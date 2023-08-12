**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: b8e9de3d2aa934a8a6fc3e1dccb4824c
Active Storage 개요
=======================

이 가이드는 Active Record 모델에 파일을 첨부하는 방법에 대해 다룹니다.

이 가이드를 읽은 후에는 다음을 알게 될 것입니다:

* 레코드에 하나 또는 여러 파일을 첨부하는 방법.
* 첨부된 파일을 삭제하는 방법.
* 첨부된 파일에 링크하는 방법.
* 이미지를 변환하기 위해 변형을 사용하는 방법.
* PDF나 비디오와 같은 비-이미지 파일의 이미지 표현을 생성하는 방법.
* 브라우저에서 직접 파일 업로드를 스토리지 서비스로 보내서 애플리케이션 서버를 우회하는 방법.
* 테스트 중에 저장된 파일을 정리하는 방법.
* 추가적인 스토리지 서비스를 지원하기 위한 구현 방법.

--------------------------------------------------------------------------------

Active Storage란 무엇인가?
-----------------------

Active Storage는 클라우드 스토리지 서비스인 Amazon S3, Google Cloud Storage 또는 Microsoft Azure Storage에 파일을 업로드하고 해당 파일을 Active Record 객체에 첨부하는 것을 용이하게 해줍니다. 개발 및 테스트를 위한 로컬 디스크 기반 서비스를 제공하며, 백업 및 마이그레이션을 위해 하위 서비스로 파일을 미러링하는 기능을 지원합니다.

Active Storage를 사용하면 애플리케이션은 이미지 업로드를 변환하거나 PDF 및 비디오와 같은 비-이미지 업로드의 이미지 표현을 생성하고 임의의 파일에서 메타데이터를 추출할 수 있습니다.

### 요구 사항

Active Storage의 다양한 기능은 Rails가 별도로 설치하지 않는 제3자 소프트웨어에 의존합니다. 따라서 별도로 설치해야 합니다:

