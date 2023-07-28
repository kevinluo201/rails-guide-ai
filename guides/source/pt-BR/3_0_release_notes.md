**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: dd2584972aa8eae419ed5d55a287e27d
Notas de lançamento do Ruby on Rails 3.0
=========================================

Rails 3.0 é pôneis e arco-íris! Vai cozinhar para você e dobrar sua roupa. Você vai se perguntar como a vida era possível antes de sua chegada. É a Melhor Versão do Rails que já fizemos!

Mas falando sério agora, é realmente bom. Tem todas as boas ideias trazidas quando a equipe do Merb se juntou à festa e trouxe um foco na agnosticismo de frameworks, internos mais enxutos e rápidos, e um punhado de APIs saborosas. Se você está vindo para o Rails 3.0 do Merb 1.x, você deve reconhecer muitas coisas. Se você está vindo do Rails 2.x, você também vai adorar.

Mesmo que você não se importe com nossas melhorias internas, o Rails 3.0 vai te encantar. Temos um monte de novos recursos e APIs melhoradas. Nunca foi um momento melhor para ser um desenvolvedor Rails. Alguns dos destaques são:

* Novo roteador com ênfase em declarações RESTful
* Nova API do Action Mailer modelada após o Action Controller (agora sem a dor agonizante de enviar mensagens multipartes!)
* Nova linguagem de consulta encadeável do Active Record construída em cima da álgebra relacional
* Helpers de JavaScript não intrusivos com drivers para Prototype, jQuery e mais (fim do JS inline)
* Gerenciamento explícito de dependências com o Bundler

Além de tudo isso, tentamos ao máximo depreciar as APIs antigas com avisos claros. Isso significa que você pode migrar sua aplicação existente para o Rails 3 sem precisar reescrever imediatamente todo o seu código antigo para as melhores práticas mais recentes.

