**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 82080185bf1d0c30f22fa131b42e4187
Ruby on Rails 7.1 發行說明
===============================

Rails 7.1 的亮點：

--------------------------------------------------------------------------------

升級到 Rails 7.1
----------------------

如果您正在升級現有應用程式，建議在進行升級之前先確保有良好的測試覆蓋率。同時，您應該先升級到 Rails 7.0，確保應用程式在升級到 Rails 7.1 之前仍然正常運行。升級時需要注意的事項可在
[升級 Ruby on Rails](upgrading_ruby_on_rails.html#upgrading-from-rails-7-0-to-rails-7-1)
指南中找到。

主要功能
--------------

Railties
--------

詳細變更請參閱 [變更日誌][railties]。

### 移除

### 廢棄

### 重要變更

Action Cable
------------

詳細變更請參閱 [變更日誌][action-cable]。

### 移除

### 廢棄

### 重要變更

Action Pack
-----------

詳細變更請參閱 [變更日誌][action-pack]。

### 移除

*   移除 `Request#content_type` 上的已棄用行為。

*   移除將單個值分配給 `config.action_dispatch.trusted_proxies` 的已棄用能力。

*   移除系統測試中 `poltergeist` 和 `webkit` (capybara-webkit) 驅動程式的已棄用註冊。

### 廢棄

*   廢棄 `config.action_dispatch.return_only_request_media_type_on_content_type`。

*   廢棄 `AbstractController::Helpers::MissingHelperError`。

*   廢棄 `ActionDispatch::IllegalStateError`。

### 重要變更

Action View
-----------

詳細變更請參閱 [變更日誌][action-view]。

### 移除

*   移除 `ActionView::Path` 的已棄用常數。

*   移除將實例變數作為局部變數傳遞給局部視圖的已棄用支援。

### 廢棄

### 重要變更

Action Mailer
-------------

詳細變更請參閱 [變更日誌][action-mailer]。

### 移除

### 廢棄

### 重要變更

Active Record
-------------

詳細變更請參閱 [變更日誌][active-record]。

### 移除

*   移除對 `ActiveRecord.legacy_connection_handling` 的支援。

*   移除已棄用的 `ActiveRecord::Base` 配置存取器。

*   移除 `configs_for` 上的 `:include_replicas` 支援。請改用 `:include_hidden`。

*   移除已棄用的 `config.active_record.partial_writes`。

*   移除已棄用的 `Tasks::DatabaseTasks.schema_file_type`。

### 廢棄

### 重要變更

Active Storage
--------------

詳細變更請參閱 [變更日誌][active-storage]。

### 移除

*   移除 Active Storage 配置中無效的預設內容類型。

*   移除 `ActiveStorage::Current#host` 和 `ActiveStorage::Current#host=` 方法的已棄用行為。

*   移除對附件集合進行賦值時的已棄用行為。現在，附件集合將被替換，而不是追加。

*   移除附件關聯中的 `purge` 和 `purge_later` 方法的已棄用行為。

### 廢棄

### 重要變更

Active Model
------------

詳細變更請參閱 [變更日誌][active-model]。

### 移除

### 廢棄

### 重要變更

Active Support
--------------

詳細變更請參閱 [變更日誌][active-support]。

### 移除

*   移除對 `Enumerable#sum` 的已棄用覆寫。

*   移除 `ActiveSupport::PerThreadRegistry` 的已棄用行為。

*   移除在 `Array`、`Range`、`Date`、`DateTime`、`Time`、`BigDecimal`、`Float` 和 `Integer` 中將格式作為參數傳遞給 `#to_s` 的已棄用選項。
*   移除`ActiveSupport::TimeWithZone.name`的過時覆寫。

*   移除過時的`active_support/core_ext/uri`文件。

*   移除過時的`active_support/core_ext/range/include_time_with_zone`文件。

*   移除`ActiveSupport::SafeBuffer`對象隱式轉換為`String`的功能。

*   移除在提供的命名空間ID不是`Digest::UUID`定義的常數之一時生成不正確的RFC 4122 UUID的過時支持。

### 過時功能

*   過時的`config.active_support.disable_to_s_conversion`。

*   過時的`config.active_support.remove_deprecated_time_with_zone_name`。

*   過時的`config.active_support.use_rfc4122_namespaced_uuids`。

### 重要變更

Active Job
----------

詳細變更請參閱[變更日誌][active-job]。

### 移除功能

### 過時功能

### 重要變更

Action Text
----------

詳細變更請參閱[變更日誌][action-text]。

### 移除功能

### 過時功能

### 重要變更

Action Mailbox
----------

詳細變更請參閱[變更日誌][action-mailbox]。

### 移除功能

### 過時功能

### 重要變更

Ruby on Rails Guides
--------------------

詳細變更請參閱[變更日誌][guides]。

### 重要變更

貢獻者
-------

請參閱[Rails的完整貢獻者列表](https://contributors.rubyonrails.org/)，感謝所有花費許多時間使Rails成為穩定且強大的框架的人。向他們致敬。

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
