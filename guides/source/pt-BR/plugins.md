**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: b550120024fb17dc176480922543264e
Os Conceitos Básicos de Criação de Plugins Rails
====================================

Um plugin Rails é uma extensão ou modificação do framework principal. Os plugins fornecem:

* Uma maneira para os desenvolvedores compartilharem ideias inovadoras sem prejudicar a base de código estável.
* Uma arquitetura segmentada para que unidades de código possam ser corrigidas ou atualizadas em seu próprio cronograma de lançamento.
* Uma saída para os desenvolvedores principais para que eles não precisem incluir todas as novas funcionalidades legais sob o sol.

Após ler este guia, você saberá:

* Como criar um plugin do zero.
* Como escrever e executar testes para o plugin.

Este guia descreve como construir um plugin orientado a testes que irá:

* Estender as classes principais do Ruby, como Hash e String.
* Adicionar métodos a `ApplicationRecord` na tradição dos plugins `acts_as`.
* Fornecer informações sobre onde colocar geradores em seu plugin.

Para fins deste guia, finja por um momento que você é um observador de pássaros ávido.
Sua ave favorita é o Yaffle, e você deseja criar um plugin que permita que outros desenvolvedores compartilhem a maravilha do Yaffle.

--------------------------------------------------------------------------------

Configuração
-----

Atualmente, os plugins Rails são construídos como gems, _gemified plugins_. Eles podem ser compartilhados entre
diferentes aplicações Rails usando o RubyGems e o Bundler, se desejado.

### Gerar um Plugin Gemificado

O Rails vem com um comando `rails plugin new` que cria um
esqueleto para desenvolver qualquer tipo de extensão Rails com a capacidade
de executar testes de integração usando uma aplicação Rails fictícia. Crie o
seu plugin com o comando:

```bash
$ rails plugin new yaffle
```

Veja o uso e as opções solicitando ajuda:

```bash
$ rails plugin new --help
```

Testando seu Plugin Recém-gerado
-----------------------------------

Navegue até o diretório que contém o plugin e edite `yaffle.gemspec` para
substituir quaisquer linhas que tenham valores `TODO`:

```ruby
spec.homepage    = "http://example.com"
spec.summary     = "Resumo do Yaffle."
spec.description = "Descrição do Yaffle."

...

spec.metadata["source_code_uri"] = "http://example.com"
spec.metadata["changelog_uri"] = "http://example.com"
```

Em seguida, execute o comando `bundle install`.

Agora você pode executar os testes usando o comando `bin/test` e você deverá ver:

```bash
$ bin/test
...
1 execução, 1 asserção, 0 falhas, 0 erros, 0 pulos
```

Isso indicará que tudo foi gerado corretamente e você está pronto para começar a adicionar funcionalidades.

Estendendo Classes Principais
----------------------

Esta seção explicará como adicionar um método à String que estará disponível em qualquer lugar de sua aplicação Rails.

Neste exemplo, você adicionará um método chamado `to_squawk` à String. Para começar, crie um novo arquivo de teste com algumas asserções:

```ruby
# yaffle/test/core_ext_test.rb

require "test_helper"

class CoreExtTest < ActiveSupport::TestCase
  def test_to_squawk_prepends_the_word_squawk
    assert_equal "squawk! Hello World", "Hello World".to_squawk
  end
end
```

Execute `bin/test` para executar o teste. Este teste deve falhar porque ainda não implementamos o método `to_squawk`:

```bash
$ bin/test
E

Erro:
CoreExtTest#test_to_squawk_prepends_the_word_squawk:
NoMethodError: undefined method `to_squawk' for "Hello World":String


bin/test /caminho/para/yaffle/test/core_ext_test.rb:4

.

Concluído em 0.003358s, 595.6483 execuções/s, 297.8242 asserções/s.
2 execuções, 1 asserção, 0 falhas, 1 erro, 0 pulos
```

Ótimo - agora você está pronto para começar o desenvolvimento.

Em `lib/yaffle.rb`, adicione `require "yaffle/core_ext"`:

```ruby
# yaffle/lib/yaffle.rb

