**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: b95e1fead49349e056e5faed88aa5760
升級Ruby on Rails
=======================

本指南提供了升級應用程序到新版本Ruby on Rails時應遵循的步驟。這些步驟也可以在各個發行指南中找到。

--------------------------------------------------------------------------------

一般建議
--------------

在嘗試升級現有應用程序之前，您應該確定您有足夠的理由進行升級。您需要平衡幾個因素：對新功能的需求、尋找舊代碼支持的困難度增加、可用的時間和技能等等。

### 測試覆蓋率

確保在開始升級之前，您的應用程序仍然可以正常工作的最好方法是在開始過程之前進行良好的測試覆蓋。如果您沒有自動化測試來測試應用程序的大部分功能，您將需要花時間手動測試所有已更改的部分。在Rails升級的情況下，這將意味著應用程序中的每個功能都需要測試。在開始升級之前，請確保您的測試覆蓋率良好。

### Ruby版本

Rails通常在發布時與最新的Ruby版本保持接近：

* Rails 7 需要 Ruby 2.7.0 或更新版本。
* Rails 6 需要 Ruby 2.5.0 或更新版本。
* Rails 5 需要 Ruby 2.2.2 或更新版本。

升級Ruby和Rails是一個好主意。先升級到最新的Ruby，然後再升級Rails。

### 升級過程

在更改Rails版本時，最好慢慢移動，一次只升級一個次要版本，以充分利用棄用警告。Rails版本號的格式為Major.Minor.Patch。主要和次要版本可以對公共API進行更改，這可能會導致應用程序出錯。修補版本只包括錯誤修復，不會更改任何公共API。

該過程應該按照以下步驟進行：

1. 編寫測試並確保它們通過。
2. 在當前版本之後移動到最新的修補版本。
3. 修復測試和棄用功能。
4. 移動到下一個次要版本的最新修補版本。

重複此過程，直到達到目標Rails版本。

#### 在版本之間移動

要在版本之間移動：

