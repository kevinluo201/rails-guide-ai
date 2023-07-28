**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 37dd3507f05f7787a794868a2619e6d5
Validações do Active Record
=========================

Este guia ensina como validar o estado dos objetos antes de serem inseridos no banco de dados usando a funcionalidade de validações do Active Record.

Após ler este guia, você saberá:

* Como usar os auxiliares de validação embutidos no Active Record.
* Como criar seus próprios métodos de validação personalizados.
* Como trabalhar com as mensagens de erro geradas pelo processo de validação.

--------------------------------------------------------------------------------

Visão geral das validações
--------------------

Aqui está um exemplo de uma validação muito simples:

```ruby
class Person < ApplicationRecord
  validates :name, presence: true
end
```

```irb
irb> Person.create(name: "John Doe").valid?
=> true
irb> Person.create(name: nil).valid?
=> false
```

Como você pode ver, nossa validação nos informa que nossa `Person` não é válida sem um atributo `name`. A segunda `Person` não será persistida no banco de dados.

Antes de nos aprofundarmos em mais detalhes, vamos falar sobre como as validações se encaixam no contexto geral da sua aplicação.

### Por que usar validações?

As validações são usadas para garantir que apenas dados válidos sejam salvos no seu banco de dados. Por exemplo, pode ser importante para a sua aplicação garantir que cada usuário forneça um endereço de e-mail e um endereço de correspondência válidos. As validações em nível de modelo são a melhor maneira de garantir que apenas dados válidos sejam salvos no seu banco de dados. Elas são independentes do banco de dados, não podem ser ignoradas pelos usuários finais e são convenientes para testar e manter. O Rails fornece auxiliares embutidos para necessidades comuns e permite que você crie seus próprios métodos de validação também.

Existem várias outras maneiras de validar dados antes de salvá-los no banco de dados, incluindo restrições nativas do banco de dados, validações do lado do cliente e validações em nível de controlador. Aqui está um resumo dos prós e contras:

* Restrições e/ou procedimentos armazenados do banco de dados tornam os mecanismos de validação dependentes do banco de dados e podem tornar os testes e a manutenção mais difíceis. No entanto, se o seu banco de dados for usado por outras aplicações, pode ser uma boa ideia usar algumas restrições em nível de banco de dados. Além disso, as validações em nível de banco de dados podem lidar com segurança com algumas coisas (como unicidade em tabelas muito usadas) que podem ser difíceis de implementar de outra forma.
* As validações do lado do cliente podem ser úteis, mas geralmente são pouco confiáveis se usadas sozinhas. Se forem implementadas usando JavaScript, elas podem ser ignoradas se o JavaScript estiver desativado no navegador do usuário. No entanto, se combinadas com outras técnicas, a validação do lado do cliente pode ser uma maneira conveniente de fornecer aos usuários um feedback imediato ao usar o seu site.
* As validações em nível de controlador podem ser tentadoras de usar, mas geralmente se tornam difíceis de gerenciar e testar. Sempre que possível, é uma boa ideia manter seus controladores simples, pois isso tornará sua aplicação mais agradável de trabalhar a longo prazo.

Escolha essas opções em casos específicos. É a opinião da equipe do Rails que as validações em nível de modelo são as mais apropriadas na maioria das circunstâncias.

### Quando a validação ocorre?

Existem dois tipos de objetos Active Record: aqueles que correspondem a uma linha dentro do seu banco de dados e aqueles que não correspondem. Quando você cria um novo objeto, por exemplo, usando o método `new`, esse objeto ainda não pertence ao banco de dados. Uma vez que você chama o método `save` nesse objeto, ele será salvo na tabela do banco de dados apropriada. O Active Record usa o método de instância `new_record?` para determinar se um objeto já está no banco de dados ou não. Considere a seguinte classe Active Record:

```ruby
class Person < ApplicationRecord
end
```

Podemos ver como isso funciona olhando para a saída do `bin/rails console`:

```irb
irb> p = Person.new(name: "John Doe")
=> #<Person id: nil, name: "John Doe", created_at: nil, updated_at: nil>

irb> p.new_record?
=> true

irb> p.save
=> true

irb> p.new_record?
=> false
```

Criar e salvar um novo registro enviará uma operação SQL `INSERT` para o banco de dados. Atualizar um registro existente enviará uma operação SQL `UPDATE`. As validações são normalmente executadas antes desses comandos serem enviados para o banco de dados. Se alguma validação falhar, o objeto será marcado como inválido e o Active Record não executará a operação `INSERT` ou `UPDATE`. Isso evita armazenar um objeto inválido no banco de dados. Você pode escolher executar validações específicas quando um objeto é criado, salvo ou atualizado.

CUIDADO: Existem muitas maneiras de alterar o estado de um objeto no banco de dados. Alguns métodos acionarão as validações, mas outros não. Isso significa que é possível salvar um objeto no banco de dados em um estado inválido se você não tiver cuidado.
Os seguintes métodos acionam as validações e salvarão o objeto no banco de dados apenas se o objeto for válido:

* `create`
* `create!`
* `save`
* `save!`
* `update`
* `update!`

As versões com "!" (por exemplo, `save!`) lançam uma exceção se o registro for inválido. As versões sem "!" não: `save` e `update` retornam `false`, e `create` retorna o objeto.

### Ignorando Validações

Os seguintes métodos ignoram as validações e salvarão o objeto no banco de dados independentemente de sua validade. Eles devem ser usados com cautela.

* `decrement!`
* `decrement_counter`
* `increment!`
* `increment_counter`
* `insert`
* `insert!`
* `insert_all`
* `insert_all!`
* `toggle!`
* `touch`
* `touch_all`
* `update_all`
* `update_attribute`
* `update_column`
* `update_columns`
* `update_counters`
* `upsert`
* `upsert_all`

Observe que `save` também tem a capacidade de ignorar as validações se passado `validate: false` como argumento. Essa técnica deve ser usada com cautela.

* `save(validate: false)`

### `valid?` e `invalid?`

Antes de salvar um objeto Active Record, o Rails executa suas validações. Se essas validações produzirem erros, o Rails não salvará o objeto.

Você também pode executar essas validações por conta própria. [`valid?`][] aciona suas validações e retorna true se nenhum erro for encontrado no objeto e false caso contrário. Como você viu acima:

```ruby
class Person < ApplicationRecord
  validates :name, presence: true
end
```

```irb
irb> Person.create(name: "John Doe").valid?
=> true
irb> Person.create(name: nil).valid?
=> false
```

Depois que o Active Record executou as validações, quaisquer falhas podem ser acessadas através do método de instância [`errors`][]. Esse método retorna uma coleção de erros. Por definição, um objeto é válido se essa coleção estiver vazia após a execução das validações.

Observe que um objeto instanciado com `new` não reportará erros, mesmo que seja tecnicamente inválido, porque as validações são executadas automaticamente apenas quando o objeto é salvo, como nos métodos `create` ou `save`.

```ruby
class Person < ApplicationRecord
  validates :name, presence: true
end
```

