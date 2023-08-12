**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 2cf37358fedc8b51ed3ab7f408ecfc76
Empezando con Rails
==========================

Esta guía cubre cómo empezar y ejecutar Ruby on Rails.

Después de leer esta guía, sabrás:

* Cómo instalar Rails, crear una nueva aplicación Rails y conectar tu aplicación a una base de datos.
* La estructura general de una aplicación Rails.
* Los principios básicos de MVC (Modelo, Vista, Controlador) y diseño RESTful.
* Cómo generar rápidamente las piezas iniciales de una aplicación Rails.

--------------------------------------------------------------------------------

Suposiciones de la guía
-----------------

Esta guía está diseñada para principiantes que desean comenzar a crear una aplicación Rails desde cero. No asume que tienes experiencia previa con Rails.

Rails es un marco de aplicación web que se ejecuta en el lenguaje de programación Ruby. Si no tienes experiencia previa con Ruby, encontrarás una curva de aprendizaje muy pronunciada al sumergirte directamente en Rails. Hay varias listas seleccionadas de recursos en línea para aprender Ruby:

* [Sitio web oficial del lenguaje de programación Ruby](https://www.ruby-lang.org/en/documentation/)
* [Lista de libros de programación gratuitos](https://github.com/EbookFoundation/free-programming-books/blob/master/books/free-programming-books-langs.md#ruby)

Ten en cuenta que algunos recursos, aunque siguen siendo excelentes, cubren versiones antiguas de Ruby y es posible que no incluyan algunas sintaxis que verás en el desarrollo diario con Rails.

¿Qué es Rails?
--------------

Rails es un marco de desarrollo de aplicaciones web escrito en el lenguaje de programación Ruby. Está diseñado para facilitar la programación de aplicaciones web al hacer suposiciones sobre lo que cada desarrollador necesita para comenzar. Te permite escribir menos código mientras logras más que muchos otros lenguajes y marcos. Los desarrolladores experimentados de Rails también informan que hace que el desarrollo de aplicaciones web sea más divertido.

Rails es un software con opiniones. Parte de la premisa de que hay una "mejor" forma de hacer las cosas y está diseñado para fomentar esa forma, y en algunos casos, desalentar alternativas. Si aprendes "El camino de Rails", probablemente descubrirás un aumento tremendo en la productividad. Si persistes en traer viejos hábitos de otros lenguajes a tu desarrollo de Rails y tratas de usar patrones que aprendiste en otros lugares, es posible que tengas una experiencia menos satisfactoria.

La filosofía de Rails incluye dos principios rectores principales:

* **No te repitas a ti mismo:** DRY es un principio de desarrollo de software que establece que "Cada pieza de conocimiento debe tener una única representación inequívoca y autoritaria dentro de un sistema". Al no escribir la misma información una y otra vez, nuestro código es más mantenible, más extensible y menos propenso a errores.
* **Convención sobre configuración:** Rails tiene opiniones sobre la mejor manera de hacer muchas cosas en una aplicación web y se basa en este conjunto de convenciones en lugar de requerir que especifiques minucias a través de interminables archivos de configuración.

Creando un nuevo proyecto Rails
----------------------------

La mejor manera de leer esta guía es seguirla paso a paso. Todos los pasos son esenciales para ejecutar esta aplicación de ejemplo y no se necesita ningún código o paso adicional.

Siguiendo esta guía, crearás un proyecto Rails llamado `blog`, un weblog (muy) simple. Antes de poder comenzar a construir la aplicación, debes asegurarte de tener Rails instalado.

NOTA: Los ejemplos a continuación usan `$` para representar el indicador de comando en un sistema operativo similar a UNIX, aunque puede haber sido personalizado para aparecer de manera diferente. Si estás usando Windows, tu indicador se verá algo como `C:\source_code>`.

### Instalando Rails

Antes de instalar Rails, debes verificar que tu sistema tenga los requisitos previos adecuados instalados. Estos incluyen:

* Ruby
* SQLite3

#### Instalando Ruby

Abre una ventana de línea de comandos. En macOS, abre Terminal.app; en Windows, elige "Ejecutar" desde el menú Inicio y escribe `cmd.exe`. Cualquier comando precedido por un signo de dólar `$` debe ejecutarse en la línea de comandos. Verifica que tienes instalada una versión actual de Ruby:

```bash
$ ruby --version
ruby 2.7.0
```

Rails requiere la versión 2.7.0 o posterior de Ruby. Se prefiere usar la última versión de Ruby. Si el número de versión que se muestra es menor que ese número (como 2.3.7 o 1.8.7), deberás instalar una copia nueva de Ruby.

Para instalar Rails en Windows, primero deberás instalar [Ruby Installer](https://rubyinstaller.org/).

Para obtener más métodos de instalación para la mayoría de los sistemas operativos, consulta [ruby-lang.org](https://www.ruby-lang.org/en/documentation/installation/).

#### Instalando SQLite3

También necesitarás una instalación de la base de datos SQLite3. Muchos sistemas operativos similares a UNIX populares vienen con una versión aceptable de SQLite3. Otros pueden encontrar instrucciones de instalación en el sitio web de [SQLite3](https://www.sqlite.org).
Verifique que esté instalado correctamente y en su `PATH` de carga:

```bash
$ sqlite3 --version
```

El programa debería mostrar su versión.

#### Instalación de Rails

Para instalar Rails, use el comando `gem install` proporcionado por RubyGems:

```bash
$ gem install rails
```

Para verificar que todo esté instalado correctamente, debería poder ejecutar lo siguiente en una nueva terminal:

```bash
$ rails --version
```

Si muestra algo como "Rails 7.0.0", está listo para continuar.

### Creando la aplicación de Blog

Rails viene con una serie de scripts llamados generadores que están diseñados para facilitar tu vida de desarrollo al crear todo lo necesario para comenzar a trabajar en una tarea en particular. Uno de estos es el generador de nuevas aplicaciones, que te proporcionará la base de una nueva aplicación de Rails para que no tengas que escribirla tú mismo.

Para usar este generador, abre una terminal, navega hasta un directorio donde tengas permisos para crear archivos y ejecuta:

```bash
$ rails new blog
```

Esto creará una aplicación de Rails llamada Blog en un directorio `blog` e instalará las dependencias de gemas que ya se mencionan en `Gemfile` usando `bundle install`.

CONSEJO: Puedes ver todas las opciones de línea de comandos que acepta el generador de aplicaciones de Rails ejecutando `rails new --help`.

Después de crear la aplicación de blog, cambia a su carpeta:

```bash
$ cd blog
```

El directorio `blog` tendrá varios archivos y carpetas generados que conforman la estructura de una aplicación de Rails. La mayor parte del trabajo en este tutorial se realizará en la carpeta `app`, pero aquí tienes una descripción básica de la función de cada uno de los archivos y carpetas que Rails crea por defecto:

| Archivo/Carpeta | Propósito |
| ----------- | ------- |
|app/|Contiene los controladores, modelos, vistas, ayudantes, mailers, canales, trabajos y activos de tu aplicación. Te enfocarás en esta carpeta durante el resto de esta guía.|
|bin/|Contiene el script `rails` que inicia tu aplicación y puede contener otros scripts que uses para configurar, actualizar, implementar o ejecutar tu aplicación.|
|config/|Contiene la configuración de las rutas, la base de datos y más de tu aplicación. Esto se explica con más detalle en [Configuración de aplicaciones de Rails](configuring.html).|
|config.ru|Configuración de Rack para los servidores basados en Rack utilizados para iniciar la aplicación. Para obtener más información sobre Rack, consulta el [sitio web de Rack](https://rack.github.io/).|
|db/|Contiene el esquema de la base de datos actual, así como las migraciones de la base de datos.|
|Gemfile<br>Gemfile.lock|Estos archivos te permiten especificar las dependencias de gemas necesarias para tu aplicación de Rails. Estos archivos son utilizados por la gema Bundler. Para obtener más información sobre Bundler, consulta el [sitio web de Bundler](https://bundler.io).|
|lib/|Módulos extendidos para tu aplicación.|
|log/|Archivos de registro de la aplicación.|
|public/|Contiene archivos estáticos y activos compilados. Cuando tu aplicación esté en funcionamiento, este directorio se expondrá tal cual.|
|Rakefile|Este archivo localiza y carga tareas que se pueden ejecutar desde la línea de comandos. Las definiciones de tareas se definen en los componentes de Rails. En lugar de cambiar `Rakefile`, debes agregar tus propias tareas agregando archivos al directorio `lib/tasks` de tu aplicación.|
|README.md|Este es un breve manual de instrucciones para tu aplicación. Debes editar este archivo para informar a otros sobre lo que hace tu aplicación, cómo configurarla, etc.|
|storage/|Archivos de Active Storage para el servicio de disco. Esto se explica en [Descripción general de Active Storage](active_storage_overview.html).|
|test/|Pruebas unitarias, fixtures y otros aparatos de prueba. Estos se explican en [Pruebas de aplicaciones de Rails](testing.html).|
|tmp/|Archivos temporales (como archivos de caché y pid).|
|vendor/|Un lugar para todo el código de terceros. En una aplicación de Rails típica, esto incluye gemas vendidas.|
|.gitattributes|Este archivo define metadatos para rutas específicas en un repositorio de git. Estos metadatos pueden ser utilizados por git y otras herramientas para mejorar su comportamiento. Consulta la [documentación de gitattributes](https://git-scm.com/docs/gitattributes) para obtener más información.|
|.gitignore|Este archivo le indica a git qué archivos (o patrones) debe ignorar. Consulta [GitHub - Ignorar archivos](https://help.github.com/articles/ignoring-files) para obtener más información sobre cómo ignorar archivos.|
|.ruby-version|Este archivo contiene la versión predeterminada de Ruby.|

¡Hola, Rails!
--------------

Para empezar, pongamos algo de texto en la pantalla rápidamente. Para hacer esto, necesitas iniciar el servidor de aplicaciones de Rails.

### Iniciando el servidor web

En realidad, ya tienes una aplicación de Rails funcional. Para verla, necesitas iniciar un servidor web en tu máquina de desarrollo. Puedes hacer esto ejecutando el siguiente comando en el directorio `blog`:

```bash
$ bin/rails server
```
CONSEJO: Si estás utilizando Windows, debes pasar los scripts ubicados en la carpeta `bin` directamente al intérprete de Ruby, por ejemplo `ruby bin\rails server`.

CONSEJO: La compresión de activos de JavaScript requiere que tengas un tiempo de ejecución de JavaScript disponible en tu sistema. En ausencia de un tiempo de ejecución, verás un error de `execjs` durante la compresión de activos. Por lo general, macOS y Windows vienen con un tiempo de ejecución de JavaScript instalado. `therubyrhino` es el tiempo de ejecución recomendado para usuarios de JRuby y se agrega de forma predeterminada al `Gemfile` en aplicaciones generadas con JRuby. Puedes investigar todos los tiempos de ejecución compatibles en [ExecJS](https://github.com/rails/execjs#readme).

Esto iniciará Puma, un servidor web distribuido con Rails de forma predeterminada. Para ver tu aplicación en acción, abre una ventana del navegador y navega a <http://localhost:3000>. Deberías ver la página de información predeterminada de Rails:

![Captura de pantalla de la página de inicio de Rails](images/getting_started/rails_welcome.png)

Cuando quieras detener el servidor web, presiona Ctrl+C en la ventana de la terminal donde se está ejecutando. En el entorno de desarrollo, Rails generalmente no requiere reiniciar el servidor; los cambios que realices en los archivos serán recogidos automáticamente por el servidor.

La página de inicio de Rails es la "prueba de humo" para una nueva aplicación de Rails: se asegura de que tengas tu software configurado correctamente para servir una página.

### Di "Hola", Rails

Para hacer que Rails diga "Hola", necesitas crear al menos una *ruta*, un *controlador* con una *acción*, y una *vista*. Una ruta mapea una solicitud a una acción del controlador. Una acción del controlador realiza el trabajo necesario para manejar la solicitud y prepara cualquier dato para la vista. Una vista muestra los datos en un formato deseado.

En términos de implementación: las rutas son reglas escritas en un [DSL (Lenguaje Específico del Dominio)](https://en.wikipedia.org/wiki/Domain-specific_language) de Ruby. Los controladores son clases de Ruby y sus métodos públicos son acciones. Y las vistas son plantillas, generalmente escritas en una mezcla de HTML y Ruby.

Comencemos agregando una ruta a nuestro archivo de rutas, `config/routes.rb`, en el bloque `Rails.application.routes.draw`:

```ruby
Rails.application.routes.draw do
  get "/articles", to: "articles#index"

  # Para obtener más detalles sobre el DSL disponible en este archivo, consulta https://guides.rubyonrails.org/routing.html
end
```

La ruta anterior declara que las solicitudes `GET /articles` se mapean a la acción `index` de `ArticlesController`.

Para crear `ArticlesController` y su acción `index`, ejecutaremos el generador de controladores (con la opción `--skip-routes` porque ya tenemos una ruta adecuada):

```bash
$ bin/rails generate controller Articles index --skip-routes
```

Rails creará varios archivos para ti:

```
create  app/controllers/articles_controller.rb
invoke  erb
create    app/views/articles
create    app/views/articles/index.html.erb
invoke  test_unit
create    test/controllers/articles_controller_test.rb
invoke  helper
create    app/helpers/articles_helper.rb
invoke    test_unit
```

El más importante de estos es el archivo del controlador, `app/controllers/articles_controller.rb`. Echemos un vistazo:

```ruby
class ArticlesController < ApplicationController
  def index
  end
end
```

La acción `index` está vacía. Cuando una acción no renderiza explícitamente una vista (o de otra manera desencadena una respuesta HTTP), Rails automáticamente renderizará una vista que coincida con el nombre del controlador y la acción. ¡Convención sobre configuración! Las vistas se encuentran en el directorio `app/views`. Por lo tanto, la acción `index` renderizará `app/views/articles/index.html.erb` de forma predeterminada.

Abramos `app/views/articles/index.html.erb` y reemplacemos su contenido con:

```html
<h1>¡Hola, Rails!</h1>
```

Si anteriormente detuviste el servidor web para ejecutar el generador de controladores, reinícialo con `bin/rails server`. Ahora visita <http://localhost:3000/articles> y ¡verás nuestro texto mostrado!

### Configurando la página de inicio de la aplicación

En este momento, <http://localhost:3000> todavía muestra una página con el logotipo de Ruby on Rails. También vamos a mostrar nuestro texto "¡Hola, Rails!" en <http://localhost:3000>. Para hacerlo, agregaremos una ruta que mapee la *ruta raíz* de nuestra aplicación a la acción y controlador correspondientes.

Abramos `config/routes.rb` y agreguemos la siguiente ruta `root` al principio del bloque `Rails.application.routes.draw`:

```ruby
Rails.application.routes.draw do
  root "articles#index"

  get "/articles", to: "articles#index"
end
```

Ahora podemos ver nuestro texto "¡Hola, Rails!" cuando visitamos <http://localhost:3000>, confirmando que la ruta `root` también se mapea a la acción `index` de `ArticlesController`.

CONSEJO: Para obtener más información sobre enrutamiento, consulta [Rails Routing from the Outside In](routing.html).

Carga automática
-----------

Las aplicaciones de Rails **no** utilizan `require` para cargar el código de la aplicación.

Puede que hayas notado que `ArticlesController` hereda de `ApplicationController`, pero `app/controllers/articles_controller.rb` no tiene algo como

```ruby
require "application_controller" # NO HAGAS ESTO.
```

Las clases y módulos de la aplicación están disponibles en todas partes, no necesitas y **no debes** cargar nada bajo `app` con `require`. Esta característica se llama _carga automática_, y puedes obtener más información al respecto en [_Autoloading and Reloading Constants_](autoloading_and_reloading_constants.html).
Solo necesitas llamadas `require` para dos casos de uso:

* Cargar archivos bajo el directorio `lib`.
* Cargar dependencias de gemas que tienen `require: false` en el `Gemfile`.

MVC y Tú
--------

Hasta ahora, hemos discutido rutas, controladores, acciones y vistas. Todos estos
son componentes típicos de una aplicación web que sigue el patrón [MVC (Modelo-Vista-Controlador)](
https://en.wikipedia.org/wiki/Model%E2%80%93view%E2%80%93controller). MVC es un patrón de diseño que divide las responsabilidades de una aplicación
para facilitar el razonamiento. Rails sigue este patrón de diseño por convención.

Dado que tenemos un controlador y una vista con los que trabajar, generemos la siguiente
pieza: un modelo.

### Generando un Modelo

Un *modelo* es una clase de Ruby que se utiliza para representar datos. Además, los modelos
pueden interactuar con la base de datos de la aplicación a través de una característica de Rails llamada
*Active Record*.

Para definir un modelo, utilizaremos el generador de modelos:

```bash
$ bin/rails generate model Article title:string body:text
```

NOTA: Los nombres de los modelos son **singulares**, porque un modelo instanciado representa un
único registro de datos. Para ayudar a recordar esta convención, piensa en cómo llamarías al constructor del modelo: queremos escribir `Article.new(...)`, **no**
`Articles.new(...)`.

Esto creará varios archivos:

```
invoke  active_record
create    db/migrate/<timestamp>_create_articles.rb
create    app/models/article.rb
invoke    test_unit
create      test/models/article_test.rb
create      test/fixtures/articles.yml
```

Los dos archivos en los que nos enfocaremos son el archivo de migración
(`db/migrate/<timestamp>_create_articles.rb`) y el archivo del modelo
(`app/models/article.rb`).

### Migraciones de la Base de Datos

*Las migraciones* se utilizan para alterar la estructura de la base de datos de una aplicación. En
las aplicaciones de Rails, las migraciones se escriben en Ruby para que puedan ser
independientes de la base de datos.

Echemos un vistazo al contenido de nuestro nuevo archivo de migración:

```ruby
class CreateArticles < ActiveRecord::Migration[7.0]
  def change
    create_table :articles do |t|
      t.string :title
      t.text :body

      t.timestamps
    end
  end
end
```

La llamada a `create_table` especifica cómo se debe construir la tabla `articles`.
Por defecto, el método `create_table` agrega una columna `id` como clave primaria autoincremental.
Entonces, el primer registro en la tabla tendrá un `id` de 1, el siguiente registro tendrá un `id` de 2, y así sucesivamente.

Dentro del bloque de `create_table`, se definen dos columnas: `title` y
`body`. Estas se agregaron mediante el generador porque las incluimos en nuestro
comando de generación (`bin/rails generate model Article title:string body:text`).

En la última línea del bloque se encuentra una llamada a `t.timestamps`. Este método define
dos columnas adicionales llamadas `created_at` y `updated_at`. Como veremos,
Rails las administrará por nosotros, estableciendo los valores cuando creamos o actualizamos
un objeto del modelo.

Ejecutemos nuestra migración con el siguiente comando:

```bash
$ bin/rails db:migrate
```

El comando mostrará una salida que indica que se creó la tabla:

```
==  CreateArticles: migrating ===================================
-- create_table(:articles)
   -> 0.0018s
==  CreateArticles: migrated (0.0018s) ==========================
```

CONSEJO: Para obtener más información sobre las migraciones, consulta [Migraciones de Active Record](
active_record_migrations.html).

Ahora podemos interactuar con la tabla utilizando nuestro modelo.

### Usar un Modelo para Interactuar con la Base de Datos

Para jugar un poco con nuestro modelo, vamos a utilizar una característica de Rails llamada
*consola*. La consola es un entorno de codificación interactivo como `irb`, pero
también carga automáticamente Rails y el código de nuestra aplicación.

Iniciemos la consola con este comando:

```bash
$ bin/rails console
```

Deberías ver un indicador `irb` como este:

```irb
Loading development environment (Rails 7.0.0)
irb(main):001:0>
```

En este indicador, podemos inicializar un nuevo objeto `Article`:

```irb
irb> article = Article.new(title: "Hola Rails", body: "¡Estoy en Rails!")
```

Es importante tener en cuenta que solo hemos *inicializado* este objeto. Este objeto
no se guarda en la base de datos en absoluto. Solo está disponible en la consola en este
momento. Para guardar el objeto en la base de datos, debemos llamar a [`save`](
https://api.rubyonrails.org/classes/ActiveRecord/Persistence.html#method-i-save):

```irb
irb> article.save
(0.1ms)  begin transaction
Article Create (0.4ms)  INSERT INTO "articles" ("title", "body", "created_at", "updated_at") VALUES (?, ?, ?, ?)  [["title", "Hola Rails"], ["body", "¡Estoy en Rails!"], ["created_at", "2020-01-18 23:47:30.734416"], ["updated_at", "2020-01-18 23:47:30.734416"]]
(0.9ms)  commit transaction
=> true
```

La salida anterior muestra una consulta a la base de datos `INSERT INTO "articles" ...`. Esto
indica que el artículo se ha insertado en nuestra tabla. Y si volvemos a
ver el objeto `article`, veremos algo interesante:

```irb
irb> article
=> #<Article id: 1, title: "Hola Rails", body: "¡Estoy en Rails!", created_at: "2020-01-18 23:47:30", updated_at: "2020-01-18 23:47:30">
```
Los atributos `id`, `created_at` y `updated_at` del objeto ahora están configurados. Rails lo hizo por nosotros cuando guardamos el objeto.

Cuando queremos buscar este artículo en la base de datos, podemos llamar a [`find`] (https://api.rubyonrails.org/classes/ActiveRecord/FinderMethods.html#method-i-find) en el modelo y pasar el `id` como argumento:

```irb
irb> Article.find(1)
=> #<Article id: 1, title: "Hello Rails", body: "I am on Rails!", created_at: "2020-01-18 23:47:30", updated_at: "2020-01-18 23:47:30">
```

Y cuando queremos buscar todos los artículos en la base de datos, podemos llamar a [`all`] (https://api.rubyonrails.org/classes/ActiveRecord/Scoping/Named/ClassMethods.html#method-i-all) en el modelo:

```irb
irb> Article.all
=> #<ActiveRecord::Relation [#<Article id: 1, title: "Hello Rails", body: "I am on Rails!", created_at: "2020-01-18 23:47:30", updated_at: "2020-01-18 23:47:30">]>
```

Este método devuelve un objeto [`ActiveRecord::Relation`] (https://api.rubyonrails.org/classes/ActiveRecord/Relation.html), que se puede pensar como un array con superpoderes.

CONSEJO: Para obtener más información sobre los modelos, consulte [Active Record Basics] (active_record_basics.html) y [Active Record Query Interface] (active_record_querying.html).

Los modelos son la pieza final del rompecabezas MVC. A continuación, conectaremos todas las piezas juntas.

### Mostrando una lista de artículos

Volviendo a nuestro controlador en `app/controllers/articles_controller.rb`, y cambiamos la acción `index` para buscar todos los artículos en la base de datos:

```ruby
class ArticlesController < ApplicationController
  def index
    @articles = Article.all
  end
end
```

Las variables de instancia del controlador se pueden acceder desde la vista. Eso significa que podemos hacer referencia a `@articles` en `app/views/articles/index.html.erb`. Abramos ese archivo y reemplacemos su contenido con:

```html+erb
<h1>Articles</h1>

<ul>
  <% @articles.each do |article| %>
    <li>
      <%= article.title %>
    </li>
  <% end %>
</ul>
```

El código anterior es una mezcla de HTML y *ERB*. ERB es un sistema de plantillas que evalúa código Ruby incrustado en un documento. Aquí, podemos ver dos tipos de etiquetas ERB: `<% %>` y `<%= %>`. La etiqueta `<% %>` significa "evaluar el código Ruby encerrado". La etiqueta `<%= %>` significa "evaluar el código Ruby encerrado y mostrar el valor que devuelve". Cualquier cosa que se pueda escribir en un programa Ruby regular puede ir dentro de estas etiquetas ERB, aunque generalmente es mejor mantener el contenido de las etiquetas ERB corto, para facilitar la lectura.

Dado que no queremos mostrar el valor devuelto por `@articles.each`, hemos encerrado ese código en `<% %>`. Pero, dado que *sí* queremos mostrar el valor devuelto por `article.title` (para cada artículo), hemos encerrado ese código en `<%= %>`.

Podemos ver el resultado final visitando <http://localhost:3000>. (¡Recuerda que `bin/rails server` debe estar en ejecución!) Esto es lo que sucede cuando lo hacemos:

1. El navegador realiza una solicitud: `GET http://localhost:3000`.
2. Nuestra aplicación Rails recibe esta solicitud.
3. El enrutador de Rails asigna la ruta raíz a la acción `index` de `ArticlesController`.
4. La acción `index` utiliza el modelo `Article` para buscar todos los artículos en la base de datos.
5. Rails renderiza automáticamente la vista `app/views/articles/index.html.erb`.
6. El código ERB en la vista se evalúa para mostrar HTML.
7. El servidor envía una respuesta que contiene el HTML de vuelta al navegador.

Hemos conectado todas las piezas del MVC y tenemos nuestra primera acción del controlador. A continuación, pasaremos a la segunda acción.

CRUDit Donde CRUDit Es Debido
--------------------------

Casi todas las aplicaciones web involucran operaciones CRUD (Crear, Leer, Actualizar y Eliminar). Incluso puede encontrar que la mayoría del trabajo que realiza su aplicación es CRUD. Rails reconoce esto y proporciona muchas características para ayudar a simplificar el código que realiza CRUD.

Comencemos a explorar estas características agregando más funcionalidad a nuestra aplicación.

### Mostrando un solo artículo

Actualmente tenemos una vista que muestra todos los artículos en nuestra base de datos. Agreguemos una nueva vista que muestre el título y el cuerpo de un solo artículo.

Comenzamos agregando una nueva ruta que se asigna a una nueva acción del controlador (que agregaremos a continuación). Abra `config/routes.rb` e inserte la última ruta mostrada aquí:

```ruby
Rails.application.routes.draw do
  root "articles#index"

  get "/articles", to: "articles#index"
  get "/articles/:id", to: "articles#show"
end
```

La nueva ruta es otra ruta `get`, pero tiene algo adicional en su ruta: `:id`. Esto designa un *parámetro de ruta*. Un parámetro de ruta captura un segmento de la ruta de la solicitud y coloca ese valor en el Hash `params`, al que se puede acceder desde la acción del controlador. Por ejemplo, al manejar una solicitud como `GET http://localhost:3000/articles/1`, `1` se capturaría como el valor para `:id`, que luego sería accesible como `params[:id]` en la acción `show` de `ArticlesController`.
Agreguemos ahora esa acción `show`, debajo de la acción `index` en `app/controllers/articles_controller.rb`:

```ruby
class ArticlesController < ApplicationController
  def index
    @articles = Article.all
  end

  def show
    @article = Article.find(params[:id])
  end
end
```

La acción `show` llama a `Article.find` (mencionado anteriormente) con el ID capturado por el parámetro de la ruta. El artículo devuelto se guarda en la variable de instancia `@article`, por lo que es accesible desde la vista. Por defecto, la acción `show` renderizará `app/views/articles/show.html.erb`.

Creemos `app/views/articles/show.html.erb`, con el siguiente contenido:

```html+erb
<h1><%= @article.title %></h1>

<p><%= @article.body %></p>
```

¡Ahora podemos ver el artículo cuando visitamos <http://localhost:3000/articles/1>!

Para terminar, agreguemos una forma conveniente de acceder a la página de un artículo. Vamos a enlazar el título de cada artículo en `app/views/articles/index.html.erb` a su página:

```html+erb
<h1>Artículos</h1>

<ul>
  <% @articles.each do |article| %>
    <li>
      <a href="/articles/<%= article.id %>">
        <%= article.title %>
      </a>
    </li>
  <% end %>
</ul>
```

### Enrutamiento de recursos

Hasta ahora, hemos cubierto la "Lectura" (Read) de CRUD. Eventualmente cubriremos las secciones "C" (Create), "U" (Update) y "D" (Delete). Como podrás haber adivinado, lo haremos agregando nuevas rutas, acciones de controlador y vistas. Cuando tenemos una combinación de rutas, acciones de controlador y vistas que trabajan juntas para realizar operaciones CRUD en una entidad, llamamos a esa entidad un *recurso*. Por ejemplo, en nuestra aplicación, podríamos decir que un artículo es un recurso.

Rails proporciona un método de rutas llamado [`resources`](
https://api.rubyonrails.org/classes/ActionDispatch/Routing/Mapper/Resources.html#method-i-resources)
que mapea todas las rutas convencionales para una colección de recursos, como los artículos. Así que antes de pasar a las secciones "C", "U" y "D", reemplacemos las dos rutas `get` en `config/routes.rb` con `resources`:

```ruby
Rails.application.routes.draw do
  root "articles#index"

  resources :articles
end
```

Podemos inspeccionar qué rutas se mapean ejecutando el comando `bin/rails routes`:

```bash
$ bin/rails routes
      Prefix Verb   URI Pattern                  Controller#Action
        root GET    /                            articles#index
    articles GET    /articles(.:format)          articles#index
 new_article GET    /articles/new(.:format)      articles#new
     article GET    /articles/:id(.:format)      articles#show
             POST   /articles(.:format)          articles#create
edit_article GET    /articles/:id/edit(.:format) articles#edit
             PATCH  /articles/:id(.:format)      articles#update
             DELETE /articles/:id(.:format)      articles#destroy
```

El método `resources` también configura métodos auxiliares de URL y ruta que podemos usar para evitar que nuestro código dependa de una configuración de ruta específica. Los valores en la columna "Prefix" más un sufijo de `_url` o `_path` forman los nombres de estos ayudantes. Por ejemplo, el ayudante `article_path` devuelve `"/articles/#{article.id}"` cuando se le pasa un artículo. Podemos usarlo para mejorar nuestros enlaces en `app/views/articles/index.html.erb`:

```html+erb
<h1>Artículos</h1>

<ul>
  <% @articles.each do |article| %>
    <li>
      <a href="<%= article_path(article) %>">
        <%= article.title %>
      </a>
    </li>
  <% end %>
</ul>
```

Sin embargo, daremos un paso más utilizando el ayudante [`link_to`](
https://api.rubyonrails.org/classes/ActionView/Helpers/UrlHelper.html#method-i-link_to).
El ayudante `link_to` renderiza un enlace con su primer argumento como el texto del enlace y su segundo argumento como el destino del enlace. Si pasamos un objeto de modelo como segundo argumento, `link_to` llamará al ayudante de ruta correspondiente para convertir el objeto en una ruta. Por ejemplo, si pasamos un artículo, `link_to` llamará a `article_path`. Por lo tanto, `app/views/articles/index.html.erb` se convierte en:

```html+erb
<h1>Artículos</h1>

<ul>
  <% @articles.each do |article| %>
    <li>
      <%= link_to article.title, article %>
    </li>
  <% end %>
</ul>
```

¡Genial!

CONSEJO: Para obtener más información sobre el enrutamiento, consulta [Rails Routing from the Outside In](
routing.html).

### Crear un nuevo artículo

Ahora pasamos a la "C" (Create) de CRUD. Típicamente, en aplicaciones web, crear un nuevo recurso es un proceso de varios pasos. Primero, el usuario solicita un formulario para completar. Luego, el usuario envía el formulario. Si no hay errores, entonces se crea el recurso y se muestra alguna confirmación. De lo contrario, el formulario se muestra nuevamente con mensajes de error y se repite el proceso.

En una aplicación Rails, estos pasos se manejan convencionalmente mediante las acciones `new` y `create` de un controlador. Agreguemos una implementación típica de estas acciones a `app/controllers/articles_controller.rb`, debajo de la acción `show`:

```ruby
class ArticlesController < ApplicationController
  def index
    @articles = Article.all
  end

  def show
    @article = Article.find(params[:id])
  end

  def new
    @article = Article.new
  end

  def create
    @article = Article.new(title: "...", body: "...")

    if @article.save
      redirect_to @article
    else
      render :new, status: :unprocessable_entity
    end
  end
end
```

La acción `new` instancia un nuevo artículo, pero no lo guarda. Este artículo se utilizará en la vista al construir el formulario. Por defecto, la acción `new` renderizará `app/views/articles/new.html.erb`, que crearemos a continuación.
La acción `create` instancia un nuevo artículo con valores para el título y el cuerpo, e intenta guardarlo. Si el artículo se guarda correctamente, la acción redirige el navegador a la página del artículo en `"http://localhost:3000/articles/#{@article.id}"`.
De lo contrario, la acción vuelve a mostrar el formulario al renderizar `app/views/articles/new.html.erb` con el código de estado [422 Entidad no procesable](https://developer.mozilla.org/es/docs/Web/HTTP/Status/422).
Aquí, el título y el cuerpo son valores ficticios. Después de crear el formulario, volveremos y cambiaremos estos valores.

NOTA: [`redirect_to`](https://api.rubyonrails.org/classes/ActionController/Redirecting.html#method-i-redirect_to)
hará que el navegador realice una nueva solicitud,
mientras que [`render`](https://api.rubyonrails.org/classes/AbstractController/Rendering.html#method-i-render)
renderiza la vista especificada para la solicitud actual.
Es importante usar `redirect_to` después de modificar la base de datos o el estado de la aplicación.
De lo contrario, si el usuario actualiza la página, el navegador realizará la misma solicitud y la modificación se repetirá.

#### Usando un constructor de formularios

Utilizaremos una característica de Rails llamada *constructor de formularios* para crear nuestro formulario. Usando un constructor de formularios, podemos escribir una cantidad mínima de código para generar un formulario completamente configurado y que siga las convenciones de Rails.

Creemos `app/views/articles/new.html.erb` con el siguiente contenido:

```html+erb
<h1>Nuevo Artículo</h1>

<%= form_with model: @article do |form| %>
  <div>
    <%= form.label :title %><br>
    <%= form.text_field :title %>
  </div>

  <div>
    <%= form.label :body %><br>
    <%= form.text_area :body %>
  </div>

  <div>
    <%= form.submit %>
  </div>
<% end %>
```

El método auxiliar [`form_with`](https://api.rubyonrails.org/classes/ActionView/Helpers/FormHelper.html#method-i-form_with)
instancia un constructor de formularios. En el bloque `form_with` llamamos a
métodos como [`label`](https://api.rubyonrails.org/classes/ActionView/Helpers/FormBuilder.html#method-i-label)
y [`text_field`](https://api.rubyonrails.org/classes/ActionView/Helpers/FormBuilder.html#method-i-text_field)
en el constructor de formularios para generar los elementos de formulario correspondientes.

La salida resultante de nuestra llamada a `form_with` se verá así:

```html
<form action="/articles" accept-charset="UTF-8" method="post">
  <input type="hidden" name="authenticity_token" value="...">

  <div>
    <label for="article_title">Título</label><br>
    <input type="text" name="article[title]" id="article_title">
  </div>

  <div>
    <label for="article_body">Cuerpo</label><br>
    <textarea name="article[body]" id="article_body"></textarea>
  </div>

  <div>
    <input type="submit" name="commit" value="Crear Artículo" data-disable-with="Crear Artículo">
  </div>
</form>
```

CONSEJO: Para obtener más información sobre los constructores de formularios, consulta [Action View Form Helpers](
form_helpers.html).

#### Usando Strong Parameters

Los datos del formulario enviado se colocan en el Hash `params`, junto con los parámetros de ruta capturados. Por lo tanto, la acción `create` puede acceder al título enviado a través de `params[:article][:title]` y al cuerpo enviado a través de `params[:article][:body]`. Podríamos pasar estos valores individualmente a `Article.new`, pero eso sería verboso y posiblemente propenso a errores. Y empeoraría a medida que agregamos más campos.

En su lugar, pasaremos un solo Hash que contenga los valores. Sin embargo, aún debemos especificar qué valores están permitidos en ese Hash. De lo contrario, un usuario malintencionado podría enviar campos de formulario adicionales y sobrescribir datos privados. De hecho, si pasamos directamente el Hash `params[:article]` sin filtrar a `Article.new`, Rails generará un error `ForbiddenAttributesError` para alertarnos sobre el problema. Por lo tanto, utilizaremos una característica de Rails llamada *Strong Parameters* para filtrar `params`. Piensa en ello como una [tipificación fuerte](https://es.wikipedia.org/wiki/Tipado_fuerte_y_d%C3%A9bil) para `params`.

Agreguemos un método privado al final de `app/controllers/articles_controller.rb` llamado `article_params` que filtre `params`. Y cambiemos `create` para usarlo:

```ruby
class ArticlesController < ApplicationController
  def index
    @articles = Article.all
  end

  def show
    @article = Article.find(params[:id])
  end

  def new
    @article = Article.new
  end

  def create
    @article = Article.new(article_params)

    if @article.save
      redirect_to @article
    else
      render :new, status: :unprocessable_entity
    end
  end

  private
    def article_params
      params.require(:article).permit(:title, :body)
    end
end
```

CONSEJO: Para obtener más información sobre Strong Parameters, consulta [Resumen de Action Controller §
Strong Parameters](action_controller_overview.html#strong-parameters).

#### Validaciones y Mostrar Mensajes de Error

Como hemos visto, crear un recurso es un proceso de varios pasos. Manejar una entrada de usuario no válida es otro paso de ese proceso. Rails proporciona una característica llamada *validaciones* para ayudarnos a lidiar con una entrada de usuario no válida. Las validaciones son reglas que se verifican antes de que se guarde un objeto de modelo. Si alguna de las verificaciones falla, el guardado se abortará y se agregarán mensajes de error apropiados al atributo `errors` del objeto de modelo.

Agreguemos algunas validaciones a nuestro modelo en `app/models/article.rb`:

```ruby
class Article < ApplicationRecord
  validates :title, presence: true
  validates :body, presence: true, length: { minimum: 10 }
end
```

La primera validación declara que un valor de `title` debe estar presente. Dado que `title` es una cadena, esto significa que el valor de `title` debe contener al menos un carácter que no sea un espacio en blanco.

La segunda validación declara que también debe estar presente un valor de `body`. Además, declara que el valor de `body` debe tener al menos 10 caracteres de longitud.

NOTA: Es posible que te preguntes dónde se definen los atributos `title` y `body`. Active Record define automáticamente los atributos del modelo para cada columna de la tabla, por lo que no es necesario declarar esos atributos en el archivo del modelo.
Con nuestras validaciones en su lugar, modifiquemos `app/views/articles/new.html.erb` para mostrar cualquier mensaje de error para `title` y `body`:

```html+erb
<h1>Nuevo Artículo</h1>

<%= form_with model: @article do |form| %>
  <div>
    <%= form.label :title %><br>
    <%= form.text_field :title %>
    <% @article.errors.full_messages_for(:title).each do |message| %>
      <div><%= message %></div>
    <% end %>
  </div>

  <div>
    <%= form.label :body %><br>
    <%= form.text_area :body %><br>
    <% @article.errors.full_messages_for(:body).each do |message| %>
      <div><%= message %></div>
    <% end %>
  </div>

  <div>
    <%= form.submit %>
  </div>
<% end %>
```

El método [`full_messages_for`](https://api.rubyonrails.org/classes/ActiveModel/Errors.html#method-i-full_messages_for)
devuelve una matriz de mensajes de error amigables para el usuario para un atributo especificado. Si no hay errores para ese atributo, la matriz estará vacía.

Para entender cómo funciona todo esto en conjunto, echemos otro vistazo a las acciones del controlador `new` y `create`:

```ruby
  def new
    @article = Article.new
  end

  def create
    @article = Article.new(article_params)

    if @article.save
      redirect_to @article
    else
      render :new, status: :unprocessable_entity
    end
  end
```

Cuando visitamos <http://localhost:3000/articles/new>, la solicitud `GET /articles/new` se asigna a la acción `new`. La acción `new` no intenta guardar `@article`. Por lo tanto, las validaciones no se verifican y no habrá mensajes de error.

Cuando enviamos el formulario, la solicitud `POST /articles` se asigna a la acción `create`. La acción `create` *sí* intenta guardar `@article`. Por lo tanto, las validaciones *se* verifican. Si alguna validación falla, `@article` no se guardará y se renderizará `app/views/articles/new.html.erb` con mensajes de error.

CONSEJO: Para obtener más información sobre las validaciones, consulta [Validaciones de Active Record](active_record_validations.html). Para obtener más información sobre los mensajes de error de validación, consulta [Validaciones de Active Record § Trabajar con mensajes de error de validación](active_record_validations.html#working-with-validation-errors).

#### Finalizando

Ahora podemos crear un artículo visitando <http://localhost:3000/articles/new>. Para finalizar, agreguemos un enlace a esa página en la parte inferior de `app/views/articles/index.html.erb`:

```html+erb
<h1>Artículos</h1>

<ul>
  <% @articles.each do |article| %>
    <li>
      <%= link_to article.title, article %>
    </li>
  <% end %>
</ul>

<%= link_to "Nuevo Artículo", new_article_path %>
```

### Actualizando un Artículo

Hemos cubierto el "CR" de CRUD. Ahora pasemos al "U" (Actualizar). Actualizar un recurso es muy similar a crear un recurso. Ambos son procesos de múltiples pasos. Primero, el usuario solicita un formulario para editar los datos. Luego, el usuario envía el formulario. Si no hay errores, entonces el recurso se actualiza. De lo contrario, el formulario se muestra nuevamente con mensajes de error y el proceso se repite.

Estos pasos se manejan convencionalmente mediante las acciones `edit` y `update` de un controlador. Agreguemos una implementación típica de estas acciones a `app/controllers/articles_controller.rb`, debajo de la acción `create`:

```ruby
class ArticlesController < ApplicationController
  def index
    @articles = Article.all
  end

  def show
    @article = Article.find(params[:id])
  end

  def new
    @article = Article.new
  end

  def create
    @article = Article.new(article_params)

    if @article.save
      redirect_to @article
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @article = Article.find(params[:id])
  end

  def update
    @article = Article.find(params[:id])

    if @article.update(article_params)
      redirect_to @article
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private
    def article_params
      params.require(:article).permit(:title, :body)
    end
end
```

Observa cómo las acciones `edit` y `update` se asemejan a las acciones `new` y `create`.

La acción `edit` obtiene el artículo de la base de datos y lo almacena en `@article` para que se pueda usar al construir el formulario. Por defecto, la acción `edit` renderizará `app/views/articles/edit.html.erb`.

La acción `update` vuelve a obtener el artículo de la base de datos e intenta actualizarlo con los datos del formulario enviados filtrados por `article_params`. Si no hay validaciones que fallen y la actualización tiene éxito, la acción redirige el navegador a la página del artículo. De lo contrario, la acción vuelve a mostrar el formulario, con mensajes de error, al renderizar `app/views/articles/edit.html.erb`.

#### Usar Partials para Compartir Código de Vista

Nuestro formulario `edit` se verá igual que nuestro formulario `new`. Incluso el código será el mismo, gracias al constructor de formularios de Rails y el enrutamiento basado en recursos. El constructor de formularios configura automáticamente el formulario para realizar el tipo de solicitud adecuado, según si el objeto del modelo se ha guardado previamente.

Dado que el código será el mismo, lo vamos a extraer en una vista compartida llamada *partial*. Creemos `app/views/articles/_form.html.erb` con el siguiente contenido:

```html+erb
<%= form_with model: article do |form| %>
  <div>
    <%= form.label :title %><br>
    <%= form.text_field :title %>
    <% article.errors.full_messages_for(:title).each do |message| %>
      <div><%= message %></div>
    <% end %>
  </div>

  <div>
    <%= form.label :body %><br>
    <%= form.text_area :body %><br>
    <% article.errors.full_messages_for(:body).each do |message| %>
      <div><%= message %></div>
    <% end %>
  </div>

  <div>
    <%= form.submit %>
  </div>
<% end %>
```
El código anterior es el mismo que nuestro formulario en `app/views/articles/new.html.erb`,
excepto que todas las apariciones de `@article` han sido reemplazadas por `article`.
Dado que los parciales son código compartido, es una buena práctica que no dependan de
variables de instancia específicas establecidas por una acción del controlador. En su lugar, pasaremos
el artículo al parcial como una variable local.

Actualicemos `app/views/articles/new.html.erb` para usar el parcial a través de [`render`](
https://api.rubyonrails.org/classes/ActionView/Helpers/RenderingHelper.html#method-i-render):

```html+erb
<h1>Nuevo Artículo</h1>

<%= render "form", article: @article %>
```

NOTA: El nombre de archivo de un parcial debe tener un guión bajo como prefijo, por ejemplo,
`_form.html.erb`. Pero al renderizar, se hace referencia **sin** el guión bajo, por ejemplo, `render "form"`.

Y ahora, creemos un `app/views/articles/edit.html.erb` muy similar:

```html+erb
<h1>Editar Artículo</h1>

<%= render "form", article: @article %>
```

CONSEJO: Para obtener más información sobre parciales, consulta [Layouts and Rendering in Rails § Using
Partials](layouts_and_rendering.html#using-partials).

#### Finalizando

Ahora podemos actualizar un artículo visitando su página de edición, por ejemplo,
<http://localhost:3000/articles/1/edit>. Para finalizar, agreguemos un enlace a la página de edición desde el final de `app/views/articles/show.html.erb`:

```html+erb
<h1><%= @article.title %></h1>

<p><%= @article.body %></p>

<ul>
  <li><%= link_to "Editar", edit_article_path(@article) %></li>
</ul>
```

### Eliminando un Artículo

Finalmente, llegamos a la "D" (Delete) de CRUD. Eliminar un recurso es un proceso más simple
que crear o actualizar. Solo requiere una ruta y una acción del controlador. Y nuestras rutas de recursos (`resources :articles`) ya proporcionan la
ruta, que mapea las solicitudes `DELETE /articles/:id` a la acción `destroy` del
controlador `ArticlesController`.

Entonces, agreguemos una acción `destroy` típica a `app/controllers/articles_controller.rb`,
debajo de la acción `update`:

```ruby
class ArticlesController < ApplicationController
  def index
    @articles = Article.all
  end

  def show
    @article = Article.find(params[:id])
  end

  def new
    @article = Article.new
  end

  def create
    @article = Article.new(article_params)

    if @article.save
      redirect_to @article
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @article = Article.find(params[:id])
  end

  def update
    @article = Article.find(params[:id])

    if @article.update(article_params)
      redirect_to @article
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @article = Article.find(params[:id])
    @article.destroy

    redirect_to root_path, status: :see_other
  end

  private
    def article_params
      params.require(:article).permit(:title, :body)
    end
end
```

La acción `destroy` obtiene el artículo de la base de datos y llama a [`destroy`](
https://api.rubyonrails.org/classes/ActiveRecord/Persistence.html#method-i-destroy)
en él. Luego, redirige el navegador a la ruta raíz con el código de estado
[303 See Other](https://developer.mozilla.org/en-US/docs/Web/HTTP/Status/303).

Hemos elegido redirigir a la ruta raíz porque ese es nuestro punto principal de acceso
para los artículos. Pero, en otras circunstancias, podrías elegir redirigir a
por ejemplo, `articles_path`.

Ahora agreguemos un enlace al final de `app/views/articles/show.html.erb` para que
podamos eliminar un artículo desde su propia página:

```html+erb
<h1><%= @article.title %></h1>

<p><%= @article.body %></p>

<ul>
  <li><%= link_to "Editar", edit_article_path(@article) %></li>
  <li><%= link_to "Eliminar", article_path(@article), data: {
                    turbo_method: :delete,
                    turbo_confirm: "¿Estás seguro?"
                  } %></li>
</ul>
```

En el código anterior, usamos la opción `data` para establecer los atributos HTML `data-turbo-method` y
`data-turbo-confirm` del enlace "Eliminar". Ambos atributos se conectan a [Turbo](https://turbo.hotwired.dev/), que está incluido de forma predeterminada en las aplicaciones Rails nuevas. `data-turbo-method="delete"` hará que el
enlace realice una solicitud `DELETE` en lugar de una solicitud `GET`.
`data-turbo-confirm="¿Estás seguro?"` hará que aparezca un cuadro de diálogo de confirmación
cuando se hace clic en el enlace. Si el usuario cancela el cuadro de diálogo, la solicitud se
cancelará.

¡Y eso es todo! ¡Ahora podemos listar, mostrar, crear, actualizar y eliminar artículos!
¡InCRUDable!

Agregando un Segundo Modelo
---------------------------

Es hora de agregar un segundo modelo a la aplicación. El segundo modelo se encargará
de los comentarios en los artículos.

### Generando un Modelo

Vamos a utilizar el mismo generador que usamos anteriormente para crear
el modelo `Article`. Esta vez crearemos un modelo `Comment` para almacenar una
referencia a un artículo. Ejecuta este comando en tu terminal:

```bash
$ bin/rails generate model Comment commenter:string body:text article:references
```

Este comando generará cuatro archivos:

| Archivo                                         | Propósito                                                                                                 |
| ----------------------------------------------- | -------------------------------------------------------------------------------------------------------- |
| db/migrate/20140120201010_create_comments.rb    | Migración para crear la tabla de comentarios en tu base de datos (tu nombre incluirá una marca de tiempo diferente) |
| app/models/comment.rb                           | El modelo Comment                                                                                         |
| test/models/comment_test.rb                     | Conjunto de pruebas para el modelo Comment                                                                |
| test/fixtures/comments.yml                      | Comentarios de muestra para usar en las pruebas                                                           |

Primero, echa un vistazo a `app/models/comment.rb`:

```ruby
class Comment < ApplicationRecord
  belongs_to :article
end
```

Esto es muy similar al modelo `Article` que viste anteriormente. La diferencia
es la línea `belongs_to :article`, que configura una _asociación_ de Active Record.
Aprenderás un poco sobre asociaciones en la siguiente sección de esta guía.
La palabra clave (`:references`) utilizada en el comando de shell es un tipo de dato especial para modelos.
Crea una nueva columna en la tabla de tu base de datos con el nombre del modelo proporcionado seguido de `_id`
que puede contener valores enteros. Para comprender mejor, analiza el archivo `db/schema.rb` después de ejecutar la migración.

Además del modelo, Rails también ha creado una migración para crear la
tabla correspondiente en la base de datos:

```ruby
class CreateComments < ActiveRecord::Migration[7.0]
  def change
    create_table :comments do |t|
      t.string :commenter
      t.text :body
      t.references :article, null: false, foreign_key: true

      t.timestamps
    end
  end
end
```

La línea `t.references` crea una columna entera llamada `article_id`, un índice
para ella y una restricción de clave externa que apunta a la columna `id` de la tabla `articles`.
Ve y ejecuta la migración:

```bash
$ bin/rails db:migrate
```

Rails es lo suficientemente inteligente como para ejecutar solo las migraciones que aún no se hayan
ejecutado en la base de datos actual, por lo que en este caso solo verás:

```
==  CreateComments: migrating =================================================
-- create_table(:comments)
   -> 0.0115s
==  CreateComments: migrated (0.0119s) ========================================
```

### Asociación de modelos

Las asociaciones de Active Record te permiten declarar fácilmente la relación entre dos
modelos. En el caso de los comentarios y los artículos, podrías escribir las
relaciones de esta manera:

* Cada comentario pertenece a un artículo.
* Un artículo puede tener muchos comentarios.

De hecho, esto es muy similar a la sintaxis que Rails utiliza para declarar esta
asociación. Ya has visto la línea de código dentro del modelo `Comment`
(app/models/comment.rb) que hace que cada comentario pertenezca a un Artículo:

```ruby
class Comment < ApplicationRecord
  belongs_to :article
end
```

Necesitarás editar `app/models/article.rb` para agregar el otro lado de la
asociación:

```ruby
class Article < ApplicationRecord
  has_many :comments

  validates :title, presence: true
  validates :body, presence: true, length: { minimum: 10 }
end
```

Estas dos declaraciones permiten un buen comportamiento automático. Por ejemplo, si
tienes una variable de instancia `@article` que contiene un artículo, puedes recuperar
todos los comentarios que pertenecen a ese artículo como un array usando
`@article.comments`.

CONSEJO: Para obtener más información sobre las asociaciones de Active Record, consulta la [Guía de asociaciones de Active Record](association_basics.html).

### Agregar una ruta para los comentarios

Al igual que con el controlador `articles`, deberemos agregar una ruta para que Rails
sepa a dónde queremos navegar para ver los `comments`. Abre el archivo
`config/routes.rb` nuevamente y edítalo de la siguiente manera:

```ruby
Rails.application.routes.draw do
  root "articles#index"

  resources :articles do
    resources :comments
  end
end
```

Esto crea `comments` como un _recurso anidado_ dentro de `articles`. Esto es
otra parte de capturar la relación jerárquica que existe entre
artículos y comentarios.

CONSEJO: Para obtener más información sobre el enrutamiento, consulta la [Guía de enrutamiento de Rails](routing.html).

### Generar un controlador

Con el modelo en mano, puedes centrarte en crear un controlador correspondiente.
Nuevamente, utilizaremos el mismo generador que usamos antes:

```bash
$ bin/rails generate controller Comments
```

Esto crea tres archivos y un directorio vacío:

| Archivo/Directorio                           | Propósito                                 |
| -------------------------------------------- | ---------------------------------------- |
| app/controllers/comments_controller.rb       | El controlador Comments                  |
| app/views/comments/                          | Aquí se almacenan las vistas del controlador |
| test/controllers/comments_controller_test.rb | La prueba para el controlador             |
| app/helpers/comments_helper.rb               | Un archivo de ayuda para las vistas       |

Al igual que con cualquier blog, nuestros lectores crearán sus comentarios directamente después
de leer el artículo, y una vez que hayan agregado su comentario, se les enviará de vuelta
a la página de visualización del artículo para ver su comentario en la lista. Debido a esto, nuestro
`CommentsController` está allí para proporcionar un método para crear comentarios y eliminar
comentarios de spam cuando lleguen.

Entonces, primero conectaremos la plantilla de visualización del artículo
(`app/views/articles/show.html.erb`) para permitirnos crear un nuevo comentario:

```html+erb
<h1><%= @article.title %></h1>

<p><%= @article.body %></p>

<ul>
  <li><%= link_to "Edit", edit_article_path(@article) %></li>
  <li><%= link_to "Destroy", article_path(@article), data: {
                    turbo_method: :delete,
                    turbo_confirm: "Are you sure?"
                  } %></li>
</ul>

<h2>Add a comment:</h2>
<%= form_with model: [ @article, @article.comments.build ] do |form| %>
  <p>
    <%= form.label :commenter %><br>
    <%= form.text_field :commenter %>
  </p>
  <p>
    <%= form.label :body %><br>
    <%= form.text_area :body %>
  </p>
  <p>
    <%= form.submit %>
  </p>
<% end %>
```

Esto agrega un formulario en la página de visualización del `Article` que crea un nuevo comentario
llamando a la acción `create` del `CommentsController`. La llamada `form_with` aquí utiliza
un array, que construirá una ruta anidada, como `/articles/1/comments`.
Vamos a conectar el método `create` en `app/controllers/comments_controller.rb`:

```ruby
class CommentsController < ApplicationController
  def create
    @article = Article.find(params[:article_id])
    @comment = @article.comments.create(comment_params)
    redirect_to article_path(@article)
  end

  private
    def comment_params
      params.require(:comment).permit(:commenter, :body)
    end
end
```

Aquí verás un poco más de complejidad que en el controlador de artículos. Esto es un efecto secundario del anidamiento que has configurado. Cada solicitud de un comentario debe hacer un seguimiento del artículo al que está adjunto el comentario, por lo que se realiza una llamada inicial al método `find` del modelo `Article` para obtener el artículo en cuestión.

Además, el código aprovecha algunos de los métodos disponibles para una asociación. Utilizamos el método `create` en `@article.comments` para crear y guardar el comentario. Esto vinculará automáticamente el comentario para que pertenezca a ese artículo en particular.

Una vez que hemos creado el nuevo comentario, redirigimos al usuario de vuelta al artículo original utilizando el ayudante `article_path(@article)`. Como ya hemos visto, esto llama a la acción `show` del controlador `ArticlesController`, que a su vez renderiza la plantilla `show.html.erb`. Aquí es donde queremos que se muestre el comentario, así que vamos a agregar eso a `app/views/articles/show.html.erb`.

```html+erb
<h1><%= @article.title %></h1>

<p><%= @article.body %></p>

<ul>
  <li><%= link_to "Editar", edit_article_path(@article) %></li>
  <li><%= link_to "Eliminar", article_path(@article), data: {
                    turbo_method: :delete,
                    turbo_confirm: "¿Estás seguro?"
                  } %></li>
</ul>

<h2>Comentarios</h2>
<% @article.comments.each do |comment| %>
  <p>
    <strong>Comentarista:</strong>
    <%= comment.commenter %>
  </p>

  <p>
    <strong>Comentario:</strong>
    <%= comment.body %>
  </p>
<% end %>

<h2>Agregar un comentario:</h2>
<%= form_with model: [ @article, @article.comments.build ] do |form| %>
  <p>
    <%= form.label :commenter %><br>
    <%= form.text_field :commenter %>
  </p>
  <p>
    <%= form.label :body %><br>
    <%= form.text_area :body %>
  </p>
  <p>
    <%= form.submit %>
  </p>
<% end %>
```

Ahora puedes agregar artículos y comentarios a tu blog y hacer que aparezcan en los lugares correctos.

![Artículo con comentarios](images/getting_started/article_with_comments.png)

Refactorización
-----------

Ahora que tenemos los artículos y comentarios funcionando, echemos un vistazo a la plantilla `app/views/articles/show.html.erb`. Se está volviendo larga y complicada. Podemos usar parciales para limpiarla.

### Renderizando colecciones de parciales

Primero, vamos a crear un parcial para los comentarios y extraer la lógica de mostrar todos los comentarios del artículo. Crea el archivo `app/views/comments/_comment.html.erb` y coloca lo siguiente en él:

```html+erb
<p>
  <strong>Comentarista:</strong>
  <%= comment.commenter %>
</p>

<p>
  <strong>Comentario:</strong>
  <%= comment.body %>
</p>
```

Luego, puedes cambiar `app/views/articles/show.html.erb` para que se vea así:

```html+erb
<h1><%= @article.title %></h1>

<p><%= @article.body %></p>

<ul>
  <li><%= link_to "Editar", edit_article_path(@article) %></li>
  <li><%= link_to "Eliminar", article_path(@article), data: {
                    turbo_method: :delete,
                    turbo_confirm: "¿Estás seguro?"
                  } %></li>
</ul>

<h2>Comentarios</h2>
<%= render @article.comments %>

<h2>Agregar un comentario:</h2>
<%= form_with model: [ @article, @article.comments.build ] do |form| %>
  <p>
    <%= form.label :commenter %><br>
    <%= form.text_field :commenter %>
  </p>
  <p>
    <%= form.label :body %><br>
    <%= form.text_area :body %>
  </p>
  <p>
    <%= form.submit %>
  </p>
<% end %>
```

Esto ahora renderizará el parcial en `app/views/comments/_comment.html.erb` una vez por cada comentario que esté en la colección `@article.comments`. A medida que el método `render` itera sobre la colección `@article.comments`, asigna cada comentario a una variable local con el mismo nombre que el parcial, en este caso `comment`, que luego está disponible en el parcial para mostrarlo.

### Renderizando un formulario parcial

También vamos a mover esa sección de agregar un nuevo comentario a su propio parcial. Nuevamente, crea un archivo `app/views/comments/_form.html.erb` que contenga:

```html+erb
<%= form_with model: [ @article, @article.comments.build ] do |form| %>
  <p>
    <%= form.label :commenter %><br>
    <%= form.text_field :commenter %>
  </p>
  <p>
    <%= form.label :body %><br>
    <%= form.text_area :body %>
  </p>
  <p>
    <%= form.submit %>
  </p>
<% end %>
```

Luego, haz que `app/views/articles/show.html.erb` se vea así:

```html+erb
<h1><%= @article.title %></h1>

<p><%= @article.body %></p>

<ul>
  <li><%= link_to "Editar", edit_article_path(@article) %></li>
  <li><%= link_to "Eliminar", article_path(@article), data: {
                    turbo_method: :delete,
                    turbo_confirm: "¿Estás seguro?"
                  } %></li>
</ul>

<h2>Comentarios</h2>
<%= render @article.comments %>

<h2>Agregar un comentario:</h2>
<%= render 'comments/form' %>
```

El segundo `render` simplemente define la plantilla parcial que queremos renderizar, `comments/form`. Rails es lo suficientemente inteligente como para detectar la barra diagonal en esa cadena y darse cuenta de que quieres renderizar el archivo `_form.html.erb` en el directorio `app/views/comments`.

El objeto `@article` está disponible para cualquier parcial que se renderice en la vista porque lo hemos definido como una variable de instancia.

### Uso de Concerns

Los Concerns son una forma de hacer que los controladores o modelos grandes sean más fáciles de entender y gestionar. Esto también tiene la ventaja de ser reutilizable cuando varios modelos (o controladores) comparten los mismos Concerns. Los Concerns se implementan utilizando módulos que contienen métodos que representan una porción bien definida de la funcionalidad de un modelo o controlador. En otros lenguajes, los módulos a menudo se conocen como mixins.
Puedes usar concerns en tu controlador o modelo de la misma manera que usarías cualquier módulo. Cuando creaste tu aplicación con `rails new blog`, se crearon dos carpetas dentro de `app/` junto con el resto:

```
app/controllers/concerns
app/models/concerns
```

En el siguiente ejemplo, implementaremos una nueva funcionalidad para nuestro blog que se beneficiaría de usar un concern. Luego, crearemos un concern y refactorizaremos el código para usarlo, haciendo que el código sea más DRY y mantenible.

Un artículo de blog puede tener varios estados, por ejemplo, puede ser visible para todos (es decir, `public`), o solo visible para el autor (es decir, `private`). También puede estar oculto para todos pero aún recuperable (es decir, `archived`). Los comentarios también pueden estar ocultos o visibles. Esto se podría representar utilizando una columna `status` en cada modelo.

Primero, ejecutemos las siguientes migraciones para agregar `status` a `Articles` y `Comments`:

```bash
$ bin/rails generate migration AddStatusToArticles status:string
$ bin/rails generate migration AddStatusToComments status:string
```

Y luego, actualicemos la base de datos con las migraciones generadas:

```bash
$ bin/rails db:migrate
```

Para elegir el estado de los artículos y comentarios existentes, puedes agregar un valor predeterminado a los archivos de migración generados agregando la opción `default: "public"` y luego ejecutar las migraciones nuevamente. También puedes llamar en la consola de Rails `Article.update_all(status: "public")` y `Comment.update_all(status: "public")`.

CONSEJO: Para obtener más información sobre las migraciones, consulta [Migraciones de Active Record](active_record_migrations.html).

También debemos permitir la clave `:status` como parte de los strong parameters en `app/controllers/articles_controller.rb`:

```ruby

  private
    def article_params
      params.require(:article).permit(:title, :body, :status)
    end
```

y en `app/controllers/comments_controller.rb`:

```ruby

  private
    def comment_params
      params.require(:comment).permit(:commenter, :body, :status)
    end
```

Dentro del modelo `article`, después de ejecutar una migración para agregar una columna `status` usando el comando `bin/rails db:migrate`, agregaríamos:

```ruby
class Article < ApplicationRecord
  has_many :comments

  validates :title, presence: true
  validates :body, presence: true, length: { minimum: 10 }

  VALID_STATUSES = ['public', 'private', 'archived']

  validates :status, inclusion: { in: VALID_STATUSES }

  def archived?
    status == 'archived'
  end
end
```

y en el modelo `Comment`:

```ruby
class Comment < ApplicationRecord
  belongs_to :article

  VALID_STATUSES = ['public', 'private', 'archived']

  validates :status, inclusion: { in: VALID_STATUSES }

  def archived?
    status == 'archived'
  end
end
```

Luego, en nuestra plantilla de la acción `index` (`app/views/articles/index.html.erb`), usaríamos el método `archived?` para evitar mostrar cualquier artículo que esté archivado:

```html+erb
<h1>Artículos</h1>

<ul>
  <% @articles.each do |article| %>
    <% unless article.archived? %>
      <li>
        <%= link_to article.title, article %>
      </li>
    <% end %>
  <% end %>
</ul>

<%= link_to "Nuevo Artículo", new_article_path %>
```

De manera similar, en nuestra vista parcial de comentarios (`app/views/comments/_comment.html.erb`), usaríamos el método `archived?` para evitar mostrar cualquier comentario que esté archivado:

```html+erb
<% unless comment.archived? %>
  <p>
    <strong>Comentarista:</strong>
    <%= comment.commenter %>
  </p>

  <p>
    <strong>Comentario:</strong>
    <%= comment.body %>
  </p>
<% end %>
```

Sin embargo, si observas nuevamente nuestros modelos ahora, verás que la lógica está duplicada. Si en el futuro aumentamos la funcionalidad de nuestro blog, por ejemplo, para incluir mensajes privados, podríamos encontrarnos duplicando la lógica nuevamente. Aquí es donde los concerns son útiles.

Un concern es responsable solo de un subconjunto enfocado de la responsabilidad del modelo; los métodos en nuestro concern estarán relacionados con la visibilidad de un modelo. Llamemos a nuestro nuevo concern (módulo) `Visible`. Podemos crear un nuevo archivo dentro de `app/models/concerns` llamado `visible.rb` y almacenar todos los métodos de estado que se duplicaron en los modelos.

`app/models/concerns/visible.rb`

```ruby
module Visible
  def archived?
    status == 'archived'
  end
end
```

Podemos agregar nuestra validación de estado al concern, pero esto es un poco más complejo ya que las validaciones son métodos llamados a nivel de clase. El `ActiveSupport::Concern` ([API Guide](https://api.rubyonrails.org/classes/ActiveSupport/Concern.html)) nos brinda una forma más sencilla de incluirlas:

```ruby
module Visible
  extend ActiveSupport::Concern

  VALID_STATUSES = ['public', 'private', 'archived']

  included do
    validates :status, inclusion: { in: VALID_STATUSES }
  end

  def archived?
    status == 'archived'
  end
end
```

Ahora, podemos eliminar la lógica duplicada de cada modelo e incluir nuestro nuevo módulo `Visible`:

En `app/models/article.rb`:

```ruby
class Article < ApplicationRecord
  include Visible

  has_many :comments

  validates :title, presence: true
  validates :body, presence: true, length: { minimum: 10 }
end
```

y en `app/models/comment.rb`:

```ruby
class Comment < ApplicationRecord
  include Visible

  belongs_to :article
end
```
Los métodos de clase también se pueden agregar a los concerns. Si queremos mostrar un recuento de artículos públicos o comentarios en nuestra página principal, podríamos agregar un método de clase a Visible de la siguiente manera:

```ruby
module Visible
  extend ActiveSupport::Concern

  VALID_STATUSES = ['public', 'private', 'archived']

  included do
    validates :status, inclusion: { in: VALID_STATUSES }
  end

  class_methods do
    def public_count
      where(status: 'public').count
    end
  end

  def archived?
    status == 'archived'
  end
end
```

Luego, en la vista, puedes llamarlo como cualquier método de clase:

```html+erb
<h1>Artículos</h1>

¡Nuestro blog tiene <%= Article.public_count %> artículos y contando!

<ul>
  <% @articles.each do |article| %>
    <% unless article.archived? %>
      <li>
        <%= link_to article.title, article %>
      </li>
    <% end %>
  <% end %>
</ul>

<%= link_to "Nuevo Artículo", new_article_path %>
```

Para terminar, agregaremos un cuadro de selección a los formularios y permitiremos al usuario seleccionar el estado al crear un nuevo artículo o publicar un nuevo comentario. También podemos especificar el estado predeterminado como `public`. En `app/views/articles/_form.html.erb`, podemos agregar:

```html+erb
<div>
  <%= form.label :status %><br>
  <%= form.select :status, ['public', 'private', 'archived'], selected: 'public' %>
</div>
```

y en `app/views/comments/_form.html.erb`:

```html+erb
<p>
  <%= form.label :status %><br>
  <%= form.select :status, ['public', 'private', 'archived'], selected: 'public' %>
</p>
```

Eliminación de comentarios
-----------------

Otra característica importante de un blog es poder eliminar comentarios no deseados. Para hacer esto, necesitamos implementar un enlace de algún tipo en la vista y una acción `destroy` en el `CommentsController`.

Entonces, primero, agreguemos el enlace de eliminación en el parcial `app/views/comments/_comment.html.erb`:

```html+erb
<% unless comment.archived? %>
  <p>
    <strong>Comentarista:</strong>
    <%= comment.commenter %>
  </p>

  <p>
    <strong>Comentario:</strong>
    <%= comment.body %>
  </p>

  <p>
    <%= link_to "Eliminar Comentario", [comment.article, comment], data: {
                  turbo_method: :delete,
                  turbo_confirm: "¿Estás seguro?"
                } %>
  </p>
<% end %>
```

Al hacer clic en este nuevo enlace "Eliminar Comentario", se enviará un `DELETE /articles/:article_id/comments/:id` a nuestro `CommentsController`, que luego puede usar esto para encontrar el comentario que queremos eliminar, así que agreguemos una acción `destroy` a nuestro controlador (`app/controllers/comments_controller.rb`):

```ruby
class CommentsController < ApplicationController
  def create
    @article = Article.find(params[:article_id])
    @comment = @article.comments.create(comment_params)
    redirect_to article_path(@article)
  end

  def destroy
    @article = Article.find(params[:article_id])
    @comment = @article.comments.find(params[:id])
    @comment.destroy
    redirect_to article_path(@article), status: :see_other
  end

  private
    def comment_params
      params.require(:comment).permit(:commenter, :body, :status)
    end
end
```

La acción `destroy` encontrará el artículo que estamos viendo, localizará el comentario dentro de la colección `@article.comments` y luego lo eliminará de la base de datos y nos enviará de vuelta a la acción `show` del artículo.

### Eliminación de objetos asociados

Si eliminas un artículo, sus comentarios asociados también deben eliminarse, de lo contrario, simplemente ocuparían espacio en la base de datos. Rails te permite usar la opción `dependent` de una asociación para lograr esto. Modifica el modelo Article, `app/models/article.rb`, de la siguiente manera:

```ruby
class Article < ApplicationRecord
  include Visible

  has_many :comments, dependent: :destroy

  validates :title, presence: true
  validates :body, presence: true, length: { minimum: 10 }
end
```

Seguridad
--------

### Autenticación básica

Si publicaras tu blog en línea, cualquier persona podría agregar, editar y eliminar artículos o eliminar comentarios.

Rails proporciona un sistema de autenticación HTTP que funcionará bien en esta situación.

En el `ArticlesController` necesitamos tener una forma de bloquear el acceso a las diversas acciones si la persona no está autenticada. Aquí podemos usar el método `http_basic_authenticate_with` de Rails, que permite el acceso a la acción solicitada si ese método lo permite.

Para usar el sistema de autenticación, lo especificamos en la parte superior de nuestro `ArticlesController` en `app/controllers/articles_controller.rb`. En nuestro caso, queremos que el usuario esté autenticado en cada acción excepto `index` y `show`, así que escribimos eso:

```ruby
class ArticlesController < ApplicationController

  http_basic_authenticate_with name: "dhh", password: "secret", except: [:index, :show]

  def index
    @articles = Article.all
  end

  # fragmento por brevedad
```

También queremos permitir solo a usuarios autenticados eliminar comentarios, así que en el `CommentsController` (`app/controllers/comments_controller.rb`) escribimos:

```ruby
class CommentsController < ApplicationController

  http_basic_authenticate_with name: "dhh", password: "secret", only: :destroy

  def create
    @article = Article.find(params[:article_id])
    # ...
  end

  # fragmento por brevedad
```

Ahora, si intentas crear un nuevo artículo, te encontrarás con un desafío básico de autenticación HTTP:

![Desafío básico de autenticación HTTP](images/getting_started/challenge.png)

Después de ingresar el nombre de usuario y la contraseña correctos, permanecerás autenticado hasta que se requiera un nombre de usuario y contraseña diferentes o se cierre el navegador.
Hay otros métodos de autenticación disponibles para las aplicaciones de Rails. Dos complementos populares de autenticación para Rails son el motor de Rails [Devise](https://github.com/plataformatec/devise) y la gema [Authlogic](https://github.com/binarylogic/authlogic), junto con otros más.

### Otras consideraciones de seguridad

La seguridad, especialmente en aplicaciones web, es un área amplia y detallada. La seguridad en tu aplicación de Rails se cubre con más detalle en la [Guía de seguridad de Ruby on Rails](security.html).

¿Qué sigue?
------------

Ahora que has visto tu primera aplicación de Rails, siéntete libre de actualizarla y experimentar por tu cuenta.

Recuerda, no tienes que hacer todo sin ayuda. Si necesitas asistencia para comenzar y trabajar con Rails, no dudes en consultar estos recursos de soporte:

* Las [Guías de Ruby on Rails](index.html)
* La [lista de correo de Ruby on Rails](https://discuss.rubyonrails.org/c/rubyonrails-talk)

Problemas de configuración a tener en cuenta
--------------------------------------------

La forma más fácil de trabajar con Rails es almacenar todos los datos externos como UTF-8. Si no lo haces, las bibliotecas de Ruby y Rails a menudo podrán convertir tus datos nativos en UTF-8, pero esto no siempre funciona de manera confiable, por lo que es mejor asegurarse de que todos los datos externos sean UTF-8.

Si has cometido un error en esta área, el síntoma más común es un diamante negro con un signo de interrogación en el interior que aparece en el navegador. Otro síntoma común es que aparezcan caracteres como "Ã¼" en lugar de "ü". Rails toma una serie de medidas internas para mitigar las causas comunes de estos problemas que se pueden detectar y corregir automáticamente. Sin embargo, si tienes datos externos que no se almacenan como UTF-8, ocasionalmente puede resultar en este tipo de problemas que Rails no puede detectar y corregir automáticamente.

Dos fuentes muy comunes de datos que no son UTF-8:

* Tu editor de texto: la mayoría de los editores de texto (como TextMate) se guardan de forma predeterminada como UTF-8. Si tu editor de texto no lo hace, esto puede hacer que los caracteres especiales que ingreses en tus plantillas (como é) aparezcan como un diamante con un signo de interrogación en el navegador. Esto también se aplica a tus archivos de traducción i18n. La mayoría de los editores que no tienen UTF-8 como predeterminado (como algunas versiones de Dreamweaver) ofrecen una forma de cambiar la configuración predeterminada a UTF-8. Hazlo.
* Tu base de datos: Rails convierte de forma predeterminada los datos de tu base de datos a UTF-8 en el límite. Sin embargo, si tu base de datos no utiliza UTF-8 internamente, es posible que no pueda almacenar todos los caracteres que ingresan tus usuarios. Por ejemplo, si tu base de datos utiliza Latin-1 internamente y un usuario ingresa un carácter ruso, hebreo o japonés, los datos se perderán para siempre una vez que ingresen a la base de datos. Si es posible, utiliza UTF-8 como almacenamiento interno de tu base de datos.
