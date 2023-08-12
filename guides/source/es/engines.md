**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 2aedcd7fcf6f0b83538e8a8220d38afd
Introducción a los motores
============================

En esta guía aprenderás sobre los motores y cómo se pueden utilizar para proporcionar funcionalidad adicional a las aplicaciones anfitrionas a través de una interfaz limpia y muy fácil de usar.

Después de leer esta guía, sabrás:

* Qué hace un motor.
* Cómo generar un motor.
* Cómo construir características para el motor.
* Cómo conectar el motor a una aplicación.
* Cómo anular la funcionalidad del motor en la aplicación.
* Cómo evitar cargar los frameworks de Rails con Load and Configuration Hooks.

--------------------------------------------------------------------------------

¿Qué son los motores?
-----------------

Los motores pueden considerarse aplicaciones en miniatura que proporcionan funcionalidad a sus aplicaciones anfitrionas. Una aplicación de Rails es en realidad solo un motor "potenciado", con la clase `Rails::Application` heredando gran parte de su comportamiento de `Rails::Engine`.

Por lo tanto, los motores y las aplicaciones pueden considerarse casi lo mismo, solo con diferencias sutiles, como verás a lo largo de esta guía. Los motores y las aplicaciones también comparten una estructura común.

Los motores también están estrechamente relacionados con los complementos. Ambos comparten una estructura de directorios común en `lib` y se generan utilizando el generador `rails plugin new`. La diferencia es que un motor es considerado un "complemento completo" por Rails (como se indica por la opción `--full` que se pasa al comando del generador). En esta guía, en realidad estaremos utilizando la opción `--mountable`, que incluye todas las características de `--full`, y algunas más. Esta guía se referirá a estos "complementos completos" simplemente como "motores". Un motor **puede** ser un complemento, y un complemento **puede** ser un motor.

El motor que se creará en esta guía se llamará "blorgh". Este motor proporcionará funcionalidad de blogs a sus aplicaciones anfitrionas, permitiendo la creación de nuevos artículos y comentarios. Al principio de esta guía, trabajarás únicamente dentro del motor mismo, pero en las secciones posteriores verás cómo conectarlo a una aplicación.

Los motores también pueden estar aislados de sus aplicaciones anfitrionas. Esto significa que una aplicación puede tener una ruta proporcionada por un ayudante de enrutamiento como `articles_path` y utilizar un motor que también proporciona una ruta llamada `articles_path`, y los dos no entrarían en conflicto. Además de esto, los controladores, modelos y nombres de tablas también están en espacios de nombres. Verás cómo hacer esto más adelante en esta guía.

Es importante tener en cuenta en todo momento que la aplicación siempre debe tener prioridad sobre sus motores. Una aplicación es el objeto que tiene la última palabra en lo que sucede en su entorno. El motor solo debería mejorarla, en lugar de cambiarla drásticamente.

