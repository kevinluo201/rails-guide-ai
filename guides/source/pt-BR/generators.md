**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 0651830a9dc9cbd4e8a1fddab047c719
Criando e Personalizando Geradores e Modelos Rails
=====================================================

Os geradores Rails são uma ferramenta essencial para melhorar seu fluxo de trabalho. Com este guia, você aprenderá como criar geradores e personalizar os existentes.

Após ler este guia, você saberá:

* Como ver quais geradores estão disponíveis em sua aplicação.
* Como criar um gerador usando modelos.
* Como o Rails procura por geradores antes de invocá-los.
* Como personalizar seu scaffold substituindo modelos de geradores.
* Como personalizar seu scaffold substituindo geradores.
* Como usar fallbacks para evitar a substituição de um grande conjunto de geradores.
* Como criar um modelo de aplicativo.

--------------------------------------------------------------------------------

Primeiro Contato
----------------

Quando você cria uma aplicação usando o comando `rails`, na verdade está usando um gerador Rails. Depois disso, você pode obter uma lista de todos os geradores disponíveis invocando `bin/rails generate`:

```bash
$ rails new myapp
$ cd myapp
$ bin/rails generate
```

NOTA: Para criar uma aplicação Rails, usamos o comando global `rails`, que usa a versão do Rails instalada via `gem install rails`. Quando dentro do diretório da sua aplicação, usamos o comando `bin/rails`, que usa a versão do Rails incluída na aplicação.

Você obterá uma lista de todos os geradores que vêm com o Rails. Para ver uma descrição detalhada de um gerador específico, invoque o gerador com a opção `--help`. Por exemplo:

```bash
$ bin/rails generate scaffold --help
```

Criando Seu Primeiro Gerador
----------------------------

