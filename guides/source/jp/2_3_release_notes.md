**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 77b47af4826df984dead9f6263cfd135
Ruby on Rails 2.3 リリースノート
===============================

Rails 2.3では、Rackの普及した統合、Rails Engineのサポートのリフレッシュ、Active Recordのネストトランザクション、ダイナミックおよびデフォルトスコープ、統一されたレンダリング、より効率的なルーティング、アプリケーションテンプレート、および静かなバックトレースなど、さまざまな新機能と改善機能が提供されています。このリストは主要なアップグレードをカバーしていますが、すべての細かいバグ修正や変更は含まれていません。すべてを見たい場合は、GitHubのメインRailsリポジトリの[コミットリスト](https://github.com/rails/rails/commits/2-3-stable)をチェックするか、個々のRailsコンポーネントの`CHANGELOG`ファイルを確認してください。

--------------------------------------------------------------------------------

アプリケーションアーキテクチャ
------------------------

Railsアプリケーションのアーキテクチャには2つの主要な変更があります：[Rack](https://rack.github.io/)モジュラーウェブサーバーインターフェースの完全な統合と、Rails Engineへのサポートの再開です。

### Rackの統合

RailsはCGIの過去から脱却し、Rackをすべてで使用するようになりました。これにより、内部の変更が非常に多く必要とされました（ただし、CGIを使用している場合は心配しないでください。Railsはプロキシインターフェースを介してCGIをサポートしています）。それにもかかわらず、これはRailsの内部における大きな変更です。2.3にアップグレードした後は、ローカル環境と本番環境でテストする必要があります。テストする項目は以下の通りです：

* セッション
* クッキー
* ファイルのアップロード
* JSON/XML API

以下は、Rackに関連する変更の概要です：

* `script/server`はRackを使用するように切り替えられました。これにより、任意のRack互換サーバーをサポートします。`script/server`は、rackupの設定ファイルが存在する場合にもそれを使用します。デフォルトでは、`config.ru`ファイルを探しますが、`-c`スイッチでこれをオーバーライドできます。
* FCGIハンドラはRackを介して処理されます。
* `ActionController::Dispatcher`は独自のデフォルトミドルウェアスタックを維持します。ミドルウェアは挿入、並べ替え、削除ができます。スタックは起動時にチェーンにコンパイルされます。ミドルウェアスタックは`environment.rb`で設定できます。
* `rake middleware`タスクが追加され、ミドルウェアスタックを検査できます。ミドルウェアスタックの順序をデバッグするのに便利です。
* 統合テストランナーは、ミドルウェアとアプリケーションスタック全体を実行するように変更されました。これにより、統合テストはRackミドルウェアのテストに最適です。
* `ActionController::CGIHandler`は、Rackに対応した古いCGIオブジェクトを受け取り、環境情報を変換するための後方互換のCGIラッパーです。
* `CgiRequest`および`CgiResponse`は削除されました。
* セッションストアは遅延ロードされるようになりました。リクエスト中にセッションオブジェクトにアクセスしない場合、セッションデータをロードしません（クッキーの解析、メモリキャッシュからのデータの読み込み、Active Recordオブジェクトの検索など）。
* クッキーの値を設定するためにテストで`CGI::Cookie.new`を使用する必要はもはやありません。`request.cookies["foo"]`に`String`値を割り当てると、期待どおりにクッキーが設定されます。
* `CGI::Session::CookieStore`は`ActionController::Session::CookieStore`に置き換えられました。
* `CGI::Session::MemCacheStore`は`ActionController::Session::MemCacheStore`に置き換えられました。
* `CGI::Session::ActiveRecordStore`は`ActiveRecord::SessionStore`に置き換えられました。
* `ActionController::Base.session_store = :active_record_store`を使用してセッションストアを変更することは引き続き可能です。
* デフォルトのセッションオプションは、`ActionController::Base.session = { :key => "..." }`で設定します。ただし、`:session_domain`オプションは`:domain`に名前が変更されました。
* 通常リクエスト全体をラップしていたミューテックスは、ミドルウェアでラップされるようになりました（`ActionController::Lock`）。
* `ActionController::AbstractRequest`および`ActionController::Request`が統合されました。新しい`ActionController::Request`は`Rack::Request`を継承しています。これはテストリクエストでの`response.headers['type']`へのアクセスに影響します。代わりに`response.content_type`を使用してください。
* `ActiveRecord::QueryCache`ミドルウェアは、`ActiveRecord`がロードされている場合、自動的にミドルウェアスタックに挿入されます。このミドルウェアは、リクエストごとのActive Recordクエリキャッシュを設定およびフラッシュします。
* RailsのルーターとコントローラークラスはRackの仕様に従います。`SomeController.call(env)`のようにコントローラーを直接呼び出すことができます。ルーターはルーティングパラメータを`rack.routing_args`に格納します。
* `ActionController::Request`は`Rack::Request`を継承します。
* `config.action_controller.session = { :session_key => 'foo', ...`の代わりに`config.action_controller.session = { :key => 'foo', ...`を使用してください。
* `ParamsParser`ミドルウェアを使用すると、XML、JSON、またはYAMLリクエストを事前処理して、その後の任意の`Rack::Request`オブジェクトで通常通り読み取ることができます。

### Rails Engineへの再度のサポート

アップグレードがないバージョンがいくつかあった後、Rails 2.3ではRails Engine（他のアプリケーションに埋め込むことができるRailsアプリケーション）のいくつかの新機能が提供されます。まず、エンジン内のルーティングファイルは、`routes.rb`ファイルと同様に自動的にロードおよびリロードされるようになりました（これは他のプラグインのルーティングファイルにも適用されます）。また、プラグインにappフォルダーがある場合、app/[models|controllers|helpers]が自動的にRailsのロードパスに追加されます。エンジンはまた、ビューパスを追加することもサポートしており、Action MailerおよびAction Viewはエンジンや他のプラグインのビューを使用します。
ドキュメンテーション
-------------

[Ruby on Railsガイド](https://guides.rubyonrails.org/)プロジェクトは、Rails 2.3向けにいくつかの追加ガイドを公開しています。さらに、[別のサイト](https://edgeguides.rubyonrails.org/)では、Edge Railsのガイドの最新版が保持されています。その他のドキュメンテーションの取り組みには、[Rails wiki](http://newwiki.rubyonrails.org/)の再開と、Rails Bookの早期計画が含まれます。

* 詳細はこちら：[Railsドキュメンテーションプロジェクト](https://weblog.rubyonrails.org/2009/1/15/rails-documentation-projects)

Ruby 1.9.1のサポート
------------------

Rails 2.3は、Ruby 1.8または現在リリースされているRuby 1.9.1で実行している場合、自身のテストをすべてパスするはずです。ただし、1.9.1に移行すると、データアダプタ、プラグイン、およびその他のコードがRuby 1.9.1とRailsコアの互換性を持つかどうかを確認する必要があります。

Active Record
-------------

Active Recordには、Rails 2.3で多くの新機能とバグ修正があります。ハイライトには、ネストした属性、ネストしたトランザクション、動的およびデフォルトのスコープ、およびバッチ処理が含まれます。

### ネストした属性

Active Recordは、指定した場合にネストしたモデルの属性を直接更新できるようになりました。

```ruby
class Book < ActiveRecord::Base
  has_one :author
  has_many :pages

  accepts_nested_attributes_for :author, :pages
end
```

ネストした属性を有効にすると、レコードと関連する子レコードの自動（およびアトミックな）保存、子レコードに対するバリデーション、およびネストしたフォームのサポートが可能になります（後述）。

また、ネストした属性を使用して追加される新しいレコードに対して要件を指定することもできます。これは、`:reject_if`オプションを使用して行います。

```ruby
accepts_nested_attributes_for :author,
  :reject_if => proc { |attributes| attributes['name'].blank? }
```

* 主な貢献者：[Eloy Duran](http://superalloy.nl/)
* 詳細はこちら：[Nested Model Forms](https://weblog.rubyonrails.org/2009/1/26/nested-model-forms)

### ネストしたトランザクション

Active Recordは、要望の多かったネストしたトランザクションをサポートするようになりました。以下のようなコードを書くことができます。

```ruby
User.transaction do
  User.create(:username => 'Admin')
  User.transaction(:requires_new => true) do
    User.create(:username => 'Regular')
    raise ActiveRecord::Rollback
  end
end

User.find(:all)  # => Adminのみが返されます
```

ネストしたトランザクションを使用すると、内部のトランザクションをロールバックすることなく、外部のトランザクションの状態に影響を与えることができます。トランザクションをネストする場合は、明示的に`requires_new`オプションを追加する必要があります。そうしないと、ネストしたトランザクションは単に親トランザクションの一部となります（Rails 2.2では現在のようになります）。内部では、ネストしたトランザクションは[セーブポイントを使用](http://rails.lighthouseapp.com/projects/8994/tickets/383)しているため、真のネストしたトランザクションを持たないデータベースでもサポートされます。また、テスト中のトランザクションフィクスチャとの互換性を確保するために、これらのトランザクションがうまく機能するようにするためのいくつかのマジックもあります。

* 主な貢献者：[Jonathan Viney](http://www.workingwithrails.com/person/4985-jonathan-viney)および[Hongli Lai](http://izumi.plan99.net/blog/)

### 動的スコープ

Railsの動的ファインダ（`find_by_color_and_flavor`のようなメソッドを動的に作成できる）や名前付きスコープ（`currently_active`のような再利用可能なクエリ条件をフレンドリーな名前にカプセル化できる）については既に知っていると思います。さらに、動的スコープメソッドを使用することもできます。アイデアは、フィルタリングとメソッドチェーンの両方を可能にする構文を組み合わせることです。例えば：

```ruby
Order.scoped_by_customer_id(12)
Order.scoped_by_customer_id(12).find(:all,
  :conditions => "status = 'open'")
Order.scoped_by_customer_id(12).scoped_by_status("open")
```

動的スコープを使用するためには、特に定義する必要はありません。ただ動作するだけです。

* 主な貢献者：[Yaroslav Markin](http://evilmartians.com/)
* 詳細はこちら：[What's New in Edge Rails: Dynamic Scope Methods](http://archives.ryandaigle.com/articles/2008/12/29/what-s-new-in-edge-rails-dynamic-scope-methods)

### デフォルトスコープ

Rails 2.3では、名前付きスコープやモデル内のすべての名前付きスコープまたは検索メソッドに適用される「デフォルトスコープ」という概念が導入されます。例えば、`default_scope :order => 'name ASC'`と書くと、そのモデルからレコードを取得するたびに名前でソートされた状態で取得されます（オプションを上書きしない限り）。

* 主な貢献者：Paweł Kondzior
* 詳細はこちら：[What's New in Edge Rails: Default Scoping](http://archives.ryandaigle.com/articles/2008/11/18/what-s-new-in-edge-rails-default-scoping)

### バッチ処理

`find_in_batches`を使用することで、Active Recordモデルから大量のレコードをメモリに対して少ない圧力で処理することができます。

```ruby
Customer.find_in_batches(:conditions => {:active => true}) do |customer_group|
  customer_group.each { |customer| customer.update_account_balance! }
end
```

`find_in_batches`にはほとんどの`find`オプションを渡すことができます。ただし、レコードの返される順序を指定することはできません（常にプライマリキーの昇順で返されます。プライマリキーは整数である必要があります）、また`limit`オプションを使用することもできません。代わりに、各バッチで返されるレコード数を設定するために`batch_size`オプションを使用します。デフォルトでは、バッチごとに1000レコードが返されます。

新しい`find_each`メソッドは、個々のレコードを返す`find_in_batches`のラッパーを提供します。デフォルトでは、バッチで検索が行われます（デフォルトでは1000レコード）。

```ruby
Customer.find_each do |customer|
  customer.update_account_balance!
end
```
このメソッドはバッチ処理にのみ使用するようにしてください。少数のレコード（1000未満）の場合は、通常の検索メソッドを使用して独自のループを作成してください。

* 追加情報（この時点では便利なメソッドは単に `each` と呼ばれていました）：
    * [Rails 2.3: バッチ検索](http://afreshcup.com/2009/02/23/rails-23-batch-finding/)
    * [Edge Railsの新機能：バッチ検索](http://archives.ryandaigle.com/articles/2009/2/23/what-s-new-in-edge-rails-batched-find)

### コールバックの複数条件

Active Recordのコールバックを使用する際に、同じコールバックに `:if` と `:unless` オプションを組み合わせ、複数の条件を配列として指定することができます。

```ruby
before_save :update_credit_rating, :if => :active,
  :unless => [:admin, :cash_only]
```
* 主な貢献者：L. Caviola

### havingを使用した検索

Railsには、グループ化された検索のレコードをフィルタリングするための `:having` オプションがあります（`has_many` および `has_and_belongs_to_many` の関連付けでも使用できます）。SQLの経験が豊富な方にはおなじみのように、これによりグループ化された結果に基づいてフィルタリングすることができます。

```ruby
developers = Developer.find(:all, :group => "salary",
  :having => "sum(salary) > 10000", :select => "salary")
```

* 主な貢献者：[Emilio Tagua](https://github.com/miloops)

### MySQL接続の再接続

MySQLは、接続に再接続フラグをサポートしています。これがtrueに設定されている場合、クライアントは接続が失われた場合にサーバーに再接続を試みます。Railsアプリケーションからこの動作を得るために、`database.yml` のMySQL接続に `reconnect = true` を設定することができます。デフォルトは `false` なので、既存のアプリケーションの動作は変わりません。

* 主な貢献者：[Dov Murik](http://twitter.com/dubek)
* 追加情報：
    * [自動再接続の制御](http://dev.mysql.com/doc/refman/5.6/en/auto-reconnect.html)
    * [MySQL auto-reconnect revisited](http://groups.google.com/group/rubyonrails-core/browse_thread/thread/49d2a7e9c96cb9f4)

### その他のActive Recordの変更

* `has_and_belongs_to_many` のプリロード時に生成されるSQLから余分な `AS` が削除され、一部のデータベースでの動作が改善されました。
* `ActiveRecord::Base#new_record?` は、既存のレコードに遭遇した場合に `nil` ではなく `false` を返すようになりました。
* 一部の `has_many :through` 関連付けでテーブル名をクォートする際のバグが修正されました。
* `updated_at` タイムスタンプに特定のタイムスタンプを指定することができるようになりました：`cust = Customer.create(:name => "ABC Industries", :updated_at => 1.day.ago)`
* 失敗した `find_by_attribute!` の呼び出しに関するエラーメッセージが改善されました。
* Active Recordの `to_xml` サポートは、`:camelize` オプションの追加により、少し柔軟性が向上しました。
* `before_update` または `before_create` からのコールバックのキャンセルに関するバグが修正されました。
* JDBCを介したデータベースのテストのためのRakeタスクが追加されました。
* `validates_length_of` は、`:in` または `:within` オプションでカスタムエラーメッセージを使用します（指定されている場合）。
* スコープ付きの選択に対するカウントが正しく機能するようになりました。したがって、`Account.scoped(:select => "DISTINCT credit_limit").count` のようなことができます。
* `ActiveRecord::Base#invalid?` は、`ActiveRecord::Base#valid?` の反対として機能するようになりました。

Action Controller
-----------------

このリリースでは、Action Controllerはレンダリングに関する重要な変更、ルーティングの改善など、いくつかの重要な変更を行っています。

### 統一されたレンダリング

`ActionController::Base#render` は、レンダリングする内容を判断する際によりスマートになりました。今では、レンダリングしたい内容を指定するだけで、正しい結果が得られるようになりました。古いバージョンのRailsでは、レンダリングに明示的な情報を提供する必要がありました。

```ruby
render :file => '/tmp/random_file.erb'
render :template => 'other_controller/action'
render :action => 'show'
```

Rails 2.3では、レンダリングしたい内容を単に指定することができます。

```ruby
render '/tmp/random_file.erb'
render 'other_controller/action'
render 'show'
render :show
```

Railsは、レンダリングする内容に先頭のスラッシュ、埋め込まれたスラッシュ、スラッシュが含まれていないかどうかに基づいて、ファイル、テンプレート、アクションのいずれかを選択します。アクションをレンダリングする際には、文字列の代わりにシンボルを使用することもできます。その他のレンダリングスタイル（`:inline`、`:text`、`:update`、`:nothing`、`:json`、`:xml`、`:js`）は引き続き明示的なオプションが必要です。

### Application Controllerの名前変更

`application.rb` の特殊な命名にいつも悩まされていた人の一人であれば、喜ぶことができます！Rails 2.3では、`application.rb` が `application_controller.rb` に再構成されました。さらに、`rake rails:update:application_controller` という新しいrakeタスクが追加され、これを使用すると自動的に変更することができます。このタスクは通常の `rake rails:update` プロセスの一部として実行されます。

* 追加情報：
    * [Application.rbの終焉](https://afreshcup.com/home/2008/11/17/rails-2x-the-death-of-applicationrb)
    * [Edge Railsの新機能：Application.rbの二重性はもはや存在しない](http://archives.ryandaigle.com/articles/2008/11/19/what-s-new-in-edge-rails-application-rb-duality-is-no-more)

### HTTPダイジェスト認証のサポート

Railsには、HTTPダイジェスト認証の組み込みサポートがあります。これを使用するには、ユーザーのパスワードを返すブロックを指定して `authenticate_or_request_with_http_digest` を呼び出します（パスワードはハッシュ化され、送信された認証情報と比較されます）。

```ruby
class PostsController < ApplicationController
  Users = {"dhh" => "secret"}
  before_filter :authenticate

  def secret
    render :text => "Password Required!"
  end

  private
  def authenticate
    realm = "Application"
    authenticate_or_request_with_http_digest(realm) do |name|
      Users[name]
    end
  end
end
```
* 主な貢献者：[Gregg Kellogg](http://www.kellogg-assoc.com/)
* 詳細情報：[Edge Railsの新機能：HTTPダイジェスト認証](http://archives.ryandaigle.com/articles/2009/1/30/what-s-new-in-edge-rails-http-digest-authentication)

### より効率的なルーティング

Rails 2.3では、いくつかの重要なルーティングの変更があります。`formatted_`ルートヘルパーはなくなり、代わりにオプションとして`:format`を渡すようになりました。これにより、任意のリソースのルート生成プロセスが50%削減され、メモリの節約（大規模なアプリケーションでは最大で100MB）が可能です。コードが`formatted_`ヘルパーを使用している場合、当面は動作しますが、この動作は非推奨となっており、新しい標準を使用してこれらのルートを書き直すとアプリケーションがより効率的になります。もう1つの大きな変更は、Railsが`routes.rb`だけでなく複数のルーティングファイルをサポートするようになったことです。いつでも`RouteSet#add_configuration_file`を使用して追加のルートを読み込むことができますが、現在読み込まれているルートはクリアされません。この変更はエンジンに最も有用ですが、ルートをバッチで読み込む必要がある任意のアプリケーションで使用することができます。

* 主な貢献者：[Aaron Batalion](http://blog.hungrymachine.com/)

### Rackベースの遅延読み込みセッション

Action Controllerのセッションストレージの基盤がRackレベルに押し下げられるという大きな変更がありました。これにはコード上でのかなりの作業が必要でしたが、Railsアプリケーションには完全に透過的です（さらに、古いCGIセッションハンドラに関するいくつかの問題が解決されました）。ただし、1つだけ重要な理由があります。非RailsのRackアプリケーションは、Railsアプリケーションと同じセッションストレージハンドラ（および同じセッション）にアクセスできるようになりました。さらに、セッションは現在のフレームワークの読み込みの改善に合わせて遅延読み込みされるようになりました。つまり、明示的にセッションを無効にする必要はもはやありません。参照しなければ読み込まれません。

### MIMEタイプの処理の変更

RailsのMIMEタイプの処理にはいくつかの変更があります。まず、`MIME::Type`は今や`=~`演算子を実装しており、シノニムを持つタイプの存在を確認する必要がある場合に非常にクリーンになりました。

```ruby
if content_type && Mime::JS =~ content_type
  # 何かクールなことをする
end

Mime::JS =~ "text/javascript"        => true
Mime::JS =~ "application/javascript" => true
```

もう1つの変更は、フレームワークがさまざまな場所でJavaScriptをチェックする際に`Mime::JS`を使用するようになり、これによりこれらの代替をきれいに処理できるようになりました。

* 主な貢献者：[Seth Fitzsimmons](http://www.workingwithrails.com/person/5510-seth-fitzsimmons)

### `respond_to`の最適化

Rails 2.3では、Rails-Merbチームの合併の最初の成果の一部として、`respond_to`メソッドの最適化が行われています。`respond_to`は、リクエストのMIMEタイプに基づいてコントローラが結果を異なる形式でフォーマットするために多くのRailsアプリケーションで頻繁に使用されるメソッドです。`method_missing`の呼び出しを削除し、プロファイリングと微調整を行った結果、3つのフォーマット間を切り替える単純な`respond_to`で秒あたりのリクエスト数が8%向上しています。最高の部分は、この高速化を利用するためにアプリケーションのコードを一切変更する必要がないことです。

### キャッシュのパフォーマンスの向上

Railsは、リモートキャッシュストアからの読み取りをリクエストごとにローカルキャッシュとして保持することで、不要な読み取りを削減し、サイトのパフォーマンスを向上させるようになりました。この作業はもともと`MemCacheStore`に限定されていましたが、必要なメソッドを実装するリモートストアならどのストアでも利用できます。

* 主な貢献者：[Nahum Wild](http://www.motionstandingstill.com/)

### ローカライズされたビュー

Railsは、設定したロケールに応じてローカライズされたビューを提供することができます。たとえば、`Posts`コントローラに`show`アクションがある場合、デフォルトでは`app/views/posts/show.html.erb`がレンダリングされます。しかし、`I18n.locale = :da`と設定すると、`app/views/posts/show.da.html.erb`がレンダリングされます。ローカライズされたテンプレートが存在しない場合は、未装飾のバージョンが使用されます。Railsには、現在のRailsプロジェクトで利用可能な翻訳の配列を返す`I18n#available_locales`と`I18n::SimpleBackend#available_locales`も含まれています。

さらに、同じ方法を使用してパブリックディレクトリ内のレスキューファイルをローカライズすることもできます。たとえば、`public/500.da.html`や`public/404.en.html`などが機能します。

### パーシャルスコープのための翻訳

翻訳APIの変更により、パーシャル内でキーの翻訳を書く際により簡単で繰り返しの少ない方法が提供されます。`people/index.html.erb`テンプレートから`translate(".foo")`を呼び出すと、実際には`I18n.translate("people.index.foo")`が呼び出されます。キーの前にピリオドを付けない場合、APIはスコープされません（以前と同様）。
### その他のアクションコントローラの変更

* ETagの処理が少し改善されました。Railsは、レスポンスに本文がない場合や`send_file`でファイルを送信する場合には、ETagヘッダーを送信しないようになりました。
* RailsはIPスプーフィングのチェックを行うことができますが、携帯電話とのトラフィックが多いサイトでは、プロキシが正しく設定されていないことが多いため、これが迷惑になることがあります。その場合は、`ActionController::Base.ip_spoofing_check = false`と設定することで、チェックを無効にすることができます。
* `ActionController::Dispatcher`は、独自のミドルウェアスタックを実装するようになりました。これは、`rake middleware`を実行することで確認することができます。
* Cookieセッションには、サーバーサイドストアとのAPI互換性を持つ永続的なセッション識別子が追加されました。
* `send_file`と`send_data`の`:type`オプションには、今やシンボルを使用することができます。例えば、`send_file("fabulous.png", :type => :png)`のように使用します。
* `map.resources`の`:only`オプションと`:except`オプションは、ネストされたリソースには継承されなくなりました。
* バンドルされているmemcachedクライアントは、バージョン1.6.4.99に更新されました。
* `expires_in`、`stale?`、`fresh_when`メソッドは、プロキシキャッシュとの互換性を確保するために、`:public`オプションを受け入れるようになりました。
* `:requirements`オプションは、追加のRESTfulメンバールートでも正しく機能するようになりました。
* シャロールートは、名前空間を正しく尊重するようになりました。
* `polymorphic_url`は、不規則な複数形の名前を持つオブジェクトを扱う際に、より良いパフォーマンスを発揮します。

アクションビュー
-----------

Rails 2.3のアクションビューでは、ネストされたモデルフォーム、`render`の改善、柔軟な日付選択ヘルパーのプロンプトなど、さまざまな改善が行われています。

### ネストされたオブジェクトフォーム

親モデルが子オブジェクトのネストされた属性を受け入れる場合（Active Recordのセクションで説明されているように）、`form_for`と`field_for`を使用してネストされたフォームを作成することができます。これらのフォームは任意の深さでネストすることができ、冗長なコードなしで複雑なオブジェクトの階層を単一のビューで編集することができます。例えば、次のモデルがある場合：

```ruby
class Customer < ActiveRecord::Base
  has_many :orders

  accepts_nested_attributes_for :orders, :allow_destroy => true
end
```

Rails 2.3では、次のようなビューを作成することができます：

```html+erb
<% form_for @customer do |customer_form| %>
  <div>
    <%= customer_form.label :name, 'Customer Name:' %>
    <%= customer_form.text_field :name %>
  </div>

  <!-- ここでは、customer_formビルダーインスタンスに対してfields_forを呼び出しています。
  ブロックはordersコレクションの各メンバーごとに呼び出されます。 -->
  <% customer_form.fields_for :orders do |order_form| %>
    <p>
      <div>
        <%= order_form.label :number, 'Order Number:' %>
        <%= order_form.text_field :number %>
      </div>

  <!-- モデルのallow_destroyオプションにより、子レコードの削除が可能になります。 -->
      <% unless order_form.object.new_record? %>
        <div>
          <%= order_form.label :_delete, 'Remove:' %>
          <%= order_form.check_box :_delete %>
        </div>
      <% end %>
    </p>
  <% end %>

  <%= customer_form.submit %>
<% end %>
```

* 主な貢献者：[Eloy Duran](http://superalloy.nl/)
* 詳細情報：
    * [Nested Model Forms](https://weblog.rubyonrails.org/2009/1/26/nested-model-forms)
    * [complex-form-examples](https://github.com/alloy/complex-form-examples)
    * [What's New in Edge Rails: Nested Object Forms](http://archives.ryandaigle.com/articles/2009/2/1/what-s-new-in-edge-rails-nested-attributes)

### パーシャルのスマートなレンダリング

`render`メソッドは、年々賢くなってきており、今ではさらに賢くなりました。オブジェクトやコレクションと適切なパーシャルがある場合、命名が一致している場合、オブジェクトを単純にレンダリングするだけで動作するようになりました。例えば、Rails 2.3では、次のような`render`呼び出しはビューで動作します（適切な命名がされている場合）：

```ruby
# render :partial => 'articles/_article',
# :object => @article
render @article

# render :partial => 'articles/_article',
# :collection => @articles
render @articles
```

* 詳細情報：[What's New in Edge Rails: render Stops Being High-Maintenance](http://archives.ryandaigle.com/articles/2008/11/20/what-s-new-in-edge-rails-render-stops-being-high-maintenance)

### 日付選択ヘルパーのプロンプト

Rails 2.3では、日付選択ヘルパー（`date_select`、`time_select`、`datetime_select`）に対して、コレクション選択ヘルパーと同様にカスタムプロンプトを指定することができます。プロンプト文字列または各コンポーネントの個別のプロンプト文字列のハッシュを指定することができます。また、カスタムの一般的なプロンプトを使用するには、`:prompt`を`true`に設定することもできます。

```ruby
select_datetime(DateTime.now, :prompt => true)

select_datetime(DateTime.now, :prompt => "Choose date and time")

select_datetime(DateTime.now, :prompt =>
  {:day => 'Choose day', :month => 'Choose month',
   :year => 'Choose year', :hour => 'Choose hour',
   :minute => 'Choose minute'})
```

* 主な貢献者：[Sam Oliver](http://samoliver.com/)

### AssetTagのタイムスタンプキャッシュ

Railsでは、静的なアセットパスにタイムスタンプを追加して「キャッシュバスター」として使用することが一般的です。これにより、サーバー上で変更した画像やスタイルシートなどの古いコピーがユーザーのブラウザキャッシュから提供されないようになります。Action Viewの`cache_asset_timestamps`設定オプションを使用して、この動作を変更することができます。キャッシュを有効にすると、Railsはアセットを最初に提供する際にタイムスタンプを計算し、その値を保存します。これにより、静的アセットを提供するための（高価な）ファイルシステム呼び出しの回数が減りますが、サーバーが実行中の間にアセットを変更しても、クライアントに変更が反映されないことになります。
### オブジェクトとしてのアセットホスト

エッジRailsでは、アセットホストを特定の呼び出しに応答するオブジェクトとして宣言することができるため、アセットホストはより柔軟になります。これにより、アセットホスティングに必要な複雑なロジックを実装することができます。

* 詳細はこちら：[asset-hosting-with-minimum-ssl](https://github.com/dhh/asset-hosting-with-minimum-ssl/tree/master)

### grouped_options_for_selectヘルパーメソッド

Action Viewにはすでにセレクトコントロールの生成を支援するためのヘルパーがいくつかありますが、これに加えて`grouped_options_for_select`があります。これは、文字列の配列またはハッシュを受け取り、`optgroup`タグで囲まれた`option`タグの文字列に変換します。例えば：

```ruby
grouped_options_for_select([["Hats", ["Baseball Cap","Cowboy Hat"]]],
  "Cowboy Hat", "Choose a product...")
```

は以下を返します：

```html
<option value="">Choose a product...</option>
<optgroup label="Hats">
  <option value="Baseball Cap">Baseball Cap</option>
  <option selected="selected" value="Cowboy Hat">Cowboy Hat</option>
</optgroup>
```

### フォームセレクトヘルパーの無効なオプションタグ

フォームセレクトヘルパー（`select`や`options_for_select`など）は、結果のタグで無効にする値を単一の値または値の配列として受け入れる`:disabled`オプションをサポートしています。

```ruby
select(:post, :category, Post::CATEGORIES, :disabled => 'private')
```

は以下を返します：

```html
<select name="post[category]">
<option>story</option>
<option>joke</option>
<option>poem</option>
<option disabled="disabled">private</option>
</select>
```

また、無効にするオプションを実行時に決定するために、無名関数を使用することもできます。

```ruby
options_from_collection_for_select(@product.sizes, :name, :id, :disabled => lambda{|size| size.out_of_stock?})
```

* 主な貢献者：[Tekin Suleyman](http://tekin.co.uk/)
* 詳細はこちら：[New in rails 2.3 - disabled option tags and lambdas for selecting and disabling options from collections](https://tekin.co.uk/2009/03/new-in-rails-23-disabled-option-tags-and-lambdas-for-selecting-and-disabling-options-from-collections)

### テンプレートの読み込みに関する注意事項

Rails 2.3では、特定の環境でキャッシュされたテンプレートを有効または無効にする機能が追加されました。キャッシュされたテンプレートは、レンダリング時に新しいテンプレートファイルをチェックしないため、スピードが向上しますが、サーバーを再起動せずにテンプレートを「オンザフライ」で置き換えることはできません。

ほとんどの場合、テンプレートキャッシュを本番環境で有効にしたい場合は、`production.rb`ファイルで設定を行うことができます。

```ruby
config.action_view.cache_template_loading = true
```

この行は、新しいRails 2.3アプリケーションではデフォルトで生成されます。古いバージョンのRailsからアップグレードした場合、Railsは本番環境とテストではテンプレートをキャッシュし、開発環境ではキャッシュしません。

### その他のAction Viewの変更

* CSRF保護のためのトークン生成が簡素化されました。Railsは、セッションIDをいじるのではなく、`ActiveSupport::SecureRandom`によって生成されたシンプルなランダム文字列を使用します。
* `auto_link`は、生成されたメールリンクに対して`target`や`class`などのオプションを正しく適用します。
* `autolink`ヘルパーは、少し整理されてわかりやすくなりました。
* `current_page?`は、URLに複数のクエリパラメータがある場合でも正しく動作します。

Active Support
--------------

Active Supportにはいくつかの興味深い変更があります。その中には、`Object#try`の導入も含まれています。

### Object#try

多くの人々が、オブジェクト上で操作を試みるために`try()`を使用するという考え方を採用しています。ビューでは、`<%= @person.try(:name) %>`のようなコードを書くことで、nilチェックを回避することができます。それがRailsに組み込まれました。Railsでは、プライベートメソッドに対しては`NoMethodError`を発生させ、オブジェクトがnilの場合は常に`nil`を返します。

* 詳細はこちら：[try()](http://ozmm.org/posts/try.html)

### Object#tapのバックポート

`Object#tap`は、[Ruby 1.9](http://www.ruby-doc.org/core-1.9/classes/Object.html#M000309)と1.8.7に追加されたもので、Railsには以前からある`returning`メソッドと似ています。ブロックに対してyieldし、yieldされたオブジェクトを返します。Railsは、この機能を古いバージョンのRubyでも利用できるようにするためのコードを含んでいます。

### XMLmini用のパーサーの交換可能性

Active SupportのXMLパースのサポートは、異なるパーサーを交換できるようになりました。デフォルトでは、標準のREXML実装が使用されますが、適切なgemがインストールされている場合は、簡単に高速なLibXMLやNokogiriの実装を指定することができます。

```ruby
XmlMini.backend = 'LibXML'
```

* 主な貢献者：[Bart ten Brinke](http://www.movesonrails.com/)
* 主な貢献者：[Aaron Patterson](http://tenderlovemaking.com/)

### TimeWithZoneのための小数秒

`Time`と`TimeWithZone`クラスには、XMLに適した文字列で時間を返すための`xmlschema`メソッドがあります。Rails 2.3以降、`TimeWithZone`は、`Time`と同じように、返される文字列の小数秒部分の桁数を指定するための引数をサポートしています。

```ruby
Time.zone.now.xmlschema(6) # => "2009-01-16T13:00:06.13653Z"
```
* 主な寄稿者：[Nicholas Dainty](http://www.workingwithrails.com/person/13536-nicholas-dainty)

### JSONキーの引用

「json.org」サイトの仕様を調べると、JSON構造のすべてのキーは文字列でなければならず、ダブルクォートで引用する必要があることがわかります。Rails 2.3以降、数値キーでも正しく処理されます。

### その他のActive Supportの変更

* `Enumerable#none?`を使用して、要素が提供されたブロックと一致しないことを確認できます。
* Active Supportの[デリゲート](https://afreshcup.com/home/2008/10/19/coming-in-rails-22-delegate-prefixes)を使用している場合、新しい`:allow_nil`オプションを使用すると、対象オブジェクトがnilの場合に例外を発生させずに`nil`を返すことができます。
* `ActiveSupport::OrderedHash`：`each_key`と`each_value`を実装しました。
* `ActiveSupport::MessageEncryptor`は、信頼できない場所（クッキーなど）に格納するための情報を暗号化する簡単な方法を提供します。
* Active Supportの`from_xml`はもはやXmlSimpleに依存しません。代わりに、Railsには必要な機能だけを備えた独自のXmlMini実装が含まれています。これにより、Railsは持ち運んでいたXmlSimpleのバンドルコピーを廃止することができます。
* プライベートメソッドをメモ化すると、結果もプライベートになります。
* `String#parameterize`はオプションのセパレータを受け入れます：`"Quick Brown Fox".parameterize('_') => "quick_brown_fox"`。
* `number_to_phone`は7桁の電話番号も受け入れます。
* `ActiveSupport::Json.decode`は`\u0000`スタイルのエスケープシーケンスを処理します。

Railties
--------

上記でカバーされているRackの変更に加えて、Railties（Rails自体のコアコード）には、Rails Metal、アプリケーションテンプレート、および静かなバックトレースなど、多くの重要な変更があります。

### Rails Metal

Rails Metalは、Railsアプリケーション内の超高速エンドポイントを提供する新しいメカニズムです。MetalクラスはルーティングとAction Controllerをバイパスして、生のスピードを提供します（もちろん、Action Controllerのすべての機能を犠牲にしています）。これは、Railsを公開されたミドルウェアスタックを持つRackアプリケーションにするための最近の基盤作業をすべて活用しています。Metalエンドポイントは、アプリケーションまたはプラグインからロードできます。

* 詳細情報：
    * [Introducing Rails Metal](https://weblog.rubyonrails.org/2008/12/17/introducing-rails-metal)
    * [Rails Metal: a micro-framework with the power of Rails](http://soylentfoo.jnewland.com/articles/2008/12/16/rails-metal-a-micro-framework-with-the-power-of-rails-m)
    * [Metal: Super-fast Endpoints within your Rails Apps](http://www.railsinside.com/deployment/180-metal-super-fast-endpoints-within-your-rails-apps.html)
    * [What's New in Edge Rails: Rails Metal](http://archives.ryandaigle.com/articles/2008/12/18/what-s-new-in-edge-rails-rails-metal)

### アプリケーションテンプレート

Rails 2.3には、Jeremy McAnallyの[rg](https://github.com/jm/rg)アプリケーションジェネレータが組み込まれています。これは、Railsにテンプレートベースのアプリケーション生成が組み込まれたことを意味します。すべてのアプリケーションに含めるプラグインのセットなど、一度テンプレートを設定し、`rails`コマンドを実行するたびに繰り返し使用することができます。また、既存のアプリケーションにテンプレートを適用するためのrakeタスクもあります：

```bash
$ rake rails:template LOCATION=~/template.rb
```

これにより、テンプレートからの変更がプロジェクトが既に含んでいるコードの上に重ねられます。

* 主な寄稿者：[Jeremy McAnally](http://www.jeremymcanally.com/)
* 詳細情報：[Rails templates](http://m.onkey.org/2008/12/4/rails-templates)

### 静かなバックトレース

thoughtbotの[Quiet Backtrace](https://github.com/thoughtbot/quietbacktrace)プラグインを活用し、`Test::Unit`のバックトレースから行を選択的に削除できるようにするRails 2.3では、`ActiveSupport::BacktraceCleaner`と`Rails::BacktraceCleaner`がコアに実装されています。これにより、フィルタ（バックトレースの行に基づいた正規表現による置換を実行する）とサイレンサ（バックトレースの行を完全に削除する）の両方をサポートしています。Railsは新しいアプリケーションで最も一般的なノイズを取り除くために自動的にサイレンサを追加し、独自の追加を保持する`config/backtrace_silencers.rb`ファイルを作成します。この機能により、バックトレース内の任意のgemからのよりきれいな出力も可能になります。

### 開発モードでの起動時間の短縮と遅延読み込み/自動読み込み

Railsの一部（およびその依存関係）が必要な時にのみメモリに読み込まれるようにするための作業が行われました。コアフレームワークであるActive Support、Active Record、Action Controller、Action Mailer、およびAction Viewは、各クラスを遅延読み込みするために`autoload`を使用しています。この作業により、メモリの使用量を抑え、全体的なRailsのパフォーマンスを向上させることが期待されます。

また、新しい`preload_frameworks`オプションを使用して、コアライブラリを起動時に自動読み込みするかどうかを指定することもできます。これは、Railsを一度にすべて読み込む必要がある場合があるため、デフォルトでは`false`に設定されています- PassengerとJRubyは、Railsのすべてを一度に読み込む必要があります。

### rake gemタスクの書き直し

さまざまな<code>rake gem</code>タスクの内部が大幅に改訂され、さまざまなケースでシステムがより効果的に機能するようになりました。gemシステムは、開発時とランタイムの依存関係の違いを認識し、より堅牢な展開システムを持ち、ジェムのステータスをクエリする際により良い情報を提供し、ゼロから構築する際の「鶏と卵」の依存関係の問題に対してもより耐性があります。JRubyでのgemコマンドの使用や、既にベンダリングされているジェムの外部コピーを持ち込もうとする依存関係に対する修正もあります。
* 主な寄稿者：[David Dollar](http://www.workingwithrails.com/person/12240-david-dollar)

### その他のRailtiesの変更

* CIサーバーを更新してRailsをビルドするための手順が更新および拡張されました。
* 内部のRailsテストは`Test::Unit::TestCase`から`ActiveSupport::TestCase`に切り替えられ、RailsコアではテストにMochaが必要です。
* デフォルトの`environment.rb`ファイルが整理されました。
* dbconsoleスクリプトでは、すべての数字のパスワードをクラッシュせずに使用できるようになりました。
* `Rails.root`は現在`Pathname`オブジェクトを返すため、`File.join`を使用する既存のコードを直接使用できます。
* デフォルトでは、すべてのRailsアプリケーションで/ publicのCGIおよびFCGIディスパッチに関連するさまざまなファイルが生成されなくなりました（`rails`コマンドを実行するときに`--with-dispatchers`を追加するか、後で`rake rails:update:generate_dispatchers`で追加できます）。
* RailsガイドはAsciiDocからTextileマークアップに変換されました。
* スキャフォールドされたビューとコントローラーが少し整理されました。
* `script/server`は、特定のパスからRailsアプリケーションをマウントするための`--path`引数を受け入れるようになりました。
* 設定されたジェムが不足している場合、ジェムのrakeタスクは環境の多くの部分をスキップします。これにより、rake gems:installが実行できなかったジェムが不足している場合の多くの「鶏と卵」の問題が解決されます。
* ジェムは1回だけ展開されます。これにより、ファイルに読み取り専用のアクセス許可があるジェム（たとえば、hoe）に関する問題が修正されます。

非推奨

このリリースでは、いくつかの古いコードが非推奨となっています。

* インスペクタ、リーパー、およびスポーナースクリプトに依存するような方法で展開する（かなりまれな）Rails開発者の場合、これらのスクリプトはもはやRailsのコアに含まれていません。必要な場合は、[irs_process_scripts](https://github.com/rails/irs_process_scripts)プラグインを使用してコピーを取得できます。
* `render_component`はRails 2.3では「存在しない」になります。必要な場合は、[render_componentプラグイン](https://github.com/rails/render_component/tree/master)をインストールできます。
* Railsコンポーネントのサポートは削除されました。
* 統合テストに基づいたパフォーマンスを確認するために`script/performance/request`を実行するように慣れていた場合、新しいトリックを学ぶ必要があります。このスクリプトはもはやRailsのコアから削除されました。同じ機能を取得するためにインストールできる新しいrequest_profilerプラグインがあります。
* `ActionController::Base#session_enabled?`は非推奨となりました。セッションは遅延読み込みされるためです。
* `protect_from_forgery`の`:digest`および`:secret`オプションは非推奨となり、効果がありません。
* 一部の統合テストヘルパーが削除されました。`response.headers["Status"]`および`headers["Status"]`はもはや何も返さなくなりました。Rackは返されたヘッダーに「Status」を許可しません。ただし、`status`および`status_message`ヘルパーは引き続き使用できます。`response.headers["cookie"]`および`headers["cookie"]`はもはやCGIクッキーを返しません。生のクッキーヘッダーを確認するには`headers["Set-Cookie"]`を調べるか、クライアントに送信されたクッキーのハッシュを取得するために`cookies`ヘルパーを使用できます。
* `formatted_polymorphic_url`は非推奨です。代わりに`polymorphic_url`を使用して`:format`を指定します。
* `ActionController::Response#set_cookie`の`:http_only`オプションは、`:httponly`に名前が変更されました。
* `to_sentence`の`:connector`および`:skip_last_comma`オプションは、`:words_connector`、`:two_words_connector`、および`:last_word_connector`オプションに置き換えられました。
* 空の`file_field`コントロールでマルチパートフォームを投稿すると、以前のRailsのマルチパートパーサーとの違いにより、空の文字列ではなくnilが送信されるようになりました。

クレジット

リリースノートは[Mike Gunderloy](http://afreshcup.com)によって編集されました。このRails 2.3のリリースノートのバージョンは、Rails 2.3のRC2に基づいて編集されました。
