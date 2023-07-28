**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 9f53b3a12c263256fbbe154cfc8b2f4d
Autoloading e Recarregamento de Constantes
===========================================

Este guia documenta como o carregamento automático e o recarregamento funcionam no modo `zeitwerk`.

Após ler este guia, você saberá:

* Configuração relacionada ao Rails
* Estrutura do projeto
* Carregamento automático, recarregamento e carregamento ansioso
* Herança de tabela única
* E muito mais

--------------------------------------------------------------------------------

Introdução
----------

INFO. Este guia documenta o carregamento automático, recarregamento e carregamento ansioso em aplicações Rails.

Em um programa Ruby comum, você carrega explicitamente os arquivos que definem as classes e módulos que deseja usar. Por exemplo, o seguinte controlador se refere a `ApplicationController` e `Post`, e você normalmente emite chamadas `require` para eles:

```ruby
# NÃO FAÇA ISSO.
require "application_controller"
require "post"
# NÃO FAÇA ISSO.

class PostsController < ApplicationController
  def index
    @posts = Post.all
  end
end
```

Isso não acontece em aplicações Rails, onde as classes e módulos da aplicação estão disponíveis em todos os lugares sem chamadas `require`:

```ruby
class PostsController < ApplicationController
  def index
    @posts = Post.all
  end
end
```

