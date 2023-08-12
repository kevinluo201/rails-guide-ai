**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: f6b613040c7aed4c76b6648b6fd963cf
Resumen de Action View
====================

Después de leer esta guía, sabrás:

* Qué es Action View y cómo usarlo con Rails.
* Cómo utilizar plantillas, parciales y diseños de la mejor manera.
* Cómo utilizar vistas localizadas.

--------------------------------------------------------------------------------

¿Qué es Action View?
--------------------

En Rails, las solicitudes web son manejadas por [Action Controller](action_controller_overview.html) y Action View. Normalmente, Action Controller se encarga de comunicarse con la base de datos y realizar acciones CRUD cuando sea necesario. Luego, Action View es responsable de compilar la respuesta.

Las plantillas de Action View se escriben utilizando Ruby incrustado en etiquetas mezcladas con HTML. Para evitar sobrecargar las plantillas con código repetitivo, varias clases auxiliares proporcionan comportamientos comunes para formularios, fechas y cadenas. También es fácil agregar nuevos ayudantes a tu aplicación a medida que evoluciona.

NOTA: Algunas características de Action View están vinculadas a Active Record, pero eso no significa que Action View dependa de Active Record. Action View es un paquete independiente que se puede usar con cualquier tipo de bibliotecas de Ruby.

Uso de Action View con Rails
----------------------------

Para cada controlador, hay un directorio asociado en el directorio `app/views` que contiene los archivos de plantilla que conforman las vistas asociadas con ese controlador. Estos archivos se utilizan para mostrar la vista que resulta de cada acción del controlador.

Veamos qué hace Rails de forma predeterminada al crear un nuevo recurso utilizando el generador de andamios:

```bash
$ bin/rails generate scaffold article
      [...]
      invoke  scaffold_controller
      create    app/controllers/articles_controller.rb
      invoke    erb
      create      app/views/articles
      create      app/views/articles/index.html.erb
      create      app/views/articles/edit.html.erb
      create      app/views/articles/show.html.erb
      create      app/views/articles/new.html.erb
      create      app/views/articles/_form.html.erb
      [...]
```

Hay una convención de nomenclatura para las vistas en Rails. Normalmente, las vistas comparten su nombre con la acción del controlador asociada, como se puede ver arriba.
Por ejemplo, la acción del controlador `index` del archivo `articles_controller.rb` utilizará el archivo de vista `index.html.erb` en el directorio `app/views/articles`.
El HTML completo devuelto al cliente está compuesto por una combinación de este archivo ERB, una plantilla de diseño que lo envuelve y todos los parciales a los que la vista puede hacer referencia. En esta guía, encontrarás documentación más detallada sobre cada uno de estos tres componentes.

Como se mencionó, la salida HTML final es una composición de tres elementos de Rails: `Plantillas`, `Parciales` y `Diseños`.
A continuación se muestra una breve descripción de cada uno de ellos.

Plantillas
---------

Las plantillas de Action View se pueden escribir de varias formas. Si el archivo de plantilla tiene una extensión `.erb`, entonces se utiliza una mezcla de ERB (Ruby incrustado) y HTML. Si el archivo de plantilla tiene una extensión `.builder`, se utiliza la biblioteca `Builder::XmlMarkup`.

Rails admite múltiples sistemas de plantillas y utiliza una extensión de archivo para distinguir entre ellos. Por ejemplo, un archivo HTML que utiliza el sistema de plantillas ERB tendrá `.html.erb` como extensión de archivo.

### ERB

Dentro de una plantilla ERB, se puede incluir código Ruby utilizando las etiquetas `<% %>` y `<%= %>` . Las etiquetas `<% %>` se utilizan para ejecutar código Ruby que no devuelve nada, como condiciones, bucles o bloques, y las etiquetas `<%= %>` se utilizan cuando se desea obtener una salida.

Considera el siguiente bucle para los nombres:

```html+erb
<h1>Nombres de todas las personas</h1>
<% @people.each do |person| %>
  Nombre: <%= person.name %><br>
<% end %>
```

El bucle se configura utilizando etiquetas de incrustación regulares (`<% %>`) y el nombre se inserta utilizando etiquetas de incrustación de salida (`<%= %>`). Ten en cuenta que esto no es solo una sugerencia de uso: las funciones de salida regulares como `print` y `puts` no se renderizarán en la vista con las plantillas ERB. Por lo tanto, esto sería incorrecto:

```html+erb
<%# INCORRECTO %>
Hola, Sr. <% puts "Frodo" %>
```

Para suprimir los espacios en blanco iniciales y finales, puedes usar `<%-` `-%>` de manera intercambiable con `<%` y `%>`.

