**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: d3947b8dd1115e8f8e4279581ff626f6
Plantillas de Aplicación en Rails
===========================

Las plantillas de aplicación son archivos Ruby simples que contienen DSL para agregar gemas, inicializadores, etc. a tu proyecto Rails recién creado o a un proyecto Rails existente.

Después de leer esta guía, sabrás:

* Cómo usar plantillas para generar/personalizar aplicaciones Rails.
* Cómo escribir tus propias plantillas de aplicación reutilizables utilizando la API de plantillas de Rails.

--------------------------------------------------------------------------------

Uso
-----

Para aplicar una plantilla, debes proporcionar al generador de Rails la ubicación de la plantilla que deseas aplicar utilizando la opción `-m`. Esto puede ser una ruta a un archivo o una URL.

```bash
$ rails new blog -m ~/template.rb
$ rails new blog -m http://example.com/template.rb
```

Puedes usar el comando `app:template` de Rails para aplicar plantillas a una aplicación Rails existente. La ubicación de la plantilla debe pasarse a través de la variable de entorno LOCATION. Nuevamente, esto puede ser una ruta a un archivo o una URL.

```bash
$ bin/rails app:template LOCATION=~/template.rb
$ bin/rails app:template LOCATION=http://example.com/template.rb
```

API de Plantillas
------------

La API de plantillas de Rails es fácil de entender. Aquí tienes un ejemplo de una plantilla típica de Rails:

```ruby
# template.rb
generate(:scaffold, "person name:string")
route "root to: 'people#index'"
rails_command("db:migrate")

after_bundle do
  git :init
  git add: "."
  git commit: %Q{ -m 'Initial commit' }
end
```

Las siguientes secciones describen los métodos principales proporcionados por la API:

### gem(*args)

Agrega una entrada `gem` para la gema suministrada al `Gemfile` de la aplicación generada.

Por ejemplo, si tu aplicación depende de las gemas `bj` y `nokogiri`:

```ruby
gem "bj"
gem "nokogiri"
```

Ten en cuenta que este método solo agrega la gema al `Gemfile`; no instala la gema.

### gem_group(*names, &block)

Envuelve las entradas de gemas dentro de un grupo.

Por ejemplo, si quieres cargar `rspec-rails` solo en los grupos `development` y `test`:

```ruby
gem_group :development, :test do
  gem "rspec-rails"
end
```

### add_source(source, options={}, &block)

Agrega la fuente dada al `Gemfile` de la aplicación generada.

Por ejemplo, si necesitas obtener una gema de `"http://gems.github.com"`:

```ruby
add_source "http://gems.github.com"
```

Si se proporciona un bloque, las entradas de gemas en el bloque se envuelven en el grupo de la fuente.

```ruby
add_source "http://gems.github.com/" do
  gem "rspec-rails"
end
```

### environment/application(data=nil, options={}, &block)

Agrega una línea dentro de la clase `Application` para `config/application.rb`.

Si se especifica `options[:env]`, la línea se agrega al archivo correspondiente en `config/environments`.

```ruby
environment 'config.action_mailer.default_url_options = {host: "http://yourwebsite.example.com"}', env: 'production'
```

Se puede usar un bloque en lugar del argumento `data`.

### vendor/lib/file/initializer(filename, data = nil, &block)

Agrega un inicializador al directorio `config/initializers` de la aplicación generada.

Digamos que te gusta usar `Object#not_nil?` y `Object#not_blank?`:

```ruby
initializer 'bloatlol.rb', <<-CODE
  class Object
    def not_nil?
      !nil?
    end

    def not_blank?
      !blank?
    end
  end
CODE
```

De manera similar, `lib()` crea un archivo en el directorio `lib/` y `vendor()` crea un archivo en el directorio `vendor/`.

Incluso hay `file()`, que acepta una ruta relativa desde `Rails.root` y crea todos los directorios/archivos necesarios:

```ruby
file 'app/components/foo.rb', <<-CODE
  class Foo
  end
CODE
```

Eso creará el directorio `app/components` y colocará `foo.rb` allí.

### rakefile(filename, data = nil, &block)

