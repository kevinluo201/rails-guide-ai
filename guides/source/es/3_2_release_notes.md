**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 30550ed8fa3c0983f3d99a0e91571a98
Notas de lanzamiento de Ruby on Rails 3.2
==========================================

Aspectos destacados en Rails 3.2:

* Modo de desarrollo más rápido
* Nuevo motor de enrutamiento
* Explicaciones automáticas de consultas
* Registro etiquetado

Estas notas de lanzamiento solo cubren los cambios principales. Para conocer las diversas correcciones de errores y cambios, consulte los registros de cambios o visite la [lista de confirmaciones](https://github.com/rails/rails/commits/3-2-stable) en el repositorio principal de Rails en GitHub.

--------------------------------------------------------------------------------

Actualización a Rails 3.2
-------------------------

Si está actualizando una aplicación existente, es una buena idea tener una buena cobertura de pruebas antes de comenzar. También debe actualizar primero a Rails 3.1 en caso de que no lo haya hecho y asegurarse de que su aplicación siga funcionando como se espera antes de intentar una actualización a Rails 3.2. Luego, tenga en cuenta los siguientes cambios:

### Rails 3.2 requiere al menos Ruby 1.8.7

Rails 3.2 requiere Ruby 1.8.7 o superior. El soporte para todas las versiones anteriores de Ruby se ha eliminado oficialmente y debe actualizar lo antes posible. Rails 3.2 también es compatible con Ruby 1.9.2.

CONSEJO: Tenga en cuenta que Ruby 1.8.7 p248 y p249 tienen errores de serialización que hacen que Rails se bloquee. Ruby Enterprise Edition los ha corregido desde el lanzamiento de 1.8.7-2010.02. En cuanto a la versión 1.9, Ruby 1.9.1 no se puede usar porque se bloquea por completo, por lo que si desea usar 1.9.x, pase a 1.9.2 o 1.9.3 para un funcionamiento sin problemas.

### Qué actualizar en sus aplicaciones

* Actualice su `Gemfile` para depender de
    * `rails = 3.2.0`
    * `sass-rails ~> 3.2.3`
    * `coffee-rails ~> 3.2.1`
    * `uglifier >= 1.0.3`

* Rails 3.2 deprecia `vendor/plugins` y Rails 4.0 los eliminará por completo. Puede comenzar a reemplazar estos complementos extrayéndolos como gemas y agregándolos en su `Gemfile`. Si elige no convertirlos en gemas, puede moverlos a, por ejemplo, `lib/my_plugin/*` y agregar un inicializador adecuado en `config/initializers/my_plugin.rb`.

* Hay algunos cambios de configuración nuevos que debe agregar en `config/environments/development.rb`:

    ```ruby
    # Levanta una excepción en la protección de asignación masiva para modelos de Active Record
    config.active_record.mass_assignment_sanitizer = :strict

    # Registra el plan de consulta para consultas que tardan más de esto (funciona
    # con SQLite, MySQL y PostgreSQL)
    config.active_record.auto_explain_threshold_in_seconds = 0.5
    ```

    La configuración `mass_assignment_sanitizer` también debe agregarse en `config/environments/test.rb`:

    ```ruby
    # Levanta una excepción en la protección de asignación masiva para modelos de Active Record
    config.active_record.mass_assignment_sanitizer = :strict
    ```

### Qué actualizar en sus motores

Reemplace el código debajo del comentario en `script/rails` con el siguiente contenido:

```ruby
ENGINE_ROOT = File.expand_path('../..', __FILE__)
ENGINE_PATH = File.expand_path('../../lib/your_engine_name/engine', __FILE__)

require "rails/all"
require "rails/engine/commands"
```

Creando una aplicación Rails 3.2
--------------------------------

```bash
# Debe tener instalada la gema 'rails'
$ rails new myapp
$ cd myapp
```

### Empaquetando gemas

Rails ahora utiliza un `Gemfile` en la raíz de la aplicación para determinar las gemas que necesita para que su aplicación se inicie. Este `Gemfile` es procesado por la gema [Bundler](https://github.com/carlhuda/bundler), que luego instala todas las dependencias. Incluso puede instalar todas las dependencias localmente en su aplicación para que no dependa de las gemas del sistema.

Más información: [Página principal de Bundler](https://bundler.io/)

### Viviendo al límite

`Bundler` y `Gemfile` facilitan congelar su aplicación Rails con el nuevo comando `bundle` dedicado. Si desea empaquetar directamente desde el repositorio Git, puede pasar la bandera `--edge`:

```bash
$ rails new myapp --edge
```

Si tiene una copia local del repositorio de Rails y desea generar una aplicación utilizando eso, puede pasar la bandera `--dev`:

```bash
$ ruby /ruta/a/rails/railties/bin/rails new myapp --dev
```

Características principales
--------------------------

### Modo de desarrollo y enrutamiento más rápido

Rails 3.2 viene con un modo de desarrollo notablemente más rápido. Inspirado en [Active Reload](https://github.com/paneq/active_reload), Rails recarga las clases solo cuando los archivos realmente cambian. Las mejoras de rendimiento son dramáticas en una aplicación más grande. El reconocimiento de rutas también se volvió mucho más rápido gracias al nuevo motor [Journey](https://github.com/rails/journey).

### Explicaciones automáticas de consultas

Rails 3.2 viene con una función interesante que explica las consultas generadas por Arel al definir un método `explain` en `ActiveRecord::Relation`. Por ejemplo, puede ejecutar algo como `puts Person.active.limit(5).explain` y se explicará la consulta que Arel produce. Esto permite verificar los índices adecuados y realizar optimizaciones adicionales.

Las consultas que tardan más de medio segundo en ejecutarse se explican *automáticamente* en el modo de desarrollo. Por supuesto, este umbral se puede cambiar.

### Registro etiquetado
Cuando se ejecuta una aplicación multiusuario y multi cuenta, es de gran ayuda poder filtrar el registro por quién hizo qué. TaggedLogging en Active Support ayuda a hacer exactamente eso al marcar las líneas de registro con subdominios, identificadores de solicitud y cualquier otra cosa que ayude a depurar dichas aplicaciones.

Documentación
-------------

A partir de Rails 3.2, las guías de Rails están disponibles para Kindle y las aplicaciones gratuitas de lectura de Kindle para iPad, iPhone, Mac, Android, etc.

Railties
--------

* Acelera el desarrollo al volver a cargar solo las clases si los archivos de dependencias han cambiado. Esto se puede desactivar configurando `config.reload_classes_only_on_change` en falso.

* Las nuevas aplicaciones obtienen una bandera `config.active_record.auto_explain_threshold_in_seconds` en los archivos de configuración de entornos. Con un valor de `0.5` en `development.rb` y comentado en `production.rb`. No se menciona en `test.rb`.

* Se agregó `config.exceptions_app` para establecer la aplicación de excepciones invocada por el middleware `ShowException` cuando ocurre una excepción. El valor predeterminado es `ActionDispatch::PublicExceptions.new(Rails.public_path)`.

* Se agregó un middleware `DebugExceptions` que contiene características extraídas del middleware `ShowExceptions`.

* Muestra las rutas de los motores montados en `rake routes`.

* Permite cambiar el orden de carga de los railties con `config.railties_order` de la siguiente manera:

    ```ruby
    config.railties_order = [Blog::Engine, :main_app, :all]
    ```

* Scaffold devuelve 204 No Content para solicitudes de API sin contenido. Esto hace que scaffold funcione con jQuery de inmediato.

* Actualiza el middleware `Rails::Rack::Logger` para aplicar cualquier etiqueta establecida en `config.log_tags` a `ActiveSupport::TaggedLogging`. Esto facilita etiquetar las líneas de registro con información de depuración como el subdominio y el identificador de solicitud, ambos muy útiles en la depuración de aplicaciones de producción multiusuario.

* Las opciones predeterminadas para `rails new` se pueden establecer en `~/.railsrc`. Puede especificar argumentos adicionales de línea de comandos que se utilizarán cada vez que se ejecute `rails new` en el archivo de configuración `.railsrc` en su directorio de inicio.

* Agrega un alias `d` para `destroy`. Esto también funciona para los motores.

* Los atributos en los generadores de scaffold y modelo tienen como valor predeterminado string. Esto permite lo siguiente: `bin/rails g scaffold Post title body:text author`

* Los generadores de scaffold/modelo/migración ahora aceptan modificadores "index" y "uniq". Por ejemplo,

    ```bash
    bin/rails g scaffold Post title:string:index author:uniq price:decimal{7,2}
    ```

    creará índices para `title` y `author`, siendo este último un índice único. Algunos tipos como decimal aceptan opciones personalizadas. En el ejemplo, `price` será una columna decimal con precisión y escala establecidas en 7 y 2 respectivamente.

* La gema Turn se ha eliminado del archivo `Gemfile` predeterminado.

* Se eliminó el antiguo generador de complementos `rails generate plugin` a favor del comando `rails plugin new`.

* Se eliminó la antigua API `config.paths.app.controller` a favor de `config.paths["app/controller"]`.

### Deprecaciones

* `Rails::Plugin` está obsoleto y se eliminará en Rails 4.0. En lugar de agregar complementos a `vendor/plugins`, use gemas o bundler con dependencias de ruta o git.

Action Mailer
-------------

* Se actualizó la versión de `mail` a 2.4.0.

* Se eliminó la antigua API de Action Mailer que estaba obsoleta desde Rails 3.0.

Action Pack
-----------

### Action Controller

* Hace que `ActiveSupport::Benchmarkable` sea un módulo predeterminado para `ActionController::Base`, por lo que el método `#benchmark` vuelve a estar disponible en el contexto del controlador como solía ser.

* Se agregó la opción `:gzip` a `caches_page`. La opción predeterminada se puede configurar globalmente utilizando `page_cache_compression`.

* Ahora Rails utilizará su diseño predeterminado (como "layouts/application") cuando especifique un diseño con la condición `:only` y `:except`, y esas condiciones no se cumplan.

    ```ruby
    class CarsController
      layout 'single_car', :only => :show
    end
    ```

    Rails utilizará `layouts/single_car` cuando se realice una solicitud en la acción `:show`, y utilizará `layouts/application` (o `layouts/cars`, si existe) cuando se realice una solicitud en cualquier otra acción.

* `form_for` se cambió para usar `#{action}_#{as}` como la clase y el id de CSS si se proporciona la opción `:as`. Las versiones anteriores usaban `#{as}_#{action}`.

* `ActionController::ParamsWrapper` en los modelos de Active Record ahora solo envuelve los atributos `attr_accessible` si se han establecido. Si no, solo se envolverán los atributos devueltos por el método de clase `attribute_names`. Esto soluciona el envoltorio de atributos anidados agregándolos a `attr_accessible`.

* Registra "Filter chain halted as CALLBACKNAME rendered or redirected" cada vez que un callback anterior se detiene.

* Se refactorizó `ActionDispatch::ShowExceptions`. El controlador es responsable de elegir si mostrar excepciones. Es posible anular `show_detailed_exceptions?` en los controladores para especificar qué solicitudes deben proporcionar información de depuración en caso de errores.

* Los respondedores ahora devuelven 204 No Content para solicitudes de API sin cuerpo de respuesta (como en el nuevo scaffold).

* Se refactorizó `ActionController::TestCase` cookies. Asignar cookies para casos de prueba ahora debe usar `cookies[]`.
```ruby
cookies[:email] = 'user@example.com'
get :index
assert_equal 'user@example.com', cookies[:email]
```

Para borrar las cookies, usa `clear`.

```ruby
cookies.clear
get :index
assert_nil cookies[:email]
```

Ahora ya no escribimos HTTP_COOKIE y el jar de cookies es persistente entre las solicitudes, por lo que si necesitas manipular el entorno para tu prueba, debes hacerlo antes de que se cree el jar de cookies.

* `send_file` ahora adivina el tipo MIME a partir de la extensión del archivo si no se proporciona `:type`.

* Se agregaron entradas de tipo MIME para PDF, ZIP y otros formatos.

* Se permite que `fresh_when/stale?` tome un registro en lugar de un hash de opciones.

* Se cambió el nivel de registro de advertencia por falta de token CSRF de `:debug` a `:warn`.

* Los activos deben usar el protocolo de solicitud de forma predeterminada o, si no hay solicitud disponible, usar el valor predeterminado relativo.

#### Deprecaciones

* Se deprecó la búsqueda implícita de diseño en controladores cuyo padre tenía un diseño explícito establecido:

```ruby
class ApplicationController
  layout "application"
end

class PostsController < ApplicationController
end
```

En el ejemplo anterior, `PostsController` ya no buscará automáticamente un diseño de posts. Si necesitas esta funcionalidad, puedes eliminar `layout "application"` de `ApplicationController` o establecerlo explícitamente en `nil` en `PostsController`.

* Se deprecó `ActionController::UnknownAction` a favor de `AbstractController::ActionNotFound`.

* Se deprecó `ActionController::DoubleRenderError` a favor de `AbstractController::DoubleRenderError`.

* Se deprecó `method_missing` a favor de `action_missing` para acciones faltantes.

* Se deprecó `ActionController#rescue_action`, `ActionController#initialize_template_class` y `ActionController#assign_shortcuts`.

### Action Dispatch

* Se agregó `config.action_dispatch.default_charset` para configurar el conjunto de caracteres predeterminado para `ActionDispatch::Response`.

* Se agregó el middleware `ActionDispatch::RequestId` que hace que un encabezado X-Request-Id único esté disponible en la respuesta y habilita el método `ActionDispatch::Request#uuid`. Esto facilita el seguimiento de solicitudes de principio a fin en la pila y permite identificar solicitudes individuales en registros mixtos como Syslog.

* El middleware `ShowExceptions` ahora acepta una aplicación de excepciones que se encarga de renderizar una excepción cuando la aplicación falla. La aplicación se invoca con una copia de la excepción en `env["action_dispatch.exception"]` y con `PATH_INFO` reescrito al código de estado.

* Se permite configurar las respuestas de rescate a través de un railtie como en `config.action_dispatch.rescue_responses`.

#### Deprecaciones

* Se deprecó la capacidad de establecer un conjunto de caracteres predeterminado a nivel de controlador, en su lugar, usa el nuevo `config.action_dispatch.default_charset`.

### Action View

* Se agregó soporte `button_tag` a `ActionView::Helpers::FormBuilder`. Este soporte imita el comportamiento predeterminado de `submit_tag`.

```erb
<%= form_for @post do |f| %>
  <%= f.button %>
<% end %>
```

* Los ayudantes de fecha aceptan una nueva opción `:use_two_digit_numbers => true`, que renderiza cuadros de selección para meses y días con un cero inicial sin cambiar los valores respectivos. Por ejemplo, esto es útil para mostrar fechas en estilo ISO 8601 como '2011-08-01'.

* Puedes proporcionar un espacio de nombres para tu formulario para asegurar la unicidad de los atributos id en los elementos del formulario. El atributo de espacio de nombres se prefijará con un guión bajo en el id HTML generado.

```erb
<%= form_for(@offer, :namespace => 'namespace') do |f| %>
  <%= f.label :version, 'Version' %>:
  <%= f.text_field :version %>
<% end %>
```

* Limita el número de opciones para `select_year` a 1000. Pasa la opción `:max_years_allowed` para establecer tu propio límite.

* `content_tag_for` y `div_for` ahora pueden tomar una colección de registros. También cederá el registro como primer argumento si estableces un argumento receptor en tu bloque. Entonces, en lugar de hacer esto:

```ruby
@items.each do |item|
  content_tag_for(:li, item) do
    Title: <%= item.title %>
  end
end
```

Puedes hacer esto:

```ruby
content_tag_for(:li, @items) do |item|
  Title: <%= item.title %>
end
```

* Se agregó el método de ayuda `font_path` que calcula la ruta a un activo de fuente en `public/fonts`.

#### Deprecaciones

* Pasar formatos o controladores a `render :template` y similares como `render :template => "foo.html.erb"` está deprecado. En su lugar, puedes proporcionar `:handlers` y `:formats` directamente como opciones: `render :template => "foo", :formats => [:html, :js], :handlers => :erb`.

### Sprockets

* Se agrega la opción de configuración `config.assets.logger` para controlar el registro de Sprockets. Establécelo en `false` para desactivar el registro y en `nil` para usar `Rails.logger` de forma predeterminada.

Active Record
-------------

* Las columnas booleanas con valores 'on' y 'ON' se convierten en verdadero.

* Cuando el método `timestamps` crea las columnas `created_at` y `updated_at`, las hace no nulas de forma predeterminada.

* Se implementó `ActiveRecord::Relation#explain`.

* Se implementó `ActiveRecord::Base.silence_auto_explain`, que permite al usuario desactivar selectivamente los EXPLAIN automáticos dentro de un bloque.

* Se implementó el registro automático de EXPLAIN para consultas lentas. Un nuevo parámetro de configuración `config.active_record.auto_explain_threshold_in_seconds` determina qué se considera una consulta lenta. Establecerlo en `nil` desactiva esta función. Los valores predeterminados son 0.5 en modo de desarrollo y `nil` en modos de prueba y producción. Rails 3.2 admite esta función en SQLite, MySQL (adaptador mysql2) y PostgreSQL.
* Se agregó `ActiveRecord::Base.store` para declarar almacenes de clave/valor simples de una sola columna.

    ```ruby
    class User < ActiveRecord::Base
      store :settings, accessors: [ :color, :homepage ]
    end

    u = User.new(color: 'black', homepage: '37signals.com')
    u.color                          # Atributo almacenado por el accessor
    u.settings[:country] = 'Denmark' # Cualquier atributo, incluso si no se especifica con un accessor
    ```

* Se agregó la capacidad de ejecutar migraciones solo para un alcance dado, lo que permite ejecutar migraciones solo desde un motor (por ejemplo, para revertir cambios de un motor que se deben eliminar).

    ```
    rake db:migrate SCOPE=blog
    ```

* Las migraciones copiadas de los motores ahora están agrupadas con el nombre del motor, por ejemplo `01_create_posts.blog.rb`.

* Se implementó el método `ActiveRecord::Relation#pluck` que devuelve una matriz de valores de columna directamente de la tabla subyacente. Esto también funciona con atributos serializados.

    ```ruby
    Client.where(:active => true).pluck(:id)
    # SELECT id from clients where active = 1
    ```

* Los métodos de asociación generados se crean dentro de un módulo separado para permitir la anulación y composición. Para una clase llamada MyModel, el módulo se llama `MyModel::GeneratedFeatureMethods`. Se incluye en la clase del modelo inmediatamente después del módulo `generated_attributes_methods` definido en Active Model, por lo que los métodos de asociación anulan los métodos de atributo con el mismo nombre.

* Se agregó `ActiveRecord::Relation#uniq` para generar consultas únicas.

    ```ruby
    Client.select('DISTINCT name')
    ```

    ..se puede escribir como:

    ```ruby
    Client.select(:name).uniq
    ```

    Esto también te permite revertir la unicidad en una relación:

    ```ruby
    Client.select(:name).uniq.uniq(false)
    ```

* Se admite el orden de clasificación de índices en los adaptadores SQLite, MySQL y PostgreSQL.

* Se permite que la opción `:class_name` para las asociaciones tome un símbolo además de una cadena. Esto es para evitar confusiones a los principiantes y ser coherente con el hecho de que otras opciones como `:foreign_key` ya permiten un símbolo o una cadena.

    ```ruby
    has_many :clients, :class_name => :Client # Nota que el símbolo debe estar en mayúscula
    ```

* En el modo de desarrollo, `db:drop` también elimina la base de datos de prueba para ser simétrico con `db:create`.

* La validación de unicidad sin distinción entre mayúsculas y minúsculas evita llamar a LOWER en MySQL cuando la columna ya utiliza una intercalación sin distinción entre mayúsculas y minúsculas.

* Los fixtures transaccionales enlistan todas las conexiones de base de datos activas. Puedes probar modelos en diferentes conexiones sin deshabilitar los fixtures transaccionales.

* Se agregaron los métodos `first_or_create`, `first_or_create!`, `first_or_initialize` a Active Record. Este es un enfoque mejor que los antiguos métodos dinámicos `find_or_create_by` porque es más claro qué argumentos se utilizan para encontrar el registro y cuáles se utilizan para crearlo.

    ```ruby
    User.where(:first_name => "Scarlett").first_or_create!(:last_name => "Johansson")
    ```

* Se agregó un método `with_lock` a los objetos de Active Record, que inicia una transacción, bloquea el objeto (de manera pesimista) y cede el control al bloque. El método toma un parámetro (opcional) y lo pasa a `lock!`.

    Esto permite escribir lo siguiente:

    ```ruby
    class Order < ActiveRecord::Base
      def cancel!
        transaction do
          lock!
          # ... lógica de cancelación
        end
      end
    end
    ```

    como:

    ```ruby
    class Order < ActiveRecord::Base
      def cancel!
        with_lock do
          # ... lógica de cancelación
        end
      end
    end
    ```

### Deprecaciones

* Se deprecó el cierre automático de conexiones en hilos. Por ejemplo, el siguiente código está deprecado:

    ```ruby
    Thread.new { Post.find(1) }.join
    ```

    Debe cambiarse para cerrar la conexión de la base de datos al final del hilo:

    ```ruby
    Thread.new {
      Post.find(1)
      Post.connection.close
    }.join
    ```

    Solo las personas que generan hilos en su código de aplicación deben preocuparse por este cambio.

* Los métodos `set_table_name`, `set_inheritance_column`, `set_sequence_name`, `set_primary_key`, `set_locking_column` están deprecados. En su lugar, utiliza un método de asignación. Por ejemplo, en lugar de `set_table_name`, utiliza `self.table_name=`.

    ```ruby
    class Project < ActiveRecord::Base
      self.table_name = "project"
    end
    ```

    O define tu propio método `self.table_name`:

    ```ruby
    class Post < ActiveRecord::Base
      def self.table_name
        "special_" + super
      end
    end

    Post.table_name # => "special_posts"
    ```

Active Model
------------

* Se agregó `ActiveModel::Errors#added?` para verificar si se ha agregado un error específico.

* Se agregó la capacidad de definir validaciones estrictas con `strict => true` que siempre genera una excepción cuando falla.

* Se proporciona `mass_assignment_sanitizer` como una API fácil para reemplazar el comportamiento del sanitizador. También se admite el comportamiento del sanitizador `:logger` (predeterminado) y `:strict`.

### Deprecaciones

* Se deprecó `define_attr_method` en `ActiveModel::AttributeMethods` porque esto solo existía para admitir métodos como `set_table_name` en Active Record, que a su vez están siendo deprecados.

* Se deprecó `Model.model_name.partial_path` a favor de `model.to_partial_path`.

Active Resource
---------------

* Respuestas de redireccionamiento: las respuestas 303 See Other y 307 Temporary Redirect ahora se comportan como 301 Moved Permanently y 302 Found.

Active Support
--------------

* Se agregó `ActiveSupport:TaggedLogging` que puede envolver cualquier clase `Logger` estándar para proporcionar capacidades de etiquetado.

    ```ruby
    Logger = ActiveSupport::TaggedLogging.new(Logger.new(STDOUT))

    Logger.tagged("BCX") { Logger.info "Stuff" }
    # Registra "[BCX] Stuff"

    Logger.tagged("BCX", "Jason") { Logger.info "Stuff" }
    # Registra "[BCX] [Jason] Stuff"

    Logger.tagged("BCX") { Logger.tagged("Jason") { Logger.info "Stuff" } }
    # Registra "[BCX] [Jason] Stuff"
    ```
* El método `beginning_of_week` en `Date`, `Time` y `DateTime` acepta un argumento opcional que representa el día en el que se asume que comienza la semana.

* `ActiveSupport::Notifications.subscribed` proporciona suscripciones a eventos mientras se ejecuta un bloque.

* Se definieron nuevos métodos `Module#qualified_const_defined?`, `Module#qualified_const_get` y `Module#qualified_const_set` que son análogos a los métodos correspondientes en la API estándar, pero aceptan nombres de constantes calificadas.

* Se agregó `#deconstantize` que complementa a `#demodulize` en inflexiones. Esto elimina el segmento más a la derecha en un nombre de constante calificada.

* Se agregó `safe_constantize` que convierte una cadena en una constante pero devuelve `nil` en lugar de generar una excepción si la constante (o parte de ella) no existe.

* `ActiveSupport::OrderedHash` ahora está marcado como extraíble cuando se utiliza `Array#extract_options!`.

* Se agregó `Array#prepend` como un alias de `Array#unshift` y `Array#append` como un alias de `Array#<<`.

* La definición de una cadena en blanco para Ruby 1.9 se ha ampliado para incluir espacios en blanco Unicode. Además, en Ruby 1.8, se considera que el espacio ideográfico U`3000 es un espacio en blanco.

* El inflector comprende acrónimos.

* Se agregaron `Time#all_day`, `Time#all_week`, `Time#all_quarter` y `Time#all_year` como una forma de generar rangos.

    ```ruby
    Event.where(:created_at => Time.now.all_week)
    Event.where(:created_at => Time.now.all_day)
    ```

* Se agregó `instance_accessor: false` como una opción para `Class#cattr_accessor` y amigos.

* `ActiveSupport::OrderedHash` ahora tiene un comportamiento diferente para `#each` y `#each_pair` cuando se le proporciona un bloque que acepta sus parámetros con un asterisco.

* Se agregó `ActiveSupport::Cache::NullStore` para su uso en desarrollo y pruebas.

* Se eliminó `ActiveSupport::SecureRandom` a favor de `SecureRandom` de la biblioteca estándar.

### Deprecaciones

* `ActiveSupport::Base64` está en desuso a favor de `::Base64`.

* Se deprecó `ActiveSupport::Memoizable` a favor del patrón de memorización de Ruby.

* `Module#synchronize` está en desuso sin reemplazo. Por favor, use el monitor de la biblioteca estándar de Ruby.

* Se deprecó `ActiveSupport::MessageEncryptor#encrypt` y `ActiveSupport::MessageEncryptor#decrypt`.

* `ActiveSupport::BufferedLogger#silence` está en desuso. Si desea silenciar los registros para un determinado bloque, cambie el nivel de registro para ese bloque.

* `ActiveSupport::BufferedLogger#open_log` está en desuso. Este método no debería haber sido público en primer lugar.

* Está en desuso el comportamiento de `ActiveSupport::BufferedLogger` de crear automáticamente el directorio para el archivo de registro. Asegúrese de crear el directorio para su archivo de registro antes de instanciarlo.

* `ActiveSupport::BufferedLogger#auto_flushing` está en desuso. Establezca el nivel de sincronización en el controlador de archivos subyacente de la siguiente manera. O ajuste su sistema de archivos. Ahora es la caché del sistema de archivos la que controla el vaciado.

    ```ruby
    f = File.open('foo.log', 'w')
    f.sync = true
    ActiveSupport::BufferedLogger.new f
    ```

* `ActiveSupport::BufferedLogger#flush` está en desuso. Establezca la sincronización en su controlador de archivos o ajuste su sistema de archivos.

Créditos
-------

Consulte la [lista completa de colaboradores de Rails](http://contributors.rubyonrails.org/) para conocer a las muchas personas que pasaron muchas horas haciendo de Rails el marco estable y robusto que es. Felicitaciones a todos ellos.

Las Notas de la versión de Rails 3.2 fueron compiladas por [Vijay Dev](https://github.com/vijaydev).
