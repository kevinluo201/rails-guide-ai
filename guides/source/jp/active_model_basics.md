**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: cee957545ee75801aab30265bc416992
Active Modelの基礎
===================

このガイドでは、モデルクラスの使用を開始するために必要なすべての情報を提供します。Active Modelは、Action PackヘルパーがプレーンなRubyオブジェクトと対話することを可能にします。Active Modelはまた、Railsフレームワークの外部で使用するためのカスタムORMの構築を支援します。

このガイドを読み終えると、以下のことがわかります。

* Active Recordモデルの動作方法。
* コールバックとバリデーションの仕組み。
* シリアライザの動作方法。
* Active ModelがRailsの国際化（i18n）フレームワークと統合する方法。

--------------------------------------------------------------------------------

Active Modelとは何ですか？
---------------------

Active Modelは、Active Recordに存在するいくつかの機能を必要とするクラスの開発に使用されるさまざまなモジュールを含むライブラリです。
以下に、これらのモジュールのいくつかを説明します。

### API

`ActiveModel::API`は、クラスがAction PackとAction Viewと直接連携できる機能を追加します。

```ruby
class EmailContact
  include ActiveModel::API

  attr_accessor :name, :email, :message
  validates :name, :email, :message, presence: true

  def deliver
    if valid?
      # メールを送信する
    end
  end
end
```

`ActiveModel::API`を含めると、以下のような機能が提供されます。

- モデル名の内部調査
- 変換
- 翻訳
- バリデーション

また、Active Recordオブジェクトと同様に、属性のハッシュでオブジェクトを初期化することもできます。

```irb
irb> email_contact = EmailContact.new(name: 'David', email: 'david@example.com', message: 'Hello World')
irb> email_contact.name
=> "David"
irb> email_contact.email
=> "david@example.com"
irb> email_contact.valid?
=> true
irb> email_contact.persisted?
=> false
```

`ActiveModel::API`を含む任意のクラスは、Active Recordオブジェクトと同様に`form_with`、`render`、その他のAction Viewヘルパーメソッドと一緒に使用することができます。

### 属性メソッド

`ActiveModel::AttributeMethods`モジュールは、クラスのメソッドにカスタムの接頭辞と接尾辞を追加することができます。これは、接頭辞と接尾辞を定義し、オブジェクトのどのメソッドがそれらを使用するかを定義することで使用されます。

```ruby
class Person
  include ActiveModel::AttributeMethods

  attribute_method_prefix 'reset_'
  attribute_method_suffix '_highest?'
  define_attribute_methods 'age'

  attr_accessor :age

  private
    def reset_attribute(attribute)
      send("#{attribute}=", 0)
    end

    def attribute_highest?(attribute)
      send(attribute) > 100
    end
end
```

```irb
irb> person = Person.new
irb> person.age = 110
irb> person.age_highest?
=> true
irb> person.reset_age
=> 0
irb> person.age_highest?
=> false
```

### コールバック

`ActiveModel::Callbacks`は、Active Recordスタイルのコールバックを提供します。これにより、適切なタイミングで実行されるコールバックを定義することができます。
コールバックを定義した後、それらをbefore、after、aroundのカスタムメソッドでラップすることができます。

```ruby
class Person
  extend ActiveModel::Callbacks

  define_model_callbacks :update

  before_update :reset_me

  def update
    run_callbacks(:update) do
      # このメソッドはオブジェクトに対してupdateが呼び出されたときに実行されます。
    end
  end

  def reset_me
    # このメソッドはオブジェクトに対してupdateが呼び出されたときにbefore_updateコールバックとして定義されたときに実行されます。
  end
end
```

### 変換

クラスが`persisted?`メソッドと`id`メソッドを定義している場合、そのクラスに`ActiveModel::Conversion`モジュールを含めることができ、そのクラスのオブジェクトでRailsの変換メソッドを呼び出すことができます。

```ruby
class Person
  include ActiveModel::Conversion

  def persisted?
    false
  end

  def id
    nil
  end
end
```

```irb
irb> person = Person.new
irb> person.to_model == person
=> true
irb> person.to_key
=> nil
irb> person.to_param
=> nil
```

### Dirty

オブジェクトは、属性に対して1つ以上の変更を経験し、保存されていない場合にDirtyになります。`ActiveModel::Dirty`は、オブジェクトが変更されたかどうかを確認する機能を提供します。また、属性ベースのアクセサメソッドも持っています。`first_name`と`last_name`という属性を持つPersonクラスを考えてみましょう。

```ruby
class Person
  include ActiveModel::Dirty
  define_attribute_methods :first_name, :last_name

  def first_name
    @first_name
  end

  def first_name=(value)
    first_name_will_change!
    @first_name = value
  end

  def last_name
    @last_name
  end

  def last_name=(value)
    last_name_will_change!
    @last_name = value
  end

  def save
    # 保存作業を行う...
    changes_applied
  end
end
```

