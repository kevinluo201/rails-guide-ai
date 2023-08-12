**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 58b6e6f83da0f420f5da5f7d38d938db
APIドキュメントガイドライン
============================

このガイドは、Ruby on RailsのAPIドキュメントのガイドラインを文書化しています。

このガイドを読むことで、以下のことがわかります：

* ドキュメント目的のための効果的な文章の書き方
* 異なる種類のRubyコードのドキュメント化のスタイルガイド

--------------------------------------------------------------------------------

RDoc
----

[Rails APIドキュメント](https://api.rubyonrails.org)は[RDoc](https://ruby.github.io/rdoc/)で生成されます。生成するには、railsのルートディレクトリにいることを確認し、`bundle install`を実行してから次のコマンドを実行します：

```bash
$ bundle exec rake rdoc
```

生成されたHTMLファイルは、./doc/rdocディレクトリにあります。

注意：構文に関するヘルプについては、RDocの[マークアップリファレンス][RDoc Markup]を参照してください。

リンク
-----

Rails APIドキュメントはGitHubで表示することを意図していないため、リンクは現在のAPIに対してRDocの[`link`][RDoc Links]マークアップを使用する必要があります。

これは、GitHub Markdownと[api.rubyonrails.org](https://api.rubyonrails.org)および[edgeapi.rubyonrails.org](https://edgeapi.rubyonrails.org)で公開される生成されたRDocの間の違いによるものです。

例えば、RDocによって生成された`ActiveRecord::Base`クラスへのリンクを作成するために、`[link:classes/ActiveRecord/Base.html]`を使用します。

これは、`[https://api.rubyonrails.org/classes/ActiveRecord/Base.html]`などの絶対URLよりも好まれます。絶対URLは、読者を現在のドキュメントバージョン（例：edgeapi.rubyonrails.org）の外に連れ出してしまいます。

[RDoc Markup]: https://ruby.github.io/rdoc/RDoc/MarkupReference.html
[RDoc Links]: https://ruby.github.io/rdoc/RDoc/MarkupReference.html#class-RDoc::MarkupReference-label-Links

文言
----

シンプルで明確な文を書いてください。簡潔さはプラスです：要点に入りましょう。

現在形で書いてください。「Returns a hash that...」と書く代わりに、「Returned a hash that...」や「Will return a hash that...」と書かないようにしてください。

コメントは大文字で始めてください。通常の句読法のルールに従ってください：

```ruby
# Declares an attribute reader backed by an internally-named
# instance variable.
def attr_internal_reader(*attrs)
  # ...
end
```

読者に現在のやり方を明示的に、そして暗黙的に伝えてください。推奨されるイディオムを使用してください。必要に応じてセクションの順序を変更して、好ましいアプローチを強調してください。ドキュメントは、ベストプラクティスと標準的な、現代的なRailsの使用方法のモデルである必要があります。

ドキュメントは簡潔でありながら包括的である必要があります。エッジケースを探索し、文書化してください。モジュールが匿名の場合はどうなりますか？コレクションが空の場合はどうなりますか？引数がnilの場合はどうなりますか？

Railsのコンポーネントの正式な名前には、スペースが含まれています。例えば、「Active Support」というようにです。`ActiveRecord`はRubyのモジュールであり、Active RecordはORMです。Railsのドキュメントでは、すべてのRailsコンポーネントを正式な名前で一貫して参照する必要があります。

「Railsアプリケーション」という言葉を参照する場合、「エンジン」や「プラグイン」とは異なり、常に「アプリケーション」を使用してください。Railsアプリは「サービス」ではありません。ただし、サービス指向アーキテクチャについて特に議論する場合を除きます。

名前を正しくスペルしてください：Arel、minitest、RSpec、HTML、MySQL、JavaScript、ERB、Hotwire。疑わしい場合は、公式のドキュメントなどの信頼性のある情報源を参照してください。

「SQL」に対しては、冠詞「an」を使用してください。例：「an SQL statement」。また、「an SQLite database」とも言います。

「you」や「your」を避けるような表現を好んでください。例えば、次のようなスタイルではなく、

```markdown
If you need to use `return` statements in your callbacks, it is recommended that you explicitly define them as methods.
```

次のスタイルを使用してください：

```markdown
If `return` is needed, it is recommended to explicitly define a method.
```

ただし、仮想の人物を参照する際に代名詞を使用する場合、「a user with a session cookie」といった性別中立の代名詞（they/their/them）を使用する必要があります。例えば：

* heまたはshe... theyを使用する。
* himまたはher... themを使用する。
* hisまたはher... theirを使用する。
* hisまたはhers... theirsを使用する。
* himselfまたはherself... themselvesを使用する。

英語
----

アメリカ英語を使用してください（*color*、*center*、*modularize*など）。[ここでアメリカ英語とイギリス英語のスペルの違いのリストを見ることができます](https://en.wikipedia.org/wiki/American_and_British_English_spelling_differences)。

オックスフォードカンマ
----------------------

[オックスフォードカンマ](https://en.wikipedia.org/wiki/Serial_comma)を使用してください（「red, white, and blue」のように、「red, white and blue」とは書かないでください）。

コードの例
----------

基本的なポイントや注意点を示す意味のある例を選んでください。

コードのチャンクをインデントするためには、左のマージンに対して2つのスペースを使用してください。例自体は[Railsのコーディング規約](contributing_to_ruby_on_rails.html#follow-the-coding-conventions)を使用する必要があります。

短いドキュメントには、スニペットを紹介するための明示的な「Examples」ラベルは必要ありません。パラグラフに続けて記述してください：

```ruby
# Converts a collection of elements into a formatted string by
# calling +to_s+ on all elements and joining them.
#
#   Blog.all.to_fs # => "First PostSecond PostThird Post"
```

一方、大きな構造化されたドキュメントのチャンクには、別個の「Examples」セクションがある場合があります：

```ruby
# ==== Examples
#
#   Person.exists?(5)
#   Person.exists?('5')
#   Person.exists?(name: "David")
#   Person.exists?(['name LIKE ?', "%#{query}%"])
```
式の結果は、それに続いて "# => " が入り、縦に整列されます。

```ruby
# 整数が偶数か奇数かを確認するためのもの。
#
#   1.even? # => false
#   1.odd?  # => true
#   2.even? # => true
#   2.odd?  # => false
```

行が長すぎる場合は、コメントを次の行に配置することができます。

```ruby
#   label(:article, :title)
#   # => <label for="article_title">Title</label>
#
#   label(:article, :title, "A short title")
#   # => <label for="article_title">A short title</label>
#
#   label(:article, :title, "A short title", class: "title_label")
#   # => <label for="article_title" class="title_label">A short title</label>
```

その目的のために `puts` や `p` のような出力メソッドを使用しないでください。

一方、通常のコメントには矢印を使用しません。

```ruby
#   polymorphic_url(record)  # same as comment_url(record)
```

### SQL

SQL文を文書化する場合、出力の前に `=>` を付けないでください。

例えば、

```ruby
#   User.where(name: 'Oscar').to_sql
#   # SELECT "users".* FROM "users"  WHERE "users"."name" = 'Oscar'
```

### IRB

IRB（Rubyの対話型REPL）の動作を文書化する場合、コマンドの前に常に `irb>` を付け、出力は `=>` で始めてください。

例えば、

```
# Find the customer with primary key (id) 10.
#   irb> customer = Customer.find(10)
#   # => #<Customer id: 10, first_name: "Ryan">
```

### Bash / コマンドライン

コマンドラインの例では、コマンドの前に常に `$` を付け、出力には何も付けません。

```
# Run the following command:
#   $ bin/rails new zomg
#   ...
```

ブール値
--------

述語やフラグの場合、正確な値よりもブール値の意味を文書化することを優先してください。

Rubyで定義された "true" または "false" が使用される場合は、通常のフォントを使用してください。
シングルトンの `true` と `false` は固定幅フォントを使用してください。"truthy" のような用語は避けてください。
Rubyは言語で真と偽を定義しているため、これらの単語には技術的な意味があり、代替語は必要ありません。

一般的なルールとして、絶対に必要でない限りシングルトンを文書化しないでください。
これにより、`!!` や三項演算子のような人工的な構造を防ぎ、リファクタリングが可能になり、
コードは実装で呼び出されるメソッドの正確な返り値に依存する必要がありません。

例えば:

```markdown
`config.action_mailer.perform_deliveries` はメールが実際に配信されるかどうかを指定し、デフォルトでは true です。
```

ユーザーはフラグの実際のデフォルト値を知る必要はないため、ブール値の意味だけを文書化します。

述語の例:

```ruby
# Returns true if the collection is empty.
#
# If the collection has been loaded
# it is equivalent to <tt>collection.size.zero?</tt>. If the
# collection has not been loaded, it is equivalent to
# <tt>!collection.exists?</tt>. If the collection has not already been
# loaded and you are going to fetch the records anyway it is better to
# check <tt>collection.length.zero?</tt>.
def empty?
  if loaded?
    size.zero?
  else
    @target.blank? && !scope.exists?
  end
end
```

APIは特定の値にコミットしないように注意しています。メソッドは述語の意味を持っているので、それで十分です。

ファイル名
----------

原則として、アプリケーションのルートに対する相対パスのファイル名を使用してください。

```
config/routes.rb            # YES
routes.rb                   # NO
RAILS_ROOT/config/routes.rb # NO
```

フォント
-----

### 固定幅フォント

固定幅フォントを使用する場合:

* 定数、特にクラスやモジュール名。
* メソッド名。
* `nil`、`false`、`true`、`self` のようなリテラル。
* シンボル。
* メソッドのパラメータ。
* ファイル名。

```ruby
class Array
  # Calls +to_param+ on all its elements and joins the result with
  # slashes. This is used by +url_for+ in Action Pack.
  def to_param
    collect { |e| e.to_param }.join '/'
  end
end
```

警告: `+...+` を固定幅フォントにするのは、通常のクラス、モジュール、メソッド名、シンボル、パス（スラッシュを含む）などのような単純なコンテンツにのみ適用されます。それ以外のものには `<tt>...</tt>` 形式を使用してください。

以下のコマンドでRDocの出力を簡単にテストできます。

```bash
$ echo "+:to_param+" | rdoc --pipe
# => <p><code>:to_param</code></p>
```

例えば、スペースや引用符を含むコードは `<tt>...</tt>` 形式を使用する必要があります。

### 通常のフォント

"true" と "false" がRubyのキーワードではなく英単語として使用される場合は、通常のフォントを使用してください。

```ruby
# Runs all the validations within the specified context.
# Returns true if no errors are found, false otherwise.
#
# If the argument is false (default is +nil+), the context is
# set to <tt>:create</tt> if <tt>new_record?</tt> is true,
# and to <tt>:update</tt> if it is not.
#
# Validations with no <tt>:on</tt> option will run no
# matter the context. Validations with # some <tt>:on</tt>
# option will only run in the specified context.
def valid?(context = nil)
  # ...
end
```
説明リスト
-----------------

オプション、パラメータなどのリストでは、アイテムとその説明の間にハイフンを使用します（通常、オプションはシンボルであるため、コロンよりも読みやすいです）：

```ruby
# * <tt>:allow_nil</tt> - 属性が+nil+の場合、検証をスキップします。
```

説明は大文字で始まり、ピリオドで終わります - これは標準的な英語です。

追加の詳細と例を提供する場合、オプションセクションスタイルを使用する代替手段もあります。

[`ActiveSupport::MessageEncryptor#encrypt_and_sign`][#encrypt_and_sign]は、これの素晴らしい例です。

```ruby
# ==== オプション
#
# [+:expires_at+]
#   メッセージの有効期限の日時。この日時を過ぎると、メッセージの検証に失敗します。
#
#     message = encryptor.encrypt_and_sign("hello", expires_at: Time.now.tomorrow)
#     encryptor.decrypt_and_verify(message) # => "hello"
#     # 24時間後...
#     encryptor.decrypt_and_verify(message) # => nil
```


動的に生成されるメソッド
-----------------------------

`(module|class)_eval(STRING)`で作成されたメソッドは、生成されたコードのインスタンスと一緒にコメントが付いています。そのコメントはテンプレートから2スペース離れています：

[![(module|class)_eval(STRING) code comments](images/dynamic_method_class_eval.png)](images/dynamic_method_class_eval.png)

結果の行が幅が広すぎる場合、200列以上の場合、呼び出しの上にコメントを配置します：

```ruby
# def self.find_by_login_and_activated(*args)
#   options = args.extract_options!
#   ...
# end
self.class_eval %{
  def self.#{method_id}(*args)
    options = args.extract_options!
    ...
  end
}, __FILE__, __LINE__
```

メソッドの可視性
-----------------

Railsのドキュメントを書く際には、公開のユーザー向けAPIと内部APIの違いを理解することが重要です。

Railsは、ほとんどのライブラリと同様に、内部APIを定義するためにRubyのprivateキーワードを使用します。ただし、公開APIはやや異なる規則に従います。すべての公開メソッドがユーザー向けに設計されたものとは限らず、Railsは`：nodoc：`ディレクティブを使用して、この種のメソッドを内部APIとして注釈付けします。

これは、Railsにはユーザーが使用しないメソッドがあることを意味します。

これの例として、`ActiveRecord::Core::ClassMethods#arel_table`があります：

```ruby
module ActiveRecord::Core::ClassMethods
  def arel_table # :nodoc:
    # 何かの魔法を行う..
  end
end
```

もし、「このメソッドは`ActiveRecord::Core`の公開クラスメソッドのように見える」と思ったなら、正解です。しかし、実際にはRailsチームはユーザーにこのメソッドを依存させたくありません。そのため、`：nodoc：`とマークし、公開ドキュメントから削除されます。これには、チームがリリースごとに内部のニーズに応じてこれらのメソッドを変更できるようにする理由があります。このメソッドの名前が変わるか、返り値が変わるか、またはこのクラス全体が消えるかもしれません。保証はないため、プラグインやアプリケーションでこのAPIに依存しないでください。そうしないと、Railsの新しいリリースにアップグレードする際にアプリケーションやジェムが壊れる可能性があります。

貢献者として、このAPIがエンドユーザー向けに意図されているかどうかを考えることが重要です。Railsチームは、完全な非推奨サイクルを経ずにリリース間で公開APIを変更しないことを約束しています。内部メソッド/クラスでない限り、内部メソッド/クラスである場合はデフォルトで内部です。APIが安定すると、可視性を変更できますが、後方互換性のために公開APIを変更することは非常に困難です。

クラスまたはモジュールには、すべてのメソッドが内部APIであり、直接使用されるべきではないことを示すために、`：nodoc：`が付けられます。

要約すると、Railsチームは、内部使用のために公開されたメソッドとクラスをマークするために`：nodoc：`を使用します。APIの可視性の変更は慎重に検討され、まずプルリクエストで議論されるべきです。

Railsスタックに関して
-------------------------

Rails APIの一部をドキュメント化する際には、Railsスタックに含まれるすべての要素を忘れないようにすることが重要です。

これは、メソッドやクラスのスコープやコンテキストによって動作が変わる可能性があることを意味します。

さまざまな場所では、Railsスタック全体を考慮に入れると異なる動作があります。その一例が`ActionView::Helpers::AssetTagHelper#image_tag`です：

```ruby
# image_tag("icon.png")
#   # => <img src="/assets/icon.png" />
```

`#image_tag`のデフォルトの動作は常に`/images/icon.png`を返すことですが、Asset Pipelineを含むRailsスタック全体を考慮に入れると、上記の結果が表示される場合があります。

私たちは、デフォルトのフルRailsスタックを使用した場合に経験する動作に関心があります。

この場合、特定のメソッドだけでなく、フレームワークの動作をドキュメント化したいと考えています。

Railsチームが特定のAPIをどのように扱っているかについて質問がある場合は、[issue tracker](https://github.com/rails/rails/issues)にチケットを開いたり、パッチを送信したりすることを躊躇しないでください。
[#encrypt_and_sign]: https://edgeapi.rubyonrails.org/classes/ActiveSupport/MessageEncryptor.html#method-i-encrypt_and_sign
