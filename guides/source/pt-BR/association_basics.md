**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 516604959485cfefb0e0d775d767699b
Associações do Active Record
=============================

Este guia aborda as funcionalidades de associação do Active Record.

Após ler este guia, você saberá como:

* Declarar associações entre modelos do Active Record.
* Entender os vários tipos de associações do Active Record.
* Utilizar os métodos adicionados aos seus modelos ao criar associações.

--------------------------------------------------------------------------------

Por que Associações?
--------------------

No Rails, uma _associação_ é uma conexão entre dois modelos do Active Record. Por que precisamos de associações entre modelos? Porque elas tornam operações comuns mais simples e fáceis no seu código.

Por exemplo, considere uma aplicação Rails simples que inclui um modelo para autores e um modelo para livros. Cada autor pode ter muitos livros.

Sem associações, as declarações dos modelos ficariam assim:

```ruby
class Author < ApplicationRecord
end

class Book < ApplicationRecord
end
```

Agora, suponha que quiséssemos adicionar um novo livro para um autor existente. Precisaríamos fazer algo assim:

```ruby
@book = Book.create(published_at: Time.now, author_id: @author.id)
```

Ou considere excluir um autor e garantir que todos os seus livros também sejam excluídos:

```ruby
@books = Book.where(author_id: @author.id)
@books.each do |book|
  book.destroy
end
@author.destroy
```

Com as associações do Active Record, podemos simplificar essas - e outras - operações, informando declarativamente ao Rails que há uma conexão entre os dois modelos. Aqui está o código revisado para configurar autores e livros:

```ruby
class Author < ApplicationRecord
  has_many :books, dependent: :destroy
end

class Book < ApplicationRecord
  belongs_to :author
end
```

Com essa mudança, criar um novo livro para um autor específico é mais fácil:

```ruby
@book = @author.books.create(published_at: Time.now)
```

Excluir um autor e todos os seus livros é *muito* mais fácil:

```ruby
@author.destroy
```

Para saber mais sobre os diferentes tipos de associações, leia a próxima seção deste guia. Em seguida, há algumas dicas e truques para trabalhar com associações, seguidas por uma referência completa aos métodos e opções para associações no Rails.

Os Tipos de Associações
-----------------------

O Rails suporta seis tipos de associações, cada um com um caso de uso específico em mente.

Aqui está uma lista de todos os tipos suportados com um link para a documentação da API para obter informações mais detalhadas sobre como usá-los, seus parâmetros de método, etc.

* [`belongs_to`][]
* [`has_one`][]
* [`has_many`][]
* [`has_many :through`][`has_many`]
* [`has_one :through`][`has_one`]
* [`has_and_belongs_to_many`][]

