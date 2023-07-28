**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: e9aa14ccbfd8f02fea6c1b061215332c
Ruby on Rails 7.0 Notas de Lançamento
======================================

Destaques do Rails 7.0:

* Ruby 2.7.0+ é necessário, Ruby 3.0+ é preferido

--------------------------------------------------------------------------------

Atualizando para o Rails 7.0
----------------------------

Se você está atualizando um aplicativo existente, é uma ótima ideia ter uma boa cobertura de testes antes de começar. Você também deve primeiro atualizar para o Rails 6.1, caso ainda não o tenha feito, e garantir que seu aplicativo ainda funcione como esperado antes de tentar uma atualização para o Rails 7.0. Uma lista de coisas a serem observadas ao atualizar está disponível no guia de [Atualização do Ruby on Rails](upgrading_ruby_on_rails.html#upgrading-from-rails-6-1-to-rails-7-0).

Recursos Principais
-------------------

Railties
--------

Consulte o [Changelog][railties] para obter as alterações detalhadas.

### Remoções

*   Remover `config` obsoleto em `dbconsole`.

### Depreciações

### Mudanças Notáveis

*   Sprockets agora é uma dependência opcional

    A gema `rails` não depende mais de `sprockets-rails`. Se o seu aplicativo ainda precisa usar o Sprockets,
    certifique-se de adicionar `sprockets-rails` ao seu Gemfile.

    ```
    gem "sprockets-rails"
    ```

Action Cable
------------

Consulte o [Changelog][action-cable] para obter as alterações detalhadas.

### Remoções

### Depreciações

### Mudanças Notáveis

Action Pack
-----------

Consulte o [Changelog][action-pack] para obter as alterações detalhadas.

### Remoções

*   Remover `ActionDispatch::Response.return_only_media_type_on_content_type` obsoleto.

*   Remover `Rails.config.action_dispatch.hosts_response_app` obsoleto.

*   Remover `ActionDispatch::SystemTestCase#host!` obsoleto.

*   Remover suporte obsoleto para passar um caminho relativo a `fixture_path` para `fixture_file_upload`.

### Depreciações

### Mudanças Notáveis

Action View
-----------

Consulte o [Changelog][action-view] para obter as alterações detalhadas.

### Remoções

*   Remover `Rails.config.action_view.raise_on_missing_translations` obsoleto.

### Depreciações

### Mudanças Notáveis

*  `button_to` infere o verbo HTTP [method] a partir de um objeto Active Record se o objeto for usado para construir o URL

    ```ruby
    button_to("Fazer um POST", [:do_post_action, Workshop.find(1)])
    # Antes
    #=>   <input type="hidden" name="_method" value="post" autocomplete="off" />
    # Depois
    #=>   <input type="hidden" name="_method" value="patch" autocomplete="off" />
    ```

Action Mailer
-------------

Consulte o [Changelog][action-mailer] para obter as alterações detalhadas.

### Remoções

*   Remover `ActionMailer::DeliveryJob` e `ActionMailer::Parameterized::DeliveryJob`
    em favor de `ActionMailer::MailDeliveryJob`.

### Depreciações

### Mudanças Notáveis

Active Record
-------------

Consulte o [Changelog][active-record] para obter as alterações detalhadas.

### Remoções

*   Remover `database` kwarg de `connected_to` obsoleto.

*   Remover `ActiveRecord::Base.allow_unsafe_raw_sql` obsoleto.

*   Remover opção `:spec_name` no método `configs_for` obsoleto.

*   Remover suporte obsoleto para carregar instância de `ActiveRecord::Base` em formato Rails 4.2 e 4.1 usando YAML.

*   Remover aviso de depreciação quando a coluna `:interval` é usada no banco de dados PostgreSQL.

    Agora, as colunas de intervalo retornarão objetos `ActiveSupport::Duration` em vez de strings.

    Para manter o comportamento antigo, você pode adicionar esta linha ao seu modelo:

    ```ruby
    attribute :column, :string
    ```

*   Remover suporte obsoleto para resolver conexão usando `"primary"` como nome de especificação de conexão.

*   Remover suporte obsoleto para citar objetos `ActiveRecord::Base`.

*   Remover suporte obsoleto para converter valores de objetos `ActiveRecord::Base` para valores de banco de dados.

*   Remover suporte obsoleto para passar uma coluna para `type_cast`.

*   Remover método `DatabaseConfig#config` obsoleto.

*   Remover tarefas rake obsoletas:

    * `db:schema:load_if_ruby`
    * `db:structure:dump`
    * `db:structure:load`
    * `db:structure:load_if_sql`
    * `db:structure:dump:#{name}`
    * `db:structure:load:#{name}`
    * `db:test:load_structure`
    * `db:test:load_structure:#{name}`

*   Remover suporte obsoleto para `Model.reorder(nil).first` para pesquisar usando ordem não determinística.

*   Remover argumentos `environment` e `name` de `Tasks::DatabaseTasks.schema_up_to_date?` obsoletos.

*   Remover `Tasks::DatabaseTasks.dump_filename` obsoleto.

*   Remover `Tasks::DatabaseTasks.schema_file` obsoleto.

*   Remover `Tasks::DatabaseTasks.spec` obsoleto.

*   Remover `Tasks::DatabaseTasks.current_config` obsoleto.

*   Remover `ActiveRecord::Connection#allowed_index_name_length` obsoleto.

*   Remover `ActiveRecord::Connection#in_clause_length` obsoleto.

*   Remover `ActiveRecord::DatabaseConfigurations::DatabaseConfig#spec_name` obsoleto.

*   Remover `ActiveRecord::Base.connection_config` obsoleto.

*   Remover `ActiveRecord::Base.arel_attribute` obsoleto.

*   Remover `ActiveRecord::Base.configurations.default_hash` obsoleto.

*   Remover `ActiveRecord::Base.configurations.to_h` obsoleto.

*   Remover `ActiveRecord::Result#map!` e `ActiveRecord::Result#collect!` obsoletos.

*   Remover `ActiveRecord::Base#remove_connection` obsoleto.

### Depreciações

*   Depreciar `Tasks::DatabaseTasks.schema_file_type`.

### Mudanças Notáveis

*   Desfazer transações quando o bloco retorna mais cedo do que o esperado.

    Antes dessa alteração, quando um bloco de transação retornava cedo, a transação era confirmada.

    O problema é que os timeouts acionados dentro do bloco de transação também estavam fazendo com que a transação incompleta fosse confirmada, então, para evitar esse erro, o bloco de transação é desfeito.

*   Mesclar condições na mesma coluna não mantém mais ambas as condições,
    e será consistentemente substituída pela última condição.

    ```ruby
    # Rails 6.1 (IN clause é substituído por condição de igualdade no lado do merge)
    Author.where(id: [david.id, mary.id]).merge(Author.where(id: bob)) # => [bob]
    # Rails 6.1 (ambas as condições de conflito existem, obsoleto)
    Author.where(id: david.id..mary.id).merge(Author.where(id: bob)) # => []
    # Rails 6.1 com rewhere para migrar para o comportamento do Rails 7.0
    Author.where(id: david.id..mary.id).merge(Author.where(id: bob), rewhere: true) # => [bob]
    # Rails 7.0 (mesmo comportamento com IN clause, condição do merge é substituída consistentemente)
    Author.where(id: [david.id, mary.id]).merge(Author.where(id: bob)) # => [bob]
    Author.where(id: david.id..mary.id).merge(Author.where(id: bob)) # => [bob]
    ```
Active Storage
--------------

Consulte o [Changelog][active-storage] para obter detalhes das alterações.

### Remoções

### Depreciações

### Mudanças notáveis

Active Model
------------

Consulte o [Changelog][active-model] para obter detalhes das alterações.

### Remoções

*   Remova a enumeração obsoleta de instâncias de `ActiveModel::Errors` como um Hash.

*   Remova o método obsoleto `ActiveModel::Errors#to_h`.

*   Remova o método obsoleto `ActiveModel::Errors#slice!`.

*   Remova o método obsoleto `ActiveModel::Errors#values`.

*   Remova o método obsoleto `ActiveModel::Errors#keys`.

*   Remova o método obsoleto `ActiveModel::Errors#to_xml`.

*   Remova o suporte obsoleto para concatenar erros em `ActiveModel::Errors#messages`.

*   Remova o suporte obsoleto para limpar erros de `ActiveModel::Errors#messages`.

*   Remova o suporte obsoleto para excluir erros de `ActiveModel::Errors#messages`.

*   Remova o suporte obsoleto para usar `[]=` em `ActiveModel::Errors#messages`.

*   Remova o suporte para carregar o formato de erro do Rails 5.x usando Marshal e YAML.

*   Remova o suporte para carregar o formato `ActiveModel::AttributeSet` do Rails 5.x usando Marshal.

### Depreciações

### Mudanças notáveis

Active Support
--------------

Consulte o [Changelog][active-support] para obter detalhes das alterações.

### Remoções

*   Remova a configuração obsoleta `config.active_support.use_sha1_digests`.

*   Remova o método obsoleto `URI.parser`.

*   Remova o suporte obsoleto para usar `Range#include?` para verificar a inclusão de um valor em um intervalo de data e hora.

*   Remova a configuração obsoleta `ActiveSupport::Multibyte::Unicode.default_normalization_form`.

### Depreciações

*   Deprecie a passagem de um formato para `#to_s` em favor de `#to_fs` em `Array`, `Range`, `Date`, `DateTime`, `Time`,
    `BigDecimal`, `Float` e `Integer`.

    Essa depreciação permite que aplicativos Rails aproveitem uma otimização do Ruby 3.1
    [otimização](https://github.com/ruby/ruby/commit/b08dacfea39ad8da3f1fd7fdd0e4538cc892ec44) que torna
    a interpolação de alguns tipos de objetos mais rápida.

    Novos aplicativos não terão o método `#to_s` substituído nessas classes, aplicativos existentes podem usar
    `config.active_support.disable_to_s_conversion`.

### Mudanças notáveis

Active Job
----------

Consulte o [Changelog][active-job] para obter detalhes das alterações.

### Remoções

*   Removido o comportamento obsoleto que não interrompia os callbacks `after_enqueue`/`after_perform` quando um
    callback anterior era interrompido com `throw :abort`.

*   Remova a opção obsoleta `:return_false_on_aborted_enqueue`.

### Depreciações

*   Deprecie `Rails.config.active_job.skip_after_callbacks_if_terminated`.

### Mudanças notáveis

Action Text
----------

Consulte o [Changelog][action-text] para obter detalhes das alterações.

### Remoções

### Depreciações

### Mudanças notáveis

Action Mailbox
----------

Consulte o [Changelog][action-mailbox] para obter detalhes das alterações.

### Remoções

*   Removido o método obsoleto `Rails.application.credentials.action_mailbox.mailgun_api_key`.

*   Removida a variável de ambiente obsoleta `MAILGUN_INGRESS_API_KEY`.

### Depreciações

### Mudanças notáveis

Ruby on Rails Guides
--------------------

Consulte o [Changelog][guides] para obter detalhes das alterações.

### Mudanças notáveis

Créditos
-------

Consulte a
[lista completa de contribuidores para o Rails](https://contributors.rubyonrails.org/)
para ver as muitas pessoas que passaram muitas horas fazendo do Rails o framework estável e robusto que ele é. Parabéns a todos eles.

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
