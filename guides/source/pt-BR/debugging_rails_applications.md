**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 3cf93e3667cdacd242332d2d352d53fa
Depurando Aplicações Rails
============================

Este guia apresenta técnicas para depurar aplicações Ruby on Rails.

Após ler este guia, você saberá:

* O propósito da depuração.
* Como encontrar problemas e questões em sua aplicação que seus testes não estão identificando.
* As diferentes maneiras de depurar.
* Como analisar o rastreamento de pilha.

--------------------------------------------------------------------------------

Helpers de Visualização para Depuração
--------------------------

Uma tarefa comum é inspecionar o conteúdo de uma variável. O Rails fornece três maneiras diferentes de fazer isso:

* `debug`
* `to_yaml`
* `inspect`

### `debug`

O helper `debug` retornará uma tag \<pre> que renderiza o objeto usando o formato YAML. Isso gerará dados legíveis por humanos a partir de qualquer objeto. Por exemplo, se você tiver este código em uma view:

```html+erb
<%= debug @article %>
<p>
  <b>Título:</b>
  <%= @article.title %>
</p>
```

Você verá algo como isso:

```yaml
--- !ruby/object Article
attributes:
  updated_at: 2008-09-05 22:55:47
  body: É um guia muito útil para depurar sua aplicação Rails.
  title: Guia de depuração do Rails
  published: t
  id: "1"
  created_at: 2008-09-05 22:55:47
attributes_cache: {}


Título: Guia de depuração do Rails
```

### `to_yaml`

Alternativamente, chamando `to_yaml` em qualquer objeto o converte para YAML. Você pode passar esse objeto convertido para o método helper `simple_format` para formatar a saída. É assim que o `debug` faz sua mágica.

```html+erb
<%= simple_format @article.to_yaml %>
<p>
  <b>Título:</b>
  <%= @article.title %>
</p>
```

O código acima renderizará algo como isso:

```yaml
--- !ruby/object Article
attributes:
updated_at: 2008-09-05 22:55:47
body: É um guia muito útil para depurar sua aplicação Rails.
title: Guia de depuração do Rails
published: t
id: "1"
created_at: 2008-09-05 22:55:47
attributes_cache: {}

Título: Guia de depuração do Rails
```

### `inspect`

Outro método útil para exibir valores de objetos é `inspect`, especialmente ao trabalhar com arrays ou hashes. Isso imprimirá o valor do objeto como uma string. Por exemplo:

```html+erb
<%= [1, 2, 3, 4, 5].inspect %>
<p>
  <b>Título:</b>
  <%= @article.title %>
</p>
```

Irá renderizar:

```
[1, 2, 3, 4, 5]

Título: Guia de depuração do Rails
```

O Logger
----------

Também pode ser útil salvar informações em arquivos de log em tempo de execução. O Rails mantém um arquivo de log separado para cada ambiente de execução.

### O que é o Logger?

O Rails utiliza a classe `ActiveSupport::Logger` para escrever informações de log. Outros loggers, como o `Log4r`, também podem ser substituídos.

Você pode especificar um logger alternativo em `config/application.rb` ou em qualquer outro arquivo de ambiente, por exemplo:

```ruby
config.logger = Logger.new(STDOUT)
config.logger = Log4r::Logger.new("Application Log")
```

Ou na seção `Initializer`, adicione _qualquer_ um dos seguintes

```ruby
Rails.logger = Logger.new(STDOUT)
Rails.logger = Log4r::Logger.new("Application Log")
```

DICA: Por padrão, cada log é criado em `Rails.root/log/` e o arquivo de log tem o nome do ambiente em que a aplicação está sendo executada.

### Níveis de Log

Quando algo é registrado, é impresso no log correspondente se o nível de log da mensagem for igual ou maior que o nível de log configurado. Se você quiser saber o nível de log atual, pode chamar o método `Rails.logger.level`.

Os níveis de log disponíveis são: `:debug`, `:info`, `:warn`, `:error`, `:fatal` e `:unknown`, correspondendo aos números de nível de log de 0 a 5, respectivamente. Para alterar o nível de log padrão, use.
```ruby
config.log_level = :warn # Em qualquer inicializador de ambiente, ou
Rails.logger.level = 0 # a qualquer momento
```

Isso é útil quando você deseja fazer log em desenvolvimento ou em staging sem inundar o log de produção com informações desnecessárias.

DICA: O nível de log padrão do Rails é `:debug`. No entanto, ele é definido como `:info` para o ambiente `production` no arquivo `config/environments/production.rb` gerado por padrão.

### Enviando Mensagens

Para escrever no log atual, use o método `logger.(debug|info|warn|error|fatal|unknown)` dentro de um controller, model ou mailer:

```ruby
logger.debug "Atributos da pessoa: #{@person.attributes}"
logger.info "Processando a requisição..."
logger.fatal "Encerrando a aplicação, erro irreparável!!!"
```

Aqui está um exemplo de um método com logging adicional:

```ruby
class ArticlesController < ApplicationController
  # ...

  def create
    @article = Article.new(article_params)
    logger.debug "Novo artigo: #{@article.attributes}"
    logger.debug "O artigo deve ser válido: #{@article.valid?}"

    if @article.save
      logger.debug "O artigo foi salvo e agora o usuário será redirecionado..."
      redirect_to @article, notice: 'Artigo criado com sucesso.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  # ...

  private
    def article_params
      params.require(:article).permit(:title, :body, :published)
    end
end
```

Aqui está um exemplo do log gerado quando essa ação do controller é executada:

