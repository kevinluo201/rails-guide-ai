**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: dd2584972aa8eae419ed5d55a287e27d
Notas de lanzamiento de Ruby on Rails 3.0
===========================================

¡Rails 3.0 son ponis y arcoíris! Va a cocinarte la cena y doblarte la ropa. Te preguntarás cómo era posible la vida antes de que llegara. ¡Es la Mejor Versión de Rails que Hemos Hecho!

Pero en serio, es realmente bueno. Hay todas las buenas ideas traídas de cuando el equipo de Merb se unió a la fiesta y trajo un enfoque en la agnosticismo del framework, internos más delgados y rápidos, y un puñado de APIs deliciosas. Si vienes a Rails 3.0 desde Merb 1.x, deberías reconocer muchas cosas. Si vienes de Rails 2.x, también te encantará.

Incluso si no te importa nada de nuestras mejoras internas, Rails 3.0 te va a encantar. Tenemos un montón de nuevas características y APIs mejoradas. Nunca ha sido un mejor momento para ser un desarrollador de Rails. Algunos de los aspectos más destacados son:

* Nuevo enrutador con énfasis en declaraciones RESTful
* Nueva API de Action Mailer modelada según Action Controller (¡ahora sin el dolor agónico de enviar mensajes multipartes!)
* Nuevo lenguaje de consulta encadenable de Active Record construido sobre álgebra relacional
* Ayudantes de JavaScript no intrusivos con controladores para Prototype, jQuery y más por venir (fin del JS en línea)
* Gestión explícita de dependencias con Bundler

Además de todo eso, hemos hecho todo lo posible para deprecar las APIs antiguas con advertencias amigables. Eso significa que puedes mover tu aplicación existente a Rails 3 sin tener que reescribir inmediatamente todo tu código antiguo según las mejores prácticas más recientes.

