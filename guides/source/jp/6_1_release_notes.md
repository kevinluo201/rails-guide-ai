**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 1d652e6ccda9c901ca3f6a003c95f83e
Ruby on Rails 6.1 リリースノート
===============================

Rails 6.1 のハイライト：

* データベースごとの接続切り替え
* 水平シャーディング
* 厳密な関連の読み込み
* 委譲型
* 非同期での関連の削除

これらのリリースノートでは、主要な変更のみをカバーしています。さまざまなバグ修正や変更については、変更ログを参照するか、GitHub のメイン Rails リポジトリの[コミットのリスト](https://github.com/rails/rails/commits/6-1-stable)をチェックしてください。

--------------------------------------------------------------------------------

Rails 6.1 へのアップグレード
----------------------

既存のアプリケーションをアップグレードする場合は、アップグレードする前に十分なテストカバレッジを持つことが重要です。また、Rails 6.1 への更新を試みる前に、まず Rails 6.0 にアップグレードし、アプリケーションが正常に動作することを確認してください。アップグレード時に注意するべき事項のリストは、[Ruby on Rails のアップグレード](upgrading_ruby_on_rails.html#upgrading-from-rails-6-0-to-rails-6-1)ガイドで確認できます。

主要な機能
--------------

### データベースごとの接続切り替え

Rails 6.1 では、[データベースごとの接続切り替え](https://github.com/rails/rails/pull/40370)が可能になりました。6.0 では、`reading` ロールに切り替えると、すべてのデータベース接続も読み取りロールに切り替わってしまいました。しかし、6.1 では設定で `legacy_connection_handling` を `false` に設定すると、対応する抽象クラスで `connected_to` を呼び出すことで、単一のデータベースの接続を切り替えることができるようになります。

### 水平シャーディング

Rails 6.0 では、データベースを機能的にパーティション分割（複数のパーティション、異なるスキーマ）することができましたが、水平シャーディング（同じスキーマ、複数のパーティション）をサポートすることはできませんでした。Rails では、Active Record のモデルはクラスごとに1つの接続しか持つことができなかったため、水平シャーディングをサポートすることができませんでした。しかし、これは修正され、Rails で[水平シャーディング](https://github.com/rails/rails/pull/38531)が利用可能になりました。

### 厳密な関連の読み込み

[厳密な関連の読み込み](https://github.com/rails/rails/pull/37400)では、すべての関連を積極的に読み込み、N+1問題を発生させる前に停止することができます。

### 委譲型

[委譲型](https://github.com/rails/rails/pull/39341)は、単一テーブル継承の代替手段です。これにより、スーパークラスを独自のテーブルで表現することができる具体的なクラスのクラス階層を表現するのに役立ちます。各サブクラスには、追加の属性のために独自のテーブルがあります。

### 非同期での関連の削除

[非同期での関連の削除](https://github.com/rails/rails/pull/40157)により、アプリケーションで関連をバックグラウンドジョブで「削除」することができるようになりました。これにより、データを削除する際にタイムアウトやその他のパフォーマンスの問題を回避することができます。

Railties
--------

詳細な変更については、[Changelog][railties]を参照してください。

### 削除

*   廃止予定の `rake notes` タスクを削除しました。

*   `rails dbconsole` コマンドの `connection` オプションを廃止しました。

*   `rails notes` から `SOURCE_ANNOTATION_DIRECTORIES` 環境変数のサポートを廃止しました。

*   `rails server` コマンドから廃止予定の `server` 引数を削除しました。

*   サーバー IP を指定するために `HOST` 環境変数を使用するサポートを廃止しました。

*   廃止予定の `rake dev:cache` タスクを削除しました。

*   廃止予定の `rake routes` タスクを削除しました。

*   廃止予定の `rake initializers` タスクを削除しました。

### 廃止予定

### 注目すべき変更

Action Cable
------------

詳細な変更については、[Changelog][action-cable]を参照してください。

### 削除

### 廃止予定

### 注目すべき変更

Action Pack
-----------

詳細な変更については、[Changelog][action-pack]を参照してください。

### 削除

*   `ActionDispatch::Http::ParameterFilter` を廃止しました。

*   コントローラーレベルでの `force_ssl` を廃止しました。

### 廃止予定

*   `config.action_dispatch.return_only_media_type_on_content_type` を廃止しました。

### 注目すべき変更

*   `ActionDispatch::Response#content_type` をフルの Content-Type ヘッダーを返すように変更しました。

Action View
-----------

詳細な変更については、[Changelog][action-view]を参照してください。

### 削除

*   `ActionView::Template::Handlers::ERB` の `escape_whitelist` を廃止しました。

*   `ActionView::Resolver` の `find_all_anywhere` を廃止しました。

*   `ActionView::Template::HTML` の `formats` を廃止しました。

*   `ActionView::Template::RawFile` の `formats` を廃止しました。

*   `ActionView::Template::Text` の `formats` を廃止しました。

*   `ActionView::PathSet` の `find_file` を廃止しました。

*   `ActionView::LookupContext` の `rendered_format` を廃止しました。

*   `ActionView::ViewPaths` の `find_file` を廃止しました。

*   `ActionView::Base#initialize` の最初の引数に `ActionView::LookupContext` ではないオブジェクトを渡すサポートを廃止しました。

*   `ActionView::Base#initialize` の `format` 引数を廃止しました。

*   `ActionView::Template#refresh` を廃止しました。

*   `ActionView::Template#original_encoding` を廃止しました。

*   `ActionView::Template#variants` を廃止しました。
* `ActionView::Template#formats`の非推奨化を削除します。

* `ActionView::Template#virtual_path=`の非推奨化を削除します。

* `ActionView::Template#updated_at`の非推奨化を削除します。

* `ActionView::Template#initialize`で必要な`updated_at`引数の非推奨化を削除します。

* `ActionView::Template.finalize_compiled_template_methods`の非推奨化を削除します。

* `config.action_view.finalize_compiled_template_methods`の非推奨化を削除します。

* ブロックを使用して`ActionView::ViewPaths#with_fallback`を呼び出すサポートの非推奨化を削除します。

* `render template:`に絶対パスを渡すサポートの非推奨化を削除します。

* `render file:`に相対パスを渡すサポートの非推奨化を削除します。

* 2つの引数を受け入れないテンプレートハンドラのサポートを削除します。

* `ActionView::Template::PathResolver`のパターン引数の非推奨化を削除します。

* 一部のビューヘルパーでオブジェクトからプライベートメソッドを呼び出すサポートを削除します。

### 非推奨化

### 注目すべき変更

* `ActionView::Base`のサブクラスが`#compiled_method_container`を実装する必要があるようにします。

* `ActionView::Template#initialize`で`locals`引数が必要になります。

* `javascript_include_tag`と`stylesheet_link_tag`のアセットヘルパーは、モダンなブラウザにアセットのプリロードに関するヒントを与える`Link`ヘッダーを生成します。これは、`config.action_view.preload_links_header`を`false`に設定することで無効にすることができます。

Action Mailer
-------------

詳細な変更については、[Changelog][action-mailer]を参照してください。

### 削除

* [Action Mailbox](https://github.com/rails/rails/tree/6-1-stable/actionmailbox)を利用するために、非推奨化された`ActionMailer::Base.receive`を削除します。

### 非推奨化

### 注目すべき変更

Active Record
-------------

詳細な変更については、[Changelog][active-record]を参照してください。

### 削除

* `ActiveRecord::ConnectionAdapters::DatabaseLimits`から非推奨化されたメソッドを削除します。

    `column_name_length`
    `table_name_length`
    `columns_per_table`
    `indexes_per_table`
    `columns_per_multicolumn_index`
    `sql_query_length`
    `joins_per_query`

* `ActiveRecord::ConnectionAdapters::AbstractAdapter#supports_multi_insert?`の非推奨化を削除します。

* `ActiveRecord::ConnectionAdapters::AbstractAdapter#supports_foreign_keys_in_create?`の非推奨化を削除します。

* `ActiveRecord::ConnectionAdapters::PostgreSQLAdapter#supports_ranges?`の非推奨化を削除します。

* `ActiveRecord::Base#update_attributes`と`ActiveRecord::Base#update_attributes!`の非推奨化を削除します。

* `ActiveRecord::ConnectionAdapter::SchemaStatements#assume_migrated_upto_version`での非推奨化された`migrations_path`引数を削除します。

* `config.active_record.sqlite3.represent_boolean_as_integer`の非推奨化を削除します。

* `ActiveRecord::DatabaseConfigurations`から非推奨化されたメソッドを削除します。

    `fetch`
    `each`
    `first`
    `values`
    `[]=`

* `ActiveRecord::Result#to_hash`メソッドの非推奨化を削除します。

* `ActiveRecord::Relation`のメソッドで安全でない生のSQLを使用するサポートの非推奨化を削除します。

### 非推奨化

* `ActiveRecord::Base.allow_unsafe_raw_sql`を非推奨化します。

* `connected_to`の`database`キーワード引数を非推奨化します。

* `legacy_connection_handling`がfalseに設定されている場合、`connection_handlers`を非推奨化します。

### 注目すべき変更

* MySQL: ユニーク性のバリデータは、デフォルトのデータベースの照合順序を尊重し、デフォルトでは大文字と小文字を区別しない比較を強制しません。

* `relation.create`は、初期化ブロックとコールバックでクラスレベルのクエリメソッドにスコープを漏洩させなくなります。

    Before:

    ```ruby
    User.where(name: "John").create do |john|
      User.find_by(name: "David") # => nil
    end
    ```

    After:

    ```ruby
    User.where(name: "John").create do |john|
      User.find_by(name: "David") # => #<User name: "David", ...>
    end
    ```

* 名前付きスコープチェーンは、クラスレベルのクエリメソッドにスコープを漏洩させなくなります。

    ```ruby
    class User < ActiveRecord::Base
      scope :david, -> { User.where(name: "David") }
    end
    ```

    Before:

    ```ruby
    User.where(name: "John").david
    # SELECT * FROM users WHERE name = 'John' AND name = 'David'
    ```

    After:

    ```ruby
    User.where(name: "John").david
    # SELECT * FROM users WHERE name = 'David'
    ```

* `where.not`は、NORではなくNAND述語を生成するようになりました。

    Before:

    ```ruby
    User.where.not(name: "Jon", role: "admin")
    # SELECT * FROM users WHERE name != 'Jon' AND role != 'admin'
    ```

    After:

    ```ruby
    User.where.not(name: "Jon", role: "admin")
    # SELECT * FROM users WHERE NOT (name = 'Jon' AND role = 'admin')
    ```

* パーデータベースの接続ハンドリングを使用するには、`legacy_connection_handling`をfalseに変更し、`connection_handlers`の非推奨化されたアクセサを削除する必要があります。`connects_to`と`connected_to`のパブリックメソッドには変更は必要ありません。

Active Storage
--------------

詳細な変更については、[Changelog][active-storage]を参照してください。

### 削除

* `ActiveStorage::Transformers::ImageProcessing`に`combine_options`操作を渡すサポートを削除します。

* `ActiveStorage::Transformers::MiniMagickTransformer`の非推奨化を削除します。

* `config.active_storage.queue`の非推奨化を削除します。

* `ActiveStorage::Downloading`の非推奨化を削除します。

### 非推奨化

* `Blob.create_after_upload`を`Blob.create_and_upload`に非推奨化します。
    ([Pull Request](https://github.com/rails/rails/pull/34827))

### 注目すべき変更

* `Blob.create_and_upload`を追加し、指定された`io`をサービスにアップロードする新しいblobを作成します。
    ([Pull Request](https://github.com/rails/rails/pull/34827))
* `ActiveStorage::Blob#service_name`カラムが追加されました。アップグレード後にマイグレーションを実行する必要があります。そのマイグレーションを生成するには、`bin/rails app:update`を実行してください。

Active Model
------------

詳細な変更については、[Changelog][active-model]を参照してください。

### 削除

### 非推奨化

### 注目すべき変更

* Active Modelのエラーは、モデルによってスローされるエラーをより簡単に処理および操作できるインターフェースを持つオブジェクトになりました。
    [この機能](https://github.com/rails/rails/pull/32313)には、クエリインターフェース、より正確なテスト、エラーの詳細へのアクセスが含まれています。
Active Support
--------------

詳細な変更については、[変更履歴][active-support]を参照してください。

### 削除

*   `config.i18n.fallbacks` が空の場合に `I18n.default_locale` への非推奨なフォールバックを削除しました。

*   非推奨な `LoggerSilence` 定数を削除しました。

*   非推奨な `ActiveSupport::LoggerThreadSafeLevel#after_initialize` を削除しました。

*   非推奨な `Module#parent_name`、`Module#parent`、`Module#parents` を削除しました。

*   非推奨なファイル `active_support/core_ext/module/reachable` を削除しました。

*   非推奨なファイル `active_support/core_ext/numeric/inquiry` を削除しました。

*   非推奨なファイル `active_support/core_ext/array/prepend_and_append` を削除しました。

*   非推奨なファイル `active_support/core_ext/hash/compact` を削除しました。

*   非推奨なファイル `active_support/core_ext/hash/transform_values` を削除しました。

*   非推奨なファイル `active_support/core_ext/range/include_range` を削除しました。

*   非推奨な `ActiveSupport::Multibyte::Chars#consumes?` と `ActiveSupport::Multibyte::Chars#normalize` を削除しました。

*   非推奨な `ActiveSupport::Multibyte::Unicode.pack_graphemes`、
    `ActiveSupport::Multibyte::Unicode.unpack_graphemes`、
    `ActiveSupport::Multibyte::Unicode.normalize`、
    `ActiveSupport::Multibyte::Unicode.downcase`、
    `ActiveSupport::Multibyte::Unicode.upcase`、
    `ActiveSupport::Multibyte::Unicode.swapcase` を削除しました。

*   非推奨な `ActiveSupport::Notifications::Instrumenter#end=` を削除しました。

### 廃止予定

*   `ActiveSupport::Multibyte::Unicode.default_normalization_form` を廃止予定にしました。

### 注目すべき変更

Active Job
----------

詳細な変更については、[変更履歴][active-job]を参照してください。

### 削除

### 廃止予定

*   `config.active_job.return_false_on_aborted_enqueue` を廃止予定にしました。

### 注目すべき変更

*   ジョブのエンキューが中止された場合に `false` を返すようになりました。

Action Text
----------

詳細な変更については、[変更履歴][action-text]を参照してください。

### 削除

### 廃止予定

### 注目すべき変更

*   リッチテキスト属性の名前の後に `?` を追加することで、リッチテキストコンテンツの存在を確認するメソッドを追加しました。
    ([プルリクエスト](https://github.com/rails/rails/pull/37951))

*   システムテストケースヘルパー `fill_in_rich_text_area` を追加し、指定されたHTMLコンテンツでtrixエディタを検索して埋めることができるようにしました。
    ([プルリクエスト](https://github.com/rails/rails/pull/35885))

*   データベースフィクスチャで `<action-text-attachment>` 要素を生成するための `ActionText::FixtureSet.attachment` を追加しました。
    ([プルリクエスト](https://github.com/rails/rails/pull/40289))

Action Mailbox
----------

詳細な変更については、[変更履歴][action-mailbox]を参照してください。

### 削除

### 廃止予定

*   `Rails.application.credentials.action_mailbox.api_key` と `MAILGUN_INGRESS_API_KEY` を `Rails.application.credentials.action_mailbox.signing_key` と `MAILGUN_INGRESS_SIGNING_KEY` に置き換えるために、`Rails.application.credentials.action_mailbox.api_key` と `MAILGUN_INGRESS_API_KEY` を廃止予定にしました。

### 注目すべき変更

Ruby on Rails Guides
--------------------

詳細な変更については、[変更履歴][guides]を参照してください。

### 注目すべき変更

クレジット
-------

Railsに多くの時間を費やして安定かつ堅牢なフレームワークにした多くの人々に感謝します。
[Railsへの貢献者の完全なリスト](https://contributors.rubyonrails.org/)
を参照して、彼ら全員に敬意を表します。

[railties]:       https://github.com/rails/rails/blob/6-1-stable/railties/CHANGELOG.md
[action-pack]:    https://github.com/rails/rails/blob/6-1-stable/actionpack/CHANGELOG.md
[action-view]:    https://github.com/rails/rails/blob/6-1-stable/actionview/CHANGELOG.md
[action-mailer]:  https://github.com/rails/rails/blob/6-1-stable/actionmailer/CHANGELOG.md
[action-cable]:   https://github.com/rails/rails/blob/6-1-stable/actioncable/CHANGELOG.md
[active-record]:  https://github.com/rails/rails/blob/6-1-stable/activerecord/CHANGELOG.md
[active-model]:   https://github.com/rails/rails/blob/6-1-stable/activemodel/CHANGELOG.md
[active-job]:     https://github.com/rails/rails/blob/6-1-stable/activejob/CHANGELOG.md
[action-text]:    https://github.com/rails/rails/blob/6-1-stable/actiontext/CHANGELOG.md
[guides]:         https://github.com/rails/rails/blob/6-1-stable/guides/CHANGELOG.md
[active-storage]: https://github.com/rails/rails/blob/6-1-stable/activestorage/CHANGELOG.md
[active-support]: https://github.com/rails/rails/blob/6-1-stable/activesupport/CHANGELOG.md
[action-mailbox]: https://github.com/rails/rails/blob/6-1-stable/actionmailbox/CHANGELOG.md
