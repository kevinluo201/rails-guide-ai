**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 7dbd0564d604e07d111b2a827bef559f
A Linha de Comando do Rails
===========================

Após ler este guia, você saberá:

* Como criar uma aplicação Rails.
* Como gerar modelos, controladores, migrações de banco de dados e testes unitários.
* Como iniciar um servidor de desenvolvimento.
* Como experimentar objetos através de um shell interativo.

--------------------------------------------------------------------------------

NOTA: Este tutorial pressupõe que você tenha conhecimento básico do Rails a partir da leitura do [Guia de Introdução ao Rails](getting_started.html).

Criando uma Aplicação Rails
---------------------------

Primeiro, vamos criar uma aplicação Rails simples usando o comando `rails new`.

Vamos usar esta aplicação para brincar e descobrir todos os comandos descritos neste guia.

INFO: Você pode instalar a gema rails digitando `gem install rails`, se ainda não a tiver.

### `rails new`

O primeiro argumento que passaremos para o comando `rails new` é o nome da aplicação.

```bash
$ rails new my_app
     create
     create  README.md
     create  Rakefile
     create  config.ru
     create  .gitignore
     create  Gemfile
     create  app
     ...
     create  tmp/cache
     ...
        run  bundle install
```

O Rails irá configurar o que parece ser uma enorme quantidade de coisas para um comando tão pequeno! Agora temos toda a estrutura de diretórios do Rails com todo o código necessário para executar nossa aplicação simples imediatamente.

Se você deseja pular a geração de alguns arquivos ou pular algumas bibliotecas, você pode adicionar qualquer um dos seguintes argumentos ao seu comando `rails new`:

| Argumento               | Descrição                                                   |
| ----------------------- | ----------------------------------------------------------- |
| `--skip-git`            | Pular git init, .gitignore e .gitattributes                |
| `--skip-docker`         | Pular Dockerfile, .dockerignore e bin/docker-entrypoint    |
| `--skip-keeps`          | Pular arquivos .keep de controle de versão                  |
| `--skip-action-mailer`  | Pular arquivos do Action Mailer                             |
| `--skip-action-mailbox` | Pular Action Mailbox gem                                    |
| `--skip-action-text`    | Pular Action Text gem                                       |
| `--skip-active-record`  | Pular arquivos do Active Record                             |
| `--skip-active-job`     | Pular Active Job                                           |
| `--skip-active-storage` | Pular arquivos do Active Storage                            |
| `--skip-action-cable`   | Pular arquivos do Action Cable                              |
| `--skip-asset-pipeline` | Pular Asset Pipeline                                        |
| `--skip-javascript`     | Pular arquivos JavaScript                                  |
| `--skip-hotwire`        | Pular integração do Hotwire                                |
| `--skip-jbuilder`       | Pular gem jbuilder                                         |
| `--skip-test`           | Pular arquivos de teste                                     |
| `--skip-system-test`    | Pular arquivos de teste do sistema                          |
| `--skip-bootsnap`       | Pular gem bootsnap                                          |

Essas são apenas algumas das opções que o `rails new` aceita. Para obter uma lista completa de opções, digite `rails new --help`.

### Pré-configurar um Banco de Dados Diferente

Ao criar uma nova aplicação Rails, você tem a opção de especificar qual tipo de banco de dados sua aplicação irá usar. Isso irá economizar alguns minutos e certamente muitas teclas.

Vamos ver o que a opção `--database=postgresql` fará por nós:

```bash
$ rails new petstore --database=postgresql
      create
      create  app/controllers
      create  app/helpers
...
```

Vamos ver o que ele colocou em nosso `config/database.yml`:

```yaml
# PostgreSQL. Versões 9.3 e superiores são suportadas.
#
# Instale o driver pg:
#   gem install pg
# No macOS com o Homebrew:
#   gem install pg -- --with-pg-config=/usr/local/bin/pg_config
# No Windows:
#   gem install pg
#       Escolha a versão win32.
#       Instale o PostgreSQL e coloque o diretório /bin dele no seu path.
#
# Configure Usando o Gemfile
# gem "pg"
#
default: &default
  adapter: postgresql
  encoding: unicode

  # Para detalhes sobre pooling de conexões, consulte o guia de configuração do Rails
  # https://guides.rubyonrails.org/configuring.html#database-pooling
  pool: <%= ENV.fetch("RAILS_MAX_THREADS") { 5 } %>

development:
  <<: *default
  database: petstore_development
...
```

