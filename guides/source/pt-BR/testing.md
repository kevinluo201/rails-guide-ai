**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 6da9945dc313b748574b8aca256f1435
Testando Aplicações Rails
==========================

Este guia aborda os mecanismos incorporados no Rails para testar sua aplicação.

Após ler este guia, você saberá:

* A terminologia de testes do Rails.
* Como escrever testes unitários, funcionais, de integração e de sistema para sua aplicação.
* Outras abordagens populares de testes e plugins.

--------------------------------------------------------------------------------

Por que Escrever Testes para Suas Aplicações Rails?
--------------------------------------------------

O Rails torna muito fácil escrever seus testes. Ele começa produzindo um código de teste esqueleto enquanto você cria seus modelos e controladores.

Ao executar seus testes Rails, você pode garantir que seu código adere à funcionalidade desejada, mesmo após alguma refatoração de código importante.

Os testes Rails também podem simular solicitações de navegador e, assim, você pode testar a resposta de sua aplicação sem precisar testá-la através do navegador.

Introdução aos Testes
---------------------

O suporte a testes foi incorporado ao Rails desde o início. Não foi uma epifania do tipo "oh! vamos adicionar suporte para executar testes porque eles são novos e legais".

### O Rails se Configura para Testes desde o Início

O Rails cria um diretório `test` para você assim que você cria um projeto Rails usando `rails new` _nome_do_aplicativo_. Se você listar o conteúdo deste diretório, verá:

```bash
$ ls -F test
application_system_test_case.rb  controllers/                     helpers/                         mailers/                         system/
channels/                        fixtures/                        integration/                     models/                          test_helper.rb
```

Os diretórios `helpers`, `mailers` e `models` são destinados a conter testes para ajudantes de visualização, mailers e modelos, respectivamente. O diretório `channels` é destinado a conter testes para conexão e canais do Action Cable. O diretório `controllers` é destinado a conter testes para controladores, rotas e visualizações. O diretório `integration` é destinado a conter testes para interações entre controladores.

O diretório de testes do sistema contém testes de sistema, que são usados para testar o aplicativo em um navegador completo. Os testes de sistema permitem testar sua aplicação da mesma forma que seus usuários a experimentam e ajudam a testar seu JavaScript também. Os testes de sistema herdam do Capybara e realizam testes no navegador para sua aplicação.

As fixtures são uma forma de organizar dados de teste; elas residem no diretório `fixtures`.

Um diretório `jobs` também será criado quando um teste associado for gerado pela primeira vez.

O arquivo `test_helper.rb` contém a configuração padrão para seus testes.

O arquivo `application_system_test_case.rb` contém a configuração padrão para seus testes de sistema.

### O Ambiente de Teste

Por padrão, cada aplicativo Rails possui três ambientes: desenvolvimento, teste e produção.

A configuração de cada ambiente pode ser modificada de forma semelhante. Neste caso, podemos modificar nosso ambiente de teste alterando as opções encontradas em `config/environments/test.rb`.

NOTA: Seus testes são executados sob `RAILS_ENV=test`.

### Rails Encontra o Minitest

Se você se lembra, usamos o comando `bin/rails generate model` no guia [Iniciando com o Rails](getting_started.html). Criamos nosso primeiro modelo e, entre outras coisas, ele criou esboços de teste no diretório `test`:

```bash
$ bin/rails generate model article title:string body:text
...
create  app/models/article.rb
create  test/models/article_test.rb
create  test/fixtures/articles.yml
...
```

O esboço de teste padrão em `test/models/article_test.rb` se parece com isso:

```ruby
require "test_helper"

class ArticleTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
```

Um exame linha por linha deste arquivo ajudará você a se orientar no código e na terminologia de testes do Rails.

```ruby
require "test_helper"
```

Ao requerer este arquivo, `test_helper.rb`, a configuração padrão para executar nossos testes é carregada. Incluiremos isso em todos os testes que escrevermos, para que todos os métodos adicionados a este arquivo estejam disponíveis para todos os nossos testes.

```ruby
class ArticleTest < ActiveSupport::TestCase
```

A classe `ArticleTest` define um _caso de teste_ porque herda de `ActiveSupport::TestCase`. `ArticleTest` possui todos os métodos disponíveis de `ActiveSupport::TestCase`. Mais adiante neste guia, veremos alguns dos métodos que ele nos fornece.

Qualquer método definido dentro de uma classe herdada de `Minitest::Test` (que é a superclasse de `ActiveSupport::TestCase`) que começa com `test_` é simplesmente chamado de teste. Portanto, métodos definidos como `test_password` e `test_valid_password` são nomes de teste válidos e são executados automaticamente quando o caso de teste é executado.

O Rails também adiciona um método `test` que recebe um nome de teste e um bloco. Ele gera um teste normal do `Minitest::Unit` com nomes de método prefixados com `test_`. Portanto, você não precisa se preocupar em nomear os métodos e pode escrever algo como:

```ruby
test "the truth" do
  assert true
end
```

O que é aproximadamente o mesmo que escrever isso:
```ruby
def testar_a_verdade
  assert true
end
```

Embora você ainda possa usar definições de método regulares, usar a macro `test` permite um nome de teste mais legível.

NOTA: O nome do método é gerado substituindo espaços por sublinhados. O resultado não precisa ser um identificador Ruby válido, pois o nome pode conter caracteres de pontuação, etc. Isso ocorre porque em Ruby tecnicamente qualquer string pode ser um nome de método. Isso pode exigir o uso de chamadas `define_method` e `send` para funcionar corretamente, mas formalmente há pouca restrição no nome.

A seguir, vamos olhar para nossa primeira asserção:

```ruby
assert true
```

Uma asserção é uma linha de código que avalia um objeto (ou expressão) para resultados esperados. Por exemplo, uma asserção pode verificar:

* esse valor é igual àquele valor?
* esse objeto é nulo?
* essa linha de código gera uma exceção?
* a senha do usuário tem mais de 5 caracteres?

Cada teste pode conter uma ou mais asserções, sem restrição quanto ao número de asserções permitidas. Somente quando todas as asserções são bem-sucedidas, o teste é aprovado.

#### Seu Primeiro Teste Falhando

Para ver como uma falha de teste é relatada, você pode adicionar um teste falhando ao caso de teste `article_test.rb`.

```ruby
test "não deve salvar o artigo sem título" do
  article = Article.new
  assert_not article.save
end
```

Vamos executar este teste recém-adicionado (onde `6` é o número da linha onde o teste é definido).

```bash
$ bin/rails test test/models/article_test.rb:6
Opções de execução: --seed 44656

# Executando:

F

Falha:
ArticleTest#test_should_not_save_article_without_title [/caminho/para/blog/test/models/article_test.rb:6]:
Esperava-se que true fosse nulo ou falso


bin/rails test test/models/article_test.rb:6



Concluído em 0.023918s, 41.8090 execuções/s, 41.8090 asserções/s.

1 execuções, 1 asserções, 1 falhas, 0 erros, 0 ignorados
```

Na saída, `F` denota uma falha. Você pode ver o rastreamento correspondente mostrado em `Falha` junto com o nome do teste que falhou. As próximas linhas contêm o rastreamento de pilha seguido de uma mensagem que menciona o valor real e o valor esperado pela asserção. As mensagens de falha de asserção padrão fornecem informações suficientes para ajudar a identificar o erro. Para tornar a mensagem de falha de asserção mais legível, cada asserção fornece um parâmetro de mensagem opcional, como mostrado aqui:

```ruby
test "não deve salvar o artigo sem título" do
  article = Article.new
  assert_not article.save, "Salvou o artigo sem título"
end
```

A execução deste teste mostra a mensagem de falha de asserção mais amigável:

```
Falha:
ArticleTest#test_should_not_save_article_without_title [/caminho/para/blog/test/models/article_test.rb:6]:
Salvou o artigo sem título
```

Agora, para fazer este teste passar, podemos adicionar uma validação de nível de modelo para o campo _title_.

```ruby
class Article < ApplicationRecord
  validates :title, presence: true
end
```

Agora o teste deve passar. Vamos verificar executando o teste novamente:

```bash
$ bin/rails test test/models/article_test.rb:6
Opções de execução: --seed 31252

# Executando:

.

Concluído em 0.027476s, 36.3952 execuções/s, 36.3952 asserções/s.

1 execuções, 1 asserções, 0 falhas, 0 erros, 0 ignorados
```

