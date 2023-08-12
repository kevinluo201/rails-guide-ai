**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: b8e9de3d2aa934a8a6fc3e1dccb4824c
Active Storageの概要
=======================

このガイドでは、Active Recordモデルにファイルを添付する方法について説明します。

このガイドを読み終えると、以下のことがわかるようになります：

* レコードに1つまたは複数のファイルを添付する方法。
* 添付されたファイルを削除する方法。
* 添付されたファイルへのリンク方法。
* 画像を変換するためのバリアントの使用方法。
* PDFやビデオなどの非画像ファイルの画像表現を生成する方法。
* ブラウザからストレージサービスに直接ファイルをアップロードする方法（アプリケーションサーバーをバイパス）。
* テスト中に保存されたファイルをクリーンアップする方法。
* 追加のストレージサービスのサポートを実装する方法。

--------------------------------------------------------------------------------

Active Storageとは何ですか？
-----------------------

Active Storageは、Amazon S3、Google Cloud Storage、またはMicrosoft Azure Storageなどのクラウドストレージサービスにファイルをアップロードし、それらのファイルをActive Recordオブジェクトに添付することを容易にします。開発およびテスト用のローカルディスクベースのサービスを提供し、バックアップやマイグレーションのためにファイルを従属サービスにミラーリングすることもサポートしています。

Active Storageを使用すると、アプリケーションは画像のアップロードを変換したり、PDFやビデオなどの非画像のアップロードの画像表現を生成したり、任意のファイルからメタデータを抽出したりすることができます。

### 必要条件

Active Storageのさまざまな機能には、Railsがインストールしないサードパーティのソフトウェアが必要であり、別途インストールする必要があります：

