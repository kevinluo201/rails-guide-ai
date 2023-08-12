**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: b21dbc892c0a841f1bc1fafdf5ee0126
Ruby on Rails 4.0 リリースノート
===============================

Rails 4.0 のハイライト:

* Ruby 2.0 が推奨されます。1.9.3+ が必要です。
* Strong Parameters
* Turbolinks
* Russian Doll Caching

これらのリリースノートでは、主要な変更のみをカバーしています。さまざまなバグ修正や変更については、changelog を参照するか、GitHub 上のメインの Rails リポジトリの [コミットのリスト](https://github.com/rails/rails/commits/4-0-stable) をチェックしてください。

--------------------------------------------------------------------------------

Rails 4.0 へのアップグレード
----------------------

既存のアプリケーションをアップグレードする場合は、アップグレードする前に十分なテストカバレッジを持っていることが重要です。また、Rails 4.0 への更新を試みる前に、まず Rails 3.2 にアップグレードし、アプリケーションが予想どおりに動作することを確認してください。アップグレード時に注意するべき事項のリストは、[Upgrading Ruby on Rails](upgrading_ruby_on_rails.html#upgrading-from-rails-3-2-to-rails-4-0) ガイドで入手できます。


Rails 4.0 アプリケーションの作成
--------------------------------

```bash
# 'rails' RubyGem がインストールされている必要があります
$ rails new myapp
$ cd myapp
```

### Gems のベンダリング

Rails は、アプリケーションのルートにある `Gemfile` を使用して、アプリケーションの起動に必要な gem を決定します。この `Gemfile` は、[Bundler](https://github.com/carlhuda/bundler) gem によって処理され、すべての依存関係がインストールされます。さらに、アプリケーションに依存関係がシステムの gem に依存しないように、すべての依存関係をローカルにインストールすることもできます。

詳細はこちら: [Bundler ホームページ](https://bundler.io)

### 最新版を使用する

`Bundler` と `Gemfile` を使用すると、新しい専用の `bundle` コマンドを使用して、Rails アプリケーションを簡単にフリーズすることができます。Git リポジトリから直接バンドルする場合は、`--edge` フラグを渡すことができます。

```bash
$ rails new myapp --edge
```

Rails リポジトリのローカルチェックアウトがあり、それを使用してアプリケーションを生成したい場合は、`--dev` フラグを渡すことができます。

```bash
$ ruby /path/to/rails/railties/bin/rails new myapp --dev
```

主要な機能
--------------

[![Rails 4.0](images/4_0_release_notes/rails4_features.png)](https://guides.rubyonrails.org/images/4_0_release_notes/rails4_features.png)

### アップグレード

* **Ruby 1.9.3** ([commit](https://github.com/rails/rails/commit/a0380e808d3dbd2462df17f5d3b7fcd8bd812496)) - Ruby 2.0 が推奨されます。1.9.3+ が必要です。
* **[新しい非推奨ポリシー](https://www.youtube.com/watch?v=z6YgD6tVPQs)** - Rails 4.0 では非推奨の機能は警告となり、Rails 4.1 で削除されます。
* **ActionPack ページキャッシュとアクションキャッシュ** ([commit](https://github.com/rails/rails/commit/b0a7068564f0c95e7ef28fc39d0335ed17d93e90)) - ページキャッシュとアクションキャッシュは別の gem に抽出されました。ページキャッシュとアクションキャッシュは手動でキャッシュを削除する必要があります（基になるモデルオブジェクトが更新された場合に手動でキャッシュを削除する必要があります）。代わりに、Russian doll caching を使用してください。
* **ActiveRecord オブザーバー** ([commit](https://github.com/rails/rails/commit/ccecab3ba950a288b61a516bf9b6962e384aae0b)) - オブザーバーは別の gem に抽出されました。オブザーバーはページキャッシュとアクションキャッシュにのみ必要であり、スパゲッティコードにつながる可能性があります。
* **ActiveRecord セッションストア** ([commit](https://github.com/rails/rails/commit/0ffe19056c8e8b2f9ae9d487b896cad2ce9387ad)) - ActiveRecord セッションストアは別の gem に抽出されました。SQL でセッションを保存するのはコストがかかります。代わりに、クッキーセッション、メモリキャッシュセッション、またはカスタムセッションストアを使用してください。
* **ActiveModel の大量代入保護** ([commit](https://github.com/rails/rails/commit/f8c9a4d3e88181cee644f91e1342bfe896ca64c6)) - Rails 3 の大量代入保護は非推奨です。代わりに、strong parameters を使用してください。
* **ActiveResource** ([commit](https://github.com/rails/rails/commit/f1637bf2bb00490203503fbd943b73406e043d1d)) - ActiveResource は別の gem に抽出されました。ActiveResource は広く使用されていませんでした。
* **vendor/plugins の削除** ([commit](https://github.com/rails/rails/commit/853de2bd9ac572735fa6cf59fcf827e485a231c3)) - インストールされた gem を管理するために `Gemfile` を使用してください。
### ActionPack

* **Strong parameters** ([commit](https://github.com/rails/rails/commit/a8f6d5c6450a7fe058348a7f10a908352bb6c7fc)) - パラメータを許可されたものだけでモデルオブジェクトを更新する（`params.permit(:title, :text)`）。
* **Routing concerns** ([commit](https://github.com/rails/rails/commit/0dd24728a088fcb4ae616bb5d62734aca5276b1b)) - ルーティングDSLで共通のサブルートを抽出する（`/posts/1/comments`と`/videos/1/comments`から`comments`を抽出）。
* **ActionController::Live** ([commit](https://github.com/rails/rails/commit/af0a9f9eefaee3a8120cfd8d05cbc431af376da3)) - `response.stream`を使用してJSONをストリームで送信する。
* **Declarative ETags** ([commit](https://github.com/rails/rails/commit/ed5c938fa36995f06d4917d9543ba78ed506bb8d)) - アクションのETag計算の一部となるコントローラレベルのETag追加を追加する。
* **[Russian doll caching](https://37signals.com/svn/posts/3113-how-key-based-cache-expiration-works)** ([commit](https://github.com/rails/rails/commit/4154bf012d2bec2aae79e4a49aa94a70d3e91d49)) - ビューのネストされたフラグメントをキャッシュする。各フラグメントは依存関係（キャッシュキー）に基づいて期限が切れる。キャッシュキーは通常、テンプレートのバージョン番号とモデルオブジェクトです。
* **Turbolinks** ([commit](https://github.com/rails/rails/commit/e35d8b18d0649c0ecc58f6b73df6b3c8d0c6bb74)) - 初期のHTMLページのみを提供する。ユーザーが別のページに移動すると、pushStateを使用してURLを更新し、AJAXを使用してタイトルと本文を更新します。
* **Decouple ActionView from ActionController** ([commit](https://github.com/rails/rails/commit/78b0934dd1bb84e8f093fb8ef95ca99b297b51cd)) - ActionViewはActionPackから切り離され、Rails 4.1では別のgemに移動します。
* **Do not depend on ActiveModel** ([commit](https://github.com/rails/rails/commit/166dbaa7526a96fdf046f093f25b0a134b277a68)) - ActionPackはもはやActiveModelに依存しません。

### General

 * **ActiveModel::Model** ([commit](https://github.com/rails/rails/commit/3b822e91d1a6c4eab0064989bbd07aae3a6d0d08)) - `ActiveModel::Model`は、通常のRubyオブジェクトをActionPackと連携させるためのミックスインです（例：`form_for`のため）。
 * **New scope API** ([commit](https://github.com/rails/rails/commit/50cbc03d18c5984347965a94027879623fc44cce)) - スコープは常に呼び出し可能なものを使用する必要があります。
 * **Schema cache dump** ([commit](https://github.com/rails/rails/commit/5ca4fc95818047108e69e22d200e7a4a22969477)) - Railsの起動時間を改善するために、データベースからスキーマを直接ロードする代わりに、ダンプファイルからスキーマをロードします。
 * **Support for specifying transaction isolation level** ([commit](https://github.com/rails/rails/commit/392eeecc11a291e406db927a18b75f41b2658253)) - 繰り返し可能な読み取りまたはパフォーマンスの向上（ロックの削減）のどちらが重要かを選択します。
 * **Dalli** ([commit](https://github.com/rails/rails/commit/82663306f428a5bbc90c511458432afb26d2f238)) - Dalliメモリキャッシュクライアントをメモリキャッシュストアに使用します。
 * **Notifications start &amp; finish** ([commit](https://github.com/rails/rails/commit/f08f8750a512f741acb004d0cebe210c5f949f28)) - Active Supportのインストルメンテーションは、開始と終了の通知をサブスクライバに報告します。
 * **Thread safe by default** ([commit](https://github.com/rails/rails/commit/5d416b907864d99af55ebaa400fff217e17570cd)) - Railsは追加の設定なしでスレッドセーフなアプリケーションサーバで実行できます。

注意：使用しているgemがスレッドセーフであることを確認してください。

 * **PATCH verb** ([commit](https://github.com/rails/rails/commit/eed9f2539e3ab5a68e798802f464b8e4e95e619e)) - Railsでは、PUTの代わりにPATCHが使用されます。PATCHはリソースの部分的な更新に使用されます。

### Security

* **match do not catch all** ([commit](https://github.com/rails/rails/commit/90d2802b71a6e89aedfe40564a37bd35f777e541)) - ルーティングDSLでは、HTTPの動詞を指定する必要があります。
* **html entities escaped by default** ([commit](https://github.com/rails/rails/commit/5f189f41258b83d49012ec5a0678d827327e7543)) - erbでレンダリングされる文字列は、`raw`でラップされていない限りエスケープされます。
* **New security headers** ([commit](https://github.com/rails/rails/commit/6794e92b204572d75a07bd6413bdae6ae22d5a82)) - Railsは以下のヘッダをすべてのHTTPリクエストで送信します：`X-Frame-Options`（ブラウザがページをフレームに埋め込むことを禁止するためのクリックジャッキング防止）、`X-XSS-Protection`（ブラウザにスクリプトの挿入を停止するように要求）、`X-Content-Type-Options`（ブラウザがjpegをexeとして開かないようにする）。
機能の抽出からジェムへの変更
---------------------------

Rails 4.0では、いくつかの機能がジェムに抽出されました。機能を復元するには、単純に抽出されたジェムを`Gemfile`に追加するだけです。

* ハッシュベースおよびダイナミックな検索メソッド（[GitHub](https://github.com/rails/activerecord-deprecated_finders)）
* Active Recordモデルでのマスアサインメント保護（[GitHub](https://github.com/rails/protected_attributes)、[Pull Request](https://github.com/rails/rails/pull/7251)）
* ActiveRecord::SessionStore（[GitHub](https://github.com/rails/activerecord-session_store)、[Pull Request](https://github.com/rails/rails/pull/7436)）
* Active Record Observers（[GitHub](https://github.com/rails/rails-observers)、[Commit](https://github.com/rails/rails/commit/39e85b3b90c58449164673909a6f1893cba290b2)）
* Active Resource（[GitHub](https://github.com/rails/activeresource)、[Pull Request](https://github.com/rails/rails/pull/572)、[Blog](http://yetimedia-blog-blog.tumblr.com/post/35233051627/activeresource-is-dead-long-live-activeresource)）
* Action Caching（[GitHub](https://github.com/rails/actionpack-action_caching)、[Pull Request](https://github.com/rails/rails/pull/7833)）
* Page Caching（[GitHub](https://github.com/rails/actionpack-page_caching)、[Pull Request](https://github.com/rails/rails/pull/7833)）
* Sprockets（[GitHub](https://github.com/rails/sprockets-rails)）
* パフォーマンステスト（[GitHub](https://github.com/rails/rails-perftest)、[Pull Request](https://github.com/rails/rails/pull/8876)）

ドキュメンテーション
-------------

* ガイドはGitHub Flavored Markdownで書き直されました。

* ガイドはレスポンシブデザインになりました。

Railties
--------

詳細な変更については、[Changelog](https://github.com/rails/rails/blob/4-0-stable/railties/CHANGELOG.md)を参照してください。

### 注目すべき変更

* 新しいテストの場所 `test/models`、`test/helpers`、`test/controllers`、`test/mailers`。対応するrakeタスクも追加されました。 ([Pull Request](https://github.com/rails/rails/pull/7878))

* アプリケーションの実行可能ファイルは、`bin/`ディレクトリにあります。`bin/bundle`、`bin/rails`、`bin/rake`を取得するには、`rake rails:update:bin`を実行してください。

* デフォルトでスレッドセーフ

* `rails new`に`--builder`（または`-b`）を渡すことで、カスタムビルダーを使用する機能が削除されました。代わりにアプリケーションテンプレートを使用してください。 ([Pull Request](https://github.com/rails/rails/pull/9401))

### 廃止予定

* `config.threadsafe!`は、より細かい制御を提供する`config.eager_load`に置き換えられました。

* `Rails::Plugin`は廃止されました。`vendor/plugins`にプラグインを追加する代わりに、パスやgitの依存関係を使用するか、gemsまたはbundlerを使用してください。

Action Mailer
-------------

詳細な変更については、[Changelog](https://github.com/rails/rails/blob/4-0-stable/actionmailer/CHANGELOG.md)を参照してください。

### 注目すべき変更

### 廃止予定

Active Model
------------

詳細な変更については、[Changelog](https://github.com/rails/rails/blob/4-0-stable/activemodel/CHANGELOG.md)を参照してください。

### 注目すべき変更

* `ActiveModel::ForbiddenAttributesProtection`を追加しました。これは、許可されていない属性が渡された場合に属性をマスアサインメントから保護するためのシンプルなモジュールです。

* `ActiveModel::Model`を追加しました。これは、RubyオブジェクトをAction Packとの互換性を持つようにするためのミックスインです。

### 廃止予定

Active Support
--------------

詳細な変更については、[Changelog](https://github.com/rails/rails/blob/4-0-stable/activesupport/CHANGELOG.md)を参照してください。

### 注目すべき変更

* `ActiveSupport::Cache::MemCacheStore`で非推奨の`memcache-client`ジェムを`dalli`で置き換えました。

* `ActiveSupport::Cache::Entry`を最適化してメモリ使用量と処理オーバーヘッドを削減しました。

* インフレクションはロケールごとに定義できるようになりました。`singularize`と`pluralize`は追加の引数としてロケールを受け入れます。

* `Object#try`は、受信オブジェクトがメソッドを実装していない場合にNoMethodErrorを発生させる代わりに、nilを返すようになりました。ただし、新しい`Object#try!`を使用することで、古い動作を維持することもできます。

* `String#to_date`は、無効な日付が与えられた場合に`ArgumentError: invalid date`を発生させるようになりました。これは、`Date.parse`と同じで、3.xよりも多くの無効な日付を受け入れます。
```ruby
# ActiveSupport 3.x
"asdf".to_date # => NoMethodError: undefined method `div' for nil:NilClass
"333".to_date # => NoMethodError: undefined method `div' for nil:NilClass

# ActiveSupport 4
"asdf".to_date # => ArgumentError: invalid date
"333".to_date # => Fri, 29 Nov 2013
```

### 廃止予定

* `ActiveSupport::TestCase#pending` メソッドは廃止予定です。代わりに minitest の `skip` を使用してください。

* `ActiveSupport::Benchmarkable#silence` はスレッドセーフではないため、廃止予定です。Rails 4.1 では代替なしで削除されます。

* `ActiveSupport::JSON::Variable` は廃止予定です。カスタムの JSON 文字列リテラルには、独自の `#as_json` と `#encode_json` メソッドを定義してください。

* 互換性のあるメソッド `Module#local_constant_names` は廃止予定です。代わりに `Module#local_constants` を使用してください（シンボルを返します）。

* `ActiveSupport::BufferedLogger` は廃止予定です。代わりに `ActiveSupport::Logger` または Ruby 標準ライブラリのロガーを使用してください。

* `assert_present` と `assert_blank` は `assert object.blank?` と `assert object.present?` に置き換えるために廃止予定です。

Action Pack
-----------

詳細な変更については、[Changelog](https://github.com/rails/rails/blob/4-0-stable/actionpack/CHANGELOG.md) を参照してください。

### 注目すべき変更点

* 開発モードの例外ページのスタイルシートを変更しました。さらに、例外が発生したコードの行とフラグメントもすべての例外ページに表示されます。

### 廃止予定


Active Record
-------------

詳細な変更については、[Changelog](https://github.com/rails/rails/blob/4-0-stable/activerecord/CHANGELOG.md) を参照してください。

### 注目すべき変更点

* `change` マイグレーションの書き方を改善し、古い `up` と `down` メソッドは不要になりました。

    * `drop_table` メソッドと `remove_column` メソッドは、必要な情報が与えられている限り、逆変換可能になりました。
      `remove_column` メソッドは複数の列名を受け付けていたが、代わりに `remove_columns` を使用してください（逆変換不可）。
      `change_table` メソッドも逆変換可能になりましたが、そのブロックが `remove`、`change`、`change_default` を呼び出さない限りです。

    * `reversible` メソッドを使用すると、マイグレーションを上方向または下方向に実行するときに実行するコードを指定できます。
      [Migration ガイド](https://github.com/rails/rails/blob/main/guides/source/active_record_migrations.md#using-reversible)を参照してください。

    * `revert` メソッドは、マイグレーション全体または指定されたブロックを逆変換します。
      下方向にマイグレーションする場合、指定されたマイグレーション/ブロックは通常通り実行されます。
      [Migration ガイド](https://github.com/rails/rails/blob/main/guides/source/active_record_migrations.md#reverting-previous-migrations)を参照してください。

* PostgreSQL の配列型サポートを追加しました。任意のデータ型を使用して配列列を作成できます。マイグレーションとスキーマダンパーのサポートも完全です。

* `Relation#load` を追加し、レコードを明示的にロードして `self` を返します。

* `Model.all` は今や `ActiveRecord::Relation` を返します。本当に配列が必要な場合は `Relation#to_a` を使用してください。特定のケースでは、アップグレード時に問題が発生する可能性があります。

* `ActiveRecord::Migration.check_pending!` を追加し、マイグレーションが保留中の場合にエラーを発生させるようにしました。

* `ActiveRecord::Store` のカスタムコーダーのサポートを追加しました。次のようにカスタムコーダーを設定できます：

        store :settings, accessors: [ :color, :homepage ], coder: JSON
* `mysql`と`mysql2`の接続は、デフォルトで`SQL_MODE=STRICT_ALL_TABLES`を設定して、データの損失を防ぐためのものです。これは、`database.yml`で`strict: false`を指定することで無効にすることができます。

* IdentityMapを削除します。

* EXPLAINクエリの自動実行を削除します。`active_record.auto_explain_threshold_in_seconds`オプションはもはや使用されず、削除する必要があります。

* `ActiveRecord::NullRelation`と`ActiveRecord::Relation#none`を追加して、Relationクラスにnullオブジェクトパターンを実装します。

* HABTMの結合テーブルを作成するための`create_join_table`マイグレーションヘルパーを追加します。

* PostgreSQLのhstoreレコードの作成を許可します。

### 廃止予定

* 古いスタイルのハッシュベースの検索APIは廃止されました。これは、以前に「検索オプション」を受け入れていたメソッドがもはや受け入れないことを意味します。

* `find_by_...`と`find_by_...!`以外のすべての動的メソッドは廃止予定です。以下にコードの書き換え方法を示します：

      * `find_all_by_...`は`where(...)`を使用して書き換えることができます。
      * `find_last_by_...`は`where(...).last`を使用して書き換えることができます。
      * `scoped_by_...`は`where(...)`を使用して書き換えることができます。
      * `find_or_initialize_by_...`は`find_or_initialize_by(...)`を使用して書き換えることができます。
      * `find_or_create_by_...`は`find_or_create_by(...)`を使用して書き換えることができます。
      * `find_or_create_by_...!`は`find_or_create_by!(...)`を使用して書き換えることができます。

クレジット
-------

Railsを安定かつ堅牢なフレームワークにするために多くの時間を費やした多くの人々に感謝します。[Railsの貢献者の完全なリスト](https://contributors.rubyonrails.org/)を参照してください。彼ら全員に敬意を表します。
