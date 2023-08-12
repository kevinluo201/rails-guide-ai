**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: b550120024fb17dc176480922543264e
Los fundamentos de la creación de plugins en Rails
====================================

Un plugin de Rails es una extensión o modificación del marco principal. Los plugins proporcionan:

* Una forma para que los desarrolladores compartan ideas de vanguardia sin dañar la base de código estable.
* Una arquitectura segmentada para que las unidades de código se puedan corregir o actualizar según su propio calendario de lanzamiento.
* Una salida para los desarrolladores principales para que no tengan que incluir todas las nuevas características geniales bajo el sol.

Después de leer esta guía, sabrá:

* Cómo crear un plugin desde cero.
* Cómo escribir y ejecutar pruebas para el plugin.

Esta guía describe cómo construir un plugin impulsado por pruebas que:

* Extienda las clases principales de Ruby como Hash y String.
* Agregue métodos a `ApplicationRecord` siguiendo la tradición de los plugins `acts_as`.
* Le brinde información sobre dónde colocar los generadores en su plugin.

Con el propósito de esta guía, finja por un momento que es un ávido observador de aves.
Su ave favorita es el Yaffle, y desea crear un plugin que permita a otros desarrolladores compartir la bondad de Yaffle.

--------------------------------------------------------------------------------

Configuración
-----

Actualmente, los plugins de Rails se construyen como gemas, _gemified plugins_. Se pueden compartir entre
diferentes aplicaciones de Rails utilizando RubyGems y Bundler si se desea.

### Generar un Plugin como Gema

Rails incluye un comando `rails plugin new` que crea un
esqueleto para desarrollar cualquier tipo de extensión de Rails con la capacidad
de ejecutar pruebas de integración utilizando una aplicación Rails ficticia. Cree su
plugin con el siguiente comando:

```bash
$ rails plugin new yaffle
```

Consulte el uso y las opciones solicitando ayuda:

```bash
$ rails plugin new --help
```

Pruebas de su Plugin Recién Generado
-----------------------------------

Navegue hasta el directorio que contiene el plugin y edite `yaffle.gemspec` para
reemplazar cualquier línea que tenga valores `TODO`:

```ruby
spec.homepage    = "http://example.com"
spec.summary     = "Resumen de Yaffle."
spec.description = "Descripción de Yaffle."

...

spec.metadata["source_code_uri"] = "http://example.com"
spec.metadata["changelog_uri"] = "http://example.com"
```

Luego ejecute el comando `bundle install`.

Ahora puede ejecutar las pruebas utilizando el comando `bin/test` y debería ver:

```bash
$ bin/test
...
1 runs, 1 assertions, 0 failures, 0 errors, 0 skips
```

Esto le indicará que todo se generó correctamente y está listo para comenzar a agregar funcionalidad.

Extender Clases Principales
----------------------

Esta sección explicará cómo agregar un método a String que estará disponible en cualquier lugar de su aplicación Rails.

En este ejemplo, agregará un método a String llamado `to_squawk`. Para comenzar, cree un nuevo archivo de prueba con algunas afirmaciones:

```ruby
# yaffle/test/core_ext_test.rb

require "test_helper"

class CoreExtTest < ActiveSupport::TestCase
  def test_to_squawk_prepends_the_word_squawk
    assert_equal "squawk! Hello World", "Hello World".to_squawk
  end
end
```

Ejecute `bin/test` para ejecutar la prueba. Esta prueba debería fallar porque no hemos implementado el método `to_squawk`:

```bash
$ bin/test
E

Error:
CoreExtTest#test_to_squawk_prepends_the_word_squawk:
NoMethodError: undefined method `to_squawk' for "Hello World":String


bin/test /path/to/yaffle/test/core_ext_test.rb:4

.

Finished in 0.003358s, 595.6483 runs/s, 297.8242 assertions/s.
2 runs, 1 assertions, 0 failures, 1 errors, 0 skips
```

Genial, ahora estás listo para comenzar el desarrollo.

En `lib/yaffle.rb`, agregue `require "yaffle/core_ext"`:

```ruby
# yaffle/lib/yaffle.rb

