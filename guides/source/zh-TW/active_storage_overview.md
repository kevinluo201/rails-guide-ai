**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: b8e9de3d2aa934a8a6fc3e1dccb4824c
Active Storage 概述
=======================

本指南介紹了如何將文件附加到您的 Active Record 模型。

閱讀本指南後，您將了解以下內容：

* 如何將一個或多個文件附加到記錄中。
* 如何刪除附加的文件。
* 如何連結到附加的文件。
* 如何使用變體來轉換圖像。
* 如何生成非圖像文件（如 PDF 或視頻）的圖像表示。
* 如何直接從瀏覽器將文件上傳到存儲服務，繞過應用程序服務器。
* 如何在測試期間清理存儲的文件。
* 如何實現對其他存儲服務的支持。

--------------------------------------------------------------------------------

什麼是 Active Storage？
-----------------------

Active Storage 用於將文件上傳到雲存儲服務（如 Amazon S3、Google Cloud Storage 或 Microsoft Azure Storage）並將這些文件附加到 Active Record 對象上。它提供了一個基於本地磁盤的服務，用於開發和測試，並支持將文件鏡像到從屬服務進行備份和遷移。

使用 Active Storage，應用程序可以轉換圖像上傳或生成非圖像上傳（如 PDF 和視頻）的圖像表示，並從任意文件中提取元數據。

### 要求

Active Storage 的各種功能依賴於 Rails 不會安裝的第三方軟件，必須單獨安裝：