Ele gerou uma configuração de banco de dados correspondente à nossa escolha de PostgreSQL.

Noções Básicas da Linha de Comando
---------------------------------

Existem alguns comandos que são absolutamente essenciais para o uso diário do Rails. Na ordem em que você provavelmente os usará são:

* `bin/rails console`
* `bin/rails server`
* `bin/rails test`
* `bin/rails generate`
* `bin/rails db:migrate`
* `bin/rails db:create`
* `bin/rails routes`
* `bin/rails dbconsole`
* `rails new nome_da_aplicacao`

Você pode obter uma lista de comandos do Rails disponíveis para você, que muitas vezes dependerá do seu diretório atual, digitando `rails --help`. Cada comando tem uma descrição e deve ajudá-lo a encontrar o que você precisa.

```bash
$ rails --help
Uso:
  bin/rails COMANDO [opções]

Você deve especificar um comando. Os comandos mais comuns são:

  generate     Gerar novo código (atalho: "g")
  console      Iniciar o console do Rails (atalho: "c")
  server       Iniciar o servidor do Rails (atalho: "s")
  ...

Todos os comandos podem ser executados com -h (ou --help) para obter mais informações.

Além desses comandos, existem:
about                               Listar versões de todos os Rails ...
assets:clean[keep]                  Remover ativos compilados antigos
assets:clobber                      Remover ativos compilados
assets:environment                  Carregar ambiente de compilação de ativos
assets:precompile                   Compilar todos os ativos ...
...
db:fixtures:load                    Carregar fixtures no ...
db:migrate                          Migrar o banco de dados ...
db:migrate:status                   Exibir status das migrações
db:rollback                         Reverter o esquema para ...
db:schema:cache:clear               Limpar um arquivo db/schema_cache.yml
db:schema:cache:dump                Criar um arquivo db/schema_cache.yml
db:schema:dump                      Criar um arquivo de esquema do banco de dados (db/schema.rb ou db/structure.sql ...
db:schema:load                      Carregar um arquivo de esquema do banco de dados (db/schema.rb ou db/structure.sql ...
db:seed                             Carregar os dados iniciais ...
db:version                          Recuperar o esquema atual ...
...
restart                             Reiniciar o aplicativo tocando ...
tmp:create                          Criar diretórios tmp ...
```
### `bin/rails server`

O comando `bin/rails server` inicia um servidor web chamado Puma, que vem junto com o Rails. Você usará isso sempre que quiser acessar sua aplicação através de um navegador web.

Sem mais trabalho, `bin/rails server` executará nossa nova e reluzente aplicação Rails:

```bash
$ cd my_app
$ bin/rails server
=> Inicializando o Puma
=> Aplicação Rails 7.0.0 iniciando em desenvolvimento
=> Execute `bin/rails server --help` para mais opções de inicialização
Puma iniciando em modo único...
* Versão 3.12.1 (ruby 2.5.7-p206), codinome: Llamas in Pajamas
* Threads mínimos: 5, threads máximos: 5
* Ambiente: desenvolvimento
* Ouvindo em tcp://localhost:3000
Use Ctrl-C para parar
```

