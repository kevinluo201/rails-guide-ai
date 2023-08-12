**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 9f53b3a12c263256fbbe154cfc8b2f4d
Autocarga y recarga de constantes
==================================

Esta guía documenta cómo funciona la autocarga y recarga en el modo `zeitwerk`.

Después de leer esta guía, sabrás:

* Configuración relacionada con Rails
* Estructura del proyecto
* Autocarga, recarga y carga ansiosa
* Herencia de tabla única
* Y más

--------------------------------------------------------------------------------

Introducción
------------

INFO. Esta guía documenta la autocarga, recarga y carga ansiosa en aplicaciones Rails.

En un programa Ruby ordinario, cargas explícitamente los archivos que definen las clases y módulos que deseas utilizar. Por ejemplo, el siguiente controlador se refiere a `ApplicationController` y `Post`, y normalmente emitirías llamadas `require` para ellos:

```ruby
# NO HAGAS ESTO.
require "application_controller"
require "post"
# NO HAGAS ESTO.

class PostsController < ApplicationController
  def index
    @posts = Post.all
  end
end
```

Esto no ocurre en las aplicaciones Rails, donde las clases y módulos de la aplicación están disponibles en todas partes sin llamadas `require`:

```ruby
class PostsController < ApplicationController
  def index
    @posts = Post.all
  end
end
```

