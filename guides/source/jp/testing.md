**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 6da9945dc313b748574b8aca256f1435
Railsアプリケーションのテスト
==========================

このガイドでは、Railsに組み込まれたアプリケーションのテストのための機能について説明します。

このガイドを読み終えると、以下のことがわかるようになります：

* Railsのテスト用語。
* アプリケーションのためのユニットテスト、機能テスト、統合テスト、システムテストの書き方。
* 他の人気のあるテスト手法やプラグイン。

--------------------------------------------------------------------------------

なぜRailsアプリケーションのテストを書くのか？
--------------------------------------------

Railsでは、テストの書き方が非常に簡単です。モデルやコントローラを作成する際に、スケルトンのテストコードが生成されます。

Railsのテストを実行することで、コードが望ましい機能を満たしていることを確認できます。特に、大規模なコードのリファクタリング後でも機能が保持されていることを確認できます。

Railsのテストは、ブラウザのテストを行わずにアプリケーションの応答をシミュレートすることもできます。

テストの紹介
-----------------------

テストのサポートは、Railsの設計に最初から組み込まれていました。それは「新しくてクールだからテストの実行サポートを追加しよう」というようなものではありませんでした。

### Railsは最初からテストのために設定されています

Railsプロジェクトを`rails new`コマンドで作成すると、`test`ディレクトリが自動的に作成されます。このディレクトリの内容をリストアップすると、次のようになります：

```bash
$ ls -F test
application_system_test_case.rb  controllers/                     helpers/                         mailers/                         system/
channels/                        fixtures/                        integration/                     models/                          test_helper.rb
```

`helpers`、`mailers`、`models`ディレクトリは、それぞれビューヘルパー、メーラー、モデルのテストを格納するためのものです。`channels`ディレクトリは、Action Cableの接続とチャンネルのテストを格納するためのものです。`controllers`ディレクトリは、コントローラ、ルート、ビューのテストを格納するためのものです。`integration`ディレクトリは、コントローラ間の相互作用のテストを格納するためのものです。

システムテストディレクトリには、アプリケーションのフルブラウザテストに使用されるシステムテストが格納されます。システムテストでは、ユーザーがアプリケーションを体験する方法でアプリケーションをテストすることができ、JavaScriptのテストもサポートされます。システムテストはCapybaraから継承しており、アプリケーションのブラウザテストを実行します。

フィクスチャはテストデータを整理するための方法で、`fixtures`ディレクトリに格納されます。

関連するテストが最初に生成されたときには、`jobs`ディレクトリも作成されます。

`test_helper.rb`ファイルには、テストのデフォルトの設定が格納されています。

`application_system_test_case.rb`には、システムテストのデフォルトの設定が格納されています。

### テスト環境

デフォルトでは、すべてのRailsアプリケーションには開発、テスト、本番の3つの環境があります。

各環境の設定は同様に変更できます。この場合、`config/environments/test.rb`にあるオプションを変更することで、テスト環境を変更できます。

注意：テストは`RAILS_ENV=test`の下で実行されます。

### RailsとMinitestの出会い

覚えているかもしれませんが、[Rails入門](getting_started.html)ガイドで`bin/rails generate model`コマンドを使用しました。最初のモデルを作成し、その他のものと一緒に`test`ディレクトリにテストのスタブが作成されました：

```bash
$ bin/rails generate model article title:string body:text
...
create  app/models/article.rb
create  test/models/article_test.rb
create  test/fixtures/articles.yml
...
```

`test/models/article_test.rb`のデフォルトのテストスタブは次のようになります：

```ruby
require "test_helper"

class ArticleTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
```

このファイルの行ごとの説明をすることで、Railsのテストコードと用語に慣れることができます。

```ruby
require "test_helper"
```

このファイルを`require`することで、`test_helper.rb`のデフォルトの設定が読み込まれます。私たちが書くすべてのテストにこれを含めるため、このファイルに追加されたメソッドはすべてのテストで利用できます。

```ruby
class ArticleTest < ActiveSupport::TestCase
```

`ArticleTest`クラスは、`ActiveSupport::TestCase`を継承しているため、_テストケース_を定義しています。したがって、`ArticleTest`は`ActiveSupport::TestCase`から利用可能なすべてのメソッドを持っています。このガイドの後半では、いくつかのメソッドを見ていきます。

`Minitest::Test`をスーパークラスとして継承したクラス内で定義されたメソッドは、`test_`で始まるものはすべてテストとして扱われます。したがって、`test_password`や`test_valid_password`といった名前のメソッドは、テストケースが実行されると自動的に実行されます。
Railsは、テスト名とブロックを受け取る`test`メソッドも追加します。これにより、`test_`で始まるメソッド名を持つ通常の`Minitest::Unit`テストが生成されます。したがって、メソッドの命名について心配する必要はありませんし、次のように書くことができます。

```ruby
test "the truth" do
  assert true
end
```

これは、次のように書くのとほぼ同じです。

```ruby
def test_the_truth
  assert true
end
```

通常のメソッド定義も使用できますが、`test`マクロを使用すると、より読みやすいテスト名を指定できます。

注意：メソッド名はスペースをアンダースコアに置き換えることで生成されます。ただし、結果は有効なRubyの識別子である必要はありません。名前に句読点などの文字が含まれていても構いません。これは、Rubyでは厳密にはどの文字列でもメソッド名になり得るためです。これには`define_method`と`send`呼び出しの使用が必要になる場合がありますが、形式的には名前に制限はほとんどありません。

次に、最初のアサーションを見てみましょう。

```ruby
assert true
```

アサーションは、期待される結果に対してオブジェクト（または式）を評価するコードの行です。たとえば、アサーションは次のようなことをチェックできます。

* この値はあの値と等しいか？
* このオブジェクトはnilですか？
* このコード行は例外をスローしますか？
* ユーザーのパスワードは5文字以上ですか？

すべてのテストには1つ以上のアサーションが含まれることができますが、アサーションがすべて成功した場合にのみテストがパスします。

#### 最初の失敗するテスト

テストの失敗がどのように報告されるかを確認するために、`article_test.rb`テストケースに失敗するテストを追加することができます。

```ruby
test "should not save article without title" do
  article = Article.new
  assert_not article.save
end
```

この新しく追加されたテストを実行してみましょう（テストが定義されている行番号は`6`です）。

```bash
$ bin/rails test test/models/article_test.rb:6
Run options: --seed 44656

# Running:

F

Failure:
ArticleTest#test_should_not_save_article_without_title [/path/to/blog/test/models/article_test.rb:6]:
Expected true to be nil or false


bin/rails test test/models/article_test.rb:6



Finished in 0.023918s, 41.8090 runs/s, 41.8090 assertions/s.

1 runs, 1 assertions, 1 failures, 0 errors, 0 skips
```

出力では、`F`は失敗を示しています。失敗したテストの名前の下に対応するトレースが表示されていることがわかります。次の数行にはスタックトレースが含まれ、アサーションによる実際の値と期待される値を示すメッセージが続きます。デフォルトのアサーションメッセージは、エラーの位置を特定するのに十分な情報を提供します。アサーションの失敗メッセージをより読みやすくするために、すべてのアサーションにはオプションのメッセージパラメータが用意されています。次のように示されているように、このようなメッセージを指定することができます。

```ruby
test "should not save article without title" do
  article = Article.new
  assert_not article.save, "Saved the article without a title"
end
```

このテストを実行すると、よりフレンドリーなアサーションメッセージが表示されます。

```
Failure:
ArticleTest#test_should_not_save_article_without_title [/path/to/blog/test/models/article_test.rb:6]:
Saved the article without a title
```

次に、このテストをパスするために、_title_フィールドのモデルレベルのバリデーションを追加できます。

```ruby
class Article < ApplicationRecord
  validates :title, presence: true
end
```

これでテストがパスするはずです。テストを再度実行して確認しましょう。

```bash
$ bin/rails test test/models/article_test.rb:6
Run options: --seed 31252

# Running:

.

Finished in 0.027476s, 36.3952 runs/s, 36.3952 assertions/s.

1 runs, 1 assertions, 0 failures, 0 errors, 0 skips
```

