**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: b1c2c8ad5c4bacb2e3b92aa320c4da3d
Notas de lanzamiento de Ruby on Rails 6.0
==========================================

Aspectos destacados en Rails 6.0:

* Action Mailbox
* Action Text
* Pruebas paralelas
* Pruebas de Action Cable

Estas notas de lanzamiento solo cubren los cambios principales. Para conocer las correcciones de errores y cambios diversos, consulte los registros de cambios o revise la [lista de confirmaciones](https://github.com/rails/rails/commits/6-0-stable) en el repositorio principal de Rails en GitHub.

--------------------------------------------------------------------------------

Actualización a Rails 6.0
-------------------------

Si está actualizando una aplicación existente, es una buena idea tener una buena cobertura de pruebas antes de comenzar. También debe actualizar primero a Rails 5.2 en caso de que no lo haya hecho y asegurarse de que su aplicación siga funcionando como se espera antes de intentar una actualización a Rails 6.0. Una lista de cosas a tener en cuenta al actualizar está disponible en la guía [Actualización de Ruby on Rails](upgrading_ruby_on_rails.html#upgrading-from-rails-5-2-to-rails-6-0).

Características principales
--------------------------

### Action Mailbox

[Solicitud de extracción](https://github.com/rails/rails/pull/34786)

[Action Mailbox](https://github.com/rails/rails/tree/6-0-stable/actionmailbox) le permite enrutar correos electrónicos entrantes a buzones de correo similares a controladores. Puede obtener más información sobre Action Mailbox en la guía [Conceptos básicos de Action Mailbox](action_mailbox_basics.html).

### Action Text

[Solicitud de extracción](https://github.com/rails/rails/pull/34873)

[Action Text](https://github.com/rails/rails/tree/6-0-stable/actiontext) brinda contenido de texto enriquecido y edición a Rails. Incluye el editor [Trix](https://trix-editor.org) que maneja todo, desde el formato hasta los enlaces, citas, listas, imágenes incrustadas y galerías. El contenido de texto enriquecido generado por el editor Trix se guarda en su propio modelo RichText que está asociado con cualquier modelo Active Record existente en la aplicación. Cualquier imagen incrustada (u otros archivos adjuntos) se almacenan automáticamente utilizando Active Storage y se asocian con el modelo RichText incluido.

Puede obtener más información sobre Action Text en la guía [Descripción general de Action Text](action_text_overview.html).

### Pruebas paralelas

[Solicitud de extracción](https://github.com/rails/rails/pull/31900)

[Pruebas paralelas](testing.html#parallel-testing) le permite paralelizar su conjunto de pruebas. Si bien la bifurcación de procesos es el método predeterminado, también se admite el uso de hilos. Ejecutar pruebas en paralelo reduce el tiempo que tarda en ejecutarse todo el conjunto de pruebas.

### Pruebas de Action Cable

[Solicitud de extracción](https://github.com/rails/rails/pull/33659)

[Las herramientas de prueba de Action Cable](testing.html#testing-action-cable) le permiten probar la funcionalidad de Action Cable en cualquier nivel: conexiones, canales, transmisiones.

Railties
--------

Consulte el [registro de cambios][railties] para obtener cambios detallados.

### Eliminaciones

*   Eliminar el ayudante `after_bundle` obsoleto dentro de las plantillas de los complementos.
    ([Confirmación](https://github.com/rails/rails/commit/4d51efe24e461a2a3ed562787308484cd48370c7))

*   Eliminar el soporte obsoleto para `config.ru` que utiliza la clase de la aplicación como argumento de `run`.
    ([Confirmación](https://github.com/rails/rails/commit/553b86fc751c751db504bcbe2d033eb2bb5b6a0b))

*   Eliminar el argumento obsoleto `environment` de los comandos de Rails.
    ([Confirmación](https://github.com/rails/rails/commit/e20589c9be09c7272d73492d4b0f7b24e5595571))

*   Eliminar el método obsoleto `capify!` en generadores y plantillas.
    ([Confirmación](https://github.com/rails/rails/commit/9d39f81d512e0d16a27e2e864ea2dd0e8dc41b17))

*   Eliminar `config.secret_token` obsoleto.
    ([Confirmación](https://github.com/rails/rails/commit/46ac5fe69a20d4539a15929fe48293e1809a26b0))

### Obsolescencias

*   Obsoleto pasar el nombre del servidor Rack como un argumento regular a `rails server`.
    ([Solicitud de extracción](https://github.com/rails/rails/pull/32058))

*   Obsoleto el uso del entorno `HOST` para especificar la IP del servidor.
    ([Solicitud de extracción](https://github.com/rails/rails/pull/32540))

*   Obsoleto el acceso a los hashes devueltos por `config_for` mediante claves no simbólicas.
    ([Solicitud de extracción](https://github.com/rails/rails/pull/35198))

### Cambios destacados

*   Agregar una opción explícita `--using` o `-u` para especificar el servidor para el comando `rails server`.
    ([Solicitud de extracción](https://github.com/rails/rails/pull/32058))

*   Agregar la capacidad de ver la salida de `rails routes` en formato expandido.
    ([Solicitud de extracción](https://github.com/rails/rails/pull/32130))

*   Ejecutar la tarea de la base de datos de semillas utilizando el adaptador Active Job en línea.
    ([Solicitud de extracción](https://github.com/rails/rails/pull/34953))

*   Agregar un comando `rails db:system:change` para cambiar la base de datos de la aplicación.
    ([Solicitud de extracción](https://github.com/rails/rails/pull/34832))

*   Agregar el comando `rails test:channels` para probar solo los canales de Action Cable.
    ([Solicitud de extracción](https://github.com/rails/rails/pull/34947))
*   Introducir protección contra ataques de rebinding de DNS.
    ([Pull Request](https://github.com/rails/rails/pull/33145))

*   Agregar la capacidad de abortar en caso de fallo al ejecutar comandos de generador.
    ([Pull Request](https://github.com/rails/rails/pull/34420))

*   Hacer que Webpacker sea el compilador de JavaScript predeterminado para Rails 6.
    ([Pull Request](https://github.com/rails/rails/pull/33079))

*   Agregar soporte para múltiples bases de datos en el comando `rails db:migrate:status`.
    ([Pull Request](https://github.com/rails/rails/pull/34137))

*   Agregar la capacidad de utilizar rutas de migración diferentes de múltiples bases de datos en
    los generadores.
    ([Pull Request](https://github.com/rails/rails/pull/34021))

*   Agregar soporte para credenciales de múltiples entornos.
    ([Pull Request](https://github.com/rails/rails/pull/33521))

*   Hacer que `null_store` sea el almacén de caché predeterminado en el entorno de prueba.
    ([Pull Request](https://github.com/rails/rails/pull/33773))

Action Cable
------------

Consulte el [registro de cambios][action-cable] para obtener cambios detallados.

### Eliminaciones

*   Reemplazar `ActionCable.startDebugging()` y `ActionCable.stopDebugging()`
    con `ActionCable.logger.enabled`.
    ([Pull Request](https://github.com/rails/rails/pull/34370))

### Deprecaciones

*   No hay deprecaciones para Action Cable en Rails 6.0.

### Cambios destacados

*   Agregar soporte para la opción `channel_prefix` para adaptadores de suscripción de PostgreSQL
    en `cable.yml`.
    ([Pull Request](https://github.com/rails/rails/pull/35276))

*   Permitir pasar una configuración personalizada a `ActionCable::Server::Base`.
    ([Pull Request](https://github.com/rails/rails/pull/34714))

*   Agregar ganchos de carga `:action_cable_connection` y `:action_cable_channel`.
    ([Pull Request](https://github.com/rails/rails/pull/35094))

*   Agregar `Channel::Base#broadcast_to` y `Channel::Base.broadcasting_for`.
    ([Pull Request](https://github.com/rails/rails/pull/35021))

*   Cerrar una conexión al llamar a `reject_unauthorized_connection` desde una
    `ActionCable::Connection`.
    ([Pull Request](https://github.com/rails/rails/pull/34194))

*   Convertir el paquete de JavaScript de Action Cable de CoffeeScript a ES2015 y
    publicar el código fuente en la distribución de npm.
    ([Pull Request](https://github.com/rails/rails/pull/34370))

*   Mover la configuración del adaptador WebSocket y del adaptador de registro
    de propiedades de `ActionCable` a `ActionCable.adapters`.
    ([Pull Request](https://github.com/rails/rails/pull/34370))

*   Agregar una opción `id` al adaptador Redis para distinguir las conexiones de Redis de Action Cable.
    ([Pull Request](https://github.com/rails/rails/pull/33798))

Action Pack
-----------

Consulte el [registro de cambios][action-pack] para obtener cambios detallados.

### Eliminaciones

*   Eliminar el ayudante `fragment_cache_key` en desuso en favor de `combined_fragment_cache_key`.
    ([Commit](https://github.com/rails/rails/commit/e70d3df7c9b05c129b0fdcca57f66eca316c5cfc))

*   Eliminar los métodos en desuso en `ActionDispatch::TestResponse`:
    `#success?` en favor de `#successful?`, `#missing?` en favor de `#not_found?`,
    `#error?` en favor de `#server_error?`.
    ([Commit](https://github.com/rails/rails/commit/13ddc92e079e59a0b894e31bf5bb4fdecbd235d1))

### Deprecaciones

*   Deprecar `ActionDispatch::Http::ParameterFilter` en favor de `ActiveSupport::ParameterFilter`.
    ([Pull Request](https://github.com/rails/rails/pull/34039))

*   Deprecar `force_ssl` a nivel de controlador en favor de `config.force_ssl`.
    ([Pull Request](https://github.com/rails/rails/pull/32277))

### Cambios destacados

*   Cambiar `ActionDispatch::Response#content_type` para devolver el encabezado Content-Type tal cual.
    ([Pull Request](https://github.com/rails/rails/pull/36034))

*   Generar un `ArgumentError` si un parámetro de recurso contiene dos puntos.
    ([Pull Request](https://github.com/rails/rails/pull/35236))

*   Permitir que `ActionDispatch::SystemTestCase.driven_by` se llame con un bloque
    para definir capacidades específicas del navegador.
    ([Pull Request](https://github.com/rails/rails/pull/35081))

*   Agregar el middleware `ActionDispatch::HostAuthorization` que protege contra ataques de rebinding de DNS.
    ([Pull Request](https://github.com/rails/rails/pull/33145))

*   Permitir el uso de `parsed_body` en `ActionController::TestCase`.
    ([Pull Request](https://github.com/rails/rails/pull/34717))

*   Generar un `ArgumentError` cuando existen múltiples rutas raíz en el mismo contexto
    sin especificaciones de nombre `as:`.
    ([Pull Request](https://github.com/rails/rails/pull/34494))

*   Permitir el uso de `#rescue_from` para manejar errores de análisis de parámetros.
    ([Pull Request](https://github.com/rails/rails/pull/34341))

*   Agregar `ActionController::Parameters#each_value` para iterar a través de los parámetros.
    ([Pull Request](https://github.com/rails/rails/pull/33979))

*   Codificar los nombres de archivo de Content-Disposition en `send_data` y `send_file`.
    ([Pull Request](https://github.com/rails/rails/pull/33829))

*   Exponer `ActionController::Parameters#each_key`.
    ([Pull Request](https://github.com/rails/rails/pull/33758))

*   Agregar metadatos de propósito y vencimiento dentro de las cookies firmadas/encriptadas para evitar copiar el valor de
    las cookies entre sí.
    ([Pull Request](https://github.com/rails/rails/pull/32937))

*   Generar `ActionController::RespondToMismatchError` para invocaciones conflictivas de `respond_to`.
    ([Pull Request](https://github.com/rails/rails/pull/33446))

*   Agregar una página de error explícita cuando falta una plantilla para un formato de solicitud.
    ([Pull Request](https://github.com/rails/rails/pull/29286))

*   Introducir `ActionDispatch::DebugExceptions.register_interceptor`, una forma de conectarse a
    DebugExceptions y procesar la excepción antes de ser renderizada.
    ([Pull Request](https://github.com/rails/rails/pull/23868))

*   Mostrar solo un valor de encabezado de nonce de Content-Security-Policy por solicitud.
    ([Pull Request](https://github.com/rails/rails/pull/32602))

*   Agregar un módulo específicamente para la configuración predeterminada de encabezados de Rails
    que se puede incluir explícitamente en los controladores.
    ([Pull Request](https://github.com/rails/rails/pull/32484))
*   Agregar `#dig` a `ActionDispatch::Request::Session`.
    ([Pull Request](https://github.com/rails/rails/pull/32446))

Action View
-----------

Consulte el [registro de cambios][action-view] para obtener cambios detallados.

### Eliminaciones

*   Eliminar el ayudante `image_alt` obsoleto.
    ([Commit](https://github.com/rails/rails/commit/60c8a03c8d1e45e48fcb1055ba4c49ed3d5ff78f))

*   Eliminar un módulo vacío `RecordTagHelper` del cual la funcionalidad
    ya se ha movido a la gema `record_tag_helper`.
    ([Commit](https://github.com/rails/rails/commit/5c5ddd69b1e06fb6b2bcbb021e9b8dae17e7cb31))

### Obsolescencias

*   Obsoleto `ActionView::Template.finalize_compiled_template_methods` sin
    reemplazo.
    ([Pull Request](https://github.com/rails/rails/pull/35036))

*   Obsoleto `config.action_view.finalize_compiled_template_methods` sin
    reemplazo.
    ([Pull Request](https://github.com/rails/rails/pull/35036))

*   Obsoleto llamar a métodos de modelo privados desde el ayudante de vista `options_from_collection_for_select`.
    ([Pull Request](https://github.com/rails/rails/pull/33547))

### Cambios destacados

*   Limpiar la caché de Action View solo en desarrollo cuando hay cambios en los archivos, acelerando
    el modo de desarrollo.
    ([Pull Request](https://github.com/rails/rails/pull/35629))

*   Mover todos los paquetes npm de Rails a un alcance `@rails`.
    ([Pull Request](https://github.com/rails/rails/pull/34905))

*   Aceptar solo formatos de tipos MIME registrados.
    ([Pull Request](https://github.com/rails/rails/pull/35604), [Pull Request](https://github.com/rails/rails/pull/35753))

*   Agregar asignaciones a la plantilla y renderizado parcial en la salida del servidor.
    ([Pull Request](https://github.com/rails/rails/pull/34136))

*   Agregar una opción `year_format` a la etiqueta `date_select`, lo que permite
    personalizar los nombres de los años.
    ([Pull Request](https://github.com/rails/rails/pull/32190))

*   Agregar una opción `nonce: true` para el ayudante `javascript_include_tag` para
    admitir la generación automática de nonce para una Política de Seguridad de Contenido.
    ([Pull Request](https://github.com/rails/rails/pull/32607))

*   Agregar una configuración `action_view.finalize_compiled_template_methods` para deshabilitar o
    habilitar los finalizadores de `ActionView::Template`.
    ([Pull Request](https://github.com/rails/rails/pull/32418))

*   Extraer la llamada JavaScript `confirm` a su propio método sobrescribible en `rails_ujs`.
    ([Pull Request](https://github.com/rails/rails/pull/32404))

*   Agregar una opción de configuración `action_controller.default_enforce_utf8` para manejar
    la codificación UTF-8. Esto es `false` por defecto.
    ([Pull Request](https://github.com/rails/rails/pull/32125))

*   Agregar soporte para el estilo de clave I18n en las etiquetas de envío de locales.
    ([Pull Request](https://github.com/rails/rails/pull/26799))

Action Mailer
-------------

Consulte el [registro de cambios][action-mailer] para obtener cambios detallados.

### Eliminaciones

### Obsolescencias

*   Obsoleto `ActionMailer::Base.receive` a favor de Action Mailbox.
    ([Commit](https://github.com/rails/rails/commit/e3f832a7433a291a51c5df397dc3dd654c1858cb))

*   Obsoleto `DeliveryJob` y `Parameterized::DeliveryJob` a favor de
    `MailDeliveryJob`.
    ([Pull Request](https://github.com/rails/rails/pull/34591))

### Cambios destacados

*   Agregar `MailDeliveryJob` para enviar correos regulares y parametrizados.
    ([Pull Request](https://github.com/rails/rails/pull/34591))

*   Permitir que los trabajos de entrega de correo personalizados funcionen con las afirmaciones de prueba de Action Mailer.
    ([Pull Request](https://github.com/rails/rails/pull/34339))

*   Permitir especificar un nombre de plantilla para correos multipartes con bloques en lugar de
    solo usar el nombre de la acción.
    ([Pull Request](https://github.com/rails/rails/pull/22534))

*   Agregar `perform_deliveries` a la carga útil de la notificación `deliver.action_mailer`.
    ([Pull Request](https://github.com/rails/rails/pull/33824))

*   Mejorar el mensaje de registro cuando `perform_deliveries` es falso para indicar
    que se omitió el envío de correos electrónicos.
    ([Pull Request](https://github.com/rails/rails/pull/33824))

*   Permitir llamar a `assert_enqueued_email_with` sin bloque.
    ([Pull Request](https://github.com/rails/rails/pull/33258))

*   Realizar los trabajos de entrega de correo en cola en el bloque `assert_emails`.
    ([Pull Request](https://github.com/rails/rails/pull/32231))

*   Permitir que `ActionMailer::Base` anule los observadores e interceptores.
    ([Pull Request](https://github.com/rails/rails/pull/32207))

Active Record
-------------

Consulte el [registro de cambios][active-record] para obtener cambios detallados.

### Eliminaciones

*   Eliminar `#set_state` obsoleto del objeto de transacción.
    ([Commit](https://github.com/rails/rails/commit/6c745b0c5152a4437163a67707e02f4464493983))

*   Eliminar `#supports_statement_cache?` obsoleto de los adaptadores de base de datos.
    ([Commit](https://github.com/rails/rails/commit/5f3ed8784383fb4eb0f9959f31a9c28a991b7553))

*   Eliminar `#insert_fixtures` obsoleto de los adaptadores de base de datos.
    ([Commit](https://github.com/rails/rails/commit/400ba786e1d154448235f5f90183e48a1043eece))

*   Eliminar `ActiveRecord::ConnectionAdapters::SQLite3Adapter#valid_alter_table_type?` obsoleto.
    ([Commit](https://github.com/rails/rails/commit/45b4d5f81f0c0ca72c18d0dea4a3a7b2ecc589bf))

*   Eliminar el soporte para pasar el nombre de la columna a `sum` cuando se pasa un bloque.
    ([Commit](https://github.com/rails/rails/commit/91ddb30083430622188d76eb9f29b78131df67f9))

*   Eliminar el soporte para pasar el nombre de la columna a `count` cuando se pasa un bloque.
    ([Commit](https://github.com/rails/rails/commit/67356f2034ab41305af7218f7c8b2fee2d614129))

*   Eliminar el soporte para la delegación de métodos faltantes en una relación a Arel.
    ([Commit](https://github.com/rails/rails/commit/d97980a16d76ad190042b4d8578109714e9c53d0))

*   Eliminar el soporte para la delegación de métodos faltantes en una relación a métodos privados de la clase.
    ([Commit](https://github.com/rails/rails/commit/a7becf147afc85c354e5cfa519911a948d25fc4d))

*   Eliminar el soporte para especificar un nombre de marca de tiempo para `#cache_key`.
    ([Commit](https://github.com/rails/rails/commit/0bef23e630f62e38f20b5ae1d1d5dbfb087050ea))

*   Eliminar `ActiveRecord::Migrator.migrations_path=`.
    ([Commit](https://github.com/rails/rails/commit/90d7842186591cae364fab3320b524e4d31a7d7d))
*   Eliminar `expand_hash_conditions_for_aggregates` obsoleto.
    ([Commit](https://github.com/rails/rails/commit/27b252d6a85e300c7236d034d55ec8e44f57a83e))


### Obsolescencias

*   Obsoleto el uso de comparaciones de colación de sensibilidad de mayúsculas y minúsculas para el validador de unicidad.
    ([Commit](https://github.com/rails/rails/commit/9def05385f1cfa41924bb93daa187615e88c95b9))

*   Obsoleto el uso de métodos de consulta a nivel de clase si el alcance del receptor se ha filtrado.
    ([Pull Request](https://github.com/rails/rails/pull/35280))

*   Obsoleto `config.active_record.sqlite3.represent_boolean_as_integer`.
    ([Commit](https://github.com/rails/rails/commit/f59b08119bc0c01a00561d38279b124abc82561b))

*   Obsoleto pasar `migrations_paths` a `connection.assume_migrated_upto_version`.
    ([Commit](https://github.com/rails/rails/commit/c1b14aded27e063ead32fa911aa53163d7cfc21a))

*   Obsoleto `ActiveRecord::Result#to_hash` en favor de `ActiveRecord::Result#to_a`.
    ([Commit](https://github.com/rails/rails/commit/16510d609c601aa7d466809f3073ec3313e08937))

*   Obsoletos los métodos en `DatabaseLimits`: `column_name_length`, `table_name_length`,
    `columns_per_table`, `indexes_per_table`, `columns_per_multicolumn_index`,
    `sql_query_length` y `joins_per_query`.
    ([Commit](https://github.com/rails/rails/commit/e0a1235f7df0fa193c7e299a5adee88db246b44f))

*   Obsoleto `update_attributes`/`!` en favor de `update`/`!`.
    ([Commit](https://github.com/rails/rails/commit/5645149d3a27054450bd1130ff5715504638a5f5))

### Cambios destacados

*   Aumentar la versión mínima de la gema `sqlite3` a 1.4.
    ([Pull Request](https://github.com/rails/rails/pull/35844))

*   Agregar `rails db:prepare` para crear una base de datos si no existe y ejecutar sus migraciones.
    ([Pull Request](https://github.com/rails/rails/pull/35768))

*   Agregar el callback `after_save_commit` como atajo para `after_commit :hook, on: [ :create, :update ]`.
    ([Pull Request](https://github.com/rails/rails/pull/35804))

*   Agregar `ActiveRecord::Relation#extract_associated` para extraer registros asociados de una relación.
    ([Pull Request](https://github.com/rails/rails/pull/35784))

*   Agregar `ActiveRecord::Relation#annotate` para agregar comentarios SQL a las consultas de ActiveRecord::Relation.
    ([Pull Request](https://github.com/rails/rails/pull/35617))

*   Agregar soporte para establecer Optimizer Hints en bases de datos.
    ([Pull Request](https://github.com/rails/rails/pull/35615))

*   Agregar métodos `insert_all`/`insert_all!`/`upsert_all` para realizar inserciones masivas.
    ([Pull Request](https://github.com/rails/rails/pull/35631))

*   Agregar `rails db:seed:replant` que trunca las tablas de cada base de datos
    para el entorno actual y carga las semillas.
    ([Pull Request](https://github.com/rails/rails/pull/34779))

*   Agregar `reselect` como método abreviado para `unscope(:select).select(fields)`.
    ([Pull Request](https://github.com/rails/rails/pull/33611))

*   Agregar ámbitos negativos para todos los valores de enumeración.
    ([Pull Request](https://github.com/rails/rails/pull/35381))

*   Agregar `#destroy_by` y `#delete_by` para eliminaciones condicionales.
    ([Pull Request](https://github.com/rails/rails/pull/35316))

*   Agregar la capacidad de cambiar automáticamente las conexiones de la base de datos.
    ([Pull Request](https://github.com/rails/rails/pull/35073))

*   Agregar la capacidad de evitar escrituras en una base de datos durante la duración de un bloque.
    ([Pull Request](https://github.com/rails/rails/pull/34505))

*   Agregar una API para cambiar conexiones y admitir múltiples bases de datos.
    ([Pull Request](https://github.com/rails/rails/pull/34052))

*   Hacer que las marcas de tiempo con precisión sean la opción predeterminada para las migraciones.
    ([Pull Request](https://github.com/rails/rails/pull/34970))

*   Admitir la opción `:size` para cambiar el tamaño de texto y blob en MySQL.
    ([Pull Request](https://github.com/rails/rails/pull/35071))

*   Establecer tanto la clave externa como las columnas de tipo externo en NULL para
    asociaciones polimórficas con estrategia `dependent: :nullify`.
    ([Pull Request](https://github.com/rails/rails/pull/28078))

*   Permitir que una instancia permitida de `ActionController::Parameters` se pase como argumento a `ActiveRecord::Relation#exists?`.
    ([Pull Request](https://github.com/rails/rails/pull/34891))

*   Agregar soporte en `#where` para rangos infinitos introducidos en Ruby 2.6.
    ([Pull Request](https://github.com/rails/rails/pull/34906))

*   Hacer que `ROW_FORMAT=DYNAMIC` sea una opción de creación de tabla predeterminada para MySQL.
    ([Pull Request](https://github.com/rails/rails/pull/34742))

*   Agregar la capacidad de desactivar los ámbitos generados por `ActiveRecord.enum`.
    ([Pull Request](https://github.com/rails/rails/pull/34605))

*   Hacer que el orden implícito sea configurable para una columna.
    ([Pull Request](https://github.com/rails/rails/pull/34480))

*   Aumentar la versión mínima de PostgreSQL a 9.3, eliminando el soporte para 9.1 y 9.2.
    ([Pull Request](https://github.com/rails/rails/pull/34520))

*   Hacer que los valores de una enumeración sean congelados, generando un error al intentar modificarlos.
    ([Pull Request](https://github.com/rails/rails/pull/34517))

*   Hacer que el SQL de los errores `ActiveRecord::StatementInvalid` sea su propia propiedad de error
    e incluir los enlaces SQL como una propiedad de error separada.
    ([Pull Request](https://github.com/rails/rails/pull/34468))

*   Agregar una opción `:if_not_exists` a `create_table`.
    ([Pull Request](https://github.com/rails/rails/pull/31382))

*   Agregar soporte para múltiples bases de datos a `rails db:schema:cache:dump`
    y `rails db:schema:cache:clear`.
    ([Pull Request](https://github.com/rails/rails/pull/34181))

*   Agregar soporte para configuraciones de hash y URL en el hash de base de datos de `ActiveRecord::Base.connected_to`.
    ([Pull Request](https://github.com/rails/rails/pull/34196))

*   Agregar soporte para expresiones predeterminadas e índices de expresiones para MySQL.
    ([Pull Request](https://github.com/rails/rails/pull/34307))

*   Agregar una opción `index` para los ayudantes de migración `change_table`.
    ([Pull Request](https://github.com/rails/rails/pull/23593))

*   Corregir la reversión de `transaction` para migraciones. Anteriormente, los comandos dentro de una `transaction`
    en una migración revertida se ejecutaban sin invertir. Este cambio soluciona eso.
    ([Pull Request](https://github.com/rails/rails/pull/31604))
*   Permitir que `ActiveRecord::Base.configurations=` se establezca con un hash simbolizado.
    ([Pull Request](https://github.com/rails/rails/pull/33968))

*   Corregir la actualización de la caché del contador solo si el registro se guarda realmente.
    ([Pull Request](https://github.com/rails/rails/pull/33913))

*   Agregar soporte de índices de expresión para el adaptador SQLite.
    ([Pull Request](https://github.com/rails/rails/pull/33874))

*   Permitir que las subclases redefinan los callbacks de autosave para los registros asociados.
    ([Pull Request](https://github.com/rails/rails/pull/33378))

*   Aumentar la versión mínima de MySQL a 5.5.8.
    ([Pull Request](https://github.com/rails/rails/pull/33853))

*   Usar el conjunto de caracteres utf8mb4 de forma predeterminada en MySQL.
    ([Pull Request](https://github.com/rails/rails/pull/33608))

*   Agregar la capacidad de filtrar datos sensibles en `#inspect`.
    ([Pull Request](https://github.com/rails/rails/pull/33756), [Pull Request](https://github.com/rails/rails/pull/34208))

*   Cambiar `ActiveRecord::Base.configurations` para devolver un objeto en lugar de un hash.
    ([Pull Request](https://github.com/rails/rails/pull/33637))

*   Agregar configuración de base de datos para deshabilitar bloqueos de asesoramiento.
    ([Pull Request](https://github.com/rails/rails/pull/33691))

*   Actualizar el método `alter_table` del adaptador SQLite3 para restaurar las claves externas.
    ([Pull Request](https://github.com/rails/rails/pull/33585))

*   Permitir que la opción `:to_table` de `remove_foreign_key` sea invertible.
    ([Pull Request](https://github.com/rails/rails/pull/33530))

*   Corregir el valor predeterminado para los tipos de tiempo de MySQL con precisión especificada.
    ([Pull Request](https://github.com/rails/rails/pull/33280))

*   Corregir la opción `touch` para comportarse de manera consistente con el método `Persistence#touch`.
    ([Pull Request](https://github.com/rails/rails/pull/33107))

*   Generar una excepción para definiciones de columna duplicadas en Migrations.
    ([Pull Request](https://github.com/rails/rails/pull/33029))

*   Aumentar la versión mínima de SQLite a 3.8.
    ([Pull Request](https://github.com/rails/rails/pull/32923))

*   Corregir que los registros principales no se guarden con registros secundarios duplicados.
    ([Pull Request](https://github.com/rails/rails/pull/32952))

*   Asegurar que `Associations::CollectionAssociation#size` y `Associations::CollectionAssociation#empty?`
    usen los ids de asociación cargados si están presentes.
    ([Pull Request](https://github.com/rails/rails/pull/32617))

*   Agregar soporte para precargar asociaciones de asociaciones polimórficas cuando no todos los registros tienen las asociaciones solicitadas.
    ([Commit](https://github.com/rails/rails/commit/75ef18c67c29b1b51314b6c8a963cee53394080b))

*   Agregar el método `touch_all` a `ActiveRecord::Relation`.
    ([Pull Request](https://github.com/rails/rails/pull/31513))

*   Agregar el predicado `ActiveRecord::Base.base_class?`.
    ([Pull Request](https://github.com/rails/rails/pull/32417))

*   Agregar opciones de prefijo/sufijo personalizadas a `ActiveRecord::Store.store_accessor`.
    ([Pull Request](https://github.com/rails/rails/pull/32306))

*   Agregar `ActiveRecord::Base.create_or_find_by`/`!` para manejar la condición de carrera SELECT/INSERT en
    `ActiveRecord::Base.find_or_create_by`/`!` aprovechando las restricciones únicas en la base de datos.
    ([Pull Request](https://github.com/rails/rails/pull/31989))

*   Agregar `Relation#pick` como atajo para obtener un solo valor.
    ([Pull Request](https://github.com/rails/rails/pull/31941))

Active Storage
--------------

Consulte el [Changelog][active-storage] para obtener cambios detallados.

### Eliminaciones

### Deprecaciones

*   Deprecar `config.active_storage.queue` a favor de `config.active_storage.queues.analysis`
    y `config.active_storage.queues.purge`.
    ([Pull Request](https://github.com/rails/rails/pull/34838))

*   Deprecar `ActiveStorage::Downloading` a favor de `ActiveStorage::Blob#open`.
    ([Commit](https://github.com/rails/rails/commit/ee21b7c2eb64def8f00887a9fafbd77b85f464f1))

*   Deprecar el uso de `mini_magick` directamente para generar variantes de imágenes a favor de
    `image_processing`.
    ([Commit](https://github.com/rails/rails/commit/697f4a93ad386f9fb7795f0ba68f815f16ebad0f))

*   Deprecar `:combine_options` en el transformador de ImageProcessing de Active Storage
    sin reemplazo.
    ([Commit](https://github.com/rails/rails/commit/697f4a93ad386f9fb7795f0ba68f815f16ebad0f))

### Cambios destacados

*   Agregar soporte para generar variantes de imágenes BMP.
    ([Pull Request](https://github.com/rails/rails/pull/36051))

*   Agregar soporte para generar variantes de imágenes TIFF.
    ([Pull Request](https://github.com/rails/rails/pull/34824))

*   Agregar soporte para generar variantes de imágenes JPEG progresivas.
    ([Pull Request](https://github.com/rails/rails/pull/34455))

*   Agregar `ActiveStorage.routes_prefix` para configurar las rutas generadas por Active Storage.
    ([Pull Request](https://github.com/rails/rails/pull/33883))

*   Generar una respuesta 404 Not Found en `ActiveStorage::DiskController#show` cuando
    el archivo solicitado falta en el servicio de disco.
    ([Pull Request](https://github.com/rails/rails/pull/33666))

*   Lanzar `ActiveStorage::FileNotFoundError` cuando falta el archivo solicitado para
    `ActiveStorage::Blob#download` y `ActiveStorage::Blob#open`.
    ([Pull Request](https://github.com/rails/rails/pull/33666))

*   Agregar una clase genérica `ActiveStorage::Error` de la cual heredan las excepciones de Active Storage.
    ([Commit](https://github.com/rails/rails/commit/18425b837149bc0d50f8d5349e1091a623762d6b))

*   Persistir los archivos cargados asignados a un registro en el almacenamiento cuando el registro
    se guarda en lugar de hacerlo inmediatamente.
    ([Pull Request](https://github.com/rails/rails/pull/33303))

*   Opcionalmente reemplazar archivos existentes en lugar de agregar nuevos al asignar a
    una colección de adjuntos (como en `@user.update!(images: [ … ])`). Usar
    `config.active_storage.replace_on_assign_to_many` para controlar este comportamiento.
    ([Pull Request](https://github.com/rails/rails/pull/33303),
     [Pull Request](https://github.com/rails/rails/pull/36716))

*   Agregar la capacidad de reflejar los adjuntos definidos utilizando el mecanismo de reflexión existente de Active Record.
    ([Pull Request](https://github.com/rails/rails/pull/33018))
*   Agregar `ActiveStorage::Blob#open`, que descarga un blob a un tempfile en disco
    y devuelve el tempfile.
    ([Commit](https://github.com/rails/rails/commit/ee21b7c2eb64def8f00887a9fafbd77b85f464f1))

*   Soporte para descargas en streaming desde Google Cloud Storage. Requiere la versión 1.11+
    de la gema `google-cloud-storage`.
    ([Pull Request](https://github.com/rails/rails/pull/32788))

*   Usar la gema `image_processing` para las variantes de Active Storage. Esto reemplaza el uso
    de `mini_magick` directamente.
    ([Pull Request](https://github.com/rails/rails/pull/32471))

Active Model
------------

Consulte el [Changelog][active-model] para obtener cambios detallados.

### Eliminaciones

### Deprecaciones

### Cambios destacados

*   Agregar una opción de configuración para personalizar el formato de `ActiveModel::Errors#full_message`.
    ([Pull Request](https://github.com/rails/rails/pull/32956))

*   Agregar soporte para configurar el nombre del atributo para `has_secure_password`.
    ([Pull Request](https://github.com/rails/rails/pull/26764))

*   Agregar el método `#slice!` a `ActiveModel::Errors`.
    ([Pull Request](https://github.com/rails/rails/pull/34489))

*   Agregar `ActiveModel::Errors#of_kind?` para verificar la presencia de un error específico.
    ([Pull Request](https://github.com/rails/rails/pull/34866))

*   Corregir el método `ActiveModel::Serializers::JSON#as_json` para los timestamps.
    ([Pull Request](https://github.com/rails/rails/pull/31503))

*   Corregir el validador de numericality para seguir utilizando el valor antes de la conversión de tipo, excepto en Active Record.
    ([Pull Request](https://github.com/rails/rails/pull/33654))

*   Corregir la validación de igualdad de numericality de `BigDecimal` y `Float`
    al convertir a `BigDecimal` en ambos extremos de la validación.
    ([Pull Request](https://github.com/rails/rails/pull/32852))

*   Corregir el valor del año al convertir un hash de tiempo multiparamétrico.
    ([Pull Request](https://github.com/rails/rails/pull/34990))

*   Convertir los símbolos booleanos falsos en un atributo booleano como falso.
    ([Pull Request](https://github.com/rails/rails/pull/35794))

*   Devolver la fecha correcta al convertir parámetros en `value_from_multiparameter_assignment`
    para `ActiveModel::Type::Date`.
    ([Pull Request](https://github.com/rails/rails/pull/29651))

*   Retroceder al idioma principal antes de retroceder al espacio de nombres `:errors` al buscar
    las traducciones de errores.
    ([Pull Request](https://github.com/rails/rails/pull/35424))

Active Support
--------------

Consulte el [Changelog][active-support] para obtener cambios detallados.

### Eliminaciones

*   Eliminar el método deprecado `#acronym_regex` de `Inflections`.
    ([Commit](https://github.com/rails/rails/commit/0ce67d3cd6d1b7b9576b07fecae3dd5b422a5689))

*   Eliminar el método deprecado `Module#reachable?`.
    ([Commit](https://github.com/rails/rails/commit/6eb1d56a333fd2015610d31793ed6281acd66551))

*   Eliminar `` Kernel#` `` sin reemplazo.
    ([Pull Request](https://github.com/rails/rails/pull/31253))

### Deprecaciones

*   Deprecar el uso de argumentos enteros negativos para `String#first` y
    `String#last`.
    ([Pull Request](https://github.com/rails/rails/pull/33058))

*   Deprecar `ActiveSupport::Multibyte::Unicode#downcase/upcase/swapcase`
    en favor de `String#downcase/upcase/swapcase`.
    ([Pull Request](https://github.com/rails/rails/pull/34123))

*   Deprecar `ActiveSupport::Multibyte::Unicode#normalize`
    y `ActiveSupport::Multibyte::Chars#normalize` en favor de
    `String#unicode_normalize`.
    ([Pull Request](https://github.com/rails/rails/pull/34202))

*   Deprecar `ActiveSupport::Multibyte::Chars.consumes?` en favor de
    `String#is_utf8?`.
    ([Pull Request](https://github.com/rails/rails/pull/34215))

*   Deprecar `ActiveSupport::Multibyte::Unicode#pack_graphemes(array)`
    y `ActiveSupport::Multibyte::Unicode#unpack_graphemes(string)`
    en favor de `array.flatten.pack("U*")` y `string.scan(/\X/).map(&:codepoints)`,
    respectivamente.
    ([Pull Request](https://github.com/rails/rails/pull/34254))

### Cambios destacados

*   Agregar soporte para pruebas en paralelo.
    ([Pull Request](https://github.com/rails/rails/pull/31900))

*   Asegurarse de que `String#strip_heredoc` preserve la congelación de las cadenas.
    ([Pull Request](https://github.com/rails/rails/pull/32037))

*   Agregar `String#truncate_bytes` para truncar una cadena a un tamaño máximo en bytes
    sin romper caracteres multibyte o grupos de grafemas.
    ([Pull Request](https://github.com/rails/rails/pull/27319))

*   Agregar la opción `private` al método `delegate` para delegar a
    métodos privados. Esta opción acepta `true/false` como valor.
    ([Pull Request](https://github.com/rails/rails/pull/31944))

*   Agregar soporte para traducciones a través de I18n para `ActiveSupport::Inflector#ordinal`
    y `ActiveSupport::Inflector#ordinalize`.
    ([Pull Request](https://github.com/rails/rails/pull/32168))

*   Agregar los métodos `before?` y `after?` a `Date`, `DateTime`,
    `Time` y `TimeWithZone`.
    ([Pull Request](https://github.com/rails/rails/pull/32185))

*   Corregir el error donde `URI.unescape` fallaría con una entrada de caracteres mixtos Unicode/escapados.
    ([Pull Request](https://github.com/rails/rails/pull/32183))

*   Corregir el error donde `ActiveSupport::Cache` inflaría masivamente el tamaño de almacenamiento
    cuando la compresión estaba habilitada.
    ([Pull Request](https://github.com/rails/rails/pull/32539))

*   Almacenamiento en caché de Redis: `delete_matched` ya no bloquea el servidor de Redis.
    ([Pull Request](https://github.com/rails/rails/pull/32614))

*   Corregir el error donde `ActiveSupport::TimeZone.all` fallaría cuando faltara datos de tzinfo para
    cualquier zona horaria definida en `ActiveSupport::TimeZone::MAPPING`.
    ([Pull Request](https://github.com/rails/rails/pull/32613))

*   Agregar `Enumerable#index_with`, que permite crear un hash a partir de un enumerable
    con el valor de un bloque pasado o un argumento predeterminado.
    ([Pull Request](https://github.com/rails/rails/pull/32523))

*   Permitir que los métodos `Range#===` y `Range#cover?` funcionen con un argumento de tipo `Range`.
    ([Pull Request](https://github.com/rails/rails/pull/32938))
*   Soporte para la expiración de claves en las operaciones `increment/decrement` de RedisCacheStore.
    ([Pull Request](https://github.com/rails/rails/pull/33254))

*   Agregar características de tiempo de CPU, tiempo de inactividad y asignaciones a los eventos del suscriptor de registro.
    ([Pull Request](https://github.com/rails/rails/pull/33449))

*   Agregar soporte para objetos de evento al sistema de notificación de Active Support.
    ([Pull Request](https://github.com/rails/rails/pull/33451))

*   Agregar soporte para no almacenar en caché entradas `nil` mediante la introducción de la nueva opción `skip_nil` para `ActiveSupport::Cache#fetch`.
    ([Pull Request](https://github.com/rails/rails/pull/25437))

*   Agregar el método `Array#extract!` que elimina y devuelve los elementos para los cuales el bloque devuelve un valor verdadero.
    ([Pull Request](https://github.com/rails/rails/pull/33137))

*   Mantener una cadena segura para HTML después de cortarla.
    ([Pull Request](https://github.com/rails/rails/pull/33808))

*   Agregar soporte para rastrear la carga automática constante a través del registro.
    ([Commit](https://github.com/rails/rails/commit/c03bba4f1f03bad7dc034af555b7f2b329cf76f5))

*   Definir `unfreeze_time` como un alias de `travel_back`.
    ([Pull Request](https://github.com/rails/rails/pull/33813))

*   Cambiar `ActiveSupport::TaggedLogging.new` para devolver una nueva instancia de registro en lugar de modificar la recibida como argumento.
    ([Pull Request](https://github.com/rails/rails/pull/27792))

*   Tratar los métodos `#delete_prefix`, `#delete_suffix` y `#unicode_normalize` como métodos no seguros para HTML.
    ([Pull Request](https://github.com/rails/rails/pull/33990))

*   Corregir el error donde `#without` para `ActiveSupport::HashWithIndifferentAccess` fallaría con argumentos de símbolo.
    ([Pull Request](https://github.com/rails/rails/pull/34012))

*   Renombrar `Module#parent`, `Module#parents` y `Module#parent_name` a `module_parent`, `module_parents` y `module_parent_name`.
    ([Pull Request](https://github.com/rails/rails/pull/34051))

*   Agregar `ActiveSupport::ParameterFilter`.
    ([Pull Request](https://github.com/rails/rails/pull/34039))

*   Corregir el problema donde la duración se redondeaba a un segundo completo cuando se agregaba un número decimal a la duración.
    ([Pull Request](https://github.com/rails/rails/pull/34135))

*   Hacer que `#to_options` sea un alias de `#symbolize_keys` en `ActiveSupport::HashWithIndifferentAccess`.
    ([Pull Request](https://github.com/rails/rails/pull/34360))

*   Ya no generar una excepción si el mismo bloque se incluye varias veces en un Concern.
    ([Pull Request](https://github.com/rails/rails/pull/34553))

*   Preservar el orden de las claves pasadas a `ActiveSupport::CacheStore#fetch_multi`.
    ([Pull Request](https://github.com/rails/rails/pull/34700))

*   Corregir `String#safe_constantize` para que no lance un `LoadError` para referencias constantes escritas incorrectamente.
    ([Pull Request](https://github.com/rails/rails/pull/34892))

*   Agregar `Hash#deep_transform_values` y `Hash#deep_transform_values!`.
    ([Commit](https://github.com/rails/rails/commit/b8dc06b8fdc16874160f61dcf58743fcc10e57db))

*   Agregar `ActiveSupport::HashWithIndifferentAccess#assoc`.
    ([Pull Request](https://github.com/rails/rails/pull/35080))

*   Agregar el callback `before_reset` a `CurrentAttributes` y definir `after_reset` como un alias de `resets` para mayor simetría.
    ([Pull Request](https://github.com/rails/rails/pull/35063))

*   Revisar `ActiveSupport::Notifications.unsubscribe` para manejar correctamente suscriptores de expresiones regulares u otros patrones múltiples.
    ([Pull Request](https://github.com/rails/rails/pull/32861))

*   Agregar un nuevo mecanismo de carga automática utilizando Zeitwerk.
    ([Commit](https://github.com/rails/rails/commit/e53430fa9af239e21e11548499d814f540d421e5))

*   Agregar `Array#including` y `Enumerable#including` para ampliar convenientemente una colección.
    ([Commit](https://github.com/rails/rails/commit/bfaa3091c3c32b5980a614ef0f7b39cbf83f6db3))

*   Renombrar `Array#without` y `Enumerable#without` a `Array#excluding` y `Enumerable#excluding`. Los nombres antiguos de los métodos se mantienen como alias.
    ([Commit](https://github.com/rails/rails/commit/bfaa3091c3c32b5980a614ef0f7b39cbf83f6db3))

*   Agregar soporte para suministrar `locale` a `transliterate` y `parameterize`.
    ([Pull Request](https://github.com/rails/rails/pull/35571))

*   Corregir `Time#advance` para que funcione con fechas anteriores a 1001-03-07.
    ([Pull Request](https://github.com/rails/rails/pull/35659))

*   Actualizar `ActiveSupport::Notifications::Instrumenter#instrument` para permitir no pasar un bloque.
    ([Pull Request](https://github.com/rails/rails/pull/35705))

*   Usar referencias débiles en el rastreador de descendientes para permitir que las subclases anónimas sean recolectadas por el recolector de basura.
    ([Pull Request](https://github.com/rails/rails/pull/31442))

*   Llamar a los métodos de prueba con el método `with_info_handler` para permitir que el complemento minitest-hooks funcione.
    ([Commit](https://github.com/rails/rails/commit/758ba117a008b6ea2d3b92c53b6a7a8d7ccbca69))

*   Preservar el estado de `html_safe?` en `ActiveSupport::SafeBuffer#*`.
    ([Pull Request](https://github.com/rails/rails/pull/36012))

Active Job
----------

Consulte el [registro de cambios][active-job] para obtener cambios detallados.

### Eliminaciones

*   Eliminar el soporte para la gema Qu.
    ([Pull Request](https://github.com/rails/rails/pull/32300))

### Deprecaciones

### Cambios destacados

*   Agregar soporte para serializadores personalizados para los argumentos de Active Job.
    ([Pull Request](https://github.com/rails/rails/pull/30941))

*   Agregar soporte para ejecutar trabajos activos en la zona horaria en la que se encolaron.
    ([Pull Request](https://github.com/rails/rails/pull/32085))

*   Permitir pasar múltiples excepciones a `retry_on`/`discard_on`.
    ([Commit](https://github.com/rails/rails/commit/3110caecbebdad7300daaf26bfdff39efda99e25))

*   Permitir llamar a `assert_enqueued_with` y `assert_enqueued_email_with` sin un bloque.
    ([Pull Request](https://github.com/rails/rails/pull/33258))

*   Envolver las notificaciones de `enqueue` y `enqueue_at` en el callback `around_enqueue` en lugar del callback `after_enqueue`.
    ([Pull Request](https://github.com/rails/rails/pull/33171))

*   Permitir llamar a `perform_enqueued_jobs` sin un bloque.
    ([Pull Request](https://github.com/rails/rails/pull/33626))

*   Permitir llamar a `assert_performed_with` sin un bloque.
    ([Pull Request](https://github.com/rails/rails/pull/33635))

[active-job]: https://github.com/rails/rails/blob/master/activejob/CHANGELOG.md
*   Agregar la opción `:queue` a las aserciones y ayudantes de trabajos.
    ([Pull Request](https://github.com/rails/rails/pull/33635))

*   Agregar ganchos a Active Job alrededor de reintentos y descartes.
    ([Pull Request](https://github.com/rails/rails/pull/33751))

*   Agregar una forma de probar un subconjunto de argumentos al realizar trabajos.
    ([Pull Request](https://github.com/rails/rails/pull/33995))

*   Incluir argumentos deserializados en los trabajos devueltos por los ayudantes de prueba de Active Job.
    ([Pull Request](https://github.com/rails/rails/pull/34204))

*   Permitir que los ayudantes de aserción de Active Job acepten un Proc para la palabra clave `only`.
    ([Pull Request](https://github.com/rails/rails/pull/34339))

*   Eliminar microsegundos y nanosegundos de los argumentos del trabajo en los ayudantes de aserción.
    ([Pull Request](https://github.com/rails/rails/pull/35713))

Guías de Ruby on Rails
--------------------

Consulte el [Registro de cambios][guides] para obtener cambios detallados.

### Cambios destacados

*   Agregar guía de Múltiples bases de datos con Active Record.
    ([Pull Request](https://github.com/rails/rails/pull/36389))

*   Agregar una sección sobre solución de problemas de carga automática de constantes.
    ([Commit](https://github.com/rails/rails/commit/c03bba4f1f03bad7dc034af555b7f2b329cf76f5))

*   Agregar guía básica de Action Mailbox.
    ([Pull Request](https://github.com/rails/rails/pull/34812))

*   Agregar descripción general de Action Text.
    ([Pull Request](https://github.com/rails/rails/pull/34878))

Créditos
-------

Consulte la [lista completa de colaboradores de Rails](https://contributors.rubyonrails.org/)
para ver a las muchas personas que pasaron muchas horas haciendo de Rails el marco estable y robusto que es. Felicitaciones a todos ellos.

[railties]:       https://github.com/rails/rails/blob/6-0-stable/railties/CHANGELOG.md
[action-pack]:    https://github.com/rails/rails/blob/6-0-stable/actionpack/CHANGELOG.md
[action-view]:    https://github.com/rails/rails/blob/6-0-stable/actionview/CHANGELOG.md
[action-mailer]:  https://github.com/rails/rails/blob/6-0-stable/actionmailer/CHANGELOG.md
[action-cable]:   https://github.com/rails/rails/blob/6-0-stable/actioncable/CHANGELOG.md
[active-record]:  https://github.com/rails/rails/blob/6-0-stable/activerecord/CHANGELOG.md
[active-model]:   https://github.com/rails/rails/blob/6-0-stable/activemodel/CHANGELOG.md
[active-job]:     https://github.com/rails/rails/blob/6-0-stable/activejob/CHANGELOG.md
[guides]:         https://github.com/rails/rails/blob/6-0-stable/guides/CHANGELOG.md
[active-storage]: https://github.com/rails/rails/blob/6-0-stable/activestorage/CHANGELOG.md
[active-support]: https://github.com/rails/rails/blob/6-0-stable/activesupport/CHANGELOG.md
