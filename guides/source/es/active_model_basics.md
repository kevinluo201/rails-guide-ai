**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: cee957545ee75801aab30265bc416992
Fundamentos de Active Model
===================

Esta guía te proporcionará todo lo que necesitas para comenzar a usar las clases de modelo. Active Model permite que los ayudantes de Action Pack interactúen con objetos Ruby simples. Active Model también ayuda a construir ORMs personalizados para su uso fuera del framework Rails.

Después de leer esta guía, sabrás:

* Cómo se comporta un modelo de Active Record.
* Cómo funcionan los callbacks y las validaciones.
* Cómo funcionan los serializadores.
* Cómo se integra Active Model con el framework de internacionalización (i18n) de Rails.

--------------------------------------------------------------------------------

¿Qué es Active Model?
---------------------

Active Model es una biblioteca que contiene varios módulos utilizados en el desarrollo de clases que necesitan algunas características presentes en Active Record. Algunos de estos módulos se explican a continuación.

### API

`ActiveModel::API` agrega la capacidad de que una clase funcione con Action Pack y Action View directamente.

```ruby
class EmailContact
  include ActiveModel::API

  attr_accessor :name, :email, :message
  validates :name, :email, :message, presence: true

  def deliver
    if valid?
      # enviar correo electrónico
    end
  end
end
```

Al incluir `ActiveModel::API`, obtienes algunas características como:

- introspección del nombre del modelo
- conversiones
- traducciones
- validaciones

También te brinda la capacidad de inicializar un objeto con un hash de atributos, al igual que cualquier objeto de Active Record.

```irb
irb> email_contact = EmailContact.new(name: 'David', email: 'david@example.com', message: 'Hola Mundo')
irb> email_contact.name
=> "David"
irb> email_contact.email
=> "david@example.com"
irb> email_contact.valid?
=> true
irb> email_contact.persisted?
=> false
```

Cualquier clase que incluya `ActiveModel::API` se puede utilizar con `form_with`, `render` y cualquier otro método de ayuda de Action View, al igual que los objetos de Active Record.

### Métodos de atributo

El módulo `ActiveModel::AttributeMethods` puede agregar prefijos y sufijos personalizados a los métodos de una clase. Se utiliza definiendo los prefijos y sufijos y qué métodos del objeto los utilizarán.

```ruby
class Person
  include ActiveModel::AttributeMethods

  attribute_method_prefix 'reset_'
  attribute_method_suffix '_highest?'
  define_attribute_methods 'age'

  attr_accessor :age

  private
    def reset_attribute(attribute)
      send("#{attribute}=", 0)
    end

    def attribute_highest?(attribute)
      send(attribute) > 100
    end
end
```

```irb
irb> person = Person.new
irb> person.age = 110
irb> person.age_highest?
=> true
irb> person.reset_age
=> 0
irb> person.age_highest?
=> false
```

### Callbacks

`ActiveModel::Callbacks` proporciona callbacks al estilo de Active Record. Esto proporciona la capacidad de definir callbacks que se ejecutan en momentos apropiados. Después de definir los callbacks, puedes envolverlos con métodos personalizados antes, después y alrededor.

```ruby
class Person
  extend ActiveModel::Callbacks

  define_model_callbacks :update

  before_update :reset_me

  def update
    run_callbacks(:update) do
      # Este método se llama cuando se llama a update en un objeto.
    end
  end

  def reset_me
    # Este método se llama cuando se llama a update en un objeto, ya que se ha definido un callback before_update.
  end
end
```

### Conversión

Si una clase define los métodos `persisted?` e `id`, entonces puedes incluir el módulo `ActiveModel::Conversion` en esa clase y llamar a los métodos de conversión de Rails en objetos de esa clase.

```ruby
class Person
  include ActiveModel::Conversion

  def persisted?
    false
  end

  def id
    nil
  end
end
```

```irb
irb> person = Person.new
irb> person.to_model == person
=> true
irb> person.to_key
=> nil
irb> person.to_param
=> nil
```

### Dirty

Un objeto se vuelve "dirty" cuando ha sufrido uno o más cambios en sus atributos y no se ha guardado. `ActiveModel::Dirty` proporciona la capacidad de verificar si un objeto ha cambiado o no. También tiene métodos de acceso basados en atributos. Consideremos una clase Person con los atributos `first_name` y `last_name`:

```ruby
class Person
  include ActiveModel::Dirty
  define_attribute_methods :first_name, :last_name

  def first_name
    @first_name
  end

  def first_name=(value)
    first_name_will_change!
    @first_name = value
  end

  def last_name
    @last_name
  end

  def last_name=(value)
    last_name_will_change!
    @last_name = value
  end

  def save
    # hacer trabajo de guardado...
    changes_applied
  end
end
```

#### Consultar directamente un objeto para obtener su lista de todos los atributos cambiados

