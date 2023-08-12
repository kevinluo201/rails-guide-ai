**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 37dd3507f05f7787a794868a2619e6d5
Active Recordのバリデーション
=========================

このガイドでは、Active Recordのバリデーション機能を使用して、オブジェクトがデータベースに入る前の状態を検証する方法について学びます。

このガイドを読み終えると、以下のことがわかります。

* 組み込みのActive Recordバリデーションヘルパーの使用方法。
* 独自のカスタムバリデーションメソッドの作成方法。
* バリデーションプロセスで生成されるエラーメッセージの扱い方。

--------------------------------------------------------------------------------

バリデーションの概要
--------------------

以下は非常にシンプルなバリデーションの例です。

```ruby
class Person < ApplicationRecord
  validates :name, presence: true
end
```

```irb
irb> Person.create(name: "John Doe").valid?
=> true
irb> Person.create(name: nil).valid?
=> false
```

上記のように、バリデーションによって`name`属性がない場合に`Person`が無効であることがわかります。2番目の`Person`はデータベースに保存されません。

詳細について説明する前に、バリデーションがアプリケーション全体の大局的な構成にどのように組み込まれるかについて説明しましょう。

### なぜバリデーションを使用するのか？

バリデーションは、データベースに保存されるのは有効なデータのみであることを保証するために使用されます。たとえば、有効なメールアドレスや郵便送付先の提供をユーザーに要求することは、アプリケーションにとって重要な場合があります。モデルレベルのバリデーションは、データベースに有効なデータのみが保存されるようにするための最良の方法です。データベースに依存しないため、エンドユーザーによってバイパスされることはありませんし、テストやメンテナンスも容易です。Railsには一般的なニーズに対する組み込みのヘルパーが用意されており、独自のバリデーションメソッドを作成することもできます。

データベースに保存される前にデータをバリデーションするための他の方法もいくつかあります。データベースの制約、クライアントサイドのバリデーション、コントローラレベルのバリデーションなどです。以下に利点と欠点の要約を示します。

* データベースの制約やストアドプロシージャを使用すると、バリデーションメカニズムがデータベースに依存し、テストやメンテナンスがより困難になる場合があります。ただし、データベースが他のアプリケーションで使用されている場合は、データベースレベルでいくつかの制約を使用することが良いアイデアかもしれません。さらに、データベースレベルのバリデーションは、それ以外に実装が難しいいくつかのこと（例：使用頻度の高いテーブルでの一意性）を安全に処理できます。
* クライアントサイドのバリデーションは便利ですが、単独で使用すると信頼性が低い場合があります。JavaScriptを使用して実装されている場合、ユーザーのブラウザでJavaScriptが無効になっている場合はバイパスされる可能性があります。ただし、他のテクニックと組み合わせて使用する場合、クライアントサイドのバリデーションはユーザーに即時のフィードバックを提供する便利な方法になります。
* コントローラレベルのバリデーションは誘惑されるかもしれませんが、しばしば扱いにくく、テストやメンテナンスが困難になります。可能な限りコントローラをシンプルに保つことは、長期的にはアプリケーションを使いやすくするために良いアイデアです。

特定の場合にこれらを選択してください。Railsチームの意見では、モデルレベルのバリデーションがほとんどの場合に最も適切だと考えています。

### バリデーションはいつ実行されるのか？

Active Recordオブジェクトには2種類あります。データベース内の行に対応するオブジェクトと、対応しないオブジェクトです。例えば、`new`メソッドを使用して新しいオブジェクトを作成する場合、そのオブジェクトはまだデータベースに属していません。そのオブジェクトに対して`save`メソッドを呼び出すと、適切なデータベーステーブルに保存されます。Active Recordは`new_record?`インスタンスメソッドを使用して、オブジェクトが既にデータベースに存在するかどうかを判断します。次のActive Recordクラスを考えてみましょう。

```ruby
class Person < ApplicationRecord
end
```

`bin/rails console`の出力を見ることで、その動作を確認できます。

```irb
irb> p = Person.new(name: "John Doe")
=> #<Person id: nil, name: "John Doe", created_at: nil, updated_at: nil>

irb> p.new_record?
=> true

irb> p.save
=> true

irb> p.new_record?
=> false
```

新しいレコードを作成して保存すると、データベースに対してSQLの`INSERT`操作が送信されます。既存のレコードを更新すると、SQLの`UPDATE`操作が送信されます。バリデーションは通常、これらのコマンドがデータベースに送信される前に実行されます。バリデーションに失敗すると、オブジェクトは無効とマークされ、Active Recordは`INSERT`または`UPDATE`操作を実行しません。これにより、無効なオブジェクトがデータベースに保存されるのを防ぎます。オブジェクトが作成、保存、または更新される際に特定のバリデーションを実行するように選択することができます。

注意：オブジェクトの状態をデータベースで変更する方法は多くあります。一部のメソッドはバリデーションをトリガーしますが、一部はトリガーしません。注意を払わないと、無効な状態のオブジェクトをデータベースに保存する可能性があります。
以下のメソッドはバリデーションをトリガーし、オブジェクトが有効である場合にのみデータベースにオブジェクトを保存します。

* `create`
* `create!`
* `save`
* `save!`
* `update`
* `update!`

バンバージョン（例：`save!`）は、レコードが無効な場合に例外を発生させます。バンバージョンではないバージョンは、`save`と`update`は`false`を返し、`create`はオブジェクトを返します。

### バリデーションのスキップ

以下のメソッドはバリデーションをスキップし、オブジェクトをデータベースに保存します。オブジェクトの有効性に関係なく保存されます。注意して使用する必要があります。

* `decrement!`
* `decrement_counter`
* `increment!`
* `increment_counter`
* `insert`
* `insert!`
* `insert_all`
* `insert_all!`
* `toggle!`
* `touch`
* `touch_all`
* `update_all`
* `update_attribute`
* `update_column`
* `update_columns`
* `update_counters`
* `upsert`
* `upsert_all`

`save`には、引数として`validate: false`を渡すことでバリデーションをスキップする機能もあります。このテクニックは注意して使用する必要があります。

* `save(validate: false)`

### `valid?`と`invalid?`

Active Recordオブジェクトを保存する前に、Railsはバリデーションを実行します。これらのバリデーションによってエラーが発生すると、Railsはオブジェクトを保存しません。

これらのバリデーションを自分で実行することもできます。[`valid?`][]はバリデーションをトリガーし、オブジェクトにエラーが見つからない場合はtrueを返し、それ以外の場合はfalseを返します。先ほど見たように：

```ruby
class Person < ApplicationRecord
  validates :name, presence: true
end
```

```irb
irb> Person.create(name: "John Doe").valid?
=> true
irb> Person.create(name: nil).valid?
=> false
```

Active Recordがバリデーションを実行した後、失敗したバリデーションは[`errors`][]インスタンスメソッドを介してアクセスできます。これはエラーのコレクションを返します。定義によれば、バリデーションを実行した後にこのコレクションが空である場合、オブジェクトは有効です。

