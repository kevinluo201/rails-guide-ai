**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 7dbd0564d604e07d111b2a827bef559f
La línea de comandos de Rails
=============================

Después de leer esta guía, sabrás:

* Cómo crear una aplicación de Rails.
* Cómo generar modelos, controladores, migraciones de base de datos y pruebas unitarias.
* Cómo iniciar un servidor de desarrollo.
* Cómo experimentar con objetos a través de una consola interactiva.

--------------------------------------------------------------------------------

NOTA: Este tutorial asume que tienes conocimientos básicos de Rails a partir de la lectura de la [Guía de introducción a Rails](getting_started.html).

Creando una aplicación de Rails
------------------------------

Primero, creemos una aplicación de Rails simple utilizando el comando `rails new`.

Utilizaremos esta aplicación para jugar y descubrir todos los comandos descritos en esta guía.

INFO: Puedes instalar la gema de Rails escribiendo `gem install rails`, si aún no la tienes.

### `rails new`

El primer argumento que pasaremos al comando `rails new` es el nombre de la aplicación.

```bash
$ rails new my_app
     create
     create  README.md
     create  Rakefile
     create  config.ru
     create  .gitignore
     create  Gemfile
     create  app
     ...
     create  tmp/cache
     ...
        run  bundle install
```

¡Rails configurará lo que parece ser una gran cantidad de cosas para un comando tan pequeño! Ahora tenemos toda la estructura de directorios de Rails con todo el código que necesitamos para ejecutar nuestra aplicación simple directamente.

Si deseas omitir la generación de algunos archivos o bibliotecas, puedes agregar cualquiera de los siguientes argumentos a tu comando `rails new`:

| Argumento                | Descripción                                                 |
| ----------------------- | ----------------------------------------------------------- |
| `--skip-git`            | Omitir git init, .gitignore y .gitattributes               |
| `--skip-docker`         | Omitir Dockerfile, .dockerignore y bin/docker-entrypoint    |
| `--skip-keeps`          | Omitir archivos .keep de control de código fuente                             |
| `--skip-action-mailer`  | Omitir archivos de Action Mailer                                    |
| `--skip-action-mailbox` | Omitir Action Mailbox gem                                     |
| `--skip-action-text`    | Omitir Action Text gem                                        |
| `--skip-active-record`  | Omitir archivos de Active Record                                    |
| `--skip-active-job`     | Omitir Active Job                                             |
| `--skip-active-storage` | Omitir archivos de Active Storage                                   |
| `--skip-action-cable`   | Omitir archivos de Action Cable                                     |
| `--skip-asset-pipeline` | Omitir Asset Pipeline                                         |
| `--skip-javascript`     | Omitir archivos de JavaScript                                       |
| `--skip-hotwire`        | Omitir integración de Hotwire                                    |
| `--skip-jbuilder`       | Omitir gema jbuilder                                           |
| `--skip-test`           | Omitir archivos de prueba                                             |
| `--skip-system-test`    | Omitir archivos de prueba de sistema                                      |
| `--skip-bootsnap`       | Omitir gema bootsnap                                           |

Estas son solo algunas de las opciones que acepta `rails new`. Para ver una lista completa de opciones, escribe `rails new --help`.

### Preconfigurar una base de datos diferente

Al crear una nueva aplicación de Rails, tienes la opción de especificar qué tipo de base de datos utilizará tu aplicación. Esto te ahorrará unos minutos y, ciertamente, muchos golpes de teclado.

Veamos qué hace la opción `--database=postgresql`:

```bash
$ rails new petstore --database=postgresql
      create
      create  app/controllers
      create  app/helpers
...
```

Veamos qué se agregó a nuestro `config/database.yml`:

```yaml
# PostgreSQL. Se admiten las versiones 9.3 y superiores.
#
# Instala el controlador pg:
#   gem install pg
# En macOS con Homebrew:
#   gem install pg -- --with-pg-config=/usr/local/bin/pg_config
# En Windows:
#   gem install pg
#       Elige la versión win32.
#       Instala PostgreSQL y agrega su directorio /bin a tu ruta.
#
# Configura usando el Gemfile
# gem "pg"
#
default: &default
  adapter: postgresql
  encoding: unicode

  # Para obtener más detalles sobre el agrupamiento de conexiones, consulta la guía de configuración de Rails
  # https://guides.rubyonrails.org/configuring.html#database-pooling
  pool: <%= ENV.fetch("RAILS_MAX_THREADS") { 5 } %>

development:
  <<: *default
  database: petstore_development
...
```