```irb
irb> p = Person.new
=> #<Person id: nil, name: nil>
irb> p.errors.size
=> 0

irb> p.valid?
=> false
irb> p.errors.objects.first.full_message
=> "Name can’t be blank"

irb> p = Person.create
=> #<Person id: nil, name: nil>
irb> p.errors.objects.first.full_message
=> "Name can’t be blank"

irb> p.save
=> false

irb> p.save!
ActiveRecord::RecordInvalid: Validation failed: Name can’t be blank

irb> Person.create!
ActiveRecord::RecordInvalid: Validation failed: Name can’t be blank
```

[`invalid?`][] é o inverso de `valid?`. Ele aciona suas validações, retornando true se algum erro for encontrado no objeto e false caso contrário.


### `errors[]`

Para verificar se um atributo específico de um objeto é válido ou não, você pode usar [`errors[:atributo]`][Errors#squarebrackets]. Ele retorna uma matriz com todas as mensagens de erro para `:atributo`. Se não houver erros no atributo especificado, uma matriz vazia será retornada.

Este método só é útil _após_ as validações terem sido executadas, porque ele apenas inspeciona a coleção de erros e não aciona as validações por si só. É diferente do método `ActiveRecord::Base#invalid?` explicado acima porque não verifica a validade do objeto como um todo. Ele verifica apenas se há erros encontrados em um atributo individual do objeto.

```ruby
class Person < ApplicationRecord
  validates :name, presence: true
end
```

```irb
irb> Person.new.errors[:name].any?
=> false
irb> Person.create.errors[:name].any?
=> true
```

Abordaremos os erros de validação com mais detalhes na seção [Trabalhando com Erros de Validação](#working-with-validation-errors).


Assistentes de Validação
------------------

O Active Record oferece muitos assistentes de validação pré-definidos que você pode usar diretamente em suas definições de classe. Esses assistentes fornecem regras de validação comuns. Sempre que uma validação falha, um erro é adicionado à coleção `errors` do objeto e isso é associado ao atributo sendo validado.

Cada assistente aceita um número arbitrário de nomes de atributos, então com uma única linha de código você pode adicionar o mesmo tipo de validação a vários atributos.

Todos eles aceitam as opções `:on` e `:message`, que definem quando a validação deve ser executada e qual mensagem deve ser adicionada à coleção `errors` se ela falhar, respectivamente. A opção `:on` aceita um dos valores `:create` ou `:update`. Há uma mensagem de erro padrão para cada um dos assistentes de validação. Essas mensagens são usadas quando a opção `:message` não é especificada. Vamos dar uma olhada em cada um dos assistentes disponíveis.

INFO: Para ver uma lista dos assistentes padrão disponíveis, dê uma olhada em [`ActiveModel::Validations::HelperMethods`][].
### `acceptance`

Este método valida se uma caixa de seleção na interface do usuário foi marcada quando um formulário foi enviado. Isso é normalmente usado quando o usuário precisa concordar com os termos de serviço do seu aplicativo, confirmar que algum texto foi lido ou qualquer conceito similar.

```ruby
class Person < ApplicationRecord
  validates :terms_of_service, acceptance: true
end
```

Essa verificação é realizada apenas se `terms_of_service` não for `nil`.
A mensagem de erro padrão para esse helper é _"deve ser aceito"_.
Você também pode passar uma mensagem personalizada através da opção `message`.

```ruby
class Person < ApplicationRecord
  validates :terms_of_service, acceptance: { message: 'deve ser cumprido' }
end
```

Também é possível receber uma opção `:accept`, que determina os valores permitidos que serão considerados como aceitáveis. O valor padrão é `['1', true]` e pode ser facilmente alterado.

```ruby
class Person < ApplicationRecord
  validates :terms_of_service, acceptance: { accept: 'yes' }
  validates :eula, acceptance: { accept: ['TRUE', 'accepted'] }
end
```

Essa validação é muito específica para aplicações web e essa 'aceitação' não precisa ser registrada em nenhum lugar do seu banco de dados. Se você não tiver um campo para isso, o helper criará um atributo virtual. Se o campo existir no seu banco de dados, a opção `accept` deve ser definida como ou incluir `true`, caso contrário, a validação não será executada.

### `confirmation`

Você deve usar esse helper quando tiver dois campos de texto que devem receber exatamente o mesmo conteúdo. Por exemplo, você pode querer confirmar um endereço de e-mail ou uma senha. Essa validação cria um atributo virtual cujo nome é o nome do campo que deve ser confirmado, com "_confirmation" adicionado.

```ruby
class Person < ApplicationRecord
  validates :email, confirmation: true
end
```

Em seu modelo de visualização, você pode usar algo como

```erb
<%= text_field :person, :email %>
<%= text_field :person, :email_confirmation %>
```

NOTA: Essa verificação é realizada apenas se `email_confirmation` não for `nil`. Para exigir a confirmação, certifique-se de adicionar uma verificação de presença para o atributo de confirmação (veremos a opção `presence` [mais adiante](#presence) neste guia):

```ruby
class Person < ApplicationRecord
  validates :email, confirmation: true
  validates :email_confirmation, presence: true
end
```

Também há uma opção `:case_sensitive` que você pode usar para definir se a restrição de confirmação será sensível a maiúsculas e minúsculas ou não. Essa opção tem o valor padrão true.

```ruby
class Person < ApplicationRecord
  validates :email, confirmation: { case_sensitive: false }
end
```

A mensagem de erro padrão para esse helper é _"não coincide com a confirmação"_. Você também pode passar uma mensagem personalizada através da opção `message`.

Geralmente, ao usar esse validador, você desejará combiná-lo com a opção `:if` para validar apenas o campo "_confirmation" quando o campo inicial for alterado e **não** toda vez que você salvar o registro. Mais sobre [validações condicionais](#conditional-validation) posteriormente.

```ruby
class Person < ApplicationRecord
  validates :email, confirmation: true
  validates :email_confirmation, presence: true, if: :email_changed?
end
```

### `comparison`

Essa verificação validará uma comparação entre dois valores comparáveis.

```ruby
class Promotion < ApplicationRecord
  validates :end_date, comparison: { greater_than: :start_date }
end
```

A mensagem de erro padrão para esse helper é _"falha na comparação"_. Você também pode passar uma mensagem personalizada através da opção `message`.

Essas opções são todas suportadas:

* `:greater_than` - Especifica que o valor deve ser maior que o valor fornecido. A mensagem de erro padrão para essa opção é _"deve ser maior que %{count}"_.
* `:greater_than_or_equal_to` - Especifica que o valor deve ser maior ou igual ao valor fornecido. A mensagem de erro padrão para essa opção é _"deve ser maior ou igual a %{count}"_.
* `:equal_to` - Especifica que o valor deve ser igual ao valor fornecido. A mensagem de erro padrão para essa opção é _"deve ser igual a %{count}"_.
* `:less_than` - Especifica que o valor deve ser menor que o valor fornecido. A mensagem de erro padrão para essa opção é _"deve ser menor que %{count}"_.
* `:less_than_or_equal_to` - Especifica que o valor deve ser menor ou igual ao valor fornecido. A mensagem de erro padrão para essa opção é _"deve ser menor ou igual a %{count}"_.
* `:other_than` - Especifica que o valor deve ser diferente do valor fornecido. A mensagem de erro padrão para essa opção é _"deve ser diferente de %{count}"_.

NOTA: O validador requer que uma opção de comparação seja fornecida. Cada opção aceita um valor, proc ou símbolo. Qualquer classe que inclua Comparable pode ser comparada.
### `formato`

Este auxiliar valida os valores dos atributos testando se eles correspondem a uma expressão regular fornecida, que é especificada usando a opção `:with`.

```ruby
class Product < ApplicationRecord
  validates :legacy_code, format: { with: /\A[a-zA-Z]+\z/,
    message: "permite apenas letras" }
end
```

Inversamente, usando a opção `:without`, você pode exigir que o atributo especificado _não_ corresponda à expressão regular.

Em ambos os casos, a opção `:with` ou `:without` fornecida deve ser uma expressão regular ou um proc ou lambda que retorne uma.

A mensagem de erro padrão é _"é inválido"_.

ATENÇÃO. use `\A` e `\z` para corresponder ao início e ao fim da string, `^` e `$` correspondem ao início/fim de uma linha. Devido ao uso frequente incorreto de `^` e `$`, você precisa passar a opção `multiline: true` caso use algum desses dois âncoras na expressão regular fornecida. Na maioria dos casos, você deve usar `\A` e `\z`.

### `inclusão`

Este auxiliar valida se os valores dos atributos estão incluídos em um conjunto dado. Na verdade, esse conjunto pode ser qualquer objeto enumerável.

```ruby
class Coffee < ApplicationRecord
  validates :size, inclusion: { in: %w(small medium large),
    message: "%{value} não é um tamanho válido" }
end
```

O auxiliar `inclusão` tem uma opção `:in` que recebe o conjunto de valores que serão aceitos. A opção `:in` tem um alias chamado `:within` que você pode usar para o mesmo propósito, se desejar. O exemplo anterior usa a opção `:message` para mostrar como você pode incluir o valor do atributo. Para todas as opções, consulte a documentação da [mensagem](#mensagem).

A mensagem de erro padrão para este auxiliar é _"não está incluído na lista"_.

### `exclusão`

O oposto de `inclusão` é... `exclusão`!

Este auxiliar valida se os valores dos atributos não estão incluídos em um conjunto dado. Na verdade, esse conjunto pode ser qualquer objeto enumerável.

```ruby
class Account < ApplicationRecord
  validates :subdomain, exclusion: { in: %w(www us ca jp),
    message: "%{value} está reservado." }
end
```

O auxiliar `exclusão` tem uma opção `:in` que recebe o conjunto de valores que não serão aceitos para os atributos validados. A opção `:in` tem um alias chamado `:within` que você pode usar para o mesmo propósito, se desejar. Este exemplo usa a opção `:message` para mostrar como você pode incluir o valor do atributo. Para todas as opções do argumento de mensagem, consulte a documentação da [mensagem](#mensagem).

A mensagem de erro padrão é _"está reservado"_.

Alternativamente a um objeto enumerável tradicional (como um Array), você pode fornecer um proc, lambda ou símbolo que retorna um objeto enumerável. Se o objeto enumerável for um intervalo numérico, de tempo ou de data e hora, o teste é realizado com `Range#cover?`, caso contrário, com `include?`. Ao usar um proc ou lambda, a instância em validação é passada como argumento.

### `comprimento`

Este auxiliar valida o comprimento dos valores dos atributos. Ele fornece uma variedade de opções, para que você possa especificar restrições de comprimento de diferentes maneiras:

```ruby
class Person < ApplicationRecord
  validates :name, length: { minimum: 2 }
  validates :bio, length: { maximum: 500 }
  validates :password, length: { in: 6..20 }
  validates :registration_number, length: { is: 6 }
end
```

As possíveis opções de restrição de comprimento são:

* `:minimum` - O atributo não pode ter menos que o comprimento especificado.
* `:maximum` - O atributo não pode ter mais que o comprimento especificado.
* `:in` (ou `:within`) - O comprimento do atributo deve estar incluído em um determinado intervalo. O valor para esta opção deve ser um intervalo.
* `:is` - O comprimento do atributo deve ser igual ao valor fornecido.

As mensagens de erro padrão dependem do tipo de validação de comprimento sendo realizada. Você pode personalizar essas mensagens usando as opções `:wrong_length`, `:too_long` e `:too_short` e `%{count}` como um espaço reservado para o número correspondente à restrição de comprimento sendo usada. Ainda é possível usar a opção `:message` para especificar uma mensagem de erro.

```ruby
class Person < ApplicationRecord
  validates :bio, length: { maximum: 1000,
    too_long: "%{count} caracteres é o máximo permitido" }
end
```

Observe que as mensagens de erro padrão são no plural (por exemplo, "é muito curto (o mínimo é de %{count} caracteres)"). Por esse motivo, quando `:minimum` é 1, você deve fornecer uma mensagem personalizada ou usar `presence: true` em vez disso. Quando `:in` ou `:within` têm um limite inferior de 1, você deve fornecer uma mensagem personalizada ou chamar `presence` antes de `length`.
NOTA: Apenas uma opção de restrição pode ser usada de cada vez, exceto as opções `:minimum` e `:maximum`, que podem ser combinadas juntas.

### `numericality`

Este auxiliar valida se seus atributos possuem apenas valores numéricos. Por padrão, ele irá corresponder a um sinal opcional seguido de um número inteiro ou de ponto flutuante.

Para especificar que apenas números inteiros são permitidos, defina `:only_integer` como true. Em seguida, ele usará a seguinte expressão regular para validar o valor do atributo.

```ruby
/\A[+-]?\d+\z/
```

Caso contrário, ele tentará converter o valor em um número usando `Float`. `Float`s são convertidos em `BigDecimal` usando o valor de precisão da coluna ou um máximo de 15 dígitos.

```ruby
class Player < ApplicationRecord
  validates :points, numericality: true
  validates :games_played, numericality: { only_integer: true }
end
```

A mensagem de erro padrão para `:only_integer` é _"deve ser um número inteiro"_.

Além de `:only_integer`, este auxiliar também aceita a opção `:only_numeric`, que especifica que o valor deve ser uma instância de `Numeric` e tenta analisar o valor se for uma `String`.

NOTA: Por padrão, `numericality` não permite valores `nil`. Você pode usar a opção `allow_nil: true` para permitir. Observe que para colunas `Integer` e `Float`, strings vazias são convertidas em `nil`.

A mensagem de erro padrão quando nenhuma opção é especificada é _"não é um número"_.

Também existem muitas opções que podem ser usadas para adicionar restrições aos valores aceitáveis:

* `:greater_than` - Especifica que o valor deve ser maior que o valor fornecido. A mensagem de erro padrão para esta opção é _"deve ser maior que %{count}"_.
* `:greater_than_or_equal_to` - Especifica que o valor deve ser maior ou igual ao valor fornecido. A mensagem de erro padrão para esta opção é _"deve ser maior ou igual a %{count}"_.
* `:equal_to` - Especifica que o valor deve ser igual ao valor fornecido. A mensagem de erro padrão para esta opção é _"deve ser igual a %{count}"_.
* `:less_than` - Especifica que o valor deve ser menor que o valor fornecido. A mensagem de erro padrão para esta opção é _"deve ser menor que %{count}"_.
* `:less_than_or_equal_to` - Especifica que o valor deve ser menor ou igual ao valor fornecido. A mensagem de erro padrão para esta opção é _"deve ser menor ou igual a %{count}"_.
* `:other_than` - Especifica que o valor deve ser diferente do valor fornecido. A mensagem de erro padrão para esta opção é _"deve ser diferente de %{count}"_.
* `:in` - Especifica que o valor deve estar dentro do intervalo fornecido. A mensagem de erro padrão para esta opção é _"deve estar em %{count}"_.
* `:odd` - Especifica que o valor deve ser um número ímpar. A mensagem de erro padrão para esta opção é _"deve ser ímpar"_.
* `:even` - Especifica que o valor deve ser um número par. A mensagem de erro padrão para esta opção é _"deve ser par"_.

### `presence`

Este auxiliar valida se os atributos especificados não estão vazios. Ele usa o método [`Object#blank?`][] para verificar se o valor é `nil` ou uma string vazia, ou seja, uma string que está vazia ou consiste apenas de espaços em branco.

```ruby
class Person < ApplicationRecord
  validates :name, :login, :email, presence: true
end
```

Se você deseja garantir que uma associação esteja presente, você precisará testar se o próprio objeto associado está presente e não a chave estrangeira usada para mapear a associação. Dessa forma, não é verificado apenas se a chave estrangeira não está vazia, mas também se o objeto referenciado existe.

```ruby
class Supplier < ApplicationRecord
  has_one :account
  validates :account, presence: true
end
```

Para validar registros associados cuja presença é obrigatória, você deve especificar a opção `:inverse_of` para a associação:

```ruby
class Order < ApplicationRecord
  has_many :line_items, inverse_of: :order
end
```

NOTA: Se você deseja garantir que a associação esteja presente e seja válida, você também precisa usar `validates_associated`. Mais informações
[abaixo](#validates-associated)

Se você valida a presença de um objeto associado por meio de um relacionamento `has_one` ou `has_many`, ele verificará se o objeto não está em branco (`blank?`) e não está marcado para destruição (`marked_for_destruction?`).

Como `false.blank?` é verdadeiro, se você deseja validar a presença de um campo booleano, você deve usar uma das seguintes validações:

```ruby
# O valor _deve_ ser true ou false
validates :nome_do_campo_booleano, inclusion: [true, false]
# O valor _não deve_ ser nil, ou seja, true ou false
validates :nome_do_campo_booleano, exclusion: [nil]
```

Ao usar uma dessas validações, você garantirá que o valor NÃO será `nil`, o que resultaria em um valor `NULL` na maioria dos casos.

A mensagem de erro padrão é _"não pode ficar em branco"_.


### `absence`

Este auxiliar valida se os atributos especificados estão ausentes. Ele usa o método [`Object#present?`][] para verificar se o valor não é `nil` ou uma string em branco, ou seja, uma string que está vazia ou consiste apenas de espaços em branco.

```ruby
class Person < ApplicationRecord
  validates :name, :login, :email, absence: true
end
```

Se você quiser ter certeza de que uma associação está ausente, você precisará testar se o próprio objeto associado está ausente e não a chave estrangeira usada para mapear a associação.

```ruby
class LineItem < ApplicationRecord
  belongs_to :order
  validates :order, absence: true
end
```

Para validar registros associados cuja ausência é necessária, você deve especificar a opção `:inverse_of` para a associação:

```ruby
class Order < ApplicationRecord
  has_many :line_items, inverse_of: :order
end
```

NOTA: Se você deseja garantir que a associação esteja presente e válida, você também precisa usar `validates_associated`. Mais informações sobre isso abaixo.

Se você validar a ausência de um objeto associado por meio de um relacionamento `has_one` ou `has_many`, ele verificará se o objeto não está `present?` nem `marked_for_destruction?`.

Como `false.present?` é falso, se você deseja validar a ausência de um campo booleano, deve usar `validates :nome_do_campo, exclusion: { in: [true, false] }`.

A mensagem de erro padrão é _"deve ficar em branco"_.


### `uniqueness`

Este auxiliar valida se o valor do atributo é único antes de o objeto ser salvo.

```ruby
class Account < ApplicationRecord
  validates :email, uniqueness: true
end
```

A validação é feita executando uma consulta SQL na tabela do modelo, procurando por um registro existente com o mesmo valor nesse atributo.

Existe uma opção `:scope` que você pode usar para especificar um ou mais atributos que são usados para limitar a verificação de unicidade:

```ruby
class Holiday < ApplicationRecord
  validates :name, uniqueness: { scope: :year,
    message: "deve ocorrer uma vez por ano" }
end
```

CUIDADO. Essa validação não cria uma restrição de unicidade no banco de dados, então pode acontecer que duas conexões de banco de dados diferentes criem dois registros com o mesmo valor para uma coluna que você pretende que seja única. Para evitar isso, você deve criar um índice único nessa coluna em seu banco de dados.

Para adicionar uma restrição de unicidade no banco de dados, use a instrução [`add_index`][] em uma migração e inclua a opção `unique: true`.

Se você deseja criar uma restrição de banco de dados para evitar possíveis violações de uma validação de unicidade usando a opção `:scope`, você deve criar um índice único em ambas as colunas em seu banco de dados. Consulte [o manual do MySQL][] para obter mais detalhes sobre índices de várias colunas ou [o manual do PostgreSQL][] para exemplos de restrições únicas que se referem a um grupo de colunas.

Também existe uma opção `:case_sensitive` que você pode usar para definir se a restrição de unicidade será sensível a maiúsculas e minúsculas, insensível a maiúsculas e minúsculas ou respeitar a colação padrão do banco de dados. Essa opção tem como padrão respeitar a colação padrão do banco de dados.

```ruby
class Person < ApplicationRecord
  validates :name, uniqueness: { case_sensitive: false }
end
```

CUIDADO. Observe que alguns bancos de dados são configurados para realizar pesquisas insensíveis a maiúsculas e minúsculas de qualquer maneira.

Existe uma opção `:conditions` que você pode usar para especificar condições adicionais como um fragmento SQL `WHERE` para limitar a busca da restrição de unicidade (por exemplo, `conditions: -> { where(status: 'active') }`).

A mensagem de erro padrão é _"já está em uso"_.

Consulte [`validates_uniqueness_of`][] para obter mais informações.

[o manual do MySQL]: https://dev.mysql.com/doc/refman/en/multiple-column-indexes.html
[o manual do PostgreSQL]: https://www.postgresql.org/docs/current/static/ddl-constraints.html

### `validates_associated`

Você deve usar este auxiliar quando seu modelo tem associações que sempre precisam ser validadas. Sempre que você tentar salvar seu objeto, `valid?` será chamado em cada um dos objetos associados.

```ruby
class Library < ApplicationRecord
  has_many :books
  validates_associated :books
end
```

Essa validação funcionará com todos os tipos de associação.

CUIDADO: Não use `validates_associated` em ambos os lados de suas associações. Eles chamariam um ao outro em um loop infinito.

A mensagem de erro padrão para [`validates_associated`][] é _"é inválido"_. Observe que cada objeto associado conterá sua própria coleção de `errors`; os erros não são propagados para o modelo chamador.

NOTA: [`validates_associated`][] só pode ser usado com objetos ActiveRecord, tudo até agora também pode ser usado em qualquer objeto que inclua [`ActiveModel::Validations`][].
### `validates_each`

Este auxiliar valida atributos contra um bloco. Ele não possui uma função de validação predefinida. Você deve criar uma usando um bloco, e cada atributo passado para [`validates_each`][] será testado contra ele.

No exemplo a seguir, rejeitaremos nomes e sobrenomes que começam com letra minúscula.

```ruby
class Person < ApplicationRecord
  validates_each :name, :surname do |record, attr, value|
    record.errors.add(attr, 'deve começar com letra maiúscula') if /\A[[:lower:]]/.match?(value)
  end
end
```

O bloco recebe o registro, o nome do atributo e o valor do atributo.

Você pode fazer qualquer coisa para verificar dados válidos dentro do bloco. Se a validação falhar, você deve adicionar um erro ao modelo, tornando-o inválido.


### `validates_with`

Este auxiliar passa o registro para uma classe separada para validação.

```ruby
class GoodnessValidator < ActiveModel::Validator
  def validate(record)
    if record.first_name == "Evil"
      record.errors.add :base, "Esta pessoa é má"
    end
  end
end

class Person < ApplicationRecord
  validates_with GoodnessValidator
end
```

Não há mensagem de erro padrão para `validates_with`. Você deve adicionar manualmente erros à coleção de erros do registro na classe do validador.

NOTA: Erros adicionados a `record.errors[:base]` se referem ao estado do registro como um todo.

Para implementar o método de validação, você deve aceitar um parâmetro `record` na definição do método, que é o registro a ser validado.

Se você deseja adicionar um erro em um atributo específico, passe-o como o primeiro argumento, como `record.errors.add(:first_name, "escolha outro nome")`. Abordaremos [erros de validação][] com mais detalhes posteriormente.

```ruby
def validate(record)
  if record.some_field != "aceitável"
    record.errors.add :some_field, "este campo é inaceitável"
  end
end
```

O auxiliar [`validates_with`][] aceita uma classe ou uma lista de classes para usar na validação.

```ruby
class Person < ApplicationRecord
  validates_with MyValidator, MyOtherValidator, on: :create
end
```

Como todas as outras validações, `validates_with` aceita as opções `:if`, `:unless` e `:on`. Se você passar outras opções, elas serão enviadas para a classe do validador como `options`:

```ruby
class GoodnessValidator < ActiveModel::Validator
  def validate(record)
    if options[:fields].any? { |field| record.send(field) == "Evil" }
      record.errors.add :base, "Esta pessoa é má"
    end
  end
end

class Person < ApplicationRecord
  validates_with GoodnessValidator, fields: [:first_name, :last_name]
end
```

Observe que o validador será inicializado *apenas uma vez* para todo o ciclo de vida da aplicação, e não em cada execução de validação, portanto, tenha cuidado ao usar variáveis de instância dentro dele.

Se o seu validador for complexo o suficiente para que você queira variáveis de instância, você pode usar facilmente um objeto Ruby simples em vez disso:

```ruby
class Person < ApplicationRecord
  validate do |person|
    GoodnessValidator.new(person).validate
  end
end

class GoodnessValidator
  def initialize(person)
    @person = person
  end

  def validate
    if some_complex_condition_involving_ivars_and_private_methods?
      @person.errors.add :base, "Esta pessoa é má"
    end
  end

  # ...
end
```

Abordaremos [validações personalizadas](#performing-custom-validations) mais adiante.

[erros de validação](#working-with-validation-errors)

Opções Comuns de Validação
-------------------------

Existem várias opções comuns suportadas pelos validadores que acabamos de ver, vamos ver algumas delas agora!

NOTA: Nem todas essas opções são suportadas por todos os validadores, consulte a documentação da API para [`ActiveModel::Validations`][].

Ao usar qualquer um dos métodos de validação que mencionamos, também há uma lista de opções comuns compartilhadas junto com os validadores. Vamos cobri-las agora!

* [`:allow_nil`](#allow-nil): Ignora a validação se o atributo for `nil`.
* [`:allow_blank`](#allow-blank): Ignora a validação se o atributo estiver em branco.
* [`:message`](#message): Especifica uma mensagem de erro personalizada.
* [`:on`](#on): Especifica os contextos nos quais essa validação está ativa.
* [`:strict`](#strict-validations): Gera uma exceção quando a validação falha.
* [`:if` e `:unless`](#conditional-validation): Especifica quando a validação deve ou não ocorrer.


### `:allow_nil`

A opção `:allow_nil` ignora a validação quando o valor sendo validado é `nil`.

```ruby
class Coffee < ApplicationRecord
  validates :size, inclusion: { in: %w(small medium large),
    message: "%{value} não é um tamanho válido" }, allow_nil: true
end
```

```irb
irb> Coffee.create(size: nil).valid?
=> true
irb> Coffee.create(size: "mega").valid?
=> false
```

Para opções completas para o argumento de mensagem, consulte a
[documentação de mensagem](#message).

### `:allow_blank`

A opção `:allow_blank` é semelhante à opção `:allow_nil`. Essa opção permite que a validação seja aprovada se o valor do atributo estiver em branco, como `nil` ou uma string vazia, por exemplo.

```ruby
class Topic < ApplicationRecord
  validates :title, length: { is: 5 }, allow_blank: true
end
```

```irb
irb> Topic.create(title: "").valid?
=> true
irb> Topic.create(title: nil).valid?
=> true
```

### `:message`
Como você já viu, a opção `:message` permite especificar a mensagem que será adicionada à coleção de `errors` quando a validação falhar. Quando essa opção não é usada, o Active Record usará a mensagem de erro padrão correspondente para cada helper de validação.

A opção `:message` aceita tanto uma `String` quanto um `Proc` como valor.

Um valor `String` `:message` pode opcionalmente conter qualquer/ todos `%{value}`, `%{attribute}` e `%{model}`, que serão substituídos dinamicamente quando a validação falhar. Essa substituição é feita usando a gem i18n, e os espaços reservados devem corresponder exatamente, sem espaços são permitidos.

```ruby
class Person < ApplicationRecord
  # Mensagem codificada
  validates :name, presence: { message: "deve ser fornecido, por favor" }

  # Mensagem com valor de atributo dinâmico. %{value} será substituído
  # pelo valor real do atributo. %{attribute} e %{model}
  # também estão disponíveis.
  validates :age, numericality: { message: "%{value} parece errado" }
end
```

Um valor `Proc` `:message` é fornecido com dois argumentos: o objeto sendo validado e
um hash com pares de chave-valor `:model`, `:attribute` e `:value`.

```ruby
class Person < ApplicationRecord
  validates :username,
    uniqueness: {
      # objeto = objeto de pessoa sendo validado
      # dados = { model: "Person", attribute: "Username", value: <username> }
      message: ->(object, data) do
        "Ei #{object.name}, #{data[:value]} já está em uso."
      end
    }
end
```

### `:on`

A opção `:on` permite especificar quando a validação deve ocorrer. O
comportamento padrão para todos os helpers de validação incorporados é ser executado ao salvar
(tanto ao criar um novo registro quanto ao atualizá-lo). Se você
deseja alterá-lo, pode usar `on: :create` para executar a validação apenas quando um
novo registro é criado ou `on: :update` para executar a validação apenas quando um registro
é atualizado.

```ruby
class Person < ApplicationRecord
  # será possível atualizar o email com um valor duplicado
  validates :email, uniqueness: true, on: :create

  # será possível criar o registro com uma idade não numérica
  validates :age, numericality: true, on: :update

  # o padrão (valida tanto na criação quanto na atualização)
  validates :name, presence: true
end
```

Você também pode usar `on:` para definir contextos personalizados. Contextos personalizados precisam ser
acionados explicitamente passando o nome do contexto para `valid?`,
`invalid?` ou `save`.

```ruby
class Person < ApplicationRecord
  validates :email, uniqueness: true, on: :account_setup
  validates :age, numericality: true, on: :account_setup
end
```

```irb
irb> person = Person.new(age: 'trinta e três')
irb> person.valid?
=> true
irb> person.valid?(:account_setup)
=> false
irb> person.errors.messages
=> {:email=>["já está em uso"], :age=>["não é um número"]}
```

`person.valid?(:account_setup)` executa ambas as validações sem salvar
o modelo. `person.save(context: :account_setup)` valida `person` no
contexto `account_setup` antes de salvar.

Passar um array de símbolos também é aceitável.

```ruby
class Book
  include ActiveModel::Validations

  validates :title, presence: true, on: [:update, :ensure_title]
end
```

```irb
irb> book = Book.new(title: nil)
irb> book.valid?
=> true
irb> book.valid?(:ensure_title)
=> false
irb> book.errors.messages
=> {:title=>["não pode ficar em branco"]}
```

Quando acionadas por um contexto explícito, as validações são executadas para esse contexto,
bem como quaisquer validações _sem_ um contexto.

```ruby
class Person < ApplicationRecord
  validates :email, uniqueness: true, on: :account_setup
  validates :age, numericality: true, on: :account_setup
  validates :name, presence: true
end
```

```irb
irb> person = Person.new
irb> person.valid?(:account_setup)
=> false
irb> person.errors.messages
=> {:email=>["já está em uso"], :age=>["não é um número"], :name=>["não pode ficar em branco"]}
```

Abordaremos mais casos de uso para `on:` no [guia de callbacks](active_record_callbacks.html).

Validações Estritas
------------------

Você também pode especificar validações para serem estritas e gerar
`ActiveModel::StrictValidationFailed` quando o objeto for inválido.

```ruby
class Person < ApplicationRecord
  validates :name, presence: { strict: true }
end
```

```irb
irb> Person.new.valid?
ActiveModel::StrictValidationFailed: O nome não pode ficar em branco
```

Também é possível passar uma exceção personalizada para a opção `:strict`.

```ruby
class Person < ApplicationRecord
  validates :token, presence: true, uniqueness: true, strict: TokenGenerationException
end
```

```irb
irb> Person.new.valid?
TokenGenerationException: O token não pode ficar em branco
```

Validação Condicional
----------------------

Às vezes, fará sentido validar um objeto apenas quando um predicado dado
for satisfeito. Você pode fazer isso usando as opções `:if` e `:unless`, que
podem receber um símbolo, um `Proc` ou um `Array`. Você pode usar a opção `:if` quando
você deseja especificar quando a validação **deve** ocorrer. Alternativamente, se você
deseja especificar quando a validação **não deve** ocorrer, então você pode usar a opção
`:unless`.
### Usando um símbolo com `:if` e `:unless`

Você pode associar as opções `:if` e `:unless` com um símbolo correspondente ao nome de um método que será chamado antes da validação ocorrer. Essa é a opção mais comumente usada.

```ruby
class Order < ApplicationRecord
  validates :card_number, presence: true, if: :paid_with_card?

  def paid_with_card?
    payment_type == "card"
  end
end
```

### Usando um Proc com `:if` e `:unless`

É possível associar `:if` e `:unless` com um objeto `Proc` que será chamado. Usar um objeto `Proc` permite escrever uma condição inline em vez de um método separado. Essa opção é mais adequada para uma única linha.

```ruby
class Account < ApplicationRecord
  validates :password, confirmation: true,
    unless: Proc.new { |a| a.password.blank? }
end
```

Como `lambda` é um tipo de `Proc`, também é possível usar para escrever condições inline aproveitando a sintaxe reduzida.

```ruby
validates :password, confirmation: true, unless: -> { password.blank? }
```

### Agrupando Validações Condicionalmente

Às vezes, é útil ter várias validações usando uma única condição. Isso pode ser facilmente alcançado usando [`with_options`][].

```ruby
class User < ApplicationRecord
  with_options if: :is_admin? do |admin|
    admin.validates :password, length: { minimum: 10 }
    admin.validates :email, presence: true
  end
end
```

Todas as validações dentro do bloco `with_options` passarão automaticamente pela condição `if: :is_admin?`


### Combinando Condições de Validação

Por outro lado, quando várias condições definem se uma validação deve ocorrer ou não, um `Array` pode ser usado. Além disso, você pode aplicar tanto `:if` quanto `:unless` à mesma validação.

```ruby
class Computer < ApplicationRecord
  validates :mouse, presence: true,
                    if: [Proc.new { |c| c.market.retail? }, :desktop?],
                    unless: Proc.new { |c| c.trackpad.present? }
end
```

A validação só é executada quando todas as condições `:if` e nenhuma das condições `:unless` são avaliadas como `true`.

Realizando Validações Personalizadas
-----------------------------

Quando os ajudantes de validação incorporados não são suficientes para suas necessidades, você pode escrever seus próprios validadores ou métodos de validação como preferir.

### Validadores Personalizados

Validadores personalizados são classes que herdam de [`ActiveModel::Validator`][]. Essas classes devem implementar o método `validate`, que recebe um registro como argumento e realiza a validação nele. O validador personalizado é chamado usando o método `validates_with`.

```ruby
class MyValidator < ActiveModel::Validator
  def validate(record)
    unless record.name.start_with? 'X'
      record.errors.add :name, "Forneça um nome começando com X, por favor!"
    end
  end
end

class Person < ApplicationRecord
  validates_with MyValidator
end
```

A maneira mais fácil de adicionar validadores personalizados para validar atributos individuais é com o conveniente [`ActiveModel::EachValidator`][]. Nesse caso, a classe do validador personalizado deve implementar um método `validate_each` que recebe três argumentos: registro, atributo e valor. Eles correspondem à instância, ao atributo a ser validado e ao valor do atributo na instância passada.

```ruby
class EmailValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    unless URI::MailTo::EMAIL_REGEXP.match?(value)
      record.errors.add attribute, (options[:message] || "não é um email")
    end
  end
end

class Person < ApplicationRecord
  validates :email, presence: true, email: true
end
```

Como mostrado no exemplo, você também pode combinar validações padrão com seus próprios validadores personalizados.


### Métodos Personalizados

Você também pode criar métodos que verificam o estado dos seus modelos e adicionam erros à coleção `errors` quando eles são inválidos. Em seguida, você deve registrar esses métodos usando o método de classe [`validate`][], passando os símbolos para os nomes dos métodos de validação.

Você pode passar mais de um símbolo para cada método de classe e as respectivas validações serão executadas na mesma ordem em que foram registradas.

O método `valid?` verificará se a coleção `errors` está vazia, portanto, seus métodos de validação personalizados devem adicionar erros a ela quando você deseja que a validação falhe:

```ruby
class Invoice < ApplicationRecord
  validate :expiration_date_cannot_be_in_the_past,
    :discount_cannot_be_greater_than_total_value

  def expiration_date_cannot_be_in_the_past
    if expiration_date.present? && expiration_date < Date.today
      errors.add(:expiration_date, "não pode estar no passado")
    end
  end

  def discount_cannot_be_greater_than_total_value
    if discount > total_value
      errors.add(:discount, "não pode ser maior que o valor total")
    end
  end
end
```

Por padrão, essas validações serão executadas sempre que você chamar `valid?` ou salvar o objeto. Mas também é possível controlar quando executar essas validações personalizadas, fornecendo uma opção `:on` para o método `validate`, com `:create` ou `:update`.

```ruby
class Invoice < ApplicationRecord
  validate :active_customer, on: :create

  def active_customer
    errors.add(:customer_id, "não está ativo") unless customer.active?
  end
end
```
Consulte a seção acima para obter mais detalhes sobre [`:on`](#on).

### Listando Validadores

Se você deseja descobrir todos os validadores para um determinado objeto, não procure mais do que `validators`.

Por exemplo, se tivermos o seguinte modelo usando um validador personalizado e um validador embutido:

```ruby
class Person < ApplicationRecord
  validates :name, presence: true, on: :create
  validates :email, format: URI::MailTo::EMAIL_REGEXP
  validates_with MyOtherValidator, strict: true
end
```

Agora podemos usar `validators` no modelo "Person" para listar todos os validadores, ou até mesmo verificar um campo específico usando `validators_on`.

```irb
irb> Person.validators
#=> [#<ActiveRecord::Validations::PresenceValidator:0x10b2f2158
      @attributes=[:name], @options={:on=>:create}>,
     #<MyOtherValidatorValidator:0x10b2f17d0
      @attributes=[:name], @options={:strict=>true}>,
     #<ActiveModel::Validations::FormatValidator:0x10b2f0f10
      @attributes=[:email],
      @options={:with=>URI::MailTo::EMAIL_REGEXP}>]
     #<MyOtherValidator:0x10b2f0948 @options={:strict=>true}>]

irb> Person.validators_on(:name)
#=> [#<ActiveModel::Validations::PresenceValidator:0x10b2f2158
      @attributes=[:name], @options={on: :create}>]
```


Trabalhando com Erros de Validação
------------------------------

Os métodos [`valid?`][] e [`invalid?`][] fornecem apenas um status resumido sobre a validade. No entanto, você pode aprofundar cada erro individual usando vários métodos da coleção [`errors`][].

A seguir está uma lista dos métodos mais comumente usados. Consulte a documentação [`ActiveModel::Errors`][] para obter uma lista de todos os métodos disponíveis.


### `errors`

O gateway através do qual você pode aprofundar vários detalhes de cada erro.

Isso retorna uma instância da classe `ActiveModel::Errors` contendo todos os erros, cada erro é representado por um objeto [`ActiveModel::Error`][].

```ruby
class Person < ApplicationRecord
  validates :name, presence: true, length: { minimum: 3 }
end
```

```irb
irb> person = Person.new
irb> person.valid?
=> false
irb> person.errors.full_messages
=> ["Name não pode ficar em branco", "Name é muito curto (mínimo: 3 caracteres)"]

irb> person = Person.new(name: "John Doe")
irb> person.valid?
=> true
irb> person.errors.full_messages
=> []

irb> person = Person.new
irb> person.valid?
=> false
irb> person.errors.first.details
=> {:error=>:too_short, :count=>3}
```


### `errors[]`

[`errors[]`][Errors#squarebrackets] é usado quando você deseja verificar as mensagens de erro para um atributo específico. Ele retorna uma matriz de strings com todas as mensagens de erro para o atributo fornecido, cada string com uma mensagem de erro. Se não houver erros relacionados ao atributo, ele retorna uma matriz vazia.

```ruby
class Person < ApplicationRecord
  validates :name, presence: true, length: { minimum: 3 }
end
```

```irb
irb> person = Person.new(name: "John Doe")
irb> person.valid?
=> true
irb> person.errors[:name]
=> []

irb> person = Person.new(name: "JD")
irb> person.valid?
=> false
irb> person.errors[:name]
=> ["é muito curto (mínimo: 3 caracteres)"]

irb> person = Person.new
irb> person.valid?
=> false
irb> person.errors[:name]
=> ["não pode ficar em branco", "é muito curto (mínimo: 3 caracteres)"]
```

### `errors.where` e Objeto de Erro

Às vezes, podemos precisar de mais informações sobre cada erro além de sua mensagem. Cada erro é encapsulado como um objeto `ActiveModel::Error`, e o método [`where`][] é a maneira mais comum de acessá-lo.

`where` retorna uma matriz de objetos de erro filtrados por vários graus de condições.

```ruby
class Person < ApplicationRecord
  validates :name, presence: true, length: { minimum: 3 }
end
```

Podemos filtrar apenas o `atributo` passando-o como o primeiro parâmetro para `errors.where(:attr)`. O segundo parâmetro é usado para filtrar o `tipo` de erro que queremos chamando `errors.where(:attr, :type)`.

```irb
irb> person = Person.new
irb> person.valid?
=> false

irb> person.errors.where(:name)
=> [ ... ] # todos os erros para o atributo :name

irb> person.errors.where(:name, :too_short)
=> [ ... ] # erros :too_short para o atributo :name
```

Por último, podemos filtrar por quaisquer `opções` que possam existir no tipo de objeto de erro fornecido.

```irb
irb> person = Person.new
irb> person.valid?
=> false

irb> person.errors.where(:name, :too_short, minimum: 3)
=> [ ... ] # todos os erros de nome sendo muito curtos e o mínimo é 2
```

Você pode ler várias informações desses objetos de erro:

```irb
irb> error = person.errors.where(:name).last

irb> error.attribute
=> :name
irb> error.type
=> :too_short
irb> error.options[:count]
=> 3
```

Você também pode gerar a mensagem de erro:

```irb
irb> error.message
=> "é muito curto (mínimo: 3 caracteres)"
irb> error.full_message
=> "Name é muito curto (mínimo: 3 caracteres)"
```

O método [`full_message`][] gera uma mensagem mais amigável ao usuário, com o nome do atributo em maiúscula anteposto. (Para personalizar o formato que `full_message` usa, consulte o [guia I18n](i18n.html#active-model-methods).)


### `errors.add`

O método [`add`][] cria o objeto de erro ao receber o `atributo`, o `tipo` de erro e um hash de opções adicionais. Isso é útil ao escrever seu próprio validador, pois permite definir situações de erro muito específicas.

```ruby
class Person < ApplicationRecord
  validate do |person|
    errors.add :name, :too_plain, message: "não é legal o suficiente"
  end
end
```
```irb
irb> person = Person.create
irb> person.errors.where(:name).first.type
=> :too_plain
irb> person.errors.where(:name).first.full_message
=> "O nome não é legal o suficiente"
```


### `errors[:base]`

Você pode adicionar erros que estão relacionados ao estado do objeto como um todo, em vez de
estar relacionado a um atributo específico. Para fazer isso, você deve usar `:base` como o
atributo ao adicionar um novo erro.

```ruby
class Person < ApplicationRecord
  validate do |person|
    errors.add :base, :invalid, message: "Essa pessoa é inválida porque ..."
  end
end
```

```irb
irb> person = Person.create
irb> person.errors.where(:base).first.full_message
=> "Essa pessoa é inválida porque ..."
```

### `errors.size`

O método `size` retorna o número total de erros para o objeto.

```ruby
class Person < ApplicationRecord
  validates :name, presence: true, length: { minimum: 3 }
end
```

```irb
irb> person = Person.new
irb> person.valid?
=> false
irb> person.errors.size
=> 2

irb> person = Person.new(name: "Andrea", email: "andrea@example.com")
irb> person.valid?
=> true
irb> person.errors.size
=> 0
```

### `errors.clear`

O método `clear` é usado quando você deseja limpar intencionalmente a coleção de `errors`.
Claro, chamar `errors.clear` em um objeto inválido não o tornará válido: a coleção de `errors` agora estará vazia, mas na próxima
vez que você chamar `valid?` ou qualquer método que tente salvar esse objeto no
banco de dados, as validações serão executadas novamente. Se alguma das validações falhar, a
coleção de `errors` será preenchida novamente.

```ruby
class Person < ApplicationRecord
  validates :name, presence: true, length: { minimum: 3 }
end
```

```irb
irb> person = Person.new
irb> person.valid?
=> false
irb> person.errors.empty?
=> false

irb> person.errors.clear
irb> person.errors.empty?
=> true

irb> person.save
=> false

irb> person.errors.empty?
=> false
```

Exibindo Erros de Validação nas Views
-------------------------------------

Depois de criar um modelo e adicionar validações, se esse modelo for criado por meio de
um formulário da web, provavelmente você deseja exibir uma mensagem de erro quando uma das
validações falhar.

Como cada aplicativo lida com esse tipo de coisa de maneira diferente, o Rails não
inclui nenhum helper de visualização para ajudá-lo a gerar essas mensagens diretamente.
No entanto, devido ao grande número de métodos que o Rails oferece para interagir com
validações em geral, você pode construir o seu próprio. Além disso, ao
gerar um scaffold, o Rails colocará algum ERB no `_form.html.erb` que
ele gera que exibe a lista completa de erros nesse modelo.

Supondo que temos um modelo que foi salvo em uma variável de instância chamada
`@article`, ele se parece com isso:

```html+erb
<% if @article.errors.any? %>
  <div id="error_explanation">
    <h2><%= pluralize(@article.errors.count, "error") %> impediram que este artigo fosse salvo:</h2>

    <ul>
      <% @article.errors.each do |error| %>
        <li><%= error.full_message %></li>
      <% end %>
    </ul>
  </div>
<% end %>
```

Além disso, se você usar os helpers de formulário do Rails para gerar seus formulários, quando
ocorre um erro de validação em um campo, ele gerará um `<div>` extra em torno
da entrada.

```html
<div class="field_with_errors">
  <input id="article_title" name="article[title]" size="30" type="text" value="">
</div>
```

Você pode estilizar esse div da maneira que desejar. O scaffold padrão que
o Rails gera, por exemplo, adiciona essa regra CSS:

```css
.field_with_errors {
  padding: 2px;
  background-color: red;
  display: table;
}
```

Isso significa que qualquer campo com um erro terá uma borda vermelha de 2 pixels.
[`errors`]: https://api.rubyonrails.org/classes/ActiveModel/Validations.html#method-i-errors
[`invalid?`]: https://api.rubyonrails.org/classes/ActiveModel/Validations.html#method-i-invalid-3F
[`valid?`]: https://api.rubyonrails.org/classes/ActiveRecord/Validations.html#method-i-valid-3F
[Errors#squarebrackets]: https://api.rubyonrails.org/classes/ActiveModel/Errors.html#method-i-5B-5D
[`ActiveModel::Validations::HelperMethods`]: https://api.rubyonrails.org/classes/ActiveModel/Validations/HelperMethods.html
[`Object#blank?`]: https://api.rubyonrails.org/classes/Object.html#method-i-blank-3F
[`Object#present?`]: https://api.rubyonrails.org/classes/Object.html#method-i-present-3F
[`validates_uniqueness_of`]: https://api.rubyonrails.org/classes/ActiveRecord/Validations/ClassMethods.html#method-i-validates_uniqueness_of
[`add_index`]: https://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html#method-i-add_index
[`validates_associated`]: https://api.rubyonrails.org/classes/ActiveRecord/Validations/ClassMethods.html#method-i-validates_associated
[`validates_each`]: https://api.rubyonrails.org/classes/ActiveModel/Validations/ClassMethods.html#method-i-validates_each
[`validates_with`]: https://api.rubyonrails.org/classes/ActiveModel/Validations/ClassMethods.html#method-i-validates_with
[`ActiveModel::Validations`]: https://api.rubyonrails.org/classes/ActiveModel/Validations.html
[`with_options`]: https://api.rubyonrails.org/classes/Object.html#method-i-with_options
[`ActiveModel::EachValidator`]: https://api.rubyonrails.org/classes/ActiveModel/EachValidator.html
[`ActiveModel::Validator`]: https://api.rubyonrails.org/classes/ActiveModel/Validator.html
[`validate`]: https://api.rubyonrails.org/classes/ActiveModel/Validations/ClassMethods.html#method-i-validate
[`ActiveModel::Errors`]: https://api.rubyonrails.org/classes/ActiveModel/Errors.html
[`ActiveModel::Error`]: https://api.rubyonrails.org/classes/ActiveModel/Error.html
[`full_message`]: https://api.rubyonrails.org/classes/ActiveModel/Errors.html#method-i-full_message
[`where`]: https://api.rubyonrails.org/classes/ActiveModel/Errors.html#method-i-where
[`add`]: https://api.rubyonrails.org/classes/ActiveModel/Errors.html#method-i-add