require "yaffle/version"
require "yaffle/railtie"
require "yaffle/core_ext"

module Yaffle
  # Seu código vai aqui...
end
```

Finalmente, crie o arquivo `core_ext.rb` e adicione o método `to_squawk`:

```ruby
# yaffle/lib/yaffle/core_ext.rb

class String
  def to_squawk
    "squawk! #{self}".strip
  end
end
```

Para testar se seu método faz o que diz que faz, execute os testes unitários com `bin/test` a partir do diretório do seu plugin.

```
$ bin/test
...
2 execuções, 2 asserções, 0 falhas, 0 erros, 0 pulos
```

Para ver isso em ação, mude para o diretório `test/dummy`, inicie `bin/rails console` e comece a cacarejar:

```irb
irb> "Hello World".to_squawk
=> "squawk! Hello World"
```

Adicionar um Método "acts_as" ao Active Record
----------------------------------------

Um padrão comum em plugins é adicionar um método chamado `acts_as_alguma_coisa` aos modelos. Neste caso, você
deseja escrever um método chamado `acts_as_yaffle` que adiciona um método `squawk` aos seus modelos Active Record.

Para começar, configure seus arquivos para que você tenha:

```ruby
# yaffle/test/acts_as_yaffle_test.rb

require "test_helper"

class ActsAsYaffleTest < ActiveSupport::TestCase
end
```

```ruby
# yaffle/lib/yaffle.rb

require "yaffle/version"
require "yaffle/railtie"
require "yaffle/core_ext"
require "yaffle/acts_as_yaffle"

module Yaffle
  # Seu código vai aqui...
end
```

```ruby
# yaffle/lib/yaffle/acts_as_yaffle.rb

module Yaffle
  module ActsAsYaffle
  end
end
```
### Adicionar um Método de Classe

Este plugin espera que você tenha adicionado um método ao seu modelo chamado `last_squawk`. No entanto, os usuários do plugin podem já ter definido um método em seu modelo chamado `last_squawk` que eles usam para outra coisa. Este plugin permitirá que o nome seja alterado adicionando um método de classe chamado `yaffle_text_field`.

Para começar, escreva um teste que falhe e mostre o comportamento desejado:

```ruby
# yaffle/test/acts_as_yaffle_test.rb

require "test_helper"

class ActsAsYaffleTest < ActiveSupport::TestCase
  def test_a_hickwalls_yaffle_text_field_should_be_last_squawk
    assert_equal "last_squawk", Hickwall.yaffle_text_field
  end

  def test_a_wickwalls_yaffle_text_field_should_be_last_tweet
    assert_equal "last_tweet", Wickwall.yaffle_text_field
  end
end
```

Quando você executar `bin/test`, você deverá ver o seguinte:

```bash
$ bin/test
# Running:

..E

Error:
ActsAsYaffleTest#test_a_wickwalls_yaffle_text_field_should_be_last_tweet:
NameError: uninitialized constant ActsAsYaffleTest::Wickwall


bin/test /path/to/yaffle/test/acts_as_yaffle_test.rb:8

E

Error:
ActsAsYaffleTest#test_a_hickwalls_yaffle_text_field_should_be_last_squawk:
NameError: uninitialized constant ActsAsYaffleTest::Hickwall


bin/test /path/to/yaffle/test/acts_as_yaffle_test.rb:4



Finished in 0.004812s, 831.2949 runs/s, 415.6475 assertions/s.
4 runs, 2 assertions, 0 failures, 2 errors, 0 skips
```

Isso nos diz que não temos os modelos necessários (Hickwall e Wickwall) que estamos tentando testar. Podemos gerar facilmente esses modelos em nossa aplicação Rails "dummy" executando os seguintes comandos a partir do diretório `test/dummy`:

```bash
$ cd test/dummy
$ bin/rails generate model Hickwall last_squawk:string
$ bin/rails generate model Wickwall last_squawk:string last_tweet:string
```

Agora você pode criar as tabelas de banco de dados necessárias em seu banco de dados de teste navegando até sua aplicação dummy e migrando o banco de dados. Primeiro, execute:

```bash
$ cd test/dummy
$ bin/rails db:migrate
```

Enquanto estiver aqui, altere os modelos Hickwall e Wickwall para que eles saibam que devem agir como yaffles.

```ruby
# test/dummy/app/models/hickwall.rb

