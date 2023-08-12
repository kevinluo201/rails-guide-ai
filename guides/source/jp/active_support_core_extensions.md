**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: fdd2e5c41171c61b555549ced4d68a82
Active Supportコア拡張機能
==============================

Active Supportは、Ruby言語の拡張とユーティリティを提供するRuby on Railsのコンポーネントです。

これは、Railsアプリケーションの開発とRuby on Rails自体の開発の両方を対象とした、より豊かな言語レベルの機能を提供します。

このガイドを読むことで、以下のことがわかります：

* コア拡張とは何か。
* すべての拡張機能をロードする方法。
* 必要な拡張機能のみを選択する方法。
* Active Supportが提供する拡張機能は何か。

--------------------------------------------------------------------------------

コア拡張機能のロード方法
---------------------------

### スタンドアロンのActive Support

Active Supportは、デフォルトで可能な限り最小の依存関係をロードするために、最小限の依存関係をロードします。それは小さな部分に分割されているため、必要な拡張機能のみをロードすることができます。また、関連する拡張機能を一度にロードするための便利なエントリーポイントもあります。

したがって、次のような単純な`require`の後には、Active Supportフレームワークで必要な拡張機能のみがロードされます。

```ruby
require "active_support"
```

#### 定義の選択

この例では、[`Hash#with_indifferent_access`][Hash#with_indifferent_access]をロードする方法を示しています。この拡張機能は、`Hash`を[`ActiveSupport::HashWithIndifferentAccess`][ActiveSupport::HashWithIndifferentAccess]に変換し、キーを文字列またはシンボルとしてアクセスできるようにします。

```ruby
{ a: 1 }.with_indifferent_access["a"] # => 1
```

このガイドでは、各コア拡張機能のメソッドごとに、そのメソッドがどこで定義されているかを示すノートがあります。`with_indifferent_access`の場合、ノートは次のようになります：

NOTE: `active_support/core_ext/hash/indifferent_access.rb`で定義されています。

これは、次のようにしてそれを要求できることを意味します：

```ruby
require "active_support"
require "active_support/core_ext/hash/indifferent_access"
```

Active Supportは、必要な依存関係のみを厳密にロードするように注意深く見直されています。

#### グループ化されたコア拡張機能のロード

次のレベルは、単に`Hash`へのすべての拡張機能をロードすることです。`SomeClass`への拡張機能は、`active_support/core_ext/some_class`をロードすることで一度に利用できるという規則です。

したがって、すべての`Hash`への拡張機能（`with_indifferent_access`を含む）をロードするには、次のようにします。

```ruby
require "active_support"
require "active_support/core_ext/hash"
```

#### すべてのコア拡張機能のロード

すべてのコア拡張機能をロードするだけの場合は、次のファイルがあります。

```ruby
require "active_support"
require "active_support/core_ext"
```

#### すべてのActive Supportのロード

最後に、すべてのActive Supportを利用したい場合は、次のようにします。

```ruby
require "active_support/all"
```

これにより、Active Support全体が事前にメモリに配置されるわけではありません。一部のものは`autoload`を介して設定されているため、使用時にのみロードされます。

### Ruby on Railsアプリケーション内のActive Support

Ruby on Railsアプリケーションは、[`config.active_support.bare`][]がtrueでない限り、すべてのActive Supportをロードします。その場合、アプリケーションはフレームワーク自体が必要とするものだけを選択してロードし、前のセクションで説明したように、任意の粒度で自身を選択することもできます。


すべてのオブジェクトへの拡張機能
-------------------------

### `blank?`と`present?`

Railsアプリケーションでは、次の値が空と見なされます：

* `nil`と`false`、

* 空白のみで構成された文字列（以下の注意事項を参照）、

* 空の配列とハッシュ、および

* `empty?`に応答し、空である他のオブジェクト。

INFO: 文字列の述語は、Unicode対応の文字クラス`[:space:]`を使用しているため、たとえばU+2029（段落セパレータ）は空白と見なされます。

WARNING: 数字は言及されていません。特に、0と0.0は**空ではありません**。

たとえば、この`ActionController::HttpAuthentication::Token::ControllerMethods`のメソッドでは、トークンが存在するかどうかを確認するために[`blank?`][Object#blank?]を使用しています。

```ruby
def authenticate(controller, &login_procedure)
  token, options = token_and_options(controller.request)
  unless token.blank?
    login_procedure.call(token, options)
  end
end
```

メソッド[`present?`][Object#present?]は、`!blank?`と同等です。この例は、`ActionDispatch::Http::Cache::Response`から取得されています。

```ruby
def set_conditional_cache_control!
  return if self["Cache-Control"].present?
  # ...
end
```

NOTE: `active_support/core_ext/object/blank.rb`で定義されています。


### `presence`

[`presence`][Object#presence]メソッドは、`present?`であればレシーバー自体を返し、そうでなければ`nil`を返します。次のようなイディオムに便利です：
```ruby
host = config[:host].presence || 'localhost'
```

注意：`active_support/core_ext/object/blank.rb`で定義されています。


### `duplicable?`

Ruby 2.5以降、ほとんどのオブジェクトは`dup`または`clone`を使用して複製できます。

```ruby
"foo".dup           # => "foo"
"".dup              # => ""
Rational(1).dup     # => (1/1)
Complex(0).dup      # => (0+0i)
1.method(:+).dup    # => TypeError (allocator undefined for Method)
```

Active Supportは[`duplicable?`][Object#duplicable?]を提供して、オブジェクトに対してクエリを行うことができます。

```ruby
"foo".duplicable?           # => true
"".duplicable?              # => true
Rational(1).duplicable?     # => true
Complex(1).duplicable?      # => true
1.method(:+).duplicable?    # => false
```

警告：任意のクラスは`dup`と`clone`を削除するか、それらから例外を発生させることで複製を禁止することができます。したがって、与えられた任意のオブジェクトが複製可能かどうかは`rescue`のみが判断できます。`duplicable?`は上記のハードコードされたリストに依存していますが、`rescue`よりもはるかに高速です。使用する場合は、ハードコードされたリストが使用ケースで十分であることを確認してください。

注意：`active_support/core_ext/object/duplicable.rb`で定義されています。


### `deep_dup`

[`deep_dup`][Object#deep_dup]メソッドは、指定されたオブジェクトのディープコピーを返します。通常、他のオブジェクトを含むオブジェクトを`dup`すると、Rubyはそれらを`dup`しないため、オブジェクトの浅いコピーが作成されます。たとえば、文字列を含む配列がある場合、次のようになります。

```ruby
array     = ['string']
duplicate = array.dup

duplicate.push 'another-string'

# オブジェクトが複製されたため、要素は複製にのみ追加されました
array     # => ['string']
duplicate # => ['string', 'another-string']

duplicate.first.gsub!('string', 'foo')

# 最初の要素は複製されていないため、両方の配列で変更されます
array     # => ['foo']
duplicate # => ['foo', 'another-string']
```

見ての通り、`Array`インスタンスを複製した後、別のオブジェクトが得られるため、それを変更することができ、元のオブジェクトは変更されません。ただし、配列の要素についてはそうではありません。`dup`はディープコピーを作成しないため、配列内の文字列はまだ同じオブジェクトです。

オブジェクトのディープコピーが必要な場合は、`deep_dup`を使用する必要があります。以下に例を示します。

```ruby
array     = ['string']
duplicate = array.deep_dup

duplicate.first.gsub!('string', 'foo')

array     # => ['string']
duplicate # => ['foo']
```

オブジェクトが複製できない場合、`deep_dup`は単にそれを返します。

```ruby
number = 1
duplicate = number.deep_dup
number.object_id == duplicate.object_id   # => true
```

注意：`active_support/core_ext/object/deep_dup.rb`で定義されています。


### `try`

オブジェクトが`nil`でない場合にのみメソッドを呼び出したい場合、条件文を追加して不要な冗長性を追加する方法があります。代替方法は、[`try`][Object#try]を使用することです。`try`は`nil`に送信された場合に`nil`を返す点を除いて、`Object#public_send`と似ています。

以下に例を示します。

```ruby
# tryを使用しない場合
unless @number.nil?
  @number.next
end

# tryを使用する場合
@number.try(:next)
```

もう1つの例は、`ActiveRecord::ConnectionAdapters::AbstractAdapter`のコードで、`@logger`が`nil`の場合があります。コードは`try`を使用し、不要なチェックを回避していることがわかります。

```ruby
def log_info(sql, name, ms)
  if @logger.try(:debug?)
    name = '%s (%.1fms)' % [name || 'SQL', ms]
    @logger.debug(format_log_entry(name, sql.squeeze(' ')))
  end
end
```

`try`は引数なしで呼び出すこともできますが、ブロックを伴います。この場合、オブジェクトが`nil`でない場合にのみ実行されます。

```ruby
@person.try { |p| "#{p.first_name} #{p.last_name}" }
```

`try`は存在しないメソッドのエラーを無視し、代わりに`nil`を返します。スペルミスに対して保護する場合は、[`try!`][Object#try!]を使用してください。

```ruby
@number.try(:nest)  # => nil
@number.try!(:nest) # NoMethodError: undefined method `nest' for 1:Integer
```

注意：`active_support/core_ext/object/try.rb`で定義されています。


### `class_eval(*args, &block)`

[`class_eval`][Kernel#class_eval]を使用して、任意のオブジェクトのシングルトンクラスのコンテキストでコードを評価することができます。

```ruby
class Proc
  def bind(object)
    block, time = self, Time.current
    object.class_eval do
      method_name = "__bind_#{time.to_i}_#{time.usec}"
      define_method(method_name, &block)
      method = instance_method(method_name)
      remove_method(method_name)
      method
    end.bind(object)
  end
end
```

注意：`active_support/core_ext/kernel/singleton_class.rb`で定義されています。


### `acts_like?(duck)`

[`acts_like?`][Object#acts_like?]メソッドは、単純な規則に基づいて、あるクラスが別のクラスのように振る舞うかどうかをチェックする方法を提供します。
```ruby
def acts_like_string?
end
```

これは単なるマーカーであり、その本体や返り値は関係ありません。その後、クライアントコードは次のようにしてダックタイプの安全性をクエリできます。

```ruby
some_klass.acts_like?(:string)
```

Railsには、`Date`や`Time`のように振る舞い、この契約に従うクラスがあります。

注意：`active_support/core_ext/object/acts_like.rb`で定義されています。


### `to_param`

Railsのすべてのオブジェクトは、[`to_param`][Object#to_param]メソッドに応答します。このメソッドは、クエリ文字列やURLフラグメントとしてオブジェクトを表すものを返すためのものです。

デフォルトでは、`to_param`は単に`to_s`を呼び出します。

```ruby
7.to_param # => "7"
```

`to_param`の返り値はエスケープされてはいけません。

```ruby
"Tom & Jerry".to_param # => "Tom & Jerry"
```

Railsのいくつかのクラスはこのメソッドを上書きしています。

例えば、`nil`、`true`、`false`はそれ自体を返します。[`Array#to_param`][Array#to_param]は要素に`to_param`を呼び出し、結果を"/"で結合します。

```ruby
[0, true, String].to_param # => "0/true/String"
```

特に、Railsのルーティングシステムはモデルの`to_param`を呼び出して`:id`プレースホルダーの値を取得します。`ActiveRecord::Base#to_param`はモデルの`id`を返しますが、モデルでこのメソッドを再定義することもできます。例えば、次のように定義されている場合、

```ruby
class User
  def to_param
    "#{id}-#{name.parameterize}"
  end
end
```

次のようになります。

```ruby
user_path(@user) # => "/users/357-john-smith"
```

警告：コントローラは`to_param`の再定義に注意する必要があります。なぜなら、"357-john-smith"のようなリクエストが来た場合、`params[:id]`の値がそれになるからです。

注意：`active_support/core_ext/object/to_param.rb`で定義されています。


### `to_query`

[`to_query`][Object#to_query]メソッドは、指定された`key`を`to_param`の返り値に関連付けるクエリ文字列を構築します。例えば、次の`to_param`の定義がある場合、

```ruby
class User
  def to_param
    "#{id}-#{name.parameterize}"
  end
end
```

次のようになります。

```ruby
current_user.to_query('user') # => "user=357-john-smith"
```

このメソッドは、必要なものをエスケープします。キーと値の両方に対してです。

```ruby
account.to_query('company[name]')
# => "company%5Bname%5D=Johnson+%26+Johnson"
```

そのため、出力はクエリ文字列で使用する準備ができています。

配列は、各要素に対して`key[]`をキーとして`to_query`を適用し、結果を"&"で結合します。

```ruby
[3.4, -45.6].to_query('sample')
# => "sample%5B%5D=3.4&sample%5B%5D=-45.6"
```

ハッシュも`to_query`に応答しますが、異なるシグネチャを持ちます。引数が渡されない場合、呼び出しは値に`to_query(key)`を呼び出してソートされたキー/値の割り当てのシリーズを生成します。それから結果を"&"で結合します。

```ruby
{ c: 3, b: 2, a: 1 }.to_query # => "a=1&b=2&c=3"
```

メソッド[`Hash#to_query`][Hash#to_query]は、キーに対するオプションの名前空間を受け入れます。

```ruby
{ id: 89, name: "John Smith" }.to_query('user')
# => "user%5Bid%5D=89&user%5Bname%5D=John+Smith"
```

注意：`active_support/core_ext/object/to_query.rb`で定義されています。


### `with_options`

[`with_options`][Object#with_options]メソッドは、一連のメソッド呼び出しで共通のオプションをまとめる方法を提供します。

デフォルトのオプションハッシュが与えられると、`with_options`はブロックに対してプロキシオブジェクトをyieldします。ブロック内では、プロキシに対して呼び出されたメソッドは、オプションがマージされた状態でレシーバに転送されます。例えば、次のようにして重複を取り除くことができます。

```ruby
class Account < ApplicationRecord
  has_many :customers, dependent: :destroy
  has_many :products,  dependent: :destroy
  has_many :invoices,  dependent: :destroy
  has_many :expenses,  dependent: :destroy
end
```

次のようにします。

```ruby
class Account < ApplicationRecord
  with_options dependent: :destroy do |assoc|
    assoc.has_many :customers
    assoc.has_many :products
    assoc.has_many :invoices
    assoc.has_many :expenses
  end
end
```

このイディオムは、読み手にも「グループ化」を伝えるかもしれません。例えば、ユーザに依存するニュースレターを送信したい場合、メーラのどこかで次のようにロケールに依存する部分をグループ化できます。

```ruby
I18n.with_options locale: user.locale, scope: "newsletter" do |i18n|
  subject i18n.t :subject
  body    i18n.t :body, user_name: user.name
end
```

TIP: `with_options`は呼び出しをレシーバに転送するため、ネストすることができます。各ネストレベルは、独自のものに加えて継承されたデフォルトをマージします。

注意：`active_support/core_ext/object/with_options.rb`で定義されています。


### JSONサポート

Active Supportは、通常の`json`ジェムが提供するRubyオブジェクトの`to_json`よりも優れた実装を提供します。これは、`Hash`や`Process::Status`などの一部のクラスが適切なJSON表現を提供するために特別な処理が必要なためです。
注意：`active_support/core_ext/object/json.rb`で定義されています。

### インスタンス変数

Active Supportは、インスタンス変数へのアクセスを容易にするためのいくつかのメソッドを提供しています。

#### `instance_values`

[`instance_values`][Object#instance_values]メソッドは、"@"を含まないインスタンス変数名を対応する値にマッピングするハッシュを返します。キーは文字列です。

```ruby
class C
  def initialize(x, y)
    @x, @y = x, y
  end
end

C.new(0, 1).instance_values # => {"x" => 0, "y" => 1}
```

注意：`active_support/core_ext/object/instance_variables.rb`で定義されています。


#### `instance_variable_names`

[`instance_variable_names`][Object#instance_variable_names]メソッドは、配列を返します。各名前には"@"の記号が含まれます。

```ruby
class C
  def initialize(x, y)
    @x, @y = x, y
  end
end

C.new(0, 1).instance_variable_names # => ["@x", "@y"]
```

注意：`active_support/core_ext/object/instance_variables.rb`で定義されています。


### 警告と例外の抑制

[`silence_warnings`][Kernel#silence_warnings]メソッドと[`enable_warnings`][Kernel#enable_warnings]メソッドは、ブロックの実行中に`$VERBOSE`の値を適切に変更し、その後にリセットします。

```ruby
silence_warnings { Object.const_set "RAILS_DEFAULT_LOGGER", logger }
```

[`suppress`][Kernel#suppress]メソッドを使用すると、例外を抑制することも可能です。このメソッドは任意の数の例外クラスを受け取ります。ブロックの実行中に例外が発生し、引数のいずれかに`kind_of?`である場合、`suppress`は例外をキャプチャして無視します。それ以外の場合、例外はキャプチャされません。

```ruby
# ユーザーがロックされている場合、インクリメントは失われますが、大したことではありません。
suppress(ActiveRecord::StaleObjectError) do
  current_user.increment! :visits
end
```

注意：`active_support/core_ext/kernel/reporting.rb`で定義されています。


### `in?`

述語[`in?`][Object#in?]は、オブジェクトが別のオブジェクトに含まれているかどうかをテストします。引数が`include?`に応答しない場合、`ArgumentError`例外が発生します。

`in?`の例：

```ruby
1.in?([1, 2])        # => true
"lo".in?("hello")   # => true
25.in?(30..50)      # => false
1.in?(1)            # => ArgumentError
```

注意：`active_support/core_ext/object/inclusion.rb`で定義されています。


`Module`への拡張
----------------------

### 属性

#### `alias_attribute`

モデルの属性には、リーダー、ライター、および述語があります。[`alias_attribute`][Module#alias_attribute]を使用すると、対応する3つのメソッドがすべて定義されたモデル属性のエイリアスを作成できます。他のエイリアスメソッドと同様に、新しい名前は最初の引数で、古い名前は2番目の引数です（代入を行う場合と同じ順序になることを覚えておくと覚えやすいです）。

```ruby
class User < ApplicationRecord
  # emailカラムを"login"として参照できます。
  # 認証コードに意味があるかもしれません。
  alias_attribute :login, :email
end
```

注意：`active_support/core_ext/module/aliasing.rb`で定義されています。


#### 内部属性

サブクラス化されるクラスで属性を定義する場合、名前の衝突が発生する可能性があります。これは、ライブラリにとって非常に重要です。

Active Supportは、[`attr_internal_reader`][Module#attr_internal_reader]、[`attr_internal_writer`][Module#attr_internal_writer]、および[`attr_internal_accessor`][Module#attr_internal_accessor]というマクロを定義しています。これらは、Rubyの組み込みの`attr_*`と同様に動作しますが、衝突の可能性が低くなるようにインスタンス変数の名前を付けます。

マクロ[`attr_internal`][Module#attr_internal]は、`attr_internal_accessor`の同義語です。

```ruby
# ライブラリ
class ThirdPartyLibrary::Crawler
  attr_internal :log_level
end

# クライアントコード
class MyCrawler < ThirdPartyLibrary::Crawler
  attr_accessor :log_level
end
```

前の例では、`log_level`がライブラリの公開インターフェースに属していない可能性があり、開発のためにのみ使用されている場合があります。クライアントコードは潜在的な衝突に気付かずにサブクラス化し、独自の`log_level`を定義します。`attr_internal`のおかげで衝突は発生しません。

デフォルトでは、内部インスタンス変数は先頭にアンダースコアが付いた形式で名前付けられます。上記の例では`@_log_level`です。ただし、`Module.attr_internal_naming_format`を介して設定可能であり、先頭に`@`が付いた`sprintf`のような形式の文字列と`%s`がどこかにある`sprintf`のような形式の文字列を渡すことができます。そこに名前が配置されます。デフォルトは`"@_%s"`です。

Railsでは、ビューなどのいくつかの場所で内部属性を使用しています。

```ruby
module ActionView
  class Base
    attr_internal :captures
    attr_internal :request, :layout
    attr_internal :controller, :template
  end
end
```

注意：`active_support/core_ext/module/attr_internal.rb`で定義されています。


#### モジュール属性

[`mattr_reader`][Module#mattr_reader]、[`mattr_writer`][Module#mattr_writer]、および[`mattr_accessor`][Module#mattr_accessor]というマクロは、クラスのために定義された`cattr_*`マクロと同じです。実際、`cattr_*`マクロは`mattr_*`マクロのエイリアスです。[クラス属性](#class-attributes)を参照してください。
例えば、Active StorageのロガーのAPIは`mattr_accessor`を使用して生成されます。

```ruby
module ActiveStorage
  mattr_accessor :logger
end
```

注：`active_support/core_ext/module/attribute_accessors.rb`で定義されています。


### 親

#### `module_parent`

ネストされた名前付きモジュールの[`module_parent`][Module#module_parent]メソッドは、対応する定数を含むモジュールを返します。

```ruby
module X
  module Y
    module Z
    end
  end
end
M = X::Y::Z

X::Y::Z.module_parent # => X::Y
M.module_parent       # => X::Y
```

モジュールが無名であるか、トップレベルに属している場合、`module_parent`は`Object`を返します。

警告：この場合、`module_parent_name`は`nil`を返すことに注意してください。

注：`active_support/core_ext/module/introspection.rb`で定義されています。


#### `module_parent_name`

ネストされた名前付きモジュールの[`module_parent_name`][Module#module_parent_name]メソッドは、対応する定数を含むモジュールの完全修飾名を返します。

```ruby
module X
  module Y
    module Z
    end
  end
end
M = X::Y::Z

X::Y::Z.module_parent_name # => "X::Y"
M.module_parent_name       # => "X::Y"
```

トップレベルまたは無名のモジュールの場合、`module_parent_name`は`nil`を返します。

警告：この場合、`module_parent`は`Object`を返します。

注：`active_support/core_ext/module/introspection.rb`で定義されています。


#### `module_parents`

[`module_parents`][Module#module_parents]メソッドは、レシーバーに対して`module_parent`を呼び出し、`Object`に到達するまで上方向に呼び出します。チェーンは、下から上に向かって配列で返されます。

```ruby
module X
  module Y
    module Z
    end
  end
end
M = X::Y::Z

X::Y::Z.module_parents # => [X::Y, X, Object]
M.module_parents       # => [X::Y, X, Object]
```

注：`active_support/core_ext/module/introspection.rb`で定義されています。


### 無名

モジュールには名前がある場合とない場合があります。

```ruby
module M
end
M.name # => "M"

N = Module.new
N.name # => "N"

Module.new.name # => nil
```

述語[`anonymous?`][Module#anonymous?]を使用して、モジュールに名前があるかどうかを確認できます。

```ruby
module M
end
M.anonymous? # => false

Module.new.anonymous? # => true
```

到達不能であることは無名であることを意味しないことに注意してください。

```ruby
module M
end

m = Object.send(:remove_const, :M)

m.anonymous? # => false
```

ただし、無名のモジュールは定義により到達不能です。

注：`active_support/core_ext/module/anonymous.rb`で定義されています。


### メソッドの委譲

#### `delegate`

マクロ[`delegate`][Module#delegate]は、メソッドを簡単に転送する方法を提供します。

あるアプリケーションのユーザーが`User`モデルにログイン情報を持っているが、名前やその他のデータは別の`Profile`モデルにあると想像してください。

```ruby
class User < ApplicationRecord
  has_one :profile
end
```

この設定では、ユーザーの名前はプロファイルを介して取得できますが、便利な場合にはその属性に直接アクセスできると便利です。

```ruby
class User < ApplicationRecord
  has_one :profile

  def name
    profile.name
  end
end
```

これが`delegate`が行ってくれることです。

```ruby
class User < ApplicationRecord
  has_one :profile

  delegate :name, to: :profile
end
```

これは短く、意図がより明確です。

対象のメソッドはターゲットでパブリックである必要があります。

`delegate`マクロは複数のメソッドを受け入れます。

```ruby
delegate :name, :age, :address, :twitter, to: :profile
```

文字列に補間される場合、`:to`オプションはメソッドが委譲されるオブジェクトに評価される式になるべきです。通常は文字列またはシンボルです。その式はレシーバーのコンテキストで評価されます。

```ruby
# Rails定数に委譲
delegate :logger, to: :Rails

# レシーバーのクラスに委譲
delegate :table_name, to: :class
```

警告：`prefix`オプションが`true`の場合、これはより一般的ではありません。以下を参照してください。

デフォルトでは、委譲が`NoMethodError`を発生させ、ターゲットが`nil`の場合、例外が伝播します。`:allow_nil`オプションを使用すると、代わりに`nil`が返されるようにすることができます。

```ruby
delegate :name, to: :profile, allow_nil: true
```

`:allow_nil`を使用すると、ユーザーにプロファイルがない場合、`user.name`の呼び出しは`nil`を返します。

オプション`prefix`は生成されるメソッドの名前に接頭辞を追加します。これは、より良い名前を取得するために便利です。

```ruby
delegate :street, to: :address, prefix: true
```

前の例では、`street`ではなく`address_street`が生成されます。
警告：この場合、生成されるメソッドの名前は対象オブジェクトと対象メソッドの名前で構成されているため、`:to`オプションはメソッド名である必要があります。

カスタムの接頭辞も設定できます：

```ruby
delegate :size, to: :attachment, prefix: :avatar
```

前の例では、マクロは`size`ではなく`avatar_size`を生成します。

オプション`:private`はメソッドのスコープを変更します：

```ruby
delegate :date_of_birth, to: :profile, private: true
```

デリゲートされたメソッドはデフォルトで公開されています。それを変更するには、`private: true`を渡します。

注意：`active_support/core_ext/module/delegation.rb`で定義されています


#### `delegate_missing_to`

`User`オブジェクトから見つからないすべてを`Profile`オブジェクトに委任したいとします。[`delegate_missing_to`][Module#delegate_missing_to]マクロを使用すると、これを簡単に実装できます。

```ruby
class User < ApplicationRecord
  has_one :profile

  delegate_missing_to :profile
end
```

対象は、オブジェクト内で呼び出し可能なものであれば何でもかまいません。インスタンス変数、メソッド、定数などです。対象の公開メソッドのみが委任されます。

注意：`active_support/core_ext/module/delegation.rb`で定義されています。


### メソッドの再定義

`define_method`を使用してメソッドを定義する必要がある場合、その名前のメソッドが既に存在するかどうかわかりません。有効になっている場合、警告が発生します。それほど大きな問題ではありませんが、きれいではありません。

メソッド[`redefine_method`][Module#redefine_method]は、既存のメソッドを必要に応じて削除することで、そのような潜在的な警告を防ぎます。

また、[`silence_redefinition_of_method`][Module#silence_redefinition_of_method]を使用して、置換メソッドを自分で定義する必要がある場合（`delegate`を使用しているためなど）、それも行うことができます。

注意：`active_support/core_ext/module/redefine_method.rb`で定義されています。


`Class`への拡張
---------------------

### クラス属性

#### `class_attribute`

メソッド[`class_attribute`][Class#class_attribute]は、階層のどのレベルでもオーバーライドできる1つ以上の継承可能なクラス属性を宣言します。

```ruby
class A
  class_attribute :x
end

class B < A; end

class C < B; end

A.x = :a
B.x # => :a
C.x # => :a

B.x = :b
A.x # => :a
C.x # => :b

C.x = :c
A.x # => :a
B.x # => :b
```

たとえば、`ActionMailer::Base`では次のように定義されています。

```ruby
class_attribute :default_params
self.default_params = {
  mime_version: "1.0",
  charset: "UTF-8",
  content_type: "text/plain",
  parts_order: [ "text/plain", "text/enriched", "text/html" ]
}.freeze
```

これらはインスタンスレベルでもアクセスおよびオーバーライドできます。

```ruby
A.x = 1

a1 = A.new
a2 = A.new
a2.x = 2

a1.x # => 1, Aから来ます
a2.x # => 2, a2でオーバーライドされました
```

オプション`：instance_writer`を`false`に設定すると、ライターインスタンスメソッドの生成を防ぐことができます。

```ruby
module ActiveRecord
  class Base
    class_attribute :table_name_prefix, instance_writer: false, default: "my"
  end
end
```

モデルは、その属性を設定するための方法として、そのオプションを有用とする場合があります。

オプション`：instance_reader`を`false`に設定すると、リーダーインスタンスメソッドの生成を防ぐことができます。

```ruby
class A
  class_attribute :x, instance_reader: false
end

A.new.x = 1
A.new.x # NoMethodError
```

便宜上、`class_attribute`は、インスタンスリーダーメソッドが返すものの否定の否定であるインスタンス述語も定義します。上記の例では、それは`x?`と呼ばれるでしょう。

`：instance_reader`が`false`の場合、インスタンス述語はリーダーメソッドと同様に`NoMethodError`を返します。

インスタンス述語を使用しない場合は、`instance_predicate: false`を渡して定義しないようにすることができます。

注意：`active_support/core_ext/class/attribute.rb`で定義されています。


#### `cattr_reader`、`cattr_writer`、および`cattr_accessor`

マクロ[`cattr_reader`][Module#cattr_reader]、[`cattr_writer`][Module#cattr_writer]、および[`cattr_accessor`][Module#cattr_accessor]は、クラスの`attr_*`と同様ですが、クラスに対して使用します。存在しない場合、クラス変数を`nil`で初期化し、それにアクセスするための対応するクラスメソッドを生成します。

```ruby
class MysqlAdapter < AbstractAdapter
  # @@emulate_booleansにアクセスするためのクラスメソッドを生成します。
  cattr_accessor :emulate_booleans
end
```

また、`cattr_*`には、デフォルト値を使用して属性を設定するためのブロックを渡すこともできます。

```ruby
class MysqlAdapter < AbstractAdapter
  # デフォルト値がtrueの@@emulate_booleansにアクセスするためのクラスメソッドを生成します。
  cattr_accessor :emulate_booleans, default: true
end
```
便利のために、インスタンスメソッドも作成されますが、それらはクラス属性へのプロキシです。したがって、インスタンスはクラス属性を変更することができますが、`class_attribute`（上記参照）のようにオーバーライドすることはできません。例えば、以下のように与えられた場合、

```ruby
module ActionView
  class Base
    cattr_accessor :field_error_proc, default: Proc.new { ... }
  end
end
```

ビューで`field_error_proc`にアクセスすることができます。

リーダーインスタンスメソッドの生成は、`:instance_reader`を`false`に設定することで防止することができます。また、ライターインスタンスメソッドの生成は、`:instance_writer`を`false`に設定することで防止することができます。両方のメソッドの生成を防止するには、`:instance_accessor`を`false`に設定します。いずれの場合も、値は`false`でなければなりません。

```ruby
module A
  class B
    # first_nameのインスタンスリーダーは生成されません。
    cattr_accessor :first_name, instance_reader: false
    # last_name=のインスタンスライターは生成されません。
    cattr_accessor :last_name, instance_writer: false
    # surnameのインスタンスリーダーまたはsurname=のライターは生成されません。
    cattr_accessor :surname, instance_accessor: false
  end
end
```

モデルは、属性の設定を防ぐために、`instance_accessor`を`false`に設定することが便利である場合があります。

注意：`active_support/core_ext/module/attribute_accessors.rb`で定義されています。


### サブクラスと子孫

#### `subclasses`

[`subclasses`][Class#subclasses]メソッドは、レシーバのサブクラスを返します。

```ruby
class C; end
C.subclasses # => []

class B < C; end
C.subclasses # => [B]

class A < B; end
C.subclasses # => [B]

class D < C; end
C.subclasses # => [B, D]
```

これらのクラスが返される順序は指定されていません。

注意：`active_support/core_ext/class/subclasses.rb`で定義されています。


#### `descendants`

[`descendants`][Class#descendants]メソッドは、レシーバよりも`<`であるすべてのクラスを返します。

```ruby
class C; end
C.descendants # => []

class B < C; end
C.descendants # => [B]

class A < B; end
C.descendants # => [B, A]

class D < C; end
C.descendants # => [B, A, D]
```

これらのクラスが返される順序は指定されていません。

注意：`active_support/core_ext/class/subclasses.rb`で定義されています。


`String`への拡張
------------------

### 出力の安全性

#### 動機

HTMLテンプレートにデータを挿入する際には、注意が必要です。たとえば、`@review.title`をそのままHTMLページに挿入することはできません。なぜなら、レビュータイトルが「Flanagan & Matz rules!」の場合、出力は正しく形成されないからです。なぜなら、アンパサンドは「&amp;amp;」としてエスケープする必要があるからです。さらに、アプリケーションによっては、ユーザーが手作りのレビュータイトルを設定して悪意のあるHTMLを注入できるため、これは大きなセキュリティホールになる可能性があります。リスクについては、[セキュリティガイド](security.html#cross-site-scripting-xss)のクロスサイトスクリプティングのセクションを参照してください。

#### 安全な文字列

Active Supportには、_(html) safe_文字列の概念があります。安全な文字列は、そのままHTMLに挿入できるとマークされています。エスケープされているかどうかに関係なく、信頼されています。

デフォルトでは、文字列は安全ではないと見なされます。

```ruby
"".html_safe? # => false
```

[`html_safe`][String#html_safe]メソッドを使用して、指定された文字列から安全な文字列を取得できます。

```ruby
s = "".html_safe
s.html_safe? # => true
```

`html_safe`はエスケープを一切行わないことを理解することが重要です。これは単なるアサーションです。

```ruby
s = "<script>...</script>".html_safe
s.html_safe? # => true
s            # => "<script>...</script>"
```

特定の文字列に`html_safe`を呼び出すことが適切であることを確認する責任はあなたにあります。

安全な文字列に対して、`concat`/`<<`でインプレースに追加したり、`+`で追加したりすると、結果は安全な文字列になります。安全でない引数はエスケープされます。

```ruby
"".html_safe + "<" # => "&lt;"
```

安全な引数は直接追加されます。

```ruby
"".html_safe + "<".html_safe # => "<"
```

これらのメソッドは通常のビューでは使用しないでください。安全でない値は自動的にエスケープされます。

```erb
<%= @review.title %> <%# 必要に応じてエスケープされます %>
```
verbatimを挿入する場合は、`html_safe`を呼び出す代わりに[`raw`][]ヘルパーを使用します。

```erb
<%= raw @cms.current_template %> <%# @cms.current_templateをそのまま挿入する %>
```

または、`<%==`を使用することもできます。

```erb
<%== @cms.current_template %> <%# @cms.current_templateをそのまま挿入する %>
```

`raw`ヘルパーは、`html_safe`を自動的に呼び出します。

```ruby
def raw(stringish)
  stringish.to_s.html_safe
end
```

注意：`active_support/core_ext/string/output_safety.rb`で定義されています。


#### 変換

一般的なルールとして、文字列を変更する可能性があるメソッドは、安全でない文字列を返します。これには、`downcase`、`gsub`、`strip`、`chomp`、`underscore`などがあります。

`gsub!`のようなインプレースの変換の場合、レシーバ自体が安全でなくなります。

情報：変換が実際に何かを変更したかどうかに関係なく、安全性のビットは常に失われます。

#### 変換と強制

安全な文字列に対して`to_s`を呼び出すと、安全な文字列が返されますが、`to_str`を使用した強制変換は安全でない文字列を返します。

#### コピー

安全な文字列に対して`dup`または`clone`を呼び出すと、安全な文字列が生成されます。

### `remove`

[`remove`][String#remove]メソッドは、パターンのすべての出現を削除します。

```ruby
"Hello World".remove(/Hello /) # => "World"
```

破壊的なバージョンの`String#remove!`もあります。

注意：`active_support/core_ext/string/filters.rb`で定義されています。


### `squish`

[`squish`][String#squish]メソッドは、先頭と末尾の空白を削除し、連続する空白を単一のスペースに置き換えます。

```ruby
" \n  foo\n\r \t bar \n".squish # => "foo bar"
```

破壊的なバージョンの`String#squish!`もあります。

ASCIIとUnicodeの両方の空白を処理することに注意してください。

注意：`active_support/core_ext/string/filters.rb`で定義されています。


### `truncate`

[`truncate`][String#truncate]メソッドは、指定された`length`の後に切り詰められたレシーバのコピーを返します。

```ruby
"Oh dear! Oh dear! I shall be late!".truncate(20)
# => "Oh dear! Oh dear!..."
```

省略記号は`:omission`オプションでカスタマイズできます。

```ruby
"Oh dear! Oh dear! I shall be late!".truncate(20, omission: '&hellip;')
# => "Oh dear! Oh &hellip;"
```

特に、切り詰めは省略文字列の長さも考慮します。

自然な区切りで文字列を切り詰めるには、`:separator`を渡します。

```ruby
"Oh dear! Oh dear! I shall be late!".truncate(18)
# => "Oh dear! Oh dea..."
"Oh dear! Oh dear! I shall be late!".truncate(18, separator: ' ')
# => "Oh dear! Oh..."
```

オプションの`:separator`は正規表現にすることもできます。

```ruby
"Oh dear! Oh dear! I shall be late!".truncate(18, separator: /\s/)
# => "Oh dear! Oh..."
```

上記の例では、最初に"dear"が切り詰められますが、その後に`：separator`がそれを防ぎます。

注意：`active_support/core_ext/string/filters.rb`で定義されています。


### `truncate_bytes`

[`truncate_bytes`][String#truncate_bytes]メソッドは、最大で`bytesize`バイトに切り詰められたレシーバのコピーを返します。

```ruby
"👍👍👍👍".truncate_bytes(15)
# => "👍👍👍…"
```

省略記号は`:omission`オプションでカスタマイズできます。

```ruby
"👍👍👍👍".truncate_bytes(15, omission: "🖖")
# => "👍👍🖖"
```

注意：`active_support/core_ext/string/filters.rb`で定義されています。


### `truncate_words`

[`truncate_words`][String#truncate_words]メソッドは、指定された単語数の後に切り詰められたレシーバのコピーを返します。

```ruby
"Oh dear! Oh dear! I shall be late!".truncate_words(4)
# => "Oh dear! Oh dear!..."
```

省略記号は`:omission`オプションでカスタマイズできます。

```ruby
"Oh dear! Oh dear! I shall be late!".truncate_words(4, omission: '&hellip;')
# => "Oh dear! Oh dear!&hellip;"
```

自然な区切りで文字列を切り詰めるには、`:separator`を渡します。

```ruby
"Oh dear! Oh dear! I shall be late!".truncate_words(3, separator: '!')
# => "Oh dear! Oh dear! I shall be late..."
```

オプションの`:separator`は正規表現にすることもできます。

```ruby
"Oh dear! Oh dear! I shall be late!".truncate_words(4, separator: /\s/)
# => "Oh dear! Oh dear!..."
```

注意：`active_support/core_ext/string/filters.rb`で定義されています。


### `inquiry`

[`inquiry`][String#inquiry]メソッドは、文字列を`StringInquirer`オブジェクトに変換し、等価性のチェックを見やすくします。

```ruby
"production".inquiry.production? # => true
"active".inquiry.inactive?       # => false
```

注意：`active_support/core_ext/string/inquiry.rb`で定義されています。


### `starts_with?`と`ends_with?`

Active Supportは、`String#start_with?`と`String#end_with?`の3人称のエイリアスを定義しています。

```ruby
"foo".starts_with?("f") # => true
"foo".ends_with?("o")   # => true
```
注意：`active_support/core_ext/string/starts_ends_with.rb`で定義されています。

### `strip_heredoc`

メソッド[`strip_heredoc`][String#strip_heredoc]は、ヒアドキュメント内のインデントを削除します。

例えば、

```ruby
if options[:usage]
  puts <<-USAGE.strip_heredoc
    This command does such and such.

    Supported options are:
      -h         This message
      ...
  USAGE
end
```

ユーザーは、使用法メッセージが左端に揃って表示されます。

技術的には、文字列全体で最もインデントされている行を探し、その先頭の空白を削除します。

注意：`active_support/core_ext/string/strip.rb`で定義されています。


### `indent`

[`indent`][String#indent]メソッドは、レシーバーの行をインデントします。

```ruby
<<EOS.indent(2)
def some_method
  some_code
end
EOS
# =>
  def some_method
    some_code
  end
```

2番目の引数である`indent_string`は、どのインデント文字列を使用するかを指定します。デフォルトは`nil`で、メソッドは最初のインデントされた行を覗いて推測し、存在しない場合はスペースにフォールバックします。

```ruby
"  foo".indent(2)        # => "    foo"
"foo\n\t\tbar".indent(2) # => "\t\tfoo\n\t\t\t\tbar"
"foo".indent(2, "\t")    # => "\t\tfoo"
```

`indent_string`は通常、スペースまたはタブのいずれかですが、任意の文字列にすることもできます。

3番目の引数である`indent_empty_lines`は、空行をインデントするかどうかを示すフラグです。デフォルトはfalseです。

```ruby
"foo\n\nbar".indent(2)            # => "  foo\n\n  bar"
"foo\n\nbar".indent(2, nil, true) # => "  foo\n  \n  bar"
```

[`indent!`][String#indent!]メソッドは、インデントをその場で行います。

注意：`active_support/core_ext/string/indent.rb`で定義されています。


### アクセス

#### `at(position)`

[`at`][String#at]メソッドは、文字列の位置`position`の文字を返します。

```ruby
"hello".at(0)  # => "h"
"hello".at(4)  # => "o"
"hello".at(-1) # => "o"
"hello".at(10) # => nil
```

注意：`active_support/core_ext/string/access.rb`で定義されています。


#### `from(position)`

[`from`][String#from]メソッドは、位置`position`から始まる文字列の部分文字列を返します。

```ruby
"hello".from(0)  # => "hello"
"hello".from(2)  # => "llo"
"hello".from(-2) # => "lo"
"hello".from(10) # => nil
```

注意：`active_support/core_ext/string/access.rb`で定義されています。


#### `to(position)`

[`to`][String#to]メソッドは、位置`position`までの文字列の部分文字列を返します。

```ruby
"hello".to(0)  # => "h"
"hello".to(2)  # => "hel"
"hello".to(-2) # => "hell"
"hello".to(10) # => "hello"
```

注意：`active_support/core_ext/string/access.rb`で定義されています。


#### `first(limit = 1)`

[`first`][String#first]メソッドは、文字列の最初の`limit`文字を含む部分文字列を返します。

`str.first(n)`の呼び出しは、`n` > 0の場合は`str.to(n-1)`と同等であり、`n` == 0の場合は空の文字列を返します。

注意：`active_support/core_ext/string/access.rb`で定義されています。


#### `last(limit = 1)`

[`last`][String#last]メソッドは、文字列の最後の`limit`文字を含む部分文字列を返します。

`str.last(n)`の呼び出しは、`n` > 0の場合は`str.from(-n)`と同等であり、`n` == 0の場合は空の文字列を返します。

注意：`active_support/core_ext/string/access.rb`で定義されています。


### インフレクション

#### `pluralize`

メソッド[`pluralize`][String#pluralize]は、レシーバーの複数形を返します。

```ruby
"table".pluralize     # => "tables"
"ruby".pluralize      # => "rubies"
"equipment".pluralize # => "equipment"
```

前の例のように、Active Supportはいくつかの不規則な複数形と数えられない名詞を知っています。組み込みのルールは`config/initializers/inflections.rb`で拡張することができます。このファイルはデフォルトで`rails new`コマンドによって生成され、コメントに指示があります。

`pluralize`はオプションの`count`パラメーターも受け取ることができます。`count == 1`の場合、単数形が返されます。`count`の値が1以外の場合、複数形が返されます。

```ruby
"dude".pluralize(0) # => "dudes"
"dude".pluralize(1) # => "dude"
"dude".pluralize(2) # => "dudes"
```

Active Recordは、このメソッドを使用してモデルに対応するデフォルトのテーブル名を計算します。

```ruby
# active_record/model_schema.rb
def undecorated_table_name(model_name)
  table_name = model_name.to_s.demodulize.underscore
  pluralize_table_names ? table_name.pluralize : table_name
end
```

注意：`active_support/core_ext/string/inflections.rb`で定義されています。


#### `singularize`

[`singularize`][String#singularize]メソッドは、`pluralize`の逆です。

```ruby
"tables".singularize    # => "table"
"rubies".singularize    # => "ruby"
"equipment".singularize # => "equipment"
```

関連付けは、このメソッドを使用して対応するデフォルトの関連クラスの名前を計算します。

```ruby
# active_record/reflection.rb
def derive_class_name
  class_name = name.to_s.camelize
  class_name = class_name.singularize if collection?
  class_name
end
```
注意：`active_support/core_ext/string/inflections.rb`で定義されています。

#### `camelize`

メソッド[`camelize`][String#camelize]は、キャメルケースで受け取った文字列を返します。

```ruby
"product".camelize    # => "Product"
"admin_user".camelize # => "AdminUser"
```

このメソッドは、パスをRubyのクラスやモジュール名に変換するメソッドと考えることができます。スラッシュは名前空間を区切ります。

```ruby
"backoffice/session".camelize # => "Backoffice::Session"
```

たとえば、Action Packは特定のセッションストアを提供するクラスをロードするためにこのメソッドを使用します。

```ruby
# action_controller/metal/session_management.rb
def session_store=(store)
  @@session_store = store.is_a?(Symbol) ?
    ActionDispatch::Session.const_get(store.to_s.camelize) :
    store
end
```

`camelize`はオプションの引数を受け入れます。`:upper`（デフォルト）または`:lower`が指定できます。後者の場合、最初の文字は小文字になります。

```ruby
"visual_effect".camelize(:lower) # => "visualEffect"
```

これは、その規則に従う言語でメソッド名を計算するのに便利です。たとえばJavaScriptです。

INFO: `camelize`は`underscore`の逆と考えることができますが、その逆が成り立たない場合もあります。例えば、`"SSLError".underscore.camelize`は`"SslError"`を返します。このような場合をサポートするために、Active Supportでは`config/initializers/inflections.rb`で略語を指定することができます。

```ruby
ActiveSupport::Inflector.inflections do |inflect|
  inflect.acronym 'SSL'
end

"SSLError".underscore.camelize # => "SSLError"
```

`camelize`は[`camelcase`][String#camelcase]としてエイリアスされています。

注意：`active_support/core_ext/string/inflections.rb`で定義されています。

#### `underscore`

メソッド[`underscore`][String#underscore]は、キャメルケースからパスに変換します。

```ruby
"Product".underscore   # => "product"
"AdminUser".underscore # => "admin_user"
```

また、"::"を"/"に変換します。

```ruby
"Backoffice::Session".underscore # => "backoffice/session"
```

小文字で始まる文字列も理解します。

```ruby
"visualEffect".underscore # => "visual_effect"
```

`underscore`は引数を受け取りません。

Railsは、コントローラクラスの小文字化された名前を取得するために`underscore`を使用します。

```ruby
# actionpack/lib/abstract_controller/base.rb
def controller_path
  @controller_path ||= name.delete_suffix("Controller").underscore
end
```

たとえば、`params[:controller]`で取得できる値です。

INFO: `underscore`は`camelize`の逆と考えることができますが、その逆が成り立たない場合もあります。例えば、`"SSLError".underscore.camelize`は`"SslError"`を返します。

注意：`active_support/core_ext/string/inflections.rb`で定義されています。

#### `titleize`

メソッド[`titleize`][String#titleize]は、受け取った文字列の単語の先頭を大文字にします。

```ruby
"alice in wonderland".titleize # => "Alice In Wonderland"
"fermat's enigma".titleize     # => "Fermat's Enigma"
```

`titleize`は[`titlecase`][String#titlecase]としてエイリアスされています。

注意：`active_support/core_ext/string/inflections.rb`で定義されています。

#### `dasherize`

メソッド[`dasherize`][String#dasherize]は、受け取った文字列のアンダースコアをダッシュに置き換えます。

```ruby
"name".dasherize         # => "name"
"contact_data".dasherize # => "contact-data"
```

モデルのXMLシリアライザは、このメソッドを使用してノード名をダッシュ化します。

```ruby
# active_model/serializers/xml.rb
def reformat_name(name)
  name = name.camelize if camelize?
  dasherize? ? name.dasherize : name
end
```

注意：`active_support/core_ext/string/inflections.rb`で定義されています。

#### `demodulize`

修飾された定数名を持つ文字列が与えられた場合、[`demodulize`][String#demodulize]はその定数名の一番右側の部分を返します。

```ruby
"Product".demodulize                        # => "Product"
"Backoffice::UsersController".demodulize    # => "UsersController"
"Admin::Hotel::ReservationUtils".demodulize # => "ReservationUtils"
"::Inflections".demodulize                  # => "Inflections"
"".demodulize                               # => ""
```

Active Recordは、例えばカウンターキャッシュカラムの名前を計算するためにこのメソッドを使用します。

```ruby
# active_record/reflection.rb
def counter_cache_column
  if options[:counter_cache] == true
    "#{active_record.name.demodulize.underscore.pluralize}_count"
  elsif options[:counter_cache]
    options[:counter_cache]
  end
end
```

注意：`active_support/core_ext/string/inflections.rb`で定義されています。

#### `deconstantize`

修飾された定数参照式を持つ文字列が与えられた場合、[`deconstantize`][String#deconstantize]は一番右のセグメントを削除し、通常は定数のコンテナの名前を残します。

```ruby
"Product".deconstantize                        # => ""
"Backoffice::UsersController".deconstantize    # => "Backoffice"
"Admin::Hotel::ReservationUtils".deconstantize # => "Admin::Hotel"
```

注意：`active_support/core_ext/string/inflections.rb`で定義されています。

#### `parameterize`

メソッド[`parameterize`][String#parameterize]は、受け取った文字列をプリティなURLで使用できる形式に正規化します。

```ruby
"John Smith".parameterize # => "john-smith"
"Kurt Gödel".parameterize # => "kurt-godel"
```

文字列の大文字と小文字を保持するには、`preserve_case`引数をtrueに設定します。デフォルトでは、`preserve_case`はfalseに設定されています。

```ruby
"John Smith".parameterize(preserve_case: true) # => "John-Smith"
"Kurt Gödel".parameterize(preserve_case: true) # => "Kurt-Godel"
```

カスタムのセパレータを使用するには、`separator`引数をオーバーライドします。
```ruby
"Employee Salary".downcase_first # => "employee Salary"
"".downcase_first                # => ""
```

NOTE: Defined in `active_support/core_ext/string/inflections.rb`.
```ruby
123.to_fs(:human)                  # => "123"
1234.to_fs(:human)                 # => "1.23 Thousand"
12345.to_fs(:human)                # => "12.3 Thousand"
1234567.to_fs(:human)              # => "1.23 Million"
1234567890.to_fs(:human)           # => "1.23 Billion"
1234567890123.to_fs(:human)        # => "1.23 Trillion"
1234567890123456.to_fs(:human)     # => "1.23 Quadrillion"
1234567890123456789.to_fs(:human)  # => "1.23 Quintillion"
```

NOTE: Defined in `active_support/core_ext/numeric/conversions.rb`.
```ruby
123.to_fs(:human)               # => "123"
1234.to_fs(:human)              # => "1.23 Thousand"
12345.to_fs(:human)             # => "12.3 Thousand"
1234567.to_fs(:human)           # => "1.23 Million"
1234567890.to_fs(:human)        # => "1.23 Billion"
1234567890123.to_fs(:human)     # => "1.23 Trillion"
1234567890123456.to_fs(:human)  # => "1.23 Quadrillion"
```

注意：`active_support/core_ext/numeric/conversions.rb`で定義されています。

`Integer`への拡張
-----------------------

### `multiple_of?`

[`multiple_of?`][Integer#multiple_of?]メソッドは、整数が引数の倍数であるかどうかをテストします。

```ruby
2.multiple_of?(1) # => true
1.multiple_of?(2) # => false
```

注意：`active_support/core_ext/integer/multiple.rb`で定義されています。


### `ordinal`

[`ordinal`][Integer#ordinal]メソッドは、受信した整数に対応する序数接尾辞文字列を返します。

```ruby
1.ordinal    # => "st"
2.ordinal    # => "nd"
53.ordinal   # => "rd"
2009.ordinal # => "th"
-21.ordinal  # => "st"
-134.ordinal # => "th"
```

注意：`active_support/core_ext/integer/inflections.rb`で定義されています。


### `ordinalize`

[`ordinalize`][Integer#ordinalize]メソッドは、受信した整数に対応する序数文字列を返します。比較のために、`ordinal`メソッドは**接尾辞文字列のみ**を返します。

```ruby
1.ordinalize    # => "1st"
2.ordinalize    # => "2nd"
53.ordinalize   # => "53rd"
2009.ordinalize # => "2009th"
-21.ordinalize  # => "-21st"
-134.ordinalize # => "-134th"
```

注意：`active_support/core_ext/integer/inflections.rb`で定義されています。


### Time

以下のメソッド：

* [`months`][Integer#months]
* [`years`][Integer#years]

は、`4.months + 5.years`のような時間の宣言と計算を可能にします。これらの戻り値は、Timeオブジェクトに加算または減算することもできます。

これらのメソッドは、正確な日付の計算のために[`from_now`][Duration#from_now]、[`ago`][Duration#ago]などと組み合わせることができます。例えば：

```ruby
# Time.current.advance(months: 1)と同等
1.month.from_now

# Time.current.advance(years: 2)と同等
2.years.from_now

# Time.current.advance(months: 4, years: 5)と同等
(4.months + 5.years).from_now
```

警告：他の期間については、`Numeric`への時間の拡張を参照してください。

注意：`active_support/core_ext/integer/time.rb`で定義されています。


`BigDecimal`への拡張
--------------------------

### `to_s`

`to_s`メソッドは、デフォルトの指定子として「F」を提供します。これにより、`to_s`の単純な呼び出しは、工学表記ではなく浮動小数点表現になります。

```ruby
BigDecimal(5.00, 6).to_s       # => "5.0"
```

工学表記もサポートされています。

```ruby
BigDecimal(5.00, 6).to_s("e")  # => "0.5E1"
```

`Enumerable`への拡張
--------------------------

### `sum`

[`sum`][Enumerable#sum]メソッドは、列挙可能な要素を合計します。

```ruby
[1, 2, 3].sum # => 6
(1..100).sum  # => 5050
```

加算は、要素が`+`に応答することを前提としています。

```ruby
[[1, 2], [2, 3], [3, 4]].sum    # => [1, 2, 2, 3, 3, 4]
%w(foo bar baz).sum             # => "foobarbaz"
{ a: 1, b: 2, c: 3 }.sum          # => [:a, 1, :b, 2, :c, 3]
```

空のコレクションの合計はデフォルトでゼロですが、これはカスタマイズ可能です。

```ruby
[].sum    # => 0
[].sum(1) # => 1
```

ブロックが与えられた場合、`sum`はコレクションの要素をイテレータとして使用し、返された値を合計します。

```ruby
(1..5).sum { |n| n * 2 } # => 30
[2, 4, 6, 8, 10].sum    # => 30
```

空の受信者の合計もこの形式でカスタマイズできます。

```ruby
[].sum(1) { |n| n**3 } # => 1
```

注意：`active_support/core_ext/enumerable.rb`で定義されています。


### `index_by`

[`index_by`][Enumerable#index_by]メソッドは、列挙可能な要素をキーとするハッシュを生成します。

コレクションを反復処理し、各要素をブロックに渡します。要素は、ブロックが返す値によってキー付けされます。

```ruby
invoices.index_by(&:number)
# => {'2009-032' => <Invoice ...>, '2009-008' => <Invoice ...>, ...}
```

警告：通常、キーは一意である必要があります。ブロックが異なる要素に対して同じ値を返す場合、そのキーに対してはコレクションが構築されません。最後のアイテムが優先されます。

注意：`active_support/core_ext/enumerable.rb`で定義されています。


### `index_with`

[`index_with`][Enumerable#index_with]メソッドは、列挙可能な要素をキーとするハッシュを生成します。値は、渡されたデフォルト値またはブロックで返されます。

```ruby
post = Post.new(title: "hey there", body: "what's up?")

%i( title body ).index_with { |attr_name| post.public_send(attr_name) }
# => { title: "hey there", body: "what's up?" }

WEEKDAYS.index_with(Interval.all_day)
# => { monday: [ 0, 1440 ], … }
```

注意：`active_support/core_ext/enumerable.rb`で定義されています。

### `many?`

メソッド[`many?`][Enumerable#many?]は、`collection.size > 1`の省略形です。

```erb
<% if pages.many? %>
  <%= pagination_links %>
<% end %>
```

オプションのブロックが指定されている場合、`many?`はtrueを返す要素のみを考慮に入れます。

```ruby
@see_more = videos.many? { |video| video.category == params[:category] }
```

注意：`active_support/core_ext/enumerable.rb`で定義されています。

### `exclude?`

述語[`exclude?`][Enumerable#exclude?]は、指定されたオブジェクトがコレクションに**含まれていない**かどうかをテストします。これは組み込みの`include?`の否定です。

```ruby
to_visit << node if visited.exclude?(node)
```

注意：`active_support/core_ext/enumerable.rb`で定義されています。

### `including`

メソッド[`including`][Enumerable#including]は、渡された要素を含む新しい列挙可能オブジェクトを返します。

```ruby
[ 1, 2, 3 ].including(4, 5)                    # => [ 1, 2, 3, 4, 5 ]
["David", "Rafael"].including %w[ Aaron Todd ] # => ["David", "Rafael", "Aaron", "Todd"]
```

注意：`active_support/core_ext/enumerable.rb`で定義されています。

### `excluding`

メソッド[`excluding`][Enumerable#excluding]は、指定された要素を除いた列挙可能オブジェクトのコピーを返します。

```ruby
["David", "Rafael", "Aaron", "Todd"].excluding("Aaron", "Todd") # => ["David", "Rafael"]
```

`excluding`は[`without`][Enumerable#without]のエイリアスです。

注意：`active_support/core_ext/enumerable.rb`で定義されています。

### `pluck`

メソッド[`pluck`][Enumerable#pluck]は、各要素から指定されたキーを抽出します。

```ruby
[{ name: "David" }, { name: "Rafael" }, { name: "Aaron" }].pluck(:name) # => ["David", "Rafael", "Aaron"]
[{ id: 1, name: "David" }, { id: 2, name: "Rafael" }].pluck(:id, :name) # => [[1, "David"], [2, "Rafael"]]
```

注意：`active_support/core_ext/enumerable.rb`で定義されています。

### `pick`

メソッド[`pick`][Enumerable#pick]は、最初の要素から指定されたキーを抽出します。

```ruby
[{ name: "David" }, { name: "Rafael" }, { name: "Aaron" }].pick(:name) # => "David"
[{ id: 1, name: "David" }, { id: 2, name: "Rafael" }].pick(:id, :name) # => [1, "David"]
```

注意：`active_support/core_ext/enumerable.rb`で定義されています。

`Array`への拡張
---------------------

### アクセス

Active Supportは、配列のAPIを拡張して、特定のアクセス方法を容易にします。例えば、[`to`][Array#to]は、指定されたインデックスまでの要素のサブ配列を返します。

```ruby
%w(a b c d).to(2) # => ["a", "b", "c"]
[].to(7)          # => []
```

同様に、[`from`][Array#from]は、指定されたインデックスから末尾までの要素を返します。インデックスが配列の長さよりも大きい場合、空の配列が返されます。

```ruby
%w(a b c d).from(2)  # => ["c", "d"]
%w(a b c d).from(10) # => []
[].from(0)           # => []
```

メソッド[`including`][Array#including]は、渡された要素を含む新しい配列を返します。

```ruby
[ 1, 2, 3 ].including(4, 5)          # => [ 1, 2, 3, 4, 5 ]
[ [ 0, 1 ] ].including([ [ 1, 0 ] ]) # => [ [ 0, 1 ], [ 1, 0 ] ]
```

メソッド[`excluding`][Array#excluding]は、指定された要素を除いた配列のコピーを返します。これは、パフォーマンスのために`Array#reject`の代わりに`Array#-`を使用する`Enumerable#excluding`の最適化です。

```ruby
["David", "Rafael", "Aaron", "Todd"].excluding("Aaron", "Todd") # => ["David", "Rafael"]
[ [ 0, 1 ], [ 1, 0 ] ].excluding([ [ 1, 0 ] ])                  # => [ [ 0, 1 ] ]
```

メソッド[`second`][Array#second]、[`third`][Array#third]、[`fourth`][Array#fourth]、[`fifth`][Array#fifth]は、対応する要素を返します。[`second_to_last`][Array#second_to_last]と[`third_to_last`][Array#third_to_last]（`first`と`last`は組み込み）も同様です。社会的な知恵と建設的な構築力のおかげで、[`forty_two`][Array#forty_two]も利用できます。

```ruby
%w(a b c d).third # => "c"
%w(a b c d).fifth # => nil
```

注意：`active_support/core_ext/array/access.rb`で定義されています。

### 抽出

メソッド[`extract!`][Array#extract!]は、ブロックがtrueを返す要素を削除して返します。ブロックが指定されていない場合、代わりにEnumeratorが返されます。

```ruby
numbers = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
odd_numbers = numbers.extract! { |number| number.odd? } # => [1, 3, 5, 7, 9]
numbers # => [0, 2, 4, 6, 8]
```
注意：`active_support/core_ext/array/extract.rb`で定義されています。

### オプションの抽出

メソッド呼び出しの最後の引数がハッシュである場合、`&block`引数を除いて括弧を省略することができます。

```ruby
User.exists?(email: params[:email])
```

このような構文糖衣は、Railsでは位置引数が多すぎる場合に位置引数を避けるためによく使用され、代わりに名前付きパラメータをエミュレートするインターフェースを提供します。特に、オプションのために末尾のハッシュを使用することは非常にイディオマチックです。

しかし、メソッドが可変長の引数を受け取り、その宣言で`*`を使用している場合、このようなオプションのハッシュは引数の配列の要素として扱われ、役割を失います。

そのような場合、[`extract_options!`][Array#extract_options!]を使用してオプションのハッシュを特別な扱いにすることができます。このメソッドは配列の最後の要素の型をチェックします。ハッシュであればそれを取り出して返し、そうでなければ空のハッシュを返します。

例えば、`caches_action`コントローラーマクロの定義を見てみましょう。

```ruby
def caches_action(*actions)
  return unless cache_configured?
  options = actions.extract_options!
  # ...
end
```

このメソッドは任意の数のアクション名とオプションのハッシュを最後の引数として受け取ります。`extract_options!`の呼び出しにより、オプションのハッシュを取得し、`actions`から削除することができます。

注意：`active_support/core_ext/array/extract_options.rb`で定義されています。

### 変換

#### `to_sentence`

[`to_sentence`][Array#to_sentence]メソッドは、配列を要素を列挙する文を含む文字列に変換します。

```ruby
%w().to_sentence                # => ""
%w(Earth).to_sentence           # => "Earth"
%w(Earth Wind).to_sentence      # => "Earth and Wind"
%w(Earth Wind Fire).to_sentence # => "Earth, Wind, and Fire"
```

このメソッドは3つのオプションを受け入れます。

* `:two_words_connector`: 長さ2の配列に使用されるものです。デフォルトは " and " です。
* `:words_connector`: 3つ以上の要素を持つ配列の要素を結合するために使用されるものです。ただし、最後の2つを除きます。デフォルトは ", " です。
* `:last_word_connector`: 3つ以上の要素を持つ配列の最後の要素を結合するために使用されるものです。デフォルトは ", and " です。

これらのオプションのデフォルト値はローカライズできます。キーは次のとおりです。

| オプション                 | I18nキー                            |
| ---------------------- | ----------------------------------- |
| `:two_words_connector` | `support.array.two_words_connector` |
| `:words_connector`     | `support.array.words_connector`     |
| `:last_word_connector` | `support.array.last_word_connector` |

注意：`active_support/core_ext/array/conversions.rb`で定義されています。

#### `to_fs`

[`to_fs`][Array#to_fs]メソッドは、デフォルトでは`to_s`と同様の動作をします。

ただし、配列に`id`に応答する要素が含まれている場合、引数としてシンボル`:db`を渡すことができます。これは通常、Active Recordオブジェクトのコレクションで使用されます。返される文字列は次のようになります。

```ruby
[].to_fs(:db)            # => "null"
[user].to_fs(:db)        # => "8456"
invoice.lines.to_fs(:db) # => "23,567,556,12"
```

上記の例の整数は、それぞれの`id`への呼び出しから取得されるものとします。

注意：`active_support/core_ext/array/conversions.rb`で定義されています。

#### `to_xml`

[`to_xml`][Array#to_xml]メソッドは、受け取った配列のXML表現を含む文字列を返します。

```ruby
Contributor.limit(2).order(:rank).to_xml
# =>
# <?xml version="1.0" encoding="UTF-8"?>
# <contributors type="array">
#   <contributor>
#     <id type="integer">4356</id>
#     <name>Jeremy Kemper</name>
#     <rank type="integer">1</rank>
#     <url-id>jeremy-kemper</url-id>
#   </contributor>
#   <contributor>
#     <id type="integer">4404</id>
#     <name>David Heinemeier Hansson</name>
#     <rank type="integer">2</rank>
#     <url-id>david-heinemeier-hansson</url-id>
#   </contributor>
# </contributors>
```

これを行うために、それぞれのアイテムに`to_xml`を送信し、結果をルートノードの下に収集します。すべてのアイテムは`to_xml`に応答する必要があります。そうでない場合は例外が発生します。

デフォルトでは、ルート要素の名前は最初のアイテムのクラスのアンダースコアとダッシュを含む複数形になります。ただし、他の要素がそのタイプに属していること（`is_a?`でチェックされる）とハッシュでないことが条件です。上記の例では、それは "contributors" です。

最初の要素のタイプと異なる要素がある場合、ルートノードは "objects" になります。
```ruby
[Contributor.first, Commit.first].to_xml
# =>
# <?xml version="1.0" encoding="UTF-8"?>
# <objects type="array">
#   <object>
#     <id type="integer">4583</id>
#     <name>Aaron Batalion</name>
#     <rank type="integer">53</rank>
#     <url-id>aaron-batalion</url-id>
#   </object>
#   <object>
#     <author>Joshua Peek</author>
#     <authored-timestamp type="datetime">2009-09-02T16:44:36Z</authored-timestamp>
#     <branch>origin/master</branch>
#     <committed-timestamp type="datetime">2009-09-02T16:44:36Z</committed-timestamp>
#     <committer>Joshua Peek</committer>
#     <git-show nil="true"></git-show>
#     <id type="integer">190316</id>
#     <imported-from-svn type="boolean">false</imported-from-svn>
#     <message>Kill AMo observing wrap_with_notifications since ARes was only using it</message>
#     <sha1>723a47bfb3708f968821bc969a9a3fc873a3ed58</sha1>
#   </object>
# </objects>
```

もしレシーバがハッシュの配列である場合、ルート要素はデフォルトで "objects" になります。

```ruby
[{ a: 1, b: 2 }, { c: 3 }].to_xml
# =>
# <?xml version="1.0" encoding="UTF-8"?>
# <objects type="array">
#   <object>
#     <b type="integer">2</b>
#     <a type="integer">1</a>
#   </object>
#   <object>
#     <c type="integer">3</c>
#   </object>
# </objects>
```

注意: コレクションが空の場合、ルート要素はデフォルトで "nil-classes" になります。これは注意が必要です。例えば、上記の貢献者リストのルート要素は "contributors" ではなく、コレクションが空の場合は "nil-classes" になります。一貫したルート要素を確保するために、`:root` オプションを使用することができます。

子ノードの名前はデフォルトでルートノードの名前の単数形になります。上記の例では "contributor" と "object" を見ました。`:children` オプションを使用してこれらのノード名を設定することができます。

デフォルトの XML ビルダーは `Builder::XmlMarkup` の新しいインスタンスです。`:builder` オプションを使用して独自のビルダーを設定することができます。また、`:dasherize` などのオプションも受け入れます。これらのオプションはビルダーに転送されます。

```ruby
Contributor.limit(2).order(:rank).to_xml(skip_types: true)
# =>
# <?xml version="1.0" encoding="UTF-8"?>
# <contributors>
#   <contributor>
#     <id>4356</id>
#     <name>Jeremy Kemper</name>
#     <rank>1</rank>
#     <url-id>jeremy-kemper</url-id>
#   </contributor>
#   <contributor>
#     <id>4404</id>
#     <name>David Heinemeier Hansson</name>
#     <rank>2</rank>
#     <url-id>david-heinemeier-hansson</url-id>
#   </contributor>
# </contributors>
```

注意: `active_support/core_ext/array/conversions.rb` で定義されています。


### ラッピング

[`Array.wrap`][Array.wrap] メソッドは、引数が既に配列（または配列のようなオブジェクト）でない場合、引数を配列でラップします。

具体的には:

* 引数が `nil` の場合、空の配列が返されます。
* それ以外の場合、引数が `to_ary` を呼び出すことができる場合、`to_ary` が呼び出され、`to_ary` の値が `nil` でない場合はそれが返されます。
* それ以外の場合、引数を単一の要素として持つ配列が返されます。

```ruby
Array.wrap(nil)       # => []
Array.wrap([1, 2, 3]) # => [1, 2, 3]
Array.wrap(0)         # => [0]
```

このメソッドは `Kernel#Array` の目的と似ていますが、いくつかの違いがあります:

* 引数が `to_ary` を呼び出すことができる場合、メソッドが呼び出されます。`Kernel#Array` は返された値が `nil` の場合に `to_a` を試みますが、`Array.wrap` は引数を単一の要素として持つ配列をすぐに返します。
* `to_ary` から返される値が `nil` でも `Array` オブジェクトでもない場合、`Kernel#Array` は例外を発生させますが、`Array.wrap` は例外を発生させずに値を返します。
* 引数が `to_ary` に応答しない場合、`to_a` を呼び出しません。その場合、引数を単一の要素として持つ配列が返されます。

特に、いくつかの列挙可能なオブジェクトについて比較する価値がある最後のポイントです:

```ruby
Array.wrap(foo: :bar) # => [{:foo=>:bar}]
Array(foo: :bar)      # => [[:foo, :bar]]
```

また、スプラット演算子を使用した関連するイディオムもあります:

```ruby
[*object]
```

注意: `active_support/core_ext/array/wrap.rb` で定義されています。


### 複製

[`Array#deep_dup`][Array#deep_dup] メソッドは、Active Support の `Object#deep_dup` メソッドを使用して、自身と内部のすべてのオブジェクトを再帰的に複製します。これは `Array#map` のように動作し、各オブジェクトに `deep_dup` メソッドを送信します。

```ruby
array = [1, [2, 3]]
dup = array.deep_dup
dup[1][2] = 4
array[1][2] == nil   # => true
```

注意: `active_support/core_ext/object/deep_dup.rb` で定義されています。


### グループ化

#### `in_groups_of(number, fill_with = nil)`

[`in_groups_of`][Array#in_groups_of] メソッドは、配列を指定したサイズの連続したグループに分割します。グループを含む配列が返されます。

```ruby
[1, 2, 3].in_groups_of(2) # => [[1, 2], [3, nil]]
```

または、ブロックが渡された場合は、順番にそれらを返します。

```html+erb
<% sample.in_groups_of(3) do |a, b, c| %>
  <tr>
    <td><%= a %></td>
    <td><%= b %></td>
    <td><%= c %></td>
  </tr>
<% end %>
```

最初の例では、`in_groups_of`が要求されたサイズになるように、最後のグループを必要なだけ`nil`要素で埋めます。2番目のオプション引数を使用して、このパディング値を変更することができます。

```ruby
[1, 2, 3].in_groups_of(2, 0) # => [[1, 2], [3, 0]]
```

また、最後のグループを埋めないようにするには、`false`を渡すこともできます。

```ruby
[1, 2, 3].in_groups_of(2, false) # => [[1, 2], [3]]
```

その結果、`false`はパディング値として使用できません。

注意：`active_support/core_ext/array/grouping.rb`で定義されています。


#### `in_groups(number, fill_with = nil)`

メソッド[`in_groups`][Array#in_groups]は、配列を指定された数のグループに分割します。メソッドはグループを含む配列を返します。

```ruby
%w(1 2 3 4 5 6 7).in_groups(3)
# => [["1", "2", "3"], ["4", "5", nil], ["6", "7", nil]]
```

または、ブロックが渡された場合は、順番にそれらを返します。

```ruby
%w(1 2 3 4 5 6 7).in_groups(3) { |group| p group }
["1", "2", "3"]
["4", "5", nil]
["6", "7", nil]
```

上記の例では、`in_groups`が必要に応じていくつかのグループを末尾に`nil`要素で埋めます。グループには最大で1つの追加要素が含まれることがありますが、それらを含むのは常に最後のグループです。

2番目のオプション引数を使用して、このパディング値を変更することができます。

```ruby
%w(1 2 3 4 5 6 7).in_groups(3, "0")
# => [["1", "2", "3"], ["4", "5", "0"], ["6", "7", "0"]]
```

また、小さいグループを埋めないようにするには、`false`を渡すこともできます。

```ruby
%w(1 2 3 4 5 6 7).in_groups(3, false)
# => [["1", "2", "3"], ["4", "5"], ["6", "7"]]
```

その結果、`false`はパディング値として使用できません。

注意：`active_support/core_ext/array/grouping.rb`で定義されています。


#### `split(value = nil)`

メソッド[`split`][Array#split]は、配列を区切り文字で分割し、結果のチャンクを返します。

ブロックが渡された場合、区切り文字はブロックがtrueを返す配列の要素です。

```ruby
(-5..5).to_a.split { |i| i.multiple_of?(4) }
# => [[-5], [-3, -2, -1], [1, 2, 3], [5]]
```

そうでない場合、デフォルトで`nil`となる引数として受け取った値が区切り文字です。

```ruby
[0, 1, -5, 1, 1, "foo", "bar"].split(1)
# => [[0], [-5], [], ["foo", "bar"]]
```

TIP: 前の例では、連続する区切り文字は空の配列になります。

注意：`active_support/core_ext/array/grouping.rb`で定義されています。


`Hash`への拡張
--------------------

### 変換

#### `to_xml`

メソッド[`to_xml`][Hash#to_xml]は、受け取ったハッシュのXML表現を含む文字列を返します。

```ruby
{ foo: 1, bar: 2 }.to_xml
# =>
# <?xml version="1.0" encoding="UTF-8"?>
# <hash>
#   <foo type="integer">1</foo>
#   <bar type="integer">2</bar>
# </hash>
```

これを行うために、メソッドはペアをループし、値に応じてノードを構築します。ペア`key`、`value`が与えられた場合：

* `value`がハッシュの場合、`key`を`:root`として再帰呼び出しを行います。

* `value`が配列の場合、`key`を`:root`、`key`の単数形を`:children`として再帰呼び出しを行います。

* `value`が呼び出し可能なオブジェクトの場合、1つまたは2つの引数を受け取る必要があります。引数の数に応じて、呼び出し可能オブジェクトは`options`ハッシュを最初の引数として、`key`を`:root`、単数形の`key`を2番目の引数として呼び出されます。その戻り値は新しいノードになります。

* `value`が`to_xml`に応答する場合、メソッドは`key`を`:root`として呼び出されます。

* それ以外の場合、`key`をタグとするノードが作成され、`value`の文字列表現がテキストノードとして追加されます。`value`が`nil`の場合、属性"nil"が"true"に設定されます。オプション`：skip_types`が存在し、trueである場合を除き、次のマッピングに従って属性"type"も追加されます。
```ruby
XML_TYPE_NAMES = {
  "Symbol"     => "symbol",
  "Integer"    => "integer",
  "BigDecimal" => "decimal",
  "Float"      => "float",
  "TrueClass"  => "boolean",
  "FalseClass" => "boolean",
  "Date"       => "date",
  "DateTime"   => "datetime",
  "Time"       => "datetime"
}
```

デフォルトではルートノードは "hash" ですが、 `:root` オプションを使用して設定することができます。

デフォルトの XML ビルダーは `Builder::XmlMarkup` の新しいインスタンスです。 `:builder` オプションを使用して独自のビルダーを設定することもできます。また、 `:dasherize` などのオプションも受け入れますが、これらはビルダーに転送されます。

注意：`active_support/core_ext/hash/conversions.rb` で定義されています。


### マージ

Ruby には、2 つのハッシュをマージするための組み込みメソッド `Hash#merge` があります。

```ruby
{ a: 1, b: 1 }.merge(a: 0, c: 2)
# => {:a=>0, :b=>1, :c=>2}
```

Active Support では、便利なハッシュのマージ方法をいくつか定義しています。

#### `reverse_merge` と `reverse_merge!`

`merge` では、引数のハッシュのキーが衝突した場合、引数のハッシュのキーが優先されます。このイディオムを使用して、デフォルト値を持つオプションハッシュをコンパクトにサポートすることができます。

```ruby
options = { length: 30, omission: "..." }.merge(options)
```

Active Support では、この代替記法として [`reverse_merge`][Hash#reverse_merge] を定義しています。

```ruby
options = options.reverse_merge(length: 30, omission: "...")
```

また、マージをインプレースで実行するバンバージョン [`reverse_merge!`][Hash#reverse_merge!] も定義されています。

```ruby
options.reverse_merge!(length: 30, omission: "...")
```

注意：`reverse_merge!` は呼び出し元のハッシュを変更する可能性があるため、良いアイデアであるかどうかは考慮してください。

注意：`active_support/core_ext/hash/reverse_merge.rb` で定義されています。


#### `reverse_update`

[`reverse_update`][Hash#reverse_update] メソッドは、上記で説明した `reverse_merge!` のエイリアスです。

注意：`reverse_update` にはバンがありません。

注意：`active_support/core_ext/hash/reverse_merge.rb` で定義されています。


#### `deep_merge` と `deep_merge!`

前の例でわかるように、両方のハッシュでキーが見つかった場合、引数のハッシュの値が優先されます。

Active Support では [`Hash#deep_merge`][Hash#deep_merge] を定義しています。ディープマージでは、両方のハッシュでキーが見つかり、その値が再びハッシュである場合、そのマージが結果のハッシュの値になります。

```ruby
{ a: { b: 1 } }.deep_merge(a: { c: 2 })
# => {:a=>{:b=>1, :c=>2}}
```

メソッド [`deep_merge!`][Hash#deep_merge!] はインプレースでディープマージを実行します。

注意：`active_support/core_ext/hash/deep_merge.rb` で定義されています。


### ディープコピー

[`Hash#deep_dup`][Hash#deep_dup] メソッドは、自身とそのキーと値を再帰的に複製します。これは、Active Support の `Object#deep_dup` メソッドを使用して、`Enumerator#each_with_object` と同様に、各ペアに `deep_dup` メソッドを送信するように動作します。

```ruby
hash = { a: 1, b: { c: 2, d: [3, 4] } }

dup = hash.deep_dup
dup[:b][:e] = 5
dup[:b][:d] << 5

hash[:b][:e] == nil      # => true
hash[:b][:d] == [3, 4]   # => true
```

注意：`active_support/core_ext/object/deep_dup.rb` で定義されています。


### キーの操作

#### `except` と `except!`

[`except`][Hash#except] メソッドは、引数リストに含まれるキーを削除したハッシュを返します。

```ruby
{ a: 1, b: 2 }.except(:a) # => {:b=>2}
```

レシーバが `convert_key` に応答する場合、引数の各要素に対してそのメソッドが呼び出されます。これにより、`except` は、例えば indifferent access を持つハッシュとうまく動作することができます。

```ruby
{ a: 1 }.with_indifferent_access.except(:a)  # => {}
{ a: 1 }.with_indifferent_access.except("a") # => {}
```

また、バンバージョンの [`except!`][Hash#except!] もあり、キーをインプレースで削除します。

注意：`active_support/core_ext/hash/except.rb` で定義されています。


#### `stringify_keys` と `stringify_keys!`

[`stringify_keys`][Hash#stringify_keys] メソッドは、レシーバのキーの文字列化バージョンを持つハッシュを返します。これは、各キーに対して `to_s` を送信することで行われます。

```ruby
{ nil => nil, 1 => 1, a: :a }.stringify_keys
# => {"" => nil, "1" => 1, "a" => :a}
```

キーの衝突がある場合、値はハッシュに最後に挿入された値になります。

```ruby
{ "a" => 1, a: 2 }.stringify_keys
# 結果は
# => {"a"=>2}
```
このメソッドは、例えばシンボルと文字列の両方をオプションとして受け入れるために便利です。例えば、`ActionView::Helpers::FormHelper`では次のように定義されています。

```ruby
def to_check_box_tag(options = {}, checked_value = "1", unchecked_value = "0")
  options = options.stringify_keys
  options["type"] = "checkbox"
  # ...
end
```

2行目では、安全に"type"キーにアクセスし、ユーザーが`:type`または"type"のいずれかを渡すことができます。

また、[`stringify_keys!`][Hash#stringify_keys!]というバンジョンもあり、キーをその場で文字列に変換します。

それ以外にも、与えられたハッシュとその中にネストされたすべてのハッシュのキーを文字列に変換するために[`deep_stringify_keys`][Hash#deep_stringify_keys]と[`deep_stringify_keys!`][Hash#deep_stringify_keys!]を使用することができます。結果の例は次のとおりです。

```ruby
{ nil => nil, 1 => 1, nested: { a: 3, 5 => 5 } }.deep_stringify_keys
# => {""=>nil, "1"=>1, "nested"=>{"a"=>3, "5"=>5}}
```

注意：`active_support/core_ext/hash/keys.rb`で定義されています。


#### `symbolize_keys`と`symbolize_keys!`

メソッド[`symbolize_keys`][Hash#symbolize_keys]は、受け取ったハッシュのキーのシンボル化バージョンを可能な限り返します。これは、それらに`to_sym`を送信することによって行われます。

```ruby
{ nil => nil, 1 => 1, "a" => "a" }.symbolize_keys
# => {nil=>nil, 1=>1, :a=>"a"}
```

警告。前の例では、キーが1つだけシンボル化されていることに注意してください。

キーの衝突の場合、値はハッシュに最後に挿入されたものになります。

```ruby
{ "a" => 1, a: 2 }.symbolize_keys
# => {:a=>2}
```

このメソッドは、例えばシンボルと文字列の両方をオプションとして簡単に受け入れるために便利です。例えば、`ActionText::TagHelper`では次のように定義されています。

```ruby
def rich_text_area_tag(name, value = nil, options = {})
  options = options.symbolize_keys

  options[:input] ||= "trix_input_#{ActionText::TagHelper.id += 1}"
  # ...
end
```

3行目では、安全に`:input`キーにアクセスし、ユーザーが`:input`または"input"のいずれかを渡すことができます。

また、[`symbolize_keys!`][Hash#symbolize_keys!]というバンジョンもあり、キーをその場でシンボルに変換します。

それ以外にも、与えられたハッシュとその中にネストされたすべてのハッシュのキーをシンボルに変換するために[`deep_symbolize_keys`][Hash#deep_symbolize_keys]と[`deep_symbolize_keys!`][Hash#deep_symbolize_keys!]を使用することができます。結果の例は次のとおりです。

```ruby
{ nil => nil, 1 => 1, "nested" => { "a" => 3, 5 => 5 } }.deep_symbolize_keys
# => {nil=>nil, 1=>1, nested:{a:3, 5=>5}}
```

注意：`active_support/core_ext/hash/keys.rb`で定義されています。


#### `to_options`と`to_options!`

メソッド[`to_options`][Hash#to_options]と[`to_options!`][Hash#to_options!]は、それぞれ`symbolize_keys`と`symbolize_keys!`のエイリアスです。

注意：`active_support/core_ext/hash/keys.rb`で定義されています。


#### `assert_valid_keys`

メソッド[`assert_valid_keys`][Hash#assert_valid_keys]は、任意の数の引数を受け取り、レシーバーにそのリスト外のキーがあるかどうかをチェックします。もしキーがあれば、`ArgumentError`が発生します。

```ruby
{ a: 1 }.assert_valid_keys(:a)  # パスする
{ a: 1 }.assert_valid_keys("a") # ArgumentError
```

例えば、Active Recordでは、関連を構築する際に未知のオプションを受け入れません。これは`assert_valid_keys`を使用して制御されています。

注意：`active_support/core_ext/hash/keys.rb`で定義されています。


### 値の操作

#### `deep_transform_values`と`deep_transform_values!`

メソッド[`deep_transform_values`][Hash#deep_transform_values]は、ブロック操作によって変換されたすべての値を含む新しいハッシュを返します。これには、ルートハッシュとすべてのネストされたハッシュと配列の値が含まれます。

```ruby
hash = { person: { name: 'Rob', age: '28' } }

hash.deep_transform_values { |value| value.to_s.upcase }
# => {person: {name: "ROB", age: "28"}}
```

また、ブロック操作を使用してすべての値を破壊的に変換するためのバンジョン[`deep_transform_values!`][Hash#deep_transform_values!]もあります。

注意：`active_support/core_ext/hash/deep_transform_values.rb`で定義されています。


### スライス

メソッド[`slice!`][Hash#slice!]は、指定されたキーのみを含むハッシュに置き換え、削除されたキー/値のペアを含むハッシュを返します。

```ruby
hash = { a: 1, b: 2 }
rest = hash.slice!(:a) # => {:b=>2}
hash                   # => {:a=>1}
```

注意：`active_support/core_ext/hash/slice.rb`で定義されています。


### 抽出

メソッド[`extract!`][Hash#extract!]は、指定されたキーに一致するキー/値のペアを削除して返します。

```ruby
hash = { a: 1, b: 2 }
rest = hash.extract!(:a) # => {:a=>1}
hash                     # => {:b=>2}
```

メソッド`extract!`は、レシーバーと同じハッシュのサブクラスを返します。
```ruby
hash = { a: 1, b: 2 }.with_indifferent_access
rest = hash.extract!(:a).class
# => ActiveSupport::HashWithIndifferentAccess
```

注意：`active_support/core_ext/hash/slice.rb`で定義されています。


### 無差別アクセス

[`with_indifferent_access`][Hash#with_indifferent_access]メソッドは、レシーバーから[`ActiveSupport::HashWithIndifferentAccess`][ActiveSupport::HashWithIndifferentAccess]を返します。

```ruby
{ a: 1 }.with_indifferent_access["a"] # => 1
```

注意：`active_support/core_ext/hash/indifferent_access.rb`で定義されています。


`Regexp`の拡張
----------------------

### `multiline?`

[`multiline?`][Regexp#multiline?]メソッドは、正規表現が`/m`フラグが設定されているかどうか、つまりドットが改行にマッチするかどうかを示します。

```ruby
%r{.}.multiline?  # => false
%r{.}m.multiline? # => true

Regexp.new('.').multiline?                    # => false
Regexp.new('.', Regexp::MULTILINE).multiline? # => true
```

Railsでは、このメソッドをルーティングコードでも使用しています。マルチラインの正規表現はルートの要件では許可されておらず、このフラグはその制約を緩和します。

```ruby
def verify_regexp_requirements(requirements)
  # ...
  if requirement.multiline?
    raise ArgumentError, "Regexp multiline option is not allowed in routing requirements: #{requirement.inspect}"
  end
  # ...
end
```

注意：`active_support/core_ext/regexp.rb`で定義されています。


`Range`の拡張
---------------------

### `to_fs`

Active Supportは、オプションのフォーマット引数を理解する`to_s`の代替として`Range#to_fs`を定義しています。現時点では、サポートされている非デフォルトのフォーマットは`:db`のみです。

```ruby
(Date.today..Date.tomorrow).to_fs
# => "2009-10-25..2009-10-26"

(Date.today..Date.tomorrow).to_fs(:db)
# => "BETWEEN '2009-10-25' AND '2009-10-26'"
```

例では、`:db`フォーマットは`BETWEEN` SQL句を生成します。これは、Active Recordが条件で範囲値をサポートするために使用されます。

注意：`active_support/core_ext/range/conversions.rb`で定義されています。

### `===`と`include?`

`Range#===`メソッドと`Range#include?`メソッドは、与えられた値がインスタンスの範囲の両端の間にあるかどうかを示します。

```ruby
(2..3).include?(Math::E) # => true
```

Active Supportは、引数が再び範囲である場合、これらのメソッドを拡張して、引数の範囲の両端がレシーバー自体に属しているかどうかをテストします。

```ruby
(1..10) === (3..7)  # => true
(1..10) === (0..7)  # => false
(1..10) === (3..11) # => false
(1...9) === (3..9)  # => false

(1..10).include?(3..7)  # => true
(1..10).include?(0..7)  # => false
(1..10).include?(3..11) # => false
(1...9).include?(3..9)  # => false
```

注意：`active_support/core_ext/range/compare_range.rb`で定義されています。

### `overlap?`

[`Range#overlap?`][Range#overlap?]メソッドは、2つの範囲が空でない交差部分を持つかどうかを示します。

```ruby
(1..10).overlap?(7..11)  # => true
(1..10).overlap?(0..7)   # => true
(1..10).overlap?(11..27) # => false
```

注意：`active_support/core_ext/range/overlap.rb`で定義されています。


`Date`の拡張
--------------------

### 計算

INFO: 以下の計算メソッドには、1582年10月のエッジケースがあります。なぜなら、日付5〜14は存在しないからです。このガイドでは、簡潔さのためにこれらの日付の周りでの動作は文書化していませんが、期待される動作についてはActive Supportのテストスイートの`test/core_ext/date_ext_test.rb`を確認してください。

#### `Date.current`

Active Supportは、[`Date.current`][Date.current]を現在のタイムゾーンの今日の日付と定義しています。これは`Date.today`と似ていますが、定義されている場合はユーザータイムゾーンを尊重します。また、[`Date.yesterday`][Date.yesterday]と[`Date.tomorrow`][Date.tomorrow]、およびインスタンスの述語[`past?`][DateAndTime::Calculations#past?]、[`today?`][DateAndTime::Calculations#today?]、[`tomorrow?`][DateAndTime::Calculations#tomorrow?]、[`next_day?`][DateAndTime::Calculations#next_day?]、[`yesterday?`][DateAndTime::Calculations#yesterday?]、[`prev_day?`][DateAndTime::Calculations#prev_day?]、[`future?`][DateAndTime::Calculations#future?]、[`on_weekday?`][DateAndTime::Calculations#on_weekday?]、[`on_weekend?`][DateAndTime::Calculations#on_weekend?]も定義されています。これらはすべて`Date.current`に対して相対的です。

ユーザータイムゾーンを尊重するメソッドを使用して日付の比較を行う場合は、`Date.today`ではなく`Date.current`を使用してください。ユーザータイムゾーンがシステムタイムゾーンよりも未来にある場合、`Date.today`は`Date.yesterday`と等しくなる可能性があるためです。

注意：`active_support/core_ext/date/calculations.rb`で定義されています。


#### 名前付き日付

##### `beginning_of_week`、`end_of_week`

[`beginning_of_week`][DateAndTime::Calculations#beginning_of_week]メソッドと[`end_of_week`][DateAndTime::Calculations#end_of_week]メソッドは、それぞれ週の始まりと終わりの日付を返します。週は月曜日から始まると仮定されていますが、引数を渡したり、スレッドローカルの`Date.beginning_of_week`または[`config.beginning_of_week`][]を設定することで変更できます。

```ruby
d = Date.new(2010, 5, 8)     # => Sat, 08 May 2010
d.beginning_of_week          # => Mon, 03 May 2010
d.beginning_of_week(:sunday) # => Sun, 02 May 2010
d.end_of_week                # => Sun, 09 May 2010
d.end_of_week(:sunday)       # => Sat, 08 May 2010
```

`beginning_of_week`は[`at_beginning_of_week`][DateAndTime::Calculations#at_beginning_of_week]にエイリアスされ、`end_of_week`は[`at_end_of_week`][DateAndTime::Calculations#at_end_of_week]にエイリアスされています。

注意：`active_support/core_ext/date_and_time/calculations.rb`で定義されています。


##### `monday`, `sunday`

[`monday`][DateAndTime::Calculations#monday]と[`sunday`][DateAndTime::Calculations#sunday]メソッドは、それぞれ前の月曜日と次の日曜日の日付を返します。

```ruby
d = Date.new(2010, 5, 8)     # => Sat, 08 May 2010
d.monday                     # => Mon, 03 May 2010
d.sunday                     # => Sun, 09 May 2010

d = Date.new(2012, 9, 10)    # => Mon, 10 Sep 2012
d.monday                     # => Mon, 10 Sep 2012

d = Date.new(2012, 9, 16)    # => Sun, 16 Sep 2012
d.sunday                     # => Sun, 16 Sep 2012
```

注意：`active_support/core_ext/date_and_time/calculations.rb`で定義されています。


##### `prev_week`, `next_week`

[`next_week`][DateAndTime::Calculations#next_week]メソッドは、英語の曜日名をシンボルで受け取ります（デフォルトはスレッドローカルの[`Date.beginning_of_week`][Date.beginning_of_week]、または[`config.beginning_of_week`][]、または`:monday`）そして、その日に対応する日付を返します。

```ruby
d = Date.new(2010, 5, 9) # => Sun, 09 May 2010
d.next_week              # => Mon, 10 May 2010
d.next_week(:saturday)   # => Sat, 15 May 2010
```

[`prev_week`][DateAndTime::Calculations#prev_week]メソッドは同様です：

```ruby
d.prev_week              # => Mon, 26 Apr 2010
d.prev_week(:saturday)   # => Sat, 01 May 2010
d.prev_week(:friday)     # => Fri, 30 Apr 2010
```

`prev_week`は[`last_week`][DateAndTime::Calculations#last_week]にエイリアスされています。

`next_week`と`prev_week`は、`Date.beginning_of_week`または`config.beginning_of_week`が設定されている場合にも正常に動作します。

注意：`active_support/core_ext/date_and_time/calculations.rb`で定義されています。


##### `beginning_of_month`, `end_of_month`

[`beginning_of_month`][DateAndTime::Calculations#beginning_of_month]と[`end_of_month`][DateAndTime::Calculations#end_of_month]メソッドは、月の始まりと終わりの日付を返します。

```ruby
d = Date.new(2010, 5, 9) # => Sun, 09 May 2010
d.beginning_of_month     # => Sat, 01 May 2010
d.end_of_month           # => Mon, 31 May 2010
```

`beginning_of_month`は[`at_beginning_of_month`][DateAndTime::Calculations#at_beginning_of_month]にエイリアスされ、`end_of_month`は[`at_end_of_month`][DateAndTime::Calculations#at_end_of_month]にエイリアスされています。

注意：`active_support/core_ext/date_and_time/calculations.rb`で定義されています。


##### `quarter`, `beginning_of_quarter`, `end_of_quarter`

[`quarter`][DateAndTime::Calculations#quarter]メソッドは、レシーバのカレンダー年の四半期を返します。

```ruby
d = Date.new(2010, 5, 9) # => Sun, 09 May 2010
d.quarter                # => 2
```

[`beginning_of_quarter`][DateAndTime::Calculations#beginning_of_quarter]と[`end_of_quarter`][DateAndTime::Calculations#end_of_quarter]メソッドは、レシーバのカレンダー年の四半期の始まりと終わりの日付を返します。

```ruby
d = Date.new(2010, 5, 9) # => Sun, 09 May 2010
d.beginning_of_quarter   # => Thu, 01 Apr 2010
d.end_of_quarter         # => Wed, 30 Jun 2010
```

`beginning_of_quarter`は[`at_beginning_of_quarter`][DateAndTime::Calculations#at_beginning_of_quarter]にエイリアスされ、`end_of_quarter`は[`at_end_of_quarter`][DateAndTime::Calculations#at_end_of_quarter]にエイリアスされています。

注意：`active_support/core_ext/date_and_time/calculations.rb`で定義されています。


##### `beginning_of_year`, `end_of_year`

[`beginning_of_year`][DateAndTime::Calculations#beginning_of_year]と[`end_of_year`][DateAndTime::Calculations#end_of_year]メソッドは、年の始まりと終わりの日付を返します。

```ruby
d = Date.new(2010, 5, 9) # => Sun, 09 May 2010
d.beginning_of_year      # => Fri, 01 Jan 2010
d.end_of_year            # => Fri, 31 Dec 2010
```

`beginning_of_year`は[`at_beginning_of_year`][DateAndTime::Calculations#at_beginning_of_year]にエイリアスされ、`end_of_year`は[`at_end_of_year`][DateAndTime::Calculations#at_end_of_year]にエイリアスされています。

注意：`active_support/core_ext/date_and_time/calculations.rb`で定義されています。


#### その他の日付計算

##### `years_ago`, `years_since`

[`years_ago`][DateAndTime::Calculations#years_ago]メソッドは、指定した年数前の同じ日付を返します。

```ruby
date = Date.new(2010, 6, 7)
date.years_ago(10) # => Wed, 07 Jun 2000
```

[`years_since`][DateAndTime::Calculations#years_since]メソッドは、指定した年数後の日付を返します。

```ruby
date = Date.new(2010, 6, 7)
date.years_since(10) # => Sun, 07 Jun 2020
```

そのような日が存在しない場合、対応する月の最終日が返されます。

```ruby
Date.new(2012, 2, 29).years_ago(3)     # => Sat, 28 Feb 2009
Date.new(2012, 2, 29).years_since(3)   # => Sat, 28 Feb 2015
```

[`last_year`][DateAndTime::Calculations#last_year]は`#years_ago(1)`の省略形です。

注意：`active_support/core_ext/date_and_time/calculations.rb`で定義されています。


##### `months_ago`, `months_since`

[`months_ago`][DateAndTime::Calculations#months_ago]と[`months_since`][DateAndTime::Calculations#months_since]メソッドは、月に対して同様の動作をします。

```ruby
Date.new(2010, 4, 30).months_ago(2)   # => Sun, 28 Feb 2010
Date.new(2010, 4, 30).months_since(2) # => Wed, 30 Jun 2010
```

そのような日が存在しない場合、対応する月の最終日が返されます。

```ruby
Date.new(2010, 4, 30).months_ago(2)    # => Sun, 28 Feb 2010
Date.new(2009, 12, 31).months_since(2) # => Sun, 28 Feb 2010
```

[`last_month`][DateAndTime::Calculations#last_month]は`#months_ago(1)`の省略形です。
注意：`active_support/core_ext/date_and_time/calculations.rb`で定義されています。

##### `weeks_ago`

[`weeks_ago`][DateAndTime::Calculations#weeks_ago]メソッドは、週に対して同様に機能します。

```ruby
Date.new(2010, 5, 24).weeks_ago(1)    # => Mon, 17 May 2010
Date.new(2010, 5, 24).weeks_ago(2)    # => Mon, 10 May 2010
```

注意：`active_support/core_ext/date_and_time/calculations.rb`で定義されています。

##### `advance`

他の日にジャンプする最も一般的な方法は、[`advance`][Date#advance]です。このメソッドは、`years`、`months`、`weeks`、`days`というキーを持つハッシュを受け取り、現在のキーが示すだけ進んだ日付を返します。

```ruby
date = Date.new(2010, 6, 6)
date.advance(years: 1, weeks: 2)  # => Mon, 20 Jun 2011
date.advance(months: 2, days: -2) # => Wed, 04 Aug 2010
```

前の例では、増分が負であることに注意してください。

注意：`active_support/core_ext/date/calculations.rb`で定義されています。

#### コンポーネントの変更

[`change`][Date#change]メソッドを使用すると、指定した年、月、または日を除いて、受信者と同じ日付の新しい日付を取得できます。

```ruby
Date.new(2010, 12, 23).change(year: 2011, month: 11)
# => Wed, 23 Nov 2011
```

このメソッドは存在しない日付に対しては許容されません。変更が無効な場合は、`ArgumentError`が発生します。

```ruby
Date.new(2010, 1, 31).change(month: 2)
# => ArgumentError: invalid date
```

注意：`active_support/core_ext/date/calculations.rb`で定義されています。

#### 持続時間

[`Duration`][ActiveSupport::Duration]オブジェクトは、日付に追加したり、日付から減算したりすることができます。

```ruby
d = Date.current
# => Mon, 09 Aug 2010
d + 1.year
# => Tue, 09 Aug 2011
d - 3.hours
# => Sun, 08 Aug 2010 21:00:00 UTC +00:00
```

これらは`since`または`advance`への呼び出しに変換されます。たとえば、ここではカレンダー改革の正しいジャンプが得られます。

```ruby
Date.new(1582, 10, 4) + 1.day
# => Fri, 15 Oct 1582
```

#### タイムスタンプ

INFO: 以下のメソッドは、可能な場合は`Time`オブジェクトを返し、それ以外の場合は`DateTime`オブジェクトを返します。設定されている場合、ユーザーのタイムゾーンを尊重します。

##### `beginning_of_day`、`end_of_day`

[`beginning_of_day`][Date#beginning_of_day]メソッドは、その日の始まり（00:00:00）のタイムスタンプを返します。

```ruby
date = Date.new(2010, 6, 7)
date.beginning_of_day # => Mon Jun 07 00:00:00 +0200 2010
```

[`end_of_day`][Date#end_of_day]メソッドは、その日の終わり（23:59:59）のタイムスタンプを返します。

```ruby
date = Date.new(2010, 6, 7)
date.end_of_day # => Mon Jun 07 23:59:59 +0200 2010
```

`beginning_of_day`は[`at_beginning_of_day`][Date#at_beginning_of_day]、[`midnight`][Date#midnight]、[`at_midnight`][Date#at_midnight]としてエイリアスされています。

注意：`active_support/core_ext/date/calculations.rb`で定義されています。

##### `beginning_of_hour`、`end_of_hour`

[`beginning_of_hour`][DateTime#beginning_of_hour]メソッドは、その時間の始まり（hh:00:00）のタイムスタンプを返します。

```ruby
date = DateTime.new(2010, 6, 7, 19, 55, 25)
date.beginning_of_hour # => Mon Jun 07 19:00:00 +0200 2010
```

[`end_of_hour`][DateTime#end_of_hour]メソッドは、その時間の終わり（hh:59:59）のタイムスタンプを返します。

```ruby
date = DateTime.new(2010, 6, 7, 19, 55, 25)
date.end_of_hour # => Mon Jun 07 19:59:59 +0200 2010
```

`beginning_of_hour`は[`at_beginning_of_hour`][DateTime#at_beginning_of_hour]としてエイリアスされています。

注意：`active_support/core_ext/date_time/calculations.rb`で定義されています。

##### `beginning_of_minute`、`end_of_minute`

[`beginning_of_minute`][DateTime#beginning_of_minute]メソッドは、その分の始まり（hh:mm:00）のタイムスタンプを返します。

```ruby
date = DateTime.new(2010, 6, 7, 19, 55, 25)
date.beginning_of_minute # => Mon Jun 07 19:55:00 +0200 2010
```

[`end_of_minute`][DateTime#end_of_minute]メソッドは、その分の終わり（hh:mm:59）のタイムスタンプを返します。

```ruby
date = DateTime.new(2010, 6, 7, 19, 55, 25)
date.end_of_minute # => Mon Jun 07 19:55:59 +0200 2010
```

`beginning_of_minute`は[`at_beginning_of_minute`][DateTime#at_beginning_of_minute]としてエイリアスされています。

INFO：`beginning_of_hour`、`end_of_hour`、`beginning_of_minute`、`end_of_minute`は、`Date`インスタンスでは時や分の始まりや終わりを要求する意味がないため、`Time`と`DateTime`に対して実装されていますが、`Date`には実装されていません。

注意：`active_support/core_ext/date_time/calculations.rb`で定義されています。

##### `ago`、`since`

[`ago`][Date#ago]メソッドは、指定した秒数前のタイムスタンプを返します。

```ruby
date = Date.current # => Fri, 11 Jun 2010
date.ago(1)         # => Thu, 10 Jun 2010 23:59:59 EDT -04:00
```

同様に、[`since`][Date#since]メソッドは前に進みます。

```ruby
date = Date.current # => Fri, 11 Jun 2010
date.since(1)       # => Fri, 11 Jun 2010 00:00:01 EDT -04:00
```
注意：`active_support/core_ext/date/calculations.rb`で定義されています。

`DateTime`の拡張
------------------------

警告：`DateTime`はDSTのルールを認識していないため、一部のメソッドはDSTの変更が行われている場合にエッジケースが発生する可能性があります。たとえば、[`seconds_since_midnight`][DateTime#seconds_since_midnight]はそのような日には実際の値を返さないかもしれません。

### 計算

クラス`DateTime`は`Date`のサブクラスなので、`active_support/core_ext/date/calculations.rb`をロードすることでこれらのメソッドとそのエイリアスを継承しますが、常に日時を返します。

以下のメソッドは再実装されているため、これらのメソッドについては`active_support/core_ext/date/calculations.rb`をロードする必要はありません。

* [`beginning_of_day`][DateTime#beginning_of_day] / [`midnight`][DateTime#midnight] / [`at_midnight`][DateTime#at_midnight] / [`at_beginning_of_day`][DateTime#at_beginning_of_day]
* [`end_of_day`][DateTime#end_of_day]
* [`ago`][DateTime#ago]
* [`since`][DateTime#since] / [`in`][DateTime#in]

一方、[`advance`][DateTime#advance]と[`change`][DateTime#change]はより多くのオプションをサポートしており、以下で説明されています。

以下のメソッドは`DateTime`インスタンスと一緒に使用する場合にのみ実装されています。

* [`beginning_of_hour`][DateTime#beginning_of_hour] / [`at_beginning_of_hour`][DateTime#at_beginning_of_hour]
* [`end_of_hour`][DateTime#end_of_hour]


#### 名前付き日時

##### `DateTime.current`

Active Supportは[`DateTime.current`][DateTime.current]を`Time.now.to_datetime`のように定義していますが、ユーザーのタイムゾーンが定義されている場合はそれに従います。インスタンスの述語[`past?`][DateAndTime::Calculations#past?]と[`future?`][DateAndTime::Calculations#future?]は、`DateTime.current`に対して相対的に定義されています。

注意：`active_support/core_ext/date_time/calculations.rb`で定義されています。


#### その他の拡張

##### `seconds_since_midnight`

メソッド[`seconds_since_midnight`][DateTime#seconds_since_midnight]は、真夜中からの経過秒数を返します。

```ruby
now = DateTime.current     # => Mon, 07 Jun 2010 20:26:36 +0000
now.seconds_since_midnight # => 73596
```

注意：`active_support/core_ext/date_time/calculations.rb`で定義されています。


##### `utc`

メソッド[`utc`][DateTime#utc]は、受信者の日時をUTCで表現したものを返します。

```ruby
now = DateTime.current # => Mon, 07 Jun 2010 19:27:52 -0400
now.utc                # => Mon, 07 Jun 2010 23:27:52 +0000
```

このメソッドは[`getutc`][DateTime#getutc]としてもエイリアスされています。

注意：`active_support/core_ext/date_time/calculations.rb`で定義されています。


##### `utc?`

述語[`utc?`][DateTime#utc?]は、受信者がUTCをタイムゾーンとして持っているかどうかを示します。

```ruby
now = DateTime.now # => Mon, 07 Jun 2010 19:30:47 -0400
now.utc?           # => false
now.utc.utc?       # => true
```

注意：`active_support/core_ext/date_time/calculations.rb`で定義されています。


##### `advance`

別の日時にジャンプする最も一般的な方法は[`advance`][DateTime#advance]です。このメソッドは、`years`、`months`、`weeks`、`days`、`hours`、`minutes`、`seconds`というキーを持つハッシュを受け取り、それに応じて進められた日時を返します。

```ruby
d = DateTime.current
# => Thu, 05 Aug 2010 11:33:31 +0000
d.advance(years: 1, months: 1, days: 1, hours: 1, minutes: 1, seconds: 1)
# => Tue, 06 Sep 2011 12:34:32 +0000
```

このメソッドはまず、`Date#advance`で`years`、`months`、`weeks`、`days`を渡して目的の日付を計算します。その後、[`since`][DateTime#since]を呼び出して進める秒数を指定して時間を調整します。この順序は重要であり、異なる順序では一部のエッジケースで異なる日時が得られます。`Date#advance`の例が適用され、時間ビットに関連する順序の関連性を示すことができます。

たとえば、日付ビット（前述のように相対的な処理順序も持っています）を最初に移動し、その後に時間ビットを移動すると、次の計算結果が得られます。

```ruby
d = DateTime.new(2010, 2, 28, 23, 59, 59)
# => Sun, 28 Feb 2010 23:59:59 +0000
d.advance(months: 1, seconds: 1)
# => Mon, 29 Mar 2010 00:00:00 +0000
```

しかし、逆の順序で計算すると、結果は異なります。

```ruby
d.advance(seconds: 1).advance(months: 1)
# => Thu, 01 Apr 2010 00:00:00 +0000
```

警告：`DateTime`はDSTを認識していないため、警告やエラーなしに存在しない時点に到達する可能性があります。

注意：`active_support/core_ext/date_time/calculations.rb`で定義されています。


#### コンポーネントの変更

メソッド[`change`][DateTime#change]を使用すると、与えられたオプション（`year`、`month`、`day`、`hour`、`min`、`sec`、`offset`、`start`）を除いて、受信者と同じ日時を持つ新しい日時を取得できます。

```ruby
now = DateTime.current
# => Tue, 08 Jun 2010 01:56:22 +0000
now.change(year: 2011, offset: Rational(-6, 24))
# => Wed, 08 Jun 2011 01:56:22 -0600
```
時間がゼロになると、分と秒もゼロになります（値が指定されていない場合）：

```ruby
now.change(hour: 0)
# => Tue, 08 Jun 2010 00:00:00 +0000
```

同様に、分がゼロになると、秒もゼロになります（値が指定されていない場合）：

```ruby
now.change(min: 0)
# => Tue, 08 Jun 2010 01:00:00 +0000
```

このメソッドは存在しない日付に対しては許容されません。無効な変更がある場合は、`ArgumentError`が発生します：

```ruby
DateTime.current.change(month: 2, day: 30)
# => ArgumentError: invalid date
```

注意：`active_support/core_ext/date_time/calculations.rb`で定義されています。


#### 持続時間

[`Duration`][ActiveSupport::Duration]オブジェクトは、日時に追加または減算できます：

```ruby
now = DateTime.current
# => Mon, 09 Aug 2010 23:15:17 +0000
now + 1.year
# => Tue, 09 Aug 2011 23:15:17 +0000
now - 1.week
# => Mon, 02 Aug 2010 23:15:17 +0000
```

これらは`since`または`advance`への呼び出しに変換されます。たとえば、ここではカレンダー改革の正しいジャンプが得られます：

```ruby
DateTime.new(1582, 10, 4, 23) + 1.hour
# => Fri, 15 Oct 1582 00:00:00 +0000
```

`Time`への拡張
--------------------

### 計算

これらは類似しています。上記のドキュメントを参照して、以下の違いに注意してください：

* [`change`][Time#change]は追加の`:usec`オプションを受け入れます。
* `Time`はDSTを理解しているため、正しいDSTの計算が得られます。たとえば、

```ruby
Time.zone_default
# => #<ActiveSupport::TimeZone:0x7f73654d4f38 @utc_offset=nil, @name="Madrid", ...>

# バルセロナでは、2010/03/28 02:00 +0100はDSTのために2010/03/28 03:00 +0200になります。
t = Time.local(2010, 3, 28, 1, 59, 59)
# => Sun Mar 28 01:59:59 +0100 2010
t.advance(seconds: 1)
# => Sun Mar 28 03:00:00 +0200 2010
```

* [`since`][Time#since]または[`ago`][Time#ago]が`Time`で表現できない時間にジャンプする場合、代わりに`DateTime`オブジェクトが返されます。


#### `Time.current`

Active Supportは、[`Time.current`][Time.current]を現在のタイムゾーンの今日と定義しています。これは`Time.now`と似ていますが、定義されている場合はユーザーのタイムゾーンを尊重します。また、[`past?`][DateAndTime::Calculations#past?]、[`today?`][DateAndTime::Calculations#today?]、[`tomorrow?`][DateAndTime::Calculations#tomorrow?]、[`next_day?`][DateAndTime::Calculations#next_day?]、[`yesterday?`][DateAndTime::Calculations#yesterday?]、[`prev_day?`][DateAndTime::Calculations#prev_day?]、[`future?`][DateAndTime::Calculations#future?]といったインスタンスの述語も定義されており、すべて`Time.current`に対して相対的です。

ユーザーのタイムゾーンを尊重するメソッドを使用して時間の比較を行う場合は、`Time.now`の代わりに`Time.current`を使用してください。ユーザーのタイムゾーンがシステムのタイムゾーンよりも未来にある場合、デフォルトで`Time.now`が使用するシステムのタイムゾーンと比較して、`Time.now.to_date`は`Date.yesterday`と等しくなる可能性があります。

注意：`active_support/core_ext/time/calculations.rb`で定義されています。


#### `all_day`、`all_week`、`all_month`、`all_quarter`、`all_year`

メソッド[`all_day`][DateAndTime::Calculations#all_day]は、現在の時間の一日全体を表す範囲を返します。

```ruby
now = Time.current
# => Mon, 09 Aug 2010 23:20:05 UTC +00:00
now.all_day
# => Mon, 09 Aug 2010 00:00:00 UTC +00:00..Mon, 09 Aug 2010 23:59:59 UTC +00:00
```

同様に、[`all_week`][DateAndTime::Calculations#all_week]、[`all_month`][DateAndTime::Calculations#all_month]、[`all_quarter`][DateAndTime::Calculations#all_quarter]、[`all_year`][DateAndTime::Calculations#all_year]は、時間範囲を生成するための目的で使用されます。

```ruby
now = Time.current
# => Mon, 09 Aug 2010 23:20:05 UTC +00:00
now.all_week
# => Mon, 09 Aug 2010 00:00:00 UTC +00:00..Sun, 15 Aug 2010 23:59:59 UTC +00:00
now.all_week(:sunday)
# => Sun, 16 Sep 2012 00:00:00 UTC +00:00..Sat, 22 Sep 2012 23:59:59 UTC +00:00
now.all_month
# => Sat, 01 Aug 2010 00:00:00 UTC +00:00..Tue, 31 Aug 2010 23:59:59 UTC +00:00
now.all_quarter
# => Thu, 01 Jul 2010 00:00:00 UTC +00:00..Thu, 30 Sep 2010 23:59:59 UTC +00:00
now.all_year
# => Fri, 01 Jan 2010 00:00:00 UTC +00:00..Fri, 31 Dec 2010 23:59:59 UTC +00:00
```

注意：`active_support/core_ext/date_and_time/calculations.rb`で定義されています。


#### `prev_day`、`next_day`

[`prev_day`][Time#prev_day]と[`next_day`][Time#next_day]は、前日または翌日の時間を返します：

```ruby
t = Time.new(2010, 5, 8) # => 2010-05-08 00:00:00 +0900
t.prev_day               # => 2010-05-07 00:00:00 +0900
t.next_day               # => 2010-05-09 00:00:00 +0900
```

注意：`active_support/core_ext/time/calculations.rb`で定義されています。


#### `prev_month`、`next_month`

[`prev_month`][Time#prev_month]と[`next_month`][Time#next_month]は、前月または翌月の同じ日の時間を返します：
```ruby
t = Time.new(2010, 5, 8) # => 2010-05-08 00:00:00 +0900
t.prev_month             # => 2010-04-08 00:00:00 +0900
t.next_month             # => 2010-06-08 00:00:00 +0900
```

もし存在しない日付の場合、対応する月の最終日が返されます。

```ruby
Time.new(2000, 5, 31).prev_month # => 2000-04-30 00:00:00 +0900
Time.new(2000, 3, 31).prev_month # => 2000-02-29 00:00:00 +0900
Time.new(2000, 5, 31).next_month # => 2000-06-30 00:00:00 +0900
Time.new(2000, 1, 31).next_month # => 2000-02-29 00:00:00 +0900
```

注意：`active_support/core_ext/time/calculations.rb`で定義されています。


#### `prev_year`, `next_year`

[`prev_year`][Time#prev_year]と[`next_year`][Time#next_year]は、同じ日/月を前年または次年に持つ時間を返します。

```ruby
t = Time.new(2010, 5, 8) # => 2010-05-08 00:00:00 +0900
t.prev_year              # => 2009-05-08 00:00:00 +0900
t.next_year              # => 2011-05-08 00:00:00 +0900
```

もし日付が閏年の2月29日の場合、28日が返されます。

```ruby
t = Time.new(2000, 2, 29) # => 2000-02-29 00:00:00 +0900
t.prev_year               # => 1999-02-28 00:00:00 +0900
t.next_year               # => 2001-02-28 00:00:00 +0900
```

注意：`active_support/core_ext/time/calculations.rb`で定義されています。


#### `prev_quarter`, `next_quarter`

[`prev_quarter`][DateAndTime::Calculations#prev_quarter]と[`next_quarter`][DateAndTime::Calculations#next_quarter]は、前の四半期または次の四半期の同じ日付を返します。

```ruby
t = Time.local(2010, 5, 8) # => 2010-05-08 00:00:00 +0300
t.prev_quarter             # => 2010-02-08 00:00:00 +0200
t.next_quarter             # => 2010-08-08 00:00:00 +0300
```

もし存在しない日付の場合、対応する月の最終日が返されます。

```ruby
Time.local(2000, 7, 31).prev_quarter  # => 2000-04-30 00:00:00 +0300
Time.local(2000, 5, 31).prev_quarter  # => 2000-02-29 00:00:00 +0200
Time.local(2000, 10, 31).prev_quarter # => 2000-07-31 00:00:00 +0300
Time.local(2000, 11, 31).next_quarter # => 2001-03-01 00:00:00 +0200
```

`prev_quarter`は[`last_quarter`][DateAndTime::Calculations#last_quarter]のエイリアスです。

注意：`active_support/core_ext/date_and_time/calculations.rb`で定義されています。


### 時間のコンストラクタ

Active Supportでは、ユーザーのタイムゾーンが定義されている場合は`Time.zone.now`、それ以外の場合は`Time.now`となる[`Time.current`][Time.current]が定義されています。

```ruby
Time.zone_default
# => #<ActiveSupport::TimeZone:0x7f73654d4f38 @utc_offset=nil, @name="Madrid", ...>
Time.current
# => Fri, 06 Aug 2010 17:11:58 CEST +02:00
```

`DateTime`と同様に、述語[`past?`][DateAndTime::Calculations#past?]と[`future?`][DateAndTime::Calculations#future?]は`Time.current`に対して相対的です。

構築する時間がランタイムプラットフォームでサポートされている範囲を超える場合、マイクロ秒は破棄され、代わりに`DateTime`オブジェクトが返されます。

#### 期間

[`Duration`][ActiveSupport::Duration]オブジェクトは、時間オブジェクトに加算または減算することができます。

```ruby
now = Time.current
# => Mon, 09 Aug 2010 23:20:05 UTC +00:00
now + 1.year
# => Tue, 09 Aug 2011 23:21:11 UTC +00:00
now - 1.week
# => Mon, 02 Aug 2010 23:21:11 UTC +00:00
```

これらは`sinc`または`advance`への呼び出しに変換されます。たとえば、ここではカレンダー改革の正しいジャンプが得られます。

```ruby
Time.utc(1582, 10, 3) + 5.days
# => Mon Oct 18 00:00:00 UTC 1582
```

`File`への拡張
--------------------

### `atomic_write`

クラスメソッド[`File.atomic_write`][File.atomic_write]を使用すると、半分書き込まれたコンテンツを読み取ることを防ぐ方法でファイルに書き込むことができます。

ファイルの名前は引数として渡され、メソッドは書き込み用に開かれたファイルハンドルを生成します。ブロックが完了すると、`atomic_write`はファイルハンドルを閉じて処理を完了します。

たとえば、Action Packは`all.css`のようなアセットキャッシュファイルを書き込むためにこのメソッドを使用します。

```ruby
File.atomic_write(joined_asset_path) do |cache|
  cache.write(join_asset_file_contents(asset_paths))
end
```

これを実現するために、`atomic_write`は一時ファイルを作成します。これがブロック内のコードが実際に書き込むファイルです。完了時に、一時ファイルはリネームされ、これはPOSIXシステム上のアトミックな操作です。対象のファイルが存在する場合、`atomic_write`は上書きし、所有者とアクセス権を保持します。ただし、ファイルの所有者やアクセス権を変更できない場合がいくつかあります。このエラーはキャッチされ、スキップされます。ファイルがプロセスが必要とするプロセスにアクセスできるようにユーザー/ファイルシステムに信頼しています。

注意：`atomic_write`が実行するchmod操作のため、対象のファイルにACLが設定されている場合、このACLは再計算/変更されます。
警告。`atomic_write` で追加することはできません。

補助ファイルは一時ファイルのための標準ディレクトリに書き込まれますが、第2引数として任意のディレクトリを渡すこともできます。

注意: `active_support/core_ext/file/atomic.rb` で定義されています。


`NameError` への拡張
-------------------------

Active Support は `NameError` に [`missing_name?`][NameError#missing_name?] を追加し、例外が引数として渡された名前によって発生したかどうかをテストします。

名前はシンボルまたは文字列として指定できます。シンボルは裸の定数名と比較され、文字列は完全修飾定数名と比較されます。

ヒント: シンボルは `:"ActiveRecord::Base"` のように完全修飾定数名を表すことができますので、シンボルの振る舞いは便宜上定義されているものであり、技術的にそうする必要があるわけではありません。

例えば、`ArticlesController` のアクションが呼び出された場合、Rails は楽観的に `ArticlesHelper` を使用しようとします。ヘルパーモジュールが存在しない場合は問題ありませんので、その定数名に対して例外が発生した場合は無視されるべきです。しかし、`articles_helper.rb` が実際の未知の定数によって `NameError` を発生させる場合もあります。それは再度発生させるべきです。`missing_name?` メソッドは両方のケースを区別する方法を提供します。

```ruby
def default_helper_module!
  module_name = name.delete_suffix("Controller")
  module_path = module_name.underscore
  helper module_path
rescue LoadError => e
  raise e unless e.is_missing? "helpers/#{module_path}_helper"
rescue NameError => e
  raise e unless e.missing_name? "#{module_name}Helper"
end
```

注意: `active_support/core_ext/name_error.rb` で定義されています。


`LoadError` への拡張
-------------------------

Active Support は `LoadError` に [`is_missing?`][LoadError#is_missing?] を追加します。

`is_missing?` メソッドは、特定のファイルによって例外が発生したかどうかをテストします（おそらく ".rb" 拡張子を除く）。

例えば、`ArticlesController` のアクションが呼び出された場合、Rails は `articles_helper.rb` を読み込もうとしますが、そのファイルが存在しない場合もあります。それは問題ありません。ヘルパーモジュールは必須ではないため、Rails は読み込みエラーを無視します。しかし、ヘルパーモジュールが存在し、さらに別のライブラリが不足している場合もあります。その場合、Rails は例外を再度発生させる必要があります。`is_missing?` メソッドは両方のケースを区別する方法を提供します。

```ruby
def default_helper_module!
  module_name = name.delete_suffix("Controller")
  module_path = module_name.underscore
  helper module_path
rescue LoadError => e
  raise e unless e.is_missing? "helpers/#{module_path}_helper"
rescue NameError => e
  raise e unless e.missing_name? "#{module_name}Helper"
end
```

注意: `active_support/core_ext/load_error.rb` で定義されています。


Pathname への拡張
-------------------------

### `existence`

[`existence`][Pathname#existence] メソッドは、指定されたファイルが存在する場合はレシーバーを返し、存在しない場合は `nil` を返します。次のようなイディオムに便利です。

```ruby
content = Pathname.new("file").existence&.read
```

注意: `active_support/core_ext/pathname/existence.rb` で定義されています。
[`config.active_support.bare`]: configuring.html#config-active-support-bare
[Object#blank?]: https://api.rubyonrails.org/classes/Object.html#method-i-blank-3F
[Object#present?]: https://api.rubyonrails.org/classes/Object.html#method-i-present-3F
[Object#presence]: https://api.rubyonrails.org/classes/Object.html#method-i-presence
[Object#duplicable?]: https://api.rubyonrails.org/classes/Object.html#method-i-duplicable-3F
[Object#deep_dup]: https://api.rubyonrails.org/classes/Object.html#method-i-deep_dup
[Object#try]: https://api.rubyonrails.org/classes/Object.html#method-i-try
[Object#try!]: https://api.rubyonrails.org/classes/Object.html#method-i-try-21
[Kernel#class_eval]: https://api.rubyonrails.org/classes/Kernel.html#method-i-class_eval
[Object#acts_like?]: https://api.rubyonrails.org/classes/Object.html#method-i-acts_like-3F
[Array#to_param]: https://api.rubyonrails.org/classes/Array.html#method-i-to_param
[Object#to_param]: https://api.rubyonrails.org/classes/Object.html#method-i-to_param
[Hash#to_query]: https://api.rubyonrails.org/classes/Hash.html#method-i-to_query
[Object#to_query]: https://api.rubyonrails.org/classes/Object.html#method-i-to_query
[Object#with_options]: https://api.rubyonrails.org/classes/Object.html#method-i-with_options
[Object#instance_values]: https://api.rubyonrails.org/classes/Object.html#method-i-instance_values
[Object#instance_variable_names]: https://api.rubyonrails.org/classes/Object.html#method-i-instance_variable_names
[Kernel#enable_warnings]: https://api.rubyonrails.org/classes/Kernel.html#method-i-enable_warnings
[Kernel#silence_warnings]: https://api.rubyonrails.org/classes/Kernel.html#method-i-silence_warnings
[Kernel#suppress]: https://api.rubyonrails.org/classes/Kernel.html#method-i-suppress
[Object#in?]: https://api.rubyonrails.org/classes/Object.html#method-i-in-3F
[Module#alias_attribute]: https://api.rubyonrails.org/classes/Module.html#method-i-alias_attribute
[Module#attr_internal]: https://api.rubyonrails.org/classes/Module.html#method-i-attr_internal
[Module#attr_internal_accessor]: https://api.rubyonrails.org/classes/Module.html#method-i-attr_internal_accessor
[Module#attr_internal_reader]: https://api.rubyonrails.org/classes/Module.html#method-i-attr_internal_reader
[Module#attr_internal_writer]: https://api.rubyonrails.org/classes/Module.html#method-i-attr_internal_writer
[Module#mattr_accessor]: https://api.rubyonrails.org/classes/Module.html#method-i-mattr_accessor
[Module#mattr_reader]: https://api.rubyonrails.org/classes/Module.html#method-i-mattr_reader
[Module#mattr_writer]: https://api.rubyonrails.org/classes/Module.html#method-i-mattr_writer
[Module#module_parent]: https://api.rubyonrails.org/classes/Module.html#method-i-module_parent
[Module#module_parent_name]: https://api.rubyonrails.org/classes/Module.html#method-i-module_parent_name
[Module#module_parents]: https://api.rubyonrails.org/classes/Module.html#method-i-module_parents
[Module#anonymous?]: https://api.rubyonrails.org/classes/Module.html#method-i-anonymous-3F
[Module#delegate]: https://api.rubyonrails.org/classes/Module.html#method-i-delegate
[Module#delegate_missing_to]: https://api.rubyonrails.org/classes/Module.html#method-i-delegate_missing_to
[Module#redefine_method]: https://api.rubyonrails.org/classes/Module.html#method-i-redefine_method
[Module#silence_redefinition_of_method]: https://api.rubyonrails.org/classes/Module.html#method-i-silence_redefinition_of_method
[Class#class_attribute]: https://api.rubyonrails.org/classes/Class.html#method-i-class_attribute
[Module#cattr_accessor]: https://api.rubyonrails.org/classes/Module.html#method-i-cattr_accessor
[Module#cattr_reader]: https://api.rubyonrails.org/classes/Module.html#method-i-cattr_reader
[Module#cattr_writer]: https://api.rubyonrails.org/classes/Module.html#method-i-cattr_writer
[Class#subclasses]: https://api.rubyonrails.org/classes/Class.html#method-i-subclasses
[Class#descendants]: https://api.rubyonrails.org/classes/Class.html#method-i-descendants
[`raw`]: https://api.rubyonrails.org/classes/ActionView/Helpers/OutputSafetyHelper.html#method-i-raw
[String#html_safe]: https://api.rubyonrails.org/classes/String.html#method-i-html_safe
[String#remove]: https://api.rubyonrails.org/classes/String.html#method-i-remove
[String#squish]: https://api.rubyonrails.org/classes/String.html#method-i-squish
[String#truncate]: https://api.rubyonrails.org/classes/String.html#method-i-truncate
[String#truncate_bytes]: https://api.rubyonrails.org/classes/String.html#method-i-truncate_bytes
[String#truncate_words]: https://api.rubyonrails.org/classes/String.html#method-i-truncate_words
[String#inquiry]: https://api.rubyonrails.org/classes/String.html#method-i-inquiry
[String#strip_heredoc]: https://api.rubyonrails.org/classes/String.html#method-i-strip_heredoc
[String#indent!]: https://api.rubyonrails.org/classes/String.html#method-i-indent-21
[String#indent]: https://api.rubyonrails.org/classes/String.html#method-i-indent
[String#at]: https://api.rubyonrails.org/classes/String.html#method-i-at
[String#from]: https://api.rubyonrails.org/classes/String.html#method-i-from
[String#to]: https://api.rubyonrails.org/classes/String.html#method-i-to
[String#first]: https://api.rubyonrails.org/classes/String.html#method-i-first
[String#last]: https://api.rubyonrails.org/classes/String.html#method-i-last
[String#pluralize]: https://api.rubyonrails.org/classes/String.html#method-i-pluralize
[String#singularize]: https://api.rubyonrails.org/classes/String.html#method-i-singularize
[String#camelcase]: https://api.rubyonrails.org/classes/String.html#method-i-camelcase
[String#camelize]: https://api.rubyonrails.org/classes/String.html#method-i-camelize
[String#underscore]: https://api.rubyonrails.org/classes/String.html#method-i-underscore
[String#titlecase]: https://api.rubyonrails.org/classes/String.html#method-i-titlecase
[String#titleize]: https://api.rubyonrails.org/classes/String.html#method-i-titleize
[String#dasherize]: https://api.rubyonrails.org/classes/String.html#method-i-dasherize
[String#demodulize]: https://api.rubyonrails.org/classes/String.html#method-i-demodulize
[String#deconstantize]: https://api.rubyonrails.org/classes/String.html#method-i-deconstantize
[String#parameterize]: https://api.rubyonrails.org/classes/String.html#method-i-parameterize
[String#tableize]: https://api.rubyonrails.org/classes/String.html#method-i-tableize
[String#classify]: https://api.rubyonrails.org/classes/String.html#method-i-classify
[String#constantize]: https://api.rubyonrails.org/classes/String.html#method-i-constantize
[String#humanize]: https://api.rubyonrails.org/classes/String.html#method-i-humanize
[String#foreign_key]: https://api.rubyonrails.org/classes/String.html#method-i-foreign_key
[String#upcase_first]: https://api.rubyonrails.org/classes/String.html#method-i-upcase_first
[String#downcase_first]: https://api.rubyonrails.org/classes/String.html#method-i-downcase_first
[String#to_date]: https://api.rubyonrails.org/classes/String.html#method-i-to_date
[String#to_datetime]: https://api.rubyonrails.org/classes/String.html#method-i-to_datetime
[String#to_time]: https://api.rubyonrails.org/classes/String.html#method-i-to_time
[Numeric#bytes]: https://api.rubyonrails.org/classes/Numeric.html#method-i-bytes
[Numeric#exabytes]: https://api.rubyonrails.org/classes/Numeric.html#method-i-exabytes
[Numeric#gigabytes]: https://api.rubyonrails.org/classes/Numeric.html#method-i-gigabytes
[Numeric#kilobytes]: https://api.rubyonrails.org/classes/Numeric.html#method-i-kilobytes
[Numeric#megabytes]: https://api.rubyonrails.org/classes/Numeric.html#method-i-megabytes
[Numeric#petabytes]: https://api.rubyonrails.org/classes/Numeric.html#method-i-petabytes
[Numeric#terabytes]: https://api.rubyonrails.org/classes/Numeric.html#method-i-terabytes
[Duration#ago]: https://api.rubyonrails.org/classes/ActiveSupport/Duration.html#method-i-ago
[Duration#from_now]: https://api.rubyonrails.org/classes/ActiveSupport/Duration.html#method-i-from_now
[Numeric#days]: https://api.rubyonrails.org/classes/Numeric.html#method-i-days
[Numeric#fortnights]: https://api.rubyonrails.org/classes/Numeric.html#method-i-fortnights
[Numeric#hours]: https://api.rubyonrails.org/classes/Numeric.html#method-i-hours
[Numeric#minutes]: https://api.rubyonrails.org/classes/Numeric.html#method-i-minutes
[Numeric#seconds]: https://api.rubyonrails.org/classes/Numeric.html#method-i-seconds
[Numeric#weeks]: https://api.rubyonrails.org/classes/Numeric.html#method-i-weeks
[Integer#multiple_of?]: https://api.rubyonrails.org/classes/Integer.html#method-i-multiple_of-3F
[Integer#ordinal]: https://api.rubyonrails.org/classes/Integer.html#method-i-ordinal
[Integer#ordinalize]: https://api.rubyonrails.org/classes/Integer.html#method-i-ordinalize
[Integer#months]: https://api.rubyonrails.org/classes/Integer.html#method-i-months
[Integer#years]: https://api.rubyonrails.org/classes/Integer.html#method-i-years
[Enumerable#sum]: https://api.rubyonrails.org/classes/Enumerable.html#method-i-sum
[Enumerable#index_by]: https://api.rubyonrails.org/classes/Enumerable.html#method-i-index_by
[Enumerable#index_with]: https://api.rubyonrails.org/classes/Enumerable.html#method-i-index_with
[Enumerable#many?]: https://api.rubyonrails.org/classes/Enumerable.html#method-i-many-3F
[Enumerable#exclude?]: https://api.rubyonrails.org/classes/Enumerable.html#method-i-exclude-3F
[Enumerable#including]: https://api.rubyonrails.org/classes/Enumerable.html#method-i-including
[Enumerable#excluding]: https://api.rubyonrails.org/classes/Enumerable.html#method-i-excluding
[Enumerable#without]: https://api.rubyonrails.org/classes/Enumerable.html#method-i-without
[Enumerable#pluck]: https://api.rubyonrails.org/classes/Enumerable.html#method-i-pluck
[Enumerable#pick]: https://api.rubyonrails.org/classes/Enumerable.html#method-i-pick
[Array#excluding]: https://api.rubyonrails.org/classes/Array.html#method-i-excluding
[Array#fifth]: https://api.rubyonrails.org/classes/Array.html#method-i-fifth
[Array#forty_two]: https://api.rubyonrails.org/classes/Array.html#method-i-forty_two
[Array#fourth]: https://api.rubyonrails.org/classes/Array.html#method-i-fourth
[Array#from]: https://api.rubyonrails.org/classes/Array.html#method-i-from
[Array#including]: https://api.rubyonrails.org/classes/Array.html#method-i-including
[Array#second]: https://api.rubyonrails.org/classes/Array.html#method-i-second
[Array#second_to_last]: https://api.rubyonrails.org/classes/Array.html#method-i-second_to_last
[Array#third]: https://api.rubyonrails.org/classes/Array.html#method-i-third
[Array#third_to_last]: https://api.rubyonrails.org/classes/Array.html#method-i-third_to_last
[Array#to]: https://api.rubyonrails.org/classes/Array.html#method-i-to
[Array#extract!]: https://api.rubyonrails.org/classes/Array.html#method-i-extract-21
[Array#extract_options!]: https://api.rubyonrails.org/classes/Array.html#method-i-extract_options-21
[Array#to_sentence]: https://api.rubyonrails.org/classes/Array.html#method-i-to_sentence
[Array#to_fs]: https://api.rubyonrails.org/classes/Array.html#method-i-to_fs
[Array#to_xml]: https://api.rubyonrails.org/classes/Array.html#method-i-to_xml
[Array.wrap]: https://api.rubyonrails.org/classes/Array.html#method-c-wrap
[Array#deep_dup]: https://api.rubyonrails.org/classes/Array.html#method-i-deep_dup
[Array#in_groups_of]: https://api.rubyonrails.org/classes/Array.html#method-i-in_groups_of
[Array#in_groups]: https://api.rubyonrails.org/classes/Array.html#method-i-in_groups
[Array#split]: https://api.rubyonrails.org/classes/Array.html#method-i-split
[Hash#to_xml]: https://api.rubyonrails.org/classes/Hash.html#method-i-to_xml
[Hash#reverse_merge!]: https://api.rubyonrails.org/classes/Hash.html#method-i-reverse_merge-21
[Hash#reverse_merge]: https://api.rubyonrails.org/classes/Hash.html#method-i-reverse_merge
[Hash#reverse_update]: https://api.rubyonrails.org/classes/Hash.html#method-i-reverse_update
[Hash#deep_merge!]: https://api.rubyonrails.org/classes/Hash.html#method-i-deep_merge-21
[Hash#deep_merge]: https://api.rubyonrails.org/classes/Hash.html#method-i-deep_merge
[Hash#deep_dup]: https://api.rubyonrails.org/classes/Hash.html#method-i-deep_dup
[Hash#except!]: https://api.rubyonrails.org/classes/Hash.html#method-i-except-21
[Hash#except]: https://api.rubyonrails.org/classes/Hash.html#method-i-except
[Hash#deep_stringify_keys!]: https://api.rubyonrails.org/classes/Hash.html#method-i-deep_stringify_keys-21
[Hash#deep_stringify_keys]: https://api.rubyonrails.org/classes/Hash.html#method-i-deep_stringify_keys
[Hash#stringify_keys!]: https://api.rubyonrails.org/classes/Hash.html#method-i-stringify_keys-21
[Hash#stringify_keys]: https://api.rubyonrails.org/classes/Hash.html#method-i-stringify_keys
[Hash#deep_symbolize_keys!]: https://api.rubyonrails.org/classes/Hash.html#method-i-deep_symbolize_keys-21
[Hash#deep_symbolize_keys]: https://api.rubyonrails.org/classes/Hash.html#method-i-deep_symbolize_keys
[Hash#symbolize_keys!]: https://api.rubyonrails.org/classes/Hash.html#method-i-symbolize_keys-21
[Hash#symbolize_keys]: https://api.rubyonrails.org/classes/Hash.html#method-i-symbolize_keys
[Hash#to_options!]: https://api.rubyonrails.org/classes/Hash.html#method-i-to_options-21
[Hash#to_options]: https://api.rubyonrails.org/classes/Hash.html#method-i-to_options
[Hash#assert_valid_keys]: https://api.rubyonrails.org/classes/Hash.html#method-i-assert_valid_keys
[Hash#deep_transform_values!]: https://api.rubyonrails.org/classes/Hash.html#method-i-deep_transform_values-21
[Hash#deep_transform_values]: https://api.rubyonrails.org/classes/Hash.html#method-i-deep_transform_values
[Hash#slice!]: https://api.rubyonrails.org/classes/Hash.html#method-i-slice-21
[Hash#extract!]: https://api.rubyonrails.org/classes/Hash.html#method-i-extract-21
[ActiveSupport::HashWithIndifferentAccess]: https://api.rubyonrails.org/classes/ActiveSupport/HashWithIndifferentAccess.html
[Hash#with_indifferent_access]: https://api.rubyonrails.org/classes/Hash.html#method-i-with_indifferent_access
[Regexp#multiline?]: https://api.rubyonrails.org/classes/Regexp.html#method-i-multiline-3F
[Range#overlap?]: https://api.rubyonrails.org/classes/Range.html#method-i-overlaps-3F
[Date.current]: https://api.rubyonrails.org/classes/Date.html#method-c-current
[Date.tomorrow]: https://api.rubyonrails.org/classes/Date.html#method-c-tomorrow
[Date.yesterday]: https://api.rubyonrails.org/classes/Date.html#method-c-yesterday
[DateAndTime::Calculations#future?]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-future-3F
[DateAndTime::Calculations#on_weekday?]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-on_weekday-3F
[DateAndTime::Calculations#on_weekend?]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-on_weekend-3F
[DateAndTime::Calculations#past?]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-past-3F
[`config.beginning_of_week`]: configuring.html#config-beginning-of-week
[DateAndTime::Calculations#at_beginning_of_week]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-at_beginning_of_week
[DateAndTime::Calculations#at_end_of_week]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-at_end_of_week
[DateAndTime::Calculations#beginning_of_week]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-beginning_of_week
[DateAndTime::Calculations#end_of_week]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-end_of_week
[DateAndTime::Calculations#monday]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-monday
[DateAndTime::Calculations#sunday]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-sunday
[Date.beginning_of_week]: https://api.rubyonrails.org/classes/Date.html#method-c-beginning_of_week
[DateAndTime::Calculations#last_week]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-last_week
[DateAndTime::Calculations#next_week]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-next_week
[DateAndTime::Calculations#prev_week]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-prev_week
[DateAndTime::Calculations#at_beginning_of_month]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-at_beginning_of_month
[DateAndTime::Calculations#at_end_of_month]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-at_end_of_month
[DateAndTime::Calculations#beginning_of_month]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-beginning_of_month
[DateAndTime::Calculations#end_of_month]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-end_of_month
[DateAndTime::Calculations#quarter]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-quarter
[DateAndTime::Calculations#at_beginning_of_quarter]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-at_beginning_of_quarter
[DateAndTime::Calculations#at_end_of_quarter]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-at_end_of_quarter
[DateAndTime::Calculations#beginning_of_quarter]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-beginning_of_quarter
[DateAndTime::Calculations#end_of_quarter]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-end_of_quarter
[DateAndTime::Calculations#at_beginning_of_year]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-at_beginning_of_year
[DateAndTime::Calculations#at_end_of_year]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-at_end_of_year
[DateAndTime::Calculations#beginning_of_year]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-beginning_of_year
[DateAndTime::Calculations#end_of_year]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-end_of_year
[DateAndTime::Calculations#last_year]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-last_year
[DateAndTime::Calculations#years_ago]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-years_ago
[DateAndTime::Calculations#years_since]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-years_since
[DateAndTime::Calculations#last_month]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-last_month
[DateAndTime::Calculations#months_ago]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-months_ago
[DateAndTime::Calculations#months_since]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-months_since
[DateAndTime::Calculations#weeks_ago]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-weeks_ago
[Date#advance]: https://api.rubyonrails.org/classes/Date.html#method-i-advance
[Date#change]: https://api.rubyonrails.org/classes/Date.html#method-i-change
[ActiveSupport::Duration]: https://api.rubyonrails.org/classes/ActiveSupport/Duration.html
[Date#at_beginning_of_day]: https://api.rubyonrails.org/classes/Date.html#method-i-at_beginning_of_day
[Date#at_midnight]: https://api.rubyonrails.org/classes/Date.html#method-i-at_midnight
[Date#beginning_of_day]: https://api.rubyonrails.org/classes/Date.html#method-i-beginning_of_day
[Date#end_of_day]: https://api.rubyonrails.org/classes/Date.html#method-i-end_of_day
[Date#midnight]: https://api.rubyonrails.org/classes/Date.html#method-i-midnight
[DateTime#at_beginning_of_minute]: https://api.rubyonrails.org/classes/DateTime.html#method-i-at_beginning_of_minute
[DateTime#beginning_of_minute]: https://api.rubyonrails.org/classes/DateTime.html#method-i-beginning_of_minute
[DateTime#end_of_minute]: https://api.rubyonrails.org/classes/DateTime.html#method-i-end_of_minute
[Date#ago]: https://api.rubyonrails.org/classes/Date.html#method-i-ago
[Date#since]: https://api.rubyonrails.org/classes/Date.html#method-i-since
[DateTime#ago]: https://api.rubyonrails.org/classes/DateTime.html#method-i-ago
[DateTime#at_beginning_of_day]: https://api.rubyonrails.org/classes/DateTime.html#method-i-at_beginning_of_day
[DateTime#at_beginning_of_hour]: https://api.rubyonrails.org/classes/DateTime.html#method-i-at_beginning_of_hour
[DateTime#at_midnight]: https://api.rubyonrails.org/classes/DateTime.html#method-i-at_midnight
[DateTime#beginning_of_day]: https://api.rubyonrails.org/classes/DateTime.html#method-i-beginning_of_day
[DateTime#beginning_of_hour]: https://api.rubyonrails.org/classes/DateTime.html#method-i-beginning_of_hour
[DateTime#end_of_day]: https://api.rubyonrails.org/classes/DateTime.html#method-i-end_of_day
[DateTime#end_of_hour]: https://api.rubyonrails.org/classes/DateTime.html#method-i-end_of_hour
[DateTime#in]: https://api.rubyonrails.org/classes/DateTime.html#method-i-in
[DateTime#midnight]: https://api.rubyonrails.org/classes/DateTime.html#method-i-midnight
[DateTime.current]: https://api.rubyonrails.org/classes/DateTime.html#method-c-current
[DateTime#seconds_since_midnight]: https://api.rubyonrails.org/classes/DateTime.html#method-i-seconds_since_midnight
[DateTime#getutc]: https://api.rubyonrails.org/classes/DateTime.html#method-i-getutc
[DateTime#utc]: https://api.rubyonrails.org/classes/DateTime.html#method-i-utc
[DateTime#utc?]: https://api.rubyonrails.org/classes/DateTime.html#method-i-utc-3F
[DateTime#advance]: https://api.rubyonrails.org/classes/DateTime.html#method-i-advance
[DateTime#since]: https://api.rubyonrails.org/classes/DateTime.html#method-i-since
[DateTime#change]: https://api.rubyonrails.org/classes/DateTime.html#method-i-change
[Time#ago]: https://api.rubyonrails.org/classes/Time.html#method-i-ago
[Time#change]: https://api.rubyonrails.org/classes/Time.html#method-i-change
[Time#since]: https://api.rubyonrails.org/classes/Time.html#method-i-since
[DateAndTime::Calculations#next_day?]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-next_day-3F
[DateAndTime::Calculations#prev_day?]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-prev_day-3F
[DateAndTime::Calculations#today?]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-today-3F
[DateAndTime::Calculations#tomorrow?]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-tomorrow-3F
[DateAndTime::Calculations#yesterday?]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-yesterday-3F
[DateAndTime::Calculations#all_day]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-all_day
[DateAndTime::Calculations#all_month]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-all_month
[DateAndTime::Calculations#all_quarter]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-all_quarter
[DateAndTime::Calculations#all_week]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-all_week
[DateAndTime::Calculations#all_year]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-all_year
[Time.current]: https://api.rubyonrails.org/classes/Time.html#method-c-current
[Time#next_day]: https://api.rubyonrails.org/classes/Time.html#method-i-next_day
[Time#prev_day]: https://api.rubyonrails.org/classes/Time.html#method-i-prev_day
[Time#next_month]: https://api.rubyonrails.org/classes/Time.html#method-i-next_month
[Time#prev_month]: https://api.rubyonrails.org/classes/Time.html#method-i-prev_month
[Time#next_year]: https://api.rubyonrails.org/classes/Time.html#method-i-next_year
[Time#prev_year]: https://api.rubyonrails.org/classes/Time.html#method-i-prev_year
[DateAndTime::Calculations#last_quarter]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-last_quarter
[DateAndTime::Calculations#next_quarter]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-next_quarter
[DateAndTime::Calculations#prev_quarter]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-prev_quarter
[File.atomic_write]: https://api.rubyonrails.org/classes/File.html#method-c-atomic_write
[NameError#missing_name?]: https://api.rubyonrails.org/classes/NameError.html#method-i-missing_name-3F
[LoadError#is_missing?]: https://api.rubyonrails.org/classes/LoadError.html#method-i-is_missing-3F
[Pathname#existence]: https://api.rubyonrails.org/classes/Pathname.html#method-i-existence
