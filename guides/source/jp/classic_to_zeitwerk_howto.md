**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 9c6201fd526077579ef792e0c4e2150d
ClassicからZeitwerkへの移行のHOWTO
=========================

このガイドでは、Railsアプリケーションを「classic」から「zeitwerk」モードに移行する方法について説明します。

このガイドを読み終えると、以下のことがわかります。

* 「classic」と「zeitwerk」モードとは何か
* 「classic」から「zeitwerk」に切り替える理由
* 「zeitwerk」モードをアクティベートする方法
* アプリケーションが「zeitwerk」モードで実行されていることを確認する方法
* コマンドラインでプロジェクトが正常に読み込まれることを確認する方法
* テストスイートでプロジェクトが正常に読み込まれることを確認する方法
* 可能なエッジケースに対処する方法
* Zeitwerkで利用できる新機能

--------------------------------------------------------------------------------

「classic」と「zeitwerk」モードとは何ですか？
--------------------------------------------------------

Railsは初めからRails 5まで、Active Supportで実装されたオートローダーを使用していました。このオートローダーは「classic」として知られ、Rails 6.xでも使用できます。ただし、Rails 7にはこのオートローダーは含まれていません。

Rails 6以降、Railsには新しくてより優れた自動ロードの方法が搭載され、[Zeitwerk](https://github.com/fxn/zeitwerk)ジェムに委譲されます。これが「zeitwerk」モードです。デフォルトでは、6.0および6.1のフレームワークデフォルトをロードするアプリケーションは「zeitwerk」モードで実行され、Rails 7ではこのモードのみが利用可能です。


なぜ「classic」から「zeitwerk」に切り替える必要がありますか？
----------------------------------------

「classic」オートローダーは非常に便利でしたが、時々オートロードが少しトリッキーで混乱する[問題](https://guides.rubyonrails.org/v6.1/autoloading_and_reloading_constants_classic_mode.html#common-gotchas)がありました。Zeitwerkは、これを解決するために開発されました。その他の[動機](https://github.com/fxn/zeitwerk#motivation)もあります。

Rails 6.xにアップグレードする際は、`zeitwerk`モードに切り替えることを強くお勧めします。`classic`モードは非推奨です。

Rails 7では、移行期間が終了し、「classic」モードは含まれていません。

心配しないでください。
-----------

心配しないでください :).

Zeitwerkは、できるだけ「classic」オートローダーと互換性があるように設計されています。現在正常にオートロードされている動作中のアプリケーションがある場合、切り替えは簡単になる可能性があります。多くのプロジェクトが、スムーズな切り替えを報告しています。

このガイドは、自信を持ってオートローダーを変更するのに役立ちます。

何らかの理由で解決方法がわからない状況に遭遇した場合は、[`rails/rails`で問題を開く](https://github.com/rails/rails/issues/new)ことをためらわず、[`@fxn`](https://github.com/fxn)をタグ付けしてください。


「zeitwerk」モードをアクティベートする方法
-------------------------------

### Rails 5.x以前のアプリケーション

Rails 6.0より前のバージョンのアプリケーションでは、「zeitwerk」モードは利用できません。少なくともRails 6.0である必要があります。

### Rails 6.xで実行されているアプリケーション

Rails 6.xで実行されているアプリケーションには2つのシナリオがあります。

アプリケーションがRails 6.0または6.1のフレームワークデフォルトをロードしており、「classic」モードで実行されている場合、手動でオプトアウトする必要があります。次のような設定が必要です。

```ruby
# config/application.rb
config.load_defaults 6.0
config.autoloader = :classic # この行を削除
```

上記のように、オーバーライドを削除するだけで、「zeitwerk」モードがデフォルトになります。

一方、アプリケーションが古いフレームワークデフォルトをロードしている場合は、「zeitwerk」モードを明示的に有効にする必要があります。

```ruby
# config/application.rb
config.load_defaults 5.2
config.autoloader = :zeitwerk
```

### Rails 7で実行されているアプリケーション

Rails 7では、「zeitwerk」モードのみが利用可能であり、有効にするための特別な設定は必要ありません。

実際、Rails 7では、setter `config.autoloader=` は存在しません。もし `config/application.rb` で使用している場合は、その行を削除してください。


アプリケーションが「zeitwerk」モードで実行されていることを確認する方法は？
------------------------------------------------------

アプリケーションが「zeitwerk」モードで実行されていることを確認するには、次のコマンドを実行します。

```
bin/rails runner 'p Rails.autoloaders.zeitwerk_enabled?'
```

これが `true` を出力する場合、`zeitwerk`モードが有効になっています。


アプリケーションがZeitwerkの規約に準拠しているかどうかは？
-----------------------------------------------------

### config.eager_load_paths

準拠テストは、イーガーロードされたファイルのみで実行されます。したがって、Zeitwerkの準拠性を確認するためには、すべてのオートロードパスをイーガーロードパスに含めることをお勧めします。

これはデフォルトで既に行われていますが、プロジェクトにカスタムのオートロードパスが設定されている場合は、次のようになります。

```ruby
config.autoload_paths << "#{Rails.root}/extras"
```

これらはイーガーロードされず、検証されません。イーガーロードパスに追加するのは簡単です。

```ruby
config.autoload_paths << "#{Rails.root}/extras"
config.eager_load_paths << "#{Rails.root}/extras"
```

### zeitwerk:check

「zeitwerk」モードが有効になり、イーガーロードパスの設定が再確認されたら、次のコマンドを実行してください。

```
bin/rails zeitwerk:check
```

成功した場合、次のように表示されます。

```
% bin/rails zeitwerk:check
Hold on, I am eager loading the application.
All is good!
```

アプリケーションの設定によっては、追加の出力がある場合がありますが、最後の "All is good!" が表示されれば問題ありません。
前のセクションで説明したダブルチェックが、実際にはイーガーロードパスの外にいくつかのカスタムオートロードパスが必要であることを確認した場合、このタスクはそれらを検出して警告します。ただし、テストスイートがこれらのファイルを正常にロードする場合は問題ありません。

次に、期待される定数を定義していないファイルがある場合、このタスクはそれを通知します。これは1つのファイルずつ行われます。なぜなら、1つのファイルのロードの失敗が他のチェックとは関係のない他の失敗に連鎖する可能性があり、エラーレポートが混乱するからです。

1つの定数が報告された場合、その特定の定数を修正して再度タスクを実行します。"All is good!"と表示されるまで繰り返します。

例えば、以下のようにします：

```
% bin/rails zeitwerk:check
Hold on, I am eager loading the application.
expected file app/models/vat.rb to define constant Vat
```

VATはヨーロッパの税金です。ファイル`app/models/vat.rb`は`VAT`を定義していますが、オートローダーは`Vat`を期待しているため、なぜですか？

### アクロニム

これは最も一般的な不一致の種類であり、アクロニムに関連しています。なぜこのエラーメッセージが表示されるのかを理解しましょう。

古典的なオートローダーは、欠落している定数の名前である`VAT`を自動ロードできます。`VAT`に`underscore`を適用すると`vat`が得られ、`vat.rb`という名前のファイルを探します。これは機能します。

新しいオートローダーの入力はファイルシステムです。`vat.rb`というファイルが与えられた場合、Zeitwerkは`vat`に対して`camelize`を呼び出し、`Vat`を得て、そのファイルが定数`Vat`を定義することを期待します。これがエラーメッセージの内容です。

これを修正するには、インフレクターにこのアクロニムについて教えるだけです：

```ruby
# config/initializers/inflections.rb
ActiveSupport::Inflector.inflections(:en) do |inflect|
  inflect.acronym "VAT"
end
```

これにより、Active Supportがグローバルにインフレクトする方法が変わります。これは問題ないかもしれませんが、オートローダーで使用されるインフレクターにオーバーライドを渡すこともできます：

```ruby
# config/initializers/zeitwerk.rb
Rails.autoloaders.main.inflector.inflect("vat" => "VAT")
```

このオプションを使用すると、`vat.rb`という名前のファイルまたは`vat`という名前のディレクトリのみが`VAT`としてインフレクトされます。`vat_rules.rb`という名前のファイルは影響を受けず、`VatRules`を正常に定義することができます。プロジェクトにこのような命名の不一致がある場合に便利です。

これを設定すると、チェックがパスします！

```
% bin/rails zeitwerk:check
Hold on, I am eager loading the application.
All is good!
```

すべてが正常になったら、プロジェクトをテストスイートで検証し続けることをお勧めします。[_Check Zeitwerk Compliance in the Test Suite_](#check-zeitwerk-compliance-in-the-test-suite)セクションでは、これを行う方法について説明しています。

### コンサーン

`concerns`のサブディレクトリを使用して、標準の構造からオートロードおよびイーガーロードすることができます。例えば、

```
app/models
app/models/concerns
```

デフォルトでは、`app/models/concerns`はオートロードパスに属しているため、ルートディレクトリと見なされます。したがって、デフォルトでは、`app/models/concerns/foo.rb`は`Concerns::Foo`ではなく`Foo`を定義する必要があります。

アプリケーションが`Concerns`を名前空間として使用する場合、2つのオプションがあります：

1. それらのクラスとモジュールから`Concerns`名前空間を削除し、クライアントコードを更新します。
2. `app/models/concerns`をオートロードパスから削除して、現状のままにします：

  ```ruby
  # config/initializers/zeitwerk.rb
  ActiveSupport::Dependencies.
    autoload_paths.
    delete("#{Rails.root}/app/models/concerns")
  ```

### `app`をオートロードパスに含める

一部のプロジェクトでは、`app/api/base.rb`のように`API::Base`を定義するために`app`をオートロードパスに追加したい場合があります。

Railsは`app`のすべてのサブディレクトリを自動的にオートロードパスに追加します（一部の例外を除く）。そのため、`app/models/concerns`と同様に、ネストされたルートディレクトリが存在する状況が発生します。このセットアップはそのままでは機能しません。

ただし、その構造を維持することができます。ただし、イニシャライザで`app/api`をオートロードパスから削除するだけです：

```ruby
# config/initializers/zeitwerk.rb
ActiveSupport::Dependencies.
  autoload_paths.
  delete("#{Rails.root}/app/api")
```

オートロード/イーガーロードするファイルがないサブディレクトリに注意してください。例えば、アプリケーションには[ActiveAdmin](https://activeadmin.info/)のリソースがある`app/admin`がある場合、それらを無視する必要があります。`assets`や関連するディレクトリも同様です：

```ruby
# config/initializers/zeitwerk.rb
Rails.autoloaders.main.ignore(
  "app/admin",
  "app/assets",
  "app/javascripts",
  "app/views"
)
```

この設定がないと、アプリケーションはこれらのツリーをイーガーロードしようとします。ファイルが定数を定義していないため`app/admin`でエラーが発生し、副作用として`Views`モジュールを定義します。

`app`をオートロードパスに含めることは技術的に可能ですが、少しトリッキーです。

### オートロードされた定数と明示的な名前空間

ファイル内で名前空間が`Hotel`として定義されている場合、以下のようになります：
```
app/models/hotel.rb         # ホテルを定義します。
app/models/hotel/pricing.rb # Hotel::Pricingを定義します。

```

`Hotel`定数は、`class`または`module`キーワードを使用して設定する必要があります。例えば:

```ruby
class Hotel
end
```

が良いです。

以下のような代替手段は機能しません。

```ruby
Hotel = Class.new
```

または

```ruby
Hotel = Struct.new
```

この制限は、明示的な名前空間にのみ適用されます。名前空間を定義しないクラスやモジュールは、これらのイディオムを使用して定義することができます。

### 1ファイルに1つの定数（同じトップレベル）

`classic`モードでは、同じトップレベルで複数の定数を定義し、それらをすべてリロードすることができます。例えば、次のような場合です。

```ruby
# app/models/foo.rb

class Foo
end

class Bar
end
```

`Bar`は自動読み込みされませんが、`Foo`を自動読み込みすると、`Bar`も自動読み込みされます。

これは`zeitwerk`モードでは適用されません。`Bar`を独自のファイル`bar.rb`に移動する必要があります。1つのファイルに1つのトップレベル定数。

これは、上記の例の同じトップレベルの定数にのみ影響します。内部クラスやモジュールは問題ありません。例えば、次のような場合を考えてみてください。

```ruby
# app/models/foo.rb

class Foo
  class InnerClass
  end
end
```

アプリケーションが`Foo`をリロードすると、`Foo::InnerClass`もリロードされます。

### `config.autoload_paths`のグロブ

次のようなワイルドカードを使用した設定に注意してください。

```ruby
config.autoload_paths += Dir["#{config.root}/extras/**/"]
```

`config.autoload_paths`の各要素は、トップレベルの名前空間（`Object`）を表す必要があります。これは機能しません。

これを修正するには、ワイルドカードを削除するだけです。

```ruby
config.autoload_paths << "#{config.root}/extras"
```

### エンジンからのクラスとモジュールのデコレーション

アプリケーションがエンジンからクラスやモジュールをデコレートしている場合、おそらくどこかで次のようなことを行っています。

```ruby
config.to_prepare do
  Dir.glob("#{Rails.root}/app/overrides/**/*_override.rb").sort.each do |override|
    require_dependency override
  end
end
```

これを更新する必要があります。`main`オートローダーにオーバーライドのディレクトリを無視するように指示し、`load`を使用してそれらをロードする必要があります。次のようなものです。

```ruby
overrides = "#{Rails.root}/app/overrides"
Rails.autoloaders.main.ignore(overrides)
config.to_prepare do
  Dir.glob("#{overrides}/**/*_override.rb").sort.each do |override|
    load override
  end
end
```

### `before_remove_const`

Rails 3.1では、クラスまたはモジュールがこのメソッドに応答し、リロードされる予定の場合に呼び出される`before_remove_const`というコールバックがサポートされました。このコールバックは他の方法では文書化されておらず、おそらくコードで使用していないでしょう。

ただし、もし使用している場合は、次のように書き換えることができます。

```ruby
class Country < ActiveRecord::Base
  def self.before_remove_const
    expire_redis_cache
  end
end
```

次のようにします。

```ruby
# config/initializers/country.rb
if Rails.application.config.reloading_enabled?
  Rails.autoloaders.main.on_unload("Country") do |klass, _abspath|
    klass.expire_redis_cache
  end
end
```

### Springと`test`環境

Springは、何か変更があるとアプリケーションコードをリロードします。`test`環境では、それが機能するためにリロードを有効にする必要があります。

```ruby
# config/environments/test.rb
config.cache_classes = false
```

または、Rails 7.1以降:

```ruby
# config/environments/test.rb
config.enable_reloading = true
```

そうしないと、次のようなエラーが発生します。

```
reloading is disabled because config.cache_classes is true
```

または

```
reloading is disabled because config.enable_reloading is false
```

これにはパフォーマンスのペナルティはありません。

### Bootsnap

必ず少なくともBootsnap 1.4.4に依存していることを確認してください。


テストスイートでZeitwerkの準拠をチェックする
-------------------------------------------

`zeitwerk:check`タスクは、マイグレーション中に便利です。プロジェクトが準拠している場合、このチェックを自動化することをお勧めします。そのためには、アプリケーションをイーガーロードするだけで十分です。

### 継続的インテグレーション

プロジェクトに継続的インテグレーションがある場合、テストスイートが実行されるときにアプリケーションをイーガーロードすることが良いアイデアです。アプリケーションが何らかの理由でイーガーロードできない場合、本番よりもCIで知ることができます。

CIは通常、テストスイートが実行されていることを示すためにいくつかの環境変数を設定します。例えば、`CI`という名前の変数になるかもしれません。

```ruby
# config/environments/test.rb
config.eager_load = ENV["CI"].present?
```

Rails 7以降、新しく生成されたアプリケーションはデフォルトでこのように設定されています。

### ベアなテストスイート

プロジェクトに継続的インテグレーションがない場合、`Rails.application.eager_load!`を呼び出すことでテストスイートでイーガーロードすることができます。

#### Minitest

```ruby
require "test_helper"

class ZeitwerkComplianceTest < ActiveSupport::TestCase
  test "eager loads all files without errors" do
    assert_nothing_raised { Rails.application.eager_load! }
  end
end
```

#### RSpec

```ruby
require "rails_helper"

RSpec.describe "Zeitwerk compliance" do
  it "eager loads all files without errors" do
    expect { Rails.application.eager_load! }.not_to raise_error
  end
end
```

`require`の呼び出しを削除してください
-----------------------------------

私の経験では、プロジェクトでは一般的にこれを行いません。しかし、いくつかのプロジェクトではこれを行っているのを見たことがあり、他のいくつかのプロジェクトでも聞いたことがあります。
Railsアプリケーションでは、`lib`からのコードやgemの依存関係、標準ライブラリなど、サードパーティからのコードを読み込むために`require`を使用します。**決してautoload可能なアプリケーションコードを`require`で読み込まないでください**。`classic`の[こちら](https://guides.rubyonrails.org/v6.1/autoloading_and_reloading_constants_classic_mode.html#autoloading-and-require)で、なぜこれが悪いアイデアであるかをすでに確認してください。

```ruby
require "nokogiri" # 良い例
require "net/http" # 良い例
require "user"     # 悪い例、削除してください（app/models/user.rbを想定）
```

このような`require`呼び出しを削除してください。

利用できる新機能
-----------------

### `require_dependency`呼び出しの削除

Zeitwerkでは、`require_dependency`のすべての使用例が削除されています。プロジェクトをgrepして、これらの呼び出しを削除してください。

アプリケーションがSingle Table Inheritanceを使用している場合は、Autoloading and Reloading Constants（Zeitwerkモード）ガイドの[Single Table Inheritanceセクション](autoloading_and_reloading_constants.html#single-table-inheritance)を参照してください。

### クラスとモジュール定義での修飾名の使用

クラスとモジュール定義で定数パスを堅牢に使用できるようになりました。

```ruby
# このクラス本体でのAutoloadingは、Rubyのセマンティクスに合致します。
class Admin::UsersController < ApplicationController
  # ...
end
```

注意点として、実行順によっては、クラシックなオートローダーは次のような場合に`Foo::Wadus`をオートロードできることがあります。

```ruby
class Foo::Bar
  Wadus
end
```

これはRubyのセマンティクスに合致していないため、`zeitwerk`モードではまったく機能しません。このような特殊なケースがある場合は、修飾名`Foo::Wadus`を使用するか、ネストに`Foo`を追加してください。

```ruby
class Foo::Bar
  Foo::Wadus
end
```

または、ネストに`Foo`を追加してください。

```ruby
module Foo
  class Bar
    Wadus
  end
end
```

### スレッドセーフ

`classic`モードでは、定数のオートロードはスレッドセーフではありませんが、Railsにはウェブリクエストのスレッドセーフを実現するためのロックがあります。

`zeitwerk`モードでは、定数のオートロードはスレッドセーフです。たとえば、`runner`コマンドで実行されるマルチスレッドのスクリプトでオートロードを行うことができます。

### イーガーローディングとオートローディングの一貫性

`classic`モードでは、`app/models/foo.rb`が`Bar`を定義している場合、そのファイルをオートロードすることはできませんが、イーガーローディングは再帰的にファイルを読み込むため、動作します。これは、最初にイーガーローディングでテストを行った場合、後でオートローディングで実行が失敗する可能性があるため、エラーの原因になることがあります。

`zeitwerk`モードでは、両方のローディングモードが一貫しており、同じファイルで失敗し、エラーが発生します。
