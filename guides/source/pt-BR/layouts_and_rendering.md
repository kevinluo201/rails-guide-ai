**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 02f663dc709da76ced45deb2ba800a78
Layouts e Renderização no Rails
==============================

Este guia aborda os recursos básicos de layout do Action Controller e Action View.

Após ler este guia, você saberá:

* Como usar os vários métodos de renderização incorporados no Rails.
* Como criar layouts com várias seções de conteúdo.
* Como usar partials para otimizar suas visualizações.
* Como usar layouts aninhados (sub-modelos).

--------------------------------------------------------------------------------

Visão Geral: Como as Peças se Encaixam
-------------------------------------

Este guia se concentra na interação entre Controller e View no triângulo Model-View-Controller. Como você sabe, o Controller é responsável por orquestrar todo o processo de manipulação de uma solicitação no Rails, embora normalmente ele delegue qualquer código pesado para o Model. Mas então, quando é hora de enviar uma resposta de volta para o usuário, o Controller passa as coisas para a View. É essa transferência que é o assunto deste guia.

Em linhas gerais, isso envolve decidir o que deve ser enviado como resposta e chamar um método apropriado para criar essa resposta. Se a resposta for uma visualização completa, o Rails também faz um trabalho extra para envolver a visualização em um layout e possivelmente incluir visualizações parciais. Você verá todos esses caminhos mais adiante neste guia.

Criando Respostas
------------------

Do ponto de vista do controller, existem três maneiras de criar uma resposta HTTP:

* Chamar [`render`][controller.render] para criar uma resposta completa a ser enviada de volta para o navegador.
* Chamar [`redirect_to`][] para enviar um código de status de redirecionamento HTTP para o navegador.
* Chamar [`head`][] para criar uma resposta consistindo apenas de cabeçalhos HTTP para enviar de volta para o navegador.


### Renderização por Padrão: Convenção sobre Configuração em Ação

Você já ouviu falar que o Rails promove "convenção sobre configuração". A renderização padrão é um excelente exemplo disso. Por padrão, os controllers no Rails renderizam automaticamente visualizações com nomes que correspondem a rotas válidas. Por exemplo, se você tiver este código em sua classe `BooksController`:

```ruby
class BooksController < ApplicationController
end
```

E o seguinte em seu arquivo de rotas:

```ruby
resources :books
```

E você tiver um arquivo de visualização `app/views/books/index.html.erb`:

```html+erb
<h1>Livros em breve!</h1>
```

O Rails renderizará automaticamente `app/views/books/index.html.erb` quando você navegar para `/books` e você verá "Livros em breve!" em sua tela.

No entanto, uma tela de "em breve" é apenas minimamente útil, então você logo criará seu modelo `Book` e adicionará a ação de índice ao `BooksController`:

```ruby
class BooksController < ApplicationController
  def index
    @books = Book.all
  end
end
```

Observe que não temos uma renderização explícita no final da ação de índice de acordo com o princípio de "convenção sobre configuração". A regra é que, se você não renderizar explicitamente algo no final de uma ação do controller, o Rails procurará automaticamente o template `action_name.html.erb` no caminho de visualização do controller e o renderizará. Portanto, neste caso, o Rails renderizará o arquivo `app/views/books/index.html.erb`.

Se quisermos exibir as propriedades de todos os livros em nossa visualização, podemos fazer isso com um template ERB como este:

```html+erb
<h1>Listando Livros</h1>

<table>
  <thead>
    <tr>
      <th>Título</th>
      <th>Conteúdo</th>
      <th colspan="3"></th>
    </tr>
  </thead>

  <tbody>
    <% @books.each do |book| %>
      <tr>
        <td><%= book.title %></td>
        <td><%= book.content %></td>
        <td><%= link_to "Mostrar", book %></td>
        <td><%= link_to "Editar", edit_book_path(book) %></td>
        <td><%= link_to "Excluir", book, data: { turbo_method: :delete, turbo_confirm: "Tem certeza?" } %></td>
      </tr>
    <% end %>
  </tbody>
</table>

<br>

<%= link_to "Novo livro", new_book_path %>
```

