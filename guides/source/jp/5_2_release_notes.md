**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: c7252bf18650c5a9a85fc144305c4615
Ruby on Rails 5.2 リリースノート
===============================

Rails 5.2 のハイライト：

* Active Storage
* Redis Cache Store
* HTTP/2 Early Hints
* Credentials
* Content Security Policy

これらのリリースノートは主要な変更のみをカバーしています。さまざまなバグ修正や変更については、変更ログを参照するか、GitHubのRailsリポジトリの[コミットのリスト](https://github.com/rails/rails/commits/5-2-stable)を確認してください。

--------------------------------------------------------------------------------

Rails 5.2 へのアップグレード
----------------------

既存のアプリケーションをアップグレードする場合は、アップグレード前に十分なテストカバレッジを持つことが重要です。また、まずRails 5.1にアップグレードし、アプリケーションが正常に動作することを確認してから、Rails 5.2への更新を試みることをお勧めします。アップグレード時に注意すべき点のリストは、[Ruby on Railsのアップグレード](upgrading_ruby_on_rails.html#upgrading-from-rails-5-1-to-rails-5-2)ガイドで利用できます。

主要な機能
--------------

### Active Storage

[プルリクエスト](https://github.com/rails/rails/pull/30020)

[Active Storage](https://github.com/rails/rails/tree/5-2-stable/activestorage)は、Amazon S3、Google Cloud Storage、またはMicrosoft Azure Storageなどのクラウドストレージサービスにファイルをアップロードし、それらのファイルをActive Recordオブジェクトに添付することを容易にします。開発およびテスト用のローカルディスクベースのサービスが付属しており、バックアップやマイグレーションのためにファイルを下位サービスにミラーリングすることもサポートしています。Active Storageについては、[Active Storageの概要](active_storage_overview.html)ガイドを参照してください。

### Redis Cache Store

[プルリクエスト](https://github.com/rails/rails/pull/31134)

Rails 5.2には、組み込みのRedisキャッシュストアが付属しています。これについては、[Railsでのキャッシュ](caching_with_rails.html#activesupport-cache-rediscachestore)ガイドで詳しく説明しています。

### HTTP/2 Early Hints

[プルリクエスト](https://github.com/rails/rails/pull/30744)

Rails 5.2は、[HTTP/2 Early Hints](https://tools.ietf.org/html/rfc8297)をサポートしています。Early Hintsを有効にしてサーバーを起動するには、`bin/rails server`に`--early-hints`を渡します。

### Credentials

[プルリクエスト](https://github.com/rails/rails/pull/30067)

`config/credentials.yml.enc`ファイルが追加され、本番アプリケーションの秘密情報を保存することができるようになりました。これにより、`config/master.key`ファイルまたは`RAILS_MASTER_KEY`環境変数で暗号化されたリポジトリに対して、サードパーティのサービスの認証情報を直接保存することができます。これは、Rails 5.1で導入された`Rails.application.secrets`と暗号化されたシークレットを最終的に置き換えるものです。さらに、Rails 5.2では、[Credentialsの基礎となるAPIを公開](https://github.com/rails/rails/pull/30940)しているため、他の暗号化された設定、キー、ファイルを簡単に扱うことができます。これについては、[Railsアプリケーションのセキュリティ](security.html#custom-credentials)ガイドで詳しく説明しています。

### Content Security Policy

[プルリクエスト](https://github.com/rails/rails/pull/31162)

Rails 5.2には、アプリケーションの[Content Security Policy](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Content-Security-Policy)を設定するための新しいDSLが付属しています。グローバルなデフォルトポリシーを設定し、リソースごとにオーバーライドすることができ、マルチテナントアプリケーションのアカウントサブドメインなど、パーリクエストの値をヘッダーに注入するためにラムダを使用することもできます。これについては、[Railsアプリケーションのセキュリティ](security.html#content-security-policy)ガイドで詳しく説明しています。
Railties
--------

詳細な変更については、[Changelog][railties]を参照してください。

### 廃止予定

*   ジェネレータとテンプレートの`capify!`メソッドを廃止します。
    ([Pull Request](https://github.com/rails/rails/pull/29493))

*   `rails dbconsole`および`rails console`コマンドに環境名を通常の引数として渡すことは廃止されました。
    代わりに`-e`オプションを使用する必要があります。
    ([Commit](https://github.com/rails/rails/commit/48b249927375465a7102acc71c2dfb8d49af8309))

*   `Rails::Application`のサブクラスを使用してRailsサーバーを起動することは廃止されました。
    ([Pull Request](https://github.com/rails/rails/pull/30127))

*   Railsプラグインテンプレートの`after_bundle`コールバックを廃止します。
    ([Pull Request](https://github.com/rails/rails/pull/29446))

### 注目すべき変更

*   すべての環境で読み込まれる`config/database.yml`に共有セクションを追加しました。
    ([Pull Request](https://github.com/rails/rails/pull/28896))

*   プラグインジェネレータに`railtie.rb`を追加しました。
    ([Pull Request](https://github.com/rails/rails/pull/29576))

*   `tmp:clear`タスクでスクリーンショットファイルをクリアします。
    ([Pull Request](https://github.com/rails/rails/pull/29534))

*   `bin/rails app:update`を実行する際に未使用のコンポーネントをスキップします。
    初期のアプリケーション生成時にAction Cable、Active Recordなどをスキップした場合、アップデートタスクもそれらのスキップを尊重します。
    ([Pull Request](https://github.com/rails/rails/pull/29645))

*   3レベルのデータベース構成を使用している場合、`rails dbconsole`コマンドにカスタム接続名を渡すことができるようになりました。
    例：`bin/rails dbconsole -c replica`。
    ([Commit](https://github.com/rails/rails/commit/1acd9a6464668d4d54ab30d016829f60b70dbbeb))

*   `console`および`dbconsole`コマンドを実行する際に、環境名のショートカットを適切に展開します。
    ([Commit](https://github.com/rails/rails/commit/3777701f1380f3814bd5313b225586dec64d4104))

*   デフォルトの`Gemfile`に`bootsnap`を追加しました。
    ([Pull Request](https://github.com/rails/rails/pull/29313))

*   `rails runner`でスクリプトを標準入力から実行するためのプラットフォームに依存しない方法として`-`をサポートします。
    ([Pull Request](https://github.com/rails/rails/pull/26343))

*   新しいRailsアプリケーションが作成される際に、`Gemfile`に`ruby x.x.x`バージョンを追加し、現在のRubyバージョンを含む`.ruby-version`ルートファイルを作成します。
    ([Pull Request](https://github.com/rails/rails/pull/30016))

*   プラグインジェネレータに`--skip-action-cable`オプションを追加しました。
    ([Pull Request](https://github.com/rails/rails/pull/30164))

*   プラグインジェネレータの`Gemfile`に`git_source`を追加しました。
    ([Pull Request](https://github.com/rails/rails/pull/30110))

*   Railsプラグインで`bin/rails`を実行する際に未使用のコンポーネントをスキップします。
    ([Commit](https://github.com/rails/rails/commit/62499cb6e088c3bc32a9396322c7473a17a28640))

*   ジェネレータアクションのインデントを最適化しました。
    ([Pull Request](https://github.com/rails/rails/pull/30166))

*   ルートのインデントを最適化しました。
    ([Pull Request](https://github.com/rails/rails/pull/30241))

*   プラグインジェネレータに`--skip-yarn`オプションを追加しました。
    ([Pull Request](https://github.com/rails/rails/pull/30238))

*   ジェネレータの`gem`メソッドに複数のバージョン引数をサポートします。
    ([Pull Request](https://github.com/rails/rails/pull/30323))

*   開発およびテスト環境でアプリケーション名から`secret_key_base`を派生させます。
    ([Pull Request](https://github.com/rails/rails/pull/30067))

*   デフォルトの`Gemfile`に`mini_magick`をコメントとして追加しました。
    ([Pull Request](https://github.com/rails/rails/pull/30633))

*   `rails new`および`rails plugin new`はデフォルトで`Active Storage`を取得します。
    `--skip-active-storage`を使用して`Active Storage`をスキップする機能を追加し、`--skip-active-record`が使用された場合には自動的にスキップします。
    ([Pull Request](https://github.com/rails/rails/pull/30101))

Action Cable
------------

詳細な変更については、[Changelog][action-cable]を参照してください。

### 削除

*   廃止予定のイベント駆動型Redisアダプタを削除しました。
    ([Commit](https://github.com/rails/rails/commit/48766e32d31651606b9f68a16015ad05c3b0de2c))

### 注目すべき変更

*   cable.ymlで`host`、`port`、`db`、`password`オプションをサポートしました。
    ([Pull Request](https://github.com/rails/rails/pull/29528))

*   PostgreSQLアダプタを使用する場合に、長いストリーム識別子をハッシュ化します。
    ([Pull Request](https://github.com/rails/rails/pull/29297))

Action Pack
-----------

詳細な変更については、[Changelog][action-pack]を参照してください。

[railties]: https://github.com/rails/rails/blob/master/railties/CHANGELOG.md
[action-cable]: https://github.com/rails/rails/blob/master/actioncable/CHANGELOG.md
[action-pack]: https://github.com/rails/rails/blob/master/actionpack/CHANGELOG.md
### 削除

*   廃止された `ActionController::ParamsParser::ParseError` を削除しました。
    ([Commit](https://github.com/rails/rails/commit/e16c765ac6dcff068ff2e5554d69ff345c003de1))

### 廃止予定

*   `ActionDispatch::TestResponse` の `#success?`、`#missing?`、`#error?` のエイリアスを廃止予定としました。
    ([Pull Request](https://github.com/rails/rails/pull/30104))

### 注目すべき変更

*   フラグメントキャッシュに再利用可能なキャッシュキーのサポートを追加しました。
    ([Pull Request](https://github.com/rails/rails/pull/29092))

*   フラグメントのキャッシュキーの形式を変更し、キーの変更をデバッグしやすくしました。
    ([Pull Request](https://github.com/rails/rails/pull/29092))

*   GCM を使用した AEAD 暗号化されたクッキーとセッションを追加しました。
    ([Pull Request](https://github.com/rails/rails/pull/28132))

*   デフォルトで CSRF 保護を有効にしました。
    ([Pull Request](https://github.com/rails/rails/pull/29742))

*   サーバーサイドで署名/暗号化されたクッキーの有効期限を強制します。
    ([Pull Request](https://github.com/rails/rails/pull/30121))

*   クッキーの `:expires` オプションが `ActiveSupport::Duration` オブジェクトをサポートするようになりました。
    ([Pull Request](https://github.com/rails/rails/pull/30121))

*   Capybara の登録済み `:puma` サーバー設定を使用するようにしました。
    ([Pull Request](https://github.com/rails/rails/pull/30638))

*   キーローテーションのサポートを持つクッキーミドルウェアを簡素化しました。
    ([Pull Request](https://github.com/rails/rails/pull/29716))

*   HTTP/2 の Early Hints を有効にする機能を追加しました。
    ([Pull Request](https://github.com/rails/rails/pull/30744))

*   システムテストにヘッドレスChromeのサポートを追加しました。
    ([Pull Request](https://github.com/rails/rails/pull/30876))

*   `redirect_back` メソッドに `:allow_other_host` オプションを追加しました。
    ([Pull Request](https://github.com/rails/rails/pull/30850))

*   `assert_recognizes` がマウントされたエンジンをトラバースするようにしました。
    ([Pull Request](https://github.com/rails/rails/pull/22435))

*   Content-Security-Policy ヘッダーを設定するための DSL を追加しました。
    ([Pull Request](https://github.com/rails/rails/pull/31162),
    [Commit](https://github.com/rails/rails/commit/619b1b6353a65e1635d10b8f8c6630723a5a6f1a),
    [Commit](https://github.com/rails/rails/commit/4ec8bf68ff92f35e79232fbd605012ce1f4e1e6e))

*   モダンなブラウザでサポートされている最も人気のあるオーディオ/ビデオ/フォント MIME タイプを登録しました。
    ([Pull Request](https://github.com/rails/rails/pull/31251))

*   システムテストのスクリーンショット出力のデフォルトを `inline` から `simple` に変更しました。
    ([Commit](https://github.com/rails/rails/commit/9d6e288ee96d6241f864dbf90211c37b14a57632))

*   システムテストにヘッドレスFirefoxのサポートを追加しました。
    ([Pull Request](https://github.com/rails/rails/pull/31365))

*   デフォルトのヘッダーセットにセキュアな `X-Download-Options` と `X-Permitted-Cross-Domain-Policies` を追加しました。
    ([Commit](https://github.com/rails/rails/commit/5d7b70f4336d42eabfc403e9f6efceb88b3eff44))

*   システムテストを、ユーザーが別のサーバーを手動で指定しない限り、デフォルトのサーバーとして Puma を設定するように変更しました。
    ([Pull Request](https://github.com/rails/rails/pull/31384))

*   デフォルトのヘッダーセットに `Referrer-Policy` ヘッダーを追加しました。
    ([Commit](https://github.com/rails/rails/commit/428939be9f954d39b0c41bc53d85d0d106b9d1a1))

*   `ActionController::Parameters#each` の `Hash#each` の動作に一致するようにしました。
    ([Pull Request](https://github.com/rails/rails/pull/27790))

*   Rails UJS の自動ノンス生成のサポートを追加しました。
    ([Commit](https://github.com/rails/rails/commit/b2f0a8945956cd92dec71ec4e44715d764990a49))

*   HSTS のデフォルトの最大有効期間を 31536000 秒（1年）に更新し、https://hstspreload.org/ の最小 max-age 要件を満たすようにしました。
    ([Commit](https://github.com/rails/rails/commit/30b5f469a1d30c60d1fb0605e84c50568ff7ed37))

*   `cookies` の `to_h` に `to_hash` のエイリアスメソッドを追加しました。
    `session` の `to_hash` に `to_h` のエイリアスメソッドを追加しました。
    ([Commit](https://github.com/rails/rails/commit/50a62499e41dfffc2903d468e8b47acebaf9b500))

Action View
-----------

詳細な変更については、[Changelog][action-view] を参照してください。

### 削除

*   廃止された Erubis ERB ハンドラーを削除しました。
    ([Commit](https://github.com/rails/rails/commit/7de7f12fd140a60134defe7dc55b5a20b2372d06))

### 廃止予定

*   `image_tag` で生成される画像にデフォルトの alt テキストを追加するために使用されていた `image_alt` ヘルパーを廃止予定としました。
    ([Pull Request](https://github.com/rails/rails/pull/30213))

### 注目すべき変更

*   [JSON Feeds](https://jsonfeed.org/version/1) をサポートするために、`auto_discovery_link_tag` に `:json` タイプを追加しました。
    ([Pull Request](https://github.com/rails/rails/pull/29158))

*   `image_tag` ヘルパーに `srcset` オプションを追加しました。
    ([Pull Request](https://github.com/rails/rails/pull/29349))

*   `field_error_proc` が `optgroup` とセレクトディバイダー `option` をラップする問題を修正しました。
    ([Pull Request](https://github.com/rails/rails/pull/31088))

*   `form_with` がデフォルトで ID を生成するように変更しました。
    ([Commit](https://github.com/rails/rails/commit/260d6f112a0ffdbe03e6f5051504cb441c1e94cd))

*   `preload_link_tag` ヘルパーを追加しました。
    ([Pull Request](https://github.com/rails/rails/pull/31251))

*   グループ化されたセレクトでグループメソッドとして呼び出し可能なオブジェクトの使用を許可しました。
    ([Pull Request](https://github.com/rails/rails/pull/31578))

[action-view]: https://github.com/rails/rails/blob/master/actionview/CHANGELOG.md
Action Mailer
-------------

詳細な変更については、[Changelog][action-mailer]を参照してください。

### 注目すべき変更点

*   Action Mailerクラスが配信ジョブを設定できるようになりました。
    ([Pull Request](https://github.com/rails/rails/pull/29457))

*   `assert_enqueued_email_with`テストヘルパーを追加しました。
    ([Pull Request](https://github.com/rails/rails/pull/30695))

Active Record
-------------

詳細な変更については、[Changelog][active-record]を参照してください。

### 削除されたもの

*   廃止された`#migration_keys`を削除しました。
    ([Pull Request](https://github.com/rails/rails/pull/30337))

*   Active Recordオブジェクトの型変換時に`quoted_id`への廃止されたサポートを削除しました。
    ([Commit](https://github.com/rails/rails/commit/82472b3922bda2f337a79cef961b4760d04f9689))

*   `index_name_exists?`から廃止された引数`default`を削除しました。
    ([Commit](https://github.com/rails/rails/commit/8f5b34df81175e30f68879479243fbce966122d7))

*   関連付けにおいて`class_name`にクラスを渡すことへの廃止されたサポートを削除しました。
    ([Commit](https://github.com/rails/rails/commit/e65aff70696be52b46ebe57207ebd8bb2cfcdbb6))

*   `initialize_schema_migrations_table`と`initialize_internal_metadata_table`の廃止されたメソッドを削除しました。
    ([Commit](https://github.com/rails/rails/commit/c9660b5777707658c414b430753029cd9bc39934))

*   `supports_migrations?`の廃止されたメソッドを削除しました。
    ([Commit](https://github.com/rails/rails/commit/9438c144b1893f2a59ec0924afe4d46bd8d5ffdd))

*   `supports_primary_key?`の廃止されたメソッドを削除しました。
    ([Commit](https://github.com/rails/rails/commit/c56ff22fc6e97df4656ddc22909d9bf8b0c2cbb1))

*   `ActiveRecord::Migrator.schema_migrations_table_name`の廃止されたメソッドを削除しました。
    ([Commit](https://github.com/rails/rails/commit/7df6e3f3cbdea9a0460ddbab445c81fbb1cfd012))

*   `#indexes`から廃止された引数`name`を削除しました。
    ([Commit](https://github.com/rails/rails/commit/d6b779ecebe57f6629352c34bfd6c442ac8fba0e))

*   `#verify!`から廃止された引数を削除しました。
    ([Commit](https://github.com/rails/rails/commit/9c6ee1bed0292fc32c23dc1c68951ae64fc510be))

*   `.error_on_ignored_order_or_limit`の廃止された設定を削除しました。
    ([Commit](https://github.com/rails/rails/commit/e1066f450d1a99c9a0b4d786b202e2ca82a4c3b3))

*   `#scope_chain`の廃止されたメソッドを削除しました。
    ([Commit](https://github.com/rails/rails/commit/ef7784752c5c5efbe23f62d2bbcc62d4fd8aacab))

*   `#sanitize_conditions`の廃止されたメソッドを削除しました。
    ([Commit](https://github.com/rails/rails/commit/8f5413b896099f80ef46a97819fe47a820417bc2))

### 廃止予定

*   `supports_statement_cache?`を廃止しました。
    ([Pull Request](https://github.com/rails/rails/pull/28938))

*   `ActiveRecord::Calculations`の`count`と`sum`に引数とブロックを同時に渡すことを廃止しました。
    ([Pull Request](https://github.com/rails/rails/pull/29262))

*   `Relation`で`arel`に委譲することを廃止しました。
    ([Pull Request](https://github.com/rails/rails/pull/29619))

*   `TransactionState`の`set_state`メソッドを廃止しました。
    ([Commit](https://github.com/rails/rails/commit/608ebccf8f6314c945444b400a37c2d07f21b253))

*   置換なしで`expand_hash_conditions_for_aggregates`を廃止しました。
    ([Commit](https://github.com/rails/rails/commit/7ae26885d96daee3809d0bd50b1a440c2f5ffb69))

### 注目すべき変更点

*   引数なしで動的なフィクスチャアクセサメソッドを呼び出すと、このタイプのすべてのフィクスチャが返されるようになりました。以前はこのメソッドは常に空の配列を返していました。
    ([Pull Request](https://github.com/rails/rails/pull/28692))

*   Active Record属性リーダーをオーバーライドする際の変更された属性の不一致を修正しました。
    ([Pull Request](https://github.com/rails/rails/pull/28661))

*   MySQLの降順インデックスをサポートしました。
    ([Pull Request](https://github.com/rails/rails/pull/28773))

*   `bin/rails db:forward`の最初のマイグレーションを修正しました。
    ([Commit](https://github.com/rails/rails/commit/b77d2aa0c336492ba33cbfade4964ba0eda3ef84))

*   現在のマイグレーションが存在しない場合にマイグレーションの移動で`UnknownMigrationVersionError`エラーを発生させるようにしました。
    ([Commit](https://github.com/rails/rails/commit/bb9d6eb094f29bb94ef1f26aa44f145f17b973fe))

*   データベース構造のダンプにおいて、rakeタスクで`SchemaDumper.ignore_tables`を尊重するようにしました。
    ([Pull Request](https://github.com/rails/rails/pull/29077))

*   `ActiveRecord::Base#cache_version`を追加して、新しいバージョン付きエントリを介して再利用可能なキャッシュキーをサポートします。これにより、`ActiveRecord::Base#cache_key`はタイムスタンプを含まない安定したキーを返すようになりました。
    ([Pull Request](https://github.com/rails/rails/pull/29092))

*   キャストされた値がnilの場合にバインドパラメータを作成しないように修正しました。
    ([Pull Request](https://github.com/rails/rails/pull/29282))

*   パフォーマンスの向上のために、フィクスチャを挿入する際にバルクINSERTを使用します。
    ([Pull Request](https://github.com/rails/rails/pull/29504))

*   ネストされた結合を表す2つの関係をマージすると、マージされた関係の結合がLEFT OUTER JOINに変換されなくなりました。
    ([Pull Request](https://github.com/rails/rails/pull/27063))

*   トランザクションを子トランザクションに状態を適用するように修正しました。以前は、ネストされたトランザクションがあり、外側のトランザクションがロールバックされた場合、内側のトランザクションのレコードはまだ永続化されたままでした。これは、親トランザクションの状態を子トランザクションに適用することで修正されました。これにより、内側のトランザクションのレコードが正しく永続化されないようになります。
    ([Commit](https://github.com/rails/rails/commit/0237da287eb4c507d10a0c6d94150093acc52b03))
* スコープに結合を含めた場合のイーガーローディング/プリローディングの関連修正
    ([プルリクエスト](https://github.com/rails/rails/pull/29413))

* `sql.active_record` 通知のサブスクライバーによって発生したエラーを `ActiveRecord::StatementInvalid` 例外に変換しないように修正
    ([プルリクエスト](https://github.com/rails/rails/pull/29692))

* レコードのバッチ処理 (`find_each`, `find_in_batches`, `in_batches`) の場合、クエリキャッシュをスキップするように修正
    ([コミット](https://github.com/rails/rails/commit/b83852e6eed5789b23b13bac40228e87e8822b4d))

* sqlite3 のブール値のシリアライズを 1 と 0 を使用するように変更
    SQLite はネイティブで 1 と 0 を真偽値として認識しますが、以前は 't' と 'f' を認識していませんでした。
    ([プルリクエスト](https://github.com/rails/rails/pull/29699))

* マルチパラメータ割り当てを使用して構築された値は、シングルフィールドのフォーム入力でレンダリングする際に、ポストタイプキャスト値を使用するように変更されました。
    ([コミット](https://github.com/rails/rails/commit/1519e976b224871c7f7dd476351930d5d0d7faf6))

* モデルを生成する際に `ApplicationRecord` はもはや生成されません。生成する必要がある場合は、`rails g application_record` で作成できます。
    ([プルリクエスト](https://github.com/rails/rails/pull/29916))

* `Relation#or` は、`references` の値が異なる2つの関連を受け入れるようになりました。`references` は `where` によって暗黙的に呼び出される可能性があるためです。
    ([コミット](https://github.com/rails/rails/commit/ea6139101ccaf8be03b536b1293a9f36bc12f2f7))

* `Relation#or` を使用する場合、共通の条件を抽出し、OR 条件の前に配置するように変更しました。
    ([プルリクエスト](https://github.com/rails/rails/pull/29950))

* `binary` フィクスチャヘルパーメソッドを追加
    ([プルリクエスト](https://github.com/rails/rails/pull/30073))

* STI の逆関連を自動的に推測するように変更
    ([プルリクエスト](https://github.com/rails/rails/pull/23425))

* ロック待ちタイムアウトが超過した場合に発生する `LockWaitTimeout` 新しいエラークラスを追加
    ([プルリクエスト](https://github.com/rails/rails/pull/30360))

* `sql.active_record` インストルメンテーションのペイロード名をより具体的なものに更新
    ([プルリクエスト](https://github.com/rails/rails/pull/30619))

* データベースからインデックスを削除する際に指定されたアルゴリズムを使用するように変更
    ([プルリクエスト](https://github.com/rails/rails/pull/24199))

* `Relation#where` に `Set` を渡すと、配列を渡すのと同じように動作するように修正
    ([コミット](https://github.com/rails/rails/commit/9cf7e3494f5bd34f1382c1ff4ea3d811a4972ae2))

* PostgreSQL の `tsrange` はサブセカンドの精度を保持するように変更
    ([プルリクエスト](https://github.com/rails/rails/pull/30725))

* ダーティレコードで `lock!` を呼び出すとエラーが発生するように修正
    ([コミット](https://github.com/rails/rails/commit/63cf15877bae859ff7b4ebaf05186f3ca79c1863))

* SQLite アダプタを使用している場合、インデックスの列順序が `db/schema.rb` に書き込まれないバグを修正
    ([プルリクエスト](https://github.com/rails/rails/pull/30970))

* 指定された `VERSION` で `bin/rails db:migrate` を修正します。空の `VERSION` で `bin/rails db:migrate` を実行すると、`VERSION` なしと同じように動作します。`VERSION` の形式をチェックします。マイグレーションバージョン番号またはマイグレーションファイルの名前を許可します。フォーマットが無効な場合はエラーを発生させます。対象のマイグレーションが存在しない場合はエラーを発生させます。
    ([プルリクエスト](https://github.com/rails/rails/pull/30714))

* ステートメントタイムアウトが超過した場合に発生する `StatementTimeout` 新しいエラークラスを追加
    ([プルリクエスト](https://github.com/rails/rails/pull/31129))

* `update_all` は、値を `Type#cast` に渡す前に `Type#serialize` に渡すようになりました。これにより、`update_all(foo: 'true')` は正しくブール値を永続化します。
    ([コミット](https://github.com/rails/rails/commit/68fe6b08ee72cc47263e0d2c9ff07f75c4b42761))

* リレーションクエリメソッドで使用する場合、生の SQL フラグメントは明示的にマークする必要があります。
    ([コミット](https://github.com/rails/rails/commit/a1ee43d2170dd6adf5a9f390df2b1dde45018a48),
    [コミット](https://github.com/rails/rails/commit/e4a921a75f8702a7dbaf41e31130fe884dea93f9))

* データベースマイグレーションに `#up_only` を追加し、アップ時にのみ関連するコード（新しいカラムのポピュレートなど）を実行できるようにしました。
    ([プルリクエスト](https://github.com/rails/rails/pull/31082))
* ユーザーリクエストによるステートメントのキャンセル時に発生するエラークラス `QueryCanceled` を追加します。
    ([プルリクエスト](https://github.com/rails/rails/pull/31235))

* `Relation` のインスタンスメソッドと競合するスコープの定義を許可しません。
    ([プルリクエスト](https://github.com/rails/rails/pull/31179))

* `add_index` に PostgreSQL オペレータクラスのサポートを追加します。
    ([プルリクエスト](https://github.com/rails/rails/pull/19090))

* データベースクエリの呼び出し元をログに記録します。
    ([プルリクエスト](https://github.com/rails/rails/pull/26815),
    [プルリクエスト](https://github.com/rails/rails/pull/31519),
    [プルリクエスト](https://github.com/rails/rails/pull/31690))

* カラム情報をリセットする際に、子孫の属性メソッドを未定義にします。
    ([プルリクエスト](https://github.com/rails/rails/pull/31475))

* `limit` や `offset` を使用した `delete_all` のためのサブセレクトを使用します。
    ([コミット](https://github.com/rails/rails/commit/9e7260da1bdc0770cf4ac547120c85ab93ff3d48))

* `limit()` と一緒に使用した場合の `first(n)` の不整合を修正します。
    `first(n)` ファインダーは `limit()` を尊重するようになり、`relation.to_a.first(n)` の動作とも一貫し、`last(n)` の振る舞いとも一致します。
    ([プルリクエスト](https://github.com/rails/rails/pull/27597))

* 未保存の親インスタンスでのネストした `has_many :through` 関連を修正します。
    ([コミット](https://github.com/rails/rails/commit/027f865fc8b262d9ba3ee51da3483e94a5489b66))

* 削除されるレコードを通じて削除する際に関連の条件を考慮します。
    ([コミット](https://github.com/rails/rails/commit/ae48c65e411e01c1045056562319666384bb1b63))

* `save` または `save!` の呼び出し後に破壊されたオブジェクトの変更を許可しません。
    ([コミット](https://github.com/rails/rails/commit/562dd0494a90d9d47849f052e8913f0050f3e494))

* `left_outer_joins` による関連マージャーの問題を修正します。
    ([プルリクエスト](https://github.com/rails/rails/pull/27860))

* PostgreSQL 外部テーブルのサポートを追加します。
    ([プルリクエスト](https://github.com/rails/rails/pull/31549))

* Active Record オブジェクトが複製される際にトランザクションの状態をクリアします。
    ([プルリクエスト](https://github.com/rails/rails/pull/31751))

* `composed_of` カラムを使用して where メソッドに Array オブジェクトを引数として渡す際の展開の問題を修正します。
    ([プルリクエスト](https://github.com/rails/rails/pull/31724))

* `reflection.klass` が `polymorphic?` でない場合に例外を発生させ、誤用を防止します。
    ([コミット](https://github.com/rails/rails/commit/63fc1100ce054e3e11c04a547cdb9387cd79571a))

* MySQL と PostgreSQL の `#columns_for_distinct` を修正し、`ActiveRecord::FinderMethods#limited_ids_for` が正しい主キー値を使用するようにします。
    `ORDER BY` の列に他のテーブルの主キーが含まれていても、正しい主キー値を使用します。
    ([コミット](https://github.com/rails/rails/commit/851618c15750979a75635530200665b543561a44))

* `dependent: :destroy` の問題を修正し、子が削除されない場合に親クラスが削除される問題を修正します。
    ([コミット](https://github.com/rails/rails/commit/b0fc04aa3af338d5a90608bf37248668d59fc881))

* アイドル状態のデータベース接続（以前は孤立した接続のみ）は、接続プールリーパーによって定期的に削除されるようになりました。
    ([コミット](https://github.com/rails/rails/pull/31221/commits/9027fafff6da932e6e64ddb828665f4b01fc8902))

Active Model
------------

詳細な変更については、[Changelog][active-model] を参照してください。

### 注目すべき変更点

* `ActiveModel::Errors` のメソッド `#keys`、`#values` を修正します。
    `#keys` を空のメッセージを持たないキーのみを返すように変更します。
    `#values` を空でない値のみを返すように変更します。
    ([プルリクエスト](https://github.com/rails/rails/pull/28584))

* `ActiveModel::Errors` にメソッド `#merge!` を追加します。
    ([プルリクエスト](https://github.com/rails/rails/pull/29714))

* 長さバリデータのオプションに Proc またはシンボルを渡すことを許可します。
    ([プルリクエスト](https://github.com/rails/rails/pull/30674))

* `_confirmation` の値が `false` の場合に `ConfirmationValidator` のバリデーションを実行します。
    ([プルリクエスト](https://github.com/rails/rails/pull/31058))

* プロックのデフォルト値を持つ属性 API を使用するモデルをマーシャリングできるようにします。
    ([コミット](https://github.com/rails/rails/commit/0af36c62a5710e023402e37b019ad9982e69de4b))

* シリアライズ時にオプションを持つ複数の `:includes` をすべて失わないようにします。
    ([コミット](https://github.com/rails/rails/commit/853054bcc7a043eea78c97e7705a46abb603cc44))

Active Support
--------------

詳細な変更については、[Changelog][active-support] を参照してください。

### 削除されたもの

* コールバックのための非推奨の `:if` と `:unless` の文字列フィルタを削除します。
    ([コミット](https://github.com/rails/rails/commit/c792354adcbf8c966f274915c605c6713b840548))

* 非推奨の `halt_callback_chains_on_return_false` オプションを削除します。
    ([コミット](https://github.com/rails/rails/commit/19fbbebb1665e482d76cae30166b46e74ceafe29))

[active-model]: https://github.com/rails/rails/blob/master/activemodel/CHANGELOG.md
[active-support]: https://github.com/rails/rails/blob/master/activesupport/CHANGELOG.md
### 廃止

*   `Module#reachable?` メソッドを廃止します。
    ([プルリクエスト](https://github.com/rails/rails/pull/30624))

*   `secrets.secret_token` を廃止します。
    ([コミット](https://github.com/rails/rails/commit/fbcc4bfe9a211e219da5d0bb01d894fcdaef0a0e))

### 注目すべき変更点

*   `HashWithIndifferentAccess` に `fetch_values` を追加します。
    ([プルリクエスト](https://github.com/rails/rails/pull/28316))

*   `Time#change` に `:offset` のサポートを追加します。
    ([コミット](https://github.com/rails/rails/commit/851b7f866e13518d900407c78dcd6eb477afad06))

*   `ActiveSupport::TimeWithZone#change` に `:offset` と `:zone` のサポートを追加します。
    ([コミット](https://github.com/rails/rails/commit/851b7f866e13518d900407c78dcd6eb477afad06))

*   廃止通知にジェム名と廃止の時期を渡すようにします。
    ([プルリクエスト](https://github.com/rails/rails/pull/28800))

*   バージョン付きのキャッシュエントリをサポートします。これにより、キャッシュストアはキャッシュキーを再利用し、頻繁な変更がある場合に大幅なストレージの節約が可能になります。Active Record の `#cache_key` と `#cache_version` の分離と、Action Pack のフラグメントキャッシュでの使用と一緒に機能します。
    ([プルリクエスト](https://github.com/rails/rails/pull/29092))

*   スレッドごとに属性を保持するための `ActiveSupport::CurrentAttributes` を追加します。主な使用例は、すべてのリクエストごとの属性をシステム全体で簡単に利用できるようにすることです。
    ([プルリクエスト](https://github.com/rails/rails/pull/29180))

*   指定されたロケールの場合に `#singularize` と `#pluralize` が不可算名詞を考慮するようになりました。
    ([コミット](https://github.com/rails/rails/commit/352865d0f835c24daa9a2e9863dcc9dde9e5371a))

*   `class_attribute` にデフォルトオプションを追加します。
    ([プルリクエスト](https://github.com/rails/rails/pull/29270))

*   `Date#prev_occurring` と `Date#next_occurring` を追加し、指定された前後の曜日を返します。
    ([プルリクエスト](https://github.com/rails/rails/pull/26600))

*   モジュールとクラスの属性アクセサにデフォルトオプションを追加します。
    ([プルリクエスト](https://github.com/rails/rails/pull/29294))

*   キャッシュ: `write_multi` を追加します。
    ([プルリクエスト](https://github.com/rails/rails/pull/29366))

*   デフォルトで `ActiveSupport::MessageEncryptor` が AES 256 GCM 暗号化を使用するようにします。
    ([プルリクエスト](https://github.com/rails/rails/pull/29263))

*   テストで時間を `Time.now` に固定するための `freeze_time` ヘルパーを追加します。
    ([プルリクエスト](https://github.com/rails/rails/pull/29681))

*   `Hash#reverse_merge!` の順序を `HashWithIndifferentAccess` と一貫させます。
    ([プルリクエスト](https://github.com/rails/rails/pull/28077))

*   `ActiveSupport::MessageVerifier` と `ActiveSupport::MessageEncryptor` に目的と有効期限のサポートを追加します。
    ([プルリクエスト](https://github.com/rails/rails/pull/29892))

*   `String#camelize` を更新し、間違ったオプションが渡された場合にフィードバックを提供するようにします。
    ([プルリクエスト](https://github.com/rails/rails/pull/30039))

*   `Module#delegate_missing_to` は、ターゲットが nil の場合に `DelegationError` を発生させるようになりました。これは `Module#delegate` と同様です。
    ([プルリクエスト](https://github.com/rails/rails/pull/30191))

*   `ActiveSupport::EncryptedFile` と `ActiveSupport::EncryptedConfiguration` を追加します。
    ([プルリクエスト](https://github.com/rails/rails/pull/30067))

*   本番アプリの秘密情報を保存するための `config/credentials.yml.enc` を追加します。
    ([プルリクエスト](https://github.com/rails/rails/pull/30067))

*   `MessageEncryptor` と `MessageVerifier` にキーのローテーションサポートを追加します。
    ([プルリクエスト](https://github.com/rails/rails/pull/29716))

*   `HashWithIndifferentAccess#transform_keys` から `HashWithIndifferentAccess` のインスタンスを返します。
    ([プルリクエスト](https://github.com/rails/rails/pull/30728))

*   `Hash#slice` は、定義されている場合は Ruby 2.5+ の組み込み定義にフォールバックします。
    ([コミット](https://github.com/rails/rails/commit/01ae39660243bc5f0a986e20f9c9bff312b1b5f8))

*   `IO#to_json` は、配列に変換しようとせずに `to_s` の表現を返すようになりました。これにより、`IO#to_json` を読み取り不可なオブジェクトで呼び出した場合に `IOError` が発生するバグが修正されます。
    ([プルリクエスト](https://github.com/rails/rails/pull/30953))

*   `Time#prev_day` と `Time#next_day` のメソッドシグネチャを `Date#prev_day` と `Date#next_day` に合わせるために同じメソッドシグネチャを追加します。`Time#prev_day` と `Time#next_day` に引数を渡すことができるようになります。
    ([コミット](https://github.com/rails/rails/commit/61ac2167eff741bffb44aec231f4ea13d004134e))

*   `Time#prev_month` と `Time#next_month` のメソッドシグネチャを `Date#prev_month` と `Date#next_month` に合わせるために同じメソッドシグネチャを追加します。`Time#prev_month` と `Time#next_month` に引数を渡すことができるようになります。
    ([コミット](https://github.com/rails/rails/commit/f2c1e3a793570584d9708aaee387214bc3543530))

*   `Time#prev_year` と `Time#next_year` のメソッドシグネチャを `Date#prev_year` と `Date#next_year` に合わせるために同じメソッドシグネチャを追加します。`Time#prev_year` と `Time#next_year` に引数を渡すことができるようになります。
    ([コミット](https://github.com/rails/rails/commit/ee9d81837b5eba9d5ec869ae7601d7ffce763e3e))
* `humanize`での略語サポートを修正しました。
    ([Commit](https://github.com/rails/rails/commit/0ddde0a8fca6a0ca3158e3329713959acd65605d))

* TWZ範囲での`Range#include?`を許可しました。
    ([Pull Request](https://github.com/rails/rails/pull/31081))

* キャッシュ：1kBを超える値に対してデフォルトで圧縮を有効にしました。
    ([Pull Request](https://github.com/rails/rails/pull/31147))

* Redisキャッシュストア。
    ([Pull Request](https://github.com/rails/rails/pull/31134),
    [Pull Request](https://github.com/rails/rails/pull/31866))

* `TZInfo::AmbiguousTime`エラーを処理するようにしました。
    ([Pull Request](https://github.com/rails/rails/pull/31128))

* MemCacheStore：期限切れのカウンターをサポートします。
    ([Commit](https://github.com/rails/rails/commit/b22ee64b5b30c6d5039c292235e10b24b1057f6d))

* `ActiveSupport::TimeZone.all`が`ActiveSupport::TimeZone::MAPPING`にあるタイムゾーンのみを返すようにしました。
    ([Pull Request](https://github.com/rails/rails/pull/31176))

* `ActiveSupport::SecurityUtils.secure_compare`のデフォルトの動作を変更し、可変長の文字列でも長さ情報を漏洩しないようにしました。
    以前の`ActiveSupport::SecurityUtils.secure_compare`を`fixed_length_secure_compare`に名前を変更し、渡された文字列の長さの不一致の場合には`ArgumentError`を発生させるようにしました。
    ([Pull Request](https://github.com/rails/rails/pull/24510))

* 非機密なダイジェスト（例：ETagヘッダー）を生成するためにSHA-1を使用します。
    ([Pull Request](https://github.com/rails/rails/pull/31289),
    [Pull Request](https://github.com/rails/rails/pull/31651))

* `assert_changes`は、`from:`と`to:`の引数の組み合わせに関係なく、常に式が変化することをアサートします。
    ([Pull Request](https://github.com/rails/rails/pull/31011))

* `ActiveSupport::Cache::Store`の`read_multi`に欠けているインストルメンテーションを追加します。
    ([Pull Request](https://github.com/rails/rails/pull/30268))

* `assert_difference`の最初の引数としてハッシュをサポートします。
    これにより、同じアサーション内で複数の数値の差異を指定することができます。
    ([Pull Request](https://github.com/rails/rails/pull/31600))

* キャッシュ：MemCacheとRedisの`read_multi`および`fetch_multi`の高速化。
    バックエンドを参照する前に、ローカルのインメモリキャッシュから読み取ります。
    ([Commit](https://github.com/rails/rails/commit/a2b97e4ffef971607a1be8fc7909f099b6840f36))

Active Job
----------

詳細な変更については、[Changelog][active-job]を参照してください。

### 注目すべき変更点

* `ActiveJob::Base.discard_on`にブロックを渡すことで、破棄されるジョブのカスタム処理を許可します。
    ([Pull Request](https://github.com/rails/rails/pull/30622))

Ruby on Rails Guides
--------------------

詳細な変更については、[Changelog][guides]を参照してください。

### 注目すべき変更点

* [Threading and Code Execution in Rails](threading_and_code_execution.html)ガイドを追加しました。
    ([Pull Request](https://github.com/rails/rails/pull/27494))

* [Active Storage Overview](active_storage_overview.html)ガイドを追加しました。
    ([Pull Request](https://github.com/rails/rails/pull/31037))

Credits
-------

Railsへの多くの時間を費やした多くの人々に感謝します。
[Railsへの貢献者の完全なリスト](https://contributors.rubyonrails.org/)を参照してください。
彼ら全員に賞賛を送ります。

[railties]:       https://github.com/rails/rails/blob/5-2-stable/railties/CHANGELOG.md
[action-pack]:    https://github.com/rails/rails/blob/5-2-stable/actionpack/CHANGELOG.md
[action-view]:    https://github.com/rails/rails/blob/5-2-stable/actionview/CHANGELOG.md
[action-mailer]:  https://github.com/rails/rails/blob/5-2-stable/actionmailer/CHANGELOG.md
[action-cable]:   https://github.com/rails/rails/blob/5-2-stable/actioncable/CHANGELOG.md
[active-record]:  https://github.com/rails/rails/blob/5-2-stable/activerecord/CHANGELOG.md
[active-model]:   https://github.com/rails/rails/blob/5-2-stable/activemodel/CHANGELOG.md
[active-job]:     https://github.com/rails/rails/blob/5-2-stable/activejob/CHANGELOG.md
[guides]:         https://github.com/rails/rails/blob/5-2-stable/guides/CHANGELOG.md
[active-support]: https://github.com/rails/rails/blob/5-2-stable/activesupport/CHANGELOG.md
