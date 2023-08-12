**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: b8e9de3d2aa934a8a6fc3e1dccb4824c
Resumen de Active Storage
=======================

Esta guía cubre cómo adjuntar archivos a tus modelos de Active Record.

Después de leer esta guía, sabrás:

* Cómo adjuntar uno o varios archivos a un registro.
* Cómo eliminar un archivo adjunto.
* Cómo enlazar a un archivo adjunto.
* Cómo usar variantes para transformar imágenes.
* Cómo generar una representación de imagen de un archivo que no es una imagen, como un PDF o un video.
* Cómo enviar cargas de archivos directamente desde navegadores a un servicio de almacenamiento, evitando los servidores de tu aplicación.
* Cómo limpiar los archivos almacenados durante las pruebas.
* Cómo implementar soporte para servicios de almacenamiento adicionales.

--------------------------------------------------------------------------------

¿Qué es Active Storage?
-----------------------

Active Storage facilita la carga de archivos a un servicio de almacenamiento en la nube como Amazon S3, Google Cloud Storage o Microsoft Azure Storage, y la adjunta a objetos de Active Record. Viene con un servicio basado en disco local para desarrollo y pruebas, y admite la duplicación de archivos en servicios subordinados para copias de seguridad y migraciones.

Usando Active Storage, una aplicación puede transformar cargas de imágenes o generar representaciones de imágenes de cargas que no son imágenes, como PDF y videos, y extraer metadatos de archivos arbitrarios.

### Requisitos

Varias características de Active Storage dependen de software de terceros que Rails no instalará y que deben instalarse por separado:

* [libvips](https://github.com/libvips/libvips) v8.6+ o [ImageMagick](https://imagemagick.org/index.php) para análisis y transformaciones de imágenes.
* [ffmpeg](http://ffmpeg.org/) v3.4+ para vistas previas de videos y ffprobe para análisis de video/audio.
* [poppler](https://poppler.freedesktop.org/) o [muPDF](https://mupdf.com/) para vistas previas de PDF.

El análisis y las transformaciones de imágenes también requieren la gema `image_processing`. Descoméntala en tu `Gemfile`, o agrégala si es necesario:

```ruby
gem "image_processing", ">= 1.2"
```

CONSEJO: En comparación con libvips, ImageMagick es más conocido y más ampliamente disponible. Sin embargo, libvips puede ser [hasta 10 veces más rápido y consumir 1/10 de la memoria](https://github.com/libvips/libvips/wiki/Speed-and-memory-use). Para archivos JPEG, esto se puede mejorar aún más reemplazando `libjpeg-dev` con `libjpeg-turbo-dev`, que es [2-7 veces más rápido](https://libjpeg-turbo.org/About/Performance).

ADVERTENCIA: Antes de instalar y usar software de terceros, asegúrate de entender las implicaciones de licencia al hacerlo. MuPDF, en particular, está licenciado bajo AGPL y requiere una licencia comercial para algunos usos.

## Configuración

```bash
$ bin/rails active_storage:install
$ bin/rails db:migrate
```

Esto configura la configuración y crea las tres tablas que utiliza Active Storage: `active_storage_blobs`, `active_storage_attachments` y `active_storage_variant_records`.

| Tabla      | Propósito |
| ------------------- | ----- |
| `active_storage_blobs` | Almacena datos sobre los archivos cargados, como el nombre de archivo y el tipo de contenido. |
| `active_storage_attachments` | Una tabla de unión polimórfica que [conecta tus modelos con los blobs](#adjuntar-archivos-a-registros). Si el nombre de la clase de tu modelo cambia, deberás ejecutar una migración en esta tabla para actualizar el `record_type` subyacente al nuevo nombre de clase de tu modelo. |
| `active_storage_variant_records` | Si se habilita el [seguimiento de variantes](#adjuntar-archivos-a-registros), almacena registros para cada variante que se ha generado. |

ADVERTENCIA: Si estás utilizando UUID en lugar de enteros como clave primaria en tus modelos, debes configurar `Rails.application.config.generators { |g| g.orm :active_record, primary_key_type: :uuid }` en un archivo de configuración.

Declara los servicios de Active Storage en `config/storage.yml`. Para cada servicio que tu aplicación utiliza, proporciona un nombre y la configuración necesaria. El ejemplo a continuación declara tres servicios llamados `local`, `test` y `amazon`:

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
  region: "" # por ejemplo, 'us-east-1'
```

Indica a Active Storage qué servicio utilizar configurando `Rails.application.config.active_storage.service`. Debido a que cada entorno probablemente utilizará un servicio diferente, se recomienda hacer esto de manera específica para cada entorno. Para utilizar el servicio de disco del ejemplo anterior en el entorno de desarrollo, agregarías lo siguiente a `config/environments/development.rb`:

```ruby
# Almacena archivos localmente.
config.active_storage.service = :local
```

Para utilizar el servicio de S3 en producción, agregarías lo siguiente a `config/environments/production.rb`:

```ruby
# Almacena archivos en Amazon S3.
config.active_storage.service = :amazon
```

Para utilizar el servicio de prueba durante las pruebas, agregarías lo siguiente a `config/environments/test.rb`:

```ruby
# Almacena archivos cargados en el sistema de archivos local en un directorio temporal.
config.active_storage.service = :test
```

NOTA: Los archivos de configuración específicos del entorno tendrán prioridad: en producción, por ejemplo, el archivo `config/storage/production.yml` (si existe) tendrá prioridad sobre el archivo `config/storage.yml`.

Se recomienda utilizar `Rails.env` en los nombres de los buckets para reducir aún más el riesgo de destruir accidentalmente datos de producción.

```yaml
amazon:
  service: S3
  # ...
  bucket: tu_propio_bucket-<%= Rails.env %>

google:
  service: GCS
  # ...
  bucket: tu_propio_bucket-<%= Rails.env %>

azure:
  service: AzureStorage
  # ...
  container: tu_nombre_de_contenedor-<%= Rails.env %>
```
Sigue leyendo para obtener más información sobre los adaptadores de servicio integrados (por ejemplo, `Disk` y `S3`) y la configuración que requieren.

### Servicio de Disco

Declara un servicio de Disco en `config/storage.yml`:

```yaml
local:
  service: Disk
  root: <%= Rails.root.join("storage") %>
```

### Servicio S3 (Amazon S3 y APIs compatibles con S3)

Para conectarse a Amazon S3, declara un servicio S3 en `config/storage.yml`:

```yaml
amazon:
  service: S3
  access_key_id: ""
  secret_access_key: ""
  region: ""
  bucket: ""
```

Opcionalmente, proporciona opciones de cliente y carga:

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
    server_side_encryption: "" # 'aws:kms' o 'AES256'
    cache_control: "private, max-age=<%= 1.day.to_i %>"
```

CONSEJO: Establece tiempos de espera y límites de reintento HTTP sensatos para tu aplicación. En ciertos escenarios de fallos, la configuración predeterminada del cliente de AWS puede hacer que las conexiones se mantengan durante varios minutos y provoquen la acumulación de solicitudes.

Agrega la gema [`aws-sdk-s3`](https://github.com/aws/aws-sdk-ruby) a tu `Gemfile`:

```ruby
gem "aws-sdk-s3", require: false
```

NOTA: Las características principales de Active Storage requieren los siguientes permisos: `s3:ListBucket`, `s3:PutObject`, `s3:GetObject` y `s3:DeleteObject`. El [acceso público](#public-access) adicionalmente requiere `s3:PutObjectAcl`. Si tienes opciones de carga adicionales configuradas, como la configuración de ACL, es posible que se requieran permisos adicionales.

NOTA: Si deseas utilizar variables de entorno, archivos de configuración estándar del SDK, perfiles, perfiles de instancia IAM o roles de tareas, puedes omitir las claves `access_key_id`, `secret_access_key` y `region` en el ejemplo anterior. El servicio S3 admite todas las opciones de autenticación descritas en la [documentación del SDK de AWS](https://docs.aws.amazon.com/sdk-for-ruby/v3/developer-guide/setup-config.html).

Para conectarse a una API de almacenamiento de objetos compatible con S3, como DigitalOcean Spaces, proporciona el `endpoint`:

```yaml
digitalocean:
  service: S3
  endpoint: https://nyc3.digitaloceanspaces.com
  access_key_id: ...
  secret_access_key: ...
  # ...y otras opciones
```

Hay muchas otras opciones disponibles. Puedes consultarlas en la documentación de [AWS S3 Client](https://docs.aws.amazon.com/sdk-for-ruby/v3/api/Aws/S3/Client.html#initialize-instance_method).

### Servicio de Almacenamiento de Microsoft Azure

Declara un servicio de almacenamiento de Azure en `config/storage.yml`:

```yaml
azure:
  service: AzureStorage
  storage_account_name: ""
  storage_access_key: ""
  container: ""
```

Agrega la gema [`azure-storage-blob`](https://github.com/Azure/azure-storage-ruby) a tu `Gemfile`:

```ruby
gem "azure-storage-blob", "~> 2.0", require: false
```

### Servicio de Almacenamiento de Google Cloud

Declara un servicio de almacenamiento de Google Cloud en `config/storage.yml`:

```yaml
google:
  service: GCS
  credentials: <%= Rails.root.join("path/to/keyfile.json") %>
  project: ""
  bucket: ""
```

Opcionalmente, proporciona un Hash de credenciales en lugar de una ruta de archivo de clave:

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

Opcionalmente, proporciona una metadatos Cache-Control para establecer en los activos cargados:

```yaml
google:
  service: GCS
  ...
  cache_control: "public, max-age=3600"
```

Opcionalmente, utiliza [IAM](https://cloud.google.com/storage/docs/access-control/signed-urls#signing-iam) en lugar de `credentials` al firmar URLs. Esto es útil si estás autenticando tus aplicaciones de GKE con Workload Identity, consulta [esta publicación de blog de Google Cloud](https://cloud.google.com/blog/products/containers-kubernetes/introducing-workload-identity-better-authentication-for-your-gke-applications) para obtener más información.

```yaml
google:
  service: GCS
  ...
  iam: true
```

Opcionalmente, utiliza un GSA específico al firmar URLs. Cuando se utiliza IAM, se contactará al [servidor de metadatos](https://cloud.google.com/compute/docs/storing-retrieving-metadata) para obtener el correo electrónico del GSA, pero este servidor de metadatos no siempre está presente (por ejemplo, en pruebas locales) y es posible que desees utilizar un GSA no predeterminado.

```yaml
google:
  service: GCS
  ...
  iam: true
  gsa_email: "foobar@baz.iam.gserviceaccount.com"
```

Agrega la gema [`google-cloud-storage`](https://github.com/GoogleCloudPlatform/google-cloud-ruby/tree/master/google-cloud-storage) a tu `Gemfile`:

```ruby
gem "google-cloud-storage", "~> 1.11", require: false
```

### Servicio de Espejo

Puedes mantener varios servicios sincronizados definiendo un servicio de espejo. Un servicio de espejo replica las cargas y eliminaciones en dos o más servicios subordinados.

Un servicio de espejo está destinado a ser utilizado temporalmente durante una migración entre servicios en producción. Puedes comenzar a reflejar en un nuevo servicio, copiar archivos preexistentes del antiguo al nuevo, y luego utilizar completamente el nuevo servicio.

NOTA: La sincronización no es atómica. Es posible que una carga se realice correctamente en el servicio principal y falle en cualquiera de los servicios subordinados. Antes de utilizar completamente un nuevo servicio, verifica que se hayan copiado todos los archivos.

Define cada uno de los servicios que deseas reflejar como se describe anteriormente. Haz referencia a ellos por su nombre al definir un servicio de espejo:

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

Aunque todos los servicios secundarios reciben cargas, las descargas siempre son manejadas por el servicio principal.

Los servicios de espejo son compatibles con las cargas directas. Los archivos nuevos se cargan directamente en el servicio principal. Cuando un archivo cargado directamente se adjunta a un registro, se encola un trabajo en segundo plano para copiarlo en los servicios secundarios.
### Acceso público

Por defecto, Active Storage asume acceso privado a los servicios. Esto significa generar URLs firmadas y de un solo uso para los blobs. Si prefieres que los blobs sean accesibles públicamente, especifica `public: true` en el archivo `config/storage.yml` de tu aplicación:

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

Asegúrate de que tus buckets estén correctamente configurados para el acceso público. Consulta la documentación sobre cómo habilitar los permisos de lectura pública para los servicios de almacenamiento de [Amazon S3](https://docs.aws.amazon.com/AmazonS3/latest/user-guide/block-public-access-bucket.html), [Google Cloud Storage](https://cloud.google.com/storage/docs/access-control/making-data-public#buckets) y [Microsoft Azure](https://docs.microsoft.com/en-us/azure/storage/blobs/storage-manage-access-to-resources#set-container-public-access-level-in-the-azure-portal). Amazon S3 también requiere que tengas el permiso `s3:PutObjectAcl`.

Cuando conviertas una aplicación existente para usar `public: true`, asegúrate de actualizar cada archivo individual en el bucket para que sea legible públicamente antes de hacer el cambio.

Adjuntar archivos a registros
--------------------------

### `has_one_attached`

La macro [`has_one_attached`][] establece una relación uno a uno entre registros y archivos. Cada registro puede tener un archivo adjunto.

Por ejemplo, supongamos que tu aplicación tiene un modelo `User`. Si quieres que cada usuario tenga un avatar, define el modelo `User` de la siguiente manera:

```ruby
class User < ApplicationRecord
  has_one_attached :avatar
end
```

o si estás usando Rails 6.0+, puedes ejecutar un comando generador de modelo como este:

```ruby
bin/rails generate model User avatar:attachment
```

Puedes crear un usuario con un avatar:

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

Llama a [`avatar.attach`][Attached::One#attach] para adjuntar un avatar a un usuario existente:

```ruby
user.avatar.attach(params[:avatar])
```

Llama a [`avatar.attached?`][Attached::One#attached?] para determinar si un usuario en particular tiene un avatar:

```ruby
user.avatar.attached?
```

En algunos casos, es posible que desees anular un servicio predeterminado para un adjunto específico. Puedes configurar servicios específicos por adjunto utilizando la opción `service`:

```ruby
class User < ApplicationRecord
  has_one_attached :avatar, service: :s3
end
```

Puedes configurar variantes específicas por adjunto llamando al método `variant` en el objeto adjunto proporcionado:

```ruby
class User < ApplicationRecord
  has_one_attached :avatar do |attachable|
    attachable.variant :thumb, resize_to_limit: [100, 100]
  end
end
```

Llama a `avatar.variant(:thumb)` para obtener una variante de pulgar de un avatar:

```erb
<%= image_tag user.avatar.variant(:thumb) %>
```

También puedes usar variantes específicas para las vistas previas:

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

La macro [`has_many_attached`][] establece una relación uno a muchos entre registros y archivos. Cada registro puede tener muchos archivos adjuntos.

Por ejemplo, supongamos que tu aplicación tiene un modelo `Message`. Si quieres que cada mensaje tenga muchas imágenes, define el modelo `Message` de la siguiente manera:

```ruby
class Message < ApplicationRecord
  has_many_attached :images
end
```

o si estás usando Rails 6.0+, puedes ejecutar un comando generador de modelo como este:

```ruby
bin/rails generate model Message images:attachments
```

Puedes crear un mensaje con imágenes:

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

Llama a [`images.attach`][Attached::Many#attach] para agregar nuevas imágenes a un mensaje existente:

```ruby
@message.images.attach(params[:images])
```

Llama a [`images.attached?`][Attached::Many#attached?] para determinar si un mensaje en particular tiene imágenes:

```ruby
@message.images.attached?
```

La anulación del servicio predeterminado se realiza de la misma manera que `has_one_attached`, utilizando la opción `service`:

```ruby
class Message < ApplicationRecord
  has_many_attached :images, service: :s3
end
```

La configuración de variantes específicas se realiza de la misma manera que `has_one_attached`, llamando al método `variant` en el objeto adjunto proporcionado:

```ruby
class Message < ApplicationRecord
  has_many_attached :images do |attachable|
    attachable.variant :thumb, resize_to_limit: [100, 100]
  end
end
```



### Adjuntar objetos de archivo/IO

A veces necesitas adjuntar un archivo que no llega a través de una solicitud HTTP. Por ejemplo, es posible que desees adjuntar un archivo que generaste en el disco o descargaste desde una URL enviada por el usuario. También es posible que desees adjuntar un archivo de prueba en un modelo. Para hacer eso, proporciona un Hash que contenga al menos un objeto IO abierto y un nombre de archivo:

```ruby
@message.images.attach(io: File.open('/path/to/file'), filename: 'file.pdf')
```

Cuando sea posible, proporciona también un tipo de contenido. Active Storage intenta determinar el tipo de contenido de un archivo a partir de sus datos. Si no puede hacerlo, utilizará el tipo de contenido que proporciones.
```ruby
@message.images.attach(io: File.open('/path/to/file'), filename: 'file.pdf', content_type: 'application/pdf')
```

Puede evitar la inferencia del tipo de contenido de los datos pasando
`identify: false` junto con `content_type`.

```ruby
@message.images.attach(
  io: File.open('/path/to/file'),
  filename: 'file.pdf',
  content_type: 'application/pdf',
  identify: false
)
```

Si no proporciona un tipo de contenido y Active Storage no puede determinar
automáticamente el tipo de contenido del archivo, se establece por defecto en application/octet-stream.


Eliminación de archivos
--------------

Para eliminar un archivo adjunto de un modelo, llame a [`purge`][Attached::One#purge] en el
archivo adjunto. Si su aplicación está configurada para usar Active Job, la eliminación se puede hacer
en segundo plano llamando a [`purge_later`][Attached::One#purge_later].
La eliminación borra el blob y el archivo del servicio de almacenamiento.

```ruby
# Destruye sincrónicamente el avatar y los archivos de recursos reales.
user.avatar.purge

# Destruye los modelos asociados y los archivos de recursos reales de forma asincrónica, a través de Active Job.
user.avatar.purge_later
```


Servicio de archivos
-------------

Active Storage admite dos formas de servir archivos: redireccionamiento y proxy.

ADVERTENCIA: Todos los controladores de Active Storage son accesibles públicamente de forma predeterminada. Las
URL generadas son difíciles de adivinar, pero permanentes por diseño. Si sus archivos
requieren un nivel más alto de protección, considere implementar
[Controladores Autenticados](#authenticated-controllers).

### Modo de redireccionamiento

Para generar una URL permanente para un blob, puede pasar el blob al
ayudante de vista [`url_for`][ActionView::RoutingUrlFor#url_for]. Esto genera una
URL con el [`signed_id`][ActiveStorage::Blob#signed_id] del blob
que se enruta al [`RedirectController`][`ActiveStorage::Blobs::RedirectController`] del blob.

```ruby
url_for(user.avatar)
# => /rails/active_storage/blobs/:signed_id/my-avatar.png
```

El `RedirectController` redirige al punto final de servicio real. Esto
desacopla la URL del servicio de la URL real y permite, por ejemplo, reflejar los archivos adjuntos en diferentes servicios para una alta disponibilidad. La
redirección tiene una expiración HTTP de 5 minutos.

Para crear un enlace de descarga, use el ayudante `rails_blob_{path|url}`. Usando este
ayudante le permite establecer la disposición.

```ruby
rails_blob_path(user.avatar, disposition: "attachment")
```

ADVERTENCIA: Para evitar ataques XSS, Active Storage fuerza la cabecera Content-Disposition
a "attachment" para algunos tipos de archivos. Para cambiar este comportamiento, consulte las
opciones de configuración disponibles en [Configuración de aplicaciones Rails](configuring.html#configuring-active-storage).

Si necesita crear un enlace desde fuera del contexto del controlador/vista (trabajos en segundo plano, Cronjobs, etc.), puede acceder a `rails_blob_path` de esta manera:

```ruby
Rails.application.routes.url_helpers.rails_blob_path(user.avatar, only_path: true)
```


### Modo de proxy

Opcionalmente, los archivos también se pueden servir mediante proxy. Esto significa que los servidores de su aplicación descargarán los datos del archivo desde el servicio de almacenamiento en respuesta a las solicitudes. Esto puede ser útil para servir archivos desde una CDN.

Puede configurar Active Storage para que use el proxy de forma predeterminada:

```ruby
# config/initializers/active_storage.rb
Rails.application.config.active_storage.resolve_model_to_route = :rails_storage_proxy
```

O si desea proxy explícitamente adjuntos específicos, hay ayudantes de URL que puede usar en forma de `rails_storage_proxy_path` y `rails_storage_proxy_url`.

```erb
<%= image_tag rails_storage_proxy_path(@user.avatar) %>
```

#### Poner una CDN delante de Active Storage

Además, para usar una CDN para los archivos adjuntos de Active Storage, deberá generar URL con el modo de proxy para que sean servidos por su aplicación y la CDN almacenará en caché el archivo adjunto sin ninguna configuración adicional. Esto funciona de forma predeterminada porque el controlador de proxy de Active Storage establece una cabecera HTTP que indica a la CDN que almacene en caché la respuesta.

También debe asegurarse de que las URL generadas utilicen el host de la CDN en lugar del host de su aplicación. Hay varias formas de lograr esto, pero en general implica ajustar su archivo `config/routes.rb` para que pueda generar las URL adecuadas para los archivos adjuntos y sus variaciones. Como ejemplo, podría agregar esto:

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

y luego generar rutas de esta manera:

```erb
<%= cdn_image_url(user.avatar.variant(resize_to_limit: [128, 128])) %>
```

### Controladores autenticados

Todos los controladores de Active Storage son accesibles públicamente de forma predeterminada. Las
URL generadas utilizan un [`signed_id`][ActiveStorage::Blob#signed_id] simple, lo que las hace difíciles de
adivinar pero permanentes. Cualquier persona que conozca la URL del blob podrá acceder a ella,
incluso si un `before_action` en su `ApplicationController` requeriría iniciar sesión. Si sus archivos requieren un nivel más alto de protección, puede
implementar sus propios controladores autenticados, basados en
[`ActiveStorage::Blobs::RedirectController`][],
[`ActiveStorage::Blobs::ProxyController`][],
[`ActiveStorage::Representations::RedirectController`][] y
[`ActiveStorage::Representations::ProxyController`][]

Para permitir que solo una cuenta acceda a su propio logotipo, puede hacer lo siguiente:
```ruby
# config/routes.rb
resource :account do
  resource :logo
end
```

```ruby
# app/controllers/logos_controller.rb
class LogosController < ApplicationController
  # A través de ApplicationController:
  # incluir Autenticar, EstablecerCuentaActual

  def show
    redirect_to Current.account.logo.url
  end
end
```

```erb
<%= image_tag account_logo_path %>
```

Y luego debes desactivar las rutas predeterminadas de Active Storage con:

```ruby
config.active_storage.draw_routes = false
```

para evitar que los archivos se accedan con las URL públicamente accesibles.


Descargar archivos
-----------------

A veces necesitas procesar un blob después de que se haya cargado, por ejemplo, para convertirlo a un formato diferente. Usa el método [`download`][Blob#download] del adjunto para leer los datos binarios de un blob en memoria:

```ruby
binary = user.avatar.download
```

Es posible que desees descargar un blob a un archivo en disco para que un programa externo (por ejemplo, un escáner de virus o un transcodificador de medios) pueda operar en él. Usa el método [`open`][Blob#open] del adjunto para descargar un blob a un archivo temporal en disco:

```ruby
message.video.open do |file|
  system '/ruta/al/escáner/de/virus', file.path
  # ...
end
```

Es importante saber que el archivo aún no está disponible en el callback `after_create`, sino solo en `after_create_commit`.


Análisis de archivos
---------------

Active Storage analiza los archivos una vez que se han cargado encolando un trabajo en Active Job. Los archivos analizados almacenarán información adicional en el hash de metadatos, incluyendo `analyzed: true`. Puedes verificar si un blob ha sido analizado llamando a [`analyzed?`][] en él.

El análisis de imágenes proporciona los atributos `width` y `height`. El análisis de video proporciona estos, así como `duration`, `angle`, `display_aspect_ratio` y booleanos `video` y `audio` para indicar la presencia de esos canales. El análisis de audio proporciona los atributos `duration` y `bit_rate`.


Mostrar imágenes, videos y PDFs
---------------

Active Storage admite la representación de una variedad de archivos. Puedes llamar a [`representation`][] en un adjunto para mostrar una variante de imagen, o una vista previa de un video o PDF. Antes de llamar a `representation`, verifica si el adjunto se puede representar llamando a [`representable?`]. Algunos formatos de archivo no se pueden previsualizar con Active Storage de forma predeterminada (por ejemplo, documentos de Word); si `representable?` devuelve false, es posible que desees [enlazar](#serving-files) al archivo en su lugar.

```erb
<ul>
  <% @message.files.each do |file| %>
    <li>
      <% if file.representable? %>
        <%= image_tag file.representation(resize_to_limit: [100, 100]) %>
      <% else %>
        <%= link_to rails_blob_path(file, disposition: "attachment") do %>
          <%= image_tag "placeholder.png", alt: "Descargar archivo" %>
        <% end %>
      <% end %>
    </li>
  <% end %>
</ul>
```

Internamente, `representation` llama a `variant` para imágenes, y a `preview` para archivos que se pueden previsualizar. También puedes llamar a estos métodos directamente.


### Carga diferida vs inmediata

De forma predeterminada, Active Storage procesará las representaciones de forma diferida. Este código:

```ruby
image_tag file.representation(resize_to_limit: [100, 100])
```

Generará una etiqueta `<img>` con el `src` apuntando al
[`ActiveStorage::Representations::RedirectController`][]. El navegador realizará
una solicitud a ese controlador, que realizará lo siguiente:

1. Procesar el archivo y cargar el archivo procesado si es necesario.
2. Devolver una redirección `302` al archivo ya sea a
  * el servicio remoto (por ejemplo, S3).
  * o a `ActiveStorage::Blobs::ProxyController` que devolverá el contenido del archivo si [el modo de proxy](#proxy-mode) está habilitado.

La carga diferida del archivo permite que funciones como [URL de un solo uso](#public-access)
funcionen sin ralentizar la carga inicial de la página.

Esto funciona bien para la mayoría de los casos.

Si deseas generar URL para imágenes de inmediato, puedes llamar a `.processed.url`:

```ruby
image_tag file.representation(resize_to_limit: [100, 100]).processed.url
```

El rastreador de variantes de Active Storage mejora el rendimiento de esto, almacenando un
registro en la base de datos si la representación solicitada se ha procesado antes.
Por lo tanto, el código anterior solo realizará una llamada a la API del servicio remoto (por ejemplo, S3)
una vez, y una vez que se almacene una variante, la utilizará. El rastreador de variantes se ejecuta
automáticamente, pero se puede desactivar a través de [`config.active_storage.track_variants`][].

Si estás renderizando muchas imágenes en una página, el ejemplo anterior podría resultar
en consultas N+1 cargando todos los registros de variantes. Para evitar estas consultas N+1,
utiliza los ámbitos nombrados en [`ActiveStorage::Attachment`][].

```ruby
message.images.with_all_variant_records.each do |file|
  image_tag file.representation(resize_to_limit: [100, 100]).processed.url
end
```


### Transformar imágenes

La transformación de imágenes te permite mostrar la imagen en las dimensiones que elijas.
Para crear una variación de una imagen, llama a [`variant`][] en el adjunto. Puedes
pasar cualquier transformación admitida por el procesador de variantes al método.
Cuando el navegador accede a la URL de la variante, Active Storage transformará
perezosamente el blob original en el formato especificado y redireccionará a su nueva
ubicación de servicio.

```erb
<%= image_tag user.avatar.variant(resize_to_limit: [100, 100]) %>
```
Si se solicita una variante, Active Storage aplicará automáticamente transformaciones dependiendo del formato de la imagen:

1. Los tipos de contenido que son variables (según lo dictado por [`config.active_storage.variable_content_types`][]) y no se consideran imágenes web (según lo dictado por [`config.active_storage.web_image_content_types`][]), se convertirán a PNG.

2. Si no se especifica `quality`, se utilizará la calidad predeterminada del procesador de variantes para el formato.

Active Storage puede utilizar tanto [Vips][] como MiniMagick como procesador de variantes. El predeterminado depende de la versión objetivo de `config.load_defaults`, y el procesador se puede cambiar configurando [`config.active_storage.variant_processor`][].

Los dos procesadores no son completamente compatibles, por lo que al migrar una aplicación existente entre MiniMagick y Vips, se deben realizar algunos cambios si se utilizan opciones específicas del formato:

```rhtml
<!-- MiniMagick -->
<%= image_tag user.avatar.variant(resize_to_limit: [100, 100], format: :jpeg, sampling_factor: "4:2:0", strip: true, interlace: "JPEG", colorspace: "sRGB", quality: 80) %>

<!-- Vips -->
<%= image_tag user.avatar.variant(resize_to_limit: [100, 100], format: :jpeg, saver: { subsample_mode: "on", strip: true, interlace: true, quality: 80 }) %>
```

Los parámetros disponibles están definidos por la gema [`image_processing`][] y dependen del procesador de variantes que estés utilizando, pero ambos admiten los siguientes parámetros:

| Parámetro      | Ejemplo | Descripción |
| ------------------- | ---------------- | ----- |
| `resize_to_limit` | `resize_to_limit: [100, 100]` | Reduce el tamaño de la imagen para que se ajuste a las dimensiones especificadas mientras se mantiene la relación de aspecto original. Solo redimensionará la imagen si es más grande que las dimensiones especificadas. |
| `resize_to_fit` | `resize_to_fit: [100, 100]` | Redimensiona la imagen para que se ajuste a las dimensiones especificadas mientras se mantiene la relación de aspecto original. Reducirá el tamaño de la imagen si es más grande que las dimensiones especificadas o aumentará el tamaño si es más pequeña. |
| `resize_to_fill` | `resize_to_fill: [100, 100]` | Redimensiona la imagen para que llene las dimensiones especificadas mientras se mantiene la relación de aspecto original. Si es necesario, recortará la imagen en la dimensión más grande. |
| `resize_and_pad` | `resize_and_pad: [100, 100]` | Redimensiona la imagen para que se ajuste a las dimensiones especificadas mientras se mantiene la relación de aspecto original. Si es necesario, rellenará el área restante con un color transparente si la imagen de origen tiene un canal alfa, de lo contrario, será negro. |
| `crop` | `crop: [20, 50, 300, 300]` | Extrae un área de una imagen. Los dos primeros argumentos son los bordes izquierdo y superior del área a extraer, mientras que los dos últimos argumentos son el ancho y la altura del área a extraer. |
| `rotate` | `rotate: 90` | Rota la imagen el ángulo especificado. |

[`image_processing`][] tiene más opciones disponibles (como `saver`, que permite configurar la compresión de la imagen) en su propia documentación para los procesadores [Vips](https://github.com/janko/image_processing/blob/master/doc/vips.md) y [MiniMagick](https://github.com/janko/image_processing/blob/master/doc/minimagick.md).



### Vista previa de archivos

Algunos archivos que no son imágenes se pueden previsualizar, es decir, se pueden presentar como imágenes. Por ejemplo, se puede previsualizar un archivo de video extrayendo su primer fotograma. De forma predeterminada, Active Storage admite la previsualización de videos y documentos PDF. Para crear un enlace a una vista previa generada de forma diferida, utiliza el método [`preview`][] del adjunto:

```erb
<%= image_tag message.video.preview(resize_to_limit: [100, 100]) %>
```

Para agregar soporte para otro formato, agrega tu propio generador de vistas previas. Consulta la documentación de [`ActiveStorage::Preview`][] para obtener más información.


Cargas directas
--------------

Active Storage, con su biblioteca JavaScript incluida, admite la carga directa desde el cliente a la nube.

### Uso

1. Incluye `activestorage.js` en el paquete de JavaScript de tu aplicación.

    Usando el pipeline de activos:

    ```js
    //= require activestorage
    ```

    Usando el paquete npm:

    ```js
    import * as ActiveStorage from "@rails/activestorage"
    ActiveStorage.start()
    ```

2. Agrega `direct_upload: true` a tu [campo de archivo](form_helpers.html#uploading-files):

    ```erb
    <%= form.file_field :attachments, multiple: true, direct_upload: true %>
    ```

    O, si no estás utilizando un `FormBuilder`, agrega el atributo de datos directamente:

    ```erb
    <input type="file" data-direct-upload-url="<%= rails_direct_uploads_url %>" />
    ```

3. Configura CORS en los servicios de almacenamiento de terceros para permitir solicitudes de carga directa.

4. ¡Eso es todo! Las cargas comienzan al enviar el formulario.

### Configuración de intercambio de recursos de origen cruzado (CORS)

Para que las cargas directas a un servicio de terceros funcionen, deberás configurar el servicio para permitir solicitudes de origen cruzado desde tu aplicación. Consulta la documentación de CORS de tu servicio:

* [S3](https://docs.aws.amazon.com/AmazonS3/latest/dev/cors.html#how-do-i-enable-cors)
* [Google Cloud Storage](https://cloud.google.com/storage/docs/configuring-cors)
* [Azure Storage](https://docs.microsoft.com/en-us/rest/api/storageservices/cross-origin-resource-sharing--cors--support-for-the-azure-storage-services)

Asegúrate de permitir:

* Todos los orígenes desde los cuales se accede a tu aplicación
* El método de solicitud `PUT`
* Los siguientes encabezados:
  * `Origin`
  * `Content-Type`
  * `Content-MD5`
  * `Content-Disposition` (excepto para Azure Storage)
  * `x-ms-blob-content-disposition` (solo para Azure Storage)
  * `x-ms-blob-type` (solo para Azure Storage)
  * `Cache-Control` (para GCS, solo si se establece `cache_control`)
No se requiere configuración CORS para el servicio de Disco ya que comparte el origen de tu aplicación.

#### Ejemplo: Configuración CORS de S3

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

#### Ejemplo: Configuración CORS de Google Cloud Storage

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

#### Ejemplo: Configuración CORS de Azure Storage

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

### Eventos de JavaScript de carga directa

| Nombre del evento | Objetivo del evento | Datos del evento (`event.detail`) | Descripción |
| --- | --- | --- | --- |
| `direct-uploads:start` | `<form>` | Ninguno | Se envió un formulario que contiene archivos para campos de carga directa. |
| `direct-upload:initialize` | `<input>` | `{id, file}` | Se envía para cada archivo después del envío del formulario. |
| `direct-upload:start` | `<input>` | `{id, file}` | Comienza una carga directa. |
| `direct-upload:before-blob-request` | `<input>` | `{id, file, xhr}` | Antes de hacer una solicitud a tu aplicación para obtener metadatos de carga directa. |
| `direct-upload:before-storage-request` | `<input>` | `{id, file, xhr}` | Antes de hacer una solicitud para almacenar un archivo. |
| `direct-upload:progress` | `<input>` | `{id, file, progress}` | A medida que avanzan las solicitudes para almacenar archivos. |
| `direct-upload:error` | `<input>` | `{id, file, error}` | Ocurrió un error. Se mostrará una `alerta` a menos que se cancele este evento. |
| `direct-upload:end` | `<input>` | `{id, file}` | Finaliza una carga directa. |
| `direct-uploads:end` | `<form>` | Ninguno | Todas las cargas directas han finalizado. |

### Ejemplo

Puedes usar estos eventos para mostrar el progreso de una carga.

![direct-uploads](https://user-images.githubusercontent.com/5355/28694528-16e69d0c-72f8-11e7-91a7-c0b8cfc90391.gif)

Para mostrar los archivos cargados en un formulario:

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

Agrega estilos:

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

### Soluciones personalizadas de arrastrar y soltar

Puedes usar la clase `DirectUpload` para este propósito. Al recibir un archivo de tu biblioteca
de elección, instancia un objeto DirectUpload y llama a su método create. Create toma
un callback para invocar cuando se complete la carga.

```js
import { DirectUpload } from "@rails/activestorage"

const input = document.querySelector('input[type=file]')

// Vincular a la caída de archivos - usar el ondrop en un elemento padre o usar una
// biblioteca como Dropzone
const onDrop = (event) => {
  event.preventDefault()
  const files = event.dataTransfer.files;
  Array.from(files).forEach(file => uploadFile(file))
}

// Vincular a la selección normal de archivos
input.addEventListener('change', (event) => {
  Array.from(input.files).forEach(file => uploadFile(file))
  // puedes borrar los archivos seleccionados del input
  input.value = null
})

const uploadFile = (file) => {
  // tu formulario necesita el campo de archivo con direct_upload: true, que
  // proporciona data-direct-upload-url
  const url = input.dataset.directUploadUrl
  const upload = new DirectUpload(file, url)

  upload.create((error, blob) => {
    if (error) {
      // Maneja el error
    } else {
      // Agrega un campo oculto con el nombre adecuado al formulario con un
      // valor de blob.signed_id para que los IDs de los blobs se transmitan
      // en el flujo de carga normal
      const hiddenField = document.createElement('input')
      hiddenField.setAttribute("type", "hidden");
      hiddenField.setAttribute("value", blob.signed_id);
      hiddenField.name = input.name
      document.querySelector('form').appendChild(hiddenField)
    }
  })
}
```

### Seguimiento del progreso de la carga del archivo

Cuando se utiliza el constructor `DirectUpload`, es posible incluir un tercer parámetro.
Esto permitirá que el objeto `DirectUpload` invoque el método `directUploadWillStoreFileWithXHR`
durante el proceso de carga.
Luego puedes adjuntar tu propio controlador de progreso al XHR según tus necesidades.
```js
import { DirectUpload } from "@rails/activestorage"

class Uploader {
  constructor(file, url) {
    this.upload = new DirectUpload(this.file, this.url, this)
  }

  upload(file) {
    this.upload.create((error, blob) => {
      if (error) {
        // Manejar el error
      } else {
        // Agregar un input oculto con el nombre apropiado al formulario
        // con un valor de blob.signed_id
      }
    })
  }

  directUploadWillStoreFileWithXHR(request) {
    request.upload.addEventListener("progress",
      event => this.directUploadDidProgress(event))
  }

  directUploadDidProgress(event) {
    // Usar event.loaded y event.total para actualizar la barra de progreso
  }
}
```

### Integración con bibliotecas o frameworks

Una vez que recibas un archivo de la biblioteca que hayas seleccionado, debes crear
una instancia de `DirectUpload` y utilizar su método "create" para iniciar el proceso de carga,
agregando cualquier encabezado adicional requerido según sea necesario. El método "create" también requiere
que se proporcione una función de devolución de llamada que se activará una vez que la carga haya finalizado.

```js
import { DirectUpload } from "@rails/activestorage"

class Uploader {
  constructor(file, url, token) {
    const headers = { 'Authentication': `Bearer ${token}` }
    // INFO: El envío de encabezados es un parámetro opcional. Si decides no enviar encabezados,
    //       la autenticación se realizará utilizando cookies o datos de sesión.
    this.upload = new DirectUpload(this.file, this.url, this, headers)
  }

  upload(file) {
    this.upload.create((error, blob) => {
      if (error) {
        // Manejar el error
      } else {
        // Usar blob.signed_id como referencia de archivo en la siguiente solicitud
      }
    })
  }

  directUploadWillStoreFileWithXHR(request) {
    request.upload.addEventListener("progress",
      event => this.directUploadDidProgress(event))
  }

  directUploadDidProgress(event) {
    // Usar event.loaded y event.total para actualizar la barra de progreso
  }
}
```

Para implementar la autenticación personalizada, se debe crear un nuevo controlador en
la aplicación de Rails, similar al siguiente:

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

NOTA: El uso de [Direct Uploads](#direct-uploads) a veces puede resultar en un archivo que se carga, pero que nunca se adjunta a un registro. Considera [eliminar las cargas no adjuntas](#purging-unattached-uploads).

Pruebas
-------------------------------------------

Utiliza [`fixture_file_upload`][] para probar la carga de un archivo en una prueba de integración o controlador.
Rails maneja los archivos como cualquier otro parámetro.

```ruby
class SignupController < ActionDispatch::IntegrationTest
  test "puede registrarse" do
    post signup_path, params: {
      name: "David",
      avatar: fixture_file_upload("david.png", "image/png")
    }

    user = User.order(:created_at).last
    assert user.avatar.attached?
  end
end
```


### Descartar archivos creados durante las pruebas

#### Pruebas de sistema

Las pruebas de sistema limpian los datos de prueba deshaciendo una transacción. Como nunca se llama a `destroy`
en un objeto, los archivos adjuntos nunca se limpian. Si deseas borrar los archivos, puedes hacerlo en un
callback `after_teardown`. Hacerlo aquí asegura que todas las conexiones creadas durante la prueba estén completas y
no recibirás un error de Active Storage diciendo que no puede encontrar un archivo.

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

Si estás utilizando [pruebas paralelas][] y el servicio `DiskService`, debes configurar cada proceso para que utilice su propia
carpeta para Active Storage. De esta manera, el callback `teardown` solo eliminará los archivos de las pruebas del proceso relevante.

```ruby
class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  # ...
  parallelize_setup do |i|
    ActiveStorage::Blob.service.root = "#{ActiveStorage::Blob.service.root}-#{i}"
  end
  # ...
end
```

Si tus pruebas de sistema verifican la eliminación de un modelo con archivos adjuntos y estás
utilizando Active Job, configura tu entorno de prueba para usar el adaptador de cola en línea para
que el trabajo de purga se ejecute inmediatamente en lugar de en un momento desconocido en el futuro.

```ruby
# Utiliza el procesamiento de trabajos en línea para que las cosas sucedan de inmediato
config.active_job.queue_adapter = :inline
```

[pruebas paralelas]: testing.html#pruebas-paralelas

#### Pruebas de integración

De manera similar a las pruebas de sistema, los archivos cargados durante las pruebas de integración no se
eliminan automáticamente. Si deseas borrar los archivos, puedes hacerlo en un callback `teardown`.

```ruby
class ActionDispatch::IntegrationTest
  def after_teardown
    super
    FileUtils.rm_rf(ActiveStorage::Blob.service.root)
  end
end
```

Si estás utilizando [pruebas paralelas][] y el servicio Disk, debes configurar cada proceso para que utilice su propia
carpeta para Active Storage. De esta manera, el callback `teardown` solo eliminará los archivos de las pruebas del proceso relevante.

```ruby
class ActionDispatch::IntegrationTest
  parallelize_setup do |i|
    ActiveStorage::Blob.service.root = "#{ActiveStorage::Blob.service.root}-#{i}"
  end
end
```

[pruebas paralelas]: testing.html#pruebas-paralelas

### Agregar archivos adjuntos a fixtures

Puedes agregar archivos adjuntos a tus [fixtures][] existentes. Primero, debes crear un servicio de almacenamiento separado:

```yml
# config/storage.yml

test_fixtures:
  service: Disk
  root: <%= Rails.root.join("tmp/storage_fixtures") %>
```

Esto le indica a Active Storage dónde "cargar" los archivos de las fixtures, por lo que debe ser un directorio temporal. Al hacerlo
un directorio diferente al servicio regular `test`, puedes separar los archivos de las fixtures de los archivos cargados durante una
prueba.
A continuación, crea archivos de fixture para las clases de Active Storage:

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

Luego, coloca un archivo en tu directorio de fixtures (la ruta predeterminada es `test/fixtures/files`) con el nombre de archivo correspondiente.
Consulta la documentación de [`ActiveStorage::FixtureSet`][] para obtener más información.

Una vez que todo esté configurado, podrás acceder a los adjuntos en tus pruebas:

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

#### Limpiando los fixtures

Si bien los archivos cargados en las pruebas se eliminan [al final de cada prueba](#discarding-files-created-during-tests),
solo necesitas limpiar los archivos de fixture una vez: cuando todas tus pruebas se completen.

Si estás utilizando pruebas paralelas, llama a `parallelize_teardown`:

```ruby
class ActiveSupport::TestCase
  # ...
  parallelize_teardown do |i|
    FileUtils.rm_rf(ActiveStorage::Blob.services.fetch(:test_fixtures).root)
  end
  # ...
end
```

Si no estás ejecutando pruebas paralelas, utiliza `Minitest.after_run` o el equivalente para tu framework de pruebas
(por ejemplo, `after(:suite)` para RSpec):

```ruby
# test_helper.rb

Minitest.after_run do
  FileUtils.rm_rf(ActiveStorage::Blob.services.fetch(:test_fixtures).root)
end
```


### Configurando servicios

Puedes agregar `config/storage/test.yml` para configurar los servicios que se utilizarán en el entorno de pruebas.
Esto es útil cuando se utiliza la opción `service`.

```ruby
class User < ApplicationRecord
  has_one_attached :avatar, service: :s3
end
```

Sin `config/storage/test.yml`, se utilizará el servicio `s3` configurado en `config/storage.yml`, incluso al ejecutar pruebas.

Se utilizará la configuración predeterminada y los archivos se cargarán en el proveedor de servicios configurado en `config/storage.yml`.

En este caso, puedes agregar `config/storage/test.yml` y utilizar el servicio Disk para el servicio `s3` para evitar enviar solicitudes.

```yaml
test:
  service: Disk
  root: <%= Rails.root.join("tmp/storage") %>

s3:
  service: Disk
  root: <%= Rails.root.join("tmp/storage") %>
```

Implementando soporte para otros servicios en la nube
-----------------------------------------------------

Si necesitas admitir un servicio en la nube que no sea estos, deberás
implementar el servicio. Cada servicio extiende
[`ActiveStorage::Service`](https://api.rubyonrails.org/classes/ActiveStorage/Service.html)
implementando los métodos necesarios para cargar y descargar archivos en la nube.

Eliminación de cargas no adjuntas
--------------------------------

Hay casos en los que se carga un archivo pero nunca se adjunta a un registro. Esto puede ocurrir al utilizar [Cargas directas](#direct-uploads). Puedes consultar los registros no adjuntos utilizando el [ámbito unattached](https://github.com/rails/rails/blob/8ef5bd9ced351162b673904a0b77c7034ca2bc20/activestorage/app/models/active_storage/blob.rb#L49). A continuación se muestra un ejemplo utilizando una [tarea personalizada de rake](command_line.html#custom-rake-tasks).

```ruby
namespace :active_storage do
  desc "Elimina los blobs de Active Storage no adjuntos. Ejecutar regularmente."
  task purge_unattached: :environment do
    ActiveStorage::Blob.unattached.where(created_at: ..2.days.ago).find_each(&:purge_later)
  end
end
```

ADVERTENCIA: La consulta generada por `ActiveStorage::Blob.unattached` puede ser lenta y potencialmente disruptiva en aplicaciones con bases de datos más grandes.
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