#### オブジェクトの変更された属性のリストを直接クエリする

```irb
irb> person = Person.new
irb> person.changed?
=> false

irb> person.first_name = "First Name"
irb> person.first_name
=> "First Name"

# いずれかの属性に未保存の変更がある場合はtrueを返します。
irb> person.changed?
=> true

# 保存前に変更された属性のリストを返します。
irb> person.changed
=> ["first_name"]

# 変更された属性とその元の値のハッシュを返します。
irb> person.changed_attributes
=> {"first_name"=>nil}

# 属性の変更のハッシュを返します。キーは属性名で、値はそのフィールドの古い値と新しい値の配列です。
irb> person.changes
=> {"first_name"=>[nil, "First Name"]}
```

#### 属性ベースのアクセサメソッド

特定の属性が変更されたかどうかを追跡します。
```irb
irb> person.first_name
=> "名前"

# attr_name_changed?
irb> person.first_name_changed?
=> true
```

属性の以前の値を追跡します。

```irb
# attr_name_was accessor
irb> person.first_name_was
=> nil
```

変更された属性の以前と現在の値を追跡します。変更された場合は配列を返し、それ以外の場合はnilを返します。

```irb
# attr_name_change
irb> person.first_name_change
=> [nil, "名前"]
irb> person.last_name_change
=> nil
```

### バリデーション

`ActiveModel::Validations`モジュールは、Active Recordのようにオブジェクトをバリデーションする機能を追加します。

```ruby
class Person
  include ActiveModel::Validations

  attr_accessor :name, :email, :token

  validates :name, presence: true
  validates_format_of :email, with: /\A([^\s]+)((?:[-a-z0-9]\.)[a-z]{2,})\z/i
  validates! :token, presence: true
end
```

```irb
irb> person = Person.new
irb> person.token = "2b1f325"
irb> person.valid?
=> false
irb> person.name = 'vishnu'
irb> person.email = 'me'
irb> person.valid?
=> false
irb> person.email = 'me@vishnuatrai.com'
irb> person.valid?
=> true
irb> person.token = nil
irb> person.valid?
ActiveModel::StrictValidationFailed
```

### 名前付け

`ActiveModel::Naming`は、名前付けとルーティングを管理しやすくするためのいくつかのクラスメソッドを追加します。このモジュールは、いくつかの`ActiveSupport::Inflector`メソッドを使用していくつかのアクセサを定義する`model_name`クラスメソッドを定義します。

```ruby
class Person
  extend ActiveModel::Naming
end

Person.model_name.name                # => "Person"
Person.model_name.singular            # => "person"
Person.model_name.plural              # => "people"
Person.model_name.element             # => "person"
Person.model_name.human               # => "Person"
Person.model_name.collection          # => "people"
Person.model_name.param_key           # => "person"
Person.model_name.i18n_key            # => :person
Person.model_name.route_key           # => "people"
Person.model_name.singular_route_key  # => "person"
```

### モデル

`ActiveModel::Model`を使用すると、`ActiveRecord::Base`に似たモデルを実装できます。

```ruby
class EmailContact
  include ActiveModel::Model

  attr_accessor :name, :email, :message
  validates :name, :email, :message, presence: true

  def deliver
    if valid?
      # deliver email
    end
  end
end
```

`ActiveModel::Model`を含めると、`ActiveModel::API`のすべての機能が使用できます。

### シリアライズ

`ActiveModel::Serialization`は、オブジェクトの基本的なシリアライズを提供します。シリアライズしたい属性を含む属性ハッシュを宣言する必要があります。属性はシンボルではなく文字列である必要があります。

```ruby
class Person
  include ActiveModel::Serialization

  attr_accessor :name

  def attributes
    { 'name' => nil }
  end
end
```

`serializable_hash`メソッドを使用して、オブジェクトのシリアライズされたハッシュにアクセスできます。

```irb
irb> person = Person.new
irb> person.serializable_hash
=> {"name"=>nil}
irb> person.name = "Bob"
irb> person.serializable_hash
=> {"name"=>"Bob"}
```

#### ActiveModel::Serializers

Active Modelは、JSONのシリアライズ/デシリアライズのための`ActiveModel::Serializers::JSON`モジュールも提供します。このモジュールは、先に説明した`ActiveModel::Serialization`モジュールも自動的に含まれます。

##### ActiveModel::Serializers::JSON

`ActiveModel::Serializers::JSON`を使用するには、含めるモジュールを`ActiveModel::Serialization`から`ActiveModel::Serializers::JSON`に変更するだけです。

```ruby
class Person
  include ActiveModel::Serializers::JSON

  attr_accessor :name

  def attributes
    { 'name' => nil }
  end
end
```

`as_json`メソッドは、`serializable_hash`と同様に、モデルを表すハッシュを提供します。

```irb
irb> person = Person.new
irb> person.as_json
=> {"name"=>nil}
irb> person.name = "Bob"
irb> person.as_json
=> {"name"=>"Bob"}
```

