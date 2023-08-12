**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: b21dbc892c0a841f1bc1fafdf5ee0126
Notas de lanzamiento de Ruby on Rails 4.0
==========================================

Aspectos destacados en Rails 4.0:

* Se prefiere Ruby 2.0; se requiere 1.9.3+
* Parámetros fuertes
* Turbolinks
* Caché de muñecas rusas

Estas notas de lanzamiento solo cubren los cambios principales. Para conocer las correcciones de errores y cambios diversos, consulte los registros de cambios o revise la [lista de confirmaciones](https://github.com/rails/rails/commits/4-0-stable) en el repositorio principal de Rails en GitHub.

--------------------------------------------------------------------------------

Actualización a Rails 4.0
-------------------------

Si está actualizando una aplicación existente, es una buena idea tener una buena cobertura de pruebas antes de comenzar. También debe actualizar primero a Rails 3.2 en caso de que no lo haya hecho y asegurarse de que su aplicación siga funcionando como se espera antes de intentar una actualización a Rails 4.0. Una lista de cosas a tener en cuenta al actualizar está disponible en la guía [Actualización de Ruby on Rails](upgrading_ruby_on_rails.html#upgrading-from-rails-3-2-to-rails-4-0).

Creación de una aplicación Rails 4.0
------------------------------------

```bash
# Debe tener instalada la gema 'rails'
$ rails new myapp
$ cd myapp
```

### Vinculación de gemas

Rails ahora utiliza un `Gemfile` en la raíz de la aplicación para determinar las gemas que necesita su aplicación para iniciar. Este `Gemfile` es procesado por la gema [Bundler](https://github.com/carlhuda/bundler), que luego instala todas las dependencias. Incluso puede instalar todas las dependencias localmente en su aplicación para que no dependa de las gemas del sistema.

Más información: [Página principal de Bundler](https://bundler.io)

### Vivir al límite

`Bundler` y `Gemfile` hacen que congelar su aplicación Rails sea pan comido con el nuevo comando `bundle` dedicado. Si desea agrupar directamente desde el repositorio Git, puede pasar la bandera `--edge`:

```bash
$ rails new myapp --edge
```

Si tiene una copia local del repositorio de Rails y desea generar una aplicación utilizando eso, puede pasar la bandera `--dev`:

```bash
$ ruby /ruta/a/rails/railties/bin/rails new myapp --dev
```

Funcionalidades principales
---------------------------

[![Rails 4.0](images/4_0_release_notes/rails4_features.png)](https://guides.rubyonrails.org/images/4_0_release_notes/rails4_features.png)

### Actualización

* **Ruby 1.9.3** ([confirmación](https://github.com/rails/rails/commit/a0380e808d3dbd2462df17f5d3b7fcd8bd812496)) - Se prefiere Ruby 2.0; se requiere 1.9.3+
* **[Nueva política de deprecación](https://www.youtube.com/watch?v=z6YgD6tVPQs)** - Las características obsoletas son advertencias en Rails 4.0 y se eliminarán en Rails 4.1.
* **Caché de página y acción de ActionPack** ([confirmación](https://github.com/rails/rails/commit/b0a7068564f0c95e7ef28fc39d0335ed17d93e90)) - La caché de página y acción se extrae a una gema separada. La caché de página y acción requiere demasiada intervención manual (caducar manualmente las cachés cuando se actualizan los objetos de modelo subyacentes). En su lugar, use la caché de muñecas rusas.
* **Observadores de ActiveRecord** ([confirmación](https://github.com/rails/rails/commit/ccecab3ba950a288b61a516bf9b6962e384aae0b)) - Los observadores se extraen a una gema separada. Los observadores solo son necesarios para la caché de página y acción, y pueden generar código espagueti.
* **Almacenamiento de sesión de ActiveRecord** ([confirmación](https://github.com/rails/rails/commit/0ffe19056c8e8b2f9ae9d487b896cad2ce9387ad)) - El almacenamiento de sesión de ActiveRecord se extrae a una gema separada. Almacenar sesiones en SQL es costoso. En su lugar, use sesiones de cookies, sesiones de memcache o un almacenamiento de sesión personalizado.
* **Protección de asignación masiva de ActiveModel** ([confirmación](https://github.com/rails/rails/commit/f8c9a4d3e88181cee644f91e1342bfe896ca64c6)) - La protección de asignación masiva de Rails 3 está obsoleta. En su lugar, use parámetros fuertes.
* **ActiveResource** ([confirmación](https://github.com/rails/rails/commit/f1637bf2bb00490203503fbd943b73406e043d1d)) - ActiveResource se extrae a una gema separada. ActiveResource no se usaba ampliamente.
* **vendor/plugins eliminado** ([confirmación](https://github.com/rails/rails/commit/853de2bd9ac572735fa6cf59fcf827e485a231c3)) - Use un `Gemfile` para administrar las gemas instaladas.

### ActionPack

* **Parámetros fuertes** ([confirmación](https://github.com/rails/rails/commit/a8f6d5c6450a7fe058348a7f10a908352bb6c7fc)) - Solo permita que los parámetros permitidos actualicen objetos de modelo (`params.permit(:title, :text)`).
* **Preocupaciones de enrutamiento** ([confirmación](https://github.com/rails/rails/commit/0dd24728a088fcb4ae616bb5d62734aca5276b1b)) - En el DSL de enrutamiento, factorice subrutas comunes (`comments` de `/posts/1/comments` y `/videos/1/comments`).
* **ActionController::Live** ([confirmación](https://github.com/rails/rails/commit/af0a9f9eefaee3a8120cfd8d05cbc431af376da3)) - Transmita JSON con `response.stream`.
* **ETags declarativos** ([confirmación](https://github.com/rails/rails/commit/ed5c938fa36995f06d4917d9543ba78ed506bb8d)) - Agregue adiciones de etag a nivel de controlador que formarán parte del cálculo de etag de la acción.
* **[Caché de muñecas rusas](https://37signals.com/svn/posts/3113-how-key-based-cache-expiration-works)** ([confirmación](https://github.com/rails/rails/commit/4154bf012d2bec2aae79e4a49aa94a70d3e91d49)) - Almacene en caché fragmentos anidados de vistas. Cada fragmento caduca en función de un conjunto de dependencias (una clave de caché). La clave de caché suele ser un número de versión de plantilla y un objeto de modelo.
* **Turbolinks** ([confirmación](https://github.com/rails/rails/commit/e35d8b18d0649c0ecc58f6b73df6b3c8d0c6bb74)) - Sirva solo una página HTML inicial. Cuando el usuario navega a otra página, use pushState para actualizar la URL y use AJAX para actualizar el título y el cuerpo.
* **Desacoplar ActionView de ActionController** ([confirmación](https://github.com/rails/rails/commit/78b0934dd1bb84e8f093fb8ef95ca99b297b51cd)) - ActionView se desacopló de ActionPack y se moverá a una gema separada en Rails 4.1.
* **No depender de ActiveModel** ([confirmación](https://github.com/rails/rails/commit/166dbaa7526a96fdf046f093f25b0a134b277a68)) - ActionPack ya no depende de ActiveModel.
### General

 * **ActiveModel::Model** ([commit](https://github.com/rails/rails/commit/3b822e91d1a6c4eab0064989bbd07aae3a6d0d08)) - `ActiveModel::Model`, una mezcla para hacer que los objetos normales de Ruby funcionen con ActionPack sin problemas (por ejemplo, para `form_for`).
 * **Nueva API de alcance** ([commit](https://github.com/rails/rails/commit/50cbc03d18c5984347965a94027879623fc44cce)) - Los alcances siempre deben usar funciones llamables.
 * **Volcado de caché de esquema** ([commit](https://github.com/rails/rails/commit/5ca4fc95818047108e69e22d200e7a4a22969477)) - Para mejorar el tiempo de inicio de Rails, en lugar de cargar el esquema directamente desde la base de datos, cargar el esquema desde un archivo de volcado.
 * **Soporte para especificar el nivel de aislamiento de la transacción** ([commit](https://github.com/rails/rails/commit/392eeecc11a291e406db927a18b75f41b2658253)) - Elija si las lecturas repetibles o el rendimiento mejorado (menos bloqueo) son más importantes.
 * **Dalli** ([commit](https://github.com/rails/rails/commit/82663306f428a5bbc90c511458432afb26d2f238)) - Utilice el cliente de memcache Dalli para la tienda de memcache.
 * **Inicio y finalización de notificaciones** ([commit](https://github.com/rails/rails/commit/f08f8750a512f741acb004d0cebe210c5f949f28)) - La instrumentación de Active Support informa las notificaciones de inicio y finalización a los suscriptores.
 * **Seguridad por defecto** ([commit](https://github.com/rails/rails/commit/5d416b907864d99af55ebaa400fff217e17570cd)) - Rails puede ejecutarse en servidores de aplicaciones con hilos sin configuración adicional.

NOTA: Verifique que las gemas que está utilizando sean seguras para hilos.

 * **Verbo PATCH** ([commit](https://github.com/rails/rails/commit/eed9f2539e3ab5a68e798802f464b8e4e95e619e)) - En Rails, PATCH reemplaza a PUT. PATCH se utiliza para actualizaciones parciales de recursos.

### Seguridad

* **match no captura todo** ([commit](https://github.com/rails/rails/commit/90d2802b71a6e89aedfe40564a37bd35f777e541)) - En el DSL de enrutamiento, match requiere que se especifique el verbo o verbos HTTP.
* **Entidades HTML escapadas por defecto** ([commit](https://github.com/rails/rails/commit/5f189f41258b83d49012ec5a0678d827327e7543)) - Las cadenas renderizadas en erb se escapan a menos que se envuelvan con `raw` o se llame a `html_safe`.
* **Nuevas cabeceras de seguridad** ([commit](https://github.com/rails/rails/commit/6794e92b204572d75a07bd6413bdae6ae22d5a82)) - Rails envía las siguientes cabeceras con cada solicitud HTTP: `X-Frame-Options` (evita el clickjacking al prohibir que el navegador incruste la página en un marco), `X-XSS-Protection` (pide al navegador que detenga la inyección de scripts) y `X-Content-Type-Options` (evita que el navegador abra un jpeg como un exe).

Extracción de características a gemas
---------------------------

En Rails 4.0, varias características se han extraído a gemas. Simplemente agregue las gemas extraídas a su `Gemfile` para recuperar la funcionalidad.

* Métodos de búsqueda basados en hash y dinámicos ([GitHub](https://github.com/rails/activerecord-deprecated_finders))
* Protección de asignación masiva en modelos de Active Record ([GitHub](https://github.com/rails/protected_attributes), [Pull Request](https://github.com/rails/rails/pull/7251))
* ActiveRecord::SessionStore ([GitHub](https://github.com/rails/activerecord-session_store), [Pull Request](https://github.com/rails/rails/pull/7436))
* Observadores de Active Record ([GitHub](https://github.com/rails/rails-observers), [Commit](https://github.com/rails/rails/commit/39e85b3b90c58449164673909a6f1893cba290b2))
* Active Resource ([GitHub](https://github.com/rails/activeresource), [Pull Request](https://github.com/rails/rails/pull/572), [Blog](http://yetimedia-blog-blog.tumblr.com/post/35233051627/activeresource-is-dead-long-live-activeresource))
* Caché de acciones ([GitHub](https://github.com/rails/actionpack-action_caching), [Pull Request](https://github.com/rails/rails/pull/7833))
* Caché de páginas ([GitHub](https://github.com/rails/actionpack-page_caching), [Pull Request](https://github.com/rails/rails/pull/7833))
* Sprockets ([GitHub](https://github.com/rails/sprockets-rails))
* Pruebas de rendimiento ([GitHub](https://github.com/rails/rails-perftest), [Pull Request](https://github.com/rails/rails/pull/8876))

Documentación
-------------

* Las guías se han reescrito en Markdown con formato GitHub.

* Las guías tienen un diseño receptivo.

Railties
--------

Consulte el [Registro de cambios](https://github.com/rails/rails/blob/4-0-stable/railties/CHANGELOG.md) para obtener cambios detallados.

### Cambios destacados

* Nuevas ubicaciones de pruebas `test/models`, `test/helpers`, `test/controllers` y `test/mailers`. También se agregaron tareas de rake correspondientes. ([Pull Request](https://github.com/rails/rails/pull/7878))

* Los ejecutables de su aplicación ahora se encuentran en el directorio `bin/`. Ejecute `rake rails:update:bin` para obtener `bin/bundle`, `bin/rails` y `bin/rake`.

* Seguridad por defecto

* Se ha eliminado la capacidad de usar un constructor personalizado pasando `--builder` (o `-b`) a `rails new`. Considere usar plantillas de aplicación en su lugar. ([Pull Request](https://github.com/rails/rails/pull/9401))

### Deprecaciones

* `config.threadsafe!` está en desuso a favor de `config.eager_load`, que proporciona un control más detallado sobre qué se carga de forma anticipada.

* `Rails::Plugin` ha desaparecido. En lugar de agregar complementos a `vendor/plugins`, use gemas o bundler con dependencias de ruta o git.

Action Mailer
-------------

Consulte el [Registro de cambios](https://github.com/rails/rails/blob/4-0-stable/actionmailer/CHANGELOG.md) para obtener cambios detallados.

### Cambios destacados

### Deprecaciones

Active Model
------------

Consulte el [Registro de cambios](https://github.com/rails/rails/blob/4-0-stable/activemodel/CHANGELOG.md) para obtener cambios detallados.

### Cambios destacados

* Agregue `ActiveModel::ForbiddenAttributesProtection`, un módulo simple para proteger los atributos de la asignación masiva cuando se pasan atributos no permitidos.

* Se agregó `ActiveModel::Model`, una mezcla para hacer que los objetos de Ruby funcionen con Action Pack sin problemas.

### Deprecaciones

Active Support
--------------

Consulte el [Registro de cambios](https://github.com/rails/rails/blob/4-0-stable/activesupport/CHANGELOG.md) para obtener cambios detallados.

### Cambios destacados

* Reemplace la gema `memcache-client` obsoleta por `dalli` en `ActiveSupport::Cache::MemCacheStore`.

* Optimice `ActiveSupport::Cache::Entry` para reducir la memoria y la sobrecarga de procesamiento.

* Las inflexiones ahora se pueden definir por localidad. `singularize` y `pluralize` aceptan la localidad como un argumento adicional.

* `Object#try` ahora devolverá nil en lugar de generar un NoMethodError si el objeto receptor no implementa el método, pero aún puede obtener el comportamiento anterior utilizando el nuevo `Object#try!`.
* `String#to_date` ahora lanza `ArgumentError: invalid date` en lugar de `NoMethodError: undefined method 'div' for nil:NilClass` cuando se le proporciona una fecha inválida. Ahora es igual que `Date.parse` y acepta más fechas inválidas que en la versión 3.x, como:

    ```ruby
    # ActiveSupport 3.x
    "asdf".to_date # => NoMethodError: undefined method `div' for nil:NilClass
    "333".to_date # => NoMethodError: undefined method `div' for nil:NilClass

    # ActiveSupport 4
    "asdf".to_date # => ArgumentError: invalid date
    "333".to_date # => Fri, 29 Nov 2013
    ```

### Deprecaciones

* Se deprecia el método `ActiveSupport::TestCase#pending`, en su lugar se debe usar `skip` de minitest.

* `ActiveSupport::Benchmarkable#silence` ha sido deprecado debido a su falta de seguridad en hilos. Será eliminado sin reemplazo en Rails 4.1.

* `ActiveSupport::JSON::Variable` está deprecado. Define tus propios métodos `#as_json` y `#encode_json` para literales de cadena JSON personalizados.

* Se deprecia el método de compatibilidad `Module#local_constant_names`, en su lugar se debe usar `Module#local_constants` (que devuelve símbolos).

* `ActiveSupport::BufferedLogger` está deprecado. Usa `ActiveSupport::Logger` o el registro de la biblioteca estándar de Ruby.

* Se deprecia `assert_present` y `assert_blank` en favor de `assert object.blank?` y `assert object.present?`

Action Pack
-----------

Consulta el [Changelog](https://github.com/rails/rails/blob/4-0-stable/actionpack/CHANGELOG.md) para obtener cambios detallados.

### Cambios destacados

* Cambia la hoja de estilos de las páginas de excepción para el modo de desarrollo. Además, muestra también la línea de código y el fragmento que generó la excepción en todas las páginas de excepción.

### Deprecaciones


Active Record
-------------

Consulta el [Changelog](https://github.com/rails/rails/blob/4-0-stable/activerecord/CHANGELOG.md) para obtener cambios detallados.

### Cambios destacados

* Mejora las formas de escribir migraciones `change`, haciendo que los antiguos métodos `up` y `down` ya no sean necesarios.

    * Los métodos `drop_table` y `remove_column` ahora son reversibles, siempre y cuando se proporcione la información necesaria.
      El método `remove_column` solía aceptar múltiples nombres de columna; en su lugar, usa `remove_columns` (que no es reversible).
      El método `change_table` también es reversible, siempre y cuando su bloque no llame a `remove`, `change` o `change_default`.

    * El nuevo método `reversible` permite especificar código que se ejecutará al migrar hacia arriba o hacia abajo.
      Consulta la [Guía de migraciones](https://github.com/rails/rails/blob/main/guides/source/active_record_migrations.md#using-reversible)

    * El nuevo método `revert` revertirá una migración completa o el bloque dado.
      Si se está migrando hacia abajo, la migración/bloque dado se ejecutará normalmente.
      Consulta la [Guía de migraciones](https://github.com/rails/rails/blob/main/guides/source/active_record_migrations.md#reverting-previous-migrations)

* Agrega soporte para el tipo de array de PostgreSQL. Se puede utilizar cualquier tipo de dato para crear una columna de array, con soporte completo de migración y volcado de esquema.

* Agrega `Relation#load` para cargar explícitamente el registro y devolver `self`.

* `Model.all` ahora devuelve una `ActiveRecord::Relation`, en lugar de un array de registros. Usa `Relation#to_a` si realmente quieres un array. En algunos casos específicos, esto puede causar problemas al actualizar.

* Se agregó `ActiveRecord::Migration.check_pending!` que genera un error si hay migraciones pendientes.

* Se agregó soporte para codificadores personalizados en `ActiveRecord::Store`. Ahora puedes configurar tu codificador personalizado de la siguiente manera:

        store :settings, accessors: [ :color, :homepage ], coder: JSON

* Las conexiones `mysql` y `mysql2` establecerán `SQL_MODE=STRICT_ALL_TABLES` de forma predeterminada para evitar la pérdida silenciosa de datos. Esto se puede desactivar especificando `strict: false` en tu `database.yml`.

* Se eliminó IdentityMap.

* Se eliminó la ejecución automática de consultas EXPLAIN. La opción `active_record.auto_explain_threshold_in_seconds` ya no se utiliza y se debe eliminar.

* Se agregó `ActiveRecord::NullRelation` y `ActiveRecord::Relation#none` implementando el patrón de objeto nulo para la clase Relation.

* Se agregó el ayudante de migración `create_join_table` para crear tablas de unión HABTM.

* Permite crear registros hstore de PostgreSQL.

### Deprecaciones

* Se deprecó la API de búsqueda basada en hash de estilo antiguo. Esto significa que los métodos que anteriormente aceptaban "opciones de búsqueda" ya no lo hacen.

* Todos los métodos dinámicos, excepto `find_by_...` y `find_by_...!`, están deprecados. Así es como puedes reescribir el código:

      * `find_all_by_...` se puede reescribir usando `where(...)`.
      * `find_last_by_...` se puede reescribir usando `where(...).last`.
      * `scoped_by_...` se puede reescribir usando `where(...)`.
      * `find_or_initialize_by_...` se puede reescribir usando `find_or_initialize_by(...)`.
      * `find_or_create_by_...` se puede reescribir usando `find_or_create_by(...)`.
      * `find_or_create_by_...!` se puede reescribir usando `find_or_create_by!(...)`.

Créditos
-------
Consulta la [lista completa de colaboradores de Rails](https://contributors.rubyonrails.org/) para conocer a las muchas personas que dedicaron muchas horas para hacer de Rails el marco estable y robusto que es. Felicitaciones a todos ellos.