O Rails _carrega automaticamente_ eles para você, se necessário. Isso é possível graças a um par de carregadores [Zeitwerk](https://github.com/fxn/zeitwerk) que o Rails configura para você, que fornecem carregamento automático, recarregamento e carregamento ansioso.

Por outro lado, esses carregadores não gerenciam mais nada. Em particular, eles não gerenciam a biblioteca padrão do Ruby, dependências de gemas, os próprios componentes do Rails ou até mesmo (por padrão) o diretório `lib` da aplicação. Esse código deve ser carregado como de costume.


Estrutura do Projeto
--------------------

Em uma aplicação Rails, os nomes dos arquivos devem corresponder às constantes que eles definem, com os diretórios atuando como namespaces.

Por exemplo, o arquivo `app/helpers/users_helper.rb` deve definir `UsersHelper` e o arquivo `app/controllers/admin/payments_controller.rb` deve definir `Admin::PaymentsController`.

Por padrão, o Rails configura o Zeitwerk para infletir os nomes dos arquivos com `String#camelize`. Por exemplo, ele espera que `app/controllers/users_controller.rb` defina a constante `UsersController` porque é isso que `"users_controller".camelize` retorna.

A seção _Customizando Inflections_ abaixo documenta maneiras de substituir essa configuração padrão.

Por favor, verifique a [documentação do Zeitwerk](https://github.com/fxn/zeitwerk#file-structure) para mais detalhes.

config.autoload_paths
---------------------

Nos referimos à lista de diretórios da aplicação cujo conteúdo deve ser carregado automaticamente e (opcionalmente) recarregado como _caminhos de carregamento automático_. Por exemplo, `app/models`. Esses diretórios representam o namespace raiz: `Object`.

INFO. Os caminhos de carregamento automático são chamados de _diretórios raiz_ na documentação do Zeitwerk, mas vamos usar "caminho de carregamento automático" neste guia.

Dentro de um caminho de carregamento automático, os nomes dos arquivos devem corresponder às constantes que eles definem, como documentado [aqui](https://github.com/fxn/zeitwerk#file-structure).

Por padrão, os caminhos de carregamento automático de uma aplicação consistem em todos os subdiretórios de `app` que existem quando a aplicação é iniciada ---exceto por `assets`, `javascript` e `views`--- além dos caminhos de carregamento automático das engines nas quais ela pode depender.

Por exemplo, se `UsersHelper` for implementado em `app/helpers/users_helper.rb`, o módulo pode ser carregado automaticamente, você não precisa (e não deve) escrever uma chamada `require` para ele:

```bash
$ bin/rails runner 'p UsersHelper'
UsersHelper
```

O Rails adiciona automaticamente diretórios personalizados em `app` aos caminhos de carregamento automático. Por exemplo, se sua aplicação tiver `app/presenters`, você não precisa configurar nada para carregar automaticamente os presenters; isso funciona sem problemas.

A matriz de caminhos de carregamento automático padrão pode ser estendida adicionando a `config.autoload_paths`, em `config/application.rb` ou `config/environments/*.rb`. Por exemplo:

```ruby
module MyApplication
  class Application < Rails::Application
    config.autoload_paths << "#{root}/extras"
  end
end
```

Além disso, as engines podem adicionar no corpo da classe da engine e em seus próprios `config/environments/*.rb`.

WARNING. Por favor, não altere `ActiveSupport::Dependencies.autoload_paths`; a interface pública para alterar os caminhos de carregamento automático é `config.autoload_paths`.

WARNING: Você não pode carregar automaticamente código nos caminhos de carregamento automático enquanto a aplicação está sendo iniciada. Em particular, diretamente em `config/initializers/*.rb`. Por favor, verifique [_Carregamento automático quando a aplicação é iniciada_](#carregamento-automático-quando-a-aplicação-é-iniciada) abaixo para maneiras válidas de fazer isso.

Os caminhos de carregamento automático são gerenciados pelo carregador automático `Rails.autoloaders.main`.

config.autoload_lib(ignore:)
----------------------------

Por padrão, o diretório `lib` não faz parte dos caminhos de carregamento automático de aplicações ou engines.

O método de configuração `config.autoload_lib` adiciona o diretório `lib` a `config.autoload_paths` e `config.eager_load_paths`. Ele deve ser invocado a partir de `config/application.rb` ou `config/environments/*.rb`, e não está disponível para engines.

Normalmente, `lib` possui subdiretórios que não devem ser gerenciados pelos carregadores automáticos. Por favor, passe o nome deles em relação a `lib` no argumento de palavra-chave `ignore` necessário. Por exemplo:

```ruby
config.autoload_lib(ignore: %w(assets tasks))
```

Por quê? Embora `assets` e `tasks` compartilhem o diretório `lib` com o código regular, o conteúdo deles não deve ser carregado automaticamente ou carregado ansiosamente. `Assets` e `Tasks` não são namespaces Ruby lá. O mesmo vale para geradores, se você tiver algum:
```ruby
config.autoload_lib(ignore: %w(assets tasks generators))
```

`config.autoload_lib` não está disponível antes da versão 7.1, mas você ainda pode emulá-lo desde que a aplicação utilize o Zeitwerk:

```ruby
# config/application.rb
module MyApp
  class Application < Rails::Application
    lib = root.join("lib")

    config.autoload_paths << lib
    config.eager_load_paths << lib

    Rails.autoloaders.main.ignore(
      lib.join("assets"),
      lib.join("tasks"),
      lib.join("generators")
    )

    ...
  end
end
```

config.autoload_once_paths
--------------------------

Você pode querer ser capaz de carregar automaticamente classes e módulos sem recarregá-los. A configuração `autoload_once_paths` armazena código que pode ser carregado automaticamente, mas não será recarregado.

Por padrão, essa coleção está vazia, mas você pode estendê-la adicionando a `config.autoload_once_paths`. Você pode fazer isso em `config/application.rb` ou `config/environments/*.rb`. Por exemplo:

```ruby
module MyApplication
  class Application < Rails::Application
    config.autoload_once_paths << "#{root}/app/serializers"
  end
end
```

Além disso, os engines podem adicionar no corpo da classe do engine e em seus próprios `config/environments/*.rb`.

INFO. Se `app/serializers` for adicionado a `config.autoload_once_paths`, o Rails não considera mais isso um caminho de carregamento automático, apesar de ser um diretório personalizado em `app`. Essa configuração substitui essa regra.

Isso é importante para classes e módulos que são armazenados em locais que sobrevivem às recargas, como o próprio framework Rails.

Por exemplo, os serializadores do Active Job são armazenados dentro do Active Job:

```ruby
# config/initializers/custom_serializers.rb
Rails.application.config.active_job.custom_serializers << MoneySerializer
```

e o próprio Active Job não é recarregado quando há uma recarga, apenas o código da aplicação e dos engines nos caminhos de carregamento automático são.

Tornar `MoneySerializer` recarregável seria confuso, porque recarregar uma versão editada não teria efeito sobre a classe armazenada no Active Job. Na verdade, se `MoneySerializer` fosse recarregável, a partir do Rails 7, esse inicializador geraria um `NameError`.

Outro caso de uso é quando os engines decoram classes do framework:

```ruby
initializer "decorate ActionController::Base" do
  ActiveSupport.on_load(:action_controller_base) do
    include MyDecoration
  end
end
```

Nesse caso, o objeto do módulo armazenado em `MyDecoration` no momento em que o inicializador é executado se torna um ancestral de `ActionController::Base`, e recarregar `MyDecoration` é inútil, não afetará essa cadeia de ancestrais.

Classes e módulos dos caminhos de carregamento automático único podem ser carregados automaticamente em `config/initializers`. Portanto, com essa configuração, isso funciona:

```ruby
# config/initializers/custom_serializers.rb
Rails.application.config.active_job.custom_serializers << MoneySerializer
```

INFO: Tecnicamente, você pode carregar automaticamente classes e módulos gerenciados pelo carregador automático `once` em qualquer inicializador que seja executado após `:bootstrap_hook`.

Os caminhos de carregamento automático único são gerenciados por `Rails.autoloaders.once`.

config.autoload_lib_once(ignore:)
---------------------------------

O método `config.autoload_lib_once` é semelhante a `config.autoload_lib`, exceto que adiciona `lib` a `config.autoload_once_paths` em vez disso. Ele deve ser invocado a partir de `config/application.rb` ou `config/environments/*.rb` e não está disponível para engines.

Ao chamar `config.autoload_lib_once`, classes e módulos em `lib` podem ser carregados automaticamente, mesmo a partir de inicializadores da aplicação, mas não serão recarregados.

`config.autoload_lib_once` não está disponível antes da versão 7.1, mas você ainda pode emulá-lo desde que a aplicação utilize o Zeitwerk:

```ruby
# config/application.rb
module MyApp
  class Application < Rails::Application
    lib = root.join("lib")

    config.autoload_once_paths << lib
    config.eager_load_paths << lib

    Rails.autoloaders.once.ignore(
      lib.join("assets"),
      lib.join("tasks"),
      lib.join("generators")
    )

    ...
  end
end
```

$LOAD_PATH{#load_path}
----------

Os caminhos de carregamento automático são adicionados a `$LOAD_PATH` por padrão. No entanto, o Zeitwerk usa nomes de arquivo absolutos internamente, e sua aplicação não deve fazer chamadas `require` para arquivos que podem ser carregados automaticamente, então esses diretórios na verdade não são necessários lá. Você pode optar por não incluí-los com essa configuração:

```ruby
config.add_autoload_paths_to_load_path = false
```

Isso pode acelerar um pouco as chamadas `require` legítimas, pois há menos pesquisas. Além disso, se sua aplicação usa o [Bootsnap](https://github.com/Shopify/bootsnap), isso evita que a biblioteca construa índices desnecessários, levando a um uso menor de memória.

O diretório `lib` não é afetado por essa configuração, ele é sempre adicionado a `$LOAD_PATH`.

Recarregamento
---------

O Rails recarrega automaticamente classes e módulos se os arquivos da aplicação nos caminhos de carregamento automático forem alterados.

Mais precisamente, se o servidor web estiver em execução e os arquivos da aplicação tiverem sido modificados, o Rails descarrega todas as constantes carregadas automaticamente gerenciadas pelo carregador automático `main` logo antes da próxima requisição ser processada. Dessa forma, as classes ou módulos da aplicação usados durante essa requisição serão carregados automaticamente novamente, assim, pegando sua implementação atual no sistema de arquivos.

O recarregamento pode ser ativado ou desativado. A configuração que controla esse comportamento é [`config.enable_reloading`][], que é `true` por padrão no modo `development` e `false` por padrão no modo `production`. Para compatibilidade com versões anteriores, o Rails também suporta `config.cache_classes`, que é equivalente a `!config.enable_reloading`.

O Rails usa um monitor de arquivo com eventos para detectar alterações nos arquivos por padrão. Ele também pode ser configurado para detectar alterações nos arquivos percorrendo os caminhos de carregamento automático. Isso é controlado pela configuração [`config.file_watcher`][].

Em um console do Rails, não há monitor de arquivo ativo, independentemente do valor de `config.enable_reloading`. Isso ocorre porque, normalmente, seria confuso recarregar o código no meio de uma sessão do console. Semelhante a uma requisição individual, geralmente você deseja que uma sessão do console seja atendida por um conjunto consistente e imutável de classes e módulos da aplicação.
No entanto, você pode forçar uma recarga no console executando `reload!`:

```irb
irb(main):001:0> User.object_id
=> 70136277390120
irb(main):002:0> reload!
Recarregando...
=> true
irb(main):003:0> User.object_id
=> 70136284426020
```

Como você pode ver, o objeto da classe armazenado na constante `User` é diferente após a recarga.


### Recarregando e Objetos Antigos

É muito importante entender que o Ruby não tem uma maneira de recarregar verdadeiramente classes e módulos na memória e fazer com que isso seja refletido em todos os lugares onde eles já são usados. Tecnicamente, "descarregar" a classe `User` significa remover a constante `User` via `Object.send(:remove_const, "User")`.

Por exemplo, veja esta sessão do console do Rails:

```irb
irb> joe = User.new
irb> reload!
irb> alice = User.new
irb> joe.class == alice.class
=> false
```

`joe` é uma instância da classe `User` original. Quando há uma recarga, a constante `User` então avalia para uma classe recarregada diferente. `alice` é uma instância do novo `User` carregado, mas `joe` não é - sua classe está desatualizada. Você pode definir `joe` novamente, iniciar uma subseção do IRB ou simplesmente iniciar um novo console em vez de chamar `reload!`.

Outra situação em que você pode encontrar esse problema é ao criar subclasses de classes recarregáveis em um local que não é recarregado:

```ruby
# lib/vip_user.rb
class VipUser < User
end
```

se `User` for recarregado, uma vez que `VipUser` não é, a superclasse de `VipUser` será o objeto de classe original desatualizado.

Resumindo: **não armazene em cache classes ou módulos recarregáveis**.

## Carregamento Automático ao Iniciar a Aplicação

Durante a inicialização, as aplicações podem carregar automaticamente a partir dos caminhos de carregamento automático uma vez, que são gerenciados pelo carregador automático `once`. Por favor, verifique a seção [`config.autoload_once_paths`](#config-autoload-once-paths) acima.

No entanto, você não pode carregar automaticamente a partir dos caminhos de carregamento automático, que são gerenciados pelo carregador automático `main`. Isso se aplica ao código em `config/initializers`, bem como aos inicializadores da aplicação ou dos motores.

Por quê? Os inicializadores são executados apenas uma vez, quando a aplicação é iniciada. Eles não são executados novamente nas recargas. Se um inicializador usasse uma classe ou módulo recarregável, as edições feitas neles não seriam refletidas nesse código inicial, tornando-se assim desatualizadas. Portanto, é proibido se referir a constantes recarregáveis durante a inicialização.

Vamos ver o que fazer em vez disso.

### Caso de Uso 1: Durante a Inicialização, Carregue Código Recarregável

#### Carregamento Automático na Inicialização e em Cada Recarga

Vamos imaginar que `ApiGateway` é uma classe recarregável e você precisa configurar seu endpoint durante a inicialização da aplicação:

```ruby
# config/initializers/api_gateway_setup.rb
ApiGateway.endpoint = "https://example.com" # NameError
```

Os inicializadores não podem se referir a constantes recarregáveis, você precisa envolver isso em um bloco `to_prepare`, que é executado na inicialização e após cada recarga:

```ruby
# config/initializers/api_gateway_setup.rb
Rails.application.config.to_prepare do
  ApiGateway.endpoint = "https://example.com" # CORRETO
end
```

NOTA: Por razões históricas, esse retorno de chamada pode ser executado duas vezes. O código que ele executa deve ser idempotente.

#### Carregamento Automático Apenas na Inicialização

Classes e módulos recarregáveis também podem ser carregados automaticamente em blocos `after_initialize`. Esses blocos são executados na inicialização, mas não são executados novamente nas recargas. Em alguns casos excepcionais, isso pode ser o que você deseja.

Verificações preliminares são um caso de uso para isso:

```ruby
# config/initializers/check_admin_presence.rb
Rails.application.config.after_initialize do
  unless Role.where(name: "admin").exists?
    abort "A função de administrador não está presente, por favor, semeie o banco de dados."
  end
end
```

### Caso de Uso 2: Durante a Inicialização, Carregue Código que Permanece em Cache

Algumas configurações recebem um objeto de classe ou módulo e o armazenam em um local que não é recarregado. É importante que esses objetos não sejam recarregáveis, porque as edições não seriam refletidas nesses objetos em cache desatualizados.

Um exemplo disso são os middlewares:

```ruby
config.middleware.use MyApp::Middleware::Foo
```

Quando você recarrega, a pilha de middlewares não é afetada, então seria confuso que `MyApp::Middleware::Foo` seja recarregável. Alterações em sua implementação não teriam efeito.

Outro exemplo são os serializadores do Active Job:

```ruby
# config/initializers/custom_serializers.rb
Rails.application.config.active_job.custom_serializers << MoneySerializer
```

Qualquer coisa que `MoneySerializer` avalie durante a inicialização é adicionada aos serializadores personalizados e esse objeto permanece lá nas recargas.

Outro exemplo são os railties ou motores que decoram classes do framework incluindo módulos. Por exemplo, o [`turbo-rails`](https://github.com/hotwired/turbo-rails) decora `ActiveRecord::Base` dessa maneira:

```ruby
initializer "turbo.broadcastable" do
  ActiveSupport.on_load(:active_record) do
    include Turbo::Broadcastable
  end
end
```

Isso adiciona um objeto de módulo à cadeia de ancestrais de `ActiveRecord::Base`. Alterações em `Turbo::Broadcastable` não teriam efeito se recarregadas, a cadeia de ancestrais ainda teria a original.

Corolário: Essas classes ou módulos **não podem ser recarregáveis**.

A maneira mais fácil de se referir a essas classes ou módulos durante a inicialização é tê-los definidos em um diretório que não pertença aos caminhos de carregamento automático. Por exemplo, `lib` é uma escolha idiomática. Por padrão, ele não pertence aos caminhos de carregamento automático, mas pertence a `$LOAD_PATH`. Basta fazer um `require` regular para carregá-lo.
Como observado acima, outra opção é ter o diretório que os define no autoload once paths e autoload. Por favor, verifique a [seção sobre config.autoload_once_paths](#config-autoload-once-paths) para mais detalhes.

### Caso de uso 3: Configurar Classes de Aplicação para Engines

Vamos supor que uma engine trabalhe com a classe de aplicação recarregável que modela usuários e tenha um ponto de configuração para isso:

```ruby
# config/initializers/my_engine.rb
MyEngine.configure do |config|
  config.user_model = User # NameError
end
```

Para funcionar bem com o código de aplicação recarregável, a engine precisa que as aplicações configurem o _nome_ dessa classe:

```ruby
# config/initializers/my_engine.rb
MyEngine.configure do |config|
  config.user_model = "User" # OK
end
```

Então, em tempo de execução, `config.user_model.constantize` retorna o objeto da classe atual.

Carregamento Antecipado
-----------------------

Em ambientes semelhantes à produção, geralmente é melhor carregar todo o código da aplicação quando a aplicação é iniciada. O carregamento antecipado coloca tudo na memória pronto para atender às solicitações imediatamente, e também é amigável ao [CoW](https://en.wikipedia.org/wiki/Copy-on-write).

O carregamento antecipado é controlado pela flag [`config.eager_load`][], que está desativada por padrão em todos os ambientes, exceto `production`. Quando uma tarefa Rake é executada, `config.eager_load` é substituída por [`config.rake_eager_load`][], que é `false` por padrão. Portanto, por padrão, em ambientes de produção, as tarefas Rake não carregam antecipadamente a aplicação.

A ordem em que os arquivos são carregados antecipadamente é indefinida.

Durante o carregamento antecipado, o Rails invoca `Zeitwerk::Loader.eager_load_all`. Isso garante que todas as dependências de gem gerenciadas pelo Zeitwerk também sejam carregadas antecipadamente.



Herança de Tabela Única
-----------------------

A herança de tabela única não funciona bem com o carregamento preguiçoso: o Active Record precisa estar ciente das hierarquias de STI para funcionar corretamente, mas quando o carregamento preguiçoso, as classes são precisamente carregadas apenas sob demanda!

Para resolver essa incompatibilidade fundamental, precisamos carregar antecipadamente os STIs. Existem algumas opções para fazer isso, com diferentes compensações. Vamos vê-las.

### Opção 1: Habilitar Carregamento Antecipado

A maneira mais fácil de carregar antecipadamente os STIs é habilitar o carregamento antecipado definindo:

```ruby
config.eager_load = true
```

em `config/environments/development.rb` e `config/environments/test.rb`.

Isso é simples, mas pode ser custoso porque carrega antecipadamente toda a aplicação na inicialização e em cada recarregamento. No entanto, a compensação pode valer a pena para aplicações pequenas.

### Opção 2: Carregar Antecipadamente um Diretório Colapsado

Armazene os arquivos que definem a hierarquia em um diretório dedicado, o que também faz sentido conceitualmente. O diretório não tem a intenção de representar um namespace, seu único propósito é agrupar o STI:

```
app/models/shapes/shape.rb
app/models/shapes/circle.rb
app/models/shapes/square.rb
app/models/shapes/triangle.rb
```

Neste exemplo, ainda queremos que `app/models/shapes/circle.rb` defina `Circle`, não `Shapes::Circle`. Essa pode ser sua preferência pessoal para manter as coisas simples e também evita refatorações em bases de código existentes. A funcionalidade de [colapsar](https://github.com/fxn/zeitwerk#collapsing-directories) do Zeitwerk nos permite fazer isso:

```ruby
# config/initializers/preload_stis.rb

shapes = "#{Rails.root}/app/models/shapes"
Rails.autoloaders.main.collapse(shapes) # Não é um namespace.

unless Rails.application.config.eager_load
  Rails.application.config.to_prepare do
    Rails.autoloaders.main.eager_load_dir(shapes)
  end
end
```

Nesta opção, carregamos antecipadamente esses poucos arquivos na inicialização e recarregamos mesmo se o STI não for usado. No entanto, a menos que sua aplicação tenha muitos STIs, isso não terá nenhum impacto mensurável.

INFO: O método `Zeitwerk::Loader#eager_load_dir` foi adicionado no Zeitwerk 2.6.2. Para versões mais antigas, você ainda pode listar o diretório `app/models/shapes` e chamar `require_dependency` em seu conteúdo.

AVISO: Se modelos forem adicionados, modificados ou excluídos do STI, o recarregamento funcionará como esperado. No entanto, se uma nova hierarquia de STI separada for adicionada à aplicação, você precisará editar o inicializador e reiniciar o servidor.

### Opção 3: Carregar Antecipadamente um Diretório Regular

Semelhante à opção anterior, mas o diretório é destinado a ser um namespace. Ou seja, espera-se que `app/models/shapes/circle.rb` defina `Shapes::Circle`.

Para esta opção, o inicializador é o mesmo, exceto que nenhum colapso é configurado:

```ruby
# config/initializers/preload_stis.rb

unless Rails.application.config.eager_load
  Rails.application.config.to_prepare do
    Rails.autoloaders.main.eager_load_dir("#{Rails.root}/app/models/shapes")
  end
end
```

Mesmas compensações.

### Opção 4: Carregar Tipos do Banco de Dados

Nesta opção, não precisamos organizar os arquivos de nenhuma maneira, mas acessamos o banco de dados:

```ruby
# config/initializers/preload_stis.rb

unless Rails.application.config.eager_load
  Rails.application.config.to_prepare do
    types = Shape.unscoped.select(:type).distinct.pluck(:type)
    types.compact.each(&:constantize)
  end
end
```

AVISO: O STI funcionará corretamente mesmo se a tabela não tiver todos os tipos, mas métodos como `subclasses` ou `descendants` não retornarão os tipos ausentes.

AVISO: Se modelos forem adicionados, modificados ou excluídos do STI, o recarregamento funcionará como esperado. No entanto, se uma nova hierarquia de STI separada for adicionada à aplicação, você precisará editar o inicializador e reiniciar o servidor.
Personalizando Inflections
-----------------------

Por padrão, o Rails usa `String#camelize` para saber qual constante um determinado arquivo ou nome de diretório deve definir. Por exemplo, `posts_controller.rb` deve definir `PostsController` porque é isso que `"posts_controller".camelize` retorna.

Pode ser o caso de que um determinado nome de arquivo ou diretório não seja infletido como você deseja. Por exemplo, espera-se que `html_parser.rb` defina `HtmlParser` por padrão. E se você preferir que a classe seja `HTMLParser`? Existem algumas maneiras de personalizar isso.

A maneira mais fácil é definir acrônimos:

```ruby
ActiveSupport::Inflector.inflections(:en) do |inflect|
  inflect.acronym "HTML"
  inflect.acronym "SSL"
end
```

Fazendo isso afeta como o Active Support inflete globalmente. Isso pode ser bom em algumas aplicações, mas você também pode personalizar como camelize nomes de arquivos individualmente, independentemente do Active Support, passando uma coleção de substituições para os inflectors padrão:

```ruby
Rails.autoloaders.each do |autoloader|
  autoloader.inflector.inflect(
    "html_parser" => "HTMLParser",
    "ssl_error"   => "SSLError"
  )
end
```

Essa técnica ainda depende de `String#camelize`, porque é isso que os inflectors padrão usam como fallback. Se você preferir não depender das inflections do Active Support e ter controle absoluto sobre as inflections, configure os inflectors como instâncias de `Zeitwerk::Inflector`:

```ruby
Rails.autoloaders.each do |autoloader|
  autoloader.inflector = Zeitwerk::Inflector.new
  autoloader.inflector.inflect(
    "html_parser" => "HTMLParser",
    "ssl_error"   => "SSLError"
  )
end
```

Não há uma configuração global que possa afetar essas instâncias; elas são determinísticas.

Você pode até definir um inflector personalizado para ter total flexibilidade. Por favor, verifique a [documentação do Zeitwerk](https://github.com/fxn/zeitwerk#custom-inflector) para mais detalhes.

### Onde Deve Ir a Personalização de Inflections?

Se uma aplicação não usa o autoloader `once`, os trechos acima podem ser colocados em `config/initializers`. Por exemplo, `config/initializers/inflections.rb` para o caso de uso do Active Support, ou `config/initializers/zeitwerk.rb` para os outros casos.

Aplicações que usam o autoloader `once` precisam mover ou carregar essa configuração do corpo da classe de aplicação em `config/application.rb`, porque o autoloader `once` usa o inflector no início do processo de inicialização.

Namespaces Personalizados
-----------------

Como vimos acima, os caminhos de autoload representam o namespace de nível superior: `Object`.

Vamos considerar `app/services`, por exemplo. Este diretório não é gerado por padrão, mas se ele existir, o Rails o adiciona automaticamente aos caminhos de autoload.

Por padrão, espera-se que o arquivo `app/services/users/signup.rb` defina `Users::Signup`, mas e se você preferir que toda a subárvore esteja sob um namespace `Services`? Bem, com as configurações padrão, isso pode ser feito criando um subdiretório: `app/services/services`.

No entanto, dependendo do seu gosto, isso pode não parecer certo para você. Você pode preferir que `app/services/users/signup.rb` simplesmente defina `Services::Users::Signup`.

O Zeitwerk suporta [namespaces raiz personalizados](https://github.com/fxn/zeitwerk#custom-root-namespaces) para abordar esse caso de uso, e você pode personalizar o autoloader `main` para conseguir isso:

```ruby
# config/initializers/autoloading.rb

# O namespace precisa existir.
#
# Neste exemplo, definimos o módulo no local. Também poderia ser criado
# em outro lugar e sua definição carregada aqui com um `require` comum.
# Em qualquer caso, `push_dir` espera um objeto de classe ou módulo.
module Services; end

Rails.autoloaders.main.push_dir("#{Rails.root}/app/services", namespace: Services)
```

O Rails < 7.1 não suportava esse recurso, mas você ainda pode adicionar esse código adicional no mesmo arquivo e fazê-lo funcionar:

```ruby
# Código adicional para aplicações em execução no Rails < 7.1.
app_services_dir = "#{Rails.root}/app/services" # precisa ser uma string
ActiveSupport::Dependencies.autoload_paths.delete(app_services_dir)
Rails.application.config.watchable_dirs[app_services_dir] = [:rb]
```

Namespaces personalizados também são suportados para o autoloader `once`. No entanto, como esse é configurado mais cedo no processo de inicialização, a configuração não pode ser feita em um inicializador de aplicação. Em vez disso, coloque-o em `config/application.rb`, por exemplo.

Autoload e Engines
-----------------------

Os engines são executados no contexto de uma aplicação pai, e seu código é carregado, recarregado e carregado antecipadamente pela aplicação pai. Se a aplicação é executada no modo `zeitwerk`, o código do engine é carregado no modo `zeitwerk`. Se a aplicação é executada no modo `classic`, o código do engine é carregado no modo `classic`.

Quando o Rails inicializa, os diretórios do engine são adicionados aos caminhos de autoload, e do ponto de vista do autoloader, não há diferença. As principais entradas dos autoloaders são os caminhos de autoload, e se eles pertencem à árvore de origem da aplicação ou a alguma árvore de origem do engine é irrelevante.

Por exemplo, esta aplicação usa o [Devise](https://github.com/heartcombo/devise):

```
% bin/rails runner 'pp ActiveSupport::Dependencies.autoload_paths'
[".../app/controllers",
 ".../app/controllers/concerns",
 ".../app/helpers",
 ".../app/models",
 ".../app/models/concerns",
 ".../gems/devise-4.8.0/app/controllers",
 ".../gems/devise-4.8.0/app/helpers",
 ".../gems/devise-4.8.0/app/mailers"]
 ```

Se o engine controla o modo de autoload de sua aplicação pai, o engine pode ser escrito normalmente.
No entanto, se um mecanismo suporta o Rails 6 ou o Rails 6.1 e não controla suas aplicações pai, ele precisa estar pronto para ser executado no modo `classic` ou `zeitwerk`. Coisas a serem consideradas:

1. Se o modo `classic` precisar de uma chamada `require_dependency` para garantir que uma constante seja carregada em algum momento, escreva-a. Embora o `zeitwerk` não precise disso, não fará mal, funcionará também no modo `zeitwerk`.

2. O modo `classic` sublinha os nomes das constantes ("User" -> "user.rb"), e o modo `zeitwerk` cameliza os nomes dos arquivos ("user.rb" -> "User"). Eles coincidem na maioria dos casos, mas não se houver sequências de letras maiúsculas consecutivas, como em "HTMLParser". A maneira mais fácil de ser compatível é evitar esses nomes. Nesse caso, escolha "HtmlParser".

3. No modo `classic`, o arquivo `app/model/concerns/foo.rb` pode definir tanto `Foo` quanto `Concerns::Foo`. No modo `zeitwerk`, há apenas uma opção: ele deve definir `Foo`. Para ser compatível, defina `Foo`.

Testes
-------

### Testes Manuais

A tarefa `zeitwerk:check` verifica se a estrutura do projeto segue as convenções de nomenclatura esperadas e é útil para verificações manuais. Por exemplo, se você está migrando do modo `classic` para o modo `zeitwerk`, ou se está corrigindo algo:

```
% bin/rails zeitwerk:check
Aguarde, estou carregando a aplicação.
Está tudo bem!
```

Pode haver saída adicional dependendo da configuração da aplicação, mas o último "Está tudo bem!" é o que você está procurando.

### Testes Automatizados

É uma boa prática verificar no conjunto de testes se o projeto é carregado corretamente.

Isso abrange a conformidade com a nomenclatura do Zeitwerk e outras possíveis condições de erro. Por favor, verifique a [seção sobre testes de carregamento antecipado](testing.html#testing-eager-loading) no guia [_Testing Rails Applications_](testing.html).

Solucionando Problemas
----------------------

A melhor maneira de acompanhar o que os carregadores estão fazendo é inspecionar sua atividade.

A maneira mais fácil de fazer isso é incluir

```ruby
Rails.autoloaders.log!
```

em `config/application.rb` após carregar as configurações padrão do framework. Isso imprimirá rastreamentos na saída padrão.

Se você preferir registrar em um arquivo, configure isso em vez disso:

```ruby
Rails.autoloaders.logger = Logger.new("#{Rails.root}/log/autoloading.log")
```

O logger do Rails ainda não está disponível quando `config/application.rb` é executado. Se você preferir usar o logger do Rails, configure essa configuração em um inicializador:

```ruby
# config/initializers/log_autoloaders.rb
Rails.autoloaders.logger = Rails.logger
```

Rails.autoloaders
-----------------

As instâncias do Zeitwerk que gerenciam sua aplicação estão disponíveis em

```ruby
Rails.autoloaders.main
Rails.autoloaders.once
```

O predicado

```ruby
Rails.autoloaders.zeitwerk_enabled?
```

ainda está disponível em aplicações Rails 7 e retorna `true`.
[`config.enable_reloading`]: configuring.html#config-enable-reloading
[`config.file_watcher`]: configuring.html#config-file-watcher
[`config.eager_load`]: configuring.html#config-eager-load
[`config.rake_eager_load`]: configuring.html#config-rake-eager-load
