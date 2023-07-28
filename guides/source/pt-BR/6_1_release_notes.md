**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 1d652e6ccda9c901ca3f6a003c95f83e
Notas de Lançamento do Ruby on Rails 6.1
========================================

Destaques no Rails 6.1:

* Troca de Conexão por Banco de Dados
* Sharding Horizontal
* Carregamento Estrito de Associações
* Tipos Delegados
* Destruir Associações de Forma Assíncrona

Estas notas de lançamento cobrem apenas as principais mudanças. Para saber sobre várias correções de bugs e mudanças, consulte os registros de alterações ou confira a [lista de commits](https://github.com/rails/rails/commits/6-1-stable) no repositório principal do Rails no GitHub.

--------------------------------------------------------------------------------

Atualizando para o Rails 6.1
---------------------------

Se você está atualizando um aplicativo existente, é uma ótima ideia ter uma boa cobertura de testes antes de prosseguir. Você também deve primeiro atualizar para o Rails 6.0, caso ainda não o tenha feito, e garantir que seu aplicativo ainda esteja funcionando como esperado antes de tentar uma atualização para o Rails 6.1. Uma lista de coisas a serem observadas ao atualizar está disponível no guia [Atualizando o Ruby on Rails](upgrading_ruby_on_rails.html#upgrading-from-rails-6-0-to-rails-6-1).

Recursos Principais
-------------------

### Troca de Conexão por Banco de Dados

O Rails 6.1 oferece a capacidade de [trocar conexões por banco de dados](https://github.com/rails/rails/pull/40370). No Rails 6.0, se você trocasse para a função `reading`, todas as conexões do banco de dados também trocariam para a função de leitura. Agora, no Rails 6.1, se você definir `legacy_connection_handling` como `false` em sua configuração, o Rails permitirá que você troque as conexões para um único banco de dados chamando `connected_to` na classe abstrata correspondente.

### Sharding Horizontal

O Rails 6.0 permitia a partição funcional (múltiplas partições, esquemas diferentes) do seu banco de dados, mas não era capaz de suportar o sharding horizontal (mesmo esquema, múltiplas partições). O Rails não era capaz de suportar o sharding horizontal porque os modelos no Active Record só podiam ter uma conexão por função por classe. Isso agora foi corrigido e o [sharding horizontal](https://github.com/rails/rails/pull/38531) com o Rails está disponível.

### Carregamento Estrito de Associações

[Carregamento estrito de associações](https://github.com/rails/rails/pull/37400) permite que você garanta que todas as suas associações sejam carregadas antecipadamente e evite N+1 antes que eles ocorram.

### Tipos Delegados

[Tipos delegados](https://github.com/rails/rails/pull/39341) é uma alternativa à herança de tabela única. Isso ajuda a representar hierarquias de classes, permitindo que a superclasse seja uma classe concreta representada por sua própria tabela. Cada subclasse tem sua própria tabela para atributos adicionais.

### Destruir Associações de Forma Assíncrona

[Destruir associações de forma assíncrona](https://github.com/rails/rails/pull/40157) adiciona a capacidade para aplicativos de `destruir` associações em um trabalho em segundo plano. Isso pode ajudar a evitar tempos limite e outros problemas de desempenho em seu aplicativo ao destruir dados.

Railties
--------

Consulte o [Changelog][railties] para obter alterações detalhadas.

### Remoções

*   Remover tarefas `rake notes` obsoletas.

*   Remover opção `connection` obsoleta no comando `rails dbconsole`.

*   Remover suporte à variável de ambiente `SOURCE_ANNOTATION_DIRECTORIES` obsoleta do `rails notes`.

*   Remover argumento `server` obsoleto do comando `rails server`.

*   Remover suporte obsoleto para usar a variável de ambiente `HOST` para especificar o IP do servidor.

*   Remover tarefas `rake dev:cache` obsoletas.

*   Remover tarefas `rake routes` obsoletas.

*   Remover tarefas `rake initializers` obsoletas.

### Depreciações

### Mudanças Notáveis

Action Cable
------------

Consulte o [Changelog][action-cable] para obter alterações detalhadas.

### Remoções

### Depreciações

### Mudanças Notáveis

Action Pack
-----------

Consulte o [Changelog][action-pack] para obter alterações detalhadas.

### Remoções

*   Remover `ActionDispatch::Http::ParameterFilter` obsoleto.

*   Remover `force_ssl` obsoleto no nível do controlador.

### Depreciações

*   Depreciar `config.action_dispatch.return_only_media_type_on_content_type`.

### Mudanças Notáveis

*   Alterar `ActionDispatch::Response#content_type` para retornar o cabeçalho completo Content-Type.

Action View
-----------

Consulte o [Changelog][action-view] para obter alterações detalhadas.

### Remoções

*   Remover `escape_whitelist` obsoleto de `ActionView::Template::Handlers::ERB`.

*   Remover `find_all_anywhere` obsoleto de `ActionView::Resolver`.

*   Remover `formats` obsoleto de `ActionView::Template::HTML`.

*   Remover `formats` obsoleto de `ActionView::Template::RawFile`.

*   Remover `formats` obsoleto de `ActionView::Template::Text`.

*   Remover `find_file` obsoleto de `ActionView::PathSet`.

*   Remover `rendered_format` obsoleto de `ActionView::LookupContext`.

*   Remover `find_file` obsoleto de `ActionView::ViewPaths`.

*   Remover suporte obsoleto para passar um objeto que não seja um `ActionView::LookupContext` como o primeiro argumento em `ActionView::Base#initialize`.

*   Remover argumento `format` obsoleto em `ActionView::Base#initialize`.

*   Remover `ActionView::Template#refresh` obsoleto.

*   Remover `ActionView::Template#original_encoding` obsoleto.

*   Remover `ActionView::Template#variants` obsoleto.

*   Remover `ActionView::Template#formats` obsoleto.

*   Remover `ActionView::Template#virtual_path=` obsoleto.

*   Remover `ActionView::Template#updated_at` obsoleto.

*   Remover argumento `updated_at` obrigatório em `ActionView::Template#initialize`.

*   Remover `ActionView::Template.finalize_compiled_template_methods` obsoleto.

*   Remover `config.action_view.finalize_compiled_template_methods` obsoleto.

*   Remover suporte obsoleto para chamar `ActionView::ViewPaths#with_fallback` com um bloco.

*   Remover suporte obsoleto para passar caminhos absolutos para `render template:`.

*   Remover suporte obsoleto para passar caminhos relativos para `render file:`.

*   Remover suporte a manipuladores de templates que não aceitam dois argumentos.

*   Remover argumento `pattern` obsoleto em `ActionView::Template::PathResolver`.

*   Remover suporte obsoleto para chamar métodos privados de objeto em alguns helpers de visualização.

### Depreciações

### Mudanças Notáveis
*   Exigir que as subclasses de `ActionView::Base` implementem `#compiled_method_container`.

*   Tornar o argumento `locals` obrigatório em `ActionView::Template#initialize`.

*   Os auxiliares de ativos `javascript_include_tag` e `stylesheet_link_tag` geram um cabeçalho `Link` que dá dicas aos navegadores modernos sobre o pré-carregamento de ativos. Isso pode ser desativado definindo `config.action_view.preload_links_header` como `false`.

Action Mailer
-------------

Consulte o [Changelog][action-mailer] para obter detalhes das alterações.

### Remoções

*   Remover o método depreciado `ActionMailer::Base.receive` em favor do [Action Mailbox](https://github.com/rails/rails/tree/6-1-stable/actionmailbox).

### Depreciações

### Mudanças notáveis

Active Record
-------------

Consulte o [Changelog][active-record] para obter detalhes das alterações.

### Remoções

*   Remover métodos depreciados de `ActiveRecord::ConnectionAdapters::DatabaseLimits`.

    `column_name_length`
    `table_name_length`
    `columns_per_table`
    `indexes_per_table`
    `columns_per_multicolumn_index`
    `sql_query_length`
    `joins_per_query`

*   Remover o método depreciado `ActiveRecord::ConnectionAdapters::AbstractAdapter#supports_multi_insert?`.

*   Remover o método depreciado `ActiveRecord::ConnectionAdapters::AbstractAdapter#supports_foreign_keys_in_create?`.

*   Remover o método depreciado `ActiveRecord::ConnectionAdapters::PostgreSQLAdapter#supports_ranges?`.

*   Remover os métodos depreciados `ActiveRecord::Base#update_attributes` e `ActiveRecord::Base#update_attributes!`.

*   Remover o argumento `migrations_path` depreciado em
    `ActiveRecord::ConnectionAdapter::SchemaStatements#assume_migrated_upto_version`.

*   Remover `config.active_record.sqlite3.represent_boolean_as_integer` depreciado.

*   Remover métodos depreciados de `ActiveRecord::DatabaseConfigurations`.

    `fetch`
    `each`
    `first`
    `values`
    `[]=`

*   Remover o método depreciado `ActiveRecord::Result#to_hash`.

*   Remover o suporte depreciado ao uso de SQL bruto inseguro nos métodos de `ActiveRecord::Relation`.

### Depreciações

*   Depreciar `ActiveRecord::Base.allow_unsafe_raw_sql`.

*   Depreciar o argumento `database` em `connected_to`.

*   Depreciar `connection_handlers` quando `legacy_connection_handling` é definido como false.

### Mudanças notáveis

*   MySQL: O validador de unicidade agora respeita a colação padrão do banco de dados,
    não mais força comparação case-sensitive por padrão.

*   `relation.create` não vaza mais o escopo para métodos de consulta em nível de classe
    no bloco de inicialização e nos callbacks.

    Antes:

    ```ruby
    User.where(name: "John").create do |john|
      User.find_by(name: "David") # => nil
    end
    ```

    Depois:

    ```ruby
    User.where(name: "John").create do |john|
      User.find_by(name: "David") # => #<User name: "David", ...>
    end
    ```

*   A cadeia de escopos nomeados não vaza mais o escopo para métodos de consulta em nível de classe.

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

    Depois:

    ```ruby
    User.where(name: "John").david
    # SELECT * FROM users WHERE name = 'David'
    ```

*   `where.not` agora gera predicados NAND em vez de NOR.

    Antes:

    ```ruby
    User.where.not(name: "Jon", role: "admin")
    # SELECT * FROM users WHERE name != 'Jon' AND role != 'admin'
    ```

    Depois:

    ```ruby
    User.where.not(name: "Jon", role: "admin")
    # SELECT * FROM users WHERE NOT (name = 'Jon' AND role = 'admin')
    ```

*   Para usar o novo tratamento de conexão por banco de dados, as aplicações devem alterar
    `legacy_connection_handling` para false e remover os acessores depreciados em
    `connection_handlers`. Os métodos públicos para `connects_to` e `connected_to`
    não requerem alterações.

Active Storage
--------------

Consulte o [Changelog][active-storage] para obter detalhes das alterações.

### Remoções

*   Remover o suporte depreciado para passar operações `:combine_options` para `ActiveStorage::Transformers::ImageProcessing`.

*   Remover `ActiveStorage::Transformers::MiniMagickTransformer` depreciado.

*   Remover `config.active_storage.queue` depreciado.

*   Remover `ActiveStorage::Downloading` depreciado.

### Depreciações

*   Depreciar `Blob.create_after_upload` em favor de `Blob.create_and_upload`.
    ([Pull Request](https://github.com/rails/rails/pull/34827))

### Mudanças notáveis

*   Adicionar `Blob.create_and_upload` para criar um novo blob e fazer upload do `io` fornecido
    para o serviço.
    ([Pull Request](https://github.com/rails/rails/pull/34827))
*   A coluna `service_name` foi adicionada a `ActiveStorage::Blob`. É necessário executar uma migração após a atualização. Execute `bin/rails app:update` para gerar essa migração.

Active Model
------------

Consulte o [Changelog][active-model] para obter detalhes das alterações.

### Remoções

### Depreciações

### Mudanças notáveis

*   Os erros do Active Model agora são objetos com uma interface que permite que sua aplicação lide e interaja mais facilmente com os erros lançados pelos modelos.
    [A funcionalidade](https://github.com/rails/rails/pull/32313) inclui uma interface de consulta, permite testes mais precisos e acesso aos detalhes do erro.

Active Support
--------------

Consulte o [Changelog][active-support] para obter detalhes das alterações.

### Remoções

*   Remover o fallback depreciado para `I18n.default_locale` quando `config.i18n.fallbacks` está vazio.

*   Remover a constante `LoggerSilence` depreciada.

*   Remover `ActiveSupport::LoggerThreadSafeLevel#after_initialize` depreciado.

*   Remover os métodos `Module#parent_name`, `Module#parent` e `Module#parents` depreciados.

*   Remover o arquivo `active_support/core_ext/module/reachable` depreciado.

*   Remover o arquivo `active_support/core_ext/numeric/inquiry` depreciado.

*   Remover o arquivo `active_support/core_ext/array/prepend_and_append` depreciado.

*   Remover o arquivo `active_support/core_ext/hash/compact` depreciado.

*   Remover o arquivo `active_support/core_ext/hash/transform_values` depreciado.

*   Remover o arquivo `active_support/core_ext/range/include_range` depreciado.

*   Remover `ActiveSupport::Multibyte::Chars#consumes?` e `ActiveSupport::Multibyte::Chars#normalize` depreciados.

*   Remover `ActiveSupport::Multibyte::Unicode.pack_graphemes`,
    `ActiveSupport::Multibyte::Unicode.unpack_graphemes`,
    `ActiveSupport::Multibyte::Unicode.normalize`,
    `ActiveSupport::Multibyte::Unicode.downcase`,
    `ActiveSupport::Multibyte::Unicode.upcase` e `ActiveSupport::Multibyte::Unicode.swapcase` depreciados.

*   Remover `ActiveSupport::Notifications::Instrumenter#end=` depreciado.

### Depreciações

*   Depreciar `ActiveSupport::Multibyte::Unicode.default_normalization_form`.

### Mudanças notáveis

Active Job
----------

Consulte o [Changelog][active-job] para obter detalhes das alterações.

### Remoções

### Depreciações

*   Depreciar `config.active_job.return_false_on_aborted_enqueue`.

### Mudanças notáveis

*   Retornar `false` quando o enfileiramento de um job é abortado.

Action Text
----------

Consulte o [Changelog][action-text] para obter detalhes das alterações.

### Remoções

### Depreciações

### Mudanças notáveis

*   Adicionar método para confirmar a existência de conteúdo de texto rico adicionando `?` após
    o nome do atributo de texto rico.
    ([Pull Request](https://github.com/rails/rails/pull/37951))

*   Adicionar o helper de caso de teste do sistema `fill_in_rich_text_area` para encontrar um editor trix
    e preenchê-lo com o conteúdo HTML fornecido.
    ([Pull Request](https://github.com/rails/rails/pull/35885))
*   Adicione `ActionText::FixtureSet.attachment` para gerar elementos `<action-text-attachment>` nos fixtures do banco de dados. ([Pull Request](https://github.com/rails/rails/pull/40289))

Action Mailbox
----------

Consulte o [Changelog][action-mailbox] para obter detalhes das alterações.

### Remoções

### Depreciações

*   Depreciar `Rails.application.credentials.action_mailbox.api_key` e `MAILGUN_INGRESS_API_KEY` em favor de `Rails.application.credentials.action_mailbox.signing_key` e `MAILGUN_INGRESS_SIGNING_KEY`.

### Mudanças notáveis

Ruby on Rails Guides
--------------------

Consulte o [Changelog][guides] para obter detalhes das alterações.

### Mudanças notáveis

Créditos
-------

Veja a [lista completa de contribuidores para o Rails](https://contributors.rubyonrails.org/) para as muitas pessoas que passaram muitas horas fazendo do Rails o framework estável e robusto que ele é. Parabéns a todos eles.

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
