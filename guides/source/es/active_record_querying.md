**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: cc70f06da31561d3461720649cc42371
Interfaz de consulta de Active Record
======================================

Esta guía cubre diferentes formas de recuperar datos de la base de datos utilizando Active Record.

Después de leer esta guía, sabrás:

* Cómo encontrar registros utilizando una variedad de métodos y condiciones.
* Cómo especificar el orden, los atributos recuperados, la agrupación y otras propiedades de los registros encontrados.
* Cómo utilizar la carga ansiosa para reducir el número de consultas a la base de datos necesarias para la recuperación de datos.
* Cómo utilizar los métodos de búsqueda dinámica.
* Cómo utilizar el encadenamiento de métodos para utilizar varios métodos de Active Record juntos.
* Cómo verificar la existencia de registros particulares.
* Cómo realizar varios cálculos en modelos de Active Record.
* Cómo ejecutar EXPLAIN en relaciones.

--------------------------------------------------------------------------------

¿Qué es la interfaz de consulta de Active Record?
------------------------------------------------

Si estás acostumbrado a utilizar SQL en bruto para encontrar registros de la base de datos, generalmente encontrarás que hay mejores formas de realizar las mismas operaciones en Rails. Active Record te protege de la necesidad de utilizar SQL en la mayoría de los casos.

Active Record realizará consultas en la base de datos por ti y es compatible con la mayoría de los sistemas de bases de datos, incluyendo MySQL, MariaDB, PostgreSQL y SQLite. Independientemente del sistema de bases de datos que estés utilizando, el formato del método de Active Record siempre será el mismo.

Los ejemplos de código a lo largo de esta guía se referirán a uno o más de los siguientes modelos:

CONSEJO: Todos los siguientes modelos utilizan `id` como clave primaria, a menos que se especifique lo contrario.

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

![Diagrama de todos los modelos de la librería](images/active_record_querying/bookstore_models.png)

Recuperando objetos de la base de datos
--------------------------------------

Para recuperar objetos de la base de datos, Active Record proporciona varios métodos de búsqueda. Cada método de búsqueda te permite pasar argumentos para realizar ciertas consultas en tu base de datos sin escribir SQL en bruto.

Los métodos son:

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

Los métodos de búsqueda que devuelven una colección, como `where` y `group`, devuelven una instancia de [`ActiveRecord::Relation`][]. Los métodos que encuentran una sola entidad, como `find` y `first`, devuelven una única instancia del modelo.

La operación principal de `Model.find(options)` se puede resumir de la siguiente manera:

* Convertir las opciones suministradas en una consulta SQL equivalente.
* Ejecutar la consulta SQL y recuperar los resultados correspondientes de la base de datos.
* Instanciar el objeto Ruby equivalente del modelo apropiado para cada fila resultante.
* Ejecutar los callbacks `after_find` y luego `after_initialize`, si los hay.


### Recuperando un solo objeto

Active Record proporciona varias formas diferentes de recuperar un solo objeto.

#### `find`

Utilizando el método [`find`][], puedes recuperar el objeto correspondiente a la _clave primaria_ especificada que coincida con cualquier opción suministrada. Por ejemplo:

```irb
# Encuentra el cliente con la clave primaria (id) 10.
irb> customer = Customer.find(10)
=> #<Customer id: 10, first_name: "Ryan">
```

El equivalente SQL de lo anterior es:

```sql
SELECT * FROM customers WHERE (customers.id = 10) LIMIT 1
```

El método `find` lanzará una excepción `ActiveRecord::RecordNotFound` si no se encuentra ningún registro coincidente.

También puedes utilizar este método para consultar varios objetos. Llama al método `find` y pasa un array de claves primarias. El resultado será un array que contiene todos los registros coincidentes para las claves primarias suministradas. Por ejemplo:
```irb
# Encuentra los clientes con claves primarias 1 y 10.
irb> customers = Customer.find([1, 10]) # O Customer.find(1, 10)
=> [#<Customer id: 1, first_name: "Lifo">, #<Customer id: 10, first_name: "Ryan">]
```

El equivalente SQL de lo anterior es:

```sql
SELECT * FROM customers WHERE (customers.id IN (1,10))
```

ADVERTENCIA: El método `find` lanzará una excepción `ActiveRecord::RecordNotFound` a menos que se encuentre un registro coincidente para **todos** las claves primarias suministradas.

#### `take`

El método [`take`][] recupera un registro sin ningún orden implícito. Por ejemplo:

```irb
irb> customer = Customer.take
=> #<Customer id: 1, first_name: "Lifo">
```

El equivalente SQL de lo anterior es:

```sql
SELECT * FROM customers LIMIT 1
```

El método `take` devuelve `nil` si no se encuentra ningún registro y no se lanzará ninguna excepción.

Puede pasar un argumento numérico al método `take` para devolver hasta ese número de resultados. Por ejemplo:

```irb
irb> customers = Customer.take(2)
=> [#<Customer id: 1, first_name: "Lifo">, #<Customer id: 220, first_name: "Sara">]
```

El equivalente SQL de lo anterior es:

```sql
SELECT * FROM customers LIMIT 2
```

El método [`take!`][] se comporta exactamente como `take`, excepto que lanzará `ActiveRecord::RecordNotFound` si no se encuentra ningún registro coincidente.

CONSEJO: El registro recuperado puede variar dependiendo del motor de la base de datos.


#### `first`

El método [`first`][] encuentra el primer registro ordenado por clave primaria (por defecto). Por ejemplo:

```irb
irb> customer = Customer.first
=> #<Customer id: 1, first_name: "Lifo">
```

El equivalente SQL de lo anterior es:

```sql
SELECT * FROM customers ORDER BY customers.id ASC LIMIT 1
```

El método `first` devuelve `nil` si no se encuentra ningún registro coincidente y no se lanzará ninguna excepción.

