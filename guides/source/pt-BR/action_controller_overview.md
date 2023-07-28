**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 3529115f04b9d5fe01401105d9c154e2
Visão Geral do Action Controller
==========================

Neste guia, você aprenderá como os controladores funcionam e como eles se encaixam no ciclo de solicitação em sua aplicação.

Após ler este guia, você saberá como:

* Seguir o fluxo de uma solicitação através de um controlador.
* Restringir os parâmetros passados para o seu controlador.
* Armazenar dados na sessão ou cookies, e por quê.
* Trabalhar com filtros para executar código durante o processamento da solicitação.
* Usar a autenticação HTTP incorporada do Action Controller.
* Transmitir dados diretamente para o navegador do usuário.
* Filtrar parâmetros sensíveis para que não apareçam no log da aplicação.
* Lidar com exceções que podem ser levantadas durante o processamento da solicitação.
* Usar o ponto de extremidade de verificação de saúde incorporado para balanceadores de carga e monitores de tempo de atividade.

--------------------------------------------------------------------------------

O que um Controlador faz?
--------------------------

O Action Controller é o C no [MVC](https://en.wikipedia.org/wiki/Model%E2%80%93view%E2%80%93controller). Depois que o roteador determina qual controlador usar para uma solicitação, o controlador é responsável por entender a solicitação e produzir a saída apropriada. Felizmente, o Action Controller faz a maior parte do trabalho para você e usa convenções inteligentes para tornar isso o mais simples possível.

Para a maioria das aplicações [RESTful](https://en.wikipedia.org/wiki/Representational_state_transfer) convencionais, o controlador receberá a solicitação (isso é invisível para você como desenvolvedor), buscará ou salvará dados de um modelo e usará uma visualização para criar a saída HTML. Se o seu controlador precisar fazer algo um pouco diferente, isso não é um problema, essa é apenas a maneira mais comum de um controlador funcionar.

Assim, um controlador pode ser considerado como um intermediário entre modelos e visualizações. Ele torna os dados do modelo disponíveis para a visualização, para que possa exibir esses dados ao usuário, e salva ou atualiza os dados do usuário no modelo.

NOTA: Para mais detalhes sobre o processo de roteamento, consulte [Rails Routing from the Outside In](routing.html).

Convenção de Nomenclatura do Controlador
----------------------------

A convenção de nomenclatura dos controladores no Rails favorece a pluralização da última palavra no nome do controlador, embora isso não seja estritamente necessário (por exemplo, `ApplicationController`). Por exemplo, `ClientsController` é preferível a `ClientController`, `SiteAdminsController` é preferível a `SiteAdminController` ou `SitesAdminsController`, e assim por diante.

Seguir essa convenção permitirá que você use os geradores de rotas padrão (por exemplo, `resources`, etc) sem precisar qualificar cada `:path` ou `:controller`, e manterá o uso consistente dos auxiliares de rotas nomeadas em toda a sua aplicação. Consulte [Layouts and Rendering Guide](layouts_and_rendering.html) para mais detalhes.

NOTA: A convenção de nomenclatura do controlador difere da convenção de nomenclatura dos modelos, que devem ter nomes no singular.

Métodos e Ações
-------------------

Um controlador é uma classe Ruby que herda de `ApplicationController` e possui métodos como qualquer outra classe. Quando sua aplicação recebe uma solicitação, o roteamento determinará qual controlador e ação executar, então o Rails criará uma instância desse controlador e executará o método com o mesmo nome da ação.

```ruby
class ClientsController < ApplicationController
  def new
  end
end
```

Como exemplo, se um usuário acessar `/clients/new` em sua aplicação para adicionar um novo cliente, o Rails criará uma instância de `ClientsController` e chamará seu método `new`. Observe que o método vazio do exemplo acima funcionaria muito bem porque o Rails, por padrão, renderizará a visualização `new.html.erb` a menos que a ação diga o contrário. Ao criar um novo `Client`, o método `new` pode tornar uma variável de instância `@client` acessível na visualização:

```ruby
def new
  @client = Client.new
end
```

O [Layouts and Rendering Guide](layouts_and_rendering.html) explica isso com mais detalhes.

`ApplicationController` herda de [`ActionController::Base`][], que define vários métodos úteis. Este guia abordará alguns deles, mas se você estiver curioso para ver o que está lá, pode ver todos eles na [documentação da API](https://api.rubyonrails.org/classes/ActionController.html) ou no próprio código-fonte.

Somente métodos públicos podem ser chamados como ações. É uma boa prática reduzir a visibilidade dos métodos (com `private` ou `protected`) que não se destinam a ser ações, como métodos auxiliares ou filtros.

ATENÇÃO: Alguns nomes de métodos são reservados pelo Action Controller. Redefinir acidentalmente eles como ações, ou até mesmo como métodos auxiliares, pode resultar em um `SystemStackError`. Se você limitar seus controladores apenas a ações de [Resource Routing][] RESTful, você não precisará se preocupar com isso.

NOTA: Se você precisar usar um método reservado como nome de ação, uma solução alternativa é usar uma rota personalizada para mapear o nome do método reservado para o seu método de ação não reservado.
[Roteamento de Recursos]: routing.html#resource-routing-o-padrao-do-rails

Parâmetros
----------

Provavelmente você vai querer acessar os dados enviados pelo usuário ou outros parâmetros em suas ações do controlador. Existem dois tipos de parâmetros possíveis em uma aplicação web. O primeiro são os parâmetros que são enviados como parte da URL, chamados de parâmetros de string de consulta. A string de consulta é tudo depois de "?" na URL. O segundo tipo de parâmetro é geralmente chamado de dados POST. Essas informações geralmente vêm de um formulário HTML preenchido pelo usuário. É chamado de dados POST porque só pode ser enviado como parte de uma solicitação HTTP POST. O Rails não faz nenhuma distinção entre parâmetros de string de consulta e parâmetros POST, e ambos estão disponíveis no hash [`params`][] no seu controlador:

```ruby
class ClientsController < ApplicationController
  # Esta ação usa parâmetros de string de consulta porque é executada
  # por uma solicitação HTTP GET, mas isso não faz diferença
  # para como os parâmetros são acessados. A URL para
  # esta ação seria assim para listar clientes ativados: /clients?status=activated
  def index
    if params[:status] == "activated"
      @clients = Client.activated
    else
      @clients = Client.inactivated
    end
  end

  # Esta ação usa parâmetros POST. Eles provavelmente estão vindo
  # de um formulário HTML que o usuário enviou. A URL para
  # esta solicitação RESTful será "/clients", e os dados serão
  # enviados como parte do corpo da solicitação.
  def create
    @client = Client.new(params[:client])
    if @client.save
      redirect_to @client
    else
      # Esta linha substitui o comportamento de renderização padrão, que
      # seria renderizar a visualização "create".
      render "new"
    end
  end
end
```


### Parâmetros de Hash e Array

O hash `params` não se limita a chaves e valores unidimensionais. Ele pode conter matrizes e hashes aninhados. Para enviar uma matriz de valores, adicione um par de colchetes vazios "[]" ao nome da chave:

```
GET /clients?ids[]=1&ids[]=2&ids[]=3
```

NOTA: A URL real neste exemplo será codificada como "/clients?ids%5b%5d=1&ids%5b%5d=2&ids%5b%5d=3" porque os caracteres "[" e "]" não são permitidos em URLs. Na maioria das vezes, você não precisa se preocupar com isso porque o navegador irá codificá-lo para você, e o Rails irá decodificá-lo automaticamente, mas se você se encontrar tendo que enviar essas solicitações manualmente para o servidor, você deve ter isso em mente.

O valor de `params[:ids]` agora será `["1", "2", "3"]`. Observe que os valores dos parâmetros são sempre strings; o Rails não tenta adivinhar ou converter o tipo.

NOTA: Valores como `[nil]` ou `[nil, nil, ...]` em `params` são substituídos
por `[]` por motivos de segurança por padrão. Consulte o [Guia de Segurança](security.html#unsafe-query-generation)
para obter mais informações.

Para enviar um hash, você inclui o nome da chave entre colchetes:

```html
<form accept-charset="UTF-8" action="/clients" method="post">
  <input type="text" name="client[name]" value="Acme" />
  <input type="text" name="client[phone]" value="12345" />
  <input type="text" name="client[address][postcode]" value="12345" />
  <input type="text" name="client[address][city]" value="Carrot City" />
</form>
```

Quando este formulário é enviado, o valor de `params[:client]` será `{ "name" => "Acme", "phone" => "12345", "address" => { "postcode" => "12345", "city" => "Carrot City" } }`. Observe o hash aninhado em `params[:client][:address]`.

O objeto `params` age como um Hash, mas permite que você use símbolos e strings de forma intercambiável como chaves.

### Parâmetros JSON

Se sua aplicação expõe uma API, é provável que você esteja aceitando parâmetros no formato JSON. Se o cabeçalho "Content-Type" da sua solicitação estiver definido como "application/json", o Rails carregará automaticamente seus parâmetros no hash `params`, que você pode acessar normalmente.

Então, por exemplo, se você estiver enviando este conteúdo JSON:

```json
{ "company": { "name": "acme", "address": "123 Carrot Street" } }
```

Seu controlador receberá `params[:company]` como `{ "name" => "acme", "address" => "123 Carrot Street" }`.

Além disso, se você ativou `config.wrap_parameters` em seu inicializador ou chamou [`wrap_parameters`][] em seu controlador, você pode omitir com segurança o elemento raiz no parâmetro JSON. Nesse caso, os parâmetros serão clonados e envolvidos com uma chave escolhida com base no nome do seu controlador. Portanto, a solicitação JSON acima pode ser escrita como:

```json
{ "name": "acme", "address": "123 Carrot Street" }
```

E, supondo que você esteja enviando os dados para `CompaniesController`, eles serão envolvidos na chave `:company` assim:
```ruby
{ name: "acme", address: "123 Carrot Street", company: { name: "acme", address: "123 Carrot Street" } }
```

Você pode personalizar o nome da chave ou parâmetros específicos que deseja envolver consultando a [documentação da API](https://api.rubyonrails.org/classes/ActionController/ParamsWrapper.html)

NOTA: O suporte para análise de parâmetros XML foi extraído para uma gem chamada `actionpack-xml_parser`.


### Parâmetros de Roteamento

O hash `params` sempre conterá as chaves `:controller` e `:action`, mas você deve usar os métodos [`controller_name`][] e [`action_name`][] para acessar esses valores. Quaisquer outros parâmetros definidos pelo roteamento, como `:id`, também estarão disponíveis. Como exemplo, considere uma lista de clientes onde a lista pode mostrar clientes ativos ou inativos. Podemos adicionar uma rota que captura o parâmetro `:status` em uma URL "bonita":

```ruby
get '/clients/:status', to: 'clients#index', foo: 'bar'
```

Neste caso, quando um usuário abre a URL `/clients/active`, `params[:status]` será definido como "active". Quando esta rota é usada, `params[:foo]` também será definido como "bar", como se fosse passado na string de consulta. Seu controlador também receberá `params[:action]` como "index" e `params[:controller]` como "clients".


### `default_url_options`

Você pode definir parâmetros padrão globais para geração de URL definindo um método chamado `default_url_options` em seu controlador. Esse método deve retornar um hash com os padrões desejados, cujas chaves devem ser símbolos:

```ruby
class ApplicationController < ActionController::Base
  def default_url_options
    { locale: I18n.locale }
  end
end
```

Essas opções serão usadas como ponto de partida ao gerar URLs, portanto, é possível que sejam substituídas pelas opções passadas para chamadas `url_for`.

Se você definir `default_url_options` em `ApplicationController`, como no exemplo acima, esses padrões serão usados para toda a geração de URL. O método também pode ser definido em um controlador específico, nesse caso, afetará apenas as URLs geradas lá.

Em uma determinada solicitação, o método não é realmente chamado para cada URL gerada. Por motivos de desempenho, o hash retornado é armazenado em cache e há no máximo uma invocação por solicitação.

### Parâmetros Fortes

Com parâmetros fortes, os parâmetros do Action Controller são proibidos de serem usados em atribuições em massa do Active Model até que tenham sido permitidos. Isso significa que você terá que tomar uma decisão consciente sobre quais atributos permitir para atualização em massa. Essa é uma prática de segurança melhor para ajudar a evitar permitir acidentalmente que os usuários atualizem atributos sensíveis do modelo.

Além disso, os parâmetros podem ser marcados como obrigatórios e passarão por um fluxo de exceção pré-definido que resultará em um retorno de erro 400 Bad Request se nem todos os parâmetros obrigatórios forem passados.

```ruby
class PeopleController < ActionController::Base
  # Isso levantará uma exceção ActiveModel::ForbiddenAttributesError
  # porque está usando atribuição em massa sem uma etapa de permissão
  # explícita.
  def create
    Person.create(params[:person])
  end

  # Isso passará com sucesso desde que haja uma chave person
  # nos parâmetros, caso contrário, levantará uma exceção
  # ActionController::ParameterMissing, que será capturada
  # por ActionController::Base e convertida em um erro 400 Bad
  # Request.
  def update
    person = current_account.people.find(params[:id])
    person.update!(person_params)
    redirect_to person
  end

  private
    # Usar um método privado para encapsular os parâmetros permitidos
    # é apenas um bom padrão, pois você poderá reutilizar a mesma
    # lista de permissões entre create e update. Além disso, você pode
    # especializar esse método com verificação de atributos permitidos
    # por usuário.
    def person_params
      params.require(:person).permit(:name, :age)
    end
end
```

#### Valores Escalares Permitidos

Chamar [`permit`][] assim:

```ruby
params.permit(:id)
```

permite a inclusão da chave especificada (`:id`) se ela aparecer em `params` e
tiver um valor escalar permitido associado. Caso contrário, a chave será filtrada,
portanto, arrays, hashes ou qualquer outro objeto não podem ser injetados.

Os tipos escalares permitidos são `String`, `Symbol`, `NilClass`,
`Numeric`, `TrueClass`, `FalseClass`, `Date`, `Time`, `DateTime`,
`StringIO`, `IO`, `ActionDispatch::Http::UploadedFile` e
`Rack::Test::UploadedFile`.

Para declarar que o valor em `params` deve ser um array de valores escalares permitidos,
mapeie a chave para um array vazio:

```ruby
params.permit(id: [])
```

Às vezes, não é possível ou conveniente declarar as chaves válidas de
um parâmetro hash ou sua estrutura interna. Basta mapear para um hash vazio:

```ruby
params.permit(preferences: {})
```

mas tenha cuidado, pois isso abre a porta para entrada arbitrária. Nesse
caso, `permit` garante que os valores na estrutura retornada sejam escalares permitidos
e filtra qualquer outra coisa.
Para permitir um hash inteiro de parâmetros, o método [`permit!`][] pode ser usado:

```ruby
params.require(:log_entry).permit!
```

Isso marca o hash de parâmetros `:log_entry` e qualquer sub-hash como permitido e não verifica os escalares permitidos, qualquer coisa é aceita. Deve-se ter muito cuidado ao usar `permit!`, pois isso permitirá que todos os atributos do modelo atuais e futuros sejam atribuídos em massa.

#### Parâmetros Aninhados

Você também pode usar `permit` em parâmetros aninhados, como:

```ruby
params.permit(:name, { emails: [] },
              friends: [ :name,
                         { family: [ :name ], hobbies: [] }])
```

Essa declaração permite os atributos `name`, `emails` e `friends`. É esperado que `emails` seja uma matriz de valores escalares permitidos e que `friends` seja uma matriz de recursos com atributos específicos: eles devem ter um atributo `name` (quaisquer valores escalares permitidos permitidos), um atributo `hobbies` como uma matriz de valores escalares permitidos e um atributo `family` que é restrito a ter um `name` (quaisquer valores escalares permitidos permitidos aqui também).

#### Mais Exemplos

Você também pode querer usar os atributos permitidos em sua ação `new`. Isso levanta o problema de que você não pode usar [`require`][] na chave raiz porque, normalmente, ela não existe ao chamar `new`:

```ruby
# usando `fetch` você pode fornecer um valor padrão e usar
# a API de Strong Parameters a partir daí.
params.fetch(:blog, {}).permit(:title, :author)
```

O método de classe do modelo `accepts_nested_attributes_for` permite que você atualize e exclua registros associados. Isso é baseado nos parâmetros `id` e `_destroy`:

```ruby
# permitir :id e :_destroy
params.require(:author).permit(:name, books_attributes: [:title, :id, :_destroy])
```

Hashes com chaves inteiras são tratados de forma diferente e você pode declarar os atributos como se fossem filhos diretos. Você obtém esse tipo de parâmetros quando usa `accepts_nested_attributes_for` em combinação com uma associação `has_many`:

```ruby
# Para permitir os seguintes dados:
# {"book" => {"title" => "Some Book",
#             "chapters_attributes" => { "1" => {"title" => "First Chapter"},
#                                        "2" => {"title" => "Second Chapter"}}}}

params.require(:book).permit(:title, chapters_attributes: [:title])
```

Imagine um cenário em que você tem parâmetros representando o nome de um produto e um hash de dados arbitrários associados a esse produto, e você deseja permitir o atributo de nome do produto e também o hash de dados completo:

```ruby
def product_params
  params.require(:product).permit(:name, data: {})
end
```

#### Fora do Escopo dos Strong Parameters

A API de parâmetros fortes foi projetada com os casos de uso mais comuns em mente. Não se destina a ser uma solução universal para lidar com todos os seus problemas de filtragem de parâmetros. No entanto, você pode facilmente misturar a API com seu próprio código para se adaptar à sua situação.

Sessão
-------

Sua aplicação possui uma sessão para cada usuário na qual você pode armazenar pequenas quantidades de dados que serão persistidos entre as requisições. A sessão está disponível apenas no controlador e na visualização e pode usar um dos vários mecanismos de armazenamento diferentes:

* [`ActionDispatch::Session::CookieStore`][] - Armazena tudo no cliente.
* [`ActionDispatch::Session::CacheStore`][] - Armazena os dados no cache do Rails.
* [`ActionDispatch::Session::MemCacheStore`][] - Armazena os dados em um cluster memcached (esta é uma implementação legada; considere usar `CacheStore` em vez disso).
* [`ActionDispatch::Session::ActiveRecordStore`][activerecord-session_store] -
  Armazena os dados em um banco de dados usando o Active Record (requer o
  gem [`activerecord-session_store`][activerecord-session_store])
* Um armazenamento personalizado ou um armazenamento fornecido por um gem de terceiros

Todos os armazenamentos de sessão usam um cookie para armazenar um ID exclusivo para cada sessão (você deve usar um cookie, o Rails não permitirá que você passe o ID da sessão na URL, pois isso é menos seguro).

Para a maioria dos armazenamentos, esse ID é usado para procurar os dados da sessão no servidor, por exemplo, em uma tabela de banco de dados. Há uma exceção, que é o armazenamento de sessão padrão e recomendado - o CookieStore - que armazena todos os dados da sessão no próprio cookie (o ID ainda está disponível se você precisar dele). Isso tem a vantagem de ser muito leve e não requer nenhuma configuração em um novo aplicativo para usar a sessão. Os dados do cookie são assinados criptograficamente para torná-los à prova de adulteração. Eles também são criptografados para que ninguém com acesso a eles possa ler seu conteúdo (o Rails não aceitará se ele tiver sido editado).

O CookieStore pode armazenar cerca de 4 kB de dados - muito menos que os outros - mas isso geralmente é suficiente. Armazenar grandes quantidades de dados na sessão é desencorajado, independentemente do armazenamento de sessão usado em seu aplicativo. Você deve evitar especialmente armazenar objetos complexos (como instâncias de modelo) na sessão, pois o servidor pode não ser capaz de reuni-los entre as requisições, o que resultará em um erro.
Se suas sessões de usuário não armazenam dados críticos ou não precisam estar disponíveis por longos períodos (por exemplo, se você usa o flash apenas para mensagens), você pode considerar o uso de `ActionDispatch::Session::CacheStore`. Isso armazenará as sessões usando a implementação de cache configurada para sua aplicação. A vantagem disso é que você pode usar sua infraestrutura de cache existente para armazenar as sessões sem precisar de qualquer configuração ou administração adicional. A desvantagem, é claro, é que as sessões serão efêmeras e podem desaparecer a qualquer momento.

Leia mais sobre o armazenamento de sessão no [Guia de Segurança](security.html).

Se você precisar de um mecanismo de armazenamento de sessão diferente, você pode alterá-lo em um inicializador:

```ruby
Rails.application.config.session_store :cache_store
```

Consulte [`config.session_store`](configuring.html#config-session-store) no guia de configuração para obter mais informações.

O Rails configura uma chave de sessão (o nome do cookie) ao assinar os dados da sessão. Essas chaves também podem ser alteradas em um inicializador:

```ruby
# Certifique-se de reiniciar o servidor quando modificar este arquivo.
Rails.application.config.session_store :cookie_store, key: '_your_app_session'
```

Você também pode passar uma chave `:domain` e especificar o nome do domínio para o cookie:

```ruby
# Certifique-se de reiniciar o servidor quando modificar este arquivo.
Rails.application.config.session_store :cookie_store, key: '_your_app_session', domain: ".example.com"
```

O Rails configura (para o CookieStore) uma chave secreta usada para assinar os dados da sessão em `config/credentials.yml.enc`. Isso pode ser alterado com `bin/rails credentials:edit`.

```yaml
# aws:
#   access_key_id: 123
#   secret_access_key: 345

# Usado como segredo base para todos os MessageVerifiers no Rails, incluindo o que protege os cookies.
secret_key_base: 492f...
```

NOTA: Alterar o secret_key_base ao usar o `CookieStore` invalidará todas as sessões existentes.



### Acessando a Sessão

Em seu controlador, você pode acessar a sessão através do método de instância `session`.

NOTA: As sessões são carregadas de forma preguiçosa. Se você não acessar as sessões no código da sua ação, elas não serão carregadas. Portanto, você nunca precisará desabilitar as sessões, apenas não acessá-las fará o trabalho.

Os valores da sessão são armazenados usando pares chave/valor como um hash:

```ruby
class ApplicationController < ActionController::Base
  private
    # Encontra o Usuário com o ID armazenado na sessão com a chave
    # :current_user_id. Esta é uma forma comum de lidar com o login do usuário em
    # uma aplicação Rails; fazer login define o valor da sessão e
    # fazer logout remove-o.
    def current_user
      @_current_user ||= session[:current_user_id] &&
        User.find_by(id: session[:current_user_id])
    end
end
```

Para armazenar algo na sessão, basta atribuí-lo à chave como um hash:

```ruby
class LoginsController < ApplicationController
  # "Criar" um login, também conhecido como "fazer login do usuário"
  def create
    if user = User.authenticate(params[:username], params[:password])
      # Salva o ID do usuário na sessão para que possa ser usado em
      # solicitações subsequentes
      session[:current_user_id] = user.id
      redirect_to root_url
    end
  end
end
```

Para remover algo da sessão, exclua o par chave/valor:

```ruby
class LoginsController < ApplicationController
  # "Excluir" um login, também conhecido como "fazer logout do usuário"
  def destroy
    # Remove o ID do usuário da sessão
    session.delete(:current_user_id)
    # Limpa o usuário atual memoizado
    @_current_user = nil
    redirect_to root_url, status: :see_other
  end
end
```

Para redefinir toda a sessão, use [`reset_session`][].


### O Flash

O flash é uma parte especial da sessão que é limpa a cada solicitação. Isso significa que os valores armazenados lá só estarão disponíveis na próxima solicitação, o que é útil para passar mensagens de erro, etc.

O flash é acessado através do método [`flash`][]. Assim como a sessão, o flash é representado como um hash.

Vamos usar o ato de fazer logout como exemplo. O controlador pode enviar uma mensagem que será exibida ao usuário na próxima solicitação:

```ruby
class LoginsController < ApplicationController
  def destroy
    session.delete(:current_user_id)
    flash[:notice] = "Você fez logout com sucesso."
    redirect_to root_url, status: :see_other
  end
end
```

Observe que também é possível atribuir uma mensagem flash como parte da redireção. Você pode atribuir `:notice`, `:alert` ou o `:flash` de propósito geral:

```ruby
redirect_to root_url, notice: "Você fez logout com sucesso."
redirect_to root_url, alert: "Você está preso aqui!"
redirect_to root_url, flash: { referral_code: 1234 }
```

A ação `destroy` redireciona para o `root_url` da aplicação, onde a mensagem será exibida. Observe que cabe inteiramente à próxima ação decidir o que, se alguma coisa, ela fará com o que a ação anterior colocou no flash. É convencional exibir quaisquer alertas de erro ou avisos do flash no layout da aplicação.
```erb
<html>
  <!-- <head/> -->
  <body>
    <% flash.each do |name, msg| -%>
      <%= content_tag :div, msg, class: name %>
    <% end -%>

    <!-- more content -->
  </body>
</html>
```

Dessa forma, se uma ação definir uma mensagem de aviso ou alerta, o layout irá exibi-la automaticamente.

Você pode passar qualquer coisa que a sessão possa armazenar; você não está limitado a avisos e alertas:

```erb
<% if flash[:just_signed_up] %>
  <p class="welcome">Bem-vindo ao nosso site!</p>
<% end %>
```

Se você deseja que um valor flash seja mantido para outra requisição, use [`flash.keep`][]:

```ruby
class MainController < ApplicationController
  # Vamos supor que essa ação corresponda a root_url, mas você deseja
  # que todas as requisições aqui sejam redirecionadas para UsersController#index.
  # Se uma ação definir o flash e redirecionar para cá, os valores
  # normalmente seriam perdidos quando outro redirecionamento ocorresse, mas você
  # pode usar 'keep' para mantê-lo para outra requisição.
  def index
    # Irá manter todos os valores do flash.
    flash.keep

    # Você também pode usar uma chave para manter apenas um tipo de valor.
    # flash.keep(:notice)
    redirect_to users_url
  end
end
```


#### `flash.now`

Por padrão, adicionar valores ao flash os tornará disponíveis para a próxima requisição, mas às vezes você pode querer acessar esses valores na mesma requisição. Por exemplo, se a ação `create` falhar ao salvar um recurso e você renderizar diretamente o template `new`, isso não resultará em uma nova requisição, mas você ainda pode querer exibir uma mensagem usando o flash. Para fazer isso, você pode usar [`flash.now`][] da mesma forma que usa o flash normal:

```ruby
class ClientsController < ApplicationController
  def create
    @client = Client.new(client_params)
    if @client.save
      # ...
    else
      flash.now[:error] = "Não foi possível salvar o cliente"
      render action: "new"
    end
  end
end
```


Cookies
-------

Sua aplicação pode armazenar pequenas quantidades de dados no cliente - chamados de cookies - que serão persistidos em requisições e até mesmo sessões. O Rails fornece acesso fácil aos cookies através do método [`cookies`][], que - assim como a `session` - funciona como um hash:

```ruby
class CommentsController < ApplicationController
  def new
    # Preencha automaticamente o nome do comentador se ele tiver sido armazenado em um cookie
    @comment = Comment.new(author: cookies[:commenter_name])
  end

  def create
    @comment = Comment.new(comment_params)
    if @comment.save
      flash[:notice] = "Obrigado pelo seu comentário!"
      if params[:remember_name]
        # Lembre-se do nome do comentador.
        cookies[:commenter_name] = @comment.author
      else
        # Exclua o cookie para o nome do comentador, se houver.
        cookies.delete(:commenter_name)
      end
      redirect_to @comment.article
    else
      render action: "new"
    end
  end
end
```

Observe que, enquanto para valores de sessão você pode definir a chave como `nil`, para excluir um valor de cookie você deve usar `cookies.delete(:chave)`.

O Rails também fornece um pote de cookies assinado e um pote de cookies criptografado para armazenar
dados sensíveis. O pote de cookies assinado anexa uma assinatura criptográfica nos
valores dos cookies para proteger sua integridade. O pote de cookies criptografado criptografa os
valores além de assiná-los, para que não possam ser lidos pelo usuário final.
Consulte a [documentação da API](https://api.rubyonrails.org/classes/ActionDispatch/Cookies.html)
para mais detalhes.

Esses potes de cookies especiais usam um serializador para serializar os valores atribuídos em
strings e desserializá-los em objetos Ruby na leitura. Você pode especificar qual
serializador usar através de [`config.action_dispatch.cookies_serializer`][].

O serializador padrão para novas aplicações é `:json`. Esteja ciente de que o JSON tem
suporte limitado para objetos Ruby. Por exemplo, objetos `Date`, `Time` e
`Symbol` (incluindo chaves de `Hash`) serão serializados e desserializados
em `String`s:

```ruby
class CookiesController < ApplicationController
  def set_cookie
    cookies.encrypted[:expiration_date] = Date.tomorrow # => Thu, 20 Mar 2014
    redirect_to action: 'read_cookie'
  end

  def read_cookie
    cookies.encrypted[:expiration_date] # => "2014-03-20"
  end
end
```

Se você precisar armazenar esses objetos ou objetos mais complexos, talvez seja necessário
converter manualmente seus valores ao lê-los em requisições subsequentes.

Se você usar o armazenamento de sessão em cookie, o acima se aplica ao hash `session` e
`flash` também.


Renderização
---------

ActionController torna a renderização de dados HTML, XML ou JSON fácil. Se você gerou um controlador usando o scaffolding, ele ficaria assim:

```ruby
class UsersController < ApplicationController
  def index
    @users = User.all
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render xml: @users }
      format.json { render json: @users }
    end
  end
end
```

Você pode notar no código acima que estamos usando `render xml: @users`, não `render xml: @users.to_xml`. Se o objeto não for uma String, o Rails automaticamente invocará `to_xml` para nós.
Você pode aprender mais sobre renderização no [Guia de Layouts e Renderização](layouts_and_rendering.html).

Filtros
-------

Filtros são métodos que são executados "antes", "depois" ou "ao redor" de uma ação do controlador.

Os filtros são herdados, então se você definir um filtro no `ApplicationController`, ele será executado em todos os controladores da sua aplicação.

Filtros "antes" são registrados via [`before_action`][]. Eles podem interromper o ciclo da requisição. Um filtro "antes" comum é aquele que requer que um usuário esteja logado para que uma ação seja executada. Você pode definir o método do filtro desta forma:

```ruby
class ApplicationController < ActionController::Base
  before_action :require_login

  private
    def require_login
      unless logged_in?
        flash[:error] = "Você precisa estar logado para acessar esta seção"
        redirect_to new_login_url # interrompe o ciclo da requisição
      end
    end
end
```

O método simplesmente armazena uma mensagem de erro no flash e redireciona para o formulário de login se o usuário não estiver logado. Se um filtro "antes" renderizar ou redirecionar, a ação não será executada. Se houver filtros adicionais agendados para serem executados após esse filtro, eles também serão cancelados.

Neste exemplo, o filtro é adicionado ao `ApplicationController` e, portanto, todos os controladores da aplicação o herdam. Isso fará com que tudo na aplicação exija que o usuário esteja logado para usá-lo. Por motivos óbvios (o usuário não poderia fazer login em primeiro lugar!), nem todos os controladores ou ações devem exigir isso. Você pode impedir que esse filtro seja executado antes de ações específicas com [`skip_before_action`][]:

```ruby
class LoginsController < ApplicationController
  skip_before_action :require_login, only: [:new, :create]
end
```

Agora, as ações `new` e `create` do `LoginsController` funcionarão como antes, sem exigir que o usuário esteja logado. A opção `:only` é usada para pular esse filtro apenas para essas ações, e também há uma opção `:except` que funciona de forma oposta. Essas opções também podem ser usadas ao adicionar filtros, para que você possa adicionar um filtro que só é executado para ações selecionadas em primeiro lugar.

NOTA: Chamar o mesmo filtro várias vezes com opções diferentes não funcionará,
pois a última definição do filtro substituirá as anteriores.


### Filtros "Depois" e Filtros "Ao Redor"

Além dos filtros "antes", você também pode executar filtros depois que uma ação foi executada, ou tanto antes quanto depois.

Filtros "depois" são registrados via [`after_action`][]. Eles são semelhantes aos filtros "antes", mas porque a ação já foi executada, eles têm acesso aos dados de resposta que estão prestes a serem enviados ao cliente. Obviamente, os filtros "depois" não podem impedir a execução da ação. Observe que os filtros "depois" são executados apenas após uma ação bem-sucedida, mas não quando uma exceção é lançada no ciclo da requisição.

Filtros "ao redor" são registrados via [`around_action`][]. Eles são responsáveis por executar suas ações associadas por meio de um `yield`, semelhante ao funcionamento dos middlewares do Rack.

Por exemplo, em um site onde as alterações têm um fluxo de aprovação, um administrador poderia visualizá-las facilmente aplicando-as dentro de uma transação:

```ruby
class ChangesController < ApplicationController
  around_action :wrap_in_transaction, only: :show

  private
    def wrap_in_transaction
      ActiveRecord::Base.transaction do
        begin
          yield
        ensure
          raise ActiveRecord::Rollback
        end
      end
    end
end
```

Observe que um filtro "ao redor" também envolve a renderização. Em particular, no exemplo acima, se a própria visualização ler do banco de dados (por exemplo, por meio de um escopo), ela o fará dentro da transação e, portanto, apresentará os dados para visualização.

Você pode optar por não fazer um `yield` e construir a resposta você mesmo, nesse caso a ação não será executada.


### Outras Formas de Usar Filtros

Embora a forma mais comum de usar filtros seja criando métodos privados e usando `before_action`, `after_action` ou `around_action` para adicioná-los, existem outras duas maneiras de fazer a mesma coisa.

A primeira é usar um bloco diretamente com os métodos `*_action`. O bloco recebe o controlador como argumento. O filtro `require_login` do exemplo acima poderia ser reescrito para usar um bloco:

```ruby
class ApplicationController < ActionController::Base
  before_action do |controller|
    unless controller.send(:logged_in?)
      flash[:error] = "Você precisa estar logado para acessar esta seção"
      redirect_to new_login_url
    end
  end
end
```

Observe que o filtro, neste caso, usa `send` porque o método `logged_in?` é privado e o filtro não é executado no escopo do controlador. Esta não é a forma recomendada de implementar esse filtro específico, mas em casos mais simples, pode ser útil.
Especificamente para `around_action`, o bloco também é executado na `action`:

```ruby
around_action { |_controller, action| time(&action) }
```

A segunda maneira é usar uma classe (na verdade, qualquer objeto que responda aos métodos corretos servirá) para lidar com o filtro. Isso é útil em casos mais complexos que não podem ser implementados de maneira legível e reutilizável usando os outros dois métodos. Como exemplo, você pode reescrever o filtro de login novamente para usar uma classe:

```ruby
class ApplicationController < ActionController::Base
  before_action LoginFilter
end

class LoginFilter
  def self.before(controller)
    unless controller.send(:logged_in?)
      controller.flash[:error] = "Você precisa estar logado para acessar esta seção"
      controller.redirect_to controller.new_login_url
    end
  end
end
```

Novamente, este não é um exemplo ideal para este filtro, porque ele não é executado no escopo do controlador, mas recebe o controlador como argumento. A classe do filtro deve implementar um método com o mesmo nome do filtro, então para o filtro `before_action`, a classe deve implementar um método `before`, e assim por diante. O método `around` deve `yield` para executar a ação.

Proteção contra falsificação de solicitação
-------------------------------------------

A falsificação de solicitação entre sites é um tipo de ataque no qual um site engana um usuário a fazer solicitações em outro site, possivelmente adicionando, modificando ou excluindo dados nesse site sem o conhecimento ou permissão do usuário.

O primeiro passo para evitar isso é garantir que todas as ações "destrutivas" (criar, atualizar e excluir) só possam ser acessadas com solicitações não-GET. Se você estiver seguindo as convenções RESTful, já estará fazendo isso. No entanto, um site malicioso ainda pode enviar facilmente uma solicitação não-GET para o seu site, e é aí que entra a proteção contra falsificação de solicitação. Como o nome diz, ela protege contra solicitações falsificadas.

A maneira como isso é feito é adicionando um token não adivinhável, que só é conhecido pelo seu servidor, a cada solicitação. Dessa forma, se uma solicitação chegar sem o token adequado, o acesso será negado.

Se você gerar um formulário assim:

```erb
<%= form_with model: @user do |form| %>
  <%= form.text_field :username %>
  <%= form.text_field :password %>
<% end %>
```

Você verá como o token é adicionado como um campo oculto:

```html
<form accept-charset="UTF-8" action="/users/1" method="post">
<input type="hidden"
       value="67250ab105eb5ad10851c00a5621854a23af5489"
       name="authenticity_token"/>
<!-- campos -->
</form>
```

O Rails adiciona esse token a cada formulário gerado usando os [helpers de formulário](form_helpers.html), então na maioria das vezes você não precisa se preocupar com isso. Se você estiver escrevendo um formulário manualmente ou precisar adicionar o token por outro motivo, ele está disponível através do método `form_authenticity_token`:

O `form_authenticity_token` gera um token de autenticação válido. Isso é útil em lugares onde o Rails não o adiciona automaticamente, como em chamadas Ajax personalizadas.

O [Guia de Segurança](security.html) tem mais informações sobre isso e muitos outros problemas relacionados à segurança que você deve estar ciente ao desenvolver um aplicativo da web.

Os objetos de solicitação e resposta
-----------------------------------

Em cada controlador, existem dois métodos de acesso que apontam para os objetos de solicitação e resposta associados ao ciclo de solicitação que está sendo executado no momento. O método [`request`][] contém uma instância de [`ActionDispatch::Request`][] e o método [`response`][] retorna um objeto de resposta que representa o que será enviado de volta ao cliente.


### O objeto `request`

O objeto de solicitação contém muitas informações úteis sobre a solicitação recebida do cliente. Para obter uma lista completa dos métodos disponíveis, consulte a [documentação da API do Rails](https://api.rubyonrails.org/classes/ActionDispatch/Request.html) e a [documentação do Rack](https://www.rubydoc.info/github/rack/rack/Rack/Request). Entre as propriedades às quais você pode acessar neste objeto estão:

| Propriedade de `request`                  | Propósito                                                                         |
| ----------------------------------------- | --------------------------------------------------------------------------------- |
| `host`                                    | O nome do host usado para esta solicitação.                                       |
| `domain(n=2)`                             | Os primeiros `n` segmentos do nome do host, começando pela direita (o TLD).        |
| `format`                                  | O tipo de conteúdo solicitado pelo cliente.                                       |
| `method`                                  | O método HTTP usado para a solicitação.                                           |
| `get?`, `post?`, `patch?`, `put?`, `delete?`, `head?` | Retorna true se o método HTTP for GET/POST/PATCH/PUT/DELETE/HEAD.   |
| `headers`                                 | Retorna um hash contendo os cabeçalhos associados à solicitação.                   |
| `port`                                    | O número da porta (inteiro) usado para a solicitação.                             |
| `protocol`                                | Retorna uma string contendo o protocolo usado mais "://", por exemplo "http://".  |
| `query_string`                            | A parte da string de consulta da URL, ou seja, tudo após "?".                      |
| `remote_ip`                               | O endereço IP do cliente.                                                         |
| `url`                                     | A URL inteira usada para a solicitação.                                            |
#### `path_parameters`, `query_parameters` e `request_parameters`

O Rails coleta todos os parâmetros enviados juntamente com a solicitação no hash `params`, independentemente de serem enviados como parte da string de consulta ou do corpo da postagem. O objeto de solicitação possui três acessores que fornecem acesso a esses parâmetros, dependendo de onde eles vieram. O hash [`query_parameters`][] contém parâmetros que foram enviados como parte da string de consulta, enquanto o hash [`request_parameters`][] contém parâmetros enviados como parte do corpo da postagem. O hash [`path_parameters`][] contém parâmetros que foram reconhecidos pelo roteamento como sendo parte do caminho que leva a este controlador e ação específicos.


### O objeto `response`

O objeto de resposta geralmente não é usado diretamente, mas é construído durante a execução da ação e renderização dos dados que estão sendo enviados de volta ao usuário, mas às vezes - como em um filtro posterior - pode ser útil acessar a resposta diretamente. Alguns desses métodos acessores também têm setters, permitindo que você altere seus valores. Para obter uma lista completa dos métodos disponíveis, consulte a [documentação da API do Rails](https://api.rubyonrails.org/classes/ActionDispatch/Response.html) e a [documentação do Rack](https://www.rubydoc.info/github/rack/rack/Rack/Response).

| Propriedade de `response` | Propósito                                                                                           |
| ------------------------ | -------------------------------------------------------------------------------------------------- |
| `body`                   | Esta é a string de dados que está sendo enviada de volta ao cliente. Isso geralmente é HTML.        |
| `status`                 | O código de status HTTP para a resposta, como 200 para uma solicitação bem-sucedida ou 404 para arquivo não encontrado. |
| `location`               | A URL para a qual o cliente está sendo redirecionado, se houver.                                    |
| `content_type`           | O tipo de conteúdo da resposta.                                                                     |
| `charset`                | O conjunto de caracteres usado para a resposta. O padrão é "utf-8".                                 |
| `headers`                | Cabeçalhos usados para a resposta.                                                                  |

#### Definindo Cabeçalhos Personalizados

Se você deseja definir cabeçalhos personalizados para uma resposta, então `response.headers` é o local para fazê-lo. O atributo headers é um hash que mapeia nomes de cabeçalho para seus valores, e o Rails definirá alguns deles automaticamente. Se você deseja adicionar ou alterar um cabeçalho, basta atribuí-lo a `response.headers` desta forma:

```ruby
response.headers["Content-Type"] = "application/pdf"
```

NOTA: No caso acima, faria mais sentido usar o setter `content_type` diretamente.

Autenticações HTTP
--------------------

O Rails vem com três mecanismos de autenticação HTTP integrados:

* Autenticação Básica
* Autenticação Digest
* Autenticação de Token

### Autenticação Básica HTTP

A autenticação básica HTTP é um esquema de autenticação suportado pela maioria dos navegadores e outros clientes HTTP. Como exemplo, considere uma seção de administração que só estará disponível ao inserir um nome de usuário e uma senha na janela de diálogo básica de autenticação HTTP do navegador. Usar a autenticação integrada requer apenas o uso de um método, [`http_basic_authenticate_with`][].

```ruby
class AdminsController < ApplicationController
  http_basic_authenticate_with name: "humbaba", password: "5baa61e4"
end
```

Com isso em vigor, você pode criar controladores com namespace que herdam de `AdminsController`. O filtro será executado para todas as ações nesses controladores, protegendo-os com autenticação básica HTTP.


### Autenticação Digest HTTP

A autenticação digest HTTP é superior à autenticação básica, pois não requer que o cliente envie uma senha não criptografada pela rede (embora a autenticação básica HTTP seja segura por HTTPS). Usar a autenticação digest com o Rails requer apenas o uso de um método, [`authenticate_or_request_with_http_digest`][].

```ruby
class AdminsController < ApplicationController
  USERS = { "lifo" => "world" }

  before_action :authenticate

  private
    def authenticate
      authenticate_or_request_with_http_digest do |username|
        USERS[username]
      end
    end
end
```

Como visto no exemplo acima, o bloco `authenticate_or_request_with_http_digest` recebe apenas um argumento - o nome de usuário. E o bloco retorna a senha. Retornar `false` ou `nil` do `authenticate_or_request_with_http_digest` causará falha na autenticação.


### Autenticação de Token HTTP

A autenticação de token HTTP é um esquema que permite o uso de tokens de portador no cabeçalho HTTP `Authorization`. Existem muitos formatos de token disponíveis e descrevê-los está fora do escopo deste documento.

Como exemplo, suponha que você queira usar um token de autenticação que tenha sido emitido antecipadamente para realizar autenticação e acesso. Implementar a autenticação de token com o Rails requer apenas o uso de um método, [`authenticate_or_request_with_http_token`][].

```ruby
class PostsController < ApplicationController
  TOKEN = "secret"

  before_action :authenticate

  private
    def authenticate
      authenticate_or_request_with_http_token do |token, options|
        ActiveSupport::SecurityUtils.secure_compare(token, TOKEN)
      end
    end
end
```

Como visto no exemplo acima, o bloco `authenticate_or_request_with_http_token` recebe dois argumentos - o token e um `Hash` contendo as opções que foram analisadas do cabeçalho HTTP `Authorization`. O bloco deve retornar `true` se a autenticação for bem-sucedida. Retornar `false` ou `nil` causará uma falha na autenticação.
Streaming e Downloads de Arquivos
----------------------------

Às vezes, você pode querer enviar um arquivo para o usuário em vez de renderizar uma página HTML. Todos os controladores no Rails possuem os métodos [`send_data`][] e [`send_file`][], que permitem transmitir dados para o cliente. `send_file` é um método conveniente que permite fornecer o nome de um arquivo no disco e transmitir o conteúdo desse arquivo para você.

Para transmitir dados para o cliente, use `send_data`:

```ruby
require "prawn"
class ClientsController < ApplicationController
  # Gera um documento PDF com informações sobre o cliente e
  # retorna-o. O usuário receberá o PDF como um download de arquivo.
  def download_pdf
    client = Client.find(params[:id])
    send_data generate_pdf(client),
              filename: "#{client.name}.pdf",
              type: "application/pdf"
  end

  private
    def generate_pdf(client)
      Prawn::Document.new do
        text client.name, align: :center
        text "Endereço: #{client.address}"
        text "Email: #{client.email}"
      end.render
    end
end
```

A ação `download_pdf` no exemplo acima chamará um método privado que realmente gera o documento PDF e o retorna como uma string. Essa string será então transmitida para o cliente como um download de arquivo, e um nome de arquivo será sugerido ao usuário. Às vezes, ao transmitir arquivos para o usuário, você pode não querer que eles façam o download do arquivo. Tome como exemplo imagens, que podem ser incorporadas em páginas HTML. Para informar ao navegador que um arquivo não deve ser baixado, você pode definir a opção `:disposition` como "inline". O valor oposto e padrão para essa opção é "attachment".

### Enviando Arquivos

Se você deseja enviar um arquivo que já existe no disco, use o método `send_file`.

```ruby
class ClientsController < ApplicationController
  # Transmite um arquivo que já foi gerado e armazenado no disco.
  def download_pdf
    client = Client.find(params[:id])
    send_file("#{Rails.root}/files/clients/#{client.id}.pdf",
              filename: "#{client.name}.pdf",
              type: "application/pdf")
  end
end
```

Isso lerá e transmitirá o arquivo 4 kB por vez, evitando carregar o arquivo inteiro na memória de uma só vez. Você pode desativar a transmissão com a opção `:stream` ou ajustar o tamanho do bloco com a opção `:buffer_size`.

Se `:type` não for especificado, ele será inferido a partir da extensão do arquivo especificada em `:filename`. Se o tipo de conteúdo não estiver registrado para a extensão, será usado `application/octet-stream`.

ATENÇÃO: Tenha cuidado ao usar dados provenientes do cliente (params, cookies, etc.) para localizar o arquivo no disco, pois isso representa um risco de segurança que pode permitir que alguém acesse arquivos aos quais não deveria ter acesso.

DICA: Não é recomendado transmitir arquivos estáticos através do Rails se você puder mantê-los em uma pasta pública em seu servidor web. É muito mais eficiente permitir que o usuário faça o download do arquivo diretamente usando o Apache ou outro servidor web, evitando que a solicitação passe desnecessariamente por todo o stack do Rails.

### Downloads RESTful

Embora `send_data` funcione muito bem, se você estiver criando um aplicativo RESTful, geralmente não é necessário ter ações separadas para downloads de arquivos. Na terminologia REST, o arquivo PDF do exemplo acima pode ser considerado apenas mais uma representação do recurso cliente. O Rails oferece uma maneira elegante de fazer downloads "RESTful". Veja como você pode reescrever o exemplo para que o download do PDF seja parte da ação `show`, sem qualquer transmissão:

```ruby
class ClientsController < ApplicationController
  # O usuário pode solicitar receber este recurso como HTML ou PDF.
  def show
    @client = Client.find(params[:id])

    respond_to do |format|
      format.html
      format.pdf { render pdf: generate_pdf(@client) }
    end
  end
end
```

Para que este exemplo funcione, você precisa adicionar o tipo MIME PDF ao Rails. Isso pode ser feito adicionando a seguinte linha ao arquivo `config/initializers/mime_types.rb`:

```ruby
Mime::Type.register "application/pdf", :pdf
```

NOTA: Os arquivos de configuração não são recarregados a cada solicitação, portanto, você precisa reiniciar o servidor para que as alterações tenham efeito.

Agora o usuário pode solicitar uma versão em PDF de um cliente apenas adicionando ".pdf" à URL:

```
GET /clients/1.pdf
```

### Streaming ao Vivo de Dados Arbitrários

O Rails permite transmitir mais do que apenas arquivos. Na verdade, você pode transmitir qualquer coisa que desejar em um objeto de resposta. O módulo [`ActionController::Live`][] permite criar uma conexão persistente com um navegador. Usando este módulo, você poderá enviar dados arbitrários para o navegador em momentos específicos.
#### Incorporando Streaming ao Vivo

Incluir `ActionController::Live` dentro da classe do seu controlador fornecerá a todas as ações dentro do controlador a capacidade de transmitir dados. Você pode misturar o módulo da seguinte forma:

```ruby
class MeuControlador < ActionController::Base
  include ActionController::Live

  def stream
    response.headers['Content-Type'] = 'text/event-stream'
    100.times {
      response.stream.write "olá mundo\n"
      sleep 1
    }
  ensure
    response.stream.close
  end
end
```

O código acima manterá uma conexão persistente com o navegador e enviará 100 mensagens de `"olá mundo\n"`, uma a cada segundo.

Existem algumas coisas a serem observadas no exemplo acima. Precisamos garantir o fechamento do fluxo de resposta. Esquecer de fechar o fluxo deixará o socket aberto para sempre. Também precisamos definir o tipo de conteúdo como `text/event-stream` antes de escrever no fluxo de resposta. Isso ocorre porque os cabeçalhos não podem ser escritos após a resposta ter sido enviada (quando `response.committed?` retorna um valor verdadeiro), o que ocorre quando você `write` ou `commit` o fluxo de resposta.

#### Exemplo de Uso

Vamos supor que você esteja criando uma máquina de karaokê e um usuário queira obter a letra de uma música específica. Cada `Song` tem um número específico de linhas e cada linha leva um tempo `num_beats` para terminar de cantar.

Se quisermos retornar a letra no estilo karaokê (enviando apenas a linha quando o cantor terminar a linha anterior), podemos usar `ActionController::Live` da seguinte forma:

```ruby
class LyricsController < ActionController::Base
  include ActionController::Live

  def show
    response.headers['Content-Type'] = 'text/event-stream'
    song = Song.find(params[:id])

    song.each do |line|
      response.stream.write line.lyrics
      sleep line.num_beats
    end
  ensure
    response.stream.close
  end
end
```

O código acima envia a próxima linha somente depois que o cantor terminou a linha anterior.

#### Considerações sobre Streaming

Streaming de dados arbitrários é uma ferramenta extremamente poderosa. Como mostrado nos exemplos anteriores, você pode escolher quando e o que enviar através de um fluxo de resposta. No entanto, você também deve observar as seguintes coisas:

* Cada fluxo de resposta cria uma nova thread e copia as variáveis locais da thread original. Ter muitas variáveis locais pode afetar negativamente o desempenho. Da mesma forma, um grande número de threads também pode prejudicar o desempenho.
* Não fechar o fluxo de resposta deixará o socket correspondente aberto para sempre. Certifique-se de chamar `close` sempre que estiver usando um fluxo de resposta.
* Os servidores WEBrick armazenam em buffer todas as respostas, portanto, incluir `ActionController::Live` não funcionará. Você deve usar um servidor web que não armazene automaticamente as respostas em buffer.

Filtragem de Logs
-----------------

O Rails mantém um arquivo de log para cada ambiente na pasta `log`. Eles são extremamente úteis para depurar o que está acontecendo em sua aplicação, mas em uma aplicação em produção, você pode não querer que todas as informações sejam armazenadas no arquivo de log.

### Filtragem de Parâmetros

Você pode filtrar parâmetros sensíveis das solicitações nos arquivos de log, adicionando-os a [`config.filter_parameters`][] na configuração da aplicação. Esses parâmetros serão marcados como [FILTERED] no log.

```ruby
config.filter_parameters << :password
```

NOTA: Os parâmetros fornecidos serão filtrados por meio de uma expressão regular de correspondência parcial. O Rails adiciona uma lista de filtros padrão, incluindo `:passw`, `:secret` e `:token`, no inicializador apropriado (`initializers/filter_parameter_logging.rb`) para lidar com parâmetros típicos de aplicação, como `password`, `password_confirmation` e `my_token`.

### Filtragem de Redirecionamentos

Às vezes, é desejável filtrar dos arquivos de log as localizações sensíveis para as quais a aplicação está redirecionando. Você pode fazer isso usando a opção de configuração `config.filter_redirect`:

```ruby
config.filter_redirect << 's3.amazonaws.com'
```

Você pode definir como uma String, uma Regexp ou uma matriz de ambos.

```ruby
config.filter_redirect.concat ['s3.amazonaws.com', /private_path/]
```

As URLs correspondentes serão marcadas como '[FILTERED]'.

Resgate
-------

É muito provável que sua aplicação contenha bugs ou lance uma exceção que precisa ser tratada. Por exemplo, se o usuário seguir um link para um recurso que não existe mais no banco de dados, o Active Record lançará a exceção `ActiveRecord::RecordNotFound`.

O tratamento de exceções padrão do Rails exibe uma mensagem de "Erro do Servidor 500" para todas as exceções. Se a solicitação foi feita localmente, um rastreamento detalhado e algumas informações adicionais são exibidos, para que você possa descobrir o que deu errado e lidar com isso. Se a solicitação foi remota, o Rails apenas exibirá uma mensagem simples de "Erro do Servidor 500" para o usuário, ou um "Erro 404 Não Encontrado" se houver um erro de roteamento ou se um registro não puder ser encontrado. Às vezes, você pode querer personalizar como esses erros são capturados e como são exibidos para o usuário. Existem vários níveis de tratamento de exceções disponíveis em uma aplicação Rails:
### Os Modelos Padrão de 500 e 404

Por padrão, no ambiente de produção, a aplicação irá renderizar uma mensagem de erro 404 ou 500. No ambiente de desenvolvimento, todas as exceções não tratadas são simplesmente levantadas. Essas mensagens estão contidas em arquivos HTML estáticos na pasta pública, em `404.html` e `500.html`, respectivamente. Você pode personalizar esses arquivos para adicionar informações extras e estilo, mas lembre-se de que eles são HTML estáticos; ou seja, você não pode usar ERB, SCSS, CoffeeScript ou layouts para eles.

### `rescue_from`

Se você quiser fazer algo um pouco mais elaborado ao capturar erros, você pode usar [`rescue_from`][], que lida com exceções de um determinado tipo (ou vários tipos) em um controlador inteiro e suas subclasses.

Quando ocorre uma exceção que é capturada por uma diretiva `rescue_from`, o objeto de exceção é passado para o manipulador. O manipulador pode ser um método ou um objeto `Proc` passado para a opção `:with`. Você também pode usar um bloco diretamente em vez de um objeto `Proc` explícito.

Veja como você pode usar `rescue_from` para interceptar todos os erros `ActiveRecord::RecordNotFound` e fazer algo com eles.

```ruby
class ApplicationController < ActionController::Base
  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found

  private
    def record_not_found
      render plain: "404 Not Found", status: 404
    end
end
```

É claro que este exemplo está longe de ser elaborado e não melhora o tratamento padrão de exceções de forma alguma, mas uma vez que você pode capturar todas essas exceções, você está livre para fazer o que quiser com elas. Por exemplo, você pode criar classes de exceção personalizadas que serão lançadas quando um usuário não tiver acesso a uma determinada seção da sua aplicação:

```ruby
class ApplicationController < ActionController::Base
  rescue_from User::NotAuthorized, with: :user_not_authorized

  private
    def user_not_authorized
      flash[:error] = "Você não tem acesso a esta seção."
      redirect_back(fallback_location: root_path)
    end
end

class ClientsController < ApplicationController
  # Verifica se o usuário tem a autorização correta para acessar os clientes.
  before_action :check_authorization

  # Observe como as ações não precisam se preocupar com todas as coisas de autenticação.
  def edit
    @client = Client.find(params[:id])
  end

  private
    # Se o usuário não estiver autorizado, apenas lance a exceção.
    def check_authorization
      raise User::NotAuthorized unless current_user.admin?
    end
end
```

ATENÇÃO: Usar `rescue_from` com `Exception` ou `StandardError` pode causar efeitos colaterais graves, pois impede que o Rails lide corretamente com as exceções. Portanto, não é recomendado fazer isso, a menos que haja uma razão forte.

NOTA: Ao executar no ambiente de produção, todos os erros `ActiveRecord::RecordNotFound` renderizam a página de erro 404. A menos que você precise de um comportamento personalizado, você não precisa lidar com isso.

NOTA: Certas exceções só podem ser resgatadas da classe `ApplicationController`, pois são levantadas antes que o controlador seja inicializado e a ação seja executada.


Forçar o Protocolo HTTPS
--------------------

Se você deseja garantir que a comunicação com o seu controlador seja possível apenas via HTTPS, você deve fazer isso ativando o middleware [`ActionDispatch::SSL`][] através da configuração [`config.force_ssl`][] no seu arquivo de configuração de ambiente.


Endpoint de Verificação de Saúde Incorporado
------------------------------

O Rails também vem com um endpoint de verificação de saúde incorporado que é acessível no caminho `/up`. Este endpoint retornará um código de status 200 se o aplicativo tiver sido inicializado sem exceções e um código de status 500 caso contrário.

Em produção, muitas aplicações são obrigadas a relatar seu status para cima, seja para um monitor de tempo de atividade que irá notificar um engenheiro quando algo der errado, ou para um balanceador de carga ou controlador Kubernetes usado para determinar a saúde de um pod. Esta verificação de saúde foi projetada para ser uma solução única que funcionará em muitas situações.

Embora todas as aplicações Rails recém-geradas tenham a verificação de saúde em `/up`, você pode configurar o caminho para qualquer coisa que desejar no arquivo "config/routes.rb":

```ruby
Rails.application.routes.draw do
  get "healthz" => "rails/health#show", as: :rails_health_check
end
```

A verificação de saúde agora estará acessível através do caminho `/healthz`.

NOTA: Este endpoint não reflete o status de todas as dependências da sua aplicação, como o banco de dados ou o cluster Redis. Substitua "rails/health#show" pela ação do seu próprio controlador se você tiver necessidades específicas da aplicação.

Pense cuidadosamente sobre o que você deseja verificar, pois isso pode levar a situações em que sua aplicação está sendo reiniciada devido a um serviço de terceiros que está com problemas. Idealmente, você deve projetar sua aplicação para lidar com essas interrupções de forma adequada.
[`ActionController::Base`]: https://api.rubyonrails.org/classes/ActionController/Base.html
[`params`]: https://api.rubyonrails.org/classes/ActionController/StrongParameters.html#method-i-params
[`wrap_parameters`]: https://api.rubyonrails.org/classes/ActionController/ParamsWrapper/Options/ClassMethods.html#method-i-wrap_parameters
[`controller_name`]: https://api.rubyonrails.org/classes/ActionController/Metal.html#method-i-controller_name
[`action_name`]: https://api.rubyonrails.org/classes/AbstractController/Base.html#method-i-action_name
[`permit`]: https://api.rubyonrails.org/classes/ActionController/Parameters.html#method-i-permit
[`permit!`]: https://api.rubyonrails.org/classes/ActionController/Parameters.html#method-i-permit-21
[`require`]: https://api.rubyonrails.org/classes/ActionController/Parameters.html#method-i-require
[`ActionDispatch::Session::CookieStore`]: https://api.rubyonrails.org/classes/ActionDispatch/Session/CookieStore.html
[`ActionDispatch::Session::CacheStore`]: https://api.rubyonrails.org/classes/ActionDispatch/Session/CacheStore.html
[`ActionDispatch::Session::MemCacheStore`]: https://api.rubyonrails.org/classes/ActionDispatch/Session/MemCacheStore.html
[activerecord-session_store]: https://github.com/rails/activerecord-session_store
[`reset_session`]: https://api.rubyonrails.org/classes/ActionController/Metal.html#method-i-reset_session
[`flash`]: https://api.rubyonrails.org/classes/ActionDispatch/Flash/RequestMethods.html#method-i-flash
[`flash.keep`]: https://api.rubyonrails.org/classes/ActionDispatch/Flash/FlashHash.html#method-i-keep
[`flash.now`]: https://api.rubyonrails.org/classes/ActionDispatch/Flash/FlashHash.html#method-i-now
[`config.action_dispatch.cookies_serializer`]: configuring.html#config-action-dispatch-cookies-serializer
[`cookies`]: https://api.rubyonrails.org/classes/ActionController/Cookies.html#method-i-cookies
[`before_action`]: https://api.rubyonrails.org/classes/AbstractController/Callbacks/ClassMethods.html#method-i-before_action
[`skip_before_action`]: https://api.rubyonrails.org/classes/AbstractController/Callbacks/ClassMethods.html#method-i-skip_before_action
[`after_action`]: https://api.rubyonrails.org/classes/AbstractController/Callbacks/ClassMethods.html#method-i-after_action
[`around_action`]: https://api.rubyonrails.org/classes/AbstractController/Callbacks/ClassMethods.html#method-i-around_action
[`ActionDispatch::Request`]: https://api.rubyonrails.org/classes/ActionDispatch/Request.html
[`request`]: https://api.rubyonrails.org/classes/ActionController/Base.html#method-i-request
[`response`]: https://api.rubyonrails.org/classes/ActionController/Base.html#method-i-response
[`path_parameters`]: https://api.rubyonrails.org/classes/ActionDispatch/Http/Parameters.html#method-i-path_parameters
[`query_parameters`]: https://api.rubyonrails.org/classes/ActionDispatch/Request.html#method-i-query_parameters
[`request_parameters`]: https://api.rubyonrails.org/classes/ActionDispatch/Request.html#method-i-request_parameters
[`http_basic_authenticate_with`]: https://api.rubyonrails.org/classes/ActionController/HttpAuthentication/Basic/ControllerMethods/ClassMethods.html#method-i-http_basic_authenticate_with
[`authenticate_or_request_with_http_digest`]: https://api.rubyonrails.org/classes/ActionController/HttpAuthentication/Digest/ControllerMethods.html#method-i-authenticate_or_request_with_http_digest
[`authenticate_or_request_with_http_token`]: https://api.rubyonrails.org/classes/ActionController/HttpAuthentication/Token/ControllerMethods.html#method-i-authenticate_or_request_with_http_token
[`send_data`]: https://api.rubyonrails.org/classes/ActionController/DataStreaming.html#method-i-send_data
[`send_file`]: https://api.rubyonrails.org/classes/ActionController/DataStreaming.html#method-i-send_file
[`ActionController::Live`]: https://api.rubyonrails.org/classes/ActionController/Live.html
[`config.filter_parameters`]: configuring.html#config-filter-parameters
[`rescue_from`]: https://api.rubyonrails.org/classes/ActiveSupport/Rescuable/ClassMethods.html#method-i-rescue_from
[`config.force_ssl`]: configuring.html#config-force-ssl
[`ActionDispatch::SSL`]: https://api.rubyonrails.org/classes/ActionDispatch/SSL.html
