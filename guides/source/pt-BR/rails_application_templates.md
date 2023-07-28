**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: d3947b8dd1115e8f8e4279581ff626f6
Modelos de Aplicativos Rails
===========================

Os modelos de aplicativos são arquivos Ruby simples contendo DSL para adicionar gems, inicializadores, etc. ao seu projeto Rails recém-criado ou a um projeto Rails existente.

Depois de ler este guia, você saberá:

* Como usar modelos para gerar/personalizar aplicativos Rails.
* Como escrever seus próprios modelos de aplicativos reutilizáveis usando a API de modelos do Rails.

--------------------------------------------------------------------------------

Uso
-----

Para aplicar um modelo, você precisa fornecer ao gerador do Rails a localização do modelo que deseja aplicar usando a opção `-m`. Isso pode ser um caminho para um arquivo ou uma URL.

```bash
$ rails new blog -m ~/template.rb
$ rails new blog -m http://example.com/template.rb
```

Você pode usar o comando `app:template` do Rails para aplicar modelos a um aplicativo Rails existente. A localização do modelo precisa ser passada via variável de ambiente LOCATION. Novamente, isso pode ser um caminho para um arquivo ou uma URL.

```bash
$ bin/rails app:template LOCATION=~/template.rb
$ bin/rails app:template LOCATION=http://example.com/template.rb
```

API de Modelo
------------

A API de modelos do Rails é fácil de entender. Aqui está um exemplo de um modelo típico do Rails:

```ruby
# template.rb
generate(:scaffold, "person name:string")
route "root to: 'people#index'"
rails_command("db:migrate")

after_bundle do
  git :init
  git add: "."
  git commit: %Q{ -m 'Initial commit' }
end
```

As seções a seguir descrevem os principais métodos fornecidos pela API:

### gem(*args)

Adiciona uma entrada `gem` para a gem fornecida ao `Gemfile` do aplicativo gerado.

Por exemplo, se seu aplicativo depende das gems `bj` e `nokogiri`:

```ruby
gem "bj"
gem "nokogiri"
```

Observe que este método apenas adiciona a gem ao `Gemfile`; ele não instala a gem.

### gem_group(*names, &block)

Envolve as entradas de gem em um grupo.

Por exemplo, se você deseja carregar o `rspec-rails` apenas nos grupos `development` e `test`:

```ruby
gem_group :development, :test do
  gem "rspec-rails"
end
```

### add_source(source, options={}, &block)

Adiciona a origem fornecida ao `Gemfile` do aplicativo gerado.

Por exemplo, se você precisa obter uma gem de `"http://gems.github.com"`:

```ruby
add_source "http://gems.github.com"
```

Se um bloco for fornecido, as entradas de gem no bloco serão envolvidas no grupo de origem.

```ruby
add_source "http://gems.github.com/" do
  gem "rspec-rails"
end
```

### environment/application(data=nil, options={}, &block)

Adiciona uma linha dentro da classe `Application` para `config/application.rb`.

Se `options[:env]` for especificado, a linha será adicionada ao arquivo correspondente em `config/environments`.

```ruby
environment 'config.action_mailer.default_url_options = {host: "http://yourwebsite.example.com"}', env: 'production'
```

Um bloco pode ser usado no lugar do argumento `data`.

### vendor/lib/file/initializer(filename, data = nil, &block)

Adiciona um inicializador ao diretório `config/initializers` do aplicativo gerado.

Digamos que você goste de usar `Object#not_nil?` e `Object#not_blank?`:

```ruby
initializer 'bloatlol.rb', <<-CODE
  class Object
    def not_nil?
      !nil?
    end

    def not_blank?
      !blank?
    end
  end
CODE
```

Da mesma forma, `lib()` cria um arquivo no diretório `lib/` e `vendor()` cria um arquivo no diretório `vendor/`.

Há até mesmo `file()`, que aceita um caminho relativo a partir de `Rails.root` e cria todos os diretórios/arquivos necessários:

```ruby
file 'app/components/foo.rb', <<-CODE
  class Foo
  end
CODE
```