require "yaffle/version"
require "yaffle/railtie"
require "yaffle/core_ext"

module Yaffle
  # Your code goes here...
end
```

Finalmente, cree el archivo `core_ext.rb` y agregue el método `to_squawk`:

```ruby
# yaffle/lib/yaffle/core_ext.rb

class String
  def to_squawk
    "squawk! #{self}".strip
  end
end
```

Para probar que su método hace lo que dice que hace, ejecute las pruebas unitarias con `bin/test` desde el directorio de su plugin.

```
$ bin/test
...
2 runs, 2 assertions, 0 failures, 0 errors, 0 skips
```

Para ver esto en acción, cambie al directorio `test/dummy`, inicie `bin/rails console` y comience a hacer squawk:

```irb
irb> "Hello World".to_squawk
=> "squawk! Hello World"
```

Agregar un Método "acts_as" a Active Record
----------------------------------------

Un patrón común en los plugins es agregar un método llamado `acts_as_algo` a los modelos. En este caso, usted
quiere escribir un método llamado `acts_as_yaffle` que agregue un método `squawk` a sus modelos de Active Record.

Para comenzar, configure sus archivos de manera que tenga:

```ruby
# yaffle/test/acts_as_yaffle_test.rb

require "test_helper"

class ActsAsYaffleTest < ActiveSupport::TestCase
end
```

```ruby
# yaffle/lib/yaffle.rb

require "yaffle/version"
require "yaffle/railtie"
require "yaffle/core_ext"
require "yaffle/acts_as_yaffle"

module Yaffle
  # Your code goes here...
end
```

```ruby
# yaffle/lib/yaffle/acts_as_yaffle.rb

module Yaffle
  module ActsAsYaffle
  end
end
```
### Agregar un Método de Clase

Este complemento espera que hayas agregado un método a tu modelo llamado `last_squawk`. Sin embargo, los usuarios del complemento podrían haber definido un método en su modelo llamado `last_squawk` que utilizan para otra cosa. Este complemento permitirá cambiar el nombre agregando un método de clase llamado `yaffle_text_field`.

Para comenzar, escribe una prueba fallida que muestre el comportamiento que deseas:

```ruby
# yaffle/test/acts_as_yaffle_test.rb

require "test_helper"

class ActsAsYaffleTest < ActiveSupport::TestCase
  def test_a_hickwalls_yaffle_text_field_should_be_last_squawk
    assert_equal "last_squawk", Hickwall.yaffle_text_field
  end

  def test_a_wickwalls_yaffle_text_field_should_be_last_tweet
    assert_equal "last_tweet", Wickwall.yaffle_text_field
  end
end
```

Cuando ejecutes `bin/test`, deberías ver lo siguiente:

```bash
$ bin/test
# Running:

..E

Error:
ActsAsYaffleTest#test_a_wickwalls_yaffle_text_field_should_be_last_tweet:
NameError: uninitialized constant ActsAsYaffleTest::Wickwall


bin/test /path/to/yaffle/test/acts_as_yaffle_test.rb:8

E

Error:
ActsAsYaffleTest#test_a_hickwalls_yaffle_text_field_should_be_last_squawk:
NameError: uninitialized constant ActsAsYaffleTest::Hickwall


bin/test /path/to/yaffle/test/acts_as_yaffle_test.rb:4



Finished in 0.004812s, 831.2949 runs/s, 415.6475 assertions/s.
4 runs, 2 assertions, 0 failures, 2 errors, 0 skips
```

Esto nos dice que no tenemos los modelos necesarios (Hickwall y Wickwall) que estamos tratando de probar. Podemos generar fácilmente estos modelos en nuestra aplicación Rails "dummy" ejecutando los siguientes comandos desde el directorio `test/dummy`:

```bash
$ cd test/dummy
$ bin/rails generate model Hickwall last_squawk:string
$ bin/rails generate model Wickwall last_squawk:string last_tweet:string
```

Ahora puedes crear las tablas de base de datos necesarias en tu base de datos de prueba navegando hasta tu aplicación dummy y migrando la base de datos. Primero, ejecuta:

```bash
$ cd test/dummy
$ bin/rails db:migrate
```

Mientras estás aquí, cambia los modelos Hickwall y Wickwall para que sepan que deben actuar como yaffles.

```ruby
# test/dummy/app/models/hickwall.rb

