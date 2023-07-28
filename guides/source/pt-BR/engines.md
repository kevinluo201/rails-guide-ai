**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 2aedcd7fcf6f0b83538e8a8220d38afd
Introdução aos Engines
============================

Neste guia, você aprenderá sobre engines e como elas podem ser usadas para fornecer funcionalidades adicionais às suas aplicações hospedeiras por meio de uma interface limpa e muito fácil de usar.

Após ler este guia, você saberá:

* O que torna um engine.
* Como gerar um engine.
* Como construir recursos para o engine.
* Como conectar o engine a uma aplicação.
* Como substituir a funcionalidade do engine na aplicação.
* Como evitar o carregamento dos frameworks do Rails com Load e Configuration Hooks.

--------------------------------------------------------------------------------

O que são Engines?
-----------------

Engines podem ser considerados como aplicações em miniatura que fornecem funcionalidades às suas aplicações hospedeiras. Uma aplicação Rails é na verdade apenas um engine "turbinado", com a classe `Rails::Application` herdando grande parte de seu comportamento de `Rails::Engine`.

Portanto, engines e aplicações podem ser considerados quase a mesma coisa, apenas com diferenças sutis, como você verá ao longo deste guia. Engines e aplicações também compartilham uma estrutura comum.

Engines também estão intimamente relacionados a plugins. Os dois compartilham uma estrutura de diretório `lib` comum e são gerados usando o gerador `rails plugin new`. A diferença é que um engine é considerado um "plugin completo" pelo Rails (como indicado pela opção `--full` passada para o comando do gerador). Neste guia, estaremos usando a opção `--mountable`, que inclui todos os recursos de `--full` e mais alguns. Este guia se referirá a esses "plugins completos" simplesmente como "engines". Um engine **pode** ser um plugin e um plugin **pode** ser um engine.

O engine que será criado neste guia se chamará "blorgh". Este engine fornecerá funcionalidade de blog para suas aplicações hospedeiras, permitindo a criação de novos artigos e comentários. No início deste guia, você estará trabalhando exclusivamente dentro do próprio engine, mas nas seções posteriores você verá como conectá-lo a uma aplicação.

Engines também podem ser isolados de suas aplicações hospedeiras. Isso significa que uma aplicação pode ter um caminho fornecido por um helper de roteamento, como `articles_path`, e usar um engine que também fornece um caminho chamado `articles_path`, e os dois não entrarão em conflito. Além disso, controladores, modelos e nomes de tabelas também são colocados em namespaces. Você verá como fazer isso mais adiante neste guia.

É importante ter em mente o tempo todo que a aplicação deve **sempre** ter precedência sobre seus engines. Uma aplicação é o objeto que tem a palavra final sobre o que acontece em seu ambiente. O engine deve apenas aprimorá-la, em vez de alterá-la drasticamente.

