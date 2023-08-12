**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: fe858c0828e87f595c5d8c23c4b6326e
Usando Rails para aplicaciones solo de API
===========================================

En esta guía aprenderás:

* Qué proporciona Rails para aplicaciones solo de API
* Cómo configurar Rails para iniciar sin ninguna funcionalidad de navegador
* Cómo decidir qué middleware deseas incluir
* Cómo decidir qué módulos utilizar en tu controlador

--------------------------------------------------------------------------------

¿Qué es una aplicación de API?
------------------------------

Tradicionalmente, cuando las personas decían que usaban Rails como una "API", se referían a proporcionar una API accesible programáticamente junto con su aplicación web. Por ejemplo, GitHub proporciona [una API](https://developer.github.com) que puedes utilizar desde tus propios clientes personalizados.

Con la aparición de los frameworks del lado del cliente, más desarrolladores están utilizando Rails para construir un backend que se comparte entre su aplicación web y otras aplicaciones nativas.

Por ejemplo, Twitter utiliza su [API pública](https://developer.twitter.com/) en su aplicación web, que se construye como un sitio estático que consume recursos JSON.

En lugar de utilizar Rails para generar HTML que se comunica con el servidor a través de formularios y enlaces, muchos desarrolladores tratan su aplicación web como un cliente de API que se entrega como HTML con JavaScript que consume una API JSON.

Esta guía cubre la construcción de una aplicación Rails que sirve recursos JSON a un cliente de API, incluyendo frameworks del lado del cliente.

¿Por qué usar Rails para API JSON?
-----------------------------------

La primera pregunta que mucha gente tiene al pensar en construir una API JSON utilizando Rails es: "¿no es excesivo usar Rails para generar JSON? ¿No debería usar algo como Sinatra?".

Para APIs muy simples, esto puede ser cierto. Sin embargo, incluso en aplicaciones con mucho HTML, la mayor parte de la lógica de una aplicación vive fuera de la capa de vista.

La razón por la que la mayoría de las personas utilizan Rails es que proporciona un conjunto de valores predeterminados que permite a los desarrolladores comenzar rápidamente, sin tener que tomar muchas decisiones triviales.

Veamos algunas de las cosas que Rails proporciona de forma predeterminada y que siguen siendo aplicables a las aplicaciones de API.

Manejado en la capa de middleware:

- Recarga: Las aplicaciones Rails admiten la recarga transparente. Esto funciona incluso si tu aplicación se vuelve grande y reiniciar el servidor para cada solicitud se vuelve inviable.
- Modo de desarrollo: Las aplicaciones Rails vienen con valores predeterminados inteligentes para el desarrollo, lo que hace que el desarrollo sea agradable sin comprometer el rendimiento en tiempo de producción.
- Modo de prueba: Lo mismo que el modo de desarrollo.
- Registro: Las aplicaciones Rails registran cada solicitud, con un nivel de verbosidad adecuado para el modo actual. Los registros de Rails en desarrollo incluyen información sobre el entorno de la solicitud, consultas a la base de datos e información básica de rendimiento.
- Seguridad: Rails detecta y frustra los ataques de [suplantación de IP](https://en.wikipedia.org/wiki/IP_address_spoofing) y maneja las firmas criptográficas de manera consciente de los [ataques de tiempo](https://en.wikipedia.org/wiki/Timing_attack). ¿No sabes qué es un ataque de suplantación de IP o un ataque de tiempo? Exactamente.
- Análisis de parámetros: ¿Quieres especificar tus parámetros como JSON en lugar de como una cadena codificada en URL? No hay problema. Rails decodificará el JSON por ti y lo pondrá disponible en `params`. ¿Quieres utilizar parámetros anidados codificados en URL? Eso también funciona.
- GET condicionales: Rails maneja las solicitudes condicionales `GET` (`ETag` y `Last-Modified`) procesando las cabeceras de solicitud y devolviendo las cabeceras y el código de estado correctos. Todo lo que necesitas hacer es usar la función [`stale?`](https://api.rubyonrails.org/classes/ActionController/ConditionalGet.html#method-i-stale-3F) en tu controlador, y Rails se encargará de todos los detalles HTTP por ti.
- Solicitudes HEAD: Rails convertirá transparentemente las solicitudes `HEAD` en solicitudes `GET` y devolverá solo las cabeceras en el camino de salida. Esto hace que `HEAD` funcione de manera confiable en todas las APIs de Rails.

Si bien obviamente podrías construir estos en términos de middleware de Rack existentes, esta lista demuestra que la pila de middleware predeterminada de Rails proporciona mucho valor, incluso si solo estás "generando JSON".

Manejado en la capa de Action Pack:

- Enrutamiento de recursos: Si estás construyendo una API JSON RESTful, querrás utilizar el enrutador de Rails. Un mapeo limpio y convencional de HTTP a controladores significa no tener que perder tiempo pensando en cómo modelar tu API en términos de HTTP.
- Generación de URL: El lado opuesto del enrutamiento es la generación de URL. Una buena API basada en HTTP incluye URLs (consulta [la API de Gist de GitHub](https://docs.github.com/en/rest/reference/gists) para ver un ejemplo).
- Respuestas de encabezado y redirección: `head :no_content` y `redirect_to user_url(current_user)` son útiles. Claro, podrías agregar manualmente los encabezados de respuesta, pero ¿por qué hacerlo?
- Caché: Rails proporciona caché de página, acción y fragmento. La caché de fragmentos es especialmente útil al construir un objeto JSON anidado.
- Autenticación básica, de digestión y de token: Rails viene con soporte incorporado para tres tipos de autenticación HTTP.
- Instrumentación: Rails tiene una API de instrumentación que activa controladores registrados para una variedad de eventos, como el procesamiento de acciones, el envío de un archivo o datos, la redirección y las consultas a la base de datos. La carga útil de cada evento viene con información relevante (para el evento de procesamiento de acciones, la carga útil incluye el controlador, la acción, los parámetros, el formato de la solicitud, el método de la solicitud y la ruta completa de la solicitud).
- Generadores: A menudo es útil generar un recurso y obtener tu modelo, controlador, stubs de prueba y rutas creadas para ti en un solo comando para ajustes adicionales. Lo mismo para migraciones y otros.
- Plugins: Muchas bibliotecas de terceros vienen con soporte para Rails que reducen o eliminan el costo de configurar y unir la biblioteca y el framework web. Esto incluye cosas como anular los generadores predeterminados, agregar tareas de Rake y respetar las elecciones de Rails (como el registrador y el backend de caché).
Por supuesto, el proceso de arranque de Rails también une todos los componentes registrados.
Por ejemplo, el proceso de arranque de Rails es el que utiliza tu archivo `config/database.yml`
al configurar Active Record.

**La versión corta es**: es posible que no hayas pensado en qué partes de Rails
siguen siendo aplicables incluso si eliminas la capa de vista, pero la respuesta resulta
ser la mayoría de ellas.

La configuración básica
-----------------------

Si estás construyendo una aplicación Rails que será principalmente un servidor de API,
puedes comenzar con un subconjunto más limitado de Rails y agregar características
según sea necesario.

### Crear una nueva aplicación

Puedes generar una nueva aplicación Rails para una API:

```bash
$ rails new my_api --api
```

Esto hará tres cosas principales por ti:

- Configurará tu aplicación para comenzar con un conjunto más limitado de middleware
  que lo normal. Específicamente, no incluirá ningún middleware principalmente útil
  para aplicaciones de navegador (como el soporte de cookies) de forma predeterminada.
- Hará que `ApplicationController` herede de `ActionController::API` en lugar de
  `ActionController::Base`. Al igual que con el middleware, esto dejará fuera cualquier
  módulo de Action Controller que proporcione funcionalidades utilizadas principalmente por
  aplicaciones de navegador.
- Configurará los generadores para omitir la generación de vistas, helpers y assets cuando
  generes un nuevo recurso.

### Generar un nuevo recurso

Para ver cómo maneja nuestra API recién creada la generación de un nuevo recurso, creemos
un nuevo recurso Group. Cada grupo tendrá un nombre.

```bash
$ bin/rails g scaffold Group name:string
```

Antes de poder usar nuestro código generado, necesitamos actualizar nuestro esquema de base de datos.

```bash
$ bin/rails db:migrate
```

Ahora, si abrimos nuestro `GroupsController`, deberíamos notar que con una aplicación Rails
de API solo estamos renderizando datos JSON. En la acción de índice, consultamos `Group.all`
y lo asignamos a una variable de instancia llamada `@groups`. Pasarlo a `render` con la opción
`:json` automáticamente renderizará los grupos como JSON.

```ruby
# app/controllers/groups_controller.rb
class GroupsController < ApplicationController
  before_action :set_group, only: %i[ show update destroy ]

  # GET /groups
  def index
    @groups = Group.all

    render json: @groups
  end

  # GET /groups/1
  def show
    render json: @group
  end

  # POST /groups
  def create
    @group = Group.new(group_params)

    if @group.save
      render json: @group, status: :created, location: @group
    else
      render json: @group.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /groups/1
  def update
    if @group.update(group_params)
      render json: @group
    else
      render json: @group.errors, status: :unprocessable_entity
    end
  end

  # DELETE /groups/1
  def destroy
    @group.destroy
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_group
      @group = Group.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def group_params
      params.require(:group).permit(:name)
    end
end
```

Finalmente, podemos agregar algunos grupos a nuestra base de datos desde la consola de Rails:

```irb
irb> Group.create(name: "Rails Founders")
irb> Group.create(name: "Rails Contributors")
```

Con algunos datos en la aplicación, podemos iniciar el servidor y visitar <http://localhost:3000/groups.json> para ver nuestros datos JSON.

```json
[
{"id":1, "name":"Rails Founders", "created_at": ...},
{"id":2, "name":"Rails Contributors", "created_at": ...}
]
```

### Cambiar una aplicación existente

Si deseas tomar una aplicación existente y convertirla en una API, lee los siguientes pasos.

En `config/application.rb`, agrega la siguiente línea al principio de la definición de la clase `Application`:

```ruby
config.api_only = true
```

En `config/environments/development.rb`, establece [`config.debug_exception_response_format`][]
para configurar el formato utilizado en las respuestas cuando ocurren errores en el modo de desarrollo.

Para renderizar una página HTML con información de depuración, usa el valor `:default`.

```ruby
config.debug_exception_response_format = :default
```

Para renderizar información de depuración conservando el formato de respuesta, usa el valor `:api`.

```ruby
config.debug_exception_response_format = :api
```

De forma predeterminada, `config.debug_exception_response_format` se establece en `:api`, cuando `config.api_only` se establece en true.

Finalmente, dentro de `app/controllers/application_controller.rb`, en lugar de:

```ruby
class ApplicationController < ActionController::Base
end
```

haz:

```ruby
class ApplicationController < ActionController::API
end
```


Elección de middleware
--------------------

Una aplicación de API viene con el siguiente middleware de forma predeterminada:

- `ActionDispatch::HostAuthorization`
- `Rack::Sendfile`
- `ActionDispatch::Static`
- `ActionDispatch::Executor`
- `ActionDispatch::ServerTiming`
- `ActiveSupport::Cache::Strategy::LocalCache::Middleware`
- `Rack::Runtime`
- `ActionDispatch::RequestId`
- `ActionDispatch::RemoteIp`
- `Rails::Rack::Logger`
- `ActionDispatch::ShowExceptions`
- `ActionDispatch::DebugExceptions`
- `ActionDispatch::ActionableExceptions`
- `ActionDispatch::Reloader`
- `ActionDispatch::Callbacks`
- `ActiveRecord::Migration::CheckPending`
- `Rack::Head`
- `Rack::ConditionalGet`
- `Rack::ETag`

Consulta la sección [middleware interno](rails_on_rack.html#internal-middleware-stack)
de la guía de Rack para obtener más información sobre ellos.

Otros complementos, incluido Active Record, pueden agregar middleware adicional. En
general, este middleware es agnóstico al tipo de aplicación que estás
construyendo y tiene sentido en una aplicación Rails solo de API.
Puedes obtener una lista de todos los middleware en tu aplicación a través de:

```bash
$ bin/rails middleware
```

### Usando Rack::Cache

Cuando se usa con Rails, `Rack::Cache` utiliza la tienda de caché de Rails para sus
almacenes de entidad y meta. Esto significa que si usas memcache para tu
aplicación de Rails, por ejemplo, la caché HTTP incorporada usará memcache.

Para hacer uso de `Rack::Cache`, primero debes agregar la gema `rack-cache`
a `Gemfile` y configurar `config.action_dispatch.rack_cache` en `true`.
Para habilitar su funcionalidad, querrás usar `stale?` en tu
controlador. Aquí tienes un ejemplo de cómo se usa `stale?`.

```ruby
def show
  @post = Post.find(params[:id])

  if stale?(last_modified: @post.updated_at)
    render json: @post
  end
end
```

La llamada a `stale?` comparará el encabezado `If-Modified-Since` en la solicitud
con `@post.updated_at`. Si el encabezado es más nuevo que la última modificación, esta
acción devolverá una respuesta "304 No modificado". De lo contrario, renderizará la
respuesta e incluirá un encabezado `Last-Modified` en ella.

Normalmente, este mecanismo se utiliza de forma individual para cada cliente. `Rack::Cache`
nos permite compartir este mecanismo de almacenamiento en caché entre clientes. Podemos habilitar
el almacenamiento en caché entre clientes en la llamada a `stale?`:

```ruby
def show
  @post = Post.find(params[:id])

  if stale?(last_modified: @post.updated_at, public: true)
    render json: @post
  end
end
```

Esto significa que `Rack::Cache` almacenará el valor `Last-Modified`
para una URL en la caché de Rails y agregará un encabezado `If-Modified-Since` a cualquier
solicitud entrante posterior para la misma URL.

Piensa en ello como almacenamiento en caché de páginas utilizando semántica HTTP.

### Usando Rack::Sendfile

Cuando usas el método `send_file` dentro de un controlador de Rails, se establece el
encabezado `X-Sendfile`. `Rack::Sendfile` es responsable de enviar el archivo de verdad.

Si tu servidor frontal admite el envío acelerado de archivos, `Rack::Sendfile`
delegará el trabajo real de envío de archivos al servidor frontal.

Puedes configurar el nombre del encabezado que tu servidor frontal utiliza para
este propósito utilizando [`config.action_dispatch.x_sendfile_header`][] en el archivo de configuración
del entorno correspondiente.

Puedes obtener más información sobre cómo usar `Rack::Sendfile` con servidores
frontales populares en [la documentación de Rack::Sendfile](https://www.rubydoc.info/gems/rack/Rack/Sendfile).

Aquí tienes algunos valores para este encabezado para algunos servidores populares, una vez que estos servidores estén configurados para admitir
el envío acelerado de archivos:

```ruby
# Apache y lighttpd
config.action_dispatch.x_sendfile_header = "X-Sendfile"

# Nginx
config.action_dispatch.x_sendfile_header = "X-Accel-Redirect"
```

Asegúrate de configurar tu servidor para admitir estas opciones siguiendo las
instrucciones en la documentación de `Rack::Sendfile`.


### Usando ActionDispatch::Request

`ActionDispatch::Request#params` tomará los parámetros del cliente en formato JSON
y los pondrá a disposición en tu controlador dentro de `params`.

Para usar esto, tu cliente deberá hacer una solicitud con parámetros codificados en JSON
y especificar el `Content-Type` como `application/json`.

Aquí tienes un ejemplo en jQuery:

```js
jQuery.ajax({
  type: 'POST',
  url: '/people',
  dataType: 'json',
  contentType: 'application/json',
  data: JSON.stringify({ person: { firstName: "Yehuda", lastName: "Katz" } }),
  success: function(json) { }
});
```

`ActionDispatch::Request` verá el `Content-Type` y tus parámetros
serán:

```ruby
{ person: { firstName: "Yehuda", lastName: "Katz" } }
```

### Usando Middlewares de Sesión

Los siguientes middlewares, utilizados para la gestión de sesiones, están excluidos de las aplicaciones API ya que normalmente no necesitan sesiones. Si uno de tus clientes de API es un navegador, es posible que desees agregar uno de estos nuevamente:

- `ActionDispatch::Session::CacheStore`
- `ActionDispatch::Session::CookieStore`
- `ActionDispatch::Session::MemCacheStore`

El truco para agregar estos nuevamente es que, por defecto, se les pasan `session_options`
cuando se agregan (incluida la clave de sesión), por lo que no puedes simplemente agregar un inicializador `session_store.rb`, agregar
`use ActionDispatch::Session::CookieStore` y tener sesiones funcionando como de costumbre. (Para ser claro: las sesiones
pueden funcionar, pero se ignorarán las opciones de sesión, es decir, la clave de sesión se establecerá en `_session_id` de forma predeterminada)

En lugar del inicializador, deberás configurar las opciones relevantes en algún lugar antes de que se construya tu middleware
(como `config/application.rb`) y pasarlas a tu middleware preferido, así:

```ruby
# Esto también configura session_options para usar a continuación
config.session_store :cookie_store, key: '_interslice_session'

# Requerido para la gestión de sesiones (independientemente de session_store)
config.middleware.use ActionDispatch::Cookies

config.middleware.use config.session_store, config.session_options
```

### Otros Middlewares

Rails incluye varios otros middlewares que podrías querer usar en una
aplicación API, especialmente si uno de tus clientes de API es el navegador:

- `Rack::MethodOverride`
- `ActionDispatch::Cookies`
- `ActionDispatch::Flash`

Cualquiera de estos middlewares se puede agregar mediante:

```ruby
config.middleware.use Rack::MethodOverride
```

### Eliminando Middlewares

Si no deseas utilizar un middleware que está incluido de forma predeterminada en el conjunto de middlewares solo para API,
puedes eliminarlo con:
```ruby
config.middleware.delete ::Rack::Sendfile
```

Ten en cuenta que al eliminar estos middlewares se eliminará el soporte para ciertas características en Action Controller.

Elección de los módulos del controlador
---------------------------------------

Una aplicación de API (usando `ActionController::API`) viene con los siguientes módulos del controlador por defecto:

|   |   |
|---|---|
| `ActionController::UrlFor` | Hace que `url_for` y helpers similares estén disponibles. |
| `ActionController::Redirecting` | Soporte para `redirect_to`. |
| `AbstractController::Rendering` y `ActionController::ApiRendering` | Soporte básico para renderizar. |
| `ActionController::Renderers::All` | Soporte para `render :json` y amigos. |
| `ActionController::ConditionalGet` | Soporte para `stale?`. |
| `ActionController::BasicImplicitRender` | Asegura que se devuelva una respuesta vacía si no hay una explícita. |
| `ActionController::StrongParameters` | Soporte para filtrado de parámetros en combinación con la asignación masiva de Active Model. |
| `ActionController::DataStreaming` | Soporte para `send_file` y `send_data`. |
| `AbstractController::Callbacks` | Soporte para `before_action` y helpers similares. |
| `ActionController::Rescue` | Soporte para `rescue_from`. |
| `ActionController::Instrumentation` | Soporte para los ganchos de instrumentación definidos por Action Controller (ver [la guía de instrumentación](active_support_instrumentation.html#action-controller) para más información al respecto). |
| `ActionController::ParamsWrapper` | Envuelve el hash de parámetros en un hash anidado, de modo que no sea necesario especificar elementos raíz al enviar solicitudes POST, por ejemplo.
| `ActionController::Head` | Soporte para devolver una respuesta sin contenido, solo encabezados. |

Otros complementos pueden agregar módulos adicionales. Puedes obtener una lista de todos los módulos incluidos en `ActionController::API` en la consola de Rails:

```irb
irb> ActionController::API.ancestors - ActionController::Metal.ancestors
=> [ActionController::API,
    ActiveRecord::Railties::ControllerRuntime,
    ActionDispatch::Routing::RouteSet::MountedHelpers,
    ActionController::ParamsWrapper,
    ... ,
    AbstractController::Rendering,
    ActionView::ViewPaths]
```

### Agregar otros módulos

Todos los módulos de Action Controller conocen sus módulos dependientes, por lo que puedes incluir cualquier módulo en tus controladores y todas las dependencias se incluirán y configurarán también.

Algunos módulos comunes que es posible que desees agregar:

- `AbstractController::Translation`: Soporte para los métodos de localización y traducción `l` y `t`.
- Soporte para autenticación HTTP básica, de resumen o de token:
  * `ActionController::HttpAuthentication::Basic::ControllerMethods`
  * `ActionController::HttpAuthentication::Digest::ControllerMethods`
  * `ActionController::HttpAuthentication::Token::ControllerMethods`
- `ActionView::Layouts`: Soporte para diseños al renderizar.
- `ActionController::MimeResponds`: Soporte para `respond_to`.
- `ActionController::Cookies`: Soporte para `cookies`, que incluye soporte para cookies firmadas y encriptadas. Esto requiere el middleware de cookies.
- `ActionController::Caching`: Soporte para el almacenamiento en caché de vistas para el controlador de la API. Ten en cuenta que deberás especificar manualmente el almacén de caché dentro del controlador de esta manera:

    ```ruby
    class ApplicationController < ActionController::API
      include ::ActionController::Caching
      self.cache_store = :mem_cache_store
    end
    ```

    Rails *no* pasa esta configuración automáticamente.

El mejor lugar para agregar un módulo es en tu `ApplicationController`, pero también puedes agregar módulos a controladores individuales.
[`config.debug_exception_response_format`]: configuring.html#config-debug-exception-response-format
[`config.action_dispatch.x_sendfile_header`]: configuring.html#config-action-dispatch-x-sendfile-header
