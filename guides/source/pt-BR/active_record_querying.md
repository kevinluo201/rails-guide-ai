**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: cc70f06da31561d3461720649cc42371
Interface de Consulta do Active Record
========================================

Este guia aborda diferentes maneiras de recuperar dados do banco de dados usando o Active Record.

Após ler este guia, você saberá:

* Como encontrar registros usando uma variedade de métodos e condições.
* Como especificar a ordem, os atributos recuperados, o agrupamento e outras propriedades dos registros encontrados.
* Como usar o carregamento antecipado para reduzir o número de consultas ao banco de dados necessárias para a recuperação de dados.
* Como usar métodos de busca dinâmica.
* Como usar o encadeamento de métodos para usar vários métodos do Active Record juntos.
* Como verificar a existência de registros específicos.
* Como realizar vários cálculos em modelos do Active Record.
* Como executar o EXPLAIN em relações.

--------------------------------------------------------------------------------

O que é a Interface de Consulta do Active Record?
------------------------------------------------

Se você está acostumado a usar SQL bruto para encontrar registros de banco de dados, geralmente encontrará melhores maneiras de realizar as mesmas operações no Rails. O Active Record o isola da necessidade de usar SQL na maioria dos casos.

O Active Record executará consultas no banco de dados para você e é compatível com a maioria dos sistemas de banco de dados, incluindo MySQL, MariaDB, PostgreSQL e SQLite. Independentemente do sistema de banco de dados que você está usando, o formato do método Active Record será sempre o mesmo.

Os exemplos de código ao longo deste guia se referirão a um ou mais dos seguintes modelos:

DICA: Todos os modelos a seguir usam `id` como chave primária, a menos que especificado de outra forma.

```ruby
class Author < ApplicationRecord
  has_many :books, -> { order(year_published: :desc) }
end
```

```ruby
class Book < ApplicationRecord
  belongs_to :supplier
  belongs_to :author
  has_many :reviews
  has_and_belongs_to_many :orders, join_table: 'books_orders'

  scope :in_print, -> { where(out_of_print: false) }
  scope :out_of_print, -> { where(out_of_print: true) }
  scope :old, -> { where(year_published: ...50.years.ago.year) }
  scope :out_of_print_and_expensive, -> { out_of_print.where('price > 500') }
  scope :costs_more_than, ->(amount) { where('price > ?', amount) }
end
```

```ruby
class Customer < ApplicationRecord
  has_many :orders
  has_many :reviews
end
```

```ruby
class Order < ApplicationRecord
  belongs_to :customer
  has_and_belongs_to_many :books, join_table: 'books_orders'

  enum :status, [:shipped, :being_packed, :complete, :cancelled]

  scope :created_before, ->(time) { where(created_at: ...time) }
end
```

```ruby
class Review < ApplicationRecord
  belongs_to :customer
  belongs_to :book

  enum :state, [:not_reviewed, :published, :hidden]
end
```

```ruby
class Supplier < ApplicationRecord
  has_many :books
  has_many :authors, through: :books
end
```

![Diagrama de todos os modelos da livraria](images/active_record_querying/bookstore_models.png)

Recuperando Objetos do Banco de Dados
------------------------------------

Para recuperar objetos do banco de dados, o Active Record fornece vários métodos de busca. Cada método de busca permite que você passe argumentos para realizar determinadas consultas no seu banco de dados sem escrever SQL bruto.

Os métodos são:

* [`annotate`][]
* [`find`][]
* [`create_with`][]
* [`distinct`][]
* [`eager_load`][]
* [`extending`][]
* [`extract_associated`][]
* [`from`][]
* [`group`][]
* [`having`][]
* [`includes`][]
* [`joins`][]
* [`left_outer_joins`][]
* [`limit`][]
* [`lock`][]
* [`none`][]
* [`offset`][]
* [`optimizer_hints`][]
* [`order`][]
* [`preload`][]
* [`readonly`][]
* [`references`][]
* [`reorder`][]
* [`reselect`][]
* [`regroup`][]
* [`reverse_order`][]
* [`select`][]
* [`where`][]

Métodos de busca que retornam uma coleção, como `where` e `group`, retornam uma instância de [`ActiveRecord::Relation`][]. Métodos que encontram uma única entidade, como `find` e `first`, retornam uma única instância do modelo.

A operação principal de `Model.find(options)` pode ser resumida como:

* Converter as opções fornecidas em uma consulta SQL equivalente.
* Executar a consulta SQL e recuperar os resultados correspondentes do banco de dados.
* Instanciar o objeto Ruby equivalente do modelo apropriado para cada linha resultante.
* Executar os callbacks `after_find` e depois `after_initialize`, se houver.


### Recuperando um Único Objeto

O Active Record fornece várias maneiras diferentes de recuperar um único objeto.

#### `find`

Usando o método [`find`][], você pode recuperar o objeto correspondente à _chave primária_ especificada que corresponda a quaisquer opções fornecidas. Por exemplo:

```irb
# Encontre o cliente com a chave primária (id) 10.
irb> customer = Customer.find(10)
=> #<Customer id: 10, first_name: "Ryan">
```

O equivalente SQL do exemplo acima é:

```sql
SELECT * FROM customers WHERE (customers.id = 10) LIMIT 1
```

O método `find` lançará uma exceção `ActiveRecord::RecordNotFound` se nenhum registro correspondente for encontrado.

Você também pode usar este método para consultar vários objetos. Chame o método `find` e passe um array de chaves primárias. O retorno será um array contendo todos os registros correspondentes às chaves primárias fornecidas. Por exemplo:
```irb
# Encontre os clientes com chaves primárias 1 e 10.
irb> customers = Customer.find([1, 10]) # OU Customer.find(1, 10)
=> [#<Customer id: 1, first_name: "Lifo">, #<Customer id: 10, first_name: "Ryan">]
```

O equivalente SQL do código acima é:

```sql
SELECT * FROM customers WHERE (customers.id IN (1,10))
```

ATENÇÃO: O método `find` lançará uma exceção `ActiveRecord::RecordNotFound` a menos que um registro correspondente seja encontrado para **todas** as chaves primárias fornecidas.

#### `take`

O método [`take`][] recupera um registro sem nenhuma ordenação implícita. Por exemplo:

```irb
irb> customer = Customer.take
=> #<Customer id: 1, first_name: "Lifo">
```

O equivalente SQL do código acima é:

```sql
SELECT * FROM customers LIMIT 1
```

O método `take` retorna `nil` se nenhum registro for encontrado e nenhuma exceção será lançada.

Você pode passar um argumento numérico para o método `take` para retornar até esse número de resultados. Por exemplo:

```irb
irb> customers = Customer.take(2)
=> [#<Customer id: 1, first_name: "Lifo">, #<Customer id: 220, first_name: "Sara">]
```

O equivalente SQL do código acima é:

```sql
SELECT * FROM customers LIMIT 2
```

O método [`take!`][] se comporta exatamente como `take`, exceto que ele lançará `ActiveRecord::RecordNotFound` se nenhum registro correspondente for encontrado.

DICA: O registro recuperado pode variar dependendo do mecanismo de banco de dados.


#### `first`

O método [`first`][] encontra o primeiro registro ordenado pela chave primária (padrão). Por exemplo:

```irb
irb> customer = Customer.first
=> #<Customer id: 1, first_name: "Lifo">
```

O equivalente SQL do código acima é:

```sql
SELECT * FROM customers ORDER BY customers.id ASC LIMIT 1
```

O método `first` retorna `nil` se nenhum registro correspondente for encontrado e nenhuma exceção será lançada.

