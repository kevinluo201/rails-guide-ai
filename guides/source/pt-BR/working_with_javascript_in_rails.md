**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: c1e56036aa9fd68276daeec5a9407096
Trabalhando com JavaScript no Rails
===================================

Este guia aborda as opções para integrar funcionalidades JavaScript em sua aplicação Rails,
incluindo as opções que você tem para usar pacotes JavaScript externos e como usar o Turbo com
Rails.

Após ler este guia, você saberá:

* Como usar o Rails sem a necessidade de um Node.js, Yarn ou um empacotador JavaScript.
* Como criar uma nova aplicação Rails usando import maps, esbuild, rollup ou webpack para empacotar
  seu JavaScript.
* O que é o Turbo e como usá-lo.
* Como usar os auxiliares HTML do Turbo fornecidos pelo Rails.

--------------------------------------------------------------------------------

Import Maps
-----------

[Import maps](https://github.com/rails/importmap-rails) permitem que você importe módulos JavaScript usando
nomes lógicos que mapeiam para arquivos versionados diretamente do navegador. Import maps são o padrão
a partir do Rails 7, permitindo que qualquer pessoa construa aplicações JavaScript modernas usando a maioria dos pacotes NPM
sem a necessidade de transpilação ou empacotamento.

Aplicações que usam import maps não precisam do [Node.js](https://nodejs.org/en/) ou
[Yarn](https://yarnpkg.com/) para funcionar. Se você planeja usar o Rails com `importmap-rails` para
gerenciar suas dependências JavaScript, não é necessário instalar o Node.js ou o Yarn.

Ao usar import maps, nenhum processo de compilação separado é necessário, basta iniciar seu servidor com
`bin/rails server` e você está pronto para começar.

### Instalando importmap-rails

O Importmap para Rails é automaticamente incluído no Rails 7+ para novas aplicações, mas você também pode instalá-lo manualmente em aplicações existentes:

```bash
$ bin/bundle add importmap-rails
```

Execute a tarefa de instalação:

```bash
$ bin/rails importmap:install
```

### Adicionando Pacotes NPM com importmap-rails

Para adicionar novos pacotes à sua aplicação com import map, execute o comando `bin/importmap pin`
do seu terminal:

```bash
$ bin/importmap pin react react-dom
```

Em seguida, importe o pacote em `application.js` como de costume:

```javascript
import React from "react"
import ReactDOM from "react-dom"
```

Adicionando Pacotes NPM com Empacotadores JavaScript
--------

Import maps são o padrão para novas aplicações Rails, mas se você preferir o empacotamento tradicional de JavaScript,
você pode criar novas aplicações Rails com sua escolha de
[esbuild](https://esbuild.github.io/), [webpack](https://webpack.js.org/) ou
[rollup.js](https://rollupjs.org/guide/en/).

Para usar um empacotador em vez de import maps em uma nova aplicação Rails, passe a opção `—javascript` ou `-j`
para `rails new`:

```bash
$ rails new my_new_app --javascript=webpack
OU
$ rails new my_new_app -j webpack
```

Essas opções de empacotamento vêm com uma configuração simples e integração com o pipeline de assets através da gem [jsbundling-rails](https://github.com/rails/jsbundling-rails).

Ao usar uma opção de empacotamento, use `bin/dev` para iniciar o servidor Rails e compilar o JavaScript para
desenvolvimento.

### Instalando o Node.js e o Yarn

Se você estiver usando um empacotador JavaScript em sua aplicação Rails, o Node.js e o Yarn devem ser
instalados.

Encontre as instruções de instalação no site do [Node.js](https://nodejs.org/en/download/) e
verifique se ele está instalado corretamente com o seguinte comando:

```bash
$ node --version
```

A versão do seu runtime Node.js deve ser exibida. Verifique se é maior que `8.16.0`.

Para instalar o Yarn, siga as instruções de instalação no
[site do Yarn](https://classic.yarnpkg.com/en/docs/install). Executar este comando deve exibir
a versão do Yarn:

```bash
$ yarn --version
```

Se ele exibir algo como `1.22.0`, o Yarn foi instalado corretamente.

Escolhendo Entre Import Maps e um Empacotador JavaScript
-------------------------------------------------------

Ao criar uma nova aplicação Rails, você precisará escolher entre import maps e uma
solução de empacotamento JavaScript. Cada aplicação tem requisitos diferentes, e você deve
considerar seus requisitos cuidadosamente antes de escolher uma opção de JavaScript, pois migrar de uma
opção para outra pode ser demorado para aplicações grandes e complexas.

Import maps são a opção padrão porque a equipe do Rails acredita no potencial dos import maps para
reduzir a complexidade, melhorar a experiência do desenvolvedor e proporcionar ganhos de desempenho.

Para muitas aplicações, especialmente aquelas que dependem principalmente do stack [Hotwire](https://hotwired.dev/)
para suas necessidades de JavaScript, import maps serão a opção certa a longo prazo. Você
pode ler mais sobre o raciocínio por trás de tornar os import maps o padrão no Rails 7
[aqui](https://world.hey.com/dhh/rails-7-will-have-three-great-answers-to-javascript-in-2021-8d68191b).

Outras aplicações ainda podem precisar de um empacotador JavaScript tradicional. Requisitos que indicam
que você deve escolher um empacotador tradicional incluem:

* Seu código requer uma etapa de transpilação, como JSX ou TypeScript.
* Se você precisa usar bibliotecas JavaScript que incluem CSS ou dependem de
  [loaders do Webpack](https://webpack.js.org/loaders/).
* Se você tem certeza absoluta de que precisa de
  [tree-shaking](https://webpack.js.org/guides/tree-shaking/).
* Se você instalar o Bootstrap, Bulma, PostCSS ou Dart CSS através da gem [cssbundling-rails](https://github.com/rails/cssbundling-rails). Todas as opções fornecidas por esta gem, exceto Tailwind e Sass, instalarão automaticamente o `esbuild` para você se você não especificar uma opção diferente em `rails new`.
Turbo
-----

Se você escolher mapas de importação ou um empacotador tradicional, o Rails vem com o [Turbo](https://turbo.hotwired.dev/) para acelerar sua aplicação, reduzindo drasticamente a quantidade de JavaScript que você precisará escrever.

O Turbo permite que seu servidor entregue HTML diretamente como uma alternativa aos frameworks front-end predominantes, que reduzem o lado do servidor de sua aplicação Rails a pouco mais do que uma API JSON.

### Turbo Drive

O [Turbo Drive](https://turbo.hotwired.dev/handbook/drive) acelera o carregamento de páginas evitando a destruição e reconstrução completa da página a cada solicitação de navegação. O Turbo Drive é uma melhoria e substituição do Turbolinks.

### Turbo Frames

Os [Turbo Frames](https://turbo.hotwired.dev/handbook/frames) permitem que partes predefinidas de uma página sejam atualizadas sob demanda, sem afetar o restante do conteúdo da página.

Você pode usar o Turbo Frames para criar edição no local sem nenhum JavaScript personalizado, carregar conteúdo preguiçoso e criar interfaces com abas renderizadas no servidor com facilidade.

O Rails fornece ajudantes HTML para simplificar o uso do Turbo Frames por meio do gem [turbo-rails](https://github.com/hotwired/turbo-rails).

Usando esse gem, você pode adicionar um Turbo Frame à sua aplicação com o ajudante `turbo_frame_tag`, assim:

```erb
<%= turbo_frame_tag dom_id(post) do %>
  <div>
     <%= link_to post.title, post_path(post) %>
  </div>
<% end %>
```

### Turbo Streams

Os [Turbo Streams](https://turbo.hotwired.dev/handbook/streams) entregam alterações na página como fragmentos de HTML envoltos em elementos `<turbo-stream>` autoexecutáveis. Os Turbo Streams permitem que você transmita alterações feitas por outros usuários por meio de WebSockets e atualize partes de uma página após o envio de um formulário sem exigir uma carga completa da página.

O Rails fornece ajudantes HTML e do lado do servidor para simplificar o uso do Turbo Streams por meio do gem [turbo-rails](https://github.com/hotwired/turbo-rails).

Usando esse gem, você pode renderizar Turbo Streams a partir de uma ação do controlador:

```ruby
def create
  @post = Post.new(post_params)

  respond_to do |format|
    if @post.save
      format.turbo_stream
    else
      format.html { render :new, status: :unprocessable_entity }
    end
  end
end
```

O Rails automaticamente procurará por um arquivo de visualização `.turbo_stream.erb` e renderizará essa visualização quando encontrado.

As respostas do Turbo Stream também podem ser renderizadas inline na ação do controlador:

```ruby
def create
  @post = Post.new(post_params)

  respond_to do |format|
    if @post.save
      format.turbo_stream { render turbo_stream: turbo_stream.prepend('posts', partial: 'post') }
    else
      format.html { render :new, status: :unprocessable_entity }
    end
  end
end
```

Por fim, os Turbo Streams podem ser iniciados a partir de um modelo ou de um trabalho em segundo plano usando ajudantes integrados. Essas transmissões podem ser usadas para atualizar o conteúdo por meio de uma conexão WebSocket para todos os usuários, mantendo o conteúdo da página atualizado e dando vida à sua aplicação.

Para transmitir um Turbo Stream a partir de um modelo, combine um retorno de chamada do modelo assim:

```ruby
class Post < ApplicationRecord
  after_create_commit { broadcast_append_to('posts') }
end
```

Com uma conexão WebSocket configurada na página que deve receber as atualizações assim:

```erb
<%= turbo_stream_from "posts" %>
```

Substituições para a Funcionalidade Rails/UJS
--------------------------------------------

O Rails 6 foi lançado com uma ferramenta chamada UJS (JavaScript Não Intrusivo). O UJS permite que os desenvolvedores substituam o método de solicitação HTTP das tags `<a>`, adicionem diálogos de confirmação antes de executar uma ação e muito mais. O UJS era o padrão antes do Rails 7, mas agora é recomendado usar o Turbo.

### Método

Clicar em links sempre resulta em uma solicitação HTTP GET. Se sua aplicação é [RESTful](https://en.wikipedia.org/wiki/Representational_State_Transfer), alguns links são, na verdade, ações que alteram dados no servidor e devem ser executados com solicitações não-GET. O atributo `data-turbo-method` permite marcar esses links com um método explícito, como "post", "put" ou "delete".

O Turbo analisará as tags `<a>` em sua aplicação em busca do atributo de dados `turbo-method` e usará o método especificado quando presente, substituindo a ação GET padrão.

Por exemplo:

```erb
<%= link_to "Excluir post", post_path(post), data: { turbo_method: "delete" } %>
```

Isso gera:

```html
<a data-turbo-method="delete" href="...">Excluir post</a>
```

Uma alternativa para alterar o método de um link com `data-turbo-method` é usar o ajudante `button_to` do Rails. Por motivos de acessibilidade, botões e formulários reais são preferíveis para qualquer ação não-GET.

### Confirmações

Você pode solicitar uma confirmação extra do usuário adicionando um atributo `data-turbo-confirm` em links e formulários. Ao clicar no link ou enviar o formulário, o usuário verá uma caixa de diálogo JavaScript `confirm()` contendo o texto do atributo. Se o usuário optar por cancelar, a ação não será executada.

Por exemplo, com o ajudante `link_to`:

```erb
<%= link_to "Excluir post", post_path(post), data: { turbo_method: "delete", turbo_confirm: "Tem certeza?" } %>
```

Isso gera:

```html
<a href="..." data-turbo-confirm="Tem certeza?" data-turbo-method="delete">Excluir post</a>
```
Quando o usuário clicar no link "Excluir postagem", será exibida uma caixa de diálogo de confirmação "Tem certeza?".

O atributo também pode ser usado com o auxiliar `button_to`, no entanto, ele deve ser adicionado ao formulário que o auxiliar `button_to` renderiza internamente:

```erb
<%= button_to "Excluir postagem", post, method: :delete, form: { data: { turbo_confirm: "Tem certeza?" } } %>
```

### Requisições Ajax

Ao fazer requisições não-GET a partir do JavaScript, o cabeçalho `X-CSRF-Token` é necessário. Sem esse cabeçalho, as requisições não serão aceitas pelo Rails.

NOTA: Esse token é necessário pelo Rails para prevenir ataques de falsificação de solicitação entre sites (CSRF). Leia mais no [guia de segurança](security.html#cross-site-request-forgery-csrf).

O [Rails Request.JS](https://github.com/rails/request.js) encapsula a lógica de adicionar os cabeçalhos de requisição necessários pelo Rails. Basta importar a classe `FetchRequest` do pacote e instanciá-la passando o método de requisição, URL e opções, em seguida, chamar `await request.perform()` e fazer o que for necessário com a resposta.

Por exemplo:

```javascript
import { FetchRequest } from '@rails/request.js'

....

async myMethod () {
  const request = new FetchRequest('post', 'localhost:3000/posts', {
    body: JSON.stringify({ name: 'Request.JS' })
  })
  const response = await request.perform()
  if (response.ok) {
    const body = await response.text
  }
}
```

Ao usar outra biblioteca para fazer chamadas Ajax, é necessário adicionar o token de segurança como um cabeçalho padrão. Para obter o token, verifique a tag `<meta name='csrf-token' content='THE-TOKEN'>` impressa por [`csrf_meta_tags`][] na visualização da sua aplicação. Você pode fazer algo como:

```javascript
document.head.querySelector("meta[name=csrf-token]")?.content
```
[`csrf_meta_tags`]: https://api.rubyonrails.org/classes/ActionView/Helpers/CsrfHelper.html#method-i-csrf_meta_tags
