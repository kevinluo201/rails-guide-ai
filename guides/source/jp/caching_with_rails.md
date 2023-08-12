**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: bef23603f5d822054701f5cbf2578d95
Railsでのキャッシュ：概要
=======================

このガイドは、キャッシュを使用してRailsアプリケーションのパフォーマンスを向上させるための入門です。

キャッシュとは、リクエストとレスポンスのサイクル中に生成されたコンテンツを保存し、類似のリクエストに対して再利用することを意味します。

キャッシュは、アプリケーションのパフォーマンスを向上させるための最も効果的な方法です。キャッシュを通じて、単一のサーバーと単一のデータベースで実行されているウェブサイトは、数千の同時ユーザーの負荷を持続することができます。

Railsは、デフォルトで一連のキャッシュ機能を提供しています。このガイドでは、それぞれのスコープと目的を学びます。これらのテクニックをマスターすれば、Railsアプリケーションは高いレスポンス時間やサーバーの請求書を必要とせずに数百万のビューを提供することができます。

このガイドを読み終えると、以下のことがわかるようになります：

* フラグメントキャッシュとロシア人の人形キャッシュ
* キャッシュの依存関係の管理方法
* 代替キャッシュストア
* 条件付きGETのサポート

--------------------------------------------------------------------------------

基本的なキャッシュ
-----------------

このセクションでは、ページキャッシュ、アクションキャッシュ、フラグメントキャッシュの3つのキャッシュ技術について紹介します。デフォルトでは、Railsはフラグメントキャッシュを提供します。ページキャッシュとアクションキャッシュを使用するには、`Gemfile`に`actionpack-page_caching`と`actionpack-action_caching`を追加する必要があります。

デフォルトでは、キャッシュは本番環境でのみ有効になっています。`rails dev:cache`を実行するか、`config/environments/development.rb`で`config.action_controller.perform_caching`を`true`に設定することで、ローカルでキャッシュを試すことができます。

