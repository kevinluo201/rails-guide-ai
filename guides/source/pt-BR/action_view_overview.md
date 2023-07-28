**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: f6b613040c7aed4c76b6648b6fd963cf
Visão Geral do Action View
====================

Após ler este guia, você saberá:

* O que é o Action View e como usá-lo com o Rails.
* Como usar templates, partials e layouts da melhor maneira.
* Como usar views localizadas.

--------------------------------------------------------------------------------

O que é o Action View?
--------------------

No Rails, as solicitações da web são tratadas pelo [Action Controller](action_controller_overview.html) e pelo Action View. Normalmente, o Action Controller se preocupa em se comunicar com o banco de dados e realizar ações CRUD quando necessário. O Action View é responsável por compilar a resposta.

Os templates do Action View são escritos usando Ruby embutido em tags misturadas com HTML. Para evitar poluir os templates com código repetitivo, várias classes auxiliares fornecem comportamentos comuns para formulários, datas e strings. Também é fácil adicionar novos auxiliares à sua aplicação à medida que ela evolui.

NOTA: Alguns recursos do Action View estão relacionados ao Active Record, mas isso não significa que o Action View depende do Active Record. O Action View é um pacote independente que pode ser usado com qualquer tipo de biblioteca Ruby.

Usando o Action View com o Rails
----------------------------

Para cada controlador, há um diretório associado no diretório `app/views` que contém os arquivos de template que compõem as views associadas a esse controlador. Esses arquivos são usados para exibir a view resultante de cada ação do controlador.

Vamos dar uma olhada no que o Rails faz por padrão ao criar um novo recurso usando o gerador de scaffold:

```bash
$ bin/rails generate scaffold article
      [...]
      invoke  scaffold_controller
      create    app/controllers/articles_controller.rb
      invoke    erb
      create      app/views/articles
      create      app/views/articles/index.html.erb
      create      app/views/articles/edit.html.erb
      create      app/views/articles/show.html.erb
      create      app/views/articles/new.html.erb
      create      app/views/articles/_form.html.erb
      [...]
```

Existe uma convenção de nomenclatura para as views no Rails. Normalmente, as views compartilham seu nome com a ação do controlador associada, como você pode ver acima.
Por exemplo, a ação do controlador `index` do `articles_controller.rb` usará o arquivo de view `index.html.erb` no diretório `app/views/articles`.
O HTML completo retornado para o cliente é composto por uma combinação deste arquivo ERB, um template de layout que o envolve e todos os partials que a view pode referenciar. Neste guia, você encontrará uma documentação mais detalhada sobre cada um desses três componentes.

Como mencionado, a saída HTML final é uma composição de três elementos do Rails: `Templates`, `Partials` e `Layouts`.
Abaixo está uma breve visão geral de cada um deles.

Templates
---------

Os templates do Action View podem ser escritos de várias maneiras. Se o arquivo de template tiver a extensão `.erb`, ele usará uma mistura de ERB (Embedded Ruby) e HTML. Se o arquivo de template tiver a extensão `.builder`, será usado a biblioteca `Builder::XmlMarkup`.

O Rails suporta vários sistemas de templates e usa uma extensão de arquivo para distingui-los. Por exemplo, um arquivo HTML usando o sistema de template ERB terá `.html.erb` como extensão de arquivo.

### ERB

Dentro de um template ERB, código Ruby pode ser incluído usando as tags `<% %>` e `<%= %>` . As tags `<% %>` são usadas para executar código Ruby que não retorna nada, como condições, loops ou blocos, e as tags `<%= %>` são usadas quando você deseja exibir uma saída.

Considere o seguinte loop para nomes:

```html+erb
<h1>Nomes de todas as pessoas</h1>
<% @people.each do |person| %>
  Nome: <%= person.name %><br>
<% end %>
```

O loop é configurado usando tags de incorporação regulares (`<% %>`) e o nome é inserido usando as tags de incorporação de saída (`<%= %>`). Observe que isso não é apenas uma sugestão de uso: funções regulares de saída como `print` e `puts` não serão renderizadas na view com templates ERB. Portanto, isso estaria errado:

```html+erb
<%# ERRADO %>
Oi, Sr. <% puts "Frodo" %>
```

Para suprimir espaços em branco no início e no final, você pode usar `<%-` `-%>` alternadamente com `<%` e `%>`.

### Builder

Os templates do Builder são uma alternativa mais programática ao ERB. Eles são especialmente úteis para gerar conteúdo XML. Um objeto XmlMarkup chamado `xml` é automaticamente disponibilizado para templates com a extensão `.builder`.

