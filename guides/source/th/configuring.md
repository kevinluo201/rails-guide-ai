**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: bba7dd6e311e7abd59e434f12dbebd0e
การกำหนดค่าแอปพลิเคชัน Rails
==============================

เอกสารนี้เป็นคู่มือสำหรับการกำหนดค่าและเริ่มต้นใช้งานในแอปพลิเคชัน Rails

หลังจากอ่านคู่มือนี้คุณจะรู้:

* วิธีการปรับแต่งพฤติกรรมของแอปพลิเคชัน Rails ของคุณ
* วิธีการเพิ่มโค้ดเพิ่มเติมที่จะทำงานในเวลาเริ่มต้นแอปพลิเคชัน

--------------------------------------------------------------------------------

ตำแหน่งสำหรับโค้ดเริ่มต้น
---------------------------------

Rails มีสี่ตำแหน่งมาตรฐานที่ให้คุณวางโค้ดเริ่มต้น:

* `config/application.rb`
* ไฟล์กำหนดค่าสำหรับแต่ละสภาพแวดล้อม
* Initializers
* After-initializers

การรันโค้ดก่อน Rails
-------------------------

ในกรณีที่มีความจำเป็นที่แอปพลิเคชันของคุณต้องรันบางโค้ดก่อนที่ Rails จะโหลดเอง ให้วางโค้ดดังกล่าวด้านบนของการเรียกใช้ `require "rails/all"` ใน `config/application.rb`

การกำหนดค่าคอมโพเนนต์ของ Rails
----------------------------

โดยทั่วไปแล้ว การกำหนดค่า Rails หมายถึงการกำหนดค่าคอมโพเนนต์ของ Rails รวมทั้งการกำหนดค่า Rails เอง ไฟล์กำหนดค่า `config/application.rb` และไฟล์กำหนดค่าสำหรับแต่ละสภาพแวดล้อม (เช่น `config/environments/production.rb`) ช่วยให้คุณระบุการตั้งค่าต่างๆ ที่คุณต้องการส่งต่อไปยังคอมโพเนนต์ทั้งหมด

ตัวอย่างเช่น คุณสามารถเพิ่มการตั้งค่านี้ในไฟล์ `config/application.rb`:

```ruby
config.time_zone = 'Central Time (US & Canada)'
```

นี่คือการตั้งค่าสำหรับ Rails เอง หากคุณต้องการส่งค่าไปยังคอมโพเนนต์แต่ละตัวของ Rails คุณสามารถทำได้ผ่านอ็อบเจ็กต์ `config` เดียวกันใน `config/application.rb`:
```ruby
config.active_record.schema_format = :ruby
```

Rails จะใช้การตั้งค่านี้เพื่อกำหนดค่า Active Record

คำเตือน: ใช้วิธีการกำหนดค่าสาธารณะแทนการเรียกใช้โดยตรงกับคลาสที่เกี่ยวข้อง เช่น `Rails.application.config.action_mailer.options` แทน `ActionMailer::Base.options`

