**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 77b47af4826df984dead9f6263cfd135
Notas de lanzamiento de Ruby on Rails 2.3
==========================================

Rails 2.3 ofrece una variedad de características nuevas y mejoradas, incluyendo una integración generalizada de Rack, soporte renovado para Rails Engines, transacciones anidadas para Active Record, ámbitos dinámicos y predeterminados, renderizado unificado, enrutamiento más eficiente, plantillas de aplicación y trazas de error silenciosas. Esta lista cubre las actualizaciones principales, pero no incluye cada pequeña corrección de errores y cambio. Si quieres ver todo, revisa la [lista de commits](https://github.com/rails/rails/commits/2-3-stable) en el repositorio principal de Rails en GitHub o revisa los archivos `CHANGELOG` de los componentes individuales de Rails.

--------------------------------------------------------------------------------

Arquitectura de la aplicación
----------------------------

Hay dos cambios importantes en la arquitectura de las aplicaciones de Rails: la integración completa de la interfaz del servidor web modular [Rack](https://rack.github.io/) y el soporte renovado para Rails Engines.

### Integración de Rack

Rails ha dejado atrás su pasado con CGI y ahora utiliza Rack en todas partes. Esto requirió y resultó en una gran cantidad de cambios internos (pero si usas CGI, no te preocupes; Rails ahora admite CGI a través de una interfaz de proxy). Aún así, este es un cambio importante en los componentes internos de Rails. Después de actualizar a la versión 2.3, debes probar en tu entorno local y en tu entorno de producción. Algunas cosas para probar:

* Sesiones
* Cookies
* Cargas de archivos
* APIs JSON/XML

Aquí tienes un resumen de los cambios relacionados con Rack:

* `script/server` ahora utiliza Rack, lo que significa que es compatible con cualquier servidor compatible con Rack. `script/server` también buscará un archivo de configuración de rackup si existe. De forma predeterminada, buscará un archivo `config.ru`, pero puedes cambiar esto con el interruptor `-c`.
* El controlador FCGI pasa por Rack.
* `ActionController::Dispatcher` mantiene su propia pila de middleware predeterminada. Los middlewares se pueden inyectar, reordenar y eliminar. La pila se compila en una cadena al iniciar. Puedes configurar la pila de middleware en `environment.rb`.
* Se ha agregado la tarea `rake middleware` para inspeccionar la pila de middleware. Esto es útil para depurar el orden de la pila de middleware.
* El ejecutor de pruebas de integración se ha modificado para ejecutar toda la pila de middleware y aplicación. Esto hace que las pruebas de integración sean perfectas para probar middlewares de Rack.
* `ActionController::CGIHandler` es un envoltorio CGI compatible con versiones anteriores alrededor de Rack. El `CGIHandler` está diseñado para tomar un objeto CGI antiguo y convertir su información de entorno en una forma compatible con Rack.
* Se han eliminado `CgiRequest` y `CgiResponse`.
* Las tiendas de sesiones ahora se cargan de forma diferida. Si nunca accedes al objeto de sesión durante una solicitud, nunca intentará cargar los datos de sesión (analizar la cookie, cargar los datos de memcache o buscar un objeto Active Record).
* Ya no es necesario usar `CGI::Cookie.new` en tus pruebas para establecer un valor de cookie. Asignar un valor de tipo `String` a `request.cookies["foo"]` ahora establece la cookie como se espera.
* `CGI::Session::CookieStore` ha sido reemplazado por `ActionController::Session::CookieStore`.
* `CGI::Session::MemCacheStore` ha sido reemplazado por `ActionController::Session::MemCacheStore`.
* `CGI::Session::ActiveRecordStore` ha sido reemplazado por `ActiveRecord::SessionStore`.
* Aún puedes cambiar la tienda de sesiones con `ActionController::Base.session_store = :active_record_store`.
* Las opciones predeterminadas de las sesiones aún se establecen con `ActionController::Base.session = { :key => "..." }`. Sin embargo, la opción `:session_domain` ha sido renombrada a `:domain`.
* El mutex que normalmente envuelve toda tu solicitud se ha movido a un middleware, `ActionController::Lock`.
* `ActionController::AbstractRequest` y `ActionController::Request` se han unificado. El nuevo `ActionController::Request` hereda de `Rack::Request`. Esto afecta el acceso a `response.headers['type']` en las solicitudes de prueba. Usa `response.content_type` en su lugar.
* El middleware `ActiveRecord::QueryCache` se inserta automáticamente en la pila de middleware si se ha cargado `ActiveRecord`. Este middleware configura y vacía la caché de consultas de Active Record por solicitud.
* El enrutador y las clases de controlador de Rails siguen la especificación de Rack. Puedes llamar a un controlador directamente con `SomeController.call(env)`. El enrutador almacena los parámetros de enrutamiento en `rack.routing_args`.
* `ActionController::Request` hereda de `Rack::Request`.
* En lugar de `config.action_controller.session = { :session_key => 'foo', ...` usa `config.action_controller.session = { :key => 'foo', ...`.
* El uso del middleware `ParamsParser` preprocesa cualquier solicitud XML, JSON o YAML para que se puedan leer normalmente con cualquier objeto `Rack::Request` posteriormente.

### Soporte renovado para Rails Engines

Después de algunas versiones sin actualizaciones, Rails 2.3 ofrece algunas características nuevas para Rails Engines (aplicaciones de Rails que se pueden integrar en otras aplicaciones). Primero, los archivos de enrutamiento en los engines ahora se cargan y recargan automáticamente, al igual que tu archivo `routes.rb` (esto también se aplica a los archivos de enrutamiento en otros plugins). Segundo, si tu plugin tiene una carpeta `app`, entonces `app/[models|controllers|helpers]` se agregará automáticamente a la ruta de carga de Rails. Los engines también admiten agregar rutas de vistas ahora, y Action Mailer, así como Action View, utilizarán vistas de engines y otros plugins.
Documentación
-------------

El proyecto [Ruby on Rails guides](https://guides.rubyonrails.org/) ha publicado varias guías adicionales para Rails 2.3. Además, un [sitio separado](https://edgeguides.rubyonrails.org/) mantiene copias actualizadas de las Guías para Edge Rails. Otros esfuerzos de documentación incluyen el relanzamiento del [wiki de Rails](http://newwiki.rubyonrails.org/) y la planificación temprana de un libro de Rails.

* Más información: [Proyectos de documentación de Rails](https://weblog.rubyonrails.org/2009/1/15/rails-documentation-projects)

Soporte para Ruby 1.9.1
------------------

Rails 2.3 debería pasar todas sus propias pruebas, ya sea que se ejecute en Ruby 1.8 o en el ahora lanzado Ruby 1.9.1. Sin embargo, debes tener en cuenta que el cambio a 1.9.1 implica verificar la compatibilidad de todos los adaptadores de datos, complementos y otro código en el que dependas para Ruby 1.9.1, así como el núcleo de Rails.

Active Record
-------------

Active Record obtiene varias características nuevas y correcciones de errores en Rails 2.3. Los aspectos más destacados incluyen atributos anidados, transacciones anidadas, ámbitos dinámicos y por defecto, y procesamiento por lotes.

### Atributos Anidados

Active Record ahora puede actualizar los atributos en modelos anidados directamente, siempre y cuando se le indique que lo haga:

```ruby
class Book < ActiveRecord::Base
  has_one :author
  has_many :pages

  accepts_nested_attributes_for :author, :pages
end
```

Activar los atributos anidados habilita varias cosas: guardar automáticamente (y de forma atómica) un registro junto con sus hijos asociados, validaciones conscientes de los hijos y soporte para formularios anidados (discutido más adelante).

También puedes especificar requisitos para cualquier registro nuevo que se agregue a través de atributos anidados utilizando la opción `:reject_if`:

```ruby
accepts_nested_attributes_for :author,
  :reject_if => proc { |attributes| attributes['name'].blank? }
```

* Contribuidor principal: [Eloy Duran](http://superalloy.nl/)
* Más información: [Formularios de modelos anidados](https://weblog.rubyonrails.org/2009/1/26/nested-model-forms)

### Transacciones Anidadas

Active Record ahora admite transacciones anidadas, una característica muy solicitada. Ahora puedes escribir código como este:

```ruby
User.transaction do
  User.create(:username => 'Admin')
  User.transaction(:requires_new => true) do
    User.create(:username => 'Regular')
    raise ActiveRecord::Rollback
  end
end

User.find(:all)  # => Devuelve solo Admin
```

Las transacciones anidadas te permiten deshacer una transacción interna sin afectar el estado de la transacción externa. Si deseas que una transacción sea anidada, debes agregar explícitamente la opción `:requires_new`; de lo contrario, una transacción anidada simplemente se convierte en parte de la transacción principal (como ocurre actualmente en Rails 2.2). En el fondo, las transacciones anidadas están [utilizando puntos de guardado](http://rails.lighthouseapp.com/projects/8994/tickets/383), por lo que son compatibles incluso en bases de datos que no tienen transacciones anidadas reales. También hay un poco de magia para que estas transacciones funcionen bien con las pruebas de fixtures transaccionales.

* Contribuidores principales: [Jonathan Viney](http://www.workingwithrails.com/person/4985-jonathan-viney) y [Hongli Lai](http://izumi.plan99.net/blog/)

### Ámbitos Dinámicos

Ya conoces los buscadores dinámicos en Rails (que te permiten crear métodos como `find_by_color_and_flavor` sobre la marcha) y los ámbitos nombrados (que te permiten encapsular condiciones de consulta reutilizables en nombres amigables como `currently_active`). Bueno, ahora puedes tener métodos de ámbito dinámicos. La idea es juntar una sintaxis que permita filtrar sobre la marcha _y_ encadenar métodos. Por ejemplo:

```ruby
Order.scoped_by_customer_id(12)
Order.scoped_by_customer_id(12).find(:all,
  :conditions => "status = 'open'")
Order.scoped_by_customer_id(12).scoped_by_status("open")
```

No hay nada que definir para usar ámbitos dinámicos: simplemente funcionan.

* Contribuidor principal: [Yaroslav Markin](http://evilmartians.com/)
* Más información: [Novedades en Edge Rails: Métodos de ámbito dinámico](http://archives.ryandaigle.com/articles/2008/12/29/what-s-new-in-edge-rails-dynamic-scope-methods)

### Ámbitos por Defecto

Rails 2.3 introducirá la noción de _ámbitos por defecto_, similares a los ámbitos nombrados, pero aplicados a todos los ámbitos nombrados o métodos de búsqueda dentro del modelo. Por ejemplo, puedes escribir `default_scope :order => 'name ASC'` y cada vez que recuperes registros de ese modelo, saldrán ordenados por nombre (a menos que anules la opción, por supuesto).

* Contribuidor principal: Paweł Kondzior
* Más información: [Novedades en Edge Rails: Ámbitos por Defecto](http://archives.ryandaigle.com/articles/2008/11/18/what-s-new-in-edge-rails-default-scoping)

### Procesamiento por Lotes

Ahora puedes procesar grandes cantidades de registros de un modelo Active Record con menos presión en la memoria utilizando `find_in_batches`:

```ruby
Customer.find_in_batches(:conditions => {:active => true}) do |customer_group|
  customer_group.each { |customer| customer.update_account_balance! }
end
```

Puedes pasar la mayoría de las opciones de `find` a `find_in_batches`. Sin embargo, no puedes especificar el orden en que se devolverán los registros (siempre se devolverán en orden ascendente de la clave primaria, que debe ser un entero) ni usar la opción `:limit`. En su lugar, utiliza la opción `:batch_size`, que por defecto es 1000, para establecer la cantidad de registros que se devolverán en cada lote.

El nuevo método `find_each` proporciona un envoltorio alrededor de `find_in_batches` que devuelve registros individuales, realizando la búsqueda en lotes (de 1000 por defecto):

```ruby
Customer.find_each do |customer|
  customer.update_account_balance!
end
```
Tenga en cuenta que solo debe utilizar este método para procesamiento por lotes: para pequeñas cantidades de registros (menos de 1000), simplemente debe utilizar los métodos de búsqueda regulares con su propio bucle.

* Más información (en ese momento el método de conveniencia se llamaba simplemente `each`):
    * [Rails 2.3: Búsqueda por lotes](http://afreshcup.com/2009/02/23/rails-23-batch-finding/)
    * [Novedades en Edge Rails: Búsqueda por lotes](http://archives.ryandaigle.com/articles/2009/2/23/what-s-new-in-edge-rails-batched-find)

### Múltiples condiciones para callbacks

Cuando se utilizan callbacks de Active Record, ahora se pueden combinar las opciones `:if` y `:unless` en el mismo callback y proporcionar múltiples condiciones como un array:

```ruby
before_save :update_credit_rating, :if => :active,
  :unless => [:admin, :cash_only]
```
* Contribuidor principal: L. Caviola

### Búsqueda con having

Rails ahora tiene una opción `:having` en la búsqueda (así como en las asociaciones `has_many` y `has_and_belongs_to_many`) para filtrar registros en búsquedas agrupadas. Como aquellos con experiencia en SQL saben, esto permite filtrar en función de los resultados agrupados:

```ruby
developers = Developer.find(:all, :group => "salary",
  :having => "sum(salary) > 10000", :select => "salary")
```

* Contribuidor principal: [Emilio Tagua](https://github.com/miloops)

### Reconexión de conexiones MySQL

MySQL admite una bandera de reconexión en sus conexiones: si se establece en true, el cliente intentará reconectarse al servidor antes de rendirse en caso de una conexión perdida. Ahora puede establecer `reconnect = true` para sus conexiones MySQL en `database.yml` para obtener este comportamiento desde una aplicación Rails. El valor predeterminado es `false`, por lo que el comportamiento de las aplicaciones existentes no cambia.

* Contribuidor principal: [Dov Murik](http://twitter.com/dubek)
* Más información:
    * [Control del comportamiento de reconexión automática](http://dev.mysql.com/doc/refman/5.6/en/auto-reconnect.html)
    * [Reconexión automática de MySQL revisada](http://groups.google.com/group/rubyonrails-core/browse_thread/thread/49d2a7e9c96cb9f4)

### Otros cambios en Active Record

* Se eliminó un `AS` adicional del SQL generado para la precarga de `has_and_belongs_to_many`, lo que lo hace funcionar mejor para algunas bases de datos.
* `ActiveRecord::Base#new_record?` ahora devuelve `false` en lugar de `nil` cuando se enfrenta a un registro existente.
* Se corrigió un error en la citación de nombres de tablas en algunas asociaciones `has_many :through`.
* Ahora puede especificar una marca de tiempo particular para los campos `updated_at`: `cust = Customer.create(:name => "ABC Industries", :updated_at => 1.day.ago)`
* Mejores mensajes de error en llamadas fallidas de `find_by_attribute!`.
* El soporte `to_xml` de Active Record se vuelve un poco más flexible con la adición de una opción `:camelize`.
* Se corrigió un error en la cancelación de callbacks desde `before_update` o `before_create`.
* Se agregaron tareas de Rake para probar bases de datos a través de JDBC.
* `validates_length_of` utilizará un mensaje de error personalizado con las opciones `:in` o `:within` (si se proporciona uno).
* Los recuentos en selecciones con alcance ahora funcionan correctamente, por lo que puede hacer cosas como `Account.scoped(:select => "DISTINCT credit_limit").count`.
* `ActiveRecord::Base#invalid?` ahora funciona como el opuesto de `ActiveRecord::Base#valid?`.

Controlador de acciones
-----------------------

El controlador de acciones implementa algunos cambios significativos en la representación, así como mejoras en el enrutamiento y otras áreas, en esta versión.

### Representación unificada

`ActionController::Base#render` es mucho más inteligente al decidir qué representar. Ahora solo necesita decirle qué representar y esperar obtener los resultados correctos. En versiones anteriores de Rails, a menudo necesita proporcionar información explícita para representar:

```ruby
render :file => '/tmp/random_file.erb'
render :template => 'other_controller/action'
render :action => 'show'
```

Ahora en Rails 2.3, solo necesita proporcionar lo que desea representar:

```ruby
render '/tmp/random_file.erb'
render 'other_controller/action'
render 'show'
render :show
```

Rails elige entre archivo, plantilla y acción dependiendo de si hay una barra diagonal inicial, una barra diagonal incrustada o ninguna barra diagonal en lo que se va a representar. Tenga en cuenta que también puede usar un símbolo en lugar de una cadena al representar una acción. Otros estilos de representación (`:inline`, `:text`, `:update`, `:nothing`, `:json`, `:xml`, `:js`) todavía requieren una opción explícita.

### Controlador de aplicación renombrado

Si eres una de las personas que siempre se ha molestado por el nombre especial de `application.rb`, ¡alégrate! Se ha modificado para ser `application_controller.rb` en Rails 2.3. Además, hay una nueva tarea de rake, `rake rails:update:application_controller`, que hace esto automáticamente por ti, y se ejecutará como parte del proceso normal de `rake rails:update`.

* Más información:
    * [La muerte de application.rb](https://afreshcup.com/home/2008/11/17/rails-2x-the-death-of-applicationrb)
    * [Novedades en Edge Rails: La dualidad de Application.rb ya no existe](http://archives.ryandaigle.com/articles/2008/11/19/what-s-new-in-edge-rails-application-rb-duality-is-no-more)

### Soporte de autenticación HTTP Digest

Rails ahora tiene soporte incorporado para la autenticación HTTP digest. Para usarlo, llame a `authenticate_or_request_with_http_digest` con un bloque que devuelva la contraseña del usuario (que luego se hashea y se compara con las credenciales transmitidas):

```ruby
class PostsController < ApplicationController
  Users = {"dhh" => "secret"}
  before_filter :authenticate

  def secret
    render :text => "¡Se requiere contraseña!"
  end

  private
  def authenticate
    realm = "Application"
    authenticate_or_request_with_http_digest(realm) do |name|
      Users[name]
    end
  end
end
```
* Contribuidor Principal: [Gregg Kellogg](http://www.kellogg-assoc.com/)
* Más Información: [Novedades en Edge Rails: Autenticación HTTP Digest](http://archives.ryandaigle.com/articles/2009/1/30/what-s-new-in-edge-rails-http-digest-authentication)

### Enrutamiento más eficiente

Hay un par de cambios significativos en el enrutamiento en Rails 2.3. Los ayudantes de ruta `formatted_` han desaparecido, en su lugar se pasa `:format` como opción. Esto reduce el proceso de generación de rutas en un 50% para cualquier recurso, y puede ahorrar una cantidad sustancial de memoria (hasta 100MB en aplicaciones grandes). Si tu código utiliza los ayudantes `formatted_`, seguirán funcionando por el momento, pero ese comportamiento está obsoleto y tu aplicación será más eficiente si reescribes esas rutas utilizando el nuevo estándar. Otro cambio importante es que Rails ahora admite múltiples archivos de enrutamiento, no solo `routes.rb`. Puedes usar `RouteSet#add_configuration_file` para agregar más rutas en cualquier momento, sin borrar las rutas cargadas actualmente. Si bien este cambio es más útil para los Engines, se puede utilizar en cualquier aplicación que necesite cargar rutas por lotes.

* Contribuidor Principal: [Aaron Batalion](http://blog.hungrymachine.com/)

### Sesiones cargadas de forma diferida basadas en Rack

Un gran cambio llevó los fundamentos del almacenamiento de sesiones de Action Controller al nivel de Rack. Esto implicó mucho trabajo en el código, aunque debería ser completamente transparente para tus aplicaciones de Rails (como bonificación, se eliminaron algunos parches desagradables en el antiguo controlador de sesiones CGI). Sin embargo, sigue siendo significativo por una simple razón: las aplicaciones Rack no relacionadas con Rails tienen acceso a los mismos controladores de almacenamiento de sesiones (y, por lo tanto, a la misma sesión) que tus aplicaciones de Rails. Además, las sesiones ahora se cargan de forma diferida (en línea con las mejoras de carga en el resto del framework). Esto significa que ya no necesitas deshabilitar explícitamente las sesiones si no las quieres; simplemente no hagas referencia a ellas y no se cargarán.

### Cambios en el manejo de tipos MIME

Hay un par de cambios en el código para manejar los tipos MIME en Rails. Primero, `MIME::Type` ahora implementa el operador `=~`, lo que hace que sea mucho más limpio cuando necesitas verificar la presencia de un tipo que tiene sinónimos:

```ruby
if content_type && Mime::JS =~ content_type
  # hacer algo genial
end

Mime::JS =~ "text/javascript"        => true
Mime::JS =~ "application/javascript" => true
```

El otro cambio es que el framework ahora utiliza `Mime::JS` al verificar JavaScript en varios lugares, lo que permite manejar esas alternativas de manera limpia.

* Contribuidor Principal: [Seth Fitzsimmons](http://www.workingwithrails.com/person/5510-seth-fitzsimmons)

### Optimización de `respond_to`

Como uno de los primeros frutos de la fusión del equipo de Rails-Merb, Rails 2.3 incluye algunas optimizaciones para el método `respond_to`, que se utiliza ampliamente en muchas aplicaciones de Rails para permitir que tu controlador formatee los resultados de manera diferente según el tipo MIME de la solicitud entrante. Después de eliminar una llamada a `method_missing` y realizar algunas pruebas y ajustes, estamos viendo una mejora del 8% en el número de solicitudes por segundo atendidas con un simple `respond_to` que cambia entre tres formatos. ¿Lo mejor? No se requiere ningún cambio en el código de tu aplicación para aprovechar esta aceleración.

### Mejora del rendimiento de la caché

Rails ahora mantiene una caché local por solicitud de lecturas de los almacenes de caché remotos, reduciendo las lecturas innecesarias y mejorando el rendimiento del sitio. Si bien este trabajo se limitaba originalmente a `MemCacheStore`, está disponible para cualquier almacén remoto que implemente los métodos requeridos.

* Contribuidor Principal: [Nahum Wild](http://www.motionstandingstill.com/)

### Vistas localizadas

Rails ahora puede proporcionar vistas localizadas, según la configuración regional que hayas establecido. Por ejemplo, supongamos que tienes un controlador `Posts` con una acción `show`. Por defecto, esto renderizará `app/views/posts/show.html.erb`. Pero si estableces `I18n.locale = :da`, se renderizará `app/views/posts/show.da.html.erb`. Si la plantilla localizada no está presente, se utilizará la versión sin decorar. Rails también incluye `I18n#available_locales` y `I18n::SimpleBackend#available_locales`, que devuelven una matriz de las traducciones disponibles en el proyecto Rails actual.

Además, puedes utilizar el mismo esquema para localizar los archivos de rescate en el directorio público: `public/500.da.html` o `public/404.en.html` funcionan, por ejemplo.

### Ámbito parcial para traducciones

Un cambio en la API de traducción facilita y reduce la repetición al escribir traducciones clave dentro de parciales. Si llamas a `translate(".foo")` desde la plantilla `people/index.html.erb`, en realidad estarás llamando a `I18n.translate("people.index.foo")`. Si no precedes la clave con un punto, entonces la API no la delimita, al igual que antes.
### Otros cambios en ActionController

* El manejo de ETag se ha limpiado un poco: Rails ahora omitirá enviar un encabezado ETag cuando no haya cuerpo en la respuesta o al enviar archivos con `send_file`.
* El hecho de que Rails verifique el spoofing de IP puede ser molesto para los sitios que tienen mucho tráfico con teléfonos celulares, porque sus proxies generalmente no configuran las cosas correctamente. Si eres uno de ellos, ahora puedes establecer `ActionController::Base.ip_spoofing_check = false` para desactivar por completo la verificación.
* `ActionController::Dispatcher` ahora implementa su propia pila de middleware, que puedes ver ejecutando `rake middleware`.
* Las sesiones de cookies ahora tienen identificadores de sesión persistentes, con compatibilidad de API con las tiendas del lado del servidor.
* Ahora puedes usar símbolos para la opción `:type` de `send_file` y `send_data`, así: `send_file("fabulous.png", :type => :png)`.
* Las opciones `:only` y `:except` para `map.resources` ya no se heredan en recursos anidados.
* El cliente memcached incluido se ha actualizado a la versión 1.6.4.99.
* Los métodos `expires_in`, `stale?` y `fresh_when` ahora aceptan una opción `:public` para que funcionen bien con el almacenamiento en caché de proxy.
* La opción `:requirements` ahora funciona correctamente con rutas adicionales de miembros RESTful.
* Las rutas poco profundas ahora respetan correctamente los espacios de nombres.
* `polymorphic_url` ahora maneja mejor los objetos con nombres plurales irregulares.

Action View
-----------

Action View en Rails 2.3 incluye formularios de modelos anidados, mejoras en `render`, promps más flexibles para los ayudantes de selección de fecha y una aceleración en el almacenamiento en caché de activos, entre otras cosas.

### Formularios de objetos anidados

Si el modelo padre acepta atributos anidados para los objetos hijos (como se discute en la sección de Active Record), puedes crear formularios anidados utilizando `form_for` y `field_for`. Estos formularios pueden anidarse arbitrariamente, lo que te permite editar jerarquías de objetos complejas en una sola vista sin código excesivo. Por ejemplo, dado este modelo:

```ruby
class Customer < ActiveRecord::Base
  has_many :orders

  accepts_nested_attributes_for :orders, :allow_destroy => true
end
```

Puedes escribir esta vista en Rails 2.3:

```html+erb
<% form_for @customer do |customer_form| %>
  <div>
    <%= customer_form.label :name, 'Nombre del cliente:' %>
    <%= customer_form.text_field :name %>
  </div>

  <!-- Aquí llamamos a fields_for en la instancia del constructor customer_form.
   El bloque se llama para cada miembro de la colección de pedidos. -->
  <% customer_form.fields_for :orders do |order_form| %>
    <p>
      <div>
        <%= order_form.label :number, 'Número de pedido:' %>
        <%= order_form.text_field :number %>
      </div>

  <!-- La opción allow_destroy en el modelo permite eliminar
   registros secundarios. -->
      <% unless order_form.object.new_record? %>
        <div>
          <%= order_form.label :_delete, 'Eliminar:' %>
          <%= order_form.check_box :_delete %>
        </div>
      <% end %>
    </p>
  <% end %>

  <%= customer_form.submit %>
<% end %>
```

* Contribuidor principal: [Eloy Duran](http://superalloy.nl/)
* Más información:
    * [Formularios de modelos anidados](https://weblog.rubyonrails.org/2009/1/26/nested-model-forms)
    * [complex-form-examples](https://github.com/alloy/complex-form-examples)
    * [Novedades en Edge Rails: Formularios de objetos anidados](http://archives.ryandaigle.com/articles/2009/2/1/what-s-new-in-edge-rails-nested-attributes)

### Renderizado inteligente de parciales

El método `render` ha ido mejorando con el tiempo, y ahora es aún más inteligente. Si tienes un objeto o una colección y un parcial adecuado, y los nombres coinciden, ahora puedes simplemente renderizar el objeto y las cosas funcionarán. Por ejemplo, en Rails 2.3, estas llamadas a `render` funcionarán en tu vista (asumiendo nombres sensibles):

```ruby
# Equivalente a render :partial => 'articles/_article',
# :object => @article
render @article

# Equivalente a render :partial => 'articles/_article',
# :collection => @articles
render @articles
```

* Más información: [Novedades en Edge Rails: render deja de ser complicado](http://archives.ryandaigle.com/articles/2008/11/20/what-s-new-in-edge-rails-render-stops-being-high-maintenance)

### Prompts para los ayudantes de selección de fecha

En Rails 2.3, puedes proporcionar promps personalizados para los diversos ayudantes de selección de fecha (`date_select`, `time_select` y `datetime_select`), de la misma manera que lo haces con los ayudantes de selección de colección. Puedes proporcionar una cadena de prompt o un hash de cadenas de prompt individuales para los diferentes componentes. También puedes simplemente establecer `:prompt` en `true` para usar el prompt genérico personalizado:

```ruby
select_datetime(DateTime.now, :prompt => true)

select_datetime(DateTime.now, :prompt => "Elegir fecha y hora")

select_datetime(DateTime.now, :prompt =>
  {:day => 'Elegir día', :month => 'Elegir mes',
   :year => 'Elegir año', :hour => 'Elegir hora',
   :minute => 'Elegir minuto'})
```

* Contribuidor principal: [Sam Oliver](http://samoliver.com/)

### Almacenamiento en caché de marcas de tiempo de AssetTag

Es probable que estés familiarizado con la práctica de Rails de agregar marcas de tiempo a las rutas de activos estáticos como un "cache buster". Esto ayuda a asegurar que no se sirvan copias obsoletas de cosas como imágenes y hojas de estilo desde la caché del navegador del usuario cuando las cambias en el servidor. Ahora puedes modificar este comportamiento con la opción de configuración `cache_asset_timestamps` para Action View. Si habilitas la caché, Rails calculará la marca de tiempo una vez cuando sirva por primera vez un activo y guardará ese valor. Esto significa menos llamadas (costosas) al sistema de archivos para servir activos estáticos, pero también significa que no puedes modificar ninguno de los activos mientras el servidor está en ejecución y esperar que los cambios sean recogidos por los clientes.
### Asset Hosts como Objetos

En edge Rails, los hosts de activos se vuelven más flexibles con la capacidad de declarar un host de activos como un objeto específico que responde a una llamada. Esto te permite implementar cualquier lógica compleja que necesites en tu alojamiento de activos.

* Más información: [asset-hosting-with-minimum-ssl](https://github.com/dhh/asset-hosting-with-minimum-ssl/tree/master)

### Método auxiliar grouped_options_for_select

Action View ya tenía un montón de métodos auxiliares para ayudar a generar controles de selección, pero ahora hay uno más: `grouped_options_for_select`. Este acepta una matriz o un hash de cadenas y las convierte en una cadena de etiquetas `option` envueltas con etiquetas `optgroup`. Por ejemplo:

```ruby
grouped_options_for_select([["Hats", ["Baseball Cap","Cowboy Hat"]]],
  "Cowboy Hat", "Choose a product...")
```

devuelve

```html
<option value="">Choose a product...</option>
<optgroup label="Hats">
  <option value="Baseball Cap">Baseball Cap</option>
  <option selected="selected" value="Cowboy Hat">Cowboy Hat</option>
</optgroup>
```

### Etiquetas de opción deshabilitadas para los ayudantes de selección de formularios

Los ayudantes de selección de formularios (como `select` y `options_for_select`) ahora admiten una opción `:disabled`, que puede tomar un valor único o una matriz de valores para deshabilitar en las etiquetas resultantes:

```ruby
select(:post, :category, Post::CATEGORIES, :disabled => 'private')
```

devuelve

```html
<select name="post[category]">
<option>story</option>
<option>joke</option>
<option>poem</option>
<option disabled="disabled">private</option>
</select>
```

También puedes usar una función anónima para determinar en tiempo de ejecución qué opciones de las colecciones serán seleccionadas y/o deshabilitadas:

```ruby
options_from_collection_for_select(@product.sizes, :name, :id, :disabled => lambda{|size| size.out_of_stock?})
```

* Contribuidor principal: [Tekin Suleyman](http://tekin.co.uk/)
* Más información: [New in rails 2.3 - disabled option tags and lambdas for selecting and disabling options from collections](https://tekin.co.uk/2009/03/new-in-rails-23-disabled-option-tags-and-lambdas-for-selecting-and-disabling-options-from-collections)

### Una nota sobre la carga de plantillas

Rails 2.3 incluye la capacidad de habilitar o deshabilitar las plantillas en caché para cualquier entorno en particular. Las plantillas en caché te brindan un impulso de velocidad porque no verifican un nuevo archivo de plantilla cuando se renderizan, pero también significa que no puedes reemplazar una plantilla "sobre la marcha" sin reiniciar el servidor.

En la mayoría de los casos, querrás que la caché de plantillas esté activada en producción, lo cual puedes hacer configurando en tu archivo `production.rb`:

```ruby
config.action_view.cache_template_loading = true
```

Esta línea se generará automáticamente por defecto en una nueva aplicación Rails 2.3. Si has actualizado desde una versión anterior de Rails, Rails utilizará la caché de plantillas en producción y prueba, pero no en desarrollo.

### Otros cambios en Action View

* La generación de tokens para la protección CSRF se ha simplificado; ahora Rails utiliza una cadena aleatoria simple generada por `ActiveSupport::SecureRandom` en lugar de manipular las IDs de sesión.
* `auto_link` ahora aplica correctamente las opciones (como `:target` y `:class`) a los enlaces de correo electrónico generados.
* El ayudante `autolink` ha sido refactorizado para que sea un poco menos confuso y más intuitivo.
* `current_page?` ahora funciona correctamente incluso cuando hay múltiples parámetros de consulta en la URL.

Active Support
--------------

Active Support tiene algunos cambios interesantes, incluida la introducción de `Object#try`.

### Object#try

Muchas personas han adoptado la idea de usar try() para intentar operaciones en objetos. Es especialmente útil en las vistas donde puedes evitar la comprobación de nulos escribiendo código como `<%= @person.try(:name) %>`. Bueno, ahora está integrado directamente en Rails. Como se implementa en Rails, genera `NoMethodError` en métodos privados y siempre devuelve `nil` si el objeto es nulo.

* Más información: [try()](http://ozmm.org/posts/try.html)

### Backport de Object#tap

`Object#tap` es una adición a [Ruby 1.9](http://www.ruby-doc.org/core-1.9/classes/Object.html#M000309) y 1.8.7 que es similar al método `returning` que Rails ha tenido durante un tiempo: se ejecuta un bloque y luego devuelve el objeto que se pasó. Ahora Rails incluye código para hacer esto disponible en versiones anteriores de Ruby también.

### Analizadores intercambiables para XMLmini

El soporte para el análisis XML en Active Support se ha vuelto más flexible al permitirte intercambiar analizadores diferentes. Por defecto, utiliza la implementación estándar de REXML, pero puedes especificar fácilmente las implementaciones más rápidas de LibXML o Nokogiri para tus propias aplicaciones, siempre que tengas las gemas apropiadas instaladas:

```ruby
XmlMini.backend = 'LibXML'
```

* Contribuidor principal: [Bart ten Brinke](http://www.movesonrails.com/)
* Contribuidor principal: [Aaron Patterson](http://tenderlovemaking.com/)

### Segundos fraccionarios para TimeWithZone

Las clases `Time` y `TimeWithZone` incluyen un método `xmlschema` para devolver la hora en una cadena compatible con XML. A partir de Rails 2.3, `TimeWithZone` admite el mismo argumento para especificar el número de dígitos en la parte de segundos fraccionarios de la cadena devuelta que `Time`:

```ruby
Time.zone.now.xmlschema(6) # => "2009-01-16T13:00:06.13653Z"
```
* Contribuidor principal: [Nicholas Dainty](http://www.workingwithrails.com/person/13536-nicholas-dainty)

### Comillas clave JSON

Si consultas la especificación en el sitio "json.org", descubrirás que todas las claves en una estructura JSON deben ser cadenas y deben estar entre comillas dobles. A partir de Rails 2.3, hacemos lo correcto aquí, incluso con claves numéricas.

### Otros cambios en Active Support

* Puedes usar `Enumerable#none?` para verificar que ninguno de los elementos coincida con el bloque suministrado.
* Si estás utilizando [delegados](https://afreshcup.com/home/2008/10/19/coming-in-rails-22-delegate-prefixes) de Active Support, la nueva opción `:allow_nil` te permite devolver `nil` en lugar de generar una excepción cuando el objeto objetivo es nulo.
* `ActiveSupport::OrderedHash`: ahora implementa `each_key` y `each_value`.
* `ActiveSupport::MessageEncryptor` proporciona una forma sencilla de cifrar información para almacenarla en una ubicación no confiable (como las cookies).
* El método `from_xml` de Active Support ya no depende de XmlSimple. En su lugar, Rails ahora incluye su propia implementación de XmlMini, con solo la funcionalidad que requiere. Esto permite que Rails prescinda de la copia incluida de XmlSimple que ha estado arrastrando.
* Si memoizas un método privado, el resultado ahora será privado.
* `String#parameterize` acepta un separador opcional: `"Quick Brown Fox".parameterize('_') => "quick_brown_fox"`.
* `number_to_phone` ahora acepta números de teléfono de 7 dígitos.
* `ActiveSupport::Json.decode` ahora maneja secuencias de escape de estilo `\u0000`.

Railties
--------

Además de los cambios en Rack mencionados anteriormente, Railties (el código principal de Rails en sí) presenta una serie de cambios significativos, incluyendo Rails Metal, plantillas de aplicación y trazas de error silenciosas.

### Rails Metal

Rails Metal es un nuevo mecanismo que proporciona puntos finales de alta velocidad dentro de tus aplicaciones Rails. Las clases Metal omiten el enrutamiento y el controlador de acciones para brindarte velocidad pura (a costa de todas las cosas en el controlador de acciones, por supuesto). Esto se basa en todo el trabajo de base reciente para convertir a Rails en una aplicación Rack con una pila de middleware expuesta. Los puntos finales de Metal se pueden cargar desde tu aplicación o desde complementos.

* Más información:
    * [Introducing Rails Metal](https://weblog.rubyonrails.org/2008/12/17/introducing-rails-metal)
    * [Rails Metal: a micro-framework with the power of Rails](http://soylentfoo.jnewland.com/articles/2008/12/16/rails-metal-a-micro-framework-with-the-power-of-rails-m)
    * [Metal: Super-fast Endpoints within your Rails Apps](http://www.railsinside.com/deployment/180-metal-super-fast-endpoints-within-your-rails-apps.html)
    * [What's New in Edge Rails: Rails Metal](http://archives.ryandaigle.com/articles/2008/12/18/what-s-new-in-edge-rails-rails-metal)

### Plantillas de aplicación

Rails 2.3 incorpora el generador de aplicaciones [rg](https://github.com/jm/rg) de Jeremy McAnally. Esto significa que ahora tenemos generación de aplicaciones basada en plantillas incorporada en Rails; si tienes un conjunto de complementos que incluyes en cada aplicación (entre muchos otros casos de uso), solo necesitas configurar una plantilla una vez y usarla una y otra vez cuando ejecutes el comando `rails`. También hay una tarea rake para aplicar una plantilla a una aplicación existente:

```bash
$ rake rails:template LOCATION=~/template.rb
```

Esto aplicará los cambios de la plantilla sobre el código que ya contiene el proyecto.

* Contribuidor principal: [Jeremy McAnally](http://www.jeremymcanally.com/)
* Más información: [Rails templates](http://m.onkey.org/2008/12/4/rails-templates)

### Trazas de error más silenciosas

Basándose en el complemento [Quiet Backtrace](https://github.com/thoughtbot/quietbacktrace) de thoughtbot, que te permite eliminar selectivamente líneas de las trazas de error de `Test::Unit`, Rails 2.3 implementa `ActiveSupport::BacktraceCleaner` y `Rails::BacktraceCleaner` en su núcleo. Esto admite tanto filtros (para realizar sustituciones basadas en expresiones regulares en las líneas de la traza de error) como silenciadores (para eliminar completamente las líneas de la traza de error). Rails agrega automáticamente silenciadores para eliminar el ruido más común en una nueva aplicación y crea un archivo `config/backtrace_silencers.rb` para contener tus propias adiciones. Esta función también permite una impresión más bonita desde cualquier gema en la traza de error.

### Tiempo de inicio más rápido en modo de desarrollo con carga perezosa/carga automática

Se ha realizado bastante trabajo para asegurarse de que las partes de Rails (y sus dependencias) solo se carguen en memoria cuando realmente se necesiten. Los marcos principales: Active Support, Active Record, Action Controller, Action Mailer y Action View, ahora utilizan `autoload` para cargar perezosamente sus clases individuales. Este trabajo debería ayudar a mantener el consumo de memoria bajo y mejorar el rendimiento general de Rails.

También puedes especificar (usando la nueva opción `preload_frameworks`) si las bibliotecas principales deben cargarse automáticamente al inicio. Esto se establece en `false` de forma predeterminada para que Rails se cargue pieza por pieza, pero hay algunas circunstancias en las que aún necesitas cargar todo de una vez: Passenger y JRuby quieren ver todo Rails cargado juntos.

### Reescritura de la tarea `rake gem`

Se han revisado sustancialmente los aspectos internos de las diversas tareas <code>rake gem</code> para que el sistema funcione mejor en una variedad de casos. Ahora el sistema de gemas distingue entre dependencias de desarrollo y de tiempo de ejecución, tiene un sistema de desempaquetado más robusto, proporciona mejor información al consultar el estado de las gemas y es menos propenso a problemas de dependencia "de gallina y huevo" cuando estás comenzando desde cero. También se han corregido problemas al usar comandos de gemas en JRuby y con dependencias que intentan traer copias externas de gemas que ya están vendidas.
* Contribuidor principal: [David Dollar](http://www.workingwithrails.com/person/12240-david-dollar)

### Otros cambios en Railties

* Las instrucciones para actualizar un servidor de CI para construir Rails se han actualizado y ampliado.
* Las pruebas internas de Rails se han cambiado de `Test::Unit::TestCase` a `ActiveSupport::TestCase`, y el núcleo de Rails requiere Mocha para las pruebas.
* El archivo `environment.rb` predeterminado se ha despejado.
* El script dbconsole ahora permite usar una contraseña completamente numérica sin bloquearse.
* `Rails.root` ahora devuelve un objeto `Pathname`, lo que significa que se puede usar directamente con el método `join` para [limpiar el código existente](https://afreshcup.wordpress.com/2008/12/05/a-little-rails_root-tidiness/) que utiliza `File.join`.
* Varios archivos en /public que se ocupan de la distribución de CGI y FCGI ya no se generan en cada aplicación de Rails de forma predeterminada (aún puedes obtenerlos si los necesitas agregando `--with-dispatchers` cuando ejecutes el comando `rails`, o agregarlos más tarde con `rake rails:update:generate_dispatchers`).
* Las guías de Rails se han convertido de AsciiDoc a Textile markup.
* Las vistas y controladores generados por scaffold se han limpiado un poco.
* `script/server` ahora acepta un argumento `--path` para montar una aplicación de Rails desde una ruta específica.
* Si faltan algunas gemas configuradas, las tareas de rake de las gemas omitirán cargar gran parte del entorno. Esto debería solucionar muchos de los problemas de "huevo y gallina" donde rake gems:install no se podía ejecutar porque faltaban gemas.
* Las gemas ahora se desempaquetan exactamente una vez. Esto soluciona problemas con gemas (como hoe, por ejemplo) que se empaquetan con permisos de solo lectura en los archivos.

Obsoleto
----------

Algunas piezas de código antiguo están obsoletas en esta versión:

* Si eres uno de los (bastante raros) desarrolladores de Rails que implementa de una manera que depende de los scripts inspector, reaper y spawner, debes saber que esos scripts ya no se incluyen en el núcleo de Rails. Si los necesitas, podrás obtener copias a través del complemento [irs_process_scripts](https://github.com/rails/irs_process_scripts).
* `render_component` pasa de "obsoleto" a "inexistente" en Rails 2.3. Si aún lo necesitas, puedes instalar el complemento [render_component](https://github.com/rails/render_component/tree/master).
* Se ha eliminado el soporte para los componentes de Rails.
* Si eras una de las personas que solía ejecutar `script/performance/request` para ver el rendimiento basado en pruebas de integración, debes aprender un nuevo truco: ese script se ha eliminado del núcleo de Rails ahora. Hay un nuevo complemento request_profiler que puedes instalar para obtener exactamente la misma funcionalidad.
* `ActionController::Base#session_enabled?` está obsoleto porque las sesiones se cargan de forma diferida ahora.
* Las opciones `:digest` y `:secret` de `protect_from_forgery` están obsoletas y no tienen efecto.
* Se han eliminado algunos ayudantes de pruebas de integración. `response.headers["Status"]` y `headers["Status"]` ya no devolverán nada. Rack no permite "Status" en sus encabezados de retorno. Sin embargo, aún puedes usar los ayudantes `status` y `status_message`. `response.headers["cookie"]` y `headers["cookie"]` ya no devolverán ninguna cookie de CGI. Puedes inspeccionar `headers["Set-Cookie"]` para ver el encabezado de cookie sin procesar o usar el ayudante `cookies` para obtener un hash de las cookies enviadas al cliente.
* `formatted_polymorphic_url` está obsoleto. Usa `polymorphic_url` con `:format` en su lugar.
* La opción `:http_only` en `ActionController::Response#set_cookie` se ha renombrado a `:httponly`.
* Las opciones `:connector` y `:skip_last_comma` de `to_sentence` se han reemplazado por las opciones `:words_connector`, `:two_words_connector` y `:last_word_connector`.
* Enviar un formulario multipart con un control `file_field` vacío solía enviar una cadena vacía al controlador. Ahora envía un nulo, debido a las diferencias entre el analizador multipart de Rack y el antiguo de Rails.

Créditos
-------

Notas de la versión compiladas por [Mike Gunderloy](http://afreshcup.com). Esta versión de las notas de la versión de Rails 2.3 se compiló en base a RC2 de Rails 2.3.