* [libvips](https://github.com/libvips/libvips) v8.6+ 或 [ImageMagick](https://imagemagick.org/index.php) 用於圖像分析和轉換
* [ffmpeg](http://ffmpeg.org/) v3.4+ 用於視頻預覽，ffprobe 用於視頻/音頻分析
* [poppler](https://poppler.freedesktop.org/) 或 [muPDF](https://mupdf.com/) 用於 PDF 預覽

圖像分析和轉換還需要 `image_processing` gem。請在您的 `Gemfile` 中取消註釋它，或在必要時添加它：

```ruby
gem "image_processing", ">= 1.2"
```

提示：相較於 libvips，ImageMagick 更為知名且更廣泛可用。然而，libvips 可以[快達 10 倍並且消耗 1/10 的內存](https://github.com/libvips/libvips/wiki/Speed-and-memory-use)。對於 JPEG 文件，可以通過將 `libjpeg-dev` 替換為 `libjpeg-turbo-dev` 進一步提高性能，後者[快達 2-7 倍](https://libjpeg-turbo.org/About/Performance)。
警告：在安裝和使用第三方軟件之前，請確保您了解這樣做的許可證影響。特別是，MuPDF是根據AGPL許可證授權的，某些用途需要商業許可證。

## 設置

```bash
$ bin/rails active_storage:install
$ bin/rails db:migrate
```

這將設置配置並創建Active Storage使用的三個表：
`active_storage_blobs`、`active_storage_attachments`和`active_storage_variant_records`。

| 表格      | 目的 |
| ------------------- | ----- |
| `active_storage_blobs` | 存儲有關上傳文件的數據，例如文件名和內容類型。 |
| `active_storage_attachments` | 一個多態的連接表，[將您的模型與blobs連接起來](#attaching-files-to-records)。如果您的模型類名更改了，您需要在此表上運行遷移以更新底層的`record_type`為您的模型的新類名。 |
| `active_storage_variant_records` | 如果啟用了[變體跟踪](#attaching-files-to-records)，則存儲已生成的每個變體的記錄。 |

警告：如果您在模型的主鍵上使用UUID而不是整數，您應該在配置文件中設置`Rails.application.config.generators { |g| g.orm :active_record, primary_key_type: :uuid }`。

在`config/storage.yml`中聲明Active Storage服務。對於應用程序使用的每個服務，提供一個名稱和相應的配置。下面的示例聲明了三個名為`local`、`test`和`amazon`的服務：

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

通過設置`Rails.application.config.active_storage.service`告訴Active Storage使用哪個服務。由於每個環境可能使用不同的服務，建議在每個環境上進行設置。要在開發環境中使用前面示例中的磁盤服務，您需要將以下內容添加到`config/environments/development.rb`：

```ruby
# 將文件存儲在本地。
config.active_storage.service = :local
```

要在生產環境中使用S3服務，您需要將以下內容添加到`config/environments/production.rb`：
```ruby
# 在 Amazon S3 上存儲文件。
config.active_storage.service = :amazon
```

在測試時使用測試服務，請在 `config/environments/test.rb` 中添加以下內容：

```ruby
# 在本地文件系統的臨時目錄中存儲上傳的文件。
config.active_storage.service = :test
```

注意：環境特定的配置文件優先級更高：
例如，在生產環境中，如果存在 `config/storage/production.yml` 文件，則該文件將優先於 `config/storage.yml` 文件。

建議在存儲桶名稱中使用 `Rails.env` 以進一步減少意外刪除生產數據的風險。

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

繼續閱讀以獲取有關內置服務適配器（例如 `Disk` 和 `S3`）及其所需配置的更多信息。

### Disk 服務

在 `config/storage.yml` 中聲明一個 Disk 服務：

```yaml
local:
  service: Disk
  root: <%= Rails.root.join("storage") %>
```

### S3 服務（Amazon S3 和兼容 S3 API）

要連接到 Amazon S3，請在 `config/storage.yml` 中聲明一個 S3 服務：

```yaml
amazon:
  service: S3
  access_key_id: ""
  secret_access_key: ""
  region: ""
  bucket: ""
```

可選地提供客戶端和上傳選項：

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

提示：為應用程序設置合理的客戶端 HTTP 超時和重試限制。在某些故障場景中，默認的 AWS 客戶端配置可能導致連接被保持長達數分鐘並導致請求排隊。

將 [`aws-sdk-s3`](https://github.com/aws/aws-sdk-ruby) gem 添加到您的 `Gemfile`：

```ruby
gem "aws-sdk-s3", require: false
```

注意：Active Storage 的核心功能需要以下權限：`s3:ListBucket`、`s3:PutObject`、`s3:GetObject` 和 `s3:DeleteObject`。[公共訪問](#public-access)還需要 `s3:PutObjectAcl`。如果配置了其他上傳選項，例如設置 ACL，則可能需要額外的權限。
注意：如果您想使用環境變數、標準 SDK 配置文件、配置文件、IAM 實例配置文件或任務角色，則可以在上面的示例中省略 `access_key_id`、`secret_access_key` 和 `region` 鍵。S3 服務支持 [AWS SDK 文檔](https://docs.aws.amazon.com/sdk-for-ruby/v3/developer-guide/setup-config.html) 中描述的所有身份驗證選項。

要連接到 S3 兼容的對象存儲 API（例如 DigitalOcean Spaces），請提供 `endpoint`：

```yaml
digitalocean:
  service: S3
  endpoint: https://nyc3.digitaloceanspaces.com
  access_key_id: ...
  secret_access_key: ...
  # ...和其他選項
```

還有許多其他選項可用。您可以在 [AWS S3 Client](https://docs.aws.amazon.com/sdk-for-ruby/v3/api/Aws/S3/Client.html#initialize-instance_method) 文檔中檢查它們。

### Microsoft Azure 儲存服務

在 `config/storage.yml` 中聲明 Azure 儲存服務：

```yaml
azure:
  service: AzureStorage
  storage_account_name: ""
  storage_access_key: ""
  container: ""
```

將 [`azure-storage-blob`](https://github.com/Azure/azure-storage-ruby) gem 添加到您的 `Gemfile`：

```ruby
gem "azure-storage-blob", "~> 2.0", require: false
```

### Google Cloud 儲存服務

在 `config/storage.yml` 中聲明 Google Cloud 儲存服務：

```yaml
google:
  service: GCS
  credentials: <%= Rails.root.join("path/to/keyfile.json") %>
  project: ""
  bucket: ""
```

可選地，可以提供一個憑證的 Hash，而不是憑證文件路徑：

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

可選地，提供 Cache-Control 元數據以設置上傳資源的快取控制：

```yaml
google:
  service: GCS
  ...
  cache_control: "public, max-age=3600"
```

可選地在簽署 URL 時使用 [IAM](https://cloud.google.com/storage/docs/access-control/signed-urls#signing-iam) 而不是 `credentials`。如果您正在使用 Workload Identity 對 GKE 應用進行身份驗證，這將非常有用，請參閱 [Google Cloud 博客文章](https://cloud.google.com/blog/products/containers-kubernetes/introducing-workload-identity-better-authentication-for-your-gke-applications) 了解更多信息。

```yaml
google:
  service: GCS
  ...
  iam: true
```

可選地在簽署 URL 時使用特定的 GSA。在使用 IAM 時，將聯繫 [元數據服務器](https://cloud.google.com/compute/docs/storing-retrieving-metadata) 以獲取 GSA 電子郵件，但是此元數據服務器並不總是存在（例如本地測試），您可能希望使用非默認 GSA。
```yaml
google:
  service: GCS
  ...
  iam: true
  gsa_email: "foobar@baz.iam.gserviceaccount.com"
```

在您的`Gemfile`中添加[`google-cloud-storage`](https://github.com/GoogleCloudPlatform/google-cloud-ruby/tree/master/google-cloud-storage) gem：

```ruby
gem "google-cloud-storage", "~> 1.11", require: false
```

### 鏡像服務

您可以通過定義鏡像服務來保持多個服務的同步。鏡像服務將上傳和刪除操作複製到兩個或多個從屬服務中。

鏡像服務旨在在生產環境中在服務之間進行遷移時暫時使用。您可以開始將鏡像服務鏡像到新服務，將舊服務中的預先存在的文件複製到新服務，然後完全使用新服務。

注意：鏡像不是原子操作。在主服務上上傳成功並在任何從屬服務上失敗是可能的。在完全使用新服務之前，請驗證所有文件是否已複製。

根據上述描述定義您想要鏡像的每個服務。在定義鏡像服務時，使用名稱引用它們：

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

儘管所有次要服務都會接收上傳，但下載始終由主服務處理。

鏡像服務與直接上傳兼容。新文件直接上傳到主服務。當直接上傳的文件附加到記錄時，會將後台作業加入佇列以將其複製到次要服務。

### 公開訪問

默認情況下，Active Storage假設對服務進行私有訪問。這意味著為blob生成簽名的一次性URL。如果您希望使blob公開訪問，請在應用的`config/storage.yml`中指定`public: true`：

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

確保您的存儲桶已正確配置以進行公開訪問。有關如何為[Amazon S3](https://docs.aws.amazon.com/AmazonS3/latest/user-guide/block-public-access-bucket.html)、[Google Cloud Storage](https://cloud.google.com/storage/docs/access-control/making-data-public#buckets)和[Microsoft Azure](https://docs.microsoft.com/en-us/azure/storage/blobs/storage-manage-access-to-resources#set-container-public-access-level-in-the-azure-portal)存儲服務啟用公開讀取權限的文檔。Amazon S3還要求您具有`s3:PutObjectAcl`權限。
當將現有應用程式轉換為使用 `public: true` 時，請確保在切換之前更新存儲桶中的每個單獨文件為可公開讀取。

將文件附加到記錄
--------------------------

### `has_one_attached`

[`has_one_attached`][] 宏設置了記錄和文件之間的一對一映射關係。每個記錄可以附加一個文件。

例如，假設您的應用程式有一個 `User` 模型。如果您希望每個用戶都有一個頭像，可以如下定義 `User` 模型：

```ruby
class User < ApplicationRecord
  has_one_attached :avatar
end
```

或者如果您使用的是 Rails 6.0+，您可以運行以下模型生成器命令：

```ruby
bin/rails generate model User avatar:attachment
```

您可以使用以下代碼創建帶有頭像的用戶：

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

使用 [`avatar.attach`][Attached::One#attach] 將頭像附加到現有用戶：

```ruby
user.avatar.attach(params[:avatar])
```

使用 [`avatar.attached?`][Attached::One#attached?] 確定特定用戶是否有頭像：

```ruby
user.avatar.attached?
```

在某些情況下，您可能希望為特定附件覆蓋默認服務。您可以使用 `service` 選項為每個附件配置特定的服務：

```ruby
class User < ApplicationRecord
  has_one_attached :avatar, service: :s3
end
```

您可以通過在可附加對象上調用 `variant` 方法來為每個附件配置特定的變體：

```ruby
class User < ApplicationRecord
  has_one_attached :avatar do |attachable|
    attachable.variant :thumb, resize_to_limit: [100, 100]
  end
end
```

使用 `avatar.variant(:thumb)` 獲取頭像的縮略圖變體：

```erb
<%= image_tag user.avatar.variant(:thumb) %>
```

您也可以為預覽使用特定的變體：

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

[`has_many_attached`][] 宏設置了記錄和文件之間的一對多關係。每個記錄可以附加多個文件。
例如，假設您的應用程式有一個 `Message` 模型。如果您希望每個訊息都有多個圖片，請按照以下方式定義 `Message` 模型：

```ruby
class Message < ApplicationRecord
  has_many_attached :images
end
```

或者如果您使用的是 Rails 6.0+，您可以執行以下模型生成器命令：

```ruby
bin/rails generate model Message images:attachments
```

您可以創建一個帶有圖片的訊息：

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

調用 [`images.attach`][Attached::Many#attach] 來將新圖片添加到現有訊息：

```ruby
@message.images.attach(params[:images])
```

調用 [`images.attached?`][Attached::Many#attached?] 來判斷特定訊息是否有任何圖片：

```ruby
@message.images.attached?
```

覆蓋默認服務的方式與 `has_one_attached` 相同，使用 `service` 選項：

```ruby
class Message < ApplicationRecord
  has_many_attached :images, service: :s3
end
```

配置特定變體的方式與 `has_one_attached` 相同，通過在生成的可附加對象上調用 `variant` 方法：

```ruby
class Message < ApplicationRecord
  has_many_attached :images do |attachable|
    attachable.variant :thumb, resize_to_limit: [100, 100]
  end
end
```



### 附加文件/IO物件

有時候您需要附加一個不是通過HTTP請求傳遞的文件。
例如，您可能希望附加一個在磁盤上生成或從用戶提交的URL下載的文件。
您也可能希望在模型測試中附加一個固定的文件。
為此，提供一個包含至少一個打開的IO物件和文件名的Hash：

```ruby
@message.images.attach(io: File.open('/path/to/file'), filename: 'file.pdf')
```

在可能的情況下，請提供內容類型。
Active Storage會嘗試從數據中確定文件的內容類型。
如果無法確定，則會使用您提供的內容類型。

```ruby
@message.images.attach(io: File.open('/path/to/file'), filename: 'file.pdf', content_type: 'application/pdf')
```

您可以通過傳遞 `identify: false` 和 `content_type` 一起來繞過從數據推斷內容類型。
```ruby
@message.images.attach(
  io: File.open('/path/to/file'),
  filename: 'file.pdf',
  content_type: 'application/pdf',
  identify: false
)
```

如果您沒有提供內容類型，並且Active Storage無法自動確定文件的內容類型，則默認為application/octet-stream。

刪除文件
--------------

要從模型中刪除附件，請在附件上調用[`purge`][Attached::One#purge]。如果您的應用程序設置為使用Active Job，則可以通過調用[`purge_later`][Attached::One#purge_later]在後台進行刪除。清除操作會刪除blob和存儲服務中的文件。

```ruby
# 同步銷毀頭像和實際資源文件。
user.avatar.purge

# 通過Active Job異步銷毀相關模型和實際資源文件。
user.avatar.purge_later
```


提供文件
-------------

Active Storage支持兩種提供文件的方式：重定向和代理。

警告：默認情況下，所有Active Storage控制器都是公開訪問的。生成的URL很難猜測，但設計上是永久的。如果您的文件需要更高級的保護，請考慮實現[驗證控制器](#authenticated-controllers)。

### 重定向模式

要為blob生成永久URL，可以將blob傳遞給[`url_for`][ActionView::RoutingUrlFor#url_for]視圖助手。這將生成一個URL，其中包含blob的[`signed_id`][ActiveStorage::Blob#signed_id]，該URL將路由到blob的[`RedirectController`][`ActiveStorage::Blobs::RedirectController`]

```ruby
url_for(user.avatar)
# => /rails/active_storage/blobs/:signed_id/my-avatar.png
```

`RedirectController`將重定向到實際的服務端點。這種間接性將服務URL與實際URL解耦，並且允許在不同服務中鏡像附件以實現高可用性。重定向的HTTP過期時間為5分鐘。

要創建下載鏈接，請使用`rails_blob_{path|url}`助手。使用此助手可以設置disposition。

```ruby
rails_blob_path(user.avatar, disposition: "attachment")
```

警告：為了防止XSS攻擊，Active Storage將Content-Disposition標頭強制為某些文件的"attachment"。要更改此行為，請參閱[配置Rails應用程序](configuring.html#configuring-active-storage)中的可用配置選項。

如果您需要在控制器/視圖上下文之外創建鏈接（後台作業，Cron作業等），可以像這樣訪問`rails_blob_path`：
```ruby
Rails.application.routes.url_helpers.rails_blob_path(user.avatar, only_path: true)
```

### 代理模式

可選擇使用代理模式來處理文件。這意味著您的應用伺服器將根據請求從儲存服務下載文件數據。這對於從 CDN 服務器提供文件非常有用。

您可以設置 Active Storage 默認使用代理模式：

```ruby
# config/initializers/active_storage.rb
Rails.application.config.active_storage.resolve_model_to_route = :rails_storage_proxy
```

或者，如果您想要明確地代理特定的附件，可以使用 URL 輔助方法 `rails_storage_proxy_path` 和 `rails_storage_proxy_url`。

```erb
<%= image_tag rails_storage_proxy_path(@user.avatar) %>
```

#### 在 Active Storage 前使用 CDN

此外，為了在 Active Storage 附件中使用 CDN，您需要生成使用代理模式的 URL，以便它們由您的應用伺服器提供並且 CDN 可以緩存附件，而無需進行任何額外的配置。這是因為默認的 Active Storage 代理控制器會設置一個 HTTP 標頭，指示 CDN 緩存響應。

您還應該確保生成的 URL 使用 CDN 主機而不是您的應用主機。有多種方法可以實現這一點，但通常涉及微調您的 `config/routes.rb` 文件，以便您可以為附件及其變體生成正確的 URL。例如，您可以添加以下內容：

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

然後像這樣生成路由：

```erb
<%= cdn_image_url(user.avatar.variant(resize_to_limit: [128, 128])) %>
```

### 驗證控制器

默認情況下，所有的 Active Storage 控制器都是公開可訪問的。生成的 URL 使用普通的 [`signed_id`][ActiveStorage::Blob#signed_id]，使其難以猜測但是永久有效。任何知道 blob URL 的人都可以訪問它，即使在您的 `ApplicationController` 中的 `before_action` 要求登錄。如果您的文件需要更高級的保護，您可以根據 [`ActiveStorage::Blobs::RedirectController`]、[`ActiveStorage::Blobs::ProxyController`]、[`ActiveStorage::Representations::RedirectController`] 和 [`ActiveStorage::Representations::ProxyController`] 實現自己的驗證控制器。
要僅允許帳戶訪問自己的標誌，您可以執行以下操作：

```ruby
# config/routes.rb
resource :account do
  resource :logo
end
```

```ruby
# app/controllers/logos_controller.rb
class LogosController < ApplicationController
  # 通過 ApplicationController：
  # 包括身份驗證，設置當前帳戶

  def show
    redirect_to Current.account.logo.url
  end
end
```

```erb
<%= image_tag account_logo_path %>
```

然後，您應該使用以下代碼禁用Active Storage的默認路由：

```ruby
config.active_storage.draw_routes = false
```

以防止通過公開訪問的URL訪問文件。


下載文件
-----------------

有時候，您需要在上傳後處理blob，例如將其轉換為不同的格式。使用附件的[`download`][Blob#download]方法將blob的二進制數據讀入內存：

```ruby
binary = user.avatar.download
```

您可能希望將blob下載到磁盤上的文件，以便外部程序（例如病毒掃描器或媒體轉碼器）可以對其進行操作。使用附件的[`open`][Blob#open]方法將blob下載到磁盤上的臨時文件：

```ruby
message.video.open do |file|
  system '/path/to/virus/scanner', file.path
  # ...
end
```

重要的是要知道該文件在`after_create`回調中還不可用，只有在`after_create_commit`中才可用。


分析文件
---------------

Active Storage在上傳文件後通過在Active Job中排隊作業來分析文件。分析後的文件將在元數據哈希中存儲其他信息，包括`analyzed: true`。您可以通過在其上調用[`analyzed?`][]來檢查blob是否已經分析。

圖像分析提供`width`和`height`屬性。視頻分析提供這些屬性，以及`duration`、`angle`、`display_aspect_ratio`和`video`和`audio`布爾值，以指示這些通道的存在。音頻分析提供`duration`和`bit_rate`屬性。


顯示圖像、視頻和PDF
---------------

Active Storage支持表示各種文件。您可以在附件上調用[`representation`][]以顯示圖像變體，或者視頻或PDF的預覽。在調用`representation`之前，通過調用[`representable?`]檢查附件是否可以表示。某些文件格式無法直接由Active Storage預覽（例如Word文檔）；如果`representable?`返回false，您可能希望[鏈接到](#serving-files)該文件。
```erb
<ul>
  <% @message.files.each do |file| %>
    <li>
      <% if file.representable? %>
        <%= image_tag file.representation(resize_to_limit: [100, 100]) %>
      <% else %>
        <%= link_to rails_blob_path(file, disposition: "attachment") do %>
          <%= image_tag "placeholder.png", alt: "下載檔案" %>
        <% end %>
      <% end %>
    </li>
  <% end %>
</ul>
```

內部，`representation` 方法會為圖片呼叫 `variant`，並為可預覽的檔案呼叫 `preview`。您也可以直接呼叫這些方法。

### 延遲載入 vs 立即載入

預設情況下，Active Storage 會延遲處理圖片的表示。以下程式碼：

```ruby
image_tag file.representation(resize_to_limit: [100, 100])
```

會產生一個 `<img>` 標籤，`src` 屬性指向 [`ActiveStorage::Representations::RedirectController`][]。瀏覽器會向該控制器發出請求，該控制器會執行以下操作：

1. 處理檔案，並在必要時上傳處理後的檔案。
2. 返回 `302` 重新導向到檔案，可能是
   * 遠端服務（例如 S3）。
   * 或者如果啟用了[代理模式](#proxy-mode)，則返回檔案內容的 `ActiveStorage::Blobs::ProxyController`。

延遲載入檔案可以使[單次使用 URL](#public-access)等功能在不減慢初始頁面載入速度的情況下正常運作。

這對大多數情況都適用。

如果您想立即生成圖片的 URL，可以呼叫 `.processed.url`：

```ruby
image_tag file.representation(resize_to_limit: [100, 100]).processed.url
```

Active Storage 變體追踪器通過在資料庫中存儲記錄，提高了此操作的效能，如果已經處理過所需的表示，則只會向遠端服務（例如 S3）發出一次 API 請求，並且一旦存儲了變體，就會使用該變體。變體追踪器會自動運行，但可以通過 [`config.active_storage.track_variants`][] 進行禁用。

如果您在頁面上渲染大量圖片，上述示例可能會導致 N+1 查詢，從而加載所有變體記錄。為了避免這些 N+1 查詢，可以使用 [`ActiveStorage::Attachment`][] 上的命名範圍。

```ruby
message.images.with_all_variant_records.each do |file|
  image_tag file.representation(resize_to_limit: [100, 100]).processed.url
end
```

### 轉換圖片
圖像轉換允許您以所選的尺寸顯示圖像。
要創建圖像的變體，請在附件上調用[`variant`]方法。您可以將變體處理器支持的任何轉換傳遞給該方法。
當瀏覽器訪問變體URL時，Active Storage將懶惰地將原始blob轉換為指定的格式並重定向到其新的服務位置。

```erb
<%= image_tag user.avatar.variant(resize_to_limit: [100, 100]) %>
```

如果請求了變體，Active Storage將根據圖像的格式自動應用轉換：

1. 可變的內容類型（由[`config.active_storage.variable_content_types`]指定）且不被視為Web圖像（由[`config.active_storage.web_image_content_types`]指定）的內容類型將被轉換為PNG。

2. 如果未指定`quality`，則將使用變體處理器的格式的默認質量。

Active Storage可以使用[Vips]或MiniMagick作為變體處理器。
默認值取決於您的`config.load_defaults`目標版本，並且可以通過設置[`config.active_storage.variant_processor`]來更改處理器。

這兩個處理器不完全兼容，因此在使用特定於格式的選項時，從MiniMagick遷移現有應用程序到Vips時，需要進行一些更改：

```rhtml
<!-- MiniMagick -->
<%= image_tag user.avatar.variant(resize_to_limit: [100, 100], format: :jpeg, sampling_factor: "4:2:0", strip: true, interlace: "JPEG", colorspace: "sRGB", quality: 80) %>

<!-- Vips -->
<%= image_tag user.avatar.variant(resize_to_limit: [100, 100], format: :jpeg, saver: { subsample_mode: "on", strip: true, interlace: true, quality: 80 }) %>
```

可用的參數由[`image_processing`] gem定義，取決於您正在使用的變體處理器，但兩者都支持以下參數：

| 參數      | 範例 | 描述 |
| ------------------- | ---------------- | ----- |
| `resize_to_limit` | `resize_to_limit: [100, 100]` | 將圖像縮小到符合指定尺寸，同時保留原始長寬比。僅在圖像大於指定尺寸時才會調整圖像大小。 |
| `resize_to_fit` | `resize_to_fit: [100, 100]` | 將圖像調整為符合指定尺寸，同時保留原始長寬比。如果圖像大於指定尺寸，則會縮小圖像；如果圖像小於指定尺寸，則會放大圖像。 |
| `resize_to_fill` | `resize_to_fill: [100, 100]` | 將圖像調整為填滿指定尺寸，同時保留原始長寬比。如果需要，將在較大的尺寸上裁剪圖像。 |
| `resize_and_pad` | `resize_and_pad: [100, 100]` | 將圖像調整為符合指定尺寸，同時保留原始長寬比。如果需要，如果源圖像具有alpha通道，則使用透明顏色填充剩餘區域，否則使用黑色填充。 |
| `crop` | `crop: [20, 50, 300, 300]` | 從圖像中提取區域。前兩個參數是要提取的區域的左邊緣和上邊緣，後兩個參數是要提取的區域的寬度和高度。 |
| `rotate` | `rotate: 90` | 將圖像旋轉指定的角度。 |
[`image_processing`][]在其自己的文檔中提供了更多選項（例如`saver`，允許配置圖像壓縮）的[Vips](https://github.com/janko/image_processing/blob/master/doc/vips.md)和[MiniMagick](https://github.com/janko/image_processing/blob/master/doc/minimagick.md)處理器的文檔。

### 預覽文件

某些非圖像文件可以進行預覽，即可以呈現為圖像。例如，可以通過提取視頻文件的第一幀來預覽視頻。Active Storage支持預覽視頻和PDF文檔。要創建到懶惰生成的預覽的鏈接，請使用附件的[`preview`][]方法：

```erb
<%= image_tag message.video.preview(resize_to_limit: [100, 100]) %>
```

要添加對另一種格式的支持，請添加自己的預覽器。有關更多信息，請參見[`ActiveStorage::Preview`][]文檔。

直接上傳
--------------

Active Storage及其附帶的JavaScript庫支持從客戶端直接上傳到雲端。

### 用法

1. 在應用程序的JavaScript捆綁包中包含`activestorage.js`。

    使用資源管道：

    ```js
    //= require activestorage
    ```

    使用npm包：

    ```js
    import * as ActiveStorage from "@rails/activestorage"
    ActiveStorage.start()
    ```

2. 在[file field](form_helpers.html#uploading-files)中添加`direct_upload: true`：

    ```erb
    <%= form.file_field :attachments, multiple: true, direct_upload: true %>
    ```

    或者，如果您不使用`FormBuilder`，直接添加數據屬性：

    ```erb
    <input type="file" data-direct-upload-url="<%= rails_direct_uploads_url %>" />
    ```

3. 將CORS配置為允許第三方存儲服務進行直接上傳請求。

4. 完成！上傳將在表單提交時開始。

### 跨域資源共享（CORS）配置

要使對第三方服務的直接上傳工作，您需要配置該服務以允許您的應用程序進行跨域請求。請參考您服務的CORS文檔：

* [S3](https://docs.aws.amazon.com/AmazonS3/latest/dev/cors.html#how-do-i-enable-cors)
* [Google Cloud Storage](https://cloud.google.com/storage/docs/configuring-cors)
* [Azure Storage](https://docs.microsoft.com/en-us/rest/api/storageservices/cross-origin-resource-sharing--cors--support-for-the-azure-storage-services)

請確保允許：

* 您的應用程序所訪問的所有來源
* `PUT`請求方法
* 以下標頭：
  * `Origin`
  * `Content-Type`
  * `Content-MD5`
  * `Content-Disposition`（Azure Storage除外）
  * `x-ms-blob-content-disposition`（僅適用於Azure Storage）
  * `x-ms-blob-type`（僅適用於Azure Storage）
  * `Cache-Control`（僅適用於GCS，僅在設置了`cache_control`時）
磁碟服務不需要CORS配置，因為它與應用程式的來源共享。

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

### 直接上傳JavaScript事件

| 事件名稱 | 事件目標 | 事件數據 (`event.detail`) | 描述 |
| --- | --- | --- | --- |
| `direct-uploads:start` | `<form>` | 無 | 提交包含直接上傳字段的表單。 |
| `direct-upload:initialize` | `<input>` | `{id, file}` | 表單提交後的每個文件都會觸發。 |
| `direct-upload:start` | `<input>` | `{id, file}` | 開始直接上傳。 |
| `direct-upload:before-blob-request` | `<input>` | `{id, file, xhr}` | 在向應用程式請求直接上傳元數據之前。 |
| `direct-upload:before-storage-request` | `<input>` | `{id, file, xhr}` | 在請求存儲文件之前。 |
| `direct-upload:progress` | `<input>` | `{id, file, progress}` | 存儲文件的請求進度。 |
| `direct-upload:error` | `<input>` | `{id, file, error}` | 發生錯誤。除非取消此事件，否則將顯示`alert`。 |
| `direct-upload:end` | `<input>` | `{id, file}` | 直接上傳結束。 |
| `direct-uploads:end` | `<form>` | 無 | 所有直接上傳結束。 |

### 示例

您可以使用這些事件來顯示上傳的進度。

![direct-uploads](https://user-images.githubusercontent.com/5355/28694528-16e69d0c-72f8-11e7-91a7-c0b8cfc90391.gif)

要在表單中顯示上傳的文件：

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

您可以使用`DirectUpload`类来实现此目的。从您选择的库中接收到文件后，实例化一个DirectUpload并调用其create方法。create方法接受一个在上传完成时调用的回调函数。

```js
import { DirectUpload } from "@rails/activestorage"

const input = document.querySelector('input[type=file]')

// 绑定文件拖放 - 使用父元素的ondrop事件或使用
//  Dropzone等库
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
  // 表单需要设置file_field direct_upload: true，
  // 以提供data-direct-upload-url
  const url = input.dataset.directUploadUrl
  const upload = new DirectUpload(file, url)

  upload.create((error, blob) => {
    if (error) {
      // 处理错误
    } else {
      // 向表单添加一个适当命名的隐藏输入，其值为blob.signed_id，
      // 以便在正常的上传流程中传输blob id
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
        // 處理錯誤
      } else {
        // 在表單中新增一個適當命名的隱藏輸入，其值為 blob.signed_id
      }
    })
  }

  directUploadWillStoreFileWithXHR(request) {
    request.upload.addEventListener("progress",
      event => this.directUploadDidProgress(event))
  }

  directUploadDidProgress(event) {
    // 使用 event.loaded 和 event.total 更新進度條
  }
}
```

### 與庫或框架集成

一旦從所選的庫中接收到文件，您需要創建一個 `DirectUpload` 實例，並使用其 "create" 方法來啟動上傳過程，根據需要添加任何必需的額外標頭。 "create" 方法還需要提供一個回調函數，該回調函數將在上傳完成後觸發。

```js
import { DirectUpload } from "@rails/activestorage"

class Uploader {
  constructor(file, url, token) {
    const headers = { 'Authentication': `Bearer ${token}` }
    // 訊息：傳送標頭是一個可選參數。如果您選擇不傳送標頭，則將使用 cookie 或會話數據進行身份驗證。
    this.upload = new DirectUpload(this.file, this.url, this, headers)
  }

  upload(file) {
    this.upload.create((error, blob) => {
      if (error) {
        // 處理錯誤
      } else {
        // 使用 blob.signed_id 作為下一個請求中的文件參考
      }
    })
  }

  directUploadWillStoreFileWithXHR(request) {
    request.upload.addEventListener("progress",
      event => this.directUploadDidProgress(event))
  }

  directUploadDidProgress(event) {
    // 使用 event.loaded 和 event.total 更新進度條
  }
}
```

要實現自定義身份驗證，必須在 Rails 應用程序上創建一個新的控制器，類似於以下示例：

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

注意：使用 [Direct Uploads](#direct-uploads) 有時可能會導致上傳的文件未附加到記錄中。請考慮 [清除未附加的上傳](#purging-unattached-uploads)。
測試
-------------------------------------------

在整合測試或控制器測試中使用[`fixture_file_upload`][]來測試上傳文件。Rails將文件處理為任何其他參數。

```ruby
class SignupController < ActionDispatch::IntegrationTest
  test "可以註冊" do
    post signup_path, params: {
      name: "David",
      avatar: fixture_file_upload("david.png", "image/png")
    }

    user = User.order(:created_at).last
    assert user.avatar.attached?
  end
end
```


### 測試期間丟棄創建的文件

#### 系統測試

系統測試通過回滾事務來清理測試數據。因為對象上從未調用`destroy`方法，所以附加的文件從未被清理。如果你想清除這些文件，可以在`after_teardown`回調中執行。在這裡執行可以確保測試期間創建的所有連接都已完成，並且你不會收到Active Storage無法找到文件的錯誤。

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

如果你使用[parallel tests][]和`DiskService`，你應該配置每個進程使用自己的文件夾來存儲Active Storage。這樣，`teardown`回調只會刪除相關進程的測試文件。

```ruby
class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  # ...
  parallelize_setup do |i|
    ActiveStorage::Blob.service.root = "#{ActiveStorage::Blob.service.root}-#{i}"
  end
  # ...
end
```

如果你的系統測試驗證了帶有附件的模型的刪除操作，並且你使用Active Job，請將測試環境設置為使用內聯佇列適配器，以便立即執行清除作業，而不是在未來的某個未知時間執行。

```ruby
# 使用內聯作業處理，使事情立即發生
config.active_job.queue_adapter = :inline
```

[parallel tests]: testing.html#parallel-testing

#### 整合測試

與系統測試類似，整合測試期間上傳的文件也不會自動清理。如果你想清除這些文件，可以在`teardown`回調中執行。

```ruby
class ActionDispatch::IntegrationTest
  def after_teardown
    super
    FileUtils.rm_rf(ActiveStorage::Blob.service.root)
  end
end
```

如果你使用[parallel tests][]和`Disk`服務，你應該配置每個進程使用自己的文件夾來存儲Active Storage。這樣，`teardown`回調只會刪除相關進程的測試文件。
```ruby
class ActionDispatch::IntegrationTest
  parallelize_setup do |i|
    ActiveStorage::Blob.service.root = "#{ActiveStorage::Blob.service.root}-#{i}"
  end
end
```

[平行測試]: testing.html#parallel-testing

### 在固定裝置中添加附件

您可以將附件添加到現有的[固定裝置][]中。首先，您需要創建一個單獨的存儲服務：

```yml
# config/storage.yml

test_fixtures:
  service: Disk
  root: <%= Rails.root.join("tmp/storage_fixtures") %>
```

這告訴Active Storage將固定裝置文件“上傳”到哪裡，因此它應該是一個臨時目錄。通過將其設置為與常規的`test`服務不同的目錄，您可以將固定裝置文件與測試期間上傳的文件分開。

接下來，為Active Storage類創建固定裝置文件：

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

然後，在您的固定裝置目錄中放置一個文件（默認路徑為`test/fixtures/files`），並具有相應的文件名。有關更多信息，請參見[`ActiveStorage::FixtureSet`][]文檔。

一切都設置好後，您將能夠在測試中訪問附件：

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

#### 清理固定裝置

雖然在測試中上傳的文件會在[每個測試結束時清理](#discarding-files-created-during-tests)，但您只需要在所有測試完成時清理固定裝置文件一次。

如果您正在使用平行測試，請調用`parallelize_teardown`：

```ruby
class ActiveSupport::TestCase
  # ...
  parallelize_teardown do |i|
    FileUtils.rm_rf(ActiveStorage::Blob.services.fetch(:test_fixtures).root)
  end
  # ...
end
```

如果您不運行平行測試，請使用`Minitest.after_run`或您的測試框架的等效方法（例如RSpec的`after(:suite)`）：

```ruby
# test_helper.rb

Minitest.after_run do
  FileUtils.rm_rf(ActiveStorage::Blob.services.fetch(:test_fixtures).root)
end
```


### 配置服務

您可以添加`config/storage/test.yml`以配置在測試環境中使用的服務。這在使用`service`選項時非常有用。

```ruby
class User < ApplicationRecord
  has_one_attached :avatar, service: :s3
end
```

如果沒有`config/storage/test.yml`，則將使用在`config/storage.yml`中配置的`s3`服務 - 即使在運行測試時也是如此。
預設配置將會使用並將文件上傳到在 `config/storage.yml` 中配置的服務提供商。

在這種情況下，您可以添加 `config/storage/test.yml` 並使用 Disk 服務作為 `s3` 服務，以防止發送請求。

```yaml
test:
  service: Disk
  root: <%= Rails.root.join("tmp/storage") %>

s3:
  service: Disk
  root: <%= Rails.root.join("tmp/storage") %>
```

實現對其他雲服務的支援
------------------------

如果您需要支援除這些之外的雲服務，您需要實現該服務。每個服務都擴展了 [`ActiveStorage::Service`](https://api.rubyonrails.org/classes/ActiveStorage/Service.html)，通過實現上傳和下載文件到雲端所需的方法。

清除未附加的上傳文件
--------------------

有些情況下，文件已上傳但從未附加到記錄中。這可能發生在使用[直接上傳](#direct-uploads)時。您可以使用 [unattached scope](https://github.com/rails/rails/blob/8ef5bd9ced351162b673904a0b77c7034ca2bc20/activestorage/app/models/active_storage/blob.rb#L49) 查詢未附加的記錄。以下是使用[自定義 rake 任務](command_line.html#custom-rake-tasks)的示例。

```ruby
namespace :active_storage do
  desc "清除未附加的 Active Storage blobs。定期運行。"
  task purge_unattached: :environment do
    ActiveStorage::Blob.unattached.where(created_at: ..2.days.ago).find_each(&:purge_later)
  end
end
```

警告：`ActiveStorage::Blob.unattached` 生成的查詢可能在具有較大數據庫的應用程序上變慢並且可能造成干擾。
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
