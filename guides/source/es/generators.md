**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 0651830a9dc9cbd4e8a1fddab047c719
Creando y personalizando generadores y plantillas de Rails
============================================================

Los generadores de Rails son una herramienta esencial para mejorar tu flujo de trabajo. Con esta guía aprenderás cómo crear generadores y personalizar los existentes.

Después de leer esta guía, sabrás:

* Cómo ver qué generadores están disponibles en tu aplicación.
* Cómo crear un generador utilizando plantillas.
* Cómo Rails busca generadores antes de invocarlos.
* Cómo personalizar tu andamiaje sobrescribiendo las plantillas del generador.
* Cómo personalizar tu andamiaje sobrescribiendo generadores.
* Cómo usar fallbacks para evitar sobrescribir un gran conjunto de generadores.
* Cómo crear una plantilla de aplicación.

--------------------------------------------------------------------------------

Primer contacto
---------------

Cuando creas una aplicación utilizando el comando `rails`, en realidad estás utilizando un generador de Rails. Después de eso, puedes obtener una lista de todos los generadores disponibles invocando `bin/rails generate`:

```bash
$ rails new myapp
$ cd myapp
$ bin/rails generate
```

NOTA: Para crear una aplicación de Rails utilizamos el comando global `rails`, que utiliza la versión de Rails instalada a través de `gem install rails`. Cuando estás dentro del directorio de tu aplicación, utilizamos el comando `bin/rails`, que utiliza la versión de Rails incluida en la aplicación.

Obtendrás una lista de todos los generadores que vienen con Rails. Para ver una descripción detallada de un generador en particular, invoca el generador con la opción `--help`. Por ejemplo:

```bash
$ bin/rails generate scaffold --help
```

Creando tu primer generador
---------------------------

