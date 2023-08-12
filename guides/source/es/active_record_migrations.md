**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 311d5225fa32d069369256501f31c507
Migraciones de Active Record
============================

Las migraciones son una característica de Active Record que te permite evolucionar tu esquema de base de datos con el tiempo. En lugar de escribir modificaciones de esquema en SQL puro, las migraciones te permiten usar un DSL de Ruby para describir los cambios en tus tablas.

Después de leer esta guía, sabrás:

* Los generadores que puedes usar para crearlas.
* Los métodos que Active Record proporciona para manipular tu base de datos.
* Los comandos de Rails que manipulan las migraciones y tu esquema.
* Cómo se relacionan las migraciones con `schema.rb`.

Resumen de las migraciones
--------------------------

Las migraciones son una forma conveniente de alterar el esquema de tu base de datos con el tiempo de manera consistente. Utilizan un DSL de Ruby para que no tengas que escribir SQL manualmente, lo que permite que tu esquema y los cambios sean independientes de la base de datos.

Puedes pensar en cada migración como una nueva 'versión' de la base de datos. Un esquema comienza sin nada y cada migración lo modifica para agregar o eliminar tablas, columnas o entradas. Active Record sabe cómo actualizar tu esquema a lo largo de esta línea de tiempo, llevándolo desde cualquier punto en la historia hasta la última versión. Active Record también actualizará tu archivo `db/schema.rb` para que coincida con la estructura actualizada de tu base de datos.

Aquí tienes un ejemplo de una migración:

```ruby
class CreateProducts < ActiveRecord::Migration[7.1]
  def change
    create_table :products do |t|
      t.string :name
      t.text :description

      t.timestamps
    end
  end
end
```

Esta migración agrega una tabla llamada `products` con una columna de tipo string llamada `name` y una columna de tipo texto llamada `description`. También se agregará implícitamente una columna de clave primaria llamada `id`, ya que es la clave primaria predeterminada para todos los modelos de Active Record. La macro `timestamps` agrega dos columnas, `created_at` y `updated_at`. Estas columnas especiales son administradas automáticamente por Active Record si existen.

Ten en cuenta que definimos el cambio que queremos que ocurra en el futuro. Antes de que se ejecute esta migración, no habrá tabla. Después, la tabla existirá. Active Record también sabe cómo revertir esta migración: si revertimos esta migración, se eliminará la tabla.

En las bases de datos que admiten transacciones con declaraciones que cambian el esquema, cada migración se envuelve en una transacción. Si la base de datos no admite esto, cuando una migración falla, las partes que tuvieron éxito no se revertirán. Tendrás que deshacer los cambios realizados manualmente.

NOTA: Hay ciertas consultas que no se pueden ejecutar dentro de una transacción. Si tu adaptador admite transacciones DDL, puedes usar `disable_ddl_transaction!` para desactivarlas para una sola migración.

### Haciendo lo irreversible posible

Si deseas que una migración haga algo que Active Record no sepa cómo revertir, puedes usar `reversible`:

```ruby
class ChangeProductsPrice < ActiveRecord::Migration[7.1]
  def change
    reversible do |direction|
      change_table :products do |t|
        direction.up   { t.change :price, :string }
        direction.down { t.change :price, :integer }
      end
    end
  end
end
```

Esta migración cambiará el tipo de la columna `price` a string, o de vuelta a integer cuando se revierta la migración. Observa el bloque que se pasa a `direction.up` y `direction.down`, respectivamente.

Alternativamente, puedes usar `up` y `down` en lugar de `change`:

```ruby
class ChangeProductsPrice < ActiveRecord::Migration[7.1]
  def up
    change_table :products do |t|
      t.change :price, :string
    end
  end

  def down
    change_table :products do |t|
      t.change :price, :integer
    end
  end
end
```