Aqui estão alguns exemplos básicos:

```ruby
xml.em("enfatizado")
xml.em { xml.b("enfatizado e negrito") }
xml.a("Um link", "href" => "https://rubyonrails.org")
xml.target("name" => "compilar", "option" => "rápido")
```

que produziria:

```html
<em>enfatizado</em>
<em><b>enfatizado e negrito</b></em>
<a href="https://rubyonrails.org">Um link</a>
<target option="rápido" name="compilar" />
```

Qualquer método com um bloco será tratado como uma tag de marcação XML com marcação aninhada no bloco. Por exemplo, o seguinte:
```ruby
xml.div do
  xml.h1(@person.name)
  xml.p(@person.bio)
end
```

produziria algo como:

```html
<div>
  <h1>David Heinemeier Hansson</h1>
  <p>Um produto do Design Dinamarquês durante o Inverno de '79...</p>
</div>
```

Abaixo está um exemplo completo de RSS realmente usado no Basecamp:

```ruby
xml.rss("version" => "2.0", "xmlns:dc" => "http://purl.org/dc/elements/1.1/") do
  xml.channel do
    xml.title(@feed_title)
    xml.link(@url)
    xml.description "Basecamp: Itens recentes"
    xml.language "en-us"
    xml.ttl "40"

    for item in @recent_items
      xml.item do
        xml.title(item_title(item))
        xml.description(item_description(item)) if item_description(item)
        xml.pubDate(item_pubDate(item))
        xml.guid(@person.firm.account.url + @recent_items.url(item))
        xml.link(@person.firm.account.url + @recent_items.url(item))
        xml.tag!("dc:creator", item.author_name) if item_has_creator?(item)
      end
    end
  end
end
```

### Jbuilder