Essas notas de lançamento cobrem as principais atualizações, mas não incluem todas as pequenas correções de bugs e mudanças. O Rails 3.0 consiste em quase 4.000 commits de mais de 250 autores! Se você quiser ver tudo, confira a [lista de commits](https://github.com/rails/rails/commits/3-0-stable) no repositório principal do Rails no GitHub.

--------------------------------------------------------------------------------

Para instalar o Rails 3:

```bash
# Use sudo se necessário para a sua configuração
$ gem install rails
```


Atualizando para o Rails 3
--------------------------

Se você está atualizando uma aplicação existente, é uma ótima ideia ter uma boa cobertura de testes antes de começar. Você também deve primeiro atualizar para o Rails 2.3.5 e garantir que sua aplicação ainda funcione conforme o esperado antes de tentar atualizar para o Rails 3. Em seguida, observe as seguintes mudanças:

### Rails 3 requer pelo menos o Ruby 1.8.7

O Rails 3.0 requer o Ruby 1.8.7 ou superior. O suporte para todas as versões anteriores do Ruby foi oficialmente removido e você deve fazer a atualização o mais cedo possível. O Rails 3.0 também é compatível com o Ruby 1.9.2.

DICA: Note que as versões p248 e p249 do Ruby 1.8.7 têm bugs de marshalling que fazem o Rails 3.0 travar. O Ruby Enterprise Edition corrigiu esses bugs desde a versão 1.8.7-2010.02. No front do Ruby 1.9, o Ruby 1.9.1 não é utilizável porque ele simplesmente causa um segfault no Rails 3.0, então se você quiser usar o Rails 3 com o 1.9.x, use o 1.9.2 para uma experiência tranquila.

### Objeto de Aplicação do Rails

Como parte do trabalho para suportar a execução de várias aplicações Rails no mesmo processo, o Rails 3 introduz o conceito de um objeto de Aplicação. Um objeto de aplicação contém todas as configurações específicas da aplicação e é muito semelhante em natureza ao `config/environment.rb` das versões anteriores do Rails.

Agora, cada aplicação Rails deve ter um objeto de aplicação correspondente. O objeto de aplicação é definido em `config/application.rb`. Se você está atualizando uma aplicação existente para o Rails 3, você deve adicionar este arquivo e mover as configurações apropriadas de `config/environment.rb` para `config/application.rb`.

### script/* substituído por script/rails

O novo `script/rails` substitui todos os scripts que costumavam estar no diretório `script`. No entanto, você não executa `script/rails` diretamente, o comando `rails` detecta que está sendo invocado na raiz de uma aplicação Rails e executa o script para você. O uso pretendido é:

```bash
$ rails console                      # em vez de script/console
$ rails g scaffold post title:string # em vez de script/generate scaffold post title:string
```

Execute `rails --help` para obter uma lista de todas as opções.

### Dependências e config.gem

O método `config.gem` foi removido e substituído pelo uso do `bundler` e de um `Gemfile`, veja [Vendendo Gems](#vendoring-gems) abaixo.

### Processo de Atualização

Para ajudar no processo de atualização, um plugin chamado [Rails Upgrade](https://github.com/rails/rails_upgrade) foi criado para automatizar parte dele.

Basta instalar o plugin e, em seguida, executar `rake rails:upgrade:check` para verificar sua aplicação em busca de partes que precisam ser atualizadas (com links para informações sobre como atualizá-las). Ele também oferece uma tarefa para gerar um `Gemfile` com base nas suas chamadas atuais de `config.gem` e uma tarefa para gerar um novo arquivo de rotas a partir do seu atual. Para obter o plugin, basta executar o seguinte:
```bash
$ ruby script/plugin install git://github.com/rails/rails_upgrade.git
```

Você pode ver um exemplo de como isso funciona em [Rails Upgrade is now an Official Plugin](http://omgbloglol.com/post/364624593/rails-upgrade-is-now-an-official-plugin)

Além da ferramenta Rails Upgrade, se você precisar de mais ajuda, existem pessoas no IRC e [rubyonrails-talk](https://discuss.rubyonrails.org/c/rubyonrails-talk) que provavelmente estão fazendo a mesma coisa, possivelmente enfrentando os mesmos problemas. Certifique-se de compartilhar suas próprias experiências ao fazer o upgrade para que outros possam se beneficiar do seu conhecimento!

Criando uma aplicação Rails 3.0
------------------------------

```bash
# Você deve ter o RubyGem 'rails' instalado
$ rails new myapp
$ cd myapp
```

### Vendendo Gems

O Rails agora usa um `Gemfile` na raiz da aplicação para determinar as gems que você precisa para iniciar sua aplicação. Este `Gemfile` é processado pelo [Bundler](https://github.com/bundler/bundler), que então instala todas as suas dependências. Ele também pode instalar todas as dependências localmente em sua aplicação para que ela não dependa das gems do sistema.

Mais informações: - [Página inicial do bundler](https://bundler.io/)

### Vivendo no Limite

O `Bundler` e o `Gemfile` tornam fácil congelar sua aplicação Rails com o novo comando `bundle`, então o `rake freeze` não é mais relevante e foi removido.

Se você quiser agrupar diretamente do repositório Git, pode passar a flag `--edge`:

```bash
$ rails new myapp --edge
```

Se você tiver um checkout local do repositório Rails e quiser gerar uma aplicação usando-o, pode passar a flag `--dev`:

```bash
$ ruby /caminho/para/rails/bin/rails new myapp --dev
```

Mudanças Arquiteturais no Rails
------------------------------

Existem seis mudanças principais na arquitetura do Rails.

### Railties Restrung

O Railties foi atualizado para fornecer uma API de plugin consistente para todo o framework Rails, bem como uma reescrita total dos geradores e das ligações do Rails. O resultado é que os desenvolvedores agora podem se conectar a qualquer estágio significativo dos geradores e do framework da aplicação de maneira consistente e definida.

### Todos os componentes principais do Rails estão desacoplados

Com a fusão do Merb e do Rails, uma das grandes tarefas foi remover o acoplamento rígido entre os componentes principais do Rails. Isso agora foi alcançado, e todos os componentes principais do Rails agora estão usando a mesma API que você pode usar para desenvolver plugins. Isso significa que qualquer plugin que você faça, ou qualquer substituição de componente principal (como DataMapper ou Sequel), pode acessar todas as funcionalidades que os componentes principais do Rails têm acesso e estender e aprimorar à vontade.

Mais informações: - [The Great Decoupling](http://yehudakatz.com/2009/07/19/rails-3-the-great-decoupling/)


### Abstração do Active Model

Parte do desacoplamento dos componentes principais foi extrair todas as dependências do Active Record do Action Pack. Isso agora foi concluído. Todos os novos plugins ORM agora só precisam implementar as interfaces do Active Model para funcionar perfeitamente com o Action Pack.

Mais informações: - [Make Any Ruby Object Feel Like ActiveRecord](http://yehudakatz.com/2010/01/10/activemodel-make-any-ruby-object-feel-like-activerecord/)


### Abstração do Controller

Outra grande parte do desacoplamento dos componentes principais foi criar uma superclasse base separada das noções de HTTP para lidar com a renderização de views, etc. Essa criação do `AbstractController` permitiu que `ActionController` e `ActionMailer` fossem muito simplificados, com código comum removido de todas essas bibliotecas e colocado no Abstract Controller.

Mais informações: - [Rails Edge Architecture](http://yehudakatz.com/2009/06/11/rails-edge-architecture/)


### Integração do Arel

O [Arel](https://github.com/brynary/arel) (ou Active Relation) foi adotado como base do Active Record e agora é necessário para o Rails. O Arel fornece uma abstração SQL que simplifica o Active Record e fornece a base para a funcionalidade de relação no Active Record.

Mais informações: - [Why I wrote Arel](https://web.archive.org/web/20120718093140/http://magicscalingsprinkles.wordpress.com/2010/01/28/why-i-wrote-arel/)


### Extração do Mail

O Action Mailer, desde o início, teve patches, pré-parsers e até agentes de entrega e recebimento, além de ter o TMail vendido no repositório de origem. A versão 3 muda isso, com toda a funcionalidade relacionada a mensagens de e-mail abstraída para a gem [Mail](https://github.com/mikel/mail). Isso reduz novamente a duplicação de código e ajuda a criar limites definidos entre o Action Mailer e o analisador de e-mail.

Mais informações: - [New Action Mailer API in Rails 3](http://lindsaar.net/2010/1/26/new-actionmailer-api-in-rails-3)


Documentação
------------

A documentação na árvore do Rails está sendo atualizada com todas as mudanças na API, além disso, os [Rails Edge Guides](https://edgeguides.rubyonrails.org/) estão sendo atualizados um por um para refletir as mudanças no Rails 3.0. Os guias em [guides.rubyonrails.org](https://guides.rubyonrails.org/), no entanto, continuarão a conter apenas a versão estável do Rails (atualmente, a versão 2.3.5, até que a versão 3.0 seja lançada).

Mais informações: - [Projetos de Documentação do Rails](https://weblog.rubyonrails.org/2009/1/15/rails-documentation-projects)
Internacionalização
--------------------

Muito trabalho foi feito com o suporte a I18n no Rails 3, incluindo a última versão do [I18n](https://github.com/svenfuchs/i18n) gem que fornece muitas melhorias de velocidade.

* I18n para qualquer objeto - O comportamento do I18n pode ser adicionado a qualquer objeto incluindo `ActiveModel::Translation` e `ActiveModel::Validations`. Também há um fallback `errors.messages` para traduções.
* Atributos podem ter traduções padrão.
* As tags de envio de formulário automaticamente puxam o status correto (Criar ou Atualizar) dependendo do status do objeto, e assim puxam a tradução correta.
* Labels com I18n agora funcionam apenas passando o nome do atributo.

Mais informações: - [Mudanças no I18n do Rails 3](http://blog.plataformatec.com.br/2010/02/rails-3-i18n-changes/)


Railties
--------

Com a desvinculação dos principais frameworks do Rails, o Railties passou por uma grande reformulação para tornar a conexão de frameworks, engines ou plugins o mais fácil e extensível possível:

* Cada aplicativo agora tem seu próprio espaço de nomes, a aplicação é iniciada com `YourAppName.boot`, por exemplo, tornando a interação com outros aplicativos muito mais fácil.
* Qualquer coisa em `Rails.root/app` agora é adicionada ao caminho de carregamento, então você pode criar `app/observers/user_observer.rb` e o Rails irá carregá-lo sem nenhuma modificação.
* O Rails 3.0 agora fornece um objeto `Rails.config`, que oferece um repositório central de todos os tipos de opções de configuração do Rails.

A geração de aplicativos recebeu flags extras que permitem pular a instalação do test-unit, Active Record, Prototype e Git. Também foi adicionada uma nova flag `--dev` que configura o aplicativo com o `Gemfile` apontando para o seu checkout do Rails (que é determinado pelo caminho para o binário `rails`). Veja `rails --help` para mais informações.

Os geradores do Railties receberam muita atenção no Rails 3.0, basicamente:

* Os geradores foram completamente reescritos e não são compatíveis com versões anteriores.
* A API de templates do Rails e a API de geradores foram mescladas (elas são as mesmas que as anteriores).
* Os geradores não são mais carregados de caminhos especiais, eles são apenas encontrados no caminho de carregamento do Ruby, então chamar `rails generate foo` irá procurar por `generators/foo_generator`.
* Novos geradores fornecem hooks, então qualquer mecanismo de template, ORM, framework de teste pode facilmente se conectar.
* Novos geradores permitem que você substitua os templates colocando uma cópia em `Rails.root/lib/templates`.
* `Rails::Generators::TestCase` também é fornecido para que você possa criar seus próprios geradores e testá-los.

Além disso, as views geradas pelos geradores do Railties passaram por algumas mudanças:

* As views agora usam tags `div` em vez de tags `p`.
* Os scaffolds gerados agora usam partials `_form`, em vez de código duplicado nas views de edição e nova.
* Os formulários do scaffold agora usam `f.submit`, que retorna "Criar NomeDoModelo" ou "Atualizar NomeDoModelo" dependendo do estado do objeto passado.

Finalmente, algumas melhorias foram adicionadas às tarefas do rake:

* Foi adicionado o `rake db:forward`, permitindo que você avance suas migrações individualmente ou em grupos.
* Foi adicionado o `rake routes CONTROLLER=x`, permitindo que você visualize apenas as rotas de um controlador.

O Railties agora deprecia:

* `RAILS_ROOT` em favor de `Rails.root`,
* `RAILS_ENV` em favor de `Rails.env`, e
* `RAILS_DEFAULT_LOGGER` em favor de `Rails.logger`.

`PLUGIN/rails/tasks` e `PLUGIN/tasks` não são mais carregados, todas as tarefas agora devem estar em `PLUGIN/lib/tasks`.

Mais informações:

* [Descobrindo os geradores do Rails 3](http://blog.plataformatec.com.br/2010/01/discovering-rails-3-generators)
* [O Módulo Rails (no Rails 3)](http://quaran.to/blog/2010/02/03/the-rails-module/)

Action Pack
-----------

Houve mudanças significativas internas e externas no Action Pack.


### Controlador Abstrato

O Controlador Abstrato extrai as partes genéricas do Action Controller em um módulo reutilizável que qualquer biblioteca pode usar para renderizar templates, renderizar partials, helpers, traduções, logging, qualquer parte do ciclo de resposta da requisição. Essa abstração permitiu que o `ActionMailer::Base` agora apenas herde do `AbstractController` e envolva a DSL do Rails no gem Mail.

Também proporcionou uma oportunidade para limpar o Action Controller, abstraindo o que poderia simplificar o código.

No entanto, observe que o Controlador Abstrato não é uma API voltada para o usuário, você não irá encontrá-lo em seu uso diário do Rails.

Mais informações: - [Arquitetura do Rails Edge](http://yehudakatz.com/2009/06/11/rails-edge-architecture/)


### Action Controller

* `application_controller.rb` agora tem `protect_from_forgery` ativado por padrão.
* O `cookie_verifier_secret` foi depreciado e agora é atribuído através de `Rails.application.config.cookie_secret` e movido para seu próprio arquivo: `config/initializers/cookie_verification_secret.rb`.
* O `session_store` era configurado em `ActionController::Base.session`, e agora foi movido para `Rails.application.config.session_store`. As configurações padrão são definidas em `config/initializers/session_store.rb`.
* `cookies.secure` permite que você defina valores criptografados nos cookies com `cookie.secure[:key] => value`.
* `cookies.permanent` permite que você defina valores permanentes no hash de cookies `cookie.permanent[:key] => value` que levantam exceções em valores assinados se houver falhas de verificação.
* Agora você pode passar `:notice => 'Esta é uma mensagem flash'` ou `:alert => 'Algo deu errado'` para a chamada `format` dentro de um bloco `respond_to`. O hash `flash[]` ainda funciona como antes.
* O método `respond_with` agora foi adicionado aos seus controladores, simplificando os veneráveis blocos `format`.
* Foi adicionado o `ActionController::Responder`, permitindo flexibilidade na geração de suas respostas.
Depreciações:

* `filter_parameter_logging` está depreciado em favor de `config.filter_parameters << :password`.

Mais informações:

* [Opções de Renderização no Rails 3](https://blog.engineyard.com/2010/render-options-in-rails-3)
* [Três motivos para amar ActionController::Responder](https://weblog.rubyonrails.org/2009/8/31/three-reasons-love-responder)


### Action Dispatch

Action Dispatch é novo no Rails 3.0 e fornece uma nova implementação mais limpa para roteamento.

* Grande limpeza e reescrita do roteador, o roteador do Rails agora é `rack_mount` com uma DSL do Rails por cima, é um software independente.
* As rotas definidas por cada aplicação agora estão dentro do namespace do módulo da sua aplicação, ou seja:

    ```ruby
    # Em vez de:

    ActionController::Routing::Routes.draw do |map|
      map.resources :posts
    end

    # Você faz:

    AppName::Application.routes do
      resources :posts
    end
    ```

* Adicionado o método `match` ao roteador, você também pode passar qualquer aplicação Rack para a rota correspondente.
* Adicionado o método `constraints` ao roteador, permitindo que você proteja rotas com restrições definidas.
* Adicionado o método `scope` ao roteador, permitindo que você crie namespaces para rotas em diferentes idiomas ou ações diferentes, por exemplo:

    ```ruby
    scope 'es' do
      resources :projects, :path_names => { :edit => 'cambiar' }, :path => 'proyecto'
    end

    # Isso te dá a ação de edição com /es/proyecto/1/cambiar
    ```

* Adicionado o método `root` ao roteador como um atalho para `match '/', :to => path`.
* Você pode passar segmentos opcionais para o match, por exemplo `match "/:controller(/:action(/:id))(.:format)"`, cada segmento entre parênteses é opcional.
* Rotas podem ser expressas através de blocos, por exemplo você pode chamar `controller :home { match '/:action' }`.

NOTA. Os comandos no estilo antigo `map` ainda funcionam como antes com uma camada de compatibilidade reversa, no entanto isso será removido na versão 3.1.

Depreciações

* A rota de captura para aplicações não-REST (`/:controller/:action/:id`) agora está comentada.
* A opção `:path_prefix` não existe mais e `:name_prefix` agora adiciona automaticamente "_" no final do valor fornecido.

Mais informações:
* [O Roteador do Rails 3: Rack it Up](http://yehudakatz.com/2009/12/26/the-rails-3-router-rack-it-up/)
* [Rotas Renovadas no Rails 3](https://medium.com/fusion-of-thoughts/revamped-routes-in-rails-3-b6d00654e5b0)
* [Ações Genéricas no Rails 3](http://yehudakatz.com/2009/12/20/generic-actions-in-rails-3/)


### Action View

#### JavaScript não intrusivo

Foi feita uma grande reescrita nos helpers do Action View, implementando ganchos de JavaScript não intrusivo (UJS) e removendo os antigos comandos AJAX inline. Isso permite que o Rails use qualquer driver UJS compatível para implementar os ganchos UJS nos helpers.

O que isso significa é que todos os antigos helpers `remote_<method>` foram removidos do núcleo do Rails e colocados no [Prototype Legacy Helper](https://github.com/rails/prototype_legacy_helper). Para adicionar ganchos UJS ao seu HTML, agora você passa `:remote => true`. Por exemplo:

```ruby
form_for @post, :remote => true
```

Produz:

```html
<form action="http://host.com" id="create-post" method="post" data-remote="true">
```

#### Helpers com blocos

Helpers como `form_for` ou `div_for` que inserem conteúdo de um bloco agora usam `<%=`:

```html+erb
<%= form_for @post do |f| %>
  ...
<% end %>
```

Seus próprios helpers desse tipo devem retornar uma string, em vez de anexar ao buffer de saída manualmente.

Helpers que fazem outra coisa, como `cache` ou `content_for`, não são afetados por essa mudança, eles precisam de `&lt;%` como antes.

#### Outras mudanças

* Você não precisa mais chamar `h(string)` para escapar a saída HTML, isso está ativado por padrão em todos os templates de visualização. Se você quiser a string não escapada, chame `raw(string)`.
* Os helpers agora geram HTML5 por padrão.
* O helper de rótulo de formulário agora busca os valores do I18n com um único valor, então `f.label :name` buscará a tradução `:name`.
* A tradução do rótulo de seleção do I18n agora deve ser :en.helpers.select em vez de :en.support.select.
* Você não precisa mais colocar um sinal de menos no final de uma interpolação Ruby dentro de um template ERB para remover a quebra de linha no final na saída HTML.
* Adicionado o helper `grouped_collection_select` ao Action View.
* Foi adicionado o `content_for?`, permitindo que você verifique a existência de conteúdo em uma visualização antes de renderizar.
* passar `:value => nil` para os helpers de formulário definirá o atributo `value` do campo como nulo, em vez de usar o valor padrão
* passar `:id => nil` para os helpers de formulário fará com que esses campos sejam renderizados sem o atributo `id`
* passar `:alt => nil` para `image_tag` fará com que a tag `img` seja renderizada sem o atributo `alt`

Active Model
------------

Active Model é novo no Rails 3.0. Ele fornece uma camada de abstração para qualquer biblioteca ORM interagir com o Rails, implementando uma interface Active Model.
### Abstração ORM e Interface Action Pack

Parte da desacoplagem dos componentes principais foi extrair todas as dependências do Active Record do Action Pack. Isso agora foi concluído. Todos os novos plugins ORM agora só precisam implementar as interfaces do Active Model para funcionar perfeitamente com o Action Pack.

Mais informações: - [Faça qualquer objeto Ruby se sentir como ActiveRecord](http://yehudakatz.com/2010/01/10/activemodel-make-any-ruby-object-feel-like-activerecord/)


### Validações

As validações foram movidas do Active Record para o Active Model, fornecendo uma interface para validações que funciona em bibliotecas ORM diferentes no Rails 3.

* Agora há um método de atalho `validates :atributo, options_hash` que permite passar opções para todos os métodos de validação da classe, você pode passar mais de uma opção para um método de validação.
* O método `validates` tem as seguintes opções:
    * `:acceptance => Boolean`.
    * `:confirmation => Boolean`.
    * `:exclusion => { :in => Enumerable }`.
    * `:inclusion => { :in => Enumerable }`.
    * `:format => { :with => Regexp, :on => :create }`.
    * `:length => { :maximum => Fixnum }`.
    * `:numericality => Boolean`.
    * `:presence => Boolean`.
    * `:uniqueness => Boolean`.

NOTA: Todos os métodos de validação no estilo da versão 2.3 do Rails ainda são suportados no Rails 3.0, o novo método validates é projetado como uma ajuda adicional nas validações do seu modelo, não uma substituição para a API existente.

Você também pode passar um objeto validador, que você pode reutilizar entre objetos que usam o Active Model:

```ruby
class TitleValidator < ActiveModel::EachValidator
  Titles = ['Sr.', 'Sra.', 'Dr.']
  def validate_each(record, attribute, value)
    unless Titles.include?(value)
      record.errors[attribute] << 'deve ser um título válido'
    end
  end
end
```

```ruby
class Person
  include ActiveModel::Validations
  attr_accessor :title
  validates :title, :presence => true, :title => true
end

# Ou para o Active Record

class Person < ActiveRecord::Base
  validates :title, :presence => true, :title => true
end
```

Também há suporte para introspecção:

```ruby
User.validators
User.validators_on(:login)
```

Mais informações:

* [Validação sexy no Rails 3](http://thelucid.com/2010/01/08/sexy-validation-in-edge-rails-rails-3/)
* [Explicação das validações no Rails 3](http://lindsaar.net/2010/1/31/validates_rails_3_awesome_is_true)


Active Record
-------------

O Active Record recebeu muita atenção no Rails 3.0, incluindo a abstração para o Active Model, uma atualização completa da interface de consulta usando o Arel, atualizações de validação e muitas melhorias e correções. Toda a API do Rails 2.x será utilizável através de uma camada de compatibilidade que será suportada até a versão 3.1.


### Interface de Consulta

O Active Record, através do uso do Arel, agora retorna relações em seus métodos principais. A API existente no Rails 2.3.x ainda é suportada e não será depreciada até o Rails 3.1 e não será removida até o Rails 3.2, no entanto, a nova API fornece os seguintes novos métodos que retornam relações permitindo que sejam encadeados:

* `where` - fornece condições na relação, o que é retornado.
* `select` - escolhe quais atributos dos modelos você deseja que sejam retornados do banco de dados.
* `group` - agrupa a relação no atributo fornecido.
* `having` - fornece uma expressão limitando as relações de grupo (restrição GROUP BY).
* `joins` - une a relação a outra tabela.
* `clause` - fornece uma expressão limitando as relações de junção (restrição JOIN).
* `includes` - inclui outras relações pré-carregadas.
* `order` - ordena a relação com base na expressão fornecida.
* `limit` - limita a relação ao número de registros especificado.
* `lock` - bloqueia os registros retornados da tabela.
* `readonly` - retorna uma cópia somente leitura dos dados.
* `from` - fornece uma maneira de selecionar relacionamentos de mais de uma tabela.
* `scope` - (anteriormente `named_scope`) retorna relações e pode ser encadeado com os outros métodos de relação.
* `with_scope` - e `with_exclusive_scope` agora também retornam relações e podem ser encadeados.
* `default_scope` - também funciona com relações.

Mais informações:

* [Interface de Consulta do Active Record](http://m.onkey.org/2010/1/22/active-record-query-interface)
* [Deixe seu SQL rugir no Rails 3](http://hasmanyquestions.wordpress.com/2010/01/17/let-your-sql-growl-in-rails-3/)


### Melhorias

* Adicionado `:destroyed?` aos objetos do Active Record.
* Adicionado `:inverse_of` às associações do Active Record, permitindo que você obtenha a instância de uma associação já carregada sem acessar o banco de dados.


### Correções e Depreciações

Além disso, muitas correções foram feitas no ramo do Active Record:

* O suporte ao SQLite 2 foi abandonado em favor do SQLite 3.
* Suporte MySQL para ordem de colunas.
* O adaptador do PostgreSQL teve seu suporte `TIME ZONE` corrigido para não inserir valores incorretos.
* Suporte a esquemas múltiplos em nomes de tabelas para o PostgreSQL.
* Suporte do PostgreSQL para coluna do tipo de dados XML.
* `table_name` agora é armazenado em cache.
* Um grande trabalho também foi feito no adaptador do Oracle, com muitas correções de bugs.
Além das seguintes depreciações:

* `named_scope` em uma classe Active Record está obsoleto e foi renomeado para apenas `scope`.
* Nos métodos `scope`, você deve passar a usar os métodos de relação, em vez de um método de busca `:conditions => {}`, por exemplo, `scope :since, lambda {|time| where("created_at > ?", time) }`.
* `save(false)` está obsoleto, em favor de `save(:validate => false)`.
* As mensagens de erro I18n para Active Record devem ser alteradas de :en.activerecord.errors.template para `:en.errors.template`.
* `model.errors.on` está obsoleto, em favor de `model.errors[]`
* validates_presence_of => validates... :presence => true
* `ActiveRecord::Base.colorize_logging` e `config.active_record.colorize_logging` estão obsoletos, em favor de `Rails::LogSubscriber.colorize_logging` ou `config.colorize_logging`

NOTA: Embora uma implementação de State Machine tenha sido adicionada ao Active Record há alguns meses, ela foi removida do lançamento do Rails 3.0.


Active Resource
---------------

O Active Resource também foi extraído para o Active Model, permitindo que você use objetos Active Resource com o Action Pack de forma transparente.

* Adicionadas validações através do Active Model.
* Adicionados ganchos de observação.
* Suporte a proxy HTTP.
* Adicionado suporte para autenticação digest.
* Movida a nomenclatura do modelo para o Active Model.
* Alterados os atributos do Active Resource para um Hash com acesso indiferente.
* Adicionados os aliases `first`, `last` e `all` para escopos de busca equivalentes.
* `find_every` agora não retorna um erro `ResourceNotFound` se nada for retornado.
* Adicionado `save!` que gera uma exceção `ResourceInvalid` a menos que o objeto seja `valid?`.
* `update_attribute` e `update_attributes` adicionados aos modelos do Active Resource.
* Adicionado `exists?`.
* Renomeada `SchemaDefinition` para `Schema` e `define_schema` para `schema`.
* Usa o formato de recursos ativos (`format`) em vez do tipo de conteúdo remoto (`content-type`) para carregar erros.
* Usa `instance_eval` para o bloco de esquema.
* Corrige `ActiveResource::ConnectionError#to_s` quando `@response` não responde a #code ou #message, lida com a compatibilidade do Ruby 1.9.
* Adiciona suporte para erros no formato JSON.
* Garante que `load` funcione com arrays numéricos.
* Reconhece uma resposta 410 do recurso remoto como o recurso sendo excluído.
* Adiciona capacidade de definir opções SSL em conexões do Active Resource.
* Definir o tempo limite da conexão também afeta o `Net::HTTP` `open_timeout`.

Depreciações:

* `save(false)` está obsoleto, em favor de `save(:validate => false)`.
* Ruby 1.9.2: `URI.parse` e `.decode` estão obsoletos e não são mais usados na biblioteca.


Active Support
--------------

Um grande esforço foi feito no Active Support para torná-lo selecionável, ou seja, você não precisa mais requerer toda a biblioteca do Active Support para obter partes dela. Isso permite que os vários componentes principais do Rails sejam executados de forma mais enxuta.

Estas são as principais mudanças no Active Support:

* Grande limpeza da biblioteca, removendo métodos não utilizados em todo o código.
* O Active Support não fornece mais versões vendidas do TZInfo, Memcache Client e Builder. Todos eles são incluídos como dependências e instalados através do comando `bundle install`.
* Buffers seguros são implementados em `ActiveSupport::SafeBuffer`.
* Adicionados `Array.uniq_by` e `Array.uniq_by!`.
* Removido `Array#rand` e adicionado `Array#sample` do Ruby 1.9.
* Corrigido bug em `TimeZone.seconds_to_utc_offset` que retornava um valor incorreto.
* Adicionado middleware `ActiveSupport::Notifications`.
* `ActiveSupport.use_standard_json_time_format` agora tem como padrão true.
* `ActiveSupport.escape_html_entities_in_json` agora tem como padrão false.
* `Integer#multiple_of?` aceita zero como argumento, retorna false a menos que o receptor seja zero.
* `string.chars` foi renomeado para `string.mb_chars`.
* `ActiveSupport::OrderedHash` agora pode ser deserializado através do YAML.
* Adicionado parser baseado em SAX para XmlMini, usando LibXML e Nokogiri.
* Adicionado `Object#presence` que retorna o objeto se ele for `#present?`, caso contrário, retorna `nil`.
* Adicionada extensão central `String#exclude?` que retorna o inverso de `#include?`.
* Adicionado `to_i` para `DateTime` em `ActiveSupport`, para que `to_yaml` funcione corretamente em modelos com atributos `DateTime`.
* Adicionado `Enumerable#exclude?` para trazer paridade com `Enumerable#include?` e evitar `!x.include?`.
* Ativar por padrão a proteção contra XSS no Rails.
* Suporte a mesclagem profunda em `ActiveSupport::HashWithIndifferentAccess`.
* `Enumerable#sum` agora funciona com todos os enumeráveis, mesmo que eles não respondam a `:size`.
* `inspect` em uma duração de comprimento zero retorna '0 segundos' em vez de uma string vazia.
* Adicionados `element` e `collection` a `ModelName`.
* `String#to_time` e `String#to_datetime` lidam com segundos fracionados.
* Adicionado suporte a novos callbacks para objeto de filtro ao redor que responde a `:before` e `:after` usados em callbacks antes e depois.
* O método `ActiveSupport::OrderedHash#to_a` retorna um conjunto ordenado de arrays. Corresponde ao `Hash#to_a` do Ruby 1.9.
* `MissingSourceFile` existe como uma constante, mas agora é igual a `LoadError`.
* Adicionado `Class#class_attribute`, para poder declarar um atributo de nível de classe cujo valor é herdável e pode ser sobrescrito por subclasses.
* Finalmente removido `DeprecatedCallbacks` em `ActiveRecord::Associations`.
* `Object#metaclass` agora é `Kernel#singleton_class` para corresponder ao Ruby.
Os seguintes métodos foram removidos porque agora estão disponíveis no Ruby 1.8.7 e 1.9.

* `Integer#even?` e `Integer#odd?`
* `String#each_char`
* `String#start_with?` e `String#end_with?` (aliases da terceira pessoa ainda foram mantidos)
* `String#bytesize`
* `Object#tap`
* `Symbol#to_proc`
* `Object#instance_variable_defined?`
* `Enumerable#none?`

O patch de segurança para REXML permanece no Active Support porque as primeiras versões do Ruby 1.8.7 ainda precisam dele. O Active Support sabe se deve aplicá-lo ou não.

Os seguintes métodos foram removidos porque não são mais usados no framework:

* `Kernel#daemonize`
* `Object#remove_subclasses_of` `Object#extend_with_included_modules_from`, `Object#extended_by`
* `Class#remove_class`
* `Regexp#number_of_captures`, `Regexp.unoptionalize`, `Regexp.optionalize`, `Regexp#number_of_captures`


Action Mailer
-------------

O Action Mailer recebeu uma nova API com o TMail sendo substituído pelo novo [Mail](https://github.com/mikel/mail) como biblioteca de e-mail. O Action Mailer em si foi completamente reescrito, com praticamente todas as linhas de código sendo modificadas. O resultado é que o Action Mailer agora simplesmente herda do Abstract Controller e envolve a gem Mail em um DSL do Rails. Isso reduz consideravelmente a quantidade de código e duplicação de outras bibliotecas no Action Mailer.

* Todos os mailers agora estão em `app/mailers` por padrão.
* Agora é possível enviar e-mails usando a nova API com três métodos: `attachments`, `headers` e `mail`.
* O Action Mailer agora possui suporte nativo para anexos inline usando o método `attachments.inline`.
* Os métodos de envio de e-mail do Action Mailer agora retornam objetos `Mail::Message`, que podem então enviar a si mesmos a mensagem `deliver`.
* Todos os métodos de envio de e-mail agora estão abstraídos na gem Mail.
* O método de envio de e-mail pode aceitar um hash de todos os campos de cabeçalho de e-mail válidos com seus pares de valor.
* O método de envio `mail` age de maneira semelhante ao `respond_to` do Action Controller, e você pode renderizar templates explicitamente ou implicitamente. O Action Mailer transformará o e-mail em um e-mail multipart, se necessário.
* É possível passar um proc para as chamadas `format.mime_type` dentro do bloco de e-mail e renderizar explicitamente tipos específicos de texto, ou adicionar layouts ou templates diferentes. A chamada `render` dentro do proc é do Abstract Controller e suporta as mesmas opções.
* O que eram testes unitários de mailer foram movidos para testes funcionais.
* O Action Mailer agora delega toda a codificação automática de campos de cabeçalho e corpos para a gem Mail.
* O Action Mailer irá codificar automaticamente os corpos e cabeçalhos de e-mail para você.

Depreciações:

* `:charset`, `:content_type`, `:mime_version`, `:implicit_parts_order` estão todos depreciados em favor das declarações no estilo `ActionMailer.default :key => value`.
* Os métodos dinâmicos `create_method_name` e `deliver_method_name` do Mailer estão depreciados, basta chamar `method_name` que agora retorna um objeto `Mail::Message`.
* `ActionMailer.deliver(message)` está depreciado, basta chamar `message.deliver`.
* `template_root` está depreciado, passe opções para uma chamada de render dentro de um proc do método `format.mime_type` dentro do bloco de geração de `mail`.
* O método `body` para definir variáveis de instância está depreciado (`body {:ivar => value}`), basta declarar as variáveis de instância diretamente no método e elas estarão disponíveis na view.
* O uso de mailers em `app/models` está depreciado, use `app/mailers` em vez disso.

Mais informações:

* [Nova API do Action Mailer no Rails 3](http://lindsaar.net/2010/1/26/new-actionmailer-api-in-rails-3)
* [Nova gem Mail para Ruby](http://lindsaar.net/2010/1/23/mail-gem-version-2-released)


Créditos
-------

Veja a [lista completa de contribuidores para o Rails](https://contributors.rubyonrails.org/) para as muitas pessoas que passaram muitas horas fazendo o Rails 3. Parabéns a todos eles.

As Notas de Lançamento do Rails 3.0 foram compiladas por [Mikel Lindsaar](http://lindsaar.net).
