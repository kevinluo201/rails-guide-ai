**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 48f8290cbf9190673c32a3eb9777acba
Rails no Rack
=============

Este guia aborda a integração do Rails com o Rack e a interface com outros componentes do Rack.

Após ler este guia, você saberá:

* Como usar Middlewares do Rack em suas aplicações Rails.
* A pilha interna de Middlewares do Action Pack.
* Como definir uma pilha de Middlewares personalizada.

--------------------------------------------------------------------------------

AVISO: Este guia pressupõe um conhecimento básico do protocolo Rack e conceitos do Rack, como middlewares, mapas de URL e `Rack::Builder`.

Introdução ao Rack
------------------

O Rack fornece uma interface mínima, modular e adaptável para desenvolver aplicações web em Ruby. Ao envolver as requisições e respostas HTTP da maneira mais simples possível, ele unifica e destila a API para servidores web, frameworks web e software intermediário (os chamados middlewares) em uma única chamada de método.

Explicar como o Rack funciona não está realmente no escopo deste guia. Caso você não esteja familiarizado com os conceitos básicos do Rack, você deve verificar a seção [Recursos](#recursos) abaixo.

Rails no Rack
-------------

### Objeto Rack da Aplicação Rails

`Rails.application` é o objeto principal de aplicação Rack de uma aplicação Rails. Qualquer servidor web compatível com o Rack deve usar o objeto `Rails.application` para servir uma aplicação Rails.

### `bin/rails server`

`bin/rails server` faz o trabalho básico de criar um objeto `Rack::Server` e iniciar o servidor web.

Veja como `bin/rails server` cria uma instância de `Rack::Server`:

```ruby
Rails::Server.new.tap do |server|
  require APP_PATH
  Dir.chdir(Rails.application.root)
  server.start
end
```

O `Rails::Server` herda de `Rack::Server` e chama o método `Rack::Server#start` desta forma:

```ruby
class Server < ::Rack::Server
  def start
    # ...
    super
  end
end
```

### `rackup`

Para usar o `rackup` em vez do `bin/rails server` do Rails, você pode colocar o seguinte dentro do arquivo `config.ru` do diretório raiz da sua aplicação Rails:

```ruby
# Rails.root/config.ru
require_relative "config/environment"
run Rails.application
```

E inicie o servidor:

```bash
$ rackup config.ru
```

Para saber mais sobre as diferentes opções do `rackup`, você pode executar:

```bash
$ rackup --help
```

### Desenvolvimento e Recarregamento Automático

Os middlewares são carregados uma vez e não são monitorados por alterações. Você precisará reiniciar o servidor para que as alterações sejam refletidas na aplicação em execução.

Pilha de Middlewares do Action Dispatcher
-----------------------------------------

Muitos dos componentes internos do Action Dispatcher são implementados como middlewares do Rack. O `Rails::Application` usa `ActionDispatch::MiddlewareStack` para combinar vários middlewares internos e externos para formar uma aplicação Rails completa no Rack.

NOTA: `ActionDispatch::MiddlewareStack` é o equivalente do Rails ao `Rack::Builder`, mas é construído para melhor flexibilidade e mais recursos para atender aos requisitos do Rails.

### Inspecionando a Pilha de Middlewares

O Rails possui um comando útil para inspecionar a pilha de middlewares em uso:

```bash
$ bin/rails middleware
```

Para uma aplicação Rails recém-gerada, isso pode produzir algo como:

```ruby
use ActionDispatch::HostAuthorization
use Rack::Sendfile
use ActionDispatch::Static
use ActionDispatch::Executor
use ActionDispatch::ServerTiming
use ActiveSupport::Cache::Strategy::LocalCache::Middleware
use Rack::Runtime
use Rack::MethodOverride
use ActionDispatch::RequestId
use ActionDispatch::RemoteIp
use Sprockets::Rails::QuietAssets
use Rails::Rack::Logger
use ActionDispatch::ShowExceptions
use WebConsole::Middleware
use ActionDispatch::DebugExceptions
use ActionDispatch::ActionableExceptions
use ActionDispatch::Reloader
use ActionDispatch::Callbacks
use ActiveRecord::Migration::CheckPending
use ActionDispatch::Cookies
use ActionDispatch::Session::CookieStore
use ActionDispatch::Flash
use ActionDispatch::ContentSecurityPolicy::Middleware
use Rack::Head
use Rack::ConditionalGet
use Rack::ETag
use Rack::TempfileReaper
run MyApp::Application.routes
```

Os middlewares padrão mostrados aqui (e alguns outros) são resumidos na seção [Middlewares Internos](#pilha-de-middlewares-internos), abaixo.

### Configurando a Pilha de Middlewares

O Rails fornece uma interface de configuração simples [`config.middleware`][] para adicionar, remover e modificar os middlewares na pilha de middlewares através do arquivo `application.rb` ou do arquivo de configuração específico do ambiente `environments/<ambiente>.rb`.


#### Adicionando um Middleware

Você pode adicionar um novo middleware à pilha de middlewares usando um dos seguintes métodos:

* `config.middleware.use(new_middleware, args)` - Adiciona o novo middleware no final da pilha de middlewares.

* `config.middleware.insert_before(existing_middleware, new_middleware, args)` - Adiciona o novo middleware antes do middleware existente especificado na pilha de middlewares.

* `config.middleware.insert_after(existing_middleware, new_middleware, args)` - Adiciona o novo middleware após o middleware existente especificado na pilha de middlewares.

```ruby
# config/application.rb

# Adiciona Rack::BounceFavicon no final
config.middleware.use Rack::BounceFavicon

# Adiciona Lifo::Cache após ActionDispatch::Executor.
# Passa o argumento { page_cache: false } para Lifo::Cache.
config.middleware.insert_after ActionDispatch::Executor, Lifo::Cache, page_cache: false
```

#### Trocando um Middleware

Você pode trocar um middleware existente na pilha de middlewares usando `config.middleware.swap`.

```ruby
# config/application.rb

# Substitui ActionDispatch::ShowExceptions por Lifo::ShowExceptions
config.middleware.swap ActionDispatch::ShowExceptions, Lifo::ShowExceptions
```

#### Movendo um Middleware

Você pode mover um middleware existente na pilha de middlewares usando `config.middleware.move_before` e `config.middleware.move_after`.

```ruby
# config/application.rb

# Move ActionDispatch::ShowExceptions para antes de Lifo::ShowExceptions
config.middleware.move_before Lifo::ShowExceptions, ActionDispatch::ShowExceptions
```

```ruby
# config/application.rb

# Move ActionDispatch::ShowExceptions para depois de Lifo::ShowExceptions
config.middleware.move_after Lifo::ShowExceptions, ActionDispatch::ShowExceptions
```

#### Excluindo um Middleware
Adicione as seguintes linhas à configuração do seu aplicativo:

```ruby
# config/application.rb
config.middleware.delete Rack::Runtime
```

Agora, se você inspecionar a pilha de middlewares, verá que `Rack::Runtime` não faz mais parte dela.

```bash
$ bin/rails middleware
(in /Users/lifo/Rails/blog)
use ActionDispatch::Static
use #<ActiveSupport::Cache::Strategy::LocalCache::Middleware:0x00000001c304c8>
...
run Rails.application.routes
```

Se você deseja remover middlewares relacionados à sessão, faça o seguinte:

```ruby
# config/application.rb
config.middleware.delete ActionDispatch::Cookies
config.middleware.delete ActionDispatch::Session::CookieStore
config.middleware.delete ActionDispatch::Flash
```

E para remover middlewares relacionados ao navegador,

```ruby
# config/application.rb
config.middleware.delete Rack::MethodOverride
```

Se você deseja que um erro seja gerado ao tentar excluir um item que não existe, use `delete!` em vez disso.

```ruby
# config/application.rb
config.middleware.delete! ActionDispatch::Executor
```

### Pilha de Middlewares Internos

Grande parte da funcionalidade do Action Controller é implementada como Middlewares. A lista a seguir explica o propósito de cada um deles:

**`ActionDispatch::HostAuthorization`**

* Protege contra ataques de DNS rebinding, permitindo explicitamente os hosts para os quais uma solicitação pode ser enviada. Consulte o [guia de configuração](configuring.html#actiondispatch-hostauthorization) para obter instruções de configuração.

**`Rack::Sendfile`**

* Define o cabeçalho X-Sendfile específico do servidor. Configure isso por meio da opção [`config.action_dispatch.x_sendfile_header`][].

**`ActionDispatch::Static`**

* Usado para servir arquivos estáticos do diretório public. Desativado se [`config.public_file_server.enabled`][] for `false`.

**`Rack::Lock`**

* Define a flag `env["rack.multithread"]` como `false` e envolve a aplicação em um Mutex.

**`ActionDispatch::Executor`**

* Usado para recarregar o código de forma segura em threads durante o desenvolvimento.

**`ActionDispatch::ServerTiming`**

* Define um cabeçalho [`Server-Timing`](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Server-Timing) contendo métricas de desempenho para a solicitação.

**`ActiveSupport::Cache::Strategy::LocalCache::Middleware`**

* Usado para cache em memória. Este cache não é thread-safe.

**`Rack::Runtime`**

* Define um cabeçalho X-Runtime, contendo o tempo (em segundos) necessário para executar a solicitação.

**`Rack::MethodOverride`**

* Permite que o método seja substituído se `params[:_method]` estiver definido. Este é o middleware que suporta os tipos de método HTTP PUT e DELETE.

**`ActionDispatch::RequestId`**

* Torna um cabeçalho `X-Request-Id` exclusivo disponível para a resposta e habilita o método `ActionDispatch::Request#request_id`.

**`ActionDispatch::RemoteIp`**

* Verifica ataques de spoofing de IP.

**`Sprockets::Rails::QuietAssets`**

* Suprime a saída do logger para solicitações de ativos.

**`Rails::Rack::Logger`**

* Notifica os logs de que a solicitação foi iniciada. Após a conclusão da solicitação, todos os logs são liberados.

**`ActionDispatch::ShowExceptions`**

* Resgata qualquer exceção retornada pela aplicação e chama um aplicativo de exceções que a envolverá em um formato para o usuário final.

**`ActionDispatch::DebugExceptions`**

* Responsável por registrar exceções e mostrar uma página de depuração caso a solicitação seja local.

**`ActionDispatch::ActionableExceptions`**

* Fornece uma maneira de despachar ações das páginas de erro do Rails.

**`ActionDispatch::Reloader`**

* Fornece callbacks de preparação e limpeza, destinados a auxiliar no recarregamento de código durante o desenvolvimento.

**`ActionDispatch::Callbacks`**

* Fornece callbacks a serem executados antes e depois de despachar a solicitação.

**`ActiveRecord::Migration::CheckPending`**

* Verifica migrações pendentes e gera um `ActiveRecord::PendingMigrationError` se houver migrações pendentes.

**`ActionDispatch::Cookies`**

* Define cookies para a solicitação.

**`ActionDispatch::Session::CookieStore`**

* Responsável por armazenar a sessão em cookies.

**`ActionDispatch::Flash`**

* Configura as chaves do flash. Disponível apenas se [`config.session_store`][] estiver definido com um valor.

**`ActionDispatch::ContentSecurityPolicy::Middleware`**

* Fornece uma DSL para configurar um cabeçalho Content-Security-Policy.

**`Rack::Head`**

* Converte solicitações HEAD em solicitações `GET` e as serve como tal.

**`Rack::ConditionalGet`**

* Adiciona suporte para "Conditional `GET`" para que o servidor responda com nada se a página não foi alterada.

**`Rack::ETag`**

* Adiciona o cabeçalho ETag em todos os corpos de String. ETags são usados para validar o cache.

**`Rack::TempfileReaper`**

* Limpa os arquivos temporários usados para armazenar solicitações multipart.

DICA: É possível usar qualquer um dos middlewares acima em sua pilha personalizada do Rack.

Recursos
---------

### Aprendendo Rack

* [Site oficial do Rack](https://rack.github.io)
* [Apresentando o Rack](http://chneukirchen.org/blog/archive/2007/02/introducing-rack.html)

### Entendendo Middlewares

* [Railscast sobre Middlewares do Rack](http://railscasts.com/episodes/151-rack-middleware)
[`config.middleware`]: configuring.html#config-middleware
[`config.action_dispatch.x_sendfile_header`]: configuring.html#config-action-dispatch-x-sendfile-header
[`config.public_file_server.enabled`]: configuring.html#config-public-file-server-enabled
[`config.session_store`]: configuring.html#config-session-store
