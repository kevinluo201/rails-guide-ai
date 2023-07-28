**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: c7252bf18650c5a9a85fc144305c4615
Notas de lançamento do Ruby on Rails 5.2
=========================================

Destaques do Rails 5.2:

* Active Storage
* Redis Cache Store
* HTTP/2 Early Hints
* Credentials
* Content Security Policy

Estas notas de lançamento abordam apenas as principais mudanças. Para saber sobre várias correções de bugs e mudanças, consulte os registros de alterações ou verifique a [lista de commits](https://github.com/rails/rails/commits/5-2-stable) no repositório principal do Rails no GitHub.

--------------------------------------------------------------------------------

Atualizando para o Rails 5.2
---------------------------

Se você está atualizando um aplicativo existente, é uma ótima ideia ter uma boa cobertura de testes antes de prosseguir. Você também deve primeiro atualizar para o Rails 5.1, caso ainda não tenha feito isso, e garantir que seu aplicativo ainda funcione conforme o esperado antes de tentar atualizar para o Rails 5.2. Uma lista de coisas a serem observadas ao atualizar está disponível no guia [Atualizando o Ruby on Rails](upgrading_ruby_on_rails.html#upgrading-from-rails-5-1-to-rails-5-2).

Recursos Principais
-------------------

### Active Storage

[Pull Request](https://github.com/rails/rails/pull/30020)

[Active Storage](https://github.com/rails/rails/tree/5-2-stable/activestorage) facilita o upload de arquivos para um serviço de armazenamento em nuvem como Amazon S3, Google Cloud Storage ou Microsoft Azure Storage e a anexação desses arquivos a objetos Active Record. Ele vem com um serviço baseado em disco local para desenvolvimento e teste e suporta espelhamento de arquivos para serviços subordinados para backups e migrações. Você pode ler mais sobre o Active Storage no guia [Visão Geral do Active Storage](active_storage_overview.html).

### Redis Cache Store

[Pull Request](https://github.com/rails/rails/pull/31134)

O Rails 5.2 vem com o Redis cache store integrado. Você pode ler mais sobre isso no guia [Cache com Rails: Uma Visão Geral](caching_with_rails.html#activesupport-cache-rediscachestore).

### HTTP/2 Early Hints

[Pull Request](https://github.com/rails/rails/pull/30744)

O Rails 5.2 suporta [HTTP/2 Early Hints](https://tools.ietf.org/html/rfc8297). Para iniciar o servidor com Early Hints habilitado, passe `--early-hints` para `bin/rails server`.

### Credentials

[Pull Request](https://github.com/rails/rails/pull/30067)

Adicionado o arquivo `config/credentials.yml.enc` para armazenar segredos do aplicativo de produção. Isso permite salvar quaisquer credenciais de autenticação para serviços de terceiros diretamente no repositório, criptografadas com uma chave no arquivo `config/master.key` ou na variável de ambiente `RAILS_MASTER_KEY`. Isso eventualmente substituirá `Rails.application.secrets` e os segredos criptografados introduzidos no Rails 5.1. Além disso, o Rails 5.2 [abre a API subjacente das Credentials](https://github.com/rails/rails/pull/30940), para que você possa lidar facilmente com outras configurações, chaves e arquivos criptografados. Você pode ler mais sobre isso no guia [Protegendo Aplicações Rails](security.html#custom-credentials).
### Política de Segurança de Conteúdo

[Solicitação de Pull](https://github.com/rails/rails/pull/31162)

O Rails 5.2 vem com uma nova DSL que permite configurar uma [Política de Segurança de Conteúdo](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Content-Security-Policy) para sua aplicação. Você pode configurar uma política padrão global e, em seguida, substituí-la em uma base por recurso e até mesmo usar lambdas para injetar valores por solicitação no cabeçalho, como subdomínios de conta em uma aplicação multi-inquilino. Você pode ler mais sobre isso no guia [Securing Rails Applications](security.html#content-security-policy).

Railties
--------

Consulte o [Changelog][railties] para obter alterações detalhadas.

### Descontinuações

*   Descontinuar o método `capify!` em geradores e modelos.
    ([Solicitação de Pull](https://github.com/rails/rails/pull/29493))

*   Passar o nome do ambiente como um argumento regular para os comandos `rails dbconsole` e `rails console` está descontinuado. A opção `-e` deve ser usada em seu lugar.
    ([Commit](https://github.com/rails/rails/commit/48b249927375465a7102acc71c2dfb8d49af8309))

*   Descontinuar o uso de subclasses de `Rails::Application` para iniciar o servidor Rails.
    ([Solicitação de Pull](https://github.com/rails/rails/pull/30127))

*   Descontinuar o callback `after_bundle` em modelos de plugins do Rails.
    ([Solicitação de Pull](https://github.com/rails/rails/pull/29446))

### Mudanças notáveis

*   Adicionada uma seção compartilhada ao `config/database.yml` que será carregada para todos os ambientes.
    ([Solicitação de Pull](https://github.com/rails/rails/pull/28896))

*   Adicionar `railtie.rb` ao gerador de plugins.
    ([Solicitação de Pull](https://github.com/rails/rails/pull/29576))

*   Limpar arquivos de captura de tela na tarefa `tmp:clear`.
    ([Solicitação de Pull](https://github.com/rails/rails/pull/29534))

*   Ignorar componentes não utilizados ao executar `bin/rails app:update`. Se a geração inicial do aplicativo ignorou o Action Cable, Active Record, etc., a tarefa de atualização também respeita essas exclusões.
    ([Solicitação de Pull](https://github.com/rails/rails/pull/29645))

*   Permitir passar um nome de conexão personalizado para o comando `rails dbconsole` ao usar uma configuração de banco de dados de 3 níveis. Exemplo: `bin/rails dbconsole -c replica`.
    ([Commit](https://github.com/rails/rails/commit/1acd9a6464668d4d54ab30d016829f60b70dbbeb))

*   Expandir corretamente atalhos para o nome do ambiente ao executar os comandos `console` e `dbconsole`.
    ([Commit](https://github.com/rails/rails/commit/3777701f1380f3814bd5313b225586dec64d4104))

*   Adicionar `bootsnap` ao `Gemfile` padrão.
    ([Solicitação de Pull](https://github.com/rails/rails/pull/29313))

*   Suportar `-` como uma forma independente de plataforma para executar um script a partir da entrada padrão com `rails runner`.
    ([Solicitação de Pull](https://github.com/rails/rails/pull/26343))

*   Adicionar a versão `ruby x.x.x` ao `Gemfile` e criar o arquivo `.ruby-version` na raiz contendo a versão atual do Ruby quando novas aplicações Rails são criadas.
    ([Solicitação de Pull](https://github.com/rails/rails/pull/30016))

*   Adicionar a opção `--skip-action-cable` ao gerador de plugins.
    ([Solicitação de Pull](https://github.com/rails/rails/pull/30164))
*   Adicione `git_source` ao `Gemfile` para o gerador de plugins.
    ([Pull Request](https://github.com/rails/rails/pull/30110))

*   Pule componentes não utilizados ao executar `bin/rails` em um plugin do Rails.
    ([Commit](https://github.com/rails/rails/commit/62499cb6e088c3bc32a9396322c7473a17a28640))

*   Otimize a indentação para ações do gerador.
    ([Pull Request](https://github.com/rails/rails/pull/30166))

*   Otimize a indentação das rotas.
    ([Pull Request](https://github.com/rails/rails/pull/30241))

*   Adicione a opção `--skip-yarn` ao gerador de plugins.
    ([Pull Request](https://github.com/rails/rails/pull/30238))

*   Suporte a múltiplos argumentos de versão para o método `gem` dos Geradores.
    ([Pull Request](https://github.com/rails/rails/pull/30323))

*   Derive `secret_key_base` do nome do aplicativo nos ambientes de desenvolvimento e teste.
    ([Pull Request](https://github.com/rails/rails/pull/30067))

*   Adicione `mini_magick` ao `Gemfile` padrão como comentário.
    ([Pull Request](https://github.com/rails/rails/pull/30633))

*   `rails new` e `rails plugin new` obtêm `Active Storage` por padrão.
    Adicione a capacidade de pular o `Active Storage` com `--skip-active-storage`
    e faça isso automaticamente quando `--skip-active-record` for usado.
    ([Pull Request](https://github.com/rails/rails/pull/30101))

Action Cable
------------

Consulte o [Changelog][action-cable] para obter alterações detalhadas.

### Remoções

*   Removido adaptador de redis com eventos obsoletos.
    ([Commit](https://github.com/rails/rails/commit/48766e32d31651606b9f68a16015ad05c3b0de2c))

### Mudanças notáveis

*   Adicione suporte às opções `host`, `port`, `db` e `password` em cable.yml
    ([Pull Request](https://github.com/rails/rails/pull/29528))

*   Hash identificadores longos de stream ao usar o adaptador PostgreSQL.
    ([Pull Request](https://github.com/rails/rails/pull/29297))

Action Pack
-----------

Consulte o [Changelog][action-pack] para obter alterações detalhadas.

### Remoções

*   Remova `ActionController::ParamsParser::ParseError` obsoleto.
    ([Commit](https://github.com/rails/rails/commit/e16c765ac6dcff068ff2e5554d69ff345c003de1))

### Depreciações

*   Deprecie os aliases `#success?`, `#missing?` e `#error?` de
    `ActionDispatch::TestResponse`.
    ([Pull Request](https://github.com/rails/rails/pull/30104))

### Mudanças notáveis

*   Adicione suporte a chaves de cache recicláveis com cache de fragmentos.
    ([Pull Request](https://github.com/rails/rails/pull/29092))

*   Altere o formato da chave de cache para fragmentos para facilitar a depuração da chave.
    ([Pull Request](https://github.com/rails/rails/pull/29092))

*   Cookies e sessões criptografados AEAD com GCM.
    ([Pull Request](https://github.com/rails/rails/pull/28132))

*   Proteja contra falsificação por padrão.
    ([Pull Request](https://github.com/rails/rails/pull/29742))

*   Expiração de cookies e sessões assinados/criptografados no lado do servidor.
    ([Pull Request](https://github.com/rails/rails/pull/30121))

*   A opção `:expires` dos cookies suporta objetos `ActiveSupport::Duration`.
    ([Pull Request](https://github.com/rails/rails/pull/30121))

*   Use a configuração do servidor `:puma` registrado no Capybara.
    ([Pull Request](https://github.com/rails/rails/pull/30638))

*   Simplifique o middleware de cookies com suporte à rotação de chaves.
    ([Pull Request](https://github.com/rails/rails/pull/29716))

*   Adicione a capacidade de habilitar Early Hints para HTTP/2.
    ([Pull Request](https://github.com/rails/rails/pull/30744))

*   Adicione suporte ao chrome headless aos Testes de Sistema.
    ([Pull Request](https://github.com/rails/rails/pull/30876))

*   Adicione a opção `:allow_other_host` ao método `redirect_back`.
    ([Pull Request](https://github.com/rails/rails/pull/30850))
*   Faça `assert_recognizes` percorrer engines montados.
    ([Pull Request](https://github.com/rails/rails/pull/22435))

*   Adicione DSL para configurar o cabeçalho Content-Security-Policy.
    ([Pull Request](https://github.com/rails/rails/pull/31162),
    [Commit](https://github.com/rails/rails/commit/619b1b6353a65e1635d10b8f8c6630723a5a6f1a),
    [Commit](https://github.com/rails/rails/commit/4ec8bf68ff92f35e79232fbd605012ce1f4e1e6e))

*   Registre os tipos MIME de áudio/vídeo/fonte mais populares suportados pelos navegadores modernos.
    ([Pull Request](https://github.com/rails/rails/pull/31251))

*   Altere a saída padrão de captura de tela dos testes de sistema de `inline` para `simple`.
    ([Commit](https://github.com/rails/rails/commit/9d6e288ee96d6241f864dbf90211c37b14a57632))

*   Adicione suporte ao Firefox sem interface gráfica aos testes de sistema.
    ([Pull Request](https://github.com/rails/rails/pull/31365))

*   Adicione `X-Download-Options` seguro e `X-Permitted-Cross-Domain-Policies` aos cabeçalhos padrão.
    ([Commit](https://github.com/rails/rails/commit/5d7b70f4336d42eabfc403e9f6efceb88b3eff44))

*   Altere os testes de sistema para definir o Puma como servidor padrão apenas quando o usuário não especificar manualmente outro servidor.
    ([Pull Request](https://github.com/rails/rails/pull/31384))

*   Adicione o cabeçalho `Referrer-Policy` aos cabeçalhos padrão.
    ([Commit](https://github.com/rails/rails/commit/428939be9f954d39b0c41bc53d85d0d106b9d1a1))

*   Iguala o comportamento de `Hash#each` em `ActionController::Parameters#each`.
    ([Pull Request](https://github.com/rails/rails/pull/27790))

*   Adicione suporte para geração automática de nonce para o Rails UJS.
    ([Commit](https://github.com/rails/rails/commit/b2f0a8945956cd92dec71ec4e44715d764990a49))

*   Atualize o valor padrão de max-age do HSTS para 31536000 segundos (1 ano)
    para atender ao requisito mínimo de max-age para https://hstspreload.org/.
    ([Commit](https://github.com/rails/rails/commit/30b5f469a1d30c60d1fb0605e84c50568ff7ed37))

*   Adicione o método de alias `to_hash` para `to_h` para `cookies`.
    Adicione o método de alias `to_h` para `to_hash` para `session`.
    ([Commit](https://github.com/rails/rails/commit/50a62499e41dfffc2903d468e8b47acebaf9b500))

Action View
-----------

Consulte o [Changelog][action-view] para obter detalhes das alterações.

### Remoções

*   Remova o manipulador ERB Erubis obsoleto.
    ([Commit](https://github.com/rails/rails/commit/7de7f12fd140a60134defe7dc55b5a20b2372d06))

### Depreciações

*   Deprecie o auxiliar `image_alt` que costumava adicionar texto alt padrão às
    imagens geradas por `image_tag`.
    ([Pull Request](https://github.com/rails/rails/pull/30213))

### Mudanças notáveis

*   Adicione o tipo `:json` ao `auto_discovery_link_tag` para suportar
    [JSON Feeds](https://jsonfeed.org/version/1).
    ([Pull Request](https://github.com/rails/rails/pull/29158))

*   Adicione a opção `srcset` ao auxiliar `image_tag`.
    ([Pull Request](https://github.com/rails/rails/pull/29349))

*   Corrija problemas com `field_error_proc` envolvendo `optgroup` e
    `option` de divisão de seleção.
    ([Pull Request](https://github.com/rails/rails/pull/31088))

*   Altere `form_with` para gerar ids por padrão.
    ([Commit](https://github.com/rails/rails/commit/260d6f112a0ffdbe03e6f5051504cb441c1e94cd))

*   Adicione o auxiliar `preload_link_tag`.
    ([Pull Request](https://github.com/rails/rails/pull/31251))

*   Permita o uso de objetos chamáveis como métodos de grupo para seleções agrupadas.
    ([Pull Request](https://github.com/rails/rails/pull/31578))

Action Mailer
-------------

Consulte o [Changelog][action-mailer] para obter detalhes das alterações.

### Mudanças notáveis

*   Permita que as classes do Action Mailer configurem seu trabalho de entrega.
    ([Pull Request](https://github.com/rails/rails/pull/29457))

*   Adicione o auxiliar de teste `assert_enqueued_email_with`.
    ([Pull Request](https://github.com/rails/rails/pull/30695))

Active Record
-------------
Consulte o [Changelog][active-record] para obter detalhes das alterações.

### Remoções

*   Remova `#migration_keys` obsoleta.
    ([Pull Request](https://github.com/rails/rails/pull/30337))

*   Remova o suporte obsoleto a `quoted_id` ao converter o tipo de um objeto Active Record.
    ([Commit](https://github.com/rails/rails/commit/82472b3922bda2f337a79cef961b4760d04f9689))

*   Remova o argumento obsoleto `default` de `index_name_exists?`.
    ([Commit](https://github.com/rails/rails/commit/8f5b34df81175e30f68879479243fbce966122d7))

*   Remova o suporte obsoleto ao passar uma classe para `:class_name` em associações.
    ([Commit](https://github.com/rails/rails/commit/e65aff70696be52b46ebe57207ebd8bb2cfcdbb6))

*   Remova os métodos obsoletos `initialize_schema_migrations_table` e `initialize_internal_metadata_table`.
    ([Commit](https://github.com/rails/rails/commit/c9660b5777707658c414b430753029cd9bc39934))

*   Remova o método obsoleto `supports_migrations?`.
    ([Commit](https://github.com/rails/rails/commit/9438c144b1893f2a59ec0924afe4d46bd8d5ffdd))

*   Remova o método obsoleto `supports_primary_key?`.
    ([Commit](https://github.com/rails/rails/commit/c56ff22fc6e97df4656ddc22909d9bf8b0c2cbb1))

*   Remova o método obsoleto `ActiveRecord::Migrator.schema_migrations_table_name`.
    ([Commit](https://github.com/rails/rails/commit/7df6e3f3cbdea9a0460ddbab445c81fbb1cfd012))

*   Remova o argumento obsoleto `name` de `#indexes`.
    ([Commit](https://github.com/rails/rails/commit/d6b779ecebe57f6629352c34bfd6c442ac8fba0e))

*   Remova os argumentos obsoletos de `#verify!`.
    ([Commit](https://github.com/rails/rails/commit/9c6ee1bed0292fc32c23dc1c68951ae64fc510be))

*   Remova a configuração obsoleta `.error_on_ignored_order_or_limit`.
    ([Commit](https://github.com/rails/rails/commit/e1066f450d1a99c9a0b4d786b202e2ca82a4c3b3))

*   Remova o método obsoleto `#scope_chain`.
    ([Commit](https://github.com/rails/rails/commit/ef7784752c5c5efbe23f62d2bbcc62d4fd8aacab))

*   Remova o método obsoleto `#sanitize_conditions`.
    ([Commit](https://github.com/rails/rails/commit/8f5413b896099f80ef46a97819fe47a820417bc2))

### Depreciações

*   Deprecie `supports_statement_cache?`.
    ([Pull Request](https://github.com/rails/rails/pull/28938))

*   Deprecie a passagem de argumentos e bloco ao mesmo tempo para `count` e `sum` em `ActiveRecord::Calculations`.
    ([Pull Request](https://github.com/rails/rails/pull/29262))

*   Deprecie a delegação para `arel` em `Relation`.
    ([Pull Request](https://github.com/rails/rails/pull/29619))

*   Deprecie o método `set_state` em `TransactionState`.
    ([Commit](https://github.com/rails/rails/commit/608ebccf8f6314c945444b400a37c2d07f21b253))

*   Deprecie o método `expand_hash_conditions_for_aggregates` sem substituição.
    ([Commit](https://github.com/rails/rails/commit/7ae26885d96daee3809d0bd50b1a440c2f5ffb69))

### Mudanças notáveis

*   Ao chamar o método de acesso dinâmico ao fixture sem argumentos, agora ele retorna todos os fixtures desse tipo. Anteriormente, esse método sempre retornava um array vazio.
    ([Pull Request](https://github.com/rails/rails/pull/28692))

*   Corrija a inconsistência com atributos alterados ao substituir o leitor de atributos do Active Record.
    ([Pull Request](https://github.com/rails/rails/pull/28661))

*   Suporte a índices descendentes para o MySQL.
    ([Pull Request](https://github.com/rails/rails/pull/28773))

*   Corrija a primeira migração do `bin/rails db:forward`.
    ([Commit](https://github.com/rails/rails/commit/b77d2aa0c336492ba33cbfade4964ba0eda3ef84))

*   Gere um erro `UnknownMigrationVersionError` ao mover migrações quando a migração atual não existe.
    ([Commit](https://github.com/rails/rails/commit/bb9d6eb094f29bb94ef1f26aa44f145f17b973fe))

*   Respeite `SchemaDumper.ignore_tables` nas tarefas do rake para o dump da estrutura do banco de dados.
    ([Pull Request](https://github.com/rails/rails/pull/29077))

*   Adicione `ActiveRecord::Base#cache_version` para suportar chaves de cache recicláveis através das novas entradas versionadas em `ActiveSupport::Cache`. Isso também significa que `ActiveRecord::Base#cache_key` agora retornará uma chave estável que não inclui mais um carimbo de data e hora.
    ([Pull Request](https://github.com/rails/rails/pull/29092))

*   Evite a criação de parâmetros de ligação se o valor convertido for nulo.
    ([Pull Request](https://github.com/rails/rails/pull/29282))

*   Use o INSERT em massa para inserir fixtures para melhor desempenho.
    ([Pull Request](https://github.com/rails/rails/pull/29504))
*   A fusão de duas relações que representam junções aninhadas não transforma mais as junções da relação fundida em LEFT OUTER JOIN.
    ([Pull Request](https://github.com/rails/rails/pull/27063))

*   Corrigir transações para aplicar estado às transações filhas.
    Anteriormente, se você tivesse uma transação aninhada e a transação externa fosse revertida, o registro da transação interna ainda seria marcado como persistente. Isso foi corrigido aplicando o estado da transação pai à transação filha quando a transação pai é revertida. Isso marcará corretamente os registros da transação interna como não persistente.
    ([Commit](https://github.com/rails/rails/commit/0237da287eb4c507d10a0c6d94150093acc52b03))

*   Corrigir carregamento antecipado/precarregamento de associação com escopo incluindo junções.
    ([Pull Request](https://github.com/rails/rails/pull/29413))

*   Impedir que erros gerados por assinantes de notificações `sql.active_record` sejam convertidos em exceções `ActiveRecord::StatementInvalid`.
    ([Pull Request](https://github.com/rails/rails/pull/29692))

*   Ignorar o cache de consultas ao trabalhar com lotes de registros (`find_each`, `find_in_batches`, `in_batches`).
    ([Commit](https://github.com/rails/rails/commit/b83852e6eed5789b23b13bac40228e87e8822b4d))

*   Alterar a serialização booleana do sqlite3 para usar 1 e 0.
    O SQLite reconhece nativamente 1 e 0 como verdadeiro e falso, mas não reconhece nativamente 't' e 'f' como era serializado anteriormente.
    ([Pull Request](https://github.com/rails/rails/pull/29699))

*   Os valores construídos usando atribuição de vários parâmetros agora usarão o valor pós-cast para renderização em campos de formulário de único campo.
    ([Commit](https://github.com/rails/rails/commit/1519e976b224871c7f7dd476351930d5d0d7faf6))

*   `ApplicationRecord` não é mais gerado ao gerar modelos. Se você precisar gerá-lo, ele pode ser criado com `rails g application_record`.
    ([Pull Request](https://github.com/rails/rails/pull/29916))

*   `Relation#or` agora aceita duas relações que têm valores diferentes para `references` apenas, pois `references` pode ser chamado implicitamente por `where`.
    ([Commit](https://github.com/rails/rails/commit/ea6139101ccaf8be03b536b1293a9f36bc12f2f7))

*   Ao usar `Relation#or`, extrair as condições comuns e colocá-las antes da condição OR.
    ([Pull Request](https://github.com/rails/rails/pull/29950))

*   Adicionar o método auxiliar de fixture `binary`.
    ([Pull Request](https://github.com/rails/rails/pull/30073))

*   Adivinhar automaticamente as associações inversas para STI.
    ([Pull Request](https://github.com/rails/rails/pull/23425))

*   Adicionar nova classe de erro `LockWaitTimeout` que será levantada quando o tempo limite de espera do bloqueio for excedido.
    ([Pull Request](https://github.com/rails/rails/pull/30360))

*   Atualizar os nomes dos payloads para a instrumentação `sql.active_record` para serem mais descritivos.
    ([Pull Request](https://github.com/rails/rails/pull/30619))

*   Usar o algoritmo fornecido ao remover o índice do banco de dados.
    ([Pull Request](https://github.com/rails/rails/pull/24199))
*   Passar um `Set` para `Relation#where` agora se comporta da mesma forma que passar um array.
    ([Commit](https://github.com/rails/rails/commit/9cf7e3494f5bd34f1382c1ff4ea3d811a4972ae2))

*   O `tsrange` do PostgreSQL agora preserva a precisão de subsegundos.
    ([Pull Request](https://github.com/rails/rails/pull/30725))

*   Gera um erro ao chamar `lock!` em um registro sujo.
    ([Commit](https://github.com/rails/rails/commit/63cf15877bae859ff7b4ebaf05186f3ca79c1863))

*   Corrigido um bug onde a ordem das colunas para um índice não era escrita em `db/schema.rb` ao usar o adaptador SQLite.
    ([Pull Request](https://github.com/rails/rails/pull/30970))

*   Corrigir `bin/rails db:migrate` com `VERSION` especificado.
    `bin/rails db:migrate` com `VERSION` vazio se comporta como sem `VERSION`.
    Verificar o formato de `VERSION`: Permitir um número de versão de migração
    ou nome de um arquivo de migração. Gerar erro se o formato de `VERSION` for inválido.
    Gerar erro se a migração de destino não existir.
    ([Pull Request](https://github.com/rails/rails/pull/30714))

*   Adicionar nova classe de erro `StatementTimeout` que será gerada
    quando o tempo limite da declaração for excedido.
    ([Pull Request](https://github.com/rails/rails/pull/31129))

*   `update_all` agora passará seus valores para `Type#cast` antes de passá-los para
    `Type#serialize`. Isso significa que `update_all(foo: 'true')` irá persistir corretamente um booleano.
    ([Commit](https://github.com/rails/rails/commit/68fe6b08ee72cc47263e0d2c9ff07f75c4b42761))

*   Exigir que fragmentos de SQL brutos sejam marcados explicitamente quando usados em
    métodos de consulta de relação.
    ([Commit](https://github.com/rails/rails/commit/a1ee43d2170dd6adf5a9f390df2b1dde45018a48),
    [Commit](https://github.com/rails/rails/commit/e4a921a75f8702a7dbaf41e31130fe884dea93f9))

*   Adicionar `#up_only` às migrações de banco de dados para código que é relevante apenas ao
    migrar para cima, por exemplo, popular uma nova coluna.
    ([Pull Request](https://github.com/rails/rails/pull/31082))

*   Adicionar nova classe de erro `QueryCanceled` que será gerada
    ao cancelar a declaração devido a uma solicitação do usuário.
    ([Pull Request](https://github.com/rails/rails/pull/31235))

*   Não permitir que escopos sejam definidos em conflito com métodos de instância
    em `Relation`.
    ([Pull Request](https://github.com/rails/rails/pull/31179))

*   Adicionar suporte para classes de operadores do PostgreSQL ao `add_index`.
    ([Pull Request](https://github.com/rails/rails/pull/19090))

*   Registrar os chamadores das consultas do banco de dados.
    ([Pull Request](https://github.com/rails/rails/pull/26815),
    [Pull Request](https://github.com/rails/rails/pull/31519),
    [Pull Request](https://github.com/rails/rails/pull/31690))

*   Desdefinir métodos de atributo nos descendentes ao redefinir informações de coluna.
    ([Pull Request](https://github.com/rails/rails/pull/31475))

*   Usar subseleção para `delete_all` com `limit` ou `offset`.
    ([Commit](https://github.com/rails/rails/commit/9e7260da1bdc0770cf4ac547120c85ab93ff3d48))

*   Corrigida inconsistência com `first(n)` quando usado com `limit()`.
    O localizador `first(n)` agora respeita o `limit()`, tornando-o consistente
    com `relation.to_a.first(n)`, e também com o comportamento de `last(n)`.
    ([Pull Request](https://github.com/rails/rails/pull/27597))

*   Corrigir associações aninhadas `has_many :through` em instâncias pai não persistidas.
    ([Commit](https://github.com/rails/rails/commit/027f865fc8b262d9ba3ee51da3483e94a5489b66))
*   Levar em consideração as condições de associação ao excluir registros.
    ([Commit](https://github.com/rails/rails/commit/ae48c65e411e01c1045056562319666384bb1b63))

*   Não permitir a mutação de objetos destruídos após a chamada de `save` ou `save!`.
    ([Commit](https://github.com/rails/rails/commit/562dd0494a90d9d47849f052e8913f0050f3e494))

*   Corrigir problema de mesclagem de relação com `left_outer_joins`.
    ([Pull Request](https://github.com/rails/rails/pull/27860))

*   Suporte para tabelas estrangeiras do PostgreSQL.
    ([Pull Request](https://github.com/rails/rails/pull/31549))

*   Limpar o estado da transação quando um objeto Active Record é duplicado.
    ([Pull Request](https://github.com/rails/rails/pull/31751))

*   Corrigir problema de não expansão ao passar um objeto Array como argumento
    para o método where usando coluna `composed_of`.
    ([Pull Request](https://github.com/rails/rails/pull/31724))

*   Fazer `reflection.klass` lançar uma exceção se `polymorphic?` não for usado corretamente.
    ([Commit](https://github.com/rails/rails/commit/63fc1100ce054e3e11c04a547cdb9387cd79571a))

*   Corrigir `#columns_for_distinct` do MySQL e PostgreSQL para fazer
    `ActiveRecord::FinderMethods#limited_ids_for` usar os valores corretos da chave primária
    mesmo se as colunas `ORDER BY` incluírem a chave primária de outra tabela.
    ([Commit](https://github.com/rails/rails/commit/851618c15750979a75635530200665b543561a44))

*   Corrigir problema de `dependent: :destroy` para relacionamento has_one/belongs_to onde
    a classe pai estava sendo excluída quando o filho não estava.
    ([Commit](https://github.com/rails/rails/commit/b0fc04aa3af338d5a90608bf37248668d59fc881))

*   Conexões inativas do banco de dados (anteriormente apenas conexões órfãs) agora são
    periodicamente removidas pelo coletor de conexões do pool de conexões.
    ([Commit](https://github.com/rails/rails/pull/31221/commits/9027fafff6da932e6e64ddb828665f4b01fc8902))

Active Model
------------

Consulte o [Changelog][active-model] para obter detalhes das alterações.

### Alterações notáveis

*   Corrigir os métodos `#keys`, `#values` em `ActiveModel::Errors`.
    Alterar `#keys` para retornar apenas as chaves que não possuem mensagens vazias.
    Alterar `#values` para retornar apenas os valores não vazios.
    ([Pull Request](https://github.com/rails/rails/pull/28584))

*   Adicionar o método `#merge!` para `ActiveModel::Errors`.
    ([Pull Request](https://github.com/rails/rails/pull/29714))

*   Permitir passar um Proc ou Symbol para as opções do validador de comprimento.
    ([Pull Request](https://github.com/rails/rails/pull/30674))

*   Executar a validação do `ConfirmationValidator` quando o valor de `_confirmation`
    for `false`.
    ([Pull Request](https://github.com/rails/rails/pull/31058))

*   Modelos que usam a API de atributos com um valor padrão de proc agora podem ser serializados.
    ([Commit](https://github.com/rails/rails/commit/0af36c62a5710e023402e37b019ad9982e69de4b))

*   Não perder todas as múltiplas `:includes` com opções na serialização.
    ([Commit](https://github.com/rails/rails/commit/853054bcc7a043eea78c97e7705a46abb603cc44))

Active Support
--------------

Consulte o [Changelog][active-support] para obter detalhes das alterações.

### Remoções

*   Remover o filtro de string `:if` e `:unless` depreciado para callbacks.
    ([Commit](https://github.com/rails/rails/commit/c792354adcbf8c966f274915c605c6713b840548))

*   Remover a opção `halt_callback_chains_on_return_false` depreciada.
    ([Commit](https://github.com/rails/rails/commit/19fbbebb1665e482d76cae30166b46e74ceafe29))

### Depreciações

*   Depreciar o método `Module#reachable?`.
    ([Pull Request](https://github.com/rails/rails/pull/30624))

*   Depreciar `secrets.secret_token`.
    ([Commit](https://github.com/rails/rails/commit/fbcc4bfe9a211e219da5d0bb01d894fcdaef0a0e))

### Alterações notáveis

*   Adicionar `fetch_values` para `HashWithIndifferentAccess`.
    ([Pull Request](https://github.com/rails/rails/pull/28316))
*   Adicionar suporte para `:offset` ao método `Time#change`.
    ([Commit](https://github.com/rails/rails/commit/851b7f866e13518d900407c78dcd6eb477afad06))

*   Adicionar suporte para `:offset` e `:zone`
    ao método `ActiveSupport::TimeWithZone#change`.
    ([Commit](https://github.com/rails/rails/commit/851b7f866e13518d900407c78dcd6eb477afad06))

*   Passar o nome da gem e o horizonte de depreciação para as notificações de depreciação.
    ([Pull Request](https://github.com/rails/rails/pull/28800))

*   Adicionar suporte para entradas de cache versionadas. Isso permite que os armazenamentos de cache reciclem as chaves de cache, economizando muito espaço de armazenamento em casos com churn frequente. Funciona em conjunto com a separação de `#cache_key` e `#cache_version` no Active Record e seu uso no fragment caching do Action Pack.
    ([Pull Request](https://github.com/rails/rails/pull/29092))

*   Adicionar `ActiveSupport::CurrentAttributes` para fornecer um singleton de atributos isolados por thread. O caso de uso principal é manter todos os atributos por solicitação facilmente disponíveis para todo o sistema.
    ([Pull Request](https://github.com/rails/rails/pull/29180))

*   `#singularize` e `#pluralize` agora respeitam os incontáveis para o local especificado.
    ([Commit](https://github.com/rails/rails/commit/352865d0f835c24daa9a2e9863dcc9dde9e5371a))

*   Adicionar opção padrão para `class_attribute`.
    ([Pull Request](https://github.com/rails/rails/pull/29270))

*   Adicionar `Date#prev_occurring` e `Date#next_occurring` para retornar o próximo/último dia da semana especificado.
    ([Pull Request](https://github.com/rails/rails/pull/26600))

*   Adicionar opção padrão para acessores de atributos de módulo e classe.
    ([Pull Request](https://github.com/rails/rails/pull/29294))

*   Cache: `write_multi`.
    ([Pull Request](https://github.com/rails/rails/pull/29366))

*   Definir o `ActiveSupport::MessageEncryptor` para usar criptografia AES 256 GCM por padrão.
    ([Pull Request](https://github.com/rails/rails/pull/29263))

*   Adicionar helper `freeze_time` que congela o tempo em `Time.now` nos testes.
    ([Pull Request](https://github.com/rails/rails/pull/29681))

*   Tornar a ordem de `Hash#reverse_merge!` consistente com `HashWithIndifferentAccess`.
    ([Pull Request](https://github.com/rails/rails/pull/28077))

*   Adicionar suporte a propósito e expiração para `ActiveSupport::MessageVerifier` e `ActiveSupport::MessageEncryptor`.
    ([Pull Request](https://github.com/rails/rails/pull/29892))

*   Atualizar `String#camelize` para fornecer feedback quando uma opção incorreta é passada.
    ([Pull Request](https://github.com/rails/rails/pull/30039))

*   `Module#delegate_missing_to` agora levanta `DelegationError` se o alvo for nulo, semelhante a `Module#delegate`.
    ([Pull Request](https://github.com/rails/rails/pull/30191))

*   Adicionar `ActiveSupport::EncryptedFile` e `ActiveSupport::EncryptedConfiguration`.
    ([Pull Request](https://github.com/rails/rails/pull/30067))

*   Adicionar `config/credentials.yml.enc` para armazenar segredos de aplicativos de produção.
    ([Pull Request](https://github.com/rails/rails/pull/30067))

*   Adicionar suporte a rotação de chaves para `MessageEncryptor` e `MessageVerifier`.
    ([Pull Request](https://github.com/rails/rails/pull/29716))

*   Retornar uma instância de `HashWithIndifferentAccess` de `HashWithIndifferentAccess#transform_keys`.
    ([Pull Request](https://github.com/rails/rails/pull/30728))

*   `Hash#slice` agora usa a definição nativa do Ruby 2.5+ se definida.
    ([Commit](https://github.com/rails/rails/commit/01ae39660243bc5f0a986e20f9c9bff312b1b5f8))

*   `IO#to_json` agora retorna a representação de `to_s`, em vez de tentar converter para um array. Isso corrige um bug onde `IO#to_json` lançaria um `IOError` quando chamado em um objeto não legível.
    ([Pull Request](https://github.com/rails/rails/pull/30953))
*   Adicione a mesma assinatura de método para `Time#prev_day` e `Time#next_day`
    de acordo com `Date#prev_day`, `Date#next_day`.
    Permite passar argumento para `Time#prev_day` e `Time#next_day`.
    ([Commit](https://github.com/rails/rails/commit/61ac2167eff741bffb44aec231f4ea13d004134e))

*   Adicione a mesma assinatura de método para `Time#prev_month` e `Time#next_month`
    de acordo com `Date#prev_month`, `Date#next_month`.
    Permite passar argumento para `Time#prev_month` e `Time#next_month`.
    ([Commit](https://github.com/rails/rails/commit/f2c1e3a793570584d9708aaee387214bc3543530))

*   Adicione a mesma assinatura de método para `Time#prev_year` e `Time#next_year`
    de acordo com `Date#prev_year`, `Date#next_year`.
    Permite passar argumento para `Time#prev_year` e `Time#next_year`.
    ([Commit](https://github.com/rails/rails/commit/ee9d81837b5eba9d5ec869ae7601d7ffce763e3e))

*   Corrija o suporte a siglas em `humanize`.
    ([Commit](https://github.com/rails/rails/commit/0ddde0a8fca6a0ca3158e3329713959acd65605d))

*   Permita `Range#include?` em intervalos de TWZ.
    ([Pull Request](https://github.com/rails/rails/pull/31081))

*   Cache: Ative a compressão por padrão para valores > 1kB.
    ([Pull Request](https://github.com/rails/rails/pull/31147))

*   Armazenamento de cache Redis.
    ([Pull Request](https://github.com/rails/rails/pull/31134),
    [Pull Request](https://github.com/rails/rails/pull/31866))

*   Trate erros de `TZInfo::AmbiguousTime`.
    ([Pull Request](https://github.com/rails/rails/pull/31128))

*   MemCacheStore: Suporte a expiração de contadores.
    ([Commit](https://github.com/rails/rails/commit/b22ee64b5b30c6d5039c292235e10b24b1057f6d))

*   Faça `ActiveSupport::TimeZone.all` retornar apenas fusos horários que estão em
    `ActiveSupport::TimeZone::MAPPING`.
    ([Pull Request](https://github.com/rails/rails/pull/31176))

*   Alterado o comportamento padrão de `ActiveSupport::SecurityUtils.secure_compare`,
    para não vazar informações de comprimento mesmo para strings de comprimento variável.
    Renomeado o antigo `ActiveSupport::SecurityUtils.secure_compare` para
    `fixed_length_secure_compare`, e começou a lançar `ArgumentError` em
    caso de incompatibilidade de comprimento das strings passadas.
    ([Pull Request](https://github.com/rails/rails/pull/24510))

*   Use SHA-1 para gerar resumos não sensíveis, como o cabeçalho ETag.
    ([Pull Request](https://github.com/rails/rails/pull/31289),
    [Pull Request](https://github.com/rails/rails/pull/31651))

*   `assert_changes` sempre irá verificar se a expressão muda,
    independentemente das combinações de argumentos `from:` e `to:`.
    ([Pull Request](https://github.com/rails/rails/pull/31011))

*   Adicione instrumentação ausente para `read_multi`
    em `ActiveSupport::Cache::Store`.
    ([Pull Request](https://github.com/rails/rails/pull/30268))

*   Suporte a hash como primeiro argumento em `assert_difference`.
    Isso permite especificar várias diferenças numéricas na mesma asserção.
    ([Pull Request](https://github.com/rails/rails/pull/31600))

*   Caching: Aceleração de `read_multi` e `fetch_multi` do MemCache e Redis.
    Leia do cache local em memória antes de consultar o backend.
    ([Commit](https://github.com/rails/rails/commit/a2b97e4ffef971607a1be8fc7909f099b6840f36))

Active Job
----------

Consulte o [Changelog][active-job] para obter detalhes das alterações.

### Alterações notáveis

*   Permita que um bloco seja passado para `ActiveJob::Base.discard_on` para permitir
    manipulação personalizada de descarte de jobs.
    ([Pull Request](https://github.com/rails/rails/pull/30622))

Ruby on Rails Guides
--------------------

Consulte o [Changelog][guides] para obter detalhes das alterações.

### Alterações notáveis

*   Adicione o Guia [Threading and Code Execution in Rails](threading_and_code_execution.html).
    ([Pull Request](https://github.com/rails/rails/pull/27494))

[active-job]: https://github.com/rails/rails/blob/master/activejob/CHANGELOG.md
[guides]: https://github.com/rails/rails/blob/master/guides/source/CHANGELOG.md
*   Adicionar [Visão Geral do Active Storage](active_storage_overview.html) Guia.
    ([Pull Request](https://github.com/rails/rails/pull/31037))

Créditos
-------

Veja a
[lista completa de contribuidores para o Rails](https://contributors.rubyonrails.org/)
para as muitas pessoas que passaram muitas horas fazendo do Rails, o framework estável e robusto que ele é. Parabéns a todos eles.

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