```irb
irb> person = Person.new
irb> person.changed?
=> false

irb> person.first_name = "Nombre"
irb> person.first_name
=> "Nombre"

# Devuelve true si alguno de los atributos tiene cambios no guardados.
irb> person.changed?
=> true

# Devuelve una lista de atributos que han cambiado antes de guardar.
irb> person.changed
=> ["first_name"]

# Devuelve un Hash de los atributos que han cambiado con sus valores originales.
irb> person.changed_attributes
=> {"first_name"=>nil}

# Devuelve un Hash de los cambios, con los nombres de los atributos como claves y los valores como un array de los valores antiguos y nuevos para ese campo.
irb> person.changes
=> {"first_name"=>[nil, "Nombre"]}
```

#### Métodos de acceso basados en atributos

Realizar un seguimiento de si el atributo en particular ha cambiado o no.
```irb
irb> persona.nombre
=> "Nombre"

# ¿attr_nombre_cambiado?
irb> persona.nombre_cambiado?
=> true
```

Realizar un seguimiento del valor anterior del atributo.

```irb
# Accesor attr_nombre_era
irb> persona.nombre_era
=> nil
```

Realizar un seguimiento de los valores anterior y actual del atributo cambiado. Devuelve una matriz si ha cambiado, de lo contrario devuelve nil.

```irb
# Cambio attr_nombre
irb> persona.cambio_nombre
=> [nil, "Nombre"]
irb> persona.cambio_apellido
=> nil
```

### Validaciones

El módulo `ActiveModel::Validations` agrega la capacidad de validar objetos como en Active Record.

```ruby
class Persona
  include ActiveModel::Validations

  attr_accessor :nombre, :email, :token

  validates :nombre, presence: true
  validates_format_of :email, with: /\A([^\s]+)((?:[-a-z0-9]\.)[a-z]{2,})\z/i
  validates! :token, presence: true
end
```

```irb
irb> persona = Persona.new
irb> persona.token = "2b1f325"
irb> persona.valid?
=> false
irb> persona.nombre = 'vishnu'
irb> persona.email = 'yo'
irb> persona.valid?
=> false
irb> persona.email = 'yo@vishnuatrai.com'
irb> persona.valid?
=> true
irb> persona.token = nil
irb> persona.valid?
ActiveModel::StrictValidationFailed
```

### Nomenclatura

`ActiveModel::Naming` agrega varios métodos de clase que facilitan la gestión de la nomenclatura y el enrutamiento. El módulo define el método de clase `model_name` que define varios accesores utilizando algunos métodos de `ActiveSupport::Inflector`.

```ruby
class Persona
  extend ActiveModel::Naming
end

Persona.model_name.name                # => "Persona"
Persona.model_name.singular            # => "persona"
Persona.model_name.plural              # => "personas"
Persona.model_name.element             # => "persona"
Persona.model_name.human               # => "Persona"
Persona.model_name.collection          # => "personas"
Persona.model_name.param_key           # => "persona"
Persona.model_name.i18n_key            # => :persona
Persona.model_name.route_key           # => "personas"
Persona.model_name.singular_route_key  # => "persona"
```

### Modelo

`ActiveModel::Model` permite implementar modelos similares a `ActiveRecord::Base`.

```ruby
class ContactoEmail
  include ActiveModel::Model

  attr_accessor :nombre, :email, :mensaje
  validates :nombre, :email, :mensaje, presence: true

  def enviar
    if valid?
      # enviar correo electrónico
    end
  end
end
```

Al incluir `ActiveModel::Model`, se obtienen todas las características de `ActiveModel::API`.

### Serialización

`ActiveModel::Serialization` proporciona una serialización básica para su objeto. Debe declarar un Hash de atributos que contenga los atributos que desea serializar. Los atributos deben ser cadenas, no símbolos.

```ruby
class Persona
  include ActiveModel::Serialization

  attr_accessor :nombre

  def attributes
    { 'nombre' => nil }
  end
end
```

Ahora puede acceder a un Hash serializado de su objeto utilizando el método `serializable_hash`.

```irb
irb> persona = Persona.new
irb> persona.serializable_hash
=> {"nombre"=>nil}
irb> persona.nombre = "Bob"
irb> persona.serializable_hash
=> {"nombre"=>"Bob"}
```

#### ActiveModel::Serializers

Active Model también proporciona el módulo `ActiveModel::Serializers::JSON` para la serialización / deserialización JSON. Este módulo incluye automáticamente el módulo `ActiveModel::Serialization` mencionado anteriormente.

##### ActiveModel::Serializers::JSON

Para usar `ActiveModel::Serializers::JSON`, solo necesita cambiar el módulo que está incluyendo de `ActiveModel::Serialization` a `ActiveModel::Serializers::JSON`.

```ruby
class Persona
  include ActiveModel::Serializers::JSON

  attr_accessor :nombre

  def attributes
    { 'nombre' => nil }
  end
end
```

El método `as_json`, similar a `serializable_hash`, proporciona un Hash que representa el modelo.

```irb
irb> persona = Persona.new
irb> persona.as_json
=> {"nombre"=>nil}
irb> persona.nombre = "Bob"
irb> persona.as_json
=> {"nombre"=>"Bob"}
```