INFO: Más sobre [`reversible`](#using-reversible) más adelante.

Generando migraciones
---------------------

### Creando una migración independiente

Las migraciones se almacenan como archivos en el directorio `db/migrate`, uno para cada clase de migración. El nombre del archivo tiene el formato `YYYYMMDDHHMMSS_create_products.rb`, es decir, una marca de tiempo UTC que identifica la migración seguida de un guión bajo y el nombre de la migración. El nombre de la clase de migración (versión en CamelCase) debe coincidir con la última parte del nombre del archivo. Por ejemplo, `20080906120000_create_products.rb` debe definir la clase `CreateProducts` y `20080906120001_add_details_to_products.rb` debe definir `AddDetailsToProducts`. Rails utiliza esta marca de tiempo para determinar qué migración se debe ejecutar y en qué orden, así que si estás copiando una migración de otra aplicación o generando un archivo tú mismo, ten en cuenta su posición en el orden.

Por supuesto, calcular marcas de tiempo no es divertido, por lo que Active Record proporciona un generador para hacerlo por ti:

```bash
$ bin/rails generate migration AddPartNumberToProducts
```
Esto creará una migración vacía con el nombre apropiado:

```ruby
class AddPartNumberToProducts < ActiveRecord::Migration[7.1]
  def change
  end
end
```

Este generador puede hacer mucho más que agregar una marca de tiempo al nombre del archivo.
Según las convenciones de nomenclatura y los argumentos adicionales (opcionales), también puede
comenzar a completar la migración.

### Agregar nuevas columnas

Si el nombre de la migración tiene la forma "AddColumnToTable" o
"RemoveColumnFromTable" y va seguido de una lista de nombres de columna y
tipos, se creará una migración que contenga las declaraciones [`add_column`][] y
[`remove_column`][] apropiadas.

```bash
$ bin/rails generate migration AddPartNumberToProducts part_number:string
```

Esto generará la siguiente migración:

```ruby
class AddPartNumberToProducts < ActiveRecord::Migration[7.1]
  def change
    add_column :products, :part_number, :string
  end
end
```

Si desea agregar un índice en la nueva columna, también puede hacerlo.

```bash
$ bin/rails generate migration AddPartNumberToProducts part_number:string:index
```

Esto generará las declaraciones [`add_column`][] y [`add_index`][] apropiadas:

```ruby
class AddPartNumberToProducts < ActiveRecord::Migration[7.1]
  def change
    add_column :products, :part_number, :string
    add_index :products, :part_number
  end
end
```

No está limitado a una columna generada automáticamente. Por ejemplo:

```bash
$ bin/rails generate migration AddDetailsToProducts part_number:string price:decimal
```

Generará una migración de esquema que agrega dos columnas adicionales
a la tabla `products`.

```ruby
class AddDetailsToProducts < ActiveRecord::Migration[7.1]
  def change
    add_column :products, :part_number, :string
    add_column :products, :price, :decimal
  end
end
```

### Eliminación de columnas

De manera similar, puede generar una migración para eliminar una columna desde la línea de comandos:

```bash
$ bin/rails generate migration RemovePartNumberFromProducts part_number:string
```

Esto genera las declaraciones [`remove_column`][] apropiadas:

```ruby
class RemovePartNumberFromProducts < ActiveRecord::Migration[7.1]
  def change
    remove_column :products, :part_number, :string
  end
end
```

### Creación de nuevas tablas

Si el nombre de la migración tiene la forma "CreateXXX" y va seguido de una lista de
nombres de columna y tipos, se generará una migración que crea la tabla XXX con las
columnas enumeradas. Por ejemplo:

```bash
$ bin/rails generate migration CreateProducts name:string part_number:string
```

genera

```ruby
class CreateProducts < ActiveRecord::Migration[7.1]
  def change
    create_table :products do |t|
      t.string :name
      t.string :part_number

      t.timestamps
    end
  end
end
```

Como siempre, lo que se ha generado es solo un punto de partida.
Puede agregar o eliminar lo que desee editando el archivo
`db/migrate/YYYYMMDDHHMMSS_add_details_to_products.rb`.

### Creación de asociaciones utilizando referencias

Además, el generador acepta el tipo de columna como `references` (también disponible como
`belongs_to`). Por ejemplo,

```bash
$ bin/rails generate migration AddUserRefToProducts user:references
```

genera la siguiente llamada [`add_reference`][]:

```ruby
class AddUserRefToProducts < ActiveRecord::Migration[7.1]
  def change
    add_reference :products, :user, foreign_key: true
  end
end
```

Esta migración creará una columna `user_id`. Las [referencias](#references) son una
forma abreviada de crear columnas, índices, claves externas o incluso columnas de asociación polimórfica.

También hay un generador que producirá tablas de unión si `JoinTable` es parte del nombre:

```bash
$ bin/rails generate migration CreateJoinTableCustomerProduct customer product
```

producirá la siguiente migración:

```ruby
class CreateJoinTableCustomerProduct < ActiveRecord::Migration[7.1]
  def change
    create_join_table :customers, :products do |t|
      # t.index [:customer_id, :product_id]
      # t.index [:product_id, :customer_id]
    end
  end
end
```


### Generadores de modelos

Los generadores de modelos, recursos y andamios crearán migraciones adecuadas para agregar
un nuevo modelo. Esta migración ya contendrá instrucciones para crear la
tabla relevante. Si le dice a Rails qué columnas desea, también se crearán declaraciones para
agregar estas columnas. Por ejemplo, al ejecutar:

```bash
$ bin/rails generate model Product name:string description:text
```

Esto creará una migración que se verá así:

```ruby
class CreateProducts < ActiveRecord::Migration[7.1]
  def change
    create_table :products do |t|
      t.string :name
      t.text :description

      t.timestamps
    end
  end
end
```

Puede agregar tantos pares de nombres de columna/tipo como desee.

### Pasar modificadores

Algunos [modificadores de tipo](#column-modifiers) comúnmente utilizados se pueden pasar directamente en
la línea de comandos. Están encerrados entre llaves y siguen al tipo de campo:

Por ejemplo, al ejecutar:

```bash
$ bin/rails generate migration AddDetailsToProducts 'price:decimal{5,2}' supplier:references{polymorphic}
```

se producirá una migración que se verá así:

```ruby
class AddDetailsToProducts < ActiveRecord::Migration[7.1]
  def change
    add_column :products, :price, :decimal, precision: 5, scale: 2
    add_reference :products, :supplier, polymorphic: true
  end
end
```

CONSEJO: Consulte la salida de ayuda de los generadores (`bin/rails generate --help`)
para obtener más detalles.

Escritura de migraciones
------------------

Una vez que haya creado su migración utilizando uno de los generadores, es hora de
ponerse a trabajar!

### Crear una tabla

El método [`create_table`][] es uno de los más fundamentales, pero la mayoría de las veces
se generará automáticamente al usar un generador de modelos, recursos o andamios. Un uso típico sería
```ruby
create_table :products do |t|
  t.string :name
end
```

Este método crea una tabla `products` con una columna llamada `name`.

Por defecto, `create_table` creará implícitamente una clave primaria llamada `id` para ti. Puedes cambiar el nombre de la columna con la opción `:primary_key` o, si no quieres una clave primaria en absoluto, puedes pasar la opción `id: false`.

Si necesitas pasar opciones específicas de la base de datos, puedes colocar un fragmento SQL en la opción `:options`. Por ejemplo:

```ruby
create_table :products, options: "ENGINE=BLACKHOLE" do |t|
  t.string :name, null: false
end
```

Esto agregará `ENGINE=BLACKHOLE` a la declaración SQL utilizada para crear la tabla.

Se puede crear un índice en las columnas creadas dentro del bloque `create_table` pasando `index: true` o un hash de opciones a la opción `:index`:

```ruby
create_table :users do |t|
  t.string :name, index: true
  t.string :email, index: { unique: true, name: 'unique_emails' }
end
```

También puedes pasar la opción `:comment` con cualquier descripción para la tabla que se almacenará en la base de datos misma y se puede ver con herramientas de administración de bases de datos, como MySQL Workbench o PgAdmin III. Se recomienda encarecidamente especificar comentarios en las migraciones para aplicaciones con bases de datos grandes, ya que ayuda a las personas a comprender el modelo de datos y generar documentación. Actualmente, solo los adaptadores de MySQL y PostgreSQL admiten comentarios.


### Creando una tabla de unión

El método de migración [`create_join_table`][] crea una tabla de unión HABTM (tiene y pertenece a muchos). Un uso típico sería:

```ruby
create_join_table :products, :categories
```

Esta migración creará una tabla `categories_products` con dos columnas llamadas `category_id` y `product_id`.

Estas columnas tienen la opción `:null` establecida en `false` de forma predeterminada, lo que significa que **debes** proporcionar un valor para guardar un registro en esta tabla. Esto se puede anular especificando la opción `:column_options`:

```ruby
create_join_table :products, :categories, column_options: { null: true }
```

De forma predeterminada, el nombre de la tabla de unión proviene de la unión de los dos primeros argumentos proporcionados a `create_join_table`, en orden alfabético.

Para personalizar el nombre de la tabla, proporciona la opción `:table_name`:

```ruby
create_join_table :products, :categories, table_name: :categorization
```

Esto asegura que el nombre de la tabla de unión sea `categorization` como se solicitó.

Además, `create_join_table` acepta un bloque, que puedes usar para agregar índices (que no se crean de forma predeterminada) o cualquier columna adicional que elijas.

```ruby
create_join_table :products, :categories do |t|
  t.index :product_id
  t.index :category_id
end
```


### Cambiando tablas

Si quieres cambiar una tabla existente en su lugar, existe [`change_table`][].

Se utiliza de manera similar a `create_table`, pero el objeto que se pasa dentro del bloque tiene acceso a una serie de funciones especiales, por ejemplo:

```ruby
change_table :products do |t|
  t.remove :description, :name
  t.string :part_number
  t.index :part_number
  t.rename :upccode, :upc_code
end
```

Esta migración eliminará las columnas `description` y `name`, creará una nueva columna de tipo string llamada `part_number` y le agregará un índice. Finalmente, cambiará el nombre de la columna `upccode` a `upc_code`.


### Cambiando columnas

Similar a los métodos `remove_column` y `add_column` que cubrimos [anteriormente](#adding-new-columns), Rails también proporciona el método de migración [`change_column`][].

```ruby
change_column :products, :part_number, :text
```

Esto cambia la columna `part_number` en la tabla `products` a un campo `:text`.

NOTA: El comando `change_column` es **irreversible**. Debes proporcionar tu propia migración `reversible`, como discutimos [antes](#making-the-irreversible-possible).

Además de `change_column`, los métodos [`change_column_null`][] y [`change_column_default`][] se utilizan específicamente para cambiar una restricción de nulidad y los valores predeterminados de una columna.

```ruby
change_column_null :products, :name, false
change_column_default :products, :approved, from: true, to: false
```

Esto establece que el campo `:name` en `products` sea una columna `NOT NULL` y el valor predeterminado del campo `:approved` cambia de verdadero a falso. Estos cambios solo se aplicarán a transacciones futuras, los registros existentes no se ven afectados.

Cuando se establece la restricción de nulidad en verdadero, esto significa que la columna aceptará un valor nulo, de lo contrario, se aplica la restricción `NOT NULL` y se debe pasar un valor para persistir el registro en la base de datos.

NOTA: También podrías escribir la migración `change_column_default` anterior como `change_column_default :products, :approved, false`, pero a diferencia del ejemplo anterior, esto haría que tu migración no sea reversible.


### Modificadores de columna

Los modificadores de columna se pueden aplicar al crear o cambiar una columna:

* `comment`      Agrega un comentario para la columna.
* `collation`    Especifica la intercalación para una columna `string` o `text`.
* `default`      Permite establecer un valor predeterminado en la columna. Ten en cuenta que si estás utilizando un valor dinámico (como una fecha), el valor predeterminado solo se calculará la primera vez (es decir, en la fecha en que se aplique la migración). Usa `nil` para `NULL`.
* `limit`        Establece el número máximo de caracteres para una columna `string` y el número máximo de bytes para columnas `text/binary/integer`.
* `null`         Permite o prohíbe los valores `NULL` en la columna.
* `precision`    Especifica la precisión para columnas `decimal/numeric/datetime/time`.
* `scale`        Especifica la escala para las columnas `decimal` y `numeric`, que representa el número de dígitos después del punto decimal.
NOTA: Para `add_column` o `change_column` no hay opción para agregar índices.
Deben agregarse por separado utilizando `add_index`.

Algunos adaptadores pueden admitir opciones adicionales; consulte la documentación específica del adaptador
para obtener más información.

NOTA: `null` y `default` no se pueden especificar a través de la línea de comandos al generar
migraciones.

### Referencias

El método `add_reference` permite la creación de una columna con un nombre apropiado
que actúa como la conexión entre una o más asociaciones.

```ruby
add_reference :users, :role
```

Esta migración creará una columna `role_id` en la tabla de usuarios. También crea un
índice para esta columna, a menos que se indique explícitamente lo contrario con la opción
`index: false`.

INFO: Consulte también la guía de [Asociaciones de Active Record][] para obtener más información.

El método `add_belongs_to` es un alias de `add_reference`.

```ruby
add_belongs_to :taggings, :taggable, polymorphic: true
```

La opción `polymorphic` creará dos columnas en la tabla de taggings que se pueden
utilizar para asociaciones polimórficas: `taggable_type` y `taggable_id`.

INFO: Consulte esta guía para obtener más información sobre [asociaciones polimórficas][].

Se puede crear una clave externa con la opción `foreign_key`.

```ruby
add_reference :users, :role, foreign_key: true
```

Para obtener más opciones de `add_reference`, visite la [documentación de la API](https://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html#method-i-add_reference).

También se pueden eliminar referencias:

```ruby
remove_reference :products, :user, foreign_key: true, index: false
```

[Asociaciones de Active Record]: association_basics.html
[asociaciones polimórficas]: association_basics.html#asociaciones-polimórficas

### Claves externas

Si bien no es obligatorio, es posible que desee agregar restricciones de clave externa para
[garantizar la integridad referencial](#active-record-y-la-integridad-referencial).

```ruby
add_foreign_key :articles, :authors
```

Esta llamada [`add_foreign_key`][] agrega una nueva restricción a la tabla `articles`.
La restricción garantiza que exista una fila en la tabla `authors` donde
la columna `id` coincida con `articles.author_id`.

Si el nombre de la columna `from_table` no se puede derivar del nombre de la `to_table`,
puede utilizar la opción `:column`. Utilice la opción `:primary_key` si la
clave primaria de referencia no es `:id`.

Por ejemplo, para agregar una clave externa en `articles.reviewer` que referencia `authors.email`:

```ruby
add_foreign_key :articles, :authors, column: :reviewer, primary_key: :email
```

Esto agregará una restricción a la tabla `articles` que garantiza que exista una fila en la
tabla `authors` donde la columna `email` coincida con el campo `articles.reviewer`.

`add_foreign_key` admite varias otras opciones como `name`, `on_delete`, `if_not_exists`, `validate`
y `deferrable`.

Las claves externas también se pueden eliminar utilizando [`remove_foreign_key`][]:

```ruby
# dejar que Active Record determine el nombre de la columna
remove_foreign_key :accounts, :branches

# eliminar clave externa para una columna específica
remove_foreign_key :accounts, column: :owner_id
```

NOTA: Active Record solo admite claves externas de una sola columna. Se requiere `execute` y
`structure.sql` para usar claves externas compuestas. Consulte
[Volcado de esquema y usted](#volcado-de-esquema-y-usted).

### Cuando los ayudantes no son suficientes

Si los ayudantes proporcionados por Active Record no son suficientes, puede utilizar el método [`execute`][]
para ejecutar SQL arbitrario:

```ruby
Product.connection.execute("UPDATE products SET price = 'free' WHERE 1=1")
```

Para obtener más detalles y ejemplos de métodos individuales, consulte la documentación de la API.

En particular, la documentación de
[`ActiveRecord::ConnectionAdapters::SchemaStatements`][], que proporciona los métodos disponibles en los métodos `change`, `up` y `down`.

Para los métodos disponibles con respecto al objeto devuelto por `create_table`, consulte [`ActiveRecord::ConnectionAdapters::TableDefinition`][].

Y para el objeto devuelto por `change_table`, consulte [`ActiveRecord::ConnectionAdapters::Table`][].


### Uso del método `change`

El método `change` es la forma principal de escribir migraciones. Funciona para
la mayoría de los casos en los que Active Record sabe cómo revertir automáticamente las acciones de una migración. A continuación se muestran algunas de las acciones que admite `change`:

* [`add_check_constraint`][]
* [`add_column`][]
* [`add_foreign_key`][]
* [`add_index`][]
* [`add_reference`][]
* [`add_timestamps`][]
* [`change_column_comment`][] (debe proporcionar las opciones `:from` y `:to`)
* [`change_column_default`][] (debe proporcionar las opciones `:from` y `:to`)
* [`change_column_null`][]
* [`change_table_comment`][] (debe proporcionar las opciones `:from` y `:to`)
* [`create_join_table`][]
* [`create_table`][]
* `disable_extension`
* [`drop_join_table`][]
* [`drop_table`][] (debe proporcionar un bloque)
* `enable_extension`
* [`remove_check_constraint`][] (debe proporcionar una expresión de restricción)
* [`remove_column`][] (debe proporcionar un tipo)
* [`remove_columns`][] (debe proporcionar la opción `:type`)
* [`remove_foreign_key`][] (debe proporcionar una segunda tabla)
* [`remove_index`][]
* [`remove_reference`][]
* [`remove_timestamps`][]
* [`rename_column`][]
* [`rename_index`][]
* [`rename_table`][]

[`change_table`][] también es reversible, siempre y cuando el bloque solo llame
a operaciones reversibles como las mencionadas anteriormente.

`remove_column` es reversible si proporciona el tipo de columna como tercer
argumento. Proporcione también las opciones de columna originales, de lo contrario Rails no puede
recrear la columna exactamente al deshacer la migración:

```ruby
remove_column :posts, :slug, :string, null: false, default: ''
```

Si va a necesitar utilizar otros métodos, debe utilizar `reversible`
o escribir los métodos `up` y `down` en lugar de utilizar el método `change`.
### Usando `reversible`

Las migraciones complejas pueden requerir procesamiento que Active Record no sabe cómo revertir. Puedes usar [`reversible`][] para especificar qué hacer al ejecutar una migración y qué más hacer al revertirla. Por ejemplo:

```ruby
class ExampleMigration < ActiveRecord::Migration[7.1]
  def change
    create_table :distributors do |t|
      t.string :zipcode
    end

    reversible do |direction|
      direction.up do
        # crear una vista de distribuidores
        execute <<-SQL
          CREATE VIEW distributors_view AS
          SELECT id, zipcode
          FROM distributors;
        SQL
      end
      direction.down do
        execute <<-SQL
          DROP VIEW distributors_view;
        SQL
      end
    end

    add_column :users, :home_page_url, :string
    rename_column :users, :email, :email_address
  end
end
```

Usar `reversible` asegurará que las instrucciones se ejecuten en el orden correcto también. Si se revierte la migración de ejemplo anterior, el bloque `down` se ejecutará después de que se elimine la columna `home_page_url` y se cambie el nombre de la columna `email_address`, y justo antes de que se elimine la tabla `distributors`.


### Usando los métodos `up`/`down`

También puedes usar el estilo antiguo de migración utilizando los métodos `up` y `down` en lugar del método `change`.

El método `up` debe describir la transformación que deseas realizar en tu esquema, y el método `down` de tu migración debe revertir las transformaciones realizadas por el método `up`. En otras palabras, el esquema de la base de datos no debe cambiar si haces un `up` seguido de un `down`.

Por ejemplo, si creas una tabla en el método `up`, debes eliminarla en el método `down`. Es recomendable realizar las transformaciones en el orden inverso en el que se realizaron en el método `up`. El ejemplo de la sección `reversible` es equivalente a:

```ruby
class ExampleMigration < ActiveRecord::Migration[7.1]
  def up
    create_table :distributors do |t|
      t.string :zipcode
    end

    # crear una vista de distribuidores
    execute <<-SQL
      CREATE VIEW distributors_view AS
      SELECT id, zipcode
      FROM distributors;
    SQL

    add_column :users, :home_page_url, :string
    rename_column :users, :email, :email_address
  end

  def down
    rename_column :users, :email_address, :email
    remove_column :users, :home_page_url

    execute <<-SQL
      DROP VIEW distributors_view;
    SQL

    drop_table :distributors
  end
end
```

### Lanzar un error para evitar reversiones

A veces, tu migración hará algo que es simplemente irreversible; por ejemplo, podría destruir algunos datos.

En esos casos, puedes lanzar `ActiveRecord::IrreversibleMigration` en tu bloque `down`.

Si alguien intenta revertir tu migración, se mostrará un mensaje de error diciendo que no se puede hacer.

### Revertir migraciones anteriores

Puedes usar la capacidad de Active Record para revertir migraciones utilizando el método [`revert`][]:

```ruby
require_relative "20121212123456_example_migration"

class FixupExampleMigration < ActiveRecord::Migration[7.1]
  def change
    revert ExampleMigration

    create_table(:apples) do |t|
      t.string :variety
    end
  end
end
```

El método `revert` también acepta un bloque de instrucciones para revertir. Esto podría ser útil para revertir partes seleccionadas de migraciones anteriores.

Por ejemplo, imaginemos que se ha confirmado `ExampleMigration` y luego se decide que la vista de Distributors ya no es necesaria.

```ruby
class DontUseDistributorsViewMigration < ActiveRecord::Migration[7.1]
  def change
    revert do
      # código copiado de ExampleMigration
      reversible do |direction|
        direction.up do
          # crear una vista de distribuidores
          execute <<-SQL
            CREATE VIEW distributors_view AS
            SELECT id, zipcode
            FROM distributors;
          SQL
        end
        direction.down do
          execute <<-SQL
            DROP VIEW distributors_view;
          SQL
        end
      end

      # El resto de la migración estaba bien
    end
  end
end
```

La misma migración también podría haberse escrito sin usar `revert`, pero esto habría implicado algunos pasos adicionales:

1. Invertir el orden de `create_table` y `reversible`.
2. Reemplazar `create_table` con `drop_table`.
3. Finalmente, reemplazar `up` con `down` y viceversa.

Todo esto es manejado por `revert`.


Ejecutando migraciones
------------------

Rails proporciona un conjunto de comandos para ejecutar ciertos conjuntos de migraciones.

El primer comando relacionado con migraciones que probablemente usarás será `bin/rails db:migrate`. En su forma más básica, simplemente ejecuta el método `change` o `up` para todas las migraciones que aún no se han ejecutado. Si no hay tales migraciones, se sale. Ejecutará estas migraciones en orden según la fecha de la migración.

Ten en cuenta que al ejecutar el comando `db:migrate` también se invoca el comando `db:schema:dump`, que actualizará tu archivo `db/schema.rb` para que coincida con la estructura de tu base de datos.

Si especificas una versión objetivo, Active Record ejecutará las migraciones requeridas (change, up, down) hasta que haya alcanzado la versión especificada. La versión es el prefijo numérico en el nombre de archivo de la migración. Por ejemplo, para migrar a la versión 20080906120000, ejecuta:
```bash
$ bin/rails db:migrate VERSION=20080906120000
```

Si la versión 20080906120000 es mayor que la versión actual (es decir, se está migrando hacia arriba), esto ejecutará el método `change` (o `up`) en todas las migraciones hasta e incluyendo 20080906120000, y no ejecutará ninguna migración posterior. Si se está migrando hacia abajo, esto ejecutará el método `down` en todas las migraciones hasta, pero no incluyendo, 20080906120000.

### Revertir

Una tarea común es revertir la última migración. Por ejemplo, si cometiste un error en ella y deseas corregirlo. En lugar de buscar el número de versión asociado con la migración anterior, puedes ejecutar:

```bash
$ bin/rails db:rollback
```

Esto revertirá la última migración, ya sea revirtiendo el método `change` o ejecutando el método `down`. Si necesitas deshacer varias migraciones, puedes proporcionar un parámetro `STEP`:

```bash
$ bin/rails db:rollback STEP=3
```

Se revertirán las últimas 3 migraciones.

El comando `db:migrate:redo` es un atajo para hacer un rollback y luego migrar hacia arriba nuevamente. Al igual que el comando `db:rollback`, puedes usar el parámetro `STEP` si necesitas retroceder más de una versión, por ejemplo:

```bash
$ bin/rails db:migrate:redo STEP=3
```

Ninguno de estos comandos de Rails hace algo que no se pueda hacer con `db:migrate`. Están ahí por conveniencia, ya que no necesitas especificar explícitamente la versión a la que migrar.

### Configurar la base de datos

El comando `bin/rails db:setup` creará la base de datos, cargará el esquema e inicializará los datos de inicio.

### Restablecer la base de datos

El comando `bin/rails db:reset` eliminará la base de datos y la configurará nuevamente. Esto es funcionalmente equivalente a `bin/rails db:drop db:setup`.

NOTA: Esto no es lo mismo que ejecutar todas las migraciones. Solo utilizará el contenido del archivo `db/schema.rb` o `db/structure.sql` actual. Si una migración no se puede revertir, `bin/rails db:reset` puede no ayudarte. Para obtener más información sobre cómo volcar el esquema, consulta la sección [Volcado de esquema y tú][].

[Volcado de esquema y tú]: #volcado-de-esquema-y-tú

### Ejecutar migraciones específicas

Si necesitas ejecutar una migración específica hacia arriba o hacia abajo, los comandos `db:migrate:up` y `db:migrate:down` lo harán. Solo especifica la versión correspondiente y se invocará el método `change`, `up` o `down` de la migración correspondiente, por ejemplo:

```bash
$ bin/rails db:migrate:up VERSION=20080906120000
```

Al ejecutar este comando, se ejecutará el método `change` (o el método `up`) para la migración con la versión "20080906120000".

Primero, este comando verificará si la migración existe y si ya se ha realizado y no hará nada en ese caso.

Si la versión especificada no existe, Rails lanzará una excepción.

```bash
$ bin/rails db:migrate VERSION=zomg
rails aborted!
ActiveRecord::UnknownMigrationVersionError:

No hay ninguna migración con el número de versión zomg.
```

### Ejecutar migraciones en diferentes entornos

De forma predeterminada, ejecutar `bin/rails db:migrate` se ejecutará en el entorno `development`.

Para ejecutar migraciones en otro entorno, puedes especificarlo utilizando la variable de entorno `RAILS_ENV` mientras ejecutas el comando. Por ejemplo, para ejecutar migraciones en el entorno `test`, puedes ejecutar:

```bash
$ bin/rails db:migrate RAILS_ENV=test
```

### Cambiar la salida de las migraciones

De forma predeterminada, las migraciones te indican exactamente lo que están haciendo y cuánto tiempo llevó. Una migración que crea una tabla y agrega un índice podría producir una salida como esta:

```
==  CreateProducts: migrating =================================================
-- create_table(:products)
   -> 0.0028s
==  CreateProducts: migrated (0.0028s) ========================================
```

Se proporcionan varios métodos en las migraciones que te permiten controlar todo esto:

| Método                     | Propósito
| -------------------------- | -------
| [`suppress_messages`][]    | Toma un bloque como argumento y suprime cualquier salida generada por el bloque.
| [`say`][]                  | Toma un argumento de mensaje y lo muestra tal cual. Se puede pasar un segundo argumento booleano para especificar si se debe sangrar o no.
| [`say_with_time`][]        | Muestra texto junto con cuánto tiempo llevó ejecutar su bloque. Si el bloque devuelve un número entero, asume que es el número de filas afectadas.

Por ejemplo, toma la siguiente migración:

```ruby
class CreateProducts < ActiveRecord::Migration[7.1]
  def change
    suppress_messages do
      create_table :products do |t|
        t.string :name
        t.text :description
        t.timestamps
      end
    end

    say "Created a table"

    suppress_messages { add_index :products, :name }
    say "and an index!", true

    say_with_time 'Waiting for a while' do
      sleep 10
      250
    end
  end
end
```

Esto generará la siguiente salida:

```
==  CreateProducts: migrando =================================================
-- Se creó una tabla
   -> ¡y un índice!
-- Esperando un momento
   -> 10.0013s
   -> 250 filas
==  CreateProducts: migrado (10.0054s) =======================================
```

Si desea que Active Record no muestre nada, ejecutar `bin/rails db:migrate
VERBOSE=false` suprimirá toda la salida.


Modificación de migraciones existentes
----------------------------

Ocasionalmente, puede cometer un error al escribir una migración. Si ya ha ejecutado la migración, no puede simplemente editar la migración y ejecutarla nuevamente: Rails cree que ya ha ejecutado la migración y no hará nada cuando ejecute `bin/rails db:migrate`. Debe deshacer la migración (por ejemplo, con `bin/rails db:rollback`), editar su migración y luego ejecutar `bin/rails db:migrate` para ejecutar la versión corregida.

En general, editar migraciones existentes no es una buena idea. Estará creando trabajo adicional para usted y sus compañeros de trabajo y causará dolores de cabeza importantes si la versión existente de la migración ya se ha ejecutado en máquinas de producción.

En su lugar, debe escribir una nueva migración que realice los cambios que necesita. Editar una migración recién generada que aún no se ha confirmado en el control de origen (o, más generalmente, que no se ha propagado más allá de su máquina de desarrollo) es relativamente inofensivo.

El método `revert` puede ser útil al escribir una nueva migración para deshacer migraciones anteriores en su totalidad o en parte (consulte [Reverting Previous Migrations][] arriba).

[Reverting Previous Migrations]: #reverting-previous-migrations

Volcado de esquema y tú
----------------------

### ¿Para qué sirven los archivos de esquema?

Las migraciones, por poderosas que sean, no son la fuente autoritaria del esquema de su base de datos. **Su base de datos sigue siendo la fuente de verdad**.

De forma predeterminada, Rails genera `db/schema.rb`, que intenta capturar el estado actual del esquema de su base de datos.

Suele ser más rápido y menos propenso a errores crear una nueva instancia de la base de datos de su aplicación cargando el archivo de esquema a través de `bin/rails db:schema:load` que reproducir toda la historia de migraciones. Las [migraciones antiguas][] pueden no aplicarse correctamente si esas migraciones utilizan dependencias externas cambiantes o dependen de código de aplicación que evoluciona por separado de sus migraciones.

Los archivos de esquema también son útiles si desea ver rápidamente qué atributos tiene un objeto Active Record. Esta información no está en el código del modelo y a menudo se encuentra en varias migraciones, pero la información se resume muy bien en el archivo de esquema.

[migraciones antiguas]: #migraciones-antiguas

### Tipos de volcados de esquema

El formato del volcado de esquema generado por Rails está controlado por la configuración [`config.active_record.schema_format`][] definida en `config/application.rb`. De forma predeterminada, el formato es `:ruby`, o alternativamente se puede establecer en `:sql`.

#### Uso del esquema `:ruby` predeterminado

Cuando se selecciona `:ruby`, el esquema se almacena en `db/schema.rb`. Si observa este archivo, verá que se parece mucho a una migración muy grande:

```ruby
ActiveRecord::Schema[7.1].define(version: 2008_09_06_171750) do
  create_table "authors", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "products", force: true do |t|
    t.string   "name"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "part_number"
  end
end
```

En muchos aspectos, esto es exactamente lo que es. Este archivo se crea inspeccionando la base de datos y expresando su estructura mediante `create_table`, `add_index`, y así sucesivamente.

#### Uso del volcado de esquema `:sql`

Sin embargo, `db/schema.rb` no puede expresar todo lo que su base de datos puede admitir, como disparadores, secuencias, procedimientos almacenados, etc.

Si está utilizando características como estas, debe establecer el formato de esquema en `:sql` para obtener un archivo de esquema preciso que sea útil para crear nuevas instancias de la base de datos.

Cuando el formato de esquema se establece en `:sql`, la estructura de la base de datos se volcará utilizando una herramienta específica de la base de datos en `db/structure.sql`. Por ejemplo, para PostgreSQL, se utiliza la utilidad `pg_dump`. Para MySQL y MariaDB, este archivo contendrá la salida de `SHOW CREATE TABLE` para las diversas tablas.

Para cargar el esquema desde `db/structure.sql`, ejecute `bin/rails db:schema:load`. La carga de este archivo se realiza ejecutando las declaraciones SQL que contiene. Por definición, esto creará una copia perfecta de la estructura de la base de datos.


### Volcados de esquema y control de origen
Dado que los archivos de esquema se utilizan comúnmente para crear nuevas bases de datos, se recomienda encarecidamente que se incluya el archivo de esquema en el control de origen.

Pueden ocurrir conflictos de fusión en el archivo de esquema cuando dos ramas modifican el esquema. Para resolver estos conflictos, ejecute `bin/rails db:migrate` para regenerar el archivo de esquema.

INFO: Las aplicaciones de Rails recién generadas ya tendrán la carpeta de migraciones incluida en el árbol de git, por lo que solo debe asegurarse de agregar cualquier nueva migración que agregue y comprometerlas.

Active Record e integridad referencial
---------------------------------------

La forma de Active Record sostiene que la inteligencia pertenece a los modelos, no a la base de datos. Como tal, no se recomienda el uso de características como disparadores o restricciones, que devuelven parte de esa inteligencia a la base de datos.

Las validaciones, como `validates :foreign_key, uniqueness: true`, son una forma en la que los modelos pueden hacer cumplir la integridad de los datos. La opción `:dependent` en las asociaciones permite que los modelos destruyan automáticamente los objetos secundarios cuando se destruye el padre. Al igual que cualquier cosa que funcione a nivel de aplicación, no pueden garantizar la integridad referencial, por lo que algunas personas las complementan con [restricciones de clave externa][] en la base de datos.

Aunque Active Record no proporciona todas las herramientas para trabajar directamente con estas características, el método `execute` se puede utilizar para ejecutar SQL arbitrario.

[restricciones de clave externa]: #restricciones-de-clave-externa

Migraciones y datos de inicio
------------------------

El propósito principal de la función de migración de Rails es emitir comandos que modifiquen el esquema utilizando un proceso consistente. Las migraciones también se pueden utilizar para agregar o modificar datos. Esto es útil en una base de datos existente que no se puede destruir y recrear, como una base de datos de producción.

```ruby
class AddInitialProducts < ActiveRecord::Migration[7.1]
  def up
    5.times do |i|
      Product.create(name: "Producto ##{i}", description: "Un producto.")
    end
  end

  def down
    Product.delete_all
  end
end
```

Para agregar datos iniciales después de crear una base de datos, Rails tiene una función incorporada de 'seeds' que acelera el proceso. Esto es especialmente útil al recargar la base de datos con frecuencia en entornos de desarrollo y prueba, o al configurar datos iniciales para producción.

Para comenzar con esta función, abra `db/seeds.rb` y agregue algún código Ruby, luego ejecute `bin/rails db:seed`.

NOTA: El código aquí debe ser idempotente para que se pueda ejecutar en cualquier momento en todos los entornos.

```ruby
["Acción", "Comedia", "Drama", "Terror"].each do |nombre_genero|
  MovieGenre.find_or_create_by!(name: nombre_genero)
end
```

Esta es generalmente una forma mucho más limpia de configurar la base de datos de una aplicación en blanco.

Migraciones antiguas
--------------

El archivo `db/schema.rb` o `db/structure.sql` es una instantánea del estado actual de su base de datos y es la fuente autorizada para reconstruir esa base de datos. Esto permite eliminar o podar archivos de migración antiguos.

Cuando se eliminan archivos de migración en el directorio `db/migrate/`, cualquier entorno en el que se haya ejecutado `bin/rails db:migrate` cuando esos archivos aún existían mantendrá una referencia a la marca de tiempo de migración específica para ellos dentro de una tabla interna de la base de datos de Rails llamada `schema_migrations`. Esta tabla se utiliza para realizar un seguimiento de si las migraciones se han ejecutado en un entorno específico.

Si ejecuta el comando `bin/rails db:migrate:status`, que muestra el estado (activado o desactivado) de cada migración, debería ver `********** NO FILE **********` mostrado junto a cualquier archivo de migración eliminado que alguna vez se haya ejecutado en un entorno específico pero que ya no se puede encontrar en el directorio `db/migrate/`.

### Migraciones de motores

Sin embargo, hay una advertencia con [Motores][]. Las tareas Rake para instalar migraciones de motores son idempotentes, lo que significa que tendrán el mismo resultado sin importar cuántas veces se llamen. Las migraciones presentes en la aplicación principal debido a una instalación anterior se omiten y las que faltan se copian con una nueva marca de tiempo principal. Si elimina migraciones antiguas del motor y ejecuta la tarea de instalación nuevamente, obtendrá nuevos archivos con nuevas marcas de tiempo, y `db:migrate` intentará ejecutarlos nuevamente.

Por lo tanto, generalmente desea conservar las migraciones que provienen de los motores. Tienen un comentario especial como este:

```ruby
# Esta migración proviene de blorgh (originalmente 20210621082949)
```

 [Motores]: engines.html
[`add_column`]: https://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html#method-i-add_column
[`add_index`]: https://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html#method-i-add_index
[`add_reference`]: https://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html#method-i-add_reference
[`remove_column`]: https://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html#method-i-remove_column
[`create_table`]: https://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html#method-i-create_table
[`create_join_table`]: https://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html#method-i-create_join_table
[`change_table`]: https://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html#method-i-change_table
[`change_column`]: https://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html#method-i-change_column
[`change_column_default`]: https://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html#method-i-change_column_default
[`change_column_null`]: https://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html#method-i-change_column_null
[`execute`]: https://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/DatabaseStatements.html#method-i-execute
[`ActiveRecord::ConnectionAdapters::SchemaStatements`]: https://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html
[`ActiveRecord::ConnectionAdapters::TableDefinition`]: https://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/TableDefinition.html
[`ActiveRecord::ConnectionAdapters::Table`]: https://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/Table.html
[`add_check_constraint`]: https://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html#method-i-add_check_constraint
[`add_foreign_key`]: https://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html#method-i-add_foreign_key
[`add_timestamps`]: https://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html#method-i-add_timestamps
[`change_column_comment`]: https://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html#method-i-change_column_comment
[`change_table_comment`]: https://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html#method-i-change_table_comment
[`drop_join_table`]: https://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html#method-i-drop_join_table
[`drop_table`]: https://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html#method-i-drop_table
[`remove_check_constraint`]: https://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html#method-i-remove_check_constraint
[`remove_foreign_key`]: https://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html#method-i-remove_foreign_key
[`remove_index`]: https://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html#method-i-remove_index
[`remove_reference`]: https://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html#method-i-remove_reference
[`remove_timestamps`]: https://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html#method-i-remove_timestamps
[`rename_column`]: https://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html#method-i-rename_column
[`remove_columns`]: https://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html#method-i-remove_columns
[`rename_index`]: https://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html#method-i-rename_index
[`rename_table`]: https://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html#method-i-rename_table
[`reversible`]: https://api.rubyonrails.org/classes/ActiveRecord/Migration.html#method-i-reversible
[`revert`]: https://api.rubyonrails.org/classes/ActiveRecord/Migration.html#method-i-revert
[`say`]: https://api.rubyonrails.org/classes/ActiveRecord/Migration.html#method-i-say
[`say_with_time`]: https://api.rubyonrails.org/classes/ActiveRecord/Migration.html#method-i-say_with_time
[`suppress_messages`]: https://api.rubyonrails.org/classes/ActiveRecord/Migration.html#method-i-suppress_messages
[`config.active_record.schema_format`]: configuring.html#config-active-record-schema-format