さて、気づいたかもしれませんが、まず望ましい機能のために失敗するテストを書き、次に機能を追加するコードを書き、最後にテストがパスすることを確認しました。このソフトウェア開発のアプローチは、[_テスト駆動開発_（TDD）](http://c2.com/cgi/wiki?TestDrivenDevelopment)と呼ばれています。

#### エラーの見た目

エラーがどのように報告されるかを確認するために、次のようなエラーを含むテストを見てみましょう。

```ruby
test "should report error" do
  # some_undefined_variableはテストケースの他の場所で定義されていません
  some_undefined_variable
  assert true
end
```
今度はテストを実行してコンソールにさらに多くの出力が表示されます：

```bash
$ bin/rails test test/models/article_test.rb
Run options: --seed 1808

# Running:

.E

Error:
ArticleTest#test_should_report_error:
NameError: undefined local variable or method 'some_undefined_variable' for #<ArticleTest:0x007fee3aa71798>
    test/models/article_test.rb:11:in 'block in <class:ArticleTest>'


bin/rails test test/models/article_test.rb:9



Finished in 0.040609s, 49.2500 runs/s, 24.6250 assertions/s.

2 runs, 1 assertions, 0 failures, 1 errors, 0 skips
```

出力に'E'があることに注意してください。これはエラーが発生したテストを示しています。

注意：各テストメソッドの実行は、エラーまたはアサーションの失敗が発生すると停止し、テストスイートは次のメソッドで続行します。すべてのテストメソッドはランダムな順序で実行されます。[`config.active_support.test_order`][]オプションを使用してテストの順序を設定できます。

テストが失敗すると、対応するバックトレースが表示されます。デフォルトでは、Railsはそのバックトレースをフィルタリングし、アプリケーションに関連する行のみを表示します。これにより、フレームワークのノイズが除去され、コードに集中するのに役立ちます。ただし、フルバックトレースを表示したい場合もあります。次のように`-b`（または`--backtrace`）引数を設定してこの動作を有効にします：

```bash
$ bin/rails test -b test/models/article_test.rb
```

このテストをパスさせるためには、次のように`assert_raises`を使用するように変更できます：

```ruby
test "should report error" do
  # some_undefined_variableはテストケースの他の場所で定義されていません
  assert_raises(NameError) do
    some_undefined_variable
  end
end
```

このテストは今ではパスするはずです。


### 利用可能なアサーション

これまでに利用可能ないくつかのアサーションを一部見てきました。アサーションはテストの作業蜂です。計画どおりに進んでいることを確認するために実際にチェックを実行する役割を果たします。

以下は、Railsで使用されるデフォルトのテストライブラリである[`Minitest`](https://github.com/minitest/minitest)で使用できるアサーションの抜粋です。`[msg]`パラメータは、テストの失敗メッセージをより明確にするために指定できるオプションの文字列メッセージです。

| アサーション                                                      | 目的 |
| ---------------------------------------------------------------- | ------- |
| `assert( test, [msg] )`                                          | `test`がtrueであることを確認します。|
| `assert_not( test, [msg] )`                                      | `test`がfalseであることを確認します。|
| `assert_equal( expected, actual, [msg] )`                        | `expected == actual`がtrueであることを確認します。|
| `assert_not_equal( expected, actual, [msg] )`                    | `expected != actual`がtrueであることを確認します。|
| `assert_same( expected, actual, [msg] )`                         | `expected.equal?(actual)`がtrueであることを確認します。|
| `assert_not_same( expected, actual, [msg] )`                     | `expected.equal?(actual)`がfalseであることを確認します。|
| `assert_nil( obj, [msg] )`                                       | `obj.nil?`がtrueであることを確認します。|
| `assert_not_nil( obj, [msg] )`                                   | `obj.nil?`がfalseであることを確認します。|
| `assert_empty( obj, [msg] )`                                     | `obj`が`empty?`であることを確認します。|
| `assert_not_empty( obj, [msg] )`                                 | `obj`が`empty?`でないことを確認します。|
| `assert_match( regexp, string, [msg] )`                          | 文字列が正規表現に一致することを確認します。|
| `assert_no_match( regexp, string, [msg] )`                       | 文字列が正規表現に一致しないことを確認します。|
| `assert_includes( collection, obj, [msg] )`                      | `obj`が`collection`に含まれていることを確認します。|
| `assert_not_includes( collection, obj, [msg] )`                  | `obj`が`collection`に含まれていないことを確認します。|
| `assert_in_delta( expected, actual, [delta], [msg] )`            | 数値`expected`と`actual`がお互いに`delta`以内であることを確認します。|
| `assert_not_in_delta( expected, actual, [delta], [msg] )`        | 数値`expected`と`actual`がお互いに`delta`以内でないことを確認します。|
| `assert_in_epsilon ( expected, actual, [epsilon], [msg] )`       | 数値`expected`と`actual`の相対誤差が`epsilon`より小さいことを確認します。|
| `assert_not_in_epsilon ( expected, actual, [epsilon], [msg] )`   | 数値`expected`と`actual`の相対誤差が`epsilon`以上であることを確認します。|
| `assert_throws( symbol, [msg] ) { block }`                       | 指定したブロックがシンボルをスローすることを確認します。|
| `assert_raises( exception1, exception2, ... ) { block }`         | 指定したブロックが指定した例外のいずれかを発生させることを確認します。|
| `assert_instance_of( class, obj, [msg] )`                        | `obj`が`class`のインスタンスであることを確認します。|
| `assert_not_instance_of( class, obj, [msg] )`                    | `obj`が`class`のインスタンスでないことを確認します。|
| `assert_kind_of( class, obj, [msg] )`                            | `obj`が`class`のインスタンスであるか、またはそれを継承していることを確認します。|
| `assert_not_kind_of( class, obj, [msg] )`                        | `obj`が`class`のインスタンスでなく、それを継承していないことを確認します。|
| `assert_respond_to( obj, symbol, [msg] )`                        | `obj`が`symbol`に応答することを確認します。|
| `assert_not_respond_to( obj, symbol, [msg] )`                    | `obj`が`symbol`に応答しないことを確認します。|
| `assert_operator( obj1, operator, [obj2], [msg] )`               | `obj1.operator(obj2)`がtrueであることを確認します。|
| `assert_not_operator( obj1, operator, [obj2], [msg] )`           | `obj1.operator(obj2)`がfalseであることを確認します。|
| `assert_predicate ( obj, predicate, [msg] )`                     | `obj.predicate`がtrueであることを確認します。例：`assert_predicate str, :empty?`|
| `assert_not_predicate ( obj, predicate, [msg] )`                 | `obj.predicate`がfalseであることを確認します。例：`assert_not_predicate str, :empty?`|
| `flunk( [msg] )`                                                 | 失敗を確認します。これはまだ完了していないテストを明示的にマークするのに便利です。|
上記は、minitestがサポートするアサーションの一部です。詳細で最新のリストについては、[Minitest APIドキュメント](http://docs.seattlerb.org/minitest/)を参照してください。特に、[`Minitest::Assertions`](http://docs.seattlerb.org/minitest/Minitest/Assertions.html)を参照してください。

テストフレームワークのモジュラーな性質のため、独自のアサーションを作成することが可能です。実際に、Railsが行っているのはまさにそれです。いくつかの特殊なアサーションが含まれており、あなたの生活をより簡単にします。

注意：独自のアサーションを作成することは、このチュートリアルでは扱いません。

### Rails固有のアサーション

Railsは、`minitest`フレームワークに独自のアサーションを追加します。

| アサーション                                                                         | 目的 |
| --------------------------------------------------------------------------------- | ------- |
| [`assert_difference(expressions, difference = 1, message = nil) {...}`](https://api.rubyonrails.org/classes/ActiveSupport/Testing/Assertions.html#method-i-assert_difference) | 式の返り値の数値の差をテストし、ブロック内で評価される結果によるものです。|
| [`assert_no_difference(expressions, message = nil, &block)`](https://api.rubyonrails.org/classes/ActiveSupport/Testing/Assertions.html#method-i-assert_no_difference) | 式の評価結果の数値が、渡されたブロックを呼び出す前後で変化しないことをアサートします。|
| [`assert_changes(expressions, message = nil, from:, to:, &block)`](https://api.rubyonrails.org/classes/ActiveSupport/Testing/Assertions.html#method-i-assert_changes) | 渡されたブロックを呼び出した後に式の評価結果が変化することをテストします。|
| [`assert_no_changes(expressions, message = nil, &block)`](https://api.rubyonrails.org/classes/ActiveSupport/Testing/Assertions.html#method-i-assert_no_changes) | 渡されたブロックを呼び出した後に式の評価結果が変化しないことをテストします。|
| [`assert_nothing_raised { block }`](https://api.rubyonrails.org/classes/ActiveSupport/Testing/Assertions.html#method-i-assert_nothing_raised) | 指定されたブロックが例外を発生させないことを保証します。|
| [`assert_recognizes(expected_options, path, extras={}, message=nil)`](https://api.rubyonrails.org/classes/ActionDispatch/Assertions/RoutingAssertions.html#method-i-assert_recognizes) | 指定されたパスのルーティングが正しく処理され、解析されたオプション（expected_optionsハッシュで指定）がパスと一致することをアサートします。基本的には、Railsがexpected_optionsで指定されたルートを認識することをアサートします。|
| [`assert_generates(expected_path, options, defaults={}, extras = {}, message=nil)`](https://api.rubyonrails.org/classes/ActionDispatch/Assertions/RoutingAssertions.html#method-i-assert_generates) | 指定されたオプションを使用して指定されたパスを生成できることをアサートします。これはassert_recognizesの逆です。extrasパラメータは、クエリ文字列に含まれる追加のリクエストパラメータの名前と値をリクエストに伝えるために使用されます。messageパラメータを使用して、アサーションの失敗時にカスタムエラーメッセージを指定することもできます。|
| [`assert_response(type, message = nil)`](https://api.rubyonrails.org/classes/ActionDispatch/Assertions/ResponseAssertions.html#method-i-assert_response) | レスポンスが特定のステータスコードであることをアサートします。`:success`を指定すると、200-299を示し、`:redirect`を指定すると、300-399を示し、`:missing`を指定すると、404を示し、`:error`を指定すると、500-599の範囲に一致します。明示的なステータス番号またはそのシンボルの等価物を渡すこともできます。詳細については、[ステータスコードの完全なリスト](https://rubydoc.info/gems/rack/Rack/Utils#HTTP_STATUS_CODES-constant)とその[マッピング](https://rubydoc.info/gems/rack/Rack/Utils#SYMBOL_TO_STATUS_CODE-constant)の方法を参照してください。|
| [`assert_redirected_to(options = {}, message=nil)`](https://api.rubyonrails.org/classes/ActionDispatch/Assertions/ResponseAssertions.html#method-i-assert_redirected_to) | レスポンスが指定されたオプションに一致するURLへのリダイレクトであることをアサートします。`assert_redirected_to root_path`のような名前付きルートや、`assert_redirected_to @article`のようなActive Recordオブジェクトを渡すこともできます。|

これらのアサーションのいくつかの使用方法は、次の章で確認できます。

### テストケースについての簡単な注意事項

`Minitest::Assertions`で定義されている`assert_equal`などのすべての基本的なアサーションは、自分自身のテストケースで使用するクラスでも利用できます。実際に、Railsでは以下のクラスを継承するために提供しています。

* [`ActiveSupport::TestCase`](https://api.rubyonrails.org/classes/ActiveSupport/TestCase.html)
* [`ActionMailer::TestCase`](https://api.rubyonrails.org/classes/ActionMailer/TestCase.html)
* [`ActionView::TestCase`](https://api.rubyonrails.org/classes/ActionView/TestCase.html)
* [`ActiveJob::TestCase`](https://api.rubyonrails.org/classes/ActiveJob/TestCase.html)
* [`ActionDispatch::IntegrationTest`](https://api.rubyonrails.org/classes/ActionDispatch/IntegrationTest.html)
* [`ActionDispatch::SystemTestCase`](https://api.rubyonrails.org/classes/ActionDispatch/SystemTestCase.html)
* [`Rails::Generators::TestCase`](https://api.rubyonrails.org/classes/Rails/Generators/TestCase.html)

これらのクラスはすべて`Minitest::Assertions`を含んでおり、テストですべての基本的なアサーションを使用することができます。

注意：`Minitest`の詳細については、[そのドキュメント](http://docs.seattlerb.org/minitest)を参照してください。

### Railsテストランナー

`bin/rails test`コマンドを使用して、すべてのテストを一度に実行できます。

または、テストケースを含むファイル名を`bin/rails test`コマンドに渡すことで、単一のテストファイルを実行できます。

```bash
$ bin/rails test test/models/article_test.rb
Run options: --seed 1559

# Running:

..

Finished in 0.027034s, 73.9810 runs/s, 110.9715 assertions/s.

2 runs, 3 assertions, 0 failures, 0 errors, 0 skips
```

これにより、テストケースからすべてのテストメソッドが実行されます。
また、テストケースから特定のテストメソッドを実行することもできます。その際には、`-n`または`--name`フラグとテストメソッドの名前を指定します。

```bash
$ bin/rails test test/models/article_test.rb -n test_the_truth
Run options: -n test_the_truth --seed 43583

# 実行中:

.

Finished tests in 0.009064s, 110.3266 tests/s, 110.3266 assertions/s.

1 tests, 1 assertions, 0 failures, 0 errors, 0 skips
```

また、行番号を指定することで特定の行のテストを実行することもできます。

```bash
$ bin/rails test test/models/article_test.rb:6 # 特定のテストと行を実行
```

さらに、ディレクトリのパスを指定することで、テストのディレクトリ全体を実行することもできます。

```bash
$ bin/rails test test/controllers # 特定のディレクトリからすべてのテストを実行
```

テストランナーには、失敗を早めに検出する機能や、テストの出力をテスト実行の最後に遅延させるなど、他にも多くの機能があります。以下のテストランナーのドキュメントを参照してください。

```bash
$ bin/rails test -h
Usage: rails test [options] [files or directories]

You can run a single test by appending a line number to a filename:

    bin/rails test test/models/user_test.rb:27

You can run multiple files and directories at the same time:

    bin/rails test test/controllers test/integration/login_test.rb

By default test failures and errors are reported inline during a run.

minitest options:
    -h, --help                       Display this help.
        --no-plugins                 Bypass minitest plugin auto-loading (or set $MT_NO_PLUGINS).
    -s, --seed SEED                  Sets random seed. Also via env. Eg: SEED=n rake
    -v, --verbose                    Verbose. Show progress processing files.
    -n, --name PATTERN               Filter run on /regexp/ or string.
        --exclude PATTERN            Exclude /regexp/ or string from run.

Known extensions: rails, pride
    -w, --warnings                   Run with Ruby warnings enabled
    -e, --environment ENV            Run tests in the ENV environment
    -b, --backtrace                  Show the complete backtrace
    -d, --defer-output               Output test failures and errors after the test run
    -f, --fail-fast                  Abort test run on first failure or error
    -c, --[no-]color                 Enable color in the output
    -p, --pride                      Pride. Show your testing pride!
```

### CI（継続的インテグレーション）でのテストの実行

CI環境ですべてのテストを実行するには、次のコマンドを使用します。

```bash
$ bin/rails test
```

[システムテスト](#system-testing)を使用している場合、`bin/rails test`では実行されません。システムテストも実行するには、`bin/rails test:system`を実行する別のCIステップを追加するか、最初のステップを`bin/rails test:all`に変更してシステムテストを含めたすべてのテストを実行します。

並列テスト
----------------

並列テストを使用すると、テストスイートを並列化することができます。プロセスのフォークがデフォルトの方法ですが、スレッドもサポートされています。テストを並列実行することで、テストスイート全体の実行時間を短縮することができます。

### プロセスを使用した並列テスト

デフォルトの並列化方法は、RubyのDRbシステムを使用してプロセスをフォークすることです。プロセスは提供されたワーカーの数に基づいてフォークされます。デフォルトの数は、使用しているマシンの実際のコア数ですが、parallelizeメソッドに渡す数で変更することができます。

並列化を有効にするには、`test_helper.rb`に次のコードを追加します。

```ruby
class ActiveSupport::TestCase
  parallelize(workers: 2)
end
```

渡されたワーカーの数は、プロセスがフォークされる回数です。ローカルのテストスイートとCIのテストスイートを異なる方法で並列化したい場合は、テスト実行に使用するワーカーの数を簡単に変更できるように、環境変数が提供されています。

```bash
$ PARALLEL_WORKERS=15 bin/rails test
```

テストを並列化する場合、Active Recordは自動的にデータベースを作成し、各プロセスにスキーマをロードする処理を自動的に行います。データベースは、ワーカーに対応する番号でサフィックスが付けられます。たとえば、2つのワーカーがある場合、テストはそれぞれ`test-database-0`と`test-database-1`を作成します。
もしワーカーの数が1以下であれば、プロセスはフォークされず、テストは並列化されず、テストは元の`test-database`データベースを使用します。

2つのフックが提供されており、1つはプロセスがフォークされたときに実行され、もう1つはフォークされたプロセスが終了する前に実行されます。
これらは、アプリケーションが複数のデータベースを使用するか、ワーカーの数に依存する他のタスクを実行する場合に便利です。

`parallelize_setup`メソッドは、プロセスがフォークされた直後に呼び出されます。`parallelize_teardown`メソッドは、プロセスが閉じられる直前に呼び出されます。

```ruby
class ActiveSupport::TestCase
  parallelize_setup do |worker|
    # データベースのセットアップ
  end

  parallelize_teardown do |worker|
    # データベースのクリーンアップ
  end

  parallelize(workers: :number_of_processors)
end
```

これらのメソッドは、スレッドを使用した並列テストを行う場合には必要ありませんし、利用できません。

### スレッドを使用した並列テスト

スレッドを使用する場合、またはJRubyを使用している場合、スレッドを使用した並列化オプションが提供されます。スレッドをバックエンドとする並列化は、Minitestの`Parallel::Executor`によってバックアップされます。

並列化の方法をフォークからスレッドに変更するには、`test_helper.rb`に次のコードを追加します。

```ruby
class ActiveSupport::TestCase
  parallelize(workers: :number_of_processors, with: :threads)
end
```

JRubyまたはTruffleRubyから生成されたRailsアプリケーションでは、自動的に`with: :threads`オプションが含まれます。

`parallelize`に渡されるワーカーの数は、テストが使用するスレッドの数を決定します。ローカルのテストスイートとCIで異なる並列化を行いたい場合、テスト実行に使用するワーカーの数を簡単に変更できる環境変数が提供されています。

```bash
$ PARALLEL_WORKERS=15 bin/rails test
```

### 並列トランザクションのテスト

Railsは、テストケースをデータベーストランザクションで自動的にラップし、テストが完了した後にロールバックします。これにより、テストケースは互いに独立しており、データベースへの変更は単一のテスト内でのみ可視化されます。

スレッドで並列トランザクションを実行するコードをテストしたい場合、トランザクションは既にテストトランザクションの下にネストされているため、トランザクションがブロックされる可能性があります。

テストケースクラスでトランザクションを無効にするには、`self.use_transactional_tests = false`を設定します。

```ruby
class WorkerTest < ActiveSupport::TestCase
  self.use_transactional_tests = false

  test "parallel transactions" do
    # トランザクションを作成するスレッドを開始する
  end
end
```

注意: トランザクションテストが無効になっている場合、テストが作成するデータをクリーンアップする必要があります。テストが完了した後に変更は自動的にロールバックされません。

### テストの並列化のしきい値

テストを並列化することは、データベースのセットアップやフィクスチャの読み込みにおいてオーバーヘッドが発生します。そのため、Railsは50未満のテストを含む実行を並列化しません。

このしきい値を`test.rb`で設定することができます。

```ruby
config.active_support.test_parallelization_threshold = 100
```

また、テストケースレベルで並列化を設定する際にも設定できます。

```ruby
class ActiveSupport::TestCase
  parallelize threshold: 100
end
```

テストデータベース
-----------------

ほとんどのRailsアプリケーションはデータベースと密接に連携しており、その結果、テストもデータベースとやり取りする必要があります。効率的なテストを書くためには、このデータベースを設定し、サンプルデータでデータベースを満たす方法を理解する必要があります。

デフォルトでは、すべてのRailsアプリケーションには開発、テスト、本番の3つの環境があります。それぞれのデータベースは`config/database.yml`で設定されています。

専用のテストデータベースを使用することで、テストデータを分離して設定し、操作することができます。これにより、テストは開発や本番のデータベースのデータに影響を与えることなく、自信を持ってテストデータを操作できます。

### テストデータベースのスキーマの維持

テストを実行するためには、テストデータベースに現在のスキーマが必要です。テストヘルパーは、テストデータベースに保留中のマイグレーションがあるかどうかをチェックします。`db/schema.rb`または`db/structure.sql`をテストデータベースにロードしようとします。マイグレーションがまだ保留中の場合、エラーが発生します。通常、これはスキーマが完全にマイグレーションされていないことを示しています。開発データベースに対してマイグレーションを実行することで、スキーマを最新の状態に更新することができます（`bin/rails db:migrate`）。

注意：既存のマイグレーションに変更がある場合、テストデータベースを再構築する必要があります。これは、`bin/rails db:test:prepare`を実行することで行うことができます。

### フィクスチャについての詳細

良いテストを行うためには、テストデータの設定について考える必要があります。Railsでは、フィクスチャを定義してカスタマイズすることで、これを処理することができます。[フィクスチャAPIドキュメント](https://api.rubyonrails.org/classes/ActiveRecord/FixtureSet.html)に詳細なドキュメントがあります。

#### フィクスチャとは何ですか？

フィクスチャは、サンプルデータのことを指す洒落た言葉です。フィクスチャを使用すると、テストが実行される前にテストデータベースに事前定義されたデータを追加することができます。フィクスチャはデータベースに依存せず、YAML形式で記述されます。1つのモデルにつき1つのファイルがあります。

注意：フィクスチャはテストに必要なすべてのオブジェクトを作成するために設計されているわけではなく、一般的なケースに適用できるデフォルトデータにのみ使用する場合に最適です。

`test/fixtures`ディレクトリの下にフィクスチャがあります。新しいモデルを作成するために`bin/rails generate model`を実行すると、Railsは自動的にこのディレクトリにフィクスチャのスタブを作成します。

#### YAML

YAML形式のフィクスチャは、サンプルデータを記述するための人間にやさしい方法です。このタイプのフィクスチャは、**.yml**の拡張子を持ちます（例：`users.yml`）。

以下は、サンプルのYAMLフィクスチャファイルです。

```yaml
# lo & behold! I am a YAML comment!
david:
  name: David Heinemeier Hansson
  birthday: 1979-10-15
  profession: Systems development

steve:
  name: Steve Ross Kellock
  birthday: 1974-09-27
  profession: guy with keyboard
```

各フィクスチャには、名前が付けられ、コロンで区切られたキー/値のペアのインデントリストが続きます。レコードは通常、空行で区切られます。フィクスチャファイルの最初の列には、#文字を使用してコメントを記述することができます。

[関連付け](/association_basics.html)を使用している場合、2つの異なるフィクスチャ間に参照ノードを定義することができます。以下は、`belongs_to`/`has_many`の関連付けを持つ例です。

```yaml
# test/fixtures/categories.yml
about:
  name: About
```

```yaml
# test/fixtures/articles.yml
first:
  title: Welcome to Rails!
  category: about
```

```yaml
# test/fixtures/action_text/rich_texts.yml
first_content:
  record: first (Article)
  name: content
  body: <div>Hello, from <strong>a fixture</strong></div>
```

`fixtures/articles.yml`で見つかる`first` Articleの`category`キーの値が`about`であり、`fixtures/action_text/rich_texts.yml`で見つかる`first_content`エントリの`record`キーの値が`first (Article)`であることに注意してください。これにより、Active Recordは前者の`fixtures/categories.yml`で見つかるCategory `about`をロードし、後者のAction Textは`fixtures/articles.yml`で見つかるArticle `first`をロードするようにヒントを与えます。

注意：関連付けが名前で互いを参照する場合、関連するフィクスチャの`id:`属性を指定する代わりに、フィクスチャ名を使用することができます。Railsは一貫性のあるプライマリキーを自動的に割り当てます。この関連付けの動作についての詳細は、[フィクスチャAPIドキュメント](https://api.rubyonrails.org/classes/ActiveRecord/FixtureSet.html)をお読みください。

#### ファイル添付フィクスチャ

他のActive Recordベースのモデルと同様に、Active Storageの添付レコードもActiveRecord::Baseインスタンスから継承されるため、フィクスチャでデータを追加することができます。

`thumbnail`添付ファイルを持つ`Article`モデルを考えてみましょう。また、YAML形式のフィクスチャデータも考えてみます。

```ruby
class Article
  has_one_attached :thumbnail
end
```

```yaml
# test/fixtures/articles.yml
first:
  title: An Article
```

`test/fixtures/files/first.png`に[image/png][]形式のファイルがあると仮定すると、次のYAMLフィクスチャエントリは関連する`ActiveStorage::Blob`と`ActiveStorage::Attachment`レコードを生成します。

```yaml
# test/fixtures/active_storage/blobs.yml
first_thumbnail_blob: <%= ActiveStorage::FixtureSet.blob filename: "first.png" %>
```

```yaml
# test/fixtures/active_storage/attachments.yml
first_thumbnail_attachment:
  name: thumbnail
  record: first (Article)
  blob: first_thumbnail_blob
```


#### ERBを使用する

ERBを使用すると、テンプレート内にRubyコードを埋め込むことができます。Railsがフィクスチャをロードする際に、YAMLフィクスチャ形式はERBで事前処理されます。これにより、Rubyを使用してサンプルデータを生成するのに役立ちます。たとえば、次のコードは1000人のユーザーを生成します。

```erb
<% 1000.times do |n| %>
user_<%= n %>:
  username: <%= "user#{n}" %>
  email: <%= "user#{n}@example.com" %>
<% end %>
```
#### Fixturesの動作

Railsはデフォルトで`test/fixtures`ディレクトリからすべてのfixturesを自動的にロードします。ロードには3つのステップがあります：

1. fixturesに対応するテーブルから既存のデータを削除する
2. fixturesデータをテーブルにロードする
3. fixturesデータを直接アクセスするためのメソッドにダンプする

TIP: データベースから既存のデータを削除するために、Railsは参照整合性トリガー（外部キーやチェック制約など）を無効にしようとします。テスト実行時に面倒な権限エラーが発生する場合は、テスト環境でこれらのトリガーを無効にする権限をデータベースユーザーが持っていることを確認してください。（PostgreSQLでは、すべてのトリガーを無効にする権限を持つのはスーパーユーザーのみです。PostgreSQLの権限については[こちら](https://www.postgresql.org/docs/current/sql-altertable.html)を参照してください）。

#### FixturesはActive Recordオブジェクトです

FixturesはActive Recordのインスタンスです。上記のポイント3で述べたように、テストケースのローカルスコープとして自動的に利用可能なメソッドとして提供されるため、オブジェクトに直接アクセスすることができます。例えば：

```ruby
# これはfixtureの名前がdavidのUserオブジェクトを返します
users(:david)

# これはdavidのidというプロパティを返します
users(:david).id

# Userクラスで利用可能なメソッドにもアクセスできます
david = users(:david)
david.call(david.partner)
```

複数のfixturesを一度に取得するには、fixture名のリストを渡すことができます。例えば：

```ruby
# これはdavidとsteveのfixturesを含む配列を返します
users(:david, :steve)
```


モデルのテスト
-------------

モデルテストは、アプリケーションのさまざまなモデルをテストするために使用されます。

Railsのモデルテストは`test/models`ディレクトリに保存されます。Railsには、モデルテストの骨組みを生成するためのジェネレータが用意されています。

```bash
$ bin/rails generate test_unit:model article title:string body:text
create  test/models/article_test.rb
create  test/fixtures/articles.yml
```

モデルテストには、`ActionMailer::TestCase`のような独自のスーパークラスはありません。代わりに、[`ActiveSupport::TestCase`](https://api.rubyonrails.org/classes/ActiveSupport/TestCase.html)を継承します。

システムテスト
--------------

システムテストを使用すると、実際のブラウザまたはヘッドレスブラウザでアプリケーションのユーザーインタラクションをテストすることができます。システムテストは、内部でCapybaraを使用します。

Railsのシステムテストを作成するには、アプリケーション内の`test/system`ディレクトリを使用します。Railsには、システムテストの骨組みを生成するためのジェネレータが用意されています。

```bash
$ bin/rails generate system_test users
      invoke test_unit
      create test/system/users_test.rb
```

以下は、新しく生成されたシステムテストの例です：

```ruby
require "application_system_test_case"

class UsersTest < ApplicationSystemTestCase
  # test "visiting the index" do
  #   visit users_url
  #
  #   assert_selector "h1", text: "Users"
  # end
end
```

デフォルトでは、システムテストはChromeブラウザを使用し、画面サイズは1400x1400です。次のセクションでは、デフォルト設定を変更する方法について説明します。

### デフォルト設定の変更

Railsはシステムテストのデフォルト設定を変更することを非常に簡単にします。すべてのセットアップは抽象化されているため、テストの記述に集中できます。

新しいアプリケーションまたはスキャフォールドを生成すると、`test`ディレクトリに`application_system_test_case.rb`ファイルが作成されます。これはシステムテストのすべての設定が記述される場所です。

デフォルト設定を変更したい場合は、システムテストの「駆動方法」を変更することができます。たとえば、ドライバをSeleniumからCupriteに変更したい場合は、まず`Gemfile`に`cuprite`ジェムを追加します。次に、`application_system_test_case.rb`ファイルで次のようにします：

```ruby
require "test_helper"
require "capybara/cuprite"

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  driven_by :cuprite
end
```

ドライバ名は`driven_by`の必須引数です。`driven_by`に渡すことができるオプション引数は、Seleniumの場合にのみ使用されるブラウザの`:using`、スクリーンショットのサイズを変更するための`:screen_size`、およびドライバがサポートするオプションを設定するための`:options`です。

```ruby
require "test_helper"

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  driven_by :selenium, using: :firefox
end
```
ヘッドレスブラウザを使用する場合、`:using`引数に`headless_chrome`または`headless_firefox`を追加することで、Headless ChromeまたはHeadless Firefoxを使用することができます。

```ruby
require "test_helper"

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  driven_by :selenium, using: :headless_chrome
end
```

リモートブラウザを使用する場合は、例えば[Headless Chrome in Docker](https://github.com/SeleniumHQ/docker-selenium)のように、`options`を介してリモート`url`を追加する必要があります。

```ruby
require "test_helper"

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  options = ENV["SELENIUM_REMOTE_URL"].present? ? { url: ENV["SELENIUM_REMOTE_URL"] } : {}
  driven_by :selenium, using: :headless_chrome, options: options
end
```

このような場合、`webdrivers`のgemは必要ありません。完全に削除するか、`Gemfile`に`require:`オプションを追加することができます。

```ruby
# ...
group :test do
  gem "webdrivers", require: !ENV["SELENIUM_REMOTE_URL"] || ENV["SELENIUM_REMOTE_URL"].empty?
end
```

これでリモートブラウザに接続できるはずです。

```bash
$ SELENIUM_REMOTE_URL=http://localhost:4444/wd/hub bin/rails test:system
```

テスト中のアプリケーションもリモートで実行される場合、例えばDockerコンテナの場合、Capybaraはリモートサーバーの呼び出し方法についての追加の入力が必要です。

```ruby
require "test_helper"

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  def setup
    Capybara.server_host = "0.0.0.0" # すべてのインターフェースにバインドする
    Capybara.app_host = "http://#{IPSocket.getaddress(Socket.gethostname)}" if ENV["SELENIUM_REMOTE_URL"].present?
    super
  end
  # ...
end
```

これで、DockerコンテナやCIで実行されているかどうかに関係なく、リモートブラウザとサーバーに接続できるはずです。

Capybaraの設定には、Railsが提供するものよりも多くのセットアップが必要な場合、この追加の設定を`application_system_test_case.rb`ファイルに追加することができます。

追加の設定については、[Capybaraのドキュメント](https://github.com/teamcapybara/capybara#setup)を参照してください。

### スクリーンショットヘルパー

`ScreenshotHelper`は、テストのスクリーンショットをキャプチャするためのヘルパーです。これは、テストが失敗した時点でブラウザを表示したり、デバッグのために後でスクリーンショットを表示するのに役立ちます。

`take_screenshot`と`take_failed_screenshot`の2つのメソッドが提供されています。`take_failed_screenshot`は、Railsの`before_teardown`内で自動的に含まれます。

`take_screenshot`ヘルパーメソッドは、テストの任意の場所に含めることで、ブラウザのスクリーンショットを撮ることができます。

### システムテストの実装

次に、ブログアプリケーションにシステムテストを追加します。インデックスページを訪れ、新しいブログ記事を作成するというシステムテストの作成方法を示します。

もしもスキャフォールドジェネレータを使用した場合、システムテストのスケルトンが自動的に作成されているはずです。スキャフォールドジェネレータを使用しなかった場合は、まずシステムテストのスケルトンを作成します。

```bash
$ bin/rails generate system_test articles
```

上記のコマンドの出力により、次のようなテストファイルのプレースホルダが作成されるはずです。

```
      invoke  test_unit
      create    test/system/articles_test.rb
```

それでは、そのファイルを開き、最初のアサーションを書いてみましょう。

```ruby
require "application_system_test_case"

class ArticlesTest < ApplicationSystemTestCase
  test "viewing the index" do
    visit articles_path
    assert_selector "h1", text: "Articles"
  end
end
```

このテストでは、記事のインデックスページに`h1`があることを確認し、パスするはずです。

システムテストを実行します。

```bash
$ bin/rails test:system
```

注意：デフォルトでは、`bin/rails test`を実行してもシステムテストは実行されません。実際に実行するには、`bin/rails test:system`を実行してください。また、システムテストを含むすべてのテストを実行するには、`bin/rails test:all`を実行することもできます。

#### 記事の作成システムテストの作成

次に、ブログで新しい記事を作成するフローをテストします。

```ruby
test "should create Article" do
  visit articles_path

  click_on "New Article"

  fill_in "Title", with: "Creating an Article"
  fill_in "Body", with: "Created this article successfully!"

  click_on "Create Article"

  assert_text "Creating an Article"
end
```

最初のステップは、`visit articles_path`を呼び出すことです。これにより、テストは記事のインデックスページに移動します。

次に、`click_on "New Article"`は、インデックスページで「New Article」ボタンを見つけます。これにより、ブラウザは`/articles/new`にリダイレクトされます。

その後、テストは指定されたテキストで記事のタイトルと本文を入力します。フィールドが入力されたら、「Create Article」をクリックし、新しい記事をデータベースに作成するためのPOSTリクエストが送信されます。
記事のインデックスページにリダイレクトされ、そこで新しい記事のタイトルのテキストが記事のインデックスページにあることを確認します。

#### 複数の画面サイズのテスト

デスクトップのテストに加えて、モバイルサイズのテストも行いたい場合は、`ActionDispatch::SystemTestCase`を継承した別のクラスを作成し、テストスイートで使用することができます。この例では、`mobile_system_test_case.rb`というファイルを`/test`ディレクトリに作成し、以下の設定を行います。

```ruby
require "test_helper"

class MobileSystemTestCase < ActionDispatch::SystemTestCase
  driven_by :selenium, using: :chrome, screen_size: [375, 667]
end
```

この設定を使用するには、`MobileSystemTestCase`を継承した`test/system`内のテストを作成します。これで、複数の異なる設定でアプリをテストすることができます。

```ruby
require "mobile_system_test_case"

class PostsTest < MobileSystemTestCase
  test "インデックスにアクセスする" do
    visit posts_url
    assert_selector "h1", text: "Posts"
  end
end
```

#### さらに進む

システムテストの美しいところは、それが統合テストに似ていることであり、コントローラ、モデル、ビューとのユーザーのインタラクションをテストしますが、システムテストはより堅牢で、実際のユーザーが使用しているかのようにアプリケーションをテストします。これからは、コメントのテスト、記事の削除、下書き記事の公開など、ユーザー自身がアプリケーションで行うことができるすべてのことをテストすることができます。

統合テスト
-------------------

統合テストは、アプリケーションのさまざまな部分がどのように相互作用するかをテストするために使用されます。通常、アプリケーション内の重要なワークフローをテストするために使用されます。

Railsの統合テストを作成するために、アプリケーションの`test/integration`ディレクトリを使用します。Railsは、統合テストのスケルトンを作成するためのジェネレータを提供しています。

```bash
$ bin/rails generate integration_test user_flows
      exists  test/integration/
      create  test/integration/user_flows_test.rb
```

以下は、新しく生成された統合テストのスケルトンの例です。

```ruby
require "test_helper"

class UserFlowsTest < ActionDispatch::IntegrationTest
  # test "the truth" do
  #   assert true
  # end
end
```

ここでは、テストが`ActionDispatch::IntegrationTest`を継承しています。これにより、統合テストで使用できるいくつかの追加のヘルパーが利用可能になります。

### 統合テストで利用可能なヘルパー

標準のテストヘルパーに加えて、`ActionDispatch::IntegrationTest`を継承することで、統合テストを作成する際に使用できるいくつかの追加のヘルパーが利用可能になります。利用できる3つのカテゴリのヘルパーについて簡単に紹介しましょう。

統合テストランナーに関する操作については、[`ActionDispatch::Integration::Runner`](https://api.rubyonrails.org/classes/ActionDispatch/Integration/Runner.html)を参照してください。

リクエストを実行する際には、[`ActionDispatch::Integration::RequestHelpers`](https://api.rubyonrails.org/classes/ActionDispatch/Integration/RequestHelpers.html)を使用できます。

セッションの変更や統合テストの状態の変更が必要な場合は、[`ActionDispatch::Integration::Session`](https://api.rubyonrails.org/classes/ActionDispatch/Integration/Session.html)を参照してください。

### 統合テストの実装

ブログアプリケーションに統合テストを追加しましょう。まず、すべてが正常に動作していることを確認するために、新しいブログ記事の作成の基本的なワークフローをテストします。

まず、統合テストのスケルトンを生成します。

```bash
$ bin/rails generate integration_test blog_flow
```

これにより、テストファイルのプレースホルダが作成されます。前のコマンドの出力には次のように表示されるはずです。

```
      invoke  test_unit
      create    test/integration/blog_flow_test.rb
```

次に、そのファイルを開き、最初のアサーションを書きます。

```ruby
require "test_helper"

class BlogFlowTest < ActionDispatch::IntegrationTest
  test "ウェルカムページを表示できる" do
    get "/"
    assert_select "h1", "Welcome#index"
  end
end
```

`assert_select`を使用して、リクエストの結果のHTMLをクエリする方法については、以下の「ビューのテスト」セクションで説明します。このアサーションは、リクエストの応答をテストするために使用され、主要なHTML要素とその内容の存在をアサートします。

ルートパスを訪れると、ビューのために`welcome/index.html.erb`がレンダリングされるはずです。したがって、このアサーションはパスするはずです。

#### 記事の作成統合テスト

ブログで新しい記事を作成し、結果の記事を表示する能力をテストしてみましょう。

```ruby
test "記事を作成できる" do
  get "/articles/new"
  assert_response :success

  post "/articles",
    params: { article: { title: "can create", body: "article successfully." } }
  assert_response :redirect
  follow_redirect!
  assert_response :success
  assert_select "p", "Title:\n  can create"
end
```

このテストを理解するために、分解してみましょう。

まず、Articlesコントローラーの`:new`アクションを呼び出します。このレスポンスは成功するはずです。

その後、Articlesコントローラーの`:create`アクションに対してPOSTリクエストを行います。

```ruby
post "/articles",
  params: { article: { title: "can create", body: "article successfully." } }
assert_response :redirect
follow_redirect!
```

リクエストに続く2行は、新しい記事を作成する際に設定したリダイレクトを処理するためのものです。

注意：リダイレクト後にさらなるリクエストを行う場合は、`follow_redirect!`を呼び出すのを忘れないでください。

最後に、レスポンスが成功し、新しい記事がページ上で読み取れることを確認できます。

#### さらに進める

私たちは、ブログを訪れて新しい記事を作成するという非常に小さなワークフローを成功裏にテストすることができました。さらに進めるために、コメント、記事の削除、コメントの編集などのテストを追加することができます。統合テストは、アプリケーションのさまざまなユースケースを試すための素晴らしい場所です。

コントローラーの機能テスト
-------------------------------------

Railsでは、コントローラーのさまざまなアクションをテストすることは、機能テストの形式です。コントローラーは、アプリケーションへの着信ウェブリクエストを処理し、最終的にはレンダリングされたビューで応答します。機能テストを書くときは、アクションがリクエストをどのように処理し、期待される結果や応答（場合によってはHTMLビュー）をテストしています。

### 機能テストに含めるべき内容

以下のようなことをテストする必要があります。

* ウェブリクエストは成功しましたか？
* ユーザーは正しいページにリダイレクトされましたか？
* ユーザーは正常に認証されましたか？
* ビューでユーザーに適切なメッセージが表示されましたか？
* 応答には正しい情報が表示されましたか？

機能テストを実際に見る最も簡単な方法は、スキャフォールドジェネレーターを使用してコントローラーを生成することです。

```bash
$ bin/rails generate scaffold_controller article title:string body:text
...
create  app/controllers/articles_controller.rb
...
invoke  test_unit
create    test/controllers/articles_controller_test.rb
...
```

これにより、`Article`リソースのコントローラーコードとテストが生成されます。`test/controllers`ディレクトリの`articles_controller_test.rb`ファイルを確認できます。

既にコントローラーがある場合で、デフォルトの7つのアクションごとにテストのスキャフォールドコードを生成したい場合は、次のコマンドを使用できます。

```bash
$ bin/rails generate test_unit:scaffold article
...
invoke  test_unit
create    test/controllers/articles_controller_test.rb
...
```

では、`articles_controller_test.rb`ファイルの`test_should_get_index`というテストを見てみましょう。

```ruby
# articles_controller_test.rb
class ArticlesControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get articles_url
    assert_response :success
  end
end
```

`test_should_get_index`テストでは、Railsは`index`というアクションに対してリクエストをシミュレートし、リクエストが成功したことを確認し、正しいレスポンスボディが生成されたことも確認しています。

`get`メソッドはウェブリクエストを開始し、結果を`@response`に格納します。最大6つの引数を受け入れることができます。

* リクエストしているコントローラーアクションのURI。これは文字列またはルートヘルパー（例：`articles_url`）の形式で指定できます。
* `params`：アクションに渡すリクエストパラメータのハッシュのオプション（クエリ文字列パラメータや記事変数など）。
* `headers`：リクエストと一緒に渡されるヘッダーを設定するためのもの。
* `env`：必要に応じてリクエスト環境をカスタマイズするためのもの。
* `xhr`：リクエストがAjaxリクエストかどうか。Ajaxリクエストとしてマークするためにtrueに設定できます。
* `as`：異なるコンテンツタイプでリクエストをエンコードするためのもの。

これらのキーワード引数はすべてオプションです。

例：最初の`Article`に対して`show`アクションを呼び出し、`HTTP_REFERER`ヘッダーを渡す場合。

```ruby
get article_url(Article.first), headers: { "HTTP_REFERER" => "http://example.com/home" }
```
別の例：Ajaxリクエストとして、最後の「Article」に対して`params`の`title`に新しいテキストを渡して`：update`アクションを呼び出す場合：

```ruby
patch article_url(Article.last), params: { article: { title: "updated" } }, xhr: true
```

もう1つの例：JSONリクエストとして、新しい記事を作成するために`params`の`title`にテキストを渡して`：create`アクションを呼び出す場合：

```ruby
post articles_path, params: { article: { title: "Ahoy!" } }, as: :json
```

注意：`articles_controller_test.rb`の`test_should_create_article`テストを実行しようとすると、新しく追加されたモデルレベルのバリデーションにより失敗します。

すべてのテストがパスするように`articles_controller_test.rb`の`test_should_create_article`テストを修正しましょう：

```ruby
test "should create article" do
  assert_difference("Article.count") do
    post articles_url, params: { article: { body: "Rails is awesome!", title: "Hello Rails" } }
  end

  assert_redirected_to article_path(Article.last)
end
```

これですべてのテストを実行して、パスするはずです。

注意：[Basic Authentication](getting_started.html#basic-authentication)セクションの手順に従った場合、すべてのテストをパスするためにすべてのリクエストヘッダーに認証情報を追加する必要があります：

```ruby
post articles_url, params: { article: { body: "Rails is awesome!", title: "Hello Rails" } }, headers: { Authorization: ActionController::HttpAuthentication::Basic.encode_credentials("dhh", "secret") }
```

### 機能テストで使用可能なリクエストタイプ

HTTPプロトコルに詳しい場合、`get`はリクエストの一種であることを知っているでしょう。Railsの機能テストでは、以下の6つのリクエストタイプがサポートされています：

* `get`
* `post`
* `patch`
* `put`
* `head`
* `delete`

すべてのリクエストタイプには使用できる同等のメソッドがあります。通常のC.R.U.D.アプリケーションでは、`get`、`post`、`put`、`delete`をより頻繁に使用します。

注意：機能テストでは、指定したリクエストタイプがアクションで受け入れられるかどうかを検証しません。結果に関心があります。このような場合には、リクエストテストが存在し、テストを目的に合わせるために使用できます。

### XHR（Ajax）リクエストのテスト

Ajaxリクエストをテストするには、`get`、`post`、`patch`、`put`、`delete`メソッドに`xhr: true`オプションを指定できます。例：

```ruby
test "ajax request" do
  article = articles(:one)
  get article_url(article), xhr: true

  assert_equal "hello world", @response.body
  assert_equal "text/javascript", @response.media_type
end
```

### 3つのApocalypseハッシュ

リクエストが作成され、処理された後、使用できる3つのハッシュオブジェクトがあります：

* `cookies` - 設定されたクッキー
* `flash` - flashに存在するオブジェクト
* `session` - セッション変数に存在するオブジェクト

通常のハッシュオブジェクトと同様に、キーを文字列で参照することで値にアクセスできます。また、シンボル名でも参照できます。例：

```ruby
flash["gordon"]               flash[:gordon]
session["shmession"]          session[:shmession]
cookies["are_good_for_u"]     cookies[:are_good_for_u]
```

### 利用可能なインスタンス変数

リクエストが作成された**後**、機能テストで3つのインスタンス変数にアクセスできます：

* `@controller` - リクエストを処理しているコントローラー
* `@request` - リクエストオブジェクト
* `@response` - レスポンスオブジェクト

```ruby
class ArticlesControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get articles_url

    assert_equal "index", @controller.action_name
    assert_equal "application/x-www-form-urlencoded", @request.media_type
    assert_match "Articles", @response.body
  end
end
```

### ヘッダーとCGI変数の設定

[HTTPヘッダー](https://tools.ietf.org/search/rfc2616#section-5.3)
および
[CGI変数](https://tools.ietf.org/search/rfc3875#section-4.1)
は、ヘッダーとして渡すことができます：

```ruby
# HTTPヘッダーの設定
get articles_url, headers: { "Content-Type": "text/plain" } # カスタムヘッダーでリクエストをシミュレート

# CGI変数の設定
get articles_url, headers: { "HTTP_REFERER": "http://example.com/home" } # カスタム環境変数でリクエストをシミュレート
```

### `flash`メッセージのテスト

以前に説明したように、Apocalypseハッシュの1つは`flash`です。

新しい記事が正常に作成された場合、ブログアプリケーションに`flash`メッセージを追加したいと思います。

まず、`test_should_create_article`テストにこのアサーションを追加しましょう：
```ruby
test "記事を作成することができる" do
  assert_difference("Article.count") do
    post articles_url, params: { article: { title: "Some title" } }
  end

  assert_redirected_to article_path(Article.last)
  assert_equal "記事が正常に作成されました。", flash[:notice]
end
```

テストを実行すると、失敗が表示されるはずです。

```bash
$ bin/rails test test/controllers/articles_controller_test.rb -n test_should_create_article
Run options: -n test_should_create_article --seed 32266

# Running:

F

Finished in 0.114870s, 8.7055 runs/s, 34.8220 assertions/s.

  1) Failure:
ArticlesControllerTest#test_should_create_article [/test/controllers/articles_controller_test.rb:16]:
--- expected
+++ actual
@@ -1 +1 @@
-"記事が正常に作成されました。"
+nil

1 runs, 4 assertions, 1 failures, 0 errors, 0 skips
```

コントローラーにフラッシュメッセージを実装しましょう。`create`アクションは以下のようになります。

```ruby
def create
  @article = Article.new(article_params)

  if @article.save
    flash[:notice] = "記事が正常に作成されました。"
    redirect_to @article
  else
    render "new"
  end
end
```

テストを実行すると、パスするはずです。

```bash
$ bin/rails test test/controllers/articles_controller_test.rb -n test_should_create_article
Run options: -n test_should_create_article --seed 18981

# Running:

.

Finished in 0.081972s, 12.1993 runs/s, 48.7972 assertions/s.

1 runs, 4 assertions, 0 failures, 0 errors, 0 skips
```

### まとめる

この時点で、Articlesコントローラーは`:index`、`:new`、`:create`アクションをテストしています。既存のデータに対処する方法はありますか？

`show`アクションのテストを書いてみましょう。

```ruby
test "記事を表示することができる" do
  article = articles(:one)
  get article_url(article)
  assert_response :success
end
```

フィクスチャのディスカッションで説明したように、`articles()`メソッドを使用してArticlesフィクスチャにアクセスできます。

既存の記事を削除する方法はありますか？

```ruby
test "記事を削除することができる" do
  article = articles(:one)
  assert_difference("Article.count", -1) do
    delete article_url(article)
  end

  assert_redirected_to articles_path
end
```

既存の記事を更新するテストも追加できます。

```ruby
test "記事を更新することができる" do
  article = articles(:one)

  patch article_url(article), params: { article: { title: "更新済み" } }

  assert_redirected_to article_path(article)
  # 更新されたデータを取得して、タイトルが更新されていることを確認するために関連をリロードする。
  article.reload
  assert_equal "更新済み", article.title
end
```

これらの3つのテストでは、同じ記事フィクスチャデータにアクセスしているため、重複が見られます。`ActiveSupport::Callbacks`が提供する`setup`と`teardown`メソッドを使用して、これをDRYにすることができます。

テストは以下のようになります。他のテストは簡潔にするために省略しています。

```ruby
require "test_helper"

class ArticlesControllerTest < ActionDispatch::IntegrationTest
  # 各テストの前に呼び出される
  setup do
    @article = articles(:one)
  end

  # 各テストの後に呼び出される
  teardown do
    # コントローラーがキャッシュを使用している場合は、後でリセットするのが良いアイデアです
    Rails.cache.clear
  end

  test "記事を表示することができる" do
    # setupで作成した@articleインスタンス変数を再利用
    get article_url(@article)
    assert_response :success
  end

  test "記事を削除することができる" do
    assert_difference("Article.count", -1) do
      delete article_url(@article)
    end

    assert_redirected_to articles_path
  end

  test "記事を更新することができる" do
    patch article_url(@article), params: { article: { title: "更新済み" } }

    assert_redirected_to article_path(@article)
    # 更新されたデータを取得して、タイトルが更新されていることを確認するために関連をリロードする。
    @article.reload
    assert_equal "更新済み", @article.title
  end
end
```

Railsの他のコールバックと同様に、`setup`と`teardown`メソッドは、ブロック、ラムダ、または呼び出すためのメソッド名を渡すことで使用することもできます。

### テストヘルパー(subtitle)

コードの重複を避けるために、独自のテストヘルパーを追加することができます。例として、サインインヘルパーを追加してみましょう。

```ruby
# test/test_helper.rb

module SignInHelper
  def sign_in_as(user)
    post sign_in_url(email: user.email, password: user.password)
  end
end

class ActionDispatch::IntegrationTest
  include SignInHelper
end
```

```ruby
require "test_helper"

class ProfileControllerTest < ActionDispatch::IntegrationTest
  test "プロフィールを表示することができる" do
    # ヘルパーはコントローラーテストケースから再利用できるようになりました
    sign_in_as users(:david)

    get profile_url
    assert_response :success
  end
end
```

#### 別のファイルを使用する

ヘルパーが`test_helper.rb`を混雑させている場合は、別のファイルに分割することもできます。`test/lib`または`test/test_helpers`に保存するのが適切です。
```ruby
# test/test_helpers/multiple_assertions.rb
module MultipleAssertions
  def assert_multiple_of_forty_two(number)
    assert (number % 42 == 0), "expected #{number} to be a multiple of 42"
  end
end
```

これらのヘルパーは必要に応じて明示的に要求され、必要に応じて含まれることができます。

```ruby
require "test_helper"
require "test_helpers/multiple_assertions"

class NumberTest < ActiveSupport::TestCase
  include MultipleAssertions

  test "420 is a multiple of forty two" do
    assert_multiple_of_forty_two 420
  end
end
```

または、関連する親クラスに直接含め続けることもできます。

```ruby
# test/test_helper.rb
require "test_helpers/sign_in_helper"

class ActionDispatch::IntegrationTest
  include SignInHelper
end
```

#### ヘルパーの積極的な要求

`test_helper.rb` でヘルパーを積極的に要求することで、テストファイルがそれらに暗黙的にアクセスできるようにすることができます。これは、次のようにグロブを使用して実現できます。

```ruby
# test/test_helper.rb
Dir[Rails.root.join("test", "test_helpers", "**", "*.rb")].each { |file| require file }
```

これにより、個々のテストで必要なファイルのみを手動で要求するよりも、起動時間が増加するというデメリットがあります。

ルートのテスト
--------------

Railsアプリケーションの他のすべてと同様に、ルートをテストすることもできます。ルートのテストは `test/controllers/` に存在するか、コントローラのテストの一部です。

注意: アプリケーションに複雑なルートがある場合、Railsはそれらをテストするための便利なヘルパーを提供しています。

Railsで利用可能なルーティングアサーションの詳細については、[`ActionDispatch::Assertions::RoutingAssertions`](https://api.rubyonrails.org/classes/ActionDispatch/Assertions/RoutingAssertions.html)のAPIドキュメントを参照してください。

ビューのテスト
-------------

要求に対するレスポンスをテストするために、キーとなるHTML要素とその内容の存在をアサートすることは、アプリケーションのビューをテストする一般的な方法です。ルートテストと同様に、ビューテストは `test/controllers/` に存在するか、コントローラのテストの一部です。`assert_select` メソッドを使用すると、シンプルでパワフルな構文を使ってレスポンスのHTML要素をクエリすることができます。

`assert_select` には2つの形式があります。

`assert_select(selector, [equality], [message])` は、セレクタを通じて選択された要素に対して等式条件が満たされていることを保証します。セレクタはCSSセレクタ式（文字列）または置換値を持つ式である場合があります。

`assert_select(element, selector, [equality], [message])` は、_element_（`Nokogiri::XML::Node`または`Nokogiri::XML::NodeSet`のインスタンス）とその子孫から始まるセレクタを通じて選択されたすべての要素に対して等式条件が満たされていることを保証します。

たとえば、次のようにしてレスポンスのタイトル要素の内容を検証できます。

```ruby
assert_select "title", "Welcome to Rails Testing Guide"
```

より深い調査のために、ネストされた `assert_select` ブロックを使用することもできます。

次の例では、外側のブロックで選択された要素のコレクション内で実行される `li.menu_item` の内部の `assert_select` が実行されます。

```ruby
assert_select "ul.navigation" do
  assert_select "li.menu_item"
end
```

選択された要素のコレクションは反復処理できるため、各要素に対して個別に `assert_select` を呼び出すことができます。

たとえば、レスポンスに2つの順序付きリストが含まれており、それぞれに4つのネストされたリスト要素がある場合、次のテストはどちらもパスします。

```ruby
assert_select "ol" do |elements|
  elements.each do |element|
    assert_select element, "li", 4
  end
end

assert_select "ol" do
  assert_select "li", 8
end
```

このアサーションは非常に強力です。より高度な使用法については、[ドキュメント](https://github.com/rails/rails-dom-testing/blob/master/lib/rails/dom/testing/assertions/selector_assertions.rb)を参照してください。

### 追加のビューベースのアサーション

ビューをテストする際に主に使用される他のアサーションがあります。

| アサーション                                                 | 目的 |
| --------------------------------------------------------- | ------- |
| `assert_select_email`                                     | メールの本文に対してアサーションを行うことができます。 |
| `assert_select_encoded`                                   | エンコードされたHTMLに対してアサーションを行うことができます。これは、各要素のエンコードを解除してから、すべてのエンコード解除された要素でブロックを呼び出すことによって行われます。|
| `css_select(selector)` または `css_select(element, selector)` | _selector_ によって選択されたすべての要素の配列を返します。2番目のバリアントでは、まず基本となる _element_ に一致し、その子のいずれかで _selector_ 式に一致しようとします。一致するものがない場合、両方のバリアントとも空の配列を返します。|
```
`assert_select_email`を使用する例を以下に示します。

```ruby
assert_select_email do
  assert_select "small", "Please click the 'Unsubscribe' link if you want to opt-out."
end
```

テストヘルパー
---------------

ヘルパーは、ビューで使用できるメソッドを定義するだけのシンプルなモジュールです。

ヘルパーをテストするには、単にヘルパーメソッドの出力が期待通りであることを確認するだけです。ヘルパーに関連するテストは、`test/helpers`ディレクトリの下に配置されています。

次のヘルパーがあるとします。

```ruby
module UsersHelper
  def link_to_user(user)
    link_to "#{user.first_name} #{user.last_name}", user
  end
end
```

このメソッドの出力を次のようにテストできます。

```ruby
class UsersHelperTest < ActionView::TestCase
  test "should return the user's full name" do
    user = users(:david)

    assert_dom_equal %{<a href="/user/#{user.id}">David Heinemeier Hansson</a>}, link_to_user(user)
  end
end
```

さらに、テストクラスは`ActionView::TestCase`を拡張しているため、`link_to`や`pluralize`などのRailsのヘルパーメソッドにアクセスできます。

メーラーのテスト
--------------------

メーラークラスをテストするには、徹底的なテストを行うためにいくつかの特定のツールが必要です。

### ポストマンをチェックする

メーラークラスは、Railsアプリケーションの他の部分と同様に、期待どおりに動作するかどうかをテストする必要があります。

メーラークラスをテストする目標は次のとおりです。

* メールが処理されていること（作成および送信）
* メールの内容が正しいこと（件名、送信者、本文など）
* 正しいタイミングで正しいメールが送信されていること

#### すべての面から

メーラーをテストするには、ユニットテストと機能テストの2つの側面があります。ユニットテストでは、メーラーを独立して実行し、厳密に制御された入力と既知の値（フィクスチャ）との出力を比較します。機能テストでは、メーラーが生成する細かい詳細をテストするのではなく、コントローラやモデルがメーラーを正しい方法で使用していることをテストします。正しいメールが正しいタイミングで送信されたことを証明するためにテストします。

### ユニットテスト

メーラーが期待どおりに動作していることをテストするために、ユニットテストを使用してメーラーの実際の結果と事前に作成された例とを比較することができます。

#### フィクスチャの復讐

メーラーのユニットテストの目的のために、フィクスチャは出力の例を提供するために使用されます。これらは他のフィクスチャとは異なり、メールの例であり、Active Recordのデータではありませんので、他のフィクスチャとは別のサブディレクトリに保管されます。`test/fixtures`内のディレクトリ名は、メーラーの名前と直接対応しています。したがって、`UserMailer`という名前のメーラーの場合、フィクスチャは`test/fixtures/user_mailer`ディレクトリに配置されるべきです。

メーラーを生成した場合、ジェネレータはメーラーのアクションのスタブフィクスチャを作成しません。上記の手順に従って、自分でこれらのファイルを作成する必要があります。

#### 基本的なテストケース

以下は、`UserMailer`という名前のメーラーの`invite`アクションを使用して友達に招待状を送信するためのユニットテストの例です。これは、`invite`アクションのためにジェネレータによって作成されたベーステストの適応バージョンです。

```ruby
require "test_helper"

class UserMailerTest < ActionMailer::TestCase
  test "invite" do
    # メールを作成して、さらなるアサーションのために保存する
    email = UserMailer.create_invite("me@example.com",
                                     "friend@example.com", Time.now)

    # メールを送信し、キューに追加されたことをテストする
    assert_emails 1 do
      email.deliver_now
    end

    # 送信されたメールの本文が期待通りであることをテストする
    assert_equal ["me@example.com"], email.from
    assert_equal ["friend@example.com"], email.to
    assert_equal "You have been invited by me@example.com", email.subject
    assert_equal read_fixture("invite").join, email.body.to_s
  end
end
```

テストでは、メールを作成し、返されたオブジェクトを`email`変数に格納します。次に、それが送信されたことを確認します（最初のアサーション）。次に、2番目のアサーションで、メールが実際に期待通りの内容を含んでいることを確認します。ヘルパー`read_fixture`は、このファイルからのコンテンツを読み込むために使用されます。
注意：`email.body.to_s`は、HTMLまたはテキストのいずれかのパートが存在する場合に表示されます。両方が提供される場合は、`email.text_part.body.to_s`または`email.html_part.body.to_s`を使用して特定のパートに対してフィクスチャをテストすることができます。

以下は、`invite`フィクスチャの内容です。

```
friend@example.com宛に招待されました。

乾杯！
```

これは、メーラーのテストについてもう少し理解するための適切な時期です。`config/environments/test.rb`の`ActionMailer::Base.delivery_method = :test`の行は、配信方法をテストモードに設定し、実際にメールを配信せずに（テスト中にユーザーにスパムを送信するのを避けるために便利です）代わりに配列（`ActionMailer::Base.deliveries`）に追加するようにします。

注意：`ActionMailer::Base.deliveries`配列は、`ActionMailer::TestCase`と`ActionDispatch::IntegrationTest`テストでのみ自動的にリセットされます。これらのテストケースの外部でクリーンな状態を保つ場合は、次のように手動でリセットできます：`ActionMailer::Base.deliveries.clear`

#### キューイングされたメールのテスト

`assert_enqueued_email_with`アサーションを使用して、メールが期待されるメーラーメソッドの引数と/またはパラメータ化されたメーラーパラメータと共にキューに入れられたことを確認できます。これにより、`deliver_later`メソッドでキューに入れられたメールを一致させることができます。

基本的なテストケースと同様に、メールを作成し、返されたオブジェクトを`email`変数に格納します。以下の例では、引数と/またはパラメータを渡すさまざまなバリエーションを含めています。

この例では、メールが正しい引数でキューに入れられたことをアサートします：

```ruby
require "test_helper"

class UserMailerTest < ActionMailer::TestCase
  test "invite" do
    # メールを作成し、追加のアサーションのために保存します
    email = UserMailer.create_invite("me@example.com", "friend@example.com")

    # メールが正しい引数でキューに入れられたことをテストします
    assert_enqueued_email_with UserMailer, :create_invite, args: ["me@example.com", "friend@example.com"] do
      email.deliver_later
    end
  end
end
```

この例では、ハッシュとして引数を渡すことで、メーラーメソッドの正しい名前付き引数でメーラーがキューに入れられたことをアサートします：

```ruby
require "test_helper"

class UserMailerTest < ActionMailer::TestCase
  test "invite" do
    # メールを作成し、追加のアサーションのために保存します
    email = UserMailer.create_invite(from: "me@example.com", to: "friend@example.com")

    # メールが正しい名前付き引数でキューに入れられたことをテストします
    assert_enqueued_email_with UserMailer, :create_invite, args: [{ from: "me@example.com",
                                                                    to: "friend@example.com" }] do
      email.deliver_later
    end
  end
end
```

この例では、パラメータ化されたメーラーが正しいパラメータと引数でキューに入れられたことをアサートします。メーラーパラメータは`params`として渡され、メーラーメソッドの引数は`args`として渡されます：

```ruby
require "test_helper"

class UserMailerTest < ActionMailer::TestCase
  test "invite" do
    # メールを作成し、追加のアサーションのために保存します
    email = UserMailer.with(all: "good").create_invite("me@example.com", "friend@example.com")

    # メールが正しいメーラーパラメータと引数でキューに入れられたことをテストします
    assert_enqueued_email_with UserMailer, :create_invite, params: { all: "good" },
                                                           args: ["me@example.com", "friend@example.com"] do
      email.deliver_later
    end
  end
end
```

この例では、パラメータ化されたメーラーが正しいパラメータでキューに入れられたことをテストする別の方法を示しています：

```ruby
require "test_helper"

class UserMailerTest < ActionMailer::TestCase
  test "invite" do
    # メールを作成し、追加のアサーションのために保存します
    email = UserMailer.with(to: "friend@example.com").create_invite

    # メールが正しいメーラーパラメータでキューに入れられたことをテストします
    assert_enqueued_email_with UserMailer.with(to: "friend@example.com"), :create_invite do
      email.deliver_later
    end
  end
end
```

### 機能テストとシステムテスト

ユニットテストでは、メールの属性をテストできますが、機能テストとシステムテストでは、ユーザーの操作が適切にメールの配信をトリガーするかどうかをテストできます。たとえば、友達を招待する操作が適切にメールを送信しているかどうかを確認できます：

```ruby
# 統合テスト
require "test_helper"

class UsersControllerTest < ActionDispatch::IntegrationTest
  test "invite friend" do
    # ActionMailer::Base.deliveriesの差分をアサートします
    assert_emails 1 do
      post invite_friend_url, params: { email: "friend@example.com" }
    end
  end
end
```

```ruby
# システムテスト
require "test_helper"

class UsersTest < ActionDispatch::SystemTestCase
  driven_by :selenium, using: :headless_chrome

  test "inviting a friend" do
    visit invite_users_url
    fill_in "Email", with: "friend@example.com"
    assert_emails 1 do
      click_on "Invite"
    end
  end
end
```
注意：`assert_emails`メソッドは特定の配信方法に結び付けられておらず、`deliver_now`メソッドまたは`deliver_later`メソッドで配信されるメールと共に動作します。メールがキューに追加されたことを明示的にアサートする場合は、`assert_enqueued_email_with`（[上記の例を参照](#testing-enqueued-emails)）または`assert_enqueued_emails`メソッドを使用できます。詳細については、[こちらのドキュメント](https://api.rubyonrails.org/classes/ActionMailer/TestHelper.html)を参照してください。

ジョブのテスト
------------

カスタムジョブはアプリケーション内のさまざまなレベルでキューに追加される可能性があるため、ジョブ自体のテスト（キューに追加されたときの動作）と、他のエンティティが正しくジョブをキューに追加することをテストする必要があります。

### 基本的なテストケース

ジョブを生成すると、デフォルトで`test/jobs`ディレクトリの下に関連するテストも生成されます。以下は請求ジョブの例です。

```ruby
require "test_helper"

class BillingJobTest < ActiveJob::TestCase
  test "アカウントが請求されること" do
    BillingJob.perform_now(account, product)
    assert account.reload.charged_for?(product)
  end
end
```

このテストは非常にシンプルで、ジョブが期待された動作を行ったことをアサートしています。

### カスタムアサーションと他のコンポーネント内のジョブのテスト

Active Jobには、テストの冗長性を減らすために使用できるカスタムアサーションがいくつか用意されています。使用可能なアサーションの完全なリストについては、[`ActiveJob::TestHelper`](https://api.rubyonrails.org/classes/ActiveJob/TestHelper.html)のAPIドキュメントを参照してください。

ジョブが正しくキューに追加されるか、または実行されるかを確認することは、良いプラクティスです（たとえば、コントローラ内で実行される場合など）。これは、Active Jobが提供するカスタムアサーションが非常に便利な場所です。たとえば、モデル内では、ジョブがキューに追加されたことを確認できます。

```ruby
require "test_helper"

class ProductTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  test "請求ジョブのスケジューリング" do
    assert_enqueued_with(job: BillingJob) do
      product.charge(account)
    end
    assert_not account.reload.charged_for?(product)
  end
end
```

デフォルトのアダプタである`:test`は、ジョブがキューに追加されたときにジョブを実行しません。ジョブを実行するタイミングを指定する必要があります。

```ruby
require "test_helper"

class ProductTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  test "請求ジョブのスケジューリング" do
    perform_enqueued_jobs(only: BillingJob) do
      product.charge(account)
    end
    assert account.reload.charged_for?(product)
  end
end
```

以前に実行されたジョブとキューに追加されたジョブは、テストが実行される前にすべてクリアされるため、各テストのスコープ内で既に実行されたジョブはないと安全に想定できます。

Action Cableのテスト
--------------------

Action Cableはアプリケーション内のさまざまなレベルで使用されるため、チャネル、接続クラス自体、および他のエンティティが正しいメッセージをブロードキャストすることをテストする必要があります。

### 接続テストケース

デフォルトでは、Action Cableを使用して新しいRailsアプリケーションを生成すると、ベースの接続クラス（`ApplicationCable::Connection`）のテストも`test/channels/application_cable`ディレクトリの下に生成されます。

接続テストは、接続の識別子が適切に割り当てられるか、または不適切な接続リクエストが拒否されるかを確認するためのものです。以下は例です。

```ruby
class ApplicationCable::ConnectionTest < ActionCable::Connection::TestCase
  test "パラメータを使用して接続する" do
    # `connect`メソッドを呼び出すことで接続の開始をシミュレートします
    connect params: { user_id: 42 }

    # テスト内では`connection`を介してConnectionオブジェクトにアクセスできます
    assert_equal connection.user_id, "42"
  end

  test "パラメータなしで接続を拒否する" do
    # `assert_reject_connection`マッチャを使用して、接続が拒否されたことを検証します
    assert_reject_connection { connect }
  end
end
```

統合テストと同じ方法でリクエストのクッキーを指定することもできます。

```ruby
test "クッキーを使用して接続する" do
  cookies.signed[:user_id] = "42"

  connect

  assert_equal connection.user_id, "42"
end
```

詳細については、[`ActionCable::Connection::TestCase`](https://api.rubyonrails.org/classes/ActionCable/Connection/TestCase.html)のAPIドキュメントを参照してください。

### チャネルテストケース

チャネルを生成すると、デフォルトで`test/channels`ディレクトリの下に関連するテストも生成されます。以下はチャットチャネルの例です。

```ruby
require "test_helper"

class ChatChannelTest < ActionCable::Channel::TestCase
  test "ルームの購読とストリーム" do
    # `subscribe`を呼び出すことで購読の作成をシミュレートします
    subscribe room: "15"

    # テスト内では`subscription`を介してChannelオブジェクトにアクセスできます
    assert subscription.confirmed?
    assert_has_stream "chat_15"
  end
end
```
このテストは非常にシンプルで、チャネルが特定のストリームに接続を購読することをアサートします。

また、基礎となる接続識別子を指定することもできます。以下はWeb通知チャネルを使用したテストの例です。

```ruby
require "test_helper"

class WebNotificationsChannelTest < ActionCable::Channel::TestCase
  test "ユーザーの購読とストリーム" do
    stub_connection current_user: users(:john)

    subscribe

    assert_has_stream_for users(:john)
  end
end
```

詳細については、[`ActionCable::Channel::TestCase`](https://api.rubyonrails.org/classes/ActionCable/Channel/TestCase.html)のAPIドキュメントを参照してください。

### カスタムアサーションと他のコンポーネント内でのブロードキャストのテスト

Action Cableには、テストの冗長性を減らすために使用できるカスタムアサーションがいくつか用意されています。使用可能なアサーションの完全なリストについては、[`ActionCable::TestHelper`](https://api.rubyonrails.org/classes/ActionCable/TestHelper.html)のAPIドキュメントを参照してください。

正しいメッセージが他のコンポーネント（例：コントローラ内）でブロードキャストされたことを確認することは、良いプラクティスです。これは、Action Cableが提供するカスタムアサーションが非常に便利な場所です。たとえば、モデル内では次のようになります。

```ruby
require "test_helper"

class ProductTest < ActionCable::TestCase
  test "チャージ後にステータスをブロードキャストする" do
    assert_broadcast_on("products:#{product.id}", type: "charged") do
      product.charge(account)
    end
  end
end
```

`Channel.broadcast_to`で行われたブロードキャストをテストする場合は、`Channel.broadcasting_for`を使用して基礎となるストリーム名を生成する必要があります。

```ruby
# app/jobs/chat_relay_job.rb
class ChatRelayJob < ApplicationJob
  def perform(room, message)
    ChatChannel.broadcast_to room, text: message
  end
end
```

```ruby
# test/jobs/chat_relay_job_test.rb
require "test_helper"

class ChatRelayJobTest < ActiveJob::TestCase
  include ActionCable::TestHelper

  test "ルームにメッセージをブロードキャストする" do
    room = rooms(:all)

    assert_broadcast_on(ChatChannel.broadcasting_for(room), text: "Hi!") do
      ChatRelayJob.perform_now(room, "Hi!")
    end
  end
end
```

Eager Loadingのテスト
---------------------

通常、アプリケーションは`development`または`test`環境ではイーガーロードされず、処理を高速化します。ただし、`production`環境ではイーガーロードされます。

プロジェクト内のいくつかのファイルが何らかの理由でロードできない場合、本番環境にデプロイする前に検出する方が良いですよね？

### 継続的インテグレーション

プロジェクトに継続的インテグレーション（CI）がある場合、CIでのイーガーロードはアプリケーションのイーガーロードを確認するための簡単な方法です。

CIは通常、テストスイートが実行されていることを示すための環境変数を設定します。たとえば、`CI`という名前になることがあります。

```ruby
# config/environments/test.rb
config.eager_load = ENV["CI"].present?
```

Rails 7以降、新しく生成されたアプリケーションはデフォルトでこのように設定されています。

### ベアテストスイート

プロジェクトに継続的インテグレーションがない場合でも、`Rails.application.eager_load!`を呼び出すことでテストスイートでイーガーロードを行うことができます。

#### Minitest

```ruby
require "test_helper"

class ZeitwerkComplianceTest < ActiveSupport::TestCase
  test "エラーなくすべてのファイルをイーガーロードする" do
    assert_nothing_raised { Rails.application.eager_load! }
  end
end
```

#### RSpec

```ruby
require "rails_helper"

RSpec.describe "Zeitwerkの準拠性" do
  it "エラーなくすべてのファイルをイーガーロードする" do
    expect { Rails.application.eager_load! }.not_to raise_error
  end
end
```

追加のテストリソース
----------------------------

### 時間依存コードのテスト

Railsは、時間に依存するコードが期待どおりに動作することをアサートするための組み込みのヘルパーメソッドを提供しています。

以下の例では、[`travel_to`][travel_to]ヘルパーを使用しています。

```ruby
# ユーザーが登録してから1ヶ月後にギフトが可能になるとします。
user = User.create(name: "Gaurish", activation_date: Date.new(2004, 10, 24))
assert_not user.applicable_for_gifting?

travel_to Date.new(2004, 11, 24) do
  # `travel_to`ブロック内では`Date.current`がスタブ化されます
  assert_equal Date.new(2004, 10, 24), user.activation_date
  assert user.applicable_for_gifting?
end

# 変更は`travel_to`ブロック内でのみ可視です。
assert_equal Date.new(2004, 10, 24), user.activation_date
```

詳細については、利用可能な時間ヘルパーに関する情報については、[`ActiveSupport::Testing::TimeHelpers`][time_helpers_api]のAPIリファレンスを参照してください。
[`config.active_support.test_order`]: configuring.html#config-active-support-test-order
[image/png]: https://developer.mozilla.org/en-US/docs/Web/HTTP/Basics_of_HTTP/MIME_types#image_types
[travel_to]: https://api.rubyonrails.org/classes/ActiveSupport/Testing/TimeHelpers.html#method-i-travel_to
[time_helpers_api]: https://api.rubyonrails.org/classes/ActiveSupport/Testing/TimeHelpers.html
