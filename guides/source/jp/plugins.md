**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: b550120024fb17dc176480922543264e
Railsプラグインの基礎
=========================

Railsプラグインは、コアフレームワークの拡張または変更です。プラグインは以下を提供します：

* 安定したコードベースに影響を与えずに、開発者が最新のアイデアを共有する方法。
* コードのユニットを個別に修正または更新できるセグメント化されたアーキテクチャ。
* コア開発者がすべての新機能を含める必要がないためのアウトレット。

このガイドを読み終えると、以下がわかるようになります：

* スクラッチからプラグインを作成する方法。
* プラグインのテストを書いて実行する方法。

このガイドでは、以下のようなテスト駆動型のプラグインの構築方法について説明します：

* HashやStringのようなコアRubyクラスを拡張する。
* `acts_as`プラグインの伝統に従って`ApplicationRecord`にメソッドを追加する。
* プラグイン内のジェネレータを配置する場所に関する情報を提供する。

このガイドの目的のために、一時的に熱心な鳥観察家であるかのように振る舞ってください。
お気に入りの鳥はYaffleで、他の開発者とYaffleの良さを共有できるプラグインを作成したいと思います。

--------------------------------------------------------------------------------

セットアップ
------------

現在、Railsプラグインはジェムとして構築されます。_ジェム化されたプラグイン_と呼ばれます。必要に応じて、RubyGemsとBundlerを使用して異なるRailsアプリケーション間で共有することができます。

### ジェム化されたプラグインの生成

Railsには、ダミーのRailsアプリケーションを使用して統合テストを実行する機能を備えた、あらゆる種類のRails拡張を開発するためのスケルトンを作成する`rails plugin new`コマンドが付属しています。次のコマンドでプラグインを作成します：

```bash
$ rails plugin new yaffle
```

ヘルプを表示するには、使用方法とオプションを確認してください：

```bash
$ rails plugin new --help
```

新しく生成されたプラグインをテストする
--------------------------------------

プラグインが含まれているディレクトリに移動し、`yaffle.gemspec`を編集して`TODO`の値が含まれる行を置き換えます：

```ruby
spec.homepage    = "http://example.com"
spec.summary     = "Summary of Yaffle."
spec.description = "Description of Yaffle."

...

spec.metadata["source_code_uri"] = "http://example.com"
spec.metadata["changelog_uri"] = "http://example.com"
```

その後、`bundle install`コマンドを実行します。

`bin/test`コマンドを使用してテストを実行し、次のように表示されるはずです：

```bash
$ bin/test
...
1 runs, 1 assertions, 0 failures, 0 errors, 0 skips
```

これにより、すべてが正しく生成され、機能の追加を開始する準備が整いました。

コアクラスの拡張
----------------

このセクションでは、Railsアプリケーションのどこからでも利用できるStringにメソッドを追加する方法について説明します。

この例では、Stringに`to_squawk`という名前のメソッドを追加します。まず、いくつかのアサーションを持つ新しいテストファイルを作成します：

```ruby
# yaffle/test/core_ext_test.rb

require "test_helper"

class CoreExtTest < ActiveSupport::TestCase
  def test_to_squawk_prepends_the_word_squawk
    assert_equal "squawk! Hello World", "Hello World".to_squawk
  end
end
```

テストを実行するには、`bin/test`を実行します。このテストは失敗するはずです。なぜなら、`to_squawk`メソッドを実装していないからです：

```bash
$ bin/test
E

Error:
CoreExtTest#test_to_squawk_prepends_the_word_squawk:
NoMethodError: undefined method `to_squawk' for "Hello World":String


bin/test /path/to/yaffle/test/core_ext_test.rb:4

.

Finished in 0.003358s, 595.6483 runs/s, 297.8242 assertions/s.
2 runs, 1 assertions, 0 failures, 1 errors, 0 skips
```

素晴らしい - これで開発を開始する準備が整いました。

`lib/yaffle.rb`に`require "yaffle/core_ext"`を追加します：

```ruby
# yaffle/lib/yaffle.rb

