**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 37dd3507f05f7787a794868a2619e6d5
Validaciones de Active Record
==============================

Esta guía te enseña cómo validar el estado de los objetos antes de que se guarden en la base de datos utilizando la función de validaciones de Active Record.

Después de leer esta guía, sabrás:

* Cómo utilizar las funciones de validación incorporadas de Active Record.
* Cómo crear tus propios métodos de validación personalizados.
* Cómo trabajar con los mensajes de error generados por el proceso de validación.

--------------------------------------------------------------------------------

Resumen de las validaciones
---------------------------

Aquí tienes un ejemplo de una validación muy simple:

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

Como puedes ver, nuestra validación nos indica que nuestra `Person` no es válida sin un atributo `name`. La segunda `Person` no se guardará en la base de datos.

Antes de entrar en más detalles, hablemos de cómo encajan las validaciones en el panorama general de tu aplicación.

### ¿Por qué utilizar validaciones?

Las validaciones se utilizan para asegurarse de que solo se guarde en la base de datos datos válidos. Por ejemplo, puede ser importante para tu aplicación asegurarse de que cada usuario proporcione una dirección de correo electrónico y una dirección postal válidas. Las validaciones a nivel de modelo son la mejor manera de asegurarse de que solo se guarde en la base de datos datos válidos. Son independientes de la base de datos, no pueden ser evitadas por los usuarios finales y son convenientes de probar y mantener. Rails proporciona funciones incorporadas para necesidades comunes y te permite crear tus propios métodos de validación también.

Hay varias otras formas de validar datos antes de que se guarden en la base de datos, incluyendo restricciones nativas de la base de datos, validaciones en el lado del cliente y validaciones a nivel de controlador. Aquí tienes un resumen de las ventajas y desventajas:

* Las restricciones de la base de datos y/o los procedimientos almacenados hacen que los mecanismos de validación dependan de la base de datos y pueden dificultar las pruebas y el mantenimiento. Sin embargo, si tu base de datos es utilizada por otras aplicaciones, puede ser una buena idea utilizar algunas restricciones a nivel de base de datos. Además, las validaciones a nivel de base de datos pueden manejar de forma segura algunas cosas (como la unicidad en tablas muy utilizadas) que pueden ser difíciles de implementar de otra manera.
* Las validaciones en el lado del cliente pueden ser útiles, pero generalmente no son fiables si se utilizan solas. Si se implementan utilizando JavaScript, pueden ser evitadas si JavaScript está desactivado en el navegador del usuario. Sin embargo, si se combinan con otras técnicas, la validación en el lado del cliente puede ser una forma conveniente de proporcionar a los usuarios una retroalimentación inmediata mientras utilizan tu sitio.
* Las validaciones a nivel de controlador pueden ser tentadoras de utilizar, pero a menudo se vuelven difíciles de manejar y difíciles de probar y mantener. Siempre que sea posible, es una buena idea mantener tus controladores simples, ya que hará que tu aplicación sea un placer de trabajar a largo plazo.

Elige estas en casos específicos. Es la opinión del equipo de Rails que las validaciones a nivel de modelo son las más apropiadas en la mayoría de las circunstancias.

### ¿Cuándo ocurre la validación?

Hay dos tipos de objetos de Active Record: aquellos que corresponden a una fila dentro de tu base de datos y aquellos que no lo hacen. Cuando creas un objeto nuevo, por ejemplo utilizando el método `new`, ese objeto aún no pertenece a la base de datos. Una vez que llamas a `save` en ese objeto, se guardará en la tabla de la base de datos correspondiente. Active Record utiliza el método de instancia `new_record?` para determinar si un objeto ya está en la base de datos o no. Considera la siguiente clase de Active Record:

```ruby
class Person < ApplicationRecord
end
```

Podemos ver cómo funciona mirando la salida de `bin/rails console`:

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

Crear y guardar un nuevo registro enviará una operación SQL `INSERT` a la base de datos. Actualizar un registro existente enviará una operación SQL `UPDATE` en su lugar. Las validaciones se ejecutan típicamente antes de que se envíen estos comandos a la base de datos. Si alguna validación falla, el objeto se marcará como no válido y Active Record no realizará la operación `INSERT` o `UPDATE`. Esto evita almacenar un objeto no válido en la base de datos. Puedes elegir que se ejecuten validaciones específicas cuando se crea, guarda o actualiza un objeto.

PRECAUCIÓN: Hay muchas formas de cambiar el estado de un objeto en la base de datos. Algunos métodos activarán las validaciones, pero otros no. Esto significa que es posible guardar un objeto en la base de datos en un estado no válido si no tienes cuidado.
Los siguientes métodos activan las validaciones y guardarán el objeto en la base de datos solo si el objeto es válido:

* `create`
* `create!`
* `save`
* `save!`
* `update`
* `update!`

Las versiones con signo de exclamación (por ejemplo, `save!`) lanzan una excepción si el registro no es válido. Las versiones sin signo de exclamación no lo hacen: `save` y `update` devuelven `false`, y `create` devuelve el objeto.

### Omitir validaciones

Los siguientes métodos omiten las validaciones y guardarán el objeto en la base de datos sin importar su validez. Deben usarse con precaución.

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

Tenga en cuenta que `save` también tiene la capacidad de omitir las validaciones si se le pasa `validate: false` como argumento. Esta técnica debe usarse con precaución.

* `save(validate: false)`

### `valid?` e `invalid?`

Antes de guardar un objeto Active Record, Rails ejecuta las validaciones. Si estas validaciones producen algún error, Rails no guarda el objeto.

También puedes ejecutar estas validaciones por tu cuenta. [`valid?`][] activa tus validaciones y devuelve `true` si no se encontraron errores en el objeto, y `false` en caso contrario. Como viste anteriormente:

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

Después de que Active Record haya realizado las validaciones, cualquier error se puede acceder a través del método de instancia [`errors`][]. Este método devuelve una colección de errores. Por definición, un objeto es válido si esta colección está vacía después de ejecutar las validaciones.

Tenga en cuenta que un objeto instanciado con `new` no informará errores incluso si es técnicamente inválido, porque las validaciones se ejecutan automáticamente solo cuando se guarda el objeto, como con los métodos `create` o `save`.

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