Crea un nuevo archivo rake en `lib/tasks` con las tareas suministradas:

```ruby
rakefile("bootstrap.rake") do
  <<-TASK
    namespace :boot do
      task :strap do
        puts "i like boots!"
      end
    end
  TASK
end
```

Lo anterior crea `lib/tasks/bootstrap.rake` con una tarea rake `boot:strap`.

### generate(what, *args)

Ejecuta el generador de Rails suministrado con los argumentos dados.

```ruby
generate(:scaffold, "person", "name:string", "address:text", "age:number")
```

### run(command)

Ejecuta un comando arbitrario. Al igual que las comillas invertidas. Digamos que quieres eliminar el archivo `README.rdoc`:

```ruby
run "rm README.rdoc"
```

### rails_command(command, options = {})

Ejecuta el comando suministrado en la aplicación Rails. Digamos que quieres migrar la base de datos:

```ruby
rails_command "db:migrate"
```

También puedes ejecutar comandos con un entorno Rails diferente:

```ruby
rails_command "db:migrate", env: 'production'
```

También puedes ejecutar comandos como superusuario:

```ruby
rails_command "log:clear", sudo: true
```

También puedes ejecutar comandos que deben abortar la generación de la aplicación si fallan:

```ruby
rails_command "db:migrate", abort_on_failure: true
```

### route(routing_code)

Agrega una entrada de enrutamiento al archivo `config/routes.rb`. En los pasos anteriores, generamos un andamio de persona y también eliminamos `README.rdoc`. Ahora, para hacer que `PeopleController#index` sea la página predeterminada de la aplicación:

```ruby
route "root to: 'person#index'"
```

### inside(dir)

Te permite ejecutar un comando desde el directorio dado. Por ejemplo, si tienes una copia de Rails edge que deseas vincular desde tus nuevas aplicaciones, puedes hacer esto:
```ruby
dentro_de('vendor') do
  ejecutar "ln -s ~/commit-rails/rails rails"
end
```

### ask(pregunta)

`ask()` te da la oportunidad de obtener comentarios del usuario y usarlos en tus plantillas. Digamos que quieres que el usuario nombre la nueva y brillante biblioteca que estás agregando:

```ruby
nombre_lib = ask("¿Cómo quieres llamar a la brillante biblioteca?")
nombre_lib << ".rb" unless nombre_lib.index(".rb")

lib nombre_lib, <<-CODE
  class Brillante
  end
CODE
```

### yes?(pregunta) o no?(pregunta)

Estos métodos te permiten hacer preguntas desde las plantillas y decidir el flujo basado en la respuesta del usuario. Digamos que quieres preguntarle al usuario si desea ejecutar migraciones:

```ruby
rails_command("db:migrate") if yes?("¿Ejecutar migraciones de la base de datos?")
# no?(pregunta) actúa de manera opuesta.
```

### git(:comando)

Las plantillas de Rails te permiten ejecutar cualquier comando de git:

```ruby
git :init
git add: "."
git commit: "-a -m 'Commit inicial'"
```

### after_bundle(&block)

Registra una devolución de llamada para ser ejecutada después de que se instalen las gemas y se generen los binstubs. Útil para agregar archivos generados al control de versiones:

```ruby
after_bundle do
  git :init
  git add: '.'
  git commit: "-a -m 'Commit inicial'"
end
```

Las devoluciones de llamada se ejecutan incluso si se ha pasado `--skip-bundle`.

Uso Avanzado
--------------

La plantilla de la aplicación se evalúa en el contexto de una instancia de `Rails::Generators::AppGenerator`. Utiliza la acción [`apply`](https://www.rubydoc.info/gems/thor/Thor/Actions#apply-instance_method) proporcionada por Thor.

Esto significa que puedes extender y cambiar la instancia para que se ajuste a tus necesidades.

Por ejemplo, sobrescribiendo el método `source_paths` para que contenga la ubicación de tu plantilla. Ahora, los métodos como `copy_file` aceptarán rutas relativas a la ubicación de tu plantilla.

```ruby
def source_paths
  [__dir__]
end
```
