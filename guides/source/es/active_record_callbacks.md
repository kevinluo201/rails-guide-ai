**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 320082396ef549e27ab4cb837ec975dd
Callbacks de Active Record
============================

Esta guía te enseña cómo engancharte en el ciclo de vida de tus objetos de Active Record.

Después de leer esta guía, sabrás:

* Cuándo ocurren ciertos eventos durante la vida de un objeto de Active Record.
* Cómo crear métodos de callback que respondan a eventos en el ciclo de vida del objeto.
* Cómo crear clases especiales que encapsulen comportamientos comunes para tus callbacks.

--------------------------------------------------------------------------------

El Ciclo de Vida del Objeto
---------------------------

Durante el funcionamiento normal de una aplicación de Rails, los objetos pueden ser creados, actualizados y destruidos. Active Record proporciona ganchos en este *ciclo de vida del objeto* para que puedas controlar tu aplicación y sus datos.

Los callbacks te permiten activar lógica antes o después de una alteración en el estado de un objeto.

```ruby
class Baby < ApplicationRecord
  after_create -> { puts "¡Felicidades!" }
end
```

```irb
irb> @baby = Baby.create
¡Felicidades!
```

Como verás, hay muchos eventos en el ciclo de vida y puedes elegir engancharte en cualquiera de ellos, ya sea antes, después o incluso alrededor de ellos.

Resumen de los Callbacks
------------------------

Los callbacks son métodos que se llaman en ciertos momentos del ciclo de vida de un objeto. Con los callbacks, es posible escribir código que se ejecutará cada vez que se crea, guarda, actualiza, elimina, valida o carga desde la base de datos un objeto de Active Record.

### Registro de Callbacks

Para usar los callbacks disponibles, debes registrarlos. Puedes implementar los callbacks como métodos ordinarios y usar un método de clase de estilo macro para registrarlos como callbacks:

```ruby
class User < ApplicationRecord
  validates :login, :email, presence: true

  before_validation :ensure_login_has_a_value

  private
    def ensure_login_has_a_value
      if login.blank?
        self.login = email unless email.blank?
      end
    end
end
```

Los métodos de clase de estilo macro también pueden recibir un bloque. Considera usar este estilo si el código dentro de tu bloque es tan corto que cabe en una sola línea:

```ruby
class User < ApplicationRecord
  validates :login, :email, presence: true

  before_create do
    self.name = login.capitalize if name.blank?
  end
end
```

Alternativamente, puedes pasar un proc al callback para que se active.

```ruby
class User < ApplicationRecord
  before_create ->(user) { user.name = user.login.capitalize if user.name.blank? }
end
```

