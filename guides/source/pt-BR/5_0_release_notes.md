**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: df23e2b31bd56973a30f38f5a1c29b52
Ruby on Rails 5.0 Notas de Lançamento
======================================

Destaques no Rails 5.0:

* Action Cable
* Rails API
* Active Record Attributes API
* Test Runner
* Uso exclusivo do `rails` CLI em vez do Rake
* Sprockets 3
* Turbolinks 5
* Requer Ruby 2.2.2+

Estas notas de lançamento cobrem apenas as principais mudanças. Para saber sobre várias correções de bugs e mudanças, consulte os changelogs ou confira a [lista de commits](https://github.com/rails/rails/commits/5-0-stable) no repositório principal do Rails no GitHub.

--------------------------------------------------------------------------------

Atualizando para o Rails 5.0
----------------------------

Se você está atualizando um aplicativo existente, é uma ótima ideia ter uma boa cobertura de testes antes de começar. Você também deve primeiro atualizar para o Rails 4.2, caso ainda não tenha feito isso, e garantir que seu aplicativo ainda funcione como esperado antes de tentar uma atualização para o Rails 5.0. Uma lista de coisas para ficar atento ao atualizar está disponível no guia [Atualizando o Ruby on Rails](upgrading_ruby_on_rails.html#upgrading-from-rails-4-2-to-rails-5-0).

Principais Recursos
-------------------

### Action Cable

Action Cable é um novo framework no Rails 5. Ele integra perfeitamente [WebSockets](https://en.wikipedia.org/wiki/WebSocket) com o restante do seu aplicativo Rails.

Action Cable permite que recursos em tempo real sejam escritos em Ruby no mesmo estilo e formato do restante do seu aplicativo Rails, ao mesmo tempo em que é performático e escalável. É uma oferta de pilha completa que fornece tanto um framework JavaScript do lado do cliente quanto um framework Ruby do lado do servidor. Você tem acesso ao seu modelo de domínio completo escrito com Active Record ou sua ORM de escolha.

Consulte o guia [Visão Geral do Action Cable](action_cable_overview.html) para obter mais informações.

### Aplicações API

Agora o Rails pode ser usado para criar aplicativos API apenas. Isso é útil para criar e servir APIs simplificadas semelhantes à API do [Twitter](https://dev.twitter.com) ou [GitHub](https://developer.github.com), que podem ser usadas para servir aplicativos públicos, bem como aplicativos personalizados.

Você pode gerar um novo aplicativo Rails API usando:

```bash
$ rails new my_api --api
```
Isso fará três coisas principais:

- Configurar sua aplicação para iniciar com um conjunto mais limitado de middlewares do que o normal. Especificamente, não incluirá por padrão nenhum middleware principalmente útil para aplicativos de navegador (como suporte a cookies).
- Fazer com que `ApplicationController` herde de `ActionController::API` em vez de `ActionController::Base`. Assim como os middlewares, isso deixará de fora quaisquer módulos do Action Controller que forneçam funcionalidades principalmente usadas por aplicativos de navegador.
- Configurar os geradores para pular a geração de views, helpers e assets ao gerar um novo recurso.

A aplicação fornece uma base para APIs, que podem então ser [configuradas para incluir funcionalidades](api_app.html) adequadas às necessidades da aplicação.

Consulte o guia [Using Rails for API-only Applications](api_app.html) para obter mais informações.

### API de atributos do Active Record

Define um atributo com um tipo em um modelo. Ele substituirá o tipo de atributos existentes, se necessário.
Isso permite controlar como os valores são convertidos para e de SQL quando atribuídos a um modelo.
Também altera o comportamento dos valores passados para `ActiveRecord::Base.where`, o que permite usar nossos objetos de domínio em grande parte do Active Record, sem precisar depender de detalhes de implementação ou monkey patching.

Algumas coisas que você pode alcançar com isso:

- O tipo detectado pelo Active Record pode ser substituído.
- Um valor padrão também pode ser fornecido.
- Os atributos não precisam ser suportados por uma coluna de banco de dados.

```ruby
# db/schema.rb
create_table :store_listings, force: true do |t|
  t.decimal :price_in_cents
  t.string :my_string, default: "original default"
end
```

```ruby
# app/models/store_listing.rb
class StoreListing < ActiveRecord::Base
end
```

```ruby
store_listing = StoreListing.new(price_in_cents: '10.1')

# antes
store_listing.price_in_cents # => BigDecimal.new(10.1)
StoreListing.new.my_string # => "original default"

class StoreListing < ActiveRecord::Base
  attribute :price_in_cents, :integer # tipo personalizado
  attribute :my_string, :string, default: "new default" # valor padrão
  attribute :my_default_proc, :datetime, default: -> { Time.now } # valor padrão
  attribute :field_without_db_column, :integer, array: true
end

# depois
store_listing.price_in_cents # => 10
StoreListing.new.my_string # => "new default"
StoreListing.new.my_default_proc # => 2015-05-30 11:04:48 -0600
model = StoreListing.new(field_without_db_column: ["1", "2", "3"])
model.attributes # => {field_without_db_column: [1, 2, 3]}
```
**Criando Tipos Personalizados:**

Você pode definir seus próprios tipos personalizados, desde que eles respondam aos métodos definidos no tipo de valor. O método `deserialize` ou `cast` será chamado no objeto do seu tipo, com a entrada bruta do banco de dados ou dos seus controladores. Isso é útil, por exemplo, ao fazer conversões personalizadas, como dados de dinheiro.

**Consultando:**

Quando `ActiveRecord::Base.where` é chamado, ele usará o tipo definido pela classe do modelo para converter o valor em SQL, chamando `serialize` no objeto do seu tipo.

Isso dá aos objetos a capacidade de especificar como converter valores ao executar consultas SQL.

**Rastreamento de Mudanças:**

O tipo de um atributo pode alterar como o rastreamento de mudanças é realizado.

Consulte a [documentação](https://api.rubyonrails.org/v5.0.1/classes/ActiveRecord/Attributes/ClassMethods.html) para obter uma descrição detalhada.

### Test Runner

Um novo test runner foi introduzido para aprimorar as capacidades de execução de testes no Rails.
Para usar este test runner, basta digitar `bin/rails test`.

O Test Runner é inspirado no `RSpec`, `minitest-reporters`, `maxitest` e outros.
Ele inclui alguns desses avanços notáveis:

- Executar um único teste usando o número da linha do teste.
- Executar vários testes apontando para o número da linha dos testes.
- Melhoria nas mensagens de falha, que também facilitam a reexecução dos testes falhados.
- Falhar rapidamente usando a opção `-f`, para interromper os testes imediatamente ao ocorrer uma falha, em vez de esperar a conclusão da suíte.
- Adiar a saída dos testes até o final de uma execução completa de testes usando a opção `-d`.
- Saída completa do backtrace da exceção usando a opção `-b`.
- Integração com o minitest para permitir opções como `-s` para dados de seed de teste, `-n` para executar um teste específico pelo nome, `-v` para uma saída verbose melhorada, entre outras.
- Saída colorida dos testes.

Railties
--------

Consulte o [Changelog][railties] para obter detalhes das alterações.

### Remoções

*   Removido suporte ao debugger, use o byebug em vez disso. `debugger` não é suportado pelo Ruby 2.2. ([commit](https://github.com/rails/rails/commit/93559da4826546d07014f8cfa399b64b4a143127))
*   Removidas as tarefas `test:all` e `test:all:db` obsoletas.
    ([commit](https://github.com/rails/rails/commit/f663132eef0e5d96bf2a58cec9f7c856db20be7c))

*   Removido o `Rails::Rack::LogTailer` obsoleto.
    ([commit](https://github.com/rails/rails/commit/c564dcb75c191ab3d21cc6f920998b0d6fbca623))

*   Removida a constante `RAILS_CACHE` obsoleta.
    ([commit](https://github.com/rails/rails/commit/b7f856ce488ef8f6bf4c12bb549f462cb7671c08))

*   Removida a configuração `serve_static_assets` obsoleta.
    ([commit](https://github.com/rails/rails/commit/463b5d7581ee16bfaddf34ca349b7d1b5878097c))

*   Removidas as tarefas de documentação `doc:app`, `doc:rails` e `doc:guides`.
    ([commit](https://github.com/rails/rails/commit/cd7cc5254b090ccbb84dcee4408a5acede25ef2a))

*   Removido o middleware `Rack::ContentLength` da pilha padrão.
    ([Commit](https://github.com/rails/rails/commit/56903585a099ab67a7acfaaef0a02db8fe80c450))

### Depreciações

*   `config.static_cache_control` foi depreciado em favor de
    `config.public_file_server.headers`.
    ([Pull Request](https://github.com/rails/rails/pull/19135))

*   `config.serve_static_files` foi depreciado em favor de `config.public_file_server.enabled`.
    ([Pull Request](https://github.com/rails/rails/pull/22173))

*   As tarefas no namespace `rails` foram depreciadas em favor do namespace `app`.
    (por exemplo, as tarefas `rails:update` e `rails:template` foram renomeadas para `app:update` e `app:template`.)
    ([Pull Request](https://github.com/rails/rails/pull/23439))

### Mudanças notáveis

*   Adicionado o test runner do Rails `bin/rails test`.
    ([Pull Request](https://github.com/rails/rails/pull/19216))

*   Aplicações e plugins recém-gerados recebem um `README.md` em Markdown.
    ([commit](https://github.com/rails/rails/commit/89a12c931b1f00b90e74afffcdc2fc21f14ca663),
     [Pull Request](https://github.com/rails/rails/pull/22068))

*   Adicionada a tarefa `bin/rails restart` para reiniciar sua aplicação Rails tocando em `tmp/restart.txt`.
    ([Pull Request](https://github.com/rails/rails/pull/18965))

*   Adicionada a tarefa `bin/rails initializers` para imprimir todos os inicializadores definidos
    na ordem em que são invocados pelo Rails.
    ([Pull Request](https://github.com/rails/rails/pull/19323))

*   Adicionada a tarefa `bin/rails dev:cache` para habilitar ou desabilitar o cache no modo de desenvolvimento.
    ([Pull Request](https://github.com/rails/rails/pull/20961))

*   Adicionado o script `bin/update` para atualizar automaticamente o ambiente de desenvolvimento.
    ([Pull Request](https://github.com/rails/rails/pull/20972))

*   Tarefas Rake são proxy através de `bin/rails`.
    ([Pull Request](https://github.com/rails/rails/pull/22457),
     [Pull Request](https://github.com/rails/rails/pull/22288))

*   Novas aplicações são geradas com o monitor de sistema de arquivos baseado em eventos habilitado
    no Linux e macOS. Essa funcionalidade pode ser desativada passando
    `--skip-listen` para o gerador.
    ([commit](https://github.com/rails/rails/commit/de6ad5665d2679944a9ee9407826ba88395a1003),
    [commit](https://github.com/rails/rails/commit/94dbc48887bf39c241ee2ce1741ee680d773f202))

*   Gere aplicações com a opção de registrar logs no STDOUT em produção
    usando a variável de ambiente `RAILS_LOG_TO_STDOUT`.
    ([Pull Request](https://github.com/rails/rails/pull/23734))

*   HSTS é habilitado com o cabeçalho IncludeSubdomains para novas aplicações.
    ([Pull Request](https://github.com/rails/rails/pull/23852))

*   O gerador de aplicação escreve um novo arquivo `config/spring.rb`, que informa
    ao Spring para monitorar arquivos comuns adicionais.
    ([commit](https://github.com/rails/rails/commit/b04d07337fd7bc17e88500e9d6bcd361885a45f8))

*   Adicionado `--skip-action-mailer` para pular o Action Mailer ao gerar uma nova aplicação.
    ([Pull Request](https://github.com/rails/rails/pull/18288))

*   Removido o diretório `tmp/sessions` e a tarefa rake de limpeza associada a ele.
    ([Pull Request](https://github.com/rails/rails/pull/18314))

*   Alterado o `_form.html.erb` gerado pelo gerador de scaffold para usar variáveis locais.
    ([Pull Request](https://github.com/rails/rails/pull/13434))
* Desabilitada a carga automática de classes no ambiente de produção.
    ([commit](https://github.com/rails/rails/commit/a71350cae0082193ad8c66d65ab62e8bb0b7853b))

Action Pack
-----------

Consulte o [Changelog][action-pack] para obter detalhes das alterações.

### Remoções

*   Removido `ActionDispatch::Request::Utils.deep_munge`.
    ([commit](https://github.com/rails/rails/commit/52cf1a71b393486435fab4386a8663b146608996))

*   Removido `ActionController::HideActions`.
    ([Pull Request](https://github.com/rails/rails/pull/18371))

*   Removidos os métodos de espaço reservado `respond_to` e `respond_with`, essa funcionalidade
    foi extraída para a gem
    [responders](https://github.com/plataformatec/responders).
    ([commit](https://github.com/rails/rails/commit/afd5e9a7ff0072e482b0b0e8e238d21b070b6280))

*   Removidos os arquivos de asserção obsoletos.
    ([commit](https://github.com/rails/rails/commit/92e27d30d8112962ee068f7b14aa7b10daf0c976))

*   Removido o uso obsoleto de chaves de string nos auxiliares de URL.
    ([commit](https://github.com/rails/rails/commit/34e380764edede47f7ebe0c7671d6f9c9dc7e809))

*   Removida a opção obsoleta `only_path` nos auxiliares `*_path`.
    ([commit](https://github.com/rails/rails/commit/e4e1fd7ade47771067177254cb133564a3422b8a))

*   Removido o suporte obsoleto `NamedRouteCollection#helpers`.
    ([commit](https://github.com/rails/rails/commit/2cc91c37bc2e32b7a04b2d782fb8f4a69a14503f))

*   Removido o suporte obsoleto para definir rotas com a opção `:to` que não contém `#`.
    ([commit](https://github.com/rails/rails/commit/1f3b0a8609c00278b9a10076040ac9c90a9cc4a6))

*   Removido `ActionDispatch::Response#to_ary` obsoleto.
    ([commit](https://github.com/rails/rails/commit/4b19d5b7bcdf4f11bd1e2e9ed2149a958e338c01))

*   Removido `ActionDispatch::Request#deep_munge` obsoleto.
    ([commit](https://github.com/rails/rails/commit/7676659633057dacd97b8da66e0d9119809b343e))

*   Removido `ActionDispatch::Http::Parameters#symbolized_path_parameters` obsoleto.
    ([commit](https://github.com/rails/rails/commit/7fe7973cd8bd119b724d72c5f617cf94c18edf9e))

*   Removida a opção obsoleta `use_route` nos testes de controlador.
    ([commit](https://github.com/rails/rails/commit/e4cfd353a47369dd32198b0e67b8cbb2f9a1c548))

*   Removidos `assigns` e `assert_template`. Ambos os métodos foram extraídos
    para a gem
    [rails-controller-testing](https://github.com/rails/rails-controller-testing).
    ([Pull Request](https://github.com/rails/rails/pull/20138))

### Depreciações

*   Depreciados todos os callbacks `*_filter` em favor dos callbacks `*_action`.
    ([Pull Request](https://github.com/rails/rails/pull/18410))

*   Depreciados os métodos de teste de integração `*_via_redirect`. Use `follow_redirect!`
    manualmente após a chamada da requisição para o mesmo comportamento.
    ([Pull Request](https://github.com/rails/rails/pull/18693))

*   Depreciado `AbstractController#skip_action_callback` em favor de métodos individuais
    `skip_callback`.
    ([Pull Request](https://github.com/rails/rails/pull/19060))

*   Depreciada a opção `:nothing` para o método `render`.
    ([Pull Request](https://github.com/rails/rails/pull/20336))

*   Depreciado o uso do primeiro parâmetro como `Hash` e o código de status padrão para
    o método `head`.
    ([Pull Request](https://github.com/rails/rails/pull/20407))

*   Depreciado o uso de strings ou símbolos para nomes de classes de middleware. Use nomes de classe
    em vez disso.
    ([commit](https://github.com/rails/rails/commit/83b767ce))

*   Depreciado o acesso aos tipos de MIME via constantes (por exemplo, `Mime::HTML`). Use o
    operador de subscrito com um símbolo em vez disso (por exemplo, `Mime[:html]`).
    ([Pull Request](https://github.com/rails/rails/pull/21869))

*   Depreciado `redirect_to :back` em favor de `redirect_back`, que aceita um
    argumento `fallback_location` obrigatório, eliminando assim a possibilidade de um
    `RedirectBackError`.
    ([Pull Request](https://github.com/rails/rails/pull/22506))

*   `ActionDispatch::IntegrationTest` e `ActionController::TestCase` depreciam argumentos posicionais em favor de
    argumentos de palavra-chave. ([Pull Request](https://github.com/rails/rails/pull/18323))

*   Depreciados os parâmetros de caminho `:controller` e `:action`.
    ([Pull Request](https://github.com/rails/rails/pull/23980))

*   Depreciado o método env nas instâncias de controlador.
    ([commit](https://github.com/rails/rails/commit/05934d24aff62d66fc62621aa38dae6456e276be))

*   `ActionDispatch::ParamsParser` está depreciado e foi removido da
    pilha de middlewares. Para configurar os analisadores de parâmetros, use
    `ActionDispatch::Request.parameter_parsers=`.
    ([commit](https://github.com/rails/rails/commit/38d2bf5fd1f3e014f2397898d371c339baa627b1),
    [commit](https://github.com/rails/rails/commit/5ed38014811d4ce6d6f957510b9153938370173b))
### Mudanças notáveis

*   Adicionado `ActionController::Renderer` para renderizar templates arbitrários
    fora das ações do controlador.
    ([Pull Request](https://github.com/rails/rails/pull/18546))

*   Migração para a sintaxe de argumentos de palavra-chave em `ActionController::TestCase` e
    métodos de solicitação HTTP de `ActionDispatch::Integration`.
    ([Pull Request](https://github.com/rails/rails/pull/18323))

*   Adicionado `http_cache_forever` ao Action Controller, para que possamos armazenar em cache uma resposta
    que nunca expira.
    ([Pull Request](https://github.com/rails/rails/pull/18394))

*   Fornecer acesso mais amigável às variantes de solicitação.
    ([Pull Request](https://github.com/rails/rails/pull/18939))

*   Para ações sem templates correspondentes, renderizar `head :no_content`
    em vez de gerar um erro.
    ([Pull Request](https://github.com/rails/rails/pull/19377))

*   Adicionada a capacidade de substituir o construtor de formulários padrão para um controlador.
    ([Pull Request](https://github.com/rails/rails/pull/19736))

*   Adicionado suporte para aplicativos somente de API.
    `ActionController::API` é adicionado como substituto de
    `ActionController::Base` para esse tipo de aplicativo.
    ([Pull Request](https://github.com/rails/rails/pull/19832))

*   Tornar `ActionController::Parameters` não herda mais de
    `HashWithIndifferentAccess`.
    ([Pull Request](https://github.com/rails/rails/pull/20868))

*   Tornar mais fácil optar por `config.force_ssl` e `config.ssl_options` por
    tornando-os menos perigosos de tentar e mais fáceis de desativar.
    ([Pull Request](https://github.com/rails/rails/pull/21520))

*   Adicionada a capacidade de retornar cabeçalhos arbitrários para `ActionDispatch::Static`.
    ([Pull Request](https://github.com/rails/rails/pull/19135))

*   Alterado o padrão de prepend de `protect_from_forgery` para `false`.
    ([commit](https://github.com/rails/rails/commit/39794037817703575c35a75f1961b01b83791191))

*   `ActionController::TestCase` será movido para sua própria gema no Rails 5.1. Use
    `ActionDispatch::IntegrationTest` em seu lugar.
    ([commit](https://github.com/rails/rails/commit/4414c5d1795e815b102571425974a8b1d46d932d))

*   O Rails gera ETags fracos por padrão.
    ([Pull Request](https://github.com/rails/rails/pull/17573))

*   Ações do controlador sem uma chamada `render` explícita e sem
    templates correspondentes renderizarão `head :no_content` implicitamente
    em vez de gerar um erro.
    (Pull Request [1](https://github.com/rails/rails/pull/19377),
    [2](https://github.com/rails/rails/pull/23827))

*   Adicionada uma opção para tokens CSRF por formulário.
    ([Pull Request](https://github.com/rails/rails/pull/22275))

*   Adicionada codificação de solicitação e análise de resposta aos testes de integração.
    ([Pull Request](https://github.com/rails/rails/pull/21671))

*   Adicione `ActionController#helpers` para obter acesso ao contexto de visualização
    no nível do controlador.
    ([Pull Request](https://github.com/rails/rails/pull/24866))

*   As mensagens flash descartadas são removidas antes de serem armazenadas na sessão.
    ([Pull Request](https://github.com/rails/rails/pull/18721))

*   Adicionado suporte para passar uma coleção de registros para `fresh_when` e
    `stale?`.
    ([Pull Request](https://github.com/rails/rails/pull/18374))

*   `ActionController::Live` se tornou um `ActiveSupport::Concern`. Isso
    significa que ele não pode ser apenas incluído em outros módulos sem estendê-los com `ActiveSupport::Concern` ou `ActionController::Live`
    não terá efeito em produção. Algumas pessoas podem estar usando outro
    módulo para incluir algum código especial de tratamento de falha de autenticação `Warden`/`Devise` também, já que o middleware não pode capturar um
    `:warden` lançado por uma thread gerada, que é o caso ao usar
    `ActionController::Live`.
    ([Mais detalhes neste problema](https://github.com/rails/rails/issues/25581))
*   Introduza `Response#strong_etag=` e `#weak_etag=` e opções análogas para `fresh_when` e `stale?`.
    ([Pull Request](https://github.com/rails/rails/pull/24387))

Action View
-------------

Consulte o [Changelog][action-view] para obter detalhes das alterações.

### Remoções

*   Removido `AbstractController::Base::parent_prefixes` obsoleto.
    ([commit](https://github.com/rails/rails/commit/34bcbcf35701ca44be559ff391535c0dd865c333))

*   Removido `ActionView::Helpers::RecordTagHelper`, essa funcionalidade
    foi extraída para a gem
    [record_tag_helper](https://github.com/rails/record_tag_helper).
    ([Pull Request](https://github.com/rails/rails/pull/18411))

*   Removida a opção `:rescue_format` para o helper `translate` pois não é mais
    suportada pelo I18n.
    ([Pull Request](https://github.com/rails/rails/pull/20019))

### Mudanças Notáveis

*   Alterado o manipulador de templates padrão de `ERB` para `Raw`.
    ([commit](https://github.com/rails/rails/commit/4be859f0fdf7b3059a28d03c279f03f5938efc80))

*   A renderização de coleções pode armazenar em cache e buscar vários parciais de uma vez.
    ([Pull Request](https://github.com/rails/rails/pull/18948),
    [commit](https://github.com/rails/rails/commit/e93f0f0f133717f9b06b1eaefd3442bd0ff43985))

*   Adicionada correspondência de curinga para dependências explícitas.
    ([Pull Request](https://github.com/rails/rails/pull/20904))

*   Tornar `disable_with` o comportamento padrão para tags de envio. Desabilita o
    botão no envio para evitar envios duplicados.
    ([Pull Request](https://github.com/rails/rails/pull/21135))

*   O nome do template parcial não precisa mais ser um identificador Ruby válido.
    ([commit](https://github.com/rails/rails/commit/da9038e))

*   O helper `datetime_tag` agora gera uma tag de input com o tipo
    `datetime-local`.
    ([Pull Request](https://github.com/rails/rails/pull/25469))

*   Permite blocos ao renderizar com o helper `render partial:`.
    ([Pull Request](https://github.com/rails/rails/pull/17974))

Action Mailer
-------------

Consulte o [Changelog][action-mailer] para obter detalhes das alterações.

### Remoções

*   Removidos os helpers `*_path` obsoletos nas visualizações de e-mail.
    ([commit](https://github.com/rails/rails/commit/d282125a18c1697a9b5bb775628a2db239142ac7))

*   Removidos os métodos obsoletos `deliver` e `deliver!`.
    ([commit](https://github.com/rails/rails/commit/755dcd0691f74079c24196135f89b917062b0715))

### Mudanças Notáveis

*   A busca de templates agora respeita o locale padrão e as fallbacks do I18n.
    ([commit](https://github.com/rails/rails/commit/ecb1981b))

*   Adicionado sufixo `_mailer` aos mailers criados via gerador, seguindo a mesma
    convenção de nomenclatura usada em controladores e jobs.
    ([Pull Request](https://github.com/rails/rails/pull/18074))

*   Adicionados `assert_enqueued_emails` e `assert_no_enqueued_emails`.
    ([Pull Request](https://github.com/rails/rails/pull/18403))

*   Adicionada a configuração `config.action_mailer.deliver_later_queue_name` para definir
    o nome da fila do mailer.
    ([Pull Request](https://github.com/rails/rails/pull/18587))

*   Adicionado suporte para cache de fragmentos nas visualizações do Action Mailer.
    Adicionada nova opção de configuração `config.action_mailer.perform_caching` para determinar
    se seus templates devem realizar cache ou não.
    ([Pull Request](https://github.com/rails/rails/pull/22825))


Active Record
-------------

Consulte o [Changelog][active-record] para obter detalhes das alterações.

### Remoções

*   Removido o comportamento obsoleto que permitia passar matrizes aninhadas como valores de consulta.
    ([Pull Request](https://github.com/rails/rails/pull/17919))

*   Removido `ActiveRecord::Tasks::DatabaseTasks#load_schema` obsoleto. Este
    método foi substituído por `ActiveRecord::Tasks::DatabaseTasks#load_schema_for`.
    ([commit](https://github.com/rails/rails/commit/ad783136d747f73329350b9bb5a5e17c8f8800da))
*   Removido `serialized_attributes` obsoleto.
    ([commit](https://github.com/rails/rails/commit/82043ab53cb186d59b1b3be06122861758f814b2))

*   Removido contador automático obsoleto em `has_many :through`.
    ([commit](https://github.com/rails/rails/commit/87c8ce340c6c83342df988df247e9035393ed7a0))

*   Removido `sanitize_sql_hash_for_conditions` obsoleto.
    ([commit](https://github.com/rails/rails/commit/3a59dd212315ebb9bae8338b98af259ac00bbef3))

*   Removido `Reflection#source_macro` obsoleto.
    ([commit](https://github.com/rails/rails/commit/ede8c199a85cfbb6457d5630ec1e285e5ec49313))

*   Removido `symbolized_base_class` e `symbolized_sti_name` obsoletos.
    ([commit](https://github.com/rails/rails/commit/9013e28e52eba3a6ffcede26f85df48d264b8951))

*   Removido `ActiveRecord::Base.disable_implicit_join_references=`.
    ([commit](https://github.com/rails/rails/commit/0fbd1fc888ffb8cbe1191193bf86933110693dfc))

*   Removido acesso obsoleto à especificação de conexão usando um acessor de string.
    ([commit](https://github.com/rails/rails/commit/efdc20f36ccc37afbb2705eb9acca76dd8aabd4f))

*   Removido suporte obsoleto para pré-carregar associações dependentes da instância.
    ([commit](https://github.com/rails/rails/commit/4ed97979d14c5e92eb212b1a629da0a214084078))

*   Removido suporte obsoleto para intervalos PostgreSQL com limites inferiores exclusivos.
    ([commit](https://github.com/rails/rails/commit/a076256d63f64d194b8f634890527a5ed2651115))

*   Removida a depreciação ao modificar uma relação com Arel em cache.
    Agora, isso gera um erro `ImmutableRelation`.
    ([commit](https://github.com/rails/rails/commit/3ae98181433dda1b5e19910e107494762512a86c))

*   Removido `ActiveRecord::Serialization::XmlSerializer` do núcleo. Essa funcionalidade
    foi extraída para o
    [activemodel-serializers-xml](https://github.com/rails/activemodel-serializers-xml)
    gem. ([Pull Request](https://github.com/rails/rails/pull/21161))

*   Removido suporte para o adaptador de banco de dados legado `mysql` do núcleo. A maioria dos usuários deve
    ser capaz de usar `mysql2`. Ele será convertido em um gem separado quando encontrarmos alguém
    para mantê-lo. ([Pull Request 1](https://github.com/rails/rails/pull/22642),
    [Pull Request 2](https://github.com/rails/rails/pull/22715))

*   Removido suporte para o gem `protected_attributes`.
    ([commit](https://github.com/rails/rails/commit/f4fbc0301021f13ae05c8e941c8efc4ae351fdf9))

*   Removido suporte para versões do PostgreSQL abaixo de 9.1.
    ([Pull Request](https://github.com/rails/rails/pull/23434))

*   Removido suporte para o gem `activerecord-deprecated_finders`.
    ([commit](https://github.com/rails/rails/commit/78dab2a8569408658542e462a957ea5a35aa4679))

*   Removida a constante `ActiveRecord::ConnectionAdapters::Column::TRUE_VALUES`.
    ([commit](https://github.com/rails/rails/commit/a502703c3d2151d4d3b421b29fefdac5ad05df61))

### Depreciações

*   Depreciado passar uma classe como valor em uma consulta. Os usuários devem passar strings
    em vez disso. ([Pull Request](https://github.com/rails/rails/pull/17916))

*   Depreciado retornar `false` como forma de interromper as cadeias de callback do Active Record.
    A forma recomendada é usar `throw(:abort)`. ([Pull Request](https://github.com/rails/rails/pull/17227))

*   Depreciado `ActiveRecord::Base.errors_in_transactional_callbacks=`.
    ([commit](https://github.com/rails/rails/commit/07d3d402341e81ada0214f2cb2be1da69eadfe72))

*   Depreciado o uso de `Relation#uniq`, use `Relation#distinct` em vez disso.
    ([commit](https://github.com/rails/rails/commit/adfab2dcf4003ca564d78d4425566dd2d9cd8b4f))

*   Depreciado o tipo PostgreSQL `:point` em favor de um novo que retornará
    objetos `Point` em vez de um `Array`
    ([Pull Request](https://github.com/rails/rails/pull/20448))

*   Depreciado recarregar a associação forçadamente passando um argumento verdadeiro para
    o método de associação.
    ([Pull Request](https://github.com/rails/rails/pull/20888))

*   Depreciadas as chaves para erros de `restrict_dependent_destroy` da associação em favor
    de novos nomes de chave.
    ([Pull Request](https://github.com/rails/rails/pull/20668))

*   Sincronizado o comportamento de `#tables`.
    ([Pull Request](https://github.com/rails/rails/pull/21601))

*   Depreciado `SchemaCache#tables`, `SchemaCache#table_exists?` e
    `SchemaCache#clear_table_cache!` em favor de seus novos equivalentes de fonte de dados.
    ([Pull Request](https://github.com/rails/rails/pull/21715))
*   `connection.tables` foi depreciado nos adaptadores SQLite3 e MySQL.
    ([Pull Request](https://github.com/rails/rails/pull/21601))

*   Foi depreciado o envio de argumentos para `#tables` - o método `#tables` de alguns
    adaptadores (mysql2, sqlite3) retornaria tanto tabelas quanto visualizações, enquanto outros
    (postgresql) retornam apenas tabelas. Para tornar seu comportamento consistente,
    `#tables` retornará apenas tabelas no futuro.
    ([Pull Request](https://github.com/rails/rails/pull/21601))

*   Foi depreciado `table_exists?` - O método `#table_exists?` verificaria tanto
    tabelas quanto visualizações. Para tornar seu comportamento consistente com `#tables`,
    `#table_exists?` verificará apenas tabelas no futuro.
    ([Pull Request](https://github.com/rails/rails/pull/21601))

*   Depreciar o envio do argumento `offset` para `find_nth`. Por favor, use o
    método `offset` na relação em vez disso.
    ([Pull Request](https://github.com/rails/rails/pull/22053))

*   Foi depreciado `{insert|update|delete}_sql` em `DatabaseStatements`.
    Use os métodos públicos `{insert|update|delete}` em vez disso.
    ([Pull Request](https://github.com/rails/rails/pull/23086))

*   Foi depreciado `use_transactional_fixtures` em favor de
    `use_transactional_tests` para maior clareza.
    ([Pull Request](https://github.com/rails/rails/pull/19282))

*   Foi depreciado o envio de uma coluna para `ActiveRecord::Connection#quote`.
    ([commit](https://github.com/rails/rails/commit/7bb620869725ad6de603f6a5393ee17df13aa96c))

*   Adicionada uma opção `end` para `find_in_batches` que complementa o parâmetro `start`
    para especificar onde parar o processamento em lote.
    ([Pull Request](https://github.com/rails/rails/pull/12257))


### Mudanças notáveis

*   Adicionada a opção `foreign_key` para `references` ao criar a tabela.
    ([commit](https://github.com/rails/rails/commit/99a6f9e60ea55924b44f894a16f8de0162cf2702))

*   Nova API de atributos.
    ([commit](https://github.com/rails/rails/commit/8c752c7ac739d5a86d4136ab1e9d0142c4041e58))

*   Adicionada a opção `:_prefix`/`:_suffix` para a definição de `enum`.
    ([Pull Request](https://github.com/rails/rails/pull/19813),
     [Pull Request](https://github.com/rails/rails/pull/20999))

*   Adicionado `#cache_key` para `ActiveRecord::Relation`.
    ([Pull Request](https://github.com/rails/rails/pull/20884))

*   Alterado o valor padrão de `null` para `false` em `timestamps`.
    ([commit](https://github.com/rails/rails/commit/a939506f297b667291480f26fa32a373a18ae06a))

*   Adicionado `ActiveRecord::SecureToken` para encapsular a geração de
    tokens únicos para atributos em um modelo usando `SecureRandom`.
    ([Pull Request](https://github.com/rails/rails/pull/18217))

*   Adicionada a opção `:if_exists` para `drop_table`.
    ([Pull Request](https://github.com/rails/rails/pull/18597))

*   Adicionado `ActiveRecord::Base#accessed_fields`, que pode ser usado para rapidamente
    descobrir quais campos foram lidos de um modelo quando você está procurando apenas
    selecionar os dados necessários do banco de dados.
    ([commit](https://github.com/rails/rails/commit/be9b68038e83a617eb38c26147659162e4ac3d2c))

*   Adicionado o método `#or` em `ActiveRecord::Relation`, permitindo o uso do operador OR
    para combinar cláusulas WHERE ou HAVING.
    ([commit](https://github.com/rails/rails/commit/b0b37942d729b6bdcd2e3178eda7fa1de203b3d0))

*   Adicionado `ActiveRecord::Base.suppress` para evitar que o receptor seja salvo
    durante o bloco fornecido.
    ([Pull Request](https://github.com/rails/rails/pull/18910))

*   `belongs_to` agora irá disparar um erro de validação por padrão se a
    associação não estiver presente. Você pode desativar isso em uma base de associação
    com `optional: true`. Também foi depreciada a opção `required` em favor de `optional`
    para `belongs_to`.
    ([Pull Request](https://github.com/rails/rails/pull/18937))
*   Adicionado `config.active_record.dump_schemas` para configurar o comportamento do `db:structure:dump`.
    ([Pull Request](https://github.com/rails/rails/pull/19347))

*   Adicionada a opção `config.active_record.warn_on_records_fetched_greater_than`.
    ([Pull Request](https://github.com/rails/rails/pull/18846))

*   Adicionado suporte nativo ao tipo de dados JSON no MySQL.
    ([Pull Request](https://github.com/rails/rails/pull/21110))

*   Adicionado suporte para exclusão de índices simultaneamente no PostgreSQL.
    ([Pull Request](https://github.com/rails/rails/pull/21317))

*   Adicionados os métodos `#views` e `#view_exists?` nos adaptadores de conexão.
    ([Pull Request](https://github.com/rails/rails/pull/21609))

*   Adicionado `ActiveRecord::Base.ignored_columns` para tornar algumas colunas invisíveis para o Active Record.
    ([Pull Request](https://github.com/rails/rails/pull/21720))

*   Adicionados `connection.data_sources` e `connection.data_source_exists?`.
    Esses métodos determinam quais relações podem ser usadas para dar suporte aos modelos do Active Record (geralmente tabelas e visualizações).
    ([Pull Request](https://github.com/rails/rails/pull/21715))

*   Permite que os arquivos de fixtures definam a classe do modelo no próprio arquivo YAML.
    ([Pull Request](https://github.com/rails/rails/pull/20574))

*   Adicionada a capacidade de definir `uuid` como chave primária padrão ao gerar migrações de banco de dados.
    ([Pull Request](https://github.com/rails/rails/pull/21762))

*   Adicionados `ActiveRecord::Relation#left_joins` e `ActiveRecord::Relation#left_outer_joins`.
    ([Pull Request](https://github.com/rails/rails/pull/12071))

*   Adicionados callbacks `after_{create,update,delete}_commit`.
    ([Pull Request](https://github.com/rails/rails/pull/22516))

*   Versão da API apresentada para classes de migração, para que possamos alterar os valores padrão dos parâmetros sem quebrar as migrações existentes ou forçá-las a serem reescritas através de um ciclo de depreciação.
    ([Pull Request](https://github.com/rails/rails/pull/21538))

*   `ApplicationRecord` é uma nova superclasse para todos os modelos do aplicativo, análoga aos controladores do aplicativo que herdam de `ApplicationController` em vez de `ActionController::Base`. Isso permite que os aplicativos configurem o comportamento do modelo em todo o aplicativo em um único local.
    ([Pull Request](https://github.com/rails/rails/pull/22567))

*   Adicionados os métodos `ActiveRecord#second_to_last` e `ActiveRecord#third_to_last`.
    ([Pull Request](https://github.com/rails/rails/pull/23583))

*   Adicionada a capacidade de adicionar comentários a objetos de banco de dados (tabelas, colunas, índices) armazenados nos metadados do banco de dados para PostgreSQL e MySQL.
    ([Pull Request](https://github.com/rails/rails/pull/22911))

*   Adicionado suporte a prepared statements para o adaptador `mysql2`, para mysql2 0.4.4+.
    Anteriormente, isso era suportado apenas no adaptador legado `mysql` descontinuado.
    Para habilitar, defina `prepared_statements: true` em `config/database.yml`.
    ([Pull Request](https://github.com/rails/rails/pull/23461))

*   Adicionada a capacidade de chamar `ActionRecord::Relation#update` em objetos de relação, o que executará validações e callbacks em todos os objetos da relação.
    ([Pull Request](https://github.com/rails/rails/pull/11898))

*   Adicionada a opção `:touch` ao método `save`, para que os registros possam ser salvos sem atualizar os timestamps.
    ([Pull Request](https://github.com/rails/rails/pull/18225))

*   Adicionado suporte a índices de expressão e classes de operadores para o PostgreSQL.
    ([commit](https://github.com/rails/rails/commit/edc2b7718725016e988089b5fb6d6fb9d6e16882))
*   Adicionada a opção `:index_errors` para adicionar índices aos erros de atributos aninhados.
    ([Pull Request](https://github.com/rails/rails/pull/19686))

*   Adicionado suporte para dependências destrutivas bidirecionais.
    ([Pull Request](https://github.com/rails/rails/pull/18548))

*   Adicionado suporte para callbacks `after_commit` em testes transacionais.
    ([Pull Request](https://github.com/rails/rails/pull/18458))

*   Adicionado método `foreign_key_exists?` para verificar se uma chave estrangeira existe ou não em uma tabela.
    ([Pull Request](https://github.com/rails/rails/pull/18662))

*   Adicionada opção `:time` para o método `touch` para atualizar registros com um tempo diferente do tempo atual.
    ([Pull Request](https://github.com/rails/rails/pull/18956))

*   Alterados os callbacks de transação para não ignorar erros.
    Antes dessa alteração, quaisquer erros gerados dentro de um callback de transação eram resgatados e impressos nos logs, a menos que você usasse a opção (recém-depreciada) `raise_in_transactional_callbacks = true`.

    Agora esses erros não são mais resgatados e apenas são propagados, seguindo o comportamento de outros callbacks.
    ([commit](https://github.com/rails/rails/commit/07d3d402341e81ada0214f2cb2be1da69eadfe72))

Active Model
------------

Consulte o [Changelog][active-model] para obter detalhes das alterações.

### Remoções

*   Removidos os métodos depreciados `ActiveModel::Dirty#reset_#{attribute}` e
    `ActiveModel::Dirty#reset_changes`.
    ([Pull Request](https://github.com/rails/rails/commit/37175a24bd508e2983247ec5d011d57df836c743))

*   Removida a serialização XML. Essa funcionalidade foi extraída para a
    [gem activemodel-serializers-xml](https://github.com/rails/activemodel-serializers-xml).
    ([Pull Request](https://github.com/rails/rails/pull/21161))

*   Removido o módulo `ActionController::ModelNaming`.
    ([Pull Request](https://github.com/rails/rails/pull/18194))

### Depreciações

*   Depreciado o retorno `false` como forma de interromper as cadeias de callbacks do Active Model e
    `ActiveModel::Validations`. A forma recomendada é usar `throw(:abort)`.
    ([Pull Request](https://github.com/rails/rails/pull/17227))

*   Depreciados os métodos `ActiveModel::Errors#get`, `ActiveModel::Errors#set` e
    `ActiveModel::Errors#[]=` que possuem comportamento inconsistente.
    ([Pull Request](https://github.com/rails/rails/pull/18634))

*   Depreciada a opção `:tokenizer` para `validates_length_of`, em favor de
    Ruby puro.
    ([Pull Request](https://github.com/rails/rails/pull/19585))

*   Depreciados os métodos `ActiveModel::Errors#add_on_empty` e `ActiveModel::Errors#add_on_blank`
    sem substituição.
    ([Pull Request](https://github.com/rails/rails/pull/18996))

### Mudanças notáveis

*   Adicionado o método `ActiveModel::Errors#details` para determinar qual validador falhou.
    ([Pull Request](https://github.com/rails/rails/pull/18322))

*   Extraído `ActiveRecord::AttributeAssignment` para `ActiveModel::AttributeAssignment`,
    permitindo seu uso em qualquer objeto como um módulo incluível.
    ([Pull Request](https://github.com/rails/rails/pull/10776))

*   Adicionados os métodos `ActiveModel::Dirty#[attr_name]_previously_changed?` e
    `ActiveModel::Dirty#[attr_name]_previous_change` para melhorar o acesso
    às alterações registradas após o salvamento do modelo.
    ([Pull Request](https://github.com/rails/rails/pull/19847))

*   Validação de múltiplos contextos no `valid?` e `invalid?` de uma vez.
    ([Pull Request](https://github.com/rails/rails/pull/21069))

*   Alteração do `validates_acceptance_of` para aceitar `true` como valor padrão,
    além de `1`.
    ([Pull Request](https://github.com/rails/rails/pull/18439))
Active Job
-----------

Consulte o [Changelog][active-job] para obter detalhes das alterações.

### Alterações importantes

*   `ActiveJob::Base.deserialize` delega para a classe do trabalho. Isso permite que os trabalhos anexem metadados arbitrários quando são serializados e leiam de volta quando são executados.
    ([Pull Request](https://github.com/rails/rails/pull/18260))

*   Adicionada a capacidade de configurar o adaptador de fila em uma base de trabalho sem afetar uns aos outros.
    ([Pull Request](https://github.com/rails/rails/pull/16992))

*   Um trabalho gerado agora herda de `app/jobs/application_job.rb` por padrão.
    ([Pull Request](https://github.com/rails/rails/pull/19034))

*   Permitir que `DelayedJob`, `Sidekiq`, `qu`, `que` e `queue_classic` relatem o ID do trabalho de volta para `ActiveJob::Base` como `provider_job_id`.
    ([Pull Request](https://github.com/rails/rails/pull/20064),
     [Pull Request](https://github.com/rails/rails/pull/20056),
     [commit](https://github.com/rails/rails/commit/68e3279163d06e6b04e043f91c9470e9259bbbe0))

*   Implementar um processador de `AsyncJob` simples e um `AsyncAdapter` associado que enfileiram trabalhos em uma piscina de threads `concurrent-ruby`.
    ([Pull Request](https://github.com/rails/rails/pull/21257))

*   Alterar o adaptador padrão de inline para async. É uma melhor opção padrão, pois os testes não dependerão erroneamente de um comportamento ocorrendo de forma síncrona.
    ([commit](https://github.com/rails/rails/commit/625baa69d14881ac49ba2e5c7d9cac4b222d7022))

Active Support
--------------

Consulte o [Changelog][active-support] para obter detalhes das alterações.

### Remoções

*   Removido `ActiveSupport::JSON::Encoding::CircularReferenceError` obsoleto.
    ([commit](https://github.com/rails/rails/commit/d6e06ea8275cdc3f126f926ed9b5349fde374b10))

*   Removidos os métodos obsoletos `ActiveSupport::JSON::Encoding.encode_big_decimal_as_string=`
    e `ActiveSupport::JSON::Encoding.encode_big_decimal_as_string`.
    ([commit](https://github.com/rails/rails/commit/c8019c0611791b2716c6bed48ef8dcb177b7869c))

*   Removido `ActiveSupport::SafeBuffer#prepend` obsoleto.
    ([commit](https://github.com/rails/rails/commit/e1c8b9f688c56aaedac9466a4343df955b4a67ec))

*   Removidos os métodos obsoletos de `Kernel`. `silence_stderr`, `silence_stream`,
    `capture` e `quietly`.
    ([commit](https://github.com/rails/rails/commit/481e49c64f790e46f4aff3ed539ed227d2eb46cb))

*   Removido arquivo obsoleto `active_support/core_ext/big_decimal/yaml_conversions`.
    ([commit](https://github.com/rails/rails/commit/98ea19925d6db642731741c3b91bd085fac92241))

*   Removidos os métodos obsoletos `ActiveSupport::Cache::Store.instrument` e
    `ActiveSupport::Cache::Store.instrument=`.
    ([commit](https://github.com/rails/rails/commit/a3ce6ca30ed0e77496c63781af596b149687b6d7))

*   Removido `Class#superclass_delegating_accessor` obsoleto.
    Use `Class#class_attribute` em seu lugar.
    ([Pull Request](https://github.com/rails/rails/pull/16938))

*   Removido `ThreadSafe::Cache`. Use `Concurrent::Map` em seu lugar.
    ([Pull Request](https://github.com/rails/rails/pull/21679))

*   Removido `Object#itself` pois está implementado no Ruby 2.2.
    ([Pull Request](https://github.com/rails/rails/pull/18244))

### Depreciações

*   Depreciado `MissingSourceFile` em favor de `LoadError`.
    ([commit](https://github.com/rails/rails/commit/734d97d2))

*   Depreciado `alias_method_chain` em favor de `Module#prepend` introduzido em
    Ruby 2.0.
    ([Pull Request](https://github.com/rails/rails/pull/19434))

*   Depreciado `ActiveSupport::Concurrency::Latch` em favor de
    `Concurrent::CountDownLatch` do concurrent-ruby.
    ([Pull Request](https://github.com/rails/rails/pull/20866))

*   Depreciado a opção `:prefix` de `number_to_human_size` sem substituição.
    ([Pull Request](https://github.com/rails/rails/pull/21191))

*   Depreciado `Module#qualified_const_` em favor dos métodos `Module#const_` incorporados.
    ([Pull Request](https://github.com/rails/rails/pull/17845))

*   Depreciado passar uma string para definir um callback.
    ([Pull Request](https://github.com/rails/rails/pull/22598))

*   Depreciados `ActiveSupport::Cache::Store#namespaced_key`,
    `ActiveSupport::Cache::MemCachedStore#escape_key` e
    `ActiveSupport::Cache::FileStore#key_file_path`.
    Use `normalize_key` em seu lugar.
    ([Pull Request](https://github.com/rails/rails/pull/22215),
     [commit](https://github.com/rails/rails/commit/a8f773b0))
*   Depreciado `ActiveSupport::Cache::LocaleCache#set_cache_value` em favor de `write_cache_value`.
    ([Pull Request](https://github.com/rails/rails/pull/22215))

*   Depreciado passar argumentos para `assert_nothing_raised`.
    ([Pull Request](https://github.com/rails/rails/pull/23789))

*   Depreciado `Module.local_constants` em favor de `Module.constants(false)`.
    ([Pull Request](https://github.com/rails/rails/pull/23936))


### Mudanças notáveis

*   Adicionados métodos `#verified` e `#valid_message?` para
    `ActiveSupport::MessageVerifier`.
    ([Pull Request](https://github.com/rails/rails/pull/17727))

*   Alterada a forma como as cadeias de chamadas de retorno podem ser interrompidas. O método preferido
    para interromper uma cadeia de chamadas de retorno a partir de agora é usar explicitamente `throw(:abort)`.
    ([Pull Request](https://github.com/rails/rails/pull/17227))

*   Nova opção de configuração
    `config.active_support.halt_callback_chains_on_return_false` para especificar
    se as cadeias de chamadas de retorno do ActiveRecord, ActiveModel e ActiveModel::Validations podem ser interrompidas
    retornando `false` em um callback 'before'.
    ([Pull Request](https://github.com/rails/rails/pull/17227))

*   Alterada a ordem padrão dos testes de `:sorted` para `:random`.
    ([commit](https://github.com/rails/rails/commit/5f777e4b5ee2e3e8e6fd0e2a208ec2a4d25a960d))

*   Adicionados métodos `#on_weekend?`, `#on_weekday?`, `#next_weekday`, `#prev_weekday` para `Date`,
    `Time` e `DateTime`.
    ([Pull Request](https://github.com/rails/rails/pull/18335),
     [Pull Request](https://github.com/rails/rails/pull/23687))

*   Adicionada opção `same_time` para `#next_week` e `#prev_week` para `Date`, `Time`,
    e `DateTime`.
    ([Pull Request](https://github.com/rails/rails/pull/18335))

*   Adicionados métodos `#prev_day` e `#next_day` como contrapartes de `#yesterday` e
    `#tomorrow` para `Date`, `Time` e `DateTime`.
    ([Pull Request](https://github.com/rails/rails/pull/18335))

*   Adicionado `SecureRandom.base58` para geração de strings aleatórias em base58.
    ([commit](https://github.com/rails/rails/commit/b1093977110f18ae0cafe56c3d99fc22a7d54d1b))

*   Adicionado `file_fixture` para `ActiveSupport::TestCase`.
    Fornece um mecanismo simples para acessar arquivos de exemplo em seus casos de teste.
    ([Pull Request](https://github.com/rails/rails/pull/18658))

*   Adicionado `#without` em `Enumerable` e `Array` para retornar uma cópia de um
    enumerável sem os elementos especificados.
    ([Pull Request](https://github.com/rails/rails/pull/19157))

*   Adicionados `ActiveSupport::ArrayInquirer` e `Array#inquiry`.
    ([Pull Request](https://github.com/rails/rails/pull/18939))

*   Adicionado `ActiveSupport::TimeZone#strptime` para permitir a análise de horários como se
    fossem de um determinado fuso horário.
    ([commit](https://github.com/rails/rails/commit/a5e507fa0b8180c3d97458a9b86c195e9857d8f6))

*   Adicionados métodos de consulta `Integer#positive?` e `Integer#negative?`
    no estilo de `Integer#zero?`.
    ([commit](https://github.com/rails/rails/commit/e54277a45da3c86fecdfa930663d7692fd083daa))

*   Adicionada uma versão com exclamação para os métodos de obtenção de `ActiveSupport::OrderedOptions` que lançará
    um `KeyError` se o valor for `.blank?`.
    ([Pull Request](https://github.com/rails/rails/pull/20208))

*   Adicionado `Time.days_in_year` para retornar o número de dias no ano fornecido, ou o
    ano atual se nenhum argumento for fornecido.
    ([commit](https://github.com/rails/rails/commit/2f4f4d2cf1e4c5a442459fc250daf66186d110fa))

*   Adicionado um observador de arquivos com eventos para detectar assincronamente alterações no
    código-fonte da aplicação, rotas, localidades, etc.
    ([Pull Request](https://github.com/rails/rails/pull/22254))

*   Adicionados métodos `thread_m/cattr_accessor/reader/writer` para declarar
    variáveis de classe e módulo que vivem por thread.
    ([Pull Request](https://github.com/rails/rails/pull/22630))
*   Adicionados os métodos `Array#second_to_last` e `Array#third_to_last`.
    ([Pull Request](https://github.com/rails/rails/pull/23583))

*   Publicadas as APIs `ActiveSupport::Executor` e `ActiveSupport::Reloader` para permitir
    que componentes e bibliotecas gerenciem e participem da execução do
    código da aplicação e do processo de recarregamento da aplicação.
    ([Pull Request](https://github.com/rails/rails/pull/23807))

*   `ActiveSupport::Duration` agora suporta formatação e análise ISO8601.
    ([Pull Request](https://github.com/rails/rails/pull/16917))

*   `ActiveSupport::JSON.decode` agora suporta a análise de horários locais ISO8601 quando
    `parse_json_times` está habilitado.
    ([Pull Request](https://github.com/rails/rails/pull/23011))

*   `ActiveSupport::JSON.decode` agora retorna objetos `Date` para strings de data.
    ([Pull Request](https://github.com/rails/rails/pull/23011))

*   Adicionada a capacidade de `TaggedLogging` permitir que os loggers sejam instanciados várias
    vezes para que eles não compartilhem tags entre si.
    ([Pull Request](https://github.com/rails/rails/pull/9065))

Créditos
-------

Veja a
[lista completa de contribuidores para o Rails](https://contributors.rubyonrails.org/) para
as muitas pessoas que passaram muitas horas fazendo do Rails o framework estável e robusto
que ele é. Parabéns a todos eles.

[railties]:       https://github.com/rails/rails/blob/5-0-stable/railties/CHANGELOG.md
[action-pack]:    https://github.com/rails/rails/blob/5-0-stable/actionpack/CHANGELOG.md
[action-view]:    https://github.com/rails/rails/blob/5-0-stable/actionview/CHANGELOG.md
[action-mailer]:  https://github.com/rails/rails/blob/5-0-stable/actionmailer/CHANGELOG.md
[action-cable]:   https://github.com/rails/rails/blob/5-0-stable/actioncable/CHANGELOG.md
[active-record]:  https://github.com/rails/rails/blob/5-0-stable/activerecord/CHANGELOG.md
[active-model]:   https://github.com/rails/rails/blob/5-0-stable/activemodel/CHANGELOG.md
[active-job]:     https://github.com/rails/rails/blob/5-0-stable/activejob/CHANGELOG.md
[active-support]: https://github.com/rails/rails/blob/5-0-stable/activesupport/CHANGELOG.md