Si su [ámbito predeterminado](active_record_querying.html#applying-a-default-scope) contiene un método de orden, `first` devolverá el primer registro según este orden.

Puede pasar un argumento numérico al método `first` para devolver hasta ese número de resultados. Por ejemplo:

```irb
irb> customers = Customer.first(3)
=> [#<Customer id: 1, first_name: "Lifo">, #<Customer id: 2, first_name: "Fifo">, #<Customer id: 3, first_name: "Filo">]
```

El equivalente SQL de lo anterior es:

```sql
SELECT * FROM customers ORDER BY customers.id ASC LIMIT 3
```

En una colección que se ordena usando `order`, `first` devolverá el primer registro ordenado por el atributo especificado para `order`.

```irb
irb> customer = Customer.order(:first_name).first
=> #<Customer id: 2, first_name: "Fifo">
```

El equivalente SQL de lo anterior es:

```sql
SELECT * FROM customers ORDER BY customers.first_name ASC LIMIT 1
```

El método [`first!`][] se comporta exactamente como `first`, excepto que lanzará `ActiveRecord::RecordNotFound` si no se encuentra ningún registro coincidente.


#### `last`

El método [`last`][] encuentra el último registro ordenado por clave primaria (por defecto). Por ejemplo:

```irb
irb> customer = Customer.last
=> #<Customer id: 221, first_name: "Russel">
```

El equivalente SQL de lo anterior es:

```sql
SELECT * FROM customers ORDER BY customers.id DESC LIMIT 1
```

El método `last` devuelve `nil` si no se encuentra ningún registro coincidente y no se lanzará ninguna excepción.

Si su [ámbito predeterminado](active_record_querying.html#applying-a-default-scope) contiene un método de orden, `last` devolverá el último registro según este orden.

Puede pasar un argumento numérico al método `last` para devolver hasta ese número de resultados. Por ejemplo:

```irb
irb> customers = Customer.last(3)
=> [#<Customer id: 219, first_name: "James">, #<Customer id: 220, first_name: "Sara">, #<Customer id: 221, first_name: "Russel">]
```

El equivalente SQL de lo anterior es:

```sql
SELECT * FROM customers ORDER BY customers.id DESC LIMIT 3
```

En una colección que se ordena usando `order`, `last` devolverá el último registro ordenado por el atributo especificado para `order`.

```irb
irb> customer = Customer.order(:first_name).last
=> #<Customer id: 220, first_name: "Sara">
```

El equivalente SQL de lo anterior es:

```sql
SELECT * FROM customers ORDER BY customers.first_name DESC LIMIT 1
```

El método [`last!`][] se comporta exactamente como `last`, excepto que lanzará `ActiveRecord::RecordNotFound` si no se encuentra ningún registro coincidente.


#### `find_by`

El método [`find_by`][] encuentra el primer registro que coincide con algunas condiciones. Por ejemplo:

```irb
irb> Customer.find_by first_name: 'Lifo'
=> #<Customer id: 1, first_name: "Lifo">

irb> Customer.find_by first_name: 'Jon'
=> nil
```

Es equivalente a escribir:

```ruby
Customer.where(first_name: 'Lifo').take
```

El equivalente SQL de lo anterior es:

```sql
SELECT * FROM customers WHERE (customers.first_name = 'Lifo') LIMIT 1
```
Ten en cuenta que no hay `ORDER BY` en el SQL anterior. Si tus condiciones de `find_by` pueden coincidir con varios registros, debes [aplicar un orden](#ordering) para garantizar un resultado determinista.

El método [`find_by!`][] se comporta exactamente como `find_by`, excepto que generará una excepción `ActiveRecord::RecordNotFound` si no se encuentra ningún registro coincidente. Por ejemplo:

```irb
irb> Customer.find_by! first_name: 'no existe'
ActiveRecord::RecordNotFound
```

Esto es equivalente a escribir:

```ruby
Customer.where(first_name: 'no existe').take!
```


### Recuperar múltiples objetos en lotes

A menudo necesitamos iterar sobre un gran conjunto de registros, como cuando enviamos un boletín a un gran conjunto de clientes o cuando exportamos datos.

Esto puede parecer sencillo:

```ruby
# Esto puede consumir demasiada memoria si la tabla es grande.
Customer.all.each do |customer|
  NewsMailer.weekly(customer).deliver_now
end
```

Pero este enfoque se vuelve cada vez más impráctico a medida que aumenta el tamaño de la tabla, ya que `Customer.all.each` instruye a Active Record a buscar _toda la tabla_ en un solo paso, construir un objeto de modelo por fila y luego mantener todo el array de objetos de modelo en memoria. De hecho, si tenemos un gran número de registros, es posible que la colección completa exceda la cantidad de memoria disponible.

Rails proporciona dos métodos que abordan este problema dividiendo los registros en lotes que son amigables para la memoria para su procesamiento. El primer método, `find_each`, recupera un lote de registros y luego cede _cada_ registro al bloque individualmente como un modelo. El segundo método, `find_in_batches`, recupera un lote de registros y luego cede _todo el lote_ al bloque como un array de modelos.

CONSEJO: Los métodos `find_each` y `find_in_batches` están destinados a ser utilizados en el procesamiento por lotes de un gran número de registros que no cabrían en memoria de una sola vez. Si solo necesitas iterar sobre mil registros, los métodos de búsqueda regulares son la opción preferida.

#### `find_each`

El método [`find_each`][] recupera registros en lotes y luego cede _cada uno_ al bloque. En el siguiente ejemplo, `find_each` recupera clientes en lotes de 1000 y los cede al bloque uno por uno:

```ruby
Customer.find_each do |customer|
  NewsMailer.weekly(customer).deliver_now
end
```

Este proceso se repite, obteniendo más lotes según sea necesario, hasta que todos los registros hayan sido procesados.

`find_each` funciona en clases de modelos, como se ve arriba, y también en relaciones:

```ruby
Customer.where(weekly_subscriber: true).find_each do |customer|
  NewsMailer.weekly(customer).deliver_now
end
```

siempre y cuando no tengan un orden, ya que el método necesita forzar un orden internamente para iterar.

Si hay un orden presente en el receptor, el comportamiento depende de la bandera
[`config.active_record.error_on_ignored_order`][]. Si es verdadero, se genera un `ArgumentError`,
de lo contrario, se ignora el orden y se emite una advertencia, que es el
valor predeterminado. Esto se puede anular con la opción `:error_on_ignore`, explicada
a continuación.


##### Opciones para `find_each`

**`:batch_size`**

La opción `:batch_size` te permite especificar la cantidad de registros que se deben recuperar en cada lote, antes de pasarlos individualmente al bloque. Por ejemplo, para recuperar registros en lotes de 5000:

```ruby
Customer.find_each(batch_size: 5000) do |customer|
  NewsMailer.weekly(customer).deliver_now
end
```

**`:start`**

De forma predeterminada, los registros se recuperan en orden ascendente de la clave primaria. La opción `:start` te permite configurar el primer ID de la secuencia cuando el ID más bajo no es el que necesitas. Esto sería útil, por ejemplo, si quisieras reanudar un proceso por lotes interrumpido, siempre que hayas guardado el último ID procesado como punto de control.

Por ejemplo, para enviar boletines solo a clientes con la clave primaria a partir de 2000:

```ruby
Customer.find_each(start: 2000) do |customer|
  NewsMailer.weekly(customer).deliver_now
end
```

**`:finish`**

Similar a la opción `:start`, `:finish` te permite configurar el último ID de la secuencia cuando el ID más alto no es el que necesitas.
Esto sería útil, por ejemplo, si quisieras ejecutar un proceso por lotes utilizando un subconjunto de registros basado en `:start` y `:finish`.

Por ejemplo, para enviar boletines solo a clientes con la clave primaria a partir de 2000 hasta 10000:

```ruby
Customer.find_each(start: 2000, finish: 10000) do |customer|
  NewsMailer.weekly(customer).deliver_now
end
```

Otro ejemplo sería si quisieras que varios trabajadores manejen la misma
cola de procesamiento. Cada trabajador podría manejar 10000 registros configurando las
opciones `:start` y `:finish` adecuadas en cada trabajador.

**`:error_on_ignore`**

Anula la configuración de la aplicación para especificar si se debe generar un error cuando
hay un orden presente en la relación.

**`:order`**

Especifica el orden de la clave primaria (puede ser `:asc` o `:desc`). El valor predeterminado es `:asc`.
```ruby
Customer.find_each(order: :desc) do |customer|
  NewsMailer.weekly(customer).deliver_now
end
```

#### `find_in_batches`

El método [`find_in_batches`][] es similar a `find_each`, ya que ambos recuperan lotes de registros. La diferencia es que `find_in_batches` devuelve _lotes_ al bloque como un array de modelos, en lugar de individualmente. El siguiente ejemplo devolverá al bloque suministrado un array de hasta 1000 clientes a la vez, con el último bloque que contiene los clientes restantes:

```ruby
# Dar a add_customers un array de 1000 clientes a la vez.
Customer.find_in_batches do |customers|
  export.add_customers(customers)
end
```

`find_in_batches` funciona en clases de modelos, como se ve arriba, y también en relaciones:

```ruby
# Dar a add_customers un array de 1000 clientes recientemente activos a la vez.
Customer.recently_active.find_in_batches do |customers|
  export.add_customers(customers)
end
```

siempre y cuando no tengan un orden, ya que el método necesita forzar un orden internamente para iterar.

##### Opciones para `find_in_batches`

El método `find_in_batches` acepta las mismas opciones que `find_each`:

**`:batch_size`**

Al igual que para `find_each`, `batch_size` establece cuántos registros se recuperarán en cada grupo. Por ejemplo, se puede especificar la recuperación de lotes de 2500 registros de la siguiente manera:

```ruby
Customer.find_in_batches(batch_size: 2500) do |customers|
  export.add_customers(customers)
end
```

**`:start`**

La opción `start` permite especificar el ID de inicio desde donde se seleccionarán los registros. Como se mencionó antes, de forma predeterminada, los registros se obtienen en orden ascendente de la clave primaria. Por ejemplo, para recuperar clientes a partir del ID: 5000 en lotes de 2500 registros, se puede usar el siguiente código:

```ruby
Customer.find_in_batches(batch_size: 2500, start: 5000) do |customers|
  export.add_customers(customers)
end
```

**`:finish`**

La opción `finish` permite especificar el ID final de los registros que se van a recuperar. El siguiente código muestra el caso de recuperar clientes en lotes, hasta el cliente con ID: 7000:

```ruby
Customer.find_in_batches(finish: 7000) do |customers|
  export.add_customers(customers)
end
```

**`:error_on_ignore`**

La opción `error_on_ignore` anula la configuración de la aplicación para especificar si se debe generar un error cuando hay un orden específico en la relación.

Condiciones
----------

El método [`where`][] te permite especificar condiciones para limitar los registros devueltos, representando la parte `WHERE` de la declaración SQL. Las condiciones se pueden especificar como una cadena, un array o un hash.

### Condiciones como cadena pura

Si deseas agregar condiciones a tu búsqueda, simplemente puedes especificarlas allí, como `Book.where("title = 'Introduction to Algorithms'")`. Esto encontrará todos los libros donde el valor del campo `title` sea 'Introduction to Algorithms'.

ADVERTENCIA: Construir tus propias condiciones como cadenas puras puede dejarte vulnerable a ataques de inyección SQL. Por ejemplo, `Book.where("title LIKE '%#{params[:title]}%'")` no es seguro. Consulta la siguiente sección para conocer la forma preferida de manejar las condiciones usando un array.

### Condiciones como array

Ahora, ¿qué pasa si ese título puede variar, por ejemplo, como un argumento de algún lugar? La búsqueda tendría entonces la siguiente forma:

```ruby
Book.where("title = ?", params[:title])
```

Active Record tomará el primer argumento como la cadena de condiciones y cualquier argumento adicional reemplazará los signos de interrogación `(?)` en ella.

Si deseas especificar múltiples condiciones:

```ruby
Book.where("title = ? AND out_of_print = ?", params[:title], false)
```

En este ejemplo, el primer signo de interrogación se reemplazará con el valor en `params[:title]` y el segundo se reemplazará con la representación SQL de `false`, que depende del adaptador.

Este código es muy preferible:

```ruby
Book.where("title = ?", params[:title])
```

a este código:

```ruby
Book.where("title = #{params[:title]}")
```

debido a la seguridad de los argumentos. Colocar la variable directamente en la cadena de condiciones pasará la variable a la base de datos **tal cual**. Esto significa que será una variable no escapada directamente de un usuario que puede tener intenciones maliciosas. Si haces esto, pones en riesgo toda tu base de datos porque una vez que un usuario descubre que puede explotar tu base de datos, puede hacer prácticamente cualquier cosa con ella. Nunca coloques tus argumentos directamente dentro de la cadena de condiciones.

CONSEJO: Para obtener más información sobre los peligros de la inyección SQL, consulta la [Guía de seguridad de Ruby on Rails](security.html#sql-injection).

#### Condiciones con marcadores de posición

Similar al estilo de reemplazo de `(?)` de los parámetros, también puedes especificar claves en tu cadena de condiciones junto con un hash de claves/valores correspondientes:

```ruby
Book.where("created_at >= :start_date AND created_at <= :end_date",
  { start_date: params[:start_date], end_date: params[:end_date] })
```

Esto hace que sea más legible si tienes un gran número de condiciones variables.

#### Condiciones que usan `LIKE`

Aunque los argumentos de las condiciones se escapan automáticamente para prevenir la inyección SQL, los comodines `LIKE` de SQL (es decir, `%` y `_`) **no** se escapan. Esto puede causar un comportamiento inesperado si se utiliza un valor no sanitizado en un argumento. Por ejemplo:
```ruby
Book.order(:title).order(:created_at)
# OR
Book.order("title").order("created_at")
```

This will generate SQL like this:

```sql
SELECT * FROM books ORDER BY title, created_at
```

You can also use the `reverse_order` method to reverse the order of the query:

```ruby
Book.order(:created_at).reverse_order
# OR
Book.order("created_at").reverse_order
```

This will generate SQL like this:

```sql
SELECT * FROM books ORDER BY created_at DESC
```

### Limit and Offset

To limit the number of records returned from the database, you can use the [`limit`][] method. For example, to retrieve the first 5 books:

```ruby
Book.limit(5)
```

This will generate SQL like this:

```sql
SELECT * FROM books LIMIT 5
```

To retrieve a specific range of records, you can use the [`offset`][] method. For example, to retrieve records starting from the 6th record:

```ruby
Book.offset(5)
```

This will generate SQL like this:

```sql
SELECT * FROM books OFFSET 5
```

You can also chain `limit` and `offset` together to retrieve a specific range of records:

```ruby
Book.limit(5).offset(10)
```

This will generate SQL like this:

```sql
SELECT * FROM books LIMIT 5 OFFSET 10
```

### Reordering

To reorder the records returned from the database, you can use the [`reorder`][] method. This allows you to specify a new order for the records, overriding any previous ordering.

For example, to retrieve the books ordered by title and then reorder them by created_at:

```ruby
Book.order(:title).reorder(:created_at)
```

This will generate SQL like this:

```sql
SELECT * FROM books ORDER BY created_at
```

### Selecting Specific Fields

By default, Active Record will retrieve all columns from the table when querying for records. However, you can specify specific fields to retrieve using the [`select`][] method.

For example, to retrieve only the title and author fields of the books:

```ruby
Book.select(:title, :author)
```

This will generate SQL like this:

```sql
SELECT title, author FROM books
```

You can also use SQL expressions in the select statement:

```ruby
Book.select("title", "UPPER(author) AS uppercase_author")
```

This will generate SQL like this:

```sql
SELECT title, UPPER(author) AS uppercase_author FROM books
```

### Grouping

To group records by one or more columns, you can use the [`group`][] method. This is useful when you want to perform aggregate functions on the grouped records.

For example, to retrieve the total number of books published by each author:

```ruby
Book.group(:author).count
```

This will generate SQL like this:

```sql
SELECT author, COUNT(*) AS count FROM books GROUP BY author
```

You can also use the `having` method to specify conditions on the grouped records:

```ruby
Book.group(:author).having("COUNT(*) > 1")
```

This will generate SQL like this:

```sql
SELECT author FROM books GROUP BY author HAVING COUNT(*) > 1
```

### Joins

Active Record allows you to perform joins between tables using the [`joins`][] method. This allows you to retrieve records from multiple tables based on a common column.

For example, to retrieve all books with their corresponding authors:

```ruby
Book.joins(:author)
```

This will generate SQL like this:

```sql
SELECT books.* FROM books INNER JOIN authors ON authors.id = books.author_id
```

You can also specify additional conditions on the join:

```ruby
Book.joins(:author).where("authors.name = ?", "John Doe")
```

This will generate SQL like this:

```sql
SELECT books.* FROM books INNER JOIN authors ON authors.id = books.author_id WHERE authors.name = 'John Doe'
```

### Eager Loading

By default, Active Record will perform a separate database query for each association when retrieving records. This can lead to the N+1 query problem, where the number of queries grows linearly with the number of records retrieved.

To avoid this problem, you can use eager loading to retrieve all associated records in a single query. This can be done using the [`includes`][] method.

For example, to retrieve all books with their corresponding authors:

```ruby
Book.includes(:author)
```

This will generate SQL like this:

```sql
SELECT books.* FROM books LEFT OUTER JOIN authors ON authors.id = books.author_id
```

You can also specify multiple associations to eager load:

```ruby
Book.includes(:author, :publisher)
```

This will generate SQL like this:

```sql
SELECT books.* FROM books LEFT OUTER JOIN authors ON authors.id = books.author_id LEFT OUTER JOIN publishers ON publishers.id = books.publisher_id
```

Eager loading can also be used with nested associations:

```ruby
Book.includes(author: :publisher)
```

This will generate SQL like this:

```sql
SELECT books.* FROM books LEFT OUTER JOIN authors ON authors.id = books.author_id LEFT OUTER JOIN publishers ON publishers.id = authors.publisher_id
```

### Locking

Active Record allows you to lock records in the database to prevent other processes from modifying them. This can be done using the [`lock`][] method.

For example, to lock a book record:

```ruby
book = Book.find(1)
book.lock!
```

This will generate SQL like this:

```sql
SELECT * FROM books WHERE books.id = 1 FOR UPDATE
```

You can also use the `lock` method with a block to lock multiple records:

```ruby
Book.lock do
  books = Book.where(out_of_print: true)
  # Perform operations on locked records
end
```

This will generate SQL like this:

```sql
SELECT * FROM books WHERE books.out_of_print = 1 FOR UPDATE
```

### Pluck

Active Record allows you to retrieve a single column from the database using the [`pluck`][] method. This can be useful when you only need a specific attribute of the records.

For example, to retrieve the titles of all books:

```ruby
Book.pluck(:title)
```

This will generate SQL like this:

```sql
SELECT title FROM books
```

You can also retrieve multiple columns:

```ruby
Book.pluck(:title, :author)
```

This will generate SQL like this:

```sql
SELECT title, author FROM books
```

### Calculations

Active Record allows you to perform calculations on the records retrieved from the database using the [`calculate`][] method. This can be useful when you need to retrieve aggregate values, such as the sum, average, or maximum of a column.

For example, to retrieve the total number of books:

```ruby
Book.calculate(:count, :all)
```

This will generate SQL like this:

```sql
SELECT COUNT(*) FROM books
```

You can also perform calculations on a specific column:

```ruby
Book.calculate(:sum, :price)
```

This will generate SQL like this:

```sql
SELECT SUM(price) FROM books
```

You can also specify conditions on the records to be included in the calculation:

```ruby
Book.calculate(:count, :all, conditions: { out_of_print: true })
```

This will generate SQL like this:

```sql
SELECT COUNT(*) FROM books WHERE books.out_of_print = 1
```

### Batches

Active Record allows you to retrieve records from the database in batches using the [`find_each`][] and [`find_in_batches`][] methods. This can be useful when you need to process a large number of records without loading them all into memory at once.

For example, to process all books in batches of 100:

```ruby
Book.find_each(batch_size: 100) do |book|
  # Process book
end
```

You can also use the `find_in_batches` method to retrieve records in batches:

```ruby
Book.find_in_batches(batch_size: 100) do |books|
  # Process batch of books
end
```

Both methods will retrieve records in batches and yield them to the block for processing. This allows you to work with a subset of records at a time, reducing memory usage.

### Transactions

Active Record allows you to perform multiple database operations within a single transaction using the [`transaction`][] method. This ensures that all operations are committed or rolled back as a single unit.

For example, to create a new book and update an existing author within a transaction:

```ruby
Book.transaction do
  book = Book.create(title: "New Book")
  author = Author.find(1)
  author.update(name: "New Name")
end
```

If any of the operations within the transaction fail, the entire transaction will be rolled back and no changes will be made to the database.

### Raw SQL Queries

Active Record allows you to execute raw SQL queries using the [`find_by_sql`][] method. This can be useful when you need to perform complex queries that cannot be expressed using the Active Record query interface.

For example, to retrieve all books with a title containing the word "Rails":

```ruby
Book.find_by_sql("SELECT * FROM books WHERE title LIKE '%Rails%'")
```

This will execute the raw SQL query and return an array of Book objects.

You can also use the [`exec_query`][] method to execute a raw SQL query and return a result object:

```ruby
result = Book.connection.exec_query("SELECT * FROM books WHERE title LIKE '%Rails%'")
```

This will execute the raw SQL query and return a result object that can be used to access the query results.

### Conclusion

Active Record provides a powerful and flexible interface for querying and manipulating database records. By understanding and utilizing the various query methods and options available, you can write efficient and expressive code for working with your database.
```irb
irb> Book.order("title ASC").order("created_at DESC")
SELECT * FROM books ORDER BY title ASC, created_at DESC
```

ADVERTENCIA: En la mayoría de los sistemas de bases de datos, al seleccionar campos con `distinct` de un conjunto de resultados utilizando métodos como `select`, `pluck` e `ids`; el método `order` generará una excepción `ActiveRecord::StatementInvalid` a menos que el campo(s) utilizado(s) en la cláusula `order` estén incluidos en la lista de selección. Consulte la siguiente sección para seleccionar campos del conjunto de resultados.

Selección de campos específicos
-------------------------

Por defecto, `Model.find` selecciona todos los campos del conjunto de resultados utilizando `select *`.

Para seleccionar solo un subconjunto de campos del conjunto de resultados, puede especificar el subconjunto a través del método [`select`][].

Por ejemplo, para seleccionar solo las columnas `isbn` y `out_of_print`:

```ruby
Book.select(:isbn, :out_of_print)
# O
Book.select("isbn, out_of_print")
```

La consulta SQL utilizada por esta llamada a `find` será algo así:

```sql
SELECT isbn, out_of_print FROM books
```

Tenga cuidado porque esto también significa que está inicializando un objeto de modelo con solo los campos que ha seleccionado. Si intenta acceder a un campo que no está en el registro inicializado, recibirá:

```
ActiveModel::MissingAttributeError: missing attribute '<attribute>' for Book
```

Donde `<attribute>` es el atributo que solicitó. El método `id` no generará la excepción `ActiveRecord::MissingAttributeError`, así que tenga cuidado al trabajar con asociaciones porque necesitan el método `id` para funcionar correctamente.

Si desea obtener solo un registro único por valor único en un campo determinado, puede usar [`distinct`][]:

```ruby
Customer.select(:last_name).distinct
```

Esto generaría SQL como:

```sql
SELECT DISTINCT last_name FROM customers
```

También puede eliminar la restricción de unicidad:

```ruby
# Devuelve last_names únicos
query = Customer.select(:last_name).distinct

# Devuelve todos los last_names, incluso si hay duplicados
query.distinct(false)
```

Límite y desplazamiento
----------------

Para aplicar `LIMIT` a la consulta SQL generada por `Model.find`, puede especificar el `LIMIT` utilizando los métodos [`limit`][] y [`offset`][] en la relación.

Puede usar `limit` para especificar el número de registros que se van a recuperar y usar `offset` para especificar el número de registros que se deben omitir antes de comenzar a devolver los registros. Por ejemplo

```ruby
Customer.limit(5)
```

devolverá un máximo de 5 clientes y, como no especifica ningún desplazamiento, devolverá los primeros 5 de la tabla. La consulta SQL que ejecuta se ve así:

```sql
SELECT * FROM customers LIMIT 5
```

Agregando `offset` a eso

```ruby
Customer.limit(5).offset(30)
```

en cambio, devolverá un máximo de 5 clientes a partir del 31º. El SQL se ve así:

```sql
SELECT * FROM customers LIMIT 5 OFFSET 30
```

Agrupamiento
--------

Para aplicar una cláusula `GROUP BY` a la consulta SQL generada por el buscador, puede usar el método [`group`][].

Por ejemplo, si desea encontrar una colección de las fechas en las que se crearon los pedidos:

```ruby
Order.select("created_at").group("created_at")
```

Y esto le dará un objeto `Order` único para cada fecha en la que haya pedidos en la base de datos.

La consulta SQL que se ejecutaría sería algo así:

```sql
SELECT created_at
FROM orders
GROUP BY created_at
```

### Total de elementos agrupados

Para obtener el total de elementos agrupados en una sola consulta, llame a [`count`][] después del `group`.

```irb
irb> Order.group(:status).count
=> {"being_packed"=>7, "shipped"=>12}
```

La consulta SQL que se ejecutaría sería algo así:

```sql
SELECT COUNT (*) AS count_all, status AS status
FROM orders
GROUP BY status
```


### Condiciones HAVING

SQL utiliza la cláusula `HAVING` para especificar condiciones en los campos `GROUP BY`. Puede agregar la cláusula `HAVING` a la consulta SQL generada por `Model.find` agregando el método [`having`][] a la consulta.

Por ejemplo:

```ruby
Order.select("created_at, sum(total) as total_price").
  group("created_at").having("sum(total) > ?", 200)
```

La consulta SQL que se ejecutaría sería algo así:

```sql
SELECT created_at as ordered_date, sum(total) as total_price
FROM orders
GROUP BY created_at
HAVING sum(total) > 200
```

Esto devuelve la fecha y el precio total para cada objeto de pedido, agrupados por el día en que se realizaron y donde el total es superior a $200.

Puede acceder al `total_price` para cada objeto de pedido devuelto de esta manera:

```ruby
big_orders = Order.select("created_at, sum(total) as total_price")
                  .group("created_at")
                  .having("sum(total) > ?", 200)

big_orders[0].total_price
# Devuelve el precio total para el primer objeto de pedido
```

Anulación de condiciones
---------------------

### `unscope`

Puede especificar ciertas condiciones que se eliminarán utilizando el método [`unscope`][]. Por ejemplo:
```ruby
Book.where('id > 100').limit(20).order('id desc').unscope(:order)
```

El SQL que se ejecutaría:

```sql
SELECT * FROM books WHERE id > 100 LIMIT 20

-- Consulta original sin `unscope`
SELECT * FROM books WHERE id > 100 ORDER BY id desc LIMIT 20
```

También puedes eliminar cláusulas `where` específicas. Por ejemplo, esto eliminará la condición de `id` de la cláusula `where`:

```ruby
Book.where(id: 10, out_of_print: false).unscope(where: :id)
# SELECT books.* FROM books WHERE out_of_print = 0
```

Una relación que ha utilizado `unscope` afectará a cualquier relación en la que se fusiona:

```ruby
Book.order('id desc').merge(Book.unscope(:order))
# SELECT books.* FROM books
```


### `only`

También puedes anular condiciones utilizando el método [`only`][]. Por ejemplo:

```ruby
Book.where('id > 10').limit(20).order('id desc').only(:order, :where)
```

El SQL que se ejecutaría:

```sql
SELECT * FROM books WHERE id > 10 ORDER BY id DESC

-- Consulta original sin `only`
SELECT * FROM books WHERE id > 10 ORDER BY id DESC LIMIT 20
```


### `reselect`

El método [`reselect`][] anula una declaración de selección existente. Por ejemplo:

```ruby
Book.select(:title, :isbn).reselect(:created_at)
```

El SQL que se ejecutaría:

```sql
SELECT books.created_at FROM books
```

Compara esto con el caso en el que no se utiliza la cláusula `reselect`:

```ruby
Book.select(:title, :isbn).select(:created_at)
```

El SQL que se ejecutaría:

```sql
SELECT books.title, books.isbn, books.created_at FROM books
```

### `reorder`

El método [`reorder`][] anula el orden predeterminado del ámbito. Por ejemplo, si la definición de la clase incluye esto:

```ruby
class Author < ApplicationRecord
  has_many :books, -> { order(year_published: :desc) }
end
```

Y ejecutas esto:

```ruby
Author.find(10).books
```

El SQL que se ejecutaría:

```sql
SELECT * FROM authors WHERE id = 10 LIMIT 1
SELECT * FROM books WHERE author_id = 10 ORDER BY year_published DESC
```

Puedes usar la cláusula `reorder` para especificar una forma diferente de ordenar los libros:

```ruby
Author.find(10).books.reorder('year_published ASC')
```

El SQL que se ejecutaría:

```sql
SELECT * FROM authors WHERE id = 10 LIMIT 1
SELECT * FROM books WHERE author_id = 10 ORDER BY year_published ASC
```

### `reverse_order`

El método [`reverse_order`][] invierte la cláusula de orden si se especifica.

```ruby
Book.where("author_id > 10").order(:year_published).reverse_order
```

El SQL que se ejecutaría:

```sql
SELECT * FROM books WHERE author_id > 10 ORDER BY year_published DESC
```

Si no se especifica ninguna cláusula de orden en la consulta, `reverse_order` ordena por la clave primaria en orden inverso.

```ruby
Book.where("author_id > 10").reverse_order
```

El SQL que se ejecutaría:

```sql
SELECT * FROM books WHERE author_id > 10 ORDER BY books.id DESC
```

El método `reverse_order` no acepta **ningún** argumento.

### `rewhere`

El método [`rewhere`][] anula una condición `where` existente y nombrada. Por ejemplo:

```ruby
Book.where(out_of_print: true).rewhere(out_of_print: false)
```

El SQL que se ejecutaría:

```sql
SELECT * FROM books WHERE out_of_print = 0
```

Si no se utiliza la cláusula `rewhere`, las cláusulas `where` se combinan mediante el operador AND:

```ruby
Book.where(out_of_print: true).where(out_of_print: false)
```

El SQL que se ejecutaría:

```sql
SELECT * FROM books WHERE out_of_print = 1 AND out_of_print = 0
```



### `regroup`

El método [`regroup`][] anula una condición `group` existente y nombrada. Por ejemplo:

```ruby
Book.group(:author).regroup(:id)
```

El SQL que se ejecutaría:

```sql
SELECT * FROM books GROUP BY id
```

Si no se utiliza la cláusula `regroup`, las cláusulas `group` se combinan:

```ruby
Book.group(:author).group(:id)
```

El SQL que se ejecutaría:

```sql
SELECT * FROM books GROUP BY author, id
```



Relación nula
-------------

El método [`none`][] devuelve una relación encadenable sin registros. Cualquier condición posterior encadenada a la relación devuelta seguirá generando relaciones vacías. Esto es útil en escenarios donde necesitas una respuesta encadenable para un método o un ámbito que podría devolver cero resultados.

```ruby
Book.none # devuelve una Relación vacía y no realiza consultas.
```

```ruby
# Se espera que el método highlighted_reviews a continuación siempre devuelva una Relación.
Book.first.highlighted_reviews.average(:rating)
# => Devuelve la calificación promedio de un libro

class Book
  # Devuelve las reseñas si hay al menos 5,
  # de lo contrario, considera este libro como no reseñado
  def highlighted_reviews
    if reviews.count > 5
      reviews
    else
      Review.none # No cumple aún el umbral mínimo
    end
  end
end
```

Objetos de solo lectura
-----------------------

Active Record proporciona el método [`readonly`][] en una relación para prohibir explícitamente la modificación de cualquiera de los objetos devueltos. Cualquier intento de modificar un registro de solo lectura no tendrá éxito y generará una excepción `ActiveRecord::ReadOnlyRecord`.
```ruby
customer = Customer.readonly.first
customer.visits += 1
customer.save
```

Como `customer` está explícitamente configurado como un objeto de solo lectura, el código anterior generará una excepción `ActiveRecord::ReadOnlyRecord` al llamar a `customer.save` con un valor actualizado de _visits_.

Bloqueo de registros para actualización
--------------------------------------

El bloqueo es útil para prevenir condiciones de carrera al actualizar registros en la base de datos y garantizar actualizaciones atómicas.

Active Record proporciona dos mecanismos de bloqueo:

* Bloqueo optimista
* Bloqueo pesimista

### Bloqueo optimista

El bloqueo optimista permite que varios usuarios accedan al mismo registro para realizar ediciones y asume un mínimo de conflictos con los datos. Esto se logra verificando si otro proceso ha realizado cambios en un registro desde que se abrió. Se genera una excepción `ActiveRecord::StaleObjectError` si eso ha ocurrido y se ignora la actualización.

**Columna de bloqueo optimista**

Para utilizar el bloqueo optimista, la tabla debe tener una columna llamada `lock_version` de tipo entero. Cada vez que se actualiza el registro, Active Record incrementa la columna `lock_version`. Si se realiza una solicitud de actualización con un valor menor en el campo `lock_version` que el que se encuentra actualmente en la columna `lock_version` en la base de datos, la solicitud de actualización fallará con una excepción `ActiveRecord::StaleObjectError`.

Por ejemplo:

```ruby
c1 = Customer.find(1)
c2 = Customer.find(1)

c1.first_name = "Sandra"
c1.save

c2.first_name = "Michael"
c2.save # Genera una excepción ActiveRecord::StaleObjectError
```

Entonces, es responsabilidad del programador manejar el conflicto rescatando la excepción y ya sea deshaciendo los cambios, fusionándolos o aplicando la lógica de negocio necesaria para resolver el conflicto.

Este comportamiento se puede desactivar configurando `ActiveRecord::Base.lock_optimistically = false`.

Para cambiar el nombre de la columna `lock_version`, `ActiveRecord::Base` proporciona un atributo de clase llamado `locking_column`:

```ruby
class Customer < ApplicationRecord
  self.locking_column = :lock_customer_column
end
```

### Bloqueo pesimista

El bloqueo pesimista utiliza un mecanismo de bloqueo proporcionado por la base de datos subyacente. Al utilizar `lock` al construir una relación, se obtiene un bloqueo exclusivo en las filas seleccionadas. Las relaciones que utilizan `lock` generalmente se envuelven dentro de una transacción para evitar condiciones de bloqueo.

Por ejemplo:

```ruby
Book.transaction do
  book = Book.lock.first
  book.title = 'Algorithms, second edition'
  book.save!
end
```

La sesión anterior produce la siguiente consulta SQL para una base de datos MySQL:

```sql
SQL (0.2ms)   BEGIN
Book Load (0.3ms)   SELECT * FROM books LIMIT 1 FOR UPDATE
Book Update (0.4ms)   UPDATE books SET updated_at = '2009-02-07 18:05:56', title = 'Algorithms, second edition' WHERE id = 1
SQL (0.8ms)   COMMIT
```

También puedes pasar SQL sin procesar al método `lock` para permitir diferentes tipos de bloqueos. Por ejemplo, MySQL tiene una expresión llamada `LOCK IN SHARE MODE` donde puedes bloquear un registro pero permitir que otras consultas lo lean. Para especificar esta expresión, simplemente pásala como opción de bloqueo:

```ruby
Book.transaction do
  book = Book.lock("LOCK IN SHARE MODE").find(1)
  book.increment!(:views)
end
```

NOTA: Ten en cuenta que tu base de datos debe admitir el SQL sin procesar que pasas al método `lock`.

Si ya tienes una instancia de tu modelo, puedes iniciar una transacción y adquirir el bloqueo de una sola vez utilizando el siguiente código:

```ruby
book = Book.first
book.with_lock do
  # Este bloque se ejecuta dentro de una transacción,
  # el libro ya está bloqueado.
  book.increment!(:views)
end
```

Unir tablas
-----------

Active Record proporciona dos métodos de búsqueda para especificar cláusulas `JOIN` en el SQL resultante: `joins` y `left_outer_joins`.
Mientras que `joins` se utiliza para `INNER JOIN` o consultas personalizadas,
`left_outer_joins` se utiliza para consultas que utilizan `LEFT OUTER JOIN`.

### `joins`

Hay varias formas de utilizar el método [`joins`][].

#### Usando un fragmento de SQL en cadena

Puedes simplemente proporcionar el SQL sin procesar que especifica la cláusula `JOIN` a `joins`:

```ruby
Author.joins("INNER JOIN books ON books.author_id = authors.id AND books.out_of_print = FALSE")
```

Esto dará como resultado el siguiente SQL:

```sql
SELECT authors.* FROM authors INNER JOIN books ON books.author_id = authors.id AND books.out_of_print = FALSE
```

#### Usando un array/Hash de asociaciones con nombres

Active Record te permite utilizar los nombres de las [asociaciones](association_basics.html) definidas en el modelo como un atajo para especificar cláusulas `JOIN` para esas asociaciones al utilizar el método `joins`.

Todas las siguientes producirán las consultas de unión esperadas utilizando `INNER JOIN`:

##### Unir una sola asociación

```ruby
Book.joins(:reviews)
```

Esto produce:

```sql
SELECT books.* FROM books
  INNER JOIN reviews ON reviews.book_id = books.id
```

O, en español: "devuelve un objeto Book para todos los libros con reseñas". Ten en cuenta que verás libros duplicados si un libro tiene más de una reseña. Si quieres libros únicos, puedes usar `Book.joins(:reviews).distinct`.
#### Uniendo múltiples asociaciones

```ruby
Book.joins(:author, :reviews)
```

Esto produce:

```sql
SELECT books.* FROM books
  INNER JOIN authors ON authors.id = books.author_id
  INNER JOIN reviews ON reviews.book_id = books.id
```

O, en español: "devuelve todos los libros con su autor que tienen al menos una reseña". Nuevamente, tenga en cuenta que los libros con múltiples reseñas aparecerán varias veces.

##### Uniendo asociaciones anidadas (un solo nivel)

```ruby
Book.joins(reviews: :customer)
```

Esto produce:

```sql
SELECT books.* FROM books
  INNER JOIN reviews ON reviews.book_id = books.id
  INNER JOIN customers ON customers.id = reviews.customer_id
```

O, en español: "devuelve todos los libros que tienen una reseña de un cliente".

##### Uniendo asociaciones anidadas (varios niveles)

```ruby
Author.joins(books: [{ reviews: { customer: :orders } }, :supplier])
```

Esto produce:

```sql
SELECT * FROM authors
  INNER JOIN books ON books.author_id = authors.id
  INNER JOIN reviews ON reviews.book_id = books.id
  INNER JOIN customers ON customers.id = reviews.customer_id
  INNER JOIN orders ON orders.customer_id = customers.id
INNER JOIN suppliers ON suppliers.id = books.supplier_id
```

O, en español: "devuelve todos los autores que tienen libros con reseñas _y_ han sido ordenados por un cliente, y los proveedores de esos libros".

#### Especificando condiciones en las tablas unidas

Puede especificar condiciones en las tablas unidas utilizando las condiciones regulares de [Array](#array-conditions) y [String](#pure-string-conditions). Las condiciones de [Hash](#hash-conditions) proporcionan una sintaxis especial para especificar condiciones para las tablas unidas:

```ruby
time_range = (Time.now.midnight - 1.day)..Time.now.midnight
Customer.joins(:orders).where('orders.created_at' => time_range).distinct
```

Esto encontrará todos los clientes que tienen pedidos que se crearon ayer, utilizando una expresión SQL `BETWEEN` para comparar `created_at`.

Una sintaxis alternativa y más limpia es anidar las condiciones de hash:

```ruby
time_range = (Time.now.midnight - 1.day)..Time.now.midnight
Customer.joins(:orders).where(orders: { created_at: time_range }).distinct
```

Para condiciones más avanzadas o para reutilizar un ámbito con nombre existente, se puede utilizar [`merge`][]. Primero, agreguemos un nuevo ámbito con nombre al modelo `Order`:

```ruby
class Order < ApplicationRecord
  belongs_to :customer

  scope :created_in_time_range, ->(time_range) {
    where(created_at: time_range)
  }
end
```

Ahora podemos usar `merge` para fusionar el ámbito `created_in_time_range`:

```ruby
time_range = (Time.now.midnight - 1.day)..Time.now.midnight
Customer.joins(:orders).merge(Order.created_in_time_range(time_range)).distinct
```

Esto encontrará todos los clientes que tienen pedidos que se crearon ayer, nuevamente utilizando una expresión SQL `BETWEEN`.

### `left_outer_joins`

Si desea seleccionar un conjunto de registros, independientemente de si tienen registros asociados o no, puede utilizar el método [`left_outer_joins`][].

```ruby
Customer.left_outer_joins(:reviews).distinct.select('customers.*, COUNT(reviews.*) AS reviews_count').group('customers.id')
```

Lo cual produce:

```sql
SELECT DISTINCT customers.*, COUNT(reviews.*) AS reviews_count FROM customers
LEFT OUTER JOIN reviews ON reviews.customer_id = customers.id GROUP BY customers.id
```

Lo que significa: "devuelve todos los clientes con su cuenta de reseñas, independientemente de si tienen o no reseñas".

### `where.associated` y `where.missing`

Los métodos de consulta `associated` y `missing` le permiten seleccionar un conjunto de registros basado en la presencia o ausencia de una asociación.

Para usar `where.associated`:

```ruby
Customer.where.associated(:reviews)
```

Produce:

```sql
SELECT customers.* FROM customers
INNER JOIN reviews ON reviews.customer_id = customers.id
WHERE reviews.id IS NOT NULL
```

Lo que significa "devuelve todos los clientes que han realizado al menos una reseña".

Para usar `where.missing`:

```ruby
Customer.where.missing(:reviews)
```

Produce:

```sql
SELECT customers.* FROM customers
LEFT OUTER JOIN reviews ON reviews.customer_id = customers.id
WHERE reviews.id IS NULL
```

Lo que significa "devuelve todos los clientes que no han realizado ninguna reseña".


Carga anticipada de asociaciones
--------------------------

La carga anticipada es el mecanismo para cargar los registros asociados de los objetos devueltos por `Model.find` utilizando la menor cantidad posible de consultas.

### Problema de las consultas N + 1

Considere el siguiente código, que encuentra 10 libros e imprime los apellidos de sus autores:

```ruby
books = Book.limit(10)

books.each do |book|
  puts book.author.last_name
end
```

Este código parece estar bien a primera vista. Pero el problema radica en el número total de consultas ejecutadas. El código anterior ejecuta 1 (para encontrar 10 libros) + 10 (uno por cada libro para cargar el autor) = **11** consultas en total.

#### Solución al problema de las consultas N + 1

Active Record le permite especificar de antemano todas las asociaciones que se van a cargar.

Los métodos son:

* [`includes`][]
* [`preload`][]
* [`eager_load`][]

### `includes`

Con `includes`, Active Record asegura que todas las asociaciones especificadas se carguen utilizando la menor cantidad posible de consultas.

Revisitando el caso anterior utilizando el método `includes`, podríamos reescribir `Book.limit(10)` para cargar de forma anticipada los autores:

```ruby
books = Book.includes(:author).limit(10)

books.each do |book|
  puts book.author.last_name
end
```
El código anterior ejecutará solo **2** consultas, en lugar de las **11** consultas del caso original:

```sql
SELECT books.* FROM books LIMIT 10
SELECT authors.* FROM authors
  WHERE authors.book_id IN (1,2,3,4,5,6,7,8,9,10)
```

#### Carga ansiosa de múltiples asociaciones

Active Record te permite cargar ansiosamente cualquier número de asociaciones con una sola llamada a `Model.find` utilizando un array, hash o un hash anidado de array/hash con el método `includes`.

##### Array de múltiples asociaciones

```ruby
Customer.includes(:orders, :reviews)
```

Esto carga todos los clientes y los pedidos y reseñas asociados para cada uno.

##### Hash de asociaciones anidadas

```ruby
Customer.includes(orders: { books: [:supplier, :author] }).find(1)
```

Esto encontrará al cliente con id 1 y cargará ansiosamente todos los pedidos asociados, los libros de todos los pedidos y el autor y proveedor de cada libro.

#### Especificar condiciones en asociaciones cargadas ansiosamente

Aunque Active Record te permite especificar condiciones en las asociaciones cargadas ansiosamente al igual que en `joins`, la forma recomendada es usar [joins](#joining-tables) en su lugar.

Sin embargo, si es necesario hacer esto, puedes usar `where` como lo harías normalmente.

```ruby
Author.includes(:books).where(books: { out_of_print: true })
```

Esto generaría una consulta que contiene un `LEFT OUTER JOIN`, mientras que el método `joins` generaría uno utilizando la función `INNER JOIN` en su lugar.

```sql
  SELECT authors.id AS t0_r0, ... books.updated_at AS t1_r5 FROM authors LEFT OUTER JOIN books ON books.author_id = authors.id WHERE (books.out_of_print = 1)
```

Si no hubiera una condición `where`, esto generaría el conjunto normal de dos consultas.

NOTA: Usar `where` de esta manera solo funcionará cuando le pases un Hash. Para fragmentos SQL, necesitas usar `references` para forzar las tablas unidas:

```ruby
Author.includes(:books).where("books.out_of_print = true").references(:books)
```

Si, en el caso de esta consulta `includes`, no hubiera libros para ningún autor, todos los autores aún se cargarían. Al usar `joins` (un INNER JOIN), las condiciones de unión **deben** coincidir, de lo contrario no se devolverán registros.

NOTA: Si una asociación se carga ansiosamente como parte de una unión, cualquier campo de una cláusula de selección personalizada no estará presente en los modelos cargados. Esto se debe a que es ambiguo si deben aparecer en el registro padre o en el hijo.

### `preload`

Con `preload`, Active Record carga cada asociación especificada utilizando una consulta por asociación.

Revisando el problema de las consultas N + 1, podríamos reescribir `Book.limit(10)` para precargar los autores:

```ruby
books = Book.preload(:author).limit(10)

books.each do |book|
  puts book.author.last_name
end
```

El código anterior ejecutará solo **2** consultas, en lugar de las **11** consultas del caso original:

```sql
SELECT books.* FROM books LIMIT 10
SELECT authors.* FROM authors
  WHERE authors.book_id IN (1,2,3,4,5,6,7,8,9,10)
```

NOTA: El método `preload` utiliza un array, hash o un hash anidado de array/hash de la misma manera que el método `includes` para cargar cualquier número de asociaciones con una sola llamada a `Model.find`. Sin embargo, a diferencia del método `includes`, no es posible especificar condiciones para las asociaciones precargadas.

### `eager_load`

Con `eager_load`, Active Record carga todas las asociaciones especificadas utilizando un `LEFT OUTER JOIN`.

Revisando el caso donde ocurrió N + 1 utilizando el método `eager_load`, podríamos reescribir `Book.limit(10)` para los autores:

```ruby
books = Book.eager_load(:author).limit(10)

books.each do |book|
  puts book.author.last_name
end
```

El código anterior ejecutará solo **2** consultas, en lugar de las **11** consultas del caso original:

```sql
SELECT DISTINCT books.id FROM books LEFT OUTER JOIN authors ON authors.book_id = books.id LIMIT 10
SELECT books.id AS t0_r0, books.last_name AS t0_r1, ...
  FROM books LEFT OUTER JOIN authors ON authors.book_id = books.id
  WHERE books.id IN (1,2,3,4,5,6,7,8,9,10)
```

NOTA: El método `eager_load` utiliza un array, hash o un hash anidado de array/hash de la misma manera que el método `includes` para cargar cualquier número de asociaciones con una sola llamada a `Model.find`. Además, al igual que el método `includes`, puedes especificar condiciones para las asociaciones cargadas ansiosamente.

### `strict_loading`

La carga ansiosa puede evitar las consultas N + 1, pero aún puedes estar cargando perezosamente algunas asociaciones. Para asegurarte de que no se carguen perezosamente ninguna asociación, puedes habilitar [`strict_loading`][].

Al habilitar el modo de carga estricta en una relación, se generará un `ActiveRecord::StrictLoadingViolationError` si el registro intenta cargar perezosamente una asociación:

```ruby
user = User.strict_loading.first
user.comments.to_a # genera un ActiveRecord::StrictLoadingViolationError
```


Ámbitos
------
El ámbito permite especificar consultas comúnmente utilizadas que se pueden referenciar como llamadas de método en los objetos o modelos de asociación. Con estos ámbitos, se pueden utilizar todos los métodos previamente cubiertos, como `where`, `joins` e `includes`. Todos los cuerpos de ámbito deben devolver un objeto `ActiveRecord::Relation` o `nil` para permitir que se llamen a otros métodos (como otros ámbitos) sobre él.

Para definir un ámbito simple, utilizamos el método [`scope`][] dentro de la clase, pasando la consulta que nos gustaría ejecutar cuando se llame a este ámbito:

```ruby
class Book < ApplicationRecord
  scope :out_of_print, -> { where(out_of_print: true) }
end
```

Para llamar a este ámbito `out_of_print`, podemos llamarlo en la clase:

```irb
irb> Book.out_of_print
=> #<ActiveRecord::Relation> # todos los libros fuera de impresión
```

O en una asociación que consiste en objetos `Book`:

```irb
irb> author = Author.first
irb> author.books.out_of_print
=> #<ActiveRecord::Relation> # todos los libros fuera de impresión de `author`
```

Los ámbitos también se pueden encadenar dentro de otros ámbitos:

```ruby
class Book < ApplicationRecord
  scope :out_of_print, -> { where(out_of_print: true) }
  scope :out_of_print_and_expensive, -> { out_of_print.where("price > 500") }
end
```


### Pasando argumentos

Su ámbito puede tomar argumentos:

```ruby
class Book < ApplicationRecord
  scope :costs_more_than, ->(amount) { where("price > ?", amount) }
end
```

Llame al ámbito como si fuera un método de clase:

```irb
irb> Book.costs_more_than(100.10)
```

Sin embargo, esto solo duplica la funcionalidad que se le proporcionaría mediante un método de clase.

```ruby
class Book < ApplicationRecord
  def self.costs_more_than(amount)
    where("price > ?", amount)
  end
end
```

Estos métodos seguirán siendo accesibles en los objetos de asociación:

```irb
irb> author.books.costs_more_than(100.10)
```

### Uso de condicionales

Su ámbito puede utilizar condicionales:

```ruby
class Order < ApplicationRecord
  scope :created_before, ->(time) { where(created_at: ...time) if time.present? }
end
```

Al igual que los otros ejemplos, esto se comportará de manera similar a un método de clase.

```ruby
class Order < ApplicationRecord
  def self.created_before(time)
    where(created_at: ...time) if time.present?
  end
end
```

Sin embargo, hay una advertencia importante: un ámbito siempre devolverá un objeto `ActiveRecord::Relation`, incluso si la condición se evalúa como `false`, mientras que un método de clase devolverá `nil`. Esto puede causar un `NoMethodError` al encadenar métodos de clase con condicionales, si alguno de los condicionales devuelve `false`.

### Aplicación de un ámbito predeterminado

Si deseamos que un ámbito se aplique en todas las consultas al modelo, podemos usar el método [`default_scope`][] dentro del propio modelo.

```ruby
class Book < ApplicationRecord
  default_scope { where(out_of_print: false) }
end
```

Cuando se ejecutan consultas en este modelo, la consulta SQL se verá así:

```sql
SELECT * FROM books WHERE (out_of_print = false)
```

Si necesita hacer cosas más complejas con un ámbito predeterminado, también puede definirlo como un método de clase:

```ruby
class Book < ApplicationRecord
  def self.default_scope
    # Debe devolver un objeto ActiveRecord::Relation.
  end
end
```

NOTA: El `default_scope` también se aplica al crear/construir un registro cuando se proporcionan los argumentos del ámbito como un `Hash`. No se aplica al actualizar un registro. Ej.:

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

Tenga en cuenta que, cuando se proporciona en formato `Array`, los argumentos de consulta de `default_scope` no se pueden convertir en un `Hash` para la asignación de atributos predeterminados. Ej.:

```ruby
class Book < ApplicationRecord
  default_scope { where("out_of_print = ?", false) }
end
```

```irb
irb> Book.new
=> #<Book id: nil, out_of_print: nil>
```


### Fusión de ámbitos

Al igual que las cláusulas `where`, los ámbitos se fusionan utilizando condiciones `AND`.

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

Podemos mezclar y combinar condiciones de `scope` y `where` y la consulta SQL final tendrá todas las condiciones unidas con `AND`.

```irb
irb> Book.in_print.where(price: ...100)
SELECT books.* FROM books WHERE books.out_of_print = 'false' AND books.price < 100
```

Si queremos que la última cláusula `where` sea la que prevalezca, se puede usar [`merge`][].

```irb
irb> Book.in_print.merge(Book.out_of_print)
SELECT books.* FROM books WHERE books.out_of_print = true
```

Una advertencia importante es que el `default_scope` se colocará al principio de las condiciones de `scope` y `where`.
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

Como se puede ver arriba, el `default_scope` se está fusionando en las condiciones de ambos `scope` y `where`.


### Eliminando todos los ámbitos

Si deseamos eliminar los ámbitos por cualquier motivo, podemos usar el método [`unscoped`][]. Esto es especialmente útil si se especifica un `default_scope` en el modelo y no se debe aplicar para esta consulta en particular.

```ruby
Book.unscoped.load
```

Este método elimina todos los ámbitos y realizará una consulta normal en la tabla.

```irb
irb> Book.unscoped.all
SELECT books.* FROM books

irb> Book.where(out_of_print: true).unscoped.all
SELECT books.* FROM books
```

`unscoped` también puede aceptar un bloque:

```irb
irb> Book.unscoped { Book.out_of_print }
SELECT books.* FROM books WHERE books.out_of_print
```


Buscadores dinámicos
---------------

Para cada campo (también conocido como atributo) que definas en tu tabla, Active Record proporciona un método buscador. Si tienes un campo llamado `first_name` en tu modelo `Customer`, por ejemplo, obtienes el método de instancia `find_by_first_name` de forma gratuita desde Active Record. Si también tienes un campo `locked` en el modelo `Customer`, también obtienes el método `find_by_locked`.

Puedes especificar un signo de exclamación (`!`) al final de los buscadores dinámicos para que generen un error `ActiveRecord::RecordNotFound` si no devuelven ningún registro, como `Customer.find_by_first_name!("Ryan")`

Si quieres buscar tanto por `first_name` como por `orders_count`, puedes encadenar estos buscadores simplemente escribiendo "`and`" entre los campos. Por ejemplo, `Customer.find_by_first_name_and_orders_count("Ryan", 5)`.

Enums
-----

Un enum te permite definir una matriz de valores para un atributo y referirte a ellos por nombre. El valor real almacenado en la base de datos es un entero que se ha asignado a uno de los valores.

Declarar un enum:

* Crea ámbitos que se pueden usar para encontrar todos los objetos que tienen o no tienen uno de los valores del enum.
* Crea un método de instancia que se puede usar para determinar si un objeto tiene un valor particular para el enum.
* Crea un método de instancia que se puede usar para cambiar el valor del enum de un objeto.

para todos los posibles valores de un enum.

Por ejemplo, dada esta declaración de [`enum`][]:

```ruby
class Order < ApplicationRecord
  enum :status, [:shipped, :being_packaged, :complete, :cancelled]
end
```

Estos [ámbitos](#scopes) se crean automáticamente y se pueden usar para encontrar todos los objetos con o sin un valor particular para `status`:

```irb
irb> Order.shipped
=> #<ActiveRecord::Relation> # todos los pedidos con status == :shipped
irb> Order.not_shipped
=> #<ActiveRecord::Relation> # todos los pedidos con status != :shipped
```

Estos métodos de instancia se crean automáticamente y consultan si el modelo tiene ese valor para el enum `status`:

```irb
irb> order = Order.shipped.first
irb> order.shipped?
=> true
irb> order.complete?
=> false
```

Estos métodos de instancia se crean automáticamente y primero actualizan el valor de `status` al valor nombrado y luego consultan si el estado se ha establecido correctamente en el valor:

```irb
irb> order = Order.first
irb> order.shipped!
UPDATE "orders" SET "status" = ?, "updated_at" = ? WHERE "orders"."id" = ?  [["status", 0], ["updated_at", "2019-01-24 07:13:08.524320"], ["id", 1]]
=> true
```

La documentación completa sobre enums se puede encontrar [aquí](https://api.rubyonrails.org/classes/ActiveRecord/Enum.html).


Entendiendo el encadenamiento de métodos
-----------------------------

El patrón Active Record implementa el [encadenamiento de métodos](https://en.wikipedia.org/wiki/Method_chaining),
que nos permite usar múltiples métodos de Active Record juntos de manera simple y directa.

Puedes encadenar métodos en una declaración cuando el método anterior llamado devuelve un
[`ActiveRecord::Relation`][], como `all`, `where` y `joins`. Los métodos que devuelven
un solo objeto (ver la sección [Recuperar un solo objeto](#recuperar-un-solo-objeto))
deben estar al final de la declaración.

A continuación, se muestran algunos ejemplos. Esta guía no cubrirá todas las posibilidades, solo algunas como ejemplos.
Cuando se llama a un método de Active Record, la consulta no se genera ni se envía a la base de datos de inmediato.
La consulta se envía solo cuando los datos realmente se necesitan. Por lo tanto, cada ejemplo a continuación genera una sola consulta.

### Recuperar datos filtrados de múltiples tablas
```ruby
Customer
  .select('customers.id, customers.last_name, reviews.body')
  .joins(:reviews)
  .where('reviews.created_at > ?', 1.week.ago)
```

El resultado debería ser algo como esto:

```sql
SELECT customers.id, customers.last_name, reviews.body
FROM customers
INNER JOIN reviews
  ON reviews.customer_id = customers.id
WHERE (reviews.created_at > '2019-01-08')
```

### Recuperando datos específicos de múltiples tablas

```ruby
Book
  .select('books.id, books.title, authors.first_name')
  .joins(:author)
  .find_by(title: 'Abstraction and Specification in Program Development')
```

Lo anterior debería generar:

```sql
SELECT books.id, books.title, authors.first_name
FROM books
INNER JOIN authors
  ON authors.id = books.author_id
WHERE books.title = $1 [["title", "Abstraction and Specification in Program Development"]]
LIMIT 1
```

NOTA: Tenga en cuenta que si una consulta coincide con varios registros, `find_by` solo obtendrá el primero e ignorará los demás (ver la declaración `LIMIT 1` anterior).

Encontrar o construir un nuevo objeto
------------------------------------

Es común que necesite encontrar un registro o crearlo si no existe. Puede hacerlo con los métodos `find_or_create_by` y `find_or_create_by!`.

### `find_or_create_by`

El método [`find_or_create_by`][] verifica si existe un registro con los atributos especificados. Si no existe, se llama a `create`. Veamos un ejemplo.

Supongamos que desea encontrar un cliente llamado "Andy" y, si no existe, crear uno. Puede hacerlo ejecutando:

```irb
irb> Customer.find_or_create_by(first_name: 'Andy')
=> #<Customer id: 5, first_name: "Andy", last_name: nil, title: nil, visits: 0, orders_count: nil, lock_version: 0, created_at: "2019-01-17 07:06:45", updated_at: "2019-01-17 07:06:45">
```

El SQL generado por este método se ve así:

```sql
SELECT * FROM customers WHERE (customers.first_name = 'Andy') LIMIT 1
BEGIN
INSERT INTO customers (created_at, first_name, locked, orders_count, updated_at) VALUES ('2011-08-30 05:22:57', 'Andy', 1, NULL, '2011-08-30 05:22:57')
COMMIT
```

`find_or_create_by` devuelve el registro que ya existe o el nuevo registro. En nuestro caso, no teníamos un cliente llamado Andy, por lo que se crea y devuelve el registro.

Es posible que el nuevo registro no se guarde en la base de datos; eso depende de si las validaciones se aprobaron o no (como `create`).

Supongamos que queremos establecer el atributo 'locked' en `false` si estamos creando un nuevo registro, pero no queremos incluirlo en la consulta. Entonces queremos encontrar al cliente llamado "Andy" o, si ese cliente no existe, crear un cliente llamado "Andy" que no esté bloqueado.

Podemos lograr esto de dos maneras. La primera es usar `create_with`:

```ruby
Customer.create_with(locked: false).find_or_create_by(first_name: 'Andy')
```

La segunda forma es usar un bloque:

```ruby
Customer.find_or_create_by(first_name: 'Andy') do |c|
  c.locked = false
end
```

El bloque solo se ejecutará si se está creando el cliente. La segunda vez que ejecutemos este código, se ignorará el bloque.


### `find_or_create_by!`

También puede usar [`find_or_create_by!`][] para generar una excepción si el nuevo registro no es válido. Las validaciones no se cubren en esta guía, pero supongamos por un momento que agrega temporalmente

```ruby
validates :orders_count, presence: true
```

a su modelo `Customer`. Si intenta crear un nuevo `Customer` sin pasar un `orders_count`, el registro será inválido y se generará una excepción:

```irb
irb> Customer.find_or_create_by!(first_name: 'Andy')
ActiveRecord::RecordInvalid: Validation failed: Orders count can’t be blank
```


### `find_or_initialize_by`

El método [`find_or_initialize_by`][] funcionará de manera similar a `find_or_create_by`, pero llamará a `new` en lugar de `create`. Esto significa que se creará una nueva instancia del modelo en la memoria pero no se guardará en la base de datos. Continuando con el ejemplo de `find_or_create_by`, ahora queremos al cliente llamado 'Nina':

```irb
irb> nina = Customer.find_or_initialize_by(first_name: 'Nina')
=> #<Customer id: nil, first_name: "Nina", orders_count: 0, locked: true, created_at: "2011-08-30 06:09:27", updated_at: "2011-08-30 06:09:27">

irb> nina.persisted?
=> false

irb> nina.new_record?
=> true
```

Como el objeto aún no se almacena en la base de datos, el SQL generado se ve así:

```sql
SELECT * FROM customers WHERE (customers.first_name = 'Nina') LIMIT 1
```

Cuando desee guardarlo en la base de datos, simplemente llame a `save`:

```irb
irb> nina.save
=> true
```


Búsqueda por SQL
----------------

Si desea utilizar su propio SQL para encontrar registros en una tabla, puede usar [`find_by_sql`][]. El método `find_by_sql` devolverá una matriz de objetos incluso si la consulta subyacente devuelve solo un registro. Por ejemplo, podría ejecutar esta consulta:

```irb
irb> Customer.find_by_sql("SELECT * FROM customers INNER JOIN orders ON customers.id = orders.customer_id ORDER BY customers.created_at desc")
=> [#<Customer id: 1, first_name: "Lucas" ...>, #<Customer id: 2, first_name: "Jan" ...>, ...]
```

`find_by_sql` te proporciona una forma sencilla de realizar llamadas personalizadas a la base de datos y recuperar objetos instanciados.


### `select_all`

`find_by_sql` tiene un método relacionado llamado [`connection.select_all`][]. `select_all` recuperará
objetos de la base de datos utilizando SQL personalizado al igual que `find_by_sql`, pero no los instanciará.
Este método devolverá una instancia de la clase `ActiveRecord::Result` y llamar a `to_a` en este
objeto te devolverá un array de hashes donde cada hash indica un registro.

```irb
irb> Customer.connection.select_all("SELECT first_name, created_at FROM customers WHERE id = '1'").to_a
=> [{"first_name"=>"Rafael", "created_at"=>"2012-11-10 23:23:45.281189"}, {"first_name"=>"Eileen", "created_at"=>"2013-12-09 11:22:35.221282"}]
```


### `pluck`

[`pluck`][] se puede utilizar para seleccionar el valor o valores de la(s) columna(s) con nombre en la relación actual. Acepta una lista de nombres de columna como argumento y devuelve un array de valores de las columnas especificadas con el tipo de datos correspondiente.

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

`pluck` permite reemplazar código como:

```ruby
Customer.select(:id).map { |c| c.id }
# o
Customer.select(:id).map(&:id)
# o
Customer.select(:id, :first_name).map { |c| [c.id, c.first_name] }
```

con:

```ruby
Customer.pluck(:id)
# o
Customer.pluck(:id, :first_name)
```

A diferencia de `select`, `pluck` convierte directamente un resultado de la base de datos en un `Array` de Ruby,
sin construir objetos `ActiveRecord`. Esto puede significar un mejor rendimiento para
una consulta grande o que se ejecuta con frecuencia. Sin embargo, cualquier anulación de método del modelo
no estará disponible. Por ejemplo:

```ruby
class Customer < ApplicationRecord
  def name
    "Soy #{first_name}"
  end
end
```

```irb
irb> Customer.select(:first_name).map &:name
=> ["Soy David", "Soy Jeremy", "Soy Jose"]

irb> Customer.pluck(:first_name)
=> ["David", "Jeremy", "Jose"]
```

No estás limitado a consultar campos de una sola tabla, también puedes consultar varias tablas.

```irb
irb> Order.joins(:customer, :books).pluck("orders.created_at, customers.email, books.title")
```

Además, a diferencia de `select` y otros ámbitos de `Relation`, `pluck` desencadena una consulta inmediata,
y por lo tanto no se puede encadenar con más ámbitos, aunque puede funcionar con
ámbitos ya construidos anteriormente:

```irb
irb> Customer.pluck(:first_name).limit(1)
NoMethodError: undefined method `limit' for #<Array:0x007ff34d3ad6d8>

irb> Customer.limit(1).pluck(:first_name)
=> ["David"]
```

NOTA: También debes saber que usar `pluck` desencadenará la carga ansiosa si el objeto de relación contiene valores de inclusión, incluso si la carga ansiosa no es necesaria para la consulta. Por ejemplo:

```irb
irb> assoc = Customer.includes(:reviews)
irb> assoc.pluck(:id)
SELECT "customers"."id" FROM "customers" LEFT OUTER JOIN "reviews" ON "reviews"."id" = "customers"."review_id"
```

Una forma de evitar esto es `unscope` los includes:

```irb
irb> assoc.unscope(:includes).pluck(:id)
```


### `pick`

[`pick`][] se puede utilizar para seleccionar el valor o valores de la(s) columna(s) con nombre en la relación actual. Acepta una lista de nombres de columna como argumento y devuelve la primera fila de los valores de columna especificados con el tipo de datos correspondiente.
`pick` es una forma abreviada de `relation.limit(1).pluck(*column_names).first`, que es especialmente útil cuando ya tienes una relación limitada a una fila.

`pick` permite reemplazar código como:

```ruby
Customer.where(id: 1).pluck(:id).first
```

con:

```ruby
Customer.where(id: 1).pick(:id)
```


### `ids`

[`ids`][] se puede utilizar para seleccionar todos los IDs de la relación utilizando la clave primaria de la tabla.

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


Existencia de objetos
--------------------

Si simplemente quieres verificar la existencia del objeto, hay un método llamado [`exists?`][].
Este método consultará la base de datos utilizando la misma consulta que `find`, pero en lugar de devolver un
objeto o una colección de objetos, devolverá `true` o `false`.

```ruby
Customer.exists?(1)
```

El método `exists?` también acepta múltiples valores, pero la trampa es que devolverá `true` si alguno
de esos registros existe.

```ruby
Customer.exists?(id: [1, 2, 3])
# o
Customer.exists?(first_name: ['Jane', 'Sergei'])
```

Incluso es posible usar `exists?` sin argumentos en un modelo o una relación.

```ruby
Customer.where(first_name: 'Ryan').exists?
```

Lo anterior devuelve `true` si hay al menos un cliente con el `first_name` 'Ryan' y `false`
en caso contrario.

```ruby
Customer.exists?
```

Lo anterior devuelve `false` si la tabla `customers` está vacía y `true` en caso contrario.

También puedes usar `any?` y `many?` para verificar la existencia en un modelo o relación. `many?` utilizará `count` de SQL para determinar si el elemento existe.
```ruby
# a través de un modelo
Order.any?
# SELECT 1 FROM orders LIMIT 1
Order.many?
# SELECT COUNT(*) FROM (SELECT 1 FROM orders LIMIT 2)

# a través de un ámbito nombrado
Order.shipped.any?
# SELECT 1 FROM orders WHERE orders.status = 0 LIMIT 1
Order.shipped.many?
# SELECT COUNT(*) FROM (SELECT 1 FROM orders WHERE orders.status = 0 LIMIT 2)

# a través de una relación
Book.where(out_of_print: true).any?
Book.where(out_of_print: true).many?

# a través de una asociación
Customer.first.orders.any?
Customer.first.orders.many?
```


Cálculos
------------

Esta sección utiliza [`count`][] como método de ejemplo en este preámbulo, pero las opciones descritas se aplican a todas las subsecciones.

Todos los métodos de cálculo funcionan directamente en un modelo:

```irb
irb> Customer.count
SELECT COUNT(*) FROM customers
```

O en una relación:

```irb
irb> Customer.where(first_name: 'Ryan').count
SELECT COUNT(*) FROM customers WHERE (first_name = 'Ryan')
```

También puedes usar varios métodos de búsqueda en una relación para realizar cálculos complejos:

```irb
irb> Customer.includes("orders").where(first_name: 'Ryan', orders: { status: 'shipped' }).count
```

Lo cual ejecutará:

```sql
SELECT COUNT(DISTINCT customers.id) FROM customers
  LEFT OUTER JOIN orders ON orders.customer_id = customers.id
  WHERE (customers.first_name = 'Ryan' AND orders.status = 0)
```

asumiendo que Order tiene `enum status: [ :shipped, :being_packed, :cancelled ]`.

### `count`

Si quieres ver cuántos registros hay en la tabla de tu modelo, puedes llamar a `Customer.count` y eso devolverá el número.
Si quieres ser más específico y encontrar todos los clientes con un título presente en la base de datos, puedes usar `Customer.count(:title)`.

Para opciones, por favor vea la sección principal, [Cálculos](#cálculos).

### `average`

Si quieres ver el promedio de un cierto número en una de tus tablas, puedes llamar al método [`average`][] en la clase que se relaciona con la tabla. Esta llamada al método se verá algo así:

```ruby
Order.average("subtotal")
```

Esto devolverá un número (posiblemente un número de punto flotante como 3.14159265) que representa el valor promedio en el campo.

Para opciones, por favor vea la sección principal, [Cálculos](#cálculos).


### `minimum`

Si quieres encontrar el valor mínimo de un campo en tu tabla, puedes llamar al método [`minimum`][] en la clase que se relaciona con la tabla. Esta llamada al método se verá algo así:

```ruby
Order.minimum("subtotal")
```

Para opciones, por favor vea la sección principal, [Cálculos](#cálculos).


### `maximum`

Si quieres encontrar el valor máximo de un campo en tu tabla, puedes llamar al método [`maximum`][] en la clase que se relaciona con la tabla. Esta llamada al método se verá algo así:

```ruby
Order.maximum("subtotal")
```

Para opciones, por favor vea la sección principal, [Cálculos](#cálculos).


### `sum`

Si quieres encontrar la suma de un campo para todos los registros en tu tabla, puedes llamar al método [`sum`][] en la clase que se relaciona con la tabla. Esta llamada al método se verá algo así:

```ruby
Order.sum("subtotal")
```

Para opciones, por favor vea la sección principal, [Cálculos](#cálculos).


Ejecutando EXPLAIN
---------------

Puedes ejecutar [`explain`][] en una relación. La salida de EXPLAIN varía para cada base de datos.

Por ejemplo, ejecutar

```ruby
Customer.where(id: 1).joins(:orders).explain
```

puede dar como resultado

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

en MySQL y MariaDB.

Active Record realiza una impresión en formato legible que emula la del
shell de la base de datos correspondiente. Por lo tanto, la misma consulta ejecutada con
el adaptador de PostgreSQL mostraría en su lugar

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

La carga temprana puede desencadenar más de una consulta en el fondo, y algunas consultas
pueden necesitar los resultados de consultas anteriores. Debido a eso, `explain` realmente
ejecuta la consulta y luego solicita los planes de consulta. Por ejemplo,
```ruby
Customer.where(id: 1).includes(:orders).explain
```

puede generar esto para MySQL y MariaDB:

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

1 fila en el conjunto (0.00 seg)

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


1 fila en el conjunto (0.00 seg)
```

y puede generar esto para PostgreSQL:

```
  Customer Load (0.3ms)  SELECT "customers".* FROM "customers" WHERE "customers"."id" = $1  [["id", 1]]
  Order Load (0.3ms)  SELECT "orders".* FROM "orders" WHERE "orders"."customer_id" = $1  [["customer_id", 1]]
=> EXPLAIN SELECT "customers".* FROM "customers" WHERE "customers"."id" = $1 [["id", 1]]
                                    QUERY PLAN
----------------------------------------------------------------------------------
 Index Scan using customers_pkey on customers  (cost=0.15..8.17 rows=1 width=164)
   Index Cond: (id = '1'::bigint)
(2 filas)
```


### Opciones de Explicación

Para bases de datos y adaptadores que las admiten (actualmente PostgreSQL y MySQL), se pueden pasar opciones para proporcionar un análisis más profundo.

Usando PostgreSQL, lo siguiente:

```ruby
Customer.where(id: 1).joins(:orders).explain(:analyze, :verbose)
```

produce:

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
(12 filas)
```

Usando MySQL o MariaDB, lo siguiente:

```ruby
Customer.where(id: 1).joins(:orders).explain(:analyze)
```

produce:

```sql
ANALYZE SELECT `shop_accounts`.* FROM `shop_accounts` INNER JOIN `customers` ON `customers`.`id` = `shop_accounts`.`customer_id` WHERE `shop_accounts`.`id` = 1
+----+-------------+-------+------+---------------+------+---------+------+------+--------+----------+------------+--------------------------------+
| id | select_type | table | type | possible_keys | key  | key_len | ref  | rows | r_rows | filtered | r_filtered | Extra                          |
+----+-------------+-------+------+---------------+------+---------+------+------+--------+----------+------------+--------------------------------+
|  1 | SIMPLE      | NULL  | NULL | NULL          | NULL | NULL    | NULL | NULL | NULL   | NULL     | NULL       | no matching row in const table |
+----+-------------+-------+------+---------------+------+---------+------+------+--------+----------+------------+--------------------------------+
1 fila en el conjunto (0.00 seg)
```

NOTA: Las opciones EXPLAIN y ANALYZE varían según las versiones de MySQL y MariaDB.
([MySQL 5.7][MySQL5.7-explain], [MySQL 8.0][MySQL8-explain], [MariaDB][MariaDB-explain])


### Interpretación de EXPLAIN

La interpretación de la salida de EXPLAIN está más allá del alcance de esta guía. Los siguientes consejos pueden ser útiles:

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
