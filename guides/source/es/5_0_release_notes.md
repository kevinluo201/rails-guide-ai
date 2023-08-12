**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: df23e2b31bd56973a30f38f5a1c29b52
Notas de lanzamiento de Ruby on Rails 5.0
==========================================

Aspectos destacados en Rails 5.0:

* Action Cable
* Rails API
* API de Atributos de Active Record
* Test Runner
* Uso exclusivo de `rails` CLI en lugar de Rake
* Sprockets 3
* Turbolinks 5
* Se requiere Ruby 2.2.2+

Estas notas de lanzamiento solo cubren los cambios principales. Para conocer las diversas correcciones de errores y cambios, consulte los registros de cambios o revise la [lista de confirmaciones](https://github.com/rails/rails/commits/5-0-stable) en el repositorio principal de Rails en GitHub.

--------------------------------------------------------------------------------

Actualización a Rails 5.0
-------------------------

Si está actualizando una aplicación existente, es una buena idea tener una buena cobertura de pruebas antes de comenzar. También debe actualizar primero a Rails 4.2 en caso de que no lo haya hecho y asegurarse de que su aplicación siga funcionando como se espera antes de intentar una actualización a Rails 5.0. Una lista de cosas a tener en cuenta al actualizar está disponible en la guía [Actualización de Ruby on Rails](upgrading_ruby_on_rails.html#upgrading-from-rails-4-2-to-rails-5-0).

Funciones principales
--------------------

### Action Cable

Action Cable es un nuevo marco en Rails 5.0. Integra de manera transparente [WebSockets](https://en.wikipedia.org/wiki/WebSocket) con el resto de su aplicación Rails.

Action Cable permite escribir características en tiempo real en Ruby en el mismo estilo y forma que el resto de su aplicación Rails, al mismo tiempo que es eficiente y escalable. Es una oferta de pila completa que proporciona tanto un marco de JavaScript en el lado del cliente como un marco de Ruby en el lado del servidor. Tiene acceso a su modelo de dominio completo escrito con Active Record o su ORM de elección.

Consulte la guía [Descripción general de Action Cable](action_cable_overview.html) para obtener más información.

### Aplicaciones API

Rails ahora se puede utilizar para crear aplicaciones API más reducidas. Esto es útil para crear y servir API similares a la de [Twitter](https://dev.twitter.com) o [GitHub](https://developer.github.com), que se pueden utilizar para servir aplicaciones públicas, así como aplicaciones personalizadas.

Puede generar una nueva aplicación Rails API utilizando:

```bash
$ rails new my_api --api
```

Esto hará tres cosas principales:

- Configurar su aplicación para que comience con un conjunto más limitado de middleware que lo normal. Específicamente, no incluirá ningún middleware principalmente útil para aplicaciones de navegador (como el soporte de cookies) de forma predeterminada.
- Hacer que `ApplicationController` herede de `ActionController::API` en lugar de `ActionController::Base`. Al igual que con el middleware, esto omitirá cualquier módulo de Action Controller que proporcione funcionalidades utilizadas principalmente por aplicaciones de navegador.
- Configurar los generadores para omitir la generación de vistas, ayudantes y activos cuando se genera un nuevo recurso.

La aplicación proporciona una base para API, que luego se puede [configurar para incluir funcionalidad](api_app.html) según las necesidades de la aplicación.
Consulte la guía [Usando Rails para aplicaciones solo de API](api_app.html) para obtener más información.

### API de atributos de Active Record

Define un atributo con un tipo en un modelo. Anulará el tipo de los atributos existentes si es necesario.
Esto permite controlar cómo se convierten los valores hacia y desde SQL cuando se asignan a un modelo.
También cambia el comportamiento de los valores pasados a `ActiveRecord::Base.where`, lo que nos permite usar nuestros objetos de dominio en gran parte de Active Record,
sin tener que depender de detalles de implementación o parches de monkey.

Algunas cosas que se pueden lograr con esto:

- Se puede anular el tipo detectado por Active Record.
- También se puede proporcionar un valor predeterminado.
- Los atributos no necesitan estar respaldados por una columna de base de datos.

```ruby
# db/schema.rb
create_table :store_listings, force: true do |t|
  t.decimal :price_in_cents
  t.string :my_string, default: "original default"
end
```

```ruby
# app/models/store_listing.rb
class StoreListing < ActiveRecord::Base
end
```

```ruby
store_listing = StoreListing.new(price_in_cents: '10.1')

# antes
store_listing.price_in_cents # => BigDecimal.new(10.1)
StoreListing.new.my_string # => "original default"

class StoreListing < ActiveRecord::Base
  attribute :price_in_cents, :integer # tipo personalizado
  attribute :my_string, :string, default: "new default" # valor predeterminado
  attribute :my_default_proc, :datetime, default: -> { Time.now } # valor predeterminado
  attribute :field_without_db_column, :integer, array: true
end

# después
store_listing.price_in_cents # => 10
StoreListing.new.my_string # => "new default"
StoreListing.new.my_default_proc # => 2015-05-30 11:04:48 -0600
model = StoreListing.new(field_without_db_column: ["1", "2", "3"])
model.attributes # => {field_without_db_column: [1, 2, 3]}
```

**Creando tipos personalizados:**

Puede definir sus propios tipos personalizados, siempre y cuando respondan
a los métodos definidos en el tipo de valor. El método `deserialize` o
`cast` se llamará en su objeto de tipo, con la entrada sin procesar de la
base de datos o de sus controladores. Esto es útil, por ejemplo, al hacer conversiones personalizadas,
como datos de dinero.

**Consulta:**

Cuando se llama a `ActiveRecord::Base.where`, utilizará
el tipo definido por la clase del modelo para convertir el valor a SQL,
llamando a `serialize` en su objeto de tipo.

Esto le da a los objetos la capacidad de especificar cómo convertir valores al realizar consultas SQL.

**Seguimiento de cambios:**

El tipo de un atributo puede cambiar cómo se realiza el seguimiento de cambios.
Consulte su
[documentación](https://api.rubyonrails.org/v5.0.1/classes/ActiveRecord/Attributes/ClassMethods.html)
para obtener una descripción detallada.

### Ejecutor de pruebas

Se ha introducido un nuevo ejecutor de pruebas para mejorar las capacidades de ejecución de pruebas en Rails.
Para usar este ejecutor de pruebas, simplemente escriba `bin/rails test`.

El ejecutor de pruebas está inspirado en `RSpec`, `minitest-reporters`, `maxitest` y otros.
Incluye algunos de estos avances destacados:

- Ejecutar una sola prueba utilizando el número de línea de la prueba.
- Ejecutar varias pruebas señalando al número de línea de las pruebas.
- Mejora en los mensajes de error, que también facilitan la repetición de las pruebas fallidas.
- Fallar rápidamente usando la opción `-f`, para detener las pruebas inmediatamente al producirse un fallo,
en lugar de esperar a que se complete el conjunto de pruebas.
- Retrasar la salida de las pruebas hasta el final de una ejecución completa de pruebas utilizando la opción `-d`.
- Salida completa de la traza de excepción utilizando la opción `-b`.
- Integración con minitest para permitir opciones como `-s` para datos de semilla de prueba,
`-n` para ejecutar una prueba específica por nombre, `-v` para obtener una salida más detallada, y así sucesivamente.
- Salida de prueba en color.
Railties
--------

Consulte el [registro de cambios][railties] para obtener cambios detallados.

### Eliminaciones

*   Se eliminó el soporte para el depurador, use byebug en su lugar. `debugger` no es compatible con Ruby 2.2. ([commit](https://github.com/rails/rails/commit/93559da4826546d07014f8cfa399b64b4a143127))

*   Se eliminaron las tareas `test:all` y `test:all:db` obsoletas. ([commit](https://github.com/rails/rails/commit/f663132eef0e5d96bf2a58cec9f7c856db20be7c))

*   Se eliminó `Rails::Rack::LogTailer` obsoleto. ([commit](https://github.com/rails/rails/commit/c564dcb75c191ab3d21cc6f920998b0d6fbca623))

*   Se eliminó la constante `RAILS_CACHE` obsoleta. ([commit](https://github.com/rails/rails/commit/b7f856ce488ef8f6bf4c12bb549f462cb7671c08))

*   Se eliminó la configuración obsoleta `serve_static_assets`. ([commit](https://github.com/rails/rails/commit/463b5d7581ee16bfaddf34ca349b7d1b5878097c))

*   Se eliminaron las tareas de documentación `doc:app`, `doc:rails` y `doc:guides`. ([commit](https://github.com/rails/rails/commit/cd7cc5254b090ccbb84dcee4408a5acede25ef2a))

*   Se eliminó el middleware `Rack::ContentLength` de la pila predeterminada. ([Commit](https://github.com/rails/rails/commit/56903585a099ab67a7acfaaef0a02db8fe80c450))

### Obsolescencias

*   Se deprecó `config.static_cache_control` a favor de `config.public_file_server.headers`. ([Pull Request](https://github.com/rails/rails/pull/19135))

*   Se deprecó `config.serve_static_files` a favor de `config.public_file_server.enabled`. ([Pull Request](https://github.com/rails/rails/pull/22173))

*   Se deprecó las tareas en el espacio de nombres de tareas `rails` a favor del espacio de nombres `app`. (por ejemplo, las tareas `rails:update` y `rails:template` se renombraron a `app:update` y `app:template`.) ([Pull Request](https://github.com/rails/rails/pull/23439))

### Cambios destacados

*   Se agregó el ejecutador de pruebas de Rails `bin/rails test`. ([Pull Request](https://github.com/rails/rails/pull/19216))

*   Las aplicaciones y complementos recién generados obtienen un archivo `README.md` en formato Markdown. ([commit](https://github.com/rails/rails/commit/89a12c931b1f00b90e74afffcdc2fc21f14ca663), [Pull Request](https://github.com/rails/rails/pull/22068))

*   Se agregó la tarea `bin/rails restart` para reiniciar su aplicación de Rails tocando `tmp/restart.txt`. ([Pull Request](https://github.com/rails/rails/pull/18965))

*   Se agregó la tarea `bin/rails initializers` para imprimir todos los inicializadores definidos en el orden en que son invocados por Rails. ([Pull Request](https://github.com/rails/rails/pull/19323))

*   Se agregó `bin/rails dev:cache` para habilitar o deshabilitar el almacenamiento en caché en el modo de desarrollo. ([Pull Request](https://github.com/rails/rails/pull/20961))

*   Se agregó el script `bin/update` para actualizar automáticamente el entorno de desarrollo. ([Pull Request](https://github.com/rails/rails/pull/20972))

*   Se realizaron tareas Rake a través de `bin/rails`. ([Pull Request](https://github.com/rails/rails/pull/22457), [Pull Request](https://github.com/rails/rails/pull/22288))

*   Las nuevas aplicaciones se generan con el monitor de sistema de archivos basado en eventos habilitado en Linux y macOS. La función se puede omitir pasando `--skip-listen` al generador. ([commit](https://github.com/rails/rails/commit/de6ad5665d2679944a9ee9407826ba88395a1003), [commit](https://github.com/rails/rails/commit/94dbc48887bf39c241ee2ce1741ee680d773f202))

*   Generar aplicaciones con una opción para registrar en STDOUT en producción utilizando la variable de entorno `RAILS_LOG_TO_STDOUT`. ([Pull Request](https://github.com/rails/rails/pull/23734))

*   Habilitar HSTS con el encabezado IncludeSubdomains para nuevas aplicaciones. ([Pull Request](https://github.com/rails/rails/pull/23852))

*   El generador de aplicaciones escribe un nuevo archivo `config/spring.rb`, que le indica a Spring que observe archivos comunes adicionales. ([commit](https://github.com/rails/rails/commit/b04d07337fd7bc17e88500e9d6bcd361885a45f8))

*   Se agregó `--skip-action-mailer` para omitir Action Mailer al generar una nueva aplicación. ([Pull Request](https://github.com/rails/rails/pull/18288))

*   Se eliminó el directorio `tmp/sessions` y la tarea de borrado asociada. ([Pull Request](https://github.com/rails/rails/pull/18314))

*   Se cambió `_form.html.erb` generado por el generador de andamios para usar variables locales. ([Pull Request](https://github.com/rails/rails/pull/13434))

*   Se desactivó la carga automática de clases en el entorno de producción. ([commit](https://github.com/rails/rails/commit/a71350cae0082193ad8c66d65ab62e8bb0b7853b))

Action Pack
-----------

Consulte el [registro de cambios][action-pack] para obtener cambios detallados.

### Eliminaciones

*   Se eliminó `ActionDispatch::Request::Utils.deep_munge`. ([commit](https://github.com/rails/rails/commit/52cf1a71b393486435fab4386a8663b146608996))

*   Se eliminó `ActionController::HideActions`. ([Pull Request](https://github.com/rails/rails/pull/18371))

*   Se eliminaron los métodos de marcador de posición `respond_to` y `respond_with`, esta funcionalidad se ha extraído a la gema [responders](https://github.com/plataformatec/responders). ([commit](https://github.com/rails/rails/commit/afd5e9a7ff0072e482b0b0e8e238d21b070b6280))

*   Se eliminaron los archivos de aserción obsoletos. ([commit](https://github.com/rails/rails/commit/92e27d30d8112962ee068f7b14aa7b10daf0c976))

*   Se eliminó el uso obsoleto de claves de cadena en los ayudantes de URL. ([commit](https://github.com/rails/rails/commit/34e380764edede47f7ebe0c7671d6f9c9dc7e809))

*   Se eliminó la opción obsoleta `only_path` en los ayudantes `*_path`. ([commit](https://github.com/rails/rails/commit/e4e1fd7ade47771067177254cb133564a3422b8a))
*   Se eliminó `NamedRouteCollection#helpers` obsoleto.
    ([commit](https://github.com/rails/rails/commit/2cc91c37bc2e32b7a04b2d782fb8f4a69a14503f))

*   Se eliminó el soporte obsoleto para definir rutas con la opción `:to` que no contiene `#`.
    ([commit](https://github.com/rails/rails/commit/1f3b0a8609c00278b9a10076040ac9c90a9cc4a6))

*   Se eliminó `ActionDispatch::Response#to_ary` obsoleto.
    ([commit](https://github.com/rails/rails/commit/4b19d5b7bcdf4f11bd1e2e9ed2149a958e338c01))

*   Se eliminó `ActionDispatch::Request#deep_munge` obsoleto.
    ([commit](https://github.com/rails/rails/commit/7676659633057dacd97b8da66e0d9119809b343e))

*   Se eliminó `ActionDispatch::Http::Parameters#symbolized_path_parameters` obsoleto.
    ([commit](https://github.com/rails/rails/commit/7fe7973cd8bd119b724d72c5f617cf94c18edf9e))

*   Se eliminó la opción obsoleta `use_route` en las pruebas de controladores.
    ([commit](https://github.com/rails/rails/commit/e4cfd353a47369dd32198b0e67b8cbb2f9a1c548))

*   Se eliminaron `assigns` y `assert_template`. Ambos métodos se han extraído
    en la gema
    [rails-controller-testing](https://github.com/rails/rails-controller-testing)
    .
    ([Pull Request](https://github.com/rails/rails/pull/20138))

### Deprecaciones

*   Se deprecó todos los callbacks `*_filter` a favor de los callbacks `*_action`.
    ([Pull Request](https://github.com/rails/rails/pull/18410))

*   Se deprecó los métodos de prueba de integración `*_via_redirect`. Use `follow_redirect!`
    manualmente después de la llamada de la solicitud para el mismo comportamiento.
    ([Pull Request](https://github.com/rails/rails/pull/18693))

*   Se deprecó `AbstractController#skip_action_callback` a favor de métodos individuales
    skip_callback.
    ([Pull Request](https://github.com/rails/rails/pull/19060))

*   Se deprecó la opción `:nothing` para el método `render`.
    ([Pull Request](https://github.com/rails/rails/pull/20336))

*   Se deprecó pasar el primer parámetro como `Hash` y el código de estado predeterminado para
    el método `head`.
    ([Pull Request](https://github.com/rails/rails/pull/20407))

*   Se deprecó el uso de cadenas o símbolos para los nombres de clase de middleware. Use nombres de clase
    en su lugar.
    ([commit](https://github.com/rails/rails/commit/83b767ce))

*   Se deprecó el acceso a los tipos MIME a través de constantes (por ejemplo, `Mime::HTML`). Use el
    operador de subíndice con un símbolo en su lugar (por ejemplo, `Mime[:html]`).
    ([Pull Request](https://github.com/rails/rails/pull/21869))

*   Se deprecó `redirect_to :back` a favor de `redirect_back`, que acepta un
    argumento `fallback_location` requerido, eliminando así la posibilidad de un
    `RedirectBackError`.
    ([Pull Request](https://github.com/rails/rails/pull/22506))

*   `ActionDispatch::IntegrationTest` y `ActionController::TestCase` deprecian los argumentos posicionales a favor de
    argumentos de palabras clave. ([Pull Request](https://github.com/rails/rails/pull/18323))

*   Se deprecó los parámetros de ruta `:controller` y `:action`.
    ([Pull Request](https://github.com/rails/rails/pull/23980))

*   Se deprecó el método env en las instancias de controlador.
    ([commit](https://github.com/rails/rails/commit/05934d24aff62d66fc62621aa38dae6456e276be))

*   `ActionDispatch::ParamsParser` está obsoleto y se eliminó de la
    pila de middleware. Para configurar los analizadores de parámetros, use
    `ActionDispatch::Request.parameter_parsers=`.
    ([commit](https://github.com/rails/rails/commit/38d2bf5fd1f3e014f2397898d371c339baa627b1),
    [commit](https://github.com/rails/rails/commit/5ed38014811d4ce6d6f957510b9153938370173b))

### Cambios destacados

*   Se agregó `ActionController::Renderer` para renderizar plantillas arbitrarias
    fuera de las acciones del controlador.
    ([Pull Request](https://github.com/rails/rails/pull/18546))

*   Migración a la sintaxis de argumentos de palabras clave en `ActionController::TestCase` y
    métodos de solicitud HTTP de `ActionDispatch::Integration`.
    ([Pull Request](https://github.com/rails/rails/pull/18323))

*   Se agregó `http_cache_forever` a Action Controller, para que podamos almacenar en caché una respuesta
    que nunca caduca.
    ([Pull Request](https://github.com/rails/rails/pull/18394))

*   Proporcionar un acceso más amigable a las variantes de solicitud.
    ([Pull Request](https://github.com/rails/rails/pull/18939))

*   Para acciones sin plantillas correspondientes, renderizar `head :no_content`
    en lugar de generar un error.
    ([Pull Request](https://github.com/rails/rails/pull/19377))

*   Se agregó la capacidad de anular el generador de formularios predeterminado para un controlador.
    ([Pull Request](https://github.com/rails/rails/pull/19736))

*   Se agregó soporte para aplicaciones solo de API.
    `ActionController::API` se agrega como reemplazo de
    `ActionController::Base` para este tipo de aplicaciones.
    ([Pull Request](https://github.com/rails/rails/pull/19832))

*   `ActionController::Parameters` ya no hereda de
    `HashWithIndifferentAccess`.
    ([Pull Request](https://github.com/rails/rails/pull/20868))

*   Se facilita la opción de habilitar `config.force_ssl` y `config.ssl_options` al
    hacerlos menos peligrosos de probar y más fáciles de deshabilitar.
    ([Pull Request](https://github.com/rails/rails/pull/21520))

*   Se agregó la capacidad de devolver encabezados arbitrarios a `ActionDispatch::Static`.
    ([Pull Request](https://github.com/rails/rails/pull/19135))

*   Se cambió el valor predeterminado de `protect_from_forgery` a `false`.
    ([commit](https://github.com/rails/rails/commit/39794037817703575c35a75f1961b01b83791191))
*   `ActionController::TestCase` se moverá a su propia gema en Rails 5.1. En su lugar, use `ActionDispatch::IntegrationTest`. ([commit](https://github.com/rails/rails/commit/4414c5d1795e815b102571425974a8b1d46d932d))

*   Rails genera ETags débiles de forma predeterminada. ([Pull Request](https://github.com/rails/rails/pull/17573))

*   Las acciones del controlador sin una llamada explícita a `render` y sin plantillas correspondientes renderizarán implícitamente `head :no_content` en lugar de generar un error. (Pull Request [1](https://github.com/rails/rails/pull/19377), [2](https://github.com/rails/rails/pull/23827))

*   Se agregó una opción para tokens CSRF por formulario. ([Pull Request](https://github.com/rails/rails/pull/22275))

*   Se agregó la codificación de solicitud y el análisis de respuesta a las pruebas de integración. ([Pull Request](https://github.com/rails/rails/pull/21671))

*   Agregue `ActionController#helpers` para acceder al contexto de la vista a nivel de controlador. ([Pull Request](https://github.com/rails/rails/pull/24866))

*   Los mensajes flash descartados se eliminan antes de almacenarlos en la sesión. ([Pull Request](https://github.com/rails/rails/pull/18721))

*   Se agregó soporte para pasar una colección de registros a `fresh_when` y `stale?`. ([Pull Request](https://github.com/rails/rails/pull/18374))

*   `ActionController::Live` se convirtió en un `ActiveSupport::Concern`. Esto significa que no se puede incluir en otros módulos sin extenderlos con `ActiveSupport::Concern` o `ActionController::Live` no tendrá efecto en producción. Algunas personas también pueden estar usando otro módulo para incluir algún código especial de manejo de fallas de autenticación `Warden`/`Devise`, ya que el middleware no puede capturar un `:warden` lanzado por un hilo generado, que es el caso cuando se usa `ActionController::Live`. ([Más detalles en este problema](https://github.com/rails/rails/issues/25581))

*   Introducir `Response#strong_etag=` y `#weak_etag=` y opciones análogas para `fresh_when` y `stale?`. ([Pull Request](https://github.com/rails/rails/pull/24387))

Action View
-------------

Consulte el [Changelog][action-view] para obtener cambios detallados.

### Eliminaciones

*   Se eliminó `AbstractController::Base::parent_prefixes` en desuso. ([commit](https://github.com/rails/rails/commit/34bcbcf35701ca44be559ff391535c0dd865c333))

*   Se eliminó `ActionView::Helpers::RecordTagHelper`, esta funcionalidad se ha extraído a la gema [record_tag_helper](https://github.com/rails/record_tag_helper). ([Pull Request](https://github.com/rails/rails/pull/18411))

*   Se eliminó la opción `:rescue_format` para el ayudante `translate` ya que ya no es compatible con I18n. ([Pull Request](https://github.com/rails/rails/pull/20019))

### Cambios destacados

*   Se cambió el controlador de plantillas predeterminado de `ERB` a `Raw`. ([commit](https://github.com/rails/rails/commit/4be859f0fdf7b3059a28d03c279f03f5938efc80))

*   La representación de colecciones puede almacenar en caché y recuperar múltiples parciales a la vez. ([Pull Request](https://github.com/rails/rails/pull/18948), [commit](https://github.com/rails/rails/commit/e93f0f0f133717f9b06b1eaefd3442bd0ff43985))

*   Se agregó la coincidencia de comodines a las dependencias explícitas. ([Pull Request](https://github.com/rails/rails/pull/20904))

*   Hacer que `disable_with` sea el comportamiento predeterminado para las etiquetas de envío. Deshabilita el botón al enviar para evitar envíos duplicados. ([Pull Request](https://github.com/rails/rails/pull/21135))

*   El nombre de la plantilla parcial ya no tiene que ser un identificador válido de Ruby. ([commit](https://github.com/rails/rails/commit/da9038e))

*   El ayudante `datetime_tag` ahora genera una etiqueta de entrada con el tipo `datetime-local`. ([Pull Request](https://github.com/rails/rails/pull/25469))

*   Permitir bloques al renderizar con el ayudante `render partial:`. ([Pull Request](https://github.com/rails/rails/pull/17974))

Action Mailer
-------------

Consulte el [Changelog][action-mailer] para obtener cambios detallados.

### Eliminaciones

*   Se eliminaron los ayudantes `*_path` en desuso en las vistas de correo electrónico. ([commit](https://github.com/rails/rails/commit/d282125a18c1697a9b5bb775628a2db239142ac7))

*   Se eliminaron los métodos `deliver` y `deliver!` en desuso. ([commit](https://github.com/rails/rails/commit/755dcd0691f74079c24196135f89b917062b0715))

### Cambios destacados

*   La búsqueda de plantillas ahora respeta el idioma predeterminado y las opciones de fallback de I18n. ([commit](https://github.com/rails/rails/commit/ecb1981b))

*   Se agregó el sufijo `_mailer` a los mailers creados mediante el generador, siguiendo la misma convención de nomenclatura utilizada en los controladores y trabajos. ([Pull Request](https://github.com/rails/rails/pull/18074))
*   Agregado `assert_enqueued_emails` y `assert_no_enqueued_emails`.
    ([Pull Request](https://github.com/rails/rails/pull/18403))

*   Agregada la configuración `config.action_mailer.deliver_later_queue_name` para establecer
    el nombre de la cola del mailer.
    ([Pull Request](https://github.com/rails/rails/pull/18587))

*   Agregado soporte para el fragment caching en las vistas de Action Mailer.
    Agregada la nueva opción de configuración `config.action_mailer.perform_caching` para determinar
    si las plantillas deben realizar caching o no.
    ([Pull Request](https://github.com/rails/rails/pull/22825))


Active Record
-------------

Por favor, consulta el [Changelog][active-record] para obtener cambios detallados.

### Eliminaciones

*   Eliminado el comportamiento obsoleto que permitía pasar matrices anidadas como valores de consulta.
    ([Pull Request](https://github.com/rails/rails/pull/17919))

*   Eliminado `ActiveRecord::Tasks::DatabaseTasks#load_schema`, que estaba obsoleto. Este
    método fue reemplazado por `ActiveRecord::Tasks::DatabaseTasks#load_schema_for`.
    ([commit](https://github.com/rails/rails/commit/ad783136d747f73329350b9bb5a5e17c8f8800da))

*   Eliminado `serialized_attributes`, que estaba obsoleto.
    ([commit](https://github.com/rails/rails/commit/82043ab53cb186d59b1b3be06122861758f814b2))

*   Eliminado el contador automático obsoleto en `has_many :through`.
    ([commit](https://github.com/rails/rails/commit/87c8ce340c6c83342df988df247e9035393ed7a0))

*   Eliminado `sanitize_sql_hash_for_conditions`, que estaba obsoleto.
    ([commit](https://github.com/rails/rails/commit/3a59dd212315ebb9bae8338b98af259ac00bbef3))

*   Eliminado `Reflection#source_macro`, que estaba obsoleto.
    ([commit](https://github.com/rails/rails/commit/ede8c199a85cfbb6457d5630ec1e285e5ec49313))

*   Eliminados `symbolized_base_class` y `symbolized_sti_name`, que estaban obsoletos.
    ([commit](https://github.com/rails/rails/commit/9013e28e52eba3a6ffcede26f85df48d264b8951))

*   Eliminado `ActiveRecord::Base.disable_implicit_join_references=`, que estaba obsoleto.
    ([commit](https://github.com/rails/rails/commit/0fbd1fc888ffb8cbe1191193bf86933110693dfc))

*   Eliminado el acceso obsoleto a la especificación de conexión utilizando un accessor de cadena.
    ([commit](https://github.com/rails/rails/commit/efdc20f36ccc37afbb2705eb9acca76dd8aabd4f))

*   Eliminado el soporte obsoleto para precargar asociaciones dependientes de la instancia.
    ([commit](https://github.com/rails/rails/commit/4ed97979d14c5e92eb212b1a629da0a214084078))

*   Eliminado el soporte obsoleto para rangos de PostgreSQL con límites inferiores exclusivos.
    ([commit](https://github.com/rails/rails/commit/a076256d63f64d194b8f634890527a5ed2651115))

*   Eliminada la deprecación al modificar una relación con Arel en caché.
    Esto ahora genera un error `ImmutableRelation`.
    ([commit](https://github.com/rails/rails/commit/3ae98181433dda1b5e19910e107494762512a86c))

*   Eliminado `ActiveRecord::Serialization::XmlSerializer` del núcleo. Esta funcionalidad
    se ha extraído al
    [activemodel-serializers-xml](https://github.com/rails/activemodel-serializers-xml)
    gema. ([Pull Request](https://github.com/rails/rails/pull/21161))

*   Eliminado el soporte para el adaptador de base de datos `mysql` heredado del núcleo. La mayoría de los usuarios deberían
    poder usar `mysql2`. Se convertirá en una gema separada cuando encontremos a alguien
    que lo mantenga. ([Pull Request 1](https://github.com/rails/rails/pull/22642),
    [Pull Request 2](https://github.com/rails/rails/pull/22715))

*   Eliminado el soporte para la gema `protected_attributes`.
    ([commit](https://github.com/rails/rails/commit/f4fbc0301021f13ae05c8e941c8efc4ae351fdf9))

*   Eliminado el soporte para versiones de PostgreSQL anteriores a 9.1.
    ([Pull Request](https://github.com/rails/rails/pull/23434))

*   Eliminado el soporte para la gema `activerecord-deprecated_finders`.
    ([commit](https://github.com/rails/rails/commit/78dab2a8569408658542e462a957ea5a35aa4679))

*   Eliminada la constante `ActiveRecord::ConnectionAdapters::Column::TRUE_VALUES`.
    ([commit](https://github.com/rails/rails/commit/a502703c3d2151d4d3b421b29fefdac5ad05df61))

### Deprecaciones

*   Deprecado pasar una clase como valor en una consulta. Los usuarios deben pasar cadenas
    en su lugar. ([Pull Request](https://github.com/rails/rails/pull/17916))

*   Deprecado devolver `false` como forma de detener las cadenas de callback de Active Record.
    La forma recomendada es usar `throw(:abort)`. ([Pull Request](https://github.com/rails/rails/pull/17227))

*   Deprecado `ActiveRecord::Base.errors_in_transactional_callbacks=`.
    ([commit](https://github.com/rails/rails/commit/07d3d402341e81ada0214f2cb2be1da69eadfe72))

*   Deprecado el uso de `Relation#uniq`, usar `Relation#distinct` en su lugar.
    ([commit](https://github.com/rails/rails/commit/adfab2dcf4003ca564d78d4425566dd2d9cd8b4f))

*   Deprecado el tipo PostgreSQL `:point` a favor de uno nuevo que devolverá
    objetos `Point` en lugar de un `Array`.
    ([Pull Request](https://github.com/rails/rails/pull/20448))

*   Deprecado recargar la asociación forzando un argumento verdadero al método de asociación.
    ([Pull Request](https://github.com/rails/rails/pull/20888))

*   Deprecados los nombres de clave para los errores de `restrict_dependent_destroy` de la asociación en favor
    de nuevos nombres de clave.
    ([Pull Request](https://github.com/rails/rails/pull/20668))

*   Sincronizado el comportamiento de `#tables`.
    ([Pull Request](https://github.com/rails/rails/pull/21601))

*   Deprecado `SchemaCache#tables`, `SchemaCache#table_exists?` y
    `SchemaCache#clear_table_cache!` en favor de sus contrapartes de origen de datos.
    ([Pull Request](https://github.com/rails/rails/pull/21715))

*   Deprecado `connection.tables` en los adaptadores SQLite3 y MySQL.
    ([Pull Request](https://github.com/rails/rails/pull/21601))

*   Deprecado pasar argumentos a `#tables` - el método `#tables` de algunos
    adaptadores (mysql2, sqlite3) devolvería tanto tablas como vistas, mientras que otros
    (postgresql) solo devuelven tablas. Para hacer que su comportamiento sea consistente,
    `#tables` solo devolverá tablas en el futuro.
    ([Pull Request](https://github.com/rails/rails/pull/21601))
*   Obsoleto `table_exists?` - El método `#table_exists?` verificaba tanto las tablas como las vistas. Para que su comportamiento sea consistente con `#tables`, en el futuro `#table_exists?` solo verificará las tablas.
    ([Pull Request](https://github.com/rails/rails/pull/21601))

*   Obsoleto el envío del argumento `offset` a `find_nth`. Por favor, use el método `offset` en la relación en su lugar.
    ([Pull Request](https://github.com/rails/rails/pull/22053))

*   Obsoletos `{insert|update|delete}_sql` en `DatabaseStatements`. Use los métodos públicos `{insert|update|delete}` en su lugar.
    ([Pull Request](https://github.com/rails/rails/pull/23086))

*   Obsoleto `use_transactional_fixtures` en favor de `use_transactional_tests` para mayor claridad.
    ([Pull Request](https://github.com/rails/rails/pull/19282))

*   Obsoleto pasar una columna a `ActiveRecord::Connection#quote`.
    ([commit](https://github.com/rails/rails/commit/7bb620869725ad6de603f6a5393ee17df13aa96c))

*   Se agregó una opción `end` a `find_in_batches` que complementa el parámetro `start` para especificar dónde detener el procesamiento por lotes.
    ([Pull Request](https://github.com/rails/rails/pull/12257))


### Cambios destacados

*   Se agregó la opción `foreign_key` a `references` al crear la tabla.
    ([commit](https://github.com/rails/rails/commit/99a6f9e60ea55924b44f894a16f8de0162cf2702))

*   Nueva API de atributos.
    ([commit](https://github.com/rails/rails/commit/8c752c7ac739d5a86d4136ab1e9d0142c4041e58))

*   Se agregó la opción `:_prefix`/`:_suffix` a la definición de `enum`.
    ([Pull Request](https://github.com/rails/rails/pull/19813),
     [Pull Request](https://github.com/rails/rails/pull/20999))

*   Se agregó `#cache_key` a `ActiveRecord::Relation`.
    ([Pull Request](https://github.com/rails/rails/pull/20884))

*   Se cambió el valor predeterminado de `null` para `timestamps` a `false`.
    ([commit](https://github.com/rails/rails/commit/a939506f297b667291480f26fa32a373a18ae06a))

*   Se agregó `ActiveRecord::SecureToken` para encapsular la generación de tokens únicos para atributos en un modelo usando `SecureRandom`.
    ([Pull Request](https://github.com/rails/rails/pull/18217))

*   Se agregó la opción `:if_exists` para `drop_table`.
    ([Pull Request](https://github.com/rails/rails/pull/18597))

*   Se agregó `ActiveRecord::Base#accessed_fields`, que se puede usar para descubrir rápidamente qué campos se leyeron de un modelo cuando se busca seleccionar solo los datos necesarios de la base de datos.
    ([commit](https://github.com/rails/rails/commit/be9b68038e83a617eb38c26147659162e4ac3d2c))

*   Se agregó el método `#or` a `ActiveRecord::Relation`, que permite usar el operador OR para combinar cláusulas WHERE o HAVING.
    ([commit](https://github.com/rails/rails/commit/b0b37942d729b6bdcd2e3178eda7fa1de203b3d0))

*   Se agregó `ActiveRecord::Base.suppress` para evitar que el receptor se guarde durante el bloque dado.
    ([Pull Request](https://github.com/rails/rails/pull/18910))

*   `belongs_to` ahora generará un error de validación de forma predeterminada si la asociación no está presente. Puede desactivar esto por asociación con `optional: true`. También se deprecia la opción `required` en favor de `optional` para `belongs_to`.
    ([Pull Request](https://github.com/rails/rails/pull/18937))

*   Se agregó `config.active_record.dump_schemas` para configurar el comportamiento de `db:structure:dump`.
    ([Pull Request](https://github.com/rails/rails/pull/19347))

*   Se agregó la opción `config.active_record.warn_on_records_fetched_greater_than`.
    ([Pull Request](https://github.com/rails/rails/pull/18846))

*   Se agregó soporte nativo para el tipo de datos JSON en MySQL.
    ([Pull Request](https://github.com/rails/rails/pull/21110))

*   Se agregó soporte para eliminar índices concurrentemente en PostgreSQL.
    ([Pull Request](https://github.com/rails/rails/pull/21317))

*   Se agregaron los métodos `#views` y `#view_exists?` en los adaptadores de conexión.
    ([Pull Request](https://github.com/rails/rails/pull/21609))

*   Se agregó `ActiveRecord::Base.ignored_columns` para hacer que algunas columnas sean invisibles para Active Record.
    ([Pull Request](https://github.com/rails/rails/pull/21720))

*   Se agregaron los métodos `connection.data_sources` y `connection.data_source_exists?`. Estos métodos determinan qué relaciones se pueden utilizar para respaldar los modelos de Active Record (generalmente tablas y vistas).
    ([Pull Request](https://github.com/rails/rails/pull/21715))

*   Los archivos de fixtures ahora pueden establecer la clase del modelo en el propio archivo YAML.
    ([Pull Request](https://github.com/rails/rails/pull/20574))

*   Se agregó la capacidad de utilizar `uuid` como clave primaria de forma predeterminada al generar migraciones de base de datos.
    ([Pull Request](https://github.com/rails/rails/pull/21762))
*   Agregado `ActiveRecord::Relation#left_joins` y `ActiveRecord::Relation#left_outer_joins`. ([Pull Request](https://github.com/rails/rails/pull/12071))

*   Agregados callbacks `after_{create,update,delete}_commit`. ([Pull Request](https://github.com/rails/rails/pull/22516))

*   Versionado de la API presentada a las clases de migración, para poder cambiar los valores predeterminados de los parámetros sin romper las migraciones existentes, ni forzar a que sean reescritas a través de un ciclo de deprecación. ([Pull Request](https://github.com/rails/rails/pull/21538))

*   `ApplicationRecord` es una nueva superclase para todos los modelos de la aplicación, análoga a los controladores de la aplicación que heredan de `ApplicationController` en lugar de `ActionController::Base`. Esto proporciona a las aplicaciones un único lugar para configurar el comportamiento de los modelos en toda la aplicación. ([Pull Request](https://github.com/rails/rails/pull/22567))

*   Agregados los métodos `#second_to_last` y `#third_to_last` a ActiveRecord. ([Pull Request](https://github.com/rails/rails/pull/23583))

*   Agregada la capacidad de anotar objetos de la base de datos (tablas, columnas, índices) con comentarios almacenados en los metadatos de la base de datos para PostgreSQL y MySQL. ([Pull Request](https://github.com/rails/rails/pull/22911))

*   Agregado soporte para prepared statements en el adaptador `mysql2`, para mysql2 0.4.4+. Anteriormente, esto solo era compatible con el adaptador heredado `mysql` en desuso. Para habilitarlo, establezca `prepared_statements: true` en `config/database.yml`. ([Pull Request](https://github.com/rails/rails/pull/23461))

*   Agregada la capacidad de llamar al método `ActionRecord::Relation#update` en objetos de relación, lo que ejecutará validaciones y callbacks en todos los objetos de la relación. ([Pull Request](https://github.com/rails/rails/pull/11898))

*   Agregada la opción `:touch` al método `save` para que los registros se puedan guardar sin actualizar las marcas de tiempo. ([Pull Request](https://github.com/rails/rails/pull/18225))

*   Agregado soporte para índices de expresiones y clases de operadores en PostgreSQL. ([commit](https://github.com/rails/rails/commit/edc2b7718725016e988089b5fb6d6fb9d6e16882))

*   Agregada la opción `:index_errors` para agregar índices a los errores de atributos anidados. ([Pull Request](https://github.com/rails/rails/pull/19686))

*   Agregado soporte para dependencias de eliminación bidireccionales. ([Pull Request](https://github.com/rails/rails/pull/18548))

*   Agregado soporte para callbacks `after_commit` en pruebas transaccionales. ([Pull Request](https://github.com/rails/rails/pull/18458))

*   Agregado el método `foreign_key_exists?` para verificar si una clave foránea existe en una tabla o no. ([Pull Request](https://github.com/rails/rails/pull/18662))

*   Agregada la opción `:time` al método `touch` para tocar registros con una hora diferente a la hora actual. ([Pull Request](https://github.com/rails/rails/pull/18956))

*   Cambiados los callbacks de transacción para no ocultar errores. Antes de este cambio, cualquier error generado dentro de un callback de transacción era rescatado e impreso en los registros, a menos que se usara la opción (recién deprecada) `raise_in_transactional_callbacks = true`. Ahora, estos errores ya no son rescatados y simplemente se propagan, coincidiendo con el comportamiento de otros callbacks. ([commit](https://github.com/rails/rails/commit/07d3d402341e81ada0214f2cb2be1da69eadfe72))

Active Model
------------

Consulte el [Changelog][active-model] para obtener cambios detallados.

### Eliminaciones

*   Eliminados los métodos obsoletos `ActiveModel::Dirty#reset_#{attribute}` y `ActiveModel::Dirty#reset_changes`. ([Pull Request](https://github.com/rails/rails/commit/37175a24bd508e2983247ec5d011d57df836c743))

*   Eliminada la serialización XML. Esta característica se ha extraído a la gema [activemodel-serializers-xml](https://github.com/rails/activemodel-serializers-xml). ([Pull Request](https://github.com/rails/rails/pull/21161))

*   Eliminado el módulo `ActionController::ModelNaming`. ([Pull Request](https://github.com/rails/rails/pull/18194))

### Deprecaciones

*   Deprecado el retorno de `false` como forma de detener las cadenas de callbacks de Active Model y `ActiveModel::Validations`. La forma recomendada es usar `throw(:abort)`. ([Pull Request](https://github.com/rails/rails/pull/17227))

*   Deprecados los métodos `ActiveModel::Errors#get`, `ActiveModel::Errors#set` y `ActiveModel::Errors#[]=` que tienen un comportamiento inconsistente. ([Pull Request](https://github.com/rails/rails/pull/18634))

*   Deprecada la opción `:tokenizer` para `validates_length_of`, a favor de Ruby puro. ([Pull Request](https://github.com/rails/rails/pull/19585))
*   Se ha eliminado `ActiveModel::Errors#add_on_empty` y `ActiveModel::Errors#add_on_blank`
    sin reemplazo.
    ([Pull Request](https://github.com/rails/rails/pull/18996))

### Cambios destacados

*   Se ha agregado `ActiveModel::Errors#details` para determinar qué validador ha fallado.
    ([Pull Request](https://github.com/rails/rails/pull/18322))

*   Se ha extraído `ActiveRecord::AttributeAssignment` a `ActiveModel::AttributeAssignment`
    permitiendo su uso para cualquier objeto como un módulo incluible.
    ([Pull Request](https://github.com/rails/rails/pull/10776))

*   Se han agregado `ActiveModel::Dirty#[attr_name]_previously_changed?` y
    `ActiveModel::Dirty#[attr_name]_previous_change` para mejorar el acceso
    a los cambios registrados después de que el modelo ha sido guardado.
    ([Pull Request](https://github.com/rails/rails/pull/19847))

*   Se validan múltiples contextos en `valid?` e `invalid?` a la vez.
    ([Pull Request](https://github.com/rails/rails/pull/21069))

*   Se ha cambiado `validates_acceptance_of` para aceptar `true` como valor predeterminado
    además de `1`.
    ([Pull Request](https://github.com/rails/rails/pull/18439))

Active Job
-----------

Consulte el [registro de cambios][active-job] para obtener cambios detallados.

### Cambios destacados

*   `ActiveJob::Base.deserialize` delega a la clase de trabajo. Esto permite que los trabajos
    adjunten metadatos arbitrarios cuando se serializan y los lean cuando se realizan.
    ([Pull Request](https://github.com/rails/rails/pull/18260))

*   Se agrega la capacidad de configurar el adaptador de cola en cada trabajo sin
    afectar a los demás.
    ([Pull Request](https://github.com/rails/rails/pull/16992))

*   Ahora, un trabajo generado hereda de `app/jobs/application_job.rb` de forma predeterminada.
    ([Pull Request](https://github.com/rails/rails/pull/19034))

*   Se permite que `DelayedJob`, `Sidekiq`, `qu`, `que` y `queue_classic` informen
    el ID del trabajo a `ActiveJob::Base` como `provider_job_id`.
    ([Pull Request](https://github.com/rails/rails/pull/20064),
     [Pull Request](https://github.com/rails/rails/pull/20056),
     [commit](https://github.com/rails/rails/commit/68e3279163d06e6b04e043f91c9470e9259bbbe0))

*   Se implementa un procesador de `AsyncJob` simple y un `AsyncAdapter` asociado que
    encola trabajos en un grupo de hilos de `concurrent-ruby`.
    ([Pull Request](https://github.com/rails/rails/pull/21257))

*   Se cambia el adaptador predeterminado de en línea a asíncrono. Es una mejor opción ya que
    las pruebas no dependerán erróneamente de un comportamiento que ocurre de forma sincrónica.
    ([commit](https://github.com/rails/rails/commit/625baa69d14881ac49ba2e5c7d9cac4b222d7022))

Active Support
--------------

Consulte el [registro de cambios][active-support] para obtener cambios detallados.

### Eliminaciones

*   Se ha eliminado `ActiveSupport::JSON::Encoding::CircularReferenceError` obsoleto.
    ([commit](https://github.com/rails/rails/commit/d6e06ea8275cdc3f126f926ed9b5349fde374b10))

*   Se han eliminado los métodos obsoletos `ActiveSupport::JSON::Encoding.encode_big_decimal_as_string=`
    y `ActiveSupport::JSON::Encoding.encode_big_decimal_as_string`.
    ([commit](https://github.com/rails/rails/commit/c8019c0611791b2716c6bed48ef8dcb177b7869c))

*   Se ha eliminado `ActiveSupport::SafeBuffer#prepend` obsoleto.
    ([commit](https://github.com/rails/rails/commit/e1c8b9f688c56aaedac9466a4343df955b4a67ec))

*   Se han eliminado los métodos obsoletos de `Kernel`. `silence_stderr`, `silence_stream`,
    `capture` y `quietly`.
    ([commit](https://github.com/rails/rails/commit/481e49c64f790e46f4aff3ed539ed227d2eb46cb))

*   Se ha eliminado el archivo obsoleto `active_support/core_ext/big_decimal/yaml_conversions`.
    ([commit](https://github.com/rails/rails/commit/98ea19925d6db642731741c3b91bd085fac92241))

*   Se han eliminado los métodos obsoletos `ActiveSupport::Cache::Store.instrument` y
    `ActiveSupport::Cache::Store.instrument=`.
    ([commit](https://github.com/rails/rails/commit/a3ce6ca30ed0e77496c63781af596b149687b6d7))

*   Se ha eliminado `Class#superclass_delegating_accessor` obsoleto.
    Use `Class#class_attribute` en su lugar.
    ([Pull Request](https://github.com/rails/rails/pull/16938))

*   Se ha eliminado `ThreadSafe::Cache`. Use `Concurrent::Map` en su lugar.
    ([Pull Request](https://github.com/rails/rails/pull/21679))

*   Se ha eliminado `Object#itself` ya que está implementado en Ruby 2.2.
    ([Pull Request](https://github.com/rails/rails/pull/18244))

### Deprecaciones

*   Se ha deprecado `MissingSourceFile` a favor de `LoadError`.
    ([commit](https://github.com/rails/rails/commit/734d97d2))

*   Se ha deprecado `alias_method_chain` en favor de `Module#prepend` introducido en
    Ruby 2.0.
    ([Pull Request](https://github.com/rails/rails/pull/19434))

*   Se ha deprecado `ActiveSupport::Concurrency::Latch` a favor de
    `Concurrent::CountDownLatch` de concurrent-ruby.
    ([Pull Request](https://github.com/rails/rails/pull/20866))

*   Se ha deprecado la opción `:prefix` de `number_to_human_size` sin reemplazo.
    ([Pull Request](https://github.com/rails/rails/pull/21191))

*   Se ha deprecado `Module#qualified_const_` en favor de los métodos integrados
    `Module#const_`.
    ([Pull Request](https://github.com/rails/rails/pull/17845))

*   Se ha deprecado pasar una cadena para definir un callback.
    ([Pull Request](https://github.com/rails/rails/pull/22598))

*   Se ha deprecado `ActiveSupport::Cache::Store#namespaced_key`,
    `ActiveSupport::Cache::MemCachedStore#escape_key` y
    `ActiveSupport::Cache::FileStore#key_file_path`.
    Use `normalize_key` en su lugar.
    ([Pull Request](https://github.com/rails/rails/pull/22215),
     [commit](https://github.com/rails/rails/commit/a8f773b0))

*   Se ha deprecado `ActiveSupport::Cache::LocaleCache#set_cache_value` a favor de `write_cache_value`.
    ([Pull Request](https://github.com/rails/rails/pull/22215))
*   Se ha dejado de recomendar pasar argumentos a `assert_nothing_raised`.
    ([Pull Request](https://github.com/rails/rails/pull/23789))

*   Se ha dejado de recomendar `Module.local_constants` en favor de `Module.constants(false)`.
    ([Pull Request](https://github.com/rails/rails/pull/23936))


### Cambios destacados

*   Se han agregado los métodos `#verified` y `#valid_message?` a
    `ActiveSupport::MessageVerifier`.
    ([Pull Request](https://github.com/rails/rails/pull/17727))

*   Se ha cambiado la forma en que se pueden detener las cadenas de callbacks. El método preferido
    para detener una cadena de callbacks a partir de ahora es lanzar explícitamente `throw(:abort)`.
    ([Pull Request](https://github.com/rails/rails/pull/17227))

*   Nueva opción de configuración
    `config.active_support.halt_callback_chains_on_return_false` para especificar
    si las cadenas de callbacks de ActiveRecord, ActiveModel y ActiveModel::Validations
    pueden detenerse al devolver `false` en un callback 'before'.
    ([Pull Request](https://github.com/rails/rails/pull/17227))

*   Se ha cambiado el orden de prueba predeterminado de `:sorted` a `:random`.
    ([commit](https://github.com/rails/rails/commit/5f777e4b5ee2e3e8e6fd0e2a208ec2a4d25a960d))

*   Se han agregado los métodos `#on_weekend?`, `#on_weekday?`, `#next_weekday`, `#prev_weekday` a `Date`,
    `Time` y `DateTime`.
    ([Pull Request](https://github.com/rails/rails/pull/18335),
     [Pull Request](https://github.com/rails/rails/pull/23687))

*   Se ha agregado la opción `same_time` a `#next_week` y `#prev_week` para `Date`, `Time`,
    y `DateTime`.
    ([Pull Request](https://github.com/rails/rails/pull/18335))

*   Se han agregado los métodos `#prev_day` y `#next_day` como contrapartes de `#yesterday` y
    `#tomorrow` para `Date`, `Time` y `DateTime`.
    ([Pull Request](https://github.com/rails/rails/pull/18335))

*   Se ha agregado `SecureRandom.base58` para generar cadenas aleatorias en base58.
    ([commit](https://github.com/rails/rails/commit/b1093977110f18ae0cafe56c3d99fc22a7d54d1b))

*   Se ha agregado `file_fixture` a `ActiveSupport::TestCase`.
    Proporciona un mecanismo sencillo para acceder a archivos de muestra en tus casos de prueba.
    ([Pull Request](https://github.com/rails/rails/pull/18658))

*   Se ha agregado `#without` a `Enumerable` y `Array` para devolver una copia de un
    enumerable sin los elementos especificados.
    ([Pull Request](https://github.com/rails/rails/pull/19157))

*   Se ha agregado `ActiveSupport::ArrayInquirer` y `Array#inquiry`.
    ([Pull Request](https://github.com/rails/rails/pull/18939))

*   Se ha agregado `ActiveSupport::TimeZone#strptime` para permitir el análisis de horas como si
    fueran de una zona horaria dada.
    ([commit](https://github.com/rails/rails/commit/a5e507fa0b8180c3d97458a9b86c195e9857d8f6))

*   Se han agregado los métodos de consulta `Integer#positive?` y `Integer#negative?`
    en la línea de `Integer#zero?`.
    ([commit](https://github.com/rails/rails/commit/e54277a45da3c86fecdfa930663d7692fd083daa))

*   Se ha agregado una versión con exclamación a los métodos de obtención de `ActiveSupport::OrderedOptions` que lanzará
    un `KeyError` si el valor es `.blank?`.
    ([Pull Request](https://github.com/rails/rails/pull/20208))

*   Se ha agregado `Time.days_in_year` para devolver el número de días en el año dado, o el
    año actual si no se proporciona ningún argumento.
    ([commit](https://github.com/rails/rails/commit/2f4f4d2cf1e4c5a442459fc250daf66186d110fa))

*   Se ha agregado un observador de archivos con eventos para detectar de forma asíncrona cambios en el
    código fuente de la aplicación, rutas, locales, etc.
    ([Pull Request](https://github.com/rails/rails/pull/22254))

*   Se han agregado los métodos `thread_m/cattr_accessor/reader/writer` para declarar
    variables de clase y módulo que viven por hilo.
    ([Pull Request](https://github.com/rails/rails/pull/22630))

*   Se han agregado los métodos `Array#second_to_last` y `Array#third_to_last`.
    ([Pull Request](https://github.com/rails/rails/pull/23583))

*   Se han publicado las APIs `ActiveSupport::Executor` y `ActiveSupport::Reloader` para permitir que
    componentes y bibliotecas administren y participen en la ejecución de
    código de aplicación y el proceso de recarga de la aplicación.
    ([Pull Request](https://github.com/rails/rails/pull/23807))

*   `ActiveSupport::Duration` ahora admite el formato y análisis ISO8601.
    ([Pull Request](https://github.com/rails/rails/pull/16917))

*   `ActiveSupport::JSON.decode` ahora admite el análisis de horas locales ISO8601 cuando
    `parse_json_times` está habilitado.
    ([Pull Request](https://github.com/rails/rails/pull/23011))

*   `ActiveSupport::JSON.decode` ahora devuelve objetos `Date` para cadenas de fecha.
    ([Pull Request](https://github.com/rails/rails/pull/23011))

*   Se ha agregado la capacidad de `TaggedLogging` para permitir que los registradores se instancien múltiples
    veces para que no compartan etiquetas entre sí.
    ([Pull Request](https://github.com/rails/rails/pull/9065))
Créditos
-------

Consulte la [lista completa de colaboradores de Rails](https://contributors.rubyonrails.org/) para conocer a las muchas personas que dedicaron muchas horas para hacer de Rails el marco estable y robusto que es. Felicitaciones a todos ellos.

[railties]:       https://github.com/rails/rails/blob/5-0-stable/railties/CHANGELOG.md
[action-pack]:    https://github.com/rails/rails/blob/5-0-stable/actionpack/CHANGELOG.md
[action-view]:    https://github.com/rails/rails/blob/5-0-stable/actionview/CHANGELOG.md
[action-mailer]:  https://github.com/rails/rails/blob/5-0-stable/actionmailer/CHANGELOG.md
[action-cable]:   https://github.com/rails/rails/blob/5-0-stable/actioncable/CHANGELOG.md
[active-record]:  https://github.com/rails/rails/blob/5-0-stable/activerecord/CHANGELOG.md
[active-model]:   https://github.com/rails/rails/blob/5-0-stable/activemodel/CHANGELOG.md
[active-job]:     https://github.com/rails/rails/blob/5-0-stable/activejob/CHANGELOG.md
[active-support]: https://github.com/rails/rails/blob/5-0-stable/activesupport/CHANGELOG.md