`new`でインスタンス化されたオブジェクトは、`create`や`save`などのオブジェクトが保存されるときにのみ、バリデーションが自動的に実行されるため、技術的には無効であってもエラーを報告しません。

```ruby
class Person < ApplicationRecord
  validates :name, presence: true
end
```

```irb
irb> p = Person.new
=> #<Person id: nil, name: nil>
irb> p.errors.size
=> 0

irb> p.valid?
=> false
irb> p.errors.objects.first.full_message
=> "Name can’t be blank"

irb> p = Person.create
=> #<Person id: nil, name: nil>
irb> p.errors.objects.first.full_message
=> "Name can’t be blank"

irb> p.save
=> false

irb> p.save!
ActiveRecord::RecordInvalid: Validation failed: Name can’t be blank

irb> Person.create!
ActiveRecord::RecordInvalid: Validation failed: Name can’t be blank
```

[`invalid?`][]は`valid?`の逆です。バリデーションをトリガーし、オブジェクトにエラーが見つかった場合はtrueを返し、それ以外の場合はfalseを返します。

### `errors[]`

オブジェクトの特定の属性が有効かどうかを確認するには、[`errors[:attribute]`][Errors#squarebrackets]を使用できます。これは`:attribute`のすべてのエラーメッセージの配列を返します。指定した属性にエラーがない場合、空の配列が返されます。

このメソッドは、バリデーションが実行された後にのみ有用です。なぜなら、バリデーション自体をトリガーせずにエラーコレクションを検査するためです。これは上記で説明した`ActiveRecord::Base#invalid?`メソッドとは異なり、オブジェクト全体の有効性を検証しません。オブジェクトの個々の属性にエラーがあるかどうかを確認するだけです。

```ruby
class Person < ApplicationRecord
  validates :name, presence: true
end
```

```irb
irb> Person.new.errors[:name].any?
=> false
irb> Person.create.errors[:name].any?
=> true
```

バリデーションエラーについては、[バリデーションエラーの操作](#working-with-validation-errors)セクションで詳しく説明します。

バリデーションヘルパー
------------------

Active Recordは、クラス定義内で直接使用できる多くの事前定義されたバリデーションヘルパーを提供しています。これらのヘルパーは一般的なバリデーションルールを提供します。バリデーションが失敗するたびに、エラーがオブジェクトの`errors`コレクションに追加され、これはバリデーションされている属性と関連付けられます。

各ヘルパーは任意の数の属性名を受け入れますので、1行のコードで複数の属性に同じ種類のバリデーションを追加することができます。

すべてのヘルパーは、`on`オプションと`message`オプションを受け入れます。これらはそれぞれ、バリデーションが実行されるタイミングと、バリデーションが失敗した場合に`errors`コレクションに追加されるメッセージを定義します。`on`オプションは、値`:create`または`:update`のいずれかを取ります。各バリデーションヘルパーにはデフォルトのエラーメッセージがあります。これらのメッセージは、`message`オプションが指定されていない場合に使用されます。利用可能なヘルパーの一覧については、[`ActiveModel::Validations::HelperMethods`][]を参照してください。
### `acceptance`

このメソッドは、フォームが送信されたときにユーザーインターフェースのチェックボックスがチェックされたことを検証します。これは、ユーザーがアプリケーションの利用規約に同意する必要がある場合、テキストが読まれたことを確認する場合、または類似の概念がある場合に通常使用されます。

```ruby
class Person < ApplicationRecord
  validates :terms_of_service, acceptance: true
end
```

このチェックは、`terms_of_service`が`nil`でない場合にのみ実行されます。
このヘルパーのデフォルトのエラーメッセージは「受け入れる必要があります」となります。
`message`オプションを使用してカスタムメッセージを渡すこともできます。

```ruby
class Person < ApplicationRecord
  validates :terms_of_service, acceptance: { message: '守られる必要があります' }
end
```

また、`accept`オプションを受け取ることもできます。これにより、許容されると見なされる許容値を指定できます。デフォルトでは`['1', true]`に設定されており、簡単に変更できます。

```ruby
class Person < ApplicationRecord
  validates :terms_of_service, acceptance: { accept: 'yes' }
  validates :eula, acceptance: { accept: ['TRUE', 'accepted'] }
end
```

この検証は、Webアプリケーションに非常に特化しており、この「受け入れ」はデータベースのどこにも記録する必要はありません。フィールドが存在しない場合、ヘルパーは仮想属性を作成します。フィールドがデータベースに存在する場合、`accept`オプションは`true`を設定するか含める必要があります。さもないと、検証は実行されません。

### `confirmation`

このヘルパーは、まったく同じ内容を受け取る必要がある2つのテキストフィールドがある場合に使用する必要があります。たとえば、電子メールアドレスやパスワードを確認する場合に使用します。この検証は、確認するフィールドの名前に "_confirmation" が追加された仮想属性を作成します。

```ruby
class Person < ApplicationRecord
  validates :email, confirmation: true
end
```

ビューテンプレートでは、次のように使用できます。

```erb
<%= text_field :person, :email %>
<%= text_field :person, :email_confirmation %>
```

注意：このチェックは、`email_confirmation`が`nil`でない場合にのみ実行されます。確認を必要とする場合は、確認属性に対して存在チェックを追加する必要があります（後でこのガイドの「存在」について説明します）。

```ruby
class Person < ApplicationRecord
  validates :email, confirmation: true
  validates :email_confirmation, presence: true
end
```

また、`case_sensitive`オプションを使用して、確認制約が大文字と小文字を区別するかどうかを定義することもできます。このオプションのデフォルトは`true`です。

```ruby
class Person < ApplicationRecord
  validates :email, confirmation: { case_sensitive: false }
end
```

このヘルパーのデフォルトのエラーメッセージは「確認が一致しません」となります。`message`オプションを使用してカスタムメッセージを渡すこともできます。

通常、このバリデータを使用する場合は、`if`オプションと組み合わせて、初期フィールドが変更されたときにのみ "_confirmation" フィールドを検証し、レコードを保存するたびに検証しないようにすることが望ましいです。後で説明する[条件付きバリデーション](#conditional-validation)について詳しく説明します。

```ruby
class Person < ApplicationRecord
  validates :email, confirmation: true
  validates :email_confirmation, presence: true, if: :email_changed?
end
```

### `comparison`

このチェックは、2つの比較可能な値の間の比較を検証します。

```ruby
class Promotion < ApplicationRecord
  validates :end_date, comparison: { greater_than: :start_date }
end
```

このヘルパーのデフォルトのエラーメッセージは「比較に失敗しました」となります。`message`オプションを使用してカスタムメッセージを渡すこともできます。

次のオプションがすべてサポートされています。

* `:greater_than` - 指定された値よりも大きい必要があります。このオプションのデフォルトのエラーメッセージは「%{count}よりも大きい必要があります」となります。
* `:greater_than_or_equal_to` - 指定された値以上である必要があります。このオプションのデフォルトのエラーメッセージは「%{count}以上である必要があります」となります。
* `:equal_to` - 指定された値と等しい必要があります。このオプションのデフォルトのエラーメッセージは「%{count}と等しい必要があります」となります。
* `:less_than` - 指定された値よりも小さい必要があります。このオプションのデフォルトのエラーメッセージは「%{count}よりも小さい必要があります」となります。
* `:less_than_or_equal_to` - 指定された値以下である必要があります。このオプションのデフォルトのエラーメッセージは「%{count}以下である必要があります」となります。
* `:other_than` - 指定された値と異なる必要があります。このオプションのデフォルトのエラーメッセージは「%{count}と異なる必要があります」となります。

注意：バリデータには比較オプションが必要です。各オプションは値、proc、またはシンボルを受け入れます。Comparableを含む任意のクラスを比較することができます。
### `format`

このヘルパーは、与えられた正規表現に一致するかどうかをテストして、属性の値を検証します。正規表現は、`:with`オプションを使用して指定します。

```ruby
class Product < ApplicationRecord
  validates :legacy_code, format: { with: /\A[a-zA-Z]+\z/,
    message: "only allows letters" }
end
```

逆に、`：without`オプションを使用すると、指定した属性が正規表現と一致しないことを要求することができます。

いずれの場合も、提供された`:with`または`:without`オプションは、正規表現または1つを返すprocまたはlambdaでなければなりません。

デフォルトのエラーメッセージは「無効です」です。

警告。文字列の先頭と末尾に一致させるには`\A`と`\z`を使用し、行の先頭/末尾に一致させるには`^`と`$`を使用します。`^`と`$`の誤用が頻繁にあるため、提供された正規表現でこれらの2つのアンカーのいずれかを使用する場合は、`multiline: true`オプションを渡す必要があります。ほとんどの場合、`\A`と`\z`を使用する必要があります。

### `inclusion`

このヘルパーは、属性の値が指定されたセットに含まれていることを検証します。実際には、このセットは任意の列挙可能なオブジェクトであることができます。

```ruby
class Coffee < ApplicationRecord
  validates :size, inclusion: { in: %w(small medium large),
    message: "%{value} is not a valid size" }
end
```

`inclusion`ヘルパーには、受け入れられる値のセットを受け取る`：in`オプションがあります。`：in`オプションには、同じ目的で使用できる`：within`という別名があります。前の例では、属性の値を含める方法を示すために`:message`オプションを使用しています。詳細なオプションについては、[メッセージのドキュメント](#message)を参照してください。

このヘルパーのデフォルトのエラーメッセージは「リストに含まれていません」です。

### `exclusion`

`inclusion`の反対は... `exclusion`です！

このヘルパーは、属性の値が指定されたセットに含まれていないことを検証します。実際には、このセットは任意の列挙可能なオブジェクトであることができます。

```ruby
class Account < ApplicationRecord
  validates :subdomain, exclusion: { in: %w(www us ca jp),
    message: "%{value} is reserved." }
end
```

`exclusion`ヘルパーには、検証される属性に受け入れられない値のセットを受け取る`：in`オプションがあります。`：in`オプションには、同じ目的で使用できる`：within`という別名があります。この例では、属性の値を含める方法を示すために`:message`オプションを使用しています。メッセージ引数の詳細なオプションについては、[メッセージのドキュメント](#message)を参照してください。

デフォルトのエラーメッセージは「予約済みです」です。

通常の列挙可能なオブジェクト（配列など）の代わりに、列挙可能なオブジェクトを返すproc、lambda、またはシンボルを指定することもできます。列挙可能なオブジェクトが数値、時間、または日時の範囲の場合、テストは`Range#cover?`で実行されます。それ以外の場合は`include?`で実行されます。procまたはlambdaを使用する場合、検証中のインスタンスが引数として渡されます。

### `length`

このヘルパーは、属性の値の長さを検証します。さまざまな方法で長さの制約を指定できるため、さまざまなオプションが用意されています。

```ruby
class Person < ApplicationRecord
  validates :name, length: { minimum: 2 }
  validates :bio, length: { maximum: 500 }
  validates :password, length: { in: 6..20 }
  validates :registration_number, length: { is: 6 }
end
```

可能な長さの制約オプションは次のとおりです。

* `:minimum` - 属性の長さは指定された長さよりも短くすることはできません。
* `:maximum` - 属性の長さは指定された長さよりも長くすることはできません。
* `:in`（または`：within`）- 属性の長さは、指定された範囲に含まれる必要があります。このオプションの値は範囲である必要があります。
* `:is` - 属性の長さは指定された値と等しくなければなりません。

デフォルトのエラーメッセージは、実行される長さの検証のタイプに依存します。これらのメッセージをカスタマイズするには、`:wrong_length`、`:too_long`、および`:too_short`オプションを使用し、長さ制約に対応する数値のプレースホルダーとして`%{count}`を使用できます。エラーメッセージを指定するには、依然として`:message`オプションを使用できます。

```ruby
class Person < ApplicationRecord
  validates :bio, length: { maximum: 1000,
    too_long: "%{count} characters is the maximum allowed" }
end
```

デフォルトのエラーメッセージは複数形です（例：「短すぎます（最小は%{count}文字です）」）。そのため、`：minimum`が1の場合はカスタムメッセージを指定するか、代わりに`presence: true`を使用する必要があります。`：in`または`：within`の下限が1の場合は、カスタムメッセージを指定するか、`length`の前に`presence`を呼び出す必要があります。
注意：`:minimum`と`:maximum`オプションを除いて、1つの制約オプションしか使用できません。

### `numericality`

このヘルパーは、属性が数値のみであることを検証します。デフォルトでは、オプションの符号の後に整数または浮動小数点数が続くことになります。

整数のみを許可する場合は、`:only_integer`をtrueに設定します。その場合、次の正規表現を使用して属性の値を検証します。

```ruby
/\A[+-]?\d+\z/
```

それ以外の場合は、`Float`を使用して値を数値に変換しようとします。`Float`は、カラムの精度値または最大15桁の`BigDecimal`にキャストされます。

```ruby
class Player < ApplicationRecord
  validates :points, numericality: true
  validates :games_played, numericality: { only_integer: true }
end
```

`:only_integer`のデフォルトのエラーメッセージは「整数でなければなりません」です。

`numericality`は、`:only_numeric`オプションも受け入れます。このオプションは、値が`Numeric`のインスタンスであることを指定し、`String`の場合は値を解析しようとします。

注意：デフォルトでは、`numericality`は`nil`の値を許可しません。`allow_nil: true`オプションを使用して許可することができます。ただし、`Integer`と`Float`のカラムでは、空の文字列は`nil`に変換されます。

オプションを指定しない場合のデフォルトのエラーメッセージは「数値ではありません」です。

許容可能な値に制約を追加するために使用できる多くのオプションもあります：

* `:greater_than` - 指定された値よりも大きい値である必要があります。このオプションのデフォルトのエラーメッセージは「%{count}よりも大きくなければなりません」です。
* `:greater_than_or_equal_to` - 指定された値以上である必要があります。このオプションのデフォルトのエラーメッセージは「%{count}以上でなければなりません」です。
* `:equal_to` - 指定された値と等しい必要があります。このオプションのデフォルトのエラーメッセージは「%{count}と等しくなければなりません」です。
* `:less_than` - 指定された値よりも小さい値である必要があります。このオプションのデフォルトのエラーメッセージは「%{count}よりも小さくなければなりません」です。
* `:less_than_or_equal_to` - 指定された値以下である必要があります。このオプションのデフォルトのエラーメッセージは「%{count}以下でなければなりません」です。
* `:other_than` - 指定された値と異なる必要があります。このオプションのデフォルトのエラーメッセージは「%{count}と異ならなければなりません」です。
* `:in` - 指定された範囲内である必要があります。このオプションのデフォルトのエラーメッセージは「%{count}内でなければなりません」です。
* `:odd` - 奇数である必要があります。このオプションのデフォルトのエラーメッセージは「奇数でなければなりません」です。
* `:even` - 偶数である必要があります。このオプションのデフォルトのエラーメッセージは「偶数でなければなりません」です。

### `presence`

このヘルパーは、指定した属性が空でないことを検証します。値が`nil`または空白の文字列（つまり、空であるか、空白で構成されている文字列）であるかどうかをチェックするために、[`Object#blank?`][]メソッドを使用します。

```ruby
class Person < ApplicationRecord
  validates :name, :login, :email, presence: true
end
```

関連するオブジェクトが存在することを確認する場合は、関連オブジェクト自体が存在するかどうかをテストする必要があります。これにより、外部キーが空でないだけでなく、参照されるオブジェクトが存在するかどうかも確認されます。

```ruby
class Supplier < ApplicationRecord
  has_one :account
  validates :account, presence: true
end
```

必要な存在を検証する関連レコードを検証するには、関連付けに対して`inverse_of`オプションを指定する必要があります。

```ruby
class Order < ApplicationRecord
  has_many :line_items, inverse_of: :order
end
```

注意：関連付けられたオブジェクトが存在し、有効であることを確認する場合は、`validates_associated`も使用する必要があります。詳細については、以下を参照してください。

`has_one`または`has_many`の関連を介して関連するオブジェクトの存在を検証する場合、オブジェクトが`blank?`でも`marked_for_destruction?`でもないことをチェックします。

`false.blank?`はtrueなので、ブールフィールドの存在を検証する場合は、次のいずれかの検証を使用する必要があります。

```ruby
# 値はtrueまたはfalseである必要があります
validates :boolean_field_name, inclusion: [true, false]
# 値はnilではない（つまりtrueまたはfalse）である必要があります
validates :boolean_field_name, exclusion: [nil]
```

これらのバリデーションのいずれかを使用することで、値が`nil`にならず、ほとんどの場合には`NULL`値にならないことを保証します。

デフォルトのエラーメッセージは「空であってはなりません」です。

### `absence`

このヘルパーは、指定した属性が存在しないことを検証します。値が`nil`または空白の文字列（空であるか、空白で構成されている文字列）でないかを確認するために、[`Object#present?`][]メソッドを使用します。

```ruby
class Person < ApplicationRecord
  validates :name, :login, :email, absence: true
end
```

関連オブジェクトが存在しないことをテストするには、関連オブジェクト自体が存在しないかどうかをテストする必要があります。関連付けのマッピングに使用される外部キーではありません。

```ruby
class LineItem < ApplicationRecord
  belongs_to :order
  validates :order, absence: true
end
```

必要な存在しない関連レコードを検証するには、関連付けに対して`:inverse_of`オプションを指定する必要があります。

```ruby
class Order < ApplicationRecord
  has_many :line_items, inverse_of: :order
end
```

注意：関連付けが存在し、有効であることを確認する場合は、`validates_associated`も使用する必要があります。詳細については、以下を参照してください。

`has_one`または`has_many`の関連付けを介して関連するオブジェクトの存在しないことを検証する場合、オブジェクトが`present?`でも`marked_for_destruction?`でもないことを確認します。

`false.present?`は`false`なので、ブールフィールドの存在しないことを検証する場合は、`validates :field_name, exclusion: { in: [true, false] }`を使用する必要があります。

デフォルトのエラーメッセージは「空でなければなりません」です。

### `uniqueness`

このヘルパーは、オブジェクトが保存される直前に属性の値が一意であることを検証します。

```ruby
class Account < ApplicationRecord
  validates :email, uniqueness: true
end
```

この検証は、モデルのテーブルに対してSQLクエリを実行し、その属性の同じ値を持つ既存のレコードを検索することで行われます。

一意性のチェックを制限するために1つ以上の属性を指定するために使用できる`:scope`オプションがあります。

```ruby
class Holiday < ApplicationRecord
  validates :name, uniqueness: { scope: :year,
    message: "should happen once per year" }
end
```

警告：この検証はデータベースに一意性制約を作成しないため、異なるデータベース接続が、一意であることを意図している列の同じ値を持つ2つのレコードを作成する可能性があります。これを避けるためには、データベースのその列に一意なインデックスを作成する必要があります。

データベースに一意な制約を追加するには、マイグレーションで[`add_index`][]ステートメントを使用し、`unique: true`オプションを含めます。

`scope`オプションを使用して一意性の検証の違反を防ぐためのデータベース制約を作成するには、データベースの両方の列に一意なインデックスを作成する必要があります。複数の列インデックスの詳細については、[MySQLマニュアル][]を参照してください。一連の列を参照する一意な制約の例については、[PostgreSQLマニュアル][]を参照してください。

また、一意性制約が大文字と小文字を区別するか、区別しないか、デフォルトのデータベースの照合順序に従うかを定義するために使用できる`:case_sensitive`オプションもあります。このオプションはデフォルトでデフォルトのデータベースの照合順序に従います。

```ruby
class Person < ApplicationRecord
  validates :name, uniqueness: { case_sensitive: false }
end
```

警告：一部のデータベースは、大文字と小文字を区別しない検索を行うように設定されていることに注意してください。

追加の条件を指定するための`:conditions`オプションもあります。これは、一意性制約の検索を制限するための`WHERE` SQLフラグメントとして追加の条件を指定するために使用します（例：`conditions: -> { where(status: 'active') }`）。

デフォルトのエラーメッセージは「すでに使用されています」です。

詳細については、[`validates_uniqueness_of`][]を参照してください。

[MySQLマニュアル]: https://dev.mysql.com/doc/refman/en/multiple-column-indexes.html
[PostgreSQLマニュアル]: https://www.postgresql.org/docs/current/static/ddl-constraints.html

### `validates_associated`

モデルに常に検証する必要がある関連がある場合は、このヘルパーを使用する必要があります。オブジェクトを保存しようとするたびに、関連オブジェクトのそれぞれに対して`valid?`が呼び出されます。

```ruby
class Library < ApplicationRecord
  has_many :books
  validates_associated :books
end
```

この検証は、すべての関連タイプで動作します。

注意：関連の両端に`validates_associated`を使用しないでください。それらは無限ループで互いを呼び出します。

[`validates_associated`][]のデフォルトのエラーメッセージは「が無効です」です。関連オブジェクトごとに独自の`errors`コレクションが含まれることに注意してください。エラーは呼び出し元のモデルには伝播しません。

注意：[`validates_associated`][]はActiveRecordオブジェクトでのみ使用できます。これまでのすべては、[`ActiveModel::Validations`][]を含むオブジェクトで使用することもできます。
### `validates_each`

このヘルパーは、属性をブロックに対して検証します。事前に定義された検証関数はありません。ブロックを使用して検証関数を作成し、[`validates_each`][] に渡されたすべての属性がそれに対してテストされます。

以下の例では、名前と姓が小文字で始まる場合は拒否します。

```ruby
class Person < ApplicationRecord
  validates_each :name, :surname do |record, attr, value|
    record.errors.add(attr, 'must start with upper case') if /\A[[:lower:]]/.match?(value)
  end
end
```

ブロックは、レコード、属性の名前、および属性の値を受け取ります。

ブロック内で有効なデータをチェックするために好きなことを行うことができます。検証が失敗した場合は、モデルにエラーを追加して無効にする必要があります。


### `validates_with`

このヘルパーは、別のクラスにレコードを渡して検証します。

```ruby
class GoodnessValidator < ActiveModel::Validator
  def validate(record)
    if record.first_name == "Evil"
      record.errors.add :base, "This person is evil"
    end
  end
end

class Person < ApplicationRecord
  validates_with GoodnessValidator
end
```

`validates_with` にはデフォルトのエラーメッセージはありません。バリデータクラスでレコードのエラーコレクションに手動でエラーを追加する必要があります。

注意: `record.errors[:base]` に追加されたエラーは、レコード全体の状態に関連しています。

`validate` メソッドを実装するには、メソッド定義で `record` パラメータを受け入れる必要があります。これは検証されるレコードです。

特定の属性にエラーを追加する場合は、最初の引数として渡します。たとえば、`record.errors.add(:first_name, "please choose another name")` のようにします。後で詳しく説明する [validation errors][] をカバーします。

```ruby
def validate(record)
  if record.some_field != "acceptable"
    record.errors.add :some_field, "this field is unacceptable"
  end
end
```

[`validates_with`][] ヘルパーは、検証に使用するクラスまたはクラスのリストを受け取ります。

```ruby
class Person < ApplicationRecord
  validates_with MyValidator, MyOtherValidator, on: :create
end
```

他のすべての検証と同様に、`validates_with` は `:if`、`:unless`、および `:on` オプションを受け取ります。他のオプションを渡すと、それらのオプションがバリデータクラスに `options` として送信されます。

```ruby
class GoodnessValidator < ActiveModel::Validator
  def validate(record)
    if options[:fields].any? { |field| record.send(field) == "Evil" }
      record.errors.add :base, "This person is evil"
    end
  end
end

class Person < ApplicationRecord
  validates_with GoodnessValidator, fields: [:first_name, :last_name]
end
```

バリデータは、アプリケーションのライフサイクル全体で *一度だけ* 初期化され、各検証実行ごとに初期化されません。そのため、インスタンス変数を使用する場合は注意してください。

バリデータがインスタンス変数を使用するほど複雑である場合は、単なる古いプレーンなRubyオブジェクトを使用することもできます。

```ruby
class Person < ApplicationRecord
  validate do |person|
    GoodnessValidator.new(person).validate
  end
end

class GoodnessValidator
  def initialize(person)
    @person = person
  end

  def validate
    if some_complex_condition_involving_ivars_and_private_methods?
      @person.errors.add :base, "This person is evil"
    end
  end

  # ...
end
```

後で [custom validations](#performing-custom-validations) を詳しく説明します。

[validation errors](#working-with-validation-errors)

Common Validation Options
-------------------------

これまで説明したバリデータでサポートされているいくつかの共通オプションがありますので、いくつか説明します！

注意: これらのオプションはすべてのバリデータでサポートされているわけではありませんので、[`ActiveModel::Validations`][] のAPIドキュメントを参照してください。

先ほど説明したバリデーションメソッドのいずれかを使用すると、バリデータと共有されるいくつかの共通オプションがあります。これらについて説明します！

* [`:allow_nil`](#allow-nil): 属性が `nil` の場合、検証をスキップします。
* [`:allow_blank`](#allow-blank): 属性が空の場合、検証をスキップします。
* [`:message`](#message): カスタムエラーメッセージを指定します。
* [`:on`](#on): この検証が有効なコンテキストを指定します。
* [`:strict`](#strict-validations): 検証に失敗した場合に例外を発生させます。
* [`:if` と `:unless`](#conditional-validation): 検証が発生するかどうかを指定します。


### `:allow_nil`

`:allow_nil` オプションは、検証される値が `nil` の場合に検証をスキップします。

```ruby
class Coffee < ApplicationRecord
  validates :size, inclusion: { in: %w(small medium large),
    message: "%{value} is not a valid size" }, allow_nil: true
end
```

```irb
irb> Coffee.create(size: nil).valid?
=> true
irb> Coffee.create(size: "mega").valid?
=> false
```

メッセージ引数の詳細なオプションについては、[message documentation](#message) を参照してください。

### `:allow_blank`

`:allow_blank` オプションは、`:allow_nil` オプションと似ています。このオプションは、属性の値が `blank?`（`nil` や空の文字列など）の場合に検証をパスさせます。

```ruby
class Topic < ApplicationRecord
  validates :title, length: { is: 5 }, allow_blank: true
end
```

```irb
irb> Topic.create(title: "").valid?
=> true
irb> Topic.create(title: nil).valid?
=> true
```

### `:message`
既にご覧の通り、`:message`オプションを使用すると、バリデーションが失敗した場合に`errors`コレクションに追加されるメッセージを指定することができます。このオプションを使用しない場合、Active Recordは各バリデーションヘルパーに対してそれぞれのデフォルトのエラーメッセージを使用します。

`:message`オプションは、値として`String`または`Proc`を受け入れます。

`String`型の`:message`値には、オプションで`%{value}`、`%{attribute}`、`%{model}`のいずれかまたはすべてを含めることができます。これらのプレースホルダは、バリデーションが失敗した場合に動的に置換されます。この置換はi18n gemを使用して行われ、プレースホルダは正確に一致する必要があります。スペースは許可されません。

```ruby
class Person < ApplicationRecord
  # ハードコードされたメッセージ
  validates :name, presence: { message: "must be given please" }

  # 動的な属性値を含むメッセージ。%{value}は属性の実際の値で置換されます。%{attribute}と%{model}も使用できます。
  validates :age, numericality: { message: "%{value} seems wrong" }
end
```

`Proc`型の`:message`値には、2つの引数が与えられます。バリデーションされるオブジェクトと、`:model`、`:attribute`、`:value`のキーと値を持つハッシュです。

```ruby
class Person < ApplicationRecord
  validates :username,
    uniqueness: {
      # object = バリデーションされるpersonオブジェクト
      # data = { model: "Person", attribute: "Username", value: <username> }
      message: ->(object, data) do
        "Hey #{object.name}, #{data[:value]} is already taken."
      end
    }
end
```

### `:on`

`:on`オプションを使用すると、バリデーションがいつ実行されるかを指定できます。組み込みのバリデーションヘルパーのデフォルトの動作は、保存時に実行されることです（新しいレコードを作成する場合と更新する場合の両方）。変更したい場合は、`on: :create`を使用して新しいレコードが作成される場合にのみバリデーションを実行するか、`on: :update`を使用してレコードが更新される場合にのみバリデーションを実行することができます。

```ruby
class Person < ApplicationRecord
  # 重複した値でemailを更新することが可能になります
  validates :email, uniqueness: true, on: :create

  # 数値でないageでレコードを作成することが可能になります
  validates :age, numericality: true, on: :update

  # デフォルト（作成と更新の両方でバリデーションを実行）
  validates :name, presence: true
end
```

`valid?`、`invalid?`、または`save`にコンテキストの名前を渡すことで、明示的にカスタムコンテキストをトリガーすることもできます。

```ruby
class Person < ApplicationRecord
  validates :email, uniqueness: true, on: :account_setup
  validates :age, numericality: true, on: :account_setup
end
```

```irb
irb> person = Person.new(age: 'thirty-three')
irb> person.valid?
=> true
irb> person.valid?(:account_setup)
=> false
irb> person.errors.messages
=> {:email=>["has already been taken"], :age=>["is not a number"]}
```

`person.valid?(:account_setup)`は、モデルを保存せずに両方のバリデーションを実行します。`person.save(context: :account_setup)`は、保存する前に`account_setup`コンテキストで`person`をバリデーションします。

シンボルの配列を渡すこともできます。

```ruby
class Book
  include ActiveModel::Validations

  validates :title, presence: true, on: [:update, :ensure_title]
end
```

```irb
irb> book = Book.new(title: nil)
irb> book.valid?
=> true
irb> book.valid?(:ensure_title)
=> false
irb> book.errors.messages
=> {:title=>["can’t be blank"]}
```

明示的なコンテキストによってトリガーされる場合、バリデーションはそのコンテキストのために実行されます。また、コンテキストの指定がないバリデーションも実行されます。

```ruby
class Person < ApplicationRecord
  validates :email, uniqueness: true, on: :account_setup
  validates :age, numericality: true, on: :account_setup
  validates :name, presence: true
end
```

```irb
irb> person = Person.new
irb> person.valid?(:account_setup)
=> false
irb> person.errors.messages
=> {:email=>["has already been taken"], :age=>["is not a number"], :name=>["can’t be blank"]}
```

`on:`の使用例については、[コールバックガイド](active_record_callbacks.html)でさらに説明します。

厳密なバリデーション
------------------

オブジェクトが無効な場合に`ActiveModel::StrictValidationFailed`を発生させるように、バリデーションを厳密に指定することもできます。

```ruby
class Person < ApplicationRecord
  validates :name, presence: { strict: true }
end
```

```irb
irb> Person.new.valid?
ActiveModel::StrictValidationFailed: Name can’t be blank
```

また、`strict`オプションにカスタムの例外を渡すこともできます。

```ruby
class Person < ApplicationRecord
  validates :token, presence: true, uniqueness: true, strict: TokenGenerationException
end
```

```irb
irb> Person.new.valid?
TokenGenerationException: Token can’t be blank
```

条件付きバリデーション
----------------------

特定の述語が満たされた場合にのみオブジェクトをバリデーションすることが意味を持つ場合があります。その場合は、`:if`オプションと`:unless`オプションを使用して、シンボル、`Proc`、または`Array`を指定することができます。バリデーションが実行されるべき時には`:if`オプションを使用し、バリデーションが実行されるべきでない時には`:unless`オプションを使用します。
### `:if`と`:unless`を使用する

`validates`メソッドの`:if`と`:unless`オプションには、バリデーションが実行される直前に呼び出されるメソッドの名前に対応するシンボルを関連付けることができます。これは最も一般的に使用されるオプションです。

```ruby
class Order < ApplicationRecord
  validates :card_number, presence: true, if: :paid_with_card?

  def paid_with_card?
    payment_type == "card"
  end
end
```

### `:if`と`:unless`を`Proc`で使用する

`Proc`オブジェクトを`:if`と`:unless`に関連付けることもできます。`Proc`オブジェクトを使用すると、別のメソッドではなくインラインの条件を記述することができます。このオプションは、1行のコードに最適です。

```ruby
class Account < ApplicationRecord
  validates :password, confirmation: true,
    unless: Proc.new { |a| a.password.blank? }
end
```

`lambda`は`Proc`の一種であるため、短縮構文を利用してインラインの条件を記述することもできます。

```ruby
validates :password, confirmation: true, unless: -> { password.blank? }
```

### 条件付きバリデーションのグループ化

複数のバリデーションが同じ条件を使用する場合、[`with_options`][]を使用して簡単に実現できます。

```ruby
class User < ApplicationRecord
  with_options if: :is_admin? do |admin|
    admin.validates :password, length: { minimum: 10 }
    admin.validates :email, presence: true
  end
end
```

`with_options`ブロック内のすべてのバリデーションは、自動的に`if: :is_admin?`の条件をパスします。


### バリデーション条件の組み合わせ

一方、複数の条件がバリデーションが実行されるかどうかを定義する場合、`Array`を使用することができます。さらに、同じバリデーションに対して`if`と`unless`の両方を適用することもできます。

```ruby
class Computer < ApplicationRecord
  validates :mouse, presence: true,
                    if: [Proc.new { |c| c.market.retail? }, :desktop?],
                    unless: Proc.new { |c| c.trackpad.present? }
end
```

バリデーションは、すべての`:if`条件が評価され、`:unless`条件のいずれも`true`に評価されない場合にのみ実行されます。

カスタムバリデーションの実行
-----------------------------

組み込みのバリデーションヘルパーが必要な要件を満たさない場合は、必要に応じて独自のバリデータまたはバリデーションメソッドを作成することができます。

### カスタムバリデータ

カスタムバリデータは、[`ActiveModel::Validator`][]を継承するクラスです。これらのクラスは、レコードを引数として受け取り、そのレコードに対してバリデーションを実行する`validate`メソッドを実装する必要があります。カスタムバリデータは、`validates_with`メソッドを使用して呼び出されます。

```ruby
class MyValidator < ActiveModel::Validator
  def validate(record)
    unless record.name.start_with? 'X'
      record.errors.add :name, "Provide a name starting with X, please!"
    end
  end
end

class Person < ApplicationRecord
  validates_with MyValidator
end
```

個々の属性をバリデートするためのカスタムバリデータを追加する最も簡単な方法は、便利な[`ActiveModel::EachValidator`][]を使用することです。この場合、カスタムバリデータクラスは、`validate_each`メソッドを実装する必要があります。このメソッドは3つの引数、レコード、属性、および渡されたインスタンスの属性の値を受け取ります。

```ruby
class EmailValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    unless URI::MailTo::EMAIL_REGEXP.match?(value)
      record.errors.add attribute, (options[:message] || "is not an email")
    end
  end
end

class Person < ApplicationRecord
  validates :email, presence: true, email: true
end
```

例に示されているように、標準のバリデーションと独自のカスタムバリデータを組み合わせることもできます。


### カスタムメソッド

モデルの状態を検証し、無効な場合に`errors`コレクションにエラーを追加するメソッドを作成することもできます。その後、`validate`クラスメソッドを使用してこれらのメソッドを登録する必要があります。バリデーションメソッドの名前のシンボルを渡すことができます。

クラスメソッドごとに複数のシンボルを渡すことができ、登録された順序で対応するバリデーションが実行されます。

`valid?`メソッドは、`errors`コレクションが空であることを検証するため、カスタムバリデーションメソッドは、バリデーションが失敗する場合にエラーを追加する必要があります。

```ruby
class Invoice < ApplicationRecord
  validate :expiration_date_cannot_be_in_the_past,
    :discount_cannot_be_greater_than_total_value

  def expiration_date_cannot_be_in_the_past
    if expiration_date.present? && expiration_date < Date.today
      errors.add(:expiration_date, "can't be in the past")
    end
  end

  def discount_cannot_be_greater_than_total_value
    if discount > total_value
      errors.add(:discount, "can't be greater than total value")
    end
  end
end
```

デフォルトでは、これらのバリデーションは`valid?`を呼び出すたびに実行されます。ただし、`validate`メソッドに`:on`オプションを指定することで、これらのカスタムバリデーションをいつ実行するかを制御することもできます。`:create`または`:update`のいずれかを指定します。

```ruby
class Invoice < ApplicationRecord
  validate :active_customer, on: :create

  def active_customer
    errors.add(:customer_id, "is not active") unless customer.active?
  end
end
```
詳細については、[`:on`](#on)を参照してください。

### バリデータのリスト

特定のオブジェクトのすべてのバリデータを調べたい場合は、`validators`を使用します。

たとえば、次のようなカスタムバリデータと組み込みバリデータを使用したモデルがあるとします。

```ruby
class Person < ApplicationRecord
  validates :name, presence: true, on: :create
  validates :email, format: URI::MailTo::EMAIL_REGEXP
  validates_with MyOtherValidator, strict: true
end
```

"Person"モデルで`validators`を使用してすべてのバリデータをリストアップしたり、`validators_on`を使用して特定のフィールドをチェックしたりできます。

```irb
irb> Person.validators
#=> [#<ActiveRecord::Validations::PresenceValidator:0x10b2f2158
      @attributes=[:name], @options={:on=>:create}>,
     #<MyOtherValidatorValidator:0x10b2f17d0
      @attributes=[:name], @options={:strict=>true}>,
     #<ActiveModel::Validations::FormatValidator:0x10b2f0f10
      @attributes=[:email],
      @options={:with=>URI::MailTo::EMAIL_REGEXP}>]
     #<MyOtherValidator:0x10b2f0948 @options={:strict=>true}>]

irb> Person.validators_on(:name)
#=> [#<ActiveModel::Validations::PresenceValidator:0x10b2f2158
      @attributes=[:name], @options={on: :create}>]
```


バリデーションエラーの処理
------------------------------

[`valid?`][]メソッドと[`invalid?`][]メソッドは、妥当性に関する概要ステータスのみを提供します。ただし、[`errors`][]コレクションのさまざまなメソッドを使用して、各個別のエラーに詳しくアクセスすることができます。

以下は、最も一般的に使用されるメソッドのリストです。すべての利用可能なメソッドのリストについては、[`ActiveModel::Errors`][]ドキュメントを参照してください。


### `errors`

各エラーのさまざまな詳細に深く入り込むためのゲートウェイです。

これは、すべてのエラーを含む`ActiveModel::Errors`クラスのインスタンスを返します。各エラーは[`ActiveModel::Error`][]オブジェクトで表されます。

```ruby
class Person < ApplicationRecord
  validates :name, presence: true, length: { minimum: 3 }
end
```

```irb
irb> person = Person.new
irb> person.valid?
=> false
irb> person.errors.full_messages
=> ["Name can’t be blank", "Name is too short (minimum is 3 characters)"]

irb> person = Person.new(name: "John Doe")
irb> person.valid?
=> true
irb> person.errors.full_messages
=> []

irb> person = Person.new
irb> person.valid?
=> false
irb> person.errors.first.details
=> {:error=>:too_short, :count=>3}
```


### `errors[]`

[`errors[]`][Errors#squarebrackets]は、特定の属性のエラーメッセージをチェックする場合に使用します。指定された属性のすべてのエラーメッセージを含む文字列の配列を返します。エラーが属性に関連付けられていない場合は、空の配列を返します。

```ruby
class Person < ApplicationRecord
  validates :name, presence: true, length: { minimum: 3 }
end
```

```irb
irb> person = Person.new(name: "John Doe")
irb> person.valid?
=> true
irb> person.errors[:name]
=> []

irb> person = Person.new(name: "JD")
irb> person.valid?
=> false
irb> person.errors[:name]
=> ["is too short (minimum is 3 characters)"]

irb> person = Person.new
irb> person.valid?
=> false
irb> person.errors[:name]
=> ["can’t be blank", "is too short (minimum is 3 characters)"]
```

### `errors.where`とエラーオブジェクト

エラーメッセージ以外の各エラーについての詳細情報が必要な場合があります。各エラーは`ActiveModel::Error`オブジェクトとしてカプセル化されており、[`where`][]メソッドはアクセスするための最も一般的な方法です。

`where`は、さまざまな条件でフィルタリングされたエラーオブジェクトの配列を返します。

```ruby
class Person < ApplicationRecord
  validates :name, presence: true, length: { minimum: 3 }
end
```

`where`メソッドに`attribute`を最初のパラメータとして渡すと、`attribute`だけをフィルタリングします。2番目のパラメータは、`errors.where(:attr, :type)`を呼び出すことで、フィルタリングする`type`のエラーを指定します。

```irb
irb> person = Person.new
irb> person.valid?
=> false

irb> person.errors.where(:name)
=> [ ... ] # :name属性のすべてのエラー

irb> person.errors.where(:name, :too_short)
=> [ ... ] # :name属性の:too_shortエラー
```

最後に、指定されたタイプのエラーオブジェクトに存在する任意の`options`でフィルタリングすることもできます。

```irb
irb> person = Person.new
irb> person.valid?
=> false

irb> person.errors.where(:name, :too_short, minimum: 3)
=> [ ... ] # 名前が短すぎて、最小が2のすべての名前エラー
```

これらのエラーオブジェクトからさまざまな情報を読み取ることができます。

```irb
irb> error = person.errors.where(:name).last

irb> error.attribute
=> :name
irb> error.type
=> :too_short
irb> error.options[:count]
=> 3
```

エラーメッセージも生成できます。

```irb
irb> error.message
=> "is too short (minimum is 3 characters)"
irb> error.full_message
=> "Name is too short (minimum is 3 characters)"
```

[`full_message`][]メソッドは、大文字化された属性名が前に付けられた、よりユーザーフレンドリーなメッセージを生成します（`full_message`が使用するフォーマットをカスタマイズするには、[I18nガイド](i18n.html#active-model-methods)を参照してください）。

### `errors.add`

[`add`][]メソッドは、`attribute`、エラー`type`、および追加のオプションハッシュを取ることで、エラーオブジェクトを作成します。これは、独自のバリデータを作成する場合に便利です。これにより、非常に具体的なエラーシチュエーションを定義することができます。

```ruby
class Person < ApplicationRecord
  validate do |person|
    errors.add :name, :too_plain, message: "is not cool enough"
  end
end
```
```irb
irb> person = Person.create
irb> person.errors.where(:name).first.type
=> :too_plain
irb> person.errors.where(:name).first.full_message
=> "名前は十分にクールではありません"
```


### `errors[:base]`

オブジェクトの状態全体に関連するエラーを、特定の属性に関連するエラーではなく追加することができます。これを行うには、新しいエラーを追加する際に `:base` を属性として使用する必要があります。

```ruby
class Person < ApplicationRecord
  validate do |person|
    errors.add :base, :invalid, message: "この人物は無効です..."
  end
end
```

```irb
irb> person = Person.create
irb> person.errors.where(:base).first.full_message
=> "この人物は無効です..."
```

### `errors.size`

`size` メソッドは、オブジェクトのエラーの総数を返します。

```ruby
class Person < ApplicationRecord
  validates :name, presence: true, length: { minimum: 3 }
end
```

```irb
irb> person = Person.new
irb> person.valid?
=> false
irb> person.errors.size
=> 2

irb> person = Person.new(name: "Andrea", email: "andrea@example.com")
irb> person.valid?
=> true
irb> person.errors.size
=> 0
```

### `errors.clear`

`clear` メソッドは、意図的に `errors` コレクションをクリアする場合に使用されます。もちろん、無効なオブジェクトに `errors.clear` を呼び出しても、オブジェクトは実際には有効になりません。`errors` コレクションは空になりますが、次に `valid?` メソッドやこのオブジェクトをデータベースに保存しようとする任意のメソッドを呼び出すと、バリデーションが再度実行されます。バリデーションのいずれかが失敗すると、`errors` コレクションは再び埋められます。

```ruby
class Person < ApplicationRecord
  validates :name, presence: true, length: { minimum: 3 }
end
```

```irb
irb> person = Person.new
irb> person.valid?
=> false
irb> person.errors.empty?
=> false

irb> person.errors.clear
irb> person.errors.empty?
=> true

irb> person.save
=> false

irb> person.errors.empty?
=> false
```

ビューでのバリデーションエラーの表示
-------------------------------------

モデルを作成し、バリデーションを追加した後、そのモデルがウェブフォームを介して作成される場合、バリデーションが失敗した場合にエラーメッセージを表示することができると思います。

この種の処理は、すべてのアプリケーションが異なる方法で処理するため、Railsには直接これらのメッセージを生成するためのビューヘルパーは含まれていません。ただし、Railsが一般的なバリデーションとの対話に使用する豊富なメソッドのおかげで、独自のメソッドを作成することができます。さらに、スキャフォールドを生成するときに、Railsは生成された `_form.html.erb` にいくつかのERBを配置し、そのモデルの完全なエラーリストを表示します。

`@article` という名前のインスタンス変数に保存されたモデルがあると仮定すると、次のようになります。

```html+erb
<% if @article.errors.any? %>
  <div id="error_explanation">
    <h2><%= pluralize(@article.errors.count, "error") %> が保存できないため、この記事は無効です:</h2>

    <ul>
      <% @article.errors.each do |error| %>
        <li><%= error.full_message %></li>
      <% end %>
    </ul>
  </div>
<% end %>
```

さらに、フォームを生成するためにRailsのフォームヘルパーを使用すると、フィールドでバリデーションエラーが発生すると、エントリの周りに追加の `<div>` が生成されます。

```html
<div class="field_with_errors">
  <input id="article_title" name="article[title]" size="30" type="text" value="">
</div>
```

その後、このdivに任意のスタイルを適用することができます。Railsが生成するデフォルトのスキャフォールドでは、次のCSSルールが追加されます。

```css
.field_with_errors {
  padding: 2px;
  background-color: red;
  display: table;
}
```

これにより、エラーが発生したフィールドには2ピクセルの赤いボーダーが追加されます。
[`errors`]: https://api.rubyonrails.org/classes/ActiveModel/Validations.html#method-i-errors
[`invalid?`]: https://api.rubyonrails.org/classes/ActiveModel/Validations.html#method-i-invalid-3F
[`valid?`]: https://api.rubyonrails.org/classes/ActiveRecord/Validations.html#method-i-valid-3F
[Errors#squarebrackets]: https://api.rubyonrails.org/classes/ActiveModel/Errors.html#method-i-5B-5D
[`ActiveModel::Validations::HelperMethods`]: https://api.rubyonrails.org/classes/ActiveModel/Validations/HelperMethods.html
[`Object#blank?`]: https://api.rubyonrails.org/classes/Object.html#method-i-blank-3F
[`Object#present?`]: https://api.rubyonrails.org/classes/Object.html#method-i-present-3F
[`validates_uniqueness_of`]: https://api.rubyonrails.org/classes/ActiveRecord/Validations/ClassMethods.html#method-i-validates_uniqueness_of
[`add_index`]: https://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html#method-i-add_index
[`validates_associated`]: https://api.rubyonrails.org/classes/ActiveRecord/Validations/ClassMethods.html#method-i-validates_associated
[`validates_each`]: https://api.rubyonrails.org/classes/ActiveModel/Validations/ClassMethods.html#method-i-validates_each
[`validates_with`]: https://api.rubyonrails.org/classes/ActiveModel/Validations/ClassMethods.html#method-i-validates_with
[`ActiveModel::Validations`]: https://api.rubyonrails.org/classes/ActiveModel/Validations.html
[`with_options`]: https://api.rubyonrails.org/classes/Object.html#method-i-with_options
[`ActiveModel::EachValidator`]: https://api.rubyonrails.org/classes/ActiveModel/EachValidator.html
[`ActiveModel::Validator`]: https://api.rubyonrails.org/classes/ActiveModel/Validator.html
[`validate`]: https://api.rubyonrails.org/classes/ActiveModel/Validations/ClassMethods.html#method-i-validate
[`ActiveModel::Errors`]: https://api.rubyonrails.org/classes/ActiveModel/Errors.html
[`ActiveModel::Error`]: https://api.rubyonrails.org/classes/ActiveModel/Error.html
[`full_message`]: https://api.rubyonrails.org/classes/ActiveModel/Errors.html#method-i-full_message
[`where`]: https://api.rubyonrails.org/classes/ActiveModel/Errors.html#method-i-where
[`add`]: https://api.rubyonrails.org/classes/ActiveModel/Errors.html#method-i-add