Com apenas três comandos, criamos um servidor Rails ouvindo na porta 3000. Vá para o seu navegador e abra [http://localhost:3000](http://localhost:3000), você verá uma aplicação Rails básica em execução.

INFO: Você também pode usar o alias "s" para iniciar o servidor: `bin/rails s`.

O servidor pode ser executado em uma porta diferente usando a opção `-p`. O ambiente de desenvolvimento padrão pode ser alterado usando `-e`.

```bash
$ bin/rails server -e production -p 4000
```

A opção `-b` vincula o Rails ao IP especificado, por padrão é localhost. Você pode executar um servidor como um daemon passando a opção `-d`.

### `bin/rails generate`

O comando `bin/rails generate` usa modelos para criar muitas coisas. Executar `bin/rails generate` sozinho exibe uma lista de geradores disponíveis:

INFO: Você também pode usar o alias "g" para invocar o comando do gerador: `bin/rails g`.

```bash
$ bin/rails generate
Uso:
  bin/rails generate GERADOR [argumentos] [opções]

...
...

Escolha um gerador abaixo.

Rails:
  assets
  channel
  controller
  generator
  ...
  ...
```

NOTA: Você pode instalar mais geradores através de gems de geradores, partes de plugins que você certamente instalará, e até mesmo criar o seu próprio!

Usar geradores economizará muito tempo escrevendo **código boilerplate**, código necessário para que a aplicação funcione.

Vamos criar nosso próprio controlador com o gerador de controladores. Mas qual comando devemos usar? Vamos perguntar ao gerador:

INFO: Todos os utilitários do console do Rails têm texto de ajuda. Como na maioria dos utilitários *nix, você pode tentar adicionar `--help` ou `-h` no final, por exemplo `bin/rails server --help`.

```bash
$ bin/rails generate controller
Uso:
  bin/rails generate controller NOME [ação ação] [opções]

...
...

Descrição:
    ...

    Para criar um controlador dentro de um módulo, especifique o nome do controlador como um caminho como 'nome_do_módulo/controlador'.

    ...

Exemplo:
    `bin/rails generate controller CreditCards open debit credit close`

    Controlador de cartão de crédito com URLs como /credit_cards/debit.
        Controlador: app/controllers/credit_cards_controller.rb
        Teste:       test/controllers/credit_cards_controller_test.rb
        Visualizações:      app/views/credit_cards/debit.html.erb [...]
        Auxiliar:     app/helpers/credit_cards_helper.rb
```

O gerador de controladores espera parâmetros na forma `generate controller NomeDoControlador acao1 acao2`. Vamos criar um controlador `Greetings` com uma ação de **hello**, que nos dirá algo legal.

```bash
$ bin/rails generate controller Greetings hello
     create  app/controllers/greetings_controller.rb
      route  get 'greetings/hello'
     invoke  erb
     create    app/views/greetings
     create    app/views/greetings/hello.html.erb
     invoke  test_unit
     create    test/controllers/greetings_controller_test.rb
     invoke  helper
     create    app/helpers/greetings_helper.rb
     invoke    test_unit
```

O que tudo isso gerou? Ele se certificou de que um monte de diretórios estivesse em nossa aplicação e criou um arquivo de controlador, um arquivo de visualização, um arquivo de teste funcional, um auxiliar para a visualização, um arquivo JavaScript e um arquivo de folha de estilo.

Verifique o controlador e modifique-o um pouco (em `app/controllers/greetings_controller.rb`):

```ruby
class GreetingsController < ApplicationController
  def hello
    @message = "Olá, como você está hoje?"
  end
end
```

Em seguida, a visualização, para exibir nossa mensagem (em `app/views/greetings/hello.html.erb`):

```erb
<h1>Uma Saudação para Você!</h1>
<p><%= @message %></p>
```

Inicie seu servidor usando `bin/rails server`.

```bash
$ bin/rails server
=> Inicializando o Puma...
```

A URL será [http://localhost:3000/greetings/hello](http://localhost:3000/greetings/hello).

INFO: Com uma aplicação Rails normal, suas URLs geralmente seguirão o padrão http://(host)/(controlador)/(ação), e uma URL como http://(host)/(controlador) acionará a ação **index** desse controlador.

O Rails vem com um gerador para modelos de dados também.

```bash
$ bin/rails generate model
Uso:
  bin/rails generate model NOME [campo[:tipo][:índice] campo[:tipo][:índice]] [opções]

...

Opções do ActiveRecord:
      [--migration], [--no-migration]        # Indica quando gerar a migração
                                             # Padrão: true

...

Descrição:
    Gera um novo modelo. Passe o nome do modelo, em CamelCase ou
    under_scored, e uma lista opcional de pares de atributos como argumentos.

...
```

NOTA: Para obter uma lista de tipos de campo disponíveis para o parâmetro `tipo`, consulte a [documentação da API](https://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html#method-i-add_column) para o método `add_column` do módulo `SchemaStatements`. O parâmetro `índice` gera um índice correspondente para a coluna.
Mas em vez de gerar um modelo diretamente (o que faremos mais tarde), vamos configurar um esqueleto. Um **esqueleto** no Rails é um conjunto completo de modelo, migração de banco de dados para esse modelo, controlador para manipulá-lo, visualizações para visualizar e manipular os dados e um conjunto de testes para cada um dos itens mencionados acima.

Vamos configurar um recurso simples chamado "HighScore" que irá acompanhar nossa maior pontuação nos videogames que jogamos.

```bash
$ bin/rails generate scaffold HighScore game:string score:integer
    invoke  active_record
    create    db/migrate/20190416145729_create_high_scores.rb
    create    app/models/high_score.rb
    invoke    test_unit
    create      test/models/high_score_test.rb
    create      test/fixtures/high_scores.yml
    invoke  resource_route
     route    resources :high_scores
    invoke  scaffold_controller
    create    app/controllers/high_scores_controller.rb
    invoke    erb
    create      app/views/high_scores
    create      app/views/high_scores/index.html.erb
    create      app/views/high_scores/edit.html.erb
    create      app/views/high_scores/show.html.erb
    create      app/views/high_scores/new.html.erb
    create      app/views/high_scores/_form.html.erb
    invoke    test_unit
    create      test/controllers/high_scores_controller_test.rb
    create      test/system/high_scores_test.rb
    invoke    helper
    create      app/helpers/high_scores_helper.rb
    invoke      test_unit
    invoke    jbuilder
    create      app/views/high_scores/index.json.jbuilder
    create      app/views/high_scores/show.json.jbuilder
    create      app/views/high_scores/_high_score.json.jbuilder
```

O gerador cria o modelo, as visualizações, o controlador, a rota de **recurso** e a migração de banco de dados (que cria a tabela `high_scores`) para HighScore. E ele adiciona testes para eles.

A migração requer que façamos uma **migração**, ou seja, executemos algum código Ruby (o arquivo `20190416145729_create_high_scores.rb` da saída acima) para modificar o esquema do nosso banco de dados. Qual banco de dados? O banco de dados SQLite3 que o Rails criará para você quando executarmos o comando `bin/rails db:migrate`. Falaremos mais sobre esse comando abaixo.

```bash
$ bin/rails db:migrate
==  CreateHighScores: migrating ===============================================
-- create_table(:high_scores)
   -> 0.0017s
==  CreateHighScores: migrated (0.0019s) ======================================
```

INFO: Vamos falar sobre testes unitários. Testes unitários são código que testa e faz afirmações sobre o código. Nos testes unitários, pegamos uma pequena parte do código, digamos um método de um modelo, e testamos suas entradas e saídas. Testes unitários são seus amigos. Quanto mais cedo você aceitar o fato de que sua qualidade de vida aumentará drasticamente quando você testar unitariamente seu código, melhor. Sério. Por favor, visite [o guia de testes](testing.html) para uma análise detalhada dos testes unitários.

Vamos ver a interface que o Rails criou para nós.

```bash
$ bin/rails server
```

Vá para o seu navegador e abra [http://localhost:3000/high_scores](http://localhost:3000/high_scores), agora podemos criar novas pontuações altas (55.160 em Space Invaders!)

### `bin/rails console`

O comando `console` permite interagir com sua aplicação Rails a partir da linha de comando. Por baixo dos panos, `bin/rails console` usa o IRB, então se você já o usou, estará familiarizado. Isso é útil para testar ideias rápidas com código e alterar dados no servidor sem mexer no site.

INFO: Você também pode usar o alias "c" para invocar o console: `bin/rails c`.

Você pode especificar o ambiente em que o comando `console` deve operar.

```bash
$ bin/rails console -e staging
```

Se você deseja testar algum código sem alterar nenhum dado, pode fazer isso invocando `bin/rails console --sandbox`.

```bash
$ bin/rails console --sandbox
Loading development environment in sandbox (Rails 7.1.0)
Any modifications you make will be rolled back on exit
irb(main):001:0>
```

#### Os objetos `app` e `helper`

Dentro do `bin/rails console`, você tem acesso às instâncias `app` e `helper`.

Com o método `app`, você pode acessar os ajudantes de rota com nome, bem como fazer solicitações.

```irb
irb> app.root_path
=> "/"

irb> app.get _
Started GET "/" for 127.0.0.1 at 2014-06-19 10:41:57 -0300
...
```

Com o método `helper`, é possível acessar os ajudantes do Rails e da sua aplicação.

```irb
irb> helper.time_ago_in_words 30.days.ago
=> "about 1 month"

irb> helper.my_custom_helper
=> "my custom helper"
```

### `bin/rails dbconsole`

`bin/rails dbconsole` descobre qual banco de dados você está usando e o coloca no interface de linha de comando que você usaria com ele (e também descobre os parâmetros de linha de comando para fornecer a ele!). Ele suporta MySQL (incluindo MariaDB), PostgreSQL e SQLite3.

INFO: Você também pode usar o alias "db" para invocar o dbconsole: `bin/rails db`.

Se você estiver usando vários bancos de dados, `bin/rails dbconsole` se conectará ao banco de dados principal por padrão. Você pode especificar qual banco de dados se conectar usando `--database` ou `--db`:

```bash
$ bin/rails dbconsole --database=animals
```

### `bin/rails runner`

`runner` executa código Ruby no contexto do Rails de forma não interativa. Por exemplo:

```bash
$ bin/rails runner "Model.long_running_method"
```

INFO: Você também pode usar o alias "r" para invocar o runner: `bin/rails r`.

Você pode especificar o ambiente em que o comando `runner` deve operar usando o sinalizador `-e`.

```bash
$ bin/rails runner -e staging "Model.long_running_method"
```

Você pode executar código Ruby escrito em um arquivo com o runner.

```bash
$ bin/rails runner lib/code_to_be_run.rb
```

### `bin/rails destroy`

Pense em `destroy` como o oposto de `generate`. Ele descobrirá o que o generate fez e desfará.

INFO: Você também pode usar o alias "d" para invocar o comando destroy: `bin/rails d`.

```bash
$ bin/rails generate model Oops
      invoke  active_record
      create    db/migrate/20120528062523_create_oops.rb
      create    app/models/oops.rb
      invoke    test_unit
      create      test/models/oops_test.rb
      create      test/fixtures/oops.yml
```

```bash
$ bin/rails destroy model Oops
      invoke  active_record
      remove    db/migrate/20120528062523_create_oops.rb
      remove    app/models/oops.rb
      invoke    test_unit
      remove      test/models/oops_test.rb
      remove      test/fixtures/oops.yml
```

### `bin/rails about`

`bin/rails about` fornece informações sobre números de versão para Ruby, RubyGems, Rails, os subcomponentes do Rails, a pasta do seu aplicativo, o nome do ambiente atual do Rails, o adaptador de banco de dados do seu aplicativo e a versão do esquema. É útil quando você precisa pedir ajuda, verificar se um patch de segurança pode afetar você ou quando precisa de algumas estatísticas para uma instalação existente do Rails.

```bash
$ bin/rails about
Sobre o ambiente do seu aplicativo
Versão do Rails             7.0.0
Versão do Ruby              2.7.0 (x86_64-linux)
Versão do RubyGems          2.7.3
Versão do Rack              2.0.4
Tempo de execução do JavaScript        Node.js (V8)
Middleware:               Rack::Sendfile, ActionDispatch::Static, ActionDispatch::Executor, ActiveSupport::Cache::Strategy::LocalCache::Middleware, Rack::Runtime, Rack::MethodOverride, ActionDispatch::RequestId, ActionDispatch::RemoteIp, Sprockets::Rails::QuietAssets, Rails::Rack::Logger, ActionDispatch::ShowExceptions, WebConsole::Middleware, ActionDispatch::DebugExceptions, ActionDispatch::Reloader, ActionDispatch::Callbacks, ActiveRecord::Migration::CheckPending, ActionDispatch::Cookies, ActionDispatch::Session::CookieStore, ActionDispatch::Flash, Rack::Head, Rack::ConditionalGet, Rack::ETag
Raiz do aplicativo          /home/foobar/my_app
Ambiente               development
Adaptador de banco de dados          sqlite3
Versão do esquema do banco de dados   20180205173523
```

### `bin/rails assets:`

Você pode pré-compilar os assets em `app/assets` usando `bin/rails assets:precompile` e remover assets compilados mais antigos usando `bin/rails assets:clean`. O comando `assets:clean` permite implantações progressivas que ainda podem estar vinculadas a um asset antigo enquanto os novos assets estão sendo construídos.

Se você quiser limpar completamente `public/assets`, pode usar `bin/rails assets:clobber`.

### `bin/rails db:`

Os comandos mais comuns do namespace `db:` do Rails são `migrate` e `create`, e vale a pena experimentar todos os comandos de migração do Rails (`up`, `down`, `redo`, `reset`). `bin/rails db:version` é útil para solucionar problemas, informando a versão atual do banco de dados.

Mais informações sobre migrações podem ser encontradas no guia [Migrations](active_record_migrations.html).

### `bin/rails notes`

`bin/rails notes` pesquisa seu código por comentários que começam com uma palavra-chave específica. Você pode consultar `bin/rails notes --help` para obter informações sobre o uso.

Por padrão, ele pesquisará nos diretórios `app`, `config`, `db`, `lib` e `test` por anotações FIXME, OPTIMIZE e TODO em arquivos com extensão `.builder`, `.rb`, `.rake`, `.yml`, `.yaml`, `.ruby`, `.css`, `.js` e `.erb`.

```bash
$ bin/rails notes
app/controllers/admin/users_controller.rb:
  * [ 20] [TODO] qualquer outra maneira de fazer isso?
  * [132] [FIXME] alta prioridade para a próxima implantação

lib/school.rb:
  * [ 13] [OPTIMIZE] refatorar este código para torná-lo mais rápido
  * [ 17] [FIXME]
```

#### Anotações

Você pode passar anotações específicas usando o argumento `--annotations`. Por padrão, ele pesquisará por FIXME, OPTIMIZE e TODO.
Observe que as anotações diferenciam maiúsculas de minúsculas.

```bash
$ bin/rails notes --annotations FIXME RELEASE
app/controllers/admin/users_controller.rb:
  * [101] [RELEASE] Precisamos analisar isso antes do próximo lançamento
  * [132] [FIXME] alta prioridade para a próxima implantação

lib/school.rb:
  * [ 17] [FIXME]
```

#### Tags

Você pode adicionar mais tags padrão para pesquisar usando `config.annotations.register_tags`. Ele recebe uma lista de tags.

```ruby
config.annotations.register_tags("DEPRECATEME", "TESTME")
```

```bash
$ bin/rails notes
app/controllers/admin/users_controller.rb:
  * [ 20] [TODO] fazer teste A/B nisso
  * [ 42] [TESTME] isso precisa de mais testes funcionais
  * [132] [DEPRECATEME] garantir que este método seja obsoleto no próximo lançamento
```

#### Diretórios

Você pode adicionar mais diretórios padrão para pesquisar usando `config.annotations.register_directories`. Ele recebe uma lista de nomes de diretórios.

```ruby
config.annotations.register_directories("spec", "vendor")
```

```bash
$ bin/rails notes
app/controllers/admin/users_controller.rb:
  * [ 20] [TODO] qualquer outra maneira de fazer isso?
  * [132] [FIXME] alta prioridade para a próxima implantação

lib/school.rb:
  * [ 13] [OPTIMIZE] Refatorar este código para torná-lo mais rápido
  * [ 17] [FIXME]

spec/models/user_spec.rb:
  * [122] [TODO] Verificar se o usuário com assinatura funciona

vendor/tools.rb:
  * [ 56] [TODO] Livrar-se dessa dependência
```

#### Extensões

Você pode adicionar mais extensões de arquivo padrão para pesquisar usando `config.annotations.register_extensions`. Ele recebe uma lista de extensões com sua correspondente regex para fazer a correspondência.

```ruby
config.annotations.register_extensions("scss", "sass") { |annotation| /\/\/\s*(#{annotation}):?\s*(.*)$/ }
```

```bash
$ bin/rails notes
app/controllers/admin/users_controller.rb:
  * [ 20] [TODO] qualquer outra maneira de fazer isso?
  * [132] [FIXME] alta prioridade para próxima implantação

app/assets/stylesheets/application.css.sass:
  * [ 34] [TODO] Usar pseudo elemento para esta classe

app/assets/stylesheets/application.css.scss:
  * [  1] [TODO] Dividir em vários componentes

lib/school.rb:
  * [ 13] [OPTIMIZE] Refatorar este código para torná-lo mais rápido
  * [ 17] [FIXME]

spec/models/user_spec.rb:
  * [122] [TODO] Verificar se o usuário com assinatura funciona

vendor/tools.rb:
  * [ 56] [TODO] Livrar-se dessa dependência
```
### `bin/rails routes`

`bin/rails routes` irá listar todas as rotas definidas, o que é útil para rastrear problemas de roteamento em seu aplicativo ou para fornecer uma boa visão geral das URLs em um aplicativo com o qual você está tentando se familiarizar.

### `bin/rails test`

INFO: Uma boa descrição dos testes unitários no Rails é fornecida em [Um Guia para Testar Aplicações Rails](testing.html)

O Rails vem com um framework de teste chamado minitest. A estabilidade do Rails se deve ao uso de testes. Os comandos disponíveis no namespace `test:` ajudam a executar os diferentes testes que você, esperançosamente, escreverá.

### `bin/rails tmp:`

O diretório `Rails.root/tmp` é, assim como o diretório `/tmp` do *nix, o local para arquivos temporários como arquivos de ID de processo e ações em cache.

Os comandos com o namespace `tmp:` ajudarão você a limpar e criar o diretório `Rails.root/tmp`:

* `bin/rails tmp:cache:clear` limpa `tmp/cache`.
* `bin/rails tmp:sockets:clear` limpa `tmp/sockets`.
* `bin/rails tmp:screenshots:clear` limpa `tmp/screenshots`.
* `bin/rails tmp:clear` limpa todos os arquivos de cache, sockets e screenshots.
* `bin/rails tmp:create` cria diretórios tmp para cache, sockets e pids.

### Diversos

* `bin/rails initializers` imprime todos os inicializadores definidos na ordem em que são invocados pelo Rails.
* `bin/rails middleware` lista a pilha de middleware Rack habilitada para o seu aplicativo.
* `bin/rails stats` é ótimo para visualizar estatísticas do seu código, exibindo coisas como KLOCs (milhares de linhas de código) e a proporção entre código e testes.
* `bin/rails secret` fornecerá uma chave pseudoaleatória para usar como segredo de sessão.
* `bin/rails time:zones:all` lista todos os fusos horários que o Rails conhece.

### Tarefas Rake Personalizadas

Tarefas Rake personalizadas têm a extensão `.rake` e são colocadas em
`Rails.root/lib/tasks`. Você pode criar essas tarefas Rake personalizadas com o comando `bin/rails generate task`.

```ruby
desc "Eu sou uma descrição curta, mas abrangente para minha tarefa legal"
task task_name: [:prerequisite_task, :another_task_we_depend_on] do
  # Todo o seu código mágico aqui
  # Qualquer código Ruby válido é permitido
end
```

Para passar argumentos para sua tarefa Rake personalizada:

```ruby
task :task_name, [:arg_1] => [:prerequisite_1, :prerequisite_2] do |task, args|
  argument_1 = args.arg_1
end
```

Você pode agrupar tarefas colocando-as em namespaces:

```ruby
namespace :db do
  desc "Esta tarefa não faz nada"
  task :nothing do
    # Sério, nada
  end
end
```

A invocação das tarefas será assim:

```bash
$ bin/rails task_name
$ bin/rails "task_name[value 1]" # a string de argumento inteira deve ser colocada entre aspas
$ bin/rails "task_name[value 1,value2,value3]" # separe vários argumentos com uma vírgula
$ bin/rails db:nothing
```

Se você precisar interagir com os modelos do seu aplicativo, realizar consultas ao banco de dados, etc., sua tarefa deve depender da tarefa `environment`, que carregará o código do seu aplicativo.

```ruby
task task_that_requires_app_code: [:environment] do
  User.create!
end
```
