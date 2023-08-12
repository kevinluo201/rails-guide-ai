**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: da25f37b5b3eddff86c5b5b2cd24007f
Notas de lanzamiento de Ruby on Rails 3.1
==========================================

Aspectos destacados en Rails 3.1:

* Streaming
* Migraciones reversibles
* Canalización de activos
* jQuery como biblioteca de JavaScript predeterminada

Estas notas de lanzamiento solo cubren los cambios principales. Para conocer las diversas correcciones de errores y cambios, consulte los registros de cambios o revise la [lista de confirmaciones](https://github.com/rails/rails/commits/3-1-stable) en el repositorio principal de Rails en GitHub.

--------------------------------------------------------------------------------

Actualización a Rails 3.1
-------------------------

Si está actualizando una aplicación existente, es una buena idea tener una buena cobertura de pruebas antes de comenzar. También debe actualizar primero a Rails 3 en caso de que no lo haya hecho y asegurarse de que su aplicación siga funcionando como se espera antes de intentar actualizar a Rails 3.1. Luego, tenga en cuenta los siguientes cambios:

### Rails 3.1 requiere al menos Ruby 1.8.7

Rails 3.1 requiere Ruby 1.8.7 o superior. El soporte para todas las versiones anteriores de Ruby se ha eliminado oficialmente y debe actualizar lo antes posible. Rails 3.1 también es compatible con Ruby 1.9.2.

CONSEJO: Tenga en cuenta que Ruby 1.8.7 p248 y p249 tienen errores de serialización que hacen que Rails se bloquee. Ruby Enterprise Edition los ha corregido desde la versión 1.8.7-2010.02. En cuanto a la versión 1.9, Ruby 1.9.1 no se puede usar porque se bloquea por completo, por lo que si desea usar 1.9.x, use 1.9.2 para un funcionamiento sin problemas.

### Qué actualizar en sus aplicaciones

Los siguientes cambios están destinados a actualizar su aplicación a Rails 3.1.3, la última versión 3.1.x de Rails.

#### Gemfile

Realice los siguientes cambios en su `Gemfile`.

```ruby
gem 'rails', '= 3.1.3'
gem 'mysql2'

# Necesario para la nueva canalización de activos
group :assets do
  gem 'sass-rails',   "~> 3.1.5"
  gem 'coffee-rails', "~> 3.1.1"
  gem 'uglifier',     ">= 1.0.3"
end

# jQuery es la biblioteca de JavaScript predeterminada en Rails 3.1
gem 'jquery-rails'
```

#### config/application.rb

* La canalización de activos requiere las siguientes adiciones:

    ```ruby
    config.assets.enabled = true
    config.assets.version = '1.0'
    ```

* Si su aplicación está utilizando la ruta "/assets" para un recurso, es posible que desee cambiar el prefijo utilizado para los activos para evitar conflictos:

    ```ruby
    # Por defecto es '/assets'
    config.assets.prefix = '/asset-files'
    ```

#### config/environments/development.rb

* Elimine la configuración de RJS `config.action_view.debug_rjs = true`.

* Agregue lo siguiente, si habilita la canalización de activos.

    ```ruby
    # No comprimir activos
    config.assets.compress = false

    # Expande las líneas que cargan los activos
    config.assets.debug = true
    ```

#### config/environments/production.rb

* Nuevamente, la mayoría de los cambios a continuación son para la canalización de activos. Puede leer más sobre esto en la guía [Canalización de activos](asset_pipeline.html).

    ```ruby
    # Comprimir JavaScript y CSS
    config.assets.compress = true

    # No utilizar la canalización de activos si falta un activo precompilado
    config.assets.compile = false

    # Generar resúmenes para las URL de los activos
    config.assets.digest = true

    # Por defecto, Rails.root.join("public/assets")
    # config.assets.manifest = YOUR_PATH

    # Precompilar activos adicionales (application.js, application.css y todos los que no sean JS/CSS ya están agregados)
    # config.assets.precompile `= %w( admin.js admin.css )


    # Forzar todo el acceso a la aplicación a través de SSL, usar Strict-Transport-Security y cookies seguras.
    # config.force_ssl = true
    ```

#### config/environments/test.rb

```ruby
# Configurar el servidor de activos estáticos para pruebas con Cache-Control para mejorar el rendimiento
config.serve_static_assets = true
config.static_cache_control = "public, max-age=3600"
```

#### config/initializers/wrap_parameters.rb

* Agregue este archivo con el siguiente contenido, si desea envolver los parámetros en un hash anidado. Esto está activado de forma predeterminada en las nuevas aplicaciones.

    ```ruby
    # Asegúrese de reiniciar su servidor cuando modifique este archivo.
    # Este archivo contiene configuraciones para ActionController::ParamsWrapper que
    # está habilitado de forma predeterminada.

    # Habilitar el envoltorio de parámetros para JSON. Puede deshabilitar esto configurando :format en una matriz vacía.
    ActiveSupport.on_load(:action_controller) do
      wrap_parameters :format => [:json]
    end

    # Deshabilitar el elemento raíz en JSON de forma predeterminada.
    ActiveSupport.on_load(:active_record) do
      self.include_root_in_json = false
    end
    ```

#### Eliminar las opciones :cache y :concat en las referencias de los ayudantes de activos en las vistas

* Con la canalización de activos, las opciones :cache y :concat ya no se utilizan, elimine estas opciones de sus vistas.

Creación de una aplicación Rails 3.1
-----------------------------------

```bash
# Debe tener instalada la gema 'rails'
$ rails new myapp
$ cd myapp
```

### Empaquetar gemas

Rails ahora utiliza un `Gemfile` en la raíz de la aplicación para determinar las gemas que necesita su aplicación para iniciar. Este `Gemfile` es procesado por la gema [Bundler](https://github.com/carlhuda/bundler), que luego instala todas las dependencias. Incluso puede instalar todas las dependencias localmente en su aplicación para que no dependa de las gemas del sistema.
Más información: - [página principal de Bundler](https://bundler.io/)

### Viviendo al límite

`Bundler` y `Gemfile` hacen que congelar tu aplicación Rails sea pan comido con el nuevo comando `bundle` dedicado. Si quieres agrupar directamente desde el repositorio Git, puedes pasar la bandera `--edge`:

```bash
$ rails new myapp --edge
```

Si tienes una copia local del repositorio de Rails y quieres generar una aplicación usando eso, puedes pasar la bandera `--dev`:

```bash
$ ruby /path/to/rails/railties/bin/rails new myapp --dev
```

Cambios arquitectónicos de Rails
---------------------------

### Pipeline de activos

El cambio principal en Rails 3.1 es el Pipeline de activos. Hace que CSS y JavaScript sean ciudadanos de primera clase y permite una organización adecuada, incluyendo su uso en complementos y motores.

El pipeline de activos está impulsado por [Sprockets](https://github.com/rails/sprockets) y se cubre en la guía [Pipeline de activos](asset_pipeline.html).

### Streaming HTTP

El streaming HTTP es otro cambio que es nuevo en Rails 3.1. Esto permite que el navegador descargue tus hojas de estilo y archivos JavaScript mientras el servidor sigue generando la respuesta. Esto requiere Ruby 1.9.2, es opcional y también requiere soporte por parte del servidor web, pero la combinación popular de NGINX y Unicorn está lista para aprovecharlo.

### La biblioteca JS predeterminada ahora es jQuery

jQuery es la biblioteca JavaScript predeterminada que se incluye con Rails 3.1. Pero si usas Prototype, es fácil cambiarlo.

```bash
$ rails new myapp -j prototype
```

### Mapa de identidad

Active Record tiene un mapa de identidad en Rails 3.1. Un mapa de identidad mantiene registros previamente instanciados y devuelve el objeto asociado con el registro si se accede nuevamente. El mapa de identidad se crea en cada solicitud y se vacía al finalizar la solicitud.

Rails 3.1 viene con el mapa de identidad desactivado de forma predeterminada.

Railties
--------

* jQuery es la nueva biblioteca JavaScript predeterminada.

* jQuery y Prototype ya no se venden y ahora se proporcionan a través de las gemas `jquery-rails` y `prototype-rails`.

* El generador de aplicaciones acepta una opción `-j` que puede ser una cadena arbitraria. Si se pasa "foo", se agrega la gema "foo-rails" al `Gemfile`, y el manifiesto de JavaScript de la aplicación requiere "foo" y "foo_ujs". Actualmente solo existen "prototype-rails" y "jquery-rails" y proporcionan esos archivos a través del pipeline de activos.

* Generar una aplicación o un complemento ejecuta `bundle install` a menos que se especifique `--skip-gemfile` o `--skip-bundle`.

* Los generadores de controladores y recursos ahora generarán automáticamente stubs de activos (esto se puede desactivar con `--skip-assets`). Estos stubs utilizarán CoffeeScript y Sass, si esas bibliotecas están disponibles.

* El generador de controladores de andamios crea un bloque de formato para JSON en lugar de XML.

* El registro de Active Record se dirige a STDOUT y se muestra en línea en la consola.

* Se agregó la configuración `config.force_ssl`, que carga el middleware `Rack::SSL` y fuerza que todas las solicitudes estén bajo el protocolo HTTPS.

* Se agregó el comando `rails plugin new`, que genera un complemento de Rails con gemspec, pruebas y una aplicación ficticia para pruebas.

* Se agregaron `Rack::Etag` y `Rack::ConditionalGet` a la pila de middleware predeterminada.

* Se agregó `Rack::Cache` a la pila de middleware predeterminada.

* Los motores recibieron una actualización importante: se pueden montar en cualquier ruta, habilitar activos, ejecutar generadores, etc.

Action Pack
-----------

### Action Controller

* Se emite una advertencia si no se puede verificar la autenticidad del token CSRF.

* Especifica `force_ssl` en un controlador para forzar al navegador a transferir datos a través del protocolo HTTPS en ese controlador en particular. Para limitar a acciones específicas, se pueden usar `:only` o `:except`.

* Los parámetros de cadena de consulta sensibles especificados en `config.filter_parameters` ahora se filtrarán de las rutas de solicitud en el registro.

* Los parámetros de URL que devuelven `nil` para `to_param` ahora se eliminan de la cadena de consulta.

* Se agregó `ActionController::ParamsWrapper` para envolver los parámetros en un hash anidado, y se activará de forma predeterminada para las solicitudes JSON en nuevas aplicaciones. Esto se puede personalizar en `config/initializers/wrap_parameters.rb`.

* Se agregó `config.action_controller.include_all_helpers`. De forma predeterminada, se realiza `helper :all` en `ActionController::Base`, que incluye todos los helpers de forma predeterminada. Si se establece `include_all_helpers` en `false`, solo se incluirá `application_helper` y el helper correspondiente al controlador (como `foo_helper` para `foo_controller`).

* `url_for` y los ayudantes de URL con nombre ahora aceptan `:subdomain` y `:domain` como opciones.
* Se agregó `Base.http_basic_authenticate_with` para realizar una autenticación básica de http con una sola llamada al método de clase.

    ```ruby
    class PostsController < ApplicationController
      USER_NAME, PASSWORD = "dhh", "secret"

      before_filter :authenticate, :except => [ :index ]

      def index
        render :text => "¡Todos pueden verme!"
      end

      def edit
        render :text => "Solo soy accesible si conoces la contraseña"
      end

      private
        def authenticate
          authenticate_or_request_with_http_basic do |user_name, password|
            user_name == USER_NAME && password == PASSWORD
          end
        end
    end
    ```

    ..ahora se puede escribir como

    ```ruby
    class PostsController < ApplicationController
      http_basic_authenticate_with :name => "dhh", :password => "secret", :except => :index

      def index
        render :text => "¡Todos pueden verme!"
      end

      def edit
        render :text => "Solo soy accesible si conoces la contraseña"
      end
    end
    ```

* Se agregó soporte para streaming, se puede habilitar con:

    ```ruby
    class PostsController < ActionController::Base
      stream
    end
    ```

    Se puede restringir a algunas acciones usando `:only` o `:except`. Por favor, lee la documentación en [`ActionController::Streaming`](https://api.rubyonrails.org/v3.1.0/classes/ActionController/Streaming.html) para más información.

* El método de ruta de redirección ahora también acepta un hash de opciones que solo cambiarán las partes de la URL en cuestión, o un objeto que responda a `call`, permitiendo reutilizar las redirecciones.

### Action Dispatch

* `config.action_dispatch.x_sendfile_header` ahora tiene un valor predeterminado de `nil` y `config/environments/production.rb` no establece ningún valor en particular para él. Esto permite que los servidores lo establezcan a través de `X-Sendfile-Type`.

* `ActionDispatch::MiddlewareStack` ahora utiliza composición en lugar de herencia y ya no es un array.

* Se agregó `ActionDispatch::Request.ignore_accept_header` para ignorar los encabezados de aceptación.

* Se agregó `Rack::Cache` a la pila predeterminada.

* Se trasladó la responsabilidad de etag de `ActionDispatch::Response` a la pila de middleware.

* Se basa en la API de almacenamiento de `Rack::Session` para una mayor compatibilidad en el mundo Ruby. Esto es incompatible con versiones anteriores ya que `Rack::Session` espera que `#get_session` acepte cuatro argumentos y requiere `#destroy_session` en lugar de simplemente `#destroy`.

* La búsqueda de plantillas ahora busca más arriba en la cadena de herencia.

### Action View

* Se agregó la opción `:authenticity_token` a `form_tag` para un manejo personalizado o para omitir el token pasando `:authenticity_token => false`.

* Se creó `ActionView::Renderer` y se especificó una API para `ActionView::Context`.

* La mutación en su lugar de `SafeBuffer` está prohibida en Rails 3.1.

* Se agregó el ayudante `button_tag` de HTML5.

* `file_field` agrega automáticamente `:multipart => true` al formulario que lo contiene.

* Se agregó un conveniente método para generar atributos HTML5 `data-*` en los ayudantes de etiquetas a partir de un hash `:data` de opciones:

    ```ruby
    tag("div", :data => {:name => 'Stephen', :city_state => %w(Chicago IL)})
    # => <div data-name="Stephen" data-city-state="[&quot;Chicago&quot;,&quot;IL&quot;]" />
    ```

Las claves se convierten en guiones. Los valores se codifican en JSON, excepto para cadenas y símbolos.

* `csrf_meta_tag` se renombró a `csrf_meta_tags` y se agregó un alias `csrf_meta_tag` para compatibilidad con versiones anteriores.

* La antigua API de manejadores de plantillas está en desuso y la nueva API simplemente requiere que un manejador de plantillas responda a `call`.

* Se eliminaron finalmente los manejadores de plantillas rhtml y rxml.

* Se volvió a agregar `config.action_view.cache_template_loading`, que permite decidir si las plantillas deben ser almacenadas en caché o no.

* El ayudante de formulario `submit` ya no genera un id "object_name_id".

* Permite que `FormHelper#form_for` especifique el `:method` como una opción directa en lugar de a través del hash `:html`. `form_for(@post, remote: true, method: :delete)` en lugar de `form_for(@post, remote: true, html: { method: :delete })`.

* Se proporcionó `JavaScriptHelper#j()` como un alias de `JavaScriptHelper#escape_javascript()`. Esto reemplaza el método `Object#j()` que la gema JSON agrega dentro de las plantillas que utilizan JavaScriptHelper.

* Permite el formato AM/PM en los selectores de fecha y hora.

* `auto_link` se ha eliminado de Rails y se ha extraído a la gema [rails_autolink](https://github.com/tenderlove/rails_autolink)

Active Record
-------------

* Se agregó un método de clase `pluralize_table_names` para singularizar/pluralizar los nombres de tabla de modelos individuales. Anteriormente, esto solo se podía configurar globalmente para todos los modelos a través de `ActiveRecord::Base.pluralize_table_names`.

    ```ruby
    class User < ActiveRecord::Base
      self.pluralize_table_names = false
    end
    ```

* Se agregó la configuración de atributos para asociaciones singulares mediante bloque. El bloque se llamará después de que se inicialice la instancia.

    ```ruby
    class User < ActiveRecord::Base
      has_one :account
    end

    user.build_account{ |a| a.credit_limit = 100.0 }
    ```

* Se agregó `ActiveRecord::Base.attribute_names` para devolver una lista de nombres de atributos. Esto devolverá un array vacío si el modelo es abstracto o la tabla no existe.

* Las fixtures de CSV están en desuso y el soporte se eliminará en Rails 3.2.0.

* `ActiveRecord#new`, `ActiveRecord#create` y `ActiveRecord#update_attributes` ahora aceptan un segundo hash como opción que permite especificar qué rol considerar al asignar atributos. Esto se basa en las nuevas capacidades de asignación masiva de Active Model.
```ruby
class Post < ActiveRecord::Base
  attr_accessible :title
  attr_accessible :title, :published_at, :as => :admin
end

Post.new(params[:post], :as => :admin)
```

* `default_scope` ahora puede tomar un bloque, lambda o cualquier otro objeto que responda a `call` para evaluación perezosa.

* Los alcances predeterminados ahora se evalúan en el último momento posible, para evitar problemas donde se crearían alcances que contienen implícitamente el alcance predeterminado, lo que luego sería imposible de eliminar a través de `Model.unscoped`.

* El adaptador de PostgreSQL solo admite la versión 8.2 y superior de PostgreSQL.

* El middleware `ConnectionManagement` se cambió para limpiar el grupo de conexiones después de que el cuerpo de rack se haya vaciado.

* Se agregó un método `update_column` en Active Record. Este nuevo método actualiza un atributo dado en un objeto, omitiendo validaciones y callbacks. Se recomienda usar `update_attributes` o `update_attribute` a menos que esté seguro de que no desea ejecutar ningún callback, incluida la modificación de la columna `updated_at`. No debe llamarse en registros nuevos.

* Las asociaciones con la opción `:through` ahora pueden usar cualquier asociación como la asociación `through` o `source`, incluidas otras asociaciones que tienen una opción `:through` y asociaciones `has_and_belongs_to_many`.

* La configuración para la conexión actual a la base de datos ahora es accesible a través de `ActiveRecord::Base.connection_config`.

* Los límites y desplazamientos se eliminan de las consultas COUNT a menos que se suministren ambos.

```ruby
People.limit(1).count           # => 'SELECT COUNT(*) FROM people'
People.offset(1).count          # => 'SELECT COUNT(*) FROM people'
People.limit(1).offset(1).count # => 'SELECT COUNT(*) FROM people LIMIT 1 OFFSET 1'
```

* `ActiveRecord::Associations::AssociationProxy` se ha dividido. Ahora hay una clase `Association` (y subclases) que son responsables de operar en las asociaciones, y luego un envoltorio separado y delgado llamado `CollectionProxy`, que actúa como proxy para las asociaciones de colección. Esto evita la contaminación del espacio de nombres, separa las responsabilidades y permitirá refactorizaciones adicionales.

* Las asociaciones singulares (`has_one`, `belongs_to`) ya no tienen un proxy y simplemente devuelven el registro asociado o `nil`. Esto significa que no debe usar métodos no documentados como `bob.mother.create` - en su lugar, use `bob.create_mother`.

* Se admite la opción `:dependent` en las asociaciones `has_many :through`. Por razones históricas y prácticas, `:delete_all` es la estrategia de eliminación predeterminada empleada por `association.delete(*records)`, a pesar de que la estrategia predeterminada es `:nullify` para `has_many` regulares. Además, esto solo funciona si la reflexión de origen es un `belongs_to`. Para otras situaciones, debe modificar directamente la asociación `through`.

* El comportamiento de `association.destroy` para `has_and_belongs_to_many` y `has_many :through` ha cambiado. A partir de ahora, 'destroy' o 'delete' en una asociación se entenderá como 'eliminar el enlace', no (necesariamente) 'eliminar los registros asociados'.

* Anteriormente, `has_and_belongs_to_many.destroy(*records)` destruiría los registros en sí. No eliminaría ningún registro en la tabla de unión. Ahora, elimina los registros en la tabla de unión.

* Anteriormente, `has_many_through.destroy(*records)` destruiría los registros en sí y los registros en la tabla de unión. [Nota: Esto no siempre ha sido así; versiones anteriores de Rails solo eliminaban los registros en sí.] Ahora, solo destruye los registros en la tabla de unión.

* Tenga en cuenta que este cambio es en cierta medida incompatible hacia atrás, pero desafortunadamente no hay forma de 'depreciarlo' antes de cambiarlo. El cambio se está realizando para tener consistencia en cuanto al significado de 'destroy' o 'delete' en los diferentes tipos de asociaciones. Si desea destruir los registros en sí, puede hacer `records.association.each(&:destroy)`.

* Agregue la opción `:bulk => true` a `change_table` para realizar todos los cambios de esquema definidos en un bloque utilizando una sola instrucción ALTER.

```ruby
change_table(:users, :bulk => true) do |t|
  t.string :company_name
  t.change :birthdate, :datetime
end
```

* Se eliminó el soporte para acceder a atributos en una tabla de unión `has_and_belongs_to_many`. Debe usarse `has_many :through`.

* Se agregó un método `create_association!` para las asociaciones `has_one` y `belongs_to`.

* Las migraciones ahora son reversibles, lo que significa que Rails descubrirá cómo revertir sus migraciones. Para usar migraciones reversibles, simplemente defina el método `change`.

```ruby
class MyMigration < ActiveRecord::Migration
  def change
    create_table(:horses) do |t|
      t.column :content, :text
      t.column :remind_at, :datetime
    end
  end
end
```

* Algunas cosas no se pueden revertir automáticamente. Si sabe cómo revertir esas cosas, debe definir `up` y `down` en su migración. Si define algo en `change` que no se puede revertir, se lanzará una excepción `IrreversibleMigration` al retroceder.

* Las migraciones ahora usan métodos de instancia en lugar de métodos de clase:
```ruby
class FooMigration < ActiveRecord::Migration
  def up # No self.up
    # ...
  end
end
```

* Los archivos de migración generados a partir de los generadores de modelo y migración constructiva (por ejemplo, add_name_to_users) utilizan el método `change` de migración reversible en lugar de los métodos `up` y `down` ordinarios.

* Se eliminó el soporte para la interpolación de condiciones de SQL de cadena en las asociaciones. En su lugar, se debe utilizar un proc.

```ruby
has_many :things, :conditions => 'foo = #{bar}'          # antes
has_many :things, :conditions => proc { "foo = #{bar}" } # después
```

Dentro del proc, `self` es el objeto que es el propietario de la asociación, a menos que esté cargando la asociación de forma ansiosa, en cuyo caso `self` es la clase en la que se encuentra la asociación.

Puede tener cualquier condición "normal" dentro del proc, por lo que lo siguiente también funcionará:

```ruby
has_many :things, :conditions => proc { ["foo = ?", bar] }
```

* Anteriormente, `:insert_sql` y `:delete_sql` en la asociación `has_and_belongs_to_many` permitían llamar a 'record' para obtener el registro que se está insertando o eliminando. Ahora se pasa como argumento al proc.

* Se agregó `ActiveRecord::Base#has_secure_password` (a través de `ActiveModel::SecurePassword`) para encapsular el uso de contraseñas muy simple con encriptación y salado BCrypt.

```ruby
# Esquema: User(name:string, password_digest:string, password_salt:string)
class User < ActiveRecord::Base
  has_secure_password
end
```

* Cuando se genera un modelo, se agrega `add_index` de forma predeterminada para las columnas `belongs_to` o `references`.

* Establecer el id de un objeto `belongs_to` actualizará la referencia al objeto.

* Las semánticas de `ActiveRecord::Base#dup` y `ActiveRecord::Base#clone` han cambiado para que se asemejen más a las semánticas normales de dup y clone de Ruby.

* Llamar a `ActiveRecord::Base#clone` resultará en una copia superficial del registro, incluida la copia del estado congelado. No se llamarán callbacks.

* Llamar a `ActiveRecord::Base#dup` duplicará el registro, incluida la llamada a los hooks después de la inicialización. No se copiará el estado congelado y se borrarán todas las asociaciones. Un registro duplicado devolverá `true` para `new_record?`, tendrá un campo de id `nil` y se puede guardar.

* La caché de consultas ahora funciona con declaraciones preparadas. No se requieren cambios en las aplicaciones.

Active Model
------------

* `attr_accessible` acepta una opción `:as` para especificar un rol.

* `InclusionValidator`, `ExclusionValidator` y `FormatValidator` ahora aceptan una opción que puede ser un proc, un lambda o cualquier cosa que responda a `call`. Esta opción se llamará con el registro actual como argumento y devolverá un objeto que responda a `include?` para `InclusionValidator` y `ExclusionValidator`, y devolverá un objeto de expresión regular para `FormatValidator`.

* Se agregó `ActiveModel::SecurePassword` para encapsular el uso de contraseñas muy simple con encriptación y salado BCrypt.

* `ActiveModel::AttributeMethods` permite definir atributos a pedido.

* Se agregó soporte para habilitar y deshabilitar selectivamente los observadores.

* Ya no se admite la búsqueda de espacio de nombres `I18n` alternativo.

Active Resource
---------------

* El formato predeterminado se ha cambiado a JSON para todas las solicitudes. Si desea seguir utilizando XML, deberá establecer `self.format = :xml` en la clase. Por ejemplo,

```ruby
class User < ActiveResource::Base
  self.format = :xml
end
```

Active Support
--------------

* `ActiveSupport::Dependencies` ahora genera una excepción `NameError` si encuentra una constante existente en `load_missing_constant`.

* Se agregó un nuevo método de informe `Kernel#quietly` que silencia tanto `STDOUT` como `STDERR`.

* Se agregó `String#inquiry` como un método de conveniencia para convertir una cadena en un objeto `StringInquirer`.

* Se agregó `Object#in?` para probar si un objeto está incluido en otro objeto.

* La estrategia `LocalCache` ahora es una clase de middleware real y ya no es una clase anónima.

* Se ha introducido la clase `ActiveSupport::Dependencies::ClassCache` para mantener referencias a clases recargables.

* `ActiveSupport::Dependencies::Reference` se ha refactorizado para aprovechar directamente la nueva `ClassCache`.

* Se ha retroportado `Range#cover?` como un alias de `Range#include?` en Ruby 1.8.

* Se agregaron `weeks_ago` y `prev_week` a Date/DateTime/Time.

* Se agregó el callback `before_remove_const` a `ActiveSupport::Dependencies.remove_unloadable_constants!`.

Deprecaciones:

* `ActiveSupport::SecureRandom` está en desuso a favor de `SecureRandom` de la biblioteca estándar de Ruby.

Créditos
-------

Consulte la [lista completa de colaboradores de Rails](https://contributors.rubyonrails.org/) para conocer a las muchas personas que pasaron muchas horas haciendo de Rails el marco estable y robusto que es. Felicitaciones a todos ellos.

Las notas de la versión de Rails 3.1 fueron compiladas por [Vijay Dev](https://github.com/vijaydev)