### Builder

Las plantillas de Builder son una alternativa más programática a ERB. Son especialmente útiles para generar contenido XML. Se crea automáticamente un objeto XmlMarkup llamado `xml` que está disponible en las plantillas con una extensión `.builder`.

Aquí tienes algunos ejemplos básicos:

```ruby
xml.em("enfatizado")
xml.em { xml.b("énfasis y negrita") }
xml.a("Un enlace", "href" => "https://rubyonrails.org")
xml.target("nombre" => "compilar", "opción" => "rápido")
```

que produciría:

```html
<em>enfatizado</em>
<em><b>énfasis y negrita</b></em>
<a href="https://rubyonrails.org">Un enlace</a>
<target opción="rápido" nombre="compilar" />
```

Cualquier método con un bloque se tratará como una etiqueta de marcado XML con marcado anidado en el bloque. Por ejemplo, lo siguiente:
```ruby
xml.div {
  xml.h1(@person.name)
  xml.p(@person.bio)
}
```

produciría algo como:

```html
<div>
  <h1>David Heinemeier Hansson</h1>
  <p>Un producto del Diseño Danés durante el Invierno del '79...</p>
</div>
```

A continuación se muestra un ejemplo completo de RSS que se utiliza en Basecamp:

```ruby
xml.rss("version" => "2.0", "xmlns:dc" => "http://purl.org/dc/elements/1.1/") do
  xml.channel do
    xml.title(@feed_title)
    xml.link(@url)
    xml.description "Basecamp: Ítems recientes"
    xml.language "en-us"
    xml.ttl "40"

    for item in @recent_items
      xml.item do
        xml.title(item_title(item))
        xml.description(item_description(item)) if item_description(item)
        xml.pubDate(item_pubDate(item))
        xml.guid(@person.firm.account.url + @recent_items.url(item))
        xml.link(@person.firm.account.url + @recent_items.url(item))
        xml.tag!("dc:creator", item.author_name) if item_has_creator?(item)
      end
    end
  end
end
```

### Jbuilder