Os geradores são construídos em cima do [Thor](https://github.com/rails/thor), que fornece opções poderosas para análise e uma ótima API para manipulação de arquivos.

Vamos construir um gerador que cria um arquivo de inicialização chamado `initializer.rb` dentro de `config/initializers`. O primeiro passo é criar um arquivo em `lib/generators/initializer_generator.rb` com o seguinte conteúdo:

```ruby
class InitializerGenerator < Rails::Generators::Base
  def create_initializer_file
    create_file "config/initializers/initializer.rb", <<~RUBY
      # Adicione o conteúdo de inicialização aqui
    RUBY
  end
end
```

Nosso novo gerador é bastante simples: ele herda de [`Rails::Generators::Base`][] e tem uma definição de método. Quando um gerador é invocado, cada método público no gerador é executado sequencialmente na ordem em que é definido. Nosso método invoca [`create_file`][], que criará um arquivo no destino fornecido com o conteúdo fornecido.

Para invocar nosso novo gerador, executamos:

```bash
$ bin/rails generate initializer
```

Antes de prosseguirmos, vamos ver a descrição do nosso novo gerador:

```bash
$ bin/rails generate initializer --help
```

O Rails geralmente é capaz de derivar uma boa descrição se um gerador estiver em um namespace, como `ActiveRecord::Generators::ModelGenerator`, mas não neste caso. Podemos resolver esse problema de duas maneiras. A primeira maneira de adicionar uma descrição é chamando [`desc`][] dentro do nosso gerador:

```ruby
class InitializerGenerator < Rails::Generators::Base
  desc "Este gerador cria um arquivo de inicialização em config/initializers"
  def create_initializer_file
    create_file "config/initializers/initializer.rb", <<~RUBY
      # Adicione o conteúdo de inicialização aqui
    RUBY
  end
end
```

Agora podemos ver a nova descrição invocando `--help` no novo gerador.

A segunda maneira de adicionar uma descrição é criando um arquivo chamado `USAGE` no mesmo diretório do nosso gerador. Faremos isso no próximo passo.


Criando Geradores com Geradores
-------------------------------

Os próprios geradores têm um gerador. Vamos remover nosso `InitializerGenerator` e usar `bin/rails generate generator` para gerar um novo:

```bash
$ rm lib/generators/initializer_generator.rb

$ bin/rails generate generator initializer
      create  lib/generators/initializer
      create  lib/generators/initializer/initializer_generator.rb
      create  lib/generators/initializer/USAGE
      create  lib/generators/initializer/templates
      invoke  test_unit
      create    test/lib/generators/initializer_generator_test.rb
```

Este é o gerador acabamos de criar:

```ruby
class InitializerGenerator < Rails::Generators::NamedBase
  source_root File.expand_path("templates", __dir__)
end
```

Primeiro, observe que o gerador herda de [`Rails::Generators::NamedBase`][] em vez de `Rails::Generators::Base`. Isso significa que nosso gerador espera pelo menos um argumento, que será o nome do inicializador e estará disponível para nosso código via `name`.

Podemos ver isso verificando a descrição do novo gerador:

```bash
$ bin/rails generate initializer --help
Uso:
  bin/rails generate initializer NAME [options]
```

Além disso, observe que o gerador tem um método de classe chamado [`source_root`][]. Este método aponta para a localização dos nossos modelos, se houver. Por padrão, ele aponta para o diretório `lib/generators/initializer/templates` que acabamos de criar.

Para entender como os modelos de gerador funcionam, vamos criar o arquivo `lib/generators/initializer/templates/initializer.rb` com o seguinte conteúdo:

```ruby
# Adicione o conteúdo de inicialização aqui
```

E vamos alterar o gerador para copiar este modelo quando invocado:
```ruby
class InitializerGenerator < Rails::Generators::NamedBase
  source_root File.expand_path("templates", __dir__)

  def copy_initializer_file
    copy_file "initializer.rb", "config/initializers/#{file_name}.rb"
  end
end
```

Agora vamos executar nosso gerador:

```bash
$ bin/rails generate initializer core_extensions
      create  config/initializers/core_extensions.rb

$ cat config/initializers/core_extensions.rb
# Adicione o conteúdo de inicialização aqui
```

Vemos que [`copy_file`][] criou `config/initializers/core_extensions.rb`
com o conteúdo do nosso modelo. (O método `file_name` usado no
caminho de destino é herdado de `Rails::Generators::NamedBase`.)


Opções de Linha de Comando do Gerador
-------------------------------------

Os geradores podem suportar opções de linha de comando usando [`class_option`][]. Por
exemplo:

```ruby
class InitializerGenerator < Rails::Generators::NamedBase
  class_option :scope, type: :string, default: "app"
end
```

Agora nosso gerador pode ser invocado com a opção `--scope`:

```bash
$ bin/rails generate initializer theme --scope dashboard
```

Os valores das opções são acessíveis nos métodos do gerador através de [`options`][]:

```ruby
def copy_initializer_file
  @scope = options["scope"]
end
```


Resolução de Geradores
--------------------

Ao resolver o nome de um gerador, o Rails procura o gerador usando vários
nomes de arquivo. Por exemplo, quando você executa `bin/rails generate initializer core_extensions`,
o Rails tenta carregar cada um dos seguintes arquivos, em ordem, até encontrar um:

* `rails/generators/initializer/initializer_generator.rb`
* `generators/initializer/initializer_generator.rb`
* `rails/generators/initializer_generator.rb`
* `generators/initializer_generator.rb`

Se nenhum desses for encontrado, um erro será gerado.

Colocamos nosso gerador no diretório `lib/` da aplicação porque esse
diretório está em `$LOAD_PATH`, permitindo assim que o Rails encontre e carregue o arquivo.

Substituindo Modelos de Geradores do Rails
------------------------------------------

O Rails também procura em vários lugares ao resolver arquivos de modelos de geradores.
Um desses lugares é o diretório `lib/templates/` da aplicação. Esse
comportamento nos permite substituir os modelos usados pelos geradores internos do Rails.
Por exemplo, poderíamos substituir o [modelo de controlador de scaffold][] ou os
[modelos de visualização de scaffold][].

Para ver isso em ação, vamos criar um arquivo `lib/templates/erb/scaffold/index.html.erb.tt`
com o seguinte conteúdo:

```erb
<%% @<%= plural_table_name %>.count %> <%= human_name.pluralize %>
```

Observe que o modelo é um modelo ERB que renderiza _outro_ modelo ERB.
Portanto, qualquer `<%` que deve aparecer no modelo _resultante_ deve ser escapado como
`<%%` no modelo do _gerador_.

Agora vamos executar o gerador de scaffold interno do Rails:

```bash
$ bin/rails generate scaffold Post title:string
      ...
      create      app/views/posts/index.html.erb
      ...
```

O conteúdo de `app/views/posts/index.html.erb` é:

```erb
<% @posts.count %> Posts
```

[modelo de controlador de scaffold]: https://github.com/rails/rails/blob/main/railties/lib/rails/generators/rails/scaffold_controller/templates/controller.rb.tt
[modelos de visualização de scaffold]: https://github.com/rails/rails/tree/main/railties/lib/rails/generators/erb/scaffold/templates

Substituindo Geradores do Rails
---------------------------

Os geradores internos do Rails podem ser configurados via [`config.generators`][],
incluindo a substituição de alguns geradores completamente.

Primeiro, vamos dar uma olhada mais de perto em como o gerador de scaffold funciona.

```bash
$ bin/rails generate scaffold User name:string
      invoke  active_record
      create    db/migrate/20230518000000_create_users.rb
      create    app/models/user.rb
      invoke    test_unit
      create      test/models/user_test.rb
      create      test/fixtures/users.yml
      invoke  resource_route
       route    resources :users
      invoke  scaffold_controller
      create    app/controllers/users_controller.rb
      invoke    erb
      create      app/views/users
      create      app/views/users/index.html.erb
      create      app/views/users/edit.html.erb
      create      app/views/users/show.html.erb
      create      app/views/users/new.html.erb
      create      app/views/users/_form.html.erb
      create      app/views/users/_user.html.erb
      invoke    resource_route
      invoke    test_unit
      create      test/controllers/users_controller_test.rb
      create      test/system/users_test.rb
      invoke    helper
      create      app/helpers/users_helper.rb
      invoke      test_unit
      invoke    jbuilder
      create      app/views/users/index.json.jbuilder
      create      app/views/users/show.json.jbuilder
```

A partir da saída, podemos ver que o gerador de scaffold invoca outros
geradores, como o gerador `scaffold_controller`. E alguns desses
geradores também invocam outros geradores. Em particular, o gerador `scaffold_controller`
invoca vários outros geradores, incluindo o gerador `helper`.

Vamos substituir o gerador interno `helper` por um novo gerador. Vamos nomear
o gerador como `my_helper`:

```bash
$ bin/rails generate generator rails/my_helper
      create  lib/generators/rails/my_helper
      create  lib/generators/rails/my_helper/my_helper_generator.rb
      create  lib/generators/rails/my_helper/USAGE
      create  lib/generators/rails/my_helper/templates
      invoke  test_unit
      create    test/lib/generators/rails/my_helper_generator_test.rb
```

E em `lib/generators/rails/my_helper/my_helper_generator.rb` vamos definir
o gerador como:

```ruby
class Rails::MyHelperGenerator < Rails::Generators::NamedBase
  def create_helper_file
    create_file "app/helpers/#{file_name}_helper.rb", <<~RUBY
      module #{class_name}Helper
        # Estou ajudando!
      end
    RUBY
  end
end
```

Por fim, precisamos informar ao Rails para usar o gerador `my_helper` em vez do
gerador interno `helper`. Para isso, usamos `config.generators`. Em
`config/application.rb`, vamos adicionar:

```ruby
config.generators do |g|
  g.helper :my_helper
end
```

Agora, se executarmos o gerador de scaffold novamente, veremos o gerador `my_helper` em
ação:

```bash
$ bin/rails generate scaffold Article body:text
      ...
      invoke  scaffold_controller
      ...
      invoke    my_helper
      create      app/helpers/articles_helper.rb
      ...
```

NOTA: Você pode notar que a saída para o gerador interno `helper`
inclui "invoke test_unit", enquanto a saída para `my_helper` não inclui.
Embora o gerador `helper` não gere testes por padrão, ele fornece um gancho para fazê-lo usando [`hook_for`][].
Podemos fazer o mesmo incluindo `hook_for :test_framework, as: :helper` na classe `MyHelperGenerator`.
Consulte a documentação do `hook_for` para obter mais informações.


### Fallbacks de Geradores

Outra maneira de substituir geradores específicos é usando _fallbacks_. Um fallback
permite que um namespace de gerador delegue para outro namespace de gerador.
Por exemplo, digamos que queremos substituir o gerador `test_unit:model` pelo nosso próprio gerador `my_test_unit:model`, mas não queremos substituir todos os outros geradores `test_unit:*`, como `test_unit:controller`.

Primeiro, criamos o gerador `my_test_unit:model` em `lib/generators/my_test_unit/model/model_generator.rb`:

```ruby
module MyTestUnit
  class ModelGenerator < Rails::Generators::NamedBase
    source_root File.expand_path("templates", __dir__)

    def do_different_stuff
      say "Fazendo coisas diferentes..."
    end
  end
end
```

Em seguida, usamos `config.generators` para configurar o gerador `test_framework` como `my_test_unit`, mas também configuramos uma alternativa para que quaisquer geradores `my_test_unit:*` ausentes sejam resolvidos como `test_unit:*`:

```ruby
config.generators do |g|
  g.test_framework :my_test_unit, fixture: false
  g.fallbacks[:my_test_unit] = :test_unit
end
```

Agora, quando executamos o gerador de scaffold, vemos que `my_test_unit` substituiu `test_unit`, mas apenas os testes de modelo foram afetados:

```bash
$ bin/rails generate scaffold Comment body:text
      invoke  active_record
      create    db/migrate/20230518000000_create_comments.rb
      create    app/models/comment.rb
      invoke    my_test_unit
    Fazendo coisas diferentes...
      invoke  resource_route
       route    resources :comments
      invoke  scaffold_controller
      create    app/controllers/comments_controller.rb
      invoke    erb
      create      app/views/comments
      create      app/views/comments/index.html.erb
      create      app/views/comments/edit.html.erb
      create      app/views/comments/show.html.erb
      create      app/views/comments/new.html.erb
      create      app/views/comments/_form.html.erb
      create      app/views/comments/_comment.html.erb
      invoke    resource_route
      invoke    my_test_unit
      create      test/controllers/comments_controller_test.rb
      create      test/system/comments_test.rb
      invoke    helper
      create      app/helpers/comments_helper.rb
      invoke      my_test_unit
      invoke    jbuilder
      create      app/views/comments/index.json.jbuilder
      create      app/views/comments/show.json.jbuilder
```

Modelos de Aplicação
---------------------

Modelos de aplicação são um tipo especial de gerador. Eles podem usar todos os
[métodos auxiliares do gerador](#métodos-auxiliares-do-gerador), mas são escritos como um script Ruby em vez de uma classe Ruby. Aqui está um exemplo:

```ruby
# template.rb

if yes?("Gostaria de instalar o Devise?")
  gem "devise"
  devise_model = ask("Como você gostaria que o modelo de usuário fosse chamado?", default: "User")
end

after_bundle do
  if devise_model
    generate "devise:install"
    generate "devise", devise_model
    rails_command "db:migrate"
  end

  git add: ".", commit: %(-m 'Commit inicial')
end
```

Primeiro, o modelo pergunta ao usuário se ele gostaria de instalar o Devise.
Se o usuário responder "sim" (ou "s"), o modelo adiciona o Devise ao `Gemfile`
e pergunta ao usuário o nome do modelo de usuário do Devise (com o padrão `User`).
Mais tarde, depois que o `bundle install` for executado, o modelo executará os geradores do Devise e `rails db:migrate` se um modelo do Devise for especificado. Por fim, o modelo fará `git add` e `git commit` em todo o diretório do aplicativo.

Podemos executar nosso modelo ao gerar um novo aplicativo Rails passando a opção `-m` para o comando `rails new`:

```bash
$ rails new my_cool_app -m path/to/template.rb
```

Alternativamente, podemos executar nosso modelo dentro de um aplicativo existente com o `bin/rails app:template`:

```bash
$ bin/rails app:template LOCATION=path/to/template.rb
```

Os modelos também não precisam ser armazenados localmente - você pode especificar uma URL em vez de um caminho:

```bash
$ rails new my_cool_app -m http://example.com/template.rb
$ bin/rails app:template LOCATION=http://example.com/template.rb
```

Métodos Auxiliares do Gerador
------------------------

O Thor fornece muitos métodos auxiliares do gerador por meio de [`Thor::Actions`][], como:

* [`copy_file`][]
* [`create_file`][]
* [`gsub_file`][]
* [`insert_into_file`][]
* [`inside`][]

Além desses, o Rails também fornece muitos métodos auxiliares por meio de [`Rails::Generators::Actions`][], como:

* [`environment`][]
* [`gem`][]
* [`generate`][]
* [`git`][]
* [`initializer`][]
* [`lib`][]
* [`rails_command`][]
* [`rake`][]
* [`route`][]
[`Rails::Generators::Base`]: https://api.rubyonrails.org/classes/Rails/Generators/Base.html
[`Thor::Actions`]: https://www.rubydoc.info/gems/thor/Thor/Actions
[`create_file`]: https://www.rubydoc.info/gems/thor/Thor/Actions#create_file-instance_method
[`desc`]: https://www.rubydoc.info/gems/thor/Thor#desc-class_method
[`Rails::Generators::NamedBase`]: https://api.rubyonrails.org/classes/Rails/Generators/NamedBase.html
[`copy_file`]: https://www.rubydoc.info/gems/thor/Thor/Actions#copy_file-instance_method
[`source_root`]: https://api.rubyonrails.org/classes/Rails/Generators/Base.html#method-c-source_root
[`class_option`]: https://www.rubydoc.info/gems/thor/Thor/Base/ClassMethods#class_option-instance_method
[`options`]: https://www.rubydoc.info/gems/thor/Thor/Base#options-instance_method
[`config.generators`]: configuring.html#configuring-generators
[`hook_for`]: https://api.rubyonrails.org/classes/Rails/Generators/Base.html#method-c-hook_for
[`Rails::Generators::Actions`]: https://api.rubyonrails.org/classes/Rails/Generators/Actions.html
[`environment`]: https://api.rubyonrails.org/classes/Rails/Generators/Actions.html#method-i-environment
[`gem`]: https://api.rubyonrails.org/classes/Rails/Generators/Actions.html#method-i-gem
[`generate`]: https://api.rubyonrails.org/classes/Rails/Generators/Actions.html#method-i-generate
[`git`]: https://api.rubyonrails.org/classes/Rails/Generators/Actions.html#method-i-git
[`gsub_file`]: https://www.rubydoc.info/gems/thor/Thor/Actions#gsub_file-instance_method
[`initializer`]: https://api.rubyonrails.org/classes/Rails/Generators/Actions.html#method-i-initializer
[`insert_into_file`]: https://www.rubydoc.info/gems/thor/Thor/Actions#insert_into_file-instance_method
[`inside`]: https://www.rubydoc.info/gems/thor/Thor/Actions#inside-instance_method
[`lib`]: https://api.rubyonrails.org/classes/Rails/Generators/Actions.html#method-i-lib
[`rails_command`]: https://api.rubyonrails.org/classes/Rails/Generators/Actions.html#method-i-rails_command
[`rake`]: https://api.rubyonrails.org/classes/Rails/Generators/Actions.html#method-i-rake
[`route`]: https://api.rubyonrails.org/classes/Rails/Generators/Actions.html#method-i-route
