**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 30550ed8fa3c0983f3d99a0e91571a98
Ruby on Rails 3.2 Notas de Lançamento
======================================

Destaques do Rails 3.2:

* Modo de Desenvolvimento mais Rápido
* Novo Motor de Roteamento
* Explicações Automáticas de Consultas
* Logging com Tags

Estas notas de lançamento cobrem apenas as principais mudanças. Para saber sobre várias correções de bugs e mudanças, por favor, consulte os registros de alterações ou verifique a [lista de commits](https://github.com/rails/rails/commits/3-2-stable) no repositório principal do Rails no GitHub.

--------------------------------------------------------------------------------

Atualizando para o Rails 3.2
----------------------------

Se você está atualizando um aplicativo existente, é uma ótima ideia ter uma boa cobertura de testes antes de começar. Você também deve primeiro atualizar para o Rails 3.1, caso ainda não tenha feito isso, e garantir que seu aplicativo ainda funcione como esperado antes de tentar uma atualização para o Rails 3.2. Em seguida, observe as seguintes mudanças:

### O Rails 3.2 requer pelo menos o Ruby 1.8.7

O Rails 3.2 requer o Ruby 1.8.7 ou superior. O suporte para todas as versões anteriores do Ruby foi oficialmente removido e você deve fazer a atualização o mais cedo possível. O Rails 3.2 também é compatível com o Ruby 1.9.2.

DICA: Note que as versões p248 e p249 do Ruby 1.8.7 possuem bugs de marshalling que fazem o Rails travar. O Ruby Enterprise Edition corrigiu esses bugs desde o lançamento da versão 1.8.7-2010.02. Na versão 1.9, o Ruby 1.9.1 não é utilizável porque causa falhas de segmentação, então, se você quiser usar a versão 1.9.x, vá direto para a versão 1.9.2 ou 1.9.3 para uma experiência tranquila.

### O que atualizar em seus aplicativos

* Atualize seu `Gemfile` para depender de
    * `rails = 3.2.0`
    * `sass-rails ~> 3.2.3`
    * `coffee-rails ~> 3.2.1`
    * `uglifier >= 1.0.3`

* O Rails 3.2 deprecia o uso de `vendor/plugins` e o Rails 4.0 irá removê-los completamente. Você pode começar a substituir esses plugins extraindo-os como gems e adicionando-os ao seu `Gemfile`. Se você optar por não transformá-los em gems, você pode movê-los para, por exemplo, `lib/my_plugin/*` e adicionar um inicializador apropriado em `config/initializers/my_plugin.rb`.

* Existem algumas novas alterações de configuração que você deve adicionar em `config/environments/development.rb`:

    ```ruby
    # Levantar exceção na proteção de atribuição em massa para modelos Active Record
    config.active_record.mass_assignment_sanitizer = :strict

    # Registrar o plano de consulta para consultas que levam mais tempo que isso (funciona
    # com SQLite, MySQL e PostgreSQL)
    config.active_record.auto_explain_threshold_in_seconds = 0.5
    ```

    A configuração `mass_assignment_sanitizer` também precisa ser adicionada em `config/environments/test.rb`:

    ```ruby
    # Levantar exceção na proteção de atribuição em massa para modelos Active Record
    config.active_record.mass_assignment_sanitizer = :strict
    ```

### O que atualizar em suas engines

Substitua o código abaixo do comentário em `script/rails` pelo seguinte conteúdo:

```ruby
ENGINE_ROOT = File.expand_path('../..', __FILE__)
ENGINE_PATH = File.expand_path('../../lib/your_engine_name/engine', __FILE__)

require "rails/all"
require "rails/engine/commands"
```

Criando um aplicativo Rails 3.2
-------------------------------

```bash
# Você deve ter o RubyGem 'rails' instalado
$ rails new myapp
$ cd myapp
```

### Vendendo Gems

O Rails agora usa um `Gemfile` na raiz do aplicativo para determinar as gems necessárias para o seu aplicativo iniciar. Este `Gemfile` é processado pela gem [Bundler](https://github.com/carlhuda/bundler), que então instala todas as dependências. Ele também pode instalar todas as dependências localmente para o seu aplicativo, para que ele não dependa das gems do sistema.

Mais informações: [Página inicial do Bundler](https://bundler.io/)

### Vivendo no Limite

O `Bundler` e o `Gemfile` tornam fácil congelar seu aplicativo Rails com o novo comando `bundle` dedicado. Se você quiser agrupar diretamente do repositório Git, você pode passar a flag `--edge`:

```bash
$ rails new myapp --edge
```

Se você tiver um checkout local do repositório do Rails e quiser gerar um aplicativo usando isso, você pode passar a flag `--dev`:

```bash
$ ruby /caminho/para/rails/railties/bin/rails new myapp --dev
```

Principais Recursos
-------------------

### Modo de Desenvolvimento mais Rápido e Roteamento

O Rails 3.2 vem com um modo de desenvolvimento que é perceptivelmente mais rápido. Inspirado pelo [Active Reload](https://github.com/paneq/active_reload), o Rails recarrega as classes apenas quando os arquivos realmente mudam. Os ganhos de desempenho são dramáticos em um aplicativo maior. O reconhecimento de rotas também ficou muito mais rápido graças ao novo motor [Journey](https://github.com/rails/journey).

### Explicações Automáticas de Consultas

O Rails 3.2 vem com um recurso interessante que explica as consultas geradas pelo Arel, definindo um método `explain` em `ActiveRecord::Relation`. Por exemplo, você pode executar algo como `puts Person.active.limit(5).explain` e a consulta produzida pelo Arel será explicada. Isso permite verificar os índices adequados e otimizações adicionais.

Consultas que levam mais de meio segundo para serem executadas são *automaticamente* explicadas no modo de desenvolvimento. É claro que esse limite pode ser alterado.

### Logging com Tags
Ao executar um aplicativo multiusuário e multi-conta, é de grande ajuda poder filtrar o log por quem fez o quê. O TaggedLogging no Active Support ajuda a fazer exatamente isso, marcando as linhas de log com subdomínios, ids de solicitação e qualquer outra coisa para auxiliar na depuração desses aplicativos.

Documentação
-------------

A partir do Rails 3.2, os guias do Rails estão disponíveis para o Kindle e para os aplicativos gratuitos de leitura do Kindle para iPad, iPhone, Mac, Android, etc.

Railties
--------

* Acelere o desenvolvimento recarregando apenas as classes se os arquivos de dependência forem alterados. Isso pode ser desativado definindo `config.reload_classes_only_on_change` como falso.

* Novos aplicativos recebem uma flag `config.active_record.auto_explain_threshold_in_seconds` nos arquivos de configuração de ambiente. Com um valor de `0.5` em `development.rb` e comentado em `production.rb`. Nenhuma menção em `test.rb`.

* Adicionado `config.exceptions_app` para definir a aplicação de exceções invocada pelo middleware `ShowException` quando ocorre uma exceção. O padrão é `ActionDispatch::PublicExceptions.new(Rails.public_path)`.

* Adicionado um middleware `DebugExceptions` que contém recursos extraídos do middleware `ShowExceptions`.

* Exibir as rotas das engines montadas em `rake routes`.

* Permitir alterar a ordem de carregamento das railties com `config.railties_order`, como:

    ```ruby
    config.railties_order = [Blog::Engine, :main_app, :all]
    ```

* O scaffold retorna 204 No Content para solicitações de API sem conteúdo. Isso faz com que o scaffold funcione com o jQuery sem problemas.

* Atualizar o middleware `Rails::Rack::Logger` para aplicar quaisquer tags definidas em `config.log_tags` para `ActiveSupport::TaggedLogging`. Isso facilita a marcação das linhas de log com informações de depuração, como subdomínio e id de solicitação - ambos muito úteis na depuração de aplicativos de produção multiusuário.

* As opções padrão para `rails new` podem ser definidas em `~/.railsrc`. Você pode especificar argumentos extras de linha de comando a serem usados sempre que `rails new` for executado no arquivo de configuração `.railsrc` em seu diretório pessoal.

* Adicionar um alias `d` para `destroy`. Isso também funciona para engines.

* Os atributos nos geradores de scaffold e model são padrão para string. Isso permite o seguinte: `bin/rails g scaffold Post title body:text author`

* Permitir que os geradores de scaffold/model/migration aceitem modificadores "index" e "uniq". Por exemplo,

    ```bash
    bin/rails g scaffold Post title:string:index author:uniq price:decimal{7,2}
    ```

    criará índices para `title` e `author`, sendo este último um índice exclusivo. Alguns tipos, como decimal, aceitam opções personalizadas. No exemplo, `price` será uma coluna decimal com precisão e escala definidas como 7 e 2, respectivamente.

* A gem Turn foi removida do Gemfile padrão.

* Remover o antigo gerador de plugins `rails generate plugin` em favor do comando `rails plugin new`.

* Remover a antiga API `config.paths.app.controller` em favor de `config.paths["app/controller"]`.

### Depreciações

* `Rails::Plugin` está obsoleto e será removido no Rails 4.0. Em vez de adicionar plugins ao `vendor/plugins`, use gems ou bundler com dependências de caminho ou git.

Action Mailer
-------------

* Atualizada a versão do `mail` para 2.4.0.

* Removida a antiga API do Action Mailer, que estava obsoleta desde o Rails 3.0.

Action Pack
-----------

### Action Controller

* Tornar `ActiveSupport::Benchmarkable` um módulo padrão para `ActionController::Base`, para que o método `#benchmark` esteja novamente disponível no contexto do controlador, como costumava ser.

* Adicionada a opção `:gzip` para `caches_page`. A opção padrão pode ser configurada globalmente usando `page_cache_compression`.

* O Rails agora usará seu layout padrão (como "layouts/application") quando você especificar um layout com a condição `:only` e `:except`, e essas condições falharem.

    ```ruby
    class CarsController
      layout 'single_car', :only => :show
    end
    ```

    O Rails usará `layouts/single_car` quando uma solicitação chegar à ação `:show`, e usará `layouts/application` (ou `layouts/cars`, se existir) quando uma solicitação chegar a qualquer outra ação.

* `form_for` foi alterado para usar `#{action}_#{as}` como a classe CSS e id se a opção `:as` for fornecida. Versões anteriores usavam `#{as}_#{action}`.

* `ActionController::ParamsWrapper` nos modelos Active Record agora envolve apenas os atributos `attr_accessible` se eles forem definidos. Caso contrário, apenas os atributos retornados pelo método de classe `attribute_names` serão envolvidos. Isso corrige o envolvimento de atributos aninhados adicionando-os a `attr_accessible`.

* Registrar "Filter chain halted as CALLBACKNAME rendered or redirected" sempre que um retorno de chamada antes interrompe a execução.

* `ActionDispatch::ShowExceptions` foi refatorado. O controlador é responsável por escolher mostrar exceções. É possível substituir `show_detailed_exceptions?` nos controladores para especificar quais solicitações devem fornecer informações de depuração em caso de erros.

* Os Responders agora retornam 204 No Content para solicitações de API sem corpo de resposta (como no novo scaffold).

* `ActionController::TestCase` cookies foi refatorado. Atribuir cookies para casos de teste agora deve usar `cookies[]`.
```ruby
cookies[:email] = 'user@example.com'
get :index
assert_equal 'user@example.com', cookies[:email]
```

Para limpar os cookies, use `clear`.

```ruby
cookies.clear
get :index
assert_nil cookies[:email]
```

Agora não escrevemos mais o HTTP_COOKIE e o cookie jar é persistente entre as requisições, então se você precisar manipular o ambiente para o seu teste, você precisa fazer isso antes que o cookie jar seja criado.

* `send_file` agora adivinha o tipo MIME a partir da extensão do arquivo se `:type` não for fornecido.

* Foram adicionadas entradas de tipo MIME para PDF, ZIP e outros formatos.

* Permite que `fresh_when/stale?` receba um registro em vez de um hash de opções.

* Alterado o nível de log de aviso para token CSRF ausente de `:debug` para `:warn`.

* Os assets devem usar o protocolo da requisição por padrão ou padrão relativo se não houver requisição disponível.

#### Depreciações

* Depreciado a busca implícita de layout em controladores cujo pai tinha um layout explícito definido:

```ruby
class ApplicationController
  layout "application"
end

class PostsController < ApplicationController
end
```

No exemplo acima, `PostsController` não procurará automaticamente por um layout de posts. Se você precisar dessa funcionalidade, você pode remover `layout "application"` de `ApplicationController` ou definir explicitamente como `nil` em `PostsController`.

* Depreciado `ActionController::UnknownAction` em favor de `AbstractController::ActionNotFound`.

* Depreciado `ActionController::DoubleRenderError` em favor de `AbstractController::DoubleRenderError`.

* Depreciado `method_missing` em favor de `action_missing` para ações ausentes.

* Depreciado `ActionController#rescue_action`, `ActionController#initialize_template_class` e `ActionController#assign_shortcuts`.

### Action Dispatch

* Adicionado `config.action_dispatch.default_charset` para configurar o charset padrão para `ActionDispatch::Response`.

* Adicionado o middleware `ActionDispatch::RequestId` que torna um cabeçalho X-Request-Id único disponível para a resposta e habilita o método `ActionDispatch::Request#uuid`. Isso facilita o rastreamento de solicitações de ponta a ponta na pilha e identificar solicitações individuais em logs mistos como o Syslog.

* O middleware `ShowExceptions` agora aceita um aplicativo de exceções que é responsável por renderizar uma exceção quando o aplicativo falha. O aplicativo é invocado com uma cópia da exceção em `env["action_dispatch.exception"]` e com o `PATH_INFO` reescrito para o código de status.

* Permite configurar as respostas de resgate através de um railtie, como em `config.action_dispatch.rescue_responses`.

#### Depreciações

* Depreciada a capacidade de definir um charset padrão no nível do controlador, use o novo `config.action_dispatch.default_charset` em vez disso.

### Action View

* Adicionado suporte `button_tag` para `ActionView::Helpers::FormBuilder`. Esse suporte imita o comportamento padrão de `submit_tag`.

```erb
<%= form_for @post do |f| %>
  <%= f.button %>
<% end %>
```

* Os ajudantes de data aceitam uma nova opção `:use_two_digit_numbers => true`, que renderiza caixas de seleção para meses e dias com um zero à esquerda sem alterar os respectivos valores. Por exemplo, isso é útil para exibir datas no estilo ISO 8601, como '2011-08-01'.

* Você pode fornecer um namespace para o seu formulário para garantir a unicidade dos atributos id nos elementos do formulário. O atributo namespace será prefixado com um sublinhado no id HTML gerado.

```erb
<%= form_for(@offer, :namespace => 'namespace') do |f| %>
  <%= f.label :version, 'Version' %>:
  <%= f.text_field :version %>
<% end %>
```

* Limite o número de opções para `select_year` para 1000. Passe a opção `:max_years_allowed` para definir seu próprio limite.

* `content_tag_for` e `div_for` agora podem receber uma coleção de registros. Ele também fornecerá o registro como o primeiro argumento se você definir um argumento de recebimento em seu bloco. Então, em vez de fazer isso:

```ruby
@items.each do |item|
  content_tag_for(:li, item) do
    Title: <%= item.title %>
  end
end
```

Você pode fazer isso:

```ruby
content_tag_for(:li, @items) do |item|
  Title: <%= item.title %>
end
```

* Adicionado o método auxiliar `font_path` que calcula o caminho para um asset de fonte em `public/fonts`.

#### Depreciações

* Passar formatos ou manipuladores para `render :template` e amigos como `render :template => "foo.html.erb"` está depreciado. Em vez disso, você pode fornecer `:handlers` e `:formats` diretamente como opções: `render :template => "foo", :formats => [:html, :js], :handlers => :erb`.

### Sprockets

* Adiciona uma opção de configuração `config.assets.logger` para controlar o registro do Sprockets. Defina como `false` para desativar o registro e como `nil` para usar o `Rails.logger` padrão. 

Active Record
-------------

* Colunas booleanas com valores 'on' e 'ON' são convertidas para true.

* Quando o método `timestamps` cria as colunas `created_at` e `updated_at`, elas são definidas como não nulas por padrão.

* Implementado `ActiveRecord::Relation#explain`.

* Implementa `ActiveRecord::Base.silence_auto_explain`, que permite ao usuário desativar seletivamente os EXPLAINs automáticos dentro de um bloco.

* Implementa o registro automático de EXPLAIN para consultas lentas. Um novo parâmetro de configuração `config.active_record.auto_explain_threshold_in_seconds` determina o que é considerado uma consulta lenta. Definir como nil desativa esse recurso. Os valores padrão são 0.5 no modo de desenvolvimento e nil nos modos de teste e produção. O Rails 3.2 suporta esse recurso no SQLite, MySQL (adaptador mysql2) e PostgreSQL.
* Adicionado `ActiveRecord::Base.store` para declarar armazenamentos chave/valor simples de uma única coluna.

    ```ruby
    class User < ActiveRecord::Base
      store :settings, accessors: [ :color, :homepage ]
    end

    u = User.new(color: 'black', homepage: '37signals.com')
    u.color                          # Acessa o atributo armazenado
    u.settings[:country] = 'Denmark' # Qualquer atributo, mesmo que não tenha sido especificado com um acessor
    ```

* Adicionada a capacidade de executar migrações apenas para um escopo específico, o que permite executar migrações apenas de um mecanismo (por exemplo, reverter alterações de um mecanismo que precisa ser removido).

    ```
    rake db:migrate SCOPE=blog
    ```

* As migrações copiadas dos mecanismos agora são agrupadas com o nome do mecanismo, por exemplo, `01_create_posts.blog.rb`.

* Implementado o método `ActiveRecord::Relation#pluck` que retorna um array de valores de coluna diretamente da tabela subjacente. Isso também funciona com atributos serializados.

    ```ruby
    Client.where(:active => true).pluck(:id)
    # SELECT id from clients where active = 1
    ```

* Os métodos de associação gerados são criados dentro de um módulo separado para permitir a substituição e composição. Para uma classe chamada MyModel, o módulo é chamado `MyModel::GeneratedFeatureMethods`. Ele é incluído na classe do modelo imediatamente após o módulo `generated_attributes_methods` definido em Active Model, para que os métodos de associação substituam os métodos de atributo com o mesmo nome.

* Adicionado `ActiveRecord::Relation#uniq` para gerar consultas únicas.

    ```ruby
    Client.select('DISTINCT name')
    ```

    ..pode ser escrito como:

    ```ruby
    Client.select(:name).uniq
    ```

    Isso também permite reverter a unicidade em uma relação:

    ```ruby
    Client.select(:name).uniq.uniq(false)
    ```

* Suporte à ordenação de índices nos adaptadores SQLite, MySQL e PostgreSQL.

* Permitir que a opção `:class_name` para associações aceite um símbolo além de uma string. Isso é para evitar confusão para iniciantes e ser consistente com o fato de que outras opções como `:foreign_key` já permitem um símbolo ou uma string.

    ```ruby
    has_many :clients, :class_name => :Client # Observe que o símbolo precisa estar em maiúsculo
    ```

* No modo de desenvolvimento, `db:drop` também exclui o banco de dados de teste para ser simétrico com `db:create`.

* A validação de unicidade sem diferenciação de maiúsculas e minúsculas evita chamar LOWER no MySQL quando a coluna já usa uma colação insensível a maiúsculas e minúsculas.

* Os fixtures transacionais incluem todas as conexões de banco de dados ativas. Você pode testar modelos em diferentes conexões sem desabilitar os fixtures transacionais.

* Adicionados os métodos `first_or_create`, `first_or_create!`, `first_or_initialize` ao Active Record. Esta é uma abordagem melhor do que os antigos métodos dinâmicos `find_or_create_by`, porque é mais claro quais argumentos são usados para encontrar o registro e quais são usados para criá-lo.

    ```ruby
    User.where(:first_name => "Scarlett").first_or_create!(:last_name => "Johansson")
    ```

* Adicionado o método `with_lock` aos objetos Active Record, que inicia uma transação, bloqueia o objeto (de forma pessimista) e passa para o bloco. O método recebe um parâmetro (opcional) e o passa para `lock!`.

    Isso torna possível escrever o seguinte:

    ```ruby
    class Order < ActiveRecord::Base
      def cancel!
        transaction do
          lock!
          # ... lógica de cancelamento
        end
      end
    end
    ```

    como:

    ```ruby
    class Order < ActiveRecord::Base
      def cancel!
        with_lock do
          # ... lógica de cancelamento
        end
      end
    end
    ```

### Descontinuações

* O fechamento automático de conexões em threads está descontinuado. Por exemplo, o seguinte código está descontinuado:

    ```ruby
    Thread.new { Post.find(1) }.join
    ```

    Ele deve ser alterado para fechar a conexão com o banco de dados no final da thread:

    ```ruby
    Thread.new {
      Post.find(1)
      Post.connection.close
    }.join
    ```

    Apenas as pessoas que criam threads em seu código de aplicativo precisam se preocupar com essa alteração.

* Os métodos `set_table_name`, `set_inheritance_column`, `set_sequence_name`, `set_primary_key`, `set_locking_column` estão descontinuados. Use um método de atribuição em vez disso. Por exemplo, em vez de `set_table_name`, use `self.table_name=`.

    ```ruby
    class Project < ActiveRecord::Base
      self.table_name = "project"
    end
    ```

    Ou defina seu próprio método `self.table_name`:

    ```ruby
    class Post < ActiveRecord::Base
      def self.table_name
        "special_" + super
      end
    end

    Post.table_name # => "special_posts"
    ```

Active Model
------------

* Adicionado `ActiveModel::Errors#added?` para verificar se um erro específico foi adicionado.

* Adicionada a capacidade de definir validações estritas com `strict => true` que sempre gera uma exceção quando falha.

* Fornecer `mass_assignment_sanitizer` como uma API fácil para substituir o comportamento do sanitizador. Também suporta comportamento de sanitização `:logger` (padrão) e `:strict`.

### Descontinuações

* Descontinuado `define_attr_method` em `ActiveModel::AttributeMethods` porque isso só existia para suportar métodos como `set_table_name` em Active Record, que estão sendo descontinuados.

* Descontinuado `Model.model_name.partial_path` em favor de `model.to_partial_path`.

Active Resource
---------------

* Respostas de redirecionamento: 303 See Other e 307 Temporary Redirect agora se comportam como 301 Moved Permanently e 302 Found.

Active Support
--------------

* Adicionado `ActiveSupport:TaggedLogging` que pode envolver qualquer classe `Logger` padrão para fornecer recursos de marcação.

    ```ruby
    Logger = ActiveSupport::TaggedLogging.new(Logger.new(STDOUT))

    Logger.tagged("BCX") { Logger.info "Stuff" }
    # Logs "[BCX] Stuff"

    Logger.tagged("BCX", "Jason") { Logger.info "Stuff" }
    # Logs "[BCX] [Jason] Stuff"

    Logger.tagged("BCX") { Logger.tagged("Jason") { Logger.info "Stuff" } }
    # Logs "[BCX] [Jason] Stuff"
    ```
* O método `beginning_of_week` em `Date`, `Time` e `DateTime` aceita um argumento opcional que representa o dia em que a semana é assumida como iniciada.

* `ActiveSupport::Notifications.subscribed` fornece assinaturas para eventos enquanto um bloco é executado.

* Foram definidos novos métodos `Module#qualified_const_defined?`, `Module#qualified_const_get` e `Module#qualified_const_set` que são análogos aos métodos correspondentes na API padrão, mas aceitam nomes de constantes qualificadas.

* Adicionado `#deconstantize` que complementa `#demodulize` em inflections. Isso remove o segmento mais à direita em um nome de constante qualificada.

* Adicionado `safe_constantize` que transforma uma string em uma constante, mas retorna `nil` em vez de lançar uma exceção se a constante (ou parte dela) não existir.

* `ActiveSupport::OrderedHash` agora é marcado como extraível ao usar `Array#extract_options!`.

* Adicionado `Array#prepend` como um alias para `Array#unshift` e `Array#append` como um alias para `Array#<<`.

* A definição de uma string vazia para o Ruby 1.9 foi estendida para incluir espaços em branco Unicode. Além disso, no Ruby 1.8, o espaço ideográfico U+3000 é considerado espaço em branco.

* O inflector entende acrônimos.

* Adicionado `Time#all_day`, `Time#all_week`, `Time#all_quarter` e `Time#all_year` como uma forma de gerar intervalos.

    ```ruby
    Event.where(:created_at => Time.now.all_week)
    Event.where(:created_at => Time.now.all_day)
    ```

* Adicionado `instance_accessor: false` como uma opção para `Class#cattr_accessor` e amigos.

* `ActiveSupport::OrderedHash` agora tem comportamento diferente para `#each` e `#each_pair` quando um bloco é fornecido com parâmetros usando um splat.

* Adicionado `ActiveSupport::Cache::NullStore` para uso em desenvolvimento e testes.

* Removido `ActiveSupport::SecureRandom` em favor de `SecureRandom` da biblioteca padrão.

### Depreciações

* `ActiveSupport::Base64` está depreciado em favor de `::Base64`.

* `ActiveSupport::Memoizable` está depreciado em favor do padrão de memoização do Ruby.

* `Module#synchronize` está depreciado sem substituição. Por favor, use o monitor da biblioteca padrão do Ruby.

* `ActiveSupport::MessageEncryptor#encrypt` e `ActiveSupport::MessageEncryptor#decrypt` estão depreciados.

* `ActiveSupport::BufferedLogger#silence` está depreciado. Se você quiser silenciar os logs para um determinado bloco, altere o nível de log para esse bloco.

* `ActiveSupport::BufferedLogger#open_log` está depreciado. Este método não deveria ter sido público em primeiro lugar.

* A criação automática do diretório para o arquivo de log em `ActiveSupport::BufferedLogger` está depreciada. Certifique-se de criar o diretório para o arquivo de log antes de instanciá-lo.

* `ActiveSupport::BufferedLogger#auto_flushing` está depreciado. Defina o nível de sincronização no manipulador de arquivo subjacente como este exemplo. Ou ajuste o seu sistema de arquivos. O cache do sistema de arquivos é o que controla a sincronização.

    ```ruby
    f = File.open('foo.log', 'w')
    f.sync = true
    ActiveSupport::BufferedLogger.new f
    ```

* `ActiveSupport::BufferedLogger#flush` está depreciado. Defina a sincronização no seu manipulador de arquivo ou ajuste o seu sistema de arquivos.

Créditos
-------

Veja a [lista completa de contribuidores para o Rails](http://contributors.rubyonrails.org/) para as muitas pessoas que passaram muitas horas fazendo do Rails o framework estável e robusto que ele é. Parabéns a todos eles.

As Notas de Lançamento do Rails 3.2 foram compiladas por [Vijay Dev](https://github.com/vijaydev).
