**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 77b47af4826df984dead9f6263cfd135
Ruby on Rails 2.3 Notas de Lançamento
======================================

O Rails 2.3 oferece uma variedade de recursos novos e aprimorados, incluindo integração pervasiva com o Rack, suporte atualizado para Rails Engines, transações aninhadas para o Active Record, escopos dinâmicos e padrão, renderização unificada, roteamento mais eficiente, modelos de aplicativos e backtraces silenciosos. Esta lista abrange as principais atualizações, mas não inclui todas as pequenas correções de bugs e alterações. Se você quiser ver tudo, confira a [lista de commits](https://github.com/rails/rails/commits/2-3-stable) no repositório principal do Rails no GitHub ou revise os arquivos `CHANGELOG` para os componentes individuais do Rails.

--------------------------------------------------------------------------------

Arquitetura da Aplicação
------------------------

Existem duas mudanças importantes na arquitetura das aplicações Rails: integração completa com a interface do servidor web modular [Rack](https://rack.github.io/) e suporte renovado para Rails Engines.

### Integração com o Rack

O Rails agora abandonou seu passado com o CGI e usa o Rack em todos os lugares. Isso exigiu e resultou em uma enorme quantidade de mudanças internas (mas se você usa o CGI, não se preocupe; o Rails agora suporta o CGI por meio de uma interface de proxy). Ainda assim, essa é uma mudança importante nos internos do Rails. Após a atualização para a versão 2.3, você deve testar em seu ambiente local e em seu ambiente de produção. Algumas coisas para testar:

* Sessões
* Cookies
* Uploads de arquivos
* APIs JSON/XML

Aqui está um resumo das mudanças relacionadas ao Rack:

* O `script/server` foi alterado para usar o Rack, o que significa que ele suporta qualquer servidor compatível com o Rack. O `script/server` também irá buscar um arquivo de configuração rackup, caso exista. Por padrão, ele procurará por um arquivo `config.ru`, mas você pode substituir isso com a opção `-c`.
* O manipulador FCGI passa pelo Rack.
* O `ActionController::Dispatcher` mantém sua própria pilha de middlewares padrão. Middlewares podem ser injetados, reordenados e removidos. A pilha é compilada em uma cadeia na inicialização. Você pode configurar a pilha de middlewares em `environment.rb`.
* A tarefa `rake middleware` foi adicionada para inspecionar a pilha de middlewares. Isso é útil para depurar a ordem da pilha de middlewares.
* O executor de testes de integração foi modificado para executar toda a pilha de middlewares e aplicação. Isso torna os testes de integração perfeitos para testar middlewares do Rack.
* O `ActionController::CGIHandler` é uma camada de compatibilidade CGI retrocompatível com o Rack. O `CGIHandler` deve receber um objeto CGI antigo e converter suas informações de ambiente em uma forma compatível com o Rack.
* `CgiRequest` e `CgiResponse` foram removidos.
* Os armazenamentos de sessão agora são carregados de forma preguiçosa. Se você nunca acessar o objeto de sessão durante uma solicitação, ele nunca tentará carregar os dados da sessão (analisar o cookie, carregar os dados do memcache ou procurar um objeto Active Record).
* Você não precisa mais usar `CGI::Cookie.new` em seus testes para definir um valor de cookie. Atribuir um valor `String` para `request.cookies["foo"]` agora define o cookie como esperado.
* `CGI::Session::CookieStore` foi substituído por `ActionController::Session::CookieStore`.
* `CGI::Session::MemCacheStore` foi substituído por `ActionController::Session::MemCacheStore`.
* `CGI::Session::ActiveRecordStore` foi substituído por `ActiveRecord::SessionStore`.
* Ainda é possível alterar o armazenamento da sessão com `ActionController::Base.session_store = :active_record_store`.
* As opções padrão das sessões ainda são definidas com `ActionController::Base.session = { :key => "..." }`. No entanto, a opção `:session_domain` foi renomeada para `:domain`.
* O mutex que normalmente envolve toda a sua solicitação foi movido para o middleware `ActionController::Lock`.
* `ActionController::AbstractRequest` e `ActionController::Request` foram unificados. O novo `ActionController::Request` herda de `Rack::Request`. Isso afeta o acesso a `response.headers['type']` em solicitações de teste. Use `response.content_type` em vez disso.
* O middleware `ActiveRecord::QueryCache` é automaticamente inserido na pilha de middlewares se o `ActiveRecord` tiver sido carregado. Esse middleware configura e limpa o cache de consulta do Active Record por solicitação.
* O roteador e as classes de controlador do Rails seguem a especificação do Rack. Você pode chamar um controlador diretamente com `SomeController.call(env)`. O roteador armazena os parâmetros de roteamento em `rack.routing_args`.
* `ActionController::Request` herda de `Rack::Request`.
* Em vez de `config.action_controller.session = { :session_key => 'foo', ...`, use `config.action_controller.session = { :key => 'foo', ...`.
* O uso do middleware `ParamsParser` pré-processa qualquer solicitação XML, JSON ou YAML para que possam ser lidas normalmente com qualquer objeto `Rack::Request` posteriormente.

### Suporte Renovado para Rails Engines

Após algumas versões sem atualização, o Rails 2.3 oferece alguns recursos novos para Rails Engines (aplicações Rails que podem ser incorporadas em outras aplicações). Primeiro, os arquivos de roteamento nos engines agora são carregados e recarregados automaticamente, assim como o seu arquivo `routes.rb` (isso também se aplica aos arquivos de roteamento em outros plugins). Segundo, se o seu plugin tiver uma pasta `app`, então `app/[models|controllers|helpers]` será automaticamente adicionado ao caminho de carregamento do Rails. Os engines também suportam adicionar caminhos de visualização agora, e o Action Mailer, assim como o Action View, usará visualizações de engines e outros plugins.
Documentação
-------------

O projeto [Ruby on Rails guides](https://guides.rubyonrails.org/) publicou vários guias adicionais para o Rails 2.3. Além disso, um [site separado](https://edgeguides.rubyonrails.org/) mantém cópias atualizadas dos Guias para o Edge Rails. Outros esforços de documentação incluem o relançamento do [Rails wiki](http://newwiki.rubyonrails.org/) e o planejamento inicial de um livro sobre o Rails.

* Mais informações: [Projetos de Documentação do Rails](https://weblog.rubyonrails.org/2009/1/15/rails-documentation-projects)

Suporte ao Ruby 1.9.1
------------------

O Rails 2.3 deve passar em todos os seus próprios testes, seja executando no Ruby 1.8 ou no Ruby 1.9.1, que já foi lançado. No entanto, você deve estar ciente de que a migração para o 1.9.1 requer a verificação de todos os adaptadores de dados, plugins e outros códigos nos quais você depende para garantir a compatibilidade com o Ruby 1.9.1, além do Rails core.

Active Record
-------------

O Active Record recebe várias novas funcionalidades e correções de bugs no Rails 2.3. Os destaques incluem atributos aninhados, transações aninhadas, escopos dinâmicos e processamento em lote.

### Atributos Aninhados

Agora, o Active Record pode atualizar os atributos em modelos aninhados diretamente, desde que você o instrua a fazê-lo:

```ruby
class Book < ActiveRecord::Base
  has_one :author
  has_many :pages

  accepts_nested_attributes_for :author, :pages
end
```

Ao ativar os atributos aninhados, várias coisas são habilitadas: salvamento automático (e atômico) de um registro junto com seus filhos associados, validações conscientes dos filhos e suporte para formulários aninhados (discutido posteriormente).

Você também pode especificar requisitos para novos registros adicionados por meio de atributos aninhados usando a opção `:reject_if`:

```ruby
accepts_nested_attributes_for :author,
  :reject_if => proc { |attributes| attributes['name'].blank? }
```

* Contribuidor Principal: [Eloy Duran](http://superalloy.nl/)
* Mais informações: [Formulários de Modelos Aninhados](https://weblog.rubyonrails.org/2009/1/26/nested-model-forms)

### Transações Aninhadas

O Active Record agora suporta transações aninhadas, uma funcionalidade muito solicitada. Agora você pode escrever código como este:

```ruby
User.transaction do
  User.create(:username => 'Admin')
  User.transaction(:requires_new => true) do
    User.create(:username => 'Regular')
    raise ActiveRecord::Rollback
  end
end

User.find(:all)  # => Retorna apenas Admin
```

As transações aninhadas permitem que você reverta uma transação interna sem afetar o estado da transação externa. Se você deseja que uma transação seja aninhada, você deve adicionar explicitamente a opção `:requires_new`; caso contrário, uma transação aninhada simplesmente se torna parte da transação pai (como ocorre atualmente no Rails 2.2). Por baixo dos panos, as transações aninhadas estão [usando savepoints](http://rails.lighthouseapp.com/projects/8994/tickets/383), portanto, elas são suportadas mesmo em bancos de dados que não possuem transações aninhadas verdadeiras. Também há um pouco de mágica acontecendo para fazer essas transações funcionarem bem com fixtures transacionais durante os testes.

* Contribuidores Principais: [Jonathan Viney](http://www.workingwithrails.com/person/4985-jonathan-viney) e [Hongli Lai](http://izumi.plan99.net/blog/)

### Escopos Dinâmicos

Você conhece os finders dinâmicos no Rails (que permitem criar métodos como `find_by_color_and_flavor` na hora) e os escopos nomeados (que permitem encapsular condições de consulta reutilizáveis em nomes amigáveis como `currently_active`). Bem, agora você pode ter métodos de escopo dinâmico. A ideia é criar uma sintaxe que permita filtrar dinamicamente _e_ encadear métodos. Por exemplo:

```ruby
Order.scoped_by_customer_id(12)
Order.scoped_by_customer_id(12).find(:all,
  :conditions => "status = 'open'")
Order.scoped_by_customer_id(12).scoped_by_status("open")
```

Não é necessário definir nada para usar escopos dinâmicos: eles simplesmente funcionam.

* Contribuidor Principal: [Yaroslav Markin](http://evilmartians.com/)
* Mais informações: [O que há de novo no Edge Rails: Métodos de Escopo Dinâmico](http://archives.ryandaigle.com/articles/2008/12/29/what-s-new-in-edge-rails-dynamic-scope-methods)

### Escopos Padrão

O Rails 2.3 introduzirá a noção de _escopos padrão_, semelhantes aos escopos nomeados, mas aplicados a todos os escopos nomeados ou métodos de busca dentro do modelo. Por exemplo, você pode escrever `default_scope :order => 'name ASC'` e toda vez que você recuperar registros desse modelo, eles serão retornados ordenados por nome (a menos que você substitua a opção, é claro).

* Contribuidor Principal: Paweł Kondzior
* Mais informações: [O que há de novo no Edge Rails: Escopos Padrão](http://archives.ryandaigle.com/articles/2008/11/18/what-s-new-in-edge-rails-default-scoping)

### Processamento em Lote

Agora você pode processar grandes quantidades de registros de um modelo Active Record com menos pressão na memória usando `find_in_batches`:

```ruby
Customer.find_in_batches(:conditions => {:active => true}) do |customer_group|
  customer_group.each { |customer| customer.update_account_balance! }
end
```

Você pode passar a maioria das opções do `find` para o `find_in_batches`. No entanto, você não pode especificar a ordem em que os registros serão retornados (eles sempre serão retornados em ordem crescente da chave primária, que deve ser um número inteiro) ou usar a opção `:limit`. Em vez disso, use a opção `:batch_size`, que tem o valor padrão de 1000, para definir o número de registros que serão retornados em cada lote.

O novo método `find_each` fornece uma abstração em torno do `find_in_batches` que retorna registros individuais, sendo a busca em lotes (por padrão, de 1000 em 1000):

```ruby
Customer.find_each do |customer|
  customer.update_account_balance!
end
```
Observe que você deve usar este método apenas para processamento em lote: para pequenos números de registros (menos de 1000), você deve usar os métodos regulares de busca com seu próprio loop.

* Mais informações (naquele momento o método de conveniência era chamado apenas de `each`):
    * [Rails 2.3: Localizando em Lote](http://afreshcup.com/2009/02/23/rails-23-batch-finding/)
    * [O que há de novo no Edge Rails: Localização em Lote](http://archives.ryandaigle.com/articles/2009/2/23/what-s-new-in-edge-rails-batched-find)

### Múltiplas Condições para Callbacks

Ao usar callbacks do Active Record, agora você pode combinar as opções `:if` e `:unless` no mesmo callback e fornecer várias condições como um array:

```ruby
before_save :update_credit_rating, :if => :active,
  :unless => [:admin, :cash_only]
```
* Contribuidor Principal: L. Caviola

### Localizar com having

O Rails agora possui uma opção `:having` na busca (assim como nas associações `has_many` e `has_and_belongs_to_many`) para filtrar registros em buscas agrupadas. Como aqueles com experiência em SQL sabem, isso permite filtrar com base em resultados agrupados:

```ruby
developers = Developer.find(:all, :group => "salary",
  :having => "sum(salary) > 10000", :select => "salary")
```

* Contribuidor Principal: [Emilio Tagua](https://github.com/miloops)

### Reconectando Conexões MySQL

O MySQL suporta uma flag de reconexão em suas conexões - se definida como true, o cliente tentará reconectar ao servidor antes de desistir em caso de conexão perdida. Agora você pode definir `reconnect = true` para suas conexões MySQL em `database.yml` para obter esse comportamento de uma aplicação Rails. O padrão é `false`, então o comportamento das aplicações existentes não muda.

* Contribuidor Principal: [Dov Murik](http://twitter.com/dubek)
* Mais informações:
    * [Controlando o Comportamento de Reconexão Automática](http://dev.mysql.com/doc/refman/5.6/en/auto-reconnect.html)
    * [MySQL auto-reconnect revisited](http://groups.google.com/group/rubyonrails-core/browse_thread/thread/49d2a7e9c96cb9f4)

### Outras Mudanças no Active Record

* Um `AS` extra foi removido do SQL gerado para pré-carregamento de `has_and_belongs_to_many`, tornando-o melhor para alguns bancos de dados.
* `ActiveRecord::Base#new_record?` agora retorna `false` em vez de `nil` quando confrontado com um registro existente.
* Um bug na citação de nomes de tabelas em algumas associações `has_many :through` foi corrigido.
* Agora você pode especificar um timestamp específico para timestamps `updated_at`: `cust = Customer.create(:name => "ABC Industries", :updated_at => 1.day.ago)`
* Melhores mensagens de erro em chamadas falhadas de `find_by_attribute!`.
* O suporte `to_xml` do Active Record fica um pouco mais flexível com a adição de uma opção `:camelize`.
* Um bug no cancelamento de callbacks de `before_update` ou `before_create` foi corrigido.
* Tarefas Rake para testar bancos de dados via JDBC foram adicionadas.
* `validates_length_of` usará uma mensagem de erro personalizada com as opções `:in` ou `:within` (se uma for fornecida).
* Contagens em seleções com escopo agora funcionam corretamente, então você pode fazer coisas como `Account.scoped(:select => "DISTINCT credit_limit").count`.
* `ActiveRecord::Base#invalid?` agora funciona como o oposto de `ActiveRecord::Base#valid?`.

Action Controller
-----------------

O Action Controller apresenta algumas mudanças significativas na renderização, bem como melhorias no roteamento e em outras áreas, nesta versão.

### Renderização Unificada

`ActionController::Base#render` está mais inteligente ao decidir o que renderizar. Agora você pode apenas dizer o que renderizar e esperar obter os resultados corretos. Nas versões anteriores do Rails, você frequentemente precisa fornecer informações explícitas para renderizar:

```ruby
render :file => '/tmp/random_file.erb'
render :template => 'other_controller/action'
render :action => 'show'
```

Agora, no Rails 2.3, você pode apenas fornecer o que deseja renderizar:

```ruby
render '/tmp/random_file.erb'
render 'other_controller/action'
render 'show'
render :show
```

O Rails escolhe entre arquivo, template e ação dependendo se há uma barra inicial, uma barra embutida ou nenhuma barra em tudo no que será renderizado. Observe que você também pode usar um símbolo em vez de uma string ao renderizar uma ação. Outros estilos de renderização (`:inline`, `:text`, `:update`, `:nothing`, `:json`, `:xml`, `:js`) ainda requerem uma opção explícita.

### Controlador de Aplicação Renomeado

Se você é uma das pessoas que sempre se incomodou com o nome especial de `application.rb`, comemore! Ele foi reformulado para ser `application_controller.rb` no Rails 2.3. Além disso, há uma nova tarefa rake, `rake rails:update:application_controller`, para fazer isso automaticamente para você - e ela será executada como parte do processo normal de `rake rails:update`.

* Mais informações:
    * [A Morte de Application.rb](https://afreshcup.com/home/2008/11/17/rails-2x-the-death-of-applicationrb)
    * [O que há de novo no Edge Rails: A Dualidade de Application.rb não Existe Mais](http://archives.ryandaigle.com/articles/2008/11/19/what-s-new-in-edge-rails-application-rb-duality-is-no-more)

### Suporte à Autenticação Digest HTTP

O Rails agora possui suporte integrado para autenticação digest HTTP. Para usá-lo, você chama `authenticate_or_request_with_http_digest` com um bloco que retorna a senha do usuário (que é então hashada e comparada com as credenciais transmitidas):

```ruby
class PostsController < ApplicationController
  Users = {"dhh" => "secret"}
  before_filter :authenticate

  def secret
    render :text => "Senha Requerida!"
  end

  private
  def authenticate
    realm = "Application"
    authenticate_or_request_with_http_digest(realm) do |name|
      Users[name]
    end
  end
end
```
* Contribuidor Principal: [Gregg Kellogg](http://www.kellogg-assoc.com/)
* Mais Informações: [O que há de novo no Edge Rails: Autenticação Digest HTTP](http://archives.ryandaigle.com/articles/2009/1/30/what-s-new-in-edge-rails-http-digest-authentication)

### Roteamento mais eficiente

Existem algumas mudanças significativas no roteamento do Rails 2.3. Os auxiliares de rota `formatted_` foram removidos, em favor de passar apenas `:format` como uma opção. Isso reduz o processo de geração de rota em 50% para qualquer recurso - e pode economizar uma quantidade substancial de memória (até 100MB em aplicativos grandes). Se o seu código usa os auxiliares `formatted_`, eles ainda funcionarão por enquanto - mas esse comportamento está obsoleto e sua aplicação será mais eficiente se você reescrever essas rotas usando o novo padrão. Outra grande mudança é que o Rails agora suporta vários arquivos de roteamento, não apenas `routes.rb`. Você pode usar `RouteSet#add_configuration_file` para adicionar mais rotas a qualquer momento - sem limpar as rotas atualmente carregadas. Embora essa mudança seja mais útil para Engines, você pode usá-la em qualquer aplicativo que precise carregar rotas em lotes.

* Contribuidor Principal: [Aaron Batalion](http://blog.hungrymachine.com/)

### Sessões Carregadas Preguiçosamente Baseadas em Rack

Uma grande mudança empurrou as bases do armazenamento de sessão do Action Controller para o nível do Rack. Isso envolveu um bom trabalho no código, embora deva ser completamente transparente para suas aplicações Rails (como um bônus, alguns patches desagradáveis em torno do antigo manipulador de sessão CGI foram removidos). Ainda é significativo, no entanto, por uma razão simples: aplicativos Rack não-Rails têm acesso aos mesmos manipuladores de armazenamento de sessão (e, portanto, à mesma sessão) que suas aplicações Rails. Além disso, as sessões agora são carregadas preguiçosamente (em linha com as melhorias de carregamento no restante do framework). Isso significa que você não precisa mais desabilitar explicitamente as sessões se não quiser; basta não se referir a elas e elas não serão carregadas.

### Mudanças no Tratamento de Tipos MIME

Existem algumas mudanças no código para o tratamento de tipos MIME no Rails. Primeiro, `MIME::Type` agora implementa o operador `=~`, tornando as coisas muito mais limpas quando você precisa verificar a presença de um tipo que tem sinônimos:

```ruby
if content_type && Mime::JS =~ content_type
  # faça algo legal
end

Mime::JS =~ "text/javascript"        => true
Mime::JS =~ "application/javascript" => true
```

A outra mudança é que o framework agora usa o `Mime::JS` ao verificar o JavaScript em vários pontos, tornando-o tratando essas alternativas de forma limpa.

* Contribuidor Principal: [Seth Fitzsimmons](http://www.workingwithrails.com/person/5510-seth-fitzsimmons)

### Otimização do `respond_to`

Em alguns dos primeiros frutos da fusão das equipes Rails-Merb, o Rails 2.3 inclui algumas otimizações para o método `respond_to`, que é amplamente usado em muitas aplicações Rails para permitir que seu controlador formate os resultados de maneira diferente com base no tipo MIME da solicitação recebida. Após eliminar uma chamada para `method_missing` e fazer alguns perfis e ajustes, estamos vendo uma melhoria de 8% no número de solicitações por segundo atendidas com um simples `respond_to` que alterna entre três formatos. A melhor parte? Nenhuma alteração no código da sua aplicação é necessária para aproveitar essa melhoria de velocidade.

### Melhoria no Desempenho do Cache

O Rails agora mantém um cache local por solicitação de leitura dos armazenamentos de cache remotos, reduzindo as leituras desnecessárias e melhorando o desempenho do site. Embora esse trabalho fosse originalmente limitado ao `MemCacheStore`, ele está disponível para qualquer armazenamento remoto que implemente os métodos necessários.

* Contribuidor Principal: [Nahum Wild](http://www.motionstandingstill.com/)

### Visualizações Localizadas

O Rails agora pode fornecer visualizações localizadas, dependendo da localidade que você definiu. Por exemplo, suponha que você tenha um controlador `Posts` com uma ação `show`. Por padrão, isso renderizará `app/views/posts/show.html.erb`. Mas se você definir `I18n.locale = :da`, ele renderizará `app/views/posts/show.da.html.erb`. Se o modelo localizado não estiver presente, a versão não decorada será usada. O Rails também inclui `I18n#available_locales` e `I18n::SimpleBackend#available_locales`, que retornam uma matriz das traduções disponíveis no projeto Rails atual.

Além disso, você pode usar o mesmo esquema para localizar os arquivos de resgate no diretório público: `public/500.da.html` ou `public/404.en.html` funcionam, por exemplo.

### Escopo Parcial para Traduções

Uma mudança na API de tradução torna mais fácil e menos repetitivo escrever traduções de chave dentro de parciais. Se você chamar `translate(".foo")` no modelo `people/index.html.erb`, você estará chamando `I18n.translate("people.index.foo")`. Se você não adicionar um ponto antes da chave, a API não fará o escopo, assim como antes.
### Outras mudanças no Action Controller

* O tratamento de ETag foi melhorado: o Rails agora não enviará um cabeçalho ETag quando não houver corpo na resposta ou ao enviar arquivos com `send_file`.
* O fato de o Rails verificar a falsificação de IP pode ser um incômodo para sites que têm muito tráfego com celulares, porque seus proxies geralmente não configuram corretamente. Se esse for o seu caso, agora você pode definir `ActionController::Base.ip_spoofing_check = false` para desativar completamente a verificação.
* O `ActionController::Dispatcher` agora implementa sua própria pilha de middlewares, que você pode ver executando `rake middleware`.
* As sessões de cookies agora têm identificadores de sessão persistentes, com compatibilidade de API com os armazenamentos do lado do servidor.
* Agora você pode usar símbolos para a opção `:type` do `send_file` e `send_data`, assim: `send_file("fabulous.png", :type => :png)`.
* As opções `:only` e `:except` para `map.resources` não são mais herdadas por recursos aninhados.
* O cliente memcached incluído foi atualizado para a versão 1.6.4.99.
* Os métodos `expires_in`, `stale?` e `fresh_when` agora aceitam a opção `:public` para funcionarem bem com o cache de proxy.
* A opção `:requirements` agora funciona corretamente com rotas adicionais de membros RESTful.
* As rotas rasas agora respeitam corretamente os namespaces.
* `polymorphic_url` lida melhor com objetos com nomes plurais irregulares.

Action View
-----------

O Action View no Rails 2.3 suporta formulários de modelos aninhados, melhorias no `render`, prompts mais flexíveis para os auxiliares de seleção de data e uma aceleração no cache de ativos, entre outras coisas.

### Formulários de Objetos Aninhados

Desde que o modelo pai aceite atributos aninhados para os objetos filhos (conforme discutido na seção Active Record), você pode criar formulários aninhados usando `form_for` e `field_for`. Esses formulários podem ser aninhados arbitrariamente, permitindo que você edite hierarquias de objetos complexos em uma única visualização sem código excessivo. Por exemplo, dado este modelo:

```ruby
class Customer < ActiveRecord::Base
  has_many :orders

  accepts_nested_attributes_for :orders, :allow_destroy => true
end
```

Você pode escrever esta visualização no Rails 2.3:

```html+erb
<% form_for @customer do |customer_form| %>
  <div>
    <%= customer_form.label :name, 'Nome do Cliente:' %>
    <%= customer_form.text_field :name %>
  </div>

  <!-- Aqui chamamos fields_for na instância do construtor customer_form.
   O bloco é chamado para cada membro da coleção orders. -->
  <% customer_form.fields_for :orders do |order_form| %>
    <p>
      <div>
        <%= order_form.label :number, 'Número do Pedido:' %>
        <%= order_form.text_field :number %>
      </div>

  <!-- A opção allow_destroy no modelo permite a exclusão de
   registros filhos. -->
      <% unless order_form.object.new_record? %>
        <div>
          <%= order_form.label :_delete, 'Remover:' %>
          <%= order_form.check_box :_delete %>
        </div>
      <% end %>
    </p>
  <% end %>

  <%= customer_form.submit %>
<% end %>
```

* Contribuidor Principal: [Eloy Duran](http://superalloy.nl/)
* Mais Informações:
    * [Formulários de Modelos Aninhados](https://weblog.rubyonrails.org/2009/1/26/nested-model-forms)
    * [complex-form-examples](https://github.com/alloy/complex-form-examples)
    * [O que há de novo no Edge Rails: Formulários de Objetos Aninhados](http://archives.ryandaigle.com/articles/2009/2/1/what-s-new-in-edge-rails-nested-attributes)

### Renderização Inteligente de Partials

O método `render` tem ficado mais inteligente ao longo dos anos, e agora está ainda mais inteligente. Se você tiver um objeto ou uma coleção e um partial apropriado, e os nomes coincidirem, agora você pode simplesmente renderizar o objeto e as coisas funcionarão. Por exemplo, no Rails 2.3, essas chamadas de renderização funcionarão em sua visualização (assumindo nomes sensatos):

```ruby
# Equivalente a render :partial => 'articles/_article',
# :object => @article
render @article

# Equivalente a render :partial => 'articles/_article',
# :collection => @articles
render @articles
```

* Mais Informações: [O que há de novo no Edge Rails: render deixa de ser complicado](http://archives.ryandaigle.com/articles/2008/11/20/what-s-new-in-edge-rails-render-stops-being-high-maintenance)

### Prompts para Auxiliares de Seleção de Data

No Rails 2.3, você pode fornecer prompts personalizados para os vários auxiliares de seleção de data (`date_select`, `time_select` e `datetime_select`), da mesma forma que pode fazer com os auxiliares de seleção de coleção. Você pode fornecer uma string de prompt ou um hash de strings de prompt individuais para os vários componentes. Você também pode simplesmente definir `:prompt` como `true` para usar o prompt genérico personalizado:

```ruby
select_datetime(DateTime.now, :prompt => true)

select_datetime(DateTime.now, :prompt => "Escolha a data e a hora")

select_datetime(DateTime.now, :prompt =>
  {:day => 'Escolha o dia', :month => 'Escolha o mês',
   :year => 'Escolha o ano', :hour => 'Escolha a hora',
   :minute => 'Escolha o minuto'})
```

* Contribuidor Principal: [Sam Oliver](http://samoliver.com/)

### Cache de Timestamp de AssetTag

Você provavelmente está familiarizado com a prática do Rails de adicionar timestamps aos caminhos de ativos estáticos como um "cache buster". Isso ajuda a garantir que cópias obsoletas de coisas como imagens e folhas de estilo não sejam servidas do cache do navegador do usuário quando você as altera no servidor. Agora você pode modificar esse comportamento com a opção de configuração `cache_asset_timestamps` para o Action View. Se você habilitar o cache, o Rails calculará o timestamp apenas uma vez quando ele servir o ativo pela primeira vez e salvará esse valor. Isso significa menos chamadas (caras) ao sistema de arquivos para servir ativos estáticos - mas também significa que você não pode modificar nenhum dos ativos enquanto o servidor estiver em execução e esperar que as alterações sejam capturadas pelos clientes.
### Asset Hosts como Objetos

Os hosts de ativos se tornam mais flexíveis no edge Rails com a capacidade de declarar um host de ativos como um objeto específico que responde a uma chamada. Isso permite que você implemente qualquer lógica complexa que você precise em seu host de ativos.

* Mais informações: [asset-hosting-with-minimum-ssl](https://github.com/dhh/asset-hosting-with-minimum-ssl/tree/master)

### Método Auxiliar grouped_options_for_select

O Action View já tinha um monte de auxiliares para ajudar na geração de controles de seleção, mas agora há mais um: `grouped_options_for_select`. Este aceita um array ou hash de strings e os converte em uma string de tags `option` envolvidas com tags `optgroup`. Por exemplo:

```ruby
grouped_options_for_select([["Hats", ["Baseball Cap","Cowboy Hat"]]],
  "Cowboy Hat", "Escolha um produto...")
```

retorna

```html
<option value="">Escolha um produto...</option>
<optgroup label="Hats">
  <option value="Baseball Cap">Baseball Cap</option>
  <option selected="selected" value="Cowboy Hat">Cowboy Hat</option>
</optgroup>
```

### Tags de Opção Desabilitadas para Auxiliares de Seleção de Formulário

Os auxiliares de seleção de formulário (como `select` e `options_for_select`) agora suportam uma opção `:disabled`, que pode receber um único valor ou um array de valores para serem desabilitados nas tags resultantes:

```ruby
select(:post, :category, Post::CATEGORIES, :disabled => 'private')
```

retorna

```html
<select name="post[category]">
<option>story</option>
<option>joke</option>
<option>poem</option>
<option disabled="disabled">private</option>
</select>
```

Você também pode usar uma função anônima para determinar em tempo de execução quais opções das coleções serão selecionadas e/ou desabilitadas:

```ruby
options_from_collection_for_select(@product.sizes, :name, :id, :disabled => lambda{|size| size.out_of_stock?})
```

* Contribuidor Principal: [Tekin Suleyman](http://tekin.co.uk/)
* Mais informações: [Novo no rails 2.3 - tags de opção desabilitadas e lambdas para selecionar e desabilitar opções de coleções](https://tekin.co.uk/2009/03/new-in-rails-23-disabled-option-tags-and-lambdas-for-selecting-and-disabling-options-from-collections)

### Uma Observação Sobre o Carregamento de Templates

O Rails 2.3 inclui a capacidade de habilitar ou desabilitar templates em cache para qualquer ambiente específico. Templates em cache oferecem um impulso de velocidade porque não verificam a existência de um novo arquivo de template quando são renderizados - mas também significa que você não pode substituir um template "na hora" sem reiniciar o servidor.

Na maioria dos casos, você vai querer que o cache de templates esteja ativado em produção, o que você pode fazer fazendo uma configuração no seu arquivo `production.rb`:

```ruby
config.action_view.cache_template_loading = true
```

Essa linha será gerada por padrão em um novo aplicativo Rails 2.3. Se você fez um upgrade de uma versão mais antiga do Rails, o Rails irá usar o cache de templates por padrão em produção e teste, mas não em desenvolvimento.

### Outras Mudanças no Action View

* A geração de token para proteção CSRF foi simplificada; agora o Rails usa uma string aleatória simples gerada por `ActiveSupport::SecureRandom` em vez de mexer com IDs de sessão.
* `auto_link` agora aplica corretamente opções (como `:target` e `:class`) a links de e-mail gerados.
* O auxiliar `autolink` foi refatorado para ficar um pouco menos confuso e mais intuitivo.
* `current_page?` agora funciona corretamente mesmo quando há vários parâmetros de consulta na URL.

Active Support
--------------

Active Support tem algumas mudanças interessantes, incluindo a introdução de `Object#try`.

### Object#try

Muitas pessoas adotaram a ideia de usar try() para tentar operações em objetos. Isso é especialmente útil em views onde você pode evitar a verificação de nulo escrevendo código como `<%= @person.try(:name) %>`. Bem, agora isso está incorporado no Rails. Como implementado no Rails, ele gera `NoMethodError` em métodos privados e sempre retorna `nil` se o objeto for nulo.

* Mais informações: [try()](http://ozmm.org/posts/try.html)

### Backport do Object#tap

`Object#tap` é uma adição ao [Ruby 1.9](http://www.ruby-doc.org/core-1.9/classes/Object.html#M000309) e 1.8.7 que é semelhante ao método `returning` que o Rails já tinha há algum tempo: ele chama um bloco e, em seguida, retorna o objeto que foi chamado. O Rails agora inclui código para tornar isso disponível em versões mais antigas do Ruby também.

### Parsers Substituíveis para XMLmini

O suporte para análise de XML no Active Support foi tornado mais flexível, permitindo que você substitua os parsers. Por padrão, ele usa a implementação padrão REXML, mas você pode facilmente especificar as implementações mais rápidas LibXML ou Nokogiri para suas próprias aplicações, desde que você tenha as gems apropriadas instaladas:

```ruby
XmlMini.backend = 'LibXML'
```

* Contribuidor Principal: [Bart ten Brinke](http://www.movesonrails.com/)
* Contribuidor Principal: [Aaron Patterson](http://tenderlovemaking.com/)

### Segundos fracionários para TimeWithZone

As classes `Time` e `TimeWithZone` incluem um método `xmlschema` para retornar o tempo em uma string amigável ao XML. A partir do Rails 2.3, `TimeWithZone` suporta o mesmo argumento para especificar o número de dígitos na parte de segundos fracionários da string retornada que `Time` faz:

```ruby
Time.zone.now.xmlschema(6) # => "2009-01-16T13:00:06.13653Z"
```
* Contribuidor Principal: [Nicholas Dainty](http://www.workingwithrails.com/person/13536-nicholas-dainty)

### Citação de Chave JSON

Se você consultar a especificação no site "json.org", descobrirá que todas as chaves em uma estrutura JSON devem ser strings e devem ser citadas com aspas duplas. A partir do Rails 2.3, fazemos a coisa certa aqui, mesmo com chaves numéricas.

### Outras Mudanças no Active Support

* Você pode usar `Enumerable#none?` para verificar se nenhum dos elementos corresponde ao bloco fornecido.
* Se você estiver usando [delegados](https://afreshcup.com/home/2008/10/19/coming-in-rails-22-delegate-prefixes) do Active Support, a nova opção `:allow_nil` permite retornar `nil` em vez de lançar uma exceção quando o objeto de destino é nulo.
* `ActiveSupport::OrderedHash`: agora implementa `each_key` e `each_value`.
* `ActiveSupport::MessageEncryptor` fornece uma maneira simples de criptografar informações para armazenamento em um local não confiável (como cookies).
* O `from_xml` do Active Support não depende mais do XmlSimple. Em vez disso, o Rails agora inclui sua própria implementação do XmlMini, com apenas a funcionalidade que ele requer. Isso permite que o Rails dispense a cópia embutida do XmlSimple que ele vem carregando.
* Se você memorizar um método privado, o resultado agora será privado.
* `String#parameterize` aceita um separador opcional: `"Quick Brown Fox".parameterize('_') => "quick_brown_fox"`.
* `number_to_phone` agora aceita números de telefone de 7 dígitos.
* `ActiveSupport::Json.decode` agora lida com sequências de escape no estilo `\u0000`.

Railties
--------

Além das mudanças no Rack mencionadas acima, o Railties (o código principal do próprio Rails) apresenta várias mudanças significativas, incluindo Rails Metal, templates de aplicativos e backtraces silenciosos.

### Rails Metal

Rails Metal é um novo mecanismo que fornece endpoints super rápidos dentro de suas aplicações Rails. As classes Metal ignoram o roteamento e o Action Controller para fornecer velocidade bruta (com o custo de todas as funcionalidades do Action Controller, é claro). Isso se baseia em todo o trabalho recente para tornar o Rails uma aplicação Rack com uma pilha de middlewares exposta. Os endpoints Metal podem ser carregados de sua aplicação ou de plugins.

* Mais informações:
    * [Apresentando o Rails Metal](https://weblog.rubyonrails.org/2008/12/17/introducing-rails-metal)
    * [Rails Metal: um micro-framework com o poder do Rails](http://soylentfoo.jnewland.com/articles/2008/12/16/rails-metal-a-micro-framework-with-the-power-of-rails-m)
    * [Metal: Endpoints super rápidos em suas aplicações Rails](http://www.railsinside.com/deployment/180-metal-super-fast-endpoints-within-your-rails-apps.html)
    * [O que há de novo no Edge Rails: Rails Metal](http://archives.ryandaigle.com/articles/2008/12/18/what-s-new-in-edge-rails-rails-metal)

### Templates de Aplicativos

O Rails 2.3 incorpora o gerador de aplicativos [rg](https://github.com/jm/rg) de Jeremy McAnally. Isso significa que agora temos geração de aplicativos baseada em templates incorporada ao Rails; se você tem um conjunto de plugins que inclui em cada aplicativo (entre muitos outros casos de uso), você pode configurar um template uma vez e usá-lo repetidamente quando executar o comando `rails`. Também há uma tarefa rake para aplicar um template a um aplicativo existente:

```bash
$ rake rails:template LOCATION=~/template.rb
```

Isso aplicará as alterações do template sobre o código que o projeto já contém.

* Contribuidor Principal: [Jeremy McAnally](http://www.jeremymcanally.com/)
* Mais informações: [Templates do Rails](http://m.onkey.org/2008/12/4/rails-templates)

### Backtraces Mais Silenciosos

Baseado no plugin [Quiet Backtrace](https://github.com/thoughtbot/quietbacktrace) da thoughtbot, que permite remover seletivamente linhas de backtraces do `Test::Unit`, o Rails 2.3 implementa `ActiveSupport::BacktraceCleaner` e `Rails::BacktraceCleaner` no núcleo. Isso suporta tanto filtros (para realizar substituições baseadas em regex nas linhas do backtrace) quanto silenciadores (para remover completamente as linhas do backtrace). O Rails adiciona automaticamente silenciadores para eliminar o ruído mais comum em um novo aplicativo e cria um arquivo `config/backtrace_silencers.rb` para suas próprias adições. Essa funcionalidade também permite uma impressão mais bonita de qualquer gem no backtrace.

### Tempo de Inicialização Mais Rápido no Modo de Desenvolvimento com Carregamento Preguiçoso/Autoload

Muito trabalho foi feito para garantir que partes do Rails (e suas dependências) sejam carregadas na memória apenas quando realmente são necessárias. Os frameworks principais - Active Support, Active Record, Action Controller, Action Mailer e Action View - agora usam `autoload` para carregar preguiçosamente suas classes individuais. Esse trabalho deve ajudar a manter a pegada de memória baixa e melhorar o desempenho geral do Rails.

Você também pode especificar (usando a nova opção `preload_frameworks`) se as bibliotecas principais devem ser carregadas na inicialização. Isso é definido como `false` para que o Rails carregue a si mesmo aos poucos, mas há algumas circunstâncias em que você ainda precisa trazer tudo de uma vez - o Passenger e o JRuby querem ver todo o Rails carregado juntos.

### Reescrita da Tarefa rake gem

Os mecanismos internos das várias tarefas <code>rake gem</code> foram substancialmente revisados para melhorar o funcionamento do sistema em uma variedade de casos. O sistema de gem agora sabe a diferença entre dependências de desenvolvimento e em tempo de execução, possui um sistema de descompactação mais robusto, fornece melhores informações ao consultar o status das gems e é menos propenso a problemas de dependência "ovo e galinha" ao iniciar do zero. Também há correções para o uso de comandos gem no JRuby e para dependências que tentam trazer cópias externas de gems que já estão vendidas.
* Contribuidor Principal: [David Dollar](http://www.workingwithrails.com/person/12240-david-dollar)

### Outras Mudanças no Railties

* As instruções para atualizar um servidor CI para construir o Rails foram atualizadas e expandidas.
* Os testes internos do Rails foram alterados de `Test::Unit::TestCase` para `ActiveSupport::TestCase`, e o Rails core requer Mocha para testar.
* O arquivo `environment.rb` padrão foi simplificado.
* O script dbconsole agora permite que você use uma senha totalmente numérica sem travar.
* `Rails.root` agora retorna um objeto `Pathname`, o que significa que você pode usá-lo diretamente com o método `join` para [limpar o código existente](https://afreshcup.wordpress.com/2008/12/05/a-little-rails_root-tidiness/) que usa `File.join`.
* Vários arquivos em /public que lidam com o despacho de CGI e FCGI não são mais gerados em cada aplicativo Rails por padrão (você ainda pode obtê-los se precisar adicionando `--with-dispatchers` quando executar o comando `rails`, ou adicioná-los posteriormente com `rake rails:update:generate_dispatchers`).
* Os Rails Guides foram convertidos de AsciiDoc para a marcação Textile.
* As visualizações e controladores gerados pelo scaffold foram aprimorados um pouco.
* O `script/server` agora aceita um argumento `--path` para montar uma aplicação Rails a partir de um caminho específico.
* Se algum gem configurado estiver faltando, as tarefas rake do gem pularão o carregamento de grande parte do ambiente. Isso deve resolver muitos dos problemas de "ovo e galinha" em que o rake gems:install não podia ser executado porque faltavam gems.
* Os gems agora são descompactados apenas uma vez. Isso corrige problemas com gems (como hoe, por exemplo) que são empacotadas com permissões somente leitura nos arquivos.

Depreciado
----------

Algumas partes do código antigo estão obsoletas nesta versão:

* Se você é um dos (bastante raros) desenvolvedores Rails que fazem implantações que dependem dos scripts inspector, reaper e spawner, você precisa saber que esses scripts não estão mais incluídos no core do Rails. Se você precisar deles, poderá obtê-los através do plugin [irs_process_scripts](https://github.com/rails/irs_process_scripts).
* `render_component` passa de "obsoleto" para "inexistente" no Rails 2.3. Se você ainda precisar dele, poderá instalar o plugin [render_component](https://github.com/rails/render_component/tree/master).
* O suporte a componentes Rails foi removido.
* Se você era uma das pessoas que se acostumou a executar `script/performance/request` para analisar o desempenho com base em testes de integração, você precisa aprender um novo truque: esse script foi removido do core do Rails agora. Há um novo plugin request_profiler que você pode instalar para obter exatamente a mesma funcionalidade de volta.
* `ActionController::Base#session_enabled?` está obsoleto porque as sessões são carregadas sob demanda agora.
* As opções `:digest` e `:secret` para `protect_from_forgery` estão obsoletas e não têm efeito.
* Alguns ajudantes de teste de integração foram removidos. `response.headers["Status"]` e `headers["Status"]` não retornarão mais nada. O Rack não permite "Status" em seus cabeçalhos de retorno. No entanto, você ainda pode usar os ajudantes `status` e `status_message`. `response.headers["cookie"]` e `headers["cookie"]` não retornarão mais nenhum cookie CGI. Você pode inspecionar `headers["Set-Cookie"]` para ver o cabeçalho de cookie bruto ou usar o ajudante `cookies` para obter um hash dos cookies enviados ao cliente.
* `formatted_polymorphic_url` está obsoleto. Use `polymorphic_url` com `:format` em seu lugar.
* A opção `:http_only` em `ActionController::Response#set_cookie` foi renomeada para `:httponly`.
* As opções `:connector` e `:skip_last_comma` de `to_sentence` foram substituídas pelas opções `:words_connector`, `:two_words_connector` e `:last_word_connector`.
* Enviar um formulário multipart com um controle `file_field` vazio costumava enviar uma string vazia para o controlador. Agora ele envia um nulo, devido às diferenças entre o analisador multipart do Rack e o antigo analisador do Rails.

Créditos
-------

Notas de lançamento compiladas por [Mike Gunderloy](http://afreshcup.com). Esta versão das notas de lançamento do Rails 2.3 foi compilada com base no RC2 do Rails 2.3.
