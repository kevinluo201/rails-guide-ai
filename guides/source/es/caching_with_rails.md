**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: bef23603f5d822054701f5cbf2578d95
Caché con Rails: Una Visión General
===============================

Esta guía es una introducción para acelerar su aplicación Rails con caché.

Caché significa almacenar contenido generado durante el ciclo de solicitud-respuesta
y reutilizarlo al responder a solicitudes similares.

La caché es a menudo la forma más efectiva de mejorar el rendimiento de una aplicación.
A través de la caché, los sitios web que se ejecutan en un solo servidor con una sola base de datos
pueden soportar una carga de miles de usuarios concurrentes.

Rails proporciona un conjunto de características de caché de forma predeterminada. Esta guía le enseñará
el alcance y el propósito de cada una de ellas. Domine estas técnicas y sus
aplicaciones Rails pueden servir millones de vistas sin tiempos de respuesta exorbitantes
o facturas de servidor.

Después de leer esta guía, sabrá:

* Caché de fragmentos y muñecas rusas.
* Cómo gestionar las dependencias de caché.
* Almacenamiento de caché alternativo.
* Soporte para GET condicional.

--------------------------------------------------------------------------------

Caché Básica
-------------

Esta es una introducción a tres tipos de técnicas de caché: de página, de acción y
de fragmento. Por defecto, Rails proporciona caché de fragmentos. Para usar
caché de página y de acción, deberá agregar `actionpack-page_caching` y
`actionpack-action_caching` a su `Gemfile`.

Por defecto, la caché solo está habilitada en su entorno de producción. Puede probar
la caché localmente ejecutando `rails dev:cache`, o configurando
[`config.action_controller.perform_caching`][] en `config/environments/development.rb` a `true`.

