**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 3cf93e3667cdacd242332d2d352d53fa
Depuración de aplicaciones Rails
============================

Esta guía presenta técnicas para depurar aplicaciones Ruby on Rails.

Después de leer esta guía, sabrás:

* El propósito de la depuración.
* Cómo encontrar problemas e incidencias en tu aplicación que tus pruebas no están identificando.
* Las diferentes formas de depuración.
* Cómo analizar la traza de la pila.

--------------------------------------------------------------------------------

Helpers de vista para depuración
--------------------------

Una tarea común es inspeccionar el contenido de una variable. Rails proporciona tres formas diferentes de hacer esto:

* `debug`
* `to_yaml`
* `inspect`

### `debug`

El helper `debug` devolverá una etiqueta \<pre> que renderiza el objeto utilizando el formato YAML. Esto generará datos legibles por humanos a partir de cualquier objeto. Por ejemplo, si tienes este código en una vista:

```html+erb
<%= debug @article %>
<p>
  <b>Título:</b>
  <%= @article.title %>
</p>
```

Verás algo como esto:

```yaml
--- !ruby/object Article
attributes:
  updated_at: 2008-09-05 22:55:47
  body: Es una guía muy útil para depurar tu aplicación Rails.
  title: Guía de depuración de Rails
  published: t
  id: "1"
  created_at: 2008-09-05 22:55:47
attributes_cache: {}


Título: Guía de depuración de Rails
```

### `to_yaml`

Alternativamente, llamar a `to_yaml` en cualquier objeto lo convierte en YAML. Puedes pasar este objeto convertido al método helper `simple_format` para formatear la salida. Así es como `debug` hace su magia.

```html+erb
<%= simple_format @article.to_yaml %>
<p>
  <b>Título:</b>
  <%= @article.title %>
</p>
```

El código anterior renderizará algo como esto:

```yaml
--- !ruby/object Article
attributes:
updated_at: 2008-09-05 22:55:47
body: Es una guía muy útil para depurar tu aplicación Rails.
title: Guía de depuración de Rails
published: t
id: "1"
created_at: 2008-09-05 22:55:47
attributes_cache: {}

Título: Guía de depuración de Rails
```

### `inspect`

Otro método útil para mostrar valores de objetos es `inspect`, especialmente cuando se trabaja con arrays o hashes. Esto imprimirá el valor del objeto como una cadena. Por ejemplo:

```html+erb
<%= [1, 2, 3, 4, 5].inspect %>
<p>
  <b>Título:</b>
  <%= @article.title %>
</p>
```

Renderizará:

```
[1, 2, 3, 4, 5]

Título: Guía de depuración de Rails
```

El Logger
----------

También puede ser útil guardar información en archivos de registro en tiempo de ejecución. Rails mantiene un archivo de registro separado para cada entorno de ejecución.

### ¿Qué es el Logger?

Rails utiliza la clase `ActiveSupport::Logger` para escribir información de registro. Otros registradores, como `Log4r`, también se pueden sustituir.

Puedes especificar un registrador alternativo en `config/application.rb` o en cualquier otro archivo de entorno, por ejemplo:

```ruby
config.logger = Logger.new(STDOUT)
config.logger = Log4r::Logger.new("Registro de la aplicación")
```

O en la sección `Initializer`, agrega _cualquiera_ de los siguientes

```ruby
Rails.logger = Logger.new(STDOUT)
Rails.logger = Log4r::Logger.new("Registro de la aplicación")
```

CONSEJO: Por defecto, cada registro se crea en `Rails.root/log/` y el archivo de registro lleva el nombre del entorno en el que se está ejecutando la aplicación.

### Niveles de registro

Cuando se registra algo, se imprime en el registro correspondiente si el nivel de registro del mensaje es igual o mayor que el nivel de registro configurado. Si quieres saber el nivel de registro actual, puedes llamar al método `Rails.logger.level`.

Los niveles de registro disponibles son: `:debug`, `:info`, `:warn`, `:error`, `:fatal`,
y `:unknown`, correspondientes a los números de nivel de registro del 0 al 5,
respectivamente. Para cambiar el nivel de registro predeterminado, utiliza
```ruby
config.log_level = :warn # En cualquier inicializador de entorno, o
Rails.logger.level = 0 # en cualquier momento
```

Esto es útil cuando quieres registrar bajo desarrollo o puesta en escena sin inundar el registro de producción con información innecesaria.

CONSEJO: El nivel de registro predeterminado de Rails es `:debug`. Sin embargo, se establece en `:info` para el entorno `production` en el archivo `config/environments/production.rb` generado por defecto.

### Envío de mensajes

Para escribir en el registro actual, utiliza el método `logger.(debug|info|warn|error|fatal|unknown)` desde un controlador, modelo o mailer:

```ruby
logger.debug "Hash de atributos de la persona: #{@person.attributes}"
logger.info "Procesando la solicitud..."
logger.fatal "¡Terminando la aplicación, se produjo un error irrecuperable!"
```

Aquí hay un ejemplo de un método instrumentado con registros adicionales:

```ruby
class ArticlesController < ApplicationController
  # ...

  def create
    @article = Article.new(article_params)
    logger.debug "Nuevo artículo: #{@article.attributes}"
    logger.debug "El artículo debería ser válido: #{@article.valid?}"

    if @article.save
      logger.debug "El artículo se guardó y ahora el usuario será redirigido..."
      redirect_to @article, notice: 'El artículo se creó correctamente.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  # ...

  private
    def article_params
      params.require(:article).permit(:title, :body, :published)
    end
end
```

Aquí hay un ejemplo del registro generado cuando se ejecuta esta acción del controlador:

```
Started POST "/articles" for 127.0.0.1 at 2018-10-18 20:09:23 -0400
Processing by ArticlesController#create as HTML
  Parameters: {"utf8"=>"✓", "authenticity_token"=>"XLveDrKzF1SwaiNRPTaMtkrsTzedtebPPkmxEFIU0ordLjICSnXsSNfrdMa4ccyBjuGwnnEiQhEoMN6H1Gtz3A==", "article"=>{"title"=>"Depurando Rails", "body"=>"Estoy aprendiendo cómo imprimir en los registros.", "published"=>"0"}, "commit"=>"Crear artículo"}
Nuevo artículo: {"id"=>nil, "title"=>"Depurando Rails", "body"=>"Estoy aprendiendo cómo imprimir en los registros.", "published"=>false, "created_at"=>nil, "updated_at"=>nil}
El artículo debería ser válido: true
   (0.0ms)  begin transaction
  ↳ app/controllers/articles_controller.rb:31
  Article Create (0.5ms)  INSERT INTO "articles" ("title", "body", "published", "created_at", "updated_at") VALUES (?, ?, ?, ?, ?)  [["title", "Depurando Rails"], ["body", "Estoy aprendiendo cómo imprimir en los registros."], ["published", 0], ["created_at", "2018-10-19 00:09:23.216549"], ["updated_at", "2018-10-19 00:09:23.216549"]]
  ↳ app/controllers/articles_controller.rb:31
   (2.3ms)  commit transaction
  ↳ app/controllers/articles_controller.rb:31
El artículo se guardó y ahora el usuario será redirigido...
Redirigiendo a http://localhost:3000/articles/1
Completed 302 Found in 4ms (ActiveRecord: 0.8ms)
```

Agregar registros adicionales como este facilita la búsqueda de comportamientos inesperados o inusuales en tus registros. Si agregas registros adicionales, asegúrate de hacer un uso sensato de los niveles de registro para evitar llenar tus registros de producción con trivialidades inútiles.

### Registros detallados de consultas

Cuando se observa la salida de las consultas a la base de datos en los registros, es posible que no sea evidente de inmediato por qué se desencadenan múltiples consultas a la base de datos cuando se llama a un solo método:

```
irb(main):001:0> Article.pamplemousse
  Article Load (0.4ms)  SELECT "articles".* FROM "articles"
  Comment Load (0.2ms)  SELECT "comments".* FROM "comments" WHERE "comments"."article_id" = ?  [["article_id", 1]]
  Comment Load (0.1ms)  SELECT "comments".* FROM "comments" WHERE "comments"."article_id" = ?  [["article_id", 2]]
  Comment Load (0.1ms)  SELECT "comments".* FROM "comments" WHERE "comments"."article_id" = ?  [["article_id", 3]]
=> #<Comment id: 2, author: "1", body: "Bueno, en realidad...", article_id: 1, created_at: "2018-10-19 00:56:10", updated_at: "2018-10-19 00:56:10">
```

Después de ejecutar `ActiveRecord.verbose_query_logs = true` en la sesión de `bin/rails console` para habilitar los registros detallados de consultas y volver a ejecutar el método, se vuelve evidente qué línea de código está generando todas estas llamadas discretas a la base de datos:

```
irb(main):003:0> Article.pamplemousse
  Article Load (0.2ms)  SELECT "articles".* FROM "articles"
  ↳ app/models/article.rb:5
  Comment Load (0.1ms)  SELECT "comments".* FROM "comments" WHERE "comments"."article_id" = ?  [["article_id", 1]]
  ↳ app/models/article.rb:6
  Comment Load (0.1ms)  SELECT "comments".* FROM "comments" WHERE "comments"."article_id" = ?  [["article_id", 2]]
  ↳ app/models/article.rb:6
  Comment Load (0.1ms)  SELECT "comments".* FROM "comments" WHERE "comments"."article_id" = ?  [["article_id", 3]]
  ↳ app/models/article.rb:6
=> #<Comment id: 2, author: "1", body: "Bueno, en realidad...", article_id: 1, created_at: "2018-10-19 00:56:10", updated_at: "2018-10-19 00:56:10">
```
A continuación de cada declaración de base de datos, se pueden ver flechas que apuntan al nombre de archivo fuente específico (y número de línea) del método que resultó en una llamada a la base de datos. Esto puede ayudarlo a identificar y solucionar problemas de rendimiento causados por consultas N+1: consultas de base de datos individuales que generan múltiples consultas adicionales.

Los registros detallados de consultas están habilitados de forma predeterminada en los registros del entorno de desarrollo después de Rails 5.2.

ADVERTENCIA: Recomendamos no utilizar esta configuración en entornos de producción. Se basa en el método `Kernel#caller` de Ruby, que tiende a asignar mucha memoria para generar trazas de llamadas a métodos. En su lugar, utilice etiquetas de registro de consultas (consulte a continuación).

### Registros de encolado detallados

Similar a los "Registros de consultas detallados" anteriores, permite imprimir ubicaciones de origen de los métodos que encolan trabajos en segundo plano.

Está habilitado de forma predeterminada en desarrollo. Para habilitarlo en otros entornos, agregue en `application.rb` o cualquier inicializador de entorno:

```rb
config.active_job.verbose_enqueue_logs = true
```

Al igual que los registros de consultas detallados, no se recomienda su uso en entornos de producción.

Comentarios de consulta SQL
------------------

