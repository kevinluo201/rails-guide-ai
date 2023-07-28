**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: bef23603f5d822054701f5cbf2578d95
Caching com Rails: Uma Visão Geral
===============================

Este guia é uma introdução para acelerar sua aplicação Rails com caching.

Caching significa armazenar o conteúdo gerado durante o ciclo de requisição-resposta
e reutilizá-lo ao responder a requisições semelhantes.

O caching é frequentemente a maneira mais eficaz de aumentar o desempenho de uma aplicação.
Através do caching, websites que rodam em um único servidor com um único banco de dados
podem suportar uma carga de milhares de usuários simultâneos.

O Rails fornece um conjunto de recursos de caching prontos para uso. Este guia irá ensinar
o escopo e o propósito de cada um deles. Domine essas técnicas e suas
aplicações Rails podem servir milhões de visualizações sem tempos de resposta exorbitantes
ou contas de servidor altas.

Depois de ler este guia, você saberá:

* Fragment e Russian doll caching.
* Como gerenciar as dependências de caching.
* Armazenamentos alternativos de cache.
* Suporte a GET condicional.

--------------------------------------------------------------------------------

Caching Básico
-------------

Esta é uma introdução a três tipos de técnicas de caching: caching de página, de ação e
de fragmento. Por padrão, o Rails fornece o caching de fragmentos. Para usar
o caching de página e de ação, você precisará adicionar `actionpack-page_caching` e
`actionpack-action_caching` ao seu `Gemfile`.

Por padrão, o caching só está habilitado no ambiente de produção. Você pode testar
o caching localmente executando `rails dev:cache`, ou configurando
[`config.action_controller.perform_caching`][] como `true` em `config/environments/development.rb`.