Los generadores se construyen sobre [Thor](https://github.com/rails/thor), que proporciona opciones poderosas para el análisis y una gran API para manipular archivos.

Vamos a construir un generador que crea un archivo de inicialización llamado `initializer.rb` dentro de `config/initializers`. El primer paso es crear un archivo en `lib/generators/initializer_generator.rb` con el siguiente contenido:

```ruby
class InitializerGenerator < Rails::Generators::Base
  def create_initializer_file
    create_file "config/initializers/initializer.rb", <<~RUBY
      # Agrega aquí el contenido de inicialización
    RUBY
  end
end
```

Nuestro nuevo generador es bastante simple: hereda de [`Rails::Generators::Base`][] y tiene una definición de método. Cuando se invoca un generador, cada método público en el generador se ejecuta secuencialmente en el orden en que se define. Nuestro método invoca [`create_file`][], que creará un archivo en la ubicación especificada con el contenido dado.

Para invocar nuestro nuevo generador, ejecutamos:

```bash
$ bin/rails generate initializer
```

Antes de continuar, veamos la descripción de nuestro nuevo generador:

```bash
$ bin/rails generate initializer --help
```

Rails suele ser capaz de derivar una buena descripción si un generador tiene un espacio de nombres, como `ActiveRecord::Generators::ModelGenerator`, pero no en este caso. Podemos resolver este problema de dos formas. La primera forma de agregar una descripción es llamando a [`desc`][] dentro de nuestro generador:

```ruby
class InitializerGenerator < Rails::Generators::Base
  desc "Este generador crea un archivo de inicialización en config/initializers"
  def create_initializer_file
    create_file "config/initializers/initializer.rb", <<~RUBY
      # Agrega aquí el contenido de inicialización
    RUBY
  end
end
```

Ahora podemos ver la nueva descripción invocando `--help` en el nuevo generador.

La segunda forma de agregar una descripción es creando un archivo llamado `USAGE` en el mismo directorio que nuestro generador. Vamos a hacer eso en el siguiente paso.


Creando generadores con generadores
-----------------------------------

Los generadores en sí mismos tienen un generador. Vamos a eliminar nuestro `InitializerGenerator` y usar `bin/rails generate generator` para generar uno nuevo:

```bash
$ rm lib/generators/initializer_generator.rb

$ bin/rails generate generator initializer
      create  lib/generators/initializer
      create  lib/generators/initializer/initializer_generator.rb
      create  lib/generators/initializer/USAGE
      create  lib/generators/initializer/templates
      invoke  test_unit
      create    test/lib/generators/initializer_generator_test.rb
```

Este es el generador que acaba de ser creado:

```ruby
class InitializerGenerator < Rails::Generators::NamedBase
  source_root File.expand_path("templates", __dir__)
end
```

Primero, observa que el generador hereda de [`Rails::Generators::NamedBase`][] en lugar de `Rails::Generators::Base`. Esto significa que nuestro generador espera al menos un argumento, que será el nombre del inicializador y estará disponible en nuestro código a través de `name`.

Podemos ver eso al verificar la descripción del nuevo generador:

```bash
$ bin/rails generate initializer --help
Uso:
  bin/rails generate initializer NAME [opciones]
```

Además, observa que el generador tiene un método de clase llamado [`source_root`][]. Este método apunta a la ubicación de nuestras plantillas, si las hay. Por defecto, apunta al directorio `lib/generators/initializer/templates` que acaba de ser creado.

Para entender cómo funcionan las plantillas de generador, creemos el archivo `lib/generators/initializer/templates/initializer.rb` con el siguiente contenido:

```ruby
# Agrega aquí el contenido de inicialización
```

Y cambiemos el generador para copiar esta plantilla cuando se invoque:
```ruby
class InitializerGenerator < Rails::Generators::NamedBase
  source_root File.expand_path("templates", __dir__)

  def copy_initializer_file
    copy_file "initializer.rb", "config/initializers/#{file_name}.rb"
  end
end
```

Ahora vamos a ejecutar nuestro generador:

```bash
$ bin/rails generate initializer core_extensions
      create  config/initializers/core_extensions.rb

$ cat config/initializers/core_extensions.rb
# Agrega aquí el contenido de inicialización
```

Vemos que [`copy_file`][] creó `config/initializers/core_extensions.rb`
con el contenido de nuestra plantilla. (El método `file_name` utilizado en la
ruta de destino se hereda de `Rails::Generators::NamedBase`.)


Opciones de línea de comandos del generador
-------------------------------------------

Los generadores pueden admitir opciones de línea de comandos utilizando [`class_option`][]. Por ejemplo:

```ruby
class InitializerGenerator < Rails::Generators::NamedBase
  class_option :scope, type: :string, default: "app"
end
```

Ahora nuestro generador puede ser invocado con la opción `--scope`:

```bash
$ bin/rails generate initializer theme --scope dashboard
```

Los valores de las opciones son accesibles en los métodos del generador a través de [`options`][]:

```ruby
def copy_initializer_file
  @scope = options["scope"]
end
```


Resolución de generadores
-------------------------

Al resolver el nombre de un generador, Rails busca el generador utilizando múltiples
nombres de archivo. Por ejemplo, cuando ejecutas `bin/rails generate initializer core_extensions`,
Rails intenta cargar cada uno de los siguientes archivos, en orden, hasta que se encuentre uno:

* `rails/generators/initializer/initializer_generator.rb`
* `generators/initializer/initializer_generator.rb`
* `rails/generators/initializer_generator.rb`
* `generators/initializer_generator.rb`

Si ninguno de estos se encuentra, se generará un error.

Colocamos nuestro generador en el directorio `lib/` de la aplicación porque ese
directorio está en `$LOAD_PATH`, lo que permite que Rails encuentre y cargue el archivo.

Anulación de las plantillas de generador de Rails
------------------------------------------------

Rails también buscará en varios lugares al resolver los archivos de plantilla del generador.
Uno de esos lugares es el directorio `lib/templates/` de la aplicación. Este
comportamiento nos permite anular las plantillas utilizadas por los generadores incorporados de Rails.
Por ejemplo, podríamos anular la plantilla del controlador de [scaffold][] o las
plantillas de vista de [scaffold][].

Para ver esto en acción, creemos un archivo `lib/templates/erb/scaffold/index.html.erb.tt` con el siguiente contenido:

```erb
<%% @<%= plural_table_name %>.count %> <%= human_name.pluralize %>
```

Ten en cuenta que la plantilla es una plantilla ERB que renderiza _otra_ plantilla ERB.
Por lo tanto, cualquier `<%` que deba aparecer en la plantilla _resultante_ debe escaparse como
`<%%` en la plantilla del _generador_.

Ahora ejecutemos el generador de scaffold incorporado de Rails:

```bash
$ bin/rails generate scaffold Post title:string
      ...
      create      app/views/posts/index.html.erb
      ...
```

El contenido de `app/views/posts/index.html.erb` es:

```erb
<% @posts.count %> Posts
```

[scaffold]: https://github.com/rails/rails/blob/main/railties/lib/rails/generators/rails/scaffold_controller/templates/controller.rb.tt
[scaffold]: https://github.com/rails/rails/tree/main/railties/lib/rails/generators/erb/scaffold/templates

Anulación de los generadores de Rails
-------------------------------------

Los generadores incorporados de Rails se pueden configurar a través de [`config.generators`][],
incluyendo la anulación de algunos generadores por completo.

Primero, echemos un vistazo más de cerca a cómo funciona el generador de scaffold.

```bash
$ bin/rails generate scaffold User name:string
      invoke  active_record
      create    db/migrate/20230518000000_create_users.rb
      create    app/models/user.rb
      invoke    test_unit
      create      test/models/user_test.rb
      create      test/fixtures/users.yml
      invoke  resource_route
       route    resources :users
      invoke  scaffold_controller
      create    app/controllers/users_controller.rb
      invoke    erb
      create      app/views/users
      create      app/views/users/index.html.erb
      create      app/views/users/edit.html.erb
      create      app/views/users/show.html.erb
      create      app/views/users/new.html.erb
      create      app/views/users/_form.html.erb
      create      app/views/users/_user.html.erb
      invoke    resource_route
      invoke    test_unit
      create      test/controllers/users_controller_test.rb
      create      test/system/users_test.rb
      invoke    helper
      create      app/helpers/users_helper.rb
      invoke      test_unit
      invoke    jbuilder
      create      app/views/users/index.json.jbuilder
      create      app/views/users/show.json.jbuilder
```

A partir de la salida, podemos ver que el generador de scaffold invoca otros
generadores, como el generador `scaffold_controller`. Y algunos de esos
generadores también invocan a otros generadores. En particular, el generador `scaffold_controller`
invoca varios otros generadores, incluido el generador `helper`.

Anulemos el generador incorporado `helper` con un nuevo generador. Nombraremos
el generador `my_helper`:

```bash
$ bin/rails generate generator rails/my_helper
      create  lib/generators/rails/my_helper
      create  lib/generators/rails/my_helper/my_helper_generator.rb
      create  lib/generators/rails/my_helper/USAGE
      create  lib/generators/rails/my_helper/templates
      invoke  test_unit
      create    test/lib/generators/rails/my_helper_generator_test.rb
```

Y en `lib/generators/rails/my_helper/my_helper_generator.rb` definiremos
el generador como:

```ruby
class Rails::MyHelperGenerator < Rails::Generators::NamedBase
  def create_helper_file
    create_file "app/helpers/#{file_name}_helper.rb", <<~RUBY
      module #{class_name}Helper
        # ¡Estoy ayudando!
      end
    RUBY
  end
end
```

Finalmente, necesitamos decirle a Rails que use el generador `my_helper` en lugar del
generador incorporado `helper`. Para eso, usamos `config.generators`. En
`config/application.rb`, agreguemos:

```ruby
config.generators do |g|
  g.helper :my_helper
end
```

Ahora, si ejecutamos el generador de scaffold nuevamente, veremos el generador `my_helper` en
acción:

```bash
$ bin/rails generate scaffold Article body:text
      ...
      invoke  scaffold_controller
      ...
      invoke    my_helper
      create      app/helpers/articles_helper.rb
      ...
```

NOTA: Puede que notes que la salida para el generador incorporado `helper`
incluye "invoke test_unit", mientras que la salida para `my_helper` no lo hace.
Aunque el generador `helper` no genera pruebas de forma predeterminada, proporciona un gancho para hacerlo usando [`hook_for`][].
Podemos hacer lo mismo incluyendo `hook_for :test_framework, as: :helper` en la clase `MyHelperGenerator`. Consulta
la documentación de `hook_for` para obtener más información.


### Fallbacks de generadores

Otra forma de anular generadores específicos es mediante el uso de _fallbacks_. Un fallback
permite que un espacio de nombres de generador delegue en otro espacio de nombres de generador.
Por ejemplo, supongamos que queremos anular el generador `test_unit:model` con nuestro propio generador `my_test_unit:model`, pero no queremos reemplazar todos los demás generadores `test_unit:*` como `test_unit:controller`.

Primero, creamos el generador `my_test_unit:model` en `lib/generators/my_test_unit/model/model_generator.rb`:

```ruby
module MyTestUnit
  class ModelGenerator < Rails::Generators::NamedBase
    source_root File.expand_path("templates", __dir__)

    def do_different_stuff
      say "Haciendo cosas diferentes..."
    end
  end
end
```

A continuación, utilizamos `config.generators` para configurar el generador `test_framework` como `my_test_unit`, pero también configuramos un fallback para que cualquier generador `my_test_unit:*` que falte se resuelva como `test_unit:*`:

```ruby
config.generators do |g|
  g.test_framework :my_test_unit, fixture: false
  g.fallbacks[:my_test_unit] = :test_unit
end
```

Ahora, cuando ejecutamos el generador de scaffold, vemos que `my_test_unit` ha reemplazado a `test_unit`, pero solo se han visto afectadas las pruebas de modelo:

```bash
$ bin/rails generate scaffold Comment body:text
      invoke  active_record
      create    db/migrate/20230518000000_create_comments.rb
      create    app/models/comment.rb
      invoke    my_test_unit
    Haciendo cosas diferentes...
      invoke  resource_route
       route    resources :comments
      invoke  scaffold_controller
      create    app/controllers/comments_controller.rb
      invoke    erb
      create      app/views/comments
      create      app/views/comments/index.html.erb
      create      app/views/comments/edit.html.erb
      create      app/views/comments/show.html.erb
      create      app/views/comments/new.html.erb
      create      app/views/comments/_form.html.erb
      create      app/views/comments/_comment.html.erb
      invoke    resource_route
      invoke    my_test_unit
      create      test/controllers/comments_controller_test.rb
      create      test/system/comments_test.rb
      invoke    helper
      create      app/helpers/comments_helper.rb
      invoke      my_test_unit
      invoke    jbuilder
      create      app/views/comments/index.json.jbuilder
      create      app/views/comments/show.json.jbuilder
```

Plantillas de aplicación
------------------------

Las plantillas de aplicación son un tipo especial de generador. Pueden utilizar todos los [métodos auxiliares del generador](#métodos-auxiliares-del-generador), pero se escriben como un script de Ruby en lugar de una clase de Ruby. Aquí tienes un ejemplo:

```ruby
# template.rb

if yes?("¿Deseas instalar Devise?")
  gem "devise"
  devise_model = ask("¿Cómo te gustaría llamar al modelo de usuario?", default: "User")
end

after_bundle do
  if devise_model
    generate "devise:install"
    generate "devise", devise_model
    rails_command "db:migrate"
  end

  git add: ".", commit: %(-m 'Commit inicial')
end
```

Primero, la plantilla le pregunta al usuario si desea instalar Devise. Si el usuario responde "sí" (o "s"), la plantilla agrega Devise al `Gemfile` y le pregunta al usuario el nombre del modelo de usuario de Devise (por defecto, `User`). Más tarde, después de que se haya ejecutado `bundle install`, la plantilla ejecutará los generadores de Devise y `rails db:migrate` si se especificó un modelo de Devise. Finalmente, la plantilla hará `git add` y `git commit` de todo el directorio de la aplicación.

Podemos ejecutar nuestra plantilla al generar una nueva aplicación de Rails pasando la opción `-m` al comando `rails new`:

```bash
$ rails new my_cool_app -m path/to/template.rb
```

Alternativamente, podemos ejecutar nuestra plantilla dentro de una aplicación existente con `bin/rails app:template`:

```bash
$ bin/rails app:template LOCATION=path/to/template.rb
```

Las plantillas tampoco necesitan almacenarse localmente, puedes especificar una URL en lugar de una ruta:

```bash
$ rails new my_cool_app -m http://example.com/template.rb
$ bin/rails app:template LOCATION=http://example.com/template.rb
```

Métodos auxiliares del generador
--------------------------------

Thor proporciona muchos métodos auxiliares del generador a través de [`Thor::Actions`][], como:

* [`copy_file`][]
* [`create_file`][]
* [`gsub_file`][]
* [`insert_into_file`][]
* [`inside`][]

Además de eso, Rails también proporciona muchos métodos auxiliares a través de [`Rails::Generators::Actions`][], como:

* [`environment`][]
* [`gem`][]
* [`generate`][]
* [`git`][]
* [`initializer`][]
* [`lib`][]
* [`rails_command`][]
* [`rake`][]
* [`route`][]
[`Rails::Generators::Base`]: https://api.rubyonrails.org/classes/Rails/Generators/Base.html
[`Thor::Actions`]: https://www.rubydoc.info/gems/thor/Thor/Actions
[`create_file`]: https://www.rubydoc.info/gems/thor/Thor/Actions#create_file-instance_method
[`desc`]: https://www.rubydoc.info/gems/thor/Thor#desc-class_method
[`Rails::Generators::NamedBase`]: https://api.rubyonrails.org/classes/Rails/Generators/NamedBase.html
[`copy_file`]: https://www.rubydoc.info/gems/thor/Thor/Actions#copy_file-instance_method
[`source_root`]: https://api.rubyonrails.org/classes/Rails/Generators/Base.html#method-c-source_root
[`class_option`]: https://www.rubydoc.info/gems/thor/Thor/Base/ClassMethods#class_option-instance_method
[`options`]: https://www.rubydoc.info/gems/thor/Thor/Base#options-instance_method
[`config.generators`]: configuring.html#configuring-generators
[`hook_for`]: https://api.rubyonrails.org/classes/Rails/Generators/Base.html#method-c-hook_for
[`Rails::Generators::Actions`]: https://api.rubyonrails.org/classes/Rails/Generators/Actions.html
[`environment`]: https://api.rubyonrails.org/classes/Rails/Generators/Actions.html#method-i-environment
[`gem`]: https://api.rubyonrails.org/classes/Rails/Generators/Actions.html#method-i-gem
[`generate`]: https://api.rubyonrails.org/classes/Rails/Generators/Actions.html#method-i-generate
[`git`]: https://api.rubyonrails.org/classes/Rails/Generators/Actions.html#method-i-git
[`gsub_file`]: https://www.rubydoc.info/gems/thor/Thor/Actions#gsub_file-instance_method
[`initializer`]: https://api.rubyonrails.org/classes/Rails/Generators/Actions.html#method-i-initializer
[`insert_into_file`]: https://www.rubydoc.info/gems/thor/Thor/Actions#insert_into_file-instance_method
[`inside`]: https://www.rubydoc.info/gems/thor/Thor/Actions#inside-instance_method
[`lib`]: https://api.rubyonrails.org/classes/Rails/Generators/Actions.html#method-i-lib
[`rails_command`]: https://api.rubyonrails.org/classes/Rails/Generators/Actions.html#method-i-rails_command
[`rake`]: https://api.rubyonrails.org/classes/Rails/Generators/Actions.html#method-i-rake
[`route`]: https://api.rubyonrails.org/classes/Rails/Generators/Actions.html#method-i-route
