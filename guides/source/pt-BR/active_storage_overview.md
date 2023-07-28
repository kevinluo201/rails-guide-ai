**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: b8e9de3d2aa934a8a6fc3e1dccb4824c
Visão geral do Active Storage
=======================

Este guia aborda como anexar arquivos aos seus modelos Active Record.

Após ler este guia, você saberá:

* Como anexar um ou vários arquivos a um registro.
* Como excluir um arquivo anexado.
* Como vincular a um arquivo anexado.
* Como usar variantes para transformar imagens.
* Como gerar uma representação de imagem de um arquivo não-imagem, como um PDF ou um vídeo.
* Como enviar uploads de arquivos diretamente dos navegadores para um serviço de armazenamento, evitando os servidores de aplicação.
* Como limpar arquivos armazenados durante os testes.
* Como implementar suporte para serviços de armazenamento adicionais.

--------------------------------------------------------------------------------

O que é o Active Storage?
-----------------------

O Active Storage facilita o upload de arquivos para um serviço de armazenamento em nuvem, como Amazon S3, Google Cloud Storage ou Microsoft Azure Storage, e a anexação desses arquivos a objetos Active Record. Ele vem com um serviço baseado em disco local para desenvolvimento e testes e suporta a replicação de arquivos para serviços subordinados para backups e migrações.

Usando o Active Storage, um aplicativo pode transformar uploads de imagens ou gerar representações de imagem de uploads não-imagem, como PDFs e vídeos, e extrair metadados de arquivos arbitrários.

### Requisitos

Vários recursos do Active Storage dependem de software de terceiros que o Rails não instalará e que deve ser instalado separadamente:

* [libvips](https://github.com/libvips/libvips) v8.6+ ou [ImageMagick](https://imagemagick.org/index.php) para análise e transformações de imagens
* [ffmpeg](http://ffmpeg.org/) v3.4+ para visualizações de vídeo e ffprobe para análise de vídeo/áudio
* [poppler](https://poppler.freedesktop.org/) ou [muPDF](https://mupdf.com/) para visualizações de PDF

A análise e transformações de imagens também requerem a gema `image_processing`. Descomente-a em seu `Gemfile` ou adicione-a, se necessário:

```ruby
gem "image_processing", ">= 1.2"
```

DICA: Comparado ao libvips, o ImageMagick é mais conhecido e mais amplamente disponível. No entanto, o libvips pode ser [até 10 vezes mais rápido e consumir 1/10 da memória](https://github.com/libvips/libvips/wiki/Speed-and-memory-use). Para arquivos JPEG, isso pode ser melhorado ainda mais substituindo `libjpeg-dev` por `libjpeg-turbo-dev`, que é [2-7 vezes mais rápido](https://libjpeg-turbo.org/About/Performance).

ATENÇÃO: Antes de instalar e usar software de terceiros, certifique-se de entender as implicações de licenciamento ao fazê-lo. O MuPDF, em particular, é licenciado sob AGPL e requer uma licença comercial para alguns usos.

## Configuração

```bash
$ bin/rails active_storage:install
$ bin/rails db:migrate
```

Isso configura a configuração e cria as três tabelas que o Active Storage usa:
`active_storage_blobs`, `active_storage_attachments` e `active_storage_variant_records`.

| Tabela      | Propósito |
| ------------------- | ----- |
| `active_storage_blobs` | Armazena dados sobre arquivos enviados, como nome do arquivo e tipo de conteúdo. |
| `active_storage_attachments` | Uma tabela de junção polimórfica que [conecta seus modelos a blobs](#anexando-arquivos-a-registros). Se o nome da classe do seu modelo mudar, você precisará executar uma migração nesta tabela para atualizar o `record_type` subjacente para o novo nome da classe do seu modelo. |
| `active_storage_variant_records` | Se o [rastreamento de variantes](#anexando-arquivos-a-registros) estiver habilitado, armazena registros para cada variante gerada. |

ATENÇÃO: Se você estiver usando UUIDs em vez de inteiros como chave primária em seus modelos, você deve definir `Rails.application.config.generators { |g| g.orm :active_record, primary_key_type: :uuid }` em um arquivo de configuração.

Declare os serviços do Active Storage em `config/storage.yml`. Para cada serviço que seu aplicativo usa, forneça um nome e a configuração necessária. O exemplo abaixo declara três serviços chamados `local`, `test` e `amazon`:

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
  region: "" # por exemplo, 'us-east-1'
```

Informe ao Active Storage qual serviço usar definindo `Rails.application.config.active_storage.service`. Como cada ambiente provavelmente usará um serviço diferente, é recomendado fazer isso em uma base por ambiente. Para usar o serviço de disco do exemplo anterior no ambiente de desenvolvimento, você adicionaria o seguinte a `config/environments/development.rb`:

```ruby
# Armazene arquivos localmente.
config.active_storage.service = :local
```

Para usar o serviço S3 em produção, você adiciona o seguinte a `config/environments/production.rb`:

```ruby
# Armazene arquivos na Amazon S3.
config.active_storage.service = :amazon
```

Para usar o serviço de teste durante os testes, você adiciona o seguinte a `config/environments/test.rb`:

```ruby
# Armazene arquivos enviados no sistema de arquivos local em um diretório temporário.
config.active_storage.service = :test
```

NOTA: Arquivos de configuração específicos para cada ambiente terão precedência: em produção, por exemplo, o arquivo `config/storage/production.yml` (se existir) terá precedência sobre o arquivo `config/storage.yml`.

É recomendado usar `Rails.env` nos nomes dos buckets para reduzir ainda mais o risco de destruir acidentalmente dados de produção.

```yaml
amazon:
  service: S3
  # ...
  bucket: seu_bucket_proprio-<%= Rails.env %>

google:
  service: GCS
  # ...
  bucket: seu_bucket_proprio-<%= Rails.env %>

azure:
  service: AzureStorage
  # ...
  container: seu_nome_de_container-<%= Rails.env %>
```
Continue lendo para obter mais informações sobre os adaptadores de serviço integrados (por exemplo, `Disk` e `S3`) e a configuração que eles exigem.

### Serviço de Disco

Declare um serviço de Disco em `config/storage.yml`:

```yaml
local:
  service: Disk
  root: <%= Rails.root.join("storage") %>
```

### Serviço S3 (Amazon S3 e APIs compatíveis com S3)

Para se conectar ao Amazon S3, declare um serviço S3 em `config/storage.yml`:

```yaml
amazon:
  service: S3
  access_key_id: ""
  secret_access_key: ""
  region: ""
  bucket: ""
```

Opcionalmente, forneça opções de cliente e upload:

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
    server_side_encryption: "" # 'aws:kms' ou 'AES256'
    cache_control: "private, max-age=<%= 1.day.to_i %>"
```

DICA: Defina tempos limite HTTP e limites de tentativas razoáveis para sua aplicação. Em certos cenários de falha, a configuração padrão do cliente AWS pode fazer com que as conexões sejam mantidas por vários minutos e levem ao enfileiramento de solicitações.

Adicione a gema [`aws-sdk-s3`](https://github.com/aws/aws-sdk-ruby) ao seu `Gemfile`:

```ruby
gem "aws-sdk-s3", require: false
```

NOTA: Os recursos principais do Active Storage exigem as seguintes permissões: `s3:ListBucket`, `s3:PutObject`, `s3:GetObject` e `s3:DeleteObject`. O [acesso público](#public-access) também requer `s3:PutObjectAcl`. Se você tiver outras opções de upload configuradas, como definir ACLs, poderá ser necessário fornecer permissões adicionais.

NOTA: Se você deseja usar variáveis de ambiente, arquivos de configuração padrão do SDK, perfis,
perfis de instância IAM ou funções de tarefa, você pode omitir as chaves `access_key_id`, `secret_access_key`
e `region` no exemplo acima. O serviço S3 suporta todas as opções de autenticação descritas na [documentação do SDK da AWS](https://docs.aws.amazon.com/sdk-for-ruby/v3/developer-guide/setup-config.html).

Para se conectar a uma API de armazenamento de objetos compatível com S3, como o DigitalOcean Spaces, forneça o `endpoint`:

```yaml
digitalocean:
  service: S3
  endpoint: https://nyc3.digitaloceanspaces.com
  access_key_id: ...
  secret_access_key: ...
  # ...e outras opções
```

Existem muitas outras opções disponíveis. Você pode verificá-las na documentação do [Cliente AWS S3](https://docs.aws.amazon.com/sdk-for-ruby/v3/api/Aws/S3/Client.html#initialize-instance_method).

### Serviço de Armazenamento Microsoft Azure

Declare um serviço de armazenamento Azure em `config/storage.yml`:

```yaml
azure:
  service: AzureStorage
  storage_account_name: ""
  storage_access_key: ""
  container: ""
```

Adicione a gema [`azure-storage-blob`](https://github.com/Azure/azure-storage-ruby) ao seu `Gemfile`:

```ruby
gem "azure-storage-blob", "~> 2.0", require: false
```

### Serviço de Armazenamento Google Cloud

Declare um serviço de armazenamento Google Cloud em `config/storage.yml`:

```yaml
google:
  service: GCS
  credentials: <%= Rails.root.join("path/to/keyfile.json") %>
  project: ""
  bucket: ""
```

Opcionalmente, forneça um Hash de credenciais em vez de um caminho de arquivo de chave:

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

Opcionalmente, forneça um metadado Cache-Control para definir nos ativos enviados:

```yaml
google:
  service: GCS
  ...
  cache_control: "public, max-age=3600"
```

Opcionalmente, use [IAM](https://cloud.google.com/storage/docs/access-control/signed-urls#signing-iam) em vez das `credentials` ao assinar URLs. Isso é útil se você estiver autenticando suas aplicações GKE com Identidade de Carga de Trabalho, consulte [este post no blog do Google Cloud](https://cloud.google.com/blog/products/containers-kubernetes/introducing-workload-identity-better-authentication-for-your-gke-applications) para obter mais informações.

```yaml
google:
  service: GCS
  ...
  iam: true
```

Opcionalmente, use um GSA específico ao assinar URLs. Ao usar o IAM, o [servidor de metadados](https://cloud.google.com/compute/docs/storing-retrieving-metadata) será contatado para obter o e-mail do GSA, mas esse servidor de metadados nem sempre está presente (por exemplo, testes locais) e você pode desejar usar um GSA não padrão.

```yaml
google:
  service: GCS
  ...
  iam: true
  gsa_email: "foobar@baz.iam.gserviceaccount.com"
```

Adicione a gema [`google-cloud-storage`](https://github.com/GoogleCloudPlatform/google-cloud-ruby/tree/master/google-cloud-storage) ao seu `Gemfile`:

```ruby
gem "google-cloud-storage", "~> 1.11", require: false
```

### Serviço de Espelhamento

Você pode manter vários serviços sincronizados definindo um serviço de espelhamento. Um serviço de espelhamento replica uploads e exclusões em dois ou mais serviços subordinados.

Um serviço de espelhamento destina-se a ser usado temporariamente durante uma migração entre
serviços em produção. Você pode começar a espelhar para um novo serviço, copiar
arquivos pré-existentes do serviço antigo para o novo e, em seguida, migrar completamente para o novo
serviço.

NOTA: O espelhamento não é atômico. É possível que um upload tenha sucesso no
serviço principal e falhe em qualquer um dos serviços subordinados. Antes de migrar
completamente para um novo serviço, verifique se todos os arquivos foram copiados.

Defina cada um dos serviços que você deseja espelhar conforme descrito acima. Faça referência
a eles pelo nome ao definir um serviço de espelhamento:

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

Embora todos os serviços secundários recebam uploads, os downloads são sempre tratados
pelo serviço principal.

Os serviços de espelhamento são compatíveis com uploads diretos. Novos arquivos são diretamente
enviados para o serviço principal. Quando um arquivo enviado diretamente é anexado a um
registro, um trabalho em segundo plano é enfileirado para copiá-lo para os serviços secundários.
### Acesso público

Por padrão, o Active Storage assume acesso privado aos serviços. Isso significa gerar URLs assinados e de uso único para os blobs. Se você preferir tornar os blobs publicamente acessíveis, especifique `public: true` no arquivo `config/storage.yml` do seu aplicativo:

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

Certifique-se de que seus buckets estejam configurados corretamente para acesso público. Consulte a documentação sobre como habilitar permissões de leitura pública para os serviços de armazenamento [Amazon S3](https://docs.aws.amazon.com/AmazonS3/latest/user-guide/block-public-access-bucket.html), [Google Cloud Storage](https://cloud.google.com/storage/docs/access-control/making-data-public#buckets) e [Microsoft Azure](https://docs.microsoft.com/en-us/azure/storage/blobs/storage-manage-access-to-resources#set-container-public-access-level-in-the-azure-portal). O Amazon S3 também requer que você tenha a permissão `s3:PutObjectAcl`.

Ao converter um aplicativo existente para usar `public: true`, certifique-se de atualizar cada arquivo individual no bucket para ser legível publicamente antes de fazer a troca.

Anexando arquivos aos registros
--------------------------

### `has_one_attached`

A macro [`has_one_attached`][] configura uma relação um-para-um entre registros e arquivos. Cada registro pode ter um arquivo anexado a ele.

Por exemplo, suponha que seu aplicativo tenha um modelo `User`. Se você quiser que cada usuário tenha um avatar, defina o modelo `User` da seguinte forma:

```ruby
class User < ApplicationRecord
  has_one_attached :avatar
end
```

ou se você estiver usando o Rails 6.0+, você pode executar um comando gerador de modelo assim:

```ruby
bin/rails generate model User avatar:attachment
```

Você pode criar um usuário com um avatar:

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

Chame [`avatar.attach`][Attached::One#attach] para anexar um avatar a um usuário existente:

```ruby
user.avatar.attach(params[:avatar])
```

Chame [`avatar.attached?`][Attached::One#attached?] para determinar se um determinado usuário tem um avatar:

```ruby
user.avatar.attached?
```

Em alguns casos, você pode querer substituir um serviço padrão para um anexo específico. Você pode configurar serviços específicos por anexo usando a opção `service`:

```ruby
class User < ApplicationRecord
  has_one_attached :avatar, service: :s3
end
```

Você pode configurar variantes específicas por anexo chamando o método `variant` no objeto attachable fornecido:

```ruby
class User < ApplicationRecord
  has_one_attached :avatar do |attachable|
    attachable.variant :thumb, resize_to_limit: [100, 100]
  end
end
```

Chame `avatar.variant(:thumb)` para obter uma variante de polegar de um avatar:

```erb
<%= image_tag user.avatar.variant(:thumb) %>
```

Você também pode usar variantes específicas para visualizações:

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

A macro [`has_many_attached`][] configura uma relação um-para-muitos entre registros e arquivos. Cada registro pode ter muitos arquivos anexados a ele.

Por exemplo, suponha que seu aplicativo tenha um modelo `Message`. Se você quiser que cada mensagem tenha muitas imagens, defina o modelo `Message` da seguinte forma:

```ruby
class Message < ApplicationRecord
  has_many_attached :images
end
```

ou se você estiver usando o Rails 6.0+, você pode executar um comando gerador de modelo assim:

```ruby
bin/rails generate model Message images:attachments
```

Você pode criar uma mensagem com imagens:

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

Chame [`images.attach`][Attached::Many#attach] para adicionar novas imagens a uma mensagem existente:

```ruby
@message.images.attach(params[:images])
```

Chame [`images.attached?`][Attached::Many#attached?] para determinar se uma determinada mensagem tem alguma imagem:

```ruby
@message.images.attached?
```

A substituição do serviço padrão é feita da mesma forma que `has_one_attached`, usando a opção `service`:

```ruby
class Message < ApplicationRecord
  has_many_attached :images, service: :s3
end
```

A configuração de variantes específicas é feita da mesma forma que `has_one_attached`, chamando o método `variant` no objeto attachable fornecido:

```ruby
class Message < ApplicationRecord
  has_many_attached :images do |attachable|
    attachable.variant :thumb, resize_to_limit: [100, 100]
  end
end
```



### Anexando objetos de arquivo/IO

Às vezes, você precisa anexar um arquivo que não chega por meio de uma solicitação HTTP. Por exemplo, você pode querer anexar um arquivo gerado no disco ou baixado de uma URL enviada pelo usuário. Você também pode querer anexar um arquivo de fixture em um teste de modelo. Para fazer isso, forneça um Hash contendo pelo menos um objeto IO aberto e um nome de arquivo:

```ruby
@message.images.attach(io: File.open('/path/to/file'), filename: 'file.pdf')
```

Quando possível, forneça também um tipo de conteúdo. O Active Storage tenta determinar o tipo de conteúdo de um arquivo a partir de seus dados. Ele usa o tipo de conteúdo fornecido se não conseguir determinar.
```ruby
@message.images.attach(io: File.open('/path/to/file'), filename: 'file.pdf', content_type: 'application/pdf')
```

Você pode ignorar a inferência do tipo de conteúdo dos dados passando
`identify: false` junto com o `content_type`.

```ruby
@message.images.attach(
  io: File.open('/path/to/file'),
  filename: 'file.pdf',
  content_type: 'application/pdf',
  identify: false
)
```

Se você não fornecer um tipo de conteúdo e o Active Storage não conseguir determinar
automaticamente o tipo de conteúdo do arquivo, ele será definido como application/octet-stream.


Removendo Arquivos
--------------

Para remover um anexo de um modelo, chame [`purge`][Attached::One#purge] no
anexo. Se sua aplicação estiver configurada para usar Active Job, a remoção pode ser feita
em segundo plano chamando [`purge_later`][Attached::One#purge_later].
A purgação exclui o blob e o arquivo do serviço de armazenamento.

```ruby
# Destrua sincronamente o avatar e os arquivos de recurso reais.
user.avatar.purge

# Destrua os modelos associados e os arquivos de recurso reais assincronamente, via Active Job.
user.avatar.purge_later
```


Servindo Arquivos
-------------

O Active Storage suporta duas maneiras de servir arquivos: redirecionamento e proxy.

AVISO: Todos os controladores do Active Storage são acessíveis publicamente por padrão. As
URLs geradas são difíceis de adivinhar, mas permanentes por design. Se seus arquivos
requerem um nível mais alto de proteção, considere implementar
[Controladores Autenticados](#authenticated-controllers).

### Modo de Redirecionamento

Para gerar uma URL permanente para um blob, você pode passar o blob para o
helper de visualização [`url_for`][ActionView::RoutingUrlFor#url_for]. Isso gera uma
URL com o [`signed_id`][ActiveStorage::Blob#signed_id] do blob
que é roteado para o [`RedirectController`][`ActiveStorage::Blobs::RedirectController`]
do blob.

```ruby
url_for(user.avatar)
# => /rails/active_storage/blobs/:signed_id/my-avatar.png
```

O `RedirectController` redireciona para o ponto de extremidade real do serviço. Isso
desacopla a URL do serviço da URL real e permite, por exemplo, espelhar anexos em diferentes serviços para alta disponibilidade. O
redirecionamento tem uma expiração HTTP de 5 minutos.

Para criar um link de download, use o helper `rails_blob_{path|url}`. Usando este
helper permite que você defina a disposição.

```ruby
rails_blob_path(user.avatar, disposition: "attachment")
```

AVISO: Para evitar ataques XSS, o Active Storage força o cabeçalho Content-Disposition
para "attachment" para alguns tipos de arquivos. Para alterar esse comportamento, consulte
as opções de configuração disponíveis em [Configurando Aplicações Rails](configuring.html#configuring-active-storage).

Se você precisa criar um link fora do contexto do controlador/visualização (Background
jobs, Cronjobs, etc.), você pode acessar o `rails_blob_path` assim:

```ruby
Rails.application.routes.url_helpers.rails_blob_path(user.avatar, only_path: true)
```


### Modo de Proxy

Opcionalmente, os arquivos podem ser servidos por proxy. Isso significa que seus servidores de aplicativos irão baixar os dados do arquivo do serviço de armazenamento em resposta às solicitações. Isso pode ser útil para servir arquivos de um CDN.

Você pode configurar o Active Storage para usar o proxy por padrão:

```ruby
# config/initializers/active_storage.rb
Rails.application.config.active_storage.resolve_model_to_route = :rails_storage_proxy
```

Ou se você quiser explicitamente usar o proxy para anexos específicos, existem helpers de URL que você pode usar na forma de `rails_storage_proxy_path` e `rails_storage_proxy_url`.

```erb
<%= image_tag rails_storage_proxy_path(@user.avatar) %>
```

#### Colocando um CDN na Frente do Active Storage

Além disso, para usar um CDN para anexos do Active Storage, você precisará gerar URLs com o modo de proxy para que sejam servidos pelo seu aplicativo e o CDN possa armazenar em cache o anexo sem nenhuma configuração extra. Isso funciona sem problemas porque o controlador de proxy padrão do Active Storage define um cabeçalho HTTP indicando ao CDN para armazenar em cache a resposta.

Você também deve garantir que as URLs geradas usem o host do CDN em vez do host do seu aplicativo. Existem várias maneiras de fazer isso, mas em geral envolve ajustar o arquivo `config/routes.rb` para que você possa gerar as URLs corretas para os anexos e suas variações. Como exemplo, você poderia adicionar isso:

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

e então gerar rotas assim:

```erb
<%= cdn_image_url(user.avatar.variant(resize_to_limit: [128, 128])) %>
```

### Controladores Autenticados

Todos os controladores do Active Storage são acessíveis publicamente por padrão. As
URLs geradas usam um [`signed_id`][ActiveStorage::Blob#signed_id] simples, tornando-as difíceis de
adivinhar, mas permanentes. Qualquer pessoa que conheça a URL do blob poderá acessá-la,
mesmo que um `before_action` em seu `ApplicationController` exija um login. Se seus arquivos requerem um nível mais alto de proteção, você pode
implementar seus próprios controladores autenticados, com base no
[`ActiveStorage::Blobs::RedirectController`][],
[`ActiveStorage::Blobs::ProxyController`][],
[`ActiveStorage::Representations::RedirectController`][] e
[`ActiveStorage::Representations::ProxyController`][]

Para permitir que apenas uma conta acesse seu próprio logotipo, você pode fazer o seguinte:
```ruby
# config/routes.rb
resource :account do
  resource :logo
end
```

```ruby
# app/controllers/logos_controller.rb
class LogosController < ApplicationController
  # Através de ApplicationController:
  # include Authenticate, SetCurrentAccount

  def show
    redirect_to Current.account.logo.url
  end
end
```

```erb
<%= image_tag account_logo_path %>
```

E então você deve desabilitar as rotas padrão do Active Storage com:

```ruby
config.active_storage.draw_routes = false
```

para evitar que os arquivos sejam acessados através de URLs publicamente acessíveis.


Download de Arquivos
-----------------

Às vezes, você precisa processar um blob após o upload, por exemplo, para convertê-lo
para um formato diferente. Use o método [`download`][Blob#download] do anexo para ler os dados binários de um blob na memória:

```ruby
binary = user.avatar.download
```

Você pode querer baixar um blob para um arquivo no disco para que um programa externo (por exemplo,
um scanner de vírus ou transcodificador de mídia) possa operar nele. Use o método
[`open`][Blob#open] do anexo para baixar um blob para um arquivo temporário no disco:

```ruby
message.video.open do |file|
  system '/path/to/virus/scanner', file.path
  # ...
end
```

É importante saber que o arquivo ainda não está disponível no callback `after_create`, mas apenas no `after_create_commit`.


Analisando Arquivos
---------------

O Active Storage analisa os arquivos assim que eles são carregados, enfileirando um job no Active Job. Os arquivos analisados armazenarão informações adicionais no hash de metadados, incluindo `analyzed: true`. Você pode verificar se um blob foi analisado chamando [`analyzed?`][] nele.

A análise de imagem fornece os atributos `width` e `height`. A análise de vídeo fornece esses atributos, além de `duration`, `angle`, `display_aspect_ratio` e booleanos `video` e `audio` para indicar a presença desses canais. A análise de áudio fornece os atributos `duration` e `bit_rate`.


Exibindo Imagens, Vídeos e PDFs
---------------

O Active Storage suporta a representação de uma variedade de arquivos. Você pode chamar
[`representation`][] em um anexo para exibir uma variante de imagem, ou uma
visualização de um vídeo ou PDF. Antes de chamar `representation`, verifique se o
anexo pode ser representado chamando [`representable?`]. Alguns formatos de arquivo
não podem ser visualizados pelo Active Storage por padrão (por exemplo, documentos do Word); se
`representable?` retornar false, você pode querer [linkar](#serving-files)
o arquivo em vez disso.

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

Internamente, `representation` chama `variant` para imagens e `preview` para
arquivos que podem ser visualizados. Você também pode chamar esses métodos diretamente.


### Carregamento Preguiçoso vs Imediato

Por padrão, o Active Storage processará as representações de forma preguiçosa. Este código:

```ruby
image_tag file.representation(resize_to_limit: [100, 100])
```

Irá gerar uma tag `<img>` com o `src` apontando para o
[`ActiveStorage::Representations::RedirectController`][]. O navegador irá
fazer uma solicitação para esse controlador, que irá realizar o seguinte:

1. Processar o arquivo e fazer o upload do arquivo processado, se necessário.
2. Retornar um redirecionamento `302` para o arquivo, seja para
  * o serviço remoto (por exemplo, S3).
  * ou `ActiveStorage::Blobs::ProxyController`, que retornará o conteúdo do arquivo se o [modo de proxy](#proxy-mode) estiver ativado.

O carregamento do arquivo de forma preguiçosa permite que recursos como [URLs de uso único](#public-access)
funcionem sem retardar o carregamento inicial da página.

Isso funciona bem para a maioria dos casos.

Se você deseja gerar URLs para imagens imediatamente, pode chamar `.processed.url`:

```ruby
image_tag file.representation(resize_to_limit: [100, 100]).processed.url
```

O rastreador de variantes do Active Storage melhora o desempenho disso, armazenando um
registro no banco de dados se a representação solicitada já tiver sido processada antes.
Assim, o código acima fará apenas uma chamada à API do serviço remoto (por exemplo, S3)
uma vez, e uma vez que uma variante é armazenada, ela será usada. O rastreador de variantes é executado
automaticamente, mas pode ser desabilitado através de [`config.active_storage.track_variants`][].

Se você estiver renderizando muitas imagens em uma página, o exemplo acima poderia resultar
em consultas N+1 carregando todos os registros de variantes. Para evitar essas consultas N+1,
use os escopos nomeados em [`ActiveStorage::Attachment`][].

```ruby
message.images.with_all_variant_records.each do |file|
  image_tag file.representation(resize_to_limit: [100, 100]).processed.url
end
```


### Transformando Imagens

A transformação de imagens permite exibir a imagem nas dimensões de sua escolha.
Para criar uma variação de uma imagem, chame [`variant`][] no anexo. Você
pode passar qualquer transformação suportada pelo processador de variantes para o método.
Quando o navegador acessa a URL da variante, o Active Storage transformará preguiçosamente
o blob original no formato especificado e redirecionará para sua nova localização de serviço.

```erb
<%= image_tag user.avatar.variant(resize_to_limit: [100, 100]) %>
```
Se uma variante for solicitada, o Active Storage aplicará automaticamente transformações dependendo do formato da imagem:

1. Tipos de conteúdo que são variáveis (conforme ditado por [`config.active_storage.variable_content_types`][]), e não são consideradas imagens da web (conforme ditado por [`config.active_storage.web_image_content_types`][]), serão convertidas para PNG.

2. Se `quality` não for especificado, a qualidade padrão do processador de variantes para o formato será usada.

O Active Storage pode usar o Vips ou o MiniMagick como processador de variantes. O padrão depende da versão de destino do `config.load_defaults`, e o processador pode ser alterado definindo [`config.active_storage.variant_processor`][].

Os dois processadores não são totalmente compatíveis, portanto, ao migrar um aplicativo existente entre o MiniMagick e o Vips, algumas alterações devem ser feitas se estiver usando opções específicas de formato:

```rhtml
<!-- MiniMagick -->
<%= image_tag user.avatar.variant(resize_to_limit: [100, 100], format: :jpeg, sampling_factor: "4:2:0", strip: true, interlace: "JPEG", colorspace: "sRGB", quality: 80) %>

<!-- Vips -->
<%= image_tag user.avatar.variant(resize_to_limit: [100, 100], format: :jpeg, saver: { subsample_mode: "on", strip: true, interlace: true, quality: 80 }) %>
```

Os parâmetros disponíveis são definidos pela gema [`image_processing`][] e dependem do processador de variantes que você está usando, mas ambos suportam os seguintes parâmetros:

| Parâmetro      | Exemplo | Descrição |
| ------------------- | ---------------- | ----- |
| `resize_to_limit` | `resize_to_limit: [100, 100]` | Redimensiona a imagem para caber nas dimensões especificadas, mantendo a proporção original. A imagem só será redimensionada se for maior que as dimensões especificadas. |
| `resize_to_fit` | `resize_to_fit: [100, 100]` | Redimensiona a imagem para caber nas dimensões especificadas, mantendo a proporção original. A imagem será reduzida se for maior que as dimensões especificadas ou aumentada se for menor. |
| `resize_to_fill` | `resize_to_fill: [100, 100]` | Redimensiona a imagem para preencher as dimensões especificadas, mantendo a proporção original. Se necessário, a imagem será cortada na dimensão maior. |
| `resize_and_pad` | `resize_and_pad: [100, 100]` | Redimensiona a imagem para caber nas dimensões especificadas, mantendo a proporção original. Se necessário, a área restante será preenchida com cor transparente se a imagem de origem tiver canal alfa, caso contrário, será preenchida com preto. |
| `crop` | `crop: [20, 50, 300, 300]` | Extrai uma área de uma imagem. Os dois primeiros argumentos são as bordas esquerda e superior da área a ser extraída, enquanto os dois últimos argumentos são a largura e a altura da área a ser extraída. |
| `rotate` | `rotate: 90` | Rotaciona a imagem pelo ângulo especificado. |

[`image_processing`][] tem mais opções disponíveis (como `saver`, que permite configurar a compressão da imagem) em sua própria documentação para os processadores [Vips](https://github.com/janko/image_processing/blob/master/doc/vips.md) e [MiniMagick](https://github.com/janko/image_processing/blob/master/doc/minimagick.md).



### Visualizando Arquivos

Alguns arquivos não-imagem podem ser visualizados: ou seja, podem ser apresentados como imagens.
Por exemplo, um arquivo de vídeo pode ser visualizado extraindo o primeiro quadro. Por padrão,
o Active Storage suporta visualização de vídeos e documentos PDF. Para criar um link para uma
visualização gerada preguiçosamente, use o método [`preview`][] do anexo:

```erb
<%= image_tag message.video.preview(resize_to_limit: [100, 100]) %>
```

Para adicionar suporte a outro formato, adicione seu próprio visualizador. Consulte a
documentação [`ActiveStorage::Preview`][] para obter mais informações.


Uploads Diretos
--------------

O Active Storage, com sua biblioteca JavaScript inclusa, suporta o envio direto do cliente para a nuvem.

### Uso

1. Inclua `activestorage.js` no pacote JavaScript da sua aplicação.

    Usando o pipeline de ativos:

    ```js
    //= require activestorage
    ```

    Usando o pacote npm:

    ```js
    import * as ActiveStorage from "@rails/activestorage"
    ActiveStorage.start()
    ```

2. Adicione `direct_upload: true` ao seu [campo de arquivo](form_helpers.html#uploading-files):

    ```erb
    <%= form.file_field :attachments, multiple: true, direct_upload: true %>
    ```

    Ou, se você não estiver usando um `FormBuilder`, adicione o atributo de dados diretamente:

    ```erb
    <input type="file" data-direct-upload-url="<%= rails_direct_uploads_url %>" />
    ```

3. Configure o CORS nos serviços de armazenamento de terceiros para permitir solicitações de upload direto.

4. Isso é tudo! Os uploads começam ao enviar o formulário.

### Configuração de Compartilhamento de Recursos de Origem Cruzada (CORS)

Para fazer uploads diretos para um serviço de terceiros funcionar, você precisará configurar o serviço para permitir solicitações de origem cruzada do seu aplicativo. Consulte a documentação de CORS do seu serviço:

* [S3](https://docs.aws.amazon.com/AmazonS3/latest/dev/cors.html#how-do-i-enable-cors)
* [Google Cloud Storage](https://cloud.google.com/storage/docs/configuring-cors)
* [Azure Storage](https://docs.microsoft.com/en-us/rest/api/storageservices/cross-origin-resource-sharing--cors--support-for-the-azure-storage-services)

Certifique-se de permitir:

* Todas as origens de onde seu aplicativo é acessado
* O método de solicitação `PUT`
* Os seguintes cabeçalhos:
  * `Origin`
  * `Content-Type`
  * `Content-MD5`
  * `Content-Disposition` (exceto para o Azure Storage)
  * `x-ms-blob-content-disposition` (apenas para o Azure Storage)
  * `x-ms-blob-type` (apenas para o Azure Storage)
  * `Cache-Control` (para GCS, somente se `cache_control` estiver definido)
Nenhuma configuração CORS é necessária para o serviço de disco, pois ele compartilha a origem do seu aplicativo.

#### Exemplo: Configuração CORS do S3

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

#### Exemplo: Configuração CORS do Google Cloud Storage

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

#### Exemplo: Configuração CORS do Azure Storage

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

### Eventos JavaScript de Upload Direto

| Nome do evento | Alvo do evento | Dados do evento (`event.detail`) | Descrição |
| --- | --- | --- | --- |
| `direct-uploads:start` | `<form>` | Nenhum | Um formulário contendo arquivos para campos de upload direto foi enviado. |
| `direct-upload:initialize` | `<input>` | `{id, file}` | Disparado para cada arquivo após o envio do formulário. |
| `direct-upload:start` | `<input>` | `{id, file}` | Um upload direto está começando. |
| `direct-upload:before-blob-request` | `<input>` | `{id, file, xhr}` | Antes de fazer uma solicitação para sua aplicação para metadados de upload direto. |
| `direct-upload:before-storage-request` | `<input>` | `{id, file, xhr}` | Antes de fazer uma solicitação para armazenar um arquivo. |
| `direct-upload:progress` | `<input>` | `{id, file, progress}` | Conforme as solicitações para armazenar arquivos progridem. |
| `direct-upload:error` | `<input>` | `{id, file, error}` | Ocorreu um erro. Um `alert` será exibido a menos que este evento seja cancelado. |
| `direct-upload:end` | `<input>` | `{id, file}` | Um upload direto foi concluído. |
| `direct-uploads:end` | `<form>` | Nenhum | Todos os uploads diretos foram concluídos. |

### Exemplo

Você pode usar esses eventos para mostrar o progresso de um upload.

![direct-uploads](https://user-images.githubusercontent.com/5355/28694528-16e69d0c-72f8-11e7-91a7-c0b8cfc90391.gif)

Para mostrar os arquivos enviados em um formulário:

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

Adicione estilos:

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

### Soluções personalizadas de arrastar e soltar

Você pode usar a classe `DirectUpload` para esse propósito. Ao receber um arquivo de sua biblioteca
de escolha, instancie um DirectUpload e chame seu método create. O create recebe
um retorno de chamada para invocar quando o upload for concluído.

```js
import { DirectUpload } from "@rails/activestorage"

const input = document.querySelector('input[type=file]')

// Vincule ao soltar do arquivo - use o ondrop em um elemento pai ou use uma
// biblioteca como o Dropzone
const onDrop = (event) => {
  event.preventDefault()
  const files = event.dataTransfer.files;
  Array.from(files).forEach(file => uploadFile(file))
}

// Vincule à seleção normal de arquivos
input.addEventListener('change', (event) => {
  Array.from(input.files).forEach(file => uploadFile(file))
  // você pode limpar os arquivos selecionados do input
  input.value = null
})

const uploadFile = (file) => {
  // seu formulário precisa do file_field direct_upload: true, que
  // fornece data-direct-upload-url
  const url = input.dataset.directUploadUrl
  const upload = new DirectUpload(file, url)

  upload.create((error, blob) => {
    if (error) {
      // Lide com o erro
    } else {
      // Adicione um campo oculto com o nome apropriado ao formulário com um
      // valor de blob.signed_id para que os ids de blob sejam
      // transmitidos no fluxo de upload normal
      const hiddenField = document.createElement('input')
      hiddenField.setAttribute("type", "hidden");
      hiddenField.setAttribute("value", blob.signed_id);
      hiddenField.name = input.name
      document.querySelector('form').appendChild(hiddenField)
    }
  })
}
```

### Acompanhe o progresso do upload do arquivo

Ao usar o construtor `DirectUpload`, é possível incluir um terceiro parâmetro.
Isso permitirá que o objeto `DirectUpload` invoque o método `directUploadWillStoreFileWithXHR`
durante o processo de upload.
Você pode então anexar seu próprio manipulador de progresso ao XHR para atender às suas necessidades.
```js
import { DirectUpload } from "@rails/activestorage"

class Uploader {
  constructor(file, url) {
    this.upload = new DirectUpload(this.file, this.url, this)
  }

  upload(file) {
    this.upload.create((error, blob) => {
      if (error) {
        // Tratar o erro
      } else {
        // Adicionar um input oculto com o nome apropriado ao formulário
        // com o valor de blob.signed_id
      }
    })
  }

  directUploadWillStoreFileWithXHR(request) {
    request.upload.addEventListener("progress",
      event => this.directUploadDidProgress(event))
  }

  directUploadDidProgress(event) {
    // Usar event.loaded e event.total para atualizar a barra de progresso
  }
}
```

### Integração com Bibliotecas ou Frameworks

Depois de receber um arquivo da biblioteca selecionada, você precisa criar
uma instância de `DirectUpload` e usar seu método "create" para iniciar o processo de upload,
adicionando quaisquer cabeçalhos adicionais necessários. O método "create" também requer
uma função de retorno de chamada que será acionada assim que o upload for concluído.

```js
import { DirectUpload } from "@rails/activestorage"

class Uploader {
  constructor(file, url, token) {
    const headers = { 'Authentication': `Bearer ${token}` }
    // INFO: Enviar cabeçalhos é um parâmetro opcional. Se você optar por não enviar cabeçalhos,
    //       a autenticação será feita usando cookies ou dados de sessão.
    this.upload = new DirectUpload(this.file, this.url, this, headers)
  }

  upload(file) {
    this.upload.create((error, blob) => {
      if (error) {
        // Tratar o erro
      } else {
        // Usar o blob.signed_id como referência de arquivo na próxima solicitação
      }
    })
  }

  directUploadWillStoreFileWithXHR(request) {
    request.upload.addEventListener("progress",
      event => this.directUploadDidProgress(event))
  }

  directUploadDidProgress(event) {
    // Usar event.loaded e event.total para atualizar a barra de progresso
  }
}
```

Para implementar autenticação personalizada, um novo controlador deve ser criado na
aplicação Rails, semelhante ao seguinte:

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

NOTA: O uso de [Uploads Diretos](#uploads-diretos) às vezes pode resultar em um arquivo que é carregado, mas nunca é anexado a um registro. Considere [limpar uploads não anexados](#limpar-uploads-não-anexados).

Testando
-------------------------------------------

Use [`fixture_file_upload`][] para testar o upload de um arquivo em um teste de integração ou controlador.
O Rails trata os arquivos como qualquer outro parâmetro.

```ruby
class SignupController < ActionDispatch::IntegrationTest
  test "pode se inscrever" do
    post signup_path, params: {
      name: "David",
      avatar: fixture_file_upload("david.png", "image/png")
    }

    user = User.order(:created_at).last
    assert user.avatar.attached?
  end
end
```


### Descartando Arquivos Criados Durante os Testes

#### Testes de Sistema

Os testes de sistema limpam os dados de teste revertendo uma transação. Como `destroy`
nunca é chamado em um objeto, os arquivos anexados nunca são limpos. Se você
deseja limpar os arquivos, você pode fazer isso em um callback `after_teardown`. Fazendo isso
aqui garante que todas as conexões criadas durante o teste estejam concluídas e
você não receberá um erro do Active Storage dizendo que não consegue encontrar um arquivo.

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

Se você estiver usando [testes paralelos][] e o `DiskService`, você deve configurar cada processo para usar sua própria
pasta para o Active Storage. Dessa forma, o callback `teardown` só excluirá arquivos dos testes do processo relevante.

```ruby
class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  # ...
  parallelize_setup do |i|
    ActiveStorage::Blob.service.root = "#{ActiveStorage::Blob.service.root}-#{i}"
  end
  # ...
end
```

Se seus testes de sistema verificarem a exclusão de um modelo com anexos e você estiver
usando Active Job, defina seu ambiente de teste para usar o adaptador de fila inline para
que o trabalho de purga seja executado imediatamente em vez de em um momento desconhecido no futuro.

```ruby
# Use o processamento de trabalhos inline para que as coisas aconteçam imediatamente
config.active_job.queue_adapter = :inline
```

[testes paralelos]: testing.html#testes-paralelos

#### Testes de Integração

Da mesma forma que os testes de sistema, os arquivos enviados durante os testes de integração não serão
limpos automaticamente. Se você deseja limpar os arquivos, pode fazer isso em um
callback `teardown`.

```ruby
class ActionDispatch::IntegrationTest
  def after_teardown
    super
    FileUtils.rm_rf(ActiveStorage::Blob.service.root)
  end
end
```

Se você estiver usando [testes paralelos][] e o serviço de Disco, você deve configurar cada processo para usar sua própria
pasta para o Active Storage. Dessa forma, o callback `teardown` só excluirá arquivos dos testes do processo relevante.

```ruby
class ActionDispatch::IntegrationTest
  parallelize_setup do |i|
    ActiveStorage::Blob.service.root = "#{ActiveStorage::Blob.service.root}-#{i}"
  end
end
```

[testes paralelos]: testing.html#testes-paralelos

### Adicionando Anexos às Fixtures

Você pode adicionar anexos às suas [fixtures][] existentes. Primeiro, você precisará criar um serviço de armazenamento separado:

```yml
# config/storage.yml

test_fixtures:
  service: Disk
  root: <%= Rails.root.join("tmp/storage_fixtures") %>
```

Isso informa ao Active Storage onde "carregar" os arquivos de fixture, portanto, deve ser um diretório temporário. Ao torná-lo
um diretório diferente do seu serviço regular `test`, você pode separar os arquivos de fixture dos arquivos carregados durante um
teste.
Em seguida, crie arquivos de fixture para as classes Active Storage:

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

Em seguida, coloque um arquivo no diretório de fixtures (o caminho padrão é `test/fixtures/files`) com o nome de arquivo correspondente.
Consulte a documentação [`ActiveStorage::FixtureSet`][] para obter mais informações.

Depois que tudo estiver configurado, você poderá acessar os anexos em seus testes:

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

#### Limpando as Fixtures

Embora os arquivos enviados nos testes sejam limpos [no final de cada teste](#discarding-files-created-during-tests),
você só precisa limpar os arquivos de fixture uma vez: quando todos os seus testes forem concluídos.

Se você estiver usando testes paralelos, chame `parallelize_teardown`:

```ruby
class ActiveSupport::TestCase
  # ...
  parallelize_teardown do |i|
    FileUtils.rm_rf(ActiveStorage::Blob.services.fetch(:test_fixtures).root)
  end
  # ...
end
```

Se você não estiver executando testes paralelos, use `Minitest.after_run` ou o equivalente para o seu framework de teste
(por exemplo, `after(:suite)` para o RSpec):

```ruby
# test_helper.rb

Minitest.after_run do
  FileUtils.rm_rf(ActiveStorage::Blob.services.fetch(:test_fixtures).root)
end
```


### Configurando serviços

Você pode adicionar `config/storage/test.yml` para configurar os serviços a serem usados no ambiente de teste.
Isso é útil quando a opção `service` é usada.

```ruby
class User < ApplicationRecord
  has_one_attached :avatar, service: :s3
end
```

Sem `config/storage/test.yml`, o serviço `s3` configurado em `config/storage.yml` é usado - mesmo ao executar testes.

A configuração padrão seria usada e os arquivos seriam enviados para o provedor de serviços configurado em `config/storage.yml`.

Nesse caso, você pode adicionar `config/storage/test.yml` e usar o serviço Disk para o serviço `s3` para evitar o envio de solicitações.

```yaml
test:
  service: Disk
  root: <%= Rails.root.join("tmp/storage") %>

s3:
  service: Disk
  root: <%= Rails.root.join("tmp/storage") %>
```

Implementando Suporte para Outros Serviços de Nuvem
--------------------------------------------------

Se você precisar oferecer suporte a um serviço de nuvem diferente desses, será necessário
implementar o Service. Cada serviço estende
[`ActiveStorage::Service`](https://api.rubyonrails.org/classes/ActiveStorage/Service.html)
implementando os métodos necessários para enviar e baixar arquivos para a nuvem.

Excluindo Uploads Não Anexados
------------------------------

Existem casos em que um arquivo é enviado, mas nunca é anexado a um registro. Isso pode acontecer ao usar [Uploads Diretos](#direct-uploads). Você pode consultar registros não anexados usando o escopo [unattached](https://github.com/rails/rails/blob/8ef5bd9ced351162b673904a0b77c7034ca2bc20/activestorage/app/models/active_storage/blob.rb#L49). Abaixo está um exemplo usando uma [tarefa rake personalizada](command_line.html#custom-rake-tasks).

```ruby
namespace :active_storage do
  desc "Purges unattached Active Storage blobs. Run regularly."
  task purge_unattached: :environment do
    ActiveStorage::Blob.unattached.where(created_at: ..2.days.ago).find_each(&:purge_later)
  end
end
```

AVISO: A consulta gerada por `ActiveStorage::Blob.unattached` pode ser lenta e potencialmente disruptiva em aplicativos com bancos de dados maiores.
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