1. 在`Gemfile`中更改Rails版本號並運行`bundle update`。
2. 在`package.json`中更改Rails JavaScript套件的版本並運行`yarn install`（如果使用Webpacker）。
3. 運行[更新任務](#the-update-task)。
4. 運行您的測試。

您可以在[這裡](https://rubygems.org/gems/rails/versions)找到所有已發布的Rails gem的列表。

### 更新任務

Rails提供了`rails app:update`命令。在`Gemfile`中更新Rails版本後，運行此命令。
這將在交互式會話中幫助您創建新文件並更改舊文件。

```bash
$ bin/rails app:update
       exist  config
    conflict  config/application.rb
Overwrite /myapp/config/application.rb? (enter "h" for help) [Ynaqdh]
       force  config/application.rb
      create  config/initializers/new_framework_defaults_7_0.rb
...
```

不要忘記檢查差異，看是否有任何意外更改。

### 配置框架默認值

新的Rails版本可能與先前版本有不同的配置默認值。但是，在按照上述步驟進行操作後，您的應用程序仍將運行使用*先前*Rails版本的配置默認值。這是因為`config/application.rb`中的`config.load_defaults`的值尚未更改。

為了讓您能夠逐步升級到新的默認值，更新任務已經創建了一個文件`config/initializers/new_framework_defaults_X.Y.rb`（文件名中包含所需的Rails版本）。您應該取消對文件中的新配置默認值的注釋，這可以在多個部署中逐步完成。一旦您的應用程序準備好使用新的默認值運行，您可以刪除此文件並切換`config.load_defaults`的值。

從Rails 7.0升級到Rails 7.1
-------------------------------------

有關Rails 7.1所做更改的更多信息，請參閱[發行說明](7_1_release_notes.html)。

### 自動加載的路徑不再在加載路徑中

從Rails 7.1開始，自動加載器管理的所有路徑將不再添加到`$LOAD_PATH`中。
這意味著無法使用手動的`require`調用加載它們，而是可以引用類或模塊。

減少`$LOAD_PATH`的大小可以加快不使用`bootsnap`的應用程序的`require`調用速度，並減少其他應用程序的`bootsnap`緩存的大小。
### `ActiveStorage::BaseController` 不再包含串流相關功能

繼承自 `ActiveStorage::BaseController` 的應用程式控制器，如果使用串流來實現自定義的檔案服務邏輯，現在必須明確地包含 `ActiveStorage::Streaming` 模組。

### `MemCacheStore` 和 `RedisCacheStore` 現在預設使用連接池

`connection_pool` gem 已經成為 `activesupport` gem 的相依套件，
`MemCacheStore` 和 `RedisCacheStore` 現在預設使用連接池。

如果不想使用連接池，可以在配置快取存儲時將 `:pool` 選項設為 `false`：

```ruby
config.cache_store = :mem_cache_store, "cache.example.com", pool: false
```

詳細資訊請參閱 [Rails 快取指南](https://guides.rubyonrails.org/v7.1/caching_with_rails.html#connection-pool-options)。

### `SQLite3Adapter` 現在預設以嚴格字串模式配置

使用嚴格字串模式會禁用雙引號字串文字。

SQLite 在處理雙引號字串文字時有一些怪異之處。
它首先嘗試將雙引號字串視為識別名稱，但如果識別名稱不存在，
則將其視為字串文字。因此，拼寫錯誤可能會悄悄地被忽略。
例如，可以為不存在的列創建索引。
詳細資訊請參閱 [SQLite 文件](https://www.sqlite.org/quirks.html#double_quoted_string_literals_are_accepted)。

如果不想在嚴格模式下使用 `SQLite3Adapter`，可以禁用此行為：

```ruby
# config/application.rb
config.active_record.sqlite3_adapter_strict_strings_by_default = false
```

### 支援 `ActionMailer::Preview` 的多個預覽路徑

`config.action_mailer.preview_path` 選項已被棄用，改用 `config.action_mailer.preview_paths`。將路徑附加到此配置選項將在搜尋郵件預覽時使用這些路徑。

```ruby
config.action_mailer.preview_paths << "#{Rails.root}/lib/mailer_previews"
```

### `config.i18n.raise_on_missing_translations = true` 現在在任何缺失翻譯時都會引發異常。

之前只有在視圖或控制器中調用時才會引發異常。現在，只要 `I18n.t` 提供了無法識別的鍵，就會引發異常。

```ruby
# with config.i18n.raise_on_missing_translations = true

# 在視圖或控制器中：
t("missing.key") # 在 7.0 中引發異常，在 7.1 中引發異常
I18n.t("missing.key") # 在 7.0 中未引發異常，在 7.1 中引發異常

# 在任何地方：
I18n.t("missing.key") # 在 7.0 中未引發異常，在 7.1 中引發異常
```

如果不想要這種行為，可以將 `config.i18n.raise_on_missing_translations` 設置為 `false`：

```ruby
# with config.i18n.raise_on_missing_translations = false

# 在視圖或控制器中：
t("missing.key") # 在 7.0 中未引發異常，在 7.1 中不引發異常
I18n.t("missing.key") # 在 7.0 中未引發異常，在 7.1 中不引發異常

# 在任何地方：
I18n.t("missing.key") # 在 7.0 中未引發異常，在 7.1 中不引發異常
```

或者，可以自定義 `I18n.exception_handler`。
詳細資訊請參閱 [i18n 指南](https://guides.rubyonrails.org/v7.1/i18n.html#using-different-exception-handlers)。

從 Rails 6.1 升級到 Rails 7.0
-------------------------------------

有關 Rails 7.0 的更多資訊，請參閱 [發行說明](7_0_release_notes.html)。

### `ActionView::Helpers::UrlHelper#button_to` 的行為已更改

從 Rails 7.0 開始，如果使用持久化的 Active Record 物件來建立按鈕的 URL，`button_to` 會渲染一個帶有 `patch` HTTP 動詞的 `form` 標籤。
如果要保持當前行為，請明確傳遞 `method:` 選項：

```diff
-button_to("Do a POST", [:my_custom_post_action_on_workshop, Workshop.find(1)])
+button_to("Do a POST", [:my_custom_post_action_on_workshop, Workshop.find(1)], method: :post)
```

或者使用輔助方法來建立 URL：

```diff
-button_to("Do a POST", [:my_custom_post_action_on_workshop, Workshop.find(1)])
+button_to("Do a POST", my_custom_post_action_on_workshop_workshop_path(Workshop.find(1)))
```

### Spring

如果應用程式使用 Spring，需要升級至至少 3.0.0 版本。否則會出現以下錯誤：

```
undefined method `mechanism=' for ActiveSupport::Dependencies:Module
```

此外，請確保在 `config/environments/test.rb` 中將 [`config.cache_classes`][] 設置為 `false`。

### Sprockets 現在是可選的相依套件

`rails` gem 不再依賴於 `sprockets-rails`。如果應用程式仍需要使用 Sprockets，
請確保將 `sprockets-rails` 添加到 Gemfile 中。

```ruby
gem "sprockets-rails"
```

### 應用程式需要在 `zeitwerk` 模式下運行

仍在使用 `classic` 模式運行的應用程式必須切換到 `zeitwerk` 模式。請查看 [從 Classic 切換到 Zeitwerk 的 HOWTO](https://guides.rubyonrails.org/v7.0/classic_to_zeitwerk_howto.html) 指南以獲取詳細資訊。

### 刪除了 `config.autoloader=` 設置器

在 Rails 7 中，沒有配置點來設置自動載入模式，已刪除 `config.autoloader=`。如果出於任何原因將其設置為 `:zeitwerk`，只需將其刪除即可。

### 刪除了 `ActiveSupport::Dependencies` 的私有 API

已刪除 `ActiveSupport::Dependencies` 的私有 API。這包括 `hook!`、`unhook!`、`depend_on`、`require_or_load`、`mechanism` 等方法。

以下是一些亮點：

* 如果使用了 `ActiveSupport::Dependencies.constantize` 或 `ActiveSupport::Dependencies.safe_constantize`，只需將它們更改為 `String#constantize` 或 `String#safe_constantize`。

  ```ruby
  ActiveSupport::Dependencies.constantize("User") # 無法再使用
  "User".constantize # 👍
  ```

* 任何使用 `ActiveSupport::Dependencies.mechanism` 的地方，讀取器或寫入器，都必須根據需要訪問 `config.cache_classes` 進行替換。

* 如果要追蹤自動載入器的活動，不再提供 `ActiveSupport::Dependencies.verbose=`，只需在 `config/application.rb` 中添加 `Rails.autoloaders.log!`。


輔助內部類別或模組也已經消失，例如`ActiveSupport::Dependencies::Reference`、`ActiveSupport::Dependencies::Blamable`等等。

### 初始化期間的自動載入

在初始化期間自動載入可重新載入的常數的應用程式，在`to_prepare`區塊之外，這些常數會被卸載並發出以下警告，自Rails 6.0開始：

```
DEPRECATION WARNING: Initialization autoloaded the constant ....

Being able to do this is deprecated. Autoloading during initialization is going
to be an error condition in future versions of Rails.

...
```

如果您仍然在日誌中看到此警告，請在[自動載入指南](https://guides.rubyonrails.org/v7.0/autoloading_and_reloading_constants.html#autoloading-when-the-application-boots)中檢查應用程式啟動時的自動載入部分。否則，在Rails 7中將會得到`NameError`。

### 可以配置`config.autoload_once_paths`

[`config.autoload_once_paths`][]可以在`config/application.rb`中定義的應用程式類別主體或在`config/environments/*`中的環境配置中設定。

同樣，引擎可以在引擎類別的類體或在環境配置中配置該集合。

之後，該集合將被凍結，並且您可以從這些路徑進行自動載入。特別是在初始化期間，它們由`Rails.autoloaders.once`自動載入器管理，該自動載入器不重新載入，只進行自動載入/急切載入。

如果您在環境配置已處理之後配置了此設置並且出現`FrozenError`，請將代碼移動。

### `ActionDispatch::Request#content_type`現在返回原樣的Content-Type標頭。

以前，`ActionDispatch::Request#content_type`返回的值不包含字符集部分。
這個行為已經改變，現在返回的Content-Type標頭包含原樣的字符集部分。

如果您只想要MIME類型，請改用`ActionDispatch::Request#media_type`。

之前：

```ruby
request = ActionDispatch::Request.new("CONTENT_TYPE" => "text/csv; header=present; charset=utf-16", "REQUEST_METHOD" => "GET")
request.content_type #=> "text/csv"
```

之後：

```ruby
request = ActionDispatch::Request.new("Content-Type" => "text/csv; header=present; charset=utf-16", "REQUEST_METHOD" => "GET")
request.content_type #=> "text/csv; header=present; charset=utf-16"
request.media_type   #=> "text/csv"
```

### 密鑰生成器摘要類別更改需要Cookie旋轉器

密鑰生成器的預設摘要類別從SHA1更改為SHA256。
這對於Rails生成的任何加密訊息（包括加密的Cookie）都有影響。

為了能夠使用舊的摘要類別讀取訊息，需要註冊一個旋轉器。如果未這樣做，升級期間可能會導致使用者的會話失效。

以下是用於加密和簽名Cookie的旋轉器示例。

```ruby
# config/initializers/cookie_rotator.rb
Rails.application.config.after_initialize do
  Rails.application.config.action_dispatch.cookies_rotations.tap do |cookies|
    authenticated_encrypted_cookie_salt = Rails.application.config.action_dispatch.authenticated_encrypted_cookie_salt
    signed_cookie_salt = Rails.application.config.action_dispatch.signed_cookie_salt

    secret_key_base = Rails.application.secret_key_base

    key_generator = ActiveSupport::KeyGenerator.new(
      secret_key_base, iterations: 1000, hash_digest_class: OpenSSL::Digest::SHA1
    )
    key_len = ActiveSupport::MessageEncryptor.key_len

    old_encrypted_secret = key_generator.generate_key(authenticated_encrypted_cookie_salt, key_len)
    old_signed_secret = key_generator.generate_key(signed_cookie_salt)

    cookies.rotate :encrypted, old_encrypted_secret
    cookies.rotate :signed, old_signed_secret
  end
end
```

### ActiveSupport::Digest的摘要類別更改為SHA256

ActiveSupport::Digest的預設摘要類別從SHA1更改為SHA256。
這對於Etag等事物的變更和快取鍵也有影響。
更改這些鍵可能會對快取命中率產生影響，因此在升級到新的哈希時要小心並注意這一點。

### 新的ActiveSupport::Cache序列化格式

引入了一種更快、更緊湊的序列化格式。

要啟用它，必須設置`config.active_support.cache_format_version = 7.0`：

```ruby
# config/application.rb

config.load_defaults 6.1
config.active_support.cache_format_version = 7.0
```

或者簡單地：

```ruby
# config/application.rb

config.load_defaults 7.0
```

但是，Rails 6.1應用程式無法讀取這種新的序列化格式，
因此為了確保無縫升級，您必須首先使用`config.active_support.cache_format_version = 6.1`部署您的Rails 7.0升級，
然後只有在所有Rails進程都已更新後，您才能設置`config.active_support.cache_format_version = 7.0`。

Rails 7.0能夠讀取兩種格式，因此在升級期間快取不會失效。

### Active Storage視頻預覽圖像生成

視頻預覽圖像生成現在使用FFmpeg的場景變更檢測來生成更有意義的預覽圖像。以前會使用視頻的第一幀，如果視頻從黑色淡入，這會引起問題。此更改需要FFmpeg v3.4+。

### Active Storage默認的變體處理器更改為`:vips`

對於新的應用程式，圖像轉換將使用libvips而不是ImageMagick。這將減少生成變體所需的時間，並減少CPU和內存使用量，從而改善依賴Active Storage提供圖像的應用程式的響應時間。

`:mini_magick`選項不會被棄用，因此繼續使用它是可以的。

要將現有應用程式遷移到libvips，請設置：
```ruby
Rails.application.config.active_storage.variant_processor = :vips
```

然後，您需要將現有的圖像轉換代碼更改為`image_processing`宏，並使用libvips的選項替換ImageMagick的選項。

#### 使用resize_to_limit替換resize

```diff
- variant(resize: "100x")
+ variant(resize_to_limit: [100, nil])
```

如果不這樣做，當您切換到vips時，您將看到此錯誤：`no implicit conversion to float from string`。

#### 在裁剪時使用數組

```diff
- variant(crop: "1920x1080+0+0")
+ variant(crop: [0, 0, 1920, 1080])
```

如果在遷移到vips時不這樣做，您將看到以下錯誤：`unable to call crop: you supplied 2 arguments, but operation needs 5`。

#### 修正裁剪值：

Vips在裁剪方面比ImageMagick更嚴格：

1. 如果`x`和/或`y`是負值，它將不進行裁剪。例如：`[-10, -10, 100, 100]`
2. 如果位置（`x`或`y`）加上裁剪尺寸（`width`，`height`）大於圖像，它將不進行裁剪。例如：一個125x125的圖像和一個裁剪區域為`[50, 50, 100, 100]`

如果在遷移到vips時不這樣做，您將看到以下錯誤：`extract_area: bad extract area`。

#### 調整`resize_and_pad`使用的背景顏色

Vips將黑色作為`resize_and_pad`的默認背景顏色，而不是像ImageMagick一樣使用白色。通過使用`background`選項來修正：

```diff
- variant(resize_and_pad: [300, 300])
+ variant(resize_and_pad: [300, 300, background: [255]])
```

#### 刪除基於EXIF的旋轉

Vips在處理變體時會使用EXIF值自動旋轉圖像。如果您以前使用ImageMagick存儲用戶上傳照片的旋轉值以應用旋轉，則必須停止這樣做：

```diff
- variant(format: :jpg, rotate: rotation_value)
+ variant(format: :jpg)
```

#### 使用colourspace替換monochrome

Vips使用不同的選項來生成單色圖像：

```diff
- variant(monochrome: true)
+ variant(colourspace: "b-w")
```

#### 切換到libvips選項以壓縮圖像

JPEG

```diff
- variant(strip: true, quality: 80, interlace: "JPEG", sampling_factor: "4:2:0", colorspace: "sRGB")
+ variant(saver: { strip: true, quality: 80, interlace: true })
```

PNG

```diff
- variant(strip: true, quality: 75)
+ variant(saver: { strip: true, compression: 9 })
```

WEBP

```diff
- variant(strip: true, quality: 75, define: { webp: { lossless: false, alpha_quality: 85, thread_level: 1 } })
+ variant(saver: { strip: true, quality: 75, lossless: false, alpha_q: 85, reduction_effort: 6, smart_subsample: true })
```

GIF

```diff
- variant(layers: "Optimize")
+ variant(saver: { optimize_gif_frames: true, optimize_gif_transparency: true })
```

#### 部署到生產環境

Active Storage將需要執行的轉換列表編碼到圖像的URL中。如果您的應用程序緩存這些URL，則在部署新代碼到生產環境後，您的圖像將中斷。因此，您必須手動使受影響的緩存鍵失效。

例如，如果在視圖中有以下代碼：

```erb
<% @products.each do |product| %>
  <% cache product do %>
    <%= image_tag product.cover_photo.variant(resize: "200x") %>
  <% end %>
<% end %>
```

您可以通過觸發產品或更改緩存鍵來使緩存失效：

```erb
<% @products.each do |product| %>
  <% cache ["v2", product] do %>
    <%= image_tag product.cover_photo.variant(resize_to_limit: [200, nil]) %>
  <% end %>
<% end %>
```

### 現在在Active Record模式轉儲中包含Rails版本

Rails 7.0更改了某些列類型的默認值。為了避免從6.1升級到7.0的應用程序使用新的7.0默認值加載當前模式，Rails現在在模式轉儲中包含框架的版本。

在首次在Rails 7.0中加載模式之前，請確保運行`rails app:update`以確保模式的版本包含在模式轉儲中。

模式文件將如下所示：

```ruby
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[6.1].define(version: 2022_01_28_123512) do
```
注意：在Rails 7.0中首次導出模式時，您將看到該文件的許多更改，包括一些列信息。請確保審查新的模式文件內容並將其提交到您的存儲庫中。

從Rails 6.0升級到Rails 6.1
-------------------------------------

有關Rails 6.1所做的更改的更多信息，請參閱[發行說明](6_1_release_notes.html)。

### `Rails.application.config_for`返回值不再支持使用字符串鍵訪問。

給定以下配置文件：

```yaml
# config/example.yml
development:
  options:
    key: value
```

```ruby
Rails.application.config_for(:example).options
```

以前這將返回一個哈希，您可以使用字符串鍵訪問值。這在6.0中已被棄用，現在不再起作用。

如果您仍然希望使用字符串鍵訪問值，您可以在`config_for`的返回值上調用`with_indifferent_access`，例如：

```ruby
Rails.application.config_for(:example).with_indifferent_access.dig('options', 'key')
```

### 使用`respond_to#any`時的響應Content-Type

響應中返回的Content-Type標頭可能與Rails 6.0返回的不同，特別是如果您的應用程序使用`respond_to { |format| format.any }`。現在，Content-Type將基於給定的塊而不是請求的格式。

示例：

```ruby
def my_action
  respond_to do |format|
    format.any { render(json: { foo: 'bar' }) }
  end
end
```

```ruby
get('my_action.csv')
```

以前的行為是返回一個`text/csv`的Content-Type，這是不準確的，因為正在渲染一個JSON響應。當前的行為正確返回一個`application/json`的Content-Type。

如果您的應用程序依賴於先前的不正確行為，建議您指定您的操作接受的格式，例如：

```ruby
format.any(:xml, :json) { render request.format.to_sym => @people }
```

### `ActiveSupport::Callbacks#halted_callback_hook`現在接收第二個參數

Active Support允許您在回調停止鏈時覆蓋`halted_callback_hook`。這個方法現在接收第二個參數，即被停止的回調的名稱。如果您的類覆蓋了這個方法，請確保它接受兩個參數。請注意，這是一個沒有先前棄用周期的破壞性更改（出於性能原因）。

示例：

```ruby
class Book < ApplicationRecord
  before_save { throw(:abort) }
  before_create { throw(:abort) }

  def halted_callback_hook(filter, callback_name) # => 這個方法現在接受2個參數而不是1個
    Rails.logger.info("無法#{callback_name}書籍")
  end
end
```

### 控制器中的`helper`類方法使用`String#constantize`

在Rails 6.1之前，概念上：

```ruby
helper "foo/bar"
```

將導致：

```ruby
require_dependency "foo/bar_helper"
module_name = "foo/bar_helper".camelize
module_name.constantize
```

現在它改為：

```ruby
prefix = "foo/bar".camelize
"#{prefix}Helper".constantize
```

對於大多數應用程序來說，這個更改是向後兼容的，您不需要做任何事情。

但從技術上講，控制器可以配置`helpers_path`指向`$LOAD_PATH`中不在自動加載路徑中的目錄。這種用法不再被直接支持。如果helper模塊無法自動加載，應用程序需要在調用`helper`之前加載它。

### 從HTTP重定向到HTTPS現在使用308 HTTP狀態碼

在從HTTP重定向非GET/HEAD請求到HTTPS時，`ActionDispatch::SSL`使用的默認HTTP狀態碼已更改為`308`，如https://tools.ietf.org/html/rfc7538所定義。

### Active Storage現在需要Image Processing

在Active Storage中處理變體時，現在需要捆綁[image_processing gem](https://github.com/janko/image_processing)而不是直接使用`mini_magick`。 Image Processing默認配置為在幕後使用`mini_magick`，因此升級的最簡單方法是將`mini_magick` gem替換為`image_processing` gem，並確保刪除對`combine_options`的显式使用，因為它不再需要。

為了可讀性，您可能希望將原始的`resize`調用更改為`image_processing`宏。例如，代替：

```ruby
video.preview(resize: "100x100")
video.preview(resize: "100x100>")
video.preview(resize: "100x100^")
```

您可以分別這樣做：

```ruby
video.preview(resize_to_fit: [100, 100])
video.preview(resize_to_limit: [100, 100])
video.preview(resize_to_fill: [100, 100])
```

### 新的`ActiveModel::Error`類

錯誤現在是新的`ActiveModel::Error`類的實例，API有所更改。根據您如何操作錯誤，這些更改中的一些可能會引發錯誤，而其他更改則會打印棄用警告以便在Rails 7.0中修復。

有關此更改的更多信息以及有關API更改的詳細信息，請參閱[此PR](https://github.com/rails/rails/pull/32313)。

從Rails 5.2升級到Rails 6.0
-------------------------------------

有關Rails 6.0所做的更改的更多信息，請參閱[發行說明](6_0_release_notes.html)。

### 使用Webpacker
[Webpacker](https://github.com/rails/webpacker) 是 Rails 6 的預設 JavaScript 編譯器。但如果你正在升級應用程式，它不會被預設啟用。如果你想使用 Webpacker，請在 Gemfile 中加入它並安裝：

```ruby
gem "webpacker"
```

```bash
$ bin/rails webpacker:install
```

### 強制使用 SSL

在 Rails 6.1 中，控制器上的 `force_ssl` 方法已被棄用並將被移除。建議你啟用 [`config.force_ssl`][] 來強制使用 HTTPS 連線。如果你需要免除某些端點的重新導向，你可以使用 [`config.ssl_options`][] 來配置這個行為。

### 目的和到期元數據現在嵌入在簽名和加密的 Cookie 中以增加安全性

為了提高安全性，Rails 將目的和到期元數據嵌入在加密或簽名的 Cookie 值中。

這樣可以防止攻擊者複製 Cookie 的簽名/加密值並將其用作另一個 Cookie 的值。

這些新的嵌入元數據使這些 Cookie 不兼容舊於 6.0 版本的 Rails。

如果你需要讓你的 Cookie 被 Rails 5.2 及更早版本讀取，或者你仍在驗證你的 6.0 部署並希望能夠回滾，請將 `Rails.application.config.action_dispatch.use_cookies_with_metadata` 設置為 `false`。

### 所有 npm 套件已移至 `@rails` 範疇

如果你之前通過 npm/yarn 載入了 `actioncable`、`activestorage` 或 `rails-ujs` 套件，你必須在升級到 `6.0.0` 之前更新這些依賴的名稱：

```
actioncable   → @rails/actioncable
activestorage → @rails/activestorage
rails-ujs     → @rails/ujs
```

### Action Cable JavaScript API 變更

Action Cable JavaScript 套件已從 CoffeeScript 轉換為 ES2015，我們現在在 npm 分發中發布源代碼。

此版本對 Action Cable JavaScript API 的可選部分進行了一些破壞性變更：

- WebSocket 適配器和日誌適配器的配置已從 `ActionCable` 的屬性移至 `ActionCable.adapters` 的屬性。如果你正在配置這些適配器，你需要進行以下更改：

    ```diff
    -    ActionCable.WebSocket = MyWebSocket
    +    ActionCable.adapters.WebSocket = MyWebSocket
    ```

    ```diff
    -    ActionCable.logger = myLogger
    +    ActionCable.adapters.logger = myLogger
    ```

- `ActionCable.startDebugging()` 和 `ActionCable.stopDebugging()` 方法已被移除，並改為使用 `ActionCable.logger.enabled` 屬性。如果你正在使用這些方法，你需要進行以下更改：

    ```diff
    -    ActionCable.startDebugging()
    +    ActionCable.logger.enabled = true
    ```

    ```diff
    -    ActionCable.stopDebugging()
    +    ActionCable.logger.enabled = false
    ```

### `ActionDispatch::Response#content_type` 現在返回未修改的 Content-Type 標頭

以前，`ActionDispatch::Response#content_type` 的返回值不包含字符集部分。這個行為已更改，現在包含之前省略的字符集部分。

如果你只想要 MIME 類型，請改用 `ActionDispatch::Response#media_type`。

之前：

```ruby
resp = ActionDispatch::Response.new(200, "Content-Type" => "text/csv; header=present; charset=utf-16")
resp.content_type #=> "text/csv; header=present"
```

之後：

```ruby
resp = ActionDispatch::Response.new(200, "Content-Type" => "text/csv; header=present; charset=utf-16")
resp.content_type #=> "text/csv; header=present; charset=utf-16"
resp.media_type   #=> "text/csv"
```

### 新的 `config.hosts` 設置

Rails 現在有一個新的 `config.hosts` 設置，用於安全目的。這個設置在開發中預設為 `localhost`。如果你在開發中使用其他域名，你需要像這樣允許它們：

```ruby
# config/environments/development.rb

config.hosts << 'dev.myapp.com'
config.hosts << /[a-z0-9-]+\.myapp\.com/ # 可選，也可以使用正則表達式
```

對於其他環境，`config.hosts` 預設為空，這意味著 Rails 不會驗證主機。如果你想在生產環境中驗證它，你可以選擇添加它們。

### 自動加載

Rails 6 的預設配置

```ruby
# config/application.rb

config.load_defaults 6.0
```

在 CRuby 上啟用了 `zeitwerk` 自動加載模式。在這種模式下，自動加載、重新加載和急切加載由 [Zeitwerk](https://github.com/fxn/zeitwerk) 管理。

如果你使用的是之前版本的 Rails 的預設值，你可以這樣啟用 zeitwerk：

```ruby
# config/application.rb

config.autoloader = :zeitwerk
```

#### 公共 API

一般情況下，應用程式不需要直接使用 Zeitwerk 的 API。Rails 根據現有的契約設置事物：`config.autoload_paths`、`config.cache_classes` 等等。

雖然應用程式應該遵守該界面，但實際的 Zeitwerk 加載器對象可以通過以下方式訪問：

```ruby
Rails.autoloaders.main
```

如果你需要預加載單表繼承（STI）類或配置自定義的 inflector，這可能很方便。

#### 專案結構

如果正在升級的應用程式已正確自動加載，項目結構應該已經基本兼容。

然而，`classic` 模式從缺少的常量名（`underscore`）推斷文件名，而 `zeitwerk` 模式從文件名推斷常量名（`camelize`）。這些輔助方法並不總是互為反函數，特別是如果涉及首字母縮略詞。例如，`"FOO".underscore` 是 `"foo"`，但 `"foo".camelize` 是 `"Foo"`，而不是 `"FOO"`。
可以使用`zeitwerk:check`任務來檢查相容性：

```bash
$ bin/rails zeitwerk:check
請稍等，我正在加載應用程序。
一切正常！
```

#### require_dependency

已經消除了所有已知使用`require_dependency`的情況，您應該使用grep命令在項目中查找並刪除它們。

如果您的應用程序使用單表繼承，請參閱自動加載和重新加載常量（Zeitwerk模式）指南中的[單表繼承部分](autoloading_and_reloading_constants.html#single-table-inheritance)。

#### 類和模塊定義中的限定名

現在您可以在類和模塊定義中穩健地使用常量路徑：

```ruby
# 現在這個類的主體中的自動加載與Ruby語義相符。
class Admin::UsersController < ApplicationController
  # ...
end
```

需要注意的是，根據執行順序的不同，傳統的自動加載器有時可以自動加載`Foo::Wadus`，例如：

```ruby
class Foo::Bar
  Wadus
end
```

這不符合Ruby語義，因為`Foo`不在嵌套中，並且在`zeitwerk`模式下根本不起作用。如果遇到這種情況，您可以使用限定名`Foo::Wadus`：

```ruby
class Foo::Bar
  Foo::Wadus
end
```

或者將`Foo`添加到嵌套中：

```ruby
module Foo
  class Bar
    Wadus
  end
end
```

#### Concerns

您可以從標準結構中自動加載和急切加載，例如：

```
app/models
app/models/concerns
```

在這種情況下，假設`app/models/concerns`是根目錄（因為它屬於自動加載路徑），並且被忽略為命名空間。因此，`app/models/concerns/foo.rb`應該定義`Foo`，而不是`Concerns::Foo`。

`Concerns::`命名空間在傳統的自動加載器中作為實現的副作用而存在，但這實際上並不是預期的行為。使用`Concerns::`的應用程序需要將這些類和模塊重命名，以便能夠在`zeitwerk`模式下運行。

#### 在自動加載路徑中添加`app`

某些項目希望像`app/api/base.rb`這樣的文件定義`API::Base`，並將`app`添加到自動加載路徑中以在`classic`模式下實現。由於Rails自動將`app`的所有子目錄添加到自動加載路徑中，因此我們又遇到了另一種情況，即存在嵌套的根目錄，因此該設置不再起作用。這與我們上面解釋的`concerns`原則類似。

如果您想保留該結構，您需要在初始化程序中從自動加載路徑中刪除子目錄：

```ruby
ActiveSupport::Dependencies.autoload_paths.delete("#{Rails.root}/app/api")
```

#### 自動加載的常量和明確的命名空間

如果在文件中定義了命名空間，例如這裡的`Hotel`：

```
app/models/hotel.rb         # 定義了Hotel。
app/models/hotel/pricing.rb # 定義了Hotel::Pricing。
```

則必須使用`class`或`module`關鍵字設置`Hotel`常量。例如：

```ruby
class Hotel
end
```

是正確的。

以下替代方法不起作用：

```ruby
Hotel = Class.new
```

或者

```ruby
Hotel = Struct.new
```

這樣的替代方法無法找到`Hotel::Pricing`等子對象。

此限制僅適用於明確的命名空間。不定義命名空間的類和模塊可以使用這些習慣用法來定義。

#### 一個文件，一個常量（在同一個頂層）

在`classic`模式下，您可以在同一個頂層定義多個常量並將它們全部重新加載。例如，假設有以下代碼：

```ruby
# app/models/foo.rb

class Foo
end

class Bar
end
```

在`classic`模式下，`Bar`無法自動加載，但自動加載`Foo`將標記`Bar`為已自動加載。但在`zeitwerk`模式下，您需要將`Bar`移動到自己的文件`bar.rb`中。一個文件，一個常量。

這只適用於與上面示例中相同頂層的常量。內部類和模塊沒有此限制。例如，考慮以下代碼：

```ruby
# app/models/foo.rb

class Foo
  class InnerClass
  end
end
```

如果應用程序重新加載`Foo`，它也將重新加載`Foo::InnerClass`。

#### Spring和`test`環境

如果有任何更改，Spring將重新加載應用程序代碼。在`test`環境中，您需要啟用重新加載才能正常工作：

```ruby
# config/environments/test.rb

config.cache_classes = false
```

否則，您將收到以下錯誤：

```
reloading is disabled because config.cache_classes is true
```

#### Bootsnap

Bootsnap的版本應至少為1.4.2。

此外，由於Ruby 2.5中解釋器的一個錯誤，Bootsnap需要禁用iseq緩存。在這種情況下，請確保至少依賴於Bootsnap 1.4.4。

#### `config.add_autoload_paths_to_load_path`

新的配置點[`config.add_autoload_paths_to_load_path`][]默認為`true`，以保持向後兼容性，但允許您選擇不將自動加載路徑添加到`$LOAD_PATH`中。

對於大多數應用程序來說，這是有意義的，因為您永遠不應該在`app/models`中要求文件，而Zeitwerk內部只使用絕對文件名。
通過選擇退出，您可以優化`$LOAD_PATH`的查找（減少目錄的檢查），並節省Bootsnap的工作和內存消耗，因為它不需要為這些目錄建立索引。

#### 线程安全

在经典模式下，常量自动加载不是线程安全的，尽管Rails已经放置了锁定机制，例如在启用自动加载时使Web请求线程安全，因为在开发环境中这是常见的。

在`zeitwerk`模式下，常量自动加载是线程安全的。例如，您现在可以在`runner`命令执行的多线程脚本中自动加载。

#### 配置中的通配符

注意配置如下的情况：

```ruby
config.autoload_paths += Dir["#{config.root}/lib/**/"]
```

`config.autoload_paths`的每个元素都应该代表顶级命名空间（`Object`），它们不能嵌套（除了上面解释的`concerns`目录）。

要修复这个问题，只需删除通配符：

```ruby
config.autoload_paths << "#{config.root}/lib"
```

#### 预加载和自动加载的一致性

在`classic`模式下，如果`app/models/foo.rb`定义了`Bar`，您将无法自动加载该文件，但是预加载将工作，因为它会盲目地递归加载文件。如果您首先测试了预加载，然后执行自动加载，这可能会导致错误。

在`zeitwerk`模式下，这两种加载模式是一致的，它们在相同的文件中失败和出错。

#### 如何在Rails 6中使用经典自动加载器

应用程序可以加载Rails 6的默认设置，并通过以下方式设置经典自动加载器：

```ruby
# config/application.rb

config.load_defaults 6.0
config.autoloader = :classic
```

在Rails 6应用程序中使用经典自动加载器时，建议在开发环境中将并发级别设置为1，用于Web服务器和后台处理器，以解决线程安全问题。

### Active Storage分配行为的更改

在Rails 5.2的默认配置中，将文件分配给使用`has_many_attached`声明的附件集合时，会追加新文件：

```ruby
class User < ApplicationRecord
  has_many_attached :highlights
end

user.highlights.attach(filename: "funky.jpg", ...)
user.highlights.count # => 1

blob = ActiveStorage::Blob.create_after_upload!(filename: "town.jpg", ...)
user.update!(highlights: [ blob ])

user.highlights.count # => 2
user.highlights.first.filename # => "funky.jpg"
user.highlights.second.filename # => "town.jpg"
```

在Rails 6.0的默认配置中，将文件分配给使用`has_many_attached`声明的附件集合时，会替换现有文件而不是追加：

```ruby
user.highlights.attach(filename: "funky.jpg", ...)
user.highlights.count # => 1

blob = ActiveStorage::Blob.create_after_upload!(filename: "town.jpg", ...)
user.update!(highlights: [ blob ])

user.highlights.count # => 1
user.highlights.first.filename # => "town.jpg"
```

可以使用`#attach`方法添加新的附件而不删除现有的附件：

```ruby
blob = ActiveStorage::Blob.create_after_upload!(filename: "town.jpg", ...)
user.highlights.attach(blob)

user.highlights.count # => 2
user.highlights.first.filename # => "funky.jpg"
user.highlights.second.filename # => "town.jpg"
```

现有的应用程序可以通过将[`config.active_storage.replace_on_assign_to_many`][]设置为`true`来选择使用这种新行为。旧行为将在Rails 7.0中弃用，并在Rails 7.1中删除。

### 自定义异常处理应用程序

无效的`Accept`或`Content-Type`请求头将引发异常。默认的[`config.exceptions_app`][]专门处理该错误并进行补偿。自定义异常应用程序也需要处理该错误，否则这样的请求将导致Rails使用回退的异常应用程序，返回`500 Internal Server Error`。

从Rails 5.1升级到Rails 5.2
-------------------------------------

有关Rails 5.2所做更改的更多信息，请参阅[发布说明](5_2_release_notes.html)。

### Bootsnap

Rails 5.2在[新生成的应用程序的Gemfile](https://github.com/rails/rails/pull/29313)中添加了bootsnap gem。`app:update`命令在`boot.rb`中设置了它。如果您想使用它，请将其添加到Gemfile中：

```ruby
# 通过缓存减少启动时间；在config/boot.rb中需要
gem 'bootsnap', require: false
```

否则，请更改`boot.rb`以不使用bootsnap。

### 签名或加密cookie中的过期时间现在嵌入在cookie值中

为了提高安全性，Rails现在还将过期信息嵌入到加密或签名cookie的值中。

这个新的嵌入信息使得这些cookie与早于5.2版本的Rails不兼容。

如果您需要让您的cookie被5.1和更早版本读取，或者您仍在验证您的5.2部署并希望允许回滚，请将`Rails.application.config.action_dispatch.use_authenticated_cookie_encryption`设置为`false`。

从Rails 5.0升级到Rails 5.1
-------------------------------------

有关Rails 5.1所做更改的更多信息，请参阅[发布说明](5_1_release_notes.html)。

### 顶级`HashWithIndifferentAccess`已被软弃用

如果您的应用程序使用顶级`HashWithIndifferentAccess`类，您应该逐渐将您的代码改为使用`ActiveSupport::HashWithIndifferentAccess`。
這只是軟棄用，這意味著您的代碼目前不會出錯，也不會顯示任何棄用警告，但這個常量將來會被刪除。

此外，如果您有非常舊的YAML文檔，其中包含這些對象的轉儲，您可能需要重新加載和轉儲它們，以確保它們引用正確的常量，並且在將來不會出錯。

### `application.secrets`現在以所有鍵作為符號加載

如果您的應用程序將嵌套配置存儲在`config/secrets.yml`中，則現在所有鍵都以符號形式加載，因此應更改使用字符串的訪問方式。

從：

```ruby
Rails.application.secrets[:smtp_settings]["address"]
```

到：

```ruby
Rails.application.secrets[:smtp_settings][:address]
```

### 移除`render`中對`：text`和`：nothing`的棄用支持

如果您的控制器使用`render :text`，它們將不再起作用。使用MIME類型為`text/plain`的新方法來呈現文本是使用`render :plain`。

同樣，已經移除了`render :nothing`，您應該使用`head`方法來發送僅包含標頭的響應。例如，`head :ok`將發送一個沒有正文的200響應。

### 移除對`redirect_to :back`的棄用支持

在Rails 5.0中，`redirect_to :back`已被棄用。在Rails 5.1中，它完全被刪除。

作為替代方案，請使用`redirect_back`。重要的是要注意，`redirect_back`還接受一個`fallback_location`選項，如果`HTTP_REFERER`缺失，將使用該選項。

```ruby
redirect_back(fallback_location: root_path)
```

從Rails 4.2升級到Rails 5.0
-------------------------------------

有關Rails 5.0所做更改的更多信息，請參閱[發行說明](5_0_release_notes.html)。

### 需要Ruby 2.2.2+

從Ruby on Rails 5.0開始，只支持Ruby 2.2.2+版本。在繼續之前，請確保您使用的是2.2.2版本或更高版本。

### Active Record模型現在默認繼承自ApplicationRecord

在Rails 4.2中，Active Record模型繼承自`ActiveRecord::Base`。在Rails 5.0中，所有模型都繼承自`ApplicationRecord`。

`ApplicationRecord`是所有應用程序模型的新超類，類似於應用程序控制器繼承`ApplicationController`而不是`ActionController::Base`。這為應用程序提供了一個單一的位置來配置應用程序範圍的模型行為。

從Rails 4.2升級到Rails 5.0時，您需要在`app/models/`中創建一個`application_record.rb`文件，並添加以下內容：

```ruby
class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true
end
```

然後確保所有模型都繼承自它。

### 通過`throw(:abort)`停止回調鏈

在Rails 4.2中，當Active Record和Active Model中的“before”回調返回`false`時，整個回調鏈將停止。換句話說，連續的“before”回調不會被執行，也不會執行在回調中包裹的操作。

在Rails 5.0中，返回Active Record或Active Model回調中的`false`將不會停止回調鏈的這個副作用。相反，必須通過調用`throw(:abort)`來明確停止回調鏈。

從Rails 4.2升級到Rails 5.0時，返回這些類型的回調中的`false`仍然會停止回調鏈，但您將收到有關此即將到來的更改的棄用警告。

當您準備好時，您可以選擇新的行為並通過將以下配置添加到您的`config/application.rb`中來刪除棄用警告：

```ruby
ActiveSupport.halt_callback_chains_on_return_false = false
```

請注意，此選項不會影響Active Support回調，因為它們在返回任何值時從不停止鏈。

有關更多詳細信息，請參閱[#17227](https://github.com/rails/rails/pull/17227)。

### ActiveJob現在默認繼承自ApplicationJob

在Rails 4.2中，Active Job繼承自`ActiveJob::Base`。在Rails 5.0中，這種行為已更改為現在繼承自`ApplicationJob`。

從Rails 4.2升級到Rails 5.0時，您需要在`app/jobs/`中創建一個`application_job.rb`文件，並添加以下內容：

```ruby
class ApplicationJob < ActiveJob::Base
end
```

然後確保所有作業類都繼承自它。

有關更多詳細信息，請參閱[#19034](https://github.com/rails/rails/pull/19034)。

### Rails控制器測試

#### 將一些輔助方法提取到`rails-controller-testing`

`assigns`和`assert_template`已經提取到`rails-controller-testing` gem中。要在控制器測試中繼續使用這些方法，請將`gem 'rails-controller-testing'`添加到您的`Gemfile`中。

如果您使用RSpec進行測試，請參閱該gem文檔中所需的額外配置。

#### 上傳文件時的新行為

如果您在測試中使用`ActionDispatch::Http::UploadedFile`上傳文件，您需要更改為使用類似的`Rack::Test::UploadedFile`類。
請參閱[#26404](https://github.com/rails/rails/issues/26404)以獲取更多詳細資訊。

### 在生產環境啟動後停用自動載入

預設情況下，在生產環境啟動後將停用自動載入。

應用程式的急速載入是啟動過程的一部分，因此頂層常數是可以的，仍然會自動載入，不需要要求其檔案。

深層位置的常數只有在運行時才會執行，例如常規方法體，也是可以的，因為在啟動時已經急速載入了定義它們的檔案。

對於絕大多數應用程式，這個變更不需要任何操作。但在非常罕見的情況下，如果您的應用程式在生產環境中需要自動載入，請將`Rails.application.config.enable_dependency_loading`設置為`true`。

### XML 序列化

`ActiveModel::Serializers::Xml`已從Rails中提取到`activemodel-serializers-xml` gem。要繼續在應用程式中使用XML序列化，請將`gem 'activemodel-serializers-xml'`添加到您的`Gemfile`中。

### 移除對舊版`mysql`數據庫適配器的支援

Rails 5移除了對舊版`mysql`數據庫適配器的支援。大多數用戶應該可以使用`mysql2`代替。當我們找到有人維護時，它將被轉換為一個獨立的gem。

### 移除對Debugger的支援

Ruby 2.2不支援`debugger`，而Rails 5需要使用Ruby 2.2。請改用`byebug`。

### 使用`bin/rails`運行任務和測試

Rails 5新增了通過`bin/rails`運行任務和測試的功能，而不是使用rake。通常這些變更與rake平行進行，但有些變更完全移植過來。

要使用新的測試運行器，只需輸入`bin/rails test`。

`rake dev:cache`現在是`bin/rails dev:cache`。

在應用程式的根目錄中運行`bin/rails`以查看可用的命令列表。

### `ActionController::Parameters`不再繼承自`HashWithIndifferentAccess`

在應用程式中調用`params`將返回一個對象而不是哈希。如果您的參數已經被允許，則不需要進行任何更改。如果您正在使用`map`和其他依賴於無論`permitted?`如何都能讀取哈希的方法，則需要升級您的應用程式，首先允許然後轉換為哈希。

```ruby
params.permit([:proceed_to, :return_to]).to_h
```

### `protect_from_forgery`現在的默認值為`prepend: false`

`protect_from_forgery`的默認值為`prepend: false`，這意味著它將在您在應用程式中調用它的位置插入到回調鏈中。如果您希望`protect_from_forgery`始終首先運行，則應更改您的應用程式以使用`protect_from_forgery prepend: true`。

### 默認模板處理程序現在是RAW

沒有模板處理程序的擴展名的檔案將使用原始處理程序呈現。以前，Rails會使用ERB模板處理程序呈現檔案。

如果您不希望您的檔案通過原始處理程序處理，請為您的檔案添加一個可以由適當的模板處理程序解析的擴展名。

### 模板依賴關係的通配符匹配

您現在可以使用通配符匹配來處理模板依賴關係。例如，如果您定義模板如下：

```erb
<% # 模板依賴關係：recordings/threads/events/subscribers_changed %>
<% # 模板依賴關係：recordings/threads/events/completed %>
<% # 模板依賴關係：recordings/threads/events/uncompleted %>
```

您現在只需使用通配符一次調用依賴關係。

```erb
<% # 模板依賴關係：recordings/threads/events/* %>
```

### `ActionView::Helpers::RecordTagHelper`移至外部gem（record_tag_helper）

`content_tag_for`和`div_for`已被移除，改用`content_tag`。要繼續使用舊的方法，請將`record_tag_helper` gem添加到您的`Gemfile`中：

```ruby
gem 'record_tag_helper', '~> 1.0'
```

請參閱[#18411](https://github.com/rails/rails/pull/18411)以獲取更多詳細資訊。

### 移除對`protected_attributes` gem的支援

Rails 5不再支援`protected_attributes` gem。

### 移除對`activerecord-deprecated_finders` gem的支援

Rails 5不再支援`activerecord-deprecated_finders` gem。

### `ActiveSupport::TestCase`的默認測試順序現在是隨機的

在運行應用程式的測試時，默認順序現在是`:random`而不是`:sorted`。使用以下配置選項將其設置回`:sorted`。

```ruby
# config/environments/test.rb
Rails.application.configure do
  config.active_support.test_order = :sorted
end
```

### `ActionController::Live`變為`Concern`

如果您在另一個模塊中包含`ActionController::Live`並將該模塊包含在您的控制器中，則您還應該使用`ActiveSupport::Concern`擴展該模塊。或者，您可以使用`self.included`鉤子在包含`StreamingSupport`後直接將`ActionController::Live`包含到控制器中。

這意味著如果您的應用程式以前有自己的流模塊，以下代碼將在生產中中斷：
```ruby
# 這是一個解決使用 Warden/Devise 進行身份驗證的流式控制器的方法。
# 請參考 https://github.com/plataformatec/devise/issues/2332
# 路由中進行身份驗證是另一個解決方案，如該問題中所建議的。
class StreamingSupport
  include ActionController::Live # 這在 Rails 5 的生產環境中無法運作
  # extend ActiveSupport::Concern # 除非你取消註解這一行。

  def process(name)
    super(name)
  rescue ArgumentError => e
    if e.message == 'uncaught throw :warden'
      throw :warden
    else
      raise e
    end
  end
end
```

### 新的框架默認值

#### Active Record `belongs_to` 默認需要選項

如果關聯不存在，`belongs_to` 現在默認會觸發驗證錯誤。

可以使用 `optional: true` 來關閉每個關聯的默認驗證。

這個默認值會自動配置在新的應用程式中。如果現有的應用程式想要添加這個功能，需要在初始化程序中打開它：

```ruby
config.active_record.belongs_to_required_by_default = true
```

這個配置默認是全局的，對所有模型都有效，但你可以在每個模型上覆蓋它。這應該幫助你將所有模型遷移到默認要求它們的關聯。

```ruby
class Book < ApplicationRecord
  # 模型還沒準備好默認要求關聯

  self.belongs_to_required_by_default = false
  belongs_to(:author)
end

class Car < ApplicationRecord
  # 模型已經準備好默認要求關聯

  self.belongs_to_required_by_default = true
  belongs_to(:pilot)
end
```

#### 每個表單的 CSRF Token

Rails 5 現在支持每個表單的 CSRF Token，以防止 JavaScript 創建的表單的代碼注入攻擊。打開這個選項後，應用程式中的每個表單都會有自己的 CSRF Token，該 Token 專門用於該表單的動作和方法。

```ruby
config.action_controller.per_form_csrf_tokens = true
```

#### 通過 Origin 檢查進行防偽保護

你現在可以配置應用程式檢查 HTTP `Origin` 標頭是否與站點的原始位置匹配，作為額外的 CSRF 防禦。在配置中設置以下值為 true：

```ruby
config.action_controller.forgery_protection_origin_check = true
```

#### 允許配置 Action Mailer 佇列名稱

默認的郵件佇列名稱是 `mailers`。這個配置選項允許你全局更改佇列名稱。在配置中設置以下值：

```ruby
config.action_mailer.deliver_later_queue_name = :new_queue_name
```

#### 在 Action Mailer 視圖中支持片段緩存

在配置中設置 [`config.action_mailer.perform_caching`][]，以確定你的 Action Mailer 視圖是否支持緩存。

```ruby
config.action_mailer.perform_caching = true
```

#### 配置 `db:structure:dump` 的輸出

如果你使用了 `schema_search_path` 或其他 PostgreSQL 擴展，你可以控制如何導出模式。設置為 `:all` 以生成所有導出，或設置為 `:schema_search_path` 以從模式搜索路徑生成導出。

```ruby
config.active_record.dump_schemas = :all
```

#### 配置 SSL 選項以啟用帶子域名的 HSTS

在配置中設置以下值以在使用子域名時啟用 HSTS：

```ruby
config.ssl_options = { hsts: { subdomains: true } }
```

#### 保留接收者的時區

在使用 Ruby 2.4 時，當調用 `to_time` 時，你可以保留接收者的時區。

```ruby
ActiveSupport.to_time_preserves_timezone = false
```

### JSON/JSONB 序列化的變化

在 Rails 5.0 中，JSON/JSONB 屬性的序列化和反序列化方式發生了變化。現在，如果你將一個列等於 `String`，Active Record 將不再將該字符串轉換為 `Hash`，而只會返回該字符串。這不僅限於與模型交互的代碼，還影響到 `db/schema.rb` 中的 `:default` 列設置。建議不要將列設置為 `String`，而是傳遞一個 `Hash`，它將自動轉換為 JSON 字符串。

從 Rails 4.1 升級到 Rails 4.2
----------------------------

### Web Console

首先，在你的 `Gemfile` 中的 `:development` 組中添加 `gem 'web-console', '~> 2.0'`，然後運行 `bundle install`（在升級 Rails 時它不會被包含）。安裝完成後，你只需在任何你想啟用它的視圖中添加對控制台助手的引用（例如 `<%= console %>`）。在開發環境中查看任何錯誤頁面時，也會提供一個控制台。

### Responders

`respond_with` 和類級的 `respond_to` 方法已經被提取到 `responders` gem 中。要使用它們，只需在你的 `Gemfile` 中添加 `gem 'responders', '~> 2.0'`。在你的依賴中包含 `responders` gem 後，`respond_with` 和類級的 `respond_to` 調用將不再起作用：
```
```ruby
# app/controllers/users_controller.rb

class UsersController < ApplicationController
  respond_to :html, :json

  def show
    @user = User.find(params[:id])
    respond_with @user
  end
end
```

實例級別的`respond_to`不受影響，並且不需要額外的gem：

```ruby
# app/controllers/users_controller.rb

class UsersController < ApplicationController
  def show
    @user = User.find(params[:id])
    respond_to do |format|
      format.html
      format.json { render json: @user }
    end
  end
end
```

詳情請參閱[#16526](https://github.com/rails/rails/pull/16526)。

### 事務回調中的錯誤處理

目前，Active Record會壓制在`after_rollback`或`after_commit`回調中引發的錯誤，並且只會將它們打印到日誌中。在下一個版本中，這些錯誤將不再被壓制。相反，這些錯誤將像其他Active Record回調一樣正常傳播。

當您定義`after_rollback`或`after_commit`回調時，您將收到有關此即將到來的更改的停用警告。當您準備好時，您可以選擇新的行為並通過將以下配置添加到您的`config/application.rb`中來刪除停用警告：

```ruby
config.active_record.raise_in_transactional_callbacks = true
```

詳情請參閱[#14488](https://github.com/rails/rails/pull/14488)和[#16537](https://github.com/rails/rails/pull/16537)。

### 測試用例的順序

在Rails 5.0中，預設情況下將隨機執行測試用例。為了預防這個變化，Rails 4.2引入了一個新的配置選項`active_support.test_order`，用於明確指定測試順序。這使您可以通過將選項設置為`:sorted`來鎖定當前行為，或者通過將選項設置為`:random`來選擇未來行為。

如果您不為此選項指定值，將發出一個停用警告。為了避免這種情況，請將以下行添加到您的測試環境中：

```ruby
# config/environments/test.rb
Rails.application.configure do
  config.active_support.test_order = :sorted # 或者如果您喜歡，設置為`:random`
end
```

### 序列化屬性

當使用自定義編碼器（例如`serialize :metadata, JSON`）時，將`nil`賦值給序列化屬性將將其保存到數據庫中作為`NULL`，而不是通過編碼器傳遞`nil`值（例如，使用`JSON`編碼器時為`"null"`）。

### 生產日誌級別

在Rails 5中，生產環境的默認日誌級別將從`：info`更改為`：debug`。為了保留當前的默認值，請將以下行添加到您的`production.rb`中：

```ruby
# 設置為`:info`以匹配當前的默認值，或者設置為`:debug`以選擇未來的默認值。
config.log_level = :info
```

### Rails模板中的`after_bundle`

如果您有一個將所有文件添加到版本控制的Rails模板，它在生成binstubs之前執行，因此無法添加生成的binstubs：

```ruby
# template.rb
generate(:scaffold, "person name:string")
route "root to: 'people#index'"
rake("db:migrate")

git :init
git add: "."
git commit: %Q{ -m 'Initial commit' }
```

現在，您可以將`git`調用包裝在`after_bundle`塊中。它將在生成binstubs之後運行。

```ruby
# template.rb
generate(:scaffold, "person name:string")
route "root to: 'people#index'"
rake("db:migrate")

after_bundle do
  git :init
  git add: "."
  git commit: %Q{ -m 'Initial commit' }
end
```

### Rails HTML Sanitizer

在您的應用程序中，有一個用於清理HTML片段的新選擇。古老的html-scanner方法現在正式被棄用，取而代之的是[`Rails HTML Sanitizer`](https://github.com/rails/rails-html-sanitizer)。

這意味著`sanitize`，`sanitize_css`，`strip_tags`和`strip_links`方法都有了新的實現。

這個新的清理器在內部使用[Loofah](https://github.com/flavorjones/loofah)。而Loofah則使用了C和Java編寫的XML解析器Nokogiri，所以無論您運行哪個Ruby版本，清理速度都應該更快。

新版本更新了`sanitize`，因此它可以接受`Loofah::Scrubber`進行強大的清理。
[在這裡看一些Scrubber的示例](https://github.com/flavorjones/loofah#loofahscrubber)。

還添加了兩個新的Scrubber：`PermitScrubber`和`TargetScrubber`。
請閱讀[gem的自述文件](https://github.com/rails/rails-html-sanitizer)以獲取更多信息。

`PermitScrubber`和`TargetScrubber`的文檔解釋了您如何完全控制何時以及如何剝除元素。

如果您的應用程序需要使用舊的清理器實現，在您的`Gemfile`中包含`rails-deprecated_sanitizer`：

```ruby
gem 'rails-deprecated_sanitizer'
```

### Rails DOM Testing

[`TagAssertions`模塊](https://api.rubyonrails.org/v4.1/classes/ActionDispatch/Assertions/TagAssertions.html)（包含`assert_tag`等方法）已被棄用，取而代之的是從`SelectorAssertions`模塊中提取出來的`assert_select`方法，該模塊已被提取到[rails-dom-testing gem](https://github.com/rails/rails-dom-testing)中。

### 掩蓋的真實性令牌

為了防止SSL攻擊，`form_authenticity_token`現在被掩蓋，以便每個請求都不同。因此，令牌通過解掩蓋和解密進行驗證。因此，任何依賴於靜態會話CSRF令牌驗證非Rails表單的請求的策略都必須考慮到這一點。
### Action Mailer

以前，在郵件類別上調用郵件方法會直接執行相應的實例方法。隨著 Active Job 和 `#deliver_later` 的引入，這種情況不再成立。在 Rails 4.2 中，實例方法的調用被延遲到 `deliver_now` 或 `deliver_later` 被調用之前。例如：

```ruby
class Notifier < ActionMailer::Base
  def notify(user, ...)
    puts "Called"
    mail(to: user.email, ...)
  end
end
```

```ruby
mail = Notifier.notify(user, ...) # 此時 Notifier#notify 尚未被調用
mail = mail.deliver_now           # 輸出 "Called"
```

對於大多數應用程序來說，這不會產生任何明顯的差異。但是，如果您需要同步執行一些非郵件方法，並且之前依賴於同步代理行為，則應直接在郵件類別上定義它們作為類方法：

```ruby
class Notifier < ActionMailer::Base
  def self.broadcast_notifications(users, ...)
    users.each { |user| Notifier.notify(user, ...) }
  end
end
```

### 外鍵支援

遷移 DSL 已擴展以支援外鍵定義。如果您一直在使用 Foreigner gem，您可能希望考慮將其移除。請注意，Rails 的外鍵支援是 Foreigner 的一個子集。這意味著並非每個 Foreigner 定義都可以完全由其 Rails 遷移 DSL 對應物取代。

遷移程序如下：

1. 從 `Gemfile` 中刪除 `gem "foreigner"`。
2. 執行 `bundle install`。
3. 執行 `bin/rake db:schema:dump`。
4. 確保 `db/schema.rb` 包含了每個外鍵定義和必要的選項。

從 Rails 4.0 升級到 Rails 4.1
-------------------------------------

### 遠程 `<script>` 標籤的 CSRF 保護

或者，"我的測試失敗了！！！" 或者 "我的 `<script>` 小工具壞了！！"

跨站請求偽造（CSRF）保護現在也適用於帶有 JavaScript 響應的 GET 請求。這可以防止第三方站點通過 `<script>` 標籤遠程引用您的 JavaScript 以提取敏感數據。

這意味著使用以下代碼的功能和集成測試

```ruby
get :index, format: :js
```

現在將觸發 CSRF 保護。請改用

```ruby
xhr :get, :index, format: :js
```

以明確測試 `XmlHttpRequest`。

注意：您自己的 `<script>` 標籤也被視為跨域並被默認阻止。如果您確實需要從 `<script>` 標籤加載 JavaScript，您現在必須明確跳過這些操作的 CSRF 保護。

### Spring

如果您想將 Spring 作為應用程序預加載器，您需要：

1. 在 `Gemfile` 中添加 `gem 'spring', group: :development`。
2. 使用 `bundle install` 安裝 spring。
3. 使用 `bundle exec spring binstub` 生成 Spring binstub。

注意：用戶定義的 rake 任務默認在 `development` 環境中運行。如果您希望它們在其他環境中運行，請參考 [Spring README](https://github.com/rails/spring#rake)。

### `config/secrets.yml`

如果您想使用新的 `secrets.yml` 慣例來存儲應用程序的密鑰，您需要：

1. 在 `config` 文件夾中創建一個 `secrets.yml` 文件，內容如下：

    ```yaml
    development:
      secret_key_base:

    test:
      secret_key_base:

    production:
      secret_key_base: <%= ENV["SECRET_KEY_BASE"] %>
    ```

2. 使用現有的 `secret_token.rb` 初始化程序中的 `secret_key_base`，為在生產中運行 Rails 應用程序的任何用戶設置 `SECRET_KEY_BASE` 環境變量。或者，您可以直接將現有的 `secret_key_base` 從 `secret_token.rb` 初始化程序複製到 `secrets.yml` 的 `production` 部分，替換 `<%= ENV["SECRET_KEY_BASE"] %>`。

3. 刪除 `secret_token.rb` 初始化程序。

4. 使用 `rake secret` 生成 `development` 和 `test` 部分的新密鑰。

5. 重新啟動您的服務器。

### 測試助手的變更

如果您的測試助手包含對 `ActiveRecord::Migration.check_pending!` 的調用，則可以將其刪除。現在在 `require "rails/test_help"` 時會自動執行檢查，但是在助手中保留此行不會有任何壞處。

### Cookies 序列化器

在 Rails 4.1 之前創建的應用程序使用 `Marshal` 將 cookie 值序列化到簽名和加密的 cookie 存儲中。如果您想在應用程序中使用新的基於 `JSON` 的格式，您可以添加一個初始化文件，內容如下：

```ruby
Rails.application.config.action_dispatch.cookies_serializer = :hybrid
```

這將使您現有的使用 `Marshal` 序列化的 cookie 自動遷移到新的基於 `JSON` 的格式。

使用 `:json` 或 `:hybrid` 序列化器時，您應該注意並非所有 Ruby 對象都可以序列化為 JSON。例如，`Date` 和 `Time` 對象將序列化為字符串，而 `Hash` 的鍵將被轉換為字符串。

```ruby
class CookiesController < ApplicationController
  def set_cookie
    cookies.encrypted[:expiration_date] = Date.tomorrow # => Thu, 20 Mar 2014
    redirect_to action: 'read_cookie'
  end

  def read_cookie
    cookies.encrypted[:expiration_date] # => "2014-03-20"
  end
end
```
建議只在cookie中存儲簡單的數據（字符串和數字）。
如果必須存儲複雜的對象，則需要在後續請求中手動處理轉換。

如果使用cookie會話存儲，這也適用於`session`和`flash`哈希。

### Flash結構變更

Flash消息鍵已經[規範化為字符串](https://github.com/rails/rails/commit/a668beffd64106a1e1fedb71cc25eaaa11baf0c1)。它們仍然可以使用符號或字符串訪問。循環遍歷flash將始終產生字符串鍵：

```ruby
flash["string"] = "a string"
flash[:symbol] = "a symbol"

# Rails < 4.1
flash.keys # => ["string", :symbol]

# Rails >= 4.1
flash.keys # => ["string", "symbol"]
```

請確保將Flash消息鍵與字符串進行比較。

### JSON處理變更

Rails 4.1中與JSON處理相關的變更有幾個重要的變更。

#### 移除MultiJSON

MultiJSON已達到[生命週期終點](https://github.com/rails/rails/pull/10576)，並已從Rails中刪除。

如果您的應用程序目前直接依賴於MultiJSON，您有幾個選擇：

1. 在`Gemfile`中添加'multi_json'。請注意，這可能在將來停止工作。

2. 通過使用`obj.to_json`和`JSON.parse(str)`來遷移MultiJSON。

警告：不要僅僅將`MultiJson.dump`和`MultiJson.load`替換為`JSON.dump`和`JSON.load`。這些JSON gem API用於序列化和反序列化任意Ruby對象，通常是[不安全的](https://ruby-doc.org/stdlib-2.2.2/libdoc/json/rdoc/JSON.html#method-i-load)。

#### JSON gem兼容性

在過去，Rails與JSON gem存在一些兼容性問題。在Rails應用程序中使用`JSON.generate`和`JSON.dump`可能會產生意外錯誤。

Rails 4.1通過將自己的編碼器與JSON gem隔離來解決了這些問題。JSON gem API將正常運作，但它們將無法訪問任何Rails特定功能。例如：

```ruby
class FooBar
  def as_json(options = nil)
    { foo: 'bar' }
  end
end
```

```irb
irb> FooBar.new.to_json
=> "{\"foo\":\"bar\"}"
irb> JSON.generate(FooBar.new, quirks_mode: true)
=> "\"#<FooBar:0x007fa80a481610>\""
```

#### 新的JSON編碼器

Rails 4.1中的JSON編碼器已經重寫，以利用JSON gem。對於大多數應用程序來說，這應該是一個透明的變更。但是，作為重寫的一部分，編碼器中刪除了以下功能：

1. 循環數據結構檢測
2. 對`encode_json`鉤子的支持
3. 將`BigDecimal`對象編碼為數字而不是字符串的選項

如果您的應用程序依賴於這些功能之一，可以通過將[`activesupport-json_encoder`](https://github.com/rails/activesupport-json_encoder) gem添加到您的`Gemfile`中來恢復它們。

#### Time對象的JSON表示

具有時間組件（`Time`，`DateTime`，`ActiveSupport::TimeWithZone`）的對象的`#as_json`現在默認返回毫秒精度。如果需要保留沒有毫秒精度的舊行為，請在初始化程序中設置以下內容：

```ruby
ActiveSupport::JSON::Encoding.time_precision = 0
```

### 內聯回調塊中的`return`使用

以前，Rails允許內聯回調塊使用`return`的方式：

```ruby
class ReadOnlyModel < ActiveRecord::Base
  before_save { return false } # 不好的寫法
end
```

這種行為從未被有意支持過。由於`ActiveSupport::Callbacks`內部的更改，這在Rails 4.1中不再允許。在內聯回調塊中使用`return`語句將在執行回調時引發`LocalJumpError`。

可以將使用`return`的內聯回調塊重構為求值為返回值：

```ruby
class ReadOnlyModel < ActiveRecord::Base
  before_save { false } # 好的寫法
end
```

或者，如果偏好使用`return`，建議明確定義一個方法：

```ruby
class ReadOnlyModel < ActiveRecord::Base
  before_save :before_save_callback # 好的寫法

  private
    def before_save_callback
      false
    end
end
```

此更改適用於Rails中使用回調的大多數地方，包括Active Record和Active Model回調，以及Action Controller中的過濾器（例如`before_action`）。

有關詳細信息，請參見[此pull request](https://github.com/rails/rails/pull/13271)。

### 在Active Record fixtures中定義的方法

Rails 4.1在單獨的上下文中評估每個fixture的ERB，因此在fixture中定義的輔助方法將不可在其他fixture中使用。

在多個fixture中使用的輔助方法應該在新引入的`ActiveRecord::FixtureSet.context_class`中包含的模塊中定義，在`test_helper.rb`中。

```ruby
module FixtureFileHelpers
  def file_sha(path)
    OpenSSL::Digest::SHA256.hexdigest(File.read(Rails.root.join('test/fixtures', path)))
  end
end

ActiveRecord::FixtureSet.context_class.include FixtureFileHelpers
```

### I18n強制可用語言

Rails 4.1現在將I18n選項`enforce_available_locales`的默認值設置為`true`。這意味著它將確保傳遞給它的所有語言必須在`available_locales`列表中聲明。
要禁用它（並允許I18n接受*任何*區域選項），請將以下配置添加到您的應用程序中：

```ruby
config.i18n.enforce_available_locales = false
```

請注意，此選項是作為安全措施添加的，以確保用戶輸入不能用作區域信息，除非事先已知。因此，除非您有充分的理由這樣做，否則建議不要禁用此選項。

### 在關聯上調用的變異方法

`Relation`不再具有像`#map!`和`#delete_if`這樣的變異方法。在使用這些方法之前，請調用`#to_a`將其轉換為`Array`。

這樣做是為了防止在直接調用變異方法的代碼中出現奇怪的錯誤和混淆。

```ruby
# 不再這樣寫
Author.where(name: 'Hank Moody').compact!

# 現在需要這樣寫
authors = Author.where(name: 'Hank Moody').to_a
authors.compact!
```

### 默認作用域的更改

默認作用域不再被同一字段的鏈式條件覆蓋。

在之前的版本中，當您在模型中定義了一個`default_scope`時，它會被同一字段的鏈式條件覆蓋。現在它像任何其他作用域一樣合併。

之前：

```ruby
class User < ActiveRecord::Base
  default_scope { where state: 'pending' }
  scope :active, -> { where state: 'active' }
  scope :inactive, -> { where state: 'inactive' }
end

User.all
# SELECT "users".* FROM "users" WHERE "users"."state" = 'pending'

User.active
# SELECT "users".* FROM "users" WHERE "users"."state" = 'active'

User.where(state: 'inactive')
# SELECT "users".* FROM "users" WHERE "users"."state" = 'inactive'
```

之後：

```ruby
class User < ActiveRecord::Base
  default_scope { where state: 'pending' }
  scope :active, -> { where state: 'active' }
  scope :inactive, -> { where state: 'inactive' }
end

User.all
# SELECT "users".* FROM "users" WHERE "users"."state" = 'pending'

User.active
# SELECT "users".* FROM "users" WHERE "users"."state" = 'pending' AND "users"."state" = 'active'

User.where(state: 'inactive')
# SELECT "users".* FROM "users" WHERE "users"."state" = 'pending' AND "users"."state" = 'inactive'
```

要獲得以前的行為，需要使用`unscoped`，`unscope`，`rewhere`或`except`明確刪除`default_scope`條件。

```ruby
class User < ActiveRecord::Base
  default_scope { where state: 'pending' }
  scope :active, -> { unscope(where: :state).where(state: 'active') }
  scope :inactive, -> { rewhere state: 'inactive' }
end

User.all
# SELECT "users".* FROM "users" WHERE "users"."state" = 'pending'

User.active
# SELECT "users".* FROM "users" WHERE "users"."state" = 'active'

User.inactive
# SELECT "users".* FROM "users" WHERE "users"."state" = 'inactive'
```

### 從字符串渲染內容

Rails 4.1引入了`：plain`，`：html`和`：body`選項來渲染。這些選項現在是渲染基於字符串的內容的首選方式，因為它允許您指定要將響應發送為的內容類型。

* `render：plain`將內容類型設置為`text/plain`
* `render：html`將內容類型設置為`text/html`
* `render：body`將*不*設置內容類型標頭。

從安全角度來看，如果您不希望在響應主體中有任何標記，您應該使用`render：plain`，因為大多數瀏覽器會為您轉義響應中的不安全內容。

我們將在未來的版本中停用`render：text`的使用。因此，請開始使用更精確的`：plain`，`：html`和`：body`選項。使用`render：text`可能會帶來安全風險，因為內容被發送為`text/html`。

### PostgreSQL JSON和hstore數據類型

Rails 4.1將`json`和`hstore`列映射為以字符串為鍵的Ruby `Hash`。在早期版本中，使用了`HashWithIndifferentAccess`。這意味著不再支持符號訪問。對於基於`json`或`hstore`列的`store_accessors`也是如此。請確保一致使用字符串鍵。

### `ActiveSupport::Callbacks`的顯式塊用法

Rails 4.1現在在調用`ActiveSupport::Callbacks.set_callback`時期望傳遞一個顯式塊。這個變化源於`ActiveSupport::Callbacks`在4.1版本中的大部分重寫。

```ruby
# 在Rails 4.0中以前
set_callback :save, :around, ->(r, &block) { stuff; result = block.call; stuff }

# 現在在Rails 4.1中
set_callback :save, :around, ->(r, block) { stuff; result = block.call; stuff }
```

從Rails 3.2升級到Rails 4.0
-------------------------------------

如果您的應用程序目前使用的是3.2.x之前的任何版本的Rails，請在嘗試升級到Rails 4.0之前升級到Rails 3.2。

以下更改適用於將應用程序升級到Rails 4.0。

### HTTP PATCH
Rails 4現在在`config/routes.rb`中聲明RESTful資源時，使用`PATCH`作為更新的主要HTTP動詞。`update`動作仍然被使用，`PUT`請求仍然會被路由到`update`動作。所以，如果你只使用標準的RESTful路由，不需要做任何更改：

```ruby
resources :users
```

```erb
<%= form_for @user do |f| %>
```

```ruby
class UsersController < ApplicationController
  def update
    # 不需要更改；PATCH將被優先使用，PUT仍然有效。
  end
end
```

然而，如果你使用`form_for`來更新一個資源，並且與使用`PUT` HTTP方法的自定義路由一起使用，則需要進行更改：

```ruby
resources :users do
  put :update_name, on: :member
end
```

```erb
<%= form_for [ :update_name, @user ] do |f| %>
```

```ruby
class UsersController < ApplicationController
  def update_name
    # 需要更改；form_for將嘗試使用不存在的PATCH路由。
  end
end
```

如果該動作不是在公共API中使用，並且你可以更改HTTP方法，你可以將路由更新為使用`patch`而不是`put`：

```ruby
resources :users do
  patch :update_name, on: :member
end
```

在Rails 4中，對`/users/:id`的`PUT`請求將被路由到`update`，就像現在一樣。所以，如果你有一個接收真實PUT請求的API，它將正常工作。路由器還將`PATCH`請求路由到`/users/:id`的`update`動作。

如果該動作在公共API中使用，並且你不能更改正在使用的HTTP方法，你可以更新表單以使用`PUT`方法：

```erb
<%= form_for [ :update_name, @user ], method: :put do |f| %>
```

有關PATCH以及為什麼進行此更改的更多信息，請參閱Rails博客上的[此文章](https://weblog.rubyonrails.org/2012/2/26/edge-rails-patch-is-the-new-primary-http-method-for-updates/)。

#### 關於媒體類型的注意事項

`PATCH`動詞的勘誤[指定應該使用'diff'媒體類型與`PATCH`](http://www.rfc-editor.org/errata_search.php?rfc=5789)。其中一種格式是[JSON Patch](https://tools.ietf.org/html/rfc6902)。雖然Rails不原生支持JSON Patch，但很容易添加支持：

```ruby
# 在你的控制器中：
def update
  respond_to do |format|
    format.json do
      # 執行部分更新
      @article.update params[:article]
    end

    format.json_patch do
      # 執行複雜的更改
    end
  end
end
```

```ruby
# config/initializers/json_patch.rb
Mime::Type.register 'application/json-patch+json', :json_patch
```

由於JSON Patch最近才成為RFC，還沒有很好的Ruby庫。Aaron Patterson的[hana](https://github.com/tenderlove/hana)是其中一個，但對於規範的最後幾個更改沒有完全支持。

### Gemfile

Rails 4.0從`Gemfile`中刪除了`assets`組。在升級時，你需要從`Gemfile`中刪除該行。你還應該更新應用程序文件（在`config/application.rb`中）：

```ruby
# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)
```

### vendor/plugins

Rails 4.0不再支持從`vendor/plugins`加載插件。你必須將任何插件提取為gems並將它們添加到你的`Gemfile`中。如果你選擇不將它們製作成gems，你可以將它們移動到`lib/my_plugin/*`，並在`config/initializers/my_plugin.rb`中添加適當的初始化程序。

### Active Record

* Rails 4.0從Active Record中刪除了身份映射，原因是[與關聯存在一些不一致之處](https://github.com/rails/rails/commit/302c912bf6bcd0fa200d964ec2dc4a44abe328a6)。如果你在應用程序中手動啟用了它，你需要刪除以下不再起作用的配置：`config.active_record.identity_map`。

* 集合關聯中的`delete`方法現在可以接受`Integer`或`String`類型的記錄ID作為參數，就像`destroy`方法一樣。以前，對於這樣的參數，它會引發`ActiveRecord::AssociationTypeMismatch`錯誤。從Rails 4.0開始，`delete`在刪除之前會自動嘗試找到與給定ID匹配的記錄。

* 在Rails 4.0中，當重命名列或表時，相關的索引也會被重命名。如果你有重命名索引的遷移，它們不再需要。

* Rails 4.0將`serialized_attributes`和`attr_readonly`更改為僅類方法。你不應該使用實例方法，因為它已被棄用。你應該將它們更改為使用類方法，例如`self.serialized_attributes`改為`self.class.serialized_attributes`。

* 在使用默認編碼器時，將`nil`賦值給序列化屬性將其保存到數據庫中作為`NULL`，而不是通過YAML傳遞`nil`值（`"--- \n...\n"`）。
* Rails 4.0在Strong Parameters的支持下移除了`attr_accessible`和`attr_protected`功能。您可以使用[Protected Attributes gem](https://github.com/rails/protected_attributes)来平滑升级。

* 如果您不使用Protected Attributes，可以删除与该gem相关的任何选项，如`whitelist_attributes`或`mass_assignment_sanitizer`选项。

* Rails 4.0要求作用域使用可调用对象，如Proc或lambda：

    ```ruby
      scope :active, where(active: true)

      # 变为
      scope :active, -> { where active: true }
    ```

* Rails 4.0已弃用`ActiveRecord::Fixtures`，改用`ActiveRecord::FixtureSet`。

* Rails 4.0已弃用`ActiveRecord::TestCase`，改用`ActiveSupport::TestCase`。

* Rails 4.0已弃用了旧式基于哈希的查找器API。这意味着以前接受“查找器选项”的方法不再接受。例如，`Book.find(:all, conditions: { name: '1984' })`已被弃用，推荐使用`Book.where(name: '1984')`。

* 除了`find_by_...`和`find_by_...!`之外的所有动态方法都已弃用。以下是如何处理这些更改：

      * `find_all_by_...`           变为 `where(...)`.
      * `find_last_by_...`          变为 `where(...).last`.
      * `scoped_by_...`             变为 `where(...)`.
      * `find_or_initialize_by_...` 变为 `find_or_initialize_by(...)`.
      * `find_or_create_by_...`     变为 `find_or_create_by(...)`.

* 请注意，`where(...)`返回的是一个关系（relation），而不是旧查找器中的数组。如果需要一个`Array`，请使用`where(...).to_a`。

* 这些等效方法可能不会执行与以前实现相同的SQL。

* 要重新启用旧查找器，可以使用[activerecord-deprecated_finders gem](https://github.com/rails/activerecord-deprecated_finders)。

* Rails 4.0已更改了`has_and_belongs_to_many`关系的默认连接表，以去除第二个表名的公共前缀。任何具有公共前缀的现有`has_and_belongs_to_many`模型之间的关系都必须使用`join_table`选项指定。例如：

    ```ruby
    CatalogCategory < ActiveRecord::Base
      has_and_belongs_to_many :catalog_products, join_table: 'catalog_categories_catalog_products'
    end

    CatalogProduct < ActiveRecord::Base
      has_and_belongs_to_many :catalog_categories, join_table: 'catalog_categories_catalog_products'
    end
    ```

* 请注意，前缀也考虑了作用域，因此`Catalog::Category`和`Catalog::Product`或`Catalog::Category`和`CatalogProduct`之间的关系需要进行类似的更新。

### Active Resource

Rails 4.0将Active Resource提取为独立的gem。如果您仍然需要该功能，可以在您的`Gemfile`中添加[Active Resource gem](https://github.com/rails/activeresource)。

### Active Model

* Rails 4.0已更改了`ActiveModel::Validations::ConfirmationValidator`中错误附加的方式。现在，当确认验证失败时，错误将附加到`:#{attribute}_confirmation`而不是`attribute`。

* Rails 4.0已将`ActiveModel::Serializers::JSON.include_root_in_json`的默认值更改为`false`。现在，Active Model Serializers和Active Record对象具有相同的默认行为。这意味着您可以在`config/initializers/wrap_parameters.rb`文件中注释或删除以下选项：

    ```ruby
    # Disable root element in JSON by default.
    # ActiveSupport.on_load(:active_record) do
    #   self.include_root_in_json = false
    # end
    ```

### Action Pack

* Rails 4.0引入了`ActiveSupport::KeyGenerator`，并将其用作生成和验证签名cookie（等等）的基础。如果您保留现有的`secret_token`并添加新的`secret_key_base`，则会自动升级现有的使用Rails 3.x生成的签名cookie。

    ```ruby
      # config/initializers/secret_token.rb
      Myapp::Application.config.secret_token = 'existing secret token'
      Myapp::Application.config.secret_key_base = 'new secret key base'
    ```

    请注意，应在100%的用户基础上使用Rails 4.x并且有理由相信您不需要回滚到Rails 3.x之后再设置`secret_key_base`。这是因为基于Rails 4.x中的新`secret_key_base`生成的cookie与Rails 3.x不兼容。您可以保留现有的`secret_token`，不设置新的`secret_key_base`，并忽略弃用警告，直到您相当确定升级已经完成。

    如果您依赖于外部应用程序或JavaScript能够读取您的Rails应用程序的签名会话cookie（或签名cookie），则在解耦这些问题之前不应设置`secret_key_base`。

* Rails 4.0如果设置了`secret_key_base`，会对基于cookie的会话内容进行加密。Rails 3.x对基于cookie的会话进行了签名，但没有加密。签名的cookie是“安全的”，因为它们经过验证，已被您的应用程序生成，并且是防篡改的。但是，内容可以被最终用户查看，加密内容可以消除这个注意事项/问题，而不会带来显著的性能损失。

    请阅读[Pull Request #9978](https://github.com/rails/rails/pull/9978)以了解有关迁移到加密会话cookie的详细信息。

* Rails 4.0已删除了`ActionController::Base.asset_path`选项。请使用资产管道功能。
* Rails 4.0已經棄用`ActionController::Base.page_cache_extension`選項。請改用`ActionController::Base.default_static_extension`。

* Rails 4.0已從Action Pack中移除了Action和Page緩存。您需要在控制器中添加`actionpack-action_caching` gem以使用`caches_action`，以及添加`actionpack-page_caching` gem以使用`caches_page`。

* Rails 4.0已移除XML參數解析器。如果需要此功能，您需要添加`actionpack-xml_parser` gem。

* Rails 4.0更改了使用符號或返回nil的procs進行默認`layout`查找設置。要獲得“無佈局”行為，請返回false而不是nil。

* Rails 4.0將默認的memcached客戶端從`memcache-client`更改為`dalli`。要升級，只需將`gem 'dalli'`添加到您的`Gemfile`中。

* Rails 4.0在控制器中棄用了`dom_id`和`dom_class`方法（在視圖中使用它們是可以的）。如果需要此功能，您需要在需要的控制器中包含`ActionView::RecordIdentifier`模塊。

* Rails 4.0在`link_to`助手中棄用了`:confirm`選項。您應該改為依賴數據屬性（例如`data: { confirm: 'Are you sure?' }`）。此棄用還涉及基於此助手的助手（例如`link_to_if`或`link_to_unless`）。

* Rails 4.0更改了`assert_generates`，`assert_recognizes`和`assert_routing`的工作方式。現在，所有這些斷言都會引發`Assertion`而不是`ActionController::RoutingError`。

* Rails 4.0如果定義了衝突的命名路由，則會引發`ArgumentError`。這可以通過明確定義的命名路由或`resources`方法觸發。以下是兩個與命名路由`example_path`衝突的示例：

    ```ruby
    get 'one' => 'test#example', as: :example
    get 'two' => 'test#example', as: :example
    ```

    ```ruby
    resources :examples
    get 'clashing/:id' => 'test#example', as: :example
    ```

    在第一種情況下，您可以簡單地避免在多個路由中使用相同的名稱。在第二種情況下，您可以使用`resources`方法提供的`only`或`except`選項，以限制根據[路由指南](routing.html#restricting-the-routes-created)中的詳細信息創建的路由。

* Rails 4.0還更改了繪製Unicode字符路由的方式。現在，您可以直接繪製Unicode字符路由。如果您已經繪製了此類路由，則必須對其進行更改，例如：

    ```ruby
    get Rack::Utils.escape('こんにちは'), controller: 'welcome', action: 'index'
    ```

    改為

    ```ruby
    get 'こんにちは', controller: 'welcome', action: 'index'
    ```

* Rails 4.0要求使用`match`的路由必須指定請求方法。例如：

    ```ruby
      # Rails 3.x
      match '/' => 'root#index'

      # 改為
      match '/' => 'root#index', via: :get

      # 或者
      get '/' => 'root#index'
    ```

* Rails 4.0已刪除了`ActionDispatch::BestStandardsSupport`中間件，`<!DOCTYPE html>`已根據 https://msdn.microsoft.com/en-us/library/jj676915(v=vs.85).aspx 觸發標準模式，並且ChromeFrame標頭已移至`config.action_dispatch.default_headers`。

    請記住，您還必須從應用程序代碼中刪除對中間件的任何引用，例如：

    ```ruby
    # 引發異常
    config.middleware.insert_before(Rack::Lock, ActionDispatch::BestStandardsSupport)
    ```

    還要檢查您的環境設置中是否存在`config.action_dispatch.best_standards_support`，如果存在，請將其刪除。

* Rails 4.0允許通過設置`config.action_dispatch.default_headers`來配置HTTP標頭。默認值如下：

    ```ruby
      config.action_dispatch.default_headers = {
        'X-Frame-Options' => 'SAMEORIGIN',
        'X-XSS-Protection' => '1; mode=block'
      }
    ```

    請注意，如果您的應用程序依賴於在`<frame>`或`<iframe>`中加載某些頁面，則可能需要將`X-Frame-Options`明確設置為`ALLOW-FROM ...`或`ALLOWALL`。

* 在Rails 4.0中，預編譯資源不再自動從`vendor/assets`和`lib/assets`複製非JS/CSS資源。Rails應用程序和引擎開發人員應將這些資源放在`app/assets`中或配置[`config.assets.precompile`][]。

* 在Rails 4.0中，當操作不處理請求格式時，將引發`ActionController::UnknownFormat`異常。默認情況下，該異常將以406 Not Acceptable作為響應，但現在您可以覆蓋它。在Rails 3中，始終返回406 Not Acceptable。無法覆蓋。

* 在Rails 4.0中，當`ParamsParser`無法解析請求參數時，將引發通用的`ActionDispatch::ParamsParser::ParseError`異常。您應該捕獲此異常，而不是低級的`MultiJson::DecodeError`，例如。

* 在Rails 4.0中，當引擎安裝在從URL前綴提供服務的應用程序上時，`SCRIPT_NAME`將正確嵌套。您不再需要設置`default_url_options[:script_name]`來解決被覆蓋的URL前綴。

* Rails 4.0棄用了`ActionController::Integration`，改用`ActionDispatch::Integration`。
* Rails 4.0棄用了`ActionController::IntegrationTest`，改用`ActionDispatch::IntegrationTest`。
* Rails 4.0棄用了`ActionController::PerformanceTest`，改用`ActionDispatch::PerformanceTest`。
* Rails 4.0棄用了`ActionController::AbstractRequest`，改用`ActionDispatch::Request`。
* Rails 4.0棄用了`ActionController::Request`，改用`ActionDispatch::Request`。
* Rails 4.0棄用了`ActionController::AbstractResponse`，改用`ActionDispatch::Response`。
* Rails 4.0棄用了`ActionController::Response`，改用`ActionDispatch::Response`。
* Rails 4.0棄用了`ActionController::Routing`，改用`ActionDispatch::Routing`。
### 主動支援

Rails 4.0 移除了 `j` 別名對於 `ERB::Util#json_escape` 的使用，因為 `j` 已經被用於 `ActionView::Helpers::JavaScriptHelper#escape_javascript`。

#### 快取

Rails 3.x 和 4.0 之間的快取方法有所變化。您應該[更改快取命名空間](https://guides.rubyonrails.org/v4.0/caching_with_rails.html#activesupport-cache-store)並在冷快取的情況下進行部署。

### 輔助程式載入順序

在 Rails 4.0 中，從多個目錄載入輔助程式的順序已經改變。以前，它們會被收集然後按字母順序排序。升級到 Rails 4.0 後，輔助程式將保留載入目錄的順序，並且只在每個目錄內按字母順序排序。除非您明確使用 `helpers_path` 參數，否則此更改只會影響從引擎載入輔助程式的方式。如果您依賴於順序，您應該在升級後檢查正確的方法是否可用。如果您想要更改引擎載入的順序，可以使用 `config.railties_order=` 方法。

### Active Record 觀察者和 Action Controller Sweeper

`ActiveRecord::Observer` 和 `ActionController::Caching::Sweeper` 已經被提取到 `rails-observers` gem 中。如果您需要這些功能，您需要添加 `rails-observers` gem。

### sprockets-rails

* `assets:precompile:primary` 和 `assets:precompile:all` 已被移除。請改用 `assets:precompile`。
* `config.assets.compress` 選項應該改為 [`config.assets.js_compressor`][]，例如：

    ```ruby
    config.assets.js_compressor = :uglifier
    ```

### sass-rails

* 具有兩個參數的 `asset-url` 已被棄用。例如：`asset-url("rails.png", image)` 變為 `asset-url("rails.png")`。

從 Rails 3.1 升級到 Rails 3.2
-------------------------------------

如果您的應用程式目前使用的是 3.1.x 之前的任何版本的 Rails，您應該在嘗試升級到 Rails 3.2 之前先升級到 Rails 3.1。

以下更改適用於將您的應用程式升級到最新的 3.2.x 版本的 Rails。

### Gemfile

對您的 `Gemfile` 做以下更改。

```ruby
gem 'rails', '3.2.21'

group :assets do
  gem 'sass-rails',   '~> 3.2.6'
  gem 'coffee-rails', '~> 3.2.2'
  gem 'uglifier',     '>= 1.0.3'
end
```

### config/environments/development.rb

您應該在開發環境中添加一些新的配置設定：

```ruby
# 對於 Active Record 模型的批量賦值保護，引發異常
config.active_record.mass_assignment_sanitizer = :strict

# 對於執行時間超過此閾值的查詢，記錄查詢計劃（適用於 SQLite、MySQL 和 PostgreSQL）
config.active_record.auto_explain_threshold_in_seconds = 0.5
```

### config/environments/test.rb

`mass_assignment_sanitizer` 配置設定也應該添加到 `config/environments/test.rb`：

```ruby
# 對於 Active Record 模型的批量賦值保護，引發異常
config.active_record.mass_assignment_sanitizer = :strict
```

### vendor/plugins

Rails 3.2 廢棄了 `vendor/plugins`，而 Rails 4.0 將完全刪除它們。雖然作為 Rails 3.2 升級的一部分並不是絕對必要的，但您可以開始將任何插件提取為 gems，並將它們添加到您的 `Gemfile` 中。如果您選擇不將它們製作為 gems，您可以將它們移動到 `lib/my_plugin/*`，並在 `config/initializers/my_plugin.rb` 中添加適當的初始化程式。

### Active Record

從 `belongs_to` 中刪除了 `:dependent => :restrict` 選項。如果您想要防止刪除對象，如果存在任何關聯對象，您可以設置 `:dependent => :destroy`，並在任何關聯對象的刪除回調中檢查關聯的存在後返回 `false`。

從 Rails 3.0 升級到 Rails 3.1
-------------------------------------

如果您的應用程式目前使用的是 3.0.x 之前的任何版本的 Rails，您應該在嘗試升級到 Rails 3.1 之前先升級到 Rails 3.0。

以下更改適用於將您的應用程式升級到 Rails 3.1.12，最後一個 3.1.x 版本的 Rails。

### Gemfile

對您的 `Gemfile` 做以下更改。

```ruby
gem 'rails', '3.1.12'
gem 'mysql2'

# 新的資源管道所需
group :assets do
  gem 'sass-rails',   '~> 3.1.7'
  gem 'coffee-rails', '~> 3.1.1'
  gem 'uglifier',     '>= 1.0.3'
end

# jQuery 是 Rails 3.1 的預設 JavaScript 函式庫
gem 'jquery-rails'
```

### config/application.rb

資源管道需要以下新增設定：

```ruby
config.assets.enabled = true
config.assets.version = '1.0'
```

如果您的應用程式使用 "/assets" 路由來存取資源，您可能需要更改用於資源的前綴以避免衝突：

```ruby
# 預設為 '/assets'
config.assets.prefix = '/asset-files'
```

### config/environments/development.rb

刪除 RJS 設定 `config.action_view.debug_rjs = true`。

如果您啟用了資源管道，請添加以下設定：

```ruby
# 不壓縮資源
config.assets.compress = false

# 展開載入資源的行
config.assets.debug = true
```

### config/environments/production.rb

同樣地，下面的大部分更改是針對資源管道的。您可以在[資源管道](asset_pipeline.html)指南中了解更多相關資訊。
```ruby
# 壓縮 JavaScript 和 CSS
config.assets.compress = true

# 如果編譯過的資源遺失，不要回退到資源管道
config.assets.compile = false

# 生成資源 URL 的摘要
config.assets.digest = true

# 默認為 Rails.root.join("public/assets")
# config.assets.manifest = YOUR_PATH

# 預編譯其他資源 (application.js、application.css，以及所有非 JS/CSS 的資源已經添加)
# config.assets.precompile += %w( admin.js admin.css )

# 強制所有訪問使用 SSL，使用 Strict-Transport-Security，並使用安全的 cookies
# config.force_ssl = true
```

### config/environments/test.rb

您可以通過以下方式將這些內容添加到測試環境中，以幫助測試性能：

```ruby
# 為測試配置靜態資源服務器，並使用 Cache-Control 進行性能優化
config.public_file_server.enabled = true
config.public_file_server.headers = {
  'Cache-Control' => 'public, max-age=3600'
}
```

### config/initializers/wrap_parameters.rb

如果您希望將參數封裝成嵌套的哈希，請添加此文件並包含以下內容。這在新應用程序中默認啟用。

```ruby
# 當您修改此文件時，請確保重新啟動服務器。
# 此文件包含 ActionController::ParamsWrapper 的設置，默認情況下啟用。

# 啟用 JSON 的參數封裝。您可以通過將 :format 設置為空數組來禁用此功能。
ActiveSupport.on_load(:action_controller) do
  wrap_parameters format: [:json]
end

# 默認情況下禁用 JSON 中的根元素。
ActiveSupport.on_load(:active_record) do
  self.include_root_in_json = false
end
```

### config/initializers/session_store.rb

您需要將會話密鑰更改為新的值，或者刪除所有會話：

```ruby
# 在 config/initializers/session_store.rb 中
AppName::Application.config.session_store :cookie_store, key: 'SOMETHINGNEW'
```

或者

```bash
$ bin/rake db:sessions:clear
```

### 從視圖中的資源輔助函數引用中刪除 :cache 和 :concat 選項

* 使用資源管道，不再使用 :cache 和 :concat 選項，從視圖中刪除這些選項。
[`config.cache_classes`]: configuring.html#config-cache-classes
[`config.autoload_once_paths`]: configuring.html#config-autoload-once-paths
[`config.force_ssl`]: configuring.html#config-force-ssl
[`config.ssl_options`]: configuring.html#config-ssl-options
[`config.add_autoload_paths_to_load_path`]: configuring.html#config-add-autoload-paths-to-load-path
[`config.active_storage.replace_on_assign_to_many`]: configuring.html#config-active-storage-replace-on-assign-to-many
[`config.exceptions_app`]: configuring.html#config-exceptions-app
[`config.action_mailer.perform_caching`]: configuring.html#config-action-mailer-perform-caching
[`config.assets.precompile`]: configuring.html#config-assets-precompile
[`config.assets.js_compressor`]: configuring.html#config-assets-js-compressor
