**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 82080185bf1d0c30f22fa131b42e4187
Ruby on Rails 7.1 Notas de Lançamento
======================================

Destaques do Rails 7.1:

--------------------------------------------------------------------------------

Atualizando para o Rails 7.1
---------------------------

Se você está atualizando um aplicativo existente, é uma ótima ideia ter uma boa cobertura de testes antes de prosseguir. Você também deve primeiro atualizar para o Rails 7.0, caso ainda não o tenha feito, e garantir que seu aplicativo ainda funcione como esperado antes de tentar uma atualização para o Rails 7.1. Uma lista de coisas a serem observadas ao atualizar está disponível no guia [Atualizando o Ruby on Rails](upgrading_ruby_on_rails.html#upgrading-from-rails-7-0-to-rails-7-1).

Recursos Principais
-------------------

Railties
--------

Consulte o [Changelog][railties] para obter detalhes das alterações.

### Remoções

### Depreciações

### Mudanças notáveis

Action Cable
------------

Consulte o [Changelog][action-cable] para obter detalhes das alterações.

### Remoções

### Depreciações

### Mudanças notáveis

Action Pack
-----------

Consulte o [Changelog][action-pack] para obter detalhes das alterações.

### Remoções

*   Remover comportamento obsoleto em `Request#content_type`

*   Remover capacidade obsoleta de atribuir um único valor a `config.action_dispatch.trusted_proxies`.

*   Remover registro obsoleto dos drivers `poltergeist` e `webkit` (capybara-webkit) para testes de sistema.

### Depreciações

*   Depreciar `config.action_dispatch.return_only_request_media_type_on_content_type`.

*   Depreciar `AbstractController::Helpers::MissingHelperError`

*   Depreciar `ActionDispatch::IllegalStateError`.

### Mudanças notáveis

Action View
-----------

Consulte o [Changelog][action-view] para obter detalhes das alterações.

### Remoções

*   Remover constante obsoleta `ActionView::Path`.

*   Remover suporte obsoleto para passar variáveis de instância como locais para parciais.

### Depreciações

### Mudanças notáveis

Action Mailer
-------------

Consulte o [Changelog][action-mailer] para obter detalhes das alterações.

### Remoções

### Depreciações

### Mudanças notáveis

Active Record
-------------

Consulte o [Changelog][active-record] para obter detalhes das alterações.

### Remoções

*   Remover suporte para `ActiveRecord.legacy_connection_handling`.

*   Remover acessores de configuração obsoletos de `ActiveRecord::Base`

*   Remover suporte para `:include_replicas` em `configs_for`. Use `:include_hidden` em seu lugar.

*   Remover `config.active_record.partial_writes` obsoleto.

*   Remover `Tasks::DatabaseTasks.schema_file_type` obsoleto.

### Depreciações

### Mudanças notáveis

Active Storage
--------------

Consulte o [Changelog][active-storage] para obter detalhes das alterações.

### Remoções

*   Remover tipos de conteúdo padrão inválidos obsoletos nas configurações do Active Storage.

*   Remover métodos obsoletos `ActiveStorage::Current#host` e `ActiveStorage::Current#host=`.

*   Remover comportamento obsoleto ao atribuir a uma coleção de anexos. Em vez de anexar à coleção, a coleção agora é substituída.

*   Remover métodos `purge` e `purge_later` obsoletos da associação de anexos.

### Depreciações

### Mudanças notáveis

Active Model
------------

Consulte o [Changelog][active-model] para obter detalhes das alterações.

### Remoções

### Depreciações

### Mudanças notáveis

Active Support
--------------

Consulte o [Changelog][active-support] para obter detalhes das alterações.

### Remoções

*   Remover substituição obsoleta de `Enumerable#sum`.

*   Remover `ActiveSupport::PerThreadRegistry` obsoleto.

*   Remover opção obsoleta de passar um formato para `#to_s` em `Array`, `Range`, `Date`, `DateTime`, `Time`,
    `BigDecimal`, `Float` e `Integer`.

*   Remover substituição obsoleta de `ActiveSupport::TimeWithZone.name`.

*   Remover arquivo `active_support/core_ext/uri` obsoleto.

*   Remover arquivo `active_support/core_ext/range/include_time_with_zone` obsoleto.

*   Remover conversão implícita de objetos em `String` por `ActiveSupport::SafeBuffer`.

*   Remover suporte obsoleto para gerar UUIDs RFC 4122 incorretos ao fornecer um ID de namespace que não é uma das
    constantes definidas em `Digest::UUID`.

### Depreciações

*   Depreciar `config.active_support.disable_to_s_conversion`.

*   Depreciar `config.active_support.remove_deprecated_time_with_zone_name`.

*   Depreciar `config.active_support.use_rfc4122_namespaced_uuids`.

### Mudanças notáveis

Active Job
----------

Consulte o [Changelog][active-job] para obter detalhes das alterações.

### Remoções

### Depreciações

### Mudanças notáveis

Action Text
----------

Consulte o [Changelog][action-text] para obter detalhes das alterações.

### Remoções

### Depreciações

### Mudanças notáveis

Action Mailbox
--------------

Consulte o [Changelog][action-mailbox] para obter detalhes das alterações.

### Remoções

### Depreciações

### Mudanças notáveis

Ruby on Rails Guides
--------------------

Consulte o [Changelog][guides] para obter detalhes das alterações.

### Mudanças notáveis

Créditos
--------

Veja a [lista completa de contribuidores para o Rails](https://contributors.rubyonrails.org/) para as muitas pessoas que dedicaram muitas horas para tornar o Rails o framework estável e robusto que ele é. Parabéns a todos eles.

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
