**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: e9aa14ccbfd8f02fea6c1b061215332c
Ruby on Rails 7.0 リリースノート
===============================

Rails 7.0 のハイライト：

* Ruby 2.7.0+ が必要であり、Ruby 3.0+ が推奨されています

--------------------------------------------------------------------------------

Rails 7.0 へのアップグレード
----------------------

既存のアプリケーションをアップグレードする場合、アップグレードする前に十分なテストカバレッジを持っていることが重要です。また、まだ行っていない場合は、まず Rails 6.1 にアップグレードし、アプリケーションが予想どおりに動作することを確認してから、Rails 7.0 への更新を試みてください。アップグレード時に注意するべき事項のリストは、[Ruby on Rails のアップグレード](upgrading_ruby_on_rails.html#upgrading-from-rails-6-1-to-rails-7-0)ガイドで利用できます。

主な機能
--------------

Railties
--------

詳細な変更点については、[Changelog][railties] を参照してください。

### 削除

* `dbconsole` 内の `config` が非推奨となりました。

### 廃止予定

### 注目すべき変更点

* Sprockets はオプションの依存関係となりました

    `rails` ジェムはもはや `sprockets-rails` に依存しません。アプリケーションがまだ Sprockets を使用する必要がある場合は、Gemfile に `sprockets-rails` を追加してください。

    ```
    gem "sprockets-rails"
    ```

Action Cable
------------

詳細な変更点については、[Changelog][action-cable] を参照してください。

### 削除

### 廃止予定

### 注目すべき変更点

Action Pack
-----------

詳細な変更点については、[Changelog][action-pack] を参照してください。

### 削除

* `ActionDispatch::Response.return_only_media_type_on_content_type` が非推奨となりました。

* `Rails.config.action_dispatch.hosts_response_app` が非推奨となりました。

* `ActionDispatch::SystemTestCase#host!` が非推奨となりました。

* `fixture_path` を基準とした `fixture_file_upload` への相対パスのサポートが非推奨となりました。

### 廃止予定

### 注目すべき変更点

Action View
-----------

詳細な変更点については、[Changelog][action-view] を参照してください。

### 削除

* `Rails.config.action_view.raise_on_missing_translations` が非推奨となりました。

### 廃止予定

### 注目すべき変更点

* `button_to` は、URL の構築にオブジェクトが使用される場合、HTTP メソッド [method] を推測します。

    ```ruby
    button_to("Do a POST", [:do_post_action, Workshop.find(1)])
    # Before
    #=>   <input type="hidden" name="_method" value="post" autocomplete="off" />
    # After
    #=>   <input type="hidden" name="_method" value="patch" autocomplete="off" />
    ```

Action Mailer
-------------

詳細な変更点については、[Changelog][action-mailer] を参照してください。

### 削除

* `ActionMailer::DeliveryJob` および `ActionMailer::Parameterized::DeliveryJob` が非推奨となり、`ActionMailer::MailDeliveryJob` に置き換えられました。

### 廃止予定

### 注目すべき変更点

Active Record
-------------

詳細な変更点については、[Changelog][active-record] を参照してください。

### 削除

* `connected_to` から `database` キーワード引数が削除されました。

* `ActiveRecord::Base.allow_unsafe_raw_sql` が非推奨となりました。

* `configs_for` メソッドのオプション `:spec_name` が非推奨となりました。

* Rails 4.2 および 4.1 の形式で `ActiveRecord::Base` インスタンスを YAML でロードするサポートが非推奨となりました。

* PostgreSQL データベースで `:interval` カラムが使用されている場合の非推奨警告が削除されました。

    現在、interval カラムは文字列の代わりに `ActiveSupport::Duration` オブジェクトを返します。

    古い動作を維持するには、モデルに次の行を追加できます。

    ```ruby
    attribute :column, :string
    ```

* 接続の解決に `"primary"` を接続仕様名として使用するサポートが非推奨となりました。

* `ActiveRecord::Base` オブジェクトをクォートするサポートが非推奨となりました。

* データベース値への型キャストを行う `ActiveRecord::Base` オブジェクトへのサポートが非推奨となりました。

* `type_cast` にカラムを渡すサポートが非推奨となりました。

* `DatabaseConfig#config` メソッドが非推奨となりました。

* 次の rake タスクが非推奨となりました：

    * `db:schema:load_if_ruby`
    * `db:structure:dump`
    * `db:structure:load`
    * `db:structure:load_if_sql`
    * `db:structure:dump:#{name}`
    * `db:structure:load:#{name}`
    * `db:test:load_structure`
    * `db:test:load_structure:#{name}`

* 非決定的な順序で検索するための `Model.reorder(nil).first` の非推奨サポートが削除されました。

* `Tasks::DatabaseTasks.schema_up_to_date?` の `environment` 引数と `name` 引数が非推奨となりました。

* `Tasks::DatabaseTasks.dump_filename` が非推奨となりました。

* `Tasks::DatabaseTasks.schema_file` が非推奨となりました。

* `Tasks::DatabaseTasks.spec` が非推奨となりました。

* `Tasks::DatabaseTasks.current_config` が非推奨となりました。

* `ActiveRecord::Connection#allowed_index_name_length` が非推奨となりました。

* `ActiveRecord::Connection#in_clause_length` が非推奨となりました。

* `ActiveRecord::DatabaseConfigurations::DatabaseConfig#spec_name` が非推奨となりました。

* `ActiveRecord::Base.connection_config` が非推奨となりました。

* `ActiveRecord::Base.arel_attribute` が非推奨となりました。

* `ActiveRecord::Base.configurations.default_hash` が非推奨となりました。

* `ActiveRecord::Base.configurations.to_h` が非推奨となりました。

* `ActiveRecord::Result#map!` および `ActiveRecord::Result#collect!` が非推奨となりました。

* `ActiveRecord::Base#remove_connection` が非推奨となりました。

### 廃止予定

* `Tasks::DatabaseTasks.schema_file_type` が廃止予定となりました。

### 注目すべき変更点

* ブロックが予想よりも早く返された場合、トランザクションをロールバックします。

    この変更前では、トランザクションブロックが早期に返された場合、トランザクションはコミットされてしまいました。

    問題は、トランザクションブロック内でタイムアウトが発生した場合も不完全なトランザクションがコミットされてしまうことです。この誤りを避けるために、トランザクションブロックはロールバックされます。

* 同じカラムに対する条件のマージは、もはや両方の条件を維持せず、常に後の条件で置き換えられるようになりました。

    ```ruby
    # Rails 6.1 (IN 句はマージ先側の等値条件に置き換えられます)
    Author.where(id: [david.id, mary.id]).merge(Author.where(id: bob)) # => [bob]
    # Rails 6.1 (両方の競合する条件が存在し、非推奨)
    Author.where(id: david.id..mary.id).merge(Author.where(id: bob)) # => []
    # Rails 6.1 から Rails 7.0 の動作に移行するための rewhere
    Author.where(id: david.id..mary.id).merge(Author.where(id: bob), rewhere: true) # => [bob]
    # Rails 7.0 (IN 句と同じ動作で、マージ先側の条件が一貫して置き換えられます)
    Author.where(id: [david.id, mary.id]).merge(Author.where(id: bob)) # => [bob]
    Author.where(id: david.id..mary.id).merge(Author.where(id: bob)) # => [bob]
    ```
Active Storage
--------------

詳細な変更については、[Changelog][active-storage]を参照してください。

### 削除

### 廃止予定

### 注目すべき変更点

Active Model
------------

詳細な変更については、[Changelog][active-model]を参照してください。

### 削除

*   `ActiveModel::Errors`インスタンスの非推奨な列挙をハッシュとして削除しました。

*   非推奨な`ActiveModel::Errors#to_h`を削除しました。

*   非推奨な`ActiveModel::Errors#slice!`を削除しました。

*   非推奨な`ActiveModel::Errors#values`を削除しました。

*   非推奨な`ActiveModel::Errors#keys`を削除しました。

*   非推奨な`ActiveModel::Errors#to_xml`を削除しました。

*   `ActiveModel::Errors#messages`へのエラーの連結をサポートする機能を削除しました。

*   `ActiveModel::Errors#messages`からエラーをクリアする機能を削除しました。

*   `ActiveModel::Errors#messages`からエラーを削除する機能を削除しました。

*   `ActiveModel::Errors#messages`で`[]=`を使用するサポートを削除しました。

*   Rails 5.xのエラーフォーマットをMarshalおよびYAMLでロードするサポートを削除しました。

*   Rails 5.xの`ActiveModel::AttributeSet`フォーマットをMarshalでロードするサポートを削除しました。

### 廃止予定

### 注目すべき変更点

Active Support
--------------

詳細な変更については、[Changelog][active-support]を参照してください。

### 削除

*   非推奨な`config.active_support.use_sha1_digests`を削除しました。

*   非推奨な`URI.parser`を削除しました。

*   日時範囲内の値の包含をチェックするために`Range#include?`を使用するサポートを非推奨にしました。

*   非推奨な`ActiveSupport::Multibyte::Unicode.default_normalization_form`を削除しました。

### 廃止予定

*   `Array`、`Range`、`Date`、`DateTime`、`Time`、`BigDecimal`、`Float`、`Integer`の`#to_s`にフォーマットを渡すことを非推奨にし、`#to_fs`を使用することを推奨しました。

    この非推奨は、RailsアプリケーションがRuby 3.1の[最適化](https://github.com/ruby/ruby/commit/b08dacfea39ad8da3f1fd7fdd0e4538cc892ec44)を利用できるようにするためのもので、一部のオブジェクトの補間を高速化します。

    新しいアプリケーションでは、これらのクラスの`#to_s`メソッドはオーバーライドされません。既存のアプリケーションでは、`config.active_support.disable_to_s_conversion`を使用できます。

### 注目すべき変更点

Active Job
----------

詳細な変更については、[Changelog][active-job]を参照してください。

### 削除

*   前のコールバックが`throw :abort`で中断された場合に、`after_enqueue`/`after_perform`コールバックを停止しなかった非推奨な動作を削除しました。

*   非推奨な`:return_false_on_aborted_enqueue`オプションを削除しました。

### 廃止予定

*   `Rails.config.active_job.skip_after_callbacks_if_terminated`を廃止しました。

### 注目すべき変更点

Action Text
----------

詳細な変更については、[Changelog][action-text]を参照してください。

### 削除

### 廃止予定

### 注目すべき変更点

Action Mailbox
----------

詳細な変更については、[Changelog][action-mailbox]を参照してください。

### 削除

*   非推奨な`Rails.application.credentials.action_mailbox.mailgun_api_key`を削除しました。

*   非推奨な環境変数`MAILGUN_INGRESS_API_KEY`を削除しました。

### 廃止予定

### 注目すべき変更点

Ruby on Rails Guides
--------------------

詳細な変更については、[Changelog][guides]を参照してください。

### 注目すべき変更点

Credits
-------

Railsに多くの時間を費やし、安定かつ堅牢なフレームワークにした多くの人々に感謝します。
[Railsへの貢献者の完全なリスト](https://contributors.rubyonrails.org/)を参照して、彼ら全員に賞賛を送りましょう。

[railties]:       https://github.com/rails/rails/blob/7-0-stable/railties/CHANGELOG.md
[action-pack]:    https://github.com/rails/rails/blob/7-0-stable/actionpack/CHANGELOG.md
[action-view]:    https://github.com/rails/rails/blob/7-0-stable/actionview/CHANGELOG.md
[action-mailer]:  https://github.com/rails/rails/blob/7-0-stable/actionmailer/CHANGELOG.md
[action-cable]:   https://github.com/rails/rails/blob/7-0-stable/actioncable/CHANGELOG.md
[active-record]:  https://github.com/rails/rails/blob/7-0-stable/activerecord/CHANGELOG.md
[active-model]:   https://github.com/rails/rails/blob/7-0-stable/activemodel/CHANGELOG.md
[active-job]:     https://github.com/rails/rails/blob/7-0-stable/activejob/CHANGELOG.md
[action-text]:    https://github.com/rails/rails/blob/7-0-stable/actiontext/CHANGELOG.md
[guides]:         https://github.com/rails/rails/blob/7-0-stable/guides/CHANGELOG.md
[active-storage]: https://github.com/rails/rails/blob/7-0-stable/activestorage/CHANGELOG.md
[active-support]: https://github.com/rails/rails/blob/7-0-stable/activesupport/CHANGELOG.md
[action-mailbox]: https://github.com/rails/rails/blob/7-0-stable/actionmailbox/CHANGELOG.md