Para ver demostraciones de otros motores, echa un vistazo a [Devise](https://github.com/plataformatec/devise), un motor que proporciona autenticación para sus aplicaciones principales, o [Thredded](https://github.com/thredded/thredded), un motor que proporciona funcionalidad de foro. También está [Spree](https://github.com/spree/spree), que proporciona una plataforma de comercio electrónico, y [Refinery CMS](https://github.com/refinery/refinerycms), un motor de CMS.

Finalmente, los motores no habrían sido posibles sin el trabajo de James Adam, Piotr Sarnacki, el equipo principal de Rails y muchas otras personas. Si alguna vez los conoces, ¡no olvides darles las gracias!

Generando un motor
--------------------

Para generar un motor, deberás ejecutar el generador de complementos y pasarle las opciones adecuadas según sea necesario. Para el ejemplo de "blorgh", deberás crear un motor "montable", ejecutando este comando en una terminal:

```bash
$ rails plugin new blorgh --mountable
```

La lista completa de opciones para el generador de complementos se puede ver escribiendo:

```bash
$ rails plugin --help
```

La opción `--mountable` le indica al generador que deseas crear un motor "montable" y aislado en un espacio de nombres. Este generador proporcionará la misma estructura esqueleto que la opción `--full`. La opción `--full` le indica al generador que deseas crear un motor, incluyendo una estructura esqueleto que proporciona lo siguiente:

  * Un árbol de directorios `app`
  * Un archivo `config/routes.rb`:

    ```ruby
    Rails.application.routes.draw do
    end
    ```

  * Un archivo en `lib/blorgh/engine.rb`, que es idéntico en función al archivo `config/application.rb` de una aplicación Rails estándar:

    ```ruby
    module Blorgh
      class Engine < ::Rails::Engine
      end
    end
    ```

La opción `--mountable` agregará a la opción `--full`:

  * Archivos de manifiesto de activos (`blorgh_manifest.js` y `application.css`)
  * Un esqueleto de `ApplicationController` en un espacio de nombres
  * Un esqueleto de `ApplicationHelper` en un espacio de nombres
  * Una plantilla de vista de diseño para el motor
  * Aislamiento de espacio de nombres en `config/routes.rb`:
```ruby
Blorgh::Engine.routes.draw do
end
```

* Aislamiento de espacio de nombres en `lib/blorgh/engine.rb`:

```ruby
module Blorgh
  class Engine < ::Rails::Engine
    isolate_namespace Blorgh
  end
end
```

Además, la opción `--mountable` le indica al generador que monte el motor dentro de la aplicación de prueba dummy ubicada en `test/dummy` agregando lo siguiente al archivo de rutas de la aplicación dummy en `test/dummy/config/routes.rb`:

```ruby
mount Blorgh::Engine => "/blorgh"
```

### Dentro de un motor

#### Archivos críticos

En la raíz del directorio de este nuevo motor se encuentra un archivo `blorgh.gemspec`. Cuando incluyas el motor en una aplicación más adelante, lo harás con esta línea en el archivo `Gemfile` de la aplicación Rails:

```ruby
gem 'blorgh', path: 'engines/blorgh'
```

No olvides ejecutar `bundle install` como de costumbre. Al especificarlo como una gema dentro del `Gemfile`, Bundler lo cargará como tal, analizando este archivo `blorgh.gemspec` y requiriendo un archivo dentro del directorio `lib` llamado `lib/blorgh.rb`. Este archivo requiere el archivo `blorgh/engine.rb` (ubicado en `lib/blorgh/engine.rb`) y define un módulo base llamado `Blorgh`.

```ruby
require "blorgh/engine"

module Blorgh
end
```

CONSEJO: Algunos motores eligen usar este archivo para colocar opciones de configuración global para su motor. Es una idea relativamente buena, por lo que si quieres ofrecer opciones de configuración, el archivo donde se define el `module` de tu motor es perfecto para eso. Coloca los métodos dentro del módulo y estarás listo para continuar.

Dentro de `lib/blorgh/engine.rb` se encuentra la clase base para el motor:

```ruby
module Blorgh
  class Engine < ::Rails::Engine
    isolate_namespace Blorgh
  end
end
```

Al heredar de la clase `Rails::Engine`, esta gema notifica a Rails que hay un motor en la ruta especificada y montará correctamente el motor dentro de la aplicación, realizando tareas como agregar el directorio `app` del motor a la ruta de carga para modelos, mailers, controladores y vistas.

El método `isolate_namespace` merece una mención especial aquí. Esta llamada es responsable de aislar los controladores, modelos, rutas y otras cosas en su propio espacio de nombres, lejos de los componentes similares dentro de la aplicación. Sin esto, existe la posibilidad de que los componentes del motor puedan "filtrarse" en la aplicación, causando interrupciones no deseadas, o que los componentes importantes del motor puedan ser anulados por cosas con nombres similares dentro de la aplicación. Uno de los ejemplos de tales conflictos son los helpers. Sin llamar a `isolate_namespace`, los helpers del motor se incluirían en los controladores de una aplicación.

NOTA: Se recomienda **encarecidamente** dejar la línea `isolate_namespace` dentro de la definición de la clase `Engine`. Sin ella, las clases generadas en un motor **pueden** entrar en conflicto con una aplicación.

Lo que significa este aislamiento del espacio de nombres es que un modelo generado por una llamada a `bin/rails generate model`, como `bin/rails generate model article`, no se llamará `Article`, sino que se llamará `Blorgh::Article`. Además, la tabla para el modelo se pondrá en un espacio de nombres, convirtiéndose en `blorgh_articles`, en lugar de simplemente `articles`. Similar al espacio de nombres del modelo, un controlador llamado `ArticlesController` se convierte en `Blorgh::ArticlesController` y las vistas para ese controlador no estarán en `app/views/articles`, sino en `app/views/blorgh/articles`. Los mailers, jobs y helpers también se ponen en un espacio de nombres.

Finalmente, las rutas también se aislarán dentro del motor. Esta es una de las partes más importantes del espacio de nombres y se discute más adelante en la sección de [Rutas](#routes) de esta guía.

#### Directorio `app`

Dentro del directorio `app` se encuentran los directorios estándar `assets`, `controllers`, `helpers`, `jobs`, `mailers`, `models` y `views` con los que deberías estar familiarizado en una aplicación. Miraremos más en detalle los modelos en una sección futura, cuando estemos escribiendo el motor.

Dentro del directorio `app/assets`, hay los directorios `images` y `stylesheets` que, nuevamente, deberías conocer debido a su similitud con una aplicación. Sin embargo, una diferencia aquí es que cada directorio contiene un subdirectorio con el nombre del motor. Debido a que este motor va a tener un espacio de nombres, sus activos también deberían tenerlo.

Dentro del directorio `app/controllers` hay un directorio `blorgh` que contiene un archivo llamado `application_controller.rb`. Este archivo proporcionará cualquier funcionalidad común para los controladores del motor. El directorio `blorgh` es donde irán los otros controladores del motor. Al colocarlos dentro de este directorio con espacio de nombres, evitas que puedan entrar en conflicto con controladores de nombres idénticos dentro de otros motores o incluso dentro de la aplicación.

NOTA: La clase `ApplicationController` dentro de un motor se llama igual que una aplicación Rails para facilitar la conversión de aplicaciones en motores.
NOTA: Si la aplicación principal se ejecuta en modo `classic`, es posible que te encuentres en una situación en la que el controlador del motor herede del controlador de la aplicación principal y no del controlador de la aplicación del motor. La mejor manera de evitar esto es cambiar al modo `zeitwerk` en la aplicación principal. De lo contrario, utiliza `require_dependency` para asegurarte de que se cargue el controlador de la aplicación del motor. Por ejemplo:

```ruby
# SOLO NECESARIO EN MODO `classic`.
require_dependency "blorgh/application_controller"

module Blorgh
  class ArticlesController < ApplicationController
    # ...
  end
end
```

ADVERTENCIA: No uses `require` porque romperá la recarga automática de clases en el entorno de desarrollo; usar `require_dependency` asegura que las clases se carguen y descarguen de manera correcta.

Al igual que para `app/controllers`, encontrarás un subdirectorio `blorgh` en los directorios `app/helpers`, `app/jobs`, `app/mailers` y `app/models` que contiene el archivo `application_*.rb` asociado para recopilar funcionalidades comunes. Al colocar tus archivos en este subdirectorio y darles un espacio de nombres, evitas que puedan entrar en conflicto con elementos de nombre idéntico en otros motores o incluso en la aplicación.

Por último, el directorio `app/views` contiene una carpeta `layouts`, que contiene un archivo en `blorgh/application.html.erb`. Este archivo te permite especificar un diseño para el motor. Si este motor se va a utilizar como un motor independiente, agregarías cualquier personalización a su diseño en este archivo, en lugar del archivo `app/views/layouts/application.html.erb` de la aplicación.

Si no quieres imponer un diseño a los usuarios del motor, puedes eliminar este archivo y hacer referencia a un diseño diferente en los controladores de tu motor.

#### Directorio `bin`

Este directorio contiene un archivo, `bin/rails`, que te permite utilizar los subcomandos y generadores de `rails` como lo harías en una aplicación. Esto significa que podrás generar nuevos controladores y modelos para este motor de manera muy fácil ejecutando comandos como este:

```bash
$ bin/rails generate model
```

Ten en cuenta, por supuesto, que cualquier cosa generada con estos comandos dentro de un motor que tenga `isolate_namespace` en la clase `Engine` estará en un espacio de nombres.

#### Directorio `test`

El directorio `test` es donde se colocarán las pruebas para el motor. Para probar el motor, hay una versión reducida de una aplicación de Rails incrustada en él en `test/dummy`. Esta aplicación montará el motor en el archivo `test/dummy/config/routes.rb`:

```ruby
Rails.application.routes.draw do
  mount Blorgh::Engine => "/blorgh"
end
```

Esta línea monta el motor en la ruta `/blorgh`, lo que lo hará accesible a través de la aplicación solo en esa ruta.

Dentro del directorio de pruebas también se encuentra el directorio `test/integration`, donde se deben colocar las pruebas de integración para el motor. También se pueden crear otros directorios en el directorio `test`. Por ejemplo, es posible que desees crear un directorio `test/models` para las pruebas de tus modelos.

Proporcionar funcionalidad del motor
------------------------------------

El motor que cubre esta guía proporciona funcionalidad para enviar artículos y comentar, y sigue un hilo similar a la [Guía de introducción](getting_started.html), con algunas novedades.

NOTA: Para esta sección, asegúrate de ejecutar los comandos en la raíz del directorio del motor `blorgh`.

### Generar un recurso de artículo

Lo primero que se debe generar para un motor de blog es el modelo `Article` y el controlador relacionado. Para generar esto rápidamente, puedes usar el generador de andamios de Rails.

```bash
$ bin/rails generate scaffold article title:string text:text
```

Este comando mostrará esta información:

```
invoke  active_record
create    db/migrate/[timestamp]_create_blorgh_articles.rb
create    app/models/blorgh/article.rb
invoke    test_unit
create      test/models/blorgh/article_test.rb
create      test/fixtures/blorgh/articles.yml
invoke  resource_route
 route    resources :articles
invoke  scaffold_controller
create    app/controllers/blorgh/articles_controller.rb
invoke    erb
create      app/views/blorgh/articles
create      app/views/blorgh/articles/index.html.erb
create      app/views/blorgh/articles/edit.html.erb
create      app/views/blorgh/articles/show.html.erb
create      app/views/blorgh/articles/new.html.erb
create      app/views/blorgh/articles/_form.html.erb
invoke    test_unit
create      test/controllers/blorgh/articles_controller_test.rb
create      test/system/blorgh/articles_test.rb
invoke    helper
create      app/helpers/blorgh/articles_helper.rb
invoke      test_unit
```

Lo primero que hace el generador de andamios es invocar al generador `active_record`, que genera una migración y un modelo para el recurso. Sin embargo, ten en cuenta que la migración se llama `create_blorgh_articles` en lugar de la habitual `create_articles`. Esto se debe al método `isolate_namespace` llamado en la definición de la clase `Blorgh::Engine`. El modelo aquí también tiene un espacio de nombres, ya que se coloca en `app/models/blorgh/article.rb` en lugar de `app/models/article.rb`, debido a la llamada a `isolate_namespace` dentro de la clase `Engine`.

A continuación, se invoca el generador `test_unit` para este modelo, generando una prueba de modelo en `test/models/blorgh/article_test.rb` (en lugar de `test/models/article_test.rb`) y un fixture en `test/fixtures/blorgh/articles.yml` (en lugar de `test/fixtures/articles.yml`).

Después de eso, se inserta una línea para el recurso en el archivo `config/routes.rb` del motor. Esta línea es simplemente `resources :articles`, convirtiendo el archivo `config/routes.rb` del motor en esto:
```ruby
Blorgh::Engine.routes.draw do
  resources :articles
end
```

Tenga en cuenta que las rutas se dibujan en el objeto `Blorgh::Engine` en lugar de
la clase `YourApp::Application`. Esto se hace para que las rutas del motor estén confinadas
al propio motor y se puedan montar en un punto específico como se muestra en la
sección [directorio de pruebas](#directorio-de-pruebas). También hace que las rutas del motor
estén aisladas de aquellas rutas que están dentro de la aplicación. La sección
[Rutas](#rutas) de esta guía lo describe en detalle.

A continuación, se invoca el generador `scaffold_controller`, que genera un controlador
llamado `Blorgh::ArticlesController` (en
`app/controllers/blorgh/articles_controller.rb`) y sus vistas relacionadas en
`app/views/blorgh/articles`. Este generador también genera pruebas para el
controlador (`test/controllers/blorgh/articles_controller_test.rb` y `test/system/blorgh/articles_test.rb`) y un ayudante (`app/helpers/blorgh/articles_helper.rb`).

Todo lo que ha creado este generador está perfectamente enmarcado. La clase del controlador
se define dentro del módulo `Blorgh`:

```ruby
module Blorgh
  class ArticlesController < ApplicationController
    # ...
  end
end
```

NOTA: La clase `ArticlesController` hereda de
`Blorgh::ApplicationController`, no del `ApplicationController` de la aplicación.

El ayudante dentro de `app/helpers/blorgh/articles_helper.rb` también está enmarcado:

```ruby
module Blorgh
  module ArticlesHelper
    # ...
  end
end
```

Esto ayuda a evitar conflictos con cualquier otro motor o aplicación que también pueda tener
un recurso de artículo.

Puede ver lo que el motor tiene hasta ahora ejecutando `bin/rails db:migrate` en la raíz
de nuestro motor para ejecutar la migración generada por el generador de andamios, y luego
ejecutando `bin/rails server` en `test/dummy`. Cuando abra
`http://localhost:3000/blorgh/articles` verá el andamio predeterminado que se ha
generado. ¡Haz clic! Acabas de generar las primeras funciones de tu primer motor.

Si prefieres jugar en la consola, `bin/rails console` también funcionará como
una aplicación de Rails. Recuerda: el modelo `Article` está enmarcado, así que para
referenciarlo debes llamarlo como `Blorgh::Article`.

```irb
irb> Blorgh::Article.find(1)
=> #<Blorgh::Article id: 1 ...>
```

Una cosa final es que el recurso `articles` de este motor debería ser la raíz
del motor. Cuando alguien va a la ruta raíz donde se monta el motor,
debería mostrarse una lista de artículos. Esto se puede lograr si
esta línea se inserta en el archivo `config/routes.rb` dentro del motor:

```ruby
root to: "articles#index"
```

Ahora las personas solo necesitarán ir a la raíz del motor para ver todos los artículos,
en lugar de visitar `/articles`. Esto significa que en lugar de
`http://localhost:3000/blorgh/articles`, ahora solo necesitas ir a
`http://localhost:3000/blorgh`.

### Generando un recurso de comentarios

Ahora que el motor puede crear nuevos artículos, tiene sentido agregar
funcionalidad de comentarios también. Para hacer esto, deberás generar un modelo de comentario,
un controlador de comentarios y luego modificar el andamio de artículos para mostrar
comentarios y permitir a las personas crear nuevos comentarios.

Desde la raíz del motor, ejecuta el generador de modelos. Indícale que genere un
modelo `Comment`, con la tabla relacionada que tiene dos columnas: un entero `article_id`
y una columna de texto `text`.

```bash
$ bin/rails generate model Comment article_id:integer text:text
```

Esto mostrará lo siguiente:

```
invoke  active_record
create    db/migrate/[timestamp]_create_blorgh_comments.rb
create    app/models/blorgh/comment.rb
invoke    test_unit
create      test/models/blorgh/comment_test.rb
create      test/fixtures/blorgh/comments.yml
```

Esta llamada al generador generará solo los archivos de modelo necesarios,
enmarcando los archivos en un directorio `blorgh` y creando una clase de modelo
llamada `Blorgh::Comment`. Ahora ejecuta la migración para crear nuestra tabla de blorgh_comments:

```bash
$ bin/rails db:migrate
```

Para mostrar los comentarios en un artículo, edita `app/views/blorgh/articles/show.html.erb` y
agrega esta línea antes del enlace "Editar":

```html+erb
<h3>Comentarios</h3>
<%= render @article.comments %>
```

Esta línea requerirá que haya una asociación `has_many` para comentarios definida
en el modelo `Blorgh::Article`, que no existe en este momento. Para definir una, abre
`app/models/blorgh/article.rb` y agrega esta línea al modelo:

```ruby
has_many :comments
```

El modelo quedará así:

```ruby
module Blorgh
  class Article < ApplicationRecord
    has_many :comments
  end
end
```

NOTA: Como `has_many` se define dentro de una clase que está dentro del
módulo `Blorgh`, Rails sabrá que quieres usar el modelo `Blorgh::Comment`
para estos objetos, por lo que no es necesario especificarlo usando la
opción `:class_name` aquí.

A continuación, debe haber un formulario para que se puedan crear comentarios en un artículo. Para
agregar esto, coloca esta línea debajo de la llamada a `render @article.comments` en
`app/views/blorgh/articles/show.html.erb`:

```erb
<%= render "blorgh/comments/form" %>
```

A continuación, el parcial que esta línea renderizará debe existir. Crea un nuevo
directorio en `app/views/blorgh/comments` y dentro de él un nuevo archivo llamado
`_form.html.erb` que tenga este contenido para crear el parcial requerido:
```html+erb
<h3>Nuevo comentario</h3>
<%= form_with model: [@article, @article.comments.build] do |form| %>
  <p>
    <%= form.label :text %><br>
    <%= form.text_area :text %>
  </p>
  <%= form.submit %>
<% end %>
```

Cuando se envía este formulario, intentará realizar una solicitud `POST` a una ruta de `/articles/:article_id/comments` dentro del motor. Esta ruta no existe en este momento, pero se puede crear cambiando la línea `resources :articles` dentro de `config/routes.rb` por estas líneas:

```ruby
resources :articles do
  resources :comments
end
```

Esto crea una ruta anidada para los comentarios, que es lo que requiere el formulario.

Ahora la ruta existe, pero el controlador al que va esta ruta no existe. Para crearlo, ejecute el siguiente comando desde la raíz del motor:

```bash
$ bin/rails generate controller comments
```

Esto generará las siguientes cosas:

```
create  app/controllers/blorgh/comments_controller.rb
invoke  erb
 exist    app/views/blorgh/comments
invoke  test_unit
create    test/controllers/blorgh/comments_controller_test.rb
invoke  helper
create    app/helpers/blorgh/comments_helper.rb
invoke    test_unit
```

El formulario realizará una solicitud `POST` a `/articles/:article_id/comments`, que corresponderá con la acción `create` en `Blorgh::CommentsController`. Esta acción debe ser creada, lo cual se puede hacer colocando las siguientes líneas dentro de la definición de clase en `app/controllers/blorgh/comments_controller.rb`:

```ruby
def create
  @article = Article.find(params[:article_id])
  @comment = @article.comments.create(comment_params)
  flash[:notice] = "¡El comentario ha sido creado!"
  redirect_to articles_path
end

private
  def comment_params
    params.require(:comment).permit(:text)
  end
```

Este es el último paso necesario para que el formulario de nuevo comentario funcione. Sin embargo, la visualización de los comentarios aún no es del todo correcta. Si creara un comentario en este momento, vería este error:

```
Falta la vista parcial blorgh/comments/_comment con {:handlers=>[:erb, :builder],
:formats=>[:html], :locale=>[:en, :en]}. Buscado en:   *
"/Users/ryan/Sites/side_projects/blorgh/test/dummy/app/views"   *
"/Users/ryan/Sites/side_projects/blorgh/app/views"
```

El motor no puede encontrar la vista parcial requerida para renderizar los comentarios. Rails busca primero en el directorio `app/views` de la aplicación (`test/dummy`) y luego en el directorio `app/views` del motor. Cuando no puede encontrarlo, arrojará este error. El motor sabe que debe buscar `blorgh/comments/_comment` porque el objeto del modelo que recibe es de la clase `Blorgh::Comment`.

Esta vista parcial será responsable de renderizar solo el texto del comentario, por ahora. Cree un nuevo archivo en `app/views/blorgh/comments/_comment.html.erb` y coloque esta línea dentro de él:

```erb
<%= comment_counter + 1 %>. <%= comment.text %>
```

La variable local `comment_counter` nos la proporciona la llamada `<%= render @article.comments %>`, que la definirá automáticamente e incrementará el contador a medida que itera a través de cada comentario. Se utiliza en este ejemplo para mostrar un pequeño número junto a cada comentario cuando se crea.

Esto completa la función de comentarios del motor de blogs. Ahora es el momento de usarlo dentro de una aplicación.

Integración en una aplicación
----------------------------

Usar un motor dentro de una aplicación es muy fácil. Esta sección cubre cómo montar el motor en una aplicación y la configuración inicial requerida, así como vincular el motor a una clase `User` proporcionada por la aplicación para proporcionar propiedad de los artículos y comentarios dentro del motor.

### Montar el motor

Primero, el motor debe especificarse dentro del `Gemfile` de la aplicación. Si no hay una aplicación disponible para probar esto, genere una usando el comando `rails new` fuera del directorio del motor de esta manera:

```bash
$ rails new unicorn
```

Por lo general, especificar el motor dentro del `Gemfile` se haría especificándolo como una gema normal y corriente.

```ruby
gem 'devise'
```

Sin embargo, debido a que estás desarrollando el motor `blorgh` en tu máquina local, deberás especificar la opción `:path` en tu `Gemfile`:

```ruby
gem 'blorgh', path: 'engines/blorgh'
```

Luego ejecuta `bundle` para instalar la gema.

Como se describió anteriormente, al colocar la gema en el `Gemfile`, se cargará cuando se cargue Rails. Primero requerirá `lib/blorgh.rb` del motor, luego `lib/blorgh/engine.rb`, que es el archivo que define las principales funcionalidades del motor.

Para que la funcionalidad del motor sea accesible desde una aplicación, debe montarse en el archivo `config/routes.rb` de esa aplicación:

```ruby
mount Blorgh::Engine, at: "/blog"
```

Esta línea montará el motor en `/blog` en la aplicación. Haciéndolo accesible en `http://localhost:3000/blog` cuando la aplicación se ejecute con `bin/rails server`.

NOTA: Otros motores, como Devise, manejan esto de manera un poco diferente al hacer que especifiques helpers personalizados (como `devise_for`) en las rutas. Estos helpers hacen exactamente lo mismo, montando partes de la funcionalidad del motor en una ruta predefinida que puede ser personalizable.
### Configuración del motor

El motor contiene migraciones para las tablas `blorgh_articles` y `blorgh_comments` que deben crearse en la base de datos de la aplicación para que los modelos del motor puedan consultarlas correctamente. Para copiar estas migraciones en la aplicación, ejecute el siguiente comando desde la raíz de la aplicación:

```bash
$ bin/rails blorgh:install:migrations
```

Si tiene varios motores que necesitan migraciones copiadas, use `railties:install:migrations` en su lugar:

```bash
$ bin/rails railties:install:migrations
```

Puede especificar una ruta personalizada en el motor de origen para las migraciones especificando MIGRATIONS_PATH.

```bash
$ bin/rails railties:install:migrations MIGRATIONS_PATH=db_blourgh
```

Si tiene varias bases de datos, también puede especificar la base de datos de destino especificando DATABASE.

```bash
$ bin/rails railties:install:migrations DATABASE=animals
```

Este comando, cuando se ejecuta por primera vez, copiará todas las migraciones del motor. Cuando se ejecuta la próxima vez, solo copiará las migraciones que aún no se hayan copiado. La primera ejecución de este comando mostrará algo como esto:

```
Copied migration [timestamp_1]_create_blorgh_articles.blorgh.rb from blorgh
Copied migration [timestamp_2]_create_blorgh_comments.blorgh.rb from blorgh
```

El primer timestamp (`[timestamp_1]`) será la hora actual, y el segundo timestamp (`[timestamp_2]`) será la hora actual más un segundo. La razón de esto es para que las migraciones del motor se ejecuten después de cualquier migración existente en la aplicación.

Para ejecutar estas migraciones dentro del contexto de la aplicación, simplemente ejecute `bin/rails db:migrate`. Al acceder al motor a través de `http://localhost:3000/blog`, los artículos estarán vacíos. Esto se debe a que la tabla creada dentro de la aplicación es diferente de la creada dentro del motor. Adelante, juegue con el motor recién montado. Verá que es igual que cuando solo era un motor.

Si desea ejecutar migraciones solo desde un motor, puede hacerlo especificando `SCOPE`:

```bash
$ bin/rails db:migrate SCOPE=blorgh
```

Esto puede ser útil si desea revertir las migraciones del motor antes de eliminarlo. Para revertir todas las migraciones del motor blorgh, puede ejecutar un código como este:

```bash
$ bin/rails db:migrate SCOPE=blorgh VERSION=0
```

### Uso de una clase proporcionada por la aplicación

#### Uso de un modelo proporcionado por la aplicación

Cuando se crea un motor, es posible que desee utilizar clases específicas de una aplicación para establecer vínculos entre las partes del motor y las partes de la aplicación. En el caso del motor `blorgh`, tendría mucho sentido que los artículos y los comentarios tuvieran autores.

Una aplicación típica podría tener una clase `User` que se utilizaría para representar autores de un artículo o un comentario. Pero podría haber un caso en el que la aplicación llame a esta clase de manera diferente, como `Person`. Por esta razón, el motor no debe codificar asociaciones específicamente para una clase `User`.

Para mantenerlo simple en este caso, la aplicación tendrá una clase llamada `User` que representa a los usuarios de la aplicación (entraremos en cómo hacer esto configurable más adelante). Puede generarse utilizando este comando dentro de la aplicación:

```bash
$ bin/rails generate model user name:string
```

El comando `bin/rails db:migrate` debe ejecutarse aquí para asegurarse de que nuestra aplicación tenga la tabla `users` para su uso futuro.

Además, para mantenerlo simple, el formulario de los artículos tendrá un nuevo campo de texto llamado `author_name`, donde los usuarios pueden elegir poner su nombre. Luego, el motor tomará este nombre y creará un nuevo objeto `User` a partir de él, o encontrará uno que ya tenga ese nombre. Luego, el motor asociará el artículo con el objeto `User` encontrado o creado.

Primero, el campo de texto `author_name` debe agregarse al parcial `app/views/blorgh/articles/_form.html.erb` dentro del motor. Esto se puede agregar encima del campo `title` con este código:

```html+erb
<div class="field">
  <%= form.label :author_name %><br>
  <%= form.text_field :author_name %>
</div>
```

A continuación, debemos actualizar nuestro método `Blorgh::ArticlesController#article_params` para permitir el nuevo parámetro del formulario:

```ruby
def article_params
  params.require(:article).permit(:title, :text, :author_name)
end
```

El modelo `Blorgh::Article` debe tener algún código para convertir el campo `author_name` en un objeto `User` real y asociarlo como el `author` de ese artículo antes de que se guarde el artículo. También deberá tener un `attr_accessor` configurado para este campo, para que se definan los métodos setter y getter para él.

Para hacer todo esto, deberá agregar el `attr_accessor` para `author_name`, la asociación para el autor y la llamada `before_validation` en `app/models/blorgh/article.rb`. La asociación `author` se codificará para la clase `User` por el momento.
```ruby
attr_accessor :author_name
belongs_to :author, class_name: "User"

before_validation :set_author

private
  def set_author
    self.author = User.find_or_create_by(name: author_name)
  end
```

Al representar el objeto de la asociación `author` con la clase `User`, se establece un vínculo entre el motor y la aplicación. Debe haber una forma de asociar los registros en la tabla `blorgh_articles` con los registros en la tabla `users`. Debido a que la asociación se llama `author`, se debe agregar una columna `author_id` a la tabla `blorgh_articles`.

Para generar esta nueva columna, ejecute el siguiente comando dentro del motor:

```bash
$ bin/rails generate migration add_author_id_to_blorgh_articles author_id:integer
```

NOTA: Debido al nombre de la migración y la especificación de la columna después de él, Rails sabrá automáticamente que desea agregar una columna a una tabla específica y lo escribirá en la migración por usted. No necesita decirle más que esto.

Esta migración deberá ejecutarse en la aplicación. Para hacerlo, primero debe copiarse utilizando este comando:

```bash
$ bin/rails blorgh:install:migrations
```

Observe que aquí solo se copió _una_ migración. Esto se debe a que las dos primeras migraciones se copiaron la primera vez que se ejecutó este comando.

```
NOTA La migración [timestamp]_create_blorgh_articles.blorgh.rb de blorgh se ha omitido. Ya existe una migración con el mismo nombre.
NOTA La migración [timestamp]_create_blorgh_comments.blorgh.rb de blorgh se ha omitido. Ya existe una migración con el mismo nombre.
Se copió la migración [timestamp]_add_author_id_to_blorgh_articles.blorgh.rb de blorgh
```

Ejecute la migración usando:

```bash
$ bin/rails db:migrate
```

Ahora, con todas las piezas en su lugar, se llevará a cabo una acción que asociará un autor, representado por un registro en la tabla `users`, con un artículo, representado por la tabla `blorgh_articles` del motor.

Finalmente, el nombre del autor debe mostrarse en la página del artículo. Agregue este código encima de la salida "Title" dentro de `app/views/blorgh/articles/show.html.erb`:

```html+erb
<p>
  <b>Author:</b>
  <%= @article.author.name %>
</p>
```

#### Usando un controlador proporcionado por la aplicación

Por lo general, los controladores de Rails comparten código para cosas como la autenticación y el acceso a variables de sesión, por lo que heredan de `ApplicationController` de forma predeterminada. Sin embargo, los motores de Rails están diseñados para ejecutarse de forma independiente de la aplicación principal, por lo que cada motor obtiene un `ApplicationController` con un ámbito propio. Este espacio de nombres evita colisiones de código, pero a menudo los controladores del motor necesitan acceder a métodos en el `ApplicationController` de la aplicación principal. Una forma sencilla de proporcionar este acceso es cambiar el `ApplicationController` con ámbito del motor para que herede del `ApplicationController` de la aplicación principal. Para nuestro motor Blorgh, esto se haría cambiando `app/controllers/blorgh/application_controller.rb` para que se vea así:

```ruby
module Blorgh
  class ApplicationController < ::ApplicationController
  end
end
```

De forma predeterminada, los controladores del motor heredan de `Blorgh::ApplicationController`. Por lo tanto, después de realizar este cambio, tendrán acceso al `ApplicationController` de la aplicación principal, como si fueran parte de la aplicación principal.

Este cambio requiere que el motor se ejecute desde una aplicación Rails que tenga un `ApplicationController`.

### Configurando un motor

Esta sección cubre cómo hacer que la clase `User` sea configurable, seguida de consejos de configuración general para el motor.

#### Configurando opciones de configuración en la aplicación

El siguiente paso es hacer que la clase que representa a un `User` en la aplicación sea personalizable para el motor. Esto se debe a que esa clase no siempre será `User`, como se explicó anteriormente. Para hacer que esta configuración sea personalizable, el motor tendrá una opción de configuración llamada `author_class` que se utilizará para especificar qué clase representa a los usuarios dentro de la aplicación.

Para definir esta opción de configuración, debe utilizar un `mattr_accessor` dentro del módulo `Blorgh` del motor. Agregue esta línea a `lib/blorgh.rb` dentro del motor:

```ruby
mattr_accessor :author_class
```

Este método funciona como sus equivalentes, `attr_accessor` y `cattr_accessor`, pero proporciona un método setter y getter en el módulo con el nombre especificado. Para usarlo, debe hacer referencia a él utilizando `Blorgh.author_class`.

El siguiente paso es cambiar el modelo `Blorgh::Article` a esta nueva opción. Cambie la asociación `belongs_to` dentro de este modelo (`app/models/blorgh/article.rb`) a esto:

```ruby
belongs_to :author, class_name: Blorgh.author_class
```

El método `set_author` en el modelo `Blorgh::Article` también debe utilizar esta clase:

```ruby
self.author = Blorgh.author_class.constantize.find_or_create_by(name: author_name)
```

Para evitar tener que llamar a `constantize` en el resultado de `author_class` todo el tiempo, podría simplemente anular el método getter `author_class` dentro del módulo `Blorgh` en el archivo `lib/blorgh.rb` para que siempre llame a `constantize` en el valor guardado antes de devolver el resultado:
```ruby
def self.author_class
  @@author_class.constantize
end
```

Esto convertiría el código anterior para `set_author` en esto:

```ruby
self.author = Blorgh.author_class.find_or_create_by(name: author_name)
```

Resultando en algo un poco más corto y más implícito en su comportamiento. El método `author_class` siempre debe devolver un objeto `Class`.

Dado que cambiamos el método `author_class` para devolver una `Class` en lugar de una `String`, también debemos modificar nuestra definición de `belongs_to` en el modelo `Blorgh::Article`:

```ruby
belongs_to :author, class_name: Blorgh.author_class.to_s
```

Para configurar esta configuración dentro de la aplicación, se debe utilizar un inicializador. Al utilizar un inicializador, la configuración se establecerá antes de que la aplicación comience y llame a los modelos del motor, que pueden depender de que exista esta configuración.

Cree un nuevo inicializador en `config/initializers/blorgh.rb` dentro de la aplicación donde se instala el motor `blorgh` y coloque este contenido en él:

```ruby
Blorgh.author_class = "User"
```

ADVERTENCIA: Es muy importante aquí usar la versión `String` de la clase, en lugar de la clase en sí. Si usara la clase, Rails intentaría cargar esa clase y luego hacer referencia a la tabla relacionada. Esto podría causar problemas si la tabla aún no existiera. Por lo tanto, se debe usar una `String` y luego convertirla en una clase usando `constantize` en el motor más adelante.

Continúe y trate de crear un nuevo artículo. Verá que funciona exactamente de la misma manera que antes, excepto que esta vez el motor está utilizando la configuración en `config/initializers/blorgh.rb` para saber cuál es la clase.

Ahora no hay dependencias estrictas sobre cuál es la clase, solo sobre cuál debe ser la API para la clase. El motor simplemente requiere que esta clase defina un método `find_or_create_by` que devuelva un objeto de esa clase, para asociarlo con un artículo cuando se crea. Este objeto, por supuesto, debe tener algún tipo de identificador con el que se pueda hacer referencia.

#### Configuración general del motor

Dentro de un motor, puede llegar un momento en el que desee utilizar cosas como inicializadores, internacionalización u otras opciones de configuración. La gran noticia es que estas cosas son completamente posibles, porque un motor de Rails comparte gran parte de la misma funcionalidad que una aplicación de Rails. De hecho, la funcionalidad de una aplicación de Rails es en realidad un superconjunto de lo que proporcionan los motores.

Si desea utilizar un inicializador, es decir, código que debe ejecutarse antes de que se cargue el motor, el lugar para ello es la carpeta `config/initializers`. La funcionalidad de este directorio se explica en la sección [Inicializadores](configuring.html#initializers) de la guía de configuración, y funciona exactamente de la misma manera que el directorio `config/initializers` dentro de una aplicación. Lo mismo ocurre si desea utilizar un inicializador estándar.

Para los locales, simplemente coloque los archivos de localización en el directorio `config/locales`, al igual que lo haría en una aplicación.

Probando un motor
-----------------

Cuando se genera un motor, se crea una aplicación simulada más pequeña dentro de él en `test/dummy`. Esta aplicación se utiliza como punto de montaje para el motor, para facilitar las pruebas del motor. Puede ampliar esta aplicación generando controladores, modelos o vistas desde el directorio, y luego utilizarlos para probar su motor.

El directorio `test` debe tratarse como un entorno de prueba típico de Rails, lo que permite realizar pruebas unitarias, funcionales e integradas.

### Pruebas funcionales

Un aspecto que vale la pena tener en cuenta al escribir pruebas funcionales es que las pruebas se ejecutarán en una aplicación, la aplicación `test/dummy`, en lugar de en su motor. Esto se debe a la configuración del entorno de prueba; un motor necesita una aplicación como anfitrión para probar su funcionalidad principal, especialmente los controladores. Esto significa que si hiciera un `GET` típico a un controlador en una prueba funcional de controlador como esta:

```ruby
module Blorgh
  class FooControllerTest < ActionDispatch::IntegrationTest
    include Engine.routes.url_helpers

    def test_index
      get foos_url
      # ...
    end
  end
end
```

Es posible que no funcione correctamente. Esto se debe a que la aplicación no sabe cómo enrutar estas solicitudes al motor a menos que se lo indique explícitamente **cómo**. Para hacer esto, debe establecer la variable de instancia `@routes` en el conjunto de rutas del motor en su código de configuración:

```ruby
module Blorgh
  class FooControllerTest < ActionDispatch::IntegrationTest
    include Engine.routes.url_helpers

    setup do
      @routes = Engine.routes
    end

    def test_index
      get foos_url
      # ...
    end
  end
end
```
Esto le indica a la aplicación que aún desea realizar una solicitud `GET` a la acción `index` de este controlador, pero desea utilizar la ruta del motor para llegar allí, en lugar de la de la aplicación.

Esto también asegura que los ayudantes de URL del motor funcionarán como se espera en sus pruebas.

Mejorando la funcionalidad del motor
------------------------------------

Esta sección explica cómo agregar y/o anular la funcionalidad MVC del motor en la aplicación principal de Rails.

### Anulando modelos y controladores

Los modelos y controladores del motor pueden reabrirse en la aplicación principal para extenderlos o decorarlos.

Las anulaciones se pueden organizar en un directorio dedicado `app/overrides`, ignorado por el cargador automático y precargado en un callback `to_prepare`:

```ruby
# config/application.rb
module MyApp
  class Application < Rails::Application
    # ...

    overrides = "#{Rails.root}/app/overrides"
    Rails.autoloaders.main.ignore(overrides)

    config.to_prepare do
      Dir.glob("#{overrides}/**/*_override.rb").sort.each do |override|
        load override
      end
    end
  end
end
```

#### Reabrir clases existentes usando `class_eval`

Por ejemplo, para anular el modelo del motor

```ruby
# Blorgh/app/models/blorgh/article.rb
module Blorgh
  class Article < ApplicationRecord
    # ...
  end
end
```

solo tienes que crear un archivo que _reabra_ esa clase:

```ruby
# MyApp/app/overrides/models/blorgh/article_override.rb
Blorgh::Article.class_eval do
  # ...
end
```

Es muy importante que la anulación _reabra_ la clase o el módulo. El uso de las palabras clave `class` o `module` las definiría si no estuvieran en memoria, lo cual sería incorrecto porque la definición se encuentra en el motor. El uso de `class_eval` como se muestra arriba asegura que estás reabriendo.

#### Reabrir clases existentes usando ActiveSupport::Concern

El uso de `Class#class_eval` es excelente para ajustes simples, pero para modificaciones de clase más complejas, es posible que desees considerar el uso de [`ActiveSupport::Concern`](https://api.rubyonrails.org/classes/ActiveSupport/Concern.html). ActiveSupport::Concern administra el orden de carga de módulos y clases dependientes interconectados en tiempo de ejecución, lo que te permite modularizar significativamente tu código.

**Agregando** `Article#time_since_created` y **Anulando** `Article#summary`:

```ruby
# MyApp/app/models/blorgh/article.rb

class Blorgh::Article < ApplicationRecord
  include Blorgh::Concerns::Models::Article

  def time_since_created
    Time.current - created_at
  end

  def summary
    "#{title} - #{truncate(text)}"
  end
end
```

```ruby
# Blorgh/app/models/blorgh/article.rb
module Blorgh
  class Article < ApplicationRecord
    include Blorgh::Concerns::Models::Article
  end
end
```

```ruby
# Blorgh/lib/concerns/models/article.rb

module Blorgh::Concerns::Models::Article
  extend ActiveSupport::Concern

  # `included do` hace que el bloque se evalúe en el contexto
  # en el que se incluye el módulo (es decir, Blorgh::Article),
  # en lugar de en el módulo en sí.
  included do
    attr_accessor :author_name
    belongs_to :author, class_name: "User"

    before_validation :set_author

    private
      def set_author
        self.author = User.find_or_create_by(name: author_name)
      end
  end

  def summary
    "#{title}"
  end

  module ClassMethods
    def some_class_method
      'some class method string'
    end
  end
end
```

### Carga automática y motores

Consulta la guía [Carga automática y recarga de constantes](autoloading_and_reloading_constants.html#autoloading-and-engines) para obtener más información sobre la carga automática y los motores.

### Anulando vistas

Cuando Rails busca una vista para renderizar, primero buscará en el directorio `app/views` de la aplicación. Si no puede encontrar la vista allí, buscará en los directorios `app/views` de todos los motores que tengan este directorio.

Cuando se le pide a la aplicación que renderice la vista para la acción `index` del controlador `Blorgh::ArticlesController`, primero buscará la ruta `app/views/blorgh/articles/index.html.erb` dentro de la aplicación. Si no puede encontrarla, buscará dentro del motor.

Puedes anular esta vista en la aplicación simplemente creando un nuevo archivo en `app/views/blorgh/articles/index.html.erb`. Luego puedes cambiar completamente lo que esta vista normalmente mostraría.

Prueba esto ahora creando un nuevo archivo en `app/views/blorgh/articles/index.html.erb` y coloca este contenido en él:

```html+erb
<h1>Articles</h1>
<%= link_to "New Article", new_article_path %>
<% @articles.each do |article| %>
  <h2><%= article.title %></h2>
  <small>By <%= article.author %></small>
  <%= simple_format(article.text) %>
  <hr>
<% end %>
```

### Rutas

Las rutas dentro de un motor están aisladas de la aplicación de forma predeterminada. Esto se hace mediante la llamada `isolate_namespace` dentro de la clase `Engine`. Esto significa esencialmente que la aplicación y sus motores pueden tener rutas con nombres idénticos y no entrarán en conflicto.

Las rutas dentro de un motor se definen en la clase `Engine` dentro de `config/routes.rb`, de esta manera:

```ruby
Blorgh::Engine.routes.draw do
  resources :articles
end
```

Al tener rutas aisladas como esta, si deseas enlazar a un área de un motor desde dentro de una aplicación, deberás utilizar el método de proxy de enrutamiento del motor. Las llamadas a métodos de enrutamiento normales como `articles_path` pueden terminar yendo a ubicaciones no deseadas si tanto la aplicación como el motor tienen un ayudante definido de esa manera.

Por ejemplo, el siguiente ejemplo iría a `articles_path` de la aplicación si esa plantilla se renderizara desde la aplicación, o a `articles_path` del motor si se renderizara desde el motor:
```erb
<%= link_to "Artículos del blog", articles_path %>
```

Para que esta ruta siempre use el método auxiliar de enrutamiento `articles_path` del motor,
debemos llamar al método en el método de proxy de enrutamiento que comparte el mismo nombre que
el motor.

```erb
<%= link_to "Artículos del blog", blorgh.articles_path %>
```

Si desea hacer referencia a la aplicación dentro del motor de manera similar, use
el ayudante `main_app`:

```erb
<%= link_to "Inicio", main_app.root_path %>
```

Si esto se usara dentro de un motor, **siempre** iría a la
raíz de la aplicación. Si se omite la llamada al método de proxy de enrutamiento `main_app`,
potencialmente podría ir a la raíz del motor o de la aplicación,
dependiendo de dónde se haya llamado.

Si una plantilla renderizada desde dentro de un motor intenta usar uno de los
métodos auxiliares de enrutamiento de la aplicación, puede resultar en una llamada a un método no definido.
Si encuentra este problema, asegúrese de no intentar llamar a los
métodos de enrutamiento de la aplicación sin el prefijo `main_app` desde dentro del
motor.

### Activos

Los activos dentro de un motor funcionan de la misma manera que en una aplicación completa. Debido a que
la clase del motor hereda de `Rails::Engine`, la aplicación sabrá buscar activos en los directorios `app/assets` y `lib/assets` del motor.

Al igual que todos los demás componentes de un motor, los activos deben estar en un espacio de nombres.
Esto significa que si tiene un activo llamado `style.css`, debe colocarse en
`app/assets/stylesheets/[nombre del motor]/style.css`, en lugar de
`app/assets/stylesheets/style.css`. Si este activo no tiene un espacio de nombres, existe la
posibilidad de que la aplicación principal tenga un activo con el mismo nombre, en
cuyo caso el activo de la aplicación tomaría precedencia y se ignoraría el del motor.

Imaginemos que tiene un activo ubicado en
`app/assets/stylesheets/blorgh/style.css`. Para incluir este activo en una
aplicación, simplemente use `stylesheet_link_tag` y haga referencia al activo como si estuviera dentro del motor:

```erb
<%= stylesheet_link_tag "blorgh/style.css" %>
```

También puede especificar estos activos como dependencias de otros activos utilizando declaraciones de requerimiento del Asset Pipeline en archivos procesados:

```css
/*
 *= require blorgh/style
 */
```

INFO. Recuerde que para usar lenguajes como Sass o CoffeeScript,
debe agregar la biblioteca relevante al archivo `.gemspec` de su motor.

### Separar activos y precompilación

Hay algunas situaciones en las que los activos de su motor no son necesarios para la
aplicación principal. Por ejemplo, supongamos que ha creado una funcionalidad de administración
que solo existe para su motor. En este caso, la aplicación principal no necesita
requerir `admin.css` o `admin.js`. Solo el diseño de administración del motor necesita
estos activos. No tiene sentido que la aplicación principal incluya
`"blorgh/admin.css"` en sus hojas de estilo. En esta situación, debe
definir explícitamente estos activos para la precompilación. Esto le indica a Sprockets que agregue
los activos del motor cuando se active `bin/rails assets:precompile`.

Puede definir activos para la precompilación en `engine.rb`:

```ruby
initializer "blorgh.assets.precompile" do |app|
  app.config.assets.precompile += %w( admin.js admin.css )
end
```

Para obtener más información, lea la [guía del Asset Pipeline](asset_pipeline.html).

### Otras dependencias de gemas

Las dependencias de gemas dentro de un motor deben especificarse dentro del archivo `.gemspec`
en la raíz del motor. La razón es que el motor se puede instalar como una
gema. Si las dependencias se especificaran dentro del `Gemfile`, estas no se
reconocerían durante una instalación de gemas tradicional y, por lo tanto, no se instalarían,
lo que causaría un mal funcionamiento del motor.

Para especificar una dependencia que se debe instalar con el motor durante una
instalación tradicional de gemas, especifíquela dentro del bloque `Gem::Specification`
dentro del archivo `.gemspec` del motor:

```ruby
s.add_dependency "moo"
```

Para especificar una dependencia que solo se debe instalar como una dependencia de desarrollo
de la aplicación, especifíquela de esta manera:

```ruby
s.add_development_dependency "moo"
```

Ambos tipos de dependencias se instalarán cuando se ejecute `bundle install` dentro de
la aplicación. Las dependencias de desarrollo de la gema solo se utilizarán
cuando se ejecuten el desarrollo y las pruebas del motor.

Tenga en cuenta que si desea requerir inmediatamente dependencias cuando se
requiere el motor, debe requerirlas antes de la inicialización del motor. Por
ejemplo:

```ruby
require "other_engine/engine"
require "yet_another_engine/engine"

module MyEngine
  class Engine < ::Rails::Engine
  end
end
```

Ganchos de carga y configuración
-------------------------------

El código de Rails a menudo se puede hacer referencia al cargar una aplicación. Rails es responsable del orden de carga de estos frameworks, por lo que cuando carga frameworks, como `ActiveRecord::Base`, prematuramente está violando un contrato implícito que su aplicación tiene con Rails. Además, al cargar código como `ActiveRecord::Base` al inicio de su aplicación, está cargando frameworks completos que pueden ralentizar el tiempo de inicio y causar conflictos con el orden de carga y el inicio de su aplicación.
Los hooks de carga y configuración son la API que te permite enganchar en este proceso de inicialización sin violar el contrato de carga con Rails. Esto también mitigará la degradación del rendimiento de arranque y evitará conflictos.

### Evitar la carga de los frameworks de Rails

Dado que Ruby es un lenguaje dinámico, algunos códigos harán que se carguen diferentes frameworks de Rails. Por ejemplo, considera este fragmento de código:

```ruby
ActiveRecord::Base.include(MyActiveRecordHelper)
```

Este fragmento significa que cuando se cargue este archivo, encontrará `ActiveRecord::Base`. Este encuentro hace que Ruby busque la definición de esa constante y la requiera. Esto hace que se cargue todo el framework de Active Record al arrancar.

`ActiveSupport.on_load` es un mecanismo que se puede utilizar para retrasar la carga del código hasta que realmente se necesite. El fragmento anterior se puede cambiar a:

```ruby
ActiveSupport.on_load(:active_record) do
  include MyActiveRecordHelper
end
```

Este nuevo fragmento solo incluirá `MyActiveRecordHelper` cuando se cargue `ActiveRecord::Base`.

### ¿Cuándo se llaman los hooks?

En el framework de Rails, estos hooks se llaman cuando se carga una biblioteca específica. Por ejemplo, cuando se carga `ActionController::Base`, se llama al hook `:action_controller_base`. Esto significa que todas las llamadas a `ActiveSupport.on_load` con hooks `:action_controller_base` se llamarán en el contexto de `ActionController::Base` (eso significa que `self` será un `ActionController::Base`).

### Modificar el código para usar los hooks de carga

Modificar el código generalmente es sencillo. Si tienes una línea de código que se refiere a un framework de Rails como `ActiveRecord::Base`, puedes envolver ese código en un hook de carga.

**Modificar las llamadas a `include`**

```ruby
ActiveRecord::Base.include(MyActiveRecordHelper)
```

se convierte en

```ruby
ActiveSupport.on_load(:active_record) do
  # self se refiere a ActiveRecord::Base aquí,
  # por lo que podemos llamar a .include
  include MyActiveRecordHelper
end
```

**Modificar las llamadas a `prepend`**

```ruby
ActionController::Base.prepend(MyActionControllerHelper)
```

se convierte en

```ruby
ActiveSupport.on_load(:action_controller_base) do
  # self se refiere a ActionController::Base aquí,
  # por lo que podemos llamar a .prepend
  prepend MyActionControllerHelper
end
```

**Modificar las llamadas a métodos de clase**

```ruby
ActiveRecord::Base.include_root_in_json = true
```

se convierte en

```ruby
ActiveSupport.on_load(:active_record) do
  # self se refiere a ActiveRecord::Base aquí
  self.include_root_in_json = true
end
```

### Hooks de carga disponibles

Estos son los hooks de carga que puedes usar en tu propio código. Para enganchar en el proceso de inicialización de una de las siguientes clases, utiliza el hook disponible.

| Clase                                | Hook                                 |
| -------------------------------------| ------------------------------------ |
| `ActionCable`                        | `action_cable`                       |
| `ActionCable::Channel::Base`         | `action_cable_channel`               |
| `ActionCable::Connection::Base`      | `action_cable_connection`            |
| `ActionCable::Connection::TestCase`  | `action_cable_connection_test_case`  |
| `ActionController::API`              | `action_controller_api`              |
| `ActionController::API`              | `action_controller`                  |
| `ActionController::Base`             | `action_controller_base`             |
| `ActionController::Base`             | `action_controller`                  |
| `ActionController::TestCase`         | `action_controller_test_case`        |
| `ActionDispatch::IntegrationTest`    | `action_dispatch_integration_test`   |
| `ActionDispatch::Response`           | `action_dispatch_response`           |
| `ActionDispatch::Request`            | `action_dispatch_request`            |
| `ActionDispatch::SystemTestCase`     | `action_dispatch_system_test_case`   |
| `ActionMailbox::Base`                | `action_mailbox`                     |
| `ActionMailbox::InboundEmail`        | `action_mailbox_inbound_email`       |
| `ActionMailbox::Record`              | `action_mailbox_record`              |
| `ActionMailbox::TestCase`            | `action_mailbox_test_case`           |
| `ActionMailer::Base`                 | `action_mailer`                      |
| `ActionMailer::TestCase`             | `action_mailer_test_case`            |
| `ActionText::Content`                | `action_text_content`                |
| `ActionText::Record`                 | `action_text_record`                 |
| `ActionText::RichText`               | `action_text_rich_text`              |
| `ActionText::EncryptedRichText`      | `action_text_encrypted_rich_text`    |
| `ActionView::Base`                   | `action_view`                        |
| `ActionView::TestCase`               | `action_view_test_case`              |
| `ActiveJob::Base`                    | `active_job`                         |
| `ActiveJob::TestCase`                | `active_job_test_case`               |
| `ActiveRecord::Base`                 | `active_record`                      |
| `ActiveRecord::TestFixtures`         | `active_record_fixtures`             |
| `ActiveRecord::ConnectionAdapters::PostgreSQLAdapter`    | `active_record_postgresqladapter`    |
| `ActiveRecord::ConnectionAdapters::Mysql2Adapter`        | `active_record_mysql2adapter`        |
| `ActiveRecord::ConnectionAdapters::TrilogyAdapter`       | `active_record_trilogyadapter`       |
| `ActiveRecord::ConnectionAdapters::SQLite3Adapter`       | `active_record_sqlite3adapter`       |
| `ActiveStorage::Attachment`          | `active_storage_attachment`          |
| `ActiveStorage::VariantRecord`       | `active_storage_variant_record`      |
| `ActiveStorage::Blob`                | `active_storage_blob`                |
| `ActiveStorage::Record`              | `active_storage_record`              |
| `ActiveSupport::TestCase`            | `active_support_test_case`           |
| `i18n`                               | `i18n`                               |

### Hooks de configuración disponibles

Los hooks de configuración no se enganchan en ningún framework en particular, sino que se ejecutan en el contexto de toda la aplicación.

| Hook                   | Caso de uso                                                                         |
| ---------------------- | ---------------------------------------------------------------------------------- |
| `before_configuration` | Primer bloque configurable que se ejecuta. Se llama antes de que se ejecuten los inicializadores.           |
| `before_initialize`    | Segundo bloque configurable que se ejecuta. Se llama antes de que los frameworks se inicialicen.             |
| `before_eager_load`    | Tercer bloque configurable que se ejecuta. No se ejecuta si [`config.eager_load`][] se establece en false. |
| `after_initialize`     | Último bloque configurable que se ejecuta. Se llama después de que los frameworks se inicialicen.                |

Los hooks de configuración se pueden llamar en la clase Engine.

```ruby
module Blorgh
  class Engine < ::Rails::Engine
    config.before_configuration do
      puts 'Soy llamado antes de cualquier inicializador'
    end
  end
end
```
[`config.eager_load`]: configuring.html#config-eager-load