require "yaffle/version"
require "yaffle/railtie"
require "yaffle/core_ext"

module Yaffle
  # Your code goes here...
end
```

最後に、`core_ext.rb`ファイルを作成し、`to_squawk`メソッドを追加します：

```ruby
# yaffle/lib/yaffle/core_ext.rb

class String
  def to_squawk
    "squawk! #{self}".strip
  end
end
```

メソッドが期待どおりの動作をするかテストするには、プラグインディレクトリから`bin/test`でユニットテストを実行します。

```
$ bin/test
...
2 runs, 2 assertions, 0 failures, 0 errors, 0 skips
```

これを実際に確認するために、`test/dummy`ディレクトリに移動し、`bin/rails console`を起動して鳴き声を聞いてみましょう：

```irb
irb> "Hello World".to_squawk
=> "squawk! Hello World"
```

Active Recordに"acts_as"メソッドを追加する
--------------------------------------------

プラグインでよく使われるパターンは、モデルに`acts_as_something`というメソッドを追加することです。この場合、Active Recordモデルに`squawk`メソッドを追加する`acts_as_yaffle`というメソッドを作成したいと思います。

まず、次のようなファイルをセットアップします：

```ruby
# yaffle/test/acts_as_yaffle_test.rb

require "test_helper"

class ActsAsYaffleTest < ActiveSupport::TestCase
end
```

```ruby
# yaffle/lib/yaffle.rb

require "yaffle/version"
require "yaffle/railtie"
require "yaffle/core_ext"
require "yaffle/acts_as_yaffle"

module Yaffle
  # Your code goes here...
end
```

```ruby
# yaffle/lib/yaffle/acts_as_yaffle.rb

module Yaffle
  module ActsAsYaffle
  end
end
```
### クラスメソッドを追加する

このプラグインでは、モデルに `last_squawk` という名前のメソッドが追加されていることを期待しています。ただし、プラグインのユーザーは、すでに `last_squawk` という名前のメソッドをモデルに定義して、他の用途で使用しているかもしれません。このプラグインでは、`yaffle_text_field` というクラスメソッドを追加することで、名前を変更できるようにします。

まず、望む動作を示す失敗するテストを書いてください。

```ruby
# yaffle/test/acts_as_yaffle_test.rb

require "test_helper"

class ActsAsYaffleTest < ActiveSupport::TestCase
  def test_a_hickwalls_yaffle_text_field_should_be_last_squawk
    assert_equal "last_squawk", Hickwall.yaffle_text_field
  end

  def test_a_wickwalls_yaffle_text_field_should_be_last_tweet
    assert_equal "last_tweet", Wickwall.yaffle_text_field
  end
end
```

`bin/test` を実行すると、次のようになります。

```bash
$ bin/test
# Running:

..E

Error:
ActsAsYaffleTest#test_a_wickwalls_yaffle_text_field_should_be_last_tweet:
NameError: uninitialized constant ActsAsYaffleTest::Wickwall


bin/test /path/to/yaffle/test/acts_as_yaffle_test.rb:8

E

Error:
ActsAsYaffleTest#test_a_hickwalls_yaffle_text_field_should_be_last_squawk:
NameError: uninitialized constant ActsAsYaffleTest::Hickwall


bin/test /path/to/yaffle/test/acts_as_yaffle_test.rb:4



Finished in 0.004812s, 831.2949 runs/s, 415.6475 assertions/s.
4 runs, 2 assertions, 0 failures, 2 errors, 0 skips
```

これにより、テストしようとしているモデル（Hickwall と Wickwall）が存在しないことがわかります。ダミーのRailsアプリケーションでこれらのモデルを簡単に生成できます。`test/dummy` ディレクトリから次のコマンドを実行します。

```bash
$ cd test/dummy
$ bin/rails generate model Hickwall last_squawk:string
$ bin/rails generate model Wickwall last_squawk:string last_tweet:string
```

次に、ダミーアプリケーションに必要なデータベーステーブルを作成するために、ダミーアプリケーションに移動してデータベースをマイグレーションします。まず、次を実行します。

```bash
$ cd test/dummy
$ bin/rails db:migrate
```

ここで、Hickwall と Wickwall モデルを変更して、yaffle のように動作するようにします。

```ruby
# test/dummy/app/models/hickwall.rb

