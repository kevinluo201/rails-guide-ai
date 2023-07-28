**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 29fda46e32914456eb8369ab3f2cb7d6
Ruby on Rails 2.2 Notas de Lançamento
=====================================

O Rails 2.2 oferece várias novas e melhoradas funcionalidades. Esta lista abrange as principais atualizações, mas não inclui todas as pequenas correções de bugs e mudanças. Se você quiser ver tudo, confira a [lista de commits](https://github.com/rails/rails/commits/2-2-stable) no repositório principal do Rails no GitHub.

Junto com o Rails, o 2.2 marca o lançamento dos [Guias do Ruby on Rails](https://guides.rubyonrails.org/), os primeiros resultados do contínuo [hackfest dos Guias do Rails](http://hackfest.rubyonrails.org/guide). Este site fornecerá documentação de alta qualidade sobre as principais funcionalidades do Rails.

--------------------------------------------------------------------------------

Infraestrutura
--------------

O Rails 2.2 é um lançamento significativo para a infraestrutura que mantém o Rails funcionando e conectado ao resto do mundo.

### Internacionalização

O Rails 2.2 fornece um sistema fácil para internacionalização (ou i18n, para aqueles que estão cansados de digitar).

* Principais Contribuidores: Equipe Rails i18
* Mais informações:
    * [Site oficial do Rails i18](http://rails-i18n.org)
    * [Finalmente. Ruby on Rails é internacionalizado](https://web.archive.org/web/20140407075019/http://www.artweb-design.de/2008/7/18/finally-ruby-on-rails-gets-internationalized)
    * [Localizando o Rails: Aplicação de demonstração](https://github.com/clemens/i18n_demo_app)

### Compatibilidade com Ruby 1.9 e JRuby

Além da segurança de threads, muito trabalho foi feito para fazer o Rails funcionar bem com o JRuby e o próximo Ruby 1.9. Com o Ruby 1.9 sendo um alvo em movimento, executar o Rails edge no Ruby edge ainda é uma proposta incerta, mas o Rails está pronto para fazer a transição para o Ruby 1.9 quando este for lançado.

Documentação
------------

A documentação interna do Rails, na forma de comentários de código, foi melhorada em vários lugares. Além disso, o projeto [Guias do Ruby on Rails](https://guides.rubyonrails.org/) é a fonte definitiva de informações sobre os principais componentes do Rails. Em seu primeiro lançamento oficial, a página dos Guias inclui:

* [Começando com o Rails](getting_started.html)
* [Migrações de Banco de Dados do Rails](active_record_migrations.html)
* [Associações do Active Record](association_basics.html)
* [Interface de Consulta do Active Record](active_record_querying.html)
* [Layouts e Renderização no Rails](layouts_and_rendering.html)
* [Assistentes de Formulário do Action View](form_helpers.html)
* [Roteamento do Rails de Fora para Dentro](routing.html)
* [Visão Geral do Action Controller](action_controller_overview.html)
* [Caching no Rails](caching_with_rails.html)
* [Um Guia para Testar Aplicações Rails](testing.html)
* [Segurança em Aplicações Rails](security.html)
* [Depurando Aplicações Rails](debugging_rails_applications.html)
* [Noções Básicas de Criação de Plugins Rails](plugins.html)

No total, os Guias fornecem dezenas de milhares de palavras de orientação para desenvolvedores iniciantes e intermediários do Rails.

Se você quiser gerar esses guias localmente, dentro da sua aplicação:

```bash
$ rake doc:guides
```

Isso colocará os guias dentro de `Rails.root/doc/guides` e você pode começar a navegar imediatamente abrindo `Rails.root/doc/guides/index.html` no seu navegador favorito.

* Principais contribuições de [Xavier Noria](http://advogato.org/person/fxn/diary.html) e [Hongli Lai](http://izumi.plan99.net/blog/).
* Mais informações:
    * [Hackfest dos Guias do Rails](http://hackfest.rubyonrails.org/guide)
    * [Ajude a melhorar a documentação do Rails no branch Git](https://weblog.rubyonrails.org/2008/5/2/help-improve-rails-documentation-on-git-branch)

Melhor integração com HTTP: Suporte ETag out-of-the-box
--------------------------------------------------------

O suporte ao ETag e ao último timestamp modificado nos cabeçalhos HTTP significa que o Rails agora pode enviar uma resposta vazia se receber uma solicitação para um recurso que não foi modificado recentemente. Isso permite verificar se uma resposta precisa ser enviada.

```ruby
class ArticlesController < ApplicationController
  def show_with_respond_to_block
    @article = Article.find(params[:id])

    # Se a solicitação enviar cabeçalhos diferentes das opções fornecidas para o stale?,
    # então a solicitação está desatualizada e o bloco respond_to é acionado (e as opções
    # para a chamada de stale? são definidas na resposta).
    #
    # Se os cabeçalhos da solicitação corresponderem, então a solicitação está atualizada e o bloco respond_to não é acionado.
    # Em vez disso, a renderização padrão ocorrerá, que verificará os cabeçalhos last-modified e etag e concluirá que só precisa enviar um "304 Not Modified" em vez de renderizar o template.
    if stale?(:last_modified => @article.published_at.utc, :etag => @article)
      respond_to do |wants|
        # processamento normal da resposta
      end
    end
  end

  def show_with_implied_render
    @article = Article.find(params[:id])

    # Define os cabeçalhos de resposta e os verifica em relação à solicitação, se a solicitação estiver desatualizada
    # (ou seja, nenhuma correspondência de etag ou last-modified), então a renderização padrão do template ocorre.
    # Se a solicitação estiver atualizada, então a renderização padrão retornará um "304 Not Modified"
    # em vez de renderizar o template.
    fresh_when(:last_modified => @article.published_at.utc, :etag => @article)
  end
end
```

Segurança de Threads
--------------------

O trabalho feito para tornar o Rails seguro para threads está sendo implementado no Rails 2.2. Dependendo da infraestrutura do seu servidor web, isso significa que você pode lidar com mais solicitações com menos cópias do Rails na memória, resultando em melhor desempenho do servidor e maior utilização de múltiplos núcleos.
Para habilitar o despacho com várias threads no modo de produção do seu aplicativo, adicione a seguinte linha no arquivo `config/environments/production.rb`:

```ruby
config.threadsafe!
```

* Mais informações:
    * [Thread safety for your Rails](http://m.onkey.org/2008/10/23/thread-safety-for-your-rails)
    * [Thread safety project announcement](https://weblog.rubyonrails.org/2008/8/16/josh-peek-officially-joins-the-rails-core)
    * [Q/A: What Thread-safe Rails Means](http://blog.headius.com/2008/08/qa-what-thread-safe-rails-means.html)

Active Record
-------------

Existem duas grandes adições para falar aqui: migrações transacionais e transações de banco de dados em pool. Também há uma nova sintaxe (mais limpa) para condições de tabela de junção, além de várias melhorias menores.

### Migrações Transacionais

Historicamente, as migrações de várias etapas do Rails têm sido uma fonte de problemas. Se algo desse errado durante uma migração, tudo antes do erro alterava o banco de dados e tudo depois do erro não era aplicado. Além disso, a versão da migração era armazenada como tendo sido executada, o que significa que não poderia ser simplesmente reexecutada por `rake db:migrate:redo` depois de corrigir o problema. As migrações transacionais mudam isso, envolvendo as etapas da migração em uma transação DDL, para que, se alguma delas falhar, a migração inteira seja desfeita. No Rails 2.2, as migrações transacionais são suportadas no PostgreSQL por padrão. O código é extensível para outros tipos de banco de dados no futuro - e a IBM já o estendeu para suportar o adaptador DB2.

* Contribuidor Principal: [Adam Wiggins](http://about.adamwiggins.com/)
* Mais informações:
    * [DDL Transactions](http://adam.heroku.com/past/2008/9/3/ddl_transactions/)
    * [A major milestone for DB2 on Rails](http://db2onrails.com/2008/11/08/a-major-milestone-for-db2-on-rails/)

### Pool de Conexões

O pool de conexões permite que o Rails distribua solicitações de banco de dados em um pool de conexões de banco de dados que crescerá até um tamanho máximo (por padrão, 5, mas você pode adicionar uma chave `pool` ao seu `database.yml` para ajustar isso). Isso ajuda a remover gargalos em aplicativos que suportam muitos usuários simultâneos. Também há um `wait_timeout` que por padrão é de 5 segundos antes de desistir. `ActiveRecord::Base.connection_pool` dá acesso direto ao pool, se necessário.

```yaml
development:
  adapter: mysql
  username: root
  database: sample_development
  pool: 10
  wait_timeout: 10
```

* Contribuidor Principal: [Nick Sieger](http://blog.nicksieger.com/)
* Mais informações:
    * [What's New in Edge Rails: Connection Pools](http://archives.ryandaigle.com/articles/2008/9/7/what-s-new-in-edge-rails-connection-pools)

### Hashes para Condições de Tabela de Junção

Agora você pode especificar condições em tabelas de junção usando um hash. Isso é de grande ajuda se você precisa fazer consultas em junções complexas.

```ruby
class Photo < ActiveRecord::Base
  belongs_to :product
end

class Product < ActiveRecord::Base
  has_many :photos
end

# Obter todos os produtos com fotos sem direitos autorais:
Product.all(:joins => :photos, :conditions => { :photos => { :copyright => false }})
```

* Mais informações:
    * [What's New in Edge Rails: Easy Join Table Conditions](http://archives.ryandaigle.com/articles/2008/7/7/what-s-new-in-edge-rails-easy-join-table-conditions)

### Novos Localizadores Dinâmicos

Dois novos conjuntos de métodos foram adicionados à família de localizadores dinâmicos do Active Record.

#### `find_last_by_attribute`

O método `find_last_by_attribute` é equivalente a `Model.last(:conditions => {:attribute => value})`

```ruby
# Obter o último usuário que se cadastrou em Londres
User.find_last_by_city('London')
```

* Contribuidor Principal: [Emilio Tagua](http://www.workingwithrails.com/person/9147-emilio-tagua)

#### `find_by_attribute!`

A nova versão com bang! de `find_by_attribute!` é equivalente a `Model.first(:conditions => {:attribute => value}) || raise ActiveRecord::RecordNotFound` Em vez de retornar `nil` se não encontrar um registro correspondente, esse método lançará uma exceção se não encontrar uma correspondência.

```ruby
# Lançar exceção ActiveRecord::RecordNotFound se 'Moby' ainda não se cadastrou!
User.find_by_name!('Moby')
```

* Contribuidor Principal: [Josh Susser](http://blog.hasmanythrough.com)

### Associações Respeitam o Escopo Privado/Protegido

Os proxies de associação do Active Record agora respeitam o escopo dos métodos no objeto proxy. Anteriormente (dado que User tem_one :account) `@user.account.private_method` chamaria o método privado no objeto Account associado. Isso falha no Rails 2.2; se você precisa dessa funcionalidade, deve usar `@user.account.send(:private_method)` (ou tornar o método público em vez de privado ou protegido). Observe que, se você estiver substituindo `method_missing`, também deve substituir `respond_to` para corresponder ao comportamento, para que as associações funcionem normalmente.

* Contribuidor Principal: Adam Milligan
* Mais informações:
    * [Rails 2.2 Change: Private Methods on Association Proxies are Private](http://afreshcup.com/2008/10/24/rails-22-change-private-methods-on-association-proxies-are-private/)

### Outras Mudanças no Active Record

* `rake db:migrate:redo` agora aceita um VERSION opcional para direcionar essa migração específica para refazer
* Defina `config.active_record.timestamped_migrations = false` para ter migrações com prefixo numérico em vez de carimbo de data e hora UTC.
* Colunas de contador de cache (para associações declaradas com `:counter_cache => true`) não precisam mais ser inicializadas com zero.
* `ActiveRecord::Base.human_name` para uma tradução humana consciente de internacionalização dos nomes dos modelos

Action Controller
-----------------

No lado do controlador, há várias alterações que ajudarão a organizar suas rotas. Também há algumas alterações internas no mecanismo de roteamento para reduzir o uso de memória em aplicativos complexos.
### Aninhamento Raso de Rotas

O aninhamento raso de rotas fornece uma solução para a conhecida dificuldade de usar recursos profundamente aninhados. Com o aninhamento raso, você só precisa fornecer informações suficientes para identificar de forma única o recurso com o qual deseja trabalhar.

```ruby
map.resources :publishers, :shallow => true do |publisher|
  publisher.resources :magazines do |magazine|
    magazine.resources :photos
  end
end
```

Isso permitirá o reconhecimento das seguintes rotas (entre outras):

```
/publishers/1           ==> publisher_path(1)
/publishers/1/magazines ==> publisher_magazines_path(1)
/magazines/2            ==> magazine_path(2)
/magazines/2/photos     ==> magazines_photos_path(2)
/photos/3               ==> photo_path(3)
```

* Contribuidor Principal: [S. Brent Faulkner](http://www.unwwwired.net/)
* Mais informações:
    * [Rails Routing from the Outside In](routing.html#nested-resources)
    * [What's New in Edge Rails: Shallow Routes](http://archives.ryandaigle.com/articles/2008/9/7/what-s-new-in-edge-rails-shallow-routes)

### Arrays de Métodos para Rotas de Membros ou Coleções

Agora você pode fornecer um array de métodos para novas rotas de membros ou coleções. Isso remove a inconveniência de ter que definir uma rota como aceitando qualquer verbo assim que você precisa que ela manipule mais de um. Com o Rails 2.2, esta é uma declaração de rota legítima:

```ruby
map.resources :photos, :collection => { :search => [:get, :post] }
```

* Contribuidor Principal: [Brennan Dunn](http://brennandunn.com/)

### Recursos com Ações Específicas

Por padrão, quando você usa `map.resources` para criar uma rota, o Rails gera rotas para sete ações padrão (index, show, create, new, edit, update e destroy). Mas cada uma dessas rotas ocupa memória em sua aplicação e faz com que o Rails gere lógica de roteamento adicional. Agora você pode usar as opções `:only` e `:except` para ajustar as rotas que o Rails irá gerar para recursos. Você pode fornecer uma única ação, um array de ações ou as opções especiais `:all` ou `:none`. Essas opções são herdadas por recursos aninhados.

```ruby
map.resources :photos, :only => [:index, :show]
map.resources :products, :except => :destroy
```

* Contribuidor Principal: [Tom Stuart](http://experthuman.com/)

### Outras Mudanças no Action Controller

* Agora você pode facilmente [mostrar uma página de erro personalizada](http://m.onkey.org/2008/7/20/rescue-from-dispatching) para exceções lançadas durante o roteamento de uma solicitação.
* O cabeçalho HTTP Accept está desativado por padrão agora. Você deve preferir o uso de URLs formatadas (como `/customers/1.xml`) para indicar o formato desejado. Se você precisar dos cabeçalhos Accept, pode ativá-los novamente com `config.action_controller.use_accept_header = true`.
* Os números de benchmark agora são relatados em milissegundos em vez de frações minúsculas de segundos.
* O Rails agora suporta cookies somente HTTP (e os usa para sessões), o que ajuda a mitigar alguns riscos de script entre sites em navegadores mais recentes.
* `redirect_to` agora suporta totalmente esquemas de URI (então, por exemplo, você pode redirecionar para um URI svn`ssh:).
* `render` agora suporta uma opção `:js` para renderizar JavaScript puro com o tipo MIME correto.
* A proteção contra falsificação de solicitações foi reforçada para se aplicar apenas a solicitações de conteúdo formatado em HTML.
* URLs polimórficas se comportam de forma mais sensata se um parâmetro passado for nulo. Por exemplo, chamar `polymorphic_path([@project, @date, @area])` com uma data nula retornará `project_area_path`.

Action View
-----------

* `javascript_include_tag` e `stylesheet_link_tag` suportam uma nova opção `:recursive` para ser usada junto com `:all`, para que você possa carregar uma árvore inteira de arquivos com uma única linha de código.
* A biblioteca JavaScript Prototype incluída foi atualizada para a versão 1.6.0.3.
* `RJS#page.reload` para recarregar a localização atual do navegador via JavaScript.
* O helper `atom_feed` agora aceita uma opção `:instruct` para permitir a inserção de instruções de processamento XML.

Action Mailer
-------------

O Action Mailer agora suporta layouts de mailer. Você pode deixar seus e-mails em HTML tão bonitos quanto suas visualizações no navegador, fornecendo um layout com o nome apropriado - por exemplo, a classe `CustomerMailer` espera usar `layouts/customer_mailer.html.erb`.

* Mais informações:
    * [What's New in Edge Rails: Mailer Layouts](http://archives.ryandaigle.com/articles/2008/9/7/what-s-new-in-edge-rails-mailer-layouts)

O Action Mailer agora oferece suporte integrado para servidores SMTP do GMail, ativando automaticamente o STARTTLS. Isso requer que o Ruby 1.8.7 esteja instalado.

Active Support
--------------

O Active Support agora oferece memoização integrada para aplicações Rails, o método `each_with_object`, suporte a prefixo em delegates e vários outros novos métodos de utilidade.

### Memoização

A memoização é um padrão de inicializar um método uma vez e depois armazenar seu valor para uso repetido. Provavelmente você já usou esse padrão em suas próprias aplicações:

```ruby
def full_name
  @full_name ||= "#{first_name} #{last_name}"
end
```

A memoização permite que você lide com essa tarefa de forma declarativa:

```ruby
extend ActiveSupport::Memoizable

def full_name
  "#{first_name} #{last_name}"
end
memoize :full_name
```

Outras características da memoização incluem `unmemoize`, `unmemoize_all` e `memoize_all` para ativar ou desativar a memoização.
* Contribuidor Principal: [Josh Peek](http://joshpeek.com/)
* Mais informações:
    * [O que há de novo no Edge Rails: Fácil Memoization](http://archives.ryandaigle.com/articles/2008/7/16/what-s-new-in-edge-rails-memoization)
    * [Memo-o quê? Um guia para Memoization](http://www.railway.at/articles/2008/09/20/a-guide-to-memoization)

### each_with_object

O método `each_with_object` fornece uma alternativa ao `inject`, usando um método retroportado do Ruby 1.9. Ele itera sobre uma coleção, passando o elemento atual e o memo para o bloco.

```ruby
%w(foo bar).each_with_object({}) { |str, hsh| hsh[str] = str.upcase } # => {'foo' => 'FOO', 'bar' => 'BAR'}
```

Contribuidor Principal: [Adam Keys](http://therealadam.com/)

### Delegados com Prefixos

Se você delegar comportamento de uma classe para outra, agora é possível especificar um prefixo que será usado para identificar os métodos delegados. Por exemplo:

```ruby
class Vendor < ActiveRecord::Base
  has_one :account
  delegate :email, :password, :to => :account, :prefix => true
end
```

Isso irá produzir os métodos delegados `vendor#account_email` e `vendor#account_password`. Você também pode especificar um prefixo personalizado:

```ruby
class Vendor < ActiveRecord::Base
  has_one :account
  delegate :email, :password, :to => :account, :prefix => :owner
end
```

Isso irá produzir os métodos delegados `vendor#owner_email` e `vendor#owner_password`.

Contribuidor Principal: [Daniel Schierbeck](http://workingwithrails.com/person/5830-daniel-schierbeck)

### Outras Mudanças no Active Support

* Atualizações extensivas em `ActiveSupport::Multibyte`, incluindo correções de compatibilidade com o Ruby 1.9.
* A adição de `ActiveSupport::Rescuable` permite que qualquer classe misture a sintaxe `rescue_from`.
* `past?`, `today?` e `future?` para as classes `Date` e `Time` para facilitar comparações de data/hora.
* `Array#second` até `Array#fifth` como aliases para `Array#[1]` até `Array#[4]`.
* `Enumerable#many?` para encapsular `collection.size > 1`.
* `Inflector#parameterize` produz uma versão pronta para URL de sua entrada, para uso em `to_param`.
* `Time#advance` reconhece dias e semanas fracionados, então você pode fazer `1.7.weeks.ago`, `1.5.hours.since`, e assim por diante.
* A biblioteca TzInfo incluída foi atualizada para a versão 0.3.12.
* `ActiveSupport::StringInquirer` oferece uma maneira elegante de testar igualdade em strings: `ActiveSupport::StringInquirer.new("abc").abc? => true`

Railties
--------

No Railties (o código principal do Rails em si), as maiores mudanças estão no mecanismo `config.gems`.

### config.gems

Para evitar problemas de implantação e tornar as aplicações Rails mais autocontidas, é possível colocar cópias de todas as gems que sua aplicação Rails requer em `/vendor/gems`. Essa capacidade apareceu pela primeira vez no Rails 2.1, mas é muito mais flexível e robusta no Rails 2.2, lidando com dependências complicadas entre gems. O gerenciamento de gems no Rails inclui os seguintes comandos:

* `config.gem _nome_da_gem_` em seu arquivo `config/environment.rb`
* `rake gems` para listar todas as gems configuradas, bem como se elas (e suas dependências) estão instaladas, congeladas ou do framework (gems do framework são aquelas carregadas pelo Rails antes que o código de dependência da gem seja executado; tais gems não podem ser congeladas)
* `rake gems:install` para instalar as gems ausentes no computador
* `rake gems:unpack` para colocar uma cópia das gems necessárias em `/vendor/gems`
* `rake gems:unpack:dependencies` para obter cópias das gems necessárias e suas dependências em `/vendor/gems`
* `rake gems:build` para construir quaisquer extensões nativas ausentes
* `rake gems:refresh_specs` para alinhar as gems vendidas criadas com o Rails 2.1 com a forma de armazená-las no Rails 2.2

Você pode descompactar ou instalar uma única gem especificando `GEM=_nome_da_gem_` na linha de comando.

* Contribuidor Principal: [Matt Jones](https://github.com/al2o3cr)
* Mais informações:
    * [O que há de novo no Edge Rails: Dependências de Gems](http://archives.ryandaigle.com/articles/2008/4/1/what-s-new-in-edge-rails-gem-dependencies)
    * [Rails 2.1.2 e 2.2RC1: Atualize seu RubyGems](https://afreshcup.com/home/2008/10/25/rails-212-and-22rc1-update-your-rubygems)
    * [Discussão detalhada no Lighthouse](http://rails.lighthouseapp.com/projects/8994-ruby-on-rails/tickets/1128)

### Outras Mudanças no Railties

* Se você é fã do servidor web [Thin](http://code.macournoyer.com/thin/), ficará feliz em saber que o `script/server` agora suporta o Thin diretamente.
* `script/plugin install &lt;plugin&gt; -r &lt;revision&gt;` agora funciona com plugins baseados em git, assim como com plugins baseados em svn.
* `script/console` agora suporta a opção `--debugger`.
* Instruções para configurar um servidor de integração contínua para construir o próprio Rails estão incluídas no código-fonte do Rails.
* `rake notes:custom ANNOTATION=MYFLAG` permite listar anotações personalizadas.
* Envolveu `Rails.env` em `StringInquirer` para que você possa fazer `Rails.env.development?`.
* Para eliminar avisos de depreciação e lidar corretamente com dependências de gems, o Rails agora requer o rubygems 1.3.1 ou superior.

Depreciado
----------

Algumas partes de código mais antigo estão depreciadas nesta versão:

* `Rails::SecretKeyGenerator` foi substituído por `ActiveSupport::SecureRandom`.
* `render_component` está depreciado. Existe um [plugin render_components](https://github.com/rails/render_component/tree/master) disponível se você precisar dessa funcionalidade.
* Atribuições locais implícitas ao renderizar partials estão depreciadas.

    ```ruby
    def partial_with_implicit_local_assignment
      @customer = Customer.new("Marcel")
      render :partial => "customer"
    end
    ```

    Anteriormente, o código acima disponibilizava uma variável local chamada `customer` dentro do partial 'customer'. Agora, você deve passar explicitamente todas as variáveis através do hash `:locals`.
* `country_select` foi removido. Consulte a [página de depreciação](http://www.rubyonrails.org/deprecation/list-of-countries) para obter mais informações e um substituto de plugin.
* `ActiveRecord::Base.allow_concurrency` não tem mais efeito.
* `ActiveRecord::Errors.default_error_messages` foi depreciado em favor de `I18n.translate('activerecord.errors.messages')`
* A sintaxe de interpolação `%s` e `%d` para internacionalização está obsoleta.
* `String#chars` foi depreciado em favor de `String#mb_chars`.
* Durações de meses fracionados ou anos fracionados estão obsoletas. Use a aritmética das classes `Date` e `Time` do Ruby em vez disso.
* `Request#relative_url_root` está obsoleto. Use `ActionController::Base.relative_url_root` em seu lugar.

Créditos
-------

Notas de lançamento compiladas por [Mike Gunderloy](http://afreshcup.com)
