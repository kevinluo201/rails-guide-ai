**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: b1c2c8ad5c4bacb2e3b92aa320c4da3d
Ruby on Rails 6.0 リリースノート
===============================

Rails 6.0 のハイライト：

* Action Mailbox
* Action Text
* パラレルテスト
* Action Cable テスト

これらのリリースノートは主要な変更のみをカバーしています。さまざまなバグ修正や変更については、変更ログを参照するか、GitHub 上のメインの Rails リポジトリの[コミットのリスト](https://github.com/rails/rails/commits/6-0-stable)をチェックしてください。

--------------------------------------------------------------------------------

Rails 6.0 へのアップグレード
----------------------

既存のアプリケーションをアップグレードする場合は、アップグレードする前に十分なテストカバレッジを持つことが重要です。また、まだ行っていない場合はまず Rails 5.2 にアップグレードし、アプリケーションが正常に動作することを確認してから Rails 6.0 への更新を試みてください。アップグレード時に注意すべき点のリストは、[Ruby on Rails のアップグレード](upgrading_ruby_on_rails.html#upgrading-from-rails-5-2-to-rails-6-0)ガイドで入手できます。

主な機能
--------------

### Action Mailbox

[プルリクエスト](https://github.com/rails/rails/pull/34786)

[Action Mailbox](https://github.com/rails/rails/tree/6-0-stable/actionmailbox)は、受信したメールをコントローラのようなメールボックスにルーティングすることができます。
Action Mailbox については、[Action Mailbox の基本](action_mailbox_basics.html)ガイドで詳しく説明しています。

### Action Text

[プルリクエスト](https://github.com/rails/rails/pull/34873)

[Action Text](https://github.com/rails/rails/tree/6-0-stable/actiontext)は、Rails にリッチテキストのコンテンツと編集機能をもたらします。これには、フォーマットやリンク、引用、リスト、埋め込み画像やギャラリーなど、すべてを扱う[Trix エディタ](https://trix-editor.org)が含まれています。Trix エディタによって生成されたリッチテキストのコンテンツは、既存のアプリケーション内の任意の Active Record モデルに関連付けられた独自の RichText モデルに保存されます。埋め込まれた画像（またはその他の添付ファイル）は、Active Storage を使用して自動的に保存され、含まれる RichText モデルに関連付けられます。

Action Text については、[Action Text の概要](action_text_overview.html)ガイドで詳しく説明しています。

### パラレルテスト

[プルリクエスト](https://github.com/rails/rails/pull/31900)

[パラレルテスト](testing.html#parallel-testing)を使用すると、テストスイートを並列化することができます。プロセスのフォークがデフォルトの方法ですが、スレッドもサポートされています。テストを並列実行することで、テストスイート全体の実行時間を短縮することができます。

### Action Cable テスト

[プルリクエスト](https://github.com/rails/rails/pull/33659)

[Action Cable テストツール](testing.html#testing-action-cable)を使用すると、Action Cable の機能を接続、チャンネル、ブロードキャストのいずれのレベルでもテストすることができます。

Railties
--------

詳細な変更については、[変更ログ][railties]を参照してください。

### 削除

*   プラグインテンプレート内の非推奨な `after_bundle` ヘルパーを削除しました。
    ([コミット](https://github.com/rails/rails/commit/4d51efe24e461a2a3ed562787308484cd48370c7))

*   アプリケーションクラスを `run` の引数として使用する `config.ru` の非推奨なサポートを削除しました。
    ([コミット](https://github.com/rails/rails/commit/553b86fc751c751db504bcbe2d033eb2bb5b6a0b))

*   rails コマンドからの非推奨な `environment` 引数を削除しました。
    ([コミット](https://github.com/rails/rails/commit/e20589c9be09c7272d73492d4b0f7b24e5595571))

*   ジェネレータとテンプレート内の非推奨な `capify!` メソッドを削除しました。
    ([コミット](https://github.com/rails/rails/commit/9d39f81d512e0d16a27e2e864ea2dd0e8dc41b17))

*   非推奨な `config.secret_token` を削除しました。
    ([コミット](https://github.com/rails/rails/commit/46ac5fe69a20d4539a15929fe48293e1809a26b0))

### 非推奨

*   `rails server` に Rack サーバー名を通常の引数として渡すことを非推奨にしました。
    ([プルリクエスト](https://github.com/rails/rails/pull/32058))
* `HOST`環境を使用してサーバーIPを指定するサポートを非推奨にします。
    ([プルリクエスト](https://github.com/rails/rails/pull/32540))

* `config_for`によって返されるハッシュに非シンボルキーでアクセスすることを非推奨にします。
    ([プルリクエスト](https://github.com/rails/rails/pull/35198))

### 注目すべき変更点

* `rails server`コマンドのサーバーを指定するための明示的なオプション`--using`または`-u`を追加します。
    ([プルリクエスト](https://github.com/rails/rails/pull/32058))

* `rails routes`の出力を展開形式で表示する機能を追加します。
    ([プルリクエスト](https://github.com/rails/rails/pull/32130))

* インラインのActive Jobアダプターを使用してシードデータベースタスクを実行します。
    ([プルリクエスト](https://github.com/rails/rails/pull/34953))

* アプリケーションのデータベースを変更するための`rails db:system:change`コマンドを追加します。
    ([プルリクエスト](https://github.com/rails/rails/pull/34832))

* `rails test:channels`コマンドを追加して、Action Cableチャンネルのみをテストします。
    ([プルリクエスト](https://github.com/rails/rails/pull/34947))

* DNSリバインディング攻撃に対するガードを導入します。
    ([プルリクエスト](https://github.com/rails/rails/pull/33145))

* ジェネレーターコマンドの実行中に失敗した場合に中止する機能を追加します。
    ([プルリクエスト](https://github.com/rails/rails/pull/34420))

* Rails 6のデフォルトのJavaScriptコンパイラをWebpackerにします。
    ([プルリクエスト](https://github.com/rails/rails/pull/33079))

* `rails db:migrate:status`コマンドに複数のデータベースのサポートを追加します。
    ([プルリクエスト](https://github.com/rails/rails/pull/34137))

* ジェネレーターで複数のデータベースから異なるマイグレーションパスを使用する機能を追加します。
    ([プルリクエスト](https://github.com/rails/rails/pull/34021))

* 複数の環境での認証情報のサポートを追加します。
    ([プルリクエスト](https://github.com/rails/rails/pull/33521))

* テスト環境でのデフォルトのキャッシュストアを`null_store`にします。
    ([プルリクエスト](https://github.com/rails/rails/pull/33773))

Action Cable
------------

詳細な変更点については、[Changelog][action-cable]を参照してください。

### 削除

* `ActionCable.startDebugging()`と`ActionCable.stopDebugging()`を`ActionCable.logger.enabled`で置き換えます。
    ([プルリクエスト](https://github.com/rails/rails/pull/34370))

### 非推奨

* Rails 6.0では、Action Cableに関する非推奨事項はありません。

### 注目すべき変更点

* `cable.yml`でPostgreSQLのサブスクリプションアダプターの`channel_prefix`オプションをサポートします。
    ([プルリクエスト](https://github.com/rails/rails/pull/35276))

* `ActionCable::Server::Base`にカスタム設定を渡す機能を追加します。
    ([プルリクエスト](https://github.com/rails/rails/pull/34714))

* `:action_cable_connection`と`:action_cable_channel`のロードフックを追加します。
    ([プルリクエスト](https://github.com/rails/rails/pull/35094))

* `Channel::Base#broadcast_to`と`Channel::Base.broadcasting_for`を追加します。
    ([プルリクエスト](https://github.com/rails/rails/pull/35021))

* `ActionCable::Connection`から`reject_unauthorized_connection`を呼び出すと接続を閉じます。
    ([プルリクエスト](https://github.com/rails/rails/pull/34194))

* Action CableのJavaScriptパッケージをCoffeeScriptからES2015に変換し、ソースコードをnpm配布に公開します。
    ([プルリクエスト](https://github.com/rails/rails/pull/34370))

* WebSocketアダプターとロガーアダプターの設定を`ActionCable`のプロパティから`ActionCable.adapters`に移動します。
    ([プルリクエスト](https://github.com/rails/rails/pull/34370))

* Action CableのRedisアダプターに`id`オプションを追加して、Redisの接続を区別します。
    ([プルリクエスト](https://github.com/rails/rails/pull/33798))

Action Pack
-----------

詳細な変更点については、[Changelog][action-pack]を参照してください。

### 削除

* `combined_fragment_cache_key`に対して非推奨の`fragment_cache_key`ヘルパーを削除します。
    ([コミット](https://github.com/rails/rails/commit/e70d3df7c9b05c129b0fdcca57f66eca316c5cfc))

* `ActionDispatch::TestResponse`の非推奨メソッドを削除します：
    `#success?`を`#successful?`に、`#missing?`を`#not_found?`に、`#error?`を`#server_error?`に置き換えます。
    ([コミット](https://github.com/rails/rails/commit/13ddc92e079e59a0b894e31bf5bb4fdecbd235d1))

### 非推奨

* `ActionDispatch::Http::ParameterFilter`を`ActiveSupport::ParameterFilter`に非推奨にします。
    ([プルリクエスト](https://github.com/rails/rails/pull/34039))

* コントローラーレベルの`force_ssl`を`config.force_ssl`に非推奨にします。
    ([プルリクエスト](https://github.com/rails/rails/pull/32277))

[action-cable]: https://github.com/rails/rails/blob/master/actioncable/CHANGELOG.md
[action-pack]: https://github.com/rails/rails/blob/master/actionpack/CHANGELOG.md
### 注目すべき変更点

*   `ActionDispatch::Response#content_type`がContent-Typeヘッダーをそのまま返すように変更されました。
    ([プルリクエスト](https://github.com/rails/rails/pull/36034))

*   リソースパラメータにコロンが含まれている場合、`ArgumentError`を発生させるように変更されました。
    ([プルリクエスト](https://github.com/rails/rails/pull/35236))

*   特定のブラウザの機能を定義するために、`ActionDispatch::SystemTestCase.driven_by`をブロックで呼び出すことができるようになりました。
    ([プルリクエスト](https://github.com/rails/rails/pull/35081))

*   DNSリバインディング攻撃から保護するための`ActionDispatch::HostAuthorization`ミドルウェアが追加されました。
    ([プルリクエスト](https://github.com/rails/rails/pull/33145))

*   `ActionController::TestCase`で`parsed_body`を使用することができるようになりました。
    ([プルリクエスト](https://github.com/rails/rails/pull/34717))

*   同じコンテキスト内で複数のルートルートが存在する場合、`as:`の名前指定がない場合に`ArgumentError`を発生させるように変更されました。
    ([プルリクエスト](https://github.com/rails/rails/pull/34494))

*   パラメータの解析エラーを処理するために`#rescue_from`の使用を許可するようになりました。
    ([プルリクエスト](https://github.com/rails/rails/pull/34341))

*   パラメータを反復処理するための`ActionController::Parameters#each_value`が追加されました。
    ([プルリクエスト](https://github.com/rails/rails/pull/33979))

*   `send_data`と`send_file`でContent-Dispositionのファイル名をエンコードするようになりました。
    ([プルリクエスト](https://github.com/rails/rails/pull/33829))

*   `ActionController::Parameters#each_key`を公開するようになりました。
    ([プルリクエスト](https://github.com/rails/rails/pull/33758))

*   署名付き/暗号化されたクッキー内の目的と有効期限のメタデータが追加され、クッキーの値をコピーしないようになりました。
    ([プルリクエスト](https://github.com/rails/rails/pull/32937))

*   矛盾する`respond_to`呼び出しに対して`ActionController::RespondToMismatchError`を発生させるようになりました。
    ([プルリクエスト](https://github.com/rails/rails/pull/33446))

*   リクエストフォーマットのテンプレートが存在しない場合に明示的なエラーページを追加しました。
    ([プルリクエスト](https://github.com/rails/rails/pull/29286))

*   `ActionDispatch::DebugExceptions.register_interceptor`を導入し、レンダリング前に例外を処理する方法を提供しました。
    ([プルリクエスト](https://github.com/rails/rails/pull/23868))

*   1つのリクエストに対して1つのContent-Security-Policy nonceヘッダー値のみを出力するようになりました。
    ([プルリクエスト](https://github.com/rails/rails/pull/32602))

*   明示的にコントローラに含めることができる、Railsのデフォルトヘッダー設定のためのモジュールが追加されました。
    ([プルリクエスト](https://github.com/rails/rails/pull/32484))

*   `ActionDispatch::Request::Session`に`#dig`を追加しました。
    ([プルリクエスト](https://github.com/rails/rails/pull/32446))

Action View
-----------

詳細な変更点については、[Changelog][action-view]を参照してください。

### 削除

*   廃止予定の`image_alt`ヘルパーを削除しました。
    ([コミット](https://github.com/rails/rails/commit/60c8a03c8d1e45e48fcb1055ba4c49ed3d5ff78f))

*   機能が既に`record_tag_helper` gemに移動された空の`RecordTagHelper`モジュールを削除しました。
    ([コミット](https://github.com/rails/rails/commit/5c5ddd69b1e06fb6b2bcbb021e9b8dae17e7cb31))

### 廃止予定

*   置換なしで`ActionView::Template.finalize_compiled_template_methods`を廃止しました。
    ([プルリクエスト](https://github.com/rails/rails/pull/35036))

*   置換なしで`config.action_view.finalize_compiled_template_methods`を廃止しました。
    ([プルリクエスト](https://github.com/rails/rails/pull/35036))

*   `options_from_collection_for_select`ビューヘルパーからプライベートモデルメソッドを呼び出すことを廃止しました。
    ([プルリクエスト](https://github.com/rails/rails/pull/33547))

### 注目すべき変更点

*   開発モードでのみファイルの変更時にAction Viewキャッシュをクリアし、開発モードの高速化を実現しました。
    ([プルリクエスト](https://github.com/rails/rails/pull/35629))

*   Railsのすべてのnpmパッケージを`@rails`スコープに移動しました。
    ([プルリクエスト](https://github.com/rails/rails/pull/34905))

*   登録されたMIMEタイプからのフォーマットのみを受け入れるようにしました。
    ([プルリクエスト](https://github.com/rails/rails/pull/35604), [プルリクエスト](https://github.com/rails/rails/pull/35753))

*   テンプレートとパーシャルのレンダリングサーバー出力に割り当てを追加しました。
    ([プルリクエスト](https://github.com/rails/rails/pull/34136))

*   `date_select`タグに`year_format`オプションを追加し、年の名前をカスタマイズできるようにしました。
    ([プルリクエスト](https://github.com/rails/rails/pull/32190))

*   `javascript_include_tag`ヘルパーに`nonce: true`オプションを追加し、Content Security Policyの自動nonce生成をサポートしました。
    ([プルリクエスト](https://github.com/rails/rails/pull/32607))

*   `ActionView::Template`の最終処理を無効化または有効化するための`action_view.finalize_compiled_template_methods`設定を追加しました。
    ([プルリクエスト](https://github.com/rails/rails/pull/32418))
*   `rails_ujs`内のJavaScriptの`confirm`呼び出しを、オーバーライド可能なメソッドに抽出します。
    ([プルリクエスト](https://github.com/rails/rails/pull/32404))

*   UTF-8エンコーディングの強制を処理するために、`action_controller.default_enforce_utf8`設定オプションを追加します。デフォルトは`false`です。
    ([プルリクエスト](https://github.com/rails/rails/pull/32125))

*   ロケールキーをサブミットタグに対してI18nキースタイルのサポートを追加します。
    ([プルリクエスト](https://github.com/rails/rails/pull/26799))

アクションメーラー
-------------

詳細な変更については、[変更履歴][action-mailer]を参照してください。

### 削除

### 廃止予定

*   `ActionMailer::Base.receive`を廃止し、Action Mailboxを利用するようにします。
    ([コミット](https://github.com/rails/rails/commit/e3f832a7433a291a51c5df397dc3dd654c1858cb))

*   `DeliveryJob`と`Parameterized::DeliveryJob`を廃止し、`MailDeliveryJob`を利用するようにします。
    ([プルリクエスト](https://github.com/rails/rails/pull/34591))

### 注目すべき変更

*   通常のメールとパラメータ化されたメールの両方を配信するための`MailDeliveryJob`を追加します。
    ([プルリクエスト](https://github.com/rails/rails/pull/34591))

*   カスタムのメール配信ジョブがAction Mailerのテストアサーションと連携できるようにします。
    ([プルリクエスト](https://github.com/rails/rails/pull/34339))

*   アクション名だけでなく、ブロックを使用してマルチパートメールのテンプレート名を指定できるようにします。
    ([プルリクエスト](https://github.com/rails/rails/pull/22534))

*   `deliver.action_mailer`通知のペイロードに`perform_deliveries`を追加します。
    ([プルリクエスト](https://github.com/rails/rails/pull/33824))

*   `perform_deliveries`がfalseの場合に、メールの送信がスキップされたことを示すログメッセージを改善します。
    ([プルリクエスト](https://github.com/rails/rails/pull/33824))

*   ブロックなしで`assert_enqueued_email_with`を呼び出すことができるようにします。
    ([プルリクエスト](https://github.com/rails/rails/pull/33258))

*   `assert_emails`ブロック内でエンキューされたメール配信ジョブを実行します。
    ([プルリクエスト](https://github.com/rails/rails/pull/32231))

*   `ActionMailer::Base`からオブザーバーとインターセプターを登録解除できるようにします。
    ([プルリクエスト](https://github.com/rails/rails/pull/32207))

アクティブレコード
-------------

詳細な変更については、[変更履歴][active-record]を参照してください。

### 削除

*   トランザクションオブジェクトから廃止予定の`#set_state`を削除します。
    ([コミット](https://github.com/rails/rails/commit/6c745b0c5152a4437163a67707e02f4464493983))

*   データベースアダプタから廃止予定の`#supports_statement_cache?`を削除します。
    ([コミット](https://github.com/rails/rails/commit/5f3ed8784383fb4eb0f9959f31a9c28a991b7553))

*   データベースアダプタから廃止予定の`#insert_fixtures`を削除します。
    ([コミット](https://github.com/rails/rails/commit/400ba786e1d154448235f5f90183e48a1043eece))

*   `ActiveRecord::ConnectionAdapters::SQLite3Adapter#valid_alter_table_type?`を廃止します。
    ([コミット](https://github.com/rails/rails/commit/45b4d5f81f0c0ca72c18d0dea4a3a7b2ecc589bf))

*   ブロックが渡された場合に`sum`にカラム名を渡すことをサポートしないようにします。
    ([コミット](https://github.com/rails/rails/commit/91ddb30083430622188d76eb9f29b78131df67f9))

*   ブロックが渡された場合に`count`にカラム名を渡すことをサポートしないようにします。
    ([コミット](https://github.com/rails/rails/commit/67356f2034ab41305af7218f7c8b2fee2d614129))

*   リレーションの欠落したメソッドをArelに委譲するサポートを削除します。
    ([コミット](https://github.com/rails/rails/commit/d97980a16d76ad190042b4d8578109714e9c53d0))

*   リレーションの欠落したメソッドをクラスのプライベートメソッドに委譲するサポートを削除します。
    ([コミット](https://github.com/rails/rails/commit/a7becf147afc85c354e5cfa519911a948d25fc4d))

*   `#cache_key`にタイムスタンプ名を指定するサポートを削除します。
    ([コミット](https://github.com/rails/rails/commit/0bef23e630f62e38f20b5ae1d1d5dbfb087050ea))

*   廃止予定の`ActiveRecord::Migrator.migrations_path=`を削除します。
    ([コミット](https://github.com/rails/rails/commit/90d7842186591cae364fab3320b524e4d31a7d7d))

*   `expand_hash_conditions_for_aggregates`を廃止します。
    ([コミット](https://github.com/rails/rails/commit/27b252d6a85e300c7236d034d55ec8e44f57a83e))


### 廃止予定

*   一意性バリデータの大文字小文字の区別がある照合比較を廃止します。
    ([コミット](https://github.com/rails/rails/commit/9def05385f1cfa41924bb93daa187615e88c95b9))

*   受信側スコープが漏洩している場合に、クラスレベルのクエリメソッドの使用を廃止します。
    ([プルリクエスト](https://github.com/rails/rails/pull/35280))

*   `config.active_record.sqlite3.represent_boolean_as_integer`を廃止します。
    ([コミット](https://github.com/rails/rails/commit/f59b08119bc0c01a00561d38279b124abc82561b))

*   `migrations_paths`を`connection.assume_migrated_upto_version`に渡すことを廃止します。
    ([コミット](https://github.com/rails/rails/commit/c1b14aded27e063ead32fa911aa53163d7cfc21a))

*   `ActiveRecord::Result#to_hash`を`ActiveRecord::Result#to_a`に廃止します。
    ([コミット](https://github.com/rails/rails/commit/16510d609c601aa7d466809f3073ec3313e08937))

*   `DatabaseLimits`のメソッド`column_name_length`、`table_name_length`、
    `columns_per_table`、`indexes_per_table`、`columns_per_multicolumn_index`、
    `sql_query_length`、`joins_per_query`を廃止します。
    ([コミット](https://github.com/rails/rails/commit/e0a1235f7df0fa193c7e299a5adee88db246b44f))

*   `update_attributes`/`!`を`update`/`!`に廃止します。
    ([コミット](https://github.com/rails/rails/commit/5645149d3a27054450bd1130ff5715504638a5f5))

### 注目すべき変更

*   `sqlite3` gemの最小バージョンを1.4に上げます。
    ([プルリクエスト](https://github.com/rails/rails/pull/35844))

[action-mailer]: https://github.com/rails/rails/blob/master/actionmailer/CHANGELOG.md
[active-record]: https://github.com/rails/rails/blob/master/activerecord/CHANGELOG.md
* `rails db:prepare`を追加して、存在しない場合はデータベースを作成し、マイグレーションを実行します。
    ([プルリクエスト](https://github.com/rails/rails/pull/35768))

* `after_save_commit`コールバックを追加して、`after_commit :hook, on: [ :create, :update ]`のショートカットを提供します。
    ([プルリクエスト](https://github.com/rails/rails/pull/35804))

* 関連するレコードをリレーションから抽出するための`ActiveRecord::Relation#extract_associated`を追加します。
    ([プルリクエスト](https://github.com/rails/rails/pull/35784))

* ActiveRecord::RelationクエリにSQLコメントを追加するための`ActiveRecord::Relation#annotate`を追加します。
    ([プルリクエスト](https://github.com/rails/rails/pull/35617))

* データベースにOptimizer Hintsを設定するサポートを追加します。
    ([プルリクエスト](https://github.com/rails/rails/pull/35615))

* バルク挿入を行うための`insert_all`/`insert_all!`/`upsert_all`メソッドを追加します。
    ([プルリクエスト](https://github.com/rails/rails/pull/35631))

* 現在の環境の各データベースのテーブルを切り捨て、シードをロードするための`rails db:seed:replant`を追加します。
    ([プルリクエスト](https://github.com/rails/rails/pull/34779))

* `unscope(:select).select(fields)`のショートカットである`reselect`メソッドを追加します。
    ([プルリクエスト](https://github.com/rails/rails/pull/33611))

* すべてのenum値に対するネガティブスコープを追加します。
    ([プルリクエスト](https://github.com/rails/rails/pull/35381))

* 条件付きの削除のための`#destroy_by`と`#delete_by`を追加します。
    ([プルリクエスト](https://github.com/rails/rails/pull/35316))

* ブロックの実行中にデータベースへの書き込みを自動的に無効にする機能を追加します。
    ([プルリクエスト](https://github.com/rails/rails/pull/35073))

* 複数のデータベースをサポートするための接続切り替えの機能を追加します。
    ([プルリクエスト](https://github.com/rails/rails/pull/34505))

* 複数のデータベースをサポートするための接続切り替えのためのAPIを追加します。
    ([プルリクエスト](https://github.com/rails/rails/pull/34052))

* マイグレーションのデフォルトとして、タイムスタンプに精度を設定します。
    ([プルリクエスト](https://github.com/rails/rails/pull/34970))

* MySQLでテキストとBLOBのサイズを変更するための`:size`オプションをサポートします。
    ([プルリクエスト](https://github.com/rails/rails/pull/35071))

* `dependent: :nullify`戦略でのポリモーフィック関連の場合、外部キーと外部タイプの両方のカラムをNULLに設定します。
    ([プルリクエスト](https://github.com/rails/rails/pull/28078))

* `ActiveRecord::Relation#exists?`の引数として許可された`ActionController::Parameters`のインスタンスを渡すことを許可します。
    ([プルリクエスト](https://github.com/rails/rails/pull/34891))

* Ruby 2.6で導入された無限範囲のための`#where`サポートを追加します。
    ([プルリクエスト](https://github.com/rails/rails/pull/34906))

* MySQLのデフォルトのテーブル作成オプションとして`ROW_FORMAT=DYNAMIC`を設定します。
    ([プルリクエスト](https://github.com/rails/rails/pull/34742))

* `ActiveRecord.enum`によって生成されるスコープを無効にする機能を追加します。
    ([プルリクエスト](https://github.com/rails/rails/pull/34605))

* カラムの暗黙の並べ替えを設定可能にします。
    ([プルリクエスト](https://github.com/rails/rails/pull/34480))

* PostgreSQLの最小バージョンを9.3に引き上げ、9.1と9.2のサポートを終了します。
    ([プルリクエスト](https://github.com/rails/rails/pull/34520))

* enumの値を変更しようとするとエラーが発生するようにし、enumの値を凍結します。
    ([プルリクエスト](https://github.com/rails/rails/pull/34517))

* `ActiveRecord::StatementInvalid`エラーのSQLを独自のエラープロパティとして設定し、SQLバインドを別のエラープロパティとして含めます。
    ([プルリクエスト](https://github.com/rails/rails/pull/34468))

* `create_table`に`if_not_exists`オプションを追加します。
    ([プルリクエスト](https://github.com/rails/rails/pull/31382))

* `rails db:schema:cache:dump`と`rails db:schema:cache:clear`に複数のデータベースのサポートを追加します。
    ([プルリクエスト](https://github.com/rails/rails/pull/34181))

* `ActiveRecord::Base.connected_to`のデータベースハッシュでハッシュとURLの設定をサポートします。
    ([プルリクエスト](https://github.com/rails/rails/pull/34196))

* MySQLのデフォルト式と式インデックスのサポートを追加します。
    ([プルリクエスト](https://github.com/rails/rails/pull/34307))

* `change_table`マイグレーションヘルパーのための`index`オプションを追加します。
    ([プルリクエスト](https://github.com/rails/rails/pull/23593))
* マイグレーションの`transaction`のリバートを修正しました。以前は、リバートされたマイグレーション内のコマンドがリバートされずに実行されていましたが、この変更により修正されました。
    ([プルリクエスト](https://github.com/rails/rails/pull/31604))

* `ActiveRecord::Base.configurations=`をシンボル化されたハッシュで設定できるようにしました。
    ([プルリクエスト](https://github.com/rails/rails/pull/33968))

* カウンターキャッシュを実際に保存された場合にのみ更新するように修正しました。
    ([プルリクエスト](https://github.com/rails/rails/pull/33913))

* SQLiteアダプターに式インデックスのサポートを追加しました。
    ([プルリクエスト](https://github.com/rails/rails/pull/33874))

* 関連するレコードの自動保存コールバックをサブクラスで再定義できるようにしました。
    ([プルリクエスト](https://github.com/rails/rails/pull/33378))

* 最小のMySQLバージョンを5.5.8に引き上げました。
    ([プルリクエスト](https://github.com/rails/rails/pull/33853))

* MySQLでデフォルトでutf8mb4文字セットを使用するようにしました。
    ([プルリクエスト](https://github.com/rails/rails/pull/33608))

* `#inspect`で機密データをフィルタリングする機能を追加しました。
    ([プルリクエスト](https://github.com/rails/rails/pull/33756), [プルリクエスト](https://github.com/rails/rails/pull/34208))

* `ActiveRecord::Base.configurations`をハッシュではなくオブジェクトを返すように変更しました。
    ([プルリクエスト](https://github.com/rails/rails/pull/33637))

* アドバイザリーロックを無効にするためのデータベース設定を追加しました。
    ([プルリクエスト](https://github.com/rails/rails/pull/33691))

* SQLite3アダプターの`alter_table`メソッドを更新して外部キーを復元するようにしました。
    ([プルリクエスト](https://github.com/rails/rails/pull/33585))

* `remove_foreign_key`の`to_table`オプションを反転可能にするようにしました。
    ([プルリクエスト](https://github.com/rails/rails/pull/33530))

* 指定された精度を持つMySQLの時間型のデフォルト値を修正しました。
    ([プルリクエスト](https://github.com/rails/rails/pull/33280))

* `touch`オプションを`Persistence#touch`メソッドと一貫した動作に修正しました。
    ([プルリクエスト](https://github.com/rails/rails/pull/33107))

* マイグレーションで重複する列定義がある場合に例外を発生させるようにしました。
    ([プルリクエスト](https://github.com/rails/rails/pull/33029))

* 最小のSQLiteバージョンを3.8に引き上げました。
    ([プルリクエスト](https://github.com/rails/rails/pull/32923))

* 親レコードが重複した子レコードと一緒に保存されないように修正しました。
    ([プルリクエスト](https://github.com/rails/rails/pull/32952))

* `Associations::CollectionAssociation#size`と`Associations::CollectionAssociation#empty?`がロードされた関連のIDを使用するように修正しました。
    ([プルリクエスト](https://github.com/rails/rails/pull/32617))

* ポリモーフィック関連のレコードの一部に要求された関連が存在しない場合に関連をプリロードするサポートを追加しました。
    ([コミット](https://github.com/rails/rails/commit/75ef18c67c29b1b51314b6c8a963cee53394080b))

* `ActiveRecord::Relation`に`touch_all`メソッドを追加しました。
    ([プルリクエスト](https://github.com/rails/rails/pull/31513))

* `ActiveRecord::Base.base_class?`述語を追加しました。
    ([プルリクエスト](https://github.com/rails/rails/pull/32417))

* `ActiveRecord::Store.store_accessor`にカスタムの接頭辞/接尾辞オプションを追加しました。
    ([プルリクエスト](https://github.com/rails/rails/pull/32306))

* `ActiveRecord::Base.find_or_create_by`/`!`のSELECT/INSERT競合状態を処理するために、`ActiveRecord::Base.create_or_find_by`/`!`を追加しました。
    ([プルリクエスト](https://github.com/rails/rails/pull/31989))

* 単一の値のプラックスのための省略形として`Relation#pick`を追加しました。
    ([プルリクエスト](https://github.com/rails/rails/pull/31941))

Active Storage
--------------

詳細な変更については、[Changelog][active-storage]を参照してください。

### 削除

### 廃止予定

* `config.active_storage.queue`を`config.active_storage.queues.analysis`と`config.active_storage.queues.purge`に置き換えるために、`config.active_storage.queue`を廃止予定にしました。
    ([プルリクエスト](https://github.com/rails/rails/pull/34838))

* `ActiveStorage::Downloading`を`ActiveStorage::Blob#open`に置き換えるために、`ActiveStorage::Downloading`を廃止予定にしました。
    ([コミット](https://github.com/rails/rails/commit/ee21b7c2eb64def8f00887a9fafbd77b85f464f1))

* 画像のバリアントを生成するために`mini_magick`を直接使用することを廃止し、`image_processing`を使用するようにしました。
    ([コミット](https://github.com/rails/rails/commit/697f4a93ad386f9fb7795f0ba68f815f16ebad0f))

* Active StorageのImageProcessingトランスフォーマーで`combine_options`を廃止しました。
    ([コミット](https://github.com/rails/rails/commit/697f4a93ad386f9fb7795f0ba68f815f16ebad0f))

### 注目すべき変更

* BMP画像のバリアント生成をサポートしました。
    ([プルリクエスト](https://github.com/rails/rails/pull/36051))

* TIFF画像のバリアント生成をサポートしました。
    ([プルリクエスト](https://github.com/rails/rails/pull/34824))

* プログレッシブJPEG画像のバリアント生成をサポートしました。
    ([プルリクエスト](https://github.com/rails/rails/pull/34455))
* `ActiveStorage.routes_prefix`を追加して、Active Storageが生成するルートを設定できるようにしました。
    ([プルリクエスト](https://github.com/rails/rails/pull/33883))

* `ActiveStorage::DiskController#show`でリクエストされたファイルがディスクサービスから見つからない場合、404 Not Foundのレスポンスを返すようにしました。
    ([プルリクエスト](https://github.com/rails/rails/pull/33666))

* `ActiveStorage::Blob#download`と`ActiveStorage::Blob#open`でリクエストされたファイルが見つからない場合、`ActiveStorage::FileNotFoundError`を発生させるようにしました。
    ([プルリクエスト](https://github.com/rails/rails/pull/33666))

* Active Storageの例外が継承するための汎用的な`ActiveStorage::Error`クラスを追加しました。
    ([コミット](https://github.com/rails/rails/commit/18425b837149bc0d50f8d5349e1091a623762d6b))

* レコードに割り当てられたアップロードされたファイルを、レコードが保存される時点でストレージに永続化するようにしました。
    ([プルリクエスト](https://github.com/rails/rails/pull/33303))

* 添付ファイルのコレクションに割り当てる際に、既存のファイルを置き換えるオプションを追加しました（`@user.update!(images: [ … ])`のような形式）。この動作を制御するには、`config.active_storage.replace_on_assign_to_many`を使用してください。
    ([プルリクエスト](https://github.com/rails/rails/pull/33303),
     [プルリクエスト](https://github.com/rails/rails/pull/36716))

* 既存のActive Recordの反射機構を使用して、定義された添付ファイルに関する情報を取得できるようにしました。
    ([プルリクエスト](https://github.com/rails/rails/pull/33018))

* `ActiveStorage::Blob#open`を追加し、ブロブをディスク上の一時ファイルにダウンロードし、その一時ファイルをyieldするようにしました。
    ([コミット](https://github.com/rails/rails/commit/ee21b7c2eb64def8f00887a9fafbd77b85f464f1))

* Google Cloud Storageからのストリーミングダウンロードをサポートしました。`google-cloud-storage` gemのバージョン1.11以上が必要です。
    ([プルリクエスト](https://github.com/rails/rails/pull/32788))

* Active Storageのバリアントには`mini_magick`の代わりに`image_processing` gemを使用するようにしました。
    ([プルリクエスト](https://github.com/rails/rails/pull/32471))

Active Model
------------

詳細な変更については、[Changelog][active-model]を参照してください。

### 削除

### 廃止予定

### 注目すべき変更

* `ActiveModel::Errors#full_message`のフォーマットをカスタマイズするための設定オプションを追加しました。
    ([プルリクエスト](https://github.com/rails/rails/pull/32956))

* `has_secure_password`の属性名を設定するためのサポートを追加しました。
    ([プルリクエスト](https://github.com/rails/rails/pull/26764))

* `ActiveModel::Errors`に`#slice!`メソッドを追加しました。
    ([プルリクエスト](https://github.com/rails/rails/pull/34489))

* 特定のエラーの存在をチェックするための`ActiveModel::Errors#of_kind?`を追加しました。
    ([プルリクエスト](https://github.com/rails/rails/pull/34866))

* タイムスタンプのための`ActiveModel::Serializers::JSON#as_json`メソッドを修正しました。
    ([プルリクエスト](https://github.com/rails/rails/pull/31503))

* Active Record以外では、数値検証子は型変換前の値を使用するように修正しました。
    ([プルリクエスト](https://github.com/rails/rails/pull/33654))

* `BigDecimal`と`Float`の数値検証の等価性を、検証の両端で`BigDecimal`にキャストすることで修正しました。
    ([プルリクエスト](https://github.com/rails/rails/pull/32852))

* マルチパラメータの時間ハッシュをキャストする際の年の値を修正しました。
    ([プルリクエスト](https://github.com/rails/rails/pull/34990))

* ブール属性の偽の値として、偽のブールシンボルを型変換するように修正しました。
    ([プルリクエスト](https://github.com/rails/rails/pull/35794))

* `ActiveModel::Type::Date`の`value_from_multiparameter_assignment`でパラメータを変換する際に、正しい日付を返すように修正しました。
    ([プルリクエスト](https://github.com/rails/rails/pull/29651))

* エラーの翻訳を取得する際に、`:errors`の名前空間の代わりに親のロケールを優先して使用するように修正しました。
    ([プルリクエスト](https://github.com/rails/rails/pull/35424))

Active Support
--------------

詳細な変更については、[Changelog][active-support]を参照してください。

### 削除

* `Inflections`から非推奨の`#acronym_regex`メソッドを削除しました。
    ([コミット](https://github.com/rails/rails/commit/0ce67d3cd6d1b7b9576b07fecae3dd5b422a5689))

* 非推奨の`Module#reachable?`メソッドを削除しました。
    ([コミット](https://github.com/rails/rails/commit/6eb1d56a333fd2015610d31793ed6281acd66551))

* 代替方法なしで`` Kernel#` ``を削除しました。
    ([プルリクエスト](https://github.com/rails/rails/pull/31253))

### 廃止予定

* `String#first`と`String#last`に対して負の整数引数を使用することを廃止しました。
    ([プルリクエスト](https://github.com/rails/rails/pull/33058))

* `ActiveSupport::Multibyte::Unicode#downcase/upcase/swapcase`を廃止し、`String#downcase/upcase/swapcase`を使用するようにしました。
    ([プルリクエスト](https://github.com/rails/rails/pull/34123))
* `ActiveSupport::Multibyte::Unicode#normalize`と`ActiveSupport::Multibyte::Chars#normalize`を`String#unicode_normalize`に置き換えるために非推奨化します。
（[プルリクエスト]（https://github.com/rails/rails/pull/34202））

* `ActiveSupport::Multibyte::Chars.consumes?`を`String#is_utf8?`に置き換えるために非推奨化します。
（[プルリクエスト]（https://github.com/rails/rails/pull/34215））

* `ActiveSupport::Multibyte::Unicode#pack_graphemes（array）`と`ActiveSupport::Multibyte::Unicode#unpack_graphemes（string）`をそれぞれ`array.flatten.pack（"U *"）`と`string.scan（/ \ X /）.map（&：codepoints）`に置き換えるために非推奨化します。
（[プルリクエスト]（https://github.com/rails/rails/pull/34254））

### 注目すべき変更

* 並列テストのサポートを追加します。
（[プルリクエスト]（https://github.com/rails/rails/pull/31900））

* `String#strip_heredoc`が文字列の凍結を保持するようにします。
（[プルリクエスト]（https://github.com/rails/rails/pull/32037））

* マルチバイト文字やグラフェムクラスターを壊さずに、文字列を最大バイトサイズに切り詰めるための`String#truncate_bytes`を追加します。
（[プルリクエスト]（https://github.com/rails/rails/pull/27319））

* `delegate`メソッドに`private`オプションを追加し、プライベートメソッドに委譲するためのオプションを追加します。このオプションは`true/false`を値として受け入れます。
（[プルリクエスト]（https://github.com/rails/rails/pull/31944））

* `ActiveSupport::Inflector#ordinal`と`ActiveSupport::Inflector#ordinalize`の翻訳をサポートするために、I18nを介した翻訳のサポートを追加します。
（[プルリクエスト]（https://github.com/rails/rails/pull/32168））

* `Date`、`DateTime`、`Time`、および`TimeWithZone`に`before?`および`after?`メソッドを追加します。
（[プルリクエスト]（https://github.com/rails/rails/pull/32185））

* `URI.unescape`が混在したUnicode/エスケープ文字の入力で失敗するバグを修正します。
（[プルリクエスト]（https://github.com/rails/rails/pull/32183））

* 圧縮が有効になっている場合に、`ActiveSupport::Cache`がストレージサイズを大幅に拡大するバグを修正します。
（[プルリクエスト]（https://github.com/rails/rails/pull/32539））

* Redisキャッシュストア：`delete_matched`がRedisサーバーをブロックしなくなりました。
（[プルリクエスト]（https://github.com/rails/rails/pull/32614））

* `ActiveSupport::TimeZone.all`が、`ActiveSupport::TimeZone::MAPPING`で定義された任意のタイムゾーンのtzinfoデータが欠落している場合に失敗するバグを修正します。
（[プルリクエスト]（https://github.com/rails/rails/pull/32613））

* `Enumerable#index_with`を追加し、渡されたブロックまたはデフォルト引数の値で列挙可能なオブジェクトからハッシュを作成できるようにします。
（[プルリクエスト]（https://github.com/rails/rails/pull/32523））

* `Range#===`および`Range#cover?`メソッドが`Range`引数と一緒に動作するようにします。
（[プルリクエスト]（https://github.com/rails/rails/pull/32938））

* RedisCacheStoreの`increment/decrement`操作でキーの有効期限をサポートします。
（[プルリクエスト]（https://github.com/rails/rails/pull/33254））

* ログサブスクライバイベントにCPU時間、アイドル時間、および割り当て機能を追加します。
（[プルリクエスト]（https://github.com/rails/rails/pull/33449））

* Active Support通知システムにイベントオブジェクトのサポートを追加します。
（[プルリクエスト]（https://github.com/rails/rails/pull/33451））

* `ActiveSupport::Cache#fetch`のための新しいオプション`skip_nil`を導入して、`nil`エントリをキャッシュしないようにサポートを追加します。
（[プルリクエスト]（https://github.com/rails/rails/pull/25437））

* ブロックが真の値を返す要素を削除して返す`Array#extract!`メソッドを追加します。
（[プルリクエスト]（https://github.com/rails/rails/pull/33137））

* スライス後もHTMLセーフな文字列をHTMLセーフに保ちます。
（[プルリクエスト]（https://github.com/rails/rails/pull/33808））

* ロギングを介した定数の自動読み込みのトレースをサポートするためのサポートを追加します。
（[コミット]（https://github.com/rails/rails/commit/c03bba4f1f03bad7dc034af555b7f2b329cf76f5））

* `unfreeze_time`を`travel_back`のエイリアスとして定義します。
（[プルリクエスト]（https://github.com/rails/rails/pull/33813））

* `ActiveSupport::TaggedLogging.new`を、受け取ったロガーインスタンスを変更するのではなく、新しいロガーインスタンスを返すように変更します。
（[プルリクエスト]（https://github.com/rails/rails/pull/27792））

* `#delete_prefix`、`#delete_suffix`、および`#unicode_normalize`メソッドをHTMLセーフでないメソッドとして扱います。
（[プルリクエスト]（https://github.com/rails/rails/pull/33990））

* `ActiveSupport::HashWithIndifferentAccess`の`#without`がシンボル引数で失敗するバグを修正します。
（[プルリクエスト]（https://github.com/rails/rails/pull/34012））

* `Module#parent`、`Module#parents`、および`Module#parent_name`を`module_parent`、`module_parents`、および`module_parent_name`に名前変更します。
（[プルリクエスト]（https://github.com/rails/rails/pull/34051））

* `ActiveSupport::ParameterFilter`を追加します。
（[プルリクエスト]（https://github.com/rails/rails/pull/34039））

* 浮動小数点数が期間に追加されたときに、秒数が完全な秒に丸められるバグを修正します。
（[プルリクエスト]（https://github.com/rails/rails/pull/34135））
* `ActiveSupport::HashWithIndifferentAccess`に`#to_options`を`#symbolize_keys`のエイリアスとして追加します。
（[プルリクエスト](https://github.com/rails/rails/pull/34360)）

* Concernに同じブロックが複数回含まれている場合には例外を発生させないようにします。
（[プルリクエスト](https://github.com/rails/rails/pull/34553)）

* `ActiveSupport::CacheStore#fetch_multi`に渡されたキーの順序を保持します。
（[プルリクエスト](https://github.com/rails/rails/pull/34700)）

* `String#safe_constantize`を修正して、大文字小文字が正しくない定数参照に対して`LoadError`をスローしないようにします。
（[プルリクエスト](https://github.com/rails/rails/pull/34892)）

* `Hash#deep_transform_values`と`Hash#deep_transform_values!`を追加します。
（[コミット](https://github.com/rails/rails/commit/b8dc06b8fdc16874160f61dcf58743fcc10e57db)）

* `ActiveSupport::HashWithIndifferentAccess#assoc`を追加します。
（[プルリクエスト](https://github.com/rails/rails/pull/35080)）

* `CurrentAttributes`に`before_reset`コールバックを追加し、`after_reset`を`resets`のエイリアスとして定義します。
（[プルリクエスト](https://github.com/rails/rails/pull/35063)）

* `ActiveSupport::Notifications.unsubscribe`を修正して、正規表現や他の複数のパターンのサブスクライバを正しく処理するようにします。
（[プルリクエスト](https://github.com/rails/rails/pull/32861)）

* Zeitwerkを使用した新しい自動読み込みメカニズムを追加します。
（[コミット](https://github.com/rails/rails/commit/e53430fa9af239e21e11548499d814f540d421e5)）

* `Array#including`と`Enumerable#including`を追加して、コレクションを便利に拡大します。
（[コミット](https://github.com/rails/rails/commit/bfaa3091c3c32b5980a614ef0f7b39cbf83f6db3)）

* `Array#without`と`Enumerable#without`を`Array#excluding`と`Enumerable#excluding`に名前変更します。古いメソッド名はエイリアスとして保持されます。
（[コミット](https://github.com/rails/rails/commit/bfaa3091c3c32b5980a614ef0f7b39cbf83f6db3)）

* `transliterate`と`parameterize`に`locale`を指定するサポートを追加します。
（[プルリクエスト](https://github.com/rails/rails/pull/35571)）

* `Time#advance`を修正して、1001-03-07より前の日付でも動作するようにします。
（[プルリクエスト](https://github.com/rails/rails/pull/35659)）

* `ActiveSupport::Notifications::Instrumenter#instrument`を更新して、ブロックを渡さないようにします。
（[プルリクエスト](https://github.com/rails/rails/pull/35705)）

* 匿名のサブクラスがガベージコレクションされるように、子孫トラッカーで弱い参照を使用します。
（[プルリクエスト](https://github.com/rails/rails/pull/31442)）

* `with_info_handler`メソッドを使用してテストメソッドを呼び出し、minitest-hooksプラグインを動作させるようにします。
（[コミット](https://github.com/rails/rails/commit/758ba117a008b6ea2d3b92c53b6a7a8d7ccbca69)）

* `ActiveSupport::SafeBuffer#*`で`html_safe?`の状態を保持します。
（[プルリクエスト](https://github.com/rails/rails/pull/36012)）

Active Job
----------

詳細な変更については、[Changelog][active-job]を参照してください。

### 削除

* Qu gemのサポートを削除します。
（[プルリクエスト](https://github.com/rails/rails/pull/32300)）

### 廃止予定

### 注目すべき変更

* Active Job引数のカスタムシリアライザのサポートを追加します。
（[プルリクエスト](https://github.com/rails/rails/pull/30941)）

* ジョブがエンキューされたタイムゾーンでActive Jobsを実行するサポートを追加します。
（[プルリクエスト](https://github.com/rails/rails/pull/32085)）

* `retry_on`/`discard_on`に複数の例外を渡すことを許可します。
（[コミット](https://github.com/rails/rails/commit/3110caecbebdad7300daaf26bfdff39efda99e25)）

* ブロックなしで`assert_enqueued_with`と`assert_enqueued_email_with`を呼び出すことを許可します。
（[プルリクエスト](https://github.com/rails/rails/pull/33258)）

* `enqueue`と`enqueue_at`の通知を`after_enqueue`コールバックではなく、`around_enqueue`コールバックでラップします。
（[プルリクエスト](https://github.com/rails/rails/pull/33171)）

* ブロックなしで`perform_enqueued_jobs`を呼び出すことを許可します。
（[プルリクエスト](https://github.com/rails/rails/pull/33626)）

* ブロックなしで`assert_performed_with`を呼び出すことを許可します。
（[プルリクエスト](https://github.com/rails/rails/pull/33635)）

* ジョブのアサーションとヘルパーに`queue`オプションを追加します。
（[プルリクエスト](https://github.com/rails/rails/pull/33635)）

* リトライと破棄の周りでActive Jobにフックを追加します。
（[プルリクエスト](https://github.com/rails/rails/pull/33751)）

* ジョブを実行する際に引数のサブセットをテストする方法を追加します。
（[プルリクエスト](https://github.com/rails/rails/pull/33995)）

* Active Jobのテストヘルパーでシリアライズされた引数を含めるようにします。
（[プルリクエスト](https://github.com/rails/rails/pull/34204)）

* Active Jobのアサーションヘルパーが`only`キーワードに対してProcを受け入れるようにします。
（[プルリクエスト](https://github.com/rails/rails/pull/34339)）

* アサーションヘルパーのジョブ引数からマイクロ秒とナノ秒を削除します。
（[プルリクエスト](https://github.com/rails/rails/pull/35713)）

Ruby on Railsガイド
--------------------

詳細な変更については、[Changelog][guides]を参照してください。

[active-job]: https://github.com/rails/rails/blob/master/activerecord/CHANGELOG.md
[guides]: https://github.com/rails/rails/blob/master/guides/CHANGELOG.md
### 注目すべき変更点

*   Active Recordガイドに複数のデータベースを追加します。
    ([プルリクエスト](https://github.com/rails/rails/pull/36389))

*   定数の自動読み込みのトラブルシューティングについてのセクションを追加します。
    ([コミット](https://github.com/rails/rails/commit/c03bba4f1f03bad7dc034af555b7f2b329cf76f5))

*   Action Mailbox Basicsガイドを追加します。
    ([プルリクエスト](https://github.com/rails/rails/pull/34812))

*   Action Text Overviewガイドを追加します。
    ([プルリクエスト](https://github.com/rails/rails/pull/34878))

クレジット
-------

Railsを安定かつ堅牢なフレームワークにするために多くの人々が多くの時間を費やしたことについては、
[Railsへの貢献者の完全なリスト](https://contributors.rubyonrails.org/)
を参照してください。彼ら全員に敬意を表します。

[railties]:       https://github.com/rails/rails/blob/6-0-stable/railties/CHANGELOG.md
[action-pack]:    https://github.com/rails/rails/blob/6-0-stable/actionpack/CHANGELOG.md
[action-view]:    https://github.com/rails/rails/blob/6-0-stable/actionview/CHANGELOG.md
[action-mailer]:  https://github.com/rails/rails/blob/6-0-stable/actionmailer/CHANGELOG.md
[action-cable]:   https://github.com/rails/rails/blob/6-0-stable/actioncable/CHANGELOG.md
[active-record]:  https://github.com/rails/rails/blob/6-0-stable/activerecord/CHANGELOG.md
[active-model]:   https://github.com/rails/rails/blob/6-0-stable/activemodel/CHANGELOG.md
[active-job]:     https://github.com/rails/rails/blob/6-0-stable/activejob/CHANGELOG.md
[guides]:         https://github.com/rails/rails/blob/6-0-stable/guides/CHANGELOG.md
[active-storage]: https://github.com/rails/rails/blob/6-0-stable/activestorage/CHANGELOG.md
[active-support]: https://github.com/rails/rails/blob/6-0-stable/activesupport/CHANGELOG.md