Las declaraciones SQL se pueden comentar con etiquetas que contienen información en tiempo de ejecución, como el nombre del controlador o trabajo, para rastrear consultas problemáticas hasta la área de la aplicación que generó estas declaraciones. Esto es útil cuando se registran consultas lentas (por ejemplo, [MySQL](https://dev.mysql.com/doc/refman/en/slow-query-log.html), [PostgreSQL](https://www.postgresql.org/docs/current/runtime-config-logging.html#GUC-LOG-MIN-DURATION-STATEMENT)), se ven consultas en ejecución actualmente o se utilizan herramientas de trazado de extremo a extremo.

Para habilitar, agregue en `application.rb` o cualquier inicializador de entorno:

```rb
config.active_record.query_log_tags_enabled = true
```

De forma predeterminada, se registran el nombre de la aplicación, el nombre y la acción del controlador o el nombre del trabajo. El formato predeterminado es [SQLCommenter](https://open-telemetry.github.io/opentelemetry-sqlcommenter/). Por ejemplo:

```
Article Load (0.2ms)  SELECT "articles".* FROM "articles" /*application='Blog',controller='articles',action='index'*/

Article Update (0.3ms)  UPDATE "articles" SET "title" = ?, "updated_at" = ? WHERE "posts"."id" = ? /*application='Blog',job='ImproveTitleJob'*/  [["title", "Improved Rails debugging guide"], ["updated_at", "2022-10-16 20:25:40.091371"], ["id", 1]]
```

El comportamiento de [`ActiveRecord::QueryLogs`](https://api.rubyonrails.org/classes/ActiveRecord/QueryLogs.html) se puede modificar para incluir cualquier cosa que ayude a conectar los puntos desde la consulta SQL, como identificadores de solicitud y trabajo para registros de aplicación, identificadores de cuenta y inquilino, etc.

### Registro etiquetado

Cuando se ejecutan aplicaciones multiusuario y multi cuenta, a menudo es útil poder filtrar los registros utilizando reglas personalizadas. `TaggedLogging` en Active Support te ayuda a hacer exactamente eso, estampando líneas de registro con subdominios, identificadores de solicitud y cualquier otra cosa que ayude a depurar dichas aplicaciones.

```ruby
logger = ActiveSupport::TaggedLogging.new(Logger.new(STDOUT))
logger.tagged("BCX") { logger.info "Stuff" }                            # Registra "[BCX] Stuff"
logger.tagged("BCX", "Jason") { logger.info "Stuff" }                   # Registra "[BCX] [Jason] Stuff"
logger.tagged("BCX") { logger.tagged("Jason") { logger.info "Stuff" } } # Registra "[BCX] [Jason] Stuff"
```

### Impacto de los registros en el rendimiento

El registro siempre tendrá un pequeño impacto en el rendimiento de su aplicación de Rails, especialmente cuando se registra en disco. Además, hay algunas sutilezas:

El uso del nivel `:debug` tendrá un mayor impacto en el rendimiento que `:fatal`, ya que se evalúan y escriben en la salida del registro (por ejemplo, en disco) una cantidad mucho mayor de cadenas.

Otro posible problema es realizar demasiadas llamadas a `Logger` en su código:

```ruby
logger.debug "Person attributes hash: #{@person.attributes.inspect}"
```

En el ejemplo anterior, habrá un impacto en el rendimiento incluso si el nivel de salida permitido no incluye el modo de depuración. La razón es que Ruby tiene que evaluar estas cadenas, lo que incluye instanciar el objeto `String` algo pesado e interpolando las variables.
Por lo tanto, se recomienda pasar bloques a los métodos del registrador, ya que solo se evalúan si el nivel de salida es el mismo que el nivel permitido (es decir, carga perezosa). El mismo código reescrito sería:

```ruby
logger.debug { "Hash de atributos de la persona: #{@person.attributes.inspect}" }
```

El contenido del bloque, y por lo tanto la interpolación de cadenas, solo se evalúan si se habilita la depuración. Estos ahorros de rendimiento solo son realmente perceptibles con grandes cantidades de registros, pero es una buena práctica utilizarlos.

INFO: Esta sección fue escrita por [Jon Cairns en una respuesta de Stack Overflow](https://stackoverflow.com/questions/16546730/logging-in-rails-is-there-any-performance-hit/16546935#16546935) y está bajo licencia [cc by-sa 4.0](https://creativecommons.org/licenses/by-sa/4.0/).

Depuración con la gema `debug`
------------------------------

Cuando tu código se comporta de manera inesperada, puedes intentar imprimir en los registros o en la consola para diagnosticar el problema. Desafortunadamente, hay momentos en los que este tipo de seguimiento de errores no es efectivo para encontrar la causa raíz de un problema. Cuando realmente necesitas adentrarte en tu código fuente en ejecución, el depurador es tu mejor compañero.

El depurador también puede ayudarte si quieres aprender sobre el código fuente de Rails pero no sabes por dónde empezar. Simplemente depura cualquier solicitud a tu aplicación y utiliza esta guía para aprender cómo moverte desde el código que has escrito hacia el código subyacente de Rails.

Rails 7 incluye la gema `debug` en el `Gemfile` de las nuevas aplicaciones generadas por CRuby. Por defecto, está activada en los entornos `development` y `test`. Por favor, consulta su [documentación](https://github.com/ruby/debug) para su uso.

### Entrar en una sesión de depuración

Por defecto, una sesión de depuración comenzará después de que se requiera la biblioteca `debug`, lo cual ocurre cuando tu aplicación se inicia. Pero no te preocupes, la sesión no interferirá con tu aplicación.

Para entrar en la sesión de depuración, puedes utilizar `binding.break` y sus alias: `binding.b` y `debugger`. Los siguientes ejemplos utilizarán `debugger`:

```rb
class PostsController < ApplicationController
  before_action :set_post, only: %i[ show edit update destroy ]

  # GET /posts or /posts.json
  def index
    @posts = Post.all
    debugger
  end
  # ...
end
```

Una vez que tu aplicación evalúe la declaración de depuración, entrará en la sesión de depuración:

```rb
Processing by PostsController#index as HTML
[2, 11] in ~/projects/rails-guide-example/app/controllers/posts_controller.rb
     2|   before_action :set_post, only: %i[ show edit update destroy ]
     3|
     4|   # GET /posts or /posts.json
     5|   def index
     6|     @posts = Post.all
=>   7|     debugger
     8|   end
     9|
    10|   # GET /posts/1 or /posts/1.json
    11|   def show
=>#0    PostsController#index at ~/projects/rails-guide-example/app/controllers/posts_controller.rb:7
  #1    ActionController::BasicImplicitRender#send_action(method="index", args=[]) at ~/.rbenv/versions/3.0.1/lib/ruby/gems/3.0.0/gems/actionpack-7.1.0.alpha/lib/action_controller/metal/basic_implicit_render.rb:6
  # and 72 frames (use `bt' command for all frames)
(rdbg)
```

Puedes salir de la sesión de depuración en cualquier momento y continuar la ejecución de tu aplicación con el comando `continue` (o `c`). O, para salir tanto de la sesión de depuración como de tu aplicación, utiliza el comando `quit` (o `q`).

### El contexto

Después de entrar en la sesión de depuración, puedes escribir código Ruby como si estuvieras en una consola de Rails o IRB.

```rb
(rdbg) @posts    # ruby
[]
(rdbg) self
#<PostsController:0x0000000000aeb0>
(rdbg)
```

También puedes utilizar los comandos `p` o `pp` para evaluar expresiones Ruby, lo cual es útil cuando el nombre de una variable entra en conflicto con un comando del depurador.
```rb
(rdbg) p headers    # comando
=> {"X-Frame-Options"=>"SAMEORIGIN", "X-XSS-Protection"=>"1; mode=block", "X-Content-Type-Options"=>"nosniff", "X-Download-Options"=>"noopen", "X-Permitted-Cross-Domain-Policies"=>"none", "Referrer-Policy"=>"strict-origin-when-cross-origin"}
(rdbg) pp headers    # comando
{"X-Frame-Options"=>"SAMEORIGIN",
 "X-XSS-Protection"=>"1; mode=block",
 "X-Content-Type-Options"=>"nosniff",
 "X-Download-Options"=>"noopen",
 "X-Permitted-Cross-Domain-Policies"=>"none",
 "Referrer-Policy"=>"strict-origin-when-cross-origin"}
(rdbg)
```

Además de la evaluación directa, el depurador también te ayuda a recopilar una gran cantidad de información a través de diferentes comandos, como:

- `info` (o `i`) - Información sobre el marco actual.
- `backtrace` (o `bt`) - Backtrace (con información adicional).
- `outline` (o `o`, `ls`) - Métodos disponibles, constantes, variables locales y variables de instancia en el ámbito actual.

#### El comando `info`

`info` proporciona una descripción general de los valores de las variables locales y de instancia que son visibles desde el marco actual.

```rb
(rdbg) info    # comando
%self = #<PostsController:0x0000000000af78>
@_action_has_layout = true
@_action_name = "index"
@_config = {}
@_lookup_context = #<ActionView::LookupContext:0x00007fd91a037e38 @details_key=nil, @digest_cache=...
@_request = #<ActionDispatch::Request GET "http://localhost:3000/posts" for 127.0.0.1>
@_response = #<ActionDispatch::Response:0x00007fd91a03ea08 @mon_data=#<Monitor:0x00007fd91a03e8c8>...
@_response_body = nil
@_routes = nil
@marked_for_same_origin_verification = true
@posts = []
@rendered_format = nil
```

#### El comando `backtrace`

Cuando se utiliza sin opciones, `backtrace` lista todos los marcos en la pila:

```rb
=>#0    PostsController#index at ~/projects/rails-guide-example/app/controllers/posts_controller.rb:7
  #1    ActionController::BasicImplicitRender#send_action(method="index", args=[]) at ~/.rbenv/versions/3.0.1/lib/ruby/gems/3.0.0/gems/actionpack-7.1.0.alpha/lib/action_controller/metal/basic_implicit_render.rb:6
  #2    AbstractController::Base#process_action(method_name="index", args=[]) at ~/.rbenv/versions/3.0.1/lib/ruby/gems/3.0.0/gems/actionpack-7.1.0.alpha/lib/abstract_controller/base.rb:214
  #3    ActionController::Rendering#process_action(#arg_rest=nil) at ~/.rbenv/versions/3.0.1/lib/ruby/gems/3.0.0/gems/actionpack-7.1.0.alpha/lib/action_controller/metal/rendering.rb:53
  #4    block in process_action at ~/.rbenv/versions/3.0.1/lib/ruby/gems/3.0.0/gems/actionpack-7.1.0.alpha/lib/abstract_controller/callbacks.rb:221
  #5    block in run_callbacks at ~/.rbenv/versions/3.0.1/lib/ruby/gems/3.0.0/gems/activesupport-7.1.0.alpha/lib/active_support/callbacks.rb:118
  #6    ActionText::Rendering::ClassMethods#with_renderer(renderer=#<PostsController:0x0000000000af78>) at ~/.rbenv/versions/3.0.1/lib/ruby/gems/3.0.0/gems/actiontext-7.1.0.alpha/lib/action_text/rendering.rb:20
  #7    block {|controller=#<PostsController:0x0000000000af78>, action=#<Proc:0x00007fd91985f1c0 /Users/st0012/...|} in <class:Engine> (4 levels) at ~/.rbenv/versions/3.0.1/lib/ruby/gems/3.0.0/gems/actiontext-7.1.0.alpha/lib/action_text/engine.rb:69
  #8    [C] BasicObject#instance_exec at ~/.rbenv/versions/3.0.1/lib/ruby/gems/3.0.0/gems/activesupport-7.1.0.alpha/lib/active_support/callbacks.rb:127
  ..... y más
```

Cada marco viene con:

- Identificador del marco
- Ubicación de la llamada
- Información adicional (por ejemplo, argumentos de bloque o método)

Esto te dará una gran idea de lo que está sucediendo en tu aplicación. Sin embargo, probablemente notarás que:

- Hay demasiados marcos (generalmente más de 50 en una aplicación de Rails).
- La mayoría de los marcos son de Rails u otras bibliotecas que utilizas.

El comando `backtrace` proporciona 2 opciones para ayudarte a filtrar los marcos:

- `backtrace [num]` - muestra solo `num` números de marcos, por ejemplo, `backtrace 10`.
- `backtrace /patrón/` - muestra solo los marcos con identificador o ubicación que coinciden con el patrón, por ejemplo, `backtrace /MyModel/`.

También es posible usar estas opciones juntas: `backtrace [num] /patrón/`.

#### El comando `outline`

`outline` es similar al comando `ls` de `pry` e `irb`. Te mostrará lo que es accesible desde el ámbito actual, incluyendo:

- Variables locales
- Variables de instancia
- Variables de clase
- Métodos y sus fuentes

```rb
ActiveSupport::Configurable#methods: config
AbstractController::Base#methods:
  action_methods  action_name  action_name=  available_action?  controller_path  inspect
  response_body
ActionController::Metal#methods:
  content_type       content_type=  controller_name  dispatch          headers
  location           location=      media_type       middleware_stack  middleware_stack=
  middleware_stack?  performed?     request          request=          reset_session
  response           response=      response_body=   response_code     session
  set_request!       set_response!  status           status=           to_a
ActionView::ViewPaths#methods:
  _prefixes  any_templates?  append_view_path   details_for_lookup  formats     formats=  locale
  locale=    lookup_context  prepend_view_path  template_exists?    view_paths
AbstractController::Rendering#methods: view_assigns

# .....

PostsController#methods: create  destroy  edit  index  new  show  update
instance variables:
  @_action_has_layout  @_action_name    @_config  @_lookup_context                      @_request
  @_response           @_response_body  @_routes  @marked_for_same_origin_verification  @posts
  @rendered_format
class variables: @@raise_on_missing_translations  @@raise_on_open_redirects
```

### Puntos de interrupción

Hay muchas formas de insertar y activar un punto de interrupción en el depurador. Además de agregar declaraciones de depuración (por ejemplo, `debugger`) directamente en tu código, también puedes insertar puntos de interrupción con comandos:

- `break` (o `b`)
  - `break` - lista todos los puntos de interrupción
  - `break <num>` - establece un punto de interrupción en la línea `num` del archivo actual
  - `break <file:num>` - establece un punto de interrupción en la línea `num` de `file`
  - `break <Class#method>` o `break <Class.method>` - establece un punto de interrupción en `Class#method` o `Class.method`
  - `break <expr>.<method>` - establece un punto de interrupción en el método `<method>` del resultado de `<expr>`.
- `catch <Exception>` - establece un punto de interrupción que se detendrá cuando se genere `Exception`
- `watch <@ivar>` - establece un punto de interrupción que se detendrá cuando se cambie el resultado de la variable `@ivar` del objeto actual (esto es lento)
Y para eliminarlos, puedes usar:

- `delete` (o `del`)
  - `delete` - eliminar todos los puntos de interrupción
  - `delete <num>` - eliminar el punto de interrupción con el id `num`

#### El comando `break`

**Establecer un punto de interrupción en un número de línea específico - por ejemplo, `b 28`**

```rb
[20, 29] en ~/projects/rails-guide-example/app/controllers/posts_controller.rb
    20|   end
    21|
    22|   # POST /posts or /posts.json
    23|   def create
    24|     @post = Post.new(post_params)
=>  25|     debugger
    26|
    27|     respond_to do |format|
    28|       if @post.save
    29|         format.html { redirect_to @post, notice: "Post was successfully created." }
=>#0    PostsController#create en ~/projects/rails-guide-example/app/controllers/posts_controller.rb:25
  #1    ActionController::BasicImplicitRender#send_action(method="create", args=[]) en ~/.rbenv/versions/3.0.1/lib/ruby/gems/3.0.0/gems/actionpack-7.0.0.alpha2/lib/action_controller/metal/basic_implicit_render.rb:6
  # y 72 marcos (use el comando `bt' para ver todos los marcos)
(rdbg) b 28    # comando break
#0  BP - Línea  /Users/st0012/projects/rails-guide-example/app/controllers/posts_controller.rb:28 (línea)
```

```rb
(rdbg) c    # comando continue
[23, 32] en ~/projects/rails-guide-example/app/controllers/posts_controller.rb
    23|   def create
    24|     @post = Post.new(post_params)
    25|     debugger
    26|
    27|     respond_to do |format|
=>  28|       if @post.save
    29|         format.html { redirect_to @post, notice: "Post was successfully created." }
    30|         format.json { render :show, status: :created, location: @post }
    31|       else
    32|         format.html { render :new, status: :unprocessable_entity }
=>#0    block {|format=#<ActionController::MimeResponds::Collec...|} en create en ~/projects/rails-guide-example/app/controllers/posts_controller.rb:28
  #1    ActionController::MimeResponds#respond_to(mimes=[]) en ~/.rbenv/versions/3.0.1/lib/ruby/gems/3.0.0/gems/actionpack-7.0.0.alpha2/lib/action_controller/metal/mime_responds.rb:205
  # y 74 marcos (use el comando `bt' para ver todos los marcos)

Detenido en #0  BP - Línea  /Users/st0012/projects/rails-guide-example/app/controllers/posts_controller.rb:28 (línea)
```

Establecer un punto de interrupción en una llamada de método específica - por ejemplo, `b @post.save`.

```rb
[20, 29] en ~/projects/rails-guide-example/app/controllers/posts_controller.rb
    20|   end
    21|
    22|   # POST /posts or /posts.json
    23|   def create
    24|     @post = Post.new(post_params)
=>  25|     debugger
    26|
    27|     respond_to do |format|
    28|       if @post.save
    29|         format.html { redirect_to @post, notice: "Post was successfully created." }
=>#0    PostsController#create en ~/projects/rails-guide-example/app/controllers/posts_controller.rb:25
  #1    ActionController::BasicImplicitRender#send_action(method="create", args=[]) en ~/.rbenv/versions/3.0.1/lib/ruby/gems/3.0.0/gems/actionpack-7.0.0.alpha2/lib/action_controller/metal/basic_implicit_render.rb:6
  # y 72 marcos (use el comando `bt' para ver todos los marcos)
(rdbg) b @post.save    # comando break
#0  BP - Método  @post.save en /Users/st0012/.rbenv/versions/3.0.1/lib/ruby/gems/3.0.0/gems/activerecord-7.0.0.alpha2/lib/active_record/suppressor.rb:43

```

```rb
(rdbg) c    # comando continue
[39, 48] en ~/.rbenv/versions/3.0.1/lib/ruby/gems/3.0.0/gems/activerecord-7.0.0.alpha2/lib/active_record/suppressor.rb
    39|         SuppressorRegistry.suppressed[name] = previous_state
    40|       end
    41|     end
    42|
    43|     def save(**) # :nodoc:
=>  44|       SuppressorRegistry.suppressed[self.class.name] ? true : super
    45|     end
    46|
    47|     def save!(**) # :nodoc:
    48|       SuppressorRegistry.suppressed[self.class.name] ? true : super
=>#0    ActiveRecord::Suppressor#save(#arg_rest=nil) en ~/.rbenv/versions/3.0.1/lib/ruby/gems/3.0.0/gems/activerecord-7.0.0.alpha2/lib/active_record/suppressor.rb:44
  #1    block {|format=#<ActionController::MimeResponds::Collec...|} en create en ~/projects/rails-guide-example/app/controllers/posts_controller.rb:28
  # y 75 marcos (use el comando `bt' para ver todos los marcos)

Detenido en #0  BP - Método  @post.save en /Users/st0012/.rbenv/versions/3.0.1/lib/ruby/gems/3.0.0/gems/activerecord-7.0.0.alpha2/lib/active_record/suppressor.rb:43
```

#### El comando `catch`

Detenerse cuando se produce una excepción - por ejemplo, `catch ActiveRecord::RecordInvalid`.

```rb
[20, 29] en ~/projects/rails-guide-example/app/controllers/posts_controller.rb
    20|   end
    21|
    22|   # POST /posts or /posts.json
    23|   def create
    24|     @post = Post.new(post_params)
=>  25|     debugger
    26|
    27|     respond_to do |format|
    28|       if @post.save!
    29|         format.html { redirect_to @post, notice: "Post was successfully created." }
=>#0    PostsController#create en ~/projects/rails-guide-example/app/controllers/posts_controller.rb:25
  #1    ActionController::BasicImplicitRender#send_action(method="create", args=[]) en ~/.rbenv/versions/3.0.1/lib/ruby/gems/3.0.0/gems/actionpack-7.0.0.alpha2/lib/action_controller/metal/basic_implicit_render.rb:6
  # y 72 marcos (use el comando `bt' para ver todos los marcos)
(rdbg) catch ActiveRecord::RecordInvalid    # comando
#1  BP - Catch  "ActiveRecord::RecordInvalid"
```

```rb
(rdbg) c    # comando continue
[75, 84] en ~/.rbenv/versions/3.0.1/lib/ruby/gems/3.0.0/gems/activerecord-7.0.0.alpha2/lib/active_record/validations.rb
    75|     def default_validation_context
    76|       new_record? ? :create : :update
    77|     end
    78|
    79|     def raise_validation_error
=>  80|       raise(RecordInvalid.new(self))
    81|     end
    82|
    83|     def perform_validations(options = {})
    84|       options[:validate] == false || valid?(options[:context])
=>#0    ActiveRecord::Validations#raise_validation_error en ~/.rbenv/versions/3.0.1/lib/ruby/gems/3.0.0/gems/activerecord-7.0.0.alpha2/lib/active_record/validations.rb:80
  #1    ActiveRecord::Validations#save!(options={}) en ~/.rbenv/versions/3.0.1/lib/ruby/gems/3.0.0/gems/activerecord-7.0.0.alpha2/lib/active_record/validations.rb:53
  # y 88 marcos (use el comando `bt' para ver todos los marcos)

Detenido en #1  BP - Catch  "ActiveRecord::RecordInvalid"
```
#### El comando `watch`

Deténgase cuando la variable de instancia cambie, por ejemplo, `watch @_response_body`.

```rb
[20, 29] en ~/projects/rails-guide-example/app/controllers/posts_controller.rb
    20|   end
    21|
    22|   # POST /posts or /posts.json
    23|   def create
    24|     @post = Post.new(post_params)
=>  25|     debugger
    26|
    27|     respond_to do |format|
    28|       if @post.save!
    29|         format.html { redirect_to @post, notice: "El post se creó exitosamente." }
=>#0    PostsController#create en ~/projects/rails-guide-example/app/controllers/posts_controller.rb:25
  #1    ActionController::BasicImplicitRender#send_action(method="create", args=[]) en ~/.rbenv/versions/3.0.1/lib/ruby/gems/3.0.0/gems/actionpack-7.0.0.alpha2/lib/action_controller/metal/basic_implicit_render.rb:6
  # y 72 marcos (use el comando `bt' para ver todos los marcos)
(rdbg) watch @_response_body    # comando
#0  BP - Watch  #<PostsController:0x00007fce69ca5320> @_response_body =
```

```rb
(rdbg) c    # comando continuar
[173, 182] en ~/.rbenv/versions/3.0.1/lib/ruby/gems/3.0.0/gems/actionpack-7.0.0.alpha2/lib/action_controller/metal.rb
   173|       body = [body] unless body.nil? || body.respond_to?(:each)
   174|       response.reset_body!
   175|       return unless body
   176|       response.body = body
   177|       super
=> 178|     end
   179|
   180|     # Tests if render or redirect has already happened.
   181|     def performed?
   182|       response_body || response.committed?
=>#0    ActionController::Metal#response_body=(body=["<html><body>You are being <a href=\"ht...) en ~/.rbenv/versions/3.0.1/lib/ruby/gems/3.0.0/gems/actionpack-7.0.0.alpha2/lib/action_controller/metal.rb:178 #=> ["<html><body>You are being <a href=\"http://localhost:3000/posts/13\">redirected</a>.</body></html>"]
  #1    ActionController::Redirecting#redirect_to(options=#<Post id: 13, title: "qweqwe", content:..., response_options={:allow_other_host=>false}) en ~/.rbenv/versions/3.0.1/lib/ruby/gems/3.0.0/gems/actionpack-7.0.0.alpha2/lib/action_controller/metal/redirecting.rb:74
  # y 82 marcos (use el comando `bt' para ver todos los marcos)

Deténgase en #0  BP - Watch  #<PostsController:0x00007fce69ca5320> @_response_body =  -> ["<html><body>You are being <a href=\"http://localhost:3000/posts/13\">redirected</a>.</body></html>"]
(rdbg)
```

#### Opciones de punto de interrupción

Además de los diferentes tipos de puntos de interrupción, también puede especificar opciones para lograr flujos de trabajo de depuración más avanzados. Actualmente, el depurador admite 4 opciones:

- `do: <cmd o expr>`: cuando se activa el punto de interrupción, ejecuta el comando/expresión dado y continúa el programa:
  - `break Foo#bar do: bt`: cuando se llama a `Foo#bar`, imprime los marcos de la pila.
- `pre: <cmd o expr>`: cuando se activa el punto de interrupción, ejecuta el comando/expresión dado antes de detenerse:
  - `break Foo#bar pre: info`: cuando se llama a `Foo#bar`, imprime las variables circundantes antes de detenerse.
- `if: <expr>`: el punto de interrupción solo se detiene si el resultado de `<expr>` es verdadero:
  - `break Post#save if: params[:debug]`: se detiene en `Post#save` si `params[:debug]` también es verdadero.
- `path: <path_regexp>`: el punto de interrupción solo se detiene si el evento que lo activa (por ejemplo, una llamada a un método) ocurre desde la ruta dada:
  - `break Post#save if: app/services/a_service`: se detiene en `Post#save` si la llamada al método ocurre en un método que coincide con la expresión regular de Ruby `/app\/services\/a_service/`.

También tenga en cuenta que las primeras 3 opciones: `do:`, `pre:` e `if:`, también están disponibles para las declaraciones de depuración que mencionamos anteriormente. Por ejemplo:

```rb
[2, 11] en ~/projects/rails-guide-example/app/controllers/posts_controller.rb
     2|   before_action :set_post, only: %i[ show edit update destroy ]
     3|
     4|   # GET /posts or /posts.json
     5|   def index
     6|     @posts = Post.all
=>   7|     debugger(do: "info")
     8|   end
     9|
    10|   # GET /posts/1 or /posts/1.json
    11|   def show
=>#0    PostsController#index en ~/projects/rails-guide-example/app/controllers/posts_controller.rb:7
  #1    ActionController::BasicImplicitRender#send_action(method="index", args=[]) en ~/.rbenv/versions/3.0.1/lib/ruby/gems/3.0.0/gems/actionpack-7.0.0.alpha2/lib/action_controller/metal/basic_implicit_render.rb:6
  # y 72 marcos (use el comando `bt' para ver todos los marcos)
(rdbg:binding.break) info
%self = #<PostsController:0x00000000017480>
@_action_has_layout = true
@_action_name = "index"
@_config = {}
@_lookup_context = #<ActionView::LookupContext:0x00007fce3ad336b8 @details_key=nil, @digest_cache=...
@_request = #<ActionDispatch::Request GET "http://localhost:3000/posts" for 127.0.0.1>
@_response = #<ActionDispatch::Response:0x00007fce3ad397e8 @mon_data=#<Monitor:0x00007fce3ad396a8>...
@_response_body = nil
@_routes = nil
@marked_for_same_origin_verification = true
@posts = #<ActiveRecord::Relation [#<Post id: 2, title: "qweqwe", content: "qweqwe", created_at: "...
@rendered_format = nil
```
#### Programa tu flujo de trabajo de depuración

Con esas opciones, puedes crear un script para tu flujo de trabajo de depuración en una línea como esta:

```rb
def create
  debugger(do: "catch ActiveRecord::RecordInvalid do: bt 10")
  # ...
end
```

Y luego el depurador ejecutará el comando scriptado e insertará el punto de interrupción de captura

```rb
(rdbg:binding.break) catch ActiveRecord::RecordInvalid do: bt 10
#0  BP - Catch  "ActiveRecord::RecordInvalid"
[75, 84] en ~/.rbenv/versions/3.0.1/lib/ruby/gems/3.0.0/gems/activerecord-7.0.0.alpha2/lib/active_record/validations.rb
    75|     def default_validation_context
    76|       new_record? ? :create : :update
    77|     end
    78|
    79|     def raise_validation_error
=>  80|       raise(RecordInvalid.new(self))
    81|     end
    82|
    83|     def perform_validations(options = {})
    84|       options[:validate] == false || valid?(options[:context])
=>#0    ActiveRecord::Validations#raise_validation_error en ~/.rbenv/versions/3.0.1/lib/ruby/gems/3.0.0/gems/activerecord-7.0.0.alpha2/lib/active_record/validations.rb:80
  #1    ActiveRecord::Validations#save!(options={}) en ~/.rbenv/versions/3.0.1/lib/ruby/gems/3.0.0/gems/activerecord-7.0.0.alpha2/lib/active_record/validations.rb:53
  # y 88 marcos (utiliza el comando `bt' para todos los marcos)
```

Una vez que se activa el punto de interrupción de captura, imprimirá los marcos de la pila

```rb
Detenido por #0  BP - Catch  "ActiveRecord::RecordInvalid"

(rdbg:catch) bt 10
=>#0    ActiveRecord::Validations#raise_validation_error en ~/.rbenv/versions/3.0.1/lib/ruby/gems/3.0.0/gems/activerecord-7.0.0.alpha2/lib/active_record/validations.rb:80
  #1    ActiveRecord::Validations#save!(options={}) en ~/.rbenv/versions/3.0.1/lib/ruby/gems/3.0.0/gems/activerecord-7.0.0.alpha2/lib/active_record/validations.rb:53
  #2    block in save! en ~/.rbenv/versions/3.0.1/lib/ruby/gems/3.0.0/gems/activerecord-7.0.0.alpha2/lib/active_record/transactions.rb:302
```

Esta técnica puede ahorrarte la repetición de la entrada manual y hacer que la experiencia de depuración sea más fluida.

Puedes encontrar más comandos y opciones de configuración en su [documentación](https://github.com/ruby/debug).

Depuración con la gema `web-console`
------------------------------------

Web Console es un poco como `debug`, pero se ejecuta en el navegador. Puedes solicitar una consola en el contexto de una vista o un controlador en cualquier página. La consola se renderizará junto a tu contenido HTML.

### Consola

Dentro de cualquier acción del controlador o vista, puedes invocar la consola llamando al método `console`.

Por ejemplo, en un controlador:

```ruby
class PostsController < ApplicationController
  def new
    console
    @post = Post.new
  end
end
```

O en una vista:

```html+erb
<% console %>

<h2>Nueva publicación</h2>
```

Esto renderizará una consola dentro de tu vista. No necesitas preocuparte por la ubicación de la llamada a `console`; no se renderizará en el lugar de su invocación, sino junto a tu contenido HTML.

La consola ejecuta código Ruby puro: puedes definir e instanciar clases personalizadas, crear nuevos modelos e inspeccionar variables.

NOTA: Solo se puede renderizar una consola por solicitud. De lo contrario, `web-console` generará un error en la segunda invocación de `console`.

### Inspeccionar variables

Puedes invocar `instance_variables` para listar todas las variables de instancia disponibles en tu contexto. Si quieres listar todas las variables locales, puedes hacerlo con `local_variables`.

### Configuración

* `config.web_console.allowed_ips`: Lista autorizada de direcciones IPv4 o IPv6 y redes (por defecto: `127.0.0.1/8, ::1`).
* `config.web_console.whiny_requests`: Registrar un mensaje cuando se evita la renderización de una consola (por defecto: `true`).

Dado que `web-console` evalúa código Ruby puro de forma remota en el servidor, no intentes usarlo en producción.

Depuración de fugas de memoria
----------------------

Una aplicación Ruby (en Rails o no) puede tener fugas de memoria, ya sea en el código Ruby o a nivel de código C.

En esta sección, aprenderás cómo encontrar y solucionar tales fugas utilizando herramientas como Valgrind.

### Valgrind

[Valgrind](http://valgrind.org/) es una aplicación para detectar fugas de memoria y condiciones de carrera basadas en C.

Existen herramientas de Valgrind que pueden detectar automáticamente muchos errores de gestión de memoria y de concurrencia, y perfilar tus programas en detalle. Por ejemplo, si una extensión C en el intérprete llama a `malloc()` pero no llama correctamente a `free()`, esta memoria no estará disponible hasta que la aplicación termine.
Para obtener más información sobre cómo instalar Valgrind y usarlo con Ruby, consulta [Valgrind and Ruby](https://blog.evanweaver.com/2008/02/05/valgrind-and-ruby/) de Evan Weaver.

### Encontrar una fuga de memoria

Hay un excelente artículo sobre cómo detectar y solucionar fugas de memoria en Derailed, [que puedes leer aquí](https://github.com/schneems/derailed_benchmarks#is-my-app-leaking-memory).

Plugins para depurar
---------------------

Existen algunos plugins de Rails que te ayudarán a encontrar errores y depurar tu aplicación. Aquí tienes una lista de plugins útiles para la depuración:

* [Query Trace](https://github.com/ruckus/active-record-query-trace/tree/master) Agrega seguimiento de origen de consultas a tus registros.
* [Exception Notifier](https://github.com/smartinez87/exception_notification/tree/master) Proporciona un objeto mailer y un conjunto predeterminado de plantillas para enviar notificaciones por correo electrónico cuando se producen errores en una aplicación Rails.
* [Better Errors](https://github.com/charliesome/better_errors) Reemplaza la página de error estándar de Rails por una nueva que contiene más información contextual, como código fuente e inspección de variables.
* [RailsPanel](https://github.com/dejan/rails_panel) Extensión de Chrome para el desarrollo de Rails que pondrá fin al seguimiento de development.log. Obtén toda la información sobre las solicitudes de tu aplicación Rails en el navegador, en el panel de Herramientas para desarrolladores. Proporciona información sobre tiempos de db/renderizado/total, lista de parámetros, vistas renderizadas y más.
* [Pry](https://github.com/pry/pry) Una alternativa a IRB y una consola de desarrollo en tiempo de ejecución.

Referencias
----------

* [Página principal de web-console](https://github.com/rails/web-console)
* [Página principal de debug](https://github.com/ruby/debug)
