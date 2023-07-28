**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: b1c2c8ad5c4bacb2e3b92aa320c4da3d
Notas de lançamento do Ruby on Rails 6.0
=========================================

Destaques do Rails 6.0:

* Action Mailbox
* Action Text
* Testes paralelos
* Testes do Action Cable

Estas notas de lançamento cobrem apenas as principais mudanças. Para saber sobre várias correções de bugs e mudanças, consulte os registros de alterações ou confira a [lista de commits](https://github.com/rails/rails/commits/6-0-stable) no repositório principal do Rails no GitHub.

--------------------------------------------------------------------------------

Atualizando para o Rails 6.0
----------------------------

Se você está atualizando um aplicativo existente, é uma ótima ideia ter uma boa cobertura de testes antes de começar. Você também deve primeiro atualizar para o Rails 5.2, caso ainda não o tenha feito, e garantir que seu aplicativo ainda funcione como esperado antes de tentar atualizar para o Rails 6.0. Uma lista de coisas a serem observadas ao atualizar está disponível no guia [Atualizando o Ruby on Rails](upgrading_ruby_on_rails.html#upgrading-from-rails-5-2-to-rails-6-0).

Recursos Principais
-------------------

### Action Mailbox

[Pull Request](https://github.com/rails/rails/pull/34786)

[Action Mailbox](https://github.com/rails/rails/tree/6-0-stable/actionmailbox) permite que você encaminhe e-mails recebidos para caixas de correio semelhantes a controladores. Você pode ler mais sobre o Action Mailbox no guia [Noções básicas do Action Mailbox](action_mailbox_basics.html).

### Action Text

[Pull Request](https://github.com/rails/rails/pull/34873)

[Action Text](https://github.com/rails/rails/tree/6-0-stable/actiontext) traz conteúdo de texto rico e edição para o Rails. Ele inclui o editor [Trix](https://trix-editor.org) que lida com tudo, desde formatação até links, citações, listas, imagens incorporadas e galerias. O conteúdo de texto rico gerado pelo editor Trix é salvo em seu próprio modelo RichText, que está associado a qualquer modelo Active Record existente no aplicativo. Quaisquer imagens incorporadas (ou outros anexos) são armazenadas automaticamente usando o Active Storage e associadas ao modelo RichText incluído.

Você pode ler mais sobre o Action Text no guia [Visão geral do Action Text](action_text_overview.html).

### Testes Paralelos

[Pull Request](https://github.com/rails/rails/pull/31900)

[Testes Paralelos](testing.html#parallel-testing) permitem que você paralelize seu conjunto de testes. Embora a criação de processos seja o método padrão, a criação de threads também é suportada. Executar testes em paralelo reduz o tempo necessário para executar todo o conjunto de testes.

### Testes do Action Cable

[Pull Request](https://github.com/rails/rails/pull/33659)

[Ferramentas de teste do Action Cable](testing.html#testing-action-cable) permitem que você teste sua funcionalidade do Action Cable em qualquer nível: conexões, canais, transmissões.

Railties
--------

Consulte o [Changelog][railties] para obter informações detalhadas sobre as alterações.

### Remoções

*   Remover o auxiliar `after_bundle` obsoleto dentro dos modelos de plugins.
    ([Commit](https://github.com/rails/rails/commit/4d51efe24e461a2a3ed562787308484cd48370c7))

*   Remover o suporte obsoleto ao `config.ru` que usa a classe do aplicativo como argumento de `run`.
    ([Commit](https://github.com/rails/rails/commit/553b86fc751c751db504bcbe2d033eb2bb5b6a0b))

*   Remover o argumento obsoleto `environment` dos comandos do Rails.
    ([Commit](https://github.com/rails/rails/commit/e20589c9be09c7272d73492d4b0f7b24e5595571))

*   Remover o método obsoleto `capify!` nos geradores e modelos.
    ([Commit](https://github.com/rails/rails/commit/9d39f81d512e0d16a27e2e864ea2dd0e8dc41b17))

*   Remover o `config.secret_token` obsoleto.
    ([Commit](https://github.com/rails/rails/commit/46ac5fe69a20d4539a15929fe48293e1809a26b0))

### Obsolescências

*   Obsoleto passar o nome do servidor Rack como um argumento regular para `rails server`.
    ([Pull Request](https://github.com/rails/rails/pull/32058))

*   Obsoleto o suporte ao uso do ambiente `HOST` para especificar o IP do servidor.
    ([Pull Request](https://github.com/rails/rails/pull/32540))

*   Obsoleto acessar hashes retornados por `config_for` por chaves não simbólicas.
    ([Pull Request](https://github.com/rails/rails/pull/35198))

### Mudanças notáveis

*   Adicionar uma opção explícita `--using` ou `-u` para especificar o servidor para o comando `rails server`.
    ([Pull Request](https://github.com/rails/rails/pull/32058))

*   Adicionar a capacidade de ver a saída de `rails routes` no formato expandido.
    ([Pull Request](https://github.com/rails/rails/pull/32130))

*   Executar a tarefa de seed do banco de dados usando o adaptador Active Job inline.
    ([Pull Request](https://github.com/rails/rails/pull/34953))

*   Adicionar um comando `rails db:system:change` para alterar o banco de dados do aplicativo.
    ([Pull Request](https://github.com/rails/rails/pull/34832))

*   Adicionar o comando `rails test:channels` para testar apenas os canais do Action Cable.
    ([Pull Request](https://github.com/rails/rails/pull/34947))
*   Introduzir proteção contra ataques de rebinding DNS.
    ([Pull Request](https://github.com/rails/rails/pull/33145))

*   Adicionar capacidade de abortar em caso de falha ao executar comandos do gerador.
    ([Pull Request](https://github.com/rails/rails/pull/34420))

*   Tornar o Webpacker o compilador JavaScript padrão para o Rails 6.
    ([Pull Request](https://github.com/rails/rails/pull/33079))

*   Adicionar suporte a múltiplos bancos de dados para o comando `rails db:migrate:status`.
    ([Pull Request](https://github.com/rails/rails/pull/34137))

*   Adicionar capacidade de usar caminhos de migração diferentes de múltiplos bancos de dados nos geradores.
    ([Pull Request](https://github.com/rails/rails/pull/34021))

*   Adicionar suporte para credenciais de vários ambientes.
    ([Pull Request](https://github.com/rails/rails/pull/33521))

*   Tornar `null_store` o armazenamento de cache padrão no ambiente de teste.
    ([Pull Request](https://github.com/rails/rails/pull/33773))

Action Cable
------------

Consulte o [Changelog][action-cable] para obter alterações detalhadas.

### Remoções

*   Substituir `ActionCable.startDebugging()` e `ActionCable.stopDebugging()`
    por `ActionCable.logger.enabled`.
    ([Pull Request](https://github.com/rails/rails/pull/34370))

### Depreciações

*   Não há depreciações para o Action Cable no Rails 6.0.

### Mudanças notáveis

*   Adicionar suporte para a opção `channel_prefix` para adaptadores de assinatura do PostgreSQL
    em `cable.yml`.
    ([Pull Request](https://github.com/rails/rails/pull/35276))

*   Permitir passar uma configuração personalizada para `ActionCable::Server::Base`.
    ([Pull Request](https://github.com/rails/rails/pull/34714))

*   Adicionar ganchos de carregamento `:action_cable_connection` e `:action_cable_channel`.
    ([Pull Request](https://github.com/rails/rails/pull/35094))

*   Adicionar `Channel::Base#broadcast_to` e `Channel::Base.broadcasting_for`.
    ([Pull Request](https://github.com/rails/rails/pull/35021))

*   Fechar uma conexão ao chamar `reject_unauthorized_connection` de uma
    `ActionCable::Connection`.
    ([Pull Request](https://github.com/rails/rails/pull/34194))

*   Converter o pacote JavaScript do Action Cable de CoffeeScript para ES2015 e
    publicar o código-fonte na distribuição npm.
    ([Pull Request](https://github.com/rails/rails/pull/34370))

*   Mover a configuração do adaptador WebSocket e adaptador de log
    de propriedades de `ActionCable` para `ActionCable.adapters`.
    ([Pull Request](https://github.com/rails/rails/pull/34370))

*   Adicionar uma opção `id` ao adaptador Redis para distinguir as conexões Redis do Action Cable.
    ([Pull Request](https://github.com/rails/rails/pull/33798))

Action Pack
-----------

Consulte o [Changelog][action-pack] para obter alterações detalhadas.

### Remoções

*   Remover o auxiliar `fragment_cache_key` obsoleto em favor de `combined_fragment_cache_key`.
    ([Commit](https://github.com/rails/rails/commit/e70d3df7c9b05c129b0fdcca57f66eca316c5cfc))

*   Remover métodos obsoletos em `ActionDispatch::TestResponse`:
    `#success?` em favor de `#successful?`, `#missing?` em favor de `#not_found?`,
    `#error?` em favor de `#server_error?`.
    ([Commit](https://github.com/rails/rails/commit/13ddc92e079e59a0b894e31bf5bb4fdecbd235d1))

### Depreciações

*   Depreciar `ActionDispatch::Http::ParameterFilter` em favor de `ActiveSupport::ParameterFilter`.
    ([Pull Request](https://github.com/rails/rails/pull/34039))

*   Depreciar `force_ssl` no nível do controlador em favor de `config.force_ssl`.
    ([Pull Request](https://github.com/rails/rails/pull/32277))

### Mudanças notáveis

*   Alterar `ActionDispatch::Response#content_type` para retornar o cabeçalho Content-Type como está.
    ([Pull Request](https://github.com/rails/rails/pull/36034))

*   Gerar um `ArgumentError` se um parâmetro de recurso contiver dois pontos.
    ([Pull Request](https://github.com/rails/rails/pull/35236))

*   Permitir que `ActionDispatch::SystemTestCase.driven_by` seja chamado com um bloco
    para definir capacidades específicas do navegador.
    ([Pull Request](https://github.com/rails/rails/pull/35081))

*   Adicionar middleware `ActionDispatch::HostAuthorization` que protege contra ataques de rebinding DNS.
    ([Pull Request](https://github.com/rails/rails/pull/33145))

*   Permitir o uso de `parsed_body` em `ActionController::TestCase`.
    ([Pull Request](https://github.com/rails/rails/pull/34717))

*   Gerar um `ArgumentError` quando várias rotas raiz existirem no mesmo contexto
    sem especificações de nomeação `as:`.
    ([Pull Request](https://github.com/rails/rails/pull/34494))

*   Permitir o uso de `#rescue_from` para lidar com erros de análise de parâmetros.
    ([Pull Request](https://github.com/rails/rails/pull/34341))

*   Adicionar `ActionController::Parameters#each_value` para iterar pelos parâmetros.
    ([Pull Request](https://github.com/rails/rails/pull/33979))

*   Codificar os nomes de arquivo do Content-Disposition em `send_data` e `send_file`.
    ([Pull Request](https://github.com/rails/rails/pull/33829))

*   Expor `ActionController::Parameters#each_key`.
    ([Pull Request](https://github.com/rails/rails/pull/33758))

*   Adicionar metadados de propósito e expiração dentro de cookies assinados/criptografados para evitar a cópia do valor
    de cookies em outros cookies.
    ([Pull Request](https://github.com/rails/rails/pull/32937))

*   Gerar `ActionController::RespondToMismatchError` para invocações conflitantes de `respond_to`.
    ([Pull Request](https://github.com/rails/rails/pull/33446))

*   Adicionar uma página de erro explícita quando um modelo está ausente para um formato de solicitação.
    ([Pull Request](https://github.com/rails/rails/pull/29286))

*   Introduzir `ActionDispatch::DebugExceptions.register_interceptor`, uma maneira de se conectar a
    DebugExceptions e processar a exceção antes de ser renderizada.
    ([Pull Request](https://github.com/rails/rails/pull/23868))

*   Saida apenas um valor de cabeçalho Content-Security-Policy nonce por solicitação.
    ([Pull Request](https://github.com/rails/rails/pull/32602))

*   Adicionar um módulo especificamente para a configuração padrão de cabeçalhos do Rails
    que pode ser incluído explicitamente em controladores.
    ([Pull Request](https://github.com/rails/rails/pull/32484))
*   Adicione `#dig` a `ActionDispatch::Request::Session`.
    ([Pull Request](https://github.com/rails/rails/pull/32446))

Action View
-----------

Consulte o [Changelog][action-view] para obter detalhes das alterações.

### Remoções

*   Remova o auxiliar `image_alt` obsoleto.
    ([Commit](https://github.com/rails/rails/commit/60c8a03c8d1e45e48fcb1055ba4c49ed3d5ff78f))

*   Remova um módulo vazio `RecordTagHelper` do qual a funcionalidade
    já foi movida para a gem `record_tag_helper`.
    ([Commit](https://github.com/rails/rails/commit/5c5ddd69b1e06fb6b2bcbb021e9b8dae17e7cb31))

### Depreciações

*   Deprecie `ActionView::Template.finalize_compiled_template_methods` sem
    substituição.
    ([Pull Request](https://github.com/rails/rails/pull/35036))

*   Deprecie `config.action_view.finalize_compiled_template_methods` sem
    substituição.
    ([Pull Request](https://github.com/rails/rails/pull/35036))

*   Deprecie a chamada de métodos privados do modelo do auxiliar de visualização `options_from_collection_for_select`.
    ([Pull Request](https://github.com/rails/rails/pull/33547))

### Mudanças notáveis

*   Limpe o cache do Action View apenas em desenvolvimento quando houver alterações de arquivo, acelerando
    o modo de desenvolvimento.
    ([Pull Request](https://github.com/rails/rails/pull/35629))

*   Mova todos os pacotes npm do Rails para um escopo `@rails`.
    ([Pull Request](https://github.com/rails/rails/pull/34905))

*   Aceite apenas formatos de tipos MIME registrados.
    ([Pull Request](https://github.com/rails/rails/pull/35604), [Pull Request](https://github.com/rails/rails/pull/35753))

*   Adicione alocações à saída do servidor para renderização de templates e parciais.
    ([Pull Request](https://github.com/rails/rails/pull/34136))

*   Adicione a opção `year_format` à tag `date_select`, tornando possível
    personalizar os nomes dos anos.
    ([Pull Request](https://github.com/rails/rails/pull/32190))

*   Adicione a opção `nonce: true` para o auxiliar `javascript_include_tag` para
    suportar a geração automática de nonce para uma Política de Segurança de Conteúdo.
    ([Pull Request](https://github.com/rails/rails/pull/32607))

*   Adicione a configuração `action_view.finalize_compiled_template_methods` para desabilitar ou
    habilitar os finalizadores de `ActionView::Template`.
    ([Pull Request](https://github.com/rails/rails/pull/32418))

*   Extraia a chamada JavaScript `confirm` para seu próprio método substituível em `rails_ujs`.
    ([Pull Request](https://github.com/rails/rails/pull/32404))

*   Adicione a opção de configuração `action_controller.default_enforce_utf8` para lidar
    com a aplicação da codificação UTF-8. O valor padrão é `false`.
    ([Pull Request](https://github.com/rails/rails/pull/32125))

*   Adicione suporte ao estilo de chave I18n para chaves de localização em tags de envio.
    ([Pull Request](https://github.com/rails/rails/pull/26799))

Action Mailer
-------------

Consulte o [Changelog][action-mailer] para obter detalhes das alterações.

### Remoções

### Depreciações

*   Deprecie `ActionMailer::Base.receive` em favor do Action Mailbox.
    ([Commit](https://github.com/rails/rails/commit/e3f832a7433a291a51c5df397dc3dd654c1858cb))

*   Deprecie `DeliveryJob` e `Parameterized::DeliveryJob` em favor de
    `MailDeliveryJob`.
    ([Pull Request](https://github.com/rails/rails/pull/34591))

### Mudanças notáveis

*   Adicione `MailDeliveryJob` para enviar emails regulares e parametrizados.
    ([Pull Request](https://github.com/rails/rails/pull/34591))

*   Permita que trabalhos de entrega de email personalizados funcionem com as asserções de teste do Action Mailer.
    ([Pull Request](https://github.com/rails/rails/pull/34339))

*   Permita especificar um nome de template para emails multipartes com blocos em vez de
    usar apenas o nome da ação.
    ([Pull Request](https://github.com/rails/rails/pull/22534))

*   Adicione `perform_deliveries` à carga útil da notificação `deliver.action_mailer`.
    ([Pull Request](https://github.com/rails/rails/pull/33824))

*   Melhore a mensagem de log quando `perform_deliveries` é falso para indicar
    que o envio de emails foi pulado.
    ([Pull Request](https://github.com/rails/rails/pull/33824))

*   Permita chamar `assert_enqueued_email_with` sem bloco.
    ([Pull Request](https://github.com/rails/rails/pull/33258))

*   Execute os trabalhos de entrega de email enfileirados no bloco `assert_emails`.
    ([Pull Request](https://github.com/rails/rails/pull/32231))

*   Permita que `ActionMailer::Base` cancele o registro de observadores e interceptadores.
    ([Pull Request](https://github.com/rails/rails/pull/32207))

Active Record
-------------

Consulte o [Changelog][active-record] para obter detalhes das alterações.

### Remoções

*   Remova `#set_state` obsoleto do objeto de transação.
    ([Commit](https://github.com/rails/rails/commit/6c745b0c5152a4437163a67707e02f4464493983))

*   Remova `#supports_statement_cache?` obsoleto dos adaptadores de banco de dados.
    ([Commit](https://github.com/rails/rails/commit/5f3ed8784383fb4eb0f9959f31a9c28a991b7553))

*   Remova `#insert_fixtures` obsoleto dos adaptadores de banco de dados.
    ([Commit](https://github.com/rails/rails/commit/400ba786e1d154448235f5f90183e48a1043eece))

*   Remova `ActiveRecord::ConnectionAdapters::SQLite3Adapter#valid_alter_table_type?` obsoleto.
    ([Commit](https://github.com/rails/rails/commit/45b4d5f81f0c0ca72c18d0dea4a3a7b2ecc589bf))

*   Remova o suporte para passar o nome da coluna para `sum` quando um bloco é passado.
    ([Commit](https://github.com/rails/rails/commit/91ddb30083430622188d76eb9f29b78131df67f9))

*   Remova o suporte para passar o nome da coluna para `count` quando um bloco é passado.
    ([Commit](https://github.com/rails/rails/commit/67356f2034ab41305af7218f7c8b2fee2d614129))

*   Remova o suporte para delegação de métodos ausentes em uma relação para Arel.
    ([Commit](https://github.com/rails/rails/commit/d97980a16d76ad190042b4d8578109714e9c53d0))

*   Remova o suporte para delegar métodos ausentes em uma relação para métodos privados da classe.
    ([Commit](https://github.com/rails/rails/commit/a7becf147afc85c354e5cfa519911a948d25fc4d))

*   Remova o suporte para especificar um nome de timestamp para `#cache_key`.
    ([Commit](https://github.com/rails/rails/commit/0bef23e630f62e38f20b5ae1d1d5dbfb087050ea))

*   Remova `ActiveRecord::Migrator.migrations_path=`.
    ([Commit](https://github.com/rails/rails/commit/90d7842186591cae364fab3320b524e4d31a7d7d))
*   Remova o método `expand_hash_conditions_for_aggregates` obsoleto.
    ([Commit](https://github.com/rails/rails/commit/27b252d6a85e300c7236d034d55ec8e44f57a83e))


### Depreciações

*   Depreciar comparações de colações com sensibilidade a maiúsculas e minúsculas para validação de unicidade.
    ([Commit](https://github.com/rails/rails/commit/9def05385f1cfa41924bb93daa187615e88c95b9))

*   Depreciar o uso de métodos de consulta em nível de classe se o escopo do receptor tiver vazado.
    ([Pull Request](https://github.com/rails/rails/pull/35280))

*   Depreciar `config.active_record.sqlite3.represent_boolean_as_integer`.
    ([Commit](https://github.com/rails/rails/commit/f59b08119bc0c01a00561d38279b124abc82561b))

*   Depreciar a passagem de `migrations_paths` para `connection.assume_migrated_upto_version`.
    ([Commit](https://github.com/rails/rails/commit/c1b14aded27e063ead32fa911aa53163d7cfc21a))

*   Depreciar `ActiveRecord::Result#to_hash` em favor de `ActiveRecord::Result#to_a`.
    ([Commit](https://github.com/rails/rails/commit/16510d609c601aa7d466809f3073ec3313e08937))

*   Depreciar métodos em `DatabaseLimits`: `column_name_length`, `table_name_length`,
    `columns_per_table`, `indexes_per_table`, `columns_per_multicolumn_index`,
    `sql_query_length` e `joins_per_query`.
    ([Commit](https://github.com/rails/rails/commit/e0a1235f7df0fa193c7e299a5adee88db246b44f))

*   Depreciar `update_attributes`/`!` em favor de `update`/`!`.
    ([Commit](https://github.com/rails/rails/commit/5645149d3a27054450bd1130ff5715504638a5f5))

### Mudanças notáveis

*   Aumente a versão mínima da gema `sqlite3` para 1.4.
    ([Pull Request](https://github.com/rails/rails/pull/35844))

*   Adicione `rails db:prepare` para criar um banco de dados se ele não existir e executar suas migrações.
    ([Pull Request](https://github.com/rails/rails/pull/35768))

*   Adicione o callback `after_save_commit` como atalho para `after_commit :hook, on: [ :create, :update ]`.
    ([Pull Request](https://github.com/rails/rails/pull/35804))

*   Adicione `ActiveRecord::Relation#extract_associated` para extrair registros associados de uma relação.
    ([Pull Request](https://github.com/rails/rails/pull/35784))

*   Adicione `ActiveRecord::Relation#annotate` para adicionar comentários SQL às consultas de ActiveRecord::Relation.
    ([Pull Request](https://github.com/rails/rails/pull/35617))

*   Adicione suporte para definir Dicas de Otimização em bancos de dados.
    ([Pull Request](https://github.com/rails/rails/pull/35615))

*   Adicione os métodos `insert_all`/`insert_all!`/`upsert_all` para fazer inserções em massa.
    ([Pull Request](https://github.com/rails/rails/pull/35631))

*   Adicione `rails db:seed:replant` que trunca as tabelas de cada banco de dados
    para o ambiente atual e carrega as sementes.
    ([Pull Request](https://github.com/rails/rails/pull/34779))

*   Adicione o método `reselect`, que é uma forma abreviada de `unscope(:select).select(fields)`.
    ([Pull Request](https://github.com/rails/rails/pull/33611))

*   Adicione escopos negativos para todos os valores de enumeração.
    ([Pull Request](https://github.com/rails/rails/pull/35381))

*   Adicione `#destroy_by` e `#delete_by` para remoções condicionais.
    ([Pull Request](https://github.com/rails/rails/pull/35316))

*   Adicione a capacidade de alternar automaticamente as conexões do banco de dados.
    ([Pull Request](https://github.com/rails/rails/pull/35073))

*   Adicione a capacidade de impedir gravações em um banco de dados durante a execução de um bloco.
    ([Pull Request](https://github.com/rails/rails/pull/34505))

*   Adicione uma API para alternar conexões para suportar vários bancos de dados.
    ([Pull Request](https://github.com/rails/rails/pull/34052))

*   Torne os timestamps com precisão o padrão para migrações.
    ([Pull Request](https://github.com/rails/rails/pull/34970))

*   Suporte à opção `:size` para alterar o tamanho de texto e blob no MySQL.
    ([Pull Request](https://github.com/rails/rails/pull/35071))

*   Defina tanto a chave estrangeira quanto as colunas de tipo estrangeiro como NULL para
    associações polimórficas na estratégia `dependent: :nullify`.
    ([Pull Request](https://github.com/rails/rails/pull/28078))

*   Permita que uma instância permitida de `ActionController::Parameters` seja passada como argumento para `ActiveRecord::Relation#exists?`.
    ([Pull Request](https://github.com/rails/rails/pull/34891))

*   Adicione suporte em `#where` para faixas infinitas introduzidas no Ruby 2.6.
    ([Pull Request](https://github.com/rails/rails/pull/34906))

*   Torne `ROW_FORMAT=DYNAMIC` uma opção padrão para criar tabela no MySQL.
    ([Pull Request](https://github.com/rails/rails/pull/34742))

*   Adicione a capacidade de desabilitar escopos gerados por `ActiveRecord.enum`.
    ([Pull Request](https://github.com/rails/rails/pull/34605))

*   Torne a ordenação implícita configurável para uma coluna.
    ([Pull Request](https://github.com/rails/rails/pull/34480))

*   Aumente a versão mínima do PostgreSQL para 9.3, removendo o suporte para 9.1 e 9.2.
    ([Pull Request](https://github.com/rails/rails/pull/34520))

*   Torne os valores de um enum congelados, gerando um erro ao tentar modificá-los.
    ([Pull Request](https://github.com/rails/rails/pull/34517))

*   Torne o SQL dos erros `ActiveRecord::StatementInvalid` sua própria propriedade de erro
    e inclua os binds SQL como uma propriedade de erro separada.
    ([Pull Request](https://github.com/rails/rails/pull/34468))

*   Adicione uma opção `:if_not_exists` para `create_table`.
    ([Pull Request](https://github.com/rails/rails/pull/31382))

*   Adicione suporte para vários bancos de dados em `rails db:schema:cache:dump`
    e `rails db:schema:cache:clear`.
    ([Pull Request](https://github.com/rails/rails/pull/34181))

*   Adicione suporte para configurações de hash e url no hash de banco de dados de `ActiveRecord::Base.connected_to`.
    ([Pull Request](https://github.com/rails/rails/pull/34196))

*   Adicione suporte para expressões padrão e índices de expressão para o MySQL.
    ([Pull Request](https://github.com/rails/rails/pull/34307))

*   Adicione uma opção `index` para os ajudantes de migração `change_table`.
    ([Pull Request](https://github.com/rails/rails/pull/23593))

*   Corrija a reversão de `transaction` para migrações. Anteriormente, comandos dentro de uma `transaction`
    em uma migração revertida eram executados sem reverter. Essa mudança corrige isso.
    ([Pull Request](https://github.com/rails/rails/pull/31604))
*   Permitir que `ActiveRecord::Base.configurations=` seja definido com um hash simbolizado.
    ([Pull Request](https://github.com/rails/rails/pull/33968))

*   Corrigir o contador de cache para atualizar apenas se o registro for realmente salvo.
    ([Pull Request](https://github.com/rails/rails/pull/33913))

*   Adicionar suporte a índices de expressão para o adaptador SQLite.
    ([Pull Request](https://github.com/rails/rails/pull/33874))

*   Permitir que subclasses redefinam callbacks de autosave para registros associados.
    ([Pull Request](https://github.com/rails/rails/pull/33378))

*   Aumentar a versão mínima do MySQL para 5.5.8.
    ([Pull Request](https://github.com/rails/rails/pull/33853))

*   Usar o conjunto de caracteres utf8mb4 por padrão no MySQL.
    ([Pull Request](https://github.com/rails/rails/pull/33608))

*   Adicionar a capacidade de filtrar dados sensíveis em `#inspect`
    ([Pull Request](https://github.com/rails/rails/pull/33756), [Pull Request](https://github.com/rails/rails/pull/34208))

*   Alterar `ActiveRecord::Base.configurations` para retornar um objeto em vez de um hash.
    ([Pull Request](https://github.com/rails/rails/pull/33637))

*   Adicionar configuração de banco de dados para desabilitar travas de assessoria.
    ([Pull Request](https://github.com/rails/rails/pull/33691))

*   Atualizar o método `alter_table` do adaptador SQLite3 para restaurar chaves estrangeiras.
    ([Pull Request](https://github.com/rails/rails/pull/33585))

*   Permitir que a opção `:to_table` de `remove_foreign_key` seja invertível.
    ([Pull Request](https://github.com/rails/rails/pull/33530))

*   Corrigir valor padrão para tipos de tempo do MySQL com precisão especificada.
    ([Pull Request](https://github.com/rails/rails/pull/33280))

*   Corrigir a opção `touch` para se comportar de forma consistente com o método `Persistence#touch`.
    ([Pull Request](https://github.com/rails/rails/pull/33107))

*   Lançar uma exceção para definições de coluna duplicadas em Migrations.
    ([Pull Request](https://github.com/rails/rails/pull/33029))

*   Aumentar a versão mínima do SQLite para 3.8.
    ([Pull Request](https://github.com/rails/rails/pull/32923))

*   Corrigir registros pai para não serem salvos com registros filhos duplicados.
    ([Pull Request](https://github.com/rails/rails/pull/32952))

*   Garantir que `Associations::CollectionAssociation#size` e `Associations::CollectionAssociation#empty?`
    usem os ids da associação carregada, se presentes.
    ([Pull Request](https://github.com/rails/rails/pull/32617))

*   Adicionar suporte para carregar associações de associações polimórficas quando nem todos os registros têm as associações solicitadas.
    ([Commit](https://github.com/rails/rails/commit/75ef18c67c29b1b51314b6c8a963cee53394080b))

*   Adicionar o método `touch_all` para `ActiveRecord::Relation`.
    ([Pull Request](https://github.com/rails/rails/pull/31513))

*   Adicionar o predicado `ActiveRecord::Base.base_class?`.
    ([Pull Request](https://github.com/rails/rails/pull/32417))

*   Adicionar opções de prefixo/sufixo personalizadas para `ActiveRecord::Store.store_accessor`.
    ([Pull Request](https://github.com/rails/rails/pull/32306))

*   Adicionar `ActiveRecord::Base.create_or_find_by`/`!` para lidar com a condição de corrida SELECT/INSERT em
    `ActiveRecord::Base.find_or_create_by`/`!` usando restrições únicas no banco de dados.
    ([Pull Request](https://github.com/rails/rails/pull/31989))

*   Adicionar `Relation#pick` como atalho para plucks de um único valor.
    ([Pull Request](https://github.com/rails/rails/pull/31941))

Active Storage
--------------

Consulte o [Changelog][active-storage] para obter detalhes das alterações.

### Remoções

### Depreciações

*   Depreciar `config.active_storage.queue` em favor de `config.active_storage.queues.analysis`
    e `config.active_storage.queues.purge`.
    ([Pull Request](https://github.com/rails/rails/pull/34838))

*   Depreciar `ActiveStorage::Downloading` em favor de `ActiveStorage::Blob#open`.
    ([Commit](https://github.com/rails/rails/commit/ee21b7c2eb64def8f00887a9fafbd77b85f464f1))

*   Depreciar o uso direto do `mini_magick` para gerar variantes de imagem em favor de
    `image_processing`.
    ([Commit](https://github.com/rails/rails/commit/697f4a93ad386f9fb7795f0ba68f815f16ebad0f))

*   Depreciar `:combine_options` no transformador ImageProcessing do Active Storage
    sem substituição.
    ([Commit](https://github.com/rails/rails/commit/697f4a93ad386f9fb7795f0ba68f815f16ebad0f))

### Mudanças notáveis

*   Adicionar suporte para gerar variantes de imagem BMP.
    ([Pull Request](https://github.com/rails/rails/pull/36051))

*   Adicionar suporte para gerar variantes de imagem TIFF.
    ([Pull Request](https://github.com/rails/rails/pull/34824))

*   Adicionar suporte para gerar variantes de imagem JPEG progressivas.
    ([Pull Request](https://github.com/rails/rails/pull/34455))

*   Adicionar `ActiveStorage.routes_prefix` para configurar as rotas geradas pelo Active Storage.
    ([Pull Request](https://github.com/rails/rails/pull/33883))

*   Gerar uma resposta 404 Not Found em `ActiveStorage::DiskController#show` quando
    o arquivo solicitado estiver ausente no serviço de disco.
    ([Pull Request](https://github.com/rails/rails/pull/33666))

*   Lançar `ActiveStorage::FileNotFoundError` quando o arquivo solicitado estiver ausente para
    `ActiveStorage::Blob#download` e `ActiveStorage::Blob#open`.
    ([Pull Request](https://github.com/rails/rails/pull/33666))

*   Adicionar uma classe genérica `ActiveStorage::Error` da qual as exceções do Active Storage herdam.
    ([Commit](https://github.com/rails/rails/commit/18425b837149bc0d50f8d5349e1091a623762d6b))

*   Persistir arquivos enviados atribuídos a um registro no armazenamento quando o registro
    for salvo, em vez de imediatamente.
    ([Pull Request](https://github.com/rails/rails/pull/33303))

*   Opcionalmente substituir arquivos existentes em vez de adicioná-los ao atribuir a
    uma coleção de anexos (como em `@user.update!(images: [ … ])`). Use
    `config.active_storage.replace_on_assign_to_many` para controlar esse comportamento.
    ([Pull Request](https://github.com/rails/rails/pull/33303),
     [Pull Request](https://github.com/rails/rails/pull/36716))

*   Adicionar a capacidade de refletir sobre os anexos definidos usando o mecanismo de reflexão existente do Active Record.
    ([Pull Request](https://github.com/rails/rails/pull/33018))
*   Adicione `ActiveStorage::Blob#open`, que faz o download de um blob para um tempfile no disco
    e retorna o tempfile.
    ([Commit](https://github.com/rails/rails/commit/ee21b7c2eb64def8f00887a9fafbd77b85f464f1))

*   Suporte a downloads em streaming do Google Cloud Storage. Requer a versão 1.11+
    da gem `google-cloud-storage`.
    ([Pull Request](https://github.com/rails/rails/pull/32788))

*   Use a gem `image_processing` para variantes do Active Storage. Isso substitui o uso
    do `mini_magick` diretamente.
    ([Pull Request](https://github.com/rails/rails/pull/32471))

Active Model
------------

Consulte o [Changelog][active-model] para obter detalhes das alterações.

### Remoções

### Depreciações

### Mudanças notáveis

*   Adicione uma opção de configuração para personalizar o formato do `ActiveModel::Errors#full_message`.
    ([Pull Request](https://github.com/rails/rails/pull/32956))

*   Adicione suporte para configurar o nome do atributo para `has_secure_password`.
    ([Pull Request](https://github.com/rails/rails/pull/26764))

*   Adicione o método `#slice!` para `ActiveModel::Errors`.
    ([Pull Request](https://github.com/rails/rails/pull/34489))

*   Adicione `ActiveModel::Errors#of_kind?` para verificar a presença de um erro específico.
    ([Pull Request](https://github.com/rails/rails/pull/34866))

*   Corrija o método `ActiveModel::Serializers::JSON#as_json` para timestamps.
    ([Pull Request](https://github.com/rails/rails/pull/31503))

*   Corrija o validador de numericality para continuar usando o valor antes da conversão de tipo, exceto no Active Record.
    ([Pull Request](https://github.com/rails/rails/pull/33654))

*   Corrija a validação de igualdade de numericality de `BigDecimal` e `Float`
    convertendo para `BigDecimal` em ambas as extremidades da validação.
    ([Pull Request](https://github.com/rails/rails/pull/32852))

*   Corrija o valor do ano ao converter um hash de tempo multiparamétrico.
    ([Pull Request](https://github.com/rails/rails/pull/34990))

*   Converta símbolos booleanos falsos em atributos booleanos como false.
    ([Pull Request](https://github.com/rails/rails/pull/35794))

*   Retorne a data correta ao converter parâmetros em `value_from_multiparameter_assignment`
    para `ActiveModel::Type::Date`.
    ([Pull Request](https://github.com/rails/rails/pull/29651))

*   Volte para o locale pai antes de voltar para o namespace `:errors` ao buscar
    traduções de erros.
    ([Pull Request](https://github.com/rails/rails/pull/35424))

Active Support
--------------

Consulte o [Changelog][active-support] para obter detalhes das alterações.

### Remoções

*   Remova o método `#acronym_regex` depreciado de `Inflections`.
    ([Commit](https://github.com/rails/rails/commit/0ce67d3cd6d1b7b9576b07fecae3dd5b422a5689))

*   Remova o método `Module#reachable?` depreciado.
    ([Commit](https://github.com/rails/rails/commit/6eb1d56a333fd2015610d31793ed6281acd66551))

*   Remova `` Kernel#` `` sem substituição.
    ([Pull Request](https://github.com/rails/rails/pull/31253))

### Depreciações

*   Deprecie o uso de argumentos inteiros negativos para `String#first` e
    `String#last`.
    ([Pull Request](https://github.com/rails/rails/pull/33058))

*   Deprecie `ActiveSupport::Multibyte::Unicode#downcase/upcase/swapcase`
    em favor de `String#downcase/upcase/swapcase`.
    ([Pull Request](https://github.com/rails/rails/pull/34123))

*   Deprecie `ActiveSupport::Multibyte::Unicode#normalize`
    e `ActiveSupport::Multibyte::Chars#normalize` em favor de
    `String#unicode_normalize`.
    ([Pull Request](https://github.com/rails/rails/pull/34202))

*   Deprecie `ActiveSupport::Multibyte::Chars.consumes?` em favor de
    `String#is_utf8?`.
    ([Pull Request](https://github.com/rails/rails/pull/34215))

*   Deprecie `ActiveSupport::Multibyte::Unicode#pack_graphemes(array)`
    e `ActiveSupport::Multibyte::Unicode#unpack_graphemes(string)`
    em favor de `array.flatten.pack("U*")` e `string.scan(/\X/).map(&:codepoints)`,
    respectivamente.
    ([Pull Request](https://github.com/rails/rails/pull/34254))

### Mudanças notáveis

*   Adicione suporte para testes paralelos.
    ([Pull Request](https://github.com/rails/rails/pull/31900))

*   Certifique-se de que `String#strip_heredoc` preserve a congelamento das strings.
    ([Pull Request](https://github.com/rails/rails/pull/32037))

*   Adicione `String#truncate_bytes` para truncar uma string para um tamanho máximo em bytes
    sem quebrar caracteres multibyte ou agrupamentos de grafemas.
    ([Pull Request](https://github.com/rails/rails/pull/27319))

*   Adicione a opção `private` para o método `delegate` para delegar a
    métodos privados. Essa opção aceita `true/false` como valor.
    ([Pull Request](https://github.com/rails/rails/pull/31944))

*   Adicione suporte para traduções através do I18n para `ActiveSupport::Inflector#ordinal`
    e `ActiveSupport::Inflector#ordinalize`.
    ([Pull Request](https://github.com/rails/rails/pull/32168))

*   Adicione os métodos `before?` e `after?` para `Date`, `DateTime`,
    `Time` e `TimeWithZone`.
    ([Pull Request](https://github.com/rails/rails/pull/32185))

*   Corrija o bug em que `URI.unescape` falharia com entrada de caracteres Unicode/escapados misturados.
    ([Pull Request](https://github.com/rails/rails/pull/32183))

*   Corrija o bug em que `ActiveSupport::Cache` inflaria massivamente o tamanho de armazenamento
    quando a compressão estava ativada.
    ([Pull Request](https://github.com/rails/rails/pull/32539))

*   Redis cache store: `delete_matched` não bloqueia mais o servidor Redis.
    ([Pull Request](https://github.com/rails/rails/pull/32614))

*   Corrija o bug em que `ActiveSupport::TimeZone.all` falharia quando os dados tzinfo para
    qualquer fuso horário definido em `ActiveSupport::TimeZone::MAPPING` estivessem faltando.
    ([Pull Request](https://github.com/rails/rails/pull/32613))

*   Adicione `Enumerable#index_with`, que permite criar um hash a partir de um enumerável
    com o valor de um bloco passado ou um argumento padrão.
    ([Pull Request](https://github.com/rails/rails/pull/32523))

*   Permita que os métodos `Range#===` e `Range#cover?` funcionem com argumento do tipo `Range`.
    ([Pull Request](https://github.com/rails/rails/pull/32938))
*   Adicionar suporte para expiração de chave nas operações `increment/decrement` do RedisCacheStore.
    ([Pull Request](https://github.com/rails/rails/pull/33254))

*   Adicionar recursos de tempo de CPU, tempo ocioso e alocações aos eventos do log subscriber.
    ([Pull Request](https://github.com/rails/rails/pull/33449))

*   Adicionar suporte para objeto de evento ao sistema de notificação do Active Support.
    ([Pull Request](https://github.com/rails/rails/pull/33451))

*   Adicionar suporte para não armazenar em cache entradas `nil` introduzindo a nova opção `skip_nil`
    para `ActiveSupport::Cache#fetch`.
    ([Pull Request](https://github.com/rails/rails/pull/25437))

*   Adicionar método `Array#extract!` que remove e retorna os elementos para os quais
    o bloco retorna um valor verdadeiro.
    ([Pull Request](https://github.com/rails/rails/pull/33137))

*   Manter uma string HTML-segura como HTML-segura após a fatia.
    ([Pull Request](https://github.com/rails/rails/pull/33808))

*   Adicionar suporte para rastrear autoloads constantes por meio de log.
    ([Commit](https://github.com/rails/rails/commit/c03bba4f1f03bad7dc034af555b7f2b329cf76f5))

*   Definir `unfreeze_time` como um alias de `travel_back`.
    ([Pull Request](https://github.com/rails/rails/pull/33813))

*   Alterar `ActiveSupport::TaggedLogging.new` para retornar uma nova instância de logger
    em vez de modificar a recebida como argumento.
    ([Pull Request](https://github.com/rails/rails/pull/27792))

*   Tratar os métodos `#delete_prefix`, `#delete_suffix` e `#unicode_normalize`
    como métodos não seguros para HTML.
    ([Pull Request](https://github.com/rails/rails/pull/33990))

*   Corrigir bug em que `#without` para `ActiveSupport::HashWithIndifferentAccess`
    falharia com argumentos de símbolo.
    ([Pull Request](https://github.com/rails/rails/pull/34012))

*   Renomear `Module#parent`, `Module#parents` e `Module#parent_name` para
    `module_parent`, `module_parents` e `module_parent_name`.
    ([Pull Request](https://github.com/rails/rails/pull/34051))

*   Adicionar `ActiveSupport::ParameterFilter`.
    ([Pull Request](https://github.com/rails/rails/pull/34039))

*   Corrigir problema em que a duração estava sendo arredondada para um segundo inteiro quando um float
    era adicionado à duração.
    ([Pull Request](https://github.com/rails/rails/pull/34135))

*   Fazer de `#to_options` um alias para `#symbolize_keys` em
    `ActiveSupport::HashWithIndifferentAccess`.
    ([Pull Request](https://github.com/rails/rails/pull/34360))

*   Não lançar mais uma exceção se o mesmo bloco for incluído várias vezes
    para um Concern.
    ([Pull Request](https://github.com/rails/rails/pull/34553))

*   Preservar a ordem das chaves passadas para `ActiveSupport::CacheStore#fetch_multi`.
    ([Pull Request](https://github.com/rails/rails/pull/34700))

*   Corrigir `String#safe_constantize` para não lançar um `LoadError` para referências de constantes com caixa incorreta.
    ([Pull Request](https://github.com/rails/rails/pull/34892))

*   Adicionar `Hash#deep_transform_values` e `Hash#deep_transform_values!`.
    ([Commit](https://github.com/rails/rails/commit/b8dc06b8fdc16874160f61dcf58743fcc10e57db))

*   Adicionar `ActiveSupport::HashWithIndifferentAccess#assoc`.
    ([Pull Request](https://github.com/rails/rails/pull/35080))

*   Adicionar callback `before_reset` para `CurrentAttributes` e definir
    `after_reset` como um alias de `resets` para simetria.
    ([Pull Request](https://github.com/rails/rails/pull/35063))

*   Revisar `ActiveSupport::Notifications.unsubscribe` para lidar corretamente
    com assinantes de várias expressões regulares ou outros padrões múltiplos.
    ([Pull Request](https://github.com/rails/rails/pull/32861))

*   Adicionar novo mecanismo de carregamento automático usando o Zeitwerk.
    ([Commit](https://github.com/rails/rails/commit/e53430fa9af239e21e11548499d814f540d421e5))

*   Adicionar `Array#including` e `Enumerable#including` para aumentar convenientemente
    uma coleção.
    ([Commit](https://github.com/rails/rails/commit/bfaa3091c3c32b5980a614ef0f7b39cbf83f6db3))

*   Renomear `Array#without` e `Enumerable#without` para `Array#excluding`
    e `Enumerable#excluding`. Os antigos nomes dos métodos são mantidos como aliases.
    ([Commit](https://github.com/rails/rails/commit/bfaa3091c3c32b5980a614ef0f7b39cbf83f6db3))

*   Adicionar suporte para fornecer `locale` para `transliterate` e `parameterize`.
    ([Pull Request](https://github.com/rails/rails/pull/35571))

*   Corrigir `Time#advance` para funcionar com datas anteriores a 1001-03-07.
    ([Pull Request](https://github.com/rails/rails/pull/35659))

*   Atualizar `ActiveSupport::Notifications::Instrumenter#instrument` para permitir
    não passar um bloco.
    ([Pull Request](https://github.com/rails/rails/pull/35705))

*   Usar referências fracas no rastreador de descendentes para permitir que subclasses anônimas sejam
    coletadas pelo coletor de lixo.
    ([Pull Request](https://github.com/rails/rails/pull/31442))

*   Chamar métodos de teste com o método `with_info_handler` para permitir que o plugin minitest-hooks
    funcione.
    ([Commit](https://github.com/rails/rails/commit/758ba117a008b6ea2d3b92c53b6a7a8d7ccbca69))

*   Preservar o status de `html_safe?` em `ActiveSupport::SafeBuffer#*`.
    ([Pull Request](https://github.com/rails/rails/pull/36012))

Active Job
----------

Consulte o [Changelog][active-job] para obter alterações detalhadas.

### Remoções

*   Remover suporte para a gem Qu.
    ([Pull Request](https://github.com/rails/rails/pull/32300))

### Depreciações

### Mudanças notáveis

*   Adicionar suporte para serializadores personalizados para argumentos do Active Job.
    ([Pull Request](https://github.com/rails/rails/pull/30941))

*   Adicionar suporte para executar Active Jobs no fuso horário em que
    eles foram enfileirados.
    ([Pull Request](https://github.com/rails/rails/pull/32085))

*   Permitir passar várias exceções para `retry_on`/`discard_on`.
    ([Commit](https://github.com/rails/rails/commit/3110caecbebdad7300daaf26bfdff39efda99e25))

*   Permitir chamar `assert_enqueued_with` e `assert_enqueued_email_with` sem um bloco.
    ([Pull Request](https://github.com/rails/rails/pull/33258))

*   Envolver as notificações para `enqueue` e `enqueue_at` no callback `around_enqueue`
    em vez do callback `after_enqueue`.
    ([Pull Request](https://github.com/rails/rails/pull/33171))

*   Permitir chamar `perform_enqueued_jobs` sem um bloco.
    ([Pull Request](https://github.com/rails/rails/pull/33626))

*   Permitir chamar `assert_performed_with` sem um bloco.
    ([Pull Request](https://github.com/rails/rails/pull/33635))
*   Adicione a opção `:queue` às asserções e ajudantes de jobs.
    ([Pull Request](https://github.com/rails/rails/pull/33635))

*   Adicione ganchos para repetições e descartes no Active Job.
    ([Pull Request](https://github.com/rails/rails/pull/33751))

*   Adicione uma maneira de testar um subconjunto de argumentos ao executar jobs.
    ([Pull Request](https://github.com/rails/rails/pull/33995))

*   Inclua argumentos desserializados nos jobs retornados pelos ajudantes de teste do Active Job.
    ([Pull Request](https://github.com/rails/rails/pull/34204))

*   Permita que os ajudantes de asserção do Active Job aceitem um Proc para a palavra-chave `only`.
    ([Pull Request](https://github.com/rails/rails/pull/34339))

*   Remova microssegundos e nanossegundos dos argumentos do job nos ajudantes de asserção.
    ([Pull Request](https://github.com/rails/rails/pull/35713))

Guia do Ruby on Rails
--------------------

Consulte o [Changelog][guides] para obter detalhes das alterações.

### Alterações notáveis

*   Adicione o guia de Múltiplos Bancos de Dados com Active Record.
    ([Pull Request](https://github.com/rails/rails/pull/36389))

*   Adicione uma seção sobre solução de problemas de carregamento automático de constantes.
    ([Commit](https://github.com/rails/rails/commit/c03bba4f1f03bad7dc034af555b7f2b329cf76f5))

*   Adicione o guia de Noções Básicas do Action Mailbox.
    ([Pull Request](https://github.com/rails/rails/pull/34812))

*   Adicione o guia de Visão Geral do Action Text.
    ([Pull Request](https://github.com/rails/rails/pull/34878))

Créditos
-------

Veja a
[lista completa de contribuidores para o Rails](https://contributors.rubyonrails.org/)
para as muitas pessoas que passaram muitas horas fazendo do Rails o framework estável e robusto que ele é. Parabéns a todos eles.

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
