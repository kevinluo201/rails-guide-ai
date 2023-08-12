**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 4d8311a1435138a81e26a7e8f537dbde
Ruby on Rails 4.2 Notas de la Versión
=====================================

Aspectos destacados en Rails 4.2:

* Active Job
* Correos Asíncronos
* Adequate Record
* Web Console
* Soporte para claves foráneas

Estas notas de la versión solo cubren los cambios principales. Para conocer otras características, correcciones de errores y cambios, consulte los registros de cambios o revise la [lista de commits](https://github.com/rails/rails/commits/4-2-stable) en el repositorio principal de Rails en GitHub.

--------------------------------------------------------------------------------

Actualizando a Rails 4.2
------------------------

Si está actualizando una aplicación existente, es una buena idea tener una buena cobertura de pruebas antes de comenzar. También debe actualizar primero a Rails 4.1 en caso de que no lo haya hecho y asegurarse de que su aplicación siga funcionando como se espera antes de intentar actualizar a Rails 4.2. Una lista de cosas a tener en cuenta al actualizar está disponible en la guía [Actualizando Ruby on Rails](upgrading_ruby_on_rails.html#upgrading-from-rails-4-1-to-rails-4-2).

Características Principales
---------------------------

### Active Job

Active Job es un nuevo framework en Rails 4.2. Es una interfaz común sobre los sistemas de encolamiento como [Resque](https://github.com/resque/resque), [Delayed Job](https://github.com/collectiveidea/delayed_job), [Sidekiq](https://github.com/mperham/sidekiq) y más.

Los trabajos escritos con la API de Active Job se ejecutan en cualquiera de las colas compatibles gracias a sus adaptadores respectivos. Active Job viene preconfigurado con un ejecutor en línea que ejecuta los trabajos de inmediato.

A menudo, los trabajos necesitan tomar objetos de Active Record como argumentos. Active Job pasa referencias de objetos como URIs (identificadores uniformes de recursos) en lugar de serializar el objeto en sí. La nueva biblioteca [Global ID](https://github.com/rails/globalid) construye URIs y busca los objetos a los que hacen referencia. Pasar objetos de Active Record como argumentos de trabajo funciona simplemente utilizando Global ID internamente.

Por ejemplo, si `trashable` es un objeto de Active Record, entonces este trabajo se ejecuta sin problemas sin necesidad de serialización:

```ruby
class TrashableCleanupJob < ActiveJob::Base
  def perform(trashable, depth)
    trashable.cleanup(depth)
  end
end
```

Consulte la guía [Conceptos Básicos de Active Job](active_job_basics.html) para obtener más información.

### Correos Asíncronos

Basándose en Active Job, Action Mailer ahora viene con un método `deliver_later` que envía correos electrónicos a través de la cola, por lo que no bloquea el controlador o el modelo si la cola es asíncrona (la cola en línea predeterminada bloquea).

Todavía es posible enviar correos electrónicos de inmediato con `deliver_now`.

### Adequate Record

Adequate Record es un conjunto de mejoras de rendimiento en Active Record que hace que las llamadas comunes de `find` y `find_by` y algunas consultas de asociación sean hasta 2 veces más rápidas.

Funciona almacenando en caché las consultas SQL comunes como declaraciones preparadas y reutilizándolas en llamadas similares, omitiendo la mayor parte del trabajo de generación de consultas en llamadas posteriores. Para obtener más detalles, consulte la publicación del blog de [Aaron Patterson](http://tenderlovemaking.com/2014/02/19/adequaterecord-pro-like-activerecord.html) (en inglés).

Active Record aprovechará automáticamente esta función en operaciones compatibles sin ninguna participación del usuario ni cambios en el código. Aquí hay algunos ejemplos de operaciones compatibles:

```ruby
Post.find(1)  # La primera llamada genera y almacena en caché la declaración preparada
Post.find(2)  # Las llamadas posteriores reutilizan la declaración preparada en caché

Post.find_by_title('primer post')
Post.find_by_title('segundo post')

Post.find_by(title: 'primer post')
Post.find_by(title: 'segundo post')

post.comments
post.comments(true)
```

Es importante destacar que, como sugieren los ejemplos anteriores, las declaraciones preparadas no almacenan en caché los valores pasados en las llamadas de método; en su lugar, tienen marcadores de posición para ellos.

La caché no se utiliza en los siguientes escenarios:

- El modelo tiene un ámbito predeterminado
- El modelo utiliza herencia de tabla única
- `find` con una lista de ids, por ejemplo:

    ```ruby
    # no se almacena en caché
    Post.find(1, 2, 3)
    Post.find([1,2])
    ```

- `find_by` con fragmentos de SQL:

    ```ruby
    Post.find_by('published_at < ?', 2.semanas.ago)
    ```

### Web Console

Las nuevas aplicaciones generadas con Rails 4.2 ahora vienen con la gema [Web Console](https://github.com/rails/web-console) de forma predeterminada. Web Console agrega una consola interactiva de Ruby en cada página de error y proporciona una vista y ayudantes de controlador `console`.

La consola interactiva en las páginas de error le permite ejecutar código en el contexto del lugar donde se originó la excepción. El ayudante `console`, si se llama en cualquier vista o controlador, inicia una consola interactiva con el contexto final, una vez que se haya completado la representación.
### Soporte para claves foráneas

El DSL de migración ahora admite agregar y eliminar claves foráneas. También se incluyen en `schema.rb`. En este momento, solo los adaptadores `mysql`, `mysql2` y `postgresql` admiten claves foráneas.

```ruby
# agregar una clave foránea a `articles.author_id` que referencia `authors.id`
add_foreign_key :articles, :authors

# agregar una clave foránea a `articles.author_id` que referencia `users.lng_id`
add_foreign_key :articles, :users, column: :author_id, primary_key: "lng_id"

# eliminar la clave foránea en `accounts.branch_id`
remove_foreign_key :accounts, :branches

# eliminar la clave foránea en `accounts.owner_id`
remove_foreign_key :accounts, column: :owner_id
```

Consulte la documentación de la API en
[add_foreign_key](https://api.rubyonrails.org/v4.2.0/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html#method-i-add_foreign_key)
y
[remove_foreign_key](https://api.rubyonrails.org/v4.2.0/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html#method-i-remove_foreign_key)
para obtener una descripción completa.

Incompatibilidades
-----------------

Se ha eliminado la funcionalidad previamente deprecada. Consulte los componentes individuales para conocer las nuevas deprecaciones en esta versión.

Los siguientes cambios pueden requerir una acción inmediata al actualizar.

### `render` con un argumento de tipo String

Anteriormente, llamar a `render "foo/bar"` en una acción del controlador era equivalente a `render file: "foo/bar"`. En Rails 4.2, esto ha cambiado para significar `render template: "foo/bar"`. Si necesita renderizar un archivo, cambie su código para usar la forma explícita (`render file: "foo/bar"`) en su lugar.

### `respond_with` / `respond_to` a nivel de clase

`respond_with` y el correspondiente `respond_to` a nivel de clase se han movido al gem [responders](https://github.com/plataformatec/responders). Agregue `gem 'responders', '~> 2.0'` a su `Gemfile` para usarlo:

```ruby
# app/controllers/users_controller.rb

class UsersController < ApplicationController
  respond_to :html, :json

  def show
    @user = User.find(params[:id])
    respond_with @user
  end
end
```

El `respond_to` a nivel de instancia no se ve afectado:

```ruby
# app/controllers/users_controller.rb

class UsersController < ApplicationController
  def show
    @user = User.find(params[:id])
    respond_to do |format|
      format.html
      format.json { render json: @user }
    end
  end
end
```

### Host predeterminado para `rails server`

Debido a un [cambio en Rack](https://github.com/rack/rack/commit/28b014484a8ac0bbb388e7eaeeef159598ec64fc), `rails server` ahora escucha en `localhost` en lugar de `0.0.0.0` de forma predeterminada. Esto debería tener un impacto mínimo en el flujo de trabajo de desarrollo estándar, ya que tanto http://127.0.0.1:3000 como http://localhost:3000 seguirán funcionando como antes en su propia máquina.

Sin embargo, con este cambio ya no podrá acceder al servidor de Rails desde una máquina diferente, por ejemplo, si su entorno de desarrollo está en una máquina virtual y desea acceder a ella desde la máquina host. En estos casos, inicie el servidor con `rails server -b 0.0.0.0` para restaurar el comportamiento anterior.

Si hace esto, asegúrese de configurar correctamente su firewall para que solo las máquinas confiables en su red puedan acceder a su servidor de desarrollo.

### Cambio en los símbolos de opción de estado para `render`

Debido a un [cambio en Rack](https://github.com/rack/rack/commit/be28c6a2ac152fe4adfbef71f3db9f4200df89e8), los símbolos que el método `render` acepta para la opción `:status` han cambiado:

- 306: se ha eliminado `:reserved`.
- 413: `:request_entity_too_large` se ha cambiado a `:payload_too_large`.
- 414: `:request_uri_too_long` se ha cambiado a `:uri_too_long`.
- 416: `:requested_range_not_satisfiable` se ha cambiado a `:range_not_satisfiable`.

Tenga en cuenta que si llama a `render` con un símbolo desconocido, el estado de respuesta será 500 de forma predeterminada.

### Sanitizador de HTML

El sanitizador de HTML se ha reemplazado por una nueva implementación más robusta basada en [Loofah](https://github.com/flavorjones/loofah) y [Nokogiri](https://github.com/sparklemotion/nokogiri). El nuevo sanitizador es más seguro y su sanitización es más potente y flexible.

Debido al nuevo algoritmo, la salida sanitizada puede ser diferente para ciertas entradas patológicas.

Si tiene una necesidad particular de la salida exacta del antiguo sanitizador, puede agregar el gem [rails-deprecated_sanitizer](https://github.com/kaspth/rails-deprecated_sanitizer) a su `Gemfile` para tener el comportamiento antiguo. El gem no emite advertencias de deprecación porque es opcional.

`rails-deprecated_sanitizer` será compatible solo con Rails 4.2; no se mantendrá para Rails 5.0.

Consulte [esta publicación de blog](https://blog.plataformatec.com.br/2014/07/the-new-html-sanitizer-in-rails-4-2/) para obtener más detalles sobre los cambios en el nuevo sanitizador.

### `assert_select`

`assert_select` ahora se basa en [Nokogiri](https://github.com/sparklemotion/nokogiri). Como resultado, algunos selectores que antes eran válidos ahora no son compatibles. Si su aplicación está utilizando alguna de estas formas de escritura, deberá actualizarlas:
* Los valores en los selectores de atributos pueden necesitar comillas si contienen caracteres no alfanuméricos.

    ```ruby
    # antes
    a[href=/]
    a[href$=/]

    # ahora
    a[href="/"]
    a[href$="/"]
    ```

* Los DOM construidos a partir de código fuente HTML que contiene HTML inválido con elementos anidados incorrectamente pueden diferir.

    Por ejemplo:

    ```ruby
    # contenido: <div><i><p></i></div>

    # antes:
    assert_select('div > i')  # => true
    assert_select('div > p')  # => false
    assert_select('i > p')    # => true

    # ahora:
    assert_select('div > i')  # => true
    assert_select('div > p')  # => true
    assert_select('i > p')    # => false
    ```

* Si los datos seleccionados contienen entidades, el valor seleccionado para la comparación solía ser sin procesar (por ejemplo, `AT&amp;T`), y ahora se evalúa (por ejemplo, `AT&T`).

    ```ruby
    # contenido: <p>AT&amp;T</p>

    # antes:
    assert_select('p', 'AT&amp;T')  # => true
    assert_select('p', 'AT&T')      # => false

    # ahora:
    assert_select('p', 'AT&T')      # => true
    assert_select('p', 'AT&amp;T')  # => false
    ```

Además, las sustituciones han cambiado de sintaxis.

Ahora tienes que usar un selector `:match` similar a CSS:

```ruby
assert_select ":match('id', ?)", 'comment_1'
```

Además, las sustituciones de expresiones regulares se ven diferentes cuando la afirmación falla.
Observa cómo `/hello/` aquí:

```ruby
assert_select(":match('id', ?)", /hello/)
```

se convierte en `"(?-mix:hello)"`:

```
Se esperaba encontrar al menos 1 elemento que coincida con "div:match('id', "(?-mix:hello)")", se encontraron 0.
Se esperaba que 0 fuera >= 1.
```

Consulta la documentación de [Rails Dom Testing](https://github.com/rails/rails-dom-testing/tree/8798b9349fb9540ad8cb9a0ce6cb88d1384a210b) para obtener más información sobre `assert_select`.


Railties
--------

Consulta el [Changelog][railties] para obtener cambios detallados.

### Eliminaciones

*   La opción `--skip-action-view` se ha eliminado del generador de aplicaciones. ([Pull Request](https://github.com/rails/rails/pull/17042))

*   El comando `rails application` se ha eliminado sin reemplazo. ([Pull Request](https://github.com/rails/rails/pull/11616))

### Deprecaciones

*   Se ha deprecado la falta de `config.log_level` para entornos de producción. ([Pull Request](https://github.com/rails/rails/pull/16622))

*   Se ha deprecado `rake test:all` a favor de `rake test`, ya que ahora ejecuta todas las pruebas en la carpeta `test`. ([Pull Request](https://github.com/rails/rails/pull/17348))

*   Se ha deprecado `rake test:all:db` a favor de `rake test:db`. ([Pull Request](https://github.com/rails/rails/pull/17348))

*   Se ha deprecado `Rails::Rack::LogTailer` sin reemplazo. ([Commit](https://github.com/rails/rails/commit/84a13e019e93efaa8994b3f8303d635a7702dbce))

### Cambios destacados

*   Se introdujo `web-console` en el archivo `Gemfile` de la aplicación por defecto. ([Pull Request](https://github.com/rails/rails/pull/11667))

*   Se agregó una opción `required` al generador de modelos para asociaciones. ([Pull Request](https://github.com/rails/rails/pull/16062))

*   Se introdujo el espacio de nombres `x` para definir opciones de configuración personalizadas:

    ```ruby
    # config/environments/production.rb
    config.x.payment_processing.schedule = :daily
    config.x.payment_processing.retries  = 3
    config.x.super_debugger              = true
    ```

    Estas opciones están disponibles a través del objeto de configuración:

    ```ruby
    Rails.configuration.x.payment_processing.schedule # => :daily
    Rails.configuration.x.payment_processing.retries  # => 3
    Rails.configuration.x.super_debugger              # => true
    ```

    ([Commit](https://github.com/rails/rails/commit/611849772dd66c2e4d005dcfe153f7ce79a8a7db))

*   Se introdujo `Rails::Application.config_for` para cargar una configuración para el entorno actual.

    ```yaml
    # config/exception_notification.yml
    production:
      url: http://127.0.0.1:8080
      namespace: my_app_production
    development:
      url: http://localhost:3001
      namespace: my_app_development
    ```

    ```ruby
    # config/environments/production.rb
    Rails.application.configure do
      config.middleware.use ExceptionNotifier, config_for(:exception_notification)
    end
    ```

    ([Pull Request](https://github.com/rails/rails/pull/16129))

*   Se introdujo la opción `--skip-turbolinks` en el generador de aplicaciones para no generar la integración de turbolinks. ([Commit](https://github.com/rails/rails/commit/bf17c8a531bc8059d50ad731398002a3e7162a7d))

*   Se introdujo el script `bin/setup` como una convención para el código de configuración automatizado al iniciar una aplicación. ([Pull Request](https://github.com/rails/rails/pull/15189))

*   Se cambió el valor predeterminado de `config.assets.digest` a `true` en desarrollo. ([Pull Request](https://github.com/rails/rails/pull/15155))

*   Se introdujo una API para registrar nuevas extensiones para `rake notes`. ([Pull Request](https://github.com/rails/rails/pull/14379))

*   Se introdujo un callback `after_bundle` para usar en plantillas de Rails. ([Pull Request](https://github.com/rails/rails/pull/16359))

*   Se introdujo `Rails.gem_version` como un método de conveniencia para devolver `Gem::Version.new(Rails.version)`. ([Pull Request](https://github.com/rails/rails/pull/14101))


Action Pack
-----------

Consulta el [Changelog][action-pack] para obtener cambios detallados.

### Eliminaciones

*   `respond_with` y `respond_to` a nivel de clase se han eliminado de Rails y se han movido a la gema `responders` (versión 2.0). Agrega `gem 'responders', '~> 2.0'` a tu `Gemfile` para seguir utilizando estas características. ([Pull Request](https://github.com/rails/rails/pull/16526), [Más detalles](https://guides.rubyonrails.org/v4.2/upgrading_ruby_on_rails.html#responders))

*   Se eliminó `AbstractController::Helpers::ClassMethods::MissingHelperError` en desuso a favor de `AbstractController::Helpers::MissingHelperError`. ([Commit](https://github.com/rails/rails/commit/a1ddde15ae0d612ff2973de9cf768ed701b594e8))

### Deprecaciones

*   Se ha deprecado la opción `only_path` en los ayudantes `*_path`. ([Commit](https://github.com/rails/rails/commit/aa1fadd48fb40dd9396a383696134a259aa59db9))

*   Se ha deprecado `assert_tag`, `assert_no_tag`, `find_tag` y `find_all_tag` en favor de `assert_select`. ([Commit](https://github.com/rails/rails-dom-testing/commit/b12850bc5ff23ba4b599bf2770874dd4f11bf750))

*   Se ha deprecado el soporte para establecer la opción `:to` de un enrutador como un símbolo o una cadena que no contiene el carácter "#":

    ```ruby
    get '/posts', to: MyRackApp    => (No es necesario cambiar)
    get '/posts', to: 'post#index' => (No es necesario cambiar)
    get '/posts', to: 'posts'      => get '/posts', controller: :posts
    get '/posts', to: :index       => get '/posts', action: :index
    ```
    ([Commit](https://github.com/rails/rails/commit/cc26b6b7bccf0eea2e2c1a9ebdcc9d30ca7390d9))

*   Se ha deprecado el soporte para claves de cadena en los ayudantes de URL:

    ```ruby
    # malo
    root_path('controller' => 'posts', 'action' => 'index')

    # bueno
    root_path(controller: 'posts', action: 'index')
    ```

    ([Pull Request](https://github.com/rails/rails/pull/17743))

### Cambios destacados

*   Se han eliminado los métodos de la familia `*_filter` de la documentación. Se desaconseja su uso a favor de los métodos de la familia `*_action`:

    ```
    after_filter          => after_action
    append_after_filter   => append_after_action
    append_around_filter  => append_around_action
    append_before_filter  => append_before_action
    around_filter         => around_action
    before_filter         => before_action
    prepend_after_filter  => prepend_after_action
    prepend_around_filter => prepend_around_action
    prepend_before_filter => prepend_before_action
    skip_after_filter     => skip_after_action
    skip_around_filter    => skip_around_action
    skip_before_filter    => skip_before_action
    skip_filter           => skip_action_callback
    ```

    Si tu aplicación depende actualmente de estos métodos, debes usar los métodos de reemplazo `*_action` en su lugar. Estos métodos serán deprecados en el futuro y eventualmente serán eliminados de Rails.

    (Commit [1](https://github.com/rails/rails/commit/6c5f43bab8206747a8591435b2aa0ff7051ad3de),
    [2](https://github.com/rails/rails/commit/489a8f2a44dc9cea09154ee1ee2557d1f037c7d4))

*   `render nothing: true` o renderizar un cuerpo `nil` ya no añade un espacio en blanco al cuerpo de la respuesta.
    ([Pull Request](https://github.com/rails/rails/pull/14883))

*   Rails ahora incluye automáticamente el hash del template en las ETags.
    ([Pull Request](https://github.com/rails/rails/pull/16527))

*   Los segmentos que se pasan a los ayudantes de URL ahora se escapan automáticamente.
    ([Commit](https://github.com/rails/rails/commit/5460591f0226a9d248b7b4f89186bd5553e7768f))

*   Se introdujo la opción `always_permitted_parameters` para configurar qué parámetros están permitidos globalmente. El valor predeterminado de esta configuración es `['controller', 'action']`.
    ([Pull Request](https://github.com/rails/rails/pull/15933))

*   Se agregó el método HTTP `MKCALENDAR` de [RFC 4791](https://tools.ietf.org/html/rfc4791).
    ([Pull Request](https://github.com/rails/rails/pull/15121))

*   Las notificaciones `*_fragment.action_controller` ahora incluyen el nombre del controlador y la acción en la carga útil.
    ([Pull Request](https://github.com/rails/rails/pull/14137))

*   Se mejoró la página de error de enrutamiento con una búsqueda difusa de rutas.
    ([Pull Request](https://github.com/rails/rails/pull/14619))

*   Se agregó una opción para deshabilitar el registro de fallos de CSRF.
    ([Pull Request](https://github.com/rails/rails/pull/14280))

*   Cuando el servidor de Rails está configurado para servir activos estáticos, los activos gzip ahora se sirven si el cliente lo admite y hay un archivo gzip pregenerado (`.gz`) en el disco. Por defecto, el pipeline de activos genera archivos `.gz` para todos los activos compresibles. Servir archivos gzip minimiza la transferencia de datos y acelera las solicitudes de activos. Siempre [usa un CDN](https://guides.rubyonrails.org/v4.2/asset_pipeline.html#cdns) si estás sirviendo activos desde tu servidor de Rails en producción.
    ([Pull Request](https://github.com/rails/rails/pull/16466))

*   Al llamar a los ayudantes `process` en una prueba de integración, la ruta debe tener una barra diagonal inicial. Anteriormente se podía omitir, pero eso era un subproducto de la implementación y no una característica intencional, por ejemplo:

    ```ruby
    test "list all posts" do
      get "/posts"
      assert_response :success
    end
    ```

Action View
-----------

Consulta el [Changelog][action-view] para ver los cambios detallados.

### Deprecaciones

*   Se ha deprecado `AbstractController::Base.parent_prefixes`.
    Sobrescribe `AbstractController::Base.local_prefixes` cuando quieras cambiar
    dónde encontrar las vistas.
    ([Pull Request](https://github.com/rails/rails/pull/15026))

*   Se ha deprecado `ActionView::Digestor#digest(name, format, finder, options = {})`.
    Los argumentos deben pasarse como un hash en su lugar.
    ([Pull Request](https://github.com/rails/rails/pull/14243))

### Cambios destacados

*   `render "foo/bar"` ahora se expande a `render template: "foo/bar"` en lugar de
    `render file: "foo/bar"`.
    ([Pull Request](https://github.com/rails/rails/pull/16888))

*   Los ayudantes de formulario ya no generan un elemento `<div>` con CSS en línea alrededor
    de los campos ocultos.
    ([Pull Request](https://github.com/rails/rails/pull/14738))

*   Se introdujo una variable local especial `#{partial_name}_iteration` para usar con
    parciales que se renderizan con una colección. Proporciona acceso al
    estado actual de la iteración a través de los métodos `index`, `size`, `first?` y
    `last?`.
    ([Pull Request](https://github.com/rails/rails/pull/7698))

*   La traducción de marcadores de posición sigue la misma convención que la traducción de `label`.
    ([Pull Request](https://github.com/rails/rails/pull/16438))


Action Mailer
-------------

Consulta el [Changelog][action-mailer] para ver los cambios detallados.

### Deprecaciones

*   Se han deprecado los ayudantes `*_path` en los mailers. Siempre usa los ayudantes `*_url` en su lugar.
    ([Pull Request](https://github.com/rails/rails/pull/15840))

*   Se han deprecado `deliver` / `deliver!` a favor de `deliver_now` / `deliver_now!`.
    ([Pull Request](https://github.com/rails/rails/pull/16582))

### Cambios destacados

*   `link_to` y `url_for` generan URLs absolutas de forma predeterminada en las plantillas,
    ya no es necesario pasar `only_path: false`.
    ([Commit](https://github.com/rails/rails/commit/9685080a7677abfa5d288a81c3e078368c6bb67c))

*   Se introdujo `deliver_later` que encola un trabajo en la cola de la aplicación
    para enviar correos electrónicos de forma asíncrona.
    ([Pull Request](https://github.com/rails/rails/pull/16485))

*   Se agregó la opción de configuración `show_previews` para habilitar las vistas previas de mailers
    fuera del entorno de desarrollo.
    ([Pull Request](https://github.com/rails/rails/pull/15970))
Active Record
-------------

Consulte el [registro de cambios][active-record] para obtener cambios detallados.

### Eliminaciones

*   Se eliminó `cache_attributes` y amigos. Todos los atributos están en caché.
    ([Pull Request](https://github.com/rails/rails/pull/15429))

*   Se eliminó el método obsoleto `ActiveRecord::Base.quoted_locking_column`.
    ([Pull Request](https://github.com/rails/rails/pull/15612))

*   Se eliminó `ActiveRecord::Migrator.proper_table_name` obsoleto. En su lugar, use el
    método de instancia `proper_table_name` en `ActiveRecord::Migration`.
    ([Pull Request](https://github.com/rails/rails/pull/15512))

*   Se eliminó el tipo `:timestamp` no utilizado. Se le asigna automáticamente el alias `:datetime`
    en todos los casos. Soluciona inconsistencias cuando los tipos de columna se envían fuera de
    Active Record, como para la serialización XML.
    ([Pull Request](https://github.com/rails/rails/pull/15184))

### Obsolescencias

*   Se obsoletó la supresión de errores dentro de `after_commit` y `after_rollback`.
    ([Pull Request](https://github.com/rails/rails/pull/16537))

*   Se obsoletó el soporte defectuoso para la detección automática de cachés de contador en
    asociaciones `has_many :through`. En su lugar, debe especificar manualmente la
    caché de contador en las asociaciones `has_many` y `belongs_to` para los
    registros a través de.
    ([Pull Request](https://github.com/rails/rails/pull/15754))

*   Se obsoletó pasar objetos de Active Record a `.find` o `.exists?`. Llame
    primero a `id` en los objetos.
    (Commit [1](https://github.com/rails/rails/commit/d92ae6ccca3bcfd73546d612efaea011270bd270),
    [2](https://github.com/rails/rails/commit/d35f0033c7dec2b8d8b52058fb8db495d49596f7))

*   Se obsoletó el soporte a medias para valores de rango de PostgreSQL con
    comienzos excluidos. Actualmente mapeamos los rangos de PostgreSQL a rangos de Ruby. Esta conversión
    no es completamente posible porque los rangos de Ruby no admiten comienzos excluidos.

    La solución actual de incrementar el comienzo no es correcta
    y ahora está obsoleta. Para subtipos donde no sabemos cómo incrementar
    (por ejemplo, `succ` no está definido), generará un `ArgumentError` para rangos
    con comienzos excluidos.
    ([Commit](https://github.com/rails/rails/commit/91949e48cf41af9f3e4ffba3e5eecf9b0a08bfc3))

*   Se obsoletó llamar a `DatabaseTasks.load_schema` sin una conexión. Use
    `DatabaseTasks.load_schema_current` en su lugar.
    ([Commit](https://github.com/rails/rails/commit/f15cef67f75e4b52fd45655d7c6ab6b35623c608))

*   Se obsoletó `sanitize_sql_hash_for_conditions` sin reemplazo. Usar un
    `Relation` para realizar consultas y actualizaciones es la API preferida.
    ([Commit](https://github.com/rails/rails/commit/d5902c9e))

*   Se obsoletó `add_timestamps` y `t.timestamps` sin pasar la opción `:null`.
    El valor predeterminado de `null: true` cambiará en Rails 5 a `null: false`.
    ([Pull Request](https://github.com/rails/rails/pull/16481))

*   Se obsoletó `Reflection#source_macro` sin reemplazo, ya que ya no es necesario
    en Active Record.
    ([Pull Request](https://github.com/rails/rails/pull/16373))

*   Se obsoletó `serialized_attributes` sin reemplazo.
    ([Pull Request](https://github.com/rails/rails/pull/15704))

*   Se obsoletó devolver `nil` desde `column_for_attribute` cuando no existe una columna. Devolverá un objeto nulo en Rails 5.0.
    ([Pull Request](https://github.com/rails/rails/pull/15878))

*   Se obsoletó usar `.joins`, `.preload` y `.eager_load` con asociaciones
    que dependen del estado de la instancia (es decir, aquellas definidas con un ámbito que
    toma un argumento) sin reemplazo.
    ([Commit](https://github.com/rails/rails/commit/ed56e596a0467390011bc9d56d462539776adac1))

### Cambios destacados

*   `SchemaDumper` utiliza `force: :cascade` en `create_table`. Esto permite
    recargar un esquema cuando hay claves externas en su lugar.

*   Se agregó la opción `:required` a las asociaciones singulares, que define una
    validación de presencia en la asociación.
    ([Pull Request](https://github.com/rails/rails/pull/16056))

*   `ActiveRecord::Dirty` ahora detecta cambios en el lugar en valores mutables.
    Los atributos serializados en modelos de Active Record ya no se guardan cuando
    no han cambiado. Esto también funciona con otros tipos como columnas de cadena y columnas json
    en PostgreSQL.
    (Pull Requests [1](https://github.com/rails/rails/pull/15674),
    [2](https://github.com/rails/rails/pull/15786),
    [3](https://github.com/rails/rails/pull/15788))

*   Se introdujo la tarea Rake `db:purge` para vaciar la base de datos del
    entorno actual.
    ([Commit](https://github.com/rails/rails/commit/e2f232aba15937a4b9d14bd91e0392c6d55be58d))

*   Se introdujo `ActiveRecord::Base#validate!` que genera una excepción
    `ActiveRecord::RecordInvalid` si el registro no es válido.
    ([Pull Request](https://github.com/rails/rails/pull/8639))

*   Se introdujo `validate` como un alias para `valid?`.
    ([Pull Request](https://github.com/rails/rails/pull/14456))

*   `touch` ahora acepta múltiples atributos para ser actualizados al mismo tiempo.
    ([Pull Request](https://github.com/rails/rails/pull/14423))

*   El adaptador PostgreSQL ahora admite el tipo de dato `jsonb` en PostgreSQL 9.4+.
    ([Pull Request](https://github.com/rails/rails/pull/16220))

*   Los adaptadores PostgreSQL y SQLite ya no agregan un límite predeterminado de 255
    caracteres en columnas de cadena.
    ([Pull Request](https://github.com/rails/rails/pull/14579))

*   Se agregó soporte para el tipo de columna `citext` en el adaptador PostgreSQL.
    ([Pull Request](https://github.com/rails/rails/pull/12523))

*   Se agregó soporte para tipos de rango creados por el usuario en el adaptador PostgreSQL.
    ([Commit](https://github.com/rails/rails/commit/4cb47167e747e8f9dc12b0ddaf82bdb68c03e032))

*   `sqlite3:///some/path` ahora se resuelve a la ruta absoluta del sistema
    `/some/path`. Para rutas relativas, use `sqlite3:some/path` en su lugar.
    (Anteriormente, `sqlite3:///some/path` se resolvía a la ruta relativa
    `some/path`. Este comportamiento fue obsoleto en Rails 4.1).
    ([Pull Request](https://github.com/rails/rails/pull/14569))

*   Se agregó soporte para segundos fraccionarios para MySQL 5.6 y superior.
    (Pull Request [1](https://github.com/rails/rails/pull/8240),
    [2](https://github.com/rails/rails/pull/14359))

*   Se agregó `ActiveRecord::Base#pretty_print` para imprimir modelos de forma legible.
    ([Pull Request](https://github.com/rails/rails/pull/15172))

*   `ActiveRecord::Base#reload` ahora se comporta igual que `m = Model.find(m.id)`,
    lo que significa que ya no conserva los atributos adicionales de `SELECT` personalizados.
    ([Pull Request](https://github.com/rails/rails/pull/15866))
*   `ActiveRecord::Base#reflections` ahora devuelve un hash con claves de tipo string en lugar de claves de tipo símbolo. ([Pull Request](https://github.com/rails/rails/pull/17718))

*   El método `references` en las migraciones ahora admite una opción `type` para especificar el tipo de la clave foránea (por ejemplo, `:uuid`). ([Pull Request](https://github.com/rails/rails/pull/16231))

Active Model
------------

Consulte el [registro de cambios][active-model] para obtener cambios detallados.

### Eliminaciones

*   Se eliminó el método `Validator#setup` obsoleto sin reemplazo. ([Pull Request](https://github.com/rails/rails/pull/10716))

### Obsolescencias

*   Se ha vuelto obsoleto el método `reset_#{attribute}` en favor de `restore_#{attribute}`. ([Pull Request](https://github.com/rails/rails/pull/16180))

*   Se ha vuelto obsoleto `ActiveModel::Dirty#reset_changes` en favor de `clear_changes_information`. ([Pull Request](https://github.com/rails/rails/pull/16180))

### Cambios destacados

*   Se introdujo `validate` como un alias de `valid?`. ([Pull Request](https://github.com/rails/rails/pull/14456))

*   Se introdujo el método `restore_attributes` en `ActiveModel::Dirty` para restaurar los atributos modificados (sucios) a sus valores anteriores. (Pull Request [1](https://github.com/rails/rails/pull/14861), [2](https://github.com/rails/rails/pull/16180))

*   `has_secure_password` ya no impide contraseñas en blanco (es decir, contraseñas que contienen solo espacios) de forma predeterminada. ([Pull Request](https://github.com/rails/rails/pull/16412))

*   `has_secure_password` ahora verifica que la contraseña proporcionada tenga menos de 72 caracteres si las validaciones están habilitadas. ([Pull Request](https://github.com/rails/rails/pull/15708))

Active Support
--------------

Consulte el [registro de cambios][active-support] para obtener cambios detallados.

### Eliminaciones

*   Se eliminaron los métodos obsoletos `Numeric#ago`, `Numeric#until`, `Numeric#since`, `Numeric#from_now`. ([Commit](https://github.com/rails/rails/commit/f1eddea1e3f6faf93581c43651348f48b2b7d8bb))

*   Se eliminaron los terminadores basados en cadenas obsoletos para `ActiveSupport::Callbacks`. ([Pull Request](https://github.com/rails/rails/pull/15100))

### Obsolescencias

*   Se ha vuelto obsoleto `Kernel#silence_stderr`, `Kernel#capture` y `Kernel#quietly` sin reemplazo. ([Pull Request](https://github.com/rails/rails/pull/13392))

*   Se ha vuelto obsoleto `Class#superclass_delegating_accessor`, use `Class#class_attribute` en su lugar. ([Pull Request](https://github.com/rails/rails/pull/14271))

*   Se ha vuelto obsoleto `ActiveSupport::SafeBuffer#prepend!` ya que `ActiveSupport::SafeBuffer#prepend` ahora realiza la misma función. ([Pull Request](https://github.com/rails/rails/pull/14529))

### Cambios destacados

*   Se introdujo una nueva opción de configuración `active_support.test_order` para especificar el orden en que se ejecutan los casos de prueba. Esta opción actualmente tiene un valor predeterminado de `:sorted`, pero se cambiará a `:random` en Rails 5.0. ([Commit](https://github.com/rails/rails/commit/53e877f7d9291b2bf0b8c425f9e32ef35829f35b))

*   `Object#try` y `Object#try!` ahora se pueden usar sin un receptor explícito en el bloque. ([Commit](https://github.com/rails/rails/commit/5e51bdda59c9ba8e5faf86294e3e431bd45f1830), [Pull Request](https://github.com/rails/rails/pull/17361))

*   El ayudante de prueba `travel_to` ahora trunca el componente `usec` a 0. ([Commit](https://github.com/rails/rails/commit/9f6e82ee4783e491c20f5244a613fdeb4024beb5))

*   Se introdujo `Object#itself` como una función de identidad. (Commit [1](https://github.com/rails/rails/commit/702ad710b57bef45b081ebf42e6fa70820fdd810), [2](https://github.com/rails/rails/commit/64d91122222c11ad3918cc8e2e3ebc4b0a03448a))

*   `Object#with_options` ahora se puede usar sin un receptor explícito en el bloque. ([Pull Request](https://github.com/rails/rails/pull/16339))

*   Se introdujo `String#truncate_words` para truncar una cadena por un número de palabras. ([Pull Request](https://github.com/rails/rails/pull/16190))

*   Se agregaron `Hash#transform_values` y `Hash#transform_values!` para simplificar un patrón común en el que los valores de un hash deben cambiar, pero las claves se mantienen iguales. ([Pull Request](https://github.com/rails/rails/pull/15819))

*   El ayudante de inflexión `humanize` ahora elimina cualquier guión bajo inicial. ([Commit](https://github.com/rails/rails/commit/daaa21bc7d20f2e4ff451637423a25ff2d5e75c7))

*   Se introdujo `Concern#class_methods` como una alternativa a `module ClassMethods`, así como `Kernel#concern` para evitar la plantilla `module Foo; extend ActiveSupport::Concern; end`. ([Commit](https://github.com/rails/rails/commit/b16c36e688970df2f96f793a759365b248b582ad))

*   Nueva [guía](autoloading_and_reloading_constants_classic_mode.html) sobre la carga automática y recarga de constantes.

Créditos
-------

Consulte la [lista completa de colaboradores de Rails](https://contributors.rubyonrails.org/) para conocer a las muchas personas que dedicaron muchas horas para hacer de Rails el marco estable y robusto que es hoy. Felicitaciones a todos ellos.

[railties]:       https://github.com/rails/rails/blob/4-2-stable/railties/CHANGELOG.md
[action-pack]:    https://github.com/rails/rails/blob/4-2-stable/actionpack/CHANGELOG.md
[action-view]:    https://github.com/rails/rails/blob/4-2-stable/actionview/CHANGELOG.md
[action-mailer]:  https://github.com/rails/rails/blob/4-2-stable/actionmailer/CHANGELOG.md
[active-record]:  https://github.com/rails/rails/blob/4-2-stable/activerecord/CHANGELOG.md
[active-model]:   https://github.com/rails/rails/blob/4-2-stable/activemodel/CHANGELOG.md
[active-support]: https://github.com/rails/rails/blob/4-2-stable/activesupport/CHANGELOG.md
[active-support]: https://github.com/rails/rails/blob/4-2-stable/activesupport/CHANGELOG.md
