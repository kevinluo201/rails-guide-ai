**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 6da9945dc313b748574b8aca256f1435
Pruebas de aplicaciones Rails
=============================

Esta guía cubre los mecanismos incorporados en Rails para probar tu aplicación.

Después de leer esta guía, sabrás:

* Terminología de pruebas en Rails.
* Cómo escribir pruebas unitarias, funcionales, de integración y de sistema para tu aplicación.
* Otros enfoques populares de pruebas y complementos.

--------------------------------------------------------------------------------

¿Por qué escribir pruebas para tus aplicaciones Rails?
-----------------------------------------------------

Rails hace que sea muy fácil escribir tus pruebas. Comienza generando código de prueba esqueleto mientras creas tus modelos y controladores.

Al ejecutar tus pruebas de Rails, puedes asegurarte de que tu código se adhiere a la funcionalidad deseada incluso después de una importante refactorización de código.

Las pruebas de Rails también pueden simular solicitudes de navegador y, por lo tanto, puedes probar la respuesta de tu aplicación sin tener que probarla a través del navegador.

Introducción a las pruebas
--------------------------

El soporte de pruebas se ha integrado en la estructura de Rails desde el principio. No fue una epifanía de "oh, agreguemos soporte para ejecutar pruebas porque son nuevas y geniales".

### Rails se configura para las pruebas desde el principio

Rails crea un directorio `test` para ti tan pronto como creas un proyecto de Rails usando `rails new` _nombre_de_la_aplicación_. Si enumeras el contenido de este directorio, verás:

```bash
$ ls -F test
application_system_test_case.rb  controllers/                     helpers/                         mailers/                         system/
channels/                        fixtures/                        integration/                     models/                          test_helper.rb
```

Los directorios `helpers`, `mailers` y `models` están destinados a contener pruebas para los ayudantes de vista, los remitentes de correo y los modelos, respectivamente. El directorio `channels` está destinado a contener pruebas para la conexión y los canales de Action Cable. El directorio `controllers` está destinado a contener pruebas para los controladores, las rutas y las vistas. El directorio `integration` está destinado a contener pruebas para las interacciones entre controladores.

El directorio de pruebas de sistema contiene pruebas de sistema, que se utilizan para probar completamente la aplicación en el navegador. Las pruebas de sistema te permiten probar tu aplicación de la misma manera en que tus usuarios la experimentan y te ayudan a probar tu JavaScript también. Las pruebas de sistema heredan de Capybara y realizan pruebas en el navegador para tu aplicación.

Las fixtures son una forma de organizar los datos de prueba; se encuentran en el directorio `fixtures`.

También se creará un directorio `jobs` cuando se genere por primera vez una prueba asociada.

El archivo `test_helper.rb` contiene la configuración predeterminada para tus pruebas.

El archivo `application_system_test_case.rb` contiene la configuración predeterminada para tus pruebas de sistema.

### El entorno de pruebas

Por defecto, cada aplicación de Rails tiene tres entornos: desarrollo, prueba y producción.

La configuración de cada entorno se puede modificar de manera similar. En este caso, podemos modificar nuestro entorno de pruebas cambiando las opciones que se encuentran en `config/environments/test.rb`.

NOTA: Tus pruebas se ejecutan bajo `RAILS_ENV=test`.

### Rails se encuentra con Minitest

Si recuerdas, usamos el comando `bin/rails generate model` en la guía [Getting Started with Rails](getting_started.html). Creamos nuestro primer modelo y, entre otras cosas, creó plantillas de prueba en el directorio `test`:

```bash
$ bin/rails generate model article title:string body:text
...
create  app/models/article.rb
create  test/models/article_test.rb
create  test/fixtures/articles.yml
...
```

La plantilla de prueba predeterminada en `test/models/article_test.rb` se ve así:

```ruby
require "test_helper"

class ArticleTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
```

Un examen línea por línea de este archivo te ayudará a familiarizarte con el código y la terminología de las pruebas en Rails.

```ruby
require "test_helper"
```

Al requerir este archivo, `test_helper.rb`, se carga la configuración predeterminada para ejecutar nuestras pruebas. Incluiremos esto en todas las pruebas que escribamos, por lo que cualquier método agregado a este archivo estará disponible para todas nuestras pruebas.

```ruby
class ArticleTest < ActiveSupport::TestCase
```

La clase `ArticleTest` define un _caso de prueba_ porque hereda de `ActiveSupport::TestCase`. `ArticleTest` tiene todos los métodos disponibles de `ActiveSupport::TestCase`. Más adelante en esta guía, veremos algunos de los métodos que nos proporciona.

Cualquier método definido dentro de una clase heredada de `Minitest::Test` (que es la superclase de `ActiveSupport::TestCase`) que comienza con `test_` se llama simplemente una prueba. Por lo tanto, los métodos definidos como `test_password` y `test_valid_password` son nombres de prueba válidos y se ejecutan automáticamente cuando se ejecuta el caso de prueba.

Rails también agrega un método `test` que toma un nombre de prueba y un bloque. Genera una prueba normal de `Minitest::Unit` con nombres de método con el prefijo `test_`. Por lo tanto, no tienes que preocuparte por nombrar los métodos, y puedes escribir algo como:

```ruby
test "the truth" do
  assert true
end
```

Lo cual es aproximadamente lo mismo que escribir esto:
```ruby
def test_the_truth
  assert true
end
```

Aunque aún se pueden usar definiciones de métodos regulares, el uso de la macro `test` permite un nombre de prueba más legible.

NOTA: El nombre del método se genera reemplazando los espacios por guiones bajos. El resultado no necesita ser un identificador válido de Ruby, ya que el nombre puede contener caracteres de puntuación, etc. Esto se debe a que en Ruby técnicamente cualquier cadena puede ser un nombre de método. Esto puede requerir el uso de llamadas `define_method` y `send` para funcionar correctamente, pero formalmente hay pocas restricciones en el nombre.

A continuación, veamos nuestra primera afirmación:

```ruby
assert true
```

Una afirmación es una línea de código que evalúa un objeto (o expresión) en busca de resultados esperados. Por ejemplo, una afirmación puede verificar:

* ¿este valor es igual a aquel valor?
* ¿este objeto es nulo?
* ¿esta línea de código genera una excepción?
* ¿la contraseña del usuario tiene más de 5 caracteres?

Cada prueba puede contener una o más afirmaciones, sin restricciones en cuanto a la cantidad de afirmaciones permitidas. Solo cuando todas las afirmaciones tienen éxito, la prueba se aprueba.

#### Tu primera prueba fallida

Para ver cómo se informa de un fallo en la prueba, puedes agregar una prueba fallida al caso de prueba `article_test.rb`.

```ruby
test "no debería guardar un artículo sin título" do
  article = Article.new
  assert_not article.save
end
```

Ejecutemos esta prueba recién agregada (donde `6` es el número de línea donde se define la prueba).

```bash
$ bin/rails test test/models/article_test.rb:6
Opciones de ejecución: --seed 44656

# Ejecutando:

F

Fallo:
ArticleTest#test_should_not_save_article_without_title [/ruta/al/blog/test/models/article_test.rb:6]:
Se esperaba que true fuera nil o false


bin/rails test test/models/article_test.rb:6



Terminado en 0.023918s, 41.8090 ejecuciones/s, 41.8090 afirmaciones/s.

1 ejecuciones, 1 afirmaciones, 1 fallos, 0 errores, 0 omisiones
```

En la salida, `F` denota un fallo. Puedes ver la traza correspondiente mostrada bajo `Fallo` junto con el nombre de la prueba fallida. Las siguientes líneas contienen la traza de la pila seguida de un mensaje que menciona el valor real y el valor esperado por la afirmación. Los mensajes de fallo de afirmación predeterminados proporcionan suficiente información para ayudar a localizar el error. Para hacer que el mensaje de fallo de la afirmación sea más legible, cada afirmación proporciona un parámetro de mensaje opcional, como se muestra aquí:

```ruby
test "no debería guardar un artículo sin título" do
  article = Article.new
  assert_not article.save, "Se guardó el artículo sin título"
end
```

Al ejecutar esta prueba, se muestra el mensaje de fallo de afirmación más amigable:

```
Fallo:
ArticleTest#test_should_not_save_article_without_title [/ruta/al/blog/test/models/article_test.rb:6]:
Se guardó el artículo sin título
```

Ahora, para que esta prueba pase, podemos agregar una validación a nivel de modelo para el campo _title_.

```ruby
class Article < ApplicationRecord
  validates :title, presence: true
end
```

Ahora la prueba debería pasar. Verifiquemos ejecutando la prueba nuevamente:

```bash
$ bin/rails test test/models/article_test.rb:6
Opciones de ejecución: --seed 31252

# Ejecutando:

.

Terminado en 0.027476s, 36.3952 ejecuciones/s, 36.3952 afirmaciones/s.

1 ejecuciones, 1 afirmaciones, 0 fallos, 0 errores, 0 omisiones
```