* 이미지 분석 및 변환을 위한 [libvips](https://github.com/libvips/libvips) v8.6+ 또는 [ImageMagick](https://imagemagick.org/index.php)
* 비디오 미리보기를 위한 [ffmpeg](http://ffmpeg.org/) v3.4+ 및 비디오/오디오 분석을 위한 ffprobe
* PDF 미리보기를 위한 [poppler](https://poppler.freedesktop.org/) 또는 [muPDF](https://mupdf.com/)

이미지 분석 및 변환에는 `image_processing` 젬도 필요합니다. `Gemfile`에서 주석 처리를 해제하거나 필요한 경우 추가해야 합니다:

```ruby
gem "image_processing", ">= 1.2"
```

팁: libvips에 비해 ImageMagick은 더 잘 알려져 있고 보다 널리 사용되고 있습니다. 그러나 libvips는 [10배 빠르고 메모리 사용량이 1/10](https://github.com/libvips/libvips/wiki/Speed-and-memory-use)입니다. JPEG 파일의 경우, 이를 `libjpeg-dev`에서 `libjpeg-turbo-dev`로 대체하여 성능을 [2-7배 향상](https://libjpeg-turbo.org/About/Performance)시킬 수 있습니다.

경고: 제3자 소프트웨어를 설치하고 사용하기 전에 해당 소프트웨어의 라이선스 영향을 이해하는지 확인하십시오. 특히 MuPDF는 AGPL로 라이선스가 부여되어 있으며 일부 사용에는 상업적 라이선스가 필요합니다.

## 설정

```bash
$ bin/rails active_storage:install
$ bin/rails db:migrate
```

이렇게 하면 구성이 설정되고 Active Storage가 사용하는 세 개의 테이블 `active_storage_blobs`, `active_storage_attachments`, `active_storage_variant_records`가 생성됩니다.

| 테이블      | 용도 |
| ------------------- | ----- |
| `active_storage_blobs` | 파일 업로드에 대한 데이터를 저장합니다. 파일 이름 및 콘텐츠 유형과 같은 정보가 포함됩니다. |
| `active_storage_attachments` | [레코드에 파일을 첨부](#attaching-files-to-records)하기 위해 다형성 조인 테이블입니다. 모델의 클래스 이름이 변경되면 이 테이블에 대한 마이그레이션을 실행하여 기존의 `record_type`을 모델의 새 클래스 이름으로 업데이트해야 합니다. |
| `active_storage_variant_records` | [변형 추적](#attaching-files-to-records)이 활성화된 경우 생성된 각 변형에 대한 레코드를 저장합니다. |

경고: 모델의 기본 키로 정수 대신 UUID를 사용하는 경우, 구성 파일에서 `Rails.application.config.generators { |g| g.orm :active_record, primary_key_type: :uuid }`를 설정해야 합니다.

`config/storage.yml`에서 Active Storage 서비스를 선언합니다. 애플리케이션이 사용하는 각 서비스에 대해 이름과 필요한 구성을 제공합니다. 아래 예제는 `local`, `test`, `amazon`이라는 세 개의 서비스를 선언합니다:

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
  region: "" # 예: 'us-east-1'
```

Active Storage가 사용할 서비스를 설정하기 위해 `Rails.application.config.active_storage.service`를 설정합니다. 각 환경마다 다른 서비스를 사용할 것이므로, 환경별로 설정하는 것이 좋습니다. 이전 예제의 디스크 서비스를 개발 환경에서 사용하려면 `config/environments/development.rb`에 다음을 추가합니다:

```ruby
# 파일을 로컬에 저장합니다.
config.active_storage.service = :local
```

프로덕션에서 S3 서비스를 사용하려면 `config/environments/production.rb`에 다음을 추가합니다:

```ruby
# 파일을 Amazon S3에 저장합니다.
config.active_storage.service = :amazon
```

테스트할 때 테스트 서비스를 사용하려면 `config/environments/test.rb`에 다음을 추가합니다:

```ruby
# 업로드된 파일을 임시 디렉토리에 로컬 파일 시스템에 저장합니다.
config.active_storage.service = :test
```

참고: 환경별로 설정된 구성 파일이 우선합니다. 예를 들어, 프로덕션에서는 `config/storage/production.yml` 파일(있는 경우)이 `config/storage.yml` 파일보다 우선합니다.

실수로 프로덕션 데이터를 삭제하는 위험을 줄이기 위해 버킷 이름에 `Rails.env`를 사용하는 것이 좋습니다.

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

내장된 서비스 어댑터 (예: `Disk` 및 `S3`) 및 그들이 요구하는 구성에 대한 자세한 정보를 읽어보세요.

### Disk 서비스

`config/storage.yml`에서 Disk 서비스를 선언하세요:

```yaml
local:
  service: Disk
  root: <%= Rails.root.join("storage") %>
```

### S3 서비스 (Amazon S3 및 S3 호환 API)

Amazon S3에 연결하려면 `config/storage.yml`에서 S3 서비스를 선언하세요:

```yaml
amazon:
  service: S3
  access_key_id: ""
  secret_access_key: ""
  region: ""
  bucket: ""
```

클라이언트 및 업로드 옵션을 선택적으로 제공할 수 있습니다:

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
    server_side_encryption: "" # 'aws:kms' 또는 'AES256'
    cache_control: "private, max-age=<%= 1.day.to_i %>"
```

팁: 응용 프로그램에 합리적인 클라이언트 HTTP 타임아웃과 재시도 제한을 설정하세요. 일부 실패 시나리오에서는 기본 AWS 클라이언트 구성으로 인해 연결이 여러 분 동안 유지되고 요청 대기열이 발생할 수 있습니다.

`Gemfile`에 [`aws-sdk-s3`](https://github.com/aws/aws-sdk-ruby) 젬을 추가하세요:

```ruby
gem "aws-sdk-s3", require: false
```

참고: Active Storage의 핵심 기능에는 다음 권한이 필요합니다: `s3:ListBucket`, `s3:PutObject`, `s3:GetObject` 및 `s3:DeleteObject`. [공개 액세스](#public-access)는 추가로 `s3:PutObjectAcl`도 필요합니다. ACL을 설정하는 등 추가 업로드 옵션이 구성된 경우 추가 권한이 필요할 수 있습니다.

참고: 환경 변수, 표준 SDK 구성 파일, 프로필, IAM 인스턴스 프로필 또는 작업 역할을 사용하려면 위의 예제에서 `access_key_id`, `secret_access_key` 및 `region` 키를 생략할 수 있습니다. S3 서비스는 [AWS SDK 문서](https://docs.aws.amazon.com/sdk-for-ruby/v3/developer-guide/setup-config.html)에 설명된 모든 인증 옵션을 지원합니다.

DigitalOcean Spaces와 같은 S3 호환 객체 스토리지 API에 연결하려면 `endpoint`를 제공하세요:

```yaml
digitalocean:
  service: S3
  endpoint: https://nyc3.digitaloceanspaces.com
  access_key_id: ...
  secret_access_key: ...
  # ...그리고 다른 옵션들
```

사용 가능한 다른 옵션들이 많이 있습니다. [AWS S3 Client](https://docs.aws.amazon.com/sdk-for-ruby/v3/api/Aws/S3/Client.html#initialize-instance_method) 문서에서 확인할 수 있습니다.

### Microsoft Azure Storage 서비스

`config/storage.yml`에서 Azure Storage 서비스를 선언하세요:

```yaml
azure:
  service: AzureStorage
  storage_account_name: ""
  storage_access_key: ""
  container: ""
```

`Gemfile`에 [`azure-storage-blob`](https://github.com/Azure/azure-storage-ruby) 젬을 추가하세요:

```ruby
gem "azure-storage-blob", "~> 2.0", require: false
```

### Google Cloud Storage 서비스

`config/storage.yml`에서 Google Cloud Storage 서비스를 선언하세요:

```yaml
google:
  service: GCS
  credentials: <%= Rails.root.join("path/to/keyfile.json") %>
  project: ""
  bucket: ""
```

키 파일 경로 대신 자격 증명의 해시를 제공할 수도 있습니다:

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

업로드된 자산에 설정할 Cache-Control 메타데이터를 선택적으로 제공할 수 있습니다:

```yaml
google:
  service: GCS
  ...
  cache_control: "public, max-age=3600"
```

URL에 서명할 때 `credentials` 대신 [IAM](https://cloud.google.com/storage/docs/access-control/signed-urls#signing-iam)을 사용할 수도 있습니다. 이는 GKE 애플리케이션을 Workload Identity로 인증하는 경우 유용합니다. 자세한 내용은 [Google Cloud 블로그 게시물](https://cloud.google.com/blog/products/containers-kubernetes/introducing-workload-identity-better-authentication-for-your-gke-applications)을 참조하세요.

```yaml
google:
  service: GCS
  ...
  iam: true
```

URL에 서명할 때 특정 GSA를 사용할 수도 있습니다. IAM을 사용할 때는 GSA 이메일을 가져오기 위해 [메타데이터 서버](https://cloud.google.com/compute/docs/storing-retrieving-metadata)에 연락할 것입니다. 그러나 이 메타데이터 서버는 항상 존재하지 않을 수 있으며 (예: 로컬 테스트), 기본 GSA 대신 다른 GSA를 사용하고 싶을 수도 있습니다.

```yaml
google:
  service: GCS
  ...
  iam: true
  gsa_email: "foobar@baz.iam.gserviceaccount.com"
```

`Gemfile`에 [`google-cloud-storage`](https://github.com/GoogleCloudPlatform/google-cloud-ruby/tree/master/google-cloud-storage) 젬을 추가하세요:

```ruby
gem "google-cloud-storage", "~> 1.11", require: false
```

### Mirror 서비스

거울 서비스를 정의하여 여러 서비스를 동기화할 수 있습니다. 거울 서비스는 업로드와 삭제를 두 개 이상의 하위 서비스에 복제합니다.

거울 서비스는 프로덕션에서 서비스 간 마이그레이션 중 일시적으로 사용하기 위해 설계되었습니다. 새로운 서비스에 거울링을 시작하고 이전 서비스에서 기존 파일을 새로운 서비스로 복사한 다음 새로운 서비스에 완전히 전환할 수 있습니다.

참고: 거울링은 원자적이지 않습니다. 업로드가 기본 서비스에서 성공하고 하위 서비스 중 하나에서 실패할 수 있습니다. 새로운 서비스로 완전히 전환하기 전에 모든 파일이 복사되었는지 확인하세요.

위에서 설명한 대로 거울링하려는 각 서비스를 정의하세요. 거울 서비스를 정의할 때 이름으로 참조하세요:

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

모든 보조 서비스는 업로드를 받지만, 다운로드는 항상 기본 서비스에서 처리됩니다.

거울 서비스는 직접 업로드와 호환됩니다. 새 파일은 직접 기본 서비스에 업로드됩니다. 직접 업로드된 파일이 레코드에 첨부되면 백그라운드 작업이 예약되어 보조 서비스로 복사됩니다.
### 공개 액세스

기본적으로 Active Storage는 서비스에 대한 비공개 액세스를 가정합니다. 이는 블롭에 대해 서명된 일회용 URL을 생성하는 것을 의미합니다. 블롭을 공개적으로 액세스할 수 있게 하려면 앱의 `config/storage.yml`에서 `public: true`를 지정하십시오:

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

버킷이 공개 액세스를 위해 올바르게 구성되어 있는지 확인하십시오. [Amazon S3](https://docs.aws.amazon.com/AmazonS3/latest/user-guide/block-public-access-bucket.html), [Google Cloud Storage](https://cloud.google.com/storage/docs/access-control/making-data-public#buckets) 및 [Microsoft Azure](https://docs.microsoft.com/en-us/azure/storage/blobs/storage-manage-access-to-resources#set-container-public-access-level-in-the-azure-portal) 스토리지 서비스에서 공개 읽기 권한을 활성화하는 방법에 대한 문서를 참조하십시오. Amazon S3는 추가로 `s3:PutObjectAcl` 권한이 필요합니다.

`public: true`를 사용하도록 기존 애플리케이션을 변환할 때는 전환하기 전에 버킷의 각 개별 파일을 공개 읽기 가능하도록 업데이트하는 것을 잊지 마십시오.

레코드에 파일 첨부하기
--------------------------

### `has_one_attached`

[`has_one_attached`][] 매크로는 레코드와 파일 간의 일대일 매핑을 설정합니다. 각 레코드에는 하나의 첨부 파일이 있을 수 있습니다.

예를 들어, 애플리케이션에 `User` 모델이 있다고 가정해 보겠습니다. 각 사용자에게 아바타를 제공하려면 다음과 같이 `User` 모델을 정의하십시오:

```ruby
class User < ApplicationRecord
  has_one_attached :avatar
end
```

또는 Rails 6.0+를 사용하는 경우 다음과 같이 모델 생성 명령을 실행할 수 있습니다:

```ruby
bin/rails generate model User avatar:attachment
```

아바타가 있는 사용자를 만들 수 있습니다:

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

기존 사용자에게 아바타를 첨부하려면 [`avatar.attach`][Attached::One#attach]를 호출하십시오:

```ruby
user.avatar.attach(params[:avatar])
```

특정 사용자가 아바타를 가지고 있는지 확인하려면 [`avatar.attached?`][Attached::One#attached?]를 호출하십시오:

```ruby
user.avatar.attached?
```

일부 경우에는 특정 첨부 파일에 대해 기본 서비스를 재정의하고 싶을 수 있습니다. `service` 옵션을 사용하여 첨부마다 특정 서비스를 구성할 수 있습니다:

```ruby
class User < ApplicationRecord
  has_one_attached :avatar, service: :s3
end
```

`variant` 메서드를 호출하여 첨부마다 특정 변형을 구성할 수 있습니다:

```ruby
class User < ApplicationRecord
  has_one_attached :avatar do |attachable|
    attachable.variant :thumb, resize_to_limit: [100, 100]
  end
end
```

아바타의 썸네일 변형을 얻으려면 `avatar.variant(:thumb)`를 호출하십시오:

```erb
<%= image_tag user.avatar.variant(:thumb) %>
```

미리보기에 특정 변형을 사용할 수도 있습니다:

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

[`has_many_attached`][] 매크로는 레코드와 파일 간의 일대다 관계를 설정합니다. 각 레코드에는 여러 파일이 첨부될 수 있습니다.

예를 들어, 애플리케이션에 `Message` 모델이 있다고 가정해 보겠습니다. 각 메시지에 여러 이미지를 첨부하려면 다음과 같이 `Message` 모델을 정의하십시오:

```ruby
class Message < ApplicationRecord
  has_many_attached :images
end
```

또는 Rails 6.0+를 사용하는 경우 다음과 같이 모델 생성 명령을 실행할 수 있습니다:

```ruby
bin/rails generate model Message images:attachments
```

이미지가 있는 메시지를 만들 수 있습니다:

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

기존 메시지에 새 이미지를 추가하려면 [`images.attach`][Attached::Many#attach]를 호출하십시오:

```ruby
@message.images.attach(params[:images])
```

특정 메시지에 이미지가 있는지 확인하려면 [`images.attached?`][Attached::Many#attached?]를 호출하십시오:

```ruby
@message.images.attached?
```

기본 서비스를 재정의하는 방법은 `has_one_attached`와 동일하게 `service` 옵션을 사용하여 수행할 수 있습니다:

```ruby
class Message < ApplicationRecord
  has_many_attached :images, service: :s3
end
```

특정 변형을 구성하는 방법도 `has_one_attached`와 동일하게 `variant` 메서드를 호출하여 수행할 수 있습니다:

```ruby
class Message < ApplicationRecord
  has_many_attached :images do |attachable|
    attachable.variant :thumb, resize_to_limit: [100, 100]
  end
end
```



### 파일/IO 객체 첨부하기

가끔 HTTP 요청을 통해 도착하지 않는 파일을 첨부해야 할 때가 있습니다. 예를 들어, 디스크에서 생성한 파일이나 사용자가 제출한 URL에서 다운로드한 파일을 첨부하려는 경우입니다. 또는 모델 테스트에서 fixture 파일을 첨부하려는 경우일 수도 있습니다. 이를 위해 최소한 열린 IO 객체와 파일 이름을 포함하는 해시를 제공하십시오:

```ruby
@message.images.attach(io: File.open('/path/to/file'), filename: 'file.pdf')
```

가능한 경우 콘텐츠 유형도 제공하십시오. Active Storage는 파일의 콘텐츠 유형을 데이터에서 결정하려고 시도합니다. 그렇게 할 수 없는 경우 제공한 콘텐츠 유형을 사용합니다.
```ruby
@message.images.attach(io: File.open('/path/to/file'), filename: 'file.pdf', content_type: 'application/pdf')
```

`identify: false`를 `content_type`와 함께 전달하여 데이터로부터 콘텐츠 유형 추론을 우회할 수 있습니다.

```ruby
@message.images.attach(
  io: File.open('/path/to/file'),
  filename: 'file.pdf',
  content_type: 'application/pdf',
  identify: false
)
```

콘텐츠 유형을 제공하지 않고 Active Storage가 파일의 콘텐츠 유형을 자동으로 결정할 수 없는 경우, 기본값으로 application/octet-stream을 사용합니다.


파일 제거
--------------

모델에서 첨부 파일을 제거하려면 첨부 파일에 대해 [`purge`][Attached::One#purge]를 호출하십시오. 애플리케이션이 Active Job을 사용하도록 설정된 경우, 제거 작업은 [`purge_later`][Attached::One#purge_later]를 호출하여 백그라운드에서 수행할 수도 있습니다. Purge는 블롭과 저장소 서비스에서 파일을 삭제합니다.

```ruby
# 아바타와 실제 리소스 파일을 동기적으로 삭제합니다.
user.avatar.purge

# 연관된 모델과 실제 리소스 파일을 비동기적으로 삭제합니다. Active Job을 통해 수행됩니다.
user.avatar.purge_later
```


파일 제공
-------------

Active Storage는 두 가지 방법으로 파일을 제공할 수 있습니다: 리다이렉트와 프록시.

경고: 모든 Active Storage 컨트롤러는 기본적으로 공개적으로 접근 가능합니다. 생성된 URL은 추측하기 어렵지만, 의도적으로 영구적입니다. 파일이 더 높은 수준의 보호를 필요로 하는 경우 [인증된 컨트롤러](#authenticated-controllers)를 구현하는 것을 고려하십시오.

### 리다이렉트 모드

블롭에 대한 영구적인 URL을 생성하려면 블롭을 [`url_for`][ActionView::RoutingUrlFor#url_for] 뷰 헬퍼에 전달하면 됩니다. 이렇게 하면 블롭의 [`signed_id`][ActiveStorage::Blob#signed_id]를 사용하여 블롭의 [`RedirectController`][`ActiveStorage::Blobs::RedirectController`]로 라우팅되는 URL이 생성됩니다.

```ruby
url_for(user.avatar)
# => /rails/active_storage/blobs/:signed_id/my-avatar.png
```

`RedirectController`는 실제 서비스 엔드포인트로 리디렉션합니다. 이 리디렉션은 서비스 URL과 실제 URL을 분리시키고, 예를 들어 고가용성을 위해 다른 서비스에 첨부 파일을 미러링하는 것을 가능하게 합니다. 리디렉션은 HTTP 만료 시간이 5분입니다.

다운로드 링크를 생성하려면 `rails_blob_{path|url}` 헬퍼를 사용하십시오. 이 헬퍼를 사용하면 디스포지션을 설정할 수 있습니다.

```ruby
rails_blob_path(user.avatar, disposition: "attachment")
```

경고: XSS 공격을 방지하기 위해 Active Storage는 일부 유형의 파일에 대해 Content-Disposition 헤더를 "attachment"로 강제합니다. 이 동작을 변경하려면 [레일즈 애플리케이션 구성](configuring.html#configuring-active-storage)에서 사용 가능한 구성 옵션을 참조하십시오.

컨트롤러/뷰 컨텍스트 외부에서 링크를 생성해야 하는 경우(백그라운드 작업, 크론 작업 등), 다음과 같이 `rails_blob_path`에 접근할 수 있습니다.

```ruby
Rails.application.routes.url_helpers.rails_blob_path(user.avatar, only_path: true)
```


### 프록시 모드

선택적으로 파일을 프록시로 제공할 수도 있습니다. 이는 애플리케이션 서버가 요청에 대한 응답으로 저장소 서비스에서 파일 데이터를 다운로드하는 것을 의미합니다. 이는 CDN에서 파일을 제공하는 데 유용할 수 있습니다.

Active Storage를 기본적으로 프록시로 사용하도록 구성할 수 있습니다.

```ruby
# config/initializers/active_storage.rb
Rails.application.config.active_storage.resolve_model_to_route = :rails_storage_proxy
```

또는 특정 첨부 파일을 명시적으로 프록시로 설정하려면 `rails_storage_proxy_path`와 `rails_storage_proxy_url` 형태의 URL 헬퍼를 사용할 수 있습니다.

```erb
<%= image_tag rails_storage_proxy_path(@user.avatar) %>
```

#### Active Storage 앞에 CDN 배치하기

또한 Active Storage 첨부 파일에 CDN을 사용하려면 프록시 모드로 URL을 생성하여 앱에서 제공되고 CDN이 추가 구성 없이 첨부 파일을 캐시하도록해야 합니다. 이는 기본 Active Storage 프록시 컨트롤러가 응답을 캐시하기 위해 CDN에게 알리는 HTTP 헤더를 설정하기 때문에 기본적으로 작동합니다.

또한 생성된 URL이 앱 호스트 대신 CDN 호스트를 사용하도록 해야 합니다. 이를 달성하는 여러 가지 방법이 있지만, 일반적으로 `config/routes.rb` 파일을 조정하여 첨부 파일 및 해당 변형에 대한 올바른 URL을 생성할 수 있도록 해야 합니다. 예를 들어 다음과 같이 추가할 수 있습니다.

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

그런 다음 다음과 같이 라우트를 생성할 수 있습니다.

```erb
<%= cdn_image_url(user.avatar.variant(resize_to_limit: [128, 128])) %>
```

### 인증된 컨트롤러

모든 Active Storage 컨트롤러는 기본적으로 공개적으로 접근 가능합니다. 생성된 URL은 일반 [`signed_id`][ActiveStorage::Blob#signed_id]를 사용하므로 추측하기 어렵지만 영구적입니다. 누구든지 블롭 URL을 알고 있다면 `ApplicationController`의 `before_action`에서 로그인이 필요한 경우에도 액세스할 수 있습니다. 파일이 더 높은 수준의 보호를 필요로 하는 경우, [`ActiveStorage::Blobs::RedirectController`][], [`ActiveStorage::Blobs::ProxyController`][], [`ActiveStorage::Representations::RedirectController`][] 및 [`ActiveStorage::Representations::ProxyController`][]를 기반으로 사용자 정의 인증 컨트롤러를 구현할 수 있습니다.

계정이 자체 로고에만 액세스할 수 있도록 하려면 다음과 같이 할 수 있습니다.
```ruby
# config/routes.rb
resource :account do
  resource :logo
end
```

```ruby
# app/controllers/logos_controller.rb
class LogosController < ApplicationController
  # ApplicationController를 통해:
  # Authenticate, SetCurrentAccount을 포함시킵니다.

  def show
    redirect_to Current.account.logo.url
  end
end
```

```erb
<%= image_tag account_logo_path %>
```

그리고 다음과 같이 Active Storage의 기본 라우트를 비활성화해야 합니다:

```ruby
config.active_storage.draw_routes = false
```

이렇게 하면 파일이 공개적으로 접근 가능한 URL을 통해 액세스되는 것을 방지할 수 있습니다.


파일 다운로드
-----------------

가끔은 업로드된 blob을 처리해야 할 때가 있습니다. 예를 들어, 다른 형식으로 변환하기 위해. blob의 이진 데이터를 메모리로 읽기 위해 첨부 파일의 [`download`][Blob#download] 메소드를 사용하세요:

```ruby
binary = user.avatar.download
```

외부 프로그램(예: 바이러스 스캐너 또는 미디어 변환기)이 작동할 수 있도록 blob을 디스크의 파일로 다운로드하려면 첨부 파일의 [`open`][Blob#open] 메소드를 사용하세요:

```ruby
message.video.open do |file|
  system '/path/to/virus/scanner', file.path
  # ...
end
```

`after_create` 콜백에서 파일을 사용할 수 없지만 `after_create_commit`에서만 사용할 수 있다는 사실을 알고 있어야 합니다.


파일 분석
---------------

Active Storage는 파일이 업로드된 후에 작업을 큐에 넣어 작업을 수행하여 파일을 분석합니다. 분석된 파일은 메타데이터 해시에 추가 정보를 저장하며, `analyzed: true`와 같은 값을 포함합니다. blob이 분석되었는지 여부를 확인하려면 [`analyzed?`][]를 호출하세요.

이미지 분석은 `width`와 `height` 속성을 제공합니다. 비디오 분석은 이러한 속성뿐만 아니라 `duration`, `angle`, `display_aspect_ratio`, `video` 및 `audio` 부울 값을 제공하여 해당 채널의 존재 여부를 나타냅니다. 오디오 분석은 `duration`과 `bit_rate` 속성을 제공합니다.


이미지, 비디오 및 PDF 표시
---------------

Active Storage는 다양한 파일을 표시할 수 있습니다. 첨부 파일에 대해 [`representation`][]을 호출하여 이미지 변형이나 비디오 또는 PDF의 미리보기를 표시할 수 있습니다. `representation`을 호출하기 전에 [`representable?`]를 호출하여 첨부 파일이 표시될 수 있는지 확인하세요. 일부 파일 형식은 Active Storage에서 기본적으로 미리보기할 수 없습니다(예: Word 문서). `representable?`이 false를 반환하면 [파일을](#serving-files) 링크하는 것이 좋습니다.

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

내부적으로 `representation`은 이미지에 대해 `variant`를 호출하고, 미리보기 가능한 파일에 대해서는 `preview`를 호출합니다. 이러한 메소드를 직접 호출할 수도 있습니다.


### 지연 로딩 vs 즉시 로딩

기본적으로 Active Storage는 표현을 지연적으로 처리합니다. 다음 코드:

```ruby
image_tag file.representation(resize_to_limit: [100, 100])
```

`<img>` 태그를 생성하고 `src`가 [`ActiveStorage::Representations::RedirectController`][]를 가리키도록 합니다. 브라우저는 해당 컨트롤러에 요청을 보내고 다음 작업을 수행합니다:

1. 파일을 처리하고 필요한 경우 처리된 파일을 업로드합니다.
2. 파일을 반환합니다. 이때,
  * 원격 서비스(예: S3)로 리디렉션합니다.
  * 또는 [프록시 모드](#proxy-mode)가 활성화된 경우 `ActiveStorage::Blobs::ProxyController`가 파일 내용을 반환합니다.

파일을 지연적으로 로드하면 [단일 사용 URL](#public-access)과 같은 기능을 초기 페이지 로드를 늦추지 않고 작동할 수 있습니다.

대부분의 경우에는 이 방법이 잘 작동합니다.

이미지에 대한 URL을 즉시 생성하려면 `.processed.url`을 호출할 수 있습니다:

```ruby
image_tag file.representation(resize_to_limit: [100, 100]).processed.url
```

Active Storage 변형 추적기는 요청된 표현이 이전에 처리되었는지 여부를 데이터베이스에 기록함으로써 이를 개선합니다. 따라서 위의 코드는 원격 서비스(예: S3)로의 API 호출을 한 번만 수행하며, 한 번 변형이 저장되면 해당 변형을 사용합니다. 변형 추적기는 자동으로 실행되지만 [`config.active_storage.track_variants`][]를 통해 비활성화할 수 있습니다.

페이지에서 많은 이미지를 렌더링하는 경우 위의 예제는 모든 변형 레코드를 로드하는 N+1 쿼리를 실행할 수 있습니다. 이러한 N+1 쿼리를 피하려면 [`ActiveStorage::Attachment`][]의 네임드 스코프를 사용하세요.

```ruby
message.images.with_all_variant_records.each do |file|
  image_tag file.representation(resize_to_limit: [100, 100]).processed.url
end
```


### 이미지 변환

이미지 변환을 통해 이미지를 원하는 크기로 표시할 수 있습니다. 첨부 파일에 대해 [`variant`][]를 호출하여 이미지 변형을 생성할 수 있습니다. 메소드에 변형 프로세서에서 지원하는 어떤 변환도 전달할 수 있습니다. 브라우저가 변형 URL에 접근하면 Active Storage는 원본 blob을 지정된 형식으로 지연적으로 변환하고 새로운 서비스 위치로 리디렉션합니다.

```erb
<%= image_tag user.avatar.variant(resize_to_limit: [100, 100]) %>
```
변형이 요청되면 Active Storage는 이미지의 형식에 따라 자동으로 변환을 적용합니다:

1. [`config.active_storage.variable_content_types`][]에 의해 지정된대로 가변적인 콘텐츠 유형 및 [`config.active_storage.web_image_content_types`][]에 의해 웹 이미지로 간주되지 않는 콘텐츠 유형은 PNG로 변환됩니다.

2. `quality`가 지정되지 않은 경우, 변형 프로세서의 형식에 대한 기본 품질이 사용됩니다.

Active Storage는 [Vips][] 또는 MiniMagick을 변형 프로세서로 사용할 수 있습니다.
기본값은 `config.load_defaults` 대상 버전에 따라 다르며,
[`config.active_storage.variant_processor`][]를 설정하여 프로세서를 변경할 수 있습니다.

두 프로세서는 완전히 호환되지 않으므로 기존 응용 프로그램을 MiniMagick에서 Vips로 마이그레이션할 때
형식별 옵션을 사용하는 경우 일부 변경이 필요합니다:

```rhtml
<!-- MiniMagick -->
<%= image_tag user.avatar.variant(resize_to_limit: [100, 100], format: :jpeg, sampling_factor: "4:2:0", strip: true, interlace: "JPEG", colorspace: "sRGB", quality: 80) %>

<!-- Vips -->
<%= image_tag user.avatar.variant(resize_to_limit: [100, 100], format: :jpeg, saver: { subsample_mode: "on", strip: true, interlace: true, quality: 80 }) %>
```

사용 가능한 매개변수는 [`image_processing`][] 젬에 의해 정의되며 사용 중인 변형 프로세서에 따라 다릅니다.
하지만 두 프로세서 모두 다음 매개변수를 지원합니다:

| 매개변수      | 예제 | 설명 |
| ------------------- | ---------------- | ----- |
| `resize_to_limit` | `resize_to_limit: [100, 100]` | 지정된 크기 내에 이미지를 조정하면서 원래의 가로 세로 비율을 유지합니다. 지정된 크기보다 이미지가 큰 경우에만 이미지 크기를 조정합니다. |
| `resize_to_fit` | `resize_to_fit: [100, 100]` | 지정된 크기 내에 이미지를 조정하면서 원래의 가로 세로 비율을 유지합니다. 이미지가 지정된 크기보다 큰 경우 이미지 크기를 줄이고 작은 경우 크기를 키웁니다. |
| `resize_to_fill` | `resize_to_fill: [100, 100]` | 지정된 크기에 이미지를 조정하면서 원래의 가로 세로 비율을 유지합니다. 필요한 경우 큰 차원에서 이미지를 자릅니다. |
| `resize_and_pad` | `resize_and_pad: [100, 100]` | 지정된 크기 내에 이미지를 조정하면서 원래의 가로 세로 비율을 유지합니다. 원본 이미지에 알파 채널이 있는 경우 투명한 색상으로 남은 영역을 채우고 그렇지 않은 경우 검은색으로 채웁니다. |
| `crop` | `crop: [20, 50, 300, 300]` | 이미지에서 영역을 추출합니다. 첫 두 인수는 추출할 영역의 왼쪽과 위쪽 가장자리이고, 마지막 두 인수는 추출할 영역의 너비와 높이입니다. |
| `rotate` | `rotate: 90` | 지정된 각도로 이미지를 회전합니다. |

[`image_processing`][]에는 [Vips](https://github.com/janko/image_processing/blob/master/doc/vips.md) 및 [MiniMagick](https://github.com/janko/image_processing/blob/master/doc/minimagick.md) 프로세서에 대한 자체 문서에서 더 많은 옵션이 있습니다.



### 파일 미리 보기

일부 비 이미지 파일은 미리 보기 할 수 있습니다. 예를 들어, 비디오 파일은 첫 번째 프레임을 추출하여 미리 보기로 표시할 수 있습니다.
Active Storage는 기본적으로 비디오 및 PDF 문서의 미리 보기를 지원합니다. 게으르게 생성된 미리 보기에 대한 링크를 만들려면 첨부 파일의 [`preview`][] 메서드를 사용하십시오:

```erb
<%= image_tag message.video.preview(resize_to_limit: [100, 100]) %>
```

다른 형식을 지원하려면 자체 미리 보기기를 추가하십시오. 자세한 내용은
[`ActiveStorage::Preview`][] 문서를 참조하십시오.


직접 업로드
--------------

Active Storage는 포함된 JavaScript 라이브러리를 사용하여 클라이언트에서 직접 클라우드로 업로드를 지원합니다.

### 사용법

1. 애플리케이션의 JavaScript 번들에 `activestorage.js`를 포함시킵니다.

    에셋 파이프라인을 사용하는 경우:

    ```js
    //= require activestorage
    ```

    npm 패키지를 사용하는 경우:

    ```js
    import * as ActiveStorage from "@rails/activestorage"
    ActiveStorage.start()
    ```

2. [파일 필드](form_helpers.html#uploading-files)에 `direct_upload: true`를 추가합니다:

    ```erb
    <%= form.file_field :attachments, multiple: true, direct_upload: true %>
    ```

    또는 `FormBuilder`를 사용하지 않는 경우 데이터 속성을 직접 추가하십시오:

    ```erb
    <input type="file" data-direct-upload-url="<%= rails_direct_uploads_url %>" />
    ```

3. 타사 저장소 서비스에서 직접 업로드 요청을 허용하도록 CORS를 구성합니다.

4. 그것으로 끝입니다! 업로드는 양식 제출 시 시작됩니다.

### Cross-Origin Resource Sharing (CORS) 구성

타사 서비스로의 직접 업로드를 작동하려면 서비스를 구성하여 앱에서의 교차 출처 요청을 허용해야 합니다. 서비스의 CORS 문서를 참조하십시오:

* [S3](https://docs.aws.amazon.com/AmazonS3/latest/dev/cors.html#how-do-i-enable-cors)
* [Google Cloud Storage](https://cloud.google.com/storage/docs/configuring-cors)
* [Azure Storage](https://docs.microsoft.com/en-us/rest/api/storageservices/cross-origin-resource-sharing--cors--support-for-the-azure-storage-services)

다음을 허용하도록 주의하십시오:

* 앱에 액세스하는 모든 출처
* `PUT` 요청 메서드
* 다음 헤더:
  * `Origin`
  * `Content-Type`
  * `Content-MD5`
  * `Content-Disposition` (Azure Storage 제외)
  * `x-ms-blob-content-disposition` (Azure Storage 전용)
  * `x-ms-blob-type` (Azure Storage 전용)
  * `Cache-Control` (GCS의 경우, `cache_control`이 설정된 경우에만)
디스크 서비스는 앱의 원본을 공유하기 때문에 CORS 구성이 필요하지 않습니다.

#### 예제: S3 CORS 구성

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

#### 예제: Google Cloud Storage CORS 구성

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

#### 예제: Azure Storage CORS 구성

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

### 직접 업로드 JavaScript 이벤트

| 이벤트 이름 | 이벤트 대상 | 이벤트 데이터 (`event.detail`) | 설명 |
| --- | --- | --- | --- |
| `direct-uploads:start` | `<form>` | 없음 | 직접 업로드 필드를 포함한 폼이 제출되었습니다. |
| `direct-upload:initialize` | `<input>` | `{id, file}` | 폼 제출 후 각 파일에 대해 발생합니다. |
| `direct-upload:start` | `<input>` | `{id, file}` | 직접 업로드가 시작됩니다. |
| `direct-upload:before-blob-request` | `<input>` | `{id, file, xhr}` | 직접 업로드 메타데이터를 요청하기 전에 애플리케이션에 대한 요청을 만들기 전입니다. |
| `direct-upload:before-storage-request` | `<input>` | `{id, file, xhr}` | 파일을 저장하기 위한 요청을 만들기 전입니다. |
| `direct-upload:progress` | `<input>` | `{id, file, progress}` | 파일 저장 요청의 진행 상황입니다. |
| `direct-upload:error` | `<input>` | `{id, file, error}` | 오류가 발생했습니다. 이벤트가 취소되지 않으면 `alert`가 표시됩니다. |
| `direct-upload:end` | `<input>` | `{id, file}` | 직접 업로드가 종료되었습니다. |
| `direct-uploads:end` | `<form>` | 없음 | 모든 직접 업로드가 종료되었습니다. |

### 예제

이러한 이벤트를 사용하여 업로드의 진행 상황을 표시할 수 있습니다.

![direct-uploads](https://user-images.githubusercontent.com/5355/28694528-16e69d0c-72f8-11e7-91a7-c0b8cfc90391.gif)

폼에 업로드된 파일을 표시하려면:

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

스타일 추가:

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

### 사용자 정의 드래그 앤 드롭 솔루션

이를 위해 `DirectUpload` 클래스를 사용할 수 있습니다. 선택한 라이브러리에서 파일을 받으면
`DirectUpload`을 인스턴스화하고 create 메서드를 호출합니다. create는
업로드가 완료될 때 호출할 콜백을 가져옵니다.

```js
import { DirectUpload } from "@rails/activestorage"

const input = document.querySelector('input[type=file]')

// 파일 드롭에 바인딩 - 부모 요소의 ondrop을 사용하거나
//  Dropzone과 같은 라이브러리를 사용합니다.
const onDrop = (event) => {
  event.preventDefault()
  const files = event.dataTransfer.files;
  Array.from(files).forEach(file => uploadFile(file))
}

// 일반 파일 선택에 바인딩
input.addEventListener('change', (event) => {
  Array.from(input.files).forEach(file => uploadFile(file))
  // 선택한 파일을 입력에서 지울 수 있습니다.
  input.value = null
})

const uploadFile = (file) => {
  // 폼에는 file_field direct_upload: true가 필요하며,
  //  data-direct-upload-url을 제공합니다.
  const url = input.dataset.directUploadUrl
  const upload = new DirectUpload(file, url)

  upload.create((error, blob) => {
    if (error) {
      // 오류 처리
    } else {
      // blob.signed_id 값을 가진 적절한 이름의 숨겨진 입력을 폼에 추가하여
      //  일반 업로드 플로우에서 blob ID가 전송되도록 합니다.
      const hiddenField = document.createElement('input')
      hiddenField.setAttribute("type", "hidden");
      hiddenField.setAttribute("value", blob.signed_id);
      hiddenField.name = input.name
      document.querySelector('form').appendChild(hiddenField)
    }
  })
}
```

### 파일 업로드의 진행 상황 추적

`DirectUpload` 생성자를 사용할 때 세 번째 매개변수를 포함할 수 있습니다.
이를 통해 `DirectUpload` 객체는 업로드 프로세스 중 `directUploadWillStoreFileWithXHR` 메서드를 호출할 수 있습니다.
그런 다음 XHR에 직접 진행 핸들러를 추가하여 필요에 맞게 사용할 수 있습니다.
```js
import { DirectUpload } from "@rails/activestorage"

class Uploader {
  constructor(file, url) {
    this.upload = new DirectUpload(this.file, this.url, this)
  }

  upload(file) {
    this.upload.create((error, blob) => {
      if (error) {
        // 에러 처리
      } else {
        // 적절한 이름의 숨겨진 입력을 폼에 추가하고 값으로 blob.signed_id를 설정합니다.
      }
    })
  }

  directUploadWillStoreFileWithXHR(request) {
    request.upload.addEventListener("progress",
      event => this.directUploadDidProgress(event))
  }

  directUploadDidProgress(event) {
    // event.loaded와 event.total을 사용하여 진행률 바를 업데이트합니다.
  }
}
```

### 라이브러리 또는 프레임워크와 통합하기

선택한 라이브러리로부터 파일을 받은 후, `DirectUpload` 인스턴스를 생성하고 "create" 메서드를 사용하여 업로드 프로세스를 시작해야 합니다. 필요한 추가 헤더가 있는 경우 해당 헤더를 추가해야 합니다. "create" 메서드는 업로드가 완료된 후 트리거되는 콜백 함수를 제공해야 합니다.

```js
import { DirectUpload } from "@rails/activestorage"

class Uploader {
  constructor(file, url, token) {
    const headers = { 'Authentication': `Bearer ${token}` }
    // INFO: 헤더를 보내는 것은 선택적 매개변수입니다. 헤더를 보내지 않으려면,
    //       인증은 쿠키나 세션 데이터를 사용하여 수행됩니다.
    this.upload = new DirectUpload(this.file, this.url, this, headers)
  }

  upload(file) {
    this.upload.create((error, blob) => {
      if (error) {
        // 에러 처리
      } else {
        // 다음 요청에서 blob.signed_id를 파일 참조로 사용합니다.
      }
    })
  }

  directUploadWillStoreFileWithXHR(request) {
    request.upload.addEventListener("progress",
      event => this.directUploadDidProgress(event))
  }

  directUploadDidProgress(event) {
    // event.loaded와 event.total을 사용하여 진행률 바를 업데이트합니다.
  }
}
```

사용자 정의 인증을 구현하려면, 다음과 같이 Rails 애플리케이션에 새로운 컨트롤러를 생성해야 합니다.

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

참고: [직접 업로드](#direct-uploads)를 사용하면 파일이 업로드되지만 레코드에 첨부되지 않을 수 있습니다. [첨부되지 않은 업로드 삭제](#purging-unattached-uploads)를 고려해야 합니다.

테스트
-------------------------------------------

통합 또는 컨트롤러 테스트에서 파일을 업로드하는 경우 [`fixture_file_upload`][]를 사용합니다. Rails는 파일을 다른 매개변수와 마찬가지로 처리합니다.

```ruby
class SignupController < ActionDispatch::IntegrationTest
  test "회원 가입 가능" do
    post signup_path, params: {
      name: "David",
      avatar: fixture_file_upload("david.png", "image/png")
    }

    user = User.order(:created_at).last
    assert user.avatar.attached?
  end
end
```


### 테스트 중 생성된 파일 삭제

#### 시스템 테스트

시스템 테스트는 트랜잭션을 롤백하여 테스트 데이터를 정리합니다. `destroy`가 객체에서 호출되지 않기 때문에 첨부된 파일은 자동으로 정리되지 않습니다. 파일을 지우려면 `after_teardown` 콜백에서 수행할 수 있습니다. 여기서 수행하면 테스트 중에 생성된 모든 연결이 완료되고 Active Storage에서 파일을 찾을 수 없다는 오류가 발생하지 않습니다.

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

[병렬 테스트][]와 `DiskService`를 사용하는 경우, 각 프로세스를 Active Storage에 대한 고유한 폴더를 사용하도록 설정해야 합니다. 이렇게 하면 `teardown` 콜백은 해당 프로세스의 테스트에서만 파일을 삭제합니다.

```ruby
class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  # ...
  parallelize_setup do |i|
    ActiveStorage::Blob.service.root = "#{ActiveStorage::Blob.service.root}-#{i}"
  end
  # ...
end
```

모델에 첨부 파일이 있는 모델 삭제를 확인하는 시스템 테스트를 사용하고 Active Job을 사용하는 경우, 테스트 환경을 인라인 큐 어댑터를 사용하도록 설정하여 삭제 작업이 즉시 실행되도록 설정합니다.

```ruby
# 즉시 작업이 실행되도록 인라인 작업 처리를 사용합니다.
config.active_job.queue_adapter = :inline
```

[병렬 테스트]: testing.html#parallel-testing

#### 통합 테스트

시스템 테스트와 마찬가지로, 통합 테스트 중에 업로드된 파일은 자동으로 정리되지 않습니다. 파일을 지우려면 `teardown` 콜백에서 수행할 수 있습니다.

```ruby
class ActionDispatch::IntegrationTest
  def after_teardown
    super
    FileUtils.rm_rf(ActiveStorage::Blob.service.root)
  end
end
```

[병렬 테스트][]와 Disk 서비스를 사용하는 경우, 각 프로세스를 Active Storage에 대한 고유한 폴더를 사용하도록 설정해야 합니다. 이렇게 하면 `teardown` 콜백은 해당 프로세스의 테스트에서만 파일을 삭제합니다.

```ruby
class ActionDispatch::IntegrationTest
  parallelize_setup do |i|
    ActiveStorage::Blob.service.root = "#{ActiveStorage::Blob.service.root}-#{i}"
  end
end
```

[병렬 테스트]: testing.html#parallel-testing

### 픽스처에 첨부 파일 추가하기

기존 [픽스처][fixtures]에 첨부 파일을 추가할 수 있습니다. 먼저, 별도의 스토리지 서비스를 생성해야 합니다.

```yml
# config/storage.yml

test_fixtures:
  service: Disk
  root: <%= Rails.root.join("tmp/storage_fixtures") %>
```

이렇게 하면 Active Storage가 픽스처 파일을 "업로드"할 위치를 알 수 있으므로 임시 디렉토리여야 합니다. 일반적인 `test` 서비스와 다른 디렉토리로 만들어 픽스처 파일을 테스트 중에 업로드된 파일과 분리할 수 있습니다.
다음으로, Active Storage 클래스에 대한 픽스처 파일을 생성하세요:

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

그런 다음 해당 파일과 동일한 파일 이름으로 픽스처 디렉토리에 파일을 넣으세요 (기본 경로는 `test/fixtures/files`입니다).
자세한 내용은 [`ActiveStorage::FixtureSet`][] 문서를 참조하세요.

설정이 완료되면 테스트에서 첨부 파일에 액세스할 수 있습니다:

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

#### 픽스처 정리

테스트에서 업로드된 파일은 [각 테스트가 끝날 때](#테스트-중-생성된-파일-삭제하기) 정리됩니다.
픽스처 파일은 모든 테스트가 완료된 후에 한 번만 정리해야 합니다.

병렬 테스트를 사용하는 경우 `parallelize_teardown`을 호출하세요:

```ruby
class ActiveSupport::TestCase
  # ...
  parallelize_teardown do |i|
    FileUtils.rm_rf(ActiveStorage::Blob.services.fetch(:test_fixtures).root)
  end
  # ...
end
```

병렬 테스트를 사용하지 않는 경우 `Minitest.after_run` 또는 테스트 프레임워크에 해당하는 동등한 메서드를 사용하세요 (예: RSpec의 `after(:suite)`):

```ruby
# test_helper.rb

Minitest.after_run do
  FileUtils.rm_rf(ActiveStorage::Blob.services.fetch(:test_fixtures).root)
end
```


### 서비스 구성

`config/storage/test.yml`을 추가하여 테스트 환경에서 사용할 서비스를 구성할 수 있습니다.
이는 `service` 옵션을 사용할 때 유용합니다.

```ruby
class User < ApplicationRecord
  has_one_attached :avatar, service: :s3
end
```

`config/storage/test.yml`이 없으면 `config/storage.yml`에서 구성된 `s3` 서비스가 사용됩니다. 테스트를 실행할 때에도 마찬가지입니다.

기본 구성이 사용되며 파일은 `config/storage.yml`에서 구성된 서비스 제공자로 업로드됩니다.

이 경우 `config/storage/test.yml`을 추가하고 `s3` 서비스에 대해 Disk 서비스를 사용하여 요청을 보내지 않도록 할 수 있습니다.

```yaml
test:
  service: Disk
  root: <%= Rails.root.join("tmp/storage") %>

s3:
  service: Disk
  root: <%= Rails.root.join("tmp/storage") %>
```

다른 클라우드 서비스를 지원하려면 Service를 구현해야 합니다.
각 서비스는
[`ActiveStorage::Service`](https://api.rubyonrails.org/classes/ActiveStorage/Service.html)를 확장하여
파일을 클라우드에 업로드하고 다운로드하는 데 필요한 메서드를 구현합니다.

연결되지 않은 업로드 정리
--------------------------

[직접 업로드](#직접-업로드)를 사용할 때 파일이 업로드되지만 레코드에 첨부되지 않을 수 있습니다. [unattached scope](https://github.com/rails/rails/blob/8ef5bd9ced351162b673904a0b77c7034ca2bc20/activestorage/app/models/active_storage/blob.rb#L49)를 사용하여 연결되지 않은 레코드를 쿼리할 수 있습니다. 아래는 [사용자 정의 rake 작업](command_line.html#사용자-정의-rake-작업)을 사용한 예입니다.

```ruby
namespace :active_storage do
  desc "연결되지 않은 Active Storage 블롭을 삭제합니다. 정기적으로 실행하세요."
  task purge_unattached: :environment do
    ActiveStorage::Blob.unattached.where(created_at: ..2.days.ago).find_each(&:purge_later)
  end
end
```

경고: `ActiveStorage::Blob.unattached`로 생성된 쿼리는 큰 데이터베이스를 가진 애플리케이션에서 느릴 수 있으며 잠재적으로 문제를 일으킬 수 있습니다.
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