class Hickwall < ApplicationRecord
  acts_as_yaffle
end
```

```ruby
# test/dummy/app/models/wickwall.rb

class Wickwall < ApplicationRecord
  acts_as_yaffle yaffle_text_field: :last_tweet
end
```

También agregaremos código para definir el método `acts_as_yaffle`.

```ruby
# yaffle/lib/yaffle/acts_as_yaffle.rb

module Yaffle
  module ActsAsYaffle
    extend ActiveSupport::Concern

    class_methods do
      def acts_as_yaffle(options = {})
      end
    end
  end
end
```

```ruby
# test/dummy/app/models/application_record.rb

class ApplicationRecord < ActiveRecord::Base
  include Yaffle::ActsAsYaffle

  self.abstract_class = true
end
```

Luego puedes volver al directorio raíz (`cd ../..`) de tu complemento y volver a ejecutar las pruebas usando `bin/test`.

```bash
$ bin/test
# Running:

.E

Error:
ActsAsYaffleTest#test_a_hickwalls_yaffle_text_field_should_be_last_squawk:
NoMethodError: undefined method `yaffle_text_field' for #<Class:0x0055974ebbe9d8>


bin/test /path/to/yaffle/test/acts_as_yaffle_test.rb:4

E

Error:
ActsAsYaffleTest#test_a_wickwalls_yaffle_text_field_should_be_last_tweet:
NoMethodError: undefined method `yaffle_text_field' for #<Class:0x0055974eb8cfc8>


bin/test /path/to/yaffle/test/acts_as_yaffle_test.rb:8

.

Finished in 0.008263s, 484.0999 runs/s, 242.0500 assertions/s.
4 runs, 2 assertions, 0 failures, 2 errors, 0 skips
```

Nos estamos acercando... Ahora implementaremos el código del método `acts_as_yaffle` para que las pruebas pasen.

```ruby
# yaffle/lib/yaffle/acts_as_yaffle.rb

module Yaffle
  module ActsAsYaffle
    extend ActiveSupport::Concern

    class_methods do
      def acts_as_yaffle(options = {})
        cattr_accessor :yaffle_text_field, default: (options[:yaffle_text_field] || :last_squawk).to_s
      end
    end
  end
end
```

```ruby
# test/dummy/app/models/application_record.rb

class ApplicationRecord < ActiveRecord::Base
  include Yaffle::ActsAsYaffle

  self.abstract_class = true
end
```

Cuando ejecutes `bin/test`, deberías ver que todas las pruebas pasan:

```bash
$ bin/test
...
4 runs, 4 assertions, 0 failures, 0 errors, 0 skips
```

### Agregar un Método de Instancia

Este complemento agregará un método llamado 'squawk' a cualquier objeto Active Record que llame a `acts_as_yaffle`. El método 'squawk' simplemente establecerá el valor de uno de los campos en la base de datos.

Para comenzar, escribe una prueba fallida que muestre el comportamiento que deseas:

```ruby
# yaffle/test/acts_as_yaffle_test.rb
require "test_helper"

class ActsAsYaffleTest < ActiveSupport::TestCase
  def test_a_hickwalls_yaffle_text_field_should_be_last_squawk
    assert_equal "last_squawk", Hickwall.yaffle_text_field
  end

  def test_a_wickwalls_yaffle_text_field_should_be_last_tweet
    assert_equal "last_tweet", Wickwall.yaffle_text_field
  end

  def test_hickwalls_squawk_should_populate_last_squawk
    hickwall = Hickwall.new
    hickwall.squawk("Hello World")
    assert_equal "squawk! Hello World", hickwall.last_squawk
  end

  def test_wickwalls_squawk_should_populate_last_tweet
    wickwall = Wickwall.new
    wickwall.squawk("Hello World")
    assert_equal "squawk! Hello World", wickwall.last_tweet
  end
