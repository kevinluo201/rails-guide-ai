**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: fe858c0828e87f595c5d8c23c4b6326e
Usando Rails para Aplicações Apenas de API
===========================================

Neste guia, você aprenderá:

* O que o Rails oferece para aplicações apenas de API
* Como configurar o Rails para iniciar sem recursos de navegador
* Como decidir quais middlewares você deseja incluir
* Como decidir quais módulos usar em seu controlador

--------------------------------------------------------------------------------

O que é uma Aplicação de API?
-----------------------------

Tradicionalmente, quando as pessoas diziam que usavam o Rails como uma "API", elas queriam dizer que forneciam uma API acessível programaticamente ao lado de sua aplicação web. Por exemplo, o GitHub fornece [uma API](https://developer.github.com) que você pode usar em seus próprios clientes personalizados.

Com o surgimento de frameworks do lado do cliente, mais desenvolvedores estão usando o Rails para construir um back-end compartilhado entre sua aplicação web e outras aplicações nativas.

Por exemplo, o Twitter usa sua [API pública](https://developer.twitter.com/) em sua aplicação web, que é construída como um site estático que consome recursos JSON.

Em vez de usar o Rails para gerar HTML que se comunica com o servidor por meio de formulários e links, muitos desenvolvedores estão tratando sua aplicação web apenas como um cliente de API entregue como HTML com JavaScript que consome uma API JSON.

Este guia aborda a construção de uma aplicação Rails que serve recursos JSON para um cliente de API, incluindo frameworks do lado do cliente.

Por que usar o Rails para APIs JSON?
-------------------------------------

A primeira pergunta que muitas pessoas têm ao pensar em construir uma API JSON usando o Rails é: "não é exagero usar o Rails para gerar algum JSON? Não deveria usar algo como o Sinatra?".

Para APIs muito simples, isso pode ser verdade. No entanto, mesmo em aplicações com muito HTML, a maior parte da lógica de uma aplicação vive fora da camada de visualização.

A razão pela qual a maioria das pessoas usa o Rails é que ele fornece um conjunto de padrões que permite que os desenvolvedores comecem a trabalhar rapidamente, sem precisar tomar muitas decisões triviais.

Vamos dar uma olhada em algumas das coisas que o Rails fornece prontamente que ainda são aplicáveis a aplicações de API.

Tratado na camada de middlewares:

- Recarregamento: as aplicações Rails suportam recarregamento transparente. Isso funciona mesmo se sua aplicação ficar grande e reiniciar o servidor para cada solicitação se tornar inviável.
- Modo de desenvolvimento: as aplicações Rails vêm com padrões inteligentes para desenvolvimento, tornando o desenvolvimento agradável sem comprometer o desempenho em tempo de produção.
- Modo de teste: o mesmo vale para o modo de desenvolvimento.
- Registro: as aplicações Rails registram cada solicitação, com um nível de verbosidade adequado ao modo atual. Os registros do Rails em desenvolvimento incluem informações sobre o ambiente da solicitação, consultas ao banco de dados e informações básicas de desempenho.
- Segurança: o Rails detecta e impede ataques de [falsificação de IP](https://en.wikipedia.org/wiki/IP_address_spoofing) e lida com assinaturas criptográficas de maneira consciente a [ataques de tempo](https://en.wikipedia.org/wiki/Timing_attack). Não sabe o que é um ataque de falsificação de IP ou um ataque de tempo? Exatamente.
- Análise de parâmetros: deseja especificar seus parâmetros como JSON em vez de uma String codificada em URL? Sem problemas. O Rails decodificará o JSON para você e o tornará disponível em `params`. Deseja usar parâmetros aninhados codificados em URL? Isso também funciona.
- GETs condicionais: o Rails lida com a verificação condicional `GET` (`ETag` e `Last-Modified`) processando cabeçalhos de solicitação e retornando os cabeçalhos e o código de status corretos da resposta. Tudo o que você precisa fazer é usar a verificação [`stale?`](https://api.rubyonrails.org/classes/ActionController/ConditionalGet.html#method-i-stale-3F) em seu controlador, e o Rails lidará com todos os detalhes HTTP para você.
- Solicitações HEAD: o Rails converterá transparentemente as solicitações `HEAD` em solicitações `GET` e retornará apenas os cabeçalhos na saída. Isso torna o `HEAD` confiável em todas as APIs do Rails.

Embora você possa obviamente construir esses recursos em termos de middlewares Rack existentes, esta lista demonstra que a pilha de middlewares padrão do Rails fornece muito valor, mesmo se você estiver "apenas gerando JSON".

Tratado na camada Action Pack:

- Roteamento de recursos: se você está construindo uma API JSON RESTful, você quer usar o roteador do Rails. Mapeamento limpo e convencional de HTTP para controladores significa não ter que gastar tempo pensando em como modelar sua API em termos de HTTP.
- Geração de URL: o lado oposto do roteamento é a geração de URL. Uma boa API baseada em HTTP inclui URLs (veja [a API de Gist do GitHub](https://docs.github.com/en/rest/reference/gists) como exemplo).
- Respostas de cabeçalho e redirecionamento: `head :no_content` e `redirect_to user_url(current_user)` são úteis. Claro, você poderia adicionar manualmente os cabeçalhos de resposta, mas por que fazer isso?
- Caching: o Rails fornece cache de página, ação e fragmento. O cache de fragmentos é especialmente útil ao construir um objeto JSON aninhado.
- Autenticação básica, digest e de token: o Rails vem com suporte embutido para três tipos de autenticação HTTP.
- Instrumentação: o Rails possui uma API de instrumentação que aciona manipuladores registrados para uma variedade de eventos, como processamento de ação, envio de arquivo ou dados, redirecionamento e consultas ao banco de dados. O payload de cada evento vem com informações relevantes (para o evento de processamento de ação, o payload inclui o controlador, a ação, os parâmetros, o formato da solicitação, o método da solicitação e o caminho completo da solicitação).
- Geradores: é frequentemente útil gerar um recurso e obter seu modelo, controlador, stubs de teste e rotas criados para você em um único comando para ajustes adicionais. O mesmo vale para migrações e outros.
- Plugins: muitas bibliotecas de terceiros vêm com suporte para o Rails que reduzem ou eliminam o custo de configurar e unir a biblioteca e o framework web. Isso inclui coisas como substituir geradores padrão, adicionar tarefas Rake e honrar as escolhas do Rails (como o logger e o back-end de cache).
Claro, o processo de inicialização do Rails também une todos os componentes registrados.
Por exemplo, o processo de inicialização do Rails é o que usa o arquivo `config/database.yml`
ao configurar o Active Record.

**A versão resumida é**: você pode não ter pensado em quais partes do Rails
ainda são aplicáveis mesmo se você remover a camada de visualização, mas a resposta acaba
sendo a maioria delas.

A Configuração Básica
-----------------------

Se você está construindo uma aplicação Rails que será principalmente um servidor de API,
você pode começar com um subconjunto mais limitado do Rails e adicionar recursos
conforme necessário.

### Criando uma Nova Aplicação

Você pode gerar um novo aplicativo Rails para API:

```bash
$ rails new my_api --api
```

Isso fará três coisas principais para você:

- Configurar seu aplicativo para começar com um conjunto mais limitado de middlewares
  do que o normal. Especificamente, ele não incluirá nenhum middleware principalmente útil
  para aplicativos de navegador (como suporte a cookies) por padrão.
- Fazer com que `ApplicationController` herde de `ActionController::API` em vez de
  `ActionController::Base`. Assim como os middlewares, isso deixará de fora quaisquer módulos
  do Action Controller que forneçam funcionalidades usadas principalmente por aplicativos de navegador.
- Configurar os geradores para pular a geração de visualizações, ajudantes e ativos ao
  gerar um novo recurso.

### Gerando um Novo Recurso

Para ver como nossa API recém-criada lida com a geração de um novo recurso, vamos criar
um novo recurso de Grupo. Cada grupo terá um nome.

```bash
$ bin/rails g scaffold Group name:string
```

Antes de podermos usar nosso código gerado, precisamos atualizar nosso esquema de banco de dados.

```bash
$ bin/rails db:migrate
```

Agora, se abrirmos nosso `GroupsController`, devemos notar que, com um aplicativo Rails para API,
estamos renderizando apenas dados JSON. Na ação de índice, consultamos `Group.all`
e atribuímos a uma variável de instância chamada `@groups`. Passá-la para `render` com a
opção `:json` renderizará automaticamente os grupos como JSON.

```ruby
# app/controllers/groups_controller.rb
class GroupsController < ApplicationController
  before_action :set_group, only: %i[ show update destroy ]

  # GET /groups
  def index
    @groups = Group.all

    render json: @groups
  end

  # GET /groups/1
  def show
    render json: @group
  end

  # POST /groups
  def create
    @group = Group.new(group_params)

    if @group.save
      render json: @group, status: :created, location: @group
    else
      render json: @group.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /groups/1
  def update
    if @group.update(group_params)
      render json: @group
    else
      render json: @group.errors, status: :unprocessable_entity
    end
  end

  # DELETE /groups/1
  def destroy
    @group.destroy
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_group
      @group = Group.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def group_params
      params.require(:group).permit(:name)
    end
end
```

Finalmente, podemos adicionar alguns grupos ao nosso banco de dados a partir do console do Rails:

```irb
irb> Group.create(name: "Rails Founders")
irb> Group.create(name: "Rails Contributors")
```

Com alguns dados no aplicativo, podemos iniciar o servidor e visitar <http://localhost:3000/groups.json> para ver nossos dados JSON.

```json
[
{"id":1, "name":"Rails Founders", "created_at": ...},
{"id":2, "name":"Rails Contributors", "created_at": ...}
]
```

### Alterando uma Aplicação Existente

Se você deseja transformar uma aplicação existente em uma aplicação de API, siga as
etapas a seguir.

No arquivo `config/application.rb`, adicione a seguinte linha no topo da definição da classe `Application`:

```ruby
config.api_only = true
```

No arquivo `config/environments/development.rb`, defina [`config.debug_exception_response_format`][]
para configurar o formato usado nas respostas quando ocorrem erros no modo de desenvolvimento.

Para renderizar uma página HTML com informações de depuração, use o valor `:default`.

```ruby
config.debug_exception_response_format = :default
```

Para renderizar informações de depuração preservando o formato de resposta, use o valor `:api`.

```ruby
config.debug_exception_response_format = :api
```

Por padrão, `config.debug_exception_response_format` é definido como `:api`, quando `config.api_only` é definido como true.

Por fim, dentro de `app/controllers/application_controller.rb`, em vez de:

```ruby
class ApplicationController < ActionController::Base
end
```

faça:

```ruby
class ApplicationController < ActionController::API
end
```


Escolhendo Middlewares
--------------------

Uma aplicação de API vem com os seguintes middlewares por padrão:

- `ActionDispatch::HostAuthorization`
- `Rack::Sendfile`
- `ActionDispatch::Static`
- `ActionDispatch::Executor`
- `ActionDispatch::ServerTiming`
- `ActiveSupport::Cache::Strategy::LocalCache::Middleware`
- `Rack::Runtime`
- `ActionDispatch::RequestId`
- `ActionDispatch::RemoteIp`
- `Rails::Rack::Logger`
- `ActionDispatch::ShowExceptions`
- `ActionDispatch::DebugExceptions`
- `ActionDispatch::ActionableExceptions`
- `ActionDispatch::Reloader`
- `ActionDispatch::Callbacks`
- `ActiveRecord::Migration::CheckPending`
- `Rack::Head`
- `Rack::ConditionalGet`
- `Rack::ETag`

Consulte a seção [middleware interno](rails_on_rack.html#internal-middleware-stack)
do guia do Rack para obter mais informações sobre eles.

Outros plugins, incluindo o Active Record, podem adicionar middlewares adicionais. Em
geral, esses middlewares são agnósticos ao tipo de aplicativo que você está
construindo e fazem sentido em um aplicativo Rails apenas para API.
Você pode obter uma lista de todos os middlewares em sua aplicação através de:

```bash
$ bin/rails middleware
```

### Usando Rack::Cache

Quando usado com o Rails, o `Rack::Cache` usa o cache store do Rails para suas
entidades e metadados. Isso significa que se você usar o memcache para o
seu aplicativo Rails, por exemplo, o cache HTTP integrado usará o memcache.

Para usar o `Rack::Cache`, você primeiro precisa adicionar a gema `rack-cache`
ao `Gemfile` e definir `config.action_dispatch.rack_cache` como `true`.
Para habilitar sua funcionalidade, você vai querer usar `stale?` no seu
controlador. Aqui está um exemplo de uso do `stale?`.

```ruby
def show
  @post = Post.find(params[:id])

  if stale?(last_modified: @post.updated_at)
    render json: @post
  end
end
```

A chamada para `stale?` irá comparar o cabeçalho `If-Modified-Since` na requisição
com `@post.updated_at`. Se o cabeçalho for mais recente do que a última modificação, esta
ação retornará uma resposta "304 Not Modified". Caso contrário, irá renderizar a
resposta e incluir um cabeçalho `Last-Modified` nela.

Normalmente, esse mecanismo é usado em uma base por cliente. O `Rack::Cache`
nos permite compartilhar esse mecanismo de cache entre clientes. Podemos habilitar
o cache entre clientes na chamada para `stale?`:

```ruby
def show
  @post = Post.find(params[:id])

  if stale?(last_modified: @post.updated_at, public: true)
    render json: @post
  end
end
```

Isso significa que o `Rack::Cache` irá armazenar o valor `Last-Modified`
para uma URL no cache do Rails e adicionar um cabeçalho `If-Modified-Since` para qualquer
requisição subsequente recebida para a mesma URL.

Pense nisso como cache de página usando semântica HTTP.

### Usando Rack::Sendfile

Quando você usa o método `send_file` dentro de um controlador do Rails, ele define o
cabeçalho `X-Sendfile`. O `Rack::Sendfile` é responsável por enviar o
arquivo de fato.

Se o seu servidor de front-end suportar o envio acelerado de arquivos, o `Rack::Sendfile`
irá delegar o trabalho de envio do arquivo para o servidor de front-end.

Você pode configurar o nome do cabeçalho que o seu servidor de front-end usa para
esse propósito usando [`config.action_dispatch.x_sendfile_header`][] no arquivo de configuração
do ambiente apropriado.

Você pode aprender mais sobre como usar o `Rack::Sendfile` com servidores de front-end populares
na [documentação do Rack::Sendfile](https://www.rubydoc.info/gems/rack/Rack/Sendfile).

Aqui estão alguns valores para esse cabeçalho para alguns servidores populares, uma vez que esses servidores são configurados para suportar
o envio acelerado de arquivos:

```ruby
# Apache e lighttpd
config.action_dispatch.x_sendfile_header = "X-Sendfile"

# Nginx
config.action_dispatch.x_sendfile_header = "X-Accel-Redirect"
```

Certifique-se de configurar o seu servidor para suportar essas opções seguindo as
instruções na documentação do `Rack::Sendfile`.


### Usando ActionDispatch::Request

`ActionDispatch::Request#params` irá pegar os parâmetros do cliente no formato JSON
e torná-los disponíveis no seu controlador dentro de `params`.

Para usar isso, seu cliente precisará fazer uma requisição com parâmetros codificados em JSON
e especificar o `Content-Type` como `application/json`.

Aqui está um exemplo em jQuery:

```js
jQuery.ajax({
  type: 'POST',
  url: '/people',
  dataType: 'json',
  contentType: 'application/json',
  data: JSON.stringify({ person: { firstName: "Yehuda", lastName: "Katz" } }),
  success: function(json) { }
});
```

O `ActionDispatch::Request` irá verificar o `Content-Type` e seus parâmetros
serão:

```ruby
{ person: { firstName: "Yehuda", lastName: "Katz" } }
```

### Usando Middlewares de Sessão

Os seguintes middlewares, usados para gerenciamento de sessão, são excluídos de aplicativos de API, já que normalmente não precisam de sessões. Se um dos seus clientes de API for um navegador, você pode querer adicionar um desses de volta:

- `ActionDispatch::Session::CacheStore`
- `ActionDispatch::Session::CookieStore`
- `ActionDispatch::Session::MemCacheStore`

O truque para adicioná-los de volta é que, por padrão, eles recebem `session_options`
quando adicionados (incluindo a chave da sessão), então você não pode apenas adicionar um inicializador `session_store.rb`, adicionar
`use ActionDispatch::Session::CookieStore` e ter as sessões funcionando como de costume. (Para ser claro: as sessões
podem funcionar, mas suas opções de sessão serão ignoradas - ou seja, a chave da sessão será definida como `_session_id`)

Em vez do inicializador, você terá que definir as opções relevantes em algum lugar antes do seu middleware ser
construído (como `config/application.rb`) e passá-las para o middleware preferido, assim:

```ruby
# Isso também configura session_options para uso abaixo
config.session_store :cookie_store, key: '_interslice_session'

# Necessário para todos os gerenciamentos de sessão (independentemente do session_store)
config.middleware.use ActionDispatch::Cookies

config.middleware.use config.session_store, config.session_options
```

### Outros Middlewares

O Rails vem com vários outros middlewares que você pode querer usar em um
aplicativo de API, especialmente se um dos seus clientes de API for o navegador:

- `Rack::MethodOverride`
- `ActionDispatch::Cookies`
- `ActionDispatch::Flash`

Qualquer um desses middlewares pode ser adicionado via:

```ruby
config.middleware.use Rack::MethodOverride
```

### Removendo Middlewares

Se você não quiser usar um middleware que está incluído por padrão no conjunto de middlewares apenas para API,
você pode removê-lo com:
```ruby
config.middleware.delete ::Rack::Sendfile
```

Tenha em mente que remover esses middlewares removerá o suporte para certos recursos no Action Controller.

Escolhendo Módulos de Controlador
--------------------------------

Uma aplicação de API (usando `ActionController::API`) vem com os seguintes
módulos de controlador por padrão:

|   |   |
|---|---|
| `ActionController::UrlFor` | Torna `url_for` e helpers similares disponíveis. |
| `ActionController::Redirecting` | Suporte para `redirect_to`. |
| `AbstractController::Rendering` e `ActionController::ApiRendering` | Suporte básico para renderização. |
| `ActionController::Renderers::All` | Suporte para `render :json` e amigos. |
| `ActionController::ConditionalGet` | Suporte para `stale?`. |
| `ActionController::BasicImplicitRender` | Garante que uma resposta vazia seja retornada, se não houver uma explícita. |
| `ActionController::StrongParameters` | Suporte para filtragem de parâmetros em combinação com atribuição em massa do Active Model. |
| `ActionController::DataStreaming` | Suporte para `send_file` e `send_data`. |
| `AbstractController::Callbacks` | Suporte para `before_action` e helpers similares. |
| `ActionController::Rescue` | Suporte para `rescue_from`. |
| `ActionController::Instrumentation` | Suporte para os ganchos de instrumentação definidos pelo Action Controller (veja [o guia de instrumentação](active_support_instrumentation.html#action-controller) para mais informações sobre isso). |
| `ActionController::ParamsWrapper` | Envolve o hash de parâmetros em um hash aninhado, para que você não precise especificar elementos raiz ao enviar solicitações POST, por exemplo.
| `ActionController::Head` | Suporte para retornar uma resposta sem conteúdo, apenas cabeçalhos. |

Outros plugins podem adicionar módulos adicionais. Você pode obter uma lista de todos os módulos
incluídos em `ActionController::API` no console do rails:

```irb
irb> ActionController::API.ancestors - ActionController::Metal.ancestors
=> [ActionController::API,
    ActiveRecord::Railties::ControllerRuntime,
    ActionDispatch::Routing::RouteSet::MountedHelpers,
    ActionController::ParamsWrapper,
    ... ,
    AbstractController::Rendering,
    ActionView::ViewPaths]
```

### Adicionando Outros Módulos

Todos os módulos do Action Controller conhecem seus módulos dependentes, então você pode
ficar à vontade para incluir qualquer módulo em seus controladores, e todas as dependências serão
incluídas e configuradas também.

Alguns módulos comuns que você pode querer adicionar:

- `AbstractController::Translation`: Suporte para os métodos de localização e tradução `l` e `t`.
- Suporte para autenticação HTTP básica, digest ou token:
  * `ActionController::HttpAuthentication::Basic::ControllerMethods`
  * `ActionController::HttpAuthentication::Digest::ControllerMethods`
  * `ActionController::HttpAuthentication::Token::ControllerMethods`
- `ActionView::Layouts`: Suporte para layouts ao renderizar.
- `ActionController::MimeResponds`: Suporte para `respond_to`.
- `ActionController::Cookies`: Suporte para `cookies`, que inclui
  suporte para cookies assinados e criptografados. Isso requer o middleware de cookies.
- `ActionController::Caching`: Suporte para cache de visualizações para o controlador da API. Por favor, note
  que você precisará especificar manualmente o armazenamento de cache dentro do controlador, assim:

    ```ruby
    class ApplicationController < ActionController::API
      include ::ActionController::Caching
      self.cache_store = :mem_cache_store
    end
    ```

    O Rails *não* passa essa configuração automaticamente.

O melhor lugar para adicionar um módulo é no seu `ApplicationController`, mas você pode
também adicionar módulos a controladores individuais.
[`config.debug_exception_response_format`]: configuring.html#config-debug-exception-response-format
[`config.action_dispatch.x_sendfile_header`]: configuring.html#config-action-dispatch-x-sendfile-header
