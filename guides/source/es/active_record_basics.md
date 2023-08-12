**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: b2cb0ab668ead9e8bd48cbd1bcac9b59
Conceptos básicos de Active Record
====================

Esta guía es una introducción a Active Record.

Después de leer esta guía, sabrás:

* Qué es el mapeo objeto-relacional y Active Record y cómo se utilizan en Rails.
* Cómo encaja Active Record en el paradigma Modelo-Vista-Controlador.
* Cómo utilizar los modelos de Active Record para manipular datos almacenados en una base de datos relacional.
* Convenciones de nomenclatura de esquema de Active Record.
* Los conceptos de migraciones de base de datos, validaciones, callbacks y asociaciones.

--------------------------------------------------------------------------------

¿Qué es Active Record?
----------------------

Active Record es la M en [MVC][] - el modelo - que es la capa del sistema
responsable de representar los datos y la lógica del negocio. Active Record facilita
la creación y el uso de objetos de negocio cuyos datos requieren almacenamiento persistente
en una base de datos. Es una implementación del patrón Active Record que en sí mismo
es una descripción de un sistema de mapeo objeto-relacional.

### El patrón Active Record

[Active Record fue descrito por Martin Fowler][MFAR] en su libro _Patterns of
Enterprise Application Architecture_. En Active Record, los objetos llevan tanto
datos persistentes como comportamiento que opera en esos datos. Active Record toma
la opinión de que asegurar la lógica de acceso a datos como parte del objeto educará
a los usuarios de ese objeto sobre cómo escribir y leer desde la base de datos.

### Mapeo objeto-relacional

[El mapeo objeto-relacional][ORM], comúnmente referido por su abreviatura ORM,
es una técnica que conecta los objetos ricos de una aplicación con las tablas en un
sistema de gestión de bases de datos relacionales. Utilizando ORM, las propiedades y
relaciones de los objetos en una aplicación pueden ser fácilmente almacenadas y
recuperadas de una base de datos sin escribir declaraciones SQL directamente y con menos
código de acceso a la base de datos en general.

NOTA: Tener conocimientos básicos de sistemas de gestión de bases de datos relacionales (RDBMS) y
lenguaje de consulta estructurado (SQL) es útil para comprender completamente Active
Record. Por favor, consulte [este tutorial][sqlcourse] (o [este otro][rdbmsinfo]) o
estúdielos de otras formas si desea aprender más.

### Active Record como un marco ORM

Active Record nos proporciona varios mecanismos, siendo el más importante la capacidad de:

* Representar modelos y sus datos.
* Representar asociaciones entre estos modelos.
* Representar jerarquías de herencia a través de modelos relacionados.
* Validar modelos antes de que se persistan en la base de datos.
* Realizar operaciones de base de datos de manera orientada a objetos.


Convención sobre configuración en Active Record
----------------------------------------------

Cuando se escriben aplicaciones utilizando otros lenguajes de programación o marcos, puede ser necesario escribir mucho código de configuración. Esto es particularmente cierto
para los marcos ORM en general. Sin embargo, si sigues las convenciones adoptadas por
Rails, necesitarás escribir muy poca configuración (en algunos casos ninguna
configuración en absoluto) al crear modelos de Active Record. La idea es que si
configuras tus aplicaciones de la misma manera la mayor parte del tiempo, entonces esta
debería ser la forma predeterminada. Por lo tanto, solo se necesitaría configuración explícita
en aquellos casos en los que no se pueda seguir la convención estándar.

### Convenciones de nomenclatura

Por defecto, Active Record utiliza algunas convenciones de nomenclatura para determinar cómo
se debe crear el mapeo entre modelos y tablas de la base de datos. Rails
pluralizará los nombres de tus clases para encontrar la tabla de base de datos correspondiente. Así que,
para una clase `Book`, deberías tener una tabla de base de datos llamada **books**. Los
mecanismos de pluralización de Rails son muy potentes, siendo capaces de pluralizar (y
singularizar) tanto palabras regulares como irregulares. Al utilizar nombres de clases compuestos
por dos o más palabras, el nombre de la clase del modelo debe seguir las convenciones de Ruby,
utilizando la forma CamelCase, mientras que el nombre de la tabla debe utilizar la forma snake_case. Ejemplos:

* Clase del modelo - Singular con la primera letra de cada palabra en mayúscula (por ejemplo, `BookClub`).
* Tabla de la base de datos - Plural con guiones bajos separando las palabras (por ejemplo, `book_clubs`).

| Modelo / Clase    | Tabla / Esquema |
| ---------------- | -------------- |
| `Article`        | `articles`     |
| `LineItem`       | `line_items`   |
| `Deer`           | `deers`        |
| `Mouse`          | `mice`         |
| `Person`         | `people`       |

### Convenciones de esquema

Active Record utiliza convenciones de nomenclatura para las columnas en las tablas de la base de datos,
dependiendo del propósito de estas columnas.

* **Claves foráneas** - Estos campos deben tener nombres que sigan el patrón
  `nombre_singular_de_la_tabla_id` (por ejemplo, `item_id`, `order_id`). Estos son los
  campos que Active Record buscará cuando crees asociaciones entre
  tus modelos.
* **Claves primarias** - Por defecto, Active Record utilizará una columna entera llamada
  `id` como clave primaria de la tabla (`bigint` para PostgreSQL y MySQL, `integer`
  para SQLite). Cuando utilices [Migraciones de Active Record](active_record_migrations.html)
  para crear tus tablas, esta columna se creará automáticamente.
También hay algunos nombres de columnas opcionales que agregarán características adicionales a las instancias de Active Record:

* `created_at` - Se establece automáticamente en la fecha y hora actual cuando se crea el registro por primera vez.
* `updated_at` - Se establece automáticamente en la fecha y hora actual cuando se crea o actualiza el registro.
* `lock_version` - Agrega [bloqueo optimista](https://api.rubyonrails.org/classes/ActiveRecord/Locking.html) a un modelo.
* `type` - Especifica que el modelo utiliza [Herencia de tabla única](https://api.rubyonrails.org/classes/ActiveRecord/Base.html#class-ActiveRecord::Base-label-Single+table+inheritance).
* `(nombre_de_asociación)_type` - Almacena el tipo para [asociaciones polimórficas](association_basics.html#polymorphic-associations).
* `(nombre_de_tabla)_count` - Se utiliza para almacenar en caché el número de objetos relacionados en las asociaciones. Por ejemplo, una columna `comments_count` en una clase `Article` que tiene muchas instancias de `Comment` almacenará en caché el número de comentarios existentes para cada artículo.

NOTA: Si bien estos nombres de columna son opcionales, de hecho están reservados por Active Record. Evite las palabras clave reservadas a menos que desee la funcionalidad adicional. Por ejemplo, `type` es una palabra clave reservada que se utiliza para designar una tabla que utiliza la herencia de tabla única (STI). Si no está utilizando STI, intente con una palabra clave análoga como "contexto", que aún puede describir con precisión los datos que está modelando.

Creación de modelos de Active Record
------------------------------------

Cuando se genera una aplicación, se creará una clase abstracta `ApplicationRecord` en `app/models/application_record.rb`. Esta es la clase base para todos los modelos en una aplicación y es lo que convierte una clase Ruby regular en un modelo de Active Record.

Para crear modelos de Active Record, hereda la clase `ApplicationRecord` y listo:

```ruby
class Product < ApplicationRecord
end
```

Esto creará un modelo `Product`, mapeado a una tabla `products` en la base de datos. Al hacer esto, también tendrás la capacidad de mapear las columnas de cada fila en esa tabla con los atributos de las instancias de tu modelo. Supongamos que la tabla `products` se creó utilizando una declaración SQL (o una de sus extensiones) como esta:

```sql
CREATE TABLE products (
  id int(11) NOT NULL auto_increment,
  name varchar(255),
  PRIMARY KEY  (id)
);
```

El esquema anterior declara una tabla con dos columnas: `id` y `name`. Cada fila de esta tabla representa un cierto producto con estos dos parámetros. Por lo tanto, podrías escribir código como el siguiente:

```ruby
p = Product.new
p.name = "Some Book"
puts p.name # "Some Book"
```

Anulando las convenciones de nomenclatura
-----------------------------------------

¿Qué sucede si necesitas seguir una convención de nomenclatura diferente o necesitas utilizar tu aplicación Rails con una base de datos heredada? No hay problema, puedes anular fácilmente las convenciones predeterminadas.

Dado que `ApplicationRecord` hereda de `ActiveRecord::Base`, los modelos de tu aplicación tendrán a su disposición una serie de métodos útiles. Por ejemplo, puedes usar el método `ActiveRecord::Base.table_name=` para personalizar el nombre de la tabla que se debe utilizar:

```ruby
class Product < ApplicationRecord
  self.table_name = "mis_productos"
end
```

Si haces esto, tendrás que definir manualmente el nombre de la clase que aloja los fixtures (`mis_productos.yml`) utilizando el método `set_fixture_class` en la definición de tus pruebas:

```ruby
# test/models/product_test.rb
class ProductTest < ActiveSupport::TestCase
  set_fixture_class mis_productos: Product
  fixtures :mis_productos
  # ...
end
```

También es posible anular la columna que se debe utilizar como clave primaria de la tabla utilizando el método `ActiveRecord::Base.primary_key=`:

```ruby
class Product < ApplicationRecord
  self.primary_key = "product_id"
end
```

NOTA: **Active Record no admite el uso de columnas que no sean clave primaria con el nombre `id`.**

NOTA: Si intentas crear una columna llamada `id` que no sea la clave primaria, Rails lanzará un error durante las migraciones, como por ejemplo: `no puedes redefinir la columna de clave primaria 'id' en 'mis_productos'.` `Para definir una clave primaria personalizada, pasa { id: false } a create_table.`

CRUD: Lectura y escritura de datos
----------------------------------

CRUD es un acrónimo de los cuatro verbos que utilizamos para operar en los datos: **C**rear, **R**ecuperar, **A**ctualizar y **E**liminar. Active Record crea automáticamente métodos para permitir que una aplicación lea y manipule los datos almacenados en sus tablas.

### Crear

Los objetos de Active Record se pueden crear a partir de un hash, un bloque o se pueden establecer manualmente sus atributos después de la creación. El método `new` devolverá un nuevo objeto mientras que `create` devolverá el objeto y lo guardará en la base de datos.

Por ejemplo, dado un modelo `User` con atributos `name` y `occupation`, la llamada al método `create` creará y guardará un nuevo registro en la base de datos:

```ruby
user = User.create(name: "David", occupation: "Code Artist")
```
Usando el método `new`, se puede instanciar un objeto sin guardarlo:

```ruby
user = User.new
user.name = "David"
user.occupation = "Code Artist"
```

Una llamada a `user.save` guardará el registro en la base de datos.

Finalmente, si se proporciona un bloque, tanto `create` como `new` pasarán el nuevo
objeto a ese bloque para su inicialización, mientras que solo `create` persistirá
el objeto resultante en la base de datos:

```ruby
user = User.new do |u|
  u.name = "David"
  u.occupation = "Code Artist"
end
```

### Leer

Active Record proporciona una API completa para acceder a los datos dentro de una base de datos. A continuación
se muestran algunos ejemplos de diferentes métodos de acceso a datos proporcionados por Active Record.

```ruby
# devuelve una colección con todos los usuarios
users = User.all
```

```ruby
# devuelve el primer usuario
user = User.first
```

```ruby
# devuelve el primer usuario llamado David
david = User.find_by(name: 'David')
```

```ruby
# encuentra todos los usuarios llamados David que sean Code Artists y ordena por created_at en orden cronológico inverso
users = User.where(name: 'David', occupation: 'Code Artist').order(created_at: :desc)
```

Puede obtener más información sobre cómo consultar un modelo de Active Record en la guía [Interfaz de consulta de Active Record](active_record_querying.html).

### Actualizar

Una vez que se ha recuperado un objeto de Active Record, se pueden modificar sus atributos
y se puede guardar en la base de datos.

```ruby
user = User.find_by(name: 'David')
user.name = 'Dave'
user.save
```

Una forma abreviada de hacer esto es usar un hash que mapee los nombres de los atributos al valor deseado, de la siguiente manera:

```ruby
user = User.find_by(name: 'David')
user.update(name: 'Dave')
```

Esto es especialmente útil cuando se actualizan varios atributos a la vez.

Si desea actualizar varios registros a granel **sin callbacks o validaciones**, puede actualizar la base de datos directamente usando `update_all`:

```ruby
User.update_all max_login_attempts: 3, must_change_password: true
```

### Eliminar

Del mismo modo, una vez recuperado, un objeto de Active Record se puede destruir, lo que lo elimina
de la base de datos.

```ruby
user = User.find_by(name: 'David')
user.destroy
```

Si desea eliminar varios registros a granel, puede usar el método `destroy_by`
o `destroy_all`:

```ruby
# encuentra y elimina todos los usuarios llamados David
User.destroy_by(name: 'David')

# eliminar todos los usuarios
User.destroy_all
```

Validaciones
-----------

Active Record le permite validar el estado de un modelo antes de guardarlo
en la base de datos. Hay varios métodos que puede utilizar para verificar sus
modelos y validar que un valor de atributo no esté vacío, sea único y no esté
ya en la base de datos, siga un formato específico y muchos más.

Métodos como `save`, `create` y `update` validan un modelo antes de guardarlo
en la base de datos. Cuando un modelo no es válido, estos métodos devuelven `false` y no
se realizan operaciones en la base de datos. Todos estos métodos tienen una contraparte "bang"
(es decir, `save!`, `create!` y `update!`), que son más estrictos en el sentido de que
lanzan una excepción `ActiveRecord::RecordInvalid` cuando falla la validación.
Un ejemplo rápido para ilustrar:

```ruby
class User < ApplicationRecord
  validates :name, presence: true
end
```

```irb
irb> user = User.new
irb> user.save
=> false
irb> user.save!
ActiveRecord::RecordInvalid: Validation failed: Name can’t be blank
```

Puede obtener más información sobre las validaciones en la guía [Validaciones de Active Record](active_record_validations.html).

Callbacks
---------

Los callbacks de Active Record le permiten adjuntar código a ciertos eventos en el
ciclo de vida de sus modelos. Esto le permite agregar comportamiento a sus modelos al
ejecutar código de manera transparente cuando ocurren esos eventos, como cuando crea un nuevo
registro, lo actualiza, lo elimina, y así sucesivamente.

```ruby
class User < ApplicationRecord
  after_create :log_new_user

  private
    def log_new_user
      puts "Se registró un nuevo usuario"
    end
end
```

```irb
irb> @user = User.create
Se registró un nuevo usuario
```

Puede obtener más información sobre los callbacks en la guía [Callbacks de Active Record](active_record_callbacks.html).

Migraciones
----------

Rails proporciona una forma conveniente de administrar cambios en el esquema de una base de datos a través de
migraciones. Las migraciones se escriben en un lenguaje específico del dominio y se almacenan
en archivos que se ejecutan en cualquier base de datos que admita Active Record.

Aquí hay una migración que crea una nueva tabla llamada `publications`:

```ruby
class CreatePublications < ActiveRecord::Migration[7.1]
  def change
    create_table :publications do |t|
      t.string :title
      t.text :description
      t.references :publication_type
      t.references :publisher, polymorphic: true
      t.boolean :single_issue

      t.timestamps
    end
  end
end
```

Tenga en cuenta que el código anterior es independiente de la base de datos: se ejecutará en MySQL,
PostgreSQL, SQLite y otros.

Rails realiza un seguimiento de las migraciones que se han guardado en la base de datos y las almacena
en una tabla adyacente en esa misma base de datos llamada `schema_migrations`.
Para ejecutar la migración y crear la tabla, debes ejecutar `bin/rails db:migrate`,
y para revertir y eliminar la tabla, `bin/rails db:rollback`.

Puedes obtener más información sobre las migraciones en la [guía de Migraciones de Active Record](active_record_migrations.html).

Asociaciones
------------

Las asociaciones de Active Record te permiten definir relaciones entre modelos.
Las asociaciones se pueden utilizar para describir relaciones uno a uno, uno a muchos y muchos a muchos. Por ejemplo, una relación como "Autor tiene muchos Libros" se puede definir de la siguiente manera:

```ruby
class Author < ApplicationRecord
  has_many :books
end
```

La clase Author ahora tiene métodos para agregar y eliminar libros de un autor, y mucho más.

Puedes obtener más información sobre las asociaciones en la [guía de Asociaciones de Active Record](association_basics.html).
[MVC]: https://en.wikipedia.org/wiki/Model%E2%80%93view%E2%80%93controller
[MFAR]: https://www.martinfowler.com/eaaCatalog/activeRecord.html
[ORM]: https://en.wikipedia.org/wiki/Object-relational_mapping
[sqlcourse]: https://www.khanacademy.org/computing/computer-programming/sql
[rdbmsinfo]: https://www.devart.com/what-is-rdbms/
