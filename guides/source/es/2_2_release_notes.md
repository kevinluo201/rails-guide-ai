**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 29fda46e32914456eb8369ab3f2cb7d6
Notas de lanzamiento de Ruby on Rails 2.2
===========================================

Rails 2.2 ofrece varias características nuevas y mejoradas. Esta lista cubre las actualizaciones principales pero no incluye cada pequeña corrección de errores y cambio. Si quieres ver todo, echa un vistazo a la [lista de commits](https://github.com/rails/rails/commits/2-2-stable) en el repositorio principal de Rails en GitHub.

Junto con Rails, 2.2 marca el lanzamiento de las [Guías de Ruby on Rails](https://guides.rubyonrails.org/), los primeros resultados del ongoing [Rails Guides hackfest](http://hackfest.rubyonrails.org/guide). Este sitio proporcionará documentación de alta calidad de las características principales de Rails.

--------------------------------------------------------------------------------

Infraestructura
---------------

Rails 2.2 es una versión importante para la infraestructura que mantiene a Rails funcionando sin problemas y conectado con el resto del mundo.

### Internacionalización

Rails 2.2 proporciona un sistema fácil para la internacionalización (o i18n, para aquellos de ustedes cansados de escribir).

* Contribuidores principales: Equipo de internacionalización de Rails
* Más información:
    * [Sitio web oficial de internacionalización de Rails](http://rails-i18n.org)
    * [Finalmente. Ruby on Rails se internacionaliza](https://web.archive.org/web/20140407075019/http://www.artweb-design.de/2008/7/18/finally-ruby-on-rails-gets-internationalized)
    * [Localizando Rails: Aplicación de demostración](https://github.com/clemens/i18n_demo_app)

### Compatibilidad con Ruby 1.9 y JRuby

Junto con la seguridad de hilos, se ha realizado mucho trabajo para que Rails funcione bien con JRuby y la próxima versión de Ruby 1.9. Con Ruby 1.9 siendo un objetivo en movimiento, ejecutar Rails en Ruby 1.9 aún es una propuesta incierta, pero Rails está listo para hacer la transición a Ruby 1.9 cuando este último sea lanzado.

Documentación
-------------

La documentación interna de Rails, en forma de comentarios de código, se ha mejorado en numerosos lugares. Además, el proyecto [Ruby on Rails Guides](https://guides.rubyonrails.org/) es la fuente definitiva de información sobre los principales componentes de Rails. En su primera versión oficial, la página de las Guías incluye:

* [Comenzando con Rails](getting_started.html)
* [Migraciones de base de datos de Rails](active_record_migrations.html)
* [Asociaciones de Active Record](association_basics.html)
* [Interfaz de consulta de Active Record](active_record_querying.html)
* [Layouts y renderizado en Rails](layouts_and_rendering.html)
* [Ayudantes de formulario de Action View](form_helpers.html)
* [Enrutamiento de Rails de afuera hacia adentro](routing.html)
* [Descripción general de Action Controller](action_controller_overview.html)
* [Caché de Rails](caching_with_rails.html)
* [Una guía para probar aplicaciones de Rails](testing.html)
* [Asegurando aplicaciones de Rails](security.html)
* [Depurando aplicaciones de Rails](debugging_rails_applications.html)
* [Lo básico de crear plugins de Rails](plugins.html)

En total, las Guías proporcionan decenas de miles de palabras de orientación para desarrolladores principiantes e intermedios de Rails.

Si quieres generar estas guías localmente, dentro de tu aplicación:

```bash
$ rake doc:guides
```

Esto colocará las guías dentro de `Rails.root/doc/guides` y podrás comenzar a navegar de inmediato abriendo `Rails.root/doc/guides/index.html` en tu navegador favorito.

* Contribuciones principales de [Xavier Noria](http://advogato.org/person/fxn/diary.html) y [Hongli Lai](http://izumi.plan99.net/blog/).
* Más información:
    * [Rails Guides hackfest](http://hackfest.rubyonrails.org/guide)
    * [Ayuda a mejorar la documentación de Rails en la rama Git](https://weblog.rubyonrails.org/2008/5/2/help-improve-rails-documentation-on-git-branch)

Mejor integración con HTTP: Soporte ETag de fábrica
---------------------------------------------------

El soporte para ETag y la marca de tiempo de última modificación en las cabeceras HTTP significa que Rails ahora puede enviar una respuesta vacía si recibe una solicitud de un recurso que no ha sido modificado recientemente. Esto te permite verificar si es necesario enviar una respuesta en absoluto.

```ruby
class ArticlesController < ApplicationController
  def show_with_respond_to_block
    @article = Article.find(params[:id])

    # Si la solicitud envía cabeceras que difieren de las opciones proporcionadas a stale?, entonces
    # la solicitud está obsoleta y se activa el bloque respond_to (y las opciones
    # para la llamada a stale? se establecen en la respuesta).
    #
    # Si las cabeceras de la solicitud coinciden, entonces la solicitud está actualizada y no se activa
    # el bloque respond_to. En su lugar, se producirá la renderización predeterminada, que comprobará las cabeceras
    # de última modificación y etag y concluirá que solo necesita enviar un "304 Not Modified" en lugar de renderizar la plantilla.
    if stale?(:last_modified => @article.published_at.utc, :etag => @article)
      respond_to do |wants|
        # procesamiento normal de la respuesta
      end
    end
  end

  def show_with_implied_render
    @article = Article.find(params[:id])

    # Establece las cabeceras de respuesta y las verifica con la solicitud, si la solicitud está obsoleta
    # (es decir, no coincide ni con la etag ni con la última modificación), entonces se produce la renderización predeterminada de la plantilla.
    # Si la solicitud está actualizada, entonces la renderización predeterminada devolverá un "304 Not Modified"
    # en lugar de renderizar la plantilla.
    fresh_when(:last_modified => @article.published_at.utc, :etag => @article)
  end
end
```

Seguridad de hilos
------------------

El trabajo realizado para hacer que Rails sea seguro para hilos se está implementando en Rails 2.2. Dependiendo de la infraestructura de tu servidor web, esto significa que puedes manejar más solicitudes con menos copias de Rails en memoria, lo que lleva a un mejor rendimiento del servidor y una mayor utilización de múltiples núcleos.
Para habilitar la despachador multihilo en el modo de producción de tu aplicación, agrega la siguiente línea en tu `config/environments/production.rb`:

```ruby
config.threadsafe!
```

* Más información:
    * [Thread safety for your Rails](http://m.onkey.org/2008/10/23/thread-safety-for-your-rails)
    * [Thread safety project announcement](https://weblog.rubyonrails.org/2008/8/16/josh-peek-officially-joins-the-rails-core)
    * [Q/A: What Thread-safe Rails Means](http://blog.headius.com/2008/08/qa-what-thread-safe-rails-means.html)

Active Record
-------------

Hay dos grandes adiciones para hablar aquí: migraciones transaccionales y transacciones de base de datos en grupo. También hay una nueva sintaxis (y más limpia) para las condiciones de las tablas de unión, así como una serie de mejoras más pequeñas.

### Migraciones Transaccionales

Históricamente, las migraciones de múltiples pasos en Rails han sido una fuente de problemas. Si algo salía mal durante una migración, todo antes del error cambiaba la base de datos y todo después del error no se aplicaba. Además, la versión de la migración se almacenaba como ejecutada, lo que significa que no se podía simplemente volver a ejecutar con `rake db:migrate:redo` después de solucionar el problema. Las migraciones transaccionales cambian esto envolviendo los pasos de migración en una transacción DDL, de modo que si alguno de ellos falla, se deshace toda la migración. En Rails 2.2, las migraciones transaccionales son compatibles con PostgreSQL de forma predeterminada. El código es extensible a otros tipos de bases de datos en el futuro, y IBM ya lo ha extendido para admitir el adaptador DB2.

* Contribuidor principal: [Adam Wiggins](http://about.adamwiggins.com/)
* Más información:
    * [DDL Transactions](http://adam.heroku.com/past/2008/9/3/ddl_transactions/)
    * [A major milestone for DB2 on Rails](http://db2onrails.com/2008/11/08/a-major-milestone-for-db2-on-rails/)

### Pool de Conexiones

El pool de conexiones permite a Rails distribuir las solicitudes de base de datos en un conjunto de conexiones de base de datos que crecerá hasta un tamaño máximo (por defecto 5, pero puedes agregar una clave `pool` a tu `database.yml` para ajustar esto). Esto ayuda a eliminar cuellos de botella en aplicaciones que admiten muchos usuarios concurrentes. También hay un `wait_timeout` que por defecto es de 5 segundos antes de rendirse. `ActiveRecord::Base.connection_pool` te da acceso directo al pool si lo necesitas.

```yaml
development:
  adapter: mysql
  username: root
  database: sample_development
  pool: 10
  wait_timeout: 10
```

* Contribuidor principal: [Nick Sieger](http://blog.nicksieger.com/)
* Más información:
    * [What's New in Edge Rails: Connection Pools](http://archives.ryandaigle.com/articles/2008/9/7/what-s-new-in-edge-rails-connection-pools)

### Hashes para Condiciones de Tablas de Unión

Ahora puedes especificar condiciones en tablas de unión utilizando un hash. Esto es de gran ayuda si necesitas hacer consultas a través de uniones complejas.

```ruby
class Photo < ActiveRecord::Base
  belongs_to :product
end

class Product < ActiveRecord::Base
  has_many :photos
end

# Obtén todos los productos con fotos sin derechos de autor:
Product.all(:joins => :photos, :conditions => { :photos => { :copyright => false }})
```

* Más información:
    * [What's New in Edge Rails: Easy Join Table Conditions](http://archives.ryandaigle.com/articles/2008/7/7/what-s-new-in-edge-rails-easy-join-table-conditions)

### Nuevos Buscadores Dinámicos

Se han agregado dos nuevos conjuntos de métodos a la familia de buscadores dinámicos de Active Record.

#### `find_last_by_attribute`

El método `find_last_by_attribute` es equivalente a `Model.last(:conditions => {:attribute => value})`

```ruby
# Obtén el último usuario que se registró desde Londres
User.find_last_by_city('London')
```

* Contribuidor principal: [Emilio Tagua](http://www.workingwithrails.com/person/9147-emilio-tagua)

#### `find_by_attribute!`

La nueva versión con bang! de `find_by_attribute!` es equivalente a `Model.first(:conditions => {:attribute => value}) || raise ActiveRecord::RecordNotFound` En lugar de devolver `nil` si no encuentra un registro coincidente, este método lanzará una excepción si no encuentra una coincidencia.

```ruby
# ¡Lanza una excepción ActiveRecord::RecordNotFound si 'Moby' aún no se ha registrado!
User.find_by_name!('Moby')
```

* Contribuidor principal: [Josh Susser](http://blog.hasmanythrough.com)

### Las Asociaciones Respetan el Alcance Privado/Protegido

Los proxies de asociación de Active Record ahora respetan el alcance de los métodos en el objeto proxy. Anteriormente (dado que User tiene_one :account) `@user.account.private_method` llamaría al método privado en el objeto Account asociado. Eso falla en Rails 2.2; si necesitas esta funcionalidad, debes usar `@user.account.send(:private_method)` (o hacer que el método sea público en lugar de privado o protegido). Ten en cuenta que si estás sobrescribiendo `method_missing`, también debes sobrescribir `respond_to` para que coincida con el comportamiento para que las asociaciones funcionen normalmente.

* Contribuidor principal: Adam Milligan
* Más información:
    * [Rails 2.2 Change: Private Methods on Association Proxies are Private](http://afreshcup.com/2008/10/24/rails-22-change-private-methods-on-association-proxies-are-private/)

### Otros Cambios en Active Record

* `rake db:migrate:redo` ahora acepta un VERSION opcional para apuntar a una migración específica para rehacerla
* Establece `config.active_record.timestamped_migrations = false` para tener migraciones con prefijo numérico en lugar de marca de tiempo UTC.
* Las columnas de contador de caché (para asociaciones declaradas con `:counter_cache => true`) ya no necesitan inicializarse en cero.
* `ActiveRecord::Base.human_name` para una traducción humana consciente de la internacionalización de los nombres de los modelos

Action Controller
-----------------

En el lado del controlador, hay varios cambios que ayudarán a limpiar tus rutas. También hay algunos cambios internos en el motor de enrutamiento para reducir el uso de memoria en aplicaciones complejas.
### Anidamiento de Rutas Superficiales

El anidamiento de rutas superficiales proporciona una solución a la conocida dificultad de utilizar recursos anidados en profundidad. Con el anidamiento superficial, solo necesitas proporcionar suficiente información para identificar de manera única el recurso con el que deseas trabajar.

```ruby
map.resources :publishers, :shallow => true do |publisher|
  publisher.resources :magazines do |magazine|
    magazine.resources :photos
  end
end
```

Esto permitirá el reconocimiento de (entre otros) estas rutas:

```
/publishers/1           ==> publisher_path(1)
/publishers/1/magazines ==> publisher_magazines_path(1)
/magazines/2            ==> magazine_path(2)
/magazines/2/photos     ==> magazines_photos_path(2)
/photos/3               ==> photo_path(3)
```

* Contribuidor Principal: [S. Brent Faulkner](http://www.unwwwired.net/)
* Más información:
    * [Rails Routing from the Outside In](routing.html#nested-resources)
    * [What's New in Edge Rails: Shallow Routes](http://archives.ryandaigle.com/articles/2008/9/7/what-s-new-in-edge-rails-shallow-routes)

### Arrays de Métodos para Rutas de Miembros o Colecciones

Ahora puedes proporcionar un array de métodos para nuevas rutas de miembros o colecciones. Esto elimina la molestia de tener que definir una ruta que acepte cualquier verbo tan pronto como necesites que maneje más de uno. Con Rails 2.2, esta es una declaración de ruta legítima:

```ruby
map.resources :photos, :collection => { :search => [:get, :post] }
```

* Contribuidor Principal: [Brennan Dunn](http://brennandunn.com/)

### Recursos con Acciones Específicas

Por defecto, cuando utilizas `map.resources` para crear una ruta, Rails genera rutas para siete acciones predeterminadas (index, show, create, new, edit, update y destroy). Pero cada una de estas rutas ocupa memoria en tu aplicación y hace que Rails genere lógica de enrutamiento adicional. Ahora puedes utilizar las opciones `:only` y `:except` para ajustar las rutas que Rails generará para los recursos. Puedes proporcionar una sola acción, un array de acciones o las opciones especiales `:all` o `:none`. Estas opciones se heredan en los recursos anidados.

```ruby
map.resources :photos, :only => [:index, :show]
map.resources :products, :except => :destroy
```

* Contribuidor Principal: [Tom Stuart](http://experthuman.com/)

### Otros Cambios en Action Controller

* Ahora puedes mostrar fácilmente una página de error personalizada para excepciones generadas durante el enrutamiento de una solicitud.
* El encabezado HTTP Accept está desactivado de forma predeterminada ahora. Deberías preferir el uso de URLs con formato (como `/customers/1.xml`) para indicar el formato que deseas. Si necesitas los encabezados Accept, puedes activarlos nuevamente con `config.action_controller.use_accept_header = true`.
* Los números de benchmarking ahora se informan en milisegundos en lugar de fracciones diminutas de segundos.
* Rails ahora admite cookies solo para HTTP (y las utiliza para sesiones), lo que ayuda a mitigar algunos riesgos de scripting entre sitios en navegadores más nuevos.
* `redirect_to` ahora admite completamente los esquemas de URI (por lo tanto, por ejemplo, puedes redirigir a un URI `svn:ssh`).
* `render` ahora admite una opción `:js` para renderizar JavaScript simple con el tipo MIME correcto.
* La protección contra falsificación de solicitudes se ha mejorado para aplicarse solo a solicitudes de contenido con formato HTML.
* Las URL polimórficas se comportan de manera más sensata si un parámetro pasado es nulo. Por ejemplo, llamar a `polymorphic_path([@project, @date, @area])` con una fecha nula te dará `project_area_path`.

Action View
-----------

* `javascript_include_tag` y `stylesheet_link_tag` admiten una nueva opción `:recursive` que se utiliza junto con `:all`, para que puedas cargar un árbol completo de archivos con una sola línea de código.
* La biblioteca de JavaScript Prototype incluida se ha actualizado a la versión 1.6.0.3.
* `RJS#page.reload` para volver a cargar la ubicación actual del navegador mediante JavaScript.
* El ayudante `atom_feed` ahora acepta una opción `:instruct` para permitirte insertar instrucciones de procesamiento XML.

Action Mailer
-------------

Action Mailer ahora admite diseños de mailer. Puedes hacer que tus correos electrónicos HTML sean tan bonitos como tus vistas en el navegador al proporcionar un diseño con el nombre adecuado, por ejemplo, la clase `CustomerMailer` espera usar `layouts/customer_mailer.html.erb`.

* Más información:
    * [What's New in Edge Rails: Mailer Layouts](http://archives.ryandaigle.com/articles/2008/9/7/what-s-new-in-edge-rails-mailer-layouts)

Action Mailer ahora ofrece soporte incorporado para los servidores SMTP de GMail, activando automáticamente STARTTLS. Esto requiere que Ruby 1.8.7 esté instalado.

Active Support
--------------

Active Support ahora ofrece memoización incorporada para aplicaciones Rails, el método `each_with_object`, soporte de prefijos en delegados y varios otros métodos de utilidad nuevos.

### Memoización

La memoización es un patrón de inicializar un método una vez y luego guardar su valor para su uso repetido. Probablemente hayas utilizado este patrón en tus propias aplicaciones:

```ruby
def full_name
  @full_name ||= "#{first_name} #{last_name}"
end
```

La memoización te permite manejar esta tarea de manera declarativa:

```ruby
extend ActiveSupport::Memoizable

def full_name
  "#{first_name} #{last_name}"
end
memoize :full_name
```

Otras características de la memoización incluyen `unmemoize`, `unmemoize_all` y `memoize_all` para activar o desactivar la memoización.
* Contribuidor principal: [Josh Peek](http://joshpeek.com/)
* Más información:
    * [Novedades en Edge Rails: Fácil memoización](http://archives.ryandaigle.com/articles/2008/7/16/what-s-new-in-edge-rails-memoization)
    * [¿Memo-qué? Una guía de memoización](http://www.railway.at/articles/2008/09/20/a-guide-to-memoization)

### each_with_object

El método `each_with_object` proporciona una alternativa a `inject`, utilizando un método retroportado de Ruby 1.9. Itera sobre una colección, pasando el elemento actual y el memo al bloque.

```ruby
%w(foo bar).each_with_object({}) { |str, hsh| hsh[str] = str.upcase } # => {'foo' => 'FOO', 'bar' => 'BAR'}
```

Contribuidor principal: [Adam Keys](http://therealadam.com/)

### Delegados con prefijos

Si delegas comportamiento de una clase a otra, ahora puedes especificar un prefijo que se utilizará para identificar los métodos delegados. Por ejemplo:

```ruby
class Vendor < ActiveRecord::Base
  has_one :account
  delegate :email, :password, :to => :account, :prefix => true
end
```

Esto producirá los métodos delegados `vendor#account_email` y `vendor#account_password`. También puedes especificar un prefijo personalizado:

```ruby
class Vendor < ActiveRecord::Base
  has_one :account
  delegate :email, :password, :to => :account, :prefix => :owner
end
```

Esto producirá los métodos delegados `vendor#owner_email` y `vendor#owner_password`.

Contribuidor principal: [Daniel Schierbeck](http://workingwithrails.com/person/5830-daniel-schierbeck)

### Otros cambios en Active Support

* Actualizaciones extensivas en `ActiveSupport::Multibyte`, incluyendo correcciones de compatibilidad con Ruby 1.9.
* La adición de `ActiveSupport::Rescuable` permite que cualquier clase mezcle la sintaxis `rescue_from`.
* `past?`, `today?` y `future?` para las clases `Date` y `Time` para facilitar las comparaciones de fechas y horas.
* `Array#second` a través de `Array#fifth` como alias para `Array#[1]` a través de `Array#[4]`.
* `Enumerable#many?` para encapsular `collection.size > 1`.
* `Inflector#parameterize` produce una versión lista para URL de su entrada, para su uso en `to_param`.
* `Time#advance` reconoce días y semanas fraccionales, por lo que puedes hacer `1.7.weeks.ago`, `1.5.hours.since`, y así sucesivamente.
* La biblioteca TzInfo incluida se ha actualizado a la versión 0.3.12.
* `ActiveSupport::StringInquirer` te proporciona una forma elegante de probar la igualdad en cadenas: `ActiveSupport::StringInquirer.new("abc").abc? => true`

Railties
--------

En Railties (el código principal de Rails en sí), los cambios más importantes están en el mecanismo `config.gems`.

### config.gems

Para evitar problemas de implementación y hacer que las aplicaciones de Rails sean más autosuficientes, es posible colocar copias de todas las gemas que tu aplicación de Rails requiere en `/vendor/gems`. Esta capacidad apareció por primera vez en Rails 2.1, pero es mucho más flexible y robusta en Rails 2.2, manejando dependencias complicadas entre gemas. La gestión de gemas en Rails incluye estos comandos:

* `config.gem _nombre_gema_` en tu archivo `config/environment.rb`
* `rake gems` para listar todas las gemas configuradas, así como si están instaladas, congeladas o del framework (las gemas del framework son aquellas cargadas por Rails antes de que se ejecute el código de dependencia de gemas; dichas gemas no se pueden congelar)
* `rake gems:install` para instalar las gemas faltantes en la computadora
* `rake gems:unpack` para colocar una copia de las gemas requeridas en `/vendor/gems`
* `rake gems:unpack:dependencies` para obtener copias de las gemas requeridas y sus dependencias en `/vendor/gems`
* `rake gems:build` para construir cualquier extensión nativa faltante
* `rake gems:refresh_specs` para alinear las gemas vendidas creadas con Rails 2.1 con la forma de almacenarlas en Rails 2.2

Puedes desempaquetar o instalar una sola gema especificando `GEM=_nombre_gema_` en la línea de comandos.

* Contribuidor principal: [Matt Jones](https://github.com/al2o3cr)
* Más información:
    * [Novedades en Edge Rails: Dependencias de gemas](http://archives.ryandaigle.com/articles/2008/4/1/what-s-new-in-edge-rails-gem-dependencies)
    * [Rails 2.1.2 y 2.2RC1: Actualiza tus RubyGems](https://afreshcup.com/home/2008/10/25/rails-212-and-22rc1-update-your-rubygems)
    * [Discusión detallada en Lighthouse](http://rails.lighthouseapp.com/projects/8994-ruby-on-rails/tickets/1128)

### Otros cambios en Railties

* Si eres fan del servidor web [Thin](http://code.macournoyer.com/thin/), te alegrará saber que `script/server` ahora admite Thin directamente.
* `script/plugin install &lt;plugin&gt; -r &lt;revision&gt;` ahora funciona con plugins basados en git y svn.
* `script/console` ahora admite la opción `--debugger`.
* Las instrucciones para configurar un servidor de integración continua para construir Rails en sí están incluidas en el código fuente de Rails.
* `rake notes:custom ANNOTATION=MYFLAG` te permite listar anotaciones personalizadas.
* Se envolvió `Rails.env` en `StringInquirer` para que puedas hacer `Rails.env.development?`.
* Para eliminar advertencias de deprecación y manejar correctamente las dependencias de gemas, Rails ahora requiere rubygems 1.3.1 o superior.

Obsoletos
----------

Algunas piezas de código más antiguas están obsoletas en esta versión:

* `Rails::SecretKeyGenerator` ha sido reemplazado por `ActiveSupport::SecureRandom`.
* `render_component` está obsoleto. Hay un [plugin render_components](https://github.com/rails/render_component/tree/master) disponible si necesitas esta funcionalidad.
* Se ha obsoleto la asignación local implícita al renderizar parciales.

    ```ruby
    def partial_with_implicit_local_assignment
      @customer = Customer.new("Marcel")
      render :partial => "customer"
    end
    ```

    Anteriormente, el código anterior hacía disponible una variable local llamada `customer` dentro del parcial 'customer'. Ahora debes pasar explícitamente todas las variables a través del hash `:locals`.
* `country_select` ha sido eliminado. Consulta la [página de deprecación](http://www.rubyonrails.org/deprecation/list-of-countries) para obtener más información y un reemplazo de complemento.
* `ActiveRecord::Base.allow_concurrency` ya no tiene ningún efecto.
* `ActiveRecord::Errors.default_error_messages` ha sido deprecado a favor de `I18n.translate('activerecord.errors.messages')`.
* La sintaxis de interpolación `%s` y `%d` para internacionalización está deprecada.
* `String#chars` ha sido deprecado a favor de `String#mb_chars`.
* Las duraciones de meses fraccionarios o años fraccionarios están deprecadas. Utiliza la aritmética de las clases `Date` y `Time` del núcleo de Ruby en su lugar.
* `Request#relative_url_root` está deprecado. Utiliza `ActionController::Base.relative_url_root` en su lugar.

Créditos
-------

Notas de lanzamiento compiladas por [Mike Gunderloy](http://afreshcup.com)
