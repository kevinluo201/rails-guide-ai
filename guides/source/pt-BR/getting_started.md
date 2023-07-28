**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 2cf37358fedc8b51ed3ab7f408ecfc76
Começando com o Rails
==========================

Este guia aborda como começar e executar o Ruby on Rails.

Após ler este guia, você saberá:

* Como instalar o Rails, criar um novo aplicativo Rails e conectar seu
  aplicativo a um banco de dados.
* O layout geral de um aplicativo Rails.
* Os princípios básicos do MVC (Modelo, Visão, Controlador) e do design RESTful.
* Como gerar rapidamente as peças iniciais de um aplicativo Rails.

--------------------------------------------------------------------------------

Suposições do Guia
-----------------

Este guia é projetado para iniciantes que desejam começar a criar um aplicativo Rails
do zero. Ele não assume que você tenha qualquer experiência prévia
com o Rails.

Rails é um framework de desenvolvimento de aplicativos web que roda na linguagem de programação Ruby.
Se você não tem experiência prévia com Ruby, encontrará uma curva de aprendizado muito íngreme
mergulhando diretamente no Rails. Existem várias listas selecionadas de recursos online
para aprender Ruby:

* [Site oficial da linguagem de programação Ruby](https://www.ruby-lang.org/en/documentation/)
* [Lista de Livros Gratuitos de Programação](https://github.com/EbookFoundation/free-programming-books/blob/master/books/free-programming-books-langs.md#ruby)

Esteja ciente de que alguns recursos, embora ainda excelentes, cobrem versões mais antigas de
Ruby e podem não incluir algumas sintaxes que você verá no desenvolvimento do dia a dia
com o Rails.

O que é o Rails?
--------------

Rails é um framework de desenvolvimento de aplicativos web escrito na linguagem de programação Ruby.
Ele foi projetado para facilitar a programação de aplicativos web, fazendo suposições
sobre o que cada desenvolvedor precisa para começar. Ele permite que você escreva menos
código enquanto realiza mais do que muitas outras linguagens e frameworks.
Desenvolvedores experientes do Rails também relatam que ele torna o desenvolvimento de aplicativos web
mais divertido.

Rails é um software opinativo. Ele assume que existe uma "melhor"
maneira de fazer as coisas e é projetado para encorajar essa maneira - e em alguns casos
desencorajar alternativas. Se você aprender "O Jeito Rails", provavelmente descobrirá um
aumento tremendo na produtividade. Se você persistir em trazer hábitos antigos de
outras linguagens para o desenvolvimento do Rails e tentar usar padrões que
aprendeu em outros lugares, pode ter uma experiência menos feliz.

A filosofia do Rails inclui dois princípios orientadores principais:

* **Não se Repita:** DRY é um princípio de desenvolvimento de software que
  afirma que "Cada pedaço de conhecimento deve ter uma única, inequívoca, autoritativa
  representação dentro de um sistema". Ao não escrever as mesmas informações repetidamente,
  nosso código é mais fácil de manter, mais extensível e menos propenso a erros.
* **Convenção sobre Configuração:** O Rails tem opiniões sobre a melhor maneira de fazer muitas
  coisas em um aplicativo web e usa essas convenções como padrão, em vez de
  exigir que você especifique minúcias por meio de arquivos de configuração intermináveis.

Criando um Novo Projeto Rails
----------------------------

A melhor maneira de ler este guia é segui-lo passo a passo. Todos os passos são
essenciais para executar este exemplo de aplicativo e nenhum código ou etapa adicional é
necessário.

Ao seguir este guia, você criará um projeto Rails chamado
`blog`, um weblog (diário online) muito simples. Antes de começar a construir o aplicativo,
você precisa garantir que tenha o Rails instalado.

NOTA: Os exemplos abaixo usam o símbolo `$` para representar o prompt do terminal em um sistema operacional semelhante ao UNIX,
embora possa ter sido personalizado para aparecer de forma diferente. Se você estiver usando o Windows,
seu prompt será parecido com `C:\source_code>`.

### Instalando o Rails

Antes de instalar o Rails, verifique se o seu sistema possui os
pré-requisitos corretos instalados. Estes incluem:

* Ruby
* SQLite3

#### Instalando o Ruby

Abra um prompt de linha de comando. No macOS, abra o Terminal.app; no Windows, escolha
"Executar" no menu Iniciar e digite `cmd.exe`. Quaisquer comandos precedidos por um
sinal de dólar `$` devem ser executados na linha de comando. Verifique se você tem uma
versão atual do Ruby instalada:

```bash
$ ruby --version
ruby 2.7.0
```

O Rails requer a versão 2.7.0 ou posterior do Ruby. É preferível usar a versão mais recente do Ruby.
Se o número da versão retornada for menor que esse número (como 2.3.7 ou 1.8.7),
você precisará instalar uma nova cópia do Ruby.

Para instalar o Rails no Windows, você precisará primeiro instalar o [Ruby Installer](https://rubyinstaller.org/).

Para obter mais métodos de instalação para a maioria dos sistemas operacionais, dê uma olhada em
[ruby-lang.org](https://www.ruby-lang.org/en/documentation/installation/).

#### Instalando o SQLite3

Você também precisará de uma instalação do banco de dados SQLite3.
Muitos sistemas operacionais semelhantes ao UNIX populares já possuem uma versão aceitável do SQLite3.
Outros podem encontrar instruções de instalação no site do [SQLite3](https://www.sqlite.org).
Verifique se está corretamente instalado e no seu `PATH` de carregamento:

```bash
$ sqlite3 --version
```

O programa deve exibir sua versão.

#### Instalando o Rails

Para instalar o Rails, use o comando `gem install` fornecido pelo RubyGems:

```bash
$ gem install rails
```

Para verificar se tudo foi instalado corretamente, você deve ser capaz de
executar o seguinte em um novo terminal:

```bash
$ rails --version
```

Se ele exibir algo como "Rails 7.0.0", você está pronto para continuar.

### Criando a Aplicação Blog

O Rails vem com uma série de scripts chamados geradores que são projetados para facilitar sua vida de desenvolvimento, criando tudo o que é necessário para começar a trabalhar em uma tarefa específica. Um deles é o gerador de nova aplicação, que fornecerá a base de uma nova aplicação Rails para que você não precise escrevê-la.

Para usar este gerador, abra um terminal, navegue até um diretório onde você tenha permissão para criar arquivos e execute:

```bash
$ rails new blog
```

Isso criará uma aplicação Rails chamada Blog em um diretório `blog` e
instalará as dependências de gemas que já estão mencionadas no `Gemfile` usando
`bundle install`.

DICA: Você pode ver todas as opções de linha de comando que o gerador de aplicação Rails aceita executando `rails new --help`.

Depois de criar a aplicação blog, mude para a pasta dela:

```bash
$ cd blog
```

O diretório `blog` terá vários arquivos e pastas gerados que compõem a estrutura de uma aplicação Rails. A maior parte do trabalho neste tutorial acontecerá na pasta `app`, mas aqui está uma visão geral básica da função de cada um dos arquivos e pastas que o Rails cria por padrão:

| Arquivo/Pasta | Propósito |
| ----------- | ------- |
|app/|Contém os controladores, modelos, visualizações, ajudantes, correios, canais, trabalhos e ativos da sua aplicação. Você vai se concentrar nesta pasta pelo resto deste guia.|
|bin/|Contém o script `rails` que inicia sua aplicação e pode conter outros scripts que você usa para configurar, atualizar, implantar ou executar sua aplicação.|
|config/|Contém a configuração das rotas, banco de dados e mais da sua aplicação. Isso é abordado em mais detalhes em [Configurando Aplicações Rails](configuring.html).|
|config.ru|Configuração do Rack para servidores baseados em Rack usados para iniciar a aplicação. Para mais informações sobre o Rack, consulte o [site do Rack](https://rack.github.io/).|
|db/|Contém o esquema do banco de dados atual, bem como as migrações do banco de dados.|
|Gemfile<br>Gemfile.lock|Esses arquivos permitem que você especifique quais dependências de gemas são necessárias para sua aplicação Rails. Esses arquivos são usados pelo gem Bundler. Para mais informações sobre o Bundler, consulte o [site do Bundler](https://bundler.io).|
|lib/|Módulos estendidos para sua aplicação.|
|log/|Arquivos de log da aplicação.|
|public/|Contém arquivos estáticos e ativos compilados. Quando sua aplicação está em execução, este diretório será exposto como está.|
|Rakefile|Este arquivo localiza e carrega tarefas que podem ser executadas a partir da linha de comando. As definições de tarefas são definidas em todos os componentes do Rails. Em vez de alterar o `Rakefile`, você deve adicionar suas próprias tarefas adicionando arquivos ao diretório `lib/tasks` da sua aplicação.|
|README.md|Este é um manual de instruções breve para sua aplicação. Você deve editar este arquivo para informar aos outros o que sua aplicação faz, como configurá-la, e assim por diante.|
|storage/|Arquivos de Active Storage para o serviço de disco. Isso é abordado em [Visão Geral do Active Storage](active_storage_overview.html).|
|test/|Testes unitários, fixtures e outros aparatos de teste. Isso é abordado em [Testando Aplicações Rails](testing.html).|
|tmp/|Arquivos temporários (como cache e arquivos pid).|
|vendor/|Um lugar para todo o código de terceiros. Em uma aplicação Rails típica, isso inclui gemas vendidas.|
|.gitattributes|Este arquivo define metadados para caminhos específicos em um repositório git. Esses metadados podem ser usados pelo git e outras ferramentas para aprimorar seu comportamento. Consulte a [documentação do gitattributes](https://git-scm.com/docs/gitattributes) para obter mais informações.|
|.gitignore|Este arquivo informa ao git quais arquivos (ou padrões) ele deve ignorar. Consulte [GitHub - Ignorando arquivos](https://help.github.com/articles/ignoring-files) para obter mais informações sobre a exclusão de arquivos.|
|.ruby-version|Este arquivo contém a versão padrão do Ruby.|

Olá, Rails!
-------------

Para começar, vamos colocar algum texto na tela rapidamente. Para fazer isso, você precisa
iniciar o servidor da sua aplicação Rails.

### Iniciando o Servidor Web

Na verdade, você já tem uma aplicação Rails funcional. Para vê-la, você precisa
iniciar um servidor web em sua máquina de desenvolvimento. Você pode fazer isso executando o
seguinte comando no diretório `blog`:

```bash
$ bin/rails server
```
DICA: Se você estiver usando o Windows, você precisa passar os scripts da pasta `bin` diretamente para o interpretador Ruby, por exemplo, `ruby bin\rails server`.

DICA: A compressão de ativos JavaScript requer que você tenha um tempo de execução JavaScript disponível em seu sistema; na ausência de um tempo de execução, você verá um erro `execjs` durante a compressão de ativos. Geralmente, macOS e Windows já vêm com um tempo de execução JavaScript instalado. `therubyrhino` é o tempo de execução recomendado para usuários do JRuby e é adicionado por padrão ao `Gemfile` em aplicativos gerados com o JRuby. Você pode investigar todos os tempos de execução suportados em [ExecJS](https://github.com/rails/execjs#readme).

Isso iniciará o Puma, um servidor web distribuído com o Rails por padrão. Para ver sua aplicação em ação, abra uma janela do navegador e navegue até <http://localhost:3000>. Você deverá ver a página de informações padrão do Rails:

![Captura de tela da página inicial do Rails](images/getting_started/rails_welcome.png)

Quando você quiser parar o servidor web, pressione Ctrl+C na janela do terminal onde ele está sendo executado. No ambiente de desenvolvimento, o Rails geralmente não requer que você reinicie o servidor; as alterações que você fizer nos arquivos serão automaticamente capturadas pelo servidor.

A página inicial do Rails é o "teste de fumaça" para um novo aplicativo Rails: ela garante que você tenha configurado corretamente seu software para servir uma página.

### Diga "Olá", Rails

Para fazer o Rails dizer "Olá", você precisa criar, no mínimo, uma *rota*, um *controlador* com uma *ação* e uma *visão*. Uma rota mapeia uma solicitação para uma ação do controlador. Uma ação do controlador executa o trabalho necessário para lidar com a solicitação e prepara quaisquer dados para a visão. Uma visão exibe os dados em um formato desejado.

Em termos de implementação: Rotas são regras escritas em uma [DSL (Linguagem Específica de Domínio)](https://en.wikipedia.org/wiki/Domain-specific_language) Ruby. Controladores são classes Ruby, e seus métodos públicos são ações. E as visões são modelos, geralmente escritos em uma mistura de HTML e Ruby.

Vamos começar adicionando uma rota ao nosso arquivo de rotas, `config/routes.rb`, no início do bloco `Rails.application.routes.draw`:

```ruby
Rails.application.routes.draw do
  get "/articles", to: "articles#index"

  # Para obter detalhes sobre a DSL disponível neste arquivo, consulte https://guides.rubyonrails.org/routing.html
end
```

A rota acima declara que as solicitações `GET /articles` são mapeadas para a ação `index` do `ArticlesController`.

Para criar o `ArticlesController` e sua ação `index`, executaremos o gerador de controladores (com a opção `--skip-routes` porque já temos uma rota apropriada):

```bash
$ bin/rails generate controller Articles index --skip-routes
```

O Rails criará vários arquivos para você:

```
create  app/controllers/articles_controller.rb
invoke  erb
create    app/views/articles
create    app/views/articles/index.html.erb
invoke  test_unit
create    test/controllers/articles_controller_test.rb
invoke  helper
create    app/helpers/articles_helper.rb
invoke    test_unit
```

O mais importante deles é o arquivo do controlador, `app/controllers/articles_controller.rb`. Vamos dar uma olhada nele:

```ruby
class ArticlesController < ApplicationController
  def index
  end
end
```

A ação `index` está vazia. Quando uma ação não renderiza explicitamente uma visão (ou de outra forma aciona uma resposta HTTP), o Rails renderizará automaticamente uma visão que corresponda ao nome do controlador e da ação. Convenção sobre Configuração! As visões estão localizadas no diretório `app/views`. Portanto, a ação `index` renderizará `app/views/articles/index.html.erb` por padrão.

Vamos abrir `app/views/articles/index.html.erb` e substituir seu conteúdo por:

```html
<h1>Olá, Rails!</h1>
```

Se você parou anteriormente o servidor web para executar o gerador de controladores, reinicie-o com `bin/rails server`. Agora visite <http://localhost:3000/articles> e veja nosso texto sendo exibido!

### Definindo a Página Inicial do Aplicativo

No momento, <http://localhost:3000> ainda exibe uma página com o logotipo do Ruby on Rails. Vamos exibir nosso texto "Olá, Rails!" em <http://localhost:3000> também. Para fazer isso, adicionaremos uma rota que mapeia o *caminho raiz* de nosso aplicativo para o controlador e a ação apropriados.

Vamos abrir `config/routes.rb` e adicionar a seguinte rota `root` no início do bloco `Rails.application.routes.draw`:

```ruby
Rails.application.routes.draw do
  root "articles#index"

  get "/articles", to: "articles#index"
end
```

Agora podemos ver nosso texto "Olá, Rails!" quando visitamos <http://localhost:3000>, confirmando que a rota `root` também está mapeada para a ação `index` do `ArticlesController`.

DICA: Para saber mais sobre roteamento, consulte [Roteamento do Rails de fora para dentro](routing.html).

Carregamento Automático
-----------------------

Aplicações Rails **não** usam `require` para carregar código do aplicativo.

Você pode ter percebido que `ArticlesController` herda de `ApplicationController`, mas `app/controllers/articles_controller.rb` não tem algo como

```ruby
require "application_controller" # NÃO FAÇA ISSO.
```

Classes e módulos do aplicativo estão disponíveis em todos os lugares, você não precisa e **não deve** carregar nada em `app` com `require`. Essa funcionalidade é chamada de _carregamento automático_, e você pode aprender mais sobre ela em [_Carregamento Automático e Recarregamento de Constantes_](autoloading_and_reloading_constants.html).
Você só precisa de chamadas `require` para dois casos de uso:

* Para carregar arquivos no diretório `lib`.
* Para carregar dependências de gemas que têm `require: false` no `Gemfile`.

MVC e Você
-----------

Até agora, discutimos rotas, controladores, ações e visualizações. Todos esses
são elementos típicos de uma aplicação web que segue o padrão [MVC (Model-View-Controller)](
https://en.wikipedia.org/wiki/Model%E2%80%93view%E2%80%93controller). MVC é um padrão de design que divide as responsabilidades de uma aplicação
para torná-la mais fácil de entender. O Rails segue esse padrão de design por convenção.

Como temos um controlador e uma visualização para trabalhar, vamos gerar a próxima
parte: um modelo.

### Gerando um Modelo

Um *modelo* é uma classe Ruby que é usada para representar dados. Além disso, os modelos
podem interagir com o banco de dados da aplicação por meio de um recurso do Rails chamado
*Active Record*.

Para definir um modelo, usaremos o gerador de modelos:

```bash
$ bin/rails generate model Article title:string body:text
```

NOTA: Os nomes dos modelos são **singulares**, porque um modelo instanciado representa um
único registro de dados. Para ajudar a lembrar dessa convenção, pense em como você chamaria o construtor do modelo: queremos escrever `Article.new(...)`, **não**
`Articles.new(...)`.

Isso criará vários arquivos:

```
invoke  active_record
create    db/migrate/<timestamp>_create_articles.rb
create    app/models/article.rb
invoke    test_unit
create      test/models/article_test.rb
create      test/fixtures/articles.yml
```

Os dois arquivos em que vamos nos concentrar são o arquivo de migração
(`db/migrate/<timestamp>_create_articles.rb`) e o arquivo do modelo
(`app/models/article.rb`).

### Migrações de Banco de Dados

*Migrações* são usadas para alterar a estrutura do banco de dados de uma aplicação. Em
aplicações Rails, as migrações são escritas em Ruby para que possam ser
independentes do banco de dados.

Vamos dar uma olhada no conteúdo do nosso novo arquivo de migração:

```ruby
class CreateArticles < ActiveRecord::Migration[7.0]
  def change
    create_table :articles do |t|
      t.string :title
      t.text :body

      t.timestamps
    end
  end
end
```

A chamada para `create_table` especifica como a tabela `articles` deve ser
construída. Por padrão, o método `create_table` adiciona uma coluna `id` como
chave primária autoincrementada. Portanto, o primeiro registro na tabela terá um
`id` de 1, o próximo registro terá um `id` de 2 e assim por diante.

Dentro do bloco para `create_table`, duas colunas são definidas: `title` e
`body`. Elas foram adicionadas pelo gerador porque as incluímos em nosso
comando de geração (`bin/rails generate model Article title:string body:text`).

Na última linha do bloco, há uma chamada para `t.timestamps`. Esse método define
duas colunas adicionais chamadas `created_at` e `updated_at`. Como veremos,
o Rails irá gerenciar essas colunas para nós, definindo os valores quando criamos ou atualizamos um
objeto de modelo.

Vamos executar nossa migração com o seguinte comando:

```bash
$ bin/rails db:migrate
```

O comando exibirá uma saída indicando que a tabela foi criada:

```
==  CreateArticles: migrating ===================================
-- create_table(:articles)
   -> 0.0018s
==  CreateArticles: migrated (0.0018s) ==========================
```

DICA: Para saber mais sobre migrações, consulte [Migrações do Active Record](
active_record_migrations.html).

Agora podemos interagir com a tabela usando nosso modelo.

### Usando um Modelo para Interagir com o Banco de Dados

Para brincar um pouco com nosso modelo, vamos usar um recurso do Rails chamado
*console*. O console é um ambiente de codificação interativo assim como o `irb`, mas
ele também carrega automaticamente o Rails e o código de nossa aplicação.

Vamos iniciar o console com o seguinte comando:

```bash
$ bin/rails console
```

Você verá um prompt `irb` como este:

```irb
Carregando ambiente de desenvolvimento (Rails 7.0.0)
irb(main):001:0>
```

Neste prompt, podemos inicializar um novo objeto `Article`:

```irb
irb> article = Article.new(title: "Hello Rails", body: "Estou no Rails!")
```

É importante observar que apenas *inicializamos* este objeto. Este objeto
não foi salvo no banco de dados. Ele está disponível apenas no console no
momento. Para salvar o objeto no banco de dados, devemos chamar [`save`](
https://api.rubyonrails.org/classes/ActiveRecord/Persistence.html#method-i-save):

```irb
irb> article.save
(0.1ms)  begin transaction
Article Create (0.4ms)  INSERT INTO "articles" ("title", "body", "created_at", "updated_at") VALUES (?, ?, ?, ?)  [["title", "Hello Rails"], ["body", "Estou no Rails!"], ["created_at", "2020-01-18 23:47:30.734416"], ["updated_at", "2020-01-18 23:47:30.734416"]]
(0.9ms)  commit transaction
=> true
```

A saída acima mostra uma consulta de banco de dados `INSERT INTO "articles" ...`. Isso
indica que o artigo foi inserido em nossa tabela. E se olharmos para o
objeto `article` novamente, veremos algo interessante aconteceu:

```irb
irb> article
=> #<Article id: 1, title: "Hello Rails", body: "Estou no Rails!", created_at: "2020-01-18 23:47:30", updated_at: "2020-01-18 23:47:30">
```
Os atributos `id`, `created_at` e `updated_at` do objeto agora estão definidos. O Rails fez isso por nós quando salvamos o objeto.

Quando queremos buscar este artigo no banco de dados, podemos chamar o método [`find`](
https://api.rubyonrails.org/classes/ActiveRecord/FinderMethods.html#method-i-find)
no modelo e passar o `id` como argumento:

```irb
irb> Article.find(1)
=> #<Article id: 1, title: "Hello Rails", body: "I am on Rails!", created_at: "2020-01-18 23:47:30", updated_at: "2020-01-18 23:47:30">
```

E quando queremos buscar todos os artigos do banco de dados, podemos chamar o método [`all`](
https://api.rubyonrails.org/classes/ActiveRecord/Scoping/Named/ClassMethods.html#method-i-all)
no modelo:

```irb
irb> Article.all
=> #<ActiveRecord::Relation [#<Article id: 1, title: "Hello Rails", body: "I am on Rails!", created_at: "2020-01-18 23:47:30", updated_at: "2020-01-18 23:47:30">]>
```

Este método retorna um objeto [`ActiveRecord::Relation`](
https://api.rubyonrails.org/classes/ActiveRecord/Relation.html), que pode ser pensado como um array super poderoso.

DICA: Para aprender mais sobre modelos, consulte [Active Record Basics](
active_record_basics.html) e [Active Record Query Interface](
active_record_querying.html).

Modelos são a peça final do quebra-cabeça do MVC. Em seguida, vamos conectar todas as peças juntas.

### Mostrando uma lista de artigos

Vamos voltar ao nosso controlador em `app/controllers/articles_controller.rb` e
alterar a ação `index` para buscar todos os artigos do banco de dados:

```ruby
class ArticlesController < ApplicationController
  def index
    @articles = Article.all
  end
end
```

As variáveis de instância do controlador podem ser acessadas pela visão. Isso significa que podemos fazer referência a `@articles` em `app/views/articles/index.html.erb`. Vamos abrir esse arquivo e substituir seu conteúdo por:

```html+erb
<h1>Artigos</h1>

<ul>
  <% @articles.each do |article| %>
    <li>
      <%= article.title %>
    </li>
  <% end %>
</ul>
```

O código acima é uma mistura de HTML e *ERB*. ERB é um sistema de templates que avalia código Ruby embutido em um documento. Aqui, podemos ver dois tipos de tags ERB: `<% %>` e `<%= %>`. A tag `<% %>` significa "avalie o código Ruby contido". A tag `<%= %>` significa "avalie o código Ruby contido e exiba o valor que ele retorna". Qualquer coisa que você possa escrever em um programa Ruby regular pode ser colocada dentro dessas tags ERB, embora seja geralmente melhor manter o conteúdo das tags ERB curto, para melhor legibilidade.

Como não queremos exibir o valor retornado por `@articles.each`, envolvemos esse código em `<% %>`. Mas, como queremos exibir o valor retornado por `article.title` (para cada artigo), envolvemos esse código em `<%= %>`.

Podemos ver o resultado final visitando <http://localhost:3000>. (Lembre-se de que
`bin/rails server` deve estar em execução!) Aqui está o que acontece quando fazemos isso:

1. O navegador faz uma solicitação: `GET http://localhost:3000`.
2. Nosso aplicativo Rails recebe essa solicitação.
3. O roteador do Rails mapeia a rota raiz para a ação `index` de `ArticlesController`.
4. A ação `index` usa o modelo `Article` para buscar todos os artigos no banco de dados.
5. O Rails renderiza automaticamente a visão `app/views/articles/index.html.erb`.
6. O código ERB na visão é avaliado para gerar HTML.
7. O servidor envia uma resposta contendo o HTML de volta para o navegador.

Conectamos todas as peças do MVC e temos nossa primeira ação do controlador! Em seguida, passaremos para a segunda ação.

CRUDit Onde o CRUDit é Devido
----------------------------

Quase todas as aplicações web envolvem operações [CRUD (Create, Read, Update e Delete)](
https://en.wikipedia.org/wiki/Create,_read,_update,_and_delete). Você pode até descobrir que a maioria do trabalho que sua aplicação faz é CRUD. O Rails reconhece isso e fornece muitos recursos para ajudar a simplificar o código que faz o CRUD.

Vamos começar a explorar esses recursos adicionando mais funcionalidades à nossa aplicação.

### Mostrando um único artigo

Atualmente, temos uma visão que lista todos os artigos em nosso banco de dados. Vamos adicionar uma nova visão que mostra o título e o corpo de um único artigo.

Começamos adicionando uma nova rota que mapeia para uma nova ação do controlador (que adicionaremos em seguida). Abra `config/routes.rb` e insira a última rota mostrada aqui:

```ruby
Rails.application.routes.draw do
  root "articles#index"

  get "/articles", to: "articles#index"
  get "/articles/:id", to: "articles#show"
end
```

A nova rota é outra rota `get`, mas tem algo extra em seu caminho: `:id`. Isso designa um *parâmetro de rota*. Um parâmetro de rota captura um segmento do caminho da solicitação e coloca esse valor no `params` Hash, que é acessível pela ação do controlador. Por exemplo, ao lidar com uma solicitação como `GET http://localhost:3000/articles/1`, `1` seria capturado como o valor para `:id`, que então seria acessível como `params[:id]` na ação `show` de `ArticlesController`.
Vamos adicionar agora a ação `show`, abaixo da ação `index` em `app/controllers/articles_controller.rb`:

```ruby
class ArticlesController < ApplicationController
  def index
    @articles = Article.all
  end

  def show
    @article = Article.find(params[:id])
  end
end
```

A ação `show` chama `Article.find` (mencionado anteriormente) com o ID capturado pelo parâmetro da rota. O artigo retornado é armazenado na variável de instância `@article`, tornando-o acessível pela view. Por padrão, a ação `show` renderizará `app/views/articles/show.html.erb`.

Vamos criar `app/views/articles/show.html.erb`, com o seguinte conteúdo:

```html+erb
<h1><%= @article.title %></h1>

<p><%= @article.body %></p>
```

Agora podemos ver o artigo quando visitamos <http://localhost:3000/articles/1>!

Para finalizar, vamos adicionar uma forma conveniente de acessar a página de um artigo. Vamos linkar o título de cada artigo em `app/views/articles/index.html.erb` para a sua página:

```html+erb
<h1>Artigos</h1>

<ul>
  <% @articles.each do |article| %>
    <li>
      <a href="/articles/<%= article.id %>">
        <%= article.title %>
      </a>
    </li>
  <% end %>
</ul>
```

### Rotas de Recursos

Até agora, cobrimos o "R" (Read) do CRUD. Eventualmente, cobriremos o "C" (Create), "U" (Update) e "D" (Delete). Como você pode ter imaginado, faremos isso adicionando novas rotas, ações de controlador e views. Sempre que temos uma combinação dessas rotas, ações de controlador e views que trabalham juntas para realizar operações CRUD em uma entidade, chamamos essa entidade de *recurso*. Por exemplo, em nossa aplicação, diríamos que um artigo é um recurso.

O Rails fornece um método de rotas chamado [`resources`](
https://api.rubyonrails.org/classes/ActionDispatch/Routing/Mapper/Resources.html#method-i-resources) que mapeia todas as rotas convencionais para uma coleção de recursos, como artigos. Então, antes de prosseguirmos para as seções "C", "U" e "D", vamos substituir as duas rotas `get` em `config/routes.rb` por `resources`:

```ruby
Rails.application.routes.draw do
  root "articles#index"

  resources :articles
end
```

Podemos verificar quais rotas estão mapeadas executando o comando `bin/rails routes`:

```bash
$ bin/rails routes
      Prefix Verb   URI Pattern                  Controller#Action
        root GET    /                            articles#index
    articles GET    /articles(.:format)          articles#index
 new_article GET    /articles/new(.:format)      articles#new
     article GET    /articles/:id(.:format)      articles#show
             POST   /articles(.:format)          articles#create
edit_article GET    /articles/:id/edit(.:format) articles#edit
             PATCH  /articles/:id(.:format)      articles#update
             DELETE /articles/:id(.:format)      articles#destroy
```

O método `resources` também configura métodos auxiliares de URL e path que podemos usar para evitar que nosso código dependa de uma configuração de rota específica. Os valores na coluna "Prefix" acima mais um sufixo `_url` ou `_path` formam os nomes desses helpers. Por exemplo, o helper `article_path` retorna `"/articles/#{article.id}"` quando dado um artigo. Podemos usá-lo para limpar nossos links em `app/views/articles/index.html.erb`:

```html+erb
<h1>Artigos</h1>

<ul>
  <% @articles.each do |article| %>
    <li>
      <a href="<%= article_path(article) %>">
        <%= article.title %>
      </a>
    </li>
  <% end %>
</ul>
```

No entanto, vamos levar isso um passo adiante usando o helper [`link_to`](
https://api.rubyonrails.org/classes/ActionView/Helpers/UrlHelper.html#method-i-link_to). O helper `link_to` renderiza um link com seu primeiro argumento como o texto do link e seu segundo argumento como o destino do link. Se passarmos um objeto de modelo como segundo argumento, o `link_to` chamará o helper de path apropriado para converter o objeto em um path. Por exemplo, se passarmos um artigo, o `link_to` chamará `article_path`. Então, `app/views/articles/index.html.erb` se torna:

```html+erb
<h1>Artigos</h1>

<ul>
  <% @articles.each do |article| %>
    <li>
      <%= link_to article.title, article %>
    </li>
  <% end %>
</ul>
```

Legal!

DICA: Para aprender mais sobre roteamento, consulte [Rails Routing from the Outside In](
routing.html).

### Criando um Novo Artigo

Agora passamos para o "C" (Create) do CRUD. Tipicamente, em aplicações web, criar um novo recurso é um processo de várias etapas. Primeiro, o usuário solicita um formulário para preencher. Em seguida, o usuário envia o formulário. Se não houver erros, o recurso é criado e alguma forma de confirmação é exibida. Caso contrário, o formulário é exibido novamente com mensagens de erro, e o processo é repetido.

Em uma aplicação Rails, essas etapas são convencionalmente tratadas pelas ações `new` e `create` de um controlador. Vamos adicionar uma implementação típica dessas ações em `app/controllers/articles_controller.rb`, abaixo da ação `show`:

```ruby
class ArticlesController < ApplicationController
  def index
    @articles = Article.all
  end

  def show
    @article = Article.find(params[:id])
  end

  def new
    @article = Article.new
  end

  def create
    @article = Article.new(title: "...", body: "...")

    if @article.save
      redirect_to @article
    else
      render :new, status: :unprocessable_entity
    end
  end
end
```

A ação `new` instancia um novo artigo, mas não o salva. Este artigo será usado na view ao construir o formulário. Por padrão, a ação `new` renderizará `app/views/articles/new.html.erb`, que criaremos em seguida.
A ação `create` instancia um novo artigo com valores para o título e o corpo e tenta salvá-lo. Se o artigo for salvo com sucesso, a ação redireciona o navegador para a página do artigo em `"http://localhost:3000/articles/#{@article.id}"`.
Caso contrário, a ação exibe novamente o formulário renderizando `app/views/articles/new.html.erb` com o código de status [422 Unprocessable Entity](https://developer.mozilla.org/en-US/docs/Web/HTTP/Status/422).
O título e o corpo aqui são valores fictícios. Depois de criar o formulário, voltaremos e alteraremos esses valores.

NOTA: [`redirect_to`](https://api.rubyonrails.org/classes/ActionController/Redirecting.html#method-i-redirect_to)
fará com que o navegador faça uma nova solicitação,
enquanto [`render`](https://api.rubyonrails.org/classes/AbstractController/Rendering.html#method-i-render)
renderiza a visualização especificada para a solicitação atual.
É importante usar `redirect_to` após modificar o banco de dados ou o estado da aplicação.
Caso contrário, se o usuário atualizar a página, o navegador fará a mesma solicitação e a mutação será repetida.

#### Usando um Construtor de Formulários

Vamos usar um recurso do Rails chamado *construtor de formulários* para criar nosso formulário. Usando
um construtor de formulários, podemos escrever uma quantidade mínima de código para gerar um formulário totalmente configurado e que segue as convenções do Rails.

Vamos criar `app/views/articles/new.html.erb` com o seguinte conteúdo:

```html+erb
<h1>Novo Artigo</h1>

<%= form_with model: @article do |form| %>
  <div>
    <%= form.label :title %><br>
    <%= form.text_field :title %>
  </div>

  <div>
    <%= form.label :body %><br>
    <%= form.text_area :body %>
  </div>

  <div>
    <%= form.submit %>
  </div>
<% end %>
```

O método auxiliar [`form_with`](https://api.rubyonrails.org/classes/ActionView/Helpers/FormHelper.html#method-i-form_with)
instancia um construtor de formulários. No bloco `form_with`, chamamos
métodos como [`label`](https://api.rubyonrails.org/classes/ActionView/Helpers/FormBuilder.html#method-i-label)
e [`text_field`](https://api.rubyonrails.org/classes/ActionView/Helpers/FormBuilder.html#method-i-text_field)
no construtor de formulários para gerar os elementos de formulário apropriados.

A saída resultante da chamada `form_with` será parecida com esta:

```html
<form action="/articles" accept-charset="UTF-8" method="post">
  <input type="hidden" name="authenticity_token" value="...">

  <div>
    <label for="article_title">Título</label><br>
    <input type="text" name="article[title]" id="article_title">
  </div>

  <div>
    <label for="article_body">Corpo</label><br>
    <textarea name="article[body]" id="article_body"></textarea>
  </div>

  <div>
    <input type="submit" name="commit" value="Criar Artigo" data-disable-with="Criar Artigo">
  </div>
</form>
```

DICA: Para saber mais sobre construtores de formulários, consulte [Action View Form Helpers](
form_helpers.html).

#### Usando Strong Parameters

Os dados do formulário enviados são colocados no Hash `params`, juntamente com os parâmetros de rota capturados. Assim, a ação `create` pode acessar o título enviado através de `params[:article][:title]` e o corpo enviado através de `params[:article][:body]`.
Poderíamos passar esses valores individualmente para `Article.new`, mas isso seria verboso e possivelmente propenso a erros. E pioraria à medida que adicionássemos mais campos.

Em vez disso, passaremos um único Hash que contém os valores. No entanto, ainda precisamos especificar quais valores são permitidos nesse Hash. Caso contrário, um usuário mal-intencionado poderia enviar campos de formulário extras e sobrescrever dados privados. Na verdade, se passarmos o Hash `params[:article]` não filtrado diretamente para `Article.new`, o Rails lançará um `ForbiddenAttributesError` para nos alertar sobre o problema. Portanto, usaremos um recurso do Rails chamado *Strong Parameters* para filtrar `params`. Pense nisso como [tipagem forte](https://en.wikipedia.org/wiki/Strong_and_weak_typing)
para `params`.

Vamos adicionar um método privado no final de `app/controllers/articles_controller.rb`
chamado `article_params` que filtra `params`. E vamos alterar o `create` para usá-lo:

```ruby
class ArticlesController < ApplicationController
  def index
    @articles = Article.all
  end

  def show
    @article = Article.find(params[:id])
  end

  def new
    @article = Article.new
  end

  def create
    @article = Article.new(article_params)

    if @article.save
      redirect_to @article
    else
      render :new, status: :unprocessable_entity
    end
  end

  private
    def article_params
      params.require(:article).permit(:title, :body)
    end
end
```

DICA: Para saber mais sobre Strong Parameters, consulte [Action Controller Overview §
Strong Parameters](action_controller_overview.html#strong-parameters).

#### Validações e Exibição de Mensagens de Erro

Como vimos, criar um recurso é um processo de várias etapas. Lidar com uma entrada de usuário inválida é outra etapa desse processo. O Rails fornece um recurso chamado *validações* para nos ajudar a lidar com uma entrada de usuário inválida. As validações são regras que são verificadas antes que um objeto do modelo seja salvo. Se alguma das verificações falhar, o salvamento será interrompido e mensagens de erro apropriadas serão adicionadas ao atributo `errors` do objeto do modelo.

Vamos adicionar algumas validações ao nosso modelo em `app/models/article.rb`:

```ruby
class Article < ApplicationRecord
  validates :title, presence: true
  validates :body, presence: true, length: { minimum: 10 }
end
```

A primeira validação declara que um valor de `title` deve estar presente. Como
`title` é uma string, isso significa que o valor de `title` deve conter pelo menos um
caractere que não seja espaço em branco.

A segunda validação declara que um valor de `body` também deve estar presente.
Além disso, declara que o valor de `body` deve ter pelo menos 10 caracteres de
comprimento.

NOTA: Você pode estar se perguntando onde os atributos `title` e `body` são definidos.
O Active Record define automaticamente os atributos do modelo para cada coluna da tabela, então
você não precisa declarar esses atributos em seu arquivo de modelo.
Com nossas validações em vigor, vamos modificar `app/views/articles/new.html.erb` para exibir quaisquer mensagens de erro para `title` e `body`:

```html+erb
<h1>Novo Artigo</h1>

<%= form_with model: @article do |form| %>
  <div>
    <%= form.label :title %><br>
    <%= form.text_field :title %>
    <% @article.errors.full_messages_for(:title).each do |message| %>
      <div><%= message %></div>
    <% end %>
  </div>

  <div>
    <%= form.label :body %><br>
    <%= form.text_area :body %><br>
    <% @article.errors.full_messages_for(:body).each do |message| %>
      <div><%= message %></div>
    <% end %>
  </div>

  <div>
    <%= form.submit %>
  </div>
<% end %>
```

O método [`full_messages_for`](https://api.rubyonrails.org/classes/ActiveModel/Errors.html#method-i-full_messages_for)
retorna um array de mensagens de erro amigáveis para um atributo especificado. Se não houver erros para esse atributo, o array estará vazio.

Para entender como tudo isso funciona em conjunto, vamos dar mais uma olhada nas ações do controlador `new` e `create`:

```ruby
  def new
    @article = Article.new
  end

  def create
    @article = Article.new(article_params)

    if @article.save
      redirect_to @article
    else
      render :new, status: :unprocessable_entity
    end
  end
```

Quando visitamos <http://localhost:3000/articles/new>, a requisição `GET /articles/new` é mapeada para a ação `new`. A ação `new` não tenta salvar `@article`. Portanto, as validações não são verificadas e não haverá mensagens de erro.

Quando enviamos o formulário, a requisição `POST /articles` é mapeada para a ação `create`. A ação `create` *tenta* salvar `@article`. Portanto, as validações *são* verificadas. Se alguma validação falhar, `@article` não será salvo e `app/views/articles/new.html.erb` será renderizado com mensagens de erro.

DICA: Para aprender mais sobre validações, consulte [Active Record Validations](
active_record_validations.html). Para aprender mais sobre mensagens de erro de validação, consulte [Active Record Validations § Trabalhando com Erros de Validação](
active_record_validations.html#working-with-validation-errors).

#### Finalizando

Agora podemos criar um artigo visitando <http://localhost:3000/articles/new>. Para finalizar, vamos adicionar um link para essa página no final de `app/views/articles/index.html.erb`:

```html+erb
<h1>Artigos</h1>

<ul>
  <% @articles.each do |article| %>
    <li>
      <%= link_to article.title, article %>
    </li>
  <% end %>
</ul>

<%= link_to "Novo Artigo", new_article_path %>
```

### Atualizando um Artigo

Já cobrimos o "CR" do CRUD. Agora vamos passar para o "U" (Atualização). Atualizar um recurso é muito semelhante a criar um recurso. Ambos são processos de vários passos. Primeiro, o usuário solicita um formulário para editar os dados. Em seguida, o usuário envia o formulário. Se não houver erros, o recurso é atualizado. Caso contrário, o formulário é exibido novamente com mensagens de erro e o processo é repetido.

Essas etapas são convencionalmente tratadas pelas ações `edit` e `update` de um controlador. Vamos adicionar uma implementação típica dessas ações em `app/controllers/articles_controller.rb`, abaixo da ação `create`:

```ruby
class ArticlesController < ApplicationController
  def index
    @articles = Article.all
  end

  def show
    @article = Article.find(params[:id])
  end

  def new
    @article = Article.new
  end

  def create
    @article = Article.new(article_params)

    if @article.save
      redirect_to @article
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @article = Article.find(params[:id])
  end

  def update
    @article = Article.find(params[:id])

    if @article.update(article_params)
      redirect_to @article
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private
    def article_params
      params.require(:article).permit(:title, :body)
    end
end
```

Observe como as ações `edit` e `update` se assemelham às ações `new` e `create`.

A ação `edit` busca o artigo no banco de dados e o armazena em `@article` para que possa ser usado ao construir o formulário. Por padrão, a ação `edit` renderizará `app/views/articles/edit.html.erb`.

A ação `update` busca (re-)o artigo no banco de dados e tenta atualizá-lo com os dados do formulário enviados filtrados por `article_params`. Se nenhuma validação falhar e a atualização for bem-sucedida, a ação redireciona o navegador para a página do artigo. Caso contrário, a ação exibe novamente o formulário - com mensagens de erro - renderizando `app/views/articles/edit.html.erb`.

#### Usando Partials para Compartilhar Código de Visualização

Nosso formulário `edit` será igual ao nosso formulário `new`. Até mesmo o código será o mesmo, graças ao construtor de formulários do Rails e ao roteamento de recursos. O construtor de formulários configura automaticamente o formulário para fazer o tipo apropriado de requisição, com base em se o objeto do modelo foi salvo anteriormente.

Como o código será o mesmo, vamos extrair isso para uma visualização compartilhada chamada *partial*. Vamos criar `app/views/articles/_form.html.erb` com o seguinte conteúdo:

```html+erb
<%= form_with model: article do |form| %>
  <div>
    <%= form.label :title %><br>
    <%= form.text_field :title %>
    <% article.errors.full_messages_for(:title).each do |message| %>
      <div><%= message %></div>
    <% end %>
  </div>

  <div>
    <%= form.label :body %><br>
    <%= form.text_area :body %><br>
    <% article.errors.full_messages_for(:body).each do |message| %>
      <div><%= message %></div>
    <% end %>
  </div>

  <div>
    <%= form.submit %>
  </div>
<% end %>
```
O código acima é o mesmo que o nosso formulário em `app/views/articles/new.html.erb`,
exceto que todas as ocorrências de `@article` foram substituídas por `article`.
Como os parciais são códigos compartilhados, é uma boa prática que eles não dependam
de variáveis de instância específicas definidas por uma ação do controlador. Em vez disso, passaremos
o artigo para o parcial como uma variável local.

Vamos atualizar `app/views/articles/new.html.erb` para usar o parcial através do [`render`](
https://api.rubyonrails.org/classes/ActionView/Helpers/RenderingHelper.html#method-i-render):

```html+erb
<h1>Novo Artigo</h1>

<%= render "form", article: @article %>
```

NOTA: O nome do arquivo de um parcial deve ser prefixado **com** um sublinhado, por exemplo,
`_form.html.erb`. Mas ao renderizar, ele é referenciado **sem** o sublinhado, por exemplo, `render "form"`.

E agora, vamos criar um `app/views/articles/edit.html.erb` muito semelhante:

```html+erb
<h1>Editar Artigo</h1>

<%= render "form", article: @article %>
```

DICA: Para aprender mais sobre parciais, consulte [Layouts e Renderização no Rails § Usando
Parciais](layouts_and_rendering.html#using-partials).

#### Finalizando

Agora podemos atualizar um artigo visitando sua página de edição, por exemplo,
<http://localhost:3000/articles/1/edit>. Para finalizar, vamos adicionar um link para a página de edição no final de `app/views/articles/show.html.erb`:

```html+erb
<h1><%= @article.title %></h1>

<p><%= @article.body %></p>

<ul>
  <li><%= link_to "Editar", edit_article_path(@article) %></li>
</ul>
```

### Excluindo um Artigo

Finalmente, chegamos ao "D" (Delete) do CRUD. Excluir um recurso é um processo mais simples
do que criar ou atualizar. Ele só requer uma rota e uma ação do controlador. E nosso roteamento de recursos (`resources :articles`) já fornece a
rota, que mapeia as solicitações `DELETE /articles/:id` para a ação `destroy` do
`ArticlesController`.

Então, vamos adicionar uma ação `destroy` típica ao `app/controllers/articles_controller.rb`,
abaixo da ação `update`:

```ruby
class ArticlesController < ApplicationController
  def index
    @articles = Article.all
  end

  def show
    @article = Article.find(params[:id])
  end

  def new
    @article = Article.new
  end

  def create
    @article = Article.new(article_params)

    if @article.save
      redirect_to @article
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @article = Article.find(params[:id])
  end

  def update
    @article = Article.find(params[:id])

    if @article.update(article_params)
      redirect_to @article
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @article = Article.find(params[:id])
    @article.destroy

    redirect_to root_path, status: :see_other
  end

  private
    def article_params
      params.require(:article).permit(:title, :body)
    end
end
```

A ação `destroy` busca o artigo no banco de dados e chama [`destroy`](
https://api.rubyonrails.org/classes/ActiveRecord/Persistence.html#method-i-destroy)
nele. Em seguida, redireciona o navegador para a rota raiz com o código de status
[303 See Other](https://developer.mozilla.org/en-US/docs/Web/HTTP/Status/303).

Escolhemos redirecionar para a rota raiz porque esse é nosso principal ponto de acesso
para os artigos. Mas, em outras circunstâncias, você pode optar por redirecionar para
por exemplo, `articles_path`.

Agora vamos adicionar um link no final de `app/views/articles/show.html.erb` para que
possamos excluir um artigo de sua própria página:

```html+erb
<h1><%= @article.title %></h1>

<p><%= @article.body %></p>

<ul>
  <li><%= link_to "Editar", edit_article_path(@article) %></li>
  <li><%= link_to "Excluir", article_path(@article), data: {
                    turbo_method: :delete,
                    turbo_confirm: "Tem certeza?"
                  } %></li>
</ul>
```

No código acima, usamos a opção `data` para definir os atributos HTML `data-turbo-method` e
`data-turbo-confirm` do link "Excluir". Ambos os atributos se conectam ao [Turbo](https://turbo.hotwired.dev/), que é incluído por
padrão em novas aplicações Rails. `data-turbo-method="delete"` fará com que o
link faça uma solicitação `DELETE` em vez de uma solicitação `GET`.
`data-turbo-confirm="Tem certeza?"` fará com que um diálogo de confirmação apareça
quando o link for clicado. Se o usuário cancelar o diálogo, a solicitação será
cancelada.

E é isso! Agora podemos listar, mostrar, criar, atualizar e excluir artigos!
InCRUDível!

Adicionando um Segundo Modelo
----------------------------

É hora de adicionar um segundo modelo à aplicação. O segundo modelo lidará com
comentários em artigos.

### Gerando um Modelo

Vamos ver o mesmo gerador que usamos antes ao criar o modelo `Article`. Desta vez, vamos criar um modelo `Comment` para armazenar uma
referência a um artigo. Execute este comando no seu terminal:

```bash
$ bin/rails generate model Comment commenter:string body:text article:references
```

Este comando irá gerar quatro arquivos:

| Arquivo                                         | Propósito                                                                                              |
| ----------------------------------------------- | ------------------------------------------------------------------------------------------------------ |
| db/migrate/20140120201010_create_comments.rb    | Migração para criar a tabela de comentários no seu banco de dados (seu nome incluirá um timestamp diferente) |
| app/models/comment.rb                           | O modelo Comment                                                                                       |
| test/models/comment_test.rb                     | Conjunto de testes para o modelo Comment                                                               |
| test/fixtures/comments.yml                      | Comentários de exemplo para uso nos testes                                                             |

Primeiro, dê uma olhada em `app/models/comment.rb`:

```ruby
class Comment < ApplicationRecord
  belongs_to :article
end
```

Isso é muito semelhante ao modelo `Article` que você viu anteriormente. A diferença
é a linha `belongs_to :article`, que configura uma _associação_ do Active Record.
Você aprenderá um pouco sobre associações na próxima seção deste guia.
A palavra-chave (`:references`) usada no comando shell é um tipo de dado especial para modelos.
Ele cria uma nova coluna na tabela do banco de dados com o nome do modelo fornecido seguido de um `_id`
que pode armazenar valores inteiros. Para entender melhor, analise o
arquivo `db/schema.rb` após executar a migração.

Além do modelo, o Rails também criou uma migração para criar a
tabela correspondente no banco de dados:

```ruby
class CreateComments < ActiveRecord::Migration[7.0]
  def change
    create_table :comments do |t|
      t.string :commenter
      t.text :body
      t.references :article, null: false, foreign_key: true

      t.timestamps
    end
  end
end
```

A linha `t.references` cria uma coluna inteira chamada `article_id`, um índice
para ela e uma restrição de chave estrangeira que aponta para a coluna `id` da tabela `articles`.
Vá em frente e execute a migração:

```bash
$ bin/rails db:migrate
```

O Rails é inteligente o suficiente para executar apenas as migrações que ainda não foram
executadas no banco de dados atual, então neste caso você verá apenas:

```
==  CreateComments: migrating =================================================
-- create_table(:comments)
   -> 0.0115s
==  CreateComments: migrated (0.0119s) ========================================
```

### Associando Modelos

As associações do Active Record permitem declarar facilmente o relacionamento entre dois
modelos. No caso de comentários e artigos, você poderia escrever as
relações desta forma:

* Cada comentário pertence a um artigo.
* Um artigo pode ter muitos comentários.

Na verdade, isso é muito próximo da sintaxe que o Rails usa para declarar essa
associação. Você já viu a linha de código dentro do modelo `Comment`
(app/models/comment.rb) que faz com que cada comentário pertença a um Artigo:

```ruby
class Comment < ApplicationRecord
  belongs_to :article
end
```

Você precisará editar `app/models/article.rb` para adicionar o outro lado da
associação:

```ruby
class Article < ApplicationRecord
  has_many :comments

  validates :title, presence: true
  validates :body, presence: true, length: { minimum: 10 }
end
```

Essas duas declarações permitem um bom comportamento automático. Por exemplo, se
você tiver uma variável de instância `@article` contendo um artigo, você pode recuperar
todos os comentários pertencentes a esse artigo como um array usando
`@article.comments`.

DICA: Para obter mais informações sobre as associações do Active Record, consulte o [Guia de Associações do Active Record](association_basics.html).

### Adicionando uma Rota para Comentários

Assim como o controlador `articles`, precisaremos adicionar uma rota para que o Rails
saiba para onde queremos navegar para ver os `comments`. Abra o arquivo
`config/routes.rb` novamente e edite-o da seguinte forma:

```ruby
Rails.application.routes.draw do
  root "articles#index"

  resources :articles do
    resources :comments
  end
end
```

Isso cria `comments` como um _recurso aninhado_ dentro de `articles`. Isso é
outra parte da captura do relacionamento hierárquico que existe entre
artigos e comentários.

DICA: Para obter mais informações sobre roteamento, consulte o [Guia de Roteamento do Rails](routing.html).

### Gerando um Controlador

Com o modelo em mãos, você pode voltar sua atenção para a criação de um controlador correspondente.
Novamente, usaremos o mesmo gerador que usamos antes:

```bash
$ bin/rails generate controller Comments
```

Isso cria três arquivos e um diretório vazio:

| Arquivo/Diretório                            | Propósito                                 |
| -------------------------------------------- | ----------------------------------------- |
| app/controllers/comments_controller.rb       | O controlador Comments                    |
| app/views/comments/                          | As visualizações do controlador são armazenadas aqui |
| test/controllers/comments_controller_test.rb | O teste para o controlador                 |
| app/helpers/comments_helper.rb               | Um arquivo de helper de visualização        |

Assim como em qualquer blog, nossos leitores criarão seus comentários diretamente após
ler o artigo e, depois de adicionar seu comentário, serão enviados de volta
para a página de exibição do artigo para ver seu comentário listado. Por causa disso, nosso
`CommentsController` está lá para fornecer um método para criar comentários e excluir
comentários de spam quando eles chegam.

Então, primeiro, vamos conectar o template de exibição do Artigo
(`app/views/articles/show.html.erb`) para nos permitir fazer um novo comentário:

```html+erb
<h1><%= @article.title %></h1>

<p><%= @article.body %></p>

<ul>
  <li><%= link_to "Edit", edit_article_path(@article) %></li>
  <li><%= link_to "Destroy", article_path(@article), data: {
                    turbo_method: :delete,
                    turbo_confirm: "Are you sure?"
                  } %></li>
</ul>

<h2>Add a comment:</h2>
<%= form_with model: [ @article, @article.comments.build ] do |form| %>
  <p>
    <%= form.label :commenter %><br>
    <%= form.text_field :commenter %>
  </p>
  <p>
    <%= form.label :body %><br>
    <%= form.text_area :body %>
  </p>
  <p>
    <%= form.submit %>
  </p>
<% end %>
```

Isso adiciona um formulário na página de exibição do `Article` que cria um novo comentário
chamando a ação `create` do `CommentsController`. A chamada `form_with` aqui usa
um array, que criará uma rota aninhada, como `/articles/1/comments`.
Vamos conectar o `create` no `app/controllers/comments_controller.rb`:

```ruby
class CommentsController < ApplicationController
  def create
    @article = Article.find(params[:article_id])
    @comment = @article.comments.create(comment_params)
    redirect_to article_path(@article)
  end

  private
    def comment_params
      params.require(:comment).permit(:commenter, :body)
    end
end
```

Você verá um pouco mais de complexidade aqui do que no controlador para artigos. Isso é um efeito colateral do aninhamento que você configurou. Cada solicitação de um comentário precisa acompanhar o artigo ao qual o comentário está anexado, portanto, a chamada inicial ao método `find` do modelo `Article` para obter o artigo em questão.

Além disso, o código aproveita alguns dos métodos disponíveis para uma associação. Usamos o método `create` em `@article.comments` para criar e salvar o comentário. Isso vinculará automaticamente o comentário para que ele pertença a esse artigo específico.

Depois de criar o novo comentário, enviamos o usuário de volta ao artigo original usando o auxiliar `article_path(@article)`. Como já vimos, isso chama a ação `show` do `ArticlesController`, que por sua vez renderiza o modelo `show.html.erb`. É aqui que queremos que o comentário seja exibido, então vamos adicioná-lo ao `app/views/articles/show.html.erb`.

```html+erb
<h1><%= @article.title %></h1>

<p><%= @article.body %></p>

<ul>
  <li><%= link_to "Editar", edit_article_path(@article) %></li>
  <li><%= link_to "Excluir", article_path(@article), data: {
                    turbo_method: :delete,
                    turbo_confirm: "Tem certeza?"
                  } %></li>
</ul>

<h2>Comentários</h2>
<% @article.comments.each do |comment| %>
  <p>
    <strong>Comentarista:</strong>
    <%= comment.commenter %>
  </p>

  <p>
    <strong>Comentário:</strong>
    <%= comment.body %>
  </p>
<% end %>

<h2>Adicionar um comentário:</h2>
<%= form_with model: [ @article, @article.comments.build ] do |form| %>
  <p>
    <%= form.label :commenter %><br>
    <%= form.text_field :commenter %>
  </p>
  <p>
    <%= form.label :body %><br>
    <%= form.text_area :body %>
  </p>
  <p>
    <%= form.submit %>
  </p>
<% end %>
```

Agora você pode adicionar artigos e comentários ao seu blog e vê-los aparecer nos lugares certos.

![Artigo com Comentários](images/getting_started/article_with_comments.png)

Refatoração
-----------

Agora que temos artigos e comentários funcionando, dê uma olhada no modelo `app/views/articles/show.html.erb`. Ele está ficando longo e desajeitado. Podemos usar parciais para deixá-lo mais limpo.

### Renderizando Coleções de Parciais

Primeiro, vamos criar um parcial para os comentários e extrair a exibição de todos os comentários do artigo. Crie o arquivo `app/views/comments/_comment.html.erb` e coloque o seguinte nele:

```html+erb
<p>
  <strong>Comentarista:</strong>
  <%= comment.commenter %>
</p>

<p>
  <strong>Comentário:</strong>
  <%= comment.body %>
</p>
```

Em seguida, você pode alterar o arquivo `app/views/articles/show.html.erb` para ficar assim:

```html+erb
<h1><%= @article.title %></h1>

<p><%= @article.body %></p>

<ul>
  <li><%= link_to "Editar", edit_article_path(@article) %></li>
  <li><%= link_to "Excluir", article_path(@article), data: {
                    turbo_method: :delete,
                    turbo_confirm: "Tem certeza?"
                  } %></li>
</ul>

<h2>Comentários</h2>
<%= render @article.comments %>

<h2>Adicionar um comentário:</h2>
<%= form_with model: [ @article, @article.comments.build ] do |form| %>
  <p>
    <%= form.label :commenter %><br>
    <%= form.text_field :commenter %>
  </p>
  <p>
    <%= form.label :body %><br>
    <%= form.text_area :body %>
  </p>
  <p>
    <%= form.submit %>
  </p>
<% end %>
```

Agora o parcial será renderizado em `app/views/comments/_comment.html.erb` uma vez para cada comentário na coleção `@article.comments`. Conforme o método `render` itera sobre a coleção `@article.comments`, ele atribui cada comentário a uma variável local com o mesmo nome do parcial, neste caso `comment`, que fica disponível no parcial para exibição.

### Renderizando um Formulário Parcial

Vamos também mover a seção de novo comentário para seu próprio parcial. Novamente, você cria um arquivo `app/views/comments/_form.html.erb` contendo:

```html+erb
<%= form_with model: [ @article, @article.comments.build ] do |form| %>
  <p>
    <%= form.label :commenter %><br>
    <%= form.text_field :commenter %>
  </p>
  <p>
    <%= form.label :body %><br>
    <%= form.text_area :body %>
  </p>
  <p>
    <%= form.submit %>
  </p>
<% end %>
```

Em seguida, você faz o arquivo `app/views/articles/show.html.erb` ficar assim:

```html+erb
<h1><%= @article.title %></h1>

<p><%= @article.body %></p>

<ul>
  <li><%= link_to "Editar", edit_article_path(@article) %></li>
  <li><%= link_to "Excluir", article_path(@article), data: {
                    turbo_method: :delete,
                    turbo_confirm: "Tem certeza?"
                  } %></li>
</ul>

<h2>Comentários</h2>
<%= render @article.comments %>

<h2>Adicionar um comentário:</h2>
<%= render 'comments/form' %>
```

A segunda renderização apenas define o modelo parcial que queremos renderizar, `comments/form`. O Rails é inteligente o suficiente para identificar a barra inclinada na string e perceber que você deseja renderizar o arquivo `_form.html.erb` no diretório `app/views/comments`.

O objeto `@article` está disponível para qualquer parcial renderizado na visualização porque o definimos como uma variável de instância.

### Usando Concerns

Concerns são uma maneira de tornar controladores ou modelos grandes mais fáceis de entender e gerenciar. Isso também tem a vantagem de reutilização quando vários modelos (ou controladores) compartilham as mesmas preocupações. Os concerns são implementados usando módulos que contêm métodos que representam uma parte bem definida da funcionalidade pela qual um modelo ou controlador é responsável. Em outras linguagens, os módulos são frequentemente conhecidos como mixins.
Você pode usar concerns no seu controller ou model da mesma forma que usaria qualquer módulo. Quando você criou seu aplicativo com `rails new blog`, duas pastas foram criadas dentro de `app/`, juntamente com o restante:

```
app/controllers/concerns
app/models/concerns
```

No exemplo abaixo, implementaremos um novo recurso para nosso blog que se beneficiaria do uso de um concern. Em seguida, criaremos um concern e refatoraremos o código para usá-lo, tornando o código mais DRY e fácil de manter.

Um artigo de blog pode ter vários status - por exemplo, pode ser visível para todos (ou seja, `public`), ou apenas visível para o autor (ou seja, `private`). Também pode estar oculto para todos, mas ainda recuperável (ou seja, `archived`). Comentários também podem ser ocultos ou visíveis. Isso pode ser representado usando uma coluna `status` em cada modelo.

Primeiro, execute as seguintes migrações para adicionar `status` a `Articles` e `Comments`:

```bash
$ bin/rails generate migration AddStatusToArticles status:string
$ bin/rails generate migration AddStatusToComments status:string
```

Em seguida, atualize o banco de dados com as migrações geradas:

```bash
$ bin/rails db:migrate
```

Para escolher o status para os artigos e comentários existentes, você pode adicionar um valor padrão aos arquivos de migração gerados, adicionando a opção `default: "public"` e executar as migrações novamente. Você também pode chamar no console do rails `Article.update_all(status: "public")` e `Comment.update_all(status: "public")`.


DICA: Para saber mais sobre migrações, consulte [Active Record Migrations](
active_record_migrations.html).

Também precisamos permitir a chave `:status` como parte do strong parameter, em `app/controllers/articles_controller.rb`:

```ruby

  private
    def article_params
      params.require(:article).permit(:title, :body, :status)
    end
```

e em `app/controllers/comments_controller.rb`:

```ruby

  private
    def comment_params
      params.require(:comment).permit(:commenter, :body, :status)
    end
```

Dentro do modelo `article`, após executar uma migração para adicionar uma coluna `status` usando o comando `bin/rails db:migrate`, você adicionaria:

```ruby
class Article < ApplicationRecord
  has_many :comments

  validates :title, presence: true
  validates :body, presence: true, length: { minimum: 10 }

  VALID_STATUSES = ['public', 'private', 'archived']

  validates :status, inclusion: { in: VALID_STATUSES }

  def archived?
    status == 'archived'
  end
end
```

e no modelo `Comment`:

```ruby
class Comment < ApplicationRecord
  belongs_to :article

  VALID_STATUSES = ['public', 'private', 'archived']

  validates :status, inclusion: { in: VALID_STATUSES }

  def archived?
    status == 'archived'
  end
end
```

Em seguida, em nosso template de ação `index` (`app/views/articles/index.html.erb`), usaríamos o método `archived?` para evitar exibir qualquer artigo que esteja arquivado:

```html+erb
<h1>Articles</h1>

<ul>
  <% @articles.each do |article| %>
    <% unless article.archived? %>
      <li>
        <%= link_to article.title, article %>
      </li>
    <% end %>
  <% end %>
</ul>

<%= link_to "New Article", new_article_path %>
```

Da mesma forma, em nossa visualização parcial de comentários (`app/views/comments/_comment.html.erb`), usaríamos o método `archived?` para evitar exibir qualquer comentário que esteja arquivado:

```html+erb
<% unless comment.archived? %>
  <p>
    <strong>Commenter:</strong>
    <%= comment.commenter %>
  </p>

  <p>
    <strong>Comment:</strong>
    <%= comment.body %>
  </p>
<% end %>
```

No entanto, se você olhar novamente para nossos modelos agora, verá que a lógica está duplicada. Se no futuro aumentarmos a funcionalidade do nosso blog - para incluir mensagens privadas, por exemplo - podemos nos encontrar duplicando a lógica novamente. É aqui que os concerns são úteis.

Um concern é responsável apenas por um subconjunto focado da responsabilidade do modelo; os métodos em nosso concern estarão todos relacionados à visibilidade de um modelo. Vamos chamar nosso novo concern (módulo) de `Visible`. Podemos criar um novo arquivo dentro de `app/models/concerns` chamado `visible.rb` e armazenar todos os métodos de status que foram duplicados nos modelos.

`app/models/concerns/visible.rb`

```ruby
module Visible
  def archived?
    status == 'archived'
  end
end
```

Podemos adicionar nossa validação de status ao concern, mas isso é um pouco mais complexo, pois as validações são métodos chamados no nível da classe. O `ActiveSupport::Concern` ([API Guide](https://api.rubyonrails.org/classes/ActiveSupport/Concern.html)) nos dá uma maneira mais simples de incluí-las:

```ruby
module Visible
  extend ActiveSupport::Concern

  VALID_STATUSES = ['public', 'private', 'archived']

  included do
    validates :status, inclusion: { in: VALID_STATUSES }
  end

  def archived?
    status == 'archived'
  end
end
```

Agora, podemos remover a lógica duplicada de cada modelo e, em vez disso, incluir nosso novo módulo `Visible`:


Em `app/models/article.rb`:

```ruby
class Article < ApplicationRecord
  include Visible

  has_many :comments

  validates :title, presence: true
  validates :body, presence: true, length: { minimum: 10 }
end
```

e em `app/models/comment.rb`:

```ruby
class Comment < ApplicationRecord
  include Visible

  belongs_to :article
end
```
Métodos de classe também podem ser adicionados a preocupações. Se quisermos exibir a contagem de artigos públicos ou comentários em nossa página principal, podemos adicionar um método de classe a Visible da seguinte forma:

```ruby
module Visible
  extend ActiveSupport::Concern

  VALID_STATUSES = ['public', 'private', 'archived']

  included do
    validates :status, inclusion: { in: VALID_STATUSES }
  end

  class_methods do
    def public_count
      where(status: 'public').count
    end
  end

  def archived?
    status == 'archived'
  end
end
```

Então, na visualização, você pode chamá-lo como qualquer método de classe:

```html+erb
<h1>Artigos</h1>

Nosso blog tem <%= Article.public_count %> artigos e contando!

<ul>
  <% @articles.each do |article| %>
    <% unless article.archived? %>
      <li>
        <%= link_to article.title, article %>
      </li>
    <% end %>
  <% end %>
</ul>

<%= link_to "Novo Artigo", new_article_path %>
```

Para finalizar, adicionaremos uma caixa de seleção aos formulários e permitiremos que o usuário selecione o status ao criar um novo artigo ou postar um novo comentário. Também podemos especificar o status padrão como `public`. Em `app/views/articles/_form.html.erb`, podemos adicionar:

```html+erb
<div>
  <%= form.label :status %><br>
  <%= form.select :status, ['public', 'private', 'archived'], selected: 'public' %>
</div>
```

e em `app/views/comments/_form.html.erb`:

```html+erb
<p>
  <%= form.label :status %><br>
  <%= form.select :status, ['public', 'private', 'archived'], selected: 'public' %>
</p>
```

Excluindo Comentários
---------------------

Outra funcionalidade importante de um blog é a capacidade de excluir comentários de spam. Para fazer isso, precisamos implementar um link de algum tipo na visualização e uma ação `destroy` no `CommentsController`.

Então, primeiro, vamos adicionar o link de exclusão na parcial `app/views/comments/_comment.html.erb`:

```html+erb
<% unless comment.archived? %>
  <p>
    <strong>Comentarista:</strong>
    <%= comment.commenter %>
  </p>

  <p>
    <strong>Comentário:</strong>
    <%= comment.body %>
  </p>

  <p>
    <%= link_to "Excluir Comentário", [comment.article, comment], data: {
                  turbo_method: :delete,
                  turbo_confirm: "Tem certeza?"
                } %>
  </p>
<% end %>
```

Clicar neste novo link "Excluir Comentário" enviará uma solicitação `DELETE /articles/:article_id/comments/:id` para o nosso `CommentsController`, que pode então usar isso para encontrar o comentário que queremos excluir, então vamos adicionar uma ação `destroy` ao nosso controlador (`app/controllers/comments_controller.rb`):

```ruby
class CommentsController < ApplicationController
  def create
    @article = Article.find(params[:article_id])
    @comment = @article.comments.create(comment_params)
    redirect_to article_path(@article)
  end

  def destroy
    @article = Article.find(params[:article_id])
    @comment = @article.comments.find(params[:id])
    @comment.destroy
    redirect_to article_path(@article), status: :see_other
  end

  private
    def comment_params
      params.require(:comment).permit(:commenter, :body, :status)
    end
end
```

A ação `destroy` encontrará o artigo que estamos visualizando, localizará o comentário dentro da coleção `@article.comments` e, em seguida, o removerá do banco de dados e nos enviará de volta para a ação de exibição do artigo.

### Excluindo Objetos Associados

Se você excluir um artigo, seus comentários associados também precisarão ser excluídos, caso contrário, eles ocupariam espaço no banco de dados. O Rails permite que você use a opção `dependent` de uma associação para conseguir isso. Modifique o modelo Article, `app/models/article.rb`, da seguinte forma:

```ruby
class Article < ApplicationRecord
  include Visible

  has_many :comments, dependent: :destroy

  validates :title, presence: true
  validates :body, presence: true, length: { minimum: 10 }
end
```

Segurança
---------

### Autenticação Básica

Se você publicar seu blog online, qualquer pessoa poderá adicionar, editar e excluir artigos ou excluir comentários.

O Rails fornece um sistema de autenticação HTTP que funcionará bem nessa situação.

No `ArticlesController`, precisamos ter uma maneira de bloquear o acesso às várias ações se a pessoa não estiver autenticada. Aqui podemos usar o método `http_basic_authenticate_with` do Rails, que permite o acesso à ação solicitada se esse método permitir.

Para usar o sistema de autenticação, especificamos no topo do nosso `ArticlesController` em `app/controllers/articles_controller.rb`. No nosso caso, queremos que o usuário esteja autenticado em todas as ações, exceto `index` e `show`, então escrevemos isso:

```ruby
class ArticlesController < ApplicationController

  http_basic_authenticate_with name: "dhh", password: "secret", except: [:index, :show]

  def index
    @articles = Article.all
  end

  # trecho para brevidade
```

Também queremos permitir apenas usuários autenticados a excluir comentários, então no `CommentsController` (`app/controllers/comments_controller.rb`) escrevemos:

```ruby
class CommentsController < ApplicationController

  http_basic_authenticate_with name: "dhh", password: "secret", only: :destroy

  def create
    @article = Article.find(params[:article_id])
    # ...
  end

  # trecho para brevidade
```

Agora, se você tentar criar um novo artigo, será recebido com um desafio básico de autenticação HTTP:

![Desafio Básico de Autenticação HTTP](images/getting_started/challenge.png)

Após inserir o nome de usuário e senha corretos, você permanecerá autenticado até que um nome de usuário e senha diferentes sejam solicitados ou o navegador seja fechado.
Outros métodos de autenticação estão disponíveis para aplicações Rails. Dois complementos populares de autenticação para Rails são o motor do [Devise](https://github.com/plataformatec/devise) e a gema [Authlogic](https://github.com/binarylogic/authlogic), juntamente com outros.

### Outras Considerações de Segurança

A segurança, especialmente em aplicações web, é uma área ampla e detalhada. A segurança em sua aplicação Rails é abordada com mais profundidade no [Guia de Segurança do Ruby on Rails](security.html).

O que vem a seguir?
--------------------

Agora que você viu sua primeira aplicação Rails, sinta-se à vontade para atualizá-la e experimentar por conta própria.

Lembre-se de que você não precisa fazer tudo sem ajuda. Se precisar de assistência para começar e executar o Rails, consulte os recursos de suporte a seguir:

* Os [Guias do Ruby on Rails](index.html)
* A lista de discussão do [Ruby on Rails](https://discuss.rubyonrails.org/c/rubyonrails-talk)

Configurações problemáticas
---------------------------

A maneira mais fácil de trabalhar com o Rails é armazenar todos os dados externos como UTF-8. Se você não fizer isso, as bibliotecas Ruby e o Rails geralmente conseguirão converter seus dados nativos em UTF-8, mas isso nem sempre funciona de forma confiável, então é melhor garantir que todos os dados externos sejam UTF-8.

Se você cometeu um erro nessa área, o sintoma mais comum é um diamante preto com um ponto de interrogação dentro aparecendo no navegador. Outro sintoma comum é a aparência de caracteres como "Ã¼" em vez de "ü". O Rails toma várias medidas internas para mitigar as causas comuns desses problemas que podem ser detectadas e corrigidas automaticamente. No entanto, se você tiver dados externos que não estão armazenados como UTF-8, isso pode resultar ocasionalmente nesses tipos de problemas que não podem ser detectados e corrigidos automaticamente pelo Rails.

Duas fontes muito comuns de dados que não são UTF-8:

* Seu editor de texto: A maioria dos editores de texto (como o TextMate) é configurada para salvar arquivos como UTF-8. Se o seu editor de texto não estiver, isso pode resultar em caracteres especiais que você insere em seus modelos (como é) aparecerem como um diamante com um ponto de interrogação dentro no navegador. Isso também se aplica aos seus arquivos de tradução i18n. A maioria dos editores que não têm UTF-8 como padrão (como algumas versões do Dreamweaver) oferece uma maneira de alterar o padrão para UTF-8. Faça isso.
* Seu banco de dados: O Rails converte dados do seu banco de dados em UTF-8 por padrão na fronteira. No entanto, se o seu banco de dados não estiver usando UTF-8 internamente, ele pode não ser capaz de armazenar todos os caracteres que seus usuários inserem. Por exemplo, se o seu banco de dados estiver usando Latin-1 internamente e o usuário inserir um caractere russo, hebraico ou japonês, os dados serão perdidos para sempre assim que entrarem no banco de dados. Se possível, use UTF-8 como armazenamento interno do seu banco de dados.
