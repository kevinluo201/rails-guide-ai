**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: e9aa14ccbfd8f02fea6c1b061215332c
Notas de lanzamiento de Ruby on Rails 7.0
==========================================

Aspectos destacados en Rails 7.0:

* Se requiere Ruby 2.7.0+ y se prefiere Ruby 3.0+

--------------------------------------------------------------------------------

Actualización a Rails 7.0
------------------------

Si estás actualizando una aplicación existente, es una buena idea tener una buena cobertura de pruebas antes de comenzar. También debes actualizar primero a Rails 6.1 en caso de que no lo hayas hecho y asegurarte de que tu aplicación siga funcionando como se espera antes de intentar una actualización a Rails 7.0. Una lista de cosas a tener en cuenta al actualizar está disponible en la guía de [Actualización de Ruby on Rails](upgrading_ruby_on_rails.html#upgrading-from-rails-6-1-to-rails-7-0).

Características principales
--------------------------

Railties
--------

Por favor, consulta el [registro de cambios][railties] para ver los cambios detallados.

### Eliminaciones

*   Eliminar `config` obsoleto en `dbconsole`.

### Deprecaciones

### Cambios destacados

*   Sprockets ahora es una dependencia opcional

    La gema `rails` ya no depende de `sprockets-rails`. Si tu aplicación aún necesita usar Sprockets,
    asegúrate de agregar `sprockets-rails` a tu Gemfile.

    ```
    gem "sprockets-rails"
    ```

Action Cable
------------

Por favor, consulta el [registro de cambios][action-cable] para ver los cambios detallados.

### Eliminaciones

### Deprecaciones

### Cambios destacados

Action Pack
-----------

Por favor, consulta el [registro de cambios][action-pack] para ver los cambios detallados.

### Eliminaciones

*   Eliminar `ActionDispatch::Response.return_only_media_type_on_content_type` obsoleto.

*   Eliminar `Rails.config.action_dispatch.hosts_response_app` obsoleto.

*   Eliminar `ActionDispatch::SystemTestCase#host!` obsoleto.

*   Eliminar el soporte obsoleto para pasar una ruta relativa a `fixture_file_upload` en relación a `fixture_path`.

### Deprecaciones

### Cambios destacados

Action View
-----------

Por favor, consulta el [registro de cambios][action-view] para ver los cambios detallados.

### Eliminaciones

*   Eliminar `Rails.config.action_view.raise_on_missing_translations` obsoleto.

### Deprecaciones

### Cambios destacados

*  `button_to` infiere el verbo HTTP [method] de un objeto Active Record si se utiliza para construir la URL

    ```ruby
    button_to("Hacer un POST", [:do_post_action, Workshop.find(1)])
    # Antes
    #=>   <input type="hidden" name="_method" value="post" autocomplete="off" />
    # Después
    #=>   <input type="hidden" name="_method" value="patch" autocomplete="off" />
    ```

Action Mailer
-------------

Por favor, consulta el [registro de cambios][action-mailer] para ver los cambios detallados.

### Eliminaciones

*   Eliminar `ActionMailer::DeliveryJob` y `ActionMailer::Parameterized::DeliveryJob` obsoletos
    a favor de `ActionMailer::MailDeliveryJob`.

### Deprecaciones

### Cambios destacados

Active Record
-------------

Por favor, consulta el [registro de cambios][active-record] para ver los cambios detallados.

### Eliminaciones

*   Eliminar el argumento `database` obsoleto de `connected_to`.

*   Eliminar `ActiveRecord::Base.allow_unsafe_raw_sql` obsoleto.

*   Eliminar la opción obsoleta `:spec_name` en el método `configs_for`.

*   Eliminar el soporte obsoleto para cargar instancias de `ActiveRecord::Base` en formato Rails 4.2 y 4.1 desde YAML.

*   Eliminar advertencia de deprecación cuando se utiliza la columna `:interval` en la base de datos de PostgreSQL.

    Ahora, las columnas de intervalo devolverán objetos `ActiveSupport::Duration` en lugar de cadenas.

    Para mantener el comportamiento anterior, puedes agregar esta línea a tu modelo:

    ```ruby
    attribute :column, :string
    ```

*   Eliminar el soporte obsoleto para resolver la conexión utilizando `"primary"` como nombre de especificación de conexión.

*   Eliminar el soporte obsoleto para citar objetos `ActiveRecord::Base`.

*   Eliminar el soporte obsoleto para convertir objetos `ActiveRecord::Base` en valores de base de datos.

*   Eliminar el soporte obsoleto para pasar una columna a `type_cast`.

*   Eliminar el método `DatabaseConfig#config` obsoleto.

*   Eliminar las tareas de rake obsoletas:

    * `db:schema:load_if_ruby`
    * `db:structure:dump`
    * `db:structure:load`
    * `db:structure:load_if_sql`
    * `db:structure:dump:#{name}`
    * `db:structure:load:#{name}`
    * `db:test:load_structure`
    * `db:test:load_structure:#{name}`

*   Eliminar el soporte obsoleto para `Model.reorder(nil).first` para buscar utilizando un orden no determinista.

*   Eliminar los argumentos `environment` y `name` obsoletos de `Tasks::DatabaseTasks.schema_up_to_date?`.

*   Eliminar `Tasks::DatabaseTasks.dump_filename` obsoleto.

*   Eliminar `Tasks::DatabaseTasks.schema_file` obsoleto.

*   Eliminar `Tasks::DatabaseTasks.spec` obsoleto.

*   Eliminar `Tasks::DatabaseTasks.current_config` obsoleto.

*   Eliminar `ActiveRecord::Connection#allowed_index_name_length` obsoleto.

*   Eliminar `ActiveRecord::Connection#in_clause_length` obsoleto.

*   Eliminar `ActiveRecord::DatabaseConfigurations::DatabaseConfig#spec_name` obsoleto.

*   Eliminar `ActiveRecord::Base.connection_config` obsoleto.

*   Eliminar `ActiveRecord::Base.arel_attribute` obsoleto.

*   Eliminar `ActiveRecord::Base.configurations.default_hash` obsoleto.

*   Eliminar `ActiveRecord::Base.configurations.to_h` obsoleto.

*   Eliminar `ActiveRecord::Result#map!` y `ActiveRecord::Result#collect!` obsoletos.

*   Eliminar `ActiveRecord::Base#remove_connection` obsoleto.

### Deprecaciones

*   Deprecar `Tasks::DatabaseTasks.schema_file_type`.

### Cambios destacados

*   Deshacer transacciones cuando el bloque devuelve antes de lo esperado.

    Antes de este cambio, cuando un bloque de transacción se devolvía temprano, la transacción se confirmaba.

    El problema es que las expiraciones de tiempo de espera dentro del bloque de transacción también hacían que la transacción incompleta se confirmara, por lo que, para evitar este error, se deshace la transacción.

*   La combinación de condiciones en la misma columna ya no mantiene ambas condiciones,
    y será reemplazada de manera consistente por la última condición.

    ```ruby
    # Rails 6.1 (la cláusula IN es reemplazada por una condición de igualdad en el lado del combinador)
    Author.where(id: [david.id, mary.id]).merge(Author.where(id: bob)) # => [bob]
    # Rails 6.1 (ambas condiciones de conflicto existen, obsoleto)
    Author.where(id: david.id..mary.id).merge(Author.where(id: bob)) # => []
    # Rails 6.1 con rewhere para migrar al comportamiento de Rails 7.0
    Author.where(id: david.id..mary.id).merge(Author.where(id: bob), rewhere: true) # => [bob]
    # Rails 7.0 (mismo comportamiento con cláusula IN, la condición del combinador se reemplaza de manera consistente)
    Author.where(id: [david.id, mary.id]).merge(Author.where(id: bob)) # => [bob]
    Author.where(id: david.id..mary.id).merge(Author.where(id: bob)) # => [bob]
    ```

[railties]: https://github.com/rails/rails/blob/main/railties/CHANGELOG.md
[action-cable]: https://github.com/rails/rails/blob/main/actioncable/CHANGELOG.md
[action-pack]: https://github.com/rails/rails/blob/main/actionpack/CHANGELOG.md
[action-view]: https://github.com/rails/rails/blob/main/actionview/CHANGELOG.md
[action-mailer]: https://github.com/rails/rails/blob/main/actionmailer/CHANGELOG.md
[active-record]: https://github.com/rails/rails/blob/main/activerecord/CHANGELOG.md
Active Storage
--------------

Consulte el [registro de cambios][active-storage] para obtener cambios detallados.

### Eliminaciones

### Deprecaciones

### Cambios destacados

Active Model
------------

Consulte el [registro de cambios][active-model] para obtener cambios detallados.

### Eliminaciones

*   Eliminar la enumeración obsoleta de instancias de `ActiveModel::Errors` como un Hash.

*   Eliminar `ActiveModel::Errors#to_h` obsoleto.

*   Eliminar `ActiveModel::Errors#slice!` obsoleto.

*   Eliminar `ActiveModel::Errors#values` obsoleto.

*   Eliminar `ActiveModel::Errors#keys` obsoleto.

*   Eliminar `ActiveModel::Errors#to_xml` obsoleto.

*   Eliminar el soporte obsoleto para concatenar errores en `ActiveModel::Errors#messages`.

*   Eliminar el soporte obsoleto para borrar errores de `ActiveModel::Errors#messages`.

*   Eliminar el soporte obsoleto para eliminar errores de `ActiveModel::Errors#messages`.

*   Eliminar el soporte para usar `[]=` en `ActiveModel::Errors#messages`.

*   Eliminar el soporte para cargar el formato de error de Rails 5.x mediante Marshal y YAML.

*   Eliminar el soporte para cargar el formato `ActiveModel::AttributeSet` de Rails 5.x mediante Marshal.

### Deprecaciones

### Cambios destacados

Active Support
--------------

Consulte el [registro de cambios][active-support] para obtener cambios detallados.

### Eliminaciones

*   Eliminar `config.active_support.use_sha1_digests` obsoleto.

*   Eliminar `URI.parser` obsoleto.

*   Se ha eliminado el soporte obsoleto para usar `Range#include?` para verificar la inclusión de un valor en un rango de fecha y hora.

*   Eliminar `ActiveSupport::Multibyte::Unicode.default_normalization_form` obsoleto.

### Deprecaciones

*   Deprecar pasar un formato a `#to_s` en favor de `#to_fs` en `Array`, `Range`, `Date`, `DateTime`, `Time`, `BigDecimal`, `Float` e `Integer`.

    Esta deprecación permite que las aplicaciones de Rails aprovechen una [optimización](https://github.com/ruby/ruby/commit/b08dacfea39ad8da3f1fd7fdd0e4538cc892ec44) de Ruby 3.1 que hace que la interpolación de algunos tipos de objetos sea más rápida.

    Las nuevas aplicaciones no tendrán el método `#to_s` anulado en esas clases, las aplicaciones existentes pueden usar `config.active_support.disable_to_s_conversion`.

### Cambios destacados

Active Job
----------

Consulte el [registro de cambios][active-job] para obtener cambios detallados.

### Eliminaciones

*   Se eliminó el comportamiento obsoleto que no detenía las devoluciones de llamada `after_enqueue`/`after_perform` cuando una devolución de llamada anterior se detenía con `throw :abort`.

*   Eliminar la opción obsoleta `:return_false_on_aborted_enqueue`.

### Deprecaciones

*   Deprecar `Rails.config.active_job.skip_after_callbacks_if_terminated`.

### Cambios destacados

Action Text
----------

Consulte el [registro de cambios][action-text] para obtener cambios detallados.

### Eliminaciones

### Deprecaciones

### Cambios destacados

Action Mailbox
----------

Consulte el [registro de cambios][action-mailbox] para obtener cambios detallados.

### Eliminaciones

*   Se eliminó `Rails.application.credentials.action_mailbox.mailgun_api_key` obsoleto.

*   Se eliminó la variable de entorno obsoleta `MAILGUN_INGRESS_API_KEY`.

### Deprecaciones

### Cambios destacados

Ruby on Rails Guides
--------------------

Consulte el [registro de cambios][guides] para obtener cambios detallados.

### Cambios destacados

Créditos
-------

Consulte la [lista completa de colaboradores de Rails](https://contributors.rubyonrails.org/) para conocer a las muchas personas que pasaron muchas horas haciendo de Rails el marco estable y robusto que es. Felicitaciones a todos ellos.

[railties]:       https://github.com/rails/rails/blob/7-0-stable/railties/CHANGELOG.md
[action-pack]:    https://github.com/rails/rails/blob/7-0-stable/actionpack/CHANGELOG.md
[action-view]:    https://github.com/rails/rails/blob/7-0-stable/actionview/CHANGELOG.md
[action-mailer]:  https://github.com/rails/rails/blob/7-0-stable/actionmailer/CHANGELOG.md
[action-cable]:   https://github.com/rails/rails/blob/7-0-stable/actioncable/CHANGELOG.md
[active-record]:  https://github.com/rails/rails/blob/7-0-stable/activerecord/CHANGELOG.md
[active-model]:   https://github.com/rails/rails/blob/7-0-stable/activemodel/CHANGELOG.md
[active-job]:     https://github.com/rails/rails/blob/7-0-stable/activejob/CHANGELOG.md
[action-text]:    https://github.com/rails/rails/blob/7-0-stable/actiontext/CHANGELOG.md
[guides]:         https://github.com/rails/rails/blob/7-0-stable/guides/CHANGELOG.md
[active-storage]: https://github.com/rails/rails/blob/7-0-stable/activestorage/CHANGELOG.md
[active-support]: https://github.com/rails/rails/blob/7-0-stable/activesupport/CHANGELOG.md
[action-mailbox]: https://github.com/rails/rails/blob/7-0-stable/actionmailbox/CHANGELOG.md
