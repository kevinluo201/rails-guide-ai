**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 95d91c83726e012162afc60c78688099
Ruby on Rails 4.1 リリースノート
===============================

Rails 4.1 のハイライト：

* Spring アプリケーションプリローダー
* `config/secrets.yml`
* Action Pack のバリアント
* Action Mailer プレビュー

これらのリリースノートは主な変更のみをカバーしています。さまざまなバグ修正や変更については、変更ログを参照するか、GitHub のメイン Rails リポジトリの[コミットのリスト](https://github.com/rails/rails/commits/4-1-stable)を確認してください。

--------------------------------------------------------------------------------

Rails 4.1 へのアップグレード
----------------------

既存のアプリケーションをアップグレードする場合は、テストカバレッジが十分であることが重要です。また、Rails 4.1 にアップデートする前に、まず Rails 4.0 にアップグレードし、アプリケーションが正常に動作することを確認してからアップデートを試みることをお勧めします。アップグレード時に注意すべき事項のリストは、[Upgrading Ruby on Rails](upgrading_ruby_on_rails.html#upgrading-from-rails-4-0-to-rails-4-1)ガイドで入手できます。


主な機能
--------------

### Spring アプリケーションプリローダー

Spring は Rails アプリケーションのプリローダーです。テスト、rake タスク、マイグレーションを実行するたびにアプリケーションを起動する必要がなく、アプリケーションをバックグラウンドで実行しておくことで開発を高速化します。

新しい Rails 4.1 アプリケーションには「springified」な binstub が付属しています。つまり、`bin/rails` と `bin/rake` は自動的にプリロードされた spring 環境を利用するようになります。

**rake タスクの実行:**

```bash
$ bin/rake test:models
```

**Rails コマンドの実行:**

```bash
$ bin/rails console
```

**Spring の状態確認:**

```bash
$ bin/spring status
Spring is running:

 1182 spring server | my_app | started 29 mins ago
 3656 spring app    | my_app | started 23 secs ago | test mode
 3746 spring app    | my_app | started 10 secs ago | development mode
```

利用可能なすべての機能については、[Spring README](https://github.com/rails/spring/blob/master/README.md)を参照してください。

既存のアプリケーションをこの機能を使用するように移行する方法については、[Upgrading Ruby on Rails](upgrading_ruby_on_rails.html#spring)ガイドを参照してください。

### `config/secrets.yml`

Rails 4.1 では、`config` フォルダに新しい `secrets.yml` ファイルが生成されます。デフォルトでは、このファイルにはアプリケーションの `secret_key_base` が含まれていますが、外部の API のアクセスキーなど、他の秘密情報を保存するためにも使用できます。

このファイルに追加された秘密情報は、`Rails.application.secrets` を介してアクセスできます。たとえば、次のような `config/secrets.yml` の場合：

```yaml
development:
  secret_key_base: 3b7cd727ee24e8444053437c36cc66c3
  some_api_key: SOMEKEY
```

`Rails.application.secrets.some_api_key` は、開発環境では `SOMEKEY` を返します。

既存のアプリケーションをこの機能を使用するように移行する方法については、[Upgrading Ruby on Rails](upgrading_ruby_on_rails.html#config-secrets-yml)ガイドを参照してください。

### Action Pack のバリアント

私たちはしばしば、電話、タブレット、デスクトップブラウザ向けに異なる HTML/JSON/XML テンプレートをレンダリングしたいと思います。バリアントを使用すると簡単に実現できます。

リクエストのバリアントは、`:tablet`、`:phone`、`:desktop` のようなリクエストフォーマットの特殊化です。

`before_action` でバリアントを設定できます：

```ruby
request.variant = :tablet if request.user_agent =~ /iPad/
```

アクション内でフォーマットと同様にバリアントに応じてレスポンスを返すことができます：

```ruby
respond_to do |format|
  format.html do |html|
    html.tablet # app/views/projects/show.html+tablet.erb をレンダリング
    html.phone { extra_setup; render ... }
  end
end
```

各フォーマットとバリアントに対して別々のテンプレートを用意できます：

```
app/views/projects/show.html.erb
app/views/projects/show.html+tablet.erb
app/views/projects/show.html+phone.erb
```

インライン構文を使用してバリアントの定義を簡素化することもできます：

```ruby
respond_to do |format|
  format.js         { render "trash" }
  format.html.phone { redirect_to progress_path }
  format.html.none  { render "trash" }
end
```
### Action Mailer プレビュー

Action Mailer プレビューは、特別な URL を訪れることでメールの表示を確認する方法を提供します。

メールオブジェクトを確認したいプレビュークラスを実装します。

```ruby
class NotifierPreview < ActionMailer::Preview
  def welcome
    Notifier.welcome(User.first)
  end
end
```

プレビューは http://localhost:3000/rails/mailers/notifier/welcome で利用でき、一覧は http://localhost:3000/rails/mailers で確認できます。

デフォルトでは、これらのプレビュークラスは `test/mailers/previews` に存在します。
`preview_path` オプションを使用してこれを設定することができます。

詳細な説明については、[ドキュメント](https://api.rubyonrails.org/v4.1.0/classes/ActionMailer/Base.html#class-ActionMailer::Base-label-Previewing+emails)を参照してください。

### Active Record enums

データベース内の整数にマップされる値を持つ enum 属性を宣言し、名前でクエリを行うことができます。

```ruby
class Conversation < ActiveRecord::Base
  enum status: [ :active, :archived ]
end

conversation.archived!
conversation.active? # => false
conversation.status  # => "archived"

Conversation.archived # => 全てのアーカイブされた Conversation の関連

Conversation.statuses # => { "active" => 0, "archived" => 1 }
```

詳細な説明については、[ドキュメント](https://api.rubyonrails.org/v4.1.0/classes/ActiveRecord/Enum.html)を参照してください。

### Message Verifiers

メッセージ検証子を使用して、署名付きメッセージを生成および検証することができます。これは、remember-me トークンや友達などの機密データを安全に転送するために役立ちます。

`Rails.application.message_verifier` メソッドは、secret_key_base と指定されたメッセージ検証子名から派生したキーでメッセージに署名する新しいメッセージ検証子を返します。

```ruby
signed_token = Rails.application.message_verifier(:remember_me).generate(token)
Rails.application.message_verifier(:remember_me).verify(signed_token) # => token

Rails.application.message_verifier(:remember_me).verify(tampered_token)
# ActiveSupport::MessageVerifier::InvalidSignature が発生します
```

### Module#concerning

クラス内の責任を分離するための自然で簡単な方法です。

```ruby
class Todo < ActiveRecord::Base
  concerning :EventTracking do
    included do
      has_many :events
    end

    def latest_event
      # ...
    end

    private
      def some_internal_method
        # ...
      end
  end
end
```

この例は、`EventTracking` モジュールをインラインで定義し、`ActiveSupport::Concern` で拡張し、`Todo` クラスにミックスインすることと等価です。

詳細な説明と使用例については、[ドキュメント](https://api.rubyonrails.org/v4.1.0/classes/Module/Concerning.html)を参照してください。

### CSRF 保護とリモート `<script>` タグからの攻撃

クロスサイトリクエストフォージェリ（CSRF）保護は、JavaScript レスポンスを伴う GET リクエストにも適用されるようになりました。これにより、第三者のサイトが JavaScript URL を参照し、それを実行して機密データを抽出しようとすることを防止します。

これは、`.js` URL を使用するテストのうち、CSRF 保護が失敗するようになります。これらのテストでは、`xhr` を使用するように明示的に指定する必要があります。`post :create, format: :js` の代わりに、明示的な `xhr :post, :create, format: :js` に切り替えてください。


Railties
--------

詳細な変更については、[Changelog](https://github.com/rails/rails/blob/4-1-stable/railties/CHANGELOG.md) を参照してください。

### 削除された機能

* `update:application_controller` の rake タスクが削除されました。

* 廃止予定の `Rails.application.railties.engines` が削除されました。

* 廃止予定の `threadsafe!` が Rails Config から削除されました。

* 廃止予定の `ActiveRecord::Generators::ActiveModel#update_attributes` が `ActiveRecord::Generators::ActiveModel#update` に置き換えられました。

* 廃止予定の `config.whiny_nils` オプションが削除されました。

* テストを実行するための廃止予定の rake タスク `rake test:uncommitted` および `rake test:recent` が削除されました。

### 注目すべき変更点

* 新しいアプリケーションでは、[Spring アプリケーションプリローダー](https://github.com/rails/spring)がデフォルトでインストールされます。これは `Gemfile` の development グループを使用するため、本番環境ではインストールされません。 ([Pull Request](https://github.com/rails/rails/pull/12958))

* `BACKTRACE` 環境変数を使用して、テストの失敗時にフィルターされていないバックトレースを表示できるようになりました。 ([Commit](https://github.com/rails/rails/commit/84eac5dab8b0fe9ee20b51250e52ad7bfea36553))

* 環境設定で `MiddlewareStack#unshift` を公開しました。 ([Pull Request](https://github.com/rails/rails/pull/12479))

* `Application#message_verifier` メソッドを追加し、メッセージ検証子を返すようにしました。 ([Pull Request](https://github.com/rails/rails/pull/12995))

* デフォルトで生成されるテストヘルパーによって必要な場合にのみ、テストデータベースが `db/schema.rb`（または `db/structure.sql`）と同期されるようになりました。スキーマの再読み込みがすべての保留中のマイグレーションを解決しない場合はエラーが発生します。`config.active_record.maintain_test_schema = false` で無効にすることもできます。 ([Pull Request](https://github.com/rails/rails/pull/13528))
* `Rails.gem_version`を導入し、`Gem::Version.new(Rails.version)`を返す便利なメソッドとして紹介し、バージョン比較をより信頼性のある方法として提案します。([プルリクエスト](https://github.com/rails/rails/pull/14103))

Action Pack
-----------

詳細な変更については、[Changelog](https://github.com/rails/rails/blob/4-1-stable/actionpack/CHANGELOG.md)を参照してください。

### 削除

* 統合テストのための非推奨のRailsアプリケーションのフォールバックを削除し、代わりに`ActionDispatch.test_app`を設定しました。

* 非推奨の`page_cache_extension`設定を削除しました。

* 非推奨の`ActionController::RecordIdentifier`を削除し、代わりに`ActionView::RecordIdentifier`を使用してください。

* Action Controllerから非推奨の定数を削除しました:

| 削除されたもの                     | 後継                             |
|:-----------------------------------|:--------------------------------|
| ActionController::AbstractRequest  | ActionDispatch::Request         |
| ActionController::Request          | ActionDispatch::Request         |
| ActionController::AbstractResponse | ActionDispatch::Response        |
| ActionController::Response         | ActionDispatch::Response        |
| ActionController::Routing          | ActionDispatch::Routing         |
| ActionController::Integration      | ActionDispatch::Integration     |
| ActionController::IntegrationTest  | ActionDispatch::IntegrationTest |

### 注目すべき変更

* `protect_from_forgery`はクロスオリジンの`<script>`タグも防止します。テストでは`xhr :get, :foo, format: :js`を使用してください。`get :foo, format: :js`の代わりに。([プルリクエスト](https://github.com/rails/rails/pull/13345))

* `#url_for`はオプションを含むハッシュを配列の内部に取ります。([プルリクエスト](https://github.com/rails/rails/pull/9599))

* `session#fetch`メソッドを追加しました。fetchは[Hash#fetch](https://www.ruby-doc.org/core-1.9.3/Hash.html#method-i-fetch)と同様に動作しますが、返された値は常にセッションに保存されます。([プルリクエスト](https://github.com/rails/rails/pull/12692))

* Action ViewをAction Packから完全に分離しました。([プルリクエスト](https://github.com/rails/rails/pull/11032))

* ディープマージによって影響を受けたキーをログに記録します。([プルリクエスト](https://github.com/rails/rails/pull/13813))

* セキュリティの脆弱性CVE-2013-0155に対処するために使用されたパラメータの「ディープマージ」をオプトアウトするための新しい設定オプション`config.action_dispatch.perform_deep_munge`を追加しました。([プルリクエスト](https://github.com/rails/rails/pull/13188))

* 署名付きおよび暗号化されたクッキージャーのシリアライザを指定するための新しい設定オプション`config.action_dispatch.cookies_serializer`を追加しました。([プルリクエスト1](https://github.com/rails/rails/pull/13692)、[プルリクエスト2](https://github.com/rails/rails/pull/13945) / [詳細](upgrading_ruby_on_rails.html#cookies-serializer))

* `render :plain`、`render :html`、`render :body`を追加しました。([プルリクエスト](https://github.com/rails/rails/pull/14062) / [詳細](upgrading_ruby_on_rails.html#rendering-content-from-string))


Action Mailer
-------------

詳細な変更については、[Changelog](https://github.com/rails/rails/blob/4-1-stable/actionmailer/CHANGELOG.md)を参照してください。

### 注目すべき変更

* 37 Signalsのmail_view gemに基づいたメーラープレビュー機能を追加しました。([コミット](https://github.com/rails/rails/commit/d6dec7fcb6b8fddf8c170182d4fe64ecfc7b2261))

* Action Mailerメッセージの生成を計測するためのインストゥルメントを追加しました。メッセージの生成にかかる時間がログに記録されます。([プルリクエスト](https://github.com/rails/rails/pull/12556))


Active Record
-------------

詳細な変更については、[Changelog](https://github.com/rails/rails/blob/4-1-stable/activerecord/CHANGELOG.md)を参照してください。

### 削除

* `SchemaCache`の以下のメソッドに対する非推奨のnilパラメータを削除しました: `primary_keys`、`tables`、`columns`、`columns_hash`。

* `ActiveRecord::Migrator#migrate`からブロックフィルタを削除しました。

* `ActiveRecord::Migrator`から非推奨のStringコンストラクタを削除しました。

* 呼び出し可能なオブジェクトを渡さずに`scope`を使用する非推奨の使用を削除しました。

* `transaction_joinable=`を非推奨とし、`begin_transaction`に`:joinable`オプションを使用するようにしました。

* `decrement_open_transactions`を非推奨としました。

* `increment_open_transactions`を非推奨としました。

* `PostgreSQLAdapter#outside_transaction?`メソッドを非推奨としました。代わりに`#transaction_open?`を使用してください。

* `ActiveRecord::Fixtures.find_table_name`を非推奨とし、`ActiveRecord::Fixtures.default_fixture_model_name`を使用してください。

* `SchemaStatements`から`columns_for_remove`を非推奨としました。

* `SchemaStatements#distinct`を非推奨としました。

* `ActiveRecord::TestCase`をRailsのテストスイートに移動しました。このクラスはもはや公開されておらず、内部のRailsテストにのみ使用されます。

* 関連付けにおける非推奨オプション`:restrict`のサポートを削除しました。

* 関連付けにおける非推奨な`delete_sql`、`insert_sql`、`finder_sql`、`counter_sql`オプションのサポートを削除しました。

* Columnから非推奨な`type_cast_code`メソッドを削除しました。

* `ActiveRecord::Base#connection`メソッドの非推奨警告を削除しました。クラス経由でアクセスしてください。

* `auto_explain_threshold_in_seconds`の非推奨警告を削除しました。

* `Relation#count`から非推奨の`:distinct`オプションを削除しました。

* `partial_updates`、`partial_updates?`、`partial_updates=`メソッドを非推奨としました。

* `scoped`メソッドを非推奨としました。

* `default_scopes?`メソッドを非推奨としました。

* 4.0で非推奨となった暗黙の結合参照を削除しました。
* `activerecord-deprecated_finders`を依存関係から削除しました。
  詳細については、[gemのREADME](https://github.com/rails/activerecord-deprecated_finders#active-record-deprecated-finders)を参照してください。

* `implicit_readonly`の使用を削除しました。`readonly`メソッドを使用して、レコードを`readonly`として明示的にマークしてください。
  ([プルリクエスト](https://github.com/rails/rails/pull/10769)を参照してください)

### 廃止予定

* 使用されていない`quoted_locking_column`メソッドを廃止しました。

* `ConnectionAdapters::SchemaStatements#distinct`を廃止しました。
  インターナルで使用されなくなったためです。([プルリクエスト](https://github.com/rails/rails/pull/10556)を参照してください)

* `rake db:test:*`タスクを廃止しました。テストデータベースは自動的に管理されるようになりました。
  railtiesのリリースノートを参照してください。([プルリクエスト](https://github.com/rails/rails/pull/13528)を参照してください)

* 使用されていない`ActiveRecord::Base.symbolized_base_class`と`ActiveRecord::Base.symbolized_sti_name`を廃止しました。
  代替方法はありません。[コミット](https://github.com/rails/rails/commit/97e7ca48c139ea5cce2fa9b4be631946252a1ebd)を参照してください。

### 注目すべき変更点

* デフォルトスコープは、チェーンされた条件によって上書きされなくなりました。

  この変更前は、モデルで`default_scope`を定義すると、同じフィールドのチェーンされた条件によって上書きされました。これからは、他のスコープと同様にマージされます。[詳細はこちら](upgrading_ruby_on_rails.html#changes-on-default-scopes)。

* `ActiveRecord::Base.to_param`を追加し、モデルの属性またはメソッドから派生した便利な「pretty」URLを提供します。
  ([プルリクエスト](https://github.com/rails/rails/pull/12891)を参照してください)

* `ActiveRecord::Base.no_touching`を追加し、モデルのタッチを無視することができます。
  ([プルリクエスト](https://github.com/rails/rails/pull/12772)を参照してください)

* `MysqlAdapter`と`Mysql2Adapter`のブール型キャストを統一しました。
  `type_cast`は`true`に対して`1`を返し、`false`に対して`0`を返します。([プルリクエスト](https://github.com/rails/rails/pull/12425)を参照してください)

* `.unscope`は、`default_scope`で指定された条件を削除します。([コミット](https://github.com/rails/rails/commit/94924dc32baf78f13e289172534c2e71c9c8cade)を参照してください)

* 既存の名前付きwhere条件を上書きする`ActiveRecord::QueryMethods#rewhere`を追加しました。([コミット](https://github.com/rails/rails/commit/f950b2699f97749ef706c6939a84dfc85f0b05f2)を参照してください)

* `ActiveRecord::Base#cache_key`を拡張し、最も高いタイムスタンプ属性のリストをオプションとして受け取るようにしました。([コミット](https://github.com/rails/rails/commit/e94e97ca796c0759d8fcb8f946a3bbc60252d329)を参照してください)

* `ActiveRecord::Base#enum`を追加し、値がデータベース内の整数にマップされ、名前でクエリできる列挙型属性を宣言できるようにしました。([コミット](https://github.com/rails/rails/commit/db41eb8a6ea88b854bf5cd11070ea4245e1639c5)を参照してください)

* JSON値を書き込む際に型キャストするようにしました。これにより、データベースから読み取る値と一貫性があります。([プルリクエスト](https://github.com/rails/rails/pull/12643)を参照してください)

* hstore値を書き込む際に型キャストするようにしました。これにより、データベースから読み取る値と一貫性があります。
  ([コミット](https://github.com/rails/rails/commit/5ac2341fab689344991b2a4817bd2bc8b3edac9d)を参照してください)

* サードパーティのジェネレータで`next_migration_number`にアクセスできるようにしました。
  ([プルリクエスト](https://github.com/rails/rails/pull/12407)を参照してください)

* `update_attributes`を呼び出す際に、`nil`の引数が渡された場合には必ず`ArgumentError`をスローするようになりました。具体的には、渡された引数が`stringify_keys`に応答しない場合にエラーがスローされます。
  ([プルリクエスト](https://github.com/rails/rails/pull/9860)を参照してください)

* `CollectionAssociation#first`/`#last`（例：`has_many`）は、コレクション全体をロードするのではなく、`LIMIT`を使用して結果を取得するクエリを使用します。
  ([プルリクエスト](https://github.com/rails/rails/pull/12137)を参照してください)

* Active Recordモデルクラスの`inspect`は、新しい接続を初期化しません。つまり、データベースが存在しない場合に`inspect`を呼び出しても例外が発生しなくなります。
  ([プルリクエスト](https://github.com/rails/rails/pull/11014)を参照してください)

* `count`のカラム制限を削除し、SQLが無効な場合にはデータベースが例外を発生させるようにしました。
  ([プルリクエスト](https://github.com/rails/rails/pull/10710)を参照してください)

* Railsは、逆の関連を自動的に検出するようになりました。関連の`:inverse_of`オプションを設定しない場合、Active Recordはヒューリスティックに基づいて逆の関連を推測します。
  ([プルリクエスト](https://github.com/rails/rails/pull/10886)を参照してください)

* ActiveRecord::Relationでエイリアスのある属性を処理するようにしました。シンボルキーを使用する場合、Active Recordはエイリアスのある属性名をデータベースで使用される実際の列名に変換します。
  ([プルリクエスト](https://github.com/rails/rails/pull/7839)を参照してください)

* フィクスチャファイルのERBは、メインオブジェクトのコンテキストで評価されなくなりました。複数のフィクスチャで使用されるヘルパーメソッドは、`ActiveRecord::FixtureSet.context_class`に含まれるモジュールで定義する必要があります。
  ([プルリクエスト](https://github.com/rails/rails/pull/13022)を参照してください)

* RAILS_ENVが明示的に指定されている場合、テストデータベースの作成や削除は行いません。
  ([プルリクエスト](https://github.com/rails/rails/pull/13629)を参照してください)

* `Relation`にはもはや`#map!`や`#delete_if`などの変更メソッドがありません。これらのメソッドを使用する前に、`#to_a`を呼び出して`Array`に変換してください。
  ([プルリクエスト](https://github.com/rails/rails/pull/13314)を参照してください)
* `find_in_batches`、`find_each`、`Result#each`、および`Enumerable#index_by`は、サイズを計算できる`Enumerator`を返すようになりました。([プルリクエスト](https://github.com/rails/rails/pull/13938))

* `scope`、`enum`、および関連付けは、"危険な"名前の競合時に例外を発生させるようになりました。([プルリクエスト](https://github.com/rails/rails/pull/13450)、[プルリクエスト](https://github.com/rails/rails/pull/13896))

* `second`から`fifth`メソッドは、`first`ファインダーと同様に動作します。([プルリクエスト](https://github.com/rails/rails/pull/13757))

* `touch`が`after_commit`および`after_rollback`コールバックを発火するようになりました。([プルリクエスト](https://github.com/rails/rails/pull/12031))

* `sqlite >= 3.8.0`で部分インデックスを有効にしました。([プルリクエスト](https://github.com/rails/rails/pull/13350))

* `change_column_null`をrevertibleにしました。([コミット](https://github.com/rails/rails/commit/724509a9d5322ff502aefa90dd282ba33a281a96))

* マイグレーション後のスキーマダンプを無効にするフラグを追加しました。新しいアプリケーションのプロダクション環境ではデフォルトで`false`に設定されています。([プルリクエスト](https://github.com/rails/rails/pull/13948))

Active Model
------------

詳細な変更については、[Changelog](https://github.com/rails/rails/blob/4-1-stable/activemodel/CHANGELOG.md)を参照してください。

### 廃止予定

* `Validator#setup`を廃止しました。これはバリデータのコンストラクタで手動で行う必要があります。([コミット](https://github.com/rails/rails/commit/7d84c3a2f7ede0e8d04540e9c0640de7378e9b3a))

### 注目すべき変更

* `ActiveModel::Dirty`に`reset_changes`および`changes_applied`という新しいAPIメソッドを追加しました。これらは変更の状態を制御します。

* バリデーションを定義する際に複数のコンテキストを指定できるようになりました。([プルリクエスト](https://github.com/rails/rails/pull/13754))

* `attribute_changed?`は、属性が与えられた値に変更されたかどうかを確認するためにハッシュを受け入れるようになりました。`:from`および`:to`を指定します。([プルリクエスト](https://github.com/rails/rails/pull/13131))


Active Support
--------------

詳細な変更については、[Changelog](https://github.com/rails/rails/blob/4-1-stable/activesupport/CHANGELOG.md)を参照してください。

### 削除

* `MultiJSON`の依存関係を削除しました。その結果、`ActiveSupport::JSON.decode`は`MultiJSON`のオプションハッシュを受け入れなくなりました。([プルリクエスト](https://github.com/rails/rails/pull/10576) / [詳細はこちら](upgrading_ruby_on_rails.html#changes-in-json-handling))

* カスタムオブジェクトをJSONにエンコードするための`encode_json`フックのサポートを削除しました。この機能は[activesupport-json_encoder](https://github.com/rails/activesupport-json_encoder) gemに抽出されました。([関連するプルリクエスト](https://github.com/rails/rails/pull/12183) / [詳細はこちら](upgrading_ruby_on_rails.html#changes-in-json-handling))

* 廃止予定の`ActiveSupport::JSON::Variable`を削除しました。

* 廃止予定の`String#encoding_aware?`コア拡張(`core_ext/string/encoding`)を削除しました。

* 廃止予定の`Module#local_constant_names`を`Module#local_constants`に置き換えました。

* 廃止予定の`DateTime.local_offset`を`DateTime.civil_from_format`に置き換えました。

* 廃止予定の`Logger`コア拡張(`core_ext/logger.rb`)を削除しました。

* 廃止予定の`Time#time_with_datetime_fallback`、`Time#utc_time`、および`Time#local_time`を`Time#utc`および`Time#local`に置き換えました。

* 廃止予定の`Hash#diff`を削除しました。

* 廃止予定の`Date#to_time_in_current_zone`を`Date#in_time_zone`に置き換えました。

* 廃止予定の`Proc#bind`を削除しました。

* 廃止予定の`Array#uniq_by`および`Array#uniq_by!`をネイティブの`Array#uniq`および`Array#uniq!`に置き換えてください。

* 廃止予定の`ActiveSupport::BasicObject`は、`ActiveSupport::ProxyObject`を使用してください。

* 廃止予定の`BufferedLogger`は、`ActiveSupport::Logger`を使用してください。

* 廃止予定の`assert_present`および`assert_blank`メソッドは、`assert object.blank?`および`assert object.present?`を使用してください。

* フィルタオブジェクトの`#filter`メソッドを削除し、対応するメソッドを使用してください（例：`before`フィルタの場合は`#before`を使用）。

* デフォルトの不規則な単数形から複数形への変換ルールである'cow' => 'kine'を削除しました。([コミット](https://github.com/rails/rails/commit/c300dca9963bda78b8f358dbcb59cabcdc5e1dc9))

### 廃止予定

* `Numeric#{ago,until,since,from_now}`を廃止しました。ユーザーは明示的に値をAS::Durationに変換する必要があります。例：`5.ago` => `5.seconds.ago`([プルリクエスト](https://github.com/rails/rails/pull/12389))

* `active_support/core_ext/object/to_json`のrequireパスを廃止しました。代わりに`active_support/core_ext/object/json`をrequireしてください。([プルリクエスト](https://github.com/rails/rails/pull/12203))

* `ActiveSupport::JSON::Encoding::CircularReferenceError`を廃止しました。この機能は[activesupport-json_encoder](https://github.com/rails/activesupport-json_encoder) gemに抽出されました。([プルリクエスト](https://github.com/rails/rails/pull/12785) / [詳細はこちら](upgrading_ruby_on_rails.html#changes-in-json-handling))

* `ActiveSupport.encode_big_decimal_as_string`オプションを廃止しました。この機能は[activesupport-json_encoder](https://github.com/rails/activesupport-json_encoder) gemに抽出されました。([プルリクエスト](https://github.com/rails/rails/pull/13060) / [詳細はこちら](upgrading_ruby_on_rails.html#changes-in-json-handling))

* カスタム`BigDecimal`のシリアル化を廃止しました。([プルリクエスト](https://github.com/rails/rails/pull/13911))

### 注目すべき変更

* `ActiveSupport`のJSONエンコーダーは、純粋なRubyでのカスタムエンコーディングではなく、JSON gemを利用するように書き直されました。([プルリクエスト](https://github.com/rails/rails/pull/12183) / [詳細はこちら](upgrading_ruby_on_rails.html#changes-in-json-handling))

* JSON gemとの互換性が向上しました。([プルリクエスト](https://github.com/rails/rails/pull/12862) / [詳細はこちら](upgrading_ruby_on_rails.html#changes-in-json-handling))

* `ActiveSupport::Testing::TimeHelpers#travel`および`#travel_to`を追加しました。これらのメソッドは、`Time.now`および`Date.today`をスタブ化して、現在の時刻を指定された時刻または期間に変更します。
* `ActiveSupport::Testing::TimeHelpers#travel_back`を追加しました。このメソッドは、`travel`と`travel_to`によって追加されたスタブを削除し、現在の時刻を元の状態に戻します。([プルリクエスト](https://github.com/rails/rails/pull/13884))

* `Numeric#in_milliseconds`を追加しました。例えば、`1.hour.in_milliseconds`のように使用することで、`getTime()`のようなJavaScript関数に渡すことができます。([コミット](https://github.com/rails/rails/commit/423249504a2b468d7a273cbe6accf4f21cb0e643))

* `Date#middle_of_day`、`DateTime#middle_of_day`、`Time#middle_of_day`メソッドを追加しました。また、`midday`、`noon`、`at_midday`、`at_noon`、`at_middle_of_day`をエイリアスとして追加しました。([プルリクエスト](https://github.com/rails/rails/pull/10879))

* `Date#all_week/month/quarter/year`を追加し、日付の範囲を生成するためのメソッドを追加しました。([プルリクエスト](https://github.com/rails/rails/pull/9685))

* `Time.zone.yesterday`と`Time.zone.tomorrow`を追加しました。([プルリクエスト](https://github.com/rails/rails/pull/12822))

* `String#remove(pattern)`を追加しました。これは、`String#gsub(pattern,'')`の一般的なパターンの省略形です。([コミット](https://github.com/rails/rails/commit/5da23a3f921f0a4a3139495d2779ab0d3bd4cb5f))

* `Hash#compact`と`Hash#compact!`を追加し、値がnilの要素をハッシュから削除するためのメソッドを追加しました。([プルリクエスト](https://github.com/rails/rails/pull/13632))

* `blank?`と`present?`はシングルトンを返すように変更されました。([コミット](https://github.com/rails/rails/commit/126dc47665c65cd129967cbd8a5926dddd0aa514))

* 新しい`I18n.enforce_available_locales`のデフォルト設定を`true`にしました。これにより、`I18n`は渡されたすべてのロケールが`available_locales`リストに宣言されている必要があることを確認します。([プルリクエスト](https://github.com/rails/rails/pull/13341))

* `Module#concerning`を導入しました。これは、クラス内で責任を分離するための自然で簡単な方法です。([コミット](https://github.com/rails/rails/commit/1eee0ca6de975b42524105a59e0521d18b38ab81))

* `Object#presence_in`を追加しました。これにより、許可されたリストに値を追加することが簡単になります。([コミット](https://github.com/rails/rails/commit/4edca106daacc5a159289eae255207d160f22396))


クレジット
-------

Railsへの多くの時間を費やした多くの人々に感謝します。Railsが安定かつ堅牢なフレームワークになったのは、彼らのおかげです。[Railsへの貢献者の完全なリスト](https://contributors.rubyonrails.org/)をご覧ください。彼ら全員に敬意を表します。
