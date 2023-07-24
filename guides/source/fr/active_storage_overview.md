**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: b8e9de3d2aa934a8a6fc3e1dccb4824c
Aperçu d'Active Storage
=======================

Ce guide explique comment attacher des fichiers à vos modèles Active Record.

Après avoir lu ce guide, vous saurez :

* Comment attacher un ou plusieurs fichiers à un enregistrement.
* Comment supprimer un fichier attaché.
* Comment créer un lien vers un fichier attaché.
* Comment utiliser des variantes pour transformer des images.
* Comment générer une représentation d'image à partir d'un fichier non-image, tel qu'un PDF ou une vidéo.
* Comment envoyer des téléchargements de fichiers directement depuis les navigateurs vers un service de stockage, en contournant les serveurs de votre application.
* Comment nettoyer les fichiers stockés pendant les tests.
* Comment implémenter la prise en charge de services de stockage supplémentaires.

--------------------------------------------------------------------------------

Qu'est-ce qu'Active Storage ?
-----------------------------

Active Storage facilite le téléchargement de fichiers vers un service de stockage en nuage tel que Amazon S3, Google Cloud Storage ou Microsoft Azure Storage, et l'attachement de ces fichiers à des objets Active Record. Il est livré avec un service basé sur un disque local pour le développement et les tests, et prend en charge la duplication des fichiers vers des services subordonnés pour les sauvegardes et les migrations.

En utilisant Active Storage, une application peut transformer les téléchargements d'images ou générer des représentations d'images à partir de téléchargements non-images tels que des PDF et des vidéos, et extraire des métadonnées à partir de fichiers arbitraires.

### Exigences

Diverses fonctionnalités d'Active Storage dépendent de logiciels tiers que Rails n'installera pas et qui doivent être installés séparément :

