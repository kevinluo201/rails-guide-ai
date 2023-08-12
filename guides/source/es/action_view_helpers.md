**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 37d2486eee8522a64c5f97f86900b8a6
Ayudantes de Action View
====================

Después de leer esta guía, sabrás:

* Cómo formatear fechas, cadenas y números
* Cómo enlazar imágenes, videos, hojas de estilo, etc...
* Cómo sanitizar contenido
* Cómo localizar contenido

--------------------------------------------------------------------------------

Resumen de los ayudantes proporcionados por Action View
-------------------------------------------

WIP: No todos los ayudantes se enumeran aquí. Para ver una lista completa, consulta la [documentación de la API](https://api.rubyonrails.org/classes/ActionView/Helpers.html)

Lo siguiente es solo un resumen breve de los ayudantes disponibles en Action View. Se recomienda que revises la [documentación de la API](https://api.rubyonrails.org/classes/ActionView/Helpers.html), que cubre todos los ayudantes con más detalle, pero esto debería servir como un buen punto de partida.

### AssetTagHelper

Este módulo proporciona métodos para generar HTML que enlaza vistas a activos como imágenes, archivos JavaScript, hojas de estilo y feeds.

Por defecto, Rails enlaza estos activos en el host actual en la carpeta pública, pero puedes indicarle a Rails que enlace los activos desde un servidor de activos dedicado configurando [`config.asset_host`][] en la configuración de la aplicación, típicamente en `config/environments/production.rb`. Por ejemplo, supongamos que tu host de activos es `assets.example.com`:

```ruby
config.asset_host = "assets.example.com"
image_tag("rails.png")
# => <img src="http://assets.example.com/images/rails.png" />
```


#### auto_discovery_link_tag

Devuelve una etiqueta de enlace que los navegadores y lectores de feeds pueden usar para detectar automáticamente un feed RSS, Atom o JSON.

```ruby
auto_discovery_link_tag(:rss, "http://www.example.com/feed.rss", { title: "RSS Feed" })
# => <link rel="alternate" type="application/rss+xml" title="RSS Feed" href="http://www.example.com/feed.rss" />
```

#### image_path

Calcula la ruta a un activo de imagen en el directorio `app/assets/images`. Las rutas completas desde la raíz del documento se pasarán. Se utiliza internamente por `image_tag` para construir la ruta de la imagen.

```ruby
image_path("edit.png") # => /assets/edit.png
```

Se agregará una huella digital al nombre de archivo si config.assets.digest está configurado en true.

```ruby
image_path("edit.png")
# => /assets/edit-2d1a2db63fc738690021fedb5a65b68e.png
```

#### image_url

Calcula la URL a un activo de imagen en el directorio `app/assets/images`. Esto llamará a `image_path` internamente y se fusionará con tu host actual o tu host de activos.

```ruby
image_url("edit.png") # => http://www.example.com/assets/edit.png
```

#### image_tag

Devuelve una etiqueta de imagen HTML para la fuente. La fuente puede ser una ruta completa o un archivo que existe en el directorio `app/assets/images`.

```ruby
image_tag("icon.png") # => <img src="/assets/icon.png" />
```

#### javascript_include_tag

Devuelve una etiqueta de script HTML para cada una de las fuentes proporcionadas. Puedes pasar el nombre de archivo (la extensión `.js` es opcional) de los archivos JavaScript que existen en tu directorio `app/assets/javascripts` para incluirlos en la página actual o puedes pasar la ruta completa relativa a la raíz de tu documento.

```ruby
javascript_include_tag "common"
# => <script src="/assets/common.js"></script>
```

#### javascript_path

Calcula la ruta a un activo de JavaScript en el directorio `app/assets/javascripts`. Si el nombre de archivo de origen no tiene extensión, se agregará `.js`. Las rutas completas desde la raíz del documento se pasarán. Se utiliza internamente por `javascript_include_tag` para construir la ruta del script.

```ruby
javascript_path "common" # => /assets/common.js
```

#### javascript_url

Calcula la URL a un activo de JavaScript en el directorio `app/assets/javascripts`. Esto llamará a `javascript_path` internamente y se fusionará con tu host actual o tu host de activos.

```ruby
javascript_url "common"
# => http://www.example.com/assets/common.js
```

#### stylesheet_link_tag

Devuelve una etiqueta de enlace de hoja de estilo para las fuentes especificadas como argumentos. Si no especificas una extensión, se agregará automáticamente `.css`.

```ruby
stylesheet_link_tag "application"
# => <link href="/assets/application.css" rel="stylesheet" />
```

#### stylesheet_path

Calcula la ruta a un activo de hoja de estilo en el directorio `app/assets/stylesheets`. Si el nombre de archivo de origen no tiene extensión, se agregará `.css`. Las rutas completas desde la raíz del documento se pasarán. Se utiliza internamente por `stylesheet_link_tag` para construir la ruta de la hoja de estilo.

```ruby
stylesheet_path "application" # => /assets/application.css
```

#### stylesheet_url

Calcula la URL a un activo de hoja de estilo en el directorio `app/assets/stylesheets`. Esto llamará a `stylesheet_path` internamente y se fusionará con tu host actual o tu host de activos.

```ruby
stylesheet_url "application"
# => http://www.example.com/assets/application.css
```

### AtomFeedHelper

#### atom_feed

Este ayudante facilita la construcción de un feed Atom. Aquí tienes un ejemplo de uso completo:

**config/routes.rb**

```ruby
resources :articles
```

**app/controllers/articles_controller.rb**

```ruby
def index
  @articles = Article.all

  respond_to do |format|
    format.html
    format.atom
  end
end
```

**app/views/articles/index.atom.builder**

```ruby
atom_feed do |feed|
  feed.title("Articles Index")
  feed.updated(@articles.first.created_at)

  @articles.each do |article|
    feed.entry(article) do |entry|
      entry.title(article.title)
      entry.content(article.body, type: 'html')

      entry.author do |author|
        author.name(article.author_name)
      end
    end
  end
end
```

### BenchmarkHelper

#### benchmark

Te permite medir el tiempo de ejecución de un bloque en una plantilla y registra el resultado en el registro. Envuelve este bloque alrededor de operaciones costosas o posibles cuellos de botella para obtener una lectura de tiempo para la operación.
```html+erb
<% benchmark "Procesar archivos de datos" do %>
  <%= expensive_files_operation %>
<% end %>
```

Esto agregaría algo como "Procesar archivos de datos (0.34523)" al registro, que luego puedes usar para comparar los tiempos al optimizar tu código.

### CacheHelper

#### cache

Un método para almacenar en caché fragmentos de una vista en lugar de una acción o página completa. Esta técnica es útil para almacenar en caché piezas como menús, listas de temas de noticias, fragmentos de HTML estáticos, etc. Este método toma un bloque que contiene el contenido que deseas almacenar en caché. Consulta `AbstractController::Caching::Fragments` para obtener más información.

```erb
<% cache do %>
  <%= render "shared/footer" %>
<% end %>
```

### CaptureHelper

#### capture

El método `capture` te permite extraer una parte de una plantilla en una variable. Luego puedes usar esta variable en cualquier lugar de tus plantillas o diseño.

```html+erb
<% @greeting = capture do %>
  <p>Bienvenido! La fecha y hora es <%= Time.now %></p>
<% end %>
```

La variable capturada luego se puede usar en cualquier otro lugar.

```html+erb
<html>
  <head>
    <title>Bienvenido!</title>
  </head>
  <body>
    <%= @greeting %>
  </body>
</html>
```

#### content_for

Llamar a `content_for` almacena un bloque de marcado en un identificador para su uso posterior. Puedes hacer llamadas posteriores al contenido almacenado en otras plantillas o en el diseño pasando el identificador como argumento a `yield`.

Por ejemplo, supongamos que tenemos un diseño de aplicación estándar, pero también una página especial que requiere cierto JavaScript que el resto del sitio no necesita. Podemos usar `content_for` para incluir este JavaScript en nuestra página especial sin aumentar el tamaño del resto del sitio.

**app/views/layouts/application.html.erb**

```html+erb
<html>
  <head>
    <title>Bienvenido!</title>
    <%= yield :special_script %>
  </head>
  <body>
    <p>Bienvenido! La fecha y hora es <%= Time.now %></p>
  </body>
</html>
```

**app/views/articles/special.html.erb**

```html+erb
<p>Esta es una página especial.</p>

<% content_for :special_script do %>
  <script>alert('Hola!')</script>
<% end %>
```

### DateHelper

#### distance_of_time_in_words

Informa la distancia aproximada en tiempo entre dos objetos Time o Date o enteros como segundos. Establece `include_seconds` en true si deseas aproximaciones más detalladas.

```ruby
distance_of_time_in_words(Time.now, Time.now + 15.seconds)
# => menos de un minuto
distance_of_time_in_words(Time.now, Time.now + 15.seconds, include_seconds: true)
# => menos de 20 segundos
```

#### time_ago_in_words

Similar a `distance_of_time_in_words`, pero donde `to_time` está fijo en `Time.now`.

```ruby
time_ago_in_words(3.minutes.from_now) # => 3 minutos
```

### DebugHelper

Devuelve una etiqueta `pre` que tiene un objeto volcado por YAML. Esto crea una forma muy legible de inspeccionar un objeto.

```ruby
my_hash = { 'first' => 1, 'second' => 'two', 'third' => [1, 2, 3] }
debug(my_hash)
```

```html
<pre class='debug_dump'>---
first: 1
second: two
third:
- 1
- 2
- 3
</pre>
```

### FormHelper

Los ayudantes de formulario están diseñados para facilitar el trabajo con modelos en comparación con el uso de elementos HTML estándar, proporcionando un conjunto de métodos para crear formularios basados en tus modelos. Este ayudante genera el HTML para los formularios, proporcionando un método para cada tipo de entrada (por ejemplo, texto, contraseña, selección, etc.). Cuando se envía el formulario (es decir, cuando el usuario hace clic en el botón de enviar o se llama a form.submit a través de JavaScript), las entradas del formulario se agruparán en el objeto params y se pasarán de vuelta al controlador.

Puedes obtener más información sobre los ayudantes de formulario en la [Guía de ayudantes de formulario de Action View](form_helpers.html).

### JavaScriptHelper

Proporciona funcionalidad para trabajar con JavaScript en tus vistas.

#### escape_javascript

Escapa los retornos de carro y las comillas simples y dobles para segmentos de JavaScript.

#### javascript_tag

Devuelve una etiqueta JavaScript que envuelve el código proporcionado.

```ruby
javascript_tag "alert('Todo está bien')"
```

```html
<script>
//<![CDATA[
alert('Todo está bien')
//]]>
</script>
```

### NumberHelper

Proporciona métodos para convertir números en cadenas formateadas. Se proporcionan métodos para números de teléfono, moneda, porcentaje, precisión, notación posicional y tamaño de archivo.

#### number_to_currency

Formatea un número en una cadena de moneda (por ejemplo, $13.65).

```ruby
number_to_currency(1234567890.50) # => $1,234,567,890.50
```

#### number_to_human

Imprime de forma legible (formatea y aproxima) un número para que sea más legible para los usuarios; útil para números que pueden ser muy grandes.

```ruby
number_to_human(1234)    # => 1.23 Mil
number_to_human(1234567) # => 1.23 Millón
```

#### number_to_human_size

Formatea los bytes en tamaño en una representación más comprensible; útil para informar tamaños de archivo a los usuarios.

```ruby
number_to_human_size(1234)    # => 1.21 KB
number_to_human_size(1234567) # => 1.18 MB
```

#### number_to_percentage

Formatea un número como una cadena de porcentaje.
```ruby
number_to_percentage(100, precision: 0) # => 100%
```

#### number_to_phone

Formatea un número en un número de teléfono (por defecto, en Estados Unidos).

```ruby
number_to_phone(1235551234) # => 123-555-1234
```

#### number_with_delimiter

Formatea un número con miles agrupados usando un delimitador.

```ruby
number_with_delimiter(12345678) # => 12,345,678
```

#### number_with_precision

Formatea un número con el nivel de `precision` especificado, que por defecto es 3.

```ruby
number_with_precision(111.2345)               # => 111.235
number_with_precision(111.2345, precision: 2) # => 111.23
```

### SanitizeHelper

El módulo SanitizeHelper proporciona un conjunto de métodos para limpiar el texto de elementos HTML no deseados.

#### sanitize

Este helper de sanitize codificará en HTML todas las etiquetas y eliminará todos los atributos que no estén específicamente permitidos.

```ruby
sanitize @article.body
```

Si se pasan las opciones `:attributes` o `:tags`, solo se permitirán los atributos y etiquetas mencionados y nada más.

```ruby
sanitize @article.body, tags: %w(table tr td), attributes: %w(id class style)
```

Para cambiar los valores predeterminados para múltiples usos, por ejemplo, agregar etiquetas de tabla a los valores predeterminados:

```ruby
class Application < Rails::Application
  config.action_view.sanitized_allowed_tags = 'table', 'tr', 'td'
end
```

#### sanitize_css(style)

Limpia un bloque de código CSS.

#### strip_links(html)

Elimina todas las etiquetas de enlace del texto y deja solo el texto del enlace.

```ruby
strip_links('<a href="https://rubyonrails.org">Ruby on Rails</a>')
# => Ruby on Rails
```

```ruby
strip_links('emails to <a href="mailto:me@email.com">me@email.com</a>.')
# => emails to me@email.com.
```

```ruby
strip_links('Blog: <a href="http://myblog.com/">Visit</a>.')
# => Blog: Visit.
```

#### strip_tags(html)

Elimina todas las etiquetas HTML del html, incluidos los comentarios.
Esta funcionalidad está impulsada por la gema rails-html-sanitizer.

```ruby
strip_tags("Strip <i>these</i> tags!")
# => Strip these tags!
```

```ruby
strip_tags("<b>Bold</b> no more!  <a href='more.html'>See more</a>")
# => Bold no more!  See more
```

NB: La salida aún puede contener caracteres '<', '>', '&' sin escapar y confundir a los navegadores.

### UrlHelper

Proporciona métodos para crear enlaces y obtener URLs que dependen del subsistema de enrutamiento.

#### url_for

Devuelve la URL para el conjunto de `options` proporcionado.

##### Ejemplos

```ruby
url_for @profile
# => /profiles/1

url_for [ @hotel, @booking, page: 2, line: 3 ]
# => /hotels/1/bookings/1?line=3&page=2
```

#### link_to

Enlaza a una URL derivada de `url_for` en el fondo. Se utiliza principalmente para
crear enlaces de recursos RESTful, que para este ejemplo, se reduce a
cuando se pasan modelos a `link_to`.

**Ejemplos**

```ruby
link_to "Profile", @profile
# => <a href="/profiles/1">Profile</a>
```

También se puede usar un bloque si el destino del enlace no cabe en el parámetro de nombre. Ejemplo en ERB:

```html+erb
<%= link_to @profile do %>
  <strong><%= @profile.name %></strong> -- <span>¡Échale un vistazo!</span>
<% end %>
```

produciría:

```html
<a href="/profiles/1">
  <strong>David</strong> -- <span>¡Échale un vistazo!</span>
</a>
```

Consulte [la Documentación de la API para obtener más información](https://api.rubyonrails.org/classes/ActionView/Helpers/UrlHelper.html#method-i-link_to)

#### button_to

Genera un formulario que se envía a la URL pasada. El formulario tiene un botón de envío
con el valor del `name`.

##### Ejemplos

```html+erb
<%= button_to "Sign in", sign_in_path %>
```

aproximadamente produciría algo como:

```html
<form method="post" action="/sessions" class="button_to">
  <input type="submit" value="Sign in" />
</form>
```

Consulte [la Documentación de la API para obtener más información](https://api.rubyonrails.org/classes/ActionView/Helpers/UrlHelper.html#method-i-button_to)

### CsrfHelper

Devuelve las etiquetas meta "csrf-param" y "csrf-token" con el nombre del parámetro y el token de protección contra falsificación de solicitudes entre sitios, respectivamente.

```html
<%= csrf_meta_tags %>
```

NOTA: Los formularios regulares generan campos ocultos, por lo que no utilizan estas etiquetas. Se pueden encontrar más detalles en la [Guía de seguridad de Rails](security.html#cross-site-request-forgery-csrf).
[`config.asset_host`]: configuring.html#config-asset-host
