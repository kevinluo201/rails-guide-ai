**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 29fda46e32914456eb8369ab3f2cb7d6
Ruby on Rails 2.2 リリースノート
===============================

Rails 2.2 には、いくつかの新機能と改善が含まれています。このリストでは主要なアップグレードをカバーしていますが、すべてのバグ修正や変更は含まれていません。すべてを確認したい場合は、GitHub のメイン Rails リポジトリの [コミットリスト](https://github.com/rails/rails/commits/2-2-stable) をご覧ください。

Rails とともに、2.2 は [Ruby on Rails Guides](https://guides.rubyonrails.org/) の開始をマークしています。これは進行中の [Rails Guides hackfest](http://hackfest.rubyonrails.org/guide) の最初の成果物であり、Rails の主要な機能の高品質なドキュメントを提供します。

--------------------------------------------------------------------------------

インフラストラクチャ
--------------

Rails 2.2 は、Rails をスムーズに動作させ、他のシステムと接続するためのインフラストラクチャにとって重要なリリースです。

### 国際化

Rails 2.2 は、国際化（または i18n）のための簡単なシステムを提供します。

* 主な貢献者: Rails i18 チーム
* 詳細情報 :
    * [公式 Rails i18n ウェブサイト](http://rails-i18n.org)
    * [ついに。Ruby on Rails が国際化されました](https://web.archive.org/web/20140407075019/http://www.artweb-design.de/2008/7/18/finally-ruby-on-rails-gets-internationalized)
    * [Rails のローカライズ : デモアプリケーション](https://github.com/clemens/i18n_demo_app)

### Ruby 1.9 および JRuby との互換性

スレッドセーフティに加えて、Rails は JRuby および今後の Ruby 1.9 との互換性を確保するために多くの作業が行われました。Ruby 1.9 は移動するターゲットであるため、エッジ Rails をエッジ Ruby で実行することはまだ確実ではありませんが、Rails は後者がリリースされた時点で Ruby 1.9 への移行に備えています。

ドキュメント
-------------

Rails の内部ドキュメントは、コードコメントの形式で多くの場所で改善されています。さらに、[Ruby on Rails Guides](https://guides.rubyonrails.org/) プロジェクトは、主要な Rails コンポーネントの情報の決定版です。最初の公式リリースでは、Guides ページには以下が含まれています。

* [Rails のはじめ方](getting_started.html)
* [Rails データベースマイグレーション](active_record_migrations.html)
* [Active Record 関連付け](association_basics.html)
* [Active Record クエリインターフェース](active_record_querying.html)
* [Rails でのレイアウトとレンダリング](layouts_and_rendering.html)
* [Action View フォームヘルパー](form_helpers.html)
* [Rails ルーティングの基本](routing.html)
* [Action Controller の概要](action_controller_overview.html)
* [Rails キャッシュ](caching_with_rails.html)
* [Rails アプリケーションのテストガイド](testing.html)
* [Rails アプリケーションのセキュリティ](security.html)
* [Rails アプリケーションのデバッグ](debugging_rails_applications.html)
* [Rails プラグインの基本](plugins.html)

全体で、Guides は初心者から中級者の Rails 開発者に対して数万語のガイダンスを提供しています。

これらのガイドをローカルで生成するには、アプリケーション内で次のコマンドを実行します。

```bash
$ rake doc:guides
```

これにより、ガイドが `Rails.root/doc/guides` 内に配置され、お気に入りのブラウザで `Rails.root/doc/guides/index.html` を開くことで直接閲覧できます。

* [Xavier Noria](http://advogato.org/person/fxn/diary.html) と [Hongli Lai](http://izumi.plan99.net/blog/) からの主な貢献
* 詳細情報:
    * [Rails Guides hackfest](http://hackfest.rubyonrails.org/guide)
    * [Git ブランチでの Rails ドキュメントの改善を支援](https://weblog.rubyonrails.org/2008/5/2/help-improve-rails-documentation-on-git-branch)

HTTP とのより良い統合: ボックス外の ETag サポート
----------------------------------------------------------

HTTP ヘッダーでの ETag と最終変更日時のサポートにより、Rails は最近変更されていないリソースのリクエストを受け取った場合に空のレスポンスを返すことができるようになりました。これにより、レスポンスを送信する必要があるかどうかを確認できます。

```ruby
class ArticlesController < ApplicationController
  def show_with_respond_to_block
    @article = Article.find(params[:id])

    # リクエストが stale? へのオプションと異なるヘッダーを送信した場合、リクエストは実際には古くなっており、
    # respond_to ブロックがトリガーされます（および stale? 呼び出しのオプションがレスポンスに設定されます）。
    #
    # リクエストヘッダーが一致する場合、リクエストは新鮮であり、respond_to ブロックはトリガーされません。
    # 代わりに、デフォルトのレンダリングが行われます。これにより、last-modified および etag ヘッダーがチェックされ、
    # テンプレートのレンダリングではなく "304 Not Modified" を送信する必要があることが判断されます。
    if stale?(:last_modified => @article.published_at.utc, :etag => @article)
      respond_to do |wants|
        # 通常のレスポンス処理
      end
    end
  end

  def show_with_implied_render
    @article = Article.find(params[:id])

    # レスポンスヘッダーを設定し、リクエストと照合します。リクエストが新鮮でない場合
    # （つまり、etag または last-modified のいずれも一致しない場合）、
    # テンプレートのデフォルトのレンダリングが行われます。
    # リクエストが新鮮な場合、デフォルトのレンダリングは "304 Not Modified" を返し、
    # テンプレートのレンダリングは行われません。
    fresh_when(:last_modified => @article.published_at.utc, :etag => @article)
  end
end
```

スレッドセーフティ
-------------

Rails のスレッドセーフ化に関する作業は、Rails 2.2 で展開されています。ウェブサーバーインフラストラクチャに応じて、これによりメモリ内の Rails のコピーを減らすことで、より多くのリクエストを処理し、サーバーのパフォーマンスを向上させ、複数のコアの利用率を高めることができます。
アプリケーションの本番モードでマルチスレッドディスパッチを有効にするには、`config/environments/production.rb`に以下の行を追加してください。

```ruby
config.threadsafe!
```

* 詳細情報：
    * [Thread safety for your Rails](http://m.onkey.org/2008/10/23/thread-safety-for-your-rails)
    * [Thread safety project announcement](https://weblog.rubyonrails.org/2008/8/16/josh-peek-officially-joins-the-rails-core)
    * [Q/A: What Thread-safe Rails Means](http://blog.headius.com/2008/08/qa-what-thread-safe-rails-means.html)

Active Record
-------------

ここでは、トランザクションマイグレーションとプールされたデータベーストランザクションの2つの大きな追加点について説明します。また、結合テーブル条件の新しい（そしてよりクリーンな）構文や、その他の改善点もあります。

### トランザクションマイグレーション

従来、複数のステップを必要とするRailsのマイグレーションは問題の元でした。マイグレーション中に何か問題が発生した場合、エラーが発生するまでのすべての変更がデータベースに反映され、エラーが発生した後の変更は適用されませんでした。また、マイグレーションのバージョンは実行済みとして保存されていたため、問題を修正した後に単純に`rake db:migrate:redo`で再実行することはできませんでした。トランザクションマイグレーションは、これを改善するために、マイグレーションステップをDDLトランザクションでラップし、いずれかのステップが失敗した場合はマイグレーション全体を元に戻す仕組みです。Rails 2.2では、トランザクションマイグレーションはPostgreSQLでサポートされています。コードは将来的に他のデータベースタイプにも拡張可能であり、IBMは既にDB2アダプタをサポートするために拡張しています。

* 主な貢献者：[Adam Wiggins](http://about.adamwiggins.com/)
* 詳細情報：
    * [DDL Transactions](http://adam.heroku.com/past/2008/9/3/ddl_transactions/)
    * [A major milestone for DB2 on Rails](http://db2onrails.com/2008/11/08/a-major-milestone-for-db2-on-rails/)

### コネクションプーリング

コネクションプーリングを使用すると、Railsはデータベースリクエストをデータベース接続のプールに分散させることができます。デフォルトでは最大サイズ（デフォルトでは5ですが、`database.yml`に`pool`キーを追加して調整することもできます）まで成長します。これにより、多くの同時ユーザをサポートするアプリケーションのボトルネックが解消されます。また、ギブアップする前の待機タイムアウトはデフォルトで5秒です。`ActiveRecord::Base.connection_pool`を使用すると、必要に応じてプールに直接アクセスできます。

```yaml
development:
  adapter: mysql
  username: root
  database: sample_development
  pool: 10
  wait_timeout: 10
```

* 主な貢献者：[Nick Sieger](http://blog.nicksieger.com/)
* 詳細情報：
    * [What's New in Edge Rails: Connection Pools](http://archives.ryandaigle.com/articles/2008/9/7/what-s-new-in-edge-rails-connection-pools)

### 結合テーブル条件のハッシュ

ハッシュを使用して結合テーブルの条件を指定することができます。これは、複雑な結合をクエリする必要がある場合に大いに役立ちます。

```ruby
class Photo < ActiveRecord::Base
  belongs_to :product
end

class Product < ActiveRecord::Base
  has_many :photos
end

# 著作権フリーの写真を持つすべての商品を取得する
Product.all(:joins => :photos, :conditions => { :photos => { :copyright => false }})
```

* 詳細情報：
    * [What's New in Edge Rails: Easy Join Table Conditions](http://archives.ryandaigle.com/articles/2008/7/7/what-s-new-in-edge-rails-easy-join-table-conditions)

### 新しいダイナミックファインダー

Active Recordのダイナミックファインダーファミリーには、2つの新しいメソッドセットが追加されました。

#### `find_last_by_attribute`

`find_last_by_attribute`メソッドは、`Model.last(:conditions => {:attribute => value})`と同等です。

```ruby
# ロンドンから最後にサインアップしたユーザーを取得する
User.find_last_by_city('London')
```

* 主な貢献者：[Emilio Tagua](http://www.workingwithrails.com/person/9147-emilio-tagua)

#### `find_by_attribute!`

`find_by_attribute!`の新しいbang!バージョンは、`Model.first(:conditions => {:attribute => value}) || raise ActiveRecord::RecordNotFound`と同等です。一致するレコードが見つからない場合、このメソッドは`nil`を返す代わりに例外を発生させます。

```ruby
# 'Moby'がまだサインアップしていない場合は、ActiveRecord::RecordNotFound例外を発生させる！
User.find_by_name!('Moby')
```

* 主な貢献者：[Josh Susser](http://blog.hasmanythrough.com)

### 関連はprivate/protectedスコープを尊重する

Active Recordの関連プロキシは、プロキシされたオブジェクトのメソッドのスコープを尊重するようになりました。以前は（Userが`has_one :account`を持つ場合）、`@user.account.private_method`は関連するAccountオブジェクトのprivateメソッドを呼び出していました。これはRails 2.2では失敗します。この機能が必要な場合は、`@user.account.send(:private_method)`を使用するか、メソッドをprivateまたはprotectedではなくpublicにする必要があります。なお、`method_missing`をオーバーライドしている場合は、関連が正常に機能するために`respond_to`もオーバーライドする必要があります。

* 主な貢献者：Adam Milligan
* 詳細情報：
    * [Rails 2.2 Change: Private Methods on Association Proxies are Private](http://afreshcup.com/2008/10/24/rails-22-change-private-methods-on-association-proxies-are-private/)

### その他のActive Recordの変更点

* `rake db:migrate:redo`は、再実行する特定のマイグレーションを対象とするためのオプションのVERSIONを受け入れるようになりました。
* `config.active_record.timestamped_migrations = false`を設定すると、UTCタイムスタンプの代わりに数値プレフィックスを持つマイグレーションが作成されます。
* `:counter_cache => true`で宣言された関連のカウンターキャッシュカラムは、もはやゼロで初期化する必要はありません。
* `ActiveRecord::Base.human_name`は、モデル名の国際化対応のヒューマンな翻訳を提供します。

Action Controller
-----------------

コントローラ側では、ルートを整理するためのいくつかの変更があります。また、ルーティングエンジンの内部変更により、複雑なアプリケーションでのメモリ使用量が低下します。
### 浅いルートのネスト

浅いルートのネストは、深くネストされたリソースの使用の難しさに対する解決策を提供します。浅いネストでは、作業するリソースを一意に識別するために十分な情報を提供するだけで済みます。

```ruby
map.resources :publishers, :shallow => true do |publisher|
  publisher.resources :magazines do |magazine|
    magazine.resources :photos
  end
end
```

これにより、次のようなルートが認識されるようになります。

```
/publishers/1           ==> publisher_path(1)
/publishers/1/magazines ==> publisher_magazines_path(1)
/magazines/2            ==> magazine_path(2)
/magazines/2/photos     ==> magazines_photos_path(2)
/photos/3               ==> photo_path(3)
```

* 主な貢献者：[S. Brent Faulkner](http://www.unwwwired.net/)
* 詳細情報：
    * [Rails Routing from the Outside In](routing.html#nested-resources)
    * [What's New in Edge Rails: Shallow Routes](http://archives.ryandaigle.com/articles/2008/9/7/what-s-new-in-edge-rails-shallow-routes)

### メンバーまたはコレクションルートのメソッド配列

新しいメンバーまたはコレクションルートには、メソッドの配列を指定することができます。これにより、1つ以上のメソッドを処理する必要がある場合に、ルートをすぐに任意の動詞を受け入れるように定義する必要がなくなります。Rails 2.2では、次のような正当なルート宣言が可能です。

```ruby
map.resources :photos, :collection => { :search => [:get, :post] }
```

* 主な貢献者：[Brennan Dunn](http://brennandunn.com/)

### 特定のアクションを持つリソース

デフォルトでは、`map.resources`を使用してルートを作成すると、Railsは7つのデフォルトアクション（index、show、create、new、edit、update、destroy）のためのルートを生成します。しかし、これらのルートはアプリケーションのメモリを使用し、Railsに追加のルーティングロジックを生成させます。これからは、`:only`と`:except`オプションを使用して、Railsがリソースに対して生成するルートを細かく調整することができます。単一のアクション、アクションの配列、または特別な`:all`または`:none`オプションを指定することができます。これらのオプションはネストされたリソースにも継承されます。

```ruby
map.resources :photos, :only => [:index, :show]
map.resources :products, :except => :destroy
```

* 主な貢献者：[Tom Stuart](http://experthuman.com/)

### その他のアクションコントローラの変更

* リクエストのルーティング中に発生した例外のために、簡単に[カスタムエラーページを表示](http://m.onkey.org/2008/7/20/rescue-from-dispatching)できるようになりました。
* HTTP Acceptヘッダーはデフォルトで無効になっています。必要なフォーマットを示すために、`/customers/1.xml`などのフォーマット指定のURLの使用を推奨します。Acceptヘッダーが必要な場合は、`config.action_controller.use_accept_header = true`で再度有効にできます。
* ベンチマークの数値は、秒の小数部分ではなくミリ秒で報告されるようになりました。
* Railsは今ではHTTP専用のクッキー（およびセッションに使用）をサポートしており、新しいブラウザでのいくつかのクロスサイトスクリプティングのリスクを軽減します。
* `redirect_to`は、URIスキームを完全にサポートするようになりました（たとえば、svn`ssh: URI`にリダイレクトすることができます）。
* `render`は、適切なMIMEタイプでプレーンなバニラJavaScriptをレンダリングするための`:js`オプションをサポートしています。
* リクエスト偽装保護は、HTML形式のコンテンツリクエストにのみ適用されるように厳密化されました。
* ポリモーフィックURLは、渡されたパラメータがnilの場合にもより適切に動作します。たとえば、nilの日付で`polymorphic_path([@project, @date, @area])`を呼び出すと、`project_area_path`が返されます。

Action View
-----------

* `javascript_include_tag`と`stylesheet_link_tag`は、`:all`と一緒に使用するための新しい`:recursive`オプションをサポートしています。これにより、1行のコードでファイルのツリー全体をロードすることができます。
* 含まれるPrototype JavaScriptライブラリがバージョン1.6.0.3にアップグレードされました。
* `RJS#page.reload`を使用して、JavaScriptを介してブラウザの現在の場所をリロードできます。
* `atom_feed`ヘルパーは、XML処理命令を挿入するための`:instruct`オプションを受け入れるようになりました。

Action Mailer
-------------

Action Mailerは、メーラーレイアウトをサポートするようになりました。適切に名前付けられたレイアウト（たとえば、`CustomerMailer`クラスは`layouts/customer_mailer.html.erb`を使用することを期待します）を提供することで、HTMLメールをブラウザのビューと同じように美しくすることができます。

* 詳細情報：
    * [What's New in Edge Rails: Mailer Layouts](http://archives.ryandaigle.com/articles/2008/9/7/what-s-new-in-edge-rails-mailer-layouts)

Action Mailerは、GMailのSMTPサーバーをサポートし、自動的にSTARTTLSをオンにするようになりました。これにはRuby 1.8.7のインストールが必要です。

Active Support
--------------

Active Supportは、Railsアプリケーション向けのビルトインのメモ化、`each_with_object`メソッド、デリゲートに対するプレフィックスサポート、およびその他の新しいユーティリティメソッドを提供します。

### メモ化

メモ化は、メソッドを一度だけ初期化し、その値を繰り返し使用するために保管するパターンです。おそらく、自分のアプリケーションでこのパターンを使用したことがあるかもしれません。

```ruby
def full_name
  @full_name ||= "#{first_name} #{last_name}"
end
```

メモ化を使用すると、このタスクを宣言的な方法で処理できます。

```ruby
extend ActiveSupport::Memoizable

def full_name
  "#{first_name} #{last_name}"
end
memoize :full_name
```

メモ化の他の機能には、`unmemoize`、`unmemoize_all`、`memoize_all`があり、メモ化をオンまたはオフにするために使用できます。
* 主な寄稿者：[Josh Peek](http://joshpeek.com/)
* 追加情報：
    * [Edge Railsの新機能：簡単なメモ化](http://archives.ryandaigle.com/articles/2008/7/16/what-s-new-in-edge-rails-memoization)
    * [メモ化とは？メモ化のガイド](http://www.railway.at/articles/2008/09/20/a-guide-to-memoization)

### each_with_object

`each_with_object`メソッドは、Ruby 1.9からバックポートされたメソッドを使用して、`inject`の代替手段を提供します。このメソッドは、現在の要素とメモをブロックに渡しながら、コレクションを反復処理します。

```ruby
%w(foo bar).each_with_object({}) { |str, hsh| hsh[str] = str.upcase } # => {'foo' => 'FOO', 'bar' => 'BAR'}
```

主な寄稿者：[Adam Keys](http://therealadam.com/)

### プレフィックス付きデリゲート

あるクラスから別のクラスに振る舞いを委譲する場合、デリゲートされたメソッドを識別するためにプレフィックスを指定することができます。例えば：

```ruby
class Vendor < ActiveRecord::Base
  has_one :account
  delegate :email, :password, :to => :account, :prefix => true
end
```

これにより、`vendor#account_email`と`vendor#account_password`というデリゲートされたメソッドが生成されます。カスタムプレフィックスも指定できます：

```ruby
class Vendor < ActiveRecord::Base
  has_one :account
  delegate :email, :password, :to => :account, :prefix => :owner
end
```

これにより、`vendor#owner_email`と`vendor#owner_password`というデリゲートされたメソッドが生成されます。

主な寄稿者：[Daniel Schierbeck](http://workingwithrails.com/person/5830-daniel-schierbeck)

### その他のActive Supportの変更

* `ActiveSupport::Multibyte`の大幅な更新（Ruby 1.9との互換性の修正を含む）
* `ActiveSupport::Rescuable`の追加により、任意のクラスで`rescue_from`構文を使用できるようになりました。
* `Date`および`Time`クラスの`past?`、`today?`、`future?`を追加し、日付/時間の比較を容易にしました。
* `Array#second`から`Array#fifth`までのエイリアスとして`Array#[1]`から`Array#[4]`を追加しました。
* `Enumerable#many?`は、`collection.size > 1`をカプセル化します。
* `Inflector#parameterize`は、入力のURL用バージョンを生成し、`to_param`で使用できます。
* `Time#advance`は、小数点以下の日数と週数を認識するため、`1.7.weeks.ago`、`1.5.hours.since`などが可能です。
* 含まれるTzInfoライブラリは、バージョン0.3.12にアップグレードされました。
* `ActiveSupport::StringInquirer`は、文字列の等価性をテストするためのきれいな方法を提供します：`ActiveSupport::StringInquirer.new("abc").abc? => true`

Railties
--------

Railties（Rails自体のコアコード）では、`config.gems`メカニズムに最も大きな変更があります。

### config.gems

デプロイメントの問題を回避し、Railsアプリケーションをより自己完結型にするために、Railsアプリケーションが必要とするすべてのgemのコピーを`/vendor/gems`に配置することができます。この機能はRails 2.1で初めて登場しましたが、Rails 2.2ではより柔軟で堅牢になり、gem間の複雑な依存関係を処理します。Railsにおけるgemの管理には、次のコマンドが含まれます：

* `config.gem _gem_name_`（`config/environment.rb`ファイル内）：設定されたすべてのgemと、それら（およびその依存関係）がインストールされているか、凍結されているか、フレームワーク（フレームワークgemは、gemの依存関係コードが実行される前にRailsによってロードされるgemです。このようなgemは凍結できません）を一覧表示します。
* `rake gems`：コンピュータに不足しているgemをインストールします。
* `rake gems:unpack`：必要なgemのコピーを`/vendor/gems`に配置します。
* `rake gems:unpack:dependencies`：必要なgemとその依存関係のコピーを`/vendor/gems`に取得します。
* `rake gems:build`：不足しているネイティブ拡張をビルドします。
* `rake gems:refresh_specs`：Rails 2.1で作成されたベンダーgemをRails 2.2の保存方法に合わせるために、ベンダーgemを更新します。

コマンドラインで`GEM=_gem_name_`を指定することで、単一のgemを展開またはインストールすることができます。

* 主な寄稿者：[Matt Jones](https://github.com/al2o3cr)
* 追加情報：
    * [Edge Railsの新機能：Gem Dependencies](http://archives.ryandaigle.com/articles/2008/4/1/what-s-new-in-edge-rails-gem-dependencies)
    * [Rails 2.1.2と2.2RC1：RubyGemsをアップデートしてください](https://afreshcup.com/home/2008/10/25/rails-212-and-22rc1-update-your-rubygems)
    * [Lighthouseでの詳しい議論](http://rails.lighthouseapp.com/projects/8994-ruby-on-rails/tickets/1128)

### その他のRailtiesの変更

* [Thin](http://code.macournoyer.com/thin/)ウェブサーバーのファンであれば、`script/server`が直接Thinをサポートすることを知って喜ぶでしょう。
* `script/plugin install &lt;plugin&gt; -r &lt;revision&gt;`は、gitベースのプラグインとsvnベースのプラグインの両方で動作します。
* `script/console`は、`--debugger`オプションをサポートします。
* Rails自体をビルドするための継続的インテグレーションサーバーの設定手順がRailsソースに含まれています。
* `rake notes:custom ANNOTATION=MYFLAG`を使用して、カスタム注釈をリストアップすることができます。
* `Rails.env`を`StringInquirer`でラップし、`Rails.env.development?`のように使用できるようにしました。
* 廃止の警告を排除し、gemの依存関係を適切に処理するために、Railsはrubygems 1.3.1以上を必要とします。

廃止予定
----------

このリリースでは、いくつかの古いコードが廃止されています：

* `Rails::SecretKeyGenerator`は`ActiveSupport::SecureRandom`に置き換えられました。
* `render_component`は廃止されました。この機能が必要な場合は、[render_componentsプラグイン](https://github.com/rails/render_component/tree/master)を使用できます。
* パーシャルをレンダリングする際の暗黙のローカル代入は廃止されました。

    ```ruby
    def partial_with_implicit_local_assignment
      @customer = Customer.new("Marcel")
      render :partial => "customer"
    end
    ```

    以前のコードでは、パーシャル「customer」内で`customer`というローカル変数が利用可能でした。現在は、すべての変数を明示的に`:locals`ハッシュを介して渡す必要があります。
* `country_select`は削除されました。詳細情報やプラグインの代替方法については、[非推奨ページ](http://www.rubyonrails.org/deprecation/list-of-countries)を参照してください。
* `ActiveRecord::Base.allow_concurrency`はもはや効果を持ちません。
* `ActiveRecord::Errors.default_error_messages`は非推奨となり、代わりに`I18n.translate('activerecord.errors.messages')`を使用してください。
* 国際化のための`%s`および`%d`の補間構文は非推奨です。
* `String#chars`は非推奨となり、`String#mb_chars`を使用してください。
* 小数点以下の月や年の期間は非推奨です。代わりにRubyの`Date`および`Time`クラスの算術を使用してください。
* `Request#relative_url_root`は非推奨です。代わりに`ActionController::Base.relative_url_root`を使用してください。

クレジット
-------

リリースノートは[Mike Gunderloy](http://afreshcup.com)によって編集されました。