* [libvips](https://github.com/libvips/libvips) v8.6+ ou [ImageMagick](https://imagemagick.org/index.php) pour l'analyse et les transformations d'images
* [ffmpeg](http://ffmpeg.org/) v3.4+ pour les aperçus vidéo et ffprobe pour l'analyse vidéo/audio
* [poppler](https://poppler.freedesktop.org/) ou [muPDF](https://mupdf.com/) pour les aperçus PDF

L'analyse et les transformations d'images nécessitent également le gem `image_processing`. Décommentez-le dans votre `Gemfile`, ou ajoutez-le si nécessaire :

```ruby
gem "image_processing", ">= 1.2"
```

CONSEIL : Comparé à libvips, ImageMagick est plus connu et plus largement disponible. Cependant, libvips peut être [jusqu'à 10 fois plus rapide et consommer 1/10 de la mémoire](https://github.com/libvips/libvips/wiki/Speed-and-memory-use). Pour les fichiers JPEG, cela peut être encore amélioré en remplaçant `libjpeg-dev` par `libjpeg-turbo-dev`, qui est [2 à 7 fois plus rapide](https://libjpeg-turbo.org/About/Performance).

AVERTISSEMENT : Avant d'installer et d'utiliser des logiciels tiers, assurez-vous de comprendre les implications de licence qui en découlent. MuPDF, en particulier, est sous licence AGPL et nécessite une licence commerciale pour certaines utilisations.

## Configuration

```bash
$ bin/rails active_storage:install
$ bin/rails db:migrate
```

Cela configure l'application et crée les trois tables utilisées par Active Storage : `active_storage_blobs`, `active_storage_attachments` et `active_storage_variant_records`.

| Table      | Objectif |
| ------------------- | ----- |
| `active_storage_blobs` | Stocke les données sur les fichiers téléchargés, telles que le nom de fichier et le type de contenu. |
| `active_storage_attachments` | Une table de jointure polymorphique qui [lie vos modèles aux blobs](#attaching-files-to-records). Si le nom de classe de votre modèle change, vous devrez exécuter une migration sur cette table pour mettre à jour le `record_type` sous-jacent avec le nouveau nom de classe de votre modèle. |
| `active_storage_variant_records` | Si le suivi des variantes est activé, stocke les enregistrements pour chaque variante générée. |

AVERTISSEMENT : Si vous utilisez des UUID à la place des entiers comme clé primaire sur vos modèles, vous devez définir `Rails.application.config.generators { |g| g.orm :active_record, primary_key_type: :uuid }` dans un fichier de configuration.

Déclarez les services Active Storage dans `config/storage.yml`. Pour chaque service utilisé par votre application, fournissez un nom et la configuration requise. L'exemple ci-dessous déclare trois services nommés `local`, `test` et `amazon` :

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
  region: "" # par exemple 'us-east-1'
```

Indiquez à Active Storage quel service utiliser en définissant `Rails.application.config.active_storage.service`. Étant donné que chaque environnement utilisera probablement un service différent, il est recommandé de le faire pour chaque environnement. Pour utiliser le service de disque à partir de l'exemple précédent dans l'environnement de développement, vous ajouteriez ce qui suit à `config/environments/development.rb` :

```ruby
# Stocker les fichiers localement.
config.active_storage.service = :local
```

Pour utiliser le service S3 en production, vous ajoutez ce qui suit à `config/environments/production.rb` :

```ruby
# Stocker les fichiers sur Amazon S3.
config.active_storage.service = :amazon
```

Pour utiliser le service de test lors des tests, vous ajoutez ce qui suit à `config/environments/test.rb` :

```ruby
# Stocker les fichiers téléchargés sur le système de fichiers local dans un répertoire temporaire.
config.active_storage.service = :test
```

REMARQUE : Les fichiers de configuration spécifiques à un environnement auront la priorité : en production, par exemple, le fichier `config/storage/production.yml` (s'il existe) aura la priorité sur le fichier `config/storage.yml`.

Il est recommandé d'utiliser `Rails.env` dans les noms de bucket pour réduire davantage le risque de destruction accidentelle de données de production.

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
Continuez à lire pour plus d'informations sur les adaptateurs de service intégrés (par exemple, `Disk` et `S3`) et la configuration dont ils ont besoin.

### Service Disk

Déclarez un service Disk dans `config/storage.yml` :

```yaml
local:
  service: Disk
  root: <%= Rails.root.join("storage") %>
```

### Service S3 (Amazon S3 et API compatibles S3)

Pour se connecter à Amazon S3, déclarez un service S3 dans `config/storage.yml` :

```yaml
amazon:
  service: S3
  access_key_id: ""
  secret_access_key: ""
  region: ""
  bucket: ""
```

Fournissez éventuellement des options client et d'upload :

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
    server_side_encryption: "" # 'aws:kms' or 'AES256'
    cache_control: "private, max-age=<%= 1.day.to_i %>"
```

CONSEIL : Définissez des délais d'attente HTTP et des limites de réessai raisonnables pour votre application. Dans certains scénarios d'échec, la configuration client AWS par défaut peut entraîner des connexions maintenues pendant plusieurs minutes et entraîner une mise en file d'attente des demandes.

Ajoutez la gem [`aws-sdk-s3`](https://github.com/aws/aws-sdk-ruby) à votre `Gemfile` :

```ruby
gem "aws-sdk-s3", require: false
```

REMARQUE : Les fonctionnalités principales de Active Storage nécessitent les autorisations suivantes : `s3:ListBucket`, `s3:PutObject`, `s3:GetObject` et `s3:DeleteObject`. L'accès public nécessite en plus `s3:PutObjectAcl`. Si vous avez d'autres options d'upload configurées, telles que la définition des ACL, des autorisations supplémentaires peuvent être nécessaires.

REMARQUE : Si vous souhaitez utiliser des variables d'environnement, des fichiers de configuration standard du SDK, des profils, des profils d'instance IAM ou de tâche, vous pouvez omettre les clés `access_key_id`, `secret_access_key` et `region` dans l'exemple ci-dessus. Le service S3 prend en charge toutes les options d'authentification décrites dans la [documentation du SDK AWS](https://docs.aws.amazon.com/sdk-for-ruby/v3/developer-guide/setup-config.html).

Pour vous connecter à une API de stockage d'objets compatible S3 telle que DigitalOcean Spaces, fournissez l'`endpoint` :

```yaml
digitalocean:
  service: S3
  endpoint: https://nyc3.digitaloceanspaces.com
  access_key_id: ...
  secret_access_key: ...
  # ...et d'autres options
```

Il existe de nombreuses autres options disponibles. Vous pouvez les vérifier dans la documentation de [AWS S3 Client](https://docs.aws.amazon.com/sdk-for-ruby/v3/api/Aws/S3/Client.html#initialize-instance_method).

### Service de stockage Microsoft Azure

Déclarez un service de stockage Azure dans `config/storage.yml` :

```yaml
azure:
  service: AzureStorage
  storage_account_name: ""
  storage_access_key: ""
  container: ""
```

Ajoutez la gem [`azure-storage-blob`](https://github.com/Azure/azure-storage-ruby) à votre `Gemfile` :

```ruby
gem "azure-storage-blob", "~> 2.0", require: false
```

### Service de stockage Google Cloud

Déclarez un service de stockage Google Cloud dans `config/storage.yml` :

```yaml
google:
  service: GCS
  credentials: <%= Rails.root.join("path/to/keyfile.json") %>
  project: ""
  bucket: ""
```

Fournissez éventuellement un Hash de credentials au lieu d'un chemin de fichier de clé :

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

Fournissez éventuellement un Cache-Control metadata à définir sur les assets uploadés :

```yaml
google:
  service: GCS
  ...
  cache_control: "public, max-age=3600"
```

Utilisez éventuellement [IAM](https://cloud.google.com/storage/docs/access-control/signed-urls#signing-iam) au lieu des `credentials` lors de la signature des URLs. Cela est utile si vous authentifiez vos applications GKE avec Workload Identity, consultez [ce billet de blog Google Cloud](https://cloud.google.com/blog/products/containers-kubernetes/introducing-workload-identity-better-authentication-for-your-gke-applications) pour plus d'informations.

```yaml
google:
  service: GCS
  ...
  iam: true
```

Utilisez éventuellement un GSA spécifique lors de la signature des URLs. Lors de l'utilisation d'IAM, le [serveur de métadonnées](https://cloud.google.com/compute/docs/storing-retrieving-metadata) sera contacté pour obtenir l'e-mail du GSA, mais ce serveur de métadonnées n'est pas toujours présent (par exemple, les tests locaux) et vous pouvez souhaiter utiliser un GSA non par défaut.

```yaml
google:
  service: GCS
  ...
  iam: true
  gsa_email: "foobar@baz.iam.gserviceaccount.com"
```

Ajoutez la gem [`google-cloud-storage`](https://github.com/GoogleCloudPlatform/google-cloud-ruby/tree/master/google-cloud-storage) à votre `Gemfile` :

```ruby
gem "google-cloud-storage", "~> 1.11", require: false
```

### Service de miroir

Vous pouvez maintenir plusieurs services synchronisés en définissant un service de miroir. Un service de miroir réplique les uploads et les suppressions sur deux services subordonnés ou plus.

Un service de miroir est destiné à être utilisé temporairement lors d'une migration entre services en production. Vous pouvez commencer à faire des miroirs vers un nouveau service, copier les fichiers préexistants de l'ancien service vers le nouveau, puis passer complètement au nouveau service.

REMARQUE : La mise en miroir n'est pas atomique. Il est possible qu'un upload réussisse sur le service principal et échoue sur l'un des services subordonnés. Avant de passer complètement à un nouveau service, vérifiez que tous les fichiers ont été copiés.

Définissez chacun des services que vous souhaitez mettre en miroir comme décrit ci-dessus. Référencez-les par leur nom lors de la définition d'un service de miroir :

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

Bien que tous les services secondaires reçoivent les uploads, les téléchargements sont toujours gérés par le service principal.

Les services de miroir sont compatibles avec les uploads directs. Les nouveaux fichiers sont directement téléchargés vers le service principal. Lorsqu'un fichier téléchargé directement est attaché à un enregistrement, un travail en arrière-plan est mis en file d'attente pour le copier vers les services secondaires.
### Accès public

Par défaut, Active Storage suppose un accès privé aux services. Cela signifie la génération d'URL signées et à usage unique pour les blobs. Si vous préférez rendre les blobs accessibles publiquement, spécifiez `public: true` dans le fichier `config/storage.yml` de votre application :

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

Assurez-vous que vos compartiments sont correctement configurés pour un accès public. Consultez la documentation sur la façon d'activer les autorisations de lecture publique pour les services de stockage [Amazon S3](https://docs.aws.amazon.com/AmazonS3/latest/user-guide/block-public-access-bucket.html), [Google Cloud Storage](https://cloud.google.com/storage/docs/access-control/making-data-public#buckets) et [Microsoft Azure](https://docs.microsoft.com/en-us/azure/storage/blobs/storage-manage-access-to-resources#set-container-public-access-level-in-the-azure-portal). Amazon S3 exige également que vous ayez l'autorisation `s3:PutObjectAcl`.

Lors de la conversion d'une application existante pour utiliser `public: true`, assurez-vous de mettre à jour chaque fichier individuel dans le compartiment pour qu'il soit accessible en lecture publique avant de passer à cette option.

Attacher des fichiers aux enregistrements
----------------------------------------

### `has_one_attached`

La macro [`has_one_attached`][] établit une correspondance un à un entre les enregistrements et les fichiers. Chaque enregistrement peut avoir un fichier attaché.

Par exemple, supposons que votre application ait un modèle `User`. Si vous voulez que chaque utilisateur ait un avatar, définissez le modèle `User` comme suit :

```ruby
class User < ApplicationRecord
  has_one_attached :avatar
end
```

ou si vous utilisez Rails 6.0+, vous pouvez exécuter une commande de génération de modèle comme ceci :

```ruby
bin/rails generate model User avatar:attachment
```

Vous pouvez créer un utilisateur avec un avatar :

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

Appelez [`avatar.attach`][Attached::One#attach] pour attacher un avatar à un utilisateur existant :

```ruby
user.avatar.attach(params[:avatar])
```

Appelez [`avatar.attached?`][Attached::One#attached?] pour déterminer si un utilisateur particulier a un avatar :

```ruby
user.avatar.attached?
```

Dans certains cas, vous voudrez peut-être remplacer un service par défaut pour une pièce jointe spécifique. Vous pouvez configurer des services spécifiques par pièce jointe en utilisant l'option `service` :

```ruby
class User < ApplicationRecord
  has_one_attached :avatar, service: :s3
end
```

Vous pouvez configurer des variantes spécifiques par pièce jointe en appelant la méthode `variant` sur l'objet attachable renvoyé :

```ruby
class User < ApplicationRecord
  has_one_attached :avatar do |attachable|
    attachable.variant :thumb, resize_to_limit: [100, 100]
  end
end
```

Appelez `avatar.variant(:thumb)` pour obtenir une variante de pouce d'un avatar :

```erb
<%= image_tag user.avatar.variant(:thumb) %>
```

Vous pouvez également utiliser des variantes spécifiques pour les aperçus :

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

La macro [`has_many_attached`][] établit une relation un à plusieurs entre les enregistrements et les fichiers. Chaque enregistrement peut avoir plusieurs fichiers attachés.

Par exemple, supposons que votre application ait un modèle `Message`. Si vous voulez que chaque message ait plusieurs images, définissez le modèle `Message` comme suit :

```ruby
class Message < ApplicationRecord
  has_many_attached :images
end
```

ou si vous utilisez Rails 6.0+, vous pouvez exécuter une commande de génération de modèle comme ceci :

```ruby
bin/rails generate model Message images:attachments
```

Vous pouvez créer un message avec des images :

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

Appelez [`images.attach`][Attached::Many#attach] pour ajouter de nouvelles images à un message existant :

```ruby
@message.images.attach(params[:images])
```

Appelez [`images.attached?`][Attached::Many#attached?] pour déterminer si un message particulier a des images :

```ruby
@message.images.attached?
```

La substitution du service par défaut se fait de la même manière que `has_one_attached`, en utilisant l'option `service` :

```ruby
class Message < ApplicationRecord
  has_many_attached :images, service: :s3
end
```

La configuration de variantes spécifiques se fait de la même manière que `has_one_attached`, en appelant la méthode `variant` sur l'objet attachable renvoyé :

```ruby
class Message < ApplicationRecord
  has_many_attached :images do |attachable|
    attachable.variant :thumb, resize_to_limit: [100, 100]
  end
end
```



### Attachement d'objets fichier/IO

Parfois, vous devez attacher un fichier qui n'arrive pas via une requête HTTP. Par exemple, vous voudrez peut-être attacher un fichier que vous avez généré sur le disque ou téléchargé à partir d'une URL soumise par l'utilisateur. Vous voudrez peut-être également attacher un fichier de fixture dans un test de modèle. Pour cela, fournissez un Hash contenant au moins un objet IO ouvert et un nom de fichier :

```ruby
@message.images.attach(io: File.open('/path/to/file'), filename: 'file.pdf')
```

Dans la mesure du possible, fournissez également un type de contenu. Active Storage tente de déterminer le type de contenu d'un fichier à partir de ses données. Il utilise le type de contenu que vous fournissez s'il ne peut pas le déterminer.
```ruby
@message.images.attach(io: File.open('/path/to/file'), filename: 'file.pdf', content_type: 'application/pdf')
```

Vous pouvez contourner l'inférence du type de contenu à partir des données en passant
`identify: false` avec le `content_type`.

```ruby
@message.images.attach(
  io: File.open('/path/to/file'),
  filename: 'file.pdf',
  content_type: 'application/pdf',
  identify: false
)
```

Si vous ne fournissez pas de type de contenu et que Active Storage ne peut pas déterminer
automatiquement le type de contenu du fichier, il se définit par défaut sur application/octet-stream.


Suppression de fichiers
--------------

Pour supprimer une pièce jointe d'un modèle, appelez [`purge`][Attached::One#purge] sur la
pièce jointe. Si votre application est configurée pour utiliser Active Job, la suppression peut être effectuée
en arrière-plan en appelant [`purge_later`][Attached::One#purge_later].
La suppression supprime le blob et le fichier du service de stockage.

```ruby
# Détruit synchroniquement l'avatar et les fichiers de ressources réels.
user.avatar.purge

# Détruit de manière asynchrone les modèles associés et les fichiers de ressources réels, via Active Job.
user.avatar.purge_later
```


Fourniture de fichiers
-------------

Active Storage prend en charge deux façons de fournir des fichiers : la redirection et la mise en proxy.

AVERTISSEMENT : Tous les contrôleurs Active Storage sont accessibles publiquement par défaut. Les
URL générées sont difficiles à deviner, mais permanentes par conception. Si vos fichiers
nécessitent un niveau de protection plus élevé, envisagez de mettre en œuvre
[des contrôleurs authentifiés](#authenticated-controllers).

### Mode de redirection

Pour générer une URL permanente pour un blob, vous pouvez passer le blob à l'aide de l'helper de vue
[`url_for`][ActionView::RoutingUrlFor#url_for]. Cela génère une
URL avec l'`signed_id` du blob qui est routé vers le [`RedirectController`][`ActiveStorage::Blobs::RedirectController`] du blob.

```ruby
url_for(user.avatar)
# => /rails/active_storage/blobs/:signed_id/my-avatar.png
```

Le `RedirectController` redirige vers le point de terminaison réel du service. Cette
indirection dissocie l'URL du service de l'URL réelle et permet, par exemple, de dupliquer les pièces jointes dans différents services pour une haute disponibilité.
La redirection a une expiration HTTP de 5 minutes.

Pour créer un lien de téléchargement, utilisez l'helper `rails_blob_{path|url}`. Cela vous permet de définir la disposition.

```ruby
rails_blob_path(user.avatar, disposition: "attachment")
```

AVERTISSEMENT : Pour prévenir les attaques XSS, Active Storage force l'en-tête Content-Disposition
à "attachment" pour certains types de fichiers. Pour modifier ce comportement, consultez les
options de configuration disponibles dans [Configuration des applications Rails](configuring.html#configuring-active-storage).

Si vous avez besoin de créer un lien en dehors du contexte du contrôleur/vue (tâches en arrière-plan,
Cronjobs, etc.), vous pouvez accéder à `rails_blob_path` de cette manière :

```ruby
Rails.application.routes.url_helpers.rails_blob_path(user.avatar, only_path: true)
```


### Mode de proxy

En option, les fichiers peuvent également être mis en proxy. Cela signifie que vos serveurs d'application téléchargeront les données de fichier à partir du service de stockage en réponse aux demandes. Cela peut être utile pour servir des fichiers à partir d'un CDN.

Vous pouvez configurer Active Storage pour utiliser le mode de proxy par défaut :

```ruby
# config/initializers/active_storage.rb
Rails.application.config.active_storage.resolve_model_to_route = :rails_storage_proxy
```

Ou si vous souhaitez mettre explicitement en proxy des pièces jointes spécifiques, il existe des helpers d'URL que vous pouvez utiliser sous la forme de `rails_storage_proxy_path` et `rails_storage_proxy_url`.

```erb
<%= image_tag rails_storage_proxy_path(@user.avatar) %>
```

#### Mettre un CDN devant Active Storage

De plus, pour utiliser un CDN pour les pièces jointes Active Storage, vous devrez générer des URLs avec le mode de proxy afin qu'elles soient servies par votre application et que le CDN mette en cache la pièce jointe sans aucune configuration supplémentaire. Cela fonctionne directement car le contrôleur de proxy Active Storage par défaut définit un en-tête HTTP indiquant au CDN de mettre en cache la réponse.

Vous devez également vous assurer que les URLs générées utilisent l'hôte du CDN au lieu de l'hôte de votre application. Il existe plusieurs façons d'y parvenir, mais en général, cela implique de modifier votre fichier `config/routes.rb` afin de pouvoir générer les URLs appropriées pour les pièces jointes et leurs variations. Par exemple, vous pouvez ajouter ceci :

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

et ensuite générer des routes comme ceci :

```erb
<%= cdn_image_url(user.avatar.variant(resize_to_limit: [128, 128])) %>
```

### Contrôleurs authentifiés

Tous les contrôleurs Active Storage sont accessibles publiquement par défaut. Les
URL générées utilisent un [`signed_id`][ActiveStorage::Blob#signed_id] simple, ce qui les rend difficiles à
deviner mais permanentes. Toute personne connaissant l'URL du blob pourra y accéder,
même si un `before_action` dans votre `ApplicationController` nécessiterait normalement une connexion. Si vos fichiers nécessitent un niveau de protection plus élevé, vous pouvez
mettre en œuvre vos propres contrôleurs authentifiés, basés sur
[`ActiveStorage::Blobs::RedirectController`][],
[`ActiveStorage::Blobs::ProxyController`][],
[`ActiveStorage::Representations::RedirectController`][] et
[`ActiveStorage::Representations::ProxyController`][]

Pour permettre uniquement à un compte d'accéder à son propre logo, vous pouvez faire ce qui suit :
```ruby
# config/routes.rb
resource :account do
  resource :logo
end
```

```ruby
# app/controllers/logos_controller.rb
class LogosController < ApplicationController
  # Via ApplicationController:
  # include Authenticate, SetCurrentAccount

  def show
    redirect_to Current.account.logo.url
  end
end
```

```erb
<%= image_tag account_logo_path %>
```

Et ensuite, vous devriez désactiver les routes par défaut d'Active Storage avec :

```ruby
config.active_storage.draw_routes = false
```

pour empêcher l'accès aux fichiers via des URL accessibles publiquement.


Téléchargement de fichiers
--------------------------

Parfois, vous devez traiter un blob après son téléchargement, par exemple pour le convertir
dans un format différent. Utilisez la méthode [`download`][Blob#download] de la pièce jointe pour lire les données binaires d'un blob
en mémoire :

```ruby
binary = user.avatar.download
```

Vous voudrez peut-être télécharger un blob vers un fichier sur le disque afin qu'un programme externe (par exemple,
un scanner de virus ou un transcodeur multimédia) puisse y travailler. Utilisez la méthode
[`open`][Blob#open] de la pièce jointe pour télécharger un blob vers un fichier temporaire sur le disque :

```ruby
message.video.open do |file|
  system '/path/to/virus/scanner', file.path
  # ...
end
```

Il est important de savoir que le fichier n'est pas encore disponible dans le rappel `after_create` mais seulement dans le `after_create_commit`.


Analyse des fichiers
--------------------

Active Storage analyse les fichiers une fois qu'ils ont été téléchargés en mettant en file d'attente un travail dans Active Job. Les fichiers analysés stockent des informations supplémentaires dans le hachage de métadonnées, y compris `analyzed: true`. Vous pouvez vérifier si un blob a été analysé en appelant [`analyzed?`][] sur celui-ci.

L'analyse d'image fournit les attributs `width` et `height`. L'analyse vidéo fournit ceux-ci, ainsi que `duration`, `angle`, `display_aspect_ratio`, et les booléens `video` et `audio` pour indiquer la présence de ces canaux. L'analyse audio fournit les attributs `duration` et `bit_rate`.


Affichage d'images, de vidéos et de PDF
---------------------------------------

Active Storage prend en charge la représentation de différents types de fichiers. Vous pouvez appeler
[`representation`][] sur une pièce jointe pour afficher une variante d'image, ou un
aperçu d'une vidéo ou d'un PDF. Avant d'appeler `representation`, vérifiez si la
pièce jointe peut être représentée en appelant [`representable?`]. Certains formats de fichier
ne peuvent pas être prévisualisés par Active Storage par défaut (par exemple, les documents Word) ; si
`representable?` renvoie false, vous voudrez peut-être [lier](#serving-files)
le fichier à la place.

```erb
<ul>
  <% @message.files.each do |file| %>
    <li>
      <% if file.representable? %>
        <%= image_tag file.representation(resize_to_limit: [100, 100]) %>
      <% else %>
        <%= link_to rails_blob_path(file, disposition: "attachment") do %>
          <%= image_tag "placeholder.png", alt: "Télécharger le fichier" %>
        <% end %>
      <% end %>
    </li>
  <% end %>
</ul>
```

En interne, `representation` appelle `variant` pour les images et `preview` pour
les fichiers pouvant être prévisualisés. Vous pouvez également appeler ces méthodes directement.


### Chargement différé vs immédiat

Par défaut, Active Storage traitera les représentations de manière différée. Ce code :

```ruby
image_tag file.representation(resize_to_limit: [100, 100])
```

Générera une balise `<img>` avec le `src` pointant vers le
[`ActiveStorage::Representations::RedirectController`][]. Le navigateur effectuera
une demande à ce contrôleur, qui effectuera les opérations suivantes :

1. Traiter le fichier et télécharger le fichier traité si nécessaire.
2. Renvoyer une redirection `302` vers le fichier, soit vers
  * le service distant (par exemple, S3).
  * ou `ActiveStorage::Blobs::ProxyController` qui renverra le contenu du fichier si le [mode proxy](#proxy-mode) est activé.

Le chargement différé du fichier permet aux fonctionnalités telles que les [URL à usage unique](#public-access)
de fonctionner sans ralentir le chargement initial de la page.

Cela fonctionne bien pour la plupart des cas.

Si vous souhaitez générer immédiatement des URL pour les images, vous pouvez appeler `.processed.url` :

```ruby
image_tag file.representation(resize_to_limit: [100, 100]).processed.url
```

Le suivi des variantes d'Active Storage améliore les performances de ceci, en stockant un
enregistrement dans la base de données si la représentation demandée a déjà été traitée.
Ainsi, le code ci-dessus ne fera qu'un appel à l'API du service distant (par exemple, S3)
une seule fois, et une fois qu'une variante est stockée, elle sera utilisée. Le suivi des variantes s'exécute
automatiquement, mais peut être désactivé via [`config.active_storage.track_variants`][].

Si vous affichez de nombreuses images sur une page, l'exemple ci-dessus pourrait entraîner
des requêtes N+1 pour charger tous les enregistrements de variantes. Pour éviter ces requêtes N+1,
utilisez les portées nommées sur [`ActiveStorage::Attachment`][].

```ruby
message.images.with_all_variant_records.each do |file|
  image_tag file.representation(resize_to_limit: [100, 100]).processed.url
end
```


### Transformation des images

La transformation des images vous permet d'afficher l'image aux dimensions de votre choix.
Pour créer une variation d'une image, appelez [`variant`][] sur la pièce jointe. Vous
pouvez passer toute transformation prise en charge par le processeur de variantes à la méthode.
Lorsque le navigateur accède à l'URL de la variante, Active Storage transforme
de manière différée le blob d'origine dans le format spécifié et redirige vers son nouvel emplacement de service.

```erb
<%= image_tag user.avatar.variant(resize_to_limit: [100, 100]) %>
```
Si une variante est demandée, Active Storage appliquera automatiquement des transformations en fonction du format de l'image :

1. Les types de contenu variables (tels que dictés par [`config.active_storage.variable_content_types`][]) et qui ne sont pas considérés comme des images web (tels que dictés par [`config.active_storage.web_image_content_types`][]), seront convertis en PNG.

2. Si `quality` n'est pas spécifié, la qualité par défaut du processeur de variantes pour le format sera utilisée.

Active Storage peut utiliser soit [Vips][] soit MiniMagick comme processeur de variantes.
Le choix par défaut dépend de la version cible de votre `config.load_defaults`, et
le processeur peut être modifié en définissant [`config.active_storage.variant_processor`][].

Les deux processeurs ne sont pas entièrement compatibles, donc lors de la migration d'une application existante
entre MiniMagick et Vips, certains changements doivent être effectués si des options spécifiques au format sont utilisées :

```rhtml
<!-- MiniMagick -->
<%= image_tag user.avatar.variant(resize_to_limit: [100, 100], format: :jpeg, sampling_factor: "4:2:0", strip: true, interlace: "JPEG", colorspace: "sRGB", quality: 80) %>

<!-- Vips -->
<%= image_tag user.avatar.variant(resize_to_limit: [100, 100], format: :jpeg, saver: { subsample_mode: "on", strip: true, interlace: true, quality: 80 }) %>
```

Les paramètres disponibles sont définis par la gem [`image_processing`][] et dépendent du
processeur de variantes que vous utilisez, mais les deux prennent en charge les paramètres suivants :

| Paramètre      | Exemple | Description |
| ------------------- | ---------------- | ----- |
| `resize_to_limit` | `resize_to_limit: [100, 100]` | Réduit la taille de l'image pour s'adapter aux dimensions spécifiées tout en conservant le rapport d'aspect d'origine. Redimensionne uniquement l'image si elle est plus grande que les dimensions spécifiées. |
| `resize_to_fit` | `resize_to_fit: [100, 100]` | Redimensionne l'image pour s'adapter aux dimensions spécifiées tout en conservant le rapport d'aspect d'origine. Réduit la taille de l'image si elle est plus grande que les dimensions spécifiées ou l'agrandit si elle est plus petite. |
| `resize_to_fill` | `resize_to_fill: [100, 100]` | Redimensionne l'image pour remplir les dimensions spécifiées tout en conservant le rapport d'aspect d'origine. Si nécessaire, recadre l'image dans la dimension la plus grande. |
| `resize_and_pad` | `resize_and_pad: [100, 100]` | Redimensionne l'image pour s'adapter aux dimensions spécifiées tout en conservant le rapport d'aspect d'origine. Si nécessaire, remplit la zone restante avec une couleur transparente si l'image source a un canal alpha, sinon avec du noir. |
| `crop` | `crop: [20, 50, 300, 300]` | Extrait une zone d'une image. Les deux premiers arguments sont les bords gauche et supérieur de la zone à extraire, tandis que les deux derniers arguments sont la largeur et la hauteur de la zone à extraire. |
| `rotate` | `rotate: 90` | Fait pivoter l'image selon l'angle spécifié. |

[`image_processing`][] propose plus d'options disponibles (comme `saver` qui permet de configurer la compression de l'image) dans sa propre documentation pour les processeurs [Vips](https://github.com/janko/image_processing/blob/master/doc/vips.md) et [MiniMagick](https://github.com/janko/image_processing/blob/master/doc/minimagick.md).



### Aperçu des fichiers

Certains fichiers non image peuvent être prévisualisés : c'est-à-dire, ils peuvent être présentés comme des images.
Par exemple, un fichier vidéo peut être prévisualisé en extrayant sa première image. Par défaut,
Active Storage prend en charge la prévisualisation des vidéos et des documents PDF. Pour créer
un lien vers une prévisualisation générée de manière paresseuse, utilisez la méthode [`preview`][] de la pièce jointe :

```erb
<%= image_tag message.video.preview(resize_to_limit: [100, 100]) %>
```

Pour ajouter la prise en charge d'un autre format, ajoutez votre propre visualiseur. Consultez la
documentation de [`ActiveStorage::Preview`][] pour plus d'informations.


Téléchargements directs
--------------

Active Storage, avec sa bibliothèque JavaScript incluse, prend en charge le téléchargement
directement depuis le client vers le cloud.

### Utilisation

1. Inclure `activestorage.js` dans le bundle JavaScript de votre application.

    Utilisation du pipeline d'assets :

    ```js
    //= require activestorage
    ```

    Utilisation du package npm :

    ```js
    import * as ActiveStorage from "@rails/activestorage"
    ActiveStorage.start()
    ```

2. Ajouter `direct_upload: true` à votre [champ de fichier](form_helpers.html#uploading-files) :

    ```erb
    <%= form.file_field :attachments, multiple: true, direct_upload: true %>
    ```

    Ou, si vous n'utilisez pas un `FormBuilder`, ajoutez directement l'attribut de données :

    ```erb
    <input type="file" data-direct-upload-url="<%= rails_direct_uploads_url %>" />
    ```

3. Configurer CORS sur les services de stockage tiers pour autoriser les requêtes de téléchargement direct.

4. C'est tout ! Les téléchargements commencent dès la soumission du formulaire.

### Configuration du partage de ressources entre origines différentes (CORS)

Pour que les téléchargements directs vers un service tiers fonctionnent, vous devrez configurer le service pour autoriser les requêtes entre origines différentes depuis votre application. Consultez la documentation CORS de votre service :

* [S3](https://docs.aws.amazon.com/AmazonS3/latest/dev/cors.html#how-do-i-enable-cors)
* [Google Cloud Storage](https://cloud.google.com/storage/docs/configuring-cors)
* [Azure Storage](https://docs.microsoft.com/en-us/rest/api/storageservices/cross-origin-resource-sharing--cors--support-for-the-azure-storage-services)

Veillez à autoriser :

* Toutes les origines à partir desquelles votre application est accessible
* La méthode de requête `PUT`
* Les en-têtes suivants :
  * `Origin`
  * `Content-Type`
  * `Content-MD5`
  * `Content-Disposition` (sauf pour Azure Storage)
  * `x-ms-blob-content-disposition` (uniquement pour Azure Storage)
  * `x-ms-blob-type` (uniquement pour Azure Storage)
  * `Cache-Control` (pour GCS, uniquement si `cache_control` est défini)
Aucune configuration CORS n'est requise pour le service Disk car il partage l'origine de votre application.

#### Exemple: Configuration CORS S3

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

#### Exemple: Configuration CORS Google Cloud Storage

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

#### Exemple: Configuration CORS Azure Storage

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

### Événements JavaScript de téléchargement direct

| Nom de l'événement | Cible de l'événement | Données de l'événement (`event.detail`) | Description |
| --- | --- | --- | --- |
| `direct-uploads:start` | `<form>` | Aucune | Un formulaire contenant des fichiers pour les champs de téléchargement direct a été soumis. |
| `direct-upload:initialize` | `<input>` | `{id, file}` | Déclenché pour chaque fichier après la soumission du formulaire. |
| `direct-upload:start` | `<input>` | `{id, file}` | Un téléchargement direct est en cours de démarrage. |
| `direct-upload:before-blob-request` | `<input>` | `{id, file, xhr}` | Avant de faire une demande à votre application pour les métadonnées de téléchargement direct. |
| `direct-upload:before-storage-request` | `<input>` | `{id, file, xhr}` | Avant de faire une demande pour stocker un fichier. |
| `direct-upload:progress` | `<input>` | `{id, file, progress}` | Au fur et à mesure que les demandes de stockage de fichiers progressent. |
| `direct-upload:error` | `<input>` | `{id, file, error}` | Une erreur s'est produite. Une `alerte` s'affiche sauf si cet événement est annulé. |
| `direct-upload:end` | `<input>` | `{id, file}` | Un téléchargement direct est terminé. |
| `direct-uploads:end` | `<form>` | Aucune | Tous les téléchargements directs sont terminés. |

### Exemple

Vous pouvez utiliser ces événements pour afficher la progression d'un téléchargement.

![direct-uploads](https://user-images.githubusercontent.com/5355/28694528-16e69d0c-72f8-11e7-91a7-c0b8cfc90391.gif)

Pour afficher les fichiers téléchargés dans un formulaire:

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

Ajoutez des styles:

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

### Solutions personnalisées de glisser-déposer

Vous pouvez utiliser la classe `DirectUpload` à cette fin. Lors de la réception d'un fichier de votre bibliothèque
de choix, instanciez un `DirectUpload` et appelez sa méthode `create`. `create` prend
un rappel à invoquer lorsque le téléchargement est terminé.

```js
import { DirectUpload } from "@rails/activestorage"

const input = document.querySelector('input[type=file]')

// Lier à la dépose de fichiers - utiliser ondrop sur un élément parent ou utiliser une
//  bibliothèque comme Dropzone
const onDrop = (event) => {
  event.preventDefault()
  const files = event.dataTransfer.files;
  Array.from(files).forEach(file => uploadFile(file))
}

// Lier à la sélection normale de fichiers
input.addEventListener('change', (event) => {
  Array.from(input.files).forEach(file => uploadFile(file))
  // vous pouvez effacer les fichiers sélectionnés de l'entrée
  input.value = null
})

const uploadFile = (file) => {
  // votre formulaire doit avoir le champ de fichier file_field direct_upload: true, qui
  //  fournit data-direct-upload-url
  const url = input.dataset.directUploadUrl
  const upload = new DirectUpload(file, url)

  upload.create((error, blob) => {
    if (error) {
      // Gérer l'erreur
    } else {
      // Ajouter un champ caché avec un nom approprié au formulaire avec une
      //  valeur de blob.signed_id afin que les identifiants de blob soient
      //  transmis dans le flux de téléchargement normal
      const hiddenField = document.createElement('input')
      hiddenField.setAttribute("type", "hidden");
      hiddenField.setAttribute("value", blob.signed_id);
      hiddenField.name = input.name
      document.querySelector('form').appendChild(hiddenField)
    }
  })
}
```

### Suivre la progression du téléchargement du fichier

Lors de l'utilisation du constructeur `DirectUpload`, il est possible d'inclure un troisième paramètre.
Cela permet à l'objet `DirectUpload` d'appeler la méthode `directUploadWillStoreFileWithXHR`
pendant le processus de téléchargement.
Vous pouvez ensuite attacher votre propre gestionnaire de progression à la XHR selon vos besoins.
```js
import { DirectUpload } from "@rails/activestorage"

class Uploader {
  constructor(file, url) {
    this.upload = new DirectUpload(this.file, this.url, this)
  }

  upload(file) {
    this.upload.create((error, blob) => {
      if (error) {
        // Gérer l'erreur
      } else {
        // Ajouter un champ caché avec un nom approprié au formulaire
        // avec une valeur de blob.signed_id
      }
    })
  }

  directUploadWillStoreFileWithXHR(request) {
    request.upload.addEventListener("progress",
      event => this.directUploadDidProgress(event))
  }

  directUploadDidProgress(event) {
    // Utiliser event.loaded et event.total pour mettre à jour la barre de progression
  }
}
```

### Intégration avec des bibliothèques ou des frameworks

Une fois que vous avez reçu un fichier de la bibliothèque que vous avez sélectionnée, vous devez créer
une instance de `DirectUpload` et utiliser sa méthode "create" pour lancer le processus de téléchargement,
en ajoutant les en-têtes supplémentaires nécessaires. La méthode "create" nécessite également
une fonction de rappel qui sera déclenchée une fois le téléchargement terminé.

```js
import { DirectUpload } from "@rails/activestorage"

class Uploader {
  constructor(file, url, token) {
    const headers = { 'Authentication': `Bearer ${token}` }
    // INFO: L'envoi des en-têtes est un paramètre facultatif. Si vous choisissez de ne pas envoyer d'en-têtes,
    //       l'authentification sera effectuée à l'aide de cookies ou de données de session.
    this.upload = new DirectUpload(this.file, this.url, this, headers)
  }

  upload(file) {
    this.upload.create((error, blob) => {
      if (error) {
        // Gérer l'erreur
      } else {
        // Utiliser blob.signed_id comme référence de fichier dans la prochaine requête
      }
    })
  }

  directUploadWillStoreFileWithXHR(request) {
    request.upload.addEventListener("progress",
      event => this.directUploadDidProgress(event))
  }

  directUploadDidProgress(event) {
    // Utiliser event.loaded et event.total pour mettre à jour la barre de progression
  }
}
```

Pour implémenter une authentification personnalisée, un nouveau contrôleur doit être créé sur
l'application Rails, similaire à celui-ci :

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

NOTE : L'utilisation des [Direct Uploads](#direct-uploads) peut parfois entraîner le téléchargement d'un fichier qui n'est jamais attaché à un enregistrement. Considérez la possibilité de [purger les téléchargements non attachés](#purging-unattached-uploads).

Test
-------------------------------------------

Utilisez [`fixture_file_upload`][] pour tester le téléchargement d'un fichier dans un test d'intégration ou de contrôleur.
Rails traite les fichiers comme n'importe quel autre paramètre.

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


### Suppression des fichiers créés lors des tests

#### Tests système

Les tests système nettoient les données de test en annulant une transaction. Comme `destroy`
n'est jamais appelé sur un objet, les fichiers attachés ne sont jamais nettoyés. Si vous
voulez supprimer les fichiers, vous pouvez le faire dans un rappel `after_teardown`. Le faire
ici garantit que toutes les connexions créées pendant le test sont terminées et
vous ne recevrez pas d'erreur d'Active Storage indiquant qu'il ne peut pas trouver un fichier.

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

Si vous utilisez des [tests parallèles][] et le service `DiskService`, vous devez configurer chaque processus pour utiliser son propre
dossier pour Active Storage. De cette façon, le rappel `teardown` ne supprimera que les fichiers des tests du processus concerné.

```ruby
class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  # ...
  parallelize_setup do |i|
    ActiveStorage::Blob.service.root = "#{ActiveStorage::Blob.service.root}-#{i}"
  end
  # ...
end
```

Si vos tests système vérifient la suppression d'un modèle avec des pièces jointes et que vous utilisez Active Job, configurez votre environnement de test pour utiliser l'adaptateur de file d'attente en ligne afin que le travail de purge soit exécuté immédiatement plutôt qu'à un moment inconnu dans le futur.

```ruby
# Utilisez le traitement des tâches en ligne pour que les choses se produisent immédiatement
config.active_job.queue_adapter = :inline
```

[tests parallèles]: testing.html#parallel-testing

#### Tests d'intégration

De la même manière que les tests système, les fichiers téléchargés lors des tests d'intégration ne seront pas
automatiquement nettoyés. Si vous voulez supprimer les fichiers, vous pouvez le faire dans un
rappel `teardown`.

```ruby
class ActionDispatch::IntegrationTest
  def after_teardown
    super
    FileUtils.rm_rf(ActiveStorage::Blob.service.root)
  end
end
```

Si vous utilisez des [tests parallèles][] et le service Disk, vous devez configurer chaque processus pour utiliser son propre
dossier pour Active Storage. De cette façon, le rappel `teardown` ne supprimera que les fichiers des tests du processus concerné.

```ruby
class ActionDispatch::IntegrationTest
  parallelize_setup do |i|
    ActiveStorage::Blob.service.root = "#{ActiveStorage::Blob.service.root}-#{i}"
  end
end
```

[tests parallèles]: testing.html#parallel-testing

### Ajout de pièces jointes aux fixtures

Vous pouvez ajouter des pièces jointes à vos [fixtures][] existantes. Tout d'abord, vous devez créer un service de stockage séparé :

```yml
# config/storage.yml

test_fixtures:
  service: Disk
  root: <%= Rails.root.join("tmp/storage_fixtures") %>
```

Cela indique à Active Storage où "uploader" les fichiers de la fixture, il doit donc s'agir d'un répertoire temporaire. En le rendant
différent du service `test` habituel, vous pouvez séparer les fichiers de la fixture des fichiers téléchargés lors d'un
test.
Ensuite, créez des fichiers de fixture pour les classes Active Storage :

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

Ensuite, placez un fichier dans votre répertoire de fixtures (le chemin par défaut est `test/fixtures/files`) avec le nom de fichier correspondant.
Consultez la documentation de [`ActiveStorage::FixtureSet`][] pour plus d'informations.

Une fois que tout est configuré, vous pourrez accéder aux pièces jointes dans vos tests :

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

#### Nettoyage des fixtures

Alors que les fichiers téléchargés lors des tests sont nettoyés [à la fin de chaque test](#discarding-files-created-during-tests),
vous n'avez besoin de nettoyer les fichiers de fixture qu'une seule fois : lorsque tous vos tests sont terminés.

Si vous utilisez des tests parallèles, appelez `parallelize_teardown` :

```ruby
class ActiveSupport::TestCase
  # ...
  parallelize_teardown do |i|
    FileUtils.rm_rf(ActiveStorage::Blob.services.fetch(:test_fixtures).root)
  end
  # ...
end
```

Si vous n'exécutez pas de tests parallèles, utilisez `Minitest.after_run` ou l'équivalent pour votre framework de test
(par exemple, `after(:suite)` pour RSpec) :

```ruby
# test_helper.rb

Minitest.after_run do
  FileUtils.rm_rf(ActiveStorage::Blob.services.fetch(:test_fixtures).root)
end
```


### Configuration des services

Vous pouvez ajouter `config/storage/test.yml` pour configurer les services à utiliser dans l'environnement de test.
Cela est utile lorsque l'option `service` est utilisée.

```ruby
class User < ApplicationRecord
  has_one_attached :avatar, service: :s3
end
```

Sans `config/storage/test.yml`, le service `s3` configuré dans `config/storage.yml` est utilisé - même lors de l'exécution des tests.

La configuration par défaut serait utilisée et les fichiers seraient téléchargés vers le fournisseur de services configuré dans `config/storage.yml`.

Dans ce cas, vous pouvez ajouter `config/storage/test.yml` et utiliser le service Disk pour le service `s3` pour éviter d'envoyer des requêtes.

```yaml
test:
  service: Disk
  root: <%= Rails.root.join("tmp/storage") %>

s3:
  service: Disk
  root: <%= Rails.root.join("tmp/storage") %>
```

Mise en œuvre de la prise en charge d'autres services cloud
-----------------------------------------------------------

Si vous avez besoin de prendre en charge un service cloud autre que ceux-ci, vous devrez
implémenter le service. Chaque service étend
[`ActiveStorage::Service`](https://api.rubyonrails.org/classes/ActiveStorage/Service.html)
en implémentant les méthodes nécessaires pour télécharger et télécharger des fichiers vers le cloud.

Purge des téléchargements non attachés
--------------------------------------

Il arrive que des fichiers soient téléchargés mais jamais attachés à un enregistrement. Cela peut se produire lors de l'utilisation de [Direct Uploads](#direct-uploads). Vous pouvez interroger les enregistrements non attachés en utilisant la [portée non attachée](https://github.com/rails/rails/blob/8ef5bd9ced351162b673904a0b77c7034ca2bc20/activestorage/app/models/active_storage/blob.rb#L49). Voici un exemple utilisant une [tâche rake personnalisée](command_line.html#custom-rake-tasks).

```ruby
namespace :active_storage do
  desc "Purges unattached Active Storage blobs. Run regularly."
  task purge_unattached: :environment do
    ActiveStorage::Blob.unattached.where(created_at: ..2.days.ago).find_each(&:purge_later)
  end
end
```

AVERTISSEMENT : La requête générée par `ActiveStorage::Blob.unattached` peut être lente et potentiellement perturbatrice sur les applications avec de plus grandes bases de données.
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
