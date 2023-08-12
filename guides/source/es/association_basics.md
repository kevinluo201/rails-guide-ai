**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 516604959485cfefb0e0d775d767699b
Asociaciones de Active Record
=============================

Esta guía cubre las características de asociación de Active Record.

Después de leer esta guía, sabrás cómo:

* Declarar asociaciones entre modelos de Active Record.
* Comprender los diferentes tipos de asociaciones de Active Record.
* Utilizar los métodos agregados a tus modelos mediante la creación de asociaciones.

--------------------------------------------------------------------------------

¿Por qué asociaciones?
-----------------------

En Rails, una _asociación_ es una conexión entre dos modelos de Active Record. ¿Por qué necesitamos asociaciones entre modelos? Porque hacen que las operaciones comunes sean más simples y fáciles en tu código.

Por ejemplo, considera una aplicación Rails simple que incluye un modelo para autores y un modelo para libros. Cada autor puede tener muchos libros.

Sin asociaciones, las declaraciones de los modelos se verían así:

```ruby
class Author < ApplicationRecord
end

class Book < ApplicationRecord
end
```

Ahora, supongamos que queremos agregar un nuevo libro para un autor existente. Necesitaríamos hacer algo como esto:

```ruby
@book = Book.create(published_at: Time.now, author_id: @author.id)
```

O considera eliminar un autor y asegurarte de que todos sus libros también se eliminen:

```ruby
@books = Book.where(author_id: @author.id)
@books.each do |book|
  book.destroy
end
@author.destroy
```

Con las asociaciones de Active Record, podemos simplificar estas - y otras - operaciones diciéndole declarativamente a Rails que hay una conexión entre los dos modelos. Aquí está el código revisado para configurar autores y libros:

```ruby
class Author < ApplicationRecord
  has_many :books, dependent: :destroy
end

class Book < ApplicationRecord
  belongs_to :author
end
```

Con este cambio, crear un nuevo libro para un autor en particular es más fácil:

```ruby
@book = @author.books.create(published_at: Time.now)
```

Eliminar un autor y todos sus libros es *mucho* más fácil:

```ruby
@author.destroy
```

Para obtener más información sobre los diferentes tipos de asociaciones, lee la siguiente sección de esta guía. A continuación, se presentan algunos consejos y trucos para trabajar con asociaciones, y luego una referencia completa a los métodos y opciones para asociaciones en Rails.

Los tipos de asociaciones
-------------------------

Rails admite seis tipos de asociaciones, cada una con un caso de uso particular en mente.

Aquí hay una lista de todos los tipos admitidos con un enlace a su documentación de API para obtener información más detallada sobre cómo usarlos, sus parámetros de método, etc.

* [`belongs_to`][]
* [`has_one`][]
* [`has_many`][]
* [`has_many :through`][`has_many`]
* [`has_one :through`][`has_one`]
* [`has_and_belongs_to_many`][]

