**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: fdd2e5c41171c61b555549ced4d68a82
Extensiones principales de Active Support
===========================================

Active Support es el componente de Ruby on Rails responsable de proporcionar extensiones y utilidades al lenguaje Ruby.

Ofrece una base más sólida a nivel de lenguaje, dirigida tanto al desarrollo de aplicaciones Rails como al desarrollo de Ruby on Rails en sí.

Después de leer esta guía, sabrás:

* Qué son las Extensiones Principales.
* Cómo cargar todas las extensiones.
* Cómo seleccionar solo las extensiones que deseas.
* Qué extensiones proporciona Active Support.

--------------------------------------------------------------------------------

Cómo cargar las Extensiones Principales
--------------------------------------

### Active Support independiente

Con el fin de tener la menor huella predeterminada posible, Active Support carga las dependencias mínimas de forma predeterminada. Está dividido en pequeñas piezas para que solo se carguen las extensiones deseadas. También tiene algunos puntos de entrada convenientes para cargar extensiones relacionadas de una sola vez, incluso todo.

Así, después de un simple require como este:

```ruby
require "active_support"
```

solo se cargan las extensiones requeridas por el framework Active Support.

#### Seleccionar una definición

Este ejemplo muestra cómo cargar [`Hash#with_indifferent_access`][Hash#with_indifferent_access]. Esta extensión permite la conversión de un `Hash` en un [`ActiveSupport::HashWithIndifferentAccess`][ActiveSupport::HashWithIndifferentAccess] que permite acceder a las claves tanto como cadenas o símbolos.

```ruby
{ a: 1 }.with_indifferent_access["a"] # => 1
```

Para cada método definido como una extensión principal, esta guía tiene una nota que indica dónde se define dicho método. En el caso de `with_indifferent_access`, la nota dice:

NOTA: Definido en `active_support/core_ext/hash/indifferent_access.rb`.

Eso significa que puedes requerirlo de esta manera:

```ruby
require "active_support"
require "active_support/core_ext/hash/indifferent_access"
```

Active Support ha sido cuidadosamente revisado para que al seleccionar un archivo solo se carguen las dependencias estrictamente necesarias, si las hay.

#### Cargar extensiones principales agrupadas

El siguiente nivel es simplemente cargar todas las extensiones de `Hash`. Como regla general, las extensiones de `SomeClass` están disponibles de una sola vez cargando `active_support/core_ext/some_class`.

Así, para cargar todas las extensiones de `Hash` (incluyendo `with_indifferent_access`):

```ruby
require "active_support"
require "active_support/core_ext/hash"
```

#### Cargar todas las extensiones principales

Tal vez prefieras simplemente cargar todas las extensiones principales, hay un archivo para eso:

```ruby
require "active_support"
require "active_support/core_ext"
```

#### Cargar todo Active Support

Y finalmente, si quieres tener todo Active Support disponible, simplemente ejecuta:

```ruby
require "active_support/all"
```

Esto ni siquiera carga todo Active Support en memoria de antemano, de hecho, algunas cosas están configuradas a través de `autoload`, por lo que solo se cargan si se utilizan.

### Active Support dentro de una aplicación Ruby on Rails

Una aplicación Ruby on Rails carga todo Active Support a menos que [`config.active_support.bare`][] sea verdadero. En ese caso, la aplicación solo cargará lo que el propio framework selecciona para sus propias necesidades, y aún puede seleccionar a cualquier nivel de granularidad, como se explica en la sección anterior.


Extensiones para todos los objetos
----------------------------------

### `blank?` y `present?`

Los siguientes valores se consideran en blanco en una aplicación Rails:

* `nil` y `false`,

* cadenas compuestas solo de espacios en blanco (ver nota a continuación),

* matrices y hashes vacíos, y

* cualquier otro objeto que responda a `empty?` y esté vacío.

INFO: El predicado para las cadenas utiliza la clase de caracteres con conocimiento de Unicode `[:space:]`, por lo que, por ejemplo, U+2029 (separador de párrafo) se considera espacio en blanco.

ADVERTENCIA: Ten en cuenta que los números no se mencionan. En particular, 0 y 0.0 **no** están en blanco.

Por ejemplo, este método de `ActionController::HttpAuthentication::Token::ControllerMethods` utiliza [`blank?`][Object#blank?] para verificar si un token está presente:

```ruby
def authenticate(controller, &login_procedure)
  token, options = token_and_options(controller.request)
  unless token.blank?
    login_procedure.call(token, options)
  end
end
```

El método [`present?`][Object#present?] es equivalente a `!blank?`. Este ejemplo se toma de `ActionDispatch::Http::Cache::Response`:

```ruby
def set_conditional_cache_control!
  return if self["Cache-Control"].present?
  # ...
end
```

NOTA: Definido en `active_support/core_ext/object/blank.rb`.


### `presence`

El método [`presence`][Object#presence] devuelve su receptor si `present?`, y `nil` en caso contrario. Es útil para idiomatismos como este:
```ruby
host = config[:host].presence || 'localhost'
```

NOTA: Definido en `active_support/core_ext/object/blank.rb`.


### `duplicable?`

A partir de Ruby 2.5, la mayoría de los objetos se pueden duplicar mediante `dup` o `clone`:

```ruby
"foo".dup           # => "foo"
"".dup              # => ""
Rational(1).dup     # => (1/1)
Complex(0).dup      # => (0+0i)
1.method(:+).dup    # => TypeError (allocator undefined for Method)
```

Active Support proporciona [`duplicable?`][Object#duplicable?] para consultar a un objeto sobre esto:

```ruby
"foo".duplicable?           # => true
"".duplicable?              # => true
Rational(1).duplicable?     # => true
Complex(1).duplicable?      # => true
1.method(:+).duplicable?    # => false
```

ADVERTENCIA: Cualquier clase puede evitar la duplicación eliminando `dup` y `clone` o lanzando excepciones desde ellos. Por lo tanto, solo `rescue` puede decir si un objeto arbitrario dado es duplicable. `duplicable?` depende de la lista codificada anteriormente, pero es mucho más rápido que `rescue`. Úsalo solo si sabes que la lista codificada es suficiente en tu caso de uso.

NOTA: Definido en `active_support/core_ext/object/duplicable.rb`.


### `deep_dup`

El método [`deep_dup`][Object#deep_dup] devuelve una copia profunda de un objeto dado. Normalmente, cuando haces `dup` de un objeto que contiene otros objetos, Ruby no los duplica, por lo que crea una copia superficial del objeto. Si tienes un array con un string, por ejemplo, se verá así:

```ruby
array     = ['string']
duplicate = array.dup

duplicate.push 'another-string'

# el objeto fue duplicado, por lo que el elemento se agregó solo a la copia
array     # => ['string']
duplicate # => ['string', 'another-string']

duplicate.first.gsub!('string', 'foo')

# el primer elemento no fue duplicado, se cambiará en ambos arrays
array     # => ['foo']
duplicate # => ['foo', 'another-string']
```

Como puedes ver, después de duplicar la instancia de `Array`, obtuvimos otro objeto, por lo tanto, podemos modificarlo y el objeto original permanecerá sin cambios. Sin embargo, esto no es cierto para los elementos del array. Dado que `dup` no hace una copia profunda, el string dentro del array sigue siendo el mismo objeto.

Si necesitas una copia profunda de un objeto, debes usar `deep_dup`. Aquí tienes un ejemplo:

```ruby
array     = ['string']
duplicate = array.deep_dup

duplicate.first.gsub!('string', 'foo')

array     # => ['string']
duplicate # => ['foo']
```

Si el objeto no se puede duplicar, `deep_dup` simplemente lo devuelve:

```ruby
number = 1
duplicate = number.deep_dup
number.object_id == duplicate.object_id   # => true
```

NOTA: Definido en `active_support/core_ext/object/deep_dup.rb`.


### `try`

Cuando quieres llamar a un método en un objeto solo si no es `nil`, la forma más sencilla de lograrlo es con declaraciones condicionales, agregando un desorden innecesario. La alternativa es usar [`try`][Object#try]. `try` es como `Object#public_send`, excepto que devuelve `nil` si se envía a `nil`.

Aquí tienes un ejemplo:

```ruby
# sin try
unless @number.nil?
  @number.next
end

# con try
@number.try(:next)
```

Otro ejemplo es este código de `ActiveRecord::ConnectionAdapters::AbstractAdapter` donde `@logger` podría ser `nil`. Puedes ver que el código usa `try` y evita una verificación innecesaria.

```ruby
def log_info(sql, name, ms)
  if @logger.try(:debug?)
    name = '%s (%.1fms)' % [name || 'SQL', ms]
    @logger.debug(format_log_entry(name, sql.squeeze(' ')))
  end
end
```

`try` también se puede llamar sin argumentos pero con un bloque, que solo se ejecutará si el objeto no es nulo:

```ruby
@person.try { |p| "#{p.first_name} #{p.last_name}" }
```

Ten en cuenta que `try` ignorará los errores de no método, devolviendo nil en su lugar. Si quieres protegerte contra errores tipográficos, usa [`try!`][Object#try!] en su lugar:

```ruby
@number.try(:nest)  # => nil
@number.try!(:nest) # NoMethodError: undefined method `nest' for 1:Integer
```

NOTA: Definido en `active_support/core_ext/object/try.rb`.


### `class_eval(*args, &block)`

Puedes evaluar código en el contexto de la clase singleton de cualquier objeto usando [`class_eval`][Kernel#class_eval]:

```ruby
class Proc
  def bind(object)
    block, time = self, Time.current
    object.class_eval do
      method_name = "__bind_#{time.to_i}_#{time.usec}"
      define_method(method_name, &block)
      method = instance_method(method_name)
      remove_method(method_name)
      method
    end.bind(object)
  end
end
```

NOTA: Definido en `active_support/core_ext/kernel/singleton_class.rb`.


### `acts_like?(duck)`

El método [`acts_like?`][Object#acts_like?] proporciona una forma de verificar si una clase se comporta como otra clase según una convención simple: una clase que proporciona la misma interfaz que `String` define
```ruby
def acts_like_string?
end
```

que solo es un marcador, su cuerpo o valor de retorno son irrelevantes. Luego, el código del cliente puede consultar si se comporta como un pato de tipo de cadena de esta manera:

```ruby
some_klass.acts_like?(:string)
```

Rails tiene clases que se comportan como `Date` o `Time` y siguen este contrato.

NOTA: Definido en `active_support/core_ext/object/acts_like.rb`.


### `to_param`

Todos los objetos en Rails responden al método [`to_param`][Object#to_param], que se supone que devuelve algo que los representa como valores en una cadena de consulta o como fragmentos de URL.

Por defecto, `to_param` simplemente llama a `to_s`:

```ruby
7.to_param # => "7"
```

El valor de retorno de `to_param` no debe ser escapado:

```ruby
"Tom & Jerry".to_param # => "Tom & Jerry"
```

Varias clases en Rails sobrescriben este método.

Por ejemplo, `nil`, `true` y `false` devuelven ellos mismos. [`Array#to_param`][Array#to_param] llama a `to_param` en los elementos y une el resultado con "/":

```ruby
[0, true, String].to_param # => "0/true/String"
```

Es importante destacar que el sistema de enrutamiento de Rails llama a `to_param` en los modelos para obtener un valor para el marcador `:id`. `ActiveRecord::Base#to_param` devuelve el `id` de un modelo, pero puedes redefinir ese método en tus modelos. Por ejemplo, dado

```ruby
class User
  def to_param
    "#{id}-#{name.parameterize}"
  end
end
```

obtenemos:

```ruby
user_path(@user) # => "/users/357-john-smith"
```

ADVERTENCIA. Los controladores deben ser conscientes de cualquier redefinición de `to_param` porque cuando llega una solicitud como esa, "357-john-smith" es el valor de `params[:id]`.

NOTA: Definido en `active_support/core_ext/object/to_param.rb`.


### `to_query`

El método [`to_query`][Object#to_query] construye una cadena de consulta que asocia una clave dada con el valor de retorno de `to_param`. Por ejemplo, con la siguiente definición de `to_param`:

```ruby
class User
  def to_param
    "#{id}-#{name.parameterize}"
  end
end
```

obtenemos:

```ruby
current_user.to_query('user') # => "user=357-john-smith"
```

Este método escapa lo que sea necesario, tanto para la clave como para el valor:

```ruby
account.to_query('company[name]')
# => "company%5Bname%5D=Johnson+%26+Johnson"
```

por lo que su salida está lista para ser utilizada en una cadena de consulta.

Los arrays devuelven el resultado de aplicar `to_query` a cada elemento con `key[]` como clave, y unen el resultado con "&":

```ruby
[3.4, -45.6].to_query('sample')
# => "sample%5B%5D=3.4&sample%5B%5D=-45.6"
```

Los hashes también responden a `to_query` pero con una firma diferente. Si no se pasa ningún argumento, una llamada genera una serie ordenada de asignaciones clave/valor llamando a `to_query(key)` en sus valores. Luego une el resultado con "&":

```ruby
{ c: 3, b: 2, a: 1 }.to_query # => "a=1&b=2&c=3"
```

El método [`Hash#to_query`][Hash#to_query] acepta un espacio de nombres opcional para las claves:

```ruby
{ id: 89, name: "John Smith" }.to_query('user')
# => "user%5Bid%5D=89&user%5Bname%5D=John+Smith"
```

NOTA: Definido en `active_support/core_ext/object/to_query.rb`.


### `with_options`

El método [`with_options`][Object#with_options] proporciona una forma de factorizar opciones comunes en una serie de llamadas a métodos.

Dado un hash de opciones predeterminado, `with_options` cede un objeto proxy a un bloque. Dentro del bloque, los métodos llamados en el proxy se reenvían al receptor con sus opciones fusionadas. Por ejemplo, te deshaces de la duplicación en:

```ruby
class Account < ApplicationRecord
  has_many :customers, dependent: :destroy
  has_many :products,  dependent: :destroy
  has_many :invoices,  dependent: :destroy
  has_many :expenses,  dependent: :destroy
end
```

de esta manera:

```ruby
class Account < ApplicationRecord
  with_options dependent: :destroy do |assoc|
    assoc.has_many :customers
    assoc.has_many :products
    assoc.has_many :invoices
    assoc.has_many :expenses
  end
end
```

Ese idioma también puede transmitir _agrupamiento_ al lector. Por ejemplo, digamos que quieres enviar un boletín cuyo idioma depende del usuario. En algún lugar del mailer podrías agrupar las partes dependientes del idioma de esta manera:

```ruby
I18n.with_options locale: user.locale, scope: "newsletter" do |i18n|
  subject i18n.t :subject
  body    i18n.t :body, user_name: user.name
end
```

CONSEJO: Dado que `with_options` reenvía las llamadas a su receptor, se pueden anidar. Cada nivel de anidamiento fusionará los valores predeterminados heredados además de los propios.

NOTA: Definido en `active_support/core_ext/object/with_options.rb`.


### Soporte JSON

Active Support proporciona una mejor implementación de `to_json` que la que el gem `json` proporciona normalmente para los objetos de Ruby. Esto se debe a que algunas clases, como `Hash` y `Process::Status`, necesitan un manejo especial para proporcionar una representación JSON adecuada.
NOTA: Definido en `active_support/core_ext/object/json.rb`.

### Variables de instancia

Active Support proporciona varios métodos para facilitar el acceso a las variables de instancia.

#### `instance_values`

El método [`instance_values`][Object#instance_values] devuelve un hash que mapea los nombres de las variables de instancia sin "@" a sus valores correspondientes. Las claves son cadenas de texto:

```ruby
class C
  def initialize(x, y)
    @x, @y = x, y
  end
end

C.new(0, 1).instance_values # => {"x" => 0, "y" => 1}
```

NOTA: Definido en `active_support/core_ext/object/instance_variables.rb`.


#### `instance_variable_names`

El método [`instance_variable_names`][Object#instance_variable_names] devuelve un array. Cada nombre incluye el signo "@".

```ruby
class C
  def initialize(x, y)
    @x, @y = x, y
  end
end

C.new(0, 1).instance_variable_names # => ["@x", "@y"]
```

NOTA: Definido en `active_support/core_ext/object/instance_variables.rb`.


### Silenciar advertencias y excepciones

Los métodos [`silence_warnings`][Kernel#silence_warnings] y [`enable_warnings`][Kernel#enable_warnings] cambian el valor de `$VERBOSE` de acuerdo con la duración de su bloque, y lo restablecen después:

```ruby
silence_warnings { Object.const_set "RAILS_DEFAULT_LOGGER", logger }
```

También es posible silenciar excepciones con [`suppress`][Kernel#suppress]. Este método recibe un número arbitrario de clases de excepción. Si se produce una excepción durante la ejecución del bloque y es `kind_of?` cualquiera de los argumentos, `suppress` la captura y la devuelve en silencio. De lo contrario, la excepción no se captura:

```ruby
# Si el usuario está bloqueado, el incremento se pierde, no es gran cosa.
suppress(ActiveRecord::StaleObjectError) do
  current_user.increment! :visits
end
```

NOTA: Definido en `active_support/core_ext/kernel/reporting.rb`.


### `in?`

El predicado [`in?`][Object#in?] comprueba si un objeto está incluido en otro objeto. Se generará una excepción `ArgumentError` si el argumento pasado no responde a `include?`.

Ejemplos de `in?`:

```ruby
1.in?([1, 2])        # => true
"lo".in?("hello")   # => true
25.in?(30..50)      # => false
1.in?(1)            # => ArgumentError
```

NOTA: Definido en `active_support/core_ext/object/inclusion.rb`.


Extensiones a `Module`
----------------------

### Atributos

#### `alias_attribute`

Los atributos del modelo tienen un lector, un escritor y un predicado. Puedes crear un alias para un atributo del modelo teniendo los tres métodos correspondientes definidos para ti utilizando [`alias_attribute`][Module#alias_attribute]. Como en otros métodos de aliasing, el nuevo nombre es el primer argumento y el antiguo nombre es el segundo (una mnemotecnia es que van en el mismo orden que si hicieras una asignación):

```ruby
class User < ApplicationRecord
  # Puedes referirte a la columna de correo electrónico como "login".
  # Esto puede ser significativo para el código de autenticación.
  alias_attribute :login, :email
end
```

NOTA: Definido en `active_support/core_ext/module/aliasing.rb`.


#### Atributos internos

Cuando defines un atributo en una clase que está destinada a ser subclaseada, existe el riesgo de colisiones de nombres. Esto es especialmente importante para las bibliotecas.

Active Support define las macros [`attr_internal_reader`][Module#attr_internal_reader], [`attr_internal_writer`][Module#attr_internal_writer] y [`attr_internal_accessor`][Module#attr_internal_accessor]. Se comportan como sus contrapartes `attr_*` integradas en Ruby, excepto que nombran la variable de instancia subyacente de una manera que reduce las posibilidades de colisión.

La macro [`attr_internal`][Module#attr_internal] es un sinónimo de `attr_internal_accessor`:

```ruby
# biblioteca
class ThirdPartyLibrary::Crawler
  attr_internal :log_level
end

# código del cliente
class MyCrawler < ThirdPartyLibrary::Crawler
  attr_accessor :log_level
end
```

En el ejemplo anterior, podría suceder que `:log_level` no pertenezca a la interfaz pública de la biblioteca y solo se use para el desarrollo. El código del cliente, sin conocer el posible conflicto, subclases y define su propio `:log_level`. Gracias a `attr_internal`, no hay colisión.

Por defecto, la variable de instancia interna se nombra con un guión bajo inicial, `@_log_level` en el ejemplo anterior. Sin embargo, esto es configurable a través de `Module.attr_internal_naming_format`, puedes pasar cualquier cadena de formato similar a `sprintf` con un `@` inicial y un `%s` en algún lugar, donde se colocará el nombre. El valor predeterminado es `"@_%s"`.

Rails utiliza atributos internos en algunos lugares, por ejemplo, para las vistas:

```ruby
module ActionView
  class Base
    attr_internal :captures
    attr_internal :request, :layout
    attr_internal :controller, :template
  end
end
```

NOTA: Definido en `active_support/core_ext/module/attr_internal.rb`.


#### Atributos de módulo

Las macros [`mattr_reader`][Module#mattr_reader], [`mattr_writer`][Module#mattr_writer] y [`mattr_accessor`][Module#mattr_accessor] son iguales que las macros `cattr_*` definidas para las clases. De hecho, las macros `cattr_*` son simplemente alias de las macros `mattr_*`. Consulta [Atributos de clase](#atributos-de-clase).
Por ejemplo, la API para el registro de Active Storage se genera con `mattr_accessor`:

```ruby
module ActiveStorage
  mattr_accessor :logger
end
```

NOTA: Definido en `active_support/core_ext/module/attribute_accessors.rb`.


### Padres

#### `module_parent`

El método [`module_parent`][Module#module_parent] en un módulo con nombre anidado devuelve el módulo que contiene su constante correspondiente:

```ruby
module X
  module Y
    module Z
    end
  end
end
M = X::Y::Z

X::Y::Z.module_parent # => X::Y
M.module_parent       # => X::Y
```

Si el módulo es anónimo o pertenece al nivel superior, `module_parent` devuelve `Object`.

ADVERTENCIA: Ten en cuenta que en ese caso `module_parent_name` devuelve `nil`.

NOTA: Definido en `active_support/core_ext/module/introspection.rb`.


#### `module_parent_name`

El método [`module_parent_name`][Module#module_parent_name] en un módulo con nombre anidado devuelve el nombre completamente cualificado del módulo que contiene su constante correspondiente:

```ruby
module X
  module Y
    module Z
    end
  end
end
M = X::Y::Z

X::Y::Z.module_parent_name # => "X::Y"
M.module_parent_name       # => "X::Y"
```

Para módulos de nivel superior o anónimos, `module_parent_name` devuelve `nil`.

ADVERTENCIA: Ten en cuenta que en ese caso `module_parent` devuelve `Object`.

NOTA: Definido en `active_support/core_ext/module/introspection.rb`.


#### `module_parents`

El método [`module_parents`][Module#module_parents] llama a `module_parent` en el receptor y hacia arriba hasta llegar a `Object`. La cadena se devuelve en un array, de abajo hacia arriba:

```ruby
module X
  module Y
    module Z
    end
  end
end
M = X::Y::Z

X::Y::Z.module_parents # => [X::Y, X, Object]
M.module_parents       # => [X::Y, X, Object]
```

NOTA: Definido en `active_support/core_ext/module/introspection.rb`.


### Anónimo

Un módulo puede tener o no un nombre:

```ruby
module M
end
M.name # => "M"

N = Module.new
N.name # => "N"

Module.new.name # => nil
```

Puedes verificar si un módulo tiene un nombre con el predicado [`anonymous?`][Module#anonymous?]:

```ruby
module M
end
M.anonymous? # => false

Module.new.anonymous? # => true
```

Ten en cuenta que ser inaccesible no implica ser anónimo:

```ruby
module M
end

m = Object.send(:remove_const, :M)

m.anonymous? # => false
```

aunque un módulo anónimo es inaccesible por definición.

NOTA: Definido en `active_support/core_ext/module/anonymous.rb`.


### Delegación de Métodos

#### `delegate`

La macro [`delegate`][Module#delegate] ofrece una forma sencilla de reenviar métodos.

Imaginemos que los usuarios en una aplicación tienen información de inicio de sesión en el modelo `User`, pero el nombre y otros datos en un modelo separado `Profile`:

```ruby
class User < ApplicationRecord
  has_one :profile
end
```

Con esa configuración, se obtiene el nombre de un usuario a través de su perfil, `user.profile.name`, pero podría ser útil poder acceder directamente a dicho atributo:

```ruby
class User < ApplicationRecord
  has_one :profile

  def name
    profile.name
  end
end
```

Esto es lo que hace `delegate` por ti:

```ruby
class User < ApplicationRecord
  has_one :profile

  delegate :name, to: :profile
end
```

Es más corto y la intención es más clara.

El método debe ser público en el objetivo.

La macro `delegate` acepta varios métodos:

```ruby
delegate :name, :age, :address, :twitter, to: :profile
```

Cuando se interpola en una cadena, la opción `:to` debe convertirse en una expresión que se evalúa en el objeto al que se delega el método. Normalmente una cadena o símbolo. Dicha expresión se evalúa en el contexto del receptor:

```ruby
# delega a la constante Rails
delegate :logger, to: :Rails

# delega a la clase del receptor
delegate :table_name, to: :class
```

ADVERTENCIA: Si la opción `:prefix` es `true`, esto es menos genérico, ver más abajo.

Por defecto, si la delegación genera un `NoMethodError` y el objetivo es `nil`, se propaga la excepción. Puedes pedir que en su lugar se devuelva `nil` con la opción `:allow_nil`:

```ruby
delegate :name, to: :profile, allow_nil: true
```

Con `:allow_nil`, la llamada `user.name` devuelve `nil` si el usuario no tiene perfil.

La opción `:prefix` agrega un prefijo al nombre del método generado. Esto puede ser útil, por ejemplo, para obtener un mejor nombre:

```ruby
delegate :street, to: :address, prefix: true
```

El ejemplo anterior genera `address_street` en lugar de `street`.
ADVERTENCIA: En este caso, el nombre del método generado está compuesto por el objeto de destino y los nombres de método de destino, por lo que la opción `:to` debe ser un nombre de método.

También se puede configurar un prefijo personalizado:

```ruby
delegate :size, to: :attachment, prefix: :avatar
```

En el ejemplo anterior, la macro genera `avatar_size` en lugar de `size`.

La opción `:private` cambia el alcance de los métodos:

```ruby
delegate :date_of_birth, to: :profile, private: true
```

Los métodos delegados son públicos de forma predeterminada. Pase `private: true` para cambiar eso.

NOTA: Definido en `active_support/core_ext/module/delegation.rb`


#### `delegate_missing_to`

Imagina que quieres delegar todo lo que falta en el objeto `User` al objeto `Profile`. La macro [`delegate_missing_to`][Module#delegate_missing_to] te permite implementar esto fácilmente:

```ruby
class User < ApplicationRecord
  has_one :profile

  delegate_missing_to :profile
end
```

El objetivo puede ser cualquier cosa llamable dentro del objeto, como variables de instancia, métodos, constantes, etc. Solo se delegan los métodos públicos del objetivo.

NOTA: Definido en `active_support/core_ext/module/delegation.rb`.


### Redefinición de métodos

Hay casos en los que necesitas definir un método con `define_method`, pero no sabes si ya existe un método con ese nombre. Si existe, se emite una advertencia si están habilitadas. No es gran cosa, pero tampoco es limpio.

El método [`redefine_method`][Module#redefine_method] evita esa advertencia potencial, eliminando el método existente antes si es necesario.

También puedes usar [`silence_redefinition_of_method`][Module#silence_redefinition_of_method] si necesitas definir el método de reemplazo tú mismo (porque estás usando `delegate`, por ejemplo).

NOTA: Definido en `active_support/core_ext/module/redefine_method.rb`.


Extensiones a `Class`
---------------------

### Atributos de clase

#### `class_attribute`

El método [`class_attribute`][Class#class_attribute] declara uno o más atributos de clase heredables que se pueden anular en cualquier nivel de la jerarquía.

```ruby
class A
  class_attribute :x
end

class B < A; end

class C < B; end

A.x = :a
B.x # => :a
C.x # => :a

B.x = :b
A.x # => :a
C.x # => :b

C.x = :c
A.x # => :a
B.x # => :b
```

Por ejemplo, `ActionMailer::Base` define:

```ruby
class_attribute :default_params
self.default_params = {
  mime_version: "1.0",
  charset: "UTF-8",
  content_type: "text/plain",
  parts_order: [ "text/plain", "text/enriched", "text/html" ]
}.freeze
```

También se pueden acceder y anular en el nivel de instancia.

```ruby
A.x = 1

a1 = A.new
a2 = A.new
a2.x = 2

a1.x # => 1, proviene de A
a2.x # => 2, anulado en a2
```

La generación del método de instancia de escritura se puede evitar configurando la opción `:instance_writer` en `false`.

```ruby
module ActiveRecord
  class Base
    class_attribute :table_name_prefix, instance_writer: false, default: "my"
  end
end
```

Un modelo puede encontrar útil esa opción como una forma de evitar la asignación masiva de establecer el atributo.

La generación del método de instancia de lectura se puede evitar configurando la opción `:instance_reader` en `false`.

```ruby
class A
  class_attribute :x, instance_reader: false
end

A.new.x = 1
A.new.x # NoMethodError
```

Para mayor comodidad, `class_attribute` también define un predicado de instancia que es la doble negación de lo que devuelve el lector de instancia. En los ejemplos anteriores se llamaría `x?`.

Cuando `:instance_reader` es `false`, el predicado de instancia devuelve un `NoMethodError` al igual que el método lector.

Si no deseas el predicado de instancia, pasa `instance_predicate: false` y no se definirá.

NOTA: Definido en `active_support/core_ext/class/attribute.rb`.


#### `cattr_reader`, `cattr_writer` y `cattr_accessor`

Las macros [`cattr_reader`][Module#cattr_reader], [`cattr_writer`][Module#cattr_writer] y [`cattr_accessor`][Module#cattr_accessor] son análogas a sus contrapartes `attr_*` pero para clases. Inicializan una variable de clase a `nil` a menos que ya exista y generan los métodos de clase correspondientes para acceder a ella:

```ruby
class MysqlAdapter < AbstractAdapter
  # Genera métodos de clase para acceder a @@emulate_booleans.
  cattr_accessor :emulate_booleans
end
```

Además, puedes pasar un bloque a `cattr_*` para configurar el atributo con un valor predeterminado:

```ruby
class MysqlAdapter < AbstractAdapter
  # Genera métodos de clase para acceder a @@emulate_booleans con un valor predeterminado de true.
  cattr_accessor :emulate_booleans, default: true
end
```
Los métodos de instancia también se crean por conveniencia, son solo proxies para el atributo de clase. Por lo tanto, las instancias pueden cambiar el atributo de clase, pero no pueden anularlo como sucede con `class_attribute` (ver arriba). Por ejemplo, dado

```ruby
module ActionView
  class Base
    cattr_accessor :field_error_proc, default: Proc.new { ... }
  end
end
```

podemos acceder a `field_error_proc` en las vistas.

La generación del método de instancia lector se puede evitar configurando `:instance_reader` en `false` y la generación del método de instancia escritor se puede evitar configurando `:instance_writer` en `false`. La generación de ambos métodos se puede evitar configurando `:instance_accessor` en `false`. En todos los casos, el valor debe ser exactamente `false` y no cualquier valor falso.

```ruby
module A
  class B
    # No se genera el lector de instancia first_name.
    cattr_accessor :first_name, instance_reader: false
    # No se genera el escritor de instancia last_name=.
    cattr_accessor :last_name, instance_writer: false
    # No se genera el lector de instancia surname ni el escritor surname=.
    cattr_accessor :surname, instance_accessor: false
  end
end
```

Un modelo puede encontrar útil configurar `:instance_accessor` en `false` como una forma de evitar la asignación masiva de atributos.

NOTA: Definido en `active_support/core_ext/module/attribute_accessors.rb`.


### Subclases y descendientes

#### `subclasses`

El método [`subclasses`][Class#subclasses] devuelve las subclases del receptor:

```ruby
class C; end
C.subclasses # => []

class B < C; end
C.subclasses # => [B]

class A < B; end
C.subclasses # => [B]

class D < C; end
C.subclasses # => [B, D]
```

El orden en el que se devuelven estas clases no está especificado.

NOTA: Definido en `active_support/core_ext/class/subclasses.rb`.


#### `descendants`

El método [`descendants`][Class#descendants] devuelve todas las clases que son `<` que su receptor:

```ruby
class C; end
C.descendants # => []

class B < C; end
C.descendants # => [B]

class A < B; end
C.descendants # => [B, A]

class D < C; end
C.descendants # => [B, A, D]
```

El orden en el que se devuelven estas clases no está especificado.

NOTA: Definido en `active_support/core_ext/class/subclasses.rb`.


Extensiones a `String`
----------------------

### Seguridad de la salida

#### Motivación

Insertar datos en plantillas HTML requiere cuidado adicional. Por ejemplo, no se puede simplemente interpolar `@review.title` literalmente en una página HTML. Por un lado, si el título de la reseña es "¡Flanagan & Matz rules!", la salida no será válida porque un ampersand debe escaparse como "&amp;amp;". Además, dependiendo de la aplicación, esto puede ser un gran agujero de seguridad porque los usuarios pueden inyectar HTML malicioso estableciendo un título de reseña personalizado. Consulta la sección sobre scripting entre sitios en la [guía de seguridad](security.html#cross-site-scripting-xss) para obtener más información sobre los riesgos.

#### Cadenas seguras

Active Support tiene el concepto de cadenas _(html) seguras_. Una cadena segura es aquella que se marca como insertable en HTML tal cual. Se considera confiable, sin importar si se ha escapado o no.

Las cadenas se consideran _inseguras_ de forma predeterminada:

```ruby
"".html_safe? # => false
```

Puedes obtener una cadena segura a partir de una cadena dada con el método [`html_safe`][String#html_safe]:

```ruby
s = "".html_safe
s.html_safe? # => true
```

Es importante entender que `html_safe` no realiza ninguna escapada en absoluto, es solo una afirmación:

```ruby
s = "<script>...</script>".html_safe
s.html_safe? # => true
s            # => "<script>...</script>"
```

Es tu responsabilidad asegurarte de que llamar a `html_safe` en una cadena en particular sea seguro.

Si agregas contenido a una cadena segura, ya sea directamente con `concat`/`<<`, o con `+`, el resultado es una cadena segura. Los argumentos inseguros se escapan:

```ruby
"".html_safe + "<" # => "&lt;"
```

Los argumentos seguros se agregan directamente:

```ruby
"".html_safe + "<".html_safe # => "<"
```

Estos métodos no deben usarse en vistas normales. Los valores inseguros se escapan automáticamente:

```erb
<%= @review.title %> <%# bien, escapado si es necesario %>
```
Para insertar algo textualmente, utiliza el ayudante [`raw`][] en lugar de llamar a `html_safe`:

```erb
<%= raw @cms.current_template %> <%# inserta @cms.current_template tal cual %>
```

o, de manera equivalente, utiliza `<%==`:

```erb
<%== @cms.current_template %> <%# inserta @cms.current_template tal cual %>
```

El ayudante `raw` llama a `html_safe` por ti:

```ruby
def raw(stringish)
  stringish.to_s.html_safe
end
```

NOTA: Definido en `active_support/core_ext/string/output_safety.rb`.


#### Transformación

Como regla general, excepto quizás para la concatenación como se explicó anteriormente, cualquier método que pueda cambiar una cadena te devuelve una cadena insegura. Estos son `downcase`, `gsub`, `strip`, `chomp`, `underscore`, etc.

En el caso de las transformaciones en su lugar, como `gsub!`, el receptor en sí mismo se vuelve inseguro.

INFO: La parte de seguridad se pierde siempre, sin importar si la transformación realmente cambió algo.

#### Conversión y coerción

Llamar a `to_s` en una cadena segura devuelve una cadena segura, pero la coerción con `to_str` devuelve una cadena insegura.

#### Copia

Llamar a `dup` o `clone` en cadenas seguras produce cadenas seguras.

### `remove`

El método [`remove`][String#remove] eliminará todas las ocurrencias del patrón:

```ruby
"Hello World".remove(/Hello /) # => "World"
```

También existe la versión destructiva `String#remove!`.

NOTA: Definido en `active_support/core_ext/string/filters.rb`.


### `squish`

El método [`squish`][String#squish] elimina los espacios en blanco al principio y al final, y sustituye las secuencias de espacios en blanco por un solo espacio:

```ruby
" \n  foo\n\r \t bar \n".squish # => "foo bar"
```

También existe la versión destructiva `String#squish!`.

Ten en cuenta que maneja tanto espacios en blanco ASCII como Unicode.

NOTA: Definido en `active_support/core_ext/string/filters.rb`.


### `truncate`

El método [`truncate`][String#truncate] devuelve una copia de su receptor truncado después de una longitud dada:

```ruby
"Oh dear! Oh dear! I shall be late!".truncate(20)
# => "Oh dear! Oh dear!..."
```

Elipsis se puede personalizar con la opción `:omission`:

```ruby
"Oh dear! Oh dear! I shall be late!".truncate(20, omission: '&hellip;')
# => "Oh dear! Oh &hellip;"
```

Ten en cuenta en particular que la truncación tiene en cuenta la longitud de la cadena de omisión.

Pasa un `:separator` para truncar la cadena en una ruptura natural:

```ruby
"Oh dear! Oh dear! I shall be late!".truncate(18)
# => "Oh dear! Oh dea..."
"Oh dear! Oh dear! I shall be late!".truncate(18, separator: ' ')
# => "Oh dear! Oh..."
```

La opción `:separator` puede ser una expresión regular:

```ruby
"Oh dear! Oh dear! I shall be late!".truncate(18, separator: /\s/)
# => "Oh dear! Oh..."
```

En los ejemplos anteriores, "dear" se corta primero, pero luego `:separator` lo evita.

NOTA: Definido en `active_support/core_ext/string/filters.rb`.


### `truncate_bytes`

El método [`truncate_bytes`][String#truncate_bytes] devuelve una copia de su receptor truncado a un máximo de `bytesize` bytes:

```ruby
"👍👍👍👍".truncate_bytes(15)
# => "👍👍👍…"
```

Elipsis se puede personalizar con la opción `:omission`:

```ruby
"👍👍👍👍".truncate_bytes(15, omission: "🖖")
# => "👍👍🖖"
```

NOTA: Definido en `active_support/core_ext/string/filters.rb`.


### `truncate_words`

El método [`truncate_words`][String#truncate_words] devuelve una copia de su receptor truncado después de un número dado de palabras:

```ruby
"Oh dear! Oh dear! I shall be late!".truncate_words(4)
# => "Oh dear! Oh dear!..."
```

Elipsis se puede personalizar con la opción `:omission`:

```ruby
"Oh dear! Oh dear! I shall be late!".truncate_words(4, omission: '&hellip;')
# => "Oh dear! Oh dear!&hellip;"
```

Pasa un `:separator` para truncar la cadena en una ruptura natural:

```ruby
"Oh dear! Oh dear! I shall be late!".truncate_words(3, separator: '!')
# => "Oh dear! Oh dear! I shall be late..."
```

La opción `:separator` puede ser una expresión regular:

```ruby
"Oh dear! Oh dear! I shall be late!".truncate_words(4, separator: /\s/)
# => "Oh dear! Oh dear!..."
```

NOTA: Definido en `active_support/core_ext/string/filters.rb`.


### `inquiry`

El método [`inquiry`][String#inquiry] convierte una cadena en un objeto `StringInquirer`, lo que hace que las comprobaciones de igualdad sean más bonitas.

```ruby
"production".inquiry.production? # => true
"active".inquiry.inactive?       # => false
```

NOTA: Definido en `active_support/core_ext/string/inquiry.rb`.


### `starts_with?` y `ends_with?`

Active Support define alias de tercera persona de `String#start_with?` y `String#end_with?`:

```ruby
"foo".starts_with?("f") # => true
"foo".ends_with?("o")   # => true
```
NOTA: Definido en `active_support/core_ext/string/starts_ends_with.rb`.

### `strip_heredoc`

El método [`strip_heredoc`][String#strip_heredoc] elimina la sangría en los heredocs.

Por ejemplo, en

```ruby
if options[:usage]
  puts <<-USAGE.strip_heredoc
    This command does such and such.

    Supported options are:
      -h         This message
      ...
  USAGE
end
```

el usuario vería el mensaje de uso alineado con el margen izquierdo.

Técnicamente, busca la línea con menos sangría en toda la cadena y elimina esa cantidad de espacios en blanco al principio.

NOTA: Definido en `active_support/core_ext/string/strip.rb`.


### `indent`

El método [`indent`][String#indent] sangra las líneas en el receptor:

```ruby
<<EOS.indent(2)
def some_method
  some_code
end
EOS
# =>
  def some_method
    some_code
  end
```

El segundo argumento, `indent_string`, especifica qué cadena de sangría usar. El valor predeterminado es `nil`, lo que indica al método que haga una suposición educada mirando la primera línea sangrada y que use un espacio si no hay ninguna.

```ruby
"  foo".indent(2)        # => "    foo"
"foo\n\t\tbar".indent(2) # => "\t\tfoo\n\t\t\t\tbar"
"foo".indent(2, "\t")    # => "\t\tfoo"
```

Si bien `indent_string` suele ser un espacio o una tabulación, puede ser cualquier cadena.

El tercer argumento, `indent_empty_lines`, es una bandera que indica si las líneas vacías deben sangrarse. El valor predeterminado es falso.

```ruby
"foo\n\nbar".indent(2)            # => "  foo\n\n  bar"
"foo\n\nbar".indent(2, nil, true) # => "  foo\n  \n  bar"
```

El método [`indent!`][String#indent!] realiza la sangría en su lugar.

NOTA: Definido en `active_support/core_ext/string/indent.rb`.


### Acceso

#### `at(position)`

El método [`at`][String#at] devuelve el carácter de la cadena en la posición `position`:

```ruby
"hello".at(0)  # => "h"
"hello".at(4)  # => "o"
"hello".at(-1) # => "o"
"hello".at(10) # => nil
```

NOTA: Definido en `active_support/core_ext/string/access.rb`.


#### `from(position)`

El método [`from`][String#from] devuelve la subcadena de la cadena que comienza en la posición `position`:

```ruby
"hello".from(0)  # => "hello"
"hello".from(2)  # => "llo"
"hello".from(-2) # => "lo"
"hello".from(10) # => nil
```

NOTA: Definido en `active_support/core_ext/string/access.rb`.


#### `to(position)`

El método [`to`][String#to] devuelve la subcadena de la cadena hasta la posición `position`:

```ruby
"hello".to(0)  # => "h"
"hello".to(2)  # => "hel"
"hello".to(-2) # => "hell"
"hello".to(10) # => "hello"
```

NOTA: Definido en `active_support/core_ext/string/access.rb`.


#### `first(limit = 1)`

El método [`first`][String#first] devuelve una subcadena que contiene los primeros `limit` caracteres de la cadena.

La llamada `str.first(n)` es equivalente a `str.to(n-1)` si `n` > 0, y devuelve una cadena vacía para `n` == 0.

NOTA: Definido en `active_support/core_ext/string/access.rb`.


#### `last(limit = 1)`

El método [`last`][String#last] devuelve una subcadena que contiene los últimos `limit` caracteres de la cadena.

La llamada `str.last(n)` es equivalente a `str.from(-n)` si `n` > 0, y devuelve una cadena vacía para `n` == 0.

NOTA: Definido en `active_support/core_ext/string/access.rb`.


### Inflections

#### `pluralize`

El método [`pluralize`][String#pluralize] devuelve el plural de su receptor:

```ruby
"table".pluralize     # => "tables"
"ruby".pluralize      # => "rubies"
"equipment".pluralize # => "equipment"
```

Como muestra el ejemplo anterior, Active Support conoce algunos plurales irregulares y sustantivos incontables. Las reglas incorporadas se pueden ampliar en `config/initializers/inflections.rb`. Este archivo se genera de forma predeterminada con el comando `rails new` y tiene instrucciones en comentarios.

`pluralize` también puede tomar un parámetro opcional `count`. Si `count == 1`, se devolverá la forma singular. Para cualquier otro valor de `count`, se devolverá la forma plural:

```ruby
"dude".pluralize(0) # => "dudes"
"dude".pluralize(1) # => "dude"
"dude".pluralize(2) # => "dudes"
```

Active Record utiliza este método para calcular el nombre de tabla predeterminado que corresponde a un modelo:

```ruby
# active_record/model_schema.rb
def undecorated_table_name(model_name)
  table_name = model_name.to_s.demodulize.underscore
  pluralize_table_names ? table_name.pluralize : table_name
end
```

NOTA: Definido en `active_support/core_ext/string/inflections.rb`.


#### `singularize`

El método [`singularize`][String#singularize] es el inverso de `pluralize`:

```ruby
"tables".singularize    # => "table"
"rubies".singularize    # => "ruby"
"equipment".singularize # => "equipment"
```

Las asociaciones calculan el nombre de la clase asociada predeterminada correspondiente utilizando este método:

```ruby
# active_record/reflection.rb
def derive_class_name
  class_name = name.to_s.camelize
  class_name = class_name.singularize if collection?
  class_name
end
```
NOTA: Definido en `active_support/core_ext/string/inflections.rb`.


#### `camelize`

El método [`camelize`][String#camelize] devuelve su receptor en formato camel case:

```ruby
"product".camelize    # => "Product"
"admin_user".camelize # => "AdminUser"
```

Como regla general, puedes pensar en este método como aquel que transforma rutas en nombres de clases o módulos de Ruby, donde las barras diagonales separan los espacios de nombres:

```ruby
"backoffice/session".camelize # => "Backoffice::Session"
```

Por ejemplo, Action Pack utiliza este método para cargar la clase que proporciona un determinado almacenamiento de sesión:

```ruby
# action_controller/metal/session_management.rb
def session_store=(store)
  @@session_store = store.is_a?(Symbol) ?
    ActionDispatch::Session.const_get(store.to_s.camelize) :
    store
end
```

`camelize` acepta un argumento opcional, que puede ser `:upper` (predeterminado) o `:lower`. Con este último, la primera letra se convierte en minúscula:

```ruby
"visual_effect".camelize(:lower) # => "visualEffect"
```

Esto puede ser útil para calcular nombres de métodos en un lenguaje que sigue esa convención, como JavaScript.

INFO: Como regla general, puedes pensar en `camelize` como el inverso de `underscore`, aunque hay casos en los que esto no se cumple: `"SSLError".underscore.camelize` devuelve `"SslError"`. Para admitir casos como este, Active Support te permite especificar acrónimos en `config/initializers/inflections.rb`:

```ruby
ActiveSupport::Inflector.inflections do |inflect|
  inflect.acronym 'SSL'
end

"SSLError".underscore.camelize # => "SSLError"
```

`camelize` está aliasado como [`camelcase`][String#camelcase].

NOTA: Definido en `active_support/core_ext/string/inflections.rb`.


#### `underscore`

El método [`underscore`][String#underscore] hace lo contrario, convierte de camel case a rutas:

```ruby
"Product".underscore   # => "product"
"AdminUser".underscore # => "admin_user"
```

También convierte "::" en "/":

```ruby
"Backoffice::Session".underscore # => "backoffice/session"
```

y entiende cadenas que comienzan con minúscula:

```ruby
"visualEffect".underscore # => "visual_effect"
```

`underscore` no acepta argumentos.

Rails utiliza `underscore` para obtener un nombre en minúscula para las clases de controladores:

```ruby
# actionpack/lib/abstract_controller/base.rb
def controller_path
  @controller_path ||= name.delete_suffix("Controller").underscore
end
```

Por ejemplo, ese valor es el que obtienes en `params[:controller]`.

INFO: Como regla general, puedes pensar en `underscore` como el inverso de `camelize`, aunque hay casos en los que esto no se cumple. Por ejemplo, `"SSLError".underscore.camelize` devuelve `"SslError"`.

NOTA: Definido en `active_support/core_ext/string/inflections.rb`.


#### `titleize`

El método [`titleize`][String#titleize] capitaliza las palabras en el receptor:

```ruby
"alice in wonderland".titleize # => "Alice In Wonderland"
"fermat's enigma".titleize     # => "Fermat's Enigma"
```

`titleize` está aliasado como [`titlecase`][String#titlecase].

NOTA: Definido en `active_support/core_ext/string/inflections.rb`.


#### `dasherize`

El método [`dasherize`][String#dasherize] reemplaza los guiones bajos en el receptor por guiones:

```ruby
"name".dasherize         # => "name"
"contact_data".dasherize # => "contact-data"
```

El serializador XML de los modelos utiliza este método para convertir los nombres de los nodos en formato guionizado:

```ruby
# active_model/serializers/xml.rb
def reformat_name(name)
  name = name.camelize if camelize?
  dasherize? ? name.dasherize : name
end
```

NOTA: Definido en `active_support/core_ext/string/inflections.rb`.


#### `demodulize`

Dada una cadena con un nombre de constante calificado, [`demodulize`][String#demodulize] devuelve el nombre de la constante en sí, es decir, la parte más a la derecha:

```ruby
"Product".demodulize                        # => "Product"
"Backoffice::UsersController".demodulize    # => "UsersController"
"Admin::Hotel::ReservationUtils".demodulize # => "ReservationUtils"
"::Inflections".demodulize                  # => "Inflections"
"".demodulize                               # => ""
```

Active Record, por ejemplo, utiliza este método para calcular el nombre de una columna de caché de contador:

```ruby
# active_record/reflection.rb
def counter_cache_column
  if options[:counter_cache] == true
    "#{active_record.name.demodulize.underscore.pluralize}_count"
  elsif options[:counter_cache]
    options[:counter_cache]
  end
end
```

NOTA: Definido en `active_support/core_ext/string/inflections.rb`.


#### `deconstantize`

Dada una cadena con una expresión de referencia a una constante calificada, [`deconstantize`][String#deconstantize] elimina el segmento más a la derecha, dejando generalmente el nombre del contenedor de la constante:

```ruby
"Product".deconstantize                        # => ""
"Backoffice::UsersController".deconstantize    # => "Backoffice"
"Admin::Hotel::ReservationUtils".deconstantize # => "Admin::Hotel"
```

NOTA: Definido en `active_support/core_ext/string/inflections.rb`.


#### `parameterize`

El método [`parameterize`][String#parameterize] normaliza su receptor de una manera que se puede utilizar en URLs legibles.

```ruby
"John Smith".parameterize # => "john-smith"
"Kurt Gödel".parameterize # => "kurt-godel"
```

Para preservar el caso de la cadena, establece el argumento `preserve_case` en true. Por defecto, `preserve_case` se establece en false.

```ruby
"John Smith".parameterize(preserve_case: true) # => "John-Smith"
"Kurt Gödel".parameterize(preserve_case: true) # => "Kurt-Godel"
```

Para utilizar un separador personalizado, sobrescribe el argumento `separator`.
```ruby
"Employee Salary".downcase_first # => "employee Salary"
"".downcase_first                # => ""
```

NOTE: Defined in `active_support/core_ext/string/inflections.rb`.
```ruby
123.to_fs(:human)                  # => "123"
1234.to_fs(:human)                 # => "1.23 Thousand"
12345.to_fs(:human)                # => "12.3 Thousand"
1234567.to_fs(:human)              # => "1.23 Million"
1234567890.to_fs(:human)           # => "1.23 Billion"
1234567890123.to_fs(:human)        # => "1.23 Trillion"
1234567890123456.to_fs(:human)     # => "1.23 Quadrillion"
1234567890123456789.to_fs(:human)  # => "1.23 Quintillion"
```

NOTE: Defined in `active_support/core_ext/numeric/conversions.rb`.
```ruby
123.to_fs(:human)               # => "123"
1234.to_fs(:human)              # => "1.23 Mil"
12345.to_fs(:human)             # => "12.3 Mil"
1234567.to_fs(:human)           # => "1.23 Millón"
1234567890.to_fs(:human)        # => "1.23 Mil Millones"
1234567890123.to_fs(:human)     # => "1.23 Billones"
1234567890123456.to_fs(:human)  # => "1.23 Cuatrillones"
```

NOTA: Definido en `active_support/core_ext/numeric/conversions.rb`.

Extensiones a `Integer`
-----------------------

### `multiple_of?`

El método [`multiple_of?`][Integer#multiple_of?] verifica si un entero es múltiplo del argumento:

```ruby
2.multiple_of?(1) # => true
1.multiple_of?(2) # => false
```

NOTA: Definido en `active_support/core_ext/integer/multiple.rb`.


### `ordinal`

El método [`ordinal`][Integer#ordinal] devuelve el sufijo ordinal correspondiente al entero receptor:

```ruby
1.ordinal    # => "º"
2.ordinal    # => "º"
53.ordinal   # => "º"
2009.ordinal # => "º"
-21.ordinal  # => "º"
-134.ordinal # => "º"
```

NOTA: Definido en `active_support/core_ext/integer/inflections.rb`.


### `ordinalize`

El método [`ordinalize`][Integer#ordinalize] devuelve el string ordinal correspondiente al entero receptor. En comparación, el método `ordinal` devuelve **solo** el sufijo.

```ruby
1.ordinalize    # => "1º"
2.ordinalize    # => "2º"
53.ordinalize   # => "53º"
2009.ordinalize # => "2009º"
-21.ordinalize  # => "-21º"
-134.ordinalize # => "-134º"
```

NOTA: Definido en `active_support/core_ext/integer/inflections.rb`.


### Time

Los siguientes métodos:

* [`months`][Integer#months]
* [`years`][Integer#years]

permiten declaraciones y cálculos de tiempo, como `4.months + 5.years`. Sus valores de retorno también se pueden sumar o restar a objetos de tipo Time.

Estos métodos se pueden combinar con [`from_now`][Duration#from_now], [`ago`][Duration#ago], etc., para cálculos precisos de fechas. Por ejemplo:

```ruby
# equivalente a Time.current.advance(months: 1)
1.month.from_now

# equivalente a Time.current.advance(years: 2)
2.years.from_now

# equivalente a Time.current.advance(months: 4, years: 5)
(4.months + 5.years).from_now
```

ADVERTENCIA. Para otras duraciones, consulte las extensiones de tiempo a `Numeric`.

NOTA: Definido en `active_support/core_ext/integer/time.rb`.


Extensiones a `BigDecimal`
--------------------------

### `to_s`

El método `to_s` proporciona un especificador predeterminado de "F". Esto significa que una llamada simple a `to_s` dará como resultado una representación de punto flotante en lugar de notación científica:

```ruby
BigDecimal(5.00, 6).to_s       # => "5.0"
```

También se admite la notación científica:

```ruby
BigDecimal(5.00, 6).to_s("e")  # => "0.5E1"
```

Extensiones a `Enumerable`
--------------------------

### `sum`

El método [`sum`][Enumerable#sum] suma los elementos de un enumerable:

```ruby
[1, 2, 3].sum # => 6
(1..100).sum  # => 5050
```

La suma asume que los elementos responden a `+`:

```ruby
[[1, 2], [2, 3], [3, 4]].sum    # => [1, 2, 2, 3, 3, 4]
%w(foo bar baz).sum             # => "foobarbaz"
{ a: 1, b: 2, c: 3 }.sum          # => [:a, 1, :b, 2, :c, 3]
```

La suma de una colección vacía es cero por defecto, pero esto se puede personalizar:

```ruby
[].sum    # => 0
[].sum(1) # => 1
```

Si se proporciona un bloque, `sum` se convierte en un iterador que devuelve los elementos de la colección y suma los valores devueltos:

```ruby
(1..5).sum { |n| n * 2 } # => 30
[2, 4, 6, 8, 10].sum    # => 30
```

La suma de un receptor vacío también se puede personalizar en esta forma:

```ruby
[].sum(1) { |n| n**3 } # => 1
```

NOTA: Definido en `active_support/core_ext/enumerable.rb`.


### `index_by`

El método [`index_by`][Enumerable#index_by] genera un hash con los elementos de un enumerable indexados por alguna clave.

Itera a través de la colección y pasa cada elemento a un bloque. El elemento se indexará por el valor devuelto por el bloque:

```ruby
invoices.index_by(&:number)
# => {'2009-032' => <Invoice ...>, '2009-008' => <Invoice ...>, ...}
```

ADVERTENCIA. Las claves normalmente deben ser únicas. Si el bloque devuelve el mismo valor para diferentes elementos, no se construirá una colección para esa clave. El último elemento ganará.

NOTA: Definido en `active_support/core_ext/enumerable.rb`.


### `index_with`

El método [`index_with`][Enumerable#index_with] genera un hash con los elementos de un enumerable como claves. El valor
es un valor predeterminado pasado o devuelto en un bloque.

```ruby
post = Post.new(title: "hey there", body: "what's up?")

%i( title body ).index_with { |attr_name| post.public_send(attr_name) }
# => { title: "hey there", body: "what's up?" }

WEEKDAYS.index_with(Interval.all_day)
# => { monday: [ 0, 1440 ], … }
```
NOTA: Definido en `active_support/core_ext/enumerable.rb`.


### `many?`

El método [`many?`][Enumerable#many?] es una forma abreviada de `collection.size > 1`:

```erb
<% if pages.many? %>
  <%= pagination_links %>
<% end %>
```

Si se proporciona un bloque opcional, `many?` solo tiene en cuenta aquellos elementos que devuelven verdadero:

```ruby
@see_more = videos.many? { |video| video.category == params[:category] }
```

NOTA: Definido en `active_support/core_ext/enumerable.rb`.


### `exclude?`

El predicado [`exclude?`][Enumerable#exclude?] prueba si un objeto dado **no** pertenece a la colección. Es la negación de `include?` incorporado:

```ruby
to_visit << node if visited.exclude?(node)
```

NOTA: Definido en `active_support/core_ext/enumerable.rb`.


### `including`

El método [`including`][Enumerable#including] devuelve un nuevo enumerable que incluye los elementos pasados:

```ruby
[ 1, 2, 3 ].including(4, 5)                    # => [ 1, 2, 3, 4, 5 ]
["David", "Rafael"].including %w[ Aaron Todd ] # => ["David", "Rafael", "Aaron", "Todd"]
```

NOTA: Definido en `active_support/core_ext/enumerable.rb`.


### `excluding`

El método [`excluding`][Enumerable#excluding] devuelve una copia de un enumerable con los elementos especificados eliminados:

```ruby
["David", "Rafael", "Aaron", "Todd"].excluding("Aaron", "Todd") # => ["David", "Rafael"]
```

`excluding` es un alias de [`without`][Enumerable#without].

NOTA: Definido en `active_support/core_ext/enumerable.rb`.


### `pluck`

El método [`pluck`][Enumerable#pluck] extrae la clave dada de cada elemento:

```ruby
[{ name: "David" }, { name: "Rafael" }, { name: "Aaron" }].pluck(:name) # => ["David", "Rafael", "Aaron"]
[{ id: 1, name: "David" }, { id: 2, name: "Rafael" }].pluck(:id, :name) # => [[1, "David"], [2, "Rafael"]]
```

NOTA: Definido en `active_support/core_ext/enumerable.rb`.


### `pick`

El método [`pick`][Enumerable#pick] extrae la clave dada del primer elemento:

```ruby
[{ name: "David" }, { name: "Rafael" }, { name: "Aaron" }].pick(:name) # => "David"
[{ id: 1, name: "David" }, { id: 2, name: "Rafael" }].pick(:id, :name) # => [1, "David"]
```

NOTA: Definido en `active_support/core_ext/enumerable.rb`.


Extensiones para `Array`
---------------------

### Acceso

Active Support amplía la API de los arrays para facilitar ciertas formas de acceso. Por ejemplo, [`to`][Array#to] devuelve el subarray de elementos hasta el índice pasado:

```ruby
%w(a b c d).to(2) # => ["a", "b", "c"]
[].to(7)          # => []
```

De manera similar, [`from`][Array#from] devuelve la cola desde el elemento en el índice pasado hasta el final. Si el índice es mayor que la longitud del array, devuelve un array vacío.

```ruby
%w(a b c d).from(2)  # => ["c", "d"]
%w(a b c d).from(10) # => []
[].from(0)           # => []
```

El método [`including`][Array#including] devuelve un nuevo array que incluye los elementos pasados:

```ruby
[ 1, 2, 3 ].including(4, 5)          # => [ 1, 2, 3, 4, 5 ]
[ [ 0, 1 ] ].including([ [ 1, 0 ] ]) # => [ [ 0, 1 ], [ 1, 0 ] ]
```

El método [`excluding`][Array#excluding] devuelve una copia del Array excluyendo los elementos especificados.
Esta es una optimización de `Enumerable#excluding` que utiliza `Array#-`
en lugar de `Array#reject` por razones de rendimiento.

```ruby
["David", "Rafael", "Aaron", "Todd"].excluding("Aaron", "Todd") # => ["David", "Rafael"]
[ [ 0, 1 ], [ 1, 0 ] ].excluding([ [ 1, 0 ] ])                  # => [ [ 0, 1 ] ]
```

Los métodos [`second`][Array#second], [`third`][Array#third], [`fourth`][Array#fourth] y [`fifth`][Array#fifth] devuelven el elemento correspondiente, al igual que [`second_to_last`][Array#second_to_last] y [`third_to_last`][Array#third_to_last] (`first` y `last` son incorporados). Gracias a la sabiduría social y la constructividad positiva en todas partes, también está disponible [`forty_two`][Array#forty_two].

```ruby
%w(a b c d).third # => "c"
%w(a b c d).fifth # => nil
```

NOTA: Definido en `active_support/core_ext/array/access.rb`.


### Extracción

El método [`extract!`][Array#extract!] elimina y devuelve los elementos para los cuales el bloque devuelve un valor verdadero.
Si no se proporciona un bloque, en su lugar se devuelve un Enumerator.

```ruby
numbers = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
odd_numbers = numbers.extract! { |number| number.odd? } # => [1, 3, 5, 7, 9]
numbers # => [0, 2, 4, 6, 8]
```
NOTA: Definido en `active_support/core_ext/array/extract.rb`.


### Extracción de opciones

Cuando el último argumento en una llamada a un método es un hash, excepto tal vez por un argumento `&block`, Ruby permite omitir los corchetes:

```ruby
User.exists?(email: params[:email])
```

Este azúcar sintáctico se utiliza mucho en Rails para evitar argumentos posicionales cuando habría demasiados, ofreciendo en su lugar interfaces que emulan parámetros nombrados. En particular, es muy idiomático usar un hash al final para las opciones.

Sin embargo, si un método espera un número variable de argumentos y utiliza `*` en su declaración, ese hash de opciones termina siendo un elemento del array de argumentos, donde pierde su función.

En esos casos, puedes darle un tratamiento distinguido a un hash de opciones con [`extract_options!`][Array#extract_options!]. Este método verifica el tipo del último elemento de un array. Si es un hash, lo extrae y lo devuelve, de lo contrario devuelve un hash vacío.

Veamos por ejemplo la definición de la macro del controlador `caches_action`:

```ruby
def caches_action(*actions)
  return unless cache_configured?
  options = actions.extract_options!
  # ...
end
```

Este método recibe un número arbitrario de nombres de acciones y un hash opcional de opciones como último argumento. Con la llamada a `extract_options!` obtienes el hash de opciones y lo eliminas de `actions` de una manera simple y explícita.

NOTA: Definido en `active_support/core_ext/array/extract_options.rb`.


### Conversiones

#### `to_sentence`

El método [`to_sentence`][Array#to_sentence] convierte un array en una cadena que enumera sus elementos:

```ruby
%w().to_sentence                # => ""
%w(Earth).to_sentence           # => "Earth"
%w(Earth Wind).to_sentence      # => "Earth and Wind"
%w(Earth Wind Fire).to_sentence # => "Earth, Wind, and Fire"
```

Este método acepta tres opciones:

* `:two_words_connector`: Lo que se utiliza para arrays de longitud 2. El valor predeterminado es " and ".
* `:words_connector`: Lo que se utiliza para unir los elementos de arrays con 3 o más elementos, excepto los dos últimos. El valor predeterminado es ", ".
* `:last_word_connector`: Lo que se utiliza para unir los últimos elementos de un array con 3 o más elementos. El valor predeterminado es ", and ".

Los valores predeterminados para estas opciones se pueden localizar, sus claves son:

| Opción                 | Clave I18n                            |
| ---------------------- | ----------------------------------- |
| `:two_words_connector` | `support.array.two_words_connector` |
| `:words_connector`     | `support.array.words_connector`     |
| `:last_word_connector` | `support.array.last_word_connector` |

NOTA: Definido en `active_support/core_ext/array/conversions.rb`.


#### `to_fs`

El método [`to_fs`][Array#to_fs] actúa como `to_s` de forma predeterminada.

Sin embargo, si el array contiene elementos que responden a `id`, se puede pasar el símbolo `:db` como argumento. Esto se utiliza típicamente con colecciones de objetos Active Record. Las cadenas devueltas son:

```ruby
[].to_fs(:db)            # => "null"
[user].to_fs(:db)        # => "8456"
invoice.lines.to_fs(:db) # => "23,567,556,12"
```

Se supone que los enteros en el ejemplo anterior provienen de las respectivas llamadas a `id`.

NOTA: Definido en `active_support/core_ext/array/conversions.rb`.


#### `to_xml`

El método [`to_xml`][Array#to_xml] devuelve una cadena que contiene una representación XML de su receptor:

```ruby
Contributor.limit(2).order(:rank).to_xml
# =>
# <?xml version="1.0" encoding="UTF-8"?>
# <contributors type="array">
#   <contributor>
#     <id type="integer">4356</id>
#     <name>Jeremy Kemper</name>
#     <rank type="integer">1</rank>
#     <url-id>jeremy-kemper</url-id>
#   </contributor>
#   <contributor>
#     <id type="integer">4404</id>
#     <name>David Heinemeier Hansson</name>
#     <rank type="integer">2</rank>
#     <url-id>david-heinemeier-hansson</url-id>
#   </contributor>
# </contributors>
```

Para hacer esto, envía `to_xml` a cada elemento por turno y recopila los resultados bajo un nodo raíz. Todos los elementos deben responder a `to_xml`, de lo contrario se genera una excepción.

De forma predeterminada, el nombre del elemento raíz es el plural en minúsculas y con guiones del nombre de la clase del primer elemento, siempre que el resto de los elementos pertenezcan a ese tipo (comprobado con `is_a?`) y no sean hashes. En el ejemplo anterior, eso es "contributors".

Si hay algún elemento que no pertenece al tipo del primero, el nodo raíz se convierte en "objects":
```ruby
[Contributor.first, Commit.first].to_xml
# =>
# <?xml version="1.0" encoding="UTF-8"?>
# <objects type="array">
#   <object>
#     <id type="integer">4583</id>
#     <name>Aaron Batalion</name>
#     <rank type="integer">53</rank>
#     <url-id>aaron-batalion</url-id>
#   </object>
#   <object>
#     <author>Joshua Peek</author>
#     <authored-timestamp type="datetime">2009-09-02T16:44:36Z</authored-timestamp>
#     <branch>origin/master</branch>
#     <committed-timestamp type="datetime">2009-09-02T16:44:36Z</committed-timestamp>
#     <committer>Joshua Peek</committer>
#     <git-show nil="true"></git-show>
#     <id type="integer">190316</id>
#     <imported-from-svn type="boolean">false</imported-from-svn>
#     <message>Kill AMo observing wrap_with_notifications since ARes was only using it</message>
#     <sha1>723a47bfb3708f968821bc969a9a3fc873a3ed58</sha1>
#   </object>
# </objects>
```

Si el receptor es un array de hashes, el elemento raíz por defecto también es "objects":

```ruby
[{ a: 1, b: 2 }, { c: 3 }].to_xml
# =>
# <?xml version="1.0" encoding="UTF-8"?>
# <objects type="array">
#   <object>
#     <b type="integer">2</b>
#     <a type="integer">1</a>
#   </object>
#   <object>
#     <c type="integer">3</c>
#   </object>
# </objects>
```

ADVERTENCIA. Si la colección está vacía, el elemento raíz por defecto es "nil-classes". Esto puede ser confuso, por ejemplo, el elemento raíz de la lista de contribuyentes anterior no sería "contributors" si la colección estuviera vacía, sino "nil-classes". Puede utilizar la opción `:root` para asegurar un elemento raíz consistente.

El nombre de los nodos hijos es, por defecto, el nombre del nodo raíz en singular. En los ejemplos anteriores hemos visto "contributor" y "object". La opción `:children` te permite establecer estos nombres de nodos.

El constructor XML por defecto es una nueva instancia de `Builder::XmlMarkup`. Puedes configurar tu propio constructor a través de la opción `:builder`. El método también acepta opciones como `:dasherize` y otros, que se envían al constructor:

```ruby
Contributor.limit(2).order(:rank).to_xml(skip_types: true)
# =>
# <?xml version="1.0" encoding="UTF-8"?>
# <contributors>
#   <contributor>
#     <id>4356</id>
#     <name>Jeremy Kemper</name>
#     <rank>1</rank>
#     <url-id>jeremy-kemper</url-id>
#   </contributor>
#   <contributor>
#     <id>4404</id>
#     <name>David Heinemeier Hansson</name>
#     <rank>2</rank>
#     <url-id>david-heinemeier-hansson</url-id>
#   </contributor>
# </contributors>
```

NOTA: Definido en `active_support/core_ext/array/conversions.rb`.


### Envoltura

El método [`Array.wrap`][Array.wrap] envuelve su argumento en un array a menos que ya sea un array (o similar a un array).

Específicamente:

* Si el argumento es `nil`, se devuelve un array vacío.
* De lo contrario, si el argumento responde a `to_ary`, se invoca, y si el valor de `to_ary` no es `nil`, se devuelve.
* De lo contrario, se devuelve un array con el argumento como su único elemento.

```ruby
Array.wrap(nil)       # => []
Array.wrap([1, 2, 3]) # => [1, 2, 3]
Array.wrap(0)         # => [0]
```

Este método es similar en propósito a `Kernel#Array`, pero hay algunas diferencias:

* Si el argumento responde a `to_ary`, se invoca el método. `Kernel#Array` pasa a intentar `to_a` si el valor devuelto es `nil`, pero `Array.wrap` devuelve de inmediato un array con el argumento como su único elemento.
* Si el valor devuelto de `to_ary` no es `nil` ni un objeto `Array`, `Kernel#Array` lanza una excepción, mientras que `Array.wrap` no lo hace, simplemente devuelve el valor.
* No llama a `to_a` en el argumento, si el argumento no responde a `to_ary`, devuelve un array con el argumento como su único elemento.

El último punto es particularmente importante al comparar algunos enumerables:

```ruby
Array.wrap(foo: :bar) # => [{:foo=>:bar}]
Array(foo: :bar)      # => [[:foo, :bar]]
```

También hay un idioma relacionado que utiliza el operador splat:

```ruby
[*object]
```

NOTA: Definido en `active_support/core_ext/array/wrap.rb`.


### Duplicación

El método [`Array#deep_dup`][Array#deep_dup] duplica el array y todos los objetos en su interior de forma recursiva con el método `Object#deep_dup` de Active Support. Funciona como `Array#map`, enviando el método `deep_dup` a cada objeto en su interior.

```ruby
array = [1, [2, 3]]
dup = array.deep_dup
dup[1][2] = 4
array[1][2] == nil   # => true
```

NOTA: Definido en `active_support/core_ext/object/deep_dup.rb`.


### Agrupamiento

#### `in_groups_of(number, fill_with = nil)`

El método [`in_groups_of`][Array#in_groups_of] divide un array en grupos consecutivos de un tamaño determinado. Devuelve un array con los grupos:

```ruby
[1, 2, 3].in_groups_of(2) # => [[1, 2], [3, nil]]
```
o los devuelve a su vez si se pasa un bloque:

```html+erb
<% sample.in_groups_of(3) do |a, b, c| %>
  <tr>
    <td><%= a %></td>
    <td><%= b %></td>
    <td><%= c %></td>
  </tr>
<% end %>
```

El primer ejemplo muestra cómo `in_groups_of` llena el último grupo con tantos elementos `nil` como sea necesario para tener el tamaño solicitado. Puede cambiar este valor de relleno utilizando el segundo argumento opcional:

```ruby
[1, 2, 3].in_groups_of(2, 0) # => [[1, 2], [3, 0]]
```

Y puede indicarle al método que no llene el último grupo pasando `false`:

```ruby
[1, 2, 3].in_groups_of(2, false) # => [[1, 2], [3]]
```

Como consecuencia, `false` no se puede utilizar como valor de relleno.

NOTA: Definido en `active_support/core_ext/array/grouping.rb`.


#### `in_groups(number, fill_with = nil)`

El método [`in_groups`][Array#in_groups] divide una matriz en un cierto número de grupos. El método devuelve una matriz con los grupos:

```ruby
%w(1 2 3 4 5 6 7).in_groups(3)
# => [["1", "2", "3"], ["4", "5", nil], ["6", "7", nil]]
```

o los devuelve a su vez si se pasa un bloque:

```ruby
%w(1 2 3 4 5 6 7).in_groups(3) { |group| p group }
["1", "2", "3"]
["4", "5", nil]
["6", "7", nil]
```

Los ejemplos anteriores muestran que `in_groups` llena algunos grupos con un elemento `nil` adicional según sea necesario. Un grupo puede tener como máximo uno de estos elementos adicionales, el más a la derecha si lo hay. Y los grupos que los tienen siempre son los últimos.

Puede cambiar este valor de relleno utilizando el segundo argumento opcional:

```ruby
%w(1 2 3 4 5 6 7).in_groups(3, "0")
# => [["1", "2", "3"], ["4", "5", "0"], ["6", "7", "0"]]
```

Y puede indicarle al método que no llene los grupos más pequeños pasando `false`:

```ruby
%w(1 2 3 4 5 6 7).in_groups(3, false)
# => [["1", "2", "3"], ["4", "5"], ["6", "7"]]
```

Como consecuencia, `false` no se puede utilizar como valor de relleno.

NOTA: Definido en `active_support/core_ext/array/grouping.rb`.


#### `split(value = nil)`

El método [`split`][Array#split] divide una matriz por un separador y devuelve los fragmentos resultantes.

Si se pasa un bloque, los separadores son aquellos elementos de la matriz para los cuales el bloque devuelve verdadero:

```ruby
(-5..5).to_a.split { |i| i.multiple_of?(4) }
# => [[-5], [-3, -2, -1], [1, 2, 3], [5]]
```

De lo contrario, el valor recibido como argumento, que por defecto es `nil`, es el separador:

```ruby
[0, 1, -5, 1, 1, "foo", "bar"].split(1)
# => [[0], [-5], [], ["foo", "bar"]]
```

CONSEJO: Observa en el ejemplo anterior que los separadores consecutivos resultan en matrices vacías.

NOTA: Definido en `active_support/core_ext/array/grouping.rb`.


Extensiones a `Hash`
--------------------

### Conversiones

#### `to_xml`

El método [`to_xml`][Hash#to_xml] devuelve una cadena que contiene una representación XML de su receptor:

```ruby
{ foo: 1, bar: 2 }.to_xml
# =>
# <?xml version="1.0" encoding="UTF-8"?>
# <hash>
#   <foo type="integer">1</foo>
#   <bar type="integer">2</bar>
# </hash>
```

Para hacer esto, el método recorre los pares y construye nodos que dependen de los _valores_. Dado un par `clave`, `valor`:

* Si `valor` es un hash, hay una llamada recursiva con `clave` como `:root`.

* Si `valor` es una matriz, hay una llamada recursiva con `clave` como `:root`, y `clave` singularizado como `:children`.

* Si `valor` es un objeto invocable, debe esperar uno o dos argumentos. Dependiendo de la aridad, se invoca al objeto invocable con el hash de `opciones` como primer argumento con `clave` como `:root`, y `clave` singularizado como segundo argumento. Su valor de retorno se convierte en un nuevo nodo.

* Si `valor` responde a `to_xml`, se invoca al método con `clave` como `:root`.

* De lo contrario, se crea un nodo con `clave` como etiqueta y una representación en cadena de `valor` como nodo de texto. Si `valor` es `nil`, se agrega un atributo "nil" establecido en "true". A menos que exista la opción `:skip_types` y sea verdadera, también se agrega un atributo "type" según la siguiente asignación:
```ruby
XML_TYPE_NAMES = {
  "Symbol"     => "símbolo",
  "Integer"    => "entero",
  "BigDecimal" => "decimal",
  "Float"      => "flotante",
  "TrueClass"  => "booleano",
  "FalseClass" => "booleano",
  "Date"       => "fecha",
  "DateTime"   => "fecha_hora",
  "Time"       => "fecha_hora"
}
```

Por defecto, el nodo raíz es "hash", pero esto se puede configurar mediante la opción `:root`.

El constructor XML predeterminado es una nueva instancia de `Builder::XmlMarkup`. Puede configurar su propio constructor con la opción `:builder`. El método también acepta opciones como `:dasherize` y otras, que se envían al constructor.

NOTA: Definido en `active_support/core_ext/hash/conversions.rb`.


### Combinación

Ruby tiene un método incorporado `Hash#merge` que combina dos hashes:

```ruby
{ a: 1, b: 1 }.merge(a: 0, c: 2)
# => {:a=>0, :b=>1, :c=>2}
```

Active Support define algunas formas más de combinar hashes que pueden ser convenientes.

#### `reverse_merge` y `reverse_merge!`

En caso de colisión, la clave en el hash del argumento gana en `merge`. Puede admitir hashes de opciones con valores predeterminados de manera compacta con esta expresión:

```ruby
options = { length: 30, omission: "..." }.merge(options)
```

Active Support define [`reverse_merge`][Hash#reverse_merge] en caso de que prefiera esta notación alternativa:

```ruby
options = options.reverse_merge(length: 30, omission: "...")
```

Y una versión con exclamación [`reverse_merge!`][Hash#reverse_merge!] que realiza la combinación en el lugar:

```ruby
options.reverse_merge!(length: 30, omission: "...")
```

ADVERTENCIA. Tenga en cuenta que `reverse_merge!` puede cambiar el hash en el llamador, lo cual puede ser o no una buena idea.

NOTA: Definido en `active_support/core_ext/hash/reverse_merge.rb`.


#### `reverse_update`

El método [`reverse_update`][Hash#reverse_update] es un alias de `reverse_merge!`, explicado anteriormente.

ADVERTENCIA. Tenga en cuenta que `reverse_update` no tiene exclamación.

NOTA: Definido en `active_support/core_ext/hash/reverse_merge.rb`.


#### `deep_merge` y `deep_merge!`

Como se puede ver en el ejemplo anterior, si una clave se encuentra en ambos hashes, el valor en el hash del argumento gana.

Active Support define [`Hash#deep_merge`][Hash#deep_merge]. En una combinación profunda, si una clave se encuentra en ambos hashes y sus valores son hashes a su vez, entonces su _combinación_ se convierte en el valor en el hash resultante:

```ruby
{ a: { b: 1 } }.deep_merge(a: { c: 2 })
# => {:a=>{:b=>1, :c=>2}}
```

El método [`deep_merge!`][Hash#deep_merge!] realiza una combinación profunda en el lugar.

NOTA: Definido en `active_support/core_ext/hash/deep_merge.rb`.


### Duplicación Profunda

El método [`Hash#deep_dup`][Hash#deep_dup] duplica a sí mismo y a todas las claves y valores
dentro de forma recursiva con el método `Object#deep_dup` de Active Support. Funciona como `Enumerator#each_with_object` enviando el método `deep_dup` a cada par dentro.

```ruby
hash = { a: 1, b: { c: 2, d: [3, 4] } }

dup = hash.deep_dup
dup[:b][:e] = 5
dup[:b][:d] << 5

hash[:b][:e] == nil      # => true
hash[:b][:d] == [3, 4]   # => true
```

NOTA: Definido en `active_support/core_ext/object/deep_dup.rb`.


### Trabajando con Claves

#### `except` y `except!`

El método [`except`][Hash#except] devuelve un hash con las claves de la lista de argumentos eliminadas, si están presentes:

```ruby
{ a: 1, b: 2 }.except(:a) # => {:b=>2}
```

Si el receptor responde a `convert_key`, se llama al método en cada uno de los argumentos. Esto permite que `except` funcione correctamente con hashes de acceso indiferente, por ejemplo:

```ruby
{ a: 1 }.with_indifferent_access.except(:a)  # => {}
{ a: 1 }.with_indifferent_access.except("a") # => {}
```

También existe la variante con exclamación [`except!`][Hash#except!] que elimina las claves en su lugar.

NOTA: Definido en `active_support/core_ext/hash/except.rb`.


#### `stringify_keys` y `stringify_keys!`

El método [`stringify_keys`][Hash#stringify_keys] devuelve un hash que tiene una versión en forma de cadena de las claves en el receptor. Lo hace enviando `to_s` a ellas:

```ruby
{ nil => nil, 1 => 1, a: :a }.stringify_keys
# => {"" => nil, "1" => 1, "a" => :a}
```

En caso de colisión de claves, el valor será el más recientemente insertado en el hash:

```ruby
{ "a" => 1, a: 2 }.stringify_keys
# El resultado será
# => {"a"=>2}
```
Este método puede ser útil, por ejemplo, para aceptar fácilmente tanto símbolos como cadenas como opciones. Por ejemplo, `ActionView::Helpers::FormHelper` define:

```ruby
def to_check_box_tag(options = {}, checked_value = "1", unchecked_value = "0")
  options = options.stringify_keys
  options["type"] = "checkbox"
  # ...
end
```

La segunda línea puede acceder de forma segura a la clave "type" y permitir al usuario pasar tanto `:type` como "type".

También existe la variante con exclamación [`stringify_keys!`][Hash#stringify_keys!] que convierte las claves en cadenas en su lugar.

Además, se puede utilizar [`deep_stringify_keys`][Hash#deep_stringify_keys] y [`deep_stringify_keys!`][Hash#deep_stringify_keys!] para convertir en cadenas todas las claves del hash dado y todos los hashes anidados en él. Un ejemplo del resultado es:

```ruby
{ nil => nil, 1 => 1, nested: { a: 3, 5 => 5 } }.deep_stringify_keys
# => {""=>nil, "1"=>1, "nested"=>{"a"=>3, "5"=>5}}
```

NOTA: Definido en `active_support/core_ext/hash/keys.rb`.


#### `symbolize_keys` y `symbolize_keys!`

El método [`symbolize_keys`][Hash#symbolize_keys] devuelve un hash que tiene una versión simbolizada de las claves en el receptor, cuando es posible. Lo hace enviando `to_sym` a ellas:

```ruby
{ nil => nil, 1 => 1, "a" => "a" }.symbolize_keys
# => {nil=>nil, 1=>1, :a=>"a"}
```

ADVERTENCIA. Observa que en el ejemplo anterior solo se simbolizó una clave.

En caso de colisión de claves, el valor será el más recientemente insertado en el hash:

```ruby
{ "a" => 1, a: 2 }.symbolize_keys
# => {:a=>2}
```

Este método puede ser útil, por ejemplo, para aceptar fácilmente tanto símbolos como cadenas como opciones. Por ejemplo, `ActionText::TagHelper` define:

```ruby
def rich_text_area_tag(name, value = nil, options = {})
  options = options.symbolize_keys

  options[:input] ||= "trix_input_#{ActionText::TagHelper.id += 1}"
  # ...
end
```

La tercera línea puede acceder de forma segura a la clave `:input` y permitir al usuario pasar tanto `:input` como "input".

También existe la variante con exclamación [`symbolize_keys!`][Hash#symbolize_keys!] que simboliza las claves en su lugar.

Además, se puede utilizar [`deep_symbolize_keys`][Hash#deep_symbolize_keys] y [`deep_symbolize_keys!`][Hash#deep_symbolize_keys!] para simbolizar todas las claves del hash dado y todos los hashes anidados en él. Un ejemplo del resultado es:

```ruby
{ nil => nil, 1 => 1, "nested" => { "a" => 3, 5 => 5 } }.deep_symbolize_keys
# => {nil=>nil, 1=>1, nested:{a:3, 5=>5}}
```

NOTA: Definido en `active_support/core_ext/hash/keys.rb`.


#### `to_options` y `to_options!`

Los métodos [`to_options`][Hash#to_options] y [`to_options!`][Hash#to_options!] son alias de `symbolize_keys` y `symbolize_keys!`, respectivamente.

NOTA: Definido en `active_support/core_ext/hash/keys.rb`.


#### `assert_valid_keys`

El método [`assert_valid_keys`][Hash#assert_valid_keys] recibe un número arbitrario de argumentos y verifica si el receptor tiene alguna clave fuera de esa lista. Si lo hace, se lanza un `ArgumentError`.

```ruby
{ a: 1 }.assert_valid_keys(:a)  # pasa
{ a: 1 }.assert_valid_keys("a") # ArgumentError
```

Active Record no acepta opciones desconocidas al construir asociaciones, por ejemplo. Implementa ese control a través de `assert_valid_keys`.

NOTA: Definido en `active_support/core_ext/hash/keys.rb`.


### Trabajando con Valores

#### `deep_transform_values` y `deep_transform_values!`

El método [`deep_transform_values`][Hash#deep_transform_values] devuelve un nuevo hash con todos los valores convertidos por la operación del bloque. Esto incluye los valores del hash raíz y de todos los hashes y arrays anidados.

```ruby
hash = { person: { name: 'Rob', age: '28' } }

hash.deep_transform_values { |value| value.to_s.upcase }
# => {person: {name: "ROB", age: "28"}}
```

También existe la variante con exclamación [`deep_transform_values!`][Hash#deep_transform_values!] que convierte destructivamente todos los valores utilizando la operación del bloque.

NOTA: Definido en `active_support/core_ext/hash/deep_transform_values.rb`.


### Slicing

El método [`slice!`][Hash#slice!] reemplaza el hash con solo las claves dadas y devuelve un hash que contiene los pares clave/valor eliminados.

```ruby
hash = { a: 1, b: 2 }
rest = hash.slice!(:a) # => {:b=>2}
hash                   # => {:a=>1}
```

NOTA: Definido en `active_support/core_ext/hash/slice.rb`.


### Extracción

El método [`extract!`][Hash#extract!] elimina y devuelve los pares clave/valor que coinciden con las claves dadas.

```ruby
hash = { a: 1, b: 2 }
rest = hash.extract!(:a) # => {:a=>1}
hash                     # => {:b=>2}
```

El método `extract!` devuelve la misma subclase de Hash que el receptor.
```ruby
hash = { a: 1, b: 2 }.with_indifferent_access
rest = hash.extract!(:a).class
# => ActiveSupport::HashWithIndifferentAccess
```

NOTA: Definido en `active_support/core_ext/hash/slice.rb`.


### Acceso indiferente

El método [`with_indifferent_access`][Hash#with_indifferent_access] devuelve un [`ActiveSupport::HashWithIndifferentAccess`][ActiveSupport::HashWithIndifferentAccess] a partir de su receptor:

```ruby
{ a: 1 }.with_indifferent_access["a"] # => 1
```

NOTA: Definido en `active_support/core_ext/hash/indifferent_access.rb`.


Extensiones a `Regexp`
----------------------

### `multiline?`

El método [`multiline?`][Regexp#multiline?] indica si una expresión regular tiene la bandera `/m` establecida, es decir, si el punto coincide con saltos de línea.

```ruby
%r{.}.multiline?  # => false
%r{.}m.multiline? # => true

Regexp.new('.').multiline?                    # => false
Regexp.new('.', Regexp::MULTILINE).multiline? # => true
```

Rails utiliza este método en un solo lugar, también en el código de enrutamiento. Las expresiones regulares de varias líneas no están permitidas para los requisitos de ruta y esta bandera facilita la aplicación de esa restricción.

```ruby
def verify_regexp_requirements(requirements)
  # ...
  if requirement.multiline?
    raise ArgumentError, "La opción multiline de la expresión regular no está permitida en los requisitos de enrutamiento: #{requirement.inspect}"
  end
  # ...
end
```

NOTA: Definido en `active_support/core_ext/regexp.rb`.


Extensiones a `Range`
---------------------

### `to_fs`

Active Support define `Range#to_fs` como una alternativa a `to_s` que entiende un argumento de formato opcional. Hasta la fecha de esta escritura, el único formato no predeterminado compatible es `:db`:

```ruby
(Date.today..Date.tomorrow).to_fs
# => "2009-10-25..2009-10-26"

(Date.today..Date.tomorrow).to_fs(:db)
# => "BETWEEN '2009-10-25' AND '2009-10-26'"
```

Como muestra el ejemplo, el formato `:db` genera una cláusula SQL `BETWEEN`. Esto es utilizado por Active Record en su soporte para valores de rango en condiciones.

NOTA: Definido en `active_support/core_ext/range/conversions.rb`.

### `===` y `include?`

Los métodos `Range#===` y `Range#include?` indican si un valor se encuentra entre los extremos de una instancia dada:

```ruby
(2..3).include?(Math::E) # => true
```

Active Support extiende estos métodos para que el argumento pueda ser otro rango a su vez. En ese caso, se prueba si los extremos del rango del argumento pertenecen al receptor en sí:

```ruby
(1..10) === (3..7)  # => true
(1..10) === (0..7)  # => false
(1..10) === (3..11) # => false
(1...9) === (3..9)  # => false

(1..10).include?(3..7)  # => true
(1..10).include?(0..7)  # => false
(1..10).include?(3..11) # => false
(1...9).include?(3..9)  # => false
```

NOTA: Definido en `active_support/core_ext/range/compare_range.rb`.

### `overlap?`

El método [`Range#overlap?`][Range#overlap?] indica si dos rangos dados tienen una intersección no vacía:

```ruby
(1..10).overlap?(7..11)  # => true
(1..10).overlap?(0..7)   # => true
(1..10).overlap?(11..27) # => false
```

NOTA: Definido en `active_support/core_ext/range/overlap.rb`.


Extensiones a `Date`
--------------------

### Cálculos

INFO: Los siguientes métodos de cálculo tienen casos especiales en octubre de 1582, ya que los días 5..14 simplemente no existen. Esta guía no documenta su comportamiento en torno a esos días por brevedad, pero es suficiente decir que hacen lo que esperarías. Es decir, `Date.new(1582, 10, 4).tomorrow` devuelve `Date.new(1582, 10, 15)` y así sucesivamente. Consulta `test/core_ext/date_ext_test.rb` en el conjunto de pruebas de Active Support para conocer el comportamiento esperado.

#### `Date.current`

Active Support define [`Date.current`][Date.current] como la fecha de hoy en la zona horaria actual. Es similar a `Date.today`, excepto que respeta la zona horaria del usuario, si está definida. También define [`Date.yesterday`][Date.yesterday] y [`Date.tomorrow`][Date.tomorrow], y los predicados de instancia [`past?`][DateAndTime::Calculations#past?], [`today?`][DateAndTime::Calculations#today?], [`tomorrow?`][DateAndTime::Calculations#tomorrow?], [`next_day?`][DateAndTime::Calculations#next_day?], [`yesterday?`][DateAndTime::Calculations#yesterday?], [`prev_day?`][DateAndTime::Calculations#prev_day?], [`future?`][DateAndTime::Calculations#future?], [`on_weekday?`][DateAndTime::Calculations#on_weekday?] y [`on_weekend?`][DateAndTime::Calculations#on_weekend?], todos ellos en relación a `Date.current`.

Cuando se hacen comparaciones de fechas utilizando métodos que respetan la zona horaria del usuario, asegúrate de usar `Date.current` y no `Date.today`. Hay casos en los que la zona horaria del usuario puede estar en el futuro en comparación con la zona horaria del sistema, que es la que utiliza `Date.today` de forma predeterminada. Esto significa que `Date.today` puede ser igual a `Date.yesterday`.

NOTA: Definido en `active_support/core_ext/date/calculations.rb`.


#### Fechas nombradas

##### `beginning_of_week`, `end_of_week`

Los métodos [`beginning_of_week`][DateAndTime::Calculations#beginning_of_week] y [`end_of_week`][DateAndTime::Calculations#end_of_week] devuelven las fechas del inicio y fin de la semana, respectivamente. Se asume que las semanas comienzan el lunes, pero eso se puede cambiar pasando un argumento, estableciendo `Date.beginning_of_week` en el hilo local o [`config.beginning_of_week`][].

```ruby
d = Date.new(2010, 5, 8)     # => Sat, 08 May 2010
d.beginning_of_week          # => Mon, 03 May 2010
d.beginning_of_week(:sunday) # => Sun, 02 May 2010
d.end_of_week                # => Sun, 09 May 2010
d.end_of_week(:sunday)       # => Sat, 08 May 2010
```

`beginning_of_week` se asigna a [`at_beginning_of_week`][DateAndTime::Calculations#at_beginning_of_week] y `end_of_week` se asigna a [`at_end_of_week`][DateAndTime::Calculations#at_end_of_week].

NOTA: Definido en `active_support/core_ext/date_and_time/calculations.rb`.


##### `monday`, `sunday`

Los métodos [`monday`][DateAndTime::Calculations#monday] y [`sunday`][DateAndTime::Calculations#sunday] devuelven las fechas del lunes anterior y del domingo siguiente, respectivamente.

```ruby
d = Date.new(2010, 5, 8)     # => Sat, 08 May 2010
d.monday                     # => Mon, 03 May 2010
d.sunday                     # => Sun, 09 May 2010

d = Date.new(2012, 9, 10)    # => Mon, 10 Sep 2012
d.monday                     # => Mon, 10 Sep 2012

d = Date.new(2012, 9, 16)    # => Sun, 16 Sep 2012
d.sunday                     # => Sun, 16 Sep 2012
```

NOTA: Definido en `active_support/core_ext/date_and_time/calculations.rb`.


##### `prev_week`, `next_week`

El método [`next_week`][DateAndTime::Calculations#next_week] recibe un símbolo con el nombre del día en inglés (por defecto es el [`Date.beginning_of_week`][Date.beginning_of_week] local del hilo, o [`config.beginning_of_week`][], o `:monday`) y devuelve la fecha correspondiente a ese día.

```ruby
d = Date.new(2010, 5, 9) # => Sun, 09 May 2010
d.next_week              # => Mon, 10 May 2010
d.next_week(:saturday)   # => Sat, 15 May 2010
```

El método [`prev_week`][DateAndTime::Calculations#prev_week] es análogo:

```ruby
d.prev_week              # => Mon, 26 Apr 2010
d.prev_week(:saturday)   # => Sat, 01 May 2010
d.prev_week(:friday)     # => Fri, 30 Apr 2010
```

`prev_week` se asigna a [`last_week`][DateAndTime::Calculations#last_week].

Tanto `next_week` como `prev_week` funcionan como se espera cuando `Date.beginning_of_week` o `config.beginning_of_week` están configurados.

NOTA: Definido en `active_support/core_ext/date_and_time/calculations.rb`.


##### `beginning_of_month`, `end_of_month`

Los métodos [`beginning_of_month`][DateAndTime::Calculations#beginning_of_month] y [`end_of_month`][DateAndTime::Calculations#end_of_month] devuelven las fechas del principio y fin del mes:

```ruby
d = Date.new(2010, 5, 9) # => Sun, 09 May 2010
d.beginning_of_month     # => Sat, 01 May 2010
d.end_of_month           # => Mon, 31 May 2010
```

`beginning_of_month` se asigna a [`at_beginning_of_month`][DateAndTime::Calculations#at_beginning_of_month], y `end_of_month` se asigna a [`at_end_of_month`][DateAndTime::Calculations#at_end_of_month].

NOTA: Definido en `active_support/core_ext/date_and_time/calculations.rb`.


##### `quarter`, `beginning_of_quarter`, `end_of_quarter`

El método [`quarter`][DateAndTime::Calculations#quarter] devuelve el trimestre del año calendario del receptor:

```ruby
d = Date.new(2010, 5, 9) # => Sun, 09 May 2010
d.quarter                # => 2
```

Los métodos [`beginning_of_quarter`][DateAndTime::Calculations#beginning_of_quarter] y [`end_of_quarter`][DateAndTime::Calculations#end_of_quarter] devuelven las fechas del principio y fin del trimestre del año calendario del receptor:

```ruby
d = Date.new(2010, 5, 9) # => Sun, 09 May 2010
d.beginning_of_quarter   # => Thu, 01 Apr 2010
d.end_of_quarter         # => Wed, 30 Jun 2010
```

`beginning_of_quarter` se asigna a [`at_beginning_of_quarter`][DateAndTime::Calculations#at_beginning_of_quarter], y `end_of_quarter` se asigna a [`at_end_of_quarter`][DateAndTime::Calculations#at_end_of_quarter].

NOTA: Definido en `active_support/core_ext/date_and_time/calculations.rb`.


##### `beginning_of_year`, `end_of_year`

Los métodos [`beginning_of_year`][DateAndTime::Calculations#beginning_of_year] y [`end_of_year`][DateAndTime::Calculations#end_of_year] devuelven las fechas del principio y fin del año:

```ruby
d = Date.new(2010, 5, 9) # => Sun, 09 May 2010
d.beginning_of_year      # => Fri, 01 Jan 2010
d.end_of_year            # => Fri, 31 Dec 2010
```

`beginning_of_year` se asigna a [`at_beginning_of_year`][DateAndTime::Calculations#at_beginning_of_year], y `end_of_year` se asigna a [`at_end_of_year`][DateAndTime::Calculations#at_end_of_year].

NOTA: Definido en `active_support/core_ext/date_and_time/calculations.rb`.


#### Otras Computaciones de Fecha

##### `years_ago`, `years_since`

El método [`years_ago`][DateAndTime::Calculations#years_ago] recibe un número de años y devuelve la misma fecha hace tantos años:

```ruby
date = Date.new(2010, 6, 7)
date.years_ago(10) # => Wed, 07 Jun 2000
```

[`years_since`][DateAndTime::Calculations#years_since] se mueve hacia adelante en el tiempo:

```ruby
date = Date.new(2010, 6, 7)
date.years_since(10) # => Sun, 07 Jun 2020
```

Si ese día no existe, se devuelve el último día del mes correspondiente:

```ruby
Date.new(2012, 2, 29).years_ago(3)     # => Sat, 28 Feb 2009
Date.new(2012, 2, 29).years_since(3)   # => Sat, 28 Feb 2015
```

[`last_year`][DateAndTime::Calculations#last_year] es una forma abreviada de `#years_ago(1)`.

NOTA: Definido en `active_support/core_ext/date_and_time/calculations.rb`.


##### `months_ago`, `months_since`

Los métodos [`months_ago`][DateAndTime::Calculations#months_ago] y [`months_since`][DateAndTime::Calculations#months_since] funcionan de manera análoga para los meses:

```ruby
Date.new(2010, 4, 30).months_ago(2)   # => Sun, 28 Feb 2010
Date.new(2010, 4, 30).months_since(2) # => Wed, 30 Jun 2010
```

Si ese día no existe, se devuelve el último día del mes correspondiente:

```ruby
Date.new(2010, 4, 30).months_ago(2)    # => Sun, 28 Feb 2010
Date.new(2009, 12, 31).months_since(2) # => Sun, 28 Feb 2010
```

[`last_month`][DateAndTime::Calculations#last_month] es una forma abreviada de `#months_ago(1)`.
NOTA: Definido en `active_support/core_ext/date_and_time/calculations.rb`.


##### `weeks_ago`

El método [`weeks_ago`][DateAndTime::Calculations#weeks_ago] funciona de manera análoga para semanas:

```ruby
Date.new(2010, 5, 24).weeks_ago(1)    # => Mon, 17 May 2010
Date.new(2010, 5, 24).weeks_ago(2)    # => Mon, 10 May 2010
```

NOTA: Definido en `active_support/core_ext/date_and_time/calculations.rb`.


##### `advance`

La forma más genérica de saltar a otros días es [`advance`][Date#advance]. Este método recibe un hash con las claves `:years`, `:months`, `:weeks`, `:days`, y devuelve una fecha avanzada tanto como indiquen las claves presentes:

```ruby
date = Date.new(2010, 6, 6)
date.advance(years: 1, weeks: 2)  # => Mon, 20 Jun 2011
date.advance(months: 2, days: -2) # => Wed, 04 Aug 2010
```

Observa en el ejemplo anterior que los incrementos pueden ser negativos.

NOTA: Definido en `active_support/core_ext/date/calculations.rb`.


#### Cambiar Componentes

El método [`change`][Date#change] te permite obtener una nueva fecha que es igual a la original excepto por el año, mes o día especificado:

```ruby
Date.new(2010, 12, 23).change(year: 2011, month: 11)
# => Wed, 23 Nov 2011
```

Este método no tolera fechas que no existen, si el cambio es inválido se lanzará un `ArgumentError`:

```ruby
Date.new(2010, 1, 31).change(month: 2)
# => ArgumentError: invalid date
```

NOTA: Definido en `active_support/core_ext/date/calculations.rb`.


#### Duraciones

Los objetos [`Duration`][ActiveSupport::Duration] se pueden sumar y restar a fechas:

```ruby
d = Date.current
# => Mon, 09 Aug 2010
d + 1.year
# => Tue, 09 Aug 2011
d - 3.hours
# => Sun, 08 Aug 2010 21:00:00 UTC +00:00
```

Se traducen en llamadas a `since` o `advance`. Por ejemplo, aquí obtenemos el salto correcto en la reforma del calendario:

```ruby
Date.new(1582, 10, 4) + 1.day
# => Fri, 15 Oct 1582
```


#### Marcas de tiempo

INFO: Los siguientes métodos devuelven un objeto `Time` si es posible, de lo contrario un `DateTime`. Si se establece, respetan la zona horaria del usuario.

##### `beginning_of_day`, `end_of_day`

El método [`beginning_of_day`][Date#beginning_of_day] devuelve una marca de tiempo al comienzo del día (00:00:00):

```ruby
date = Date.new(2010, 6, 7)
date.beginning_of_day # => Mon Jun 07 00:00:00 +0200 2010
```

El método [`end_of_day`][Date#end_of_day] devuelve una marca de tiempo al final del día (23:59:59):

```ruby
date = Date.new(2010, 6, 7)
date.end_of_day # => Mon Jun 07 23:59:59 +0200 2010
```

`beginning_of_day` se aliasa a [`at_beginning_of_day`][Date#at_beginning_of_day], [`midnight`][Date#midnight], [`at_midnight`][Date#at_midnight].

NOTA: Definido en `active_support/core_ext/date/calculations.rb`.


##### `beginning_of_hour`, `end_of_hour`

El método [`beginning_of_hour`][DateTime#beginning_of_hour] devuelve una marca de tiempo al comienzo de la hora (hh:00:00):

```ruby
date = DateTime.new(2010, 6, 7, 19, 55, 25)
date.beginning_of_hour # => Mon Jun 07 19:00:00 +0200 2010
```

El método [`end_of_hour`][DateTime#end_of_hour] devuelve una marca de tiempo al final de la hora (hh:59:59):

```ruby
date = DateTime.new(2010, 6, 7, 19, 55, 25)
date.end_of_hour # => Mon Jun 07 19:59:59 +0200 2010
```

`beginning_of_hour` se aliasa a [`at_beginning_of_hour`][DateTime#at_beginning_of_hour].

NOTA: Definido en `active_support/core_ext/date_time/calculations.rb`.

##### `beginning_of_minute`, `end_of_minute`

El método [`beginning_of_minute`][DateTime#beginning_of_minute] devuelve una marca de tiempo al comienzo del minuto (hh:mm:00):

```ruby
date = DateTime.new(2010, 6, 7, 19, 55, 25)
date.beginning_of_minute # => Mon Jun 07 19:55:00 +0200 2010
```

El método [`end_of_minute`][DateTime#end_of_minute] devuelve una marca de tiempo al final del minuto (hh:mm:59):

```ruby
date = DateTime.new(2010, 6, 7, 19, 55, 25)
date.end_of_minute # => Mon Jun 07 19:55:59 +0200 2010
```

`beginning_of_minute` se aliasa a [`at_beginning_of_minute`][DateTime#at_beginning_of_minute].

INFO: `beginning_of_hour`, `end_of_hour`, `beginning_of_minute` y `end_of_minute` están implementados para `Time` y `DateTime` pero **no** para `Date`, ya que no tiene sentido solicitar el comienzo o el final de una hora o minuto en una instancia de `Date`.

NOTA: Definido en `active_support/core_ext/date_time/calculations.rb`.


##### `ago`, `since`

El método [`ago`][Date#ago] recibe un número de segundos como argumento y devuelve una marca de tiempo que corresponde a esa cantidad de segundos antes de la medianoche:

```ruby
date = Date.current # => Fri, 11 Jun 2010
date.ago(1)         # => Thu, 10 Jun 2010 23:59:59 EDT -04:00
```

De manera similar, [`since`][Date#since] avanza en el tiempo:

```ruby
date = Date.current # => Fri, 11 Jun 2010
date.since(1)       # => Fri, 11 Jun 2010 00:00:01 EDT -04:00
```
NOTA: Definido en `active_support/core_ext/date/calculations.rb`.


Extensiones a `DateTime`
------------------------

ADVERTENCIA: `DateTime` no es consciente de las reglas de DST, por lo que algunos de estos métodos tienen casos especiales cuando ocurre un cambio de DST. Por ejemplo, [`seconds_since_midnight`][DateTime#seconds_since_midnight] puede no devolver la cantidad real en ese día.

### Cálculos

La clase `DateTime` es una subclase de `Date`, por lo que al cargar `active_support/core_ext/date/calculations.rb` heredas estos métodos y sus alias, excepto que siempre devolverán datetimes.

Los siguientes métodos se vuelven a implementar para que **no** necesites cargar `active_support/core_ext/date/calculations.rb` para estos:

* [`beginning_of_day`][DateTime#beginning_of_day] / [`midnight`][DateTime#midnight] / [`at_midnight`][DateTime#at_midnight] / [`at_beginning_of_day`][DateTime#at_beginning_of_day]
* [`end_of_day`][DateTime#end_of_day]
* [`ago`][DateTime#ago]
* [`since`][DateTime#since] / [`in`][DateTime#in]

Por otro lado, [`advance`][DateTime#advance] y [`change`][DateTime#change] también están definidos y admiten más opciones, se documentan a continuación.

Los siguientes métodos solo se implementan en `active_support/core_ext/date_time/calculations.rb` ya que solo tienen sentido cuando se usan con una instancia de `DateTime`:

* [`beginning_of_hour`][DateTime#beginning_of_hour] / [`at_beginning_of_hour`][DateTime#at_beginning_of_hour]
* [`end_of_hour`][DateTime#end_of_hour]


#### Datetimes Nombrados

##### `DateTime.current`

Active Support define [`DateTime.current`][DateTime.current] como `Time.now.to_datetime`, excepto que respeta la zona horaria del usuario, si está definida. Los predicados de instancia [`past?`][DateAndTime::Calculations#past?] y [`future?`][DateAndTime::Calculations#future?] se definen en relación a `DateTime.current`.

NOTA: Definido en `active_support/core_ext/date_time/calculations.rb`.


#### Otras Extensiones

##### `seconds_since_midnight`

El método [`seconds_since_midnight`][DateTime#seconds_since_midnight] devuelve el número de segundos desde la medianoche:

```ruby
now = DateTime.current     # => Mon, 07 Jun 2010 20:26:36 +0000
now.seconds_since_midnight # => 73596
```

NOTA: Definido en `active_support/core_ext/date_time/calculations.rb`.


##### `utc`

El método [`utc`][DateTime#utc] te da el mismo datetime en el receptor expresado en UTC.

```ruby
now = DateTime.current # => Mon, 07 Jun 2010 19:27:52 -0400
now.utc                # => Mon, 07 Jun 2010 23:27:52 +0000
```

Este método también se aliasa como [`getutc`][DateTime#getutc].

NOTA: Definido en `active_support/core_ext/date_time/calculations.rb`.


##### `utc?`

El predicado [`utc?`][DateTime#utc?] indica si el receptor tiene UTC como su zona horaria:

```ruby
now = DateTime.now # => Mon, 07 Jun 2010 19:30:47 -0400
now.utc?           # => false
now.utc.utc?       # => true
```

NOTA: Definido en `active_support/core_ext/date_time/calculations.rb`.


##### `advance`

La forma más genérica de saltar a otro datetime es [`advance`][DateTime#advance]. Este método recibe un hash con las claves `:years`, `:months`, `:weeks`, `:days`, `:hours`, `:minutes` y `:seconds`, y devuelve un datetime avanzado tanto como indiquen las claves presentes.

```ruby
d = DateTime.current
# => Thu, 05 Aug 2010 11:33:31 +0000
d.advance(years: 1, months: 1, days: 1, hours: 1, minutes: 1, seconds: 1)
# => Tue, 06 Sep 2011 12:34:32 +0000
```

Este método primero calcula la fecha de destino pasando `:years`, `:months`, `:weeks` y `:days` a `Date#advance` documentado anteriormente. Después de eso, ajusta la hora llamando a [`since`][DateTime#since] con el número de segundos a avanzar. Este orden es relevante, un orden diferente daría diferentes datetimes en algunos casos especiales. Se aplica el ejemplo en `Date#advance`, y podemos extenderlo para mostrar la relevancia del orden relacionado con los bits de tiempo.

Si primero movemos los bits de fecha (que también tienen un orden relativo de procesamiento, como se documentó anteriormente), y luego los bits de tiempo, obtenemos, por ejemplo, el siguiente cálculo:

```ruby
d = DateTime.new(2010, 2, 28, 23, 59, 59)
# => Sun, 28 Feb 2010 23:59:59 +0000
d.advance(months: 1, seconds: 1)
# => Mon, 29 Mar 2010 00:00:00 +0000
```

pero si los calculamos al revés, el resultado sería diferente:

```ruby
d.advance(seconds: 1).advance(months: 1)
# => Thu, 01 Apr 2010 00:00:00 +0000
```

ADVERTENCIA: Como `DateTime` no es consciente de DST, puedes terminar en un punto en el tiempo que no existe sin ninguna advertencia o error que te lo indique.

NOTA: Definido en `active_support/core_ext/date_time/calculations.rb`.


#### Cambiar Componentes

El método [`change`][DateTime#change] te permite obtener un nuevo datetime que es igual al receptor excepto por las opciones dadas, que pueden incluir `:year`, `:month`, `:day`, `:hour`, `:min`, `:sec`, `:offset`, `:start`:

```ruby
now = DateTime.current
# => Tue, 08 Jun 2010 01:56:22 +0000
now.change(year: 2011, offset: Rational(-6, 24))
# => Wed, 08 Jun 2011 01:56:22 -0600
```
Si las horas se establecen en cero, entonces los minutos y segundos también se establecen en cero (a menos que tengan valores dados):

```ruby
now.change(hour: 0)
# => Tue, 08 Jun 2010 00:00:00 +0000
```

De manera similar, si los minutos se establecen en cero, entonces los segundos también se establecen en cero (a menos que se haya dado un valor):

```ruby
now.change(min: 0)
# => Tue, 08 Jun 2010 01:00:00 +0000
```

Este método no es tolerante a fechas que no existen, si el cambio es inválido se genera un `ArgumentError`:

```ruby
DateTime.current.change(month: 2, day: 30)
# => ArgumentError: fecha inválida
```

NOTA: Definido en `active_support/core_ext/date_time/calculations.rb`.


#### Duraciones

Los objetos [`Duration`][ActiveSupport::Duration] se pueden sumar y restar a datetimes:

```ruby
now = DateTime.current
# => Mon, 09 Aug 2010 23:15:17 +0000
now + 1.year
# => Tue, 09 Aug 2011 23:15:17 +0000
now - 1.week
# => Mon, 02 Aug 2010 23:15:17 +0000
```

Se traducen en llamadas a `since` o `advance`. Por ejemplo, aquí obtenemos el salto correcto en la reforma del calendario:

```ruby
DateTime.new(1582, 10, 4, 23) + 1.hour
# => Fri, 15 Oct 1582 00:00:00 +0000
```

Extensiones a `Time`
--------------------

### Cálculos

Son análogos. Por favor, consulte su documentación anterior y tenga en cuenta las siguientes diferencias:

* [`change`][Time#change] acepta una opción adicional `:usec`.
* `Time` entiende DST, por lo que se obtienen cálculos DST correctos como en

```ruby
Time.zone_default
# => #<ActiveSupport::TimeZone:0x7f73654d4f38 @utc_offset=nil, @name="Madrid", ...>

# En Barcelona, el 28/03/2010 02:00 +0100 se convierte en 28/03/2010 03:00 +0200 debido a DST.
t = Time.local(2010, 3, 28, 1, 59, 59)
# => Sun Mar 28 01:59:59 +0100 2010
t.advance(seconds: 1)
# => Sun Mar 28 03:00:00 +0200 2010
```

* Si [`since`][Time#since] o [`ago`][Time#ago] salta a un tiempo que no se puede expresar con `Time`, se devuelve un objeto `DateTime` en su lugar.


#### `Time.current`

Active Support define [`Time.current`][Time.current] como hoy en la zona horaria actual. Es como `Time.now`, excepto que respeta la zona horaria del usuario, si está definida. También define los predicados de instancia [`past?`][DateAndTime::Calculations#past?], [`today?`][DateAndTime::Calculations#today?], [`tomorrow?`][DateAndTime::Calculations#tomorrow?], [`next_day?`][DateAndTime::Calculations#next_day?], [`yesterday?`][DateAndTime::Calculations#yesterday?], [`prev_day?`][DateAndTime::Calculations#prev_day?] y [`future?`][DateAndTime::Calculations#future?], todos ellos relativos a `Time.current`.

Cuando se realizan comparaciones de tiempo utilizando métodos que respetan la zona horaria del usuario, asegúrese de usar `Time.current` en lugar de `Time.now`. Hay casos en los que la zona horaria del usuario puede estar en el futuro en comparación con la zona horaria del sistema, que `Time.now` utiliza de forma predeterminada. Esto significa que `Time.now.to_date` puede ser igual a `Date.yesterday`.

NOTA: Definido en `active_support/core_ext/time/calculations.rb`.


#### `all_day`, `all_week`, `all_month`, `all_quarter` y `all_year`

El método [`all_day`][DateAndTime::Calculations#all_day] devuelve un rango que representa todo el día del tiempo actual.

```ruby
now = Time.current
# => Mon, 09 Aug 2010 23:20:05 UTC +00:00
now.all_day
# => Mon, 09 Aug 2010 00:00:00 UTC +00:00..Mon, 09 Aug 2010 23:59:59 UTC +00:00
```

De manera análoga, [`all_week`][DateAndTime::Calculations#all_week], [`all_month`][DateAndTime::Calculations#all_month], [`all_quarter`][DateAndTime::Calculations#all_quarter] y [`all_year`][DateAndTime::Calculations#all_year] sirven para generar rangos de tiempo.

```ruby
now = Time.current
# => Mon, 09 Aug 2010 23:20:05 UTC +00:00
now.all_week
# => Mon, 09 Aug 2010 00:00:00 UTC +00:00..Sun, 15 Aug 2010 23:59:59 UTC +00:00
now.all_week(:sunday)
# => Sun, 16 Sep 2012 00:00:00 UTC +00:00..Sat, 22 Sep 2012 23:59:59 UTC +00:00
now.all_month
# => Sat, 01 Aug 2010 00:00:00 UTC +00:00..Tue, 31 Aug 2010 23:59:59 UTC +00:00
now.all_quarter
# => Thu, 01 Jul 2010 00:00:00 UTC +00:00..Thu, 30 Sep 2010 23:59:59 UTC +00:00
now.all_year
# => Fri, 01 Jan 2010 00:00:00 UTC +00:00..Fri, 31 Dec 2010 23:59:59 UTC +00:00
```

NOTA: Definido en `active_support/core_ext/date_and_time/calculations.rb`.


#### `prev_day`, `next_day`

[`prev_day`][Time#prev_day] y [`next_day`][Time#next_day] devuelven el tiempo en el día anterior o siguiente:

```ruby
t = Time.new(2010, 5, 8) # => 2010-05-08 00:00:00 +0900
t.prev_day               # => 2010-05-07 00:00:00 +0900
t.next_day               # => 2010-05-09 00:00:00 +0900
```

NOTA: Definido en `active_support/core_ext/time/calculations.rb`.


#### `prev_month`, `next_month`

[`prev_month`][Time#prev_month] y [`next_month`][Time#next_month] devuelven el tiempo con el mismo día en el mes anterior o siguiente:
```ruby
t = Time.new(2010, 5, 8) # => 2010-05-08 00:00:00 +0900
t.prev_month             # => 2010-04-08 00:00:00 +0900
t.next_month             # => 2010-06-08 00:00:00 +0900
```

Si ese día no existe, se devuelve el último día del mes correspondiente:

```ruby
Time.new(2000, 5, 31).prev_month # => 2000-04-30 00:00:00 +0900
Time.new(2000, 3, 31).prev_month # => 2000-02-29 00:00:00 +0900
Time.new(2000, 5, 31).next_month # => 2000-06-30 00:00:00 +0900
Time.new(2000, 1, 31).next_month # => 2000-02-29 00:00:00 +0900
```

NOTA: Definido en `active_support/core_ext/time/calculations.rb`.


#### `prev_year`, `next_year`

[`prev_year`][Time#prev_year] y [`next_year`][Time#next_year] devuelven una fecha con el mismo día/mes en el año anterior o siguiente:

```ruby
t = Time.new(2010, 5, 8) # => 2010-05-08 00:00:00 +0900
t.prev_year              # => 2009-05-08 00:00:00 +0900
t.next_year              # => 2011-05-08 00:00:00 +0900
```

Si la fecha es el 29 de febrero de un año bisiesto, se obtiene el 28:

```ruby
t = Time.new(2000, 2, 29) # => 2000-02-29 00:00:00 +0900
t.prev_year               # => 1999-02-28 00:00:00 +0900
t.next_year               # => 2001-02-28 00:00:00 +0900
```

NOTA: Definido en `active_support/core_ext/time/calculations.rb`.


#### `prev_quarter`, `next_quarter`

[`prev_quarter`][DateAndTime::Calculations#prev_quarter] y [`next_quarter`][DateAndTime::Calculations#next_quarter] devuelven la fecha con el mismo día en el trimestre anterior o siguiente:

```ruby
t = Time.local(2010, 5, 8) # => 2010-05-08 00:00:00 +0300
t.prev_quarter             # => 2010-02-08 00:00:00 +0200
t.next_quarter             # => 2010-08-08 00:00:00 +0300
```

Si ese día no existe, se devuelve el último día del mes correspondiente:

```ruby
Time.local(2000, 7, 31).prev_quarter  # => 2000-04-30 00:00:00 +0300
Time.local(2000, 5, 31).prev_quarter  # => 2000-02-29 00:00:00 +0200
Time.local(2000, 10, 31).prev_quarter # => 2000-07-31 00:00:00 +0300
Time.local(2000, 11, 31).next_quarter # => 2001-03-01 00:00:00 +0200
```

`prev_quarter` se define como un alias de [`last_quarter`][DateAndTime::Calculations#last_quarter].

NOTA: Definido en `active_support/core_ext/date_and_time/calculations.rb`.


### Constructores de Tiempo

Active Support define [`Time.current`][Time.current] como `Time.zone.now` si hay una zona horaria de usuario definida, con fallback a `Time.now`:

```ruby
Time.zone_default
# => #<ActiveSupport::TimeZone:0x7f73654d4f38 @utc_offset=nil, @name="Madrid", ...>
Time.current
# => Fri, 06 Aug 2010 17:11:58 CEST +02:00
```

Análogamente a `DateTime`, los predicados [`past?`][DateAndTime::Calculations#past?] y [`future?`][DateAndTime::Calculations#future?] son relativos a `Time.current`.

Si el tiempo a construir está fuera del rango soportado por `Time` en la plataforma de ejecución, los microsegundos se descartan y se devuelve un objeto `DateTime` en su lugar.

#### Duraciones

Se pueden sumar y restar objetos [`Duration`][ActiveSupport::Duration] a objetos de tiempo:

```ruby
now = Time.current
# => Mon, 09 Aug 2010 23:20:05 UTC +00:00
now + 1.year
# => Tue, 09 Aug 2011 23:21:11 UTC +00:00
now - 1.week
# => Mon, 02 Aug 2010 23:21:11 UTC +00:00
```

Se traducen en llamadas a `since` o `advance`. Por ejemplo, aquí obtenemos el salto correcto en la reforma del calendario:

```ruby
Time.utc(1582, 10, 3) + 5.days
# => Mon Oct 18 00:00:00 UTC 1582
```

Extensiones a `File`
--------------------

### `atomic_write`

Con el método de clase [`File.atomic_write`][File.atomic_write] se puede escribir en un archivo de una manera que evite que cualquier lector vea contenido medio escrito.

El nombre del archivo se pasa como argumento y el método cede un manejador de archivo abierto para escribir. Una vez que el bloque se completa, `atomic_write` cierra el manejador de archivo y completa su trabajo.

Por ejemplo, Action Pack utiliza este método para escribir archivos de caché de activos como `all.css`:

```ruby
File.atomic_write(joined_asset_path) do |cache|
  cache.write(join_asset_file_contents(asset_paths))
end
```

Para lograr esto, `atomic_write` crea un archivo temporal. Ese es el archivo al que el código en el bloque realmente escribe. Al completarse, el archivo temporal se renombra, lo cual es una operación atómica en sistemas POSIX. Si el archivo de destino existe, `atomic_write` lo sobrescribe y mantiene los propietarios y permisos. Sin embargo, hay algunos casos en los que `atomic_write` no puede cambiar la propiedad o los permisos del archivo, este error se captura y se salta, confiando en el usuario/sistema de archivos para asegurarse de que el archivo sea accesible para los procesos que lo necesiten.

NOTA. Debido a la operación chmod que realiza `atomic_write`, si el archivo de destino tiene un ACL establecido en él, este ACL se recalculará/modificará.
```
ADVERTENCIA. Tenga en cuenta que no se puede agregar con `atomic_write`.

El archivo auxiliar se escribe en un directorio estándar para archivos temporales, pero puede pasar un directorio de su elección como segundo argumento.

NOTA: Definido en `active_support/core_ext/file/atomic.rb`.


Extensiones a `NameError`
-------------------------

Active Support agrega [`missing_name?`][NameError#missing_name?] a `NameError`, que prueba si la excepción se produjo debido al nombre pasado como argumento.

El nombre puede ser dado como un símbolo o una cadena. Un símbolo se prueba contra el nombre constante sin formato, una cadena se prueba contra el nombre constante completamente calificado.

CONSEJO: Un símbolo puede representar un nombre constante completamente calificado como en `:"ActiveRecord::Base"`, por lo que el comportamiento para los símbolos está definido por conveniencia, no porque tenga que ser así técnicamente.

Por ejemplo, cuando se llama a una acción de `ArticlesController`, Rails intenta usar optimistamente `ArticlesHelper`. Está bien que el módulo de ayuda no exista, por lo que si se genera una excepción para ese nombre constante, debe ser silenciada. Pero podría ser el caso de que `articles_helper.rb` genere un `NameError` debido a una constante desconocida real. Eso debería ser relanzado. El método `missing_name?` proporciona una forma de distinguir ambos casos:

```ruby
def default_helper_module!
  module_name = name.delete_suffix("Controller")
  module_path = module_name.underscore
  helper module_path
rescue LoadError => e
  raise e unless e.is_missing? "helpers/#{module_path}_helper"
rescue NameError => e
  raise e unless e.missing_name? "#{module_name}Helper"
end
```

NOTA: Definido en `active_support/core_ext/name_error.rb`.


Extensiones a `LoadError`
-------------------------

Active Support agrega [`is_missing?`][LoadError#is_missing?] a `LoadError`.

Dado un nombre de ruta, `is_missing?` prueba si la excepción se generó debido a ese archivo en particular (excepto tal vez por la extensión ".rb").

Por ejemplo, cuando se llama a una acción de `ArticlesController`, Rails intenta cargar `articles_helper.rb`, pero ese archivo puede no existir. Eso está bien, el módulo de ayuda no es obligatorio, por lo que Rails silencia un error de carga. Pero podría ser el caso de que el módulo de ayuda exista y, a su vez, requiera otra biblioteca que falte. En ese caso, Rails debe relanzar la excepción. El método `is_missing?` proporciona una forma de distinguir ambos casos:

```ruby
def default_helper_module!
  module_name = name.delete_suffix("Controller")
  module_path = module_name.underscore
  helper module_path
rescue LoadError => e
  raise e unless e.is_missing? "helpers/#{module_path}_helper"
rescue NameError => e
  raise e unless e.missing_name? "#{module_name}Helper"
end
```

NOTA: Definido en `active_support/core_ext/load_error.rb`.


Extensiones a Pathname
-------------------------

### `existence`

El método [`existence`][Pathname#existence] devuelve el receptor si el archivo con el nombre especificado existe, de lo contrario devuelve `nil`. Es útil para idiomatismos como este:

```ruby
content = Pathname.new("file").existence&.read
```

NOTA: Definido en `active_support/core_ext/pathname/existence.rb`.
[`config.active_support.bare`]: configuring.html#config-active-support-bare
[Object#blank?]: https://api.rubyonrails.org/classes/Object.html#method-i-blank-3F
[Object#present?]: https://api.rubyonrails.org/classes/Object.html#method-i-present-3F
[Object#presence]: https://api.rubyonrails.org/classes/Object.html#method-i-presence
[Object#duplicable?]: https://api.rubyonrails.org/classes/Object.html#method-i-duplicable-3F
[Object#deep_dup]: https://api.rubyonrails.org/classes/Object.html#method-i-deep_dup
[Object#try]: https://api.rubyonrails.org/classes/Object.html#method-i-try
[Object#try!]: https://api.rubyonrails.org/classes/Object.html#method-i-try-21
[Kernel#class_eval]: https://api.rubyonrails.org/classes/Kernel.html#method-i-class_eval
[Object#acts_like?]: https://api.rubyonrails.org/classes/Object.html#method-i-acts_like-3F
[Array#to_param]: https://api.rubyonrails.org/classes/Array.html#method-i-to_param
[Object#to_param]: https://api.rubyonrails.org/classes/Object.html#method-i-to_param
[Hash#to_query]: https://api.rubyonrails.org/classes/Hash.html#method-i-to_query
[Object#to_query]: https://api.rubyonrails.org/classes/Object.html#method-i-to_query
[Object#with_options]: https://api.rubyonrails.org/classes/Object.html#method-i-with_options
[Object#instance_values]: https://api.rubyonrails.org/classes/Object.html#method-i-instance_values
[Object#instance_variable_names]: https://api.rubyonrails.org/classes/Object.html#method-i-instance_variable_names
[Kernel#enable_warnings]: https://api.rubyonrails.org/classes/Kernel.html#method-i-enable_warnings
[Kernel#silence_warnings]: https://api.rubyonrails.org/classes/Kernel.html#method-i-silence_warnings
[Kernel#suppress]: https://api.rubyonrails.org/classes/Kernel.html#method-i-suppress
[Object#in?]: https://api.rubyonrails.org/classes/Object.html#method-i-in-3F
[Module#alias_attribute]: https://api.rubyonrails.org/classes/Module.html#method-i-alias_attribute
[Module#attr_internal]: https://api.rubyonrails.org/classes/Module.html#method-i-attr_internal
[Module#attr_internal_accessor]: https://api.rubyonrails.org/classes/Module.html#method-i-attr_internal_accessor
[Module#attr_internal_reader]: https://api.rubyonrails.org/classes/Module.html#method-i-attr_internal_reader
[Module#attr_internal_writer]: https://api.rubyonrails.org/classes/Module.html#method-i-attr_internal_writer
[Module#mattr_accessor]: https://api.rubyonrails.org/classes/Module.html#method-i-mattr_accessor
[Module#mattr_reader]: https://api.rubyonrails.org/classes/Module.html#method-i-mattr_reader
[Module#mattr_writer]: https://api.rubyonrails.org/classes/Module.html#method-i-mattr_writer
[Module#module_parent]: https://api.rubyonrails.org/classes/Module.html#method-i-module_parent
[Module#module_parent_name]: https://api.rubyonrails.org/classes/Module.html#method-i-module_parent_name
[Module#module_parents]: https://api.rubyonrails.org/classes/Module.html#method-i-module_parents
[Module#anonymous?]: https://api.rubyonrails.org/classes/Module.html#method-i-anonymous-3F
[Module#delegate]: https://api.rubyonrails.org/classes/Module.html#method-i-delegate
[Module#delegate_missing_to]: https://api.rubyonrails.org/classes/Module.html#method-i-delegate_missing_to
[Module#redefine_method]: https://api.rubyonrails.org/classes/Module.html#method-i-redefine_method
[Module#silence_redefinition_of_method]: https://api.rubyonrails.org/classes/Module.html#method-i-silence_redefinition_of_method
[Class#class_attribute]: https://api.rubyonrails.org/classes/Class.html#method-i-class_attribute
[Module#cattr_accessor]: https://api.rubyonrails.org/classes/Module.html#method-i-cattr_accessor
[Module#cattr_reader]: https://api.rubyonrails.org/classes/Module.html#method-i-cattr_reader
[Module#cattr_writer]: https://api.rubyonrails.org/classes/Module.html#method-i-cattr_writer
[Class#subclasses]: https://api.rubyonrails.org/classes/Class.html#method-i-subclasses
[Class#descendants]: https://api.rubyonrails.org/classes/Class.html#method-i-descendants
[`raw`]: https://api.rubyonrails.org/classes/ActionView/Helpers/OutputSafetyHelper.html#method-i-raw
[String#html_safe]: https://api.rubyonrails.org/classes/String.html#method-i-html_safe
[String#remove]: https://api.rubyonrails.org/classes/String.html#method-i-remove
[String#squish]: https://api.rubyonrails.org/classes/String.html#method-i-squish
[String#truncate]: https://api.rubyonrails.org/classes/String.html#method-i-truncate
[String#truncate_bytes]: https://api.rubyonrails.org/classes/String.html#method-i-truncate_bytes
[String#truncate_words]: https://api.rubyonrails.org/classes/String.html#method-i-truncate_words
[String#inquiry]: https://api.rubyonrails.org/classes/String.html#method-i-inquiry
[String#strip_heredoc]: https://api.rubyonrails.org/classes/String.html#method-i-strip_heredoc
[String#indent!]: https://api.rubyonrails.org/classes/String.html#method-i-indent-21
[String#indent]: https://api.rubyonrails.org/classes/String.html#method-i-indent
[String#at]: https://api.rubyonrails.org/classes/String.html#method-i-at
[String#from]: https://api.rubyonrails.org/classes/String.html#method-i-from
[String#to]: https://api.rubyonrails.org/classes/String.html#method-i-to
[String#first]: https://api.rubyonrails.org/classes/String.html#method-i-first
[String#last]: https://api.rubyonrails.org/classes/String.html#method-i-last
[String#pluralize]: https://api.rubyonrails.org/classes/String.html#method-i-pluralize
[String#singularize]: https://api.rubyonrails.org/classes/String.html#method-i-singularize
[String#camelcase]: https://api.rubyonrails.org/classes/String.html#method-i-camelcase
[String#camelize]: https://api.rubyonrails.org/classes/String.html#method-i-camelize
[String#underscore]: https://api.rubyonrails.org/classes/String.html#method-i-underscore
[String#titlecase]: https://api.rubyonrails.org/classes/String.html#method-i-titlecase
[String#titleize]: https://api.rubyonrails.org/classes/String.html#method-i-titleize
[String#dasherize]: https://api.rubyonrails.org/classes/String.html#method-i-dasherize
[String#demodulize]: https://api.rubyonrails.org/classes/String.html#method-i-demodulize
[String#deconstantize]: https://api.rubyonrails.org/classes/String.html#method-i-deconstantize
[String#parameterize]: https://api.rubyonrails.org/classes/String.html#method-i-parameterize
[String#tableize]: https://api.rubyonrails.org/classes/String.html#method-i-tableize
[String#classify]: https://api.rubyonrails.org/classes/String.html#method-i-classify
[String#constantize]: https://api.rubyonrails.org/classes/String.html#method-i-constantize
[String#humanize]: https://api.rubyonrails.org/classes/String.html#method-i-humanize
[String#foreign_key]: https://api.rubyonrails.org/classes/String.html#method-i-foreign_key
[String#upcase_first]: https://api.rubyonrails.org/classes/String.html#method-i-upcase_first
[String#downcase_first]: https://api.rubyonrails.org/classes/String.html#method-i-downcase_first
[String#to_date]: https://api.rubyonrails.org/classes/String.html#method-i-to_date
[String#to_datetime]: https://api.rubyonrails.org/classes/String.html#method-i-to_datetime
[String#to_time]: https://api.rubyonrails.org/classes/String.html#method-i-to_time
[Numeric#bytes]: https://api.rubyonrails.org/classes/Numeric.html#method-i-bytes
[Numeric#exabytes]: https://api.rubyonrails.org/classes/Numeric.html#method-i-exabytes
[Numeric#gigabytes]: https://api.rubyonrails.org/classes/Numeric.html#method-i-gigabytes
[Numeric#kilobytes]: https://api.rubyonrails.org/classes/Numeric.html#method-i-kilobytes
[Numeric#megabytes]: https://api.rubyonrails.org/classes/Numeric.html#method-i-megabytes
[Numeric#petabytes]: https://api.rubyonrails.org/classes/Numeric.html#method-i-petabytes
[Numeric#terabytes]: https://api.rubyonrails.org/classes/Numeric.html#method-i-terabytes
[Duration#ago]: https://api.rubyonrails.org/classes/ActiveSupport/Duration.html#method-i-ago
[Duration#from_now]: https://api.rubyonrails.org/classes/ActiveSupport/Duration.html#method-i-from_now
[Numeric#days]: https://api.rubyonrails.org/classes/Numeric.html#method-i-days
[Numeric#fortnights]: https://api.rubyonrails.org/classes/Numeric.html#method-i-fortnights
[Numeric#hours]: https://api.rubyonrails.org/classes/Numeric.html#method-i-hours
[Numeric#minutes]: https://api.rubyonrails.org/classes/Numeric.html#method-i-minutes
[Numeric#seconds]: https://api.rubyonrails.org/classes/Numeric.html#method-i-seconds
[Numeric#weeks]: https://api.rubyonrails.org/classes/Numeric.html#method-i-weeks
[Integer#multiple_of?]: https://api.rubyonrails.org/classes/Integer.html#method-i-multiple_of-3F
[Integer#ordinal]: https://api.rubyonrails.org/classes/Integer.html#method-i-ordinal
[Integer#ordinalize]: https://api.rubyonrails.org/classes/Integer.html#method-i-ordinalize
[Integer#months]: https://api.rubyonrails.org/classes/Integer.html#method-i-months
[Integer#years]: https://api.rubyonrails.org/classes/Integer.html#method-i-years
[Enumerable#sum]: https://api.rubyonrails.org/classes/Enumerable.html#method-i-sum
[Enumerable#index_by]: https://api.rubyonrails.org/classes/Enumerable.html#method-i-index_by
[Enumerable#index_with]: https://api.rubyonrails.org/classes/Enumerable.html#method-i-index_with
[Enumerable#many?]: https://api.rubyonrails.org/classes/Enumerable.html#method-i-many-3F
[Enumerable#exclude?]: https://api.rubyonrails.org/classes/Enumerable.html#method-i-exclude-3F
[Enumerable#including]: https://api.rubyonrails.org/classes/Enumerable.html#method-i-including
[Enumerable#excluding]: https://api.rubyonrails.org/classes/Enumerable.html#method-i-excluding
[Enumerable#without]: https://api.rubyonrails.org/classes/Enumerable.html#method-i-without
[Enumerable#pluck]: https://api.rubyonrails.org/classes/Enumerable.html#method-i-pluck
[Enumerable#pick]: https://api.rubyonrails.org/classes/Enumerable.html#method-i-pick
[Array#excluding]: https://api.rubyonrails.org/classes/Array.html#method-i-excluding
[Array#fifth]: https://api.rubyonrails.org/classes/Array.html#method-i-fifth
[Array#forty_two]: https://api.rubyonrails.org/classes/Array.html#method-i-forty_two
[Array#fourth]: https://api.rubyonrails.org/classes/Array.html#method-i-fourth
[Array#from]: https://api.rubyonrails.org/classes/Array.html#method-i-from
[Array#including]: https://api.rubyonrails.org/classes/Array.html#method-i-including
[Array#second]: https://api.rubyonrails.org/classes/Array.html#method-i-second
[Array#second_to_last]: https://api.rubyonrails.org/classes/Array.html#method-i-second_to_last
[Array#third]: https://api.rubyonrails.org/classes/Array.html#method-i-third
[Array#third_to_last]: https://api.rubyonrails.org/classes/Array.html#method-i-third_to_last
[Array#to]: https://api.rubyonrails.org/classes/Array.html#method-i-to
[Array#extract!]: https://api.rubyonrails.org/classes/Array.html#method-i-extract-21
[Array#extract_options!]: https://api.rubyonrails.org/classes/Array.html#method-i-extract_options-21
[Array#to_sentence]: https://api.rubyonrails.org/classes/Array.html#method-i-to_sentence
[Array#to_fs]: https://api.rubyonrails.org/classes/Array.html#method-i-to_fs
[Array#to_xml]: https://api.rubyonrails.org/classes/Array.html#method-i-to_xml
[Array.wrap]: https://api.rubyonrails.org/classes/Array.html#method-c-wrap
[Array#deep_dup]: https://api.rubyonrails.org/classes/Array.html#method-i-deep_dup
[Array#in_groups_of]: https://api.rubyonrails.org/classes/Array.html#method-i-in_groups_of
[Array#in_groups]: https://api.rubyonrails.org/classes/Array.html#method-i-in_groups
[Array#split]: https://api.rubyonrails.org/classes/Array.html#method-i-split
[Hash#to_xml]: https://api.rubyonrails.org/classes/Hash.html#method-i-to_xml
[Hash#reverse_merge!]: https://api.rubyonrails.org/classes/Hash.html#method-i-reverse_merge-21
[Hash#reverse_merge]: https://api.rubyonrails.org/classes/Hash.html#method-i-reverse_merge
[Hash#reverse_update]: https://api.rubyonrails.org/classes/Hash.html#method-i-reverse_update
[Hash#deep_merge!]: https://api.rubyonrails.org/classes/Hash.html#method-i-deep_merge-21
[Hash#deep_merge]: https://api.rubyonrails.org/classes/Hash.html#method-i-deep_merge
[Hash#deep_dup]: https://api.rubyonrails.org/classes/Hash.html#method-i-deep_dup
[Hash#except!]: https://api.rubyonrails.org/classes/Hash.html#method-i-except-21
[Hash#except]: https://api.rubyonrails.org/classes/Hash.html#method-i-except
[Hash#deep_stringify_keys!]: https://api.rubyonrails.org/classes/Hash.html#method-i-deep_stringify_keys-21
[Hash#deep_stringify_keys]: https://api.rubyonrails.org/classes/Hash.html#method-i-deep_stringify_keys
[Hash#stringify_keys!]: https://api.rubyonrails.org/classes/Hash.html#method-i-stringify_keys-21
[Hash#stringify_keys]: https://api.rubyonrails.org/classes/Hash.html#method-i-stringify_keys
[Hash#deep_symbolize_keys!]: https://api.rubyonrails.org/classes/Hash.html#method-i-deep_symbolize_keys-21
[Hash#deep_symbolize_keys]: https://api.rubyonrails.org/classes/Hash.html#method-i-deep_symbolize_keys
[Hash#symbolize_keys!]: https://api.rubyonrails.org/classes/Hash.html#method-i-symbolize_keys-21
[Hash#symbolize_keys]: https://api.rubyonrails.org/classes/Hash.html#method-i-symbolize_keys
[Hash#to_options!]: https://api.rubyonrails.org/classes/Hash.html#method-i-to_options-21
[Hash#to_options]: https://api.rubyonrails.org/classes/Hash.html#method-i-to_options
[Hash#assert_valid_keys]: https://api.rubyonrails.org/classes/Hash.html#method-i-assert_valid_keys
[Hash#deep_transform_values!]: https://api.rubyonrails.org/classes/Hash.html#method-i-deep_transform_values-21
[Hash#deep_transform_values]: https://api.rubyonrails.org/classes/Hash.html#method-i-deep_transform_values
[Hash#slice!]: https://api.rubyonrails.org/classes/Hash.html#method-i-slice-21
[Hash#extract!]: https://api.rubyonrails.org/classes/Hash.html#method-i-extract-21
[ActiveSupport::HashWithIndifferentAccess]: https://api.rubyonrails.org/classes/ActiveSupport/HashWithIndifferentAccess.html
[Hash#with_indifferent_access]: https://api.rubyonrails.org/classes/Hash.html#method-i-with_indifferent_access
[Regexp#multiline?]: https://api.rubyonrails.org/classes/Regexp.html#method-i-multiline-3F
[Range#overlap?]: https://api.rubyonrails.org/classes/Range.html#method-i-overlaps-3F
[Date.current]: https://api.rubyonrails.org/classes/Date.html#method-c-current
[Date.tomorrow]: https://api.rubyonrails.org/classes/Date.html#method-c-tomorrow
[Date.yesterday]: https://api.rubyonrails.org/classes/Date.html#method-c-yesterday
[DateAndTime::Calculations#future?]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-future-3F
[DateAndTime::Calculations#on_weekday?]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-on_weekday-3F
[DateAndTime::Calculations#on_weekend?]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-on_weekend-3F
[DateAndTime::Calculations#past?]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-past-3F
[`config.beginning_of_week`]: configuring.html#config-beginning-of-week
[DateAndTime::Calculations#at_beginning_of_week]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-at_beginning_of_week
[DateAndTime::Calculations#at_end_of_week]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-at_end_of_week
[DateAndTime::Calculations#beginning_of_week]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-beginning_of_week
[DateAndTime::Calculations#end_of_week]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-end_of_week
[DateAndTime::Calculations#monday]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-monday
[DateAndTime::Calculations#sunday]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-sunday
[Date.beginning_of_week]: https://api.rubyonrails.org/classes/Date.html#method-c-beginning_of_week
[DateAndTime::Calculations#last_week]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-last_week
[DateAndTime::Calculations#next_week]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-next_week
[DateAndTime::Calculations#prev_week]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-prev_week
[DateAndTime::Calculations#at_beginning_of_month]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-at_beginning_of_month
[DateAndTime::Calculations#at_end_of_month]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-at_end_of_month
[DateAndTime::Calculations#beginning_of_month]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-beginning_of_month
[DateAndTime::Calculations#end_of_month]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-end_of_month
[DateAndTime::Calculations#quarter]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-quarter
[DateAndTime::Calculations#at_beginning_of_quarter]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-at_beginning_of_quarter
[DateAndTime::Calculations#at_end_of_quarter]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-at_end_of_quarter
[DateAndTime::Calculations#beginning_of_quarter]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-beginning_of_quarter
[DateAndTime::Calculations#end_of_quarter]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-end_of_quarter
[DateAndTime::Calculations#at_beginning_of_year]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-at_beginning_of_year
[DateAndTime::Calculations#at_end_of_year]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-at_end_of_year
[DateAndTime::Calculations#beginning_of_year]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-beginning_of_year
[DateAndTime::Calculations#end_of_year]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-end_of_year
[DateAndTime::Calculations#last_year]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-last_year
[DateAndTime::Calculations#years_ago]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-years_ago
[DateAndTime::Calculations#years_since]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-years_since
[DateAndTime::Calculations#last_month]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-last_month
[DateAndTime::Calculations#months_ago]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-months_ago
[DateAndTime::Calculations#months_since]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-months_since
[DateAndTime::Calculations#weeks_ago]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-weeks_ago
[Date#advance]: https://api.rubyonrails.org/classes/Date.html#method-i-advance
[Date#change]: https://api.rubyonrails.org/classes/Date.html#method-i-change
[ActiveSupport::Duration]: https://api.rubyonrails.org/classes/ActiveSupport/Duration.html
[Date#at_beginning_of_day]: https://api.rubyonrails.org/classes/Date.html#method-i-at_beginning_of_day
[Date#at_midnight]: https://api.rubyonrails.org/classes/Date.html#method-i-at_midnight
[Date#beginning_of_day]: https://api.rubyonrails.org/classes/Date.html#method-i-beginning_of_day
[Date#end_of_day]: https://api.rubyonrails.org/classes/Date.html#method-i-end_of_day
[Date#midnight]: https://api.rubyonrails.org/classes/Date.html#method-i-midnight
[DateTime#at_beginning_of_minute]: https://api.rubyonrails.org/classes/DateTime.html#method-i-at_beginning_of_minute
[DateTime#beginning_of_minute]: https://api.rubyonrails.org/classes/DateTime.html#method-i-beginning_of_minute
[DateTime#end_of_minute]: https://api.rubyonrails.org/classes/DateTime.html#method-i-end_of_minute
[Date#ago]: https://api.rubyonrails.org/classes/Date.html#method-i-ago
[Date#since]: https://api.rubyonrails.org/classes/Date.html#method-i-since
[DateTime#ago]: https://api.rubyonrails.org/classes/DateTime.html#method-i-ago
[DateTime#at_beginning_of_day]: https://api.rubyonrails.org/classes/DateTime.html#method-i-at_beginning_of_day
[DateTime#at_beginning_of_hour]: https://api.rubyonrails.org/classes/DateTime.html#method-i-at_beginning_of_hour
[DateTime#at_midnight]: https://api.rubyonrails.org/classes/DateTime.html#method-i-at_midnight
[DateTime#beginning_of_day]: https://api.rubyonrails.org/classes/DateTime.html#method-i-beginning_of_day
[DateTime#beginning_of_hour]: https://api.rubyonrails.org/classes/DateTime.html#method-i-beginning_of_hour
[DateTime#end_of_day]: https://api.rubyonrails.org/classes/DateTime.html#method-i-end_of_day
[DateTime#end_of_hour]: https://api.rubyonrails.org/classes/DateTime.html#method-i-end_of_hour
[DateTime#in]: https://api.rubyonrails.org/classes/DateTime.html#method-i-in
[DateTime#midnight]: https://api.rubyonrails.org/classes/DateTime.html#method-i-midnight
[DateTime.current]: https://api.rubyonrails.org/classes/DateTime.html#method-c-current
[DateTime#seconds_since_midnight]: https://api.rubyonrails.org/classes/DateTime.html#method-i-seconds_since_midnight
[DateTime#getutc]: https://api.rubyonrails.org/classes/DateTime.html#method-i-getutc
[DateTime#utc]: https://api.rubyonrails.org/classes/DateTime.html#method-i-utc
[DateTime#utc?]: https://api.rubyonrails.org/classes/DateTime.html#method-i-utc-3F
[DateTime#advance]: https://api.rubyonrails.org/classes/DateTime.html#method-i-advance
[DateTime#since]: https://api.rubyonrails.org/classes/DateTime.html#method-i-since
[DateTime#change]: https://api.rubyonrails.org/classes/DateTime.html#method-i-change
[Time#ago]: https://api.rubyonrails.org/classes/Time.html#method-i-ago
[Time#change]: https://api.rubyonrails.org/classes/Time.html#method-i-change
[Time#since]: https://api.rubyonrails.org/classes/Time.html#method-i-since
[DateAndTime::Calculations#next_day?]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-next_day-3F
[DateAndTime::Calculations#prev_day?]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-prev_day-3F
[DateAndTime::Calculations#today?]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-today-3F
[DateAndTime::Calculations#tomorrow?]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-tomorrow-3F
[DateAndTime::Calculations#yesterday?]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-yesterday-3F
[DateAndTime::Calculations#all_day]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-all_day
[DateAndTime::Calculations#all_month]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-all_month
[DateAndTime::Calculations#all_quarter]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-all_quarter
[DateAndTime::Calculations#all_week]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-all_week
[DateAndTime::Calculations#all_year]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-all_year
[Time.current]: https://api.rubyonrails.org/classes/Time.html#method-c-current
[Time#next_day]: https://api.rubyonrails.org/classes/Time.html#method-i-next_day
[Time#prev_day]: https://api.rubyonrails.org/classes/Time.html#method-i-prev_day
[Time#next_month]: https://api.rubyonrails.org/classes/Time.html#method-i-next_month
[Time#prev_month]: https://api.rubyonrails.org/classes/Time.html#method-i-prev_month
[Time#next_year]: https://api.rubyonrails.org/classes/Time.html#method-i-next_year
[Time#prev_year]: https://api.rubyonrails.org/classes/Time.html#method-i-prev_year
[DateAndTime::Calculations#last_quarter]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-last_quarter
[DateAndTime::Calculations#next_quarter]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-next_quarter
[DateAndTime::Calculations#prev_quarter]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-prev_quarter
[File.atomic_write]: https://api.rubyonrails.org/classes/File.html#method-c-atomic_write
[NameError#missing_name?]: https://api.rubyonrails.org/classes/NameError.html#method-i-missing_name-3F
[LoadError#is_missing?]: https://api.rubyonrails.org/classes/LoadError.html#method-i-is_missing-3F
[Pathname#existence]: https://api.rubyonrails.org/classes/Pathname.html#method-i-existence