NOTA: A renderização real é feita por classes aninhadas do módulo [`ActionView::Template::Handlers`](https://api.rubyonrails.org/classes/ActionView/Template/Handlers.html). Este guia não explora esse processo, mas é importante saber que a extensão do arquivo de visualização controla a escolha do manipulador de template.

### Usando `render`

Na maioria dos casos, o método [`render`][controller.render] do controller faz o trabalho pesado de renderizar o conteúdo da sua aplicação para uso por um navegador. Existem várias maneiras de personalizar o comportamento do `render`. Você pode renderizar a visualização padrão para um template do Rails, ou um template específico, ou um arquivo, ou código inline, ou nada. Você pode renderizar texto, JSON ou XML. Você também pode especificar o tipo de conteúdo ou o status HTTP da resposta renderizada.

DICA: Se você quiser ver os resultados exatos de uma chamada para `render` sem precisar inspecioná-la em um navegador, você pode chamar `render_to_string`. Este método aceita exatamente as mesmas opções que `render`, mas retorna uma string em vez de enviar uma resposta de volta para o navegador.
#### Renderizando a View de uma Ação

Se você deseja renderizar a view que corresponde a um template diferente dentro do mesmo controller, você pode usar `render` com o nome da view:

```ruby
def update
  @book = Book.find(params[:id])
  if @book.update(book_params)
    redirect_to(@book)
  else
    render "edit"
  end
end
```

Se a chamada para `update` falhar, chamando a ação `update` neste controller irá renderizar o template `edit.html.erb` pertencente ao mesmo controller.

Se preferir, você pode usar um símbolo em vez de uma string para especificar a ação a ser renderizada:

```ruby
def update
  @book = Book.find(params[:id])
  if @book.update(book_params)
    redirect_to(@book)
  else
    render :edit, status: :unprocessable_entity
  end
end
```

#### Renderizando o Template de uma Ação de Outro Controller

E se você quiser renderizar um template de um controller completamente diferente daquele que contém o código da ação? Você também pode fazer isso com `render`, que aceita o caminho completo (relativo a `app/views`) do template a ser renderizado. Por exemplo, se você estiver executando código em um `AdminProductsController` que está em `app/controllers/admin`, você pode renderizar os resultados de uma ação para um template em `app/views/products` desta forma:

```ruby
render "products/show"
```

O Rails sabe que essa view pertence a um controller diferente por causa do caractere de barra embutido na string. Se você quiser ser explícito, pode usar a opção `:template` (que era obrigatória no Rails 2.2 e anteriores):

```ruby
render template: "products/show"
```

#### Conclusão

As duas maneiras acima de renderizar (renderizar o template de outra ação no mesmo controller e renderizar o template de outra ação em um controller diferente) são na verdade variantes da mesma operação.

Na verdade, na classe `BooksController`, dentro da ação `update` onde queremos renderizar o template `edit` se o livro não for atualizado com sucesso, todas as chamadas de renderização a seguir renderizariam o template `edit.html.erb` no diretório `views/books`:

```ruby
render :edit
render action: :edit
render "edit"
render action: "edit"
render "books/edit"
render template: "books/edit"
```

Qual você usa é realmente uma questão de estilo e convenção, mas a regra geral é usar o mais simples que faça sentido para o código que você está escrevendo.

#### Usando `render` com `:inline`

O método `render` pode funcionar sem uma view completamente, se você estiver disposto a usar a opção `:inline` para fornecer ERB como parte da chamada do método. Isso é perfeitamente válido:

```ruby
render inline: "<% products.each do |p| %><p><%= p.name %></p><% end %>"
```

ATENÇÃO: Raramente há uma boa razão para usar essa opção. Misturar ERB em seus controllers vai contra a orientação MVC do Rails e tornará mais difícil para outros desenvolvedores entenderem a lógica do seu projeto. Use uma view ERB separada em vez disso.

Por padrão, a renderização inline usa ERB. Você pode forçá-la a usar o Builder em vez disso com a opção `:type`:

```ruby
render inline: "xml.p {'Prática de codificação horrível!'}", type: :builder
```

#### Renderizando Texto

Você pode enviar texto simples - sem nenhuma marcação - de volta para o navegador usando a opção `:plain` para `render`:

```ruby
render plain: "OK"
```

DICA: Renderizar texto puro é mais útil quando você está respondendo a requisições Ajax ou de serviços web que esperam algo diferente de HTML adequado.

NOTA: Por padrão, se você usar a opção `:plain`, o texto será renderizado sem usar o layout atual. Se você quiser que o Rails coloque o texto no layout atual, você precisa adicionar a opção `layout: true` e usar a extensão `.text.erb` para o arquivo de layout.

#### Renderizando HTML

Você pode enviar uma string HTML de volta para o navegador usando a opção `:html` para `render`:

```ruby
render html: helpers.tag.strong('Not Found')
```

DICA: Isso é útil quando você está renderizando um pequeno trecho de código HTML. No entanto, você pode considerar movê-lo para um arquivo de template se a marcação for complexa.

NOTA: Ao usar a opção `html:`, as entidades HTML serão escapadas se a string não for composta com APIs que são `html_safe`-aware.

#### Renderizando JSON

JSON é um formato de dados JavaScript usado por muitas bibliotecas Ajax. O Rails possui suporte integrado para converter objetos em JSON e renderizar esse JSON de volta para o navegador:

```ruby
render json: @product
```

DICA: Você não precisa chamar `to_json` no objeto que deseja renderizar. Se você usar a opção `:json`, o `render` irá automaticamente chamar `to_json` para você.
#### Renderização de XML

O Rails também possui suporte integrado para converter objetos em XML e renderizar esse XML de volta para o chamador:

```ruby
render xml: @product
```

DICA: Você não precisa chamar `to_xml` no objeto que deseja renderizar. Se você usar a opção `:xml`, o `render` irá automaticamente chamar `to_xml` para você.

#### Renderização de JavaScript Vanilla

O Rails pode renderizar JavaScript vanilla:

```ruby
render js: "alert('Hello Rails');"
```

Isso enviará a string fornecida para o navegador com um tipo MIME de `text/javascript`.

#### Renderização de Corpo Bruto

Você pode enviar um conteúdo bruto de volta para o navegador, sem definir nenhum tipo de conteúdo, usando a opção `:body` para `render`:

```ruby
render body: "raw"
```

DICA: Essa opção deve ser usada apenas se você não se importar com o tipo de conteúdo da resposta. Usar `:plain` ou `:html` pode ser mais apropriado na maioria das vezes.

NOTA: A menos que seja substituído, sua resposta retornada dessa opção de renderização será `text/plain`, pois esse é o tipo de conteúdo padrão da resposta do Action Dispatch.

#### Renderização de Arquivo Bruto

O Rails pode renderizar um arquivo bruto a partir de um caminho absoluto. Isso é útil para renderizar condicionalmente arquivos estáticos, como páginas de erro.

```ruby
render file: "#{Rails.root}/public/404.html", layout: false
```

Isso renderiza o arquivo bruto (não suporta ERB ou outros manipuladores). Por padrão, ele é renderizado dentro do layout atual.

AVISO: Usar a opção `:file` em combinação com a entrada do usuário pode levar a problemas de segurança, pois um invasor pode usar essa ação para acessar arquivos sensíveis de segurança em seu sistema de arquivos.

DICA: `send_file` é frequentemente uma opção mais rápida e melhor se um layout não for necessário.

#### Renderização de Objetos

O Rails pode renderizar objetos que respondem a `:render_in`.

```ruby
render MyRenderable.new
```

Isso chama `render_in` no objeto fornecido com o contexto de visualização atual.

Você também pode fornecer o objeto usando a opção `:renderable` para `render`:

```ruby
render renderable: MyRenderable.new
```

#### Opções para `render`

As chamadas para o método [`render`][controller.render] geralmente aceitam seis opções:

* `:content_type`
* `:layout`
* `:location`
* `:status`
* `:formats`
* `:variants`

##### A opção `:content_type`

Por padrão, o Rails irá servir os resultados de uma operação de renderização com o tipo de conteúdo MIME `text/html` (ou `application/json` se você usar a opção `:json`, ou `application/xml` para a opção `:xml`). Há momentos em que você pode querer alterar isso, e você pode fazer isso definindo a opção `:content_type`:

```ruby
render template: "feed", content_type: "application/rss"
```

##### A opção `:layout`

Com a maioria das opções de `render`, o conteúdo renderizado é exibido como parte do layout atual. Você aprenderá mais sobre layouts e como usá-los mais adiante neste guia.

Você pode usar a opção `:layout` para dizer ao Rails para usar um arquivo específico como o layout para a ação atual:

```ruby
render layout: "special_layout"
```

Você também pode dizer ao Rails para renderizar sem nenhum layout:

```ruby
render layout: false
```

##### A opção `:location`

Você pode usar a opção `:location` para definir o cabeçalho HTTP `Location`:

```ruby
render xml: photo, location: photo_url(photo)
```

##### A opção `:status`

O Rails irá gerar automaticamente uma resposta com o código de status HTTP correto (na maioria dos casos, isso é `200 OK`). Você pode usar a opção `:status` para alterar isso:

```ruby
render status: 500
render status: :forbidden
```

O Rails entende tanto códigos de status numéricos quanto os símbolos correspondentes mostrados abaixo.

| Classe de Resposta  | Código de Status HTTP | Símbolo                          |
| ------------------- | --------------------- | -------------------------------- |
| **Informativo**     | 100                   | :continue                        |
|                     | 101                   | :switching_protocols             |
|                     | 102                   | :processing                      |
| **Sucesso**         | 200                   | :ok                              |
|                     | 201                   | :created                         |
|                     | 202                   | :accepted                        |
|                     | 203                   | :non_authoritative_information   |
|                     | 204                   | :no_content                      |
|                     | 205                   | :reset_content                   |
|                     | 206                   | :partial_content                 |
|                     | 207                   | :multi_status                    |
|                     | 208                   | :already_reported                |
|                     | 226                   | :im_used                         |
| **Redirecionamento**| 300                   | :multiple_choices                |
|                     | 301                   | :moved_permanently               |
|                     | 302                   | :found                           |
|                     | 303                   | :see_other                       |
|                     | 304                   | :not_modified                    |
|                     | 305                   | :use_proxy                       |
|                     | 307                   | :temporary_redirect              |
|                     | 308                   | :permanent_redirect              |
| **Erro do Cliente** | 400                   | :bad_request                     |
|                     | 401                   | :unauthorized                    |
|                     | 402                   | :payment_required                |
|                     | 403                   | :forbidden                       |
|                     | 404                   | :not_found                       |
|                     | 405                   | :method_not_allowed              |
|                     | 406                   | :not_acceptable                  |
|                     | 407                   | :proxy_authentication_required   |
|                     | 408                   | :request_timeout                 |
|                     | 409                   | :conflict                        |
|                     | 410                   | :gone                            |
|                     | 411                   | :length_required                 |
|                     | 412                   | :precondition_failed             |
|                     | 413                   | :payload_too_large               |
|                     | 414                   | :uri_too_long                    |
|                     | 415                   | :unsupported_media_type          |
|                     | 416                   | :range_not_satisfiable           |
|                     | 417                   | :expectation_failed              |
|                     | 421                   | :misdirected_request             |
|                     | 422                   | :unprocessable_entity            |
|                     | 423                   | :locked                          |
|                     | 424                   | :failed_dependency               |
|                     | 426                   | :upgrade_required                |
|                     | 428                   | :precondition_required           |
|                     | 429                   | :too_many_requests               |
|                     | 431                   | :request_header_fields_too_large |
|                     | 451                   | :unavailable_for_legal_reasons   |
| **Erro do Servidor**| 500                   | :internal_server_error           |
|                     | 501                   | :not_implemented                 |
|                     | 502                   | :bad_gateway                     |
|                     | 503                   | :service_unavailable             |
|                     | 504                   | :gateway_timeout                 |
|                     | 505                   | :http_version_not_supported      |
|                     | 506                   | :variant_also_negotiates         |
|                     | 507                   | :insufficient_storage            |
|                     | 508                   | :loop_detected                   |
|                     | 510                   | :not_extended                    |
|                     | 511                   | :network_authentication_required |
NOTA: Se você tentar renderizar conteúdo junto com um código de status que não é de conteúdo (100-199, 204, 205 ou 304), ele será removido da resposta.

##### A opção `:formats`

O Rails usa o formato especificado na solicitação (ou `:html` por padrão). Você pode alterar isso passando a opção `:formats` com um símbolo ou um array:

```ruby
render formats: :xml
render formats: [:json, :xml]
```

Se um modelo com o formato especificado não existir, será gerado um erro `ActionView::MissingTemplate`.

##### A opção `:variants`

Isso indica ao Rails para procurar variações de modelo do mesmo formato. Você pode especificar uma lista de variantes passando a opção `:variants` com um símbolo ou um array.

Um exemplo de uso seria este.

```ruby
# chamado em HomeController#index
render variants: [:mobile, :desktop]
```

Com esse conjunto de variantes, o Rails procurará o seguinte conjunto de modelos e usará o primeiro que existir.

- `app/views/home/index.html+mobile.erb`
- `app/views/home/index.html+desktop.erb`
- `app/views/home/index.html.erb`

Se um modelo com o formato especificado não existir, será gerado um erro `ActionView::MissingTemplate`.

Em vez de definir a variante na chamada de renderização, você também pode defini-la no objeto de solicitação em sua ação de controlador.

```ruby
def index
  request.variant = determine_variant
end

  private
    def determine_variant
      variant = nil
      # algum código para determinar a(s) variante(s) a serem usadas
      variant = :mobile if session[:use_mobile]

      variant
    end
```

#### Encontrando Layouts

Para encontrar o layout atual, o Rails primeiro procura um arquivo em `app/views/layouts` com o mesmo nome base do controlador. Por exemplo, a renderização de ações da classe `PhotosController` usará `app/views/layouts/photos.html.erb` (ou `app/views/layouts/photos.builder`). Se não houver um layout específico do controlador, o Rails usará `app/views/layouts/application.html.erb` ou `app/views/layouts/application.builder`. Se não houver um layout `.erb`, o Rails usará um layout `.builder` se existir. O Rails também fornece várias maneiras de atribuir layouts específicos a controladores e ações individuais.

##### Especificando Layouts para Controladores

Você pode substituir as convenções de layout padrão em seus controladores usando a declaração [`layout`][]. Por exemplo:

```ruby
class ProductsController < ApplicationController
  layout "inventory"
  #...
end
```

Com essa declaração, todas as visualizações renderizadas pelo `ProductsController` usarão `app/views/layouts/inventory.html.erb` como layout.

Para atribuir um layout específico para toda a aplicação, use uma declaração de `layout` em sua classe `ApplicationController`:

```ruby
class ApplicationController < ActionController::Base
  layout "main"
  #...
end
```

Com essa declaração, todas as visualizações em toda a aplicação usarão `app/views/layouts/main.html.erb` como layout.

##### Escolhendo Layouts em Tempo de Execução

Você pode usar um símbolo para adiar a escolha do layout até que uma solicitação seja processada:

```ruby
class ProductsController < ApplicationController
  layout :products_layout

  def show
    @product = Product.find(params[:id])
  end

  private
    def products_layout
      @current_user.special? ? "special" : "products"
    end
end
```

Agora, se o usuário atual for um usuário especial, ele receberá um layout especial ao visualizar um produto.

Você pode até mesmo usar um método inline, como um Proc, para determinar o layout. Por exemplo, se você passar um objeto Proc, o bloco que você fornecer ao Proc receberá a instância do `controller`, para que o layout possa ser determinado com base na solicitação atual:

```ruby
class ProductsController < ApplicationController
  layout Proc.new { |controller| controller.request.xhr? ? "popup" : "application" }
end
```

##### Layouts Condicional

Os layouts especificados no nível do controlador suportam as opções `:only` e `:except`. Essas opções aceitam um nome de método ou um array de nomes de método, correspondendo a nomes de método dentro do controlador:

```ruby
class ProductsController < ApplicationController
  layout "product", except: [:index, :rss]
end
```

Com essa declaração, o layout `product` será usado para tudo, exceto os métodos `rss` e `index`.

##### Herança de Layout

As declarações de layout se propagam descendente na hierarquia, e declarações de layout mais específicas sempre substituem as mais gerais. Por exemplo:

* `application_controller.rb`

    ```ruby
    class ApplicationController < ActionController::Base
      layout "main"
    end
    ```

* `articles_controller.rb`

    ```ruby
    class ArticlesController < ApplicationController
    end
    ```

* `special_articles_controller.rb`

    ```ruby
    class SpecialArticlesController < ArticlesController
      layout "special"
    end
    ```

* `old_articles_controller.rb`

    ```ruby
    class OldArticlesController < SpecialArticlesController
      layout false

      def show
        @article = Article.find(params[:id])
      end

      def index
        @old_articles = Article.older
        render layout: "old"
      end
      # ...
    end
    ```

Nesta aplicação:

* Em geral, as visualizações serão renderizadas no layout `main`
* `ArticlesController#index` usará o layout `main`
* `SpecialArticlesController#index` usará o layout `special`
* `OldArticlesController#show` não usará nenhum layout
* `OldArticlesController#index` usará o layout `old`
##### Herança de Templates

Similar à lógica de Herança de Layout, se um template ou partial não for encontrado no caminho convencional, o controlador procurará um template ou partial para renderizar em sua cadeia de herança. Por exemplo:

```ruby
# app/controllers/application_controller.rb
class ApplicationController < ActionController::Base
end
```

```ruby
# app/controllers/admin_controller.rb
class AdminController < ApplicationController
end
```

```ruby
# app/controllers/admin/products_controller.rb
class Admin::ProductsController < AdminController
  def index
  end
end
```

A ordem de busca para uma ação `admin/products#index` será:

* `app/views/admin/products/`
* `app/views/admin/`
* `app/views/application/`

Isso torna `app/views/application/` um ótimo lugar para seus partials compartilhados, que podem ser renderizados em seu ERB da seguinte forma:

```erb
<%# app/views/admin/products/index.html.erb %>
<%= render @products || "empty_list" %>

<%# app/views/application/_empty_list.html.erb %>
Não há itens nesta lista <em>ainda</em>.
```

#### Evitando Erros de Renderização Dupla

Mais cedo ou mais tarde, a maioria dos desenvolvedores Rails verá a mensagem de erro "Can only render or redirect once per action" (Só é possível renderizar ou redirecionar uma vez por ação). Embora isso seja irritante, é relativamente fácil de corrigir. Geralmente isso acontece por causa de uma compreensão equivocada sobre a forma como o `render` funciona.

Por exemplo, aqui está um código que irá disparar esse erro:

```ruby
def show
  @book = Book.find(params[:id])
  if @book.special?
    render action: "special_show"
  end
  render action: "regular_show"
end
```

Se `@book.special?` for avaliado como `true`, o Rails iniciará o processo de renderização para inserir a variável `@book` na view `special_show`. Mas isso _não_ impedirá que o restante do código na ação `show` seja executado, e quando o Rails chegar ao final da ação, ele começará a renderizar a view `regular_show` - e lançará um erro. A solução é simples: certifique-se de ter apenas uma chamada para `render` ou `redirect` em um único caminho de código. Uma coisa que pode ajudar é o `return`. Aqui está uma versão corrigida do método:

```ruby
def show
  @book = Book.find(params[:id])
  if @book.special?
    render action: "special_show"
    return
  end
  render action: "regular_show"
end
```

Observe que o render implícito feito pelo ActionController detecta se o `render` foi chamado, então o seguinte funcionará sem erros:

```ruby
def show
  @book = Book.find(params[:id])
  if @book.special?
    render action: "special_show"
  end
end
```

Isso renderizará um livro com `special?` definido com o template `special_show`, enquanto outros livros serão renderizados com o template padrão `show`.

### Usando `redirect_to`

Outra maneira de lidar com o retorno de respostas para uma requisição HTTP é com o [`redirect_to`][]. Como você viu, `render` informa ao Rails qual view (ou outro recurso) usar na construção de uma resposta. O método `redirect_to` faz algo completamente diferente: ele diz ao navegador para enviar uma nova requisição para uma URL diferente. Por exemplo, você pode redirecionar de qualquer lugar do seu código para o índice de fotos em sua aplicação com esta chamada:

```ruby
redirect_to photos_url
```

Você pode usar [`redirect_back`][] para retornar o usuário para a página de onde ele veio. Esta localização é obtida do cabeçalho `HTTP_REFERER`, que não é garantido estar definido pelo navegador, então você deve fornecer a `fallback_location` para usar nesse caso.

```ruby
redirect_back(fallback_location: root_path)
```

NOTA: `redirect_to` e `redirect_back` não interrompem e retornam imediatamente da execução do método, mas simplesmente definem respostas HTTP. As instruções que ocorrem após eles em um método serão executadas. Você pode interromper com um `return` explícito ou outro mecanismo de interrupção, se necessário.


#### Obtendo um Código de Status de Redirecionamento Diferente

O Rails usa o código de status HTTP 302, um redirecionamento temporário, quando você chama `redirect_to`. Se você deseja usar um código de status diferente, talvez 301, um redirecionamento permanente, você pode usar a opção `:status`:

```ruby
redirect_to photos_path, status: 301
```

Assim como a opção `:status` para `render`, `:status` para `redirect_to` aceita tanto designações de cabeçalho numéricas quanto simbólicas.

#### A Diferença Entre `render` e `redirect_to`

Às vezes, desenvolvedores inexperientes pensam no `redirect_to` como uma espécie de comando `goto`, movendo a execução de um lugar para outro no seu código Rails. Isso _não_ está correto. Seu código para de ser executado e aguarda uma nova requisição do navegador. Acontece apenas que você informou ao navegador qual requisição ele deve fazer em seguida, enviando de volta um código de status HTTP 302.

Considere essas ações para ver a diferença:

```ruby
def index
  @books = Book.all
end

def show
  @book = Book.find_by(id: params[:id])
  if @book.nil?
    render action: "index"
  end
end
```

Com o código nessa forma, provavelmente haverá um problema se a variável `@book` for `nil`. Lembre-se, um `render :action` não executa nenhum código na ação de destino, então nada irá configurar a variável `@books` que a view `index` provavelmente requererá. Uma maneira de corrigir isso é redirecionar em vez de renderizar:
```ruby
def index
  @books = Book.all
end

def show
  @book = Book.find_by(id: params[:id])
  if @book.nil?
    redirect_to action: :index
  end
end
```

Com esse código, o navegador fará uma nova solicitação para a página de índice, o código no método `index` será executado e tudo ficará bem.

A única desvantagem desse código é que ele requer uma viagem de ida e volta para o navegador: o navegador solicitou a ação de exibição com `/books/1` e o controlador descobre que não há livros, então o controlador envia uma resposta de redirecionamento 302 para o navegador, dizendo para ir para `/books/`, o navegador obedece e envia uma nova solicitação de volta ao controlador, agora pedindo a ação `index`, o controlador então obtém todos os livros no banco de dados e renderiza o modelo de índice, enviando-o de volta ao navegador, que então o exibe na tela.

Embora em um aplicativo pequeno, essa latência adicional possa não ser um problema, é algo a se pensar se o tempo de resposta for uma preocupação. Podemos demonstrar uma maneira de lidar com isso com um exemplo fictício:

```ruby
def index
  @books = Book.all
end

def show
  @book = Book.find_by(id: params[:id])
  if @book.nil?
    @books = Book.all
    flash.now[:alert] = "Seu livro não foi encontrado"
    render "index"
  end
end
```

Isso detectaria que não há livros com o ID especificado, preencheria a variável de instância `@books` com todos os livros no modelo e, em seguida, renderizaria diretamente o modelo `index.html.erb`, retornando-o para o navegador com uma mensagem de alerta para informar ao usuário o que aconteceu.

### Usando `head` para construir respostas apenas com cabeçalhos

O método [`head`][] pode ser usado para enviar respostas apenas com cabeçalhos para o navegador. O método `head` aceita um número ou símbolo (consulte a [tabela de referência](#a-opcao-status)) que representa um código de status HTTP. O argumento de opções é interpretado como um hash de nomes e valores de cabeçalho. Por exemplo, você pode retornar apenas um cabeçalho de erro:

```ruby
head :bad_request
```

Isso produziria o seguinte cabeçalho:

```http
HTTP/1.1 400 Bad Request
Connection: close
Date: Sun, 24 Jan 2010 12:15:53 GMT
Transfer-Encoding: chunked
Content-Type: text/html; charset=utf-8
X-Runtime: 0.013483
Set-Cookie: _blog_session=...snip...; path=/; HttpOnly
Cache-Control: no-cache
```

Ou você pode usar outros cabeçalhos HTTP para transmitir outras informações:

```ruby
head :created, location: photo_path(@photo)
```

O que produziria:

```http
HTTP/1.1 201 Created
Connection: close
Date: Sun, 24 Jan 2010 12:16:44 GMT
Transfer-Encoding: chunked
Location: /photos/1
Content-Type: text/html; charset=utf-8
X-Runtime: 0.083496
Set-Cookie: _blog_session=...snip...; path=/; HttpOnly
Cache-Control: no-cache
```

Estruturando Layouts
-------------------

Quando o Rails renderiza uma visualização como resposta, ele combina a visualização com o layout atual, usando as regras para encontrar o layout atual que foram abordadas anteriormente neste guia. Dentro de um layout, você tem acesso a três ferramentas para combinar diferentes partes de saída para formar a resposta geral:

* Tags de ativos
* `yield` e [`content_for`][]
* Partials


### Tags de Ativos

As tags de ativos fornecem métodos para gerar HTML que vinculam visualizações a feeds, JavaScript, folhas de estilo, imagens, vídeos e áudios. Existem seis tags de ativos disponíveis no Rails:

* [`auto_discovery_link_tag`][]
* [`javascript_include_tag`][]
* [`stylesheet_link_tag`][]
* [`image_tag`][]
* [`video_tag`][]
* [`audio_tag`][]

Você pode usar essas tags em layouts ou outras visualizações, embora as tags `auto_discovery_link_tag`, `javascript_include_tag` e `stylesheet_link_tag` sejam mais comumente usadas na seção `<head>` de um layout.

AVISO: As tags de ativos não verificam a existência dos ativos nos locais especificados; elas simplesmente assumem que você sabe o que está fazendo e geram o link.


#### Vinculando a Feeds com o `auto_discovery_link_tag`

O auxiliar [`auto_discovery_link_tag`][] constrói HTML que a maioria dos navegadores e leitores de feeds pode usar para detectar a presença de feeds RSS, Atom ou JSON. Ele recebe o tipo de link (`:rss`, `:atom` ou `:json`), um hash de opções que são passadas para url_for e um hash de opções para a tag:

```erb
<%= auto_discovery_link_tag(:rss, {action: "feed"},
  {title: "RSS Feed"}) %>
```

Existem três opções de tag disponíveis para o `auto_discovery_link_tag`:

* `:rel` especifica o valor `rel` no link. O valor padrão é "alternate".
* `:type` especifica um tipo MIME explícito. O Rails gerará automaticamente um tipo MIME apropriado.
* `:title` especifica o título do link. O valor padrão é o valor `:type` em maiúsculas, por exemplo, "ATOM" ou "RSS".
#### Vinculando arquivos JavaScript com o `javascript_include_tag`

O auxiliar [`javascript_include_tag`][] retorna uma tag HTML `script` para cada fonte fornecida.

Se você estiver usando o Rails com o [Asset Pipeline](asset_pipeline.html) habilitado, esse auxiliar irá gerar um link para `/assets/javascripts/` em vez de `public/javascripts`, que era usado em versões anteriores do Rails. Esse link é então servido pelo asset pipeline.

Um arquivo JavaScript dentro de uma aplicação Rails ou um engine Rails é colocado em um dos três locais: `app/assets`, `lib/assets` ou `vendor/assets`. Esses locais são explicados em detalhes na seção [Organização de Ativos no Guia do Asset Pipeline](asset_pipeline.html#asset-organization).

Você pode especificar um caminho completo relativo à raiz do documento ou uma URL, se preferir. Por exemplo, para vincular a um arquivo JavaScript que está dentro de um diretório chamado `javascripts` dentro de `app/assets`, `lib/assets` ou `vendor/assets`, você faria isso:

```erb
<%= javascript_include_tag "main" %>
```

O Rails então irá gerar uma tag `script` como esta:

```html
<script src='/assets/main.js'></script>
```

A solicitação a esse recurso é então servida pela gem Sprockets.

Para incluir vários arquivos, como `app/assets/javascripts/main.js` e `app/assets/javascripts/columns.js` ao mesmo tempo:

```erb
<%= javascript_include_tag "main", "columns" %>
```

Para incluir `app/assets/javascripts/main.js` e `app/assets/javascripts/photos/columns.js`:

```erb
<%= javascript_include_tag "main", "/photos/columns" %>
```

Para incluir `http://example.com/main.js`:

```erb
<%= javascript_include_tag "http://example.com/main.js" %>
```

#### Vinculando arquivos CSS com o `stylesheet_link_tag`

O auxiliar [`stylesheet_link_tag`][] retorna uma tag HTML `<link>` para cada fonte fornecida.

Se você estiver usando o Rails com o "Asset Pipeline" habilitado, esse auxiliar irá gerar um link para `/assets/stylesheets/`. Esse link é então processado pela gem Sprockets. Um arquivo de folha de estilo pode ser armazenado em um dos três locais: `app/assets`, `lib/assets` ou `vendor/assets`.

Você pode especificar um caminho completo relativo à raiz do documento ou uma URL. Por exemplo, para vincular a um arquivo de folha de estilo que está dentro de um diretório chamado `stylesheets` dentro de `app/assets`, `lib/assets` ou `vendor/assets`, você faria isso:

```erb
<%= stylesheet_link_tag "main" %>
```

Para incluir `app/assets/stylesheets/main.css` e `app/assets/stylesheets/columns.css`:

```erb
<%= stylesheet_link_tag "main", "columns" %>
```

Para incluir `app/assets/stylesheets/main.css` e `app/assets/stylesheets/photos/columns.css`:

```erb
<%= stylesheet_link_tag "main", "photos/columns" %>
```

Para incluir `http://example.com/main.css`:

```erb
<%= stylesheet_link_tag "http://example.com/main.css" %>
```

Por padrão, o `stylesheet_link_tag` cria links com `rel="stylesheet"`. Você pode substituir esse padrão especificando uma opção apropriada (`:rel`):

```erb
<%= stylesheet_link_tag "main_print", media: "print" %>
```

#### Vinculando imagens com o `image_tag`

O auxiliar [`image_tag`][] cria uma tag HTML `<img />` para o arquivo especificado. Por padrão, os arquivos são carregados de `public/images`.

ATENÇÃO: Note que você deve especificar a extensão da imagem.

```erb
<%= image_tag "header.png" %>
```

Você pode fornecer um caminho para a imagem, se desejar:

```erb
<%= image_tag "icons/delete.gif" %>
```

Você pode fornecer um hash de opções HTML adicionais:

```erb
<%= image_tag "icons/delete.gif", {height: 45} %>
```

Você pode fornecer um texto alternativo para a imagem, que será usado se o usuário tiver as imagens desativadas no navegador. Se você não especificar um texto alternativo explicitamente, ele será o nome do arquivo, com a primeira letra maiúscula e sem extensão. Por exemplo, essas duas tags de imagem retornariam o mesmo código:

```erb
<%= image_tag "home.gif" %>
<%= image_tag "home.gif", alt: "Home" %>
```

Você também pode especificar uma tag de tamanho especial, no formato "{largura}x{altura}":

```erb
<%= image_tag "home.gif", size: "50x20" %>
```

Além das tags especiais acima, você pode fornecer um hash final de opções HTML padrão, como `:class`, `:id` ou `:name`:

```erb
<%= image_tag "home.gif", alt: "Go Home",
                          id: "HomeImage",
                          class: "nav_bar" %>
```

#### Vinculando vídeos com o `video_tag`

O auxiliar [`video_tag`][] cria uma tag HTML5 `<video>` para o arquivo especificado. Por padrão, os arquivos são carregados de `public/videos`.

```erb
<%= video_tag "movie.ogg" %>
```

Produz

```erb
<video src="/videos/movie.ogg" />
```

Assim como um `image_tag`, você pode fornecer um caminho, seja absoluto ou relativo ao diretório `public/videos`. Além disso, você pode especificar a opção `size: "#{largura}x#{altura}"` assim como um `image_tag`. As tags de vídeo também podem ter qualquer uma das opções HTML especificadas no final (`id`, `class`, etc).

A tag de vídeo também suporta todas as opções HTML `<video>`, através do hash de opções HTML, incluindo:

* `poster: "nome_da_imagem.png"`, fornece uma imagem para ser exibida no lugar do vídeo antes de começar a reproduzir.
* `autoplay: true`, inicia a reprodução do vídeo ao carregar a página.
* `loop: true`, repete o vídeo quando chega ao final.
* `controls: true`, fornece controles fornecidos pelo navegador para o usuário interagir com o vídeo.
* `autobuffer: true`, o vídeo irá pré-carregar o arquivo para o usuário ao carregar a página.
Você também pode especificar vários vídeos para reproduzir passando um array de vídeos para a `video_tag`:

```erb
<%= video_tag ["trailer.ogg", "movie.ogg"] %>
```

Isso irá produzir:

```erb
<video>
  <source src="/videos/trailer.ogg">
  <source src="/videos/movie.ogg">
</video>
```

#### Linkando para Arquivos de Áudio com o `audio_tag`

O helper [`audio_tag`][] constrói uma tag HTML5 `<audio>` para o arquivo especificado. Por padrão, os arquivos são carregados a partir de `public/audios`.

```erb
<%= audio_tag "music.mp3" %>
```

Você pode fornecer um caminho para o arquivo de áudio, se desejar:

```erb
<%= audio_tag "music/first_song.mp3" %>
```

Você também pode fornecer um hash de opções adicionais, como `:id`, `:class`, etc.

Assim como o `video_tag`, o `audio_tag` possui opções especiais:

* `autoplay: true`, inicia a reprodução do áudio ao carregar a página
* `controls: true`, fornece controles fornecidos pelo navegador para o usuário interagir com o áudio.
* `autobuffer: true`, o áudio pré-carregará o arquivo para o usuário ao carregar a página.

### Entendendo o `yield`

Dentro do contexto de um layout, `yield` identifica uma seção onde o conteúdo da view deve ser inserido. A maneira mais simples de usar isso é ter um único `yield`, no qual todo o conteúdo da view atualmente sendo renderizada é inserido:

```html+erb
<html>
  <head>
  </head>
  <body>
  <%= yield %>
  </body>
</html>
```

Você também pode criar um layout com várias regiões de `yield`:

```html+erb
<html>
  <head>
  <%= yield :head %>
  </head>
  <body>
  <%= yield %>
  </body>
</html>
```

O corpo principal da view sempre será renderizado no `yield` sem nome. Para renderizar conteúdo em um `yield` nomeado, você usa o método `content_for`.

### Usando o Método `content_for`

O método [`content_for`][] permite inserir conteúdo em um bloco `yield` nomeado em seu layout. Por exemplo, esta view funcionaria com o layout que você acabou de ver:

```html+erb
<% content_for :head do %>
  <title>Uma página simples</title>
<% end %>

<p>Olá, Rails!</p>
```

O resultado de renderizar esta página no layout fornecido seria este HTML:

```html+erb
<html>
  <head>
  <title>Uma página simples</title>
  </head>
  <body>
  <p>Olá, Rails!</p>
  </body>
</html>
```

O método `content_for` é muito útil quando seu layout contém regiões distintas, como barras laterais e rodapés, que devem receber seus próprios blocos de conteúdo inseridos. Também é útil para inserir tags que carregam arquivos JavaScript ou CSS específicos da página no cabeçalho de um layout genérico.

### Usando Parciais

Templates parciais - geralmente chamados apenas de "parciais" - são outro recurso para dividir o processo de renderização em partes mais gerenciáveis. Com um parcial, você pode mover o código para renderizar uma parte específica de uma resposta para seu próprio arquivo.

#### Nomeando Parciais

Para renderizar um parcial como parte de uma view, você usa o método [`render`][view.render] dentro da view:

```html+erb
<%= render "menu" %>
```

Isso irá renderizar um arquivo chamado `_menu.html.erb` naquele ponto dentro da view sendo renderizada. Observe o caractere de sublinhado inicial: os parciais são nomeados com um sublinhado inicial para distingui-los das views regulares, mesmo que sejam referenciados sem o sublinhado. Isso é verdade mesmo quando você está puxando um parcial de outra pasta:

```html+erb
<%= render "shared/menu" %>
```

Esse código irá puxar o parcial de `app/views/shared/_menu.html.erb`.


#### Usando Parciais para Simplificar Views

Uma maneira de usar parciais é tratá-los como equivalentes a sub-rotinas: como uma maneira de mover detalhes de uma view para que você possa entender o que está acontecendo mais facilmente. Por exemplo, você pode ter uma view que se pareça com isso:

```erb
<%= render "shared/ad_banner" %>

<h1>Produtos</h1>

<p>Aqui estão alguns de nossos ótimos produtos:</p>
...

<%= render "shared/footer" %>
```

Aqui, os parciais `_ad_banner.html.erb` e `_footer.html.erb` podem conter
conteúdo que é compartilhado por muitas páginas em sua aplicação. Você não precisa ver
os detalhes dessas seções quando está concentrado em uma página específica.

Como visto nas seções anteriores deste guia, `yield` é uma ferramenta muito poderosa
para limpar seus layouts. Lembre-se de que é puro Ruby, então você pode usá-lo
quase em qualquer lugar. Por exemplo, podemos usá-lo para DRY up a definição de layout de formulário para vários recursos semelhantes:

* `users/index.html.erb`

    ```html+erb
    <%= render "shared/search_filters", search: @q do |form| %>
      <p>
        Nome contém: <%= form.text_field :name_contains %>
      </p>
    <% end %>
    ```

* `roles/index.html.erb`

    ```html+erb
    <%= render "shared/search_filters", search: @q do |form| %>
      <p>
        Título contém: <%= form.text_field :title_contains %>
      </p>
    <% end %>
    ```
* `shared/_search_filters.html.erb`

    ```html+erb
    <%= form_with model: search do |form| %>
      <h1>Formulário de busca:</h1>
      <fieldset>
        <%= yield form %>
      </fieldset>
      <p>
        <%= form.submit "Buscar" %>
      </p>
    <% end %>
    ```

DICA: Para conteúdo compartilhado entre todas as páginas do seu aplicativo, você pode usar parciais diretamente nos layouts.

#### Layouts Parciais

Um parcial pode usar seu próprio arquivo de layout, assim como uma visualização pode usar um layout. Por exemplo, você pode chamar um parcial assim:

```erb
<%= render partial: "link_area", layout: "graybar" %>
```

Isso procuraria um parcial chamado `_link_area.html.erb` e o renderizaria usando o layout `_graybar.html.erb`. Observe que os layouts para parciais seguem a mesma convenção de nomenclatura com sublinhado inicial que os parciais regulares e são colocados na mesma pasta do parcial ao qual pertencem (não na pasta principal `layouts`).

Observe também que é necessário especificar explicitamente `:partial` ao passar opções adicionais como `:layout`.

#### Passando Variáveis Locais

Você também pode passar variáveis locais para parciais, tornando-os ainda mais poderosos e flexíveis. Por exemplo, você pode usar essa técnica para reduzir a duplicação entre as páginas de criação e edição, mantendo um pouco de conteúdo distinto:

* `new.html.erb`

    ```html+erb
    <h1>Nova zona</h1>
    <%= render partial: "form", locals: {zone: @zone} %>
    ```

* `edit.html.erb`

    ```html+erb
    <h1>Editando zona</h1>
    <%= render partial: "form", locals: {zone: @zone} %>
    ```

* `_form.html.erb`

    ```html+erb
    <%= form_with model: zone do |form| %>
      <p>
        <b>Nome da zona</b><br>
        <%= form.text_field :name %>
      </p>
      <p>
        <%= form.submit %>
      </p>
    <% end %>
    ```

Embora o mesmo parcial seja renderizado em ambas as visualizações, o helper de submit do Action View retornará "Criar Zona" para a ação de criação e "Atualizar Zona" para a ação de edição.

Para passar uma variável local para um parcial apenas em casos específicos, use `local_assigns`.

* `index.html.erb`

    ```erb
    <%= render user.articles %>
    ```

* `show.html.erb`

    ```erb
    <%= render article, full: true %>
    ```

* `_article.html.erb`

    ```erb
    <h2><%= article.title %></h2>

    <% if local_assigns[:full] %>
      <%= simple_format article.body %>
    <% else %>
      <%= truncate article.body %>
    <% end %>
    ```

Dessa forma, é possível usar o parcial sem a necessidade de declarar todas as variáveis locais.

Todo parcial também possui uma variável local com o mesmo nome do parcial (sem o sublinhado inicial). Você pode passar um objeto para essa variável local por meio da opção `:object`:

```erb
<%= render partial: "customer", object: @new_customer %>
```

Dentro do parcial `customer`, a variável `customer` se referirá a `@new_customer` da visualização pai.

Se você tiver uma instância de um modelo para renderizar em um parcial, pode usar uma sintaxe abreviada:

```erb
<%= render @customer %>
```

Supondo que a variável de instância `@customer` contenha uma instância do modelo `Customer`, isso usará `_customer.html.erb` para renderizá-lo e passará a variável local `customer` para o parcial, que se referirá à variável de instância `@customer` na visualização pai.

#### Renderizando Coleções

Parciais são muito úteis para renderizar coleções. Quando você passa uma coleção para um parcial por meio da opção `:collection`, o parcial será inserido uma vez para cada membro da coleção:

* `index.html.erb`

    ```html+erb
    <h1>Produtos</h1>
    <%= render partial: "product", collection: @products %>
    ```

* `_product.html.erb`

    ```html+erb
    <p>Nome do produto: <%= product.name %></p>
    ```

Quando um parcial é chamado com uma coleção pluralizada, as instâncias individuais do parcial têm acesso ao membro da coleção que está sendo renderizado por meio de uma variável com o nome do parcial. Nesse caso, o parcial é `_product`, e dentro do parcial `_product`, você pode se referir a `product` para obter a instância que está sendo renderizada.

Também há uma forma abreviada para isso. Supondo que `@products` seja uma coleção de instâncias de `Product`, você pode simplesmente escrever isso em `index.html.erb` para obter o mesmo resultado:

```html+erb
<h1>Produtos</h1>
<%= render @products %>
```

O Rails determina o nome do parcial a ser usado ao analisar o nome do modelo na coleção. Na verdade, você pode até criar uma coleção heterogênea e renderizá-la dessa maneira, e o Rails escolherá o parcial apropriado para cada membro da coleção:

* `index.html.erb`

    ```html+erb
    <h1>Contatos</h1>
    <%= render [customer1, employee1, customer2, employee2] %>
    ```

* `customers/_customer.html.erb`

    ```html+erb
    <p>Cliente: <%= customer.name %></p>
    ```

* `employees/_employee.html.erb`

    ```html+erb
    <p>Funcionário: <%= employee.name %></p>
    ```

Nesse caso, o Rails usará os parciais `customer` ou `employee` conforme apropriado para cada membro da coleção.
No caso de a coleção estar vazia, `render` retornará nil, então deve ser bastante simples fornecer um conteúdo alternativo.

```html+erb
<h1>Produtos</h1>
<%= render(@products) || "Não há produtos disponíveis." %>
```

#### Variáveis Locais

Para usar um nome de variável local personalizado dentro do parcial, especifique a opção `:as` na chamada do parcial:

```erb
<%= render partial: "product", collection: @products, as: :item %>
```

Com essa alteração, você pode acessar uma instância da coleção `@products` como a variável local `item` dentro do parcial.

Você também pode passar variáveis locais arbitrárias para qualquer parcial que você está renderizando com a opção `locals: {}`:

```erb
<%= render partial: "product", collection: @products,
           as: :item, locals: {title: "Página de Produtos"} %>
```

Nesse caso, o parcial terá acesso a uma variável local `title` com o valor "Página de Produtos".

#### Variáveis de Contagem

O Rails também disponibiliza uma variável de contagem dentro de um parcial chamado pela coleção. A variável é nomeada de acordo com o título do parcial seguido por `_counter`. Por exemplo, ao renderizar uma coleção `@products`, o parcial `_product.html.erb` pode acessar a variável `product_counter`. A variável indexa o número de vezes que o parcial foi renderizado na visualização envolvente, começando com o valor `0` na primeira renderização.

```erb
# index.html.erb
<%= render partial: "product", collection: @products %>
```

```erb
# _product.html.erb
<%= product_counter %> # 0 para o primeiro produto, 1 para o segundo produto...
```

Isso também funciona quando o nome do parcial é alterado usando a opção `as:`. Portanto, se você fizer `as: :item`, a variável de contagem será `item_counter`.

#### Modelos de Espaçadores

Você também pode especificar um segundo parcial a ser renderizado entre instâncias do parcial principal usando a opção `:spacer_template`:

```erb
<%= render partial: @products, spacer_template: "product_ruler" %>
```

O Rails irá renderizar o parcial `_product_ruler` (sem dados passados para ele) entre cada par de parciais `_product`.

#### Layouts de Parciais de Coleções

Ao renderizar coleções, também é possível usar a opção `:layout`:

```erb
<%= render partial: "product", collection: @products, layout: "special_layout" %>
```

O layout será renderizado junto com o parcial para cada item na coleção. As variáveis de objeto atual e object_counter também estarão disponíveis no layout da mesma forma que estão dentro do parcial.

### Usando Layouts Aninhados

Você pode descobrir que sua aplicação requer um layout que difere ligeiramente do layout regular da aplicação para suportar um controlador específico. Em vez de repetir o layout principal e editá-lo, você pode fazer isso usando layouts aninhados (às vezes chamados de sub-modelos). Aqui está um exemplo:

Suponha que você tenha o seguinte layout `ApplicationController`:

* `app/views/layouts/application.html.erb`

    ```html+erb
    <html>
    <head>
      <title><%= @page_title or "Título da Página" %></title>
      <%= stylesheet_link_tag "layout" %>
      <style><%= yield :stylesheets %></style>
    </head>
    <body>
      <div id="top_menu">Itens do menu superior aqui</div>
      <div id="menu">Itens do menu aqui</div>
      <div id="content"><%= content_for?(:content) ? yield(:content) : yield %></div>
    </body>
    </html>
    ```

Nas páginas geradas pelo `NewsController`, você deseja ocultar o menu superior e adicionar um menu à direita:

* `app/views/layouts/news.html.erb`

    ```html+erb
    <% content_for :stylesheets do %>
      #top_menu {display: none}
      #right_menu {float: right; background-color: yellow; color: black}
    <% end %>
    <% content_for :content do %>
      <div id="right_menu">Itens do menu à direita aqui</div>
      <%= content_for?(:news_content) ? yield(:news_content) : yield %>
    <% end %>
    <%= render template: "layouts/application" %>
    ```

É isso. As visualizações de Notícias usarão o novo layout, ocultando o menu superior e adicionando um novo menu à direita dentro da div "content".

Existem várias maneiras de obter resultados semelhantes com diferentes esquemas de sub-modelos usando essa técnica. Observe que não há limite nos níveis de aninhamento. Pode-se usar o método `ActionView::render` via `render template: 'layouts/news'` para basear um novo layout no layout de Notícias. Se você tem certeza de que não irá submodelar o layout de Notícias, você pode substituir `content_for?(:news_content) ? yield(:news_content) : yield` simplesmente por `yield`.
[controller.render]: https://api.rubyonrails.org/classes/ActionController/Rendering.html#method-i-render
[`redirect_to`]: https://api.rubyonrails.org/classes/ActionController/Redirecting.html#method-i-redirect_to
[`head`]: https://api.rubyonrails.org/classes/ActionController/Head.html#method-i-head
[`layout`]: https://api.rubyonrails.org/classes/ActionView/Layouts/ClassMethods.html#method-i-layout
[`redirect_back`]: https://api.rubyonrails.org/classes/ActionController/Redirecting.html#method-i-redirect_back
[`content_for`]: https://api.rubyonrails.org/classes/ActionView/Helpers/CaptureHelper.html#method-i-content_for
[`auto_discovery_link_tag`]: https://api.rubyonrails.org/classes/ActionView/Helpers/AssetTagHelper.html#method-i-auto_discovery_link_tag
[`javascript_include_tag`]: https://api.rubyonrails.org/classes/ActionView/Helpers/AssetTagHelper.html#method-i-javascript_include_tag
[`stylesheet_link_tag`]: https://api.rubyonrails.org/classes/ActionView/Helpers/AssetTagHelper.html#method-i-stylesheet_link_tag
[`image_tag`]: https://api.rubyonrails.org/classes/ActionView/Helpers/AssetTagHelper.html#method-i-image_tag
[`video_tag`]: https://api.rubyonrails.org/classes/ActionView/Helpers/AssetTagHelper.html#method-i-video_tag
[`audio_tag`]: https://api.rubyonrails.org/classes/ActionView/Helpers/AssetTagHelper.html#method-i-audio_tag
[view.render]: https://api.rubyonrails.org/classes/ActionView/Helpers/RenderingHelper.html#method-i-render
