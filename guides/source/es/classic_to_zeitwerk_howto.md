**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 9c6201fd526077579ef792e0c4e2150d
Clásico a Zeitwerk HOWTO
=========================

Esta guía documenta cómo migrar aplicaciones de Rails de `classic` a `zeitwerk` mode.

Después de leer esta guía, sabrás:

* Qué son los modos `classic` y `zeitwerk`
* Por qué cambiar de `classic` a `zeitwerk`
* Cómo activar el modo `zeitwerk`
* Cómo verificar que tu aplicación se ejecuta en modo `zeitwerk`
* Cómo verificar que tu proyecto se carga correctamente en la línea de comandos
* Cómo verificar que tu proyecto se carga correctamente en el conjunto de pruebas
* Cómo abordar posibles casos especiales
* Nuevas características en Zeitwerk que puedes aprovechar

--------------------------------------------------------------------------------

¿Qué son los modos `classic` y `zeitwerk`?
--------------------------------------------------------

Desde el principio, y hasta Rails 5, Rails utilizaba un cargador automático implementado en Active Support. Este cargador automático se conoce como `classic` y todavía está disponible en Rails 6.x. Rails 7 ya no incluye este cargador automático.

A partir de Rails 6, Rails viene con una forma nueva y mejor de cargar automáticamente, que delega en la gema [Zeitwerk](https://github.com/fxn/zeitwerk). Este es el modo `zeitwerk`. Por defecto, las aplicaciones que cargan los valores predeterminados del framework 6.0 y 6.1 se ejecutan en modo `zeitwerk`, y este es el único modo disponible en Rails 7.


¿Por qué cambiar de `classic` a `zeitwerk`?
----------------------------------------

El cargador automático `classic` ha sido extremadamente útil, pero tenía una serie de [problemas](https://guides.rubyonrails.org/v6.1/autoloading_and_reloading_constants_classic_mode.html#common-gotchas) que hacían que la carga automática fuera un poco complicada y confusa en ocasiones. Zeitwerk fue desarrollado para abordar esto, entre otras [motivaciones](https://github.com/fxn/zeitwerk#motivation).

Cuando actualices a Rails 6.x, se recomienda encarecidamente cambiar al modo `zeitwerk` porque es un cargador automático mejor, el modo `classic` está obsoleto.

Rails 7 finaliza el período de transición y no incluye el modo `classic`.

Estoy asustado
-----------

No te preocupes :).

Zeitwerk fue diseñado para ser compatible con el cargador automático clásico tanto como sea posible. Si tienes una aplicación que carga correctamente hoy, es probable que el cambio sea fácil. Muchos proyectos, grandes y pequeños, han informado de cambios realmente fluidos.

Esta guía te ayudará a cambiar el cargador automático con confianza.

Si por alguna razón te encuentras en una situación que no sabes cómo resolver, no dudes en [abrir un problema en `rails/rails`](https://github.com/rails/rails/issues/new) y etiquetar a [`@fxn`](https://github.com/fxn).


Cómo activar el modo `zeitwerk`
-------------------------------

### Aplicaciones que ejecutan Rails 5.x o anterior

En aplicaciones que ejecutan una versión de Rails anterior a 6.0, el modo `zeitwerk` no está disponible. Debes estar al menos en Rails 6.0.

### Aplicaciones que ejecutan Rails 6.x

En aplicaciones que ejecutan Rails 6.x hay dos escenarios.

Si la aplicación está cargando los valores predeterminados del framework de Rails 6.0 o 6.1 y se está ejecutando en modo `classic`, debes optar por desactivarlo manualmente. Debes tener algo similar a esto:

```ruby
# config/application.rb
config.load_defaults 6.0
config.autoloader = :classic # ELIMINA ESTA LÍNEA
```

Como se mencionó, simplemente elimina la anulación, el modo `zeitwerk` es el predeterminado.

Por otro lado, si la aplicación está cargando valores predeterminados antiguos del framework, debes habilitar el modo `zeitwerk` explícitamente:

```ruby
# config/application.rb
config.load_defaults 5.2
config.autoloader = :zeitwerk
```

### Aplicaciones que ejecutan Rails 7

En Rails 7 solo hay modo `zeitwerk`, no necesitas hacer nada para habilitarlo.

De hecho, en Rails 7 ni siquiera existe el setter `config.autoloader=`. Si `config/application.rb` lo utiliza, por favor elimina la línea.


Cómo verificar que la aplicación se ejecuta en modo `zeitwerk`
------------------------------------------------------

Para verificar que la aplicación se está ejecutando en modo `zeitwerk`, ejecuta

```
bin/rails runner 'p Rails.autoloaders.zeitwerk_enabled?'
```

Si eso imprime `true`, el modo `zeitwerk` está habilitado.


¿Cumple mi aplicación con las convenciones de Zeitwerk?
-----------------------------------------------------

### config.eager_load_paths

La prueba de cumplimiento se ejecuta solo para los archivos cargados de forma inmediata. Por lo tanto, para verificar el cumplimiento de Zeitwerk, se recomienda tener todas las rutas de carga automática en las rutas de carga inmediata.

Esto ya es así por defecto, pero si el proyecto tiene rutas de carga automática personalizadas configuradas de esta manera:

```ruby
config.autoload_paths << "#{Rails.root}/extras"
```

esas no se cargan de forma inmediata y no se verificarán. Agregarlas a las rutas de carga inmediata es fácil:

```ruby
config.autoload_paths << "#{Rails.root}/extras"
config.eager_load_paths << "#{Rails.root}/extras"
```

### zeitwerk:check

Una vez que se habilita el modo `zeitwerk` y se verifica la configuración de las rutas de carga inmediata, ejecuta:

```
bin/rails zeitwerk:check
```

Una verificación exitosa se ve así:

```
% bin/rails zeitwerk:check
Hold on, I am eager loading the application.
All is good!
```

Puede haber una salida adicional dependiendo de la configuración de la aplicación, pero el último "All is good!" es lo que estás buscando.
Si la doble verificación explicada en la sección anterior determina que en realidad deben haber algunas rutas de carga automática personalizadas fuera de las rutas de carga ansiosa, la tarea las detectará y advertirá al respecto. Sin embargo, si el conjunto de pruebas carga esos archivos correctamente, todo está bien.

Ahora, si hay algún archivo que no define la constante esperada, la tarea te lo dirá. Lo hace uno por uno, porque si continúa, el fallo al cargar un archivo podría provocar otros fallos no relacionados con la verificación que queremos realizar y el informe de error sería confuso.

Si se informa una constante, corrige esa en particular y ejecuta la tarea nuevamente. Repite hasta obtener "¡Todo está bien!".

Tomemos por ejemplo:

```
% bin/rails zeitwerk:check
Espera, estoy cargando ansiosamente la aplicación.
se esperaba que el archivo app/models/vat.rb definiera la constante Vat
```

VAT es un impuesto europeo. El archivo `app/models/vat.rb` define `VAT`, pero el cargador automático espera `Vat`, ¿por qué?

### Acrónimos

Este es el tipo más común de discrepancia que puedes encontrar, tiene que ver con acrónimos. Veamos por qué obtenemos ese mensaje de error.

El cargador automático clásico puede cargar automáticamente `VAT` porque su entrada es el nombre de la constante faltante, `VAT`, invoca `underscore` en ella, lo que da como resultado `vat`, y busca un archivo llamado `vat.rb`. Funciona.

La entrada del nuevo cargador automático es el sistema de archivos. Dado el archivo `vat.rb`, Zeitwerk invoca `camelize` en `vat`, lo que da como resultado `Vat`, y espera que el archivo defina la constante `Vat`. Eso es lo que dice el mensaje de error.

Arreglar esto es fácil, solo necesitas decirle al inflector sobre este acrónimo:

```ruby
# config/initializers/inflections.rb
ActiveSupport::Inflector.inflections(:en) do |inflect|
  inflect.acronym "VAT"
end
```

Hacer esto afecta cómo Active Support inflecta globalmente. Eso puede estar bien, pero si prefieres, también puedes pasar anulaciones a los inflectores utilizados por los cargadores automáticos:

```ruby
# config/initializers/zeitwerk.rb
Rails.autoloaders.main.inflector.inflect("vat" => "VAT")
```

Con esta opción tienes más control, porque solo los archivos llamados exactamente `vat.rb` o los directorios llamados exactamente `vat` se inflectarán como `VAT`. Un archivo llamado `vat_rules.rb` no se ve afectado por eso y puede definir `VatRules` sin problemas. Esto puede ser útil si el proyecto tiene este tipo de inconsistencias de nomenclatura.

Con eso en su lugar, ¡la verificación pasa!

```
% bin/rails zeitwerk:check
Espera, estoy cargando ansiosamente la aplicación.
¡Todo está bien!
```

Una vez que todo está bien, se recomienda seguir validando el proyecto en el conjunto de pruebas. La sección [_Verificar la compatibilidad de Zeitwerk en el conjunto de pruebas_](#verificar-la-compatibilidad-de-zeitwerk-en-el-conjunto-de-pruebas) explica cómo hacerlo.

### Concerns

Puedes cargar automáticamente y cargar ansiosamente desde una estructura estándar con subdirectorios `concerns` como

```
app/models
app/models/concerns
```

Por defecto, `app/models/concerns` pertenece a las rutas de carga automática y, por lo tanto, se asume que es un directorio raíz. Entonces, por defecto, `app/models/concerns/foo.rb` debería definir `Foo`, no `Concerns::Foo`.

Si tu aplicación utiliza `Concerns` como espacio de nombres, tienes dos opciones:

1. Elimina el espacio de nombres `Concerns` de esas clases y módulos y actualiza el código cliente.
2. Deja las cosas como están eliminando `app/models/concerns` de las rutas de carga automática:

  ```ruby
  # config/initializers/zeitwerk.rb
  ActiveSupport::Dependencies.
    autoload_paths.
    delete("#{Rails.root}/app/models/concerns")
  ```

### Tener `app` en las Rutas de Carga Automática

Algunos proyectos desean que algo como `app/api/base.rb` defina `API::Base` y agregan `app` a las rutas de carga automática para lograrlo.

Dado que Rails agrega automáticamente todos los subdirectorios de `app` a las rutas de carga automática (con algunas excepciones), tenemos otra situación en la que hay directorios raíz anidados, similar a lo que sucede con `app/models/concerns`. Esa configuración ya no funciona tal como está.

Sin embargo, puedes mantener esa estructura, simplemente elimina `app/api` de las rutas de carga automática en un inicializador:

```ruby
# config/initializers/zeitwerk.rb
ActiveSupport::Dependencies.
  autoload_paths.
  delete("#{Rails.root}/app/api")
```

Ten cuidado con los subdirectorios que no tienen archivos para cargar automáticamente/cargar ansiosamente. Por ejemplo, si la aplicación tiene `app/admin` con recursos para [ActiveAdmin](https://activeadmin.info/), debes ignorarlos. Lo mismo para `assets` y amigos:

```ruby
# config/initializers/zeitwerk.rb
Rails.autoloaders.main.ignore(
  "app/admin",
  "app/assets",
  "app/javascripts",
  "app/views"
)
```

Sin esa configuración, la aplicación cargaría ansiosamente esos árboles. Daría un error en `app/admin` porque sus archivos no definen constantes y definiría un módulo `Views`, por ejemplo, como un efecto secundario no deseado.

Como puedes ver, tener `app` en las rutas de carga automática es técnicamente posible, pero un poco complicado.

### Constantes Cargadas Automáticamente y Espacios de Nombres Explícitos

Si un espacio de nombres se define en un archivo, como `Hotel` aquí:
```
app/models/hotel.rb         # Define Hotel.
app/models/hotel/pricing.rb # Define Hotel::Pricing.
```

la constante `Hotel` debe ser establecida utilizando las palabras clave `class` o `module`. Por ejemplo:

```ruby
class Hotel
end
```

es correcto.

Alternativas como

```ruby
Hotel = Class.new
```

o

```ruby
Hotel = Struct.new
```

no funcionarán, los objetos hijos como `Hotel::Pricing` no se encontrarán.

Esta restricción solo se aplica a los espacios de nombres explícitos. Las clases y módulos que no definen un espacio de nombres pueden ser definidos utilizando esas formas idiomáticas.

### Un Archivo, Una Constante (en el Mismo Nivel Superior)

En el modo `classic` técnicamente podrías definir varias constantes en el mismo nivel superior y hacer que todas se recarguen. Por ejemplo, dado

```ruby
# app/models/foo.rb

class Foo
end

class Bar
end
```

mientras que `Bar` no podría ser autocompletado, al autocompletar `Foo` se marcaría también a `Bar` como autocompletado.

Esto no ocurre en el modo `zeitwerk`, necesitas mover `Bar` a su propio archivo `bar.rb`. Un archivo, una constante en el nivel superior.

Esto solo afecta a las constantes en el mismo nivel superior como en el ejemplo anterior. Las clases y módulos internos están bien. Por ejemplo, considera

```ruby
# app/models/foo.rb

class Foo
  class InnerClass
  end
end
```

Si la aplicación recarga `Foo`, también recargará `Foo::InnerClass`.

### Comodines en `config.autoload_paths`

Ten cuidado con las configuraciones que utilizan comodines como

```ruby
config.autoload_paths += Dir["#{config.root}/extras/**/"]
```

Cada elemento de `config.autoload_paths` debe representar el espacio de nombres superior (`Object`). Eso no funcionará.

Para solucionarlo, simplemente elimina los comodines:

```ruby
config.autoload_paths << "#{config.root}/extras"
```

### Decoración de Clases y Módulos de Motores

Si tu aplicación decora clases o módulos de un motor, es probable que esté haciendo algo como esto en algún lugar:

```ruby
config.to_prepare do
  Dir.glob("#{Rails.root}/app/overrides/**/*_override.rb").sort.each do |override|
    require_dependency override
  end
end
```

Eso debe actualizarse: necesitas decirle al autocompletado principal que ignore el directorio con las anulaciones, y necesitas cargarlas con `load` en su lugar. Algo como esto:

```ruby
overrides = "#{Rails.root}/app/overrides"
Rails.autoloaders.main.ignore(overrides)
config.to_prepare do
  Dir.glob("#{overrides}/**/*_override.rb").sort.each do |override|
    load override
  end
end
```

### `before_remove_const`

Rails 3.1 agregó soporte para un callback llamado `before_remove_const` que se invocaba si una clase o módulo respondía a este método y estaba a punto de ser recargado. Este callback ha permanecido sin documentar y es poco probable que tu código lo utilice.

Sin embargo, en caso de que lo haga, puedes reescribir algo como

```ruby
class Country < ActiveRecord::Base
  def self.before_remove_const
    expire_redis_cache
  end
end
```

como

```ruby
# config/initializers/country.rb
if Rails.application.config.reloading_enabled?
  Rails.autoloaders.main.on_unload("Country") do |klass, _abspath|
    klass.expire_redis_cache
  end
end
```

### Spring y el Entorno `test`

Spring recarga el código de la aplicación si algo cambia. En el entorno `test` necesitas habilitar la recarga para que funcione:

```ruby
# config/environments/test.rb
config.cache_classes = false
```

o, desde Rails 7.1:

```ruby
# config/environments/test.rb
config.enable_reloading = true
```

De lo contrario, obtendrás:

```
reloading is disabled because config.cache_classes is true
```

o

```
reloading is disabled because config.enable_reloading is false
```

Esto no tiene un impacto en el rendimiento.

### Bootsnap

Asegúrate de depender al menos de Bootsnap 1.4.4.


Verificar la Conformidad de Zeitwerk en la Suite de Pruebas
----------------------------------------------------------

La tarea `zeitwerk:check` es útil durante la migración. Una vez que el proyecto sea compatible, se recomienda automatizar esta verificación. Para hacerlo, es suficiente cargar la aplicación de forma ansiosa, que es precisamente lo que hace `zeitwerk:check`.

### Integración Continua

Si tu proyecto tiene integración continua en funcionamiento, es una buena idea cargar la aplicación de forma ansiosa cuando se ejecute la suite allí. Si la aplicación no se puede cargar de forma ansiosa por cualquier motivo, quieres saberlo en la integración continua, ¿mejor que en producción, verdad?

Las integraciones continuas típicamente establecen alguna variable de entorno para indicar que la suite de pruebas se está ejecutando allí. Por ejemplo, podría ser `CI`:

```ruby
# config/environments/test.rb
config.eager_load = ENV["CI"].present?
```

A partir de Rails 7, las aplicaciones recién generadas están configuradas de esa manera de forma predeterminada.

### Suites de Pruebas Básicas

Si tu proyecto no tiene integración continua, aún puedes cargar de forma ansiosa en la suite de pruebas llamando a `Rails.application.eager_load!`:

#### Minitest

```ruby
require "test_helper"

class ZeitwerkComplianceTest < ActiveSupport::TestCase
  test "eager loads all files without errors" do
    assert_nothing_raised { Rails.application.eager_load! }
  end
end
```

#### RSpec

```ruby
require "rails_helper"

RSpec.describe "Zeitwerk compliance" do
  it "eager loads all files without errors" do
    expect { Rails.application.eager_load! }.not_to raise_error
  end
end
```

Eliminar Cualquier Llamada a `require`
-------------------------------------

En mi experiencia, los proyectos generalmente no hacen esto. Pero he visto un par, y he oído hablar de algunos otros.
```
En una aplicación de Rails, se utiliza `require` exclusivamente para cargar código desde `lib` o de terceros, como dependencias de gemas o la biblioteca estándar. **Nunca cargues código de la aplicación que se pueda cargar automáticamente con `require`**. Puedes ver por qué esto es una mala idea en el modo `classic` [aquí](https://guides.rubyonrails.org/v6.1/autoloading_and_reloading_constants_classic_mode.html#autoloading-and-require).

```ruby
require "nokogiri" # BIEN
require "net/http" # BIEN
require "user"     # MAL, ELIMINA ESTO (asumiendo que es app/models/user.rb)
```

Por favor, elimina cualquier llamada a `require` de ese tipo.

Nuevas características que puedes aprovechar
--------------------------------------------

### Eliminar llamadas a `require_dependency`

Todos los casos conocidos de `require_dependency` han sido eliminados con Zeitwerk. Debes buscar en el proyecto y eliminarlos.

Si tu aplicación utiliza la herencia de una sola tabla, consulta la sección [Herencia de una sola tabla](autoloading_and_reloading_constants.html#single-table-inheritance) de la guía Autoloading and Reloading Constants (Modo Zeitwerk).

### Nombres calificados en las definiciones de clases y módulos ahora son posibles

Ahora puedes usar de manera robusta rutas constantes en las definiciones de clases y módulos:

```ruby
# La carga automática en el cuerpo de esta clase ahora coincide con la semántica de Ruby.
class Admin::UsersController < ApplicationController
  # ...
end
```

Un detalle a tener en cuenta es que, dependiendo del orden de ejecución, el cargador automático clásico a veces podía cargar automáticamente `Foo::Wadus` en

```ruby
class Foo::Bar
  Wadus
end
```

Esto no coincide con la semántica de Ruby porque `Foo` no está en el anidamiento y no funcionará en absoluto en el modo `zeitwerk`. Si encuentras un caso así, puedes usar el nombre calificado `Foo::Wadus`:

```ruby
class Foo::Bar
  Foo::Wadus
end
```

o agregar `Foo` al anidamiento:

```ruby
module Foo
  class Bar
    Wadus
  end
end
```

### Seguridad en hilos en todas partes

En el modo `classic`, la carga automática de constantes no es segura en hilos, aunque Rails tiene bloqueos en su lugar, por ejemplo, para hacer que las solicitudes web sean seguras en hilos.

La carga automática de constantes es segura en hilos en el modo `zeitwerk`. Por ejemplo, ahora puedes cargar automáticamente en scripts multihilo ejecutados por el comando `runner`.

### La carga anticipada y la carga automática son consistentes

En el modo `classic`, si `app/models/foo.rb` define `Bar`, no podrás cargar automáticamente ese archivo, pero la carga anticipada funcionará porque carga archivos de forma recursiva a ciegas. Esto puede ser una fuente de errores si pruebas las cosas primero con carga anticipada y luego falla la ejecución con la carga automática.

En el modo `zeitwerk`, ambos modos de carga son consistentes, fallan y generan errores en los mismos archivos.