class Hickwall < ApplicationRecord
  acts_as_yaffle
end
```

```ruby
# test/dummy/app/models/wickwall.rb

class Wickwall < ApplicationRecord
  acts_as_yaffle yaffle_text_field: :last_tweet
end
```

また、`acts_as_yaffle` メソッドを定義するためのコードを追加します。

```ruby
# yaffle/lib/yaffle/acts_as_yaffle.rb

module Yaffle
  module ActsAsYaffle
    extend ActiveSupport::Concern

    class_methods do
      def acts_as_yaffle(options = {})
      end
    end
  end
end
```

```ruby
# test/dummy/app/models/application_record.rb

class ApplicationRecord < ActiveRecord::Base
  include Yaffle::ActsAsYaffle

  self.abstract_class = true
end
```

その後、プラグインのルートディレクトリに戻り、`bin/test` を使用してテストを再実行します。

```bash
$ bin/test
# Running:

.E

Error:
ActsAsYaffleTest#test_a_hickwalls_yaffle_text_field_should_be_last_squawk:
NoMethodError: undefined method `yaffle_text_field' for #<Class:0x0055974ebbe9d8>


bin/test /path/to/yaffle/test/acts_as_yaffle_test.rb:4

E

Error:
ActsAsYaffleTest#test_a_wickwalls_yaffle_text_field_should_be_last_tweet:
NoMethodError: undefined method `yaffle_text_field' for #<Class:0x0055974eb8cfc8>


bin/test /path/to/yaffle/test/acts_as_yaffle_test.rb:8

.

Finished in 0.008263s, 484.0999 runs/s, 242.0500 assertions/s.
4 runs, 2 assertions, 0 failures, 2 errors, 0 skips
```

もう少しで完成です... これでテストが成功するようにするために、`acts_as_yaffle` メソッドのコードを実装します。

```ruby
# yaffle/lib/yaffle/acts_as_yaffle.rb

module Yaffle
  module ActsAsYaffle
    extend ActiveSupport::Concern

    class_methods do
      def acts_as_yaffle(options = {})
        cattr_accessor :yaffle_text_field, default: (options[:yaffle_text_field] || :last_squawk).to_s
      end
    end
  end
end
```

```ruby
# test/dummy/app/models/application_record.rb

class ApplicationRecord < ActiveRecord::Base
  include Yaffle::ActsAsYaffle

  self.abstract_class = true
end
```

`bin/test` を実行すると、すべてのテストが成功するはずです。

```bash
$ bin/test
...
4 runs, 4 assertions, 0 failures, 0 errors, 0 skips
```

### インスタンスメソッドを追加する

このプラグインは、`acts_as_yaffle` を呼び出すすべての Active Record オブジェクトに `squawk` というメソッドを追加します。`squawk` メソッドは、データベースのフィールドの値を単純に設定します。

まず、望む動作を示す失敗するテストを書いてください。

```ruby
# yaffle/test/acts_as_yaffle_test.rb
require "test_helper"

class ActsAsYaffleTest < ActiveSupport::TestCase
  def test_a_hickwalls_yaffle_text_field_should_be_last_squawk
    assert_equal "last_squawk", Hickwall.yaffle_text_field
  end

  def test_a_wickwalls_yaffle_text_field_should_be_last_tweet
    assert_equal "last_tweet", Wickwall.yaffle_text_field
  end

  def test_hickwalls_squawk_should_populate_last_squawk
    hickwall = Hickwall.new
    hickwall.squawk("Hello World")
    assert_equal "squawk! Hello World", hickwall.last_squawk
  end

  def test_wickwalls_squawk_should_populate_last_tweet
    wickwall = Wickwall.new
    wickwall.squawk("Hello World")
    assert_equal "squawk! Hello World", wickwall.last_tweet
  end
