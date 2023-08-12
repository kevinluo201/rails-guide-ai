**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: dd2584972aa8eae419ed5d55a287e27d
Ruby on Rails 3.0 リリースノート
===============================

Rails 3.0 はポニーと虹です！あなたの夕食を作って、洗濯物をたたんでくれます。それが到着する前の人生がどのように可能だったのか不思議に思うでしょう。これは私たちが今までに行った中で最高のバージョンです！

しかし、真剣に話すと、本当に素晴らしいものです。Merbチームが参加し、フレームワークの不可知論、スリムで高速な内部、およびいくつかの便利なAPIをもたらした良いアイデアがすべて取り入れられています。Merb 1.x から Rails 3.0 に移行する場合、多くのものが認識できるはずです。Rails 2.x から来る場合も、それを愛するでしょう。

私たちの内部のクリーンアップに興味がなくても、Rails 3.0 は喜ばれるでしょう。新しい機能と改善されたAPIがたくさんあります。Rails開発者になるのにこれほど良い時期はありませんでした。ハイライトのいくつかは次のとおりです。

* RESTful宣言に重点を置いた新しいルーター
* Action Controllerにモデル化された新しいAction Mailer API（今はマルチパートメッセージの苦痛がなくなりました！）
* リレーショナル代数の上に構築された新しいActive Recordチェーン可能なクエリ言語
* Prototype、jQueryなどのドライバーを備えた非侵入型のJavaScriptヘルパー（インラインJSの終了）
* Bundlerによる明示的な依存関係管理

それだけでなく、古いAPIを警告とともに非推奨にしました。これは、既存のアプリケーションをRails 3に移行する際に、すぐにすべての古いコードを最新のベストプラクティスに書き直す必要がないことを意味します。