```
Started POST "/articles" for 127.0.0.1 at 2018-10-18 20:09:23 -0400
Processing by ArticlesController#create as HTML
  Parameters: {"utf8"=>"✓", "authenticity_token"=>"XLveDrKzF1SwaiNRPTaMtkrsTzedtebPPkmxEFIU0ordLjICSnXsSNfrdMa4ccyBjuGwnnEiQhEoMN6H1Gtz3A==", "article"=>{"title"=>"Debugging Rails", "body"=>"I'm learning how to print in logs.", "published"=>"0"}, "commit"=>"Create Article"}
Novo artigo: {"id"=>nil, "title"=>"Debugging Rails", "body"=>"I'm learning how to print in logs.", "published"=>false, "created_at"=>nil, "updated_at"=>nil}
O artigo deve ser válido: true
   (0.0ms)  begin transaction
  ↳ app/controllers/articles_controller.rb:31
  Article Create (0.5ms)  INSERT INTO "articles" ("title", "body", "published", "created_at", "updated_at") VALUES (?, ?, ?, ?, ?)  [["title", "Debugging Rails"], ["body", "I'm learning how to print in logs."], ["published", 0], ["created_at", "2018-10-19 00:09:23.216549"], ["updated_at", "2018-10-19 00:09:23.216549"]]
  ↳ app/controllers/articles_controller.rb:31
   (2.3ms)  commit transaction
  ↳ app/controllers/articles_controller.rb:31
O artigo foi salvo e agora o usuário será redirecionado...
Redirected to http://localhost:3000/articles/1
Completed 302 Found in 4ms (ActiveRecord: 0.8ms)
```

Adicionar logging adicional como este torna fácil procurar por comportamentos inesperados ou incomuns nos logs. Se você adicionar logging adicional, certifique-se de usar níveis de log sensatos para evitar encher seus logs de produção com informações triviais.

### Logs Verbosos de Consultas

Ao analisar a saída de consultas de banco de dados nos logs, pode não ficar imediatamente claro por que várias consultas de banco de dados são acionadas quando um único método é chamado:

```
irb(main):001:0> Article.pamplemousse
  Article Load (0.4ms)  SELECT "articles".* FROM "articles"
  Comment Load (0.2ms)  SELECT "comments".* FROM "comments" WHERE "comments"."article_id" = ?  [["article_id", 1]]
  Comment Load (0.1ms)  SELECT "comments".* FROM "comments" WHERE "comments"."article_id" = ?  [["article_id", 2]]
  Comment Load (0.1ms)  SELECT "comments".* FROM "comments" WHERE "comments"."article_id" = ?  [["article_id", 3]]
=> #<Comment id: 2, author: "1", body: "Well, actually...", article_id: 1, created_at: "2018-10-19 00:56:10", updated_at: "2018-10-19 00:56:10">
```

Após executar `ActiveRecord.verbose_query_logs = true` na sessão `bin/rails console` para habilitar logs verbosos de consultas e executar o método novamente, fica óbvio qual linha de código está gerando todas essas chamadas de banco de dados discretas:

```
irb(main):003:0> Article.pamplemousse
  Article Load (0.2ms)  SELECT "articles".* FROM "articles"
  ↳ app/models/article.rb:5
  Comment Load (0.1ms)  SELECT "comments".* FROM "comments" WHERE "comments"."article_id" = ?  [["article_id", 1]]
  ↳ app/models/article.rb:6
  Comment Load (0.1ms)  SELECT "comments".* FROM "comments" WHERE "comments"."article_id" = ?  [["article_id", 2]]
  ↳ app/models/article.rb:6
  Comment Load (0.1ms)  SELECT "comments".* FROM "comments" WHERE "comments"."article_id" = ?  [["article_id", 3]]
  ↳ app/models/article.rb:6
=> #<Comment id: 2, author: "1", body: "Well, actually...", article_id: 1, created_at: "2018-10-19 00:56:10", updated_at: "2018-10-19 00:56:10">
```
Abaixo de cada declaração de banco de dados, você pode ver setas apontando para o nome do arquivo de origem específico (e número da linha) do método que resultou em uma chamada ao banco de dados. Isso pode ajudar a identificar e resolver problemas de desempenho causados por consultas N+1: consultas únicas ao banco de dados que geram várias consultas adicionais.

Os registros de consulta detalhados estão habilitados por padrão nos logs do ambiente de desenvolvimento após o Rails 5.2.

AVISO: Recomendamos não usar essa configuração em ambientes de produção. Ela depende do método `Kernel#caller` do Ruby, que tende a alocar muita memória para gerar rastreamentos de pilha de chamadas de método. Use tags de log de consulta (veja abaixo) em vez disso.

### Registros de Enfileiramento Detalhados

Semelhante aos "Registros de Consulta Detalhados" acima, permite imprimir locais de origem de métodos que enfileiram trabalhos em segundo plano.

Ele está habilitado por padrão no desenvolvimento. Para habilitar em outros ambientes, adicione em `application.rb` ou qualquer inicializador de ambiente:

```rb
config.active_job.verbose_enqueue_logs = true
```

Assim como os registros de consulta detalhados, não é recomendado para uso em ambientes de produção.

Comentários de Consulta SQL
------------------