注意：`config.action_controller.perform_caching`の値を変更しても、Action Controllerが提供するキャッシュにのみ影響を与えます。たとえば、低レベルのキャッシュには影響しません。以下で説明する[低レベルのキャッシュ](#low-level-caching)には影響しません。

### ページキャッシュ

ページキャッシュは、ウェブサーバー（ApacheやNGINXなど）を介さずに生成されたページのリクエストを処理するRailsの仕組みです。これは非常に高速ですが、認証が必要なページなど、すべての状況に適用することはできません。また、ウェブサーバーがファイルを直接ファイルシステムから提供するため、キャッシュの期限切れを実装する必要があります。

情報：Rails 4からページキャッシュは削除されました。[actionpack-page_caching gem](https://github.com/rails/actionpack-page_caching)を参照してください。

### アクションキャッシュ

ページキャッシュは、beforeフィルタを持つアクションには使用できません。たとえば、認証が必要なページなどです。これがアクションキャッシュの役割です。アクションキャッシュは、ページキャッシュと同様に機能しますが、キャッシュが提供される前に着信ウェブリクエストがRailsスタックに到達するため、beforeフィルタを実行することができます。これにより、認証やその他の制限を実行しながら、キャッシュされたコピーの出力結果を提供することができます。

情報：Rails 4からアクションキャッシュは削除されました。[actionpack-action_caching gem](https://github.com/rails/actionpack-action_caching)を参照してください。新しい推奨方法については、[DHHのキーに基づくキャッシュの期限切れの概要](https://signalvnoise.com/posts/3113-how-key-based-cache-expiration-works)を参照してください。

### フラグメントキャッシュ

動的なウェブアプリケーションでは、異なるキャッシュ特性を持つさまざまなコンポーネントでページを構築することが一般的です。ページの異なる部分を個別にキャッシュし、別々に期限切れにする必要がある場合は、フラグメントキャッシュを使用できます。

フラグメントキャッシュは、ビューロジックの一部をキャッシュブロックで囲み、次のリクエストが来たときにキャッシュストアから提供することができます。

たとえば、ページ上の各製品をキャッシュしたい場合、次のコードを使用できます：

```html+erb
<% @products.each do |product| %>
  <% cache product do %>
    <%= render product %>
  <% end %>
<% end %>
```

アプリケーションがこのページに最初のリクエストを受け取ると、Railsは一意のキーで新しいキャッシュエントリを書き込みます。キーは次のようなものです：

```
views/products/index:bea67108094918eeba42cd4a6e786901/products/1
```

中央の文字列はテンプレートツリーダイジェストです。これは、キャッシュしているビューフラグメントの内容に基づいて計算されたハッシュダイジェストです。ビューフラグメント（たとえば、HTMLの変更）を変更すると、ダイジェストが変更され、既存のファイルが期限切れになります。

キャッシュエントリには、製品レコードから派生したキャッシュバージョンが格納されます。製品が変更されると、キャッシュバージョンが変更され、以前のバージョンを含むキャッシュされたフラグメントは無視されます。

ヒント：Memcachedなどのキャッシュストアは、古いキャッシュファイルを自動的に削除します。

特定の条件下でフラグメントをキャッシュしたい場合は、`cache_if`または`cache_unless`を使用できます：

```erb
<% cache_if admin?, product do %>
  <%= render product %>
<% end %>
```

#### コレクションキャッシュ

`render`ヘルパーは、コレクションに対して個別のテンプレートをキャッシュすることもできます。さらに、前の例を`each`で一括してキャッシュテンプレートを一度に読み込むこともできます。これは、コレクションをレンダリングする際に`cached: true`を渡すことで実現できます：
```html+erb
<%= render partial: 'products/product', collection: @products, cached: true %>
```

以前のレンダリングからキャッシュされたテンプレートは一度に非常に高速に取得されます。さらに、まだキャッシュされていないテンプレートはキャッシュに書き込まれ、次のレンダリング時にマルチフェッチされます。

### ロシア人の人形キャッシュ

キャッシュされたフラグメントを他のキャッシュされたフラグメントの中にネストしたい場合があります。これはロシア人の人形キャッシュと呼ばれます。

ロシア人の人形キャッシュの利点は、1つの製品が更新された場合、他の内部フラグメントが外部フラグメントを再生成する際に再利用できることです。

前のセクションで説明したように、キャッシュされたファイルは、キャッシュされたファイルが直接依存するレコードの`updated_at`の値が変更された場合に期限切れになります。ただし、これによってフラグメントがネストされているキャッシュは期限切れになりません。

たとえば、次のビューを考えてみましょう：

```erb
<% cache product do %>
  <%= render product.games %>
<% end %>
```

これによって次のビューがレンダリングされます：

```erb
<% cache game do %>
  <%= render game %>
<% end %>
```

ゲームの属性のいずれかが変更されると、`updated_at`の値が現在の時刻に設定され、キャッシュが期限切れになります。ただし、製品オブジェクトの`updated_at`は変更されないため、そのキャッシュは期限切れにならず、アプリケーションは古いデータを提供します。これを修正するには、モデルを`touch`メソッドで結び付けます：

```ruby
class Product < ApplicationRecord
  has_many :games
end

class Game < ApplicationRecord
  belongs_to :product, touch: true
end
```

`touch`を`true`に設定すると、ゲームレコードの`updated_at`を変更するアクションは、関連する製品の`updated_at`も変更し、キャッシュを期限切れにします。

### 共有パーシャルキャッシュ

異なるMIMEタイプを持つファイル間でパーシャルと関連するキャッシュを共有することができます。たとえば、共有パーシャルキャッシュを使用すると、テンプレート作成者はHTMLファイルとJavaScriptファイルの間でパーシャルを共有できます。テンプレートがテンプレートリゾルバファイルパスに収集されるとき、テンプレート言語の拡張子のみが含まれ、MIMEタイプは含まれません。そのため、テンプレートは複数のMIMEタイプに使用することができます。以下のコードは、HTMLとJavaScriptの両方のリクエストに応答します：

```ruby
render(partial: 'hotels/hotel', collection: @hotels, cached: true)
```

これにより、`hotels/hotel.erb`という名前のファイルがロードされます。

別のオプションは、レンダリングするパーシャルの完全なファイル名を含めることです。

```ruby
render(partial: 'hotels/hotel.html.erb', collection: @hotels, cached: true)
```

これにより、`hotels/hotel.html.erb`という名前のファイルが、任意のファイルMIMEタイプでロードされます。たとえば、このパーシャルをJavaScriptファイルに含めることができます。

### 依存関係の管理

キャッシュを正しく無効にするためには、キャッシュの依存関係を適切に定義する必要があります。Railsは一般的なケースをうまく処理できるので、何も指定する必要はありません。ただし、カスタムヘルパーなどを扱う場合など、明示的に定義する必要がある場合もあります。

#### 暗黙の依存関係

ほとんどのテンプレートの依存関係は、テンプレート自体での`render`呼び出しから派生することができます。以下は、`ActionView::Digestor`がデコードできる`render`呼び出しのいくつかの例です：

```ruby
render partial: "comments/comment", collection: commentable.comments
render "comments/comments"
render 'comments/comments'
render('comments/comments')

render "header" は render("comments/header") に変換されます

render(@topic)         は render("topics/topic") に変換されます
render(topics)         は render("topics/topic") に変換されます
render(message.topics) は render("topics/topic") に変換されます
```

一方、一部の呼び出しはキャッシュが正しく機能するように変更する必要があります。たとえば、カスタムコレクションを渡す場合は、次のように変更する必要があります：

```ruby
render @project.documents.where(published: true)
```

次のように変更する必要があります：

```ruby
render partial: "documents/document", collection: @project.documents.where(published: true)
```

#### 明示的な依存関係

時には、まったく派生できないテンプレートの依存関係があります。これは通常、ヘルパーでレンダリングが行われる場合です。以下は例です：

```html+erb
<%= render_sortable_todolists @project.todolists %>
```

これらを呼び出すためには、特殊なコメント形式を使用する必要があります：

```html+erb
<%# Template Dependency: todolists/todolist %>
<%= render_sortable_todolists @project.todolists %>
```

単一テーブル継承のセットアップなど、いくつかの明示的な依存関係がある場合、すべてのテンプレートを書き出す代わりに、ワイルドカードを使用してディレクトリ内の任意のテンプレートに一致させることができます：

```html+erb
<%# Template Dependency: events/* %>
<%= render_categorizable_events @person.events %>
```

コレクションキャッシュに関しては、パーシャルテンプレートがクリーンなキャッシュ呼び出しで始まらない場合でも、テンプレートのどこにでも特殊なコメント形式を追加することで、コレクションキャッシュの恩恵を受けることができます。たとえば：

```html+erb
<%# Template Collection: notification %>
<% my_helper_that_calls_cache(some_arg, notification) do %>
  <%= notification.name %>
<% end %>
```
#### 外部依存関係

キャッシュされたブロック内でヘルパーメソッドを使用し、そのヘルパーメソッドを更新した場合、キャッシュも更新する必要があります。どのように更新するかは重要ではありませんが、テンプレートファイルのMD5が変更される必要があります。一つの推奨方法は、コメントで明示的に指定することです。

```html+erb
<%# Helper Dependency Updated: Jul 28, 2015 at 7pm %>
<%= some_helper_method(person) %>
```

### 低レベルキャッシュ

ビューフラグメントのキャッシュではなく、特定の値やクエリ結果をキャッシュする必要がある場合があります。Railsのキャッシュメカニズムは、シリアライズ可能な情報を格納するのに非常に効率的です。

低レベルキャッシュを実装する最も効率的な方法は、`Rails.cache.fetch`メソッドを使用することです。このメソッドはキャッシュの読み書きを両方行います。単一の引数の場合、キーを取得し、キャッシュから値を返します。ブロックが渡された場合、キャッシュミスの場合にそのブロックが実行されます。ブロックの戻り値は、指定されたキャッシュキーの下にキャッシュに書き込まれ、その戻り値が返されます。キャッシュヒットの場合、キャッシュされた値がブロックを実行せずに返されます。

以下の例を考えてみましょう。アプリケーションには、競合するウェブサイトで製品の価格を検索するインスタンスメソッドを持つ`Product`モデルがあります。このメソッドが返すデータは、低レベルキャッシュに適しています。

```ruby
class Product < ApplicationRecord
  def competing_price
    Rails.cache.fetch("#{cache_key_with_version}/competing_price", expires_in: 12.hours) do
      Competitor::API.find_price(id)
    end
  end
end
```

注意: この例では、`cache_key_with_version`メソッドを使用しているため、生成されるキャッシュキーは`products/233-20140225082222765838000/competing_price`のようなものになります。`cache_key_with_version`は、モデルのクラス名、`id`、`updated_at`属性に基づいて文字列を生成します。これは一般的な慣例であり、製品が更新されるたびにキャッシュを無効にする利点があります。一般的に、低レベルキャッシュを使用する場合は、キャッシュキーを生成する必要があります。

#### Active Recordオブジェクトのインスタンスのキャッシュを避ける

次の例では、キャッシュにスーパーユーザーを表すActive Recordオブジェクトのリストを保存しています。

```ruby
# super_adminsは高コストなSQLクエリなので、頻繁に実行しないでください
Rails.cache.fetch("super_admin_users", expires_in: 12.hours) do
  User.super_admins.to_a
end
```

このパターンは避けるべきです。なぜなら、インスタンスが変更される可能性があるからです。本番環境では、属性が異なる場合やレコードが削除される場合があります。開発環境では、コードの変更時にキャッシュストアがコードを再読み込みするため、信頼性が低くなります。

代わりに、IDや他のプリミティブなデータ型をキャッシュしてください。例えば:

```ruby
# super_adminsは高コストなSQLクエリなので、頻繁に実行しないでください
ids = Rails.cache.fetch("super_admin_user_ids", expires_in: 12.hours) do
  User.super_admins.pluck(:id)
end
User.where(id: ids).to_a
```

### SQLキャッシュ

クエリキャッシュは、各クエリの結果セットをキャッシュするRailsの機能です。Railsは同じクエリが再度実行される場合、データベースに対してクエリを実行する代わりに、キャッシュされた結果セットを使用します。

例えば:

```ruby
class ProductsController < ApplicationController
  def index
    # findクエリを実行する
    @products = Product.all

    # ...

    # 同じクエリを再度実行する
    @products = Product.all
  end
end
```

同じクエリがデータベースに対して再度実行される場合、実際にはデータベースにアクセスしません。最初の結果はクエリキャッシュ（メモリ上）に保存され、2回目はメモリから取得されます。

ただし、クエリキャッシュはアクションの開始時に作成され、アクションの終了時に破棄されるため、アクションの実行時間のみ有効です。より永続的な方法でクエリ結果を保存したい場合は、低レベルキャッシュを使用することができます。

キャッシュストア
------------

Railsは、SQLキャッシュやページキャッシュ以外のキャッシュデータのために異なるストアを提供しています。

### 設定

`config.cache_store`設定オプションを設定することで、アプリケーションのデフォルトのキャッシュストアを設定することができます。その他のパラメータは、キャッシュストアのコンストラクタに引数として渡すことができます。

```ruby
config.cache_store = :memory_store, { size: 64.megabytes }
```

または、設定ブロックの外部で`ActionController::Base.cache_store`を設定することもできます。

`Rails.cache`を呼び出すことでキャッシュにアクセスすることができます。

#### コネクションプールオプション

デフォルトでは、[`:mem_cache_store`](#activesupport-cache-memcachestore)と[`:redis_cache_store`](#activesupport-cache-rediscachestore)はコネクションプーリングを使用するように設定されています。これは、Pumaなどのスレッド型サーバーを使用している場合、複数のスレッドが同時にキャッシュストアにクエリを実行できることを意味します。
接続プーリングを無効にする場合は、キャッシュストアを設定する際に`:pool`オプションを`false`に設定します。

```ruby
config.cache_store = :mem_cache_store, "cache.example.com", pool: false
```

また、`pool`オプションに個別のオプションを指定することで、デフォルトのプール設定を上書きすることもできます。

```ruby
config.cache_store = :mem_cache_store, "cache.example.com", pool: { size: 32, timeout: 1 }
```

* `:size` - このオプションはプロセスごとの接続数を設定します（デフォルトは5）。

* `:timeout` - このオプションは接続を待機する秒数を設定します（デフォルトは5）。タイムアウト内に利用可能な接続がない場合、`Timeout::Error`が発生します。

### `ActiveSupport::Cache::Store`

[`ActiveSupport::Cache::Store`][]は、Railsでキャッシュとのやり取りを行うための基盤を提供します。これは抽象クラスであり、単独では使用することはできません。代わりに、ストレージエンジンに結び付けられた具体的な実装クラスを使用する必要があります。Railsにはいくつかの実装が付属しており、以下で説明します。

主なAPIメソッドは[`read`][ActiveSupport::Cache::Store#read]、[`write`][ActiveSupport::Cache::Store#write]、[`delete`][ActiveSupport::Cache::Store#delete]、[`exist?`][ActiveSupport::Cache::Store#exist?]、[`fetch`][ActiveSupport::Cache::Store#fetch]です。

キャッシュストアのコンストラクタに渡されたオプションは、適切なAPIメソッドのデフォルトオプションとして扱われます。


### `ActiveSupport::Cache::MemoryStore`

[`ActiveSupport::Cache::MemoryStore`][]は、エントリをRubyプロセス内のメモリに保持します。キャッシュストアは、イニシャライザに`size`オプションを送信して指定されたサイズで制限されます（デフォルトは32MB）。キャッシュが割り当てられたサイズを超えると、クリーンアップが行われ、最も最近使用されていないエントリが削除されます。

```ruby
config.cache_store = :memory_store, { size: 64.megabytes }
```

複数のRuby on Railsサーバープロセスを実行している場合（Phusion Passengerやpumaのクラスタモードを使用している場合）、Railsサーバープロセスのインスタンスは互いにキャッシュデータを共有できません。このキャッシュストアは、大規模なアプリケーション展開には適していません。ただし、数個のサーバープロセスだけで運営される小規模で低トラフィックのサイトや開発・テスト環境ではうまく機能します。

新しいRailsプロジェクトは、デフォルトで開発環境でこの実装を使用するように設定されています。

注意：`：memory_store`を使用すると、プロセスがキャッシュデータを共有しないため、Railsコンソールを介してキャッシュを手動で読み取ったり、書き込んだり、期限を切ったりすることはできません。


### `ActiveSupport::Cache::FileStore`

[`ActiveSupport::Cache::FileStore`][]は、エントリをファイルシステムに格納します。キャッシュを初期化する際に、ストアファイルが格納されるディレクトリのパスを指定する必要があります。

```ruby
config.cache_store = :file_store, "/path/to/cache/directory"
```

このキャッシュストアでは、同じホスト上の複数のサーバープロセスがキャッシュを共有できます。このキャッシュストアは、1つまたは2つのホストから提供される低から中程度のトラフィックのサイトに適しています。異なるホストで実行されるサーバープロセスは、共有ファイルシステムを使用してキャッシュを共有することもできますが、この設定は推奨されません。

キャッシュはディスクがいっぱいになるまで成長するため、定期的に古いエントリを削除することをおすすめします。

これは、明示的な`config.cache_store`が指定されていない場合、デフォルトのキャッシュストア実装（`"#{root}/tmp/cache/"`）です。


### `ActiveSupport::Cache::MemCacheStore`

[`ActiveSupport::Cache::MemCacheStore`][]は、Dangaの`memcached`サーバーを使用してアプリケーションの中央キャッシュを提供します。Railsはデフォルトでバンドルされた`dalli`ジェムを使用します。これは現在、プロダクションのウェブサイトで最も人気のあるキャッシュストアです。非常に高いパフォーマンスと冗長性を持つ単一の共有キャッシュクラスタを提供するために使用できます。

キャッシュを初期化する際に、クラスタ内のすべてのmemcachedサーバーのアドレスを指定するか、`MEMCACHE_SERVERS`環境変数が適切に設定されていることを確認する必要があります。

```ruby
config.cache_store = :mem_cache_store, "cache-1.example.com", "cache-2.example.com"
```

どちらも指定されていない場合、デフォルトではmemcachedがlocalhostのデフォルトポート（`127.0.0.1:11211`）で実行されているものと見なされますが、これは大規模なサイトには理想的な設定ではありません。

```ruby
config.cache_store = :mem_cache_store # $MEMCACHE_SERVERS、次に127.0.0.1:11211にフォールバックします
```

サポートされるアドレスのタイプについては、[`Dalli::Client`のドキュメント](https://www.rubydoc.info/gems/dalli/Dalli/Client#initialize-instance_method)を参照してください。

このキャッシュの[`write`][ActiveSupport::Cache::MemCacheStore#write]（および`fetch`）メソッドは、memcached固有の機能を利用するための追加オプションを受け入れます。


### `ActiveSupport::Cache::RedisCacheStore`

[`ActiveSupport::Cache::RedisCacheStore`][]は、Redisが最大メモリに達したときに自動的にエントリを削除するRedisのサポートを利用し、Memcachedキャッシュサーバーのように動作することができます。

デプロイメントの注意：Redisはデフォルトではキーの有効期限が切れないため、専用のRedisキャッシュサーバーを使用するように注意してください。永続的なRedisサーバーを揮発性のあるキャッシュデータで埋めることは避けてください！詳細については、Redisキャッシュサーバーのセットアップガイド（ https://redis.io/topics/lru-cache ）を読んでください。

キャッシュ専用のRedisサーバーの場合、`maxmemory-policy`をallkeysのバリアントの1つに設定します。Redis 4以降では、最も使用頻度の低いエントリ（`allkeys-lfu`）を選択するのが最適な選択肢です。Redis 3以前では、最も最近使用されていないエントリ（`allkeys-lru`）を使用する必要があります。
キャッシュの読み取りと書き込みのタイムアウトを比較的低く設定します。キャッシュされた値を再生成する方が、それを取得するために1秒以上待つよりも速いことがよくあります。読み取りと書き込みのタイムアウトはデフォルトで1秒に設定されていますが、ネットワークが一貫して低遅延である場合はさらに低く設定することもできます。

デフォルトでは、接続がリクエスト中に失敗した場合、キャッシュストアはRedisに再接続しようとしません。頻繁な切断が発生する場合は、再接続を有効にすることを検討してください。

キャッシュの読み取りと書き込みは例外を発生させることはありません。代わりに、キャッシュに何もないかのように`nil`を返します。キャッシュが例外を発生しているかどうかを判断するために、`error_handler`を提供して例外収集サービスに報告することができます。これは、`method`（元々呼び出されたキャッシュストアのメソッド）、`returning`（通常は`nil`の値）、`exception`（救出された例外）の3つのキーワード引数を受け入れる必要があります。

始めるには、Gemfileにredis gemを追加します：

```ruby
gem 'redis'
```

最後に、関連する`config/environments/*.rb`ファイルに設定を追加します：

```ruby
config.cache_store = :redis_cache_store, { url: ENV['REDIS_URL'] }
```

より複雑なプロダクション向けのRedisキャッシュストアは、次のようになります：

```ruby
cache_servers = %w(redis://cache-01:6379/0 redis://cache-02:6379/0)
config.cache_store = :redis_cache_store, { url: cache_servers,

  connect_timeout:    30,  # デフォルトは20秒です
  read_timeout:       0.2, # デフォルトは1秒です
  write_timeout:      0.2, # デフォルトは1秒です
  reconnect_attempts: 1,   # デフォルトは0です

  error_handler: -> (method:, returning:, exception:) {
    # エラーをSentryに警告として報告する
    Sentry.capture_exception exception, level: 'warning',
      tags: { method: method, returning: returning }
  }
}
```


### `ActiveSupport::Cache::NullStore`

[`ActiveSupport::Cache::NullStore`][]は、各ウェブリクエストにスコープがあり、リクエストの終了時に格納された値をクリアします。開発環境やテスト環境で使用することを目的としています。`Rails.cache`と直接対話するコードがある場合に、キャッシュがコードの変更結果の表示に干渉する場合に非常に便利です。

```ruby
config.cache_store = :null_store
```


### カスタムキャッシュストア

`ActiveSupport::Cache::Store`を拡張し、適切なメソッドを実装するだけで、独自のカスタムキャッシュストアを作成することができます。これにより、任意の数のキャッシュ技術をRailsアプリケーションに組み込むことができます。

カスタムキャッシュストアを使用するには、キャッシュストアをカスタムクラスの新しいインスタンスに設定するだけです。

```ruby
config.cache_store = MyCacheStore.new
```

キャッシュキー
----------

キャッシュで使用されるキーは、`cache_key`または`to_param`に応答する任意のオブジェクトである必要があります。カスタムキーを生成する必要がある場合は、クラスに`cache_key`メソッドを実装することができます。Active Recordは、クラス名とレコードIDに基づいてキーを生成します。

ハッシュや値の配列をキャッシュキーとして使用することもできます。

```ruby
# これは有効なキャッシュキーです
Rails.cache.read(site: "mysite", owners: [owner_1, owner_2])
```

`Rails.cache`で使用するキーは、実際にストレージエンジンで使用されるキーとは異なる場合があります。ネームスペースに変更が加えられたり、テクノロジーバックエンドの制約に合わせて変更されたりする可能性があります。つまり、`Rails.cache`で値を保存してから`dalli` gemで取り出そうとすることはできません。ただし、memcachedのサイズ制限を超えたり、構文規則を違反したりする心配もする必要はありません。

条件付きGETのサポート
-----------------------

条件付きGETは、Webサーバーがブラウザに対して、GETリクエストのレスポンスが前回のリクエスト以降変更されていないため、ブラウザキャッシュから安全に取得できることを伝えるHTTP仕様の機能です。

これらは、`HTTP_IF_NONE_MATCH`および`HTTP_IF_MODIFIED_SINCE`ヘッダーを使用して、一意のコンテンツ識別子とコンテンツが最後に変更されたタイムスタンプを送受信することで機能します。ブラウザがコンテンツ識別子（ETag）または最終変更日時のタイムスタンプがサーバーのバージョンと一致するリクエストを行う場合、サーバーは変更されていないステータスの空のレスポンスを送信するだけで済みます。

最終変更日時とif-none-matchヘッダーを探し、完全なレスポンスを送信するかどうかを決定するのは、サーバー（つまり私たち）の責任です。Railsの条件付きGETサポートを使用すると、これは非常に簡単なタスクです：

```ruby
class ProductsController < ApplicationController
  def show
    @product = Product.find(params[:id])

    # リクエストが指定されたタイムスタンプとバージョン付きキャッシュキーに基づいて古くなっている場合
    # （つまり、再処理が必要な場合）は、このブロックを実行します
    if stale?(last_modified: @product.updated_at.utc, etag: @product.cache_key_with_version)
      respond_to do |wants|
        # ... 通常のレスポンス処理
      end
    end

    # リクエストが新しい場合（つまり、変更されていない場合）は、何もする必要はありません。デフォルトのレンダリングは、前回のstale?呼び出しで使用されたパラメータを使用してこれをチェックし、自動的に:not_modifiedを送信します。以上です、終わりです。
  end
end
```
オプションハッシュの代わりに、単純にモデルを渡すこともできます。Railsは、`updated_at`メソッドと`cache_key_with_version`メソッドを使用して、`last_modified`と`etag`を設定します。

```ruby
class ProductsController < ApplicationController
  def show
    @product = Product.find(params[:id])

    if stale?(@product)
      respond_to do |wants|
        # ...通常のレスポンス処理
      end
    end
  end
end
```

特別なレスポンス処理がなく、デフォルトのレンダリングメカニズムを使用している場合（つまり、`respond_to`を使用していないか、自分でレンダリングを呼び出していない場合）、`fresh_when`には簡単なヘルパーがあります。

```ruby
class ProductsController < ApplicationController
  # リクエストが新しい場合は自動的に :not_modified を返し、
  # 古い場合はデフォルトのテンプレート（product.*）をレンダリングします。

  def show
    @product = Product.find(params[:id])
    fresh_when last_modified: @product.published_at.utc, etag: @product
  end
end
```

時には、決して期限切れにならない静的なページなどのレスポンスをキャッシュしたい場合があります。これを実現するために、`http_cache_forever`ヘルパーを使用することができます。これにより、ブラウザとプロキシがそれを無期限にキャッシュすることができます。

デフォルトでは、キャッシュされたレスポンスはプライベートであり、ユーザーのウェブブラウザにのみキャッシュされます。プロキシがレスポンスをキャッシュできるようにするには、`public: true`を設定して、キャッシュされたレスポンスをすべてのユーザーに提供できることを示します。

このヘルパーを使用すると、`last_modified`ヘッダーは`Time.new(2011, 1, 1).utc`に設定され、`expires`ヘッダーは100年に設定されます。

警告: ブラウザ/プロキシは、ブラウザキャッシュが強制的にクリアされない限り、キャッシュされたレスポンスを無効にすることはできませんので、このメソッドを注意して使用してください。

```ruby
class HomeController < ApplicationController
  def index
    http_cache_forever(public: true) do
      render
    end
  end
end
```

### 強力な ETag と弱い ETag

Railsはデフォルトで弱いETagを生成します。弱いETagは、意味的に同等のレスポンスが完全に一致しない場合でも、同じETagを持つことができます。これは、レスポンスボディの細微な変更でページを再生成したくない場合に便利です。

弱いETagは、先頭に `W/` を付けて強いETagと区別されます。

```
W/"618bbc92e2d35ea1945008b42799b0e7" → 弱いETag
"618bbc92e2d35ea1945008b42799b0e7" → 強いETag
```

弱いETagとは異なり、強いETagはレスポンスが完全に同じであり、バイト単位で同一であることを意味します。大きなビデオやPDFファイル内で範囲リクエストを行う場合に便利です。Akamaiのような一部のCDNは、強いETagのみをサポートしています。絶対に強いETagを生成する必要がある場合は、次のように行うことができます。

```ruby
class ProductsController < ApplicationController
  def show
    @product = Product.find(params[:id])
    fresh_when last_modified: @product.published_at.utc, strong_etag: @product
  end
end
```

また、強いETagをレスポンスに直接設定することもできます。

```ruby
response.strong_etag = response.body # => "618bbc92e2d35ea1945008b42799b0e7"
```

開発中のキャッシュ
------------------

開発モードでアプリケーションのキャッシュ戦略をテストしたいことは一般的です。Railsは、キャッシュのオン/オフを簡単に切り替えるための`dev:cache`コマンドを提供しています。

```bash
$ bin/rails dev:cache
開発モードがキャッシュされています。
$ bin/rails dev:cache
開発モードのキャッシュは無効になっています。
```

デフォルトでは、開発モードのキャッシュが*オフ*の場合、Railsは[`:null_store`](#activesupport-cache-nullstore)を使用します。

参考文献
----------

* [DHHのキーベースのキャッシュの期限切れに関する記事](https://signalvnoise.com/posts/3113-how-key-based-cache-expiration-works)
* [Ryan Batesのキャッシュダイジェストに関するRailscast](http://railscasts.com/episodes/387-cache-digests)
[`config.action_controller.perform_caching`]: configuring.html#config-action-controller-perform-caching
[`ActiveSupport::Cache::Store`]: https://api.rubyonrails.org/classes/ActiveSupport/Cache/Store.html
[ActiveSupport::Cache::Store#delete]: https://api.rubyonrails.org/classes/ActiveSupport/Cache/Store.html#method-i-delete
[ActiveSupport::Cache::Store#exist?]: https://api.rubyonrails.org/classes/ActiveSupport/Cache/Store.html#method-i-exist-3F
[ActiveSupport::Cache::Store#fetch]: https://api.rubyonrails.org/classes/ActiveSupport/Cache/Store.html#method-i-fetch
[ActiveSupport::Cache::Store#read]: https://api.rubyonrails.org/classes/ActiveSupport/Cache/Store.html#method-i-read
[ActiveSupport::Cache::Store#write]: https://api.rubyonrails.org/classes/ActiveSupport/Cache/Store.html#method-i-write
[`ActiveSupport::Cache::MemoryStore`]: https://api.rubyonrails.org/classes/ActiveSupport/Cache/MemoryStore.html
[`ActiveSupport::Cache::FileStore`]: https://api.rubyonrails.org/classes/ActiveSupport/Cache/FileStore.html
[`ActiveSupport::Cache::MemCacheStore`]: https://api.rubyonrails.org/classes/ActiveSupport/Cache/MemCacheStore.html
[ActiveSupport::Cache::MemCacheStore#write]: https://api.rubyonrails.org/classes/ActiveSupport/Cache/MemCacheStore.html#method-i-write
[`ActiveSupport::Cache::RedisCacheStore`]: https://api.rubyonrails.org/classes/ActiveSupport/Cache/RedisCacheStore.html
[`ActiveSupport::Cache::NullStore`]: https://api.rubyonrails.org/classes/ActiveSupport/Cache/NullStore.html