end
```

Ejecuta la prueba para asegurarte de que las dos últimas pruebas fallen con un error que contenga "NoMethodError: undefined method \`squawk'", luego actualiza `acts_as_yaffle.rb` para que se vea así:

```ruby
# yaffle/lib/yaffle/acts_as_yaffle.rb

module Yaffle
  module ActsAsYaffle
    extend ActiveSupport::Concern

    included do
      def squawk(string)
        write_attribute(self.class.yaffle_text_field, string.to_squawk)
      end
    end

    class_methods do
      def acts_as_yaffle(options = {})
        cattr_accessor :yaffle_text_field, default: (options[:yaffle_text_field] || :last_squawk).to_s
      end
    end
  end
end
```

```ruby
# test/dummy/app/models/application_record.rb

class ApplicationRecord < ActiveRecord::Base
  include Yaffle::ActsAsYaffle

  self.abstract_class = true
end
```

Ejecuta `bin/test` una última vez, y deberías ver:

```bash
$ bin/test
...
6 runs, 6 assertions, 0 failures, 0 errors, 0 skips
```

NOTA: El uso de `write_attribute` para escribir en el campo del modelo es solo un ejemplo de cómo un complemento puede interactuar con el modelo, y no siempre será el método correcto para usar. Por ejemplo, también podrías usar:
```ruby
send("#{self.class.yaffle_text_field}=", string.to_squawk)
```

Generadores
----------

Los generadores se pueden incluir en tu gema simplemente creándolos en un directorio `lib/generators` de tu plugin. Más información sobre
la creación de generadores se puede encontrar en la [Guía de Generadores](generators.html).

Publicando tu Gema
-------------------

Las gemas en desarrollo se pueden compartir fácilmente desde cualquier repositorio Git. Para compartir la gema Yaffle con otros, simplemente
haz un commit del código a un repositorio Git (como GitHub) y agrega una línea al `Gemfile` de la aplicación en cuestión:

```ruby
gem "yaffle", git: "https://github.com/rails/yaffle.git"
```

Después de ejecutar `bundle install`, la funcionalidad de tu gema estará disponible para la aplicación.

Cuando la gema esté lista para ser compartida como una versión formal, se puede publicar en [RubyGems](https://rubygems.org).

Alternativamente, puedes beneficiarte de las tareas Rake de Bundler. Puedes ver una lista completa con el siguiente comando:

```bash
$ bundle exec rake -T

$ bundle exec rake build
# Construye yaffle-0.1.0.gem en el directorio pkg

$ bundle exec rake install
# Construye e instala yaffle-0.1.0.gem en las gemas del sistema

$ bundle exec rake release
# Crea la etiqueta v0.1.0 y construye y empuja yaffle-0.1.0.gem a Rubygems
```

Para obtener más información sobre cómo publicar gemas en RubyGems, consulta: [Publicando tu gema](https://guides.rubygems.org/publishing).

Documentación RDoc
------------------

Una vez que tu plugin sea estable y estés listo para implementarlo, hazle un favor a los demás y documenta. Afortunadamente, escribir documentación para tu plugin es fácil.

El primer paso es actualizar el archivo README con información detallada sobre cómo usar tu plugin. Algunas cosas clave para incluir son:

* Tu nombre
* Cómo instalar
* Cómo agregar la funcionalidad a la aplicación (varios ejemplos de casos de uso comunes)
* Advertencias, problemas o consejos que puedan ayudar a los usuarios y ahorrarles tiempo

Una vez que tu README esté sólido, revisa y agrega comentarios RDoc a todos los métodos que los desarrolladores usarán. También es costumbre agregar comentarios `# :nodoc:` a aquellas partes del código que no están incluidas en la API pública.

Una vez que tus comentarios estén listos, navega hasta el directorio de tu plugin y ejecuta:

```bash
$ bundle exec rake rdoc
```

### Referencias

* [Desarrollando una RubyGem usando Bundler](https://github.com/radar/guides/blob/master/gem-development.md)
* [Usando .gemspecs como se pretende](https://yehudakatz.com/2010/04/02/using-gemspecs-as-intended/)
* [Referencia de Gemspec](https://guides.rubygems.org/specification-reference/)