[`invalid?`][] es el inverso de `valid?`. Activa tus validaciones y devuelve `true` si se encontraron errores en el objeto, y `false` en caso contrario.


### `errors[]`

Para verificar si un atributo particular de un objeto es válido o no, puedes usar [`errors[:atributo]`][Errors#squarebrackets]. Devuelve una matriz de todos los mensajes de error para `:atributo`. Si no hay errores en el atributo especificado, se devuelve una matriz vacía.

Este método solo es útil _después_ de que se hayan ejecutado las validaciones, porque solo inspecciona la colección de errores y no activa las validaciones en sí. Es diferente del método `ActiveRecord::Base#invalid?` explicado anteriormente porque no verifica la validez del objeto en su conjunto. Solo verifica si se encontraron errores en un atributo individual del objeto.

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

Trataremos los errores de validación con más detalle en la sección [Trabajando con errores de validación](#working-with-validation-errors).


Ayudantes de validación
------------------

Active Record ofrece muchos ayudantes de validación predefinidos que puedes usar directamente dentro de las definiciones de tus clases. Estos ayudantes proporcionan reglas de validación comunes. Cada vez que una validación falla, se agrega un error a la colección `errors` del objeto, y esto se asocia con el atributo que se está validando.

Cada ayudante acepta un número arbitrario de nombres de atributos, por lo que con una sola línea de código puedes agregar el mismo tipo de validación a varios atributos.

Todos ellos aceptan las opciones `:on` y `:message`, que definen cuándo se debe ejecutar la validación y qué mensaje se debe agregar a la colección `errors` si falla, respectivamente. La opción `:on` toma uno de los valores `:create` o `:update`. Hay un mensaje de error predeterminado para cada uno de los ayudantes de validación. Estos mensajes se utilizan cuando no se especifica la opción `:message`. Veamos cada uno de los ayudantes disponibles.

INFO: Para ver una lista de los ayudantes predeterminados disponibles, echa un vistazo a [`ActiveModel::Validations::HelperMethods`][].
### `aceptación`

Este método valida que se haya marcado una casilla de verificación en la interfaz de usuario cuando se envía un formulario. Esto se utiliza típicamente cuando el usuario necesita aceptar los términos de servicio de su aplicación, confirmar que se ha leído un texto o cualquier concepto similar.

```ruby
class Person < ApplicationRecord
  validates :terms_of_service, acceptance: true
end
```

Esta verificación se realiza solo si `terms_of_service` no es `nil`. El mensaje de error predeterminado para este ayudante es _"debe ser aceptado"_. También puede pasar un mensaje personalizado a través de la opción `message`.

```ruby
class Person < ApplicationRecord
  validates :terms_of_service, acceptance: { message: 'debe ser cumplido' }
end
```

También puede recibir una opción `:accept`, que determina los valores permitidos que se considerarán aceptables. Por defecto, es `['1', true]` y se puede cambiar fácilmente.

```ruby
class Person < ApplicationRecord
  validates :terms_of_service, acceptance: { accept: 'sí' }
  validates :eula, acceptance: { accept: ['VERDADERO', 'aceptado'] }
end
```

Esta validación es muy específica para aplicaciones web y esta 'aceptación' no necesita ser registrada en ninguna parte de su base de datos. Si no tiene un campo para ello, el ayudante creará un atributo virtual. Si el campo existe en su base de datos, la opción `accept` debe establecerse en o incluir `true`, de lo contrario, la validación no se ejecutará.

### `confirmación`

Debe utilizar este ayudante cuando tenga dos campos de texto que deben recibir exactamente el mismo contenido. Por ejemplo, es posible que desee confirmar una dirección de correo electrónico o una contraseña. Esta validación crea un atributo virtual cuyo nombre es el nombre del campo que debe confirmarse con "_confirmation" agregado.

```ruby
class Person < ApplicationRecord
  validates :email, confirmation: true
end
```

En su plantilla de vista, podría usar algo como esto:

```erb
<%= text_field :person, :email %>
<%= text_field :person, :email_confirmation %>
```

NOTA: Esta verificación se realiza solo si `email_confirmation` no es `nil`. Para requerir confirmación, asegúrese de agregar una verificación de presencia para el atributo de confirmación (veremos `presence` [más adelante](#presence) en esta guía):

```ruby
class Person < ApplicationRecord
  validates :email, confirmation: true
  validates :email_confirmation, presence: true
end
```

También hay una opción `:case_sensitive` que puede utilizar para definir si la restricción de confirmación será sensible a mayúsculas y minúsculas o no. Esta opción tiene un valor predeterminado de verdadero.

```ruby
class Person < ApplicationRecord
  validates :email, confirmation: { case_sensitive: false }
end
```

El mensaje de error predeterminado para este ayudante es _"no coincide con la confirmación"_. También puede pasar un mensaje personalizado a través de la opción `message`.

Generalmente, al usar este validador, querrá combinarlo con la opción `:if` para validar solo el campo "_confirmation" cuando el campo inicial haya cambiado y **no** cada vez que guarde el registro. Más sobre [validaciones condicionales](#conditional-validation) más adelante.

```ruby
class Person < ApplicationRecord
  validates :email, confirmation: true
  validates :email_confirmation, presence: true, if: :email_changed?
end
```

### `comparación`

Esta verificación validará una comparación entre dos valores comparables.

```ruby
class Promotion < ApplicationRecord
  validates :end_date, comparison: { greater_than: :start_date }
end
```

El mensaje de error predeterminado para este ayudante es _"comparación fallida"_. También puede pasar un mensaje personalizado a través de la opción `message`.

Estas opciones son compatibles:

* `:greater_than` - Especifica que el valor debe ser mayor que el valor suministrado. El mensaje de error predeterminado para esta opción es _"debe ser mayor que %{count}"_.
* `:greater_than_or_equal_to` - Especifica que el valor debe ser mayor o igual que el valor suministrado. El mensaje de error predeterminado para esta opción es _"debe ser mayor o igual que %{count}"_.
* `:equal_to` - Especifica que el valor debe ser igual al valor suministrado. El mensaje de error predeterminado para esta opción es _"debe ser igual a %{count}"_.
* `:less_than` - Especifica que el valor debe ser menor que el valor suministrado. El mensaje de error predeterminado para esta opción es _"debe ser menor que %{count}"_.
* `:less_than_or_equal_to` - Especifica que el valor debe ser menor o igual que el valor suministrado. El mensaje de error predeterminado para esta opción es _"debe ser menor o igual que %{count}"_.
* `:other_than` - Especifica que el valor debe ser distinto del valor suministrado. El mensaje de error predeterminado para esta opción es _"debe ser distinto de %{count}"_.

NOTA: El validador requiere que se suministre una opción de comparación. Cada opción acepta un valor, un proc o un símbolo. Cualquier clase que incluya Comparable se puede comparar.
### `formato`

Este ayudante valida los valores de los atributos probando si coinciden con una expresión regular dada, que se especifica utilizando la opción `:with`.

```ruby
class Product < ApplicationRecord
  validates :legacy_code, format: { with: /\A[a-zA-Z]+\z/,
    message: "solo permite letras" }
end
```

Inversamente, al usar la opción `:without` en su lugar, puedes requerir que el atributo especificado _no_ coincida con la expresión regular.

En ambos casos, la opción `:with` o `:without` proporcionada debe ser una expresión regular o un proc o lambda que devuelva una.

El mensaje de error predeterminado es _"no es válido"_.

ADVERTENCIA. usa `\A` y `\z` para coincidir con el inicio y el final de la cadena, `^` y `$` coinciden con el inicio / fin de una línea. Debido al uso frecuente incorrecto de `^` y `$`, debes pasar la opción `multiline: true` en caso de que uses cualquiera de estos dos anclajes en la expresión regular proporcionada. En la mayoría de los casos, deberías usar `\A` y `\z`.

### `inclusión`

Este ayudante valida que los valores de los atributos estén incluidos en un conjunto dado. De hecho, este conjunto puede ser cualquier objeto enumerable.

```ruby
class Coffee < ApplicationRecord
  validates :size, inclusion: { in: %w(small medium large),
    message: "%{value} no es un tamaño válido" }
end
```

El ayudante `inclusion` tiene una opción `:in` que recibe el conjunto de valores que se aceptarán. La opción `:in` tiene un alias llamado `:within` que puedes usar con el mismo propósito, si lo deseas. El ejemplo anterior usa la opción `:message` para mostrar cómo puedes incluir el valor del atributo. Para ver todas las opciones, consulta la documentación sobre [mensajes](#message).

El mensaje de error predeterminado para este ayudante es _"no está incluido en la lista"_.

### `exclusión`

¡Lo opuesto a `inclusión` es... `exclusión`!

Este ayudante valida que los valores de los atributos no estén incluidos en un conjunto dado. De hecho, este conjunto puede ser cualquier objeto enumerable.

```ruby
class Account < ApplicationRecord
  validates :subdomain, exclusion: { in: %w(www us ca jp),
    message: "%{value} está reservado." }
end
```

El ayudante `exclusion` tiene una opción `:in` que recibe el conjunto de valores que no se aceptarán para los atributos validados. La opción `:in` tiene un alias llamado `:within` que puedes usar con el mismo propósito, si lo deseas. Este ejemplo usa la opción `:message` para mostrar cómo puedes incluir el valor del atributo. Para ver todas las opciones del argumento del mensaje, consulta la documentación sobre [mensajes](#message).

El mensaje de error predeterminado es _"está reservado"_.

Alternativamente a un enumerable tradicional (como un Array), puedes proporcionar un proc, lambda o símbolo que devuelva un enumerable. Si el enumerable es un rango numérico, de tiempo o de fecha y hora, la prueba se realiza con `Range#cover?`, de lo contrario, se utiliza `include?`. Cuando se utiliza un proc o lambda, se pasa la instancia en validación como argumento.

### `longitud`

Este ayudante valida la longitud de los valores de los atributos. Proporciona una variedad de opciones para que puedas especificar restricciones de longitud de diferentes formas:

```ruby
class Person < ApplicationRecord
  validates :name, length: { minimum: 2 }
  validates :bio, length: { maximum: 500 }
  validates :password, length: { in: 6..20 }
  validates :registration_number, length: { is: 6 }
end
```

Las posibles opciones de restricción de longitud son:

* `:minimum` - El atributo no puede tener menos de la longitud especificada.
* `:maximum` - El atributo no puede tener más de la longitud especificada.
* `:in` (o `:within`) - La longitud del atributo debe estar incluida en un intervalo dado. El valor para esta opción debe ser un rango.
* `:is` - La longitud del atributo debe ser igual al valor dado.

Los mensajes de error predeterminados dependen del tipo de validación de longitud que se esté realizando. Puedes personalizar estos mensajes utilizando las opciones `:wrong_length`, `:too_long` y `:too_short`, y `%{count}` como marcador de posición para el número correspondiente a la restricción de longitud que se está utilizando. Aún puedes usar la opción `:message` para especificar un mensaje de error.

```ruby
class Person < ApplicationRecord
  validates :bio, length: { maximum: 1000,
    too_long: "%{count} caracteres es el máximo permitido" }
end
```

Ten en cuenta que los mensajes de error predeterminados están en plural (por ejemplo, "es demasiado corto (el mínimo es %{count} caracteres)"). Por esta razón, cuando `:minimum` es 1, debes proporcionar un mensaje personalizado o usar `presence: true` en su lugar. Cuando `:in` o `:within` tienen un límite inferior de 1, debes proporcionar un mensaje personalizado o llamar a `presence` antes de `length`.
NOTA: Solo se puede usar una opción de restricción a la vez, aparte de las opciones `:minimum` y `:maximum` que se pueden combinar juntas.

### `numericality`

Este ayudante valida que tus atributos tengan solo valores numéricos. Por defecto, coincidirá con un signo opcional seguido de un número entero o decimal.

Para especificar que solo se permiten números enteros, establece `:only_integer` en true. Luego usará la siguiente expresión regular para validar el valor del atributo.

```ruby
/\A[+-]?\d+\z/
```

De lo contrario, intentará convertir el valor a un número usando `Float`. Los `Float` se convierten a `BigDecimal` utilizando el valor de precisión de la columna o un máximo de 15 dígitos.

```ruby
class Player < ApplicationRecord
  validates :points, numericality: true
  validates :games_played, numericality: { only_integer: true }
end
```

El mensaje de error predeterminado para `:only_integer` es _"debe ser un número entero"_.

Además de `:only_integer`, este ayudante también acepta la opción `:only_numeric`, que especifica que el valor debe ser una instancia de `Numeric` e intenta analizar el valor si es una `String`.

NOTA: Por defecto, `numericality` no permite valores `nil`. Puedes usar la opción `allow_nil: true` para permitirlo. Ten en cuenta que para las columnas `Integer` y `Float`, las cadenas vacías se convierten en `nil`.

El mensaje de error predeterminado cuando no se especifican opciones es _"no es un número"_.

También hay muchas opciones que se pueden usar para agregar restricciones a los valores aceptables:

* `:greater_than` - Especifica que el valor debe ser mayor que el valor suministrado. El mensaje de error predeterminado para esta opción es _"debe ser mayor que %{count}"_.
* `:greater_than_or_equal_to` - Especifica que el valor debe ser mayor o igual que el valor suministrado. El mensaje de error predeterminado para esta opción es _"debe ser mayor o igual que %{count}"_.
* `:equal_to` - Especifica que el valor debe ser igual al valor suministrado. El mensaje de error predeterminado para esta opción es _"debe ser igual a %{count}"_.
* `:less_than` - Especifica que el valor debe ser menor que el valor suministrado. El mensaje de error predeterminado para esta opción es _"debe ser menor que %{count}"_.
* `:less_than_or_equal_to` - Especifica que el valor debe ser menor o igual que el valor suministrado. El mensaje de error predeterminado para esta opción es _"debe ser menor o igual que %{count}"_.
* `:other_than` - Especifica que el valor debe ser distinto del valor suministrado. El mensaje de error predeterminado para esta opción es _"debe ser distinto de %{count}"_.
* `:in` - Especifica que el valor debe estar dentro del rango suministrado. El mensaje de error predeterminado para esta opción es _"debe estar en %{count}"_.
* `:odd` - Especifica que el valor debe ser un número impar. El mensaje de error predeterminado para esta opción es _"debe ser impar"_.
* `:even` - Especifica que el valor debe ser un número par. El mensaje de error predeterminado para esta opción es _"debe ser par"_.

### `presence`

Este ayudante valida que los atributos especificados no estén vacíos. Utiliza el método [`Object#blank?`][] para verificar si el valor es `nil` o una cadena vacía, es decir, una cadena que está vacía o consiste solo de espacios en blanco.

```ruby
class Person < ApplicationRecord
  validates :name, :login, :email, presence: true
end
```

Si quieres asegurarte de que una asociación esté presente, debes probar si el objeto asociado en sí está presente, y no la clave externa utilizada para mapear la asociación. De esta manera, no solo se verifica que la clave externa no esté vacía, sino que también existe el objeto referenciado.

```ruby
class Supplier < ApplicationRecord
  has_one :account
  validates :account, presence: true
end
```

Para validar registros asociados cuya presencia es requerida, debes especificar la opción `:inverse_of` para la asociación:

```ruby
class Order < ApplicationRecord
  has_many :line_items, inverse_of: :order
end
```

NOTA: Si deseas asegurarte de que la asociación esté presente y sea válida, también debes usar `validates_associated`. Más información sobre eso [abajo](#validates-associated)

Si validas la presencia de un objeto asociado a través de una relación `has_one` o `has_many`, se verificará que el objeto no esté `blank?` ni `marked_for_destruction?`.

Dado que `false.blank?` es verdadero, si deseas validar la presencia de un campo booleano, debes usar una de las siguientes validaciones:

```ruby
# El valor _debe_ ser verdadero o falso
validates :nombre_campo_booleano, inclusion: [true, false]
# El valor _no debe_ ser nulo, es decir, verdadero o falso
validates :nombre_campo_booleano, exclusion: [nil]
```

Al utilizar una de estas validaciones, asegurará que el valor NO sea `nil`, lo que resultaría en un valor `NULL` en la mayoría de los casos.

El mensaje de error predeterminado es _"no puede estar en blanco"_.


### `absence`

Este ayudante valida que los atributos especificados estén ausentes. Utiliza el método [`Object#present?`][] para verificar si el valor no es ni `nil` ni una cadena en blanco, es decir, una cadena que esté vacía o consista solo en espacios en blanco.

```ruby
class Person < ApplicationRecord
  validates :name, :login, :email, absence: true
end
```

Si desea asegurarse de que una asociación esté ausente, deberá verificar si el objeto asociado en sí está ausente y no la clave externa utilizada para mapear la asociación.

```ruby
class LineItem < ApplicationRecord
  belongs_to :order
  validates :order, absence: true
end
```

Para validar registros asociados cuya ausencia es requerida, debe especificar la opción `:inverse_of` para la asociación:

```ruby
class Order < ApplicationRecord
  has_many :line_items, inverse_of: :order
end
```

NOTA: Si desea asegurarse de que la asociación esté presente y sea válida, también debe utilizar `validates_associated`. Más información sobre eso [a continuación](#validates-associated).

Si valida la ausencia de un objeto asociado a través de una relación `has_one` o `has_many`, se verificará que el objeto no esté `present?` ni `marked_for_destruction?`.

Dado que `false.present?` es falso, si desea validar la ausencia de un campo booleano, debe usar `validates :nombre_campo, exclusion: { in: [true, false] }`.

El mensaje de error predeterminado es _"debe estar en blanco"_.


### `uniqueness`

Este ayudante valida que el valor del atributo sea único justo antes de que se guarde el objeto.

```ruby
class Account < ApplicationRecord
  validates :email, uniqueness: true
end
```

La validación se realiza realizando una consulta SQL en la tabla del modelo, buscando un registro existente con el mismo valor en ese atributo.

Hay una opción `:scope` que puede usar para especificar uno o más atributos que se utilizan para limitar la verificación de unicidad:

```ruby
class Holiday < ApplicationRecord
  validates :name, uniqueness: { scope: :year,
    message: "debe ocurrir una vez al año" }
end
```

ADVERTENCIA. Esta validación no crea una restricción de unicidad en la base de datos, por lo que puede suceder que dos conexiones de base de datos diferentes creen dos registros con el mismo valor para una columna que se supone que debe ser única. Para evitar eso, debe crear un índice único en esa columna en su base de datos.

Para agregar una restricción de unicidad en la base de datos, use la declaración [`add_index`][] en una migración e incluya la opción `unique: true`.

Si desea crear una restricción de base de datos para evitar posibles violaciones de una validación de unicidad utilizando la opción `:scope`, debe crear un índice único en ambas columnas de su base de datos. Consulte [el manual de MySQL][] para obtener más detalles sobre índices de varias columnas o [el manual de PostgreSQL][] para ver ejemplos de restricciones únicas que se refieren a un grupo de columnas.

También hay una opción `:case_sensitive` que puede usar para definir si la restricción de unicidad será sensible a mayúsculas y minúsculas, insensible a mayúsculas y minúsculas o respetará la intercalación predeterminada de la base de datos. Esta opción tiene como valor predeterminado respetar la intercalación predeterminada de la base de datos.

```ruby
class Person < ApplicationRecord
  validates :name, uniqueness: { case_sensitive: false }
end
```

ADVERTENCIA. Tenga en cuenta que algunas bases de datos están configuradas para realizar búsquedas insensibles a mayúsculas y minúsculas de todos modos.

Hay una opción `:conditions` que puede especificar condiciones adicionales como un fragmento SQL `WHERE` para limitar la búsqueda de la restricción de unicidad (por ejemplo, `conditions: -> { where(status: 'active') }`).

El mensaje de error predeterminado es _"ya ha sido tomado"_.

Consulte [`validates_uniqueness_of`][] para obtener más información.

[el manual de MySQL]: https://dev.mysql.com/doc/refman/en/multiple-column-indexes.html
[el manual de PostgreSQL]: https://www.postgresql.org/docs/current/static/ddl-constraints.html

### `validates_associated`

Debe utilizar este ayudante cuando su modelo tenga asociaciones que siempre deben validarse. Cada vez que intente guardar su objeto, se llamará a `valid?` en cada uno de los objetos asociados.

```ruby
class Library < ApplicationRecord
  has_many :books
  validates_associated :books
end
```

Esta validación funcionará con todos los tipos de asociaciones.

PRECAUCIÓN: No utilice `validates_associated` en ambos extremos de sus asociaciones. Se llamarían entre sí en un bucle infinito.

El mensaje de error predeterminado para [`validates_associated`][] es _"no es válido"_. Tenga en cuenta que cada objeto asociado contendrá su propia colección de `errors`; los errores no se propagan al modelo que llama.

NOTA: [`validates_associated`][] solo se puede usar con objetos ActiveRecord, todo hasta ahora también se puede usar en cualquier objeto que incluya [`ActiveModel::Validations`][].
### `validates_each`

Este ayudante valida los atributos contra un bloque. No tiene una función de validación predefinida. Debe crear una usando un bloque, y cada atributo pasado a [`validates_each`][] se probará contra él.

En el siguiente ejemplo, rechazaremos nombres y apellidos que comiencen con minúsculas.

```ruby
class Person < ApplicationRecord
  validates_each :name, :surname do |record, attr, value|
    record.errors.add(attr, 'debe comenzar con mayúscula') if /\A[[:lower:]]/.match?(value)
  end
end
```

El bloque recibe el registro, el nombre del atributo y el valor del atributo.

Puede hacer cualquier cosa que desee para verificar datos válidos dentro del bloque. Si su validación falla, debe agregar un error al modelo, lo que lo hace inválido.


### `validates_with`

Este ayudante pasa el registro a una clase separada para su validación.

```ruby
class GoodnessValidator < ActiveModel::Validator
  def validate(record)
    if record.first_name == "Evil"
      record.errors.add :base, "Esta persona es malvada"
    end
  end
end

class Person < ApplicationRecord
  validates_with GoodnessValidator
end
```

No hay un mensaje de error predeterminado para `validates_with`. Debe agregar manualmente errores a la colección de errores del registro en la clase validadora.

NOTA: Los errores agregados a `record.errors[:base]` se relacionan con el estado del registro en su conjunto.

Para implementar el método de validación, debe aceptar un parámetro `record` en la definición del método, que es el registro que se va a validar.

Si desea agregar un error en un atributo específico, páselo como primer argumento, como `record.errors.add(:first_name, "por favor elija otro nombre")`. Cubriremos los [errores de validación][] con más detalle más adelante.

```ruby
def validate(record)
  if record.some_field != "aceptable"
    record.errors.add :some_field, "este campo no es aceptable"
  end
end
```

El ayudante [`validates_with`][] toma una clase o una lista de clases para usar en la validación.

```ruby
class Person < ApplicationRecord
  validates_with MyValidator, MyOtherValidator, on: :create
end
```

Al igual que todas las demás validaciones, `validates_with` toma las opciones `:if`, `:unless` y `:on`. Si pasa cualquier otra opción, las enviará a la clase validadora como `options`:

```ruby
class GoodnessValidator < ActiveModel::Validator
  def validate(record)
    if options[:fields].any? { |field| record.send(field) == "Evil" }
      record.errors.add :base, "Esta persona es malvada"
    end
  end
end

class Person < ApplicationRecord
  validates_with GoodnessValidator, fields: [:first_name, :last_name]
end
```

Tenga en cuenta que el validador se inicializará *solo una vez* durante todo el ciclo de vida de la aplicación, y no en cada ejecución de validación, así que tenga cuidado al usar variables de instancia dentro de él.

Si su validador es lo suficientemente complejo como para que desee variables de instancia, puede usar fácilmente un objeto Ruby normal en su lugar:

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
      @person.errors.add :base, "Esta persona es malvada"
    end
  end

  # ...
end
```

Cubriremos [validaciones personalizadas](#realizando-validaciones-personalizadas) más adelante.

[errores de validación](#trabajando-con-errores-de-validación)

Opciones comunes de validación
-------------------------

Hay varias opciones comunes admitidas por los validadores que acabamos de ver, ¡veamos algunas de ellas ahora!

NOTA: No todas estas opciones son compatibles con todos los validadores, consulte la documentación de la API de [`ActiveModel::Validations`][].

Al utilizar cualquiera de los métodos de validación que acabamos de mencionar, también hay una lista de opciones comunes compartidas junto con los validadores. ¡Vamos a cubrirlos ahora!

* [`:allow_nil`](#permitir-nil): Omitir la validación si el atributo es `nil`.
* [`:allow_blank`](#permitir-en-blanco): Omitir la validación si el atributo está en blanco.
* [`:message`](#mensaje): Especificar un mensaje de error personalizado.
* [`:on`](#en): Especificar los contextos en los que esta validación está activa.
* [`:strict`](#validaciones-estrictas): Lanzar una excepción cuando la validación falla.
* [`:if` y `:unless`](#validación-condicional): Especificar cuándo debe o no debe ocurrir la validación.


### `:allow_nil`

La opción `:allow_nil` omite la validación cuando el valor que se está validando es `nil`.

```ruby
class Coffee < ApplicationRecord
  validates :size, inclusion: { in: %w(small medium large),
    message: "%{value} no es un tamaño válido" }, allow_nil: true
end
```

```irb
irb> Coffee.create(size: nil).valid?
=> true
irb> Coffee.create(size: "mega").valid?
=> false
```

Para obtener opciones completas para el argumento de mensaje, consulte la
[documentación de mensajes](#mensaje).

### `:allow_blank`

La opción `:allow_blank` es similar a la opción `:allow_nil`. Esta opción permite que la validación pase si el valor del atributo está en blanco, como `nil` o una cadena vacía, por ejemplo.

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
Como ya has visto, la opción `:message` te permite especificar el mensaje que se agregará a la colección de `errors` cuando la validación falla. Cuando no se utiliza esta opción, Active Record utilizará el mensaje de error predeterminado correspondiente para cada ayudante de validación.

La opción `:message` acepta tanto un `String` como un `Proc` como valor.

Un valor `String` para `:message` puede contener opcionalmente cualquier combinación de `%{value}`, `%{attribute}` y `%{model}`, que se reemplazarán dinámicamente cuando la validación falle. Esta sustitución se realiza utilizando la gema i18n, y los marcadores de posición deben coincidir exactamente, no se permiten espacios.

```ruby
class Person < ApplicationRecord
  # Mensaje codificado
  validates :name, presence: { message: "debe ser proporcionado por favor" }

  # Mensaje con valor de atributo dinámico. %{value} será reemplazado
  # con el valor real del atributo. %{attribute} y %{model}
  # también están disponibles.
  validates :age, numericality: { message: "%{value} parece incorrecto" }
end
```

Un valor `Proc` para `:message` recibe dos argumentos: el objeto que se está validando y un hash con pares clave-valor `:model`, `:attribute` y `:value`.

```ruby
class Person < ApplicationRecord
  validates :username,
    uniqueness: {
      # object = objeto de persona que se está validando
      # data = { model: "Person", attribute: "Username", value: <username> }
      message: ->(object, data) do
        "Hola #{object.name}, #{data[:value]} ya está en uso."
      end
    }
end
```

### `:on`

La opción `:on` te permite especificar cuándo debe ocurrir la validación. El comportamiento predeterminado para todos los ayudantes de validación integrados es ejecutarse al guardar (tanto al crear un nuevo registro como al actualizarlo). Si quieres cambiarlo, puedes usar `on: :create` para ejecutar la validación solo cuando se crea un nuevo registro o `on: :update` para ejecutar la validación solo cuando se actualiza un registro.

```ruby
class Person < ApplicationRecord
  # será posible actualizar el correo electrónico con un valor duplicado
  validates :email, uniqueness: true, on: :create

  # será posible crear el registro con una edad no numérica
  validates :age, numericality: true, on: :update

  # el predeterminado (valida tanto en la creación como en la actualización)
  validates :name, presence: true
end
```

También puedes usar `on:` para definir contextos personalizados. Los contextos personalizados deben activarse explícitamente pasando el nombre del contexto a `valid?`, `invalid?` o `save`.

```ruby
class Person < ApplicationRecord
  validates :email, uniqueness: true, on: :account_setup
  validates :age, numericality: true, on: :account_setup
end
```

```irb
irb> person = Person.new(age: 'treinta y tres')
irb> person.valid?
=> true
irb> person.valid?(:account_setup)
=> false
irb> person.errors.messages
=> {:email=>["ya ha sido tomado"], :age=>["no es un número"]}
```

`person.valid?(:account_setup)` ejecuta ambas validaciones sin guardar el modelo. `person.save(context: :account_setup)` valida `person` en el contexto `account_setup` antes de guardar.

También se acepta pasar una matriz de símbolos.

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
=> {:title=>["no puede estar en blanco"]}
```

Cuando se activa mediante un contexto explícito, las validaciones se ejecutan para ese contexto, así como para cualquier validación _sin_ contexto.

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
=> {:email=>["ya ha sido tomado"], :age=>["no es un número"], :name=>["no puede estar en blanco"]}
```

Abordaremos más casos de uso para `on:` en la [guía de callbacks](active_record_callbacks.html).

Validaciones Estrictas
------------------

También puedes especificar validaciones estrictas que generen una excepción `ActiveModel::StrictValidationFailed` cuando el objeto no sea válido.

```ruby
class Person < ApplicationRecord
  validates :name, presence: { strict: true }
end
```

```irb
irb> Person.new.valid?
ActiveModel::StrictValidationFailed: El nombre no puede estar en blanco
```

También se puede pasar una excepción personalizada a la opción `:strict`.

```ruby
class Person < ApplicationRecord
  validates :token, presence: true, uniqueness: true, strict: TokenGenerationException
end
```

```irb
irb> Person.new.valid?
TokenGenerationException: El token no puede estar en blanco
```

Validación Condicional
----------------------

A veces tiene sentido validar un objeto solo cuando se cumple un predicado determinado. Puedes hacerlo utilizando las opciones `:if` y `:unless`, que pueden tomar un símbolo, un `Proc` o una matriz. Puedes usar la opción `:if` cuando quieras especificar cuándo **debe** ocurrir la validación. Alternativamente, si quieres especificar cuándo **no debe** ocurrir la validación, puedes usar la opción `:unless`.
### Uso de un símbolo con `:if` y `:unless`

Puede asociar las opciones `:if` y `:unless` con un símbolo correspondiente al nombre de un método que se llamará justo antes de que ocurra la validación. Esta es la opción más comúnmente utilizada.

```ruby
class Order < ApplicationRecord
  validates :card_number, presence: true, if: :paid_with_card?

  def paid_with_card?
    payment_type == "card"
  end
end
```

### Uso de un Proc con `:if` y `:unless`

Es posible asociar `:if` y `:unless` con un objeto `Proc` que se llamará. El uso de un objeto `Proc` le brinda la capacidad de escribir una condición en línea en lugar de un método separado. Esta opción es más adecuada para una sola línea.

```ruby
class Account < ApplicationRecord
  validates :password, confirmation: true,
    unless: Proc.new { |a| a.password.blank? }
end
```

Como `lambda` es un tipo de `Proc`, también se puede usar para escribir condiciones en línea aprovechando la sintaxis abreviada.

```ruby
validates :password, confirmation: true, unless: -> { password.blank? }
```

### Agrupación de validaciones condicionales

A veces es útil que varias validaciones utilicen una misma condición. Esto se puede lograr fácilmente utilizando [`with_options`][].

```ruby
class User < ApplicationRecord
  with_options if: :is_admin? do |admin|
    admin.validates :password, length: { minimum: 10 }
    admin.validates :email, presence: true
  end
end
```

Todas las validaciones dentro del bloque `with_options` habrán pasado automáticamente la condición `if: :is_admin?`


### Combinación de condiciones de validación

Por otro lado, cuando varias condiciones definen si una validación debe ocurrir o no, se puede usar un `Array`. Además, se pueden aplicar tanto `:if` como `:unless` a la misma validación.

```ruby
class Computer < ApplicationRecord
  validates :mouse, presence: true,
                    if: [Proc.new { |c| c.market.retail? }, :desktop?],
                    unless: Proc.new { |c| c.trackpad.present? }
end
```

La validación solo se ejecuta cuando todas las condiciones `:if` y ninguna de las condiciones `:unless` se evalúan como `true`.

Realización de validaciones personalizadas
-----------------------------

Cuando los ayudantes de validación incorporados no son suficientes para sus necesidades, puede escribir sus propios validadores o métodos de validación según lo prefiera.

### Validadores personalizados

Los validadores personalizados son clases que heredan de [`ActiveModel::Validator`][]. Estas clases deben implementar el método `validate` que toma un registro como argumento y realiza la validación en él. El validador personalizado se llama utilizando el método `validates_with`.

```ruby
class MyValidator < ActiveModel::Validator
  def validate(record)
    unless record.name.start_with? 'X'
      record.errors.add :name, "¡Proporcione un nombre que comience con X, por favor!"
    end
  end
end

class Person < ApplicationRecord
  validates_with MyValidator
end
```

La forma más sencilla de agregar validadores personalizados para validar atributos individuales es con el conveniente [`ActiveModel::EachValidator`][]. En este caso, la clase de validador personalizado debe implementar un método `validate_each` que toma tres argumentos: registro, atributo y valor. Estos corresponden a la instancia, el atributo que se va a validar y el valor del atributo en la instancia pasada.

```ruby
class EmailValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    unless URI::MailTo::EMAIL_REGEXP.match?(value)
      record.errors.add attribute, (options[:message] || "no es un correo electrónico")
    end
  end
end

class Person < ApplicationRecord
  validates :email, presence: true, email: true
end
```

Como se muestra en el ejemplo, también puede combinar validaciones estándar con sus propios validadores personalizados.


### Métodos personalizados

También puede crear métodos que verifiquen el estado de sus modelos y agreguen errores a la colección de `errors` cuando no sean válidos. Luego debe registrar estos métodos utilizando el método de clase [`validate`][], pasando los símbolos de los nombres de los métodos de validación.

Puede pasar más de un símbolo para cada método de clase y las respectivas validaciones se ejecutarán en el mismo orden en que se registraron.

El método `valid?` verificará que la colección de `errors` esté vacía, por lo que sus métodos de validación personalizados deben agregar errores a ella cuando desee que la validación falle:

```ruby
class Invoice < ApplicationRecord
  validate :expiration_date_cannot_be_in_the_past,
    :discount_cannot_be_greater_than_total_value

  def expiration_date_cannot_be_in_the_past
    if expiration_date.present? && expiration_date < Date.today
      errors.add(:expiration_date, "no puede estar en el pasado")
    end
  end

  def discount_cannot_be_greater_than_total_value
    if discount > total_value
      errors.add(:discount, "no puede ser mayor que el valor total")
    end
  end
end
```

De forma predeterminada, estas validaciones se ejecutarán cada vez que llame a `valid?` o guarde el objeto. Pero también es posible controlar cuándo ejecutar estas validaciones personalizadas mediante la opción `:on` del método `validate`, con `:create` o `:update`.

```ruby
class Invoice < ApplicationRecord
  validate :active_customer, on: :create

  def active_customer
    errors.add(:customer_id, "no está activo") unless customer.active?
  end
end
```
Consulte la sección anterior para obtener más detalles sobre [`:on`](#on).

### Listado de validadores

Si desea conocer todos los validadores para un objeto dado, no busque más allá de `validators`.

Por ejemplo, si tenemos el siguiente modelo que utiliza un validador personalizado y un validador incorporado:

```ruby
class Person < ApplicationRecord
  validates :name, presence: true, on: :create
  validates :email, format: URI::MailTo::EMAIL_REGEXP
  validates_with MyOtherValidator, strict: true
end
```

Ahora podemos usar `validators` en el modelo "Person" para listar todos los validadores, o incluso verificar un campo específico usando `validators_on`.

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


Trabajando con errores de validación
------------------------------

Los métodos [`valid?`][] e [`invalid?`][] solo proporcionan un resumen del estado de validez. Sin embargo, puede profundizar en cada error individual utilizando varios métodos de la colección [`errors`][].

A continuación se muestra una lista de los métodos más utilizados. Consulte la documentación de [`ActiveModel::Errors`][] para obtener una lista de todos los métodos disponibles.


### `errors`

La puerta de entrada a través de la cual puede profundizar en varios detalles de cada error.

Esto devuelve una instancia de la clase `ActiveModel::Errors` que contiene todos los errores, cada error está representado por un objeto [`ActiveModel::Error`][].

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
=> ["El nombre no puede estar en blanco", "El nombre es demasiado corto (mínimo 3 caracteres)"]

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

[`errors[]`][Errors#squarebrackets] se utiliza cuando se desea verificar los mensajes de error para un atributo específico. Devuelve una matriz de cadenas con todos los mensajes de error para el atributo dado, cada cadena con un mensaje de error. Si no hay errores relacionados con el atributo, devuelve una matriz vacía.

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
=> ["es demasiado corto (mínimo 3 caracteres)"]

irb> person = Person.new
irb> person.valid?
=> false
irb> person.errors[:name]
=> ["no puede estar en blanco", "es demasiado corto (mínimo 3 caracteres)"]
```

### `errors.where` y objeto de error

A veces, es posible que necesitemos más información sobre cada error además de su mensaje. Cada error se encapsula como un objeto `ActiveModel::Error`, y el método [`where`][] es la forma más común de acceder.

`where` devuelve una matriz de objetos de error filtrados por diversos grados de condiciones.

```ruby
class Person < ApplicationRecord
  validates :name, presence: true, length: { minimum: 3 }
end
```

Podemos filtrar solo por el `atributo` pasándolo como el primer parámetro a `errors.where(:attr)`. El segundo parámetro se utiliza para filtrar el `tipo` de error que queremos llamando a `errors.where(:attr, :type)`.

```irb
irb> person = Person.new
irb> person.valid?
=> false

irb> person.errors.where(:name)
=> [ ... ] # todos los errores para el atributo :name

irb> person.errors.where(:name, :too_short)
=> [ ... ] # errores :too_short para el atributo :name
```

Por último, podemos filtrar por cualquier `opción` que pueda existir en el tipo de objeto de error dado.

```irb
irb> person = Person.new
irb> person.valid?
=> false

irb> person.errors.where(:name, :too_short, minimum: 3)
=> [ ... ] # todos los errores de nombre que son demasiado cortos y el mínimo es 2
```

Puede leer varias informaciones de estos objetos de error:

```irb
irb> error = person.errors.where(:name).last

irb> error.attribute
=> :name
irb> error.type
=> :too_short
irb> error.options[:count]
=> 3
```

También puede generar el mensaje de error:

```irb
irb> error.message
=> "es demasiado corto (mínimo 3 caracteres)"
irb> error.full_message
=> "El nombre es demasiado corto (mínimo 3 caracteres)"
```

El método [`full_message`][] genera un mensaje más amigable para el usuario, con el nombre del atributo en mayúscula antepuesto. (Para personalizar el formato que utiliza `full_message`, consulte la [guía de I18n](i18n.html#active-model-methods).)


### `errors.add`

El método [`add`][] crea el objeto de error tomando el `atributo`, el `tipo` de error y un hash adicional de opciones. Esto es útil cuando se escribe su propio validador, ya que le permite definir situaciones de error muy específicas.

```ruby
class Person < ApplicationRecord
  validate do |person|
    errors.add :name, :too_plain, message: "no es lo suficientemente genial"
  end
end
```
```irb
irb> person = Person.create
irb> person.errors.where(:name).first.type
=> :too_plain
irb> person.errors.where(:name).first.full_message
=> "El nombre no es lo suficientemente cool"
```


### `errors[:base]`

Puedes agregar errores que estén relacionados con el estado del objeto en su totalidad, en lugar de estar relacionados con un atributo específico. Para hacer esto, debes usar `:base` como el atributo al agregar un nuevo error.

```ruby
class Person < ApplicationRecord
  validate do |person|
    errors.add :base, :invalid, message: "Esta persona es inválida porque ..."
  end
end
```

```irb
irb> person = Person.create
irb> person.errors.where(:base).first.full_message
=> "Esta persona es inválida porque ..."
```

### `errors.size`

El método `size` devuelve el número total de errores para el objeto.

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

El método `clear` se utiliza cuando quieres borrar intencionalmente la colección de `errors`. Por supuesto, llamar a `errors.clear` en un objeto inválido no lo hará válido: la colección de `errors` ahora estará vacía, pero la próxima vez que llames a `valid?` o cualquier método que intente guardar este objeto en la base de datos, las validaciones se ejecutarán nuevamente. Si alguna de las validaciones falla, la colección de `errors` se llenará nuevamente.

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

Mostrar errores de validación en las vistas
-------------------------------------------

Una vez que hayas creado un modelo y agregado validaciones, si ese modelo se crea a través de un formulario web, probablemente quieras mostrar un mensaje de error cuando una de las validaciones falle.

Debido a que cada aplicación maneja este tipo de cosas de manera diferente, Rails no incluye ningún helper de vista para ayudarte a generar estos mensajes directamente. Sin embargo, debido a la gran cantidad de métodos que Rails te proporciona para interactuar con las validaciones en general, puedes construir los tuyos propios. Además, al generar un scaffold, Rails colocará algo de ERB en el `_form.html.erb` que genera y que muestra la lista completa de errores en ese modelo.

Suponiendo que tenemos un modelo que se ha guardado en una variable de instancia llamada `@article`, se vería así:

```html+erb
<% if @article.errors.any? %>
  <div id="error_explanation">
    <h2><%= pluralize(@article.errors.count, "error") %> impidieron que se guardara este artículo:</h2>

    <ul>
      <% @article.errors.each do |error| %>
        <li><%= error.full_message %></li>
      <% end %>
    </ul>
  </div>
<% end %>
```

Además, si utilizas los helpers de formulario de Rails para generar tus formularios, cuando ocurre un error de validación en un campo, generará un `<div>` adicional alrededor de la entrada.

```html
<div class="field_with_errors">
  <input id="article_title" name="article[title]" size="30" type="text" value="">
</div>
```

Luego puedes dar estilo a este div como desees. El scaffold predeterminado que genera Rails, por ejemplo, agrega esta regla CSS:

```css
.field_with_errors {
  padding: 2px;
  background-color: red;
  display: table;
}
```

Esto significa que cualquier campo con un error termina con un borde rojo de 2 píxeles.
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