これらのリリースノートは主要なアップグレードをカバーしていますが、すべての細かいバグ修正や変更は含まれていません。Rails 3.0 は、250人以上の著者によるほぼ4,000のコミットで構成されています！すべてを見たい場合は、GitHubのメインRailsリポジトリの[コミットのリスト](https://github.com/rails/rails/commits/3-0-stable)をチェックしてください。

--------------------------------------------------------------------------------

Rails 3をインストールするには：

```bash
# セットアップにsudoが必要な場合はsudoを使用してください
$ gem install rails
```


Rails 3へのアップグレード
--------------------

既存のアプリケーションをアップグレードする場合、入念なテストカバレッジを持っていることが重要です。また、Rails 3に更新する前に、まずRails 2.3.5にアップグレードし、アプリケーションが正常に動作することを確認してください。その後、以下の変更に注意してください：

### Rails 3は少なくともRuby 1.8.7を必要とします

Rails 3.0 はRuby 1.8.7以上が必要です。以前のRubyバージョンのサポートは公式に終了し、できるだけ早くアップグレードする必要があります。Rails 3.0 はRuby 1.9.2とも互換性があります。

TIP: Ruby 1.8.7 p248とp249には、Rails 3.0をクラッシュさせるマーシャリングのバグがあります。ただし、Ruby Enterprise Editionはリリース1.8.7-2010.02以降、これらのバグを修正しています。1.9系では、Rails 3.0で完全にセグフォルトが発生するため、スムーズに動作するためには1.9.2にジャンプする必要があります。

### Rails Applicationオブジェクト

同じプロセス内で複数のRailsアプリケーションを実行するための基盤をサポートするために、Rails 3ではApplicationオブジェクトの概念が導入されました。アプリケーションオブジェクトは、すべてのアプリケーション固有の設定を保持し、以前のバージョンのRailsの`config/environment.rb`と非常に似ています。

各Railsアプリケーションには、対応するアプリケーションオブジェクトが必要です。アプリケーションオブジェクトは`config/application.rb`で定義されます。既存のアプリケーションをRails 3にアップグレードする場合、このファイルを追加し、適切な設定を`config/environment.rb`から`config/application.rb`に移動する必要があります。

### script/* は script/rails に置き換えられました

新しい`script/rails`は、以前は`script`ディレクトリにあったすべてのスクリプトを置き換えます。ただし、直接`script/rails`を実行するわけではありません。`rails`コマンドは、Railsアプリケーションのルートで呼び出されていることを検出し、スクリプトを実行します。使用方法は次のとおりです：

```bash
$ rails console                      # script/consoleの代わりに
$ rails g scaffold post title:string # script/generate scaffold post title:stringの代わりに
```

すべてのオプションのリストについては、`rails --help`を実行してください。

### 依存関係とconfig.gem

`config.gem`メソッドはなくなり、`bundler`と`Gemfile`を使用するように置き換えられました。詳細は以下の「Gemsのベンダリング」を参照してください。

### アップグレードプロセス

アップグレードプロセスを支援するために、[Rails Upgrade](https://github.com/rails/rails_upgrade)というプラグインが作成されました。

プラグインをインストールした後、`rake rails:upgrade:check`を実行して、更新が必要な部分をアプリケーションでチェックします（更新方法に関する情報へのリンクが表示されます）。また、現在の`config.gem`呼び出しに基づいて`Gemfile`を生成するタスクや、現在のルートファイルから新しいルートファイルを生成するタスクも提供します。プラグインを取得するには、次のコマンドを実行してください：
```bash
$ ruby script/plugin install git://github.com/rails/rails_upgrade.git
```

それがどのように機能するかの例は[Rails Upgrade is now an Official Plugin](http://omgbloglol.com/post/364624593/rails-upgrade-is-now-an-official-plugin)で見ることができます。

Rails Upgradeツール以外にも、同じことをしており、同じ問題に直面している可能性のあるIRCや[rubyonrails-talk](https://discuss.rubyonrails.org/c/rubyonrails-talk)の人々がいます。アップグレードの際に自分自身の経験をブログに投稿して、他の人があなたの知識を活用できるようにしてください！

Rails 3.0アプリケーションの作成
--------------------------------

```bash
# 'rails' RubyGemがインストールされている必要があります
$ rails new myapp
$ cd myapp
```

### ジェムのベンダリング

Railsは、アプリケーションの開始に必要なジェムを決定するために、アプリケーションのルートに`Gemfile`を使用します。この`Gemfile`は[Bundler](https://github.com/bundler/bundler)によって処理され、すべての依存関係がインストールされます。それはアプリケーションにローカルに依存しないようにするために、すべての依存関係をインストールすることさえできます。

詳細はこちら：- [bundler homepage](https://bundler.io/)

### 最新版の利用

`Bundler`と`Gemfile`により、新しい専用の`bundle`コマンドを使用してRailsアプリケーションを簡単にフリーズすることができます。そのため、`rake freeze`はもはや関係ありません。

Gitリポジトリから直接バンドルする場合は、`--edge`フラグを渡すことができます。

```bash
$ rails new myapp --edge
```

Railsリポジトリのローカルチェックアウトがあり、それを使用してアプリケーションを生成したい場合は、`--dev`フラグを渡すことができます。

```bash
$ ruby /path/to/rails/bin/rails new myapp --dev
```

Railsのアーキテクチャの変更
---------------------------

Railsのアーキテクチャには6つの主な変更があります。

### Railtiesの再構築

Railtiesは、Railsフレームワーク全体の一貫したプラグインAPIを提供するように更新され、ジェネレータとRailsバインディングの完全な書き直しも行われました。その結果、開発者はジェネレータとアプリケーションフレームワークの任意の重要な段階に一貫した定義済みの方法でフックすることができるようになりました。

### すべてのRailsコアコンポーネントが切り離されました

MerbとRailsのマージに伴い、Railsコアコンポーネント間の緊密な結合を解消する作業が行われました。これは現在達成されており、すべてのRailsコアコンポーネントがプラグインの開発に使用できる同じAPIを使用しています。これは、作成するプラグインやDataMapperやSequelのようなコアコンポーネントの置き換えなど、Railsコアコンポーネントがアクセスできるすべての機能にアクセスし、拡張および強化することができることを意味します。

### Active Modelの抽象化

コアコンポーネントの切り離しの一環として、Active Recordへのすべての依存関係をAction Packから抽出しました。これは現在完了しています。新しいORMプラグインは、Action Packとシームレスに連携するためにActive Modelインターフェースを実装するだけで済みます。

### コントローラの抽象化

コアコンポーネントの切り離しのもう一つの大きな部分は、HTTPの概念から分離されたベースのスーパークラスを作成し、ビューのレンダリングなどを処理するためです。`AbstractController`の作成により、`ActionController`と`ActionMailer`は大幅に簡素化され、これらのライブラリから共通のコードが削除され、Abstract Controllerに配置されました。

### Arelの統合

[Arel](https://github.com/brynary/arel)（またはActive Relation）は、Active Recordの基盤として採用され、Railsで必要とされるようになりました。Arelは、Active RecordのSQL抽象化を提供し、Active Recordの関係機能の基盤を提供します。

### メールの抽出

Action Mailerは、その始まり以来、モンキーパッチ、プリパーサー、配信および受信エージェントを持っていました。さらに、TMailがソースツリーにベンダリングされていました。バージョン3では、すべてのメールメッセージ関連の機能が[Mail](https://github.com/mikel/mail)ジェムに抽象化されました。これにより、コードの重複が減少し、Action Mailerとメールパーサーの間に定義可能な境界が作成されます。

ドキュメント
-------------

Railsツリーのドキュメントは、すべてのAPIの変更が反映されるように更新されています。さらに、[Rails Edge Guides](https://edgeguides.rubyonrails.org/)もRails 3.0の変更を反映するために1つずつ更新されています。ただし、[guides.rubyonrails.org](https://guides.rubyonrails.org/)のガイドは引き続き安定版のRailsのみを含んでいます（現時点ではバージョン2.3.5、3.0がリリースされるまで）。
国際化
--------------------

Rails 3では、I18nサポートに関して多くの作業が行われており、最新の[I18n](https://github.com/svenfuchs/i18n) gemには多くの高速化が提供されています。

* 任意のオブジェクトにI18nの振る舞いを追加することができます。これは、`ActiveModel::Translation`と`ActiveModel::Validations`を含めることで実現できます。また、翻訳のための`errors.messages`のフォールバックもあります。
* 属性にはデフォルトの翻訳を設定することができます。
* フォームの送信タグは、オブジェクトの状態に応じて正しいステータス（作成または更新）を自動的に取得し、正しい翻訳を表示します。
* I18nを使用したラベルは、属性名を渡すだけで動作します。

詳細はこちらを参照してください：- [Rails 3 I18nの変更](http://blog.plataformatec.com.br/2010/02/rails-3-i18n-changes/)


Railties
--------

主要なRailsフレームワークの切り離しに伴い、Railtiesは大幅に改良され、フレームワーク、エンジン、またはプラグインのリンクアップをできるだけ簡単かつ拡張可能にするようになりました。

* 各アプリケーションには独自の名前空間があり、例えば`YourAppName.boot`でアプリケーションを起動することで、他のアプリケーションとのやり取りが容易になります。
* `Rails.root/app`以下のすべてのものがロードパスに追加されるため、`app/observers/user_observer.rb`を作成するだけでRailsがそれを修正せずにロードします。
* Rails 3.0では、さまざまなRails全体の設定オプションを一元的に提供する`Rails.config`オブジェクトが提供されます。

アプリケーションの生成には、test-unit、Active Record、Prototype、Gitのインストールをスキップするための追加のフラグが追加されました。また、新しい`--dev`フラグが追加され、アプリケーションがRailsのチェックアウトを指す`Gemfile`で設定されます（これは`rails`バイナリのパスによって決定されます）。詳細については、`rails --help`を参照してください。

Railtiesのジェネレータは、Rails 3.0で大幅に改良されました。

* ジェネレータは完全に書き直され、後方互換性がありません。
* RailsテンプレートAPIとジェネレータAPIが統合されました（以前と同じです）。
* ジェネレータはもはや特別なパスからロードされません。代わりに、Rubyのロードパスで見つかるようになりました。したがって、`rails generate foo`と呼び出すと、`generators/foo_generator`を探します。
* 新しいジェネレータはフックを提供し、テンプレートエンジン、ORM、テストフレームワークなどが簡単にフックできます。
* 新しいジェネレータでは、`Rails.root/lib/templates`にコピーを配置することでテンプレートを上書きすることができます。
* `Rails::Generators::TestCase`も提供されているため、独自のジェネレータを作成してテストすることができます。

また、Railtiesのジェネレータによって生成されるビューにもいくつかの改良が加えられました。

* ビューは、`p`タグの代わりに`div`タグを使用します。
* 生成されるスキャフォールドは、編集ビューと新規ビューの重複したコードの代わりに、`_form`パーシャルを使用します。
* スキャフォールドのフォームは、`f.submit`を使用しています。これにより、渡されたオブジェクトの状態に応じて「Create ModelName」または「Update ModelName」と表示されます。

最後に、rakeタスクにいくつかの改良が加えられました。

* `rake db:forward`が追加され、マイグレーションを個別またはグループ単位で進めることができます。
* `rake routes CONTROLLER=x`が追加され、1つのコントローラのルートのみを表示することができます。

Railtiesは次のものを非推奨としています。

* `RAILS_ROOT`は`Rails.root`に置き換えられました。
* `RAILS_ENV`は`Rails.env`に置き換えられました。
* `RAILS_DEFAULT_LOGGER`は`Rails.logger`に置き換えられました。

`PLUGIN/rails/tasks`と`PLUGIN/tasks`はもはやロードされず、すべてのタスクは`PLUGIN/lib/tasks`に配置する必要があります。

詳細はこちらを参照してください：

* [Rails 3のジェネレータの発見](http://blog.plataformatec.com.br/2010/01/discovering-rails-3-generators)
* [Railsモジュール（Rails 3で）](http://quaran.to/blog/2010/02/03/the-rails-module/)

Action Pack
-----------

Action Packでは、内部および外部の変更が大幅に行われました。


### Abstract Controller

Abstract Controllerは、Action Controllerの汎用部分を再利用可能なモジュールに分離しました。これにより、任意のライブラリがテンプレートのレンダリング、パーシャルのレンダリング、ヘルパー、翻訳、ログなど、リクエストレスポンスサイクルの任意の部分を使用できるようになりました。この抽象化により、`ActionMailer::Base`は今では単に`AbstractController`を継承し、Rails DSLをMail gemにラップするだけです。

また、Action Controllerを整理する機会も提供され、コードを簡素化するためにできるだけ抽象化しました。

ただし、Abstract Controllerはユーザー向けのAPIではなく、Railsの日常的な使用では遭遇することはありません。

詳細はこちらを参照してください：- [Rails Edge Architecture](http://yehudakatz.com/2009/06/11/rails-edge-architecture/)


### Action Controller

* `application_controller.rb`では、デフォルトで`protect_from_forgery`が有効になっています。
* `cookie_verifier_secret`は非推奨となり、代わりに`Rails.application.config.cookie_secret`を使用して割り当てられ、独自のファイル`config/initializers/cookie_verification_secret.rb`に移動しました。
* `session_store`は`ActionController::Base.session`で設定されていましたが、これは`Rails.application.config.session_store`に移動しました。デフォルトは`config/initializers/session_store.rb`で設定されます。
* `cookies.secure`を使用して、暗号化された値をクッキーに設定することができます。例：`cookie.secure[:key] => value`。
* `cookies.permanent`を使用して、クッキーハッシュに永続的な値を設定できます。例：`cookie.permanent[:key] => value`。署名された値の場合、検証エラーが発生した場合に例外が発生します。
* `:notice => 'This is a flash message'`または`:alert => 'Something went wrong'`を`respond_to`ブロック内の`format`呼び出しに渡すことができます。`flash[]`ハッシュは以前と同じように機能します。
* コントローラで`respond_with`メソッドが追加され、古くからある`format`ブロックを簡素化します。
* `ActionController::Responder`が追加され、レスポンスの生成方法を柔軟に設定できるようになりました。
非推奨:

* `filter_parameter_logging`は、`config.filter_parameters << :password`を使用するように非推奨となりました。

詳細情報:

* [Rails 3でのレンダリングオプション](https://blog.engineyard.com/2010/render-options-in-rails-3)
* [ActionController::Responderを愛する3つの理由](https://weblog.rubyonrails.org/2009/8/31/three-reasons-love-responder)


### Action Dispatch

Action DispatchはRails 3.0で新しく導入され、ルーティングのための新しい、よりクリーンな実装を提供します。

* ルーターの大規模なクリーンアップと書き直しを行い、Railsルーターは`rack_mount`という独立したソフトウェアの上にRails DSLを持つようになりました。
* 各アプリケーションで定義されるルートは、Applicationモジュール内に名前空間化されるようになりました。つまり、次のようになります:

    ```ruby
    # 以前は:

    ActionController::Routing::Routes.draw do |map|
      map.resources :posts
    end

    # これからは:

    AppName::Application.routes do
      resources :posts
    end
    ```

* ルーターに`match`メソッドが追加され、マッチしたルートに任意のRackアプリケーションを渡すこともできます。
* ルーターに`constraints`メソッドが追加され、定義された制約でルーターを保護することができます。
* ルーターに`scope`メソッドが追加され、異なる言語や異なるアクションのためにルートを名前空間化することができます。例えば:

    ```ruby
    scope 'es' do
      resources :projects, :path_names => { :edit => 'cambiar' }, :path => 'proyecto'
    end

    # /es/proyecto/1/cambiar でeditアクションを提供します
    ```

* ルーターに`root`メソッドが追加され、`match '/', :to => path`のショートカットとして使用できます。
* マッチにオプションセグメントを渡すことができます。例えば、`match "/:controller(/:action(/:id))(.:format)"`のように、各括弧で囲まれたセグメントはオプションです。
* ルートはブロックを使って表現することもできます。例えば、`controller :home { match '/:action' }`と呼び出すことができます。

注意: 旧スタイルの`map`コマンドは、後方互換性のレイヤーを備えて以前と同じように動作しますが、これは3.1リリースで削除されます。

非推奨:

* REST以外のアプリケーションのためのキャッチオールルート(`/:controller/:action/:id`)はコメントアウトされています。
* `:path_prefix`ルートはもはや存在せず、`:name_prefix`は与えられた値の末尾に自動的に"_"が追加されるようになりました。

詳細情報:
* [Rails 3ルーター: Rack it Up](http://yehudakatz.com/2009/12/26/the-rails-3-router-rack-it-up/)
* [Rails 3でのルートの刷新](https://medium.com/fusion-of-thoughts/revamped-routes-in-rails-3-b6d00654e5b0)
* [Rails 3での汎用アクション](http://yehudakatz.com/2009/12/20/generic-actions-in-rails-3/)


### Action View

#### Unobtrusive JavaScript

Action Viewヘルパーには大規模な書き直しが行われ、Unobtrusive JavaScript（UJS）フックが実装され、古いインラインAJAXコマンドが削除されました。これにより、Railsは準拠したUJSドライバを使用してヘルパーのUJSフックを実装することができます。

これは、以前の`remote_<method>`ヘルパーがRailsコアから削除され、[Prototype Legacy Helper](https://github.com/rails/prototype_legacy_helper)に移動されたことを意味します。HTMLにUJSフックを取得するためには、`remote => true`を渡すようになりました。例えば:

```ruby
form_for @post, :remote => true
```

次のようなHTMLを生成します:

```html
<form action="http://host.com" id="create-post" method="post" data-remote="true">
```

#### ブロックを使ったヘルパー

`form_for`や`div_for`など、ブロックからコンテンツを挿入するヘルパーは、今では`<%=`を使用します:

```html+erb
<%= form_for @post do |f| %>
  ...
<% end %>
```

同様のヘルパーは、手動で出力バッファに追加するのではなく、文字列を返すことが期待されています。

`cache`や`content_for`など、他の何かを行うヘルパーは、この変更の影響を受けません。引き続き`&lt;%`を使用する必要があります。

#### その他の変更

* HTML出力をエスケープするために`h(string)`を呼び出す必要はもはやありません。すべてのビューテンプレートでデフォルトで有効になっています。エスケープされていない文字列が必要な場合は、`raw(string)`を呼び出してください。
* ヘルパーはデフォルトでHTML5を出力するようになりました。
* フォームのラベルヘルパーは、シングルバリューでI18nから値を取得するようになりました。つまり、`f.label :name`は`:name`の翻訳を取得します。
* I18nのセレクトラベルは、`:en.helpers.select`ではなく、`:en.support.select`になるようになりました。
* ERBテンプレート内のRuby補間の末尾の改行をHTML出力から削除するために、末尾にマイナス記号を置く必要はもはやありません。
* Action Viewに`grouped_collection_select`ヘルパーが追加されました。
* `content_for?`が追加され、ビュー内でコンテンツの存在をチェックしてからレンダリングすることができます。
* フォームヘルパーに`value => nil`を渡すと、フィールドの`value`属性がデフォルト値ではなく`nil`に設定されます。
* フォームヘルパーに`id => nil`を渡すと、それらのフィールドは`id`属性を持たない状態でレンダリングされます。
* `image_tag`に`alt => nil`を渡すと、`img`タグは`alt`属性を持たない状態でレンダリングされます。

Active Model
------------

Active ModelはRails 3.0で新しく導入されました。これは、任意のORMライブラリがRailsと対話するために使用するためのActive Modelインターフェースを実装することにより、抽象化レイヤーを提供します。
### ORMの抽象化とAction Packインターフェース

コアコンポーネントのカップリングを解除するために、Active RecordからAction Packへのすべての関連を抽出する作業が行われました。これは現在完了しています。新しいORMプラグインは、Action Packとシームレスに連携するためにActive Modelのインターフェースを実装するだけで動作します。

詳細はこちら：- [Make Any Ruby Object Feel Like ActiveRecord](http://yehudakatz.com/2010/01/10/activemodel-make-any-ruby-object-feel-like-activerecord/)


### バリデーション

バリデーションはActive RecordからActive Modelに移動され、Rails 3でORMライブラリ全体で動作するバリデーションのインターフェースが提供されました。

* `validates :attribute, options_hash`というショートカットメソッドが追加され、すべてのバリデーションクラスメソッドにオプションを渡すことができます。バリデーションメソッドには複数のオプションを渡すことができます。
* `validates`メソッドには以下のオプションがあります：
    * `:acceptance => Boolean`.
    * `:confirmation => Boolean`.
    * `:exclusion => { :in => Enumerable }`.
    * `:inclusion => { :in => Enumerable }`.
    * `:format => { :with => Regexp, :on => :create }`.
    * `:length => { :maximum => Fixnum }`.
    * `:numericality => Boolean`.
    * `:presence => Boolean`.
    * `:uniqueness => Boolean`.

注意：Railsバージョン2.3のスタイルのバリデーションメソッドはすべてRails 3.0でもサポートされており、新しいvalidatesメソッドは既存のAPIの代替ではなく、モデルのバリデーションを補完するために設計されています。

また、Active Modelを使用するオブジェクト間で再利用できるバリデータオブジェクトを渡すこともできます：

```ruby
class TitleValidator < ActiveModel::EachValidator
  Titles = ['Mr.', 'Mrs.', 'Dr.']
  def validate_each(record, attribute, value)
    unless Titles.include?(value)
      record.errors[attribute] << 'must be a valid title'
    end
  end
end
```

```ruby
class Person
  include ActiveModel::Validations
  attr_accessor :title
  validates :title, :presence => true, :title => true
end

# またはActive Recordの場合

class Person < ActiveRecord::Base
  validates :title, :presence => true, :title => true
end
```

また、内省のサポートもあります：

```ruby
User.validators
User.validators_on(:login)
```

詳細は以下を参照してください：

* [Sexy Validation in Rails 3](http://thelucid.com/2010/01/08/sexy-validation-in-edge-rails-rails-3/)
* [Rails 3 Validations Explained](http://lindsaar.net/2010/1/31/validates_rails_3_awesome_is_true)


Active Record
-------------

Active RecordはRails 3.0で多くの注目を浴び、Active Modelへの抽象化、Arelを使用したクエリインターフェースの完全な更新、バリデーションの更新、および多くの改善と修正が行われました。Rails 2.xのすべてのAPIは、3.1バージョンまでサポートされる互換性レイヤーを介して使用できます。


### クエリインターフェース

Active RecordはArelを使用することで、コアメソッドでリレーションを返すようになりました。Rails 2.3.xの既存のAPIは引き続きサポートされ、Rails 3.1まで非推奨にならず、Rails 3.2まで削除されませんが、新しいAPIでは以下の新しいメソッドが提供され、すべてリレーションを返すため、チェーンすることができます：

* `where` - リレーションに条件を提供し、返される内容を指定します。
* `select` - データベースから返されるモデルの属性を選択します。
* `group` - 指定された属性でリレーションをグループ化します。
* `having` - グループリレーションを制限する式を提供します（GROUP BY制約）。
* `joins` - リレーションを別のテーブルに結合します。
* `clause` - 結合リレーションを制限する式を提供します（JOIN制約）。
* `includes` - 他のリレーションを事前にロードします。
* `order` - 指定された式に基づいてリレーションを並べ替えます。
* `limit` - 指定されたレコード数にリレーションを制限します。
* `lock` - テーブルから返されるレコードをロックします。
* `readonly` - データの読み取り専用コピーを返します。
* `from` - 複数のテーブルから関係を選択する方法を提供します。
* `scope` - （以前の`named_scope`）リレーションを返し、他のリレーションメソッドとチェーンすることができます。
* `with_scope` - および`with_exclusive_scope`もリレーションを返すようになり、チェーンすることができます。
* `default_scope` - リレーションでも機能します。

詳細は以下を参照してください：

* [Active Record Query Interface](http://m.onkey.org/2010/1/22/active-record-query-interface)
* [Let your SQL Growl in Rails 3](http://hasmanyquestions.wordpress.com/2010/01/17/let-your-sql-growl-in-rails-3/)


### 改善点

* Active Recordオブジェクトに`:destroyed?`が追加されました。
* Active Recordの関連に`:inverse_of`が追加され、データベースにアクセスせずにすでにロードされた関連のインスタンスを取得できるようになりました。


### パッチと非推奨

さらに、Active Recordブランチで多くの修正が行われました：

* SQLite 2のサポートはSQLite 3に置き換えられました。
* カラムの順序に対するMySQLのサポート。
* PostgreSQLアダプタの`TIME ZONE`サポートが修正され、不正な値が挿入されなくなりました。
* PostgreSQLのテーブル名に複数のスキーマをサポート。
* PostgreSQLのXMLデータ型カラムのサポート。
* `table_name`はキャッシュされるようになりました。
* Oracleアダプタにも多くのバグ修正が行われました。
以下の非推奨事項もあります：

* Active Recordクラス内の`named_scope`は非推奨となり、`scope`に名前が変更されました。
* `scope`メソッドでは、`:conditions => {}`の代わりに関連メソッドを使用するように移行する必要があります。例えば、`scope :since, lambda {|time| where("created_at > ?", time) }`。
* `save(false)`は非推奨であり、`save(:validate => false)`を使用するようになりました。
* Active RecordのI18nエラーメッセージは、`:en.activerecord.errors.template`から`:en.errors.template`に変更する必要があります。
* `model.errors.on`は非推奨であり、`model.errors[]`を使用するようになりました。
* `validates_presence_of` => `validates... :presence => true`
* `ActiveRecord::Base.colorize_logging`と`config.active_record.colorize_logging`は非推奨であり、`Rails::LogSubscriber.colorize_logging`または`config.colorize_logging`を使用するようになりました。

注意：State Machineの実装はActive Recordのエッジに数ヶ月間存在していましたが、Rails 3.0リリースから削除されました。

Active Resource
---------------

Active ResourceもActive Modelに抽出され、Active ResourceオブジェクトをAction Packとシームレスに使用できるようになりました。

* Active Modelを介したバリデーションの追加。
* オブザーバーフックの追加。
* HTTPプロキシのサポート。
* ダイジェスト認証のサポートの追加。
* モデルの命名をActive Modelに移動。
* Active Resource属性をインデックスアクセス可能なハッシュに変更。
* 同等の検索スコープのための`first`、`last`、`all`のエイリアスを追加。
* `find_every`は、何も返さない場合に`ResourceNotFound`エラーを返さないように変更されました。
* オブジェクトが`valid?`でない場合に`ResourceInvalid`を発生させる`save!`を追加。
* Active Resourceモデルに`update_attribute`と`update_attributes`を追加。
* `exists?`を追加。
* `SchemaDefinition`を`Schema`に、`define_schema`を`schema`に名前変更。
* エラーをロードするために、リモートエラーの`content-type`ではなくActive Resourcesの`format`を使用するように変更。
* スキーマブロックには`instance_eval`を使用。
* `ActiveResource::ConnectionError#to_s`を修正し、`@response`が`#code`または`#message`に応答しない場合にRuby 1.9の互換性を処理するように変更。
* JSON形式のエラーのサポートを追加。
* 数値配列で`load`が動作するように修正。
* リモートリソースからの410レスポンスをリソースが削除されたと認識するように変更。
* Active Resource接続にSSLオプションを設定する機能を追加。
* 接続タイムアウトの設定は`Net::HTTP`の`open_timeout`にも影響を与えます。

非推奨事項：

* `save(false)`は非推奨であり、`save(:validate => false)`を使用するようになりました。
* Ruby 1.9.2：`URI.parse`と`.decode`は非推奨となり、ライブラリでは使用されなくなりました。

Active Support
--------------

Active Supportでは、Active Supportライブラリ全体を要求する必要がなくなるように、チェリーピック可能にするための大きな努力が行われました。これにより、Railsのさまざまなコアコンポーネントをよりスリムに実行することができます。

Active Supportの主な変更点は以下です：

* ライブラリ内の未使用のメソッドを大幅に削除しました。
* Active SupportはもはやTZInfo、Memcache Client、Builderのバージョンを提供しません。これらはすべて依存関係として含まれ、`bundle install`コマンドでインストールされます。
* `ActiveSupport::SafeBuffer`でセーフバッファが実装されました。
* `Array.uniq_by`と`Array.uniq_by!`を追加しました。
* `Array#rand`を削除し、Ruby 1.9から`Array#sample`をバックポートしました。
* `TimeZone.seconds_to_utc_offset`が誤った値を返すバグを修正しました。
* `ActiveSupport::Notifications`ミドルウェアを追加しました。
* `ActiveSupport.use_standard_json_time_format`はデフォルトでtrueになりました。
* `ActiveSupport.escape_html_entities_in_json`はデフォルトでfalseになりました。
* `Integer#multiple_of?`はゼロを引数として受け入れ、レシーバがゼロでない場合はfalseを返します。
* `string.chars`は`string.mb_chars`に名前が変更されました。
* `ActiveSupport::OrderedHash`はYAMLを介して逆シリアル化できるようになりました。
* LibXMLとNokogiriを使用したXmlMiniのSAXベースのパーサーを追加しました。
* `Object#presence`を追加し、`#present?`であればオブジェクトを返し、そうでなければ`nil`を返します。
* `String#exclude?`コア拡張を追加し、`#include?`の逆を返します。
* `ActiveSupport`の`DateTime`に`to_i`を追加し、`DateTime`属性を持つモデルで`to_yaml`が正しく動作するようにしました。
* `Enumerable#include?`と同等の`Enumerable#exclude?`を追加し、`!x.include?`を避けます。
* RailsのためにデフォルトでXSSエスケープをオンに切り替えます。
* `ActiveSupport::HashWithIndifferentAccess`でのディープマージのサポートを追加します。
* `Enumerable#sum`は、`:size`に応答しない場合でもすべての列挙可能なオブジェクトで動作するようになりました。
* 長さがゼロの期間の`inspect`は、空の文字列ではなく'0 seconds'を返します。
* `ModelName`に`element`と`collection`を追加します。
* `String#to_time`と`String#to_datetime`は小数秒を処理できるようになりました。
* 新しいコールバックに対応するために、`:before`と`:after`に応答するaroundフィルターオブジェクトのサポートを追加しました。
* `ActiveSupport::OrderedHash#to_a`メソッドは、配列の順序付けられたセットを返します。Ruby 1.9の`Hash#to_a`に一致します。
* `MissingSourceFile`は定数として存在しますが、現在は単に`LoadError`と等しいです。
* クラスレベルの属性を宣言できるようにするために、`Class#class_attribute`を追加しました。この属性の値は継承可能で、サブクラスで上書きできます。
* `ActiveRecord::Associations`で`DeprecatedCallbacks`を最終的に削除しました。
* `Object#metaclass`は、Rubyに合わせるために`Kernel#singleton_class`に変更されました。
以下のメソッドは、Ruby 1.8.7および1.9で利用可能になったため、削除されました。

* `Integer#even?`および`Integer#odd?`
* `String#each_char`
* `String#start_with?`および`String#end_with?`（3人称のエイリアスは保持されます）
* `String#bytesize`
* `Object#tap`
* `Symbol#to_proc`
* `Object#instance_variable_defined?`
* `Enumerable#none?`

REXMLのセキュリティパッチは、Ruby 1.8.7の初期のパッチレベルにまだ必要なため、Active Supportに残っています。Active Supportは、適用する必要があるかどうかを判断します。

以下のメソッドは、フレームワークで使用されなくなったため、削除されました。

* `Kernel#daemonize`
* `Object#remove_subclasses_of` `Object#extend_with_included_modules_from`、`Object#extended_by`
* `Class#remove_class`
* `Regexp#number_of_captures`、`Regexp.unoptionalize`、`Regexp.optionalize`、`Regexp#number_of_captures`

Action Mailer
-------------

Action Mailerは、TMailが新しいメールライブラリである[Mail](https://github.com/mikel/mail)に置き換えられることで、新しいAPIが与えられました。Action Mailer自体もほぼ完全に書き直され、ほぼすべてのコードが触れられました。その結果、Action Mailerは単純にAbstract Controllerを継承し、Mail gemをRails DSLでラップするようになりました。これにより、Action Mailerのコード量と他のライブラリの重複がかなり減少しました。

* すべてのメーラーは、デフォルトで`app/mailers`に配置されます。
* 新しいAPIを使用してメールを送信するための3つのメソッド`attachments`、`headers`、`mail`が利用可能になりました。
* Action Mailerは、`attachments.inline`メソッドを使用してインラインの添付ファイルをネイティブにサポートします。
* Action Mailerのメール送信メソッドは、`Mail::Message`オブジェクトを返すようになりました。これにより、`deliver`メッセージを送信して自分自身を送信することができます。
* すべての配信メソッドは、Mail gemに抽象化されました。
* メール配信メソッドは、有効なメールヘッダーフィールドとその値のペアのハッシュを受け入れることができます。
* `mail`配信メソッドは、Action Controllerの`respond_to`と同様の方法で動作し、テンプレートを明示的または暗黙的にレンダリングすることができます。Action Mailerは、必要に応じてメールをマルチパートメールに変換します。
* メールブロック内の`format.mime_type`呼び出しには、procを渡すことができ、特定のタイプのテキストを明示的にレンダリングしたり、レイアウトや異なるテンプレートを追加したりすることができます。proc内の`render`呼び出しは、Abstract Controllerからのもので、同じオプションをサポートしています。
* メーラーユニットテストは、機能テストに移動されました。
* Action Mailerは、すべてのヘッダーフィールドと本文の自動エンコードをMail Gemに委任します。
* Action Mailerは、メールの本文とヘッダーを自動的にエンコードします。

非推奨:

* `:charset`、`:content_type`、`:mime_version`、`:implicit_parts_order`は、`ActionMailer.default :key => value`スタイルの宣言に置き換えるため、非推奨です。
* メーラーの動的な`create_method_name`と`deliver_method_name`は非推奨です。単に`method_name`を呼び出し、`Mail::Message`オブジェクトが返されるようになりました。
* `ActionMailer.deliver(message)`は非推奨です。単に`message.deliver`を呼び出してください。
* `template_root`は非推奨です。`mail`生成ブロック内の`format.mime_type`メソッド内のレンダーコールにオプションを渡してください。
* インスタンス変数を定義するための`body`メソッドは非推奨です（`body {:ivar => value}`）。直接メソッド内でインスタンス変数を宣言し、ビューで使用できるようにします。
* `app/models`にメーラーがあることは非推奨です。代わりに`app/mailers`を使用してください。

詳細は以下を参照してください。

* [Rails 3での新しいAction Mailer API](http://lindsaar.net/2010/1/26/new-actionmailer-api-in-rails-3)
* [Rubyの新しいMail Gem](http://lindsaar.net/2010/1/23/mail-gem-version-2-released)

クレジット
-------

Rails 3.0リリースノートは、[Mikel Lindsaar](http://lindsaar.net)によって編集されました。Railsに多くの時間を費やした多くの人々に感謝します。Railsの[全貢献者のリスト](https://contributors.rubyonrails.org/)をご覧ください。