Agora, se você notar, primeiro escrevemos um teste que falha para uma funcionalidade desejada, depois escrevemos algum código que adiciona a funcionalidade e, finalmente, garantimos que nosso teste passe. Essa abordagem para o desenvolvimento de software é chamada de [_Test-Driven Development_ (TDD)](http://c2.com/cgi/wiki?TestDrivenDevelopment).

#### Como um Erro se Parece

Para ver como um erro é relatado, aqui está um teste contendo um erro:

```ruby
test "deve relatar erro" do
  # some_undefined_variable não está definida em nenhum outro lugar no caso de teste
  some_undefined_variable
  assert true
end
```

Agora você pode ver ainda mais saída no console ao executar os testes:

```bash
$ bin/rails test test/models/article_test.rb
Opções de execução: --seed 1808

# Executando:

.E

Erro:
ArticleTest#test_should_report_error:
NameError: undefined local variable or method 'some_undefined_variable' for #<ArticleTest:0x007fee3aa71798>
    test/models/article_test.rb:11:in 'block in <class:ArticleTest>'


bin/rails test test/models/article_test.rb:9



Concluído em 0.040609s, 49.2500 execuções/s, 24.6250 asserções/s.

2 execuções, 1 asserções, 0 falhas, 1 erros, 0 ignorados
```

Observe o 'E' na saída. Ele denota um teste com erro.

NOTA: A execução de cada método de teste é interrompida assim que qualquer erro ou falha de asserção é encontrada, e a suíte de testes continua com o próximo método. Todos os métodos de teste são executados em ordem aleatória. A opção [`config.active_support.test_order`][] pode ser usada para configurar a ordem dos testes.

Quando um teste falha, você recebe o rastreamento correspondente. Por padrão, o Rails filtra esse rastreamento e imprimirá apenas as linhas relevantes para sua aplicação. Isso elimina o ruído do framework e ajuda a focar no seu código. No entanto, existem situações em que você deseja ver o rastreamento completo. Defina o argumento `-b` (ou `--backtrace`) para habilitar esse comportamento:
```bash
$ bin/rails test -b test/models/article_test.rb
```

Se quisermos que esse teste seja aprovado, podemos modificá-lo para usar `assert_raises` da seguinte forma:

```ruby
test "deve relatar erro" do
  # some_undefined_variable não está definida em nenhum outro lugar no caso de teste
  assert_raises(NameError) do
    some_undefined_variable
  end
end
```

Agora esse teste deve passar.


### Asserts Disponíveis

Até agora, você teve uma visão de algumas das asserções disponíveis. As asserções são as operárias dos testes. São elas que realmente realizam as verificações para garantir que as coisas estejam indo conforme o planejado.

Aqui está um extrato das asserções que você pode usar com
[`Minitest`](https://github.com/minitest/minitest), a biblioteca de testes padrão
usada pelo Rails. O parâmetro `[msg]` é uma mensagem de string opcional que você pode
especificar para tornar as mensagens de falha do teste mais claras.

| Assertiva                                                        | Propósito |
| ---------------------------------------------------------------- | --------- |
| `assert( test, [msg] )`                                          | Garante que `test` seja verdadeiro.|
| `assert_not( test, [msg] )`                                      | Garante que `test` seja falso.|
| `assert_equal( expected, actual, [msg] )`                        | Garante que `expected == actual` seja verdadeiro.|
| `assert_not_equal( expected, actual, [msg] )`                    | Garante que `expected != actual` seja verdadeiro.|
| `assert_same( expected, actual, [msg] )`                         | Garante que `expected.equal?(actual)` seja verdadeiro.|
| `assert_not_same( expected, actual, [msg] )`                     | Garante que `expected.equal?(actual)` seja falso.|
| `assert_nil( obj, [msg] )`                                       | Garante que `obj.nil?` seja verdadeiro.|
| `assert_not_nil( obj, [msg] )`                                   | Garante que `obj.nil?` seja falso.|
| `assert_empty( obj, [msg] )`                                     | Garante que `obj` seja `empty?`.|
| `assert_not_empty( obj, [msg] )`                                 | Garante que `obj` não seja `empty?`.|
| `assert_match( regexp, string, [msg] )`                          | Garante que uma string corresponda à expressão regular.|
| `assert_no_match( regexp, string, [msg] )`                       | Garante que uma string não corresponda à expressão regular.|
| `assert_includes( collection, obj, [msg] )`                      | Garante que `obj` esteja em `collection`.|
| `assert_not_includes( collection, obj, [msg] )`                  | Garante que `obj` não esteja em `collection`.|
| `assert_in_delta( expected, actual, [delta], [msg] )`            | Garante que os números `expected` e `actual` estejam dentro de `delta` um do outro.|
| `assert_not_in_delta( expected, actual, [delta], [msg] )`        | Garante que os números `expected` e `actual` não estejam dentro de `delta` um do outro.|
| `assert_in_epsilon ( expected, actual, [epsilon], [msg] )`       | Garante que os números `expected` e `actual` tenham um erro relativo menor que `epsilon`.|
| `assert_not_in_epsilon ( expected, actual, [epsilon], [msg] )`   | Garante que os números `expected` e `actual` tenham um erro relativo não menor que `epsilon`.|
| `assert_throws( symbol, [msg] ) { block }`                       | Garante que o bloco fornecido lance o símbolo.|
| `assert_raises( exception1, exception2, ... ) { block }`         | Garante que o bloco fornecido levante uma das exceções fornecidas.|
| `assert_instance_of( class, obj, [msg] )`                        | Garante que `obj` seja uma instância de `class`.|
| `assert_not_instance_of( class, obj, [msg] )`                    | Garante que `obj` não seja uma instância de `class`.|
| `assert_kind_of( class, obj, [msg] )`                            | Garante que `obj` seja uma instância de `class` ou esteja descendendo dela.|
| `assert_not_kind_of( class, obj, [msg] )`                        | Garante que `obj` não seja uma instância de `class` e não esteja descendendo dela.|
| `assert_respond_to( obj, symbol, [msg] )`                        | Garante que `obj` responda a `symbol`.|
| `assert_not_respond_to( obj, symbol, [msg] )`                    | Garante que `obj` não responda a `symbol`.|
| `assert_operator( obj1, operator, [obj2], [msg] )`               | Garante que `obj1.operator(obj2)` seja verdadeiro.|
| `assert_not_operator( obj1, operator, [obj2], [msg] )`           | Garante que `obj1.operator(obj2)` seja falso.|
| `assert_predicate ( obj, predicate, [msg] )`                     | Garante que `obj.predicate` seja verdadeiro, por exemplo, `assert_predicate str, :empty?`|
| `assert_not_predicate ( obj, predicate, [msg] )`                 | Garante que `obj.predicate` seja falso, por exemplo, `assert_not_predicate str, :empty?`|
| `flunk( [msg] )`                                                 | Garante falha. Isso é útil para marcar explicitamente um teste que ainda não está concluído.|

As acima são um subconjunto das asserções que o minitest suporta. Para uma lista exaustiva e mais atualizada, consulte a
[documentação da API do Minitest](http://docs.seattlerb.org/minitest/), especificamente
[`Minitest::Assertions`](http://docs.seattlerb.org/minitest/Minitest/Assertions.html).

Devido à natureza modular do framework de testes, é possível criar suas próprias asserções. Na verdade, é exatamente isso que o Rails faz. Ele inclui algumas asserções especializadas para facilitar sua vida.

NOTA: Criar suas próprias asserções é um tópico avançado que não abordaremos neste tutorial.

### Assertivas Específicas do Rails

O Rails adiciona algumas asserções personalizadas ao framework `minitest`:

| Assertiva                                                                         | Propósito |
| --------------------------------------------------------------------------------- | ------- |
| [`assert_difference(expressions, difference = 1, message = nil) {...}`](https://api.rubyonrails.org/classes/ActiveSupport/Testing/Assertions.html#method-i-assert_difference) | Testa a diferença numérica entre o valor de retorno de uma expressão como resultado do que é avaliado no bloco fornecido.|
| [`assert_no_difference(expressions, message = nil, &block)`](https://api.rubyonrails.org/classes/ActiveSupport/Testing/Assertions.html#method-i-assert_no_difference) | Verifica se o resultado numérico da avaliação de uma expressão não é alterado antes e depois de invocar o bloco fornecido.|
| [`assert_changes(expressions, message = nil, from:, to:, &block)`](https://api.rubyonrails.org/classes/ActiveSupport/Testing/Assertions.html#method-i-assert_changes) | Testa se o resultado da avaliação de uma expressão é alterado após a invocação do bloco fornecido.|
| [`assert_no_changes(expressions, message = nil, &block)`](https://api.rubyonrails.org/classes/ActiveSupport/Testing/Assertions.html#method-i-assert_no_changes) | Testa se o resultado da avaliação de uma expressão não é alterado após a invocação do bloco fornecido.|
| [`assert_nothing_raised { block }`](https://api.rubyonrails.org/classes/ActiveSupport/Testing/Assertions.html#method-i-assert_nothing_raised) | Garante que o bloco fornecido não gere exceções.|
| [`assert_recognizes(expected_options, path, extras={}, message=nil)`](https://api.rubyonrails.org/classes/ActionDispatch/Assertions/RoutingAssertions.html#method-i-assert_recognizes) | Verifica se o roteamento do caminho fornecido foi tratado corretamente e se as opções analisadas (fornecidas no hash expected_options) correspondem ao caminho. Basicamente, verifica se o Rails reconhece a rota fornecida por expected_options.|
| [`assert_generates(expected_path, options, defaults={}, extras = {}, message=nil)`](https://api.rubyonrails.org/classes/ActionDispatch/Assertions/RoutingAssertions.html#method-i-assert_generates) | Verifica se as opções fornecidas podem ser usadas para gerar o caminho fornecido. Isso é o inverso de assert_recognizes. O parâmetro extras é usado para informar à solicitação os nomes e valores dos parâmetros de solicitação adicionais que estariam em uma string de consulta. O parâmetro message permite especificar uma mensagem de erro personalizada para falhas na assertiva.|
| [`assert_response(type, message = nil)`](https://api.rubyonrails.org/classes/ActionDispatch/Assertions/ResponseAssertions.html#method-i-assert_response) | Verifica se a resposta possui um código de status específico. Você pode especificar `:success` para indicar 200-299, `:redirect` para indicar 300-399, `:missing` para indicar 404 ou `:error` para corresponder à faixa 500-599. Você também pode passar um número de status explícito ou seu equivalente simbólico. Para mais informações, consulte a [lista completa de códigos de status](https://rubydoc.info/gems/rack/Rack/Utils#HTTP_STATUS_CODES-constant) e como funciona o [mapeamento](https://rubydoc.info/gems/rack/Rack/Utils#SYMBOL_TO_STATUS_CODE-constant).|
| [`assert_redirected_to(options = {}, message=nil)`](https://api.rubyonrails.org/classes/ActionDispatch/Assertions/ResponseAssertions.html#method-i-assert_redirected_to) | Verifica se a resposta é um redirecionamento para uma URL que corresponde às opções fornecidas. Você também pode passar rotas nomeadas, como `assert_redirected_to root_path`, e objetos Active Record, como `assert_redirected_to @article`.|

Você verá o uso de algumas dessas assertivas no próximo capítulo.

### Uma Breve Observação Sobre Casos de Teste

Todas as assertivas básicas, como `assert_equal`, definidas em `Minitest::Assertions`, também estão disponíveis nas classes que usamos em nossos próprios casos de teste. Na verdade, o Rails fornece as seguintes classes para você herdar:

* [`ActiveSupport::TestCase`](https://api.rubyonrails.org/classes/ActiveSupport/TestCase.html)
* [`ActionMailer::TestCase`](https://api.rubyonrails.org/classes/ActionMailer/TestCase.html)
* [`ActionView::TestCase`](https://api.rubyonrails.org/classes/ActionView/TestCase.html)
* [`ActiveJob::TestCase`](https://api.rubyonrails.org/classes/ActiveJob/TestCase.html)
* [`ActionDispatch::IntegrationTest`](https://api.rubyonrails.org/classes/ActionDispatch/IntegrationTest.html)
* [`ActionDispatch::SystemTestCase`](https://api.rubyonrails.org/classes/ActionDispatch/SystemTestCase.html)
* [`Rails::Generators::TestCase`](https://api.rubyonrails.org/classes/Rails/Generators/TestCase.html)

Cada uma dessas classes inclui `Minitest::Assertions`, permitindo que usemos todas as assertivas básicas em nossos testes.

NOTA: Para obter mais informações sobre o `Minitest`, consulte [sua documentação](http://docs.seattlerb.org/minitest).

### O Executador de Testes do Rails

Podemos executar todos os nossos testes de uma vez usando o comando `bin/rails test`.

Ou podemos executar um único arquivo de teste passando o comando `bin/rails test` seguido do nome do arquivo que contém os casos de teste.

```bash
$ bin/rails test test/models/article_test.rb
Opções de execução: --seed 1559

# Executando:

..

Concluído em 0.027034s, 73.9810 execuções/s, 110.9715 assertivas/s.

2 execuções, 3 assertivas, 0 falhas, 0 erros, 0 ignoradas
```

Isso executará todos os métodos de teste do caso de teste.

Você também pode executar um método de teste específico do caso de teste fornecendo a
opção `-n` ou `--name` seguida do nome do método de teste.

```bash
$ bin/rails test test/models/article_test.rb -n test_the_truth
Opções de execução: -n test_the_truth --seed 43583

# Executando:

.

Testes concluídos em 0.009064s, 110.3266 testes/s, 110.3266 assertivas/s.

1 teste, 1 assertiva, 0 falhas, 0 erros, 0 ignoradas
```

Você também pode executar um teste em uma linha específica fornecendo o número da linha.

```bash
$ bin/rails test test/models/article_test.rb:6 # executar teste específico e linha
```

Você também pode executar um diretório inteiro de testes fornecendo o caminho para o diretório.

```bash
$ bin/rails test test/controllers # executar todos os testes de um diretório específico
```

O executador de testes também oferece muitos outros recursos, como falha rápida, adiamento da saída dos testes
no final da execução dos testes, e assim por diante. Verifique a documentação do executador de testes da seguinte forma:

```bash
$ bin/rails test -h
Uso: rails test [opções] [arquivos ou diretórios]

Você pode executar um único teste anexando um número de linha a um nome de arquivo:

    bin/rails test test/models/user_test.rb:27

Você pode executar vários arquivos e diretórios ao mesmo tempo:

    bin/rails test test/controllers test/integration/login_test.rb

Por padrão, falhas e erros nos testes são relatados durante a execução.

Opções do minitest:
    -h, --help                       Exibe esta ajuda.
        --no-plugins                 Ignora o carregamento automático de plugins do minitest (ou defina $MT_NO_PLUGINS).
    -s, --seed SEED                  Define a semente aleatória. Também pode ser definida via env. Ex: SEED=n rake
    -v, --verbose                    Detalhado. Mostra o progresso do processamento dos arquivos.
    -n, --name PATTERN               Filtra a execução com /regexp/ ou string.
        --exclude PATTERN            Exclui /regexp/ ou string da execução.

Extensões conhecidas: rails, pride
    -w, --warnings                   Executa com avisos Ruby habilitados
    -e, --environment ENV            Executa os testes no ambiente ENV
    -b, --backtrace                  Mostra o backtrace completo
    -d, --defer-output               Exibe falhas e erros dos testes após a execução dos testes
    -f, --fail-fast                  Aborta a execução dos testes na primeira falha ou erro
    -c, --[no-]color                 Habilita a cor na saída
    -p, --pride                      Orgulho. Mostre seu orgulho nos testes!
```
### Executando testes em Integração Contínua (CI)

Para executar todos os testes em um ambiente de CI, há apenas um comando que você precisa:

```bash
$ bin/rails test
```

Se você estiver usando [Testes de Sistema](#testes-de-sistema), `bin/rails test` não os executará, pois
eles podem ser lentos. Para executá-los também, adicione uma etapa adicional de CI que execute `bin/rails test:system`,
ou altere sua primeira etapa para `bin/rails test:all`, que executa todos os testes, incluindo os testes de sistema.

Testes Paralelos
----------------

Os testes paralelos permitem que você paralelize seu conjunto de testes. Embora a criação de processos seja o
método padrão, também é possível usar threads. A execução de testes em paralelo reduz o tempo necessário
para executar todo o conjunto de testes.

### Testes Paralelos com Processos

O método de paralelização padrão é criar processos usando o sistema DRb do Ruby. Os processos
são criados com base no número de workers fornecidos. O número padrão é o número real de núcleos
na máquina em que você está, mas pode ser alterado pelo número passado para o método parallelize.

Para habilitar a paralelização, adicione o seguinte ao seu `test_helper.rb`:

```ruby
class ActiveSupport::TestCase
  parallelize(workers: 2)
end
```

O número de workers passado é o número de vezes que o processo será criado. Talvez você queira
paralelizar seu conjunto de testes local de forma diferente do seu CI, então uma variável de ambiente é fornecida
para poder alterar facilmente o número de workers que um teste deve usar:

```bash
$ PARALLEL_WORKERS=15 bin/rails test
```

Ao paralelizar os testes, o Active Record lida automaticamente com a criação de um banco de dados e o carregamento do esquema no banco de dados para cada
processo. Os bancos de dados terão um sufixo com o número correspondente ao worker. Por exemplo, se você
tiver 2 workers, os testes criarão `test-database-0` e `test-database-1`, respectivamente.

Se o número de workers passado for 1 ou menos, os processos não serão criados e os testes não serão
paralelizados, e os testes usarão o banco de dados original `test-database`.

Dois hooks são fornecidos, um é executado quando o processo é criado e outro é executado antes que o processo criado seja encerrado.
Isso pode ser útil se seu aplicativo usar vários bancos de dados ou executar outras tarefas que dependem do número de
workers.

O método `parallelize_setup` é chamado logo após a criação dos processos. O método `parallelize_teardown`
é chamado imediatamente antes que os processos sejam encerrados.

```ruby
class ActiveSupport::TestCase
  parallelize_setup do |worker|
    # configurar bancos de dados
  end

  parallelize_teardown do |worker|
    # limpar bancos de dados
  end

  parallelize(workers: :number_of_processors)
end
```

Esses métodos não são necessários nem estão disponíveis ao usar testes paralelos com threads.

### Testes Paralelos com Threads

Se você preferir usar threads ou estiver usando o JRuby, uma opção de paralelização com threads é fornecida. O paralelizador com threads
é suportado pelo `Parallel::Executor` do Minitest.

Para alterar o método de paralelização para usar threads em vez de processos, adicione o seguinte ao seu `test_helper.rb`:

```ruby
class ActiveSupport::TestCase
  parallelize(workers: :number_of_processors, with: :threads)
end
```

Aplicações Rails geradas a partir do JRuby ou TruffleRuby incluirão automaticamente a opção `with: :threads`.

O número de workers passado para `parallelize` determina o número de threads que os testes usarão. Talvez você
queira paralelizar seu conjunto de testes local de forma diferente do seu CI, então uma variável de ambiente é fornecida
para poder alterar facilmente o número de workers que um teste deve usar:

```bash
$ PARALLEL_WORKERS=15 bin/rails test
```

### Testando Transações Paralelas

O Rails envolve automaticamente qualquer caso de teste em uma transação de banco de dados que é revertida
após a conclusão do teste. Isso torna os casos de teste independentes uns dos outros
e as alterações no banco de dados são visíveis apenas dentro de um único teste.

Quando você deseja testar código que executa transações paralelas em threads,
as transações podem bloquear umas às outras porque já estão aninhadas sob a transação de teste.

Você pode desabilitar as transações em uma classe de caso de teste definindo
`self.use_transactional_tests = false`:

```ruby
class WorkerTest < ActiveSupport::TestCase
  self.use_transactional_tests = false

  test "transações paralelas" do
    # iniciar algumas threads que criam transações
  end
end
```

NOTA: Com testes transacionais desabilitados, você precisa limpar quaisquer dados que os testes criem,
pois as alterações não são revertidas automaticamente após a conclusão do teste.

### Limite para paralelizar testes

A execução de testes em paralelo adiciona uma sobrecarga em termos de configuração do banco de dados e
carregamento de fixtures. Por causa disso, o Rails não paralelizará execuções que envolvam
menos de 50 testes.

Você pode configurar esse limite em seu `test.rb`:

```ruby
config.active_support.test_parallelization_threshold = 100
```

E também ao configurar a paralelização no nível do caso de teste:

```ruby
class ActiveSupport::TestCase
  parallelize threshold: 100
end
```

O Banco de Dados de Teste
------------------------

Quase toda aplicação Rails interage intensamente com um banco de dados e, como resultado, seus testes também precisarão de um banco de dados para interagir. Para escrever testes eficientes, você precisará entender como configurar esse banco de dados e preenchê-lo com dados de exemplo.

Por padrão, toda aplicação Rails possui três ambientes: desenvolvimento, teste e produção. O banco de dados para cada um deles é configurado em `config/database.yml`.

Um banco de dados de teste dedicado permite que você configure e interaja com dados de teste de forma isolada. Dessa forma, seus testes podem manipular dados de teste com confiança, sem se preocupar com os dados nos bancos de dados de desenvolvimento ou produção.

### Mantendo o Esquema do Banco de Dados de Teste

Para executar seus testes, seu banco de dados de teste precisará ter a estrutura atual.
O helper de teste verifica se o banco de dados de teste possui alguma migração pendente.
Ele tentará carregar seu `db/schema.rb` ou `db/structure.sql` no banco de dados de teste.
Se ainda houver migrações pendentes, um erro será gerado.
Isso geralmente indica que seu esquema não está totalmente migrado.
Executar as migrações no banco de dados de desenvolvimento (`bin/rails db:migrate`) atualizará o esquema.

NOTA: Se houver modificações nas migrações existentes, o banco de dados de teste precisa ser reconstruído.
Isso pode ser feito executando `bin/rails db:test:prepare`.

### Entendendo as Fixtures

Para bons testes, você precisará pensar em como configurar os dados de teste.
No Rails, você pode fazer isso definindo e personalizando fixtures.
Você pode encontrar documentação abrangente na [documentação da API de Fixtures](https://api.rubyonrails.org/classes/ActiveRecord/FixtureSet.html).

#### O que são Fixtures?

_Fixtures_ é um termo sofisticado para dados de exemplo. Fixtures permitem que você preencha seu banco de dados de teste com dados predefinidos antes da execução dos testes. As fixtures são independentes do banco de dados e escritas em YAML. Há um arquivo por modelo.

NOTA: As fixtures não são projetadas para criar todos os objetos que seus testes precisam e são melhor gerenciadas quando usadas apenas para dados padrão que podem ser aplicados ao caso comum.

Você encontrará as fixtures no diretório `test/fixtures`. Quando você executa `bin/rails generate model` para criar um novo modelo, o Rails automaticamente cria stubs de fixtures neste diretório.

#### YAML

As fixtures formatadas em YAML são uma maneira amigável para humanos descreverem seus dados de exemplo. Esse tipo de fixture tem a extensão de arquivo **.yml** (como `users.yml`).

Aqui está um exemplo de arquivo de fixture YAML:

```yaml
# eis que sou um comentário YAML!
david:
  name: David Heinemeier Hansson
  birthday: 1979-10-15
  profession: Desenvolvimento de sistemas

steve:
  name: Steve Ross Kellock
  birthday: 1974-09-27
  profession: cara com teclado
```

Cada fixture recebe um nome seguido de uma lista indentada de pares chave/valor separados por dois pontos. Os registros são normalmente separados por uma linha em branco. Você pode colocar comentários em um arquivo de fixture usando o caractere # na primeira coluna.

Se você estiver trabalhando com [associações](/association_basics.html), você pode
definir um nó de referência entre duas fixtures diferentes. Aqui está um exemplo com
uma associação `belongs_to`/`has_many`:

```yaml
# test/fixtures/categories.yml
about:
  name: Sobre
```

```yaml
# test/fixtures/articles.yml
first:
  title: Bem-vindo ao Rails!
  category: about
```

```yaml
# test/fixtures/action_text/rich_texts.yml
first_content:
  record: first (Article)
  name: content
  body: <div>Olá, de <strong>uma fixture</strong></div>
```

Observe que a chave `category` do primeiro Artigo encontrado em `fixtures/articles.yml` tem um valor de `about`, e que a chave `record` da entrada `first_content` encontrada em `fixtures/action_text/rich_texts.yml` tem um valor de `first (Article)`. Isso indica ao Active Record para carregar a Categoria `about` encontrada em `fixtures/categories.yml` para o primeiro caso, e ao Action Text para carregar o Artigo `first` encontrado em `fixtures/articles.yml` para o segundo caso.

NOTA: Para que as associações se refiram umas às outras pelo nome, você pode usar o nome da fixture em vez de especificar o atributo `id:` nas fixtures associadas. O Rails atribuirá automaticamente uma chave primária para ser consistente entre as execuções. Para obter mais informações sobre esse comportamento de associação, leia a [documentação da API de Fixtures](https://api.rubyonrails.org/classes/ActiveRecord/FixtureSet.html).

#### Fixtures de Anexos de Arquivos

Assim como outros modelos com suporte do Active Record, os registros de anexos do Active Storage
herdam instâncias de ActiveRecord::Base e, portanto, podem ser preenchidos por fixtures.

Considere um modelo `Article` que possui uma imagem associada como um anexo `thumbnail`,
juntamente com dados de fixture YAML:

```ruby
class Article
  has_one_attached :thumbnail
end
```

```yaml
# test/fixtures/articles.yml
first:
  title: Um Artigo
```
Supondo que haja um arquivo codificado [image/png][] em `test/fixtures/files/first.png`, as seguintes entradas de fixture YAML irão gerar os registros relacionados `ActiveStorage::Blob` e `ActiveStorage::Attachment`:

```yaml
# test/fixtures/active_storage/blobs.yml
first_thumbnail_blob: <%= ActiveStorage::FixtureSet.blob filename: "first.png" %>
```

```yaml
# test/fixtures/active_storage/attachments.yml
first_thumbnail_attachment:
  name: thumbnail
  record: first (Article)
  blob: first_thumbnail_blob
```


#### ERB'in It Up

O ERB permite que você incorpore código Ruby nos templates. O formato de fixture YAML é pré-processado com ERB quando o Rails carrega as fixtures. Isso permite que você use Ruby para ajudar a gerar alguns dados de exemplo. Por exemplo, o código a seguir gera mil usuários:

```erb
<% 1000.times do |n| %>
user_<%= n %>:
  username: <%= "user#{n}" %>
  email: <%= "user#{n}@example.com" %>
<% end %>
```

#### Fixtures in Action

O Rails carrega automaticamente todas as fixtures do diretório `test/fixtures` por padrão. O carregamento envolve três etapas:

1. Remover quaisquer dados existentes da tabela correspondente à fixture
2. Carregar os dados da fixture na tabela
3. Salvar os dados da fixture em um método caso você queira acessá-los diretamente

DICA: Para remover os dados existentes do banco de dados, o Rails tenta desabilitar os gatilhos de integridade referencial (como chaves estrangeiras e restrições de verificação). Se você estiver recebendo erros de permissão ao executar testes, verifique se o usuário do banco de dados tem privilégio para desabilitar esses gatilhos no ambiente de teste. (No PostgreSQL, apenas superusuários podem desabilitar todos os gatilhos. Leia mais sobre as permissões do PostgreSQL [aqui](https://www.postgresql.org/docs/current/sql-altertable.html)).

#### Fixtures são Objetos Active Record

As fixtures são instâncias do Active Record. Como mencionado no ponto #3 acima, você pode acessar o objeto diretamente porque ele está automaticamente disponível como um método cujo escopo é local do caso de teste. Por exemplo:

```ruby
# isso irá retornar o objeto User para a fixture chamada david
users(:david)

# isso irá retornar a propriedade id para david
users(:david).id

# também é possível acessar métodos disponíveis na classe User
david = users(:david)
david.call(david.partner)
```

Para obter várias fixtures de uma vez, você pode passar uma lista de nomes de fixtures. Por exemplo:

```ruby
# isso irá retornar um array contendo as fixtures david e steve
users(:david, :steve)
```


Testando Modelos
----------------

Os testes de modelos são usados para testar os vários modelos da sua aplicação.

Os testes de modelos do Rails são armazenados no diretório `test/models`. O Rails fornece um gerador para criar um esqueleto de teste de modelo para você.

```bash
$ bin/rails generate test_unit:model article title:string body:text
create  test/models/article_test.rb
create  test/fixtures/articles.yml
```

Os testes de modelos não possuem sua própria superclasse como `ActionMailer::TestCase`. Em vez disso, eles herdam de [`ActiveSupport::TestCase`](https://api.rubyonrails.org/classes/ActiveSupport/TestCase.html).

Testando o Sistema
------------------

Os testes de sistema permitem testar as interações do usuário com a sua aplicação, executando testes em um navegador real ou em um navegador sem interface gráfica. Os testes de sistema usam o Capybara por baixo dos panos.

Para criar testes de sistema no Rails, você usa o diretório `test/system` na sua aplicação. O Rails fornece um gerador para criar um esqueleto de teste de sistema para você.

```bash
$ bin/rails generate system_test users
      invoke test_unit
      create test/system/users_test.rb
```

Aqui está como um teste de sistema recém-gerado se parece:

```ruby
require "application_system_test_case"

class UsersTest < ApplicationSystemTestCase
  # test "visiting the index" do
  #   visit users_url
  #
  #   assert_selector "h1", text: "Users"
  # end
end
```

Por padrão, os testes de sistema são executados com o driver Selenium, usando o navegador Chrome e um tamanho de tela de 1400x1400. A próxima seção explica como alterar as configurações padrão.

### Alterando as Configurações Padrão

O Rails torna muito simples alterar as configurações padrão dos testes de sistema. Toda a configuração é abstraída para que você possa se concentrar em escrever seus testes.

Quando você gera uma nova aplicação ou scaffold, um arquivo `application_system_test_case.rb` é criado no diretório de testes. É nele que todas as configurações dos seus testes de sistema devem estar.

Se você deseja alterar as configurações padrão, pode alterar o que os testes de sistema são "guiados por". Digamos que você queira alterar o driver de Selenium para Cuprite. Primeiro, adicione a gema `cuprite` ao seu `Gemfile`. Em seguida, no arquivo `application_system_test_case.rb`, faça o seguinte:

```ruby
require "test_helper"
require "capybara/cuprite"

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  driven_by :cuprite
end
```

O nome do driver é um argumento obrigatório para `driven_by`. Os argumentos opcionais que podem ser passados para `driven_by` são `:using` para o navegador (isso será usado apenas pelo Selenium), `:screen_size` para alterar o tamanho da tela para capturas de tela e `:options` que podem ser usadas para definir opções suportadas pelo driver.
```ruby
require "test_helper"

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  driven_by :selenium, using: :firefox
end
```

Se você quiser usar um navegador sem interface gráfica, você pode usar o Headless Chrome ou o Headless Firefox adicionando `headless_chrome` ou `headless_firefox` no argumento `:using`.

```ruby
require "test_helper"

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  driven_by :selenium, using: :headless_chrome
end
```

Se você quiser usar um navegador remoto, por exemplo, o [Headless Chrome no Docker](https://github.com/SeleniumHQ/docker-selenium), você precisa adicionar a `url` remota por meio das `options`.

```ruby
require "test_helper"

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  options = ENV["SELENIUM_REMOTE_URL"].present? ? { url: ENV["SELENIUM_REMOTE_URL"] } : {}
  driven_by :selenium, using: :headless_chrome, options: options
end
```

Nesse caso, a gem `webdrivers` não é mais necessária. Você pode removê-la completamente ou adicionar a opção `require:` no `Gemfile`.

```ruby
# ...
group :test do
  gem "webdrivers", require: !ENV["SELENIUM_REMOTE_URL"] || ENV["SELENIUM_REMOTE_URL"].empty?
end
```

Agora você deve obter uma conexão com o navegador remoto.

```bash
$ SELENIUM_REMOTE_URL=http://localhost:4444/wd/hub bin/rails test:system
```

Se sua aplicação em teste também estiver sendo executada remotamente, por exemplo, em um contêiner Docker, o Capybara precisa de mais informações sobre como [chamar servidores remotos](https://github.com/teamcapybara/capybara#calling-remote-servers).

```ruby
require "test_helper"

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  def setup
    Capybara.server_host = "0.0.0.0" # vincula a todas as interfaces
    Capybara.app_host = "http://#{IPSocket.getaddress(Socket.gethostname)}" if ENV["SELENIUM_REMOTE_URL"].present?
    super
  end
  # ...
end
```

Agora você deve obter uma conexão com o navegador e o servidor remotos, independentemente se estiverem sendo executados em um contêiner Docker ou em um CI.

Se sua configuração do Capybara requer mais configurações do que as fornecidas pelo Rails, essa configuração adicional pode ser adicionada ao arquivo `application_system_test_case.rb`.

Consulte a [documentação do Capybara](https://github.com/teamcapybara/capybara#setup) para configurações adicionais.

### Screenshot Helper

O `ScreenshotHelper` é um helper projetado para capturar screenshots dos seus testes. Isso pode ser útil para visualizar o navegador no ponto em que um teste falhou ou para visualizar as screenshots posteriormente para depuração.

Dois métodos são fornecidos: `take_screenshot` e `take_failed_screenshot`. O `take_failed_screenshot` é automaticamente incluído no `before_teardown` dentro do Rails.

O método helper `take_screenshot` pode ser incluído em qualquer lugar dos seus testes para tirar uma screenshot do navegador.

### Implementando um Teste de Sistema

Agora vamos adicionar um teste de sistema à nossa aplicação de blog. Vamos demonstrar como escrever um teste de sistema visitando a página de índice e criando um novo artigo de blog.

Se você usou o gerador de scaffold, um esqueleto de teste de sistema foi criado automaticamente para você. Se você não usou o gerador de scaffold, comece criando um esqueleto de teste de sistema.

```bash
$ bin/rails generate system_test articles
```

Deveria ter criado um arquivo de teste reservado para nós. Com a saída do comando anterior, você deverá ver:

```
      invoke  test_unit
      create    test/system/articles_test.rb
```

Agora vamos abrir esse arquivo e escrever nossa primeira asserção:

```ruby
require "application_system_test_case"

class ArticlesTest < ApplicationSystemTestCase
  test "visualizando o índice" do
    visit articles_path
    assert_selector "h1", text: "Artigos"
  end
end
```

O teste deve verificar se há um elemento `h1` na página de índice dos artigos e passar.

Execute os testes de sistema.

```bash
$ bin/rails test:system
```

NOTA: Por padrão, executar `bin/rails test` não executará seus testes de sistema. Certifique-se de executar `bin/rails test:system` para executá-los de fato. Você também pode executar `bin/rails test:all` para executar todos os testes, incluindo os testes de sistema.

#### Criando um Teste de Sistema para Artigos

Agora vamos testar o fluxo de criação de um novo artigo em nosso blog.

```ruby
test "deve criar um Artigo" do
  visit articles_path

  click_on "Novo Artigo"

  fill_in "Título", with: "Criando um Artigo"
  fill_in "Corpo", with: "Artigo criado com sucesso!"

  click_on "Criar Artigo"

  assert_text "Criando um Artigo"
end
```

O primeiro passo é chamar `visit articles_path`. Isso levará o teste à página de índice dos artigos.

Em seguida, o `click_on "Novo Artigo"` encontrará o botão "Novo Artigo" na página de índice. Isso redirecionará o navegador para `/articles/new`.

Em seguida, o teste preencherá o título e o corpo do artigo com o texto especificado. Assim que os campos forem preenchidos, será clicado em "Criar Artigo", o que enviará uma solicitação POST para criar o novo artigo no banco de dados.

Seremos redirecionados de volta à página de índice dos artigos e lá verificamos se o texto do título do novo artigo está na página de índice dos artigos.

#### Testando em Múltiplos Tamanhos de Tela

Se você quiser testar para tamanhos de tela móveis além de testar para desktop, você pode criar outra classe que herda de `ActionDispatch::SystemTestCase` e usá-la em seu conjunto de testes. Neste exemplo, um arquivo chamado `mobile_system_test_case.rb` é criado no diretório `/test` com a seguinte configuração.
```ruby
require "test_helper"

class MobileSystemTestCase < ActionDispatch::SystemTestCase
  driven_by :selenium, using: :chrome, screen_size: [375, 667]
end
```

Para usar essa configuração, crie um teste dentro de `test/system` que herde de `MobileSystemTestCase`.
Agora você pode testar seu aplicativo usando várias configurações diferentes.

```ruby
require "mobile_system_test_case"

class PostsTest < MobileSystemTestCase
  test "visiting the index" do
    visit posts_url
    assert_selector "h1", text: "Posts"
  end
end
```

#### Indo Além

A beleza dos testes de sistema é que eles são semelhantes aos testes de integração
que testam a interação do usuário com o controlador, modelo e visualização, mas
os testes de sistema são muito mais robustos e realmente testam seu aplicativo como se
um usuário real estivesse usando-o. Daqui para frente, você pode testar qualquer coisa que o usuário
fará em seu aplicativo, como comentar, excluir artigos, publicar artigos rascunho, etc.

Testes de Integração
-------------------

Os testes de integração são usados para testar como várias partes do nosso aplicativo interagem. Eles são geralmente usados para testar fluxos de trabalho importantes dentro do nosso aplicativo.

Para criar testes de integração no Rails, usamos o diretório `test/integration` do nosso aplicativo. O Rails fornece um gerador para criar um esqueleto de teste de integração para nós.

```bash
$ bin/rails generate integration_test user_flows
      exists  test/integration/
      create  test/integration/user_flows_test.rb
```

Aqui está como um teste de integração recém-gerado se parece:

```ruby
require "test_helper"

class UserFlowsTest < ActionDispatch::IntegrationTest
  # test "the truth" do
  #   assert true
  # end
end
```

Aqui o teste herda de `ActionDispatch::IntegrationTest`. Isso disponibiliza alguns helpers adicionais para usarmos em nossos testes de integração.

### Helpers Disponíveis para Testes de Integração

Além dos helpers de teste padrão, herdar de `ActionDispatch::IntegrationTest` vem com alguns helpers adicionais disponíveis ao escrever testes de integração. Vamos nos familiarizar brevemente com as três categorias de helpers que podemos escolher.

Para lidar com o executor de teste de integração, consulte [`ActionDispatch::Integration::Runner`](https://api.rubyonrails.org/classes/ActionDispatch/Integration/Runner.html).

Ao realizar solicitações, teremos [`ActionDispatch::Integration::RequestHelpers`](https://api.rubyonrails.org/classes/ActionDispatch/Integration/RequestHelpers.html) disponível para uso.

Se precisarmos modificar a sessão ou o estado do nosso teste de integração, dê uma olhada em [`ActionDispatch::Integration::Session`](https://api.rubyonrails.org/classes/ActionDispatch/Integration/Session.html) para obter ajuda.

### Implementando um Teste de Integração

Vamos adicionar um teste de integração ao nosso aplicativo de blog. Começaremos com um fluxo de trabalho básico de criação de um novo artigo de blog para verificar se tudo está funcionando corretamente.

Vamos começar gerando o esqueleto do nosso teste de integração:

```bash
$ bin/rails generate integration_test blog_flow
```

Deve ter criado um espaço reservado para o arquivo de teste. Com a saída do
comando anterior, devemos ver:

```
      invoke  test_unit
      create    test/integration/blog_flow_test.rb
```

Agora vamos abrir esse arquivo e escrever nossa primeira asserção:

```ruby
require "test_helper"

class BlogFlowTest < ActionDispatch::IntegrationTest
  test "can see the welcome page" do
    get "/"
    assert_select "h1", "Welcome#index"
  end
end
```

Vamos dar uma olhada em `assert_select` para consultar o HTML resultante de uma solicitação na seção "Testando Visualizações" abaixo. Ele é usado para testar a resposta de nossa solicitação, verificando a presença de elementos HTML-chave e seu conteúdo.

Quando visitamos nosso caminho raiz, devemos ver `welcome/index.html.erb` renderizado para a visualização. Portanto, essa asserção deve passar.

#### Criando Integração de Artigos

Que tal testar nossa capacidade de criar um novo artigo em nosso blog e ver o artigo resultante.

```ruby
test "can create an article" do
  get "/articles/new"
  assert_response :success

  post "/articles",
    params: { article: { title: "can create", body: "article successfully." } }
  assert_response :redirect
  follow_redirect!
  assert_response :success
  assert_select "p", "Title:\n  can create"
end
```

Vamos quebrar esse teste para que possamos entendê-lo.

Começamos chamando a ação `:new` em nosso controlador de Artigos. Essa resposta deve ser bem-sucedida.

Depois disso, fazemos uma solicitação de postagem para a ação `:create` do nosso controlador de Artigos:

```ruby
post "/articles",
  params: { article: { title: "can create", body: "article successfully." } }
assert_response :redirect
follow_redirect!
```

As duas linhas seguintes à solicitação são para lidar com o redirecionamento que configuramos ao criar um novo artigo.

NOTA: Não se esqueça de chamar `follow_redirect!` se planeja fazer solicitações subsequentes após um redirecionamento.

Finalmente, podemos afirmar que nossa resposta foi bem-sucedida e nosso novo artigo pode ser lido na página.

#### Indo Além

Conseguimos testar com sucesso um fluxo de trabalho muito pequeno para visitar nosso blog e criar um novo artigo. Se quiséssemos ir além, poderíamos adicionar testes para comentar, remover artigos ou editar comentários. Os testes de integração são um ótimo lugar para experimentar todos os tipos de casos de uso para nossos aplicativos.
Testes Funcionais para seus Controladores
------------------------------------------

No Rails, testar as várias ações de um controlador é uma forma de escrever testes funcionais. Lembre-se de que seus controladores lidam com as solicitações web recebidas pela sua aplicação e, eventualmente, respondem com uma visualização renderizada. Ao escrever testes funcionais, você está testando como suas ações lidam com as solicitações e o resultado ou resposta esperada, em alguns casos uma visualização HTML.

### O que incluir em seus testes funcionais

Você deve testar coisas como:

* a solicitação web foi bem-sucedida?
* o usuário foi redirecionado para a página correta?
* a autenticação do usuário foi bem-sucedida?
* a mensagem apropriada foi exibida para o usuário na visualização?
* as informações corretas foram exibidas na resposta?

A maneira mais fácil de ver os testes funcionais em ação é gerar um controlador usando o gerador de scaffold:

```bash
$ bin/rails generate scaffold_controller article title:string body:text
...
create  app/controllers/articles_controller.rb
...
invoke  test_unit
create    test/controllers/articles_controller_test.rb
...
```

Isso irá gerar o código do controlador e os testes para um recurso `Article`. Você pode dar uma olhada no arquivo `articles_controller_test.rb` no diretório `test/controllers`.

Se você já tem um controlador e só quer gerar o código de scaffold de teste para cada uma das sete ações padrão, você pode usar o seguinte comando:

```bash
$ bin/rails generate test_unit:scaffold article
...
invoke  test_unit
create    test/controllers/articles_controller_test.rb
...
```

Vamos dar uma olhada em um desses testes, `test_should_get_index` do arquivo `articles_controller_test.rb`.

```ruby
# articles_controller_test.rb
class ArticlesControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get articles_url
    assert_response :success
  end
end
```

No teste `test_should_get_index`, o Rails simula uma solicitação na ação chamada `index`, garantindo que a solicitação tenha sido bem-sucedida e também garantindo que o corpo de resposta correto tenha sido gerado.

O método `get` inicia a solicitação web e preenche os resultados na variável `@response`. Ele pode aceitar até 6 argumentos:

* O URI da ação do controlador que você está solicitando. Isso pode ser na forma de uma string ou um helper de rota (por exemplo, `articles_url`).
* `params`: opção com um hash de parâmetros de solicitação para passar para a ação (por exemplo, parâmetros de string de consulta ou variáveis de artigo).
* `headers`: para definir os cabeçalhos que serão passados com a solicitação.
* `env`: para personalizar o ambiente da solicitação conforme necessário.
* `xhr`: se a solicitação é uma solicitação Ajax ou não. Pode ser definido como true para marcar a solicitação como Ajax.
* `as`: para codificar a solicitação com um tipo de conteúdo diferente.

Todos esses argumentos de palavra-chave são opcionais.

Exemplo: Chamando a ação `:show` para o primeiro `Article`, passando um cabeçalho `HTTP_REFERER`:

```ruby
get article_url(Article.first), headers: { "HTTP_REFERER" => "http://example.com/home" }
```

Outro exemplo: Chamando a ação `:update` para o último `Article`, passando um novo texto para o `title` em `params`, como uma solicitação Ajax:

```ruby
patch article_url(Article.last), params: { article: { title: "atualizado" } }, xhr: true
```

Mais um exemplo: Chamando a ação `:create` para criar um novo artigo, passando texto para o `title` em `params`, como uma solicitação JSON:

```ruby
post articles_path, params: { article: { title: "Ahoy!" } }, as: :json
```

NOTA: Se você tentar executar o teste `test_should_create_article` de `articles_controller_test.rb`, ele falhará devido à validação adicionada no nível do modelo e com razão.

Vamos modificar o teste `test_should_create_article` em `articles_controller_test.rb` para que todos os nossos testes passem:

```ruby
test "should create article" do
  assert_difference("Article.count") do
    post articles_url, params: { article: { body: "Rails é incrível!", title: "Olá Rails" } }
  end

  assert_redirected_to article_path(Article.last)
end
```

Agora você pode tentar executar todos os testes e eles devem passar.

NOTA: Se você seguiu as etapas na seção [Autenticação Básica](getting_started.html#basic-authentication), você precisará adicionar autorização a cada cabeçalho de solicitação para que todos os testes passem:

```ruby
post articles_url, params: { article: { body: "Rails é incrível!", title: "Olá Rails" } }, headers: { Authorization: ActionController::HttpAuthentication::Basic.encode_credentials("dhh", "secret") }
```

### Tipos de Solicitação Disponíveis para Testes Funcionais

Se você está familiarizado com o protocolo HTTP, saberá que `get` é um tipo de solicitação. Existem 6 tipos de solicitação suportados nos testes funcionais do Rails:

* `get`
* `post`
* `patch`
* `put`
* `head`
* `delete`

Todos os tipos de solicitação têm métodos equivalentes que você pode usar. Em uma aplicação típica de C.R.U.D., você usará `get`, `post`, `put` e `delete` com mais frequência.
NOTA: Os testes funcionais não verificam se o tipo de solicitação especificado é aceito pela ação, estamos mais preocupados com o resultado. Os testes de solicitação existem para esse caso de uso, para tornar seus testes mais úteis.

### Testando solicitações XHR (Ajax)

Para testar solicitações Ajax, você pode especificar a opção `xhr: true` para os métodos `get`, `post`, `patch`, `put` e `delete`. Por exemplo:

```ruby
test "solicitação ajax" do
  article = articles(:one)
  get article_url(article), xhr: true

  assert_equal "hello world", @response.body
  assert_equal "text/javascript", @response.media_type
end
```

### As Três Hashes do Apocalipse

Após uma solicitação ter sido feita e processada, você terá 3 objetos Hash prontos para uso:

* `cookies` - Quaisquer cookies que estejam definidos
* `flash` - Quaisquer objetos presentes no flash
* `session` - Qualquer objeto presente nas variáveis de sessão

Como acontece com objetos Hash normais, você pode acessar os valores referenciando as chaves por string. Você também pode referenciá-los pelo nome do símbolo. Por exemplo:

```ruby
flash["gordon"]               flash[:gordon]
session["shmession"]          session[:shmession]
cookies["are_good_for_u"]     cookies[:are_good_for_u]
```

### Variáveis de Instância Disponíveis

**Após** uma solicitação ser feita, você também tem acesso a três variáveis de instância em seus testes funcionais:

* `@controller` - O controlador que está processando a solicitação
* `@request` - O objeto de solicitação
* `@response` - O objeto de resposta


```ruby
class ArticlesControllerTest < ActionDispatch::IntegrationTest
  test "deve obter índice" do
    get articles_url

    assert_equal "index", @controller.action_name
    assert_equal "application/x-www-form-urlencoded", @request.media_type
    assert_match "Articles", @response.body
  end
end
```

### Definindo Cabeçalhos e Variáveis CGI

[Cabeçalhos HTTP](https://tools.ietf.org/search/rfc2616#section-5.3)
e
[Variáveis CGI](https://tools.ietf.org/search/rfc3875#section-4.1)
podem ser passados como cabeçalhos:

```ruby
# definindo um cabeçalho HTTP
get articles_url, headers: { "Content-Type": "text/plain" } # simula a solicitação com cabeçalho personalizado

# definindo uma variável CGI
get articles_url, headers: { "HTTP_REFERER": "http://example.com/home" } # simula a solicitação com variável de ambiente personalizada
```

### Testando Avisos do `flash`

Se você se lembra do que foi dito anteriormente, uma das Três Hashes do Apocalipse era o `flash`.

Queremos adicionar uma mensagem `flash` à nossa aplicação de blog sempre que alguém criar com sucesso um novo Artigo.

Vamos começar adicionando essa asserção ao nosso teste `test_should_create_article`:

```ruby
test "deve criar artigo" do
  assert_difference("Article.count") do
    post articles_url, params: { article: { title: "Algum título" } }
  end

  assert_redirected_to article_path(Article.last)
  assert_equal "Artigo criado com sucesso.", flash[:notice]
end
```

Se executarmos nosso teste agora, deveríamos ver uma falha:

```bash
$ bin/rails test test/controllers/articles_controller_test.rb -n test_should_create_article
Opções de execução: -n test_should_create_article --seed 32266

# Executando:

F

Concluído em 0,114870s, 8,7055 execuções/s, 34,8220 asserções/s.

  1) Falha:
ArticlesControllerTest#test_should_create_article [/test/controllers/articles_controller_test.rb:16]:
--- esperado
+++ atual
@@ -1 +1 @@
-"Artigo criado com sucesso."
+nil

1 execuções, 4 asserções, 1 falha, 0 erros, 0 ignorados
```

Vamos implementar a mensagem `flash` agora em nosso controlador. Nossa ação `:create` deve ficar assim:

```ruby
def create
  @article = Article.new(article_params)

  if @article.save
    flash[:notice] = "Artigo criado com sucesso."
    redirect_to @article
  else
    render "new"
  end
end
```

Agora, se executarmos nossos testes, deveríamos ver que eles passam:

```bash
$ bin/rails test test/controllers/articles_controller_test.rb -n test_should_create_article
Opções de execução: -n test_should_create_article --seed 18981

# Executando:

.

Concluído em 0,081972s, 12,1993 execuções/s, 48,7972 asserções/s.

1 execuções, 4 asserções, 0 falhas, 0 erros, 0 ignorados
```

### Juntando Tudo

Neste ponto, nosso controlador de Artigos testa as ações `:index`, `:new` e `:create`. E quanto ao tratamento de dados existentes?

Vamos escrever um teste para a ação `:show`:

```ruby
test "deve mostrar artigo" do
  article = articles(:one)
  get article_url(article)
  assert_response :success
end
```

Lembre-se de nossa discussão anterior sobre fixtures, o método `articles()` nos dará acesso às nossas fixtures de Artigos.

E quanto à exclusão de um Artigo existente?

```ruby
test "deve excluir artigo" do
  article = articles(:one)
  assert_difference("Article.count", -1) do
    delete article_url(article)
  end

  assert_redirected_to articles_path
end
```

Também podemos adicionar um teste para atualizar um Artigo existente.

```ruby
test "deve atualizar artigo" do
  article = articles(:one)

  patch article_url(article), params: { article: { title: "atualizado" } }

  assert_redirected_to article_path(article)
  # Recarrega a associação para buscar os dados atualizados e verifica se o título foi atualizado.
  article.reload
  assert_equal "atualizado", article.title
end
```

Observe que estamos começando a ver alguma duplicação nesses três testes, eles acessam os mesmos dados de fixture do Artigo. Podemos simplificar isso usando os métodos `setup` e `teardown` fornecidos por `ActiveSupport::Callbacks`.

Nosso teste deve ficar assim agora. Ignore os outros testes por enquanto, estamos deixando-os de fora por brevidade.
```ruby
require "test_helper"

class ArticlesControllerTest < ActionDispatch::IntegrationTest
  # chamado antes de cada teste
  setup do
    @article = articles(:one)
  end

  # chamado depois de cada teste
  teardown do
    # quando o controlador está usando cache, pode ser uma boa ideia limpá-lo depois
    Rails.cache.clear
  end

  test "should show article" do
    # Reutilize a variável de instância @article do setup
    get article_url(@article)
    assert_response :success
  end

  test "should destroy article" do
    assert_difference("Article.count", -1) do
      delete article_url(@article)
    end

    assert_redirected_to articles_path
  end

  test "should update article" do
    patch article_url(@article), params: { article: { title: "updated" } }

    assert_redirected_to article_path(@article)
    # Recarregue a associação para buscar os dados atualizados e verifique se o título foi atualizado.
    @article.reload
    assert_equal "updated", @article.title
  end
end
```

Assim como outros callbacks no Rails, os métodos `setup` e `teardown` também podem ser usados passando um bloco, lambda ou nome do método como um símbolo para chamar.

### Test Helpers

Para evitar duplicação de código, você pode adicionar seus próprios test helpers.
Um exemplo é o helper de login:

```ruby
# test/test_helper.rb

module SignInHelper
  def sign_in_as(user)
    post sign_in_url(email: user.email, password: user.password)
  end
end

class ActionDispatch::IntegrationTest
  include SignInHelper
end
```

```ruby
require "test_helper"

class ProfileControllerTest < ActionDispatch::IntegrationTest
  test "should show profile" do
    # o helper agora pode ser reutilizado em qualquer caso de teste de controlador
    sign_in_as users(:david)

    get profile_url
    assert_response :success
  end
end
```

#### Usando Arquivos Separados

Se você achar que seus helpers estão poluindo o `test_helper.rb`, você pode extraí-los para arquivos separados.
Um bom lugar para armazená-los é `test/lib` ou `test/test_helpers`.

```ruby
# test/test_helpers/multiple_assertions.rb
module MultipleAssertions
  def assert_multiple_of_forty_two(number)
    assert (number % 42 == 0), "expected #{number} to be a multiple of 42"
  end
end
```

Esses helpers podem então ser explicitamente requeridos conforme necessário e incluídos conforme necessário

```ruby
require "test_helper"
require "test_helpers/multiple_assertions"

class NumberTest < ActiveSupport::TestCase
  include MultipleAssertions

  test "420 is a multiple of forty two" do
    assert_multiple_of_forty_two 420
  end
end
```

ou eles podem continuar sendo incluídos diretamente nas classes pai relevantes

```ruby
# test/test_helper.rb
require "test_helpers/sign_in_helper"

class ActionDispatch::IntegrationTest
  include SignInHelper
end
```

#### Requerendo Helpers Antecipadamente

Você pode achar conveniente requerer helpers antecipadamente no `test_helper.rb` para que seus arquivos de teste tenham acesso implícito a eles. Isso pode ser feito usando globbing, da seguinte forma

```ruby
# test/test_helper.rb
Dir[Rails.root.join("test", "test_helpers", "**", "*.rb")].each { |file| require file }
```

Isso tem a desvantagem de aumentar o tempo de inicialização, em comparação com a requisição manual apenas dos arquivos necessários em seus testes individuais.

Testando Rotas
--------------

Assim como tudo o mais em sua aplicação Rails, você pode testar suas rotas. Os testes de rotas ficam em `test/controllers/` ou fazem parte dos testes de controlador.

NOTA: Se sua aplicação tiver rotas complexas, o Rails fornece vários helpers úteis para testá-las.

Para obter mais informações sobre asserções de roteamento disponíveis no Rails, consulte a documentação da API para [`ActionDispatch::Assertions::RoutingAssertions`](https://api.rubyonrails.org/classes/ActionDispatch/Assertions/RoutingAssertions.html).

Testando Views
-------------

Testar a resposta à sua solicitação, verificando a presença de elementos HTML chave e seu conteúdo, é uma maneira comum de testar as views de sua aplicação. Assim como os testes de rota, os testes de view ficam em `test/controllers/` ou fazem parte dos testes de controlador. O método `assert_select` permite consultar elementos HTML da resposta usando uma sintaxe simples, mas poderosa.

Existem duas formas de `assert_select`:

`assert_select(selector, [equality], [message])` garante que a condição de igualdade seja atendida nos elementos selecionados pelo seletor. O seletor pode ser uma expressão de seletor CSS (String) ou uma expressão com valores de substituição.

`assert_select(element, selector, [equality], [message])` garante que a condição de igualdade seja atendida em todos os elementos selecionados pelo seletor, começando pelo _elemento_ (instância de `Nokogiri::XML::Node` ou `Nokogiri::XML::NodeSet`) e seus descendentes.

Por exemplo, você pode verificar o conteúdo do elemento de título em sua resposta com:

```ruby
assert_select "title", "Welcome to Rails Testing Guide"
```

Você também pode usar blocos aninhados de `assert_select` para investigações mais profundas.

No exemplo a seguir, o `assert_select` interno para `li.menu_item` é executado dentro da coleção de elementos selecionados pelo bloco externo:

```ruby
assert_select "ul.navigation" do
  assert_select "li.menu_item"
end
```

Uma coleção de elementos selecionados pode ser iterada para que `assert_select` possa ser chamado separadamente para cada elemento.

Por exemplo, se a resposta contiver duas listas ordenadas, cada uma com quatro elementos de lista aninhados, os seguintes testes serão aprovados.

```ruby
assert_select "ol" do |elements|
  elements.each do |element|
    assert_select element, "li", 4
  end
end

assert_select "ol" do
  assert_select "li", 8
end
```

Essa afirmação é bastante poderosa. Para uso mais avançado, consulte a [documentação](https://github.com/rails/rails-dom-testing/blob/master/lib/rails/dom/testing/assertions/selector_assertions.rb).

### Asserts Adicionais Baseados em Visualização

Existem mais asserts que são usados principalmente para testar visualizações:

| Assert                                                      | Propósito |
| ---------------------------------------------------------- | --------- |
| `assert_select_email`                                       | Permite fazer asserts no corpo de um e-mail. |
| `assert_select_encoded`                                     | Permite fazer asserts em HTML codificado. Ele faz isso decodificando o conteúdo de cada elemento e chamando o bloco com todos os elementos decodificados. |
| `css_select(selector)` ou `css_select(element, selector)`   | Retorna uma matriz de todos os elementos selecionados pelo _selector_. Na segunda variante, ele primeiro corresponde ao _elemento_ base e tenta corresponder à expressão _selector_ em qualquer um de seus filhos. Se não houver correspondências, ambas as variantes retornam uma matriz vazia. |

Aqui está um exemplo de uso de `assert_select_email`:

```ruby
assert_select_email do
  assert_select "small", "Please click the 'Unsubscribe' link if you want to opt-out."
end
```

Testando Helpers
---------------

Um helper é apenas um módulo simples onde você pode definir métodos que estão disponíveis em suas visualizações.

Para testar helpers, tudo o que você precisa fazer é verificar se a saída do método helper corresponde ao que você espera. Os testes relacionados aos helpers estão localizados no diretório `test/helpers`.

Dado que temos o seguinte helper:

```ruby
module UsersHelper
  def link_to_user(user)
    link_to "#{user.first_name} #{user.last_name}", user
  end
end
```

Podemos testar a saída desse método assim:

```ruby
class UsersHelperTest < ActionView::TestCase
  test "should return the user's full name" do
    user = users(:david)

    assert_dom_equal %{<a href="/user/#{user.id}">David Heinemeier Hansson</a>}, link_to_user(user)
  end
end
```

Além disso, como a classe de teste estende `ActionView::TestCase`, você tem acesso aos métodos auxiliares do Rails, como `link_to` ou `pluralize`.

Testando Seus Mailers
--------------------

Testar classes de mailer requer algumas ferramentas específicas para fazer um trabalho completo.

### Mantendo o Carteiro sob Controle

Suas classes de mailer - assim como qualquer outra parte de sua aplicação Rails - devem ser testadas para garantir que estejam funcionando como o esperado.

Os objetivos de testar suas classes de mailer são garantir que:

* os e-mails estejam sendo processados (criados e enviados)
* o conteúdo do e-mail esteja correto (assunto, remetente, corpo, etc)
* os e-mails corretos estejam sendo enviados nos momentos certos

#### Por Todos os Lados

Existem dois aspectos de testar seu mailer, os testes de unidade e os testes funcionais. Nos testes de unidade, você executa o mailer de forma isolada com entradas controladas e compara a saída com um valor conhecido (um fixture). Nos testes funcionais, você não testa tanto os detalhes minuciosos produzidos pelo mailer; em vez disso, testamos se nossos controladores e modelos estão usando o mailer da maneira correta. Você testa para provar que o e-mail certo foi enviado no momento certo.

### Testes de Unidade

Para testar se seu mailer está funcionando como o esperado, você pode usar testes de unidade para comparar os resultados reais do mailer com exemplos pré-escritos do que deve ser produzido.

#### A Vingança dos Fixtures

Para fins de teste de unidade de um mailer, os fixtures são usados para fornecer um exemplo de como a saída _deve_ ser. Por serem e-mails de exemplo e não dados do Active Record como os outros fixtures, eles são mantidos em seu próprio subdiretório separado dos outros fixtures. O nome do diretório dentro de `test/fixtures` corresponde diretamente ao nome do mailer. Portanto, para um mailer chamado `UserMailer`, os fixtures devem estar no diretório `test/fixtures/user_mailer`.

Se você gerou seu mailer, o gerador não cria fixtures de stub para as ações do mailer. Você terá que criar esses arquivos você mesmo, conforme descrito acima.

#### O Caso Básico de Teste

Aqui está um teste de unidade para testar um mailer chamado `UserMailer` cuja ação `invite` é usada para enviar um convite a um amigo. É uma versão adaptada do teste base criado pelo gerador para uma ação `invite`.

```ruby
require "test_helper"

class UserMailerTest < ActionMailer::TestCase
  test "invite" do
    # Crie o e-mail e armazene-o para mais asserts
    email = UserMailer.create_invite("me@example.com",
                                     "friend@example.com", Time.now)

    # Envie o e-mail e, em seguida, teste se ele foi enfileirado
    assert_emails 1 do
      email.deliver_now
    end

    # Teste se o corpo do e-mail enviado contém o que esperamos
    assert_equal ["me@example.com"], email.from
    assert_equal ["friend@example.com"], email.to
    assert_equal "You have been invited by me@example.com", email.subject
    assert_equal read_fixture("invite").join, email.body.to_s
  end
end
```
No teste, criamos o email e armazenamos o objeto retornado na variável `email`. Em seguida, garantimos que ele foi enviado (o primeiro assert), depois, no segundo conjunto de asserts, garantimos que o email realmente contém o que esperamos. O helper `read_fixture` é usado para ler o conteúdo deste arquivo.

NOTA: `email.body.to_s` está presente quando há apenas uma parte (HTML ou texto) presente. Se o mailer fornecer ambos, você pode testar sua fixture em partes específicas com `email.text_part.body.to_s` ou `email.html_part.body.to_s`.

Aqui está o conteúdo da fixture `invite`:

```
Oi friend@example.com,

Você foi convidado.

Saúde!
```

Este é o momento certo para entender um pouco mais sobre como escrever testes para seus mailers. A linha `ActionMailer::Base.delivery_method = :test` em `config/environments/test.rb` define o método de entrega para o modo de teste, para que o email não seja realmente entregue (útil para evitar spam aos usuários durante os testes), mas sim seja adicionado a um array (`ActionMailer::Base.deliveries`).

NOTA: O array `ActionMailer::Base.deliveries` é redefinido automaticamente nos testes `ActionMailer::TestCase` e `ActionDispatch::IntegrationTest`. Se você quiser ter uma base limpa fora desses casos de teste, pode redefini-la manualmente com: `ActionMailer::Base.deliveries.clear`

#### Testando Emails Enfileirados

Você pode usar a asserção `assert_enqueued_email_with` para confirmar que o email foi enfileirado com todos os argumentos do método mailer esperados e/ou parâmetros parametrizados do mailer. Isso permite que você corresponda a qualquer email que tenha sido enfileirado com o método `deliver_later`.

Assim como no caso de teste básico, criamos o email e armazenamos o objeto retornado na variável `email`. Os exemplos a seguir incluem variações de passagem de argumentos e/ou parâmetros.

Este exemplo irá assegurar que o email foi enfileirado com os argumentos corretos:

```ruby
require "test_helper"

class UserMailerTest < ActionMailer::TestCase
  test "invite" do
    # Cria o email e o armazena para asserções posteriores
    email = UserMailer.create_invite("me@example.com", "friend@example.com")

    # Testa se o email foi enfileirado com os argumentos corretos
    assert_enqueued_email_with UserMailer, :create_invite, args: ["me@example.com", "friend@example.com"] do
      email.deliver_later
    end
  end
end
```

Este exemplo irá assegurar que um mailer foi enfileirado com os argumentos nomeados corretos do método mailer, passando um hash dos argumentos como `args`:

```ruby
require "test_helper"

class UserMailerTest < ActionMailer::TestCase
  test "invite" do
    # Cria o email e o armazena para asserções posteriores
    email = UserMailer.create_invite(from: "me@example.com", to: "friend@example.com")

    # Testa se o email foi enfileirado com os argumentos nomeados corretos
    assert_enqueued_email_with UserMailer, :create_invite, args: [{ from: "me@example.com",
                                                                    to: "friend@example.com" }] do
      email.deliver_later
    end
  end
end
```

Este exemplo irá assegurar que um mailer parametrizado foi enfileirado com os parâmetros e argumentos corretos. Os parâmetros do mailer são passados como `params` e os argumentos do método mailer como `args`:

```ruby
require "test_helper"

class UserMailerTest < ActionMailer::TestCase
  test "invite" do
    # Cria o email e o armazena para asserções posteriores
    email = UserMailer.with(all: "good").create_invite("me@example.com", "friend@example.com")

    # Testa se o email foi enfileirado com os parâmetros e argumentos corretos do mailer
    assert_enqueued_email_with UserMailer, :create_invite, params: { all: "good" },
                                                           args: ["me@example.com", "friend@example.com"] do
      email.deliver_later
    end
  end
end
```

Este exemplo mostra uma maneira alternativa de testar se um mailer parametrizado foi enfileirado com os parâmetros corretos:

```ruby
require "test_helper"

class UserMailerTest < ActionMailer::TestCase
  test "invite" do
    # Cria o email e o armazena para asserções posteriores
    email = UserMailer.with(to: "friend@example.com").create_invite

    # Testa se o email foi enfileirado com os parâmetros corretos do mailer
    assert_enqueued_email_with UserMailer.with(to: "friend@example.com"), :create_invite do
      email.deliver_later
    end
  end
end
```

### Testes Funcionais e de Sistema

Os testes unitários nos permitem testar os atributos do email, enquanto os testes funcionais e de sistema nos permitem testar se as interações do usuário acionam adequadamente o envio do email. Por exemplo, você pode verificar se a operação de convidar um amigo está enviando um email adequadamente:

```ruby
# Teste de Integração
require "test_helper"

class UsersControllerTest < ActionDispatch::IntegrationTest
  test "invite friend" do
    # Verifica a diferença em ActionMailer::Base.deliveries
    assert_emails 1 do
      post invite_friend_url, params: { email: "friend@example.com" }
    end
  end
end
```

```ruby
# Teste de Sistema
require "test_helper"

class UsersTest < ActionDispatch::SystemTestCase
  driven_by :selenium, using: :headless_chrome

  test "convidar um amigo" do
    visit invite_users_url
    fill_in "Email", with: "friend@example.com"
    assert_emails 1 do
      click_on "Convidar"
    end
  end
end
```

NOTA: O método `assert_emails` não está vinculado a um método de entrega específico e funcionará com emails entregues tanto com o método `deliver_now` quanto com o método `deliver_later`. Se quisermos explicitamente afirmar que o email foi enfileirado, podemos usar os métodos `assert_enqueued_email_with` ([exemplos acima](#testing-enqueued-emails)) ou `assert_enqueued_emails`. Mais informações podem ser encontradas na [documentação aqui](https://api.rubyonrails.org/classes/ActionMailer/TestHelper.html).
Testando Jobs
------------

Como seus jobs personalizados podem ser enfileirados em diferentes níveis dentro de sua aplicação,
você precisará testar tanto os jobs em si (seu comportamento quando são enfileirados)
quanto se outras entidades os enfileiram corretamente.

### Um Caso de Teste Básico

Por padrão, quando você gera um job, um teste associado também será gerado
no diretório `test/jobs`. Aqui está um exemplo de teste com um job de faturamento:

```ruby
require "test_helper"

class BillingJobTest < ActiveJob::TestCase
  test "que a conta é cobrada" do
    BillingJob.perform_now(conta, produto)
    assert conta.reload.cobrado_por?(produto)
  end
end
```

Este teste é bastante simples e apenas verifica se o job fez o trabalho esperado.

### Assertivas Personalizadas e Testando Jobs em Outros Componentes

O Active Job vem com um conjunto de assertivas personalizadas que podem ser usadas para diminuir a verbosidade dos testes. Para obter uma lista completa de assertivas disponíveis, consulte a documentação da API para [`ActiveJob::TestHelper`](https://api.rubyonrails.org/classes/ActiveJob/TestHelper.html).

É uma boa prática garantir que seus jobs sejam enfileirados ou executados corretamente
onde quer que você os invoque (por exemplo, dentro de seus controladores). É exatamente aqui
que as assertivas personalizadas fornecidas pelo Active Job são bastante úteis. Por exemplo,
dentro de um modelo, você pode confirmar que um job foi enfileirado:

```ruby
require "test_helper"

class ProductTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  test "agendamento do job de faturamento" do
    assert_enqueued_with(job: BillingJob) do
      produto.cobrar(conta)
    end
    assert_not conta.reload.cobrado_por?(produto)
  end
end
```

O adaptador padrão, `:test`, não executa os jobs quando eles são enfileirados.
Você precisa informar quando deseja que os jobs sejam executados:

```ruby
require "test_helper"

class ProductTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  test "agendamento do job de faturamento" do
    perform_enqueued_jobs(only: BillingJob) do
      produto.cobrar(conta)
    end
    assert conta.reload.cobrado_por?(produto)
  end
end
```

Todos os jobs executados e enfileirados anteriormente são limpos antes de cada execução de teste,
portanto, você pode assumir com segurança que nenhum job já foi executado no escopo de cada teste.

Testando Action Cable
--------------------

Como o Action Cable é usado em diferentes níveis dentro de sua aplicação,
você precisará testar tanto os canais e classes de conexão em si quanto se outras
entidades transmitem as mensagens corretas.

### Caso de Teste de Conexão

Por padrão, quando você gera uma nova aplicação Rails com o Action Cable, um teste para a classe de conexão base (`ApplicationCable::Connection`) também é gerado no diretório `test/channels/application_cable`.

Os testes de conexão têm como objetivo verificar se os identificadores de uma conexão são atribuídos corretamente
ou se quaisquer solicitações de conexão impróprias são rejeitadas. Aqui está um exemplo:

```ruby
class ApplicationCable::ConnectionTest < ActionCable::Connection::TestCase
  test "conecta com parâmetros" do
    # Simula a abertura de uma conexão chamando o método `connect`
    connect params: { user_id: 42 }

    # Você pode acessar o objeto Connection via `connection` nos testes
    assert_equal connection.user_id, "42"
  end

  test "rejeita conexão sem parâmetros" do
    # Use o matcher `assert_reject_connection` para verificar se
    # a conexão é rejeitada
    assert_reject_connection { connect }
  end
end
```

Você também pode especificar cookies de solicitação da mesma forma que faz em testes de integração:

```ruby
test "conecta com cookies" do
  cookies.signed[:user_id] = "42"

  connect

  assert_equal connection.user_id, "42"
end
```

Consulte a documentação da API para [`ActionCable::Connection::TestCase`](https://api.rubyonrails.org/classes/ActionCable/Connection/TestCase.html) para obter mais informações.

### Caso de Teste de Canal

Por padrão, quando você gera um canal, um teste associado também será gerado
no diretório `test/channels`. Aqui está um exemplo de teste com um canal de chat:

```ruby
require "test_helper"

class ChatChannelTest < ActionCable::Channel::TestCase
  test "inscreve e transmite para sala" do
    # Simula a criação de uma inscrição chamando `subscribe`
    subscribe room: "15"

    # Você pode acessar o objeto Channel via `subscription` nos testes
    assert subscription.confirmed?
    assert_has_stream "chat_15"
  end
end
```

Este teste é bastante simples e apenas verifica se o canal inscreve a conexão em um fluxo específico.

Você também pode especificar os identificadores de conexão subjacentes. Aqui está um exemplo de teste com um canal de notificações da web:

```ruby
require "test_helper"

class WebNotificationsChannelTest < ActionCable::Channel::TestCase
  test "inscreve e transmite para usuário" do
    stub_connection current_user: users(:john)

    subscribe

    assert_has_stream_for users(:john)
  end
end
```

Consulte a documentação da API para [`ActionCable::Channel::TestCase`](https://api.rubyonrails.org/classes/ActionCable/Channel/TestCase.html) para obter mais informações.

### Assertivas Personalizadas e Testando Transmissões em Outros Componentes

O Action Cable vem com um conjunto de assertivas personalizadas que podem ser usadas para diminuir a verbosidade dos testes. Para obter uma lista completa de assertivas disponíveis, consulte a documentação da API para [`ActionCable::TestHelper`](https://api.rubyonrails.org/classes/ActionCable/TestHelper.html).

É uma boa prática garantir que a mensagem correta tenha sido transmitida em outros componentes (por exemplo, dentro de seus controladores). É exatamente aqui
que as assertivas personalizadas fornecidas pelo Action Cable são bastante úteis. Por exemplo,
dentro de um modelo:
```ruby
require "test_helper"

class ProductTest < ActionCable::TestCase
  test "transmitir status após cobrança" do
    assert_broadcast_on("products:#{product.id}", type: "charged") do
      product.charge(account)
    end
  end
end
```

Se você quiser testar a transmissão feita com `Channel.broadcast_to`, você deve usar
`Channel.broadcasting_for` para gerar um nome de stream subjacente:

```ruby
# app/jobs/chat_relay_job.rb
class ChatRelayJob < ApplicationJob
  def perform(room, message)
    ChatChannel.broadcast_to room, text: message
  end
end
```

```ruby
# test/jobs/chat_relay_job_test.rb
require "test_helper"

class ChatRelayJobTest < ActiveJob::TestCase
  include ActionCable::TestHelper

  test "transmitir mensagem para sala" do
    room = rooms(:all)

    assert_broadcast_on(ChatChannel.broadcasting_for(room), text: "Oi!") do
      ChatRelayJob.perform_now(room, "Oi!")
    end
  end
end
```

Testando Carregamento Antecipado
--------------------------------

Normalmente, os aplicativos não carregam antecipadamente nos ambientes `development` ou `test` para acelerar as coisas. Mas eles carregam no ambiente `production`.

Se algum arquivo no projeto não puder ser carregado por qualquer motivo, é melhor detectá-lo antes de implantar na produção, certo?

### Integração Contínua

Se o seu projeto tiver CI em vigor, o carregamento antecipado no CI é uma maneira fácil de garantir que o aplicativo seja carregado antecipadamente.

Os CIs normalmente definem alguma variável de ambiente para indicar que o conjunto de testes está sendo executado lá. Por exemplo, pode ser `CI`:

```ruby
# config/environments/test.rb
config.eager_load = ENV["CI"].present?
```

A partir do Rails 7, os aplicativos recém-gerados são configurados dessa maneira por padrão.

### Conjuntos de Testes Simples

Se o seu projeto não tiver integração contínua, você ainda pode carregar antecipadamente no conjunto de testes chamando `Rails.application.eager_load!`:

#### Minitest

```ruby
require "test_helper"

class ZeitwerkComplianceTest < ActiveSupport::TestCase
  test "carrega antecipadamente todos os arquivos sem erros" do
    assert_nothing_raised { Rails.application.eager_load! }
  end
end
```

#### RSpec

```ruby
require "rails_helper"

RSpec.describe "Conformidade com Zeitwerk" do
  it "carrega antecipadamente todos os arquivos sem erros" do
    expect { Rails.application.eager_load! }.not_to raise_error
  end
end
```

Recursos Adicionais de Teste
----------------------------

### Testando Código Dependente de Tempo

O Rails fornece métodos auxiliares integrados que permitem que você verifique se o seu código sensível ao tempo funciona como esperado.

O exemplo a seguir usa o auxiliar [`travel_to`][travel_to]:

```ruby
# Dado que um usuário é elegível para presentear um mês após o registro.
user = User.create(name: "Gaurish", activation_date: Date.new(2004, 10, 24))
assert_not user.applicable_for_gifting?

travel_to Date.new(2004, 11, 24) do
  # Dentro do bloco `travel_to`, `Date.current` é substituído
  assert_equal Date.new(2004, 10, 24), user.activation_date
  assert user.applicable_for_gifting?
end

# A alteração foi visível apenas dentro do bloco `travel_to`.
assert_equal Date.new(2004, 10, 24), user.activation_date
```

Consulte a referência da API [`ActiveSupport::Testing::TimeHelpers`][time_helpers_api] para obter mais informações sobre os auxiliares de tempo disponíveis.
[`config.active_support.test_order`]: configuring.html#config-active-support-test-order
[image/png]: https://developer.mozilla.org/en-US/docs/Web/HTTP/Basics_of_HTTP/MIME_types#image_types
[travel_to]: https://api.rubyonrails.org/classes/ActiveSupport/Testing/TimeHelpers.html#method-i-travel_to
[time_helpers_api]: https://api.rubyonrails.org/classes/ActiveSupport/Testing/TimeHelpers.html