class Hickwall < ApplicationRecord
  acts_as_yaffle
end
```

```ruby
# test/dummy/app/models/wickwall.rb

class Wickwall < ApplicationRecord
  acts_as_yaffle yaffle_text_field: :last_tweet
end
```

Também adicionaremos código para definir o método `acts_as_yaffle`.

```ruby
# yaffle/lib/yaffle/acts_as_yaffle.rb

module Yaffle
  module ActsAsYaffle
    extend ActiveSupport::Concern

    class_methods do
      def acts_as_yaffle(options = {})
      end
    end
  end
end
```

```ruby
# test/dummy/app/models/application_record.rb

class ApplicationRecord < ActiveRecord::Base
  include Yaffle::ActsAsYaffle

  self.abstract_class = true
end
```

Você pode então retornar ao diretório raiz (`cd ../..`) do seu plugin e executar os testes novamente usando `bin/test`.

```bash
$ bin/test
# Running:

.E

Error:
ActsAsYaffleTest#test_a_hickwalls_yaffle_text_field_should_be_last_squawk:
NoMethodError: undefined method `yaffle_text_field' for #<Class:0x0055974ebbe9d8>


bin/test /path/to/yaffle/test/acts_as_yaffle_test.rb:4

E

Error:
ActsAsYaffleTest#test_a_wickwalls_yaffle_text_field_should_be_last_tweet:
NoMethodError: undefined method `yaffle_text_field' for #<Class:0x0055974eb8cfc8>


bin/test /path/to/yaffle/test/acts_as_yaffle_test.rb:8

.

Finished in 0.008263s, 484.0999 runs/s, 242.0500 assertions/s.
4 runs, 2 assertions, 0 failures, 2 errors, 0 skips
```

Estamos chegando lá... Agora implementaremos o código do método `acts_as_yaffle` para fazer os testes passarem.

```ruby
# yaffle/lib/yaffle/acts_as_yaffle.rb

module Yaffle
  module ActsAsYaffle
    extend ActiveSupport::Concern

    class_methods do
      def acts_as_yaffle(options = {})
        cattr_accessor :yaffle_text_field, default: (options[:yaffle_text_field] || :last_squawk).to_s
      end
    end
  end
end
```

```ruby
# test/dummy/app/models/application_record.rb

class ApplicationRecord < ActiveRecord::Base
  include Yaffle::ActsAsYaffle

  self.abstract_class = true
end
```

Quando você executar `bin/test`, você verá que todos os testes passam:

```bash
$ bin/test
...
4 runs, 4 assertions, 0 failures, 0 errors, 0 skips
```

### Adicionar um Método de Instância

Este plugin adicionará um método chamado 'squawk' a qualquer objeto Active Record que chame `acts_as_yaffle`. O método 'squawk' simplesmente definirá o valor de um dos campos no banco de dados.

Para começar, escreva um teste que falhe e mostre o comportamento desejado:

```ruby
# yaffle/test/acts_as_yaffle_test.rb
require "test_helper"

class ActsAsYaffleTest < ActiveSupport::TestCase
  def test_a_hickwalls_yaffle_text_field_should_be_last_squawk
    assert_equal "last_squawk", Hickwall.yaffle_text_field
  end

  def test_a_wickwalls_yaffle_text_field_should_be_last_tweet
    assert_equal "last_tweet", Wickwall.yaffle_text_field
  end

  def test_hickwalls_squawk_should_populate_last_squawk
    hickwall = Hickwall.new
    hickwall.squawk("Hello World")
    assert_equal "squawk! Hello World", hickwall.last_squawk
  end

  def test_wickwalls_squawk_should_populate_last_tweet
    wickwall = Wickwall.new
    wickwall.squawk("Hello World")
    assert_equal "squawk! Hello World", wickwall.last_tweet
  end
