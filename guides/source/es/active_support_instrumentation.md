**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: b093936da01fde14532f4cead51234e1
Instrumentación de Active Support
==============================

Active Support es una parte fundamental de Rails que proporciona extensiones del lenguaje Ruby, utilidades y otras cosas. Una de las cosas que incluye es una API de instrumentación que se puede utilizar dentro de una aplicación para medir ciertas acciones que ocurren dentro del código Ruby, como las que se encuentran dentro de una aplicación Rails o el propio framework. Sin embargo, no se limita a Rails, ya que también se puede utilizar de forma independiente en otros scripts de Ruby si se desea.

En esta guía, aprenderás cómo utilizar la API de instrumentación de Active Support para medir eventos dentro de Rails y otros códigos Ruby.

Después de leer esta guía, sabrás:

* Lo que la instrumentación puede proporcionar.
* Cómo agregar un suscriptor a un gancho.
* Cómo ver los tiempos de la instrumentación en tu navegador.
* Los ganchos dentro del framework de Rails para la instrumentación.
* Cómo construir una implementación personalizada de instrumentación.

--------------------------------------------------------------------------------

Introducción a la instrumentación
-------------------------------

La API de instrumentación proporcionada por Active Support permite a los desarrolladores agregar ganchos a los que otros desarrolladores pueden conectarse. Hay [varios de estos](#ganchos-del-framework-de-rails) dentro del framework de Rails. Con esta API, los desarrolladores pueden elegir ser notificados cuando ocurren ciertos eventos dentro de su aplicación u otro código Ruby.

Por ejemplo, hay [un gancho](#sql-active-record) proporcionado dentro de Active Record que se llama cada vez que Active Record utiliza una consulta SQL en una base de datos. Este gancho podría ser **suscripto** y utilizado para realizar un seguimiento del número de consultas durante una determinada acción. Hay [otro gancho](#process-action-action-controller) relacionado con el procesamiento de una acción de un controlador. Esto podría ser utilizado, por ejemplo, para realizar un seguimiento de cuánto tiempo ha tardado una acción específica.

Incluso puedes [crear tus propios eventos](#creación-de-eventos-personalizados) dentro de tu aplicación a los que luego puedes suscribirte.

Suscribirse a un evento
-----------------------

Suscribirse a un evento es fácil. Utiliza [`ActiveSupport::Notifications.subscribe`][] con un bloque para escuchar cualquier notificación.

El bloque recibe los siguientes argumentos:

* Nombre del evento
* Hora de inicio
* Hora de finalización
* Un ID único para el instrumentador que disparó el evento
* Los datos para el evento

```ruby
ActiveSupport::Notifications.subscribe "process_action.action_controller" do |name, started, finished, unique_id, data|
  # tus propias acciones personalizadas
  Rails.logger.info "#{name} ¡Recibido! (inicio: #{started}, finalización: #{finished})" # process_action.action_controller Recibido (inicio: 2019-05-05 13:43:57 -0800, finalización: 2019-05-05 13:43:58 -0800)
end
```

Si te preocupa la precisión de `started` y `finished` para calcular un tiempo transcurrido preciso, entonces utiliza [`ActiveSupport::Notifications.monotonic_subscribe`][]. El bloque dado recibirá los mismos argumentos que se mencionaron anteriormente, pero `started` y `finished` tendrán valores con un tiempo monótono preciso en lugar de un tiempo de reloj de pared.

```ruby
ActiveSupport::Notifications.monotonic_subscribe "process_action.action_controller" do |name, started, finished, unique_id, data|
  # tus propias acciones personalizadas
  Rails.logger.info "#{name} ¡Recibido! (inicio: #{started}, finalización: #{finished})" # process_action.action_controller Recibido (inicio: 1560978.425334, finalización: 1560979.429234)
end
```

Definir todos esos argumentos de bloque cada vez puede ser tedioso. Puedes crear fácilmente un [`ActiveSupport::Notifications::Event`][]
a partir de los argumentos del bloque de esta manera:

```ruby
ActiveSupport::Notifications.subscribe "process_action.action_controller" do |*args|
  event = ActiveSupport::Notifications::Event.new(*args)

  event.name      # => "process_action.action_controller"
  event.duration  # => 10 (en milisegundos)
  event.payload   # => {:extra=>información}

  Rails.logger.info "#{event} ¡Recibido!"
end
```

También puedes pasar un bloque que acepte solo un argumento, y recibirá un objeto de evento:

```ruby
ActiveSupport::Notifications.subscribe "process_action.action_controller" do |event|
  event.name      # => "process_action.action_controller"
  event.duration  # => 10 (en milisegundos)
  event.payload   # => {:extra=>información}

  Rails.logger.info "#{event} ¡Recibido!"
end
```

También puedes suscribirte a eventos que coincidan con una expresión regular. Esto te permite suscribirte a
múltiples eventos a la vez. Así es como puedes suscribirte a todo lo relacionado con `ActionController`:

```ruby
ActiveSupport::Notifications.subscribe(/action_controller/) do |*args|
  # inspeccionar todos los eventos de ActionController
end
```


Ver los tiempos de la instrumentación en tu navegador
-----------------------------------------------------

Rails implementa el estándar [Server Timing](https://www.w3.org/TR/server-timing/) para hacer que la información de tiempo esté disponible en el navegador web. Para habilitarlo, edita la configuración de tu entorno (normalmente `development.rb`, ya que se utiliza principalmente en desarrollo) para incluir lo siguiente:

```ruby
  config.server_timing = true
```

Una vez configurado (incluido reiniciar tu servidor), puedes ir a la pestaña Herramientas para desarrolladores de tu navegador, luego seleccionar Red y recargar tu página. Luego puedes seleccionar cualquier solicitud a tu servidor de Rails y verás los tiempos del servidor en la pestaña de tiempos. Para ver un ejemplo de cómo hacer esto, consulta la [Documentación de Firefox](https://firefox-source-docs.mozilla.org/devtools-user/network_monitor/request_details/index.html#server-timing).

Ganchos del framework de Rails
---------------------

Dentro del framework Ruby on Rails, se proporcionan varios ganchos para eventos comunes. A continuación se detallan estos eventos y sus datos.
### Controlador de Acción

#### `start_processing.action_controller`

| Clave         | Valor                                                     |
| ------------- | --------------------------------------------------------- |
| `:controller` | El nombre del controlador                                  |
| `:action`     | La acción                                                 |
| `:params`     | Hash de los parámetros de la solicitud sin ningún parámetro filtrado |
| `:headers`    | Encabezados de la solicitud                               |
| `:format`     | html/js/json/xml etc                                      |
| `:method`     | Verbo de solicitud HTTP                                   |
| `:path`       | Ruta de la solicitud                                      |

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

| Clave             | Valor                                                     |
| --------------- | --------------------------------------------------------- |
| `:controller`   | El nombre del controlador                                  |
| `:action`       | La acción                                                 |
| `:params`       | Hash de los parámetros de la solicitud sin ningún parámetro filtrado |
| `:headers`      | Encabezados de la solicitud                               |
| `:format`       | html/js/json/xml etc                                      |
| `:method`       | Verbo de solicitud HTTP                                   |
| `:path`         | Ruta de la solicitud                                      |
| `:request`      | El objeto [`ActionDispatch::Request`][]                  |
| `:response`     | El objeto [`ActionDispatch::Response`][]                 |
| `:status`       | Código de estado HTTP                                     |
| `:view_runtime` | Tiempo transcurrido en la vista en ms                     |
| `:db_runtime`   | Tiempo transcurrido ejecutando consultas a la base de datos en ms |

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

| Clave     | Valor                     |
| ------- | ------------------------- |
| `:path` | Ruta completa al archivo |

El llamador puede agregar claves adicionales.

#### `send_data.action_controller`

`ActionController` no agrega ninguna información específica a la carga útil. Todas las opciones se pasan a la carga útil.

#### `redirect_to.action_controller`

| Clave         | Valor                                    |
| ----------- | ---------------------------------------- |
| `:status`   | Código de respuesta HTTP                  |
| `:location` | URL a la que redirigir                    |
| `:request`  | El objeto [`ActionDispatch::Request`][] |

```ruby
{
  status: 302,
  location: "http://localhost:3000/posts/new",
  request: <ActionDispatch::Request:0x00007ff1cb9bd7b8>
}
```

#### `halted_callback.action_controller`

| Clave       | Valor                         |
| --------- | ----------------------------- |
| `:filter` | Filtro que detuvo la acción |

```ruby
{
  filter: ":halting_filter"
}
```

#### `unpermitted_parameters.action_controller`

| Clave           | Valor                                                                         |
| ------------- | ----------------------------------------------------------------------------- |
| `:keys`       | Las claves no permitidas                                                          |
| `:context`    | Hash con las siguientes claves: `:controller`, `:action`, `:params`, `:request` |

### Controlador de Acción — Caché

#### `write_fragment.action_controller`

| Clave    | Valor            |
| ------ | ---------------- |
| `:key` | La clave completa |

```ruby
{
  key: 'posts/1-dashboard-view'
}
```

#### `read_fragment.action_controller`

| Clave    | Valor            |
| ------ | ---------------- |
| `:key` | La clave completa |

```ruby
{
  key: 'posts/1-dashboard-view'
}
```

#### `expire_fragment.action_controller`

| Clave    | Valor            |
| ------ | ---------------- |
| `:key` | La clave completa |

```ruby
{
  key: 'posts/1-dashboard-view'
}
```

#### `exist_fragment?.action_controller`

| Clave    | Valor            |
| ------ | ---------------- |
| `:key` | La clave completa |

```ruby
{
  key: 'posts/1-dashboard-view'
}
```

### Despacho de Acción

#### `process_middleware.action_dispatch`

| Clave           | Valor                  |
| ------------- | ---------------------- |
| `:middleware` | Nombre del middleware |

#### `redirect.action_dispatch`

| Clave         | Valor                                    |
| ----------- | ---------------------------------------- |
| `:status`   | Código de respuesta HTTP                  |
| `:location` | URL a la que redirigir                    |
| `:request`  | El objeto [`ActionDispatch::Request`][] |

#### `request.action_dispatch`

| Clave         | Valor                                    |
| ----------- | ---------------------------------------- |
| `:request`  | El objeto [`ActionDispatch::Request`][] |

### Vista de Acción

#### `render_template.action_view`

| Clave           | Valor                              |
| ------------- | ---------------------------------- |
| `:identifier` | Ruta completa de la plantilla      |
| `:layout`     | Diseño aplicable                   |
| `:locals`     | Variables locales pasadas a la plantilla |

```ruby
{
  identifier: "/Users/adam/projects/notifications/app/views/posts/index.html.erb",
  layout: "layouts/application",
  locals: { foo: "bar" }
}
```

#### `render_partial.action_view`

| Clave           | Valor                              |
| ------------- | ---------------------------------- |
| `:identifier` | Ruta completa de la plantilla      |
| `:locals`     | Variables locales pasadas a la plantilla |

```ruby
{
  identifier: "/Users/adam/projects/notifications/app/views/posts/_form.html.erb",
  locals: { foo: "bar" }
}
```

#### `render_collection.action_view`

| Clave           | Valor                                 |
| ------------- | ------------------------------------- |
| `:identifier` | Ruta completa de la plantilla         |
| `:count`      | Tamaño de la colección                |
| `:cache_hits` | Número de parciales obtenidos de la caché |

La clave `:cache_hits` solo se incluye si la colección se renderiza con `cached: true`.
```ruby
{
  identifier: "/Users/adam/projects/notifications/app/views/posts/_post.html.erb",
  count: 3,
  cache_hits: 0
}
```

#### `render_layout.action_view`

| Clave         | Valor                 |
| ------------- | --------------------- |
| `:identifier` | Ruta completa del template |


```ruby
{
  identifier: "/Users/adam/projects/notifications/app/views/layouts/application.html.erb"
}
```


### Active Record

#### `sql.active_record`

| Clave                  | Valor                                    |
| -------------------- | ---------------------------------------- |
| `:sql`               | Sentencia SQL                            |
| `:name`              | Nombre de la operación                    |
| `:connection`        | Objeto de conexión                        |
| `:binds`             | Parámetros de enlace                      |
| `:type_casted_binds` | Parámetros de enlace convertidos          |
| `:statement_name`    | Nombre de la sentencia SQL                |
| `:cached`            | Se agrega `true` cuando se utilizan consultas en caché |

Los adaptadores pueden agregar sus propios datos también.

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

Este evento solo se emite cuando [`config.active_record.action_on_strict_loading_violation`][] se establece en `:log`.

| Clave           | Valor                                            |
| ------------- | ------------------------------------------------ |
| `:owner`      | Modelo con `strict_loading` habilitado           |
| `:reflection` | Reflexión de la asociación que intentó cargar     |


#### `instantiation.active_record`

| Clave              | Valor                                     |
| ---------------- | ----------------------------------------- |
| `:record_count`  | Número de registros que se instanciaron   |
| `:class_name`    | Clase del registro                        |

```ruby
{
  record_count: 1,
  class_name: "User"
}
```

### Action Mailer

#### `deliver.action_mailer`

| Clave                   | Valor                                                |
| --------------------- | ---------------------------------------------------- |
| `:mailer`             | Nombre de la clase de correo                          |
| `:message_id`         | ID del mensaje, generado por la gema Mail             |
| `:subject`            | Asunto del correo                                    |
| `:to`                 | Dirección(es) de destino del correo                   |
| `:from`               | Dirección de origen del correo                        |
| `:bcc`                | Direcciones BCC del correo                            |
| `:cc`                 | Direcciones CC del correo                             |
| `:date`               | Fecha del correo                                     |
| `:mail`               | La forma codificada del correo                        |
| `:perform_deliveries` | Si se realiza o no la entrega de este mensaje         |

```ruby
{
  mailer: "Notification",
  message_id: "4f5b5491f1774_181b23fc3d4434d38138e5@mba.local.mail",
  subject: "Rails Guides",
  to: ["users@rails.com", "dhh@rails.com"],
  from: ["me@rails.com"],
  date: Sat, 10 Mar 2012 14:18:09 +0100,
  mail: "...", # omitido por brevedad
  perform_deliveries: true
}
```

#### `process.action_mailer`

| Clave           | Valor                    |
| ------------- | ------------------------ |
| `:mailer`     | Nombre de la clase de correo |
| `:action`     | La acción                |
| `:args`       | Los argumentos            |

```ruby
{
  mailer: "Notification",
  action: "welcome_email",
  args: []
}
```

### Active Support — Caching

#### `cache_read.active_support`

| Clave                | Valor                   |
| ------------------ | ----------------------- |
| `:key`             | Clave utilizada en el almacenamiento   |
| `:store`           | Nombre de la clase de almacenamiento |
| `:hit`             | Si esta lectura es un acierto   |
| `:super_operation` | `:fetch` si se realiza una lectura con [`fetch`][ActiveSupport::Cache::Store#fetch] |

#### `cache_read_multi.active_support`

| Clave                | Valor                   |
| ------------------ | ----------------------- |
| `:key`             | Claves utilizadas en el almacenamiento  |
| `:store`           | Nombre de la clase de almacenamiento |
| `:hits`            | Claves de aciertos en caché      |
| `:super_operation` | `:fetch_multi` si se realiza una lectura con [`fetch_multi`][ActiveSupport::Cache::Store#fetch_multi] |

#### `cache_generate.active_support`

Este evento solo se emite cuando se llama a [`fetch`][ActiveSupport::Cache::Store#fetch] con un bloque.

| Clave      | Valor                   |
| -------- | ----------------------- |
| `:key`   | Clave utilizada en el almacenamiento   |
| `:store` | Nombre de la clase de almacenamiento |

Las opciones pasadas a `fetch` se fusionarán con la carga útil al escribir en el almacenamiento.

```ruby
{
  key: "nombre-de-la-computación-complicada",
  store: "ActiveSupport::Cache::MemCacheStore"
}
```

#### `cache_fetch_hit.active_support`

Este evento solo se emite cuando se llama a [`fetch`][ActiveSupport::Cache::Store#fetch] con un bloque.

| Clave      | Valor                   |
| -------- | ----------------------- |
| `:key`   | Clave utilizada en el almacenamiento   |
| `:store` | Nombre de la clase de almacenamiento |

Las opciones pasadas a `fetch` se fusionarán con la carga útil.

```ruby
{
  key: "nombre-de-la-computación-complicada",
  store: "ActiveSupport::Cache::MemCacheStore"
}
```

#### `cache_write.active_support`

| Clave      | Valor                   |
| -------- | ----------------------- |
| `:key`   | Clave utilizada en el almacenamiento   |
| `:store` | Nombre de la clase de almacenamiento |

Los almacenes de caché pueden agregar sus propios datos también.

```ruby
{
  key: "nombre-de-la-computación-complicada",
  store: "ActiveSupport::Cache::MemCacheStore"
}
```

#### `cache_write_multi.active_support`

| Clave      | Valor                                |
| -------- | ------------------------------------ |
| `:key`   | Claves y valores escritos en el almacenamiento |
| `:store` | Nombre de la clase de almacenamiento              |
#### `cache_increment.active_support`

Este evento solo se emite cuando se utiliza [`MemCacheStore`][ActiveSupport::Cache::MemCacheStore]
o [`RedisCacheStore`][ActiveSupport::Cache::RedisCacheStore].

| Clave     | Valor                   |
| --------- | ----------------------- |
| `:key`    | Clave utilizada en el almacenamiento   |
| `:store`  | Nombre de la clase de almacenamiento   |
| `:amount` | Cantidad a incrementar   |

```ruby
{
  key: "botellas-de-cerveza",
  store: "ActiveSupport::Cache::RedisCacheStore",
  amount: 99
}
```

#### `cache_decrement.active_support`

Este evento solo se emite cuando se utiliza los almacenes de caché Memcached o Redis.

| Clave     | Valor                   |
| --------- | ----------------------- |
| `:key`    | Clave utilizada en el almacenamiento   |
| `:store`  | Nombre de la clase de almacenamiento   |
| `:amount` | Cantidad a decrementar   |

```ruby
{
  key: "botellas-de-cerveza",
  store: "ActiveSupport::Cache::RedisCacheStore",
  amount: 1
}
```

#### `cache_delete.active_support`

| Clave     | Valor                   |
| --------- | ----------------------- |
| `:key`    | Clave utilizada en el almacenamiento   |
| `:store`  | Nombre de la clase de almacenamiento   |

```ruby
{
  key: "nombre-de-computacion-complicada",
  store: "ActiveSupport::Cache::MemCacheStore"
}
```

#### `cache_delete_multi.active_support`

| Clave     | Valor                   |
| --------- | ----------------------- |
| `:key`    | Claves utilizadas en el almacenamiento   |
| `:store`  | Nombre de la clase de almacenamiento   |

#### `cache_delete_matched.active_support`

Este evento solo se emite cuando se utiliza [`RedisCacheStore`][ActiveSupport::Cache::RedisCacheStore],
[`FileStore`][ActiveSupport::Cache::FileStore] o [`MemoryStore`][ActiveSupport::Cache::MemoryStore].

| Clave     | Valor                   |
| --------- | ----------------------- |
| `:key`    | Patrón de clave utilizado   |
| `:store`  | Nombre de la clase de almacenamiento   |

```ruby
{
  key: "posts/*",
  store: "ActiveSupport::Cache::RedisCacheStore"
}
```

#### `cache_cleanup.active_support`

Este evento solo se emite cuando se utiliza [`MemoryStore`][ActiveSupport::Cache::MemoryStore].

| Clave     | Valor                                         |
| --------- | --------------------------------------------- |
| `:store`  | Nombre de la clase de almacenamiento           |
| `:size`   | Número de entradas en la caché antes de la limpieza |

```ruby
{
  store: "ActiveSupport::Cache::MemoryStore",
  size: 9001
}
```

#### `cache_prune.active_support`

Este evento solo se emite cuando se utiliza [`MemoryStore`][ActiveSupport::Cache::MemoryStore].

| Clave     | Valor                                         |
| --------- | --------------------------------------------- |
| `:store`  | Nombre de la clase de almacenamiento           |
| `:key`    | Tamaño objetivo (en bytes) para la caché       |
| `:from`   | Tamaño (en bytes) de la caché antes de la poda  |

```ruby
{
  store: "ActiveSupport::Cache::MemoryStore",
  key: 5000,
  from: 9001
}
```

#### `cache_exist?.active_support`

| Clave     | Valor                   |
| --------- | ----------------------- |
| `:key`    | Clave utilizada en el almacenamiento   |
| `:store`  | Nombre de la clase de almacenamiento   |

```ruby
{
  key: "nombre-de-computacion-complicada",
  store: "ActiveSupport::Cache::MemCacheStore"
}
```


### Active Support — Mensajes

#### `message_serializer_fallback.active_support`

| Clave             | Valor                         |
| --------------- | ----------------------------- |
| `:serializer`   | Serializador primario (previsto) |
| `:fallback`     | Serializador secundario (real)  |
| `:serialized`   | Cadena serializada             |
| `:deserialized` | Valor deserializado            |

```ruby
{
  serializer: :json_allow_marshal,
  fallback: :marshal,
  serialized: "\x04\b{\x06I\"\nHola\x06:\x06ETI\"\nMundo\x06;\x00T",
  deserialized: { "Hola" => "Mundo" },
}
```

### Active Job

#### `enqueue_at.active_job`

| Clave          | Valor                                  |
| ------------ | -------------------------------------- |
| `:adapter`   | Objeto QueueAdapter que procesa el trabajo |
| `:job`       | Objeto de trabajo                             |

#### `enqueue.active_job`

| Clave          | Valor                                  |
| ------------ | -------------------------------------- |
| `:adapter`   | Objeto QueueAdapter que procesa el trabajo |
| `:job`       | Objeto de trabajo                             |

#### `enqueue_retry.active_job`

| Clave          | Valor                                  |
| ------------ | -------------------------------------- |
| `:job`       | Objeto de trabajo                             |
| `:adapter`   | Objeto QueueAdapter que procesa el trabajo |
| `:error`     | El error que causó el reintento        |
| `:wait`      | El retraso del reintento                 |

#### `enqueue_all.active_job`

| Clave          | Valor                                  |
| ------------ | -------------------------------------- |
| `:adapter`   | Objeto QueueAdapter que procesa el trabajo |
| `:jobs`      | Un array de objetos de trabajo                |

#### `perform_start.active_job`

| Clave          | Valor                                  |
| ------------ | -------------------------------------- |
| `:adapter`   | Objeto QueueAdapter que procesa el trabajo |
| `:job`       | Objeto de trabajo                             |

#### `perform.active_job`

| Clave           | Valor                                         |
| ------------- | --------------------------------------------- |
| `:adapter`    | Objeto QueueAdapter que procesa el trabajo        |
| `:job`        | Objeto de trabajo                                    |
| `:db_runtime` | Cantidad de tiempo gastado ejecutando consultas a la base de datos en ms |

#### `retry_stopped.active_job`

| Clave          | Valor                                  |
| ------------ | -------------------------------------- |
| `:adapter`   | Objeto QueueAdapter que procesa el trabajo |
| `:job`       | Objeto de trabajo                             |
| `:error`     | El error que causó el reintento        |

#### `discard.active_job`

| Clave          | Valor                                  |
| ------------ | -------------------------------------- |
| `:adapter`   | Objeto QueueAdapter que procesa el trabajo |
| `:job`       | Objeto de trabajo                             |
| `:error`     | El error que causó el descarte      |
### Action Cable

#### `perform_action.action_cable`

| Clave            | Valor                     |
| ---------------- | ------------------------- |
| `:channel_class` | Nombre de la clase del canal |
| `:action`        | La acción                |
| `:data`          | Un hash de datos            |

#### `transmit.action_cable`

| Clave            | Valor                     |
| ---------------- | ------------------------- |
| `:channel_class` | Nombre de la clase del canal |
| `:data`          | Un hash de datos            |
| `:via`           | Via                       |

#### `transmit_subscription_confirmation.action_cable`

| Clave            | Valor                     |
| ---------------- | ------------------------- |
| `:channel_class` | Nombre de la clase del canal |

#### `transmit_subscription_rejection.action_cable`

| Clave            | Valor                     |
| ---------------- | ------------------------- |
| `:channel_class` | Nombre de la clase del canal |

#### `broadcast.action_cable`

| Clave             | Valor                |
| --------------- | -------------------- |
| `:broadcasting` | Una transmisión nombrada |
| `:message`      | Un hash de mensaje    |
| `:coder`        | El codificador            |

### Active Storage

#### `preview.active_storage`

| Clave          | Valor               |
| ------------ | ------------------- |
| `:key`       | Token seguro        |

#### `transform.active_storage`

#### `analyze.active_storage`

| Clave          | Valor                          |
| ------------ | ------------------------------ |
| `:analyzer`  | Nombre del analizador, por ejemplo, ffprobe |

### Active Storage — Storage Service

#### `service_upload.active_storage`

| Clave          | Valor                        |
| ------------ | ---------------------------- |
| `:key`       | Token seguro                 |
| `:service`   | Nombre del servicio          |
| `:checksum`  | Suma de comprobación para garantizar la integridad |

#### `service_streaming_download.active_storage`

| Clave          | Valor               |
| ------------ | ------------------- |
| `:key`       | Token seguro        |
| `:service`   | Nombre del servicio |

#### `service_download_chunk.active_storage`

| Clave          | Valor                           |
| ------------ | ------------------------------- |
| `:key`       | Token seguro                    |
| `:service`   | Nombre del servicio             |
| `:range`     | Rango de bytes que se intentó leer |

#### `service_download.active_storage`

| Clave          | Valor               |
| ------------ | ------------------- |
| `:key`       | Token seguro        |
| `:service`   | Nombre del servicio |

#### `service_delete.active_storage`

| Clave          | Valor               |
| ------------ | ------------------- |
| `:key`       | Token seguro        |
| `:service`   | Nombre del servicio |

#### `service_delete_prefixed.active_storage`

| Clave          | Valor               |
| ------------ | ------------------- |
| `:prefix`    | Prefijo de clave          |
| `:service`   | Nombre del servicio |

#### `service_exist.active_storage`

| Clave          | Valor                       |
| ------------ | --------------------------- |
| `:key`       | Token seguro                |
| `:service`   | Nombre del servicio         |
| `:exist`     | Archivo o blob existe o no  |

#### `service_url.active_storage`

| Clave          | Valor               |
| ------------ | ------------------- |
| `:key`       | Token seguro        |
| `:service`   | Nombre del servicio |
| `:url`       | URL generada       |

#### `service_update_metadata.active_storage`

Este evento solo se emite al usar el servicio de Google Cloud Storage.

| Clave             | Valor                            |
| --------------- | -------------------------------- |
| `:key`          | Token seguro                     |
| `:service`      | Nombre del servicio              |
| `:content_type` | Campo HTTP `Content-Type`        |
| `:disposition`  | Campo HTTP `Content-Disposition` |

### Action Mailbox

#### `process.action_mailbox`

| Clave              | Valor                                                  |
| -----------------| ------------------------------------------------------ |
| `:mailbox`       | Instancia de la clase Mailbox que hereda de [`ActionMailbox::Base`][] |
| `:inbound_email` | Hash con datos sobre el correo electrónico entrante que se está procesando |

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

| Clave            | Valor                                               |
| -------------- | --------------------------------------------------- |
| `:initializer` | Ruta del inicializador cargado en `config/initializers` |

### Rails

#### `deprecation.rails`

| Clave                    | Valor                                                 |
| ---------------------- | ------------------------------------------------------|
| `:message`             | La advertencia de deprecación                          |
| `:callstack`           | De dónde proviene la advertencia de deprecación        |
| `:gem_name`            | Nombre de la gema que informa la deprecación           |
| `:deprecation_horizon` | Versión en la que se eliminará el comportamiento obsoleto |

Excepciones
----------

Si ocurre una excepción durante cualquier instrumentación, el payload incluirá
información al respecto.

| Clave                 | Valor                                                          |
| ------------------- | -------------------------------------------------------------- |
| `:exception`        | Un array de dos elementos. El nombre de la clase de la excepción y el mensaje |
| `:exception_object` | El objeto de la excepción                                           |

Creación de eventos personalizados
----------------------

Agregar tus propios eventos también es fácil. Active Support se encargará de
todo el trabajo pesado por ti. Simplemente llama a [`ActiveSupport::Notifications.instrument`][] con un `nombre`, `payload` y un bloque.
La notificación se enviará después de que el bloque regrese. Active Support generará los tiempos de inicio y fin,
y agregará el ID único del instrumentador. Todos los datos pasados a la llamada `instrument` se incluirán
en el payload.
Aquí tienes un ejemplo:

```ruby
ActiveSupport::Notifications.instrument "my.custom.event", this: :data do
  # haz tus cosas personalizadas aquí
end
```

Ahora puedes escuchar este evento con:

```ruby
ActiveSupport::Notifications.subscribe "my.custom.event" do |name, started, finished, unique_id, data|
  puts data.inspect # {:this=>:data}
end
```

También puedes llamar a `instrument` sin pasar un bloque. Esto te permite aprovechar la infraestructura de instrumentación para otros usos de mensajería.

```ruby
ActiveSupport::Notifications.instrument "my.custom.event", this: :data

ActiveSupport::Notifications.subscribe "my.custom.event" do |name, started, finished, unique_id, data|
  puts data.inspect # {:this=>:data}
end
```

Debes seguir las convenciones de Rails al definir tus propios eventos. El formato es: `evento.biblioteca`.
Si tu aplicación está enviando Tweets, debes crear un evento llamado `tweet.twitter`.
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