Generó una configuración de base de datos correspondiente a nuestra elección de PostgreSQL.

Conceptos básicos de la línea de comandos
----------------------------------------

Hay algunos comandos que son absolutamente críticos para tu uso diario de Rails. En el orden en que probablemente los utilizarás son:

* `bin/rails console`
* `bin/rails server`
* `bin/rails test`
* `bin/rails generate`
* `bin/rails db:migrate`
* `bin/rails db:create`
* `bin/rails routes`
* `bin/rails dbconsole`
* `rails new nombre_de_la_aplicación`

Puedes obtener una lista de los comandos de Rails disponibles para ti, que a menudo dependerá de tu directorio actual, escribiendo `rails --help`. Cada comando tiene una descripción y debería ayudarte a encontrar lo que necesitas.

```bash
$ rails --help
Uso:
  bin/rails COMMAND [opciones]

Debes especificar un comando. Los comandos más comunes son:

  generate     Generar nuevo código (alias abreviado: "g")
  console      Iniciar la consola de Rails (alias abreviado: "c")
  server       Iniciar el servidor de Rails (alias abreviado: "s")
  ...

Todos los comandos se pueden ejecutar con -h (o --help) para obtener más información.

Además de esos comandos, hay:
about                               Listar las versiones de todos los Rails ...
assets:clean[keep]                  Eliminar activos compilados antiguos
assets:clobber                      Eliminar activos compilados
assets:environment                  Cargar el entorno de compilación de activos
assets:precompile                   Compilar todos los activos ...
...
db:fixtures:load                    Cargar datos de prueba en la ...
db:migrate                          Migrar la base de datos ...
db:migrate:status                   Mostrar el estado de las migraciones
db:rollback                         Revertir el esquema a ...
db:schema:cache:clear               Borrar un archivo db/schema_cache.yml
db:schema:cache:dump                Crear un archivo db/schema_cache.yml
db:schema:dump                      Crear un archivo de esquema de base de datos (ya sea db/schema.rb o db/structure.sql ...
db:schema:load                      Cargar un archivo de esquema de base de datos (ya sea db/schema.rb o db/structure.sql ...
db:seed                             Cargar los datos de semilla ...
db:version                          Obtener el esquema actual ...
...
restart                             Reiniciar la aplicación tocando ...
tmp:create                          Crear directorios tmp ...
```
### `bin/rails server`

El comando `bin/rails server` inicia un servidor web llamado Puma que viene incluido con Rails. Lo utilizarás cada vez que quieras acceder a tu aplicación a través de un navegador web.

Sin hacer ningún trabajo adicional, `bin/rails server` ejecutará nuestra nueva y reluciente aplicación Rails:

```bash
$ cd my_app
$ bin/rails server
=> Iniciando Puma
=> Aplicación Rails 7.0.0 iniciando en modo desarrollo
=> Ejecuta `bin/rails server --help` para ver más opciones de inicio
Puma iniciando en modo único...
* Versión 3.12.1 (ruby 2.5.7-p206), nombre en clave: Llamas en Pijamas
* Hilos mínimos: 5, hilos máximos: 5
* Entorno: desarrollo
* Escuchando en tcp://localhost:3000
Usa Ctrl-C para detener
```

