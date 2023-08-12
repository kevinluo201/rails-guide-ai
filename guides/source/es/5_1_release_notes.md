**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: ddd82b1a207070829b1ec46e4bb40d80
Notas de lanzamiento de Ruby on Rails 5.1
=========================================

Aspectos destacados en Rails 5.1:

* Soporte para Yarn
* Soporte opcional para Webpack
* jQuery ya no es una dependencia predeterminada
* Pruebas de sistema
* Secretos encriptados
* Mailers parametrizados
* Rutas directas y resueltas
* Unificación de form_for y form_tag en form_with

Estas notas de lanzamiento solo cubren los cambios principales. Para conocer las diversas correcciones de errores y cambios, consulte los registros de cambios o revise la [lista de commits](https://github.com/rails/rails/commits/5-1-stable) en el repositorio principal de Rails en GitHub.

--------------------------------------------------------------------------------

Actualización a Rails 5.1
-------------------------

Si está actualizando una aplicación existente, es una buena idea tener una buena cobertura de pruebas antes de comenzar. También debe actualizar primero a Rails 5.0 en caso de que no lo haya hecho y asegurarse de que su aplicación siga funcionando como se espera antes de intentar una actualización a Rails 5.1. Una lista de cosas a tener en cuenta al actualizar está disponible en la guía [Actualización de Ruby on Rails](upgrading_ruby_on_rails.html#upgrading-from-rails-5-0-to-rails-5-1).

Funciones principales
--------------------

### Soporte para Yarn

[Solicitud de extracción](https://github.com/rails/rails/pull/26836)

Rails 5.1 permite administrar las dependencias de JavaScript desde npm a través de Yarn. Esto facilitará el uso de bibliotecas como React, VueJS o cualquier otra biblioteca del mundo npm. El soporte para Yarn está integrado con el pipeline de activos para que todas las dependencias funcionen sin problemas con la aplicación Rails 5.1.

### Soporte opcional para Webpack

[Solicitud de extracción](https://github.com/rails/rails/pull/27288)

Las aplicaciones Rails pueden integrarse más fácilmente con [Webpack](https://webpack.js.org/), un empaquetador de activos de JavaScript, utilizando la nueva gema [Webpacker](https://github.com/rails/webpacker). Use la bandera `--webpack` al generar nuevas aplicaciones para habilitar la integración de Webpack.

Esto es totalmente compatible con el pipeline de activos, que aún puede usar para imágenes, fuentes, sonidos y otros activos. Incluso puede tener parte del código JavaScript administrado por el pipeline de activos y otro código procesado a través de Webpack. Todo esto es gestionado por Yarn, que está habilitado de forma predeterminada.

### jQuery ya no es una dependencia predeterminada

[Solicitud de extracción](https://github.com/rails/rails/pull/27113)

jQuery era requerido de forma predeterminada en versiones anteriores de Rails para proporcionar características como `data-remote`, `data-confirm` y otras partes de las ofertas de JavaScript no intrusivas de Rails. Ya no es necesario, ya que el UJS se ha reescrito para usar JavaScript plano. Este código ahora se envía dentro de Action View como `rails-ujs`.

Todavía puede usar jQuery si es necesario, pero ya no es necesario de forma predeterminada.

### Pruebas de sistema

[Solicitud de extracción](https://github.com/rails/rails/pull/26703)

Rails 5.1 tiene soporte integrado para escribir pruebas de Capybara, en forma de pruebas de sistema. Ya no es necesario preocuparse por configurar Capybara y las estrategias de limpieza de la base de datos para este tipo de pruebas. Rails 5.1 proporciona un envoltorio para ejecutar pruebas en Chrome con características adicionales como capturas de pantalla de fallos.
### Secretos encriptados

[Solicitud de extracción](https://github.com/rails/rails/pull/28038)

Rails ahora permite gestionar los secretos de la aplicación de manera segura, inspirado en la gema [sekrets](https://github.com/ahoward/sekrets).

Ejecuta `bin/rails secrets:setup` para configurar un nuevo archivo de secretos encriptados. Esto también generará una clave maestra, que debe almacenarse fuera del repositorio. Los propios secretos pueden ser guardados de forma segura en el sistema de control de versiones, en forma encriptada.

Los secretos se desencriptarán en producción, utilizando una clave almacenada en la variable de entorno `RAILS_MASTER_KEY` o en un archivo de clave.

### Mailers parametrizados

[Solicitud de extracción](https://github.com/rails/rails/pull/27825)

Permite especificar parámetros comunes utilizados para todos los métodos en una clase de mailer, con el fin de compartir variables de instancia, encabezados y otras configuraciones comunes.

```ruby
class InvitationsMailer < ApplicationMailer
  before_action { @inviter, @invitee = params[:inviter], params[:invitee] }
  before_action { @account = params[:inviter].account }

  def account_invitation
    mail subject: "#{@inviter.name} te invitó a su Basecamp (#{@account.name})"
  end
end
```

```ruby
InvitationsMailer.with(inviter: person_a, invitee: person_b)
                 .account_invitation.deliver_later
```

### Rutas directas y resueltas

[Solicitud de extracción](https://github.com/rails/rails/pull/23138)

Rails 5.1 agrega dos nuevos métodos, `resolve` y `direct`, al DSL de enrutamiento. El método `resolve` permite personalizar la asignación polimórfica de modelos.

```ruby
resource :basket

resolve("Basket") { [:basket] }
```

```erb
<%= form_for @basket do |form| %>
  <!-- formulario del basket -->
<% end %>
```

Esto generará la URL singular `/basket` en lugar de la habitual `/baskets/:id`.

El método `direct` permite crear helpers de URL personalizados.

```ruby
direct(:homepage) { "https://rubyonrails.org" }

homepage_url # => "https://rubyonrails.org"
```

El valor de retorno del bloque debe ser un argumento válido para el método `url_for`. Por lo tanto, puedes pasar una cadena URL válida, un Hash, un Array, una instancia de Active Model o una clase de Active Model.

```ruby
direct :commentable do |model|
  [ model, anchor: model.dom_id ]
end

direct :main do
  { controller: 'pages', action: 'index', subdomain: 'www' }
end
```

### Unificación de form_for y form_tag en form_with

[Solicitud de extracción](https://github.com/rails/rails/pull/26976)

Antes de Rails 5.1, había dos interfaces para manejar formularios HTML: `form_for` para instancias de modelos y `form_tag` para URLs personalizadas.

Rails 5.1 combina ambas interfaces con `form_with` y puede generar etiquetas de formulario basadas en URLs, ámbitos o modelos.

Usando solo una URL:

```erb
<%= form_with url: posts_path do |form| %>
  <%= form.text_field :title %>
<% end %>

<%# Generará %>

<form action="/posts" method="post" data-remote="true">
  <input type="text" name="title">
</form>
```

Agregar un ámbito agrega un prefijo a los nombres de los campos de entrada:

```erb
<%= form_with scope: :post, url: posts_path do |form| %>
  <%= form.text_field :title %>
<% end %>

<%# Generará %>

<form action="/posts" method="post" data-remote="true">
  <input type="text" name="post[title]">
</form>
```
Usar un modelo implica tanto la URL como el alcance:

```erb
<%= form_with model: Post.new do |form| %>
  <%= form.text_field :title %>
<% end %>

<%# Generará %>

<form action="/posts" method="post" data-remote="true">
  <input type="text" name="post[title]">
</form>
```

Un modelo existente crea un formulario de actualización y completa los valores de los campos:

```erb
<%= form_with model: Post.first do |form| %>
  <%= form.text_field :title %>
<% end %>

<%# Generará %>

<form action="/posts/1" method="post" data-remote="true">
  <input type="hidden" name="_method" value="patch">
  <input type="text" name="post[title]" value="<el título del post>">
</form>
```

Incompatibilidades
-----------------

Los siguientes cambios pueden requerir una acción inmediata al actualizar.

### Pruebas transaccionales con múltiples conexiones

Las pruebas transaccionales ahora envuelven todas las conexiones de Active Record en transacciones de base de datos.

Cuando una prueba genera hilos adicionales y esos hilos obtienen conexiones de base de datos, esas conexiones ahora se manejan de manera especial:

Los hilos compartirán una única conexión, que está dentro de la transacción administrada. Esto asegura que todos los hilos vean la base de datos en el mismo estado, ignorando la transacción más externa. Anteriormente, estas conexiones adicionales no podían ver las filas de los fixtures, por ejemplo.

Cuando un hilo entra en una transacción anidada, obtendrá temporalmente el uso exclusivo de la conexión para mantener el aislamiento.

Si tus pruebas actualmente dependen de obtener una conexión separada fuera de la transacción en un hilo generado, deberás cambiar a un manejo de conexión más explícito.

Si tus pruebas generan hilos y esos hilos interactúan mientras también usan transacciones de base de datos explícitas, este cambio puede introducir un bloqueo.

La forma fácil de optar por no utilizar este nuevo comportamiento es desactivar las pruebas transaccionales en los casos de prueba que afecte.

Railties
--------

Por favor, consulta el [registro de cambios][railties] para obtener cambios detallados.

### Eliminaciones

*   Eliminar `config.static_cache_control` obsoleto.
    ([commit](https://github.com/rails/rails/commit/c861decd44198f8d7d774ee6a74194d1ac1a5a13))

*   Eliminar `config.serve_static_files` obsoleto.
    ([commit](https://github.com/rails/rails/commit/0129ca2eeb6d5b2ea8c6e6be38eeb770fe45f1fa))

*   Eliminar archivo obsoleto `rails/rack/debugger`.
    ([commit](https://github.com/rails/rails/commit/7563bf7b46e6f04e160d664e284a33052f9804b8))

*   Eliminar tareas obsoletas: `rails:update`, `rails:template`, `rails:template:copy`,
    `rails:update:configs` y `rails:update:bin`.
    ([commit](https://github.com/rails/rails/commit/f7782812f7e727178e4a743aa2874c078b722eef))

*   Eliminar variable de entorno `CONTROLLER` obsoleta para la tarea `routes`.
    ([commit](https://github.com/rails/rails/commit/f9ed83321ac1d1902578a0aacdfe55d3db754219))

*   Eliminar opción -j (--javascript) del comando `rails new`.
    ([Pull Request](https://github.com/rails/rails/pull/28546))

### Cambios destacados

*   Agregar una sección compartida a `config/secrets.yml` que se cargará para todos los entornos.
    ([commit](https://github.com/rails/rails/commit/e530534265d2c32b5c5f772e81cb9002dcf5e9cf))

*   El archivo de configuración `config/secrets.yml` ahora se carga con todas las claves como símbolos.
    ([Pull Request](https://github.com/rails/rails/pull/26929))

*   Eliminar jquery-rails de la pila predeterminada. rails-ujs, que se incluye con Action View, se incluye como adaptador UJS predeterminado.
    ([Pull Request](https://github.com/rails/rails/pull/27113))

*   Agregar soporte para Yarn en nuevas aplicaciones con un binstub de yarn y package.json.
    ([Pull Request](https://github.com/rails/rails/pull/26836))

*   Agregar soporte para Webpack en nuevas aplicaciones a través de la opción `--webpack`, que delegará en la gema rails/webpacker.
    ([Pull Request](https://github.com/rails/rails/pull/27288))
*   Inicializar el repositorio Git al generar una nueva aplicación, si no se proporciona la opción `--skip-git`.
    ([Pull Request](https://github.com/rails/rails/pull/27632))

*   Agregar secretos encriptados en `config/secrets.yml.enc`.
    ([Pull Request](https://github.com/rails/rails/pull/28038))

*   Mostrar el nombre de la clase Railtie en los inicializadores de Rails.
    ([Pull Request](https://github.com/rails/rails/pull/25257))

Action Cable
-----------

Consulte el [registro de cambios][action-cable] para obtener cambios detallados.

### Cambios destacados

*   Se agregó soporte para `channel_prefix` en los adaptadores Redis y Redis con eventos en `cable.yml` para evitar colisiones de nombres al usar el mismo servidor Redis con múltiples aplicaciones.
    ([Pull Request](https://github.com/rails/rails/pull/27425))

*   Se agregó un gancho `ActiveSupport::Notifications` para transmitir datos.
    ([Pull Request](https://github.com/rails/rails/pull/24988))

Action Pack
-----------

Consulte el [registro de cambios][action-pack] para obtener cambios detallados.

### Eliminaciones

*   Se eliminó el soporte para argumentos no clave en `#process`, `#get`, `#post`, `#patch`, `#put`, `#delete` y `#head` para las clases `ActionDispatch::IntegrationTest` y `ActionController::TestCase`.
    ([Commit](https://github.com/rails/rails/commit/98b8309569a326910a723f521911e54994b112fb),
    [Commit](https://github.com/rails/rails/commit/de9542acd56f60d281465a59eac11e15ca8b3323))

*   Se eliminaron los métodos obsoletos `ActionDispatch::Callbacks.to_prepare` y `ActionDispatch::Callbacks.to_cleanup`.
    ([Commit](https://github.com/rails/rails/commit/3f2b7d60a52ffb2ad2d4fcf889c06b631db1946b))

*   Se eliminaron los métodos obsoletos relacionados con los filtros del controlador.
    ([Commit](https://github.com/rails/rails/commit/d7be30e8babf5e37a891522869e7b0191b79b757))

*   Se eliminó el soporte obsoleto para `:text` y `:nothing` en `render`.
    ([Commit](https://github.com/rails/rails/commit/79a5ea9eadb4d43b62afacedc0706cbe88c54496),
    [Commit](https://github.com/rails/rails/commit/57e1c99a280bdc1b324936a690350320a1cd8111))

*   Se eliminó el soporte obsoleto para llamar a los métodos de `HashWithIndifferentAccess` en `ActionController::Parameters`.
    ([Commit](https://github.com/rails/rails/pull/26746/commits/7093ceb480ad6a0a91b511832dad4c6a86981b93))

### Obsolescencias

*   Se ha marcado como obsoleto `config.action_controller.raise_on_unfiltered_parameters`. No tiene ningún efecto en Rails 5.1.
    ([Commit](https://github.com/rails/rails/commit/c6640fb62b10db26004a998d2ece98baede509e5))

### Cambios destacados

*   Se agregaron los métodos `direct` y `resolve` a DSL de enrutamiento.
    ([Pull Request](https://github.com/rails/rails/pull/23138))

*   Se agregó una nueva clase `ActionDispatch::SystemTestCase` para escribir pruebas de sistema en sus aplicaciones.
    ([Pull Request](https://github.com/rails/rails/pull/26703))

Action View
-------------

Consulte el [registro de cambios][action-view] para obtener cambios detallados.

### Eliminaciones

*   Se eliminó `#original_exception` obsoleto en `ActionView::Template::Error`.
    ([commit](https://github.com/rails/rails/commit/b9ba263e5aaa151808df058f5babfed016a1879f))

*   Se eliminó la opción `encode_special_chars` mal nombrada de `strip_tags`.
    ([Pull Request](https://github.com/rails/rails/pull/28061))

### Obsolescencias

*   Se ha marcado como obsoleto el manejador ERB de Erubis en favor de Erubi.
    ([Pull Request](https://github.com/rails/rails/pull/27757))

### Cambios destacados

*   El manejador de plantillas Raw (el manejador de plantillas predeterminado en Rails 5) ahora muestra cadenas seguras para HTML.
    ([commit](https://github.com/rails/rails/commit/1de0df86695f8fa2eeae6b8b46f9b53decfa6ec8))

*   Cambiar `datetime_field` y `datetime_field_tag` para generar campos `datetime-local`.
    ([Pull Request](https://github.com/rails/rails/pull/25469))

*   Nueva sintaxis de estilo Builder para etiquetas HTML (`tag.div`, `tag.br`, etc.).
    ([Pull Request](https://github.com/rails/rails/pull/25543))

*   Agregar `form_with` para unificar el uso de `form_tag` y `form_for`.
    ([Pull Request](https://github.com/rails/rails/pull/26976))

*   Agregar la opción `check_parameters` a `current_page?`.
    ([Pull Request](https://github.com/rails/rails/pull/27549))

Action Mailer
-------------

Consulte el [registro de cambios][action-mailer] para obtener cambios detallados.

### Cambios destacados

*   Permitir establecer un tipo de contenido personalizado cuando se incluyen archivos adjuntos y se establece el cuerpo en línea.
    ([Pull Request](https://github.com/rails/rails/pull/27227))

*   Permitir pasar lambdas como valores al método `default`.
    ([Commit](https://github.com/rails/rails/commit/1cec84ad2ddd843484ed40b1eb7492063ce71baf))

*   Agregar soporte para invocación parametrizada de mailers para compartir filtros y valores predeterminados entre diferentes acciones de mailer.
    ([Commit](https://github.com/rails/rails/commit/1cec84ad2ddd843484ed40b1eb7492063ce71baf))

*   Pasar los argumentos entrantes a la acción del mailer al evento `process.action_mailer` bajo una clave `args`.
    ([Pull Request](https://github.com/rails/rails/pull/27900))

Active Record
-------------

Consulte el [registro de cambios][active-record] para obtener cambios detallados.

### Eliminaciones
*   Se eliminó el soporte para pasar argumentos y bloque al mismo tiempo a `ActiveRecord::QueryMethods#select`.
    ([Commit](https://github.com/rails/rails/commit/4fc3366d9d99a0eb19e45ad2bf38534efbf8c8ce))

*   Se eliminaron los ámbitos de internacionalización `activerecord.errors.messages.restrict_dependent_destroy.one` y `activerecord.errors.messages.restrict_dependent_destroy.many` que estaban en desuso.
    ([Commit](https://github.com/rails/rails/commit/00e3973a311))

*   Se eliminó el argumento de recarga forzada en los lectores de asociación singular y de colección que estaban en desuso.
    ([Commit](https://github.com/rails/rails/commit/09cac8c67af))

*   Se eliminó el soporte de pasar una columna a `#quote` que estaba en desuso.
    ([Commit](https://github.com/rails/rails/commit/e646bad5b7c))

*   Se eliminaron los argumentos `name` en `#tables` que estaban en desuso.
    ([Commit](https://github.com/rails/rails/commit/d5be101dd02214468a27b6839ffe338cfe8ef5f3))

*   Se eliminó el comportamiento en desuso de `#tables` y `#table_exists?` para devolver solo tablas y no vistas.
    ([Commit](https://github.com/rails/rails/commit/5973a984c369a63720c2ac18b71012b8347479a8))

*   Se eliminó el argumento `original_exception` en `ActiveRecord::StatementInvalid#initialize` y `ActiveRecord::StatementInvalid#original_exception` que estaba en desuso.
    ([Commit](https://github.com/rails/rails/commit/bc6c5df4699d3f6b4a61dd12328f9e0f1bd6cf46))

*   Se eliminó el soporte en desuso de pasar una clase como valor en una consulta.
    ([Commit](https://github.com/rails/rails/commit/b4664864c972463c7437ad983832d2582186e886))

*   Se eliminó el soporte en desuso para consultar usando comas en LIMIT.
    ([Commit](https://github.com/rails/rails/commit/fc3e67964753fb5166ccbd2030d7382e1976f393))

*   Se eliminó el parámetro `conditions` en `#destroy_all` que estaba en desuso.
    ([Commit](https://github.com/rails/rails/commit/d31a6d1384cd740c8518d0bf695b550d2a3a4e9b))

*   Se eliminó el parámetro `conditions` en `#delete_all` que estaba en desuso.
    ([Commit](https://github.com/rails/rails/pull/27503/commits/e7381d289e4f8751dcec9553dcb4d32153bd922b))

*   Se eliminó el método en desuso `#load_schema_for` a favor de `#load_schema`.
    ([Commit](https://github.com/rails/rails/commit/419e06b56c3b0229f0c72d3e4cdf59d34d8e5545))

*   Se eliminó la configuración `#raise_in_transactional_callbacks` que estaba en desuso.
    ([Commit](https://github.com/rails/rails/commit/8029f779b8a1dd9848fee0b7967c2e0849bf6e07))

*   Se eliminó la configuración `#use_transactional_fixtures` que estaba en desuso.
    ([Commit](https://github.com/rails/rails/commit/3955218dc163f61c932ee80af525e7cd440514b3))

### Deprecaciones

*   Se deprecó la bandera `error_on_ignored_order_or_limit` a favor de `error_on_ignored_order`.
    ([Commit](https://github.com/rails/rails/commit/451437c6f57e66cc7586ec966e530493927098c7))

*   Se deprecó `sanitize_conditions` a favor de `sanitize_sql`.
    ([Pull Request](https://github.com/rails/rails/pull/25999))

*   Se deprecó `supports_migrations?` en los adaptadores de conexión.
    ([Pull Request](https://github.com/rails/rails/pull/28172))

*   Se deprecó `Migrator.schema_migrations_table_name`, usar `SchemaMigration.table_name` en su lugar.
    ([Pull Request](https://github.com/rails/rails/pull/28351))

*   Se deprecó el uso de `#quoted_id` en la cita y conversión de tipos.
    ([Pull Request](https://github.com/rails/rails/pull/27962))

*   Se deprecó pasar el argumento `default` a `#index_name_exists?`.
    ([Pull Request](https://github.com/rails/rails/pull/26930))

### Cambios destacados

*   Se cambió la clave primaria predeterminada a BIGINT.
    ([Pull Request](https://github.com/rails/rails/pull/26266))

*   Soporte para columnas virtuales/generadas en MySQL 5.7.5+ y MariaDB 5.2.0+.
    ([Commit](https://github.com/rails/rails/commit/65bf1c60053e727835e06392d27a2fb49665484c))

*   Se agregó soporte para límites en el procesamiento por lotes.
    ([Commit](https://github.com/rails/rails/commit/451437c6f57e66cc7586ec966e530493927098c7))

*   Las pruebas transaccionales ahora envuelven todas las conexiones de Active Record en transacciones de base de datos.
    ([Pull Request](https://github.com/rails/rails/pull/28726))

*   Se omiten los comentarios en la salida del comando `mysqldump` de forma predeterminada.
    ([Pull Request](https://github.com/rails/rails/pull/23301))

*   Se corrigió `ActiveRecord::Relation#count` para usar `Enumerable#count` de Ruby para contar registros cuando se pasa un bloque como argumento en lugar de ignorar silenciosamente el bloque pasado.
    ([Pull Request](https://github.com/rails/rails/pull/24203))

*   Se pasa la bandera `"-v ON_ERROR_STOP=1"` con el comando `psql` para no suprimir los errores de SQL.
    ([Pull Request](https://github.com/rails/rails/pull/24773))

*   Se agregó `ActiveRecord::Base.connection_pool.stat`.
    ([Pull Request](https://github.com/rails/rails/pull/26988))

*   Generar una excepción cuando la asociación `through` tiene un nombre de reflexión ambiguo.
    ([Commit](https://github.com/rails/rails/commit/0944182ad7ed70d99b078b22426cbf844edd3f61))

Active Model
------------

Consulte el [registro de cambios][active-model] para obtener cambios detallados.

### Eliminaciones

*   Se eliminaron los métodos en desuso en `ActiveModel::Errors`.
    ([commit](https://github.com/rails/rails/commit/9de6457ab0767ebab7f2c8bc583420fda072e2bd))

*   Se eliminó la opción `:tokenizer` en el validador de longitud que estaba en desuso.
    ([commit](https://github.com/rails/rails/commit/6a78e0ecd6122a6b1be9a95e6c4e21e10e429513))

*   Se eliminó el comportamiento en desuso que detiene las devoluciones de llamada cuando el valor de retorno es falso.
    ([commit](https://github.com/rails/rails/commit/3a25cdca3e0d29ee2040931d0cb6c275d612dffe))

### Cambios destacados

*   La cadena original asignada a un atributo del modelo ya no se congela incorrectamente.
    ([Pull Request](https://github.com/rails/rails/pull/28729))
Active Job
-----------

Consulte el [registro de cambios][active-job] para obtener cambios detallados.

### Eliminaciones

*   Se eliminó el soporte obsoleto para pasar la clase de adaptador a `.queue_adapter`.
    ([commit](https://github.com/rails/rails/commit/d1fc0a5eb286600abf8505516897b96c2f1ef3f6))

*   Se eliminó `#original_exception` obsoleto en `ActiveJob::DeserializationError`.
    ([commit](https://github.com/rails/rails/commit/d861a1fcf8401a173876489d8cee1ede1cecde3b))

### Cambios destacados

*   Se agregó manejo declarativo de excepciones a través de `ActiveJob::Base.retry_on` y `ActiveJob::Base.discard_on`.
    ([Pull Request](https://github.com/rails/rails/pull/25991))

*   Se devuelve la instancia del trabajo para que tenga acceso a cosas como `job.arguments` en
    la lógica personalizada después de que fallan los reintentos.
    ([commit](https://github.com/rails/rails/commit/a1e4c197cb12fef66530a2edfaeda75566088d1f))

Active Support
--------------

Consulte el [registro de cambios][active-support] para obtener cambios detallados.

### Eliminaciones

*   Se eliminó la clase `ActiveSupport::Concurrency::Latch`.
    ([Commit](https://github.com/rails/rails/commit/0d7bd2031b4054fbdeab0a00dd58b1b08fb7fea6))

*   Se eliminó `halt_callback_chains_on_return_false`.
    ([Commit](https://github.com/rails/rails/commit/4e63ce53fc25c3bc15c5ebf54bab54fa847ee02a))

*   Se eliminó el comportamiento obsoleto que detiene las devoluciones de llamada cuando el retorno es falso.
    ([Commit](https://github.com/rails/rails/commit/3a25cdca3e0d29ee2040931d0cb6c275d612dffe))

### Deprecaciones

*   La clase `HashWithIndifferentAccess` de nivel superior ha sido suavemente deprecada
    a favor de `ActiveSupport::HashWithIndifferentAccess`.
    ([Pull Request](https://github.com/rails/rails/pull/28157))

*   Se deprecó pasar una cadena a las opciones condicionales `:if` y `:unless` en `set_callback` y `skip_callback`.
    ([Commit](https://github.com/rails/rails/commit/0952552))

### Cambios destacados

*   Se corrigió el análisis de duración y el desplazamiento para que sea consistente en los cambios de DST.
    ([Commit](https://github.com/rails/rails/commit/8931916f4a1c1d8e70c06063ba63928c5c7eab1e),
    [Pull Request](https://github.com/rails/rails/pull/26597))

*   Se actualizó Unicode a la versión 9.0.0.
    ([Pull Request](https://github.com/rails/rails/pull/27822))

*   Se agregaron `Duration#before` y `#after` como alias de `#ago` y `#since`.
    ([Pull Request](https://github.com/rails/rails/pull/27721))

*   Se agregó `Module#delegate_missing_to` para delegar llamadas de método no
    definidas para el objeto actual a un objeto proxy.
    ([Pull Request](https://github.com/rails/rails/pull/23930))

*   Se agregó `Date#all_day` que devuelve un rango que representa todo el día
    de la fecha y hora actual.
    ([Pull Request](https://github.com/rails/rails/pull/24930))

*   Se introdujeron los métodos `assert_changes` y `assert_no_changes` para pruebas.
    ([Pull Request](https://github.com/rails/rails/pull/25393))

*   Los métodos `travel` y `travel_to` ahora generan un error en llamadas anidadas.
    ([Pull Request](https://github.com/rails/rails/pull/24890))

*   Se actualizó `DateTime#change` para admitir usec y nsec.
    ([Pull Request](https://github.com/rails/rails/pull/28242))

Créditos
-------

Consulte la
[lista completa de colaboradores de Rails](https://contributors.rubyonrails.org/) para
las muchas personas que pasaron muchas horas haciendo de Rails el marco estable y robusto que es. Felicitaciones a todos ellos.

[railties]:       https://github.com/rails/rails/blob/5-1-stable/railties/CHANGELOG.md
[action-pack]:    https://github.com/rails/rails/blob/5-1-stable/actionpack/CHANGELOG.md
[action-view]:    https://github.com/rails/rails/blob/5-1-stable/actionview/CHANGELOG.md
[action-mailer]:  https://github.com/rails/rails/blob/5-1-stable/actionmailer/CHANGELOG.md
[action-cable]:   https://github.com/rails/rails/blob/5-1-stable/actioncable/CHANGELOG.md
[active-record]:  https://github.com/rails/rails/blob/5-1-stable/activerecord/CHANGELOG.md
[active-model]:   https://github.com/rails/rails/blob/5-1-stable/activemodel/CHANGELOG.md
[active-job]:     https://github.com/rails/rails/blob/5-1-stable/activejob/CHANGELOG.md
[active-support]: https://github.com/rails/rails/blob/5-1-stable/activesupport/CHANGELOG.md