As declarações SQL podem ser comentadas com tags contendo informações em tempo de execução, como o nome do controlador ou trabalho, para rastrear consultas problemáticas até a área da aplicação que gerou essas declarações. Isso é útil quando você está registrando consultas lentas (por exemplo, [MySQL](https://dev.mysql.com/doc/refman/en/slow-query-log.html), [PostgreSQL](https://www.postgresql.org/docs/current/runtime-config-logging.html#GUC-LOG-MIN-DURATION-STATEMENT)),
visualizando consultas em execução ou para ferramentas de rastreamento de ponta a ponta.

Para habilitar, adicione em `application.rb` ou qualquer inicializador de ambiente:

```rb
config.active_record.query_log_tags_enabled = true
```

Por padrão, o nome da aplicação, o nome e a ação do controlador ou o nome do trabalho são registrados. O
formato padrão é [SQLCommenter](https://open-telemetry.github.io/opentelemetry-sqlcommenter/). Por exemplo:

```
Article Load (0.2ms)  SELECT "articles".* FROM "articles" /*application='Blog',controller='articles',action='index'*/

Article Update (0.3ms)  UPDATE "articles" SET "title" = ?, "updated_at" = ? WHERE "posts"."id" = ? /*application='Blog',job='ImproveTitleJob'*/  [["title", "Improved Rails debugging guide"], ["updated_at", "2022-10-16 20:25:40.091371"], ["id", 1]]
```

O comportamento de [`ActiveRecord::QueryLogs`](https://api.rubyonrails.org/classes/ActiveRecord/QueryLogs.html) pode ser
modificado para incluir qualquer coisa que ajude a conectar os pontos da consulta SQL, como ids de solicitação e trabalho para
logs de aplicativos, identificadores de conta e locatários, etc.

### Registros com Tags

Ao executar aplicativos multiusuário e multi-conta, muitas vezes é útil
poder filtrar os logs usando algumas regras personalizadas. `TaggedLogging`
no Active Support ajuda você a fazer exatamente isso, marcando as linhas de log com subdomínios, ids de solicitação e qualquer outra coisa para ajudar na depuração dessas aplicações.

```ruby
logger = ActiveSupport::TaggedLogging.new(Logger.new(STDOUT))
logger.tagged("BCX") { logger.info "Stuff" }                            # Registra "[BCX] Stuff"
logger.tagged("BCX", "Jason") { logger.info "Stuff" }                   # Registra "[BCX] [Jason] Stuff"
logger.tagged("BCX") { logger.tagged("Jason") { logger.info "Stuff" } } # Registra "[BCX] [Jason] Stuff"
```

### Impacto dos Logs no Desempenho

O registro sempre terá um pequeno impacto no desempenho do seu aplicativo Rails,
especialmente ao registrar em disco. Além disso, existem algumas sutilezas:

Usar o nível `:debug` terá um impacto maior no desempenho do que `:fatal`,
pois um número muito maior de strings está sendo avaliado e gravado na
saída do log (por exemplo, disco).

Outra armadilha potencial é fazer muitas chamadas para `Logger` no seu código:

```ruby
logger.debug "Person attributes hash: #{@person.attributes.inspect}"
```

No exemplo acima, haverá um impacto no desempenho, mesmo que o nível de saída permitido não inclua o debug. O motivo é que o Ruby precisa avaliar
essas strings, o que inclui instanciar o objeto `String` um tanto pesado
e interpolar as variáveis.
Portanto, é recomendado passar blocos para os métodos do logger, pois estes só são avaliados se o nível de saída for o mesmo que — ou estiver incluído no — nível permitido (ou seja, carregamento preguiçoso). O mesmo código reescrito seria:

```ruby
logger.debug { "Hash de atributos da pessoa: #{@person.attributes.inspect}" }
```

O conteúdo do bloco, e portanto, a interpolação de string, só é avaliado se o modo de depuração estiver ativado. Essa economia de desempenho só é realmente perceptível com grandes quantidades de logs, mas é uma boa prática a ser adotada.

INFO: Esta seção foi escrita por [Jon Cairns em uma resposta no Stack Overflow](https://stackoverflow.com/questions/16546730/logging-in-rails-is-there-any-performance-hit/16546935#16546935) e está licenciada sob [cc by-sa 4.0](https://creativecommons.org/licenses/by-sa/4.0/).

Depuração com a gem `debug`
------------------------------

Quando o seu código está se comportando de maneira inesperada, você pode tentar imprimir nos logs ou no console para diagnosticar o problema. Infelizmente, há momentos em que esse tipo de rastreamento de erros não é eficaz para encontrar a causa raiz de um problema. Quando você realmente precisa entrar no código-fonte em execução, o depurador é o seu melhor companheiro.

O depurador também pode ajudá-lo se você quiser aprender sobre o código-fonte do Rails, mas não sabe por onde começar. Basta depurar qualquer solicitação para a sua aplicação e usar este guia para aprender como navegar do código que você escreveu para o código subjacente do Rails.

O Rails 7 inclui a gem `debug` no `Gemfile` de novas aplicações geradas pelo CRuby. Por padrão, ela está pronta nos ambientes `development` e `test`. Por favor, verifique a [documentação](https://github.com/ruby/debug) para saber como usá-la.

### Entrando em uma Sessão de Depuração

Por padrão, uma sessão de depuração será iniciada após a biblioteca `debug` ser requerida, o que acontece quando sua aplicação é inicializada. Mas não se preocupe, a sessão não interferirá na execução da sua aplicação.

Para entrar na sessão de depuração, você pode usar `binding.break` e seus sinônimos: `binding.b` e `debugger`. Os exemplos a seguir usarão `debugger`:

```rb
class PostsController < ApplicationController
  before_action :set_post, only: %i[ show edit update destroy ]

  # GET /posts or /posts.json
  def index
    @posts = Post.all
    debugger
  end
  # ...
end
```

Assim que sua aplicação avaliar a instrução de depuração, ela entrará na sessão de depuração:

```rb
Processando por PostsController#index como HTML
[2, 11] em ~/projects/rails-guide-example/app/controllers/posts_controller.rb
     2|   before_action :set_post, only: %i[ show edit update destroy ]
     3|
     4|   # GET /posts or /posts.json
     5|   def index
     6|     @posts = Post.all
=>   7|     debugger
     8|   end
     9|
    10|   # GET /posts/1 or /posts/1.json
    11|   def show
=>#0    PostsController#index em ~/projects/rails-guide-example/app/controllers/posts_controller.rb:7
  #1    ActionController::BasicImplicitRender#send_action(method="index", args=[]) em ~/.rbenv/versions/3.0.1/lib/ruby/gems/3.0.0/gems/actionpack-7.1.0.alpha/lib/action_controller/metal/basic_implicit_render.rb:6
  # e 72 quadros (use o comando `bt' para todos os quadros)
(rdbg)
```

Você pode sair da sessão de depuração a qualquer momento e continuar a execução da sua aplicação com o comando `continue` (ou `c`). Ou, para sair tanto da sessão de depuração quanto da aplicação, use o comando `quit` (ou `q`).

### O Contexto

Após entrar na sessão de depuração, você pode digitar código Ruby como se estivesse em um console do Rails ou IRB.

```rb
(rdbg) @posts    # ruby
[]
(rdbg) self
#<PostsController:0x0000000000aeb0>
(rdbg)
```

Você também pode usar os comandos `p` ou `pp` para avaliar expressões Ruby, o que é útil quando um nome de variável entra em conflito com um comando do depurador.
```rb
(rdbg) p headers    # comando
=> {"X-Frame-Options"=>"SAMEORIGIN", "X-XSS-Protection"=>"1; mode=block", "X-Content-Type-Options"=>"nosniff", "X-Download-Options"=>"noopen", "X-Permitted-Cross-Domain-Policies"=>"none", "Referrer-Policy"=>"strict-origin-when-cross-origin"}
(rdbg) pp headers    # comando
{"X-Frame-Options"=>"SAMEORIGIN",
 "X-XSS-Protection"=>"1; mode=block",
 "X-Content-Type-Options"=>"nosniff",
 "X-Download-Options"=>"noopen",
 "X-Permitted-Cross-Domain-Policies"=>"none",
 "Referrer-Policy"=>"strict-origin-when-cross-origin"}
(rdbg)
```

Além da avaliação direta, o depurador também ajuda a coletar uma quantidade rica de informações por meio de diferentes comandos, como:

- `info` (ou `i`) - Informações sobre o quadro atual.
- `backtrace` (ou `bt`) - Backtrace (com informações adicionais).
- `outline` (ou `o`, `ls`) - Métodos disponíveis, constantes, variáveis locais e variáveis de instância no escopo atual.

#### O comando `info`

`info` fornece uma visão geral dos valores das variáveis locais e de instância que são visíveis a partir do quadro atual.

```rb
(rdbg) info    # comando
%self = #<PostsController:0x0000000000af78>
@_action_has_layout = true
@_action_name = "index"
@_config = {}
@_lookup_context = #<ActionView::LookupContext:0x00007fd91a037e38 @details_key=nil, @digest_cache=...
@_request = #<ActionDispatch::Request GET "http://localhost:3000/posts" for 127.0.0.1>
@_response = #<ActionDispatch::Response:0x00007fd91a03ea08 @mon_data=#<Monitor:0x00007fd91a03e8c8>...
@_response_body = nil
@_routes = nil
@marked_for_same_origin_verification = true
@posts = []
@rendered_format = nil
```

#### O comando `backtrace`

Quando usado sem nenhuma opção, `backtrace` lista todos os quadros na pilha:

```rb
=>#0    PostsController#index at ~/projects/rails-guide-example/app/controllers/posts_controller.rb:7
  #1    ActionController::BasicImplicitRender#send_action(method="index", args=[]) at ~/.rbenv/versions/3.0.1/lib/ruby/gems/3.0.0/gems/actionpack-7.1.0.alpha/lib/action_controller/metal/basic_implicit_render.rb:6
  #2    AbstractController::Base#process_action(method_name="index", args=[]) at ~/.rbenv/versions/3.0.1/lib/ruby/gems/3.0.0/gems/actionpack-7.1.0.alpha/lib/abstract_controller/base.rb:214
  #3    ActionController::Rendering#process_action(#arg_rest=nil) at ~/.rbenv/versions/3.0.1/lib/ruby/gems/3.0.0/gems/actionpack-7.1.0.alpha/lib/action_controller/metal/rendering.rb:53
  #4    block in process_action at ~/.rbenv/versions/3.0.1/lib/ruby/gems/3.0.0/gems/actionpack-7.1.0.alpha/lib/abstract_controller/callbacks.rb:221
  #5    block in run_callbacks at ~/.rbenv/versions/3.0.1/lib/ruby/gems/3.0.0/gems/activesupport-7.1.0.alpha/lib/active_support/callbacks.rb:118
  #6    ActionText::Rendering::ClassMethods#with_renderer(renderer=#<PostsController:0x0000000000af78>) at ~/.rbenv/versions/3.0.1/lib/ruby/gems/3.0.0/gems/actiontext-7.1.0.alpha/lib/action_text/rendering.rb:20
  #7    block {|controller=#<PostsController:0x0000000000af78>, action=#<Proc:0x00007fd91985f1c0 /Users/st0012/...|} in <class:Engine> (4 levels) at ~/.rbenv/versions/3.0.1/lib/ruby/gems/3.0.0/gems/actiontext-7.1.0.alpha/lib/action_text/engine.rb:69
  #8    [C] BasicObject#instance_exec at ~/.rbenv/versions/3.0.1/lib/ruby/gems/3.0.0/gems/activesupport-7.1.0.alpha/lib/active_support/callbacks.rb:127
  ..... e mais
```

Cada quadro vem com:

- Identificador do quadro
- Localização da chamada
- Informações adicionais (por exemplo, argumentos de bloco ou método)

Isso lhe dará uma ótima ideia do que está acontecendo em seu aplicativo. No entanto, você provavelmente perceberá que:

- Existem muitos quadros (geralmente mais de 50 em um aplicativo Rails).
- A maioria dos quadros são do Rails ou de outras bibliotecas que você usa.

O comando `backtrace` fornece 2 opções para ajudá-lo a filtrar os quadros:

- `backtrace [num]` - mostra apenas `num` números de quadros, por exemplo, `backtrace 10`.
- `backtrace /padrão/` - mostra apenas quadros com identificador ou localização que corresponde ao padrão, por exemplo, `backtrace /MyModel/`.

Também é possível usar essas opções juntas: `backtrace [num] /padrão/`.

#### O comando `outline`

`outline` é semelhante ao comando `ls` do `pry` e `irb`. Ele mostrará o que é acessível a partir do escopo atual, incluindo:

- Variáveis locais
- Variáveis de instância
- Variáveis de classe
- Métodos e suas fontes

```rb
ActiveSupport::Configurable#methods: config
AbstractController::Base#methods:
  action_methods  action_name  action_name=  available_action?  controller_path  inspect
  response_body
ActionController::Metal#methods:
  content_type       content_type=  controller_name  dispatch          headers
  location           location=      media_type       middleware_stack  middleware_stack=
  middleware_stack?  performed?     request          request=          reset_session
  response           response=      response_body=   response_code     session
  set_request!       set_response!  status           status=           to_a
ActionView::ViewPaths#methods:
  _prefixes  any_templates?  append_view_path   details_for_lookup  formats     formats=  locale
  locale=    lookup_context  prepend_view_path  template_exists?    view_paths
AbstractController::Rendering#methods: view_assigns

# .....

PostsController#methods: create  destroy  edit  index  new  show  update
instance variables:
  @_action_has_layout  @_action_name    @_config  @_lookup_context                      @_request
  @_response           @_response_body  @_routes  @marked_for_same_origin_verification  @posts
  @rendered_format
class variables: @@raise_on_missing_translations  @@raise_on_open_redirects
```

### Pontos de interrupção

Existem várias maneiras de inserir e acionar um ponto de interrupção no depurador. Além de adicionar declarações de depuração (por exemplo, `debugger`) diretamente em seu código, você também pode inserir pontos de interrupção com comandos:

- `break` (ou `b`)
  - `break` - lista todos os pontos de interrupção
  - `break <num>` - define um ponto de interrupção na linha `num` do arquivo atual
  - `break <file:num>` - define um ponto de interrupção na linha `num` do `file`
  - `break <Class#method>` ou `break <Class.method>` - define um ponto de interrupção em `Class#method` ou `Class.method`
  - `break <expr>.<method>` - define um ponto de interrupção no método `<method>` do resultado de `<expr>`.
- `catch <Exception>` - define um ponto de interrupção que será acionado quando `Exception` for lançada
- `watch <@ivar>` - define um ponto de interrupção que será acionado quando o resultado da variável de instância `@ivar` do objeto atual for alterado (isso é lento)
E para removê-los, você pode usar:

- `delete` (ou `del`)
  - `delete` - deleta todos os pontos de interrupção
  - `delete <num>` - deleta o ponto de interrupção com o id `num`

#### O comando `break`

**Define um ponto de interrupção em uma linha específica - por exemplo, `b 28`**

```rb
[20, 29] em ~/projects/rails-guide-example/app/controllers/posts_controller.rb
    20|   end
    21|
    22|   # POST /posts or /posts.json
    23|   def create
    24|     @post = Post.new(post_params)
=>  25|     debugger
    26|
    27|     respond_to do |format|
    28|       if @post.save
    29|         format.html { redirect_to @post, notice: "Post was successfully created." }
=>#0    PostsController#create em ~/projects/rails-guide-example/app/controllers/posts_controller.rb:25
  #1    ActionController::BasicImplicitRender#send_action(method="create", args=[]) em ~/.rbenv/versions/3.0.1/lib/ruby/gems/3.0.0/gems/actionpack-7.0.0.alpha2/lib/action_controller/metal/basic_implicit_render.rb:6
  # e 72 frames (use o comando `bt' para todos os frames)
(rdbg) b 28    # comando break
#0  BP - Linha  /Users/st0012/projects/rails-guide-example/app/controllers/posts_controller.rb:28 (linha)
```

```rb
(rdbg) c    # comando continue
[23, 32] em ~/projects/rails-guide-example/app/controllers/posts_controller.rb
    23|   def create
    24|     @post = Post.new(post_params)
    25|     debugger
    26|
    27|     respond_to do |format|
=>  28|       if @post.save
    29|         format.html { redirect_to @post, notice: "Post was successfully created." }
    30|         format.json { render :show, status: :created, location: @post }
    31|       else
    32|         format.html { render :new, status: :unprocessable_entity }
=>#0    block {|format=#<ActionController::MimeResponds::Collec...|} em create em ~/projects/rails-guide-example/app/controllers/posts_controller.rb:28
  #1    ActionController::MimeResponds#respond_to(mimes=[]) em ~/.rbenv/versions/3.0.1/lib/ruby/gems/3.0.0/gems/actionpack-7.0.0.alpha2/lib/action_controller/metal/mime_responds.rb:205
  # e 74 frames (use o comando `bt' para todos os frames)

Parado em #0  BP - Linha  /Users/st0012/projects/rails-guide-example/app/controllers/posts_controller.rb:28 (linha)
```

Define um ponto de interrupção em uma chamada de método específica - por exemplo, `b @post.save`.

```rb
[20, 29] em ~/projects/rails-guide-example/app/controllers/posts_controller.rb
    20|   end
    21|
    22|   # POST /posts or /posts.json
    23|   def create
    24|     @post = Post.new(post_params)
=>  25|     debugger
    26|
    27|     respond_to do |format|
    28|       if @post.save
    29|         format.html { redirect_to @post, notice: "Post was successfully created." }
=>#0    PostsController#create em ~/projects/rails-guide-example/app/controllers/posts_controller.rb:25
  #1    ActionController::BasicImplicitRender#send_action(method="create", args=[]) em ~/.rbenv/versions/3.0.1/lib/ruby/gems/3.0.0/gems/actionpack-7.0.0.alpha2/lib/action_controller/metal/basic_implicit_render.rb:6
  # e 72 frames (use o comando `bt' para todos os frames)
(rdbg) b @post.save    # comando break
#0  BP - Método  @post.save em /Users/st0012/.rbenv/versions/3.0.1/lib/ruby/gems/3.0.0/gems/activerecord-7.0.0.alpha2/lib/active_record/suppressor.rb:43

```

```rb
(rdbg) c    # comando continue
[39, 48] em ~/.rbenv/versions/3.0.1/lib/ruby/gems/3.0.0/gems/activerecord-7.0.0.alpha2/lib/active_record/suppressor.rb
    39|         SuppressorRegistry.suppressed[name] = previous_state
    40|       end
    41|     end
    42|
    43|     def save(**) # :nodoc:
=>  44|       SuppressorRegistry.suppressed[self.class.name] ? true : super
    45|     end
    46|
    47|     def save!(**) # :nodoc:
    48|       SuppressorRegistry.suppressed[self.class.name] ? true : super
=>#0    ActiveRecord::Suppressor#save(#arg_rest=nil) em ~/.rbenv/versions/3.0.1/lib/ruby/gems/3.0.0/gems/activerecord-7.0.0.alpha2/lib/active_record/suppressor.rb:44
  #1    block {|format=#<ActionController::MimeResponds::Collec...|} em create em ~/projects/rails-guide-example/app/controllers/posts_controller.rb:28
  # e 75 frames (use o comando `bt' para todos os frames)

Parado em #0  BP - Método  @post.save em /Users/st0012/.rbenv/versions/3.0.1/lib/ruby/gems/3.0.0/gems/activerecord-7.0.0.alpha2/lib/active_record/suppressor.rb:43
```

#### O comando `catch`

Para quando uma exceção é lançada - por exemplo, `catch ActiveRecord::RecordInvalid`.

```rb
[20, 29] em ~/projects/rails-guide-example/app/controllers/posts_controller.rb
    20|   end
    21|
    22|   # POST /posts or /posts.json
    23|   def create
    24|     @post = Post.new(post_params)
=>  25|     debugger
    26|
    27|     respond_to do |format|
    28|       if @post.save!
    29|         format.html { redirect_to @post, notice: "Post was successfully created." }
=>#0    PostsController#create em ~/projects/rails-guide-example/app/controllers/posts_controller.rb:25
  #1    ActionController::BasicImplicitRender#send_action(method="create", args=[]) em ~/.rbenv/versions/3.0.1/lib/ruby/gems/3.0.0/gems/actionpack-7.0.0.alpha2/lib/action_controller/metal/basic_implicit_render.rb:6
  # e 72 frames (use o comando `bt' para todos os frames)
(rdbg) catch ActiveRecord::RecordInvalid    # comando
#1  BP - Catch  "ActiveRecord::RecordInvalid"
```

```rb
(rdbg) c    # comando continue
[75, 84] em ~/.rbenv/versions/3.0.1/lib/ruby/gems/3.0.0/gems/activerecord-7.0.0.alpha2/lib/active_record/validations.rb
    75|     def default_validation_context
    76|       new_record? ? :create : :update
    77|     end
    78|
    79|     def raise_validation_error
=>  80|       raise(RecordInvalid.new(self))
    81|     end
    82|
    83|     def perform_validations(options = {})
    84|       options[:validate] == false || valid?(options[:context])
=>#0    ActiveRecord::Validations#raise_validation_error em ~/.rbenv/versions/3.0.1/lib/ruby/gems/3.0.0/gems/activerecord-7.0.0.alpha2/lib/active_record/validations.rb:80
  #1    ActiveRecord::Validations#save!(options={}) em ~/.rbenv/versions/3.0.1/lib/ruby/gems/3.0.0/gems/activerecord-7.0.0.alpha2/lib/active_record/validations.rb:53
  # e 88 frames (use o comando `bt' para todos os frames)

Parado em #1  BP - Catch  "ActiveRecord::RecordInvalid"
```
#### O comando `watch`

Pare quando a variável de instância for alterada - por exemplo, `watch @_response_body`.

```rb
[20, 29] in ~/projects/rails-guide-example/app/controllers/posts_controller.rb
    20|   end
    21|
    22|   # POST /posts or /posts.json
    23|   def create
    24|     @post = Post.new(post_params)
=>  25|     debugger
    26|
    27|     respond_to do |format|
    28|       if @post.save!
    29|         format.html { redirect_to @post, notice: "Post was successfully created." }
=>#0    PostsController#create at ~/projects/rails-guide-example/app/controllers/posts_controller.rb:25
  #1    ActionController::BasicImplicitRender#send_action(method="create", args=[]) at ~/.rbenv/versions/3.0.1/lib/ruby/gems/3.0.0/gems/actionpack-7.0.0.alpha2/lib/action_controller/metal/basic_implicit_render.rb:6
  # e 72 frames (use o comando `bt' para todas as frames)
(rdbg) watch @_response_body    # comando
#0  BP - Watch  #<PostsController:0x00007fce69ca5320> @_response_body =
```

```rb
(rdbg) c    # comando continue
[173, 182] in ~/.rbenv/versions/3.0.1/lib/ruby/gems/3.0.0/gems/actionpack-7.0.0.alpha2/lib/action_controller/metal.rb
   173|       body = [body] unless body.nil? || body.respond_to?(:each)
   174|       response.reset_body!
   175|       return unless body
   176|       response.body = body
   177|       super
=> 178|     end
   179|
   180|     # Tests if render or redirect has already happened.
   181|     def performed?
   182|       response_body || response.committed?
=>#0    ActionController::Metal#response_body=(body=["<html><body>You are being <a href=\"ht...) at ~/.rbenv/versions/3.0.1/lib/ruby/gems/3.0.0/gems/actionpack-7.0.0.alpha2/lib/action_controller/metal.rb:178 #=> ["<html><body>You are being <a href=\"http://localhost:3000/posts/13\">redirected</a>.</body></html>"]
  #1    ActionController::Redirecting#redirect_to(options=#<Post id: 13, title: "qweqwe", content:..., response_options={:allow_other_host=>false}) at ~/.rbenv/versions/3.0.1/lib/ruby/gems/3.0.0/gems/actionpack-7.0.0.alpha2/lib/action_controller/metal/redirecting.rb:74
  # e 82 frames (use o comando `bt' para todas as frames)

Pare em #0  BP - Watch  #<PostsController:0x00007fce69ca5320> @_response_body =  -> ["<html><body>You are being <a href=\"http://localhost:3000/posts/13\">redirected</a>.</body></html>"]
(rdbg)
```

#### Opções de ponto de interrupção

Além dos diferentes tipos de pontos de interrupção, você também pode especificar opções para obter fluxos de trabalho de depuração mais avançados. Atualmente, o depurador suporta 4 opções:

- `do: <cmd ou expr>` - quando o ponto de interrupção é acionado, execute o comando/expressão fornecido e continue o programa:
  - `break Foo#bar do: bt` - quando `Foo#bar` é chamado, imprima as frames da pilha
- `pre: <cmd ou expr>` - quando o ponto de interrupção é acionado, execute o comando/expressão fornecido antes de parar:
  - `break Foo#bar pre: info` - quando `Foo#bar` é chamado, imprima as variáveis ao redor antes de parar.
- `if: <expr>` - o ponto de interrupção só para se o resultado de `<expr>` for verdadeiro:
  - `break Post#save if: params[:debug]` - para em `Post#save` se `params[:debug]` também for verdadeiro
- `path: <path_regexp>` - o ponto de interrupção só para se o evento que o aciona (por exemplo, uma chamada de método) ocorrer no caminho fornecido:
  - `break Post#save if: app/services/a_service` - para em `Post#save` se a chamada do método ocorrer em um método que corresponda à expressão regular Ruby `/app\/services\/a_service/`.

Observe também que as 3 primeiras opções: `do:`, `pre:` e `if:` também estão disponíveis para as declarações de depuração mencionadas anteriormente. Por exemplo:

```rb
[2, 11] in ~/projects/rails-guide-example/app/controllers/posts_controller.rb
     2|   before_action :set_post, only: %i[ show edit update destroy ]
     3|
     4|   # GET /posts or /posts.json
     5|   def index
     6|     @posts = Post.all
=>   7|     debugger(do: "info")
     8|   end
     9|
    10|   # GET /posts/1 or /posts/1.json
    11|   def show
=>#0    PostsController#index at ~/projects/rails-guide-example/app/controllers/posts_controller.rb:7
  #1    ActionController::BasicImplicitRender#send_action(method="index", args=[]) at ~/.rbenv/versions/3.0.1/lib/ruby/gems/3.0.0/gems/actionpack-7.0.0.alpha2/lib/action_controller/metal/basic_implicit_render.rb:6
  # e 72 frames (use o comando `bt' para todas as frames)
(rdbg:binding.break) info
%self = #<PostsController:0x00000000017480>
@_action_has_layout = true
@_action_name = "index"
@_config = {}
@_lookup_context = #<ActionView::LookupContext:0x00007fce3ad336b8 @details_key=nil, @digest_cache=...
@_request = #<ActionDispatch::Request GET "http://localhost:3000/posts" for 127.0.0.1>
@_response = #<ActionDispatch::Response:0x00007fce3ad397e8 @mon_data=#<Monitor:0x00007fce3ad396a8>...
@_response_body = nil
@_routes = nil
@marked_for_same_origin_verification = true
@posts = #<ActiveRecord::Relation [#<Post id: 2, title: "qweqwe", content: "qweqwe", created_at: "...
@rendered_format = nil
```
#### Programar seu fluxo de depuração

Com essas opções, você pode criar um script para o seu fluxo de depuração em uma linha, como:

```rb
def create
  debugger(do: "catch ActiveRecord::RecordInvalid do: bt 10")
  # ...
end
```

E então o depurador executará o comando scriptado e inserirá o ponto de interrupção de captura

```rb
(rdbg:binding.break) catch ActiveRecord::RecordInvalid do: bt 10
#0  BP - Capturar  "ActiveRecord::RecordInvalid"
[75, 84] em ~/.rbenv/versions/3.0.1/lib/ruby/gems/3.0.0/gems/activerecord-7.0.0.alpha2/lib/active_record/validations.rb
    75|     def default_validation_context
    76|       new_record? ? :create : :update
    77|     end
    78|
    79|     def raise_validation_error
=>  80|       raise(RecordInvalid.new(self))
    81|     end
    82|
    83|     def perform_validations(options = {})
    84|       options[:validate] == false || valid?(options[:context])
=>#0    ActiveRecord::Validations#raise_validation_error em ~/.rbenv/versions/3.0.1/lib/ruby/gems/3.0.0/gems/activerecord-7.0.0.alpha2/lib/active_record/validations.rb:80
  #1    ActiveRecord::Validations#save!(options={}) em ~/.rbenv/versions/3.0.1/lib/ruby/gems/3.0.0/gems/activerecord-7.0.0.alpha2/lib/active_record/validations.rb:53
  # e mais 88 quadros (use o comando `bt' para todos os quadros)
```

Uma vez que o ponto de interrupção de captura é acionado, ele imprimirá os quadros de pilha

```rb
Parar em #0  BP - Capturar  "ActiveRecord::RecordInvalid"

(rdbg:catch) bt 10
=>#0    ActiveRecord::Validations#raise_validation_error em ~/.rbenv/versions/3.0.1/lib/ruby/gems/3.0.0/gems/activerecord-7.0.0.alpha2/lib/active_record/validations.rb:80
  #1    ActiveRecord::Validations#save!(options={}) em ~/.rbenv/versions/3.0.1/lib/ruby/gems/3.0.0/gems/activerecord-7.0.0.alpha2/lib/active_record/validations.rb:53
  #2    bloco em save! em ~/.rbenv/versions/3.0.1/lib/ruby/gems/3.0.0/gems/activerecord-7.0.0.alpha2/lib/active_record/transactions.rb:302
```

Essa técnica pode economizar tempo de entrada manual repetitiva e tornar a experiência de depuração mais suave.

Você pode encontrar mais comandos e opções de configuração em sua [documentação](https://github.com/ruby/debug).

Depuração com a gem `web-console`
----------------------------------

O Web Console é um pouco como o `debug`, mas é executado no navegador. Você pode solicitar um console no contexto de uma visualização ou um controlador em qualquer página. O console será renderizado ao lado do seu conteúdo HTML.

### Console

Dentro de qualquer ação do controlador ou visualização, você pode invocar o console chamando o método `console`.

Por exemplo, em um controlador:

```ruby
class PostsController < ApplicationController
  def new
    console
    @post = Post.new
  end
end
```

Ou em uma visualização:

```html+erb
<% console %>

<h2>Novo Post</h2>
```

Isso renderizará um console dentro da sua visualização. Você não precisa se preocupar com a localização da chamada `console`; ela não será renderizada no local de sua invocação, mas ao lado do seu conteúdo HTML.

O console executa código Ruby puro: você pode definir e instanciar classes personalizadas, criar novos modelos e inspecionar variáveis.

NOTA: Apenas um console pode ser renderizado por solicitação. Caso contrário, o `web-console` lançará um erro na segunda invocação do `console`.

### Inspecionando Variáveis

Você pode invocar `instance_variables` para listar todas as variáveis de instância disponíveis no seu contexto. Se você quiser listar todas as variáveis locais, pode fazer isso com `local_variables`.

### Configurações

* `config.web_console.allowed_ips`: Lista autorizada de endereços IPv4 ou IPv6 e redes (padrão: `127.0.0.1/8, ::1`).
* `config.web_console.whiny_requests`: Registrar uma mensagem quando a renderização do console for impedida (padrão: `true`).

Como o `web-console` avalia código Ruby puro remotamente no servidor, não tente usá-lo em produção.

Depurando Vazamentos de Memória
------------------------------

Uma aplicação Ruby (no Rails ou não) pode ter vazamentos de memória - seja no código Ruby ou no nível do código C.

Nesta seção, você aprenderá como encontrar e corrigir esses vazamentos usando ferramentas como o Valgrind.

### Valgrind

[Valgrind](http://valgrind.org/) é um aplicativo para detectar vazamentos de memória e condições de corrida baseadas em C.

Existem ferramentas do Valgrind que podem detectar automaticamente muitos bugs de gerenciamento de memória e de encadeamento, e perfilar seus programas em detalhes. Por exemplo, se uma extensão C no interpretador chamar `malloc()` mas não chamar corretamente `free()`, essa memória não estará disponível até que o aplicativo seja encerrado.
Para mais informações sobre como instalar o Valgrind e usá-lo com o Ruby, consulte [Valgrind and Ruby](https://blog.evanweaver.com/2008/02/05/valgrind-and-ruby/) por Evan Weaver.

### Encontrar um Vazamento de Memória

Existe um excelente artigo sobre como detectar e corrigir vazamentos de memória no Derailed, [que você pode ler aqui](https://github.com/schneems/derailed_benchmarks#is-my-app-leaking-memory).

Plugins para Depuração
---------------------

Existem alguns plugins do Rails que podem ajudar a encontrar erros e depurar sua aplicação. Aqui está uma lista de plugins úteis para depuração:

* [Query Trace](https://github.com/ruckus/active-record-query-trace/tree/master) Adiciona rastreamento de origem de consulta aos seus logs.
* [Exception Notifier](https://github.com/smartinez87/exception_notification/tree/master) Fornece um objeto mailer e um conjunto padrão de modelos para enviar notificações por email quando ocorrem erros em uma aplicação Rails.
* [Better Errors](https://github.com/charliesome/better_errors) Substitui a página de erro padrão do Rails por uma nova contendo mais informações contextuais, como código-fonte e inspeção de variáveis.
* [RailsPanel](https://github.com/dejan/rails_panel) Extensão para o Chrome para desenvolvimento Rails que encerra o acompanhamento do development.log. Tenha todas as informações sobre as solicitações do seu aplicativo Rails no navegador - no painel de Ferramentas do Desenvolvedor. Fornece informações sobre tempos de db/renderização/total, lista de parâmetros, visualizações renderizadas e muito mais.
* [Pry](https://github.com/pry/pry) Uma alternativa ao IRB e um console de desenvolvedor em tempo de execução.

Referências
----------

* [Página inicial do web-console](https://github.com/rails/web-console)
* [Página inicial do debug](https://github.com/ruby/debug)