Rails los _autocarga_ en tu nombre si es necesario. Esto es posible gracias a un par de cargadores [Zeitwerk](https://github.com/fxn/zeitwerk) que Rails configura en tu nombre, los cuales proporcionan autocarga, recarga y carga ansiosa.

Por otro lado, esos cargadores no administran nada más. En particular, no administran la biblioteca estándar de Ruby, las dependencias de gemas, los componentes de Rails mismos o incluso (por defecto) el directorio `lib` de la aplicación. Ese código debe cargarse como de costumbre.


Estructura del proyecto
-----------------------

En una aplicación Rails, los nombres de los archivos deben coincidir con las constantes que definen, y los directorios actúan como espacios de nombres.

Por ejemplo, el archivo `app/helpers/users_helper.rb` debe definir `UsersHelper` y el archivo `app/controllers/admin/payments_controller.rb` debe definir `Admin::PaymentsController`.

Por defecto, Rails configura Zeitwerk para que infleccione los nombres de archivo con `String#camelize`. Por ejemplo, espera que `app/controllers/users_controller.rb` defina la constante `UsersController` porque eso es lo que devuelve `"users_controller".camelize`.

La sección _Personalización de las inflexiones_ a continuación documenta formas de anular esta configuración predeterminada.

Por favor, consulta la [documentación de Zeitwerk](https://github.com/fxn/zeitwerk#file-structure) para más detalles.

config.autoload_paths
---------------------

Nos referimos a la lista de directorios de la aplicación cuyo contenido se debe autocargar y (opcionalmente) recargar como _rutas de autocarga_. Por ejemplo, `app/models`. Tales directorios representan el espacio de nombres raíz: `Object`.

INFO. Las rutas de autocarga se llaman _directorios raíz_ en la documentación de Zeitwerk, pero nos quedaremos con "ruta de autocarga" en esta guía.

Dentro de una ruta de autocarga, los nombres de archivo deben coincidir con las constantes que definen, como se documenta [aquí](https://github.com/fxn/zeitwerk#file-structure).

Por defecto, las rutas de autocarga de una aplicación consisten en todos los subdirectorios de `app` que existen cuando la aplicación se inicia, excepto `assets`, `javascript` y `views`, además de las rutas de autocarga de las engines en las que pueda depender.

Por ejemplo, si `UsersHelper` se implementa en `app/helpers/users_helper.rb`, el módulo se puede autocargar, no necesitas (y no debes escribir) una llamada `require` para ello:

```bash
$ bin/rails runner 'p UsersHelper'
UsersHelper
```

Rails agrega automáticamente directorios personalizados bajo `app` a las rutas de autocarga. Por ejemplo, si tu aplicación tiene `app/presenters`, no necesitas configurar nada para autocargar los presentadores; funciona de forma predeterminada.

El array de rutas de autocarga predeterminadas se puede ampliar agregando a `config.autoload_paths`, en `config/application.rb` o `config/environments/*.rb`. Por ejemplo:

```ruby
module MyApplication
  class Application < Rails::Application
    config.autoload_paths << "#{root}/extras"
  end
end
```

Además, las engines pueden agregar rutas de autocarga en el cuerpo de la clase de la engine y en sus propios `config/environments/*.rb`.

ADVERTENCIA. Por favor, no mutar `ActiveSupport::Dependencies.autoload_paths`; la interfaz pública para cambiar las rutas de autocarga es `config.autoload_paths`.

ADVERTENCIA: No puedes autocargar código en las rutas de autocarga mientras la aplicación se inicia. En particular, directamente en `config/initializers/*.rb`. Por favor, consulta [_Autocarga cuando la aplicación se inicia_](#autoloading-when-the-application-boots) más abajo para conocer las formas válidas de hacerlo.

Las rutas de autocarga son gestionadas por el cargador automático `Rails.autoloaders.main`.

config.autoload_lib(ignore:)
----------------------------

Por defecto, el directorio `lib` no pertenece a las rutas de autocarga de las aplicaciones o engines.

El método de configuración `config.autoload_lib` agrega el directorio `lib` a `config.autoload_paths` y `config.eager_load_paths`. Debe invocarse desde `config/application.rb` o `config/environments/*.rb`, y no está disponible para las engines.

Normalmente, `lib` tiene subdirectorios que no deben ser gestionados por los cargadores automáticos. Por favor, pasa su nombre relativo a `lib` en el argumento de palabra clave `ignore` requerido. Por ejemplo:

```ruby
config.autoload_lib(ignore: %w(assets tasks))
```

¿Por qué? Mientras que `assets` y `tasks` comparten el directorio `lib` con el código regular, su contenido no está destinado a ser autocargado o cargado ansiosamente. `Assets` y `Tasks` no son espacios de nombres de Ruby allí. Lo mismo ocurre con los generadores si tienes alguno:
```ruby
config.autoload_lib(ignore: %w(assets tasks generators))
```

`config.autoload_lib` no está disponible antes de la versión 7.1, pero aún puedes emularlo siempre y cuando la aplicación use Zeitwerk:

```ruby
# config/application.rb
module MyApp
  class Application < Rails::Application
    lib = root.join("lib")

    config.autoload_paths << lib
    config.eager_load_paths << lib

    Rails.autoloaders.main.ignore(
      lib.join("assets"),
      lib.join("tasks"),
      lib.join("generators")
    )

    ...
  end
end
```

config.autoload_once_paths
--------------------------

Es posible que desees poder cargar clases y módulos sin volver a cargarlos. La configuración `autoload_once_paths` almacena código que se puede cargar automáticamente, pero no se volverá a cargar.

De forma predeterminada, esta colección está vacía, pero puedes ampliarla agregando elementos a `config.autoload_once_paths`. Puedes hacerlo en `config/application.rb` o `config/environments/*.rb`. Por ejemplo:

```ruby
module MyApplication
  class Application < Rails::Application
    config.autoload_once_paths << "#{root}/app/serializers"
  end
end
```

Además, los motores pueden agregar elementos en el cuerpo de la clase del motor y en sus propios `config/environments/*.rb`.

INFO. Si se agrega `app/serializers` a `config.autoload_once_paths`, Rails ya no considera esto como una ruta de carga automática, a pesar de ser un directorio personalizado dentro de `app`. Esta configuración anula esa regla.

Esto es importante para clases y módulos que se almacenan en lugares que sobreviven a las recargas, como el propio framework de Rails.

Por ejemplo, los serializadores de Active Job se almacenan dentro de Active Job:

```ruby
# config/initializers/custom_serializers.rb
Rails.application.config.active_job.custom_serializers << MoneySerializer
```

y Active Job en sí no se recarga cuando hay una recarga, solo se recarga el código de la aplicación y los motores en las rutas de carga automática.

Hacer que `MoneySerializer` sea recargable sería confuso, porque volver a cargar una versión editada no tendría efecto en ese objeto de clase almacenado en Active Job. De hecho, si `MoneySerializer` fuera recargable, a partir de Rails 7, dicho inicializador generaría un `NameError`.

Otro caso de uso es cuando los motores decoran clases del framework:

```ruby
initializer "decorate ActionController::Base" do
  ActiveSupport.on_load(:action_controller_base) do
    include MyDecoration
  end
end
```

Allí, el objeto de módulo almacenado en `MyDecoration` en el momento en que se ejecuta el inicializador se convierte en un ancestro de `ActionController::Base`, y volver a cargar `MyDecoration` no tiene sentido, no afectará esa cadena de ancestros.

Las clases y módulos de las rutas de carga automática única se pueden cargar automáticamente en `config/initializers`. Por lo tanto, con esa configuración, esto funciona:

```ruby
# config/initializers/custom_serializers.rb
Rails.application.config.active_job.custom_serializers << MoneySerializer
```

INFO: Técnicamente, se pueden cargar automáticamente clases y módulos gestionados por el cargador automático `once` en cualquier inicializador que se ejecute después de `:bootstrap_hook`.

Las rutas de carga automática única son gestionadas por `Rails.autoloaders.once`.

config.autoload_lib_once(ignore:)
---------------------------------

El método `config.autoload_lib_once` es similar a `config.autoload_lib`, excepto que agrega `lib` a `config.autoload_once_paths` en su lugar. Debe invocarse desde `config/application.rb` o `config/environments/*.rb`, y no está disponible para los motores.

Al llamar a `config.autoload_lib_once`, las clases y módulos en `lib` se pueden cargar automáticamente, incluso desde los inicializadores de la aplicación, pero no se volverán a cargar.

`config.autoload_lib_once` no está disponible antes de la versión 7.1, pero aún puedes emularlo siempre y cuando la aplicación use Zeitwerk:

```ruby
# config/application.rb
module MyApp
  class Application < Rails::Application
    lib = root.join("lib")

    config.autoload_once_paths << lib
    config.eager_load_paths << lib

    Rails.autoloaders.once.ignore(
      lib.join("assets"),
      lib.join("tasks"),
      lib.join("generators")
    )

    ...
  end
end
```

$LOAD_PATH{#load_path}
----------

Las rutas de carga automática se agregan a `$LOAD_PATH` de forma predeterminada. Sin embargo, Zeitwerk utiliza nombres de archivo absolutos internamente y tu aplicación no debe emitir llamadas `require` para archivos que se pueden cargar automáticamente, por lo que esos directorios no son necesarios allí. Puedes optar por no incluirlos con esta configuración:

```ruby
config.add_autoload_paths_to_load_path = false
```

Esto puede acelerar un poco las llamadas legítimas a `require`, ya que hay menos búsquedas. Además, si tu aplicación utiliza [Bootsnap](https://github.com/Shopify/bootsnap), esto evita que la biblioteca construya índices innecesarios, lo que lleva a un menor uso de memoria.

El directorio `lib` no se ve afectado por esta configuración, siempre se agrega a `$LOAD_PATH`.

Recarga
---------

Rails recarga automáticamente clases y módulos si los archivos de la aplicación en las rutas de carga automática cambian.

Más precisamente, si el servidor web está en ejecución y los archivos de la aplicación han sido modificados, Rails descarga todas las constantes cargadas automáticamente gestionadas por el cargador automático `main` justo antes de procesar la siguiente solicitud. De esta manera, las clases o módulos de la aplicación utilizados durante esa solicitud se cargarán automáticamente nuevamente, lo que les permitirá utilizar su implementación actual en el sistema de archivos.

La recarga se puede habilitar o deshabilitar. La configuración que controla este comportamiento es [`config.enable_reloading`][], que es `true` de forma predeterminada en el modo `development` y `false` de forma predeterminada en el modo `production`. Por razones de compatibilidad con versiones anteriores, Rails también admite `config.cache_classes`, que es equivalente a `!config.enable_reloading`.

Rails utiliza un monitor de archivos basado en eventos para detectar cambios en los archivos de forma predeterminada. También se puede configurar para detectar cambios en los archivos recorriendo las rutas de carga automática. Esto se controla mediante la configuración [`config.file_watcher`][].

En una consola de Rails, no hay un monitor de archivos activo independientemente del valor de `config.enable_reloading`. Esto se debe a que, normalmente, sería confuso volver a cargar el código en medio de una sesión de consola. Al igual que en una solicitud individual, generalmente deseas que una sesión de consola se sirva con un conjunto coherente y no cambiante de clases y módulos de la aplicación.
Sin embargo, puedes forzar una recarga en la consola ejecutando `reload!`:

```irb
irb(main):001:0> User.object_id
=> 70136277390120
irb(main):002:0> reload!
Recargando...
=> true
irb(main):003:0> User.object_id
=> 70136284426020
```

Como puedes ver, el objeto de clase almacenado en la constante `User` es diferente después de la recarga.


### Recarga y objetos obsoletos

Es muy importante entender que Ruby no tiene una forma de recargar verdaderamente clases y módulos en memoria, y que esto se refleje en todos los lugares donde ya se están utilizando. Técnicamente, "descargar" la clase `User` significa eliminar la constante `User` a través de `Object.send(:remove_const, "User")`.

Por ejemplo, echa un vistazo a esta sesión de la consola de Rails:

```irb
irb> joe = User.new
irb> reload!
irb> alice = User.new
irb> joe.class == alice.class
=> false
```

`joe` es una instancia de la clase `User` original. Cuando hay una recarga, la constante `User` se evalúa como una clase diferente y recargada. `alice` es una instancia del nuevo `User` cargado, pero `joe` no lo es: su clase está obsoleta. Puedes definir `joe` nuevamente, iniciar una sub-sesión de IRB o simplemente abrir una nueva consola en lugar de llamar a `reload!`.

Otra situación en la que puedes encontrar este problema es al heredar de clases recargables en un lugar que no se recarga:

```ruby
# lib/vip_user.rb
class VipUser < User
end
```

Si se recarga `User`, ya que `VipUser` no lo hace, la superclase de `VipUser` será el objeto de clase original y obsoleto.

En resumen: **no almacenes en caché clases o módulos recargables**.

## Carga automática al iniciar la aplicación

Durante el inicio, las aplicaciones pueden cargar automáticamente desde las rutas de carga automática una vez, que son gestionadas por el cargador automático `once`. Por favor, consulta la sección [`config.autoload_once_paths`](#config-autoload-once-paths) anterior.

Sin embargo, no puedes cargar automáticamente desde las rutas de carga automática, que son gestionadas por el cargador automático `main`. Esto se aplica al código en `config/initializers` así como a los inicializadores de la aplicación o motores.

¿Por qué? Los inicializadores solo se ejecutan una vez, cuando se inicia la aplicación. No se ejecutan de nuevo en las recargas. Si un inicializador utiliza una clase o módulo recargable, las ediciones en ellos no se reflejarían en ese código inicial, volviéndose obsoletas. Por lo tanto, no se permite hacer referencia a constantes recargables durante la inicialización.

Veamos qué hacer en su lugar.

### Caso de uso 1: Durante el inicio, cargar código recargable

#### Carga automática en el inicio y en cada recarga

Imaginemos que `ApiGateway` es una clase recargable y necesitas configurar su punto final mientras se inicia la aplicación:

```ruby
# config/initializers/api_gateway_setup.rb
ApiGateway.endpoint = "https://example.com" # NameError
```

Los inicializadores no pueden hacer referencia a constantes recargables, debes envolver eso en un bloque `to_prepare`, que se ejecuta en el inicio y después de cada recarga:

```ruby
# config/initializers/api_gateway_setup.rb
Rails.application.config.to_prepare do
  ApiGateway.endpoint = "https://example.com" # CORRECTO
end
```

NOTA: Por razones históricas, esta devolución de llamada puede ejecutarse dos veces. El código que ejecuta debe ser idempotente.

#### Carga automática solo en el inicio

Las clases y módulos recargables también se pueden cargar automáticamente en bloques `after_initialize`. Estos se ejecutan en el inicio, pero no se ejecutan de nuevo en las recargas. En algunos casos excepcionales, esto puede ser lo que deseas.

Los controles previos al vuelo son un caso de uso para esto:

```ruby
# config/initializers/check_admin_presence.rb
Rails.application.config.after_initialize do
  unless Role.where(name: "admin").exists?
    abort "El rol de administrador no está presente, por favor, carga la base de datos."
  end
end
```

### Caso de uso 2: Durante el inicio, cargar código que permanece en caché

Algunas configuraciones toman un objeto de clase o módulo y lo almacenan en un lugar que no se recarga. Es importante que estos no sean recargables, porque las ediciones no se reflejarían en esos objetos en caché y obsoletos.

Un ejemplo es el middleware:

```ruby
config.middleware.use MyApp::Middleware::Foo
```

Cuando recargas, la pila de middleware no se ve afectada, por lo que sería confuso que `MyApp::Middleware::Foo` sea recargable. Los cambios en su implementación no tendrían efecto.

Otro ejemplo son los serializadores de Active Job:

```ruby
# config/initializers/custom_serializers.rb
Rails.application.config.active_job.custom_serializers << MoneySerializer
```

Cualquier cosa a la que `MoneySerializer` se evalúe durante la inicialización se añade a los serializadores personalizados, y ese objeto se mantiene allí en las recargas.

Otro ejemplo son las railties o los motores que decoran las clases del framework incluyendo módulos. Por ejemplo, [`turbo-rails`](https://github.com/hotwired/turbo-rails) decora `ActiveRecord::Base` de esta manera:

```ruby
initializer "turbo.broadcastable" do
  ActiveSupport.on_load(:active_record) do
    include Turbo::Broadcastable
  end
end
```

Eso añade un objeto de módulo a la cadena de ancestros de `ActiveRecord::Base`. Los cambios en `Turbo::Broadcastable` no tendrían efecto si se recargan, la cadena de ancestros seguiría teniendo el original.

Corolario: Esas clases o módulos **no pueden ser recargables**.

La forma más sencilla de hacer referencia a esas clases o módulos durante el inicio es tenerlos definidos en un directorio que no pertenezca a las rutas de carga automática. Por ejemplo, `lib` es una elección idiomática. Por defecto, no pertenece a las rutas de carga automática, pero sí pertenece a `$LOAD_PATH`. Solo realiza un `require` normal para cargarlo.
Como se mencionó anteriormente, otra opción es tener el directorio que los define en la carga automática una vez y en las rutas de carga automática. Por favor, consulte la [sección sobre config.autoload_once_paths](#config-autoload-once-paths) para más detalles.

### Caso de uso 3: Configurar clases de aplicación para motores

Supongamos que un motor funciona con la clase de aplicación recargable que modela a los usuarios, y tiene un punto de configuración para ello:

```ruby
# config/initializers/my_engine.rb
MyEngine.configure do |config|
  config.user_model = User # NameError
end
```

Para que funcione correctamente con el código de aplicación recargable, el motor necesita que las aplicaciones configuren el _nombre_ de esa clase:

```ruby
# config/initializers/my_engine.rb
MyEngine.configure do |config|
  config.user_model = "User" # OK
end
```

Luego, en tiempo de ejecución, `config.user_model.constantize` te da el objeto de clase actual.

Carga anticipada
----------------

En entornos similares a producción, generalmente es mejor cargar todo el código de la aplicación cuando se inicia la aplicación. La carga anticipada pone todo en memoria listo para atender las solicitudes de inmediato, y también es compatible con [CoW](https://en.wikipedia.org/wiki/Copy-on-write).

La carga anticipada está controlada por la bandera [`config.eager_load`][], que está desactivada de forma predeterminada en todos los entornos excepto `production`. Cuando se ejecuta una tarea de Rake, `config.eager_load` es anulado por [`config.rake_eager_load`][], que es `false` de forma predeterminada. Por lo tanto, de forma predeterminada, en entornos de producción las tareas de Rake no cargan anticipadamente la aplicación.

El orden en el que se carga anticipadamente los archivos no está definido.

Durante la carga anticipada, Rails invoca `Zeitwerk::Loader.eager_load_all`. Esto asegura que todas las dependencias de gemas gestionadas por Zeitwerk también se carguen anticipadamente.



Herencia de tabla única
------------------------

La herencia de tabla única no funciona bien con la carga perezosa: Active Record debe ser consciente de las jerarquías de STI para funcionar correctamente, pero cuando se carga perezosamente, ¡las clases se cargan precisamente solo cuando se solicitan!

Para abordar esta incompatibilidad fundamental, necesitamos precargar STIs. Hay algunas opciones para lograr esto, con diferentes compensaciones. Veámoslas.

### Opción 1: Habilitar la carga anticipada

La forma más fácil de precargar STIs es habilitar la carga anticipada configurando:

```ruby
config.eager_load = true
```

en `config/environments/development.rb` y `config/environments/test.rb`.

Esto es simple, pero puede ser costoso porque carga anticipadamente toda la aplicación al iniciarla y en cada recarga. Sin embargo, la compensación puede valer la pena para aplicaciones pequeñas.

### Opción 2: Precargar un directorio colapsado

Almacena los archivos que definen la jerarquía en un directorio dedicado, lo cual también tiene sentido conceptualmente. El directorio no pretende representar un espacio de nombres, su único propósito es agrupar el STI:

```
app/models/shapes/shape.rb
app/models/shapes/circle.rb
app/models/shapes/square.rb
app/models/shapes/triangle.rb
```

En este ejemplo, aún queremos que `app/models/shapes/circle.rb` defina `Circle`, no `Shapes::Circle`. Esto puede ser una preferencia personal para mantener las cosas simples y también evita refactorizaciones en bases de código existentes. La función de [colapsar](https://github.com/fxn/zeitwerk#collapsing-directories) de Zeitwerk nos permite hacer eso:

```ruby
# config/initializers/preload_stis.rb

shapes = "#{Rails.root}/app/models/shapes"
Rails.autoloaders.main.collapse(shapes) # No es un espacio de nombres.

unless Rails.application.config.eager_load
  Rails.application.config.to_prepare do
    Rails.autoloaders.main.eager_load_dir(shapes)
  end
end
```

En esta opción, cargamos anticipadamente estos pocos archivos al iniciar y recargar incluso si el STI no se utiliza. Sin embargo, a menos que tu aplicación tenga muchos STIs, esto no tendrá ningún impacto medible.

INFO: El método `Zeitwerk::Loader#eager_load_dir` se agregó en Zeitwerk 2.6.2. Para versiones anteriores, aún puedes listar el directorio `app/models/shapes` e invocar `require_dependency` en su contenido.

ADVERTENCIA: Si se agregan, modifican o eliminan modelos del STI, la recarga funciona como se espera. Sin embargo, si se agrega una nueva jerarquía de STI separada a la aplicación, deberás editar el inicializador y reiniciar el servidor.

### Opción 3: Precargar un directorio regular

Similar a la anterior, pero el directorio está destinado a ser un espacio de nombres. Es decir, se espera que `app/models/shapes/circle.rb` defina `Shapes::Circle`.

Para esta opción, el inicializador es el mismo excepto que no se configura el colapso:

```ruby
# config/initializers/preload_stis.rb

unless Rails.application.config.eager_load
  Rails.application.config.to_prepare do
    Rails.autoloaders.main.eager_load_dir("#{Rails.root}/app/models/shapes")
  end
end
```

Mismas compensaciones.

### Opción 4: Precargar tipos desde la base de datos

En esta opción no necesitamos organizar los archivos de ninguna manera, pero accedemos a la base de datos:

```ruby
# config/initializers/preload_stis.rb

unless Rails.application.config.eager_load
  Rails.application.config.to_prepare do
    types = Shape.unscoped.select(:type).distinct.pluck(:type)
    types.compact.each(&:constantize)
  end
end
```

ADVERTENCIA: El STI funcionará correctamente incluso si la tabla no tiene todos los tipos, pero los métodos como `subclasses` o `descendants` no devolverán los tipos faltantes.

ADVERTENCIA: Si se agregan, modifican o eliminan modelos del STI, la recarga funciona como se espera. Sin embargo, si se agrega una nueva jerarquía de STI separada a la aplicación, deberás editar el inicializador y reiniciar el servidor.
Personalización de Inflecciones
-----------------------

Por defecto, Rails utiliza `String#camelize` para saber qué constante debe definir un determinado archivo o nombre de directorio. Por ejemplo, `posts_controller.rb` debe definir `PostsController` porque eso es lo que devuelve `"posts_controller".camelize`.

Puede suceder que algún nombre de archivo o directorio en particular no se infleccione como desee. Por ejemplo, se espera que `html_parser.rb` defina `HtmlParser` de forma predeterminada. ¿Qué pasa si prefiere que la clase sea `HTMLParser`? Hay algunas formas de personalizar esto.

La forma más sencilla es definir acrónimos:

```ruby
ActiveSupport::Inflector.inflections(:en) do |inflect|
  inflect.acronym "HTML"
  inflect.acronym "SSL"
end
```

Hacer esto afecta cómo Active Support infleccione globalmente. Eso puede ser válido en algunas aplicaciones, pero también puede personalizar cómo se infleccione cada nombre de archivo de forma independiente de Active Support pasando una colección de anulaciones a los inflectores predeterminados:

```ruby
Rails.autoloaders.each do |autoloader|
  autoloader.inflector.inflect(
    "html_parser" => "HTMLParser",
    "ssl_error"   => "SSLError"
  )
end
```

Sin embargo, esta técnica aún depende de `String#camelize`, ya que eso es lo que los inflectores predeterminados utilizan como alternativa. Si prefiere no depender en absoluto de las inflecciones de Active Support y tener un control absoluto sobre las inflecciones, configure los inflectores como instancias de `Zeitwerk::Inflector`:

```ruby
Rails.autoloaders.each do |autoloader|
  autoloader.inflector = Zeitwerk::Inflector.new
  autoloader.inflector.inflect(
    "html_parser" => "HTMLParser",
    "ssl_error"   => "SSLError"
  )
end
```

No hay una configuración global que pueda afectar a dichas instancias; son deterministas.

Incluso puede definir un inflector personalizado para tener una flexibilidad total. Consulte la [documentación de Zeitwerk](https://github.com/fxn/zeitwerk#custom-inflector) para obtener más detalles.

### ¿Dónde debe ir la personalización de inflecciones?

Si una aplicación no utiliza el cargador `once`, los fragmentos anteriores se pueden colocar en `config/initializers`. Por ejemplo, `config/initializers/inflections.rb` para el caso de uso de Active Support, o `config/initializers/zeitwerk.rb` para los demás casos.

Las aplicaciones que utilizan el cargador `once` deben mover o cargar esta configuración desde el cuerpo de la clase de la aplicación en `config/application.rb`, porque el cargador `once` utiliza el inflector al principio del proceso de inicio.

Espacios de nombres personalizados
-----------------

Como vimos anteriormente, las rutas de carga automática representan el espacio de nombres de nivel superior: `Object`.

Consideremos `app/services`, por ejemplo. Este directorio no se genera de forma predeterminada, pero si existe, Rails lo agrega automáticamente a las rutas de carga automática.

De forma predeterminada, se espera que el archivo `app/services/users/signup.rb` defina `Users::Signup`, pero ¿qué pasa si prefiere que todo ese subárbol esté bajo un espacio de nombres `Services`? Bueno, con la configuración predeterminada, eso se puede lograr creando un subdirectorio: `app/services/services`.

Sin embargo, dependiendo de sus preferencias, eso simplemente podría no parecerle correcto. Es posible que prefiera que `app/services/users/signup.rb` simplemente defina `Services::Users::Signup`.

Zeitwerk admite [espacios de nombres raíz personalizados](https://github.com/fxn/zeitwerk#custom-root-namespaces) para abordar este caso de uso, y puede personalizar el cargador `main` para lograrlo:

```ruby
# config/initializers/autoloading.rb

# El espacio de nombres debe existir.
#
# En este ejemplo, definimos el módulo en el acto. También podría crearse
# en otro lugar y su definición cargarse aquí con un `require` ordinario.
# En cualquier caso, `push_dir` espera un objeto de clase o módulo.
module Services; end

Rails.autoloaders.main.push_dir("#{Rails.root}/app/services", namespace: Services)
```

Rails < 7.1 no admitía esta función, pero aún puede agregar este código adicional en el mismo archivo y hacerlo funcionar:

```ruby
# Código adicional para aplicaciones que se ejecutan en Rails < 7.1.
app_services_dir = "#{Rails.root}/app/services" # debe ser una cadena
ActiveSupport::Dependencies.autoload_paths.delete(app_services_dir)
Rails.application.config.watchable_dirs[app_services_dir] = [:rb]
```

Los espacios de nombres personalizados también son compatibles con el cargador `once`. Sin embargo, dado que este se configura antes en el proceso de inicio, la configuración no se puede realizar en un inicializador de la aplicación. En su lugar, colóquelo en `config/application.rb`, por ejemplo.

Carga automática y motores
-----------------------

Los motores se ejecutan en el contexto de una aplicación principal y su código se carga automáticamente, se recarga y se carga de forma ansiosa por la aplicación principal. Si la aplicación se ejecuta en modo `zeitwerk`, el código del motor se carga en modo `zeitwerk`. Si la aplicación se ejecuta en modo `classic`, el código del motor se carga en modo `classic`.

Cuando Rails se inicia, los directorios del motor se agregan a las rutas de carga automática y, desde el punto de vista del cargador automático, no hay diferencia. Las entradas principales de los cargadores automáticos son las rutas de carga automática, y si pertenecen al árbol de origen de la aplicación o a algún árbol de origen del motor es irrelevante.

Por ejemplo, esta aplicación utiliza [Devise](https://github.com/heartcombo/devise):

```
% bin/rails runner 'pp ActiveSupport::Dependencies.autoload_paths'
[".../app/controllers",
 ".../app/controllers/concerns",
 ".../app/helpers",
 ".../app/models",
 ".../app/models/concerns",
 ".../gems/devise-4.8.0/app/controllers",
 ".../gems/devise-4.8.0/app/helpers",
 ".../gems/devise-4.8.0/app/mailers"]
 ```

Si el motor controla el modo de carga automática de su aplicación principal, el motor se puede escribir como de costumbre.
Sin embargo, si un motor es compatible con Rails 6 o Rails 6.1 y no controla sus aplicaciones principales, debe estar listo para ejecutarse en modo `classic` o `zeitwerk`. Cosas a tener en cuenta:

1. Si el modo `classic` necesita una llamada `require_dependency` para asegurarse de que alguna constante se cargue en algún momento, escríbala. Si bien `zeitwerk` no lo necesita, no afectará y funcionará en modo `zeitwerk` también.

2. El modo `classic` subraya los nombres de las constantes ("User" -> "user.rb"), y el modo `zeitwerk` capitaliza los nombres de los archivos ("user.rb" -> "User"). Coinciden en la mayoría de los casos, pero no si hay series de letras mayúsculas consecutivas como en "HTMLParser". La forma más fácil de ser compatible es evitar tales nombres. En este caso, elija "HtmlParser".

3. En el modo `classic`, el archivo `app/model/concerns/foo.rb` puede definir tanto `Foo` como `Concerns::Foo`. En el modo `zeitwerk`, solo hay una opción: debe definir `Foo`. Para ser compatible, defina `Foo`.

Pruebas
-------

### Pruebas manuales

La tarea `zeitwerk:check` verifica si el árbol del proyecto sigue las convenciones de nomenclatura esperadas y es útil para realizar comprobaciones manuales. Por ejemplo, si está migrando del modo `classic` al modo `zeitwerk`, o si está corrigiendo algo:

```
% bin/rails zeitwerk:check
Espera, estoy cargando la aplicación.
¡Todo está bien!
```

Puede haber una salida adicional dependiendo de la configuración de la aplicación, pero el último "¡Todo está bien!" es lo que estás buscando.

### Pruebas automatizadas

Es una buena práctica verificar en el conjunto de pruebas que la carga anticipada del proyecto se realice correctamente.

Esto cubre el cumplimiento de la nomenclatura de Zeitwerk y otras posibles condiciones de error. Consulte la [sección sobre pruebas de carga anticipada](testing.html#testing-eager-loading) en la guía [_Testing Rails Applications_](testing.html).

Solución de problemas
---------------------

La mejor manera de seguir lo que hacen los cargadores es inspeccionar su actividad.

La forma más fácil de hacerlo es incluir

```ruby
Rails.autoloaders.log!
```

en `config/application.rb` después de cargar las configuraciones predeterminadas del framework. Esto imprimirá trazas en la salida estándar.

Si prefiere registrar en un archivo, configure esto en su lugar:

```ruby
Rails.autoloaders.logger = Logger.new("#{Rails.root}/log/autoloading.log")
```

El registrador de Rails aún no está disponible cuando se ejecuta `config/application.rb`. Si prefiere usar el registrador de Rails, configure esta configuración en un inicializador en su lugar:

```ruby
# config/initializers/log_autoloaders.rb
Rails.autoloaders.logger = Rails.logger
```

Rails.autoloaders
-----------------

Las instancias de Zeitwerk que gestionan su aplicación están disponibles en

```ruby
Rails.autoloaders.main
Rails.autoloaders.once
```

El predicado

```ruby
Rails.autoloaders.zeitwerk_enabled?
```

aún está disponible en aplicaciones Rails 7 y devuelve `true`.
[`config.enable_reloading`]: configuring.html#config-enable-reloading
[`config.file_watcher`]: configuring.html#config-file-watcher
[`config.eager_load`]: configuring.html#config-eager-load
[`config.rake_eager_load`]: configuring.html#config-rake-eager-load
