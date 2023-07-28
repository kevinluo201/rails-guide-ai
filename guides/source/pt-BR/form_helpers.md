**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 975163c53746728404fb3a3658fbd0f6
Action View Form Helpers
========================

Os formulários em aplicações web são uma interface essencial para a entrada de dados do usuário. No entanto, a marcação do formulário pode se tornar rapidamente tediosa de escrever e manter devido à necessidade de lidar com a nomenclatura dos controles do formulário e seus numerosos atributos. O Rails simplifica essa complexidade fornecendo helpers de visualização para gerar a marcação do formulário. No entanto, como esses helpers têm casos de uso diferentes, os desenvolvedores precisam conhecer as diferenças entre os métodos de helper antes de usá-los.

Após ler este guia, você saberá:

* Como criar formulários de pesquisa e formulários genéricos semelhantes que não representam nenhum modelo específico em sua aplicação.
* Como criar formulários centrados no modelo para criar e editar registros específicos do banco de dados.
* Como gerar caixas de seleção a partir de vários tipos de dados.
* Quais helpers de data e hora o Rails fornece.
* O que torna um formulário de upload de arquivo diferente.
* Como enviar formulários para recursos externos e especificar a configuração de um `authenticity_token`.
* Como construir formulários complexos.

--------------------------------------------------------------------------------

