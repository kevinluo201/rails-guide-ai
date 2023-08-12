**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 3529115f04b9d5fe01401105d9c154e2
Resumen de Action Controller
==========================

En esta guía, aprenderás cómo funcionan los controladores y cómo se integran en el ciclo de solicitud de tu aplicación.

Después de leer esta guía, sabrás cómo:

* Seguir el flujo de una solicitud a través de un controlador.
* Restringir los parámetros pasados a tu controlador.
* Almacenar datos en la sesión o cookies, y por qué.
* Trabajar con filtros para ejecutar código durante el procesamiento de la solicitud.
* Usar la autenticación HTTP integrada de Action Controller.
* Transmitir datos directamente al navegador del usuario.
* Filtrar parámetros sensibles para que no aparezcan en el registro de la aplicación.
* Manejar excepciones que puedan surgir durante el procesamiento de la solicitud.
* Usar el punto final de verificación de salud integrado para equilibradores de carga y monitores de tiempo de actividad.

--------------------------------------------------------------------------------

¿Qué hace un controlador?
--------------------------

Action Controller es la C en [MVC](https://en.wikipedia.org/wiki/Model%E2%80%93view%E2%80%93controller). Después de que el enrutador haya determinado qué controlador utilizar para una solicitud, el controlador es responsable de comprender la solicitud y producir la salida adecuada. Afortunadamente, Action Controller hace la mayor parte del trabajo por ti y utiliza convenciones inteligentes para que esto sea lo más sencillo posible.

Para la mayoría de las aplicaciones convencionales [RESTful](https://en.wikipedia.org/wiki/Representational_state_transfer), el controlador recibirá la solicitud (esto es invisible para ti como desarrollador), obtendrá o guardará datos de un modelo y usará una vista para crear la salida HTML. Si tu controlador necesita hacer las cosas de manera un poco diferente, no hay problema, esta es solo la forma más común en que funciona un controlador.

Por lo tanto, se puede pensar en un controlador como un intermediario entre modelos y vistas. Hace que los datos del modelo estén disponibles para la vista, para que pueda mostrar esos datos al usuario, y guarda o actualiza los datos del usuario en el modelo.

NOTA: Para obtener más detalles sobre el proceso de enrutamiento, consulta [Rails Routing from the Outside In](routing.html).

Convención de nomenclatura del controlador
----------------------------

La convención de nomenclatura de los controladores en Rails favorece la pluralización de la última palabra en el nombre del controlador, aunque no es estrictamente necesario (por ejemplo, `ApplicationController`). Por ejemplo, es preferible `ClientsController` a `ClientController`, `SiteAdminsController` a `SiteAdminController` o `SitesAdminsController`, y así sucesivamente.

Seguir esta convención te permitirá utilizar los generadores de rutas predeterminados (por ejemplo, `resources`, etc.) sin necesidad de calificar cada `:path` o `:controller`, y mantendrá el uso consistente de los ayudantes de rutas con nombre en toda tu aplicación. Consulta [Layouts and Rendering Guide](layouts_and_rendering.html) para obtener más detalles.

NOTA: La convención de nomenclatura del controlador difiere de la convención de nomenclatura de los modelos, que se espera que se nombren en forma singular.


Métodos y Acciones
-------------------

Un controlador es una clase Ruby que hereda de `ApplicationController` y tiene métodos como cualquier otra clase. Cuando tu aplicación recibe una solicitud, el enrutamiento determinará qué controlador y acción ejecutar, luego Rails creará una instancia de ese controlador y ejecutará el método con el mismo nombre que la acción.

```ruby
class ClientsController < ApplicationController
  def new
  end
end
```

Como ejemplo, si un usuario va a `/clients/new` en tu aplicación para agregar un nuevo cliente, Rails creará una instancia de `ClientsController` y llamará a su método `new`. Ten en cuenta que el método vacío del ejemplo anterior funcionaría perfectamente porque Rails, de forma predeterminada, renderizará la vista `new.html.erb` a menos que la acción indique lo contrario. Al crear un nuevo `Client`, el método `new` puede hacer que una variable de instancia `@client` sea accesible en la vista:

```ruby
def new
  @client = Client.new
end
```

La [Guía de Diseño y Renderizado](layouts_and_rendering.html) explica esto con más detalle.

`ApplicationController` hereda de [`ActionController::Base`][], que define varios métodos útiles. Esta guía cubrirá algunos de ellos, pero si tienes curiosidad por ver qué hay allí, puedes ver todos en la [documentación de la API](https://api.rubyonrails.org/classes/ActionController.html) o en el código fuente mismo.

Solo los métodos públicos se pueden llamar como acciones. Es una buena práctica reducir la visibilidad de los métodos (con `private` o `protected`) que no están destinados a ser acciones, como métodos auxiliares o filtros.

ADVERTENCIA: Algunos nombres de métodos están reservados por Action Controller. Redefinirlos accidentalmente como acciones, o incluso como métodos auxiliares, podría resultar en un `SystemStackError`. Si limitas tus controladores solo a acciones de enrutamiento de recursos RESTful, no deberías preocuparte por esto.

NOTA: Si debes usar un método reservado como nombre de acción, una solución alternativa es usar una ruta personalizada para asignar el nombre del método reservado a tu método de acción no reservado.
[Enrutamiento de recursos]: routing.html#resource-routing-the-rails-default

Parámetros
----------

Probablemente querrás acceder a los datos enviados por el usuario u otros parámetros en las acciones de tu controlador. Hay dos tipos de parámetros posibles en una aplicación web. El primero son los parámetros que se envían como parte de la URL, llamados parámetros de cadena de consulta. La cadena de consulta es todo lo que está después de "?" en la URL. El segundo tipo de parámetro se suele llamar datos POST. Esta información generalmente proviene de un formulario HTML que ha sido completado por el usuario. Se llama datos POST porque solo se pueden enviar como parte de una solicitud HTTP POST. Rails no hace ninguna distinción entre los parámetros de cadena de consulta y los parámetros POST, y ambos están disponibles en el hash [`params`][] en tu controlador:

```ruby
class ClientsController < ApplicationController
  # Esta acción utiliza parámetros de cadena de consulta porque se ejecuta
  # mediante una solicitud HTTP GET, pero esto no hace ninguna diferencia
  # en cómo se accede a los parámetros. La URL para
  # esta acción se vería así para listar clientes activados: /clients?status=activated
  def index
    if params[:status] == "activated"
      @clients = Client.activated
    else
      @clients = Client.inactivated
    end
  end

  # Esta acción utiliza parámetros POST. Es probable que provengan
  # de un formulario HTML que el usuario ha enviado. La URL para
  # esta solicitud RESTful será "/clients", y los datos se enviarán
  # como parte del cuerpo de la solicitud.
  def create
    @client = Client.new(params[:client])
    if @client.save
      redirect_to @client
    else
      # Esta línea anula el comportamiento de renderizado predeterminado, que
      # habría sido renderizar la vista "create".
      render "new"
    end
  end
end
```


### Parámetros de hash y array

El hash `params` no se limita a claves y valores unidimensionales. Puede contener matrices y hashes anidados. Para enviar una matriz de valores, agrega un par de corchetes vacíos "[]" al nombre de la clave:

```
GET /clients?ids[]=1&ids[]=2&ids[]=3
```

NOTA: La URL real en este ejemplo se codificará como "/clients?ids%5b%5d=1&ids%5b%5d=2&ids%5b%5d=3" ya que los caracteres "[" y "]" no están permitidos en las URL. La mayoría de las veces no tienes que preocuparte por esto porque el navegador lo codificará por ti, y Rails lo decodificará automáticamente, pero si alguna vez te encuentras teniendo que enviar esas solicitudes al servidor manualmente, debes tener esto en cuenta.

El valor de `params[:ids]` ahora será `["1", "2", "3"]`. Ten en cuenta que los valores de los parámetros siempre son cadenas; Rails no intenta adivinar ni convertir el tipo.

NOTA: Los valores como `[nil]` o `[nil, nil, ...]` en `params` se reemplazan
por `[]` por razones de seguridad de forma predeterminada. Consulta la [Guía de seguridad](security.html#unsafe-query-generation)
para obtener más información.

Para enviar un hash, incluye el nombre de la clave dentro de los corchetes:

```html
<form accept-charset="UTF-8" action="/clients" method="post">
  <input type="text" name="client[name]" value="Acme" />
  <input type="text" name="client[phone]" value="12345" />
  <input type="text" name="client[address][postcode]" value="12345" />
  <input type="text" name="client[address][city]" value="Carrot City" />
</form>
```

Cuando se envía este formulario, el valor de `params[:client]` será `{ "name" => "Acme", "phone" => "12345", "address" => { "postcode" => "12345", "city" => "Carrot City" } }`. Observa el hash anidado en `params[:client][:address]`.

El objeto `params` actúa como un Hash, pero te permite usar símbolos y cadenas indistintamente como claves.

### Parámetros JSON

Si tu aplicación expone una API, es probable que aceptes parámetros en formato JSON. Si el encabezado "Content-Type" de tu solicitud está configurado como "application/json", Rails cargará automáticamente tus parámetros en el hash `params`, al que puedes acceder como lo harías normalmente.

Entonces, por ejemplo, si estás enviando este contenido JSON:

```json
{ "company": { "name": "acme", "address": "123 Carrot Street" } }
```

Tu controlador recibirá `params[:company]` como `{ "name" => "acme", "address" => "123 Carrot Street" }`.

Además, si has activado `config.wrap_parameters` en tu inicializador o has llamado a [`wrap_parameters`][] en tu controlador, puedes omitir de forma segura el elemento raíz en el parámetro JSON. En este caso, los parámetros se clonarán y se envolverán con una clave elegida en función del nombre de tu controlador. Entonces, la solicitud JSON anterior se puede escribir como:

```json
{ "name": "acme", "address": "123 Carrot Street" }
```

Y, suponiendo que estás enviando los datos a `CompaniesController`, entonces se envolverá dentro de la clave `:company` de esta manera:
```ruby
{ name: "acme", address: "123 Carrot Street", company: { name: "acme", address: "123 Carrot Street" } }
```

Puede personalizar el nombre de la clave o los parámetros específicos que desea envolver consultando la [documentación de la API](https://api.rubyonrails.org/classes/ActionController/ParamsWrapper.html)

NOTA: El soporte para analizar parámetros XML se ha extraído en una gema llamada `actionpack-xml_parser`.


### Parámetros de enrutamiento

El hash `params` siempre contendrá las claves `:controller` y `:action`, pero debe usar los métodos [`controller_name`][] y [`action_name`][] en su lugar para acceder a estos valores. Cualquier otro parámetro definido por el enrutamiento, como `:id`, también estará disponible. Como ejemplo, considere una lista de clientes donde la lista puede mostrar clientes activos o inactivos. Podemos agregar una ruta que capture el parámetro `:status` en una URL "bonita":

```ruby
get '/clients/:status', to: 'clients#index', foo: 'bar'
```

En este caso, cuando un usuario abre la URL `/clients/active`, `params[:status]` se establecerá en "active". Cuando se utiliza esta ruta, `params[:foo]` también se establecerá en "bar", como si se pasara en la cadena de consulta. Su controlador también recibirá `params[:action]` como "index" y `params[:controller]` como "clients".


### `default_url_options`

Puede establecer parámetros predeterminados globales para la generación de URL definiendo un método llamado `default_url_options` en su controlador. Este método debe devolver un hash con los valores predeterminados deseados, cuyas claves deben ser símbolos:

```ruby
class ApplicationController < ActionController::Base
  def default_url_options
    { locale: I18n.locale }
  end
end
```

Estas opciones se utilizarán como punto de partida al generar URL, por lo que es posible que sean reemplazadas por las opciones pasadas a las llamadas de `url_for`.

Si define `default_url_options` en `ApplicationController`, como en el ejemplo anterior, estos valores predeterminados se utilizarán para toda la generación de URL. El método también se puede definir en un controlador específico, en cuyo caso solo afectará a las URL generadas allí.

En una solicitud determinada, el método no se llama realmente para cada URL generada. Por razones de rendimiento, el hash devuelto se almacena en caché y hay como máximo una invocación por solicitud.

### Parámetros fuertes

Con los parámetros fuertes, los parámetros del controlador de acciones están prohibidos para su uso en asignaciones masivas de Active Model hasta que se les haya permitido. Esto significa que deberá tomar una decisión consciente sobre qué atributos permitir para la actualización masiva. Esta es una mejor práctica de seguridad para evitar permitir accidentalmente que los usuarios actualicen atributos sensibles del modelo.

Además, los parámetros se pueden marcar como requeridos y fluirán a través de un flujo de excepción predefinido que resultará en un error 400 Bad Request si no se pasan todos los parámetros requeridos.

```ruby
class PeopleController < ActionController::Base
  # Esto generará una excepción ActiveModel::ForbiddenAttributesError
  # porque está utilizando una asignación masiva sin un paso de permiso explícito.
  def create
    Person.create(params[:person])
  end

  # Esto pasará sin problemas siempre que haya una clave de persona
  # en los parámetros, de lo contrario, generará una excepción
  # ActionController::ParameterMissing, que será capturada por ActionController::Base y convertida en un error 400 Bad Request.
  def update
    person = current_account.people.find(params[:id])
    person.update!(person_params)
    redirect_to person
  end

  private
    # Usar un método privado para encapsular los parámetros permitidos
    # es una buena práctica, ya que podrá reutilizar la misma lista de permisos entre create y update. Además, puede especializar
    # este método con la verificación de atributos permitidos por usuario.
    def person_params
      params.require(:person).permit(:name, :age)
    end
end
```

#### Valores escalares permitidos

Llamar a [`permit`][] de la siguiente manera:

```ruby
params.permit(:id)
```

permite la clave especificada (`:id`) para su inclusión si aparece en `params` y
tiene un valor escalar permitido asociado. De lo contrario, la clave se filtrará, por lo que no se pueden inyectar matrices, hashes u otros objetos.

Los tipos escalares permitidos son `String`, `Symbol`, `NilClass`,
`Numeric`, `TrueClass`, `FalseClass`, `Date`, `Time`, `DateTime`,
`StringIO`, `IO`, `ActionDispatch::Http::UploadedFile` y
`Rack::Test::UploadedFile`.

Para declarar que el valor en `params` debe ser una matriz de valores escalares permitidos, mapee la clave a una matriz vacía:

```ruby
params.permit(id: [])
```

A veces no es posible o conveniente declarar las claves válidas de
un parámetro hash o su estructura interna. Simplemente mapee a un hash vacío:

```ruby
params.permit(preferences: {})
```

pero tenga cuidado porque esto abre la puerta a una entrada arbitraria. En este
caso, `permit` asegura que los valores en la estructura devuelta sean escalares permitidos y filtra cualquier otra cosa.
Para permitir un hash completo de parámetros, se puede utilizar el método [`permit!`][]:

```ruby
params.require(:log_entry).permit!
```

Esto marca el hash de parámetros `:log_entry` y cualquier sub-hash como permitido y no verifica los escalares permitidos, se acepta cualquier cosa. Se debe tener mucho cuidado al usar `permit!`, ya que permitirá asignar en masa todos los atributos del modelo actuales y futuros.


#### Parámetros anidados

También se puede utilizar `permit` en parámetros anidados, como:

```ruby
params.permit(:name, { emails: [] },
              friends: [ :name,
                         { family: [ :name ], hobbies: [] }])
```

Esta declaración permite los atributos `name`, `emails` y `friends`. Se espera que `emails` sea una matriz de valores escalares permitidos, y que `friends` sea una matriz de recursos con atributos específicos: deben tener un atributo `name` (se permiten cualquier valor escalar permitido), un atributo `hobbies` como una matriz de valores escalares permitidos, y un atributo `family` que está restringido a tener un atributo `name` (aquí también se permiten cualquier valor escalar permitido).

#### Más ejemplos

También puedes usar los atributos permitidos en tu acción `new`. Esto plantea el problema de que no puedes usar [`require`][] en la clave raíz porque, normalmente, no existe cuando se llama a `new`:

```ruby
# usando `fetch` puedes proporcionar un valor predeterminado y usar
# la API de Strong Parameters desde allí.
params.fetch(:blog, {}).permit(:title, :author)
```

El método de clase del modelo `accepts_nested_attributes_for` te permite actualizar y eliminar registros asociados. Esto se basa en los parámetros `id` y `_destroy`:

```ruby
# permitir :id y :_destroy
params.require(:author).permit(:name, books_attributes: [:title, :id, :_destroy])
```

Los hashes con claves enteras se tratan de manera diferente, y puedes declarar los atributos como si fueran hijos directos. Obtienes este tipo de parámetros cuando usas `accepts_nested_attributes_for` en combinación con una asociación `has_many`:

```ruby
# Para permitir los siguientes datos:
# {"book" => {"title" => "Some Book",
#             "chapters_attributes" => { "1" => {"title" => "First Chapter"},
#                                        "2" => {"title" => "Second Chapter"}}}}

params.require(:book).permit(:title, chapters_attributes: [:title])
```

Imagina un escenario en el que tienes parámetros que representan el nombre de un producto, y un hash de datos arbitrarios asociados con ese producto, y quieres permitir el atributo de nombre del producto y también el hash completo de datos:

```ruby
def product_params
  params.require(:product).permit(:name, data: {})
end
```


#### Fuera del alcance de Strong Parameters

La API de strong parameters fue diseñada teniendo en cuenta los casos de uso más comunes. No pretende ser una solución universal para todos tus problemas de filtrado de parámetros. Sin embargo, puedes mezclar fácilmente la API con tu propio código para adaptarlo a tu situación.

Sesión
-------

Tu aplicación tiene una sesión para cada usuario en la que puedes almacenar pequeñas cantidades de datos que se persistirán entre las solicitudes. La sesión solo está disponible en el controlador y la vista y puede utilizar uno de varios mecanismos de almacenamiento diferentes:

* [`ActionDispatch::Session::CookieStore`][] - Almacena todo en el cliente.
* [`ActionDispatch::Session::CacheStore`][] - Almacena los datos en la caché de Rails.
* [`ActionDispatch::Session::MemCacheStore`][] - Almacena los datos en un clúster de memcached (esta es una implementación heredada; considera usar `CacheStore` en su lugar).
* [`ActionDispatch::Session::ActiveRecordStore`][activerecord-session_store] -
  Almacena los datos en una base de datos utilizando Active Record (requiere la gema [`activerecord-session_store`][activerecord-session_store])
* Un almacenamiento personalizado o un almacenamiento proporcionado por una gema de terceros

Todas las tiendas de sesión utilizan una cookie para almacenar un ID único para cada sesión (debes usar una cookie, Rails no te permitirá pasar el ID de sesión en la URL ya que esto es menos seguro).

Para la mayoría de las tiendas, este ID se utiliza para buscar los datos de la sesión en el servidor, por ejemplo, en una tabla de base de datos. Hay una excepción, y es la tienda de sesión predeterminada y recomendada: la CookieStore, que almacena todos los datos de sesión en la propia cookie (el ID aún está disponible si lo necesitas). Esto tiene la ventaja de ser muy liviano y no requiere ninguna configuración en una nueva aplicación para usar la sesión. Los datos de la cookie están firmados criptográficamente para que no se puedan manipular. Y también están encriptados para que nadie con acceso a ellos pueda leer su contenido (Rails no lo aceptará si ha sido editado).

La CookieStore puede almacenar alrededor de 4 kB de datos, mucho menos que las demás, pero esto suele ser suficiente. Se desaconseja almacenar grandes cantidades de datos en la sesión, independientemente de la tienda de sesión que utilice tu aplicación. Debes evitar especialmente almacenar objetos complejos (como instancias de modelos) en la sesión, ya que el servidor puede no poder volver a ensamblarlos entre solicitudes, lo que provocará un error.
Si las sesiones de usuario no almacenan datos críticos o no necesitan estar disponibles durante largos períodos (por ejemplo, si solo se utiliza el flash para mensajes), puedes considerar el uso de `ActionDispatch::Session::CacheStore`. Esto almacenará las sesiones utilizando la implementación de caché que hayas configurado para tu aplicación. La ventaja de esto es que puedes utilizar tu infraestructura de caché existente para almacenar las sesiones sin necesidad de realizar ninguna configuración o administración adicional. La desventaja, por supuesto, es que las sesiones serán efímeras y podrían desaparecer en cualquier momento.

Lee más sobre el almacenamiento de sesiones en la [Guía de Seguridad](security.html).

Si necesitas un mecanismo de almacenamiento de sesiones diferente, puedes cambiarlo en un inicializador:

```ruby
Rails.application.config.session_store :cache_store
```

Consulta [`config.session_store`](configuring.html#config-session-store) en la guía de configuración para obtener más información.

Rails configura una clave de sesión (el nombre de la cookie) al firmar los datos de la sesión. También puedes cambiar esto en un inicializador:

```ruby
# Asegúrate de reiniciar tu servidor cuando modifiques este archivo.
Rails.application.config.session_store :cookie_store, key: '_your_app_session'
```

También puedes pasar una clave `:domain` y especificar el nombre de dominio para la cookie:

```ruby
# Asegúrate de reiniciar tu servidor cuando modifiques este archivo.
Rails.application.config.session_store :cookie_store, key: '_your_app_session', domain: ".example.com"
```

Rails configura (para CookieStore) una clave secreta utilizada para firmar los datos de la sesión en `config/credentials.yml.enc`. Esto se puede cambiar con `bin/rails credentials:edit`.

```yaml
# aws:
#   access_key_id: 123
#   secret_access_key: 345

# Se utiliza como secreto base para todos los MessageVerifiers en Rails, incluido el que protege las cookies.
secret_key_base: 492f...
```

NOTA: Cambiar la secret_key_base cuando se utiliza `CookieStore` invalidará todas las sesiones existentes.



### Acceso a la sesión

En tu controlador, puedes acceder a la sesión a través del método de instancia `session`.

NOTA: Las sesiones se cargan de forma perezosa. Si no accedes a las sesiones en el código de tu acción, no se cargarán. Por lo tanto, nunca necesitarás deshabilitar las sesiones, simplemente no acceder a ellas hará el trabajo.

Los valores de la sesión se almacenan utilizando pares clave/valor como un hash:

```ruby
class ApplicationController < ActionController::Base
  private
    # Encuentra al usuario con el ID almacenado en la sesión con la clave
    # :current_user_id. Esta es una forma común de manejar el inicio de sesión de usuario en
    # una aplicación de Rails; iniciar sesión establece el valor de la sesión y
    # cerrar sesión lo elimina.
    def current_user
      @_current_user ||= session[:current_user_id] &&
        User.find_by(id: session[:current_user_id])
    end
end
```

Para almacenar algo en la sesión, simplemente asígnalo a la clave como un hash:

```ruby
class LoginsController < ApplicationController
  # "Crear" un inicio de sesión, también conocido como "iniciar sesión del usuario"
  def create
    if user = User.authenticate(params[:username], params[:password])
      # Guarda el ID del usuario en la sesión para que se pueda utilizar en
      # solicitudes posteriores
      session[:current_user_id] = user.id
      redirect_to root_url
    end
  end
end
```

Para eliminar algo de la sesión, elimina el par clave/valor:

```ruby
class LoginsController < ApplicationController
  # "Eliminar" un inicio de sesión, también conocido como "cerrar sesión del usuario"
  def destroy
    # Elimina el ID del usuario de la sesión
    session.delete(:current_user_id)
    # Borra el usuario actual memoizado
    @_current_user = nil
    redirect_to root_url, status: :see_other
  end
end
```

Para restablecer toda la sesión, utiliza [`reset_session`][].


### El Flash

El flash es una parte especial de la sesión que se borra con cada solicitud. Esto significa que los valores almacenados allí solo estarán disponibles en la siguiente solicitud, lo cual es útil para pasar mensajes de error, etc.

El flash se accede a través del método [`flash`][]. Al igual que la sesión, el flash se representa como un hash.

Utilicemos el acto de cerrar sesión como ejemplo. El controlador puede enviar un mensaje que se mostrará al usuario en la siguiente solicitud:

```ruby
class LoginsController < ApplicationController
  def destroy
    session.delete(:current_user_id)
    flash[:notice] = "Has cerrado sesión correctamente."
    redirect_to root_url, status: :see_other
  end
end
```

Ten en cuenta que también es posible asignar un mensaje flash como parte de la redirección. Puedes asignar `:notice`, `:alert` o el `:flash` de propósito general:

```ruby
redirect_to root_url, notice: "Has cerrado sesión correctamente."
redirect_to root_url, alert: "¡Estás atrapado aquí!"
redirect_to root_url, flash: { referral_code: 1234 }
```

La acción `destroy` redirige a la `root_url` de la aplicación, donde se mostrará el mensaje. Ten en cuenta que depende por completo de la siguiente acción decidir qué, si algo, hará con lo que la acción anterior puso en el flash. Es convencional mostrar cualquier alerta de error o aviso del flash en el diseño de la aplicación.
```erb
<html>
  <!-- <head/> -->
  <body>
    <% flash.each do |name, msg| -%>
      <%= content_tag :div, msg, class: name %>
    <% end -%>

    <!-- más contenido -->
  </body>
</html>
```

De esta manera, si una acción establece un mensaje de aviso o alerta, el diseño lo mostrará automáticamente.

Puedes pasar cualquier cosa que la sesión pueda almacenar; no estás limitado a avisos y alertas:

```erb
<% if flash[:just_signed_up] %>
  <p class="welcome">¡Bienvenido a nuestro sitio!</p>
<% end %>
```

Si deseas que un valor flash se mantenga en otra solicitud, utiliza [`flash.keep`][]:

```ruby
class MainController < ApplicationController
  # Digamos que esta acción corresponde a root_url, pero quieres
  # que todas las solicitudes aquí se redirijan a UsersController#index.
  # Si una acción establece el flash y se redirige aquí, los valores
  # normalmente se perderían cuando ocurre otra redirección, pero puedes
  # usar 'keep' para que persista para otra solicitud.
  def index
    # Mantendrá todos los valores flash.
    flash.keep

    # También puedes usar una clave para mantener solo un tipo de valor.
    # flash.keep(:notice)
    redirect_to users_url
  end
end
```


#### `flash.now`

De forma predeterminada, agregar valores al flash los hará disponibles para la siguiente solicitud, pero a veces es posible que desees acceder a esos valores en la misma solicitud. Por ejemplo, si la acción `create` no puede guardar un recurso y renderizas directamente la plantilla `new`, eso no resultará en una nueva solicitud, pero es posible que aún desees mostrar un mensaje utilizando el flash. Para hacer esto, puedes usar [`flash.now`][] de la misma manera que usas el flash normal:

```ruby
class ClientsController < ApplicationController
  def create
    @client = Client.new(client_params)
    if @client.save
      # ...
    else
      flash.now[:error] = "No se pudo guardar el cliente"
      render action: "new"
    end
  end
end
```


Cookies
-------

Tu aplicación puede almacenar pequeñas cantidades de datos en el cliente, llamados cookies, que se persistirán en las solicitudes e incluso en las sesiones. Rails proporciona un acceso fácil a las cookies a través del método [`cookies`][], que, al igual que la `session`, funciona como un hash:

```ruby
class CommentsController < ApplicationController
  def new
    # Rellena automáticamente el nombre del comentarista si se ha almacenado en una cookie
    @comment = Comment.new(author: cookies[:commenter_name])
  end

  def create
    @comment = Comment.new(comment_params)
    if @comment.save
      flash[:notice] = "¡Gracias por tu comentario!"
      if params[:remember_name]
        # Recuerda el nombre del comentarista.
        cookies[:commenter_name] = @comment.author
      else
        # Elimina la cookie del nombre del comentarista, si existe.
        cookies.delete(:commenter_name)
      end
      redirect_to @comment.article
    else
      render action: "new"
    end
  end
end
```

Ten en cuenta que, si bien para los valores de sesión puedes establecer la clave en `nil`, para eliminar un valor de cookie debes usar `cookies.delete(:key)`.

Rails también proporciona un tarro de cookies firmado y un tarro de cookies cifrado para almacenar datos sensibles. El tarro de cookies firmado agrega una firma criptográfica a los valores de las cookies para proteger su integridad. El tarro de cookies cifrado cifra los valores además de firmarlos, de modo que no pueden ser leídos por el usuario final. Consulta la [documentación de la API](https://api.rubyonrails.org/classes/ActionDispatch/Cookies.html) para obtener más detalles.

Estos tarros de cookies especiales utilizan un serializador para serializar los valores asignados en cadenas y deserializarlos en objetos Ruby al leerlos. Puedes especificar qué serializador usar a través de [`config.action_dispatch.cookies_serializer`][].

El serializador predeterminado para nuevas aplicaciones es `:json`. Ten en cuenta que JSON tiene un soporte limitado para objetos Ruby. Por ejemplo, los objetos `Date`, `Time` y `Symbol` (incluidas las claves de `Hash`) se serializarán y deserializarán en `String`s:

```ruby
class CookiesController < ApplicationController
  def set_cookie
    cookies.encrypted[:expiration_date] = Date.tomorrow # => Thu, 20 Mar 2014
    redirect_to action: 'read_cookie'
  end

  def read_cookie
    cookies.encrypted[:expiration_date] # => "2014-03-20"
  end
end
```

Si necesitas almacenar estos u objetos más complejos, es posible que debas convertir manualmente sus valores al leerlos en solicitudes posteriores.

Si utilizas el almacenamiento de sesión en cookies, lo anterior también se aplica al hash `session` y `flash`.


Renderizado
---------

ActionController hace que el renderizado de datos HTML, XML o JSON sea sencillo. Si has generado un controlador utilizando el andamiaje, se vería algo así:

```ruby
class UsersController < ApplicationController
  def index
    @users = User.all
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render xml: @users }
      format.json { render json: @users }
    end
  end
end
```

Puedes notar en el código anterior que estamos usando `render xml: @users`, no `render xml: @users.to_xml`. Si el objeto no es una cadena, Rails automáticamente invocará `to_xml` por nosotros.
Puedes obtener más información sobre la representación en la [Guía de Diseños y Representación](layouts_and_rendering.html).

Filtros
-------

Los filtros son métodos que se ejecutan "antes", "después" o "alrededor" de una acción del controlador.

Los filtros se heredan, por lo que si estableces un filtro en `ApplicationController`, se ejecutará en cada controlador de tu aplicación.

Los filtros "antes" se registran a través de [`before_action`][]. Pueden detener el ciclo de solicitud. Un filtro "antes" común es aquel que requiere que un usuario haya iniciado sesión para que se ejecute una acción. Puedes definir el método del filtro de esta manera:

```ruby
class ApplicationController < ActionController::Base
  before_action :require_login

  private
    def require_login
      unless logged_in?
        flash[:error] = "Debes iniciar sesión para acceder a esta sección"
        redirect_to new_login_url # detiene el ciclo de solicitud
      end
    end
end
```

El método simplemente almacena un mensaje de error en el flash y redirige al formulario de inicio de sesión si el usuario no ha iniciado sesión. Si un filtro "antes" representa o redirige, la acción no se ejecutará. Si hay filtros adicionales programados para ejecutarse después de ese filtro, también se cancelarán.

En este ejemplo, el filtro se agrega a `ApplicationController` y, por lo tanto, todos los controladores de la aplicación lo heredan. Esto hará que todo en la aplicación requiera que el usuario haya iniciado sesión para usarlo. Por razones obvias (¡el usuario no podría iniciar sesión en primer lugar!), no todos los controladores o acciones deben requerir esto. Puedes evitar que este filtro se ejecute antes de acciones particulares con [`skip_before_action`][]:

```ruby
class LoginsController < ApplicationController
  skip_before_action :require_login, only: [:new, :create]
end
```

Ahora, las acciones `new` y `create` del `LoginsController` funcionarán como antes sin requerir que el usuario haya iniciado sesión. La opción `:only` se utiliza para omitir este filtro solo para estas acciones, y también hay una opción `:except` que funciona de manera opuesta. Estas opciones también se pueden usar al agregar filtros, por lo que puedes agregar un filtro que solo se ejecute para acciones seleccionadas en primer lugar.

NOTA: Llamar al mismo filtro varias veces con diferentes opciones no funcionará, ya que la última definición del filtro sobrescribirá las anteriores.


### Filtros Después y Filtros Alrededor

Además de los filtros "antes", también puedes ejecutar filtros después de que se haya ejecutado una acción, o tanto antes como después.

Los filtros "después" se registran a través de [`after_action`][]. Son similares a los filtros "antes", pero debido a que la acción ya se ha ejecutado, tienen acceso a los datos de respuesta que se enviarán al cliente. Obviamente, los filtros "después" no pueden detener la ejecución de la acción. Ten en cuenta que los filtros "después" se ejecutan solo después de una acción exitosa, pero no cuando se produce una excepción en el ciclo de solicitud.

Los filtros "alrededor" se registran a través de [`around_action`][]. Son responsables de ejecutar sus acciones asociadas mediante la entrega, similar a cómo funcionan los middlewares de Rack.

Por ejemplo, en un sitio web donde los cambios tienen un flujo de aprobación, un administrador podría previsualizarlos fácilmente aplicándolos dentro de una transacción:

```ruby
class ChangesController < ApplicationController
  around_action :wrap_in_transaction, only: :show

  private
    def wrap_in_transaction
      ActiveRecord::Base.transaction do
        begin
          yield
        ensure
          raise ActiveRecord::Rollback
        end
      end
    end
end
```

Ten en cuenta que un filtro "alrededor" también envuelve la representación. En particular, en el ejemplo anterior, si la vista misma lee desde la base de datos (por ejemplo, a través de un ámbito), lo hará dentro de la transacción y, por lo tanto, presentará los datos para previsualizar.

Puedes optar por no entregar y construir la respuesta tú mismo, en cuyo caso la acción no se ejecutará.


### Otras Formas de Usar Filtros

Si bien la forma más común de usar filtros es creando métodos privados y utilizando `before_action`, `after_action` o `around_action` para agregarlos, hay otras dos formas de hacer lo mismo.

La primera es utilizar un bloque directamente con los métodos `*_action`. El bloque recibe el controlador como argumento. El filtro `require_login` de arriba se podría reescribir para usar un bloque:

```ruby
class ApplicationController < ActionController::Base
  before_action do |controller|
    unless controller.send(:logged_in?)
      flash[:error] = "Debes iniciar sesión para acceder a esta sección"
      redirect_to new_login_url
    end
  end
end
```

Ten en cuenta que el filtro, en este caso, utiliza `send` porque el método `logged_in?` es privado y el filtro no se ejecuta en el ámbito del controlador. Esta no es la forma recomendada de implementar este filtro en particular, pero en casos más simples, podría ser útil.
Específicamente para `around_action`, el bloque también se ejecuta en la `action`:

```ruby
around_action { |_controller, action| time(&action) }
```

La segunda forma es usar una clase (en realidad, cualquier objeto que responda a los métodos correctos servirá) para manejar el filtrado. Esto es útil en casos más complejos que no se pueden implementar de manera legible y reutilizable utilizando los otros dos métodos. Como ejemplo, podrías reescribir el filtro de inicio de sesión nuevamente para usar una clase:

```ruby
class ApplicationController < ActionController::Base
  before_action LoginFilter
end

class LoginFilter
  def self.before(controller)
    unless controller.send(:logged_in?)
      controller.flash[:error] = "Debes iniciar sesión para acceder a esta sección"
      controller.redirect_to controller.new_login_url
    end
  end
end
```

Nuevamente, este no es un ejemplo ideal para este filtro, porque no se ejecuta en el ámbito del controlador, sino que se pasa el controlador como argumento. La clase del filtro debe implementar un método con el mismo nombre que el filtro, por lo que para el filtro `before_action`, la clase debe implementar un método `before`, y así sucesivamente. El método `around` debe `yield` para ejecutar la acción.

Protección contra falsificación de solicitudes
-----------------------------------------------

La falsificación de solicitudes entre sitios es un tipo de ataque en el que un sitio engaña a un usuario para que realice solicitudes en otro sitio, posiblemente agregando, modificando o eliminando datos en ese sitio sin el conocimiento o permiso del usuario.

El primer paso para evitar esto es asegurarse de que todas las acciones "destructivas" (crear, actualizar y eliminar) solo se puedan acceder con solicitudes que no sean GET. Si sigues las convenciones RESTful, ya estás haciendo esto. Sin embargo, un sitio malintencionado aún puede enviar fácilmente una solicitud que no sea GET a tu sitio, y ahí es donde entra en juego la protección contra falsificación de solicitudes. Como su nombre lo indica, protege contra solicitudes falsificadas.

La forma en que se hace esto es agregar un token no adivinable que solo es conocido por tu servidor a cada solicitud. De esta manera, si llega una solicitud sin el token adecuado, se le denegará el acceso.

Si generas un formulario de esta manera:

```erb
<%= form_with model: @user do |form| %>
  <%= form.text_field :username %>
  <%= form.text_field :password %>
<% end %>
```

Verás cómo se agrega el token como un campo oculto:

```html
<form accept-charset="UTF-8" action="/users/1" method="post">
<input type="hidden"
       value="67250ab105eb5ad10851c00a5621854a23af5489"
       name="authenticity_token"/>
<!-- campos -->
</form>
```

Rails agrega este token a cada formulario que se genera utilizando los [helpers de formulario](form_helpers.html), por lo que la mayoría de las veces no tienes que preocuparte por ello. Si estás escribiendo un formulario manualmente o necesitas agregar el token por alguna otra razón, está disponible a través del método `form_authenticity_token`:

El `form_authenticity_token` genera un token de autenticación válido. Esto es útil en lugares donde Rails no lo agrega automáticamente, como en llamadas Ajax personalizadas.

La [Guía de seguridad](security.html) tiene más información al respecto, y muchos otros problemas relacionados con la seguridad de los que debes tener en cuenta al desarrollar una aplicación web.

Los objetos de solicitud y respuesta
-----------------------------------

En cada controlador, hay dos métodos de acceso que apuntan a los objetos de solicitud y respuesta asociados con el ciclo de solicitud que se está ejecutando actualmente. El método [`request`][] contiene una instancia de [`ActionDispatch::Request`][] y el método [`response`][] devuelve un objeto de respuesta que representa lo que se enviará de vuelta al cliente.


### El objeto `request`

El objeto de solicitud contiene mucha información útil sobre la solicitud que proviene del cliente. Para obtener una lista completa de los métodos disponibles, consulta la [documentación de la API de Rails](https://api.rubyonrails.org/classes/ActionDispatch/Request.html) y la [documentación de Rack](https://www.rubydoc.info/github/rack/rack/Rack/Request). Entre las propiedades a las que puedes acceder en este objeto se encuentran:

| Propiedad de `request`                     | Propósito                                                                          |
| ----------------------------------------- | -------------------------------------------------------------------------------- |
| `host`                                    | El nombre de host utilizado para esta solicitud.                                              |
| `domain(n=2)`                             | Los primeros `n` segmentos del nombre de host, comenzando desde la derecha (el TLD).            |
| `format`                                  | El tipo de contenido solicitado por el cliente.                                        |
| `method`                                  | El método HTTP utilizado para la solicitud.                                            |
| `get?`, `post?`, `patch?`, `put?`, `delete?`, `head?` | Devuelve true si el método HTTP es GET/POST/PATCH/PUT/DELETE/HEAD.   |
| `headers`                                 | Devuelve un hash que contiene los encabezados asociados con la solicitud.               |
| `port`                                    | El número de puerto (entero) utilizado para la solicitud.                                  |
| `protocol`                                | Devuelve una cadena que contiene el protocolo utilizado más "://", por ejemplo "http://". |
| `query_string`                            | La parte de la cadena de consulta de la URL, es decir, todo después de "?".                    |
| `remote_ip`                               | La dirección IP del cliente.                                                    |
| `url`                                     | La URL completa utilizada para la solicitud.                                             |
#### `path_parameters`, `query_parameters` y `request_parameters`

Rails recopila todos los parámetros enviados junto con la solicitud en el hash `params`, ya sea que se envíen como parte de la cadena de consulta o del cuerpo de la publicación. El objeto de solicitud tiene tres accesores que le brindan acceso a estos parámetros según de dónde provengan. El hash [`query_parameters`][] contiene los parámetros que se enviaron como parte de la cadena de consulta, mientras que el hash [`request_parameters`][] contiene los parámetros enviados como parte del cuerpo de la publicación. El hash [`path_parameters`][] contiene los parámetros que fueron reconocidos por el enrutamiento como parte de la ruta que conduce a este controlador y acción en particular.


### El objeto `response`

El objeto de respuesta no se usa normalmente directamente, pero se construye durante la ejecución de la acción y la representación de los datos que se envían de vuelta al usuario, pero a veces, como en un filtro posterior, puede ser útil acceder directamente a la respuesta. Algunos de estos métodos de acceso también tienen setters, lo que le permite cambiar sus valores. Para obtener una lista completa de los métodos disponibles, consulte la [documentación de la API de Rails](https://api.rubyonrails.org/classes/ActionDispatch/Response.html) y la [documentación de Rack](https://www.rubydoc.info/github/rack/rack/Rack/Response).

| Propiedad de `response` | Propósito                                                                                           |
| ---------------------- | --------------------------------------------------------------------------------------------------- |
| `body`                 | Esta es la cadena de datos que se envía de vuelta al cliente. Esto suele ser HTML.                  |
| `status`               | El código de estado HTTP de la respuesta, como 200 para una solicitud exitosa o 404 para archivo no encontrado. |
| `location`             | La URL a la que se está redirigiendo el cliente, si corresponde.                                     |
| `content_type`         | El tipo de contenido de la respuesta.                                                               |
| `charset`              | El conjunto de caracteres que se utiliza para la respuesta. El valor predeterminado es "utf-8".     |
| `headers`              | Encabezados utilizados para la respuesta.                                                           |

#### Configuración de encabezados personalizados

Si desea establecer encabezados personalizados para una respuesta, `response.headers` es el lugar para hacerlo. El atributo de encabezados es un hash que asigna nombres de encabezado a sus valores, y Rails establecerá algunos de ellos automáticamente. Si desea agregar o cambiar un encabezado, simplemente asígnelo a `response.headers` de esta manera:

```ruby
response.headers["Content-Type"] = "application/pdf"
```

NOTA: En el caso anterior, tendría más sentido usar directamente el setter `content_type`.

Autenticaciones HTTP
--------------------

Rails viene con tres mecanismos de autenticación HTTP integrados:

* Autenticación básica
* Autenticación digest
* Autenticación de token

### Autenticación básica HTTP

La autenticación básica HTTP es un esquema de autenticación que es compatible con la mayoría de los navegadores y otros clientes HTTP. Como ejemplo, considere una sección de administración que solo estará disponible ingresando un nombre de usuario y una contraseña en la ventana de diálogo básica de HTTP del navegador. El uso de la autenticación incorporada solo requiere que utilice un método, [`http_basic_authenticate_with`][].

```ruby
class AdminsController < ApplicationController
  http_basic_authenticate_with name: "humbaba", password: "5baa61e4"
end
```

Con esto en su lugar, puede crear controladores con espacios de nombres que hereden de `AdminsController`. El filtro se ejecutará para todas las acciones en esos controladores, protegiéndolos con autenticación básica HTTP.


### Autenticación digest HTTP

La autenticación digest HTTP es superior a la autenticación básica ya que no requiere que el cliente envíe una contraseña sin cifrar a través de la red (aunque la autenticación básica HTTP es segura a través de HTTPS). El uso de la autenticación digest con Rails solo requiere el uso de un método, [`authenticate_or_request_with_http_digest`][].

```ruby
class AdminsController < ApplicationController
  USERS = { "lifo" => "world" }

  before_action :authenticate

  private
    def authenticate
      authenticate_or_request_with_http_digest do |username|
        USERS[username]
      end
    end
end
```

Como se ve en el ejemplo anterior, el bloque `authenticate_or_request_with_http_digest` toma solo un argumento, el nombre de usuario. Y el bloque devuelve la contraseña. Devolver `false` o `nil` desde `authenticate_or_request_with_http_digest` causará un fallo de autenticación.


### Autenticación de token HTTP

La autenticación de token HTTP es un esquema que permite el uso de tokens de portador en el encabezado HTTP `Authorization`. Hay muchos formatos de token disponibles y describirlos está fuera del alcance de este documento.

Como ejemplo, supongamos que desea utilizar un token de autenticación que se emitió previamente para realizar autenticación y acceso. La implementación de la autenticación de token con Rails solo requiere el uso de un método, [`authenticate_or_request_with_http_token`][].

```ruby
class PostsController < ApplicationController
  TOKEN = "secret"

  before_action :authenticate

  private
    def authenticate
      authenticate_or_request_with_http_token do |token, options|
        ActiveSupport::SecurityUtils.secure_compare(token, TOKEN)
      end
    end
end
```

Como se ve en el ejemplo anterior, el bloque `authenticate_or_request_with_http_token` toma dos argumentos, el token y un `Hash` que contiene las opciones que se analizaron del encabezado HTTP `Authorization`. El bloque debe devolver `true` si la autenticación es exitosa. Devolver `false` o `nil` en él causará un fallo de autenticación.
Transmisión y descarga de archivos
----------------------------

A veces puede que desees enviar un archivo al usuario en lugar de renderizar una página HTML. Todos los controladores en Rails tienen los métodos [`send_data`][] y [`send_file`][], que permiten transmitir datos al cliente. `send_file` es un método conveniente que te permite proporcionar el nombre de un archivo en el disco y transmitirá los contenidos de ese archivo por ti.

Para transmitir datos al cliente, utiliza `send_data`:

```ruby
require "prawn"
class ClientsController < ApplicationController
  # Genera un documento PDF con información sobre el cliente y lo devuelve. El usuario obtendrá el PDF como una descarga de archivo.
  def download_pdf
    client = Client.find(params[:id])
    send_data generate_pdf(client),
              filename: "#{client.name}.pdf",
              type: "application/pdf"
  end

  private
    def generate_pdf(client)
      Prawn::Document.new do
        text client.name, align: :center
        text "Dirección: #{client.address}"
        text "Email: #{client.email}"
      end.render
    end
end
```

La acción `download_pdf` en el ejemplo anterior llamará a un método privado que realmente genera el documento PDF y lo devuelve como una cadena. Esta cadena luego se transmitirá al cliente como una descarga de archivo, y se sugerirá un nombre de archivo al usuario. A veces, al transmitir archivos al usuario, es posible que no desees que descarguen el archivo. Toma las imágenes, por ejemplo, que se pueden incrustar en páginas HTML. Para indicar al navegador que un archivo no está destinado a ser descargado, puedes establecer la opción `:disposition` en "inline". El valor opuesto y predeterminado para esta opción es "attachment".


### Envío de archivos

Si deseas enviar un archivo que ya existe en el disco, utiliza el método `send_file`.

```ruby
class ClientsController < ApplicationController
  # Transmite un archivo que ya ha sido generado y almacenado en el disco.
  def download_pdf
    client = Client.find(params[:id])
    send_file("#{Rails.root}/files/clients/#{client.id}.pdf",
              filename: "#{client.name}.pdf",
              type: "application/pdf")
  end
end
```

Esto leerá y transmitirá el archivo 4 kB a la vez, evitando cargar todo el archivo en la memoria de una vez. Puedes desactivar la transmisión con la opción `:stream` o ajustar el tamaño del bloque con la opción `:buffer_size`.

Si no se especifica `:type`, se adivinará a partir de la extensión de archivo especificada en `:filename`. Si el tipo de contenido no está registrado para la extensión, se utilizará `application/octet-stream`.

ADVERTENCIA: Ten cuidado al usar datos provenientes del cliente (params, cookies, etc.) para localizar el archivo en el disco, ya que esto representa un riesgo de seguridad que podría permitir que alguien acceda a archivos a los que no debería tener acceso.

CONSEJO: No se recomienda transmitir archivos estáticos a través de Rails si puedes mantenerlos en una carpeta pública en tu servidor web. Es mucho más eficiente permitir que el usuario descargue el archivo directamente utilizando Apache u otro servidor web, evitando que la solicitud pase innecesariamente por toda la pila de Rails.

### Descargas RESTful

Si bien `send_data` funciona bien, si estás creando una aplicación RESTful, por lo general no es necesario tener acciones separadas para las descargas de archivos. En la terminología REST, el archivo PDF del ejemplo anterior se puede considerar simplemente otra representación del recurso del cliente. Rails proporciona una forma elegante de hacer descargas "RESTful". Así es como puedes reescribir el ejemplo para que la descarga del PDF sea parte de la acción `show`, sin ninguna transmisión:

```ruby
class ClientsController < ApplicationController
  # El usuario puede solicitar recibir este recurso como HTML o PDF.
  def show
    @client = Client.find(params[:id])

    respond_to do |format|
      format.html
      format.pdf { render pdf: generate_pdf(@client) }
    end
  end
end
```

Para que este ejemplo funcione, debes agregar el tipo MIME PDF a Rails. Esto se puede hacer agregando la siguiente línea al archivo `config/initializers/mime_types.rb`:

```ruby
Mime::Type.register "application/pdf", :pdf
```

NOTA: Los archivos de configuración no se recargan en cada solicitud, por lo que debes reiniciar el servidor para que los cambios surtan efecto.

Ahora el usuario puede solicitar obtener una versión PDF de un cliente simplemente agregando ".pdf" a la URL:

```
GET /clients/1.pdf
```

### Transmisión en vivo de datos arbitrarios

Rails te permite transmitir más que solo archivos. De hecho, puedes transmitir cualquier cosa que desees en un objeto de respuesta. El módulo [`ActionController::Live`][] te permite crear una conexión persistente con un navegador. Utilizando este módulo, podrás enviar datos arbitrarios al navegador en momentos específicos.
#### Incorporando la transmisión en vivo

Incluir `ActionController::Live` dentro de la clase de su controlador proporcionará a todas las acciones dentro del controlador la capacidad de transmitir datos. Puede mezclar el módulo de la siguiente manera:

```ruby
class MyController < ActionController::Base
  include ActionController::Live

  def stream
    response.headers['Content-Type'] = 'text/event-stream'
    100.times {
      response.stream.write "hello world\n"
      sleep 1
    }
  ensure
    response.stream.close
  end
end
```

El código anterior mantendrá una conexión persistente con el navegador y enviará 100 mensajes de `"hello world\n"`, cada uno separado por un segundo.

Hay un par de cosas a tener en cuenta en el ejemplo anterior. Debemos asegurarnos de cerrar el flujo de respuesta. Olvidar cerrar el flujo dejará el socket abierto para siempre. También debemos establecer el tipo de contenido en `text/event-stream` antes de escribir en el flujo de respuesta. Esto se debe a que los encabezados no se pueden escribir después de que la respuesta se haya comprometido (cuando `response.committed?` devuelve un valor verdadero), lo cual ocurre cuando se `write` o `commit` el flujo de respuesta.

#### Ejemplo de uso

Supongamos que estás haciendo una máquina de karaoke y un usuario quiere obtener la letra de una canción en particular. Cada `Song` tiene un número determinado de líneas y cada línea tarda `num_beats` en terminar de cantar.

Si queremos devolver la letra al estilo de karaoke (enviando solo la línea cuando el cantante ha terminado la línea anterior), podemos usar `ActionController::Live` de la siguiente manera:

```ruby
class LyricsController < ActionController::Base
  include ActionController::Live

  def show
    response.headers['Content-Type'] = 'text/event-stream'
    song = Song.find(params[:id])

    song.each do |line|
      response.stream.write line.lyrics
      sleep line.num_beats
    end
  ensure
    response.stream.close
  end
end
```

El código anterior envía la siguiente línea solo después de que el cantante ha completado la línea anterior.

#### Consideraciones sobre la transmisión

La transmisión de datos arbitrarios es una herramienta extremadamente poderosa. Como se muestra en los ejemplos anteriores, puedes elegir cuándo y qué enviar a través de un flujo de respuesta. Sin embargo, también debes tener en cuenta lo siguiente:

* Cada flujo de respuesta crea un nuevo hilo y copia las variables locales del hilo original. Tener demasiadas variables locales puede afectar negativamente el rendimiento. De manera similar, un gran número de hilos también puede dificultar el rendimiento.
* No cerrar el flujo de respuesta dejará el socket correspondiente abierto para siempre. Asegúrate de llamar a `close` siempre que uses un flujo de respuesta.
* Los servidores WEBrick almacenan en búfer todas las respuestas, por lo que incluir `ActionController::Live` no funcionará. Debes usar un servidor web que no almacene automáticamente las respuestas en búfer.

Filtrado de registros
---------------------

Rails mantiene un archivo de registro para cada entorno en la carpeta `log`. Estos son extremadamente útiles para depurar lo que está sucediendo en tu aplicación, pero en una aplicación en vivo es posible que no desees que se almacene toda la información en el archivo de registro.

### Filtrado de parámetros

Puedes filtrar los parámetros de solicitud sensibles de tus archivos de registro agregándolos a [`config.filter_parameters`][] en la configuración de la aplicación. Estos parámetros se marcarán como [FILTERED] en el registro.

```ruby
config.filter_parameters << :password
```

NOTA: Los parámetros proporcionados se filtrarán mediante una expresión regular de coincidencia parcial. Rails agrega una lista de filtros predeterminados, que incluyen `:passw`, `:secret` y `:token`, en el inicializador correspondiente (`initializers/filter_parameter_logging.rb`) para manejar parámetros típicos de la aplicación como `password`, `password_confirmation` y `my_token`.

### Filtrado de redirecciones

A veces es deseable filtrar de los archivos de registro las ubicaciones sensibles a las que se redirige tu aplicación. Puedes hacerlo utilizando la opción de configuración `config.filter_redirect`:

```ruby
config.filter_redirect << 's3.amazonaws.com'
```

Puedes configurarlo como una cadena, una expresión regular o una matriz de ambos.

```ruby
config.filter_redirect.concat ['s3.amazonaws.com', /private_path/]
```

Las URL coincidentes se marcarán como '[FILTERED]'.

Rescate
-------

Es muy probable que tu aplicación contenga errores o lance una excepción que debe ser manejada. Por ejemplo, si el usuario sigue un enlace a un recurso que ya no existe en la base de datos, Active Record lanzará la excepción `ActiveRecord::RecordNotFound`.

El manejo de excepciones predeterminado de Rails muestra un mensaje de "Error del servidor 500" para todas las excepciones. Si la solicitud se realizó localmente, se mostrará una traza de seguimiento agradable y se mostrará información adicional para que puedas averiguar qué salió mal y lidiar con ello. Si la solicitud fue remota, Rails simplemente mostrará un mensaje simple de "Error del servidor 500" al usuario, o un "Error 404 No encontrado" si hubo un error de enrutamiento o no se pudo encontrar un registro. A veces es posible que desees personalizar cómo se capturan estos errores y cómo se muestran al usuario. Hay varios niveles de manejo de excepciones disponibles en una aplicación de Rails:
### Las plantillas predeterminadas de error 500 y 404

De forma predeterminada, en el entorno de producción, la aplicación mostrará un mensaje de error 404 o 500. En el entorno de desarrollo, todas las excepciones no controladas simplemente se generan. Estos mensajes se encuentran en archivos HTML estáticos en la carpeta pública, en `404.html` y `500.html` respectivamente. Puede personalizar estos archivos para agregar información adicional y estilo, pero recuerde que son HTML estáticos; es decir, no puede usar ERB, SCSS, CoffeeScript o diseños para ellos.

### `rescue_from`

Si desea hacer algo más elaborado al capturar errores, puede usar [`rescue_from`][], que maneja excepciones de un cierto tipo (o varios tipos) en un controlador completo y sus subclases.

Cuando ocurre una excepción que es capturada por una directiva `rescue_from`, se pasa el objeto de excepción al controlador. El controlador puede ser un método o un objeto `Proc` pasado a la opción `:with`. También puede usar un bloque directamente en lugar de un objeto `Proc` explícito.

Aquí se muestra cómo puede usar `rescue_from` para interceptar todos los errores `ActiveRecord::RecordNotFound` y hacer algo con ellos.

```ruby
class ApplicationController < ActionController::Base
  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found

  private
    def record_not_found
      render plain: "404 Not Found", status: 404
    end
end
```

Por supuesto, este ejemplo es todo menos elaborado y no mejora en absoluto el manejo de excepciones predeterminado, pero una vez que puede capturar todas esas excepciones, puede hacer lo que quiera con ellas. Por ejemplo, podría crear clases de excepción personalizadas que se lanzarán cuando un usuario no tenga acceso a cierta sección de su aplicación:

```ruby
class ApplicationController < ActionController::Base
  rescue_from User::NotAuthorized, with: :user_not_authorized

  private
    def user_not_authorized
      flash[:error] = "No tienes acceso a esta sección."
      redirect_back(fallback_location: root_path)
    end
end

class ClientsController < ApplicationController
  # Verificar que el usuario tenga la autorización correcta para acceder a los clientes.
  before_action :check_authorization

  # Observa cómo las acciones no tienen que preocuparse por todo el tema de autenticación.
  def edit
    @client = Client.find(params[:id])
  end

  private
    # Si el usuario no está autorizado, simplemente lanza la excepción.
    def check_authorization
      raise User::NotAuthorized unless current_user.admin?
    end
end
```

ADVERTENCIA: Usar `rescue_from` con `Exception` o `StandardError` causaría efectos secundarios graves, ya que impide que Rails maneje las excepciones correctamente. Por lo tanto, no se recomienda hacerlo a menos que haya una razón sólida.

NOTA: Cuando se ejecuta en el entorno de producción, todos los errores `ActiveRecord::RecordNotFound` muestran la página de error 404. A menos que necesite un comportamiento personalizado, no es necesario manejar esto.

NOTA: Ciertas excepciones solo se pueden rescatar desde la clase `ApplicationController`, ya que se generan antes de que se inicialice el controlador y se ejecute la acción.


Forzar el protocolo HTTPS
--------------------

Si desea asegurarse de que la comunicación con su controlador solo sea posible a través de HTTPS, debe habilitar el middleware [`ActionDispatch::SSL`][] mediante [`config.force_ssl`][] en la configuración de su entorno.


Punto de control de salud incorporado
------------------------------

Rails también viene con un punto de control de salud incorporado que es accesible en la ruta `/up`. Este punto de control devolverá un código de estado 200 si la aplicación se ha iniciado sin excepciones, y un código de estado 500 en caso contrario.

En producción, muchas aplicaciones deben informar su estado aguas arriba, ya sea a un monitor de tiempo de actividad que enviará un mensaje a un ingeniero cuando algo salga mal, o a un equilibrador de carga o controlador de Kubernetes utilizado para determinar la salud de una cápsula. Este punto de control de salud está diseñado para ser un tamaño único que funcionará en muchas situaciones.

Si bien todas las aplicaciones Rails recién generadas tendrán el punto de control de salud en `/up`, puede configurar la ruta como desee en su archivo "config/routes.rb":

```ruby
Rails.application.routes.draw do
  get "healthz" => "rails/health#show", as: :rails_health_check
end
```

El punto de control de salud ahora será accesible a través de la ruta `/healthz`.

NOTA: Este punto de control no refleja el estado de todas las dependencias de su aplicación, como la base de datos o el clúster de Redis. Reemplace "rails/health#show" con su propia acción de controlador si tiene necesidades específicas de la aplicación.

Piense cuidadosamente en lo que desea verificar, ya que puede llevar a situaciones en las que su aplicación se reinicie debido a un servicio de terceros que falla. Idealmente, debería diseñar su aplicación para manejar esas interrupciones de manera adecuada.
[`ActionController::Base`]: https://api.rubyonrails.org/classes/ActionController/Base.html
[`params`]: https://api.rubyonrails.org/classes/ActionController/StrongParameters.html#method-i-params
[`wrap_parameters`]: https://api.rubyonrails.org/classes/ActionController/ParamsWrapper/Options/ClassMethods.html#method-i-wrap_parameters
[`controller_name`]: https://api.rubyonrails.org/classes/ActionController/Metal.html#method-i-controller_name
[`action_name`]: https://api.rubyonrails.org/classes/AbstractController/Base.html#method-i-action_name
[`permit`]: https://api.rubyonrails.org/classes/ActionController/Parameters.html#method-i-permit
[`permit!`]: https://api.rubyonrails.org/classes/ActionController/Parameters.html#method-i-permit-21
[`require`]: https://api.rubyonrails.org/classes/ActionController/Parameters.html#method-i-require
[`ActionDispatch::Session::CookieStore`]: https://api.rubyonrails.org/classes/ActionDispatch/Session/CookieStore.html
[`ActionDispatch::Session::CacheStore`]: https://api.rubyonrails.org/classes/ActionDispatch/Session/CacheStore.html
[`ActionDispatch::Session::MemCacheStore`]: https://api.rubyonrails.org/classes/ActionDispatch/Session/MemCacheStore.html
[activerecord-session_store]: https://github.com/rails/activerecord-session_store
[`reset_session`]: https://api.rubyonrails.org/classes/ActionController/Metal.html#method-i-reset_session
[`flash`]: https://api.rubyonrails.org/classes/ActionDispatch/Flash/RequestMethods.html#method-i-flash
[`flash.keep`]: https://api.rubyonrails.org/classes/ActionDispatch/Flash/FlashHash.html#method-i-keep
[`flash.now`]: https://api.rubyonrails.org/classes/ActionDispatch/Flash/FlashHash.html#method-i-now
[`config.action_dispatch.cookies_serializer`]: configuring.html#config-action-dispatch-cookies-serializer
[`cookies`]: https://api.rubyonrails.org/classes/ActionController/Cookies.html#method-i-cookies
[`before_action`]: https://api.rubyonrails.org/classes/AbstractController/Callbacks/ClassMethods.html#method-i-before_action
[`skip_before_action`]: https://api.rubyonrails.org/classes/AbstractController/Callbacks/ClassMethods.html#method-i-skip_before_action
[`after_action`]: https://api.rubyonrails.org/classes/AbstractController/Callbacks/ClassMethods.html#method-i-after_action
[`around_action`]: https://api.rubyonrails.org/classes/AbstractController/Callbacks/ClassMethods.html#method-i-around_action
[`ActionDispatch::Request`]: https://api.rubyonrails.org/classes/ActionDispatch/Request.html
[`request`]: https://api.rubyonrails.org/classes/ActionController/Base.html#method-i-request
[`response`]: https://api.rubyonrails.org/classes/ActionController/Base.html#method-i-response
[`path_parameters`]: https://api.rubyonrails.org/classes/ActionDispatch/Http/Parameters.html#method-i-path_parameters
[`query_parameters`]: https://api.rubyonrails.org/classes/ActionDispatch/Request.html#method-i-query_parameters
[`request_parameters`]: https://api.rubyonrails.org/classes/ActionDispatch/Request.html#method-i-request_parameters
[`http_basic_authenticate_with`]: https://api.rubyonrails.org/classes/ActionController/HttpAuthentication/Basic/ControllerMethods/ClassMethods.html#method-i-http_basic_authenticate_with
[`authenticate_or_request_with_http_digest`]: https://api.rubyonrails.org/classes/ActionController/HttpAuthentication/Digest/ControllerMethods.html#method-i-authenticate_or_request_with_http_digest
[`authenticate_or_request_with_http_token`]: https://api.rubyonrails.org/classes/ActionController/HttpAuthentication/Token/ControllerMethods.html#method-i-authenticate_or_request_with_http_token
[`send_data`]: https://api.rubyonrails.org/classes/ActionController/DataStreaming.html#method-i-send_data
[`send_file`]: https://api.rubyonrails.org/classes/ActionController/DataStreaming.html#method-i-send_file
[`ActionController::Live`]: https://api.rubyonrails.org/classes/ActionController/Live.html
[`config.filter_parameters`]: configuring.html#config-filter-parameters
[`rescue_from`]: https://api.rubyonrails.org/classes/ActiveSupport/Rescuable/ClassMethods.html#method-i-rescue_from
[`config.force_ssl`]: configuring.html#config-force-ssl
[`ActionDispatch::SSL`]: https://api.rubyonrails.org/classes/ActionDispatch/SSL.html