また、JSON文字列からモデルの属性を定義することもできます。ただし、クラスに`attributes=`メソッドを定義する必要があります。

```ruby
class Person
  include ActiveModel::Serializers::JSON

  attr_accessor :name

  def attributes=(hash)
    hash.each do |key, value|
      send("#{key}=", value)
    end
  end

  def attributes
    { 'name' => nil }
  end
end
```

これで、`Person`のインスタンスを作成し、`from_json`を使用して属性を設定することができます。

```irb
irb> json = { name: 'Bob' }.to_json
irb> person = Person.new
irb> person.from_json(json)
=> #<Person:0x00000100c773f0 @name="Bob">
irb> person.name
=> "Bob"
```

### 翻訳

`ActiveModel::Translation`は、オブジェクトとRailsの国際化（i18n）フレームワークとの統合を提供します。

```ruby
class Person
  extend ActiveModel::Translation
end
```

`human_attribute_name`メソッドを使用すると、属性名をより人間に読みやすい形式に変換できます。人間に読みやすい形式は、ロケールファイルで定義されます。

* config/locales/app.pt-BR.yml

```yaml
pt-BR:
  activemodel:
    attributes:
      person:
        name: 'Nome'
```

```ruby
Person.human_attribute_name('name') # => "Nome"
```

### Lintテスト

`ActiveModel::Lint::Tests`を使用すると、オブジェクトがActive Model APIに準拠しているかどうかをテストできます。

* `app/models/person.rb`

    ```ruby
    class Person
      include ActiveModel::Model
    end
    ```

* `test/models/person_test.rb`

    ```ruby
    require "test_helper"

    class PersonTest < ActiveSupport::TestCase
      include ActiveModel::Lint::Tests

      setup do
        @model = Person.new
      end
    end
    ```

```bash
$ bin/rails test

Run options: --seed 14596

# Running:

......

Finished in 0.024899s, 240.9735 runs/s, 1204.8677 assertions/s.

6 runs, 30 assertions, 0 failures, 0 errors, 0 skips
```

Action Packで動作するためには、すべてのAPIを実装する必要はありません。このモジュールは、すべての機能を提供するためのガイドとしてのみ使用されます。

### SecurePassword

`ActiveModel::SecurePassword`を使用すると、任意のパスワードを安全に暗号化して保存する方法が提供されます。このモジュールを含めると、デフォルトで`password`アクセサに特定のバリデーションが定義された`has_secure_password`クラスメソッドが提供されます。
#### 要件

`ActiveModel::SecurePassword`は[`bcrypt`](https://github.com/codahale/bcrypt-ruby 'BCrypt')に依存しているため、`ActiveModel::SecurePassword`を正しく使用するためには、`Gemfile`にこのgemを含める必要があります。
これを動作させるためには、モデルに`XXX_digest`という名前のアクセサを持つ必要があります。
ここで、`XXX`は希望するパスワードの属性名です。
以下のバリデーションが自動的に追加されます：

1. パスワードは必須です。
2. パスワードは確認用のパスワードと一致している必要があります（`XXX_confirmation`が渡された場合）。
3. パスワードの最大長は72です（ActiveModel::SecurePasswordが依存する`bcrypt`によって要求されます）。

#### 例

```ruby
class Person
  include ActiveModel::SecurePassword
  has_secure_password
  has_secure_password :recovery_password, validations: false

  attr_accessor :password_digest, :recovery_password_digest
end
```

```irb
irb> person = Person.new

# パスワードが空の場合
irb> person.valid?
=> false

# 確認用パスワードがパスワードと一致しない場合
irb> person.password = 'aditya'
irb> person.password_confirmation = 'nomatch'
irb> person.valid?
=> false

# パスワードの長さが72を超える場合
irb> person.password = person.password_confirmation = 'a' * 100
irb> person.valid?
=> false

# パスワードのみが提供され、パスワード確認がない場合
irb> person.password = 'aditya'
irb> person.valid?
=> true

# すべてのバリデーションがパスした場合
irb> person.password = person.password_confirmation = 'aditya'
irb> person.valid?
=> true

irb> person.recovery_password = "42password"

irb> person.authenticate('aditya')
=> #<Person> # == person
irb> person.authenticate('notright')
=> false
irb> person.authenticate_password('aditya')
=> #<Person> # == person
irb> person.authenticate_password('notright')
=> false

irb> person.authenticate_recovery_password('42password')
=> #<Person> # == person
irb> person.authenticate_recovery_password('notright')
=> false

irb> person.password_digest
=> "$2a$04$gF8RfZdoXHvyTjHhiU4ZsO.kQqV9oonYZu31PRE4hLQn3xM2qkpIy"
irb> person.recovery_password_digest
=> "$2a$04$iOfhwahFymCs5weB3BNH/uXkTG65HR.qpW.bNhEjFP3ftli3o5DQC"
```
