**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 48f8290cbf9190673c32a3eb9777acba
Rails en Rack
=============

Esta guía cubre la integración de Rails con Rack y la interfaz con otros componentes de Rack.

Después de leer esta guía, sabrás:

* Cómo usar Middlewares de Rack en tus aplicaciones de Rails.
* La pila interna de Middlewares de Action Pack.
* Cómo definir una pila de Middlewares personalizada.

--------------------------------------------------------------------------------

ADVERTENCIA: Esta guía asume un conocimiento práctico del protocolo Rack y conceptos de Rack como middlewares, mapas de URL y `Rack::Builder`.

Introducción a Rack
--------------------

Rack proporciona una interfaz mínima, modular y adaptable para desarrollar aplicaciones web en Ruby. Al envolver las solicitudes y respuestas HTTP de la manera más simple posible, unifica y destila la API para servidores web, frameworks web y software intermedio (llamado middleware) en una sola llamada de método.

Explicar cómo funciona Rack no está realmente dentro del alcance de esta guía. En caso de que no estés familiarizado con los conceptos básicos de Rack, deberías consultar la sección [Recursos](#recursos) a continuación.

Rails en Rack
-------------

### Objeto Rack de la aplicación Rails

`Rails.application` es el objeto principal de la aplicación Rack de una aplicación Rails. Cualquier servidor web compatible con Rack debería usar el objeto `Rails.application` para servir una aplicación Rails.

### `bin/rails server`

`bin/rails server` se encarga de crear un objeto `Rack::Server` y de iniciar el servidor web.

Así es como `bin/rails server` crea una instancia de `Rack::Server`:

```ruby
Rails::Server.new.tap do |server|
  require APP_PATH
  Dir.chdir(Rails.application.root)
  server.start
end
```

`Rails::Server` hereda de `Rack::Server` y llama al método `Rack::Server#start` de esta manera:

```ruby
class Server < ::Rack::Server
  def start
    # ...
    super
  end
end
```

### `rackup`

Para usar `rackup` en lugar de `bin/rails server` de Rails, puedes agregar lo siguiente dentro de `config.ru` en el directorio raíz de tu aplicación Rails:

```ruby
# Rails.root/config.ru
require_relative "config/environment"
run Rails.application
```

Y luego iniciar el servidor:

```bash
$ rackup config.ru
```

Para obtener más información sobre las diferentes opciones de `rackup`, puedes ejecutar:

```bash
$ rackup --help
```

### Desarrollo y recarga automática

Los middlewares se cargan una vez y no se supervisan los cambios. Debes reiniciar el servidor para que los cambios se reflejen en la aplicación en ejecución.

Pila de Middlewares de Action Dispatcher
----------------------------------

Muchos de los componentes internos de Action Dispatcher se implementan como middlewares de Rack. `Rails::Application` utiliza `ActionDispatch::MiddlewareStack` para combinar varios middlewares internos y externos y formar una aplicación Rails completa en Rack.

NOTA: `ActionDispatch::MiddlewareStack` es el equivalente de Rails a `Rack::Builder`, pero está diseñado para ofrecer una mayor flexibilidad y más características para cumplir con los requisitos de Rails.

### Inspeccionar la pila de Middlewares

Rails tiene un comando útil para inspeccionar la pila de middlewares en uso:

```bash
$ bin/rails middleware
```

Para una aplicación Rails recién generada, esto podría producir algo como:

```ruby
use ActionDispatch::HostAuthorization
use Rack::Sendfile
use ActionDispatch::Static
use ActionDispatch::Executor
use ActionDispatch::ServerTiming
use ActiveSupport::Cache::Strategy::LocalCache::Middleware
use Rack::Runtime
use Rack::MethodOverride
use ActionDispatch::RequestId
use ActionDispatch::RemoteIp
use Sprockets::Rails::QuietAssets
use Rails::Rack::Logger
use ActionDispatch::ShowExceptions
use WebConsole::Middleware
use ActionDispatch::DebugExceptions
use ActionDispatch::ActionableExceptions
use ActionDispatch::Reloader
use ActionDispatch::Callbacks
use ActiveRecord::Migration::CheckPending
use ActionDispatch::Cookies
use ActionDispatch::Session::CookieStore
use ActionDispatch::Flash
use ActionDispatch::ContentSecurityPolicy::Middleware
use Rack::Head
use Rack::ConditionalGet
use Rack::ETag
use Rack::TempfileReaper
run MyApp::Application.routes
```

Los middlewares predeterminados mostrados aquí (y algunos otros) se resumen en la sección [Middlewares internos](#pila-de-middlewares-internos) a continuación.

### Configurar la pila de Middlewares

Rails proporciona una interfaz de configuración simple [`config.middleware`][] para agregar, eliminar y modificar los middlewares en la pila de middlewares a través de `application.rb` o el archivo de configuración específico del entorno `environments/<entorno>.rb`.


#### Agregar un Middleware

Puedes agregar un nuevo middleware a la pila de middlewares usando alguno de los siguientes métodos:

* `config.middleware.use(new_middleware, args)` - Agrega el nuevo middleware al final de la pila de middlewares.

* `config.middleware.insert_before(existing_middleware, new_middleware, args)` - Agrega el nuevo middleware antes del middleware existente especificado en la pila de middlewares.

* `config.middleware.insert_after(existing_middleware, new_middleware, args)` - Agrega el nuevo middleware después del middleware existente especificado en la pila de middlewares.

```ruby
# config/application.rb

# Agregar Rack::BounceFavicon al final
config.middleware.use Rack::BounceFavicon

# Agregar Lifo::Cache después de ActionDispatch::Executor.
# Pasar el argumento { page_cache: false } a Lifo::Cache.
config.middleware.insert_after ActionDispatch::Executor, Lifo::Cache, page_cache: false
```

#### Intercambiar un Middleware

Puedes intercambiar un middleware existente en la pila de middlewares usando `config.middleware.swap`.

```ruby
# config/application.rb

# Reemplazar ActionDispatch::ShowExceptions con Lifo::ShowExceptions
config.middleware.swap ActionDispatch::ShowExceptions, Lifo::ShowExceptions
```

#### Mover un Middleware

Puedes mover un middleware existente en la pila de middlewares usando `config.middleware.move_before` y `config.middleware.move_after`.

```ruby
# config/application.rb

# Mover ActionDispatch::ShowExceptions antes de Lifo::ShowExceptions
config.middleware.move_before Lifo::ShowExceptions, ActionDispatch::ShowExceptions
```

```ruby
# config/application.rb

# Mover ActionDispatch::ShowExceptions después de Lifo::ShowExceptions
config.middleware.move_after Lifo::ShowExceptions, ActionDispatch::ShowExceptions
```

#### Eliminar un Middleware
Agregue las siguientes líneas a la configuración de su aplicación:

```ruby
# config/application.rb
config.middleware.delete Rack::Runtime
```

Y ahora, si inspecciona la pila de middlewares, verá que `Rack::Runtime` no forma parte de ella.

```bash
$ bin/rails middleware
(in /Users/lifo/Rails/blog)
use ActionDispatch::Static
use #<ActiveSupport::Cache::Strategy::LocalCache::Middleware:0x00000001c304c8>
...
run Rails.application.routes
```

Si desea eliminar middlewares relacionados con la sesión, haga lo siguiente:

```ruby
# config/application.rb
config.middleware.delete ActionDispatch::Cookies
config.middleware.delete ActionDispatch::Session::CookieStore
config.middleware.delete ActionDispatch::Flash
```

Y para eliminar middlewares relacionados con el navegador,

```ruby
# config/application.rb
config.middleware.delete Rack::MethodOverride
```

Si desea que se genere un error cuando intente eliminar un elemento que no existe, use `delete!` en su lugar.

```ruby
# config/application.rb
config.middleware.delete! ActionDispatch::Executor
```

### Pila interna de middlewares

Gran parte de la funcionalidad de Action Controller se implementa como middlewares. La siguiente lista explica el propósito de cada uno de ellos:

**`ActionDispatch::HostAuthorization`**

* Protege contra ataques de reasignación de DNS al permitir explícitamente los hosts a los que se puede enviar una solicitud. Consulte la [guía de configuración](configuring.html#actiondispatch-hostauthorization) para obtener instrucciones de configuración.

**`Rack::Sendfile`**

* Establece el encabezado X-Sendfile específico del servidor. Configure esto a través de la opción [`config.action_dispatch.x_sendfile_header`][].

**`ActionDispatch::Static`**

* Se utiliza para servir archivos estáticos desde el directorio público. Desactivado si [`config.public_file_server.enabled`][] es `false`.

**`Rack::Lock`**

* Establece la bandera `env["rack.multithread"]` en `false` y envuelve la aplicación en un Mutex.

**`ActionDispatch::Executor`**

* Se utiliza para la recarga de código segura para subprocesos durante el desarrollo.

**`ActionDispatch::ServerTiming`**

* Establece un encabezado [`Server-Timing`](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Server-Timing) que contiene métricas de rendimiento para la solicitud.

**`ActiveSupport::Cache::Strategy::LocalCache::Middleware`**

* Se utiliza para el almacenamiento en caché en memoria. Esta caché no es segura para subprocesos.

**`Rack::Runtime`**

* Establece un encabezado X-Runtime que contiene el tiempo (en segundos) que tarda en ejecutarse la solicitud.

**`Rack::MethodOverride`**

* Permite que se anule el método si se establece `params[:_method]`. Este es el middleware que admite los tipos de método HTTP PUT y DELETE.

**`ActionDispatch::RequestId`**

* Hace que un encabezado único `X-Request-Id` esté disponible para la respuesta y habilita el método `ActionDispatch::Request#request_id`.

**`ActionDispatch::RemoteIp`**

* Verifica los ataques de suplantación de IP.

**`Sprockets::Rails::QuietAssets`**

* Suprime la salida del registro para las solicitudes de activos.

**`Rails::Rack::Logger`**

* Notifica a los registros que la solicitud ha comenzado. Después de que se completa la solicitud, se vacían todos los registros.

**`ActionDispatch::ShowExceptions`**

* Rescata cualquier excepción devuelta por la aplicación y llama a una aplicación de excepciones que la envolverá en un formato para el usuario final.

**`ActionDispatch::DebugExceptions`**

* Responsable de registrar excepciones y mostrar una página de depuración en caso de que la solicitud sea local.

**`ActionDispatch::ActionableExceptions`**

* Proporciona una forma de despachar acciones desde las páginas de error de Rails.

**`ActionDispatch::Reloader`**

* Proporciona devoluciones de llamada de preparación y limpieza, destinadas a ayudar con la recarga de código durante el desarrollo.

**`ActionDispatch::Callbacks`**

* Proporciona devoluciones de llamada que se ejecutarán antes y después de despachar la solicitud.

**`ActiveRecord::Migration::CheckPending`**

* Verifica las migraciones pendientes y genera un error `ActiveRecord::PendingMigrationError` si hay migraciones pendientes.

**`ActionDispatch::Cookies`**

* Establece cookies para la solicitud.

**`ActionDispatch::Session::CookieStore`**

* Responsable de almacenar la sesión en cookies.

**`ActionDispatch::Flash`**

* Configura las claves de flash. Solo está disponible si [`config.session_store`][] se establece en un valor.

**`ActionDispatch::ContentSecurityPolicy::Middleware`**

* Proporciona un DSL para configurar un encabezado Content-Security-Policy.

**`Rack::Head`**

* Convierte las solicitudes HEAD en solicitudes `GET` y las sirve como tal.

**`Rack::ConditionalGet`**

* Agrega soporte para "GET condicional" para que el servidor responda con nada si la página no ha cambiado.

**`Rack::ETag`**

* Agrega el encabezado ETag a todos los cuerpos de tipo String. Los ETags se utilizan para validar la caché.

**`Rack::TempfileReaper`**

* Limpia los archivos temporales utilizados para almacenar las solicitudes multipartes.

CONSEJO: Es posible utilizar cualquiera de los middlewares anteriores en su pila personalizada de Rack.

Recursos
---------

### Aprendiendo Rack

* [Sitio web oficial de Rack](https://rack.github.io)
* [Presentación de Rack](http://chneukirchen.org/blog/archive/2007/02/introducing-rack.html)

### Entendiendo los Middlewares

* [Railscast sobre Middlewares de Rack](http://railscasts.com/episodes/151-rack-middleware)
[`config.middleware`]: configuring.html#config-middleware
[`config.action_dispatch.x_sendfile_header`]: configuring.html#config-action-dispatch-x-sendfile-header
[`config.public_file_server.enabled`]: configuring.html#config-public-file-server-enabled
[`config.session_store`]: configuring.html#config-session-store