หมายเหตุ: หากคุณต้องการใช้งานการกำหนดค่าโดยตรงกับคลาส ให้ใช้ [lazy load hook](https://api.rubyonrails.org/classes/ActiveSupport/LazyLoadHooks.html) ในไฟล์เริ่มต้นเพื่อหลีกเลี่ยงการโหลดคลาสก่อนที่การเริ่มต้นจะเสร็จสมบูรณ์ การโหลดนี้จะเกิดข้อผิดพลาดเนื่องจากการโหลดในระหว่างการเริ่มต้นไม่สามารถทำซ้ำได้อย่างปลอดภัยเมื่อแอปพลิเคชันโหลดใหม่

### ค่าเริ่มต้นที่มีเวอร์ชัน

[`config.load_defaults`] โหลดค่าการกำหนดค่าเริ่มต้นสำหรับเวอร์ชันเป้าหมายและเวอร์ชันทั้งหมดก่อนหน้านั้น ตัวอย่างเช่น `config.load_defaults 6.1` จะโหลดค่าเริ่มต้นสำหรับเวอร์ชันทั้งหมดรวมถึงเวอร์ชัน 6.1

ด้านล่างคือค่าเริ่มต้นที่เกี่ยวข้องกับแต่ละเวอร์ชันเป้าหมาย ในกรณีที่มีค่าที่ขัดแย้งกัน เวอร์ชันใหม่จะมีความสำคัญกว่าเวอร์ชันเก่า

#### ค่าเริ่มต้นสำหรับเวอร์ชันเป้าหมาย 7.1

- [`config.action_controller.allow_deprecated_parameters_hash_equality`](#config-action-controller-allow-deprecated-parameters-hash-equality): `false`
- [`config.action_dispatch.debug_exception_log_level`](#config-action-dispatch-debug-exception-log-level): `:error`
- [`config.action_dispatch.default_headers`](#config-action-dispatch-default-headers): `{ "X-Frame-Options" => "SAMEORIGIN", "X-XSS-Protection" => "0", "X-Content-Type-Options" => "nosniff", "X-Permitted-Cross-Domain-Policies" => "none", "Referrer-Policy" => "strict-origin-when-cross-origin" }`
- [`config.action_text.sanitizer_vendor`](#config-action-text-sanitizer-vendor): `Rails::HTML::Sanitizer.best_supported_vendor`
- [`config.action_view.sanitizer_vendor`](#config-action-view-sanitizer-vendor): `Rails::HTML::Sanitizer.best_supported_vendor`
- [`config.active_job.use_big_decimal_serializer`](#config-active-job-use-big-decimal-serializer): `true`
- [`config.active_record.allow_deprecated_singular_associations_name`](#config-active-record-allow-deprecated-singular-associations-name): `false`
- [`config.active_record.before_committed_on_all_records`](#config-active-record-before-committed-on-all-records): `true`
- [`config.active_record.belongs_to_required_validates_foreign_key`](#config-active-record-belongs-to-required-validates-foreign-key): `false`
- [`config.active_record.default_column_serializer`](#config-active-record-default-column-serializer): `nil`
- [`config.active_record.encryption.hash_digest_class`](#config-active-record-encryption-hash-digest-class): `OpenSSL::Digest::SHA256`
- [`config.active_record.encryption.support_sha1_for_non_deterministic_encryption`](#config-active-record-encryption-support-sha1-for-non-deterministic-encryption): `false`
- [`config.active_record.marshalling_format_version`](#config-active-record-marshalling-format-version): `7.1`
- [`config.active_record.query_log_tags_format`](#config-active-record-query-log-tags-format): `:sqlcommenter`
- [`config.active_record.raise_on_assign_to_attr_readonly`](#config-active-record-raise-on-assign-to-attr-readonly): `true`
- [`config.active_record.run_after_transaction_callbacks_in_order_defined`](#config-active-record-run-after-transaction-callbacks-in-order-defined): `true`
- [`config.active_record.run_commit_callbacks_on_first_saved_instances_in_transaction`](#config-active-record-run-commit-callbacks-on-first-saved-instances-in-transaction): `false`
- [`config.active_record.sqlite3_adapter_strict_strings_by_default`](#config-active-record-sqlite3-adapter-strict-strings-by-default): `true`
- [`config.active_support.cache_format_version`](#config-active-support-cache-format-version): `7.1`
- [`config.active_support.message_serializer`](#config-active-support-message-serializer): `:json_allow_marshal`
- [`config.active_support.raise_on_invalid_cache_expiration_time`](#config-active-support-raise-on-invalid-cache-expiration-time): `true`
- [`config.active_support.use_message_serializer_for_metadata`](#config-active-support-use-message-serializer-for-metadata): `true`
- [`config.add_autoload_paths_to_load_path`](#config-add-autoload-paths-to-load-path): `false`
- [`config.log_file_size`](#config-log-file-size): `100 * 1024 * 1024`
- [`config.precompile_filter_parameters`](#config-precompile-filter-parameters): `true`
#### ค่าเริ่มต้นสำหรับเวอร์ชันเป้าหมาย 7.0

- [`config.action_controller.raise_on_open_redirects`](#config-action-controller-raise-on-open-redirects): `true`
- [`config.action_controller.wrap_parameters_by_default`](#config-action-controller-wrap-parameters-by-default): `true`
- [`config.action_dispatch.cookies_serializer`](#config-action-dispatch-cookies-serializer): `:json`
- [`config.action_dispatch.default_headers`](#config-action-dispatch-default-headers): `{ "X-Frame-Options" => "SAMEORIGIN", "X-XSS-Protection" => "0", "X-Content-Type-Options" => "nosniff", "X-Download-Options" => "noopen", "X-Permitted-Cross-Domain-Policies" => "none", "Referrer-Policy" => "strict-origin-when-cross-origin" }`
- [`config.action_mailer.smtp_timeout`](#config-action-mailer-smtp-timeout): `5`
- [`config.action_view.apply_stylesheet_media_default`](#config-action-view-apply-stylesheet-media-default): `false`
- [`config.action_view.button_to_generates_button_tag`](#config-action-view-button-to-generates-button-tag): `true`
- [`config.active_record.automatic_scope_inversing`](#config-active-record-automatic-scope-inversing): `true`
- [`config.active_record.partial_inserts`](#config-active-record-partial-inserts): `false`
- [`config.active_record.verify_foreign_keys_for_fixtures`](#config-active-record-verify-foreign-keys-for-fixtures): `true`
- [`config.active_storage.multiple_file_field_include_hidden`](#config-active-storage-multiple-file-field-include-hidden): `true`
- [`config.active_storage.variant_processor`](#config-active-storage-variant-processor): `:vips`
- [`config.active_storage.video_preview_arguments`](#config-active-storage-video-preview-arguments): `"-vf 'select=eq(n\\,0)+eq(key\\,1)+gt(scene\\,0.015),loop=loop=-1:size=2,trim=start_frame=1' -frames:v 1 -f image2"`
- [`config.active_support.cache_format_version`](#config-active-support-cache-format-version): `7.0`
- [`config.active_support.executor_around_test_case`](#config-active-support-executor-around-test-case): `true`
- [`config.active_support.hash_digest_class`](#config-active-support-hash-digest-class): `OpenSSL::Digest::SHA256`
- [`config.active_support.isolation_level`](#config-active-support-isolation-level): `:thread`
- [`config.active_support.key_generator_hash_digest_class`](#config-active-support-key-generator-hash-digest-class): `OpenSSL::Digest::SHA256`

#### ค่าเริ่มต้นสำหรับเวอร์ชันเป้าหมาย 6.1

- [`ActiveSupport.utc_to_local_returns_utc_offset_times`](#activesupport-utc-to-local-returns-utc-offset-times): `true`
- [`config.action_dispatch.cookies_same_site_protection`](#config-action-dispatch-cookies-same-site-protection): `:lax`
- [`config.action_dispatch.ssl_default_redirect_status`](#config-action-dispatch-ssl-default-redirect-status): `308`
- [`config.action_mailbox.queues.incineration`](#config-action-mailbox-queues-incineration): `nil`
- [`config.action_mailbox.queues.routing`](#config-action-mailbox-queues-routing): `nil`
- [`config.action_mailer.deliver_later_queue_name`](#config-action-mailer-deliver-later-queue-name): `nil`
- [`config.action_view.form_with_generates_remote_forms`](#config-action-view-form-with-generates-remote-forms): `false`
- [`config.action_view.preload_links_header`](#config-action-view-preload-links-header): `true`
- [`config.active_job.retry_jitter`](#config-active-job-retry-jitter): `0.15`
- [`config.active_record.has_many_inversing`](#config-active-record-has-many-inversing): `true`
- [`config.active_storage.queues.analysis`](#config-active-storage-queues-analysis): `nil`
- [`config.active_storage.queues.purge`](#config-active-storage-queues-purge): `nil`
- [`config.active_storage.track_variants`](#config-active-storage-track-variants): `true`

#### ค่าเริ่มต้นสำหรับเวอร์ชันเป้าหมาย 6.0

- [`config.action_dispatch.use_cookies_with_metadata`](#config-action-dispatch-use-cookies-with-metadata): `true`
- [`config.action_mailer.delivery_job`](#config-action-mailer-delivery-job): `"ActionMailer::MailDeliveryJob"`
- [`config.action_view.default_enforce_utf8`](#config-action-view-default-enforce-utf8): `false`
- [`config.active_record.collection_cache_versioning`](#config-active-record-collection-cache-versioning): `true`
- [`config.active_storage.queues.analysis`](#config-active-storage-queues-analysis): `:active_storage_analysis`
- [`config.active_storage.queues.purge`](#config-active-storage-queues-purge): `:active_storage_purge`

#### ค่าเริ่มต้นสำหรับเวอร์ชันเป้าหมาย 5.2

- [`config.action_controller.default_protect_from_forgery`](#config-action-controller-default-protect-from-forgery): `true`
- [`config.action_dispatch.use_authenticated_cookie_encryption`](#config-action-dispatch-use-authenticated-cookie-encryption): `true`
- [`config.action_view.form_with_generates_ids`](#config-action-view-form-with-generates-ids): `true`
- [`config.active_record.cache_versioning`](#config-active-record-cache-versioning): `true`
- [`config.active_support.hash_digest_class`](#config-active-support-hash-digest-class): `OpenSSL::Digest::SHA1`
- [`config.active_support.use_authenticated_message_encryption`](#config-active-support-use-authenticated-message-encryption): `true`

#### ค่าเริ่มต้นสำหรับเวอร์ชันเป้าหมาย 5.1

- [`config.action_view.form_with_generates_remote_forms`](#config-action-view-form-with-generates-remote-forms): `true`
- [`config.assets.unknown_asset_fallback`](#config-assets-unknown-asset-fallback): `false`

#### ค่าเริ่มต้นสำหรับเวอร์ชันเป้าหมาย 5.0
- [`ActiveSupport.to_time_preserves_timezone`](#activesupport-to-time-preserves-timezone): `true`
- [`config.action_controller.forgery_protection_origin_check`](#config-action-controller-forgery-protection-origin-check): `true`
- [`config.action_controller.per_form_csrf_tokens`](#config-action-controller-per-form-csrf-tokens): `true`
- [`config.active_record.belongs_to_required_by_default`](#config-active-record-belongs-to-required-by-default): `true`
- [`config.ssl_options`](#config-ssl-options): `{ hsts: { subdomains: true } }`

### การกำหนดค่าทั่วไปของ Rails

วิธีการกำหนดค่าต่อไปนี้จะถูกเรียกใช้บนอ็อบเจกต์ `Rails::Railtie` เช่นคลาสลูกของ `Rails::Engine` หรือ `Rails::Application`.

#### `config.add_autoload_paths_to_load_path`

กำหนดว่าจะต้องเพิ่มเส้นทางการโหลดอัตโนมัติไปยัง `$LOAD_PATH` หรือไม่ แนะนำให้ตั้งค่าเป็น `false` ในโหมด `:zeitwerk` ใน `config/application.rb` โดยเร็ว ๆ นี้ โดยที่ Zeitwerk ใช้เส้นทางแบบสัมพันธ์ภายในและแอปพลิเคชันที่ทำงานในโหมด `:zeitwerk` ไม่ต้องการ `require_dependency` ดังนั้นโมเดล คอนโทรลเลอร์ งาน ฯลฯ ไม่จำเป็นต้องอยู่ใน `$LOAD_PATH` การตั้งค่าเป็น `false` ช่วยประหยัดเวลาในการตรวจสอบไดเรกทอรีเหล่านี้เมื่อแก้ไข `require` ด้วยเส้นทางที่สัมพันธ์ภายใน และช่วยประหยัดการทำงานและหน่วยความจำของ Bootsnap เนื่องจากไม่จำเป็นต้องสร้างดัชนีสำหรับเส้นทางเหล่านี้

ค่าเริ่มต้นขึ้นอยู่กับเวอร์ชันเป้าหมายของ `config.load_defaults`:

| เริ่มต้นเวอร์ชัน | ค่าเริ่มต้นคือ |
| --------------------- | -------------------- |
| (เดิม)            | `true`               |
| 7.1                   | `false`              |

ไดเรกทอรี `lib` ไม่ได้รับผลกระทบจากตัวชี้นี้ เส้นทางนี้จะถูกเพิ่มเข้าไปยัง `$LOAD_PATH` เสมอ

#### `config.after_initialize`

รับบล็อกที่จะถูกเรียกใช้งาน _หลังจาก_ Rails เสร็จสิ้นการเริ่มต้นแอปพลิเคชัน ซึ่งรวมถึงการเริ่มต้นของเฟรมเวิร์กตัวเอง เอ็นจิน และอินิเชียไลเซอร์ทั้งหมดใน `config/initializers` โปรดทราบว่าบล็อกนี้ _จะ_ ถูกเรียกใช้สำหรับงาน rake มีประโยชน์ในการกำหนดค่าค่าที่ตั้งค่าโดยตัวกำหนดอื่น
```ruby
config.after_initialize do
  ActionView::Base.sanitized_allowed_tags.delete 'div'
end
```

#### `config.after_routes_loaded`

รับบล็อกที่จะทำงานหลังจากที่ Rails เสร็จสิ้นการโหลดเส้นทางแอปพลิเคชัน บล็อกนี้จะถูกเรียกใช้เมื่อโหลดเส้นทางใหม่

```ruby
config.after_routes_loaded do
  # โค้ดที่ทำงานกับ Rails.application.routes
end
```

#### `config.allow_concurrency`

ควบคุมว่าคำขอควรจะถูกจัดการพร้อมกันหรือไม่ ควรตั้งค่าเป็น `false` เฉพาะเมื่อโค้ดแอปพลิเคชันไม่ปลอดภัยสำหรับการใช้งานแบบเธรด ค่าเริ่มต้นคือ `true`.

#### `config.asset_host`

ตั้งค่าโฮสต์สำหรับแอสเซ็ต มีประโยชน์เมื่อใช้ CDN ในการโฮสต์แอสเซ็ต หรือเมื่อต้องการแก้ไขปัญหาการใช้งานพร็อกซีที่มีข้อจำกัดในการใช้งานพร้อมกันของเบราว์เซอร์โดยใช้ชื่อโดเมนที่แตกต่างกัน รุ่นย่อของ `config.action_controller.asset_host`.

#### `config.assume_ssl`

ทำให้แอปพลิเคชันเชื่อว่าคำขอทั้งหมดมาถึงผ่าน SSL มีประโยชน์เมื่อใช้พร็อกซีในการโหลดสมดุลของการเชื่อมต่อ SSL คำขอที่ถูกส่งต่อจะปรากฏว่าเป็น HTTP แทนที่จะเป็น HTTPS สำหรับแอปพลิเคชันนี้ มิดเวียร์นี้ทำให้เซิร์ฟเวอร์เชื่อมต่อว่าพร็อกซีได้สิ้นสุด SSL และคำขอจริงๆ เป็น HTTPS

#### `config.autoflush_log`

เปิดใช้งานการเขียนไฟล์บันทึกทันทีแทนที่จะเก็บไว้ในแบบเต็ม ค่าเริ่มต้นคือ `true`.

#### `config.autoload_once_paths`

รับอาร์เรย์ของเส้นทางที่ Rails จะโหลดค่าคงที่ที่จะไม่ถูกล้างต่อคำขอ สำคัญถ้าการโหลดใหม่ถูกเปิดใช้งาน ซึ่งค่าเริ่มต้นคืออาร์เรย์ว่าง.
#### `config.autoload_paths`

ยอมรับอาร์เรย์ของเส้นทางที่ Rails จะโหลดค่าคงที่ ค่าเริ่มต้นคืออาร์เรย์ว่างเปล่า ตั้งแต่ [Rails 6](upgrading_ruby_on_rails.html#autoloading) ไม่แนะนำให้ปรับเปลี่ยนค่านี้ ดูเพิ่มเติมที่ [Autoloading and Reloading Constants](autoloading_and_reloading_constants.html#autoload-paths).

#### `config.autoload_lib(ignore:)`

เมธอดนี้เพิ่ม `lib` เข้าไปใน `config.autoload_paths` และ `config.eager_load_paths`.

โดยปกติแล้ว ไดเรกทอรี `lib` มีไดเรกทอรีย่อยที่ไม่ควรโหลดค่าคงที่หรือโหลดค่าทันที กรุณาส่งชื่อของไดเรกทอรีย่อยเหล่านั้นที่เกี่ยวข้องกับ `lib` ในอาร์กิวเมนต์ `ignore` ที่ต้องการ ตัวอย่างเช่น

```ruby
config.autoload_lib(ignore: %w(assets tasks generators))
```

กรุณาดูรายละเอียดเพิ่มเติมใน [autoloading guide](autoloading_and_reloading_constants.html).

#### `config.autoload_lib_once(ignore:)`

เมธอด `config.autoload_lib_once` คล้ายกับ `config.autoload_lib` แต่เพิ่ม `lib` เข้าไปใน `config.autoload_once_paths` แทน

โดยเรียกใช้ `config.autoload_lib_once` คลาสและโมดูลใน `lib` สามารถโหลดค่าคงที่ได้ แม้จะเรียกใช้จาก application initializer แต่จะไม่ถูกโหลดค่าใหม่

#### `config.beginning_of_week`

ตั้งค่าวันเริ่มต้นของสัปดาห์เริ่มต้นสำหรับแอปพลิเคชัน ยอมรับวันในสัญลักษณ์ที่ถูกต้อง (เช่น `:monday`).

#### `config.cache_classes`

การตั้งค่าเก่าที่เทียบเท่ากับ `!config.enable_reloading` รองรับเพื่อความเข้ากันที่ย้อนหลัง

#### `config.cache_store`

กำหนดค่า cache store ที่ใช้สำหรับการเก็บแคชของ Rails ตัวเลือกประกอบด้วยหนึ่งในสัญลักษณ์ `:memory_store`, `:file_store`, `:mem_cache_store`, `:null_store`, `:redis_cache_store`, หรืออ็อบเจ็กต์ที่ดำเนินการ cache API ค่าเริ่มต้นคือ `:file_store` ดูเพิ่มเติมที่ [Cache Stores](caching_with_rails.html#cache-stores) สำหรับตัวเลือกการกำหนดค่าต่อสโตร์

#### `config.colorize_logging`

กำหนดว่าจะใช้รหัสสี ANSI ในการบันทึกข้อมูลหรือไม่ ค่าเริ่มต้นคือ `true`.
#### `config.consider_all_requests_local`

เป็นตัวแปรที่ใช้เป็นตัวกำหนดว่าจะแสดงข้อมูลการแก้ไขข้อผิดพลาดอย่างละเอียดในการตอบกลับ HTTP หรือไม่ ถ้าเป็น `true` จะแสดงข้อมูลการแก้ไขข้อผิดพลาดอย่างละเอียดในการตอบกลับ HTTP และคอนโทรลเลอร์ `Rails::Info` จะแสดงบริบทการทำงานของแอปพลิเคชันใน `/rails/info/properties` ค่าเริ่มต้นเป็น `true` ในสภาพแวดล้อมการพัฒนาและทดสอบ และ `false` ในสภาพแวดล้อมการใช้งานจริง สำหรับการควบคุมที่ละเอียดยิบ ให้ตั้งค่าเป็น `false` และสร้างฟังก์ชัน `show_detailed_exceptions?` ในคอนโทรลเลอร์เพื่อระบุว่าคำขอใดควรให้ข้อมูลการแก้ไขข้อผิดพลาดอย่างละเอียด

#### `config.console`

ช่วยให้คุณสามารถตั้งค่าคลาสที่จะใช้เป็นคอนโซลเมื่อคุณเรียกใช้ `bin/rails console` ควรเรียกใช้ในบล็อก `console`:

```ruby
console do
  # บล็อกนี้จะถูกเรียกเมื่อเรียกใช้คอนโซลเท่านั้น
  # เราสามารถ require pry ได้อย่างปลอดภัยที่นี่
  require "pry"
  config.console = Pry
end
```

#### `config.content_security_policy_nonce_directives`

ดู [การเพิ่ม Nonce](security.html#adding-a-nonce) ในเอกสารความปลอดภัย

#### `config.content_security_policy_nonce_generator`

ดู [การเพิ่ม Nonce](security.html#adding-a-nonce) ในเอกสารความปลอดภัย

#### `config.content_security_policy_report_only`

ดู [การรายงานการละเมิด](security.html#reporting-violations) ในเอกสารความปลอดภัย

#### `config.credentials.content_path`

เป็นพาธของไฟล์ข้อมูลรหัสลับที่เข้ารหัส

ค่าเริ่มต้นคือ `config/credentials/#{Rails.env}.yml.enc` หากมี หรือ `config/credentials.yml.enc` หากไม่มี

หมายเหตุ: เพื่อให้คำสั่ง `bin/rails credentials` รู้จักค่านี้ คุณต้องตั้งค่าใน `config/application.rb` หรือ `config/environments/#{Rails.env}.rb`

#### `config.credentials.key_path`

เป็นพาธของไฟล์กุญแจรหัสลับที่เข้ารหัส
เริ่มต้นที่ `config/credentials/#{Rails.env}.key` ถ้ามีอยู่ หรือ
`config/master.key` ถ้าไม่มีอยู่

หมายเหตุ: เพื่อให้คำสั่ง `bin/rails credentials` รับรู้ค่านี้ได้
จะต้องตั้งค่าใน `config/application.rb` หรือ `config/environments/#{Rails.env}.rb`

#### `config.debug_exception_response_format`

ตั้งค่ารูปแบบที่ใช้ในการตอบสนองเมื่อเกิดข้อผิดพลาดในสภาพแวดล้อมการพัฒนา ค่าเริ่มต้นคือ `:api` สำหรับแอปเฉพาะ API เท่านั้น และ `:default` สำหรับแอปปกติ

#### `config.disable_sandbox`

ควบคุมว่าใครสามารถเริ่ม console ในโหมด sandbox ได้หรือไม่ สามารถช่วยเพื่อหลีกเลี่ยงการเรียกใช้งาน console ในโหมด sandbox ที่ใช้เวลานาน ซึ่งอาจทำให้เซิร์ฟเวอร์ฐานข้อมูลใช้หน่วยความจำหมด ค่าเริ่มต้นคือ `false`

#### `config.eager_load`

เมื่อเป็น `true` จะโหลดทุก `config.eager_load_namespaces` ที่ลงทะเบียนไว้ รวมถึงแอปพลิเคชันของคุณ เอ็นจินของ Rails และเนมสเปซที่ลงทะเบียนอื่น ๆ

#### `config.eager_load_namespaces`

ลงทะเบียนเนมสเปซที่จะโหลดแบบกระตุ้นเมื่อ `config.eager_load` ถูกตั้งค่าเป็น `true` ทุกเนมสเปซในรายการต้องตอบสนองต่อเมธอด `eager_load!`

#### `config.eager_load_paths`

ยอมรับอาร์เรย์ของเส้นทางที่ Rails จะโหลดแบบกระตุ้นเมื่อเริ่มต้น ถ้า `config.eager_load` เป็นจริง ค่าเริ่มต้นคือโฟลเดอร์ทุกๆ โฟลเดอร์ในไดเรกทอรี `app` ของแอปพลิเคชัน

#### `config.enable_reloading`

หาก `config.enable_reloading` เป็นจริง คลาสและโมดูลของแอปพลิเคชันจะโหลดใหม่ระหว่างคำขอเว็บถ้ามีการเปลี่ยนแปลง ค่าเริ่มต้นคือ `true` ในสภาพแวดล้อม `development` และ `false` ในสภาพแวดล้อม `production`
พจนานุกรม `config.reloading_enabled?` ก็ถูกกำหนดไว้

#### `config.encoding`

กำหนดการเข้ารหัสทั่วไปของแอปพลิเคชัน ค่าเริ่มต้นคือ UTF-8

#### `config.exceptions_app`

กำหนดแอปพลิเคชันที่ใช้เรียกใช้เมื่อเกิดข้อผิดพลาดโดย `ShowException` middleware
ค่าเริ่มต้นคือ `ActionDispatch::PublicExceptions.new(Rails.public_path)`.

แอปพลิเคชันข้อผิดพลาดต้องจัดการข้อผิดพลาด `ActionDispatch::Http::MimeNegotiation::InvalidType` ที่เกิดขึ้นเมื่อไคลเอ็นต์ส่ง `Accept` หรือ `Content-Type` header ที่ไม่ถูกต้อง
แอปพลิเคชัน `ActionDispatch::PublicExceptions` ค่าเริ่มต้นจะทำการจัดการอัตโนมัติโดยตั้งค่า `Content-Type` เป็น `text/html` และส่งค่าสถานะ `406 Not Acceptable`
หากไม่ได้จัดการข้อผิดพลาดนี้ จะทำให้เกิดข้อผิดพลาด `500 Internal Server Error`

การใช้ `Rails.application.routes` `RouteSet` เป็นแอปพลิเคชันข้อผิดพลาด ยังต้องการการจัดการเฉพาะนี้ด้วย
อาจมีลักษณะเช่นนี้:

```ruby
# config/application.rb
config.exceptions_app = CustomExceptionsAppWrapper.new(exceptions_app: routes)

# lib/custom_exceptions_app_wrapper.rb
class CustomExceptionsAppWrapper
  def initialize(exceptions_app:)
    @exceptions_app = exceptions_app
  end

  def call(env)
    request = ActionDispatch::Request.new(env)

    fallback_to_html_format_if_invalid_mime_type(request)

    @exceptions_app.call(env)
  end

  private
    def fallback_to_html_format_if_invalid_mime_type(request)
      request.formats
    rescue ActionDispatch::Http::MimeNegotiation::InvalidType
      request.set_header "CONTENT_TYPE", "text/html"
    end
end
```

#### `config.file_watcher`

เป็นคลาสที่ใช้ตรวจสอบการอัปเดตไฟล์ในระบบไฟล์เมื่อ `config.reload_classes_only_on_change` เป็น `true`  Rails มาพร้อมกับ `ActiveSupport::FileUpdateChecker` ค่าเริ่มต้น และ `ActiveSupport::EventedFileUpdateChecker` (ตัวนี้ขึ้นอยู่กับ [listen](https://github.com/guard/listen) gem) คลาสที่กำหนดเองต้องเป็นไปตาม `ActiveSupport::FileUpdateChecker` API

#### `config.filter_parameters`

ใช้สำหรับกรองพารามิเตอร์ที่คุณไม่ต้องการแสดงในบันทึก เช่น รหัสผ่านหรือหมายเลขบัตรเครดิต มันยังกรองค่าที่เป็นความลับของคอลัมน์ในฐานข้อมูลเมื่อเรียกใช้ `#inspect` บนออบเจ็กต์ Active Record โดยค่าเริ่มต้น Rails กรองรหัสผ่านโดยเพิ่มตัวกรองต่อไปนี้ใน `config/initializers/filter_parameter_logging.rb`.
```ruby
Rails.application.config.filter_parameters += [
  :passw, :secret, :token, :_key, :crypt, :salt, :certificate, :otp, :ssn
]
```

การกรองพารามิเตอร์ทำงานโดยการจับคู่กับ regular expression บางส่วน

#### `config.filter_redirect`

ใช้สำหรับกรอง URL การเปลี่ยนเส้นทางออกจากบันทึกแอปพลิเคชัน

```ruby
Rails.application.config.filter_redirect += ['s3.amazonaws.com', /private-match/]
```

ตัวกรองการเปลี่ยนเส้นทางทำงานโดยการทดสอบว่า URL รวมสตริงหรือตรงกับ regular expression

#### `config.force_ssl`

บังคับให้คำขอทั้งหมดเป็นการให้บริการผ่าน HTTPS และตั้งค่า "https://" เป็นโปรโตคอลเริ่มต้นเมื่อสร้าง URL การบังคับใช้ HTTPS จัดการโดย middleware `ActionDispatch::SSL` ซึ่งสามารถกำหนดค่าได้ผ่าน `config.ssl_options`

#### `config.helpers_paths`

กำหนดอาร์เรย์ของเส้นทางเพิ่มเติมเพื่อโหลดเฮลเปอร์ของวิว

#### `config.host_authorization`

ยอมรับแฮชของตัวเลือกเพื่อกำหนดค่า middleware [HostAuthorization](#actiondispatch-hostauthorization)

#### `config.hosts`

อาร์เรย์ของสตริง, regular expression, หรือ `IPAddr` ที่ใช้สำหรับการตรวจสอบ `Host` หัวข้อ ใช้โดย middleware [HostAuthorization](#actiondispatch-hostauthorization) เพื่อช่วยป้องกันการโจมตี DNS rebinding

#### `config.javascript_path`

กำหนดเส้นทางที่ JavaScript ของแอปของคุณอยู่ในเชิงสัมพันธ์กับไดเรกทอรี `app` เริ่มต้นคือ `javascript` ที่ใช้โดย [webpacker](https://github.com/rails/webpacker) เส้นทาง JavaScript ที่กำหนดค่าของแอปจะถูกยกเว้นจาก `autoload_paths`

#### `config.log_file_size`

กำหนดขนาดสูงสุดของไฟล์บันทึก Rails ในไบต์ ค่าเริ่มต้นคือ `104_857_600` (100 MiB) ในโหมดการพัฒนาและทดสอบ และไม่จำกัดในสภาพแวดล้อมอื่น ๆ

#### `config.log_formatter`
กำหนดรูปแบบของตัวจัดรูปของ Rails logger ตัวเลือกนี้จะมีค่าเริ่มต้นเป็นตัวอย่างของ `ActiveSupport::Logger::SimpleFormatter` สำหรับทุกสภาวะการทำงาน หากคุณกำหนดค่าสำหรับ `config.logger` คุณต้องกำหนดค่าตัวจัดรูปของคุณให้กับ logger ของคุณด้วยตนเองก่อนที่จะถูกห่อหุ้มด้วยตัวอย่างของ `ActiveSupport::TaggedLogging` ระบบ Rails จะไม่ทำให้คุณได้

#### `config.log_level`

กำหนดความละเอียดของ Rails logger ตัวเลือกนี้จะมีค่าเริ่มต้นเป็น `:debug` สำหรับทุกสภาวะการทำงานยกเว้นสภาวะการทำงานในสภาพแวดล้อมการผลิต ซึ่งมีค่าเริ่มต้นเป็น `:info` ระดับการบันทึกที่มีอยู่คือ `:debug`, `:info`, `:warn`, `:error`, `:fatal`, และ `:unknown`

#### `config.log_tags`

ยอมรับรายการของเมธอดที่วัตถุ `request` ตอบสนอง, `Proc` ที่ยอมรับวัตถุ `request`, หรืออะไรก็ตามที่ตอบสนองกับ `to_s` สิ่งนี้ทำให้ง่ายต่อการแท็กบันทึกด้วยข้อมูลการแก้ปัญหาเช่น subdomain และ request id - ทั้งคู่เป็นประโยชน์มากในการแก้ปัญหาแอปพลิเคชันการผลิตที่มีผู้ใช้หลายคน

#### `config.logger`

เป็น logger ที่จะใช้สำหรับ `Rails.logger` และการบันทึก Rails ที่เกี่ยวข้อง เช่น `ActiveRecord::Base.logger` มีค่าเริ่มต้นเป็นตัวอย่างของ `ActiveSupport::TaggedLogging` ที่ห่อหุ้มด้วยตัวอย่างของ `ActiveSupport::Logger` ซึ่งจะแสดงผลล็อกไปยังไดเรกทอรี `log/` คุณสามารถให้ logger ที่กำหนดเอง ในการให้ความเข้ากันได้อย่างเต็มที่คุณต้องปฏิบัติตามแนวทางเหล่านี้:

* เพื่อรองรับตัวจัดรูปคุณต้องกำหนดตัวจัดรูปจากค่า `config.log_formatter` ให้กับ logger ด้วยตนเอง
* เพื่อรองรับการแท็กบันทึก ตัวอย่างของล็อกต้องห่อหุ้มด้วย `ActiveSupport::TaggedLogging`
* เพื่อรองรับการปิดเสียง ตัว logger ต้องรวม `ActiveSupport::LoggerSilence` module คลาส `ActiveSupport::Logger` มีการรวมโมดูลเหล่านี้แล้ว
```ruby
class MyLogger < ::Logger
  include ActiveSupport::LoggerSilence
end

mylogger           = MyLogger.new(STDOUT)
mylogger.formatter = config.log_formatter
config.logger      = ActiveSupport::TaggedLogging.new(mylogger)
```

#### `config.middleware`

ช่วยให้คุณกำหนดค่า middleware ของแอปพลิเคชัน สามารถศึกษาเพิ่มเติมได้ในส่วน [การกำหนดค่า Middleware](#configuring-middleware) ด้านล่าง

#### `config.precompile_filter_parameters`

เมื่อเป็น `true` จะทำการ precompile [`config.filter_parameters`](#config-filter-parameters) โดยใช้ [`ActiveSupport::ParameterFilter.precompile_filters`][]

ค่าเริ่มต้นขึ้นอยู่กับเวอร์ชันเป้าหมายของ `config.load_defaults`:

| เริ่มต้นเวอร์ชัน | ค่าเริ่มต้น |
| --------------------- | -------------------- |
| (เดิม)            | `false`              |
| 7.1                   | `true`               |


#### `config.public_file_server.enabled`

กำหนดค่าให้ Rails เซิร์ฟไฟล์สแตติกจากไดเรกทอรี public ตัวเลือกนี้มีค่าเริ่มต้นเป็น `true` แต่ในสภาวะการทำงานในสภาพแวดล้อมการผลิต มันถูกตั้งค่าเป็น `false` เนื่องจากซอฟต์แวร์เซิร์ฟเวอร์ (เช่น NGINX หรือ Apache) ที่ใช้ในการเรียกใช้แอปพลิเคชันควรเซิร์ฟไฟล์สแตติกแทน หากคุณกำลังเรียกใช้แอปพลิเคชันหรือทดสอบในสภาพแวดล้อมการผลิตโดยใช้ WEBrick (ไม่แนะนำให้ใช้ WEBrick ในสภาพแวดล้อมการผลิต) ให้ตั้งค่าตัวเลือกเป็น `true` มิฉะนั้นคุณจะไม่สามารถใช้การแคชหน้าและขอไฟล์ที่อยู่ในไดเรกทอรี public ได้

#### `config.railties_order`

ช่วยกำหนดลำดับที่ Railties/Engines จะถูกโหลด ค่าเริ่มต้นคือ `[:all]`.

```ruby
config.railties_order = [Blog::Engine, :main_app, :all]
```

#### `config.rake_eager_load`

เมื่อเป็น `true` จะโหลดแอปพลิเคชันทันทีเมื่อเรียกใช้งาน Rake tasks ค่าเริ่มต้นคือ `false`.
#### `config.read_encrypted_secrets`

*เบื่องต้น*: คุณควรใช้ [credentials](https://guides.rubyonrails.org/security.html#custom-credentials) แทน encrypted secrets

เมื่อเป็น `true` จะพยายามอ่าน encrypted secrets จาก `config/secrets.yml.enc`

#### `config.relative_url_root`

ใช้บอก Rails ว่าคุณกำลัง [deploy ไปยัง subdirectory](configuring.html#deploy-to-a-subdirectory-relative-url-root) ค่าเริ่มต้นคือ `ENV['RAILS_RELATIVE_URL_ROOT']`

#### `config.reload_classes_only_on_change`

เปิดหรือปิดการโหลดคลาสเฉพาะเมื่อไฟล์ที่ติดตามเปลี่ยนแปลง ค่าเริ่มต้นคือการติดตามทุกอย่างใน autoload paths และตั้งค่าเป็น `true` หาก `config.enable_reloading` เป็น `false` ตัวเลือกนี้จะถูกละเว้น

#### `config.require_master_key`

ทำให้แอปไม่สามารถเริ่มต้นได้หากไม่มี master key ที่สามารถใช้ได้ผ่าน `ENV["RAILS_MASTER_KEY"]` หรือไฟล์ `config/master.key`

#### `config.secret_key_base`

ค่า fallback สำหรับระบุ secret ของ key generator ของแอปพลิเคชัน แนะนำให้ไม่ตั้งค่าค่านี้และใช้ `secret_key_base` ที่ระบุใน `config/credentials.yml.enc` ดูเพิ่มเติมและวิธีการตั้งค่าทางเลือกอื่นๆได้ที่ [เอกสาร API `secret_key_base`](https://api.rubyonrails.org/classes/Rails/Application.html#method-i-secret_key_base)

#### `config.server_timing`

เมื่อเป็น `true` จะเพิ่ม [ServerTiming middleware](#actiondispatch-servertiming) เข้าไปใน middleware stack

#### `config.session_options`

ตัวเลือกเพิ่มเติมที่ส่งผ่านไปยัง `config.session_store` คุณควรใช้ `config.session_store` เพื่อตั้งค่านี้แทนที่จะแก้ไขด้วยตัวคุณเอง

```ruby
config.session_store :cookie_store, key: "_your_app_session"
config.session_options # => {key: "_your_app_session"}
```

#### `config.session_store`

ระบุคลาสที่จะใช้เก็บ session ค่าที่เป็นไปได้คือ `:cache_store`, `:cookie_store`, `:mem_cache_store`, custom store, หรือ `:disabled` `:disabled` บอก Rails ว่าไม่ต้องจัดการกับ sessions
การตั้งค่านี้ถูกกำหนดผ่านการเรียกใช้เมธอดปกติ ไม่ใช่เมธอด setter ซึ่งอนุญาตให้ส่งตัวเลือกเพิ่มเติมได้:

```ruby
config.session_store :cookie_store, key: "_your_app_session"
```

หากกำหนดร้านค้าที่กำหนดเองเป็นสัญลักษณ์ จะถูกแก้ไขให้เป็นเนมสเปซ `ActionDispatch::Session`:

```ruby
# ใช้ ActionDispatch::Session::MyCustomStore เป็นร้านค้าเซสชัน
config.session_store :my_custom_store
```

ร้านค้าเริ่มต้นคือร้านค้าคุกกี้ที่มีชื่อแอปพลิเคชันเป็นคีย์เซสชัน

#### `config.ssl_options`

ตัวเลือกการกำหนดค่าสำหรับ middleware [`ActionDispatch::SSL`](https://api.rubyonrails.org/classes/ActionDispatch/SSL.html)

ค่าเริ่มต้นขึ้นอยู่กับเวอร์ชันเป้าหมายของ `config.load_defaults`:

| เริ่มต้นด้วยเวอร์ชัน | ค่าเริ่มต้นคือ |
| --------------------- | -------------------- |
| (เดิม)            | `{}`                 |
| 5.0                   | `{ hsts: { subdomains: true } }` |

#### `config.time_zone`

ตั้งค่าโซนเวลาเริ่มต้นสำหรับแอปพลิเคชันและเปิดใช้งานการรับรู้โซนเวลาสำหรับ Active Record

#### `config.x`

ใช้ในการเพิ่มการกำหนดค่าที่กำหนดเองที่ซ้อนกันได้ง่ายในอ็อบเจกต์การกำหนดค่าแอปพลิเคชัน

  ```ruby
  config.x.payment_processing.schedule = :daily
  Rails.configuration.x.payment_processing.schedule # => :daily
  ```

ดู [การกำหนดค่าที่กำหนดเอง](#การกำหนดค่าที่กำหนดเอง)

### การกำหนดค่าทรัพยากร

#### `config.assets.css_compressor`

กำหนดตัวบีบอัด CSS ที่จะใช้ ถูกกำหนดค่าโดย `sass-rails` ค่าทางเลือกที่ไม่ซ้ำกันที่มีอยู่ในขณะนี้คือ `:yui` ซึ่งใช้ gem `yui-compressor`

#### `config.assets.js_compressor`

กำหนดตัวบีบอัด JavaScript ที่จะใช้ ค่าที่เป็นไปได้คือ `:terser`, `:closure`, `:uglifier`, และ `:yui` ซึ่งต้องใช้ gem `terser`, `closure-compiler`, `uglifier`, หรือ `yui-compressor` ตามลำดับ
#### `config.assets.gzip`

เป็นตัวแปรที่เปิดใช้งานการสร้างเวอร์ชันที่ถูกบีบอัดของคอมไพล์แอสเซ็ตพร้อมกับแอสเซ็ตที่ไม่ได้ถูกบีบอัด ถูกตั้งค่าเป็น `true` โดยค่าเริ่มต้น

#### `config.assets.paths`

มีเส้นทางที่ใช้ในการค้นหาแอสเซ็ต การเพิ่มเส้นทางไปยังตัวเลือกการกำหนดค่านี้จะทำให้ใช้เส้นทางเหล่านั้นในการค้นหาแอสเซ็ต

#### `config.assets.precompile`

ช่วยให้คุณระบุแอสเซ็ตเพิ่มเติม (นอกเหนือจาก `application.css` และ `application.js`) ที่จะถูกคอมไพล์ล่วงหน้าเมื่อรัน `bin/rails assets:precompile`

#### `config.assets.unknown_asset_fallback`

ช่วยให้คุณปรับแต่งพฤติกรรมของไลน์แอสเซ็ตเมื่อแอสเซ็ตไม่อยู่ในไลน์แอสเซ็ต หากคุณใช้ sprockets-rails เวอร์ชัน 3.2.0 หรือใหม่กว่า

ค่าเริ่มต้นขึ้นอยู่กับเวอร์ชันเป้าหมายของ `config.load_defaults`:

| เริ่มต้นเวอร์ชัน | ค่าเริ่มต้นคือ |
| --------------------- | -------------------- |
| (เดิม)            | `true`               |
| 5.1                   | `false`              |

#### `config.assets.prefix`

กำหนดคำนำหน้าที่แอสเซ็ตจะให้บริการ ค่าเริ่มต้นคือ `/assets`

#### `config.assets.manifest`

กำหนดเส้นทางเต็มที่ใช้สำหรับไฟล์ manifest ของตัวคอมไพล์แอสเซ็ต ค่าเริ่มต้นคือไฟล์ที่ชื่อว่า `manifest-<random>.json` ในไดเรกทอรี `config.assets.prefix` ภายในโฟลเดอร์ public

#### `config.assets.digest`

เปิดใช้งานการใช้รหัสลับ SHA256 ในชื่อแอสเซ็ต ค่าเริ่มต้นคือ `true`

#### `config.assets.debug`

ปิดใช้งานการรวมและบีบอัดแอสเซ็ต ค่าเริ่มต้นคือ `true` ใน `development.rb`
#### `config.assets.version`

เป็นตัวเลือกสตริงที่ใช้ในการสร้าง SHA256 hash สามารถเปลี่ยนแปลงได้เพื่อบังคับให้ทุกไฟล์ถูกคอมไพล์ใหม่

#### `config.assets.compile`

เป็นบูลีนที่ใช้เพื่อเปิดใช้งานการคอมไพล์ Sprockets แบบสดในโปรดักชัน

#### `config.assets.logger`

รับ logger ที่เป็นไปตามอินเตอร์เฟซของ Log4r หรือคลาส `Logger` ของ Ruby ที่กำหนดไว้ที่ `config.logger` ค่าเริ่มต้นเหมือนกับที่กำหนดไว้ที่ `config.logger` การตั้งค่า `config.assets.logger` เป็น `false` จะปิดการบันทึกข้อมูลทรัพยากรที่ให้บริการ

#### `config.assets.quiet`

ปิดการบันทึกคำขอทรัพยากร ค่าเริ่มต้นเป็น `true` ใน `development.rb`

### การกำหนดค่า Generators

Rails ช่วยให้คุณสามารถเปลี่ยนแปลง generators ที่ใช้กับเมธอด `config.generators` ได้ โดยเมธอดนี้รับพารามิเตอร์เป็นบล็อก:

```ruby
config.generators do |g|
  g.orm :active_record
  g.test_framework :test_unit
end
```

เซตเต็มของเมธอดที่สามารถใช้ในบล็อกนี้คือ:

* `force_plural` อนุญาตให้ใช้ชื่อโมเดลที่เป็นพหูพจน์ ค่าเริ่มต้นคือ `false`
* `helper` กำหนดว่าจะสร้าง helpers หรือไม่ ค่าเริ่มต้นคือ `true`
* `integration_tool` กำหนดเครื่องมือการรวมข้อมูลที่จะใช้ในการสร้างการทดสอบการรวมข้อมูล ค่าเริ่มต้นคือ `:test_unit`
* `system_tests` กำหนดเครื่องมือการรวมข้อมูลที่จะใช้ในการสร้างการทดสอบระบบ ค่าเริ่มต้นคือ `:test_unit`
* `orm` กำหนดว่าจะใช้ orm ใด ค่าเริ่มต้นคือ `false` และจะใช้ Active Record เป็นค่าเริ่มต้น
* `resource_controller` กำหนด generator ที่จะใช้สำหรับการสร้างคอนโทรลเลอร์เมื่อใช้ `bin/rails generate resource` ค่าเริ่มต้นคือ `:controller`
* `resource_route` กำหนดว่าจะสร้างการกำหนดเส้นทางทรัพยากรหรือไม่ ค่าเริ่มต้นคือ `true`
* `scaffold_controller` ต่างจาก `resource_controller` กำหนด generator ที่จะใช้สำหรับการสร้างคอนโทรลเลอร์ที่ถูกสร้างขึ้นโดยใช้ `bin/rails generate scaffold` ค่าเริ่มต้นคือ `:scaffold_controller`
* `test_framework` กำหนด framework ทดสอบที่จะใช้ ค่าเริ่มต้นคือ `false` และจะใช้ minitest เป็นค่าเริ่มต้น
* `template_engine` กำหนดเครื่องมือสร้างเทมเพลตที่จะใช้ เช่น ERB หรือ Haml ค่าเริ่มต้นคือ `:erb`
### การกำหนดค่า Middleware

แอปพลิเคชัน Rails ทุกตัวมาพร้อมกับชุดของ middleware มาตรฐานที่ใช้ในลำดับต่อไปนี้ในสภาพแวดล้อมการพัฒนา:

#### `ActionDispatch::HostAuthorization`

ป้องกันการโจมตี DNS rebinding และการโจมตี `Host` header อื่น ๆ
มันถูกเพิ่มในสภาพแวดล้อมการพัฒนาโดยค่าเริ่มต้นดังนี้:

```ruby
Rails.application.config.hosts = [
  IPAddr.new("0.0.0.0/0"),        # ทุกที่อยู่ IPv4
  IPAddr.new("::/0"),             # ทุกที่อยู่ IPv6
  "localhost",                    # โดเมน localhost ที่สงวนไว้
  ENV["RAILS_DEVELOPMENT_HOSTS"]  # โฮสต์เพิ่มเติมที่คั่นด้วยเครื่องหมายจุลภาคสำหรับการพัฒนา
]
```

ในสภาพแวดล้อมอื่น ๆ `Rails.application.config.hosts` จะเป็นค่าว่างเปล่าและไม่มีการตรวจสอบ `Host` header ที่จะทำ
หากคุณต้องการป้องกันการโจมตี header ในการดำเนินงานจริง คุณต้องอนุญาตโฮสต์ที่ได้รับอนุญาตด้วยตนเอง
ด้วย:

```ruby
Rails.application.config.hosts << "product.com"
```

โฮสต์ของคำขอจะถูกตรวจสอบกับรายการ `hosts` ด้วยตัวดำเนินการเคส (`#===`) ซึ่งช่วยให้ `hosts` สนับสนุนรายการประเภท `Regexp`,
`Proc` และ `IPAddr` เป็นต้น นี่คือตัวอย่างที่มี regexp.

```ruby
# อนุญาตคำขอจาก subdomain เช่น `www.product.com` และ
# `beta1.product.com`.
Rails.application.config.hosts << /.*\.product\.com/
```

regexp ที่ให้มาจะถูกครอบด้วย anchor (`\A` และ `\z`) ดังนั้นจะต้องตรงกับชื่อโฮสต์ทั้งหมด `/product.com/`, เช่น, เมื่อถูกตรึง
จะไม่สามารถตรงกับ `www.product.com` ได้

มีกรณีพิเศษที่รองรับให้คุณอนุญาตทุก sub-domain:
```ruby
# อนุญาตให้ร้องขอจาก subdomain เช่น `www.product.com` และ `beta1.product.com`
Rails.application.config.hosts << ".product.com"
```

คุณสามารถยกเว้นการตรวจสอบการอนุญาตจาก Host บางร้องขอได้โดยการตั้งค่า `config.host_authorization.exclude`:

```ruby
# ยกเว้นการร้องขอสำหรับเส้นทาง /healthcheck/ จากการตรวจสอบ Host
Rails.application.config.host_authorization = {
  exclude: ->(request) { request.path.include?('healthcheck') }
}
```

เมื่อมีการร้องขอจาก Host ที่ไม่ได้รับอนุญาต แอปพลิเคชัน Rack ที่ตั้งค่าเริ่มต้นจะทำงานและตอบกลับด้วย `403 Forbidden` สามารถกำหนดเองได้โดยการตั้งค่า `config.host_authorization.response_app` ตัวอย่างเช่น:

```ruby
Rails.application.config.host_authorization = {
  response_app: -> env do
    [400, { "Content-Type" => "text/plain" }, ["Bad Request"]]
  end
}
```

#### `ActionDispatch::ServerTiming`

เพิ่มเมตริกในส่วนหัว `Server-Timing` เพื่อดูในเครื่องมือการพัฒนาของเบราว์เซอร์

#### `ActionDispatch::SSL`

บังคับให้ทุกคำขอใช้ HTTPS ถูกเรียกใช้ ถ้า `config.force_ssl` ถูกตั้งค่าเป็น `true` ตัวเลือกที่ถูกส่งผ่านไปยังนี้สามารถกำหนดค่าได้โดยการตั้งค่า `config.ssl_options`

#### `ActionDispatch::Static`

ใช้ในการให้บริการคุณสมบัติแบบสถิต ถูกปิดใช้งานถ้า `config.public_file_server.enabled` เป็น `false` ตั้งค่า `config.public_file_server.index_name` หากคุณต้องการให้บริการไดเรกทอรีสถิตที่ไม่มีชื่อว่า `index` ตัวอย่างเช่น เพื่อให้บริการ `main.html` แทน `index.html` สำหรับคำขอไดเรกทอรี ให้ตั้งค่า `config.public_file_server.index_name` เป็น `"main"`

#### `ActionDispatch::Executor`

อนุญาตให้โค้ดสามารถโหลดใหม่ได้ในสภาพแวดล้อมที่ปลอดภัยในเรื่องเธรด ถูกปิดใช้งานถ้า `config.allow_concurrency` เป็น `false` ซึ่งทำให้ `Rack::Lock` ถูกโหลด เพื่อครอบคลุมแอปพลิเคชันด้วย mutex เพื่อให้สามารถเรียกใช้ได้โดยเธรดเดียวในเวลาใดเวลาหนึ่ง
#### `ActiveSupport::Cache::Strategy::LocalCache`

ใช้เป็นแคชแบบหน่วยความจำพื้นฐาน แคชนี้ไม่ปลอดภัยในกระบวนการเชื่อมต่อแบบเธรดและมีไว้เพียงสำหรับใช้เป็นแคชหน่วยความจำชั่วคราวสำหรับเธรดเดียว

#### `Rack::Runtime`

ตั้งค่าส่วนหัว `X-Runtime` ซึ่งประกอบด้วยเวลาที่ใช้ในการประมวลผลคำขอ (เป็นวินาที)

#### `Rails::Rack::Logger`

แจ้งให้บันทึกข้อมูลว่าคำขอได้เริ่มต้นแล้ว หลังจากคำขอเสร็จสิ้น จะทำการล้างบันทึกทั้งหมด

#### `ActionDispatch::ShowExceptions`

รับข้อยกเว้นที่ส่งกลับจากแอปพลิเคชันและแสดงหน้าข้อยกเว้นที่สวยงามถ้าคำขอเป็นภาคท้องถิ่นหรือถ้า `config.consider_all_requests_local` ถูกตั้งค่าเป็น `true` หาก `config.action_dispatch.show_exceptions` ถูกตั้งค่าเป็น `:none` ข้อยกเว้นจะถูกยกเว้นอย่างไม่ว่างานจะเกิดขึ้น

#### `ActionDispatch::RequestId`

ทำให้สามารถใช้ส่วนหัว X-Request-Id ที่ไม่ซ้ำกันให้ใช้งานได้ในการตอบสนองและเปิดใช้งานเมธอด `ActionDispatch::Request#uuid` สามารถกำหนดค่าได้ด้วย `config.action_dispatch.request_id_header`

#### `ActionDispatch::RemoteIp`

ตรวจสอบการโจมตี IP spoofing และรับ `client_ip` ที่ถูกต้องจากส่วนหัวคำขอ สามารถกำหนดค่าได้ด้วยตัวเลือก `config.action_dispatch.ip_spoofing_check` และ `config.action_dispatch.trusted_proxies`

#### `Rack::Sendfile`

แทรกตัวรับข้อมูลที่ตอบสนองที่มีเนื้อหาเป็นไฟล์และแทนที่ด้วยส่วนหัว X-Sendfile ที่เซิร์ฟเวอร์เฉพาะ สามารถกำหนดค่าได้ด้วย `config.action_dispatch.x_sendfile_header`

#### `ActionDispatch::Callbacks`

เรียกใช้งานคำสั่งเตรียมก่อนให้บริการคำขอ

#### `ActionDispatch::Cookies`

ตั้งค่าคุกกี้สำหรับคำขอ

#### `ActionDispatch::Session::CookieStore`

รับผิดชอบการเก็บรักษาเซสชันในคุกกี้ สามารถใช้ middleware ทดแทนได้โดยการเปลี่ยน [`config.session_store`](#config-session-store)
#### `ActionDispatch::Flash`

ตั้งค่า `flash` keys ที่ใช้ได้เฉพาะเมื่อ [`config.session_store`](#config-session-store) ถูกตั้งค่าเป็นค่าใดค่าหนึ่ง

#### `Rack::MethodOverride`

อนุญาตให้เมธอดถูกแทนที่หาก `params[:_method]` ถูกตั้งค่า นี่คือ middleware ที่รองรับเมธอด PATCH, PUT, และ DELETE ของ HTTP

#### `Rack::Head`

แปลงคำขอ HEAD เป็นคำขอ GET และให้บริการในรูปแบบนั้น

#### เพิ่ม Middleware ที่กำหนดเอง

นอกจาก Middleware ทั่วไปเหล่านี้แล้ว คุณสามารถเพิ่ม Middleware ของคุณเองได้โดยใช้เมธอด `config.middleware.use`:

```ruby
config.middleware.use Magical::Unicorns
```

นี้จะใส่ Middleware `Magical::Unicorns` ไว้ที่สุดของสแต็ก คุณสามารถใช้ `insert_before` หากคุณต้องการเพิ่ม Middleware ก่อนอันอื่น

```ruby
config.middleware.insert_before Rack::Head, Magical::Unicorns
```

หรือคุณสามารถแทรก Middleware ไปยังตำแหน่งที่แน่นอนโดยใช้ดัชนี ตัวอย่างเช่น หากคุณต้องการแทรก Middleware `Magical::Unicorns` ไว้ด้านบนสุดของสแต็ก คุณสามารถทำได้ดังนี้:

```ruby
config.middleware.insert_before 0, Magical::Unicorns
```

ยังมี `insert_after` ซึ่งจะแทรก Middleware หลัง Middleware อื่น:

```ruby
config.middleware.insert_after Rack::Head, Magical::Unicorns
```

Middleware ยังสามารถถูกแทนที่แบบสมบูรณ์และถูกแทนที่ด้วย Middleware อื่นได้:

```ruby
config.middleware.swap ActionController::Failsafe, Lifo::Failsafe
```

Middleware สามารถถูกย้ายจากที่หนึ่งไปยังที่อื่นได้:

```ruby
config.middleware.move_before ActionDispatch::Flash, Magical::Unicorns
```

นี้จะย้าย Middleware `Magical::Unicorns` ไปก่อน `ActionDispatch::Flash` คุณยังสามารถย้ายไปหลังได้:
```ruby
config.middleware.move_after ActionDispatch::Flash, Magical::Unicorns
```

คุณยังสามารถลบ middleware ออกจาก stack ได้เช่นกัน:

```ruby
config.middleware.delete Rack::MethodOverride
```

### การกำหนดค่า i18n

ตัวเลือกการกำหนดค่าเหล่านี้ถูกนำไปใช้กับไลบรารี `I18n`.

#### `config.i18n.available_locales`

กำหนด locales ที่อนุญาตให้ใช้สำหรับแอปพลิเคชัน ค่าเริ่มต้นคือ locales ทั้งหมดที่พบในไฟล์ locale ซึ่งโดยปกติจะมีเพียง `:en` เท่านั้นในแอปพลิเคชันใหม่.

#### `config.i18n.default_locale`

กำหนด locale เริ่มต้นของแอปพลิเคชันที่ใช้สำหรับ i18n ค่าเริ่มต้นคือ `:en`.

#### `config.i18n.enforce_available_locales`

ตรวจสอบว่า locales ที่ผ่านไปทาง i18n ต้องถูกประกาศในรายการ `available_locales` โดยยกเว้นการเพิ่ม locale ที่ไม่สามารถใช้ได้ ซึ่งจะเกิดข้อยกเว้น `I18n::InvalidLocale` ขึ้นเมื่อกำหนด locale ที่ไม่สามารถใช้ได้ ค่าเริ่มต้นคือ `true` แนะนำให้ไม่ปิดการใช้งานตัวเลือกนี้เว้นแต่จะมีความจำเป็นอย่างยิ่ง เนื่องจากมันเป็นมาตรการด้านความปลอดภัยเพื่อป้องกันการกำหนด locale ที่ไม่ถูกต้องจากข้อมูลที่ผู้ใช้ป้อนเข้ามา.

#### `config.i18n.load_path`

กำหนดเส้นทางที่ Rails จะใช้ในการค้นหาไฟล์ locale ค่าเริ่มต้นคือ `config/locales/**/*.{yml,rb}`.

#### `config.i18n.raise_on_missing_translations`

กำหนดว่าควรเกิดข้อผิดพลาดเมื่อไม่พบการแปลที่ขาดหายไปหรือไม่ ค่าเริ่มต้นคือ `false`.

#### `config.i18n.fallbacks`

กำหนดการทำงานสำหรับการแปลที่ขาดหายไป นี่คือตัวอย่างการใช้ตัวเลือกนี้:

  * คุณสามารถตั้งค่าตัวเลือกเป็น `true` เพื่อใช้ locale เริ่มต้นเป็น fallback ได้เช่นนี้:

    ```ruby
    config.i18n.fallbacks = true
    ```

  * หรือคุณสามารถตั้งค่าอาร์เรย์ของ locales เป็น fallback ได้เช่นนี้:
```ruby
config.i18n.fallbacks = [:tr, :en]
```

* หรือคุณสามารถตั้งค่า fallback ที่แตกต่างกันสำหรับแต่ละ locale ได้ ตัวอย่างเช่น หากคุณต้องการใช้ `:tr` สำหรับ `:az` และ `:de`, `:en` สำหรับ `:da` เป็น fallbacks คุณสามารถทำได้ดังนี้:

```ruby
config.i18n.fallbacks = { az: :tr, da: [:de, :en] }
# หรือ
config.i18n.fallbacks.map = { az: :tr, da: [:de, :en] }
```

### การกำหนดค่า Active Model

#### `config.active_model.i18n_customize_full_message`

ควบคุมว่า [`Error#full_message`][ActiveModel::Error#full_message] สามารถถูกแทนที่ได้ในไฟล์ locale ของ i18n หรือไม่ ค่าเริ่มต้นคือ `false`.

เมื่อตั้งค่าเป็น `true`, `full_message` จะค้นหารูปแบบที่ระบุไว้ที่ระดับ attribute และ model ในไฟล์ locale รูปแบบเริ่มต้นคือ `"%{attribute} %{message}"`, โดยที่ `attribute` คือชื่อ attribute และ `message` คือข้อความที่เกี่ยวกับการตรวจสอบ ตัวอย่างต่อไปนี้แสดงการแทนที่รูปแบบสำหรับ attributes ทั้งหมดของ `Person` และรูปแบบสำหรับ attribute ที่เฉพาะเจาะจง (`age`).

```ruby
class Person
  include ActiveModel::Validations

  attr_accessor :name, :age

  validates :name, :age, presence: true
end
```

```yml
en:
  activemodel: # หรือ activerecord:
    errors:
      models:
        person:
          # แทนที่รูปแบบสำหรับ attributes ทั้งหมดของ Person:
          format: "Invalid %{attribute} (%{message})"
          attributes:
            age:
              # แทนที่รูปแบบสำหรับ attribute age:
              format: "%{message}"
              blank: "กรุณากรอก %{attribute} ของคุณ"
```

```irb
irb> person = Person.new.tap(&:valid?)

irb> person.errors.full_messages
=> [
  "Invalid Name (can’t be blank)",
  "กรุณากรอก Age ของคุณ"
]

irb> person.errors.messages
=> {
  :name => ["can’t be blank"],
  :age  => ["กรุณากรอก Age ของคุณ"]
}
```
### การกำหนดค่า Active Record

`config.active_record` รวมถึงตัวเลือกการกำหนดค่าหลายอย่าง:

#### `config.active_record.logger`

รับ logger ที่เป็นไปตามอินเตอร์เฟสของ Log4r หรือคลาส Logger ของ Ruby ที่ตั้งไว้เพื่อใช้กับการเชื่อมต่อฐานข้อมูลใหม่ คุณสามารถเรียก logger นี้ได้โดยเรียกใช้ `logger` บนคลาส Active Record หรือตัวอย่าง Active Record ก็ได้ ตั้งค่าเป็น `nil` เพื่อปิดการบันทึกข้อมูล.

#### `config.active_record.primary_key_prefix_type`

ช่วยให้คุณปรับแต่งการตั้งชื่อคอลัมน์ primary key โดยค่าเริ่มต้น Rails ถือว่าคอลัมน์ primary key มีชื่อว่า `id` (และไม่จำเป็นต้องตั้งค่าตัวเลือกการกำหนดค่านี้) มีตัวเลือกอื่นอีก 2 ตัวเลือก:

* `:table_name` จะทำให้ primary key สำหรับคลาส Customer เป็น `customerid`.
* `:table_name_with_underscore` จะทำให้ primary key สำหรับคลาส Customer เป็น `customer_id`.

#### `config.active_record.table_name_prefix`

ช่วยให้คุณกำหนดสตริงที่จะถูกเติมไว้ด้านหน้าชื่อตารางทั้งหมด หากคุณตั้งค่าเป็น `northwest_` แล้วคลาส Customer จะมองหาตาราง `northwest_customers` เป็นตารางของมัน ค่าเริ่มต้นคือสตริงว่าง.

#### `config.active_record.table_name_suffix`

ช่วยให้คุณกำหนดสตริงที่จะถูกเติมไว้ด้านหลังชื่อตารางทั้งหมด หากคุณตั้งค่าเป็น `_northwest` แล้วคลาส Customer จะมองหาตาราง `customers_northwest` เป็นตารางของมัน ค่าเริ่มต้นคือสตริงว่าง.

#### `config.active_record.schema_migrations_table_name`
ช่วยให้คุณตั้งค่าสตริงที่จะใช้เป็นชื่อของตารางการเข้ารหัสแบบสกีมา

#### `config.active_record.internal_metadata_table_name`

ช่วยให้คุณตั้งค่าสตริงที่จะใช้เป็นชื่อของตารางข้อมูลเมตาดาต้าภายใน

#### `config.active_record.protected_environments`

ช่วยให้คุณตั้งค่าอาร์เรย์ของชื่อสภาพแวดล้อมที่ต้องห้ามการกระทำที่ทำลาย

#### `config.active_record.pluralize_table_names`

ระบุว่า Rails จะค้นหาชื่อตารางในฐานข้อมูลเป็นชื่อเอกพจน์หรือพจน์ ถ้าตั้งค่าเป็น `true` (ค่าเริ่มต้น) แล้วคลาส Customer จะใช้ตาราง customers ถ้าตั้งค่าเป็น `false` แล้วคลาส Customer จะใช้ตาราง customer

#### `config.active_record.default_timezone`

กำหนดว่าจะใช้ `Time.local` (ถ้าตั้งค่าเป็น `:local`) หรือ `Time.utc` (ถ้าตั้งค่าเป็น `:utc`) เมื่อดึงวันที่และเวลาจากฐานข้อมูล ค่าเริ่มต้นคือ `:utc`

#### `config.active_record.schema_format`

ควบคุมรูปแบบในการสร้างไฟล์รูปแบบฐานข้อมูล ตัวเลือกมี `:ruby` (ค่าเริ่มต้น) เพื่อรุ่นที่ไม่ขึ้นกับฐานข้อมูลที่ขึ้นอยู่กับการเคลื่อนย้าย หรือ `:sql` เพื่อชุดคำสั่ง SQL (อาจขึ้นกับฐานข้อมูล) 

#### `config.active_record.error_on_ignored_order`

ระบุว่าควรเกิดข้อผิดพลาดหากลำดับของคิวรีถูกละเว้นในระหว่างคิวรีแบบแบทช์ ตัวเลือกมี `true` (เกิดข้อผิดพลาด) หรือ `false` (เตือน) ค่าเริ่มต้นคือ `false`

#### `config.active_record.timestamped_migrations`

ควบคุมว่าการเคลื่อนย้ายจะมีหมายเลขเป็นจำนวนเต็มลำดับหรือเป็นเวลาปัจจุบันหรือไม่ ค่าเริ่มต้นคือ `true` เพื่อใช้เวลาปัจจุบันซึ่งเป็นที่ชื่นชอบถ้ามีนักพัฒนาหลายคนทำงานในแอปพลิเคชันเดียวกัน
#### `config.active_record.db_warnings_action`

ควบคุมการดำเนินการเมื่อคำสั่ง SQL ทำให้เกิดคำเตือน ตัวเลือกที่ใช้ได้มีดังนี้:

  * `:ignore` - คำเตือนของฐานข้อมูลจะถูกละเว้น นี่คือค่าเริ่มต้น

  * `:log` - คำเตือนของฐานข้อมูลจะถูกบันทึกผ่าน `ActiveRecord.logger` ที่ระดับ `:warn`

  * `:raise` - คำเตือนของฐานข้อมูลจะถูกเรียกใช้เป็น `ActiveRecord::SQLWarning`

  * `:report` - คำเตือนของฐานข้อมูลจะถูกรายงานให้กับผู้ติดตามข้อผิดพลาดของ Rails

  * Proc ที่กำหนดเอง - สามารถกำหนด Proc ที่กำหนดเองได้ ซึ่งควรรับอ็อบเจกต์ error ของ `SQLWarning`

    ตัวอย่าง:

    ```ruby
    config.active_record.db_warnings_action = ->(warning) do
      # รายงานไปยังบริการรายงานข้อยกเว้นที่กำหนดเอง
      Bugsnag.notify(warning.message) do |notification|
        notification.add_metadata(:warning_code, warning.code)
        notification.add_metadata(:warning_level, warning.level)
      end
    end
    ```

#### `config.active_record.db_warnings_ignore`

ระบุรายการข้อความและรหัสคำเตือนที่จะถูกละเว้น โดยไม่คำนึงถึงการกำหนดค่า `db_warnings_action` ที่กำหนดไว้ พฤติกรรมเริ่มต้นคือรายงานคำเตือนทั้งหมด สามารถระบุคำเตือนที่จะถูกละเว้นเป็นสตริงหรือเรกเอ็กซ์ได้ ตัวอย่าง:

  ```ruby
  config.active_record.db_warnings_action = :raise
  # คำเตือนต่อไปนี้จะไม่ถูกเรียกใช้
  config.active_record.db_warnings_ignore = [
    /Invalid utf8mb4 character string/,
    "An exact warning message",
    "1062", # MySQL Error 1062: Duplicate entry
  ]
  ```

#### `config.active_record.migration_strategy`

ควบคุมคลาสกลยุทธ์ที่ใช้ในการดำเนินการเมทอดของคำสั่ง schema ในการโยกย้าย คลาสเริ่มต้น
จะเป็นคลาสที่มอบหมายให้กับแอดาปเตอร์การเชื่อมต่อ กลยุทธ์ที่กำหนดเองควรสืบทอดจาก `ActiveRecord::Migration::ExecutionStrategy`,
หรือสามารถสืบทอดจาก `DefaultStrategy` ซึ่งจะรักษาพฤติกรรมเริ่มต้นสำหรับเมทอดที่ไม่ได้รับการนำมาใช้งาน:
```ruby
class CustomMigrationStrategy < ActiveRecord::Migration::DefaultStrategy
  def drop_table(*)
    raise "การลบตารางไม่ได้รับการสนับสนุน!"
  end
end

config.active_record.migration_strategy = CustomMigrationStrategy
```

#### `config.active_record.lock_optimistically`

ควบคุมว่า Active Record จะใช้การล็อกแบบ optimistic หรือไม่ โดยค่าเริ่มต้นคือ `true`.

#### `config.active_record.cache_timestamp_format`

ควบคุมรูปแบบของค่า timestamp ในคีย์แคช ค่าเริ่มต้นคือ `:usec`.

#### `config.active_record.record_timestamps`

เป็นค่าบูลีนที่ควบคุมว่าการบันทึก timestamp ของการสร้างและการอัปเดตในโมเดลจะเกิดขึ้นหรือไม่ ค่าเริ่มต้นคือ `true`.

#### `config.active_record.partial_inserts`

เป็นค่าบูลีนที่ควบคุมว่าจะใช้การเขียนบางส่วนหรือไม่เมื่อสร้างเร็คคอร์ดใหม่ (เช่นการเซ็ตแอตทริบิวต์ที่แตกต่างจากค่าเริ่มต้น)

ค่าเริ่มต้นขึ้นอยู่กับเวอร์ชันเป้าหมายของ `config.load_defaults`:

| เริ่มต้นเวอร์ชัน | ค่าเริ่มต้นคือ |
| --------------------- | -------------------- |
| (เดิม)            | `true`               |
| 7.0                   | `false`              |

#### `config.active_record.partial_updates`

เป็นค่าบูลีนที่ควบคุมว่าจะใช้การเขียนบางส่วนหรือไม่เมื่ออัปเดตเรคคอร์ดที่มีอยู่ (เช่นการเซ็ตแอตทริบิวต์ที่มีค่าที่แตกต่างกัน) โปรดทราบว่าเมื่อใช้การอัปเดตบางส่วนคุณควรใช้การล็อกแบบ optimistic `config.active_record.lock_optimistically` เนื่องจากการอัปเดตพร้อมกันอาจเขียนแอตทริบิวต์ขึ้นอยู่กับสถานะการอ่านที่อาจเป็นสถานะที่ล้าสมัยได้ ค่าเริ่มต้นคือ `true`.

#### `config.active_record.maintain_test_schema`
เป็นค่าบูลีนที่ควบคุมว่า Active Record ควรพยายามที่จะรักษาโครงสร้างฐานข้อมูลทดสอบของคุณให้เป็นปัจจุบันกับ `db/schema.rb` (หรือ `db/structure.sql`) เมื่อคุณเรียกใช้การทดสอบของคุณ ค่าเริ่มต้นคือ `true` 

#### `config.active_record.dump_schema_after_migration`

เป็นตัวควบคุมว่าควรมีการสร้างสกีม่าหรือไม่ (`db/schema.rb` หรือ `db/structure.sql`) เมื่อคุณเรียกใช้การโยกย้าย ค่าเริ่มต้นคือ `false` ใน `config/environments/production.rb` ซึ่งถูกสร้างโดย Rails ค่าเริ่มต้นคือ `true` หากไม่ได้ตั้งค่าการกำหนดค่านี้

#### `config.active_record.dump_schemas`

ควบคุมว่าฐานข้อมูลแบบไหนจะถูกสร้างสกีม่าเมื่อเรียกใช้ `db:schema:dump` ตัวเลือกมี `:schema_search_path` (ค่าเริ่มต้น) ซึ่งจะสร้างสกีม่าสำหรับฐานข้อมูลที่ระบุใน `schema_search_path` `:all` ซึ่งจะสร้างสกีม่าสำหรับฐานข้อมูลทั้งหมดโดยไม่คำนึงถึง `schema_search_path` หรือสตริงของสกีม่าที่คั่นด้วยเครื่องหมายจุลภาค

#### `config.active_record.before_committed_on_all_records`

เปิดใช้งานการเรียกใช้งาน before_committed! callbacks บนระเบียนที่ลงทะเบียนทั้งหมดในธุรกรรม พฤติกรรมก่อนหน้านี้คือการเรียกใช้งาน callbacks เฉพาะบนสำเนาแรกของระเบียนเมื่อมีการลงทะเบียนสำเนาหลายๆ รายการของระเบียนเดียวกันในธุรกรรม

| เริ่มต้นเวอร์ชัน | ค่าเริ่มต้นคือ |
| --------------------- | -------------------- |
| (เดิม)            | `false`              |
| 7.1                   | `true`               |

#### `config.active_record.belongs_to_required_by_default`

เป็นค่าบูลีนและควบคุมว่าระเบียนจะไม่ผ่านการตรวจสอบความถูกต้องหากไม่มีการเชื่อมโยง `belongs_to` ที่มีอยู่
ค่าเริ่มต้นขึ้นอยู่กับเวอร์ชันเป้าหมาย `config.load_defaults`:

| เริ่มต้นด้วยเวอร์ชัน | ค่าเริ่มต้นคือ |
| --------------------- | -------------------- |
| (เดิม)            | `nil`                |
| 5.0                   | `true`               |

#### `config.active_record.belongs_to_required_validates_foreign_key`

เปิดใช้การตรวจสอบเฉพาะคอลัมน์ที่เกี่ยวข้องกับความสำคัญของผู้ปกครองเมื่อผู้ปกครองเป็นบังคับ
พฤติกรรมก่อนหน้านี้คือการตรวจสอบความสำคัญของระเบียนผู้ปกครองที่ดำเนินการคิวรีเพิ่มเติม
เพื่อรับผู้ปกครองทุกครั้งที่บันทึกลูกค้าอัปเดต แม้ว่าผู้ปกครองจะไม่เปลี่ยนแปลง

| เริ่มต้นด้วยเวอร์ชัน | ค่าเริ่มต้นคือ |
| --------------------- | -------------------- |
| (เดิม)            | `true`               |
| 7.1                   | `false`              |

#### `config.active_record.marshalling_format_version`

เมื่อตั้งค่าเป็น `7.1` จะเปิดใช้งานการตั้งค่าการตรวจสอบ Active Record instance ที่มีประสิทธิภาพมากขึ้นด้วย `Marshal.dump`.

การเปลี่ยนแปลงนี้เปลี่ยนรูปแบบการตรวจสอบ ดังนั้นโมเดลที่ถูกตรวจสอบแบบนี้
ไม่สามารถอ่านได้โดยเวอร์ชันเก่า (< 7.1) ของ Rails อย่างไรก็ตาม ข้อความที่
ใช้รูปแบบเก่ายังสามารถอ่านได้ไม่ว่าการปรับปรุงนี้จะเปิดใช้งานหรือไม่ก็ตาม

| เริ่มต้นด้วยเวอร์ชัน | ค่าเริ่มต้นคือ |
| --------------------- | -------------------- |
| (เดิม)            | `6.1`                |
| 7.1                   | `7.1`                |

#### `config.active_record.action_on_strict_loading_violation`

เปิดใช้งานการเรียกร้องหรือบันทึกข้อยกเว้นหากมีการตั้งค่า strict_loading บน
ความสัมพันธ์ ค่าเริ่มต้นคือ `:raise` ในสภาพแวดล้อมทั้งหมด สามารถเปลี่ยนเป็น `:log` เพื่อส่งการละเว้นไปยังตัวบันทึกแทนการเรียกร้อง
#### `config.active_record.strict_loading_by_default`

เป็นค่าบูลีนที่เปิดหรือปิดโหมด strict_loading ตามค่าเริ่มต้น ค่าเริ่มต้นคือ `false`.

#### `config.active_record.warn_on_records_fetched_greater_than`

อนุญาตให้ตั้งค่าค่าเตือนสำหรับขนาดผลลัพธ์ของคิวรี หากจำนวนเรคคอร์ดที่ส่งกลับจากคิวรีเกินค่าเตือน จะมีการบันทึกคำเตือนลงในบันทึก สามารถใช้เพื่อระบุคิวรีที่อาจทำให้เกิดการใช้หน่วยความจำเกินได้

#### `config.active_record.index_nested_attribute_errors`

อนุญาตให้แสดงข้อผิดพลาดสำหรับความสัมพันธ์ `has_many` ที่ซ้อนกันด้วยดัชนีและข้อผิดพลาด ค่าเริ่มต้นคือ `false`.

#### `config.active_record.use_schema_cache_dump`

เปิดใช้งานให้ผู้ใช้ได้รับข้อมูลแคชสกีมาจาก `db/schema_cache.yml` (ที่สร้างขึ้นโดย `bin/rails db:schema:cache:dump`) แทนที่จะต้องส่งคิวรีไปยังฐานข้อมูลเพื่อรับข้อมูลเหล่านี้ ค่าเริ่มต้นคือ `true`.

#### `config.active_record.cache_versioning`

ระบุว่าจะใช้วิธี `#cache_key` ที่มีความเสถียรและมีเวอร์ชันที่เปลี่ยนแปลงในวิธี `#cache_version` หรือไม่

ค่าเริ่มต้นขึ้นอยู่กับเวอร์ชันเป้าหมายของ `config.load_defaults`:

| เริ่มต้นเวอร์ชัน | ค่าเริ่มต้นคือ |
| --------------------- | -------------------- |
| (เดิม)            | `false`              |
| 5.2                   | `true`               |

#### `config.active_record.collection_cache_versioning`

เปิดใช้งานให้ใช้คีย์แคชเดียวกันเมื่อวัตถุที่กำลังถูกแคชของประเภท `ActiveRecord::Relation` เปลี่ยนแปลงโดยการย้ายข้อมูลที่เปลี่ยนแปลงได้ (max updated at และ count) ของคีย์แคชของความสัมพันธ์เข้าไปในเวอร์ชันแคชเพื่อรองรับการนำคีย์แคชกลับมาใช้ใหม่
ค่าเริ่มต้นขึ้นอยู่กับเวอร์ชันเป้าหมายของ `config.load_defaults`:

| เริ่มต้นด้วยเวอร์ชัน | ค่าเริ่มต้นคือ |
| --------------------- | -------------------- |
| (เดิม)            | `false`              |
| 6.0                   | `true`               |

#### `config.active_record.has_many_inversing`

เปิดใช้งานการตั้งค่า inverse record เมื่อทำการเดินทางจาก `belongs_to` ไปยัง `has_many` associations

ค่าเริ่มต้นขึ้นอยู่กับเวอร์ชันเป้าหมายของ `config.load_defaults`:

| เริ่มต้นด้วยเวอร์ชัน | ค่าเริ่มต้นคือ |
| --------------------- | -------------------- |
| (เดิม)            | `false`              |
| 6.1                   | `true`               |

#### `config.active_record.automatic_scope_inversing`

เปิดใช้งานการอัตโนมัติในการสร้าง `inverse_of` สำหรับ associations ที่มี scope

ค่าเริ่มต้นขึ้นอยู่กับเวอร์ชันเป้าหมายของ `config.load_defaults`:

| เริ่มต้นด้วยเวอร์ชัน | ค่าเริ่มต้นคือ |
| --------------------- | -------------------- |
| (เดิม)            | `false`              |
| 7.0                   | `true`               |

#### `config.active_record.destroy_association_async_job`

อนุญาตให้ระบุงานที่จะใช้ในการทำลาย associated records ใน background ค่าเริ่มต้นคือ `ActiveRecord::DestroyAssociationAsyncJob`.

#### `config.active_record.destroy_association_async_batch_size`

อนุญาตให้ระบุจำนวนสูงสุดของ records ที่จะถูกทำลายใน background job โดยใช้ตัวเลือก `dependent: :destroy_async` ค่าเริ่มต้นคือ `nil` ซึ่งจะทำให้ records ที่เกี่ยวข้องทั้งหมดสำหรับ association ที่กำหนดจะถูกทำลายใน background job เดียวกัน
#### `config.active_record.queues.destroy`

ช่วยให้สามารถระบุคิว Active Job ที่จะใช้สำหรับงานที่ต้องทำลายได้ หากตัวเลือกนี้เป็น `nil` งานที่ต้องทำลายจะถูกส่งไปยังคิว Active Job ที่ตั้งไว้เป็นค่าเริ่มต้น (ดูที่ `config.active_job.default_queue_name`) ค่าเริ่มต้นคือ `nil`

#### `config.active_record.enumerate_columns_in_select_statements`

เมื่อเป็น `true` จะรวมชื่อคอลัมน์เสมอในคำสั่ง `SELECT` และหลีกเลี่ยงการใช้คำสั่ง `SELECT * FROM ...` ซึ่งจะช่วยลดข้อผิดพลาดของแคชของคำสั่งที่เตรียมไว้เมื่อเพิ่มคอลัมน์ในฐานข้อมูล PostgreSQL เป็นต้น ค่าเริ่มต้นคือ `false`

#### `config.active_record.verify_foreign_keys_for_fixtures`

ตรวจสอบว่าข้อจำกัดของคีย์ต่างประเทศทั้งหมดถูกต้องหลังจากโหลดข้อมูลตัวอย่างในการทดสอบ รองรับโดย PostgreSQL และ SQLite เท่านั้น

ค่าเริ่มต้นขึ้นอยู่กับเวอร์ชันเป้าหมายของ `config.load_defaults`:

| เริ่มต้นด้วยเวอร์ชัน | ค่าเริ่มต้นคือ |
| --------------------- | -------------------- |
| (เดิม)            | `false`              |
| 7.0                   | `true`               |

#### `config.active_record.raise_on_assign_to_attr_readonly`

เปิดใช้งานการเรียกขึ้นเมื่อมีการกำหนดค่าให้กับแอตทริบิวต์ที่ตั้งค่าเป็น `attr_readonly` พฤติกรรมก่อนหน้านี้จะอนุญาตให้กำหนดค่าแต่ไม่บันทึกการเปลี่ยนแปลงลงในฐานข้อมูล

| เริ่มต้นด้วยเวอร์ชัน | ค่าเริ่มต้นคือ |
| --------------------- | -------------------- |
| (เดิม)            | `false`              |
| 7.1                   | `true`               |

#### `config.active_record.run_commit_callbacks_on_first_saved_instances_in_transaction`

เมื่อมีหลายตัวอย่าง Active Record เปลี่ยนแปลงข้อมูลเดียวกันใน transaction เดียวกัน Rails จะเรียกใช้งาน callback `after_commit` หรือ `after_rollback` สำหรับอินสแตนซ์เพียงหนึ่งตัวเท่านั้น ตัวเลือกนี้ระบุว่า Rails จะเลือกตัวอย่างใดที่จะได้รับ callback
เมื่อเป็น `true` การเรียกใช้ callback ในระหว่าง transaction จะถูกเรียกใช้บนอินสแตนซ์แรกที่จะบันทึก แม้ว่าสถานะของอินสแตนซ์นั้นอาจจะเป็นของเก่า

เมื่อเป็น `false` การเรียกใช้ callback ในระหว่าง transaction จะถูกเรียกใช้บนอินสแตนซ์ที่มีสถานะเป็นของใหม่ที่สุด อินสแตนซ์ที่ถูกเลือกจะเป็นดังนี้:

- โดยทั่วไป การเรียกใช้ callback ใน transaction จะถูกเรียกใช้บนอินสแตนซ์สุดท้ายที่จะบันทึกบันทึกที่กำหนดใน transaction
- แต่มีข้อยกเว้นสองกรณี:
    - หากบันทึกถูกสร้างขึ้นใน transaction แล้วถูกอัปเดตโดยอินสแตนซ์อื่น `after_create_commit` callbacks จะถูกเรียกใช้บนอินสแตนซ์ที่สอง แทนที่จะเรียกใช้ `after_update_commit` callbacks ตามสถานะของอินสแตนซ์นั้น
    - หากบันทึกถูกทำลายใน transaction `after_destroy_commit` callbacks จะถูกเรียกใช้บนอินสแตนซ์ที่ถูกทำลายล่าสุด แม้ว่าอินสแตนซ์ที่เก่าอาจจะทำการอัปเดต (ซึ่งจะมีผลต่อแถวที่ 0)

ค่าเริ่มต้นขึ้นอยู่กับเวอร์ชันเป้าหมายของ `config.load_defaults`:

| เริ่มต้นด้วยเวอร์ชัน | ค่าเริ่มต้นคือ |
| --------------------- | -------------------- |
| (เดิม)            | `true`               |
| 7.1                   | `false`              |

#### `config.active_record.default_column_serializer`

การสร้างตัวแปรที่ใช้ถ้าไม่ได้ระบุโดยชัดเจนสำหรับคอลัมน์ที่กำหนด

ในอดีต `serialize` และ `store` ในขณะที่อนุญาตให้ใช้การสร้างตัวแปรทดแทน จะใช้ `YAML` เป็นค่าเริ่มต้น แต่มันไม่ใช่รูปแบบที่มีประสิทธิภาพมากนักและอาจเป็นแหล่งที่มาของช่องโหว่ด้านความปลอดภัยหากใช้ไม่ระมัดระวัง
ดังนั้นแนะนำให้ใช้รูปแบบที่เข้มงวดและจำกัดมากขึ้นสำหรับการซีเรียลไซซ์ฐานข้อมูล

น่าเสียดายที่ไม่มีค่าเริ่มต้นที่เหมาะสมในไลบรารีมาตรฐานของ Ruby อย่างไรก็ตาม `JSON` อาจทำงานได้เป็นรูปแบบ แต่แพ็คเกจ `json` จะแปลงประเภทที่ไม่รองรับเป็นสตริงซึ่งอาจทำให้เกิดข้อบกพร่อง

ค่าเริ่มต้นขึ้นอยู่กับเวอร์ชันเป้าหมายของ `config.load_defaults`:

| เริ่มต้นด้วยเวอร์ชัน | ค่าเริ่มต้นคือ |
| --------------------- | -------------------- |
| (เดิม)            | `YAML`               |
| 7.1                   | `nil`                |

#### `config.active_record.run_after_transaction_callbacks_in_order_defined`

หากเป็นจริง `after_commit` callbacks จะถูกดำเนินการตามลำดับที่กำหนดในโมเดล หากเป็นเท็จ จะถูกดำเนินการในลำดับที่กลับกัน

Callback อื่น ๆ จะถูกดำเนินการตามลำดับที่กำหนดในโมเดลเสมอ (ยกเว้นหากคุณใช้ `prepend: true`)

ค่าเริ่มต้นขึ้นอยู่กับเวอร์ชันเป้าหมายของ `config.load_defaults`:

| เริ่มต้นด้วยเวอร์ชัน | ค่าเริ่มต้นคือ |
| --------------------- | -------------------- |
| (เดิม)            | `false`              |
| 7.1                   | `true`               |

#### `config.active_record.query_log_tags_enabled`

ระบุว่าจะเปิดใช้งานหรือไม่เพื่อใส่ความคิดเห็นในการค้นหาระดับอะแดปเตอร์ ค่าเริ่มต้นคือ
`false`

หมายเหตุ: เมื่อตั้งค่าเป็น `true` คำสั่งพรีเพรียร์ของฐานข้อมูลจะถูกปิดอัตโนมัติ

#### `config.active_record.query_log_tags`

กำหนด `Array` ที่ระบุแท็กคีย์/ค่าที่จะถูกแทรกในความคิดเห็น SQL ค่าเริ่มต้นคือ `[ :application ]` แท็กที่กำหนดไว้ล่วงหน้าจะคืนค่าชื่อแอปพลิเคชัน
#### `config.active_record.query_log_tags_format`

`Symbol` ที่ระบุรูปแบบการจัดรูปแบบสำหรับแท็ก ค่าที่ถูกต้องคือ `:sqlcommenter` และ `:legacy` 

ค่าเริ่มต้นขึ้นอยู่กับเวอร์ชันเป้าหมายของ `config.load_defaults`:

| เริ่มต้นเวอร์ชัน | ค่าเริ่มต้นคือ |
| --------------------- | -------------------- |
| (เดิม)            | `:legacy`            |
| 7.1                   | `:sqlcommenter`      |

#### `config.active_record.cache_query_log_tags`

กำหนดว่าจะเปิดใช้งานการเก็บแคชของแท็กบันทึกคำสั่งคิวรีหรือไม่ สำหรับแอปพลิเคชันที่มีจำนวนคำสั่งคิวรีมาก การเก็บแคชแท็กบันทึกคำสั่งคิวรีสามารถให้ประสิทธิภาพที่ดีกว่าเมื่อบริบทไม่เปลี่ยนแปลงในระหว่างการดำเนินการของคำขอหรือการประมวลผลงาน ค่าเริ่มต้นคือ `false`

#### `config.active_record.schema_cache_ignored_tables`

กำหนดรายการตารางที่ควรถูกละเว้นเมื่อสร้างแคชสกีมา รับค่าเป็น `Array` ของสตริงที่แสดงชื่อตารางหรือเรกเอ็กซ์ที่ตรงกัน

#### `config.active_record.verbose_query_logs`

ระบุว่าควรบันทึกตำแหน่งแหล่งของเมทอดที่เรียกใช้คำสั่งคิวรีฐานข้อมูลไว้ด้านล่างของคำสั่งคิวรีที่เกี่ยวข้องหรือไม่ ค่าเริ่มต้นคือ `true` ในโหมดการพัฒนาและ `false` ในสภาพแวดล้อมอื่น ๆ

#### `config.active_record.sqlite3_adapter_strict_strings_by_default`

ระบุว่าควรใช้ SQLite3Adapter ในโหมดสตริงเข้มแบบเริ่มต้นหรือไม่ การใช้โหมดสตริงเข้มจะปิดใช้งานตัวอักษรในเครื่องหมายคำพูดคู่

SQLite มีความแปลกประหลาดเกี่ยวกับตัวอักษรในเครื่องหมายคำพูดคู่
ก่อนอื่นมันพยายามพิจารณาตัวอักษรในเครื่องหมายคำพูดคู่เป็นชื่อตัวระบุ แต่หากไม่มี
จากนั้นมันจะพิจารณาเป็นตัวอักษรในเครื่องหมายคำพูดคู่ ด้วยเหตุนี้ การพิมพ์ผิดสามารถเกิดขึ้นได้อย่างไม่เห็นแก่ตา
ตัวอย่างเช่น สามารถสร้างดัชนีสำหรับคอลัมน์ที่ไม่มีอยู่ได้
ดูรายละเอียดเพิ่มเติมที่ [เอกสาร SQLite](https://www.sqlite.org/quirks.html#double_quoted_string_literals_are_accepted)
ค่าเริ่มต้นขึ้นอยู่กับเวอร์ชันเป้าหมาย `config.load_defaults`:

| เริ่มต้นด้วยเวอร์ชัน | ค่าเริ่มต้นคือ |
| --------------------- | -------------------- |
| (เดิม)            | `false`              |
| 7.1                   | `true`               |

#### `config.active_record.async_query_executor`

ระบุว่าการค้นหาแบบไม่เชื่อมต่อเป็นอย่างไร

ค่าเริ่มต้นคือ `nil` ซึ่งหมายความว่า `load_async` ถูกปิดใช้งานและจะทำการดำเนินการค้นหาโดยตรงใน foreground
ในการดำเนินการค้นหาแบบไม่เชื่อมต่อจริง ๆ ต้องตั้งค่าเป็น `:global_thread_pool` หรือ `:multi_thread_pool`

`:global_thread_pool` จะใช้พูลเดียวสำหรับฐานข้อมูลทั้งหมดที่แอปพลิเคชันเชื่อมต่อ นี่คือการกำหนดค่าที่แนะนำสำหรับแอปพลิเคชันที่มีฐานข้อมูลเดียวเท่านั้น หรือแอปพลิเคชันที่สอบถามฐานข้อมูลชาร์ดเดียวในเวลาเดียวกัน

`:multi_thread_pool` จะใช้พูลหนึ่งต่อฐานข้อมูลและสามารถกำหนดขนาดพูลแต่ละตัวได้แยกต่างหากใน `database.yml` ผ่านคุณสมบัติ `max_threads` และ `min_thread` นี่อาจเป็นประโยชน์สำหรับแอปพลิเคชันที่สอบถามฐานข้อมูลหลายตัวในเวลาเดียวกันและต้องการกำหนดความยืดหยุ่นสูงสุดอย่างแม่นยำ

#### `config.active_record.global_executor_concurrency`

ใช้ร่วมกับ `config.active_record.async_query_executor = :global_thread_pool` เพื่อกำหนดจำนวนคำสั่งค้นหาแบบไม่เชื่อมต่อที่สามารถดำเนินการพร้อมกันได้

ค่าเริ่มต้นคือ `4`

จำนวนนี้ต้องพิจารณาในความสอดคล้องกับขนาดพูลการเชื่อมต่อที่กำหนดใน `database.yml` พูลการเชื่อมต่อควรมีขนาดใหญ่เพียงพอที่จะรองรับทั้งเธรดใน foreground (เช่นเธรดเว็บเซิร์ฟเวอร์หรือเธรดงาน) และเธรดพื้นหลัง
#### `config.active_record.allow_deprecated_singular_associations_name`

การตั้งค่านี้เปิดใช้งานพฤติกรรมที่ถูกยกเลิกที่เรียกอ้างถึงความสัมพันธ์แบบเอกพจน์โดยใช้ชื่อพหูพจน์ในคำสั่ง `where` การตั้งค่าเป็น `false` จะทำให้มีประสิทธิภาพมากขึ้น

```ruby
class Comment < ActiveRecord::Base
  belongs_to :post
end

Comment.where(post: post_id).count  # => 5

# เมื่อ `allow_deprecated_singular_associations_name` เป็น true:
Comment.where(posts: post_id).count # => 5 (แจ้งเตือนการเลิกใช้)

# เมื่อ `allow_deprecated_singular_associations_name` เป็น false:
Comment.where(posts: post_id).count # => เกิดข้อผิดพลาด
```

ค่าเริ่มต้นขึ้นอยู่กับเวอร์ชันเป้าหมายของ `config.load_defaults`:

| เริ่มต้นด้วยเวอร์ชัน | ค่าเริ่มต้นคือ |
| --------------------- | -------------------- |
| (เดิม)            | `true`               |
| 7.1                   | `false`              |

#### `config.active_record.yaml_column_permitted_classes`

ค่าเริ่มต้นคือ `[Symbol]` ช่วยให้แอปพลิเคชันสามารถรวมคลาสที่ได้รับอนุญาตเพิ่มเติมไปยัง `safe_load()` บน `ActiveRecord::Coders::YAMLColumn`.

#### `config.active_record.use_yaml_unsafe_load`

ค่าเริ่มต้นคือ `false` ช่วยให้แอปพลิเคชันสามารถเลือกใช้ `unsafe_load` บน `ActiveRecord::Coders::YAMLColumn`.

#### `config.active_record.raise_int_wider_than_64bit`

ค่าเริ่มต้นคือ `true` กำหนดว่าจะเกิดข้อผิดพลาดหรือไม่เมื่อไดรเวอร์ PostgreSQL ได้รับจำนวนเต็มที่กว้างกว่าการแสดงผล 64 บิตที่ลงชื่อ

#### `ActiveRecord::ConnectionAdapters::Mysql2Adapter.emulate_booleans` และ `ActiveRecord::ConnectionAdapters::TrilogyAdapter.emulate_booleans`

ควบคุมว่าแอดาปเตอร์ MySQL ของ Active Record จะพิจารณาคอลัมน์ `tinyint(1)` ทั้งหมดเป็นบูลีนหรือไม่ ค่าเริ่มต้นคือ `true`.

#### `ActiveRecord::ConnectionAdapters::PostgreSQLAdapter.create_unlogged_tables`

ควบคุมว่าตารางฐานข้อมูลที่สร้างขึ้นโดย PostgreSQL ควรเป็น "unlogged" ซึ่งสามารถเพิ่มความเร็วได้ แต่มีความเสี่ยงในการสูญเสียข้อมูลหากฐานข้อมูลล้มเหลว แนะนำอย่างยิ่งให้ไม่เปิดใช้งานในสภาพแวดล้อมการใช้งานจริง ค่าเริ่มต้นคือ `false` ในทุกสภาพแวดล้อม.
เพื่อเปิดใช้งานสำหรับการทดสอบ:

```ruby
# config/environments/test.rb

ActiveSupport.on_load(:active_record_postgresqladapter) do
  self.create_unlogged_tables = true
end
```

#### `ActiveRecord::ConnectionAdapters::PostgreSQLAdapter.datetime_type`

ควบคุมว่า Active Record PostgreSQL adapter ควรใช้ชนิดข้อมูลเดิมใดเมื่อคุณเรียกใช้ `datetime` ใน
การโยกย้ายหรือสกีมา มันรับสัญลักษณ์ที่ต้องตรงกับหนึ่งใน
`NATIVE_DATABASE_TYPES` ที่กำหนดค่าไว้ ค่าเริ่มต้นคือ `:timestamp` ซึ่งหมายความว่า
`t.datetime` ในการโยกย้ายจะสร้างคอลัมน์ "timestamp without time zone" 

ในการใช้ "timestamp with time zone":

```ruby
# config/application.rb

ActiveSupport.on_load(:active_record_postgresqladapter) do
  self.datetime_type = :timestamptz
end
```

คุณควรเรียกใช้ `bin/rails db:migrate` เพื่อสร้าง schema.rb ใหม่หากคุณเปลี่ยนแปลงนี้

#### `ActiveRecord::SchemaDumper.ignore_tables`

ยอมรับอาร์เรย์ของตารางที่ _ไม่_ ควรถูกรวมอยู่ในไฟล์ schema ที่สร้างขึ้น

#### `ActiveRecord::SchemaDumper.fk_ignore_pattern`

อนุญาตให้ตั้งค่า regular expression ที่แตกต่างกันซึ่งจะถูกใช้ในการตัดสินใจ
ว่าชื่อ foreign key ควรถูกดัมป์ไปยัง db/schema.rb หรือไม่ โดย
ค่าเริ่มต้นคือ `/^fk_rails_[0-9a-f]{10}$/`

#### `config.active_record.encryption.hash_digest_class`

ตั้งค่าอัลกอริทึมของการเข้ารหัสที่ Active Record Encryption ใช้

ค่าเริ่มต้นขึ้นอยู่กับเวอร์ชันเป้าหมายของ `config.load_defaults`:

| เริ่มต้นเวอร์ชัน | ค่าเริ่มต้นคือ      |
|-----------------------|---------------------------|
| (เดิม)            | `OpenSSL::Digest::SHA1`   |
| 7.1                   | `OpenSSL::Digest::SHA256` |

#### `config.active_record.encryption.support_sha1_for_non_deterministic_encryption`
เปิดใช้งานการรองรับการถอดรหัสข้อมูลที่ถูกเข้ารหัสด้วยคลาสการย่อย SHA-1 ที่มีอยู่ หากเป็น `false` จะรองรับเฉพาะการย่อยที่กำหนดไว้ใน `config.active_record.encryption.hash_digest_class` 

ค่าเริ่มต้นขึ้นอยู่กับเวอร์ชันเป้าหมายของ `config.load_defaults`:

| เริ่มต้นด้วยเวอร์ชัน | ค่าเริ่มต้นคือ |
|-----------------------|----------------------|
| (เดิม)               | `true`               |
| 7.1                   | `false`              |

### การกำหนดค่า Action Controller

`config.action_controller` รวมถึงการกำหนดค่าต่างๆ:

#### `config.action_controller.asset_host`

กำหนดโฮสต์สำหรับแอสเซ็ต มีประโยชน์เมื่อใช้ CDN ในการโฮสต์แอสเซ็ตแทนเซิร์ฟเวอร์แอปพลิเคชันเอง คุณควรใช้ตัวเลือกนี้เฉพาะเมื่อคุณมีการกำหนดค่าที่แตกต่างสำหรับ Action Mailer เท่านั้น มิฉะนั้นให้ใช้ `config.asset_host` 

#### `config.action_controller.perform_caching`

กำหนดการกำหนดค่าว่าแอปพลิเคชันควรทำฟีเจอร์การแคชที่ Action Controller มีหรือไม่ ตั้งค่าเป็น `false` ในสภาพแวดล้อมการพัฒนา และ `true` ในสภาพแวดล้อมการผลิต หากไม่ระบุ ค่าเริ่มต้นจะเป็น `true` 

#### `config.action_controller.default_static_extension`

กำหนดส่วนขยายที่ใช้สำหรับหน้าที่ถูกแคชไว้ ค่าเริ่มต้นคือ `.html`

#### `config.action_controller.include_all_helpers`

กำหนดว่าควรมีเฮลเปอร์ทั้งหมดใช้งานทุกที่หรือจะมีขอบเขตในคอนโทรลเลอร์ที่เกี่ยวข้อง หากตั้งค่าเป็น `false` วิธีการช่วยเหลือของ `UsersHelper` จะสามารถใช้งานได้เฉพาะในมุมมองที่แสดงผลเป็นส่วนหนึ่งของ `UsersController` หากเป็น `true` วิธีการช่วยเหลือของ `UsersHelper` สามารถใช้งานได้ทุกที่ การกำหนดค่าเริ่มต้น (เมื่อตัวเลือกนี้ไม่ถูกตั้งค่าเป็น `true` หรือ `false` โดยชัดเจน) คือการให้วิธีการช่วยเหลือทั้งหมดสามารถใช้งานได้กับทุกคอนโทรลเลอร์
#### `config.action_controller.logger`

ยอมรับ logger ที่เป็นไปตามอินเตอร์เฟซของ Log4r หรือคลาส Ruby Logger เริ่มต้น แล้วใช้ในการบันทึกข้อมูลจาก Action Controller ตั้งค่าเป็น `nil` เพื่อปิดการบันทึกข้อมูล

#### `config.action_controller.request_forgery_protection_token`

กำหนดชื่อพารามิเตอร์ของโทเค็นสำหรับ RequestForgery การเรียกใช้ `protect_from_forgery` จะกำหนดให้เป็น `:authenticity_token` เริ่มต้น

#### `config.action_controller.allow_forgery_protection`

เปิดหรือปิดการป้องกัน CSRF โดยค่าเริ่มต้นในสภาพแวดล้อมทดสอบคือ `false` และในสภาพแวดล้อมอื่น ๆ คือ `true`

#### `config.action_controller.forgery_protection_origin_check`

กำหนดการตรวจสอบ HTTP `Origin` header ว่าควรตรวจสอบกับต้นกำเนิดของไซต์เป็นการป้องกัน CSRF เพิ่มเติมหรือไม่

ค่าเริ่มต้นขึ้นอยู่กับเวอร์ชันเป้าหมายของ `config.load_defaults`:

| เริ่มต้นเวอร์ชัน | ค่าเริ่มต้นคือ |
| --------------------- | -------------------- |
| (เดิม)            | `false`              |
| 5.0                   | `true`               |

#### `config.action_controller.per_form_csrf_tokens`

กำหนดว่า CSRF tokens จะใช้ได้เฉพาะสำหรับ method/action ที่สร้างขึ้น

ค่าเริ่มต้นขึ้นอยู่กับเวอร์ชันเป้าหมายของ `config.load_defaults`:

| เริ่มต้นเวอร์ชัน | ค่าเริ่มต้นคือ |
| --------------------- | -------------------- |
| (เดิม)            | `false`              |
| 5.0                   | `true`               |

#### `config.action_controller.default_protect_from_forgery`

กำหนดว่าการป้องกันการปลอมแปลงควรเพิ่มใน `ActionController::Base` หรือไม่

ค่าเริ่มต้นขึ้นอยู่กับเวอร์ชันเป้าหมายของ `config.load_defaults`:

| เริ่มต้นเวอร์ชัน | ค่าเริ่มต้นคือ |
| --------------------- | -------------------- |
| (เดิม)            | `false`              |
| 5.2                   | `true`               |
#### `config.action_controller.relative_url_root`

สามารถใช้บอก Rails ว่าคุณกำลัง [ติดตั้งในโฟลเดอร์ย่อย](
configuring.html#deploy-to-a-subdirectory-relative-url-root) ค่าเริ่มต้นคือ
[`config.relative_url_root`](#config-relative-url-root).

#### `config.action_controller.permit_all_parameters`

ตั้งค่าให้ทุกพารามิเตอร์สำหรับการกำหนดค่าแบบมวลสามารถรับรองได้ตามค่าเริ่มต้นคือ `false`.

#### `config.action_controller.action_on_unpermitted_parameters`

ควบคุมพฤติกรรมเมื่อพารามิเตอร์ที่ไม่ได้รับอนุญาตโดยชัดเจนถูกพบค่าเริ่มต้นคือ `:log` ในสภาพแวดล้อมทดสอบและการพัฒนา `false` ในกรณีอื่น ๆ ค่าที่เป็นไปได้คือ:

* `false` เพื่อไม่ทำการกระทำใด ๆ
* `:log` เพื่อส่งออกเหตุการณ์ `ActiveSupport::Notifications.instrument` ในหัวข้อ `unpermitted_parameters.action_controller` และบันทึกที่ระดับ DEBUG
* `:raise` เพื่อเรียกใช้ข้อยกเว้น `ActionController::UnpermittedParameters`

#### `config.action_controller.always_permitted_parameters`

ตั้งค่ารายการพารามิเตอร์ที่ได้รับอนุญาตโดยค่าเริ่มต้นคือ `['controller', 'action']`.

#### `config.action_controller.enable_fragment_cache_logging`

กำหนดว่าจะบันทึกการอ่านและเขียนแคชชิ้นส่วนในรูปแบบที่เป็นรายละเอียดดังนี้:

```
Read fragment views/v1/2914079/v1/2914079/recordings/70182313-20160225015037000000/d0bdf2974e1ef6d31685c3b392ad0b74 (0.6ms)
Rendered messages/_message.html.erb in 1.2 ms [cache hit]
Write fragment views/v1/2914079/v1/2914079/recordings/70182313-20160225015037000000/3b4e249ac9d168c617e32e84b99218b5 (1.1ms)
Rendered recordings/threads/_thread.html.erb in 1.5 ms [cache miss]
```

โดยค่าเริ่มต้นถูกตั้งค่าเป็น `false` ซึ่งผลลัพธ์คือดังนี้:

```
Rendered messages/_message.html.erb in 1.2 ms [cache hit]
Rendered recordings/threads/_thread.html.erb in 1.5 ms [cache miss]
```

#### `config.action_controller.raise_on_open_redirects`

เรียกใช้ `ActionController::Redirecting::UnsafeRedirectError` เมื่อเกิดการเปลี่ยนเส้นทางที่ไม่ได้รับอนุญาต.

ค่าเริ่มต้นขึ้นอยู่กับเวอร์ชันเป้าหมายของ `config.load_defaults`:
| เริ่มต้นด้วยเวอร์ชัน | ค่าเริ่มต้นคือ |
| --------------------- | -------------------- |
| (เดิม)            | `false`              |
| 7.0                   | `true`               |

#### `config.action_controller.log_query_tags_around_actions`

กำหนดว่าจะให้อัปเดตค่าความสัมพันธ์ของคำสั่งความสัมพันธ์ในคอนโทรลเลอร์โดยอัตโนมัติผ่าน `around_filter` หรือไม่ ค่าเริ่มต้นคือ `true`.

#### `config.action_controller.wrap_parameters_by_default`

กำหนดค่า [`ParamsWrapper`](https://api.rubyonrails.org/classes/ActionController/ParamsWrapper.html) เพื่อทำการ wrap json request โดยค่าเริ่มต้น.

ค่าเริ่มต้นขึ้นอยู่กับเวอร์ชัน `config.load_defaults` เป้าหมาย:

| เริ่มต้นด้วยเวอร์ชัน | ค่าเริ่มต้นคือ |
| --------------------- | -------------------- |
| (เดิม)            | `false`              |
| 7.0                   | `true`               |

#### `ActionController::Base.wrap_parameters`

กำหนดค่า [`ParamsWrapper`](https://api.rubyonrails.org/classes/ActionController/ParamsWrapper.html) สามารถเรียกใช้ได้ที่ระดับบนสุดหรือในคอนโทรลเลอร์แต่ละตัว.

#### `config.action_controller.allow_deprecated_parameters_hash_equality`

ควบคุมพฤติกรรมของ `ActionController::Parameters#==` กับอาร์กิวเมนต์ `Hash` ค่าของการตั้งค่ากำหนดว่า `ActionController::Parameters` จะเท่ากับ `Hash` เทียบเท่ากันหรือไม่.

ค่าเริ่มต้นขึ้นอยู่กับเวอร์ชัน `config.load_defaults` เป้าหมาย:

| เริ่มต้นด้วยเวอร์ชัน | ค่าเริ่มต้นคือ |
| --------------------- | -------------------- |
| (เดิม)            | `true`               |
| 7.1                   | `false`              |

### กำหนดค่า Action Dispatch

#### `config.action_dispatch.cookies_serializer`

ระบุว่าจะใช้ตัวแปรที่ใช้สำหรับ cookies ค่าที่ยอมรับเหมือนกับ [`config.active_support.message_serializer`](#config-active-support-message-serializer),
รวมถึง `:hybrid` ซึ่งเป็นนามแฝงสำหรับ `:json_allow_marshal`.

ค่าเริ่มต้นขึ้นอยู่กับเวอร์ชัน `config.load_defaults` เป้าหมาย:
| เริ่มต้นด้วยเวอร์ชัน | ค่าเริ่มต้นคือ |
| --------------------- | -------------------- |
| (เดิม)               | `:marshal`           |
| 7.0                   | `:json`              |

#### `config.action_dispatch.debug_exception_log_level`

กำหนดระดับการบันทึกที่ใช้โดย DebugExceptions middleware เมื่อบันทึกข้อยกเว้นที่ไม่ถูกจับในระหว่างคำขอ

ค่าเริ่มต้นขึ้นอยู่กับเวอร์ชันเป้าหมายของ `config.load_defaults`:

| เริ่มต้นด้วยเวอร์ชัน | ค่าเริ่มต้นคือ |
| --------------------- | -------------------- |
| (เดิม)               | `:fatal`             |
| 7.1                   | `:error`             |

#### `config.action_dispatch.default_headers`

เป็นแฮชที่มีส่วนหัว HTTP ที่ถูกตั้งค่าเริ่มต้นในแต่ละการตอบสนอง

ค่าเริ่มต้นขึ้นอยู่กับเวอร์ชันเป้าหมายของ `config.load_defaults`:

| เริ่มต้นด้วยเวอร์ชัน | ค่าเริ่มต้นคือ |
| --------------------- | -------------------- |
| (เดิม)               | <pre><code>{<br>  "X-Frame-Options" => "SAMEORIGIN",<br>  "X-XSS-Protection" => "1; mode=block",<br>  "X-Content-Type-Options" => "nosniff",<br>  "X-Download-Options" => "noopen",<br>  "X-Permitted-Cross-Domain-Policies" => "none",<br>  "Referrer-Policy" => "strict-origin-when-cross-origin"<br>}</code></pre> |
| 7.0                   | <pre><code>{<br>  "X-Frame-Options" => "SAMEORIGIN",<br>  "X-XSS-Protection" => "0",<br>  "X-Content-Type-Options" => "nosniff",<br>  "X-Download-Options" => "noopen",<br>  "X-Permitted-Cross-Domain-Policies" => "none",<br>  "Referrer-Policy" => "strict-origin-when-cross-origin"<br>}</code></pre> |
| 7.1                   | <pre><code>{<br>  "X-Frame-Options" => "SAMEORIGIN",<br>  "X-XSS-Protection" => "0",<br>  "X-Content-Type-Options" => "nosniff",<br>  "X-Permitted-Cross-Domain-Policies" => "none",<br>  "Referrer-Policy" => "strict-origin-when-cross-origin"<br>}</code></pre> |

#### `config.action_dispatch.default_charset`

กำหนดชุดอักขระเริ่มต้นสำหรับการเรนเดอร์ทั้งหมด ค่าเริ่มต้นคือ `nil`.

#### `config.action_dispatch.tld_length`

กำหนดความยาวของ TLD (top-level domain) สำหรับแอปพลิเคชัน ค่าเริ่มต้นคือ `1`.
#### `config.action_dispatch.ignore_accept_header`

ใช้เพื่อกำหนดว่าจะเพิกเฉยต่อส่วนหัว accept จากคำขอหรือไม่ ค่าเริ่มต้นคือ `false`.

#### `config.action_dispatch.x_sendfile_header`

ระบุส่วนหัว X-Sendfile ที่เซิร์ฟเวอร์ใช้งาน นี่เป็นประโยชน์สำหรับการส่งไฟล์ด้วยความเร็วจากเซิร์ฟเวอร์ เช่น สามารถตั้งค่าเป็น 'X-Sendfile' สำหรับ Apache.

#### `config.action_dispatch.http_auth_salt`

กำหนดค่าเกลือ HTTP Auth ค่าเริ่มต้นคือ `'http authentication'`.

#### `config.action_dispatch.signed_cookie_salt`

กำหนดค่าเกลือสำหรับลายเซ็นต์คุกกี้ ค่าเริ่มต้นคือ `'signed cookie'`.

#### `config.action_dispatch.encrypted_cookie_salt`

กำหนดค่าเกลือสำหรับคุกกี้ที่เข้ารหัส ค่าเริ่มต้นคือ `'encrypted cookie'`.

#### `config.action_dispatch.encrypted_signed_cookie_salt`

กำหนดค่าเกลือสำหรับลายเซ็นต์คุกกี้ที่เข้ารหัส ค่าเริ่มต้นคือ `'signed encrypted cookie'`.

#### `config.action_dispatch.authenticated_encrypted_cookie_salt`

กำหนดค่าเกลือสำหรับคุกกี้ที่เข้ารหัสและตรวจสอบความถูกต้อง ค่าเริ่มต้นคือ `'authenticated encrypted cookie'`.

#### `config.action_dispatch.encrypted_cookie_cipher`

กำหนดวิธีการเข้ารหัสที่จะใช้สำหรับคุกกี้ที่เข้ารหัส ค่าเริ่มต้นคือ `"aes-256-gcm"`.

#### `config.action_dispatch.signed_cookie_digest`

กำหนดวิธีการเข้ารหัสที่จะใช้สำหรับลายเซ็นต์คุกกี้ ค่าเริ่มต้นคือ `"SHA1"`.

#### `config.action_dispatch.cookies_rotations`

อนุญาตให้หมุนเปลี่ยนคีย์ลับ เทคนิคการเข้ารหัส และการเข้ารหัสสำหรับคุกกี้ที่เข้ารหัสและลายเซ็นต์.

#### `config.action_dispatch.use_authenticated_cookie_encryption`

ควบคุมว่าคุกกี้ที่เข้ารหัสและลายเซ็นต์จะใช้วิธีการเข้ารหัส AES-256-GCM หรือวิธีการเข้ารหัสเก่า AES-256-CBC

ค่าเริ่มต้นขึ้นอยู่กับเวอร์ชันเป้าหมายของ `config.load_defaults`:

| เริ่มต้นเวอร์ชัน | ค่าเริ่มต้นคือ |
| --------------------- | -------------------- |
| (เดิม)            | `false`              |
| 5.2                   | `true`               |

#### `config.action_dispatch.use_cookies_with_metadata`
เปิดใช้งานการเขียนคุกกี้พร้อมข้อมูลเชิงเทคนิคที่ฝังอยู่

ค่าเริ่มต้นขึ้นอยู่กับเวอร์ชันเป้าหมาย `config.load_defaults`:

| เริ่มต้นด้วยเวอร์ชัน | ค่าเริ่มต้นคือ |
| --------------------- | -------------------- |
| (เดิม)            | `false`              |
| 6.0                   | `true`               |

#### `config.action_dispatch.perform_deep_munge`

กำหนดการกำหนดค่าว่าเมธอด `deep_munge` ควรทำงานกับพารามิเตอร์หรือไม่
ดูเพิ่มเติมที่ [Security Guide](security.html#unsafe-query-generation) สำหรับข้อมูลเพิ่มเติม
มันมีค่าเริ่มต้นเป็น `true`.

#### `config.action_dispatch.rescue_responses`

กำหนดการกำหนดค่าว่าข้อยกเว้นใดถูกกำหนดให้กับสถานะ HTTP มันยอมรับแฮชและคุณสามารถระบุคู่ของข้อยกเว้น/สถานะได้ โดยค่าเริ่มต้นนี้ถูกกำหนดเป็น:

```ruby
config.action_dispatch.rescue_responses = {
  'ActionController::RoutingError'
    => :not_found,
  'AbstractController::ActionNotFound'
    => :not_found,
  'ActionController::MethodNotAllowed'
    => :method_not_allowed,
  'ActionController::UnknownHttpMethod'
    => :method_not_allowed,
  'ActionController::NotImplemented'
    => :not_implemented,
  'ActionController::UnknownFormat'
    => :not_acceptable,
  'ActionController::InvalidAuthenticityToken'
    => :unprocessable_entity,
  'ActionController::InvalidCrossOriginRequest'
    => :unprocessable_entity,
  'ActionDispatch::Http::Parameters::ParseError'
    => :bad_request,
  'ActionController::BadRequest'
    => :bad_request,
  'ActionController::ParameterMissing'
    => :bad_request,
  'Rack::QueryParser::ParameterTypeError'
    => :bad_request,
  'Rack::QueryParser::InvalidParameterError'
    => :bad_request,
  'ActiveRecord::RecordNotFound'
    => :not_found,
  'ActiveRecord::StaleObjectError'
    => :conflict,
  'ActiveRecord::RecordInvalid'
    => :unprocessable_entity,
  'ActiveRecord::RecordNotSaved'
    => :unprocessable_entity
}
```

ข้อยกเว้นใดที่ไม่ได้กำหนดค่าจะถูกแมปไปยัง 500 Internal Server Error.

#### `config.action_dispatch.cookies_same_site_protection`

กำหนดค่าเริ่มต้นของแอตทริบิวต์ `SameSite` เมื่อตั้งค่าคุกกี้
เมื่อตั้งค่าเป็น `nil` แอตทริบิวต์ `SameSite` จะไม่ถูกเพิ่มเข้าไป ในกรณีที่ต้องการอนุญาตให้ค่าของแอตทริบิวต์ `SameSite` ถูกกำหนดค่าได้โดยไดนามิกขึ้นอยู่กับคำขอ สามารถระบุเป็น proc ได้ เช่น:
```ruby
config.action_dispatch.cookies_same_site_protection = ->(request) do
  :strict unless request.user_agent == "TestAgent"
end
```

ค่าเริ่มต้นขึ้นอยู่กับเวอร์ชันเป้าหมายของ `config.load_defaults`:

| เริ่มต้นด้วยเวอร์ชัน | ค่าเริ่มต้นคือ |
| --------------------- | -------------------- |
| (เดิม)            | `nil`                |
| 6.1                   | `:lax`               |

#### `config.action_dispatch.ssl_default_redirect_status`

กำหนดค่ารหัสสถานะ HTTP เริ่มต้นที่ใช้เมื่อเปลี่ยนเส้นทางการเรียกของ HTTP ไปยัง HTTPS ใน middleware `ActionDispatch::SSL`.

ค่าเริ่มต้นขึ้นอยู่กับเวอร์ชันเป้าหมายของ `config.load_defaults`:

| เริ่มต้นด้วยเวอร์ชัน | ค่าเริ่มต้นคือ |
| --------------------- | -------------------- |
| (เดิม)            | `307`                |
| 6.1                   | `308`                |

#### `config.action_dispatch.log_rescued_responses`

เปิดใช้งานการบันทึกข้อยกเว้นที่ไม่ได้รับการจัดการที่กำหนดค่าใน `rescue_responses` ค่าเริ่มต้นคือ `true`.

#### `ActionDispatch::Callbacks.before`

รับบล็อกโค้ดที่จะเรียกใช้ก่อนการร้องขอ.

#### `ActionDispatch::Callbacks.after`

รับบล็อกโค้ดที่จะเรียกใช้หลังการร้องขอ.

### การกำหนดค่า Action View

`config.action_view` รวมถึงการกำหนดค่าเล็กน้อย:

#### `config.action_view.cache_template_loading`

ควบคุมว่าต้องโหลดเทมเพลตใหม่ในแต่ละคำขอหรือไม่ ค่าเริ่มต้นคือ `!config.enable_reloading`.

#### `config.action_view.field_error_proc`

ให้ HTML generator สำหรับแสดงข้อผิดพลาดที่มาจาก Active Model บล็อกจะถูกประเมินในบริบทของเทมเพลต Action View ค่าเริ่มต้นคือ

```ruby
Proc.new { |html_tag, instance| content_tag :div, html_tag, class: "field_with_errors" }
```
#### `config.action_view.default_form_builder`

บอก Rails ว่าต้องใช้ form builder ไหนเป็นค่าเริ่มต้น ค่าเริ่มต้นคือ `ActionView::Helpers::FormBuilder` หากคุณต้องการให้คลาส form builder ของคุณถูกโหลดหลังจากการเริ่มต้น (เพื่อให้โหลดใหม่ในแต่ละคำขอในการพัฒนา) คุณสามารถส่งเป็น `String` ได้

#### `config.action_view.logger`

รับ logger ที่เป็นไปตามอินเตอร์เฟซของ Log4r หรือคลาส Ruby Logger เริ่มต้น แล้วใช้ในการบันทึกข้อมูลจาก Action View ตั้งค่าเป็น `nil` เพื่อปิดการบันทึก

#### `config.action_view.erb_trim_mode`

กำหนดโหมดการตัดตอนที่จะใช้กับ ERB ค่าเริ่มต้นคือ `'-'` ซึ่งเปิดใช้การตัดตอนของช่องว่างท้ายและบรรทัดใหม่เมื่อใช้ `<%= -%>` หรือ `<%= =%>` ดูเพิ่มเติมได้ที่ [เอกสาร Erubis](http://www.kuwata-lab.com/erubis/users-guide.06.html#topics-trimspaces)

#### `config.action_view.frozen_string_literal`

คอมไพล์เทมเพลต ERB ด้วยคอมเมนต์เวทมนตร์ `# frozen_string_literal: true` ทำให้สตริงลิตเติลทั้งหมดถูกแช่แข็งและประหยัดการจัดสรรหน่วยความจำ ตั้งค่าเป็น `true` เพื่อเปิดใช้สำหรับทุกวิว

#### `config.action_view.embed_authenticity_token_in_remote_forms`

ช่วยให้คุณสามารถตั้งค่าพฤติกรรมเริ่มต้นสำหรับ `authenticity_token` ในฟอร์มที่มี `remote: true` ได้ ค่าเริ่มต้นคือ `false` ซึ่งหมายความว่าฟอร์มระยะไกลจะไม่รวม `authenticity_token` ซึ่งเป็นประโยชน์เมื่อคุณกำลังใช้การแคชชิ่งของฟอร์ม ฟอร์มระยะไกลจะได้รับความถูกต้องจากแท็ก `meta` ดังนั้นการฝังเป็นสิ่งที่ไม่จำเป็น ยกเว้นกรณีที่คุณสนับสนุนเบราว์เซอร์ที่ไม่มี JavaScript ในกรณีนั้นคุณสามารถส่ง `authenticity_token: true` เป็นตัวเลือกของฟอร์มหรือตั้งค่านี้เป็น `true`
#### `config.action_view.prefix_partial_path_with_controller_namespace`

กำหนดว่าควรหรือไม่ควรค้นหา partials จาก subdirectory ในเทมเพลตที่ถูก render จาก namespaced controllers ตัวอย่างเช่น พิจารณา controller ที่ชื่อว่า `Admin::ArticlesController` ซึ่ง render เทมเพลตนี้:

```erb
<%= render @article %>
```

การตั้งค่าเริ่มต้นคือ `true` ซึ่งใช้ partial ที่ `/admin/articles/_article.erb` การตั้งค่าเป็น `false` จะ render `/articles/_article.erb` ซึ่งเป็นพฤติกรรมเดียวกับการ render จาก controller ที่ไม่มี namespaced เช่น `ArticlesController`.

#### `config.action_view.automatically_disable_submit_tag`

กำหนดว่า `submit_tag` ควรปิดใช้งานโดยอัตโนมัติเมื่อคลิก ค่าเริ่มต้นคือ `true`.

#### `config.action_view.debug_missing_translation`

กำหนดว่าควรห่อหุ้มคีย์ของ missing translations ด้วยแท็ก `<span>` หรือไม่ ค่าเริ่มต้นคือ `true`.

#### `config.action_view.form_with_generates_remote_forms`

กำหนดว่า `form_with` ควรสร้าง remote forms หรือไม่

ค่าเริ่มต้นขึ้นอยู่กับเวอร์ชันเป้าหมายของ `config.load_defaults`:

| เริ่มต้นเวอร์ชัน | ค่าเริ่มต้นคือ |
| --------------------- | -------------------- |
| 5.1                   | `true`               |
| 6.1                   | `false`              |

#### `config.action_view.form_with_generates_ids`

กำหนดว่า `form_with` ควรสร้าง ids บน inputs หรือไม่

ค่าเริ่มต้นขึ้นอยู่กับเวอร์ชันเป้าหมายของ `config.load_defaults`:

| เริ่มต้นเวอร์ชัน | ค่าเริ่มต้นคือ |
| --------------------- | -------------------- |
| (เดิม)            | `false`              |
| 5.2                   | `true`               |

#### `config.action_view.default_enforce_utf8`

กำหนดว่าควรสร้างฟอร์มพร้อมแท็กซ่อนที่บังคับให้เวอร์ชันเก่าของ Internet Explorer ส่งฟอร์มที่เข้ารหัสด้วย UTF-8.
ค่าเริ่มต้นขึ้นอยู่กับเวอร์ชันเป้าหมาย `config.load_defaults`:

| เริ่มต้นด้วยเวอร์ชัน | ค่าเริ่มต้นคือ |
| --------------------- | -------------------- |
| (เดิม)            | `true`               |
| 6.0                   | `false`              |

#### `config.action_view.image_loading`

ระบุค่าเริ่มต้นสำหรับแอตทริบิวต์ `loading` ของแท็ก `<img>` ที่ถูกแสดงผลโดยตัวช่วย `image_tag` ตัวอย่างเช่นเมื่อตั้งค่าเป็น `"lazy"` แท็ก `<img>` ที่ถูกแสดงผลโดย `image_tag` จะรวม `loading="lazy"` ซึ่ง [แนะนำให้เบราว์เซอร์รอจนกว่ารูปภาพจะอยู่ใกล้กับพอร์ตที่มองเห็นเพื่อโหลด](https://html.spec.whatwg.org/#lazy-loading-attributes) (ค่านี้ยังสามารถเขียนทับได้ต่อรูปภาพแต่ละรูปโดยการส่งเช่น `loading: "eager"` ไปยัง `image_tag`) ค่าเริ่มต้นคือ `nil`.

#### `config.action_view.image_decoding`

ระบุค่าเริ่มต้นสำหรับแอตทริบิวต์ `decoding` ของแท็ก `<img>` ที่ถูกแสดงผลโดยตัวช่วย `image_tag` ค่าเริ่มต้นคือ `nil`.

#### `config.action_view.annotate_rendered_view_with_filenames`

กำหนดว่าจะให้ทำเครื่องหมายแสดงผลวิวที่ถูกแสดงด้วยชื่อไฟล์เทมเพลตหรือไม่ ค่าเริ่มต้นคือ `false`.

#### `config.action_view.preload_links_header`

กำหนดว่า `javascript_include_tag` และ `stylesheet_link_tag` จะสร้าง `Link` header เพื่อโหลดล่วงหน้าทรัพยากรหรือไม่.

ค่าเริ่มต้นขึ้นอยู่กับเวอร์ชันเป้าหมาย `config.load_defaults`:

| เริ่มต้นด้วยเวอร์ชัน | ค่าเริ่มต้นคือ |
| --------------------- | -------------------- |
| (เดิม)            | `nil`                |
| 6.1                   | `true`               |

#### `config.action_view.button_to_generates_button_tag`

กำหนดว่า `button_to` จะแสดงอิลิเมนต์ `<button>` ไม่ว่าเนื้อหาจะถูกส่งผ่านเป็นอาร์กิวเมนต์แรกหรือเป็นบล็อกหรือไม่.
ค่าเริ่มต้นขึ้นอยู่กับเวอร์ชันเป้าหมายของ `config.load_defaults`:

| เริ่มต้นด้วยเวอร์ชัน | ค่าเริ่มต้นคือ |
| --------------------- | -------------------- |
| (เดิม)               | `false`              |
| 7.0                   | `true`               |

#### `config.action_view.apply_stylesheet_media_default`

กำหนดว่า `stylesheet_link_tag` จะแสดง `screen` เป็นค่าเริ่มต้นสำหรับแอตทริบิวต์ `media` เมื่อไม่ได้ระบุ

ค่าเริ่มต้นขึ้นอยู่กับเวอร์ชันเป้าหมายของ `config.load_defaults`:

| เริ่มต้นด้วยเวอร์ชัน | ค่าเริ่มต้นคือ |
| --------------------- | -------------------- |
| (เดิม)               | `true`               |
| 7.0                   | `false`              |

#### `config.action_view.prepend_content_exfiltration_prevention`

กำหนดว่า `form_tag` และ `button_to` helpers จะสร้างแท็ก HTML ที่ถูกเติมไว้ด้านหน้าด้วย HTML ที่ปลอดภัยสำหรับเบราว์เซอร์ (แต่เทคนิคที่ไม่ถูกต้องตามมาตรฐาน) ที่รับรองว่าเนื้อหาของแท็กไม่สามารถถูกจับได้โดยแท็กที่ไม่ได้ปิดไว้ก่อนหน้านี้ ค่าเริ่มต้นคือ `false`.

#### `config.action_view.sanitizer_vendor`

กำหนดค่า HTML sanitizers ที่ใช้โดย Action View โดยการตั้งค่า `ActionView::Helpers::SanitizeHelper.sanitizer_vendor`. ค่าเริ่มต้นขึ้นอยู่กับเวอร์ชันเป้าหมายของ `config.load_defaults`:

| เริ่มต้นด้วยเวอร์ชัน | ค่าเริ่มต้นคือ                 | ซึ่งแยกวิเคราะห์มาร์กอัปเปิลเป็น |
|-----------------------|--------------------------------------|------------------------|
| (เดิม)               | `Rails::HTML4::Sanitizer`            | HTML4                  |
| 7.1                   | `Rails::HTML5::Sanitizer` (ดู NOTE) | HTML5                  |

NOTE: `Rails::HTML5::Sanitizer` ไม่รองรับบน JRuby ดังนั้นในแพลตฟอร์ม JRuby Rails จะถูกสลับกลับมาใช้ `Rails::HTML4::Sanitizer`.
### การกำหนดค่า Action Mailbox

`config.action_mailbox` ให้คุณสามารถกำหนดค่าต่อไปนี้ได้:

#### `config.action_mailbox.logger`

มี logger ที่ใช้โดย Action Mailbox มันรับ logger ที่เป็นไปตามอินเตอร์เฟซของ Log4r หรือคลาส Ruby Logger เริ่มต้นคือ `Rails.logger`.

```ruby
config.action_mailbox.logger = ActiveSupport::Logger.new(STDOUT)
```

#### `config.action_mailbox.incinerate_after`

รับ `ActiveSupport::Duration` ที่ระบุเวลาหลังจากการประมวลผล `ActionMailbox::InboundEmail` ที่ควรทำลายบันทึก ค่าเริ่มต้นคือ `30.days`.

```ruby
# ทำลายอีเมลขาเข้า 14 วันหลังจากการประมวลผล
config.action_mailbox.incinerate_after = 14.days
```

#### `config.action_mailbox.queues.incineration`

รับสัญลักษณ์ที่ระบุคิว Active Job ที่ใช้สำหรับงานการทำลาย หากตัวเลือกนี้เป็น `nil` งานการทำลายจะถูกส่งไปยังคิว Active Job ที่เป็นค่าเริ่มต้น (ดู `config.active_job.default_queue_name`).

ค่าเริ่มต้นขึ้นอยู่กับเวอร์ชันเป้าหมายของ `config.load_defaults`:

| เริ่มต้นเวอร์ชัน | ค่าเริ่มต้นคือ |
| --------------------- | -------------------- |
| (เดิม)            | `:action_mailbox_incineration` |
| 6.1                   | `nil`                |

#### `config.action_mailbox.queues.routing`

รับสัญลักษณ์ที่ระบุคิว Active Job ที่ใช้สำหรับงานการเส้นทาง หากตัวเลือกนี้เป็น `nil` งานการเส้นทางจะถูกส่งไปยังคิว Active Job ที่เป็นค่าเริ่มต้น (ดู `config.active_job.default_queue_name`).

ค่าเริ่มต้นขึ้นอยู่กับเวอร์ชันเป้าหมายของ `config.load_defaults`:

| เริ่มต้นเวอร์ชัน | ค่าเริ่มต้นคือ |
| --------------------- | -------------------- |
| (เดิม)            | `:action_mailbox_routing` |
| 6.1                   | `nil`                |
#### `config.action_mailbox.storage_service`

ยอมรับสัญลักษณ์ที่แสดงถึง Active Storage service ที่จะใช้ในการอัปโหลดอีเมล์ หากตัวเลือกนี้เป็น `nil` อีเมล์จะถูกอัปโหลดไปยัง Active Storage service เริ่มต้น (ดู `config.active_storage.service`)

### การกำหนดค่า Action Mailer

มีการตั้งค่าหลายรายการที่ใช้ได้บน `config.action_mailer`:

#### `config.action_mailer.asset_host`

กำหนดโฮสต์สำหรับทรัพยากร มีประโยชน์เมื่อใช้ CDN ในการโฮสต์ทรัพยากรแทนเซิร์ฟเวอร์แอปพลิเคชันเอง คุณควรใช้เฉพาะกรณีที่คุณมีการกำหนดค่าที่แตกต่างสำหรับ Action Controller เท่านั้น มิฉะนั้นให้ใช้ `config.asset_host`

#### `config.action_mailer.logger`

ยอมรับ logger ที่เป็นไปตามอินเตอร์เฟซของ Log4r หรือคลาส Logger ของ Ruby ที่เป็นค่าเริ่มต้น ซึ่งจะใช้ในการบันทึกข้อมูลจาก Action Mailer ตั้งค่าเป็น `nil` เพื่อปิดการบันทึกข้อมูล

#### `config.action_mailer.smtp_settings`

อนุญาตให้กำหนดค่าอย่างละเอียดสำหรับวิธีการส่ง `:smtp` โดยยอมรับแฮชของตัวเลือกที่สามารถรวมอยู่ในตัวเลือกเหล่านี้ได้:

* `:address` - ช่วยให้คุณสามารถใช้เซิร์ฟเวอร์จดหมายระยะไกลได้ แค่เปลี่ยนจากการตั้งค่าเริ่มต้น "localhost" ของมัน
* `:port` - ในกรณีที่เซิร์ฟเวอร์จดหมายของคุณไม่ทำงานบนพอร์ต 25 คุณสามารถเปลี่ยนได้
* `:domain` - หากคุณต้องการระบุโดเมน HELO คุณสามารถทำได้ที่นี่
* `:user_name` - หากเซิร์ฟเวอร์จดหมายของคุณต้องการการรับรองตัวตน ให้ตั้งค่าชื่อผู้ใช้ในการตั้งค่านี้
* `:password` - หากเซิร์ฟเวอร์จดหมายของคุณต้องการการรับรองตัวตน ให้ตั้งค่ารหัสผ่านในการตั้งค่านี้
* `:authentication` - หากเซิร์ฟเวอร์จดหมายของคุณต้องการการรับรองตัวตน คุณต้องระบุประเภทการรับรองตัวตนที่นี่ นี่เป็นสัญลักษณ์และเป็นหนึ่งใน `:plain`, `:login`, `:cram_md5`
* `:enable_starttls` - ใช้ STARTTLS เมื่อเชื่อมต่อกับเซิร์ฟเวอร์ SMTP และล้มเหลวหากไม่รองรับ ค่าเริ่มต้นคือ `false`
* `:enable_starttls_auto` - ตรวจสอบว่า STARTTLS เปิดใช้งานในเซิร์ฟเวอร์ SMTP และเริ่มใช้งาน ค่าเริ่มต้นคือ `true`
* `:openssl_verify_mode` - เมื่อใช้ TLS คุณสามารถตั้งค่าวิธีการตรวจสอบใบรับรองของ OpenSSL ได้ สามารถใช้ได้ถ้าคุณต้องการตรวจสอบใบรับรองที่ลงชื่อด้วยตนเองและ/หรือใบรับรองแบบไวล์การ์ด สามารถเป็นหนึ่งในค่าคงที่การตรวจสอบของ OpenSSL `:none` หรือ `:peer` -- หรือค่าคงที่โดยตรง `OpenSSL::SSL::VERIFY_NONE` หรือ `OpenSSL::SSL::VERIFY_PEER` ตามลำดับ
* `:ssl/:tls` - เปิดใช้งานการเชื่อมต่อ SMTP เพื่อใช้งาน SMTP/TLS (SMTPS: การเชื่อมต่อ SMTP ผ่านการเชื่อมต่อ TLS โดยตรง)
* `:open_timeout` - จำนวนวินาทีที่ต้องรอขณะพยายามเปิดการเชื่อมต่อ
* `:read_timeout` - จำนวนวินาทีที่ต้องรอจนกว่าการเรียกใช้งาน read(2) จะหมดเวลา
นอกจากนี้ยังสามารถส่งผ่าน [ตัวเลือกการกำหนดค่า `Mail::SMTP`](https://github.com/mikel/mail/blob/master/lib/mail/network/delivery_methods/smtp.rb) ได้

#### `config.action_mailer.smtp_timeout`

ช่วยให้สามารถกำหนดค่า `:open_timeout` และ `:read_timeout` สำหรับวิธีการส่ง `:smtp` ได้

ค่าเริ่มต้นขึ้นอยู่กับเวอร์ชันเป้าหมายของ `config.load_defaults`:

| เริ่มต้นเวอร์ชัน | ค่าเริ่มต้นคือ |
| --------------------- | -------------------- |
| (เดิม)            | `nil`                |
| 7.0                   | `5`                  |

#### `config.action_mailer.sendmail_settings`

ช่วยในการกำหนดค่าอย่างละเอียดสำหรับวิธีการส่ง `sendmail` มันยอมรับแฮชของตัวเลือกที่สามารถรวมอยู่ในตัวเลือกเหล่านี้ได้:

* `:location` - ตำแหน่งของไฟล์ส่งเมล sendmail ค่าเริ่มต้นคือ `/usr/sbin/sendmail`
* `:arguments` - อาร์กิวเมนต์บรรทัดคำสั่ง ค่าเริ่มต้นคือ `%w[ -i ]`

#### `config.action_mailer.raise_delivery_errors`

กำหนดว่าจะเรียกข้อผิดพลาดหากการส่งอีเมลไม่สามารถเสร็จสิ้นได้ ค่าเริ่มต้นคือ `true`

#### `config.action_mailer.delivery_method`

กำหนดวิธีการส่งและค่าเริ่มต้นคือ `:smtp` ดูข้อมูลเพิ่มเติมในส่วนการกำหนดค่าในเอกสารแนะนำ Action Mailer

#### `config.action_mailer.perform_deliveries`

กำหนดว่าจะส่งจริงหรือไม่และค่าเริ่มต้นคือ `true` สามารถตั้งค่าเป็น `false` สำหรับการทดสอบได้

#### `config.action_mailer.default_options`

กำหนดค่าเริ่มต้นของ Action Mailer ใช้สำหรับตั้งค่าเช่น `from` หรือ `reply_to` สำหรับทุกเมลเลอร์ ค่าเริ่มต้นคือ:

```ruby
mime_version:  "1.0",
charset:       "UTF-8",
content_type: "text/plain",
parts_order:  ["text/plain", "text/enriched", "text/html"]
```
กำหนดค่าแฮชเพื่อตั้งค่าตัวเลือกเพิ่มเติม:

```ruby
config.action_mailer.default_options = {
  from: "noreply@example.com"
}
```

#### `config.action_mailer.observers`

ลงทะเบียนผู้สังเกตการณ์ที่จะได้รับการแจ้งเมื่อส่งจดหมาย

```ruby
config.action_mailer.observers = ["MailObserver"]
```

#### `config.action_mailer.interceptors`

ลงทะเบียนตัวกระทำก่อนที่จะส่งจดหมาย

```ruby
config.action_mailer.interceptors = ["MailInterceptor"]
```

#### `config.action_mailer.preview_interceptors`

ลงทะเบียนตัวกระทำก่อนที่จะแสดงตัวอย่างจดหมาย

```ruby
config.action_mailer.preview_interceptors = ["MyPreviewMailInterceptor"]
```

#### `config.action_mailer.preview_paths`

ระบุตำแหน่งของตัวอย่างจดหมาย. เพิ่มเส้นทางไปยังตัวเลือกการกำหนดค่านี้จะทำให้ใช้เส้นทางเหล่านั้นในการค้นหาตัวอย่างจดหมาย

```ruby
config.action_mailer.preview_paths << "#{Rails.root}/lib/mailer_previews"
```

#### `config.action_mailer.show_previews`

เปิดหรือปิดการแสดงตัวอย่างจดหมาย. โดยค่าเริ่มต้นในโหมดการพัฒนาคือ `true`

```ruby
config.action_mailer.show_previews = false
```

#### `config.action_mailer.perform_caching`

ระบุว่าเทมเพลตจดหมายควรทำการแคชชิ้นหรือไม่. หากไม่ได้ระบุ ค่าเริ่มต้นจะเป็น `true`

#### `config.action_mailer.deliver_later_queue_name`

ระบุคิว Active Job ที่จะใช้สำหรับงานส่งจดหมายเริ่มต้น (ดู `config.action_mailer.delivery_job`). เมื่อตัวเลือกนี้ถูกตั้งค่าเป็น `nil`, งานส่งจดหมายจะถูกส่งไปยังคิว Active Job เริ่มต้น (ดู `config.active_job.default_queue_name`).

คลาสเมลเลอร์สามารถเขียนทับค่านี้เพื่อใช้คิวที่แตกต่างกันได้. โปรดทราบว่านี้ใช้เฉพาะเมื่อใช้งานงานส่งจดหมายเริ่มต้น. หากเมลเลอร์ของคุณใช้งานงานที่กำหนดเอง คิวของงานนั้นจะถูกใช้งาน
ตรวจสอบให้แน่ใจว่า Active Job adapter ของคุณได้รับการกำหนดค่าให้ประมวลผลคิวที่ระบุไว้ด้วย มิฉะนั้นงานการส่งจะถูกละเลยโดยไม่มีการแจ้งเตือน

ค่าเริ่มต้นขึ้นอยู่กับเวอร์ชันเป้าหมายของ `config.load_defaults`:

| เริ่มต้นด้วยเวอร์ชัน | ค่าเริ่มต้นคือ |
| --------------------- | -------------------- |
| (เดิม)            | `:mailers`           |
| 6.1                   | `nil`                |

#### `config.action_mailer.delivery_job`

ระบุงานการส่งสำหรับอีเมล

ค่าเริ่มต้นขึ้นอยู่กับเวอร์ชันเป้าหมายของ `config.load_defaults`:

| เริ่มต้นด้วยเวอร์ชัน | ค่าเริ่มต้นคือ |
| --------------------- | -------------------- |
| (เดิม)            | `ActionMailer::MailDeliveryJob` |
| 6.0                   | `"ActionMailer::MailDeliveryJob"` |

### การกำหนดค่า Active Support

มีตัวเลือกการกำหนดค่าใน Active Support มากหลายตัวเลือก:

#### `config.active_support.bare`

เปิดหรือปิดการโหลด `active_support/all` เมื่อเริ่มต้น Rails ค่าเริ่มต้นคือ `nil` ซึ่งหมายความว่า `active_support/all` จะถูกโหลด

#### `config.active_support.test_order`

กำหนดลำดับที่ทดสอบจะถูกดำเนินการ ค่าที่เป็นไปได้คือ `:random` และ `:sorted` ค่าเริ่มต้นคือ `:random`

#### `config.active_support.escape_html_entities_in_json`

เปิดหรือปิดการหนีไปยัง HTML entities ในการแปลงเป็น JSON ค่าเริ่มต้นคือ `true`

#### `config.active_support.use_standard_json_time_format`

เปิดหรือปิดการแปลงวันที่เป็นรูปแบบ ISO 8601 ในการแปลงเป็น JSON ค่าเริ่มต้นคือ `true`

#### `config.active_support.time_precision`

กำหนดความแม่นยำของค่าเวลาที่ถูกเข้ารหัสเป็น JSON ค่าเริ่มต้นคือ `3`

#### `config.active_support.hash_digest_class`

อนุญาตให้กำหนดค่าคลาสของการเข้ารหัสเพื่อสร้างการเข้ารหัสที่ไม่ได้เป็นข้อมูลที่สำคัญ เช่น ETag header
ค่าเริ่มต้นขึ้นอยู่กับเวอร์ชันเป้าหมาย `config.load_defaults`:

| เริ่มต้นด้วยเวอร์ชัน | ค่าเริ่มต้นคือ |
| --------------------- | -------------------- |
| (เดิม)            | `OpenSSL::Digest::MD5` |
| 5.2                   | `OpenSSL::Digest::SHA1` |
| 7.0                   | `OpenSSL::Digest::SHA256` |

#### `config.active_support.key_generator_hash_digest_class`

ช่วยกำหนดค่าคลาสของการเข้ารหัสที่จะใช้ในการสร้างคีย์จากฐานความลับที่กำหนดไว้ เช่นสำหรับคุกกี้ที่เข้ารหัส

ค่าเริ่มต้นขึ้นอยู่กับเวอร์ชันเป้าหมาย `config.load_defaults`:

| เริ่มต้นด้วยเวอร์ชัน | ค่าเริ่มต้นคือ |
| --------------------- | -------------------- |
| (เดิม)            | `OpenSSL::Digest::SHA1` |
| 7.0                   | `OpenSSL::Digest::SHA256` |

#### `config.active_support.use_authenticated_message_encryption`

ระบุว่าจะใช้การเข้ารหัสที่ได้รับการรับรอง AES-256-GCM เป็นรหัสเริ่มต้นในการเข้ารหัสข้อความแทน AES-256-CBC

ค่าเริ่มต้นขึ้นอยู่กับเวอร์ชันเป้าหมาย `config.load_defaults`:

| เริ่มต้นด้วยเวอร์ชัน | ค่าเริ่มต้นคือ |
| --------------------- | -------------------- |
| (เดิม)            | `false`              |
| 5.2                   | `true`               |

#### `config.active_support.message_serializer`

ระบุซีเรียลไรเซอร์เริ่มต้นที่ใช้โดย [`ActiveSupport::MessageEncryptor`][]
และ [`ActiveSupport::MessageVerifier`][] instances. เพื่อทำให้การย้ายระหว่างซีเรียลไรเซอร์ง่ายขึ้น ซีเรียลไรเซอร์ที่ให้มานี้รวมการสนับสนุน fallback mechanism เพื่อรองรับรูปแบบการถอดรหัสหลายรูปแบบ:

| ซีเรียลไรเซอร์ | ซีเรียลไรเซอร์และถอดรหัส | ซีเรียลไรเซอร์ถอดรหัส fallback |
| ---------- | ------------------------- | -------------------- |
| `:marshal` | `Marshal` | `ActiveSupport::JSON`, `ActiveSupport::MessagePack` |
| `:json` | `ActiveSupport::JSON` | `ActiveSupport::MessagePack` |
| `:json_allow_marshal` | `ActiveSupport::JSON` | `ActiveSupport::MessagePack`, `Marshal` |
| `:message_pack` | `ActiveSupport::MessagePack` | `ActiveSupport::JSON` |
| `:message_pack_allow_marshal` | `ActiveSupport::MessagePack` | `ActiveSupport::JSON`, `Marshal` |
คำเตือน: `Marshal` เป็นเวกเตอร์ที่เป็นไปได้สำหรับการโจมตีการแปลงรหัสในกรณีที่ความลับในการเซ็นต์ข้อความได้รั่วไหล หากเป็นไปได้โปรดเลือกตัวแปรที่ไม่รองรับ `Marshal` 

ข้อมูล: ตัวแปร `:message_pack` และ `:message_pack_allow_marshal` รองรับการรอบรับบางประเภทของ Ruby ที่ไม่รองรับโดย JSON เช่น `Symbol` นอกจากนี้ยังสามารถให้ประสิทธิภาพที่ดีขึ้นและขนาดข้อมูลที่เล็กลงได้ อย่างไรก็ตาม ต้องใช้ [`msgpack` gem](https://rubygems.org/gems/msgpack) 

แต่ละตัวแปรด้านบนจะส่งออกการแจ้งเตือนเหตุการณ์ [`message_serializer_fallback.active_support`][] เมื่อพวกเขาต้องพลาดไปยังรูปแบบการแปลงรหัสที่แตกต่าง เพื่อให้คุณสามารถติดตามได้ว่าการพลาดเหตุการณ์เช่นนี้เกิดขึ้นบ่อยแค่ไหน

หรือในกรณีที่ต้องการคุณสามารถระบุวัตถุตัวแปรใดก็ได้ที่ตอบสนองกับวิธีการ `dump` และ `load` ตัวอย่างเช่น:

```ruby
config.active_job.message_serializer = YAML
```

ค่าเริ่มต้นขึ้นอยู่กับเวอร์ชันเป้าหมายของ `config.load_defaults`:

| เริ่มต้นด้วยเวอร์ชัน | ค่าเริ่มต้นคือ |
| --------------------- | -------------------- |
| (เดิม)            | `:marshal`           |
| 7.1                   | `:json_allow_marshal` |


#### `config.active_support.use_message_serializer_for_metadata`

เมื่อเป็นจริง จะเปิดใช้งานการประสิทธิภาพที่ประหยัดเวลาในการแปลงรหัสข้อมูลข้อความและข้อมูลเมตาดาต้ารวมกัน สิ่งนี้เปลี่ยนรูปแบบข้อความดังนั้นข้อความที่ถูกแปลงรหัสแบบนี้จะไม่สามารถอ่านได้โดยเวอร์ชันเก่า (< 7.1) ของ Rails อย่างไรก็ตาม ข้อความที่ใช้รูปแบบเก่ายังสามารถอ่านได้ไม่ว่าจะเปิดใช้งานการประสิทธิภาพนี้หรือไม่ก็ตาม
ค่าเริ่มต้นขึ้นอยู่กับเวอร์ชันเป้าหมาย `config.load_defaults`:

| เริ่มต้นด้วยเวอร์ชัน | ค่าเริ่มต้นคือ |
| --------------------- | -------------------- |
| (เดิม)            | `false`              |
| 7.1                   | `true`               |

#### `config.active_support.cache_format_version`

ระบุรูปแบบการซีเรียลไซซ์ที่จะใช้สำหรับแคช ค่าที่เป็นไปได้คือ `6.1`, `7.0`, และ `7.1`.

รูปแบบ `6.1`, `7.0`, และ `7.1` ใช้ `Marshal` เป็นโคเดอร์เริ่มต้น แต่ `7.0` ใช้การแสดงผลที่มีประสิทธิภาพมากขึ้นสำหรับรายการแคช และ `7.1` รวมการปรับปรุงเพิ่มเติมสำหรับค่าสตริงเปล่าเช่นเฟรกเมนต์ของวิว.

รูปแบบทั้งหมดสามารถทำงานได้ทั้งย้อนหลังและสู่หน้า, ซึ่งหมายความว่ารายการแคชที่เขียนในรูปแบบหนึ่งสามารถอ่านได้เมื่อใช้รูปแบบอื่น ๆ การทำงานนี้ทำให้ง่ายต่อการย้ายระหว่างรูปแบบโดยไม่ต้องทำให้แคชทั้งหมดเสียหาย.

ค่าเริ่มต้นขึ้นอยู่กับเวอร์ชันเป้าหมาย `config.load_defaults`:

| เริ่มต้นด้วยเวอร์ชัน | ค่าเริ่มต้นคือ |
| --------------------- | -------------------- |
| (เดิม)            | `6.1`                |
| 7.0                   | `7.0`                |
| 7.1                   | `7.1`                |

#### `config.active_support.deprecation`

กำหนดค่าพฤติกรรมของการเตือนเรื่องการเลิกใช้. ตัวเลือกที่มีคือ `:raise`, `:stderr`, `:log`, `:notify`, และ `:silence`.

ในไฟล์ `config/environments` ที่สร้างขึ้นเริ่มต้น, ค่านี้ถูกตั้งค่าเป็น `:log` สำหรับการพัฒนาและ `:stderr` สำหรับการทดสอบ, และถูกละเลยสำหรับการผลิตในทางที่ดีกว่า [`config.active_support.report_deprecations`](#config-active-support-report-deprecations).
#### `config.active_support.disallowed_deprecation`

กำหนดค่าพฤติกรรมของการแจ้งเตือนการเลิกใช้ที่ไม่ได้รับอนุญาต ตัวเลือกที่มีคือ `:raise`, `:stderr`, `:log`, `:notify`, และ `:silence` 

ในไฟล์ `config/environments` ที่สร้างขึ้นโดยค่าเริ่มต้น ค่านี้ถูกตั้งค่าเป็น `:raise` สำหรับทั้งการพัฒนาและการทดสอบ และถูกละเลยสำหรับการใช้งานจริงเพื่อให้ได้ [`config.active_support.report_deprecations`](#config-active-support-report-deprecations) 

#### `config.active_support.disallowed_deprecation_warnings`

กำหนดค่าการเตือนเลิกใช้ที่แอปพลิเคชันถือว่าไม่ได้รับอนุญาต สามารถทำให้การเตือนเลิกใช้เฉพาะบางอย่างถูกจัดการเป็นความล้มเหลวได้

#### `config.active_support.report_deprecations`

เมื่อเป็น `false` จะปิดการแจ้งเตือนการเลิกใช้ทั้งหมด รวมถึงการเตือนการเลิกใช้ที่ไม่ได้รับอนุญาต จาก [deprecators ของแอปพลิเคชัน](https://api.rubyonrails.org/classes/Rails/Application.html#method-i-deprecators) ซึ่งรวมถึงการเตือนการเลิกใช้ทั้งหมดจาก Rails และแพ็กเกจอื่น ๆ ที่อาจเพิ่ม deprecator ของตนเองเข้าสู่คอลเลกชันของ deprecators แต่อาจไม่สามารถป้องกันการแจ้งเตือนการเลิกใช้ทั้งหมดที่ออกจาก ActiveSupport::Deprecation

ในไฟล์ `config/environments` ที่สร้างขึ้นโดยค่าเริ่มต้น ค่านี้ถูกตั้งค่าเป็น `false` สำหรับการใช้งานจริง

#### `config.active_support.isolation_level`

กำหนดค่าความใกล้ชิดของสถานที่เก็บข้อมูลภายใน Rails ส่วนใหญ่ หากคุณใช้เซิร์ฟเวอร์หรือตัวประมวลผลงานที่ใช้เส้นใย (เช่น `falcon`) คุณควรตั้งค่าเป็น `:fiber` มิฉะนั้นควรใช้ความใกล้ชิดเป็น `:thread` ค่าเริ่มต้นคือ `:thread`

#### `config.active_support.executor_around_test_case`

กำหนดการกำหนดค่าชุดทดสอบให้เรียกใช้ `Rails.application.executor.wrap` รอบกรณีทดสอบ
นี้ทำให้กรณีทดสอบมีพฤติกรรมใกล้เคียงกับคำขอหรืองานจริง
มีคุณสมบัติหลายอย่างที่ปกติถูกปิดในการทดสอบ เช่น แคชคิวรีคิวรี่ Active Record
และคิวรี่แบบไม่เชื่อมต่อจะถูกเปิดใช้งาน
ค่าเริ่มต้นขึ้นอยู่กับเวอร์ชันเป้าหมาย `config.load_defaults`:

| เริ่มต้นด้วยเวอร์ชัน | ค่าเริ่มต้นคือ |
| --------------------- | -------------------- |
| (เดิม)            | `false`              |
| 7.0                   | `true`               |

#### `ActiveSupport::Logger.silencer`

ถูกตั้งค่าเป็น `false` เพื่อปิดการใช้งานการปิดเสียงบันทึกในบล็อก ค่าเริ่มต้นคือ `true` 

#### `ActiveSupport::Cache::Store.logger`

ระบุ logger ที่จะใช้ในการดำเนินการของ cache store

#### `ActiveSupport.to_time_preserves_timezone`

ระบุว่า `to_time` methods จะเก็บรักษา UTC offset ของตัวรับของพวกเขาหรือไม่ หาก `false` `to_time` methods จะแปลงเป็น UTC offset ของระบบท้องถิ่นแทน

ค่าเริ่มต้นขึ้นอยู่กับเวอร์ชันเป้าหมาย `config.load_defaults`:

| เริ่มต้นด้วยเวอร์ชัน | ค่าเริ่มต้นคือ |
| --------------------- | -------------------- |
| (เดิม)            | `false`              |
| 5.0                   | `true`               |

#### `ActiveSupport.utc_to_local_returns_utc_offset_times`

กำหนดค่า `ActiveSupport::TimeZone.utc_to_local` เพื่อให้คืนค่าเวลาที่มี UTC offset แทนเวลา UTC ที่รวมถึง offset นั้น

ค่าเริ่มต้นขึ้นอยู่กับเวอร์ชันเป้าหมาย `config.load_defaults`:

| เริ่มต้นด้วยเวอร์ชัน | ค่าเริ่มต้นคือ |
| --------------------- | -------------------- |
| (เดิม)            | `false`              |
| 6.1                   | `true`               |

#### `config.active_support.raise_on_invalid_cache_expiration_time`

ระบุว่าควรเกิดข้อผิดพลาด `ArgumentError` หาก `Rails.cache` `fetch` หรือ `write` ได้รับเวลา `expires_at` หรือ `expires_in` ที่ไม่ถูกต้อง
ตัวเลือกที่มีคือ `true` และ `false` หากเป็น `false` ข้อยกเว้นจะถูกรายงานว่า `handled` และถูกบันทึกลงในระบบเป็นปกติ

ค่าเริ่มต้นขึ้นอยู่กับเวอร์ชันเป้าหมายของ `config.load_defaults`:

| เริ่มต้นด้วยเวอร์ชัน | ค่าเริ่มต้นคือ |
| --------------------- | -------------------- |
| (เดิม)            | `false`              |
| 7.1                   | `true`               |

### การกำหนดค่า Active Job

`config.active_job` มีตัวเลือกการกำหนดค่าต่อไปนี้:

#### `config.active_job.queue_adapter`

กำหนดอะแดปเตอร์สำหรับระบบคิว อะแดปเตอร์เริ่มต้นคือ `:async` สำหรับรายการอะแดปเตอร์ที่มีอยู่ให้ดูที่ [เอพีไอ ActiveJob::QueueAdapters](https://api.rubyonrails.org/classes/ActiveJob/QueueAdapters.html)

```ruby
# ตรวจสอบให้แน่ใจว่ามี gem ของอะแดปเตอร์ใน Gemfile และทำตามคำแนะนำการติดตั้งและการใช้งานของอะแดปเตอร์นั้น
config.active_job.queue_adapter = :sidekiq
```

#### `config.active_job.default_queue_name`

สามารถใช้เปลี่ยนชื่อคิวเริ่มต้นได้ โดยค่าเริ่มต้นคือ `"default"`

```ruby
config.active_job.default_queue_name = :medium_priority
```

#### `config.active_job.queue_name_prefix`

ช่วยให้คุณสามารถกำหนดคำนำหน้าชื่อคิวที่ไม่ว่างเปล่าสำหรับงานทั้งหมดได้ ค่าเริ่มต้นคือว่างเปล่าและไม่ถูกใช้งาน

การกำหนดค่าต่อไปนี้จะเพิ่มงานที่กำหนดในคิว `production_high_priority` เมื่อทำงานในโหมดการใช้งานจริง:

```ruby
config.active_job.queue_name_prefix = Rails.env
```

```ruby
class GuestsCleanupJob < ActiveJob::Base
  queue_as :high_priority
  #....
end
```

#### `config.active_job.queue_name_delimiter`

มีค่าเริ่มต้นเป็น `'_'` หากตั้งค่า `queue_name_prefix` แล้ว `queue_name_delimiter` จะรวมคำนำหน้าและชื่อคิวที่ไม่มีคำนำหน้าเข้าด้วยกัน
การกำหนดค่าต่อไปนี้จะเรียงคิวงานที่ให้ไว้ในคิว `video_server.low_priority`:

```ruby
# ต้องกำหนด prefix เพื่อให้ delimiter ถูกใช้งาน
config.active_job.queue_name_prefix = 'video_server'
config.active_job.queue_name_delimiter = '.'
```

```ruby
class EncoderJob < ActiveJob::Base
  queue_as :low_priority
  #....
end
```

#### `config.active_job.logger`

รับ logger ที่เป็นไปตามอินเตอร์เฟซของ Log4r หรือคลาส Logger ของ Ruby ที่ตั้งไว้เพื่อบันทึกข้อมูลจาก Active Job คุณสามารถเรียกใช้ logger นี้ได้โดยเรียกใช้ `logger` บนคลาส Active Job หรืออินสแตนซ์ Active Job ตั้งค่าเป็น `nil` เพื่อปิดการบันทึกข้อมูล

#### `config.active_job.custom_serializers`

อนุญาตให้ตั้งค่าตัวแปร custom argument serializers ค่าเริ่มต้นคือ `[]`

#### `config.active_job.log_arguments`

ควบคุมว่าจะบันทึกข้อมูลอาร์กิวเมนต์ของงานหรือไม่ ค่าเริ่มต้นคือ `true`

#### `config.active_job.verbose_enqueue_logs`

ระบุว่าควรบันทึกตำแหน่งแหล่งของเมธอดที่เรียกใช้งานงานพื้นหลังในบรรทัดบันทึกการเรียกใช้งานที่เกี่ยวข้องหรือไม่ โดยค่าเริ่มต้นคือ `true` ในโหมดการพัฒนาและ `false` ในสภาพแวดล้อมอื่น ๆ

#### `config.active_job.retry_jitter`

ควบคุมปริมาณ "jitter" (ค่าความแปรผันสุ่ม) ที่ใช้กับเวลาความล่าช้าที่คำนวณเมื่อลองทำงานใหม่ในงานที่ล้มเหลว

ค่าเริ่มต้นขึ้นอยู่กับเวอร์ชันเป้าหมายของ `config.load_defaults`:

| เริ่มต้นด้วยเวอร์ชัน | ค่าเริ่มต้นคือ |
| --------------------- | -------------------- |
| (เดิม)            | `0.0`                |
| 6.1                   | `0.15`               |
#### `config.active_job.log_query_tags_around_perform`

กำหนดว่าจะให้อัปเดตคำอธิบายงานสำหรับ query tags โดยอัตโนมัติผ่าน `around_perform` หรือไม่ ค่าเริ่มต้นคือ `true`.

#### `config.active_job.use_big_decimal_serializer`

เปิดใช้งานตัวแปรที่ใช้สำหรับอาร์กิวเมนต์ `BigDecimal` ที่ใหม่ ซึ่งรับรองการรอบเดียวกัน หากไม่มีตัวแปรที่ใช้สำหรับอาร์กิวเมนต์นี้ บางตัวแปรคิวอาร์ที่อาจจะทำการอักขระ `BigDecimal` เป็นสตริงที่ไม่รอบเดียวกัน

คำเตือน: เมื่อติดตั้งแอปพลิเคชันที่มีเรพลิกา (replica) หลายตัว รีพลิกาเก่า (ก่อน Rails 7.1) จะไม่สามารถทำการแปลงค่าอาร์กิวเมนต์ `BigDecimal` จากตัวแปรที่ใช้สำหรับอาร์กิวเมนต์นี้ได้ ดังนั้น ตัวเลือกนี้ควรเปิดใช้งานเมื่อรีพลิกาทั้งหมดได้รับการอัปเกรดเป็นรุ่น Rails 7.1 สำเร็จแล้ว

ค่าเริ่มต้นขึ้นอยู่กับเวอร์ชันเป้าหมายของ `config.load_defaults`:

| เริ่มต้นด้วยเวอร์ชัน | ค่าเริ่มต้นคือ |
| --------------------- | -------------------- |
| (เดิม)            | `false`              |
| 7.1                   | `true`               |

### การกำหนดค่า Action Cable

#### `config.action_cable.url`

รับค่าสตริงสำหรับ URL ของเซิร์ฟเวอร์ Action Cable ที่คุณกำลังโฮสต์ คุณสามารถใช้ตัวเลือกนี้หากคุณกำลังเรียกใช้เซิร์ฟเวอร์ Action Cable ที่แยกออกจากแอปพลิเคชันหลักของคุณ

#### `config.action_cable.mount_path`

รับค่าสตริงสำหรับตำแหน่งที่จะติดตั้ง Action Cable เป็นส่วนหนึ่งของกระบวนการเซิร์ฟเวอร์หลัก ค่าเริ่มต้นคือ `/cable` คุณสามารถตั้งค่าเป็น nil เพื่อไม่ติดตั้ง Action Cable เป็นส่วนหนึ่งของเซิร์ฟเวอร์ Rails ปกติของคุณ

คุณสามารถค้นหาตัวเลือกการกำหนดค่าที่ละเอียดมากขึ้นได้ใน
[ภาพรวมของ Action Cable](action_cable_overview.html#configuration).
#### `config.action_cable.precompile_assets`

กำหนดว่าควรเพิ่มทรัพยากร Action Cable เข้าสู่กระบวนการก่อนคอมไพล์ทรัพยากร ไม่มีผลกระทบถ้าไม่ใช้ Sprockets ค่าเริ่มต้นคือ `true`.

### การกำหนดค่า Active Storage

`config.active_storage` มีตัวเลือกการกำหนดค่าต่อไปนี้:

#### `config.active_storage.variant_processor`

รับค่าสัญลักษณ์ `:mini_magick` หรือ `:vips` ที่ระบุว่าจะใช้การแปลงแปลงและการวิเคราะห์ของตัวแปรหรือไม่ด้วย MiniMagick หรือ ruby-vips

ค่าเริ่มต้นขึ้นอยู่กับเวอร์ชันเป้าหมายของ `config.load_defaults`:

| เริ่มต้นเวอร์ชัน | ค่าเริ่มต้นคือ |
| --------------------- | -------------------- |
| (เวอร์ชันเดิม)            | `:mini_magick`       |
| 7.0                   | `:vips`              |

#### `config.active_storage.analyzers`

รับค่าอาร์เรย์ของคลาสที่ระบุว่ามีวิเคราะห์ที่ใช้ได้สำหรับ blob ใน Active Storage
โดยค่าเริ่มต้นนี้ถูกกำหนดเป็น:

```ruby
config.active_storage.analyzers = [ActiveStorage::Analyzer::ImageAnalyzer::Vips, ActiveStorage::Analyzer::ImageAnalyzer::ImageMagick, ActiveStorage::Analyzer::VideoAnalyzer, ActiveStorage::Analyzer::AudioAnalyzer]
```

วิเคราะห์ภาพสามารถสกัดความกว้างและความสูงของ blob ภาพได้; วิเคราะห์วิดีโอสามารถสกัดความกว้าง, ความสูง, ระยะเวลา, มุม, อัตราส่วนและการมี/ไม่มีช่องเสียงของ blob วิดีโอได้; วิเคราะห์เสียงสามารถสกัดระยะเวลาและอัตราการส่งข้อมูลของ blob เสียงได้.

#### `config.active_storage.previewers`

รับค่าอาร์เรย์ของคลาสที่ระบุว่ามีตัวแสดงตัวอย่างภาพที่ใช้ได้ใน blob ของ Active Storage
โดยค่าเริ่มต้นนี้ถูกกำหนดเป็น:

```ruby
config.active_storage.previewers = [ActiveStorage::Previewer::PopplerPDFPreviewer, ActiveStorage::Previewer::MuPDFPreviewer, ActiveStorage::Previewer::VideoPreviewer]
```

`PopplerPDFPreviewer` และ `MuPDFPreviewer` สามารถสร้างรูปย่อจากหน้าแรกของ blob PDF ได้; `VideoPreviewer` จากเฟรมที่เกี่ยวข้องของ blob วิดีโอ.
#### `config.active_storage.paths`

ยอมรับแฮชของตัวเลือกที่ระบุตำแหน่งของคำสั่งตัวอย่าง/ตัววิเคราะห์ ค่าเริ่มต้นคือ `{}` ซึ่งหมายความว่าคำสั่งจะถูกค้นหาในเส้นทางเริ่มต้น สามารถรวมตัวเลือกเหล่านี้ได้:

* `:ffprobe` - ตำแหน่งของตัวประมวลผล ffprobe
* `:mutool` - ตำแหน่งของตัวประมวลผล mutool
* `:ffmpeg` - ตำแหน่งของตัวประมวลผล ffmpeg

```ruby
config.active_storage.paths[:ffprobe] = '/usr/local/bin/ffprobe'
```

#### `config.active_storage.variable_content_types`

ยอมรับอาร์เรย์ของสตริงที่ระบุประเภทเนื้อหาที่ Active Storage สามารถแปลงผ่านตัวประมวลผลได้
โดยค่าเริ่มต้นนี้ถูกกำหนดเป็น:

```ruby
config.active_storage.variable_content_types = %w(image/png image/gif image/jpeg image/tiff image/bmp image/vnd.adobe.photoshop image/vnd.microsoft.icon image/webp image/avif image/heic image/heif)
```

#### `config.active_storage.web_image_content_types`

ยอมรับอาร์เรย์ของสตริงที่ถือว่าเป็นประเภทเนื้อหารูปภาพเว็บที่สามารถประมวลผลตัวแปรได้โดยไม่ต้องแปลงเป็นรูปแบบ PNG ทดแทน
หากคุณต้องการใช้ตัวแปร `WebP` หรือ `AVIF` ในแอปพลิเคชันของคุณ คุณสามารถเพิ่ม `image/webp` หรือ `image/avif` เข้าไปในอาร์เรย์นี้ได้
โดยค่าเริ่มต้นนี้ถูกกำหนดเป็น:

```ruby
config.active_storage.web_image_content_types = %w(image/png image/jpeg image/gif)
```

#### `config.active_storage.content_types_to_serve_as_binary`

ยอมรับอาร์เรย์ของสตริงที่ระบุประเภทเนื้อหาที่ Active Storage จะให้บริการเป็นไฟล์แนบเสมอ ไม่ใช่แบบอินไลน์
โดยค่าเริ่มต้นนี้ถูกกำหนดเป็น:

```ruby
config.active_storage.content_types_to_serve_as_binary = %w(text/html image/svg+xml application/postscript application/x-shockwave-flash text/xml application/xml application/xhtml+xml application/mathml+xml text/cache-manifest)
```
#### `config.active_storage.content_types_allowed_inline`

รับอาร์เรย์ของสตริงที่ระบุประเภทเนื้อหาที่ Active Storage อนุญาตให้ใช้งานในรูปแบบอินไลน์
โดยค่าเริ่มต้นจะถูกกำหนดเป็น:

```ruby
config.active_storage.content_types_allowed_inline` = %w(image/png image/gif image/jpeg image/tiff image/vnd.adobe.photoshop image/vnd.microsoft.icon application/pdf)
```

#### `config.active_storage.queues.analysis`

รับสัญลักษณ์ที่ระบุคิวงาน Active Job ที่จะใช้สำหรับงานการวิเคราะห์ หากตัวเลือกนี้เป็น `nil` งานการวิเคราะห์จะถูกส่งไปยังคิวงาน Active Job ที่เป็นค่าเริ่มต้น (ดู `config.active_job.default_queue_name`)

ค่าเริ่มต้นขึ้นอยู่กับเวอร์ชันเป้าหมายของ `config.load_defaults`:

| เริ่มต้นเวอร์ชัน | ค่าเริ่มต้นคือ |
| --------------------- | -------------------- |
| 6.0                   | `:active_storage_analysis` |
| 6.1                   | `nil`                |

#### `config.active_storage.queues.purge`

รับสัญลักษณ์ที่ระบุคิวงาน Active Job ที่จะใช้สำหรับงานการล้างข้อมูล หากตัวเลือกนี้เป็น `nil` งานการล้างข้อมูลจะถูกส่งไปยังคิวงาน Active Job ที่เป็นค่าเริ่มต้น (ดู `config.active_job.default_queue_name`)

ค่าเริ่มต้นขึ้นอยู่กับเวอร์ชันเป้าหมายของ `config.load_defaults`:

| เริ่มต้นเวอร์ชัน | ค่าเริ่มต้นคือ |
| --------------------- | -------------------- |
| 6.0                   | `:active_storage_purge` |
| 6.1                   | `nil`                |

#### `config.active_storage.queues.mirror`

รับสัญลักษณ์ที่ระบุคิวงาน Active Job ที่จะใช้สำหรับงานการสะท้อนอัปโหลดโดยตรง หากตัวเลือกนี้เป็น `nil` งานการสะท้อนจะถูกส่งไปยังคิวงาน Active Job ที่เป็นค่าเริ่มต้น (ดู `config.active_job.default_queue_name`) ค่าเริ่มต้นคือ `nil`
#### `config.active_storage.logger`

สามารถใช้เพื่อตั้งค่า logger ที่ใช้โดย Active Storage รับ logger ที่เป็นไปตามอินเตอร์เฟซของ Log4r หรือคลาส Ruby Logger เริ่มต้น

```ruby
config.active_storage.logger = ActiveSupport::Logger.new(STDOUT)
```

#### `config.active_storage.service_urls_expire_in`

กำหนดระยะเวลาหมดอายุเริ่มต้นของ URLs ที่สร้างขึ้นโดย:

* `ActiveStorage::Blob#url`
* `ActiveStorage::Blob#service_url_for_direct_upload`
* `ActiveStorage::Variant#url`

ค่าเริ่มต้นคือ 5 นาที

#### `config.active_storage.urls_expire_in`

กำหนดระยะเวลาหมดอายุเริ่มต้นของ URLs ในแอปพลิเคชัน Rails ที่สร้างขึ้นโดย Active Storage ค่าเริ่มต้นคือ nil

#### `config.active_storage.routes_prefix`

สามารถใช้เพื่อตั้งค่า prefix เส้นทางสำหรับเส้นทางที่ให้บริการโดย Active Storage รับสตริงที่จะถูกเติมไว้ก่อนเส้นทางที่สร้างขึ้น

```ruby
config.active_storage.routes_prefix = '/files'
```

ค่าเริ่มต้นคือ `/rails/active_storage`

#### `config.active_storage.track_variants`

กำหนดว่าจะบันทึก variants ในฐานข้อมูลหรือไม่

ค่าเริ่มต้นขึ้นอยู่กับเวอร์ชันเป้าหมายของ `config.load_defaults`:

| เริ่มต้นเวอร์ชัน | ค่าเริ่มต้นคือ |
| --------------------- | -------------------- |
| (เดิม)            | `false`              |
| 6.1                   | `true`               |

#### `config.active_storage.draw_routes`

สามารถใช้เพื่อเปิด/ปิดการสร้างเส้นทาง Active Storage ค่าเริ่มต้นคือ `true`

#### `config.active_storage.resolve_model_to_route`

สามารถใช้เพื่อเปลี่ยนวิธีการส่งไฟล์ Active Storage ในระดับทั่วโลก

ค่าที่อนุญาตคือ:

* `:rails_storage_redirect`: เปลี่ยนเส้นทางไปยัง signed, short-lived service URLs
* `:rails_storage_proxy`: โปรกซีไฟล์โดยดาวน์โหลดไฟล์
ค่าเริ่มต้นคือ `:rails_storage_redirect`.

#### `config.active_storage.video_preview_arguments`

สามารถใช้เพื่อเปลี่ยนวิธีการสร้างภาพตัวอย่างวิดีโอโดยใช้ ffmpeg

ค่าเริ่มต้นขึ้นอยู่กับเวอร์ชันเป้าหมายของ `config.load_defaults`:

| เริ่มต้นเวอร์ชัน | ค่าเริ่มต้นคือ |
| --------------------- | -------------------- |
| (เดิม)            | `"-y -vframes 1 -f image2"` |
| 7.0                   | `"-vf 'select=eq(n\\,0)+eq(key\\,1)+gt(scene\\,0.015)"`<sup><mark><strong><em>1</em></strong></mark></sup> <br> `+ ",loop=loop=-1:size=2,trim=start_frame=1'"`<sup><mark><strong><em>2</em></strong></mark></sup><br> `+ " -frames:v 1 -f image2"` <br><br> <ol><li>เลือกเฟรมวิดีโอแรก รวมถึงเฟรมที่เป็น keyframe และเฟรมที่ตรงกับค่าเกณฑ์การเปลี่ยนฉาก</li> <li>ใช้เฟรมวิดีโอแรกเป็นตัวเลือกสำรองเมื่อไม่มีเฟรมอื่นที่ตรงตามเกณฑ์โดยการวนซ้ำเฟรมแรก (หรือ) สองเฟรมที่เลือก จากนั้นลดเฟรมวิดีโอที่วนซ้ำครั้งแรก</li></ol> |

#### `config.active_storage.multiple_file_field_include_hidden`

ใน Rails 7.1 และต่อไป ความสัมพันธ์ `has_many_attached` ของ Active Storage จะเปลี่ยนค่าเริ่มต้นให้ _แทนที่_ คอลเลกชันปัจจุบันแทนที่จะ _เพิ่มเข้าไป_ ในกรณีที่ต้องการส่งคอลเลกชัน _ว่างเปล่า_ เมื่อ `multiple_file_field_include_hidden` เป็น `true` ตัวช่วย [`file_field`](https://api.rubyonrails.org/classes/ActionView/Helpers/FormBuilder.html#method-i-file_field) จะแสดงฟิลด์ที่ซ่อนอยู่เพิ่มเติม คล้ายกับฟิลด์ที่ซ่อนอยู่ที่แสดงโดยตัวช่วย [`check_box`](https://api.rubyonrails.org/classes/ActionView/Helpers/FormBuilder.html#method-i-check_box)

ค่าเริ่มต้นขึ้นอยู่กับเวอร์ชันเป้าหมายของ `config.load_defaults`:

| เริ่มต้นเวอร์ชัน | ค่าเริ่มต้นคือ |
| --------------------- | -------------------- |
| (เดิม)            | `false`              |
| 7.0                   | `true`               |

#### `config.active_storage.precompile_assets`
กำหนดว่า Active Storage assets ควรถูกเพิ่มในการคอมไพล์ของ asset pipeline หากไม่มีผลกระทบถ้าไม่ใช้ Sprockets ค่าเริ่มต้นคือ `true`.

### การกำหนดค่า Action Text

#### `config.action_text.attachment_tag_name`

รับค่าสตริงสำหรับแท็ก HTML ที่ใช้ครอบการแนบไฟล์ ค่าเริ่มต้นคือ `"action-text-attachment"`.

#### `config.action_text.sanitizer_vendor`

กำหนดค่า HTML sanitizer ที่ใช้โดย Action Text โดยกำหนด `ActionText::ContentHelper.sanitizer` เป็นอินสแตนซ์ของคลาสที่ได้จากเมธอด `.safe_list_sanitizer` ของเวนเดอร์ ค่าเริ่มต้นขึ้นอยู่กับเวอร์ชันเป้าหมายของ `config.load_defaults`:

| เริ่มต้นเวอร์ชัน | ค่าเริ่มต้นคือ                       | ที่แปลง markup เป็น |
|-----------------------|--------------------------------------|------------------------|
| (เดิม)               | `Rails::HTML4::Sanitizer`            | HTML4                  |
| 7.1                   | `Rails::HTML5::Sanitizer` (ดู NOTE)   | HTML5                  |

NOTE: `Rails::HTML5::Sanitizer` ไม่รองรับบน JRuby ดังนั้นในแพลตฟอร์ม JRuby Rails จะใช้ `Rails::HTML4::Sanitizer` เป็นค่าสำรอง.

### การกำหนดค่าฐานข้อมูล

เกือบทุกแอปพลิเคชัน Rails จะมีการใช้งานฐานข้อมูล คุณสามารถเชื่อมต่อกับฐานข้อมูลได้โดยกำหนดตัวแปรสภาพแวดล้อม `ENV['DATABASE_URL']` หรือโดยใช้ไฟล์กำหนดค่าที่ชื่อว่า `config/database.yml`.

โดยใช้ไฟล์ `config/database.yml` คุณสามารถระบุข้อมูลทั้งหมดที่จำเป็นในการเข้าถึงฐานข้อมูลของคุณได้:

```yaml
development:
  adapter: postgresql
  database: blog_development
  pool: 5
```

นี้จะเชื่อมต่อกับฐานข้อมูลที่ชื่อ `blog_development` โดยใช้ adapter `postgresql` ข้อมูลเดียวกันนี้สามารถเก็บไว้ใน URL และให้ผ่านตัวแปรสภาพแวดล้อมได้เช่นนี้:
```ruby
ENV['DATABASE_URL'] # => "postgresql://localhost/blog_development?pool=5"
```

ไฟล์ `config/database.yml` ประกอบด้วยส่วนสำหรับสามสภาวะแวดล้อมที่แตกต่างกันที่ Rails สามารถทำงานได้โดยค่าเริ่มต้น:

* สภาวะแวดล้อม `development` ใช้ในเครื่องคอมพิวเตอร์ของคุณในขณะที่คุณใช้งานแอปพลิเคชันเอง
* สภาวะแวดล้อม `test` ใช้เมื่อทำการทดสอบอัตโนมัติ
* สภาวะแวดล้อม `production` ใช้เมื่อคุณนำแอปพลิเคชันของคุณไปใช้งานในโลก

หากคุณต้องการ คุณสามารถระบุ URL เองภายใน `config/database.yml` ได้

```yaml
development:
  url: postgresql://localhost/blog_development?pool=5
```

ไฟล์ `config/database.yml` สามารถมีแท็ก ERB `<%= %>` ได้ สิ่งใดที่อยู่ในแท็กจะถูกประเมินเป็นรหัส Ruby คุณสามารถใช้สิ่งนี้เพื่อดึงข้อมูลจากตัวแปรสภาพแวดล้อมหรือทำการคำนวณเพื่อสร้างข้อมูลการเชื่อมต่อที่จำเป็น

เคล็ดลับ: คุณไม่จำเป็นต้องอัปเดตการกำหนดค่าฐานข้อมูลด้วยตนเอง หากคุณดูที่ตัวเลือกของเครื่องมือสร้างแอปพลิเคชัน คุณจะเห็นว่าหนึ่งในตัวเลือกชื่อ `--database` ช่วยให้คุณเลือกอแดปเตอร์จากรายการฐานข้อมูลสัมพันธ์ที่ใช้มากที่สุด คุณสามารถรันเครื่องมือสร้างซ้ำได้: `cd .. && rails new blog --database=mysql` เมื่อคุณยืนยันการเขียนทับไฟล์ `config/database.yml` แอปพลิเคชันของคุณจะถูกกำหนดค่าสำหรับ MySQL แทน SQLite ตัวอย่างรายละเอียดของการเชื่อมต่อฐานข้อมูลที่ใช้บ่อยอยู่ด้านล่าง
### การกำหนดค่าการเชื่อมต่อที่ต้องการ

เนื่องจากมีวิธีการกำหนดค่าการเชื่อมต่อสองวิธี (โดยใช้ `config/database.yml` หรือใช้ตัวแปรสภาพแวดล้อม) จึงเป็นสิ่งสำคัญที่จะเข้าใจว่าวิธีการเชื่อมต่อเหล่านี้สามารถมีปฏิสัมพันธ์กันได้อย่างไร

หากคุณมีไฟล์ `config/database.yml` ที่ว่างเปล่า แต่ `ENV['DATABASE_URL']` ของคุณมีการกำหนดค่า แล้ว Rails จะเชื่อมต่อกับฐานข้อมูลผ่านตัวแปรสภาพแวดล้อมของคุณ:

```bash
$ cat config/database.yml

$ echo $DATABASE_URL
postgresql://localhost/my_database
```

หากคุณมีไฟล์ `config/database.yml` แต่ไม่มี `ENV['DATABASE_URL']` แล้วไฟล์นี้จะถูกใช้เพื่อเชื่อมต่อกับฐานข้อมูลของคุณ:

```bash
$ cat config/database.yml
development:
  adapter: postgresql
  database: my_database
  host: localhost

$ echo $DATABASE_URL
```

หากคุณมีทั้ง `config/database.yml` และ `ENV['DATABASE_URL']` ที่กำหนดค่า แล้ว Rails จะรวมการกำหนดค่าเข้าด้วยกัน เพื่อเข้าใจดีขึ้นเราต้องเห็นตัวอย่างบางส่วน

เมื่อมีข้อมูลการเชื่อมต่อที่ซ้ำกัน ตัวแปรสภาพแวดล้อมจะมีความสำคัญกว่า:

```bash
$ cat config/database.yml
development:
  adapter: sqlite3
  database: NOT_my_database
  host: localhost

$ echo $DATABASE_URL
postgresql://localhost/my_database

$ bin/rails runner 'puts ActiveRecord::Base.configurations'
#<ActiveRecord::DatabaseConfigurations:0x00007fd50e209a28>

$ bin/rails runner 'puts ActiveRecord::Base.configurations.inspect'
#<ActiveRecord::DatabaseConfigurations:0x00007fc8eab02880 @configurations=[
  #<ActiveRecord::DatabaseConfigurations::UrlConfig:0x00007fc8eab020b0
    @env_name="development", @spec_name="primary",
    @config={"adapter"=>"postgresql", "database"=>"my_database", "host"=>"localhost"}
    @url="postgresql://localhost/my_database">
  ]
```

ที่นี่ adapter, host, และ database ตรงกับข้อมูลใน `ENV['DATABASE_URL']`.

หากมีข้อมูลที่ไม่ซ้ำกันคุณจะได้รับค่าที่ไม่ซ้ำกันทั้งหมด แต่ตัวแปรสภาพแวดล้อมยังคงมีความสำคัญในกรณีของข้อขัดแย้งใด ๆ

```bash
$ cat config/database.yml
development:
  adapter: sqlite3
  pool: 5

$ echo $DATABASE_URL
postgresql://localhost/my_database

$ bin/rails runner 'puts ActiveRecord::Base.configurations'
#<ActiveRecord::DatabaseConfigurations:0x00007fd50e209a28>

$ bin/rails runner 'puts ActiveRecord::Base.configurations.inspect'
#<ActiveRecord::DatabaseConfigurations:0x00007fc8eab02880 @configurations=[
  #<ActiveRecord::DatabaseConfigurations::UrlConfig:0x00007fc8eab020b0
    @env_name="development", @spec_name="primary",
    @config={"adapter"=>"postgresql", "database"=>"my_database", "host"=>"localhost", "pool"=>5}
    @url="postgresql://localhost/my_database">
  ]
```
เนื่องจาก pool ไม่ได้อยู่ใน `ENV['DATABASE_URL']` ข้อมูลการเชื่อมต่อที่ให้ไว้จะถูกผสานเข้าด้วยกัน โดยเนื่องจาก `adapter` ซ้ำกัน ข้อมูลการเชื่อมต่อใน `ENV['DATABASE_URL']` จะชนะ

วิธีเดียวที่จะไม่ใช้ข้อมูลการเชื่อมต่อใน `ENV['DATABASE_URL']` โดยชัดเจนคือการระบุการเชื่อมต่อ URL โดยใช้คีย์ย่อย `"url"`:

```bash
$ cat config/database.yml
development:
  url: sqlite3:NOT_my_database

$ echo $DATABASE_URL
postgresql://localhost/my_database

$ bin/rails runner 'puts ActiveRecord::Base.configurations'
#<ActiveRecord::DatabaseConfigurations:0x00007fd50e209a28>

$ bin/rails runner 'puts ActiveRecord::Base.configurations.inspect'
#<ActiveRecord::DatabaseConfigurations:0x00007fc8eab02880 @configurations=[
  #<ActiveRecord::DatabaseConfigurations::UrlConfig:0x00007fc8eab020b0
    @env_name="development", @spec_name="primary",
    @config={"adapter"=>"sqlite3", "database"=>"NOT_my_database"}
    @url="sqlite3:NOT_my_database">
  ]
```

ที่นี่ข้อมูลการเชื่อมต่อใน `ENV['DATABASE_URL']` ถูกละเว้นไป โปรดทราบถึง adapter และชื่อฐานข้อมูลที่แตกต่างกัน

เนื่องจากสามารถฝัง ERB ใน `config/database.yml` ได้ การแสดงผลชัดเจนที่สุดคือการแสดงให้เห็นว่าคุณกำลังใช้ `ENV['DATABASE_URL']` เพื่อเชื่อมต่อกับฐานข้อมูลของคุณ สิ่งนี้เป็นประโยชน์อย่างมากในการดำเนินการในระดับการผลิต เนื่องจากคุณไม่ควรเก็บความลับเช่นรหัสผ่านฐานข้อมูลลงในการควบคุมแหล่งที่เก็บข้อมูล (เช่น Git)

```bash
$ cat config/database.yml
production:
  url: <%= ENV['DATABASE_URL'] %>
```

ตอนนี้พฤติกรรมชัดเจนว่าเรากำลังใช้ข้อมูลการเชื่อมต่อใน `ENV['DATABASE_URL']` เท่านั้น

#### การกำหนดค่าฐานข้อมูล SQLite3

Rails มาพร้อมกับการสนับสนุนสำหรับ [SQLite3](http://www.sqlite.org) ซึ่งเป็นแอปพลิเคชันฐานข้อมูลแบบเบาๆ แบบไม่มีเซิร์ฟเวอร์ ในขณะที่สภาพแวดล้อมการใช้งานในระบบการผลิตที่ค่อนข้างยุ่งเหยิงอาจทำให้ SQLite ถูกเรียกใช้งานมากเกินไป แต่มันทำงานได้ดีสำหรับการพัฒนาและการทดสอบ Rails จะใช้ฐานข้อมูล SQLite เป็นค่าเริ่มต้นเมื่อสร้างโปรเจคใหม่ แต่คุณสามารถเปลี่ยนแปลงได้ตลอดเวลา
นี่คือส่วนของไฟล์กำหนดค่าเริ่มต้น (`config/database.yml`) ที่มีข้อมูลการเชื่อมต่อสำหรับสภาพแวดล้อมการพัฒนา:

```yaml
development:
  adapter: sqlite3
  database: storage/development.sqlite3
  pool: 5
  timeout: 5000
```

หมายเหตุ: Rails ใช้ฐานข้อมูล SQLite3 สำหรับการเก็บข้อมูลตามค่าเริ่มต้นเนื่องจากเป็นฐานข้อมูลที่ไม่ต้องกำหนดค่าและใช้งานได้ทันที นอกจากนี้ Rails ยังสนับสนุน MySQL (รวมถึง MariaDB) และ PostgreSQL "พร้อมใช้งาน" และมีปลั๊กอินสำหรับระบบฐานข้อมูลหลายระบบ หากคุณใช้ฐานข้อมูลในสภาพแวดล้อมการใช้งานจริง โดยส่วนใหญ่ Rails จะมีแอดเพเตอร์สำหรับฐานข้อมูลนั้น

#### การกำหนดค่าฐานข้อมูล MySQL หรือ MariaDB

หากคุณเลือกใช้ MySQL หรือ MariaDB แทนฐานข้อมูล SQLite3 ที่มาพร้อมกับ Rails ไฟล์ `config/database.yml` ของคุณจะมีความแตกต่างเล็กน้อย นี่คือส่วนของการพัฒนา:

```yaml
development:
  adapter: mysql2
  encoding: utf8mb4
  database: blog_development
  pool: 5
  username: root
  password:
  socket: /tmp/mysql.sock
```

หากฐานข้อมูลการพัฒนาของคุณมีผู้ใช้ root โดยไม่มีรหัสผ่าน การกำหนดค่านี้ควรทำงานได้สำหรับคุณ มิฉะนั้น ให้เปลี่ยนชื่อผู้ใช้และรหัสผ่านในส่วน `development` ตามที่เหมาะสม

หมายเหตุ: หากเวอร์ชัน MySQL ของคุณเป็น 5.5 หรือ 5.6 และต้องการใช้ชุดอักขระ `utf8mb4` เป็นค่าเริ่มต้น โปรดกำหนดค่าเซิร์ฟเวอร์ MySQL เพื่อรองรับความยาวของคำสั่งคีย์โดยเปิดใช้ตัวแปรระบบ `innodb_large_prefix`

การล็อคที่ปรึกษาถูกเปิดใช้งานโดยค่าเริ่มต้นบน MySQL และใช้ในการทำให้การเมืองฐานข้อมูลเป็นปลอดภัยได้พร้อมกัน คุณสามารถปิดการใช้งานล็อคที่ปรึกษาได้โดยตั้งค่า `advisory_locks` เป็น `false`
```yaml
development:
  adapter: jdbcmysql
  database: blog_development
  username: root
  password: password
  host: localhost
  port: 3306
```
```yaml
development:
  adapter: jdbcmysql
  database: blog_development
  username: root
  password:
```

#### การกำหนดค่าฐานข้อมูล PostgreSQL สำหรับแพลตฟอร์ม JRuby

หากคุณเลือกใช้ PostgreSQL และใช้ JRuby คุณจะต้องกำหนดค่า `config/database.yml` ให้ต่างจากเดิมเล็กน้อย ตามนี้คือส่วนของการพัฒนา:

```yaml
development:
  adapter: jdbcpostgresql
  encoding: unicode
  database: blog_development
  username: blog
  password:
```

เปลี่ยนชื่อผู้ใช้และรหัสผ่านในส่วน `development` ตามที่เหมาะสม

#### การกำหนดค่าการเก็บข้อมูลเมตาดาต้า

โดยค่าเริ่มต้น Rails จะเก็บข้อมูลเกี่ยวกับสภาพแวดล้อมของ Rails และ schema ในตารางภายในที่ชื่อว่า `ar_internal_metadata`

ในการปิดการใช้งานต่อการเชื่อมต่อ ให้ตั้งค่า `use_metadata_table` ในการกำหนดค่าฐานข้อมูลของคุณ ซึ่งเป็นประโยชน์เมื่อทำงานกับฐานข้อมูลที่ใช้ร่วมกันและ/หรือผู้ใช้ฐานข้อมูลที่ไม่สามารถสร้างตารางได้

```yaml
development:
  adapter: postgresql
  use_metadata_table: false
```

#### การกำหนดค่าการลองเชื่อมต่อใหม่

โดยค่าเริ่มต้น Rails จะเชื่อมต่อกับเซิร์ฟเวอร์ฐานข้อมูลอัตโนมัติและลองเชื่อมต่อใหม่สำหรับคำสั่งบางอย่างหากเกิดข้อผิดพลาด คำสั่งที่สามารถลองเชื่อมต่อใหม่ได้อย่างปลอดภัย (idempotent) เท่านั้นที่จะลองเชื่อมต่อใหม่ จำนวนครั้งในการลองเชื่อมต่อใหม่สามารถระบุได้ในการกำหนดค่าฐานข้อมูลของคุณผ่าน `connection_retries` หรือปิดใช้งานโดยกำหนดค่าเป็น 0 จำนวนครั้งในการลองเชื่อมต่อใหม่เริ่มต้นคือ 1

```yaml
development:
  adapter: mysql2
  connection_retries: 3
```

การกำหนดค่าฐานข้อมูลยังอนุญาตให้กำหนด `retry_deadline` ได้ หากกำหนด `retry_deadline` แล้ว คำสั่งที่เป็นไปได้ที่จะลองเชื่อมต่อใหม่จะไม่ลองเชื่อมต่อใหม่หากเวลาที่ระบุผ่านไปในขณะที่คำสั่งถูกลองเชื่อมต่อครั้งแรก ตัวอย่างเช่น `retry_deadline` ของ 5 วินาทีหมายความว่าหากผ่านไป 5 วินาทีตั้งแต่คำสั่งถูกลองเชื่อมต่อครั้งแรก เราจะไม่ลองเชื่อมต่อใหม่แม้ว่าคำสั่งนั้นจะเป็นไปได้ที่จะลองเชื่อมต่อใหม่และยังเหลือ `connection_retries` อยู่
ค่านี้ถูกตั้งค่าเริ่มต้นเป็น nil ซึ่งหมายความว่าการลองเชื่อมต่อซ้ำจะทำงานใหม่ไม่ว่าจะผ่านเวลากี่วินาที
ค่าสำหรับการตั้งค่านี้ควรระบุเป็นวินาที

```yaml
development:
  adapter: mysql2
  retry_deadline: 5 # หยุดลองเชื่อมต่อใหม่หลังจาก 5 วินาที
```

#### การกำหนดค่าแคชคำสั่ง

โดยค่าเริ่มต้น Rails จะแคชผลลัพธ์ที่ได้จากคำสั่งค้นหาอัตโนมัติ หาก Rails พบคำสั่งค้นหาเดียวกันอีกครั้งสำหรับคำขอหรืองานนั้น ๆ จะใช้ผลลัพธ์ที่แคชไว้แทนที่จะเรียกใช้คำสั่งค้นหาอีกครั้งกับฐานข้อมูล

แคชคำสั่งค้นหาจะถูกเก็บไว้ในหน่วยความจำ และเพื่อหลีกเลี่ยงการใช้หน่วยความจำมากเกินไป แคชจะลบคำสั่งค้นหาที่ไม่ได้ใช้บ่อยที่สุดเมื่อถึงเกณฑ์ที่กำหนด โดยค่าเริ่มต้นของเกณฑ์คือ `100` แต่สามารถกำหนดค่าได้ใน `database.yml`

```yaml
development:
  adapter: mysql2
  query_cache: 200
```

หากต้องการปิดใช้งานแคชคำสั่งค้นหาทั้งหมด สามารถตั้งค่าเป็น `false` ได้

```yaml
development:
  adapter: mysql2
  query_cache: false
```

### การสร้างสภาพแวดล้อมของ Rails

โดยค่าเริ่มต้น Rails มาพร้อมกับสามสภาพแวดล้อมคือ "development", "test", และ "production" ซึ่งเหมาะสมสำหรับส่วนใหญ่ของการใช้งาน แต่มีกรณีที่คุณต้องการสภาพแวดล้อมเพิ่มเติม

พิจารณาว่าคุณมีเซิร์ฟเวอร์ที่เหมือนกับสภาพแวดล้อมการผลิตแต่ใช้สำหรับการทดสอบเท่านั้น เซิร์ฟเวอร์แบบนี้เรียกว่า "staging server" หากต้องการกำหนดสภาพแวดล้อมที่ชื่อ "staging" สำหรับเซิร์ฟเวอร์นี้ เพียงแค่สร้างไฟล์ที่ชื่อ `config/environments/staging.rb` โดยเนื้อหาของไฟล์สามารถคัดลอกจากไฟล์ `config/environments/production.rb` เป็นจุดเริ่มต้นและทำการเปลี่ยนแปลงที่จำเป็นตามต้องการได้ ยังสามารถใช้คำสั่ง require และ extend การกำหนดค่าสภาพแวดล้อมอื่น ๆ ได้ดังนี้:
```ruby
# config/environments/staging.rb
require_relative "production"

Rails.application.configure do
  # การแทนที่สำหรับสภาพแวดล้อม Staging
end
```

สภาพแวดล้อมนี้ไม่แตกต่างจากสภาพแวดล้อมเริ่มต้น สามารถเริ่มเซิร์ฟเวอร์ด้วย `bin/rails server -e staging`, เรียกใช้คอนโซลด้วย `bin/rails console -e staging`, `Rails.env.staging?` ทำงานได้เช่นเดียวกัน

### การติดตั้งในโฟลเดอร์ย่อย (relative URL root)

โดยค่าเริ่มต้น Rails คาดหวังว่าแอปพลิเคชันของคุณจะทำงานที่ root (เช่น `/`) ส่วนนี้อธิบายวิธีการเรียกใช้แอปพลิเคชันของคุณในโฟลเดอร์ย่อย

สมมุติว่าเราต้องการติดตั้งแอปพลิเคชันของเราใน "/app1" Rails จำเป็นต้องรู้โฟลเดอร์นี้เพื่อสร้างเส้นทางที่เหมาะสม:

```ruby
config.relative_url_root = "/app1"
```

หรือคุณสามารถตั้งค่าตัวแปรสภาพแวดล้อม `RAILS_RELATIVE_URL_ROOT` ได้เช่นกัน

ตอนนี้ Rails จะเติม "/app1" ไว้ข้างหน้าเมื่อสร้างลิงก์

#### การใช้ Passenger

Passenger ทำให้ง่ายต่อการเรียกใช้แอปพลิเคชันของคุณในโฟลเดอร์ย่อย คุณสามารถค้นหาการตั้งค่าที่เกี่ยวข้องใน[คู่มือ Passenger](https://www.phusionpassenger.com/library/deploy/apache/deploy/ruby/#deploying-an-app-to-a-sub-uri-or-subdirectory)

#### การใช้ Reverse Proxy

การติดตั้งแอปพลิเคชันของคุณโดยใช้ Reverse Proxy มีข้อได้เปรียบแน่นอนเมื่อเปรียบเทียบกับการติดตั้งแบบดั้งเดิม การใช้ Reverse Proxy ช่วยให้คุณมีการควบคุมมากขึ้นต่อเซิร์ฟเวอร์ของคุณโดยการเรียงชั้นส่วนประกอบที่จำเป็นสำหรับแอปพลิเคชันของคุณ

เซิร์ฟเวอร์เว็บหลายรุ่นสามารถใช้เป็นเซิร์ฟเวอร์พร็อกซีเพื่อทดลองการใช้งานองค์ประกอบของบุคคลที่สามเช่นเซิร์ฟเวอร์แคชหรือเซิร์ฟเวอร์แอปพลิเคชัน

หนึ่งในเซิร์ฟเวอร์แอปพลิเคชันที่คุณสามารถใช้ได้คือ [Unicorn](https://bogomips.org/unicorn/) เพื่อเรียกใช้งานด้านหลังพร็อกซี
ในกรณีนี้คุณจะต้องกำหนดค่าเซิร์ฟเวอร์พร็อกซี (NGINX, Apache, เป็นต้น) เพื่อยอมรับการเชื่อมต่อจากเซิร์ฟเวอร์แอปพลิเคชันของคุณ (Unicorn) โดยค่าเริ่มต้น Unicorn จะฟังการเชื่อมต่อ TCP ที่พอร์ต 8080 แต่คุณสามารถเปลี่ยนพอร์ตหรือกำหนดค่าให้ใช้ socket แทนได้

คุณสามารถหาข้อมูลเพิ่มเติมได้ใน [Unicorn readme](https://bogomips.org/unicorn/README.html) และเข้าใจ [ปรัชญา](https://bogomips.org/unicorn/PHILOSOPHY.html) ที่อยู่เบื้องหลัง

เมื่อคุณกำหนดค่าเซิร์ฟเวอร์แอปพลิเคชันแล้ว คุณต้องส่งคำขอผ่านพร็อกซีไปยังเซิร์ฟเวอร์เว็บของคุณโดยกำหนดค่าให้ถูกต้อง ตัวอย่างเช่นการกำหนดค่า NGINX อาจประกอบด้วย:

```nginx
upstream application_server {
  server 0.0.0.0:8080;
}

server {
  listen 80;
  server_name localhost;

  root /root/path/to/your_app/public;

  try_files $uri/index.html $uri.html @app;

  location @app {
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header Host $http_host;
    proxy_redirect off;
    proxy_pass http://application_server;
  }

  # การกำหนดค่าอื่น ๆ
}
```

โปรดอ่านเอกสาร [NGINX documentation](https://nginx.org/en/docs/) เพื่อข้อมูลที่อัปเดตล่าสุด

การตั้งค่าสภาพแวดล้อมของ Rails
--------------------------

บางส่วนของ Rails ยังสามารถกำหนดค่าจากภายนอกได้โดยการให้ตัวแปรสภาพแวดล้อม ตัวแปรสภาพแวดล้อมต่อไปนี้ถูกรับรู้โดยส่วนต่าง ๆ ของ Rails:

* `ENV["RAILS_ENV"]` กำหนดสภาพแวดล้อมของ Rails (production, development, test, เป็นต้น) ที่ Rails จะทำงานภายใต้

* `ENV["RAILS_RELATIVE_URL_ROOT"]` ใช้โดยรหัสเส้นทางเพื่อรู้จัก URL เมื่อคุณ [นำแอปพลิเคชันของคุณไปใช้ในโฟลเดอร์ย่อย](configuring.html#deploy-to-a-subdirectory-relative-url-root)
* `ENV["RAILS_CACHE_ID"]` และ `ENV["RAILS_APP_VERSION"]` ถูกใช้ในการสร้างคีย์แคชที่ขยายขนาดในรหัสการแคชของ Rails นี้ช่วยให้คุณสามารถมีแคชหลายรายการที่แยกกันได้จากแอปพลิเคชันเดียวกัน


การใช้ไฟล์เริ่มต้น
-----------------------

หลังจากโหลดเฟรมเวิร์กและเจ็มในแอปพลิเคชันของคุณเสร็จ  Rails จะเริ่มโหลดไฟล์เริ่มต้น ไฟล์เริ่มต้นคือไฟล์ Ruby ใดๆ ที่เก็บอยู่ภายใต้ `config/initializers` ในแอปพลิเคชันของคุณ คุณสามารถใช้ไฟล์เริ่มต้นเพื่อเก็บการตั้งค่าที่ควรทำหลังจากโหลดเฟรมเวิร์กและเจ็มทั้งหมด เช่นตัวเลือกในการกำหนดค่าสำหรับส่วนเหล่านี้

ไฟล์ใน `config/initializers` (และในโฟลเดอร์ย่อยของ `config/initializers`) จะถูกเรียงลำดับและโหลดหนึ่งต่อหนึ่งเป็นส่วนหนึ่งของไฟล์เริ่มต้น `load_config_initializers`

หากไฟล์เริ่มต้นมีรหัสที่ขึ้นอยู่กับรหัสในไฟล์เริ่มต้นอื่น ๆ คุณสามารถรวมเข้าด้วยกันเป็นไฟล์เริ่มต้นเดียวแทน นี้จะทำให้ความขึ้นอยู่กับกันมากขึ้นและช่วยให้คุณเห็นแนวคิดใหม่ภายในแอปพลิเคชันของคุณ Rails ยังรองรับการตั้งค่าชื่อไฟล์เริ่มต้นแต่นี้อาจทำให้เกิดการเปลี่ยนชื่อไฟล์บ่อย ๆ การโหลดไฟล์เริ่มต้นโดยชื่อที่ระบุด้วย `require` ไม่แนะนำ เนื่องจากจะทำให้ไฟล์เริ่มต้นโหลดสองครั้ง

หมายเหตุ: ไม่มีการรับประกันว่าไฟล์เริ่มต้นของคุณจะทำงานหลังจากไฟล์เริ่มต้นของเจ็มทั้งหมด ดังนั้น โค้ดเริ่มต้นที่ขึ้นอยู่กับการเริ่มต้นของเจ็มที่กำหนดให้เข้าไปในบล็อก `config.after_initialize`
เหตุการณ์การเริ่มต้น
---------------------

Rails มีเหตุการณ์การเริ่มต้นทั้งหมด 5 เหตุการณ์ที่สามารถเชื่อมต่อได้ (รายการตามลำดับที่เรียกใช้):

* `before_configuration`: รันทันทีที่ค่าคงที่ของแอปพลิเคชันได้รับการสืบทอดจาก `Rails::Application` การเรียกใช้ `config` จะถูกประเมินก่อนที่จะเกิดเหตุการณ์นี้

* `before_initialize`: รันโดยตรงก่อนกระบวนการเริ่มต้นของแอปพลิเคชันเกิดขึ้นด้วยตัวกำหนด `:bootstrap_hook` ในตอนเริ่มต้นของกระบวนการเริ่มต้นของ Rails

* `to_prepare`: รันหลังจากที่ตัวกำหนดเริ่มต้นถูกเรียกใช้สำหรับ Railties ทั้งหมด (รวมถึงแอปพลิเคชันเอง) แต่ก่อนการโหลดแบบกระตุ้นและสร้างสแต็กของ middleware สำคัญกว่านั้น จะรันทุกครั้งที่โหลดโค้ดใหม่ในโหมด `development` แต่เพียงครั้งเดียว (ระหว่างการเริ่มต้น) ในโหมด `production` และ `test`

* `before_eager_load`: รันโดยตรงก่อนการโหลดแบบกระตุ้นเกิดขึ้นซึ่งเป็นพฤติกรรมเริ่มต้นสำหรับสภาพแวดล้อม `production` และไม่ใช่สำหรับสภาพแวดล้อม `development`

* `after_initialize`: รันโดยตรงหลังจากการเริ่มต้นของแอปพลิเคชันเสร็จสิ้นหลังจากที่ตัวกำหนดเริ่มต้นของแอปพลิเคชันใน `config/initializers` ถูกเรียกใช้

ในการกำหนดเหตุการณ์สำหรับเหตุการณ์เหล่านี้ ให้ใช้ไวยากรณ์บล็อกภายในคลาส `Rails::Application`, `Rails::Railtie` หรือ `Rails::Engine`:

```ruby
module YourApp
  class Application < Rails::Application
    config.before_initialize do
      # โค้ดเริ่มต้นที่นี่
    end
  end
end
```

หรือในกรณีอื่น ๆ คุณยังสามารถทำได้ผ่านวิธี `config` บนออบเจ็กต์ `Rails.application`:
```ruby
Rails.application.config.before_initialize do
  # รหัสเริ่มต้นทำงานจะอยู่ที่นี่
end
```

คำเตือน: บางส่วนของแอปพลิเคชันของคุณ เช่นการเชื่อมต่อเส้นทาง ยังไม่ได้ตั้งค่าในจุดที่บล็อก `after_initialize` ถูกเรียกใช้งาน

### `Rails::Railtie#initializer`

Rails มีตัวเริ่มต้นหลายตัวที่ทำงานเมื่อเริ่มต้นและถูกกำหนดโดยใช้เมธอด `initializer` จาก `Rails::Railtie` นี่คือตัวอย่างของตัวเริ่มต้น `set_helpers_path` จาก Action Controller:

```ruby
initializer "action_controller.set_helpers_path" do |app|
  ActionController::Helpers.helpers_path = app.helpers_paths
end
```

เมธอด `initializer` รับอาร์กิวเมนต์สามตัวโดยอาร์กิวเมนต์แรกคือชื่อสำหรับตัวเริ่มต้น และอาร์กิวเมนต์ที่สองคือแฮชตัวเลือก (ไม่แสดงที่นี่) และอาร์กิวเมนต์ที่สามคือบล็อก คีย์ `:before` ในแฮชตัวเลือกสามารถระบุได้เพื่อระบุตัวเริ่มต้นใหม่นี้ต้องทำงานก่อน และคีย์ `:after` จะระบุตัวเริ่มต้นที่จะให้ตัวเริ่มต้นนี้ทำงานหลังจากนั้น

ตัวเริ่มต้นที่กำหนดโดยใช้เมธอด `initializer` จะถูกเรียกใช้ตามลำดับที่กำหนดไว้ ยกเว้นตัวเริ่มต้นที่ใช้เมธอด `:before` หรือ `:after`

คำเตือน: คุณสามารถวางตัวเริ่มต้นของคุณก่อนหรือหลังตัวเริ่มต้นอื่นในลำดับได้ แต่จะต้องเป็นตามตรรกะ ถ้าคุณมีตัวเริ่มต้น 4 ตัวที่เรียกว่า "one" ถึง "four" (กำหนดตามลำดับนั้น) และคุณกำหนด "four" ให้ไป _ก่อน_ "two" แต่ _หลัง_ "three" นั่นไม่เป็นตรรกะและ Rails จะไม่สามารถกำหนดลำดับตัวเริ่มต้นของคุณได้
อาร์กิวเมนต์บล็อกของเมธอด `initializer` คือตัวอย่างของแอปพลิเคชันเอง ดังนั้นเราสามารถเข้าถึงการกำหนดค่าบนมันได้โดยใช้เมธอด `config` เหมือนที่ทำในตัวอย่าง

เนื่องจาก `Rails::Application` สืบทอดมาจาก `Rails::Railtie` (อ้อมค้อม) คุณสามารถใช้เมธอด `initializer` ใน `config/application.rb` เพื่อกำหนดตัวเริ่มต้นสำหรับแอปพลิเคชันได้

### เริ่มต้น

ด้านล่างนี้คือรายการเริ่มต้นทั้งหมดที่พบใน Rails ในลำดับที่กำหนด (และดำเนินการตามลำดับนั้น ยกเว้นกรณีอื่น)

* `load_environment_hook`: เป็นตัวยึดที่ให้ `:load_environment_config` สามารถกำหนดให้ทำงานก่อน

* `load_active_support`: ต้องการ `active_support/dependencies` ซึ่งกำหนดค่าพื้นฐานสำหรับ Active Support ต้องการ `active_support/all` ถ้า `config.active_support.bare` เป็นเท็จ ซึ่งเป็นค่าเริ่มต้น

* `initialize_logger`: เริ่มต้นตัวบันทึก (ออบเจ็กต์ `ActiveSupport::Logger`) สำหรับแอปพลิเคชันและทำให้สามารถเข้าถึงได้ที่ `Rails.logger` โดยเฉพาะอย่างยิ่งถ้าไม่มีตัวเริ่มต้นที่แทรกก่อนจุดนี้ได้กำหนด `Rails.logger`

* `initialize_cache`: หาก `Rails.cache` ยังไม่ได้กำหนดค่า จะเริ่มต้นแคชโดยอ้างอิงค่าใน `config.cache_store` และเก็บผลลัพธ์เป็น `Rails.cache` หากออบเจ็กต์นี้ตอบสนองกับเมธอด `middleware` จะแทรกมิดเวียร์ของมันก่อน `Rack::Runtime` ในสแต็กมิดเวียร์

* `set_clear_dependencies_hook`: เริ่มต้นนี้ - ซึ่งทำงานเฉพาะเมื่อ `config.enable_reloading` ถูกตั้งค่าเป็น `true` - ใช้ `ActionDispatch::Callbacks.after` เพื่อลบค่าคงที่ที่ได้ถูกอ้างอิงในระหว่างคำขอออกจาก object space เพื่อให้มันถูกโหลดใหม่ในคำขอถัดไป
* `bootstrap_hook`: รัน `before_initialize` blocks ที่กำหนดค่าทั้งหมด

* `i18n.callbacks`: ในสภาวะการพัฒนา ตั้งค่า `to_prepare` callback ซึ่งจะเรียกใช้ `I18n.reload!` หากมีการเปลี่ยนแปลงในภาษาที่ต่างกันตั้งแต่คำขอล่าสุด ในสภาวะการใช้งานจริง callback นี้จะทำงานเฉพาะคำขอแรกเท่านั้น

* `active_support.deprecation_behavior`: ตั้งค่าการรายงานการเลิกใช้งานสำหรับ [`Rails.application.deprecators`][] โดยใช้ [`config.active_support.report_deprecations`](#config-active-support-report-deprecations), [`config.active_support.deprecation`](#config-active-support-deprecation), [`config.active_support.disallowed_deprecation`](#config-active-support-disallowed-deprecation), และ [`config.active_support.disallowed_deprecation_warnings`](#config-active-support-disallowed-deprecation-warnings)

* `active_support.initialize_time_zone`: ตั้งค่าโซนเวลาเริ่มต้นสำหรับแอปพลิเคชัน โดยใช้การตั้งค่า `config.time_zone` ซึ่งมีค่าเริ่มต้นเป็น "UTC"

* `active_support.initialize_beginning_of_week`: ตั้งค่าวันเริ่มต้นของสัปดาห์เริ่มต้นสำหรับแอปพลิเคชัน โดยใช้การตั้งค่า `config.beginning_of_week` ซึ่งมีค่าเริ่มต้นเป็น `:monday`

* `active_support.set_configs`: ตั้งค่า Active Support โดยใช้การตั้งค่าใน `config.active_support` โดยใช้ `send` เป็น setters ให้กับ `ActiveSupport` และส่งค่าผ่าน

* `action_dispatch.configure`: กำหนดค่า `ActionDispatch::Http::URL.tld_length` ให้เป็นค่าของ `config.action_dispatch.tld_length`

* `action_view.set_configs`: ตั้งค่า Action View โดยใช้การตั้งค่าใน `config.action_view` โดยใช้ `send` เป็น setters ให้กับ `ActionView::Base` และส่งค่าผ่าน

* `action_controller.assets_config`: กำหนดค่า `config.action_controller.assets_dir` ให้เป็นไดเรกทอรีสาธารณะของแอปพลิเคชัน หากไม่ได้กำหนดค่าโดยชัดเจน

* `action_controller.set_helpers_path`: ตั้งค่า `helpers_path` ของ Action Controller เป็น `helpers_path` ของแอปพลิเคชัน

* `action_controller.parameters_config`: กำหนดค่าตัวเลือก strong parameters สำหรับ `ActionController::Parameters`

* `action_controller.set_configs`: ตั้งค่า Action Controller โดยใช้การตั้งค่าใน `config.action_controller` โดยใช้ `send` เป็น setters ให้กับ `ActionController::Base` และส่งค่าผ่าน
* `action_controller.compile_config_methods`: กำหนดค่าเริ่มต้นของเมธอดสำหรับการตั้งค่าที่ระบุเพื่อให้สามารถเข้าถึงได้เร็วขึ้น

* `active_record.initialize_timezone`: กำหนด `ActiveRecord::Base.time_zone_aware_attributes` เป็น `true` และกำหนด `ActiveRecord::Base.default_timezone` เป็น UTC  เมื่อมีการอ่านค่า attribute จากฐานข้อมูล จะถูกแปลงเป็นเขตเวลาที่ระบุโดย `Time.zone`

* `active_record.logger`: กำหนด `ActiveRecord::Base.logger` - หากยังไม่ได้กำหนด - เป็น `Rails.logger`

* `active_record.migration_error`: กำหนด middleware เพื่อตรวจสอบการมีการ migration ที่ยังไม่เสร็จสมบูรณ์

* `active_record.check_schema_cache_dump`: โหลด schema cache dump หากได้กำหนดค่าและมีให้ใช้งาน

* `active_record.warn_on_records_fetched_greater_than`: เปิดใช้งานการเตือนเมื่อคำสั่ง query คืนค่าจำนวน record มาก

* `active_record.set_configs`: กำหนดค่า Active Record โดยใช้การตั้งค่าใน `config.active_record` โดยใช้ `send` เป็นตัวส่งเมธอดเป็น setters ไปยัง `ActiveRecord::Base` และส่งค่าผ่าน

* `active_record.initialize_database`: โหลดการตั้งค่าฐานข้อมูล (โดยค่าเริ่มต้น) จาก `config/database.yml` และเชื่อมต่อกับฐานข้อมูลสำหรับ environment ปัจจุบัน

* `active_record.log_runtime`: รวม `ActiveRecord::Railties::ControllerRuntime` และ `ActiveRecord::Railties::JobRuntime` ซึ่งรับผิดชอบในการรายงานเวลาที่ใช้ในการเรียกใช้ Active Record สำหรับคำขอกลับไปยัง logger

* `active_record.set_reloader_hooks`: รีเซ็ตการเชื่อมต่อที่สามารถรีโหลดได้กับฐานข้อมูลทั้งหมดหาก `config.enable_reloading` ถูกตั้งค่าเป็น `true`

* `active_record.add_watchable_files`: เพิ่มไฟล์ `schema.rb` และ `structure.sql` เป็นไฟล์ที่สามารถตรวจสอบได้

* `active_job.logger`: กำหนด `ActiveJob::Base.logger` - หากยังไม่ได้กำหนด - เป็น `Rails.logger`

* `active_job.set_configs`: กำหนดค่า Active Job โดยใช้การตั้งค่าใน `config.active_job` โดยใช้ `send` เป็นตัวส่งเมธอดเป็น setters ไปยัง `ActiveJob::Base` และส่งค่าผ่าน
* `action_mailer.logger`: ตั้งค่า `ActionMailer::Base.logger` - หากยังไม่ได้ตั้งค่า - เป็น `Rails.logger`.

* `action_mailer.set_configs`: ตั้งค่า Action Mailer โดยใช้การตั้งค่าใน `config.action_mailer` โดยการส่งชื่อเมธอดเป็น setters ไปยัง `ActionMailer::Base` และส่งค่าผ่านไปด้วย

* `action_mailer.compile_config_methods`: เริ่มต้นเมธอดสำหรับการตั้งค่าที่ระบุเพื่อให้สามารถเข้าถึงได้เร็วขึ้น

* `set_load_path`: ตัวกำหนดค่านี้ทำงานก่อน `bootstrap_hook` เพิ่มเส้นทางที่ระบุโดย `config.load_paths` และเส้นทางการโหลดทั้งหมดไปยัง `$LOAD_PATH`.

* `set_autoload_paths`: ตัวกำหนดค่านี้ทำงานก่อน `bootstrap_hook` เพิ่มโฟลเดอร์ย่อยทั้งหมดของ `app` และเส้นทางที่ระบุโดย `config.autoload_paths`, `config.eager_load_paths` และ `config.autoload_once_paths` ไปยัง `ActiveSupport::Dependencies.autoload_paths`.

* `add_routing_paths`: โหลด (ตามค่าเริ่มต้น) ไฟล์ `config/routes.rb` ทั้งหมด (ในแอปพลิเคชันและ railties รวมถึง engines) และตั้งค่าเส้นทางสำหรับแอปพลิเคชัน

* `add_locales`: เพิ่มไฟล์ใน `config/locales` (จากแอปพลิเคชัน, railties และ engines) เข้าไปใน `I18n.load_path` เพื่อให้สามารถใช้การแปลในไฟล์เหล่านี้ได้

* `add_view_paths`: เพิ่มไดเรกทอรี `app/views` จากแอปพลิเคชัน, railties และ engines เข้าไปในเส้นทางการค้นหาไฟล์มุมมองสำหรับแอปพลิเคชัน

* `add_mailer_preview_paths`: เพิ่มไดเรกทอรี `test/mailers/previews` จากแอปพลิเคชัน, railties และ engines เข้าไปในเส้นทางการค้นหาไฟล์ตัวอย่างการส่งเมลสำหรับแอปพลิเคชัน

* `load_environment_config`: ตัวกำหนดค่านี้ทำงานก่อน `load_environment_hook` โหลดไฟล์ `config/environments` สำหรับสภาพแวดล้อมปัจจุบัน

* `prepend_helpers_path`: เพิ่มไดเรกทอรี `app/helpers` จากแอปพลิเคชัน, railties และ engines เข้าไปในเส้นทางการค้นหาช่วยเหลือสำหรับแอปพลิเคชัน
* `load_config_initializers`: โหลดไฟล์ Ruby ทั้งหมดจาก `config/initializers` ในแอปพลิเคชัน, railties, และ engines ไฟล์ในไดเรกทอรีนี้สามารถใช้เก็บการตั้งค่าที่ควรทำหลังจากโหลดเฟรมเวิร์กทั้งหมด

* `engines_blank_point`: ให้จุดในการเริ่มต้นเพื่อเชื่อมต่อหากคุณต้องการทำอะไรก่อนที่จะโหลด engines หลังจากจุดนี้จะเรียกใช้ railtie และ engine initializers ทั้งหมด

* `add_generator_templates`: ค้นหาเทมเพลตสำหรับ generators ที่ `lib/templates` สำหรับแอปพลิเคชัน, railties, และ engines และเพิ่มเข้าไปในการตั้งค่า `config.generators.templates` ซึ่งจะทำให้เทมเพลตสามารถอ้างอิงได้ทั้งหมด

* `ensure_autoload_once_paths_as_subset`: ตรวจสอบให้แน่ใจว่า `config.autoload_once_paths` เป็นเส้นทางที่มีอยู่ใน `config.autoload_paths` เท่านั้น หากมีเส้นทางเพิ่มเติม จะเกิดข้อยกเว้น

* `add_to_prepare_blocks`: บล็อกสำหรับทุก `config.to_prepare` ที่เรียกใช้ในแอปพลิเคชัน, railtie, หรือ engine จะถูกเพิ่มใน `to_prepare` callbacks สำหรับ Action Dispatch ซึ่งจะถูกเรียกใช้ต่อคำขอในการพัฒนา หรือก่อนคำขอแรกในการใช้งานจริง

* `add_builtin_route`: หากแอปพลิเคชันทำงานภายใต้สภาพแวดล้อมการพัฒนา จะเพิ่มเส้นทางสำหรับ `rails/info/properties` เข้าไปในเส้นทางของแอปพลิเคชัน เส้นทางนี้จะให้ข้อมูลที่เป็นรายละเอียดเช่นเวอร์ชัน Rails และ Ruby สำหรับ `public/index.html` ในแอปพลิเคชัน Rails เริ่มต้น

* `build_middleware_stack`: สร้างสแต็ก middleware สำหรับแอปพลิเคชันและคืนวัตถุที่มีเมธอด `call` ที่รับวัตถุแวดล้อม Rack สำหรับคำขอ
* `eager_load!`: หาก `config.eager_load` เป็น `true` จะเรียกใช้ `config.before_eager_load` hooks และเรียกใช้ `eager_load!` เพื่อโหลด `config.eager_load_namespaces` ทั้งหมด

* `finisher_hook`: ให้ hook หลังจากเสร็จสิ้นกระบวนการเริ่มต้นของแอปพลิเคชัน รวมถึงการเรียกใช้ `config.after_initialize` blocks สำหรับแอปพลิเคชัน, railties, และ engines ทั้งหมด

* `set_routes_reloader_hook`: กำหนด Action Dispatch ให้โหลด routes file ใหม่โดยใช้ `ActiveSupport::Callbacks.to_run`

* `disable_dependency_loading`: ปิดใช้งานการโหลด dependency อัตโนมัติหาก `config.eager_load` ถูกตั้งค่าเป็น `true`


การจัดการ Database Pooling
----------------

การเชื่อมต่อฐานข้อมูล Active Record จัดการโดย `ActiveRecord::ConnectionAdapters::ConnectionPool` ซึ่งจะให้การเชื่อมต่อฐานข้อมูลจำกัดจำนวนการเข้าถึงของเธรด จำกัดนี้มีค่าเริ่มต้นเป็น 5 และสามารถกำหนดค่าได้ใน `database.yml`.

```ruby
development:
  adapter: sqlite3
  database: storage/development.sqlite3
  pool: 5
  timeout: 5000
```

เนื่องจากการจัดการ connection pooling ถูกจัดการภายใน Active Record โดยค่าเริ่มต้น ทุกเซิร์ฟเวอร์แอปพลิเคชัน (Thin, Puma, Unicorn, เป็นต้น) ควรทำงานเหมือนกัน พูลการเชื่อมต่อฐานข้อมูลจะว่างเปล่าเริ่มต้น โดยเมื่อมีความต้องการเพิ่มขึ้นจะสร้างการเชื่อมต่อใหม่จนกระทั่งถึงขีดจำกัดของพูลการเชื่อมต่อ

คำขอแต่ละคำขอจะเช็คเอาต์การเชื่อมต่อครั้งแรกที่ต้องการเข้าถึงฐานข้อมูล ณ จุดสิ้นสุดของคำขอ จะเช็คเอาต์การเชื่อมต่อกลับเข้าสู่พูล นั่นหมายความว่าช่องเชื่อมต่อเพิ่มเติมจะพร้อมใช้งานอีกครั้งสำหรับคำขอถัดไปในคิว
หากคุณพยายามใช้การเชื่อมต่อมากกว่าที่มีอยู่ Active Record จะบล็อกคุณและรอการเชื่อมต่อจากพูล หากไม่สามารถเชื่อมต่อได้ จะเกิดข้อผิดพลาด timeout ที่คล้ายกับตัวอย่างด้านล่าง

```ruby
ActiveRecord::ConnectionTimeoutError - could not obtain a database connection within 5.000 seconds (waited 5.000 seconds)
```

หากคุณได้รับข้อผิดพลาดดังกล่าว คุณอาจต้องเพิ่มขนาดของพูลการเชื่อมต่อโดยเพิ่มตัวเลือก `pool` ใน `database.yml`

หมายเหตุ หากคุณกำลังทำงานในสภาวะแบบ multi-threaded อาจมีโอกาสที่หลาย thread อาจเข้าถึงการเชื่อมต่อหลายตัวพร้อมกัน ดังนั้นขึ้นอยู่กับโหลดคำขอปัจจุบันของคุณ คุณอาจมี thread หลายตัวที่แข่งขันกันสำหรับการเชื่อมต่อจำกัดจำนวน

การกำหนดค่าที่กำหนดเอง
--------------------

คุณสามารถกำหนดค่าโค้ดของคุณเองผ่านวัตถุการกำหนดค่า Rails ด้วยการกำหนดค่าที่กำหนดเองภายใต้เนมสเปซ `config.x` หรือ `config` โดยตรง ความแตกต่างสำคัญระหว่างสองนี้คือคุณควรใช้ `config.x` หากคุณกำลังกำหนดค่าที่ซ้อนกัน (เช่น `config.x.nested.hi`) และใช้เพียง `config` สำหรับการกำหนดค่าระดับเดียว (เช่น `config.hello`)

```ruby
config.x.payment_processing.schedule = :daily
config.x.payment_processing.retries  = 3
config.super_debugger = true
```

จากนั้นจะสามารถเข้าถึงจุดกำหนดค่าเหล่านี้ผ่านวัตถุการกำหนดค่าได้:

```ruby
Rails.configuration.x.payment_processing.schedule # => :daily
Rails.configuration.x.payment_processing.retries  # => 3
Rails.configuration.x.payment_processing.not_set  # => nil
Rails.configuration.super_debugger                # => true
```
คุณยังสามารถใช้ `Rails::Application.config_for` เพื่อโหลดไฟล์การกำหนดค่าทั้งหมด:

```yaml
# config/payment.yml
production:
  environment: production
  merchant_id: production_merchant_id
  public_key:  production_public_key
  private_key: production_private_key

development:
  environment: sandbox
  merchant_id: development_merchant_id
  public_key:  development_public_key
  private_key: development_private_key
```

```ruby
# config/application.rb
module MyApp
  class Application < Rails::Application
    config.payment = config_for(:payment)
  end
end
```

```ruby
Rails.configuration.payment['merchant_id'] # => production_merchant_id หรือ development_merchant_id
```

`Rails::Application.config_for` รองรับการกำหนดค่า `shared` เพื่อรวมกลุ่มการกำหนดค่าที่เป็นร่วมกัน การกำหนดค่าที่เป็นร่วมกันจะถูกผสานเข้ากับการกำหนดค่าของสภาพแวดล้อม

```yaml
# config/example.yml
shared:
  foo:
    bar:
      baz: 1

development:
  foo:
    bar:
      qux: 2
```

```ruby
# development environment
Rails.application.config_for(:example)[:foo][:bar] #=> { baz: 1, qux: 2 }
```

การดัชนีของเครื่องมือค้นหา
-----------------------

บางครั้งคุณอาจต้องการป้องกันหน้าบางหน้าของแอปพลิเคชันของคุณไม่ให้ปรากฏบนเว็บไซต์ค้นหาเช่น Google, Bing, Yahoo หรือ Duck Duck Go โรบอตที่ดัชนีเว็บไซต์เหล่านี้จะวิเคราะห์ไฟล์ `http://your-site.com/robots.txt` ก่อนที่จะรู้ว่ามีหน้าไหนที่อนุญาตให้ดัชนี

Rails สร้างไฟล์นี้ให้คุณภายในโฟลเดอร์ `/public` โดยค่าเริ่มต้นคืออนุญาตให้เครื่องมือค้นหาดัชนีหน้าทั้งหมดของแอปพลิเคชันของคุณ หากคุณต้องการบล็อกการดัชนีบนหน้าทั้งหมดของแอปพลิเคชันของคุณให้ใช้:

```
User-agent: *
Disallow: /
```

หากต้องการบล็อกเฉพาะหน้าบางหน้า จำเป็นต้องใช้ไวยากรณ์ที่ซับซ้อนมากขึ้น ศึกษาเพิ่มเติมได้ที่ [เอกสารอย่างเป็นทางการ](https://www.robotstxt.org/robotstxt.html)
ระบบตรวจสอบไฟล์แบบ Evented
---------------------------

หากโมดูล [listen gem](https://github.com/guard/listen) ถูกโหลดเข้ามา  Rails จะใช้ระบบตรวจสอบไฟล์แบบ evented เพื่อตรวจจับการเปลี่ยนแปลงเมื่อเปิดใช้งานการโหลดใหม่:

```ruby
group :development do
  gem 'listen', '~> 3.3'
end
```

หากไม่มีการโหลด gem นี้ ในทุกคำขอ Rails จะทำการตรวจสอบโครงสร้างแอปพลิเคชันเพื่อตรวจสอบว่ามีการเปลี่ยนแปลงหรือไม่

บนระบบปฏิบัติการ Linux และ macOS ไม่จำเป็นต้องโหลด gem เพิ่มเติม แต่บางระบบปฏิบัติการ *BSD และ Windows จำเป็นต้องโหลด gem เพิ่มเติม

โปรดทราบว่า [บางการตั้งค่าไม่รองรับ](https://github.com/guard/listen#issues--limitations)
[`config.load_defaults`]: https://api.rubyonrails.org/classes/Rails/Application/Configuration.html#method-i-load_defaults
[`ActiveSupport::ParameterFilter.precompile_filters`]: https://api.rubyonrails.org/classes/ActiveSupport/ParameterFilter.html#method-c-precompile_filters
[ActiveModel::Error#full_message]: https://api.rubyonrails.org/classes/ActiveModel/Error.html#method-i-full_message
[`ActiveSupport::MessageEncryptor`]: https://api.rubyonrails.org/classes/ActiveSupport/MessageEncryptor.html
[`ActiveSupport::MessageVerifier`]: https://api.rubyonrails.org/classes/ActiveSupport/MessageVerifier.html
[`message_serializer_fallback.active_support`]: active_support_instrumentation.html#message-serializer-fallback-active-support
[`Rails.application.deprecators`]: https://api.rubyonrails.org/classes/Rails/Application.html#method-i-deprecators
