**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 4d8311a1435138a81e26a7e8f537dbde
Ruby on Rails 4.2 Notas de Lançamento
======================================

Destaques no Rails 4.2:

* Active Job
* E-mails Assíncronos
* Adequate Record
* Web Console
* Suporte a chave estrangeira

Estas notas de lançamento cobrem apenas as principais mudanças. Para saber sobre
outras funcionalidades, correções de bugs e mudanças, por favor, consulte os changelogs ou confira a [lista de commits](https://github.com/rails/rails/commits/4-2-stable) no repositório principal do Rails no GitHub.

--------------------------------------------------------------------------------

Atualizando para o Rails 4.2
----------------------------

Se você está atualizando uma aplicação existente, é uma ótima ideia ter uma boa cobertura de testes antes de começar. Você também deve primeiro atualizar para o Rails 4.1, caso ainda não tenha feito isso, e garantir que sua aplicação ainda funcione como esperado antes de tentar atualizar para o Rails 4.2. Uma lista de coisas a serem observadas ao atualizar está disponível no guia [Atualizando o Ruby on Rails](upgrading_ruby_on_rails.html#upgrading-from-rails-4-1-to-rails-4-2).

Principais Funcionalidades
--------------------------

### Active Job

Active Job é um novo framework no Rails 4.2. É uma interface comum em cima de sistemas de fila como [Resque](https://github.com/resque/resque), [Delayed Job](https://github.com/collectiveidea/delayed_job), [Sidekiq](https://github.com/mperham/sidekiq) e outros.

Jobs escritos com a API do Active Job são executados em qualquer uma das filas suportadas graças aos seus respectivos adaptadores. O Active Job já vem pré-configurado com um executor inline que executa os jobs imediatamente.

Jobs frequentemente precisam receber objetos do Active Record como argumentos. O Active Job passa referências de objetos como URIs (identificadores uniformes de recursos) em vez de serializar o objeto em si. A nova biblioteca [Global ID](https://github.com/rails/globalid) constrói URIs e busca os objetos que eles referenciam. Passar objetos do Active Record como argumentos de jobs funciona simplesmente usando o Global ID internamente.

Por exemplo, se `trashable` é um objeto do Active Record, então este job é executado sem problemas, sem envolver serialização:

```ruby
class TrashableCleanupJob < ActiveJob::Base
  def perform(trashable, depth)
    trashable.cleanup(depth)
  end
end
```

Veja o guia [Noções Básicas do Active Job](active_job_basics.html) para mais informações.

### E-mails Assíncronos

Baseado no Active Job, o Action Mailer agora vem com um método `deliver_later` que envia e-mails através da fila, para que não bloqueie o controller ou o model se a fila for assíncrona (a fila inline padrão bloqueia).

Ainda é possível enviar e-mails imediatamente com `deliver_now`.

### Adequate Record

Adequate Record é um conjunto de melhorias de desempenho no Active Record que torna as chamadas comuns de `find` e `find_by` e algumas consultas de associação até 2x mais rápidas.

Isso funciona através do cache de consultas SQL com prepared statements e reutilizando-os em chamadas similares, pulando a maior parte do trabalho de geração de consulta em chamadas subsequentes. Para mais detalhes, por favor, consulte o [post no blog de Aaron Patterson](http://tenderlovemaking.com/2014/02/19/adequaterecord-pro-like-activerecord.html).

O Active Record automaticamente aproveitará essa funcionalidade em operações suportadas sem qualquer envolvimento do usuário ou alterações de código. Aqui estão alguns exemplos de operações suportadas:

```ruby
Post.find(1)  # A primeira chamada gera e armazena o prepared statement
Post.find(2)  # Chamadas subsequentes reutilizam o prepared statement armazenado

Post.find_by_title('first post')
Post.find_by_title('second post')

Post.find_by(title: 'first post')
Post.find_by(title: 'second post')

post.comments
post.comments(true)
```

É importante destacar que, como os exemplos acima sugerem, os prepared statements não armazenam os valores passados nas chamadas dos métodos; em vez disso, eles possuem espaços reservados para eles.

O cache não é utilizado nos seguintes cenários:
- O modelo tem um escopo padrão
- O modelo usa herança de tabela única
- `find` com uma lista de ids, por exemplo:

    ```ruby
    # não em cache
    Post.find(1, 2, 3)
    Post.find([1,2])
    ```

- `find_by` com fragmentos SQL:

    ```ruby
    Post.find_by('published_at < ?', 2.weeks.ago)
    ```

### Console da Web

Novas aplicações geradas com o Rails 4.2 agora vêm com a gem [Web
Console](https://github.com/rails/web-console) por padrão. O Web Console adiciona
um console Ruby interativo em cada página de erro e fornece uma visualização e
helpers de console.

O console interativo nas páginas de erro permite que você execute código no contexto
do local onde a exceção ocorreu. O helper `console`, se chamado
em qualquer lugar em uma view ou controller, inicia um console interativo com o contexto final,
após a renderização ter sido concluída.

### Suporte a Chave Estrangeira

A DSL de migração agora suporta adicionar e remover chaves estrangeiras. Elas são gravadas
no `schema.rb` também. No momento, apenas os adaptadores `mysql`, `mysql2` e `postgresql`
suportam chaves estrangeiras.

```ruby
# adicionar uma chave estrangeira para `articles.author_id` referenciando `authors.id`
add_foreign_key :articles, :authors

# adicionar uma chave estrangeira para `articles.author_id` referenciando `users.lng_id`
add_foreign_key :articles, :users, column: :author_id, primary_key: "lng_id"

# remover a chave estrangeira em `accounts.branch_id`
remove_foreign_key :accounts, :branches

# remover a chave estrangeira em `accounts.owner_id`
remove_foreign_key :accounts, column: :owner_id
```

Consulte a documentação da API em
[add_foreign_key](https://api.rubyonrails.org/v4.2.0/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html#method-i-add_foreign_key)
e
[remove_foreign_key](https://api.rubyonrails.org/v4.2.0/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html#method-i-remove_foreign_key)
para uma descrição completa.


Incompatibilidades
-----------------

Funcionalidades previamente depreciadas foram removidas. Consulte os
componentes individuais para novas depreciações nesta versão.

As seguintes alterações podem exigir ação imediata após a atualização.

### `render` com um Argumento String

Anteriormente, chamar `render "foo/bar"` em uma ação do controller era equivalente a
`render file: "foo/bar"`. No Rails 4.2, isso foi alterado para significar
`render template: "foo/bar"`. Se você precisa renderizar um arquivo, por favor
altere seu código para usar a forma explícita (`render file: "foo/bar"`) em vez disso.

### `respond_with` / `respond_to` em Nível de Classe

`respond_with` e o correspondente `respond_to` em nível de classe foram movidos
para a gem [responders](https://github.com/plataformatec/responders). Adicione
`gem 'responders', '~> 2.0'` ao seu `Gemfile` para usá-lo:

```ruby
# app/controllers/users_controller.rb

class UsersController < ApplicationController
  respond_to :html, :json

  def show
    @user = User.find(params[:id])
    respond_with @user
  end
end
```

O `respond_to` em nível de instância não é afetado:

```ruby
# app/controllers/users_controller.rb

class UsersController < ApplicationController
  def show
    @user = User.find(params[:id])
    respond_to do |format|
      format.html
      format.json { render json: @user }
    end
  end
end
```

### Host Padrão para `rails server`

Devido a uma [mudança no Rack](https://github.com/rack/rack/commit/28b014484a8ac0bbb388e7eaeeef159598ec64fc),
o `rails server` agora escuta em `localhost` em vez de `0.0.0.0` por padrão. Isso
deve ter um impacto mínimo no fluxo de trabalho de desenvolvimento padrão, pois tanto
http://127.0.0.1:3000 quanto http://localhost:3000 continuarão funcionando como antes
em sua própria máquina.

No entanto, com essa alteração, você não poderá mais acessar o servidor Rails
de uma máquina diferente, por exemplo, se seu ambiente de desenvolvimento
estiver em uma máquina virtual e você desejar acessá-lo da máquina host.
Nesses casos, inicie o servidor com `rails server -b 0.0.0.0` para
restaurar o comportamento anterior.

Se você fizer isso, certifique-se de configurar corretamente o firewall para que apenas
máquinas confiáveis em sua rede possam acessar seu servidor de desenvolvimento.
### Símbolos de opção de status alterados para `render`

Devido a uma [mudança no Rack](https://github.com/rack/rack/commit/be28c6a2ac152fe4adfbef71f3db9f4200df89e8), os símbolos que o método `render` aceita para a opção `:status` foram alterados:

- 306: `:reserved` foi removido.
- 413: `:request_entity_too_large` foi renomeado para `:payload_too_large`.
- 414: `:request_uri_too_long` foi renomeado para `:uri_too_long`.
- 416: `:requested_range_not_satisfiable` foi renomeado para `:range_not_satisfiable`.

Lembre-se de que, ao chamar `render` com um símbolo desconhecido, o status da resposta será definido como 500 por padrão.

### Sanitizador de HTML

O sanitizador de HTML foi substituído por uma nova implementação mais robusta, construída com base no [Loofah](https://github.com/flavorjones/loofah) e no [Nokogiri](https://github.com/sparklemotion/nokogiri). O novo sanitizador é mais seguro e sua sanitização é mais poderosa e flexível.

Devido ao novo algoritmo, a saída sanitizada pode ser diferente para determinadas entradas problemáticas.

Se você tiver uma necessidade específica para a saída exata do antigo sanitizador, você pode adicionar o gem [rails-deprecated_sanitizer](https://github.com/kaspth/rails-deprecated_sanitizer) ao `Gemfile`, para ter o comportamento antigo. O gem não emite avisos de depreciação porque é opcional.

O `rails-deprecated_sanitizer` será suportado apenas para o Rails 4.2; ele não será mantido para o Rails 5.0.

Veja [este post no blog](https://blog.plataformatec.com.br/2014/07/the-new-html-sanitizer-in-rails-4-2/) para mais detalhes sobre as mudanças no novo sanitizador.

### `assert_select`

`assert_select` agora é baseado no [Nokogiri](https://github.com/sparklemotion/nokogiri). Como resultado, alguns seletores anteriormente válidos agora não são suportados. Se sua aplicação estiver usando alguma dessas grafias, você precisará atualizá-las:

*   Valores em seletores de atributos podem precisar ser citados se contiverem caracteres não alfanuméricos.

    ```ruby
    # antes
    a[href=/]
    a[href$=/]

    # agora
    a[href="/"]
    a[href$="/"]
    ```

*   DOMs construídos a partir de uma fonte HTML contendo HTML inválido com elementos mal aninhados podem ser diferentes.

    Por exemplo:

    ```ruby
    # conteúdo: <div><i><p></i></div>

    # antes:
    assert_select('div > i')  # => true
    assert_select('div > p')  # => false
    assert_select('i > p')    # => true

    # agora:
    assert_select('div > i')  # => true
    assert_select('div > p')  # => true
    assert_select('i > p')    # => false
    ```

*   Se os dados selecionados contiverem entidades, o valor selecionado para comparação costumava ser bruto (por exemplo, `AT&amp;T`), e agora é avaliado (por exemplo, `AT&T`).

    ```ruby
    # conteúdo: <p>AT&amp;T</p>

    # antes:
    assert_select('p', 'AT&amp;T')  # => true
    assert_select('p', 'AT&T')      # => false

    # agora:
    assert_select('p', 'AT&T')      # => true
    assert_select('p', 'AT&amp;T')  # => false
    ```

Além disso, as substituições tiveram sua sintaxe alterada.

Agora você precisa usar um seletor `:match` semelhante ao CSS:

```ruby
assert_select ":match('id', ?)", 'comment_1'
```

Além disso, as substituições de Regexp têm uma aparência diferente quando a asserção falha. Observe como `/hello/` aqui:

```ruby
assert_select(":match('id', ?)", /hello/)
```

se torna `"(?-mix:hello)"`:

```
Esperava-se pelo menos 1 elemento correspondente a "div:match('id', "(?-mix:hello)")", encontrados 0...
Esperava-se que 0 fosse >= 1.
```

Consulte a documentação do [Rails Dom Testing](https://github.com/rails/rails-dom-testing/tree/8798b9349fb9540ad8cb9a0ce6cb88d1384a210b) para mais informações sobre `assert_select`.


Railties
--------

Consulte o [Changelog][railties] para obter detalhes das alterações.

### Remoções

*   A opção `--skip-action-view` foi removida do gerador de aplicativos. ([Pull Request](https://github.com/rails/rails/pull/17042))

*   O comando `rails application` foi removido sem substituição. ([Pull Request](https://github.com/rails/rails/pull/11616))

### Depreciações

*   Configuração `config.log_level` ausente foi depreciada para ambientes de produção. ([Pull Request](https://github.com/rails/rails/pull/16622))

*   `rake test:all` foi depreciado em favor de `rake test`, pois agora executa todos os testes na pasta `test`. ([Pull Request](https://github.com/rails/rails/pull/17348))
*   `rake test:all:db` foi depreciado em favor de `rake test:db`.
    ([Pull Request](https://github.com/rails/rails/pull/17348))

*   `Rails::Rack::LogTailer` foi depreciado sem substituição.
    ([Commit](https://github.com/rails/rails/commit/84a13e019e93efaa8994b3f8303d635a7702dbce))

### Mudanças notáveis

*   Introduzido `web-console` no `Gemfile` padrão da aplicação.
    ([Pull Request](https://github.com/rails/rails/pull/11667))

*   Adicionada a opção `required` ao gerador de modelo para associações.
    ([Pull Request](https://github.com/rails/rails/pull/16062))

*   Introduzido o namespace `x` para definir opções de configuração personalizadas:

    ```ruby
    # config/environments/production.rb
    config.x.payment_processing.schedule = :daily
    config.x.payment_processing.retries  = 3
    config.x.super_debugger              = true
    ```

    Essas opções estão disponíveis através do objeto de configuração:

    ```ruby
    Rails.configuration.x.payment_processing.schedule # => :daily
    Rails.configuration.x.payment_processing.retries  # => 3
    Rails.configuration.x.super_debugger              # => true
    ```

    ([Commit](https://github.com/rails/rails/commit/611849772dd66c2e4d005dcfe153f7ce79a8a7db))

*   Introduzido `Rails::Application.config_for` para carregar uma configuração para o
    ambiente atual.

    ```yaml
    # config/exception_notification.yml
    production:
      url: http://127.0.0.1:8080
      namespace: my_app_production
    development:
      url: http://localhost:3001
      namespace: my_app_development
    ```

    ```ruby
    # config/environments/production.rb
    Rails.application.configure do
      config.middleware.use ExceptionNotifier, config_for(:exception_notification)
    end
    ```

    ([Pull Request](https://github.com/rails/rails/pull/16129))

*   Introduzida a opção `--skip-turbolinks` no gerador de aplicativos para não gerar
    integração com turbolinks.
    ([Commit](https://github.com/rails/rails/commit/bf17c8a531bc8059d50ad731398002a3e7162a7d))

*   Introduzido o script `bin/setup` como uma convenção para código de configuração automatizada ao
    inicializar uma aplicação.
    ([Pull Request](https://github.com/rails/rails/pull/15189))

*   Alterado o valor padrão de `config.assets.digest` para `true` no desenvolvimento.
    ([Pull Request](https://github.com/rails/rails/pull/15155))

*   Introduzida uma API para registrar novas extensões para `rake notes`.
    ([Pull Request](https://github.com/rails/rails/pull/14379))

*   Introduzido um callback `after_bundle` para uso em templates do Rails.
    ([Pull Request](https://github.com/rails/rails/pull/16359))

*   Introduzido `Rails.gem_version` como um método de conveniência para retornar
    `Gem::Version.new(Rails.version)`.
    ([Pull Request](https://github.com/rails/rails/pull/14101))


Action Pack
-----------

Consulte o [Changelog][action-pack] para obter detalhes das mudanças.

### Remoções

*   `respond_with` e o `respond_to` em nível de classe foram removidos do Rails e
    movidos para o gem `responders` (versão 2.0). Adicione `gem 'responders', '~> 2.0'`
    ao seu `Gemfile` para continuar usando esses recursos.
    ([Pull Request](https://github.com/rails/rails/pull/16526),
     [Mais Detalhes](https://guides.rubyonrails.org/v4.2/upgrading_ruby_on_rails.html#responders))

*   Removido o `AbstractController::Helpers::ClassMethods::MissingHelperError` depreciado
    em favor de `AbstractController::Helpers::MissingHelperError`.
    ([Commit](https://github.com/rails/rails/commit/a1ddde15ae0d612ff2973de9cf768ed701b594e8))

### Depreciações

*   Depreciado a opção `only_path` nos ajudantes `*_path`.
    ([Commit](https://github.com/rails/rails/commit/aa1fadd48fb40dd9396a383696134a259aa59db9))

*   Depreciado `assert_tag`, `assert_no_tag`, `find_tag` e `find_all_tag` em
    favor de `assert_select`.
    ([Commit](https://github.com/rails/rails-dom-testing/commit/b12850bc5ff23ba4b599bf2770874dd4f11bf750))

*   Depreciado o suporte para definir a opção `:to` de um roteador como um símbolo ou uma
    string que não contém o caractere "#":

    ```ruby
    get '/posts', to: MyRackApp    => (Nenhuma mudança necessária)
    get '/posts', to: 'post#index' => (Nenhuma mudança necessária)
    get '/posts', to: 'posts'      => get '/posts', controller: :posts
    get '/posts', to: :index       => get '/posts', action: :index
    ```

    ([Commit](https://github.com/rails/rails/commit/cc26b6b7bccf0eea2e2c1a9ebdcc9d30ca7390d9))

*   Depreciado o suporte para chaves de string em ajudantes de URL:

    ```ruby
    # ruim
    root_path('controller' => 'posts', 'action' => 'index')

    # bom
    root_path(controller: 'posts', action: 'index')
    ```

    ([Pull Request](https://github.com/rails/rails/pull/17743))

### Mudanças notáveis

*   O grupo de métodos `*_filter` foi removido da documentação. Seu
    uso é desencorajado em favor do grupo de métodos `*_action`:

    ```
    after_filter          => after_action
    append_after_filter   => append_after_action
    append_around_filter  => append_around_action
    append_before_filter  => append_before_action
    around_filter         => around_action
    before_filter         => before_action
    prepend_after_filter  => prepend_after_action
    prepend_around_filter => prepend_around_action
    prepend_before_filter => prepend_before_action
    skip_after_filter     => skip_after_action
    skip_around_filter    => skip_around_action
    skip_before_filter    => skip_before_action
    skip_filter           => skip_action_callback
    ```

    Se sua aplicação depende desses métodos, você deve usar os
    métodos de substituição `*_action` em vez disso. Esses métodos serão depreciados
    no futuro e eventualmente serão removidos do Rails.

    (Commit [1](https://github.com/rails/rails/commit/6c5f43bab8206747a8591435b2aa0ff7051ad3de),
    [2](https://github.com/rails/rails/commit/489a8f2a44dc9cea09154ee1ee2557d1f037c7d4))

*   `render nothing: true` ou renderizar um corpo `nil` não adiciona mais um único
    espaço de preenchimento ao corpo da resposta.
    ([Pull Request](https://github.com/rails/rails/pull/14883))
*   O Rails agora inclui automaticamente o digest do template nos ETags.
    ([Pull Request](https://github.com/rails/rails/pull/16527))

*   Os segmentos passados para os auxiliares de URL agora são automaticamente escapados.
    ([Commit](https://github.com/rails/rails/commit/5460591f0226a9d248b7b4f89186bd5553e7768f))

*   Introduzida a opção `always_permitted_parameters` para configurar quais
    parâmetros são permitidos globalmente. O valor padrão dessa configuração
    é `['controller', 'action']`.
    ([Pull Request](https://github.com/rails/rails/pull/15933))

*   Adicionado o método HTTP `MKCALENDAR` do [RFC 4791](https://tools.ietf.org/html/rfc4791).
    ([Pull Request](https://github.com/rails/rails/pull/15121))

*   As notificações `*_fragment.action_controller` agora incluem o nome do controlador
    e da ação na carga útil.
    ([Pull Request](https://github.com/rails/rails/pull/14137))

*   Melhorada a página de erro de roteamento com correspondência aproximada para busca de rotas.
    ([Pull Request](https://github.com/rails/rails/pull/14619))

*   Adicionada uma opção para desabilitar o registro de falhas de CSRF.
    ([Pull Request](https://github.com/rails/rails/pull/14280))

*   Quando o servidor Rails está configurado para servir ativos estáticos, os ativos gzip agora serão
    servidos se o cliente suportar e um arquivo gzip pré-gerado (`.gz`) estiver no disco.
    Por padrão, o pipeline de ativos gera arquivos `.gz` para todos os ativos compressíveis.
    Servir arquivos gzip minimiza a transferência de dados e acelera as solicitações de ativos. Sempre
    [use um CDN](https://guides.rubyonrails.org/v4.2/asset_pipeline.html#cdns) se você estiver
    servindo ativos do seu servidor Rails em produção.
    ([Pull Request](https://github.com/rails/rails/pull/16466))

*   Ao chamar os auxiliares `process` em um teste de integração, o caminho precisa ter
    uma barra inicial. Anteriormente, era possível omiti-la, mas isso era um subproduto da
    implementação e não uma funcionalidade intencional, por exemplo:

    ```ruby
    test "listar todos os posts" do
      get "/posts"
      assert_response :success
    end
    ```

Action View
-----------

Consulte o [Changelog][action-view] para obter detalhes das alterações.

### Depreciações

*   Depreciado `AbstractController::Base.parent_prefixes`.
    Substitua por `AbstractController::Base.local_prefixes` quando quiser alterar
    onde encontrar as visualizações.
    ([Pull Request](https://github.com/rails/rails/pull/15026))

*   Depreciado `ActionView::Digestor#digest(name, format, finder, options = {})`.
    Os argumentos devem ser passados como um hash em vez disso.
    ([Pull Request](https://github.com/rails/rails/pull/14243))

### Alterações notáveis

*   `render "foo/bar"` agora se expande para `render template: "foo/bar"` em vez de
    `render file: "foo/bar"`.
    ([Pull Request](https://github.com/rails/rails/pull/16888))

*   Os auxiliares de formulário não geram mais um elemento `<div>` com CSS inline ao redor
    dos campos ocultos.
    ([Pull Request](https://github.com/rails/rails/pull/14738))

*   Introduzida a variável local especial `#{partial_name}_iteration` para uso com
    partials que são renderizados com uma coleção. Ela fornece acesso ao
    estado atual da iteração por meio dos métodos `index`, `size`, `first?` e
    `last?`.
    ([Pull Request](https://github.com/rails/rails/pull/7698))

*   O preenchimento de espaços reservados I18n segue a mesma convenção do preenchimento de `label`.
    ([Pull Request](https://github.com/rails/rails/pull/16438))


Action Mailer
-------------

Consulte o [Changelog][action-mailer] para obter detalhes das alterações.

### Depreciações

*   Depreciados os auxiliares `*_path` nos mailers. Sempre use os auxiliares `*_url` em vez disso.
    ([Pull Request](https://github.com/rails/rails/pull/15840))

*   Depreciados `deliver` / `deliver!` em favor de `deliver_now` / `deliver_now!`.
    ([Pull Request](https://github.com/rails/rails/pull/16582))

### Alterações notáveis

*   `link_to` e `url_for` geram URLs absolutas por padrão nos templates,
    não é mais necessário passar `only_path: false`.
    ([Commit](https://github.com/rails/rails/commit/9685080a7677abfa5d288a81c3e078368c6bb67c))

*   Introduzido `deliver_later`, que enfileira um trabalho na fila da aplicação
    para enviar e-mails de forma assíncrona.
    ([Pull Request](https://github.com/rails/rails/pull/16485))

*   Adicionada a opção de configuração `show_previews` para habilitar visualizações de mailer
    fora do ambiente de desenvolvimento.
    ([Pull Request](https://github.com/rails/rails/pull/15970))


Active Record
-------------

Consulte o [Changelog][active-record] para obter detalhes das alterações.

### Remoções

*   Removido `cache_attributes` e similares. Todos os atributos são armazenados em cache.
    ([Pull Request](https://github.com/rails/rails/pull/15429))

*   Removido o método depreciado `ActiveRecord::Base.quoted_locking_column`.
    ([Pull Request](https://github.com/rails/rails/pull/15612))

*   Removido `ActiveRecord::Migrator.proper_table_name` depreciado. Use o
    método de instância `proper_table_name` em `ActiveRecord::Migration` em vez disso.
    ([Pull Request](https://github.com/rails/rails/pull/15512))

*   Removido o tipo `:timestamp` não utilizado. Ele é agora um alias transparente para `:datetime`
    em todos os casos. Corrige inconsistências quando os tipos de coluna são enviados para fora do
    Active Record, como para serialização XML.
    ([Pull Request](https://github.com/rails/rails/pull/15184))
### Descontinuações

*   Descontinuado o tratamento de erros dentro de `after_commit` e `after_rollback`.
    ([Pull Request](https://github.com/rails/rails/pull/16537))

*   Descontinuado o suporte quebrado para detecção automática de contadores em cache em associações `has_many :through`. Agora você deve especificar manualmente o contador em cache nas associações `has_many` e `belongs_to` para os registros intermediários.
    ([Pull Request](https://github.com/rails/rails/pull/15754))

*   Descontinuado o uso de objetos Active Record em `.find` ou `.exists?`. Agora é necessário chamar `id` nos objetos primeiro.
    (Commit [1](https://github.com/rails/rails/commit/d92ae6ccca3bcfd73546d612efaea011270bd270),
    [2](https://github.com/rails/rails/commit/d35f0033c7dec2b8d8b52058fb8db495d49596f7))

*   Descontinuado o suporte incompleto para valores de intervalo do PostgreSQL com início excluído. Atualmente, mapeamos os intervalos do PostgreSQL para intervalos do Ruby. Essa conversão não é totalmente possível porque os intervalos do Ruby não suportam inícios excluídos.

    A solução atual de incrementar o início não está correta e agora está descontinuada. Para subtipos em que não sabemos como incrementar (por exemplo, `succ` não está definido), será lançado um `ArgumentError` para intervalos com inícios excluídos.
    ([Commit](https://github.com/rails/rails/commit/91949e48cf41af9f3e4ffba3e5eecf9b0a08bfc3))

*   Descontinuado o uso de `DatabaseTasks.load_schema` sem uma conexão. Use `DatabaseTasks.load_schema_current` em vez disso.
    ([Commit](https://github.com/rails/rails/commit/f15cef67f75e4b52fd45655d7c6ab6b35623c608))

*   Descontinuado o uso de `sanitize_sql_hash_for_conditions` sem substituição. O uso de uma `Relation` para realizar consultas e atualizações é a API preferida.
    ([Commit](https://github.com/rails/rails/commit/d5902c9e))

*   Descontinuado o uso de `add_timestamps` e `t.timestamps` sem passar a opção `:null`. O padrão `null: true` será alterado para `null: false` no Rails 5.
    ([Pull Request](https://github.com/rails/rails/pull/16481))

*   Descontinuado o uso de `Reflection#source_macro` sem substituição, pois não é mais necessário no Active Record.
    ([Pull Request](https://github.com/rails/rails/pull/16373))

*   Descontinuado o uso de `serialized_attributes` sem substituição.
    ([Pull Request](https://github.com/rails/rails/pull/15704))

*   Descontinuado o retorno de `nil` de `column_for_attribute` quando não existe uma coluna. A partir do Rails 5.0, será retornado um objeto nulo.
    ([Pull Request](https://github.com/rails/rails/pull/15878))

*   Descontinuado o uso de `.joins`, `.preload` e `.eager_load` com associações que dependem do estado da instância (ou seja, aquelas definidas com um escopo que recebe um argumento) sem substituição.
    ([Commit](https://github.com/rails/rails/commit/ed56e596a0467390011bc9d56d462539776adac1))

### Mudanças notáveis

*   `SchemaDumper` usa `force: :cascade` em `create_table`. Isso permite recarregar um esquema quando as chaves estrangeiras estão em vigor.

*   Adicionada a opção `:required` para associações singulares, que define uma validação de presença na associação.
    ([Pull Request](https://github.com/rails/rails/pull/16056))

*   `ActiveRecord::Dirty` agora detecta alterações em valores mutáveis feitas no local. Atributos serializados em modelos Active Record não são mais salvos quando não são alterados. Isso também funciona com outros tipos, como colunas de string e colunas json no PostgreSQL.
    (Pull Requests [1](https://github.com/rails/rails/pull/15674),
    [2](https://github.com/rails/rails/pull/15786),
    [3](https://github.com/rails/rails/pull/15788))

*   Introduzida a tarefa Rake `db:purge` para esvaziar o banco de dados do ambiente atual.
    ([Commit](https://github.com/rails/rails/commit/e2f232aba15937a4b9d14bd91e0392c6d55be58d))

*   Introduzido `ActiveRecord::Base#validate!` que lança `ActiveRecord::RecordInvalid` se o registro for inválido.
    ([Pull Request](https://github.com/rails/rails/pull/8639))

*   Introduzido `validate` como um alias para `valid?`.
    ([Pull Request](https://github.com/rails/rails/pull/14456))

*   `touch` agora aceita vários atributos para serem atualizados de uma vez.
    ([Pull Request](https://github.com/rails/rails/pull/14423))

*   O adaptador PostgreSQL agora suporta o tipo de dados `jsonb` no PostgreSQL 9.4+.
    ([Pull Request](https://github.com/rails/rails/pull/16220))

*   Os adaptadores PostgreSQL e SQLite não adicionam mais um limite padrão de 255 caracteres em colunas de string.
    ([Pull Request](https://github.com/rails/rails/pull/14579))

*   Adicionado suporte para o tipo de coluna `citext` no adaptador PostgreSQL.
    ([Pull Request](https://github.com/rails/rails/pull/12523))

*   Adicionado suporte para tipos de intervalo criados pelo usuário no adaptador PostgreSQL.
    ([Commit](https://github.com/rails/rails/commit/4cb47167e747e8f9dc12b0ddaf82bdb68c03e032))

*   `sqlite3:///algum/caminho` agora é resolvido para o caminho absoluto do sistema `/algum/caminho`. Para caminhos relativos, use `sqlite3:some/path` em vez disso.
    (Anteriormente, `sqlite3:///algum/caminho` era resolvido para o caminho relativo `some/path`. Esse comportamento foi descontinuado no Rails 4.1).
    ([Pull Request](https://github.com/rails/rails/pull/14569))

*   Adicionado suporte para segundos fracionários para o MySQL 5.6 e superior.
    (Pull Request [1](https://github.com/rails/rails/pull/8240),
    [2](https://github.com/rails/rails/pull/14359))
*   Adicionado `ActiveRecord::Base#pretty_print` para imprimir modelos de forma legível.
    ([Pull Request](https://github.com/rails/rails/pull/15172))

*   `ActiveRecord::Base#reload` agora se comporta da mesma forma que `m = Model.find(m.id)`,
    o que significa que não mantém mais os atributos extras de `SELECT`s personalizados.
    ([Pull Request](https://github.com/rails/rails/pull/15866))

*   `ActiveRecord::Base#reflections` agora retorna um hash com chaves de string em vez de chaves de símbolo.
    ([Pull Request](https://github.com/rails/rails/pull/17718))

*   O método `references` nas migrações agora suporta uma opção `type` para especificar o tipo da chave estrangeira (por exemplo, `:uuid`).
    ([Pull Request](https://github.com/rails/rails/pull/16231))

Active Model
------------

Consulte o [Changelog][active-model] para obter detalhes sobre as alterações.

### Remoções

*   Removido `Validator#setup` obsoleto sem substituição.
    ([Pull Request](https://github.com/rails/rails/pull/10716))

### Depreciações

*   Obsoleto `reset_#{attribute}` em favor de `restore_#{attribute}`.
    ([Pull Request](https://github.com/rails/rails/pull/16180))

*   Obsoleto `ActiveModel::Dirty#reset_changes` em favor de
    `clear_changes_information`.
    ([Pull Request](https://github.com/rails/rails/pull/16180))

### Alterações notáveis

*   Introduzido `validate` como um alias para `valid?`.
    ([Pull Request](https://github.com/rails/rails/pull/14456))

*   Introduziu o método `restore_attributes` em `ActiveModel::Dirty` para restaurar
    os atributos alterados (sujos) para seus valores anteriores.
    (Pull Request [1](https://github.com/rails/rails/pull/14861),
    [2](https://github.com/rails/rails/pull/16180))

*   `has_secure_password` não impede mais senhas em branco (ou seja, senhas
    que contêm apenas espaços) por padrão.
    ([Pull Request](https://github.com/rails/rails/pull/16412))

*   `has_secure_password` agora verifica se a senha fornecida tem menos de 72
    caracteres se as validações estiverem habilitadas.
    ([Pull Request](https://github.com/rails/rails/pull/15708))

Active Support
--------------

Consulte o [Changelog][active-support] para obter detalhes sobre as alterações.

### Remoções

*   Removido `Numeric#ago`, `Numeric#until`, `Numeric#since`,
    `Numeric#from_now` obsoletos.
    ([Commit](https://github.com/rails/rails/commit/f1eddea1e3f6faf93581c43651348f48b2b7d8bb))

*   Removidos terminadores baseados em string obsoletos para `ActiveSupport::Callbacks`.
    ([Pull Request](https://github.com/rails/rails/pull/15100))

### Depreciações

*   Obsoleto `Kernel#silence_stderr`, `Kernel#capture` e `Kernel#quietly`
    sem substituição.
    ([Pull Request](https://github.com/rails/rails/pull/13392))

*   Obsoleto `Class#superclass_delegating_accessor`, use
    `Class#class_attribute` em vez disso.
    ([Pull Request](https://github.com/rails/rails/pull/14271))

*   Obsoleto `ActiveSupport::SafeBuffer#prepend!` como
    `ActiveSupport::SafeBuffer#prepend` agora realiza a mesma função.
    ([Pull Request](https://github.com/rails/rails/pull/14529))

### Alterações notáveis

*   Introduzida uma nova opção de configuração `active_support.test_order` para
    especificar a ordem em que os casos de teste são executados. Esta opção atualmente tem
    o valor padrão `:sorted`, mas será alterada para `:random` no Rails 5.0.
    ([Commit](https://github.com/rails/rails/commit/53e877f7d9291b2bf0b8c425f9e32ef35829f35b))

*   `Object#try` e `Object#try!` agora podem ser usados sem um receptor explícito no bloco.
    ([Commit](https://github.com/rails/rails/commit/5e51bdda59c9ba8e5faf86294e3e431bd45f1830),
    [Pull Request](https://github.com/rails/rails/pull/17361))

*   O auxiliar de teste `travel_to` agora trunca o componente `usec` para 0.
    ([Commit](https://github.com/rails/rails/commit/9f6e82ee4783e491c20f5244a613fdeb4024beb5))

*   Introduzido `Object#itself` como uma função de identidade.
    (Commit [1](https://github.com/rails/rails/commit/702ad710b57bef45b081ebf42e6fa70820fdd810),
    [2](https://github.com/rails/rails/commit/64d91122222c11ad3918cc8e2e3ebc4b0a03448a))

*   `Object#with_options` agora pode ser usado sem um receptor explícito no bloco.
    ([Pull Request](https://github.com/rails/rails/pull/16339))

*   Introduzido `String#truncate_words` para truncar uma string por um número de palavras.
    ([Pull Request](https://github.com/rails/rails/pull/16190))

*   Adicionado `Hash#transform_values` e `Hash#transform_values!` para simplificar um
    padrão comum em que os valores de um hash devem ser alterados, mas as chaves são mantidas
    as mesmas.
    ([Pull Request](https://github.com/rails/rails/pull/15819))

*   O auxiliar de inflexão `humanize` agora remove quaisquer sublinhados iniciais.
    ([Commit](https://github.com/rails/rails/commit/daaa21bc7d20f2e4ff451637423a25ff2d5e75c7))

*   Introduzido `Concern#class_methods` como uma alternativa para
    `module ClassMethods`, bem como `Kernel#concern` para evitar o
    boilerplate `module Foo; extend ActiveSupport::Concern; end`.
    ([Commit](https://github.com/rails/rails/commit/b16c36e688970df2f96f793a759365b248b582ad))

*   Novo [guia](autoloading_and_reloading_constants_classic_mode.html) sobre carregamento automático e recarregamento de constantes.

Créditos
-------

Consulte a
[lista completa de contribuidores para o Rails](https://contributors.rubyonrails.org/) para
as muitas pessoas que passaram muitas horas tornando o Rails o framework estável e robusto
que é hoje. Parabéns a todos eles.

[railties]:       https://github.com/rails/rails/blob/4-2-stable/railties/CHANGELOG.md
[action-pack]:    https://github.com/rails/rails/blob/4-2-stable/actionpack/CHANGELOG.md
[action-view]:    https://github.com/rails/rails/blob/4-2-stable/actionview/CHANGELOG.md
[action-mailer]:  https://github.com/rails/rails/blob/4-2-stable/actionmailer/CHANGELOG.md
[active-record]:  https://github.com/rails/rails/blob/4-2-stable/activerecord/CHANGELOG.md
[active-model]:   https://github.com/rails/rails/blob/4-2-stable/activemodel/CHANGELOG.md
[active-support]: https://github.com/rails/rails/blob/4-2-stable/activesupport/CHANGELOG.md
[active-support]: https://github.com/rails/rails/blob/4-2-stable/activesupport/CHANGELOG.md
