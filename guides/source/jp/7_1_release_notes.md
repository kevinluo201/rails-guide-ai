**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 82080185bf1d0c30f22fa131b42e4187
Ruby on Rails 7.1 リリースノート
===============================

Rails 7.1 のハイライト:

--------------------------------------------------------------------------------

Rails 7.1 へのアップグレード
----------------------

既存のアプリケーションをアップグレードする場合、アップグレード前に十分なテストカバレッジを持っていることが重要です。また、まだ行っていない場合はまず Rails 7.0 にアップグレードし、アプリケーションが予想どおりに動作することを確認してから、Rails 7.1 への更新を試みてください。アップグレード時に注意するべき事項のリストは、
[Upgrading Ruby on Rails](upgrading_ruby_on_rails.html#upgrading-from-rails-7-0-to-rails-7-1)
ガイドで利用できます。

主な機能
--------------

Railties
--------

詳細な変更については、[Changelog][railties] を参照してください。

### 削除

### 廃止予定

### 注目の変更

Action Cable
------------

詳細な変更については、[Changelog][action-cable] を参照してください。

### 削除

### 廃止予定

### 注目の変更

Action Pack
-----------

詳細な変更については、[Changelog][action-pack] を参照してください。

### 削除

*   `Request#content_type` で非推奨の動作を削除

*   `config.action_dispatch.trusted_proxies` に単一の値を割り当てる機能を削除

*   システムテストのための `poltergeist` と `webkit` (capybara-webkit) ドライバーの登録を削除

### 廃止予定

*   `config.action_dispatch.return_only_request_media_type_on_content_type` を廃止

*   `AbstractController::Helpers::MissingHelperError` を廃止

*   `ActionDispatch::IllegalStateError` を廃止

### 注目の変更

Action View
-----------

詳細な変更については、[Changelog][action-view] を参照してください。

### 削除

*   `ActionView::Path` の非推奨定数を削除

*   パーシャルへのローカル変数としてインスタンス変数を渡すサポートを削除

### 廃止予定

### 注目の変更

Action Mailer
-------------

詳細な変更については、[Changelog][action-mailer] を参照してください。

### 削除

### 廃止予定

### 注目の変更

Active Record
-------------

詳細な変更については、[Changelog][active-record] を参照してください。

### 削除

*   `ActiveRecord.legacy_connection_handling` のサポートを削除

*   `ActiveRecord::Base` の設定アクセサを削除

*   `configs_for` の `:include_replicas` サポートを削除。代わりに `:include_hidden` を使用してください。

*   `config.active_record.partial_writes` を廃止

*   `Tasks::DatabaseTasks.schema_file_type` を廃止

### 廃止予定

### 注目の変更

Active Storage
--------------

詳細な変更については、[Changelog][active-storage] を参照してください。

### 削除

*   Active Storage 設定での無効なデフォルトコンテンツタイプを削除

*   `ActiveStorage::Current#host` と `ActiveStorage::Current#host=` メソッドの非推奨動作を削除

*   添付ファイルのコレクションへの代入時の非推奨動作を削除。コレクションに追加する代わりに、コレクションが置き換えられます。

*   添付ファイルの関連付けから `purge` と `purge_later` メソッドの非推奨動作を削除

### 廃止予定

### 注目の変更

Active Model
------------

詳細な変更については、[Changelog][active-model] を参照してください。

### 削除

### 廃止予定

### 注目の変更

Active Support
--------------

詳細な変更については、[Changelog][active-support] を参照してください。

### 削除

*   `Enumerable#sum` のオーバーライドを削除

*   `ActiveSupport::PerThreadRegistry` を削除

*   `Array`、`Range`、`Date`、`DateTime`、`Time`、`BigDecimal`、`Float`、`Integer` の `#to_s` にフォーマットを渡すオプションの非推奨動作を削除

*   `ActiveSupport::TimeWithZone.name` のオーバーライドを削除

*   `active_support/core_ext/uri` ファイルを削除

*   `active_support/core_ext/range/include_time_with_zone` ファイルを削除

*   `ActiveSupport::SafeBuffer` によるオブジェクトの `String` への暗黙の変換を削除

*   `Digest::UUID` で定義されている定数以外の名前空間 ID を指定した場合に、不正な RFC 4122 UUID を生成するサポートを削除

### 廃止予定

*   `config.active_support.disable_to_s_conversion` を廃止

*   `config.active_support.remove_deprecated_time_with_zone_name` を廃止

*   `config.active_support.use_rfc4122_namespaced_uuids` を廃止

### 注目の変更

Active Job
----------

詳細な変更については、[Changelog][active-job] を参照してください。

### 削除

### 廃止予定

### 注目の変更

Action Text
----------

詳細な変更については、[Changelog][action-text] を参照してください。

### 削除

### 廃止予定

### 注目の変更

Action Mailbox
----------

詳細な変更については、[Changelog][action-mailbox] を参照してください。

### 削除

### 廃止予定

### 注目の変更

Ruby on Rails ガイド
--------------------

詳細な変更については、[Changelog][guides] を参照してください。

### 注目の変更

クレジット
-------

Rails に多くの時間を費やした多くの人々に感謝します。Rails を安定かつ堅牢なフレームワークにするために、彼ら全員が多くの時間を費やしました。

[contributors.rubyonrails.org](https://contributors.rubyonrails.org/)
で Rails への貢献者の完全なリストをご覧ください。

[railties]:       https://github.com/rails/rails/blob/main/railties/CHANGELOG.md
[action-pack]:    https://github.com/rails/rails/blob/main/actionpack/CHANGELOG.md
[action-view]:    https://github.com/rails/rails/blob/main/actionview/CHANGELOG.md
[action-mailer]:  https://github.com/rails/rails/blob/main/actionmailer/CHANGELOG.md
[action-cable]:   https://github.com/rails/rails/blob/main/actioncable/CHANGELOG.md
[active-record]:  https://github.com/rails/rails/blob/main/activerecord/CHANGELOG.md
[active-model]:   https://github.com/rails/rails/blob/main/activemodel/CHANGELOG.md
[active-job]:     https://github.com/rails/rails/blob/main/activejob/CHANGELOG.md
[action-text]:    https://github.com/rails/rails/blob/main/actiontext/CHANGELOG.md
[guides]:         https://github.com/rails/rails/blob/main/guides/CHANGELOG.md
[active-storage]: https://github.com/rails/rails/blob/main/activestorage/CHANGELOG.md
[active-support]: https://github.com/rails/rails/blob/main/activesupport/CHANGELOG.md
[action-mailbox]: https://github.com/rails/rails/blob/main/actionmailbox/CHANGELOG.md
