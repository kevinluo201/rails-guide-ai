**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: ddd82b1a207070829b1ec46e4bb40d80
Notas de lançamento do Ruby on Rails 5.1
========================================

Destaques do Rails 5.1:

* Suporte ao Yarn
* Suporte opcional ao Webpack
* jQuery não é mais uma dependência padrão
* Testes de sistema
* Segredos criptografados
* Mailers parametrizados
* Rotas diretas e resolvidas
* Unificação do form_for e form_tag em form_with

Estas notas de lançamento cobrem apenas as principais mudanças. Para saber sobre várias correções de bugs e mudanças, consulte os changelogs ou confira a [lista de commits](https://github.com/rails/rails/commits/5-1-stable) no repositório principal do Rails no GitHub.

--------------------------------------------------------------------------------

Atualizando para o Rails 5.1
----------------------------

Se você está atualizando um aplicativo existente, é uma ótima ideia ter uma boa cobertura de testes antes de começar. Você também deve primeiro atualizar para o Rails 5.0, caso ainda não tenha feito isso, e garantir que seu aplicativo ainda funcione conforme o esperado antes de tentar uma atualização para o Rails 5.1. Uma lista de coisas a serem observadas ao atualizar está disponível no guia [Atualizando o Ruby on Rails](upgrading_ruby_on_rails.html#upgrading-from-rails-5-0-to-rails-5-1).

Recursos Principais
-------------------

### Suporte ao Yarn

[Pull Request](https://github.com/rails/rails/pull/26836)

O Rails 5.1 permite gerenciar dependências JavaScript do npm via Yarn. Isso facilitará o uso de bibliotecas como React, VueJS ou qualquer outra biblioteca do mundo npm. O suporte ao Yarn está integrado ao pipeline de ativos para que todas as dependências funcionem perfeitamente com o aplicativo Rails 5.1.

### Suporte opcional ao Webpack

[Pull Request](https://github.com/rails/rails/pull/27288)

Os aplicativos Rails podem integrar-se ao [Webpack](https://webpack.js.org/), um empacotador de ativos JavaScript, de forma mais fácil usando a nova gem [Webpacker](https://github.com/rails/webpacker). Use a flag `--webpack` ao gerar novos aplicativos para habilitar a integração com o Webpack.

Isso é totalmente compatível com o pipeline de ativos, que você pode continuar usando para imagens, fontes, sons e outros ativos. Você até pode ter algum código JavaScript gerenciado pelo pipeline de ativos e outro código processado via Webpack. Tudo isso é gerenciado pelo Yarn, que está habilitado por padrão.

### jQuery não é mais uma dependência padrão
[Solicitação de Pull](https://github.com/rails/rails/pull/27113)

O jQuery era necessário por padrão nas versões anteriores do Rails para fornecer recursos como `data-remote`, `data-confirm` e outras partes do JavaScript não intrusivo do Rails. Não é mais necessário, pois o UJS foi reescrito para usar JavaScript puro. Esse código agora é enviado dentro do Action View como `rails-ujs`.

Você ainda pode usar o jQuery, se necessário, mas não é mais necessário por padrão.

### Testes de sistema

[Solicitação de Pull](https://github.com/rails/rails/pull/26703)

O Rails 5.1 possui suporte integrado para escrever testes com Capybara, na forma de testes de sistema. Você não precisa mais se preocupar em configurar o Capybara e as estratégias de limpeza do banco de dados para esses testes. O Rails 5.1 fornece um wrapper para executar testes no Chrome com recursos adicionais, como capturas de tela de falhas.

### Segredos criptografados

[Solicitação de Pull](https://github.com/rails/rails/pull/28038)

O Rails agora permite o gerenciamento de segredos de aplicativos de forma segura, inspirado na gem [sekrets](https://github.com/ahoward/sekrets).

Execute `bin/rails secrets:setup` para configurar um novo arquivo de segredos criptografados. Isso também irá gerar uma chave mestra, que deve ser armazenada fora do repositório. Os segredos em si podem então ser armazenados com segurança no sistema de controle de revisão, em forma criptografada.

Os segredos serão descriptografados em produção, usando uma chave armazenada na variável de ambiente `RAILS_MASTER_KEY` ou em um arquivo de chave.

### Mailers parametrizados

[Solicitação de Pull](https://github.com/rails/rails/pull/27825)

Permite especificar parâmetros comuns usados para todos os métodos em uma classe de mailer, a fim de compartilhar variáveis de instância, cabeçalhos e outras configurações comuns.

```ruby
class InvitationsMailer < ApplicationMailer
  before_action { @inviter, @invitee = params[:inviter], params[:invitee] }
  before_action { @account = params[:inviter].account }

  def account_invitation
    mail subject: "#{@inviter.name} convidou você para o Basecamp deles (#{@account.name})"
  end
end
```

```ruby
InvitationsMailer.with(inviter: person_a, invitee: person_b)
                 .account_invitation.deliver_later
```

### Rotas diretas e resolvidas

[Solicitação de Pull](https://github.com/rails/rails/pull/23138)

O Rails 5.1 adiciona dois novos métodos, `resolve` e `direct`, à DSL de roteamento. O método `resolve` permite personalizar o mapeamento polimórfico de modelos.
```ruby
recurso :basket

resolve("Basket") { [:basket] }
```

```erb
<%= form_for @basket do |form| %>
  <!-- formulário do cesto -->
<% end %>
```

Isso irá gerar a URL singular `/basket` em vez da usual `/baskets/:id`.

O método `direct` permite a criação de helpers de URL personalizados.

```ruby
direct(:homepage) { "https://rubyonrails.org" }

homepage_url # => "https://rubyonrails.org"
```

O valor de retorno do bloco deve ser um argumento válido para o método `url_for`.
Portanto, você pode passar uma URL de string válida, Hash, Array, uma
instância de Active Model ou uma classe de Active Model.

```ruby
direct :commentable do |model|
  [ model, anchor: model.dom_id ]
end

direct :main do
  { controller: 'pages', action: 'index', subdomain: 'www' }
end
```

### Unificação de form_for e form_tag em form_with

[Pull Request](https://github.com/rails/rails/pull/26976)

Antes do Rails 5.1, havia duas interfaces para lidar com formulários HTML:
`form_for` para instâncias de modelos e `form_tag` para URLs personalizadas.

O Rails 5.1 combina essas duas interfaces com `form_with` e
pode gerar tags de formulário com base em URLs, escopos ou modelos.

Usando apenas uma URL:

```erb
<%= form_with url: posts_path do |form| %>
  <%= form.text_field :title %>
<% end %>

<%# Irá gerar %>

<form action="/posts" method="post" data-remote="true">
  <input type="text" name="title">
</form>
```

Adicionando um escopo, os nomes dos campos de entrada são prefixados:

```erb
<%= form_with scope: :post, url: posts_path do |form| %>
  <%= form.text_field :title %>
<% end %>

<%# Irá gerar %>

<form action="/posts" method="post" data-remote="true">
  <input type="text" name="post[title]">
</form>
```

Usando um modelo, o URL e o escopo são inferidos:

```erb
<%= form_with model: Post.new do |form| %>
  <%= form.text_field :title %>
<% end %>

<%# Irá gerar %>

<form action="/posts" method="post" data-remote="true">
  <input type="text" name="post[title]">
</form>
```

Um modelo existente cria um formulário de atualização e preenche os valores dos campos:

```erb
<%= form_with model: Post.first do |form| %>
  <%= form.text_field :title %>
<% end %>

<%# Irá gerar %>

<form action="/posts/1" method="post" data-remote="true">
  <input type="hidden" name="_method" value="patch">
  <input type="text" name="post[title]" value="<o título do post>">
</form>
```
Incompatibilidades
-----------------

As seguintes alterações podem exigir ação imediata após a atualização.

### Testes transacionais com múltiplas conexões

Os testes transacionais agora envolvem todas as conexões do Active Record em transações de banco de dados.

Quando um teste gera threads adicionais e essas threads obtêm conexões de banco de dados, essas conexões agora são tratadas de forma especial:

As threads compartilharão uma única conexão, que está dentro da transação gerenciada. Isso garante que todas as threads vejam o banco de dados no mesmo estado, ignorando a transação mais externa. Anteriormente, essas conexões adicionais não conseguiam ver as linhas de fixture, por exemplo.

Quando uma thread entra em uma transação aninhada, ela temporariamente obtém o uso exclusivo da conexão, para manter o isolamento.

Se seus testes atualmente dependem de obter uma conexão separada, fora da transação, em uma thread gerada, você precisará mudar para um gerenciamento de conexão mais explícito.

Se seus testes geram threads e essas threads interagem enquanto também usam transações de banco de dados explícitas, essa alteração pode introduzir um deadlock.

A maneira fácil de desativar esse novo comportamento é desabilitar os testes transacionais em qualquer caso de teste que seja afetado.

Railties
--------

Consulte o [Changelog][railties] para obter detalhes das alterações.

### Remoções

*   Remover `config.static_cache_control` obsoleto.
    ([commit](https://github.com/rails/rails/commit/c861decd44198f8d7d774ee6a74194d1ac1a5a13))

*   Remover `config.serve_static_files` obsoleto.
    ([commit](https://github.com/rails/rails/commit/0129ca2eeb6d5b2ea8c6e6be38eeb770fe45f1fa))

*   Remover o arquivo obsoleto `rails/rack/debugger`.
    ([commit](https://github.com/rails/rails/commit/7563bf7b46e6f04e160d664e284a33052f9804b8))

*   Remover as tarefas obsoletas: `rails:update`, `rails:template`, `rails:template:copy`,
    `rails:update:configs` e `rails:update:bin`.
    ([commit](https://github.com/rails/rails/commit/f7782812f7e727178e4a743aa2874c078b722eef))

*   Remover a variável de ambiente `CONTROLLER` obsoleta para a tarefa `routes`.
    ([commit](https://github.com/rails/rails/commit/f9ed83321ac1d1902578a0aacdfe55d3db754219))

*   Remover a opção -j (--javascript) do comando `rails new`.
    ([Pull Request](https://github.com/rails/rails/pull/28546))

### Mudanças notáveis

*   Adicionada uma seção compartilhada ao `config/secrets.yml` que será carregada para todos
    os ambientes.
    ([commit](https://github.com/rails/rails/commit/e530534265d2c32b5c5f772e81cb9002dcf5e9cf))

*   O arquivo de configuração `config/secrets.yml` agora é carregado com todas as chaves como símbolos.
    ([Pull Request](https://github.com/rails/rails/pull/26929))

*   Removido o jquery-rails do stack padrão. O rails-ujs, que é enviado
    com o Action View, é incluído como adaptador UJS padrão.
    ([Pull Request](https://github.com/rails/rails/pull/27113))

*   Adicionar suporte ao Yarn em novos aplicativos com um binstub do yarn e package.json.
    ([Pull Request](https://github.com/rails/rails/pull/26836))
*   Adicione suporte ao Webpack em novos aplicativos através da opção `--webpack`, que delegará ao gem rails/webpacker.
    ([Pull Request](https://github.com/rails/rails/pull/27288))

*   Inicialize o repositório Git ao gerar um novo aplicativo, se a opção `--skip-git` não for fornecida.
    ([Pull Request](https://github.com/rails/rails/pull/27632))

*   Adicione segredos criptografados em `config/secrets.yml.enc`.
    ([Pull Request](https://github.com/rails/rails/pull/28038))

*   Exiba o nome da classe railtie em `rails initializers`.
    ([Pull Request](https://github.com/rails/rails/pull/25257))

Action Cable
-----------

Consulte o [Changelog][action-cable] para obter detalhes das alterações.

### Alterações notáveis

*   Adicionado suporte para `channel_prefix` nos adaptadores Redis e Redis com eventos em `cable.yml` para evitar colisões de nomes ao usar o mesmo servidor Redis com vários aplicativos.
    ([Pull Request](https://github.com/rails/rails/pull/27425))

*   Adicione o gancho `ActiveSupport::Notifications` para transmitir dados.
    ([Pull Request](https://github.com/rails/rails/pull/24988))

Action Pack
-----------

Consulte o [Changelog][action-pack] para obter detalhes das alterações.

### Remoções

*   Removido o suporte a argumentos não-chave em `#process`, `#get`, `#post`, `#patch`, `#put`, `#delete` e `#head` para as classes `ActionDispatch::IntegrationTest` e `ActionController::TestCase`.
    ([Commit](https://github.com/rails/rails/commit/98b8309569a326910a723f521911e54994b112fb),
    [Commit](https://github.com/rails/rails/commit/de9542acd56f60d281465a59eac11e15ca8b3323))

*   Removido `ActionDispatch::Callbacks.to_prepare` e `ActionDispatch::Callbacks.to_cleanup` obsoletos.
    ([Commit](https://github.com/rails/rails/commit/3f2b7d60a52ffb2ad2d4fcf889c06b631db1946b))

*   Removidos métodos obsoletos relacionados a filtros de controlador.
    ([Commit](https://github.com/rails/rails/commit/d7be30e8babf5e37a891522869e7b0191b79b757))

*   Removido suporte obsoleto para `:text` e `:nothing` em `render`.
    ([Commit](https://github.com/rails/rails/commit/79a5ea9eadb4d43b62afacedc0706cbe88c54496),
    [Commit](https://github.com/rails/rails/commit/57e1c99a280bdc1b324936a690350320a1cd8111))

*   Removido suporte obsoleto para chamar métodos `HashWithIndifferentAccess` em `ActionController::Parameters`.
    ([Commit](https://github.com/rails/rails/pull/26746/commits/7093ceb480ad6a0a91b511832dad4c6a86981b93))

### Descontinuações

*   Descontinuada `config.action_controller.raise_on_unfiltered_parameters`. Não tem efeito no Rails 5.1.
    ([Commit](https://github.com/rails/rails/commit/c6640fb62b10db26004a998d2ece98baede509e5))

### Alterações notáveis

*   Adicionados os métodos `direct` e `resolve` à DSL de roteamento.
    ([Pull Request](https://github.com/rails/rails/pull/23138))

*   Adicionada uma nova classe `ActionDispatch::SystemTestCase` para escrever testes de sistema em seus aplicativos.
    ([Pull Request](https://github.com/rails/rails/pull/26703))

Action View
-------------

Consulte o [Changelog][action-view] para obter detalhes das alterações.

### Remoções

*   Removido `#original_exception` obsoleto em `ActionView::Template::Error`.
    ([commit](https://github.com/rails/rails/commit/b9ba263e5aaa151808df058f5babfed016a1879f))

*   Remova a opção `encode_special_chars` equivocada de `strip_tags`.
    ([Pull Request](https://github.com/rails/rails/pull/28061))

### Descontinuações

*   Descontinuado o manipulador Erubis ERB em favor de Erubi.
    ([Pull Request](https://github.com/rails/rails/pull/27757))

### Alterações notáveis

*   O manipulador de modelo bruto (o manipulador de modelo padrão no Rails 5) agora gera strings seguras para HTML.
    ([commit](https://github.com/rails/rails/commit/1de0df86695f8fa2eeae6b8b46f9b53decfa6ec8))

*   Altere `datetime_field` e `datetime_field_tag` para gerar campos `datetime-local`.
    ([Pull Request](https://github.com/rails/rails/pull/25469))

*   Nova sintaxe estilo Builder para tags HTML (`tag.div`, `tag.br`, etc.).
    ([Pull Request](https://github.com/rails/rails/pull/25543))
*   Adicione `form_with` para unificar o uso de `form_tag` e `form_for`.
    ([Pull Request](https://github.com/rails/rails/pull/26976))

*   Adicione a opção `check_parameters` para `current_page?`.
    ([Pull Request](https://github.com/rails/rails/pull/27549))

Action Mailer
-------------

Consulte o [Changelog][action-mailer] para obter detalhes das alterações.

### Alterações notáveis

*   Permitido definir um tipo de conteúdo personalizado quando anexos são incluídos
    e o corpo é definido inline.
    ([Pull Request](https://github.com/rails/rails/pull/27227))

*   Permitido passar lambdas como valores para o método `default`.
    ([Commit](https://github.com/rails/rails/commit/1cec84ad2ddd843484ed40b1eb7492063ce71baf))

*   Adicionado suporte para invocação parametrizada de mailers para compartilhar filtros e padrões
    entre diferentes ações de mailer.
    ([Commit](https://github.com/rails/rails/commit/1cec84ad2ddd843484ed40b1eb7492063ce71baf))

*   Passados os argumentos recebidos para a ação do mailer para o evento `process.action_mailer`
    em uma chave `args`.
    ([Pull Request](https://github.com/rails/rails/pull/27900))

Active Record
-------------

Consulte o [Changelog][active-record] para obter detalhes das alterações.

### Remoções

*   Removido suporte para passar argumentos e bloco ao mesmo tempo para
    `ActiveRecord::QueryMethods#select`.
    ([Commit](https://github.com/rails/rails/commit/4fc3366d9d99a0eb19e45ad2bf38534efbf8c8ce))

*   Removidos os escopos de internacionalização `activerecord.errors.messages.restrict_dependent_destroy.one` e
    `activerecord.errors.messages.restrict_dependent_destroy.many` que estavam obsoletos.
    ([Commit](https://github.com/rails/rails/commit/00e3973a311))

*   Removido o argumento de recarregamento forçado obsoleto nos leitores de associação singular e de coleção.
    ([Commit](https://github.com/rails/rails/commit/09cac8c67af))

*   Removido o suporte obsoleto para passar uma coluna para `#quote`.
    ([Commit](https://github.com/rails/rails/commit/e646bad5b7c))

*   Removido o argumento `name` obsoleto de `#tables`.
    ([Commit](https://github.com/rails/rails/commit/d5be101dd02214468a27b6839ffe338cfe8ef5f3))

*   Removido o comportamento obsoleto de `#tables` e `#table_exists?` de retornar apenas tabelas e não visualizações.
    ([Commit](https://github.com/rails/rails/commit/5973a984c369a63720c2ac18b71012b8347479a8))

*   Removido o argumento `original_exception` obsoleto em `ActiveRecord::StatementInvalid#initialize`
    e `ActiveRecord::StatementInvalid#original_exception`.
    ([Commit](https://github.com/rails/rails/commit/bc6c5df4699d3f6b4a61dd12328f9e0f1bd6cf46))

*   Removido o suporte obsoleto para passar uma classe como valor em uma consulta.
    ([Commit](https://github.com/rails/rails/commit/b4664864c972463c7437ad983832d2582186e886))

*   Removido o suporte obsoleto para consulta usando vírgulas no LIMIT.
    ([Commit](https://github.com/rails/rails/commit/fc3e67964753fb5166ccbd2030d7382e1976f393))

*   Removido o parâmetro `conditions` obsoleto de `#destroy_all`.
    ([Commit](https://github.com/rails/rails/commit/d31a6d1384cd740c8518d0bf695b550d2a3a4e9b))

*   Removido o parâmetro `conditions` obsoleto de `#delete_all`.
    ([Commit](https://github.com/rails/rails/pull/27503/commits/e7381d289e4f8751dcec9553dcb4d32153bd922b))

*   Removido o método obsoleto `#load_schema_for` em favor de `#load_schema`.
    ([Commit](https://github.com/rails/rails/commit/419e06b56c3b0229f0c72d3e4cdf59d34d8e5545))

*   Removida a configuração obsoleta `#raise_in_transactional_callbacks`.
    ([Commit](https://github.com/rails/rails/commit/8029f779b8a1dd9848fee0b7967c2e0849bf6e07))

*   Removida a configuração obsoleta `#use_transactional_fixtures`.
    ([Commit](https://github.com/rails/rails/commit/3955218dc163f61c932ee80af525e7cd440514b3))

### Obsolescências

*   Obsoleto o sinalizador `error_on_ignored_order_or_limit`, use
    `error_on_ignored_order` em seu lugar.
    ([Commit](https://github.com/rails/rails/commit/451437c6f57e66cc7586ec966e530493927098c7))

*   Obsoleto `sanitize_conditions`, use `sanitize_sql` em seu lugar.
    ([Pull Request](https://github.com/rails/rails/pull/25999))

*   Obsoleto `supports_migrations?` nos adaptadores de conexão.
    ([Pull Request](https://github.com/rails/rails/pull/28172))

*   Obsoleto `Migrator.schema_migrations_table_name`, use `SchemaMigration.table_name` em seu lugar.
    ([Pull Request](https://github.com/rails/rails/pull/28351))

*   Obsoleto o uso de `#quoted_id` na citação e conversão de tipos.
    ([Pull Request](https://github.com/rails/rails/pull/27962))
*   Depreciado o argumento `default` ao chamar `#index_name_exists?`.
    ([Pull Request](https://github.com/rails/rails/pull/26930))

### Mudanças notáveis

*   Alteração das chaves primárias padrão para BIGINT.
    ([Pull Request](https://github.com/rails/rails/pull/26266))

*   Suporte a colunas virtuais/geradas para MySQL 5.7.5+ e MariaDB 5.2.0+.
    ([Commit](https://github.com/rails/rails/commit/65bf1c60053e727835e06392d27a2fb49665484c))

*   Adicionado suporte a limites no processamento em lote.
    ([Commit](https://github.com/rails/rails/commit/451437c6f57e66cc7586ec966e530493927098c7))

*   Testes transacionais agora envolvem todas as conexões do Active Record em transações de banco de dados.
    ([Pull Request](https://github.com/rails/rails/pull/28726))

*   Comentários são ignorados na saída do comando `mysqldump` por padrão.
    ([Pull Request](https://github.com/rails/rails/pull/23301))

*   Corrigido `ActiveRecord::Relation#count` para usar `Enumerable#count` do Ruby para contar registros quando um bloco é passado como argumento, em vez de ignorar silenciosamente o bloco passado.
    ([Pull Request](https://github.com/rails/rails/pull/24203))

*   Passar a flag `"-v ON_ERROR_STOP=1"` com o comando `psql` para não suprimir erros de SQL.
    ([Pull Request](https://github.com/rails/rails/pull/24773))

*   Adicionado `ActiveRecord::Base.connection_pool.stat`.
    ([Pull Request](https://github.com/rails/rails/pull/26988))

*   Herdar diretamente de `ActiveRecord::Migration` gera um erro. Especifique a versão do Rails para a qual a migração foi escrita.
    ([Commit](https://github.com/rails/rails/commit/249f71a22ab21c03915da5606a063d321f04d4d3))

*   Um erro é gerado quando a associação `through` tem um nome de reflexão ambíguo.
    ([Commit](https://github.com/rails/rails/commit/0944182ad7ed70d99b078b22426cbf844edd3f61))

Active Model
------------

Consulte o [Changelog][active-model] para obter detalhes das mudanças.

### Remoções

*   Removidos métodos obsoletos em `ActiveModel::Errors`.
    ([commit](https://github.com/rails/rails/commit/9de6457ab0767ebab7f2c8bc583420fda072e2bd))

*   Removida a opção obsoleta `:tokenizer` no validador de comprimento.
    ([commit](https://github.com/rails/rails/commit/6a78e0ecd6122a6b1be9a95e6c4e21e10e429513))

*   Removido o comportamento obsoleto que interrompe os callbacks quando o valor de retorno é falso.
    ([commit](https://github.com/rails/rails/commit/3a25cdca3e0d29ee2040931d0cb6c275d612dffe))

### Mudanças notáveis

*   A string original atribuída a um atributo do modelo não é mais congelada incorretamente.
    ([Pull Request](https://github.com/rails/rails/pull/28729))

Active Job
-----------

Consulte o [Changelog][active-job] para obter detalhes das mudanças.

### Remoções

*   Removido o suporte obsoleto para passar a classe do adaptador para `.queue_adapter`.
    ([commit](https://github.com/rails/rails/commit/d1fc0a5eb286600abf8505516897b96c2f1ef3f6))

*   Removido `#original_exception` obsoleto em `ActiveJob::DeserializationError`.
    ([commit](https://github.com/rails/rails/commit/d861a1fcf8401a173876489d8cee1ede1cecde3b))

### Mudanças notáveis

*   Adicionado tratamento declarativo de exceções via `ActiveJob::Base.retry_on` e `ActiveJob::Base.discard_on`.
    ([Pull Request](https://github.com/rails/rails/pull/25991))

*   Retornar a instância do job para ter acesso a coisas como `job.arguments` na lógica personalizada após as tentativas de reenvio falharem.
    ([commit](https://github.com/rails/rails/commit/a1e4c197cb12fef66530a2edfaeda75566088d1f))

Active Support
--------------

Consulte o [Changelog][active-support] para obter detalhes das mudanças.

### Remoções

*   Removida a classe `ActiveSupport::Concurrency::Latch`.
    ([Commit](https://github.com/rails/rails/commit/0d7bd2031b4054fbdeab0a00dd58b1b08fb7fea6))

*   Removido `halt_callback_chains_on_return_false`.
    ([Commit](https://github.com/rails/rails/commit/4e63ce53fc25c3bc15c5ebf54bab54fa847ee02a))

*   Removido o comportamento obsoleto que interrompe os callbacks quando o retorno é falso.
    ([Commit](https://github.com/rails/rails/commit/3a25cdca3e0d29ee2040931d0cb6c275d612dffe))
### Depreciações

*   A classe `HashWithIndifferentAccess` no nível superior foi suavemente depreciada em favor da classe `ActiveSupport::HashWithIndifferentAccess`.
    ([Pull Request](https://github.com/rails/rails/pull/28157))

*   Depreciado o uso de string para as opções condicionais `:if` e `:unless` nos métodos `set_callback` e `skip_callback`.
    ([Commit](https://github.com/rails/rails/commit/0952552))

### Mudanças notáveis

*   Corrigida a análise de duração e viagem no tempo para torná-las consistentes durante as mudanças de horário de verão.
    ([Commit](https://github.com/rails/rails/commit/8931916f4a1c1d8e70c06063ba63928c5c7eab1e),
    [Pull Request](https://github.com/rails/rails/pull/26597))

*   Atualizado o Unicode para a versão 9.0.0.
    ([Pull Request](https://github.com/rails/rails/pull/27822))

*   Adicionados os métodos `Duration#before` e `#after` como aliases para `#ago` e `#since`.
    ([Pull Request](https://github.com/rails/rails/pull/27721))

*   Adicionado `Module#delegate_missing_to` para delegar chamadas de método não definidas para o objeto proxy atual.
    ([Pull Request](https://github.com/rails/rails/pull/23930))

*   Adicionado `Date#all_day`, que retorna um intervalo representando o dia inteiro da data e hora atual.
    ([Pull Request](https://github.com/rails/rails/pull/24930))

*   Introduzidos os métodos `assert_changes` e `assert_no_changes` para testes.
    ([Pull Request](https://github.com/rails/rails/pull/25393))

*   Os métodos `travel` e `travel_to` agora geram um erro em chamadas aninhadas.
    ([Pull Request](https://github.com/rails/rails/pull/24890))

*   Atualizado `DateTime#change` para suportar usec e nsec.
    ([Pull Request](https://github.com/rails/rails/pull/28242))

Créditos
-------

Veja a
[lista completa de contribuidores para o Rails](https://contributors.rubyonrails.org/) para
as muitas pessoas que dedicaram muitas horas para tornar o Rails o framework estável e robusto que é. Parabéns a todos eles.

[railties]:       https://github.com/rails/rails/blob/5-1-stable/railties/CHANGELOG.md
[action-pack]:    https://github.com/rails/rails/blob/5-1-stable/actionpack/CHANGELOG.md
[action-view]:    https://github.com/rails/rails/blob/5-1-stable/actionview/CHANGELOG.md
[action-mailer]:  https://github.com/rails/rails/blob/5-1-stable/actionmailer/CHANGELOG.md
[action-cable]:   https://github.com/rails/rails/blob/5-1-stable/actioncable/CHANGELOG.md
[active-record]:  https://github.com/rails/rails/blob/5-1-stable/activerecord/CHANGELOG.md
[active-model]:   https://github.com/rails/rails/blob/5-1-stable/activemodel/CHANGELOG.md
[active-job]:     https://github.com/rails/rails/blob/5-1-stable/activejob/CHANGELOG.md
[active-support]: https://github.com/rails/rails/blob/5-1-stable/activesupport/CHANGELOG.md
