**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 82080185bf1d0c30f22fa131b42e4187
Notas de la versión de Ruby on Rails 7.1
==========================================

Aspectos destacados en Rails 7.1:

--------------------------------------------------------------------------------

Actualización a Rails 7.1
-------------------------

Si estás actualizando una aplicación existente, es una buena idea tener una buena cobertura de pruebas antes de comenzar. También debes actualizar primero a Rails 7.0 en caso de que no lo hayas hecho y asegurarte de que tu aplicación siga funcionando como se espera antes de intentar una actualización a Rails 7.1. Una lista de cosas a tener en cuenta al actualizar está disponible en la guía [Actualización de Ruby on Rails](upgrading_ruby_on_rails.html#upgrading-from-rails-7-0-to-rails-7-1).

Principales características
---------------------------

Railties
--------

Consulta el [registro de cambios][railties] para ver los cambios detallados.

### Eliminaciones

### Deprecaciones

### Cambios destacados

Action Cable
------------

Consulta el [registro de cambios][action-cable] para ver los cambios detallados.

### Eliminaciones

### Deprecaciones

### Cambios destacados

Action Pack
-----------

Consulta el [registro de cambios][action-pack] para ver los cambios detallados.

### Eliminaciones

*   Eliminar el comportamiento obsoleto en `Request#content_type`

*   Eliminar la capacidad obsoleta de asignar un único valor a `config.action_dispatch.trusted_proxies`.

*   Eliminar el registro obsoleto del controlador `poltergeist` y `webkit` (capybara-webkit) para las pruebas del sistema.

### Deprecaciones

*   Deprecar `config.action_dispatch.return_only_request_media_type_on_content_type`.

*   Deprecar `AbstractController::Helpers::MissingHelperError`

*   Deprecar `ActionDispatch::IllegalStateError`.

### Cambios destacados

Action View
-----------

Consulta el [registro de cambios][action-view] para ver los cambios detallados.

### Eliminaciones

*   Eliminar la constante obsoleta `ActionView::Path`.

*   Eliminar el soporte obsoleto para pasar variables de instancia como locales a parciales.

### Deprecaciones

### Cambios destacados

Action Mailer
-------------

Consulta el [registro de cambios][action-mailer] para ver los cambios detallados.

### Eliminaciones

### Deprecaciones

### Cambios destacados

Active Record
-------------

Consulta el [registro de cambios][active-record] para ver los cambios detallados.

### Eliminaciones

*   Eliminar el soporte para `ActiveRecord.legacy_connection_handling`.

*   Eliminar los accesores de configuración obsoletos de `ActiveRecord::Base`

*   Eliminar el soporte para `:include_replicas` en `configs_for`. Utiliza `:include_hidden` en su lugar.

*   Eliminar `config.active_record.partial_writes` obsoleto.

*   Eliminar `Tasks::DatabaseTasks.schema_file_type` obsoleto.

### Deprecaciones

### Cambios destacados

Active Storage
--------------

Consulta el [registro de cambios][active-storage] para ver los cambios detallados.

### Eliminaciones

*   Eliminar los tipos de contenido predeterminados inválidos en las configuraciones de Active Storage.

*   Eliminar los métodos obsoletos `ActiveStorage::Current#host` y `ActiveStorage::Current#host=`.

*   Eliminar el comportamiento obsoleto al asignar a una colección de adjuntos. En lugar de agregar a la colección,
    ahora se reemplaza la colección.

*   Eliminar los métodos obsoletos `purge` y `purge_later` de la asociación de adjuntos.

### Deprecaciones

### Cambios destacados

Active Model
------------

Consulta el [registro de cambios][active-model] para ver los cambios detallados.

### Eliminaciones

### Deprecaciones

### Cambios destacados

Active Support
--------------

Consulta el [registro de cambios][active-support] para ver los cambios detallados.

### Eliminaciones

*   Eliminar la anulación obsoleta de `Enumerable#sum`.

*   Eliminar `ActiveSupport::PerThreadRegistry` obsoleto.

*   Eliminar la opción obsoleta de pasar un formato a `#to_s` en `Array`, `Range`, `Date`, `DateTime`, `Time`,
    `BigDecimal`, `Float` e `Integer`.

*   Eliminar la anulación obsoleta de `ActiveSupport::TimeWithZone.name`.

*   Eliminar el archivo `active_support/core_ext/uri` obsoleto.

*   Eliminar el archivo `active_support/core_ext/range/include_time_with_zone` obsoleto.

*   Eliminar la conversión implícita de objetos a `String` por parte de `ActiveSupport::SafeBuffer`.

*   Eliminar el soporte obsoleto para generar UUID de RFC 4122 incorrectos al proporcionar un ID de espacio de nombres que no es uno de los
    constantes definidas en `Digest::UUID`.

### Deprecaciones

*   Deprecar `config.active_support.disable_to_s_conversion`.

*   Deprecar `config.active_support.remove_deprecated_time_with_zone_name`.

*   Deprecar `config.active_support.use_rfc4122_namespaced_uuids`.

### Cambios destacados

Active Job
----------

Consulta el [registro de cambios][active-job] para ver los cambios detallados.

### Eliminaciones

### Deprecaciones

### Cambios destacados

Action Text
----------

Consulta el [registro de cambios][action-text] para ver los cambios detallados.

### Eliminaciones

### Deprecaciones

### Cambios destacados

Action Mailbox
----------

Consulta el [registro de cambios][action-mailbox] para ver los cambios detallados.

### Eliminaciones

### Deprecaciones

### Cambios destacados

Guías de Ruby on Rails
----------------------

Consulta el [registro de cambios][guides] para ver los cambios detallados.

### Cambios destacados

Créditos
--------

Consulta la [lista completa de colaboradores de Rails](https://contributors.rubyonrails.org/)
para ver a todas las personas que dedicaron muchas horas a hacer de Rails el marco estable y robusto que es. Felicitaciones a todos ellos.

[railties]:       https://github.com/rails/rails/blob/main/railties/CHANGELOG.md
[action-pack]:    https://github.com/rails/rails/blob/main/actionpack/CHANGELOG.md
[action-view]:    https://github.com/rails/rails/blob/main/actionview/CHANGELOG.md
[action-mailer]:  https://github.com/rails/rails/blob/main/actionmailer/CHANGELOG.md
[action-cable]:   https://github.com/rails/rails/blob/main/actioncable/CHANGELOG.md
[active-record]:  https://github.com/rails/rails/blob/main/activerecord/CHANGELOG.md
[active-model]:   https://github.com/rails/rails/blob/main/activemodel/CHANGELOG.md
[active-job]:     https://github.com/rails/rails/blob/main/activejob/CHANGELOG.md
[action-text]:    https://github.com/rails/rails/blob/main/actiontext/CHANGELOG.md
[guides]:         https://github.com/rails/rails/blob/main/guides/CHANGELOG.md
[active-storage]: https://github.com/rails/rails/blob/main/activestorage/CHANGELOG.md
[active-support]: https://github.com/rails/rails/blob/main/activesupport/CHANGELOG.md
[action-mailbox]: https://github.com/rails/rails/blob/main/actionmailbox/CHANGELOG.md
