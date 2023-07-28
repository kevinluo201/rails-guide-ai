**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: b8e9de3d2aa934a8a6fc3e1dccb4824c
Active Storage概述
=======================

本指南介绍了如何将文件附加到Active Record模型。

阅读本指南后，您将了解以下内容：

* 如何将一个或多个文件附加到记录。
* 如何删除附加的文件。
* 如何链接到附加的文件。
* 如何使用变体来转换图像。
* 如何生成非图像文件（如PDF或视频）的图像表示。
* 如何直接从浏览器将文件上传到存储服务，绕过应用程序服务器。
* 如何在测试期间清理存储的文件。
* 如何实现对其他存储服务的支持。

--------------------------------------------------------------------------------

什么是Active Storage？
-----------------------

Active Storage可以将文件上传到云存储服务，如Amazon S3、Google Cloud Storage或Microsoft Azure Storage，并将这些文件附加到Active Record对象上。它提供了一个基于本地磁盘的服务，用于开发和测试，并支持将文件镜像到从属服务以进行备份和迁移。

使用Active Storage，应用程序可以转换图像上传或生成非图像上传（如PDF和视频）的图像表示，并从任意文件中提取元数据。

### 要求

Active Storage的各种功能依赖于Rails不会安装的第三方软件，必须单独安装：

