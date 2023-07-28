**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 37d2486eee8522a64c5f97f86900b8a6
Helpers de Visualização de Ação
====================

Após ler este guia, você saberá:

* Como formatar datas, strings e números
* Como criar links para imagens, vídeos, folhas de estilo, etc...
* Como sanitizar conteúdo
* Como localizar conteúdo

--------------------------------------------------------------------------------

Visão geral dos Helpers fornecidos pela Action View
-------------------------------------------

WIP: Nem todos os helpers estão listados aqui. Para uma lista completa, consulte a [documentação da API](https://api.rubyonrails.org/classes/ActionView/Helpers.html)

O seguinte é apenas uma breve visão geral dos helpers disponíveis na Action View. É recomendado que você revise a [Documentação da API](https://api.rubyonrails.org/classes/ActionView/Helpers.html), que cobre todos os helpers com mais detalhes, mas isso deve servir como um bom ponto de partida.

### AssetTagHelper

Este módulo fornece métodos para gerar HTML que vincula as visualizações a ativos como imagens, arquivos JavaScript, folhas de estilo e feeds.

Por padrão, o Rails vincula esses ativos no host atual na pasta pública, mas você pode direcionar o Rails para vincular ativos de um servidor de ativos dedicado configurando [`config.asset_host`][] na configuração da aplicação, normalmente em `config/environments/production.rb`. Por exemplo, digamos que seu host de ativos seja `assets.example.com`:

```ruby
config.asset_host = "assets.example.com"
image_tag("rails.png")
# => <img src="http://assets.example.com/images/rails.png" />
```


#### auto_discovery_link_tag

Retorna uma tag de link que navegadores e leitores de feed podem usar para detectar automaticamente um feed RSS, Atom ou JSON.

```ruby
auto_discovery_link_tag(:rss, "http://www.example.com/feed.rss", { title: "RSS Feed" })
# => <link rel="alternate" type="application/rss+xml" title="RSS Feed" href="http://www.example.com/feed.rss" />
```

#### image_path

Calcula o caminho para um ativo de imagem no diretório `app/assets/images`. Caminhos completos a partir da raiz do documento serão passados. Usado internamente por `image_tag` para construir o caminho da imagem.

```ruby
image_path("edit.png") # => /assets/edit.png
```

A impressão digital será adicionada ao nome do arquivo se `config.assets.digest` estiver definido como true.

```ruby
image_path("edit.png")
# => /assets/edit-2d1a2db63fc738690021fedb5a65b68e.png
```

#### image_url

Calcula a URL para um ativo de imagem no diretório `app/assets/images`. Isso chamará `image_path` internamente e mesclará com seu host atual ou seu host de ativos.

```ruby
image_url("edit.png") # => http://www.example.com/assets/edit.png
```

#### image_tag

Retorna uma tag de imagem HTML para a origem. A origem pode ser um caminho completo ou um arquivo que existe no diretório `app/assets/images`.

```ruby
image_tag("icon.png") # => <img src="/assets/icon.png" />
```

#### javascript_include_tag

Retorna uma tag de script HTML para cada uma das fontes fornecidas. Você pode passar o nome do arquivo (a extensão `.js` é opcional) de arquivos JavaScript que existem no diretório `app/assets/javascripts` para inclusão na página atual ou pode passar o caminho completo em relação à raiz do documento.

```ruby
javascript_include_tag "common"
# => <script src="/assets/common.js"></script>
```

#### javascript_path

Calcula o caminho para um ativo JavaScript no diretório `app/assets/javascripts`. Se o nome do arquivo de origem não tiver extensão, `.js` será adicionado. Caminhos completos a partir da raiz do documento serão passados. Usado internamente por `javascript_include_tag` para construir o caminho do script.

```ruby
javascript_path "common" # => /assets/common.js
```

#### javascript_url

Calcula a URL para um ativo JavaScript no diretório `app/assets/javascripts`. Isso chamará `javascript_path` internamente e mesclará com seu host atual ou seu host de ativos.

```ruby
javascript_url "common"
# => http://www.example.com/assets/common.js
```

#### stylesheet_link_tag

Retorna uma tag de link para as fontes especificadas como argumentos. Se você não especificar uma extensão, `.css` será adicionado automaticamente.

```ruby
stylesheet_link_tag "application"
# => <link href="/assets/application.css" rel="stylesheet" />
```

#### stylesheet_path

Calcula o caminho para um ativo de folha de estilo no diretório `app/assets/stylesheets`. Se o nome do arquivo de origem não tiver extensão, `.css` será adicionado. Caminhos completos a partir da raiz do documento serão passados. Usado internamente por `stylesheet_link_tag` para construir o caminho da folha de estilo.

```ruby
stylesheet_path "application" # => /assets/application.css
```

#### stylesheet_url

Calcula a URL para um ativo de folha de estilo no diretório `app/assets/stylesheets`. Isso chamará `stylesheet_path` internamente e mesclará com seu host atual ou seu host de ativos.

```ruby
stylesheet_url "application"
# => http://www.example.com/assets/application.css
```

### AtomFeedHelper

#### atom_feed

Este helper facilita a construção de um feed Atom. Aqui está um exemplo de uso completo:

**config/routes.rb**

```ruby
resources :articles
```

**app/controllers/articles_controller.rb**

```ruby
def index
  @articles = Article.all

  respond_to do |format|
    format.html
    format.atom
  end
end
```

**app/views/articles/index.atom.builder**

```ruby
atom_feed do |feed|
  feed.title("Articles Index")
  feed.updated(@articles.first.created_at)

  @articles.each do |article|
    feed.entry(article) do |entry|
      entry.title(article.title)
      entry.content(article.body, type: 'html')

      entry.author do |author|
        author.name(article.author_name)
      end
    end
  end
end
```

### BenchmarkHelper

#### benchmark

Permite medir o tempo de execução de um bloco em um template e registra o resultado no log. Envolve este bloco em torno de operações caras ou gargalos possíveis para obter uma leitura de tempo para a operação.
```html+erb
<% benchmark "Processar arquivos de dados" do %>
  <%= expensive_files_operation %>
<% end %>
```

Isso adicionaria algo como "Processar arquivos de dados (0.34523)" ao log, que você pode usar para comparar os tempos ao otimizar seu código.

### CacheHelper

#### cache

Um método para armazenar em cache fragmentos de uma visualização em vez de uma ação ou página inteira. Essa técnica é útil para armazenar em cache partes como menus, listas de tópicos de notícias, fragmentos HTML estáticos, etc. Esse método recebe um bloco que contém o conteúdo que você deseja armazenar em cache. Consulte `AbstractController::Caching::Fragments` para obter mais informações.

```erb
<% cache do %>
  <%= render "shared/footer" %>
<% end %>
```

### CaptureHelper

#### capture

O método `capture` permite extrair uma parte de um modelo em uma variável. Você pode então usar essa variável em qualquer lugar em seus modelos ou layout.

```html+erb
<% @greeting = capture do %>
  <p>Bem-vindo! A data e hora são <%= Time.now %></p>
<% end %>
```

A variável capturada pode então ser usada em qualquer outro lugar.

```html+erb
<html>
  <head>
    <title>Bem-vindo!</title>
  </head>
  <body>
    <%= @greeting %>
  </body>
</html>
```

#### content_for

Chamar `content_for` armazena um bloco de marcação em um identificador para uso posterior. Você pode fazer chamadas subsequentes ao conteúdo armazenado em outros modelos ou no layout, passando o identificador como argumento para `yield`.

Por exemplo, digamos que temos um layout de aplicativo padrão, mas também uma página especial que requer determinado JavaScript que o restante do site não precisa. Podemos usar `content_for` para incluir esse JavaScript em nossa página especial sem aumentar o tamanho do restante do site.

**app/views/layouts/application.html.erb**

```html+erb
<html>
  <head>
    <title>Bem-vindo!</title>
    <%= yield :special_script %>
  </head>
  <body>
    <p>Bem-vindo! A data e hora são <%= Time.now %></p>
  </body>
</html>
```

**app/views/articles/special.html.erb**

```html+erb
<p>Esta é uma página especial.</p>

<% content_for :special_script do %>
  <script>alert('Olá!')</script>
<% end %>
```

### DateHelper

#### distance_of_time_in_words

Relata a distância aproximada no tempo entre dois objetos Time ou Date ou inteiros como segundos. Defina `include_seconds` como true se você deseja aproximações mais detalhadas.

```ruby
distance_of_time_in_words(Time.now, Time.now + 15.seconds)
# => menos de um minuto
distance_of_time_in_words(Time.now, Time.now + 15.seconds, include_seconds: true)
# => menos de 20 segundos
```

#### time_ago_in_words

Como `distance_of_time_in_words`, mas onde `to_time` é fixado em `Time.now`.

```ruby
time_ago_in_words(3.minutes.from_now) # => 3 minutos
```

### DebugHelper

Retorna uma tag `pre` que tem o objeto despejado por YAML. Isso cria uma maneira muito legível de inspecionar um objeto.

```ruby
my_hash = { 'first' => 1, 'second' => 'two', 'third' => [1, 2, 3] }
debug(my_hash)
```

```html
<pre class='debug_dump'>---
first: 1
second: two
third:
- 1
- 2
- 3
</pre>
```

### FormHelper

Os auxiliares de formulário são projetados para facilitar o trabalho com modelos em comparação com o uso apenas de elementos HTML padrão, fornecendo um conjunto de métodos para criar formulários com base em seus modelos. Este auxiliar gera o HTML para formulários, fornecendo um método para cada tipo de entrada (por exemplo, texto, senha, seleção, etc). Quando o formulário é enviado (ou seja, quando o usuário clica no botão de envio ou `form.submit` é chamado via JavaScript), as entradas do formulário serão agrupadas no objeto `params` e passadas de volta para o controlador.

Você pode aprender mais sobre os auxiliares de formulário no [Guia de Auxiliares de Formulário do Action View](form_helpers.html).

### JavaScriptHelper

Fornece funcionalidade para trabalhar com JavaScript em suas visualizações.

#### escape_javascript

Escapa retornos de carro e aspas simples e duplas para segmentos de JavaScript.

#### javascript_tag

Retorna uma tag JavaScript envolvendo o código fornecido.

```ruby
javascript_tag "alert('Tudo está bom')"
```

```html
<script>
//<![CDATA[
alert('Tudo está bom')
//]]>
</script>
```

### NumberHelper

Fornece métodos para converter números em strings formatadas. Métodos são fornecidos para números de telefone, moeda, porcentagem, precisão, notação posicional e tamanho de arquivo.

#### number_to_currency

Formata um número em uma string de moeda (por exemplo, R$13,65).

```ruby
number_to_currency(1234567890.50) # => R$1.234.567.890,50
```

#### number_to_human

Imprime de forma agradável (formata e aproxima) um número para que seja mais legível para os usuários; útil para números que podem ficar muito grandes.

```ruby
number_to_human(1234)    # => 1,23 Mil
number_to_human(1234567) # => 1,23 Milhão
```

#### number_to_human_size

Formata os bytes em tamanho em uma representação mais compreensível; útil para relatar tamanhos de arquivo aos usuários.

```ruby
number_to_human_size(1234)    # => 1,21 KB
number_to_human_size(1234567) # => 1,18 MB
```

#### number_to_percentage

Formata um número como uma string de porcentagem.
```ruby
number_to_percentage(100, precision: 0) # => 100%
```

#### number_to_phone

Formata um número em um número de telefone (padrão dos EUA).

```ruby
number_to_phone(1235551234) # => 123-555-1234
```

#### number_with_delimiter

Formata um número com milhares agrupados usando um delimitador.

```ruby
number_with_delimiter(12345678) # => 12,345,678
```

#### number_with_precision

Formata um número com o nível de `precision` especificado, que por padrão é 3.

```ruby
number_with_precision(111.2345)               # => 111.235
number_with_precision(111.2345, precision: 2) # => 111.23
```

### SanitizeHelper

O módulo SanitizeHelper fornece um conjunto de métodos para limpar o texto de elementos HTML indesejados.

#### sanitize

Este helper sanitize codificará em HTML todas as tags e removerá todos os atributos que não forem especificamente permitidos.

```ruby
sanitize @article.body
```

Se as opções `:attributes` ou `:tags` forem passadas, apenas os atributos e tags mencionados serão permitidos e nada mais.

```ruby
sanitize @article.body, tags: %w(table tr td), attributes: %w(id class style)
```

Para alterar os padrões para uso múltiplo, por exemplo, adicionar tags de tabela ao padrão:

```ruby
class Application < Rails::Application
  config.action_view.sanitized_allowed_tags = 'table', 'tr', 'td'
end
```

#### sanitize_css(style)

Limpa um bloco de código CSS.

#### strip_links(html)

Remove todas as tags de link do texto, deixando apenas o texto do link.

```ruby
strip_links('<a href="https://rubyonrails.org">Ruby on Rails</a>')
# => Ruby on Rails
```

```ruby
strip_links('emails para <a href="mailto:me@email.com">me@email.com</a>.')
# => emails para me@email.com.
```

```ruby
strip_links('Blog: <a href="http://myblog.com/">Visite</a>.')
# => Blog: Visite.
```

#### strip_tags(html)

Remove todas as tags HTML do html, incluindo comentários.
Essa funcionalidade é fornecida pelo gem rails-html-sanitizer.

```ruby
strip_tags("Remova <i>essas</i> tags!")
# => Remova essas tags!
```

```ruby
strip_tags("<b>Negrito</b> não mais!  <a href='mais.html'>Veja mais</a>")
# => Negrito não mais!  Veja mais
```

NB: A saída ainda pode conter os caracteres '<', '>', '&' não escapados e confundir os navegadores.

### UrlHelper

Fornece métodos para criar links e obter URLs que dependem do subsistema de roteamento.

#### url_for

Retorna a URL para o conjunto de `options` fornecido.

##### Exemplos

```ruby
url_for @profile
# => /profiles/1

url_for [ @hotel, @booking, page: 2, line: 3 ]
# => /hotels/1/bookings/1?line=3&page=2
```

#### link_to

Links para uma URL derivada de `url_for` internamente. Usado principalmente para
criar links de recursos RESTful, que para este exemplo, se resume a
quando passando modelos para `link_to`.

**Exemplos**

```ruby
link_to "Perfil", @profile
# => <a href="/profiles/1">Perfil</a>
```

Você também pode usar um bloco se o destino do link não couber no parâmetro de nome. Exemplo em ERB:

```html+erb
<%= link_to @profile do %>
  <strong><%= @profile.name %></strong> -- <span>Confira!</span>
<% end %>
```

produziria:

```html
<a href="/profiles/1">
  <strong>David</strong> -- <span>Confira!</span>
</a>
```

Consulte [a Documentação da API para mais informações](https://api.rubyonrails.org/classes/ActionView/Helpers/UrlHelper.html#method-i-link_to)

#### button_to

Gera um formulário que envia para a URL passada. O formulário tem um botão de envio
com o valor do `name`.

##### Exemplos

```html+erb
<%= button_to "Entrar", sign_in_path %>
```

produziria algo parecido com:

```html
<form method="post" action="/sessions" class="button_to">
  <input type="submit" value="Entrar" />
</form>
```

Consulte [a Documentação da API para mais informações](https://api.rubyonrails.org/classes/ActionView/Helpers/UrlHelper.html#method-i-button_to)

### CsrfHelper

Retorna as meta tags "csrf-param" e "csrf-token" com o nome do parâmetro e token de proteção contra falsificação de solicitação entre sites, respectivamente.

```html
<%= csrf_meta_tags %>
```

OBS: Formulários regulares geram campos ocultos, portanto, eles não usam essas tags. Mais
detalhes podem ser encontrados no [Guia de Segurança do Rails](security.html#cross-site-request-forgery-csrf).
[`config.asset_host`]: configuring.html#config-asset-host