end
```

テストを実行して、最後の2つのテストが「NoMethodError: undefined method \`squawk'」というエラーで失敗することを確認し、次に `acts_as_yaffle.rb` を次のように更新します。

```ruby
# yaffle/lib/yaffle/acts_as_yaffle.rb

module Yaffle
  module ActsAsYaffle
    extend ActiveSupport::Concern

    included do
      def squawk(string)
        write_attribute(self.class.yaffle_text_field, string.to_squawk)
      end
    end

    class_methods do
      def acts_as_yaffle(options = {})
        cattr_accessor :yaffle_text_field, default: (options[:yaffle_text_field] || :last_squawk).to_s
      end
    end
  end
end
```

```ruby
# test/dummy/app/models/application_record.rb

class ApplicationRecord < ActiveRecord::Base
  include Yaffle::ActsAsYaffle

  self.abstract_class = true
end
```

最後に、`bin/test` を実行し、次のようになるはずです。

```bash
$ bin/test
...
6 runs, 6 assertions, 0 failures, 0 errors, 0 skips
```

注意: モデル内のフィールドに書き込むために `write_attribute` を使用する例は、プラグインがモデルとやり取りする方法の一例であり、常に適切なメソッドではありません。たとえば、次のようにも書くことができます。
```ruby
send("#{self.class.yaffle_text_field}=", string.to_squawk)
```

ジェネレータ
----------

ジェネレータは、プラグインの`lib/generators`ディレクトリに作成することで、簡単にgemに含めることができます。ジェネレータの作成に関する詳細な情報は、[ジェネレータガイド](generators.html)を参照してください。

Gemの公開
-------------------

開発中のGemプラグインは、Gitリポジトリから簡単に共有することができます。Yaffle gemを他の人と共有するには、コードをGitリポジトリ（GitHubなど）にコミットし、対象のアプリケーションの`Gemfile`に行を追加します。

```ruby
gem "yaffle", git: "https://github.com/rails/yaffle.git"
```

`bundle install`を実行した後、アプリケーションでgemの機能が利用できるようになります。

Gemを正式リリースとして共有する準備ができたら、[RubyGems](https://rubygems.org)に公開することができます。

また、BundlerのRakeタスクを利用することもできます。以下のコマンドで一覧を表示できます。

```bash
$ bundle exec rake -T

$ bundle exec rake build
# yaffle-0.1.0.gemをpkgディレクトリにビルドします

$ bundle exec rake install
# yaffle-0.1.0.gemをビルドしてシステムのgemにインストールします

$ bundle exec rake release
# タグv0.1.0を作成し、yaffle-0.1.0.gemをビルドしてRubygemsにプッシュします
```

RubyGemsへのgemの公開に関する詳細な情報については、[gemの公開](https://guides.rubygems.org/publishing)を参照してください。

RDocドキュメント
------------------

プラグインが安定しており、デプロイする準備が整ったら、他の人のためにもドキュメントを作成しましょう！幸いなことに、プラグインのドキュメントを作成するのは簡単です。

最初のステップは、READMEファイルを詳細な情報で更新することです。含めるべきいくつかの重要な情報は次のとおりです。

* あなたの名前
* インストール方法
* アプリケーションに機能を追加する方法（一般的な使用例のいくつか）
* ユーザーの助けになる警告、注意点、またはヒント

READMEが完成したら、開発者が使用するすべてのメソッドにRDocコメントを追加します。また、公開APIに含まれないコードの部分には通常、`# :nodoc:`コメントを追加することが慣例です。

コメントが準備できたら、プラグインディレクトリに移動して次のコマンドを実行します。

```bash
$ bundle exec rake rdoc
```

### 参考文献

* [Bundlerを使用したRubyGemの開発](https://github.com/radar/guides/blob/master/gem-development.md)
* [意図したとおりに.gemspecを使用する](https://yehudakatz.com/2010/04/02/using-gemspecs-as-intended/)
* [Gemspecリファレンス](https://guides.rubygems.org/specification-reference/)