Las asociaciones se implementan utilizando llamadas de estilo macro, para que puedas agregar características declarativamente a tus modelos. Por ejemplo, al declarar que un modelo `belongs_to` a otro, le indicas a Rails que mantenga la información de [Primary Key](https://en.wikipedia.org/wiki/Primary_key)-[Foreign Key](https://en.wikipedia.org/wiki/Foreign_key) entre las instancias de los dos modelos, y también obtienes una serie de métodos de utilidad agregados a tu modelo.

En el resto de esta guía, aprenderás cómo declarar y usar las diferentes formas de asociaciones. Pero primero, una breve introducción a las situaciones en las que cada tipo de asociación es apropiado.


### La asociación `belongs_to`

Una asociación [`belongs_to`][] establece una conexión con otro modelo, de modo que cada instancia del modelo declarante "pertenece a" una instancia del otro modelo. Por ejemplo, si tu aplicación incluye autores y libros, y cada libro puede ser asignado a exactamente un autor, declararías el modelo de libro de esta manera:

```ruby
class Book < ApplicationRecord
  belongs_to :author
end
```

![Diagrama de la asociación belongs_to](images/association_basics/belongs_to.png)

NOTA: Las asociaciones `belongs_to` _deben_ usar el término en singular. Si usaste la forma en plural en el ejemplo anterior para la asociación `author` en el modelo `Book` e intentaste crear la instancia mediante `Book.create(authors: author)`, se te informaría que hay una "constante no inicializada Book::Authors". Esto se debe a que Rails infiere automáticamente el nombre de la clase a partir del nombre de la asociación. Si el nombre de la asociación está incorrectamente en plural, entonces la clase inferida también estará incorrectamente en plural.

La migración correspondiente podría verse así:

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

Cuando se usa solo, `belongs_to` produce una conexión unidireccional uno a uno. Por lo tanto, cada libro en el ejemplo anterior "conoce" a su autor, pero los autores no conocen sus libros.
Para configurar una [asociación bidireccional](#asociaciones-bidireccionales), usa `belongs_to` en combinación con un `has_one` o `has_many` en el otro modelo, en este caso el modelo Author.

`belongs_to` no garantiza la consistencia de referencia si `optional` se establece en true, por lo que dependiendo del caso de uso, es posible que también necesites agregar una restricción de clave externa a nivel de base de datos en la columna de referencia, como esta:
```ruby
create_table :books do |t|
  t.belongs_to :author, foreign_key: true
  # ...
end
```

### La asociación `has_one`

Una asociación [`has_one`][] indica que otro modelo tiene una referencia a este modelo. Ese modelo se puede obtener a través de esta asociación.

Por ejemplo, si cada proveedor en tu aplicación tiene solo una cuenta, declararías el modelo de proveedor de la siguiente manera:

```ruby
class Supplier < ApplicationRecord
  has_one :account
end
```

La diferencia principal con `belongs_to` es que la columna de enlace `supplier_id` se encuentra en la otra tabla:

![Diagrama de la asociación has_one](images/association_basics/has_one.png)

La migración correspondiente podría verse así:

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

Dependiendo del caso de uso, es posible que también necesites crear un índice único y/o una restricción de clave externa en la columna de proveedor para la tabla de cuentas. En este caso, la definición de la columna podría verse así:

```ruby
create_table :accounts do |t|
  t.belongs_to :supplier, index: { unique: true }, foreign_key: true
  # ...
end
```

Esta relación puede ser [bidireccional](#asociaciones-bidireccionales) cuando se utiliza en combinación con `belongs_to` en el otro modelo.

### La asociación `has_many`

Una asociación [`has_many`][] es similar a `has_one`, pero indica una conexión de uno a muchos con otro modelo. A menudo encontrarás esta asociación en el "lado contrario" de una asociación `belongs_to`. Esta asociación indica que cada instancia del modelo tiene cero o más instancias de otro modelo. Por ejemplo, en una aplicación que contiene autores y libros, el modelo de autor se podría declarar de la siguiente manera:

```ruby
class Author < ApplicationRecord
  has_many :books
end
```

NOTA: El nombre del otro modelo se pluraliza al declarar una asociación `has_many`.

![Diagrama de la asociación has_many](images/association_basics/has_many.png)

La migración correspondiente podría verse así:

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

Dependiendo del caso de uso, generalmente es una buena idea crear un índice no único y opcionalmente una restricción de clave externa en la columna de autor para la tabla de libros:

```ruby
create_table :books do |t|
  t.belongs_to :author, index: true, foreign_key: true
  # ...
end
```

### La asociación `has_many :through`

Una asociación [`has_many :through`][`has_many`] se utiliza a menudo para establecer una conexión de muchos a muchos con otro modelo. Esta asociación indica que el modelo declarante se puede relacionar con cero o más instancias de otro modelo al pasar _a través_ de un tercer modelo. Por ejemplo, considera una práctica médica donde los pacientes hacen citas para ver a los médicos. Las declaraciones de asociación relevantes podrían verse así:

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

![Diagrama de la asociación has_many :through](images/association_basics/has_many_through.png)

La migración correspondiente podría verse así:

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

La colección de modelos de unión se puede gestionar a través de los [métodos de asociación `has_many`](#referencia-de-asociación-has-many).
Por ejemplo, si asignas:

```ruby
physician.patients = patients
```

Se crearán automáticamente nuevos modelos de unión para los objetos recién asociados.
Si algunos que existían previamente ahora faltan, entonces sus filas de unión se eliminan automáticamente.

ADVERTENCIA: La eliminación automática de modelos de unión es directa, no se activan los callbacks de eliminación.

La asociación `has_many :through` también es útil para configurar "atajos" a través de asociaciones anidadas `has_many`. Por ejemplo, si un documento tiene muchas secciones y una sección tiene muchos párrafos, a veces es posible que desees obtener una colección simple de todos los párrafos en el documento. Puedes configurarlo de la siguiente manera:

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

Con `through: :sections` especificado, Rails ahora entenderá:

```ruby
@document.paragraphs
```

### La asociación `has_one :through`

Una asociación [`has_one :through`][`has_one`] establece una conexión de uno a uno con otro modelo. Esta asociación indica que el modelo declarante se puede relacionar con una instancia de otro modelo al pasar _a través_ de un tercer modelo.
Por ejemplo, si cada proveedor tiene una cuenta y cada cuenta está asociada con un historial de cuenta, entonces el modelo de proveedor podría verse así:
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

![Diagrama de la asociación `has_one :through`](images/association_basics/has_one_through.png)

La migración correspondiente podría verse así:

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

### La asociación `has_and_belongs_to_many`

Una asociación [`has_and_belongs_to_many`][] crea una conexión directa de muchos a muchos con otro modelo, sin un modelo intermedio.
Esta asociación indica que cada instancia del modelo declarante se refiere a cero o más instancias de otro modelo.
Por ejemplo, si tu aplicación incluye ensamblajes y piezas, con cada ensamblaje teniendo muchas piezas y cada pieza apareciendo en muchos ensamblajes, podrías declarar los modelos de esta manera:

```ruby
class Assembly < ApplicationRecord
  has_and_belongs_to_many :parts
end

class Part < ApplicationRecord
  has_and_belongs_to_many :assemblies
end
```

![Diagrama de la asociación `has_and_belongs_to_many`](images/association_basics/habtm.png)

La migración correspondiente podría verse así:

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

### Elegir entre `belongs_to` y `has_one`

Si deseas establecer una relación uno a uno entre dos modelos, deberás agregar `belongs_to` a uno y `has_one` al otro. ¿Cómo sabes cuál es cuál?

La distinción radica en dónde colocas la clave externa (se coloca en la tabla para la clase que declara la asociación `belongs_to`), pero también debes pensar en el significado real de los datos. La relación `has_one` indica que uno de algo es tuyo, es decir, que algo apunta hacia ti. Por ejemplo, tiene más sentido decir que un proveedor es dueño de una cuenta que decir que una cuenta es dueña de un proveedor. Esto sugiere que las relaciones correctas son las siguientes:

```ruby
class Supplier < ApplicationRecord
  has_one :account
end

class Account < ApplicationRecord
  belongs_to :supplier
end
```

La migración correspondiente podría verse así:

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

NOTA: El uso de `t.bigint :supplier_id` hace que el nombre de la clave externa sea obvio y explícito. En las versiones actuales de Rails, puedes abstraer este detalle de implementación utilizando `t.references :supplier` en su lugar.

### Elegir entre `has_many :through` y `has_and_belongs_to_many`

Rails ofrece dos formas diferentes de declarar una relación de muchos a muchos entre modelos. La primera forma es utilizar `has_and_belongs_to_many`, que te permite hacer la asociación directamente:

```ruby
class Assembly < ApplicationRecord
  has_and_belongs_to_many :parts
end

class Part < ApplicationRecord
  has_and_belongs_to_many :assemblies
end
```

La segunda forma de declarar una relación de muchos a muchos es utilizar `has_many :through`. Esto hace la asociación indirectamente, a través de un modelo de unión:

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

La regla más simple es que debes configurar una relación `has_many :through` si necesitas trabajar con el modelo de relación como una entidad independiente. Si no necesitas hacer nada con el modelo de relación, puede ser más sencillo configurar una relación `has_and_belongs_to_many` (aunque deberás recordar crear la tabla de unión en la base de datos).

Debes usar `has_many :through` si necesitas validaciones, callbacks o atributos adicionales en el modelo de unión.

### Asociaciones polimórficas

Una variante ligeramente más avanzada de las asociaciones es la _asociación polimórfica_. Con las asociaciones polimórficas, un modelo puede pertenecer a más de un modelo, en una sola asociación. Por ejemplo, podrías tener un modelo de imagen que pertenece tanto a un modelo de empleado como a un modelo de producto. Así es como se podría declarar esto:

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

Puedes pensar en una declaración polimórfica `belongs_to` como configurar una interfaz que cualquier otro modelo puede usar. Desde una instancia del modelo `Employee`, puedes recuperar una colección de imágenes: `@employee.pictures`.
De manera similar, puedes recuperar `@product.pictures`.

Si tienes una instancia del modelo `Picture`, puedes acceder a su padre a través de `@picture.imageable`. Para que esto funcione, debes declarar tanto una columna de clave externa como una columna de tipo en el modelo que declara la interfaz polimórfica:

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

Esta migración se puede simplificar utilizando la forma `t.references`:

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

![Diagrama de Asociación Polimórfica](images/association_basics/polymorphic.png)

### Autoasociaciones

Al diseñar un modelo de datos, a veces encontrarás un modelo que debería tener una relación consigo mismo. Por ejemplo, es posible que desees almacenar a todos los empleados en un solo modelo de base de datos, pero poder rastrear relaciones como la de gerente y subordinados. Esta situación se puede modelar con asociaciones de autoasociación:

```ruby
class Employee < ApplicationRecord
  has_many :subordinates, class_name: "Employee",
                          foreign_key: "manager_id"

  belongs_to :manager, class_name: "Employee", optional: true
end
```

Con esta configuración, puedes recuperar `@employee.subordinates` y `@employee.manager`.

En tus migraciones/esquema, agregarás una columna de referencia al propio modelo.

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

NOTA: La opción `to_table` pasada a `foreign_key` y más se explican en [`SchemaStatements#add_reference`][connection.add_reference].

Consejos, trucos y advertencias
------------------------------

Aquí hay algunas cosas que debes saber para utilizar eficientemente las asociaciones de Active Record en tus aplicaciones de Rails:

* Controlar el almacenamiento en caché
* Evitar colisiones de nombres
* Actualizar el esquema
* Controlar el alcance de la asociación
* Asociaciones bidireccionales

### Controlar el almacenamiento en caché

Todos los métodos de asociación se basan en el almacenamiento en caché, que mantiene el resultado de la consulta más reciente disponible para otras operaciones. La caché incluso se comparte entre métodos. Por ejemplo:

```ruby
# recupera los libros de la base de datos
author.books.load

# utiliza la copia en caché de los libros
author.books.size

# utiliza la copia en caché de los libros
author.books.empty?
```

Pero, ¿qué sucede si quieres volver a cargar la caché porque los datos podrían haber cambiado en otra parte de la aplicación? Simplemente llama a `reload` en la asociación:

```ruby
# recupera los libros de la base de datos
author.books.load

# utiliza la copia en caché de los libros
author.books.size

# descarta la copia en caché de los libros y vuelve a la base de datos
author.books.reload.empty?
```

### Evitar colisiones de nombres

No eres libre de usar cualquier nombre para tus asociaciones. Debido a que crear una asociación agrega un método con ese nombre al modelo, es una mala idea darle a una asociación un nombre que ya se utiliza para un método de instancia de `ActiveRecord::Base`. El método de asociación anularía el método base y rompería las cosas. Por ejemplo, `attributes` o `connection` son malos nombres para asociaciones.

### Actualizar el esquema

Las asociaciones son extremadamente útiles, pero no son mágicas. Eres responsable de mantener tu esquema de base de datos para que coincida con tus asociaciones. En la práctica, esto significa dos cosas, dependiendo del tipo de asociaciones que estés creando. Para las asociaciones `belongs_to`, debes crear claves externas, y para las asociaciones `has_and_belongs_to_many`, debes crear la tabla de unión correspondiente.

#### Crear claves externas para las asociaciones `belongs_to`

Cuando declaras una asociación `belongs_to`, debes crear claves externas según corresponda. Por ejemplo, considera este modelo:

```ruby
class Book < ApplicationRecord
  belongs_to :author
end
```

Esta declaración debe respaldarse con una columna de clave externa correspondiente en la tabla de libros. Para una tabla completamente nueva, la migración podría verse así:

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

Mientras que para una tabla existente, podría verse así:

```ruby
class AddAuthorToBooks < ActiveRecord::Migration[7.1]
  def change
    add_reference :books, :author
  end
end
```

NOTA: Si deseas [imponer la integridad referencial a nivel de base de datos][foreign_keys], agrega la opción `foreign_key: true` a las declaraciones de columna 'reference' anteriores.

#### Crear tablas de unión para las asociaciones `has_and_belongs_to_many`

Si creas una asociación `has_and_belongs_to_many`, debes crear explícitamente la tabla de unión. A menos que el nombre de la tabla de unión se especifique explícitamente utilizando la opción `:join_table`, Active Record crea el nombre utilizando el orden léxico de los nombres de clase. Por lo tanto, una unión entre los modelos de autor y libro dará el nombre de tabla de unión predeterminado "authors_books" porque "a" tiene más prioridad que "b" en el orden léxico.
ADVERTENCIA: La precedencia entre los nombres de los modelos se calcula utilizando el operador `<=>` para `String`. Esto significa que si las cadenas tienen longitudes diferentes y las cadenas son iguales cuando se comparan hasta la longitud más corta, entonces la cadena más larga se considera de mayor precedencia léxica que la más corta. Por ejemplo, se esperaría que las tablas "paper_boxes" y "papers" generen un nombre de tabla de unión "papers_paper_boxes" debido a la longitud del nombre "paper_boxes", pero de hecho genera un nombre de tabla de unión "paper_boxes_papers" (porque el guión bajo '\_' es lexicográficamente _menor_ que 's' en las codificaciones comunes).

Sea cual sea el nombre, debes generar manualmente la tabla de unión con una migración adecuada. Por ejemplo, considera estas asociaciones:

```ruby
class Assembly < ApplicationRecord
  has_and_belongs_to_many :parts
end

class Part < ApplicationRecord
  has_and_belongs_to_many :assemblies
end
```

Estas asociaciones deben ser respaldadas por una migración para crear la tabla `assemblies_parts`. Esta tabla debe crearse sin una clave primaria:

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

Pasamos `id: false` a `create_table` porque esa tabla no representa un modelo. Eso es necesario para que la asociación funcione correctamente. Si observas algún comportamiento extraño en una asociación `has_and_belongs_to_many`, como IDs de modelo alterados o excepciones sobre IDs conflictivos, es probable que hayas olvidado ese detalle.

Para mayor simplicidad, también puedes usar el método `create_join_table`:

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

### Controlando el alcance de la asociación

Por defecto, las asociaciones buscan objetos solo dentro del alcance del módulo actual. Esto puede ser importante cuando declaras modelos de Active Record dentro de un módulo. Por ejemplo:

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

Esto funcionará bien, porque tanto la clase `Supplier` como la clase `Account` están definidas dentro del mismo alcance. Pero lo siguiente _no_ funcionará, porque `Supplier` y `Account` están definidos en alcances diferentes:

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

Para asociar un modelo con un modelo en un espacio de nombres diferente, debes especificar el nombre completo de la clase en tu declaración de asociación:

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

### Asociaciones bidireccionales

Es normal que las asociaciones funcionen en dos direcciones, requiriendo la declaración en dos modelos diferentes:

```ruby
class Author < ApplicationRecord
  has_many :books
end

class Book < ApplicationRecord
  belongs_to :author
end
```

Active Record intentará identificar automáticamente que estos dos modelos comparten una asociación bidireccional basada en el nombre de la asociación. Esta información permite a Active Record:

* Evitar consultas innecesarias para datos que ya están cargados:

    ```irb
    irb> author = Author.first
    irb> author.books.all? do |book|
    irb>   book.author.equal?(author) # No se ejecutan consultas adicionales aquí
    irb> end
    => true
    ```

* Evitar datos inconsistentes (ya que solo hay una copia del objeto `Author` cargado):

    ```irb
    irb> author = Author.first
    irb> book = author.books.first
    irb> author.name == book.author.name
    => true
    irb> author.name = "Nombre cambiado"
    irb> author.name == book.author.name
    => true
    ```

* Guardar automáticamente las asociaciones en más casos:

    ```irb
    irb> author = Author.new
    irb> book = author.books.new
    irb> book.save!
    irb> book.persisted?
    => true
    irb> author.persisted?
    => true
    ```

* Validar la [presencia](active_record_validations.html#presence) y [ausencia](active_record_validations.html#absence) de asociaciones en más casos:

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

Active Record admite la identificación automática de la mayoría de las asociaciones con nombres estándar. Sin embargo, las asociaciones bidireccionales que contienen las opciones `:through` o `:foreign_key` no se identificarán automáticamente.

Los ámbitos personalizados en la asociación opuesta también impiden la identificación automática, al igual que los ámbitos personalizados en la propia asociación a menos que se establezca [`config.active_record.automatic_scope_inversing`][] en true (el valor predeterminado para nuevas aplicaciones).

Por ejemplo, considera las siguientes declaraciones de modelos:

```ruby
class Author < ApplicationRecord
  has_many :books
end

class Book < ApplicationRecord
  belongs_to :writer, class_name: 'Author', foreign_key: 'author_id'
end
```

Debido a la opción `:foreign_key`, Active Record ya no reconocerá automáticamente la asociación bidireccional. Esto puede causar que tu aplicación:
* Ejecutar consultas innecesarias para los mismos datos (en este ejemplo, causando consultas N+1):

    ```irb
    irb> author = Author.first
    irb> author.books.any? do |book|
    irb>   book.author.equal?(author) # Esto ejecuta una consulta de autor por cada libro
    irb> end
    => false
    ```

* Hacer referencia a múltiples copias de un modelo con datos inconsistentes:

    ```irb
    irb> author = Author.first
    irb> book = author.books.first
    irb> author.name == book.author.name
    => true
    irb> author.name = "Nombre cambiado"
    irb> author.name == book.author.name
    => false
    ```

* Fallar al guardar automáticamente las asociaciones:

    ```irb
    irb> author = Author.new
    irb> book = author.books.new
    irb> book.save!
    irb> book.persisted?
    => true
    irb> author.persisted?
    => false
    ```

* Fallar al validar la presencia o ausencia:

    ```irb
    irb> author = Author.new
    irb> book = author.books.new
    irb> book.valid?
    => false
    irb> book.errors.full_messages
    => ["Author must exist"]
    ```

Active Record proporciona la opción `:inverse_of` para declarar explícitamente asociaciones bidireccionales:

```ruby
class Author < ApplicationRecord
  has_many :books, inverse_of: 'writer'
end

class Book < ApplicationRecord
  belongs_to :writer, class_name: 'Author', foreign_key: 'author_id'
end
```

Al incluir la opción `:inverse_of` en la declaración de la asociación `has_many`,
Active Record reconocerá la asociación bidireccional y se comportará como en
los ejemplos iniciales mencionados.


Referencia detallada de asociaciones
------------------------------------

Las siguientes secciones brindan detalles de cada tipo de asociación, incluyendo los métodos que agregan y las opciones que se pueden utilizar al declarar una asociación.

### Referencia de la asociación `belongs_to`

En términos de base de datos, la asociación `belongs_to` indica que la tabla de este modelo contiene una columna que representa una referencia a otra tabla.
Esto se puede utilizar para establecer relaciones uno a uno o uno a muchos, dependiendo de la configuración.
Si la tabla de la otra clase contiene la referencia en una relación uno a uno, entonces se debe usar `has_one` en su lugar.

#### Métodos agregados por `belongs_to`

Cuando se declara una asociación `belongs_to`, la clase que la declara automáticamente obtiene 8 métodos relacionados con la asociación:

* `association`
* `association=(associate)`
* `build_association(attributes = {})`
* `create_association(attributes = {})`
* `create_association!(attributes = {})`
* `reload_association`
* `reset_association`
* `association_changed?`
* `association_previously_changed?`

En todos estos métodos, `association` se reemplaza con el símbolo pasado como primer argumento a `belongs_to`. Por ejemplo, dado la declaración:

```ruby
class Book < ApplicationRecord
  belongs_to :author
end
```

Cada instancia del modelo `Book` tendrá estos métodos:

* `author`
* `author=`
* `build_author`
* `create_author`
* `create_author!`
* `reload_author`
* `reset_author`
* `author_changed?`
* `author_previously_changed?`

NOTA: Al inicializar una nueva asociación `has_one` o `belongs_to`, se debe utilizar el prefijo `build_` para construir la asociación, en lugar del método `association.build` que se utilizaría para las asociaciones `has_many` o `has_and_belongs_to_many`. Para crear uno, se utiliza el prefijo `create_`.

##### `association`

El método `association` devuelve el objeto asociado, si existe. Si no se encuentra ningún objeto asociado, devuelve `nil`.

```ruby
@author = @book.author
```

Si el objeto asociado ya ha sido recuperado de la base de datos para este objeto, se devolverá la versión en caché. Para anular este comportamiento (y forzar una lectura de la base de datos), se llama a `#reload_association` en el objeto padre.

```ruby
@author = @book.reload_author
```

Para descargar la versión en caché del objeto asociado, lo que provoca que el próximo acceso, si lo hay, lo consulte desde la base de datos, se llama a `#reset_association` en el objeto padre.

```ruby
@book.reset_author
```

##### `association=(associate)`

El método `association=` asigna un objeto asociado a este objeto. En segundo plano, esto significa extraer la clave primaria del objeto asociado y establecer la clave externa de este objeto con el mismo valor.

```ruby
@book.author = @author
```

##### `build_association(attributes = {})`

El método `build_association` devuelve un nuevo objeto del tipo asociado. Este objeto se instanciará a partir de los atributos pasados, y el enlace a través de la clave externa de este objeto se establecerá, pero el objeto asociado _no_ se guardará todavía.

```ruby
@author = @book.build_author(author_number: 123,
                             author_name: "John Doe")
```

##### `create_association(attributes = {})`

El método `create_association` devuelve un nuevo objeto del tipo asociado. Este objeto se instanciará a partir de los atributos pasados, se establecerá el enlace a través de la clave externa de este objeto y, una vez que pase todas las validaciones especificadas en el modelo asociado, se guardará el objeto asociado.

```ruby
@author = @book.create_author(author_number: 123,
                              author_name: "John Doe")
```

##### `create_association!(attributes = {})`

Hace lo mismo que `create_association` anteriormente, pero lanza `ActiveRecord::RecordInvalid` si el registro no es válido.

##### `association_changed?`

El método `association_changed?` devuelve true si se ha asignado un nuevo objeto asociado y la clave externa se actualizará en el próximo guardado.
```ruby
@book.author # => #<Author author_number: 123, author_name: "John Doe">
@book.author_changed? # => false

@book.author = Author.second # => #<Author author_number: 456, author_name: "Jane Smith">
@book.author_changed? # => true

@book.save!
@book.author_changed? # => false
```

##### `association_previously_changed?`

El método `association_previously_changed?` devuelve true si la última vez que se guardó se actualizó la asociación para hacer referencia a un nuevo objeto asociado.

```ruby
@book.author # => #<Author author_number: 123, author_name: "John Doe">
@book.author_previously_changed? # => false

@book.author = Author.second # => #<Author author_number: 456, author_name: "Jane Smith">
@book.save!
@book.author_previously_changed? # => true
```

#### Opciones para `belongs_to`

Aunque Rails utiliza valores predeterminados inteligentes que funcionarán bien en la mayoría de las situaciones, puede haber momentos en los que desee personalizar el comportamiento de la referencia de la asociación `belongs_to`. Estas personalizaciones se pueden realizar fácilmente pasando opciones y bloques de alcance al crear la asociación. Por ejemplo, esta asociación utiliza dos opciones:

```ruby
class Book < ApplicationRecord
  belongs_to :author, touch: :books_updated_at,
    counter_cache: true
end
```

La asociación [`belongs_to`][] admite estas opciones:

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

Si establece la opción `:autosave` en `true`, Rails guardará cualquier miembro de la asociación cargado y destruirá los miembros que estén marcados para su destrucción cada vez que guarde el objeto principal. Establecer `:autosave` en `false` no es lo mismo que no establecer la opción `:autosave`. Si la opción `:autosave` no está presente, entonces se guardarán los nuevos objetos asociados, pero no se guardarán los objetos asociados actualizados.

##### `:class_name`

Si el nombre del otro modelo no se puede derivar del nombre de la asociación, puede utilizar la opción `:class_name` para proporcionar el nombre del modelo. Por ejemplo, si un libro pertenece a un autor, pero el nombre real del modelo que contiene a los autores es `Patron`, se configuraría de la siguiente manera:

```ruby
class Book < ApplicationRecord
  belongs_to :author, class_name: "Patron"
end
```

##### `:counter_cache`

La opción `:counter_cache` se puede utilizar para hacer más eficiente la búsqueda del número de objetos asociados. Considere estos modelos:

```ruby
class Book < ApplicationRecord
  belongs_to :author
end

class Author < ApplicationRecord
  has_many :books
end
```

Con estas declaraciones, solicitar el valor de `@author.books.size` requiere hacer una llamada a la base de datos para realizar una consulta `COUNT(*)`. Para evitar esta llamada, puede agregar una caché de contador al modelo _perteneciente_:

```ruby
class Book < ApplicationRecord
  belongs_to :author, counter_cache: true
end

class Author < ApplicationRecord
  has_many :books
end
```

Con esta declaración, Rails mantendrá actualizado el valor de la caché y luego devolverá ese valor en respuesta al método `size`.

Aunque la opción `:counter_cache` se especifica en el modelo que incluye la declaración `belongs_to`, la columna real debe agregarse al modelo _asociado_ (`has_many`). En el caso anterior, debería agregar una columna llamada `books_count` al modelo `Author`.

Puede anular el nombre de columna predeterminado especificando un nombre de columna personalizado en la declaración `counter_cache` en lugar de `true`. Por ejemplo, para usar `count_of_books` en lugar de `books_count`:

```ruby
class Book < ApplicationRecord
  belongs_to :author, counter_cache: :count_of_books
end

class Author < ApplicationRecord
  has_many :books
end
```

NOTA: Solo necesita especificar la opción `:counter_cache` en el lado `belongs_to` de la asociación.

Las columnas de caché de contador se agregan a la lista de atributos de solo lectura del modelo propietario a través de `attr_readonly`.

Si por alguna razón cambia el valor de la clave principal de un modelo propietario y no actualiza también las claves externas de los modelos contados, entonces la caché de contador puede tener datos obsoletos. En otras palabras, cualquier modelo huérfano seguirá contando hacia el contador. Para solucionar una caché de contador obsoleta, use [`reset_counters`][].


##### `:dependent`

Si establece la opción `:dependent` en:

* `:destroy`, cuando se destruye el objeto, se llamará a `destroy` en sus objetos asociados.
* `:delete`, cuando se destruye el objeto, todos sus objetos asociados se eliminarán directamente de la base de datos sin llamar a su método `destroy`.
* `:destroy_async`: cuando se destruye el objeto, se encola un trabajo `ActiveRecord::DestroyAssociationAsyncJob` que llamará a `destroy` en sus objetos asociados. Active Job debe estar configurado para que esto funcione. No utilice esta opción si la asociación está respaldada por restricciones de clave externa en su base de datos. Las acciones de restricción de clave externa ocurrirán dentro de la misma transacción que elimina su propietario.
ADVERTENCIA: No debe especificar esta opción en una asociación `belongs_to` que esté conectada con una asociación `has_many` en la otra clase. Hacerlo puede llevar a registros huérfanos en su base de datos.

##### `:foreign_key`

Por convención, Rails asume que la columna utilizada para almacenar la clave externa en este modelo es el nombre de la asociación con el sufijo `_id` agregado. La opción `:foreign_key` te permite establecer directamente el nombre de la clave externa:

```ruby
class Book < ApplicationRecord
  belongs_to :author, class_name: "Patron",
                      foreign_key: "patron_id"
end
```

CONSEJO: En cualquier caso, Rails no creará columnas de clave externa por ti. Necesitas definirlas explícitamente como parte de tus migraciones.

##### `:primary_key`

Por convención, Rails asume que la columna `id` se utiliza para almacenar la clave primaria de sus tablas. La opción `:primary_key` te permite especificar una columna diferente.

Por ejemplo, supongamos que tenemos una tabla `users` con `guid` como clave primaria. Si queremos una tabla separada `todos` para almacenar la clave externa `user_id` en la columna `guid`, podemos usar `primary_key` para lograr esto de la siguiente manera:

```ruby
class User < ApplicationRecord
  self.primary_key = 'guid' # la clave primaria es guid y no id
end

class Todo < ApplicationRecord
  belongs_to :user, primary_key: 'guid'
end
```

Cuando ejecutamos `@user.todos.create`, el registro `@todo` tendrá su valor `user_id` como el valor `guid` de `@user`.

##### `:inverse_of`

La opción `:inverse_of` especifica el nombre de la asociación `has_many` o `has_one` que es la inversa de esta asociación. Consulta la sección de [asociaciones bidireccionales](#asociaciones-bidireccionales) para obtener más detalles.

```ruby
class Author < ApplicationRecord
  has_many :books, inverse_of: :author
end

class Book < ApplicationRecord
  belongs_to :author, inverse_of: :books
end
```

##### `:polymorphic`

Pasando `true` a la opción `:polymorphic` indica que esta es una asociación polimórfica. Las asociaciones polimórficas se discutieron en detalle <a href="#asociaciones-polimorficas">anteriormente en esta guía</a>.

##### `:touch`

Si estableces la opción `:touch` en `true`, entonces la marca de tiempo `updated_at` o `updated_on` en el objeto asociado se establecerá en la hora actual cada vez que se guarde o se elimine este objeto:

```ruby
class Book < ApplicationRecord
  belongs_to :author, touch: true
end

class Author < ApplicationRecord
  has_many :books
end
```

En este caso, guardar o eliminar un libro actualizará la marca de tiempo en el autor asociado. También puedes especificar un atributo de marca de tiempo particular para actualizar:

```ruby
class Book < ApplicationRecord
  belongs_to :author, touch: :books_updated_at
end
```

##### `:validate`

Si estableces la opción `:validate` en `true`, entonces los nuevos objetos asociados se validarán cada vez que guardes este objeto. Por defecto, esto es `false`: los nuevos objetos asociados no se validarán cuando se guarde este objeto.

##### `:optional`

Si estableces la opción `:optional` en `true`, entonces no se validará la presencia del objeto asociado. Por defecto, esta opción está establecida en `false`.

#### Alcances para `belongs_to`

Puede haber momentos en los que desees personalizar la consulta utilizada por `belongs_to`. Estas personalizaciones se pueden lograr a través de un bloque de alcance. Por ejemplo:

```ruby
class Book < ApplicationRecord
  belongs_to :author, -> { where active: true }
end
```

Puedes utilizar cualquiera de los métodos de consulta estándar [mencionados aquí](active_record_querying.html) dentro del bloque de alcance. Los siguientes se discuten a continuación:

* `where`
* `includes`
* `readonly`
* `select`

##### `where`

El método `where` te permite especificar las condiciones que el objeto asociado debe cumplir.

```ruby
class Book < ApplicationRecord
  belongs_to :author, -> { where active: true }
end
```

##### `includes`

Puedes utilizar el método `includes` para especificar asociaciones de segundo orden que deben cargarse de forma ansiosa cuando se utiliza esta asociación. Por ejemplo, considera estos modelos:

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

Si frecuentemente recuperas autores directamente desde capítulos (`@chapter.book.author`), puedes hacer tu código algo más eficiente incluyendo autores en la asociación de capítulos a libros:

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

NOTA: No es necesario utilizar `includes` para asociaciones inmediatas, es decir, si tienes `Book belongs_to :author`, entonces el autor se carga de forma ansiosa automáticamente cuando se necesita.

##### `readonly`

Si utilizas `readonly`, entonces el objeto asociado será de solo lectura cuando se recupere a través de la asociación.
##### `select`

El método `select` te permite anular la cláusula `SELECT` de SQL que se utiliza para recuperar datos sobre el objeto asociado. Por defecto, Rails recupera todas las columnas.

CONSEJO: Si utilizas el método `select` en una asociación `belongs_to`, también debes establecer la opción `:foreign_key` para garantizar los resultados correctos.

#### ¿Existen objetos asociados?

Puedes verificar si existen objetos asociados utilizando el método `association.nil?`:

```ruby
if @book.author.nil?
  @msg = "No se encontró un autor para este libro"
end
```

#### ¿Cuándo se guardan los objetos?

Asignar un objeto a una asociación `belongs_to` no guarda automáticamente el objeto. Tampoco guarda el objeto asociado.

### Referencia de la asociación `has_one`

La asociación `has_one` crea una coincidencia uno a uno con otro modelo. En términos de base de datos, esta asociación indica que la otra clase contiene la clave externa. Si esta clase contiene la clave externa, entonces debes usar `belongs_to` en su lugar.

#### Métodos agregados por `has_one`

Cuando declaras una asociación `has_one`, la clase que la declara automáticamente obtiene 6 métodos relacionados con la asociación:

* `association`
* `association=(associate)`
* `build_association(attributes = {})`
* `create_association(attributes = {})`
* `create_association!(attributes = {})`
* `reload_association`
* `reset_association`

En todos estos métodos, `association` se reemplaza con el símbolo pasado como primer argumento a `has_one`. Por ejemplo, dada la declaración:

```ruby
class Supplier < ApplicationRecord
  has_one :account
end
```

Cada instancia del modelo `Supplier` tendrá estos métodos:

* `account`
* `account=`
* `build_account`
* `create_account`
* `create_account!`
* `reload_account`
* `reset_account`

NOTA: Al inicializar una nueva asociación `has_one` o `belongs_to`, debes utilizar el prefijo `build_` para construir la asociación, en lugar del método `association.build` que se utilizaría para las asociaciones `has_many` o `has_and_belongs_to_many`. Para crear uno, utiliza el prefijo `create_`.

##### `association`

El método `association` devuelve el objeto asociado, si existe alguno. Si no se encuentra ningún objeto asociado, devuelve `nil`.

```ruby
@account = @supplier.account
```

Si el objeto asociado ya se ha recuperado de la base de datos para este objeto, se devolverá la versión en caché. Para anular este comportamiento (y forzar una lectura de la base de datos), llama a `#reload_association` en el objeto padre.

```ruby
@account = @supplier.reload_account
```

Para descargar la versión en caché del objeto asociado, forzando que la próxima vez que se acceda a él, si corresponde, se consulte desde la base de datos, llama a `#reset_association` en el objeto padre.

```ruby
@supplier.reset_account
```

##### `association=(associate)`

El método `association=` asigna un objeto asociado a este objeto. En segundo plano, esto significa extraer la clave primaria de este objeto y establecer la clave externa del objeto asociado con el mismo valor.

```ruby
@supplier.account = @account
```

##### `build_association(attributes = {})`

El método `build_association` devuelve un nuevo objeto del tipo asociado. Este objeto se instanciará a partir de los atributos pasados, y se establecerá el enlace a través de su clave externa, pero el objeto asociado _no_ se guardará todavía.

```ruby
@account = @supplier.build_account(terms: "Net 30")
```

##### `create_association(attributes = {})`

El método `create_association` devuelve un nuevo objeto del tipo asociado. Este objeto se instanciará a partir de los atributos pasados, se establecerá el enlace a través de su clave externa y, una vez que pase todas las validaciones especificadas en el modelo asociado, se guardará el objeto asociado.

```ruby
@account = @supplier.create_account(terms: "Net 30")
```

##### `create_association!(attributes = {})`

Hace lo mismo que `create_association` anteriormente, pero genera una excepción `ActiveRecord::RecordInvalid` si el registro no es válido.

#### Opciones para `has_one`

Si bien Rails utiliza valores predeterminados inteligentes que funcionarán bien en la mayoría de las situaciones, puede haber momentos en los que desees personalizar el comportamiento de la referencia de la asociación `has_one`. Estas personalizaciones se pueden realizar fácilmente pasando opciones al crear la asociación. Por ejemplo, esta asociación utiliza dos opciones:

```ruby
class Supplier < ApplicationRecord
  has_one :account, class_name: "Billing", dependent: :nullify
end
```

La asociación [`has_one`][] admite estas opciones:

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

Establecer la opción `:as` indica que esta es una asociación polimórfica. Las asociaciones polimórficas se discutieron en detalle [anteriormente en esta guía](#asociaciones-polimórficas).

##### `:autosave`

Si estableces la opción `:autosave` en `true`, Rails guardará los miembros de la asociación cargados y destruirá los miembros que estén marcados para su eliminación cada vez que guardes el objeto padre. Establecer `:autosave` en `false` no es lo mismo que no establecer la opción `:autosave`. Si la opción `:autosave` no está presente, los nuevos objetos asociados se guardarán, pero los objetos asociados actualizados no se guardarán.
##### `:class_name`

Si el nombre del otro modelo no se puede derivar del nombre de la asociación, puedes usar la opción `:class_name` para proporcionar el nombre del modelo. Por ejemplo, si un proveedor tiene una cuenta, pero el nombre real del modelo que contiene las cuentas es `Billing`, configurarías las cosas de esta manera:

```ruby
class Supplier < ApplicationRecord
  has_one :account, class_name: "Billing"
end
```

##### `:dependent`

Controla lo que sucede con el objeto asociado cuando su propietario es destruido:

* `:destroy` hace que el objeto asociado también sea destruido
* `:delete` hace que el objeto asociado sea eliminado directamente de la base de datos (por lo que los callbacks no se ejecutarán)
* `:destroy_async`: cuando el objeto es destruido, se encola un trabajo `ActiveRecord::DestroyAssociationAsyncJob` que llamará a destroy en sus objetos asociados. Active Job debe estar configurado para que esto funcione. No utilices esta opción si la asociación está respaldada por restricciones de clave externa en tu base de datos. Las acciones de restricción de clave externa ocurrirán dentro de la misma transacción que elimina su propietario.
* `:nullify` hace que la clave externa se establezca en `NULL`. La columna de tipo polimórfico también se establece en nulo en las asociaciones polimórficas. Los callbacks no se ejecutan.
* `:restrict_with_exception` provoca que se genere una excepción `ActiveRecord::DeleteRestrictionError` si hay un registro asociado
* `:restrict_with_error` provoca que se agregue un error al propietario si hay un objeto asociado

Es necesario no establecer o dejar la opción `:nullify` para aquellas asociaciones que tienen restricciones de base de datos `NOT NULL`. Si no estableces `dependent` para destruir tales asociaciones, no podrás cambiar el objeto asociado porque la clave externa del objeto asociado inicial se establecerá en el valor `NULL` no permitido.

##### `:foreign_key`

Por convención, Rails asume que la columna utilizada para almacenar la clave externa en el otro modelo es el nombre de este modelo con el sufijo `_id` agregado. La opción `:foreign_key` te permite establecer el nombre de la clave externa directamente:

```ruby
class Supplier < ApplicationRecord
  has_one :account, foreign_key: "supp_id"
end
```

CONSEJO: En cualquier caso, Rails no creará columnas de clave externa por ti. Debes definirlas explícitamente como parte de tus migraciones.

##### `:inverse_of`

La opción `:inverse_of` especifica el nombre de la asociación `belongs_to` que es la inversa de esta asociación.
Consulta la sección de [asociación bidireccional](#bi-directional-associations) para más detalles.

```ruby
class Supplier < ApplicationRecord
  has_one :account, inverse_of: :supplier
end

class Account < ApplicationRecord
  belongs_to :supplier, inverse_of: :account
end
```

##### `:primary_key`

Por convención, Rails asume que la columna utilizada para almacenar la clave primaria de este modelo es `id`. Puedes anular esto y especificar explícitamente la clave primaria con la opción `:primary_key`.

##### `:source`

La opción `:source` especifica el nombre de la asociación de origen para una asociación `has_one :through`.

##### `:source_type`

La opción `:source_type` especifica el tipo de asociación de origen para una asociación `has_one :through` que procede a través de una asociación polimórfica.

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

La opción `:through` especifica un modelo de unión a través del cual realizar la consulta. Las asociaciones `has_one :through` se discutieron en detalle [anteriormente en esta guía](#the-has-one-through-association).

##### `:touch`

Si estableces la opción `:touch` en `true`, la marca de tiempo `updated_at` o `updated_on` en el objeto asociado se establecerá en la hora actual cada vez que se guarde o destruya este objeto:

```ruby
class Supplier < ApplicationRecord
  has_one :account, touch: true
end

class Account < ApplicationRecord
  belongs_to :supplier
end
```

En este caso, guardar o destruir un proveedor actualizará la marca de tiempo en la cuenta asociada. También puedes especificar un atributo de marca de tiempo particular para actualizar:

```ruby
class Supplier < ApplicationRecord
  has_one :account, touch: :suppliers_updated_at
end
```

##### `:validate`

Si estableces la opción `:validate` en `true`, los nuevos objetos asociados se validarán cada vez que guardes este objeto. Por defecto, esto es `false`: los nuevos objetos asociados no se validarán cuando se guarde este objeto.

#### Alcances para `has_one`

Puede haber momentos en los que desees personalizar la consulta utilizada por `has_one`. Estas personalizaciones se pueden lograr a través de un bloque de alcance. Por ejemplo:

```ruby
class Supplier < ApplicationRecord
  has_one :account, -> { where active: true }
end
```
Puedes usar cualquiera de los métodos de consulta estándar [querying methods](active_record_querying.html) dentro del bloque de alcance. Los siguientes se discuten a continuación:

* `where`
* `includes`
* `readonly`
* `select`

##### `where`

El método `where` te permite especificar las condiciones que debe cumplir el objeto asociado.

```ruby
class Supplier < ApplicationRecord
  has_one :account, -> { where "confirmed = 1" }
end
```

##### `includes`

Puedes usar el método `includes` para especificar asociaciones de segundo orden que deben cargarse de forma ansiosa cuando se utiliza esta asociación. Por ejemplo, considera estos modelos:

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

Si recuperas frecuentemente representantes directamente de los proveedores (`@supplier.account.representative`), puedes hacer tu código un poco más eficiente incluyendo representantes en la asociación de proveedores a cuentas:

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

Si usas el método `readonly`, entonces el objeto asociado será de solo lectura cuando se recupere a través de la asociación.

##### `select`

El método `select` te permite anular la cláusula SQL `SELECT` que se utiliza para recuperar datos sobre el objeto asociado. Por defecto, Rails recupera todas las columnas.

#### ¿Existen objetos asociados?

Puedes ver si existen objetos asociados usando el método `association.nil?`:

```ruby
if @supplier.account.nil?
  @msg = "No se encontró ninguna cuenta para este proveedor"
end
```

#### ¿Cuándo se guardan los objetos?

Cuando asignas un objeto a una asociación `has_one`, ese objeto se guarda automáticamente (para actualizar su clave externa). Además, cualquier objeto que se reemplace también se guarda automáticamente, porque su clave externa también cambiará.

Si cualquiera de estos guardados falla debido a errores de validación, entonces la declaración de asignación devuelve `false` y la asignación en sí se cancela.

Si el objeto padre (el que declara la asociación `has_one`) no está guardado (es decir, `new_record?` devuelve `true`), entonces los objetos hijos no se guardan. Se guardarán automáticamente cuando se guarde el objeto padre.

Si quieres asignar un objeto a una asociación `has_one` sin guardar el objeto, usa el método `build_association`.

### Referencia de la asociación `has_many`

La asociación `has_many` crea una relación uno a muchos con otro modelo. En términos de base de datos, esta asociación indica que la otra clase tendrá una clave externa que se refiere a instancias de esta clase.

#### Métodos agregados por `has_many`

Cuando declaras una asociación `has_many`, la clase que la declara automáticamente obtiene 17 métodos relacionados con la asociación:

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

En todos estos métodos, `collection` se reemplaza con el símbolo pasado como primer argumento a `has_many`, y `collection_singular` se reemplaza con la versión singularizada de ese símbolo. Por ejemplo, dada la declaración:

```ruby
class Author < ApplicationRecord
  has_many :books
end
```

Cada instancia del modelo `Author` tendrá estos métodos:

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

El método `collection` devuelve una relación de todos los objetos asociados. Si no hay objetos asociados, devuelve una relación vacía.

```ruby
@books = @author.books
```

##### `collection<<(object, ...)`

El método [`collection<<`][] agrega uno o más objetos a la colección estableciendo sus claves externas en la clave primaria del modelo que llama.

```ruby
@author.books << @book1
```

##### `collection.delete(object, ...)`

El método [`collection.delete`][] elimina uno o más objetos de la colección estableciendo sus claves externas en `NULL`.

```ruby
@author.books.delete(@book1)
```

ADVERTENCIA: Además, los objetos se destruirán si están asociados con `dependent: :destroy`, y se eliminarán si están asociados con `dependent: :delete_all`.

##### `collection.destroy(object, ...)`

El método [`collection.destroy`][] elimina uno o más objetos de la colección ejecutando `destroy` en cada objeto.

```ruby
@author.books.destroy(@book1)
```

ADVERTENCIA: Los objetos siempre se eliminarán de la base de datos, ignorando la opción `:dependent`.

##### `collection=(objects)`

El método `collection=` hace que la colección contenga solo los objetos suministrados, agregando y eliminando según corresponda. Los cambios se persisten en la base de datos.
##### `collection_singular_ids`

El método `collection_singular_ids` devuelve un array de los ids de los objetos en la colección.

```ruby
@book_ids = @author.book_ids
```

##### `collection_singular_ids=(ids)`

El método `collection_singular_ids=` hace que la colección contenga solo los objetos identificados por los valores de clave primaria suministrados, agregando y eliminando según corresponda. Los cambios se guardan en la base de datos.

##### `collection.clear`

El método [`collection.clear`][] elimina todos los objetos de la colección según la estrategia especificada por la opción `dependent`. Si no se proporciona ninguna opción, sigue la estrategia predeterminada. La estrategia predeterminada para las asociaciones `has_many :through` es `delete_all`, y para las asociaciones `has_many` es establecer las claves foráneas en `NULL`.

```ruby
@author.books.clear
```

ADVERTENCIA: Los objetos se eliminarán si están asociados con `dependent: :destroy` o `dependent: :destroy_async`, al igual que con `dependent: :delete_all`.

##### `collection.empty?`

El método [`collection.empty?`][] devuelve `true` si la colección no contiene ningún objeto asociado.

```erb
<% if @author.books.empty? %>
  No se encontraron libros
<% end %>
```

##### `collection.size`

El método [`collection.size`][] devuelve el número de objetos en la colección.

```ruby
@book_count = @author.books.size
```

##### `collection.find(...)`

El método [`collection.find`][] encuentra objetos dentro de la tabla de la colección.

```ruby
@available_book = @author.books.find(1)
```

##### `collection.where(...)`

El método [`collection.where`][] encuentra objetos dentro de la colección basados en las condiciones suministradas, pero los objetos se cargan de forma diferida, lo que significa que la base de datos se consulta solo cuando se accede al objeto(s).

```ruby
@available_books = author.books.where(available: true) # No hay consulta aún
@available_book = @available_books.first # Ahora se consultará la base de datos
```

##### `collection.exists?(...)`

El método [`collection.exists?`][] verifica si existe un objeto que cumpla las condiciones suministradas en la tabla de la colección.

##### `collection.build(attributes = {})`

El método [`collection.build`][] devuelve uno o varios objetos nuevos del tipo asociado. El/los objeto(s) se instanciarán a partir de los atributos pasados, y se creará el enlace a través de su clave foránea, pero los objetos asociados _no_ se guardarán todavía.

```ruby
@book = author.books.build(published_at: Time.now,
                            book_number: "A12345")

@books = author.books.build([
  { published_at: Time.now, book_number: "A12346" },
  { published_at: Time.now, book_number: "A12347" }
])
```

##### `collection.create(attributes = {})`

El método [`collection.create`][] devuelve uno o varios objetos nuevos del tipo asociado. El/los objeto(s) se instanciarán a partir de los atributos pasados, se creará el enlace a través de su clave foránea y, una vez que pase todas las validaciones especificadas en el modelo asociado, el objeto asociado _se_ guardará.

```ruby
@book = author.books.create(published_at: Time.now,
                             book_number: "A12345")

@books = author.books.create([
  { published_at: Time.now, book_number: "A12346" },
  { published_at: Time.now, book_number: "A12347" }
])
```

##### `collection.create!(attributes = {})`

Hace lo mismo que `collection.create` anteriormente, pero genera una excepción `ActiveRecord::RecordInvalid` si el registro no es válido.

##### `collection.reload`

El método [`collection.reload`][] devuelve una relación de todos los objetos asociados, forzando una lectura de la base de datos. Si no hay objetos asociados, devuelve una relación vacía.

```ruby
@books = author.books.reload
```

#### Opciones para `has_many`

Si bien Rails utiliza valores predeterminados inteligentes que funcionarán bien en la mayoría de las situaciones, puede haber momentos en los que desee personalizar el comportamiento de la referencia de asociación `has_many`. Estas personalizaciones se pueden lograr fácilmente pasando opciones al crear la asociación. Por ejemplo, esta asociación utiliza dos opciones:

```ruby
class Author < ApplicationRecord
  has_many :books, dependent: :delete_all, validate: false
end
```

La asociación [`has_many`][] admite estas opciones:

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

Establecer la opción `:as` indica que esta es una asociación polimórfica, como se discutió [anteriormente en esta guía](#asociaciones-polimórficas).

##### `:autosave`

Si establece la opción `:autosave` en `true`, Rails guardará los miembros de la asociación cargados y destruirá los miembros que estén marcados para su eliminación cada vez que guarde el objeto padre. Establecer `:autosave` en `false` no es lo mismo que no establecer la opción `:autosave`. Si la opción `:autosave` no está presente, los nuevos objetos asociados se guardarán, pero los objetos asociados actualizados no se guardarán.

##### `:class_name`

Si el nombre del otro modelo no se puede derivar del nombre de la asociación, puede utilizar la opción `:class_name` para proporcionar el nombre del modelo. Por ejemplo, si un autor tiene muchos libros, pero el nombre real del modelo que contiene los libros es `Transaction`, lo configuraría de esta manera:

```ruby
class Author < ApplicationRecord
  has_many :books, class_name: "Transaction"
end
```
##### `:counter_cache`

Esta opción se puede utilizar para configurar un `:counter_cache` personalizado con un nombre específico. Solo necesitas esta opción cuando has personalizado el nombre de tu `:counter_cache` en la [asociación belongs_to](#options-for-belongs-to).

##### `:dependent`

Controla lo que sucede con los objetos asociados cuando su propietario es destruido:

* `:destroy` hace que todos los objetos asociados también sean destruidos.
* `:delete_all` hace que todos los objetos asociados sean eliminados directamente de la base de datos (por lo que los callbacks no se ejecutarán).
* `:destroy_async`: cuando el objeto es destruido, se encola un trabajo `ActiveRecord::DestroyAssociationAsyncJob` que llamará a destroy en sus objetos asociados. Active Job debe estar configurado para que esto funcione.
* `:nullify` hace que la clave foránea se establezca en `NULL`. La columna de tipo polimórfico también se establece en nulo en las asociaciones polimórficas. Los callbacks no se ejecutan.
* `:restrict_with_exception` provoca que se genere una excepción `ActiveRecord::DeleteRestrictionError` si hay algún registro asociado.
* `:restrict_with_error` provoca que se agregue un error al propietario si hay algún objeto asociado.

Las opciones `:destroy` y `:delete_all` también afectan la semántica de los métodos `collection.delete` y `collection=` al hacer que destruyan los objetos asociados cuando se eliminan de la colección.

##### `:foreign_key`

Por convención, Rails asume que la columna utilizada para almacenar la clave foránea en el otro modelo es el nombre de este modelo con el sufijo `_id` agregado. La opción `:foreign_key` te permite establecer directamente el nombre de la clave foránea:

```ruby
class Author < ApplicationRecord
  has_many :books, foreign_key: "cust_id"
end
```

CONSEJO: En cualquier caso, Rails no creará columnas de clave foránea por ti. Debes definirlas explícitamente como parte de tus migraciones.

##### `:inverse_of`

La opción `:inverse_of` especifica el nombre de la asociación `belongs_to` que es la inversa de esta asociación. Consulta la sección de [asociaciones bidireccionales](#bi-directional-associations) para obtener más detalles.

```ruby
class Author < ApplicationRecord
  has_many :books, inverse_of: :author
end

class Book < ApplicationRecord
  belongs_to :author, inverse_of: :books
end
```

##### `:primary_key`

Por convención, Rails asume que la columna utilizada para almacenar la clave primaria de la asociación es `id`. Puedes anular esto y especificar explícitamente la clave primaria con la opción `:primary_key`.

Supongamos que la tabla `users` tiene `id` como clave primaria pero también tiene una columna `guid`. El requisito es que la tabla `todos` debe contener el valor de la columna `guid` como clave foránea y no el valor `id`. Esto se puede lograr de la siguiente manera:

```ruby
class User < ApplicationRecord
  has_many :todos, primary_key: :guid
end
```

Ahora, si ejecutamos `@todo = @user.todos.create`, el valor de `user_id` en el registro `@todo` será el valor `guid` de `@user`.

##### `:source`

La opción `:source` especifica el nombre de la asociación de origen para una asociación `has_many :through`. Solo necesitas usar esta opción si el nombre de la asociación de origen no se puede inferir automáticamente a partir del nombre de la asociación.

##### `:source_type`

La opción `:source_type` especifica el tipo de asociación de origen para una asociación `has_many :through` que procede a través de una asociación polimórfica.

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

La opción `:through` especifica un modelo de unión a través del cual realizar la consulta. Las asociaciones `has_many :through` proporcionan una forma de implementar relaciones de muchos a muchos, como se discutió [anteriormente en esta guía](#the-has-many-through-association).

##### `:validate`

Si estableces la opción `:validate` en `false`, los nuevos objetos asociados no se validarán cuando guardes este objeto. De forma predeterminada, esto es `true`: los nuevos objetos asociados se validarán cuando se guarde este objeto.

#### Scopes para `has_many`

Puede haber momentos en los que desees personalizar la consulta utilizada por `has_many`. Estas personalizaciones se pueden lograr mediante un bloque de scope. Por ejemplo:

```ruby
class Author < ApplicationRecord
  has_many :books, -> { where processed: true }
end
```

Puedes utilizar cualquiera de los métodos de consulta estándar [active_record_querying.html](active_record_querying.html) dentro del bloque de scope. A continuación, se discuten los siguientes:

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

El método `where` te permite especificar las condiciones que debe cumplir el objeto asociado.

```ruby
class Author < ApplicationRecord
  has_many :confirmed_books, -> { where "confirmed = 1" },
    class_name: "Book"
end
```
También puedes establecer condiciones a través de un hash:

```ruby
class Author < ApplicationRecord
  has_many :confirmed_books, -> { where confirmed: true },
    class_name: "Book"
end
```

Si usas la opción `where` en estilo de hash, la creación de registros a través de esta asociación se limitará automáticamente utilizando el hash. En este caso, al utilizar `@author.confirmed_books.create` o `@author.confirmed_books.build`, se crearán libros donde la columna `confirmed` tenga el valor `true`.

##### `extending`

El método `extending` especifica un módulo con nombre para extender el proxy de la asociación. Las extensiones de asociación se discuten en detalle [más adelante en esta guía](#extensiones-de-asociación).

##### `group`

El método `group` proporciona un nombre de atributo para agrupar el conjunto de resultados utilizando una cláusula `GROUP BY` en la consulta SQL.

```ruby
class Author < ApplicationRecord
  has_many :chapters, -> { group 'books.id' },
                      through: :books
end
```

##### `includes`

Puedes utilizar el método `includes` para especificar asociaciones de segundo orden que deben cargarse de forma ansiosa cuando se utiliza esta asociación. Por ejemplo, considera estos modelos:

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

Si frecuentemente recuperas capítulos directamente de autores (`@author.books.chapters`), puedes hacer tu código un poco más eficiente incluyendo los capítulos en la asociación de autores a libros:

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

El método `limit` te permite restringir el número total de objetos que se obtendrán a través de una asociación.

```ruby
class Author < ApplicationRecord
  has_many :recent_books,
    -> { order('published_at desc').limit(100) },
    class_name: "Book"
end
```

##### `offset`

El método `offset` te permite especificar el desplazamiento inicial para obtener objetos a través de una asociación. Por ejemplo, `-> { offset(11) }` omitirá los primeros 11 registros.

##### `order`

El método `order` dicta el orden en el que se recibirán los objetos asociados (en la sintaxis utilizada por una cláusula `ORDER BY` en SQL).

```ruby
class Author < ApplicationRecord
  has_many :books, -> { order "date_confirmed DESC" }
end
```

##### `readonly`

Si utilizas el método `readonly`, los objetos asociados serán de solo lectura al ser recuperados a través de la asociación.

##### `select`

El método `select` te permite anular la cláusula SQL `SELECT` que se utiliza para recuperar datos sobre los objetos asociados. Por defecto, Rails recupera todas las columnas.

ADVERTENCIA: Si especificas tu propio `select`, asegúrate de incluir las columnas de clave primaria y clave externa del modelo asociado. Si no lo haces, Rails lanzará un error.

##### `distinct`

Utiliza el método `distinct` para mantener la colección libre de duplicados. Esto es especialmente útil junto con la opción `:through`.

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

En el caso anterior, hay dos lecturas y `person.articles` muestra ambas, aunque estos registros apuntan al mismo artículo.

Ahora vamos a establecer `distinct`:

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

En el caso anterior, todavía hay dos lecturas. Sin embargo, `person.articles` muestra solo un artículo porque la colección carga solo registros únicos.

Si quieres asegurarte de que, al insertar, todos los registros en la asociación persistente sean distintos (para que puedas estar seguro de que al inspeccionar la asociación nunca encontrarás registros duplicados), debes agregar un índice único en la tabla misma. Por ejemplo, si tienes una tabla llamada `readings` y quieres asegurarte de que los artículos solo se puedan agregar a una persona una vez, podrías agregar lo siguiente en una migración:

```ruby
add_index :readings, [:person_id, :article_id], unique: true
```
Una vez que tenga este índice único, intentar agregar el artículo a una persona dos veces generará un error `ActiveRecord::RecordNotUnique`:

```irb
irb> person = Person.create(name: 'Honda')
irb> article = Article.create(name: 'a1')
irb> person.articles << article
irb> person.articles << article
ActiveRecord::RecordNotUnique
```

Tenga en cuenta que verificar la unicidad utilizando algo como `include?` está sujeto a condiciones de carrera. No intente usar `include?` para garantizar la distinción en una asociación. Por ejemplo, utilizando el ejemplo del artículo anterior, el siguiente código sería propenso a condiciones de carrera porque varios usuarios podrían intentar esto al mismo tiempo:

```ruby
person.articles << article unless person.articles.include?(article)
```

#### ¿Cuándo se guardan los objetos?

Cuando asigna un objeto a una asociación `has_many`, ese objeto se guarda automáticamente (para actualizar su clave externa). Si asigna varios objetos en una sola declaración, todos se guardan.

Si alguno de estos guardados falla debido a errores de validación, la declaración de asignación devuelve `false` y la asignación en sí se cancela.

Si el objeto principal (el que declara la asociación `has_many`) no está guardado (es decir, `new_record?` devuelve `true`), entonces los objetos secundarios no se guardan cuando se agregan. Todos los miembros no guardados de la asociación se guardarán automáticamente cuando se guarde el padre.

Si desea asignar un objeto a una asociación `has_many` sin guardar el objeto, use el método `collection.build`.

### Referencia de la asociación `has_and_belongs_to_many`

La asociación `has_and_belongs_to_many` crea una relación de muchos a muchos con otro modelo. En términos de base de datos, esto asocia dos clases a través de una tabla de unión intermedia que incluye claves externas que se refieren a cada una de las clases.

#### Métodos agregados por `has_and_belongs_to_many`

Cuando declara una asociación `has_and_belongs_to_many`, la clase que la declara automáticamente obtiene varios métodos relacionados con la asociación:

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

En todos estos métodos, `collection` se reemplaza con el símbolo pasado como primer argumento a `has_and_belongs_to_many`, y `collection_singular` se reemplaza con la versión singularizada de ese símbolo. Por ejemplo, dada la declaración:

```ruby
class Part < ApplicationRecord
  has_and_belongs_to_many :assemblies
end
```

Cada instancia del modelo `Part` tendrá estos métodos:

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

##### Métodos adicionales de columna

Si la tabla de unión para una asociación `has_and_belongs_to_many` tiene columnas adicionales además de las dos claves externas, estas columnas se agregarán como atributos a los registros recuperados a través de esa asociación. Los registros devueltos con atributos adicionales siempre serán de solo lectura, porque Rails no puede guardar cambios en esos atributos.

ADVERTENCIA: El uso de atributos adicionales en la tabla de unión en una asociación `has_and_belongs_to_many` está en desuso. Si necesita este tipo de comportamiento complejo en la tabla que une dos modelos en una relación de muchos a muchos, debe usar una asociación `has_many :through` en lugar de `has_and_belongs_to_many`.

##### `collection`

El método `collection` devuelve una relación de todos los objetos asociados. Si no hay objetos asociados, devuelve una relación vacía.

```ruby
@assemblies = @part.assemblies
```

##### `collection<<(object, ...)`

El método [`collection<<`][] agrega uno o más objetos a la colección creando registros en la tabla de unión.

```ruby
@part.assemblies << @assembly1
```

NOTA: Este método también se conoce como `collection.concat` y `collection.push`.

##### `collection.delete(object, ...)`

El método [`collection.delete`][] elimina uno o más objetos de la colección eliminando registros en la tabla de unión. Esto no destruye los objetos.

```ruby
@part.assemblies.delete(@assembly1)
```

##### `collection.destroy(object, ...)`

El método [`collection.destroy`][] elimina uno o más objetos de la colección eliminando registros en la tabla de unión. Esto no destruye los objetos.

```ruby
@part.assemblies.destroy(@assembly1)
```

##### `collection=(objects)`

El método `collection=` hace que la colección contenga solo los objetos suministrados, agregando y eliminando según corresponda. Los cambios se persisten en la base de datos.

##### `collection_singular_ids`

El método `collection_singular_ids` devuelve una matriz de los ids de los objetos en la colección.

```ruby
@assembly_ids = @part.assembly_ids
```

##### `collection_singular_ids=(ids)`

El método `collection_singular_ids=` hace que la colección contenga solo los objetos identificados por los valores de clave primaria suministrados, agregando y eliminando según corresponda. Los cambios se persisten en la base de datos.
##### `collection.clear`

El método [`collection.clear`][] elimina todos los objetos de la colección al eliminar las filas de la tabla de unión. Esto no destruye los objetos asociados.

##### `collection.empty?`

El método [`collection.empty?`][] devuelve `true` si la colección no contiene ningún objeto asociado.

```html+erb
<% if @part.assemblies.empty? %>
  Esta parte no se utiliza en ningún ensamblaje
<% end %>
```

##### `collection.size`

El método [`collection.size`][] devuelve el número de objetos en la colección.

```ruby
@assembly_count = @part.assemblies.size
```

##### `collection.find(...)`

El método [`collection.find`][] encuentra objetos dentro de la tabla de la colección.

```ruby
@assembly = @part.assemblies.find(1)
```

##### `collection.where(...)`

El método [`collection.where`][] encuentra objetos dentro de la colección basados en las condiciones suministradas, pero los objetos se cargan de forma perezosa, lo que significa que la base de datos se consulta solo cuando se accede a los objetos.

```ruby
@new_assemblies = @part.assemblies.where("created_at > ?", 2.days.ago)
```

##### `collection.exists?(...)`

El método [`collection.exists?`][] verifica si existe un objeto que cumpla las condiciones suministradas en la tabla de la colección.

##### `collection.build(attributes = {})`

El método [`collection.build`][] devuelve un nuevo objeto del tipo asociado. Este objeto se instanciará a partir de los atributos pasados, y se creará el enlace a través de la tabla de unión, pero el objeto asociado aún no se guardará.

```ruby
@assembly = @part.assemblies.build({ assembly_name: "Caja de transmisión" })
```

##### `collection.create(attributes = {})`

El método [`collection.create`][] devuelve un nuevo objeto del tipo asociado. Este objeto se instanciará a partir de los atributos pasados, se creará el enlace a través de la tabla de unión y, una vez que pase todas las validaciones especificadas en el modelo asociado, se guardará el objeto asociado.

```ruby
@assembly = @part.assemblies.create({ assembly_name: "Caja de transmisión" })
```

##### `collection.create!(attributes = {})`

Hace lo mismo que `collection.create`, pero genera una excepción `ActiveRecord::RecordInvalid` si el registro no es válido.

##### `collection.reload`

El método [`collection.reload`][] devuelve una relación de todos los objetos asociados, forzando una lectura de la base de datos. Si no hay objetos asociados, devuelve una relación vacía.

```ruby
@assemblies = @part.assemblies.reload
```

#### Opciones para `has_and_belongs_to_many`

Si bien Rails utiliza valores predeterminados inteligentes que funcionarán bien en la mayoría de las situaciones, puede haber momentos en los que desee personalizar el comportamiento de la referencia de la asociación `has_and_belongs_to_many`. Estas personalizaciones se pueden realizar fácilmente pasando opciones al crear la asociación. Por ejemplo, esta asociación utiliza dos opciones:

```ruby
class Parts < ApplicationRecord
  has_and_belongs_to_many :assemblies, -> { readonly },
                                       autosave: true
end
```

La asociación [`has_and_belongs_to_many`][] admite estas opciones:

* `:association_foreign_key`
* `:autosave`
* `:class_name`
* `:foreign_key`
* `:join_table`
* `:validate`

##### `:association_foreign_key`

Por convención, Rails asume que la columna en la tabla de unión utilizada para almacenar la clave externa que apunta al otro modelo es el nombre de ese modelo con el sufijo `_id` agregado. La opción `:association_foreign_key` le permite establecer directamente el nombre de la clave externa:

CONSEJO: Las opciones `:foreign_key` y `:association_foreign_key` son útiles al configurar una autoasociación de muchos a muchos. Por ejemplo:

```ruby
class User < ApplicationRecord
  has_and_belongs_to_many :friends,
      class_name: "User",
      foreign_key: "this_user_id",
      association_foreign_key: "other_user_id"
end
```

##### `:autosave`

Si establece la opción `:autosave` en `true`, Rails guardará los miembros de la asociación cargados y destruirá los miembros que estén marcados para su eliminación cada vez que guarde el objeto principal. Establecer `:autosave` en `false` no es lo mismo que no establecer la opción `:autosave`. Si la opción `:autosave` no está presente, los nuevos objetos asociados se guardarán, pero los objetos asociados actualizados no se guardarán.

##### `:class_name`

Si el nombre del otro modelo no se puede derivar del nombre de la asociación, puede utilizar la opción `:class_name` para proporcionar el nombre del modelo. Por ejemplo, si una parte tiene muchos ensamblajes, pero el nombre real del modelo que contiene los ensamblajes es `Gadget`, configuraría las cosas de esta manera:

```ruby
class Parts < ApplicationRecord
  has_and_belongs_to_many :assemblies, class_name: "Gadget"
end
```

##### `:foreign_key`

Por convención, Rails asume que la columna en la tabla de unión utilizada para almacenar la clave externa que apunta a este modelo es el nombre de este modelo con el sufijo `_id` agregado. La opción `:foreign_key` le permite establecer directamente el nombre de la clave externa:

```ruby
class User < ApplicationRecord
  has_and_belongs_to_many :friends,
      class_name: "User",
      foreign_key: "this_user_id",
      association_foreign_key: "other_user_id"
end
```

##### `:join_table`

Si el nombre predeterminado de la tabla de unión, basado en el orden alfabético, no es el que desea, puede utilizar la opción `:join_table` para anular el valor predeterminado.
##### `:validate`

Si estableces la opción `:validate` en `false`, entonces los nuevos objetos asociados no serán validados cada vez que guardes este objeto. Por defecto, esto es `true`: los nuevos objetos asociados serán validados cuando se guarde este objeto.

#### Alcances para `has_and_belongs_to_many`

Puede haber momentos en los que desees personalizar la consulta utilizada por `has_and_belongs_to_many`. Estas personalizaciones se pueden lograr mediante un bloque de alcance. Por ejemplo:

```ruby
class Parts < ApplicationRecord
  has_and_belongs_to_many :assemblies, -> { where active: true }
end
```

Puedes utilizar cualquiera de los métodos de consulta estándar [métodos de consulta de Active Record](active_record_querying.html) dentro del bloque de alcance. Los siguientes se discuten a continuación:

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

El método `where` te permite especificar las condiciones que el objeto asociado debe cumplir.

```ruby
class Parts < ApplicationRecord
  has_and_belongs_to_many :assemblies,
    -> { where "factory = 'Seattle'" }
end
```

También puedes establecer condiciones a través de un hash:

```ruby
class Parts < ApplicationRecord
  has_and_belongs_to_many :assemblies,
    -> { where factory: 'Seattle' }
end
```

Si utilizas un `where` estilo hash, entonces la creación de registros a través de esta asociación se limitará automáticamente utilizando el hash. En este caso, al utilizar `@parts.assemblies.create` o `@parts.assemblies.build` se crearán ensamblajes donde la columna `factory` tenga el valor "Seattle".

##### `extending`

El método `extending` especifica un módulo con nombre para extender el proxy de asociación. Las extensiones de asociación se discuten en detalle [más adelante en esta guía](#extensiones-de-asociación).

##### `group`

El método `group` proporciona un nombre de atributo para agrupar el conjunto de resultados, utilizando una cláusula `GROUP BY` en el SQL del buscador.

```ruby
class Parts < ApplicationRecord
  has_and_belongs_to_many :assemblies, -> { group "factory" }
end
```

##### `includes`

Puedes utilizar el método `includes` para especificar asociaciones de segundo orden que se deben cargar de forma ansiosa cuando se utiliza esta asociación.

##### `limit`

El método `limit` te permite restringir el número total de objetos que se obtendrán a través de una asociación.

```ruby
class Parts < ApplicationRecord
  has_and_belongs_to_many :assemblies,
    -> { order("created_at DESC").limit(50) }
end
```

##### `offset`

El método `offset` te permite especificar el desplazamiento inicial para obtener objetos a través de una asociación. Por ejemplo, si estableces `offset(11)`, se omitirán los primeros 11 registros.

##### `order`

El método `order` dicta el orden en el que se recibirán los objetos asociados (en la sintaxis utilizada por una cláusula `ORDER BY` de SQL).

```ruby
class Parts < ApplicationRecord
  has_and_belongs_to_many :assemblies,
    -> { order "assembly_name ASC" }
end
```

##### `readonly`

Si utilizas el método `readonly`, entonces los objetos asociados serán de solo lectura cuando se recuperen a través de la asociación.

##### `select`

El método `select` te permite anular la cláusula SQL `SELECT` que se utiliza para recuperar datos sobre los objetos asociados. Por defecto, Rails recupera todas las columnas.

##### `distinct`

Utiliza el método `distinct` para eliminar duplicados de la colección.

#### ¿Cuándo se Guardan los Objetos?

Cuando asignas un objeto a una asociación `has_and_belongs_to_many`, ese objeto se guarda automáticamente (para actualizar la tabla de unión). Si asignas varios objetos en una sola declaración, todos se guardan.

Si alguna de estas guardas falla debido a errores de validación, entonces la declaración de asignación devuelve `false` y la asignación en sí se cancela.

Si el objeto padre (el que declara la asociación `has_and_belongs_to_many`) no está guardado (es decir, `new_record?` devuelve `true`), entonces los objetos hijos no se guardan cuando se agregan. Todos los miembros no guardados de la asociación se guardarán automáticamente cuando se guarde el padre.

Si quieres asignar un objeto a una asociación `has_and_belongs_to_many` sin guardar el objeto, utiliza el método `collection.build`.

### Callbacks de Asociación

Los callbacks normales se conectan al ciclo de vida de los objetos de Active Record, lo que te permite trabajar con esos objetos en varios puntos. Por ejemplo, puedes utilizar un callback `:before_save` para hacer que algo suceda justo antes de que se guarde un objeto.

Los callbacks de asociación son similares a los callbacks normales, pero se activan por eventos en el ciclo de vida de una colección. Hay cuatro callbacks de asociación disponibles:

* `before_add`
* `after_add`
* `before_remove`
* `after_remove`

Defines los callbacks de asociación agregando opciones a la declaración de la asociación. Por ejemplo:

```ruby
class Author < ApplicationRecord
  has_many :books, before_add: :check_credit_limit

  def check_credit_limit(book)
    # ...
  end
end
```

Rails pasa el objeto que se está agregando o eliminando al callback.
Puede apilar devoluciones de llamada en un solo evento pasándolas como una matriz:

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

Si una devolución de llamada `before_add` lanza `:abort`, el objeto no se agrega a la colección. De manera similar, si una devolución de llamada `before_remove` lanza `:abort`, el objeto no se elimina de la colección:

```ruby
# el libro no se agregará si se alcanza el límite
def check_credit_limit(book)
  throw(:abort) if limit_reached?
end
```

NOTA: Estas devoluciones de llamada solo se llaman cuando los objetos asociados se agregan o eliminan a través de la colección de asociación:

```ruby
# Desencadena la devolución de llamada `before_add`
author.books << book
author.books = [book, book2]

# No desencadena la devolución de llamada `before_add`
book.update(author_id: 1)
```

### Extensiones de asociación

No estás limitado a la funcionalidad que Rails construye automáticamente en los objetos proxy de asociación. También puedes extender estos objetos a través de módulos anónimos, agregando nuevos buscadores, creadores u otros métodos. Por ejemplo:

```ruby
class Author < ApplicationRecord
  has_many :books do
    def find_by_book_prefix(book_number)
      find_by(category_id: book_number[0..2])
    end
  end
end
```

Si tienes una extensión que debe ser compartida por muchas asociaciones, puedes usar un módulo de extensión con nombre. Por ejemplo:

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

Las extensiones pueden hacer referencia a los internos del proxy de asociación utilizando estos tres atributos del accesor `proxy_association`:

* `proxy_association.owner` devuelve el objeto del que forma parte la asociación.
* `proxy_association.reflection` devuelve el objeto de reflexión que describe la asociación.
* `proxy_association.target` devuelve el objeto asociado para `belongs_to` o `has_one`, o la colección de objetos asociados para `has_many` o `has_and_belongs_to_many`.

### Asociación de ámbito utilizando el propietario de la asociación

El propietario de la asociación se puede pasar como un solo argumento al bloque de ámbito en situaciones en las que se necesita un control aún mayor sobre el ámbito de la asociación. Sin embargo, como advertencia, ya no será posible precargar la asociación.

```ruby
class Supplier < ApplicationRecord
  has_one :account, ->(supplier) { where active: supplier.active? }
end
```

Herencia de tabla única (STI)
------------------------------

A veces, es posible que desees compartir campos y comportamiento entre diferentes modelos. Digamos que tenemos los modelos Car, Motorcycle y Bicycle. Queremos compartir los campos `color` y `price` y algunos métodos para todos ellos, pero tener un comportamiento específico para cada uno y controladores separados también.

Primero, generemos el modelo base Vehicle:

```bash
$ bin/rails generate model vehicle type:string color:string price:decimal{10.2}
```

¿Notaste que estamos agregando un campo "type"? Dado que todos los modelos se guardarán en una sola tabla de base de datos, Rails guardará en esta columna el nombre del modelo que se está guardando. En nuestro ejemplo, esto puede ser "Car", "Motorcycle" o "Bicycle". STI no funcionará sin un campo "type" en la tabla.

A continuación, generaremos el modelo Car que hereda de Vehicle. Para esto, podemos usar la opción `--parent=PARENT`, que generará un modelo que hereda del padre especificado y sin migración equivalente (ya que la tabla ya existe).

Por ejemplo, para generar el modelo Car:

```bash
$ bin/rails generate model car --parent=Vehicle
```

El modelo generado se verá así:

```ruby
class Car < Vehicle
end
```

Esto significa que todo el comportamiento agregado a Vehicle también está disponible para Car, como asociaciones, métodos públicos, etc.

Crear un coche lo guardará en la tabla `vehicles` con "Car" como campo `type`:

```ruby
Car.create(color: 'Red', price: 10000)
```

generará el siguiente SQL:

```sql
INSERT INTO "vehicles" ("type", "color", "price") VALUES ('Car', 'Red', 10000)
```

Consultar registros de coches buscará solo vehículos que sean coches:

```ruby
Car.all
```

ejecutará una consulta como esta:

```sql
SELECT "vehicles".* FROM "vehicles" WHERE "vehicles"."type" IN ('Car')
```

Tipos delegados
----------------

[`Herencia de tabla única (STI)`](#herencia-de-tabla-única-sti) funciona mejor cuando hay poca diferencia entre las subclases y sus atributos, pero incluye todos los atributos de todas las subclases que necesitas crear en una sola tabla.

La desventaja de este enfoque es que resulta en un aumento de tamaño de esa tabla. Ya que incluso incluirá atributos específicos de una subclase que no son utilizados por nada más.

En el siguiente ejemplo, hay dos modelos de Active Record que heredan de la misma clase "Entry" que incluye el atributo `subject`.
```ruby
# Esquema: entradas[ id, tipo, asunto, creado_en, actualizado_en]
class Entry < ApplicationRecord
end

class Comment < Entry
end

class Message < Entry
end
```

Los tipos delegados resuelven este problema, a través de `delegated_type`.

Para utilizar los tipos delegados, debemos modelar nuestros datos de una manera particular. Los requisitos son los siguientes:

* Hay una superclase que almacena los atributos compartidos entre todas las subclases en su tabla.
* Cada subclase debe heredar de la superclase y tendrá una tabla separada para cualquier atributo adicional específico de ella.

Esto elimina la necesidad de definir atributos en una sola tabla que se comparten involuntariamente entre todas las subclases.

Para aplicar esto a nuestro ejemplo anterior, necesitamos regenerar nuestros modelos.
Primero, generemos el modelo base `Entry` que actuará como nuestra superclase:

```bash
$ bin/rails generate model entry entryable_type:string entryable_id:integer
```

Luego, generaremos los nuevos modelos `Message` y `Comment` para la delegación:

```bash
$ bin/rails generate model message subject:string body:string
$ bin/rails generate model comment content:string
```

Después de ejecutar los generadores, deberíamos obtener modelos que se vean así:

```ruby
# Esquema: entradas[ id, entryable_type, entryable_id, creado_en, actualizado_en ]
class Entry < ApplicationRecord
end

# Esquema: mensajes[ id, asunto, cuerpo, creado_en, actualizado_en ]
class Message < ApplicationRecord
end

# Esquema: comentarios[ id, contenido, creado_en, actualizado_en ]
class Comment < ApplicationRecord
end
```

### Declarar `delegated_type`

Primero, declaremos un `delegated_type` en la superclase `Entry`.

```ruby
class Entry < ApplicationRecord
  delegated_type :entryable, types: %w[ Message Comment ], dependent: :destroy
end
```

El parámetro `entryable` especifica el campo a utilizar para la delegación e incluye los tipos `Message` y `Comment` como las clases delegadas.

La clase `Entry` tiene los campos `entryable_type` y `entryable_id`. Este es el campo con los sufijos `_type` y `_id` agregados al nombre `entryable` en la definición de `delegated_type`.
`entryable_type` almacena el nombre de la subclase del delegado y `entryable_id` almacena el id del registro de la subclase del delegado.

A continuación, debemos definir un módulo para implementar esos tipos delegados, declarando el parámetro `as: :entryable` en la asociación `has_one`.

```ruby
module Entryable
  extend ActiveSupport::Concern

  included do
    has_one :entry, as: :entryable, touch: true
  end
end
```

Y luego incluir el módulo creado en su subclase.

```ruby
class Message < ApplicationRecord
  include Entryable
end

class Comment < ApplicationRecord
  include Entryable
end
```

Con esta definición completa, nuestro delegador `Entry` ahora proporciona los siguientes métodos:

| Método | Retorno |
|---|---|
| `Entry#entryable_class` | Message o Comment |
| `Entry#entryable_name` | "message" o "comment" |
| `Entry.messages` | `Entry.where(entryable_type: "Message")` |
| `Entry#message?` | Devuelve true cuando `entryable_type == "Message"` |
| `Entry#message` | Devuelve el registro de mensaje cuando `entryable_type == "Message"`, de lo contrario `nil` |
| `Entry#message_id` | Devuelve `entryable_id` cuando `entryable_type == "Message"`, de lo contrario `nil` |
| `Entry.comments` | `Entry.where(entryable_type: "Comment")` |
| `Entry#comment?` | Devuelve true cuando `entryable_type == "Comment"` |
| `Entry#comment` | Devuelve el registro de comentario cuando `entryable_type == "Comment"`, de lo contrario `nil` |
| `Entry#comment_id` | Devuelve `entryable_id` cuando `entryable_type == "Comment"`, de lo contrario `nil` |

### Creación de objetos

Al crear un nuevo objeto `Entry`, podemos especificar la subclase `entryable` al mismo tiempo.

```ruby
Entry.create! entryable: Message.new(subject: "¡Hola!")
```

### Agregar más delegación

Podemos expandir nuestro delegador `Entry` y mejorar aún más definiendo `delegates` y utilizando polimorfismo en las subclases.
Por ejemplo, para delegar el método `title` de `Entry` a sus subclases:

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
