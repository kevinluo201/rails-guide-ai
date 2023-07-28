**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: b95e1fead49349e056e5faed88aa5760
升级Ruby on Rails
=======================

本指南提供了升级应用程序到较新版本的Ruby on Rails时应遵循的步骤。这些步骤也可以在各个发布指南中找到。

--------------------------------------------------------------------------------

一般建议
--------------

在尝试升级现有应用程序之前，您应该确保有充分的理由进行升级。您需要平衡几个因素：对新功能的需求、对旧代码支持的难度增加以及可用的时间和技能等。

### 测试覆盖率

确保在开始升级之前，您的应用程序仍然正常工作的最佳方法是在开始过程之前具备良好的测试覆盖率。如果您没有自动化测试来覆盖应用程序的大部分功能，您将需要花时间手动测试所有已更改的部分。在Rails升级的情况下，这将意味着应用程序中的每个功能都需要测试。在开始升级之前，请确保您的测试覆盖率良好。

### Ruby版本

Rails通常在发布时与最新发布的Ruby版本保持接近：

* Rails 7 需要 Ruby 2.7.0 或更高版本。
* Rails 6 需要 Ruby 2.5.0 或更高版本。
* Rails 5 需要 Ruby 2.2.2 或更高版本。

最好分别升级Ruby和Rails。首先升级到最新的Ruby版本，然后再升级Rails。

### 升级过程

更改Rails版本时，最好慢慢进行，一次只升级一个次要版本，以充分利用弃用警告。Rails版本号的格式为主版本.次要版本.修订版本。主版本和次要版本允许对公共API进行更改，因此这可能会导致应用程序出错。修订版本仅包括错误修复，不会更改任何公共API。

该过程应按照以下步骤进行：

1. 编写测试并确保测试通过。
2. 在当前版本之后移动到最新的修订版本。
3. 修复测试和弃用的功能。
4. 移动到下一个次要版本的最新修订版本。

重复此过程，直到达到目标Rails版本。

#### 在版本之间移动

要在版本之间移动：