Con solo tres comandos, hemos creado un servidor Rails que escucha en el puerto 3000. Ve a tu navegador y abre [http://localhost:3000](http://localhost:3000), verás una aplicación Rails básica en funcionamiento.

INFO: También puedes usar el alias "s" para iniciar el servidor: `bin/rails s`.

El servidor se puede ejecutar en un puerto diferente utilizando la opción `-p`. El entorno de desarrollo predeterminado se puede cambiar utilizando `-e`.

```bash
$ bin/rails server -e production -p 4000
```

La opción `-b` enlaza Rails a la IP especificada, por defecto es localhost. Puedes ejecutar un servidor como un demonio pasando la opción `-d`.

### `bin/rails generate`

El comando `bin/rails generate` utiliza plantillas para crear muchas cosas. Ejecutar `bin/rails generate` por sí solo muestra una lista de generadores disponibles:

INFO: También puedes usar el alias "g" para invocar el comando del generador: `bin/rails g`.

```bash
$ bin/rails generate
Uso:
  bin/rails generate GENERADOR [argumentos] [opciones]

...
...

Por favor, elige un generador a continuación.

Rails:
  assets
  channel
  controller
  generator
  ...
  ...
```

NOTA: Puedes instalar más generadores a través de gemas de generadores, porciones de complementos que sin duda instalarás, ¡e incluso puedes crear los tuyos propios!

El uso de generadores te ahorrará una gran cantidad de tiempo al escribir código **boilerplate**, código que es necesario para que la aplicación funcione.

Creemos nuestro propio controlador con el generador de controladores. Pero, ¿qué comando debemos usar? Preguntemos al generador:

INFO: Todas las utilidades de la consola de Rails tienen texto de ayuda. Al igual que con la mayoría de las utilidades *nix, puedes intentar agregar `--help` o `-h` al final, por ejemplo `bin/rails server --help`.

```bash
$ bin/rails generate controller
Uso:
  bin/rails generate controller NOMBRE [acción acción] [opciones]

...
...

Descripción:
    ...

    Para crear un controlador dentro de un módulo, especifica el nombre del controlador como una ruta como 'nombre_modulo/controlador'.

    ...

Ejemplo:
    `bin/rails generate controller TarjetasDeCredito abrir debito credito cerrar`

    Controlador de tarjetas de crédito con URLs como /tarjetas_de_credito/debito.
        Controlador: app/controllers/tarjetas_de_credito_controller.rb
        Prueba:       test/controllers/tarjetas_de_credito_controller_test.rb
        Vistas:      app/views/tarjetas_de_credito/debito.html.erb [...]
        Ayudante:     app/helpers/tarjetas_de_credito_helper.rb
```

El generador de controladores espera parámetros en forma de `generate controller NombreDelControlador acción1 acción2`. Creemos un controlador `Saludos` con una acción de **hola**, que nos dirá algo agradable.

```bash
$ bin/rails generate controller Saludos hola
     create  app/controllers/saludos_controller.rb
      route  get 'saludos/hola'
     invoke  erb
     create    app/views/saludos
     create    app/views/saludos/hola.html.erb
     invoke  test_unit
     create    test/controllers/saludos_controller_test.rb
     invoke  helper
     create    app/helpers/saludos_helper.rb
     invoke    test_unit
```

¿Qué generó todo esto? Se aseguró de que hubiera un montón de directorios en nuestra aplicación y creó un archivo de controlador, un archivo de vista, un archivo de prueba funcional, un ayudante para la vista, un archivo de JavaScript y un archivo de hoja de estilo.

Echa un vistazo al controlador y modifícalo un poco (en `app/controllers/saludos_controller.rb`):

```ruby
class SaludosController < ApplicationController
  def hola
    @mensaje = "¡Hola, cómo estás hoy?"
  end
end
```

Luego, la vista, para mostrar nuestro mensaje (en `app/views/saludos/hola.html.erb`):

```erb
<h1>¡Un Saludo para Ti!</h1>
<p><%= @mensaje %></p>
```

Inicia tu servidor usando `bin/rails server`.

```bash
$ bin/rails server
=> Iniciando Puma...
```

La URL será [http://localhost:3000/saludos/hola](http://localhost:3000/saludos/hola).

INFO: Con una aplicación Rails normal y corriente, tus URLs generalmente seguirán el patrón de http://(host)/(controlador)/(acción), y una URL como http://(host)/(controlador) ejecutará la acción **index** de ese controlador.

Rails viene con un generador para modelos de datos también.

```bash
$ bin/rails generate model
Uso:
  bin/rails generate model NOMBRE [campo[:tipo][:índice] campo[:tipo][:índice]] [opciones]

...

Opciones de ActiveRecord:
      [--migration], [--no-migration]        # Indica cuándo generar la migración
                                             # Por defecto: true

...

Descripción:
    Genera un nuevo modelo. Pasa el nombre del modelo, en CamelCase o
    con guiones bajos, y una lista opcional de pares de atributos como argumentos.

...
```

NOTA: Para obtener una lista de tipos de campo disponibles para el parámetro `tipo`, consulta la [documentación de la API](https://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html#method-i-add_column) para el método `add_column` del módulo `SchemaStatements`. El parámetro `índice` genera un índice correspondiente para la columna.
Pero en lugar de generar un modelo directamente (que haremos más adelante), vamos a configurar un andamio. Un **andamio** en Rails es un conjunto completo de modelo, migración de base de datos para ese modelo, controlador para manipularlo, vistas para ver y manipular los datos, y una suite de pruebas para cada uno de los elementos anteriores.

Configuraremos un recurso simple llamado "HighScore" que llevará un registro de nuestra puntuación más alta en los videojuegos que jugamos.

```bash
$ bin/rails generate scaffold HighScore game:string score:integer
    invoke  active_record
    create    db/migrate/20190416145729_create_high_scores.rb
    create    app/models/high_score.rb
    invoke    test_unit
    create      test/models/high_score_test.rb
    create      test/fixtures/high_scores.yml
    invoke  resource_route
     route    resources :high_scores
    invoke  scaffold_controller
    create    app/controllers/high_scores_controller.rb
    invoke    erb
    create      app/views/high_scores
    create      app/views/high_scores/index.html.erb
    create      app/views/high_scores/edit.html.erb
    create      app/views/high_scores/show.html.erb
    create      app/views/high_scores/new.html.erb
    create      app/views/high_scores/_form.html.erb
    invoke    test_unit
    create      test/controllers/high_scores_controller_test.rb
    create      test/system/high_scores_test.rb
    invoke    helper
    create      app/helpers/high_scores_helper.rb
    invoke      test_unit
    invoke    jbuilder
    create      app/views/high_scores/index.json.jbuilder
    create      app/views/high_scores/show.json.jbuilder
    create      app/views/high_scores/_high_score.json.jbuilder
```

El generador crea el modelo, las vistas, el controlador, la ruta del **recurso** y la migración de la base de datos (que crea la tabla `high_scores`) para HighScore. Y agrega pruebas para ellos.

La migración requiere que hagamos una **migración**, es decir, ejecutemos algún código Ruby (el archivo `20190416145729_create_high_scores.rb` del resultado anterior) para modificar el esquema de nuestra base de datos. ¿Qué base de datos? La base de datos SQLite3 que Rails creará para nosotros cuando ejecutemos el comando `bin/rails db:migrate`. Hablaremos más sobre ese comando a continuación.

```bash
$ bin/rails db:migrate
==  CreateHighScores: migrating ===============================================
-- create_table(:high_scores)
   -> 0.0017s
==  CreateHighScores: migrated (0.0019s) ======================================
```

INFO: Hablemos de las pruebas unitarias. Las pruebas unitarias son código que prueba y hace afirmaciones sobre el código. En las pruebas unitarias, tomamos una pequeña parte del código, por ejemplo, un método de un modelo, y probamos sus entradas y salidas. Las pruebas unitarias son tus amigas. Cuanto antes te reconcilies con el hecho de que tu calidad de vida aumentará drásticamente cuando pruebes unitariamente tu código, mejor. En serio. Por favor, visita [la guía de pruebas](testing.html) para obtener una visión más detallada de las pruebas unitarias.

Veamos la interfaz que Rails creó para nosotros.

```bash
$ bin/rails server
```

Ve a tu navegador y abre [http://localhost:3000/high_scores](http://localhost:3000/high_scores), ahora podemos crear nuevas puntuaciones más altas (55,160 en Space Invaders!)

### `bin/rails console`

El comando `console` te permite interactuar con tu aplicación Rails desde la línea de comandos. En el fondo, `bin/rails console` utiliza IRB, por lo que si alguna vez lo has usado, te sentirás como en casa. Esto es útil para probar ideas rápidas con código y cambiar datos en el servidor sin tocar el sitio web.

INFO: También puedes usar el alias "c" para invocar la consola: `bin/rails c`.

Puedes especificar el entorno en el que debe operar el comando `console`.

```bash
$ bin/rails console -e staging
```

Si deseas probar algún código sin cambiar ningún dato, puedes hacerlo invocando `bin/rails console --sandbox`.

```bash
$ bin/rails console --sandbox
Loading development environment in sandbox (Rails 7.1.0)
Any modifications you make will be rolled back on exit
irb(main):001:0>
```

#### Los objetos `app` y `helper`

Dentro de `bin/rails console` tienes acceso a las instancias `app` y `helper`.

Con el método `app` puedes acceder a los ayudantes de ruta con nombre, así como hacer solicitudes.

```irb
irb> app.root_path
=> "/"

irb> app.get _
Started GET "/" for 127.0.0.1 at 2014-06-19 10:41:57 -0300
...
```

Con el método `helper` es posible acceder a los ayudantes de Rails y de tu aplicación.

```irb
irb> helper.time_ago_in_words 30.days.ago
=> "about 1 month"

irb> helper.my_custom_helper
=> "my custom helper"
```

### `bin/rails dbconsole`

`bin/rails dbconsole` determina qué base de datos estás usando y te lleva a la interfaz de línea de comandos que usarías con ella (y también determina los parámetros de línea de comandos que debe darle). Admite MySQL (incluido MariaDB), PostgreSQL y SQLite3.

INFO: También puedes usar el alias "db" para invocar la consola de la base de datos: `bin/rails db`.

Si estás utilizando varias bases de datos, `bin/rails dbconsole` se conectará a la base de datos principal de forma predeterminada. Puedes especificar a qué base de datos conectarte usando `--database` o `--db`:

```bash
$ bin/rails dbconsole --database=animals
```

### `bin/rails runner`

`runner` ejecuta código Ruby en el contexto de Rails de forma no interactiva. Por ejemplo:

```bash
$ bin/rails runner "Model.long_running_method"
```

INFO: También puedes usar el alias "r" para invocar el runner: `bin/rails r`.

Puedes especificar el entorno en el que debe operar el comando `runner` usando el interruptor `-e`.

```bash
$ bin/rails runner -e staging "Model.long_running_method"
```
Incluso puedes ejecutar código Ruby escrito en un archivo con runner.

```bash
$ bin/rails runner lib/code_to_be_run.rb
```

### `bin/rails destroy`

Piensa en `destroy` como lo opuesto a `generate`. Descubrirá lo que generó y lo deshará.

INFO: También puedes usar el alias "d" para invocar el comando destroy: `bin/rails d`.

```bash
$ bin/rails generate model Oops
      invoke  active_record
      create    db/migrate/20120528062523_create_oops.rb
      create    app/models/oops.rb
      invoke    test_unit
      create      test/models/oops_test.rb
      create      test/fixtures/oops.yml
```

```bash
$ bin/rails destroy model Oops
      invoke  active_record
      remove    db/migrate/20120528062523_create_oops.rb
      remove    app/models/oops.rb
      invoke    test_unit
      remove      test/models/oops_test.rb
      remove      test/fixtures/oops.yml
```

### `bin/rails about`

`bin/rails about` proporciona información sobre los números de versión de Ruby, RubyGems, Rails, los subcomponentes de Rails, la carpeta de tu aplicación, el nombre del entorno actual de Rails, el adaptador de base de datos de tu aplicación y la versión del esquema. Es útil cuando necesitas pedir ayuda, verificar si un parche de seguridad puede afectarte o cuando necesitas estadísticas para una instalación existente de Rails.

```bash
$ bin/rails about
Acerca del entorno de tu aplicación
Versión de Rails             7.0.0
Versión de Ruby              2.7.0 (x86_64-linux)
Versión de RubyGems          2.7.3
Versión de Rack              2.0.4
Tiempo de ejecución de JavaScript        Node.js (V8)
Middleware:               Rack::Sendfile, ActionDispatch::Static, ActionDispatch::Executor, ActiveSupport::Cache::Strategy::LocalCache::Middleware, Rack::Runtime, Rack::MethodOverride, ActionDispatch::RequestId, ActionDispatch::RemoteIp, Sprockets::Rails::QuietAssets, Rails::Rack::Logger, ActionDispatch::ShowExceptions, WebConsole::Middleware, ActionDispatch::DebugExceptions, ActionDispatch::Reloader, ActionDispatch::Callbacks, ActiveRecord::Migration::CheckPending, ActionDispatch::Cookies, ActionDispatch::Session::CookieStore, ActionDispatch::Flash, Rack::Head, Rack::ConditionalGet, Rack::ETag
Directorio raíz de la aplicación          /home/foobar/my_app
Entorno               desarrollo
Adaptador de base de datos          sqlite3
Versión del esquema de la base de datos   20180205173523
```

### `bin/rails assets:`

Puedes precompilar los activos en `app/assets` usando `bin/rails assets:precompile` y eliminar los activos compilados antiguos usando `bin/rails assets:clean`. El comando `assets:clean` permite implementaciones continuas que aún pueden estar vinculadas a un activo antiguo mientras se construyen los nuevos activos.

Si deseas borrar completamente `public/assets`, puedes usar `bin/rails assets:clobber`.

### `bin/rails db:`

Los comandos más comunes del espacio de nombres `db:` de Rails son `migrate` y `create`, y vale la pena probar todos los comandos de migración de Rails (`up`, `down`, `redo`, `reset`). `bin/rails db:version` es útil para solucionar problemas, ya que te muestra la versión actual de la base de datos.

Puedes encontrar más información sobre las migraciones en la guía [Migrations](active_record_migrations.html).

### `bin/rails notes`

`bin/rails notes` busca en tu código comentarios que comiencen con una palabra clave específica. Puedes consultar `bin/rails notes --help` para obtener información sobre cómo usarlo.

De forma predeterminada, buscará en los directorios `app`, `config`, `db`, `lib` y `test` las anotaciones FIXME, OPTIMIZE y TODO en archivos con las extensiones `.builder`, `.rb`, `.rake`, `.yml`, `.yaml`, `.ruby`, `.css`, `.js` y `.erb`.

```bash
$ bin/rails notes
app/controllers/admin/users_controller.rb:
  * [ 20] [TODO] ¿Hay alguna otra forma de hacer esto?
  * [132] [FIXME] alta prioridad para la próxima implementación

lib/school.rb:
  * [ 13] [OPTIMIZE] refactorizar este código para que sea más rápido
  * [ 17] [FIXME]
```

#### Anotaciones

Puedes pasar anotaciones específicas usando el argumento `--annotations`. De forma predeterminada, buscará las anotaciones FIXME, OPTIMIZE y TODO.
Ten en cuenta que las anotaciones distinguen entre mayúsculas y minúsculas.

```bash
$ bin/rails notes --annotations FIXME RELEASE
app/controllers/admin/users_controller.rb:
  * [101] [RELEASE] Necesitamos revisar esto antes de la próxima versión
  * [132] [FIXME] alta prioridad para la próxima implementación

lib/school.rb:
  * [ 17] [FIXME]
```

#### Etiquetas

Puedes agregar más etiquetas predeterminadas para buscar utilizando `config.annotations.register_tags`. Recibe una lista de etiquetas.

```ruby
config.annotations.register_tags("DEPRECATEME", "TESTME")
```

```bash
$ bin/rails notes
app/controllers/admin/users_controller.rb:
  * [ 20] [TODO] hacer pruebas A/B en esto
  * [ 42] [TESTME] esto necesita más pruebas funcionales
  * [132] [DEPRECATEME] asegurarse de que este método esté obsoleto en la próxima versión
```

#### Directorios

Puedes agregar más directorios predeterminados para buscar utilizando `config.annotations.register_directories`. Recibe una lista de nombres de directorios.

```ruby
config.annotations.register_directories("spec", "vendor")
```

```bash
$ bin/rails notes
app/controllers/admin/users_controller.rb:
  * [ 20] [TODO] ¿Hay alguna otra forma de hacer esto?
  * [132] [FIXME] alta prioridad para la próxima implementación

lib/school.rb:
  * [ 13] [OPTIMIZE] Refactorizar este código para que sea más rápido
  * [ 17] [FIXME]

spec/models/user_spec.rb:
  * [122] [TODO] Verificar que funcione el usuario que tiene una suscripción

vendor/tools.rb:
  * [ 56] [TODO] Deshacerse de esta dependencia
```

#### Extensiones

Puedes agregar más extensiones de archivo predeterminadas para buscar utilizando `config.annotations.register_extensions`. Recibe una lista de extensiones con su correspondiente expresión regular para hacer coincidir.

```ruby
config.annotations.register_extensions("scss", "sass") { |annotation| /\/\/\s*(#{annotation}):?\s*(.*)$/ }
```

```bash
$ bin/rails notes
app/controllers/admin/users_controller.rb:
  * [ 20] [TODO] ¿Hay alguna otra forma de hacer esto?
  * [132] [FIXME] alta prioridad para la próxima implementación

app/assets/stylesheets/application.css.sass:
  * [ 34] [TODO] Usar pseudo elemento para esta clase

app/assets/stylesheets/application.css.scss:
  * [  1] [TODO] Dividir en múltiples componentes

lib/school.rb:
  * [ 13] [OPTIMIZE] Refactorizar este código para que sea más rápido
  * [ 17] [FIXME]

spec/models/user_spec.rb:
  * [122] [TODO] Verificar que funcione el usuario que tiene una suscripción

vendor/tools.rb:
  * [ 56] [TODO] Deshacerse de esta dependencia
```
### `bin/rails routes`

`bin/rails routes` mostrará todas las rutas definidas, lo cual es útil para encontrar problemas de enrutamiento en tu aplicación o para tener una buena visión general de las URL en una aplicación con la que estás tratando de familiarizarte.

### `bin/rails test`

INFO: Una buena descripción de las pruebas unitarias en Rails se encuentra en [Una guía para probar aplicaciones Rails](testing.html)

Rails viene con un marco de pruebas llamado minitest. Rails debe su estabilidad al uso de pruebas. Los comandos disponibles en el espacio de nombres `test:` ayudan a ejecutar las diferentes pruebas que, con suerte, escribirás.

### `bin/rails tmp:`

El directorio `Rails.root/tmp` es, al igual que el directorio *nix /tmp, el lugar de almacenamiento de archivos temporales como archivos de identificación de proceso y acciones en caché.

Los comandos con espacio de nombres `tmp:` te ayudarán a limpiar y crear el directorio `Rails.root/tmp`:

* `bin/rails tmp:cache:clear` limpia `tmp/cache`.
* `bin/rails tmp:sockets:clear` limpia `tmp/sockets`.
* `bin/rails tmp:screenshots:clear` limpia `tmp/screenshots`.
* `bin/rails tmp:clear` limpia todos los archivos de caché, sockets y capturas de pantalla.
* `bin/rails tmp:create` crea directorios tmp para caché, sockets y pids.

### Varios

* `bin/rails initializers` muestra todos los inicializadores definidos en el orden en que son invocados por Rails.
* `bin/rails middleware` lista la pila de middleware Rack habilitada para tu aplicación.
* `bin/rails stats` es excelente para ver estadísticas de tu código, mostrando cosas como KLOCs (miles de líneas de código) y la relación entre tu código y las pruebas.
* `bin/rails secret` te dará una clave pseudoaleatoria para usar como secreto de sesión.
* `bin/rails time:zones:all` lista todas las zonas horarias que Rails conoce.

### Tareas personalizadas de Rake

Las tareas personalizadas de Rake tienen una extensión `.rake` y se colocan en `Rails.root/lib/tasks`. Puedes crear estas tareas personalizadas de Rake con el comando `bin/rails generate task`.

```ruby
desc "Soy una descripción corta pero completa para mi tarea genial"
task task_name: [:prerequisite_task, :another_task_we_depend_on] do
  # Todo tu código mágico aquí
  # Se permite cualquier código Ruby válido
end
```

Para pasar argumentos a tu tarea personalizada de Rake:

```ruby
task :task_name, [:arg_1] => [:prerequisite_1, :prerequisite_2] do |task, args|
  argument_1 = args.arg_1
end
```

Puedes agrupar tareas colocándolas en espacios de nombres:

```ruby
namespace :db do
  desc "Esta tarea no hace nada"
  task :nothing do
    # En serio, no hace nada
  end
end
```

La invocación de las tareas se verá así:

```bash
$ bin/rails task_name
$ bin/rails "task_name[value 1]" # toda la cadena de argumentos debe ir entre comillas
$ bin/rails "task_name[value 1,value2,value3]" # separa múltiples argumentos con una coma
$ bin/rails db:nothing
```

Si necesitas interactuar con los modelos de tu aplicación, realizar consultas a la base de datos, etc., tu tarea debe depender de la tarea `environment`, que cargará el código de tu aplicación.

```ruby
task task_that_requires_app_code: [:environment] do
  User.create!
end
```