NOTA: Alterar o valor de `config.action_controller.perform_caching` terá
efeito apenas no caching fornecido pelo Action Controller.
Por exemplo, não afetará o caching de baixo nível, que abordamos
[abaixo](#low-level-caching).


### Caching de Página

O caching de página é um mecanismo do Rails que permite que a requisição por uma página gerada
seja atendida pelo servidor web (ou seja, Apache ou NGINX) sem precisar passar
por todo o stack do Rails. Embora isso seja super rápido, não pode ser aplicado a
todas as situações (como páginas que precisam de autenticação). Além disso, como o
servidor web está servindo um arquivo diretamente do sistema de arquivos, você precisará
implementar a expiração do cache.

INFO: O caching de página foi removido do Rails 4. Veja o [gem actionpack-page_caching](https://github.com/rails/actionpack-page_caching).

### Caching de Ação

O caching de página não pode ser usado para ações que possuem filtros antes - por exemplo, páginas que requerem autenticação. É aí que entra o caching de ação. O caching de ação funciona como o caching de página, exceto que a requisição web recebida atinge o stack do Rails para que os filtros antes possam ser executados antes que o cache seja servido. Isso permite que a autenticação e outras restrições sejam executadas enquanto ainda é servido o resultado da saída de uma cópia em cache.

INFO: O caching de ação foi removido do Rails 4. Veja o [gem actionpack-action_caching](https://github.com/rails/actionpack-action_caching). Veja [a visão geral de expiração de cache baseada em chave de DHH](https://signalvnoise.com/posts/3113-how-key-based-cache-expiration-works) para o método preferido atualmente.

### Caching de Fragmento

Aplicações web dinâmicas geralmente constroem páginas com uma variedade de componentes
que não possuem as mesmas características de caching. Quando diferentes partes da
página precisam ser armazenadas em cache e expiradas separadamente, você pode usar o Caching de Fragmento.

O Caching de Fragmento permite que um fragmento de lógica de visualização seja envolto em um bloco de cache e servido a partir do armazenamento de cache quando a próxima requisição chegar.

Por exemplo, se você quiser armazenar em cache cada produto em uma página, você pode usar este
código:

```html+erb
<% @products.each do |product| %>
  <% cache product do %>
    <%= render product %>
  <% end %>
<% end %>
```

Quando sua aplicação recebe sua primeira requisição para esta página, o Rails irá gravar
uma nova entrada de cache com uma chave única. Uma chave se parece com isso:

```
views/products/index:bea67108094918eeba42cd4a6e786901/products/1
```

A sequência de caracteres no meio é um resumo da árvore de templates. É um resumo hash
calculado com base no conteúdo do fragmento de visualização que você está armazenando em cache. Se
você alterar o fragmento de visualização (por exemplo, as alterações de HTML), o resumo será alterado,
expirando o arquivo existente.

Uma versão em cache, derivada do registro do produto, é armazenada na entrada de cache.
Quando o produto é alterado, a versão em cache muda e quaisquer fragmentos em cache
que contenham a versão anterior são ignorados.

DICA: Armazenamentos de cache como o Memcached irão excluir automaticamente arquivos de cache antigos.

Se você quiser armazenar em cache um fragmento sob certas condições, você pode usar
`cache_if` ou `cache_unless`:

```erb
<% cache_if admin?, product do %>
  <%= render product %>
<% end %>
```

#### Caching de Coleção

O helper `render` também pode armazenar em cache templates individuais renderizados para uma coleção.
Ele pode até mesmo superar o exemplo anterior com `each` lendo todos os templates de cache
de uma só vez em vez de um por um. Isso é feito passando `cached: true` ao renderizar a coleção:
```html+erb
<%= render partial: 'products/product', collection: @products, cached: true %>
```

Todos os templates em cache de renderizações anteriores serão buscados de uma só vez com uma velocidade muito maior. Além disso, os templates que ainda não foram armazenados em cache serão escritos em cache e buscados em várias renderizações na próxima vez.

### Caching de Boneca Russa

Você pode querer aninhar fragmentos em cache dentro de outros fragmentos em cache. Isso é chamado de caching de boneca russa.

A vantagem do caching de boneca russa é que, se um único produto for atualizado, todos os outros fragmentos internos podem ser reutilizados ao regenerar o fragmento externo.

Como explicado na seção anterior, um arquivo em cache expirará se o valor de `updated_at` mudar para um registro no qual o arquivo em cache depende diretamente. No entanto, isso não expirará nenhum cache no qual o fragmento esteja aninhado.

Por exemplo, considere a seguinte visualização:

```erb
<% cache product do %>
  <%= render product.games %>
<% end %>
```

Que, por sua vez, renderiza esta visualização:

```erb
<% cache game do %>
  <%= render game %>
<% end %>
```

Se algum atributo do jogo for alterado, o valor de `updated_at` será definido como o tempo atual, expirando assim o cache. No entanto, como `updated_at` não será alterado para o objeto de produto, esse cache não será expirado e seu aplicativo fornecerá dados obsoletos. Para corrigir isso, vinculamos os modelos juntos com o método `touch`:

```ruby
class Product < ApplicationRecord
  has_many :games
end

class Game < ApplicationRecord
  belongs_to :product, touch: true
end
```

Com `touch` definido como `true`, qualquer ação que altere `updated_at` para um registro de jogo também o alterará para o produto associado, expirando assim o cache.

### Caching Parcial Compartilhado

É possível compartilhar parciais e caching associado entre arquivos com diferentes tipos MIME. Por exemplo, o caching parcial compartilhado permite que os escritores de modelos compartilhem um parcial entre arquivos HTML e JavaScript. Quando os modelos são coletados nos caminhos de arquivo do resolvedor de modelos, eles incluem apenas a extensão da linguagem do modelo e não o tipo MIME. Por causa disso, os modelos podem ser usados para vários tipos MIME. Tanto as solicitações HTML quanto as de JavaScript responderão ao seguinte código:

```ruby
render(partial: 'hotels/hotel', collection: @hotels, cached: true)
```

Carregará um arquivo chamado `hotels/hotel.erb`.

Outra opção é incluir o nome completo do parcial a ser renderizado.

```ruby
render(partial: 'hotels/hotel.html.erb', collection: @hotels, cached: true)
```

Carregará um arquivo chamado `hotels/hotel.html.erb` em qualquer tipo MIME de arquivo, por exemplo, você pode incluir esse parcial em um arquivo JavaScript.

### Gerenciando Dependências

Para invalidar corretamente o cache, você precisa definir corretamente as dependências de caching. O Rails é inteligente o suficiente para lidar com casos comuns para que você não precise especificar nada. No entanto, às vezes, ao lidar com ajudantes personalizados, por exemplo, você precisa defini-los explicitamente.

#### Dependências Implícitas

A maioria das dependências de modelo pode ser derivada de chamadas para `render` no próprio modelo. Aqui estão alguns exemplos de chamadas de renderização que o `ActionView::Digestor` sabe como decodificar:

```ruby
render partial: "comments/comment", collection: commentable.comments
render "comments/comments"
render 'comments/comments'
render('comments/comments')

render "header" se traduz em render("comments/header")

render(@topic)         se traduz em render("topics/topic")
render(topics)         se traduz em render("topics/topic")
render(message.topics) se traduz em render("topics/topic")
```

Por outro lado, algumas chamadas precisam ser alteradas para que o caching funcione corretamente. Por exemplo, se você estiver passando uma coleção personalizada, precisará alterar:

```ruby
render @project.documents.where(published: true)
```

para:

```ruby
render partial: "documents/document", collection: @project.documents.where(published: true)
```

#### Dependências Explícitas

Às vezes, você terá dependências de modelo que não podem ser derivadas de forma alguma. Esse é normalmente o caso quando a renderização ocorre em ajudantes. Aqui está um exemplo:

```html+erb
<%= render_sortable_todolists @project.todolists %>
```

Você precisará usar um formato de comentário especial para chamá-los:

```html+erb
<%# Dependência de Modelo: todolists/todolist %>
<%= render_sortable_todolists @project.todolists %>
```

Em alguns casos, como em uma configuração de herança de tabela única, você pode ter várias dependências explícitas. Em vez de escrever todos os modelos, você pode usar um caractere curinga para corresponder a qualquer modelo em um diretório:

```html+erb
<%# Dependência de Modelo: events/* %>
<%= render_categorizable_events @person.events %>
```

Quanto ao caching de coleções, se o modelo parcial não começar com uma chamada de cache limpa, você ainda pode se beneficiar do caching de coleções adicionando um formato de comentário especial em qualquer lugar do modelo, como:

```html+erb
<%# Coleção de Modelo: notification %>
<% my_helper_that_calls_cache(some_arg, notification) do %>
  <%= notification.name %>
<% end %>
```
#### Dependências Externas

Se você usar um método auxiliar, por exemplo, dentro de um bloco de cache e depois atualizar esse auxiliar, você também terá que atualizar o cache. Não importa como você faça isso, mas o MD5 do arquivo de modelo deve mudar. Uma recomendação é simplesmente ser explícito em um comentário, como:

```html+erb
<%# Dependência do Auxiliar Atualizada: 28 de julho de 2015 às 19h %>
<%= some_helper_method(person) %>
```

### Cache de Baixo Nível

Às vezes, você precisa armazenar em cache um valor específico ou o resultado de uma consulta em vez de armazenar em cache fragmentos de visualização. O mecanismo de cache do Rails funciona muito bem para armazenar qualquer informação serializável.

A maneira mais eficiente de implementar o cache de baixo nível é usando o método `Rails.cache.fetch`. Este método faz a leitura e a escrita no cache. Quando passado apenas um argumento, a chave é buscada e o valor do cache é retornado. Se um bloco for passado, esse bloco será executado no caso de uma falha no cache. O valor de retorno do bloco será gravado no cache com a chave de cache fornecida e esse valor de retorno será retornado. No caso de um acerto no cache, o valor em cache será retornado sem executar o bloco.

Considere o seguinte exemplo. Uma aplicação tem um modelo `Product` com um método de instância que busca o preço do produto em um site concorrente. Os dados retornados por este método seriam perfeitos para o cache de baixo nível:

```ruby
class Product < ApplicationRecord
  def competing_price
    Rails.cache.fetch("#{cache_key_with_version}/competing_price", expires_in: 12.hours) do
      Competitor::API.find_price(id)
    end
  end
end
```

NOTA: Observe que neste exemplo usamos o método `cache_key_with_version`, então a chave de cache resultante será algo como `products/233-20140225082222765838000/competing_price`. `cache_key_with_version` gera uma string com base no nome da classe do modelo, `id` e atributos `updated_at`. Esta é uma convenção comum e tem o benefício de invalidar o cache sempre que o produto é atualizado. Em geral, quando você usa o cache de baixo nível, precisa gerar uma chave de cache.

#### Evite Armazenar em Cache Instâncias de Objetos Active Record

Considere este exemplo, que armazena em cache uma lista de objetos Active Record que representam superusuários:

```ruby
# super_admins é uma consulta SQL cara, então não a execute com muita frequência
Rails.cache.fetch("super_admin_users", expires_in: 12.hours) do
  User.super_admins.to_a
end
```

Você deve __evitar__ esse padrão. Por quê? Porque a instância pode mudar. Em produção, os atributos podem ser diferentes ou o registro pode ser excluído. E no desenvolvimento, ele funciona de forma não confiável com armazenamentos de cache que recarregam o código quando você faz alterações.

Em vez disso, armazene o ID ou algum outro tipo de dado primitivo. Por exemplo:

```ruby
# super_admins é uma consulta SQL cara, então não a execute com muita frequência
ids = Rails.cache.fetch("super_admin_user_ids", expires_in: 12.hours) do
  User.super_admins.pluck(:id)
end
User.where(id: ids).to_a
```

### Cache de Consulta SQL

O cache de consulta é um recurso do Rails que armazena em cache o conjunto de resultados retornado por cada consulta. Se o Rails encontrar a mesma consulta novamente para essa solicitação, ele usará o conjunto de resultados em cache em vez de executar a consulta novamente no banco de dados.

Por exemplo:

```ruby
class ProductsController < ApplicationController
  def index
    # Executa uma consulta de busca
    @products = Product.all

    # ...

    # Executa a mesma consulta novamente
    @products = Product.all
  end
end
```

Na segunda vez em que a mesma consulta é executada no banco de dados, ela não será realmente executada no banco de dados. Na primeira vez, o resultado é retornado da consulta e armazenado no cache de consulta (em memória) e na segunda vez é obtido da memória.

No entanto, é importante observar que os caches de consulta são criados no início de uma ação e destruídos no final dessa ação e, portanto, persistem apenas durante a duração da ação. Se você deseja armazenar os resultados da consulta de forma mais persistente, pode usar o cache de baixo nível.

Armazenamentos de Cache
------------

O Rails fornece diferentes armazenamentos para os dados em cache (além do cache SQL e de página).

### Configuração

Você pode configurar o armazenamento de cache padrão da sua aplicação definindo a opção de configuração `config.cache_store`. Outros parâmetros podem ser passados como argumentos para o construtor do armazenamento de cache:

```ruby
config.cache_store = :memory_store, { size: 64.megabytes }
```

Alternativamente, você pode definir `ActionController::Base.cache_store` fora de um bloco de configuração.

Você pode acessar o cache chamando `Rails.cache`.

#### Opções do Pool de Conexões

Por padrão, [`:mem_cache_store`](#activesupport-cache-memcachestore) e
[`:redis_cache_store`](#activesupport-cache-rediscachestore) são configurados para usar
pool de conexões. Isso significa que, se você estiver usando o Puma ou outro servidor com várias threads, poderá ter várias threads executando consultas no armazenamento de cache ao mesmo tempo.
Se você deseja desabilitar o agrupamento de conexões, defina a opção `:pool` como `false` ao configurar o armazenamento em cache:

```ruby
config.cache_store = :mem_cache_store, "cache.example.com", pool: false
```

Você também pode substituir as configurações padrão do agrupamento fornecendo opções individuais para a opção `:pool`:

```ruby
config.cache_store = :mem_cache_store, "cache.example.com", pool: { size: 32, timeout: 1 }
```

* `:size` - Essa opção define o número de conexões por processo (padrão: 5).

* `:timeout` - Essa opção define o número de segundos para aguardar uma conexão (padrão: 5). Se nenhuma conexão estiver disponível dentro do tempo limite, será gerado um `Timeout::Error`.

### `ActiveSupport::Cache::Store`

[`ActiveSupport::Cache::Store`][] fornece a base para interagir com o cache no Rails. Esta é uma classe abstrata e não pode ser usada por si só. Em vez disso, você deve usar uma implementação concreta da classe vinculada a um mecanismo de armazenamento. O Rails vem com várias implementações, documentadas abaixo.

Os principais métodos da API são [`read`][ActiveSupport::Cache::Store#read], [`write`][ActiveSupport::Cache::Store#write], [`delete`][ActiveSupport::Cache::Store#delete], [`exist?`][ActiveSupport::Cache::Store#exist?] e [`fetch`][ActiveSupport::Cache::Store#fetch].

As opções passadas para o construtor do armazenamento em cache serão tratadas como opções padrão para os métodos apropriados da API.


### `ActiveSupport::Cache::MemoryStore`

[`ActiveSupport::Cache::MemoryStore`][] mantém as entradas na memória no mesmo processo Ruby. O armazenamento em cache tem um tamanho limitado especificado enviando a opção `:size` para o inicializador (o padrão é 32Mb). Quando o cache excede o tamanho alocado, uma limpeza ocorrerá e as entradas menos usadas serão removidas.

```ruby
config.cache_store = :memory_store, { size: 64.megabytes }
```

Se você estiver executando vários processos do servidor Ruby on Rails (o que é o caso se estiver usando o modo clusterizado do Phusion Passenger ou puma), as instâncias dos processos do servidor Rails não poderão compartilhar dados de cache entre si. Este armazenamento em cache não é adequado para implantações de aplicativos grandes. No entanto, pode funcionar bem para sites pequenos, com baixo tráfego, com apenas alguns processos do servidor, bem como para ambientes de desenvolvimento e teste.

Novos projetos do Rails são configurados para usar essa implementação no ambiente de desenvolvimento por padrão.

NOTA: Como os processos não compartilharão dados de cache ao usar `:memory_store`, não será possível ler, gravar ou expirar manualmente o cache via console do Rails.


### `ActiveSupport::Cache::FileStore`

[`ActiveSupport::Cache::FileStore`][] usa o sistema de arquivos para armazenar as entradas. O caminho para o diretório onde os arquivos do armazenamento serão armazenados deve ser especificado ao inicializar o cache.

```ruby
config.cache_store = :file_store, "/caminho/para/diretorio/de/cache"
```

Com este armazenamento em cache, vários processos do servidor no mesmo host podem compartilhar um cache. Este armazenamento em cache é adequado para sites com tráfego baixo a médio, que são servidos por um ou dois hosts. Os processos do servidor em execução em hosts diferentes podem compartilhar um cache usando um sistema de arquivos compartilhado, mas essa configuração não é recomendada.

À medida que o cache crescer até que o disco esteja cheio, é recomendável limpar periodicamente as entradas antigas.

Essa é a implementação padrão do armazenamento em cache (em `"#{root}/tmp/cache/"`) se nenhuma configuração explícita `config.cache_store` for fornecida.


### `ActiveSupport::Cache::MemCacheStore`

[`ActiveSupport::Cache::MemCacheStore`][] usa o servidor `memcached` da Danga para fornecer um cache centralizado para sua aplicação. O Rails usa a gem `dalli` por padrão. Atualmente, este é o armazenamento em cache mais popular para sites de produção. Ele pode ser usado para fornecer um cluster de cache único e compartilhado com desempenho e redundância muito altos.

Ao inicializar o cache, você deve especificar os endereços de todos os servidores memcached em seu cluster ou garantir que a variável de ambiente `MEMCACHE_SERVERS` tenha sido configurada corretamente.

```ruby
config.cache_store = :mem_cache_store, "cache-1.example.com", "cache-2.example.com"
```

Se nenhum deles for especificado, ele assumirá que o memcached está sendo executado em localhost na porta padrão (`127.0.0.1:11211`), mas essa não é uma configuração ideal para sites maiores.

```ruby
config.cache_store = :mem_cache_store # Usará $MEMCACHE_SERVERS, depois 127.0.0.1:11211
```

Consulte a documentação do [`Dalli::Client`](https://www.rubydoc.info/gems/dalli/Dalli/Client#initialize-instance_method) para obter os tipos de endereço suportados.

O método [`write`][ActiveSupport::Cache::MemCacheStore#write] (e `fetch`) neste cache aceita opções adicionais que aproveitam recursos específicos do memcached.


### `ActiveSupport::Cache::RedisCacheStore`

[`ActiveSupport::Cache::RedisCacheStore`][] aproveita o suporte do Redis para evicção automática quando atinge a memória máxima, permitindo que ele se comporte muito como um servidor de cache Memcached.

Observação de implantação: O Redis não expira chaves por padrão, portanto, tome cuidado ao usar um servidor de cache Redis dedicado. Não encha seu servidor Redis persistente com dados de cache voláteis! Leia o guia de configuração do servidor de cache Redis em detalhes [Redis cache server setup guide](https://redis.io/topics/lru-cache).

Para um servidor Redis apenas de cache, defina `maxmemory-policy` como uma das variantes de `allkeys`. O Redis 4+ suporta evicção menos frequentemente usada (`allkeys-lfu`), uma excelente escolha padrão. O Redis 3 e anteriores devem usar evicção menos recentemente usada (`allkeys-lru`).
Defina os tempos limite de leitura e gravação do cache relativamente baixos. Regenerar um valor em cache é frequentemente mais rápido do que esperar mais de um segundo para recuperá-lo. Os tempos limite de leitura e gravação têm um valor padrão de 1 segundo, mas podem ser definidos como menores se a sua rede tiver latência consistentemente baixa.

Por padrão, o armazenamento em cache não tentará reconectar-se ao Redis se a conexão falhar durante uma solicitação. Se você tiver desconexões frequentes, poderá ativar as tentativas de reconexão.

As leituras e gravações no cache nunca geram exceções; elas apenas retornam `nil`, comportando-se como se não houvesse nada no cache. Para verificar se o cache está gerando exceções, você pode fornecer um `error_handler` para relatar a um serviço de coleta de exceções. Ele deve aceitar três argumentos de palavra-chave: `method`, o método do armazenamento em cache que foi chamado originalmente; `returning`, o valor que foi retornado ao usuário, normalmente `nil`; e `exception`, a exceção que foi resgatada.

Para começar, adicione a gema redis ao seu Gemfile:

```ruby
gem 'redis'
```

Por fim, adicione a configuração no arquivo `config/environments/*.rb` relevante:

```ruby
config.cache_store = :redis_cache_store, { url: ENV['REDIS_URL'] }
```

Um armazenamento de cache Redis mais complexo e de produção pode ser parecido com isso:

```ruby
cache_servers = %w(redis://cache-01:6379/0 redis://cache-02:6379/0)
config.cache_store = :redis_cache_store, { url: cache_servers,

  connect_timeout:    30,  # Padrão: 20 segundos
  read_timeout:       0.2, # Padrão: 1 segundo
  write_timeout:      0.2, # Padrão: 1 segundo
  reconnect_attempts: 1,   # Padrão: 0

  error_handler: -> (method:, returning:, exception:) {
    # Reportar erros para o Sentry como avisos
    Sentry.capture_exception exception, level: 'warning',
      tags: { method: method, returning: returning }
  }
}
```


### `ActiveSupport::Cache::NullStore`

[`ActiveSupport::Cache::NullStore`][] é limitado a cada solicitação da web e limpa os valores armazenados no final de uma solicitação. É destinado ao uso em ambientes de desenvolvimento e teste. Pode ser muito útil quando você tem código que interage diretamente com `Rails.cache`, mas o cache interfere na visualização dos resultados das alterações de código.

```ruby
config.cache_store = :null_store
```


### Armazenamentos de Cache Personalizados

Você pode criar seu próprio armazenamento de cache personalizado simplesmente estendendo `ActiveSupport::Cache::Store` e implementando os métodos apropriados. Dessa forma, você pode trocar qualquer número de tecnologias de cache em sua aplicação Rails.

Para usar um armazenamento de cache personalizado, basta definir o armazenamento de cache como uma nova instância da sua classe personalizada.

```ruby
config.cache_store = MyCacheStore.new
```

Chaves de Cache
---------------

As chaves usadas em um cache podem ser qualquer objeto que responda a `cache_key` ou `to_param`. Você pode implementar o método `cache_key` em suas classes se precisar gerar chaves personalizadas. O Active Record gerará chaves com base no nome da classe e no ID do registro.

Você pode usar hashes e arrays de valores como chaves de cache.

```ruby
# Esta é uma chave de cache válida
Rails.cache.read(site: "mysite", owners: [owner_1, owner_2])
```

As chaves que você usa no `Rails.cache` não serão as mesmas usadas no mecanismo de armazenamento real. Elas podem ser modificadas com um namespace ou alteradas para se adequar às restrições do backend da tecnologia. Isso significa, por exemplo, que você não pode salvar valores com `Rails.cache` e depois tentar recuperá-los com a gema `dalli`. No entanto, você também não precisa se preocupar em exceder o limite de tamanho do memcached ou violar as regras de sintaxe.

Suporte a GET Condicional
-------------------------

GETs condicionais são um recurso da especificação HTTP que fornecem uma maneira para os servidores web informarem aos navegadores que a resposta a uma solicitação GET não foi alterada desde a última solicitação e pode ser obtida com segurança do cache do navegador.

Eles funcionam usando os cabeçalhos `HTTP_IF_NONE_MATCH` e `HTTP_IF_MODIFIED_SINCE` para passar de um lado para o outro um identificador de conteúdo exclusivo e o carimbo de data/hora em que o conteúdo foi alterado pela última vez. Se o navegador fizer uma solicitação em que o identificador de conteúdo (ETag) ou o carimbo de data/hora da última modificação corresponderem à versão do servidor, então o servidor só precisa enviar uma resposta vazia com um status de não modificado.

É responsabilidade do servidor (ou seja, nosso) procurar um carimbo de data/hora da última modificação e o cabeçalho if-none-match e determinar se deve ou não enviar a resposta completa. Com o suporte a GET condicional no Rails, isso é uma tarefa bastante fácil:

```ruby
class ProductsController < ApplicationController
  def show
    @product = Product.find(params[:id])

    # Se a solicitação estiver obsoleta de acordo com o carimbo de data/hora e o valor do etag fornecidos
    # (ou seja, precisa ser processada novamente), execute este bloco
    if stale?(last_modified: @product.updated_at.utc, etag: @product.cache_key_with_version)
      respond_to do |wants|
        # ... processamento normal da resposta
      end
    end

    # Se a solicitação estiver atualizada (ou seja, não foi modificada), você não precisa fazer nada. O renderizador padrão verifica isso usando os parâmetros
    # usados na chamada anterior a stale? e automaticamente enviará um
    # :not_modified. Então é isso, você terminou.
  end
end
```
Em vez de um hash de opções, você também pode simplesmente passar um modelo. O Rails usará os métodos `updated_at` e `cache_key_with_version` para definir `last_modified` e `etag`:

```ruby
class ProductsController < ApplicationController
  def show
    @product = Product.find(params[:id])

    if stale?(@product)
      respond_to do |wants|
        # ... processamento normal da resposta
      end
    end
  end
end
```

Se você não tiver nenhum processamento especial da resposta e estiver usando o mecanismo de renderização padrão (ou seja, não estiver usando `respond_to` ou chamando `render` manualmente), você tem um helper fácil em `fresh_when`:

```ruby
class ProductsController < ApplicationController
  # Isso enviará automaticamente um :not_modified se a requisição for atualizada,
  # e renderizará o template padrão (product.*) se estiver desatualizado.

  def show
    @product = Product.find(params[:id])
    fresh_when last_modified: @product.published_at.utc, etag: @product
  end
end
```

Às vezes, queremos armazenar em cache uma resposta, por exemplo, uma página estática, que nunca expira. Para fazer isso, podemos usar o helper `http_cache_forever` e, ao fazer isso, o navegador e os proxies irão armazená-lo indefinidamente.

Por padrão, as respostas em cache serão privadas, armazenadas apenas no navegador da web do usuário. Para permitir que os proxies armazenem a resposta em cache, defina `public: true` para indicar que eles podem servir a resposta em cache para todos os usuários.

Usando esse helper, o cabeçalho `last_modified` é definido como `Time.new(2011, 1, 1).utc` e o cabeçalho `expires` é definido como 100 anos.

ATENÇÃO: Use esse método com cuidado, pois o navegador/proxy não poderá invalidar a resposta em cache, a menos que o cache do navegador seja limpo à força.

```ruby
class HomeController < ApplicationController
  def index
    http_cache_forever(public: true) do
      render
    end
  end
end
```

### ETags Fortes vs. ETags Fracos

O Rails gera ETags fracas por padrão. ETags fracas permitem que respostas semanticamente equivalentes tenham as mesmas ETags, mesmo que seus corpos não sejam exatamente iguais. Isso é útil quando não queremos que a página seja regenerada para alterações mínimas no corpo da resposta.

ETags fracas têm um prefixo `W/` para diferenciá-las das ETags fortes.

```
W/"618bbc92e2d35ea1945008b42799b0e7" → ETag Fraca
"618bbc92e2d35ea1945008b42799b0e7" → ETag Forte
```

Ao contrário das ETags fracas, as ETags fortes implicam que a resposta deve ser exatamente a mesma e byte a byte idêntica. É útil ao fazer solicitações de intervalo dentro de um arquivo de vídeo ou PDF grande. Alguns CDNs suportam apenas ETags fortes, como o Akamai. Se você realmente precisa gerar uma ETag forte, pode fazer da seguinte maneira.

```ruby
class ProductsController < ApplicationController
  def show
    @product = Product.find(params[:id])
    fresh_when last_modified: @product.published_at.utc, strong_etag: @product
  end
end
```

Você também pode definir a ETag forte diretamente na resposta.

```ruby
response.strong_etag = response.body # => "618bbc92e2d35ea1945008b42799b0e7"
```

Cache no Desenvolvimento
------------------------

É comum querer testar a estratégia de cache do seu aplicativo no modo de desenvolvimento. O Rails fornece o comando `dev:cache` para alternar facilmente entre ativar/desativar o cache.

```bash
$ bin/rails dev:cache
O modo de desenvolvimento agora está sendo armazenado em cache.
$ bin/rails dev:cache
O modo de desenvolvimento não está mais sendo armazenado em cache.
```

Por padrão, quando o cache do modo de desenvolvimento está *desativado*, o Rails usa o [`:null_store`](#activesupport-cache-nullstore).

Referências
----------

* [Artigo do DHH sobre expiração baseada em chave](https://signalvnoise.com/posts/3113-how-key-based-cache-expiration-works)
* [Railscast do Ryan Bates sobre cache digests](http://railscasts.com/episodes/387-cache-digests)
[`config.action_controller.perform_caching`]: configuring.html#config-action-controller-perform-caching
[`ActiveSupport::Cache::Store`]: https://api.rubyonrails.org/classes/ActiveSupport/Cache/Store.html
[ActiveSupport::Cache::Store#delete]: https://api.rubyonrails.org/classes/ActiveSupport/Cache/Store.html#method-i-delete
[ActiveSupport::Cache::Store#exist?]: https://api.rubyonrails.org/classes/ActiveSupport/Cache/Store.html#method-i-exist-3F
[ActiveSupport::Cache::Store#fetch]: https://api.rubyonrails.org/classes/ActiveSupport/Cache/Store.html#method-i-fetch
[ActiveSupport::Cache::Store#read]: https://api.rubyonrails.org/classes/ActiveSupport/Cache/Store.html#method-i-read
[ActiveSupport::Cache::Store#write]: https://api.rubyonrails.org/classes/ActiveSupport/Cache/Store.html#method-i-write
[`ActiveSupport::Cache::MemoryStore`]: https://api.rubyonrails.org/classes/ActiveSupport/Cache/MemoryStore.html
[`ActiveSupport::Cache::FileStore`]: https://api.rubyonrails.org/classes/ActiveSupport/Cache/FileStore.html
[`ActiveSupport::Cache::MemCacheStore`]: https://api.rubyonrails.org/classes/ActiveSupport/Cache/MemCacheStore.html
[ActiveSupport::Cache::MemCacheStore#write]: https://api.rubyonrails.org/classes/ActiveSupport/Cache/MemCacheStore.html#method-i-write
[`ActiveSupport::Cache::RedisCacheStore`]: https://api.rubyonrails.org/classes/ActiveSupport/Cache/RedisCacheStore.html
[`ActiveSupport::Cache::NullStore`]: https://api.rubyonrails.org/classes/ActiveSupport/Cache/NullStore.html