Estas notas de lanzamiento cubren las actualizaciones principales, pero no incluyen cada pequeña corrección de errores y cambio. ¡Rails 3.0 consta de casi 4,000 commits realizados por más de 250 autores! Si quieres ver todo, echa un vistazo a la [lista de commits](https://github.com/rails/rails/commits/3-0-stable) en el repositorio principal de Rails en GitHub.

--------------------------------------------------------------------------------

Para instalar Rails 3:

```bash
# Usa sudo si tu configuración lo requiere
$ gem install rails
```


Actualización a Rails 3
-----------------------

Si estás actualizando una aplicación existente, es una gran idea tener una buena cobertura de pruebas antes de comenzar. También debes actualizar primero a Rails 2.3.5 y asegurarte de que tu aplicación siga funcionando como se espera antes de intentar actualizar a Rails 3. Luego, ten en cuenta los siguientes cambios:

### Rails 3 requiere al menos Ruby 1.8.7

Rails 3.0 requiere Ruby 1.8.7 o superior. El soporte para todas las versiones anteriores de Ruby se ha eliminado oficialmente y debes actualizar lo antes posible. Rails 3.0 también es compatible con Ruby 1.9.2.

CONSEJO: Ten en cuenta que Ruby 1.8.7 p248 y p249 tienen errores de serialización que hacen que Rails 3.0 se bloquee. Ruby Enterprise Edition los ha solucionado desde la versión 1.8.7-2010.02. En cuanto a la versión 1.9, Ruby 1.9.1 no es utilizable porque se bloquea por completo en Rails 3.0, así que si quieres usar Rails 3 con 1.9.x, utiliza 1.9.2 para un funcionamiento sin problemas.

### Objeto de aplicación de Rails

Como parte del trabajo previo para admitir la ejecución de múltiples aplicaciones de Rails en el mismo proceso, Rails 3 introduce el concepto de un objeto de aplicación. Un objeto de aplicación contiene todas las configuraciones específicas de la aplicación y es muy similar en naturaleza a `config/environment.rb` de las versiones anteriores de Rails.

Cada aplicación de Rails ahora debe tener un objeto de aplicación correspondiente. El objeto de aplicación se define en `config/application.rb`. Si estás actualizando una aplicación existente a Rails 3, debes agregar este archivo y mover las configuraciones correspondientes de `config/environment.rb` a `config/application.rb`.

### script/* reemplazado por script/rails

El nuevo `script/rails` reemplaza todos los scripts que solían estar en el directorio `script`. Sin embargo, no ejecutas `script/rails` directamente, el comando `rails` detecta que se está invocando en la raíz de una aplicación de Rails y ejecuta el script por ti. El uso previsto es:

```bash
$ rails console                      # en lugar de script/console
$ rails g scaffold post title:string # en lugar de script/generate scaffold post title:string
```

Ejecuta `rails --help` para ver una lista de todas las opciones.

### Dependencias y config.gem

El método `config.gem` ha desaparecido y ha sido reemplazado por el uso de `bundler` y un `Gemfile`, consulta [Vendoring Gems](#vendoring-gems) a continuación.

### Proceso de actualización

Para ayudar con el proceso de actualización, se ha creado un complemento llamado [Rails Upgrade](https://github.com/rails/rails_upgrade) para automatizar parte de él.

Simplemente instala el complemento y luego ejecuta `rake rails:upgrade:check` para verificar tu aplicación en busca de piezas que necesiten ser actualizadas (con enlaces a información sobre cómo actualizarlas). También ofrece una tarea para generar un `Gemfile` basado en tus llamadas actuales a `config.gem` y una tarea para generar un nuevo archivo de rutas a partir del actual. Para obtener el complemento, simplemente ejecuta lo siguiente:
```bash
$ ruby script/plugin install git://github.com/rails/rails_upgrade.git
```

Puedes ver un ejemplo de cómo funciona en [Rails Upgrade es ahora un Plugin Oficial](http://omgbloglol.com/post/364624593/rails-upgrade-is-now-an-official-plugin)

Además de la herramienta Rails Upgrade, si necesitas más ayuda, hay personas en IRC y [rubyonrails-talk](https://discuss.rubyonrails.org/c/rubyonrails-talk) que probablemente estén haciendo lo mismo, posiblemente enfrentando los mismos problemas. ¡Asegúrate de compartir tus propias experiencias al actualizar para que otros puedan beneficiarse de tu conocimiento!

Creando una aplicación Rails 3.0
--------------------------------

```bash
# Debes tener instalado el RubyGem 'rails'
$ rails new myapp
$ cd myapp
```

### Vendiendo Gems

Rails ahora utiliza un `Gemfile` en la raíz de la aplicación para determinar las gemas que necesitas para que tu aplicación se inicie. Este `Gemfile` es procesado por [Bundler](https://github.com/bundler/bundler), que luego instala todas tus dependencias. Incluso puede instalar todas las dependencias localmente en tu aplicación para que no dependa de las gemas del sistema.

Más información: - [Página principal de Bundler](https://bundler.io/)

### Viviendo al Límite

`Bundler` y `Gemfile` hacen que congelar tu aplicación Rails sea pan comido con el nuevo comando `bundle`, por lo que `rake freeze` ya no es relevante y se ha eliminado.

Si quieres agrupar directamente desde el repositorio Git, puedes pasar la bandera `--edge`:

```bash
$ rails new myapp --edge
```

Si tienes una copia local del repositorio de Rails y quieres generar una aplicación usando eso, puedes pasar la bandera `--dev`:

```bash
$ ruby /path/to/rails/bin/rails new myapp --dev
```

Cambios arquitectónicos en Rails
---------------------------

Hay seis cambios importantes en la arquitectura de Rails.

### Railties restringido

Railties se actualizó para proporcionar una API de plugin consistente para todo el framework de Rails, así como una reescritura total de los generadores y las conexiones de Rails. El resultado es que los desarrolladores ahora pueden conectarse a cualquier etapa importante de los generadores y el framework de la aplicación de manera consistente y definida.

### Todos los componentes principales de Rails están desacoplados

Con la fusión de Merb y Rails, uno de los grandes trabajos fue eliminar el acoplamiento estrecho entre los componentes principales de Rails. Esto se ha logrado y todos los componentes principales de Rails ahora utilizan la misma API que puedes usar para desarrollar plugins. Esto significa que cualquier plugin que hagas, o cualquier reemplazo de componente principal (como DataMapper o Sequel) puede acceder a toda la funcionalidad a la que los componentes principales de Rails tienen acceso y extender y mejorar a voluntad.

Más información: - [La Gran Desconexión](http://yehudakatz.com/2009/07/19/rails-3-the-great-decoupling/)

### Abstracción de Active Model

Parte del desacoplamiento de los componentes principales fue extraer todos los vínculos a Active Record de Action Pack. Esto se ha completado ahora. Todos los nuevos plugins ORM ahora solo necesitan implementar las interfaces de Active Model para funcionar sin problemas con Action Pack.

Más información: - [Haz que cualquier objeto Ruby se sienta como ActiveRecord](http://yehudakatz.com/2010/01/10/activemodel-make-any-ruby-object-feel-like-activerecord/)

### Abstracción de controlador

Otra gran parte del desacoplamiento de los componentes principales fue crear una superclase base separada de las nociones de HTTP para manejar la representación de vistas, etc. Esta creación de `AbstractController` permitió simplificar en gran medida `ActionController` y `ActionMailer` con código común eliminado de todas estas bibliotecas y colocado en Abstract Controller.

Más información: - [Arquitectura de Rails Edge](http://yehudakatz.com/2009/06/11/rails-edge-architecture/)

### Integración de Arel

[Arel](https://github.com/brynary/arel) (o Active Relation) se ha adoptado como base de Active Record y ahora es necesario para Rails. Arel proporciona una abstracción de SQL que simplifica Active Record y proporciona los fundamentos para la funcionalidad de relación en Active Record.

Más información: - [Por qué escribí Arel](https://web.archive.org/web/20120718093140/http://magicscalingsprinkles.wordpress.com/2010/01/28/why-i-wrote-arel/)

### Extracción de correo

Action Mailer desde sus inicios ha tenido parches, pre-analizadores e incluso agentes de entrega y recepción, además de tener TMail vendido en el árbol de origen. La versión 3 cambia eso con toda la funcionalidad relacionada con el mensaje de correo electrónico abstraída a la gema [Mail](https://github.com/mikel/mail). Esto reduce nuevamente la duplicación de código y ayuda a crear límites definidos entre Action Mailer y el analizador de correo electrónico.

Más información: - [Nueva API de Action Mailer en Rails 3](http://lindsaar.net/2010/1/26/new-actionmailer-api-in-rails-3)

Documentación
-------------

La documentación en el árbol de Rails se está actualizando con todos los cambios de API, además, las [Rails Edge Guides](https://edgeguides.rubyonrails.org/) se están actualizando una por una para reflejar los cambios en Rails 3.0. Sin embargo, las guías en [guides.rubyonrails.org](https://guides.rubyonrails.org/) seguirán conteniendo solo la versión estable de Rails (en este momento, la versión 2.3.5, hasta que se lance la versión 3.0).

Más información: - [Proyectos de documentación de Rails](https://weblog.rubyonrails.org/2009/1/15/rails-documentation-projects)
Internacionalización
--------------------

Se ha realizado una gran cantidad de trabajo con el soporte de I18n en Rails 3, incluyendo la última gema [I18n](https://github.com/svenfuchs/i18n) que proporciona muchas mejoras de velocidad.

* I18n para cualquier objeto: el comportamiento de I18n se puede agregar a cualquier objeto incluyendo `ActiveModel::Translation` y `ActiveModel::Validations`. También hay un fallback `errors.messages` para las traducciones.
* Los atributos pueden tener traducciones predeterminadas.
* Las etiquetas de envío de formularios automáticamente obtienen el estado correcto (Crear o Actualizar) dependiendo del estado del objeto, y así obtienen la traducción correcta.
* Las etiquetas con I18n ahora también funcionan simplemente pasando el nombre del atributo.

Más información: - [Cambios de I18n en Rails 3](http://blog.plataformatec.com.br/2010/02/rails-3-i18n-changes/)


Railties
--------

Con la separación de los principales frameworks de Rails, Railties ha sufrido una gran revisión para facilitar y extender la vinculación de frameworks, motores o complementos:

* Cada aplicación ahora tiene su propio espacio de nombres, la aplicación se inicia con `YourAppName.boot`, por ejemplo, lo que facilita la interacción con otras aplicaciones.
* Todo lo que se encuentra en `Rails.root/app` ahora se agrega al path de carga, por lo que puedes crear `app/observers/user_observer.rb` y Rails lo cargará sin ninguna modificación.
* Rails 3.0 ahora proporciona un objeto `Rails.config`, que es un repositorio central de todo tipo de opciones de configuración de Rails.

La generación de aplicaciones ha recibido banderas adicionales que te permiten omitir la instalación de test-unit, Active Record, Prototype y Git. También se ha agregado una nueva bandera `--dev` que configura la aplicación con el `Gemfile` apuntando a tu checkout de Rails (que se determina por la ruta al binario `rails`). Consulta `rails --help` para obtener más información.

Los generadores de Railties han recibido una gran cantidad de atención en Rails 3.0, básicamente:

* Los generadores se reescribieron por completo y no son compatibles con versiones anteriores.
* La API de plantillas de Rails y la API de generadores se fusionaron (son lo mismo que antes).
* Los generadores ya no se cargan desde rutas especiales, simplemente se encuentran en el path de carga de Ruby, por lo que llamar a `rails generate foo` buscará `generators/foo_generator`.
* Los nuevos generadores proporcionan hooks, por lo que cualquier motor de plantillas, ORM o framework de pruebas puede engancharse fácilmente.
* Los nuevos generadores te permiten anular las plantillas colocando una copia en `Rails.root/lib/templates`.
* También se proporciona `Rails::Generators::TestCase` para que puedas crear tus propios generadores y probarlos.

Además, las vistas generadas por los generadores de Railties han tenido algunas mejoras:

* Las vistas ahora usan etiquetas `div` en lugar de etiquetas `p`.
* Los andamios generados ahora utilizan parciales `_form`, en lugar de código duplicado en las vistas de edición y nuevas.
* Los formularios de andamios ahora utilizan `f.submit`, que devuelve "Crear ModelName" o "Actualizar ModelName" dependiendo del estado del objeto pasado.

Finalmente, se agregaron algunas mejoras a las tareas de rake:

* Se agregó `rake db:forward`, que te permite avanzar tus migraciones individualmente o en grupos.
* Se agregó `rake routes CONTROLLER=x`, que te permite ver solo las rutas de un controlador.

Railties ahora deprecia:

* `RAILS_ROOT` en favor de `Rails.root`,
* `RAILS_ENV` en favor de `Rails.env`, y
* `RAILS_DEFAULT_LOGGER` en favor de `Rails.logger`.

`PLUGIN/rails/tasks` y `PLUGIN/tasks` ya no se cargan, todas las tareas ahora deben estar en `PLUGIN/lib/tasks`.

Más información:

* [Descubriendo los generadores de Rails 3](http://blog.plataformatec.com.br/2010/01/discovering-rails-3-generators)
* [El módulo Rails (en Rails 3)](http://quaran.to/blog/2010/02/03/the-rails-module/)

Action Pack
-----------

Ha habido cambios significativos internos y externos en Action Pack.


### Controlador Abstracto

El Controlador Abstracto extrae las partes genéricas de Action Controller en un módulo reutilizable que cualquier biblioteca puede usar para renderizar plantillas, renderizar parciales, ayudantes, traducciones, registro, cualquier parte del ciclo de solicitud-respuesta. Esta abstracción permitió que `ActionMailer::Base` ahora solo herede de `AbstractController` y envuelva la DSL de Rails en la gema Mail.

También brindó la oportunidad de limpiar Action Controller, abstrayendo lo que se pudo para simplificar el código.

Sin embargo, hay que tener en cuenta que el Controlador Abstracto no es una API orientada al usuario, no te encontrarás con él en el uso diario de Rails.

Más información: - [Arquitectura de Rails Edge](http://yehudakatz.com/2009/06/11/rails-edge-architecture/)


### Action Controller

* `application_controller.rb` ahora tiene `protect_from_forgery` activado de forma predeterminada.
* El `cookie_verifier_secret` ha sido deprecado y ahora se asigna a través de `Rails.application.config.cookie_secret` y se ha movido a su propio archivo: `config/initializers/cookie_verification_secret.rb`.
* La configuración de `session_store` en `ActionController::Base.session` ahora se ha movido a `Rails.application.config.session_store`. Las configuraciones predeterminadas se establecen en `config/initializers/session_store.rb`.
* `cookies.secure` te permite establecer valores encriptados en las cookies con `cookie.secure[:key] => value`.
* `cookies.permanent` te permite establecer valores permanentes en el hash de cookies `cookie.permanent[:key] => value` que generan excepciones en valores firmados si hay fallos de verificación.
* Ahora puedes pasar `:notice => 'Este es un mensaje flash'` o `:alert => 'Algo salió mal'` a la llamada `format` dentro de un bloque `respond_to`. El hash `flash[]` sigue funcionando como antes.
* Se ha agregado el método `respond_with` a tus controladores, lo que simplifica los venerables bloques `format`.
* Se ha agregado `ActionController::Responder`, lo que te permite flexibilidad en cómo se generan tus respuestas.
Deprecaciones:

* `filter_parameter_logging` está obsoleto a favor de `config.filter_parameters << :password`.

Más información:

* [Opciones de renderizado en Rails 3](https://blog.engineyard.com/2010/render-options-in-rails-3)
* [Tres razones para amar ActionController::Responder](https://weblog.rubyonrails.org/2009/8/31/three-reasons-love-responder)


### Action Dispatch

Action Dispatch es nuevo en Rails 3.0 y proporciona una nueva implementación más limpia para el enrutamiento.

* Gran limpieza y reescritura del enrutador, el enrutador de Rails ahora es `rack_mount` con un DSL de Rails encima, es una pieza de software independiente.
* Las rutas definidas por cada aplicación ahora están en el espacio de nombres de su módulo de aplicación, es decir:

    ```ruby
    # En lugar de:

    ActionController::Routing::Routes.draw do |map|
      map.resources :posts
    end

    # Haces:

    AppName::Application.routes do
      resources :posts
    end
    ```

* Se agregó el método `match` al enrutador, también puedes pasar cualquier aplicación Rack a la ruta coincidente.
* Se agregó el método `constraints` al enrutador, lo que te permite proteger las rutas con restricciones definidas.
* Se agregó el método `scope` al enrutador, lo que te permite crear espacios de nombres para rutas en diferentes idiomas o acciones diferentes, por ejemplo:

    ```ruby
    scope 'es' do
      resources :projects, :path_names => { :edit => 'cambiar' }, :path => 'proyecto'
    end

    # Te da la acción de edición con /es/proyecto/1/cambiar
    ```

* Se agregó el método `root` al enrutador como un atajo para `match '/', :to => path`.
* Puedes pasar segmentos opcionales a la coincidencia, por ejemplo `match "/:controller(/:action(/:id))(.:format)"`, cada segmento entre paréntesis es opcional.
* Las rutas se pueden expresar mediante bloques, por ejemplo puedes llamar a `controller :home { match '/:action' }`.

NOTA. Los comandos de estilo antiguo `map` todavía funcionan como antes con una capa de compatibilidad hacia atrás, sin embargo, esto se eliminará en la versión 3.1.

Deprecaciones

* La ruta de captura para aplicaciones no REST (`/:controller/:action/:id`) ahora está comentada.
* Las rutas `:path_prefix` ya no existen y `:name_prefix` ahora agrega automáticamente "_" al final del valor dado.

Más información:
* [El enrutador de Rails 3: Rack it Up](http://yehudakatz.com/2009/12/26/the-rails-3-router-rack-it-up/)
* [Rutas renovadas en Rails 3](https://medium.com/fusion-of-thoughts/revamped-routes-in-rails-3-b6d00654e5b0)
* [Acciones genéricas en Rails 3](http://yehudakatz.com/2009/12/20/generic-actions-in-rails-3/)


### Action View

#### JavaScript no intrusivo

Se realizó una importante reescritura en los ayudantes de Action View, implementando ganchos de JavaScript no intrusivos (UJS) y eliminando los antiguos comandos AJAX en línea. Esto permite que Rails use cualquier controlador UJS compatible para implementar los ganchos UJS en los ayudantes.

Esto significa que todos los ayudantes anteriores `remote_<method>` se han eliminado del núcleo de Rails y se han colocado en [Prototype Legacy Helper](https://github.com/rails/prototype_legacy_helper). Para obtener ganchos UJS en tu HTML, ahora pasas `:remote => true` en su lugar. Por ejemplo:

```ruby
form_for @post, :remote => true
```

Produce:

```html
<form action="http://host.com" id="create-post" method="post" data-remote="true">
```

#### Ayudantes con bloques

Los ayudantes como `form_for` o `div_for` que insertan contenido desde un bloque ahora usan `<%=`:

```html+erb
<%= form_for @post do |f| %>
  ...
<% end %>
```

Se espera que tus propios ayudantes de ese tipo devuelvan una cadena, en lugar de agregar al búfer de salida manualmente.

Los ayudantes que hacen algo diferente, como `cache` o `content_for`, no se ven afectados por este cambio, todavía necesitan `&lt;%` como antes.

#### Otros cambios

* Ya no es necesario llamar a `h(string)` para escapar la salida HTML, ahora está activado de forma predeterminada en todas las plantillas de vista. Si quieres la cadena sin escapar, llama a `raw(string)`.
* Los ayudantes ahora generan HTML5 de forma predeterminada.
* El ayudante de etiqueta de formulario ahora obtiene los valores de I18n con un solo valor, por lo que `f.label :name` obtendrá la traducción de `:name`.
* La etiqueta de selección de I18n ahora debería ser :en.helpers.select en lugar de :en.support.select.
* Ya no es necesario colocar un signo menos al final de una interpolación de Ruby dentro de una plantilla ERB para eliminar el retorno de carro final en la salida HTML.
* Se agregó el ayudante `grouped_collection_select` a Action View.
* Se agregó `content_for?` que te permite verificar la existencia de contenido en una vista antes de renderizar.
* pasar `:value => nil` a los ayudantes de formulario establecerá el atributo `value` del campo en nil en lugar de usar el valor predeterminado
* pasar `:id => nil` a los ayudantes de formulario hará que esos campos se rendericen sin el atributo `id`
* pasar `:alt => nil` a `image_tag` hará que la etiqueta `img` se renderice sin el atributo `alt`

Active Model
------------

Active Model es nuevo en Rails 3.0. Proporciona una capa de abstracción para que las bibliotecas ORM interactúen con Rails mediante la implementación de una interfaz de Active Model.
### Abstracción ORM e Interfaz Action Pack

Parte de la desvinculación de los componentes principales fue extraer todos los vínculos con Active Record de Action Pack. Esto ya se ha completado. Todos los nuevos complementos ORM ahora solo necesitan implementar interfaces de Active Model para funcionar perfectamente con Action Pack.

Más información: - [Haz que cualquier objeto Ruby se sienta como ActiveRecord](http://yehudakatz.com/2010/01/10/activemodel-make-any-ruby-object-feel-like-activerecord/)


### Validaciones

Las validaciones se han movido de Active Record a Active Model, proporcionando una interfaz para validaciones que funciona en todas las bibliotecas ORM en Rails 3.

* Ahora hay un método abreviado `validates :atributo, options_hash` que te permite pasar opciones para todos los métodos de clase de validación, puedes pasar más de una opción a un método de validación.
* El método `validates` tiene las siguientes opciones:
    * `:acceptance => Booleano`.
    * `:confirmation => Booleano`.
    * `:exclusion => { :in => Enumerable }`.
    * `:inclusion => { :in => Enumerable }`.
    * `:format => { :with => Expresión regular, :on => :create }`.
    * `:length => { :maximum => Fixnum }`.
    * `:numericality => Booleano`.
    * `:presence => Booleano`.
    * `:uniqueness => Booleano`.

NOTA: Todos los métodos de validación de estilo de Rails versión 2.3 aún son compatibles en Rails 3.0, el nuevo método validates está diseñado como una ayuda adicional en las validaciones de tu modelo, no como un reemplazo de la API existente.

También puedes pasar un objeto validador, que luego puedes reutilizar entre objetos que usan Active Model:

```ruby
class TitleValidator < ActiveModel::EachValidator
  Titles = ['Sr.', 'Sra.', 'Dr.']
  def validate_each(record, attribute, value)
    unless Titles.include?(value)
      record.errors[attribute] << 'debe ser un título válido'
    end
  end
end
```

```ruby
class Person
  include ActiveModel::Validations
  attr_accessor :title
  validates :title, :presence => true, :title => true
end

# O para Active Record

class Person < ActiveRecord::Base
  validates :title, :presence => true, :title => true
end
```

También hay soporte para la introspección:

```ruby
User.validators
User.validators_on(:login)
```

Más información:

* [Validaciones sexys en Rails 3](http://thelucid.com/2010/01/08/sexy-validation-in-edge-rails-rails-3/)
* [Explicación de las validaciones en Rails 3](http://lindsaar.net/2010/1/31/validates_rails_3_awesome_is_true)


Active Record
-------------

Active Record recibió mucha atención en Rails 3.0, incluyendo la abstracción en Active Model, una actualización completa de la interfaz de consulta utilizando Arel, actualizaciones de validación y muchas mejoras y correcciones. Toda la API de Rails 2.x se podrá utilizar a través de una capa de compatibilidad que se mantendrá hasta la versión 3.1.


### Interfaz de consulta

Active Record, a través del uso de Arel, ahora devuelve relaciones en sus métodos principales. La API existente en Rails 2.3.x aún es compatible y no se deprecia hasta Rails 3.1 y no se elimina hasta Rails 3.2, sin embargo, la nueva API proporciona los siguientes nuevos métodos que devuelven relaciones que se pueden encadenar:

* `where` - proporciona condiciones en la relación, lo que se devuelve.
* `select` - elige qué atributos de los modelos deseas que se devuelvan de la base de datos.
* `group` - agrupa la relación en el atributo suministrado.
* `having` - proporciona una expresión que limita las relaciones de grupo (restricción GROUP BY).
* `joins` - une la relación a otra tabla.
* `clause` - proporciona una expresión que limita las relaciones de unión (restricción JOIN).
* `includes` - incluye otras relaciones precargadas.
* `order` - ordena la relación según la expresión suministrada.
* `limit` - limita la relación al número de registros especificado.
* `lock` - bloquea los registros devueltos de la tabla.
* `readonly` - devuelve una copia de solo lectura de los datos.
* `from` - proporciona una forma de seleccionar relaciones de más de una tabla.
* `scope` - (anteriormente `named_scope`) devuelve relaciones y se pueden encadenar con los demás métodos de relación.
* `with_scope` - y `with_exclusive_scope` ahora también devuelven relaciones y se pueden encadenar.
* `default_scope` - también funciona con relaciones.

Más información:

* [Interfaz de consulta de Active Record](http://m.onkey.org/2010/1/22/active-record-query-interface)
* [Deja que tu SQL gruña en Rails 3](http://hasmanyquestions.wordpress.com/2010/01/17/let-your-sql-growl-in-rails-3/)


### Mejoras

* Se agregó `:destroyed?` a los objetos de Active Record.
* Se agregó `:inverse_of` a las asociaciones de Active Record, lo que te permite obtener la instancia de una asociación ya cargada sin consultar la base de datos.


### Parches y deprecaciones

Además, se realizaron muchas correcciones en la rama de Active Record:

* Se eliminó el soporte de SQLite 2 a favor de SQLite 3.
* Soporte de MySQL para el orden de columnas.
* Se corrigió el soporte de `TIME ZONE` del adaptador de PostgreSQL para que ya no inserte valores incorrectos.
* Soporte para múltiples esquemas en nombres de tablas para PostgreSQL.
* Soporte de PostgreSQL para la columna de tipo de datos XML.
* `table_name` ahora se almacena en caché.
* También se realizó una gran cantidad de trabajo en el adaptador de Oracle con muchas correcciones de errores.
Además de las siguientes deprecaciones:

* `named_scope` en una clase Active Record está obsoleto y ha sido renombrado a `scope`.
* En los métodos `scope`, debes usar los métodos de relación en lugar de un método de búsqueda `:conditions => {}`, por ejemplo `scope :since, lambda {|time| where("created_at > ?", time) }`.
* `save(false)` está obsoleto, en favor de `save(:validate => false)`.
* Los mensajes de error de I18n para Active Record deben cambiarse de :en.activerecord.errors.template a `:en.errors.template`.
* `model.errors.on` está obsoleto, en favor de `model.errors[]`
* validates_presence_of => validates... :presence => true
* `ActiveRecord::Base.colorize_logging` y `config.active_record.colorize_logging` están obsoletos, en favor de `Rails::LogSubscriber.colorize_logging` o `config.colorize_logging`

NOTA: Aunque una implementación de State Machine ha estado en Active Record durante algunos meses, se ha eliminado de la versión 3.0 de Rails.


Active Resource
---------------

Active Resource también se extrajo a Active Model, lo que te permite usar objetos de Active Resource con Action Pack sin problemas.

* Se agregaron validaciones a través de Active Model.
* Se agregaron ganchos de observación.
* Soporte para proxy HTTP.
* Se agregó soporte para autenticación digest.
* Se movió el nombre del modelo a Active Model.
* Se cambiaron los atributos de Active Resource a un Hash con acceso indiferente.
* Se agregaron alias `first`, `last` y `all` para los ámbitos de búsqueda equivalentes.
* `find_every` ahora no devuelve un error `ResourceNotFound` si no se encuentra nada.
* Se agregó `save!` que genera un error `ResourceInvalid` a menos que el objeto sea `valido?`.
* Se agregaron `update_attribute` y `update_attributes` a los modelos de Active Resource.
* Se agregó `exists?`.
* Se renombró `SchemaDefinition` a `Schema` y `define_schema` a `schema`.
* Usa el `formato` de Active Resources en lugar del `content-type` de los errores remotos para cargar los errores.
* Usa `instance_eval` para el bloque de esquema.
* Corrige `ActiveResource::ConnectionError#to_s` cuando `@response` no responde a #code o #message, maneja la compatibilidad con Ruby 1.9.
* Agrega soporte para errores en formato JSON.
* Asegura que `load` funcione con matrices numéricas.
* Reconoce una respuesta 410 del recurso remoto como que el recurso ha sido eliminado.
* Agrega la capacidad de establecer opciones SSL en las conexiones de Active Resource.
* Establecer el tiempo de espera de la conexión también afecta a `Net::HTTP` `open_timeout`.

Deprecaciones:

* `save(false)` está obsoleto, en favor de `save(:validate => false)`.
* Ruby 1.9.2: `URI.parse` y `.decode` están obsoletos y ya no se utilizan en la biblioteca.


Active Support
--------------

Se hizo un gran esfuerzo en Active Support para hacerlo seleccionable, es decir, ya no es necesario requerir toda la biblioteca de Active Support para obtener partes de ella. Esto permite que los diversos componentes principales de Rails se ejecuten de forma más ligera.

Estos son los principales cambios en Active Support:

* Gran limpieza de la biblioteca eliminando métodos no utilizados en todo.
* Active Support ya no proporciona versiones vendidas de TZInfo, Memcache Client y Builder. Todos estos se incluyen como dependencias e se instalan a través del comando `bundle install`.
* Se implementan buffers seguros en `ActiveSupport::SafeBuffer`.
* Se agregan `Array.uniq_by` y `Array.uniq_by!`.
* Se eliminan `Array#rand` y se retrotrae `Array#sample` de Ruby 1.9.
* Se soluciona un error en `TimeZone.seconds_to_utc_offset` que devuelve un valor incorrecto.
* Se agrega middleware `ActiveSupport::Notifications`.
* `ActiveSupport.use_standard_json_time_format` ahora tiene el valor predeterminado en true.
* `ActiveSupport.escape_html_entities_in_json` ahora tiene el valor predeterminado en false.
* `Integer#multiple_of?` acepta cero como argumento, devuelve false a menos que el receptor sea cero.
* `string.chars` se ha renombrado a `string.mb_chars`.
* `ActiveSupport::OrderedHash` ahora puede deserializarse a través de YAML.
* Se agrega un analizador basado en SAX para XmlMini, utilizando LibXML y Nokogiri.
* Se agrega `Object#presence` que devuelve el objeto si es `#present?` de lo contrario devuelve `nil`.
* Se agrega la extensión principal `String#exclude?` que devuelve el inverso de `#include?`.
* Se agrega `to_i` a `DateTime` en `ActiveSupport` para que `to_yaml` funcione correctamente en modelos con atributos `DateTime`.
* Se agrega `Enumerable#exclude?` para igualar `Enumerable#include?` y evitar `!x.include?`.
* Cambio a escape de XSS activado por defecto para rails.
* Soporte para combinación profunda en `ActiveSupport::HashWithIndifferentAccess`.
* `Enumerable#sum` ahora funciona con todos los enumerables, incluso si no responden a `:size`.
* `inspect` en una duración de longitud cero devuelve '0 segundos' en lugar de una cadena vacía.
* Agrega `element` y `collection` a `ModelName`.
* `String#to_time` y `String#to_datetime` manejan segundos fraccionarios.
* Se agrega soporte para nuevos callbacks para el objeto de filtro alrededor que responde a `:before` y `:after` utilizados en callbacks antes y después.
* El método `ActiveSupport::OrderedHash#to_a` devuelve un conjunto ordenado de matrices. Coincide con `Hash#to_a` de Ruby 1.9.
* `MissingSourceFile` existe como una constante pero ahora es igual a `LoadError`.
* Se agrega `Class#class_attribute`, para poder declarar un atributo de nivel de clase cuyo valor es heredable y sobrescribible por las subclases.
* Finalmente se eliminó `DeprecatedCallbacks` en `ActiveRecord::Associations`.
* `Object#metaclass` ahora es `Kernel#singleton_class` para coincidir con Ruby.
Los siguientes métodos han sido eliminados porque ahora están disponibles en Ruby 1.8.7 y 1.9.

* `Integer#even?` y `Integer#odd?`
* `String#each_char`
* `String#start_with?` y `String#end_with?` (se mantienen los alias en tercera persona)
* `String#bytesize`
* `Object#tap`
* `Symbol#to_proc`
* `Object#instance_variable_defined?`
* `Enumerable#none?`

El parche de seguridad para REXML permanece en Active Support porque las primeras versiones de Ruby 1.8.7 aún lo necesitan. Active Support sabe si debe aplicarlo o no.

Los siguientes métodos han sido eliminados porque ya no se utilizan en el framework:

* `Kernel#daemonize`
* `Object#remove_subclasses_of` `Object#extend_with_included_modules_from`, `Object#extended_by`
* `Class#remove_class`
* `Regexp#number_of_captures`, `Regexp.unoptionalize`, `Regexp.optionalize`, `Regexp#number_of_captures`


Action Mailer
-------------

Action Mailer ha recibido una nueva API con TMail siendo reemplazado por la nueva [Mail](https://github.com/mikel/mail) como la biblioteca de correo electrónico. Action Mailer en sí ha sido completamente reescrito con prácticamente cada línea de código modificada. El resultado es que Action Mailer ahora simplemente hereda de Abstract Controller y envuelve la gema Mail en un DSL de Rails. Esto reduce considerablemente la cantidad de código y duplicación de otras bibliotecas en Action Mailer.

* Todos los mailers ahora están en `app/mailers` por defecto.
* Ahora se puede enviar correo electrónico utilizando la nueva API con tres métodos: `attachments`, `headers` y `mail`.
* Action Mailer ahora tiene soporte nativo para adjuntos en línea utilizando el método `attachments.inline`.
* Los métodos de envío de correo electrónico de Action Mailer ahora devuelven objetos `Mail::Message`, que luego pueden enviar el mensaje `deliver` para enviarse a sí mismos.
* Todos los métodos de envío se abstraen ahora en la gema Mail.
* El método de envío de correo puede aceptar un hash de todos los campos de encabezado de correo válidos con su par de valores.
* El método de envío `mail` actúa de manera similar a `respond_to` de Action Controller, y se pueden renderizar plantillas de forma explícita o implícita. Action Mailer convertirá el correo electrónico en un correo electrónico multipartes según sea necesario.
* Se puede pasar un proc a las llamadas `format.mime_type` dentro del bloque de correo y renderizar explícitamente tipos específicos de texto, o agregar diseños o plantillas diferentes. La llamada `render` dentro del proc es de Abstract Controller y admite las mismas opciones.
* Las pruebas unitarias de correo electrónico se han movido a pruebas funcionales.
* Action Mailer ahora delega toda la codificación automática de campos de encabezado y cuerpos a la gema Mail.
* Action Mailer codificará automáticamente los cuerpos y encabezados de correo electrónico por usted.

Deprecaciones:

* `:charset`, `:content_type`, `:mime_version`, `:implicit_parts_order` están todos deprecados a favor de declaraciones de estilo `ActionMailer.default :key => value`.
* Los métodos dinámicos `create_method_name` y `deliver_method_name` de Mailer están deprecados, simplemente llame a `method_name` que ahora devuelve un objeto `Mail::Message`.
* `ActionMailer.deliver(message)` está deprecado, simplemente llame a `message.deliver`.
* `template_root` está deprecado, pase opciones a una llamada de render dentro de un proc desde el método `format.mime_type` dentro del bloque de generación de `mail`.
* El método `body` para definir variables de instancia está deprecado (`body {:ivar => value}`), simplemente declare las variables de instancia directamente en el método y estarán disponibles en la vista.
* Está deprecado que los mailers estén en `app/models`, en su lugar use `app/mailers`.

Más información:

* [Nueva API de Action Mailer en Rails 3](http://lindsaar.net/2010/1/26/new-actionmailer-api-in-rails-3)
* [Nueva gema Mail para Ruby](http://lindsaar.net/2010/1/23/mail-gem-version-2-released)


Créditos
-------

Consulte la [lista completa de contribuyentes a Rails](https://contributors.rubyonrails.org/) para conocer a las muchas personas que pasaron muchas horas haciendo Rails 3. Felicitaciones a todos ellos.

Las Notas de la Versión 3.0 de Rails fueron compiladas por [Mikel Lindsaar](http://lindsaar.net).