* 画像の解析と変換には、[libvips](https://github.com/libvips/libvips) v8.6+または[ImageMagick](https://imagemagick.org/index.php)が必要です。
* ビデオのプレビューには、[ffmpeg](http://ffmpeg.org/) v3.4+が必要であり、ビデオ/オーディオの解析にはffprobeが必要です。
* PDFのプレビューには、[poppler](https://poppler.freedesktop.org/)または[muPDF](https://mupdf.com/)が必要です。

画像の解析と変換には、`image_processing`ジェムも必要です。`Gemfile`でコメントを解除するか、必要に応じて追加してください：

```ruby
gem "image_processing", ">= 1.2"
```

TIP: libvipsはImageMagickよりもよく知られており、より広く利用できます。ただし、libvipsは[最大10倍高速で、1/10のメモリを消費](https://github.com/libvips/libvips/wiki/Speed-and-memory-use)することができます。JPEGファイルの場合、これは`libjpeg-dev`を`libjpeg-turbo-dev`で置き換えることでさらに改善できます。`libjpeg-turbo-dev`は[2-7倍高速](https://libjpeg-turbo.org/About/Performance)です。

WARNING: サードパーティのソフトウェアをインストールして使用する前に、そのライセンスの影響を理解してください。特に、MuPDFはAGPLの下でライセンスされており、一部の使用には商用ライセンスが必要です。

## セットアップ

```bash
$ bin/rails active_storage:install
$ bin/rails db:migrate
```

これにより、設定がセットアップされ、Active Storageが使用する3つのテーブル、`active_storage_blobs`、`active_storage_attachments`、および`active_storage_variant_records`が作成されます。

| テーブル      | 目的 |
| ------------------- | ----- |
| `active_storage_blobs` | ファイルのアップロードに関するデータ（ファイル名やコンテンツタイプなど）を格納します。 |
| `active_storage_attachments` | [モデルとブロブを接続する](#attaching-files-to-records)ポリモーフィックな結合テーブルです。モデルのクラス名が変更された場合、このテーブルの下にある`record_type`をモデルの新しいクラス名に更新するためにマイグレーションを実行する必要があります。 |
| `active_storage_variant_records` | [バリアントのトラッキング](#attaching-files-to-records)が有効になっている場合、生成された各バリアントのレコードを格納します。 |

WARNING: モデルのプライマリキーとして整数ではなくUUIDを使用している場合は、`Rails.application.config.generators { |g| g.orm :active_record, primary_key_type: :uuid }`を設定する必要があります。

`config/storage.yml`でActive Storageサービスを宣言します。アプリケーションが使用する各サービスに名前と必要な設定を提供します。以下の例では、`local`、`test`、および`amazon`という3つのサービスが宣言されています：

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
  region: "" # 例：'us-east-1'
```

Active Storageが使用するサービスを設定するには、`Rails.application.config.active_storage.service`を設定します。各環境で異なるサービスを使用する可能性があるため、環境ごとに設定することをおすすめします。前の例のディスクサービスを開発環境で使用するには、`config/environments/development.rb`に次の設定を追加します：

```ruby
# ファイルをローカルに保存します。
config.active_storage.service = :local
```

本番環境でS3サービスを使用するには、`config/environments/production.rb`に次の設定を追加します：

```ruby
# ファイルをAmazon S3に保存します。
config.active_storage.service = :amazon
```

テスト時にテストサービスを使用するには、`config/environments/test.rb`に次の設定を追加します：

```ruby
# アップロードされたファイルを一時ディレクトリに保存します。
config.active_storage.service = :test
```

NOTE: 環境ごとに異なる設定ファイルが優先されます。たとえば、本番環境では、`config/storage/production.yml`ファイル（存在する場合）が`config/storage.yml`ファイルより優先されます。

誤って本番データを破壊するリスクをさらに減らすために、バケット名に`Rails.env`を使用することをおすすめします。

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

組み込みのサービスアダプタ（例：`Disk`および`S3`）とそれらが必要とする設定についての詳細情報については、以下をお読みください。

### ディスクサービス

`config/storage.yml`でディスクサービスを宣言します：

```yaml
local:
  service: Disk
  root: <%= Rails.root.join("storage") %>
```

### S3サービス（Amazon S3およびS3互換API）

Amazon S3に接続するためには、`config/storage.yml`でS3サービスを宣言します：

```yaml
amazon:
  service: S3
  access_key_id: ""
  secret_access_key: ""
  region: ""
  bucket: ""
```

オプションでクライアントとアップロードのオプションを指定できます：

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
    server_side_encryption: "" # 'aws:kms'または'AES256'
    cache_control: "private, max-age=<%= 1.day.to_i %>"
```

TIP: アプリケーションに適切なクライアントHTTPタイムアウトとリトライ制限を設定してください。特定の障害シナリオでは、デフォルトのAWSクライアント設定により、接続が数分間保持され、リクエストがキューに入る可能性があります。

[`aws-sdk-s3`](https://github.com/aws/aws-sdk-ruby) gemを`Gemfile`に追加してください：

```ruby
gem "aws-sdk-s3", require: false
```

注意：Active Storageのコア機能には、次のアクセス許可が必要です：`s3:ListBucket`、`s3:PutObject`、`s3:GetObject`、および`s3:DeleteObject`。[公開アクセス](#public-access)では、さらに`s3:PutObjectAcl`が必要です。ACLの設定などの追加のアップロードオプションが構成されている場合、追加のアクセス許可が必要になる場合があります。

注意：環境変数、標準のSDK設定ファイル、プロファイル、IAMインスタンスプロファイル、またはタスクロールを使用する場合は、上記の例で`access_key_id`、`secret_access_key`、および`region`キーを省略できます。S3サービスは、[AWS SDKドキュメント](https://docs.aws.amazon.com/sdk-for-ruby/v3/developer-guide/setup-config.html)で説明されているすべての認証オプションをサポートしています。

DigitalOcean SpacesなどのS3互換オブジェクトストレージAPIに接続するには、`endpoint`を指定します：

```yaml
digitalocean:
  service: S3
  endpoint: https://nyc3.digitaloceanspaces.com
  access_key_id: ...
  secret_access_key: ...
  # ...およびその他のオプション
```

他にも多くのオプションがあります。[AWS S3 Client](https://docs.aws.amazon.com/sdk-for-ruby/v3/api/Aws/S3/Client.html#initialize-instance_method)のドキュメントで確認できます。

### Microsoft Azure Storage Service

`config/storage.yml`でAzure Storageサービスを宣言します：

```yaml
azure:
  service: AzureStorage
  storage_account_name: ""
  storage_access_key: ""
  container: ""
```

[`azure-storage-blob`](https://github.com/Azure/azure-storage-ruby) gemを`Gemfile`に追加してください：

```ruby
gem "azure-storage-blob", "~> 2.0", require: false
```

### Google Cloud Storage Service

`config/storage.yml`でGoogle Cloud Storageサービスを宣言します：

```yaml
google:
  service: GCS
  credentials: <%= Rails.root.join("path/to/keyfile.json") %>
  project: ""
  bucket: ""
```

キーファイルのパスの代わりに、クレデンシャルのハッシュを指定することもできます：

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

アップロードされたアセットに設定するためのCache-Controlメタデータをオプションで指定できます：

```yaml
google:
  service: GCS
  ...
  cache_control: "public, max-age=3600"
```

URLに署名する際に`credentials`の代わりに[IAM](https://cloud.google.com/storage/docs/access-control/signed-urls#signing-iam)を使用することもできます。これは、GKEアプリケーションをワークロードアイデンティティで認証している場合に便利です。詳細については、[このGoogle Cloudブログ記事](https://cloud.google.com/blog/products/containers-kubernetes/introducing-workload-identity-better-authentication-for-your-gke-applications)を参照してください。

```yaml
google:
  service: GCS
  ...
  iam: true
```

URLに署名する際に特定のGSAを使用することもできます。IAMを使用する場合、[メタデータサーバ](https://cloud.google.com/compute/docs/storing-retrieving-metadata)はGSAのメールアドレスを取得するために連絡されますが、このメタデータサーバは常に存在しない（ローカルテストなど）ため、デフォルト以外のGSAを使用する場合があります。

```yaml
google:
  service: GCS
  ...
  iam: true
  gsa_email: "foobar@baz.iam.gserviceaccount.com"
```

[`google-cloud-storage`](https://github.com/GoogleCloudPlatform/google-cloud-ruby/tree/master/google-cloud-storage) gemを`Gemfile`に追加してください：

```ruby
gem "google-cloud-storage", "~> 1.11", require: false
```

### ミラーサービス

ミラーサービスを定義することで、複数のサービスを同期させることができます。ミラーサービスは、アップロードと削除を2つ以上の下位サービスに複製します。

ミラーサービスは、本番環境でのサービス間の移行中に一時的に使用することを想定しています。新しいサービスにミラーリングを開始し、古いサービスから事前に存在するファイルを新しいサービスにコピーし、その後新しいサービスに完全に移行します。

注意：ミラーリングはアトミックではありません。アップロードがプライマリサービスで成功し、下位サービスのいずれかで失敗する可能性があります。新しいサービスに完全に移行する前に、すべてのファイルがコピーされていることを確認してください。

上記で説明したように、ミラーリングしたい各サービスを定義してください。ミラーサービスを定義する際に、名前で参照してください：

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

すべてのセカンダリサービスはアップロードを受け取りますが、ダウンロードは常にプライマリサービスで処理されます。

ミラーサービスは直接アップロードと互換性があります。新しいファイルは直接プライマリサービスにアップロードされます。直接アップロードされたファイルがレコードに添付されると、バックグラウンドジョブがエンキューされ、セカンダリサービスにコピーされます。
### パブリックアクセス

デフォルトでは、Active Storageはサービスへのプライベートアクセスを前提としています。これは、ブロブに対して署名付きの一度限りのURLを生成することを意味します。ブロブをパブリックにアクセス可能にする場合は、アプリの`config/storage.yml`で`public: true`を指定します。

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

バケットがパブリックアクセスに適切に設定されていることを確認してください。[Amazon S3](https://docs.aws.amazon.com/AmazonS3/latest/user-guide/block-public-access-bucket.html)、[Google Cloud Storage](https://cloud.google.com/storage/docs/access-control/making-data-public#buckets)、および[Microsoft Azure](https://docs.microsoft.com/en-us/azure/storage/blobs/storage-manage-access-to-resources#set-container-public-access-level-in-the-azure-portal)のストレージサービスに対してパブリックリード権限を有効にする方法についてのドキュメントを参照してください。Amazon S3では、`s3:PutObjectAcl`の権限が必要です。

`public: true`を使用するように既存のアプリケーションを変換する場合は、切り替える前にバケット内のすべての個々のファイルをパブリックリーダブルに更新する必要があります。

レコードにファイルを添付する
--------------------------

### `has_one_attached`

[`has_one_attached`][]マクロは、レコードとファイルの1対1のマッピングを設定します。各レコードには1つのファイルが添付されることができます。

たとえば、アプリケーションに`User`モデルがあるとします。各ユーザーにアバターを持たせたい場合は、次のように`User`モデルを定義します。

```ruby
class User < ApplicationRecord
  has_one_attached :avatar
end
```

または、Rails 6.0+を使用している場合は、次のようにモデルジェネレータコマンドを実行できます。

```ruby
bin/rails generate model User avatar:attachment
```

アバターを持つユーザーを作成できます。

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

既存のユーザーにアバターを添付するには、[`avatar.attach`][Attached::One#attach]を呼び出します。

```ruby
user.avatar.attach(params[:avatar])
```

特定のユーザーがアバターを持っているかどうかを判断するには、[`avatar.attached?`][Attached::One#attached?]を呼び出します。

```ruby
user.avatar.attached?
```

一部の場合では、特定の添付ファイルに対してデフォルトのサービスをオーバーライドしたい場合があります。`service`オプションを使用して、添付ごとに特定のサービスを設定できます。

```ruby
class User < ApplicationRecord
  has_one_attached :avatar, service: :s3
end
```

`variant`メソッドを使用して、特定の添付ファイルごとに特定のバリアントを設定できます。

```ruby
class User < ApplicationRecord
  has_one_attached :avatar do |attachable|
    attachable.variant :thumb, resize_to_limit: [100, 100]
  end
end
```

アバターのサムネイルバリアントを取得するには、`avatar.variant(:thumb)`を呼び出します。

```erb
<%= image_tag user.avatar.variant(:thumb) %>
```

プレビューに特定のバリアントを使用することもできます。

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

[`has_many_attached`][]マクロは、レコードとファイルの1対多の関係を設定します。各レコードには複数のファイルが添付されることができます。

たとえば、アプリケーションに`Message`モデルがあるとします。各メッセージに複数の画像を持たせたい場合は、次のように`Message`モデルを定義します。

```ruby
class Message < ApplicationRecord
  has_many_attached :images
end
```

または、Rails 6.0+を使用している場合は、次のようにモデルジェネレータコマンドを実行できます。

```ruby
bin/rails generate model Message images:attachments
```

画像を持つメッセージを作成できます。

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

既存のメッセージに新しい画像を追加するには、[`images.attach`][Attached::Many#attach]を呼び出します。

```ruby
@message.images.attach(params[:images])
```

特定のメッセージに画像があるかどうかを判断するには、[`images.attached?`][Attached::Many#attached?]を呼び出します。

```ruby
@message.images.attached?
```

デフォルトのサービスをオーバーライドするには、`has_one_attached`と同じ方法で`service`オプションを使用します。

```ruby
class Message < ApplicationRecord
  has_many_attached :images, service: :s3
end
```

特定のバリアントを設定するには、`has_one_attached`と同じ方法で、yieldされたattachableオブジェクトに`variant`メソッドを呼び出します。

```ruby
class Message < ApplicationRecord
  has_many_attached :images do |attachable|
    attachable.variant :thumb, resize_to_limit: [100, 100]
  end
end
```



### ファイル/IOオブジェクトの添付

HTTPリクエスト経由で到着しないファイルを添付する必要がある場合があります。たとえば、ディスク上で生成したファイルや、ユーザーが提出したURLからダウンロードしたファイルを添付する場合があります。また、モデルテストでフィクスチャファイルを添付する場合もあります。その場合は、少なくともオープンなIOオブジェクトとファイル名を含むハッシュを提供します。

```ruby
@message.images.attach(io: File.open('/path/to/file'), filename: 'file.pdf')
```

可能な場合は、コンテンツタイプも指定してください。Active Storageはファイルのデータからコンテンツタイプを判断しようとします。それができない場合は、提供されたコンテンツタイプを使用します。
```ruby
@message.images.attach(io: File.open('/path/to/file'), filename: 'file.pdf', content_type: 'application/pdf')
```

`content_type`と一緒に`identify: false`を渡すことで、データからのコンテンツタイプの推論をバイパスすることができます。

```ruby
@message.images.attach(
  io: File.open('/path/to/file'),
  filename: 'file.pdf',
  content_type: 'application/pdf',
  identify: false
)
```

コンテンツタイプを提供せず、Active Storageがファイルのコンテンツタイプを自動的に判断できない場合、デフォルトで`application/octet-stream`になります。

ファイルの削除
--------------

モデルから添付ファイルを削除するには、添付ファイルに対して[`purge`][Attached::One#purge]を呼び出します。アプリケーションがActive Jobを使用するように設定されている場合、削除は[`purge_later`][Attached::One#purge_later]を呼び出すことでバックグラウンドで行うこともできます。`purge`はブロブとストレージサービスからファイルを削除します。

```ruby
# アバターと実際のリソースファイルを同期的に破棄します。
user.avatar.purge

# 関連するモデルと実際のリソースファイルを非同期に破棄します（Active Jobを使用）。
user.avatar.purge_later
```


ファイルの提供
-------------

Active Storageは2つの方法でファイルを提供することができます：リダイレクトとプロキシ。

警告：すべてのActive Storageコントローラはデフォルトで公開されています。生成されたURLは推測が難しく、意図的に永続的です。ファイルがより高いレベルの保護を必要とする場合は、[認証済みコントローラ](#authenticated-controllers)を実装することを検討してください。

### リダイレクトモード

ブロブに対して永続的なURLを生成するには、[`url_for`][ActionView::RoutingUrlFor#url_for]ビューヘルパーにブロブを渡します。これにより、ブロブの[`signed_id`][ActiveStorage::Blob#signed_id]を使用したURLが生成され、ブロブの[`RedirectController`][`ActiveStorage::Blobs::RedirectController`]にルーティングされます。

```ruby
url_for(user.avatar)
# => /rails/active_storage/blobs/:signed_id/my-avatar.png
```

`RedirectController`は実際のサービスエンドポイントにリダイレクトします。この間接的な方法により、サービスURLと実際のURLが切り離され、例えば高可用性のために異なるサービスで添付ファイルをミラーリングすることができます。リダイレクトはHTTPの有効期限が5分です。

ダウンロードリンクを作成するには、`rails_blob_{path|url}`ヘルパーを使用します。このヘルパーを使用すると、dispositionを設定することができます。

```ruby
rails_blob_path(user.avatar, disposition: "attachment")
```

警告：XSS攻撃を防ぐため、Active Storageは一部の種類のファイルに対してContent-Dispositionヘッダを"attachment"に強制します。この動作を変更するには、[Configuring Rails Applications](configuring.html#configuring-active-storage)の利用可能な設定オプションを参照してください。

コントローラ/ビューコンテキストの外部からリンクを作成する必要がある場合（バックグラウンドジョブ、Cronジョブなど）、次のように`rails_blob_path`にアクセスできます。

```ruby
Rails.application.routes.url_helpers.rails_blob_path(user.avatar, only_path: true)
```


### プロキシモード

オプションで、ファイルをプロキシすることもできます。これは、リクエストに応じてアプリケーションサーバーがストレージサービスからファイルデータをダウンロードすることを意味します。これはCDNからファイルを提供するために便利です。

Active Storageをデフォルトでプロキシモードを使用するように設定することができます。

```ruby
# config/initializers/active_storage.rb
Rails.application.config.active_storage.resolve_model_to_route = :rails_storage_proxy
```

または、特定の添付ファイルを明示的にプロキシする場合は、`rails_storage_proxy_path`および`rails_storage_proxy_url`という形式のURLヘルパーを使用できます。

```erb
<%= image_tag rails_storage_proxy_path(@user.avatar) %>
```

#### Active Storageの前にCDNを配置する

さらに、Active Storageの添付ファイルにCDNを使用するには、プロキシモードでURLを生成する必要があります。これにより、CDNが追加の設定なしで添付ファイルをキャッシュできるようになります。これはデフォルトで動作するため、Active StorageのプロキシコントローラーがレスポンスをキャッシュするようにCDNにHTTPヘッダを設定します。

また、生成されたURLがアプリのホストではなくCDNホストを使用するようにする必要もあります。これを実現するための複数の方法がありますが、一般的には`config/routes.rb`ファイルを調整して、添付ファイルとそのバリエーションの正しいURLを生成できるようにします。例えば、次のように追加できます。

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

そして、次のようにルートを生成します。

```erb
<%= cdn_image_url(user.avatar.variant(resize_to_limit: [128, 128])) %>
```

### 認証済みコントローラ

すべてのActive Storageコントローラはデフォルトで公開されています。生成されたURLは単純な[`signed_id`][ActiveStorage::Blob#signed_id]を使用しており、推測が難しくなっていますが、永続的です。ログインが必要な場合でも、`ApplicationController`の`before_action`で要求される場合でも、ブロブのURLを知っている人はアクセスできます。ファイルがより高いレベルの保護を必要とする場合は、[`ActiveStorage::Blobs::RedirectController`][], [`ActiveStorage::Blobs::ProxyController`][], [`ActiveStorage::Representations::RedirectController`][]、および[`ActiveStorage::Representations::ProxyController`][]に基づいて独自の認証済みコントローラを実装することができます。

アカウントが自分のロゴにアクセスできるようにするには、次のようにします：
```ruby
# config/routes.rb
resource :account do
  resource :logo
end
```

```ruby
# app/controllers/logos_controller.rb
class LogosController < ApplicationController
  # ApplicationControllerを介して:
  # include Authenticate, SetCurrentAccount

  def show
    redirect_to Current.account.logo.url
  end
end
```

```erb
<%= image_tag account_logo_path %>
```

そして、Active Storageのデフォルトのルートを無効にするために、次の設定を行ってください。

```ruby
config.active_storage.draw_routes = false
```

これにより、ファイルが公開可能なURLでアクセスされるのを防ぐことができます。


ファイルのダウンロード
-----------------

アップロードされたblobを処理する必要がある場合があります。たとえば、別の形式に変換するためです。blobのバイナリデータをメモリに読み込むために、添付ファイルの[`download`][Blob#download]メソッドを使用します。

```ruby
binary = user.avatar.download
```

外部プログラム（ウイルススキャナーやメディアトランスコーダなど）がそれに操作を行うために、blobをディスク上のファイルにダウンロードする場合は、添付ファイルの[`open`][Blob#open]メソッドを使用して、blobをディスク上の一時ファイルにダウンロードします。

```ruby
message.video.open do |file|
  system '/path/to/virus/scanner', file.path
  # ...
end
```

`after_create`コールバックではファイルはまだ利用できないことに注意してください。`after_create_commit`のみで利用できます。


ファイルの解析
---------------

Active Storageは、ファイルがアップロードされた後にジョブをActive Jobでキューに入れることで、ファイルを解析します。解析されたファイルは、メタデータハッシュに追加の情報（`analyzed: true`など）を保存します。[`analyzed?`][]を呼び出すことで、blobが解析されたかどうかを確認できます。

画像解析では、`width`と`height`属性が提供されます。ビデオ解析では、これらに加えて、`duration`、`angle`、`display_aspect_ratio`、`video`および`audio`のブール値が提供され、これらのチャンネルの存在を示します。オーディオ解析では、`duration`と`bit_rate`属性が提供されます。


画像、ビデオ、およびPDFの表示
---------------

Active Storageはさまざまなファイルの表示をサポートしています。添付ファイルに対して[`representation`][]を呼び出すことで、画像のバリアントやビデオやPDFのプレビューを表示することができます。`representation`を呼び出す前に、[`representable?`]を呼び出して、添付ファイルが表現可能かどうかを確認します。Active Storageでは、デフォルトでプレビューできないファイル形式（例：Wordドキュメントなど）もあります。`representable?`がfalseを返す場合は、[ファイルへのリンク](#serving-files)を作成することもできます。

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

内部的には、`representation`は画像に対して`variant`を呼び出し、プレビュー可能なファイルに対して`preview`を呼び出します。これらのメソッドを直接呼び出すこともできます。


### 遅延ロードと即時ロード

デフォルトでは、Active Storageは表現を遅延的に処理します。次のコード:

```ruby
image_tag file.representation(resize_to_limit: [100, 100])
```

は、`src`が[`ActiveStorage::Representations::RedirectController`][]を指す`<img>`タグを生成します。ブラウザはそのコントローラにリクエストを送信し、次の処理を行います。

1. ファイルを処理し、必要に応じて処理済みのファイルをアップロードします。
2. ファイルへの`302`リダイレクトを返します。リダイレクト先は、
  * リモートサービス（例：S3）。
  * または[プロキシモード](#proxy-mode)が有効な場合は`ActiveStorage::Blobs::ProxyController`がファイルの内容を返します。

ファイルを遅延的にロードすることで、[単一使用URL](#public-access)などの機能を使用して、初期ページの読み込みを遅くすることなく動作させることができます。

これはほとんどの場合で問題ありません。

画像のURLを即座に生成したい場合は、`.processed.url`を呼び出すことができます。

```ruby
image_tag file.representation(resize_to_limit: [100, 100]).processed.url
```

Active Storageのバリアントトラッカーは、要求された表現が以前に処理されたかどうかをデータベースに記録することで、このパフォーマンスを向上させます。したがって、上記のコードはリモートサービス（例：S3）へのAPI呼び出しを1回しか行わず、バリアントが保存されるとそれを使用します。バリアントトラッカーは自動的に実行されますが、[`config.active_storage.track_variants`][]を介して無効にすることもできます。

ページ上に多くの画像をレンダリングする場合、上記の例ではN+1クエリがすべてのバリアントレコードをロードする可能性があります。これらのN+1クエリを回避するには、[`ActiveStorage::Attachment`][]の名前付きスコープを使用します。

```ruby
message.images.with_all_variant_records.each do |file|
  image_tag file.representation(resize_to_limit: [100, 100]).processed.url
end
```


### 画像の変換

画像の変換を使用すると、画像を任意のサイズで表示することができます。添付ファイルに対して[`variant`][]を呼び出すことで、画像プロセッサがサポートする任意の変換をメソッドに渡すことができます。ブラウザがバリアントURLにアクセスすると、Active Storageは元のblobを指定された形式に遅延的に変換し、新しいサービスの場所にリダイレクトします。

```erb
<%= image_tag user.avatar.variant(resize_to_limit: [100, 100]) %>
```
バリアントがリクエストされた場合、Active Storageは画像の形式に応じて自動的に変換を適用します。

1. [`config.active_storage.variable_content_types`][]で指定された可変のコンテンツタイプ（[`config.active_storage.web_image_content_types`][]で指定されたウェブ画像とは異なる）は、PNGに変換されます。

2. `quality`が指定されていない場合、バリアントプロセッサのデフォルトの品質が使用されます。

Active Storageは、[Vips][]またはMiniMagickのいずれかをバリアントプロセッサとして使用できます。
デフォルトは`config.load_defaults`のターゲットバージョンに依存し、
[`config.active_storage.variant_processor`][]を設定することでプロセッサを変更できます。

2つのプロセッサは完全に互換性がないため、既存のアプリケーションをMiniMagickからVipsに移行する場合、
形式固有のオプションを使用している場合はいくつかの変更が必要です。

```rhtml
<!-- MiniMagick -->
<%= image_tag user.avatar.variant(resize_to_limit: [100, 100], format: :jpeg, sampling_factor: "4:2:0", strip: true, interlace: "JPEG", colorspace: "sRGB", quality: 80) %>

<!-- Vips -->
<%= image_tag user.avatar.variant(resize_to_limit: [100, 100], format: :jpeg, saver: { subsample_mode: "on", strip: true, interlace: true, quality: 80 }) %>
```

利用可能なパラメータは[`image_processing`][] gemによって定義され、使用しているバリアントプロセッサに依存しますが、次のパラメータを両方のプロセッサがサポートしています。

| パラメータ      | 例 | 説明 |
| ------------------- | ---------------- | ----- |
| `resize_to_limit` | `resize_to_limit: [100, 100]` | 指定した寸法に収まるように画像のサイズを縮小します。元のアスペクト比を保持します。指定した寸法よりも画像が大きい場合にのみリサイズされます。 |
| `resize_to_fit` | `resize_to_fit: [100, 100]` | 指定した寸法に収まるように画像のサイズを変更します。元のアスペクト比を保持します。指定した寸法よりも画像が大きい場合は縮小し、小さい場合は拡大します。 |
| `resize_to_fill` | `resize_to_fill: [100, 100]` | 指定した寸法に画像のサイズを変更します。元のアスペクト比を保持します。必要な場合、大きい寸法で画像を切り取ります。 |
| `resize_and_pad` | `resize_and_pad: [100, 100]` | 指定した寸法に収まるように画像のサイズを変更します。元のアスペクト比を保持します。ソース画像にアルファチャネルがある場合は、残りの領域を透明な色でパッドします。ない場合は黒でパッドします。 |
| `crop` | `crop: [20, 50, 300, 300]` | 画像から領域を切り出します。最初の2つの引数は切り出す領域の左端と上端で、最後の2つの引数は切り出す領域の幅と高さです。 |
| `rotate` | `rotate: 90` | 指定した角度で画像を回転します。 |

[`image_processing`][]には、[Vips](https://github.com/janko/image_processing/blob/master/doc/vips.md)および[MiniMagick](https://github.com/janko/image_processing/blob/master/doc/minimagick.md)プロセッサのための独自のドキュメントでさらにオプションがあります。


### ファイルのプレビュー

一部の非画像ファイルはプレビューできます。つまり、画像として表示することができます。
たとえば、ビデオファイルは最初のフレームを抽出してプレビューできます。Active Storageでは、
ビデオとPDFドキュメントのプレビューをサポートしています。遅延生成されたプレビューへのリンクを作成するには、
添付ファイルの[`preview`][]メソッドを使用します。

```erb
<%= image_tag message.video.preview(resize_to_limit: [100, 100]) %>
```

別の形式をサポートするには、独自のプレビューアを追加します。詳細については、
[`ActiveStorage::Preview`][]のドキュメントを参照してください。


直接アップロード
--------------

Active Storageは、付属のJavaScriptライブラリを使用して、クライアントからクラウドに直接アップロードすることをサポートしています。

### 使用法

1. アプリケーションのJavaScriptバンドルに`activestorage.js`を含めます。

    アセットパイプラインを使用する場合：

    ```js
    //= require activestorage
    ```

    npmパッケージを使用する場合：

    ```js
    import * as ActiveStorage from "@rails/activestorage"
    ActiveStorage.start()
    ```

2. [ファイルフィールド](form_helpers.html#uploading-files)に`direct_upload: true`を追加します。

    ```erb
    <%= form.file_field :attachments, multiple: true, direct_upload: true %>
    ```

    もしくは、`FormBuilder`を使用していない場合は、データ属性を直接追加します。

    ```erb
    <input type="file" data-direct-upload-url="<%= rails_direct_uploads_url %>" />
    ```

3. クロスオリジンリソース共有（CORS）を設定して、サードパーティのストレージサービスで直接アップロードリクエストを許可します。

4. 以上です！フォームの送信時にアップロードが開始されます。

### クロスオリジンリソース共有（CORS）の設定

サードパーティのサービスへの直接アップロードを動作させるためには、サービスを設定してアプリからのクロスオリジンリクエストを許可する必要があります。サービスのCORSドキュメントを参照してください。

* [S3](https://docs.aws.amazon.com/AmazonS3/latest/dev/cors.html#how-do-i-enable-cors)
* [Google Cloud Storage](https://cloud.google.com/storage/docs/configuring-cors)
* [Azure Storage](https://docs.microsoft.com/en-us/rest/api/storageservices/cross-origin-resource-sharing--cors--support-for-the-azure-storage-services)

以下を許可するように注意してください：

* アプリにアクセスされるすべてのオリジン
* `PUT`リクエストメソッド
* 次のヘッダー：
  * `Origin`
  * `Content-Type`
  * `Content-MD5`
  * `Content-Disposition`（Azure Storageを除く）
  * `x-ms-blob-content-disposition`（Azure Storageのみ）
  * `x-ms-blob-type`（Azure Storageのみ）
  * `Cache-Control`（GCSの場合、`cache_control`が設定されている場合のみ）
ディスクサービスでは、CORSの設定は必要ありません。なぜなら、アプリのオリジンを共有しているからです。

#### 例：S3 CORSの設定

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

#### 例：Google Cloud Storage CORSの設定

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

#### 例：Azure Storage CORSの設定

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

### ファイルの直接アップロードのJavaScriptイベント

| イベント名 | イベントターゲット | イベントデータ (`event.detail`) | 説明 |
| --- | --- | --- | --- |
| `direct-uploads:start` | `<form>` | なし | 直接アップロードフィールドを含むフォームが送信されました。 |
| `direct-upload:initialize` | `<input>` | `{id, file}` | フォームの送信後、すべてのファイルに対してディスパッチされます。 |
| `direct-upload:start` | `<input>` | `{id, file}` | 直接アップロードが開始されました。 |
| `direct-upload:before-blob-request` | `<input>` | `{id, file, xhr}` | 直接アップロードメタデータのリクエストをアプリケーションに送信する前に呼び出されます。 |
| `direct-upload:before-storage-request` | `<input>` | `{id, file, xhr}` | ファイルの保存リクエストを送信する前に呼び出されます。 |
| `direct-upload:progress` | `<input>` | `{id, file, progress}` | ファイルの保存リクエストの進行状況です。 |
| `direct-upload:error` | `<input>` | `{id, file, error}` | エラーが発生しました。このイベントがキャンセルされない限り、`alert`が表示されます。 |
| `direct-upload:end` | `<input>` | `{id, file}` | 直接アップロードが終了しました。 |
| `direct-uploads:end` | `<form>` | なし | すべての直接アップロードが終了しました。 |

### 例

これらのイベントを使用してアップロードの進行状況を表示することができます。

![direct-uploads](https://user-images.githubusercontent.com/5355/28694528-16e69d0c-72f8-11e7-91a7-c0b8cfc90391.gif)

フォームにアップロードされたファイルを表示するには：

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

スタイルを追加：

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

### カスタムのドラッグアンドドロップソリューション

この目的のために、`DirectUpload`クラスを使用することができます。選択したライブラリからファイルを受け取った場合、`DirectUpload`をインスタンス化し、その`create`メソッドを呼び出します。`create`メソッドには、アップロードが完了したときに呼び出すコールバックを指定します。

```js
import { DirectUpload } from "@rails/activestorage"

const input = document.querySelector('input[type=file]')

// ファイルのドロップにバインド - 親要素のondropを使用するか、
//  Dropzoneのようなライブラリを使用します
const onDrop = (event) => {
  event.preventDefault()
  const files = event.dataTransfer.files;
  Array.from(files).forEach(file => uploadFile(file))
}

// 通常のファイル選択にバインド
input.addEventListener('change', (event) => {
  Array.from(input.files).forEach(file => uploadFile(file))
  // 選択したファイルを入力からクリアするかもしれません
  input.value = null
})

const uploadFile = (file) => {
  // フォームには、file_field direct_upload: trueが必要で、
  //  data-direct-upload-urlが提供されます
  const url = input.dataset.directUploadUrl
  const upload = new DirectUpload(file, url)

  upload.create((error, blob) => {
    if (error) {
      // エラーを処理する
    } else {
      // 適切な名前の非表示の入力をフォームに追加し、
      //  値にblob.signed_idを設定して、通常のアップロードフローで
      //  blobのIDが送信されるようにします
      const hiddenField = document.createElement('input')
      hiddenField.setAttribute("type", "hidden");
      hiddenField.setAttribute("value", blob.signed_id);
      hiddenField.name = input.name
      document.querySelector('form').appendChild(hiddenField)
    }
  })
}
```

### ファイルのアップロードの進行状況を追跡する

`DirectUpload`コンストラクタを使用する場合、3番目のパラメータを含めることができます。
これにより、`DirectUpload`オブジェクトがアップロードプロセス中に`directUploadWillStoreFileWithXHR`メソッドを呼び出すことができます。
その後、必要に応じてXHRに独自の進行状況ハンドラをアタッチすることができます。
```js
import { DirectUpload } from "@rails/activestorage"

class Uploader {
  constructor(file, url) {
    this.upload = new DirectUpload(this.file, this.url, this)
  }

  upload(file) {
    this.upload.create((error, blob) => {
      if (error) {
        // エラーを処理する
      } else {
        // 適切な名前の非表示の入力をフォームに追加し、値にblob.signed_idを設定する
      }
    })
  }

  directUploadWillStoreFileWithXHR(request) {
    request.upload.addEventListener("progress",
      event => this.directUploadDidProgress(event))
  }

  directUploadDidProgress(event) {
    // event.loadedとevent.totalを使用して進捗バーを更新する
  }
}
```

### ライブラリやフレームワークとの統合

選択したライブラリからファイルを受け取った後、`DirectUpload`インスタンスを作成し、
アップロードプロセスを開始するためにその「create」メソッドを使用します。
必要に応じて、追加のヘッダーを指定することもできます。
「create」メソッドは、アップロードが完了した後にトリガーされるコールバック関数も必要です。

```js
import { DirectUpload } from "@rails/activestorage"

class Uploader {
  constructor(file, url, token) {
    const headers = { 'Authentication': `Bearer ${token}` }
    // INFO: ヘッダーを送信することはオプションのパラメータです。
    //       ヘッダーを送信しない場合、認証はクッキーまたはセッションデータを使用して行われます。
    this.upload = new DirectUpload(this.file, this.url, this, headers)
  }

  upload(file) {
    this.upload.create((error, blob) => {
      if (error) {
        // エラーを処理する
      } else {
        // 次のリクエストでblob.signed_idをファイルの参照として使用する
      }
    })
  }

  directUploadWillStoreFileWithXHR(request) {
    request.upload.addEventListener("progress",
      event => this.directUploadDidProgress(event))
  }

  directUploadDidProgress(event) {
    // event.loadedとevent.totalを使用して進捗バーを更新する
  }
}
```

カスタマイズされた認証を実装するには、Railsアプリケーションに次のような新しいコントローラを作成する必要があります。

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

注意: [Direct Uploads](#direct-uploads)を使用すると、アップロードされたファイルがレコードに添付されない場合があります。[未添付のアップロードを削除](#purging-unattached-uploads)することを検討してください。

テスト
-------------------------------------------

統合テストまたはコントローラーテストでファイルをアップロードするには、[`fixture_file_upload`][]を使用します。
Railsはファイルを他のパラメータと同様に処理します。

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


### テスト中に作成されたファイルの破棄

#### システムテスト

システムテストでは、トランザクションをロールバックすることでテストデータをクリーンアップします。
`destroy`がオブジェクトに呼び出されないため、添付されたファイルはクリーンアップされません。
ファイルをクリアするには、`after_teardown`コールバックで行うことができます。
ここで行うことで、テスト中に作成されたすべての接続が完了し、Active Storageがファイルを見つけられないというエラーが発生しなくなります。

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

[parallel tests]: testing.html#parallel-testing

#### 統合テスト

システムテストと同様に、統合テスト中にアップロードされたファイルは自動的にクリーンアップされません。
ファイルをクリアするには、`teardown`コールバックで行うことができます。

```ruby
class ActionDispatch::IntegrationTest
  def after_teardown
    super
    FileUtils.rm_rf(ActiveStorage::Blob.service.root)
  end
end
```

[parallel tests]: testing.html#parallel-testing

### フィクスチャに添付ファイルを追加する

既存の[fixtures][]に添付ファイルを追加することができます。
まず、別のストレージサービスを作成する必要があります。

```yml
# config/storage.yml

test_fixtures:
  service: Disk
  root: <%= Rails.root.join("tmp/storage_fixtures") %>
```

これにより、Active Storageがフィクスチャファイルを「アップロード」する場所が指定されます。
一時ディレクトリである必要があります。通常の`test`サービスとは異なるディレクトリにすることで、
テスト中にアップロードされたファイルとフィクスチャファイルを分離することができます。
次に、Active Storageクラスのためのフィクスチャファイルを作成します。

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

次に、対応するファイルをフィクスチャディレクトリ（デフォルトパスは`test/fixtures/files`です）に配置します。
詳細については、[`ActiveStorage::FixtureSet`][]のドキュメントを参照してください。

設定が完了したら、テストで添付ファイルにアクセスできるようになります。

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

#### フィクスチャのクリーンアップ

テストでアップロードされたファイルは、[各テストの終了時](#discarding-files-created-during-tests)にクリーンアップされますが、
フィクスチャファイルはすべてのテストが完了したときに一度だけクリーンアップする必要があります。

並列テストを使用している場合は、`parallelize_teardown`を呼び出します。

```ruby
class ActiveSupport::TestCase
  # ...
  parallelize_teardown do |i|
    FileUtils.rm_rf(ActiveStorage::Blob.services.fetch(:test_fixtures).root)
  end
  # ...
end
```

並列テストを実行していない場合は、`Minitest.after_run`またはテストフレームワークに応じた同等の方法（例：RSpecの`after(:suite)`）を使用します。

```ruby
# test_helper.rb

Minitest.after_run do
  FileUtils.rm_rf(ActiveStorage::Blob.services.fetch(:test_fixtures).root)
end
```


### サービスの設定

テスト環境で使用するサービスを設定するには、`config/storage/test.yml`を追加できます。
これは、`service`オプションが使用されている場合に便利です。

```ruby
class User < ApplicationRecord
  has_one_attached :avatar, service: :s3
end
```

`config/storage/test.yml`がない場合、`config/storage.yml`で設定された`s3`サービスが使用されます - テストを実行している場合でも。

デフォルトの設定が使用され、ファイルは`config/storage.yml`で設定されたサービスプロバイダにアップロードされます。

この場合、`config/storage/test.yml`を追加し、`s3`サービスに対してDiskサービスを使用してリクエストを送信しないようにすることができます。

```yaml
test:
  service: Disk
  root: <%= Rails.root.join("tmp/storage") %>

s3:
  service: Disk
  root: <%= Rails.root.join("tmp/storage") %>
```

他のクラウドサービスのサポートを実装する
---------------------------------------------

これら以外のクラウドサービスをサポートする必要がある場合は、Serviceを実装する必要があります。
各サービスは、クラウドへのファイルのアップロードとダウンロードに必要なメソッドを実装することで、
[`ActiveStorage::Service`](https://api.rubyonrails.org/classes/ActiveStorage/Service.html)を拡張します。

添付されていないアップロードの削除
--------------------------

[Direct Uploads](#direct-uploads)を使用してファイルがアップロードされたが、レコードに添付されていない場合があります。
[unattachedスコープ](https://github.com/rails/rails/blob/8ef5bd9ced351162b673904a0b77c7034ca2bc20/activestorage/app/models/active_storage/blob.rb#L49)を使用して、添付されていないレコードをクエリできます。
以下は、[カスタムのrakeタスク](command_line.html#custom-rake-tasks)を使用した例です。

```ruby
namespace :active_storage do
  desc "Purges unattached Active Storage blobs. Run regularly."
  task purge_unattached: :environment do
    ActiveStorage::Blob.unattached.where(created_at: ..2.days.ago).find_each(&:purge_later)
  end
end
```

警告：`ActiveStorage::Blob.unattached`によって生成されるクエリは、データベースのサイズが大きいアプリケーションでは遅く、潜在的に混乱を引き起こす可能性があります。
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