[Jbuilder](https://github.com/rails/jbuilder) é uma gem mantida pela equipe do Rails e incluída no `Gemfile` padrão do Rails. É semelhante ao Builder, mas é usado para gerar JSON, em vez de XML.

Se você não tiver, pode adicionar o seguinte ao seu `Gemfile`:

```ruby
gem 'jbuilder'
```

Um objeto Jbuilder chamado `json` é automaticamente disponibilizado para templates com a extensão `.jbuilder`.

Aqui está um exemplo básico:

```ruby
json.name("Alex")
json.email("alex@example.com")
```

produziria:

```json
{
  "name": "Alex",
  "email": "alex@example.com"
}
```

Consulte a [documentação do Jbuilder](https://github.com/rails/jbuilder#jbuilder) para obter mais exemplos e informações.

### Cache de Templates

Por padrão, o Rails irá compilar cada template em um método para renderizá-lo. No ambiente de desenvolvimento, quando você altera um template, o Rails verifica a data de modificação do arquivo e o recompila.

Partials
--------

Partial templates - geralmente chamados de "partials" - são outro recurso para dividir o processo de renderização em partes mais gerenciáveis. Com partials, você pode extrair trechos de código de seus templates para arquivos separados e também reutilizá-los em seus templates.

### Renderizando Partials

Para renderizar um partial como parte de uma view, você usa o método `render` dentro da view:

```erb
<%= render "menu" %>
```

Isso irá renderizar um arquivo chamado `_menu.html.erb` naquele ponto dentro da view que está sendo renderizada. Observe o caractere de sublinhado inicial: os partials são nomeados com um sublinhado inicial para distingui-los das views regulares, mesmo que sejam referenciados sem o sublinhado. Isso é válido mesmo quando você está puxando um partial de outra pasta:

```erb
<%= render "shared/menu" %>
```

Esse código irá puxar o partial de `app/views/shared/_menu.html.erb`.

### Usando Partials para Simplificar Views

Uma maneira de usar partials é tratá-los como equivalentes a sub-rotinas; uma maneira de mover detalhes de uma view para que você possa entender o que está acontecendo com mais facilidade. Por exemplo, você pode ter uma view que se parece com isso:

```html+erb
<%= render "shared/ad_banner" %>

<h1>Produtos</h1>

<p>Aqui estão alguns de nossos ótimos produtos:</p>
<% @products.each do |product| %>
  <%= render partial: "product", locals: { product: product } %>
<% end %>

<%= render "shared/footer" %>
```

Aqui, os partials `_ad_banner.html.erb` e `_footer.html.erb` podem conter conteúdo compartilhado entre muitas páginas em sua aplicação. Você não precisa ver os detalhes dessas seções quando está se concentrando em uma página específica.

### `render` sem as opções `partial` e `locals`

No exemplo acima, `render` recebe 2 opções: `partial` e `locals`. Mas se
essas são as únicas opções que você deseja passar, você pode pular o uso dessas opções.
Por exemplo, em vez de:

```erb
<%= render partial: "product", locals: { product: @product } %>
```

Você também pode fazer:

```erb
<%= render "product", product: @product %>
```

### As opções `as` e `object`

Por padrão, `ActionView::Partials::PartialRenderer` tem seu objeto em uma variável local com o mesmo nome do template. Então, dado:

```erb
<%= render partial: "product" %>
```

dentro do partial `_product`, teremos `@product` na variável local `product`,
como se tivéssemos escrito:

```erb
<%= render partial: "product", locals: { product: @product } %>
```

A opção `object` pode ser usada para especificar diretamente qual objeto é renderizado no partial; útil quando o objeto do template está em outro lugar (por exemplo, em uma variável de instância diferente ou em uma variável local).

Por exemplo, em vez de:

```erb
<%= render partial: "product", locals: { product: @item } %>
```

fariamos:

```erb
<%= render partial: "product", object: @item %>
```

Com a opção `as`, podemos especificar um nome diferente para a variável local mencionada. Por exemplo, se quisermos que seja `item` em vez de `product`, faríamos:

```erb
<%= render partial: "product", object: @item, as: "item" %>
```

Isso é equivalente a
```erb
<%= render partial: "product", locals: { item: @item } %>
```

### Renderizando Coleções

Comumente, um template precisará iterar sobre uma coleção e renderizar um sub-template para cada um dos elementos. Esse padrão foi implementado como um único método que aceita um array e renderiza um partial para cada um dos elementos do array.

Então, esse exemplo para renderizar todos os produtos:

```erb
<% @products.each do |product| %>
  <%= render partial: "product", locals: { product: product } %>
<% end %>
```

pode ser reescrito em uma única linha:

```erb
<%= render partial: "product", collection: @products %>
```

Quando um partial é chamado com uma coleção, as instâncias individuais do partial têm acesso ao membro da coleção que está sendo renderizado através de uma variável com o nome do partial. Nesse caso, o partial é `_product`, e dentro dele, você pode se referir a `product` para obter o membro da coleção que está sendo renderizado.

Você pode usar uma sintaxe abreviada para renderizar coleções. Supondo que `@products` seja uma coleção de instâncias de `Product`, você pode simplesmente escrever o seguinte para produzir o mesmo resultado:

```erb
<%= render @products %>
```

O Rails determina o nome do partial a ser usado olhando para o nome do modelo na coleção, `Product` neste caso. Na verdade, você pode até mesmo renderizar uma coleção composta por instâncias de modelos diferentes usando essa sintaxe abreviada, e o Rails escolherá o partial adequado para cada membro da coleção.

### Templates de Espaçamento

Você também pode especificar um segundo partial para ser renderizado entre as instâncias do partial principal usando a opção `:spacer_template`:

```erb
<%= render partial: @products, spacer_template: "product_ruler" %>
```

O Rails irá renderizar o partial `_product_ruler` (sem dados passados para ele) entre cada par de partials `_product`.

### Locais Estritos

Por padrão, os templates aceitam qualquer `locals` como argumentos de palavra-chave. Para definir quais `locals` um template aceita, adicione um comentário mágico `locals`:

```erb
<%# locals: (message:) -%>
<%= message %>
```

Valores padrão também podem ser fornecidos:

```erb
<%# locals: (message: "Olá, mundo!") -%>
<%= message %>
```

Ou `locals` podem ser desativados completamente:

```erb
<%# locals: () %>
```

Layouts
-------

Layouts podem ser usados para renderizar um template de visualização comum em torno dos resultados das ações do controlador do Rails. Tipicamente, uma aplicação Rails terá alguns layouts nos quais as páginas serão renderizadas. Por exemplo, um site pode ter um layout para um usuário logado e outro para o lado de marketing ou vendas do site. O layout para o usuário logado pode incluir navegação de alto nível que deve estar presente em várias ações do controlador. O layout de vendas para um aplicativo SaaS pode incluir navegação de alto nível para coisas como páginas "Preços" e "Fale Conosco". Você esperaria que cada layout tenha uma aparência e sensação diferentes. Você pode ler mais sobre layouts em mais detalhes no guia [Layouts e Renderização no Rails](layouts_and_rendering.html).

### Layouts Parciais

Partials podem ter seus próprios layouts aplicados a eles. Esses layouts são diferentes daqueles aplicados a uma ação do controlador, mas funcionam de maneira semelhante.

Digamos que estamos exibindo um artigo em uma página que deve ser envolvido em uma `div` para fins de exibição. Primeiro, vamos criar um novo `Article`:

```ruby
Article.create(body: 'Layouts Parciais são legais!')
```

No template `show`, vamos renderizar o partial `_article` envolvido no layout `box`:

**articles/show.html.erb**

```erb
<%= render partial: 'article', layout: 'box', locals: { article: @article } %>
```

O layout `box` simplesmente envolve o partial `_article` em uma `div`:

**articles/_box.html.erb**

```html+erb
<div class='box'>
  <%= yield %>
</div>
```

Observe que o layout parcial tem acesso à variável local `article` que foi passada para a chamada `render`. No entanto, ao contrário dos layouts em toda a aplicação, os layouts parciais ainda têm o prefixo de sublinhado.

Você também pode renderizar um bloco de código dentro de um layout parcial em vez de chamar `yield`. Por exemplo, se não tivéssemos o partial `_article`, poderíamos fazer isso em vez disso:

**articles/show.html.erb**

```html+erb
<% render(layout: 'box', locals: { article: @article }) do %>
  <div>
    <p><%= article.body %></p>
  </div>
<% end %>
```

Supondo que usemos o mesmo partial `_box` acima, isso produziria a mesma saída que o exemplo anterior.

Caminhos de Visualização
----------

Ao renderizar uma resposta, o controlador precisa resolver onde estão localizadas as diferentes visualizações. Por padrão, ele só procura dentro do diretório `app/views`.
Podemos adicionar outros locais e dar-lhes uma certa precedência ao resolver caminhos usando os métodos `prepend_view_path` e `append_view_path`.

### Prepend View Path

Isso pode ser útil, por exemplo, quando queremos colocar as visualizações dentro de um diretório diferente para subdomínios.

Podemos fazer isso usando:

```ruby
prepend_view_path "app/views/#{request.subdomain}"
```

Então, o Action View irá procurar primeiro neste diretório ao resolver as visualizações.

### Append View Path

Da mesma forma, podemos adicionar caminhos:

```ruby
append_view_path "app/views/direct"
```

Isso irá adicionar `app/views/direct` ao final dos caminhos de pesquisa.

Helpers
-------

O Rails fornece muitos métodos auxiliares para usar com o Action View. Estes incluem métodos para:

* Formatação de datas, strings e números
* Criação de links HTML para imagens, vídeos, folhas de estilo, etc...
* Sanitização de conteúdo
* Criação de formulários
* Localização de conteúdo

Você pode aprender mais sobre os auxiliares no [Guia de Auxiliares do Action View](action_view_helpers.html) e no [Guia de Auxiliares de Formulário do Action View](form_helpers.html).

Visualizações Localizadas
---------------

O Action View tem a capacidade de renderizar diferentes modelos dependendo da localidade atual.

Por exemplo, suponha que você tenha um `ArticlesController` com uma ação de exibição. Por padrão, chamar esta ação irá renderizar `app/views/articles/show.html.erb`. Mas se você definir `I18n.locale = :de`, então `app/views/articles/show.de.html.erb` será renderizado em seu lugar. Se o modelo localizado não estiver presente, a versão não decorada será usada. Isso significa que você não é obrigado a fornecer visualizações localizadas para todos os casos, mas elas serão preferidas e usadas se estiverem disponíveis.

Você pode usar a mesma técnica para localizar os arquivos de resgate em seu diretório público. Por exemplo, definir `I18n.locale = :de` e criar `public/500.de.html` e `public/404.de.html` permitiria que você tivesse páginas de resgate localizadas.

Como o Rails não restringe os símbolos que você usa para definir I18n.locale, você pode aproveitar esse sistema para exibir conteúdo diferente dependendo do que quiser. Por exemplo, suponha que você tenha alguns usuários "especialistas" que devem ver páginas diferentes dos usuários "normais". Você poderia adicionar o seguinte em `app/controllers/application_controller.rb`:

```ruby
before_action :set_expert_locale

def set_expert_locale
  I18n.locale = :expert if current_user.expert?
end
```

Então você poderia criar visualizações especiais como `app/views/articles/show.expert.html.erb` que só seriam exibidas para usuários especialistas.

Você pode ler mais sobre a API de Internacionalização (I18n) do Rails [aqui](i18n.html).
