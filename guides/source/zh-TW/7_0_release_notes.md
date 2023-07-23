**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: e9aa14ccbfd8f02fea6c1b061215332c
Ruby on Rails 7.0 發行說明
===============================

Rails 7.0 的亮點：

* 需要 Ruby 2.7.0+，建議使用 Ruby 3.0+

--------------------------------------------------------------------------------

升級到 Rails 7.0
----------------------

如果您正在升級現有的應用程式，在進行升級之前，最好有良好的測試覆蓋率。您應該先升級到 Rails 6.1（如果尚未升級），並確保您的應用程式在升級到 Rails 7.0 之前仍然正常運行。在升級時需要注意的事項，可參考
[升級 Ruby on Rails](upgrading_ruby_on_rails.html#upgrading-from-rails-6-1-to-rails-7-0)
指南中提供的清單。

主要功能
--------------

Railties
--------

詳細變更請參閱[變更日誌][railties]。

### 刪除

*   刪除 `dbconsole` 中已棄用的 `config`。

### 廢棄

### 重要變更

*   Sprockets 現在是可選的相依性

    gem `rails` 不再依賴於 `sprockets-rails`。如果您的應用程式仍需要使用 Sprockets，
    請確保將 `sprockets-rails` 加入到您的 Gemfile 中。

    ```
    gem "sprockets-rails"
    ```

Action Cable
------------

詳細變更請參閱[變更日誌][action-cable]。

### 刪除

### 廢棄

### 重要變更

Action Pack
-----------

詳細變更請參閱[變更日誌][action-pack]。

### 刪除

*   刪除已棄用的 `ActionDispatch::Response.return_only_media_type_on_content_type`。

*   刪除已棄用的 `Rails.config.action_dispatch.hosts_response_app`。

*   刪除已棄用的 `ActionDispatch::SystemTestCase#host!`。

*   刪除將 `fixture_file_upload` 的路徑相對於 `fixture_path` 傳遞的已棄用支援。

### 廢棄

### 重要變更

Action View
-----------

詳細變更請參閱[變更日誌][action-view]。

### 刪除

*   刪除已棄用的 `Rails.config.action_view.raise_on_missing_translations`。

### 廢棄

### 重要變更

*  `button_to` 從 Active Record 物件中推斷 HTTP 動詞 [method]，如果使用物件建立 URL

    ```ruby
    button_to("執行 POST", [:do_post_action, Workshop.find(1)])
    # 之前
    #=>   <input type="hidden" name="_method" value="post" autocomplete="off" />
    # 之後
    #=>   <input type="hidden" name="_method" value="patch" autocomplete="off" />
    ```

Action Mailer
-------------

詳細變更請參閱[變更日誌][action-mailer]。

### 刪除

*   刪除已棄用的 `ActionMailer::DeliveryJob` 和 `ActionMailer::Parameterized::DeliveryJob`，
    改用 `ActionMailer::MailDeliveryJob`。

### 廢棄

### 重要變更

Active Record
-------------

詳細變更請參閱[變更日誌][active-record]。

### 刪除

*   刪除 `connected_to` 中已棄用的 `database` 參數。

*   刪除已棄用的 `ActiveRecord::Base.allow_unsafe_raw_sql`。

*   刪除 `configs_for` 方法中 `:spec_name` 選項的已棄用支援。

*   刪除在 Rails 4.2 和 4.1 格式中使用 YAML 載入 `ActiveRecord::Base` 實例的已棄用支援。

*   刪除在 PostgreSQL 資料庫中使用 `:interval` 欄位時的廢棄警告。

    現在，interval 欄位將返回 `ActiveSupport::Duration` 物件，而不是字串。

    若要保留舊的行為，您可以在模型中添加這行程式碼：

    ```ruby
    attribute :column, :string
    ```

*   刪除使用 `"primary"` 作為連線規格名稱解析連線的已棄用支援。
*   移除對引用`ActiveRecord::Base`對象的不推薦支持。

*   移除對將`ActiveRecord::Base`對象類型轉換為數據庫值的不推薦支持。

*   移除對將列傳遞給`type_cast`的不推薦支持。

*   移除不推薦的`DatabaseConfig#config`方法。

*   移除不推薦的rake任務：

    * `db:schema:load_if_ruby`
    * `db:structure:dump`
    * `db:structure:load`
    * `db:structure:load_if_sql`
    * `db:structure:dump:#{name}`
    * `db:structure:load:#{name}`
    * `db:test:load_structure`
    * `db:test:load_structure:#{name}`

*   移除對使用非確定性順序進行搜索的`Model.reorder(nil).first`的不推薦支持。

*   移除對`Tasks::DatabaseTasks.schema_up_to_date?`中的`environment`和`name`參數的不推薦支持。

*   移除不推薦的`Tasks::DatabaseTasks.dump_filename`。

*   移除不推薦的`Tasks::DatabaseTasks.schema_file`。

*   移除不推薦的`Tasks::DatabaseTasks.spec`。

*   移除不推薦的`Tasks::DatabaseTasks.current_config`。

*   移除不推薦的`ActiveRecord::Connection#allowed_index_name_length`。

*   移除不推薦的`ActiveRecord::Connection#in_clause_length`。

*   移除不推薦的`ActiveRecord::DatabaseConfigurations::DatabaseConfig#spec_name`。

*   移除不推薦的`ActiveRecord::Base.connection_config`。

*   移除不推薦的`ActiveRecord::Base.arel_attribute`。

*   移除不推薦的`ActiveRecord::Base.configurations.default_hash`。

*   移除不推薦的`ActiveRecord::Base.configurations.to_h`。

*   移除不推薦的`ActiveRecord::Result#map!`和`ActiveRecord::Result#collect!`。

*   移除不推薦的`ActiveRecord::Base#remove_connection`。

### 不推薦

*   不推薦使用`Tasks::DatabaseTasks.schema_file_type`。

### 重要更改

*   當塊提前返回時回滾事務。

    在此更改之前，當事務塊提前返回時，事務將被提交。

    問題在於事務塊內觸發的超時也會導致未完成的事務被提交，為了避免這個錯誤，事務塊將被回滾。

*   合併相同列上的條件不再保留兩個條件，並且將一致地替換為後面的條件。

    ```ruby
    # Rails 6.1（IN子句被合併方的相等條件替換）
    Author.where(id: [david.id, mary.id]).merge(Author.where(id: bob)) # => [bob]
    # Rails 6.1（兩個衝突條件都存在，不推薦）
    Author.where(id: david.id..mary.id).merge(Author.where(id: bob)) # => []
    # Rails 6.1使用rewhere遷移到Rails 7.0的行為
    Author.where(id: david.id..mary.id).merge(Author.where(id: bob), rewhere: true) # => [bob]
    # Rails 7.0（與IN子句相同的行為，合併方的條件被一致替換）
    Author.where(id: [david.id, mary.id]).merge(Author.where(id: bob)) # => [bob]
    Author.where(id: david.id..mary.id).merge(Author.where(id: bob)) # => [bob]
    ```

Active Storage
--------------

詳細更改請參閱[Changelog][active-storage]。

### 移除

### 不推薦

### 重要更改

Active Model
------------

詳細更改請參閱[Changelog][active-model]。

### 移除

*   移除將`ActiveModel::Errors`實例枚舉為哈希的不推薦支持。

*   移除不推薦的`ActiveModel::Errors#to_h`。

*   移除不推薦的`ActiveModel::Errors#slice!`。

*   移除不推薦的`ActiveModel::Errors#values`。

*   移除不推薦的`ActiveModel::Errors#keys`。

*   移除不推薦的`ActiveModel::Errors#to_xml`。

*   移除將錯誤連接到`ActiveModel::Errors#messages`的不推薦支持。

*   移除從`ActiveModel::Errors#messages`中清除錯誤的不推薦支持。

*   移除從`ActiveModel::Errors#messages`中刪除錯誤的不推薦支持。

*   移除在`ActiveModel::Errors#messages`中使用`[]=`的支持。

*   移除對Rails 5.x錯誤格式的Marshal和YAML加載支持。
*   移除對於Rails 5.x `ActiveModel::AttributeSet` 格式的 Marshal 加載支援。

### 廢棄功能

### 重要變更

Active Support
--------------

詳細變更請參考[變更日誌][active-support]。

### 移除功能

*   移除廢棄的 `config.active_support.use_sha1_digests`。

*   移除廢棄的 `URI.parser`。

*   移除廢棄的支援，使用 `Range#include?` 檢查日期時間範圍中是否包含某個值。

*   移除廢棄的 `ActiveSupport::Multibyte::Unicode.default_normalization_form`。

### 廢棄功能

*   廢棄在 `Array`、`Range`、`Date`、`DateTime`、`Time`、`BigDecimal`、`Float` 和 `Integer` 中將格式傳遞給 `#to_s`，改用 `#to_fs`。

    此廢棄功能是為了讓 Rails 應用程式能夠利用 Ruby 3.1 的一項[優化](https://github.com/ruby/ruby/commit/b08dacfea39ad8da3f1fd7fdd0e4538cc892ec44)，使某些類型物件的插值更快。

    新的應用程式將不會在這些類別上覆寫 `#to_s` 方法，現有的應用程式可以使用 `config.active_support.disable_to_s_conversion`。

### 重要變更

Active Job
----------

詳細變更請參考[變更日誌][active-job]。

### 移除功能

*   移除在前一個回呼使用 `throw :abort` 中止時，未停止 `after_enqueue`/`after_perform` 回呼的廢棄行為。

*   移除廢棄的 `:return_false_on_aborted_enqueue` 選項。

### 廢棄功能

*   廢棄 `Rails.config.active_job.skip_after_callbacks_if_terminated`。

### 重要變更

Action Text
----------

詳細變更請參考[變更日誌][action-text]。

### 移除功能

### 廢棄功能

### 重要變更

Action Mailbox
----------

詳細變更請參考[變更日誌][action-mailbox]。

### 移除功能

*   移除廢棄的 `Rails.application.credentials.action_mailbox.mailgun_api_key`。

*   移除廢棄的環境變數 `MAILGUN_INGRESS_API_KEY`。

### 廢棄功能

### 重要變更

Ruby on Rails Guides
--------------------

詳細變更請參考[變更日誌][guides]。

### 重要變更

貢獻者
-------

請參閱[完整的 Rails 貢獻者名單](https://contributors.rubyonrails.org/)，感謝所有花費許多時間使 Rails 成為穩定且強大的框架的人們。

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
