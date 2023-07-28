**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: fb66c6f4aafffdb8f8d44e8a2076c9b0
Roteamento do Rails de fora para dentro
========================================

Este guia aborda os recursos voltados para o usuário do roteamento do Rails.

Após ler este guia, você saberá:

* Como interpretar o código em `config/routes.rb`.
* Como construir suas próprias rotas, usando o estilo de recursos preferido ou o método `match`.
* Como declarar parâmetros de rota, que são passados para as ações do controlador.
* Como criar automaticamente caminhos e URLs usando os auxiliares de rota.
* Técnicas avançadas, como criar restrições e montar pontos finais do Rack.

--------------------------------------------------------------------------------

O Propósito do Roteador do Rails
-------------------------------

O roteador do Rails reconhece URLs e as encaminha para uma ação do controlador ou para um aplicativo Rack. Ele também pode gerar caminhos e URLs, evitando a necessidade de codificar strings em suas visualizações.

### Conectando URLs ao Código

Quando sua aplicação Rails recebe uma solicitação de entrada para:

```
GET /patients/17
```

ela pede ao roteador para corresponder a uma ação do controlador. Se a primeira rota correspondente for:

```ruby
get '/patients/:id', to: 'patients#show'
```

a solicitação é encaminhada para a ação `show` do controlador `patients` com `{ id: '17' }` em `params`.

NOTA: O Rails usa snake_case para os nomes dos controladores aqui, se você tiver um controlador com várias palavras como `MonsterTrucksController`, você deve usar `monster_trucks#show`, por exemplo.

### Gerando Caminhos e URLs a partir do Código

Você também pode gerar caminhos e URLs. Se a rota acima for modificada para:

```ruby
get '/patients/:id', to: 'patients#show', as: 'patient'
```

e sua aplicação contiver este código no controlador:

```ruby
@patient = Patient.find(params[:id])
```

e isso na visualização correspondente:

```erb
<%= link_to 'Registro do Paciente', patient_path(@patient) %>
```

então o roteador irá gerar o caminho `/patients/17`. Isso reduz a fragilidade de sua visualização e torna seu código mais fácil de entender. Observe que o id não precisa ser especificado no auxiliar de rota.

### Configurando o Roteador do Rails

As rotas para sua aplicação ou engine estão no arquivo `config/routes.rb` e geralmente se parecem com isso:

```ruby
Rails.application.routes.draw do
  resources :brands, only: [:index, :show] do
    resources :products, only: [:index, :show]
  end

  resource :basket, only: [:show, :update, :destroy]

  resolve("Basket") { route_for(:basket) }
end
```

Como este é um arquivo de origem Ruby regular, você pode usar todos os seus recursos para ajudar a definir suas rotas, mas tenha cuidado com os nomes das variáveis, pois eles podem entrar em conflito com os métodos DSL do roteador.

NOTA: O bloco `Rails.application.routes.draw do ... end` que envolve suas definições de rota é necessário para estabelecer o escopo para o DSL do roteador e não deve ser excluído.

Roteamento de Recursos: o Padrão do Rails
----------------------------------------

O roteamento de recursos permite declarar rapidamente todas as rotas comuns para um determinado controlador de recursos. Uma única chamada para [`resources`][] pode declarar todas as rotas necessárias para suas ações `index`, `show`, `new`, `edit`, `create`, `update` e `destroy`.


### Recursos na Web

Os navegadores solicitam páginas do Rails fazendo uma solicitação de URL usando um método HTTP específico, como `GET`, `POST`, `PATCH`, `PUT` e `DELETE`. Cada método é uma solicitação para executar uma operação no recurso. Uma rota de recurso mapeia várias solicitações relacionadas para ações em um único controlador.

Quando sua aplicação Rails recebe uma solicitação de entrada para:

```
DELETE /photos/17
```

ela pede ao roteador para mapeá-la para uma ação do controlador. Se a primeira rota correspondente for:

```ruby
resources :photos
```

O Rails encaminhará essa solicitação para a ação `destroy` no controlador `photos` com `{ id: '17' }` em `params`.

### CRUD, Verbos e Ações

No Rails, uma rota de recursos fornece uma correspondência entre verbos HTTP e URLs para ações do controlador. Por convenção, cada ação também corresponde a uma operação CRUD específica em um banco de dados. Uma única entrada no arquivo de roteamento, como:

```ruby
resources :photos
```

cria sete rotas diferentes em sua aplicação, todas mapeando para o controlador `Photos`:

| Verbo HTTP | Caminho           | Controlador#Ação | Usado para                                   |
| ---------- | ----------------- | ---------------- | -------------------------------------------- |
| GET        | /photos           | photos#index     | exibir uma lista de todas as fotos            |
| GET        | /photos/new       | photos#new       | retornar um formulário HTML para criar uma nova foto |
| POST       | /photos           | photos#create    | criar uma nova foto                          |
| GET        | /photos/:id       | photos#show      | exibir uma foto específica                   |
| GET        | /photos/:id/edit  | photos#edit      | retornar um formulário HTML para editar uma foto |
| PATCH/PUT  | /photos/:id       | photos#update    | atualizar uma foto específica                |
| DELETE     | /photos/:id       | photos#destroy   | excluir uma foto específica                  |
NOTA: Como o roteador usa o verbo HTTP e a URL para corresponder às solicitações de entrada, quatro URLs mapeiam para sete ações diferentes.

NOTA: As rotas do Rails são correspondidas na ordem em que são especificadas, portanto, se você tiver `resources: photos` acima de `get 'photos/poll'`, a rota da ação `show` para a linha `resources` será correspondida antes da linha `get`. Para corrigir isso, mova a linha `get` **acima** da linha `resources` para que seja correspondida primeiro.

### Helpers de Caminho e URL

Criar uma rota de recursos também expõe um número de helpers para os controladores em sua aplicação. No caso de `resources: photos`:

* `photos_path` retorna `/photos`
* `new_photo_path` retorna `/photos/new`
* `edit_photo_path(:id)` retorna `/photos/:id/edit` (por exemplo, `edit_photo_path(10)` retorna `/photos/10/edit`)
* `photo_path(:id)` retorna `/photos/:id` (por exemplo, `photo_path(10)` retorna `/photos/10`)

Cada um desses helpers tem um helper correspondente `_url` (como `photos_url`) que retorna o mesmo caminho prefixado com o host atual, porta e prefixo do caminho.