* [libvips](https://github.com/libvips/libvips) v8.6+或[ImageMagick](https://imagemagick.org/index.php)用于图像分析和转换
* [ffmpeg](http://ffmpeg.org/) v3.4+用于视频预览和ffprobe用于视频/音频分析
* [poppler](https://poppler.freedesktop.org/)或[muPDF](https://mupdf.com/)用于PDF预览

图像分析和转换还需要`image_processing` gem。在您的`Gemfile`中取消注释它，或者如果需要的话添加它：

```ruby
gem "image_processing", ">= 1.2"
```

提示：与libvips相比，ImageMagick更为知名且更广泛可用。然而，libvips可以[快10倍且消耗1/10的内存](https://github.com/libvips/libvips/wiki/Speed-and-memory-use)。对于JPEG文件，可以通过将`libjpeg-dev`替换为`libjpeg-turbo-dev`来进一步改善性能，后者[快2-7倍](https://libjpeg-turbo.org/About/Performance)。

警告：在安装和使用第三方软件之前，请确保您理解这样做的许可证影响。特别是，MuPDF在AGPL下许可，某些用途需要商业许可。

## 设置

```bash
$ bin/rails active_storage:install
$ bin/rails db:migrate
```

这将设置配置，并创建Active Storage使用的三个表：`active_storage_blobs`、`active_storage_attachments`和`active_storage_variant_records`。

| 表名      | 用途 |
| ------------------- | ----- |
| `active_storage_blobs` | 存储有关上传文件的数据，如文件名和内容类型。 |
| `active_storage_attachments` | 一个多态连接表，[连接您的模型和blobs](#attaching-files-to-records)。如果您的模型类名更改了，您需要在此表上运行迁移，以更新底层的`record_type`为您的模型的新类名。 |
| `active_storage_variant_records` | 如果启用了[变体跟踪](#attaching-files-to-records)，则存储已生成的每个变体的记录。 |

警告：如果您在模型上使用UUID而不是整数作为主键，您应该在配置文件中设置`Rails.application.config.generators { |g| g.orm :active_record, primary_key_type: :uuid }`。

在`config/storage.yml`中声明Active Storage服务。对于应用程序使用的每个服务，提供一个名称和必要的配置。下面的示例声明了三个名为`local`、`test`和`amazon`的服务：

```yaml
local:
  service: Disk
  root: <%= Rails.root.join("storage") %>

test:
  service: Disk
  root: <%= Rails.root.join("tmp/storage") %>

amazon:
  service: S3
  access_key_id: ""
  secret_access_key: ""
  bucket: ""
  region: "" # 例如 'us-east-1'
```

通过设置`Rails.application.config.active_storage.service`告诉Active Storage使用哪个服务。因为每个环境可能使用不同的服务，建议在每个环境上进行设置。要在开发环境中使用前面示例中的磁盘服务，您需要将以下内容添加到`config/environments/development.rb`：

```ruby
# 将文件存储在本地。
config.active_storage.service = :local
```

要在生产环境中使用S3服务，您需要将以下内容添加到`config/environments/production.rb`：

```ruby
# 将文件存储在Amazon S3上。
config.active_storage.service = :amazon
```

要在测试时使用测试服务，您需要将以下内容添加到`config/environments/test.rb`：

```ruby
# 将上传的文件存储在本地文件系统的临时目录中。
config.active_storage.service = :test
```

注意：环境特定的配置文件将优先生效：例如，在生产环境中，如果存在`config/storage/production.yml`文件，它将优先于`config/storage.yml`文件。

建议在存储桶名称中使用`Rails.env`以进一步降低意外销毁生产数据的风险。

```yaml
amazon:
  service: S3
  # ...
  bucket: your_own_bucket-<%= Rails.env %>

google:
  service: GCS
  # ...
  bucket: your_own_bucket-<%= Rails.env %>

azure:
  service: AzureStorage
  # ...
  container: your_container_name-<%= Rails.env %>
```

继续阅读以获取有关内置服务适配器（例如`Disk`和`S3`）及其所需配置的更多信息。

### Disk 服务

在 `config/storage.yml` 中声明一个 Disk 服务：

```yaml
local:
  service: Disk
  root: <%= Rails.root.join("storage") %>
```

### S3 服务（Amazon S3 和兼容 S3 API）

要连接到 Amazon S3，请在 `config/storage.yml` 中声明一个 S3 服务：

```yaml
amazon:
  service: S3
  access_key_id: ""
  secret_access_key: ""
  region: ""
  bucket: ""
```

可选地提供客户端和上传选项：

```yaml
amazon:
  service: S3
  access_key_id: ""
  secret_access_key: ""
  region: ""
  bucket: ""
  http_open_timeout: 0
  http_read_timeout: 0
  retry_limit: 0
  upload:
    server_side_encryption: "" # 'aws:kms' 或 'AES256'
    cache_control: "private, max-age=<%= 1.day.to_i %>"
```

提示：为您的应用程序设置合理的客户端 HTTP 超时和重试限制。在某些故障场景下，默认的 AWS 客户端配置可能导致连接保持数分钟，并导致请求排队。

将 [`aws-sdk-s3`](https://github.com/aws/aws-sdk-ruby) gem 添加到您的 `Gemfile` 中：

```ruby
gem "aws-sdk-s3", require: false
```

注意：Active Storage 的核心功能需要以下权限：`s3:ListBucket`、`s3:PutObject`、`s3:GetObject` 和 `s3:DeleteObject`。[公共访问](#public-access) 还需要 `s3:PutObjectAcl`。如果您配置了其他上传选项，例如设置 ACL，则可能需要额外的权限。

注意：如果您想使用环境变量、标准 SDK 配置文件、配置文件、IAM 实例配置文件或任务角色，可以在上面的示例中省略 `access_key_id`、`secret_access_key` 和 `region` 键。S3 服务支持 [AWS SDK 文档](https://docs.aws.amazon.com/sdk-for-ruby/v3/developer-guide/setup-config.html) 中描述的所有身份验证选项。

要连接到类似 DigitalOcean Spaces 的兼容 S3 对象存储 API，请提供 `endpoint`：

```yaml
digitalocean:
  service: S3
  endpoint: https://nyc3.digitaloceanspaces.com
  access_key_id: ...
  secret_access_key: ...
  # ...和其他选项
```

还有许多其他可用选项。您可以在 [AWS S3 Client](https://docs.aws.amazon.com/sdk-for-ruby/v3/api/Aws/S3/Client.html#initialize-instance_method) 文档中查看它们。

### Microsoft Azure 存储服务

在 `config/storage.yml` 中声明一个 Azure 存储服务：

```yaml
azure:
  service: AzureStorage
  storage_account_name: ""
  storage_access_key: ""
  container: ""
```

将 [`azure-storage-blob`](https://github.com/Azure/azure-storage-ruby) gem 添加到您的 `Gemfile` 中：

```ruby
gem "azure-storage-blob", "~> 2.0", require: false
```

### Google Cloud 存储服务

在 `config/storage.yml` 中声明一个 Google Cloud 存储服务：

```yaml
google:
  service: GCS
  credentials: <%= Rails.root.join("path/to/keyfile.json") %>
  project: ""
  bucket: ""
```

可选地提供一个凭据的哈希而不是密钥文件路径：

```yaml
google:
  service: GCS
  credentials:
    type: "service_account"
    project_id: ""
    private_key_id: <%= Rails.application.credentials.dig(:gcs, :private_key_id) %>
    private_key: <%= Rails.application.credentials.dig(:gcs, :private_key).dump %>
    client_email: ""
    client_id: ""
    auth_uri: "https://accounts.google.com/o/oauth2/auth"
    token_uri: "https://accounts.google.com/o/oauth2/token"
    auth_provider_x509_cert_url: "https://www.googleapis.com/oauth2/v1/certs"
    client_x509_cert_url: ""
  project: ""
  bucket: ""
```

可选地提供一个 Cache-Control 元数据以设置上传的资源：

```yaml
google:
  service: GCS
  ...
  cache_control: "public, max-age=3600"
```

如果要在签名 URL 时使用 [IAM](https://cloud.google.com/storage/docs/access-control/signed-urls#signing-iam) 而不是 `credentials`，可以选择使用。如果您正在使用 Workload Identity 对 GKE 应用程序进行身份验证，请参阅 [此 Google Cloud 博客文章](https://cloud.google.com/blog/products/containers-kubernetes/introducing-workload-identity-better-authentication-for-your-gke-applications) 了解更多信息。

```yaml
google:
  service: GCS
  ...
  iam: true
```

如果要在签名 URL 时使用特定的 GSA，请使用 IAM。在使用 IAM 时，将联系 [元数据服务器](https://cloud.google.com/compute/docs/storing-retrieving-metadata) 以获取 GSA 电子邮件，但是该元数据服务器并不总是存在（例如本地测试），您可能希望使用非默认的 GSA。

```yaml
google:
  service: GCS
  ...
  iam: true
  gsa_email: "foobar@baz.iam.gserviceaccount.com"
```

将 [`google-cloud-storage`](https://github.com/GoogleCloudPlatform/google-cloud-ruby/tree/master/google-cloud-storage) gem 添加到您的 `Gemfile` 中：

```ruby
gem "google-cloud-storage", "~> 1.11", require: false
```

### 镜像服务

您可以通过定义镜像服务来保持多个服务的同步。镜像服务会在两个或多个从属服务之间复制上传和删除操作。

镜像服务旨在在生产环境中在服务之间进行迁移时临时使用。您可以开始将镜像服务复制到新服务，将旧服务的预先存在的文件复制到新服务，然后完全转向新服务。

注意：镜像不是原子操作。在主服务上上传可能成功，但在任何从属服务上失败。在完全转向新服务之前，请验证是否已复制所有文件。

按照上面描述的方式定义要镜像的每个服务。在定义镜像服务时，使用名称引用它们：

```yaml
s3_west_coast:
  service: S3
  access_key_id: ""
  secret_access_key: ""
  region: ""
  bucket: ""

s3_east_coast:
  service: S3
  access_key_id: ""
  secret_access_key: ""
  region: ""
  bucket: ""

production:
  service: Mirror
  primary: s3_east_coast
  mirrors:
    - s3_west_coast
```

尽管所有辅助服务都会接收上传，但下载始终由主服务处理。

镜像服务与直接上传兼容。新文件直接上传到主服务。当将直接上传的文件附加到记录时，将排队一个后台作业来将其复制到辅助服务。
### 公共访问

默认情况下，Active Storage假定对服务的访问是私有的。这意味着为blob生成签名的一次性URL。如果您希望使blob公开访问，请在应用的`config/storage.yml`中指定`public: true`：

```yaml
gcs: &gcs
  service: GCS
  project: ""

private_gcs:
  <<: *gcs
  credentials: <%= Rails.root.join("path/to/private_key.json") %>
  bucket: ""

public_gcs:
  <<: *gcs
  credentials: <%= Rails.root.join("path/to/public_key.json") %>
  bucket: ""
  public: true
```

确保您的存储桶已正确配置为公共访问。请参阅有关如何为[Amazon S3](https://docs.aws.amazon.com/AmazonS3/latest/user-guide/block-public-access-bucket.html)、[Google Cloud Storage](https://cloud.google.com/storage/docs/access-control/making-data-public#buckets)和[Microsoft Azure](https://docs.microsoft.com/en-us/azure/storage/blobs/storage-manage-access-to-resources#set-container-public-access-level-in-the-azure-portal)存储服务启用公共读权限的文档。Amazon S3还要求您具有`s3:PutObjectAcl`权限。

在将现有应用程序转换为使用`public: true`时，请确保在切换之前将存储桶中的每个单独文件都设置为可公开读取。

将文件附加到记录
--------------------------

### `has_one_attached`

[`has_one_attached`][]宏设置了记录和文件之间的一对一映射关系。每个记录可以附加一个文件。

例如，假设您的应用程序有一个`User`模型。如果您希望每个用户都有一个头像，请定义`User`模型如下：

```ruby
class User < ApplicationRecord
  has_one_attached :avatar
end
```

或者如果您使用的是Rails 6.0+，您可以运行以下模型生成命令：

```ruby
bin/rails generate model User avatar:attachment
```

您可以创建一个带有头像的用户：

```erb
<%= form.file_field :avatar %>
```

```ruby
class SignupController < ApplicationController
  def create
    user = User.create!(user_params)
    session[:user_id] = user.id
    redirect_to root_path
  end

  private
    def user_params
      params.require(:user).permit(:email_address, :password, :avatar)
    end
end
```

调用[`avatar.attach`][Attached::One#attach]将头像附加到现有用户：

```ruby
user.avatar.attach(params[:avatar])
```

调用[`avatar.attached?`][Attached::One#attached?]来确定特定用户是否有头像：

```ruby
user.avatar.attached?
```

在某些情况下，您可能希望为特定附件覆盖默认服务。您可以使用`service`选项为每个附件配置特定的服务：

```ruby
class User < ApplicationRecord
  has_one_attached :avatar, service: :s3
end
```

您可以通过在可附加对象上调用`variant`方法来为每个附件配置特定的变体：

```ruby
class User < ApplicationRecord
  has_one_attached :avatar do |attachable|
    attachable.variant :thumb, resize_to_limit: [100, 100]
  end
end
```

调用`avatar.variant(:thumb)`来获取头像的缩略图变体：

```erb
<%= image_tag user.avatar.variant(:thumb) %>
```

您还可以为预览使用特定的变体：

```ruby
class User < ApplicationRecord
  has_one_attached :video do |attachable|
    attachable.variant :thumb, resize_to_limit: [100, 100]
  end
end
```

```erb
<%= image_tag user.video.preview(:thumb) %>
```


### `has_many_attached`

[`has_many_attached`][]宏设置了记录和文件之间的一对多关系。每个记录可以附加多个文件。

例如，假设您的应用程序有一个`Message`模型。如果您希望每个消息都有多个图像，请定义`Message`模型如下：

```ruby
class Message < ApplicationRecord
  has_many_attached :images
end
```

或者如果您使用的是Rails 6.0+，您可以运行以下模型生成命令：

```ruby
bin/rails generate model Message images:attachments
```

您可以创建一个带有图像的消息：

```ruby
class MessagesController < ApplicationController
  def create
    message = Message.create!(message_params)
    redirect_to message
  end

  private
    def message_params
      params.require(:message).permit(:title, :content, images: [])
    end
end
```

调用[`images.attach`][Attached::Many#attach]将新图像添加到现有消息：

```ruby
@message.images.attach(params[:images])
```

调用[`images.attached?`][Attached::Many#attached?]来确定特定消息是否有任何图像：

```ruby
@message.images.attached?
```

覆盖默认服务的方法与`has_one_attached`相同，使用`service`选项：

```ruby
class Message < ApplicationRecord
  has_many_attached :images, service: :s3
end
```

配置特定变体的方法与`has_one_attached`相同，通过在可附加对象上调用`variant`方法：

```ruby
class Message < ApplicationRecord
  has_many_attached :images do |attachable|
    attachable.variant :thumb, resize_to_limit: [100, 100]
  end
end
```



### 附加文件/IO对象

有时您需要附加一个不是通过HTTP请求到达的文件。例如，您可能希望附加一个在磁盘上生成的文件或从用户提交的URL下载的文件。您还可能希望在模型测试中附加一个固定文件。为此，请提供一个包含至少一个打开的IO对象和一个文件名的哈希：

```ruby
@message.images.attach(io: File.open('/path/to/file'), filename: 'file.pdf')
```

在可能的情况下，还提供内容类型。Active Storage尝试从数据中确定文件的内容类型。如果无法确定，它将使用您提供的内容类型作为后备。
```ruby
@message.images.attach(io: File.open('/path/to/file'), filename: 'file.pdf', content_type: 'application/pdf')
```

您可以通过在`content_type`参数中传入`identify: false`来绕过数据的内容类型推断。

```ruby
@message.images.attach(
  io: File.open('/path/to/file'),
  filename: 'file.pdf',
  content_type: 'application/pdf',
  identify: false
)
```

如果您没有提供内容类型，并且Active Storage无法自动确定文件的内容类型，则默认为`application/octet-stream`。

删除文件
--------------

要从模型中删除附件，请在附件上调用[`purge`][Attached::One#purge]方法。如果您的应用程序设置为使用Active Job，则可以通过调用[`purge_later`][Attached::One#purge_later]方法在后台进行删除。清除操作会从存储服务中删除blob和文件。

```ruby
# 同步销毁头像和实际资源文件。
user.avatar.purge

# 通过Active Job异步销毁关联模型和实际资源文件。
user.avatar.purge_later
```


提供文件
-------------

Active Storage支持两种提供文件的方式：重定向和代理。

警告：默认情况下，所有Active Storage控制器都是公开可访问的。生成的URL很难猜测，但是设计上是永久的。如果您的文件需要更高级别的保护，请考虑实现[身份验证控制器](#authenticated-controllers)。

### 重定向模式

要为blob生成永久URL，可以将blob传递给[`url_for`][ActionView::RoutingUrlFor#url_for]视图助手。这将生成一个带有blob的[`signed_id`][ActiveStorage::Blob#signed_id]的URL，该URL路由到blob的[`RedirectController`][`ActiveStorage::Blobs::RedirectController`]。

```ruby
url_for(user.avatar)
# => /rails/active_storage/blobs/:signed_id/my-avatar.png
```

`RedirectController`将重定向到实际的服务端点。这种间接性将服务URL与实际URL解耦，例如，可以在不同的服务中镜像附件以实现高可用性。重定向具有5分钟的HTTP过期时间。

要创建一个下载链接，可以使用`rails_blob_{path|url}`助手。使用此助手可以设置附件的内容展示方式。

```ruby
rails_blob_path(user.avatar, disposition: "attachment")
```

警告：为了防止XSS攻击，Active Storage会强制将Content-Disposition头设置为某些类型的文件的"attachment"。要更改此行为，请参阅[配置Rails应用程序](configuring.html#configuring-active-storage)中的可用配置选项。

如果您需要在控制器/视图上下文之外创建链接（后台作业、Cron作业等），可以像这样访问`rails_blob_path`：

```ruby
Rails.application.routes.url_helpers.rails_blob_path(user.avatar, only_path: true)
```


### 代理模式

还可以选择代理文件。这意味着您的应用程序服务器将根据请求从存储服务下载文件数据。这对于从CDN提供文件非常有用。

您可以配置Active Storage默认使用代理：

```ruby
# config/initializers/active_storage.rb
Rails.application.config.active_storage.resolve_model_to_route = :rails_storage_proxy
```

或者，如果您想显式代理特定附件，可以使用URL助手，形式为`rails_storage_proxy_path`和`rails_storage_proxy_url`。

```erb
<%= image_tag rails_storage_proxy_path(@user.avatar) %>
```

#### 在Active Storage前面放置CDN

此外，为了在Active Storage附件中使用CDN，您需要生成带有代理模式的URL，以便它们由您的应用程序提供并且CDN将缓存附件而无需任何额外配置。这是因为默认的Active Storage代理控制器设置了一个HTTP头，指示CDN缓存响应。

您还应确保生成的URL使用CDN主机而不是您的应用程序主机。有多种方法可以实现这一点，但通常涉及调整您的`config/routes.rb`文件，以便为附件及其变体生成正确的URL。例如，您可以添加以下内容：

```ruby
# config/routes.rb
direct :cdn_image do |model, options|
  expires_in = options.delete(:expires_in) { ActiveStorage.urls_expire_in }

  if model.respond_to?(:signed_id)
    route_for(
      :rails_service_blob_proxy,
      model.signed_id(expires_in: expires_in),
      model.filename,
      options.merge(host: ENV['CDN_HOST'])
    )
  else
    signed_blob_id = model.blob.signed_id(expires_in: expires_in)
    variation_key  = model.variation.key
    filename       = model.blob.filename

    route_for(
      :rails_blob_representation_proxy,
      signed_blob_id,
      variation_key,
      filename,
      options.merge(host: ENV['CDN_HOST'])
    )
  end
end
```

然后像这样生成路由：

```erb
<%= cdn_image_url(user.avatar.variant(resize_to_limit: [128, 128])) %>
```

### 身份验证控制器

默认情况下，所有Active Storage控制器都是公开可访问的。生成的URL使用普通的[`signed_id`][ActiveStorage::Blob#signed_id]，使其难以猜测但是永久。任何知道blob URL的人都可以访问它，即使`ApplicationController`中的`before_action`要求登录。如果您的文件需要更高级别的保护，可以基于[`ActiveStorage::Blobs::RedirectController`][], [`ActiveStorage::Blobs::ProxyController`][], [`ActiveStorage::Representations::RedirectController`][]和[`ActiveStorage::Representations::ProxyController`][]实现自己的身份验证控制器。

要仅允许帐户访问其自己的标志，可以执行以下操作：
```ruby
# config/routes.rb
resource :account do
  resource :logo
end
```

```ruby
# app/controllers/logos_controller.rb
class LogosController < ApplicationController
  # 通过 ApplicationController:
  # 包括 Authenticate, SetCurrentAccount

  def show
    redirect_to Current.account.logo.url
  end
end
```

```erb
<%= image_tag account_logo_path %>
```

然后你应该使用以下代码禁用Active Storage的默认路由：

```ruby
config.active_storage.draw_routes = false
```

以防止文件通过公共可访问的URL被访问。

下载文件
-----------------

有时候你需要在上传后处理一个blob，例如将其转换为不同的格式。使用附件的[`download`][Blob#download]方法将blob的二进制数据读入内存：

```ruby
binary = user.avatar.download
```

你可能想要将blob下载到磁盘上的文件，以便外部程序（例如病毒扫描器或媒体转码器）可以对其进行操作。使用附件的[`open`][Blob#open]方法将blob下载到磁盘上的临时文件中：

```ruby
message.video.open do |file|
  system '/path/to/virus/scanner', file.path
  # ...
end
```

重要的是要知道文件在`after_create`回调中还不可用，只有在`after_create_commit`中才可用。

分析文件
---------------

Active Storage在上传后通过在Active Job中排队作业来分析文件。分析后的文件将在元数据哈希中存储附加信息，包括`analyzed: true`。您可以通过调用[`analyzed?`][]来检查blob是否已经分析。

图像分析提供`width`和`height`属性。视频分析提供这些属性，以及`duration`、`angle`、`display_aspect_ratio`和`video`和`audio`布尔值来指示这些通道的存在。音频分析提供`duration`和`bit_rate`属性。

显示图像、视频和PDF
---------------

Active Storage支持表示各种文件。您可以在附件上调用[`representation`][]来显示图像变体，或者视频或PDF的预览。在调用`representation`之前，通过调用[`representable?`]检查附件是否可以表示。一些文件格式不能直接通过Active Storage预览（例如Word文档）；如果`representable?`返回false，您可能希望[链接到](#serving-files)文件。

```erb
<ul>
  <% @message.files.each do |file| %>
    <li>
      <% if file.representable? %>
        <%= image_tag file.representation(resize_to_limit: [100, 100]) %>
      <% else %>
        <%= link_to rails_blob_path(file, disposition: "attachment") do %>
          <%= image_tag "placeholder.png", alt: "Download file" %>
        <% end %>
      <% end %>
    </li>
  <% end %>
</ul>
```

在内部，`representation`调用`variant`用于图像，调用`preview`用于可预览的文件。您也可以直接调用这些方法。

### 懒加载与立即加载

默认情况下，Active Storage将延迟处理表示。以下代码：

```ruby
image_tag file.representation(resize_to_limit: [100, 100])
```

将生成一个指向[`ActiveStorage::Representations::RedirectController`][]的`<img>`标签的`src`。浏览器将向该控制器发出请求，该控制器将执行以下操作：

1. 处理文件并在必要时上传处理后的文件。
2. 返回`302`重定向到文件，要么
  * 远程服务（例如S3）。
  * 或者如果启用了[代理模式](#proxy-mode)，则返回文件内容的`ActiveStorage::Blobs::ProxyController`。

延迟加载文件使得像[单次使用URL](#public-access)这样的功能可以在不减慢初始页面加载速度的情况下工作。

这对大多数情况都可以正常工作。

如果您想立即生成图像的URL，可以调用`.processed.url`：

```ruby
image_tag file.representation(resize_to_limit: [100, 100]).processed.url
```

Active Storage变体跟踪器通过在数据库中存储记录来提高性能，如果请求的表示以前已经被处理过。因此，上述代码只会向远程服务（例如S3）发出一次API调用，并且一旦存储了一个变体，就会使用该变体。变体跟踪器会自动运行，但可以通过[`config.active_storage.track_variants`][]禁用。

如果您在页面上渲染大量图像，上面的示例可能会导致N+1查询加载所有变体记录。为了避免这些N+1查询，可以使用[`ActiveStorage::Attachment`][]上的命名范围。

```ruby
message.images.with_all_variant_records.each do |file|
  image_tag file.representation(resize_to_limit: [100, 100]).processed.url
end
```

### 转换图像

转换图像允许您以所选尺寸显示图像。要创建图像的变体，请在附件上调用[`variant`][]。您可以将变体处理器支持的任何转换传递给该方法。当浏览器访问变体URL时，Active Storage将延迟将原始blob转换为指定的格式，并重定向到其新的服务位置。

```erb
<%= image_tag user.avatar.variant(resize_to_limit: [100, 100]) %>
```

如果请求了一个变体，Active Storage将根据图像的格式自动应用转换：

1. 可变的内容类型（由[`config.active_storage.variable_content_types`][]指定）且不被视为Web图像（由[`config.active_storage.web_image_content_types`][]指定）将被转换为PNG格式。

2. 如果未指定`quality`，则将使用变体处理器的默认质量。

Active Storage可以使用[Vips][]或MiniMagick作为变体处理器。默认取决于您的`config.load_defaults`目标版本，并且可以通过设置[`config.active_storage.variant_processor`][]来更改处理器。

这两个处理器不完全兼容，因此在现有应用程序之间迁移MiniMagick和Vips时，如果使用特定于格式的选项，则必须进行一些更改：

```rhtml
<!-- MiniMagick -->
<%= image_tag user.avatar.variant(resize_to_limit: [100, 100], format: :jpeg, sampling_factor: "4:2:0", strip: true, interlace: "JPEG", colorspace: "sRGB", quality: 80) %>

<!-- Vips -->
<%= image_tag user.avatar.variant(resize_to_limit: [100, 100], format: :jpeg, saver: { subsample_mode: "on", strip: true, interlace: true, quality: 80 }) %>
```

可用的参数由[`image_processing`][] gem定义，并取决于您使用的变体处理器，但两者都支持以下参数：

| 参数      | 示例 | 描述 |
| ------------------- | ---------------- | ----- |
| `resize_to_limit` | `resize_to_limit: [100, 100]` | 将图像缩小到适合指定尺寸的范围内，同时保留原始纵横比。仅在图像大于指定尺寸时才会调整图像大小。 |
| `resize_to_fit` | `resize_to_fit: [100, 100]` | 将图像调整为适合指定尺寸的范围内，同时保留原始纵横比。如果图像大于指定尺寸，则缩小图像；如果图像小于指定尺寸，则放大图像。 |
| `resize_to_fill` | `resize_to_fill: [100, 100]` | 将图像调整为填充指定尺寸的范围内，同时保留原始纵横比。如果需要，将在较大的维度上裁剪图像。 |
| `resize_and_pad` | `resize_and_pad: [100, 100]` | 将图像调整为适合指定尺寸的范围内，同时保留原始纵横比。如果需要，如果源图像具有Alpha通道，则使用透明颜色填充剩余区域，否则使用黑色填充。 |
| `crop` | `crop: [20, 50, 300, 300]` | 从图像中提取一个区域。前两个参数是要提取的区域的左边和顶部边缘，最后两个参数是要提取的区域的宽度和高度。 |
| `rotate` | `rotate: 90` | 将图像旋转指定的角度。 |

[`image_processing`][]在其自己的文档中有更多可用选项（例如`saver`，允许配置图像压缩）的信息，适用于[Vips](https://github.com/janko/image_processing/blob/master/doc/vips.md)和[MiniMagick](https://github.com/janko/image_processing/blob/master/doc/minimagick.md)处理器。


### 预览文件

某些非图像文件可以预览，即可以呈现为图像。例如，可以通过提取视频文件的第一帧来预览视频文件。Active Storage默认支持预览视频和PDF文档。要创建指向懒生成的预览的链接，请使用附件的[`preview`][]方法：

```erb
<%= image_tag message.video.preview(resize_to_limit: [100, 100]) %>
```

要添加对另一种格式的支持，请添加自己的预览器。有关更多信息，请参阅[`ActiveStorage::Preview`][]文档。


直接上传
--------------

Active Storage及其包含的JavaScript库支持直接从客户端上传到云端。

### 用法

1. 在应用程序的JavaScript捆绑包中包含`activestorage.js`。

    使用资产管道：

    ```js
    //= require activestorage
    ```

    使用npm包：

    ```js
    import * as ActiveStorage from "@rails/activestorage"
    ActiveStorage.start()
    ```

2. 在[file字段](form_helpers.html#uploading-files)中添加`direct_upload: true`：

    ```erb
    <%= form.file_field :attachments, multiple: true, direct_upload: true %>
    ```

    或者，如果您没有使用`FormBuilder`，直接添加数据属性：

    ```erb
    <input type="file" data-direct-upload-url="<%= rails_direct_uploads_url %>" />
    ```

3. 配置第三方存储服务的CORS以允许直接上传请求。

4. 完成！上传将在表单提交时开始。

### 跨域资源共享（CORS）配置

要使直接上传到第三方服务起作用，您需要配置该服务以允许来自您的应用程序的跨域请求。请参考您服务的CORS文档：

* [S3](https://docs.aws.amazon.com/AmazonS3/latest/dev/cors.html#how-do-i-enable-cors)
* [Google Cloud Storage](https://cloud.google.com/storage/docs/configuring-cors)
* [Azure Storage](https://docs.microsoft.com/en-us/rest/api/storageservices/cross-origin-resource-sharing--cors--support-for-the-azure-storage-services)

请确保允许：

* 所有访问您的应用程序的来源
* `PUT`请求方法
* 以下标头：
  * `Origin`
  * `Content-Type`
  * `Content-MD5`
  * `Content-Disposition`（Azure Storage除外）
  * `x-ms-blob-content-disposition`（仅适用于Azure Storage）
  * `x-ms-blob-type`（仅适用于Azure Storage）
  * `Cache-Control`（仅适用于GCS，仅在设置了`cache_control`时）
由于磁盘服务与应用程序的源相同，因此不需要进行CORS配置。

#### 示例：S3 CORS配置

```json
[
  {
    "AllowedHeaders": [
      "*"
    ],
    "AllowedMethods": [
      "PUT"
    ],
    "AllowedOrigins": [
      "https://www.example.com"
    ],
    "ExposeHeaders": [
      "Origin",
      "Content-Type",
      "Content-MD5",
      "Content-Disposition"
    ],
    "MaxAgeSeconds": 3600
  }
]
```

#### 示例：Google Cloud Storage CORS配置

```json
[
  {
    "origin": ["https://www.example.com"],
    "method": ["PUT"],
    "responseHeader": ["Origin", "Content-Type", "Content-MD5", "Content-Disposition"],
    "maxAgeSeconds": 3600
  }
]
```

#### 示例：Azure Storage CORS配置

```xml
<Cors>
  <CorsRule>
    <AllowedOrigins>https://www.example.com</AllowedOrigins>
    <AllowedMethods>PUT</AllowedMethods>
    <AllowedHeaders>Origin, Content-Type, Content-MD5, x-ms-blob-content-disposition, x-ms-blob-type</AllowedHeaders>
    <MaxAgeInSeconds>3600</MaxAgeInSeconds>
  </CorsRule>
</Cors>
```

### 直接上传JavaScript事件

| 事件名称 | 事件目标 | 事件数据（`event.detail`） | 描述 |
| --- | --- | --- | --- |
| `direct-uploads:start` | `<form>` | 无 | 提交了包含直接上传字段的表单。 |
| `direct-upload:initialize` | `<input>` | `{id, file}` | 在表单提交后的每个文件上触发。 |
| `direct-upload:start` | `<input>` | `{id, file}` | 开始直接上传。 |
| `direct-upload:before-blob-request` | `<input>` | `{id, file, xhr}` | 在向应用程序请求直接上传元数据之前。 |
| `direct-upload:before-storage-request` | `<input>` | `{id, file, xhr}` | 在请求存储文件之前。 |
| `direct-upload:progress` | `<input>` | `{id, file, progress}` | 存储文件的请求进度。 |
| `direct-upload:error` | `<input>` | `{id, file, error}` | 发生错误。除非取消此事件，否则将显示`alert`。 |
| `direct-upload:end` | `<input>` | `{id, file}` | 直接上传结束。 |
| `direct-uploads:end` | `<form>` | 无 | 所有直接上传结束。 |

### 示例

您可以使用这些事件来显示上传的进度。

![direct-uploads](https://user-images.githubusercontent.com/5355/28694528-16e69d0c-72f8-11e7-91a7-c0b8cfc90391.gif)

要在表单中显示已上传的文件：

```js
// direct_uploads.js

addEventListener("direct-upload:initialize", event => {
  const { target, detail } = event
  const { id, file } = detail
  target.insertAdjacentHTML("beforebegin", `
    <div id="direct-upload-${id}" class="direct-upload direct-upload--pending">
      <div id="direct-upload-progress-${id}" class="direct-upload__progress" style="width: 0%"></div>
      <span class="direct-upload__filename"></span>
    </div>
  `)
  target.previousElementSibling.querySelector(`.direct-upload__filename`).textContent = file.name
})

addEventListener("direct-upload:start", event => {
  const { id } = event.detail
  const element = document.getElementById(`direct-upload-${id}`)
  element.classList.remove("direct-upload--pending")
})

addEventListener("direct-upload:progress", event => {
  const { id, progress } = event.detail
  const progressElement = document.getElementById(`direct-upload-progress-${id}`)
  progressElement.style.width = `${progress}%`
})

addEventListener("direct-upload:error", event => {
  event.preventDefault()
  const { id, error } = event.detail
  const element = document.getElementById(`direct-upload-${id}`)
  element.classList.add("direct-upload--error")
  element.setAttribute("title", error)
})

addEventListener("direct-upload:end", event => {
  const { id } = event.detail
  const element = document.getElementById(`direct-upload-${id}`)
  element.classList.add("direct-upload--complete")
})
```

添加样式：

```css
/* direct_uploads.css */

.direct-upload {
  display: inline-block;
  position: relative;
  padding: 2px 4px;
  margin: 0 3px 3px 0;
  border: 1px solid rgba(0, 0, 0, 0.3);
  border-radius: 3px;
  font-size: 11px;
  line-height: 13px;
}

.direct-upload--pending {
  opacity: 0.6;
}

.direct-upload__progress {
  position: absolute;
  top: 0;
  left: 0;
  bottom: 0;
  opacity: 0.2;
  background: #0076ff;
  transition: width 120ms ease-out, opacity 60ms 60ms ease-in;
  transform: translate3d(0, 0, 0);
}

.direct-upload--complete .direct-upload__progress {
  opacity: 0.4;
}

.direct-upload--error {
  border-color: red;
}

input[type=file][data-direct-upload-url][disabled] {
  display: none;
}
```

### 自定义拖放解决方案

您可以使用`DirectUpload`类来实现此目的。从您选择的库中接收文件后，实例化DirectUpload并调用其create方法。create方法接受一个在上传完成时调用的回调函数。

```js
import { DirectUpload } from "@rails/activestorage"

const input = document.querySelector('input[type=file]')

// 绑定文件拖放 - 使用父元素的ondrop或使用Dropzone等库
const onDrop = (event) => {
  event.preventDefault()
  const files = event.dataTransfer.files;
  Array.from(files).forEach(file => uploadFile(file))
}

// 绑定普通文件选择
input.addEventListener('change', (event) => {
  Array.from(input.files).forEach(file => uploadFile(file))
  // 可以清除输入框中选择的文件
  input.value = null
})

const uploadFile = (file) => {
  // 表单需要设置file_field direct_upload: true，这样会提供data-direct-upload-url
  const url = input.dataset.directUploadUrl
  const upload = new DirectUpload(file, url)

  upload.create((error, blob) => {
    if (error) {
      // 处理错误
    } else {
      // 向表单添加一个适当命名的隐藏输入，其值为blob.signed_id，以便在正常上传流程中传输blob id
      const hiddenField = document.createElement('input')
      hiddenField.setAttribute("type", "hidden");
      hiddenField.setAttribute("value", blob.signed_id);
      hiddenField.name = input.name
      document.querySelector('form').appendChild(hiddenField)
    }
  })
}
```

### 跟踪文件上传的进度

在使用`DirectUpload`构造函数时，可以包含第三个参数。这将允许`DirectUpload`对象在上传过程中调用`directUploadWillStoreFileWithXHR`方法。然后，您可以根据需要将自己的进度处理程序附加到XHR上。
```js
import { DirectUpload } from "@rails/activestorage"

class Uploader {
  constructor(file, url) {
    this.upload = new DirectUpload(this.file, this.url, this)
  }

  upload(file) {
    this.upload.create((error, blob) => {
      if (error) {
        // 处理错误
      } else {
        // 在表单中添加一个适当命名的隐藏输入，其值为blob.signed_id
      }
    })
  }

  directUploadWillStoreFileWithXHR(request) {
    request.upload.addEventListener("progress",
      event => this.directUploadDidProgress(event))
  }

  directUploadDidProgress(event) {
    // 使用event.loaded和event.total来更新进度条
  }
}
```

### 与库或框架集成

一旦从所选库中接收到文件，您需要创建一个`DirectUpload`实例，并使用其"create"方法来启动上传过程，根据需要添加任何所需的附加标头。 "create"方法还需要提供一个回调函数，一旦上传完成就会触发该函数。

```js
import { DirectUpload } from "@rails/activestorage"

class Uploader {
  constructor(file, url, token) {
    const headers = { 'Authentication': `Bearer ${token}` }
    // 信息：发送标头是一个可选参数。如果选择不发送标头，身份验证将使用cookie或会话数据进行。
    this.upload = new DirectUpload(this.file, this.url, this, headers)
  }

  upload(file) {
    this.upload.create((error, blob) => {
      if (error) {
        // 处理错误
      } else {
        // 使用blob.signed_id作为下一个请求中的文件引用
      }
    })
  }

  directUploadWillStoreFileWithXHR(request) {
    request.upload.addEventListener("progress",
      event => this.directUploadDidProgress(event))
  }

  directUploadDidProgress(event) {
    // 使用event.loaded和event.total来更新进度条
  }
}
```

要实现自定义身份验证，必须在Rails应用程序上创建一个新的控制器，类似于以下内容：

```ruby
class DirectUploadsController < ActiveStorage::DirectUploadsController
  skip_forgery_protection
  before_action :authenticate!

  def authenticate!
    @token = request.headers['Authorization']&.split&.last

    return head :unauthorized unless valid_token?(@token)
  end
end
```

注意：使用[直接上传](#direct-uploads)有时可能会导致上传的文件不会附加到记录上。考虑[清除未附加的上传](#purging-unattached-uploads)。

测试
-------------------------------------------

使用[`fixture_file_upload`][]在集成或控制器测试中测试上传文件。Rails将文件处理为任何其他参数。

```ruby
class SignupController < ActionDispatch::IntegrationTest
  test "can sign up" do
    post signup_path, params: {
      name: "David",
      avatar: fixture_file_upload("david.png", "image/png")
    }

    user = User.order(:created_at).last
    assert user.avatar.attached?
  end
end
```


### 丢弃测试期间创建的文件

#### 系统测试

系统测试通过回滚事务来清理测试数据。因为对象上从未调用`destroy`，所以附加的文件从未被清理。如果要清除文件，可以在`after_teardown`回调中执行。在这里执行可以确保测试期间创建的所有连接都已完成，您不会收到Active Storage的错误，说找不到文件。

```ruby
class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  # ...
  def after_teardown
    super
    FileUtils.rm_rf(ActiveStorage::Blob.service.root)
  end
  # ...
end
```

如果您使用[并行测试][]和`DiskService`，您应该为每个进程配置自己的Active Storage文件夹。这样，`teardown`回调将仅删除相关进程的测试文件。

```ruby
class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  # ...
  parallelize_setup do |i|
    ActiveStorage::Blob.service.root = "#{ActiveStorage::Blob.service.root}-#{i}"
  end
  # ...
end
```

如果您的系统测试验证了带有附件的模型的删除，并且使用了Active Job，请将测试环境设置为使用内联队列适配器，以便清理作业立即执行，而不是在未来的某个未知时间执行。

```ruby
# 使用内联作业处理使事情立即发生
config.active_job.queue_adapter = :inline
```

[并行测试]: testing.html#parallel-testing

#### 集成测试

与系统测试类似，集成测试期间上传的文件也不会自动清理。如果要清除文件，可以在`teardown`回调中执行。

```ruby
class ActionDispatch::IntegrationTest
  def after_teardown
    super
    FileUtils.rm_rf(ActiveStorage::Blob.service.root)
  end
end
```

如果您使用[并行测试][]和`Disk`服务，您应该为每个进程配置自己的Active Storage文件夹。这样，`teardown`回调将仅删除相关进程的测试文件。

```ruby
class ActionDispatch::IntegrationTest
  parallelize_setup do |i|
    ActiveStorage::Blob.service.root = "#{ActiveStorage::Blob.service.root}-#{i}"
  end
end
```

[并行测试]: testing.html#parallel-testing

### 向夹具添加附件

您可以向现有的[夹具][]中添加附件。首先，您需要创建一个单独的存储服务：

```yml
# config/storage.yml

test_fixtures:
  service: Disk
  root: <%= Rails.root.join("tmp/storage_fixtures") %>
```

这告诉Active Storage将夹具文件"上传"到何处，因此它应该是一个临时目录。通过将其设置为与常规`test`服务不同的目录，您可以将夹具文件与在测试期间上传的文件分开。
接下来，为Active Storage类创建fixture文件：

```yml
# active_storage/attachments.yml
david_avatar:
  name: avatar
  record: david (User)
  blob: david_avatar_blob
```

```yml
# active_storage/blobs.yml
david_avatar_blob: <%= ActiveStorage::FixtureSet.blob filename: "david.png", service_name: "test_fixtures" %>
```

然后在你的fixture目录中放置一个与文件名对应的文件。
有关更多信息，请参阅[`ActiveStorage::FixtureSet`][]文档。

设置完成后，您将能够在测试中访问附件：

```ruby
class UserTest < ActiveSupport::TestCase
  def test_avatar
    avatar = users(:david).avatar

    assert avatar.attached?
    assert_not_nil avatar.download
    assert_equal 1000, avatar.byte_size
  end
end
```

#### 清理Fixture

虽然在测试中上传的文件会在[每个测试结束时](#discarding-files-created-during-tests)被清理，
但您只需要在所有测试完成时清理fixture文件一次。

如果您正在使用并行测试，请调用`parallelize_teardown`：

```ruby
class ActiveSupport::TestCase
  # ...
  parallelize_teardown do |i|
    FileUtils.rm_rf(ActiveStorage::Blob.services.fetch(:test_fixtures).root)
  end
  # ...
end
```

如果您没有运行并行测试，请使用`Minitest.after_run`或您的测试框架的等效方法（例如RSpec的`after(:suite)`）：

```ruby
# test_helper.rb

Minitest.after_run do
  FileUtils.rm_rf(ActiveStorage::Blob.services.fetch(:test_fixtures).root)
end
```


### 配置服务

您可以添加`config/storage/test.yml`来配置在测试环境中使用的服务。
当使用`service`选项时，这非常有用。

```ruby
class User < ApplicationRecord
  has_one_attached :avatar, service: :s3
end
```

如果没有`config/storage/test.yml`，则会使用`config/storage.yml`中配置的`s3`服务 - 即使在运行测试时也是如此。

将使用默认配置，并将文件上传到`config/storage.yml`中配置的服务提供商。

在这种情况下，您可以添加`config/storage/test.yml`并为`s3`服务使用Disk服务以防止发送请求。

```yaml
test:
  service: Disk
  root: <%= Rails.root.join("tmp/storage") %>

s3:
  service: Disk
  root: <%= Rails.root.join("tmp/storage") %>
```

实现对其他云服务的支持
---------------------------------------------

如果您需要支持除这些之外的云服务，您需要实现Service。每个服务都扩展了
[`ActiveStorage::Service`](https://api.rubyonrails.org/classes/ActiveStorage/Service.html)
通过实现将文件上传和下载到云的必要方法。

清除未附加的上传文件
--------------------------

有时文件被上传但从未附加到记录上。这可能发生在使用[直接上传](#direct-uploads)时。您可以使用[unattached scope](https://github.com/rails/rails/blob/8ef5bd9ced351162b673904a0b77c7034ca2bc20/activestorage/app/models/active_storage/blob.rb#L49)查询未附加的记录。下面是使用[自定义rake任务](command_line.html#custom-rake-tasks)的示例。

```ruby
namespace :active_storage do
  desc "Purges unattached Active Storage blobs. Run regularly."
  task purge_unattached: :environment do
    ActiveStorage::Blob.unattached.where(created_at: ..2.days.ago).find_each(&:purge_later)
  end
end
```

警告：`ActiveStorage::Blob.unattached`生成的查询可能在具有较大数据库的应用程序上变慢并且可能会造成干扰。
[`has_one_attached`]: https://api.rubyonrails.org/classes/ActiveStorage/Attached/Model.html#method-i-has_one_attached
[Attached::One#attach]: https://api.rubyonrails.org/classes/ActiveStorage/Attached/One.html#method-i-attach
[Attached::One#attached?]: https://api.rubyonrails.org/classes/ActiveStorage/Attached/One.html#method-i-attached-3F
[`has_many_attached`]: https://api.rubyonrails.org/classes/ActiveStorage/Attached/Model.html#method-i-has_many_attached
[Attached::Many#attach]: https://api.rubyonrails.org/classes/ActiveStorage/Attached/Many.html#method-i-attach
[Attached::Many#attached?]: https://api.rubyonrails.org/classes/ActiveStorage/Attached/Many.html#method-i-attached-3F
[Attached::One#purge]: https://api.rubyonrails.org/classes/ActiveStorage/Attached/One.html#method-i-purge
[Attached::One#purge_later]: https://api.rubyonrails.org/classes/ActiveStorage/Attached/One.html#method-i-purge_later
[ActionView::RoutingUrlFor#url_for]: https://api.rubyonrails.org/classes/ActionView/RoutingUrlFor.html#method-i-url_for
[ActiveStorage::Blob#signed_id]: https://api.rubyonrails.org/classes/ActiveStorage/Blob.html#method-i-signed_id
[`ActiveStorage::Blobs::RedirectController`]: https://api.rubyonrails.org/classes/ActiveStorage/Blobs/RedirectController.html
[`ActiveStorage::Blobs::ProxyController`]: https://api.rubyonrails.org/classes/ActiveStorage/Blobs/ProxyController.html
[`ActiveStorage::Representations::RedirectController`]: https://api.rubyonrails.org/classes/ActiveStorage/Representations/RedirectController.html
[`ActiveStorage::Representations::ProxyController`]: https://api.rubyonrails.org/classes/ActiveStorage/Representations/ProxyController.html
[Blob#download]: https://api.rubyonrails.org/classes/ActiveStorage/Blob.html#method-i-download
[Blob#open]: https://api.rubyonrails.org/classes/ActiveStorage/Blob.html#method-i-open
[`analyzed?`]: https://api.rubyonrails.org/classes/ActiveStorage/Blob/Analyzable.html#method-i-analyzed-3F
[`representable?`]: https://api.rubyonrails.org/classes/ActiveStorage/Blob/Representable.html#method-i-representable-3F
[`representation`]: https://api.rubyonrails.org/classes/ActiveStorage/Blob/Representable.html#method-i-representation
[`config.active_storage.track_variants`]: configuring.html#config-active-storage-track-variants
[`ActiveStorage::Representations::RedirectController`]: https://api.rubyonrails.org/classes/ActiveStorage/Representations/RedirectController.html
[`ActiveStorage::Attachment`]: https://api.rubyonrails.org/classes/ActiveStorage/Attachment.html
[`config.active_storage.variable_content_types`]: configuring.html#config-active-storage-variable-content-types
[`config.active_storage.variant_processor`]: configuring.html#config-active-storage-variant-processor
[`config.active_storage.web_image_content_types`]: configuring.html#config-active-storage-web-image-content-types
[`variant`]: https://api.rubyonrails.org/classes/ActiveStorage/Blob/Representable.html#method-i-variant
[Vips]: https://www.rubydoc.info/gems/ruby-vips/Vips/Image
[`image_processing`]: https://github.com/janko/image_processing
[`preview`]: https://api.rubyonrails.org/classes/ActiveStorage/Blob/Representable.html#method-i-preview
[`ActiveStorage::Preview`]: https://api.rubyonrails.org/classes/ActiveStorage/Preview.html
[`fixture_file_upload`]: https://api.rubyonrails.org/classes/ActionDispatch/TestProcess/FixtureFile.html
[fixtures]: testing.html#the-low-down-on-fixtures
[`ActiveStorage::FixtureSet`]: https://api.rubyonrails.org/classes/ActiveStorage/FixtureSet.html
