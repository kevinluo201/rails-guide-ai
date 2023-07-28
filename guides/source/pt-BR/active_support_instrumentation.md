**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: b093936da01fde14532f4cead51234e1
Instrumentação do Active Support
==============================

O Active Support é uma parte do Rails core que fornece extensões de linguagem Ruby, utilitários e outras coisas. Uma das coisas que ele inclui é uma API de instrumentação que pode ser usada dentro de um aplicativo para medir certas ações que ocorrem dentro do código Ruby, como aquelas dentro de um aplicativo Rails ou do próprio framework. No entanto, não se limita ao Rails. Ele pode ser usado independentemente em outros scripts Ruby, se desejado.

Neste guia, você aprenderá como usar a API de instrumentação do Active Support para medir eventos dentro do Rails e outros códigos Ruby.

Depois de ler este guia, você saberá:

* O que a instrumentação pode fornecer.
* Como adicionar um assinante a um gancho.
* Como visualizar temporizações da instrumentação em seu navegador.
* Os ganchos dentro do framework Rails para instrumentação.
* Como criar uma implementação personalizada de instrumentação.

--------------------------------------------------------------------------------

Introdução à Instrumentação
-------------------------------

A API de instrumentação fornecida pelo Active Support permite que os desenvolvedores forneçam ganchos aos quais outros desenvolvedores podem se conectar. Existem [vários desses](#rails-framework-hooks) dentro do framework Rails. Com esta API, os desenvolvedores podem optar por serem notificados quando certos eventos ocorrem dentro de seu aplicativo ou outro trecho de código Ruby.

Por exemplo, há [um gancho](#sql-active-record) fornecido dentro do Active Record que é chamado toda vez que o Active Record usa uma consulta SQL em um banco de dados. Este gancho pode ser **assinado** e usado para rastrear o número de consultas durante uma determinada ação. Há [outro gancho](#process-action-action-controller) em torno do processamento de uma ação de um controlador. Isso poderia ser usado, por exemplo, para rastrear quanto tempo uma ação específica levou.

Você também pode [criar seus próprios eventos](#creating-custom-events) dentro do seu aplicativo aos quais você pode se inscrever posteriormente.

Assinando um Evento
-----------------------

Assinar um evento é fácil. Use [`ActiveSupport::Notifications.subscribe`][] com um bloco para
ouvir qualquer notificação.

O bloco recebe os seguintes argumentos:

* Nome do evento
* Hora em que começou
* Hora em que terminou
* Um ID único para o instrumentador que disparou o evento
* O payload para o evento

```ruby
ActiveSupport::Notifications.subscribe "process_action.action_controller" do |name, started, finished, unique_id, data|
  # suas próprias coisas personalizadas
  Rails.logger.info "#{name} Recebido! (começou: #{started}, terminou: #{finished})" # process_action.action_controller Recebido (começou: 2019-05-05 13:43:57 -0800, terminou: 2019-05-05 13:43:58 -0800)
end
```

Se você estiver preocupado com a precisão de `started` e `finished` para calcular um tempo decorrido preciso, use [`ActiveSupport::Notifications.monotonic_subscribe`][]. O bloco fornecido receberá os mesmos argumentos acima, mas o `started` e `finished` terão valores com um tempo monótono preciso em vez do tempo de parede.

```ruby
ActiveSupport::Notifications.monotonic_subscribe "process_action.action_controller" do |name, started, finished, unique_id, data|
  # suas próprias coisas personalizadas
  Rails.logger.info "#{name} Recebido! (começou: #{started}, terminou: #{finished})" # process_action.action_controller Recebido (começou: 1560978.425334, terminou: 1560979.429234)
end
```

Definir todos esses argumentos de bloco toda vez pode ser tedioso. Você pode facilmente criar um [`ActiveSupport::Notifications::Event`][]
a partir dos argumentos do bloco assim:

```ruby
ActiveSupport::Notifications.subscribe "process_action.action_controller" do |*args|
  event = ActiveSupport::Notifications::Event.new(*args)

  event.name      # => "process_action.action_controller"
  event.duration  # => 10 (em milissegundos)
  event.payload   # => {:extra=>informação}

  Rails.logger.info "#{event} Recebido!"
end
```

Você também pode passar um bloco que aceite apenas um argumento, e ele receberá um objeto de evento:

```ruby
ActiveSupport::Notifications.subscribe "process_action.action_controller" do |event|
  event.name      # => "process_action.action_controller"
  event.duration  # => 10 (em milissegundos)
  event.payload   # => {:extra=>informação}

  Rails.logger.info "#{event} Recebido!"
end
```

Você também pode se inscrever em eventos que correspondam a uma expressão regular. Isso permite que você se inscreva em
múltiplos eventos de uma vez. Veja como se inscrever em tudo do `ActionController`:

```ruby
ActiveSupport::Notifications.subscribe(/action_controller/) do |*args|
  # inspecione todos os eventos do ActionController
end
```


Visualizar Temporizações da Instrumentação em Seu Navegador
-------------------------------------------------

O Rails implementa o padrão [Server Timing](https://www.w3.org/TR/server-timing/) para disponibilizar informações de temporização no navegador da web. Para habilitar, edite a configuração do ambiente (geralmente `development.rb`, pois é mais usado no desenvolvimento) para incluir o seguinte:

```ruby
  config.server_timing = true
```

Depois de configurado (incluindo reiniciar o servidor), você pode ir para o painel Ferramentas do Desenvolvedor do seu navegador, em seguida, selecione Rede e recarregue sua página. Em seguida, você pode selecionar qualquer solicitação para o seu servidor Rails e verá as temporizações do servidor na guia de temporizações. Para um exemplo de como fazer isso, consulte a [Documentação do Firefox](https://firefox-source-docs.mozilla.org/devtools-user/network_monitor/request_details/index.html#server-timing).

Ganchos do Framework Rails
---------------------

Dentro do framework Ruby on Rails, existem vários ganchos fornecidos para eventos comuns. Esses eventos e seus payloads são detalhados abaixo.
### Controlador de Ação

#### `start_processing.action_controller`

| Chave         | Valor                                                     |
| ------------- | --------------------------------------------------------- |
| `:controller` | O nome do controlador                                     |
| `:action`     | A ação                                                    |
| `:params`     | Hash dos parâmetros da solicitação sem nenhum parâmetro filtrado |
| `:headers`    | Cabeçalhos da solicitação                                 |
| `:format`     | html/js/json/xml etc                                      |
| `:method`     | Verbo de solicitação HTTP                                |
| `:path`       | Caminho da solicitação                                    |

```ruby
{
  controller: "PostsController",
  action: "new",
  params: { "action" => "new", "controller" => "posts" },
  headers: #<ActionDispatch::Http::Headers:0x0055a67a519b88>,
  format: :html,
  method: "GET",
  path: "/posts/new"
}
```

#### `process_action.action_controller`

| Chave             | Valor                                                     |
| --------------- | --------------------------------------------------------- |
| `:controller`   | O nome do controlador                                     |
| `:action`       | A ação                                                    |
| `:params`       | Hash dos parâmetros da solicitação sem nenhum parâmetro filtrado |
| `:headers`      | Cabeçalhos da solicitação                                 |
| `:format`       | html/js/json/xml etc                                      |
| `:method`       | Verbo de solicitação HTTP                                |
| `:path`         | Caminho da solicitação                                    |
| `:request`      | O objeto [`ActionDispatch::Request`][]                  |
| `:response`     | O objeto [`ActionDispatch::Response`][]                 |
| `:status`       | Código de status HTTP                                          |
| `:view_runtime` | Tempo gasto na visualização em ms                                |
| `:db_runtime`   | Tempo gasto executando consultas ao banco de dados em ms             |

```ruby
{
  controller: "PostsController",
  action: "index",
  params: {"action" => "index", "controller" => "posts"},
  headers: #<ActionDispatch::Http::Headers:0x0055a67a519b88>,
  format: :html,
  method: "GET",
  path: "/posts",
  request: #<ActionDispatch::Request:0x00007ff1cb9bd7b8>,
  response: #<ActionDispatch::Response:0x00007f8521841ec8>,
  status: 200,
  view_runtime: 46.848,
  db_runtime: 0.157
}
```

#### `send_file.action_controller`

| Chave     | Valor                     |
| ------- | ------------------------- |
| `:path` | Caminho completo para o arquivo |

Chaves adicionais podem ser adicionadas pelo chamador.

#### `send_data.action_controller`

`ActionController` não adiciona nenhuma informação específica à carga útil. Todas as opções são passadas para a carga útil.

#### `redirect_to.action_controller`

| Chave         | Valor                                    |
| ----------- | ---------------------------------------- |
| `:status`   | Código de resposta HTTP                       |
| `:location` | URL para redirecionar                       |
| `:request`  | O objeto [`ActionDispatch::Request`][] |

```ruby
{
  status: 302,
  location: "http://localhost:3000/posts/new",
  request: <ActionDispatch::Request:0x00007ff1cb9bd7b8>
}
```

#### `halted_callback.action_controller`

| Chave       | Valor                         |
| --------- | ----------------------------- |
| `:filter` | Filtro que interrompeu a ação |

```ruby
{
  filter: ":halting_filter"
}
```

#### `unpermitted_parameters.action_controller`

| Chave           | Valor                                                                         |
| ------------- | ----------------------------------------------------------------------------- |
| `:keys`       | As chaves não permitidas                                                          |
| `:context`    | Hash com as seguintes chaves: `:controller`, `:action`, `:params`, `:request` |

### Controlador de Ação — Cache

#### `write_fragment.action_controller`

| Chave    | Valor            |
| ------ | ---------------- |
| `:key` | A chave completa |

```ruby
{
  key: 'posts/1-dashboard-view'
}
```

#### `read_fragment.action_controller`

| Chave    | Valor            |
| ------ | ---------------- |
| `:key` | A chave completa |

```ruby
{
  key: 'posts/1-dashboard-view'
}
```

#### `expire_fragment.action_controller`

| Chave    | Valor            |
| ------ | ---------------- |
| `:key` | A chave completa |

```ruby
{
  key: 'posts/1-dashboard-view'
}
```

#### `exist_fragment?.action_controller`

| Chave    | Valor            |
| ------ | ---------------- |
| `:key` | A chave completa |

```ruby
{
  key: 'posts/1-dashboard-view'
}
```

### Despacho de Ação

#### `process_middleware.action_dispatch`

| Chave           | Valor                  |
| ------------- | ---------------------- |
| `:middleware` | Nome do middleware |

#### `redirect.action_dispatch`

| Chave         | Valor                                    |
| ----------- | ---------------------------------------- |
| `:status`   | Código de resposta HTTP                       |
| `:location` | URL para redirecionar                       |
| `:request`  | O objeto [`ActionDispatch::Request`][] |

#### `request.action_dispatch`

| Chave         | Valor                                    |
| ----------- | ---------------------------------------- |
| `:request`  | O objeto [`ActionDispatch::Request`][] |

### Visualização de Ação

#### `render_template.action_view`

| Chave           | Valor                              |
| ------------- | ---------------------------------- |
| `:identifier` | Caminho completo para o template              |
| `:layout`     | Layout aplicável                  |
| `:locals`     | Variáveis locais passadas para o template |

```ruby
{
  identifier: "/Users/adam/projects/notifications/app/views/posts/index.html.erb",
  layout: "layouts/application",
  locals: { foo: "bar" }
}
```

#### `render_partial.action_view`

| Chave           | Valor                              |
| ------------- | ---------------------------------- |
| `:identifier` | Caminho completo para o template              |
| `:locals`     | Variáveis locais passadas para o template |

```ruby
{
  identifier: "/Users/adam/projects/notifications/app/views/posts/_form.html.erb",
  locals: { foo: "bar" }
}
```

#### `render_collection.action_view`

| Chave           | Valor                                 |
| ------------- | ------------------------------------- |
| `:identifier` | Caminho completo para o template                 |
| `:count`      | Tamanho da coleção                    |
| `:cache_hits` | Número de parciais buscadas no cache |

A chave `:cache_hits` é incluída apenas se a coleção for renderizada com `cached: true`.
```ruby
{
  identifier: "/Users/adam/projects/notifications/app/views/posts/_post.html.erb",
  count: 3,
  cache_hits: 0
}
```

#### `render_layout.action_view`

| Chave         | Valor                     |
| ------------- | ------------------------- |
| `:identifier` | Caminho completo do modelo |


```ruby
{
  identifier: "/Users/adam/projects/notifications/app/views/layouts/application.html.erb"
}
```


### Active Record

#### `sql.active_record`

| Chave                | Valor                                    |
| -------------------- | ---------------------------------------- |
| `:sql`               | Declaração SQL                           |
| `:name`              | Nome da operação                         |
| `:connection`        | Objeto de conexão                        |
| `:binds`             | Parâmetros de ligação                    |
| `:type_casted_binds` | Parâmetros de ligação convertidos        |
| `:statement_name`    | Nome da declaração SQL                   |
| `:cached`            | `true` é adicionado quando consultas em cache são usadas |

Os adaptadores podem adicionar seus próprios dados também.

```ruby
{
  sql: "SELECT \"posts\".* FROM \"posts\" ",
  name: "Post Load",
  connection: <ActiveRecord::ConnectionAdapters::SQLite3Adapter:0x00007f9f7a838850>,
  binds: [<ActiveModel::Attribute::WithCastValue:0x00007fe19d15dc00>],
  type_casted_binds: [11],
  statement_name: nil
}
```

#### `strict_loading_violation.active_record`

Este evento é emitido apenas quando [`config.active_record.action_on_strict_loading_violation`][] está definido como `:log`.

| Chave         | Valor                                                            |
| ------------- | ---------------------------------------------------------------- |
| `:owner`      | Modelo com `strict_loading` habilitado                           |
| `:reflection` | Reflexão da associação que tentou carregar                       |


#### `instantiation.active_record`

| Chave              | Valor                                     |
| ------------------ | ----------------------------------------- |
| `:record_count`    | Número de registros instanciados          |
| `:class_name`      | Classe do registro                        |

```ruby
{
  record_count: 1,
  class_name: "User"
}
```

### Action Mailer

#### `deliver.action_mailer`

| Chave                 | Valor                                                     |
| --------------------- | --------------------------------------------------------- |
| `:mailer`             | Nome da classe do mailer                                  |
| `:message_id`         | ID da mensagem, gerado pelo gem Mail                      |
| `:subject`            | Assunto do email                                          |
| `:to`                 | Endereço(es) de destino do email                          |
| `:from`               | Endereço de origem do email                               |
| `:bcc`                | Endereços BCC do email                                    |
| `:cc`                 | Endereços CC do email                                     |
| `:date`               | Data do email                                             |
| `:mail`               | A forma codificada do email                               |
| `:perform_deliveries` | Se a entrega desta mensagem é realizada ou não             |

```ruby
{
  mailer: "Notification",
  message_id: "4f5b5491f1774_181b23fc3d4434d38138e5@mba.local.mail",
  subject: "Rails Guides",
  to: ["users@rails.com", "dhh@rails.com"],
  from: ["me@rails.com"],
  date: Sat, 10 Mar 2012 14:18:09 +0100,
  mail: "...", # omitido por brevidade
  perform_deliveries: true
}
```

#### `process.action_mailer`

| Chave         | Valor                          |
| ------------- | ------------------------------ |
| `:mailer`     | Nome da classe do mailer       |
| `:action`     | A ação                         |
| `:args`       | Os argumentos                  |

```ruby
{
  mailer: "Notification",
  action: "welcome_email",
  args: []
}
```

### Active Support — Caching

#### `cache_read.active_support`

| Chave                | Valor                          |
| -------------------- | ------------------------------ |
| `:key`               | Chave usada no armazenamento   |
| `:store`             | Nome da classe do armazenamento |
| `:hit`               | Se esta leitura é um acerto    |
| `:super_operation`   | `:fetch` se uma leitura é feita com [`fetch`][ActiveSupport::Cache::Store#fetch] |

#### `cache_read_multi.active_support`

| Chave                | Valor                          |
| -------------------- | ------------------------------ |
| `:key`               | Chaves usadas no armazenamento |
| `:store`             | Nome da classe do armazenamento |
| `:hits`              | Chaves dos acertos em cache    |
| `:super_operation`   | `:fetch_multi` se uma leitura é feita com [`fetch_multi`][ActiveSupport::Cache::Store#fetch_multi] |

#### `cache_generate.active_support`

Este evento é emitido apenas quando [`fetch`][ActiveSupport::Cache::Store#fetch] é chamado com um bloco.

| Chave      | Valor                          |
| ---------- | ------------------------------ |
| `:key`     | Chave usada no armazenamento   |
| `:store`   | Nome da classe do armazenamento |

As opções passadas para `fetch` serão mescladas com o payload ao escrever no armazenamento.

```ruby
{
  key: "nome-da-computacao-complicada",
  store: "ActiveSupport::Cache::MemCacheStore"
}
```

#### `cache_fetch_hit.active_support`

Este evento é emitido apenas quando [`fetch`][ActiveSupport::Cache::Store#fetch] é chamado com um bloco.

| Chave      | Valor                          |
| ---------- | ------------------------------ |
| `:key`     | Chave usada no armazenamento   |
| `:store`   | Nome da classe do armazenamento |

As opções passadas para `fetch` serão mescladas com o payload.

```ruby
{
  key: "nome-da-computacao-complicada",
  store: "ActiveSupport::Cache::MemCacheStore"
}
```

#### `cache_write.active_support`

| Chave      | Valor                          |
| ---------- | ------------------------------ |
| `:key`     | Chave usada no armazenamento   |
| `:store`   | Nome da classe do armazenamento |

Os armazenamentos de cache podem adicionar seus próprios dados também.

```ruby
{
  key: "nome-da-computacao-complicada",
  store: "ActiveSupport::Cache::MemCacheStore"
}
```

#### `cache_write_multi.active_support`

| Chave      | Valor                                       |
| ---------- | ------------------------------------------- |
| `:key`     | Chaves e valores escritos no armazenamento  |
| `:store`   | Nome da classe do armazenamento             |
#### `cache_increment.active_support`

Este evento é emitido apenas ao usar [`MemCacheStore`][ActiveSupport::Cache::MemCacheStore]
ou [`RedisCacheStore`][ActiveSupport::Cache::RedisCacheStore].

| Chave     | Valor                       |
| --------- | --------------------------- |
| `:key`    | Chave usada no armazenamento|
| `:store`  | Nome da classe de armazenamento |
| `:amount` | Quantidade a ser incrementada |

```ruby
{
  key: "garrafas-de-cerveja",
  store: "ActiveSupport::Cache::RedisCacheStore",
  amount: 99
}
```

#### `cache_decrement.active_support`

Este evento é emitido apenas ao usar os armazenamentos de cache Memcached ou Redis.

| Chave     | Valor                       |
| --------- | --------------------------- |
| `:key`    | Chave usada no armazenamento|
| `:store`  | Nome da classe de armazenamento |
| `:amount` | Quantidade a ser decrementada |

```ruby
{
  key: "garrafas-de-cerveja",
  store: "ActiveSupport::Cache::RedisCacheStore",
  amount: 1
}
```

#### `cache_delete.active_support`

| Chave    | Valor                       |
| -------- | --------------------------- |
| `:key`   | Chave usada no armazenamento|
| `:store` | Nome da classe de armazenamento |

```ruby
{
  key: "nome-do-calculo-complicado",
  store: "ActiveSupport::Cache::MemCacheStore"
}
```

#### `cache_delete_multi.active_support`

| Chave    | Valor                       |
| -------- | --------------------------- |
| `:key`   | Chaves usadas no armazenamento |
| `:store` | Nome da classe de armazenamento |

#### `cache_delete_matched.active_support`

Este evento é emitido apenas ao usar [`RedisCacheStore`][ActiveSupport::Cache::RedisCacheStore],
[`FileStore`][ActiveSupport::Cache::FileStore] ou [`MemoryStore`][ActiveSupport::Cache::MemoryStore].

| Chave    | Valor                       |
| -------- | --------------------------- |
| `:key`   | Padrão de chave usado        |
| `:store` | Nome da classe de armazenamento |

```ruby
{
  key: "posts/*",
  store: "ActiveSupport::Cache::RedisCacheStore"
}
```

#### `cache_cleanup.active_support`

Este evento é emitido apenas ao usar [`MemoryStore`][ActiveSupport::Cache::MemoryStore].

| Chave    | Valor                                         |
| -------- | --------------------------------------------- |
| `:store` | Nome da classe de armazenamento               |
| `:size`  | Número de entradas no cache antes da limpeza |

```ruby
{
  store: "ActiveSupport::Cache::MemoryStore",
  size: 9001
}
```

#### `cache_prune.active_support`

Este evento é emitido apenas ao usar [`MemoryStore`][ActiveSupport::Cache::MemoryStore].

| Chave    | Valor                                         |
| -------- | --------------------------------------------- |
| `:store` | Nome da classe de armazenamento               |
| `:key`   | Tamanho alvo (em bytes) para o cache          |
| `:from`  | Tamanho (em bytes) do cache antes da poda     |

```ruby
{
  store: "ActiveSupport::Cache::MemoryStore",
  key: 5000,
  from: 9001
}
```

#### `cache_exist?.active_support`

| Chave    | Valor                       |
| -------- | --------------------------- |
| `:key`   | Chave usada no armazenamento|
| `:store` | Nome da classe de armazenamento |

```ruby
{
  key: "nome-do-calculo-complicado",
  store: "ActiveSupport::Cache::MemCacheStore"
}
```


### Active Support — Mensagens

#### `message_serializer_fallback.active_support`

| Chave             | Valor                                 |
| ----------------- | ------------------------------------- |
| `:serializer`     | Serializador primário (pretendido)    |
| `:fallback`       | Serializador de fallback (real)       |
| `:serialized`     | String serializada                    |
| `:deserialized`   | Valor deserializado                   |

```ruby
{
  serializer: :json_allow_marshal,
  fallback: :marshal,
  serialized: "\x04\b{\x06I\"\nHello\x06:\x06ETI\"\nWorld\x06;\x00T",
  deserialized: { "Hello" => "World" },
}
```

### Active Job

#### `enqueue_at.active_job`

| Chave          | Valor                                        |
| -------------- | -------------------------------------------- |
| `:adapter`     | Objeto QueueAdapter processando o job        |
| `:job`         | Objeto Job                                  |

#### `enqueue.active_job`

| Chave          | Valor                                        |
| -------------- | -------------------------------------------- |
| `:adapter`     | Objeto QueueAdapter processando o job        |
| `:job`         | Objeto Job                                  |

#### `enqueue_retry.active_job`

| Chave          | Valor                                        |
| -------------- | -------------------------------------------- |
| `:job`         | Objeto Job                                  |
| `:adapter`     | Objeto QueueAdapter processando o job        |
| `:error`       | O erro que causou a repetição               |
| `:wait`        | O atraso da repetição                       |

#### `enqueue_all.active_job`

| Chave          | Valor                                        |
| -------------- | -------------------------------------------- |
| `:adapter`     | Objeto QueueAdapter processando o job        |
| `:jobs`        | Um array de objetos Job                      |

#### `perform_start.active_job`

| Chave          | Valor                                        |
| -------------- | -------------------------------------------- |
| `:adapter`     | Objeto QueueAdapter processando o job        |
| `:job`         | Objeto Job                                  |

#### `perform.active_job`

| Chave           | Valor                                                |
| --------------- | ---------------------------------------------------- |
| `:adapter`      | Objeto QueueAdapter processando o job                |
| `:job`          | Objeto Job                                          |
| `:db_runtime`   | Quantidade de tempo gasto executando consultas no banco em ms |

#### `retry_stopped.active_job`

| Chave          | Valor                                        |
| -------------- | -------------------------------------------- |
| `:adapter`     | Objeto QueueAdapter processando o job        |
| `:job`         | Objeto Job                                  |
| `:error`       | O erro que causou a repetição               |

#### `discard.active_job`

| Chave          | Valor                                        |
| -------------- | -------------------------------------------- |
| `:adapter`     | Objeto QueueAdapter processando o job        |
| `:job`         | Objeto Job                                  |
| `:error`       | O erro que causou o descarte                |
### Action Cable

#### `perform_action.action_cable`

| Chave            | Valor                     |
| ---------------- | ------------------------- |
| `:channel_class` | Nome da classe do canal    |
| `:action`        | A ação                    |
| `:data`          | Um hash de dados           |

#### `transmit.action_cable`

| Chave            | Valor                     |
| ---------------- | ------------------------- |
| `:channel_class` | Nome da classe do canal    |
| `:data`          | Um hash de dados           |
| `:via`           | Via                       |

#### `transmit_subscription_confirmation.action_cable`

| Chave            | Valor                     |
| ---------------- | ------------------------- |
| `:channel_class` | Nome da classe do canal    |

#### `transmit_subscription_rejection.action_cable`

| Chave            | Valor                     |
| ---------------- | ------------------------- |
| `:channel_class` | Nome da classe do canal    |

#### `broadcast.action_cable`

| Chave           | Valor                |
| --------------- | -------------------- |
| `:broadcasting` | Um broadcasting nomeado |
| `:message`      | Um hash de mensagem    |
| `:coder`        | O codificador         |

### Active Storage

#### `preview.active_storage`

| Chave         | Valor               |
| ------------- | ------------------- |
| `:key`        | Token seguro        |

#### `transform.active_storage`

#### `analyze.active_storage`

| Chave         | Valor                          |
| ------------- | ------------------------------ |
| `:analyzer`   | Nome do analisador, por exemplo, ffprobe |

### Active Storage — Storage Service

#### `service_upload.active_storage`

| Chave         | Valor                        |
| ------------- | ---------------------------- |
| `:key`        | Token seguro                 |
| `:service`    | Nome do serviço              |
| `:checksum`   | Checksum para garantir a integridade |

#### `service_streaming_download.active_storage`

| Chave         | Valor               |
| ------------- | ------------------- |
| `:key`        | Token seguro        |
| `:service`    | Nome do serviço     |

#### `service_download_chunk.active_storage`

| Chave         | Valor                           |
| ------------- | ------------------------------- |
| `:key`        | Token seguro                    |
| `:service`    | Nome do serviço                 |
| `:range`      | Faixa de bytes tentada de leitura |

#### `service_download.active_storage`

| Chave         | Valor               |
| ------------- | ------------------- |
| `:key`        | Token seguro        |
| `:service`    | Nome do serviço     |

#### `service_delete.active_storage`

| Chave         | Valor               |
| ------------- | ------------------- |
| `:key`        | Token seguro        |
| `:service`    | Nome do serviço     |

#### `service_delete_prefixed.active_storage`

| Chave         | Valor               |
| ------------- | ------------------- |
| `:prefix`     | Prefixo da chave    |
| `:service`    | Nome do serviço     |

#### `service_exist.active_storage`

| Chave         | Valor                       |
| ------------- | --------------------------- |
| `:key`        | Token seguro                |
| `:service`    | Nome do serviço             |
| `:exist`      | Arquivo ou blob existe ou não |

#### `service_url.active_storage`

| Chave         | Valor               |
| ------------- | ------------------- |
| `:key`        | Token seguro        |
| `:service`    | Nome do serviço     |
| `:url`        | URL gerada          |

#### `service_update_metadata.active_storage`

Este evento é emitido apenas ao usar o serviço Google Cloud Storage.

| Chave             | Valor                            |
| ----------------- | -------------------------------- |
| `:key`            | Token seguro                     |
| `:service`        | Nome do serviço                  |
| `:content_type`   | Campo HTTP `Content-Type`        |
| `:disposition`    | Campo HTTP `Content-Disposition` |

### Action Mailbox

#### `process.action_mailbox`

| Chave              | Valor                                                  |
| -------------------| ------------------------------------------------------ |
| `:mailbox`         | Instância da classe Mailbox herdando de [`ActionMailbox::Base`][] |
| `:inbound_email`   | Hash com dados sobre o email de entrada sendo processado |

```ruby
{
  mailbox: #<RepliesMailbox:0x00007f9f7a8388>,
  inbound_email: {
    id: 1,
    message_id: "0CB459E0-0336-41DA-BC88-E6E28C697DDB@37signals.com",
    status: "processing"
  }
}
```


### Railties

#### `load_config_initializer.railties`

| Chave            | Valor                                               |
| -------------- | --------------------------------------------------- |
| `:initializer` | Caminho do inicializador carregado em `config/initializers` |

### Rails

#### `deprecation.rails`

| Chave                    | Valor                                                 |
| ---------------------- | ------------------------------------------------------|
| `:message`             | O aviso de depreciação                               |
| `:callstack`           | De onde veio a depreciação                           |
| `:gem_name`            | Nome da gem relatando a depreciação                  |
| `:deprecation_horizon` | Versão em que o comportamento obsoleto será removido |

Exceções
----------

Se ocorrer uma exceção durante qualquer instrumentação, o payload incluirá
informações sobre ela.

| Chave                 | Valor                                                          |
| ------------------- | -------------------------------------------------------------- |
| `:exception`        | Um array de dois elementos. Nome da classe da exceção e a mensagem |
| `:exception_object` | O objeto de exceção                                           |

Criando Eventos Personalizados
----------------------

Adicionar seus próprios eventos também é fácil. O Active Support cuidará de
todo o trabalho pesado para você. Basta chamar [`ActiveSupport::Notifications.instrument`][] com um `nome`, `payload` e um bloco.
A notificação será enviada após o retorno do bloco. O Active Support gerará os tempos de início e término,
e adicionará o ID exclusivo do instrumentador. Todos os dados passados para a chamada `instrument` serão incluídos
no payload.
Aqui está um exemplo:

```ruby
ActiveSupport::Notifications.instrument "my.custom.event", this: :data do
  # faça suas personalizações aqui
end
```

Agora você pode ouvir esse evento com:

```ruby
ActiveSupport::Notifications.subscribe "my.custom.event" do |name, started, finished, unique_id, data|
  puts data.inspect # {:this=>:data}
end
```

Você também pode chamar `instrument` sem passar um bloco. Isso permite que você aproveite a infraestrutura de instrumentação para outros usos de mensagens.

```ruby
ActiveSupport::Notifications.instrument "my.custom.event", this: :data

ActiveSupport::Notifications.subscribe "my.custom.event" do |name, started, finished, unique_id, data|
  puts data.inspect # {:this=>:data}
end
```

Você deve seguir as convenções do Rails ao definir seus próprios eventos. O formato é: `evento.biblioteca`.
Se sua aplicação estiver enviando Tweets, você deve criar um evento chamado `tweet.twitter`.
[`ActiveSupport::Notifications::Event`]: https://api.rubyonrails.org/classes/ActiveSupport/Notifications/Event.html
[`ActiveSupport::Notifications.monotonic_subscribe`]: https://api.rubyonrails.org/classes/ActiveSupport/Notifications.html#method-c-monotonic_subscribe
[`ActiveSupport::Notifications.subscribe`]: https://api.rubyonrails.org/classes/ActiveSupport/Notifications.html#method-c-subscribe
[`ActionDispatch::Request`]: https://api.rubyonrails.org/classes/ActionDispatch/Request.html
[`ActionDispatch::Response`]: https://api.rubyonrails.org/classes/ActionDispatch/Response.html
[`config.active_record.action_on_strict_loading_violation`]: configuring.html#config-active-record-action-on-strict-loading-violation
[ActiveSupport::Cache::FileStore]: https://api.rubyonrails.org/classes/ActiveSupport/Cache/FileStore.html
[ActiveSupport::Cache::MemCacheStore]: https://api.rubyonrails.org/classes/ActiveSupport/Cache/MemCacheStore.html
[ActiveSupport::Cache::MemoryStore]: https://api.rubyonrails.org/classes/ActiveSupport/Cache/MemoryStore.html
[ActiveSupport::Cache::RedisCacheStore]: https://api.rubyonrails.org/classes/ActiveSupport/Cache/RedisCacheStore.html
[ActiveSupport::Cache::Store#fetch]: https://api.rubyonrails.org/classes/ActiveSupport/Cache/Store.html#method-i-fetch
[ActiveSupport::Cache::Store#fetch_multi]: https://api.rubyonrails.org/classes/ActiveSupport/Cache/Store.html#method-i-fetch_multi
[`ActionMailbox::Base`]: https://api.rubyonrails.org/classes/ActionMailbox/Base.html
[`ActiveSupport::Notifications.instrument`]: https://api.rubyonrails.org/classes/ActiveSupport/Notifications.html#method-c-instrument