DICA: Para encontrar os nomes dos helpers de rota para suas rotas, consulte [Listando rotas existentes](#listando-rotas-existentes) abaixo.

### Definindo Múltiplos Recursos ao Mesmo Tempo

Se você precisa criar rotas para mais de um recurso, pode economizar um pouco de digitação definindo todos eles com uma única chamada a `resources`:

```ruby
resources: photos, books, videos
```

Isso funciona exatamente da mesma forma que:

```ruby
resources: photos
resources: books
resources: videos
```

### Recursos Singulares

Às vezes, você tem um recurso que os clientes sempre procuram sem fazer referência a um ID. Por exemplo, você gostaria que `/profile` sempre mostrasse o perfil do usuário atualmente logado. Nesse caso, você pode usar um recurso singular para mapear `/profile` (em vez de `/profile/:id`) para a ação `show`:

```ruby
get 'profile', to: 'users#show'
```

Passar uma `String` para `to:` esperará um formato `controller#action`. Ao usar um `Symbol`, a opção `to:` deve ser substituída por `action:`. Ao usar uma `String` sem um `#`, a opção `to:` deve ser substituída por `controller:`:

```ruby
get 'profile', action: :show, controller: 'users'
```

Esta rota de recursos:

```ruby
resource: geocoder
resolve('Geocoder') { [:geocoder] }
```

cria seis rotas diferentes em sua aplicação, todas mapeando para o controlador `Geocoders`:

| Verbo HTTP | Caminho                  | Controlador#Ação    | Usado para                                     |
| ---------- | ------------------------ | ------------------- | ---------------------------------------------- |
| GET        | /geocoder/new            | geocoders#new       | retornar um formulário HTML para criar o geocoder |
| POST       | /geocoder                | geocoders#create    | criar o novo geocoder                          |
| GET        | /geocoder                | geocoders#show      | exibir o único recurso geocoder                |
| GET        | /geocoder/edit           | geocoders#edit      | retornar um formulário HTML para editar o geocoder |
| PATCH/PUT  | /geocoder                | geocoders#update    | atualizar o único recurso geocoder             |
| DELETE     | /geocoder                | geocoders#destroy   | excluir o recurso geocoder                     |

NOTA: Como você pode querer usar o mesmo controlador para uma rota singular (`/account`) e uma rota plural (`/accounts/45`), recursos singulares são mapeados para controladores plurais. Assim, por exemplo, `resource: photo` e `resources: photos` criam rotas tanto singulares quanto plurais que mapeiam para o mesmo controlador (`PhotosController`).

Uma rota de recursos singular gera esses helpers:

* `new_geocoder_path` retorna `/geocoder/new`
* `edit_geocoder_path` retorna `/geocoder/edit`
* `geocoder_path` retorna `/geocoder`

NOTA: A chamada para `resolve` é necessária para converter instâncias do `Geocoder` em rotas por meio da [identificação de registro](form_helpers.html#relying-on-record-identification).

Assim como recursos plurais, os mesmos helpers terminando em `_url` também incluirão o host, porta e prefixo do caminho.

### Namespaces de Controladores e Roteamento

Você pode desejar organizar grupos de controladores em um namespace. Mais comumente, você pode agrupar um número de controladores administrativos em um namespace `Admin::` e colocar esses controladores no diretório `app/controllers/admin`. Você pode rotear para esse grupo usando um bloco [`namespace`][]:

```ruby
namespace: admin do
  resources: articles, comments
end
```

Isso criará várias rotas para cada um dos controladores `articles` e `comments`. Para `Admin::ArticlesController`, o Rails criará:

| Verbo HTTP | Caminho                     | Controlador#Ação         | Helper de Rota Nomeado           |
| ---------- | --------------------------- | ----------------------- | --------------------------------- |
| GET        | /admin/articles             | admin/articles#index    | admin_articles_path              |
| GET        | /admin/articles/new         | admin/articles#new      | new_admin_article_path           |
| POST       | /admin/articles             | admin/articles#create   | admin_articles_path              |
| GET        | /admin/articles/:id         | admin/articles#show     | admin_article_path(:id)          |
| GET        | /admin/articles/:id/edit    | admin/articles#edit     | edit_admin_article_path(:id)     |
| PATCH/PUT  | /admin/articles/:id         | admin/articles#update   | admin_article_path(:id)          |
| DELETE     | /admin/articles/:id         | admin/articles#destroy  | admin_article_path(:id)          |
Se, em vez disso, você deseja rotear `/articles` (sem o prefixo `/admin`) para `Admin::ArticlesController`, você pode especificar o módulo com um bloco [`scope`][]:

```ruby
scope module: 'admin' do
  resources :articles, :comments
end
```

Isso também pode ser feito para uma única rota:

```ruby
resources :articles, module: 'admin'
```

Se, em vez disso, você deseja rotear `/admin/articles` para `ArticlesController` (sem o prefixo do módulo `Admin::`), você pode especificar o caminho com um bloco `scope`:

```ruby
scope '/admin' do
  resources :articles, :comments
end
```

Isso também pode ser feito para uma única rota:

```ruby
resources :articles, path: '/admin/articles'
```

Em ambos os casos, os ajudantes de rota nomeados permanecem os mesmos se você não usar `scope`. No último caso, os seguintes caminhos são mapeados para `ArticlesController`:

| Verbo HTTP | Caminho                   | Controlador#Ação    | Ajudante de rota nomeado |
| ---------- | ------------------------- | ------------------- | ----------------------- |
| GET        | /admin/articles           | articles#index      | articles_path           |
| GET        | /admin/articles/new       | articles#new        | new_article_path        |
| POST       | /admin/articles           | articles#create     | articles_path           |
| GET        | /admin/articles/:id       | articles#show       | article_path(:id)       |
| GET        | /admin/articles/:id/edit  | articles#edit       | edit_article_path(:id)  |
| PATCH/PUT  | /admin/articles/:id       | articles#update     | article_path(:id)       |
| DELETE     | /admin/articles/:id       | articles#destroy    | article_path(:id)       |

DICA: Se você precisar usar um namespace de controlador diferente dentro de um bloco `namespace`, você pode especificar um caminho absoluto do controlador, por exemplo: `get '/foo', to: '/foo#index'`.


### Recursos Aninhados

É comum ter recursos que são logicamente filhos de outros recursos. Por exemplo, suponha que sua aplicação inclua estes modelos:

```ruby
class Magazine < ApplicationRecord
  has_many :ads
end

class Ad < ApplicationRecord
  belongs_to :magazine
end
```

Rotas aninhadas permitem capturar esse relacionamento em seu roteamento. Nesse caso, você poderia incluir esta declaração de rota:

```ruby
resources :magazines do
  resources :ads
end
```

Além das rotas para revistas, essa declaração também roteará anúncios para um `AdsController`. As URLs de anúncios requerem uma revista:

| Verbo HTTP | Caminho                                  | Controlador#Ação | Usado para                                                                 |
| ---------- | ---------------------------------------- | ---------------- | -------------------------------------------------------------------------- |
| GET        | /magazines/:magazine_id/ads              | ads#index        | exibir uma lista de todos os anúncios de uma revista específica             |
| GET        | /magazines/:magazine_id/ads/new          | ads#new          | retornar um formulário HTML para criar um novo anúncio pertencente a uma revista específica |
| POST       | /magazines/:magazine_id/ads              | ads#create       | criar um novo anúncio pertencente a uma revista específica                 |
| GET        | /magazines/:magazine_id/ads/:id          | ads#show         | exibir um anúncio específico pertencente a uma revista específica           |
| GET        | /magazines/:magazine_id/ads/:id/edit     | ads#edit         | retornar um formulário HTML para editar um anúncio pertencente a uma revista específica |
| PATCH/PUT  | /magazines/:magazine_id/ads/:id          | ads#update       | atualizar um anúncio específico pertencente a uma revista específica        |
| DELETE     | /magazines/:magazine_id/ads/:id          | ads#destroy      | excluir um anúncio específico pertencente a uma revista específica          |

Isso também criará ajudantes de rota, como `magazine_ads_url` e `edit_magazine_ad_path`. Esses ajudantes recebem uma instância de Magazine como o primeiro parâmetro (`magazine_ads_url(@magazine)`).

#### Limites para Aninhamento

Você pode aninhar recursos dentro de outros recursos aninhados, se desejar. Por exemplo:

```ruby
resources :publishers do
  resources :magazines do
    resources :photos
  end
end
```

Recursos profundamente aninhados rapidamente se tornam complicados. Neste caso, por exemplo, a aplicação reconheceria caminhos como:

```
/publishers/1/magazines/2/photos/3
```

O ajudante de rota correspondente seria `publisher_magazine_photo_url`, exigindo que você especifique objetos em todos os três níveis. De fato, essa situação é confusa o suficiente para que um [artigo popular de Jamis Buck](http://weblog.jamisbuck.org/2007/2/5/nesting-resources) proponha uma regra geral para um bom design Rails:

DICA: Recursos nunca devem ser aninhados mais do que 1 nível de profundidade.

#### Aninhamento Raso

Uma maneira de evitar o aninhamento profundo (como recomendado acima) é gerar as ações de coleção com escopo sob o pai, para ter uma ideia da hierarquia, mas não aninhar as ações de membro. Em outras palavras, construir apenas rotas com a quantidade mínima de informações para identificar exclusivamente o recurso, assim:

```ruby
resources :articles do
  resources :comments, only: [:index, :new, :create]
end
resources :comments, only: [:show, :edit, :update, :destroy]
```

Essa ideia equilibra rotas descritivas e aninhamento profundo. Existe uma sintaxe abreviada para alcançar exatamente isso, por meio da opção `:shallow`:

```ruby
resources :articles do
  resources :comments, shallow: true
end
```
Isso irá gerar as mesmas rotas do primeiro exemplo. Você também pode especificar a opção `:shallow` no recurso pai, nesse caso todos os recursos aninhados serão rasos:

```ruby
resources :articles, shallow: true do
  resources :comments
  resources :quotes
  resources :drafts
end
```

O recurso de artigos aqui terá as seguintes rotas geradas:

| Verbo HTTP | Caminho                                         | Controlador#Ação | Helper de Rota Nomeada       |
| ---------- | ----------------------------------------------- | ---------------- | ---------------------------- |
| GET        | /articles/:article_id/comments(.:format)        | comments#index   | article_comments_path        |
| POST       | /articles/:article_id/comments(.:format)        | comments#create  | article_comments_path        |
| GET        | /articles/:article_id/comments/new(.:format)    | comments#new     | new_article_comment_path     |
| GET        | /comments/:id/edit(.:format)                    | comments#edit    | edit_comment_path            |
| GET        | /comments/:id(.:format)                         | comments#show    | comment_path                 |
| PATCH/PUT  | /comments/:id(.:format)                         | comments#update  | comment_path                 |
| DELETE     | /comments/:id(.:format)                         | comments#destroy | comment_path                 |
| GET        | /articles/:article_id/quotes(.:format)          | quotes#index     | article_quotes_path          |
| POST       | /articles/:article_id/quotes(.:format)          | quotes#create    | article_quotes_path          |
| GET        | /articles/:article_id/quotes/new(.:format)      | quotes#new       | new_article_quote_path       |
| GET        | /quotes/:id/edit(.:format)                      | quotes#edit      | edit_quote_path              |
| GET        | /quotes/:id(.:format)                           | quotes#show      | quote_path                   |
| PATCH/PUT  | /quotes/:id(.:format)                           | quotes#update    | quote_path                   |
| DELETE     | /quotes/:id(.:format)                           | quotes#destroy   | quote_path                   |
| GET        | /articles/:article_id/drafts(.:format)          | drafts#index     | article_drafts_path          |
| POST       | /articles/:article_id/drafts(.:format)          | drafts#create    | article_drafts_path          |
| GET        | /articles/:article_id/drafts/new(.:format)      | drafts#new       | new_article_draft_path       |
| GET        | /drafts/:id/edit(.:format)                      | drafts#edit      | edit_draft_path              |
| GET        | /drafts/:id(.:format)                           | drafts#show      | draft_path                   |
| PATCH/PUT  | /drafts/:id(.:format)                           | drafts#update    | draft_path                   |
| DELETE     | /drafts/:id(.:format)                           | drafts#destroy   | draft_path                   |
| GET        | /articles(.:format)                             | articles#index   | articles_path                |
| POST       | /articles(.:format)                             | articles#create  | articles_path                |
| GET        | /articles/new(.:format)                         | articles#new     | new_article_path             |
| GET        | /articles/:id/edit(.:format)                    | articles#edit    | edit_article_path            |
| GET        | /articles/:id(.:format)                         | articles#show    | article_path                 |
| PATCH/PUT  | /articles/:id(.:format)                         | articles#update  | article_path                 |
| DELETE     | /articles/:id(.:format)                         | articles#destroy | article_path                 |

O método [`shallow`][] da DSL cria um escopo no qual todos os aninhamentos são rasos. Isso gera as mesmas rotas do exemplo anterior:

```ruby
shallow do
  resources :articles do
    resources :comments
    resources :quotes
    resources :drafts
  end
end
```

Existem duas opções para `scope` personalizar rotas rasas. `:shallow_path` prefixa os caminhos dos membros com o parâmetro especificado:

```ruby
scope shallow_path: "sekret" do
  resources :articles do
    resources :comments, shallow: true
  end
end
```

O recurso de comentários aqui terá as seguintes rotas geradas:

| Verbo HTTP | Caminho                                         | Controlador#Ação | Helper de Rota Nomeada       |
| ---------- | ----------------------------------------------- | ---------------- | ---------------------------- |
| GET        | /articles/:article_id/comments(.:format)        | comments#index   | article_comments_path        |
| POST       | /articles/:article_id/comments(.:format)        | comments#create  | article_comments_path        |
| GET        | /articles/:article_id/comments/new(.:format)    | comments#new     | new_article_comment_path     |
| GET        | /sekret/comments/:id/edit(.:format)             | comments#edit    | edit_comment_path            |
| GET        | /sekret/comments/:id(.:format)                  | comments#show    | comment_path                 |
| PATCH/PUT  | /sekret/comments/:id(.:format)                  | comments#update  | comment_path                 |
| DELETE     | /sekret/comments/:id(.:format)                  | comments#destroy | comment_path                 |

A opção `:shallow_prefix` adiciona o parâmetro especificado aos helpers de rota nomeada:

```ruby
scope shallow_prefix: "sekret" do
  resources :articles do
    resources :comments, shallow: true
  end
end
```

O recurso de comentários aqui terá as seguintes rotas geradas:

| Verbo HTTP | Caminho                                         | Controlador#Ação | Helper de Rota Nomeada          |
| ---------- | ----------------------------------------------- | ---------------- | ------------------------------- |
| GET        | /articles/:article_id/comments(.:format)        | comments#index   | article_comments_path           |
| POST       | /articles/:article_id/comments(.:format)        | comments#create  | article_comments_path           |
| GET        | /articles/:article_id/comments/new(.:format)    | comments#new     | new_article_comment_path        |
| GET        | /comments/:id/edit(.:format)                    | comments#edit    | edit_sekret_comment_path        |
| GET        | /comments/:id(.:format)                         | comments#show    | sekret_comment_path             |
| PATCH/PUT  | /comments/:id(.:format)                         | comments#update  | sekret_comment_path             |
| DELETE     | /comments/:id(.:format)                         | comments#destroy | sekret_comment_path             |


### Preocupações de Roteamento

As preocupações de roteamento permitem que você declare rotas comuns que podem ser reutilizadas em outros recursos e rotas. Para definir uma preocupação, use um bloco [`concern`][]:

```ruby
concern :commentable do
  resources :comments
end

concern :image_attachable do
  resources :images, only: :index
end
```

Essas preocupações podem ser usadas em recursos para evitar duplicação de código e compartilhar comportamento entre rotas:

```ruby
resources :messages, concerns: :commentable

resources :articles, concerns: [:commentable, :image_attachable]
```

O acima é equivalente a:

```ruby
resources :messages do
  resources :comments
end

resources :articles do
  resources :comments
  resources :images, only: :index
end
```
Você também pode usá-los em qualquer lugar chamando [`concerns`][]. Por exemplo, em um bloco `scope` ou `namespace`:

```ruby
namespace :articles do
  concerns :commentable
end
```


### Criando Paths e URLs a partir de Objetos

Além de usar os ajudantes de roteamento, o Rails também pode criar paths e URLs a partir de uma matriz de parâmetros. Por exemplo, suponha que você tenha este conjunto de rotas:

```ruby
resources :magazines do
  resources :ads
end
```

Ao usar `magazine_ad_path`, você pode passar instâncias de `Magazine` e `Ad` em vez dos IDs numéricos:

```erb
<%= link_to 'Detalhes do anúncio', magazine_ad_path(@magazine, @ad) %>
```

Você também pode usar [`url_for`][ActionView::RoutingUrlFor#url_for] com um conjunto de objetos, e o Rails determinará automaticamente qual rota você deseja:

```erb
<%= link_to 'Detalhes do anúncio', url_for([@magazine, @ad]) %>
```

Nesse caso, o Rails verá que `@magazine` é um `Magazine` e `@ad` é um `Ad` e, portanto, usará o ajudante `magazine_ad_path`. Em ajudantes como `link_to`, você pode especificar apenas o objeto no lugar da chamada completa `url_for`:

```erb
<%= link_to 'Detalhes do anúncio', [@magazine, @ad] %>
```

Se você quiser vincular apenas a uma revista:

```erb
<%= link_to 'Detalhes da revista', @magazine %>
```

Para outras ações, você só precisa inserir o nome da ação como o primeiro elemento da matriz:

```erb
<%= link_to 'Editar anúncio', [:edit, @magazine, @ad] %>
```

Isso permite tratar instâncias de seus modelos como URLs e é uma vantagem fundamental ao usar o estilo de recursos.


### Adicionando mais ações RESTful

Você não está limitado às sete rotas que o roteamento RESTful cria por padrão. Se desejar, você pode adicionar rotas adicionais que se aplicam à coleção ou a membros individuais da coleção.

#### Adicionando rotas de membros

Para adicionar uma rota de membro, basta adicionar um bloco [`member`][] ao bloco de recurso:

```ruby
resources :photos do
  member do
    get 'preview'
  end
end
```

Isso reconhecerá `/photos/1/preview` com GET e roteará para a ação `preview` do `PhotosController`, com o valor do ID do recurso passado em `params[:id]`. Ele também criará os ajudantes `preview_photo_url` e `preview_photo_path`.

Dentro do bloco de rotas de membros, cada nome de rota especifica o verbo HTTP que será reconhecido. Você pode usar [`get`][], [`patch`][], [`put`][], [`post`][] ou [`delete`][] aqui. Se você não tiver várias rotas de `member`, também pode passar `:on` para uma rota, eliminando o bloco:

```ruby
resources :photos do
  get 'preview', on: :member
end
```

Você pode deixar de fora a opção `:on`, isso criará a mesma rota de membro, exceto que o valor do ID do recurso estará disponível em `params[:photo_id]` em vez de `params[:id]`. Os ajudantes de rota também serão renomeados de `preview_photo_url` e `preview_photo_path` para `photo_preview_url` e `photo_preview_path`.


#### Adicionando rotas de coleção

Para adicionar uma rota à coleção, use um bloco [`collection`][]:

```ruby
resources :photos do
  collection do
    get 'search'
  end
end
```

Isso permitirá que o Rails reconheça paths como `/photos/search` com GET e roteie para a ação `search` do `PhotosController`. Ele também criará os ajudantes de rota `search_photos_url` e `search_photos_path`.

Assim como nas rotas de membros, você pode passar `:on` para uma rota:

```ruby
resources :photos do
  get 'search', on: :collection
end
```

NOTA: Se você estiver definindo rotas de recursos adicionais com um símbolo como o primeiro argumento posicional, esteja ciente de que não é equivalente ao uso de uma string. Símbolos inferem ações do controlador enquanto strings inferem caminhos.


#### Adicionando rotas para ações novas adicionais

Para adicionar uma ação nova alternativa usando o atalho `:on`:

```ruby
resources :comments do
  get 'preview', on: :new
end
```

Isso permitirá que o Rails reconheça paths como `/comments/new/preview` com GET e roteie para a ação `preview` do `CommentsController`. Ele também criará os ajudantes de rota `preview_new_comment_url` e `preview_new_comment_path`.

DICA: Se você se encontrar adicionando muitas ações extras a uma rota de recursos, é hora de parar e se perguntar se você está disfarçando a presença de outro recurso.

Rotas não-resourceful
----------------------

Além do roteamento de recursos, o Rails tem suporte poderoso para rotear URLs arbitrários para ações. Aqui, você não obtém grupos de rotas gerados automaticamente pelo roteamento de recursos. Em vez disso, você configura cada rota separadamente dentro de sua aplicação.

Embora você deva usar o roteamento de recursos na maioria das vezes, ainda existem muitos lugares onde o roteamento mais simples é mais apropriado. Não há necessidade de tentar encaixar cada pedaço de sua aplicação em um framework de recursos se isso não for adequado.
Em particular, o roteamento simples torna muito fácil mapear URLs legadas para novas ações do Rails.

### Parâmetros vinculados

Ao configurar uma rota regular, você fornece uma série de símbolos que o Rails mapeia para partes de uma solicitação HTTP recebida. Por exemplo, considere esta rota:

```ruby
get 'photos(/:id)', to: 'photos#display'
```

Se uma solicitação recebida de `/photos/1` for processada por esta rota (porque não correspondeu a nenhuma rota anterior no arquivo), o resultado será invocar a ação `display` do `PhotosController` e disponibilizar o parâmetro final `"1"` como `params[:id]`. Esta rota também roteará a solicitação recebida de `/photos` para `PhotosController#display`, uma vez que `:id` é um parâmetro opcional, indicado por parênteses.

### Segmentos dinâmicos

Você pode configurar quantos segmentos dinâmicos desejar em uma rota regular. Qualquer segmento estará disponível para a ação como parte de `params`. Se você configurar esta rota:

```ruby
get 'photos/:id/:user_id', to: 'photos#show'
```

Um caminho de entrada de `/photos/1/2` será despachado para a ação `show` do `PhotosController`. `params[:id]` será `"1"` e `params[:user_id]` será `"2"`.

DICA: Por padrão, os segmentos dinâmicos não aceitam pontos - isso ocorre porque o ponto é usado como separador para rotas formatadas. Se você precisar usar um ponto dentro de um segmento dinâmico, adicione uma restrição que substitua isso - por exemplo, `id: /[^\/]+/` permite qualquer coisa, exceto uma barra.

### Segmentos estáticos

Você pode especificar segmentos estáticos ao criar uma rota sem adicionar dois pontos a um segmento:

```ruby
get 'photos/:id/with_user/:user_id', to: 'photos#show'
```

Esta rota responderia a caminhos como `/photos/1/with_user/2`. Neste caso, `params` seria `{ controller: 'photos', action: 'show', id: '1', user_id: '2' }`.

### A string de consulta

O `params` também incluirá quaisquer parâmetros da string de consulta. Por exemplo, com esta rota:

```ruby
get 'photos/:id', to: 'photos#show'
```

Um caminho de entrada de `/photos/1?user_id=2` será despachado para a ação `show` do controlador `Photos`. `params` será `{ controller: 'photos', action: 'show', id: '1', user_id: '2' }`.

### Definindo padrões

Você pode definir padrões em uma rota fornecendo um hash para a opção `:defaults`. Isso também se aplica a parâmetros que você não especifica como segmentos dinâmicos. Por exemplo:

```ruby
get 'photos/:id', to: 'photos#show', defaults: { format: 'jpg' }
```

O Rails corresponderia `photos/12` à ação `show` de `PhotosController` e definiria `params[:format]` como `"jpg"`.

Você também pode usar um bloco [`defaults`][] para definir os padrões para vários itens:

```ruby
defaults format: :json do
  resources :photos
end
```

NOTA: Você não pode substituir padrões por meio de parâmetros de consulta - isso é por motivos de segurança. Os únicos padrões que podem ser substituídos são segmentos dinâmicos por substituição no caminho da URL.

### Nomeando rotas

Você pode especificar um nome para qualquer rota usando a opção `:as`:

```ruby
get 'exit', to: 'sessions#destroy', as: :logout
```

Isso criará `logout_path` e `logout_url` como auxiliares de rota nomeados em seu aplicativo. Chamar `logout_path` retornará `/exit`.

Você também pode usar isso para substituir os métodos de roteamento definidos por recursos, colocando rotas personalizadas antes que o recurso seja definido, assim:

```ruby
get ':username', to: 'users#show', as: :user
resources :users
```

Isso definirá um método `user_path` que estará disponível em controladores, ajudantes e visualizações e que irá para uma rota como `/bob`. Dentro da ação `show` de `UsersController`, `params[:username]` conterá o nome de usuário do usuário. Altere `:username` na definição da rota se você não quiser que o nome do parâmetro seja `:username`.

### Restrições de verbo HTTP

Em geral, você deve usar os métodos [`get`][], [`post`][], [`put`][], [`patch`][] e [`delete`][] para restringir uma rota a um verbo específico. Você pode usar o método [`match`][] com a opção `:via` para corresponder a vários verbos de uma vez:

```ruby
match 'photos', to: 'photos#show', via: [:get, :post]
```

Você pode corresponder a todos os verbos a uma rota específica usando `via: :all`:

```ruby
match 'photos', to: 'photos#show', via: :all
```

NOTA: Rotear solicitações `GET` e `POST` para uma única ação tem implicações de segurança. Em geral, você deve evitar rotear todos os verbos para uma ação, a menos que tenha um bom motivo.

NOTA: O `GET` no Rails não verifica o token CSRF. Você nunca deve escrever no banco de dados a partir de solicitações `GET`, para mais informações, consulte o [guia de segurança](security.html#csrf-countermeasures) sobre contramedidas CSRF.
### Restrições de Segmento

Você pode usar a opção `:constraints` para impor um formato para um segmento dinâmico:

```ruby
get 'photos/:id', to: 'photos#show', constraints: { id: /[A-Z]\d{5}/ }
```

Esta rota corresponderia a caminhos como `/photos/A12345`, mas não a `/photos/893`. Você pode expressar de forma mais sucinta a mesma rota desta maneira:

```ruby
get 'photos/:id', to: 'photos#show', id: /[A-Z]\d{5}/
```

`:constraints` aceita expressões regulares com a restrição de que âncoras de expressões regulares não podem ser usadas. Por exemplo, a seguinte rota não funcionará:

```ruby
get '/:id', to: 'articles#show', constraints: { id: /^\d/ }
```

No entanto, observe que você não precisa usar âncoras porque todas as rotas são ancoradas no início e no final.

Por exemplo, as seguintes rotas permitiriam que `articles` com valores `to_param` como `1-hello-world` que sempre começam com um número e `users` com valores `to_param` como `david` que nunca começam com um número compartilhem o namespace raiz:

```ruby
get '/:id', to: 'articles#show', constraints: { id: /\d.+/ }
get '/:username', to: 'users#show'
```

### Restrições Baseadas em Requisição

Você também pode restringir uma rota com base em qualquer método no [objeto Request](action_controller_overview.html#the-request-object) que retorna uma `String`.

Você especifica uma restrição baseada em requisição da mesma maneira que especifica uma restrição de segmento:

```ruby
get 'photos', to: 'photos#index', constraints: { subdomain: 'admin' }
```

Você também pode especificar restrições usando um bloco [`constraints`][]:

```ruby
namespace :admin do
  constraints subdomain: 'admin' do
    resources :photos
  end
end
```

NOTA: As restrições de requisição funcionam chamando um método no [objeto Request](action_controller_overview.html#the-request-object) com o mesmo nome que a chave do hash e comparando o valor de retorno com o valor do hash. Portanto, os valores das restrições devem corresponder ao tipo de retorno do método correspondente do objeto Request. Por exemplo: `constraints: { subdomain: 'api' }` corresponderá a um subdomínio `api` como esperado. No entanto, usar um símbolo `constraints: { subdomain: :api }` não corresponderá, porque `request.subdomain` retorna `'api'` como uma String.

NOTA: Há uma exceção para a restrição `format`: embora seja um método no objeto Request, também é um parâmetro opcional implícito em todos os caminhos. Restrições de segmento têm prioridade e a restrição `format` é aplicada apenas quando é aplicada através de um hash. Por exemplo, `get 'foo', constraints: { format: 'json' }` corresponderá a `GET  /foo` porque o formato é opcional por padrão. No entanto, você pode [usar um lambda](#advanced-constraints) como em `get 'foo', constraints: lambda { |req| req.format == :json }` e a rota só corresponderá a solicitações JSON explícitas.


### Restrições Avançadas

Se você tiver uma restrição mais avançada, pode fornecer um objeto que responda a `matches?` que o Rails deve usar. Digamos que você queira rotear todos os usuários em uma lista restrita para o `RestrictedListController`. Você pode fazer assim:

```ruby
class RestrictedListConstraint
  def initialize
    @ips = RestrictedList.retrieve_ips
  end

  def matches?(request)
    @ips.include?(request.remote_ip)
  end
end

Rails.application.routes.draw do
  get '*path', to: 'restricted_list#index',
    constraints: RestrictedListConstraint.new
end
```

Você também pode especificar restrições como um lambda:

```ruby
Rails.application.routes.draw do
  get '*path', to: 'restricted_list#index',
    constraints: lambda { |request| RestrictedList.retrieve_ips.include?(request.remote_ip) }
end
```

Tanto o método `matches?` quanto o lambda recebem o objeto `request` como argumento.

#### Restrições no Formato de Bloco

Você pode especificar restrições no formato de bloco. Isso é útil quando você precisa aplicar a mesma regra a várias rotas. Por exemplo:

```ruby
class RestrictedListConstraint
  # ...Mesmo que o exemplo acima
end

Rails.application.routes.draw do
  constraints(RestrictedListConstraint.new) do
    get '*path', to: 'restricted_list#index'
    get '*other-path', to: 'other_restricted_list#index'
  end
end
```

Você também pode usar um `lambda`:

```ruby
Rails.application.routes.draw do
  constraints(lambda { |request| RestrictedList.retrieve_ips.include?(request.remote_ip) }) do
    get '*path', to: 'restricted_list#index'
    get '*other-path', to: 'other_restricted_list#index'
  end
end
```

### Agrupamento de Rotas e Segmentos de Curinga

O agrupamento de rotas é uma maneira de especificar que um determinado parâmetro deve corresponder a todas as partes restantes de uma rota. Por exemplo:

```ruby
get 'photos/*other', to: 'photos#unknown'
```

Esta rota corresponderia a `photos/12` ou `/photos/long/path/to/12`, definindo `params[:other]` como `"12"` ou `"long/path/to/12"`. Os segmentos prefixados com um asterisco são chamados de "segmentos curinga".

Segmentos curinga podem ocorrer em qualquer lugar de uma rota. Por exemplo:

```ruby
get 'books/*section/:title', to: 'books#show'
```

corresponderia a `books/some/section/last-words-a-memoir` com `params[:section]` igual a `'some/section'` e `params[:title]` igual a `'last-words-a-memoir'`.

Tecnicamente, uma rota pode ter mais de um segmento curinga. O matcher atribui segmentos a parâmetros de maneira intuitiva. Por exemplo:

```ruby
get '*a/foo/*b', to: 'test#index'
```

corresponderia a `zoo/woo/foo/bar/baz` com `params[:a]` igual a `'zoo/woo'` e `params[:b]` igual a `'bar/baz'`.
NOTA: Ao solicitar `'/foo/bar.json'`, seus `params[:pages]` serão iguais a `'foo/bar'` com o formato de solicitação JSON. Se você quiser recuperar o comportamento antigo da versão 3.0.x, você pode fornecer `format: false` desta forma:

```ruby
get '*pages', to: 'pages#show', format: false
```

NOTA: Se você quiser tornar o segmento de formato obrigatório, para que não possa ser omitido, você pode fornecer `format: true` desta forma:

```ruby
get '*pages', to: 'pages#show', format: true
```

### Redirecionamento

Você pode redirecionar qualquer caminho para outro caminho usando o auxiliar [`redirect`][] em seu roteador:

```ruby
get '/stories', to: redirect('/articles')
```

Você também pode reutilizar segmentos dinâmicos da correspondência no caminho para redirecionar para:

```ruby
get '/stories/:name', to: redirect('/articles/%{name}')
```

Você também pode fornecer um bloco para `redirect`, que recebe os parâmetros de caminho simbolizados e o objeto de solicitação:

```ruby
get '/stories/:name', to: redirect { |path_params, req| "/articles/#{path_params[:name].pluralize}" }
get '/stories', to: redirect { |path_params, req| "/articles/#{req.subdomain}" }
```

Observe que o redirecionamento padrão é um redirecionamento 301 "Movido permanentemente". Tenha em mente que alguns navegadores da web ou servidores proxy podem armazenar em cache esse tipo de redirecionamento, tornando a página antiga inacessível. Você pode usar a opção `:status` para alterar o status da resposta:

```ruby
get '/stories/:name', to: redirect('/articles/%{name}', status: 302)
```

Em todos esses casos, se você não fornecer o host principal (`http://www.example.com`), o Rails usará esses detalhes da solicitação atual.


### Roteamento para Aplicações Rack

Em vez de uma String como `'articles#index'`, que corresponde à ação `index` no `ArticlesController`, você pode especificar qualquer [aplicativo Rack](rails_on_rack.html) como o ponto final para um correspondente:

```ruby
match '/application.js', to: MyRackApp, via: :all
```

Desde que `MyRackApp` responda a `call` e retorne um `[status, headers, body]`, o roteador não saberá a diferença entre o aplicativo Rack e uma ação. Este é um uso apropriado de `via: :all`, pois você desejará permitir que seu aplicativo Rack manipule todos os verbos conforme considerar apropriado.

NOTA: Para os curiosos, `'articles#index'` na verdade se expande para `ArticlesController.action(:index)`, que retorna um aplicativo Rack válido.

NOTA: Como os proc/lambdas são objetos que respondem a `call`, você pode implementar rotas muito simples (por exemplo, para verificações de integridade) inline:<br>`get '/health', to: ->(env) { [204, {}, ['']] }`

Se você especificar um aplicativo Rack como o ponto final para um correspondente, lembre-se de que
a rota não será alterada na aplicação receptora. Com a seguinte
rota, seu aplicativo Rack deve esperar que a rota seja `/admin`:

```ruby
match '/admin', to: AdminApp, via: :all
```

Se você preferir que seu aplicativo Rack receba solicitações no caminho raiz
em vez disso, use [`mount`][]:

```ruby
mount AdminApp, at: '/admin'
```


### Usando `root`

Você pode especificar para onde o Rails deve rotear `'/'` com o método [`root`][]:

```ruby
root to: 'pages#main'
root 'pages#main' # atalho para o acima
```

Você deve colocar a rota `root` no topo do arquivo, porque é a rota mais popular e deve ser correspondida primeiro.

NOTA: A rota `root` apenas roteia solicitações `GET` para a ação.

Você também pode usar `root` dentro de namespaces e escopos também. Por exemplo:

```ruby
namespace :admin do
  root to: "admin#index"
end

root to: "home#index"
```


### Rotas de Caracteres Unicode

Você pode especificar rotas de caracteres Unicode diretamente. Por exemplo:

```ruby
get 'こんにちは', to: 'welcome#index'
```

### Rotas Diretas

Você pode criar auxiliares de URL personalizados diretamente chamando [`direct`][]. Por exemplo:

```ruby
direct :homepage do
  "https://rubyonrails.org"
end

# >> homepage_url
# => "https://rubyonrails.org"
```

O valor de retorno do bloco deve ser um argumento válido para o método `url_for`. Portanto, você pode passar uma URL de string válida, Hash, Array, uma instância do Active Model ou uma classe do Active Model.

```ruby
direct :commentable do |model|
  [ model, anchor: model.dom_id ]
end

direct :main do
  { controller: 'pages', action: 'index', subdomain: 'www' }
end
```


### Usando `resolve`

O método [`resolve`][] permite personalizar o mapeamento polimórfico de modelos. Por exemplo:

```ruby
resource :basket

resolve("Basket") { [:basket] }
```

```erb
<%= form_with model: @basket do |form| %>
  <!-- formulário de cesta -->
<% end %>
```

Isso irá gerar a URL singular `/basket` em vez do usual `/baskets/:id`.


Personalizando Rotas de Recursos
------------------------------

Embora as rotas e auxiliares padrão gerados por [`resources`][] geralmente atendam às suas necessidades, você pode personalizá-los de alguma forma. O Rails permite que você personalize praticamente qualquer parte genérica dos auxiliares de recursos.
### Especificando um Controlador a ser Utilizado

A opção `:controller` permite especificar explicitamente um controlador a ser utilizado para o recurso. Por exemplo:

```ruby
resources :photos, controller: 'images'
```

reconhecerá os caminhos de entrada que começam com `/photos`, mas roteará para o controlador `Images`:

| Verbo HTTP | Caminho          | Controlador#Ação | Helper de Rota Nomeada |
| ---------- | ---------------- | ---------------- | ---------------------- |
| GET        | /photos          | images#index     | photos_path            |
| GET        | /photos/new      | images#new       | new_photo_path         |
| POST       | /photos          | images#create    | photos_path            |
| GET        | /photos/:id      | images#show      | photo_path(:id)        |
| GET        | /photos/:id/edit | images#edit      | edit_photo_path(:id)   |
| PATCH/PUT  | /photos/:id      | images#update    | photo_path(:id)        |
| DELETE     | /photos/:id      | images#destroy   | photo_path(:id)        |

NOTA: Use `photos_path`, `new_photo_path`, etc. para gerar caminhos para este recurso.

Para controladores com namespace, você pode usar a notação de diretório. Por exemplo:

```ruby
resources :user_permissions, controller: 'admin/user_permissions'
```

Isso roteará para o controlador `Admin::UserPermissions`.

NOTA: Somente a notação de diretório é suportada. Especificar o controlador com a notação de constante Ruby (por exemplo, `controller: 'Admin::UserPermissions'`) pode causar problemas de roteamento e resultar em um aviso.

### Especificando Restrições

Você pode usar a opção `:constraints` para especificar um formato necessário para o `id` implícito. Por exemplo:

```ruby
resources :photos, constraints: { id: /[A-Z][A-Z][0-9]+/ }
```

Essa declaração restringe o parâmetro `:id` a corresponder à expressão regular fornecida. Portanto, neste caso, o roteador não corresponderia mais `/photos/1` a esta rota. Em vez disso, `/photos/RR27` corresponderia.

Você pode especificar uma única restrição para aplicar a várias rotas usando a forma de bloco:

```ruby
constraints(id: /[A-Z][A-Z][0-9]+/) do
  resources :photos
  resources :accounts
end
```

NOTA: Claro, você pode usar as restrições mais avançadas disponíveis em rotas não-resourceful neste contexto.

DICA: Por padrão, o parâmetro `:id` não aceita pontos - isso ocorre porque o ponto é usado como separador para rotas formatadas. Se você precisar usar um ponto dentro de um `:id`, adicione uma restrição que substitua isso - por exemplo, `id: /[^\/]+/` permite qualquer coisa, exceto uma barra.

### Substituindo os Helpers de Rota Nomeada

A opção `:as` permite substituir a nomenclatura normal para os helpers de rota nomeada. Por exemplo:

```ruby
resources :photos, as: 'images'
```

reconhecerá os caminhos de entrada que começam com `/photos` e roteará as solicitações para `PhotosController`, mas usará o valor da opção `:as` para nomear os helpers.

| Verbo HTTP | Caminho          | Controlador#Ação | Helper de Rota Nomeada |
| ---------- | ---------------- | ---------------- | ---------------------- |
| GET        | /photos          | photos#index     | images_path            |
| GET        | /photos/new      | photos#new       | new_image_path         |
| POST       | /photos          | photos#create    | images_path            |
| GET        | /photos/:id      | photos#show      | image_path(:id)        |
| GET        | /photos/:id/edit | photos#edit      | edit_image_path(:id)   |
| PATCH/PUT  | /photos/:id      | photos#update    | image_path(:id)        |
| DELETE     | /photos/:id      | photos#destroy   | image_path(:id)        |

### Substituindo os Segmentos `new` e `edit`

A opção `:path_names` permite substituir os segmentos `new` e `edit` gerados automaticamente nos caminhos:

```ruby
resources :photos, path_names: { new: 'make', edit: 'change' }
```

Isso faria com que o roteamento reconhecesse caminhos como:

```
/photos/make
/photos/1/change
```

NOTA: Os nomes reais das ações não são alterados por essa opção. Os dois caminhos mostrados ainda seriam roteados para as ações `new` e `edit`.

DICA: Se você se encontrar querendo alterar essa opção uniformemente para todas as suas rotas, você pode usar um escopo, como abaixo:

```ruby
scope path_names: { new: 'make' } do
  # restante das suas rotas
end
```

### Prefixando os Helpers de Rota Nomeada

Você pode usar a opção `:as` para prefixar os helpers de rota nomeada que o Rails gera para uma rota. Use essa opção para evitar colisões de nomes entre rotas usando um escopo de caminho. Por exemplo:

```ruby
scope 'admin' do
  resources :photos, as: 'admin_photos'
end

resources :photos
```

Isso altera os helpers de rota para `/admin/photos` de `photos_path`,
`new_photos_path`, etc. para `admin_photos_path`, `new_admin_photo_path`,
etc. Sem a adição de `as: 'admin_photos` no escopo `resources
:photos`, o `resources :photos` não terá nenhum helper de rota.

Para prefixar um grupo de helpers de rota, use `:as` com `scope`:

```ruby
scope 'admin', as: 'admin' do
  resources :photos, :accounts
end

resources :photos, :accounts
```

Assim como antes, isso altera os helpers de recursos com escopo `/admin` para
`admin_photos_path` e `admin_accounts_path`, e permite que os recursos sem escopo
usem `photos_path` e `accounts_path`.
NOTA: O escopo `namespace` adicionará automaticamente os prefixos `:as`, `:module` e `:path`.

#### Escopos Paramétricos

Você pode prefixar rotas com um parâmetro nomeado:

```ruby
scope ':account_id', as: 'account', constraints: { account_id: /\d+/ } do
  resources :articles
end
```

Isso fornecerá caminhos como `/1/articles/9` e permitirá que você faça referência à parte `account_id` do caminho como `params[:account_id]` em controladores, ajudantes e visualizações.

Também gerará ajudantes de caminho e URL prefixados com `account_`, nos quais você pode passar seus objetos como esperado:

```ruby
account_article_path(@account, @article) # => /1/article/9
url_for([@account, @article])            # => /1/article/9
form_with(model: [@account, @article])   # => <form action="/1/article/9" ...>
```

Estamos [usando uma restrição](#segment-constraints) para limitar o escopo para corresponder apenas a strings semelhantes a ID. Você pode alterar a restrição para atender às suas necessidades ou omiti-la completamente. A opção `:as` também não é estritamente necessária, mas sem ela, o Rails gerará um erro ao avaliar `url_for([@account, @article])` ou outros ajudantes que dependem de `url_for`, como [`form_with`][].


### Restringindo as Rotas Criadas

Por padrão, o Rails cria rotas para as sete ações padrão (`index`, `show`, `new`, `create`, `edit`, `update` e `destroy`) para todas as rotas RESTful em sua aplicação. Você pode usar as opções `:only` e `:except` para ajustar esse comportamento. A opção `:only` diz ao Rails para criar apenas as rotas especificadas:

```ruby
resources :photos, only: [:index, :show]
```

Agora, uma solicitação `GET` para `/photos` terá sucesso, mas uma solicitação `POST` para `/photos` (que normalmente seria roteada para a ação `create`) falhará.

A opção `:except` especifica uma rota ou lista de rotas que o Rails _não_ deve criar:

```ruby
resources :photos, except: :destroy
```

Nesse caso, o Rails criará todas as rotas normais, exceto a rota para `destroy` (uma solicitação `DELETE` para `/photos/:id`).

DICA: Se sua aplicação tiver muitas rotas RESTful, usar `:only` e `:except` para gerar apenas as rotas que você realmente precisa pode reduzir o uso de memória e acelerar o processo de roteamento.

### Caminhos Traduzidos

Usando `scope`, podemos alterar os nomes dos caminhos gerados por `resources`:

```ruby
scope(path_names: { new: 'neu', edit: 'bearbeiten' }) do
  resources :categories, path: 'kategorien'
end
```

Agora o Rails cria rotas para o `CategoriesController`.

| Verbo HTTP | Caminho                       | Controlador#Ação | Ajudante de Rota Nomeado |
| ---------- | ----------------------------- | ---------------- | ----------------------- |
| GET        | /kategorien                   | categories#index | categories_path         |
| GET        | /kategorien/neu               | categories#new   | new_category_path       |
| POST       | /kategorien                   | categories#create| categories_path         |
| GET        | /kategorien/:id               | categories#show  | category_path(:id)      |
| GET        | /kategorien/:id/bearbeiten    | categories#edit  | edit_category_path(:id) |
| PATCH/PUT  | /kategorien/:id               | categories#update| category_path(:id)      |
| DELETE     | /kategorien/:id               | categories#destroy| category_path(:id)     |

### Sobrescrevendo o Formulário Singular

Se você deseja substituir o formulário singular de um recurso, deve adicionar regras adicionais ao inflector via [`inflections`][]:

```ruby
ActiveSupport::Inflector.inflections do |inflect|
  inflect.irregular 'tooth', 'teeth'
end
```


### Usando `:as` em Recursos Aninhados

A opção `:as` substitui o nome gerado automaticamente para o recurso em ajudantes de rota aninhados. Por exemplo:

```ruby
resources :magazines do
  resources :ads, as: 'periodical_ads'
end
```

Isso criará ajudantes de roteamento como `magazine_periodical_ads_url` e `edit_magazine_periodical_ad_path`.

### Sobrescrevendo Parâmetros Nomeados de Rota

A opção `:param` substitui o identificador de recurso padrão `:id` (nome do [segmento dinâmico](routing.html#dynamic-segments) usado para gerar as rotas). Você pode acessar esse segmento do seu controlador usando `params[<:param>]`.

```ruby
resources :videos, param: :identifier
```

```
    videos GET  /videos(.:format)                  videos#index
           POST /videos(.:format)                  videos#create
 new_video GET  /videos/new(.:format)              videos#new
edit_video GET  /videos/:identifier/edit(.:format) videos#edit
```

```ruby
Video.find_by(identifier: params[:identifier])
```

Você pode substituir `ActiveRecord::Base#to_param` do modelo associado para construir
uma URL:

```ruby
class Video < ApplicationRecord
  def to_param
    identifier
  end
end
```

```ruby
video = Video.find_by(identifier: "Roman-Holiday")
edit_video_path(video) # => "/videos/Roman-Holiday/edit"
```

Dividindo um Arquivo de Rotas *Muito* Grande em Vários Arquivos Pequenos
-------------------------------------------------------

Se você trabalha em um aplicativo grande com milhares de rotas, um único arquivo `config/routes.rb` pode se tornar complicado e difícil de ler.

O Rails oferece uma maneira de dividir um único arquivo `routes.rb` gigantesco em vários arquivos pequenos usando a macro [`draw`][].

Você pode ter um arquivo de rota `admin.rb` que contém todas as rotas para a área de administração, outro arquivo `api.rb` para recursos relacionados à API, etc.

```ruby
# config/routes.rb

Rails.application.routes.draw do
  get 'foo', to: 'foo#bar'

  draw(:admin) # Carregará outro arquivo de rota localizado em `config/routes/admin.rb`
end
```
```ruby
# config/routes/admin.rb

namespace :admin do
  resources :comments
end
```

Chamar `draw(:admin)` dentro do bloco `Rails.application.routes.draw` irá tentar carregar um arquivo de rota
que tenha o mesmo nome do argumento fornecido (`admin.rb` neste exemplo).
O arquivo precisa estar localizado dentro do diretório `config/routes` ou qualquer subdiretório (por exemplo, `config/routes/admin.rb` ou `config/routes/external/admin.rb`).

Você pode usar a DSL de roteamento normal dentro do arquivo de roteamento `admin.rb`, mas **não** deve envolvê-lo com o bloco `Rails.application.routes.draw` como fez no arquivo principal `config/routes.rb`.


### Não use esse recurso a menos que você realmente precise

Ter vários arquivos de rota torna a descoberta e a compreensão mais difíceis. Para a maioria das aplicações - mesmo aquelas com algumas centenas de rotas - é mais fácil para os desenvolvedores ter um único arquivo de rota. A DSL de roteamento do Rails já oferece uma maneira de dividir as rotas de forma organizada com `namespace` e `scope`.


Inspecionando e testando rotas
------------------------------

O Rails oferece recursos para inspecionar e testar suas rotas.

### Listando as rotas existentes

Para obter uma lista completa das rotas disponíveis em sua aplicação, visite <http://localhost:3000/rails/info/routes> em seu navegador enquanto o servidor estiver em execução no ambiente de **desenvolvimento**. Você também pode executar o comando `bin/rails routes` em seu terminal para produzir a mesma saída.

Ambos os métodos listarão todas as suas rotas, na mesma ordem em que aparecem em `config/routes.rb`. Para cada rota, você verá:

* O nome da rota (se houver)
* O verbo HTTP usado (se a rota não responder a todos os verbos)
* O padrão de URL a ser correspondido
* Os parâmetros de roteamento para a rota

Por exemplo, aqui está uma pequena seção da saída de `bin/rails routes` para uma rota RESTful:

```
    users GET    /users(.:format)          users#index
          POST   /users(.:format)          users#create
 new_user GET    /users/new(.:format)      users#new
edit_user GET    /users/:id/edit(.:format) users#edit
```

Você também pode usar a opção `--expanded` para ativar o modo de formatação de tabela expandida.

```bash
$ bin/rails routes --expanded

--[ Rota 1 ]----------------------------------------------------
Prefixo           | users
Verbo             | GET
URI               | /users(.:format)
Controlador#Ação  | users#index
--[ Rota 2 ]----------------------------------------------------
Prefixo           |
Verbo             | POST
URI               | /users(.:format)
Controlador#Ação  | users#create
--[ Rota 3 ]----------------------------------------------------
Prefixo           | new_user
Verbo             | GET
URI               | /users/new(.:format)
Controlador#Ação  | users#new
--[ Rota 4 ]----------------------------------------------------
Prefixo           | edit_user
Verbo             | GET
URI               | /users/:id/edit(.:format)
Controlador#Ação  | users#edit
```

Você pode pesquisar suas rotas com a opção grep: -g. Isso exibe quaisquer rotas que correspondam parcialmente ao nome do método auxiliar de URL, ao verbo HTTP ou ao caminho da URL.

```bash
$ bin/rails routes -g new_comment
$ bin/rails routes -g POST
$ bin/rails routes -g admin
```

Se você quiser ver apenas as rotas que mapeiam para um controlador específico, há a opção -c.

```bash
$ bin/rails routes -c users
$ bin/rails routes -c admin/users
$ bin/rails routes -c Comments
$ bin/rails routes -c Articles::CommentsController
```

DICA: Você verá que a saída de `bin/rails routes` é muito mais legível se você ampliar a janela do terminal até que as linhas de saída não sejam quebradas.

### Testando rotas

As rotas devem ser incluídas em sua estratégia de teste (assim como o restante de sua aplicação). O Rails oferece três asserções embutidas projetadas para facilitar o teste de rotas:

* [`assert_generates`][]
* [`assert_recognizes`][]
* [`assert_routing`][]


#### A asserção `assert_generates`

[`assert_generates`][] afirma que um determinado conjunto de opções gera um determinado caminho e pode ser usado com rotas padrão ou rotas personalizadas. Por exemplo:

```ruby
assert_generates '/photos/1', { controller: 'photos', action: 'show', id: '1' }
assert_generates '/about', controller: 'pages', action: 'about'
```

#### A asserção `assert_recognizes`

[`assert_recognizes`][] é o inverso de `assert_generates`. Ele afirma que um determinado caminho é reconhecido e o roteia para um local específico em sua aplicação. Por exemplo:

```ruby
assert_recognizes({ controller: 'photos', action: 'show', id: '1' }, '/photos/1')
```

Você pode fornecer um argumento `:method` para especificar o verbo HTTP:

```ruby
assert_recognizes({ controller: 'photos', action: 'create' }, { path: 'photos', method: :post })
```

#### A asserção `assert_routing`

A asserção [`assert_routing`][] verifica a rota nos dois sentidos: ela testa se o caminho gera as opções e se as opções geram o caminho. Assim, combina as funções de `assert_generates` e `assert_recognizes`:

```ruby
assert_routing({ path: 'photos', method: :post }, { controller: 'photos', action: 'create' })
```

[`resources`]: https://api.rubyonrails.org/classes/ActionDispatch/Routing/Mapper/Resources.html#method-i-resources
[`namespace`]: https://api.rubyonrails.org/classes/ActionDispatch/Routing/Mapper/Scoping.html#method-i-namespace
[`scope`]: https://api.rubyonrails.org/classes/ActionDispatch/Routing/Mapper/Scoping.html#method-i-scope
[`shallow`]: https://api.rubyonrails.org/classes/ActionDispatch/Routing/Mapper/Resources.html#method-i-shallow
[`concern`]: https://api.rubyonrails.org/classes/ActionDispatch/Routing/Mapper/Concerns.html#method-i-concern
[`concerns`]: https://api.rubyonrails.org/classes/ActionDispatch/Routing/Mapper/Concerns.html#method-i-concerns
[ActionView::RoutingUrlFor#url_for]: https://api.rubyonrails.org/classes/ActionView/RoutingUrlFor.html#method-i-url_for
[`delete`]: https://api.rubyonrails.org/classes/ActionDispatch/Routing/Mapper/HttpHelpers.html#method-i-delete
[`get`]: https://api.rubyonrails.org/classes/ActionDispatch/Routing/Mapper/HttpHelpers.html#method-i-get
[`member`]: https://api.rubyonrails.org/classes/ActionDispatch/Routing/Mapper/Resources.html#method-i-member
[`patch`]: https://api.rubyonrails.org/classes/ActionDispatch/Routing/Mapper/HttpHelpers.html#method-i-patch
[`post`]: https://api.rubyonrails.org/classes/ActionDispatch/Routing/Mapper/HttpHelpers.html#method-i-post
[`put`]: https://api.rubyonrails.org/classes/ActionDispatch/Routing/Mapper/HttpHelpers.html#method-i-put
[`put`]: https://api.rubyonrails.org/classes/ActionDispatch/Routing/Mapper/HttpHelpers.html#method-i-put
[`collection`]: https://api.rubyonrails.org/classes/ActionDispatch/Routing/Mapper/Resources.html#method-i-collection
[`defaults`]: https://api.rubyonrails.org/classes/ActionDispatch/Routing/Mapper/Scoping.html#method-i-defaults
[`match`]: https://api.rubyonrails.org/classes/ActionDispatch/Routing/Mapper/Base.html#method-i-match
[`constraints`]: https://api.rubyonrails.org/classes/ActionDispatch/Routing/Mapper/Scoping.html#method-i-constraints
[`redirect`]: https://api.rubyonrails.org/classes/ActionDispatch/Routing/Redirection.html#method-i-redirect
[`mount`]: https://api.rubyonrails.org/classes/ActionDispatch/Routing/Mapper/Base.html#method-i-mount
[`root`]: https://api.rubyonrails.org/classes/ActionDispatch/Routing/Mapper/Resources.html#method-i-root
[`direct`]: https://api.rubyonrails.org/classes/ActionDispatch/Routing/Mapper/CustomUrls.html#method-i-direct
[`resolve`]: https://api.rubyonrails.org/classes/ActionDispatch/Routing/Mapper/CustomUrls.html#method-i-resolve
[`form_with`]: https://api.rubyonrails.org/classes/ActionView/Helpers/FormHelper.html#method-i-form_with
[`inflections`]: https://api.rubyonrails.org/classes/ActiveSupport/Inflector.html#method-i-inflections
[`draw`]: https://api.rubyonrails.org/classes/ActionDispatch/Routing/Mapper/Resources.html#method-i-draw
[`assert_generates`]: https://api.rubyonrails.org/classes/ActionDispatch/Assertions/RoutingAssertions.html#method-i-assert_generates
[`assert_recognizes`]: https://api.rubyonrails.org/classes/ActionDispatch/Assertions/RoutingAssertions.html#method-i-assert_recognizes
[`assert_routing`]: https://api.rubyonrails.org/classes/ActionDispatch/Assertions/RoutingAssertions.html#method-i-assert_routing