Por último, puedes definir tu propio objeto de callback personalizado, que cubriremos más adelante en más detalle [abajo](#clases-de-callbacks).

```ruby
class User < ApplicationRecord
  before_create MaybeAddName
end

class MaybeAddName
  def self.before_create(record)
    if record.name.blank?
      record.name = record.login.capitalize
    end
  end
end
```

Los callbacks también se pueden registrar para que se activen solo en ciertos eventos del ciclo de vida, lo que permite un control completo sobre cuándo y en qué contexto se activan tus callbacks.

```ruby
class User < ApplicationRecord
  before_validation :normalize_name, on: :create

  # :on también puede tomar un array
  after_validation :set_location, on: [ :create, :update ]

  private
    def normalize_name
      self.name = name.downcase.titleize
    end

    def set_location
      self.location = LocationService.query(self)
    end
end
```

Se considera una buena práctica declarar los métodos de callback como privados. Si se dejan públicos, se pueden llamar desde fuera del modelo y violar el principio de encapsulación del objeto.

ADVERTENCIA. Evita llamar a `update`, `save` u otros métodos que creen efectos secundarios en el objeto dentro de tu callback. Por ejemplo, no llames a `update(attribute: "valor")` dentro de un callback. Esto puede alterar el estado del modelo y puede resultar en efectos secundarios inesperados durante la confirmación. En su lugar, puedes asignar valores directamente de forma segura (por ejemplo, `self.attribute = "valor"`) en `before_create` / `before_update` o en callbacks anteriores.

Callbacks Disponibles
---------------------

Aquí tienes una lista con todos los callbacks disponibles de Active Record, enumerados en el mismo orden en el que se llamarán durante las respectivas operaciones:

### Crear un Objeto

* [`before_validation`][]
* [`after_validation`][]
* [`before_save`][]
* [`around_save`][]
* [`before_create`][]
* [`around_create`][]
* [`after_create`][]
* [`after_save`][]
* [`after_commit`][] / [`after_rollback`][]


### Actualizar un Objeto

* [`before_validation`][]
* [`after_validation`][]
* [`before_save`][]
* [`around_save`][]
* [`before_update`][]
* [`around_update`][]
* [`after_update`][]
* [`after_save`][]
* [`after_commit`][] / [`after_rollback`][]


ADVERTENCIA. `after_save` se ejecuta tanto en la creación como en la actualización, pero siempre _después_ de los callbacks más específicos `after_create` y `after_update`, sin importar el orden en el que se ejecutaron las llamadas a las macros.

### Destruir un Objeto

* [`before_destroy`][]
* [`around_destroy`][]
* [`after_destroy`][]
* [`after_commit`][] / [`after_rollback`][]


NOTA: Los callbacks `before_destroy` deben colocarse antes de las asociaciones `dependent: :destroy` (o usar la opción `prepend: true`), para asegurarse de que se ejecuten antes de que los registros sean eliminados por `dependent: :destroy`.

ADVERTENCIA. `after_commit` ofrece garantías muy diferentes a `after_save`, `after_update` y `after_destroy`. Por ejemplo, si ocurre una excepción en un `after_save`, la transacción se revertirá y los datos no se persistirán. Mientras que cualquier cosa que ocurra `after_commit` puede garantizar que la transacción ya se ha completado y los datos se han persistido en la base de datos. Más información sobre [callbacks transaccionales](#callbacks-transaccionales) a continuación.
### `after_initialize` y `after_find`

Cada vez que se instancia un objeto Active Record, se llamará al callback [`after_initialize`][], ya sea utilizando directamente `new` o cuando se carga un registro desde la base de datos. Puede ser útil para evitar la necesidad de anular directamente el método `initialize` de Active Record.

Cuando se carga un registro desde la base de datos, se llamará al callback [`after_find`][]. `after_find` se llama antes de `after_initialize` si ambos están definidos.

NOTA: Los callbacks `after_initialize` y `after_find` no tienen contrapartes `before_*`.

Se pueden registrar de la misma manera que los otros callbacks de Active Record.

```ruby
class User < ApplicationRecord
  after_initialize do |user|
    puts "¡Has inicializado un objeto!"
  end

  after_find do |user|
    puts "¡Has encontrado un objeto!"
  end
end
```

```irb
irb> User.new
¡Has inicializado un objeto!
=> #<User id: nil>

irb> User.first
¡Has encontrado un objeto!
¡Has inicializado un objeto!
=> #<User id: 1>
```


### `after_touch`

El callback [`after_touch`][] se llamará cada vez que se toque un objeto Active Record.

```ruby
class User < ApplicationRecord
  after_touch do |user|
    puts "Has tocado un objeto"
  end
end
```

```irb
irb> u = User.create(name: 'Kuldeep')
=> #<User id: 1, name: "Kuldeep", created_at: "2013-11-25 12:17:49", updated_at: "2013-11-25 12:17:49">

irb> u.touch
Has tocado un objeto
=> true
```

Se puede usar junto con `belongs_to`:

```ruby
class Book < ApplicationRecord
  belongs_to :library, touch: true
  after_touch do
    puts 'Se tocó un libro'
  end
end

class Library < ApplicationRecord
  has_many :books
  after_touch :log_when_books_or_library_touched

  private
    def log_when_books_or_library_touched
      puts 'Se tocó un libro/biblioteca'
    end
end
```

```irb
irb> @book = Book.last
=> #<Book id: 1, library_id: 1, created_at: "2013-11-25 17:04:22", updated_at: "2013-11-25 17:05:05">

irb> @book.touch # activa @book.library.touch
Se tocó un libro
Se tocó un libro/biblioteca
=> true
```


Ejecución de Callbacks
-----------------

Los siguientes métodos activan los callbacks:

* `create`
* `create!`
* `destroy`
* `destroy!`
* `destroy_all`
* `destroy_by`
* `save`
* `save!`
* `save(validate: false)`
* `toggle!`
* `touch`
* `update_attribute`
* `update`
* `update!`
* `valid?`

Además, el callback `after_find` se activa mediante los siguientes métodos de búsqueda:

* `all`
* `first`
* `find`
* `find_by`
* `find_by_*`
* `find_by_*!`
* `find_by_sql`
* `last`

El callback `after_initialize` se activa cada vez que se inicializa un nuevo objeto de la clase.

NOTA: Los métodos `find_by_*` y `find_by_*!` son buscadores dinámicos generados automáticamente para cada atributo. Obtén más información sobre ellos en la sección [Buscadores dinámicos](active_record_querying.html#dynamic-finders)

Omitir Callbacks
------------------

Al igual que con las validaciones, también es posible omitir los callbacks utilizando los siguientes métodos:

* `decrement!`
* `decrement_counter`
* `delete`
* `delete_all`
* `delete_by`
* `increment!`
* `increment_counter`
* `insert`
* `insert!`
* `insert_all`
* `insert_all!`
* `touch_all`
* `update_column`
* `update_columns`
* `update_all`
* `update_counters`
* `upsert`
* `upsert_all`

Sin embargo, estos métodos deben usarse con precaución, ya que las reglas comerciales importantes y la lógica de la aplicación pueden estar en los callbacks. Pasarlos por alto sin entender las posibles implicaciones puede llevar a datos no válidos.

Detener la ejecución
-----------------

Al registrar nuevos callbacks para tus modelos, se encolarán para su ejecución. Esta cola incluirá todas las validaciones de tu modelo, los callbacks registrados y la operación de base de datos que se ejecutará.

Toda la cadena de callbacks está envuelta en una transacción. Si algún callback genera una excepción, se detiene la cadena de ejecución y se emite un ROLLBACK. Para detener intencionalmente una cadena, utiliza:

```ruby
throw :abort
```

ADVERTENCIA. Cualquier excepción que no sea `ActiveRecord::Rollback` o `ActiveRecord::RecordInvalid` será lanzada nuevamente por Rails después de que se detenga la cadena de callbacks. Además, puede romper el código que no espera que los métodos como `save` y `update` (que normalmente intentan devolver `true` o `false`) generen una excepción.

NOTA: Si se genera un `ActiveRecord::RecordNotDestroyed` dentro del callback `after_destroy`, `before_destroy` o `around_destroy`, no se volverá a generar y el método `destroy` devolverá `false`.

Callbacks Relacionales
--------------------

Los callbacks funcionan a través de las relaciones de los modelos e incluso se pueden definir mediante ellas. Supongamos un ejemplo en el que un usuario tiene muchos artículos. Los artículos de un usuario deben eliminarse si se elimina el usuario. Agreguemos un callback `after_destroy` al modelo `User` a través de su relación con el modelo `Article`:

```ruby
class User < ApplicationRecord
  has_many :articles, dependent: :destroy
end

class Article < ApplicationRecord
  after_destroy :log_destroy_action

  def log_destroy_action
    puts 'Artículo eliminado'
  end
end
```

```irb
irb> user = User.first
=> #<User id: 1>
irb> user.articles.create!
=> #<Article id: 1, user_id: 1>
irb> user.destroy
Artículo eliminado
=> #<User id: 1>
```
Callbacks Condicionales
---------------------

Al igual que con las validaciones, también podemos hacer que la llamada a un método de callback sea condicional en función del cumplimiento de un predicado dado. Podemos hacer esto utilizando las opciones `:if` y `:unless`, que pueden tomar un símbolo, un `Proc` o un `Array`.

Puede utilizar la opción `:if` cuando desee especificar en qué condiciones se debe llamar al callback. Si desea especificar las condiciones en las que el callback **no** debe ser llamado, entonces puede utilizar la opción `:unless`.

### Uso de `:if` y `:unless` con un `Symbol`

Puede asociar las opciones `:if` y `:unless` con un símbolo correspondiente al nombre de un método de predicado que se llamará justo antes del callback.

Cuando se utiliza la opción `:if`, el callback **no** se ejecutará si el método de predicado devuelve **false**; cuando se utiliza la opción `:unless`, el callback **no** se ejecutará si el método de predicado devuelve **true**. Esta es la opción más común.

```ruby
class Order < ApplicationRecord
  before_save :normalize_card_number, if: :paid_with_card?
end
```

Usando esta forma de registro, también es posible registrar varios predicados diferentes que deben ser llamados para verificar si el callback debe ser ejecutado. Cubriremos esto [a continuación](#multiple-callback-conditions).

### Uso de `:if` y `:unless` con un `Proc`

Es posible asociar `:if` y `:unless` con un objeto `Proc`. Esta opción es la más adecuada cuando se escriben métodos de validación cortos, generalmente de una sola línea:

```ruby
class Order < ApplicationRecord
  before_save :normalize_card_number,
    if: Proc.new { |order| order.paid_with_card? }
end
```

Como el proc se evalúa en el contexto del objeto, también es posible escribir esto como:

```ruby
class Order < ApplicationRecord
  before_save :normalize_card_number, if: Proc.new { paid_with_card? }
end
```

### Múltiples Condiciones de Callback

Las opciones `:if` y `:unless` también aceptan un array de procs o nombres de métodos como símbolos:

```ruby
class Comment < ApplicationRecord
  before_save :filter_content,
    if: [:subject_to_parental_control?, :untrusted_author?]
end
```

Puede incluir fácilmente un proc en la lista de condiciones:

```ruby
class Comment < ApplicationRecord
  before_save :filter_content,
    if: [:subject_to_parental_control?, Proc.new { untrusted_author? }]
end
```

### Uso de `:if` y `:unless` juntos

Los callbacks pueden combinar tanto `:if` como `:unless` en la misma declaración:

```ruby
class Comment < ApplicationRecord
  before_save :filter_content,
    if: Proc.new { forum.parental_control? },
    unless: Proc.new { author.trusted? }
end
```

El callback solo se ejecuta cuando todas las condiciones `:if` y ninguna de las condiciones `:unless` se evalúan como `true`.

Clases de Callbacks
----------------

A veces, los métodos de callback que escribas serán lo suficientemente útiles como para ser reutilizados por otros modelos. Active Record permite crear clases que encapsulan los métodos de callback, para que puedan ser reutilizados.

Aquí tienes un ejemplo en el que creamos una clase con un callback `after_destroy` para manejar la limpieza de archivos descartados en el sistema de archivos. Este comportamiento puede no ser único de nuestro modelo `PictureFile` y es posible que queramos compartirlo, por lo que es una buena idea encapsularlo en una clase separada. Esto facilitará la prueba de ese comportamiento y su modificación.

```ruby
class FileDestroyerCallback
  def after_destroy(file)
    if File.exist?(file.filepath)
      File.delete(file.filepath)
    end
  end
end
```

Cuando se declara dentro de una clase, como se muestra arriba, los métodos de callback recibirán el objeto del modelo como parámetro. Esto funcionará en cualquier modelo que use la clase de la siguiente manera:

```ruby
class PictureFile < ApplicationRecord
  after_destroy FileDestroyerCallback.new
end
```

Ten en cuenta que necesitamos instanciar un nuevo objeto `FileDestroyerCallback`, ya que declaramos nuestro callback como un método de instancia. Esto es particularmente útil si los callbacks utilizan el estado del objeto instanciado. Sin embargo, a menudo tendrá más sentido declarar los callbacks como métodos de clase:

```ruby
class FileDestroyerCallback
  def self.after_destroy(file)
    if File.exist?(file.filepath)
      File.delete(file.filepath)
    end
  end
end
```

Cuando el método de callback se declara de esta manera, no será necesario instanciar un nuevo objeto `FileDestroyerCallback` en nuestro modelo.

```ruby
class PictureFile < ApplicationRecord
  after_destroy FileDestroyerCallback
end
```

Puedes declarar tantos callbacks como desees dentro de tus clases de callback.

Callbacks de Transacción
---------------------

### Tratando con la Consistencia

Hay dos callbacks adicionales que se activan al completarse una transacción de base de datos: [`after_commit`][] y [`after_rollback`][]. Estos callbacks son muy similares al callback `after_save`, excepto que no se ejecutan hasta que los cambios en la base de datos se hayan confirmado o deshecho. Son muy útiles cuando tus modelos de Active Record necesitan interactuar con sistemas externos que no forman parte de la transacción de la base de datos.
Consideremos, por ejemplo, el ejemplo anterior donde el modelo `PictureFile` necesita eliminar un archivo después de que se destruye el registro correspondiente. Si algo genera una excepción después de que se llame al callback `after_destroy` y la transacción se revierte, el archivo habrá sido eliminado y el modelo quedará en un estado inconsistente. Por ejemplo, supongamos que `picture_file_2` en el siguiente código no es válido y el método `save!` genera un error.

```ruby
PictureFile.transaction do
  picture_file_1.destroy
  picture_file_2.save!
end
```

Al usar el callback `after_commit`, podemos tener en cuenta este caso.

```ruby
class PictureFile < ApplicationRecord
  after_commit :delete_picture_file_from_disk, on: :destroy

  def delete_picture_file_from_disk
    if File.exist?(filepath)
      File.delete(filepath)
    end
  end
end
```

NOTA: La opción `:on` especifica cuándo se ejecutará un callback. Si no proporcionas la opción `:on`, el callback se ejecutará para todas las acciones.

### El contexto importa

Dado que es común utilizar el callback `after_commit` solo en crear, actualizar o eliminar, existen alias para esas operaciones:

* [`after_create_commit`][]
* [`after_update_commit`][]
* [`after_destroy_commit`][]

```ruby
class PictureFile < ApplicationRecord
  after_destroy_commit :delete_picture_file_from_disk

  def delete_picture_file_from_disk
    if File.exist?(filepath)
      File.delete(filepath)
    end
  end
end
```

ADVERTENCIA. Cuando se completa una transacción, se llaman a los callbacks `after_commit` o `after_rollback` para todos los modelos creados, actualizados o eliminados dentro de esa transacción. Sin embargo, si se genera una excepción dentro de uno de estos callbacks, la excepción se propagará y no se ejecutarán los métodos `after_commit` o `after_rollback` restantes. Por lo tanto, si el código de tu callback podría generar una excepción, deberás capturarla y manejarla dentro del callback para permitir que se ejecuten otros callbacks.

ADVERTENCIA. El código ejecutado dentro de los callbacks `after_commit` o `after_rollback` en sí no está incluido dentro de una transacción.

ADVERTENCIA. El uso de `after_create_commit` y `after_update_commit` con el mismo nombre de método solo permitirá que el último callback definido tenga efecto, ya que ambos se alias internamente a `after_commit`, que anula los callbacks previamente definidos con el mismo nombre de método.

```ruby
class User < ApplicationRecord
  after_create_commit :log_user_saved_to_db
  after_update_commit :log_user_saved_to_db

  private
    def log_user_saved_to_db
      puts 'El usuario se guardó en la base de datos'
    end
end
```

```irb
irb> @user = User.create # no imprime nada

irb> @user.save # actualizando @user
El usuario se guardó en la base de datos
```

### `after_save_commit`

También existe [`after_save_commit`][], que es un alias para usar el callback `after_commit` tanto para crear como para actualizar juntos:

```ruby
class User < ApplicationRecord
  after_save_commit :log_user_saved_to_db

  private
    def log_user_saved_to_db
      puts 'El usuario se guardó en la base de datos'
    end
end
```

```irb
irb> @user = User.create # creando un usuario
El usuario se guardó en la base de datos

irb> @user.save # actualizando @user
El usuario se guardó en la base de datos
```

### Orden de los callbacks transaccionales

Cuando se definen múltiples callbacks transaccionales `after_` (`after_commit`, `after_rollback`, etc.), el orden se invertirá desde cuando se definen.

```ruby
class User < ActiveRecord::Base
  after_commit { puts("esto se llama en realidad segundo") }
  after_commit { puts("esto se llama en realidad primero") }
end
```

NOTA: Esto también se aplica a todas las variaciones de `after_*_commit`, como `after_destroy_commit`.
[`after_create`]: https://api.rubyonrails.org/classes/ActiveRecord/Callbacks/ClassMethods.html#method-i-after_create
[`after_commit`]: https://api.rubyonrails.org/classes/ActiveRecord/Transactions/ClassMethods.html#method-i-after_commit
[`after_rollback`]: https://api.rubyonrails.org/classes/ActiveRecord/Transactions/ClassMethods.html#method-i-after_rollback
[`after_save`]: https://api.rubyonrails.org/classes/ActiveRecord/Callbacks/ClassMethods.html#method-i-after_save
[`after_validation`]: https://api.rubyonrails.org/classes/ActiveModel/Validations/Callbacks/ClassMethods.html#method-i-after_validation
[`around_create`]: https://api.rubyonrails.org/classes/ActiveRecord/Callbacks/ClassMethods.html#method-i-around_create
[`around_save`]: https://api.rubyonrails.org/classes/ActiveRecord/Callbacks/ClassMethods.html#method-i-around_save
[`before_create`]: https://api.rubyonrails.org/classes/ActiveRecord/Callbacks/ClassMethods.html#method-i-before_create
[`before_save`]: https://api.rubyonrails.org/classes/ActiveRecord/Callbacks/ClassMethods.html#method-i-before_save
[`before_validation`]: https://api.rubyonrails.org/classes/ActiveModel/Validations/Callbacks/ClassMethods.html#method-i-before_validation
[`after_update`]: https://api.rubyonrails.org/classes/ActiveRecord/Callbacks/ClassMethods.html#method-i-after_update
[`around_update`]: https://api.rubyonrails.org/classes/ActiveRecord/Callbacks/ClassMethods.html#method-i-around_update
[`before_update`]: https://api.rubyonrails.org/classes/ActiveRecord/Callbacks/ClassMethods.html#method-i-before_update
[`after_destroy`]: https://api.rubyonrails.org/classes/ActiveRecord/Callbacks/ClassMethods.html#method-i-after_destroy
[`around_destroy`]: https://api.rubyonrails.org/classes/ActiveRecord/Callbacks/ClassMethods.html#method-i-around_destroy
[`before_destroy`]: https://api.rubyonrails.org/classes/ActiveRecord/Callbacks/ClassMethods.html#method-i-before_destroy
[`after_find`]: https://api.rubyonrails.org/classes/ActiveRecord/Callbacks/ClassMethods.html#method-i-after_find
[`after_initialize`]: https://api.rubyonrails.org/classes/ActiveRecord/Callbacks/ClassMethods.html#method-i-after_initialize
[`after_touch`]: https://api.rubyonrails.org/classes/ActiveRecord/Callbacks/ClassMethods.html#method-i-after_touch
[`after_create_commit`]: https://api.rubyonrails.org/classes/ActiveRecord/Transactions/ClassMethods.html#method-i-after_create_commit
[`after_destroy_commit`]: https://api.rubyonrails.org/classes/ActiveRecord/Transactions/ClassMethods.html#method-i-after_destroy_commit
[`after_save_commit`]: https://api.rubyonrails.org/classes/ActiveRecord/Transactions/ClassMethods.html#method-i-after_save_commit
[`after_update_commit`]: https://api.rubyonrails.org/classes/ActiveRecord/Transactions/ClassMethods.html#method-i-after_update_commit