Ahora, si te diste cuenta, primero escribimos una prueba que falla para una funcionalidad deseada, luego escribimos algún código que agrega la funcionalidad y finalmente nos aseguramos de que nuestra prueba pase. Este enfoque para el desarrollo de software se conoce como [_Desarrollo Dirigido por Pruebas_ (TDD)](http://c2.com/cgi/wiki?TestDrivenDevelopment).

#### Cómo se ve un error

Para ver cómo se informa un error, aquí hay una prueba que contiene un error:

```ruby
test "debería informar un error" do
  # some_undefined_variable no está definida en otro lugar del caso de prueba
  some_undefined_variable
  assert true
end
```

Ahora puedes ver aún más salida en la consola al ejecutar las pruebas:

```bash
$ bin/rails test test/models/article_test.rb
Opciones de ejecución: --seed 1808

# Ejecutando:

.E

Error:
ArticleTest#test_should_report_error:
NameError: undefined local variable or method 'some_undefined_variable' for #<ArticleTest:0x007fee3aa71798>
    test/models/article_test.rb:11:in 'block in <class:ArticleTest>'


bin/rails test test/models/article_test.rb:9



Terminado en 0.040609s, 49.2500 ejecuciones/s, 24.6250 afirmaciones/s.

2 ejecuciones, 1 afirmaciones, 0 fallos, 1 errores, 0 omisiones
```

Observa la 'E' en la salida. Denota una prueba con error.

NOTA: La ejecución de cada método de prueba se detiene tan pronto como se encuentra cualquier error o fallo de afirmación, y el conjunto de pruebas continúa con el siguiente método. Todos los métodos de prueba se ejecutan en orden aleatorio. La opción [`config.active_support.test_order`][] se puede utilizar para configurar el orden de las pruebas.

Cuando una prueba falla, se muestra la traza correspondiente. Por defecto, Rails filtra esa traza y solo imprime las líneas relevantes a tu aplicación. Esto elimina el ruido del framework y ayuda a centrarse en tu código. Sin embargo, hay situaciones en las que deseas ver la traza completa. Establece el argumento `-b` (o `--backtrace`) para habilitar este comportamiento:
```bash
$ bin/rails test -b test/models/article_test.rb
```

Si queremos que este test pase, podemos modificarlo para usar `assert_raises` de la siguiente manera:

```ruby
test "should report error" do
  # some_undefined_variable no está definida en otro lugar en el caso de prueba
  assert_raises(NameError) do
    some_undefined_variable
  end
end
```

Este test debería pasar ahora.


### Asertos Disponibles

Hasta ahora has visto algunos de los asertos que están disponibles. Los asertos son los trabajadores de las pruebas. Son los que realmente realizan las comprobaciones para asegurarse de que las cosas van según lo planeado.

Aquí tienes un extracto de los asertos que puedes usar con
[`Minitest`](https://github.com/minitest/minitest), la biblioteca de pruebas predeterminada
usada por Rails. El parámetro `[msg]` es un mensaje de cadena opcional que puedes
especificar para que los mensajes de fallo de tus pruebas sean más claros.

| Aserto                                                            | Propósito |
| ----------------------------------------------------------------- | --------- |
| `assert( test, [msg] )`                                           | Asegura que `test` sea verdadero.|
| `assert_not( test, [msg] )`                                       | Asegura que `test` sea falso.|
| `assert_equal( expected, actual, [msg] )`                         | Asegura que `expected == actual` sea verdadero.|
| `assert_not_equal( expected, actual, [msg] )`                     | Asegura que `expected != actual` sea verdadero.|
| `assert_same( expected, actual, [msg] )`                          | Asegura que `expected.equal?(actual)` sea verdadero.|
| `assert_not_same( expected, actual, [msg] )`                      | Asegura que `expected.equal?(actual)` sea falso.|
| `assert_nil( obj, [msg] )`                                        | Asegura que `obj.nil?` sea verdadero.|
| `assert_not_nil( obj, [msg] )`                                    | Asegura que `obj.nil?` sea falso.|
| `assert_empty( obj, [msg] )`                                      | Asegura que `obj` esté `empty?`.|
| `assert_not_empty( obj, [msg] )`                                  | Asegura que `obj` no esté `empty?`.|
| `assert_match( regexp, string, [msg] )`                           | Asegura que una cadena coincida con la expresión regular.|
| `assert_no_match( regexp, string, [msg] )`                        | Asegura que una cadena no coincida con la expresión regular.|
| `assert_includes( collection, obj, [msg] )`                       | Asegura que `obj` esté en `collection`.|
| `assert_not_includes( collection, obj, [msg] )`                   | Asegura que `obj` no esté en `collection`.|
| `assert_in_delta( expected, actual, [delta], [msg] )`             | Asegura que los números `expected` y `actual` estén dentro de `delta` uno del otro.|
| `assert_not_in_delta( expected, actual, [delta], [msg] )`         | Asegura que los números `expected` y `actual` no estén dentro de `delta` uno del otro.|
| `assert_in_epsilon ( expected, actual, [epsilon], [msg] )`        | Asegura que los números `expected` y `actual` tengan un error relativo menor que `epsilon`.|
| `assert_not_in_epsilon ( expected, actual, [epsilon], [msg] )`    | Asegura que los números `expected` y `actual` tengan un error relativo no menor que `epsilon`.|
| `assert_throws( symbol, [msg] ) { block }`                        | Asegura que el bloque dado lance el símbolo.|
| `assert_raises( exception1, exception2, ... ) { block }`          | Asegura que el bloque dado lance una de las excepciones dadas.|
| `assert_instance_of( class, obj, [msg] )`                         | Asegura que `obj` sea una instancia de `class`.|
| `assert_not_instance_of( class, obj, [msg] )`                     | Asegura que `obj` no sea una instancia de `class`.|
| `assert_kind_of( class, obj, [msg] )`                             | Asegura que `obj` sea una instancia de `class` o descienda de ella.|
| `assert_not_kind_of( class, obj, [msg] )`                         | Asegura que `obj` no sea una instancia de `class` y no descienda de ella.|
| `assert_respond_to( obj, symbol, [msg] )`                         | Asegura que `obj` responda a `symbol`.|
| `assert_not_respond_to( obj, symbol, [msg] )`                     | Asegura que `obj` no responda a `symbol`.|
| `assert_operator( obj1, operator, [obj2], [msg] )`                | Asegura que `obj1.operator(obj2)` sea verdadero.|
| `assert_not_operator( obj1, operator, [obj2], [msg] )`            | Asegura que `obj1.operator(obj2)` sea falso.|
| `assert_predicate ( obj, predicate, [msg] )`                      | Asegura que `obj.predicate` sea verdadero, por ejemplo `assert_predicate str, :empty?`|
| `assert_not_predicate ( obj, predicate, [msg] )`                  | Asegura que `obj.predicate` sea falso, por ejemplo `assert_not_predicate str, :empty?`|
| `flunk( [msg] )`                                                  | Asegura el fallo. Esto es útil para marcar explícitamente una prueba que aún no está terminada.|

Estos son un subconjunto de los asertos que minitest admite. Para obtener una lista exhaustiva y más actualizada, consulta la
[documentación de la API de Minitest](http://docs.seattlerb.org/minitest/), específicamente
[`Minitest::Assertions`](http://docs.seattlerb.org/minitest/Minitest/Assertions.html).

Debido a la naturaleza modular del marco de pruebas, es posible crear tus propios asertos. De hecho, eso es exactamente lo que hace Rails. Incluye algunos asertos especializados para facilitar tu vida.

NOTA: Crear tus propios asertos es un tema avanzado que no cubriremos en este tutorial.

### Asertos Específicos de Rails

Rails agrega algunos asertos personalizados a la biblioteca `minitest`:

| Afirmación                                                                         | Propósito |
| --------------------------------------------------------------------------------- | ------- |
| [`assert_difference(expresiones, diferencia = 1, mensaje = nil) {...}`](https://api.rubyonrails.org/classes/ActiveSupport/Testing/Assertions.html#method-i-assert_difference) | Prueba la diferencia numérica entre el valor de retorno de una expresión como resultado de lo que se evalúa en el bloque proporcionado.|
| [`assert_no_difference(expresiones, mensaje = nil, &bloque)`](https://api.rubyonrails.org/classes/ActiveSupport/Testing/Assertions.html#method-i-assert_no_difference) | Asegura que el resultado numérico de evaluar una expresión no cambie antes y después de invocar el bloque proporcionado.|
| [`assert_changes(expresiones, mensaje = nil, from:, to:, &bloque)`](https://api.rubyonrails.org/classes/ActiveSupport/Testing/Assertions.html#method-i-assert_changes) | Prueba que el resultado de evaluar una expresión cambie después de invocar el bloque proporcionado.|
| [`assert_no_changes(expresiones, mensaje = nil, &bloque)`](https://api.rubyonrails.org/classes/ActiveSupport/Testing/Assertions.html#method-i-assert_no_changes) | Prueba que el resultado de evaluar una expresión no cambie después de invocar el bloque proporcionado.|
| [`assert_nothing_raised { bloque }`](https://api.rubyonrails.org/classes/ActiveSupport/Testing/Assertions.html#method-i-assert_nothing_raised) | Asegura que el bloque dado no genere ninguna excepción.|
| [`assert_recognizes(opciones_esperadas, ruta, extras={}, mensaje=nil)`](https://api.rubyonrails.org/classes/ActionDispatch/Assertions/RoutingAssertions.html#method-i-assert_recognizes) | Asegura que el enrutamiento de la ruta dada se maneje correctamente y que las opciones analizadas (dadas en el hash opciones_esperadas) coincidan con la ruta. Básicamente, asegura que Rails reconozca la ruta dada por opciones_esperadas.|
| [`assert_generates(ruta_esperada, opciones, defectos={}, extras = {}, mensaje=nil)`](https://api.rubyonrails.org/classes/ActionDispatch/Assertions/RoutingAssertions.html#method-i-assert_generates) | Asegura que las opciones proporcionadas se puedan utilizar para generar la ruta proporcionada. Esto es lo contrario de assert_recognizes. El parámetro extras se utiliza para indicar los nombres y valores de los parámetros de solicitud adicionales que estarían en una cadena de consulta. El parámetro mensaje te permite especificar un mensaje de error personalizado para las fallas de la afirmación.|
| [`assert_response(tipo, mensaje = nil)`](https://api.rubyonrails.org/classes/ActionDispatch/Assertions/ResponseAssertions.html#method-i-assert_response) | Asegura que la respuesta tenga un código de estado específico. Puedes especificar `:success` para indicar 200-299, `:redirect` para indicar 300-399, `:missing` para indicar 404, o `:error` para coincidir con el rango 500-599. También puedes pasar un número de estado explícito o su equivalente simbólico. Para obtener más información, consulta la [lista completa de códigos de estado](https://rubydoc.info/gems/rack/Rack/Utils#HTTP_STATUS_CODES-constant) y cómo funciona su [mapeo](https://rubydoc.info/gems/rack/Rack/Utils#SYMBOL_TO_STATUS_CODE-constant).|
| [`assert_redirected_to(opciones = {}, mensaje=nil)`](https://api.rubyonrails.org/classes/ActionDispatch/Assertions/ResponseAssertions.html#method-i-assert_redirected_to) | Asegura que la respuesta sea una redirección a una URL que coincida con las opciones proporcionadas. También puedes pasar rutas con nombre como `assert_redirected_to root_path` y objetos de Active Record como `assert_redirected_to @article`.|

Verás el uso de algunas de estas afirmaciones en el próximo capítulo.

### Una breve nota sobre casos de prueba

Todas las afirmaciones básicas como `assert_equal` definidas en `Minitest::Assertions` también están disponibles en las clases que usamos en nuestros propios casos de prueba. De hecho, Rails proporciona las siguientes clases para que heredes de ellas:

* [`ActiveSupport::TestCase`](https://api.rubyonrails.org/classes/ActiveSupport/TestCase.html)
* [`ActionMailer::TestCase`](https://api.rubyonrails.org/classes/ActionMailer/TestCase.html)
* [`ActionView::TestCase`](https://api.rubyonrails.org/classes/ActionView/TestCase.html)
* [`ActiveJob::TestCase`](https://api.rubyonrails.org/classes/ActiveJob/TestCase.html)
* [`ActionDispatch::IntegrationTest`](https://api.rubyonrails.org/classes/ActionDispatch/IntegrationTest.html)
* [`ActionDispatch::SystemTestCase`](https://api.rubyonrails.org/classes/ActionDispatch/SystemTestCase.html)
* [`Rails::Generators::TestCase`](https://api.rubyonrails.org/classes/Rails/Generators/TestCase.html)

Cada una de estas clases incluye `Minitest::Assertions`, lo que nos permite usar todas las afirmaciones básicas en nuestras pruebas.

NOTA: Para obtener más información sobre `Minitest`, consulta [su documentación](http://docs.seattlerb.org/minitest).

### El ejecutor de pruebas de Rails

Podemos ejecutar todas nuestras pruebas a la vez utilizando el comando `bin/rails test`.

O podemos ejecutar un solo archivo de pruebas pasando al comando `bin/rails test` el nombre del archivo que contiene los casos de prueba.

```bash
$ bin/rails test test/models/article_test.rb
Opciones de ejecución: --seed 1559

# Ejecutando:

..

Finalizado en 0.027034s, 73.9810 ejecuciones/s, 110.9715 afirmaciones/s.

2 ejecuciones, 3 afirmaciones, 0 fallas, 0 errores, 0 omisiones
```

Esto ejecutará todos los métodos de prueba del caso de prueba.

También puedes ejecutar un método de prueba específico del caso de prueba proporcionando la
bandera `-n` o `--name` y el nombre del método de prueba.

```bash
$ bin/rails test test/models/article_test.rb -n test_the_truth
Opciones de ejecución: -n test_the_truth --seed 43583

# Ejecutando:

.

Pruebas finalizadas en 0.009064s, 110.3266 pruebas/s, 110.3266 afirmaciones/s.

1 pruebas, 1 afirmaciones, 0 fallas, 0 errores, 0 omisiones
```

También puedes ejecutar una prueba en una línea específica proporcionando el número de línea.

```bash
$ bin/rails test test/models/article_test.rb:6 # ejecutar prueba específica y línea
```

También puedes ejecutar un directorio completo de pruebas proporcionando la ruta del directorio.

```bash
$ bin/rails test test/controllers # ejecutar todas las pruebas de un directorio específico
```

El ejecutor de pruebas también proporciona muchas otras características como detenerse en caso de falla, posponer la salida de las pruebas
hasta el final de la ejecución de las pruebas, entre otras. Consulta la documentación del ejecutor de pruebas de la siguiente manera:

```bash
$ bin/rails test -h
Uso: rails test [opciones] [archivos o directorios]

Puedes ejecutar una sola prueba agregando un número de línea a un nombre de archivo:

    bin/rails test test/models/user_test.rb:27

Puedes ejecutar varios archivos y directorios al mismo tiempo:

    bin/rails test test/controllers test/integration/login_test.rb

De forma predeterminada, los errores y fallas de las pruebas se informan en línea durante la ejecución.

Opciones de minitest:
    -h, --help                       Muestra esta ayuda.
        --no-plugins                 Ignora la carga automática de complementos de minitest (o establece $MT_NO_PLUGINS).
    -s, --seed SEED                  Establece la semilla aleatoria. También se puede establecer mediante env. Ej: SEED=n rake
    -v, --verbose                    Detallado. Muestra el progreso al procesar archivos.
    -n, --name PATTERN               Filtra la ejecución en /regexp/ o cadena.
        --exclude PATTERN            Excluye /regexp/ o cadena de la ejecución.

Extensiones conocidas: rails, pride
    -w, --warnings                   Ejecuta con advertencias de Ruby habilitadas
    -e, --environment ENV            Ejecuta las pruebas en el entorno ENV
    -b, --backtrace                  Muestra la traza completa
    -d, --defer-output               Muestra los errores y fallas de las pruebas después de la ejecución de las pruebas
    -f, --fail-fast                  Aborta la ejecución de las pruebas en caso de la primera falla o error
    -c, --[no-]color                 Habilita el color en la salida
    -p, --pride                      Orgullo. ¡Muestra tu orgullo por las pruebas!
```
### Ejecución de pruebas en Integración Continua (CI)

Para ejecutar todas las pruebas en un entorno de CI, solo necesitas un comando:

```bash
$ bin/rails test
```

Si estás utilizando [Pruebas de Sistema](#pruebas-de-sistema), `bin/rails test` no las ejecutará, ya que pueden ser lentas. Para ejecutarlas también, agrega otro paso de CI que ejecute `bin/rails test:system`, o cambia tu primer paso a `bin/rails test:all`, que ejecuta todas las pruebas, incluyendo las pruebas de sistema.

Pruebas Paralelas
----------------

Las pruebas paralelas te permiten paralelizar tu conjunto de pruebas. Si bien la bifurcación de procesos es el método predeterminado, también se admite el uso de hilos. Ejecutar pruebas en paralelo reduce el tiempo que tarda en ejecutarse todo el conjunto de pruebas.

### Pruebas Paralelas con Procesos

El método de paralelización predeterminado es bifurcar procesos utilizando el sistema DRb de Ruby. Los procesos se bifurcan en función del número de trabajadores proporcionados. El número predeterminado es el número real de núcleos en la máquina en la que te encuentras, pero se puede cambiar mediante el número pasado al método parallelize.

Para habilitar la paralelización, agrega lo siguiente a tu `test_helper.rb`:

```ruby
class ActiveSupport::TestCase
  parallelize(workers: 2)
end
```

El número de trabajadores pasado es el número de veces que se bifurcará el proceso. Es posible que desees paralelizar tu conjunto de pruebas local de manera diferente a tu CI, por lo que se proporciona una variable de entorno para poder cambiar fácilmente el número de trabajadores que debe usar una ejecución de prueba:

```bash
$ PARALLEL_WORKERS=15 bin/rails test
```

Cuando se paralelizan las pruebas, Active Record maneja automáticamente la creación de una base de datos y la carga del esquema en la base de datos para cada proceso. Las bases de datos se agregarán un sufijo con el número correspondiente al trabajador. Por ejemplo, si tienes 2 trabajadores, las pruebas crearán `test-database-0` y `test-database-1`, respectivamente.

Si el número de trabajadores pasado es 1 o menos, los procesos no se bifurcarán y las pruebas no se paralelizarán, y las pruebas usarán la base de datos original `test-database`.

Se proporcionan dos ganchos, uno se ejecuta cuando se bifurca el proceso y otro se ejecuta antes de que se cierre el proceso bifurcado. Estos pueden ser útiles si tu aplicación utiliza múltiples bases de datos o realiza otras tareas que dependen del número de trabajadores.

El método `parallelize_setup` se llama justo después de que se bifurcan los procesos. El método `parallelize_teardown` se llama justo antes de que se cierren los procesos.

```ruby
class ActiveSupport::TestCase
  parallelize_setup do |worker|
    # configurar bases de datos
  end

  parallelize_teardown do |worker|
    # limpiar bases de datos
  end

  parallelize(workers: :number_of_processors)
end
```

Estos métodos no son necesarios ni están disponibles cuando se utiliza la prueba paralela con hilos.

### Pruebas Paralelas con Hilos

Si prefieres utilizar hilos o estás utilizando JRuby, se proporciona una opción de paralelización con hilos. El paralelizador con hilos está respaldado por el `Parallel::Executor` de Minitest.

Para cambiar el método de paralelización para utilizar hilos en lugar de bifurcaciones, agrega lo siguiente a tu `test_helper.rb`:

```ruby
class ActiveSupport::TestCase
  parallelize(workers: :number_of_processors, with: :threads)
end
```

Las aplicaciones de Rails generadas desde JRuby o TruffleRuby incluirán automáticamente la opción `with: :threads`.

El número de trabajadores pasado a `parallelize` determina el número de hilos que utilizarán las pruebas. Es posible que desees paralelizar tu conjunto de pruebas local de manera diferente a tu CI, por lo que se proporciona una variable de entorno para poder cambiar fácilmente el número de trabajadores que debe usar una ejecución de prueba:

```bash
$ PARALLEL_WORKERS=15 bin/rails test
```

### Pruebas de Transacciones Paralelas

Rails envuelve automáticamente cualquier caso de prueba en una transacción de base de datos que se deshace después de que se completa la prueba. Esto hace que los casos de prueba sean independientes entre sí y los cambios en la base de datos solo son visibles dentro de una sola prueba.

Cuando deseas probar código que ejecuta transacciones paralelas en hilos, las transacciones pueden bloquearse entre sí porque ya están anidadas bajo la transacción de prueba.

Puedes deshabilitar las transacciones en una clase de caso de prueba configurando `self.use_transactional_tests = false`:

```ruby
class WorkerTest < ActiveSupport::TestCase
  self.use_transactional_tests = false

  test "transacciones paralelas" do
    # iniciar algunos hilos que creen transacciones
  end
end
```

NOTA: Con las pruebas transaccionales deshabilitadas, debes limpiar cualquier dato que las pruebas creen, ya que los cambios no se deshacen automáticamente después de que se completa la prueba.

### Umbral para paralelizar pruebas

La ejecución de pruebas en paralelo agrega una sobrecarga en términos de configuración de la base de datos y carga de fixtures. Debido a esto, Rails no paralelizará las ejecuciones que involucren menos de 50 pruebas.

Puedes configurar este umbral en tu `test.rb`:
```ruby
config.active_support.test_parallelization_threshold = 100
```

Y también al configurar la paralelización a nivel de caso de prueba:

```ruby
class ActiveSupport::TestCase
  parallelize threshold: 100
end
```

La base de datos de pruebas
---------------------------

Casi todas las aplicaciones de Rails interactúan ampliamente con una base de datos y, como resultado, sus pruebas también necesitarán una base de datos con la que interactuar. Para escribir pruebas eficientes, deberás entender cómo configurar esta base de datos y poblarla con datos de muestra.

Por defecto, cada aplicación de Rails tiene tres entornos: desarrollo, prueba y producción. La base de datos para cada uno de ellos se configura en `config/database.yml`.

Una base de datos de pruebas dedicada te permite configurar e interactuar con datos de prueba de forma aislada. De esta manera, tus pruebas pueden manipular datos de prueba con confianza, sin preocuparse por los datos en las bases de datos de desarrollo o producción.

### Mantener el esquema de la base de datos de pruebas

Para ejecutar tus pruebas, tu base de datos de pruebas deberá tener la estructura actual. El ayudante de pruebas verifica si tu base de datos de pruebas tiene migraciones pendientes. Intentará cargar tu `db/schema.rb` o `db/structure.sql` en la base de datos de pruebas. Si aún hay migraciones pendientes, se generará un error. Esto suele indicar que tu esquema no está completamente migrado. Ejecutar las migraciones en la base de datos de desarrollo (`bin/rails db:migrate`) actualizará el esquema.

NOTA: Si se realizaron modificaciones en migraciones existentes, la base de datos de pruebas debe reconstruirse. Esto se puede hacer ejecutando `bin/rails db:test:prepare`.

### Todo sobre los fixtures

Para buenas pruebas, deberás pensar en cómo configurar los datos de prueba. En Rails, puedes hacer esto definiendo y personalizando fixtures. Puedes encontrar documentación completa en la [documentación de la API de Fixtures](https://api.rubyonrails.org/classes/ActiveRecord/FixtureSet.html).

#### ¿Qué son los fixtures?

_Fixtures_ es una palabra elegante para datos de muestra. Los fixtures te permiten poblar tu base de datos de pruebas con datos predefinidos antes de que se ejecuten tus pruebas. Los fixtures son independientes de la base de datos y se escriben en YAML. Hay un archivo por modelo.

NOTA: Los fixtures no están diseñados para crear todos los objetos que tus pruebas necesitan, y se gestionan mejor cuando solo se utilizan para datos predeterminados que se pueden aplicar al caso común.

Encontrarás los fixtures en tu directorio `test/fixtures`. Cuando ejecutas `bin/rails generate model` para crear un nuevo modelo, Rails crea automáticamente stubs de fixtures en este directorio.

#### YAML

Los fixtures en formato YAML son una forma amigable para describir tus datos de muestra. Estos tipos de fixtures tienen la extensión de archivo **.yml** (como `users.yml`).

Aquí tienes un ejemplo de un archivo de fixture YAML:

```yaml
# ¡Mira y admira! ¡Soy un comentario YAML!
david:
  name: David Heinemeier Hansson
  birthday: 1979-10-15
  profession: Desarrollo de sistemas

steve:
  name: Steve Ross Kellock
  birthday: 1974-09-27
  profession: chico con teclado
```

Cada fixture recibe un nombre seguido de una lista indentada de pares clave/valor separados por dos puntos. Los registros suelen separarse por una línea en blanco. Puedes colocar comentarios en un archivo de fixture utilizando el carácter # en la primera columna.

Si estás trabajando con [asociaciones](/association_basics.html), puedes definir un nodo de referencia entre dos fixtures diferentes. Aquí tienes un ejemplo con una asociación `belongs_to`/`has_many`:

```yaml
# test/fixtures/categories.yml
about:
  name: Acerca de
```

```yaml
# test/fixtures/articles.yml
first:
  title: ¡Bienvenido a Rails!
  category: about
```

```yaml
# test/fixtures/action_text/rich_texts.yml
first_content:
  record: first (Article)
  name: content
  body: <div>Hola, desde <strong>un fixture</strong></div>
```

Observa que la clave `category` del primer artículo encontrado en `fixtures/articles.yml` tiene un valor de `about`, y que la clave `record` de la entrada `first_content` encontrada en `fixtures/action_text/rich_texts.yml` tiene un valor de `first (Article)`. Esto indica a Active Record que cargue la categoría `about` encontrada en `fixtures/categories.yml` para el primero, y que Action Text cargue el artículo `first` encontrado en `fixtures/articles.yml` para el segundo.

NOTA: Para que las asociaciones se refieran entre sí por nombre, puedes utilizar el nombre del fixture en lugar de especificar el atributo `id:` en los fixtures asociados. Rails asignará automáticamente una clave primaria para que sea consistente entre ejecuciones. Para obtener más información sobre este comportamiento de asociación, lee la [documentación de la API de Fixtures](https://api.rubyonrails.org/classes/ActiveRecord/FixtureSet.html).

#### Fixtures de archivos adjuntos

Al igual que otros modelos respaldados por Active Record, los registros de archivos adjuntos de Active Storage heredan de instancias de ActiveRecord::Base y, por lo tanto, se pueden poblar con fixtures.

Considera un modelo `Article` que tiene una imagen asociada como un archivo adjunto `thumbnail`, junto con datos de fixture en YAML:

```ruby
class Article
  has_one_attached :thumbnail
end
```

```yaml
# test/fixtures/articles.yml
first:
  title: Un artículo
```
Suponiendo que hay un archivo codificado [image/png][] en `test/fixtures/files/first.png`, las siguientes entradas de fixture YAML generarán los registros relacionados de `ActiveStorage::Blob` y `ActiveStorage::Attachment`:

```yaml
# test/fixtures/active_storage/blobs.yml
first_thumbnail_blob: <%= ActiveStorage::FixtureSet.blob filename: "first.png" %>
```

```yaml
# test/fixtures/active_storage/attachments.yml
first_thumbnail_attachment:
  name: thumbnail
  record: first (Article)
  blob: first_thumbnail_blob
```


#### ERB'in It Up

ERB te permite incrustar código Ruby dentro de las plantillas. El formato de fixture YAML se preprocesa con ERB cuando Rails carga los fixtures. Esto te permite usar Ruby para ayudarte a generar algunos datos de muestra. Por ejemplo, el siguiente código genera mil usuarios:

```erb
<% 1000.times do |n| %>
user_<%= n %>:
  username: <%= "user#{n}" %>
  email: <%= "user#{n}@example.com" %>
<% end %>
```

#### Fixtures en Acción

Rails carga automáticamente todos los fixtures desde el directorio `test/fixtures` de forma predeterminada. La carga implica tres pasos:

1. Eliminar cualquier dato existente de la tabla correspondiente al fixture.
2. Cargar los datos del fixture en la tabla.
3. Volcar los datos del fixture en un método en caso de que quieras acceder a ellos directamente.

CONSEJO: Para eliminar los datos existentes de la base de datos, Rails intenta deshabilitar los disparadores de integridad referencial (como las claves externas y las restricciones de verificación). Si estás obteniendo errores molestos de permisos al ejecutar pruebas, asegúrate de que el usuario de la base de datos tenga privilegios para deshabilitar estos disparadores en el entorno de prueba. (En PostgreSQL, solo los superusuarios pueden deshabilitar todos los disparadores. Lee más sobre los permisos de PostgreSQL [aquí](https://www.postgresql.org/docs/current/sql-altertable.html)).

#### Los Fixtures son Objetos de Active Record

Los fixtures son instancias de Active Record. Como se mencionó en el punto #3 anterior, puedes acceder al objeto directamente porque está disponible automáticamente como un método cuyo ámbito es local en el caso de prueba. Por ejemplo:

```ruby
# esto devolverá el objeto User para el fixture llamado david
users(:david)

# esto devolverá la propiedad id para david
users(:david).id

# también se pueden acceder a los métodos disponibles en la clase User
david = users(:david)
david.call(david.partner)
```

Para obtener varios fixtures a la vez, puedes pasar una lista de nombres de fixtures. Por ejemplo:

```ruby
# esto devolverá un array que contiene los fixtures david y steve
users(:david, :steve)
```


Pruebas de Modelos
------------------

Las pruebas de modelos se utilizan para probar los diversos modelos de tu aplicación.

Las pruebas de modelos de Rails se almacenan en el directorio `test/models`. Rails proporciona un generador para crear un esqueleto de prueba de modelo por ti.

```bash
$ bin/rails generate test_unit:model article title:string body:text
create  test/models/article_test.rb
create  test/fixtures/articles.yml
```

Las pruebas de modelos no tienen su propia superclase como `ActionMailer::TestCase`. En su lugar, heredan de [`ActiveSupport::TestCase`](https://api.rubyonrails.org/classes/ActiveSupport/TestCase.html).

Pruebas del Sistema
-------------------

Las pruebas del sistema te permiten probar las interacciones del usuario con tu aplicación, ejecutando pruebas en un navegador real o sin cabeza. Las pruebas del sistema utilizan Capybara en su interior.

Para crear pruebas del sistema en Rails, utiliza el directorio `test/system` en tu aplicación. Rails proporciona un generador para crear un esqueleto de prueba del sistema por ti.

```bash
$ bin/rails generate system_test users
      invoke test_unit
      create test/system/users_test.rb
```

Así es como se ve una prueba del sistema recién generada:

```ruby
require "application_system_test_case"

class UsersTest < ApplicationSystemTestCase
  # test "visiting the index" do
  #   visit users_url
  #
  #   assert_selector "h1", text: "Users"
  # end
end
```

De forma predeterminada, las pruebas del sistema se ejecutan con el controlador Selenium, utilizando el navegador Chrome y un tamaño de pantalla de 1400x1400. La siguiente sección explica cómo cambiar la configuración predeterminada.

### Cambiar la Configuración Predeterminada

Rails facilita cambiar la configuración predeterminada de las pruebas del sistema. Toda la configuración está abstraída para que puedas centrarte en escribir tus pruebas.

Cuando generas una nueva aplicación o un scaffold, se crea un archivo `application_system_test_case.rb` en el directorio de pruebas. Aquí es donde debe residir toda la configuración de tus pruebas del sistema.

Si deseas cambiar la configuración predeterminada, puedes cambiar lo que "impulsa" las pruebas del sistema. Por ejemplo, si deseas cambiar el controlador de Selenium a Cuprite. Primero agrega la gema `cuprite` a tu `Gemfile`. Luego, en tu archivo `application_system_test_case.rb`, haz lo siguiente:

```ruby
require "test_helper"
require "capybara/cuprite"

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  driven_by :cuprite
end
```

El nombre del controlador es un argumento requerido para `driven_by`. Los argumentos opcionales que se pueden pasar a `driven_by` son `:using` para el navegador (esto solo se utilizará con Selenium), `:screen_size` para cambiar el tamaño de la pantalla para las capturas de pantalla y `:options` que se pueden utilizar para establecer opciones admitidas por el controlador.
```ruby
require "test_helper"

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  driven_by :selenium, using: :firefox
end
```

Si desea utilizar un navegador sin cabeza, puede utilizar Headless Chrome o Headless Firefox agregando `headless_chrome` o `headless_firefox` en el argumento `:using`.

```ruby
require "test_helper"

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  driven_by :selenium, using: :headless_chrome
end
```

Si desea utilizar un navegador remoto, por ejemplo, [Headless Chrome en Docker](https://github.com/SeleniumHQ/docker-selenium), debe agregar la `url` remota a través de `options`.

```ruby
require "test_helper"

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  options = ENV["SELENIUM_REMOTE_URL"].present? ? { url: ENV["SELENIUM_REMOTE_URL"] } : {}
  driven_by :selenium, using: :headless_chrome, options: options
end
```

En este caso, la gema `webdrivers` ya no es necesaria. Puede eliminarla por completo o agregar la opción `require:` en el archivo `Gemfile`.

```ruby
# ...
group :test do
  gem "webdrivers", require: !ENV["SELENIUM_REMOTE_URL"] || ENV["SELENIUM_REMOTE_URL"].empty?
end
```

Ahora debería obtener una conexión al navegador remoto.

```bash
$ SELENIUM_REMOTE_URL=http://localhost:4444/wd/hub bin/rails test:system
```

Si su aplicación en prueba también se está ejecutando de forma remota, por ejemplo, en un contenedor Docker, Capybara necesita más información sobre cómo [llamar a servidores remotos](https://github.com/teamcapybara/capybara#calling-remote-servers).

```ruby
require "test_helper"

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  def setup
    Capybara.server_host = "0.0.0.0" # enlazar a todas las interfaces
    Capybara.app_host = "http://#{IPSocket.getaddress(Socket.gethostname)}" if ENV["SELENIUM_REMOTE_URL"].present?
    super
  end
  # ...
end
```

Ahora debería obtener una conexión al navegador y al servidor remotos, independientemente de si se está ejecutando en un contenedor Docker o en CI.

Si su configuración de Capybara requiere más ajustes que los proporcionados por Rails, esta configuración adicional se puede agregar al archivo `application_system_test_case.rb`.

Consulte la [documentación de Capybara](https://github.com/teamcapybara/capybara#setup) para obtener más configuraciones adicionales.

### Ayudante de captura de pantalla

El `ScreenshotHelper` es un ayudante diseñado para capturar capturas de pantalla de sus pruebas. Esto puede ser útil para ver el navegador en el punto en que falló una prueba o para ver las capturas de pantalla más tarde para depurar.

Se proporcionan dos métodos: `take_screenshot` y `take_failed_screenshot`. `take_failed_screenshot` se incluye automáticamente en `before_teardown` dentro de Rails.

El método de ayuda `take_screenshot` se puede incluir en cualquier lugar de sus pruebas para tomar una captura de pantalla del navegador.

### Implementación de una prueba de sistema

Ahora vamos a agregar una prueba de sistema a nuestra aplicación de blog. Demostraremos cómo escribir una prueba de sistema visitando la página de índice y creando un nuevo artículo de blog.

Si utilizó el generador de andamios, se creó automáticamente un esqueleto de prueba de sistema para usted. Si no utilizó el generador de andamios, comience creando un esqueleto de prueba de sistema.

```bash
$ bin/rails generate system_test articles
```

Debería haber creado un marcador de posición de archivo de prueba para nosotros. Con la salida del comando anterior, debería ver:

```
      invoke  test_unit
      create    test/system/articles_test.rb
```

Ahora abramos ese archivo y escribamos nuestra primera afirmación:

```ruby
require "application_system_test_case"

class ArticlesTest < ApplicationSystemTestCase
  test "viewing the index" do
    visit articles_path
    assert_selector "h1", text: "Articles"
  end
end
```

La prueba debería ver que hay un `h1` en la página de índice de artículos y pasar.

Ejecute las pruebas de sistema.

```bash
$ bin/rails test:system
```

NOTA: De forma predeterminada, ejecutar `bin/rails test` no ejecutará sus pruebas de sistema. Asegúrese de ejecutar `bin/rails test:system` para ejecutarlas realmente. También puede ejecutar `bin/rails test:all` para ejecutar todas las pruebas, incluidas las pruebas de sistema.

#### Creación de una prueba de sistema de artículos

Ahora probemos el flujo para crear un nuevo artículo en nuestro blog.

```ruby
test "should create Article" do
  visit articles_path

  click_on "New Article"

  fill_in "Title", with: "Creating an Article"
  fill_in "Body", with: "Created this article successfully!"

  click_on "Create Article"

  assert_text "Creating an Article"
end
```

El primer paso es llamar a `visit articles_path`. Esto llevará la prueba a la página de índice de artículos.

Luego, `click_on "New Article"` encontrará el botón "New Article" en la página de índice. Esto redirigirá el navegador a `/articles/new`.

Luego, la prueba completará el título y el cuerpo del artículo con el texto especificado. Una vez que se completan los campos, se hace clic en "Create Article", lo que enviará una solicitud POST para crear el nuevo artículo en la base de datos.

Seremos redirigidos de nuevo a la página de índice de artículos y allí afirmamos que el texto del título del nuevo artículo está en la página de índice de artículos.

#### Pruebas para múltiples tamaños de pantalla

Si desea probar tamaños móviles además de probar tamaños de escritorio, puede crear otra clase que herede de `ActionDispatch::SystemTestCase` y usarla en su conjunto de pruebas. En este ejemplo, se crea un archivo llamado `mobile_system_test_case.rb` en el directorio `/test` con la siguiente configuración.
```ruby
require "test_helper"

class MobileSystemTestCase < ActionDispatch::SystemTestCase
  driven_by :selenium, using: :chrome, screen_size: [375, 667]
end
```

Para utilizar esta configuración, crea una prueba dentro de `test/system` que herede de `MobileSystemTestCase`.
Ahora puedes probar tu aplicación utilizando diferentes configuraciones.

```ruby
require "mobile_system_test_case"

class PostsTest < MobileSystemTestCase
  test "visiting the index" do
    visit posts_url
    assert_selector "h1", text: "Posts"
  end
end
```

#### Llevándolo más lejos

La belleza de las pruebas de sistema es que son similares a las pruebas de integración en
que prueban la interacción del usuario con su controlador, modelo y vista, pero
las pruebas de sistema son mucho más robustas y realmente prueban su aplicación como si
un usuario real la estuviera utilizando. En el futuro, puedes probar cualquier cosa que el usuario
mismo haría en su aplicación, como comentar, eliminar artículos,
publicar artículos en borrador, etc.

Pruebas de Integración
-------------------

Las pruebas de integración se utilizan para probar cómo interactúan las diferentes partes de nuestra aplicación. Generalmente se utilizan para probar flujos de trabajo importantes dentro de nuestra aplicación.

Para crear pruebas de integración en Rails, utilizamos el directorio `test/integration` de nuestra aplicación. Rails proporciona un generador para crear una estructura básica de prueba de integración.

```bash
$ bin/rails generate integration_test user_flows
      exists  test/integration/
      create  test/integration/user_flows_test.rb
```

Esto es lo que parece una prueba de integración recién generada:

```ruby
require "test_helper"

class UserFlowsTest < ActionDispatch::IntegrationTest
  # test "the truth" do
  #   assert true
  # end
end
```

Aquí la prueba hereda de `ActionDispatch::IntegrationTest`. Esto hace que estén disponibles algunos ayudantes adicionales para usar en nuestras pruebas de integración.

### Ayudantes disponibles para pruebas de integración

Además de los ayudantes de prueba estándar, al heredar de `ActionDispatch::IntegrationTest` se incluyen algunos ayudantes adicionales para escribir pruebas de integración. Echemos un breve vistazo a las tres categorías de ayudantes que podemos elegir.

Para lidiar con el ejecutor de pruebas de integración, consulta [`ActionDispatch::Integration::Runner`](https://api.rubyonrails.org/classes/ActionDispatch/Integration/Runner.html).

Cuando realizamos solicitudes, tendremos [`ActionDispatch::Integration::RequestHelpers`](https://api.rubyonrails.org/classes/ActionDispatch/Integration/RequestHelpers.html) disponibles para su uso.

Si necesitamos modificar la sesión o el estado de nuestra prueba de integración, consulta [`ActionDispatch::Integration::Session`](https://api.rubyonrails.org/classes/ActionDispatch/Integration/Session.html) para obtener ayuda.

### Implementar una prueba de integración

Agreguemos una prueba de integración a nuestra aplicación de blog. Comenzaremos con un flujo de trabajo básico para crear un nuevo artículo de blog y verificar que todo funcione correctamente.

Comenzaremos generando la estructura básica de nuestra prueba de integración:

```bash
$ bin/rails generate integration_test blog_flow
```

Esto debería haber creado un archivo de prueba para nosotros. Con la salida del
comando anterior, deberíamos ver:

```
      invoke  test_unit
      create    test/integration/blog_flow_test.rb
```

Ahora abramos ese archivo y escribamos nuestra primera afirmación:

```ruby
require "test_helper"

class BlogFlowTest < ActionDispatch::IntegrationTest
  test "can see the welcome page" do
    get "/"
    assert_select "h1", "Welcome#index"
  end
end
```

Vamos a utilizar `assert_select` para consultar el HTML resultante de una solicitud en la sección "Pruebas de Vistas" a continuación. Se utiliza para probar la respuesta de nuestra solicitud mediante la afirmación de la presencia de elementos HTML clave y su contenido.

Cuando visitamos nuestra ruta raíz, deberíamos ver que se renderiza `welcome/index.html.erb` para la vista. Por lo tanto, esta afirmación debería pasar.

#### Creando una Integración de Artículos

¿Qué tal si probamos nuestra capacidad para crear un nuevo artículo en nuestro blog y ver el artículo resultante?

```ruby
test "can create an article" do
  get "/articles/new"
  assert_response :success

  post "/articles",
    params: { article: { title: "can create", body: "article successfully." } }
  assert_response :redirect
  follow_redirect!
  assert_response :success
  assert_select "p", "Title:\n  can create"
end
```

Desglosemos esta prueba para que podamos entenderla.

Comenzamos llamando a la acción `:new` en nuestro controlador de Artículos. Esta respuesta debería ser exitosa.

Después de esto, hacemos una solicitud POST a la acción `:create` de nuestro controlador de Artículos:

```ruby
post "/articles",
  params: { article: { title: "can create", body: "article successfully." } }
assert_response :redirect
follow_redirect!
```

Las dos líneas siguientes a la solicitud son para manejar la redirección que configuramos al crear un nuevo artículo.

NOTA: No olvides llamar a `follow_redirect!` si planeas hacer solicitudes posteriores después de una redirección.

Finalmente, podemos afirmar que nuestra respuesta fue exitosa y que nuestro nuevo artículo se puede leer en la página.

#### Llevándolo más lejos

Pudimos probar con éxito un flujo de trabajo muy pequeño para visitar nuestro blog y crear un nuevo artículo. Si queremos llevar esto más lejos, podríamos agregar pruebas para comentar, eliminar artículos o editar comentarios. Las pruebas de integración son un gran lugar para experimentar con todo tipo de casos de uso para nuestras aplicaciones.
Pruebas funcionales para tus controladores
-------------------------------------

En Rails, probar las diferentes acciones de un controlador es una forma de escribir pruebas funcionales. Recuerda que tus controladores manejan las solicitudes web entrantes a tu aplicación y eventualmente responden con una vista renderizada. Al escribir pruebas funcionales, estás probando cómo tus acciones manejan las solicitudes y el resultado o respuesta esperada, en algunos casos una vista HTML.

### Qué incluir en tus pruebas funcionales

Debes probar cosas como:

* ¿La solicitud web fue exitosa?
* ¿El usuario fue redirigido a la página correcta?
* ¿El usuario se autenticó correctamente?
* ¿Se mostró el mensaje apropiado al usuario en la vista?
* ¿Se mostró la información correcta en la respuesta?

La forma más fácil de ver las pruebas funcionales en acción es generar un controlador utilizando el generador de andamios:

```bash
$ bin/rails generate scaffold_controller article title:string body:text
...
create  app/controllers/articles_controller.rb
...
invoke  test_unit
create    test/controllers/articles_controller_test.rb
...
```

Esto generará el código del controlador y las pruebas para un recurso "Artículo". Puedes echar un vistazo al archivo `articles_controller_test.rb` en el directorio `test/controllers`.

Si ya tienes un controlador y solo quieres generar el código de andamio de prueba para cada una de las siete acciones predeterminadas, puedes usar el siguiente comando:

```bash
$ bin/rails generate test_unit:scaffold article
...
invoke  test_unit
create    test/controllers/articles_controller_test.rb
...
```

Echemos un vistazo a una de esas pruebas, `test_should_get_index` del archivo `articles_controller_test.rb`.

```ruby
# articles_controller_test.rb
class ArticlesControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get articles_url
    assert_response :success
  end
end
```

En la prueba `test_should_get_index`, Rails simula una solicitud en la acción llamada `index`, asegurándose de que la solicitud haya sido exitosa y también asegurando que se haya generado el cuerpo de respuesta correcto.

El método `get` inicia la solicitud web y llena los resultados en `@response`. Puede aceptar hasta 6 argumentos:

* La URI de la acción del controlador que estás solicitando. Esto puede ser en forma de una cadena o un ayudante de ruta (por ejemplo, `articles_url`).
* `params`: opción con un hash de parámetros de solicitud para pasar a la acción (por ejemplo, parámetros de cadena de consulta o variables de artículo).
* `headers`: para establecer los encabezados que se enviarán con la solicitud.
* `env`: para personalizar el entorno de la solicitud según sea necesario.
* `xhr`: si la solicitud es una solicitud Ajax o no. Puede establecerse en true para marcar la solicitud como Ajax.
* `as`: para codificar la solicitud con un tipo de contenido diferente.

Todos estos argumentos de palabras clave son opcionales.

Ejemplo: Llamando a la acción `:show` para el primer `Artículo`, pasando un encabezado `HTTP_REFERER`:

```ruby
get article_url(Article.first), headers: { "HTTP_REFERER" => "http://example.com/home" }
```

Otro ejemplo: Llamando a la acción `:update` para el último `Artículo`, pasando un nuevo texto para el `title` en `params`, como una solicitud Ajax:

```ruby
patch article_url(Article.last), params: { article: { title: "actualizado" } }, xhr: true
```

Un ejemplo más: Llamando a la acción `:create` para crear un nuevo artículo, pasando texto para el `title` en `params`, como una solicitud JSON:

```ruby
post articles_path, params: { article: { title: "¡Ahoy!" } }, as: :json
```

NOTA: Si intentas ejecutar la prueba `test_should_create_article` de `articles_controller_test.rb`, fallará debido a la validación agregada a nivel de modelo y con razón.

Modifiquemos la prueba `test_should_create_article` en `articles_controller_test.rb` para que todas nuestras pruebas pasen:

```ruby
test "should create article" do
  assert_difference("Article.count") do
    post articles_url, params: { article: { body: "¡Rails es increíble!", title: "Hola Rails" } }
  end

  assert_redirected_to article_path(Article.last)
end
```

Ahora puedes intentar ejecutar todas las pruebas y deberían pasar.

NOTA: Si seguiste los pasos en la sección [Autenticación básica](getting_started.html#basic-authentication), deberás agregar autorización a cada encabezado de solicitud para que todas las pruebas pasen:

```ruby
post articles_url, params: { article: { body: "¡Rails es increíble!", title: "Hola Rails" } }, headers: { Authorization: ActionController::HttpAuthentication::Basic.encode_credentials("dhh", "secret") }
```

### Tipos de solicitud disponibles para pruebas funcionales

Si estás familiarizado con el protocolo HTTP, sabrás que `get` es un tipo de solicitud. Hay 6 tipos de solicitud admitidos en las pruebas funcionales de Rails:

* `get`
* `post`
* `patch`
* `put`
* `head`
* `delete`

Todos los tipos de solicitud tienen métodos equivalentes que puedes usar. En una aplicación C.R.U.D. típica, usarás `get`, `post`, `put` y `delete` con más frecuencia.
NOTA: Las pruebas funcionales no verifican si el tipo de solicitud especificado es aceptado por la acción, nos preocupa más el resultado. Las pruebas de solicitud existen para este caso de uso para hacer que sus pruebas sean más útiles.

### Pruebas de solicitudes XHR (Ajax)

Para probar solicitudes Ajax, puede especificar la opción `xhr: true` en los métodos `get`, `post`, `patch`, `put` y `delete`. Por ejemplo:

```ruby
test "solicitud Ajax" do
  article = articles(:one)
  get article_url(article), xhr: true

  assert_equal "hola mundo", @response.body
  assert_equal "text/javascript", @response.media_type
end
```

### Los Tres Hashes del Apocalipsis

Después de que se haya realizado y procesado una solicitud, tendrá 3 objetos Hash listos para usar:

* `cookies` - Cualquier cookie que esté configurada
* `flash` - Cualquier objeto que esté en el flash
* `session` - Cualquier objeto que esté en las variables de sesión

Como ocurre con los objetos Hash normales, puede acceder a los valores haciendo referencia a las claves por cadena. También puede hacer referencia a ellos por el nombre del símbolo. Por ejemplo:

```ruby
flash["gordon"]               flash[:gordon]
session["shmession"]          session[:shmession]
cookies["are_good_for_u"]     cookies[:are_good_for_u]
```

### Variables de instancia disponibles

**Después** de realizar una solicitud, también tiene acceso a tres variables de instancia en sus pruebas funcionales:

* `@controller` - El controlador que procesa la solicitud
* `@request` - El objeto de solicitud
* `@response` - El objeto de respuesta


```ruby
class ArticlesControllerTest < ActionDispatch::IntegrationTest
  test "debería obtener índice" do
    get articles_url

    assert_equal "index", @controller.action_name
    assert_equal "application/x-www-form-urlencoded", @request.media_type
    assert_match "Artículos", @response.body
  end
end
```

### Configuración de encabezados y variables CGI

[Encabezados HTTP](https://tools.ietf.org/search/rfc2616#section-5.3)
y
[Variables CGI](https://tools.ietf.org/search/rfc3875#section-4.1)
se pueden pasar como encabezados:

```ruby
# configurar un encabezado HTTP
get articles_url, headers: { "Content-Type": "text/plain" } # simular la solicitud con encabezado personalizado

# configurar una variable CGI
get articles_url, headers: { "HTTP_REFERER": "http://example.com/home" } # simular la solicitud con variable de entorno personalizada
```

### Pruebas de `flash` Notices

Si recuerda de antes, uno de los Tres Hashes del Apocalipsis era `flash`.

Queremos agregar un mensaje `flash` a nuestra aplicación de blog cada vez que alguien crea exitosamente un nuevo artículo.

Comencemos agregando esta afirmación a nuestra prueba `test_should_create_article`:

```ruby
test "debería crear artículo" do
  assert_difference("Article.count") do
    post articles_url, params: { article: { title: "Some title" } }
  end

  assert_redirected_to article_path(Article.last)
  assert_equal "El artículo se creó correctamente.", flash[:notice]
end
```

Si ejecutamos nuestra prueba ahora, deberíamos ver un fallo:

```bash
$ bin/rails test test/controllers/articles_controller_test.rb -n test_should_create_article
Opciones de ejecución: -n test_should_create_article --seed 32266

# Ejecutando:

F

Terminado en 0.114870s, 8.7055 ejecuciones/s, 34.8220 aserciones/s.

  1) Error:
ArticlesControllerTest#test_should_create_article [/test/controllers/articles_controller_test.rb:16]:
--- esperado
+++ actual
@@ -1 +1 @@
-"El artículo se creó correctamente."
+nil

1 ejecuciones, 4 aserciones, 1 errores, 0 fallos, 0 saltos
```

Implementemos ahora el mensaje flash en nuestro controlador. Nuestra acción `:create` debería verse así:

```ruby
def create
  @article = Article.new(article_params)

  if @article.save
    flash[:notice] = "El artículo se creó correctamente."
    redirect_to @article
  else
    render "new"
  end
end
```

Ahora, si ejecutamos nuestras pruebas, deberíamos ver que pasan:

```bash
$ bin/rails test test/controllers/articles_controller_test.rb -n test_should_create_article
Opciones de ejecución: -n test_should_create_article --seed 18981

# Ejecutando:

.

Terminado en 0.081972s, 12.1993 ejecuciones/s, 48.7972 aserciones/s.

1 ejecuciones, 4 aserciones, 0 errores, 0 fallos, 0 saltos
```

### Poniéndolo todo junto

En este punto, nuestro controlador de Artículos prueba las acciones `:index`, `:new` y `:create`. ¿Qué pasa con el manejo de datos existentes?

Escribamos una prueba para la acción `:show`:

```ruby
test "debería mostrar artículo" do
  article = articles(:one)
  get article_url(article)
  assert_response :success
end
```

Recuerde de nuestra discusión anterior sobre fixtures, el método `articles()` nos dará acceso a nuestros fixtures de Artículos.

¿Qué tal eliminar un artículo existente?

```ruby
test "debería eliminar artículo" do
  article = articles(:one)
  assert_difference("Article.count", -1) do
    delete article_url(article)
  end

  assert_redirected_to articles_path
end
```

También podemos agregar una prueba para actualizar un artículo existente.

```ruby
test "debería actualizar artículo" do
  article = articles(:one)

  patch article_url(article), params: { article: { title: "actualizado" } }

  assert_redirected_to article_path(article)
  # Volver a cargar la asociación para obtener los datos actualizados y asegurarse de que el título se haya actualizado.
  article.reload
  assert_equal "actualizado", article.title
end
```

Observe que estamos comenzando a ver cierta duplicación en estas tres pruebas, ambas acceden a los mismos datos de fixture de Artículo. Podemos D.R.Y. esto utilizando los métodos `setup` y `teardown` proporcionados por `ActiveSupport::Callbacks`.

Nuestra prueba ahora debería verse algo como lo siguiente. Ignora las otras pruebas por ahora, las omitimos por brevedad.
```ruby
require "test_helper"

class ArticlesControllerTest < ActionDispatch::IntegrationTest
  # llamado antes de cada prueba individual
  setup do
    @article = articles(:one)
  end

  # llamado después de cada prueba individual
  teardown do
    # cuando el controlador está utilizando caché, puede ser una buena idea restablecerlo después
    Rails.cache.clear
  end

  test "should show article" do
    # Reutilizar la variable de instancia @article de setup
    get article_url(@article)
    assert_response :success
  end

  test "should destroy article" do
    assert_difference("Article.count", -1) do
      delete article_url(@article)
    end

    assert_redirected_to articles_path
  end

  test "should update article" do
    patch article_url(@article), params: { article: { title: "updated" } }

    assert_redirected_to article_path(@article)
    # Volver a cargar la asociación para obtener los datos actualizados y asegurarse de que el título esté actualizado.
    @article.reload
    assert_equal "updated", @article.title
  end
end
```

Similar a otros callbacks en Rails, los métodos `setup` y `teardown` también se pueden usar pasando un bloque, lambda o el nombre de un método como símbolo para llamar.

### Test Helpers

Para evitar la duplicación de código, puedes agregar tus propios test helpers.
Un buen ejemplo puede ser el helper de inicio de sesión:

```ruby
# test/test_helper.rb

module SignInHelper
  def sign_in_as(user)
    post sign_in_url(email: user.email, password: user.password)
  end
end

class ActionDispatch::IntegrationTest
  include SignInHelper
end
```

```ruby
require "test_helper"

class ProfileControllerTest < ActionDispatch::IntegrationTest
  test "should show profile" do
    # el helper ahora es reutilizable desde cualquier caso de prueba de controlador
    sign_in_as users(:david)

    get profile_url
    assert_response :success
  end
end
```

#### Usando archivos separados

Si encuentras que tus helpers están llenando `test_helper.rb`, puedes extraerlos en archivos separados.
Un buen lugar para almacenarlos es `test/lib` o `test/test_helpers`.

```ruby
# test/test_helpers/multiple_assertions.rb
module MultipleAssertions
  def assert_multiple_of_forty_two(number)
    assert (number % 42 == 0), "se esperaba que #{number} fuera múltiplo de 42"
  end
end
```

Estos helpers pueden ser requeridos explícitamente según sea necesario e incluidos según sea necesario

```ruby
require "test_helper"
require "test_helpers/multiple_assertions"

class NumberTest < ActiveSupport::TestCase
  include MultipleAssertions

  test "420 es múltiplo de cuarenta y dos" do
    assert_multiple_of_forty_two 420
  end
end
```

o pueden seguir siendo incluidos directamente en las clases padre relevantes

```ruby
# test/test_helper.rb
require "test_helpers/sign_in_helper"

class ActionDispatch::IntegrationTest
  include SignInHelper
end
```

#### Requerir Helpers de forma anticipada

Puede resultar conveniente requerir helpers de forma anticipada en `test_helper.rb` para que tus archivos de prueba tengan acceso implícito a ellos. Esto se puede lograr utilizando globbing, de la siguiente manera

```ruby
# test/test_helper.rb
Dir[Rails.root.join("test", "test_helpers", "**", "*.rb")].each { |file| require file }
```

Esto tiene la desventaja de aumentar el tiempo de inicio, en comparación con requerir manualmente solo los archivos necesarios en tus pruebas individuales.

Probando Rutas
--------------

Al igual que todo lo demás en tu aplicación Rails, puedes probar tus rutas. Las pruebas de rutas se encuentran en `test/controllers/` o forman parte de las pruebas de controlador.

NOTA: Si tu aplicación tiene rutas complejas, Rails proporciona varios helpers útiles para probarlas.

Para obtener más información sobre las aserciones de enrutamiento disponibles en Rails, consulta la documentación de la API de [`ActionDispatch::Assertions::RoutingAssertions`](https://api.rubyonrails.org/classes/ActionDispatch/Assertions/RoutingAssertions.html).

Probando Vistas
-------------

Probar la respuesta a tu solicitud mediante la comprobación de la presencia de elementos HTML clave y su contenido es una forma común de probar las vistas de tu aplicación. Al igual que las pruebas de rutas, las pruebas de vistas se encuentran en `test/controllers/` o forman parte de las pruebas de controlador. El método `assert_select` te permite consultar elementos HTML de la respuesta utilizando una sintaxis simple pero poderosa.

Hay dos formas de `assert_select`:

`assert_select(selector, [equality], [message])` asegura que se cumpla la condición de igualdad en los elementos seleccionados a través del selector. El selector puede ser una expresión de selector CSS (String) o una expresión con valores de sustitución.

`assert_select(element, selector, [equality], [message])` asegura que se cumpla la condición de igualdad en todos los elementos seleccionados a través del selector a partir del _elemento_ (instancia de `Nokogiri::XML::Node` o `Nokogiri::XML::NodeSet`) y sus descendientes.

Por ejemplo, puedes verificar el contenido del elemento de título en tu respuesta con:

```ruby
assert_select "title", "Bienvenido a la Guía de Pruebas de Rails"
```

También puedes usar bloques anidados de `assert_select` para una investigación más profunda.

En el siguiente ejemplo, el `assert_select` interno para `li.menu_item` se ejecuta dentro de la colección de elementos seleccionados por el bloque externo:

```ruby
assert_select "ul.navigation" do
  assert_select "li.menu_item"
end
```

Una colección de elementos seleccionados se puede iterar para que `assert_select` se pueda llamar por separado para cada elemento.

Por ejemplo, si la respuesta contiene dos listas ordenadas, cada una con cuatro elementos de lista anidados, entonces las siguientes pruebas pasarán:

```ruby
assert_select "ol" do |elements|
  elements.each do |element|
    assert_select element, "li", 4
  end
end

assert_select "ol" do
  assert_select "li", 8
end
```

Esta afirmación es bastante poderosa. Para un uso más avanzado, consulte su [documentación](https://github.com/rails/rails-dom-testing/blob/master/lib/rails/dom/testing/assertions/selector_assertions.rb).

### Afirmaciones adicionales basadas en vistas

Hay más afirmaciones que se utilizan principalmente en las pruebas de vistas:

| Afirmación                                                 | Propósito |
| --------------------------------------------------------- | --------- |
| `assert_select_email`                                     | Te permite hacer afirmaciones sobre el cuerpo de un correo electrónico. |
| `assert_select_encoded`                                   | Te permite hacer afirmaciones sobre HTML codificado. Esto se hace decodificando el contenido de cada elemento y luego llamando al bloque con todos los elementos sin codificar.|
| `css_select(selector)` o `css_select(element, selector)` | Devuelve una matriz de todos los elementos seleccionados por el _selector_. En la segunda variante, primero coincide con el _elemento_ base y luego intenta hacer coincidir la expresión del _selector_ en cualquiera de sus hijos. Si no hay coincidencias, ambas variantes devuelven una matriz vacía.|

Aquí hay un ejemplo de uso de `assert_select_email`:

```ruby
assert_select_email do
  assert_select "small", "Por favor, haz clic en el enlace 'Cancelar suscripción' si deseas darte de baja."
end
```

Pruebas de Helpers
------------------

Un helper es solo un módulo simple donde puedes definir métodos que están disponibles en tus vistas.

Para probar los helpers, todo lo que necesitas hacer es verificar que la salida del método helper coincida con lo que esperas. Las pruebas relacionadas con los helpers se encuentran en el directorio `test/helpers`.

Dado que tenemos el siguiente helper:

```ruby
module UsersHelper
  def link_to_user(user)
    link_to "#{user.first_name} #{user.last_name}", user
  end
end
```

Podemos probar la salida de este método de la siguiente manera:

```ruby
class UsersHelperTest < ActionView::TestCase
  test "debería devolver el nombre completo del usuario" do
    user = users(:david)

    assert_dom_equal %{<a href="/user/#{user.id}">David Heinemeier Hansson</a>}, link_to_user(user)
  end
end
```

Además, dado que la clase de prueba se extiende de `ActionView::TestCase`, tienes acceso a los métodos helper de Rails como `link_to` o `pluralize`.

Pruebas de tus Mailers
----------------------

Probar las clases de mailer requiere algunas herramientas específicas para hacer un trabajo exhaustivo.

### Manteniendo al Cartero bajo control

Tus clases de mailer, al igual que cualquier otra parte de tu aplicación Rails, deben ser probadas para asegurarse de que funcionen como se espera.

Los objetivos de probar tus clases de mailer son asegurarse de que:

* los correos electrónicos se estén procesando (creados y enviados)
* el contenido del correo electrónico sea correcto (asunto, remitente, cuerpo, etc.)
* se estén enviando los correos electrónicos correctos en el momento adecuado

#### Desde todos los ángulos

Hay dos aspectos de probar tu mailer, las pruebas unitarias y las pruebas funcionales. En las pruebas unitarias, ejecutas el mailer de forma aislada con entradas controladas y comparas la salida con un valor conocido (un fixture). En las pruebas funcionales, no pruebas tanto los detalles minuciosos producidos por el mailer; en cambio, pruebas que tus controladores y modelos estén utilizando el mailer de la manera correcta. Pruebas para demostrar que se envió el correo electrónico correcto en el momento adecuado.

### Pruebas Unitarias

Para probar que tu mailer funcione como se espera, puedes usar pruebas unitarias para comparar los resultados reales del mailer con ejemplos predefinidos de lo que debería producirse.

#### La venganza de los Fixtures

Para fines de prueba unitaria de un mailer, se utilizan fixtures para proporcionar un ejemplo de cómo debería verse la salida. Debido a que estos son correos electrónicos de ejemplo, y no datos de Active Record como los demás fixtures, se mantienen en su propio subdirectorio aparte de los demás fixtures. El nombre del directorio dentro de `test/fixtures` corresponde directamente al nombre del mailer. Entonces, para un mailer llamado `UserMailer`, los fixtures deben residir en el directorio `test/fixtures/user_mailer`.

Si generaste tu mailer, el generador no crea fixtures de stub para las acciones del mailer. Deberás crear esos archivos tú mismo como se describe arriba.

#### El caso de prueba básico

Aquí hay una prueba unitaria para probar un mailer llamado `UserMailer` cuya acción `invite` se utiliza para enviar una invitación a un amigo. Es una versión adaptada de la prueba base creada por el generador para una acción `invite`.

```ruby
require "test_helper"

class UserMailerTest < ActionMailer::TestCase
  test "invite" do
    # Crea el correo electrónico y guárdalo para más afirmaciones
    email = UserMailer.create_invite("me@example.com",
                                     "friend@example.com", Time.now)

    # Envía el correo electrónico, luego prueba que se haya encolado
    assert_emails 1 do
      email.deliver_now
    end

    # Prueba que el cuerpo del correo electrónico enviado contenga lo que esperamos
    assert_equal ["me@example.com"], email.from
    assert_equal ["friend@example.com"], email.to
    assert_equal "Has sido invitado por me@example.com", email.subject
    assert_equal read_fixture("invite").join, email.body.to_s
  end
end
```
En la prueba creamos el correo electrónico y almacenamos el objeto devuelto en la variable `email`. Luego nos aseguramos de que se haya enviado (el primer assert), luego, en el segundo conjunto de aserciones, nos aseguramos de que el correo electrónico contenga lo que esperamos. El ayudante `read_fixture` se utiliza para leer el contenido de este archivo.

NOTA: `email.body.to_s` está presente cuando solo hay una parte (HTML o texto) presente. Si el remitente de correo proporciona ambos, puede probar su accesorio contra partes específicas con `email.text_part.body.to_s` o `email.html_part.body.to_s`.

Aquí está el contenido del accesorio `invite`:

```
Hola amigo@example.com,

Has sido invitado.

¡Saludos!
```

Este es el momento adecuado para comprender un poco más sobre cómo escribir pruebas para sus remitentes de correo. La línea `ActionMailer::Base.delivery_method = :test` en `config/environments/test.rb` establece el método de entrega en el modo de prueba para que el correo electrónico no se entregue realmente (útil para evitar enviar spam a sus usuarios durante las pruebas), sino que se agregue a una matriz (`ActionMailer::Base.deliveries`).

NOTA: La matriz `ActionMailer::Base.deliveries` solo se restablece automáticamente en las pruebas de `ActionMailer::TestCase` y `ActionDispatch::IntegrationTest`. Si desea tener una pizarra limpia fuera de estos casos de prueba, puede restablecerla manualmente con: `ActionMailer::Base.deliveries.clear`

#### Pruebas de correos electrónicos en cola

Puede usar la aserción `assert_enqueued_email_with` para confirmar que el correo electrónico se ha encolado con todos los argumentos del método del remitente de correo y/o parámetros del remitente de correo parametrizados esperados. Esto le permite coincidir con cualquier correo electrónico que se haya encolado con el método `deliver_later`.

Al igual que con el caso de prueba básico, creamos el correo electrónico y almacenamos el objeto devuelto en la variable `email`. Los siguientes ejemplos incluyen variaciones de pasar argumentos y/o parámetros.

Este ejemplo afirmará que el correo electrónico se ha encolado con los argumentos correctos:

```ruby
require "test_helper"

class UserMailerTest < ActionMailer::TestCase
  test "invite" do
    # Creamos el correo electrónico y lo almacenamos para más aserciones
    email = UserMailer.create_invite("yo@example.com", "amigo@example.com")

    # Probamos que el correo electrónico se haya encolado con los argumentos correctos
    assert_enqueued_email_with UserMailer, :create_invite, args: ["yo@example.com", "amigo@example.com"] do
      email.deliver_later
    end
  end
end
```

Este ejemplo afirmará que se ha encolado un remitente de correo con los argumentos con nombre correctos pasando un hash de los argumentos como `args`:

```ruby
require "test_helper"

class UserMailerTest < ActionMailer::TestCase
  test "invite" do
    # Creamos el correo electrónico y lo almacenamos para más aserciones
    email = UserMailer.create_invite(from: "yo@example.com", to: "amigo@example.com")

    # Probamos que el correo electrónico se haya encolado con los argumentos con nombre correctos
    assert_enqueued_email_with UserMailer, :create_invite, args: [{ from: "yo@example.com",
                                                                    to: "amigo@example.com" }] do
      email.deliver_later
    end
  end
end
```

Este ejemplo afirmará que se ha encolado un remitente de correo parametrizado con los parámetros y argumentos correctos. Los parámetros del remitente de correo se pasan como `params` y los argumentos del método del remitente de correo como `args`:

```ruby
require "test_helper"

class UserMailerTest < ActionMailer::TestCase
  test "invite" do
    # Creamos el correo electrónico y lo almacenamos para más aserciones
    email = UserMailer.with(all: "bueno").create_invite("yo@example.com", "amigo@example.com")

    # Probamos que el correo electrónico se haya encolado con los parámetros y argumentos correctos del remitente de correo
    assert_enqueued_email_with UserMailer, :create_invite, params: { all: "bueno" },
                                                           args: ["yo@example.com", "amigo@example.com"] do
      email.deliver_later
    end
  end
end
```

Este ejemplo muestra una forma alternativa de probar que se ha encolado un remitente de correo parametrizado con los parámetros correctos:

```ruby
require "test_helper"

class UserMailerTest < ActionMailer::TestCase
  test "invite" do
    # Creamos el correo electrónico y lo almacenamos para más aserciones
    email = UserMailer.with(to: "amigo@example.com").create_invite

    # Probamos que el correo electrónico se haya encolado con los parámetros correctos del remitente de correo
    assert_enqueued_email_with UserMailer.with(to: "amigo@example.com"), :create_invite do
      email.deliver_later
    end
  end
end
```

### Pruebas funcionales y de sistema

Las pruebas unitarias nos permiten probar los atributos del correo electrónico, mientras que las pruebas funcionales y de sistema nos permiten probar si las interacciones del usuario desencadenan adecuadamente el envío del correo electrónico. Por ejemplo, puede verificar que la operación de invitar a un amigo esté enviando un correo electrónico adecuadamente:

```ruby
# Prueba de integración
require "test_helper"

class UsersControllerTest < ActionDispatch::IntegrationTest
  test "invite friend" do
    # Asegura la diferencia en ActionMailer::Base.deliveries
    assert_emails 1 do
      post invite_friend_url, params: { email: "amigo@example.com" }
    end
  end
end
```

```ruby
# Prueba de sistema
require "test_helper"

class UsersTest < ActionDispatch::SystemTestCase
  driven_by :selenium, using: :headless_chrome

  test "inviting a friend" do
    visit invite_users_url
    fill_in "Email", with: "amigo@example.com"
    assert_emails 1 do
      click_on "Invite"
    end
  end
end
```

NOTA: El método `assert_emails` no está vinculado a un método de entrega en particular y funcionará con correos electrónicos entregados con los métodos `deliver_now` o `deliver_later`. Si queremos afirmar explícitamente que el correo electrónico se ha encolado, podemos usar los métodos `assert_enqueued_email_with` ([ejemplos arriba](#testing-enqueued-emails)) o `assert_enqueued_emails`. Se puede encontrar más información en la [documentación aquí](https://api.rubyonrails.org/classes/ActionMailer/TestHelper.html).
Pruebas de trabajo
------------

Dado que sus trabajos personalizados pueden encolarse en diferentes niveles dentro de su aplicación,
deberá probar tanto los trabajos en sí mismos (su comportamiento cuando se encolan)
como que otras entidades los encolen correctamente.

### Un caso de prueba básico

Por defecto, cuando genera un trabajo, también se generará una prueba asociada
en el directorio `test/jobs`. Aquí hay un ejemplo de prueba con un trabajo de facturación:

```ruby
require "test_helper"

class BillingJobTest < ActiveJob::TestCase
  test "que se cobre la cuenta" do
    BillingJob.perform_now(account, product)
    assert account.reload.charged_for?(product)
  end
end
```

Esta prueba es bastante simple y solo verifica que el trabajo haya realizado el trabajo esperado.

### Afirmaciones personalizadas y pruebas de trabajos dentro de otros componentes

Active Job incluye una serie de afirmaciones personalizadas que se pueden utilizar para reducir la verbosidad de las pruebas. Para obtener una lista completa de las afirmaciones disponibles, consulte la documentación de la API de [`ActiveJob::TestHelper`](https://api.rubyonrails.org/classes/ActiveJob/TestHelper.html).

Es una buena práctica asegurarse de que sus trabajos se encolen o se realicen correctamente
donde los invoque (por ejemplo, dentro de sus controladores). Aquí es donde
las afirmaciones personalizadas proporcionadas por Active Job son bastante útiles. Por ejemplo,
dentro de un modelo, podría confirmar que se encoló un trabajo:

```ruby
require "test_helper"

class ProductTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  test "programación de trabajos de facturación" do
    assert_enqueued_with(job: BillingJob) do
      product.charge(account)
    end
    assert_not account.reload.charged_for?(product)
  end
end
```

El adaptador predeterminado, `:test`, no realiza trabajos cuando se encolan.
Debe indicar cuándo desea que se realicen los trabajos:

```ruby
require "test_helper"

class ProductTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  test "programación de trabajos de facturación" do
    perform_enqueued_jobs(only: BillingJob) do
      product.charge(account)
    end
    assert account.reload.charged_for?(product)
  end
end
```

Todos los trabajos realizados y encolados anteriormente se eliminan antes de que se ejecute cualquier prueba,
por lo que puede asumir de manera segura que no se han ejecutado trabajos en el ámbito de cada prueba.

Pruebas de Action Cable
--------------------

Dado que Action Cable se utiliza en diferentes niveles dentro de su aplicación,
deberá probar tanto los canales como las clases de conexión en sí mismos, y que otras
entidades transmitan mensajes correctos.

### Caso de prueba de conexión

Por defecto, cuando genera una nueva aplicación de Rails con Action Cable, también se genera una prueba para la clase de conexión base (`ApplicationCable::Connection`) en el directorio `test/channels/application_cable`.

Las pruebas de conexión tienen como objetivo verificar si los identificadores de una conexión se asignan correctamente
o si se rechazan solicitudes de conexión incorrectas. Aquí hay un ejemplo:

```ruby
class ApplicationCable::ConnectionTest < ActionCable::Connection::TestCase
  test "se conecta con parámetros" do
    # Simula la apertura de una conexión llamando al método `connect`
    connect params: { user_id: 42 }

    # Puede acceder al objeto Connection a través de `connection` en las pruebas
    assert_equal connection.user_id, "42"
  end

  test "rechaza la conexión sin parámetros" do
    # Use el matcher `assert_reject_connection` para verificar que
    # la conexión sea rechazada
    assert_reject_connection { connect }
  end
end
```

También puede especificar cookies de solicitud de la misma manera que lo hace en las pruebas de integración:

```ruby
test "se conecta con cookies" do
  cookies.signed[:user_id] = "42"

  connect

  assert_equal connection.user_id, "42"
end
```

Consulte la documentación de la API de [`ActionCable::Connection::TestCase`](https://api.rubyonrails.org/classes/ActionCable/Connection/TestCase.html) para obtener más información.

### Caso de prueba de canal

Por defecto, cuando genera un canal, también se generará una prueba asociada
en el directorio `test/channels`. Aquí hay un ejemplo de prueba con un canal de chat:

```ruby
require "test_helper"

class ChatChannelTest < ActionCable::Channel::TestCase
  test "se suscribe y transmite para la sala" do
    # Simula la creación de una suscripción llamando a `subscribe`
    subscribe room: "15"

    # Puede acceder al objeto Channel a través de `subscription` en las pruebas
    assert subscription.confirmed?
    assert_has_stream "chat_15"
  end
end
```

Esta prueba es bastante simple y solo verifica que el canal suscribe la conexión a un flujo particular.

También puede especificar los identificadores de conexión subyacentes. Aquí hay un ejemplo de prueba con un canal de notificaciones web:

```ruby
require "test_helper"

class WebNotificationsChannelTest < ActionCable::Channel::TestCase
  test "se suscribe y transmite para el usuario" do
    stub_connection current_user: users(:john)

    subscribe

    assert_has_stream_for users(:john)
  end
end
```

Consulte la documentación de la API de [`ActionCable::Channel::TestCase`](https://api.rubyonrails.org/classes/ActionCable/Channel/TestCase.html) para obtener más información.

### Afirmaciones personalizadas y pruebas de transmisión dentro de otros componentes

Action Cable incluye una serie de afirmaciones personalizadas que se pueden utilizar para reducir la verbosidad de las pruebas. Para obtener una lista completa de las afirmaciones disponibles, consulte la documentación de la API de [`ActionCable::TestHelper`](https://api.rubyonrails.org/classes/ActionCable/TestHelper.html).

Es una buena práctica asegurarse de que se haya transmitido el mensaje correcto dentro de otros componentes (por ejemplo, dentro de sus controladores). Aquí es donde
las afirmaciones personalizadas proporcionadas por Action Cable son bastante útiles. Por ejemplo,
dentro de un modelo:
```ruby
require "test_helper"

class ProductTest < ActionCable::TestCase
  test "emitir estado después de cobrar" do
    assert_broadcast_on("products:#{product.id}", type: "charged") do
      product.charge(account)
    end
  end
end
```

Si deseas probar la emisión realizada con `Channel.broadcast_to`, debes usar `Channel.broadcasting_for` para generar un nombre de flujo subyacente:

```ruby
# app/jobs/chat_relay_job.rb
class ChatRelayJob < ApplicationJob
  def perform(room, message)
    ChatChannel.broadcast_to room, text: message
  end
end
```

```ruby
# test/jobs/chat_relay_job_test.rb
require "test_helper"

class ChatRelayJobTest < ActiveJob::TestCase
  include ActionCable::TestHelper

  test "emitir mensaje a la sala" do
    room = rooms(:all)

    assert_broadcast_on(ChatChannel.broadcasting_for(room), text: "¡Hola!") do
      ChatRelayJob.perform_now(room, "¡Hola!")
    end
  end
end
```

Pruebas de Carga Temprana
-------------------------

Normalmente, las aplicaciones no cargan de forma temprana en los entornos `development` o `test` para acelerar las cosas. Pero sí lo hacen en el entorno `production`.

Si algún archivo del proyecto no se puede cargar por cualquier motivo, ¿no sería mejor detectarlo antes de implementarlo en producción, verdad?

### Integración Continua

Si tu proyecto tiene una integración continua en funcionamiento, la carga temprana en CI es una forma sencilla de asegurarse de que la aplicación se carga de forma temprana.

Las integraciones continuas suelen establecer alguna variable de entorno para indicar que la suite de pruebas se está ejecutando allí. Por ejemplo, podría ser `CI`:

```ruby
# config/environments/test.rb
config.eager_load = ENV["CI"].present?
```

A partir de Rails 7, las aplicaciones generadas recientemente están configuradas de esta manera de forma predeterminada.

### Suites de Pruebas Básicas

Si tu proyecto no tiene integración continua, aún puedes cargar de forma temprana en la suite de pruebas llamando a `Rails.application.eager_load!`:

#### Minitest

```ruby
require "test_helper"

class ZeitwerkComplianceTest < ActiveSupport::TestCase
  test "carga de forma temprana todos los archivos sin errores" do
    assert_nothing_raised { Rails.application.eager_load! }
  end
end
```

#### RSpec

```ruby
require "rails_helper"

RSpec.describe "Cumplimiento de Zeitwerk" do
  it "carga de forma temprana todos los archivos sin errores" do
    expect { Rails.application.eager_load! }.not_to raise_error
  end
end
```

Recursos de Pruebas Adicionales
-------------------------------

### Pruebas de Código Dependiente del Tiempo

Rails proporciona métodos auxiliares integrados que te permiten afirmar que tu código sensible al tiempo funciona como se espera.

El siguiente ejemplo utiliza el ayudante [`travel_to`][travel_to]:

```ruby
# Dado que un usuario es elegible para regalar un mes después de registrarse.
user = User.create(name: "Gaurish", activation_date: Date.new(2004, 10, 24))
assert_not user.applicable_for_gifting?

travel_to Date.new(2004, 11, 24) do
  # Dentro del bloque `travel_to`, `Date.current` se simula
  assert_equal Date.new(2004, 10, 24), user.activation_date
  assert user.applicable_for_gifting?
end

# El cambio solo fue visible dentro del bloque `travel_to`.
assert_equal Date.new(2004, 10, 24), user.activation_date
```

Consulta la referencia de la API [`ActiveSupport::Testing::TimeHelpers`][time_helpers_api] para obtener más información sobre los ayudantes de tiempo disponibles.
[`config.active_support.test_order`]: configuring.html#config-active-support-test-order
[image/png]: https://developer.mozilla.org/en-US/docs/Web/HTTP/Basics_of_HTTP/MIME_types#image_types
[travel_to]: https://api.rubyonrails.org/classes/ActiveSupport/Testing/TimeHelpers.html#method-i-travel_to
[time_helpers_api]: https://api.rubyonrails.org/classes/ActiveSupport/Testing/TimeHelpers.html
