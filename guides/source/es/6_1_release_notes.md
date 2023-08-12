**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 1d652e6ccda9c901ca3f6a003c95f83e
Notas de lanzamiento de Ruby on Rails 6.1
=========================================

Aspectos destacados en Rails 6.1:

* Cambio de conexión por base de datos
* Fragmentación horizontal
* Carga estricta de asociaciones
* Tipos delegados
* Destrucción de asociaciones de forma asíncrona

Estas notas de lanzamiento solo cubren los cambios principales. Para conocer las correcciones de errores y cambios diversos, consulte los registros de cambios o revise la [lista de confirmaciones](https://github.com/rails/rails/commits/6-1-stable) en el repositorio principal de Rails en GitHub.

--------------------------------------------------------------------------------

Actualización a Rails 6.1
-------------------------

Si está actualizando una aplicación existente, es una buena idea tener una buena cobertura de pruebas antes de comenzar. También debe actualizar primero a Rails 6.0 en caso de que aún no lo haya hecho y asegurarse de que su aplicación siga funcionando como se espera antes de intentar una actualización a Rails 6.1. Una lista de cosas a tener en cuenta al actualizar está disponible en la guía de [Actualización de Ruby on Rails](upgrading_ruby_on_rails.html#upgrading-from-rails-6-0-to-rails-6-1).

Funcionalidades principales
---------------------------

### Cambio de conexión por base de datos

Rails 6.1 le proporciona la capacidad de [cambiar de conexión por base de datos](https://github.com/rails/rails/pull/40370). En la versión 6.0, si cambiaba al rol de "lectura", todas las conexiones de la base de datos también cambiaban al rol de lectura. Ahora, en la versión 6.1, si configura `legacy_connection_handling` en `false` en su configuración, Rails le permitirá cambiar de conexión para una sola base de datos llamando a `connected_to` en la clase abstracta correspondiente.

### Fragmentación horizontal

Rails 6.0 proporcionaba la capacidad de particionar funcionalmente (múltiples particiones, esquemas diferentes) su base de datos, pero no podía admitir la fragmentación horizontal (mismo esquema, múltiples particiones). Rails no podía admitir la fragmentación horizontal porque los modelos en Active Record solo podían tener una conexión por rol por clase. Esto ahora se ha solucionado y la [fragmentación horizontal](https://github.com/rails/rails/pull/38531) con Rails está disponible.

### Carga estricta de asociaciones

La [carga estricta de asociaciones](https://github.com/rails/rails/pull/37400) le permite asegurarse de que todas sus asociaciones se carguen de forma anticipada y evitar los problemas de N+1.

### Tipos delegados

[Tipos delegados](https://github.com/rails/rails/pull/39341) es una alternativa a la herencia de una sola tabla. Esto ayuda a representar jerarquías de clases permitiendo que la superclase sea una clase concreta que se representa en su propia tabla. Cada subclase tiene su propia tabla para atributos adicionales.

### Destrucción de asociaciones de forma asíncrona

[Destrucción de asociaciones de forma asíncrona](https://github.com/rails/rails/pull/40157) agrega la capacidad para que las aplicaciones "destruyan" asociaciones en un trabajo en segundo plano. Esto puede ayudarlo a evitar tiempos de espera y otros problemas de rendimiento en su aplicación al eliminar datos.

Railties
--------

Consulte el [registro de cambios][railties] para obtener cambios detallados.

### Eliminaciones

*   Eliminar las tareas `rake notes` obsoletas.

*   Eliminar la opción `connection` obsoleta en el comando `rails dbconsole`.

*   Eliminar el soporte obsoleto de la variable de entorno `SOURCE_ANNOTATION_DIRECTORIES` en `rails notes`.

*   Eliminar el argumento `server` obsoleto del comando `rails server`.

*   Eliminar el soporte obsoleto para usar la variable de entorno `HOST` para especificar la IP del servidor.

*   Eliminar las tareas `rake dev:cache` obsoletas.

*   Eliminar las tareas `rake routes` obsoletas.

*   Eliminar las tareas `rake initializers` obsoletas.

### Deprecaciones

### Cambios destacados

Action Cable
------------

Consulte el [registro de cambios][action-cable] para obtener cambios detallados.

### Eliminaciones

### Deprecaciones

### Cambios destacados

Action Pack
-----------

Consulte el [registro de cambios][action-pack] para obtener cambios detallados.

### Eliminaciones

*   Eliminar `ActionDispatch::Http::ParameterFilter` obsoleto.

*   Eliminar `force_ssl` obsoleto a nivel de controlador.

### Deprecaciones

*   Deprecar `config.action_dispatch.return_only_media_type_on_content_type`.

### Cambios destacados

*   Cambiar `ActionDispatch::Response#content_type` para devolver el encabezado completo de Content-Type.

Action View
-----------

Consulte el [registro de cambios][action-view] para obtener cambios detallados.

### Eliminaciones

*   Eliminar `escape_whitelist` obsoleto de `ActionView::Template::Handlers::ERB`.

*   Eliminar `find_all_anywhere` obsoleto de `ActionView::Resolver`.

*   Eliminar `formats` obsoleto de `ActionView::Template::HTML`.

*   Eliminar `formats` obsoleto de `ActionView::Template::RawFile`.

*   Eliminar `formats` obsoleto de `ActionView::Template::Text`.

*   Eliminar `find_file` obsoleto de `ActionView::PathSet`.

*   Eliminar `rendered_format` obsoleto de `ActionView::LookupContext`.

*   Eliminar `find_file` obsoleto de `ActionView::ViewPaths`.

*   Eliminar el soporte obsoleto para pasar un objeto que no es un `ActionView::LookupContext` como primer argumento en `ActionView::Base#initialize`.

*   Eliminar el argumento `format` obsoleto en `ActionView::Base#initialize`.

*   Eliminar `ActionView::Template#refresh` obsoleto.

*   Eliminar `ActionView::Template#original_encoding` obsoleto.

*   Eliminar `ActionView::Template#variants` obsoleto.

*   Eliminar `ActionView::Template#formats` obsoleto.

*   Eliminar `ActionView::Template#virtual_path=` obsoleto.

*   Eliminar `ActionView::Template#updated_at` obsoleto.

*   Eliminar el argumento `updated_at` requerido en `ActionView::Template#initialize`.

*   Eliminar `ActionView::Template.finalize_compiled_template_methods` obsoleto.

*   Eliminar `config.action_view.finalize_compiled_template_methods` obsoleto.

*   Eliminar el soporte obsoleto para llamar a `ActionView::ViewPaths#with_fallback` con un bloque.

*   Eliminar el soporte obsoleto para pasar rutas absolutas a `render template:`.

*   Eliminar el soporte obsoleto para pasar rutas relativas a `render file:`.

*   Eliminar el soporte para manejadores de plantillas que no aceptan dos argumentos.

*   Eliminar el argumento de patrón obsoleto en `ActionView::Template::PathResolver`.

*   Eliminar el soporte obsoleto para llamar a métodos privados de un objeto en algunos ayudantes de vista.

### Deprecaciones

### Cambios destacados
*   Requerir que las subclases de `ActionView::Base` implementen `#compiled_method_container`.

*   Hacer que el argumento `locals` sea obligatorio en `ActionView::Template#initialize`.

*   Los ayudantes de activos `javascript_include_tag` y `stylesheet_link_tag` generan una cabecera `Link` que proporciona pistas a los navegadores modernos sobre la precarga de activos. Esto se puede desactivar configurando `config.action_view.preload_links_header` como `false`.

Action Mailer
-------------

Consulte el [registro de cambios][action-mailer] para obtener cambios detallados.

### Eliminaciones

*   Eliminar `ActionMailer::Base.receive` en desuso a favor de [Action Mailbox](https://github.com/rails/rails/tree/6-1-stable/actionmailbox).

### Deprecaciones

### Cambios destacados

Active Record
-------------

Consulte el [registro de cambios][active-record] para obtener cambios detallados.

### Eliminaciones

*   Eliminar métodos en desuso de `ActiveRecord::ConnectionAdapters::DatabaseLimits`.

    `column_name_length`
    `table_name_length`
    `columns_per_table`
    `indexes_per_table`
    `columns_per_multicolumn_index`
    `sql_query_length`
    `joins_per_query`

*   Eliminar `ActiveRecord::ConnectionAdapters::AbstractAdapter#supports_multi_insert?` en desuso.

*   Eliminar `ActiveRecord::ConnectionAdapters::AbstractAdapter#supports_foreign_keys_in_create?` en desuso.

*   Eliminar `ActiveRecord::ConnectionAdapters::PostgreSQLAdapter#supports_ranges?` en desuso.

*   Eliminar `ActiveRecord::Base#update_attributes` y `ActiveRecord::Base#update_attributes!` en desuso.

*   Eliminar el argumento `migrations_path` en desuso en
    `ActiveRecord::ConnectionAdapter::SchemaStatements#assume_migrated_upto_version`.

*   Eliminar `config.active_record.sqlite3.represent_boolean_as_integer` en desuso.

*   Eliminar métodos en desuso de `ActiveRecord::DatabaseConfigurations`.

    `fetch`
    `each`
    `first`
    `values`
    `[]=`

*   Eliminar el método `ActiveRecord::Result#to_hash` en desuso.

*   Eliminar el soporte en desuso para el uso de SQL sin procesar inseguro en los métodos de `ActiveRecord::Relation`.

### Deprecaciones

*   Deprecar `ActiveRecord::Base.allow_unsafe_raw_sql`.

*   Deprecar el argumento `database` en `connected_to`.

*   Deprecar `connection_handlers` cuando `legacy_connection_handling` se establece en false.

### Cambios destacados

*   MySQL: El validador de unicidad ahora respeta la intercalación predeterminada de la base de datos,
    ya no impone una comparación sensible a mayúsculas y minúsculas de forma predeterminada.

*   `relation.create` ya no filtra el ámbito a los métodos de consulta a nivel de clase
    en el bloque de inicialización y en los callbacks.

    Antes:

    ```ruby
    User.where(name: "John").create do |john|
      User.find_by(name: "David") # => nil
    end
    ```

    Después:

    ```ruby
    User.where(name: "John").create do |john|
      User.find_by(name: "David") # => #<User name: "David", ...>
    end
    ```

*   La cadena de ámbito con nombre ya no filtra el ámbito a los métodos de consulta a nivel de clase.

    ```ruby
    class User < ActiveRecord::Base
      scope :david, -> { User.where(name: "David") }
    end
    ```

    Antes:

    ```ruby
    User.where(name: "John").david
    # SELECT * FROM users WHERE name = 'John' AND name = 'David'
    ```

    Después:

    ```ruby
    User.where(name: "John").david
    # SELECT * FROM users WHERE name = 'David'
    ```

*   `where.not` ahora genera predicados NAND en lugar de NOR.

    Antes:

    ```ruby
    User.where.not(name: "Jon", role: "admin")
    # SELECT * FROM users WHERE name != 'Jon' AND role != 'admin'
    ```

    Después:

    ```ruby
    User.where.not(name: "Jon", role: "admin")
    # SELECT * FROM users WHERE NOT (name = 'Jon' AND role = 'admin')
    ```

*   Para utilizar el nuevo manejo de conexiones por base de datos, las aplicaciones deben cambiar
    `legacy_connection_handling` a false y eliminar los accesos en desuso en
    `connection_handlers`. Los métodos públicos para `connects_to` y `connected_to`
    no requieren cambios.

Active Storage
--------------

Consulte el [registro de cambios][active-storage] para obtener cambios detallados.

### Eliminaciones

*   Eliminar el soporte en desuso para pasar operaciones `:combine_options` a `ActiveStorage::Transformers::ImageProcessing`.

*   Eliminar `ActiveStorage::Transformers::MiniMagickTransformer` en desuso.

*   Eliminar `config.active_storage.queue` en desuso.

*   Eliminar `ActiveStorage::Downloading` en desuso.

### Deprecaciones

*   Deprecar `Blob.create_after_upload` a favor de `Blob.create_and_upload`.
    ([Pull Request](https://github.com/rails/rails/pull/34827))

### Cambios destacados

*   Agregar `Blob.create_and_upload` para crear un nuevo blob y cargar el `io` dado al servicio.
    ([Pull Request](https://github.com/rails/rails/pull/34827))
*   Se agregó la columna `service_name` a `ActiveStorage::Blob`. Es necesario ejecutar una migración después de la actualización. Ejecute `bin/rails app:update` para generar esa migración.

Active Model
------------

Consulte el [registro de cambios][active-model] para obtener cambios detallados.

### Eliminaciones

### Deprecaciones

### Cambios destacados

*   Los errores de Active Model ahora son objetos con una interfaz que permite a su aplicación manejar e interactuar más fácilmente con los errores generados por los modelos.
    [La característica](https://github.com/rails/rails/pull/32313) incluye una interfaz de consulta, permite pruebas más precisas y acceso a los detalles del error.

Active Support
--------------

Consulte el [registro de cambios][active-support] para obtener cambios detallados.

### Eliminaciones

*   Eliminar la intercalación predeterminada a `I18n.default_locale` cuando `config.i18n.fallbacks` está vacío.

*   Eliminar la constante `LoggerSilence` en desuso.

*   Eliminar `ActiveSupport::LoggerThreadSafeLevel#after_initialize` en desuso.

*   Eliminar los métodos `Module#parent_name`, `Module#parent` y `Module#parents`.

*   Eliminar el archivo en desuso `active_support/core_ext/module/reachable`.

*   Eliminar el archivo en desuso `active_support/core_ext/numeric/inquiry`.

*   Eliminar el archivo en desuso `active_support/core_ext/array/prepend_and_append`.

*   Eliminar el archivo en desuso `active_support/core_ext/hash/compact`.

*   Eliminar el archivo en desuso `active_support/core_ext/hash/transform_values`.

*   Eliminar el archivo en desuso `active_support/core_ext/range/include_range`.

*   Eliminar `ActiveSupport::Multibyte::Chars#consumes?` y `ActiveSupport::Multibyte::Chars#normalize` en desuso.

*   Eliminar `ActiveSupport::Multibyte::Unicode.pack_graphemes`,
    `ActiveSupport::Multibyte::Unicode.unpack_graphemes`,
    `ActiveSupport::Multibyte::Unicode.normalize`,
    `ActiveSupport::Multibyte::Unicode.downcase`,
    `ActiveSupport::Multibyte::Unicode.upcase` y `ActiveSupport::Multibyte::Unicode.swapcase` en desuso.

*   Eliminar `ActiveSupport::Notifications::Instrumenter#end=` en desuso.

### Deprecaciones

*   Deprecar `ActiveSupport::Multibyte::Unicode.default_normalization_form`.

### Cambios destacados

Active Job
----------

Consulte el [registro de cambios][active-job] para obtener cambios detallados.

### Eliminaciones

### Deprecaciones

*   Deprecar `config.active_job.return_false_on_aborted_enqueue`.

### Cambios destacados

*   Devolver `false` cuando se aborta la encolación de un trabajo.

Action Text
----------

Consulte el [registro de cambios][action-text] para obtener cambios detallados.

### Eliminaciones

### Deprecaciones

### Cambios destacados

*   Agregar un método para confirmar la existencia de contenido de texto enriquecido agregando `?` después
    del nombre del atributo de texto enriquecido.
    ([Pull Request](https://github.com/rails/rails/pull/37951))

*   Agregar el ayudante de caso de prueba del sistema `fill_in_rich_text_area` para encontrar un editor trix
    y llenarlo con el contenido HTML dado.
    ([Pull Request](https://github.com/rails/rails/pull/35885))
*   Agrega `ActionText::FixtureSet.attachment` para generar elementos `<action-text-attachment>` en los fixtures de la base de datos. ([Pull Request](https://github.com/rails/rails/pull/40289))

Action Mailbox
----------

Consulta el [Changelog][action-mailbox] para obtener cambios detallados.

### Eliminaciones

### Deprecaciones

*   Deprecar `Rails.application.credentials.action_mailbox.api_key` y `MAILGUN_INGRESS_API_KEY` en favor de `Rails.application.credentials.action_mailbox.signing_key` y `MAILGUN_INGRESS_SIGNING_KEY`.

### Cambios destacados

Ruby on Rails Guides
--------------------

Consulta el [Changelog][guides] para obtener cambios detallados.

### Cambios destacados

Créditos
-------

Consulta la [lista completa de contribuyentes a Rails](https://contributors.rubyonrails.org/) para ver a todas las personas que dedicaron muchas horas a hacer de Rails el marco estable y robusto que es. Felicitaciones a todos ellos.

[railties]:       https://github.com/rails/rails/blob/6-1-stable/railties/CHANGELOG.md
[action-pack]:    https://github.com/rails/rails/blob/6-1-stable/actionpack/CHANGELOG.md
[action-view]:    https://github.com/rails/rails/blob/6-1-stable/actionview/CHANGELOG.md
[action-mailer]:  https://github.com/rails/rails/blob/6-1-stable/actionmailer/CHANGELOG.md
[action-cable]:   https://github.com/rails/rails/blob/6-1-stable/actioncable/CHANGELOG.md
[active-record]:  https://github.com/rails/rails/blob/6-1-stable/activerecord/CHANGELOG.md
[active-model]:   https://github.com/rails/rails/blob/6-1-stable/activemodel/CHANGELOG.md
[active-job]:     https://github.com/rails/rails/blob/6-1-stable/activejob/CHANGELOG.md
[action-text]:    https://github.com/rails/rails/blob/6-1-stable/actiontext/CHANGELOG.md
[guides]:         https://github.com/rails/rails/blob/6-1-stable/guides/CHANGELOG.md
[active-storage]: https://github.com/rails/rails/blob/6-1-stable/activestorage/CHANGELOG.md
[active-support]: https://github.com/rails/rails/blob/6-1-stable/activesupport/CHANGELOG.md
[action-mailbox]: https://github.com/rails/rails/blob/6-1-stable/actionmailbox/CHANGELOG.md