NOTA: Cambiar el valor de `config.action_controller.perform_caching` solo
tendrá efecto en la caché proporcionada por Action Controller.
Por ejemplo, no afectará la caché de bajo nivel, que abordamos
[a continuación](#caché-de-bajo-nivel).


### Caché de Página

La caché de página es un mecanismo de Rails que permite que la solicitud de una página generada
se cumpla por el servidor web (es decir, Apache o NGINX) sin tener que pasar
por toda la pila de Rails. Si bien esto es muy rápido, no se puede aplicar a
todas las situaciones (como páginas que requieren autenticación). Además, debido a que
el servidor web sirve un archivo directamente desde el sistema de archivos, deberá
implementar la expiración de la caché.

INFO: La caché de página se ha eliminado de Rails 4. Consulte la [gema actionpack-page_caching](https://github.com/rails/actionpack-page_caching).

### Caché de Acción

La caché de página no se puede utilizar para acciones que tienen filtros previos, por ejemplo, páginas que requieren autenticación. Aquí es donde entra en juego la caché de acción. La caché de acción funciona como la caché de página, excepto que la solicitud web entrante llega a la pila de Rails para que los filtros previos puedan ejecutarse antes de que se sirva la caché. Esto permite que se ejecute la autenticación y otras restricciones mientras se sirve el resultado de la salida de una copia en caché.

INFO: La caché de acción se ha eliminado de Rails 4. Consulte la [gema actionpack-action_caching](https://github.com/rails/actionpack-action_caching). Consulte [la descripción general de la expiración de caché basada en claves de DHH](https://signalvnoise.com/posts/3113-how-key-based-cache-expiration-works) para el método preferido actualmente.

### Caché de Fragmento

Las aplicaciones web dinámicas suelen construir páginas con una variedad de componentes que no
todos tienen las mismas características de caché. Cuando diferentes partes de la
página necesitan ser almacenadas en caché y expiradas por separado, se puede usar la Caché de Fragmento.

La Caché de Fragmento permite que un fragmento de lógica de vista se envuelva en un bloque de caché y se sirva desde la tienda de caché cuando llegue la siguiente solicitud.

Por ejemplo, si desea almacenar en caché cada producto en una página, puede usar este
código:

```html+erb
<% @products.each do |product| %>
  <% cache product do %>
    <%= render product %>
  <% end %>
<% end %>
```

Cuando su aplicación recibe su primera solicitud a esta página, Rails escribirá
una nueva entrada de caché con una clave única. Una clave se ve algo como esto:

```
views/products/index:bea67108094918eeba42cd4a6e786901/products/1
```

La cadena de caracteres en el medio es un resumen del árbol de plantillas. Es un resumen de hash
calculado en función del contenido del fragmento de vista que está almacenando en caché. Si
cambia el fragmento de vista (por ejemplo, cambia el HTML), el resumen cambiará,
caducando el archivo existente.

Se almacena una versión de caché, derivada del registro del producto, en la entrada de caché.
Cuando se modifica el producto, la versión de caché cambia y se ignoran los fragmentos en caché
que contienen la versión anterior.

CONSEJO: Las tiendas de caché como Memcached eliminarán automáticamente los archivos de caché antiguos.

Si desea almacenar en caché un fragmento bajo ciertas condiciones, puede usar
`cache_if` o `cache_unless`:

```erb
<% cache_if admin?, product do %>
  <%= render product %>
<% end %>
```

#### Caché de Colección

El ayudante `render` también puede almacenar en caché plantillas individuales renderizadas para una colección.
Incluso puede superar el ejemplo anterior con `each` leyendo todas las plantillas en caché
a la vez en lugar de una por una. Esto se hace pasando `cached: true` al renderizar la colección:
```html+erb
<%= render partial: 'products/product', collection: @products, cached: true %>
```

Todos los templates en caché de renderizaciones anteriores se buscarán de una vez con mucha mayor velocidad. Además, los templates que aún no se hayan guardado en caché se escribirán en caché y se buscarán en la siguiente renderización.

### Caché de muñecas rusas

Es posible anidar fragmentos en caché dentro de otros fragmentos en caché. Esto se conoce como caché de muñecas rusas.

La ventaja del caché de muñecas rusas es que si se actualiza un solo producto, se pueden reutilizar todos los demás fragmentos internos al regenerar el fragmento externo.

Como se explicó en la sección anterior, un archivo en caché caducará si cambia el valor de `updated_at` para un registro en el que el archivo en caché depende directamente. Sin embargo, esto no caducará ninguna caché en la que el fragmento esté anidado.

Por ejemplo, considera la siguiente vista:

```erb
<% cache product do %>
  <%= render product.games %>
<% end %>
```

Que a su vez renderiza esta vista:

```erb
<% cache game do %>
  <%= render game %>
<% end %>
```

Si se cambia cualquier atributo de `game`, el valor de `updated_at` se establecerá en el tiempo actual, lo que expirará la caché. Sin embargo, como no se cambiará `updated_at` para el objeto de producto, esa caché no caducará y tu aplicación servirá datos obsoletos. Para solucionar esto, vinculamos los modelos con el método `touch`:

```ruby
class Product < ApplicationRecord
  has_many :games
end

class Game < ApplicationRecord
  belongs_to :product, touch: true
end
```

Con `touch` establecido en `true`, cualquier acción que cambie `updated_at` para un registro de juego también lo cambiará para el producto asociado, lo que expirará la caché.

### Caché de parciales compartidos

Es posible compartir parciales y su caché asociada entre archivos con diferentes tipos MIME. Por ejemplo, el caché de parciales compartidos permite a los escritores de plantillas compartir un parcial entre archivos HTML y JavaScript. Cuando las plantillas se recopilan en las rutas de archivos del resolutor de plantillas, solo incluyen la extensión del lenguaje de plantillas y no el tipo MIME. Debido a esto, las plantillas se pueden usar para múltiples tipos MIME. Tanto las solicitudes HTML como las de JavaScript responderán al siguiente código:

```ruby
render(partial: 'hotels/hotel', collection: @hotels, cached: true)
```

Cargará un archivo llamado `hotels/hotel.erb`.

Otra opción es incluir el nombre completo del parcial a renderizar.

```ruby
render(partial: 'hotels/hotel.html.erb', collection: @hotels, cached: true)
```

Cargará un archivo llamado `hotels/hotel.html.erb` en cualquier tipo MIME de archivo, por ejemplo, podrías incluir este parcial en un archivo JavaScript.

### Gestión de dependencias

Para invalidar correctamente la caché, debes definir correctamente las dependencias de caché. Rails es lo suficientemente inteligente como para manejar casos comunes, por lo que no tienes que especificar nada. Sin embargo, a veces, cuando estás trabajando con helpers personalizados, por ejemplo, necesitas definirlos explícitamente.

#### Dependencias implícitas

La mayoría de las dependencias de plantillas se pueden derivar de las llamadas a `render` en la propia plantilla. Aquí hay algunos ejemplos de llamadas a `render` que `ActionView::Digestor` sabe cómo decodificar:

```ruby
render partial: "comments/comment", collection: commentable.comments
render "comments/comments"
render 'comments/comments'
render('comments/comments')

render "header" se traduce a render("comments/header")

render(@topic)         se traduce a render("topics/topic")
render(topics)         se traduce a render("topics/topic")
render(message.topics) se traduce a render("topics/topic")
```

Por otro lado, algunas llamadas deben cambiarse para que el caché funcione correctamente. Por ejemplo, si estás pasando una colección personalizada, deberás cambiar:

```ruby
render @project.documents.where(published: true)
```

a:

```ruby
render partial: "documents/document", collection: @project.documents.where(published: true)
```

#### Dependencias explícitas

A veces tendrás dependencias de plantillas que no se pueden derivar en absoluto. Este es típicamente el caso cuando la renderización ocurre en helpers. Aquí tienes un ejemplo:

```html+erb
<%= render_sortable_todolists @project.todolists %>
```

Deberás usar un formato de comentario especial para indicar eso:

```html+erb
<%# Template Dependency: todolists/todolist %>
<%= render_sortable_todolists @project.todolists %>
```

En algunos casos, como en una configuración de herencia de tabla única, es posible que tengas varias dependencias explícitas. En lugar de escribir cada plantilla, puedes usar un comodín para que coincida con cualquier plantilla en un directorio:

```html+erb
<%# Template Dependency: events/* %>
<%= render_categorizable_events @person.events %>
```

En cuanto a la caché de colecciones, si la plantilla parcial no comienza con una llamada de caché limpia, aún puedes beneficiarte de la caché de colecciones agregando un formato de comentario especial en cualquier lugar de la plantilla, como:

```html+erb
<%# Template Collection: notification %>
<% my_helper_that_calls_cache(some_arg, notification) do %>
  <%= notification.name %>
<% end %>
```
#### Dependencias Externas

Si utilizas un método auxiliar, por ejemplo, dentro de un bloque en caché y luego actualizas ese método auxiliar, también tendrás que actualizar la caché. Realmente no importa cómo lo hagas, pero el MD5 del archivo de plantilla debe cambiar. Una recomendación es simplemente ser explícito en un comentario, como:

```html+erb
<%# Dependencia del Auxiliar Actualizada: 28 de julio de 2015 a las 7pm %>
<%= some_helper_method(person) %>
```

### Caché de Bajo Nivel

A veces necesitas almacenar en caché un valor o el resultado de una consulta en lugar de almacenar en caché fragmentos de vista. El mecanismo de caché de Rails funciona muy bien para almacenar cualquier información serializable.

La forma más eficiente de implementar la caché de bajo nivel es utilizando el método `Rails.cache.fetch`. Este método realiza tanto la lectura como la escritura en la caché. Cuando se pasa solo un argumento, se obtiene la clave y se devuelve el valor de la caché. Si se pasa un bloque, ese bloque se ejecutará en caso de que no se encuentre en la caché. El valor de retorno del bloque se escribirá en la caché con la clave de caché dada, y ese valor de retorno se devolverá. En caso de que se encuentre en la caché, se devolverá el valor almacenado en caché sin ejecutar el bloque.

Considera el siguiente ejemplo. Una aplicación tiene un modelo `Product` con un método de instancia que busca el precio del producto en un sitio web competidor. Los datos devueltos por este método serían perfectos para la caché de bajo nivel:

```ruby
class Product < ApplicationRecord
  def competing_price
    Rails.cache.fetch("#{cache_key_with_version}/competing_price", expires_in: 12.hours) do
      Competitor::API.find_price(id)
    end
  end
end
```

NOTA: Observa que en este ejemplo utilizamos el método `cache_key_with_version`, por lo que la clave de caché resultante será algo como `products/233-20140225082222765838000/competing_price`. `cache_key_with_version` genera una cadena basada en el nombre de clase del modelo, el `id` y los atributos `updated_at`. Esta es una convención común y tiene la ventaja de invalidar la caché cada vez que se actualiza el producto. En general, cuando utilizas la caché de bajo nivel, necesitas generar una clave de caché.

#### Evita Cachear Instancias de Objetos de Active Record

Considera este ejemplo, que almacena una lista de objetos de Active Record que representan superusuarios en la caché:

```ruby
# super_admins es una consulta SQL costosa, así que no la ejecutes con demasiada frecuencia
Rails.cache.fetch("super_admin_users", expires_in: 12.hours) do
  User.super_admins.to_a
end
```

Debes __evitar__ este patrón. ¿Por qué? Porque la instancia podría cambiar. En producción, los atributos pueden diferir, o el registro puede ser eliminado. Y en desarrollo, funciona de manera poco confiable con almacenes de caché que recargan el código cuando realizas cambios.

En su lugar, almacena el ID u otro tipo de datos primitivos. Por ejemplo:

```ruby
# super_admins es una consulta SQL costosa, así que no la ejecutes con demasiada frecuencia
ids = Rails.cache.fetch("super_admin_user_ids", expires_in: 12.hours) do
  User.super_admins.pluck(:id)
end
User.where(id: ids).to_a
```

### Caché de Consultas SQL

La caché de consultas es una característica de Rails que almacena en caché el conjunto de resultados devuelto por cada consulta. Si Rails encuentra la misma consulta nuevamente en esa solicitud, utilizará el conjunto de resultados almacenado en caché en lugar de ejecutar la consulta nuevamente en la base de datos.

Por ejemplo:

```ruby
class ProductsController < ApplicationController
  def index
    # Ejecutar una consulta de búsqueda
    @products = Product.all

    # ...

    # Ejecutar la misma consulta nuevamente
    @products = Product.all
  end
end
```

La segunda vez que se ejecuta la misma consulta en la base de datos, en realidad no se va a acceder a la base de datos. La primera vez que se devuelve el resultado de la consulta se almacena en la caché de consultas (en memoria) y la segunda vez se obtiene de la memoria.

Sin embargo, es importante tener en cuenta que las cachés de consultas se crean al comienzo de una acción y se destruyen al final de esa acción, por lo que solo persisten durante la duración de la acción. Si deseas almacenar los resultados de la consulta de manera más persistente, puedes hacerlo con la caché de bajo nivel.

Almacenes de Caché
------------

Rails proporciona diferentes almacenes para los datos en caché (además de la caché SQL y de página).

### Configuración

Puedes configurar el almacén de caché predeterminado de tu aplicación estableciendo la opción de configuración `config.cache_store`. Otros parámetros se pueden pasar como argumentos al constructor del almacén de caché:

```ruby
config.cache_store = :memory_store, { size: 64.megabytes }
```

Alternativamente, puedes establecer `ActionController::Base.cache_store` fuera de un bloque de configuración.

Puedes acceder a la caché llamando a `Rails.cache`.

#### Opciones de la Piscina de Conexiones

De forma predeterminada, [`:mem_cache_store`](#activesupport-cache-memcachestore) y
[`:redis_cache_store`](#activesupport-cache-rediscachestore) están configurados para usar
piscinas de conexiones. Esto significa que si estás utilizando Puma u otro servidor con subprocesos, puedes tener varios subprocesos realizando consultas al almacén de caché al mismo tiempo.
Si desea desactivar la agrupación de conexiones, configure la opción `:pool` en `false` al configurar la caché:

```ruby
config.cache_store = :mem_cache_store, "cache.example.com", pool: false
```

También puede anular la configuración de agrupación predeterminada proporcionando opciones individuales a la opción `:pool`:

```ruby
config.cache_store = :mem_cache_store, "cache.example.com", pool: { size: 32, timeout: 1 }
```

* `:size` - Esta opción establece el número de conexiones por proceso (por defecto es 5).

* `:timeout` - Esta opción establece el número de segundos que se esperará una conexión (por defecto es 5). Si no hay ninguna conexión disponible dentro del tiempo de espera, se generará un `Timeout::Error`.

### `ActiveSupport::Cache::Store`

[`ActiveSupport::Cache::Store`][] proporciona la base para interactuar con la caché en Rails. Esta es una clase abstracta y no se puede utilizar por sí sola. En su lugar, debe utilizar una implementación concreta de la clase vinculada a un motor de almacenamiento. Rails incluye varias implementaciones, que se documentan a continuación.

Los principales métodos de API son [`read`][ActiveSupport::Cache::Store#read], [`write`][ActiveSupport::Cache::Store#write], [`delete`][ActiveSupport::Cache::Store#delete], [`exist?`][ActiveSupport::Cache::Store#exist?] y [`fetch`][ActiveSupport::Cache::Store#fetch].

Las opciones pasadas al constructor de la caché se tratarán como opciones predeterminadas para los métodos de API correspondientes.

### `ActiveSupport::Cache::MemoryStore`

[`ActiveSupport::Cache::MemoryStore`][] mantiene las entradas en memoria en el mismo proceso de Ruby. La caché tiene un tamaño limitado especificado enviando la opción `:size` al inicializador (por defecto es 32Mb). Cuando la caché supera el tamaño asignado, se realizará una limpieza y se eliminarán las entradas menos utilizadas.

```ruby
config.cache_store = :memory_store, { size: 64.megabytes }
```

Si está ejecutando varios procesos de servidor Ruby on Rails (lo cual es el caso si está utilizando Phusion Passenger o el modo agrupado de puma), las instancias de los procesos del servidor Rails no podrán compartir datos de caché entre sí. Esta caché no es adecuada para implementaciones de aplicaciones grandes. Sin embargo, puede funcionar bien para sitios pequeños con poco tráfico y solo un par de procesos de servidor, así como para entornos de desarrollo y pruebas.

Los nuevos proyectos de Rails están configurados para utilizar esta implementación en el entorno de desarrollo de forma predeterminada.

NOTA: Dado que los procesos no compartirán datos de caché al utilizar `:memory_store`, no será posible leer, escribir o expirar manualmente la caché a través de la consola de Rails.

### `ActiveSupport::Cache::FileStore`

[`ActiveSupport::Cache::FileStore`][] utiliza el sistema de archivos para almacenar las entradas. Debe especificar la ruta al directorio donde se almacenarán los archivos de la caché al inicializarla.

```ruby
config.cache_store = :file_store, "/ruta/al/directorio/de/caché"
```

Con esta caché, varios procesos de servidor en el mismo host pueden compartir una caché. Esta caché es adecuada para sitios con poco a mediano tráfico que se sirven desde uno o dos hosts. Los procesos de servidor que se ejecutan en hosts diferentes podrían compartir una caché utilizando un sistema de archivos compartido, pero esta configuración no se recomienda.

Dado que la caché crecerá hasta que el disco esté lleno, se recomienda eliminar periódicamente las entradas antiguas.

Esta es la implementación de caché predeterminada (en `"#{root}/tmp/cache/"`) si no se proporciona una configuración explícita de `config.cache_store`.

### `ActiveSupport::Cache::MemCacheStore`

[`ActiveSupport::Cache::MemCacheStore`][] utiliza el servidor `memcached` de Danga para proporcionar una caché centralizada para su aplicación. Rails utiliza la gema `dalli` incluida de forma predeterminada. Actualmente, esta es la caché más popular para sitios web en producción. Se puede utilizar para proporcionar un clúster de caché único y compartido con un rendimiento y redundancia muy altos.

Al inicializar la caché, debe especificar las direcciones de todos los servidores `memcached` en su clúster, o asegurarse de que la variable de entorno `MEMCACHE_SERVERS` se haya configurado correctamente.

```ruby
config.cache_store = :mem_cache_store, "cache-1.example.com", "cache-2.example.com"
```

Si no se especifica ninguna, asumirá que `memcached` se está ejecutando en `localhost` en el puerto predeterminado (`127.0.0.1:11211`), pero esta no es una configuración ideal para sitios más grandes.

```ruby
config.cache_store = :mem_cache_store # Utilizará $MEMCACHE_SERVERS, luego 127.0.0.1:11211
```

Consulte la documentación de [`Dalli::Client`](https://www.rubydoc.info/gems/dalli/Dalli/Client#initialize-instance_method) para obtener los tipos de direcciones admitidos.

El método [`write`][ActiveSupport::Cache::MemCacheStore#write] (y `fetch`) en esta caché acepta opciones adicionales que aprovechan las características específicas de `memcached`.

### `ActiveSupport::Cache::RedisCacheStore`

[`ActiveSupport::Cache::RedisCacheStore`][] aprovecha el soporte de Redis para la eliminación automática cuando alcanza la memoria máxima, lo que le permite comportarse de manera similar a un servidor de caché Memcached.

Nota de implementación: Redis no expira las claves de forma predeterminada, así que asegúrese de utilizar un servidor de caché Redis dedicado. ¡No llene su servidor Redis persistente con datos de caché volátiles! Lea detenidamente la guía de configuración del servidor de caché Redis en [Redis cache server setup guide](https://redis.io/topics/lru-cache).

Para un servidor Redis solo de caché, establezca `maxmemory-policy` en una de las variantes de `allkeys`. Redis 4+ admite la eliminación menos utilizada (`allkeys-lfu`), que es una excelente opción predeterminada. Redis 3 y versiones anteriores deben utilizar la eliminación menos reciente utilizada (`allkeys-lru`).
Establezca los tiempos de espera de lectura y escritura de la caché relativamente bajos. Regenerar un valor en caché a menudo es más rápido que esperar más de un segundo para recuperarlo. Los tiempos de espera de lectura y escritura tienen un valor predeterminado de 1 segundo, pero se pueden establecer más bajos si su red tiene una latencia consistentemente baja.

De forma predeterminada, el almacén de caché no intentará reconectarse a Redis si la conexión falla durante una solicitud. Si experimenta desconexiones frecuentes, es posible que desee habilitar los intentos de reconexión.

Las lecturas y escrituras en caché nunca generan excepciones; simplemente devuelven `nil` en su lugar, comportándose como si no hubiera nada en la caché. Para evaluar si su caché está generando excepciones, puede proporcionar un `error_handler` para informar a un servicio de recopilación de excepciones. Debe aceptar tres argumentos de palabras clave: `method`, el método del almacén de caché que se llamó originalmente; `returning`, el valor que se devolvió al usuario, normalmente `nil`; y `exception`, la excepción que se rescató.

Para comenzar, agregue la gema de Redis a su Gemfile:

```ruby
gem 'redis'
```

Finalmente, agregue la configuración en el archivo `config/environments/*.rb` relevante:

```ruby
config.cache_store = :redis_cache_store, { url: ENV['REDIS_URL'] }
```

Un almacén de caché de Redis más complejo y de producción puede verse así:

```ruby
cache_servers = %w(redis://cache-01:6379/0 redis://cache-02:6379/0)
config.cache_store = :redis_cache_store, { url: cache_servers,

  connect_timeout:    30,  # Por defecto, 20 segundos
  read_timeout:       0.2, # Por defecto, 1 segundo
  write_timeout:      0.2, # Por defecto, 1 segundo
  reconnect_attempts: 1,   # Por defecto, 0

  error_handler: -> (method:, returning:, exception:) {
    # Reportar errores a Sentry como advertencias
    Sentry.capture_exception exception, level: 'warning',
      tags: { method: method, returning: returning }
  }
}
```


### `ActiveSupport::Cache::NullStore`

[`ActiveSupport::Cache::NullStore`][] está limitado a cada solicitud web y borra los valores almacenados al final de una solicitud. Está destinado a ser utilizado en entornos de desarrollo y pruebas. Puede ser muy útil cuando tiene código que interactúa directamente con `Rails.cache` pero el almacenamiento en caché interfiere con la visualización de los resultados de los cambios de código.

```ruby
config.cache_store = :null_store
```


### Almacenes de caché personalizados

Puede crear su propio almacén de caché personalizado simplemente extendiendo `ActiveSupport::Cache::Store` e implementando los métodos correspondientes. De esta manera, puede intercambiar cualquier cantidad de tecnologías de almacenamiento en caché en su aplicación de Rails.

Para usar un almacén de caché personalizado, simplemente configure el almacén de caché como una nueva instancia de su clase personalizada.

```ruby
config.cache_store = MyCacheStore.new
```

Claves de caché
----------

Las claves utilizadas en una caché pueden ser cualquier objeto que responda a `cache_key` o `to_param`. Puede implementar el método `cache_key` en sus clases si necesita generar claves personalizadas. Active Record generará claves basadas en el nombre de la clase y el ID del registro.

Puede usar Hashes y Arrays de valores como claves de caché.

```ruby
# Esta es una clave de caché válida
Rails.cache.read(site: "mysite", owners: [owner_1, owner_2])
```

Las claves que utiliza en `Rails.cache` no serán las mismas que las que se utilizan realmente en el motor de almacenamiento. Pueden modificarse con un espacio de nombres o alterarse para adaptarse a las restricciones del backend de tecnología. Esto significa, por ejemplo, que no puede guardar valores con `Rails.cache` y luego intentar extraerlos con la gema `dalli`. Sin embargo, tampoco necesita preocuparse por exceder el límite de tamaño de memcached o violar las reglas de sintaxis.

Soporte para GET condicional
-----------------------

Las solicitudes GET condicionales son una característica de la especificación HTTP que proporciona una forma para que los servidores web indiquen a los navegadores que la respuesta a una solicitud GET no ha cambiado desde la última solicitud y se puede obtener de forma segura desde la caché del navegador.

Funcionan utilizando los encabezados `HTTP_IF_NONE_MATCH` y `HTTP_IF_MODIFIED_SINCE` para enviar de ida y vuelta un identificador de contenido único y la marca de tiempo de cuándo se modificó por última vez el contenido. Si el navegador realiza una solicitud en la que el identificador de contenido (ETag) o la marca de tiempo de la última modificación coincide con la versión del servidor, entonces el servidor solo necesita enviar una respuesta vacía con un estado de no modificado.

Es responsabilidad del servidor (es decir, nuestro) buscar una marca de tiempo de última modificación y la cabecera if-none-match y determinar si enviar o no la respuesta completa. Con el soporte de GET condicional en Rails, esta es una tarea bastante sencilla:

```ruby
class ProductsController < ApplicationController
  def show
    @product = Product.find(params[:id])

    # Si la solicitud no es actual según la marca de tiempo y el valor de etag dados
    # (es decir, necesita procesarse nuevamente) entonces ejecute este bloque
    if stale?(last_modified: @product.updated_at.utc, etag: @product.cache_key_with_version)
      respond_to do |wants|
        # ... procesamiento normal de la respuesta
      end
    end

    # Si la solicitud es nueva (es decir, no se ha modificado) entonces no necesita hacer
    # nada. La representación predeterminada verifica esto utilizando los parámetros
    # utilizados en la llamada anterior a stale? y automáticamente enviará un
    # :not_modified. Así que eso es todo, has terminado.
  end
end
```
En lugar de un hash de opciones, también puedes simplemente pasar un modelo. Rails utilizará los métodos `updated_at` y `cache_key_with_version` para establecer `last_modified` y `etag`:

```ruby
class ProductsController < ApplicationController
  def show
    @product = Product.find(params[:id])

    if stale?(@product)
      respond_to do |wants|
        # ... procesamiento normal de la respuesta
      end
    end
  end
end
```

Si no tienes ningún procesamiento especial de la respuesta y estás utilizando el mecanismo de renderizado por defecto (es decir, no estás utilizando `respond_to` o llamando a `render` tú mismo), entonces tienes un ayudante fácil en `fresh_when`:

```ruby
class ProductsController < ApplicationController
  # Esto enviará automáticamente un :not_modified si la solicitud es fresca,
  # y renderizará la plantilla por defecto (product.*) si está obsoleta.

  def show
    @product = Product.find(params[:id])
    fresh_when last_modified: @product.published_at.utc, etag: @product
  end
end
```

A veces queremos cachear una respuesta, por ejemplo una página estática, que nunca caduca. Para lograr esto, podemos usar el ayudante `http_cache_forever` y de esta manera el navegador y los proxies la cachearán indefinidamente.

Por defecto, las respuestas cacheadas serán privadas, solo se cachearán en el navegador web del usuario. Para permitir que los proxies cacheen la respuesta, establece `public: true` para indicar que pueden servir la respuesta caché a todos los usuarios.

Usando este ayudante, el encabezado `last_modified` se establece en `Time.new(2011, 1, 1).utc` y el encabezado `expires` se establece en 100 años.

ADVERTENCIA: Utiliza este método con cuidado ya que el navegador/proxy no podrá invalidar la respuesta caché a menos que se borre la caché del navegador de forma forzada.

```ruby
class HomeController < ApplicationController
  def index
    http_cache_forever(public: true) do
      render
    end
  end
end
```

### ETags Fuertes vs ETags Débiles

Rails genera ETags débiles de forma predeterminada. Las ETags débiles permiten que las respuestas semánticamente equivalentes tengan las mismas ETags, incluso si sus cuerpos no coinciden exactamente. Esto es útil cuando no queremos que la página se regenere por cambios menores en el cuerpo de la respuesta.

Las ETags débiles tienen un prefijo `W/` para diferenciarlas de las ETags fuertes.

```
W/"618bbc92e2d35ea1945008b42799b0e7" → ETag Débil
"618bbc92e2d35ea1945008b42799b0e7" → ETag Fuerte
```

A diferencia de las ETags débiles, las ETags fuertes implican que la respuesta debe ser exactamente la misma y byte por byte idéntica. Es útil cuando se hacen solicitudes de rango dentro de un archivo de video o PDF grande. Algunas CDNs solo admiten ETags fuertes, como Akamai. Si necesitas generar una ETag fuerte, puedes hacerlo de la siguiente manera.

```ruby
class ProductsController < ApplicationController
  def show
    @product = Product.find(params[:id])
    fresh_when last_modified: @product.published_at.utc, strong_etag: @product
  end
end
```

También puedes establecer la ETag fuerte directamente en la respuesta.

```ruby
response.strong_etag = response.body # => "618bbc92e2d35ea1945008b42799b0e7"
```

Caché en Desarrollo
----------------------

Es común querer probar la estrategia de caché de tu aplicación en modo de desarrollo. Rails proporciona el comando `dev:cache` para alternar fácilmente la caché activada/desactivada.

```bash
$ bin/rails dev:cache
El modo de desarrollo ahora está en caché.
$ bin/rails dev:cache
El modo de desarrollo ya no está en caché.
```

Por defecto, cuando la caché del modo de desarrollo está *desactivada*, Rails utiliza [`:null_store`](#activesupport-cache-nullstore).

Referencias
----------

* [Artículo de DHH sobre la expiración basada en claves](https://signalvnoise.com/posts/3113-how-key-based-cache-expiration-works)
* [Railscast de Ryan Bates sobre los digestos de caché](http://railscasts.com/episodes/387-cache-digests)
[`config.action_controller.perform_caching`]: configuring.html#config-action-controller-perform-caching
[`ActiveSupport::Cache::Store`]: https://api.rubyonrails.org/classes/ActiveSupport/Cache/Store.html
[ActiveSupport::Cache::Store#delete]: https://api.rubyonrails.org/classes/ActiveSupport/Cache/Store.html#method-i-delete
[ActiveSupport::Cache::Store#exist?]: https://api.rubyonrails.org/classes/ActiveSupport/Cache/Store.html#method-i-exist-3F
[ActiveSupport::Cache::Store#fetch]: https://api.rubyonrails.org/classes/ActiveSupport/Cache/Store.html#method-i-fetch
[ActiveSupport::Cache::Store#read]: https://api.rubyonrails.org/classes/ActiveSupport/Cache/Store.html#method-i-read
[ActiveSupport::Cache::Store#write]: https://api.rubyonrails.org/classes/ActiveSupport/Cache/Store.html#method-i-write
[`ActiveSupport::Cache::MemoryStore`]: https://api.rubyonrails.org/classes/ActiveSupport/Cache/MemoryStore.html
[`ActiveSupport::Cache::FileStore`]: https://api.rubyonrails.org/classes/ActiveSupport/Cache/FileStore.html
[`ActiveSupport::Cache::MemCacheStore`]: https://api.rubyonrails.org/classes/ActiveSupport/Cache/MemCacheStore.html
[ActiveSupport::Cache::MemCacheStore#write]: https://api.rubyonrails.org/classes/ActiveSupport/Cache/MemCacheStore.html#method-i-write
[`ActiveSupport::Cache::RedisCacheStore`]: https://api.rubyonrails.org/classes/ActiveSupport/Cache/RedisCacheStore.html
[`ActiveSupport::Cache::NullStore`]: https://api.rubyonrails.org/classes/ActiveSupport/Cache/NullStore.html