Se o seu [escopo padrão](active_record_querying.html#applying-a-default-scope) contiver um método de ordenação, `first` retornará o primeiro registro de acordo com essa ordenação.

Você pode passar um argumento numérico para o método `first` para retornar até esse número de resultados. Por exemplo:

```irb
irb> customers = Customer.first(3)
=> [#<Customer id: 1, first_name: "Lifo">, #<Customer id: 2, first_name: "Fifo">, #<Customer id: 3, first_name: "Filo">]
```

O equivalente SQL do código acima é:

```sql
SELECT * FROM customers ORDER BY customers.id ASC LIMIT 3
```

Em uma coleção que é ordenada usando `order`, `first` retornará o primeiro registro ordenado pelo atributo especificado para `order`.

```irb
irb> customer = Customer.order(:first_name).first
=> #<Customer id: 2, first_name: "Fifo">
```

O equivalente SQL do código acima é:

```sql
SELECT * FROM customers ORDER BY customers.first_name ASC LIMIT 1
```

O método [`first!`][] se comporta exatamente como `first`, exceto que ele lançará `ActiveRecord::RecordNotFound` se nenhum registro correspondente for encontrado.


#### `last`

O método [`last`][] encontra o último registro ordenado pela chave primária (padrão). Por exemplo:

```irb
irb> customer = Customer.last
=> #<Customer id: 221, first_name: "Russel">
```

O equivalente SQL do código acima é:

```sql
SELECT * FROM customers ORDER BY customers.id DESC LIMIT 1
```

O método `last` retorna `nil` se nenhum registro correspondente for encontrado e nenhuma exceção será lançada.

Se o seu [escopo padrão](active_record_querying.html#applying-a-default-scope) contiver um método de ordenação, `last` retornará o último registro de acordo com essa ordenação.

Você pode passar um argumento numérico para o método `last` para retornar até esse número de resultados. Por exemplo:

```irb
irb> customers = Customer.last(3)
=> [#<Customer id: 219, first_name: "James">, #<Customer id: 220, first_name: "Sara">, #<Customer id: 221, first_name: "Russel">]
```

O equivalente SQL do código acima é:

```sql
SELECT * FROM customers ORDER BY customers.id DESC LIMIT 3
```

Em uma coleção que é ordenada usando `order`, `last` retornará o último registro ordenado pelo atributo especificado para `order`.

```irb
irb> customer = Customer.order(:first_name).last
=> #<Customer id: 220, first_name: "Sara">
```

O equivalente SQL do código acima é:

```sql
SELECT * FROM customers ORDER BY customers.first_name DESC LIMIT 1
```

O método [`last!`][] se comporta exatamente como `last`, exceto que ele lançará `ActiveRecord::RecordNotFound` se nenhum registro correspondente for encontrado.


#### `find_by`

O método [`find_by`][] encontra o primeiro registro que corresponde a algumas condições. Por exemplo:

```irb
irb> Customer.find_by first_name: 'Lifo'
=> #<Customer id: 1, first_name: "Lifo">

irb> Customer.find_by first_name: 'Jon'
=> nil
```

É equivalente a escrever:

```ruby
Customer.where(first_name: 'Lifo').take
```

O equivalente SQL do código acima é:

```sql
SELECT * FROM customers WHERE (customers.first_name = 'Lifo') LIMIT 1
```
Observe que não há `ORDER BY` no SQL acima. Se suas condições `find_by` puderem corresponder a vários registros, você deve [aplicar uma ordem](#ordering) para garantir um resultado determinístico.

O método [`find_by!`][] se comporta exatamente como `find_by`, exceto que ele lançará `ActiveRecord::RecordNotFound` se nenhum registro correspondente for encontrado. Por exemplo:

```irb
irb> Customer.find_by! first_name: 'does not exist'
ActiveRecord::RecordNotFound
```

Isso é equivalente a escrever:

```ruby
Customer.where(first_name: 'does not exist').take!
```


### Recuperando Múltiplos Objetos em Lotes

Muitas vezes, precisamos iterar sobre um grande conjunto de registros, como quando enviamos um boletim informativo para um grande conjunto de clientes ou quando exportamos dados.

Isso pode parecer simples:

```ruby
# Isso pode consumir muita memória se a tabela for grande.
Customer.all.each do |customer|
  NewsMailer.weekly(customer).deliver_now
end
```

Mas essa abordagem se torna cada vez mais impraticável à medida que o tamanho da tabela aumenta, pois `Customer.all.each` instrui o Active Record a buscar _a tabela inteira_ em uma única passagem, construir um objeto de modelo por linha e, em seguida, manter o array inteiro de objetos de modelo na memória. De fato, se tivermos um grande número de registros, a coleção inteira pode exceder a quantidade de memória disponível.

O Rails fornece dois métodos que resolvem esse problema dividindo os registros em lotes amigáveis à memória para processamento. O primeiro método, `find_each`, recupera um lote de registros e, em seguida, fornece _cada_ registro para o bloco individualmente como um modelo. O segundo método, `find_in_batches`, recupera um lote de registros e, em seguida, fornece _o lote inteiro_ para o bloco como um array de modelos.

DICA: Os métodos `find_each` e `find_in_batches` são destinados ao processamento em lote de um grande número de registros que não caberiam na memória de uma só vez. Se você apenas precisa percorrer mil registros, os métodos de busca regulares são a opção preferida.

#### `find_each`

O método [`find_each`][] recupera registros em lotes e, em seguida, fornece _cada_ um para o bloco. No exemplo a seguir, `find_each` recupera clientes em lotes de 1000 e os fornece para o bloco um por um:

```ruby
Customer.find_each do |customer|
  NewsMailer.weekly(customer).deliver_now
end
```

Esse processo é repetido, buscando mais lotes conforme necessário, até que todos os registros tenham sido processados.

`find_each` funciona em classes de modelo, como visto acima, e também em relações:

```ruby
Customer.where(weekly_subscriber: true).find_each do |customer|
  NewsMailer.weekly(customer).deliver_now
end
```

desde que não tenham ordenação, pois o método precisa forçar uma ordem internamente para iterar.

Se uma ordem estiver presente no receptor, o comportamento depende da flag
[`config.active_record.error_on_ignored_order`][]. Se for verdadeiro, `ArgumentError` é
lançado, caso contrário, a ordem é ignorada e um aviso é emitido, que é o
padrão. Isso pode ser substituído pela opção `:error_on_ignore`, explicada
abaixo.


##### Opções para `find_each`

**`:batch_size`**

A opção `:batch_size` permite especificar o número de registros a serem recuperados em cada lote, antes de serem passados individualmente para o bloco. Por exemplo, para recuperar registros em lotes de 5000:

```ruby
Customer.find_each(batch_size: 5000) do |customer|
  NewsMailer.weekly(customer).deliver_now
end
```

**`:start`**

Por padrão, os registros são buscados em ordem ascendente da chave primária. A opção `:start` permite configurar o primeiro ID da sequência sempre que o ID mais baixo não for o que você precisa. Isso seria útil, por exemplo, se você quisesse retomar um processo em lote interrompido, desde que você tenha salvo o último ID processado como um ponto de verificação.

Por exemplo, para enviar boletins apenas para clientes com a chave primária a partir de 2000:

```ruby
Customer.find_each(start: 2000) do |customer|
  NewsMailer.weekly(customer).deliver_now
end
```

**`:finish`**

Semelhante à opção `:start`, `:finish` permite configurar o último ID da sequência sempre que o ID mais alto não for o que você precisa.
Isso seria útil, por exemplo, se você quisesse executar um processo em lote usando um subconjunto de registros com base em `:start` e `:finish`.

Por exemplo, para enviar boletins apenas para clientes com a chave primária a partir de 2000 até 10000:

```ruby
Customer.find_each(start: 2000, finish: 10000) do |customer|
  NewsMailer.weekly(customer).deliver_now
end
```

Outro exemplo seria se você quisesse que vários trabalhadores manipulassem a mesma
fila de processamento. Você poderia fazer com que cada trabalhador manipulasse 10000 registros, definindo as opções `:start` e `:finish` apropriadas em cada trabalhador.

**`:error_on_ignore`**

Substitui a configuração do aplicativo para especificar se um erro deve ser lançado quando uma
ordem está presente na relação.

**`:order`**

Especifica a ordem da chave primária (pode ser `:asc` ou `:desc`). O padrão é `:asc`.
```ruby
Customer.find_each(order: :desc) do |customer|
  NewsMailer.weekly(customer).deliver_now
end
```

#### `find_in_batches`

O método [`find_in_batches`][] é semelhante ao `find_each`, pois ambos recuperam lotes de registros. A diferença é que `find_in_batches` retorna _batches_ para o bloco como um array de modelos, em vez de individualmente. O exemplo a seguir retornará para o bloco fornecido um array de até 1000 clientes por vez, com o último bloco contendo os clientes restantes:

```ruby
# Dê a add_customers um array de 1000 clientes por vez.
Customer.find_in_batches do |customers|
  export.add_customers(customers)
end
```

`find_in_batches` funciona em classes de modelo, como visto acima, e também em relações:

```ruby
# Dê a add_customers um array de 1000 clientes recentemente ativos por vez.
Customer.recently_active.find_in_batches do |customers|
  export.add_customers(customers)
end
```

desde que não tenham ordenação, pois o método precisa forçar uma ordem internamente para iterar.


##### Opções para `find_in_batches`

O método `find_in_batches` aceita as mesmas opções que `find_each`:

**`:batch_size`**

Assim como para `find_each`, `batch_size` estabelece quantos registros serão recuperados em cada grupo. Por exemplo, recuperar lotes de 2500 registros pode ser especificado como:

```ruby
Customer.find_in_batches(batch_size: 2500) do |customers|
  export.add_customers(customers)
end
```

**`:start`**

A opção `start` permite especificar o ID inicial de onde os registros serão selecionados. Como mencionado anteriormente, por padrão, os registros são buscados em ordem ascendente da chave primária. Por exemplo, para recuperar clientes a partir do ID: 5000 em lotes de 2500 registros, o seguinte código pode ser usado:

```ruby
Customer.find_in_batches(batch_size: 2500, start: 5000) do |customers|
  export.add_customers(customers)
end
```

**`:finish`**

A opção `finish` permite especificar o ID final dos registros a serem recuperados. O código abaixo mostra o caso de recuperar clientes em lotes, até o cliente com ID: 7000:

```ruby
Customer.find_in_batches(finish: 7000) do |customers|
  export.add_customers(customers)
end
```

**`:error_on_ignore`**

A opção `error_on_ignore` substitui a configuração do aplicativo para especificar se um erro deve ser gerado quando uma ordem específica está presente na relação.

Condições
----------

O método [`where`][] permite especificar condições para limitar os registros retornados, representando a parte `WHERE` da instrução SQL. As condições podem ser especificadas como uma string, array ou hash.

### Condições de String Pura

Se você deseja adicionar condições à sua consulta, pode especificá-las lá, assim como `Book.where("title = 'Introduction to Algorithms'")`. Isso encontrará todos os livros em que o valor do campo `title` é 'Introduction to Algorithms'.

ATENÇÃO: Construir suas próprias condições como strings puras pode deixar você vulnerável a ataques de injeção de SQL. Por exemplo, `Book.where("title LIKE '%#{params[:title]}%'")` não é seguro. Consulte a próxima seção para saber a maneira preferida de lidar com condições usando um array.

### Condições de Array

Agora, e se esse título pudesse variar, digamos como um argumento de algum lugar? A consulta ficaria assim:

```ruby
Book.where("title = ?", params[:title])
```

O ActiveRecord considerará o primeiro argumento como a string de condições e quaisquer argumentos adicionais substituirão os pontos de interrogação `(?)` nela.

Se você quiser especificar várias condições:

```ruby
Book.where("title = ? AND out_of_print = ?", params[:title], false)
```

Neste exemplo, o primeiro ponto de interrogação será substituído pelo valor em `params[:title]` e o segundo será substituído pela representação SQL de `false`, que depende do adaptador.

Este código é altamente preferível:

```ruby
Book.where("title = ?", params[:title])
```

em relação a este código:

```ruby
Book.where("title = #{params[:title]}")
```

por causa da segurança dos argumentos. Colocar a variável diretamente na string de condições passará a variável para o banco de dados **como está**. Isso significa que será uma variável não escapada diretamente de um usuário que pode ter intenções maliciosas. Se você fizer isso, colocará todo o seu banco de dados em risco, porque, uma vez que um usuário descobrir que pode explorar seu banco de dados, ele poderá fazer qualquer coisa com ele. Nunca coloque seus argumentos diretamente dentro da string de condições.

DICA: Para obter mais informações sobre os perigos da injeção de SQL, consulte o [Guia de Segurança do Ruby on Rails](security.html#sql-injection).

#### Condições de Espaço Reservado

Semelhante ao estilo de substituição `(?)` de parâmetros, você também pode especificar chaves em sua string de condições junto com um hash de chaves/valores correspondentes:

```ruby
Book.where("created_at >= :start_date AND created_at <= :end_date",
  { start_date: params[:start_date], end_date: params[:end_date] })
```

Isso torna a leitura mais clara se você tiver um grande número de condições variáveis.

#### Condições que Usam `LIKE`

Embora os argumentos das condições sejam automaticamente escapados para evitar a injeção de SQL, os curingas `LIKE` do SQL (ou seja, `%` e `_`) **não** são escapados. Isso pode causar comportamento inesperado se um valor não sanitizado for usado em um argumento. Por exemplo:
```ruby
Book.order(:title).order(:created_at)
```

This will generate SQL like this:

```sql
SELECT * FROM books ORDER BY title ASC, created_at ASC
```

You can also use the `reorder` method to replace any existing order with a new one:

```ruby
Book.order(:title).reorder(:created_at)
```

This will generate SQL like this:

```sql
SELECT * FROM books ORDER BY created_at ASC
```

### Limit and Offset

To limit the number of records returned from the database, you can use the [`limit`][] method. For example, to retrieve the first 10 books:

```ruby
Book.limit(10)
```

This will generate SQL like this:

```sql
SELECT * FROM books LIMIT 10
```

To skip a certain number of records and retrieve the rest, you can use the [`offset`][] method. For example, to retrieve books starting from the 11th record:

```ruby
Book.offset(10)
```

This will generate SQL like this:

```sql
SELECT * FROM books OFFSET 10
```

You can also chain `limit` and `offset` together to paginate through records:

```ruby
Book.limit(10).offset(20)
```

This will generate SQL like this:

```sql
SELECT * FROM books LIMIT 10 OFFSET 20
```

### Locking Records

Active Record allows you to lock records when querying the database. This can be useful in scenarios where you want to prevent other processes from modifying the same records while you're working with them.

To lock records, you can use the [`lock`][] method. For example, to lock a book record:

```ruby
book = Book.find(1)
book.lock!
```

This will generate SQL like this:

```sql
SELECT * FROM books WHERE books.id = 1 FOR UPDATE
```

You can also use the `lock` method directly in a query:

```ruby
Book.lock.find(1)
```

This will generate the same SQL as above.

### Selecting Specific Fields

By default, Active Record retrieves all columns from the database table when querying records. However, in some cases, you may only need to retrieve specific fields.

To select specific fields, you can use the [`select`][] method. For example, to retrieve only the `title` and `author` fields from the books table:

```ruby
Book.select(:title, :author)
```

This will generate SQL like this:

```sql
SELECT title, author FROM books
```

You can also use the `select` method with other query methods:

```ruby
Book.select(:title, :author).where(out_of_print: true)
```

This will generate SQL like this:

```sql
SELECT title, author FROM books WHERE (books.out_of_print = 1)
```

### Grouping and Counting

Active Record allows you to group records and perform aggregate functions like counting.

To group records, you can use the [`group`][] method. For example, to group books by their `author` field:

```ruby
Book.group(:author)
```

This will generate SQL like this:

```sql
SELECT * FROM books GROUP BY books.author
```

To perform aggregate functions like counting, you can use the [`count`][] method. For example, to count the number of books in each group:

```ruby
Book.group(:author).count
```

This will generate SQL like this:

```sql
SELECT books.author, COUNT(*) AS count FROM books GROUP BY books.author
```

You can also use the `group` and `count` methods together with other query methods:

```ruby
Book.group(:author).where(out_of_print: true).count
```

This will generate SQL like this:

```sql
SELECT books.author, COUNT(*) AS count FROM books WHERE (books.out_of_print = 1) GROUP BY books.author
```

### Joins

Active Record allows you to perform joins between tables in the database.

To perform a join, you can use the [`joins`][] method. For example, to join the books table with the authors table:

```ruby
Book.joins(:author)
```

This will generate SQL like this:

```sql
SELECT books.* FROM books INNER JOIN authors ON authors.id = books.author_id
```

You can also specify the type of join to perform:

```ruby
Book.joins("INNER JOIN authors ON authors.id = books.author_id")
```

This will generate the same SQL as above.

### Eager Loading Associations

Active Record allows you to eager load associations to avoid the N+1 query problem.

To eager load associations, you can use the [`includes`][] method. For example, to eager load the author association for a set of books:

```ruby
Book.includes(:author)
```

This will generate SQL like this:

```sql
SELECT * FROM books LEFT OUTER JOIN authors ON authors.id = books.author_id
```

You can also specify multiple associations to eager load:

```ruby
Book.includes(:author, :publisher)
```

This will generate SQL like this:

```sql
SELECT * FROM books LEFT OUTER JOIN authors ON authors.id = books.author_id LEFT OUTER JOIN publishers ON publishers.id = books.publisher_id
```

### Conclusion

Active Record provides a powerful and flexible query interface for interacting with databases in Ruby on Rails. By understanding and utilizing the various query methods available, you can write efficient and concise database queries for your application.
```irb
irb> Book.order("title ASC").order("created_at DESC")
SELECT * FROM books ORDER BY title ASC, created_at DESC
```

AVISO: Na maioria dos sistemas de banco de dados, ao selecionar campos com `distinct` de um conjunto de resultados usando métodos como `select`, `pluck` e `ids`; o método `order` lançará uma exceção `ActiveRecord::StatementInvalid` a menos que o(s) campo(s) usado(s) na cláusula `order` estejam incluídos na lista de seleção. Veja a próxima seção para selecionar campos do conjunto de resultados.

Selecionando Campos Específicos
-------------------------

Por padrão, `Model.find` seleciona todos os campos do conjunto de resultados usando `select *`.

Para selecionar apenas um subconjunto de campos do conjunto de resultados, você pode especificar o subconjunto através do método [`select`][].

Por exemplo, para selecionar apenas as colunas `isbn` e `out_of_print`:

```ruby
Book.select(:isbn, :out_of_print)
# OU
Book.select("isbn, out_of_print")
```

A consulta SQL usada por essa chamada de busca será algo como:

```sql
SELECT isbn, out_of_print FROM books
```

Tenha cuidado, pois isso também significa que você está inicializando um objeto de modelo apenas com os campos que você selecionou. Se você tentar acessar um campo que não está no registro inicializado, você receberá:

```
ActiveModel::MissingAttributeError: missing attribute '<attribute>' for Book
```

Onde `<attribute>` é o atributo que você solicitou. O método `id` não lançará a exceção `ActiveRecord::MissingAttributeError`, então tenha cuidado ao trabalhar com associações, pois elas precisam do método `id` para funcionar corretamente.

Se você deseja apenas pegar um único registro por valor único em um determinado campo, você pode usar [`distinct`][]:

```ruby
Customer.select(:last_name).distinct
```

Isso geraria SQL como:

```sql
SELECT DISTINCT last_name FROM customers
```

Você também pode remover a restrição de unicidade:

```ruby
# Retorna last_names únicos
query = Customer.select(:last_name).distinct

# Retorna todos os last_names, mesmo que haja duplicatas
query.distinct(false)
```

Limite e Deslocamento
----------------

Para aplicar o `LIMIT` ao SQL disparado pelo `Model.find`, você pode especificar o `LIMIT` usando os métodos [`limit`][] e [`offset`][] na relação.

Você pode usar `limit` para especificar o número de registros a serem recuperados e usar `offset` para especificar o número de registros a serem ignorados antes de começar a retornar os registros. Por exemplo

```ruby
Customer.limit(5)
```

retornará no máximo 5 clientes e, como não especifica deslocamento, retornará os primeiros 5 da tabela. O SQL executado será assim:

```sql
SELECT * FROM customers LIMIT 5
```

Adicionando `offset` a isso

```ruby
Customer.limit(5).offset(30)
```

retornará, em vez disso, no máximo 5 clientes começando pelo 31º. O SQL será assim:

```sql
SELECT * FROM customers LIMIT 5 OFFSET 30
```

Agrupamento
--------

Para aplicar uma cláusula `GROUP BY` ao SQL disparado pelo localizador, você pode usar o método [`group`][].

Por exemplo, se você quiser encontrar uma coleção das datas em que os pedidos foram criados:

```ruby
Order.select("created_at").group("created_at")
```

E isso lhe dará um único objeto `Order` para cada data em que houver pedidos no banco de dados.

O SQL que seria executado seria algo como isso:

```sql
SELECT created_at
FROM orders
GROUP BY created_at
```

### Total de Itens Agrupados

Para obter o total de itens agrupados em uma única consulta, chame [`count`][] após o `group`.

```irb
irb> Order.group(:status).count
=> {"being_packed"=>7, "shipped"=>12}
```

O SQL que seria executado seria algo como isso:

```sql
SELECT COUNT (*) AS count_all, status AS status
FROM orders
GROUP BY status
```


### Condições HAVING

O SQL usa a cláusula `HAVING` para especificar condições nos campos `GROUP BY`. Você pode adicionar a cláusula `HAVING` ao SQL disparado pelo `Model.find` adicionando o método [`having`][] à busca.

Por exemplo:

```ruby
Order.select("created_at, sum(total) as total_price").
  group("created_at").having("sum(total) > ?", 200)
```

O SQL que seria executado seria algo como isso:

```sql
SELECT created_at as ordered_date, sum(total) as total_price
FROM orders
GROUP BY created_at
HAVING sum(total) > 200
```

Isso retorna a data e o preço total para cada objeto de pedido, agrupados pelo dia em que foram encomendados e onde o total é superior a $200.

Você pode acessar o `total_price` para cada objeto de pedido retornado assim:

```ruby
big_orders = Order.select("created_at, sum(total) as total_price")
                  .group("created_at")
                  .having("sum(total) > ?", 200)

big_orders[0].total_price
# Retorna o preço total para o primeiro objeto de Pedido
```

Substituindo Condições
---------------------

### `unscope`

Você pode especificar certas condições a serem removidas usando o método [`unscope`][]. Por exemplo:
```ruby
Book.where('id > 100').limit(20).order('id desc').unscope(:order)
```

O SQL que seria executado:

```sql
SELECT * FROM books WHERE id > 100 LIMIT 20

-- Consulta original sem `unscope`
SELECT * FROM books WHERE id > 100 ORDER BY id desc LIMIT 20
```

Você também pode remover cláusulas `where` específicas. Por exemplo, isso removerá a condição `id` da cláusula where:

```ruby
Book.where(id: 10, out_of_print: false).unscope(where: :id)
# SELECT books.* FROM books WHERE out_of_print = 0
```

Uma relação que usou `unscope` afetará qualquer relação na qual ela é mesclada:

```ruby
Book.order('id desc').merge(Book.unscope(:order))
# SELECT books.* FROM books
```


### `only`

Você também pode substituir condições usando o método [`only`][]. Por exemplo:

```ruby
Book.where('id > 10').limit(20).order('id desc').only(:order, :where)
```

O SQL que seria executado:

```sql
SELECT * FROM books WHERE id > 10 ORDER BY id DESC

-- Consulta original sem `only`
SELECT * FROM books WHERE id > 10 ORDER BY id DESC LIMIT 20
```


### `reselect`

O método [`reselect`][] substitui uma declaração de seleção existente. Por exemplo:

```ruby
Book.select(:title, :isbn).reselect(:created_at)
```

O SQL que seria executado:

```sql
SELECT books.created_at FROM books
```

Compare isso com o caso em que a cláusula `reselect` não é usada:

```ruby
Book.select(:title, :isbn).select(:created_at)
```

o SQL executado seria:

```sql
SELECT books.title, books.isbn, books.created_at FROM books
```

### `reorder`

O método [`reorder`][] substitui a ordem do escopo padrão. Por exemplo, se a definição da classe incluir isso:

```ruby
class Author < ApplicationRecord
  has_many :books, -> { order(year_published: :desc) }
end
```

E você executar isso:

```ruby
Author.find(10).books
```

O SQL que seria executado:

```sql
SELECT * FROM authors WHERE id = 10 LIMIT 1
SELECT * FROM books WHERE author_id = 10 ORDER BY year_published DESC
```

Você pode usar a cláusula `reorder` para especificar uma maneira diferente de ordenar os livros:

```ruby
Author.find(10).books.reorder('year_published ASC')
```

O SQL que seria executado:

```sql
SELECT * FROM authors WHERE id = 10 LIMIT 1
SELECT * FROM books WHERE author_id = 10 ORDER BY year_published ASC
```

### `reverse_order`

O método [`reverse_order`][] inverte a cláusula de ordenação, se especificada.

```ruby
Book.where("author_id > 10").order(:year_published).reverse_order
```

O SQL que seria executado:

```sql
SELECT * FROM books WHERE author_id > 10 ORDER BY year_published DESC
```

Se nenhuma cláusula de ordenação for especificada na consulta, o `reverse_order` ordena pela chave primária em ordem reversa.

```ruby
Book.where("author_id > 10").reverse_order
```

O SQL que seria executado:

```sql
SELECT * FROM books WHERE author_id > 10 ORDER BY books.id DESC
```

O método `reverse_order` não aceita **nenhum** argumento.

### `rewhere`

O método [`rewhere`][] substitui uma condição `where` nomeada existente. Por exemplo:

```ruby
Book.where(out_of_print: true).rewhere(out_of_print: false)
```

O SQL que seria executado:

```sql
SELECT * FROM books WHERE out_of_print = 0
```

Se a cláusula `rewhere` não for usada, as cláusulas where são combinadas com AND:

```ruby
Book.where(out_of_print: true).where(out_of_print: false)
```

o SQL executado seria:

```sql
SELECT * FROM books WHERE out_of_print = 1 AND out_of_print = 0
```



### `regroup`

O método [`regroup`][] substitui uma condição `group` nomeada existente. Por exemplo:

```ruby
Book.group(:author).regroup(:id)
```

O SQL que seria executado:

```sql
SELECT * FROM books GROUP BY id
```

Se a cláusula `regroup` não for usada, as cláusulas de grupo são combinadas:

```ruby
Book.group(:author).group(:id)
```

o SQL executado seria:

```sql
SELECT * FROM books GROUP BY author, id
```



Relação Nula
-------------

O método [`none`][] retorna uma relação encadeável sem registros. Quaisquer condições subsequentes encadeadas à relação retornada continuarão gerando relações vazias. Isso é útil em cenários em que você precisa de uma resposta encadeável para um método ou escopo que pode retornar zero resultados.

```ruby
Book.none # retorna uma Relação vazia e não executa consultas.
```

```ruby
# O método highlighted_reviews abaixo deve sempre retornar uma Relação.
Book.first.highlighted_reviews.average(:rating)
# => Retorna a média de avaliação de um livro

class Book
  # Retorna as avaliações se houver pelo menos 5,
  # caso contrário, considere este como um livro não avaliado
  def highlighted_reviews
    if reviews.count > 5
      reviews
    else
      Review.none # Ainda não atende ao limite mínimo
    end
  end
end
```

Objetos Somente Leitura
-----------------------

O Active Record fornece o método [`readonly`][] em uma relação para explicitamente impedir a modificação de qualquer um dos objetos retornados. Qualquer tentativa de alterar um registro somente leitura não terá sucesso, levantando uma exceção `ActiveRecord::ReadOnlyRecord`.
```ruby
customer = Customer.readonly.first
customer.visits += 1
customer.save
```

Como o objeto `customer` está explicitamente definido como somente leitura, o código acima irá gerar uma exceção `ActiveRecord::ReadOnlyRecord` ao chamar `customer.save` com um valor atualizado para _visits_.

Bloqueando Registros para Atualização
------------------------------------

Bloquear registros é útil para evitar condições de corrida ao atualizar registros no banco de dados e garantir atualizações atômicas.

O Active Record fornece dois mecanismos de bloqueio:

* Bloqueio Otimista
* Bloqueio Pessimista

### Bloqueio Otimista

O bloqueio otimista permite que vários usuários acessem o mesmo registro para edições e pressupõe um mínimo de conflitos com os dados. Ele faz isso verificando se outro processo fez alterações em um registro desde que ele foi aberto. Uma exceção `ActiveRecord::StaleObjectError` é lançada se isso ocorrer e a atualização é ignorada.

**Coluna de bloqueio otimista**

Para usar o bloqueio otimista, a tabela precisa ter uma coluna chamada `lock_version` do tipo inteiro. Sempre que o registro é atualizado, o Active Record incrementa a coluna `lock_version`. Se uma solicitação de atualização for feita com um valor menor no campo `lock_version` do que o valor atualmente na coluna `lock_version` no banco de dados, a solicitação de atualização falhará com uma exceção `ActiveRecord::StaleObjectError`.

Por exemplo:

```ruby
c1 = Customer.find(1)
c2 = Customer.find(1)

c1.first_name = "Sandra"
c1.save

c2.first_name = "Michael"
c2.save # Gera uma exceção ActiveRecord::StaleObjectError
```

Você é responsável por lidar com o conflito, resgatando a exceção e fazendo rollback, mesclando ou aplicando a lógica de negócios necessária para resolver o conflito.

Esse comportamento pode ser desativado definindo `ActiveRecord::Base.lock_optimistically = false`.

Para substituir o nome da coluna `lock_version`, `ActiveRecord::Base` fornece um atributo de classe chamado `locking_column`:

```ruby
class Customer < ApplicationRecord
  self.locking_column = :lock_customer_column
end
```

### Bloqueio Pessimista

O bloqueio pessimista usa um mecanismo de bloqueio fornecido pelo banco de dados subjacente. Usar `lock` ao construir uma relação obtém um bloqueio exclusivo nas linhas selecionadas. As relações que usam `lock` geralmente são envolvidas em uma transação para evitar condições de deadlock.

Por exemplo:

```ruby
Book.transaction do
  book = Book.lock.first
  book.title = 'Algorithms, second edition'
  book.save!
end
```

A sessão acima produz a seguinte SQL para um banco de dados MySQL:

```sql
SQL (0.2ms)   BEGIN
Book Load (0.3ms)   SELECT * FROM books LIMIT 1 FOR UPDATE
Book Update (0.4ms)   UPDATE books SET updated_at = '2009-02-07 18:05:56', title = 'Algorithms, second edition' WHERE id = 1
SQL (0.8ms)   COMMIT
```

Você também pode passar SQL bruto para o método `lock` para permitir diferentes tipos de bloqueios. Por exemplo, o MySQL tem uma expressão chamada `LOCK IN SHARE MODE` onde você pode bloquear um registro, mas ainda permitir que outras consultas o leiam. Para especificar essa expressão, basta passá-la como opção de bloqueio:

```ruby
Book.transaction do
  book = Book.lock("LOCK IN SHARE MODE").find(1)
  book.increment!(:views)
end
```

NOTA: Observe que seu banco de dados deve suportar o SQL bruto que você passa para o método `lock`.

Se você já tem uma instância do seu modelo, pode iniciar uma transação e adquirir o bloqueio de uma vez usando o seguinte código:

```ruby
book = Book.first
book.with_lock do
  # Este bloco é chamado dentro de uma transação,
  # o livro já está bloqueado.
  book.increment!(:views)
end
```

Unindo Tabelas
--------------

O Active Record fornece dois métodos de busca para especificar cláusulas `JOIN` no SQL resultante: `joins` e `left_outer_joins`.
Enquanto `joins` deve ser usado para `INNER JOIN` ou consultas personalizadas,
`left_outer_joins` é usado para consultas usando `LEFT OUTER JOIN`.

### `joins`

Existem várias maneiras de usar o método [`joins`][].

#### Usando um Fragmento de SQL em String

Você pode simplesmente fornecer o SQL bruto especificando a cláusula `JOIN` para `joins`:

```ruby
Author.joins("INNER JOIN books ON books.author_id = authors.id AND books.out_of_print = FALSE")
```

Isso resultará no seguinte SQL:

```sql
SELECT authors.* FROM authors INNER JOIN books ON books.author_id = authors.id AND books.out_of_print = FALSE
```

#### Usando Array/Hash de Associações Nomeadas

O Active Record permite que você use os nomes das [associações](association_basics.html) definidas no modelo como um atalho para especificar cláusulas `JOIN` para essas associações ao usar o método `joins`.

Todas as seguintes produzirão as consultas de junção esperadas usando `INNER JOIN`:

##### Unindo uma Única Associação

```ruby
Book.joins(:reviews)
```

Isso produz:

```sql
SELECT books.* FROM books
  INNER JOIN reviews ON reviews.book_id = books.id
```

Ou, em português: "retorne um objeto Book para todos os livros com avaliações". Observe que você verá livros duplicados se um livro tiver mais de uma avaliação. Se você quiser livros únicos, pode usar `Book.joins(:reviews).distinct`.
#### Unindo Múltiplas Associações

```ruby
Book.joins(:author, :reviews)
```

Isso produz:

```sql
SELECT books.* FROM books
  INNER JOIN authors ON authors.id = books.author_id
  INNER JOIN reviews ON reviews.book_id = books.id
```

Ou, em inglês: "retorne todos os livros com seus autores que possuem pelo menos uma avaliação". Note novamente que os livros com várias avaliações aparecerão várias vezes.

##### Unindo Associações Aninhadas (Nível Único)

```ruby
Book.joins(reviews: :customer)
```

Isso produz:

```sql
SELECT books.* FROM books
  INNER JOIN reviews ON reviews.book_id = books.id
  INNER JOIN customers ON customers.id = reviews.customer_id
```

Ou, em inglês: "retorne todos os livros que possuem uma avaliação feita por um cliente".

##### Unindo Associações Aninhadas (Múltiplos Níveis)

```ruby
Author.joins(books: [{ reviews: { customer: :orders } }, :supplier])
```

Isso produz:

```sql
SELECT * FROM authors
  INNER JOIN books ON books.author_id = authors.id
  INNER JOIN reviews ON reviews.book_id = books.id
  INNER JOIN customers ON customers.id = reviews.customer_id
  INNER JOIN orders ON orders.customer_id = customers.id
INNER JOIN suppliers ON suppliers.id = books.supplier_id
```

Ou, em inglês: "retorne todos os autores que possuem livros com avaliações _e_ foram encomendados por um cliente, e os fornecedores desses livros".

#### Especificando Condições nas Tabelas Unidas

Você pode especificar condições nas tabelas unidas usando as condições regulares de [Array](#array-conditions) e [String](#pure-string-conditions). As condições de [Hash](#hash-conditions) fornecem uma sintaxe especial para especificar condições para as tabelas unidas:

```ruby
time_range = (Time.now.midnight - 1.day)..Time.now.midnight
Customer.joins(:orders).where('orders.created_at' => time_range).distinct
```

Isso encontrará todos os clientes que possuem pedidos criados ontem, usando uma expressão SQL `BETWEEN` para comparar `created_at`.

Uma sintaxe alternativa e mais limpa é aninhar as condições de hash:

```ruby
time_range = (Time.now.midnight - 1.day)..Time.now.midnight
Customer.joins(:orders).where(orders: { created_at: time_range }).distinct
```

Para condições mais avançadas ou para reutilizar um escopo nomeado existente, [`merge`][] pode ser usado. Primeiro, vamos adicionar um novo escopo nomeado ao modelo `Order`:

```ruby
class Order < ApplicationRecord
  belongs_to :customer

  scope :created_in_time_range, ->(time_range) {
    where(created_at: time_range)
  }
end
```

Agora podemos usar `merge` para mesclar o escopo `created_in_time_range`:

```ruby
time_range = (Time.now.midnight - 1.day)..Time.now.midnight
Customer.joins(:orders).merge(Order.created_in_time_range(time_range)).distinct
```

Isso encontrará todos os clientes que possuem pedidos criados ontem, novamente usando uma expressão SQL `BETWEEN`.

### `left_outer_joins`

Se você deseja selecionar um conjunto de registros, independentemente de eles terem registros associados ou não, você pode usar o método [`left_outer_joins`][].

```ruby
Customer.left_outer_joins(:reviews).distinct.select('customers.*, COUNT(reviews.*) AS reviews_count').group('customers.id')
```

O que produz:

```sql
SELECT DISTINCT customers.*, COUNT(reviews.*) AS reviews_count FROM customers
LEFT OUTER JOIN reviews ON reviews.customer_id = customers.id GROUP BY customers.id
```

O que significa: "retorne todos os clientes com a contagem de suas avaliações, independentemente de eles terem ou não avaliações".

### `where.associated` e `where.missing`

Os métodos de consulta `associated` e `missing` permitem selecionar um conjunto de registros com base na presença ou ausência de uma associação.

Para usar `where.associated`:

```ruby
Customer.where.associated(:reviews)
```

Produz:

```sql
SELECT customers.* FROM customers
INNER JOIN reviews ON reviews.customer_id = customers.id
WHERE reviews.id IS NOT NULL
```

O que significa "retorne todos os clientes que fizeram pelo menos uma avaliação".

Para usar `where.missing`:

```ruby
Customer.where.missing(:reviews)
```

Produz:

```sql
SELECT customers.* FROM customers
LEFT OUTER JOIN reviews ON reviews.customer_id = customers.id
WHERE reviews.id IS NULL
```

O que significa "retorne todos os clientes que não fizeram nenhuma avaliação".


Carregamento Antecipado de Associações
--------------------------

O carregamento antecipado é o mecanismo para carregar os registros associados aos objetos retornados por `Model.find` usando o menor número possível de consultas.

### Problema de Consultas N + 1

Considere o seguinte código, que encontra 10 livros e imprime o sobrenome de seus autores:

```ruby
books = Book.limit(10)

books.each do |book|
  puts book.author.last_name
end
```

Este código parece bom à primeira vista. Mas o problema está no número total de consultas executadas. O código acima executa 1 (para encontrar 10 livros) + 10 (uma para cada livro para carregar o autor) = **11** consultas no total.

#### Solução para o Problema de Consultas N + 1

O Active Record permite que você especifique antecipadamente todas as associações que serão carregadas.

Os métodos são:

* [`includes`][]
* [`preload`][]
* [`eager_load`][]

### `includes`

Com `includes`, o Active Record garante que todas as associações especificadas sejam carregadas usando o menor número possível de consultas.

Revisitando o caso acima usando o método `includes`, poderíamos reescrever `Book.limit(10)` para carregar antecipadamente os autores:

```ruby
books = Book.includes(:author).limit(10)

books.each do |book|
  puts book.author.last_name
end
```
O código acima executará apenas **2** consultas, em oposição às **11** consultas do caso original:

```sql
SELECT books.* FROM books LIMIT 10
SELECT authors.* FROM authors
  WHERE authors.book_id IN (1,2,3,4,5,6,7,8,9,10)
```

#### Carregamento Antecipado de Múltiplas Associações

O Active Record permite carregar antecipadamente qualquer número de associações com uma única chamada `Model.find` usando um array, hash ou um hash aninhado de array/hash com o método `includes`.

##### Array de Múltiplas Associações

```ruby
Customer.includes(:orders, :reviews)
```

Isso carrega todos os clientes e os pedidos e avaliações associados para cada um.

##### Hash de Associações Aninhadas

```ruby
Customer.includes(orders: { books: [:supplier, :author] }).find(1)
```

Isso encontrará o cliente com o id 1 e carregará antecipadamente todos os pedidos associados a ele, os livros de todos os pedidos e o autor e fornecedor de cada livro.

#### Especificando Condições em Associações Carregadas Antecipadamente

Embora o Active Record permita especificar condições nas associações carregadas antecipadamente, assim como `joins`, a maneira recomendada é usar [joins](#joining-tables) em vez disso.

No entanto, se você precisar fazer isso, poderá usar `where` como faria normalmente.

```ruby
Author.includes(:books).where(books: { out_of_print: true })
```

Isso geraria uma consulta que contém um `LEFT OUTER JOIN`, enquanto o método `joins` geraria um usando a função `INNER JOIN` em vez disso.

```sql
  SELECT authors.id AS t0_r0, ... books.updated_at AS t1_r5 FROM authors LEFT OUTER JOIN books ON books.author_id = authors.id WHERE (books.out_of_print = 1)
```

Se não houver condição `where`, isso gerará o conjunto normal de duas consultas.

NOTA: Usar `where` dessa forma só funcionará quando você passar um Hash. Para
fragmentos SQL, você precisa usar `references` para forçar a junção de tabelas:

```ruby
Author.includes(:books).where("books.out_of_print = true").references(:books)
```

Se, no caso dessa consulta `includes`, não houver livros para nenhum
autor, todos os autores ainda serão carregados. Usando `joins` (um INNER
JOIN), as condições de junção **devem** corresponder, caso contrário, nenhum registro será
retornado.

NOTA: Se uma associação for carregada antecipadamente como parte de uma junção, nenhum campo de uma cláusula de seleção personalizada estará presente nos modelos carregados.
Isso ocorre porque é ambíguo se eles devem aparecer no registro pai ou no filho.

### `preload`

Com `preload`, o Active Record carrega cada associação especificada usando uma consulta por associação.

Revisitando o problema das consultas N + 1, poderíamos reescrever `Book.limit(10)` para carregar antecipadamente os autores:

```ruby
books = Book.preload(:author).limit(10)

books.each do |book|
  puts book.author.last_name
end
```

O código acima executará apenas **2** consultas, em oposição às **11** consultas do caso original:

```sql
SELECT books.* FROM books LIMIT 10
SELECT authors.* FROM authors
  WHERE authors.book_id IN (1,2,3,4,5,6,7,8,9,10)
```

NOTA: O método `preload` usa um array, hash ou um hash aninhado de array/hash da mesma forma que o método `includes` para carregar qualquer número de associações com uma única chamada `Model.find`. No entanto, ao contrário do método `includes`, não é possível especificar condições para associações carregadas antecipadamente.

### `eager_load`

Com `eager_load`, o Active Record carrega todas as associações especificadas usando um `LEFT OUTER JOIN`.

Revisitando o caso em que ocorreu N + 1 usando o método `eager_load`, poderíamos reescrever `Book.limit(10)` para carregar antecipadamente os autores:

```ruby
books = Book.eager_load(:author).limit(10)

books.each do |book|
  puts book.author.last_name
end
```

O código acima executará apenas **2** consultas, em oposição às **11** consultas do caso original:

```sql
SELECT DISTINCT books.id FROM books LEFT OUTER JOIN authors ON authors.book_id = books.id LIMIT 10
SELECT books.id AS t0_r0, books.last_name AS t0_r1, ...
  FROM books LEFT OUTER JOIN authors ON authors.book_id = books.id
  WHERE books.id IN (1,2,3,4,5,6,7,8,9,10)
```

NOTA: O método `eager_load` usa um array, hash ou um hash aninhado de array/hash da mesma forma que o método `includes` para carregar qualquer número de associações com uma única chamada `Model.find`. Além disso, como o método `includes`, você pode especificar condições para associações carregadas antecipadamente.

### `strict_loading`

O carregamento antecipado pode evitar consultas N + 1, mas você ainda pode estar carregando preguiçosamente
algumas associações. Para garantir que nenhuma associação seja carregada preguiçosamente, você pode ativar
[`strict_loading`][].

Ao ativar o modo de carregamento estrito em uma relação, um
`ActiveRecord::StrictLoadingViolationError` será lançado se o registro tentar
carregar preguiçosamente uma associação:

```ruby
user = User.strict_loading.first
user.comments.to_a # levanta um ActiveRecord::StrictLoadingViolationError
```


Escopos
------
O escopo permite que você especifique consultas comumente usadas que podem ser referenciadas como chamadas de método nos objetos de associação ou modelos. Com esses escopos, você pode usar todos os métodos previamente abordados, como `where`, `joins` e `includes`. Todos os corpos de escopo devem retornar um `ActiveRecord::Relation` ou `nil` para permitir a chamada de outros métodos (como outros escopos) nele.

Para definir um escopo simples, usamos o método [`scope`][] dentro da classe, passando a consulta que gostaríamos de executar quando esse escopo for chamado:

```ruby
class Book < ApplicationRecord
  scope :out_of_print, -> { where(out_of_print: true) }
end
```

Para chamar esse escopo `out_of_print`, podemos chamá-lo na classe:

```irb
irb> Book.out_of_print
=> #<ActiveRecord::Relation> # todos os livros fora de catálogo
```

Ou em uma associação composta por objetos `Book`:

```irb
irb> author = Author.first
irb> author.books.out_of_print
=> #<ActiveRecord::Relation> # todos os livros fora de catálogo do `author`
```

Os escopos também podem ser encadeados dentro de escopos:

```ruby
class Book < ApplicationRecord
  scope :out_of_print, -> { where(out_of_print: true) }
  scope :out_of_print_and_expensive, -> { out_of_print.where("price > 500") }
end
```


### Passando Argumentos

Seu escopo pode receber argumentos:

```ruby
class Book < ApplicationRecord
  scope :costs_more_than, ->(amount) { where("price > ?", amount) }
end
```

Chame o escopo como se fosse um método de classe:

```irb
irb> Book.costs_more_than(100.10)
```

No entanto, isso está apenas duplicando a funcionalidade que seria fornecida a você por um método de classe.

```ruby
class Book < ApplicationRecord
  def self.costs_more_than(amount)
    where("price > ?", amount)
  end
end
```

Esses métodos ainda estarão acessíveis nos objetos de associação:

```irb
irb> author.books.costs_more_than(100.10)
```

### Usando Condicionais

Seu escopo pode utilizar condicionais:

```ruby
class Order < ApplicationRecord
  scope :created_before, ->(time) { where(created_at: ...time) if time.present? }
end
```

Assim como nos outros exemplos, isso se comportará de forma semelhante a um método de classe.

```ruby
class Order < ApplicationRecord
  def self.created_before(time)
    where(created_at: ...time) if time.present?
  end
end
```

No entanto, há uma ressalva importante: um escopo sempre retornará um objeto `ActiveRecord::Relation`, mesmo se a condicional for avaliada como `false`, enquanto um método de classe retornará `nil`. Isso pode causar um `NoMethodError` ao encadear métodos de classe com condicionais, se alguma das condicionais retornar `false`.

### Aplicando um Escopo Padrão

Se desejarmos que um escopo seja aplicado a todas as consultas do modelo, podemos usar o método [`default_scope`][] dentro do próprio modelo.

```ruby
class Book < ApplicationRecord
  default_scope { where(out_of_print: false) }
end
```

Quando as consultas são executadas neste modelo, a consulta SQL agora será algo como:

```sql
SELECT * FROM books WHERE (out_of_print = false)
```

Se você precisar fazer coisas mais complexas com um escopo padrão, você pode, alternativamente, defini-lo como um método de classe:

```ruby
class Book < ApplicationRecord
  def self.default_scope
    # Deve retornar um ActiveRecord::Relation.
  end
end
```

NOTA: O `default_scope` também é aplicado ao criar/construir um registro quando os argumentos do escopo são fornecidos como um `Hash`. Ele não é aplicado ao atualizar um registro. Por exemplo:

```ruby
class Book < ApplicationRecord
  default_scope { where(out_of_print: false) }
end
```

```irb
irb> Book.new
=> #<Book id: nil, out_of_print: false>
irb> Book.unscoped.new
=> #<Book id: nil, out_of_print: nil>
```

Esteja ciente de que, quando fornecido no formato `Array`, os argumentos da consulta `default_scope` não podem ser convertidos em um `Hash` para atribuição de atributo padrão. Por exemplo:

```ruby
class Book < ApplicationRecord
  default_scope { where("out_of_print = ?", false) }
end
```

```irb
irb> Book.new
=> #<Book id: nil, out_of_print: nil>
```


### Mesclando Escopos

Assim como as cláusulas `where`, os escopos são mesclados usando condições `AND`.

```ruby
class Book < ApplicationRecord
  scope :in_print, -> { where(out_of_print: false) }
  scope :out_of_print, -> { where(out_of_print: true) }

  scope :recent, -> { where(year_published: 50.years.ago.year..) }
  scope :old, -> { where(year_published: ...50.years.ago.year) }
end
```

```irb
irb> Book.out_of_print.old
SELECT books.* FROM books WHERE books.out_of_print = 'true' AND books.year_published < 1969
```

Podemos misturar e combinar condições `scope` e `where` e a consulta SQL final terá todas as condições unidas com `AND`.

```irb
irb> Book.in_print.where(price: ...100)
SELECT books.* FROM books WHERE books.out_of_print = 'false' AND books.price < 100
```

Se quisermos que a última cláusula `where` prevaleça, então [`merge`][] pode ser usado.

```irb
irb> Book.in_print.merge(Book.out_of_print)
SELECT books.* FROM books WHERE books.out_of_print = true
```

Uma ressalva importante é que o `default_scope` será adicionado antes das condições `scope` e `where`.
```ruby
class Book < ApplicationRecord
  default_scope { where(year_published: 50.years.ago.year..) }

  scope :in_print, -> { where(out_of_print: false) }
  scope :out_of_print, -> { where(out_of_print: true) }
end
```

```irb
irb> Book.all
SELECT books.* FROM books WHERE (year_published >= 1969)

irb> Book.in_print
SELECT books.* FROM books WHERE (year_published >= 1969) AND books.out_of_print = false

irb> Book.where('price > 50')
SELECT books.* FROM books WHERE (year_published >= 1969) AND (price > 50)
```

Como você pode ver acima, o `default_scope` está sendo mesclado nas condições de ambos os `scope` e `where`.


### Removendo todos os escopos

Se desejarmos remover os escopos por qualquer motivo, podemos usar o método [`unscoped`][]. Isso é
especialmente útil se um `default_scope` for especificado no modelo e não deve ser
aplicado para esta consulta específica.

```ruby
Book.unscoped.load
```

Este método remove todos os escopos e fará uma consulta normal na tabela.

```irb
irb> Book.unscoped.all
SELECT books.* FROM books

irb> Book.where(out_of_print: true).unscoped.all
SELECT books.* FROM books
```

`unscoped` também pode aceitar um bloco:

```irb
irb> Book.unscoped { Book.out_of_print }
SELECT books.* FROM books WHERE books.out_of_print
```


Finders Dinâmicos
---------------

Para cada campo (também conhecido como atributo) definido em sua tabela,
Active Record fornece um método de busca. Se você tiver um campo chamado `first_name` em seu modelo `Customer`, por exemplo,
você obtém o método de instância `find_by_first_name` gratuitamente do Active Record.
Se você também tiver um campo `locked` no modelo `Customer`, você também obtém o método `find_by_locked`.

Você pode especificar um ponto de exclamação (`!`) no final dos finders dinâmicos
para fazer com que eles levantem um erro `ActiveRecord::RecordNotFound` se eles não retornarem nenhum registro, como `Customer.find_by_first_name!("Ryan")`

Se você quiser encontrar tanto por `first_name` quanto por `orders_count`, você pode encadear esses finders simplesmente digitando "`and`" entre os campos.
Por exemplo, `Customer.find_by_first_name_and_orders_count("Ryan", 5)`.

Enums
-----

Um enum permite que você defina um array de valores para um atributo e se refira a eles pelo nome. O valor real armazenado no banco de dados é um inteiro que foi mapeado para um dos valores.

Declarar um enum irá:

* Criar escopos que podem ser usados para encontrar todos os objetos que têm ou não têm um dos valores do enum
* Criar um método de instância que pode ser usado para determinar se um objeto tem um valor específico para o enum
* Criar um método de instância que pode ser usado para alterar o valor do enum de um objeto

para todos os valores possíveis de um enum.

Por exemplo, dado esta declaração [`enum`][]:

```ruby
class Order < ApplicationRecord
  enum :status, [:shipped, :being_packaged, :complete, :cancelled]
end
```

Esses [escopos](#scopes) são criados automaticamente e podem ser usados para encontrar todos os objetos com ou sem um valor específico para `status`:

```irb
irb> Order.shipped
=> #<ActiveRecord::Relation> # todos os pedidos com status == :shipped
irb> Order.not_shipped
=> #<ActiveRecord::Relation> # todos os pedidos com status != :shipped
```

Esses métodos de instância são criados automaticamente e consultam se o modelo possui esse valor para o enum `status`:

```irb
irb> order = Order.shipped.first
irb> order.shipped?
=> true
irb> order.complete?
=> false
```

Esses métodos de instância são criados automaticamente e primeiro atualizam o valor de `status` para o valor nomeado
e, em seguida, consultam se o status foi definido com sucesso para o valor:

```irb
irb> order = Order.first
irb> order.shipped!
UPDATE "orders" SET "status" = ?, "updated_at" = ? WHERE "orders"."id" = ?  [["status", 0], ["updated_at", "2019-01-24 07:13:08.524320"], ["id", 1]]
=> true
```

A documentação completa sobre enums pode ser encontrada [aqui](https://api.rubyonrails.org/classes/ActiveRecord/Enum.html).


Entendendo o Encadeamento de Métodos
-----------------------------

O padrão Active Record implementa o [Encadeamento de Métodos](https://en.wikipedia.org/wiki/Method_chaining),
que nos permite usar vários métodos do Active Record juntos de maneira simples e direta.

Você pode encadear métodos em uma instrução quando o método anterior chamado retorna um
[`ActiveRecord::Relation`][], como `all`, `where` e `joins`. Métodos que retornam
um único objeto (veja a seção [Recuperando um Único Objeto](#recuperando-um-único-objeto))
devem estar no final da instrução.

Abaixo estão alguns exemplos. Este guia não cobrirá todas as possibilidades, apenas algumas como exemplos.
Quando um método Active Record é chamado, a consulta não é gerada imediatamente e enviada para o banco de dados.
A consulta é enviada apenas quando os dados são realmente necessários. Portanto, cada exemplo abaixo gera uma única consulta.

### Recuperando Dados Filtrados de Múltiplas Tabelas
```ruby
Customer
  .select('customers.id, customers.last_name, reviews.body')
  .joins(:reviews)
  .where('reviews.created_at > ?', 1.week.ago)
```

O resultado deve ser algo como:

```sql
SELECT customers.id, customers.last_name, reviews.body
FROM customers
INNER JOIN reviews
  ON reviews.customer_id = customers.id
WHERE (reviews.created_at > '2019-01-08')
```

### Recuperando Dados Específicos de Múltiplas Tabelas

```ruby
Book
  .select('books.id, books.title, authors.first_name')
  .joins(:author)
  .find_by(title: 'Abstraction and Specification in Program Development')
```

O código acima deve gerar:

```sql
SELECT books.id, books.title, authors.first_name
FROM books
INNER JOIN authors
  ON authors.id = books.author_id
WHERE books.title = $1 [["title", "Abstraction and Specification in Program Development"]]
LIMIT 1
```

NOTA: Note que se uma consulta corresponder a vários registros, `find_by` irá buscar apenas o primeiro e ignorar os outros (veja a declaração `LIMIT 1` acima).

Encontrar ou Criar um Novo Objeto
--------------------------

É comum que você precise encontrar um registro ou criá-lo se ele não existir. Você pode fazer isso usando os métodos `find_or_create_by` e `find_or_create_by!`.

### `find_or_create_by`

O método [`find_or_create_by`][] verifica se um registro com os atributos especificados existe. Se não existir, então o método `create` é chamado. Vejamos um exemplo.

Suponha que você queira encontrar um cliente chamado "Andy" e, se não houver nenhum, criar um. Você pode fazer isso executando:

```irb
irb> Customer.find_or_create_by(first_name: 'Andy')
=> #<Customer id: 5, first_name: "Andy", last_name: nil, title: nil, visits: 0, orders_count: nil, lock_version: 0, created_at: "2019-01-17 07:06:45", updated_at: "2019-01-17 07:06:45">
```

O SQL gerado por este método é semelhante a isso:

```sql
SELECT * FROM customers WHERE (customers.first_name = 'Andy') LIMIT 1
BEGIN
INSERT INTO customers (created_at, first_name, locked, orders_count, updated_at) VALUES ('2011-08-30 05:22:57', 'Andy', 1, NULL, '2011-08-30 05:22:57')
COMMIT
```

`find_or_create_by` retorna o registro que já existe ou o novo registro. No nosso caso, não tínhamos um cliente chamado Andy, então o registro é criado e retornado.

O novo registro pode não ser salvo no banco de dados; isso depende se as validações foram aprovadas ou não (assim como `create`).

Suponha que queremos definir o atributo 'locked' como `false` se estivermos criando um novo registro, mas não queremos incluí-lo na consulta. Então, queremos encontrar o cliente chamado "Andy" ou, se esse cliente não existir, criar um cliente chamado "Andy" que não esteja bloqueado.

Podemos fazer isso de duas maneiras. A primeira é usar `create_with`:

```ruby
Customer.create_with(locked: false).find_or_create_by(first_name: 'Andy')
```

A segunda maneira é usar um bloco:

```ruby
Customer.find_or_create_by(first_name: 'Andy') do |c|
  c.locked = false
end
```

O bloco só será executado se o cliente estiver sendo criado. Na segunda vez que executarmos este código, o bloco será ignorado.


### `find_or_create_by!`

Você também pode usar [`find_or_create_by!`][] para lançar uma exceção se o novo registro for inválido. As validações não são abordadas neste guia, mas vamos supor por um momento que você temporariamente adicione

```ruby
validates :orders_count, presence: true
```

ao seu modelo `Customer`. Se você tentar criar um novo `Customer` sem passar um `orders_count`, o registro será inválido e uma exceção será lançada:

```irb
irb> Customer.find_or_create_by!(first_name: 'Andy')
ActiveRecord::RecordInvalid: Validation failed: Orders count can’t be blank
```


### `find_or_initialize_by`

O método [`find_or_initialize_by`][] funcionará da mesma forma que `find_or_create_by`, mas ele chamará `new` em vez de `create`. Isso significa que uma nova instância do modelo será criada na memória, mas não será salva no banco de dados. Continuando com o exemplo do `find_or_create_by`, agora queremos o cliente chamado 'Nina':

```irb
irb> nina = Customer.find_or_initialize_by(first_name: 'Nina')
=> #<Customer id: nil, first_name: "Nina", orders_count: 0, locked: true, created_at: "2011-08-30 06:09:27", updated_at: "2011-08-30 06:09:27">

irb> nina.persisted?
=> false

irb> nina.new_record?
=> true
```

Como o objeto ainda não está armazenado no banco de dados, o SQL gerado é assim:

```sql
SELECT * FROM customers WHERE (customers.first_name = 'Nina') LIMIT 1
```

Quando você quiser salvá-lo no banco de dados, basta chamar `save`:

```irb
irb> nina.save
=> true
```


Encontrando por SQL
--------------

Se você quiser usar seu próprio SQL para encontrar registros em uma tabela, pode usar [`find_by_sql`][]. O método `find_by_sql` retornará um array de objetos, mesmo que a consulta subjacente retorne apenas um único registro. Por exemplo, você pode executar esta consulta:

```irb
irb> Customer.find_by_sql("SELECT * FROM customers INNER JOIN orders ON customers.id = orders.customer_id ORDER BY customers.created_at desc")
=> [#<Customer id: 1, first_name: "Lucas" ...>, #<Customer id: 2, first_name: "Jan" ...>, ...]
```

`find_by_sql` fornece uma maneira simples de fazer chamadas personalizadas ao banco de dados e recuperar objetos instanciados.


### `select_all`

`find_by_sql` tem um parente próximo chamado [`connection.select_all`][]. `select_all` irá recuperar
objetos do banco de dados usando SQL personalizado, assim como `find_by_sql`, mas não os instanciará.
Este método retornará uma instância da classe `ActiveRecord::Result` e chamar `to_a` neste
objeto retornará um array de hashes onde cada hash indica um registro.

```irb
irb> Customer.connection.select_all("SELECT first_name, created_at FROM customers WHERE id = '1'").to_a
=> [{"first_name"=>"Rafael", "created_at"=>"2012-11-10 23:23:45.281189"}, {"first_name"=>"Eileen", "created_at"=>"2013-12-09 11:22:35.221282"}]
```


### `pluck`

[`pluck`][] pode ser usado para selecionar o(s) valor(es) da(s) coluna(s) nomeada(s) na relação atual. Ele aceita uma lista de nomes de colunas como argumento e retorna um array de valores das colunas especificadas com o tipo de dados correspondente.

```irb
irb> Book.where(out_of_print: true).pluck(:id)
SELECT id FROM books WHERE out_of_print = true
=> [1, 2, 3]

irb> Order.distinct.pluck(:status)
SELECT DISTINCT status FROM orders
=> ["shipped", "being_packed", "cancelled"]

irb> Customer.pluck(:id, :first_name)
SELECT customers.id, customers.first_name FROM customers
=> [[1, "David"], [2, "Fran"], [3, "Jose"]]
```

`pluck` permite substituir código como:

```ruby
Customer.select(:id).map { |c| c.id }
# ou
Customer.select(:id).map(&:id)
# ou
Customer.select(:id, :first_name).map { |c| [c.id, c.first_name] }
```

por:

```ruby
Customer.pluck(:id)
# ou
Customer.pluck(:id, :first_name)
```

Ao contrário de `select`, `pluck` converte diretamente um resultado do banco de dados em um `Array` do Ruby,
sem construir objetos `ActiveRecord`. Isso pode significar melhor desempenho para
uma consulta grande ou frequentemente executada. No entanto, qualquer substituição de método do modelo
não estará disponível. Por exemplo:

```ruby
class Customer < ApplicationRecord
  def name
    "Eu sou #{first_name}"
  end
end
```

```irb
irb> Customer.select(:first_name).map &:name
=> ["Eu sou David", "Eu sou Jeremy", "Eu sou Jose"]

irb> Customer.pluck(:first_name)
=> ["David", "Jeremy", "Jose"]
```

Você não está limitado a consultar campos de uma única tabela, também pode consultar várias tabelas.

```irb
irb> Order.joins(:customer, :books).pluck("orders.created_at, customers.email, books.title")
```

Além disso, ao contrário de `select` e outros escopos de `Relation`, `pluck` dispara uma consulta imediata
e, portanto, não pode ser encadeado com outros escopos, embora possa funcionar com
escopos já construídos anteriormente:

```irb
irb> Customer.pluck(:first_name).limit(1)
NoMethodError: undefined method `limit' for #<Array:0x007ff34d3ad6d8>

irb> Customer.limit(1).pluck(:first_name)
=> ["David"]
```

NOTA: Você também deve saber que o uso de `pluck` irá disparar o carregamento antecipado se o objeto de relação contiver valores de inclusão, mesmo que o carregamento antecipado não seja necessário para a consulta. Por exemplo:

```irb
irb> assoc = Customer.includes(:reviews)
irb> assoc.pluck(:id)
SELECT "customers"."id" FROM "customers" LEFT OUTER JOIN "reviews" ON "reviews"."id" = "customers"."review_id"
```

Uma maneira de evitar isso é `desfazer` as inclusões:

```irb
irb> assoc.unscope(:includes).pluck(:id)
```


### `pick`

[`pick`][] pode ser usado para selecionar o(s) valor(es) da(s) coluna(s) nomeada(s) na relação atual. Ele aceita uma lista de nomes de colunas como argumento e retorna a primeira linha dos valores da coluna especificada com o tipo de dados correspondente.
`pick` é uma forma abreviada de `relation.limit(1).pluck(*column_names).first`, que é principalmente útil quando você já tem uma relação limitada a uma linha.

`pick` permite substituir código como:

```ruby
Customer.where(id: 1).pluck(:id).first
```

por:

```ruby
Customer.where(id: 1).pick(:id)
```


### `ids`

[`ids`][] pode ser usado para selecionar todos os IDs da relação usando a chave primária da tabela.

```irb
irb> Customer.ids
SELECT id FROM customers
```

```ruby
class Customer < ApplicationRecord
  self.primary_key = "customer_id"
end
```

```irb
irb> Customer.ids
SELECT customer_id FROM customers
```


Existência de Objetos
--------------------

Se você simplesmente deseja verificar a existência do objeto, há um método chamado [`exists?`][]. Este método consultará o banco de dados usando a mesma consulta que `find`, mas em vez de retornar um
objeto ou coleção de objetos, ele retornará `true` ou `false`.

```ruby
Customer.exists?(1)
```

O método `exists?` também aceita vários valores, mas a condição é que ele retornará `true` se algum
desses registros existir.

```ruby
Customer.exists?(id: [1, 2, 3])
# ou
Customer.exists?(first_name: ['Jane', 'Sergei'])
```

Também é possível usar `exists?` sem argumentos em um modelo ou relação.

```ruby
Customer.where(first_name: 'Ryan').exists?
```

O exemplo acima retorna `true` se houver pelo menos um cliente com o `first_name` 'Ryan' e `false`
caso contrário.

```ruby
Customer.exists?
```

O exemplo acima retorna `false` se a tabela `customers` estiver vazia e `true` caso contrário.

Você também pode usar `any?` e `many?` para verificar a existência em um modelo ou relação. `many?` usará o SQL `count` para determinar se o item existe.
```ruby
# via a model
Order.any?
# SELECT 1 FROM orders LIMIT 1
Order.many?
# SELECT COUNT(*) FROM (SELECT 1 FROM orders LIMIT 2)

# via a named scope
Order.shipped.any?
# SELECT 1 FROM orders WHERE orders.status = 0 LIMIT 1
Order.shipped.many?
# SELECT COUNT(*) FROM (SELECT 1 FROM orders WHERE orders.status = 0 LIMIT 2)

# via a relation
Book.where(out_of_print: true).any?
Book.where(out_of_print: true).many?

# via an association
Customer.first.orders.any?
Customer.first.orders.many?
```


Cálculos
------------

Esta seção usa o método [`count`][] como exemplo neste preâmbulo, mas as opções descritas se aplicam a todas as subseções.

Todos os métodos de cálculo funcionam diretamente em um modelo:

```irb
irb> Customer.count
SELECT COUNT(*) FROM customers
```

Ou em uma relação:

```irb
irb> Customer.where(first_name: 'Ryan').count
SELECT COUNT(*) FROM customers WHERE (first_name = 'Ryan')
```

Você também pode usar vários métodos de busca em uma relação para realizar cálculos complexos:

```irb
irb> Customer.includes("orders").where(first_name: 'Ryan', orders: { status: 'shipped' }).count
```

Que executará:

```sql
SELECT COUNT(DISTINCT customers.id) FROM customers
  LEFT OUTER JOIN orders ON orders.customer_id = customers.id
  WHERE (customers.first_name = 'Ryan' AND orders.status = 0)
```

supondo que Order tenha `enum status: [ :shipped, :being_packed, :cancelled ]`.

### `count`

Se você quiser ver quantos registros existem na tabela do seu modelo, pode chamar `Customer.count` e isso retornará o número.
Se você quiser ser mais específico e encontrar todos os clientes com um título presente no banco de dados, pode usar `Customer.count(:title)`.

Para opções, consulte a seção pai, [Cálculos](#cálculos).

### `average`

Se você quiser ver a média de um determinado número em uma de suas tabelas, pode chamar o método [`average`][] na classe que se relaciona com a tabela. Essa chamada de método será algo como:

```ruby
Order.average("subtotal")
```

Isso retornará um número (possivelmente um número de ponto flutuante, como 3.14159265) representando o valor médio no campo.

Para opções, consulte a seção pai, [Cálculos](#cálculos).


### `minimum`

Se você quiser encontrar o valor mínimo de um campo em sua tabela, pode chamar o método [`minimum`][] na classe que se relaciona com a tabela. Essa chamada de método será algo como:

```ruby
Order.minimum("subtotal")
```

Para opções, consulte a seção pai, [Cálculos](#cálculos).


### `maximum`

Se você quiser encontrar o valor máximo de um campo em sua tabela, pode chamar o método [`maximum`][] na classe que se relaciona com a tabela. Essa chamada de método será algo como:

```ruby
Order.maximum("subtotal")
```

Para opções, consulte a seção pai, [Cálculos](#cálculos).


### `sum`

Se você quiser encontrar a soma de um campo para todos os registros em sua tabela, pode chamar o método [`sum`][] na classe que se relaciona com a tabela. Essa chamada de método será algo como:

```ruby
Order.sum("subtotal")
```

Para opções, consulte a seção pai, [Cálculos](#cálculos).


Executando EXPLAIN
---------------

Você pode executar [`explain`][] em uma relação. A saída do EXPLAIN varia para cada banco de dados.

Por exemplo, executar

```ruby
Customer.where(id: 1).joins(:orders).explain
```

pode resultar em

```
EXPLAIN SELECT `customers`.* FROM `customers` INNER JOIN `orders` ON `orders`.`customer_id` = `customers`.`id` WHERE `customers`.`id` = 1
+----+-------------+------------+-------+---------------+
| id | select_type | table      | type  | possible_keys |
+----+-------------+------------+-------+---------------+
|  1 | SIMPLE      | customers  | const | PRIMARY       |
|  1 | SIMPLE      | orders     | ALL   | NULL          |
+----+-------------+------------+-------+---------------+
+---------+---------+-------+------+-------------+
| key     | key_len | ref   | rows | Extra       |
+---------+---------+-------+------+-------------+
| PRIMARY | 4       | const |    1 |             |
| NULL    | NULL    | NULL  |    1 | Using where |
+---------+---------+-------+------+-------------+

2 rows in set (0.00 sec)
```

no MySQL e MariaDB.

O Active Record realiza uma impressão bonita que emula a do
shell do banco de dados correspondente. Portanto, a mesma consulta executada com o
adaptador PostgreSQL retornaria em vez disso

```
EXPLAIN SELECT "customers".* FROM "customers" INNER JOIN "orders" ON "orders"."customer_id" = "customers"."id" WHERE "customers"."id" = $1 [["id", 1]]
                                  QUERY PLAN
------------------------------------------------------------------------------
 Nested Loop  (cost=4.33..20.85 rows=4 width=164)
    ->  Index Scan using customers_pkey on customers  (cost=0.15..8.17 rows=1 width=164)
          Index Cond: (id = '1'::bigint)
    ->  Bitmap Heap Scan on orders  (cost=4.18..12.64 rows=4 width=8)
          Recheck Cond: (customer_id = '1'::bigint)
          ->  Bitmap Index Scan on index_orders_on_customer_id  (cost=0.00..4.18 rows=4 width=0)
                Index Cond: (customer_id = '1'::bigint)
(7 rows)
```

O carregamento antecipado pode desencadear mais de uma consulta nos bastidores e algumas consultas
podem precisar dos resultados das consultas anteriores. Por causa disso, `explain` realmente
executa a consulta e, em seguida, solicita os planos de consulta. Por exemplo,
```ruby
Customer.where(id: 1).includes(:orders).explain
```

pode resultar nisso para MySQL e MariaDB:

```
EXPLAIN SELECT `customers`.* FROM `customers`  WHERE `customers`.`id` = 1
+----+-------------+-----------+-------+---------------+
| id | select_type | table     | type  | possible_keys |
+----+-------------+-----------+-------+---------------+
|  1 | SIMPLE      | customers | const | PRIMARY       |
+----+-------------+-----------+-------+---------------+
+---------+---------+-------+------+-------+
| key     | key_len | ref   | rows | Extra |
+---------+---------+-------+------+-------+
| PRIMARY | 4       | const |    1 |       |
+---------+---------+-------+------+-------+

1 row in set (0.00 sec)

EXPLAIN SELECT `orders`.* FROM `orders`  WHERE `orders`.`customer_id` IN (1)
+----+-------------+--------+------+---------------+
| id | select_type | table  | type | possible_keys |
+----+-------------+--------+------+---------------+
|  1 | SIMPLE      | orders | ALL  | NULL          |
+----+-------------+--------+------+---------------+
+------+---------+------+------+-------------+
| key  | key_len | ref  | rows | Extra       |
+------+---------+------+------+-------------+
| NULL | NULL    | NULL |    1 | Using where |
+------+---------+------+------+-------------+


1 row in set (0.00 sec)
```

e pode resultar nisso para PostgreSQL:

```
  Customer Load (0.3ms)  SELECT "customers".* FROM "customers" WHERE "customers"."id" = $1  [["id", 1]]
  Order Load (0.3ms)  SELECT "orders".* FROM "orders" WHERE "orders"."customer_id" = $1  [["customer_id", 1]]
=> EXPLAIN SELECT "customers".* FROM "customers" WHERE "customers"."id" = $1 [["id", 1]]
                                    QUERY PLAN
----------------------------------------------------------------------------------
 Index Scan using customers_pkey on customers  (cost=0.15..8.17 rows=1 width=164)
   Index Cond: (id = '1'::bigint)
(2 rows)
```


### Opções de Explicação

Para bancos de dados e adaptadores que suportam (atualmente PostgreSQL e MySQL), opções podem ser passadas para fornecer uma análise mais profunda.

Usando PostgreSQL, o seguinte:

```ruby
Customer.where(id: 1).joins(:orders).explain(:analyze, :verbose)
```

resulta em:

```sql
EXPLAIN (ANALYZE, VERBOSE) SELECT "shop_accounts".* FROM "shop_accounts" INNER JOIN "customers" ON "customers"."id" = "shop_accounts"."customer_id" WHERE "shop_accounts"."id" = $1 [["id", 1]]
                                                                   QUERY PLAN
------------------------------------------------------------------------------------------------------------------------------------------------
 Nested Loop  (cost=0.30..16.37 rows=1 width=24) (actual time=0.003..0.004 rows=0 loops=1)
   Output: shop_accounts.id, shop_accounts.customer_id, shop_accounts.customer_carrier_id
   Inner Unique: true
   ->  Index Scan using shop_accounts_pkey on public.shop_accounts  (cost=0.15..8.17 rows=1 width=24) (actual time=0.003..0.003 rows=0 loops=1)
         Output: shop_accounts.id, shop_accounts.customer_id, shop_accounts.customer_carrier_id
         Index Cond: (shop_accounts.id = '1'::bigint)
   ->  Index Only Scan using customers_pkey on public.customers  (cost=0.15..8.17 rows=1 width=8) (never executed)
         Output: customers.id
         Index Cond: (customers.id = shop_accounts.customer_id)
         Heap Fetches: 0
 Planning Time: 0.063 ms
 Execution Time: 0.011 ms
(12 rows)
```

Usando MySQL ou MariaDB, o seguinte:

```ruby
Customer.where(id: 1).joins(:orders).explain(:analyze)
```

resulta em:

```sql
ANALYZE SELECT `shop_accounts`.* FROM `shop_accounts` INNER JOIN `customers` ON `customers`.`id` = `shop_accounts`.`customer_id` WHERE `shop_accounts`.`id` = 1
+----+-------------+-------+------+---------------+------+---------+------+------+--------+----------+------------+--------------------------------+
| id | select_type | table | type | possible_keys | key  | key_len | ref  | rows | r_rows | filtered | r_filtered | Extra                          |
+----+-------------+-------+------+---------------+------+---------+------+------+--------+----------+------------+--------------------------------+
|  1 | SIMPLE      | NULL  | NULL | NULL          | NULL | NULL    | NULL | NULL | NULL   | NULL     | NULL       | no matching row in const table |
+----+-------------+-------+------+---------------+------+---------+------+------+--------+----------+------------+--------------------------------+
1 row in set (0.00 sec)
```

NOTA: As opções EXPLAIN e ANALYZE variam de acordo com as versões do MySQL e MariaDB.
([MySQL 5.7][MySQL5.7-explain], [MySQL 8.0][MySQL8-explain], [MariaDB][MariaDB-explain])


### Interpretação do EXPLAIN

A interpretação da saída do EXPLAIN está além do escopo deste guia. As seguintes dicas podem ser úteis:

* SQLite3: [EXPLAIN QUERY PLAN](https://www.sqlite.org/eqp.html)

* MySQL: [EXPLAIN Output Format](https://dev.mysql.com/doc/refman/en/explain-output.html)

* MariaDB: [EXPLAIN](https://mariadb.com/kb/en/mariadb/explain/)

* PostgreSQL: [Using EXPLAIN](https://www.postgresql.org/docs/current/static/using-explain.html)
[`ActiveRecord::Relation`]: https://api.rubyonrails.org/classes/ActiveRecord/Relation.html
[`annotate`]: https://api.rubyonrails.org/classes/ActiveRecord/QueryMethods.html#method-i-annotate
[`create_with`]: https://api.rubyonrails.org/classes/ActiveRecord/QueryMethods.html#method-i-create_with
[`distinct`]: https://api.rubyonrails.org/classes/ActiveRecord/QueryMethods.html#method-i-distinct
[`eager_load`]: https://api.rubyonrails.org/classes/ActiveRecord/QueryMethods.html#method-i-eager_load
[`extending`]: https://api.rubyonrails.org/classes/ActiveRecord/QueryMethods.html#method-i-extending
[`extract_associated`]: https://api.rubyonrails.org/classes/ActiveRecord/QueryMethods.html#method-i-extract_associated
[`find`]: https://api.rubyonrails.org/classes/ActiveRecord/FinderMethods.html#method-i-find
[`from`]: https://api.rubyonrails.org/classes/ActiveRecord/QueryMethods.html#method-i-from
[`group`]: https://api.rubyonrails.org/classes/ActiveRecord/QueryMethods.html#method-i-group
[`having`]: https://api.rubyonrails.org/classes/ActiveRecord/QueryMethods.html#method-i-having
[`includes`]: https://api.rubyonrails.org/classes/ActiveRecord/QueryMethods.html#method-i-includes
[`joins`]: https://api.rubyonrails.org/classes/ActiveRecord/QueryMethods.html#method-i-joins
[`left_outer_joins`]: https://api.rubyonrails.org/classes/ActiveRecord/QueryMethods.html#method-i-left_outer_joins
[`limit`]: https://api.rubyonrails.org/classes/ActiveRecord/QueryMethods.html#method-i-limit
[`lock`]: https://api.rubyonrails.org/classes/ActiveRecord/QueryMethods.html#method-i-lock
[`none`]: https://api.rubyonrails.org/classes/ActiveRecord/QueryMethods.html#method-i-none
[`offset`]: https://api.rubyonrails.org/classes/ActiveRecord/QueryMethods.html#method-i-offset
[`optimizer_hints`]: https://api.rubyonrails.org/classes/ActiveRecord/QueryMethods.html#method-i-optimizer_hints
[`order`]: https://api.rubyonrails.org/classes/ActiveRecord/QueryMethods.html#method-i-order
[`preload`]: https://api.rubyonrails.org/classes/ActiveRecord/QueryMethods.html#method-i-preload
[`readonly`]: https://api.rubyonrails.org/classes/ActiveRecord/QueryMethods.html#method-i-readonly
[`references`]: https://api.rubyonrails.org/classes/ActiveRecord/QueryMethods.html#method-i-references
[`reorder`]: https://api.rubyonrails.org/classes/ActiveRecord/QueryMethods.html#method-i-reorder
[`reselect`]: https://api.rubyonrails.org/classes/ActiveRecord/QueryMethods.html#method-i-reselect
[`regroup`]: https://api.rubyonrails.org/classes/ActiveRecord/QueryMethods.html#method-i-regroup
[`reverse_order`]: https://api.rubyonrails.org/classes/ActiveRecord/QueryMethods.html#method-i-reverse_order
[`select`]: https://api.rubyonrails.org/classes/ActiveRecord/QueryMethods.html#method-i-select
[`where`]: https://api.rubyonrails.org/classes/ActiveRecord/QueryMethods.html#method-i-where
[`take`]: https://api.rubyonrails.org/classes/ActiveRecord/FinderMethods.html#method-i-take
[`take!`]: https://api.rubyonrails.org/classes/ActiveRecord/FinderMethods.html#method-i-take-21
[`first`]: https://api.rubyonrails.org/classes/ActiveRecord/FinderMethods.html#method-i-first
[`first!`]: https://api.rubyonrails.org/classes/ActiveRecord/FinderMethods.html#method-i-first-21
[`last`]: https://api.rubyonrails.org/classes/ActiveRecord/FinderMethods.html#method-i-last
[`last!`]: https://api.rubyonrails.org/classes/ActiveRecord/FinderMethods.html#method-i-last-21
[`find_by`]: https://api.rubyonrails.org/classes/ActiveRecord/FinderMethods.html#method-i-find_by
[`find_by!`]: https://api.rubyonrails.org/classes/ActiveRecord/FinderMethods.html#method-i-find_by-21
[`config.active_record.error_on_ignored_order`]: configuring.html#config-active-record-error-on-ignored-order
[`find_each`]: https://api.rubyonrails.org/classes/ActiveRecord/Batches.html#method-i-find_each
[`find_in_batches`]: https://api.rubyonrails.org/classes/ActiveRecord/Batches.html#method-i-find_in_batches
[`sanitize_sql_like`]: https://api.rubyonrails.org/classes/ActiveRecord/Sanitization/ClassMethods.html#method-i-sanitize_sql_like
[`where.not`]: https://api.rubyonrails.org/classes/ActiveRecord/QueryMethods/WhereChain.html#method-i-not
[`or`]: https://api.rubyonrails.org/classes/ActiveRecord/QueryMethods.html#method-i-or
[`and`]: https://api.rubyonrails.org/classes/ActiveRecord/QueryMethods.html#method-i-and
[`count`]: https://api.rubyonrails.org/classes/ActiveRecord/Calculations.html#method-i-count
[`unscope`]: https://api.rubyonrails.org/classes/ActiveRecord/QueryMethods.html#method-i-unscope
[`only`]: https://api.rubyonrails.org/classes/ActiveRecord/SpawnMethods.html#method-i-only
[`regroup`]: https://api.rubyonrails.org/classes/ActiveRecord/QueryMethods.html#method-i-regroup
[`regroup`]: https://api.rubyonrails.org/classes/ActiveRecord/QueryMethods.html#method-i-regroup
[`strict_loading`]: https://api.rubyonrails.org/classes/ActiveRecord/QueryMethods.html#method-i-strict_loading
[`scope`]: https://api.rubyonrails.org/classes/ActiveRecord/Scoping/Named/ClassMethods.html#method-i-scope
[`default_scope`]: https://api.rubyonrails.org/classes/ActiveRecord/Scoping/Default/ClassMethods.html#method-i-default_scope
[`merge`]: https://api.rubyonrails.org/classes/ActiveRecord/SpawnMethods.html#method-i-merge
[`unscoped`]: https://api.rubyonrails.org/classes/ActiveRecord/Scoping/Default/ClassMethods.html#method-i-unscoped
[`enum`]: https://api.rubyonrails.org/classes/ActiveRecord/Enum.html#method-i-enum
[`find_or_create_by`]: https://api.rubyonrails.org/classes/ActiveRecord/Relation.html#method-i-find_or_create_by
[`find_or_create_by!`]: https://api.rubyonrails.org/classes/ActiveRecord/Relation.html#method-i-find_or_create_by-21
[`find_or_initialize_by`]: https://api.rubyonrails.org/classes/ActiveRecord/Relation.html#method-i-find_or_initialize_by
[`find_by_sql`]: https://api.rubyonrails.org/classes/ActiveRecord/Querying.html#method-i-find_by_sql
[`connection.select_all`]: https://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/DatabaseStatements.html#method-i-select_all
[`pluck`]: https://api.rubyonrails.org/classes/ActiveRecord/Calculations.html#method-i-pluck
[`pick`]: https://api.rubyonrails.org/classes/ActiveRecord/Calculations.html#method-i-pick
[`ids`]: https://api.rubyonrails.org/classes/ActiveRecord/Calculations.html#method-i-ids
[`exists?`]: https://api.rubyonrails.org/classes/ActiveRecord/FinderMethods.html#method-i-exists-3F
[`average`]: https://api.rubyonrails.org/classes/ActiveRecord/Calculations.html#method-i-average
[`minimum`]: https://api.rubyonrails.org/classes/ActiveRecord/Calculations.html#method-i-minimum
[`maximum`]: https://api.rubyonrails.org/classes/ActiveRecord/Calculations.html#method-i-maximum
[`sum`]: https://api.rubyonrails.org/classes/ActiveRecord/Calculations.html#method-i-sum
[`explain`]: https://api.rubyonrails.org/classes/ActiveRecord/Relation.html#method-i-explain
[MySQL5.7-explain]: https://dev.mysql.com/doc/refman/5.7/en/explain.html
[MySQL8-explain]: https://dev.mysql.com/doc/refman/8.0/en/explain.html
[MariaDB-explain]: https://mariadb.com/kb/en/analyze-and-explain-statements/