Isso criará o diretório `app/components` e colocará `foo.rb` lá dentro.

### rakefile(filename, data = nil, &block)

Cria um novo arquivo rake em `lib/tasks` com as tarefas fornecidas:

```ruby
rakefile("bootstrap.rake") do
  <<-TASK
    namespace :boot do
      task :strap do
        puts "i like boots!"
      end
    end
  TASK
end
```

O exemplo acima cria `lib/tasks/bootstrap.rake` com uma tarefa rake `boot:strap`.

### generate(what, *args)

Executa o gerador do Rails fornecido com os argumentos dados.

```ruby
generate(:scaffold, "person", "name:string", "address:text", "age:number")
```

### run(command)

Executa um comando arbitrário. Assim como as crases. Digamos que você queira remover o arquivo `README.rdoc`:

```ruby
run "rm README.rdoc"
```

### rails_command(command, options = {})

Executa o comando fornecido no aplicativo Rails. Digamos que você queira migrar o banco de dados:

```ruby
rails_command "db:migrate"
```

Você também pode executar comandos com um ambiente Rails diferente:

```ruby
rails_command "db:migrate", env: 'production'
```

Você também pode executar comandos como um superusuário:

```ruby
rails_command "log:clear", sudo: true
```

Você também pode executar comandos que devem abortar a geração do aplicativo se falharem:

```ruby
rails_command "db:migrate", abort_on_failure: true
```

### route(routing_code)

Adiciona uma entrada de roteamento ao arquivo `config/routes.rb`. Nos passos acima, geramos um scaffold de pessoa e também removemos o `README.rdoc`. Agora, para tornar `PeopleController#index` a página padrão do aplicativo:

```ruby
route "root to: 'person#index'"
```

### inside(dir)

Permite executar um comando a partir do diretório fornecido. Por exemplo, se você tiver uma cópia do Rails edge que deseja criar um link simbólico a partir de seus novos aplicativos, você pode fazer isso:
```ruby
dentro('vendor') do
  execute "ln -s ~/commit-rails/rails rails"
end
```

### pergunte(pergunta)

`pergunte()` dá a você a chance de obter algum feedback do usuário e usá-lo em seus modelos. Digamos que você queira que o usuário dê um nome para a nova biblioteca brilhante que você está adicionando:

```ruby
nome_biblioteca = pergunte("Como você quer chamar a biblioteca brilhante?")
nome_biblioteca << ".rb" unless nome_biblioteca.index(".rb")

biblioteca nome_biblioteca, <<-CODIGO
  class Brilhante
  end
CODIGO
```

### sim?(pergunta) ou nao?(pergunta)

Esses métodos permitem que você faça perguntas nos modelos e decida o fluxo com base na resposta do usuário. Digamos que você queira perguntar ao usuário se ele deseja executar as migrações:

```ruby
comando_rails("db:migrate") if sim?("Executar migrações do banco de dados?")
# nao?(pergunta) age exatamente o oposto.
```

### git(:comando)

Os modelos do Rails permitem que você execute qualquer comando git:

```ruby
git :init
git add: "."
git commit: "-a -m 'Commit inicial'"
```

### after_bundle(&block)

Registra um retorno de chamada a ser executado após as gemas serem agrupadas e os binstubs serem gerados. Útil para adicionar arquivos gerados ao controle de versão:

```ruby
after_bundle do
  git :init
  git add: '.'
  git commit: "-a -m 'Commit inicial'"
end
```

Os retornos de chamada são executados mesmo se `--skip-bundle` for passado.

Uso Avançado
--------------

O modelo de aplicativo é avaliado no contexto de uma instância de `Rails::Generators::AppGenerator`. Ele usa a ação [`apply`](https://www.rubydoc.info/gems/thor/Thor/Actions#apply-instance_method) fornecida pelo Thor.

Isso significa que você pode estender e alterar a instância para atender às suas necessidades.

Por exemplo, sobrescrevendo o método `source_paths` para conter a localização do seu modelo. Agora, métodos como `copy_file` aceitarão caminhos relativos à localização do seu modelo.

```ruby
def source_paths
  [__dir__]
end
```