As associações são implementadas usando chamadas de estilo macro, para que você possa adicionar recursos declarativamente aos seus modelos. Por exemplo, ao declarar que um modelo `belongs_to` a outro, você instrui o Rails a manter informações de [Primary Key](https://en.wikipedia.org/wiki/Primary_key)-[Foreign Key](https://en.wikipedia.org/wiki/Foreign_key) entre instâncias dos dois modelos, e também obtém vários métodos utilitários adicionados ao seu modelo.

No restante deste guia, você aprenderá como declarar e usar as várias formas de associações. Mas primeiro, uma breve introdução às situações em que cada tipo de associação é apropriado.


### A Associação `belongs_to`

Uma associação [`belongs_to`][] estabelece uma conexão com outro modelo, de modo que cada instância do modelo declarante "pertence a" uma instância do outro modelo. Por exemplo, se sua aplicação incluir autores e livros, e cada livro puder ser atribuído a exatamente um autor, você declararia o modelo do livro desta forma:

```ruby
class Book < ApplicationRecord
  belongs_to :author
end
```

![Diagrama de Associação `belongs_to`](images/association_basics/belongs_to.png)

NOTA: As associações `belongs_to` _devem_ usar o termo singular. Se você usou a forma pluralizada no exemplo acima para a associação `author` no modelo `Book` e tentou criar a instância por `Book.create(authors: author)`, você receberia a mensagem de que havia uma "constante não inicializada Book::Authors". Isso ocorre porque o Rails automaticamente infere o nome da classe a partir do nome da associação. Se o nome da associação estiver erradamente pluralizado, então a classe inferida também estará erradamente pluralizada.

A migração correspondente pode ser assim:

```ruby
class CreateBooks < ActiveRecord::Migration[7.1]
  def change
    create_table :authors do |t|
      t.string :name
      t.timestamps
    end

    create_table :books do |t|
      t.belongs_to :author
      t.datetime :published_at
      t.timestamps
    end
  end
end
```

Quando usado sozinho, `belongs_to` produz uma conexão unidirecional um-para-um. Portanto, cada livro no exemplo acima "sabe" seu autor, mas os autores não sabem sobre seus livros.
Para configurar uma [associação bidirecional](#associações-bidirecionais) - use `belongs_to` em combinação com um `has_one` ou `has_many` no outro modelo, neste caso o modelo Author.

`belongs_to` não garante consistência de referência se `optional` for definido como true, então, dependendo do caso de uso, você também pode precisar adicionar uma restrição de chave estrangeira no nível do banco de dados na coluna de referência, assim:
```ruby
create_table :books do |t|
  t.belongs_to :author, foreign_key: true
  # ...
end
```

### A Associação `has_one`

Uma associação [`has_one`][] indica que outro modelo possui uma referência a este modelo. Esse modelo pode ser recuperado por meio dessa associação.

Por exemplo, se cada fornecedor em sua aplicação tiver apenas uma conta, você declararia o modelo de fornecedor assim:

```ruby
class Supplier < ApplicationRecord
  has_one :account
end
```

A principal diferença do `belongs_to` é que a coluna de link `supplier_id` está localizada na outra tabela:

![Diagrama da Associação has_one](images/association_basics/has_one.png)

A migração correspondente pode ser assim:

```ruby
class CreateSuppliers < ActiveRecord::Migration[7.1]
  def change
    create_table :suppliers do |t|
      t.string :name
      t.timestamps
    end

    create_table :accounts do |t|
      t.belongs_to :supplier
      t.string :account_number
      t.timestamps
    end
  end
end
```

Dependendo do caso de uso, você também pode precisar criar um índice único e/ou uma restrição de chave estrangeira na coluna de fornecedor para a tabela de contas. Nesse caso, a definição da coluna pode ser assim:

```ruby
create_table :accounts do |t|
  t.belongs_to :supplier, index: { unique: true }, foreign_key: true
  # ...
end
```

Essa relação pode ser [bidirecional](#associações-bidirecionais) quando usada em combinação com `belongs_to` no outro modelo.

### A Associação `has_many`

Uma associação [`has_many`][] é semelhante a `has_one`, mas indica uma conexão um-para-muitos com outro modelo. Você frequentemente encontrará essa associação no "outro lado" de uma associação `belongs_to`. Essa associação indica que cada instância do modelo possui zero ou mais instâncias de outro modelo. Por exemplo, em uma aplicação contendo autores e livros, o modelo de autor poderia ser declarado assim:

```ruby
class Author < ApplicationRecord
  has_many :books
end
```

NOTA: O nome do outro modelo é pluralizado ao declarar uma associação `has_many`.

![Diagrama da Associação has_many](images/association_basics/has_many.png)

A migração correspondente pode ser assim:

```ruby
class CreateAuthors < ActiveRecord::Migration[7.1]
  def change
    create_table :authors do |t|
      t.string :name
      t.timestamps
    end

    create_table :books do |t|
      t.belongs_to :author
      t.datetime :published_at
      t.timestamps
    end
  end
end
```

Dependendo do caso de uso, geralmente é uma boa ideia criar um índice não único e, opcionalmente, uma restrição de chave estrangeira na coluna de autor para a tabela de livros:

```ruby
create_table :books do |t|
  t.belongs_to :author, index: true, foreign_key: true
  # ...
end
```

### A Associação `has_many :through`

Uma associação [`has_many :through`][`has_many`] é frequentemente usada para estabelecer uma conexão muitos-para-muitos com outro modelo. Essa associação indica que o modelo declarante pode ser correspondido com zero ou mais instâncias de outro modelo, passando _por meio_ de um terceiro modelo. Por exemplo, considere uma clínica médica onde os pacientes marcam consultas para ver médicos. As declarações de associação relevantes podem ser assim:

```ruby
class Physician < ApplicationRecord
  has_many :appointments
  has_many :patients, through: :appointments
end

class Appointment < ApplicationRecord
  belongs_to :physician
  belongs_to :patient
end

class Patient < ApplicationRecord
  has_many :appointments
  has_many :physicians, through: :appointments
end
```

![Diagrama da Associação has_many :through](images/association_basics/has_many_through.png)

A migração correspondente pode ser assim:

```ruby
class CreateAppointments < ActiveRecord::Migration[7.1]
  def change
    create_table :physicians do |t|
      t.string :name
      t.timestamps
    end

    create_table :patients do |t|
      t.string :name
      t.timestamps
    end

    create_table :appointments do |t|
      t.belongs_to :physician
      t.belongs_to :patient
      t.datetime :appointment_date
      t.timestamps
    end
  end
end
```

A coleção de modelos de junção pode ser gerenciada por meio dos [métodos de associação `has_many`](#referência-de-associação-has-many).
Por exemplo, se você atribuir:

```ruby
physician.patients = patients
```

Então, novos modelos de junção são criados automaticamente para os objetos recém-associados.
Se alguns que existiam anteriormente agora estão faltando, suas linhas de junção são excluídas automaticamente.

ATENÇÃO: A exclusão automática de modelos de junção é direta, nenhum callback de destruição é acionado.

A associação `has_many :through` também é útil para configurar "atalhos" por meio de associações `has_many` aninhadas. Por exemplo, se um documento tiver muitas seções e uma seção tiver muitos parágrafos, às vezes você pode querer obter uma coleção simples de todos os parágrafos no documento. Você pode configurar dessa maneira:

```ruby
class Document < ApplicationRecord
  has_many :sections
  has_many :paragraphs, through: :sections
end

class Section < ApplicationRecord
  belongs_to :document
  has_many :paragraphs
end

class Paragraph < ApplicationRecord
  belongs_to :section
end
```

Com `through: :sections` especificado, o Rails agora entenderá:

```ruby
@document.paragraphs
```

### A Associação `has_one :through`

Uma associação [`has_one :through`][`has_one`] estabelece uma conexão um-para-um com outro modelo. Essa associação indica
que o modelo declarante pode ser correspondido com uma instância de outro modelo, passando _por meio_ de um terceiro modelo.
Por exemplo, se cada fornecedor tiver uma conta e cada conta estiver associada a um histórico de conta, então o
modelo de fornecedor poderia ser assim:
```ruby
class Supplier < ApplicationRecord
  has_one :account
  has_one :account_history, through: :account
end

class Account < ApplicationRecord
  belongs_to :supplier
  has_one :account_history
end

class AccountHistory < ApplicationRecord
  belongs_to :account
end
```

![has_one :through Association Diagram](images/association_basics/has_one_through.png)

A migração correspondente pode ser assim:

```ruby
class CreateAccountHistories < ActiveRecord::Migration[7.1]
  def change
    create_table :suppliers do |t|
      t.string :name
      t.timestamps
    end

    create_table :accounts do |t|
      t.belongs_to :supplier
      t.string :account_number
      t.timestamps
    end

    create_table :account_histories do |t|
      t.belongs_to :account
      t.integer :credit_rating
      t.timestamps
    end
  end
end
```

### A Associação `has_and_belongs_to_many`

Uma associação [`has_and_belongs_to_many`][] cria uma conexão direta muitos-para-muitos com outro modelo, sem um modelo intermediário.
Essa associação indica que cada instância do modelo declarante se refere a zero ou mais instâncias de outro modelo.
Por exemplo, se o seu aplicativo inclui montagens e peças, com cada montagem tendo muitas peças e cada peça aparecendo em muitas montagens, você pode declarar os modelos desta forma:

```ruby
class Assembly < ApplicationRecord
  has_and_belongs_to_many :parts
end

class Part < ApplicationRecord
  has_and_belongs_to_many :assemblies
end
```

![has_and_belongs_to_many Association Diagram](images/association_basics/habtm.png)

A migração correspondente pode ser assim:

```ruby
class CreateAssembliesAndParts < ActiveRecord::Migration[7.1]
  def change
    create_table :assemblies do |t|
      t.string :name
      t.timestamps
    end

    create_table :parts do |t|
      t.string :part_number
      t.timestamps
    end

    create_table :assemblies_parts, id: false do |t|
      t.belongs_to :assembly
      t.belongs_to :part
    end
  end
end
```

### Escolhendo entre `belongs_to` e `has_one`

Se você deseja configurar um relacionamento um-para-um entre dois modelos, você precisará adicionar `belongs_to` a um e `has_one` ao outro. Como saber qual é qual?

A distinção está em onde você coloca a chave estrangeira (ela vai na tabela para a classe que declara a associação `belongs_to`), mas você também deve pensar no significado real dos dados. O relacionamento `has_one` diz que um de algo é seu - ou seja, que algo aponta de volta para você. Por exemplo, faz mais sentido dizer que um fornecedor possui uma conta do que uma conta possui um fornecedor. Isso sugere que os relacionamentos corretos são assim:

```ruby
class Supplier < ApplicationRecord
  has_one :account
end

class Account < ApplicationRecord
  belongs_to :supplier
end
```

A migração correspondente pode ser assim:

```ruby
class CreateSuppliers < ActiveRecord::Migration[7.1]
  def change
    create_table :suppliers do |t|
      t.string :name
      t.timestamps
    end

    create_table :accounts do |t|
      t.bigint  :supplier_id
      t.string  :account_number
      t.timestamps
    end

    add_index :accounts, :supplier_id
  end
end
```

NOTA: Usar `t.bigint :supplier_id` deixa o nome da chave estrangeira óbvio e explícito. Nas versões atuais do Rails, você pode abstrair esse detalhe de implementação usando `t.references :supplier` em vez disso.

### Escolhendo entre `has_many :through` e `has_and_belongs_to_many`

O Rails oferece duas maneiras diferentes de declarar um relacionamento muitos-para-muitos entre modelos. A primeira maneira é usar `has_and_belongs_to_many`, que permite fazer a associação diretamente:

```ruby
class Assembly < ApplicationRecord
  has_and_belongs_to_many :parts
end

class Part < ApplicationRecord
  has_and_belongs_to_many :assemblies
end
```

A segunda maneira de declarar um relacionamento muitos-para-muitos é usar `has_many :through`. Isso faz a associação indiretamente, por meio de um modelo de junção:

```ruby
class Assembly < ApplicationRecord
  has_many :manifests
  has_many :parts, through: :manifests
end

class Manifest < ApplicationRecord
  belongs_to :assembly
  belongs_to :part
end

class Part < ApplicationRecord
  has_many :manifests
  has_many :assemblies, through: :manifests
end
```

A regra mais simples é que você deve configurar um relacionamento `has_many :through` se precisar trabalhar com o modelo de relacionamento como uma entidade independente. Se você não precisa fazer nada com o modelo de relacionamento, pode ser mais simples configurar um relacionamento `has_and_belongs_to_many` (embora você precise lembrar de criar a tabela de junção no banco de dados).

Você deve usar `has_many :through` se precisar de validações, callbacks ou atributos extras no modelo de junção.

### Associações Polimórficas

Uma variação um pouco mais avançada das associações é a _associação polimórfica_. Com associações polimórficas, um modelo pode pertencer a mais de um outro modelo, em uma única associação. Por exemplo, você pode ter um modelo de imagem que pertence a um modelo de funcionário ou a um modelo de produto. Veja como isso pode ser declarado:

```ruby
class Picture < ApplicationRecord
  belongs_to :imageable, polymorphic: true
end

class Employee < ApplicationRecord
  has_many :pictures, as: :imageable
end

class Product < ApplicationRecord
  has_many :pictures, as: :imageable
end
```

Você pode pensar em uma declaração polimórfica `belongs_to` como configurando uma interface que qualquer outro modelo pode usar. A partir de uma instância do modelo `Employee`, você pode recuperar uma coleção de imagens: `@employee.pictures`.
```
Da mesma forma, você pode recuperar `@product.pictures`.

Se você tiver uma instância do modelo `Picture`, pode chegar ao seu pai através de `@picture.imageable`. Para fazer isso funcionar, você precisa declarar uma coluna de chave estrangeira e uma coluna de tipo no modelo que declara a interface polimórfica:

```ruby
class CreatePictures < ActiveRecord::Migration[7.1]
  def change
    create_table :pictures do |t|
      t.string  :name
      t.bigint  :imageable_id
      t.string  :imageable_type
      t.timestamps
    end

    add_index :pictures, [:imageable_type, :imageable_id]
  end
end
```

Essa migração pode ser simplificada usando a forma `t.references`:

```ruby
class CreatePictures < ActiveRecord::Migration[7.1]
  def change
    create_table :pictures do |t|
      t.string :name
      t.references :imageable, polymorphic: true
      t.timestamps
    end
  end
end
```

![Diagrama de Associação Polimórfica](images/association_basics/polymorphic.png)

### Auto Junções

Ao projetar um modelo de dados, às vezes você encontrará um modelo que deve ter uma relação consigo mesmo. Por exemplo, você pode querer armazenar todos os funcionários em um único modelo de banco de dados, mas ser capaz de rastrear relacionamentos como entre gerente e subordinados. Essa situação pode ser modelada com associações de auto junção:

```ruby
class Employee < ApplicationRecord
  has_many :subordinates, class_name: "Employee",
                          foreign_key: "manager_id"

  belongs_to :manager, class_name: "Employee", optional: true
end
```

Com essa configuração, você pode recuperar `@employee.subordinates` e `@employee.manager`.

Em suas migrações/esquema, você adicionará uma coluna de referências ao próprio modelo.

```ruby
class CreateEmployees < ActiveRecord::Migration[7.1]
  def change
    create_table :employees do |t|
      t.references :manager, foreign_key: { to_table: :employees }
      t.timestamps
    end
  end
end
```

NOTA: A opção `to_table` passada para `foreign_key` e outras são explicadas em [`SchemaStatements#add_reference`][connection.add_reference].


Dicas, Truques e Avisos
--------------------------

Aqui estão algumas coisas que você deve saber para fazer uso eficiente das associações do Active Record em suas aplicações Rails:

* Controlando o cache
* Evitando colisões de nomes
* Atualizando o esquema
* Controlando o escopo da associação
* Associações bidirecionais

### Controlando o Cache

Todos os métodos de associação são construídos em torno do cache, que mantém o resultado da consulta mais recente disponível para outras operações. O cache é até compartilhado entre os métodos. Por exemplo:

```ruby
# recupera livros do banco de dados
author.books.load

# usa a cópia em cache dos livros
author.books.size

# usa a cópia em cache dos livros
author.books.empty?
```

Mas e se você quiser recarregar o cache, porque os dados podem ter sido alterados por outra parte da aplicação? Basta chamar `reload` na associação:

```ruby
# recupera livros do banco de dados
author.books.load

# usa a cópia em cache dos livros
author.books.size

# descarta a cópia em cache dos livros e volta ao banco de dados
author.books.reload.empty?
```

### Evitando Colisões de Nomes

Você não está livre para usar qualquer nome para suas associações. Porque criar uma associação adiciona um método com esse nome ao modelo, é uma má ideia dar a uma associação um nome que já é usado para um método de instância de `ActiveRecord::Base`. O método de associação substituiria o método base e causaria problemas. Por exemplo, `attributes` ou `connection` são nomes ruins para associações.

### Atualizando o Esquema

As associações são extremamente úteis, mas não são mágicas. Você é responsável por manter o esquema do seu banco de dados para corresponder às suas associações. Na prática, isso significa duas coisas, dependendo do tipo de associações que você está criando. Para associações `belongs_to`, você precisa criar chaves estrangeiras, e para associações `has_and_belongs_to_many`, você precisa criar a tabela de junção apropriada.

#### Criando Chaves Estrangeiras para Associações `belongs_to`

Quando você declara uma associação `belongs_to`, precisa criar chaves estrangeiras conforme apropriado. Por exemplo, considere este modelo:

```ruby
class Book < ApplicationRecord
  belongs_to :author
end
```

Essa declaração precisa ser suportada por uma coluna de chave estrangeira correspondente na tabela de livros. Para uma tabela completamente nova, a migração pode ser algo assim:

```ruby
class CreateBooks < ActiveRecord::Migration[7.1]
  def change
    create_table :books do |t|
      t.datetime   :published_at
      t.string     :book_number
      t.references :author
    end
  end
end
```

Enquanto para uma tabela existente, pode ser assim:

```ruby
class AddAuthorToBooks < ActiveRecord::Migration[7.1]
  def change
    add_reference :books, :author
  end
end
```

NOTA: Se você deseja [garantir a integridade referencial no nível do banco de dados][foreign_keys], adicione a opção `foreign_key: true` às declarações de coluna 'reference' acima.


#### Criando Tabelas de Junção para Associações `has_and_belongs_to_many`

Se você criar uma associação `has_and_belongs_to_many`, precisará criar explicitamente a tabela de junção. A menos que o nome da tabela de junção seja especificado explicitamente usando a opção `:join_table`, o Active Record cria o nome usando a ordem lexical dos nomes das classes. Portanto, uma junção entre os modelos de autor e livro dará o nome padrão da tabela de junção de "authors_books" porque "a" tem precedência sobre "b" na ordenação lexical.
AVISO: A precedência entre os nomes dos modelos é calculada usando o operador `<=>` para `String`. Isso significa que, se as strings tiverem comprimentos diferentes e as strings forem iguais quando comparadas até o comprimento mais curto, a string mais longa será considerada de maior precedência léxica do que a mais curta. Por exemplo, espera-se que as tabelas "paper_boxes" e "papers" gerem um nome de tabela de junção "papers_paper_boxes" por causa do comprimento do nome "paper_boxes", mas na verdade gera um nome de tabela de junção "paper_boxes_papers" (porque o sublinhado '\_' é lexicograficamente _menor_ que 's' em codificações comuns).

Independentemente do nome, você deve gerar manualmente a tabela de junção com uma migração apropriada. Por exemplo, considere essas associações:

```ruby
class Assembly < ApplicationRecord
  has_and_belongs_to_many :parts
end

class Part < ApplicationRecord
  has_and_belongs_to_many :assemblies
end
```

Essas associações devem ser suportadas por uma migração para criar a tabela `assemblies_parts`. Essa tabela deve ser criada sem uma chave primária:

```ruby
class CreateAssembliesPartsJoinTable < ActiveRecord::Migration[7.1]
  def change
    create_table :assemblies_parts, id: false do |t|
      t.bigint :assembly_id
      t.bigint :part_id
    end

    add_index :assemblies_parts, :assembly_id
    add_index :assemblies_parts, :part_id
  end
end
```

Passamos `id: false` para `create_table` porque essa tabela não representa um modelo. Isso é necessário para que a associação funcione corretamente. Se você observar algum comportamento estranho em uma associação `has_and_belongs_to_many`, como IDs de modelo corrompidos ou exceções sobre IDs conflitantes, é provável que você tenha esquecido dessa parte.

Para simplificar, você também pode usar o método `create_join_table`:

```ruby
class CreateAssembliesPartsJoinTable < ActiveRecord::Migration[7.1]
  def change
    create_join_table :assemblies, :parts do |t|
      t.index :assembly_id
      t.index :part_id
    end
  end
end
```

### Controlando o Escopo da Associação

Por padrão, as associações procuram objetos apenas no escopo do módulo atual. Isso pode ser importante quando você declara modelos Active Record dentro de um módulo. Por exemplo:

```ruby
module MyApplication
  module Business
    class Supplier < ApplicationRecord
      has_one :account
    end

    class Account < ApplicationRecord
      belongs_to :supplier
    end
  end
end
```

Isso funcionará bem, porque tanto a classe `Supplier` quanto a classe `Account` são definidas no mesmo escopo. Mas o seguinte _não_ funcionará, porque `Supplier` e `Account` são definidos em escopos diferentes:

```ruby
module MyApplication
  module Business
    class Supplier < ApplicationRecord
      has_one :account
    end
  end

  module Billing
    class Account < ApplicationRecord
      belongs_to :supplier
    end
  end
end
```

Para associar um modelo a um modelo em um namespace diferente, você deve especificar o nome completo da classe em sua declaração de associação:

```ruby
module MyApplication
  module Business
    class Supplier < ApplicationRecord
      has_one :account,
        class_name: "MyApplication::Billing::Account"
    end
  end

  module Billing
    class Account < ApplicationRecord
      belongs_to :supplier,
        class_name: "MyApplication::Business::Supplier"
    end
  end
end
```

### Associações Bidirecionais

É normal que as associações funcionem em duas direções, exigindo declaração em dois modelos diferentes:

```ruby
class Author < ApplicationRecord
  has_many :books
end

class Book < ApplicationRecord
  belongs_to :author
end
```

O Active Record tentará identificar automaticamente que esses dois modelos compartilham uma associação bidirecional com base no nome da associação. Essa informação permite que o Active Record:

* Evite consultas desnecessárias para dados já carregados:

    ```irb
    irb> author = Author.first
    irb> author.books.all? do |book|
    irb>   book.author.equal?(author) # Nenhuma consulta adicional executada aqui
    irb> end
    => true
    ```

* Evite dados inconsistentes (já que há apenas uma cópia do objeto `Author` carregado):

    ```irb
    irb> author = Author.first
    irb> book = author.books.first
    irb> author.name == book.author.name
    => true
    irb> author.name = "Nome Alterado"
    irb> author.name == book.author.name
    => true
    ```

* Salve automaticamente as associações em mais casos:

    ```irb
    irb> author = Author.new
    irb> book = author.books.new
    irb> book.save!
    irb> book.persisted?
    => true
    irb> author.persisted?
    => true
    ```

* Valide a [presença](active_record_validations.html#presence) e [ausência](active_record_validations.html#absence) de associações em mais casos:

    ```irb
    irb> book = Book.new
    irb> book.valid?
    => false
    irb> book.errors.full_messages
    => ["Author must exist"]
    irb> author = Author.new
    irb> book = author.books.new
    irb> book.valid?
    => true
    ```

O Active Record oferece suporte à identificação automática da maioria das associações com nomes padrão. No entanto, associações bidirecionais que contêm as opções `:through` ou `:foreign_key` não serão identificadas automaticamente.

Escopos personalizados na associação oposta também impedem a identificação automática, assim como escopos personalizados na própria associação, a menos que [`config.active_record.automatic_scope_inversing`][] esteja definido como true (o padrão para novas aplicações).

Por exemplo, considere as seguintes declarações de modelo:

```ruby
class Author < ApplicationRecord
  has_many :books
end

class Book < ApplicationRecord
  belongs_to :writer, class_name: 'Author', foreign_key: 'author_id'
end
```

Devido à opção `:foreign_key`, o Active Record não reconhecerá mais automaticamente a associação bidirecional. Isso pode fazer com que sua aplicação:
* Executar consultas desnecessárias para os mesmos dados (neste exemplo, causando consultas N+1):

    ```irb
    irb> author = Author.first
    irb> author.books.any? do |book|
    irb>   book.author.equal?(author) # Isso executa uma consulta de autor para cada livro
    irb> end
    => false
    ```

* Referenciar várias cópias de um modelo com dados inconsistentes:

    ```irb
    irb> author = Author.first
    irb> book = author.books.first
    irb> author.name == book.author.name
    => true
    irb> author.name = "Nome Alterado"
    irb> author.name == book.author.name
    => false
    ```

* Falhar ao salvar automaticamente as associações:

    ```irb
    irb> author = Author.new
    irb> book = author.books.new
    irb> book.save!
    irb> book.persisted?
    => true
    irb> author.persisted?
    => false
    ```

* Falhar ao validar a presença ou ausência:

    ```irb
    irb> author = Author.new
    irb> book = author.books.new
    irb> book.valid?
    => false
    irb> book.errors.full_messages
    => ["Author must exist"]
    ```

O Active Record fornece a opção `:inverse_of` para que você possa declarar explicitamente associações bidirecionais:

```ruby
class Author < ApplicationRecord
  has_many :books, inverse_of: 'writer'
end

class Book < ApplicationRecord
  belongs_to :writer, class_name: 'Author', foreign_key: 'author_id'
end
```

Ao incluir a opção `:inverse_of` na declaração da associação `has_many`,
o Active Record agora reconhecerá a associação bidirecional e se comportará como nos exemplos iniciais acima.


Referência Detalhada de Associação
------------------------------

As seções a seguir fornecem os detalhes de cada tipo de associação, incluindo os métodos que eles adicionam e as opções que você pode usar ao declarar uma associação.

### Referência de Associação `belongs_to`

Em termos de banco de dados, a associação `belongs_to` indica que a tabela deste modelo contém uma coluna que representa uma referência a outra tabela.
Isso pode ser usado para configurar relações um-para-um ou um-para-muitos, dependendo da configuração.
Se a tabela da outra classe contiver a referência em uma relação um-para-um, você deve usar `has_one` em vez disso.

#### Métodos Adicionados por `belongs_to`

Ao declarar uma associação `belongs_to`, a classe declarante automaticamente ganha 8 métodos relacionados à associação:

* `association`
* `association=(associate)`
* `build_association(attributes = {})`
* `create_association(attributes = {})`
* `create_association!(attributes = {})`
* `reload_association`
* `reset_association`
* `association_changed?`
* `association_previously_changed?`

Em todos esses métodos, `association` é substituído pelo símbolo passado como primeiro argumento para `belongs_to`. Por exemplo, dada a declaração:

```ruby
class Book < ApplicationRecord
  belongs_to :author
end
```

Cada instância do modelo `Book` terá esses métodos:

* `author`
* `author=`
* `build_author`
* `create_author`
* `create_author!`
* `reload_author`
* `reset_author`
* `author_changed?`
* `author_previously_changed?`

NOTA: Ao inicializar uma nova associação `has_one` ou `belongs_to`, você deve usar o prefixo `build_` para criar a associação, em vez do método `association.build` que seria usado para associações `has_many` ou `has_and_belongs_to_many`. Para criar uma, use o prefixo `create_`.

##### `association`

O método `association` retorna o objeto associado, se houver. Se nenhum objeto associado for encontrado, ele retorna `nil`.

```ruby
@author = @book.author
```

Se o objeto associado já tiver sido recuperado do banco de dados para este objeto, a versão em cache será retornada. Para substituir esse comportamento (e forçar uma leitura do banco de dados), chame `#reload_association` no objeto pai.

```ruby
@author = @book.reload_author
```

Para descarregar a versão em cache do objeto associado - fazendo com que o próximo acesso, se houver, o consulte no banco de dados - chame `#reset_association` no objeto pai.

```ruby
@book.reset_author
```

##### `association=(associate)`

O método `association=` atribui um objeto associado a este objeto. Nos bastidores, isso significa extrair a chave primária do objeto associado e definir a chave estrangeira deste objeto com o mesmo valor.

```ruby
@book.author = @author
```

##### `build_association(attributes = {})`

O método `build_association` retorna um novo objeto do tipo associado. Este objeto será instanciado a partir dos atributos passados, e o link através da chave estrangeira deste objeto será definido, mas o objeto associado _não_ será salvo ainda.

```ruby
@author = @book.build_author(author_number: 123,
                             author_name: "John Doe")
```

##### `create_association(attributes = {})`

O método `create_association` retorna um novo objeto do tipo associado. Este objeto será instanciado a partir dos atributos passados, o link através da chave estrangeira deste objeto será definido e, uma vez que ele passar por todas as validações especificadas no modelo associado, o objeto associado _será_ salvo.

```ruby
@author = @book.create_author(author_number: 123,
                              author_name: "John Doe")
```

##### `create_association!(attributes = {})`

Faz o mesmo que `create_association` acima, mas gera uma exceção `ActiveRecord::RecordInvalid` se o registro for inválido.

##### `association_changed?`

O método `association_changed?` retorna true se um novo objeto associado tiver sido atribuído e a chave estrangeira será atualizada na próxima vez que for salvo.
```ruby
@book.author # => #<Author author_number: 123, author_name: "John Doe">
@book.author_changed? # => false

@book.author = Author.second # => #<Author author_number: 456, author_name: "Jane Smith">
@book.author_changed? # => true

@book.save!
@book.author_changed? # => false
```

##### `association_previously_changed?`

O método `association_previously_changed?` retorna true se a alteração anterior atualizou a associação para referenciar um novo objeto associado.

```ruby
@book.author # => #<Author author_number: 123, author_name: "John Doe">
@book.author_previously_changed? # => false

@book.author = Author.second # => #<Author author_number: 456, author_name: "Jane Smith">
@book.save!
@book.author_previously_changed? # => true
```

#### Opções para `belongs_to`

Embora o Rails use valores padrão inteligentes que funcionam bem na maioria das situações, pode haver momentos em que você deseja personalizar o comportamento da referência da associação `belongs_to`. Essas personalizações podem ser facilmente feitas passando opções e blocos de escopo ao criar a associação. Por exemplo, esta associação usa duas opções:

```ruby
class Book < ApplicationRecord
  belongs_to :author, touch: :books_updated_at,
    counter_cache: true
end
```

A associação [`belongs_to`][] suporta essas opções:

* `:autosave`
* `:class_name`
* `:counter_cache`
* `:dependent`
* `:foreign_key`
* `:primary_key`
* `:inverse_of`
* `:polymorphic`
* `:touch`
* `:validate`
* `:optional`

##### `:autosave`

Se você definir a opção `:autosave` como `true`, o Rails salvará todos os membros da associação carregados e destruirá os membros marcados para destruição sempre que você salvar o objeto pai. Definir `:autosave` como `false` não é o mesmo que não definir a opção `:autosave`. Se a opção `:autosave` não estiver presente, então novos objetos associados serão salvos, mas objetos associados atualizados não serão salvos.

##### `:class_name`

Se o nome do outro modelo não puder ser derivado do nome da associação, você pode usar a opção `:class_name` para fornecer o nome do modelo. Por exemplo, se um livro pertence a um autor, mas o nome real do modelo que contém autores é `Patron`, você configuraria as coisas desta maneira:

```ruby
class Book < ApplicationRecord
  belongs_to :author, class_name: "Patron"
end
```

##### `:counter_cache`

A opção `:counter_cache` pode ser usada para tornar a busca pelo número de objetos associados mais eficiente. Considere estes modelos:

```ruby
class Book < ApplicationRecord
  belongs_to :author
end

class Author < ApplicationRecord
  has_many :books
end
```

Com essas declarações, solicitar o valor de `@author.books.size` requer fazer uma chamada ao banco de dados para executar uma consulta `COUNT(*)`. Para evitar essa chamada, você pode adicionar um contador de cache ao modelo _pertencente_:

```ruby
class Book < ApplicationRecord
  belongs_to :author, counter_cache: true
end

class Author < ApplicationRecord
  has_many :books
end
```

Com essa declaração, o Rails manterá o valor do cache atualizado e retornará esse valor em resposta ao método `size`.

Embora a opção `:counter_cache` seja especificada no modelo que inclui a declaração `belongs_to`, a coluna real deve ser adicionada ao modelo _associado_ (`has_many`). No caso acima, você precisaria adicionar uma coluna chamada `books_count` ao modelo `Author`.

Você pode substituir o nome da coluna padrão especificando um nome de coluna personalizado na declaração `counter_cache` em vez de `true`. Por exemplo, para usar `count_of_books` em vez de `books_count`:

```ruby
class Book < ApplicationRecord
  belongs_to :author, counter_cache: :count_of_books
end

class Author < ApplicationRecord
  has_many :books
end
```

NOTA: Você só precisa especificar a opção `:counter_cache` no lado `belongs_to` da associação.

As colunas de contador de cache são adicionadas à lista de atributos somente leitura do modelo proprietário por meio de `attr_readonly`.

Se por algum motivo você alterar o valor da chave primária de um modelo proprietário e não atualizar também as chaves estrangeiras dos modelos contados, o contador de cache poderá ter dados obsoletos. Em outras palavras, quaisquer modelos órfãos ainda contarão para o contador. Para corrigir um contador de cache obsoleto, use [`reset_counters`][].


##### `:dependent`

Se você definir a opção `:dependent` como:

* `:destroy`, quando o objeto é destruído, `destroy` será chamado em seus objetos associados.
* `:delete`, quando o objeto é destruído, todos os seus objetos associados serão excluídos diretamente do banco de dados sem chamar seu método `destroy`.
* `:destroy_async`: quando o objeto é destruído, um job `ActiveRecord::DestroyAssociationAsyncJob` é enfileirado, que chamará destroy em seus objetos associados. O Active Job deve estar configurado para que isso funcione. Não use essa opção se a associação for suportada por restrições de chave estrangeira em seu banco de dados. As ações de restrição de chave estrangeira ocorrerão dentro da mesma transação que exclui seu proprietário.
AVISO: Você não deve especificar essa opção em uma associação `belongs_to` que está conectada a uma associação `has_many` na outra classe. Fazer isso pode resultar em registros órfãos no seu banco de dados.

##### `:foreign_key`

Por convenção, o Rails assume que a coluna usada para armazenar a chave estrangeira neste modelo é o nome da associação com o sufixo `_id` adicionado. A opção `:foreign_key` permite que você defina o nome da chave estrangeira diretamente:

```ruby
class Book < ApplicationRecord
  belongs_to :author, class_name: "Patron",
                      foreign_key: "patron_id"
end
```

DICA: Em qualquer caso, o Rails não criará colunas de chave estrangeira para você. Você precisa defini-las explicitamente como parte das suas migrações.

##### `:primary_key`

Por convenção, o Rails assume que a coluna `id` é usada para armazenar a chave primária das suas tabelas. A opção `:primary_key` permite que você especifique uma coluna diferente.

Por exemplo, suponha que você tenha uma tabela `users` com `guid` como chave primária. Se você quiser uma tabela separada `todos` para armazenar a chave estrangeira `user_id` na coluna `guid`, você pode usar `primary_key` para fazer isso da seguinte maneira:

```ruby
class User < ApplicationRecord
  self.primary_key = 'guid' # a chave primária é guid e não id
end

class Todo < ApplicationRecord
  belongs_to :user, primary_key: 'guid'
end
```

Quando executamos `@user.todos.create`, o registro `@todo` terá o valor `user_id` como o valor `guid` de `@user`.

##### `:inverse_of`

A opção `:inverse_of` especifica o nome da associação `has_many` ou `has_one` que é o inverso dessa associação. Consulte a seção [associação bidirecional](#associações-bidirecionais) para mais detalhes.

```ruby
class Author < ApplicationRecord
  has_many :books, inverse_of: :author
end

class Book < ApplicationRecord
  belongs_to :author, inverse_of: :books
end
```

##### `:polymorphic`

Passar `true` para a opção `:polymorphic` indica que esta é uma associação polimórfica. As associações polimórficas foram discutidas em detalhes <a href="#associações-polimórficas">anteriormente neste guia</a>.

##### `:touch`

Se você definir a opção `:touch` como `true`, o timestamp `updated_at` ou `updated_on` no objeto associado será definido como o horário atual sempre que esse objeto for salvo ou destruído:

```ruby
class Book < ApplicationRecord
  belongs_to :author, touch: true
end

class Author < ApplicationRecord
  has_many :books
end
```

Nesse caso, salvar ou destruir um livro atualizará o timestamp no autor associado. Você também pode especificar um atributo de timestamp específico para atualizar:

```ruby
class Book < ApplicationRecord
  belongs_to :author, touch: :books_updated_at
end
```

##### `:validate`

Se você definir a opção `:validate` como `true`, novos objetos associados serão validados sempre que você salvar esse objeto. Por padrão, isso é `false`: novos objetos associados não serão validados quando esse objeto for salvo.

##### `:optional`

Se você definir a opção `:optional` como `true`, a presença do objeto associado não será validada. Por padrão, essa opção é definida como `false`.

#### Escopos para `belongs_to`

Pode haver momentos em que você deseja personalizar a consulta usada pelo `belongs_to`. Essas personalizações podem ser feitas por meio de um bloco de escopo. Por exemplo:

```ruby
class Book < ApplicationRecord
  belongs_to :author, -> { where active: true }
end
```

Você pode usar qualquer um dos métodos de consulta padrão [mencionados aqui](active_record_querying.html) dentro do bloco de escopo. Os seguintes são discutidos abaixo:

* `where`
* `includes`
* `readonly`
* `select`

##### `where`

O método `where` permite que você especifique as condições que o objeto associado deve atender.

```ruby
class Book < ApplicationRecord
  belongs_to :author, -> { where active: true }
end
```

##### `includes`

Você pode usar o método `includes` para especificar associações de segunda ordem que devem ser carregadas antecipadamente quando essa associação for usada. Por exemplo, considere esses modelos:

```ruby
class Chapter < ApplicationRecord
  belongs_to :book
end

class Book < ApplicationRecord
  belongs_to :author
  has_many :chapters
end

class Author < ApplicationRecord
  has_many :books
end
```

Se você frequentemente recupera autores diretamente dos capítulos (`@chapter.book.author`), você pode tornar seu código um pouco mais eficiente incluindo autores na associação de capítulos para livros:

```ruby
class Chapter < ApplicationRecord
  belongs_to :book, -> { includes :author }
end

class Book < ApplicationRecord
  belongs_to :author
  has_many :chapters
end

class Author < ApplicationRecord
  has_many :books
end
```

NOTA: Não é necessário usar `includes` para associações imediatas - ou seja, se você tiver `Book belongs_to :author`, o autor será carregado antecipadamente automaticamente quando necessário.

##### `readonly`

Se você usar `readonly`, o objeto associado será somente leitura quando recuperado por meio da associação.
##### `select`

O método `select` permite substituir a cláusula SQL `SELECT` que é usada para recuperar dados sobre o objeto associado. Por padrão, o Rails recupera todas as colunas.

DICA: Se você usar o método `select` em uma associação `belongs_to`, você também deve definir a opção `:foreign_key` para garantir os resultados corretos.

#### Existem Objetos Associados?

Você pode verificar se existem objetos associados usando o método `association.nil?`:

```ruby
if @book.author.nil?
  @msg = "Nenhum autor encontrado para este livro"
end
```

#### Quando os Objetos são Salvos?

Atribuir um objeto a uma associação `belongs_to` _não_ salva automaticamente o objeto. Ele também não salva o objeto associado.

### Referência de Associação `has_one`

A associação `has_one` cria uma correspondência um-para-um com outro modelo. Em termos de banco de dados, essa associação indica que a outra classe contém a chave estrangeira. Se esta classe contém a chave estrangeira, então você deve usar `belongs_to` em vez disso.

#### Métodos Adicionados por `has_one`

Quando você declara uma associação `has_one`, a classe declarante automaticamente ganha 6 métodos relacionados à associação:

* `association`
* `association=(associate)`
* `build_association(attributes = {})`
* `create_association(attributes = {})`
* `create_association!(attributes = {})`
* `reload_association`
* `reset_association`

Em todos esses métodos, `association` é substituído pelo símbolo passado como primeiro argumento para `has_one`. Por exemplo, dada a declaração:

```ruby
class Supplier < ApplicationRecord
  has_one :account
end
```

Cada instância do modelo `Supplier` terá esses métodos:

* `account`
* `account=`
* `build_account`
* `create_account`
* `create_account!`
* `reload_account`
* `reset_account`

NOTA: Ao inicializar uma nova associação `has_one` ou `belongs_to`, você deve usar o prefixo `build_` para construir a associação, em vez do método `association.build` que seria usado para associações `has_many` ou `has_and_belongs_to_many`. Para criar um, use o prefixo `create_`.

##### `association`

O método `association` retorna o objeto associado, se houver. Se nenhum objeto associado for encontrado, ele retorna `nil`.

```ruby
@account = @supplier.account
```

Se o objeto associado já tiver sido recuperado do banco de dados para este objeto, a versão em cache será retornada. Para substituir esse comportamento (e forçar uma leitura do banco de dados), chame `#reload_association` no objeto pai.

```ruby
@account = @supplier.reload_account
```

Para descarregar a versão em cache do objeto associado - forçando o próximo acesso, se houver, a consultá-lo no banco de dados - chame `#reset_association` no objeto pai.

```ruby
@supplier.reset_account
```

##### `association=(associate)`

O método `association=` atribui um objeto associado a este objeto. Nos bastidores, isso significa extrair a chave primária deste objeto e definir a chave estrangeira do objeto associado com o mesmo valor.

```ruby
@supplier.account = @account
```

##### `build_association(attributes = {})`

O método `build_association` retorna um novo objeto do tipo associado. Este objeto será instanciado a partir dos atributos passados e o link através de sua chave estrangeira será definido, mas o objeto associado _ainda não_ será salvo.

```ruby
@account = @supplier.build_account(terms: "Net 30")
```

##### `create_association(attributes = {})`

O método `create_association` retorna um novo objeto do tipo associado. Este objeto será instanciado a partir dos atributos passados, o link através de sua chave estrangeira será definido e, uma vez que ele passar por todas as validações especificadas no modelo associado, o objeto associado _será_ salvo.

```ruby
@account = @supplier.create_account(terms: "Net 30")
```

##### `create_association!(attributes = {})`

Faz o mesmo que `create_association` acima, mas gera uma exceção `ActiveRecord::RecordInvalid` se o registro for inválido.

#### Opções para `has_one`

Embora o Rails use valores padrão inteligentes que funcionarão bem na maioria das situações, pode haver momentos em que você deseja personalizar o comportamento da referência de associação `has_one`. Tais personalizações podem ser facilmente realizadas passando opções ao criar a associação. Por exemplo, esta associação usa duas dessas opções:

```ruby
class Supplier < ApplicationRecord
  has_one :account, class_name: "Billing", dependent: :nullify
end
```

A associação [`has_one`][] suporta estas opções:

* `:as`
* `:autosave`
* `:class_name`
* `:dependent`
* `:foreign_key`
* `:inverse_of`
* `:primary_key`
* `:source`
* `:source_type`
* `:through`
* `:touch`
* `:validate`

##### `:as`

Definir a opção `:as` indica que esta é uma associação polimórfica. Associações polimórficas foram discutidas em detalhes [anteriormente neste guia](#polymorphic-associations).

##### `:autosave`

Se você definir a opção `:autosave` como `true`, o Rails salvará todos os membros da associação carregados e destruirá os membros que estão marcados para destruição sempre que você salvar o objeto pai. Definir `:autosave` como `false` não é o mesmo que não definir a opção `:autosave`. Se a opção `:autosave` não estiver presente, então novos objetos associados serão salvos, mas objetos associados atualizados não serão salvos.
##### `:class_name`

Se o nome do outro modelo não puder ser derivado do nome da associação, você pode usar a opção `:class_name` para fornecer o nome do modelo. Por exemplo, se um fornecedor tem uma conta, mas o nome real do modelo que contém as contas é `Billing`, você configuraria as coisas desta maneira:

```ruby
class Supplier < ApplicationRecord
  has_one :account, class_name: "Billing"
end
```

##### `:dependent`

Controla o que acontece com o objeto associado quando seu proprietário é destruído:

* `:destroy` faz com que o objeto associado também seja destruído
* `:delete` faz com que o objeto associado seja excluído diretamente do banco de dados (portanto, os callbacks não serão executados)
* `:destroy_async`: quando o objeto é destruído, um trabalho `ActiveRecord::DestroyAssociationAsyncJob` é enfileirado, que chamará a destruição em seus objetos associados. O Active Job deve ser configurado para que isso funcione. Não use esta opção se a associação for suportada por restrições de chave estrangeira em seu banco de dados. As ações de restrição de chave estrangeira ocorrerão dentro da mesma transação que exclui seu proprietário.
* `:nullify` faz com que a chave estrangeira seja definida como `NULL`. A coluna de tipo polimórfico também é definida como nula em associações polimórficas. Os callbacks não são executados.
* `:restrict_with_exception` faz com que uma exceção `ActiveRecord::DeleteRestrictionError` seja lançada se houver um registro associado
* `:restrict_with_error` faz com que um erro seja adicionado ao proprietário se houver um objeto associado

É necessário não definir ou deixar a opção `:nullify` para aquelas associações que têm restrições de banco de dados `NOT NULL`. Se você não definir `dependent` para destruir tais associações, você não poderá alterar o objeto associado porque a chave estrangeira do objeto associado inicial será definida como o valor `NULL` não permitido.

##### `:foreign_key`

Por convenção, o Rails assume que a coluna usada para armazenar a chave estrangeira no outro modelo é o nome deste modelo com o sufixo `_id` adicionado. A opção `:foreign_key` permite que você defina o nome da chave estrangeira diretamente:

```ruby
class Supplier < ApplicationRecord
  has_one :account, foreign_key: "supp_id"
end
```

DICA: Em qualquer caso, o Rails não criará colunas de chave estrangeira para você. Você precisa defini-las explicitamente como parte de suas migrações.

##### `:inverse_of`

A opção `:inverse_of` especifica o nome da associação `belongs_to` que é o inverso desta associação.
Consulte a seção [associação bidirecional](#associações-bidirecionais) para mais detalhes.

```ruby
class Supplier < ApplicationRecord
  has_one :account, inverse_of: :supplier
end

class Account < ApplicationRecord
  belongs_to :supplier, inverse_of: :account
end
```

##### `:primary_key`

Por convenção, o Rails assume que a coluna usada para armazenar a chave primária deste modelo é `id`. Você pode substituir isso e especificar explicitamente a chave primária com a opção `:primary_key`.

##### `:source`

A opção `:source` especifica o nome da associação de origem para uma associação `has_one :through`.

##### `:source_type`

A opção `:source_type` especifica o tipo de associação de origem para uma associação `has_one :through` que passa por uma associação polimórfica.

```ruby
class Author < ApplicationRecord
  has_one :book
  has_one :hardback, through: :book, source: :format, source_type: "Hardback"
  has_one :dust_jacket, through: :hardback
end

class Book < ApplicationRecord
  belongs_to :format, polymorphic: true
end

class Paperback < ApplicationRecord; end

class Hardback < ApplicationRecord
  has_one :dust_jacket
end

class DustJacket < ApplicationRecord; end
```

##### `:through`

A opção `:through` especifica um modelo de junção através do qual executar a consulta. As associações `has_one :through` foram discutidas em detalhes [anteriormente neste guia](#a-associação-has-one-through).

##### `:touch`

Se você definir a opção `:touch` como `true`, o timestamp `updated_at` ou `updated_on` no objeto associado será definido como o horário atual sempre que este objeto for salvo ou destruído:

```ruby
class Supplier < ApplicationRecord
  has_one :account, touch: true
end

class Account < ApplicationRecord
  belongs_to :supplier
end
```

Nesse caso, salvar ou destruir um fornecedor atualizará o timestamp na conta associada. Você também pode especificar um atributo de timestamp específico para atualizar:

```ruby
class Supplier < ApplicationRecord
  has_one :account, touch: :suppliers_updated_at
end
```

##### `:validate`

Se você definir a opção `:validate` como `true`, os novos objetos associados serão validados sempre que você salvar este objeto. Por padrão, isso é `false`: novos objetos associados não serão validados quando este objeto for salvo.

#### Escopos para `has_one`

Pode haver momentos em que você deseja personalizar a consulta usada pelo `has_one`. Essas personalizações podem ser feitas por meio de um bloco de escopo. Por exemplo:

```ruby
class Supplier < ApplicationRecord
  has_one :account, -> { where active: true }
end
```
Você pode usar qualquer um dos métodos padrão [de consulta](active_record_querying.html) dentro do bloco de escopo. Os seguintes são discutidos abaixo:

* `where`
* `includes`
* `readonly`
* `select`

##### `where`

O método `where` permite que você especifique as condições que o objeto associado deve atender.

```ruby
class Supplier < ApplicationRecord
  has_one :account, -> { where "confirmed = 1" }
end
```

##### `includes`

Você pode usar o método `includes` para especificar associações de segunda ordem que devem ser carregadas antecipadamente quando essa associação for usada. Por exemplo, considere esses modelos:

```ruby
class Supplier < ApplicationRecord
  has_one :account
end

class Account < ApplicationRecord
  belongs_to :supplier
  belongs_to :representative
end

class Representative < ApplicationRecord
  has_many :accounts
end
```

Se você frequentemente recupera representantes diretamente de fornecedores (`@supplier.account.representative`), você pode tornar seu código um pouco mais eficiente incluindo representantes na associação de fornecedores para contas:

```ruby
class Supplier < ApplicationRecord
  has_one :account, -> { includes :representative }
end

class Account < ApplicationRecord
  belongs_to :supplier
  belongs_to :representative
end

class Representative < ApplicationRecord
  has_many :accounts
end
```

##### `readonly`

Se você usar o método `readonly`, o objeto associado será somente leitura ao ser recuperado por meio da associação.

##### `select`

O método `select` permite substituir a cláusula SQL `SELECT` que é usada para recuperar dados sobre o objeto associado. Por padrão, o Rails recupera todas as colunas.

#### Existem Objetos Associados?

Você pode verificar se existem objetos associados usando o método `association.nil?`:

```ruby
if @supplier.account.nil?
  @msg = "Nenhuma conta encontrada para este fornecedor"
end
```

#### Quando os Objetos são Salvos?

Quando você atribui um objeto a uma associação `has_one`, esse objeto é automaticamente salvo (para atualizar sua chave estrangeira). Além disso, qualquer objeto que está sendo substituído também é automaticamente salvo, porque sua chave estrangeira também será alterada.

Se qualquer um desses salvamentos falhar devido a erros de validação, a declaração de atribuição retorna `false` e a própria atribuição é cancelada.

Se o objeto pai (aquele que declara a associação `has_one`) não estiver salvo (ou seja, `new_record?` retorna `true`), então os objetos filhos não serão salvos. Eles serão salvos automaticamente quando o objeto pai for salvo.

Se você quiser atribuir um objeto a uma associação `has_one` sem salvar o objeto, use o método `build_association`.

### Referência de Associação `has_many`

A associação `has_many` cria um relacionamento um-para-muitos com outro modelo. Em termos de banco de dados, essa associação indica que a outra classe terá uma chave estrangeira que se refere a instâncias dessa classe.

#### Métodos Adicionados por `has_many`

Quando você declara uma associação `has_many`, a classe declarante automaticamente ganha 17 métodos relacionados à associação:

* `collection`
* [`collection<<(object, ...)`][`collection<<`]
* [`collection.delete(object, ...)`][`collection.delete`]
* [`collection.destroy(object, ...)`][`collection.destroy`]
* `collection=(objects)`
* `collection_singular_ids`
* `collection_singular_ids=(ids)`
* [`collection.clear`][]
* [`collection.empty?`][]
* [`collection.size`][]
* [`collection.find(...)`][`collection.find`]
* [`collection.where(...)`][`collection.where`]
* [`collection.exists?(...)`][`collection.exists?`]
* [`collection.build(attributes = {})`][`collection.build`]
* [`collection.create(attributes = {})`][`collection.create`]
* [`collection.create!(attributes = {})`][`collection.create!`]
* [`collection.reload`][]

Em todos esses métodos, `collection` é substituído pelo símbolo passado como primeiro argumento para `has_many`, e `collection_singular` é substituído pela versão singularizada desse símbolo. Por exemplo, dada a declaração:

```ruby
class Author < ApplicationRecord
  has_many :books
end
```

Cada instância do modelo `Author` terá esses métodos:

```ruby
books
books<<(object, ...)
books.delete(object, ...)
books.destroy(object, ...)
books=(objects)
book_ids
book_ids=(ids)
books.clear
books.empty?
books.size
books.find(...)
books.where(...)
books.exists?(...)
books.build(attributes = {}, ...)
books.create(attributes = {})
books.create!(attributes = {})
books.reload
```

##### `collection`

O método `collection` retorna uma Relação de todos os objetos associados. Se não houver objetos associados, ele retorna uma Relação vazia.

```ruby
@books = @author.books
```

##### `collection<<(object, ...)`

O método [`collection<<`][] adiciona um ou mais objetos à coleção, definindo suas chaves estrangeiras como a chave primária do modelo chamador.

```ruby
@author.books << @book1
```

##### `collection.delete(object, ...)`

O método [`collection.delete`][] remove um ou mais objetos da coleção, definindo suas chaves estrangeiras como `NULL`.

```ruby
@author.books.delete(@book1)
```

ATENÇÃO: Além disso, os objetos serão destruídos se estiverem associados a `dependent: :destroy`, e excluídos se estiverem associados a `dependent: :delete_all`.

##### `collection.destroy(object, ...)`

O método [`collection.destroy`][] remove um ou mais objetos da coleção, executando `destroy` em cada objeto.

```ruby
@author.books.destroy(@book1)
```

ATENÇÃO: Os objetos _sempre_ serão removidos do banco de dados, ignorando a opção `:dependent`.

##### `collection=(objects)`

O método `collection=` faz com que a coleção contenha apenas os objetos fornecidos, adicionando e excluindo conforme necessário. As alterações são persistidas no banco de dados.
##### `collection_singular_ids`

O método `collection_singular_ids` retorna um array com os ids dos objetos na coleção.

```ruby
@book_ids = @author.book_ids
```

##### `collection_singular_ids=(ids)`

O método `collection_singular_ids=` faz com que a coleção contenha apenas os objetos identificados pelos valores de chave primária fornecidos, adicionando e excluindo conforme apropriado. As alterações são persistidas no banco de dados.

##### `collection.clear`

O método [`collection.clear`][] remove todos os objetos da coleção de acordo com a estratégia especificada pela opção `dependent`. Se nenhuma opção for fornecida, segue a estratégia padrão. A estratégia padrão para associações `has_many :through` é `delete_all`, e para associações `has_many` é definir as chaves estrangeiras como `NULL`.

```ruby
@author.books.clear
```

AVISO: Os objetos serão excluídos se estiverem associados a `dependent: :destroy` ou `dependent: :destroy_async`, assim como `dependent: :delete_all`.

##### `collection.empty?`

O método [`collection.empty?`][] retorna `true` se a coleção não contiver nenhum objeto associado.

```erb
<% if @author.books.empty? %>
  Nenhum livro encontrado
<% end %>
```

##### `collection.size`

O método [`collection.size`][] retorna o número de objetos na coleção.

```ruby
@book_count = @author.books.size
```

##### `collection.find(...)`

O método [`collection.find`][] encontra objetos dentro da tabela da coleção.

```ruby
@available_book = @author.books.find(1)
```

##### `collection.where(...)`

O método [`collection.where`][] encontra objetos dentro da coleção com base nas condições fornecidas, mas os objetos são carregados de forma preguiçosa, o que significa que o banco de dados é consultado apenas quando o(s) objeto(s) são acessados.

```ruby
@available_books = author.books.where(available: true) # Nenhuma consulta ainda
@available_book = @available_books.first # Agora o banco de dados será consultado
```

##### `collection.exists?(...)`

O método [`collection.exists?`][] verifica se um objeto que atende às condições fornecidas existe na tabela da coleção.

##### `collection.build(attributes = {})`

O método [`collection.build`][] retorna um único objeto ou um array de novos objetos do tipo associado. O(s) objeto(s) serão instanciados a partir dos atributos passados, e o link através de sua chave estrangeira será criado, mas os objetos associados ainda _não_ serão salvos.

```ruby
@book = author.books.build(published_at: Time.now,
                            book_number: "A12345")

@books = author.books.build([
  { published_at: Time.now, book_number: "A12346" },
  { published_at: Time.now, book_number: "A12347" }
])
```

##### `collection.create(attributes = {})`

O método [`collection.create`][] retorna um único objeto ou um array de novos objetos do tipo associado. O(s) objeto(s) serão instanciados a partir dos atributos passados, o link através de sua chave estrangeira será criado e, uma vez que passar por todas as validações especificadas no modelo associado, o objeto associado _será_ salvo.

```ruby
@book = author.books.create(published_at: Time.now,
                             book_number: "A12345")

@books = author.books.create([
  { published_at: Time.now, book_number: "A12346" },
  { published_at: Time.now, book_number: "A12347" }
])
```

##### `collection.create!(attributes = {})`

Faz o mesmo que `collection.create` acima, mas gera uma exceção `ActiveRecord::RecordInvalid` se o registro for inválido.

##### `collection.reload`

O método [`collection.reload`][] retorna uma Relation de todos os objetos associados, forçando uma leitura do banco de dados. Se não houver objetos associados, ele retorna uma Relation vazia.

```ruby
@books = author.books.reload
```

#### Opções para `has_many`

Embora o Rails use valores padrão inteligentes que funcionam bem na maioria das situações, pode haver momentos em que você deseja personalizar o comportamento da associação `has_many`. Essas personalizações podem ser facilmente feitas passando opções ao criar a associação. Por exemplo, esta associação usa duas opções:

```ruby
class Author < ApplicationRecord
  has_many :books, dependent: :delete_all, validate: false
end
```

A associação [`has_many`][] suporta estas opções:

* `:as`
* `:autosave`
* `:class_name`
* `:counter_cache`
* `:dependent`
* `:foreign_key`
* `:inverse_of`
* `:primary_key`
* `:source`
* `:source_type`
* `:through`
* `:validate`

##### `:as`

Definir a opção `:as` indica que esta é uma associação polimórfica, como discutido [anteriormente neste guia](#associações-polimórficas).

##### `:autosave`

Se você definir a opção `:autosave` como `true`, o Rails salvará todos os membros da associação carregados e destruirá os membros marcados para destruição sempre que você salvar o objeto pai. Definir `:autosave` como `false` não é o mesmo que não definir a opção `:autosave`. Se a opção `:autosave` não estiver presente, então os novos objetos associados serão salvos, mas os objetos associados atualizados não serão salvos.

##### `:class_name`

Se o nome do outro modelo não puder ser derivado do nome da associação, você pode usar a opção `:class_name` para fornecer o nome do modelo. Por exemplo, se um autor tem muitos livros, mas o nome real do modelo que contém os livros é `Transaction`, você configuraria as coisas desta maneira:

```ruby
class Author < ApplicationRecord
  has_many :books, class_name: "Transaction"
end
```
##### `:counter_cache`

Essa opção pode ser usada para configurar um `:counter_cache` com um nome personalizado. Você só precisa dessa opção quando personalizou o nome do seu `:counter_cache` na [associação belongs_to](#options-for-belongs-to).

##### `:dependent`

Controla o que acontece com os objetos associados quando o objeto pai é destruído:

* `:destroy` faz com que todos os objetos associados também sejam destruídos
* `:delete_all` faz com que todos os objetos associados sejam excluídos diretamente do banco de dados (então os callbacks não serão executados)
* `:destroy_async`: quando o objeto é destruído, um job `ActiveRecord::DestroyAssociationAsyncJob` é enfileirado, o qual chamará o método destroy nos objetos associados. O Active Job deve estar configurado para que isso funcione.
* `:nullify` faz com que a chave estrangeira seja definida como `NULL`. A coluna do tipo polimórfico também é definida como nula em associações polimórficas. Os callbacks não são executados.
* `:restrict_with_exception` faz com que uma exceção `ActiveRecord::DeleteRestrictionError` seja lançada se houver algum registro associado
* `:restrict_with_error` faz com que um erro seja adicionado ao objeto pai se houver algum objeto associado

As opções `:destroy` e `:delete_all` também afetam a semântica dos métodos `collection.delete` e `collection=` ao fazer com que eles destruam os objetos associados quando eles são removidos da coleção.

##### `:foreign_key`

Por convenção, o Rails assume que a coluna usada para armazenar a chave estrangeira no outro modelo é o nome deste modelo com o sufixo `_id` adicionado. A opção `:foreign_key` permite que você defina o nome da chave estrangeira diretamente:

```ruby
class Author < ApplicationRecord
  has_many :books, foreign_key: "cust_id"
end
```

DICA: Em qualquer caso, o Rails não criará colunas de chave estrangeira para você. Você precisa defini-las explicitamente como parte de suas migrações.

##### `:inverse_of`

A opção `:inverse_of` especifica o nome da associação `belongs_to` que é o inverso dessa associação. Consulte a seção [associação bidirecional](#bi-directional-associations) para mais detalhes.

```ruby
class Author < ApplicationRecord
  has_many :books, inverse_of: :author
end

class Book < ApplicationRecord
  belongs_to :author, inverse_of: :books
end
```

##### `:primary_key`

Por convenção, o Rails assume que a coluna usada para armazenar a chave primária da associação é `id`. Você pode substituir isso e especificar explicitamente a chave primária com a opção `:primary_key`.

Digamos que a tabela `users` tenha `id` como chave primária, mas também tenha uma coluna `guid`. O requisito é que a tabela `todos` deve armazenar o valor da coluna `guid` como chave estrangeira e não o valor `id`. Isso pode ser alcançado da seguinte forma:

```ruby
class User < ApplicationRecord
  has_many :todos, primary_key: :guid
end
```

Agora, se executarmos `@todo = @user.todos.create`, o valor de `user_id` no registro `@todo` será o valor `guid` de `@user`.

##### `:source`

A opção `:source` especifica o nome da associação de origem para uma associação `has_many :through`. Você só precisa usar essa opção se o nome da associação de origem não puder ser inferido automaticamente a partir do nome da associação.

##### `:source_type`

A opção `:source_type` especifica o tipo de associação de origem para uma associação `has_many :through` que passa por uma associação polimórfica.

```ruby
class Author < ApplicationRecord
  has_many :books
  has_many :paperbacks, through: :books, source: :format, source_type: "Paperback"
end

class Book < ApplicationRecord
  belongs_to :format, polymorphic: true
end

class Hardback < ApplicationRecord; end
class Paperback < ApplicationRecord; end
```

##### `:through`

A opção `:through` especifica um modelo de junção através do qual executar a consulta. As associações `has_many :through` fornecem uma maneira de implementar relacionamentos muitos para muitos, como discutido [anteriormente neste guia](#the-has-many-through-association).

##### `:validate`

Se você definir a opção `:validate` como `false`, os novos objetos associados não serão validados sempre que você salvar esse objeto. Por padrão, isso é `true`: os novos objetos associados serão validados quando esse objeto for salvo.

#### Escopos para `has_many`

Pode haver momentos em que você deseja personalizar a consulta usada por `has_many`. Essas personalizações podem ser feitas através de um bloco de escopo. Por exemplo:

```ruby
class Author < ApplicationRecord
  has_many :books, -> { where processed: true }
end
```

Você pode usar qualquer um dos métodos de consulta padrão [mencionados aqui](active_record_querying.html) dentro do bloco de escopo. Os seguintes são discutidos abaixo:

* `where`
* `extending`
* `group`
* `includes`
* `limit`
* `offset`
* `order`
* `readonly`
* `select`
* `distinct`

##### `where`

O método `where` permite que você especifique as condições que o objeto associado deve atender.

```ruby
class Author < ApplicationRecord
  has_many :confirmed_books, -> { where "confirmed = 1" },
    class_name: "Book"
end
```
Você também pode definir condições através de um hash:

```ruby
class Author < ApplicationRecord
  has_many :confirmed_books, -> { where confirmed: true },
    class_name: "Book"
end
```

Se você usar a opção `where` no estilo de hash, então a criação de registros através dessa associação será automaticamente limitada usando o hash. Nesse caso, ao usar `@author.confirmed_books.create` ou `@author.confirmed_books.build`, serão criados livros onde a coluna confirmed tem o valor `true`.

##### `extending`

O método `extending` especifica um módulo nomeado para estender o proxy da associação. As extensões de associação são discutidas em detalhes [mais adiante neste guia](#extensiones-de-associação).

##### `group`

O método `group` fornece um nome de atributo para agrupar o conjunto de resultados, usando uma cláusula `GROUP BY` no SQL do finder.

```ruby
class Author < ApplicationRecord
  has_many :chapters, -> { group 'books.id' },
                      through: :books
end
```

##### `includes`

Você pode usar o método `includes` para especificar associações de segunda ordem que devem ser carregadas antecipadamente quando essa associação é usada. Por exemplo, considere esses modelos:

```ruby
class Author < ApplicationRecord
  has_many :books
end

class Book < ApplicationRecord
  belongs_to :author
  has_many :chapters
end

class Chapter < ApplicationRecord
  belongs_to :book
end
```

Se você frequentemente recupera capítulos diretamente de autores (`@author.books.chapters`), então você pode tornar seu código um pouco mais eficiente incluindo os capítulos na associação de autores para livros:

```ruby
class Author < ApplicationRecord
  has_many :books, -> { includes :chapters }
end

class Book < ApplicationRecord
  belongs_to :author
  has_many :chapters
end

class Chapter < ApplicationRecord
  belongs_to :book
end
```

##### `limit`

O método `limit` permite restringir o número total de objetos que serão buscados através de uma associação.

```ruby
class Author < ApplicationRecord
  has_many :recent_books,
    -> { order('published_at desc').limit(100) },
    class_name: "Book"
end
```

##### `offset`

O método `offset` permite especificar o deslocamento inicial para buscar objetos através de uma associação. Por exemplo, `-> { offset(11) }` irá pular os primeiros 11 registros.

##### `order`

O método `order` dita a ordem em que os objetos associados serão recebidos (na sintaxe usada por uma cláusula SQL `ORDER BY`).

```ruby
class Author < ApplicationRecord
  has_many :books, -> { order "date_confirmed DESC" }
end
```

##### `readonly`

Se você usar o método `readonly`, então os objetos associados serão somente leitura quando recuperados através da associação.

##### `select`

O método `select` permite substituir a cláusula SQL `SELECT` que é usada para recuperar dados sobre os objetos associados. Por padrão, o Rails recupera todas as colunas.

AVISO: Se você especificar seu próprio `select`, certifique-se de incluir as colunas de chave primária e chave estrangeira do modelo associado. Se você não fizer isso, o Rails lançará um erro.

##### `distinct`

Use o método `distinct` para manter a coleção livre de duplicatas. Isso é
principalmente útil em conjunto com a opção `:through`.

```ruby
class Person < ApplicationRecord
  has_many :readings
  has_many :articles, through: :readings
end
```

```irb
irb> person = Person.create(name: 'John')
irb> article = Article.create(name: 'a1')
irb> person.articles << article
irb> person.articles << article
irb> person.articles.to_a
=> [#<Article id: 5, name: "a1">, #<Article id: 5, name: "a1">]
irb> Reading.all.to_a
=> [#<Reading id: 12, person_id: 5, article_id: 5>, #<Reading id: 13, person_id: 5, article_id: 5>]
```

No caso acima, existem duas leituras e `person.articles` traz ambas, mesmo que esses registros apontem para o mesmo artigo.

Agora vamos definir `distinct`:

```ruby
class Person
  has_many :readings
  has_many :articles, -> { distinct }, through: :readings
end
```

```irb
irb> person = Person.create(name: 'Honda')
irb> article = Article.create(name: 'a1')
irb> person.articles << article
irb> person.articles << article
irb> person.articles.to_a
=> [#<Article id: 7, name: "a1">]
irb> Reading.all.to_a
=> [#<Reading id: 16, person_id: 7, article_id: 7>, #<Reading id: 17, person_id: 7, article_id: 7>]
```

No caso acima, ainda existem duas leituras. No entanto, `person.articles` mostra apenas um artigo porque a coleção carrega apenas registros únicos.

Se você quiser garantir que, ao inserir, todos os registros na
associação persistida sejam distintos (para que você possa ter certeza de que, ao
inspecionar a associação, nunca encontrará registros duplicados), você deve
adicionar um índice único na própria tabela. Por exemplo, se você tiver uma tabela chamada
`readings` e quiser garantir que os artigos só possam ser adicionados a uma pessoa uma vez,
você pode adicionar o seguinte em uma migração:

```ruby
add_index :readings, [:person_id, :article_id], unique: true
```
Uma vez que você tenha esse índice único, tentar adicionar o artigo a uma pessoa duas vezes
irá gerar um erro `ActiveRecord::RecordNotUnique`:

```irb
irb> person = Person.create(name: 'Honda')
irb> article = Article.create(name: 'a1')
irb> person.articles << article
irb> person.articles << article
ActiveRecord::RecordNotUnique
```

Observe que verificar a unicidade usando algo como `include?` está sujeito
a condições de corrida. Não tente usar `include?` para garantir a distinção
em uma associação. Por exemplo, usando o exemplo do artigo acima, o
código a seguir seria suscetível a condições de corrida, pois vários usuários poderiam estar tentando isso
ao mesmo tempo:

```ruby
person.articles << article unless person.articles.include?(article)
```

#### Quando os objetos são salvos?

Quando você atribui um objeto a uma associação `has_many`, esse objeto é automaticamente salvo (para atualizar sua chave estrangeira). Se você atribuir vários objetos em uma única instrução, todos eles serão salvos.

Se algum desses salvamentos falhar devido a erros de validação, a instrução de atribuição retorna `false` e a própria atribuição é cancelada.

Se o objeto pai (aquele que declara a associação `has_many`) não estiver salvo (ou seja, `new_record?` retorna `true`), então os objetos filhos não serão salvos quando forem adicionados. Todos os membros não salvos da associação serão salvos automaticamente quando o pai for salvo.

Se você deseja atribuir um objeto a uma associação `has_many` sem salvar o objeto, use o método `collection.build`.

### Referência de Associação `has_and_belongs_to_many`

A associação `has_and_belongs_to_many` cria um relacionamento muitos para muitos com outro modelo. Em termos de banco de dados, isso associa duas classes por meio de uma tabela de junção intermediária que inclui chaves estrangeiras referentes a cada uma das classes.

#### Métodos adicionados por `has_and_belongs_to_many`

Quando você declara uma associação `has_and_belongs_to_many`, a classe declarante automaticamente ganha vários métodos relacionados à associação:

* `collection`
* [`collection<<(object, ...)`][`collection<<`]
* [`collection.delete(object, ...)`][`collection.delete`]
* [`collection.destroy(object, ...)`][`collection.destroy`]
* `collection=(objects)`
* `collection_singular_ids`
* `collection_singular_ids=(ids)`
* [`collection.clear`][]
* [`collection.empty?`][]
* [`collection.size`][]
* [`collection.find(...)`][`collection.find`]
* [`collection.where(...)`][`collection.where`]
* [`collection.exists?(...)`][`collection.exists?`]
* [`collection.build(attributes = {})`][`collection.build`]
* [`collection.create(attributes = {})`][`collection.create`]
* [`collection.create!(attributes = {})`][`collection.create!`]
* [`collection.reload`][]

Em todos esses métodos, `collection` é substituído pelo símbolo passado como primeiro argumento para `has_and_belongs_to_many`, e `collection_singular` é substituído pela versão singularizada desse símbolo. Por exemplo, dada a declaração:

```ruby
class Part < ApplicationRecord
  has_and_belongs_to_many :assemblies
end
```

Cada instância do modelo `Part` terá esses métodos:

```ruby
assemblies
assemblies<<(object, ...)
assemblies.delete(object, ...)
assemblies.destroy(object, ...)
assemblies=(objects)
assembly_ids
assembly_ids=(ids)
assemblies.clear
assemblies.empty?
assemblies.size
assemblies.find(...)
assemblies.where(...)
assemblies.exists?(...)
assemblies.build(attributes = {}, ...)
assemblies.create(attributes = {})
assemblies.create!(attributes = {})
assemblies.reload
```

##### Métodos adicionais de coluna

Se a tabela de junção para uma associação `has_and_belongs_to_many` tiver colunas adicionais além das duas chaves estrangeiras, essas colunas serão adicionadas como atributos aos registros recuperados por meio dessa associação. Registros retornados com atributos adicionais sempre serão somente leitura, porque o Rails não pode salvar alterações nesses atributos.

ATENÇÃO: O uso de atributos extras na tabela de junção em uma associação `has_and_belongs_to_many` está obsoleto. Se você precisar desse tipo de comportamento complexo na tabela que une dois modelos em um relacionamento muitos para muitos, você deve usar uma associação `has_many :through` em vez de `has_and_belongs_to_many`.

##### `collection`

O método `collection` retorna uma relação de todos os objetos associados. Se não houver objetos associados, ele retorna uma relação vazia.

```ruby
@assemblies = @part.assemblies
```

##### `collection<<(object, ...)`

O método [`collection<<`][] adiciona um ou mais objetos à coleção, criando registros na tabela de junção.

```ruby
@part.assemblies << @assembly1
```

OBSERVAÇÃO: Este método também é chamado de `collection.concat` e `collection.push`.

##### `collection.delete(object, ...)`

O método [`collection.delete`][] remove um ou mais objetos da coleção, excluindo registros na tabela de junção. Isso não destrói os objetos.

```ruby
@part.assemblies.delete(@assembly1)
```

##### `collection.destroy(object, ...)`

O método [`collection.destroy`][] remove um ou mais objetos da coleção, excluindo registros na tabela de junção. Isso não destrói os objetos.

```ruby
@part.assemblies.destroy(@assembly1)
```

##### `collection=(objects)`

O método `collection=` faz com que a coleção contenha apenas os objetos fornecidos, adicionando e excluindo conforme necessário. As alterações são persistidas no banco de dados.

##### `collection_singular_ids`

O método `collection_singular_ids` retorna um array com os ids dos objetos na coleção.

```ruby
@assembly_ids = @part.assembly_ids
```

##### `collection_singular_ids=(ids)`

O método `collection_singular_ids=` faz com que a coleção contenha apenas os objetos identificados pelos valores dos principais chaves fornecidos, adicionando e excluindo conforme necessário. As alterações são persistidas no banco de dados.
##### `collection.clear`

O método [`collection.clear`][] remove todos os objetos da coleção, excluindo as linhas da tabela de junção. Isso não destrói os objetos associados.

##### `collection.empty?`

O método [`collection.empty?`][] retorna `true` se a coleção não contiver nenhum objeto associado.

```html+erb
<% if @part.assemblies.empty? %>
  Esta peça não é usada em nenhuma montagem
<% end %>
```

##### `collection.size`

O método [`collection.size`][] retorna o número de objetos na coleção.

```ruby
@assembly_count = @part.assemblies.size
```

##### `collection.find(...)`

O método [`collection.find`][] encontra objetos dentro da tabela da coleção.

```ruby
@assembly = @part.assemblies.find(1)
```

##### `collection.where(...)`

O método [`collection.where`][] encontra objetos dentro da coleção com base nas condições fornecidas, mas os objetos são carregados de forma preguiçosa, o que significa que o banco de dados é consultado apenas quando o(s) objeto(s) são acessados.

```ruby
@new_assemblies = @part.assemblies.where("created_at > ?", 2.days.ago)
```

##### `collection.exists?(...)`

O método [`collection.exists?`][] verifica se um objeto que atende às condições fornecidas existe na tabela da coleção.

##### `collection.build(attributes = {})`

O método [`collection.build`][] retorna um novo objeto do tipo associado. Este objeto será instanciado a partir dos atributos passados, e o link através da tabela de junção será criado, mas o objeto associado ainda não será salvo.

```ruby
@assembly = @part.assemblies.build({ assembly_name: "Transmission housing" })
```

##### `collection.create(attributes = {})`

O método [`collection.create`][] retorna um novo objeto do tipo associado. Este objeto será instanciado a partir dos atributos passados, o link através da tabela de junção será criado e, uma vez que ele passar por todas as validações especificadas no modelo associado, o objeto associado será salvo.

```ruby
@assembly = @part.assemblies.create({ assembly_name: "Transmission housing" })
```

##### `collection.create!(attributes = {})`

Faz o mesmo que `collection.create`, mas gera uma exceção `ActiveRecord::RecordInvalid` se o registro for inválido.

##### `collection.reload`

O método [`collection.reload`][] retorna uma relação de todos os objetos associados, forçando uma leitura do banco de dados. Se não houver objetos associados, ele retorna uma relação vazia.

```ruby
@assemblies = @part.assemblies.reload
```

#### Opções para `has_and_belongs_to_many`

Embora o Rails use valores padrão inteligentes que funcionam bem na maioria das situações, pode haver momentos em que você deseja personalizar o comportamento da associação `has_and_belongs_to_many`. Essas personalizações podem ser facilmente feitas passando opções ao criar a associação. Por exemplo, esta associação usa duas opções:

```ruby
class Parts < ApplicationRecord
  has_and_belongs_to_many :assemblies, -> { readonly },
                                       autosave: true
end
```

A associação [`has_and_belongs_to_many`][] suporta estas opções:

* `:association_foreign_key`
* `:autosave`
* `:class_name`
* `:foreign_key`
* `:join_table`
* `:validate`

##### `:association_foreign_key`

Por convenção, o Rails assume que a coluna na tabela de junção usada para armazenar a chave estrangeira que aponta para o outro modelo é o nome desse modelo com o sufixo `_id` adicionado. A opção `:association_foreign_key` permite que você defina o nome da chave estrangeira diretamente:

DICA: As opções `:foreign_key` e `:association_foreign_key` são úteis ao configurar uma auto-junção muitos-para-muitos. Por exemplo:

```ruby
class User < ApplicationRecord
  has_and_belongs_to_many :friends,
      class_name: "User",
      foreign_key: "this_user_id",
      association_foreign_key: "other_user_id"
end
```

##### `:autosave`

Se você definir a opção `:autosave` como `true`, o Rails salvará todos os membros da associação carregados e destruirá os membros que estiverem marcados para destruição sempre que você salvar o objeto pai. Definir `:autosave` como `false` não é o mesmo que não definir a opção `:autosave`. Se a opção `:autosave` não estiver presente, então novos objetos associados serão salvos, mas objetos associados atualizados não serão salvos.

##### `:class_name`

Se o nome do outro modelo não puder ser derivado do nome da associação, você pode usar a opção `:class_name` para fornecer o nome do modelo. Por exemplo, se uma peça tiver muitas montagens, mas o nome real do modelo que contém as montagens for `Gadget`, você configuraria as coisas desta maneira:

```ruby
class Parts < ApplicationRecord
  has_and_belongs_to_many :assemblies, class_name: "Gadget"
end
```

##### `:foreign_key`

Por convenção, o Rails assume que a coluna na tabela de junção usada para armazenar a chave estrangeira que aponta para este modelo é o nome deste modelo com o sufixo `_id` adicionado. A opção `:foreign_key` permite que você defina o nome da chave estrangeira diretamente:

```ruby
class User < ApplicationRecord
  has_and_belongs_to_many :friends,
      class_name: "User",
      foreign_key: "this_user_id",
      association_foreign_key: "other_user_id"
end
```

##### `:join_table`

Se o nome padrão da tabela de junção, com base na ordenação lexical, não for o desejado, você pode usar a opção `:join_table` para substituir o padrão.
##### `:validate`

Se você definir a opção `:validate` como `false`, os novos objetos associados não serão validados sempre que você salvar esse objeto. Por padrão, isso é `true`: os novos objetos associados serão validados quando esse objeto for salvo.

#### Escopos para `has_and_belongs_to_many`

Pode haver momentos em que você deseja personalizar a consulta usada por `has_and_belongs_to_many`. Essas personalizações podem ser feitas por meio de um bloco de escopo. Por exemplo:

```ruby
class Parts < ApplicationRecord
  has_and_belongs_to_many :assemblies, -> { where active: true }
end
```

Você pode usar qualquer um dos métodos de consulta padrão [métodos de consulta do Active Record](active_record_querying.html) dentro do bloco de escopo. Os seguintes são discutidos abaixo:

* `where`
* `extending`
* `group`
* `includes`
* `limit`
* `offset`
* `order`
* `readonly`
* `select`
* `distinct`

##### `where`

O método `where` permite que você especifique as condições que o objeto associado deve atender.

```ruby
class Parts < ApplicationRecord
  has_and_belongs_to_many :assemblies,
    -> { where "factory = 'Seattle'" }
end
```

Você também pode definir condições por meio de um hash:

```ruby
class Parts < ApplicationRecord
  has_and_belongs_to_many :assemblies,
    -> { where factory: 'Seattle' }
end
```

Se você usar um `where` no estilo de hash, então a criação de registros por meio dessa associação será automaticamente limitada usando o hash. Nesse caso, usar `@parts.assemblies.create` ou `@parts.assemblies.build` criará assemblies onde a coluna `factory` tem o valor "Seattle".

##### `extending`

O método `extending` especifica um módulo nomeado para estender o proxy de associação. As extensões de associação são discutidas em detalhes [mais adiante neste guia](#extensões-de-associação).

##### `group`

O método `group` fornece um nome de atributo para agrupar o conjunto de resultados, usando uma cláusula `GROUP BY` no SQL do localizador.

```ruby
class Parts < ApplicationRecord
  has_and_belongs_to_many :assemblies, -> { group "factory" }
end
```

##### `includes`

Você pode usar o método `includes` para especificar associações de segunda ordem que devem ser carregadas antecipadamente quando essa associação for usada.

##### `limit`

O método `limit` permite restringir o número total de objetos que serão buscados por meio de uma associação.

```ruby
class Parts < ApplicationRecord
  has_and_belongs_to_many :assemblies,
    -> { order("created_at DESC").limit(50) }
end
```

##### `offset`

O método `offset` permite especificar o deslocamento inicial para buscar objetos por meio de uma associação. Por exemplo, se você definir `offset(11)`, ele irá pular os primeiros 11 registros.

##### `order`

O método `order` dita a ordem em que os objetos associados serão recebidos (na sintaxe usada por uma cláusula `ORDER BY` do SQL).

```ruby
class Parts < ApplicationRecord
  has_and_belongs_to_many :assemblies,
    -> { order "assembly_name ASC" }
end
```

##### `readonly`

Se você usar o método `readonly`, então os objetos associados serão somente leitura ao serem recuperados por meio da associação.

##### `select`

O método `select` permite substituir a cláusula SQL `SELECT` que é usada para recuperar dados sobre os objetos associados. Por padrão, o Rails recupera todas as colunas.

##### `distinct`

Use o método `distinct` para remover duplicatas da coleção.

#### Quando os objetos são salvos?

Quando você atribui um objeto a uma associação `has_and_belongs_to_many`, esse objeto é automaticamente salvo (para atualizar a tabela de junção). Se você atribuir vários objetos em uma única instrução, todos eles serão salvos.

Se algum desses salvamentos falhar devido a erros de validação, a instrução de atribuição retorna `false` e a própria atribuição é cancelada.

Se o objeto pai (aquele que declara a associação `has_and_belongs_to_many`) não estiver salvo (ou seja, `new_record?` retorna `true`), então os objetos filhos não serão salvos quando forem adicionados. Todos os membros não salvos da associação serão automaticamente salvos quando o pai for salvo.

Se você deseja atribuir um objeto a uma associação `has_and_belongs_to_many` sem salvar o objeto, use o método `collection.build`.

### Callbacks de Associação

Callbacks normais se conectam ao ciclo de vida dos objetos do Active Record, permitindo que você trabalhe com esses objetos em vários pontos. Por exemplo, você pode usar um callback `:before_save` para fazer algo acontecer logo antes de um objeto ser salvo.

Callbacks de associação são semelhantes aos callbacks normais, mas são acionados por eventos no ciclo de vida de uma coleção. Existem quatro callbacks de associação disponíveis:

* `before_add`
* `after_add`
* `before_remove`
* `after_remove`

Você define callbacks de associação adicionando opções à declaração da associação. Por exemplo:

```ruby
class Author < ApplicationRecord
  has_many :books, before_add: :check_credit_limit

  def check_credit_limit(book)
    # ...
  end
end
```

O Rails passa o objeto sendo adicionado ou removido para o callback.
Você pode empilhar callbacks em um único evento passando-os como um array:

```ruby
class Author < ApplicationRecord
  has_many :books,
    before_add: [:check_credit_limit, :calculate_shipping_charges]

  def check_credit_limit(book)
    # ...
  end

  def calculate_shipping_charges(book)
    # ...
  end
end
```

Se um callback `before_add` lançar `:abort`, o objeto não será adicionado à coleção. Da mesma forma, se um callback `before_remove` lançar `:abort`, o objeto não será removido da coleção:

```ruby
# o livro não será adicionado se o limite for atingido
def check_credit_limit(book)
  throw(:abort) if limit_reached?
end
```

NOTA: Esses callbacks são chamados apenas quando os objetos associados são adicionados ou removidos através da coleção de associação:

```ruby
# Aciona o callback `before_add`
author.books << book
author.books = [book, book2]

# Não aciona o callback `before_add`
book.update(author_id: 1)
```

### Extensões de Associação

Você não está limitado à funcionalidade que o Rails constrói automaticamente nos objetos proxy de associação. Você também pode estender esses objetos através de módulos anônimos, adicionando novos finders, criadores ou outros métodos. Por exemplo:

```ruby
class Author < ApplicationRecord
  has_many :books do
    def find_by_book_prefix(book_number)
      find_by(category_id: book_number[0..2])
    end
  end
end
```

Se você tiver uma extensão que deve ser compartilhada por muitas associações, você pode usar um módulo de extensão nomeado. Por exemplo:

```ruby
module FindRecentExtension
  def find_recent
    where("created_at > ?", 5.days.ago)
  end
end

class Author < ApplicationRecord
  has_many :books, -> { extending FindRecentExtension }
end

class Supplier < ApplicationRecord
  has_many :deliveries, -> { extending FindRecentExtension }
end
```

As extensões podem se referir aos internos do proxy de associação usando esses três atributos do acessor `proxy_association`:

* `proxy_association.owner` retorna o objeto do qual a associação faz parte.
* `proxy_association.reflection` retorna o objeto de reflexão que descreve a associação.
* `proxy_association.target` retorna o objeto associado para `belongs_to` ou `has_one`, ou a coleção de objetos associados para `has_many` ou `has_and_belongs_to_many`.

### Escopo de Associação usando o Proprietário da Associação

O proprietário da associação pode ser passado como um único argumento para o bloco de escopo em situações em que você precisa de ainda mais controle sobre o escopo da associação. No entanto, como uma ressalva, o pré-carregamento da associação não será mais possível.

```ruby
class Supplier < ApplicationRecord
  has_one :account, ->(supplier) { where active: supplier.active? }
end
```

Herança de Tabela Única (STI)
------------------------------

Às vezes, você pode querer compartilhar campos e comportamentos entre diferentes modelos. Digamos que temos os modelos Carro, Motocicleta e Bicicleta. Queremos compartilhar os campos `color` e `price` e alguns métodos para todos eles, mas ter comportamentos específicos para cada um e controladores separados também.

Primeiro, vamos gerar o modelo base Vehicle:

```bash
$ bin/rails generate model vehicle type:string color:string price:decimal{10.2}
```

Você notou que estamos adicionando um campo "type"? Como todos os modelos serão salvos em uma única tabela de banco de dados, o Rails salvará nesta coluna o nome do modelo que está sendo salvo. Em nosso exemplo, isso pode ser "Car", "Motorcycle" ou "Bicycle". O STI não funcionará sem um campo "type" na tabela.

Em seguida, vamos gerar o modelo Carro que herda de Vehicle. Para isso, podemos usar a opção `--parent=PARENT`, que irá gerar um modelo que herda do pai especificado e sem migração equivalente (já que a tabela já existe).

Por exemplo, para gerar o modelo Carro:

```bash
$ bin/rails generate model car --parent=Vehicle
```

O modelo gerado ficará assim:

```ruby
class Car < Vehicle
end
```

Isso significa que todo o comportamento adicionado a Vehicle está disponível também para Car, como associações, métodos públicos, etc.

Criar um carro irá salvá-lo na tabela `vehicles` com "Car" como o campo `type`:

```ruby
Car.create(color: 'Red', price: 10000)
```

irá gerar o seguinte SQL:

```sql
INSERT INTO "vehicles" ("type", "color", "price") VALUES ('Car', 'Red', 10000)
```

Consultar registros de carros irá procurar apenas por veículos que são carros:

```ruby
Car.all
```

irá executar uma consulta como:

```sql
SELECT "vehicles".* FROM "vehicles" WHERE "vehicles"."type" IN ('Car')
```

Tipos Delegados
----------------

[`Herança de Tabela Única (STI)`](#herança-de-tabela-única-sti) funciona melhor quando há pouca diferença entre subclasses e seus atributos, mas inclui todos os atributos de todas as subclasses que você precisa criar uma única tabela.

A desvantagem dessa abordagem é que ela resulta em inchaço dessa tabela. Pois ela incluirá até mesmo atributos específicos de uma subclasse que não são usados por mais nada.

No exemplo a seguir, existem dois modelos Active Record que herdam da mesma classe "Entry" que inclui o atributo `subject`.
```ruby
# Esquema: entries[ id, type, subject, created_at, updated_at]
class Entry < ApplicationRecord
end

class Comment < Entry
end

class Message < Entry
end
```

Os tipos delegados resolvem esse problema, via `delegated_type`.

Para usar tipos delegados, precisamos modelar nossos dados de uma maneira específica. Os requisitos são os seguintes:

* Existe uma superclasse que armazena atributos compartilhados entre todas as subclasses em sua tabela.
* Cada subclasse deve herdar da superclasse e terá uma tabela separada para quaisquer atributos adicionais específicos a ela.

Isso elimina a necessidade de definir atributos em uma única tabela que são compartilhados inadvertidamente entre todas as subclasses.

Para aplicar isso ao nosso exemplo acima, precisamos regenerar nossos modelos.
Primeiro, vamos gerar o modelo base `Entry` que atuará como nossa superclasse:

```bash
$ bin/rails generate model entry entryable_type:string entryable_id:integer
```

Em seguida, geraremos os novos modelos `Message` e `Comment` para delegação:

```bash
$ bin/rails generate model message subject:string body:string
$ bin/rails generate model comment content:string
```

Após executar os geradores, devemos ter modelos que se parecem com isso:

```ruby
# Esquema: entries[ id, entryable_type, entryable_id, created_at, updated_at ]
class Entry < ApplicationRecord
end

# Esquema: messages[ id, subject, body, created_at, updated_at ]
class Message < ApplicationRecord
end

# Esquema: comments[ id, content, created_at, updated_at ]
class Comment < ApplicationRecord
end
```

### Declarar `delegated_type`

Primeiro, declare um `delegated_type` na superclasse `Entry`.

```ruby
class Entry < ApplicationRecord
  delegated_type :entryable, types: %w[ Message Comment ], dependent: :destroy
end
```

O parâmetro `entryable` especifica o campo a ser usado para delegação e inclui os tipos `Message` e `Comment` como as classes delegadas.

A classe `Entry` tem os campos `entryable_type` e `entryable_id`. Este é o campo com os sufixos `_type` e `_id` adicionados ao nome `entryable` na definição de `delegated_type`.
`entryable_type` armazena o nome da subclasse do delegado e `entryable_id` armazena o ID do registro da subclasse do delegado.

Em seguida, devemos definir um módulo para implementar esses tipos delegados, declarando o parâmetro `as: :entryable` para a associação `has_one`.

```ruby
module Entryable
  extend ActiveSupport::Concern

  included do
    has_one :entry, as: :entryable, touch: true
  end
end
```

E então inclua o módulo criado em sua subclasse.

```ruby
class Message < ApplicationRecord
  include Entryable
end

class Comment < ApplicationRecord
  include Entryable
end
```

Com essa definição completa, nosso delegador `Entry` agora fornece os seguintes métodos:

| Método | Retorno |
|---|---|
| `Entry#entryable_class` | Message ou Comment |
| `Entry#entryable_name` | "message" ou "comment" |
| `Entry.messages` | `Entry.where(entryable_type: "Message")` |
| `Entry#message?` | Retorna true quando `entryable_type == "Message"` |
| `Entry#message` | Retorna o registro de mensagem, quando `entryable_type == "Message"`, caso contrário, `nil` |
| `Entry#message_id` | Retorna `entryable_id`, quando `entryable_type == "Message"`, caso contrário, `nil` |
| `Entry.comments` | `Entry.where(entryable_type: "Comment")` |
| `Entry#comment?` | Retorna true quando `entryable_type == "Comment"` |
| `Entry#comment` | Retorna o registro de comentário, quando `entryable_type == "Comment"`, caso contrário, `nil` |
| `Entry#comment_id` | Retorna `entryable_id`, quando `entryable_type == "Comment"`, caso contrário, `nil` |

### Criação de objeto

Ao criar um novo objeto `Entry`, podemos especificar a subclasse `entryable` ao mesmo tempo.

```ruby
Entry.create! entryable: Message.new(subject: "hello!")
```

### Adicionando mais delegação

Podemos expandir nosso delegador `Entry` e aprimorá-lo ainda mais, definindo `delegates` e usando polimorfismo nas subclasses.
Por exemplo, para delegar o método `title` de `Entry` para suas subclasses:

```ruby
class Entry < ApplicationRecord
  delegated_type :entryable, types: %w[ Message Comment ]
  delegates :title, to: :entryable
end

class Message < ApplicationRecord
  include Entryable

  def title
    subject
  end
end

class Comment < ApplicationRecord
  include Entryable

  def title
    content.truncate(20)
  end
end
```

[`belongs_to`]: https://api.rubyonrails.org/classes/ActiveRecord/Associations/ClassMethods.html#method-i-belongs_to
[`has_and_belongs_to_many`]: https://api.rubyonrails.org/classes/ActiveRecord/Associations/ClassMethods.html#method-i-has_and_belongs_to_many
[`has_many`]: https://api.rubyonrails.org/classes/ActiveRecord/Associations/ClassMethods.html#method-i-has_many
[`has_one`]: https://api.rubyonrails.org/classes/ActiveRecord/Associations/ClassMethods.html#method-i-has_one
[connection.add_reference]: https://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html#method-i-add_reference
[foreign_keys]: active_record_migrations.html#foreign-keys
[`config.active_record.automatic_scope_inversing`]: configuring.html#config-active-record-automatic-scope-inversing
[`reset_counters`]: https://api.rubyonrails.org/classes/ActiveRecord/CounterCache/ClassMethods.html#method-i-reset_counters
[`collection<<`]: https://api.rubyonrails.org/classes/ActiveRecord/Associations/CollectionProxy.html#method-i-3C-3C
[`collection.build`]: https://api.rubyonrails.org/classes/ActiveRecord/Associations/CollectionProxy.html#method-i-build
[`collection.clear`]: https://api.rubyonrails.org/classes/ActiveRecord/Associations/CollectionProxy.html#method-i-clear
[`collection.create`]: https://api.rubyonrails.org/classes/ActiveRecord/Associations/CollectionProxy.html#method-i-create
[`collection.create!`]: https://api.rubyonrails.org/classes/ActiveRecord/Associations/CollectionProxy.html#method-i-create-21
[`collection.delete`]: https://api.rubyonrails.org/classes/ActiveRecord/Associations/CollectionProxy.html#method-i-delete
[`collection.destroy`]: https://api.rubyonrails.org/classes/ActiveRecord/Associations/CollectionProxy.html#method-i-destroy
[`collection.empty?`]: https://api.rubyonrails.org/classes/ActiveRecord/Associations/CollectionProxy.html#method-i-empty-3F
[`collection.exists?`]: https://api.rubyonrails.org/classes/ActiveRecord/FinderMethods.html#method-i-exists-3F
[`collection.find`]: https://api.rubyonrails.org/classes/ActiveRecord/Associations/CollectionProxy.html#method-i-find
[`collection.reload`]: https://api.rubyonrails.org/classes/ActiveRecord/Associations/CollectionProxy.html#method-i-reload
[`collection.size`]: https://api.rubyonrails.org/classes/ActiveRecord/Associations/CollectionProxy.html#method-i-size
[`collection.where`]: https://api.rubyonrails.org/classes/ActiveRecord/QueryMethods.html#method-i-where