1. 在`Gemfile`中更改Rails版本号并运行`bundle update`。
2. 在`package.json`中更改Rails JavaScript包的版本并运行`yarn install`（如果使用Webpacker）。
3. 运行[更新任务](#the-update-task)。
4. 运行您的测试。

您可以在[此处](https://rubygems.org/gems/rails/versions)找到所有已发布的Rails gem的列表。

### 更新任务

Rails提供了`rails app:update`命令。在`Gemfile`中更新Rails版本后，运行此命令。这将在交互会话中帮助您创建新文件并更改旧文件。

```bash
$ bin/rails app:update
       exist  config
    conflict  config/application.rb
Overwrite /myapp/config/application.rb? (enter "h" for help) [Ynaqdh]
       force  config/application.rb
      create  config/initializers/new_framework_defaults_7_0.rb
...
```

不要忘记查看差异，以查看是否有任何意外更改。

### 配置框架默认值

新的Rails版本可能与先前版本具有不同的配置默认值。但是，在按照上述步骤进行操作后，您的应用程序仍将使用*先前*Rails版本的配置默认值运行。这是因为`config/application.rb`中的`config.load_defaults`的值尚未更改。

为了让您逐个升级到新的默认值，更新任务已经创建了一个名为`config/initializers/new_framework_defaults_X.Y.rb`的文件（其中X.Y是所需的Rails版本）。您应该取消注释文件中的新配置默认值，这可以逐步在多个部署中完成。一旦您的应用程序准备好使用新的默认值运行，您可以删除此文件并切换`config.load_defaults`的值。

从Rails 7.0升级到Rails 7.1
-------------------------------------

有关Rails 7.1所做更改的更多信息，请参阅[发布说明](7_1_release_notes.html)。

### 自动加载路径不再在加载路径中

从Rails 7.1开始，由自动加载程序管理的所有路径将不再添加到`$LOAD_PATH`中。这意味着无法使用手动的`require`调用加载它们，而是可以直接引用类或模块。

减少`$LOAD_PATH`的大小可以加快未使用`bootsnap`的应用程序的`require`调用，并减小其他应用程序的`bootsnap`缓存的大小。
### `ActiveStorage::BaseController`不再包含流处理关注点

继承自`ActiveStorage::BaseController`的应用控制器，如果使用流处理来实现自定义文件服务逻辑，现在必须显式地包含`ActiveStorage::Streaming`模块。

### `MemCacheStore`和`RedisCacheStore`现在默认使用连接池

`connection_pool` gem已作为`activesupport` gem的依赖项添加，
`MemCacheStore`和`RedisCacheStore`现在默认使用连接池。

如果您不想使用连接池，请在配置缓存存储时将`:pool`选项设置为`false`：

```ruby
config.cache_store = :mem_cache_store, "cache.example.com", pool: false
```

有关更多信息，请参阅[Rails缓存指南](https://guides.rubyonrails.org/v7.1/caching_with_rails.html#connection-pool-options)。

### `SQLite3Adapter`现在配置为在严格字符串模式下使用

使用严格字符串模式会禁用双引号字符串文字。

SQLite在处理双引号字符串文字时有一些怪异之处。
它首先尝试将双引号字符串视为标识符名称，但如果它们不存在，则将其视为字符串文字。因此，拼写错误可能会悄悄地被忽略。
例如，可以为不存在的列创建索引。
有关详细信息，请参阅[SQLite文档](https://www.sqlite.org/quirks.html#double_quoted_string_literals_are_accepted)。

如果您不想在严格模式下使用`SQLite3Adapter`，可以禁用此行为：

```ruby
# config/application.rb
config.active_record.sqlite3_adapter_strict_strings_by_default = false
```

### `ActionMailer::Preview`支持多个预览路径

选项`config.action_mailer.preview_path`已弃用，改为使用`config.action_mailer.preview_paths`。将路径附加到此配置选项将导致在搜索邮件预览时使用这些路径。

```ruby
config.action_mailer.preview_paths << "#{Rails.root}/lib/mailer_previews"
```

### `config.i18n.raise_on_missing_translations = true`现在在任何缺失的翻译上都会引发异常。

以前，它只会在视图或控制器中调用时引发异常。现在，只要`I18n.t`提供了一个无法识别的键，它就会引发异常。

```ruby
# with config.i18n.raise_on_missing_translations = true

# in a view or controller:
t("missing.key") # 在7.0中引发异常，在7.1中引发异常
I18n.t("missing.key") # 在7.0中不引发异常，在7.1中引发异常

# anywhere:
I18n.t("missing.key") # 在7.0中不引发异常，在7.1中引发异常
```

如果您不希望出现这种行为，可以将`config.i18n.raise_on_missing_translations`设置为`false`：

```ruby
# with config.i18n.raise_on_missing_translations = false

# in a view or controller:
t("missing.key") # 在7.0中不引发异常，在7.1中不引发异常
I18n.t("missing.key") # 在7.0中不引发异常，在7.1中不引发异常

# anywhere:
I18n.t("missing.key") # 在7.0中不引发异常，在7.1中不引发异常
```

或者，您可以自定义`I18n.exception_handler`。
有关更多信息，请参阅[i18n指南](https://guides.rubyonrails.org/v7.1/i18n.html#using-different-exception-handlers)。

从Rails 6.1升级到Rails 7.0
-------------------------------------

有关升级到Rails 7.0的更多信息，请参阅[发布说明](7_0_release_notes.html)。

### `ActionView::Helpers::UrlHelper#button_to`的行为已更改

从Rails 7.0开始，如果使用持久化的Active Record对象来构建按钮URL，`button_to`将呈现带有`patch` HTTP动词的`form`标签。
要保持当前行为，请考虑显式传递`method:`选项：

```diff
-button_to("Do a POST", [:my_custom_post_action_on_workshop, Workshop.find(1)])
+button_to("Do a POST", [:my_custom_post_action_on_workshop, Workshop.find(1)], method: :post)
```

或者使用助手构建URL：

```diff
-button_to("Do a POST", [:my_custom_post_action_on_workshop, Workshop.find(1)])
+button_to("Do a POST", my_custom_post_action_on_workshop_workshop_path(Workshop.find(1)))
```

### Spring

如果您的应用程序使用Spring，需要升级到至少3.0.0版本。否则，您将会得到以下错误：

```
undefined method `mechanism=' for ActiveSupport::Dependencies:Module
```

此外，请确保在`config/environments/test.rb`中将[`config.cache_classes`][]设置为`false`。


### Sprockets现在是可选的依赖项

`rails` gem不再依赖于`sprockets-rails`。如果您的应用程序仍然需要使用Sprockets，请确保将`sprockets-rails`添加到Gemfile中。

```ruby
gem "sprockets-rails"
```

### 应用程序需要在`zeitwerk`模式下运行

仍在运行`classic`模式的应用程序必须切换到`zeitwerk`模式。请查看[Classic to Zeitwerk HOWTO](https://guides.rubyonrails.org/v7.0/classic_to_zeitwerk_howto.html)指南以获取详细信息。

### 删除了设置器`config.autoloader=`

在Rails 7中，没有配置点来设置自动加载模式，已删除`config.autoloader=`。如果您将其设置为`:zeitwerk`，只需将其删除。

### 删除了`ActiveSupport::Dependencies`私有API

已删除`ActiveSupport::Dependencies`的私有API。其中包括`hook!`、`unhook!`、`depend_on`、`require_or_load`、`mechanism`等方法。

以下是一些亮点：

* 如果您使用了`ActiveSupport::Dependencies.constantize`或`ActiveSupport::Dependencies.safe_constantize`，只需将它们更改为`String#constantize`或`String#safe_constantize`。

  ```ruby
  ActiveSupport::Dependencies.constantize("User") # 不再可行
  "User".constantize # 👍
  ```

* 任何使用`ActiveSupport::Dependencies.mechanism`的地方，无论是读取器还是写入器，都必须根据需要访问`config.cache_classes`进行替换。

* 如果要跟踪自动加载器的活动，不再提供`ActiveSupport::Dependencies.verbose=`，只需在`config/application.rb`中添加`Rails.autoloaders.log!`。


辅助的内部类或模块也被删除了，例如 `ActiveSupport::Dependencies::Reference`、`ActiveSupport::Dependencies::Blamable` 等等。

### 初始化期间的自动加载

在初始化期间自动加载可重载的常量的应用程序（不在 `to_prepare` 块中）会导致这些常量被卸载，并在 Rails 6.0 中发出此警告：

```
DEPRECATION WARNING: Initialization autoloaded the constant ....

Being able to do this is deprecated. Autoloading during initialization is going
to be an error condition in future versions of Rails.

...
```

如果您仍然在日志中收到此警告，请在 [自动加载指南](https://guides.rubyonrails.org/v7.0/autoloading_and_reloading_constants.html#autoloading-when-the-application-boots) 中检查应用程序启动时的自动加载部分。否则，在 Rails 7 中会出现 `NameError`。

### 配置 `config.autoload_once_paths` 的能力

[`config.autoload_once_paths`][] 可以在 `config/application.rb` 中定义的应用程序类的主体中设置，也可以在 `config/environments/*` 中的环境配置中设置。

同样，引擎可以在引擎类的类主体中或在环境的配置中配置该集合。

之后，该集合将被冻结，并且您可以从这些路径进行自动加载。特别是在初始化期间，您可以从这里进行自动加载。它们由 `Rails.autoloaders.once` 自动加载器管理，它不重新加载，只进行自动加载/急切加载。

如果您在环境配置已处理之后配置了此设置并且收到 `FrozenError`，请将代码移动到其他位置。

### `ActionDispatch::Request#content_type` 现在返回原样的 Content-Type 标头。

以前，`ActionDispatch::Request#content_type` 返回的值不包含字符集部分。
这个行为已更改为返回原样包含字符集部分的 Content-Type 标头。

如果您只想获取 MIME 类型，请改用 `ActionDispatch::Request#media_type`。

之前：

```ruby
request = ActionDispatch::Request.new("CONTENT_TYPE" => "text/csv; header=present; charset=utf-16", "REQUEST_METHOD" => "GET")
request.content_type #=> "text/csv"
```

之后：

```ruby
request = ActionDispatch::Request.new("Content-Type" => "text/csv; header=present; charset=utf-16", "REQUEST_METHOD" => "GET")
request.content_type #=> "text/csv; header=present; charset=utf-16"
request.media_type   #=> "text/csv"
```

### 密钥生成器摘要类更改需要进行 cookie 旋转

密钥生成器的默认摘要类从 SHA1 更改为 SHA256。
这会影响到 Rails 生成的任何加密消息，包括加密的 cookie。

为了能够使用旧的摘要类读取消息，需要注册一个旋转器。如果不这样做，升级过程中可能会导致用户的会话失效。

以下是用于加密和签名 cookie 的旋转器示例。

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

### ActiveSupport::Digest 的摘要类更改为 SHA256

ActiveSupport::Digest 的默认摘要类从 SHA1 更改为 SHA256。
这会对诸如 Etag 的内容产生影响，并且还会更改缓存键。
更改这些键可能会对缓存命中率产生影响，因此在升级到新的哈希算法时要小心并注意这一点。

### 新的 ActiveSupport::Cache 序列化格式

引入了一种更快、更紧凑的序列化格式。

要启用它，您必须设置 `config.active_support.cache_format_version = 7.0`：

```ruby
# config/application.rb

config.load_defaults 6.1
config.active_support.cache_format_version = 7.0
```

或者简单地：

```ruby
# config/application.rb

config.load_defaults 7.0
```

但是，Rails 6.1 应用程序无法读取这种新的序列化格式，
因此为了确保无缝升级，您必须首先使用 `config.active_support.cache_format_version = 6.1` 部署您的 Rails 7.0 升级，
然后只有在所有 Rails 进程都已更新之后，您才可以设置 `config.active_support.cache_format_version = 7.0`。

Rails 7.0 能够读取这两种格式，因此在升级过程中缓存不会失效。

### Active Storage 视频预览图生成

视频预览图生成现在使用 FFmpeg 的场景变化检测来生成更有意义的预览图像。以前会使用视频的第一帧，如果视频从黑色淡入，则会出现问题。此更改需要 FFmpeg v3.4+。

### Active Storage 默认的变体处理器更改为 `:vips`

对于新的应用程序，图像转换将使用 libvips 而不是 ImageMagick。这将减少生成变体所需的时间，以及 CPU 和内存的使用量，提高依赖 Active Storage 为其图像提供服务的应用程序的响应时间。

`:mini_magick` 选项不会被弃用，因此继续使用它是可以的。

要将现有应用程序迁移到 libvips，请设置：
```ruby
Rails.application.config.active_storage.variant_processor = :vips
```

然后，您需要将现有的图像转换代码更改为`image_processing`宏，并使用libvips的选项替换ImageMagick的选项。

#### 使用`resize_to_limit`替换`resize`

```diff
- variant(resize: "100x")
+ variant(resize_to_limit: [100, nil])
```

如果您不这样做，当您切换到vips时，您将看到此错误：`no implicit conversion to float from string`。

#### 裁剪时使用数组

```diff
- variant(crop: "1920x1080+0+0")
+ variant(crop: [0, 0, 1920, 1080])
```

如果您在迁移到vips时不这样做，您将看到以下错误：`unable to call crop: you supplied 2 arguments, but operation needs 5`。

#### 限制裁剪值：

与ImageMagick相比，Vips在裁剪时更严格：

1. 如果`x`和/或`y`是负值，它将不会进行裁剪。例如：`[-10, -10, 100, 100]`
2. 如果位置（`x`或`y`）加上裁剪尺寸（`width`，`height`）大于图像，它将不会进行裁剪。例如：一个125x125的图像和一个裁剪区域为`[50, 50, 100, 100]`

如果您在迁移到vips时不这样做，您将看到以下错误：`extract_area: bad extract area`。

#### 调整`resize_and_pad`使用的背景颜色

Vips使用黑色作为`resize_and_pad`的默认背景颜色，而不是像ImageMagick一样使用白色。通过使用`background`选项来修复：

```diff
- variant(resize_and_pad: [300, 300])
+ variant(resize_and_pad: [300, 300, background: [255]])
```

#### 移除基于EXIF的旋转

Vips在处理变体时会使用EXIF值自动旋转图像。如果您以前使用ImageMagick存储用户上传照片的旋转值以应用旋转，则必须停止这样做：

```diff
- variant(format: :jpg, rotate: rotation_value)
+ variant(format: :jpg)
```

#### 使用`colourspace`替换`monochrome`

Vips使用不同的选项来生成单色图像：

```diff
- variant(monochrome: true)
+ variant(colourspace: "b-w")
```

#### 切换到libvips选项以压缩图像

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

#### 部署到生产环境

Active Storage将需要执行的转换列表编码到图像的URL中。如果您的应用程序缓存这些URL，当您将新代码部署到生产环境后，图像将无法显示。因此，您必须手动使受影响的缓存键无效。

例如，如果您在视图中有以下内容：

```erb
<% @products.each do |product| %>
  <% cache product do %>
    <%= image_tag product.cover_photo.variant(resize: "200x") %>
  <% end %>
<% end %>
```

您可以通过触发产品或更改缓存键来使缓存无效：

```erb
<% @products.each do |product| %>
  <% cache ["v2", product] do %>
    <%= image_tag product.cover_photo.variant(resize_to_limit: [200, nil]) %>
  <% end %>
<% end %>
```

### Rails版本现在包含在Active Record模式转储中

Rails 7.0更改了某些列类型的默认值。为了避免从6.1升级到7.0的应用程序使用新的7.0默认值加载当前模式，Rails现在在模式转储中包含框架的版本。

在首次在Rails 7.0中加载模式之前，请确保运行`rails app:update`以确保模式的版本包含在模式转储中。

模式文件将如下所示：

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
注意：在Rails 7.0中首次转储模式时，您将看到该文件的许多更改，包括一些列信息。请确保查看新的模式文件内容并将其提交到您的存储库中。

从Rails 6.0升级到Rails 6.1
-------------------------------------

有关Rails 6.1所做更改的更多信息，请参阅[发布说明](6_1_release_notes.html)。

### `Rails.application.config_for`返回值不再支持使用字符串键访问。

给定以下配置文件：

```yaml
# config/example.yml
development:
  options:
    key: value
```

```ruby
Rails.application.config_for(:example).options
```

以前，这将返回一个哈希，您可以使用字符串键访问其中的值。这在6.0中已被弃用，现在不再起作用。

如果您仍然希望使用字符串键访问值，可以在`config_for`的返回值上调用`with_indifferent_access`，例如：

```ruby
Rails.application.config_for(:example).with_indifferent_access.dig('options', 'key')
```

### 使用`respond_to#any`时响应的Content-Type

响应中返回的Content-Type标头可能与Rails 6.0返回的不同，特别是如果您的应用程序使用`respond_to { |format| format.any }`。现在，Content-Type将基于给定的块而不是请求的格式。

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

以前的行为是返回一个`text/csv`响应的Content-Type，这是不准确的，因为正在呈现一个JSON响应。当前行为正确返回一个`application/json`响应的Content-Type。

如果您的应用程序依赖于先前的错误行为，建议您指定您的操作接受的格式，例如：

```ruby
format.any(:xml, :json) { render request.format.to_sym => @people }
```

### `ActiveSupport::Callbacks#halted_callback_hook`现在接收第二个参数

Active Support允许您在回调停止链时重写`halted_callback_hook`。此方法现在接收第二个参数，即被停止的回调的名称。如果您有覆盖此方法的类，请确保它接受两个参数。请注意，这是一个没有先前弃用周期的破坏性更改（出于性能原因）。

示例：

```ruby
class Book < ApplicationRecord
  before_save { throw(:abort) }
  before_create { throw(:abort) }

  def halted_callback_hook(filter, callback_name) # => 此方法现在接受2个参数而不是1个
    Rails.logger.info("无法#{callback_name}图书")
  end
end
```

### 控制器中的`helper`类方法使用`String#constantize`

在Rails 6.1之前的概念上，

```ruby
helper "foo/bar"
```

结果是

```ruby
require_dependency "foo/bar_helper"
module_name = "foo/bar_helper".camelize
module_name.constantize
```

现在它改为：

```ruby
prefix = "foo/bar".camelize
"#{prefix}Helper".constantize
```

对于大多数应用程序来说，此更改是向后兼容的，您不需要做任何操作。

但从技术上讲，控制器可以配置`helpers_path`以指向`$LOAD_PATH`中不在自动加载路径中的目录。这种用法不再默认支持。如果助手模块无法自动加载，应用程序需要在调用`helper`之前加载它。

### 从HTTP重定向到HTTPS现在使用308 HTTP状态码

在将非GET/HEAD请求从HTTP重定向到HTTPS时，`ActionDispatch::SSL`中使用的默认HTTP状态码已更改为`308`，如https://tools.ietf.org/html/rfc7538中定义。

### Active Storage现在需要图像处理

在Active Storage中处理变体时，现在需要捆绑[image_processing gem](https://github.com/janko/image_processing)而不是直接使用`mini_magick`。 Image Processing默认配置为在幕后使用`mini_magick`，因此升级的最简单方法是将`mini_magick` gem替换为`image_processing` gem，并确保删除对`combine_options`的显式使用，因为它不再需要。

为了提高可读性，您可能希望将原始的`resize`调用更改为`image_processing`宏。例如，不再使用：

```ruby
video.preview(resize: "100x100")
video.preview(resize: "100x100>")
video.preview(resize: "100x100^")
```

而是分别使用：

```ruby
video.preview(resize_to_fit: [100, 100])
video.preview(resize_to_limit: [100, 100])
video.preview(resize_to_fill: [100, 100])
```

### 新的`ActiveModel::Error`类

错误现在是新的`ActiveModel::Error`类的实例，API有所更改。根据您如何操作错误，其中一些更改可能会引发错误，而其他更改将打印弃用警告以在Rails 7.0中修复。

有关此更改的更多信息以及有关API更改的详细信息，请参阅[此PR](https://github.com/rails/rails/pull/32313)。

从Rails 5.2升级到Rails 6.0
-------------------------------------

有关Rails 6.0所做更改的更多信息，请参阅[发布说明](6_0_release_notes.html)。

### 使用Webpacker
[Webpacker](https://github.com/rails/webpacker) 是Rails 6的默认JavaScript编译器。但是，如果您正在升级应用程序，则默认情况下不会激活它。
如果您想使用Webpacker，请在Gemfile中包含它并安装它：

```ruby
gem "webpacker"
```

```bash
$ bin/rails webpacker:install
```

### 强制SSL

控制器上的`force_ssl`方法已被弃用，并将在Rails 6.1中删除。建议您启用[`config.force_ssl`][]以在整个应用程序中强制使用HTTPS连接。如果您需要豁免某些端点的重定向，可以使用[`config.ssl_options`][]来配置该行为。

### 目的和过期元数据现在嵌入在签名和加密的cookie中，以增加安全性

为了提高安全性，Rails将目的和过期元数据嵌入到加密或签名cookie的值中。

这样，Rails可以防止攻击者尝试复制cookie的签名/加密值并将其用作另一个cookie的值。

这些新的嵌入元数据使这些cookie与早于6.0版本的Rails不兼容。

如果您需要Rails 5.2及更早版本读取您的cookie，或者您仍在验证您的6.0部署并希望能够回滚，请将`Rails.application.config.action_dispatch.use_cookies_with_metadata`设置为`false`。

### 所有npm包已移至`@rails`范围

如果您以前通过npm/yarn加载`actioncable`、`activestorage`或`rails-ujs`包，您必须在将它们升级到`6.0.0`之前更新这些依赖项的名称：

```
actioncable   → @rails/actioncable
activestorage → @rails/activestorage
rails-ujs     → @rails/ujs
```

### Action Cable JavaScript API更改

Action Cable JavaScript包已从CoffeeScript转换为ES2015，并且我们现在在npm分发中发布源代码。

此版本对Action Cable JavaScript API的可选部分进行了一些重大更改：

- WebSocket适配器和日志记录器适配器的配置已从`ActionCable`的属性移动到`ActionCable.adapters`的属性。如果您正在配置这些适配器，您需要进行以下更改：

    ```diff
    -    ActionCable.WebSocket = MyWebSocket
    +    ActionCable.adapters.WebSocket = MyWebSocket
    ```

    ```diff
    -    ActionCable.logger = myLogger
    +    ActionCable.adapters.logger = myLogger
    ```

- `ActionCable.startDebugging()`和`ActionCable.stopDebugging()`方法已被移除，并用属性`ActionCable.logger.enabled`替换。如果您正在使用这些方法，您需要进行以下更改：

    ```diff
    -    ActionCable.startDebugging()
    +    ActionCable.logger.enabled = true
    ```

    ```diff
    -    ActionCable.stopDebugging()
    +    ActionCable.logger.enabled = false
    ```

### `ActionDispatch::Response#content_type`现在返回不经修改的Content-Type头

以前，`ActionDispatch::Response#content_type`的返回值不包含字符集部分。
这个行为已经改变，现在包括之前省略的字符集部分。

如果您只想要MIME类型，请改用`ActionDispatch::Response#media_type`。

之前：

```ruby
resp = ActionDispatch::Response.new(200, "Content-Type" => "text/csv; header=present; charset=utf-16")
resp.content_type #=> "text/csv; header=present"
```

之后：

```ruby
resp = ActionDispatch::Response.new(200, "Content-Type" => "text/csv; header=present; charset=utf-16")
resp.content_type #=> "text/csv; header=present; charset=utf-16"
resp.media_type   #=> "text/csv"
```

### 新的`config.hosts`设置

Rails现在有一个新的`config.hosts`设置，用于安全目的。该设置在开发环境中默认为`localhost`。如果您在开发中使用其他域名，您需要像这样允许它们：

```ruby
# config/environments/development.rb

config.hosts << 'dev.myapp.com'
config.hosts << /[a-z0-9-]+\.myapp\.com/ # 可选地，也可以使用正则表达式
```

对于其他环境，默认情况下`config.hosts`为空，这意味着Rails不会验证主机。如果您想在生产环境中验证它，可以选择添加它们。

### 自动加载

Rails 6的默认配置

```ruby
# config/application.rb

config.load_defaults 6.0
```

在CRuby上启用了`zeitwerk`自动加载模式。在这种模式下，自动加载、重新加载和急切加载由[Zeitwerk](https://github.com/fxn/zeitwerk)管理。

如果您使用的是以前版本的Rails的默认值，您可以这样启用zeitwerk：

```ruby
# config/application.rb

config.autoloader = :zeitwerk
```

#### 公共API

一般来说，应用程序不需要直接使用Zeitwerk的API。Rails根据现有的约定设置事物：`config.autoload_paths`、`config.cache_classes`等。

虽然应用程序应该遵守该接口，但实际的Zeitwerk加载器对象可以通过以下方式访问：

```ruby
Rails.autoloaders.main
```

如果您需要预加载单表继承（STI）类或配置自定义的inflector，这可能会很方便。

#### 项目结构

如果正在升级的应用程序正确地自动加载，项目结构应该已经基本兼容。

然而，`classic`模式从缺失的常量名（`underscore`）推断文件名，而`zeitwerk`模式从文件名推断常量名（`camelize`）。这些辅助函数并不总是彼此的逆操作，特别是如果涉及首字母缩略词。例如，`"FOO".underscore`是`"foo"`，但`"foo".camelize`是`"Foo"`，而不是`"FOO"`。
可以使用`zeitwerk:check`任务来检查兼容性：

```bash
$ bin/rails zeitwerk:check
请稍等，我正在加载应用程序。
一切正常！
```

#### require_dependency

已经消除了`require_dependency`的所有已知用例，您应该在项目中使用grep命令并删除它们。

如果您的应用程序使用单表继承，请参阅自动加载和重新加载常量（Zeitwerk模式）指南中的[单表继承部分](autoloading_and_reloading_constants.html#single-table-inheritance)。

#### 类和模块定义中的限定名称

现在您可以在类和模块定义中稳健地使用常量路径：

```ruby
# 此类主体中的自动加载与Ruby语义现在匹配。
class Admin::UsersController < ApplicationController
  # ...
end
```

需要注意的是，根据执行顺序，经典的自动加载程序有时可以自动加载`Foo::Wadus`：

```ruby
class Foo::Bar
  Wadus
end
```

这不符合Ruby语义，因为`Foo`不在嵌套中，并且在`zeitwerk`模式下根本不起作用。如果您发现这种特殊情况，可以使用限定名称`Foo::Wadus`：

```ruby
class Foo::Bar
  Foo::Wadus
end
```

或者将`Foo`添加到嵌套中：

```ruby
module Foo
  class Bar
    Wadus
  end
end
```

#### Concerns

您可以从标准结构中自动加载和急切加载，例如：

```
app/models
app/models/concerns
```

在这种情况下，`app/models/concerns`被假定为根目录（因为它属于自动加载路径），并且被忽略为命名空间。因此，`app/models/concerns/foo.rb`应该定义`Foo`，而不是`Concerns::Foo`。

`Concerns::`命名空间在经典的自动加载程序中作为实现的副作用工作，但这实际上并不是预期的行为。使用`Concerns::`的应用程序需要将这些类和模块重命名，以便能够在`zeitwerk`模式下运行。

#### 在自动加载路径中添加`app`

某些项目希望像`app/api/base.rb`这样定义`API::Base`，并将`app`添加到自动加载路径以在`classic`模式下实现。由于Rails自动将`app`的所有子目录添加到自动加载路径中，我们有了另一种情况，其中存在嵌套的根目录，因此该设置不再起作用。与上面解释的`concerns`类似的原则。

如果要保留该结构，您需要在初始化程序中从自动加载路径中删除子目录：

```ruby
ActiveSupport::Dependencies.autoload_paths.delete("#{Rails.root}/app/api")
```

#### 自动加载的常量和显式命名空间

如果在文件中定义了命名空间，例如这里的`Hotel`：

```
app/models/hotel.rb         # 定义了Hotel。
app/models/hotel/pricing.rb # 定义了Hotel::Pricing。
```

则必须使用`class`或`module`关键字设置`Hotel`常量。例如：

```ruby
class Hotel
end
```

是正确的。

以下替代方法不起作用，例如：

```ruby
Hotel = Class.new
```

或者

```ruby
Hotel = Struct.new
```

这样的子对象，例如`Hotel::Pricing`将无法找到。

此限制仅适用于显式命名空间。不定义命名空间的类和模块可以使用这些习惯用法进行定义。

#### 一个文件，一个常量（在同一顶级）

在`classic`模式下，您可以在同一顶级定义多个常量并重新加载它们。例如，给定以下代码：

```ruby
# app/models/foo.rb

class Foo
end

class Bar
end
```

虽然无法自动加载`Bar`，但自动加载`Foo`将标记`Bar`为已自动加载。但在`zeitwerk`模式下不是这样的，您需要将`Bar`移动到它自己的文件`bar.rb`中。一个文件，一个常量。

这仅适用于与上面示例中的相同顶级的常量。内部类和模块是可以的。例如，请考虑以下代码：

```ruby
# app/models/foo.rb

class Foo
  class InnerClass
  end
end
```

如果应用程序重新加载`Foo`，它也将重新加载`Foo::InnerClass`。

#### Spring和`test`环境

如果有更改，Spring会重新加载应用程序代码。在`test`环境中，您需要启用重新加载才能使其工作：

```ruby
# config/environments/test.rb

config.cache_classes = false
```

否则，您将收到以下错误：

```
reloading is disabled because config.cache_classes is true
```

#### Bootsnap

Bootsnap的版本应至少为1.4.2。

除此之外，由于解释器中的一个错误，Bootsnap需要禁用iseq缓存，如果运行的是Ruby 2.5，请确保至少依赖于Bootsnap 1.4.4。

#### `config.add_autoload_paths_to_load_path`

新的配置点[`config.add_autoload_paths_to_load_path`][]默认为`true`，以保持向后兼容性，但允许您选择不将自动加载路径添加到`$LOAD_PATH`中。

这在大多数应用程序中是有意义的，因为您永远不应该在`app/models`中要求文件，例如，Zeitwerk只在内部使用绝对文件名。
通过选择退出，您可以优化`$LOAD_PATH`的查找（减少目录检查），并节省Bootsnap的工作和内存消耗，因为它不需要为这些目录构建索引。

#### 线程安全

在经典模式下，常量自动加载不是线程安全的，尽管Rails已经放置了锁定机制，例如在启用自动加载时使Web请求线程安全，这在开发环境中很常见。

在`zeitwerk`模式下，常量自动加载是线程安全的。例如，您现在可以在由`runner`命令执行的多线程脚本中自动加载。

#### `config.autoload_paths`中的通配符

注意配置如下的情况：

```ruby
config.autoload_paths += Dir["#{config.root}/lib/**/"]
```

`config.autoload_paths`的每个元素都应该代表顶级命名空间（`Object`），并且它们不能嵌套（除了上面解释的`concerns`目录）。

要修复这个问题，只需移除通配符：

```ruby
config.autoload_paths << "#{config.root}/lib"
```

#### 预加载和自动加载的一致性

在`classic`模式下，如果`app/models/foo.rb`定义了`Bar`，您将无法自动加载该文件，但是预加载将工作，因为它会盲目递归加载文件。如果您首先进行预加载测试，然后执行自动加载，可能会导致错误。

在`zeitwerk`模式下，这两种加载模式是一致的，它们在相同的文件中失败和出错。

#### 如何在Rails 6中使用经典自动加载器

应用程序可以加载Rails 6的默认设置，并通过设置`config.autoloader`来使用经典自动加载器，如下所示：

```ruby
# config/application.rb

config.load_defaults 6.0
config.autoloader = :classic
```

在Rails 6应用程序中使用经典自动加载器时，建议在开发环境中将并发级别设置为1，用于Web服务器和后台处理器，以解决线程安全问题。

### Active Storage分配行为更改

使用Rails 5.2的配置默认值，对于使用`has_many_attached`声明的附件集合进行分配会追加新文件：

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

使用Rails 6.0的配置默认值，对于使用`has_many_attached`声明的附件集合进行分配会替换现有文件，而不是追加到它们后面。这与将值分配给集合关联时的Active Record行为相匹配：

```ruby
user.highlights.attach(filename: "funky.jpg", ...)
user.highlights.count # => 1

blob = ActiveStorage::Blob.create_after_upload!(filename: "town.jpg", ...)
user.update!(highlights: [ blob ])

user.highlights.count # => 1
user.highlights.first.filename # => "town.jpg"
```

`#attach`可以用于添加新的附件而不删除现有的附件：

```ruby
blob = ActiveStorage::Blob.create_after_upload!(filename: "town.jpg", ...)
user.highlights.attach(blob)

user.highlights.count # => 2
user.highlights.first.filename # => "funky.jpg"
user.highlights.second.filename # => "town.jpg"
```

现有的应用程序可以通过将[`config.active_storage.replace_on_assign_to_many`][]设置为`true`来选择使用这种新行为。旧行为将在Rails 7.0中弃用，并在Rails 7.1中删除。

### 自定义异常处理应用程序

无效的`Accept`或`Content-Type`请求头现在会引发异常。默认的[`config.exceptions_app`][]专门处理该错误并进行补偿。自定义异常应用程序也需要处理该错误，否则这样的请求将导致Rails使用回退的异常应用程序，返回`500 Internal Server Error`。

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

为了提高安全性，Rails现在还将过期信息嵌入在加密或签名cookie的值中。

这个新的嵌入信息使得这些cookie与早于5.2版本的Rails不兼容。

如果您需要让您的cookie被5.1和更早版本读取，或者您仍在验证您的5.2部署并希望允许回滚，请将`Rails.application.config.action_dispatch.use_authenticated_cookie_encryption`设置为`false`。

从Rails 5.0升级到Rails 5.1
-------------------------------------

有关Rails 5.1所做更改的更多信息，请参阅[发布说明](5_1_release_notes.html)。

### 顶级`HashWithIndifferentAccess`已被软弃用

如果您的应用程序使用顶级`HashWithIndifferentAccess`类，您应该逐步将您的代码改为使用`ActiveSupport::HashWithIndifferentAccess`。
它只是软弃用，这意味着您的代码目前不会出错，也不会显示任何弃用警告，但是这个常量将来会被删除。

此外，如果您有非常旧的YAML文档，其中包含这些对象的转储，您可能需要重新加载和转储它们，以确保它们引用正确的常量，并且加载它们不会在将来出错。

### `application.secrets`现在加载所有键为符号

如果您的应用程序将嵌套配置存储在`config/secrets.yml`中，现在所有键都将作为符号加载，因此应更改使用字符串的访问方式。

从：

```ruby
Rails.application.secrets[:smtp_settings]["address"]
```

到：

```ruby
Rails.application.secrets[:smtp_settings][:address]
```

### 删除了`render`中对`：text`和`：nothing`的弃用支持

如果您的控制器使用`render :text`，它们将不再起作用。使用MIME类型为`text/plain`的新方法来呈现文本是使用`render :plain`。

类似地，已删除`render :nothing`，您应该使用`head`方法发送仅包含头部的响应。例如，`head :ok`发送一个没有正文的200响应。

### 删除了对`redirect_to :back`的弃用支持

在Rails 5.0中，`redirect_to :back`已被弃用。在Rails 5.1中，它被完全删除。

作为替代，使用`redirect_back`。重要的是要注意，`redirect_back`还接受一个`fallback_location`选项，该选项将在`HTTP_REFERER`丢失的情况下使用。

```ruby
redirect_back(fallback_location: root_path)
```

从Rails 4.2升级到Rails 5.0
-------------------------------------

有关Rails 5.0所做更改的更多信息，请参阅[发布说明](5_0_release_notes.html)。

### 需要Ruby 2.2.2+

从Ruby on Rails 5.0开始，只支持Ruby 2.2.2+版本。在继续之前，请确保您使用的是Ruby 2.2.2版本或更高版本。

### Active Record模型现在默认继承自ApplicationRecord

在Rails 4.2中，Active Record模型继承自`ActiveRecord::Base`。在Rails 5.0中，所有模型都继承自`ApplicationRecord`。

`ApplicationRecord`是所有应用程序模型的新超类，类似于应用程序控制器继承`ApplicationController`而不是`ActionController::Base`。这为应用程序提供了一个单一的位置来配置应用程序范围的模型行为。

从Rails 4.2升级到Rails 5.0时，您需要在`app/models/`中创建一个`application_record.rb`文件，并添加以下内容：

```ruby
class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true
end
```

然后确保所有模型都继承自它。

### 通过`throw(:abort)`停止回调链

在Rails 4.2中，当Active Record和Active Model中的'before'回调返回`false`时，整个回调链将停止。换句话说，连续的'before'回调不会执行，也不会执行包装在回调中的操作。

在Rails 5.0中，在Active Record或Active Model回调中返回`false`将不会导致回调链停止的副作用。相反，必须通过调用`throw(:abort)`来显式停止回调链。

当您从Rails 4.2升级到Rails 5.0时，返回`false`在这些类型的回调中仍然会停止回调链，但是您将收到有关此即将发生的更改的弃用警告。

当您准备好时，可以选择使用新的行为，并通过将以下配置添加到您的`config/application.rb`中来删除弃用警告：

```ruby
ActiveSupport.halt_callback_chains_on_return_false = false
```

请注意，此选项不会影响Active Support回调，因为它们在返回任何值时从不停止链。

有关更多详细信息，请参见[#17227](https://github.com/rails/rails/pull/17227)。

### ActiveJob现在默认继承自ApplicationJob

在Rails 4.2中，Active Job继承自`ActiveJob::Base`。在Rails 5.0中，此行为已更改为继承自`ApplicationJob`。

从Rails 4.2升级到Rails 5.0时，您需要在`app/jobs/`中创建一个`application_job.rb`文件，并添加以下内容：

```ruby
class ApplicationJob < ActiveJob::Base
end
```

然后确保所有作业类都继承自它。

有关更多详细信息，请参见[#19034](https://github.com/rails/rails/pull/19034)。

### Rails控制器测试

#### 将一些辅助方法提取到`rails-controller-testing`

`assigns`和`assert_template`已提取到`rails-controller-testing` gem中。要在控制器测试中继续使用这些方法，请将`gem 'rails-controller-testing'`添加到您的`Gemfile`中。

如果您在使用RSpec进行测试，请参阅该gem文档中所需的额外配置。

#### 上传文件时的新行为

如果您在测试中使用`ActionDispatch::Http::UploadedFile`来上传文件，则需要更改为使用类似的`Rack::Test::UploadedFile`类。
有关更多详细信息，请参见[#26404](https://github.com/rails/rails/issues/26404)。

### 在生产环境中启动后禁用自动加载

默认情况下，在生产环境中启动后禁用自动加载。

应用程序的预加载是启动过程的一部分，因此顶级常量是可以的，仍然会自动加载，无需要求它们的文件。

深层次的常量只有在运行时才会执行，例如常规方法体，也是可以的，因为在启动时已经预加载了定义它们的文件。

对于绝大多数应用程序，此更改无需采取任何操作。但在极少数情况下，如果您的应用程序在生产环境中需要自动加载，请将`Rails.application.config.enable_dependency_loading`设置为`true`。

### XML序列化

`ActiveModel::Serializers::Xml`已从Rails中提取到`activemodel-serializers-xml` gem中。要继续在应用程序中使用XML序列化，请将`gem 'activemodel-serializers-xml'`添加到您的`Gemfile`中。

### 移除对传统`mysql`数据库适配器的支持

Rails 5移除了对传统`mysql`数据库适配器的支持。大多数用户应该可以使用`mysql2`代替。当我们找到维护者时，它将转换为一个单独的gem。

### 移除对Debugger的支持

Ruby 2.2不支持`debugger`，而Rails 5需要使用Ruby 2.2。请改用`byebug`。

### 使用`bin/rails`运行任务和测试

Rails 5添加了通过`bin/rails`而不是rake运行任务和测试的功能。通常这些更改与rake并行进行，但有些是完全移植过来的。

要使用新的测试运行器，只需键入`bin/rails test`。

`rake dev:cache`现在是`bin/rails dev:cache`。

在应用程序的根目录中运行`bin/rails`以查看可用的命令列表。

### `ActionController::Parameters`不再继承自`HashWithIndifferentAccess`

在应用程序中调用`params`现在将返回一个对象而不是哈希。如果您的参数已经被允许，则不需要进行任何更改。如果您正在使用`map`和其他依赖于无论`permitted?`如何都能读取哈希的方法，则需要升级您的应用程序，先进行许可，然后转换为哈希。

```ruby
params.permit([:proceed_to, :return_to]).to_h
```

### `protect_from_forgery`现在默认为`prepend: false`

`protect_from_forgery`默认为`prepend: false`，这意味着它将在您在应用程序中调用它的位置插入到回调链中。如果您希望`protect_from_forgery`始终首先运行，则应更改应用程序以使用`protect_from_forgery prepend: true`。

### 默认模板处理程序现在是RAW

没有模板处理程序的文件将使用原始处理程序进行渲染。以前，Rails会使用ERB模板处理程序来渲染文件。

如果您不希望通过原始处理程序处理文件，则应为文件添加一个可以由适当的模板处理程序解析的扩展名。

### 添加了模板依赖项的通配符匹配

现在可以使用通配符匹配来匹配模板依赖项。例如，如果您定义模板如下：

```erb
<% # Template Dependency: recordings/threads/events/subscribers_changed %>
<% # Template Dependency: recordings/threads/events/completed %>
<% # Template Dependency: recordings/threads/events/uncompleted %>
```

现在您只需使用通配符一次调用依赖项。

```erb
<% # Template Dependency: recordings/threads/events/* %>
```

### `ActionView::Helpers::RecordTagHelper`移至外部gem（record_tag_helper）

`content_tag_for`和`div_for`已被移除，建议只使用`content_tag`。要继续使用旧方法，请将`record_tag_helper` gem添加到您的`Gemfile`中：

```ruby
gem 'record_tag_helper', '~> 1.0'
```

有关更多详细信息，请参见[#18411](https://github.com/rails/rails/pull/18411)。

### 移除对`protected_attributes` gem的支持

Rails 5不再支持`protected_attributes` gem。

### 移除对`activerecord-deprecated_finders` gem的支持

Rails 5不再支持`activerecord-deprecated_finders` gem。

### `ActiveSupport::TestCase`默认测试顺序现在是随机的

当在应用程序中运行测试时，默认顺序现在是`:random`，而不是`:sorted`。使用以下配置选项将其设置回`:sorted`。

```ruby
# config/environments/test.rb
Rails.application.configure do
  config.active_support.test_order = :sorted
end
```

### `ActionController::Live`变为`Concern`

如果您在另一个模块中包含`ActionController::Live`，而该模块又包含在您的控制器中，则还应该使用`ActiveSupport::Concern`扩展该模块。或者，您可以使用`self.included`钩子，在包含`StreamingSupport`后直接将`ActionController::Live`包含到控制器中。

这意味着如果您的应用程序以前有自己的流模块，则以下代码将在生产中中断：
```ruby
# 这是一个用于在流式控制器中使用Warden/Devise进行身份验证的解决方法。
# 参见 https://github.com/plataformatec/devise/issues/2332
# 在路由器中进行身份验证是该问题中提出的另一种解决方案
class StreamingSupport
  include ActionController::Live # 这在Rails 5的生产环境中无法工作
  # extend ActiveSupport::Concern # 除非你取消注释此行。

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

### 新的框架默认设置

#### Active Record `belongs_to` 默认要求

如果关联不存在，`belongs_to` 现在默认会触发验证错误。

可以通过 `optional: true` 关闭每个关联的默认要求。

这个默认设置将自动配置在新的应用程序中。如果现有应用程序想要添加此功能，需要在初始化程序中打开它：

```ruby
config.active_record.belongs_to_required_by_default = true
```

这个配置默认是全局的，适用于所有模型，但你可以在每个模型上覆盖它。这应该帮助你将所有模型迁移到默认要求关联的状态。

```ruby
class Book < ApplicationRecord
  # 模型还没有准备好默认要求关联

  self.belongs_to_required_by_default = false
  belongs_to(:author)
end

class Car < ApplicationRecord
  # 模型已准备好默认要求关联

  self.belongs_to_required_by_default = true
  belongs_to(:pilot)
end
```

#### 每个表单的 CSRF 令牌

Rails 5 现在支持每个表单的 CSRF 令牌，以防止 JavaScript 创建的表单的代码注入攻击。打开此选项后，应用程序中的每个表单都会有自己的 CSRF 令牌，该令牌特定于该表单的动作和方法。

```ruby
config.action_controller.per_form_csrf_tokens = true
```

#### 带来源检查的伪造保护

现在，你可以配置应用程序检查 HTTP `Origin` 标头是否应与站点的来源进行检查，作为额外的 CSRF 防御。在配置中设置以下内容为 true：

```ruby
config.action_controller.forgery_protection_origin_check = true
```

#### 允许配置 Action Mailer 队列名称

默认的邮件队列名称是 `mailers`。这个配置选项允许你全局更改队列名称。在配置中设置以下内容：

```ruby
config.action_mailer.deliver_later_queue_name = :new_queue_name
```

#### 在 Action Mailer 视图中支持片段缓存

在配置中设置 [`config.action_mailer.perform_caching`][]，以确定你的 Action Mailer 视图是否支持缓存。

```ruby
config.action_mailer.perform_caching = true
```

#### 配置 `db:structure:dump` 的输出

如果你正在使用 `schema_search_path` 或其他 PostgreSQL 扩展，你可以控制如何转储模式。设置为 `:all` 以生成所有转储，或设置为 `:schema_search_path` 以从模式搜索路径生成。

```ruby
config.active_record.dump_schemas = :all
```

#### 配置 SSL 选项以启用带子域名的 HSTS

在配置中设置以下内容以在使用子域名时启用 HSTS：

```ruby
config.ssl_options = { hsts: { subdomains: true } }
```

#### 保留接收者的时区

在使用 Ruby 2.4 时，当调用 `to_time` 时，你可以保留接收者的时区。

```ruby
ActiveSupport.to_time_preserves_timezone = false
```

### JSON/JSONB 序列化的变化

在 Rails 5.0 中，JSON/JSONB 属性的序列化和反序列化方式发生了变化。现在，如果你将一个列设置为 `String`，Active Record 将不再将该字符串转换为 `Hash`，而只会返回字符串。这不仅限于与模型交互的代码，还影响 `db/schema.rb` 中的 `:default` 列设置。建议不要将列设置为 `String`，而是传递一个 `Hash`，它将自动转换为 JSON 字符串。

从 Rails 4.1 升级到 Rails 4.2
-------------------------------------

### Web Console

首先，在你的 `Gemfile` 中的 `:development` 组中添加 `gem 'web-console', '~> 2.0'`，然后运行 `bundle install`（在升级 Rails 时它不会被包含）。安装完成后，你可以简单地在任何你想启用它的视图中添加对控制台助手的引用（例如，`<%= console %>`）。在开发环境中查看任何错误页面时，也会提供一个控制台。

### Responders

`respond_with` 和类级别的 `respond_to` 方法已经提取到 `responders` gem 中。要使用它们，只需在你的 `Gemfile` 中添加 `gem 'responders', '~> 2.0'`。在你的依赖项中没有包含 `responders` gem 的情况下，调用 `respond_with` 和类级别的 `respond_to` 将不再起作用：
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

实例级别的`respond_to`不受影响，不需要额外的gem：

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

更多详细信息请参见[#16526](https://github.com/rails/rails/pull/16526)。

### 事务回调中的错误处理

当前，Active Record会抑制在`after_rollback`或`after_commit`回调中引发的错误，并仅将其打印到日志中。在下一个版本中，这些错误将不再被抑制。相反，错误将像其他Active Record回调一样正常传播。

当您定义一个`after_rollback`或`after_commit`回调时，您将收到有关即将发生的更改的弃用警告。当您准备好时，您可以选择新的行为，并通过将以下配置添加到您的`config/application.rb`中来删除弃用警告：

```ruby
config.active_record.raise_in_transactional_callbacks = true
```

更多详细信息请参见[#14488](https://github.com/rails/rails/pull/14488)和[#16537](https://github.com/rails/rails/pull/16537)。

### 测试用例的排序

在Rails 5.0中，默认情况下，测试用例将以随机顺序执行。为了预期这个变化，Rails 4.2引入了一个新的配置选项`active_support.test_order`，用于显式指定测试的顺序。这允许您通过将选项设置为`:sorted`来锁定当前行为，或者通过将选项设置为`:random`来选择未来的行为。

如果您没有为此选项指定值，将发出弃用警告。为了避免这种情况，请将以下行添加到您的测试环境中：

```ruby
# config/environments/test.rb
Rails.application.configure do
  config.active_support.test_order = :sorted # 或者 `:random`，如果您喜欢
end
```

### 序列化属性

当使用自定义编码器（例如`serialize :metadata, JSON`）时，将`nil`赋值给序列化属性将将其保存到数据库中作为`NULL`，而不是通过编码器传递`nil`值（例如，使用`JSON`编码器时为`"null"`）。

### 生产日志级别

在Rails 5中，生产环境的默认日志级别将从`:info`更改为`:debug`。为了保留当前的默认设置，请将以下行添加到您的`production.rb`中：

```ruby
# 设置为`:info`以匹配当前的默认设置，或者设置为`:debug`以选择未来的默认设置。
config.log_level = :info
```

### Rails模板中的`after_bundle`

如果您有一个将所有文件添加到版本控制的Rails模板，它在生成binstubs之前执行，因此无法添加生成的binstubs：

```ruby
# template.rb
generate(:scaffold, "person name:string")
route "root to: 'people#index'"
rake("db:migrate")

git :init
git add: "."
git commit: %Q{ -m 'Initial commit' }
```

现在，您可以将`git`调用包装在`after_bundle`块中。它将在生成binstubs之后运行。

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

在应用程序中，对HTML片段进行消毒的新选择已经出现。古老的html-scanner方法现已正式弃用，取而代之的是[`Rails HTML Sanitizer`](https://github.com/rails/rails-html-sanitizer)。

这意味着`sanitize`、`sanitize_css`、`strip_tags`和`strip_links`方法都有了新的实现。

这个新的消毒器在内部使用[Loofah](https://github.com/flavorjones/loofah)。而Loofah又使用了Nokogiri，它包装了用C和Java编写的XML解析器，所以无论您运行哪个Ruby版本，消毒速度都应该更快。

新版本更新了`sanitize`，因此它可以接受`Loofah::Scrubber`进行强大的消毒。
[在这里可以看到一些Scrubber的示例](https://github.com/flavorjones/loofah#loofahscrubber)。

还添加了两个新的Scrubber：`PermitScrubber`和`TargetScrubber`。
阅读[gem的自述文件](https://github.com/rails/rails-html-sanitizer)获取更多信息。

`PermitScrubber`和`TargetScrubber`的文档解释了如何完全控制何时以及如何剥离元素。

如果您的应用程序需要使用旧的消毒器实现，请在您的`Gemfile`中包含`rails-deprecated_sanitizer`：

```ruby
gem 'rails-deprecated_sanitizer'
```

### Rails DOM测试

[`TagAssertions`模块](https://api.rubyonrails.org/v4.1/classes/ActionDispatch/Assertions/TagAssertions.html)（包含`assert_tag`等方法）已被弃用，取而代之的是从`SelectorAssertions`模块中提取出来的`assert_select`方法，该模块已被提取到[rails-dom-testing gem](https://github.com/rails/rails-dom-testing)中。

### 掩码认证令牌

为了减轻SSL攻击，`form_authenticity_token`现在被掩码，以便每个请求都有所不同。因此，令牌通过解码和解密进行验证。因此，验证来自非Rails表单的请求的策略必须考虑到这一点。
### Action Mailer

之前，在邮件类上调用邮件方法会直接执行相应的实例方法。随着 Active Job 和 `#deliver_later` 的引入，这种情况不再成立。在 Rails 4.2 中，实例方法的调用被推迟到调用 `deliver_now` 或 `deliver_later` 时才执行。例如：

```ruby
class Notifier < ActionMailer::Base
  def notify(user, ...)
    puts "Called"
    mail(to: user.email, ...)
  end
end
```

```ruby
mail = Notifier.notify(user, ...) # 此时 Notifier#notify 还未被调用
mail = mail.deliver_now           # 输出 "Called"
```

对于大多数应用程序来说，这不会导致任何明显的差异。然而，如果您需要同步执行一些非邮件方法，并且之前依赖于同步代理行为，您应该直接在邮件类上定义它们作为类方法：

```ruby
class Notifier < ActionMailer::Base
  def self.broadcast_notifications(users, ...)
    users.each { |user| Notifier.notify(user, ...) }
  end
end
```

### 外键支持

迁移 DSL 已扩展以支持外键定义。如果您一直在使用 Foreigner gem，您可能想考虑将其移除。请注意，Rails 的外键支持是 Foreigner 的一个子集。这意味着并非每个 Foreigner 定义都可以完全由其 Rails 迁移 DSL 对应物替代。

迁移过程如下：

1. 从 `Gemfile` 中删除 `gem "foreigner"`。
2. 运行 `bundle install`。
3. 运行 `bin/rake db:schema:dump`。
4. 确保 `db/schema.rb` 包含了每个外键定义及其必要的选项。

从 Rails 4.0 升级到 Rails 4.1
-------------------------------------

### 防止来自远程 `<script>` 标签的 CSRF 攻击

或者说，"我的测试失败了！！！" 或者 "我的 `<script>` 小部件坏了！！"

跨站请求伪造 (CSRF) 保护现在也覆盖了带有 JavaScript 响应的 GET 请求。这可以防止第三方站点通过 `<script>` 标签远程引用您的 JavaScript 以提取敏感数据。

这意味着使用以下代码的功能测试和集成测试

```ruby
get :index, format: :js
```

现在将触发 CSRF 保护。改为使用

```ruby
xhr :get, :index, format: :js
```

来显式地测试 `XmlHttpRequest`。

注意：您自己的 `<script>` 标签也被视为跨域并默认被阻止。如果您确实需要从 `<script>` 标签加载 JavaScript，您现在必须显式跳过这些操作的 CSRF 保护。

### Spring

如果您想使用 Spring 作为应用程序的预加载器，您需要：

1. 在 `Gemfile` 中添加 `gem 'spring', group: :development`。
2. 使用 `bundle install` 安装 spring。
3. 使用 `bundle exec spring binstub` 生成 Spring binstub。

注意：用户定义的 rake 任务默认在 `development` 环境中运行。如果您希望它们在其他环境中运行，请参阅 [Spring README](https://github.com/rails/spring#rake)。

### `config/secrets.yml`

如果您想使用新的 `secrets.yml` 约定来存储应用程序的密钥，您需要：

1. 在 `config` 文件夹中创建一个名为 `secrets.yml` 的文件，内容如下：

    ```yaml
    development:
      secret_key_base:

    test:
      secret_key_base:

    production:
      secret_key_base: <%= ENV["SECRET_KEY_BASE"] %>
    ```

2. 使用现有的 `secret_token.rb` 初始化文件中的 `secret_key_base` 来为在生产环境中运行 Rails 应用程序的用户设置 `SECRET_KEY_BASE` 环境变量。或者，您可以直接将现有的 `secret_key_base` 从 `secret_token.rb` 初始化文件复制到 `secrets.yml` 的 `production` 部分，替换 `<%= ENV["SECRET_KEY_BASE"] %>`。

3. 删除 `secret_token.rb` 初始化文件。

4. 使用 `rake secret` 为 `development` 和 `test` 部分生成新的密钥。

5. 重新启动服务器。

### 测试助手的更改

如果您的测试助手包含对 `ActiveRecord::Migration.check_pending!` 的调用，可以将其删除。现在在 `require "rails/test_help"` 时会自动进行检查，尽管在助手中保留此行不会有任何危害。

### Cookies 序列化器

在 Rails 4.1 之前创建的应用程序使用 `Marshal` 将 cookie 值序列化为签名和加密的 cookie 存储。如果您想在应用程序中使用新的基于 `JSON` 的格式，可以添加一个初始化文件，内容如下：

```ruby
Rails.application.config.action_dispatch.cookies_serializer = :hybrid
```

这将自动将现有的使用 `Marshal` 序列化的 cookie 迁移到新的基于 `JSON` 的格式。

当使用 `:json` 或 `:hybrid` 序列化器时，您应该注意并非所有的 Ruby 对象都可以序列化为 JSON。例如，`Date` 和 `Time` 对象将被序列化为字符串，而 `Hash` 的键将被转换为字符串。

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
建议只在cookie中存储简单的数据（字符串和数字）。如果必须存储复杂的对象，在后续请求中读取值时需要手动处理转换。

如果使用cookie会话存储，这也适用于`session`和`flash`哈希。

### Flash结构变化

Flash消息键已经[normalized to strings](https://github.com/rails/rails/commit/a668beffd64106a1e1fedb71cc25eaaa11baf0c1)。仍然可以使用符号或字符串访问它们。循环遍历flash将始终产生字符串键：

```ruby
flash["string"] = "a string"
flash[:symbol] = "a symbol"

# Rails < 4.1
flash.keys # => ["string", :symbol]

# Rails >= 4.1
flash.keys # => ["string", "symbol"]
```

确保将Flash消息键与字符串进行比较。

### JSON处理的变化

Rails 4.1中与JSON处理相关的几个重大变化。

#### 移除MultiJSON

MultiJSON已经达到了[end-of-life](https://github.com/rails/rails/pull/10576)，并已从Rails中移除。

如果您的应用程序当前直接依赖于MultiJSON，您有几个选择：

1. 将'multi_json'添加到您的`Gemfile`。请注意，这可能在将来停止工作。

2. 通过使用`obj.to_json`和`JSON.parse(str)`来迁移到MultiJSON。

警告：不要简单地用`JSON.dump`和`JSON.load`替换`MultiJson.dump`和`MultiJson.load`。这些JSON gem API用于序列化和反序列化任意Ruby对象，通常是不安全的。

#### JSON gem兼容性

在历史上，Rails与JSON gem存在一些兼容性问题。在Rails应用程序中使用`JSON.generate`和`JSON.dump`可能会产生意外的错误。

Rails 4.1通过将其自己的编码器与JSON gem隔离来解决了这些问题。JSON gem API将正常工作，但它们将无法访问任何Rails特定的功能。例如：

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

#### 新的JSON编码器

Rails 4.1中的JSON编码器已经重写，以利用JSON gem的优势。对于大多数应用程序，这应该是一个透明的更改。然而，作为重写的一部分，编码器删除了以下功能：

1. 循环数据结构检测
2. 支持`encode_json`钩子
3. 将`BigDecimal`对象编码为数字而不是字符串的选项

如果您的应用程序依赖于这些功能之一，可以通过将[`activesupport-json_encoder`](https://github.com/rails/activesupport-json_encoder) gem添加到您的`Gemfile`中来恢复它们。

#### Time对象的JSON表示

具有时间组件（`Time`，`DateTime`，`ActiveSupport::TimeWithZone`）的对象的`#as_json`现在默认返回毫秒精度。如果需要保留没有毫秒精度的旧行为，请在初始化程序中设置以下内容：

```ruby
ActiveSupport::JSON::Encoding.time_precision = 0
```

### 内联回调块中的`return`的使用

以前，Rails允许内联回调块使用`return`，如下所示：

```ruby
class ReadOnlyModel < ActiveRecord::Base
  before_save { return false } # BAD
end
```

这种行为从未被有意支持过。由于`ActiveSupport::Callbacks`内部的更改，这在Rails 4.1中不再允许。在内联回调块中使用`return`语句会在执行回调时引发`LocalJumpError`。

可以将使用`return`的内联回调块重构为评估返回的值：

```ruby
class ReadOnlyModel < ActiveRecord::Base
  before_save { false } # GOOD
end
```

或者，如果更喜欢使用`return`，建议显式定义一个方法：

```ruby
class ReadOnlyModel < ActiveRecord::Base
  before_save :before_save_callback # GOOD

  private
    def before_save_callback
      false
    end
end
```

此更改适用于Rails中使用回调的大多数地方，包括Active Record和Active Model回调，以及Action Controller中的过滤器（例如`before_action`）。

有关更多详细信息，请参阅[此pull request](https://github.com/rails/rails/pull/13271)。

### 在Active Record fixtures中定义的方法

Rails 4.1在单独的上下文中评估每个fixture的ERB，因此在fixture中定义的辅助方法将不会在其他fixture中可用。

在多个fixture中使用的辅助方法应该在新引入的`ActiveRecord::FixtureSet.context_class`中包含的模块中定义，在`test_helper.rb`中。

```ruby
module FixtureFileHelpers
  def file_sha(path)
    OpenSSL::Digest::SHA256.hexdigest(File.read(Rails.root.join('test/fixtures', path)))
  end
end

ActiveRecord::FixtureSet.context_class.include FixtureFileHelpers
```

### I18n强制可用的区域设置

Rails 4.1现在将I18n选项`enforce_available_locales`默认设置为`true`。这意味着它将确保传递给它的所有区域设置必须在`available_locales`列表中声明。
要禁用它（并允许I18n接受*任何*区域设置选项），请将以下配置添加到您的应用程序中：

```ruby
config.i18n.enforce_available_locales = false
```

请注意，此选项是作为安全措施添加的，以确保用户输入不能用作区域设置信息，除非事先已知。因此，除非您有充分的理由这样做，否则建议不要禁用此选项。

### 在关系上调用的Mutator方法

`Relation`不再具有像`#map!`和`#delete_if`这样的Mutator方法。在使用这些方法之前，请调用`#to_a`将其转换为`Array`。

这旨在防止在代码中直接调用Mutator方法时出现奇怪的错误和混淆。

```ruby
# 不再这样写
Author.where(name: 'Hank Moody').compact!

# 现在需要这样写
authors = Author.where(name: 'Hank Moody').to_a
authors.compact!
```

### 默认作用域的更改

默认作用域不再被链式条件覆盖。

在之前的版本中，当您在模型中定义`default_scope`时，它会被相同字段的链式条件覆盖。现在它像任何其他作用域一样合并。

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

之后：

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

要恢复以前的行为，需要使用`unscoped`，`unscope`，`rewhere`或`except`显式删除`default_scope`条件。

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

### 从字符串渲染内容

Rails 4.1引入了`render`的`:plain`，`:html`和`:body`选项。这些选项现在是渲染基于字符串的内容的首选方式，因为它允许您指定要将响应发送为的内容类型。

* `render :plain`将内容类型设置为`text/plain`
* `render :html`将内容类型设置为`text/html`
* `render :body`将*不会*设置内容类型头。

从安全角度来看，如果您不希望在响应正文中有任何标记，则应使用`render :plain`，因为大多数浏览器会为您转义响应中的不安全内容。

我们将在将来的版本中弃用使用`render :text`。因此，请开始使用更精确的`:plain`，`:html`和`:body`选项。使用`render :text`可能会带来安全风险，因为内容将作为`text/html`发送。

### PostgreSQL JSON和hstore数据类型

Rails 4.1将`json`和`hstore`列映射为以字符串为键的Ruby `Hash`。在早期版本中，使用的是`HashWithIndifferentAccess`。这意味着不再支持符号访问。对于基于`json`或`hstore`列的`store_accessors`也是如此。请确保始终使用字符串键。

### `ActiveSupport::Callbacks`的显式块用法

Rails 4.1现在在调用`ActiveSupport::Callbacks.set_callback`时期望传递一个显式块。这个变化源于`ActiveSupport::Callbacks`在4.1版本中被大部分重写。

```ruby
# 在Rails 4.0中以前
set_callback :save, :around, ->(r, &block) { stuff; result = block.call; stuff }

# 在Rails 4.1中现在
set_callback :save, :around, ->(r, block) { stuff; result = block.call; stuff }
```

从Rails 3.2升级到Rails 4.0
-------------------------------------

如果您的应用程序当前使用的是早于3.2.x的任何版本的Rails，请在尝试升级到Rails 4.0之前先升级到Rails 3.2。

以下更改适用于将应用程序升级到Rails 4.0。

### HTTP PATCH
Rails 4现在在`config/routes.rb`中声明RESTful资源时，使用`PATCH`作为更新的主要HTTP动词。`update`动作仍然被使用，`PUT`请求也将继续路由到`update`动作。因此，如果您只使用标准的RESTful路由，无需进行任何更改：

```ruby
resources :users
```

```erb
<%= form_for @user do |f| %>
```

```ruby
class UsersController < ApplicationController
  def update
    # 无需更改；PATCH将被优先使用，PUT仍然有效。
  end
end
```

然而，如果您正在使用`form_for`来更新资源，并且与使用`PUT` HTTP方法的自定义路由结合使用，则需要进行更改：

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
    # 需要更改；form_for将尝试使用一个不存在的PATCH路由。
  end
end
```

如果该动作未在公共API中使用，并且您可以更改HTTP方法，则可以更新路由以使用`patch`而不是`put`：

```ruby
resources :users do
  patch :update_name, on: :member
end
```

在Rails 4中，`PUT`请求到`/users/:id`将路由到`update`，与现在的情况相同。因此，如果您有一个接收真实PUT请求的API，它将正常工作。路由器还将`PATCH`请求路由到`/users/:id`到`update`动作。

如果该动作在公共API中使用，并且您无法更改正在使用的HTTP方法，则可以更新表单以使用`PUT`方法：

```erb
<%= form_for [ :update_name, @user ], method: :put do |f| %>
```

有关PATCH以及为什么进行此更改的更多信息，请参阅Rails博客上的[此文章](https://weblog.rubyonrails.org/2012/2/26/edge-rails-patch-is-the-new-primary-http-method-for-updates/)。

#### 关于媒体类型的说明

`PATCH`动词的勘误[指定应使用'diff'媒体类型](http://www.rfc-editor.org/errata_search.php?rfc=5789)。其中一种格式是[JSON Patch](https://tools.ietf.org/html/rfc6902)。虽然Rails不原生支持JSON Patch，但很容易添加支持：

```ruby
# 在您的控制器中：
def update
  respond_to do |format|
    format.json do
      # 执行部分更新
      @article.update params[:article]
    end

    format.json_patch do
      # 执行复杂的更改
    end
  end
end
```

```ruby
# config/initializers/json_patch.rb
Mime::Type.register 'application/json-patch+json', :json_patch
```

由于JSON Patch最近才成为RFC，因此还没有很多出色的Ruby库。Aaron Patterson的[hana](https://github.com/tenderlove/hana)是一个这样的宝石，但对规范的最后几个更改没有完全支持。

### Gemfile

Rails 4.0从`Gemfile`中删除了`assets`组。在升级时，您需要从`Gemfile`中删除该行。您还应该更新应用程序文件（位于`config/application.rb`中）：

```ruby
# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)
```

### vendor/plugins

Rails 4.0不再支持从`vendor/plugins`加载插件。您必须将任何插件提取为宝石并将它们添加到您的`Gemfile`中。如果您选择不将它们制作成宝石，您可以将它们移动到`lib/my_plugin/*`，并在`config/initializers/my_plugin.rb`中添加适当的初始化程序。

### Active Record

* Rails 4.0从Active Record中删除了标识映射，原因是与关联存在一些不一致性。如果您在应用程序中手动启用了它，您将不得不删除以下没有效果的配置：`config.active_record.identity_map`。

* 集合关联中的`delete`方法现在可以接收`Integer`或`String`类型的记录ID作为参数，与`destroy`方法几乎相同。以前，对于这样的参数，它会引发`ActiveRecord::AssociationTypeMismatch`错误。从Rails 4.0开始，在删除之前，`delete`会自动尝试找到与给定ID匹配的记录。

* 在Rails 4.0中，当重命名列或表时，相关的索引也会被重命名。如果您有重命名索引的迁移，它们不再需要。

* Rails 4.0已将`serialized_attributes`和`attr_readonly`更改为仅类方法。您不应该使用实例方法，因为它已被弃用。您应该将它们更改为使用类方法，例如`self.serialized_attributes`改为`self.class.serialized_attributes`。

* 使用默认编码器时，将`nil`分配给序列化属性将将其保存到数据库中作为`NULL`，而不是通过YAML传递`nil`值（`"--- \n...\n"`）。
* Rails 4.0在Strong Parameters的支持下移除了`attr_accessible`和`attr_protected`功能。您可以使用[Protected Attributes gem](https://github.com/rails/protected_attributes)进行平滑升级。

* 如果您没有使用Protected Attributes，可以删除与该gem相关的任何选项，例如`whitelist_attributes`或`mass_assignment_sanitizer`选项。

* Rails 4.0要求作用域使用可调用对象，例如Proc或lambda：

    ```ruby
      scope :active, where(active: true)

      # 变为
      scope :active, -> { where active: true }
    ```

* Rails 4.0已弃用`ActiveRecord::Fixtures`，改用`ActiveRecord::FixtureSet`。

* Rails 4.0已弃用`ActiveRecord::TestCase`，改用`ActiveSupport::TestCase`。

* Rails 4.0已弃用旧式基于哈希的查找器API。这意味着以前接受“查找器选项”的方法不再接受。例如，`Book.find(:all, conditions: { name: '1984' })`已被弃用，改用`Book.where(name: '1984')`

* 除了`find_by_...`和`find_by_...!`之外，所有动态方法都已弃用。以下是如何处理这些更改：

      * `find_all_by_...`           变为 `where(...)`.
      * `find_last_by_...`          变为 `where(...).last`.
      * `scoped_by_...`             变为 `where(...)`.
      * `find_or_initialize_by_...` 变为 `find_or_initialize_by(...)`.
      * `find_or_create_by_...`     变为 `find_or_create_by(...)`.

* 请注意，`where(...)`返回的是一个关系(relation)，而不是旧的查找器中的数组。如果需要一个`Array`，请使用`where(...).to_a`。

* 这些等效方法可能不会执行与先前实现相同的SQL。

* 要重新启用旧的查找器，可以使用[activerecord-deprecated_finders gem](https://github.com/rails/activerecord-deprecated_finders)。

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

Rails 4.0将Active Resource提取为独立的gem。如果您仍然需要该功能，可以在`Gemfile`中添加[Active Resource gem](https://github.com/rails/activeresource)。

### Active Model

* Rails 4.0已更改了`ActiveModel::Validations::ConfirmationValidator`附加错误的方式。现在，当确认验证失败时，错误将附加到`:#{attribute}_confirmation`而不是`attribute`。

* Rails 4.0已将`ActiveModel::Serializers::JSON.include_root_in_json`的默认值更改为`false`。现在，Active Model Serializers和Active Record对象具有相同的默认行为。这意味着您可以在`config/initializers/wrap_parameters.rb`文件中注释或删除以下选项：

    ```ruby
    # Disable root element in JSON by default.
    # ActiveSupport.on_load(:active_record) do
    #   self.include_root_in_json = false
    # end
    ```

### Action Pack

* Rails 4.0引入了`ActiveSupport::KeyGenerator`，并将其用作生成和验证签名cookie（等等）的基础。如果您保留现有的`secret_token`并添加新的`secret_key_base`，则会自动升级现有的Rails 3.x签名cookie。

    ```ruby
      # config/initializers/secret_token.rb
      Myapp::Application.config.secret_token = 'existing secret token'
      Myapp::Application.config.secret_key_base = 'new secret key base'
    ```

    请注意，应在将100％的用户迁移到Rails 4.x并且合理确定不需要回滚到Rails 3.x之后再设置`secret_key_base`。这是因为基于新的`secret_key_base`在Rails 4.x中生成的cookie与Rails 3.x不兼容。您可以保留现有的`secret_token`，不设置新的`secret_key_base`，并忽略弃用警告，直到您合理确定升级已经完成。

    如果您依赖于外部应用程序或JavaScript能够读取您的Rails应用程序的签名会话cookie（或签名cookie），则在解耦这些问题之前不应设置`secret_key_base`。

* Rails 4.0如果设置了`secret_key_base`，会对基于cookie的会话内容进行加密。Rails 3.x对基于cookie的会话内容进行了签名，但没有加密。签名cookie是“安全”的，因为它们经过验证是由您的应用程序生成的，并且是防篡改的。但是，内容可以被最终用户查看，加密内容可以消除这个注意事项/问题，而不会有显著的性能损失。

    有关移至加密会话cookie的详细信息，请阅读[Pull Request #9978](https://github.com/rails/rails/pull/9978)。

* Rails 4.0已删除了`ActionController::Base.asset_path`选项。请使用资产管道功能。
* Rails 4.0已弃用`ActionController::Base.page_cache_extension`选项。请改用`ActionController::Base.default_static_extension`。

* Rails 4.0已从Action Pack中移除了Action和Page缓存。您需要在控制器中添加`actionpack-action_caching` gem以使用`caches_action`，并添加`actionpack-page_caching` gem以使用`caches_page`。

* Rails 4.0已移除了XML参数解析器。如果需要此功能，您需要添加`actionpack-xml_parser` gem。

* Rails 4.0更改了使用符号或返回nil的procs进行默认`layout`查找设置。要获得“无布局”行为，应返回false而不是nil。

* Rails 4.0将默认的memcached客户端从`memcache-client`更改为`dalli`。要升级，只需将`gem 'dalli'`添加到您的`Gemfile`中。

* Rails 4.0在控制器中弃用了`dom_id`和`dom_class`方法（在视图中使用它们是可以的）。如果需要此功能，您需要在需要的控制器中包含`ActionView::RecordIdentifier`模块。

* Rails 4.0在`link_to`助手中弃用了`:confirm`选项。您应该使用数据属性（例如`data: { confirm: 'Are you sure?' }`）来替代。此弃用还涉及基于此助手的其他助手（如`link_to_if`或`link_to_unless`）。

* Rails 4.0更改了`assert_generates`，`assert_recognizes`和`assert_routing`的工作方式。现在，所有这些断言都会引发`Assertion`而不是`ActionController::RoutingError`。

* Rails 4.0如果定义了冲突的命名路由，则会引发`ArgumentError`。这可以通过显式定义的命名路由或`resources`方法触发。以下是与名为`example_path`的路由冲突的两个示例：

    ```ruby
    get 'one' => 'test#example', as: :example
    get 'two' => 'test#example', as: :example
    ```

    ```ruby
    resources :examples
    get 'clashing/:id' => 'test#example', as: :example
    ```

    在第一种情况下，您可以避免在多个路由中使用相同的名称。在第二种情况下，您可以使用`resources`方法提供的`only`或`except`选项来限制创建的路由，详细信息请参阅[Routing Guide](routing.html#restricting-the-routes-created)。

* Rails 4.0还更改了绘制Unicode字符路由的方式。现在可以直接绘制Unicode字符路由。如果您已经绘制了此类路由，则必须更改它们，例如：

    ```ruby
    get Rack::Utils.escape('こんにちは'), controller: 'welcome', action: 'index'
    ```

    变为

    ```ruby
    get 'こんにちは', controller: 'welcome', action: 'index'
    ```

* Rails 4.0要求使用`match`的路由必须指定请求方法。例如：

    ```ruby
      # Rails 3.x
      match '/' => 'root#index'

      # 变为
      match '/' => 'root#index', via: :get

      # 或者
      get '/' => 'root#index'
    ```

* Rails 4.0已移除`ActionDispatch::BestStandardsSupport`中间件，`<!DOCTYPE html>`已经根据 https://msdn.microsoft.com/en-us/library/jj676915(v=vs.85).aspx 触发了标准模式，并且ChromeFrame头已移至`config.action_dispatch.default_headers`。

    请记住，您还必须从应用程序代码中删除对中间件的任何引用，例如：

    ```ruby
    # 引发异常
    config.middleware.insert_before(Rack::Lock, ActionDispatch::BestStandardsSupport)
    ```

    还要检查环境设置中的`config.action_dispatch.best_standards_support`并在存在时删除它。

* Rails 4.0允许通过设置`config.action_dispatch.default_headers`来配置HTTP头。默认值如下：

    ```ruby
      config.action_dispatch.default_headers = {
        'X-Frame-Options' => 'SAMEORIGIN',
        'X-XSS-Protection' => '1; mode=block'
      }
    ```

    请注意，如果您的应用程序依赖于在`<frame>`或`<iframe>`中加载某些页面，则可能需要显式设置`X-Frame-Options`为`ALLOW-FROM ...`或`ALLOWALL`。

* 在Rails 4.0中，预编译资产不再自动从`vendor/assets`和`lib/assets`复制非JS/CSS资产。Rails应用程序和引擎开发人员应将这些资产放在`app/assets`中或配置[`config.assets.precompile`][]。

* 在Rails 4.0中，当操作不处理请求格式时，将引发`ActionController::UnknownFormat`异常。默认情况下，该异常通过响应406 Not Acceptable来处理，但现在可以覆盖它。在Rails 3中，始终返回406 Not Acceptable。无法覆盖。

* 在Rails 4.0中，当`ParamsParser`无法解析请求参数时，会引发通用的`ActionDispatch::ParamsParser::ParseError`异常。您应该捕获此异常，而不是低级别的`MultiJson::DecodeError`，例如。

* 在Rails 4.0中，当引擎挂载在从URL前缀提供的应用程序上时，`SCRIPT_NAME`会正确嵌套。您不再需要设置`default_url_options[:script_name]`来解决被覆盖的URL前缀。

* Rails 4.0弃用了`ActionController::Integration`，推荐使用`ActionDispatch::Integration`。
* Rails 4.0弃用了`ActionController::IntegrationTest`，推荐使用`ActionDispatch::IntegrationTest`。
* Rails 4.0弃用了`ActionController::PerformanceTest`，推荐使用`ActionDispatch::PerformanceTest`。
* Rails 4.0弃用了`ActionController::AbstractRequest`，推荐使用`ActionDispatch::Request`。
* Rails 4.0弃用了`ActionController::Request`，推荐使用`ActionDispatch::Request`。
* Rails 4.0弃用了`ActionController::AbstractResponse`，推荐使用`ActionDispatch::Response`。
* Rails 4.0弃用了`ActionController::Response`，推荐使用`ActionDispatch::Response`。
* Rails 4.0弃用了`ActionController::Routing`，推荐使用`ActionDispatch::Routing`。
### Active Support

Rails 4.0移除了`ERB::Util#json_escape`的`j`别名，因为`j`已经用于`ActionView::Helpers::JavaScriptHelper#escape_javascript`。

#### 缓存

Rails 3.x和4.0之间的缓存方法发生了变化。您应该[更改缓存命名空间](https://guides.rubyonrails.org/v4.0/caching_with_rails.html#activesupport-cache-store)并使用冷缓存进行部署。

### Helpers加载顺序

在Rails 4.0中，从多个目录加载的helpers的顺序发生了变化。以前，它们被收集然后按字母顺序排序。升级到Rails 4.0后，helpers将保留加载目录的顺序，并且只在每个目录内按字母顺序排序。除非您明确使用`helpers_path`参数，否则此更改只会影响从引擎加载helpers的方式。如果您依赖于顺序，请在升级后检查正确的方法是否可用。如果您想更改引擎加载的顺序，可以使用`config.railties_order=`方法。

### Active Record Observer和Action Controller Sweeper

`ActiveRecord::Observer`和`ActionController::Caching::Sweeper`已经提取到`rails-observers` gem中。如果您需要这些功能，您需要添加`rails-observers` gem。

### sprockets-rails

* `assets:precompile:primary`和`assets:precompile:all`已被删除。请改用`assets:precompile`。
* `config.assets.compress`选项应更改为[`config.assets.js_compressor`][]，例如：

    ```ruby
    config.assets.js_compressor = :uglifier
    ```

### sass-rails

* `asset-url`带有两个参数的用法已被弃用。例如：`asset-url("rails.png", image)`变为`asset-url("rails.png")`。

从Rails 3.1升级到Rails 3.2
-------------------------------------

如果您的应用程序当前处于3.1.x之前的任何版本的Rails上，您应该在尝试升级到Rails 3.2之前先升级到Rails 3.1。

以下更改适用于将应用程序升级到最新的Rails 3.2.x版本。

### Gemfile

对您的`Gemfile`进行以下更改。

```ruby
gem 'rails', '3.2.21'

group :assets do
  gem 'sass-rails',   '~> 3.2.6'
  gem 'coffee-rails', '~> 3.2.2'
  gem 'uglifier',     '>= 1.0.3'
end
```

### config/environments/development.rb

您应该在开发环境中添加一些新的配置设置：

```ruby
# 对Active Record模型的批量赋值保护引发异常
config.active_record.mass_assignment_sanitizer = :strict

# 记录查询计划，对于执行时间超过此阈值的查询（适用于SQLite、MySQL和PostgreSQL）
config.active_record.auto_explain_threshold_in_seconds = 0.5
```

### config/environments/test.rb

`mass_assignment_sanitizer`配置设置也应添加到`config/environments/test.rb`中：

```ruby
# 对Active Record模型的批量赋值保护引发异常
config.active_record.mass_assignment_sanitizer = :strict
```

### vendor/plugins

Rails 3.2弃用了`vendor/plugins`，而Rails 4.0将完全删除它们。虽然作为Rails 3.2升级的一部分并不是严格必需的，但您可以通过将它们提取为gems并将它们添加到您的`Gemfile`中来开始替换任何插件。如果您选择不将它们制作为gems，您可以将它们移动到`lib/my_plugin/*`，并在`config/initializers/my_plugin.rb`中添加适当的初始化程序。

### Active Record

从`belongs_to`中删除了`dependent => :restrict`选项。如果您想要防止删除对象，如果存在任何关联对象，您可以设置`dependent => :destroy`，并在检查任何关联对象的destroy回调中返回`false`。

从Rails 3.0升级到Rails 3.1
-------------------------------------

如果您的应用程序当前处于3.0.x之前的任何版本的Rails上，您应该在尝试升级到Rails 3.1之前先升级到Rails 3.0。

以下更改适用于将应用程序升级到Rails 3.1.12，最后一个3.1.x版本的Rails。

### Gemfile

对您的`Gemfile`进行以下更改。

```ruby
gem 'rails', '3.1.12'
gem 'mysql2'

# 为新的asset pipeline所需
group :assets do
  gem 'sass-rails',   '~> 3.1.7'
  gem 'coffee-rails', '~> 3.1.1'
  gem 'uglifier',     '>= 1.0.3'
end

# jQuery是Rails 3.1的默认JavaScript库
gem 'jquery-rails'
```

### config/application.rb

asset pipeline需要以下添加：

```ruby
config.assets.enabled = true
config.assets.version = '1.0'
```

如果您的应用程序为资源使用"/assets"路由，您可能希望更改用于资源的前缀以避免冲突：

```ruby
# 默认为'/assets'
config.assets.prefix = '/asset-files'
```

### config/environments/development.rb

删除RJS设置`config.action_view.debug_rjs = true`。

如果启用asset pipeline，请添加以下设置：

```ruby
# 不压缩assets
config.assets.compress = false

# 展开加载assets的行
config.assets.debug = true
```

### config/environments/production.rb

同样，下面的大部分更改都是为了asset pipeline。您可以在[Asset Pipeline](asset_pipeline.html)指南中了解更多信息。
```ruby
# 压缩JavaScript和CSS
config.assets.compress = true

# 如果预编译的资源丢失，则不回退到资源管道
config.assets.compile = false

# 为资源URL生成摘要
config.assets.digest = true

# 默认为Rails.root.join("public/assets")
# config.assets.manifest = YOUR_PATH

# 预编译其他资源（application.js、application.css以及所有非JS/CSS文件已添加）
# config.assets.precompile += %w( admin.js admin.css )

# 强制通过SSL访问应用程序，使用Strict-Transport-Security，并使用安全的cookie。
# config.force_ssl = true
```

### config/environments/test.rb

您可以通过以下方式在测试环境中测试性能：

```ruby
# 为测试配置静态资源服务器，使用Cache-Control提高性能
config.public_file_server.enabled = true
config.public_file_server.headers = {
  'Cache-Control' => 'public, max-age=3600'
}
```

### config/initializers/wrap_parameters.rb

如果您希望将参数包装成嵌套哈希，请添加此文件并包含以下内容。这在新应用程序中默认启用。

```ruby
# 修改此文件后请务必重新启动服务器。
# 此文件包含ActionController::ParamsWrapper的设置，默认情况下启用。

# 启用JSON的参数包装。您可以通过将:format设置为空数组来禁用此功能。
ActiveSupport.on_load(:action_controller) do
  wrap_parameters format: [:json]
end

# 默认情况下在JSON中禁用根元素。
ActiveSupport.on_load(:active_record) do
  self.include_root_in_json = false
end
```

### config/initializers/session_store.rb

您需要将会话密钥更改为新的值，或者删除所有会话：

```ruby
# 在config/initializers/session_store.rb中
AppName::Application.config.session_store :cookie_store, key: 'SOMETHINGNEW'
```

或者

```bash
$ bin/rake db:sessions:clear
```

### 从视图中的资源助手引用中删除:cache和:concat选项

* 使用资源管道，不再使用:cache和:concat选项，从视图中删除这些选项。
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