end
```

Execute o teste para garantir que os dois últimos testes falhem com um erro que contenha "NoMethodError: undefined method \`squawk'", em seguida, atualize `acts_as_yaffle.rb` para ficar assim:

```ruby
# yaffle/lib/yaffle/acts_as_yaffle.rb

module Yaffle
  module ActsAsYaffle
    extend ActiveSupport::Concern

    included do
      def squawk(string)
        write_attribute(self.class.yaffle_text_field, string.to_squawk)
      end
    end

    class_methods do
      def acts_as_yaffle(options = {})
        cattr_accessor :yaffle_text_field, default: (options[:yaffle_text_field] || :last_squawk).to_s
      end
    end
  end
end
```

```ruby
# test/dummy/app/models/application_record.rb

class ApplicationRecord < ActiveRecord::Base
  include Yaffle::ActsAsYaffle

  self.abstract_class = true
end
```

Execute `bin/test` mais uma vez, e você verá:

```bash
$ bin/test
...
6 runs, 6 assertions, 0 failures, 0 errors, 0 skips
```

NOTA: O uso de `write_attribute` para escrever no campo no modelo é apenas um exemplo de como um plugin pode interagir com o modelo e nem sempre será o método correto a ser usado. Por exemplo, você também pode usar:
```ruby
send("#{self.class.yaffle_text_field}=", string.to_squawk)
```

Geradores
---------

Geradores podem ser incluídos em sua gem simplesmente criando-os em um diretório `lib/generators` do seu plugin. Mais informações sobre
a criação de geradores podem ser encontradas no [Guia de Geradores](generators.html).

Publicando sua Gem
------------------

Plugins de gem atualmente em desenvolvimento podem ser facilmente compartilhados de qualquer repositório Git. Para compartilhar a gem Yaffle com outros, simplesmente
faça o commit do código para um repositório Git (como o GitHub) e adicione uma linha ao `Gemfile` da aplicação em questão:

```ruby
gem "yaffle", git: "https://github.com/rails/yaffle.git"
```

Após executar `bundle install`, a funcionalidade da sua gem estará disponível para a aplicação.

Quando a gem estiver pronta para ser compartilhada como um lançamento formal, ela pode ser publicada no [RubyGems](https://rubygems.org).

Alternativamente, você pode se beneficiar das tarefas Rake do Bundler. Você pode ver uma lista completa com o seguinte:

```bash
$ bundle exec rake -T

$ bundle exec rake build
# Constrói yaffle-0.1.0.gem no diretório pkg

$ bundle exec rake install
# Constrói e instala yaffle-0.1.0.gem nas gems do sistema

$ bundle exec rake release
# Cria a tag v0.1.0 e constrói e envia yaffle-0.1.0.gem para o Rubygems
```

Para obter mais informações sobre a publicação de gems no RubyGems, consulte: [Publicando sua gem](https://guides.rubygems.org/publishing).

Documentação RDoc
-----------------

Quando seu plugin estiver estável e você estiver pronto para implantá-lo, faça um favor a todos e documente-o! Felizmente, escrever documentação para seu plugin é fácil.

O primeiro passo é atualizar o arquivo README com informações detalhadas sobre como usar seu plugin. Algumas coisas importantes a incluir são:

* Seu nome
* Como instalar
* Como adicionar a funcionalidade ao aplicativo (vários exemplos de casos de uso comuns)
* Avisos, problemas ou dicas que possam ajudar os usuários e economizar tempo

Depois de ter um README sólido, adicione comentários RDoc a todos os métodos que os desenvolvedores usarão. Também é costume adicionar comentários `# :nodoc:` às partes do código que não estão incluídas na API pública.

Depois que seus comentários estiverem prontos, navegue até o diretório do seu plugin e execute:

```bash
$ bundle exec rake rdoc
```

### Referências

* [Desenvolvendo uma RubyGem usando Bundler](https://github.com/radar/guides/blob/master/gem-development.md)
* [Usando .gemspecs como pretendido](https://yehudakatz.com/2010/04/02/using-gemspecs-as-intended/)
* [Referência do Gemspec](https://guides.rubygems.org/specification-reference/)