NOTA: Este guia não pretende ser uma documentação completa dos helpers de formulário disponíveis e seus argumentos. Por favor, visite [a documentação da API do Rails](https://api.rubyonrails.org/classes/ActionView/Helpers.html) para uma referência completa de todos os helpers disponíveis.

Lidando com Formulários Básicos
------------------------

O principal helper de formulário é [`form_with`](https://api.rubyonrails.org/classes/ActionView/Helpers/FormHelper.html#method-i-form_with).

```erb
<%= form_with do |form| %>
  Conteúdo do formulário
<% end %>
```

Quando chamado sem argumentos como este, ele cria uma tag de formulário que, quando enviado, fará um POST para a página atual. Por exemplo, supondo que a página atual seja uma página inicial, o HTML gerado será assim:

```html
<form accept-charset="UTF-8" action="/" method="post">
  <input name="authenticity_token" type="hidden" value="J7CBxfHalt49OSHp27hblqK20c9PgwJ108nDHX/8Cts=" />
  Conteúdo do formulário
</form>
```

Você notará que o HTML contém um elemento `input` com o tipo `hidden`. Este `input` é importante, porque formulários não-GET não podem ser enviados com sucesso sem ele.
O elemento `input` oculto com o nome `authenticity_token` é um recurso de segurança do Rails chamado **proteção contra falsificação de solicitação entre sites**, e os helpers de formulário o geram para cada formulário não-GET (desde que esse recurso de segurança esteja habilitado). Você pode ler mais sobre isso no guia [Securing Rails Applications](security.html#cross-site-request-forgery-csrf) (em inglês).

### Um Formulário de Pesquisa Genérico

Um dos formulários mais básicos que você vê na web é um formulário de pesquisa. Este formulário contém:

* um elemento de formulário com método "GET",
* um rótulo para a entrada,
* um elemento de entrada de texto, e
* um elemento de envio.

Para criar este formulário, você usará `form_with` e o objeto do construtor de formulários que ele gera. Assim:

```erb
<%= form_with url: "/search", method: :get do |form| %>
  <%= form.label :query, "Pesquisar por:" %>
  <%= form.text_field :query %>
  <%= form.submit "Pesquisar" %>
<% end %>
```

Isso gerará o seguinte HTML:

```html
<form action="/search" method="get" accept-charset="UTF-8" >
  <label for="query">Pesquisar por:</label>
  <input id="query" name="query" type="text" />
  <input name="commit" type="submit" value="Pesquisar" data-disable-with="Pesquisar" />
</form>
```

DICA: Passar `url: meu_caminho_especificado` para `form_with` informa ao formulário onde fazer a solicitação. No entanto, como explicado abaixo, você também pode passar objetos Active Record para o formulário.

DICA: Para cada entrada de formulário, um atributo ID é gerado a partir de seu nome (`"query"` no exemplo acima). Esses IDs podem ser muito úteis para estilizar CSS ou manipular controles de formulário com JavaScript.

IMPORTANTE: Use "GET" como o método para formulários de pesquisa. Isso permite que os usuários criem um marcador para uma pesquisa específica e voltem a ela. Mais geralmente, o Rails incentiva você a usar o verbo HTTP correto para uma ação.

### Helpers para Gerar Elementos de Formulário

O objeto construtor de formulários gerado por `form_with` fornece vários métodos auxiliares para gerar elementos de formulário, como campos de texto, caixas de seleção e botões de rádio. O primeiro parâmetro desses métodos é sempre o nome da
entrada. Quando o formulário é enviado, o nome será passado juntamente com o formulário
dados e chegará aos `params` no controlador com o
valor inserido pelo usuário para aquele campo. Por exemplo, se o formulário contiver
`<%= form.text_field :query %>`, então você poderá obter o valor deste
campo no controlador com `params[:query]`.

Ao nomear as entradas, o Rails usa certas convenções que permitem enviar parâmetros com valores não escalares, como arrays ou hashes, que também serão acessíveis em `params`. Você pode ler mais sobre eles na seção [Compreendendo as Convenções de Nomenclatura de Parâmetros](#compreendendo-as-convenções-de-nomenclatura-de-parâmetros) deste guia. Para detalhes sobre o uso preciso desses helpers, consulte a [documentação da API](https://api.rubyonrails.org/classes/ActionView/Helpers/FormTagHelper.html).
#### Caixas de seleção

As caixas de seleção são controles de formulário que fornecem ao usuário um conjunto de opções que eles podem habilitar ou desabilitar:

```erb
<%= form.check_box :pet_dog %>
<%= form.label :pet_dog, "Eu tenho um cachorro" %>
<%= form.check_box :pet_cat %>
<%= form.label :pet_cat, "Eu tenho um gato" %>
```

Isso gera o seguinte:

```html
<input type="checkbox" id="pet_dog" name="pet_dog" value="1" />
<label for="pet_dog">Eu tenho um cachorro</label>
<input type="checkbox" id="pet_cat" name="pet_cat" value="1" />
<label for="pet_cat">Eu tenho um gato</label>
```

O primeiro parâmetro para [`check_box`](https://api.rubyonrails.org/classes/ActionView/Helpers/FormBuilder.html#method-i-check_box) é o nome do input. Os valores da caixa de seleção (os valores que aparecerão em `params`) podem ser especificados opcionalmente usando os terceiro e quarto parâmetros. Consulte a documentação da API para obter mais detalhes.

#### Botões de rádio

Os botões de rádio, embora semelhantes às caixas de seleção, são controles que especificam um conjunto de opções em que são mutuamente exclusivos (ou seja, o usuário só pode escolher um):

```erb
<%= form.radio_button :age, "child" %>
<%= form.label :age_child, "Eu sou menor de 21 anos" %>
<%= form.radio_button :age, "adult" %>
<%= form.label :age_adult, "Eu sou maior de 21 anos" %>
```

Saída:

```html
<input type="radio" id="age_child" name="age" value="child" />
<label for="age_child">Eu sou menor de 21 anos</label>
<input type="radio" id="age_adult" name="age" value="adult" />
<label for="age_adult">Eu sou maior de 21 anos</label>
```

O segundo parâmetro para [`radio_button`](https://api.rubyonrails.org/classes/ActionView/Helpers/FormBuilder.html#method-i-radio_button) é o valor do input. Como esses dois botões de rádio compartilham o mesmo nome (`age`), o usuário só poderá selecionar um deles, e `params[:age]` conterá `"child"` ou `"adult"`.

NOTA: Sempre use rótulos para caixas de seleção e botões de rádio. Eles associam texto a uma opção específica e, ao expandir a região clicável, facilitam para os usuários clicarem nos inputs.

### Outros ajudantes de interesse

Outros controles de formulário que valem a pena mencionar são áreas de texto, campos ocultos, campos de senha, campos numéricos, campos de data e hora e muitos outros:

```erb
<%= form.text_area :message, size: "70x5" %>
<%= form.hidden_field :parent_id, value: "foo" %>
<%= form.password_field :password %>
<%= form.number_field :price, in: 1.0..20.0, step: 0.5 %>
<%= form.range_field :discount, in: 1..100 %>
<%= form.date_field :born_on %>
<%= form.time_field :started_at %>
<%= form.datetime_local_field :graduation_day %>
<%= form.month_field :birthday_month %>
<%= form.week_field :birthday_week %>
<%= form.search_field :name %>
<%= form.email_field :address %>
<%= form.telephone_field :phone %>
<%= form.url_field :homepage %>
<%= form.color_field :favorite_color %>
```

Saída:

```html
<textarea name="message" id="message" cols="70" rows="5"></textarea>
<input type="hidden" name="parent_id" id="parent_id" value="foo" />
<input type="password" name="password" id="password" />
<input type="number" name="price" id="price" step="0.5" min="1.0" max="20.0" />
<input type="range" name="discount" id="discount" min="1" max="100" />
<input type="date" name="born_on" id="born_on" />
<input type="time" name="started_at" id="started_at" />
<input type="datetime-local" name="graduation_day" id="graduation_day" />
<input type="month" name="birthday_month" id="birthday_month" />
<input type="week" name="birthday_week" id="birthday_week" />
<input type="search" name="name" id="name" />
<input type="email" name="address" id="address" />
<input type="tel" name="phone" id="phone" />
<input type="url" name="homepage" id="homepage" />
<input type="color" name="favorite_color" id="favorite_color" value="#000000" />
```

Inputs ocultos não são mostrados ao usuário, mas em vez disso, armazenam dados como qualquer input textual. Os valores dentro deles podem ser alterados com JavaScript.

IMPORTANTE: Os inputs de pesquisa, telefone, data, hora, cor, data e hora, mês, semana, URL, e-mail, número e intervalo são controles HTML5. Se você precisar que seu aplicativo tenha uma experiência consistente em navegadores mais antigos, será necessário um polyfill HTML5 (fornecido por CSS e/ou JavaScript). Definitivamente, [não há escassez de soluções para isso](https://github.com/Modernizr/Modernizr/wiki/HTML5-Cross-Browser-Polyfills), embora uma ferramenta popular no momento seja o [Modernizr](https://modernizr.com/), que fornece uma maneira simples de adicionar funcionalidade com base na presença de recursos HTML5 detectados.

DICA: Se você estiver usando campos de input de senha (para qualquer finalidade), talvez queira configurar seu aplicativo para evitar que esses parâmetros sejam registrados. Você pode aprender sobre isso no guia [Securing Rails Applications](security.html#logging).

Lidando com objetos de modelo
--------------------------

### Vinculando um formulário a um objeto

O argumento `:model` do `form_with` nos permite vincular o objeto do construtor de formulários a um objeto de modelo. Isso significa que o formulário será limitado a esse objeto de modelo e os campos do formulário serão preenchidos com os valores desse objeto de modelo.

Por exemplo, se tivermos um objeto de modelo `@article` como:

```ruby
@article = Article.find(42)
# => #<Article id: 42, title: "Meu Título", body: "Meu Corpo">
```

O formulário a seguir:

```erb
<%= form_with model: @article do |form| %>
  <%= form.text_field :title %>
  <%= form.text_area :body, size: "60x10" %>
  <%= form.submit %>
<% end %>
```

Gera:

```html
<form action="/articles/42" method="post" accept-charset="UTF-8" >
  <input name="authenticity_token" type="hidden" value="..." />
  <input type="text" name="article[title]" id="article_title" value="Meu Título" />
  <textarea name="article[body]" id="article_body" cols="60" rows="10">
    Meu Corpo
  </textarea>
  <input type="submit" name="commit" value="Atualizar Artigo" data-disable-with="Atualizar Artigo">
</form>
```
Existem várias coisas para observar aqui:

* O atributo `action` do formulário é preenchido automaticamente com um valor apropriado para `@article`.
* Os campos do formulário são preenchidos automaticamente com os valores correspondentes de `@article`.
* Os nomes dos campos do formulário são escopados com `article[...]`. Isso significa que `params[:article]` será um hash contendo os valores desses campos. Você pode ler mais sobre o significado dos nomes de entrada no capítulo [Compreendendo as Convenções de Nomenclatura de Parâmetros](#compreendendo-as-convenções-de-nomenclatura-de-parâmetros) deste guia.
* O botão de envio é automaticamente atribuído um valor de texto apropriado.

DICA: Convenções sugerem que seus campos de entrada reflitam os atributos do modelo. No entanto, eles não precisam! Se houver outras informações que você precisa, você pode incluí-las em seu formulário da mesma forma que os atributos e acessá-las através de `params[:article][:my_nifty_non_attribute_input]`.

#### O Helper `fields_for`

O helper [`fields_for`][] cria uma ligação semelhante, mas sem renderizar uma tag `<form>`. Isso pode ser usado para renderizar campos para objetos de modelo adicionais dentro do mesmo formulário. Por exemplo, se você tiver um modelo `Person` com um modelo associado `ContactDetail`, você pode criar um único formulário para ambos da seguinte maneira:

```erb
<%= form_with model: @person do |person_form| %>
  <%= person_form.text_field :name %>
  <%= fields_for :contact_detail, @person.contact_detail do |contact_detail_form| %>
    <%= contact_detail_form.text_field :phone_number %>
  <% end %>
<% end %>
```

Que produz a seguinte saída:

```html
<form action="/people" accept-charset="UTF-8" method="post">
  <input type="hidden" name="authenticity_token" value="bL13x72pldyDD8bgtkjKQakJCpd4A8JdXGbfksxBDHdf1uC0kCMqe2tvVdUYfidJt0fj3ihC4NxiVHv8GVYxJA==" />
  <input type="text" name="person[name]" id="person_name" />
  <input type="text" name="contact_detail[phone_number]" id="contact_detail_phone_number" />
</form>
```

O objeto retornado por `fields_for` é um construtor de formulários, assim como o retornado por `form_with`.


### Dependendo da Identificação do Registro

O modelo Article está diretamente disponível para os usuários do aplicativo, então - seguindo as melhores práticas para desenvolvimento com Rails - você deve declará-lo **um recurso**:

```ruby
resources :articles
```

DICA: Declarar um recurso tem vários efeitos colaterais. Veja o guia [Rails Routing from the Outside In](routing.html#resource-routing-the-rails-default) para obter mais informações sobre como configurar e usar recursos.

Ao lidar com recursos RESTful, as chamadas para `form_with` podem se tornar significativamente mais fáceis se você depender da **identificação do registro**. Em resumo, você pode simplesmente passar a instância do modelo e deixar o Rails descobrir o nome do modelo e o resto. Em ambos os exemplos, o estilo longo e o estilo curto têm o mesmo resultado:

```ruby
## Criando um novo artigo
# estilo longo:
form_with(model: @article, url: articles_path)
# estilo curto:
form_with(model: @article)

## Editando um artigo existente
# estilo longo:
form_with(model: @article, url: article_path(@article), method: "patch")
# estilo curto:
form_with(model: @article)
```

Observe como a invocação de `form_with` no estilo curto é convenientemente a mesma, independentemente do registro ser novo ou existente. A identificação do registro é inteligente o suficiente para descobrir se o registro é novo perguntando `record.persisted?`. Ele também seleciona o caminho correto para enviar os dados e o nome com base na classe do objeto.

Se você tiver um [recurso singular](routing.html#singular-resources), precisará chamar `resource` e `resolve` para que ele funcione com `form_with`:

```ruby
resource :geocoder
resolve('Geocoder') { [:geocoder] }
```

ATENÇÃO: Quando você está usando STI (herança de tabela única) com seus modelos, você não pode depender da identificação do registro em uma subclasse se apenas a classe pai for declarada como um recurso. Você terá que especificar `:url` e `:scope` (o nome do modelo) explicitamente.

#### Lidando com Namespaces

Se você criou rotas com namespaces, `form_with` também tem uma forma simplificada para isso. Se sua aplicação tiver um namespace admin, então

```ruby
form_with model: [:admin, @article]
```

irá criar um formulário que envia para o `ArticlesController` dentro do namespace admin (enviando para `admin_article_path(@article)` no caso de uma atualização). Se você tiver vários níveis de namespaces, a sintaxe é semelhante:

```ruby
form_with model: [:admin, :management, @article]
```

Para obter mais informações sobre o sistema de roteamento do Rails e as convenções associadas, consulte o guia [Rails Routing from the Outside In](routing.html).

### Como funcionam os formulários com os métodos PATCH, PUT ou DELETE?

O framework Rails incentiva o design RESTful de suas aplicações, o que significa que você fará muitas solicitações "PATCH", "PUT" e "DELETE" (além de "GET" e "POST"). No entanto, a maioria dos navegadores _não suporta_ métodos diferentes de "GET" e "POST" ao enviar formulários.

O Rails contorna esse problema emulando outros métodos através de POST com um campo oculto chamado `"_method"`, que é definido para refletir o método desejado:

```ruby
form_with(url: search_path, method: "patch")
```

Saída:

```html
<form accept-charset="UTF-8" action="/search" method="post">
  <input name="_method" type="hidden" value="patch" />
  <input name="authenticity_token" type="hidden" value="f755bb0ed134b76c432144748a6d4b7a7ddf2b71" />
  <!-- ... -->
</form>
```
Ao analisar os dados enviados por POST, o Rails levará em consideração o parâmetro especial `_method` e agirá como se o método HTTP fosse o especificado nele ("PATCH" neste exemplo).

Ao renderizar um formulário, os botões de envio podem substituir o atributo `method` declarado através da palavra-chave `formmethod:`:

```erb
<%= form_with url: "/posts/1", method: :patch do |form| %>
  <%= form.button "Excluir", formmethod: :delete, data: { confirm: "Tem certeza?" } %>
  <%= form.button "Atualizar" %>
<% end %>
```

Semelhante aos elementos `<form>`, a maioria dos navegadores _não suporta_ a substituição de métodos de formulário declarados através de [formmethod][] que não sejam "GET" e "POST".

O Rails contorna esse problema emulando outros métodos sobre POST por meio de uma combinação de [formmethod][], [value][button-value] e [name][button-name]:

```html
<form accept-charset="UTF-8" action="/posts/1" method="post">
  <input name="_method" type="hidden" value="patch" />
  <input name="authenticity_token" type="hidden" value="f755bb0ed134b76c432144748a6d4b7a7ddf2b71" />
  <!-- ... -->

  <button type="submit" formmethod="post" name="_method" value="delete" data-confirm="Tem certeza?">Excluir</button>
  <button type="submit" name="button">Atualizar</button>
</form>
```


Criando Caixas de Seleção com Facilidade
----------------------------------------

Caixas de seleção em HTML requerem uma quantidade significativa de marcação - um elemento `<option>` para cada opção a ser escolhida. Portanto, o Rails fornece métodos auxiliares para reduzir essa carga.

Por exemplo, digamos que temos uma lista de cidades para o usuário escolher. Podemos usar o helper [`select`](https://api.rubyonrails.org/classes/ActionView/Helpers/FormBuilder.html#method-i-select) da seguinte forma:

```erb
<%= form.select :city, ["Berlim", "Chicago", "Madri"] %>
```

Saída:

```html
<select name="city" id="city">
  <option value="Berlim">Berlim</option>
  <option value="Chicago">Chicago</option>
  <option value="Madri">Madri</option>
</select>
```

Também podemos designar valores `<option>` diferentes de seus rótulos:

```erb
<%= form.select :city, [["Berlim", "BE"], ["Chicago", "CHI"], ["Madri", "MD"]] %>
```

Saída:

```html
<select name="city" id="city">
  <option value="BE">Berlim</option>
  <option value="CHI">Chicago</option>
  <option value="MD">Madri</option>
</select>
```

Dessa forma, o usuário verá o nome completo da cidade, mas `params[:city]` será um dos valores `"BE"`, `"CHI"` ou `"MD"`.

Por fim, podemos especificar uma escolha padrão para a caixa de seleção com o argumento `:selected`:

```erb
<%= form.select :city, [["Berlim", "BE"], ["Chicago", "CHI"], ["Madri", "MD"]], selected: "CHI" %>
```

Saída:

```html
<select name="city" id="city">
  <option value="BE">Berlim</option>
  <option value="CHI" selected="selected">Chicago</option>
  <option value="MD">Madri</option>
</select>
```

### Grupos de Opções

Em alguns casos, podemos querer melhorar a experiência do usuário agrupando opções relacionadas. Podemos fazer isso passando um `Hash` (ou `Array` comparável) para `select`:

```erb
<%= form.select :city,
      {
        "Europa" => [ ["Berlim", "BE"], ["Madri", "MD"] ],
        "América do Norte" => [ ["Chicago", "CHI"] ],
      },
      selected: "CHI" %>
```

Saída:

```html
<select name="city" id="city">
  <optgroup label="Europa">
    <option value="BE">Berlim</option>
    <option value="MD">Madri</option>
  </optgroup>
  <optgroup label="América do Norte">
    <option value="CHI" selected="selected">Chicago</option>
  </optgroup>
</select>
```

### Caixas de Seleção e Objetos de Modelo

Assim como outros controles de formulário, uma caixa de seleção pode ser vinculada a um atributo do modelo. Por exemplo, se tivermos um objeto de modelo `@person` como:

```ruby
@person = Person.new(city: "MD")
```

O formulário a seguir:

```erb
<%= form_with model: @person do |form| %>
  <%= form.select :city, [["Berlim", "BE"], ["Chicago", "CHI"], ["Madri", "MD"]] %>
<% end %>
```

Gera uma caixa de seleção como:

```html
<select name="person[city]" id="person_city">
  <option value="BE">Berlim</option>
  <option value="CHI">Chicago</option>
  <option value="MD" selected="selected">Madri</option>
</select>
```

Observe que a opção apropriada foi automaticamente marcada como `selected="selected"`. Como essa caixa de seleção foi vinculada a um modelo, não precisamos especificar um argumento `:selected`!

### Seleção de Fuso Horário e País

Para aproveitar o suporte a fusos horários no Rails, você precisa perguntar aos seus usuários em qual fuso horário eles estão. Fazer isso exigiria gerar opções de seleção a partir de uma lista de objetos [`ActiveSupport::TimeZone`](https://api.rubyonrails.org/classes/ActiveSupport/TimeZone.html) pré-definidos, mas você pode simplesmente usar o helper [`time_zone_select`](https://api.rubyonrails.org/classes/ActionView/Helpers/FormBuilder.html#method-i-time_zone_select) que já envolve isso:

```erb
<%= form.time_zone_select :time_zone %>
```

O Rails _costumava ter_ um helper `country_select` para escolher países, mas isso foi extraído para o [plugin country_select](https://github.com/stefanpenner/country_select).

Usando Helpers de Formulário de Data e Hora
-------------------------------------------

Se você não deseja usar entradas de data e hora HTML5, o Rails fornece helpers de formulário de data e hora alternativos que renderizam caixas de seleção simples. Esses helpers renderizam uma caixa de seleção para cada componente temporal (por exemplo, ano, mês, dia, etc). Por exemplo, se tivermos um objeto de modelo `@person` como:

```ruby
@person = Person.new(birth_date: Date.new(1995, 12, 21))
```

O formulário a seguir:

```erb
<%= form_with model: @person do |form| %>
  <%= form.date_select :birth_date %>
<% end %>
```

Gera caixas de seleção como:

```html
<select name="person[birth_date(1i)]" id="person_birth_date_1i">
  <option value="1990">1990</option>
  <option value="1991">1991</option>
  <option value="1992">1992</option>
  <option value="1993">1993</option>
  <option value="1994">1994</option>
  <option value="1995" selected="selected">1995</option>
  <option value="1996">1996</option>
  <option value="1997">1997</option>
  <option value="1998">1998</option>
  <option value="1999">1999</option>
  <option value="2000">2000</option>
</select>
<select name="person[birth_date(2i)]" id="person_birth_date_2i">
  <option value="1">Janeiro</option>
  <option value="2">Fevereiro</option>
  <option value="3">Março</option>
  <option value="4">Abril</option>
  <option value="5">Maio</option>
  <option value="6">Junho</option>
  <option value="7">Julho</option>
  <option value="8">Agosto</option>
  <option value="9">Setembro</option>
  <option value="10">Outubro</option>
  <option value="11">Novembro</option>
  <option value="12" selected="selected">Dezembro</option>
</select>
<select name="person[birth_date(3i)]" id="person_birth_date_3i">
  <option value="1">1</option>
  ...
  <option value="21" selected="selected">21</option>
  ...
  <option value="31">31</option>
</select>
```
Observe que, quando o formulário é enviado, não haverá um único valor no hash `params` que contenha a data completa. Em vez disso, haverá vários valores com nomes especiais como `"birth_date(1i)"`. O Active Record sabe como montar esses valores com nomes especiais em uma data ou hora completa, com base no tipo declarado do atributo do modelo. Portanto, podemos passar `params[:person]` para, por exemplo, `Person.new` ou `Person#update` da mesma forma que faríamos se o formulário usasse um único campo para representar a data completa.

Além do helper [`date_select`](https://api.rubyonrails.org/classes/ActionView/Helpers/FormBuilder.html#method-i-date_select), o Rails fornece [`time_select`](https://api.rubyonrails.org/classes/ActionView/Helpers/FormBuilder.html#method-i-time_select) e [`datetime_select`](https://api.rubyonrails.org/classes/ActionView/Helpers/FormBuilder.html#method-i-datetime_select).

### Caixas de seleção para componentes temporais individuais

O Rails também fornece helpers para renderizar caixas de seleção para componentes temporais individuais: [`select_year`](https://api.rubyonrails.org/classes/ActionView/Helpers/DateHelper.html#method-i-select_year), [`select_month`](https://api.rubyonrails.org/classes/ActionView/Helpers/DateHelper.html#method-i-select_month), [`select_day`](https://api.rubyonrails.org/classes/ActionView/Helpers/DateHelper.html#method-i-select_day), [`select_hour`](https://api.rubyonrails.org/classes/ActionView/Helpers/DateHelper.html#method-i-select_hour), [`select_minute`](https://api.rubyonrails.org/classes/ActionView/Helpers/DateHelper.html#method-i-select_minute) e [`select_second`](https://api.rubyonrails.org/classes/ActionView/Helpers/DateHelper.html#method-i-select_second). Esses helpers são métodos "puros", o que significa que eles não são chamados em uma instância de form builder. Por exemplo:

```erb
<%= select_year 1999, prefix: "party" %>
```

Gera uma caixa de seleção como:

```html
<select name="party[year]" id="party_year">
  <option value="1994">1994</option>
  <option value="1995">1995</option>
  <option value="1996">1996</option>
  <option value="1997">1997</option>
  <option value="1998">1998</option>
  <option value="1999" selected="selected">1999</option>
  <option value="2000">2000</option>
  <option value="2001">2001</option>
  <option value="2002">2002</option>
  <option value="2003">2003</option>
  <option value="2004">2004</option>
</select>
```

Para cada um desses helpers, você pode especificar um objeto de data ou hora em vez de um número como valor padrão, e o componente temporal apropriado será extraído e usado.

Escolhas a partir de uma coleção de objetos arbitrários
------------------------------------------------------

Às vezes, queremos gerar um conjunto de escolhas a partir de uma coleção de objetos arbitrários. Por exemplo, se tivermos um modelo `City` e uma associação correspondente `belongs_to :city`:

```ruby
class City < ApplicationRecord
end

class Person < ApplicationRecord
  belongs_to :city
end
```

```ruby
City.order(:name).map { |city| [city.name, city.id] }
# => [["Berlin", 3], ["Chicago", 1], ["Madrid", 2]]
```

Então podemos permitir que o usuário escolha uma cidade do banco de dados com o seguinte formulário:

```erb
<%= form_with model: @person do |form| %>
  <%= form.select :city_id, City.order(:name).map { |city| [city.name, city.id] } %>
<% end %>
```

NOTA: Ao renderizar um campo para uma associação `belongs_to`, você deve especificar o nome da chave estrangeira (`city_id` no exemplo acima), em vez do nome da associação em si.

No entanto, o Rails fornece helpers que geram escolhas a partir de uma coleção sem a necessidade de iterar explicitamente sobre ela. Esses helpers determinam o valor e o rótulo de texto de cada escolha chamando métodos especificados em cada objeto da coleção.

### O helper `collection_select`

Para gerar uma caixa de seleção, podemos usar o [`collection_select`](https://api.rubyonrails.org/classes/ActionView/Helpers/FormBuilder.html#method-i-collection_select):

```erb
<%= form.collection_select :city_id, City.order(:name), :id, :name %>
```

Saída:

```html
<select name="person[city_id]" id="person_city_id">
  <option value="3">Berlin</option>
  <option value="1">Chicago</option>
  <option value="2">Madrid</option>
</select>
```

NOTA: Com o `collection_select`, especificamos primeiro o método de valor (`:id` no exemplo acima) e depois o método de rótulo de texto (`:name` no exemplo acima). Isso é o oposto da ordem usada ao especificar escolhas para o helper `select`, onde o rótulo de texto vem primeiro e o valor em segundo.

### O helper `collection_radio_buttons`

Para gerar um conjunto de botões de rádio, podemos usar o [`collection_radio_buttons`](https://api.rubyonrails.org/classes/ActionView/Helpers/FormBuilder.html#method-i-collection_radio_buttons):

```erb
<%= form.collection_radio_buttons :city_id, City.order(:name), :id, :name %>
```

Saída:

```html
<input type="radio" name="person[city_id]" value="3" id="person_city_id_3">
<label for="person_city_id_3">Berlin</label>

<input type="radio" name="person[city_id]" value="1" id="person_city_id_1">
<label for="person_city_id_1">Chicago</label>

<input type="radio" name="person[city_id]" value="2" id="person_city_id_2">
<label for="person_city_id_2">Madrid</label>
```

### O helper `collection_check_boxes`

Para gerar um conjunto de caixas de seleção - por exemplo, para suportar uma associação `has_and_belongs_to_many` - podemos usar o [`collection_check_boxes`](https://api.rubyonrails.org/classes/ActionView/Helpers/FormBuilder.html#method-i-collection_check_boxes):

```erb
<%= form.collection_check_boxes :interest_ids, Interest.order(:name), :id, :name %>
```

Saída:

```html
<input type="checkbox" name="person[interest_id][]" value="3" id="person_interest_id_3">
<label for="person_interest_id_3">Engineering</label>

<input type="checkbox" name="person[interest_id][]" value="4" id="person_interest_id_4">
<label for="person_interest_id_4">Math</label>

<input type="checkbox" name="person[interest_id][]" value="1" id="person_interest_id_1">
<label for="person_interest_id_1">Science</label>

<input type="checkbox" name="person[interest_id][]" value="2" id="person_interest_id_2">
<label for="person_interest_id_2">Technology</label>
```

Upload de arquivos
------------------

Uma tarefa comum é fazer o upload de algum tipo de arquivo, seja uma foto de uma pessoa ou um arquivo CSV contendo dados para processar. Campos de upload de arquivos podem ser renderizados com o helper [`file_field`](https://api.rubyonrails.org/classes/ActionView/Helpers/FormBuilder.html#method-i-file_field).

```erb
<%= form_with model: @person do |form| %>
  <%= form.file_field :picture %>
<% end %>
```

A coisa mais importante a lembrar com uploads de arquivos é que o atributo `enctype` do formulário renderizado **deve** ser definido como "multipart/form-data". Isso é feito automaticamente se você usar um `file_field` dentro de um `form_with`. Você também pode definir o atributo manualmente:

```erb
<%= form_with url: "/uploads", multipart: true do |form| %>
  <%= file_field_tag :picture %>
<% end %>
```

Observe que, de acordo com as convenções do `form_with`, os nomes dos campos nos dois formulários também serão diferentes. Ou seja, o nome do campo no primeiro formulário será `person[picture]` (acessível via `params[:person][:picture]`), e o nome do campo no segundo formulário será apenas `picture` (acessível via `params[:picture]`).
### O que é enviado

O objeto no hash `params` é uma instância de [`ActionDispatch::Http::UploadedFile`](https://api.rubyonrails.org/classes/ActionDispatch/Http/UploadedFile.html). O trecho a seguir salva o arquivo enviado em `#{Rails.root}/public/uploads` com o mesmo nome do arquivo original.

```ruby
def upload
  uploaded_file = params[:picture]
  File.open(Rails.root.join('public', 'uploads', uploaded_file.original_filename), 'wb') do |file|
    file.write(uploaded_file.read)
  end
end
```

Depois que um arquivo é enviado, existem várias tarefas potenciais, desde onde armazenar os arquivos (no disco, Amazon S3, etc), associá-los a modelos, redimensionar arquivos de imagem e gerar miniaturas, etc. [Active Storage](active_storage_overview.html) é projetado para auxiliar nessas tarefas.

Personalizando Form Builders
-------------------------

O objeto retornado por `form_with` e `fields_for` é uma instância de [`ActionView::Helpers::FormBuilder`](https://api.rubyonrails.org/classes/ActionView/Helpers/FormBuilder.html). Os form builders encapsulam a ideia de exibir elementos de formulário para um único objeto. Embora você possa escrever helpers para seus formulários da maneira usual, você também pode criar uma subclasse de `ActionView::Helpers::FormBuilder` e adicionar os helpers lá. Por exemplo,

```erb
<%= form_with model: @person do |form| %>
  <%= text_field_with_label form, :first_name %>
<% end %>
```

pode ser substituído por

```erb
<%= form_with model: @person, builder: LabellingFormBuilder do |form| %>
  <%= form.text_field :first_name %>
<% end %>
```

definindo uma classe `LabellingFormBuilder` semelhante à seguinte:

```ruby
class LabellingFormBuilder < ActionView::Helpers::FormBuilder
  def text_field(attribute, options = {})
    label(attribute) + super
  end
end
```

Se você reutilizar isso com frequência, poderá definir um helper `labeled_form_with` que aplique automaticamente a opção `builder: LabellingFormBuilder`:

```ruby
def labeled_form_with(model: nil, scope: nil, url: nil, format: nil, **options, &block)
  options[:builder] = LabellingFormBuilder
  form_with model: model, scope: scope, url: url, format: format, **options, &block
end
```

O form builder usado também determina o que acontece quando você faz:

```erb
<%= render partial: f %>
```

Se `f` for uma instância de `ActionView::Helpers::FormBuilder`, isso renderizará o partial `form`, definindo o objeto do partial como o form builder. Se o form builder for da classe `LabellingFormBuilder`, então o partial `labelling_form` será renderizado.

Entendendo as Convenções de Nomenclatura de Parâmetros
------------------------------------------

Os valores dos formulários podem estar no nível superior do hash `params` ou aninhados em outro hash. Por exemplo, em uma ação `create` padrão para um modelo Person, `params[:person]` geralmente seria um hash com todos os atributos da pessoa a ser criada. O hash `params` também pode conter arrays, arrays de hashes e assim por diante.

Fundamentalmente, os formulários HTML não conhecem nenhum tipo de dados estruturados, tudo o que eles geram são pares de nome-valor, onde os pares são apenas strings simples. Os arrays e hashes que você vê em sua aplicação são o resultado de algumas convenções de nomenclatura de parâmetros que o Rails usa.

### Estruturas Básicas

As duas estruturas básicas são arrays e hashes. Os hashes refletem a sintaxe usada para acessar o valor em `params`. Por exemplo, se um formulário contém:

```html
<input id="person_name" name="person[name]" type="text" value="Henry"/>
```

o hash `params` conterá

```ruby
{ 'person' => { 'name' => 'Henry' } }
```

e `params[:person][:name]` recuperará o valor enviado no controller.

Hashes podem ser aninhados quantos níveis forem necessários, por exemplo:

```html
<input id="person_address_city" name="person[address][city]" type="text" value="New York"/>
```

resultará no hash `params` sendo

```ruby
{ 'person' => { 'address' => { 'city' => 'New York' } } }
```

Normalmente, o Rails ignora nomes de parâmetros duplicados. Se o nome do parâmetro terminar com um conjunto vazio de colchetes `[]`, eles serão acumulados em um array. Se você quiser permitir que os usuários insiram vários números de telefone, você pode colocar isso no formulário:

```html
<input name="person[phone_number][]" type="text"/>
<input name="person[phone_number][]" type="text"/>
<input name="person[phone_number][]" type="text"/>
```

Isso resultaria em `params[:person][:phone_number]` sendo um array contendo os números de telefone inseridos.

### Combinando-os

Podemos misturar e combinar esses dois conceitos. Um elemento de um hash pode ser um array, como no exemplo anterior, ou você pode ter um array de hashes. Por exemplo, um formulário pode permitir que você crie qualquer número de endereços repetindo o seguinte fragmento de formulário

```html
<input name="person[addresses][][line1]" type="text"/>
<input name="person[addresses][][line2]" type="text"/>
<input name="person[addresses][][city]" type="text"/>
<input name="person[addresses][][line1]" type="text"/>
<input name="person[addresses][][line2]" type="text"/>
<input name="person[addresses][][city]" type="text"/>
```

Isso resultaria em `params[:person][:addresses]` sendo um array de hashes com as chaves `line1`, `line2` e `city`.

No entanto, há uma restrição: enquanto os hashes podem ser aninhados arbitrariamente, apenas um nível de "arrayness" é permitido. Arrays geralmente podem ser substituídos por hashes; por exemplo, em vez de ter um array de objetos de modelo, pode-se ter um hash de objetos de modelo com chave em seu id, um índice de array ou algum outro parâmetro.
AVISO: Os parâmetros de array não funcionam bem com o auxiliar `check_box`. De acordo com a especificação HTML, caixas de seleção desmarcadas não enviam nenhum valor. No entanto, muitas vezes é conveniente que uma caixa de seleção sempre envie um valor. O auxiliar `check_box` simula isso criando um campo de entrada oculto auxiliar com o mesmo nome. Se a caixa de seleção estiver desmarcada, apenas o campo de entrada oculto será enviado e, se estiver marcada, ambos serão enviados, mas o valor enviado pela caixa de seleção terá precedência.

### A opção `:index` do auxiliar `fields_for`

Vamos supor que queremos renderizar um formulário com um conjunto de campos para cada um dos endereços de uma pessoa. O auxiliar [`fields_for`][] com sua opção `:index` pode ajudar:

```erb
<%= form_with model: @person do |person_form| %>
  <%= person_form.text_field :name %>
  <% @person.addresses.each do |address| %>
    <%= person_form.fields_for address, index: address.id do |address_form| %>
      <%= address_form.text_field :city %>
    <% end %>
  <% end %>
<% end %>
```

Supondo que a pessoa tenha dois endereços com IDs 23 e 45, o formulário acima renderizará uma saída semelhante a:

```html
<form accept-charset="UTF-8" action="/people/1" method="post">
  <input name="_method" type="hidden" value="patch" />
  <input id="person_name" name="person[name]" type="text" />
  <input id="person_address_23_city" name="person[address][23][city]" type="text" />
  <input id="person_address_45_city" name="person[address][45][city]" type="text" />
</form>
```

O que resultará em um hash `params` que se parece com:

```ruby
{
  "person" => {
    "name" => "Bob",
    "address" => {
      "23" => {
        "city" => "Paris"
      },
      "45" => {
        "city" => "London"
      }
    }
  }
}
```

Todos os campos de entrada do formulário são mapeados para o hash `"person"` porque chamamos `fields_for` no construtor de formulários `person_form`. Além disso, ao especificar `index: address.id`, renderizamos o atributo `name` de cada campo de cidade como `person[address][#{address.id}][city]` em vez de `person[address][city]`. Assim, podemos determinar quais registros de endereço devem ser modificados ao processar o hash `params`.

Você pode passar outros números ou strings de significado através da opção `:index`. Você até pode passar `nil`, o que produzirá um parâmetro de array.

Para criar aninhamentos mais complexos, você pode especificar explicitamente a parte inicial do nome do campo de entrada. Por exemplo:

```erb
<%= fields_for 'person[address][primary]', address, index: address.id do |address_form| %>
  <%= address_form.text_field :city %>
<% end %>
```

irá criar campos de entrada como:

```html
<input id="person_address_primary_23_city" name="person[address][primary][23][city]" type="text" value="Paris" />
```

Você também pode passar uma opção `:index` diretamente para auxiliares como `text_field`, mas geralmente é menos repetitivo especificar isso no nível do construtor de formulários do que em campos de entrada individuais.

Falando de forma geral, o nome final do campo de entrada será uma concatenação do nome fornecido para `fields_for` / `form_with`, o valor da opção `:index` e o nome do atributo.

Por fim, como atalho, em vez de especificar um ID para `:index` (por exemplo, `index: address.id`), você pode adicionar `"[]"` ao nome fornecido. Por exemplo:

```erb
<%= fields_for 'person[address][primary][]', address do |address_form| %>
  <%= address_form.text_field :city %>
<% end %>
```

produzirá exatamente a mesma saída que nosso exemplo original.

Formulários para Recursos Externos
---------------------------------

Os auxiliares de formulário do Rails também podem ser usados para criar um formulário para enviar dados a um recurso externo. No entanto, às vezes pode ser necessário definir um `authenticity_token` para o recurso; isso pode ser feito passando um parâmetro `authenticity_token: 'seu_token_externo'` para as opções do `form_with`:

```erb
<%= form_with url: 'http://longe.longe/form', authenticity_token: 'token_externo' do %>
  Conteúdo do formulário
<% end %>
```

Às vezes, ao enviar dados para um recurso externo, como um gateway de pagamento, os campos que podem ser usados no formulário são limitados por uma API externa e pode ser indesejável gerar um `authenticity_token`. Para não enviar um token, basta passar `false` para a opção `:authenticity_token`:

```erb
<%= form_with url: 'http://longe.longe/form', authenticity_token: false do %>
  Conteúdo do formulário
<% end %>
```

Construindo Formulários Complexos
--------------------------------

Muitos aplicativos vão além de formulários simples que editam um único objeto. Por exemplo, ao criar uma `Person`, você pode querer permitir que o usuário (no mesmo formulário) crie vários registros de endereço (casa, trabalho, etc.). Ao editar posteriormente essa pessoa, o usuário deve ser capaz de adicionar, remover ou modificar endereços conforme necessário.

### Configurando o Modelo

O Active Record fornece suporte em nível de modelo por meio do método [`accepts_nested_attributes_for`](https://api.rubyonrails.org/classes/ActiveRecord/NestedAttributes/ClassMethods.html#method-i-accepts_nested_attributes_for):

```ruby
class Person < ApplicationRecord
  has_many :addresses, inverse_of: :person
  accepts_nested_attributes_for :addresses
end

class Address < ApplicationRecord
  belongs_to :person
end
```

Isso cria um método `addresses_attributes=` em `Person` que permite criar, atualizar e (opcionalmente) excluir endereços.
### Formulários Aninhados

O formulário a seguir permite que um usuário crie uma `Person` e seus endereços associados.

```html+erb
<%= form_with model: @person do |form| %>
  Endereços:
  <ul>
    <%= form.fields_for :addresses do |addresses_form| %>
      <li>
        <%= addresses_form.label :kind %>
        <%= addresses_form.text_field :kind %>

        <%= addresses_form.label :street %>
        <%= addresses_form.text_field :street %>
        ...
      </li>
    <% end %>
  </ul>
<% end %>
```


Quando uma associação aceita atributos aninhados, `fields_for` renderiza seu bloco uma vez para cada elemento da associação. Em particular, se uma pessoa não tiver endereços, não renderiza nada. Um padrão comum é o controlador criar um ou mais filhos vazios para que pelo menos um conjunto de campos seja mostrado ao usuário. O exemplo abaixo resultaria em 2 conjuntos de campos de endereço sendo renderizados no formulário de nova pessoa.

```ruby
def new
  @person = Person.new
  2.times { @person.addresses.build }
end
```

O `fields_for` gera um construtor de formulários. O nome dos parâmetros será o que o `accepts_nested_attributes_for` espera. Por exemplo, ao criar um usuário com 2 endereços, os parâmetros enviados seriam assim:

```ruby
{
  'person' => {
    'name' => 'John Doe',
    'addresses_attributes' => {
      '0' => {
        'kind' => 'Home',
        'street' => '221b Baker Street'
      },
      '1' => {
        'kind' => 'Office',
        'street' => '31 Spooner Street'
      }
    }
  }
}
```

Os valores reais das chaves no hash `:addresses_attributes` não são importantes; no entanto, eles precisam ser strings de inteiros e diferentes para cada endereço.

Se o objeto associado já estiver salvo, `fields_for` gera automaticamente um campo oculto com o `id` do registro salvo. Você pode desabilitar isso passando `include_id: false` para `fields_for`.

### O Controlador

Como de costume, você precisa
[declarar os parâmetros permitidos](action_controller_overview.html#strong-parameters) no
controlador antes de passá-los para o modelo:

```ruby
def create
  @person = Person.new(person_params)
  # ...
end

private
  def person_params
    params.require(:person).permit(:name, addresses_attributes: [:id, :kind, :street])
  end
```

### Removendo Objetos

Você pode permitir que os usuários excluam objetos associados passando `allow_destroy: true` para `accepts_nested_attributes_for`

```ruby
class Person < ApplicationRecord
  has_many :addresses
  accepts_nested_attributes_for :addresses, allow_destroy: true
end
```

Se o hash de atributos para um objeto contiver a chave `_destroy` com um valor que
avalia para `true` (por exemplo, 1, '1', true ou 'true'), então o objeto será destruído.
Este formulário permite que os usuários removam endereços:

```erb
<%= form_with model: @person do |form| %>
  Endereços:
  <ul>
    <%= form.fields_for :addresses do |addresses_form| %>
      <li>
        <%= addresses_form.check_box :_destroy %>
        <%= addresses_form.label :kind %>
        <%= addresses_form.text_field :kind %>
        ...
      </li>
    <% end %>
  </ul>
<% end %>
```

Não se esqueça de atualizar os parâmetros permitidos em seu controlador para incluir também
o campo `_destroy`:

```ruby
def person_params
  params.require(:person).
    permit(:name, addresses_attributes: [:id, :kind, :street, :_destroy])
end
```

### Prevenindo Registros Vazios

Muitas vezes é útil ignorar conjuntos de campos que o usuário não preencheu. Você pode controlar isso passando um bloco `:reject_if` para `accepts_nested_attributes_for`. Esse bloco será chamado com cada hash de atributos enviado pelo formulário. Se o bloco retornar `true`, o Active Record não criará um objeto associado para esse hash. O exemplo abaixo só tenta criar um endereço se o atributo `kind` estiver definido.

```ruby
class Person < ApplicationRecord
  has_many :addresses
  accepts_nested_attributes_for :addresses, reject_if: lambda { |attributes| attributes['kind'].blank? }
end
```

Como conveniência, você também pode passar o símbolo `:all_blank`, que criará um bloco que rejeitará registros em que todos os atributos estiverem em branco, excluindo qualquer valor para `_destroy`.

### Adicionando Campos Dinamicamente

Em vez de renderizar vários conjuntos de campos antecipadamente, você pode desejar adicioná-los apenas quando um usuário clicar em um botão "Adicionar novo endereço". O Rails não fornece suporte embutido para isso. Ao gerar novos conjuntos de campos, você deve garantir que a chave do array associado seja única - a data JavaScript atual (milissegundos desde a [época](https://en.wikipedia.org/wiki/Unix_time)) é uma escolha comum.

Usando Tag Helpers sem um Construtor de Formulários
----------------------------------------------------

Caso precise renderizar campos de formulário fora do contexto de um construtor de formulários, o Rails fornece assistentes de tags para elementos comuns de formulário. Por exemplo, [`check_box_tag`](https://api.rubyonrails.org/classes/ActionView/Helpers/FormTagHelper.html#method-i-check_box_tag):

```erb
<%= check_box_tag "accept" %>
```

Saída:

```html
<input type="checkbox" name="accept" id="accept" value="1" />
```

Geralmente, esses assistentes têm o mesmo nome que seus equivalentes construtores de formulários, mas com um sufixo `_tag`. Para uma lista completa, consulte a documentação da API [`FormTagHelper`](https://api.rubyonrails.org/classes/ActionView/Helpers/FormTagHelper.html).
Usando `form_tag` e `form_for`
-------------------------------

Antes da introdução do `form_with` no Rails 5.1, sua funcionalidade era dividida entre [`form_tag`](https://api.rubyonrails.org/v5.2/classes/ActionView/Helpers/FormTagHelper.html#method-i-form_tag) e [`form_for`](https://api.rubyonrails.org/v5.2/classes/ActionView/Helpers/FormHelper.html#method-i-form_for). Ambos estão agora em soft-deprecated. A documentação sobre o uso deles pode ser encontrada em [versões mais antigas deste guia](https://guides.rubyonrails.org/v5.2/form_helpers.html).
[`fields_for`]: https://api.rubyonrails.org/classes/ActionView/Helpers/FormBuilder.html#method-i-fields_for
[formmethod]: https://developer.mozilla.org/en-US/docs/Web/HTML/Element/button#attr-formmethod
[button-name]: https://developer.mozilla.org/en-US/docs/Web/HTML/Element/button#attr-name
[button-value]: https://developer.mozilla.org/en-US/docs/Web/HTML/Element/button#attr-value
