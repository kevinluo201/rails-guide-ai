**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: da25f37b5b3eddff86c5b5b2cd24007f
Ruby on Rails 3.1 Notas de Lançamento
======================================

Destaques do Rails 3.1:

* Streaming
* Migrações Reversíveis
* Pipeline de Ativos
* jQuery como a biblioteca JavaScript padrão

Estas notas de lançamento abrangem apenas as principais mudanças. Para saber sobre várias correções de bugs e mudanças, consulte os registros de alterações ou confira a [lista de commits](https://github.com/rails/rails/commits/3-1-stable) no repositório principal do Rails no GitHub.

--------------------------------------------------------------------------------

Atualizando para o Rails 3.1
----------------------------

Se você está atualizando um aplicativo existente, é uma ótima ideia ter uma boa cobertura de testes antes de começar. Você também deve primeiro atualizar para o Rails 3, caso ainda não tenha feito isso, e garantir que seu aplicativo ainda funcione como esperado antes de tentar atualizar para o Rails 3.1. Em seguida, observe as seguintes mudanças:

### Rails 3.1 requer pelo menos o Ruby 1.8.7

O Rails 3.1 requer o Ruby 1.8.7 ou superior. O suporte para todas as versões anteriores do Ruby foi oficialmente abandonado e você deve fazer a atualização o mais cedo possível. O Rails 3.1 também é compatível com o Ruby 1.9.2.

DICA: Observe que as versões p248 e p249 do Ruby 1.8.7 têm bugs de marshalling que fazem o Rails travar. O Ruby Enterprise Edition corrigiu esses bugs desde o lançamento 1.8.7-2010.02. No front do Ruby 1.9, o Ruby 1.9.1 não é utilizável porque causa falhas de segmentação, então se você quiser usar o 1.9.x, use o 1.9.2 para uma navegação tranquila.

### O que atualizar em seus aplicativos

As seguintes mudanças são destinadas a atualizar seu aplicativo para o Rails 3.1.3, a versão mais recente do Rails 3.1.x.

#### Gemfile

Faça as seguintes alterações no seu `Gemfile`.

```ruby
gem 'rails', '= 3.1.3'
gem 'mysql2'

# Necessário para o novo pipeline de ativos
group :assets do
  gem 'sass-rails',   "~> 3.1.5"
  gem 'coffee-rails', "~> 3.1.1"
  gem 'uglifier',     ">= 1.0.3"
end

# jQuery é a biblioteca JavaScript padrão no Rails 3.1
gem 'jquery-rails'
```

#### config/application.rb

* O pipeline de ativos requer as seguintes adições:

    ```ruby
    config.assets.enabled = true
    config.assets.version = '1.0'
    ```

* Se o seu aplicativo estiver usando a rota "/assets" para um recurso, você pode querer alterar o prefixo usado para os ativos para evitar conflitos:

    ```ruby
    # Padrão é '/assets'
    config.assets.prefix = '/asset-files'
    ```

#### config/environments/development.rb

* Remova a configuração RJS `config.action_view.debug_rjs = true`.

* Adicione o seguinte, se você habilitar o pipeline de ativos.

    ```ruby
    # Não comprimir ativos
    config.assets.compress = false

    # Expande as linhas que carregam os ativos
    config.assets.debug = true
    ```

#### config/environments/production.rb

* Novamente, a maioria das alterações abaixo são para o pipeline de ativos. Você pode ler mais sobre isso no [Guia do Pipeline de Ativos](asset_pipeline.html).

    ```ruby
    # Comprimir JavaScripts e CSS
    config.assets.compress = true

    # Não recorrer ao pipeline de ativos se um ativo pré-compilado estiver faltando
    config.assets.compile = false

    # Gerar hashes para URLs de ativos
    config.assets.digest = true

    # Padrão é Rails.root.join("public/assets")
    # config.assets.manifest = YOUR_PATH

    # Pré-compilar ativos adicionais (application.js, application.css e todos os não JS/CSS já estão adicionados)
    # config.assets.precompile `= %w( admin.js admin.css )


    # Forçar todo o acesso ao aplicativo por SSL, usar Strict-Transport-Security e usar cookies seguros.
    # config.force_ssl = true
    ```

#### config/environments/test.rb

```ruby
# Configurar servidor de ativos estáticos para testes com Cache-Control para desempenho
config.serve_static_assets = true
config.static_cache_control = "public, max-age=3600"
```

#### config/initializers/wrap_parameters.rb

* Adicione este arquivo com o seguinte conteúdo, se você deseja envolver os parâmetros em um hash aninhado. Isso está ativado por padrão em novos aplicativos.

    ```ruby
    # Certifique-se de reiniciar o servidor quando modificar este arquivo.
    # Este arquivo contém configurações para ActionController::ParamsWrapper que
    # está ativado por padrão.

    # Habilitar envolvimento de parâmetros para JSON. Você pode desativar isso definindo :format como um array vazio.
    ActiveSupport.on_load(:action_controller) do
      wrap_parameters :format => [:json]
    end

    # Desativar elemento raiz no JSON por padrão.
    ActiveSupport.on_load(:active_record) do
      self.include_root_in_json = false
    end
    ```

#### Remova as opções :cache e :concat nas referências de helpers de ativos nas visualizações

* Com o Pipeline de Ativos, as opções :cache e :concat não são mais usadas, exclua essas opções das suas visualizações.

Criando um aplicativo Rails 3.1
-------------------------------

```bash
# Você deve ter o RubyGem 'rails' instalado
$ rails new myapp
$ cd myapp
```

### Vendendo Gems

O Rails agora usa um `Gemfile` na raiz do aplicativo para determinar as gems que você precisa para iniciar seu aplicativo. Este `Gemfile` é processado pela gem [Bundler](https://github.com/carlhuda/bundler), que então instala todas as dependências. Ele também pode instalar todas as dependências localmente para o seu aplicativo, para que ele não dependa das gems do sistema.
Mais informações: - [página inicial do Bundler](https://bundler.io/)

### Vivendo no Limite

`Bundler` e `Gemfile` tornam fácil congelar sua aplicação Rails com o novo comando `bundle` dedicado. Se você quiser agrupar diretamente do repositório Git, pode passar a flag `--edge`:

```bash
$ rails new myapp --edge
```

Se você tiver um checkout local do repositório Rails e quiser gerar uma aplicação usando isso, pode passar a flag `--dev`:

```bash
$ ruby /caminho/para/rails/railties/bin/rails new myapp --dev
```

Mudanças Arquiteturais do Rails
---------------------------

### Pipeline de Ativos

A grande mudança no Rails 3.1 é a Pipeline de Ativos. Ela torna CSS e JavaScript cidadãos de primeira classe e permite uma organização adequada, incluindo o uso em plugins e engines.

A pipeline de ativos é alimentada pelo [Sprockets](https://github.com/rails/sprockets) e é abordada no guia [Pipeline de Ativos](asset_pipeline.html).

### Streaming HTTP

O Streaming HTTP é outra mudança que é nova no Rails 3.1. Isso permite que o navegador faça o download de seus arquivos de folhas de estilo e JavaScript enquanto o servidor ainda está gerando a resposta. Isso requer o Ruby 1.9.2, é opcional e requer suporte do servidor web também, mas a combinação popular de NGINX e Unicorn está pronta para aproveitar isso.

### Biblioteca JS padrão agora é o jQuery

O jQuery é a biblioteca JavaScript padrão que vem com o Rails 3.1. Mas se você usa o Prototype, é simples trocar.

```bash
$ rails new myapp -j prototype
```

### Identity Map

O Active Record possui um Identity Map no Rails 3.1. Um Identity Map mantém registros previamente instanciados e retorna o objeto associado ao registro se acessado novamente. O Identity Map é criado em uma base por solicitação e é limpo ao final da solicitação.

O Rails 3.1 vem com o Identity Map desativado por padrão.

Railties
--------

* jQuery é a nova biblioteca JavaScript padrão.

* jQuery e Prototype não são mais fornecidos e agora são fornecidos pelos gems `jquery-rails` e `prototype-rails`.

* O gerador de aplicativos aceita a opção `-j` que pode ser uma string arbitrária. Se passado "foo", o gem "foo-rails" é adicionado ao `Gemfile` e o manifesto de JavaScript da aplicação requer "foo" e "foo_ujs". Atualmente, apenas "prototype-rails" e "jquery-rails" existem e fornecem esses arquivos através da pipeline de ativos.

* Gerar um aplicativo ou um plugin executa `bundle install` a menos que `--skip-gemfile` ou `--skip-bundle` seja especificado.

* Os geradores de controlador e recurso agora automaticamente produzem stubs de ativos (isso pode ser desativado com `--skip-assets`). Esses stubs usarão CoffeeScript e Sass, se essas bibliotecas estiverem disponíveis.

* O gerador de controlador de scaffold cria um bloco de formato para JSON em vez de XML.

* O log do Active Record é direcionado para STDOUT e exibido inline no console.

* Adicionada a configuração `config.force_ssl` que carrega o middleware `Rack::SSL` e força todas as solicitações a estarem sob o protocolo HTTPS.

* Adicionado o comando `rails plugin new` que gera um plugin Rails com gemspec, testes e uma aplicação fictícia para testes.

* Adicionados `Rack::Etag` e `Rack::ConditionalGet` à pilha de middleware padrão.

* Adicionado `Rack::Cache` à pilha de middleware padrão.

* As engines receberam uma grande atualização - você pode montá-las em qualquer caminho, habilitar ativos, executar geradores, etc.

Action Pack
-----------

### Action Controller

* Um aviso é exibido se a autenticidade do token CSRF não puder ser verificada.

* Especifique `force_ssl` em um controlador para forçar o navegador a transferir dados via protocolo HTTPS nesse controlador específico. Para limitar a ações específicas, `:only` ou `:except` podem ser usados.

* Parâmetros de string de consulta sensíveis especificados em `config.filter_parameters` agora serão filtrados dos caminhos de solicitação no log.

* Parâmetros de URL que retornam `nil` para `to_param` agora são removidos da string de consulta.

* Adicionado `ActionController::ParamsWrapper` para envolver parâmetros em um hash aninhado e será ativado por padrão para solicitações JSON em novas aplicações. Isso pode ser personalizado em `config/initializers/wrap_parameters.rb`.

* Adicionado `config.action_controller.include_all_helpers`. Por padrão, `helper :all` é feito em `ActionController::Base`, que inclui todos os helpers por padrão. Definir `include_all_helpers` como `false` resultará na inclusão apenas do `application_helper` e do helper correspondente ao controlador (como `foo_helper` para `foo_controller`).

* `url_for` e os helpers de URL nomeados agora aceitam `:subdomain` e `:domain` como opções.
* Adicionado `Base.http_basic_authenticate_with` para fazer autenticação básica http com uma única chamada de método de classe.

    ```ruby
    class PostsController < ApplicationController
      USER_NAME, PASSWORD = "dhh", "secret"

      before_filter :authenticate, :except => [ :index ]

      def index
        render :text => "Todos podem me ver!"
      end

      def edit
        render :text => "Eu só sou acessível se você souber a senha"
      end

      private
        def authenticate
          authenticate_or_request_with_http_basic do |user_name, password|
            user_name == USER_NAME && password == PASSWORD
          end
        end
    end
    ```

    ..agora pode ser escrito como

    ```ruby
    class PostsController < ApplicationController
      http_basic_authenticate_with :name => "dhh", :password => "secret", :except => :index

      def index
        render :text => "Todos podem me ver!"
      end

      def edit
        render :text => "Eu só sou acessível se você souber a senha"
      end
    end
    ```

* Adicionado suporte a streaming, você pode habilitá-lo com:

    ```ruby
    class PostsController < ActionController::Base
      stream
    end
    ```

    Você pode restringi-lo a algumas ações usando `:only` ou `:except`. Por favor, leia a documentação em [`ActionController::Streaming`](https://api.rubyonrails.org/v3.1.0/classes/ActionController/Streaming.html) para mais informações.

* O método de rota de redirecionamento agora também aceita um hash de opções que só irá alterar as partes da URL em questão, ou um objeto que responda a chamada, permitindo que redirecionamentos sejam reutilizados.

### Action Dispatch

* `config.action_dispatch.x_sendfile_header` agora tem o valor padrão `nil` e `config/environments/production.rb` não define nenhum valor específico para ele. Isso permite que os servidores o definam através de `X-Sendfile-Type`.

* `ActionDispatch::MiddlewareStack` agora usa composição em vez de herança e não é mais um array.

* Adicionado `ActionDispatch::Request.ignore_accept_header` para ignorar cabeçalhos de aceitação.

* Adicionado `Rack::Cache` à pilha padrão.

* Responsabilidade de etag foi movida de `ActionDispatch::Response` para a pilha de middleware.

* Depende da API de armazenamento de `Rack::Session` para maior compatibilidade no mundo Ruby. Isso é incompatível com versões anteriores, já que `Rack::Session` espera que `#get_session` aceite quatro argumentos e requer `#destroy_session` em vez de simplesmente `#destroy`.

* A busca de templates agora procura mais acima na cadeia de herança.

### Action View

* Adicionada a opção `:authenticity_token` para `form_tag` para manipulação personalizada ou para omitir o token passando `:authenticity_token => false`.

* Criado `ActionView::Renderer` e especificada uma API para `ActionView::Context`.

* A mutação do `SafeBuffer` no lugar é proibida no Rails 3.1.

* Adicionado helper `button_tag` do HTML5.

* `file_field` automaticamente adiciona `:multipart => true` ao formulário envolvente.

* Adicionado um idiom de conveniência para gerar atributos HTML5 data-* em helpers de tags a partir de um hash `:data` de opções:

    ```ruby
    tag("div", :data => {:name => 'Stephen', :city_state => %w(Chicago IL)})
    # => <div data-name="Stephen" data-city-state="[&quot;Chicago&quot;,&quot;IL&quot;]" />
    ```

As chaves são convertidas para traços. Os valores são codificados em JSON, exceto para strings e símbolos.

* `csrf_meta_tag` foi renomeado para `csrf_meta_tags` e tem um alias `csrf_meta_tag` para compatibilidade com versões anteriores.

* A antiga API de manipulador de templates está obsoleta e a nova API simplesmente requer que um manipulador de templates responda a `call`.

* rhtml e rxml finalmente foram removidos como manipuladores de templates.

* `config.action_view.cache_template_loading` foi reintroduzido, permitindo decidir se os templates devem ser armazenados em cache ou não.

* O helper de formulário `submit` não gera mais um id "object_name_id".

* Permite que `FormHelper#form_for` especifique o `:method` como uma opção direta em vez de através do hash `:html`. `form_for(@post, remote: true, method: :delete)` em vez de `form_for(@post, remote: true, html: { method: :delete })`.

* Fornecido `JavaScriptHelper#j()` como um alias para `JavaScriptHelper#escape_javascript()`. Isso substitui o método `Object#j()` que a gem JSON adiciona nos templates usando o JavaScriptHelper.

* Permite formato AM/PM nos seletores de data e hora.

* `auto_link` foi removido do Rails e extraído para a [gem rails_autolink](https://github.com/tenderlove/rails_autolink)

Active Record
-------------

* Adicionado um método de classe `pluralize_table_names` para singularizar/pluralizar nomes de tabelas de modelos individuais. Anteriormente, isso só podia ser definido globalmente para todos os modelos através de `ActiveRecord::Base.pluralize_table_names`.

    ```ruby
    class User < ActiveRecord::Base
      self.pluralize_table_names = false
    end
    ```

* Adicionada a definição de atributos para associações singulares. O bloco será chamado após a instância ser inicializada.

    ```ruby
    class User < ActiveRecord::Base
      has_one :account
    end

    user.build_account{ |a| a.credit_limit = 100.0 }
    ```

* Adicionado `ActiveRecord::Base.attribute_names` para retornar uma lista de nomes de atributos. Isso retornará um array vazio se o modelo for abstrato ou a tabela não existir.

* CSV Fixtures está obsoleto e o suporte será removido no Rails 3.2.0.

* `ActiveRecord#new`, `ActiveRecord#create` e `ActiveRecord#update_attributes` agora aceitam um segundo hash como opção que permite especificar qual papel considerar ao atribuir atributos. Isso é construído em cima das capacidades de atribuição em massa do Active Model.
```ruby
class Post < ActiveRecord::Base
  attr_accessible :title
  attr_accessible :title, :published_at, :as => :admin
end

Post.new(params[:post], :as => :admin)
```

* `default_scope` agora pode receber um bloco, lambda ou qualquer outro objeto que responda a chamada para avaliação preguiçosa.

* Os escopos padrão agora são avaliados no momento mais tardio possível, para evitar problemas onde escopos seriam criados que implicitamente conteriam o escopo padrão, que então seria impossível de se livrar via Model.unscoped.

* O adaptador PostgreSQL só suporta a versão 8.2 e superior do PostgreSQL.

* O middleware `ConnectionManagement` foi alterado para limpar o pool de conexões após o corpo do rack ter sido enviado.

* Adicionado um método `update_column` no Active Record. Este novo método atualiza um atributo específico em um objeto, ignorando validações e callbacks. É recomendado usar `update_attributes` ou `update_attribute` a menos que você tenha certeza de que não deseja executar nenhum callback, incluindo a modificação da coluna `updated_at`. Não deve ser chamado em novos registros.

* Associações com a opção `:through` agora podem usar qualquer associação como a associação através ou de origem, incluindo outras associações que têm a opção `:through` e associações `has_and_belongs_to_many`.

* A configuração para a conexão atual do banco de dados agora é acessível através de `ActiveRecord::Base.connection_config`.

* limites e offsets são removidos de consultas COUNT a menos que ambos sejam fornecidos.

```ruby
People.limit(1).count           # => 'SELECT COUNT(*) FROM people'
People.offset(1).count          # => 'SELECT COUNT(*) FROM people'
People.limit(1).offset(1).count # => 'SELECT COUNT(*) FROM people LIMIT 1 OFFSET 1'
```

* `ActiveRecord::Associations::AssociationProxy` foi dividido. Agora existe uma classe `Association` (e subclasses) que são responsáveis por operar em associações, e então um wrapper separado e fino chamado `CollectionProxy`, que faz proxy para associações de coleção. Isso evita poluição de namespace, separa responsabilidades e permitirá refatorações adicionais.

* Associações singulares (`has_one`, `belongs_to`) não têm mais um proxy e simplesmente retornam o registro associado ou `nil`. Isso significa que você não deve usar métodos não documentados como `bob.mother.create` - use `bob.create_mother` em vez disso.

* Suporte à opção `:dependent` em associações `has_many :through`. Por razões históricas e práticas, `:delete_all` é a estratégia de exclusão padrão empregada por `association.delete(*records)`, apesar do fato de que a estratégia padrão é `:nullify` para has_many regulares. Além disso, isso só funciona se a reflexão de origem for um belongs_to. Para outras situações, você deve modificar diretamente a associação através.

* O comportamento de `association.destroy` para `has_and_belongs_to_many` e `has_many :through` foi alterado. A partir de agora, 'destroy' ou 'delete' em uma associação será entendido como 'se livrar do link', não (necessariamente) 'se livrar dos registros associados'.

* Anteriormente, `has_and_belongs_to_many.destroy(*records)` destruiria os próprios registros. Não deletaria nenhum registro na tabela de junção. Agora, ele deleta os registros na tabela de junção.

* Anteriormente, `has_many_through.destroy(*records)` destruiria os próprios registros e os registros na tabela de junção. [Nota: Isso nem sempre foi o caso; versões anteriores do Rails apenas deletavam os próprios registros.] Agora, ele destrói apenas os registros na tabela de junção.

* Observe que essa mudança é incompatível com versões anteriores até certo ponto, mas infelizmente não há como 'descontinuá-la' antes de mudá-la. A mudança está sendo feita para ter consistência quanto ao significado de 'destroy' ou 'delete' nos diferentes tipos de associações. Se você deseja destruir os próprios registros, você pode fazer `records.association.each(&:destroy)`.

* Adicionada a opção `:bulk => true` para `change_table` para fazer todas as alterações de esquema definidas em um bloco usando uma única instrução ALTER.

```ruby
change_table(:users, :bulk => true) do |t|
  t.string :company_name
  t.change :birthdate, :datetime
end
```

* Removido o suporte para acessar atributos em uma tabela de junção `has_and_belongs_to_many`. `has_many :through` precisa ser usado.

* Adicionado um método `create_association!` para associações `has_one` e `belongs_to`.

* As migrações agora são reversíveis, o que significa que o Rails descobrirá como reverter suas migrações. Para usar migrações reversíveis, basta definir o método `change`.

```ruby
class MyMigration < ActiveRecord::Migration
  def change
    create_table(:horses) do |t|
      t.column :content, :text
      t.column :remind_at, :datetime
    end
  end
end
```

* Algumas coisas não podem ser revertidas automaticamente para você. Se você souber como reverter essas coisas, você deve definir `up` e `down` em sua migração. Se você definir algo em `change` que não pode ser revertido, uma exceção `IrreversibleMigration` será lançada ao reverter.

* As migrações agora usam métodos de instância em vez de métodos de classe:
```ruby
class FooMigration < ActiveRecord::Migration
  def up # Não self.up
    # ...
  end
end
```

* Os arquivos de migração gerados a partir dos geradores de modelo e migração construtiva (por exemplo, add_name_to_users) usam o método `change` da migração reversível em vez dos métodos `up` e `down` comuns.

* Removido o suporte para interpolar condições SQL de string em associações. Em vez disso, deve ser usado um proc.

```ruby
has_many :things, :conditions => 'foo = #{bar}'          # antes
has_many :things, :conditions => proc { "foo = #{bar}" } # depois
```

Dentro do proc, `self` é o objeto que é o proprietário da associação, a menos que você esteja carregando a associação de forma ansiosa, nesse caso `self` é a classe à qual a associação pertence.

Você pode ter qualquer condição "normal" dentro do proc, então o seguinte também funcionará:

```ruby
has_many :things, :conditions => proc { ["foo = ?", bar] }
```

* Anteriormente, `:insert_sql` e `:delete_sql` na associação `has_and_belongs_to_many` permitiam chamar 'record' para obter o registro sendo inserido ou excluído. Agora isso é passado como um argumento para o proc.

* Adicionado `ActiveRecord::Base#has_secure_password` (via `ActiveModel::SecurePassword`) para encapsular o uso simples de senhas com criptografia e salting BCrypt.

```ruby
# Schema: User(name:string, password_digest:string, password_salt:string)
class User < ActiveRecord::Base
  has_secure_password
end
```

* Quando um modelo é gerado, `add_index` é adicionado por padrão para colunas `belongs_to` ou `references`.

* Definir o id de um objeto `belongs_to` atualizará a referência para o objeto.

* A semântica de `ActiveRecord::Base#dup` e `ActiveRecord::Base#clone` mudou para se aproximar das semânticas normais de dup e clone do Ruby.

* Chamar `ActiveRecord::Base#clone` resultará em uma cópia superficial do registro, incluindo a cópia do estado congelado. Nenhum callback será chamado.

* Chamar `ActiveRecord::Base#dup` duplicará o registro, incluindo a chamada de hooks after initialize. O estado congelado não será copiado e todas as associações serão limpas. Um registro duplicado retornará `true` para `new_record?`, terá um campo de id `nil` e poderá ser salvo.

* O cache de consulta agora funciona com declarações preparadas. Nenhuma alteração nas aplicações é necessária.

Active Model
------------

* `attr_accessible` aceita uma opção `:as` para especificar uma função.

* `InclusionValidator`, `ExclusionValidator` e `FormatValidator` agora aceitam uma opção que pode ser um proc, um lambda ou qualquer coisa que responda a `call`. Essa opção será chamada com o registro atual como argumento e retornará um objeto que responda a `include?` para `InclusionValidator` e `ExclusionValidator`, e retornará um objeto de expressão regular para `FormatValidator`.

* Adicionado `ActiveModel::SecurePassword` para encapsular o uso simples de senhas com criptografia e salting BCrypt.

* `ActiveModel::AttributeMethods` permite que atributos sejam definidos sob demanda.

* Adicionado suporte para habilitar e desabilitar seletivamente observadores.

* A pesquisa de namespace alternativo `I18n` não é mais suportada.

Active Resource
---------------

* O formato padrão foi alterado para JSON para todas as solicitações. Se você deseja continuar usando XML, precisará definir `self.format = :xml` na classe. Por exemplo,

```ruby
class User < ActiveResource::Base
  self.format = :xml
end
```

Active Support
--------------

* `ActiveSupport::Dependencies` agora gera um `NameError` se encontrar uma constante existente em `load_missing_constant`.

* Adicionado um novo método de relatório `Kernel#quietly` que silencia tanto `STDOUT` quanto `STDERR`.

* Adicionado `String#inquiry` como um método de conveniência para transformar uma String em um objeto `StringInquirer`.

* Adicionado `Object#in?` para testar se um objeto está incluído em outro objeto.

* A estratégia `LocalCache` agora é uma classe de middleware real e não mais uma classe anônima.

* Foi introduzida a classe `ActiveSupport::Dependencies::ClassCache` para manter referências a classes recarregáveis.

* `ActiveSupport::Dependencies::Reference` foi refatorado para aproveitar diretamente o novo `ClassCache`.

* Backports `Range#cover?` como um alias para `Range#include?` no Ruby 1.8.

* Adicionado `weeks_ago` e `prev_week` para Date/DateTime/Time.

* Adicionado callback `before_remove_const` para `ActiveSupport::Dependencies.remove_unloadable_constants!`.

Depreciações:

* `ActiveSupport::SecureRandom` está obsoleto em favor de `SecureRandom` da biblioteca padrão do Ruby.

Créditos
-------

Veja a [lista completa de contribuidores para o Rails](https://contributors.rubyonrails.org/) para as muitas pessoas que passaram muitas horas fazendo do Rails o framework estável e robusto que ele é. Parabéns a todos eles.

As Notas de Lançamento do Rails 3.1 foram compiladas por [Vijay Dev](https://github.com/vijaydev)