[Jbuilder](https://github.com/rails/jbuilder) es una gema que es mantenida por el equipo de Rails y está incluida en el `Gemfile` predeterminado de Rails. Es similar a Builder pero se utiliza para generar JSON en lugar de XML.

Si no lo tienes, puedes agregar lo siguiente a tu `Gemfile`:

```ruby
gem 'jbuilder'
```

Un objeto Jbuilder llamado `json` se crea automáticamente y está disponible en las plantillas con extensión `.jbuilder`.

Aquí tienes un ejemplo básico:

```ruby
json.name("Alex")
json.email("alex@example.com")
```

produciría:

```json
{
  "name": "Alex",
  "email": "alex@example.com"
}
```

Consulta la [documentación de Jbuilder](https://github.com/rails/jbuilder#jbuilder) para obtener más ejemplos e información.

### Caché de plantillas

Por defecto, Rails compilará cada plantilla en un método para renderizarla. En el entorno de desarrollo, cuando modificas una plantilla, Rails verificará la fecha de modificación del archivo y la volverá a compilar.

Partials
--------

Las plantillas parciales, generalmente llamadas "partials", son otro recurso para dividir el proceso de renderizado en fragmentos más manejables. Con los partials, puedes extraer fragmentos de código de tus plantillas y reutilizarlos en toda tu aplicación.

### Renderización de partials

Para renderizar un partial como parte de una vista, utilizas el método `render` dentro de la vista:

```erb
<%= render "menu" %>
```

Esto renderizará un archivo llamado `_menu.html.erb` en ese punto de la vista que se está renderizando. Observa el carácter de guion bajo al principio: los partials se nombran con un guion bajo al principio para distinguirlos de las vistas regulares, aunque se los menciona sin el guion bajo. Esto es válido incluso cuando estás utilizando un partial de otra carpeta:

```erb
<%= render "shared/menu" %>
```

Ese código utilizará el partial de `app/views/shared/_menu.html.erb`.

### Uso de partials para simplificar las vistas

Una forma de utilizar los partials es tratarlos como equivalentes a subrutinas; una forma de mover los detalles de una vista para poder comprender mejor lo que está sucediendo. Por ejemplo, podrías tener una vista que se vea así:

```html+erb
<%= render "shared/ad_banner" %>

<h1>Productos</h1>

<p>Aquí tienes algunos de nuestros excelentes productos:</p>
<% @products.each do |product| %>
  <%= render partial: "product", locals: { product: product } %>
<% end %>

<%= render "shared/footer" %>
```

Aquí, los partials `_ad_banner.html.erb` y `_footer.html.erb` podrían contener contenido que se comparte en muchas páginas de tu aplicación. No necesitas ver los detalles de estas secciones cuando te estás concentrando en una página en particular.

### `render` sin las opciones `partial` y `locals`

En el ejemplo anterior, `render` toma 2 opciones: `partial` y `locals`. Pero si estas son las únicas opciones que deseas pasar, puedes omitir el uso de estas opciones. Por ejemplo, en lugar de:

```erb
<%= render partial: "product", locals: { product: @product } %>
```

También puedes hacer:

```erb
<%= render "product", product: @product %>
```

### Las opciones `as` y `object`

De forma predeterminada, `ActionView::Partials::PartialRenderer` tiene su objeto en una variable local con el mismo nombre que la plantilla. Entonces, dado:

```erb
<%= render partial: "product" %>
```

dentro del partial `_product` obtendremos `@product` en la variable local `product`, como si hubiéramos escrito:

```erb
<%= render partial: "product", locals: { product: @product } %>
```

La opción `object` se puede utilizar para especificar directamente qué objeto se renderiza en el partial; útil cuando el objeto de la plantilla está en otro lugar (por ejemplo, en una variable de instancia diferente o en una variable local).

Por ejemplo, en lugar de:

```erb
<%= render partial: "product", locals: { product: @item } %>
```

haríamos:

```erb
<%= render partial: "product", object: @item %>
```

Con la opción `as`, podemos especificar un nombre diferente para dicha variable local. Por ejemplo, si quisiéramos que fuera `item` en lugar de `product`, haríamos:

```erb
<%= render partial: "product", object: @item, as: "item" %>
```

Esto es equivalente a
```erb
<%= render partial: "product", locals: { item: @item } %>
```

### Renderizando Colecciones

Comúnmente, una plantilla necesitará iterar sobre una colección y renderizar una sub-plantilla para cada uno de los elementos. Este patrón se ha implementado como un único método que acepta un array y renderiza un partial para cada uno de los elementos en el array.

Entonces, este ejemplo para renderizar todos los productos:

```erb
<% @products.each do |product| %>
  <%= render partial: "product", locals: { product: product } %>
<% end %>
```

puede ser reescrito en una sola línea:

```erb
<%= render partial: "product", collection: @products %>
```

Cuando un partial es llamado con una colección, las instancias individuales del partial tienen acceso al miembro de la colección que está siendo renderizado a través de una variable llamada como el partial. En este caso, el partial es `_product`, y dentro de él, puedes referirte a `product` para obtener el miembro de la colección que está siendo renderizado.

Puedes usar una sintaxis abreviada para renderizar colecciones. Suponiendo que `@products` es una colección de instancias de `Product`, simplemente puedes escribir lo siguiente para obtener el mismo resultado:

```erb
<%= render @products %>
```

Rails determina el nombre del partial a utilizar al mirar el nombre del modelo en la colección, en este caso `Product`. De hecho, incluso puedes renderizar una colección compuesta por instancias de diferentes modelos usando esta sintaxis abreviada, y Rails elegirá el partial adecuado para cada miembro de la colección.

### Plantillas de Espaciado

También puedes especificar un segundo partial para ser renderizado entre las instancias del partial principal usando la opción `:spacer_template`:

```erb
<%= render partial: @products, spacer_template: "product_ruler" %>
```

Rails renderizará el partial `_product_ruler` (sin datos pasados a él) entre cada par de partials `_product`.

### Locales Estrictas

Por defecto, las plantillas aceptarán cualquier `locals` como argumentos de palabras clave. Para definir qué `locals` acepta una plantilla, agrega un comentario mágico `locals`:

```erb
<%# locals: (message:) -%>
<%= message %>
```

También se pueden proporcionar valores predeterminados:

```erb
<%# locals: (message: "¡Hola, mundo!") -%>
<%= message %>
```

O las `locals` se pueden deshabilitar por completo:

```erb
<%# locals: () %>
```

Layouts
-------

Los layouts se pueden utilizar para renderizar una plantilla de vista común alrededor de los resultados de las acciones del controlador de Rails. Típicamente, una aplicación de Rails tendrá un par de layouts en los que se renderizarán las páginas. Por ejemplo, un sitio puede tener un layout para un usuario registrado y otro para el lado de marketing o ventas del sitio. El layout para el usuario registrado puede incluir una navegación de nivel superior que debe estar presente en muchas acciones del controlador. El layout de ventas para una aplicación SaaS puede incluir una navegación de nivel superior para cosas como las páginas "Precios" y "Contáctenos". Se esperaría que cada layout tenga un aspecto y una sensación diferentes. Puedes leer más detalles sobre los layouts en la guía [Layouts and Rendering in Rails](layouts_and_rendering.html).

### Layouts Parciales

Los partials pueden tener sus propios layouts aplicados a ellos. Estos layouts son diferentes de los aplicados a una acción del controlador, pero funcionan de manera similar.

Digamos que estamos mostrando un artículo en una página que debe envolverse en un `div` para fines de visualización. En primer lugar, crearemos un nuevo `Article`:

```ruby
Article.create(body: '¡Los Layouts Parciales son geniales!')
```

En la plantilla `show`, renderizaremos el partial `_article` envuelto en el layout `box`:

**articles/show.html.erb**

```erb
<%= render partial: 'article', layout: 'box', locals: { article: @article } %>
```

El layout `box` simplemente envuelve el partial `_article` en un `div`:

**articles/_box.html.erb**

```html+erb
<div class='box'>
  <%= yield %>
</div>
```

Ten en cuenta que el layout del partial tiene acceso a la variable local `article` que se pasó a la llamada `render`. Sin embargo, a diferencia de los layouts de toda la aplicación, los layouts parciales todavía tienen el prefijo de guión bajo.

También puedes renderizar un bloque de código dentro de un layout parcial en lugar de llamar a `yield`. Por ejemplo, si no tuviéramos el partial `_article`, podríamos hacer esto en su lugar:

**articles/show.html.erb**

```html+erb
<% render(layout: 'box', locals: { article: @article }) do %>
  <div>
    <p><%= article.body %></p>
  </div>
<% end %>
```

Suponiendo que usamos el mismo partial `_box` de arriba, esto produciría el mismo resultado que el ejemplo anterior.

Rutas de Vistas
---------------

Cuando se renderiza una respuesta, el controlador necesita resolver dónde se encuentran las diferentes vistas. Por defecto, solo busca dentro del directorio `app/views`.
Podemos agregar otras ubicaciones y darles cierta precedencia al resolver rutas utilizando los métodos `prepend_view_path` y `append_view_path`.

### Prepend View Path

Esto puede ser útil, por ejemplo, cuando queremos poner vistas dentro de un directorio diferente para subdominios.

Podemos hacer esto usando:

```ruby
prepend_view_path "app/views/#{request.subdomain}"
```

Entonces Action View buscará primero en este directorio al resolver vistas.

### Append View Path

De manera similar, podemos agregar rutas:

```ruby
append_view_path "app/views/direct"
```

Esto agregará `app/views/direct` al final de las rutas de búsqueda.

Helpers
-------

Rails proporciona muchos métodos auxiliares para usar con Action View. Estos incluyen métodos para:

* Formatear fechas, cadenas y números
* Crear enlaces HTML a imágenes, videos, hojas de estilo, etc...
* Sanitizar contenido
* Crear formularios
* Localizar contenido

Puedes obtener más información sobre los helpers en la [Guía de Helpers de Action View](action_view_helpers.html) y la [Guía de Helpers de Formularios de Action View](form_helpers.html).

Vistas Localizadas
---------------

Action View tiene la capacidad de renderizar diferentes plantillas dependiendo de la configuración regional actual.

Por ejemplo, supongamos que tienes un `ArticlesController` con una acción `show`. Por defecto, llamar a esta acción renderizará `app/views/articles/show.html.erb`. Pero si estableces `I18n.locale = :de`, entonces se renderizará `app/views/articles/show.de.html.erb` en su lugar. Si la plantilla localizada no está presente, se utilizará la versión sin decorar. Esto significa que no es necesario proporcionar vistas localizadas para todos los casos, pero se preferirán y utilizarán si están disponibles.

Puedes usar la misma técnica para localizar los archivos de rescate en tu directorio público. Por ejemplo, establecer `I18n.locale = :de` y crear `public/500.de.html` y `public/404.de.html` te permitiría tener páginas de rescate localizadas.

Dado que Rails no restringe los símbolos que utilizas para establecer `I18n.locale`, puedes aprovechar este sistema para mostrar contenido diferente dependiendo de lo que desees. Por ejemplo, supongamos que tienes algunos usuarios "expertos" que deberían ver páginas diferentes de los usuarios "normales". Podrías agregar lo siguiente a `app/controllers/application_controller.rb`:

```ruby
before_action :set_expert_locale

def set_expert_locale
  I18n.locale = :expert if current_user.expert?
end
```

Luego podrías crear vistas especiales como `app/views/articles/show.expert.html.erb` que solo se mostrarían a los usuarios expertos.

Puedes leer más sobre la API de Internacionalización (I18n) de Rails [aquí](i18n.html).