Para ver demonstrações de outros engines, confira o [Devise](https://github.com/plataformatec/devise), um engine que fornece autenticação para suas aplicações pai, ou o [Thredded](https://github.com/thredded/thredded), um engine que fornece funcionalidade de fórum. Também há o [Spree](https://github.com/spree/spree), que fornece uma plataforma de comércio eletrônico, e o [Refinery CMS](https://github.com/refinery/refinerycms), um engine de CMS.

Por fim, engines não teriam sido possíveis sem o trabalho de James Adam, Piotr Sarnacki, da equipe principal do Rails e de várias outras pessoas. Se você encontrá-los algum dia, não se esqueça de agradecer!

Gerando um Engine
--------------------

Para gerar um engine, você precisará executar o gerador de plugins e passar as opções apropriadas para a necessidade. Para o exemplo "blorgh", você precisará criar um engine "mountable", executando o seguinte comando em um terminal:

```bash
$ rails plugin new blorgh --mountable
```

A lista completa de opções para o gerador de plugins pode ser vista digitando:

```bash
$ rails plugin --help
```

A opção `--mountable` informa ao gerador que você deseja criar um engine "mountable" e isolado em um namespace. Este gerador fornecerá a mesma estrutura esquelética que a opção `--full`. A opção `--full` informa ao gerador que você deseja criar um engine, incluindo uma estrutura esquelética que fornece o seguinte:

  * Uma árvore de diretórios `app`
  * Um arquivo `config/routes.rb`:

    ```ruby
    Rails.application.routes.draw do
    end
    ```

  * Um arquivo em `lib/blorgh/engine.rb`, que é idêntico em função ao arquivo `config/application.rb` de uma aplicação Rails padrão:

    ```ruby
    module Blorgh
      class Engine < ::Rails::Engine
      end
    end
    ```

A opção `--mountable` adicionará à opção `--full`:

  * Arquivos de manifesto de ativos (`blorgh_manifest.js` e `application.css`)
  * Um esboço de `ApplicationController` em um namespace
  * Um esboço de `ApplicationHelper` em um namespace
  * Um template de visualização de layout para o engine
  * Isolamento de namespace em `config/routes.rb`:
```ruby
Blorgh::Engine.routes.draw do
end
```

* Isolamento de namespace para `lib/blorgh/engine.rb`:

```ruby
module Blorgh
  class Engine < ::Rails::Engine
    isolate_namespace Blorgh
  end
end
```

Além disso, a opção `--mountable` diz ao gerador para montar o engine dentro do aplicativo de teste dummy localizado em `test/dummy`, adicionando o seguinte ao arquivo de rotas do aplicativo dummy em `test/dummy/config/routes.rb`:

```ruby
mount Blorgh::Engine => "/blorgh"
```

### Dentro de um Engine

#### Arquivos Críticos

Na raiz do diretório deste novo engine, há um arquivo `blorgh.gemspec`. Quando você incluir o engine em um aplicativo posteriormente, você fará isso com esta linha no `Gemfile` do aplicativo Rails:

```ruby
gem 'blorgh', path: 'engines/blorgh'
```

Não se esqueça de executar `bundle install` como de costume. Ao especificá-lo como uma gem no `Gemfile`, o Bundler o carregará como tal, analisando este arquivo `blorgh.gemspec` e requerendo um arquivo dentro do diretório `lib` chamado `lib/blorgh.rb`. Este arquivo requer o arquivo `blorgh/engine.rb` (localizado em `lib/blorgh/engine.rb`) e define um módulo base chamado `Blorgh`.

```ruby
require "blorgh/engine"

module Blorgh
end
```

DICA: Alguns engines optam por usar este arquivo para colocar opções de configuração global para o engine. É uma ideia relativamente boa, então se você quiser oferecer opções de configuração, o arquivo onde o `module` do seu engine é definido é perfeito para isso. Coloque os métodos dentro do módulo e você estará pronto para seguir em frente.

Dentro de `lib/blorgh/engine.rb` está a classe base para o engine:

```ruby
module Blorgh
  class Engine < ::Rails::Engine
    isolate_namespace Blorgh
  end
end
```

Ao herdar da classe `Rails::Engine`, esta gem notifica o Rails de que há um engine no caminho especificado e irá montar corretamente o engine dentro do aplicativo, realizando tarefas como adicionar o diretório `app` do engine ao caminho de carga para modelos, mailers, controladores e visualizações.

O método `isolate_namespace` aqui merece atenção especial. Esta chamada é responsável por isolar os controladores, modelos, rotas e outras coisas em seu próprio namespace, longe de componentes semelhantes dentro do aplicativo. Sem isso, há a possibilidade de que os componentes do engine possam "vazar" para o aplicativo, causando interrupções indesejadas, ou que componentes importantes do engine possam ser substituídos por coisas com nomes semelhantes dentro do aplicativo. Um dos exemplos de tais conflitos são os helpers. Sem chamar `isolate_namespace`, os helpers do engine seriam incluídos nos controladores de um aplicativo.

NOTA: É **altamente** recomendado que a linha `isolate_namespace` seja deixada dentro da definição da classe `Engine`. Sem ela, as classes geradas em um engine **podem** entrar em conflito com um aplicativo.

O que esse isolamento do namespace significa é que um modelo gerado por uma chamada a `bin/rails generate model`, como `bin/rails generate model article`, não será chamado de `Article`, mas sim será nomeado com namespace como `Blorgh::Article`. Além disso, a tabela para o modelo é nomeada com namespace, tornando-se `blorgh_articles`, em vez de simplesmente `articles`. Semelhante ao namespace do modelo, um controlador chamado `ArticlesController` se torna `Blorgh::ArticlesController` e as visualizações para esse controlador não estarão em `app/views/articles`, mas sim em `app/views/blorgh/articles`. Mailers, jobs e helpers também são nomeados com namespace.

Por fim, as rotas também serão isoladas dentro do engine. Esta é uma das partes mais importantes do isolamento de namespaces e é discutida posteriormente na seção [Rotas](#routes) deste guia.

#### Diretório `app`

Dentro do diretório `app`, estão os diretórios padrão `assets`, `controllers`, `helpers`, `jobs`, `mailers`, `models` e `views`, com os quais você deve estar familiarizado em um aplicativo. Vamos olhar mais para os modelos em uma seção futura, quando estivermos escrevendo o engine.

Dentro do diretório `app/assets`, há os diretórios `images` e `stylesheets`, que, novamente, você deve estar familiarizado devido à sua semelhança com um aplicativo. Uma diferença aqui, no entanto, é que cada diretório contém um subdiretório com o nome do engine. Como este engine será nomeado com namespace, seus assets também devem ser.

Dentro do diretório `app/controllers`, há um diretório `blorgh` que contém um arquivo chamado `application_controller.rb`. Este arquivo fornecerá qualquer funcionalidade comum para os controladores do engine. O diretório `blorgh` é onde os outros controladores do engine serão colocados. Ao colocá-los dentro deste diretório com namespace, você evita que eles possam entrar em conflito com controladores com nomes idênticos em outros engines ou até mesmo no aplicativo.

NOTA: A classe `ApplicationController` dentro de um engine é nomeada exatamente como um aplicativo Rails para facilitar a conversão de aplicativos em engines.
NOTA: Se a aplicação principal estiver em modo `classic`, você pode se deparar com uma situação em que o controlador do mecanismo herda do controlador da aplicação principal e não do controlador da aplicação do mecanismo. A melhor maneira de evitar isso é mudar para o modo `zeitwerk` na aplicação principal. Caso contrário, use `require_dependency` para garantir que o controlador da aplicação do mecanismo seja carregado. Por exemplo:

```ruby
# SOMENTE NECESSÁRIO NO MODO `classic`.
require_dependency "blorgh/application_controller"

module Blorgh
  class ArticlesController < ApplicationController
    # ...
  end
end
```

AVISO: Não use `require` porque isso quebrará a recarga automática de classes no ambiente de desenvolvimento - usar `require_dependency` garante que as classes sejam carregadas e descarregadas corretamente.

Assim como para `app/controllers`, você encontrará um subdiretório `blorgh` nos diretórios `app/helpers`, `app/jobs`, `app/mailers` e `app/models`, contendo o arquivo `application_*.rb` associado para reunir funcionalidades comuns. Ao colocar seus arquivos neste subdiretório e nomear seus objetos, você evita que eles possam entrar em conflito com elementos de mesmo nome em outros mecanismos ou até mesmo na aplicação.

Por fim, o diretório `app/views` contém uma pasta `layouts`, que contém um arquivo em `blorgh/application.html.erb`. Este arquivo permite especificar um layout para o mecanismo. Se este mecanismo for usado como um mecanismo independente, você adicionaria qualquer personalização ao seu layout neste arquivo, em vez do arquivo `app/views/layouts/application.html.erb` da aplicação.

Se você não quiser impor um layout aos usuários do mecanismo, poderá excluir este arquivo e referenciar um layout diferente nos controladores do mecanismo.

#### Diretório `bin`

Este diretório contém um arquivo, `bin/rails`, que permite usar os subcomandos e geradores do `rails` da mesma forma que em uma aplicação. Isso significa que você poderá gerar novos controladores e modelos para este mecanismo facilmente executando comandos como este:

```bash
$ bin/rails generate model
```

Lembre-se, é claro, de que qualquer coisa gerada com esses comandos dentro de um mecanismo que tenha `isolate_namespace` na classe `Engine` será nomeada com espaço de nomes.

#### Diretório `test`

O diretório `test` é onde os testes para o mecanismo serão colocados. Para testar o mecanismo, há uma versão reduzida de uma aplicação Rails incorporada nele em `test/dummy`. Esta aplicação irá montar o mecanismo no arquivo `test/dummy/config/routes.rb`:

```ruby
Rails.application.routes.draw do
  mount Blorgh::Engine => "/blorgh"
end
```

Esta linha monta o mecanismo no caminho `/blorgh`, tornando-o acessível apenas através da aplicação nesse caminho.

Dentro do diretório de teste, há o diretório `test/integration`, onde os testes de integração para o mecanismo devem ser colocados. Outros diretórios também podem ser criados no diretório `test`. Por exemplo, você pode desejar criar um diretório `test/models` para seus testes de modelo.

Fornecendo Funcionalidades do Mecanismo
---------------------------------------

O mecanismo abordado neste guia fornece funcionalidades de envio de artigos e comentários e segue uma linha semelhante ao [Guia de Introdução](getting_started.html), com algumas novidades.

NOTA: Para esta seção, certifique-se de executar os comandos na raiz do diretório do mecanismo `blorgh`.

### Gerando um Recurso de Artigo

A primeira coisa a gerar para um mecanismo de blog é o modelo `Article` e o controlador relacionado. Para gerar isso rapidamente, você pode usar o gerador de scaffold do Rails.

```bash
$ bin/rails generate scaffold article title:string text:text
```

Este comando irá gerar a seguinte saída:

```
invoke  active_record
create    db/migrate/[timestamp]_create_blorgh_articles.rb
create    app/models/blorgh/article.rb
invoke    test_unit
create      test/models/blorgh/article_test.rb
create      test/fixtures/blorgh/articles.yml
invoke  resource_route
 route    resources :articles
invoke  scaffold_controller
create    app/controllers/blorgh/articles_controller.rb
invoke    erb
create      app/views/blorgh/articles
create      app/views/blorgh/articles/index.html.erb
create      app/views/blorgh/articles/edit.html.erb
create      app/views/blorgh/articles/show.html.erb
create      app/views/blorgh/articles/new.html.erb
create      app/views/blorgh/articles/_form.html.erb
invoke    test_unit
create      test/controllers/blorgh/articles_controller_test.rb
create      test/system/blorgh/articles_test.rb
invoke    helper
create      app/helpers/blorgh/articles_helper.rb
invoke      test_unit
```

A primeira coisa que o gerador de scaffold faz é invocar o gerador `active_record`, que gera uma migração e um modelo para o recurso. Observe aqui, no entanto, que a migração é chamada `create_blorgh_articles` em vez do usual `create_articles`. Isso ocorre devido ao método `isolate_namespace` chamado na definição da classe `Blorgh::Engine`. O modelo aqui também está em um espaço de nomes, sendo colocado em `app/models/blorgh/article.rb` em vez de `app/models/article.rb` devido à chamada `isolate_namespace` dentro da classe `Engine`.

Em seguida, o gerador `test_unit` é invocado para este modelo, gerando um teste de modelo em `test/models/blorgh/article_test.rb` (em vez de `test/models/article_test.rb`) e um fixture em `test/fixtures/blorgh/articles.yml` (em vez de `test/fixtures/articles.yml`).

Depois disso, uma linha para o recurso é inserida no arquivo `config/routes.rb` do mecanismo. Essa linha é simplesmente `resources :articles`, transformando o arquivo `config/routes.rb` do mecanismo em:
```ruby
Blorgh::Engine.routes.draw do
  resources :articles
end
```

Observe aqui que as rotas são desenhadas no objeto `Blorgh::Engine` em vez da classe `YourApp::Application`. Isso é feito para que as rotas do engine sejam limitadas ao próprio engine e possam ser montadas em um ponto específico, como mostrado na seção [diretório de testes](#test-directory). Isso também faz com que as rotas do engine sejam isoladas das rotas que estão dentro da aplicação. A seção [Rotas](#routes) deste guia descreve isso em detalhes.

Em seguida, o gerador `scaffold_controller` é invocado, gerando um controlador chamado `Blorgh::ArticlesController` (em `app/controllers/blorgh/articles_controller.rb`) e suas visualizações relacionadas em `app/views/blorgh/articles`. Este gerador também gera testes para o controlador (`test/controllers/blorgh/articles_controller_test.rb` e `test/system/blorgh/articles_test.rb`) e um helper (`app/helpers/blorgh/articles_helper.rb`).

Tudo o que este gerador criou está devidamente nomeado. A classe do controlador é definida dentro do módulo `Blorgh`:

```ruby
module Blorgh
  class ArticlesController < ApplicationController
    # ...
  end
end
```

NOTA: A classe `ArticlesController` herda de `Blorgh::ApplicationController`, não do `ApplicationController` da aplicação.

O helper dentro de `app/helpers/blorgh/articles_helper.rb` também está nomeado:

```ruby
module Blorgh
  module ArticlesHelper
    # ...
  end
end
```

Isso ajuda a evitar conflitos com qualquer outro engine ou aplicação que também possa ter um recurso de artigo.

Você pode ver o que o engine tem até agora executando `bin/rails db:migrate` na raiz do nosso engine para executar a migração gerada pelo gerador de scaffold, e então executando `bin/rails server` em `test/dummy`. Quando você abrir `http://localhost:3000/blorgh/articles`, você verá o scaffold padrão que foi gerado. Navegue! Você acabou de gerar as primeiras funções do seu primeiro engine.

Se você preferir brincar no console, `bin/rails console` também funcionará como uma aplicação Rails. Lembre-se: o modelo `Article` está em um namespace, então para referenciá-lo você deve chamá-lo como `Blorgh::Article`.

```irb
irb> Blorgh::Article.find(1)
=> #<Blorgh::Article id: 1 ...>
```

Uma última coisa é que o recurso `articles` para este engine deve ser a raiz do engine. Sempre que alguém acessar o caminho raiz onde o engine está montado, eles devem ver uma lista de artigos. Isso pode ser feito se esta linha for inserida no arquivo `config/routes.rb` dentro do engine:

```ruby
root to: "articles#index"
```

Agora as pessoas só precisarão ir para a raiz do engine para ver todos os artigos, em vez de visitar `/articles`. Isso significa que em vez de `http://localhost:3000/blorgh/articles`, você só precisa ir para `http://localhost:3000/blorgh` agora.

### Gerando um Recurso de Comentários

Agora que o engine pode criar novos artigos, faz sentido adicionar também a funcionalidade de comentários. Para fazer isso, você precisará gerar um modelo de comentário, um controlador de comentário e, em seguida, modificar o scaffold de artigos para exibir comentários e permitir que as pessoas criem novos.

A partir da raiz do engine, execute o gerador de modelo. Diga a ele para gerar um modelo `Comment`, com a tabela relacionada tendo duas colunas: um inteiro `article_id` e uma coluna de texto `text`.

```bash
$ bin/rails generate model Comment article_id:integer text:text
```

Isso irá gerar o seguinte:

```
invoke  active_record
create    db/migrate/[timestamp]_create_blorgh_comments.rb
create    app/models/blorgh/comment.rb
invoke    test_unit
create      test/models/blorgh/comment_test.rb
create      test/fixtures/blorgh/comments.yml
```

Esta chamada do gerador irá gerar apenas os arquivos de modelo necessários, colocando os arquivos em um diretório `blorgh` e criando uma classe de modelo chamada `Blorgh::Comment`. Agora execute a migração para criar nossa tabela `blorgh_comments`:

```bash
$ bin/rails db:migrate
```

Para mostrar os comentários em um artigo, edite `app/views/blorgh/articles/show.html.erb` e adicione esta linha antes do link "Editar":

```html+erb
<h3>Comentários</h3>
<%= render @article.comments %>
```

Esta linha requer que haja uma associação `has_many` para comentários definida no modelo `Blorgh::Article`, que ainda não existe. Para definir uma, abra `app/models/blorgh/article.rb` e adicione esta linha ao modelo:

```ruby
has_many :comments
```

Fazendo com que o modelo fique assim:

```ruby
module Blorgh
  class Article < ApplicationRecord
    has_many :comments
  end
end
```

NOTA: Como o `has_many` é definido dentro de uma classe que está dentro do módulo `Blorgh`, o Rails saberá que você deseja usar o modelo `Blorgh::Comment` para esses objetos, então não é necessário especificar isso usando a opção `:class_name` aqui.

Em seguida, é necessário um formulário para que os comentários possam ser criados em um artigo. Para adicionar isso, coloque esta linha abaixo da chamada para `render @article.comments` em `app/views/blorgh/articles/show.html.erb`:

```erb
<%= render "blorgh/comments/form" %>
```

Em seguida, o partial que esta linha irá renderizar precisa existir. Crie um novo diretório em `app/views/blorgh/comments` e nele um novo arquivo chamado `_form.html.erb` que tenha este conteúdo para criar o partial necessário:
```html+erb
<h3>Novo comentário</h3>
<%= form_with model: [@article, @article.comments.build] do |form| %>
  <p>
    <%= form.label :text %><br>
    <%= form.text_area :text %>
  </p>
  <%= form.submit %>
<% end %>
```

Quando este formulário é enviado, ele vai tentar realizar uma requisição `POST`
para uma rota de `/articles/:article_id/comments` dentro do motor. Esta rota não
existe no momento, mas pode ser criada alterando a linha `resources :articles`
dentro de `config/routes.rb` para estas linhas:

```ruby
resources :articles do
  resources :comments
end
```

Isso cria uma rota aninhada para os comentários, que é o que o formulário requer.

Agora a rota existe, mas o controlador para qual esta rota vai não existe. Para
criá-lo, execute este comando a partir da raiz do motor:

```bash
$ bin/rails generate controller comments
```

Isso irá gerar as seguintes coisas:

```
create  app/controllers/blorgh/comments_controller.rb
invoke  erb
 exist    app/views/blorgh/comments
invoke  test_unit
create    test/controllers/blorgh/comments_controller_test.rb
invoke  helper
create    app/helpers/blorgh/comments_helper.rb
invoke    test_unit
```

O formulário estará fazendo uma requisição `POST` para `/articles/:article_id/comments`, que
corresponderá com a ação `create` em `Blorgh::CommentsController`. Esta
ação precisa ser criada, o que pode ser feito colocando as seguintes linhas
dentro da definição de classe em `app/controllers/blorgh/comments_controller.rb`:

```ruby
def create
  @article = Article.find(params[:article_id])
  @comment = @article.comments.create(comment_params)
  flash[:notice] = "Comentário foi criado!"
  redirect_to articles_path
end

private
  def comment_params
    params.require(:comment).permit(:text)
  end
```

Este é o último passo necessário para fazer o formulário de novo comentário funcionar. No entanto, a exibição
dos comentários ainda não está correta. Se você criar um comentário
agora, você verá este erro:

```
Missing partial blorgh/comments/_comment with {:handlers=>[:erb, :builder],
:formats=>[:html], :locale=>[:en, :en]}. Searched in:   *
"/Users/ryan/Sites/side_projects/blorgh/test/dummy/app/views"   *
"/Users/ryan/Sites/side_projects/blorgh/app/views"
```

O motor não consegue encontrar o parcial necessário para renderizar os comentários.
O Rails procura primeiro no diretório `app/views` da aplicação (`test/dummy`) e
depois no diretório `app/views` do motor. Quando não consegue encontrar, ele lança
este erro. O motor sabe procurar por `blorgh/comments/_comment` porque o
objeto do modelo que está recebendo é da classe `Blorgh::Comment`.

Este parcial será responsável por renderizar apenas o texto do comentário, por enquanto.
Crie um novo arquivo em `app/views/blorgh/comments/_comment.html.erb` e coloque esta
linha dentro dele:

```erb
<%= comment_counter + 1 %>. <%= comment.text %>
```

A variável local `comment_counter` é fornecida pela chamada `<%= render
@article.comments %>` e será definida automaticamente e incrementada
conforme itera por cada comentário. Ela é usada neste exemplo para
exibir um pequeno número ao lado de cada comentário quando ele é criado.

Isso completa a função de comentário do motor de blogs. Agora é hora de usá-lo
dentro de uma aplicação.

Integrando em uma aplicação
---------------------------

Usar um motor dentro de uma aplicação é muito fácil. Esta seção aborda como
montar o motor em uma aplicação e a configuração inicial necessária, bem como
vincular o motor a uma classe `User` fornecida pela aplicação para fornecer
propriedade para artigos e comentários dentro do motor.

### Montando o motor

Primeiro, o motor precisa ser especificado dentro do `Gemfile` da aplicação. Se
não houver uma aplicação disponível para testar isso, gere uma usando o
comando `rails new` fora do diretório do motor, assim:

```bash
$ rails new unicorn
```

Normalmente, especificar o motor dentro do `Gemfile` seria feito especificando-o
como uma gem normal.

```ruby
gem 'devise'
```

No entanto, como você está desenvolvendo o motor `blorgh` em sua máquina local,
você precisará especificar a opção `:path` em seu `Gemfile`:

```ruby
gem 'blorgh', path: 'engines/blorgh'
```

Em seguida, execute `bundle` para instalar a gem.

Como descrito anteriormente, ao colocar a gem no `Gemfile`, ela será carregada quando
o Rails for carregado. Ele primeiro requer `lib/blorgh.rb` do motor e depois
`lib/blorgh/engine.rb`, que é o arquivo que define as principais funcionalidades
do motor.

Para tornar a funcionalidade do motor acessível a partir de uma aplicação, ele
precisa ser montado no arquivo `config/routes.rb` da aplicação:

```ruby
mount Blorgh::Engine, at: "/blog"
```

Esta linha irá montar o motor em `/blog` na aplicação. Tornando-o
acessível em `http://localhost:3000/blog` quando a aplicação é executada com `bin/rails
server`.

NOTA: Outros motores, como o Devise, lidam com isso um pouco diferente, fazendo
você especificar ajudantes personalizados (como `devise_for`) nas rotas. Esses ajudantes
fazem exatamente a mesma coisa, montando partes da funcionalidade do motor em um
caminho pré-definido que pode ser personalizado.
### Configuração do Motor

O motor contém migrações para as tabelas `blorgh_articles` e `blorgh_comments` que precisam ser criadas no banco de dados da aplicação para que os modelos do motor possam consultá-las corretamente. Para copiar essas migrações para a aplicação, execute o seguinte comando a partir do diretório raiz da aplicação:

```bash
$ bin/rails blorgh:install:migrations
```

Se você tiver vários motores que precisam ter as migrações copiadas, use `railties:install:migrations` em vez disso:

```bash
$ bin/rails railties:install:migrations
```

Você pode especificar um caminho personalizado no motor de origem para as migrações, especificando MIGRATIONS_PATH.

```bash
$ bin/rails railties:install:migrations MIGRATIONS_PATH=db_blourgh
```

Se você tiver vários bancos de dados, também pode especificar o banco de dados de destino especificando DATABASE.

```bash
$ bin/rails railties:install:migrations DATABASE=animals
```

Este comando, quando executado pela primeira vez, copiará todas as migrações do motor. Quando executado novamente, ele copiará apenas as migrações que ainda não foram copiadas. A primeira execução deste comando exibirá algo como isto:

```
Copied migration [timestamp_1]_create_blorgh_articles.blorgh.rb from blorgh
Copied migration [timestamp_2]_create_blorgh_comments.blorgh.rb from blorgh
```

O primeiro timestamp (`[timestamp_1]`) será a hora atual e o segundo timestamp (`[timestamp_2]`) será a hora atual mais um segundo. O motivo disso é para que as migrações do motor sejam executadas após quaisquer migrações existentes na aplicação.

Para executar essas migrações no contexto da aplicação, basta executar `bin/rails db:migrate`. Ao acessar o motor através de `http://localhost:3000/blog`, os artigos estarão vazios. Isso ocorre porque a tabela criada dentro da aplicação é diferente da tabela criada dentro do motor. Vá em frente, brinque com o motor recém-montado. Você verá que é o mesmo que quando era apenas um motor.

Se você deseja executar migrações apenas de um motor, pode fazer isso especificando `SCOPE`:

```bash
$ bin/rails db:migrate SCOPE=blorgh
```

Isso pode ser útil se você quiser reverter as migrações do motor antes de removê-lo. Para reverter todas as migrações do motor blorgh, você pode executar um código como este:

```bash
$ bin/rails db:migrate SCOPE=blorgh VERSION=0
```

### Usando uma Classe Fornecida pela Aplicação

#### Usando um Modelo Fornecido pela Aplicação

Quando um motor é criado, pode ser necessário usar classes específicas de uma aplicação para fornecer links entre as partes do motor e as partes da aplicação. No caso do motor `blorgh`, faz muito sentido que os artigos e comentários tenham autores.

Uma aplicação típica pode ter uma classe `User` que seria usada para representar autores de um artigo ou comentário. Mas pode haver um caso em que a aplicação chame essa classe de forma diferente, como `Person`. Por esse motivo, o motor não deve codificar associações especificamente para uma classe `User`.

Para simplificar neste caso, a aplicação terá uma classe chamada `User` que representa os usuários da aplicação (vamos abordar como tornar isso configurável mais adiante). Ela pode ser gerada usando o seguinte comando dentro da aplicação:

```bash
$ bin/rails generate model user name:string
```

O comando `bin/rails db:migrate` precisa ser executado aqui para garantir que nossa aplicação tenha a tabela `users` para uso futuro.

Além disso, para simplificar, o formulário de artigos terá um novo campo de texto chamado `author_name`, onde os usuários podem optar por inserir seu nome. O motor então pegará esse nome e criará um novo objeto `User` a partir dele ou encontrará um que já tenha esse nome. O motor então associará o artigo ao objeto `User` encontrado ou criado.

Primeiro, o campo de texto `author_name` precisa ser adicionado ao parcial `app/views/blorgh/articles/_form.html.erb` dentro do motor. Isso pode ser adicionado acima do campo `title` com este código:

```html+erb
<div class="field">
  <%= form.label :author_name %><br>
  <%= form.text_field :author_name %>
</div>
```

Em seguida, precisamos atualizar nosso método `Blorgh::ArticlesController#article_params` para permitir o novo parâmetro do formulário:

```ruby
def article_params
  params.require(:article).permit(:title, :text, :author_name)
end
```

O modelo `Blorgh::Article` deve então ter algum código para converter o campo `author_name` em um objeto `User` real e associá-lo como o `author` daquele artigo antes que o artigo seja salvo. Também será necessário ter um `attr_accessor` configurado para este campo, para que os métodos setter e getter sejam definidos para ele.

Para fazer tudo isso, você precisará adicionar o `attr_accessor` para `author_name`, a associação para o autor e a chamada `before_validation` em `app/models/blorgh/article.rb`. A associação `author` será codificada para a classe `User` por enquanto.
```ruby
attr_accessor :author_name
belongs_to :author, class_name: "User"

before_validation :set_author

private
  def set_author
    self.author = User.find_or_create_by(name: author_name)
  end
```

Ao representar o objeto de associação `author` com a classe `User`, é estabelecida uma ligação entre o mecanismo e a aplicação. É necessário ter uma maneira de associar os registros na tabela `blorgh_articles` com os registros na tabela `users`. Como a associação é chamada de `author`, deve ser adicionada uma coluna `author_id` à tabela `blorgh_articles`.

Para gerar essa nova coluna, execute o seguinte comando dentro do mecanismo:

```bash
$ bin/rails generate migration add_author_id_to_blorgh_articles author_id:integer
```

NOTA: Devido ao nome da migração e à especificação da coluna após ele, o Rails saberá automaticamente que você deseja adicionar uma coluna a uma tabela específica e escreverá isso na migração para você. Você não precisa informar mais do que isso.

Essa migração precisará ser executada na aplicação. Para fazer isso, ela deve ser copiada usando o seguinte comando:

```bash
$ bin/rails blorgh:install:migrations
```

Observe que apenas _uma_ migração foi copiada aqui. Isso ocorre porque as duas primeiras migrações foram copiadas na primeira vez que esse comando foi executado.

```
NOTA A migração [timestamp]_create_blorgh_articles.blorgh.rb do blorgh foi ignorada. Já existe uma migração com o mesmo nome.
NOTA A migração [timestamp]_create_blorgh_comments.blorgh.rb do blorgh foi ignorada. Já existe uma migração com o mesmo nome.
Migração copiada [timestamp]_add_author_id_to_blorgh_articles.blorgh.rb do blorgh
```

Execute a migração usando:

```bash
$ bin/rails db:migrate
```

Agora, com todas as peças no lugar, uma ação será realizada que associará um autor - representado por um registro na tabela `users` - a um artigo, representado pela tabela `blorgh_articles` do mecanismo.

Por fim, o nome do autor deve ser exibido na página do artigo. Adicione este código acima da saída "Title" dentro de `app/views/blorgh/articles/show.html.erb`:

```html+erb
<p>
  <b>Autor:</b>
  <%= @article.author.name %>
</p>
```

#### Usando um Controlador Fornecido pela Aplicação

Como os controladores do Rails geralmente compartilham código para coisas como autenticação e acesso a variáveis de sessão, eles herdam por padrão do `ApplicationController`. No entanto, os mecanismos do Rails são limitados a serem executados independentemente da aplicação principal, então cada mecanismo recebe um `ApplicationController` específico. Esse namespace evita colisões de código, mas muitas vezes os controladores do mecanismo precisam acessar métodos do `ApplicationController` da aplicação principal. Uma maneira fácil de fornecer esse acesso é alterar o `ApplicationController` específico do mecanismo para herdar do `ApplicationController` da aplicação principal. Para o nosso mecanismo Blorgh, isso seria feito alterando o arquivo `app/controllers/blorgh/application_controller.rb` para ficar assim:

```ruby
module Blorgh
  class ApplicationController < ::ApplicationController
  end
end
```

Por padrão, os controladores do mecanismo herdam do `Blorgh::ApplicationController`. Portanto, após fazer essa alteração, eles terão acesso ao `ApplicationController` da aplicação principal, como se fizessem parte da aplicação principal.

Essa alteração requer que o mecanismo seja executado a partir de uma aplicação Rails que tenha um `ApplicationController`.

### Configurando um Mecanismo

Esta seção aborda como tornar a classe `User` configurável, seguida de dicas de configuração geral para o mecanismo.

#### Definindo Configurações de Configuração na Aplicação

O próximo passo é tornar a classe que representa um `User` na aplicação personalizável para o mecanismo. Isso ocorre porque essa classe nem sempre será `User`, como explicado anteriormente. Para tornar essa configuração personalizável, o mecanismo terá uma configuração chamada `author_class` que será usada para especificar qual classe representa os usuários dentro da aplicação.

Para definir essa configuração, você deve usar um `mattr_accessor` dentro do módulo `Blorgh` do mecanismo. Adicione esta linha em `lib/blorgh.rb` dentro do mecanismo:

```ruby
mattr_accessor :author_class
```

Este método funciona como seus irmãos, `attr_accessor` e `cattr_accessor`, mas fornece um método setter e getter no módulo com o nome especificado. Para usá-lo, ele deve ser referenciado usando `Blorgh.author_class`.

O próximo passo é alterar o modelo `Blorgh::Article` para usar essa nova configuração. Altere a associação `belongs_to` dentro deste modelo (`app/models/blorgh/article.rb`) para o seguinte:

```ruby
belongs_to :author, class_name: Blorgh.author_class
```

O método `set_author` no modelo `Blorgh::Article` também deve usar essa classe:

```ruby
self.author = Blorgh.author_class.constantize.find_or_create_by(name: author_name)
```

Para evitar ter que chamar `constantize` no resultado de `author_class` o tempo todo, você pode substituir o método getter `author_class` dentro do módulo `Blorgh` no arquivo `lib/blorgh.rb` para sempre chamar `constantize` no valor salvo antes de retornar o resultado:
```ruby
def self.author_class
  @@author_class.constantize
end
```

Isso então transformaria o código acima para `set_author` em:

```ruby
self.author = Blorgh.author_class.find_or_create_by(name: author_name)
```

Resultando em algo um pouco mais curto e mais implícito em seu comportamento. O
método `author_class` deve sempre retornar um objeto `Class`.

Como alteramos o método `author_class` para retornar uma `Class` em vez de uma
`String`, também devemos modificar nossa definição `belongs_to` no modelo `Blorgh::Article`:

```ruby
belongs_to :author, class_name: Blorgh.author_class.to_s
```

Para definir essa configuração dentro da aplicação, um inicializador deve ser usado. Ao usar um inicializador, a configuração será definida antes de a aplicação iniciar e chamar os modelos do mecanismo, que podem depender dessa configuração existente.

Crie um novo inicializador em `config/initializers/blorgh.rb` dentro da aplicação onde o mecanismo `blorgh` está instalado e coloque este conteúdo nele:

```ruby
Blorgh.author_class = "User"
```

ATENÇÃO: É muito importante aqui usar a versão `String` da classe, em vez da própria classe. Se você usar a classe, o Rails tentará carregar essa classe e, em seguida, referenciar a tabela relacionada. Isso pode levar a problemas se a tabela ainda não existir. Portanto, uma `String` deve ser usada e depois convertida em uma classe usando `constantize` no mecanismo posteriormente.

Vá em frente e tente criar um novo artigo. Você verá que funciona exatamente da mesma maneira que antes, exceto que desta vez o mecanismo está usando a configuração em `config/initializers/blorgh.rb` para saber qual é a classe.

Agora não há dependências estritas sobre qual é a classe, apenas sobre qual deve ser a API para a classe. O mecanismo simplesmente requer que essa classe defina um método `find_or_create_by` que retorna um objeto dessa classe, para ser associado a um artigo quando ele é criado. Esse objeto, é claro, deve ter algum tipo de identificador pelo qual possa ser referenciado.

#### Configuração Geral do Mecanismo

Dentro de um mecanismo, pode chegar um momento em que você deseja usar coisas como
inicializadores, internacionalização ou outras opções de configuração. A ótima
notícia é que essas coisas são totalmente possíveis, porque um mecanismo Rails compartilha
muita da mesma funcionalidade de uma aplicação Rails. Na verdade, a funcionalidade de uma
aplicação Rails é na verdade um superset do que é fornecido pelos mecanismos!

Se você deseja usar um inicializador - código que deve ser executado antes de o mecanismo ser
carregado - o lugar para isso é a pasta `config/initializers`. A funcionalidade deste diretório é explicada na seção [Inicializadores](configuring.html#initializers) do guia de Configuração e funciona exatamente da mesma maneira que o diretório `config/initializers` dentro de uma aplicação. O mesmo vale se você quiser usar um inicializador padrão.

Para localidades, basta colocar os arquivos de localidade no diretório `config/locales`, assim como você faria em uma aplicação.

Testando um Mecanismo
-----------------

Quando um mecanismo é gerado, há uma aplicação dummy menor criada dentro
dele em `test/dummy`. Esta aplicação é usada como um ponto de montagem para o mecanismo,
para tornar o teste do mecanismo extremamente simples. Você pode estender esta aplicação por
gerar controladores, modelos ou visualizações de dentro do diretório e, em seguida, usar
esses para testar seu mecanismo.

O diretório `test` deve ser tratado como um ambiente de teste Rails típico,
permitindo testes unitários, funcionais e de integração.

### Testes Funcionais

Um aspecto a ser considerado ao escrever testes funcionais é que
os testes serão executados em uma aplicação - a aplicação `test/dummy` -
em vez do seu mecanismo. Isso ocorre devido à configuração do ambiente de teste; um mecanismo precisa de uma aplicação como host para testar sua funcionalidade principal, especialmente controladores. Isso significa que, se você fizer um
`GET` típico para um controlador em um teste funcional de controlador como este:

```ruby
module Blorgh
  class FooControllerTest < ActionDispatch::IntegrationTest
    include Engine.routes.url_helpers

    def test_index
      get foos_url
      # ...
    end
  end
end
```

Pode não funcionar corretamente. Isso ocorre porque a aplicação não sabe como
rotear essas solicitações para o mecanismo, a menos que você diga explicitamente **como**. Para
fazer isso, você deve definir a variável de instância `@routes` como o conjunto de rotas do mecanismo
em seu código de configuração:

```ruby
module Blorgh
  class FooControllerTest < ActionDispatch::IntegrationTest
    include Engine.routes.url_helpers

    setup do
      @routes = Engine.routes
    end

    def test_index
      get foos_url
      # ...
    end
  end
end
```
Isso informa à aplicação que você ainda deseja realizar uma solicitação `GET` para a ação `index` deste controlador, mas deseja usar a rota do mecanismo para chegar lá, em vez da rota da aplicação.

Isso também garante que os auxiliares de URL do mecanismo funcionem como esperado nos seus testes.

Melhorando a Funcionalidade do Mecanismo
----------------------------------------

Esta seção explica como adicionar e/ou substituir a funcionalidade MVC do mecanismo na aplicação principal do Rails.

### Substituindo Modelos e Controladores

Os modelos e controladores do mecanismo podem ser reabertos pela aplicação principal para estendê-los ou decorá-los.

As substituições podem ser organizadas em um diretório dedicado `app/overrides`, ignorado pelo carregador automático e pré-carregado em um retorno de chamada `to_prepare`:

```ruby
# config/application.rb
module MyApp
  class Application < Rails::Application
    # ...

    overrides = "#{Rails.root}/app/overrides"
    Rails.autoloaders.main.ignore(overrides)

    config.to_prepare do
      Dir.glob("#{overrides}/**/*_override.rb").sort.each do |override|
        load override
      end
    end
  end
end
```

#### Reabrindo Classes Existente Usando `class_eval`

Por exemplo, para substituir o modelo do mecanismo

```ruby
# Blorgh/app/models/blorgh/article.rb
module Blorgh
  class Article < ApplicationRecord
    # ...
  end
end
```

você só precisa criar um arquivo que _reabra_ essa classe:

```ruby
# MyApp/app/overrides/models/blorgh/article_override.rb
Blorgh::Article.class_eval do
  # ...
end
```

É muito importante que a substituição _reabra_ a classe ou módulo. Usar as palavras-chave `class` ou `module` as definiria se elas não estivessem em memória, o que seria incorreto porque a definição está no mecanismo. Usar `class_eval` como mostrado acima garante que você está reabrindo.

#### Reabrindo Classes Existente Usando ActiveSupport::Concern

Usar `Class#class_eval` é ótimo para ajustes simples, mas para modificações de classe mais complexas, você pode considerar usar [`ActiveSupport::Concern`](https://api.rubyonrails.org/classes/ActiveSupport/Concern.html).
ActiveSupport::Concern gerencia a ordem de carregamento de módulos e classes dependentes interligados em tempo de execução, permitindo modularizar significativamente seu código.

**Adicionando** `Article#time_since_created` e **Substituindo** `Article#summary`:

```ruby
# MyApp/app/models/blorgh/article.rb

class Blorgh::Article < ApplicationRecord
  include Blorgh::Concerns::Models::Article

  def time_since_created
    Time.current - created_at
  end

  def summary
    "#{title} - #{truncate(text)}"
  end
end
```

```ruby
# Blorgh/app/models/blorgh/article.rb
module Blorgh
  class Article < ApplicationRecord
    include Blorgh::Concerns::Models::Article
  end
end
```

```ruby
# Blorgh/lib/concerns/models/article.rb

module Blorgh::Concerns::Models::Article
  extend ActiveSupport::Concern

  # `included do` faz com que o bloco seja avaliado no contexto
  # em que o módulo é incluído (ou seja, Blorgh::Article),
  # em vez de no próprio módulo.
  included do
    attr_accessor :author_name
    belongs_to :author, class_name: "User"

    before_validation :set_author

    private
      def set_author
        self.author = User.find_or_create_by(name: author_name)
      end
  end

  def summary
    "#{title}"
  end

  module ClassMethods
    def some_class_method
      'some class method string'
    end
  end
end
```

### Carregamento Automático e Mecanismos

Consulte o guia [Carregamento Automático e Recarregamento de Constantes](autoloading_and_reloading_constants.html#autoloading-and-engines) para obter mais informações sobre carregamento automático e mecanismos.

### Substituindo Visualizações

Quando o Rails procura uma visualização para renderizar, ele primeiro procura no diretório `app/views` da aplicação. Se não encontrar a visualização lá, ele verificará nos diretórios `app/views` de todos os mecanismos que possuem esse diretório.

Quando a aplicação é solicitada a renderizar a visualização para a ação `index` do `Blorgh::ArticlesController`, ela primeiro procura pelo caminho `app/views/blorgh/articles/index.html.erb` dentro da aplicação. Se não encontrar, ela procurará dentro do mecanismo.

Você pode substituir essa visualização na aplicação simplesmente criando um novo arquivo em `app/views/blorgh/articles/index.html.erb`. Em seguida, você pode alterar completamente o que essa visualização normalmente exibiria.

Experimente fazer isso agora criando um novo arquivo em `app/views/blorgh/articles/index.html.erb` e coloque este conteúdo nele:

```html+erb
<h1>Artigos</h1>
<%= link_to "Novo Artigo", new_article_path %>
<% @articles.each do |article| %>
  <h2><%= article.title %></h2>
  <small>Por <%= article.author %></small>
  <%= simple_format(article.text) %>
  <hr>
<% end %>
```

### Rotas

As rotas dentro de um mecanismo são isoladas da aplicação por padrão. Isso é feito pela chamada `isolate_namespace` dentro da classe `Engine`. Isso significa essencialmente que a aplicação e seus mecanismos podem ter rotas com nomes idênticos e elas não entrarão em conflito.

As rotas dentro de um mecanismo são definidas na classe `Engine` dentro de `config/routes.rb`, assim:

```ruby
Blorgh::Engine.routes.draw do
  resources :articles
end
```

Ao ter rotas isoladas como essa, se você desejar vincular a uma área de um mecanismo de dentro de uma aplicação, precisará usar o método de proxy de roteamento do mecanismo. Chamadas a métodos de roteamento normais, como `articles_path`, podem acabar indo para locais indesejados se tanto a aplicação quanto o mecanismo tiverem um auxiliar com esse nome.

Por exemplo, o seguinte exemplo iria para `articles_path` da aplicação se esse modelo fosse renderizado a partir da aplicação, ou para `articles_path` do mecanismo se fosse renderizado a partir do mecanismo:
```erb
<%= link_to "Artigos do blog", articles_path %>
```

Para fazer com que essa rota sempre use o método auxiliar de roteamento `articles_path` do engine, devemos chamar o método no método de proxy de roteamento que compartilha o mesmo nome do engine.

```erb
<%= link_to "Artigos do blog", blorgh.articles_path %>
```

Se você deseja fazer referência à aplicação dentro do engine de maneira semelhante, use o auxiliar `main_app`:

```erb
<%= link_to "Início", main_app.root_path %>
```

Se você usar isso dentro de um engine, ele sempre irá para a raiz da aplicação. Se você deixar de fora a chamada do método de proxy de roteamento `main_app`, ele poderá potencialmente ir para a raiz do engine ou da aplicação, dependendo de onde foi chamado.

Se um template renderizado de dentro de um engine tentar usar um dos métodos auxiliares de roteamento da aplicação, pode resultar em uma chamada de método indefinida. Se você encontrar esse problema, verifique se não está tentando chamar os métodos de roteamento da aplicação sem o prefixo `main_app` de dentro do engine.

### Ativos

Os ativos dentro de um engine funcionam da mesma maneira que em uma aplicação completa. Como a classe do engine herda de `Rails::Engine`, a aplicação saberá procurar ativos nos diretórios `app/assets` e `lib/assets` do engine.

Assim como todos os outros componentes de um engine, os ativos devem ser namespaceados. Isso significa que, se você tiver um ativo chamado `style.css`, ele deve ser colocado em `app/assets/stylesheets/[nome do engine]/style.css`, em vez de `app/assets/stylesheets/style.css`. Se esse ativo não estiver namespaceado, existe a possibilidade de que a aplicação hospedeira tenha um ativo com o mesmo nome, nesse caso, o ativo da aplicação terá precedência e o do engine será ignorado.

Imagine que você tenha um ativo localizado em `app/assets/stylesheets/blorgh/style.css`. Para incluir esse ativo em uma aplicação, basta usar `stylesheet_link_tag` e fazer referência ao ativo como se estivesse dentro do engine:

```erb
<%= stylesheet_link_tag "blorgh/style.css" %>
```

Você também pode especificar esses ativos como dependências de outros ativos usando declarações de require do Asset Pipeline em arquivos processados:

```css
/*
 *= require blorgh/style
 */
```

INFO. Lembre-se de que, para usar linguagens como Sass ou CoffeeScript, você deve adicionar a biblioteca relevante ao arquivo `.gemspec` do seu engine.

### Separar Ativos e Pré-compilação

Existem algumas situações em que os ativos do seu engine não são necessários para a aplicação hospedeira. Por exemplo, digamos que você tenha criado uma funcionalidade de administração que só existe para o seu engine. Nesse caso, a aplicação hospedeira não precisa requerer `admin.css` ou `admin.js`. Apenas o layout de administração do gem precisa desses ativos. Não faz sentido para a aplicação hospedeira incluir `"blorgh/admin.css"` em seus estilos. Nessa situação, você deve definir explicitamente esses ativos para pré-compilação. Isso informa ao Sprockets para adicionar os ativos do seu engine quando o comando `bin/rails assets:precompile` for acionado.

Você pode definir os ativos para pré-compilação em `engine.rb`:

```ruby
initializer "blorgh.assets.precompile" do |app|
  app.config.assets.precompile += %w( admin.js admin.css )
end
```

Para obter mais informações, leia o guia [Asset Pipeline](asset_pipeline.html).

### Outras Dependências de Gem

As dependências de gem dentro de um engine devem ser especificadas no arquivo `.gemspec` na raiz do engine. O motivo é que o engine pode ser instalado como uma gem. Se as dependências fossem especificadas no `Gemfile`, elas não seriam reconhecidas por uma instalação de gem tradicional e, portanto, não seriam instaladas, causando mau funcionamento do engine.

Para especificar uma dependência que deve ser instalada com o engine durante uma instalação de gem tradicional, especifique-a dentro do bloco `Gem::Specification` no arquivo `.gemspec` do engine:

```ruby
s.add_dependency "moo"
```

Para especificar uma dependência que deve ser instalada apenas como uma dependência de desenvolvimento da aplicação, especifique-a assim:

```ruby
s.add_development_dependency "moo"
```

Ambos os tipos de dependências serão instalados quando `bundle install` for executado dentro da aplicação. As dependências de desenvolvimento para a gem só serão usadas quando o desenvolvimento e os testes do engine estiverem em execução.

Observe que, se você quiser exigir imediatamente as dependências quando o engine for exigido, você deve exigir antes da inicialização do engine. Por exemplo:

```ruby
require "other_engine/engine"
require "yet_another_engine/engine"

module MyEngine
  class Engine < ::Rails::Engine
  end
end
```

Hooks de Carregamento e Configuração
----------------------------

O código Rails muitas vezes pode ser referenciado no carregamento de uma aplicação. O Rails é responsável pela ordem de carregamento desses frameworks, então, quando você carrega frameworks, como `ActiveRecord::Base`, prematuramente, você está violando um contrato implícito que sua aplicação tem com o Rails. Além disso, ao carregar código como `ActiveRecord::Base` na inicialização da sua aplicação, você está carregando frameworks inteiros que podem retardar o tempo de inicialização e causar conflitos com a ordem de carregamento e inicialização da sua aplicação.
Hooks de carregamento e configuração são a API que permite conectar-se a esse processo de inicialização sem violar o contrato de carregamento com o Rails. Isso também ajudará a mitigar a degradação do desempenho de inicialização e evitar conflitos.

### Evitando o Carregamento de Frameworks do Rails

Como o Ruby é uma linguagem dinâmica, alguns códigos farão com que diferentes frameworks do Rails sejam carregados. Considere este trecho, por exemplo:

```ruby
ActiveRecord::Base.include(MyActiveRecordHelper)
```

Este trecho significa que quando este arquivo for carregado, ele encontrará `ActiveRecord::Base`. Esse encontro faz com que o Ruby procure a definição dessa constante e a exija. Isso faz com que todo o framework Active Record seja carregado na inicialização.

`ActiveSupport.on_load` é um mecanismo que pode ser usado para adiar o carregamento de código até que ele seja realmente necessário. O trecho acima pode ser alterado para:

```ruby
ActiveSupport.on_load(:active_record) do
  include MyActiveRecordHelper
end
```

Este novo trecho incluirá `MyActiveRecordHelper` apenas quando `ActiveRecord::Base` for carregado.

### Quando os Hooks são chamados?

No framework Rails, esses hooks são chamados quando uma biblioteca específica é carregada. Por exemplo, quando `ActionController::Base` é carregado, o hook `:action_controller_base` é chamado. Isso significa que todas as chamadas `ActiveSupport.on_load` com hooks `:action_controller_base` serão chamadas no contexto de `ActionController::Base` (ou seja, `self` será um `ActionController::Base`).

### Modificando o Código para Usar Hooks de Carregamento

Modificar o código geralmente é simples. Se você tiver uma linha de código que se refere a um framework do Rails, como `ActiveRecord::Base`, você pode envolver esse código em um hook de carregamento.

**Modificando chamadas para `include`**

```ruby
ActiveRecord::Base.include(MyActiveRecordHelper)
```

se torna

```ruby
ActiveSupport.on_load(:active_record) do
  # self se refere a ActiveRecord::Base aqui,
  # então podemos chamar .include
  include MyActiveRecordHelper
end
```

**Modificando chamadas para `prepend`**

```ruby
ActionController::Base.prepend(MyActionControllerHelper)
```

se torna

```ruby
ActiveSupport.on_load(:action_controller_base) do
  # self se refere a ActionController::Base aqui,
  # então podemos chamar .prepend
  prepend MyActionControllerHelper
end
```

**Modificando chamadas para métodos de classe**

```ruby
ActiveRecord::Base.include_root_in_json = true
```

se torna

```ruby
ActiveSupport.on_load(:active_record) do
  # self se refere a ActiveRecord::Base aqui
  self.include_root_in_json = true
end
```

### Hooks de Carregamento Disponíveis

Estes são os hooks de carregamento que você pode usar em seu próprio código. Para conectar-se ao processo de inicialização de uma das seguintes classes, use o hook disponível.

| Classe                                | Hook                                 |
| -------------------------------------| ------------------------------------ |
| `ActionCable`                        | `action_cable`                       |
| `ActionCable::Channel::Base`         | `action_cable_channel`               |
| `ActionCable::Connection::Base`      | `action_cable_connection`            |
| `ActionCable::Connection::TestCase`  | `action_cable_connection_test_case`  |
| `ActionController::API`              | `action_controller_api`              |
| `ActionController::API`              | `action_controller`                  |
| `ActionController::Base`             | `action_controller_base`             |
| `ActionController::Base`             | `action_controller`                  |
| `ActionController::TestCase`         | `action_controller_test_case`        |
| `ActionDispatch::IntegrationTest`    | `action_dispatch_integration_test`   |
| `ActionDispatch::Response`           | `action_dispatch_response`           |
| `ActionDispatch::Request`            | `action_dispatch_request`            |
| `ActionDispatch::SystemTestCase`     | `action_dispatch_system_test_case`   |
| `ActionMailbox::Base`                | `action_mailbox`                     |
| `ActionMailbox::InboundEmail`        | `action_mailbox_inbound_email`       |
| `ActionMailbox::Record`              | `action_mailbox_record`              |
| `ActionMailbox::TestCase`            | `action_mailbox_test_case`           |
| `ActionMailer::Base`                 | `action_mailer`                      |
| `ActionMailer::TestCase`             | `action_mailer_test_case`            |
| `ActionText::Content`                | `action_text_content`                |
| `ActionText::Record`                 | `action_text_record`                 |
| `ActionText::RichText`               | `action_text_rich_text`              |
| `ActionText::EncryptedRichText`      | `action_text_encrypted_rich_text`    |
| `ActionView::Base`                   | `action_view`                        |
| `ActionView::TestCase`               | `action_view_test_case`              |
| `ActiveJob::Base`                    | `active_job`                         |
| `ActiveJob::TestCase`                | `active_job_test_case`               |
| `ActiveRecord::Base`                 | `active_record`                      |
| `ActiveRecord::TestFixtures`         | `active_record_fixtures`             |
| `ActiveRecord::ConnectionAdapters::PostgreSQLAdapter`    | `active_record_postgresqladapter`    |
| `ActiveRecord::ConnectionAdapters::Mysql2Adapter`        | `active_record_mysql2adapter`        |
| `ActiveRecord::ConnectionAdapters::TrilogyAdapter`       | `active_record_trilogyadapter`       |
| `ActiveRecord::ConnectionAdapters::SQLite3Adapter`       | `active_record_sqlite3adapter`       |
| `ActiveStorage::Attachment`          | `active_storage_attachment`          |
| `ActiveStorage::VariantRecord`       | `active_storage_variant_record`      |
| `ActiveStorage::Blob`                | `active_storage_blob`                |
| `ActiveStorage::Record`              | `active_storage_record`              |
| `ActiveSupport::TestCase`            | `active_support_test_case`           |
| `i18n`                               | `i18n`                               |

### Hooks de Configuração Disponíveis

Hooks de configuração não se conectam a nenhum framework específico, mas são executados no contexto de toda a aplicação.

| Hook                   | Caso de Uso                                                                       |
| ---------------------- | --------------------------------------------------------------------------------- |
| `before_configuration` | Primeiro bloco configurável a ser executado. Chamado antes de qualquer inicializador. |
| `before_initialize`    | Segundo bloco configurável a ser executado. Chamado antes da inicialização dos frameworks. |
| `before_eager_load`    | Terceiro bloco configurável a ser executado. Não é executado se [`config.eager_load`][] for definido como false. |
| `after_initialize`     | Último bloco configurável a ser executado. Chamado após a inicialização dos frameworks. |

Hooks de configuração podem ser chamados na classe Engine.

```ruby
module Blorgh
  class Engine < ::Rails::Engine
    config.before_configuration do
      puts 'Eu sou chamado antes de qualquer inicializador'
    end
  end
end
```
[`config.eager_load`]: configuring.html#config-eager-load
