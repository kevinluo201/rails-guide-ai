**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 95d91c83726e012162afc60c78688099
Ruby on Rails 4.1 Notas de la versión
=====================================

Aspectos destacados en Rails 4.1:

* Precargador de aplicaciones Spring
* `config/secrets.yml`
* Variantes de Action Pack
* Previsualizaciones de Action Mailer

Estas notas de la versión solo cubren los cambios principales. Para conocer las diversas correcciones de errores y cambios, consulte los registros de cambios o revise la [lista de confirmaciones](https://github.com/rails/rails/commits/4-1-stable) en el repositorio principal de Rails en GitHub.

--------------------------------------------------------------------------------

Actualización a Rails 4.1
-------------------------

Si está actualizando una aplicación existente, es una buena idea tener una buena cobertura de pruebas antes de comenzar. También debe actualizar primero a Rails 4.0 en caso de que no lo haya hecho y asegurarse de que su aplicación siga funcionando como se espera antes de intentar una actualización a Rails 4.1. Una lista de cosas a tener en cuenta al actualizar está disponible en la guía [Actualización de Ruby on Rails](upgrading_ruby_on_rails.html#upgrading-from-rails-4-0-to-rails-4-1).

Funciones principales
--------------------

### Precargador de aplicaciones Spring

Spring es un precargador de aplicaciones Rails. Acelera el desarrollo al mantener su aplicación en ejecución en segundo plano para que no tenga que iniciarla cada vez que ejecuta una prueba, tarea de rake o migración.

Las nuevas aplicaciones Rails 4.1 se enviarán con binstubs "springificados". Esto significa que `bin/rails` y `bin/rake` aprovecharán automáticamente los entornos de spring precargados.

**Ejecutar tareas de rake:**

```bash
$ bin/rake test:models
```

**Ejecutar un comando de Rails:**

```bash
$ bin/rails console
```

**Introspección de Spring:**

```bash
$ bin/spring status
Spring se está ejecutando:

 1182 spring server | my_app | iniciado hace 29 minutos
 3656 spring app    | my_app | iniciado hace 23 segundos | modo de prueba
 3746 spring app    | my_app | iniciado hace 10 segundos | modo de desarrollo
```

Eche un vistazo al [README de Spring](https://github.com/rails/spring/blob/master/README.md) para ver todas las características disponibles.

Consulte la guía [Actualización de Ruby on Rails](upgrading_ruby_on_rails.html#spring) sobre cómo migrar aplicaciones existentes para usar esta función.

### `config/secrets.yml`

Rails 4.1 genera un nuevo archivo `secrets.yml` en la carpeta `config`. Por defecto, este archivo contiene la `secret_key_base` de la aplicación, pero también se puede utilizar para almacenar otros secretos como claves de acceso para API externas.

Los secretos agregados a este archivo son accesibles a través de `Rails.application.secrets`. Por ejemplo, con el siguiente `config/secrets.yml`:

```yaml
development:
  secret_key_base: 3b7cd727ee24e8444053437c36cc66c3
  some_api_key: SOMEKEY
```

`Rails.application.secrets.some_api_key` devuelve `SOMEKEY` en el entorno de desarrollo.

Consulte la guía [Actualización de Ruby on Rails](upgrading_ruby_on_rails.html#config-secrets-yml) sobre cómo migrar aplicaciones existentes para usar esta función.

### Variantes de Action Pack

A menudo queremos renderizar diferentes plantillas HTML/JSON/XML para teléfonos, tabletas y navegadores de escritorio. Las variantes lo hacen fácil.

La variante de la solicitud es una especialización del formato de la solicitud, como `:tablet`, `:phone` o `:desktop`.

Puede establecer la variante en un `before_action`:

```ruby
request.variant = :tablet if request.user_agent =~ /iPad/
```

Responda a las variantes en la acción de la misma manera que responde a los formatos:

```ruby
respond_to do |format|
  format.html do |html|
    html.tablet # renderiza app/views/projects/show.html+tablet.erb
    html.phone { extra_setup; render ... }
  end
end
```

Proporcione plantillas separadas para cada formato y variante:

```
app/views/projects/show.html.erb
app/views/projects/show.html+tablet.erb
app/views/projects/show.html+phone.erb
```

También puede simplificar la definición de variantes utilizando la sintaxis en línea:

```ruby
respond_to do |format|
  format.js         { render "trash" }
  format.html.phone { redirect_to progress_path }
  format.html.none  { render "trash" }
end
```

### Previsualizaciones de Action Mailer

Las previsualizaciones de Action Mailer proporcionan una forma de ver cómo se ven los correos electrónicos visitando una URL especial que los renderiza.

Implemente una clase de previsualización cuyos métodos devuelvan el objeto de correo que desea verificar:

```ruby
class NotifierPreview < ActionMailer::Preview
  def welcome
    Notifier.welcome(User.first)
  end
end
```

La previsualización está disponible en http://localhost:3000/rails/mailers/notifier/welcome, y una lista de ellas en http://localhost:3000/rails/mailers.

De forma predeterminada, estas clases de previsualización se encuentran en `test/mailers/previews`. Esto se puede configurar utilizando la opción `preview_path`.

Consulte su [documentación](https://api.rubyonrails.org/v4.1.0/classes/ActionMailer/Base.html#class-ActionMailer::Base-label-Previewing+emails) para obtener una descripción detallada.

### Enumeraciones de Active Record

Declare un atributo de enumeración donde los valores se asignen a enteros en la base de datos, pero se puedan consultar por nombre.

```ruby
class Conversation < ActiveRecord::Base
  enum status: [ :active, :archived ]
end

conversation.archived!
conversation.active? # => false
conversation.status  # => "archived"

Conversation.archived # => Relación de todas las Conversaciones archivadas

Conversation.statuses # => { "active" => 0, "archived" => 1 }
```

Consulte su [documentación](https://api.rubyonrails.org/v4.1.0/classes/ActiveRecord/Enum.html) para obtener una descripción detallada.

### Verificadores de mensajes

Los verificadores de mensajes se pueden utilizar para generar y verificar mensajes firmados. Esto puede ser útil para transportar de forma segura datos sensibles como tokens de recordatorio y amigos.

El método `Rails.application.message_verifier` devuelve un nuevo verificador de mensajes que firma mensajes con una clave derivada de `secret_key_base` y el nombre del verificador de mensajes dado:
```ruby
signed_token = Rails.application.message_verifier(:remember_me).generate(token)
Rails.application.message_verifier(:remember_me).verify(signed_token) # => token

Rails.application.message_verifier(:remember_me).verify(tampered_token)
# raises ActiveSupport::MessageVerifier::InvalidSignature
```

### Module#concerning

Una forma natural y sencilla de separar responsabilidades dentro de una clase:

```ruby
class Todo < ActiveRecord::Base
  concerning :EventTracking do
    included do
      has_many :events
    end

    def latest_event
      # ...
    end

    private
      def some_internal_method
        # ...
      end
  end
end
```

Este ejemplo es equivalente a definir un módulo `EventTracking` en línea,
extenderlo con `ActiveSupport::Concern` y luego mezclarlo en la clase `Todo`.

Consulte su
[documentación](https://api.rubyonrails.org/v4.1.0/classes/Module/Concerning.html)
para obtener una descripción detallada y los casos de uso previstos.

### Protección CSRF desde etiquetas `<script>` remotas

La protección contra falsificación de solicitudes entre sitios (CSRF) ahora cubre las solicitudes GET con respuestas JavaScript. Esto evita que un sitio de terceros haga referencia a su URL de JavaScript e intente ejecutarla para extraer datos sensibles.

Esto significa que cualquier prueba que acceda a URLs `.js` ahora fallará la protección CSRF a menos que use `xhr`. Actualice sus pruebas para que sean explícitas al esperar XmlHttpRequests. En lugar de `post :create, format: :js`, cambie a `xhr :post, :create, format: :js`.


Railties
--------

Consulte el
[registro de cambios](https://github.com/rails/rails/blob/4-1-stable/railties/CHANGELOG.md)
para obtener cambios detallados.

### Eliminaciones

* Se eliminó la tarea rake `update:application_controller`.

* Se eliminó `Rails.application.railties.engines`, que estaba en desuso.

* Se eliminó `threadsafe!` de Rails Config, que estaba en desuso.

* Se eliminó `ActiveRecord::Generators::ActiveModel#update_attributes`, que estaba en desuso, en favor de `ActiveRecord::Generators::ActiveModel#update`.

* Se eliminó la opción `config.whiny_nils`, que estaba en desuso.

* Se eliminaron las tareas rake en desuso para ejecutar pruebas: `rake test:uncommitted` y `rake test:recent`.

### Cambios destacados

* El pre-cargador de aplicaciones [Spring](https://github.com/rails/spring) ahora se instala de forma predeterminada en las nuevas aplicaciones. Utiliza el grupo de desarrollo del `Gemfile`, por lo que no se instalará en producción. ([Pull Request](https://github.com/rails/rails/pull/12958))

* `BACKTRACE` es una variable de entorno que muestra trazas sin filtrar para fallas en las pruebas. ([Commit](https://github.com/rails/rails/commit/84eac5dab8b0fe9ee20b51250e52ad7bfea36553))

* Se expuso `MiddlewareStack#unshift` para la configuración del entorno. ([Pull Request](https://github.com/rails/rails/pull/12479))

* Se agregó el método `Application#message_verifier` para devolver un verificador de mensajes. ([Pull Request](https://github.com/rails/rails/pull/12995))

* El archivo `test_help.rb`, que es requerido por el ayudante de prueba generado por defecto, mantendrá automáticamente su base de datos de prueba actualizada con `db/schema.rb` (o `db/structure.sql`). Generará un error si volver a cargar el esquema no resuelve todas las migraciones pendientes. Desactive esto con `config.active_record.maintain_test_schema = false`. ([Pull Request](https://github.com/rails/rails/pull/13528))

* Se introdujo `Rails.gem_version` como un método de conveniencia para devolver `Gem::Version.new(Rails.version)`, sugiriendo una forma más confiable de realizar comparaciones de versiones. ([Pull Request](https://github.com/rails/rails/pull/14103))


Action Pack
-----------

Consulte el
[registro de cambios](https://github.com/rails/rails/blob/4-1-stable/actionpack/CHANGELOG.md)
para obtener cambios detallados.

### Eliminaciones

* Se eliminó la funcionalidad obsoleta de fallback de la aplicación Rails para las pruebas de integración, en su lugar, configure `ActionDispatch.test_app`.

* Se eliminó la configuración obsoleta `page_cache_extension`.

* Se eliminaron las constantes obsoletas de Action Controller:

| Eliminado                           | Sucesor                         |
|:-----------------------------------|:--------------------------------|
| ActionController::AbstractRequest  | ActionDispatch::Request         |
| ActionController::Request          | ActionDispatch::Request         |
| ActionController::AbstractResponse | ActionDispatch::Response        |
| ActionController::Response         | ActionDispatch::Response        |
| ActionController::Routing          | ActionDispatch::Routing         |
| ActionController::Integration      | ActionDispatch::Integration     |
| ActionController::IntegrationTest  | ActionDispatch::IntegrationTest |

### Cambios destacados

* `protect_from_forgery` también evita las etiquetas `<script>` de origen cruzado. Actualice sus pruebas para usar `xhr :get, :foo, format: :js` en lugar de `get :foo, format: :js`. ([Pull Request](https://github.com/rails/rails/pull/13345))

* `#url_for` ahora toma un hash con opciones dentro de un array. ([Pull Request](https://github.com/rails/rails/pull/9599))

* Se agregó el método `session#fetch`, que se comporta de manera similar a [Hash#fetch](https://www.ruby-doc.org/core-1.9.3/Hash.html#method-i-fetch), con la excepción de que el valor devuelto siempre se guarda en la sesión. ([Pull Request](https://github.com/rails/rails/pull/12692))

* Se separó completamente Action View de Action Pack. ([Pull Request](https://github.com/rails/rails/pull/11032))

* Se registra qué claves se ven afectadas por la manipulación profunda. ([Pull Request](https://github.com/rails/rails/pull/13813))

* Nueva opción de configuración `config.action_dispatch.perform_deep_munge` para optar por no realizar la "manipulación profunda" de los parámetros que se utilizó para abordar la vulnerabilidad de seguridad CVE-2013-0155. ([Pull Request](https://github.com/rails/rails/pull/13188))

* Nueva opción de configuración `config.action_dispatch.cookies_serializer` para especificar un serializador para los tarros de cookies firmados y encriptados. (Pull Requests [1](https://github.com/rails/rails/pull/13692), [2](https://github.com/rails/rails/pull/13945) / [Más detalles](upgrading_ruby_on_rails.html#cookies-serializer))

* Se agregaron `render :plain`, `render :html` y `render :body`. ([Pull Request](https://github.com/rails/rails/pull/14062) / [Más detalles](upgrading_ruby_on_rails.html#rendering-content-from-string))


Action Mailer
-------------

Consulte el
[registro de cambios](https://github.com/rails/rails/blob/4-1-stable/actionmailer/CHANGELOG.md)
para obtener cambios detallados.

### Cambios destacados

* Se agregó la función de vistas previas de correo basada en la gema mail_view de 37 Signals. ([Commit](https://github.com/rails/rails/commit/d6dec7fcb6b8fddf8c170182d4fe64ecfc7b2261))

* Se instrumenta la generación de mensajes de Action Mailer. El tiempo que lleva generar un mensaje se registra en el registro. ([Pull Request](https://github.com/rails/rails/pull/12556))


Active Record
-------------

Consulte el
[registro de cambios](https://github.com/rails/rails/blob/4-1-stable/activerecord/CHANGELOG.md)
para obtener cambios detallados.

### Eliminaciones

* Se eliminó la funcionalidad obsoleta de pasar `nil` a los siguientes métodos de `SchemaCache`: `primary_keys`, `tables`, `columns` y `columns_hash`.

* Se eliminó el filtro de bloque obsoleto de `ActiveRecord::Migrator#migrate`.

* Se eliminó el constructor de cadena obsoleto de `ActiveRecord::Migrator`.

* Se eliminó el uso obsoleto de `scope` sin pasar un objeto invocable.

* Se eliminó `transaction_joinable=` en favor de `begin_transaction` con la opción `:joinable`.

* Se eliminó `decrement_open_transactions`, que estaba en desuso.

* Se eliminó `increment_open_transactions`, que estaba en desuso.
* Se eliminó el método `PostgreSQLAdapter#outside_transaction?` obsoleto. Ahora puedes usar `#transaction_open?` en su lugar.

* Se eliminó el método obsoleto `ActiveRecord::Fixtures.find_table_name` a favor de `ActiveRecord::Fixtures.default_fixture_model_name`.

* Se eliminó el método `columns_for_remove` obsoleto de `SchemaStatements`.

* Se eliminó el método obsoleto `SchemaStatements#distinct`.

* Se movió la clase `ActiveRecord::TestCase` obsoleta al conjunto de pruebas de Rails. La clase ya no es pública y solo se utiliza para pruebas internas de Rails.

* Se eliminó el soporte para la opción obsoleta `:restrict` para `:dependent` en las asociaciones.

* Se eliminó el soporte para las opciones obsoletas `:delete_sql`, `:insert_sql`, `:finder_sql` y `:counter_sql` en las asociaciones.

* Se eliminó el método obsoleto `type_cast_code` de Column.

* Se eliminó el método obsoleto `ActiveRecord::Base#connection`. Asegúrate de acceder a él a través de la clase.

* Se eliminó la advertencia de deprecación para `auto_explain_threshold_in_seconds`.

* Se eliminó la opción obsoleta `:distinct` de `Relation#count`.

* Se eliminaron los métodos obsoletos `partial_updates`, `partial_updates?` y `partial_updates=`.

* Se eliminó el método obsoleto `scoped`.

* Se eliminó el método obsoleto `default_scopes?`.

* Se eliminaron las referencias de unión implícitas que se volvieron obsoletas en la versión 4.0.

* Se eliminó `activerecord-deprecated_finders` como dependencia. Consulta [el archivo README de la gema](https://github.com/rails/activerecord-deprecated_finders#active-record-deprecated-finders) para obtener más información.

* Se eliminó el uso de `implicit_readonly`. Ahora debes usar el método `readonly` explícitamente para marcar los registros como "solo lectura". ([Pull Request](https://github.com/rails/rails/pull/10769))

### Deprecaciones

* Se deprecó el método `quoted_locking_column`, que no se utiliza en ningún lugar.

* Se deprecó `ConnectionAdapters::SchemaStatements#distinct`, ya que ya no se utiliza internamente. ([Pull Request](https://github.com/rails/rails/pull/10556))

* Se deprecó las tareas `rake db:test:*`, ya que la base de datos de pruebas ahora se mantiene automáticamente. Consulta las notas de la versión de Railties. ([Pull Request](https://github.com/rails/rails/pull/13528))

* Se deprecia `ActiveRecord::Base.symbolized_base_class` y `ActiveRecord::Base.symbolized_sti_name`, que no se utilizan y no tienen reemplazo. [Commit](https://github.com/rails/rails/commit/97e7ca48c139ea5cce2fa9b4be631946252a1ebd)

### Cambios destacados

* Las scopes predeterminadas ya no se anulan por condiciones encadenadas.

  Antes de este cambio, cuando definías una `default_scope` en un modelo, se anulaba por condiciones encadenadas en el mismo campo. Ahora se fusiona como cualquier otra scope. [Más detalles](upgrading_ruby_on_rails.html#changes-on-default-scopes).

* Se agregó `ActiveRecord::Base.to_param` para obtener URL "bonitas" derivadas de un atributo o método del modelo. ([Pull Request](https://github.com/rails/rails/pull/12891))

* Se agregó `ActiveRecord::Base.no_touching`, que permite ignorar el "touch" en los modelos. ([Pull Request](https://github.com/rails/rails/pull/12772))

* Se unificó la conversión de tipo booleano para `MysqlAdapter` y `Mysql2Adapter`. `type_cast` devolverá `1` para `true` y `0` para `false`. ([Pull Request](https://github.com/rails/rails/pull/12425))

* `.unscope` ahora elimina las condiciones especificadas en `default_scope`. ([Commit](https://github.com/rails/rails/commit/94924dc32baf78f13e289172534c2e71c9c8cade))

* Se agregó `ActiveRecord::QueryMethods#rewhere`, que sobrescribe una condición `where` existente con nombre. ([Commit](https://github.com/rails/rails/commit/f950b2699f97749ef706c6939a84dfc85f0b05f2))

* Se amplió `ActiveRecord::Base#cache_key` para aceptar una lista opcional de atributos de marca de tiempo, de los cuales se utilizará el más alto. ([Commit](https://github.com/rails/rails/commit/e94e97ca796c0759d8fcb8f946a3bbc60252d329))

* Se agregó `ActiveRecord::Base#enum` para declarar atributos de enumeración donde los valores se mapean a enteros en la base de datos, pero se pueden consultar por nombre. ([Commit](https://github.com/rails/rails/commit/db41eb8a6ea88b854bf5cd11070ea4245e1639c5))

* Se convierten los valores JSON al escribirlos, para que el valor sea coherente con la lectura desde la base de datos. ([Pull Request](https://github.com/rails/rails/pull/12643))

* Se convierten los valores hstore al escribirlos, para que el valor sea coherente con la lectura desde la base de datos. ([Commit](https://github.com/rails/rails/commit/5ac2341fab689344991b2a4817bd2bc8b3edac9d))

* Se hace accesible `next_migration_number` para generadores de terceros. ([Pull Request](https://github.com/rails/rails/pull/12407))

* Llamar a `update_attributes` ahora lanzará un `ArgumentError` si recibe un argumento `nil`. Específicamente, lanzará un error si el argumento que se le pasa no responde a `stringify_keys`. ([Pull Request](https://github.com/rails/rails/pull/9860))

* `CollectionAssociation#first`/`#last` (por ejemplo, `has_many`) utiliza una consulta con `LIMIT` para obtener resultados en lugar de cargar toda la colección. ([Pull Request](https://github.com/rails/rails/pull/12137))

* `inspect` en las clases de modelo de Active Record ya no inicia una nueva conexión. Esto significa que llamar a `inspect`, cuando falta la base de datos, ya no generará una excepción. ([Pull Request](https://github.com/rails/rails/pull/11014))

* Se eliminaron las restricciones de columna para `count`, dejando que la base de datos genere un error si el SQL es inválido. ([Pull Request](https://github.com/rails/rails/pull/10710))

* Rails ahora detecta automáticamente las asociaciones inversas. Si no estableces la opción `:inverse_of` en la asociación, Active Record adivinará la asociación inversa en función de heurísticas. ([Pull Request](https://github.com/rails/rails/pull/10886))

* Se manejan los atributos con alias en ActiveRecord::Relation. Al usar claves de símbolos, ActiveRecord ahora traducirá los nombres de atributos con alias al nombre de columna real utilizado en la base de datos. ([Pull Request](https://github.com/rails/rails/pull/7839))

* El ERB en los archivos de fixtures ya no se evalúa en el contexto del objeto principal. Los métodos auxiliares utilizados por varias fixtures deben definirse en módulos incluidos en `ActiveRecord::FixtureSet.context_class`. ([Pull Request](https://github.com/rails/rails/pull/13022))

* No se crea ni se elimina la base de datos de pruebas si se especifica explícitamente RAILS_ENV. ([Pull Request](https://github.com/rails/rails/pull/13629))

* `Relation` ya no tiene métodos mutadores como `#map!` y `#delete_if`. Conviértelo en un `Array` llamando a `#to_a` antes de usar estos métodos. ([Pull Request](https://github.com/rails/rails/pull/13314))

* `find_in_batches`, `find_each`, `Result#each` y `Enumerable#index_by` ahora devuelven un `Enumerator` que puede calcular su tamaño. ([Pull Request](https://github.com/rails/rails/pull/13938))

* `scope`, `enum` y las asociaciones ahora generan un error en caso de conflictos de nombres "peligrosos". ([Pull Request](https://github.com/rails/rails/pull/13450), [Pull Request](https://github.com/rails/rails/pull/13896))

* Los métodos `second` a `fifth` actúan como el buscador `first`. ([Pull Request](https://github.com/rails/rails/pull/13757))

* `touch` ahora activa los callbacks `after_commit` y `after_rollback`. ([Pull Request](https://github.com/rails/rails/pull/12031))
* Habilitar índices parciales para `sqlite >= 3.8.0`.
  ([Pull Request](https://github.com/rails/rails/pull/13350))

* Hacer que `change_column_null` sea reversible. ([Commit](https://github.com/rails/rails/commit/724509a9d5322ff502aefa90dd282ba33a281a96))

* Se agregó una bandera para deshabilitar la generación del esquema después de la migración. Esto está configurado en `false` de forma predeterminada en el entorno de producción para nuevas aplicaciones. ([Pull Request](https://github.com/rails/rails/pull/13948))

Active Model
------------

Consulte el
[Registro de cambios](https://github.com/rails/rails/blob/4-1-stable/activemodel/CHANGELOG.md)
para obtener cambios detallados.

### Deprecaciones

* Se deprecó `Validator#setup`. Ahora esto debe hacerse manualmente en el constructor del validador. ([Commit](https://github.com/rails/rails/commit/7d84c3a2f7ede0e8d04540e9c0640de7378e9b3a))

### Cambios destacados

* Se agregaron nuevos métodos de API `reset_changes` y `changes_applied` a `ActiveModel::Dirty` que controlan el estado de los cambios.

* Posibilidad de especificar múltiples contextos al definir una validación. ([Pull Request](https://github.com/rails/rails/pull/13754))

* `attribute_changed?` ahora acepta un hash para verificar si el atributo cambió `:from` y/o `:to` un valor dado. ([Pull Request](https://github.com/rails/rails/pull/13131))


Active Support
--------------

Consulte el
[Registro de cambios](https://github.com/rails/rails/blob/4-1-stable/activesupport/CHANGELOG.md)
para obtener cambios detallados.


### Eliminaciones

* Se eliminó la dependencia de `MultiJSON`. Como resultado, `ActiveSupport::JSON.decode` ya no acepta un hash de opciones para `MultiJSON`. ([Pull Request](https://github.com/rails/rails/pull/10576) / [Más detalles](upgrading_ruby_on_rails.html#changes-in-json-handling))

* Se eliminó el soporte para el gancho `encode_json` utilizado para codificar objetos personalizados en JSON. Esta función se ha extraído al [activesupport-json_encoder](https://github.com/rails/activesupport-json_encoder) gem.
  ([Pull Request relacionado](https://github.com/rails/rails/pull/12183) /
  [Más detalles](upgrading_ruby_on_rails.html#changes-in-json-handling))

* Se eliminó `ActiveSupport::JSON::Variable` deprecado sin reemplazo.

* Se eliminaron las extensiones de núcleo `String#encoding_aware?` (`core_ext/string/encoding`) deprecadas.

* Se eliminó `DateTime.local_offset` deprecado en favor de `DateTime.civil_from_format`.

* Se eliminaron las extensiones de núcleo `Logger` deprecadas (`core_ext/logger.rb`).

* Se eliminaron `Time#time_with_datetime_fallback`, `Time#utc_time` y `Time#local_time` deprecados en favor de `Time#utc` y `Time#local`.

* Se eliminó `Hash#diff` deprecado sin reemplazo.

* Se eliminó `Date#to_time_in_current_zone` deprecado en favor de `Date#in_time_zone`.

* Se eliminó `Proc#bind` deprecado sin reemplazo.

* Se eliminaron `Array#uniq_by` y `Array#uniq_by!` deprecados, use `Array#uniq` y `Array#uniq!` nativos en su lugar.

* Se eliminó `ActiveSupport::BasicObject` deprecado, use `ActiveSupport::ProxyObject` en su lugar.

* Se eliminó `BufferedLogger` deprecado, use `ActiveSupport::Logger` en su lugar.

* Se eliminaron los métodos `assert_present` y `assert_blank`, use `assert object.blank?` y `assert object.present?` en su lugar.

* Se eliminó el método `#filter` deprecado para objetos de filtro, use el método correspondiente en su lugar (por ejemplo, `#before` para un filtro antes).

* Se eliminó la irregular inflexión 'cow' => 'kine' de las inflexiones predeterminadas. ([Commit](https://github.com/rails/rails/commit/c300dca9963bda78b8f358dbcb59cabcdc5e1dc9))

### Deprecaciones

* Se deprecó `Numeric#{ago,until,since,from_now}`, se espera que el usuario convierta explícitamente el valor en un AS::Duration, es decir, `5.ago` => `5.seconds.ago` ([Pull Request](https://github.com/rails/rails/pull/12389))

* Se deprecó la ruta de requerimiento `active_support/core_ext/object/to_json`. En su lugar, requiera `active_support/core_ext/object/json`. ([Pull Request](https://github.com/rails/rails/pull/12203))

* Se deprecó `ActiveSupport::JSON::Encoding::CircularReferenceError`. Esta función se ha extraído al [activesupport-json_encoder](https://github.com/rails/activesupport-json_encoder) gem.
  ([Pull Request](https://github.com/rails/rails/pull/12785) /
  [Más detalles](upgrading_ruby_on_rails.html#changes-in-json-handling))

* Se deprecó la opción `ActiveSupport.encode_big_decimal_as_string`. Esta función se ha extraído al [activesupport-json_encoder](https://github.com/rails/activesupport-json_encoder) gem.
  ([Pull Request](https://github.com/rails/rails/pull/13060) /
  [Más detalles](upgrading_ruby_on_rails.html#changes-in-json-handling))

* Se deprecó la serialización personalizada de `BigDecimal`. ([Pull Request](https://github.com/rails/rails/pull/13911))

### Cambios destacados

* El codificador JSON de `ActiveSupport` se ha reescrito para aprovechar la gema JSON en lugar de realizar una codificación personalizada en Ruby puro.
  ([Pull Request](https://github.com/rails/rails/pull/12183) /
  [Más detalles](upgrading_ruby_on_rails.html#changes-in-json-handling))

* Mejorada la compatibilidad con la gema JSON.
  ([Pull Request](https://github.com/rails/rails/pull/12862) /
  [Más detalles](upgrading_ruby_on_rails.html#changes-in-json-handling))

* Se agregaron los métodos `ActiveSupport::Testing::TimeHelpers#travel` y `#travel_to`. Estos métodos cambian la hora actual a la hora o duración especificada mediante la simulación de `Time.now` y `Date.today`.

* Se agregó `ActiveSupport::Testing::TimeHelpers#travel_back`. Este método devuelve la hora actual a su estado original, eliminando las simulaciones agregadas por `travel` y `travel_to`. ([Pull Request](https://github.com/rails/rails/pull/13884))

* Se agregó `Numeric#in_milliseconds`, como `1.hour.in_milliseconds`, para poder usarlo en funciones de JavaScript como `getTime()`. ([Commit](https://github.com/rails/rails/commit/423249504a2b468d7a273cbe6accf4f21cb0e643))

* Se agregaron los métodos `Date#middle_of_day`, `DateTime#middle_of_day` y `Time#middle_of_day`. También se agregaron `midday`, `noon`, `at_midday`, `at_noon` y `at_middle_of_day` como alias. ([Pull Request](https://github.com/rails/rails/pull/10879))

* Se agregaron `Date#all_week/month/quarter/year` para generar rangos de fechas. ([Pull Request](https://github.com/rails/rails/pull/9685))

* Se agregaron `Time.zone.yesterday` y `Time.zone.tomorrow`. ([Pull Request](https://github.com/rails/rails/pull/12822))

* Se agregó `String#remove(pattern)` como una forma abreviada del patrón común de `String#gsub(pattern,'')`. ([Commit](https://github.com/rails/rails/commit/5da23a3f921f0a4a3139495d2779ab0d3bd4cb5f))

* Se agregaron `Hash#compact` y `Hash#compact!` para eliminar elementos con valor nulo de un hash. ([Pull Request](https://github.com/r