También puede definir los atributos de un modelo a partir de una cadena JSON. Sin embargo, debe definir el método `attributes=` en su clase:

```ruby
class Persona
  include ActiveModel::Serializers::JSON

  attr_accessor :nombre

  def attributes=(hash)
    hash.each do |key, value|
      send("#{key}=", value)
    end
  end

  def attributes
    { 'nombre' => nil }
  end
end
```

Ahora es posible crear una instancia de `Persona` y establecer atributos usando `from_json`.

```irb
irb> json = { nombre: 'Bob' }.to_json
irb> persona = Persona.new
irb> persona.from_json(json)
=> #<Persona:0x00000100c773f0 @nombre="Bob">
irb> persona.nombre
=> "Bob"
```

### Traducción

`ActiveModel::Translation` proporciona integración entre su objeto y el marco de internacionalización (i18n) de Rails.

```ruby
class Persona
  extend ActiveModel::Translation
end
```

Con el método `human_attribute_name`, puede transformar los nombres de atributos en un formato más legible para los humanos. El formato legible para los humanos se define en su archivo(s) de localización.

* config/locales/app.pt-BR.yml

```yaml
pt-BR:
  activemodel:
    attributes:
      persona:
        nombre: 'Nome'
```

```ruby
Persona.human_attribute_name('nombre') # => "Nome"
```

### Pruebas de Lint

`ActiveModel::Lint::Tests` le permite probar si un objeto cumple con la API de Active Model.

* `app/models/persona.rb`

    ```ruby
    class Persona
      include ActiveModel::Model
    end
    ```

* `test/models/persona_test.rb`

    ```ruby
    require "test_helper"

    class PersonaTest < ActiveSupport::TestCase
      include ActiveModel::Lint::Tests

      setup do
        @model = Persona.new
      end
    end
    ```

```bash
$ bin/rails test

Run options: --seed 14596

# Running:

......

Finished in 0.024899s, 240.9735 runs/s, 1204.8677 assertions/s.

6 runs, 30 assertions, 0 failures, 0 errors, 0 skips
```

No es necesario que un objeto implemente todas las API para funcionar con Action Pack. Este módulo solo pretende servir de guía en caso de que desee todas las características listas para usar.

### SecurePassword

`ActiveModel::SecurePassword` proporciona una forma de almacenar de forma segura cualquier contraseña en forma cifrada. Cuando incluye este módulo, se proporciona un método de clase `has_secure_password` que define un accesor `password` con ciertas validaciones de forma predeterminada.
#### Requisitos

`ActiveModel::SecurePassword` depende de [`bcrypt`](https://github.com/codahale/bcrypt-ruby 'BCrypt'),
por lo tanto, incluye esta gema en tu `Gemfile` para usar `ActiveModel::SecurePassword` correctamente.
Para que esto funcione, el modelo debe tener un accessor llamado `XXX_digest`.
Donde `XXX` es el nombre del atributo de tu contraseña deseada.
Las siguientes validaciones se agregan automáticamente:

1. La contraseña debe estar presente.
2. La contraseña debe ser igual a su confirmación (si se proporciona `XXX_confirmation`).
3. La longitud máxima de una contraseña es 72 (requerido por `bcrypt` en el que depende ActiveModel::SecurePassword).

#### Ejemplos

```ruby
class Person
  include ActiveModel::SecurePassword
  has_secure_password
  has_secure_password :recovery_password, validations: false

  attr_accessor :password_digest, :recovery_password_digest
end
```

```irb
irb> person = Person.new

# Cuando la contraseña está en blanco.
irb> person.valid?
=> false

# Cuando la confirmación no coincide con la contraseña.
irb> person.password = 'aditya'
irb> person.password_confirmation = 'nomatch'
irb> person.valid?
=> false

# Cuando la longitud de la contraseña supera los 72 caracteres.
irb> person.password = person.password_confirmation = 'a' * 100
irb> person.valid?
=> false

# Cuando solo se proporciona la contraseña sin la confirmación de la contraseña.
irb> person.password = 'aditya'
irb> person.valid?
=> true

# Cuando se pasan todas las validaciones.
irb> person.password = person.password_confirmation = 'aditya'
irb> person.valid?
=> true

irb> person.recovery_password = "42password"

irb> person.authenticate('aditya')
=> #<Person> # == person
irb> person.authenticate('notright')
=> false
irb> person.authenticate_password('aditya')
=> #<Person> # == person
irb> person.authenticate_password('notright')
=> false

irb> person.authenticate_recovery_password('42password')
=> #<Person> # == person
irb> person.authenticate_recovery_password('notright')
=> false

irb> person.password_digest
=> "$2a$04$gF8RfZdoXHvyTjHhiU4ZsO.kQqV9oonYZu31PRE4hLQn3xM2qkpIy"
irb> person.recovery_password_digest
=> "$2a$04$iOfhwahFymCs5weB3BNH/uXkTG65HR.qpW.bNhEjFP3ftli3o5DQC"
```
