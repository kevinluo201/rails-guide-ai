**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: c7252bf18650c5a9a85fc144305c4615
Notas de lanzamiento de Ruby on Rails 5.2
==========================================

Aspectos destacados en Rails 5.2:

* Active Storage
* Redis Cache Store
* HTTP/2 Early Hints
* Credentials
* Content Security Policy

Estas notas de lanzamiento solo cubren los cambios principales. Para conocer las diversas correcciones de errores y cambios, consulte los registros de cambios o revise la [lista de confirmaciones](https://github.com/rails/rails/commits/5-2-stable) en el repositorio principal de Rails en GitHub.

--------------------------------------------------------------------------------

Actualización a Rails 5.2
-------------------------

Si está actualizando una aplicación existente, es una buena idea tener una buena cobertura de pruebas antes de comenzar. También debe actualizar primero a Rails 5.1 en caso de que no lo haya hecho y asegurarse de que su aplicación siga funcionando como se espera antes de intentar una actualización a Rails 5.2. Una lista de cosas a tener en cuenta al actualizar está disponible en la guía [Actualización de Ruby on Rails](upgrading_ruby_on_rails.html#upgrading-from-rails-5-1-to-rails-5-2).

Funciones principales
--------------------

### Active Storage

[Solicitud de extracción](https://github.com/rails/rails/pull/30020)

[Active Storage](https://github.com/rails/rails/tree/5-2-stable/activestorage) facilita la carga de archivos a un servicio de almacenamiento en la nube como Amazon S3, Google Cloud Storage o Microsoft Azure Storage y la adjunta a objetos Active Record. Viene con un servicio basado en disco local para desarrollo y pruebas, y admite la duplicación de archivos en servicios subordinados para copias de seguridad y migraciones. Puede obtener más información sobre Active Storage en la guía [Descripción general de Active Storage](active_storage_overview.html).

### Redis Cache Store

[Solicitud de extracción](https://github.com/rails/rails/pull/31134)

Rails 5.2 incluye una tienda de caché Redis incorporada. Puede obtener más información al respecto en la guía [Caché con Rails: una descripción general](caching_with_rails.html#activesupport-cache-rediscachestore).

### HTTP/2 Early Hints

[Solicitud de extracción](https://github.com/rails/rails/pull/30744)

Rails 5.2 admite [HTTP/2 Early Hints](https://tools.ietf.org/html/rfc8297). Para iniciar el servidor con Early Hints habilitado, pase `--early-hints` a `bin/rails server`.

### Credentials

[Solicitud de extracción](https://github.com/rails/rails/pull/30067)

Se agregó el archivo `config/credentials.yml.enc` para almacenar secretos de la aplicación de producción. Permite guardar cualquier credencial de autenticación para servicios de terceros directamente en el repositorio cifrado con una clave en el archivo `config/master.key` o la variable de entorno `RAILS_MASTER_KEY`. Esto eventualmente reemplazará a `Rails.application.secrets` y los secretos cifrados introducidos en Rails 5.1. Además, Rails 5.2 [abre la API subyacente de Credentials](https://github.com/rails/rails/pull/30940), por lo que puede manejar fácilmente otras configuraciones, claves y archivos cifrados. Puede obtener más información al respecto en la guía [Seguridad de las aplicaciones Rails](security.html#custom-credentials).

### Content Security Policy

[Solicitud de extracción](https://github.com/rails/rails/pull/31162)

Rails 5.2 incluye un nuevo DSL que le permite configurar una [Content Security Policy](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Content-Security-Policy) para su aplicación. Puede configurar una política predeterminada global y luego anularla en función de cada recurso e incluso usar lambdas para inyectar valores por solicitud en el encabezado, como subdominios de cuenta en una aplicación multiinquilino. Puede obtener más información al respecto en la guía [Seguridad de las aplicaciones Rails](security.html#content-security-policy).
Railties
--------

Consulte el [registro de cambios][railties] para obtener información detallada sobre los cambios.

### Obsolescencias

*   Obsoleta el método `capify!` en generadores y plantillas.
    ([Pull Request](https://github.com/rails/rails/pull/29493))

*   Se ha obsoleto pasar el nombre del entorno como un argumento regular a los comandos `rails dbconsole` y `rails console`.
    En su lugar, se debe utilizar la opción `-e`.
    ([Commit](https://github.com/rails/rails/commit/48b249927375465a7102acc71c2dfb8d49af8309))

*   Obsoleta la utilización de una subclase de `Rails::Application` para iniciar el servidor de Rails.
    ([Pull Request](https://github.com/rails/rails/pull/30127))

*   Obsoleta la devolución de llamada `after_bundle` en las plantillas de los complementos de Rails.
    ([Pull Request](https://github.com/rails/rails/pull/29446))

### Cambios destacados

*   Se agregó una sección compartida a `config/database.yml` que se cargará para todos los entornos.
    ([Pull Request](https://github.com/rails/rails/pull/28896))

*   Agregar `railtie.rb` al generador de complementos.
    ([Pull Request](https://github.com/rails/rails/pull/29576))

*   Limpiar los archivos de captura de pantalla en la tarea `tmp:clear`.
    ([Pull Request](https://github.com/rails/rails/pull/29534))

*   Omitir los componentes no utilizados al ejecutar `bin/rails app:update`.
    Si la generación inicial de la aplicación omitió Action Cable, Active Record, etc., la tarea de actualización también respeta esas omisiones.
    ([Pull Request](https://github.com/rails/rails/pull/29645))

*   Permitir pasar un nombre de conexión personalizado al comando `rails dbconsole` cuando se utiliza una configuración de base de datos de 3 niveles.
    Ejemplo: `bin/rails dbconsole -c replica`.
    ([Commit](https://github.com/rails/rails/commit/1acd9a6464668d4d54ab30d016829f60b70dbbeb))

*   Expandir correctamente los atajos para el nombre del entorno al ejecutar los comandos `console` y `dbconsole`.
    ([Commit](https://github.com/rails/rails/commit/3777701f1380f3814bd5313b225586dec64d4104))

*   Agregar `bootsnap` al `Gemfile` predeterminado.
    ([Pull Request](https://github.com/rails/rails/pull/29313))

*   Admitir `-` como una forma independiente de plataforma para ejecutar un script desde stdin con `rails runner`.
    ([Pull Request](https://github.com/rails/rails/pull/26343))

*   Agregar la versión `ruby x.x.x` al `Gemfile` y crear el archivo raíz `.ruby-version` que contiene la versión actual de Ruby cuando se crean nuevas aplicaciones de Rails.
    ([Pull Request](https://github.com/rails/rails/pull/30016))

*   Agregar la opción `--skip-action-cable` al generador de complementos.
    ([Pull Request](https://github.com/rails/rails/pull/30164))

*   Agregar `git_source` al `Gemfile` para el generador de complementos.
    ([Pull Request](https://github.com/rails/rails/pull/30110))

*   Omitir los componentes no utilizados al ejecutar `bin/rails` en un complemento de Rails.
    ([Commit](https://github.com/rails/rails/commit/62499cb6e088c3bc32a9396322c7473a17a28640))

*   Optimizar la sangría de las acciones del generador.
    ([Pull Request](https://github.com/rails/rails/pull/30166))

*   Optimizar la sangría de las rutas.
    ([Pull Request](https://github.com/rails/rails/pull/30241))

*   Agregar la opción `--skip-yarn` al generador de complementos.
    ([Pull Request](https://github.com/rails/rails/pull/30238))

*   Admitir múltiples argumentos de versiones para el método `gem` de los generadores.
    ([Pull Request](https://github.com/rails/rails/pull/30323))

*   Derivar `secret_key_base` del nombre de la aplicación en los entornos de desarrollo y prueba.
    ([Pull Request](https://github.com/rails/rails/pull/30067))

*   Agregar `mini_magick` al `Gemfile` predeterminado como comentario.
    ([Pull Request](https://github.com/rails/rails/pull/30633))

*   `rails new` y `rails plugin new` obtienen `Active Storage` de forma predeterminada.
    Agregar la capacidad de omitir `Active Storage` con `--skip-active-storage` y hacerlo automáticamente cuando se utiliza `--skip-active-record`.
    ([Pull Request](https://github.com/rails/rails/pull/30101))

Action Cable
------------

Consulte el [registro de cambios][action-cable] para obtener información detallada sobre los cambios.

### Eliminaciones

*   Se eliminó el adaptador de Redis basado en eventos obsoleto.
    ([Commit](https://github.com/rails/rails/commit/48766e32d31651606b9f68a16015ad05c3b0de2c))

### Cambios destacados

*   Agregar soporte para las opciones `host`, `port`, `db` y `password` en cable.yml
    ([Pull Request](https://github.com/rails/rails/pull/29528))

*   Hash los identificadores de transmisión largos al utilizar el adaptador de PostgreSQL.
    ([Pull Request](https://github.com/rails/rails/pull/29297))

Action Pack
-----------

Consulte el [registro de cambios][action-pack] para obtener información detallada sobre los cambios.
### Eliminaciones

*   Eliminar `ActionController::ParamsParser::ParseError` obsoleto.
    ([Commit](https://github.com/rails/rails/commit/e16c765ac6dcff068ff2e5554d69ff345c003de1))

### Obsolescencias

*   Obsoleto `#success?`, `#missing?` y `#error?` alias de
    `ActionDispatch::TestResponse`.
    ([Pull Request](https://github.com/rails/rails/pull/30104))

### Cambios destacados

*   Agregar soporte para claves de caché reciclables con caché de fragmentos.
    ([Pull Request](https://github.com/rails/rails/pull/29092))

*   Cambiar el formato de la clave de caché para fragmentos para facilitar la depuración de claves.
    ([Pull Request](https://github.com/rails/rails/pull/29092))

*   Cookies y sesiones cifradas AEAD con GCM.
    ([Pull Request](https://github.com/rails/rails/pull/28132))

*   Proteger contra falsificaciones de forma predeterminada.
    ([Pull Request](https://github.com/rails/rails/pull/29742))

*   Aplicar el vencimiento de las cookies firmadas/cifradas en el servidor.
    ([Pull Request](https://github.com/rails/rails/pull/30121))

*   La opción `:expires` de las cookies admite el objeto `ActiveSupport::Duration`.
    ([Pull Request](https://github.com/rails/rails/pull/30121))

*   Usar la configuración del servidor registrado `:puma` de Capybara.
    ([Pull Request](https://github.com/rails/rails/pull/30638))

*   Simplificar el middleware de cookies con soporte de rotación de claves.
    ([Pull Request](https://github.com/rails/rails/pull/29716))

*   Agregar capacidad para habilitar Early Hints para HTTP/2.
    ([Pull Request](https://github.com/rails/rails/pull/30744))

*   Agregar soporte de Chrome sin cabeza a las pruebas del sistema.
    ([Pull Request](https://github.com/rails/rails/pull/30876))

*   Agregar opción `:allow_other_host` al método `redirect_back`.
    ([Pull Request](https://github.com/rails/rails/pull/30850))

*   Hacer que `assert_recognizes` recorra los motores montados.
    ([Pull Request](https://github.com/rails/rails/pull/22435))

*   Agregar DSL para configurar la cabecera Content-Security-Policy.
    ([Pull Request](https://github.com/rails/rails/pull/31162),
    [Commit](https://github.com/rails/rails/commit/619b1b6353a65e1635d10b8f8c6630723a5a6f1a),
    [Commit](https://github.com/rails/rails/commit/4ec8bf68ff92f35e79232fbd605012ce1f4e1e6e))

*   Registrar los tipos MIME de audio/video/fuente más populares admitidos por los navegadores modernos.
    ([Pull Request](https://github.com/rails/rails/pull/31251))

*   Cambiar la salida de captura de pantalla de las pruebas del sistema de `inline` a `simple` de forma predeterminada.
    ([Commit](https://github.com/rails/rails/commit/9d6e288ee96d6241f864dbf90211c37b14a57632))

*   Agregar soporte de Firefox sin cabeza a las pruebas del sistema.
    ([Pull Request](https://github.com/rails/rails/pull/31365))

*   Agregar `X-Download-Options` y `X-Permitted-Cross-Domain-Policies` seguros a los encabezados predeterminados.
    ([Commit](https://github.com/rails/rails/commit/5d7b70f4336d42eabfc403e9f6efceb88b3eff44))

*   Cambiar las pruebas del sistema para establecer Puma como servidor predeterminado solo cuando el usuario no haya especificado manualmente otro servidor.
    ([Pull Request](https://github.com/rails/rails/pull/31384))

*   Agregar encabezado `Referrer-Policy` a los encabezados predeterminados.
    ([Commit](https://github.com/rails/rails/commit/428939be9f954d39b0c41bc53d85d0d106b9d1a1))

*   Coincidir con el comportamiento de `Hash#each` en `ActionController::Parameters#each`.
    ([Pull Request](https://github.com/rails/rails/pull/27790))

*   Agregar soporte para generación automática de nonce para Rails UJS.
    ([Commit](https://github.com/rails/rails/commit/b2f0a8945956cd92dec71ec4e44715d764990a49))

*   Actualizar el valor predeterminado de HSTS max-age a 31536000 segundos (1 año)
    para cumplir con el requisito mínimo de max-age para https://hstspreload.org/.
    ([Commit](https://github.com/rails/rails/commit/30b5f469a1d30c60d1fb0605e84c50568ff7ed37))

*   Agregar método de alias `to_hash` a `to_h` para `cookies`.
    Agregar método de alias `to_h` a `to_hash` para `session`.
    ([Commit](https://github.com/rails/rails/commit/50a62499e41dfffc2903d468e8b47acebaf9b500))

Action View
-----------

Consulte el [registro de cambios][action-view] para obtener cambios detallados.

### Eliminaciones

*   Eliminar el controlador ERB obsoleto de Erubis.
    ([Commit](https://github.com/rails/rails/commit/7de7f12fd140a60134defe7dc55b5a20b2372d06))

### Obsolescencias

*   Obsoleto el ayudante `image_alt` que solía agregar texto alternativo predeterminado a
    las imágenes generadas por `image_tag`.
    ([Pull Request](https://github.com/rails/rails/pull/30213))

### Cambios destacados

*   Agregar tipo `:json` a `auto_discovery_link_tag` para admitir
    [JSON Feeds](https://jsonfeed.org/version/1).
    ([Pull Request](https://github.com/rails/rails/pull/29158))

*   Agregar opción `srcset` al ayudante `image_tag`.
    ([Pull Request](https://github.com/rails/rails/pull/29349))

*   Solucionar problemas con `field_error_proc` que envuelve `optgroup` y
    opción de división select `option`.
    ([Pull Request](https://github.com/rails/rails/pull/31088))

*   Cambiar `form_with` para generar ids de forma predeterminada.
    ([Commit](https://github.com/rails/rails/commit/260d6f112a0ffdbe03e6f5051504cb441c1e94cd))

*   Agregar ayudante `preload_link_tag`.
    ([Pull Request](https://github.com/rails/rails/pull/31251))

*   Permitir el uso de objetos llamables como métodos de grupo para selects agrupados.
    ([Pull Request](https://github.com/rails/rails/pull/31578))
Action Mailer
-------------

Consulte el [registro de cambios][action-mailer] para obtener cambios detallados.

### Cambios destacados

*   Permitir que las clases de Action Mailer configuren su trabajo de entrega.
    ([Solicitud de extracción](https://github.com/rails/rails/pull/29457))

*   Agregar el ayudante de prueba `assert_enqueued_email_with`.
    ([Solicitud de extracción](https://github.com/rails/rails/pull/30695))

Active Record
-------------

Consulte el [registro de cambios][active-record] para obtener cambios detallados.

### Eliminaciones

*   Eliminar `#migration_keys` obsoleto.
    ([Solicitud de extracción](https://github.com/rails/rails/pull/30337))

*   Eliminar el soporte obsoleto para `quoted_id` al convertir el tipo de
    un objeto Active Record.
    ([Commit](https://github.com/rails/rails/commit/82472b3922bda2f337a79cef961b4760d04f9689))

*   Eliminar el argumento obsoleto `default` de `index_name_exists?`.
    ([Commit](https://github.com/rails/rails/commit/8f5b34df81175e30f68879479243fbce966122d7))

*   Eliminar el soporte obsoleto para pasar una clase a `:class_name`
    en las asociaciones.
    ([Commit](https://github.com/rails/rails/commit/e65aff70696be52b46ebe57207ebd8bb2cfcdbb6))

*   Eliminar los métodos obsoletos `initialize_schema_migrations_table` y
    `initialize_internal_metadata_table`.
    ([Commit](https://github.com/rails/rails/commit/c9660b5777707658c414b430753029cd9bc39934))

*   Eliminar el método obsoleto `supports_migrations?`.
    ([Commit](https://github.com/rails/rails/commit/9438c144b1893f2a59ec0924afe4d46bd8d5ffdd))

*   Eliminar el método obsoleto `supports_primary_key?`.
    ([Commit](https://github.com/rails/rails/commit/c56ff22fc6e97df4656ddc22909d9bf8b0c2cbb1))

*   Eliminar el método obsoleto
    `ActiveRecord::Migrator.schema_migrations_table_name`.
    ([Commit](https://github.com/rails/rails/commit/7df6e3f3cbdea9a0460ddbab445c81fbb1cfd012))

*   Eliminar el argumento obsoleto `name` de `#indexes`.
    ([Commit](https://github.com/rails/rails/commit/d6b779ecebe57f6629352c34bfd6c442ac8fba0e))

*   Eliminar los argumentos obsoletos de `#verify!`.
    ([Commit](https://github.com/rails/rails/commit/9c6ee1bed0292fc32c23dc1c68951ae64fc510be))

*   Eliminar la configuración obsoleta `.error_on_ignored_order_or_limit`.
    ([Commit](https://github.com/rails/rails/commit/e1066f450d1a99c9a0b4d786b202e2ca82a4c3b3))

*   Eliminar el método obsoleto `#scope_chain`.
    ([Commit](https://github.com/rails/rails/commit/ef7784752c5c5efbe23f62d2bbcc62d4fd8aacab))

*   Eliminar el método obsoleto `#sanitize_conditions`.
    ([Commit](https://github.com/rails/rails/commit/8f5413b896099f80ef46a97819fe47a820417bc2))

### Obsolescencias

*   Obsoleto `supports_statement_cache?`.
    ([Solicitud de extracción](https://github.com/rails/rails/pull/28938))

*   Obsoleto pasar argumentos y bloque al mismo tiempo a
    `count` y `sum` en `ActiveRecord::Calculations`.
    ([Solicitud de extracción](https://github.com/rails/rails/pull/29262))

*   Obsoleto delegar a `arel` en `Relation`.
    ([Solicitud de extracción](https://github.com/rails/rails/pull/29619))

*   Obsoleto el método `set_state` en `TransactionState`.
    ([Commit](https://github.com/rails/rails/commit/608ebccf8f6314c945444b400a37c2d07f21b253))

*   Obsoleto `expand_hash_conditions_for_aggregates` sin reemplazo.
    ([Commit](https://github.com/rails/rails/commit/7ae26885d96daee3809d0bd50b1a440c2f5ffb69))

### Cambios destacados

*   Al llamar al método de acceso dinámico a los fixtures sin argumentos, ahora
    devuelve todos los fixtures de este tipo. Anteriormente, este método siempre devolvía
    una matriz vacía.
    ([Solicitud de extracción](https://github.com/rails/rails/pull/28692))

*   Corregir inconsistencia con los atributos cambiados al anular
    el lector de atributos de Active Record.
    ([Solicitud de extracción](https://github.com/rails/rails/pull/28661))

*   Soporte para índices descendentes en MySQL.
    ([Solicitud de extracción](https://github.com/rails/rails/pull/28773))

*   Corregir la primera migración de `bin/rails db:forward`.
    ([Commit](https://github.com/rails/rails/commit/b77d2aa0c336492ba33cbfade4964ba0eda3ef84))

*   Generar un error `UnknownMigrationVersionError` en el movimiento de migraciones
    cuando la migración actual no existe.
    ([Commit](https://github.com/rails/rails/commit/bb9d6eb094f29bb94ef1f26aa44f145f17b973fe))

*   Respetar `SchemaDumper.ignore_tables` en las tareas de rake para
    la estructura de las bases de datos.
    ([Solicitud de extracción](https://github.com/rails/rails/pull/29077))

*   Agregar `ActiveRecord::Base#cache_version` para admitir claves de caché reciclables a través de
    las nuevas entradas versionadas en `ActiveSupport::Cache`. Esto también significa que
    `ActiveRecord::Base#cache_key` ahora devolverá una clave estable que
    ya no incluye una marca de tiempo.
    ([Solicitud de extracción](https://github.com/rails/rails/pull/29092))

*   Evitar la creación de un parámetro de enlace si el valor convertido es nulo.
    ([Solicitud de extracción](https://github.com/rails/rails/pull/29282))

*   Usar INSERT masivo para insertar fixtures para obtener un mejor rendimiento.
    ([Solicitud de extracción](https://github.com/rails/rails/pull/29504))

*   La fusión de dos relaciones que representan joins anidados ya no transforma
    los joins de la relación fusionada en LEFT OUTER JOIN.
    ([Solicitud de extracción](https://github.com/rails/rails/pull/27063))

*   Corregir las transacciones para aplicar el estado a las transacciones secundarias.
    Anteriormente, si tenía una transacción anidada y la transacción externa se revertía,
    el registro de la transacción interna aún se marcaría
    como persistente. Se corrigió aplicando el estado de la transacción principal
    a la transacción secundaria cuando la transacción principal se revierte.
    Esto marcará correctamente los registros de la transacción interna
    como no persistentes.
    ([Commit](https://github.com/rails/rails/commit/0237da287eb4c507d10a0c6d94150093acc52b03))
*   Corregir la carga ansiosa/precarga de asociaciones con alcance que incluye joins.
    ([Pull Request](https://github.com/rails/rails/pull/29413))

*   Evitar que los errores generados por los suscriptores de notificaciones `sql.active_record`
    se conviertan en excepciones `ActiveRecord::StatementInvalid`.
    ([Pull Request](https://github.com/rails/rails/pull/29692))

*   Omitir el almacenamiento en caché de consultas al trabajar con lotes de registros
    (`find_each`, `find_in_batches`, `in_batches`).
    ([Commit](https://github.com/rails/rails/commit/b83852e6eed5789b23b13bac40228e87e8822b4d))

*   Cambiar la serialización booleana de sqlite3 para usar 1 y 0.
    SQLite reconoce nativamente 1 y 0 como verdadero y falso, pero no reconoce nativamente
    't' y 'f' como se serializaba anteriormente.
    ([Pull Request](https://github.com/rails/rails/pull/29699))

*   Los valores construidos utilizando asignación de múltiples parámetros ahora utilizarán el
    valor de poscasteo para su representación en campos de formulario de un solo campo.
    ([Commit](https://github.com/rails/rails/commit/1519e976b224871c7f7dd476351930d5d0d7faf6))

*   `ApplicationRecord` ya no se genera al generar modelos. Si necesitas generarlo, puedes crearlo con `rails g application_record`.
    ([Pull Request](https://github.com/rails/rails/pull/29916))

*   `Relation#or` ahora acepta dos relaciones que tienen valores diferentes para
    `references` solamente, ya que `references` puede ser llamado implícitamente por `where`.
    ([Commit](https://github.com/rails/rails/commit/ea6139101ccaf8be03b536b1293a9f36bc12f2f7))

*   Al utilizar `Relation#or`, extraer las condiciones comunes y
    colocarlas antes de la condición OR.
    ([Pull Request](https://github.com/rails/rails/pull/29950))

*   Agregar el método auxiliar de fixture `binary`.
    ([Pull Request](https://github.com/rails/rails/pull/30073))

*   Adivinar automáticamente las asociaciones inversas para STI.
    ([Pull Request](https://github.com/rails/rails/pull/23425))

*   Agregar la nueva clase de error `LockWaitTimeout` que se generará
    cuando se exceda el tiempo de espera de bloqueo.
    ([Pull Request](https://github.com/rails/rails/pull/30360))

*   Actualizar los nombres de carga útil para la instrumentación `sql.active_record` para que sean
    más descriptivos.
    ([Pull Request](https://github.com/rails/rails/pull/30619))

*   Utilizar el algoritmo dado al eliminar un índice de la base de datos.
    ([Pull Request](https://github.com/rails/rails/pull/24199))

*   Pasar un `Set` a `Relation#where` ahora se comporta de la misma manera que pasar
    un array.
    ([Commit](https://github.com/rails/rails/commit/9cf7e3494f5bd34f1382c1ff4ea3d811a4972ae2))

*   PostgreSQL `tsrange` ahora conserva la precisión de subsegundos.
    ([Pull Request](https://github.com/rails/rails/pull/30725))

*   Generar una excepción al llamar a `lock!` en un registro modificado.
    ([Commit](https://github.com/rails/rails/commit/63cf15877bae859ff7b4ebaf05186f3ca79c1863))

*   Corregido un error donde los órdenes de columna para un índice no se escribían en
    `db/schema.rb` al utilizar el adaptador SQLite.
    ([Pull Request](https://github.com/rails/rails/pull/30970))

*   Corregir `bin/rails db:migrate` con `VERSION` especificado.
    `bin/rails db:migrate` con `VERSION` vacío se comporta como sin `VERSION`.
    Verificar el formato de `VERSION`: Permitir un número de versión de migración
    o el nombre de un archivo de migración. Generar un error si el formato de `VERSION` es inválido.
    Generar un error si la migración objetivo no existe.
    ([Pull Request](https://github.com/rails/rails/pull/30714))

*   Agregar la nueva clase de error `StatementTimeout` que se generará
    cuando se exceda el tiempo de espera de la declaración.
    ([Pull Request](https://github.com/rails/rails/pull/31129))

*   `update_all` ahora pasará sus valores a `Type#cast` antes de pasarlos a
    `Type#serialize`. Esto significa que `update_all(foo: 'true')` persistirá correctamente un booleano.
    ([Commit](https://github.com/rails/rails/commit/68fe6b08ee72cc47263e0d2c9ff07f75c4b42761))

*   Requerir que los fragmentos de SQL sin procesar se marquen explícitamente cuando se usan en
    métodos de consulta de relaciones.
    ([Commit](https://github.com/rails/rails/commit/a1ee43d2170dd6adf5a9f390df2b1dde45018a48),
    [Commit](https://github.com/rails/rails/commit/e4a921a75f8702a7dbaf41e31130fe884dea93f9))

*   Agregar `#up_only` a las migraciones de la base de datos para el código que solo es relevante al
    migrar hacia arriba, por ejemplo, poblar una nueva columna.
    ([Pull Request](https://github.com/rails/rails/pull/31082))
*   Agregar nueva clase de error `QueryCanceled` que se lanzará cuando se cancele una declaración debido a una solicitud del usuario.
    ([Pull Request](https://github.com/rails/rails/pull/31235))

*   No permitir definir ámbitos que entren en conflicto con los métodos de instancia en `Relation`.
    ([Pull Request](https://github.com/rails/rails/pull/31179))

*   Agregar soporte para clases de operadores de PostgreSQL a `add_index`.
    ([Pull Request](https://github.com/rails/rails/pull/19090))

*   Registrar los llamadores de las consultas de la base de datos.
    ([Pull Request](https://github.com/rails/rails/pull/26815),
    [Pull Request](https://github.com/rails/rails/pull/31519),
    [Pull Request](https://github.com/rails/rails/pull/31690))

*   Anular los métodos de atributo en los descendientes al restablecer la información de columna.
    ([Pull Request](https://github.com/rails/rails/pull/31475))

*   Usar subconsulta para `delete_all` con `limit` o `offset`.
    ([Commit](https://github.com/rails/rails/commit/9e7260da1bdc0770cf4ac547120c85ab93ff3d48))

*   Corregir inconsistencia con `first(n)` cuando se usa con `limit()`.
    El buscador `first(n)` ahora respeta el `limit()`, haciéndolo consistente
    con `relation.to_a.first(n)`, y también con el comportamiento de `last(n)`.
    ([Pull Request](https://github.com/rails/rails/pull/27597))

*   Corregir asociaciones anidadas `has_many :through` en instancias de padres no persistidos.
    ([Commit](https://github.com/rails/rails/commit/027f865fc8b262d9ba3ee51da3483e94a5489b66))

*   Tomar en cuenta las condiciones de asociación al eliminar registros a través de ellos.
    ([Commit](https://github.com/rails/rails/commit/ae48c65e411e01c1045056562319666384bb1b63))

*   No permitir la mutación de objetos destruidos después de llamar a `save` o `save!`.
    ([Commit](https://github.com/rails/rails/commit/562dd0494a90d9d47849f052e8913f0050f3e494))

*   Corregir problema de fusión de relaciones con `left_outer_joins`.
    ([Pull Request](https://github.com/rails/rails/pull/27860))

*   Soporte para tablas externas de PostgreSQL.
    ([Pull Request](https://github.com/rails/rails/pull/31549))

*   Limpiar el estado de transacción cuando se duplica un objeto Active Record.
    ([Pull Request](https://github.com/rails/rails/pull/31751))

*   Corregir problema de expansión no realizada al pasar un objeto Array como argumento
    al método where utilizando una columna `composed_of`.
    ([Pull Request](https://github.com/rails/rails/pull/31724))

*   Hacer que `reflection.klass` lance una excepción si `polymorphic?` no se usa correctamente.
    ([Commit](https://github.com/rails/rails/commit/63fc1100ce054e3e11c04a547cdb9387cd79571a))

*   Corregir `#columns_for_distinct` de MySQL y PostgreSQL para que
    `ActiveRecord::FinderMethods#limited_ids_for` use los valores de clave primaria correctos
    incluso si las columnas `ORDER BY` incluyen la clave primaria de otra tabla.
    ([Commit](https://github.com/rails/rails/commit/851618c15750979a75635530200665b543561a44))

*   Corregir problema de `dependent: :destroy` en la relación has_one/belongs_to donde
    la clase padre se eliminaba cuando el hijo no lo estaba.
    ([Commit](https://github.com/rails/rails/commit/b0fc04aa3af338d5a90608bf37248668d59fc881))

*   Las conexiones inactivas de la base de datos (anteriormente solo las conexiones huérfanas) ahora
    se eliminan periódicamente por el recolector de conexiones del grupo de conexiones.
    ([Commit](https://github.com/rails/rails/pull/31221/commits/9027fafff6da932e6e64ddb828665f4b01fc8902))

Active Model
------------

Consulte el [registro de cambios][active-model] para obtener cambios detallados.

### Cambios destacados

*   Corregir los métodos `#keys`, `#values` en `ActiveModel::Errors`.
    Cambiar `#keys` para que solo devuelva las claves que no tienen mensajes vacíos.
    Cambiar `#values` para que solo devuelva los valores no vacíos.
    ([Pull Request](https://github.com/rails/rails/pull/28584))

*   Agregar el método `#merge!` para `ActiveModel::Errors`.
    ([Pull Request](https://github.com/rails/rails/pull/29714))

*   Permitir pasar un Proc o un símbolo a las opciones del validador de longitud.
    ([Pull Request](https://github.com/rails/rails/pull/30674))

*   Ejecutar la validación de `ConfirmationValidator` cuando el valor de `_confirmation`
    es `false`.
    ([Pull Request](https://github.com/rails/rails/pull/31058))

*   Los modelos que utilizan la API de atributos con un valor predeterminado de tipo proc ahora se pueden serializar.
    ([Commit](https://github.com/rails/rails/commit/0af36c62a5710e023402e37b019ad9982e69de4b))

*   No perder todas las múltiples `:includes` con opciones en la serialización.
    ([Commit](https://github.com/rails/rails/commit/853054bcc7a043eea78c97e7705a46abb603cc44))

Active Support
--------------

Consulte el [registro de cambios][active-support] para obtener cambios detallados.

### Eliminaciones

*   Eliminar el filtro de cadena `:if` y `:unless` deprecado para los callbacks.
    ([Commit](https://github.com/rails/rails/commit/c792354adcbf8c966f274915c605c6713b840548))

*   Eliminar la opción `halt_callback_chains_on_return_false` deprecada.
    ([Commit](https://github.com/rails/rails/commit/19fbbebb1665e482d76cae30166b46e74ceafe29))
### Deprecaciones

*   Deprecar el método `Module#reachable?`.
    ([Pull Request](https://github.com/rails/rails/pull/30624))

*   Deprecar `secrets.secret_token`.
    ([Commit](https://github.com/rails/rails/commit/fbcc4bfe9a211e219da5d0bb01d894fcdaef0a0e))

### Cambios destacados

*   Agregar `fetch_values` para `HashWithIndifferentAccess`.
    ([Pull Request](https://github.com/rails/rails/pull/28316))

*   Agregar soporte para `:offset` en `Time#change`.
    ([Commit](https://github.com/rails/rails/commit/851b7f866e13518d900407c78dcd6eb477afad06))

*   Agregar soporte para `:offset` y `:zone`
    en `ActiveSupport::TimeWithZone#change`.
    ([Commit](https://github.com/rails/rails/commit/851b7f866e13518d900407c78dcd6eb477afad06))

*   Pasar el nombre de la gema y el horizonte de depreciación a las notificaciones de depreciación.
    ([Pull Request](https://github.com/rails/rails/pull/28800))

*   Agregar soporte para entradas de caché versionadas. Esto permite que las tiendas de caché reciclen claves de caché, lo que ahorra mucho almacenamiento en casos con cambios frecuentes. Funciona junto con la separación de `#cache_key` y `#cache_version` en Active Record y su uso en el almacenamiento en caché de fragmentos de Action Pack.
    ([Pull Request](https://github.com/rails/rails/pull/29092))

*   Agregar `ActiveSupport::CurrentAttributes` para proporcionar un singleton de atributos aislados en el hilo. El caso de uso principal es mantener todos los atributos por solicitud fácilmente disponibles para todo el sistema.
    ([Pull Request](https://github.com/rails/rails/pull/29180))

*   `#singularize` y `#pluralize` ahora respetan los incontables para el idioma especificado.
    ([Commit](https://github.com/rails/rails/commit/352865d0f835c24daa9a2e9863dcc9dde9e5371a))

*   Agregar opción predeterminada a `class_attribute`.
    ([Pull Request](https://github.com/rails/rails/pull/29270))

*   Agregar `Date#prev_occurring` y `Date#next_occurring` para devolver el día de la semana siguiente/anterior especificado.
    ([Pull Request](https://github.com/rails/rails/pull/26600))

*   Agregar opción predeterminada a los accesores de atributos de módulo y clase.
    ([Pull Request](https://github.com/rails/rails/pull/29294))

*   Caché: `write_multi`.
    ([Pull Request](https://github.com/rails/rails/pull/29366))

*   Establecer por defecto `ActiveSupport::MessageEncryptor` para usar cifrado AES 256 GCM.
    ([Pull Request](https://github.com/rails/rails/pull/29263))

*   Agregar ayudante `freeze_time` que congela el tiempo en `Time.now` en las pruebas.
    ([Pull Request](https://github.com/rails/rails/pull/29681))

*   Hacer que el orden de `Hash#reverse_merge!` sea consistente con `HashWithIndifferentAccess`.
    ([Pull Request](https://github.com/rails/rails/pull/28077))

*   Agregar soporte para propósito y expiración a `ActiveSupport::MessageVerifier` y `ActiveSupport::MessageEncryptor`.
    ([Pull Request](https://github.com/rails/rails/pull/29892))

*   Actualizar `String#camelize` para proporcionar retroalimentación cuando se pasa una opción incorrecta.
    ([Pull Request](https://github.com/rails/rails/pull/30039))

*   `Module#delegate_missing_to` ahora genera un `DelegationError` si el objetivo es nulo, similar a `Module#delegate`.
    ([Pull Request](https://github.com/rails/rails/pull/30191))

*   Agregar `ActiveSupport::EncryptedFile` y `ActiveSupport::EncryptedConfiguration`.
    ([Pull Request](https://github.com/rails/rails/pull/30067))

*   Agregar `config/credentials.yml.enc` para almacenar secretos de la aplicación de producción.
    ([Pull Request](https://github.com/rails/rails/pull/30067))

*   Agregar soporte de rotación de claves a `MessageEncryptor` y `MessageVerifier`.
    ([Pull Request](https://github.com/rails/rails/pull/29716))

*   Devolver una instancia de `HashWithIndifferentAccess` desde `HashWithIndifferentAccess#transform_keys`.
    ([Pull Request](https://github.com/rails/rails/pull/30728))

*   `Hash#slice` ahora utiliza la definición incorporada de Ruby 2.5+ si está definida.
    ([Commit](https://github.com/rails/rails/commit/01ae39660243bc5f0a986e20f9c9bff312b1b5f8))

*   `IO#to_json` ahora devuelve la representación `to_s`, en lugar de intentar convertir a un array. Esto soluciona un error donde `IO#to_json` generaba un `IOError` al llamarlo en un objeto no legible.
    ([Pull Request](https://github.com/rails/rails/pull/30953))

*   Agregar la misma firma de método para `Time#prev_day` y `Time#next_day` de acuerdo con `Date#prev_day`, `Date#next_day`. Permite pasar un argumento para `Time#prev_day` y `Time#next_day`.
    ([Commit](https://github.com/rails/rails/commit/61ac2167eff741bffb44aec231f4ea13d004134e))

*   Agregar la misma firma de método para `Time#prev_month` y `Time#next_month` de acuerdo con `Date#prev_month`, `Date#next_month`. Permite pasar un argumento para `Time#prev_month` y `Time#next_month`.
    ([Commit](https://github.com/rails/rails/commit/f2c1e3a793570584d9708aaee387214bc3543530))

*   Agregar la misma firma de método para `Time#prev_year` y `Time#next_year` de acuerdo con `Date#prev_year`, `Date#next_year`. Permite pasar un argumento para `Time#prev_year` y `Time#next_year`.
    ([Commit](https://github.com/rails/rails/commit/ee9d81837b5eba9d5ec869ae7601d7ffce763e3e))
*   Corregir el soporte de acrónimos en `humanize`.
    ([Commit](https://github.com/rails/rails/commit/0ddde0a8fca6a0ca3158e3329713959acd65605d))

*   Permitir `Range#include?` en rangos TWZ.
    ([Pull Request](https://github.com/rails/rails/pull/31081))

*   Caché: Habilitar compresión de forma predeterminada para valores > 1kB.
    ([Pull Request](https://github.com/rails/rails/pull/31147))

*   Almacenamiento de caché en Redis.
    ([Pull Request](https://github.com/rails/rails/pull/31134),
    [Pull Request](https://github.com/rails/rails/pull/31866))

*   Manejar errores de `TZInfo::AmbiguousTime`.
    ([Pull Request](https://github.com/rails/rails/pull/31128))

*   MemCacheStore: Soporte para expirar contadores.
    ([Commit](https://github.com/rails/rails/commit/b22ee64b5b30c6d5039c292235e10b24b1057f6d))

*   Hacer que `ActiveSupport::TimeZone.all` devuelva solo zonas horarias que estén en
    `ActiveSupport::TimeZone::MAPPING`.
    ([Pull Request](https://github.com/rails/rails/pull/31176))

*   Cambiar el comportamiento predeterminado de `ActiveSupport::SecurityUtils.secure_compare`,
    para que no se filtre información de longitud incluso para cadenas de longitud variable.
    Renombrar el antiguo `ActiveSupport::SecurityUtils.secure_compare` a
    `fixed_length_secure_compare`, y comenzar a generar un `ArgumentError` en
    caso de discrepancia de longitud de las cadenas pasadas.
    ([Pull Request](https://github.com/rails/rails/pull/24510))

*   Usar SHA-1 para generar resúmenes no sensibles, como el encabezado ETag.
    ([Pull Request](https://github.com/rails/rails/pull/31289),
    [Pull Request](https://github.com/rails/rails/pull/31651))

*   `assert_changes` siempre afirmará que la expresión cambia,
    independientemente de las combinaciones de argumentos `from:` y `to:`.
    ([Pull Request](https://github.com/rails/rails/pull/31011))

*   Agregar instrumentación faltante para `read_multi`
    en `ActiveSupport::Cache::Store`.
    ([Pull Request](https://github.com/rails/rails/pull/30268))

*   Soporte de hash como primer argumento en `assert_difference`.
    Esto permite especificar múltiples diferencias numéricas en la misma afirmación.
    ([Pull Request](https://github.com/rails/rails/pull/31600))

*   Caché: Aceleración de `read_multi` y `fetch_multi` en MemCache y Redis.
    Leer de la caché en memoria local antes de consultar el backend.
    ([Commit](https://github.com/rails/rails/commit/a2b97e4ffef971607a1be8fc7909f099b6840f36))

Active Job
----------

Consulte el [registro de cambios][active-job] para obtener cambios detallados.

### Cambios destacados

*   Permitir pasar un bloque a `ActiveJob::Base.discard_on` para permitir
    manejo personalizado de trabajos descartados.
    ([Pull Request](https://github.com/rails/rails/pull/30622))

Ruby on Rails Guides
--------------------

Consulte el [registro de cambios][guides] para obtener cambios detallados.

### Cambios destacados

*   Agregar
    [Guía de subprocesos y ejecución de código en Rails](threading_and_code_execution.html).
    ([Pull Request](https://github.com/rails/rails/pull/27494))

*   Agregar [Descripción general de Active Storage](active_storage_overview.html) Guía.
    ([Pull Request](https://github.com/rails/rails/pull/31037))

Créditos
-------

Consulte la
[lista completa de colaboradores de Rails](https://contributors.rubyonrails.org/)
para conocer a las muchas personas que dedicaron muchas horas a hacer de Rails, el marco estable y robusto que es. Felicitaciones a todos ellos.

[railties]:       https://github.com/rails/rails/blob/5-2-stable/railties/CHANGELOG.md
[action-pack]:    https://github.com/rails/rails/blob/5-2-stable/actionpack/CHANGELOG.md
[action-view]:    https://github.com/rails/rails/blob/5-2-stable/actionview/CHANGELOG.md
[action-mailer]:  https://github.com/rails/rails/blob/5-2-stable/actionmailer/CHANGELOG.md
[action-cable]:   https://github.com/rails/rails/blob/5-2-stable/actioncable/CHANGELOG.md
[active-record]:  https://github.com/rails/rails/blob/5-2-stable/activerecord/CHANGELOG.md
[active-model]:   https://github.com/rails/rails/blob/5-2-stable/activemodel/CHANGELOG.md
[active-job]:     https://github.com/rails/rails/blob/5-2-stable/activejob/CHANGELOG.md
[guides]:         https://github.com/rails/rails/blob/5-2-stable/guides/CHANGELOG.md
[active-support]: https://github.com/rails/rails/blob/5-2-stable/activesupport/CHANGELOG.md
