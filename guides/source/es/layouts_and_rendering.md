**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 02f663dc709da76ced45deb2ba800a78
Diseños y Renderizado en Rails
==============================

Esta guía cubre las características básicas de diseño de Action Controller y Action View.

Después de leer esta guía, sabrás:

* Cómo utilizar los diversos métodos de renderizado incorporados en Rails.
* Cómo crear diseños con múltiples secciones de contenido.
* Cómo utilizar parciales para evitar la repetición de código en tus vistas.
* Cómo utilizar diseños anidados (sub-plantillas).

--------------------------------------------------------------------------------

Resumen: Cómo encajan las piezas
--------------------------------

Esta guía se centra en la interacción entre el Controlador y la Vista en el triángulo Modelo-Vista-Controlador. Como sabes, el Controlador es responsable de orquestar todo el proceso de manejo de una solicitud en Rails, aunque normalmente delega cualquier código pesado al Modelo. Pero luego, cuando llega el momento de enviar una respuesta de vuelta al usuario, el Controlador pasa las cosas a la Vista. Esa transferencia es el tema de esta guía.

En líneas generales, esto implica decidir qué se debe enviar como respuesta y llamar a un método adecuado para crear esa respuesta. Si la respuesta es una vista completa, Rails también realiza un trabajo adicional para envolver la vista en un diseño y posiblemente para incluir vistas parciales. Verás todos esos caminos más adelante en esta guía.

Creando Respuestas
------------------

Desde el punto de vista del controlador, hay tres formas de crear una respuesta HTTP:

* Llamar a [`render`][controller.render] para crear una respuesta completa para enviar de vuelta al navegador.
* Llamar a [`redirect_to`][] para enviar un código de estado de redirección HTTP al navegador.
* Llamar a [`head`][] para crear una respuesta que consista únicamente en encabezados HTTP para enviar de vuelta al navegador.


### Renderizado por defecto: Convención sobre configuración en acción

Has escuchado que Rails promueve la "convención sobre configuración". El renderizado por defecto es un excelente ejemplo de esto. Por defecto, los controladores en Rails renderizan automáticamente vistas con nombres que corresponden a rutas válidas. Por ejemplo, si tienes este código en tu clase `BooksController`:

```ruby
class BooksController < ApplicationController
end
```

Y lo siguiente en tu archivo de rutas:

```ruby
resources :books
```

Y tienes un archivo de vista `app/views/books/index.html.erb`:

```html+erb
<h1>¡Los libros están por venir!</h1>
```

Rails automáticamente renderizará `app/views/books/index.html.erb` cuando navegues a `/books` y verás "¡Los libros están por venir!" en tu pantalla.

Sin embargo, una pantalla de próximamente solo es mínimamente útil, así que pronto crearás tu modelo `Book` y agregarás la acción de índice a `BooksController`:

```ruby
class BooksController < ApplicationController
  def index
    @books = Book.all
  end
end
```

Observa que no tenemos un render explícito al final de la acción de índice de acuerdo con el principio de "convención sobre configuración". La regla es que si no renderizas explícitamente algo al final de una acción de controlador, Rails buscará automáticamente la plantilla `action_name.html.erb` en la ruta de vistas del controlador y la renderizará. Así que en este caso, Rails renderizará el archivo `app/views/books/index.html.erb`.

Si queremos mostrar las propiedades de todos los libros en nuestra vista, podemos hacerlo con una plantilla ERB como esta:

```html+erb
<h1>Listado de Libros</h1>

<table>
  <thead>
    <tr>
      <th>Título</th>
      <th>Contenido</th>
      <th colspan="3"></th>
    </tr>
  </thead>

  <tbody>
    <% @books.each do |book| %>
      <tr>
        <td><%= book.title %></td>
        <td><%= book.content %></td>
        <td><%= link_to "Mostrar", book %></td>
        <td><%= link_to "Editar", edit_book_path(book) %></td>
        <td><%= link_to "Eliminar", book, data: { turbo_method: :delete, turbo_confirm: "¿Estás seguro?" } %></td>
      </tr>
    <% end %>
  </tbody>
</table>

<br>

<%= link_to "Nuevo libro", new_book_path %>
```

NOTA: El renderizado real lo realizan clases anidadas del módulo [`ActionView::Template::Handlers`](https://api.rubyonrails.org/classes/ActionView/Template/Handlers.html). Esta guía no profundiza en ese proceso, pero es importante saber que la extensión de archivo de tu vista controla la elección del manejador de plantillas.

### Usando `render`

En la mayoría de los casos, el método [`render`][controller.render] del controlador se encarga de renderizar el contenido de tu aplicación para su uso por parte de un navegador. Hay varias formas de personalizar el comportamiento de `render`. Puedes renderizar la vista predeterminada para una plantilla de Rails, o una plantilla específica, o un archivo, o código en línea, o nada en absoluto. Puedes renderizar texto, JSON o XML. También puedes especificar el tipo de contenido o el estado HTTP de la respuesta renderizada.

CONSEJO: Si quieres ver los resultados exactos de una llamada a `render` sin necesidad de inspeccionarlos en un navegador, puedes llamar a `render_to_string`. Este método toma exactamente las mismas opciones que `render`, pero devuelve una cadena en lugar de enviar una respuesta de vuelta al navegador.
#### Renderizando la vista de una acción

Si quieres renderizar la vista que corresponde a una plantilla diferente dentro del mismo controlador, puedes usar `render` con el nombre de la vista:

```ruby
def update
  @book = Book.find(params[:id])
  if @book.update(book_params)
    redirect_to(@book)
  else
    render "edit"
  end
end
```

Si la llamada a `update` falla, llamar a la acción `update` en este controlador renderizará la plantilla `edit.html.erb` perteneciente al mismo controlador.

Si lo prefieres, puedes usar un símbolo en lugar de una cadena para especificar la acción a renderizar:

```ruby
def update
  @book = Book.find(params[:id])
  if @book.update(book_params)
    redirect_to(@book)
  else
    render :edit, status: :unprocessable_entity
  end
end
```

#### Renderizando la plantilla de una acción desde otro controlador

¿Qué pasa si quieres renderizar una plantilla desde un controlador completamente diferente al que contiene el código de la acción? También puedes hacerlo con `render`, que acepta la ruta completa (relativa a `app/views`) de la plantilla a renderizar. Por ejemplo, si estás ejecutando código en un `AdminProductsController` que se encuentra en `app/controllers/admin`, puedes renderizar los resultados de una acción a una plantilla en `app/views/products` de esta manera:

```ruby
render "products/show"
```

Rails sabe que esta vista pertenece a un controlador diferente debido al carácter de barra inclinada en la cadena. Si quieres ser explícito, puedes usar la opción `:template` (que era requerida en Rails 2.2 y versiones anteriores):

```ruby
render template: "products/show"
```

#### Conclusión

Las dos formas anteriores de renderizar (renderizar la plantilla de otra acción en el mismo controlador y renderizar la plantilla de otra acción en un controlador diferente) son en realidad variantes de la misma operación.

De hecho, en la clase `BooksController`, dentro de la acción `update` donde queremos renderizar la plantilla `edit` si el libro no se actualiza correctamente, todas las siguientes llamadas a `render` renderizarían la plantilla `edit.html.erb` en el directorio `views/books`:

```ruby
render :edit
render action: :edit
render "edit"
render action: "edit"
render "books/edit"
render template: "books/edit"
```

Cuál usar es realmente una cuestión de estilo y convención, pero la regla general es usar la forma más simple que tenga sentido para el código que estás escribiendo.

#### Usando `render` con `:inline`

El método `render` puede prescindir completamente de una vista, si estás dispuesto a usar la opción `:inline` para proporcionar ERB como parte de la llamada al método. Esto es perfectamente válido:

```ruby
render inline: "<% products.each do |p| %><p><%= p.name %></p><% end %>"
```

ADVERTENCIA: Rara vez hay una buena razón para usar esta opción. Mezclar ERB en tus controladores va en contra de la orientación MVC de Rails y dificultará que otros desarrolladores sigan la lógica de tu proyecto. En su lugar, utiliza una vista ERB separada.

Por defecto, la renderización en línea utiliza ERB. Puedes forzar que utilice Builder en su lugar con la opción `:type`:

```ruby
render inline: "xml.p {'¡Práctica de codificación horrible!'}", type: :builder
```

#### Renderizando texto

Puedes enviar texto plano, sin ningún marcado, de vuelta al navegador utilizando la opción `:plain` en `render`:

```ruby
render plain: "OK"
```

CONSEJO: Renderizar texto puro es más útil cuando estás respondiendo a solicitudes Ajax o de servicios web que esperan algo diferente a HTML correcto.

NOTA: Por defecto, si usas la opción `:plain`, el texto se renderizará sin utilizar el diseño actual. Si quieres que Rails coloque el texto en el diseño actual, debes agregar la opción `layout: true` y usar la extensión `.text.erb` para el archivo de diseño.

#### Renderizando HTML

Puedes enviar una cadena HTML de vuelta al navegador utilizando la opción `:html` en `render`:

```ruby
render html: helpers.tag.strong('Not Found')
```

CONSEJO: Esto es útil cuando estás renderizando un pequeño fragmento de código HTML. Sin embargo, es posible que desees considerar moverlo a un archivo de plantilla si el marcado es complejo.

NOTA: Al usar la opción `html:`, las entidades HTML se escaparán si la cadena no está compuesta con APIs que sean conscientes de `html_safe`.

#### Renderizando JSON

JSON es un formato de datos de JavaScript utilizado por muchas bibliotecas Ajax. Rails tiene soporte incorporado para convertir objetos a JSON y renderizar ese JSON de vuelta al navegador:

```ruby
render json: @product
```

CONSEJO: No es necesario llamar a `to_json` en el objeto que deseas renderizar. Si usas la opción `:json`, `render` llamará automáticamente a `to_json` por ti.
#### Renderizado de XML

Rails también tiene soporte incorporado para convertir objetos a XML y renderizar ese XML de vuelta al llamador:

```ruby
render xml: @product
```

CONSEJO: No es necesario llamar a `to_xml` en el objeto que deseas renderizar. Si usas la opción `:xml`, `render` llamará automáticamente a `to_xml` por ti.

#### Renderizado de JavaScript puro

Rails puede renderizar JavaScript puro:

```ruby
render js: "alert('Hola Rails');"
```

Esto enviará la cadena proporcionada al navegador con un tipo MIME de `text/javascript`.

#### Renderizado de cuerpo sin formato

Puedes enviar un contenido sin formato al navegador, sin establecer ningún tipo de contenido, utilizando la opción `:body` en `render`:

```ruby
render body: "sin formato"
```

CONSEJO: Esta opción solo debe usarse si no te importa el tipo de contenido de la respuesta. Usar `:plain` o `:html` puede ser más apropiado la mayoría de las veces.

NOTA: A menos que se anule, la respuesta devuelta desde esta opción de renderizado será `text/plain`, ya que ese es el tipo de contenido predeterminado de la respuesta de Action Dispatch.

#### Renderizado de archivo sin procesar

Rails puede renderizar un archivo sin procesar desde una ruta absoluta. Esto es útil para renderizar condicionalmente archivos estáticos como páginas de error.

```ruby
render file: "#{Rails.root}/public/404.html", layout: false
```

Esto renderiza el archivo sin procesar (no admite ERB u otros manejadores). Por defecto, se renderiza dentro del diseño actual.

ADVERTENCIA: El uso de la opción `:file` en combinación con la entrada de usuarios puede causar problemas de seguridad, ya que un atacante podría usar esta acción para acceder a archivos sensibles de seguridad en tu sistema de archivos.

CONSEJO: `send_file` suele ser una opción más rápida y mejor si no se requiere un diseño.

#### Renderizado de objetos

Rails puede renderizar objetos que responden a `:render_in`.

```ruby
render MyRenderable.new
```

Esto llama a `render_in` en el objeto proporcionado con el contexto de vista actual.

También puedes proporcionar el objeto utilizando la opción `:renderable` en `render`:

```ruby
render renderable: MyRenderable.new
```

#### Opciones para `render`

Las llamadas al método [`render`][controller.render] generalmente aceptan seis opciones:

* `:content_type`
* `:layout`
* `:location`
* `:status`
* `:formats`
* `:variants`

##### La opción `:content_type`

Por defecto, Rails servirá los resultados de una operación de renderizado con el tipo de contenido MIME `text/html` (o `application/json` si usas la opción `:json`, o `application/xml` para la opción `:xml`). Hay momentos en los que es posible que desees cambiar esto, y puedes hacerlo estableciendo la opción `:content_type`:

```ruby
render template: "feed", content_type: "application/rss"
```

##### La opción `:layout`

Con la mayoría de las opciones de `render`, el contenido renderizado se muestra como parte del diseño actual. Aprenderás más sobre los diseños y cómo usarlos más adelante en esta guía.

Puedes usar la opción `:layout` para indicarle a Rails que use un archivo específico como el diseño para la acción actual:

```ruby
render layout: "special_layout"
```

También puedes indicarle a Rails que renderice sin ningún diseño en absoluto:

```ruby
render layout: false
```

##### La opción `:location`

Puedes usar la opción `:location` para establecer el encabezado HTTP `Location`:

```ruby
render xml: photo, location: photo_url(photo)
```

##### La opción `:status`

Rails generará automáticamente una respuesta con el código de estado HTTP correcto (en la mayoría de los casos, esto es `200 OK`). Puedes usar la opción `:status` para cambiar esto:

```ruby
render status: 500
render status: :forbidden
```

Rails comprende tanto los códigos de estado numéricos como los símbolos correspondientes que se muestran a continuación.

| Clase de respuesta  | Código de estado HTTP | Símbolo                          |
| ------------------- | --------------------- | -------------------------------- |
| **Informativa**     | 100                   | :continue                        |
|                     | 101                   | :switching_protocols             |
|                     | 102                   | :processing                      |
| **Éxito**           | 200                   | :ok                              |
|                     | 201                   | :created                         |
|                     | 202                   | :accepted                        |
|                     | 203                   | :non_authoritative_information   |
|                     | 204                   | :no_content                      |
|                     | 205                   | :reset_content                   |
|                     | 206                   | :partial_content                 |
|                     | 207                   | :multi_status                    |
|                     | 208                   | :already_reported                |
|                     | 226                   | :im_used                         |
| **Redirección**     | 300                   | :multiple_choices                |
|                     | 301                   | :moved_permanently               |
|                     | 302                   | :found                           |
|                     | 303                   | :see_other                       |
|                     | 304                   | :not_modified                    |
|                     | 305                   | :use_proxy                       |
|                     | 307                   | :temporary_redirect              |
|                     | 308                   | :permanent_redirect              |
| **Error del cliente** | 400                 | :bad_request                     |
|                     | 401                   | :unauthorized                    |
|                     | 402                   | :payment_required                |
|                     | 403                   | :forbidden                       |
|                     | 404                   | :not_found                       |
|                     | 405                   | :method_not_allowed              |
|                     | 406                   | :not_acceptable                  |
|                     | 407                   | :proxy_authentication_required   |
|                     | 408                   | :request_timeout                 |
|                     | 409                   | :conflict                        |
|                     | 410                   | :gone                            |
|                     | 411                   | :length_required                 |
|                     | 412                   | :precondition_failed             |
|                     | 413                   | :payload_too_large               |
|                     | 414                   | :uri_too_long                    |
|                     | 415                   | :unsupported_media_type          |
|                     | 416                   | :range_not_satisfiable           |
|                     | 417                   | :expectation_failed              |
|                     | 421                   | :misdirected_request             |
|                     | 422                   | :unprocessable_entity            |
|                     | 423                   | :locked                          |
|                     | 424                   | :failed_dependency               |
|                     | 426                   | :upgrade_required                |
|                     | 428                   | :precondition_required           |
|                     | 429                   | :too_many_requests               |
|                     | 431                   | :request_header_fields_too_large |
|                     | 451                   | :unavailable_for_legal_reasons   |
| **Error del servidor** | 500                 | :internal_server_error           |
|                     | 501                   | :not_implemented                 |
|                     | 502                   | :bad_gateway                     |
|                     | 503                   | :service_unavailable             |
|                     | 504                   | :gateway_timeout                 |
|                     | 505                   | :http_version_not_supported      |
|                     | 506                   | :variant_also_negotiates         |
|                     | 507                   | :insufficient_storage            |
|                     | 508                   | :loop_detected                   |
|                     | 510                   | :not_extended                    |
|                     | 511                   | :network_authentication_required |
NOTA: Si intenta renderizar contenido junto con un código de estado que no es de contenido (100-199, 204, 205 o 304), se eliminará de la respuesta.

##### La opción `:formats`

Rails utiliza el formato especificado en la solicitud (o `:html` de forma predeterminada). Puede cambiar esto pasando la opción `:formats` con un símbolo o una matriz:

```ruby
render formats: :xml
render formats: [:json, :xml]
```

Si no existe una plantilla con el formato especificado, se generará un error `ActionView::MissingTemplate`.

##### La opción `:variants`

Esto le indica a Rails que busque variantes de plantillas del mismo formato. Puede especificar una lista de variantes pasando la opción `:variants` con un símbolo o una matriz.

Un ejemplo de uso sería el siguiente.

```ruby
# llamado en HomeController#index
render variants: [:mobile, :desktop]
```

Con este conjunto de variantes, Rails buscará el siguiente conjunto de plantillas y utilizará la primera que exista.

- `app/views/home/index.html+mobile.erb`
- `app/views/home/index.html+desktop.erb`
- `app/views/home/index.html.erb`

Si no existe una plantilla con el formato especificado, se generará un error `ActionView::MissingTemplate`.

En lugar de establecer la variante en la llamada de renderizado, también puede establecerla en el objeto de solicitud en la acción del controlador.

```ruby
def index
  request.variant = determine_variant
end

  private
    def determine_variant
      variant = nil
      # algún código para determinar la(s) variante(s) a utilizar
      variant = :mobile if session[:use_mobile]

      variant
    end
```

#### Encontrar diseños

Para encontrar el diseño actual, Rails primero busca un archivo en `app/views/layouts` con el mismo nombre base que el controlador. Por ejemplo, al renderizar acciones desde la clase `PhotosController`, se utilizará `app/views/layouts/photos.html.erb` (o `app/views/layouts/photos.builder`). Si no hay un diseño específico del controlador, Rails utilizará `app/views/layouts/application.html.erb` o `app/views/layouts/application.builder`. Si no hay un diseño `.erb`, Rails utilizará un diseño `.builder` si existe. Rails también proporciona varias formas de asignar diseños específicos de manera más precisa a controladores y acciones individuales.

##### Especificar diseños para controladores

Puede anular las convenciones de diseño predeterminadas en sus controladores utilizando la declaración [`layout`][]. Por ejemplo:

```ruby
class ProductsController < ApplicationController
  layout "inventory"
  #...
end
```

Con esta declaración, todas las vistas renderizadas por el `ProductsController` utilizarán `app/views/layouts/inventory.html.erb` como su diseño.

Para asignar un diseño específico para toda la aplicación, use una declaración de `layout` en su clase `ApplicationController`:

```ruby
class ApplicationController < ActionController::Base
  layout "main"
  #...
end
```

Con esta declaración, todas las vistas en toda la aplicación utilizarán `app/views/layouts/main.html.erb` como su diseño.

##### Elegir diseños en tiempo de ejecución

Puede usar un símbolo para posponer la elección del diseño hasta que se procese una solicitud:

```ruby
class ProductsController < ApplicationController
  layout :products_layout

  def show
    @product = Product.find(params[:id])
  end

  private
    def products_layout
      @current_user.special? ? "special" : "products"
    end
end
```

Ahora, si el usuario actual es un usuario especial, obtendrá un diseño especial al ver un producto.

Incluso puede usar un método en línea, como un Proc, para determinar el diseño. Por ejemplo, si pasa un objeto Proc, el bloque que le dé al Proc se le dará la instancia del `controller`, por lo que el diseño se puede determinar en función de la solicitud actual:

```ruby
class ProductsController < ApplicationController
  layout Proc.new { |controller| controller.request.xhr? ? "popup" : "application" }
end
```

##### Diseños condicionales

Los diseños especificados a nivel de controlador admiten las opciones `:only` y `:except`. Estas opciones toman un nombre de método o una matriz de nombres de métodos, que corresponden a los nombres de métodos dentro del controlador:

```ruby
class ProductsController < ApplicationController
  layout "product", except: [:index, :rss]
end
```

Con esta declaración, el diseño `product` se utilizaría para todo excepto los métodos `rss` e `index`.

##### Herencia de diseños

Las declaraciones de diseño se heredan en la jerarquía y las declaraciones de diseño más específicas siempre anulan las más generales. Por ejemplo:

* `application_controller.rb`

    ```ruby
    class ApplicationController < ActionController::Base
      layout "main"
    end
    ```

* `articles_controller.rb`

    ```ruby
    class ArticlesController < ApplicationController
    end
    ```

* `special_articles_controller.rb`

    ```ruby
    class SpecialArticlesController < ArticlesController
      layout "special"
    end
    ```

* `old_articles_controller.rb`

    ```ruby
    class OldArticlesController < SpecialArticlesController
      layout false

      def show
        @article = Article.find(params[:id])
      end

      def index
        @old_articles = Article.older
        render layout: "old"
      end
      # ...
    end
    ```

En esta aplicación:

* En general, las vistas se renderizarán en el diseño `main`
* `ArticlesController#index` utilizará el diseño `main`
* `SpecialArticlesController#index` utilizará el diseño `special`
* `OldArticlesController#show` no utilizará ningún diseño
* `OldArticlesController#index` utilizará el diseño `old`
##### Herencia de plantillas

Similar a la lógica de herencia de diseño, si no se encuentra una plantilla o parcial en la ruta convencional, el controlador buscará una plantilla o parcial para renderizar en su cadena de herencia. Por ejemplo:

```ruby
# app/controllers/application_controller.rb
class ApplicationController < ActionController::Base
end
```

```ruby
# app/controllers/admin_controller.rb
class AdminController < ApplicationController
end
```

```ruby
# app/controllers/admin/products_controller.rb
class Admin::ProductsController < AdminController
  def index
  end
end
```

El orden de búsqueda para una acción `admin/products#index` será:

* `app/views/admin/products/`
* `app/views/admin/`
* `app/views/application/`

Esto hace que `app/views/application/` sea un lugar ideal para sus parciales compartidos, que luego se pueden renderizar en su ERB de la siguiente manera:

```erb
<%# app/views/admin/products/index.html.erb %>
<%= render @products || "empty_list" %>

<%# app/views/application/_empty_list.html.erb %>
No hay elementos en esta lista <em>todavía</em>.
```

#### Evitando errores de renderización duplicada

Tarde o temprano, la mayoría de los desarrolladores de Rails verán el mensaje de error "Solo se puede renderizar o redirigir una vez por acción". Aunque esto es molesto, es relativamente fácil de solucionar. Por lo general, ocurre debido a una comprensión errónea fundamental de cómo funciona `render`.

Por ejemplo, aquí hay un código que desencadenará este error:

```ruby
def show
  @book = Book.find(params[:id])
  if @book.special?
    render action: "special_show"
  end
  render action: "regular_show"
end
```

Si `@book.special?` se evalúa como `true`, Rails iniciará el proceso de renderización para volcar la variable `@book` en la vista `special_show`. Pero esto _no_ detendrá que el resto del código en la acción `show` se ejecute, y cuando Rails llegue al final de la acción, comenzará a renderizar la vista `regular_show` y lanzará un error. La solución es simple: asegúrese de tener solo una llamada a `render` o `redirect` en un solo camino de código. Algo que puede ayudar es `return`. Aquí hay una versión parcheada del método:

```ruby
def show
  @book = Book.find(params[:id])
  if @book.special?
    render action: "special_show"
    return
  end
  render action: "regular_show"
end
```

Tenga en cuenta que la renderización implícita realizada por ActionController detecta si se ha llamado a `render`, por lo que lo siguiente funcionará sin errores:

```ruby
def show
  @book = Book.find(params[:id])
  if @book.special?
    render action: "special_show"
  end
end
```

Esto renderizará un libro con `special?` establecido con la plantilla `special_show`, mientras que otros libros se renderizarán con la plantilla `show` predeterminada.

### Uso de `redirect_to`

Otra forma de manejar las respuestas a una solicitud HTTP es con [`redirect_to`][]. Como has visto, `render` le dice a Rails qué vista (u otro recurso) usar para construir una respuesta. El método `redirect_to` hace algo completamente diferente: le dice al navegador que envíe una nueva solicitud para una URL diferente. Por ejemplo, podrías redirigir desde cualquier parte de tu código al índice de fotos en tu aplicación con esta llamada:

```ruby
redirect_to photos_url
```

Puedes usar [`redirect_back`][] para devolver al usuario a la página de la que acaba de venir. Esta ubicación se extrae del encabezado `HTTP_REFERER`, que no se garantiza que esté configurado por el navegador, por lo que debes proporcionar la `fallback_location` para usar en este caso.

```ruby
redirect_back(fallback_location: root_path)
```

NOTA: `redirect_to` y `redirect_back` no detienen ni devuelven inmediatamente la ejecución del método, simplemente establecen respuestas HTTP. Las declaraciones que ocurran después de ellos en un método se ejecutarán. Puedes detener la ejecución mediante un `return` explícito u otro mecanismo de detención, si es necesario.


#### Obteniendo un código de estado de redirección diferente

Rails utiliza el código de estado HTTP 302, una redirección temporal, cuando llamas a `redirect_to`. Si deseas utilizar un código de estado diferente, como el 301, una redirección permanente, puedes usar la opción `:status`:

```ruby
redirect_to photos_path, status: 301
```

Al igual que la opción `:status` para `render`, `:status` para `redirect_to` acepta tanto designaciones de encabezado numéricas como simbólicas.

#### La diferencia entre `render` y `redirect_to`

A veces, los desarrolladores inexpertos piensan en `redirect_to` como una especie de comando `goto`, que mueve la ejecución de un lugar a otro en tu código de Rails. Esto es _incorrecto_. Tu código se detiene y espera una nueva solicitud del navegador. Simplemente has dicho al navegador qué solicitud debe hacer a continuación, enviando un código de estado HTTP 302.

Considera estas acciones para ver la diferencia:

```ruby
def index
  @books = Book.all
end

def show
  @book = Book.find_by(id: params[:id])
  if @book.nil?
    render action: "index"
  end
end
```

Con el código en esta forma, es probable que haya un problema si la variable `@book` es `nil`. Recuerda, un `render :action` no ejecuta ningún código en la acción objetivo, por lo que nada configurará la variable `@books` que probablemente requiera la vista `index`. Una forma de solucionar esto es redirigir en lugar de renderizar:
```ruby
def index
  @books = Book.all
end

def show
  @book = Book.find_by(id: params[:id])
  if @book.nil?
    redirect_to action: :index
  end
end
```

Con este código, el navegador hará una nueva solicitud para la página de índice, se ejecutará el código en el método `index` y todo estará bien.

La única desventaja de este código es que requiere un viaje de ida y vuelta al navegador: el navegador solicitó la acción de mostrar con `/books/1` y el controlador encuentra que no hay libros, por lo que el controlador envía una respuesta de redireccionamiento 302 al navegador indicándole que vaya a `/books/`, el navegador cumple y envía una nueva solicitud de vuelta al controlador pidiendo ahora la acción `index`, el controlador luego obtiene todos los libros en la base de datos y renderiza la plantilla de índice, enviándola de vuelta al navegador que luego la muestra en tu pantalla.

Si bien en una aplicación pequeña, esta latencia adicional puede no ser un problema, es algo a tener en cuenta si el tiempo de respuesta es una preocupación. Podemos demostrar una forma de manejar esto con un ejemplo ficticio:

```ruby
def index
  @books = Book.all
end

def show
  @book = Book.find_by(id: params[:id])
  if @book.nil?
    @books = Book.all
    flash.now[:alert] = "Tu libro no fue encontrado"
    render "index"
  end
end
```

Esto detectaría que no hay libros con el ID especificado, llenaría la variable de instancia `@books` con todos los libros en el modelo y luego renderizaría directamente la plantilla `index.html.erb`, devolviéndola al navegador con un mensaje de alerta flash para decirle al usuario qué sucedió.

### Usando `head` para construir respuestas solo con encabezados

El método [`head`][] se puede utilizar para enviar respuestas solo con encabezados al navegador. El método `head` acepta un número o símbolo (ver [tabla de referencia](#la-opción-de-estado)) que representa un código de estado HTTP. El argumento de opciones se interpreta como un hash de nombres y valores de encabezado. Por ejemplo, puedes devolver solo un encabezado de error:

```ruby
head :bad_request
```

Esto produciría el siguiente encabezado:

```http
HTTP/1.1 400 Bad Request
Connection: close
Date: Sun, 24 Jan 2010 12:15:53 GMT
Transfer-Encoding: chunked
Content-Type: text/html; charset=utf-8
X-Runtime: 0.013483
Set-Cookie: _blog_session=...snip...; path=/; HttpOnly
Cache-Control: no-cache
```

O puedes usar otros encabezados HTTP para transmitir otra información:

```ruby
head :created, location: photo_path(@photo)
```

Lo cual produciría:

```http
HTTP/1.1 201 Created
Connection: close
Date: Sun, 24 Jan 2010 12:16:44 GMT
Transfer-Encoding: chunked
Location: /photos/1
Content-Type: text/html; charset=utf-8
X-Runtime: 0.083496
Set-Cookie: _blog_session=...snip...; path=/; HttpOnly
Cache-Control: no-cache
```

Estructurando diseños
-------------------

Cuando Rails renderiza una vista como respuesta, lo hace combinando la vista con el diseño actual, utilizando las reglas para encontrar el diseño actual que se cubrieron anteriormente en esta guía. Dentro de un diseño, tienes acceso a tres herramientas para combinar diferentes partes de salida para formar la respuesta general:

* Etiquetas de activos
* `yield` y [`content_for`][]
* Parciales


### Ayudantes de etiquetas de activos

Los ayudantes de etiquetas de activos proporcionan métodos para generar HTML que vinculan vistas a feeds, JavaScript, hojas de estilo, imágenes, videos y audios. Hay seis ayudantes de etiquetas de activos disponibles en Rails:

* [`auto_discovery_link_tag`][]
* [`javascript_include_tag`][]
* [`stylesheet_link_tag`][]
* [`image_tag`][]
* [`video_tag`][]
* [`audio_tag`][]

Puedes usar estas etiquetas en diseños u otras vistas, aunque las etiquetas `auto_discovery_link_tag`, `javascript_include_tag` y `stylesheet_link_tag` se utilizan más comúnmente en la sección `<head>` de un diseño.

ADVERTENCIA: Los ayudantes de etiquetas de activos no verifican la existencia de los activos en las ubicaciones especificadas; simplemente asumen que sabes lo que estás haciendo y generan el enlace.


#### Vinculando a feeds con `auto_discovery_link_tag`

El ayudante [`auto_discovery_link_tag`][] construye HTML que la mayoría de los navegadores y lectores de feeds pueden usar para detectar la presencia de feeds RSS, Atom o JSON. Toma el tipo de enlace (`:rss`, `:atom` o `:json`), un hash de opciones que se pasan a url_for y un hash de opciones para la etiqueta:

```erb
<%= auto_discovery_link_tag(:rss, {action: "feed"},
  {title: "RSS Feed"}) %>
```

Hay tres opciones de etiqueta disponibles para `auto_discovery_link_tag`:

* `:rel` especifica el valor `rel` en el enlace. El valor predeterminado es "alternate".
* `:type` especifica un tipo MIME explícito. Rails generará automáticamente un tipo MIME adecuado.
* `:title` especifica el título del enlace. El valor predeterminado es el valor `:type` en mayúsculas, por ejemplo, "ATOM" o "RSS".
#### Enlazando archivos JavaScript con `javascript_include_tag`

El ayudante [`javascript_include_tag`][] devuelve una etiqueta HTML `script` por cada fuente proporcionada.

Si estás utilizando Rails con el [Asset Pipeline](asset_pipeline.html) habilitado, este ayudante generará un enlace a `/assets/javascripts/` en lugar de `public/javascripts` que se utilizaba en versiones anteriores de Rails. Este enlace es luego servido por el asset pipeline.

Un archivo JavaScript dentro de una aplicación Rails o un motor Rails se coloca en una de tres ubicaciones: `app/assets`, `lib/assets` o `vendor/assets`. Estas ubicaciones se explican en detalle en la sección [Organización de Activos en la Guía del Asset Pipeline](asset_pipeline.html#asset-organization).

Puedes especificar una ruta completa relativa a la raíz del documento, o una URL, si lo prefieres. Por ejemplo, para enlazar a un archivo JavaScript que está dentro de un directorio llamado `javascripts` dentro de `app/assets`, `lib/assets` o `vendor/assets`, harías esto:

```erb
<%= javascript_include_tag "main" %>
```

Rails entonces generará una etiqueta `script` como esta:

```html
<script src='/assets/main.js'></script>
```

La solicitud a este activo es luego servida por la gema Sprockets.

Para incluir varios archivos como `app/assets/javascripts/main.js` y `app/assets/javascripts/columns.js` al mismo tiempo:

```erb
<%= javascript_include_tag "main", "columns" %>
```

Para incluir `app/assets/javascripts/main.js` y `app/assets/javascripts/photos/columns.js`:

```erb
<%= javascript_include_tag "main", "/photos/columns" %>
```

Para incluir `http://example.com/main.js`:

```erb
<%= javascript_include_tag "http://example.com/main.js" %>
```

#### Enlazando archivos CSS con `stylesheet_link_tag`

El ayudante [`stylesheet_link_tag`][] devuelve una etiqueta HTML `<link>` por cada fuente proporcionada.

Si estás utilizando Rails con el "Asset Pipeline" habilitado, este ayudante generará un enlace a `/assets/stylesheets/`. Este enlace es luego procesado por la gema Sprockets. Un archivo de hoja de estilo se puede almacenar en una de tres ubicaciones: `app/assets`, `lib/assets` o `vendor/assets`.

Puedes especificar una ruta completa relativa a la raíz del documento, o una URL. Por ejemplo, para enlazar a un archivo de hoja de estilo que está dentro de un directorio llamado `stylesheets` dentro de `app/assets`, `lib/assets` o `vendor/assets`, harías esto:

```erb
<%= stylesheet_link_tag "main" %>
```

Para incluir `app/assets/stylesheets/main.css` y `app/assets/stylesheets/columns.css`:

```erb
<%= stylesheet_link_tag "main", "columns" %>
```

Para incluir `app/assets/stylesheets/main.css` y `app/assets/stylesheets/photos/columns.css`:

```erb
<%= stylesheet_link_tag "main", "photos/columns" %>
```

Para incluir `http://example.com/main.css`:

```erb
<%= stylesheet_link_tag "http://example.com/main.css" %>
```

Por defecto, `stylesheet_link_tag` crea enlaces con `rel="stylesheet"`. Puedes anular esta opción predeterminada especificando una opción adecuada (`:rel`):

```erb
<%= stylesheet_link_tag "main_print", media: "print" %>
```

#### Enlazando a imágenes con `image_tag`

El ayudante [`image_tag`][] construye una etiqueta HTML `<img />` para el archivo especificado. Por defecto, los archivos se cargan desde `public/images`.

ADVERTENCIA: Ten en cuenta que debes especificar la extensión de la imagen.

```erb
<%= image_tag "header.png" %>
```

Puedes proporcionar una ruta a la imagen si lo deseas:

```erb
<%= image_tag "icons/delete.gif" %>
```

Puedes proporcionar un hash de opciones HTML adicionales:

```erb
<%= image_tag "icons/delete.gif", {height: 45} %>
```

Puedes proporcionar un texto alternativo para la imagen que se utilizará si el usuario tiene las imágenes desactivadas en su navegador. Si no especificas explícitamente un texto alternativo, se utilizará el nombre del archivo, en mayúsculas y sin extensión. Por ejemplo, estas dos etiquetas de imagen devolverían el mismo código:

```erb
<%= image_tag "home.gif" %>
<%= image_tag "home.gif", alt: "Home" %>
```

También puedes especificar una etiqueta de tamaño especial, en el formato "{ancho}x{alto}":

```erb
<%= image_tag "home.gif", size: "50x20" %>
```

Además de las etiquetas especiales mencionadas anteriormente, puedes proporcionar un hash final de opciones HTML estándar, como `:class`, `:id` o `:name`:

```erb
<%= image_tag "home.gif", alt: "Go Home",
                          id: "HomeImage",
                          class: "nav_bar" %>
```

#### Enlazando a videos con `video_tag`

El ayudante [`video_tag`][] construye una etiqueta HTML5 `<video>` para el archivo especificado. Por defecto, los archivos se cargan desde `public/videos`.

```erb
<%= video_tag "movie.ogg" %>
```

Produce

```erb
<video src="/videos/movie.ogg" />
```

Al igual que con `image_tag`, puedes proporcionar una ruta, ya sea absoluta o relativa al directorio `public/videos`. Además, puedes especificar la opción `size: "#{ancho}x#{alto}"` al igual que con `image_tag`. Las etiquetas de video también pueden tener cualquiera de las opciones HTML especificadas al final (`id`, `class`, etc.).

La etiqueta de video también admite todas las opciones HTML de `<video>`, a través del hash de opciones HTML, incluyendo:

* `poster: "nombre_imagen.png"`, proporciona una imagen para colocar en lugar del video antes de que comience a reproducirse.
* `autoplay: true`, comienza a reproducir el video al cargar la página.
* `loop: true`, repite el video una vez que llega al final.
* `controls: true`, proporciona controles suministrados por el navegador para que el usuario interactúe con el video.
* `autobuffer: true`, el video precargará el archivo para el usuario al cargar la página.
También puedes especificar varios videos para reproducir pasando una matriz de videos a `video_tag`:

```erb
<%= video_tag ["trailer.ogg", "movie.ogg"] %>
```

Esto producirá:

```erb
<video>
  <source src="/videos/trailer.ogg">
  <source src="/videos/movie.ogg">
</video>
```

#### Enlazando a archivos de audio con `audio_tag`

El ayudante [`audio_tag`][] construye una etiqueta HTML5 `<audio>` para el archivo especificado. De forma predeterminada, los archivos se cargan desde `public/audios`.

```erb
<%= audio_tag "music.mp3" %>
```

Puedes proporcionar una ruta al archivo de audio si lo deseas:

```erb
<%= audio_tag "music/first_song.mp3" %>
```

También puedes proporcionar un hash de opciones adicionales, como `:id`, `:class`, etc.

Al igual que `video_tag`, `audio_tag` tiene opciones especiales:

* `autoplay: true`, comienza a reproducir el audio al cargar la página
* `controls: true`, proporciona controles suministrados por el navegador para que el usuario interactúe con el audio.
* `autobuffer: true`, el audio precargará el archivo para el usuario al cargar la página.

### Entendiendo `yield`

Dentro del contexto de un diseño, `yield` identifica una sección donde se debe insertar el contenido de la vista. La forma más sencilla de usar esto es tener un solo `yield`, en el cual se inserta todo el contenido de la vista que se está renderizando actualmente:

```html+erb
<html>
  <head>
  </head>
  <body>
  <%= yield %>
  </body>
</html>
```

También puedes crear un diseño con múltiples regiones de `yield`:

```html+erb
<html>
  <head>
  <%= yield :head %>
  </head>
  <body>
  <%= yield %>
  </body>
</html>
```

El cuerpo principal de la vista siempre se renderizará en el `yield` sin nombre. Para renderizar contenido en un `yield` con nombre, se utiliza el método `content_for`.

### Uso del método `content_for`

El método [`content_for`][] te permite insertar contenido en un bloque `yield` con nombre en tu diseño. Por ejemplo, esta vista funcionaría con el diseño que acabas de ver:

```html+erb
<% content_for :head do %>
  <title>Una página simple</title>
<% end %>

<p>Hola, Rails!</p>
```

El resultado de renderizar esta página en el diseño proporcionado sería este HTML:

```html+erb
<html>
  <head>
  <title>Una página simple</title>
  </head>
  <body>
  <p>Hola, Rails!</p>
  </body>
</html>
```

El método `content_for` es muy útil cuando tu diseño contiene regiones distintas, como barras laterales y pies de página, que deben tener sus propios bloques de contenido insertados. También es útil para insertar etiquetas que cargan archivos JavaScript o CSS específicos de la página en la cabecera de un diseño genérico.

### Uso de parciales

Las plantillas parciales, generalmente llamadas "parciales", son otro recurso para dividir el proceso de renderizado en fragmentos más manejables. Con un parcial, puedes mover el código para renderizar una parte específica de una respuesta a su propio archivo.

#### Nombres de parciales

Para renderizar un parcial como parte de una vista, se utiliza el método [`render`][view.render] dentro de la vista:

```html+erb
<%= render "menu" %>
```

Esto renderizará un archivo llamado `_menu.html.erb` en ese punto dentro de la vista que se está renderizando. Observa el carácter de guión bajo al principio: los parciales se nombran con un guión bajo al principio para distinguirlos de las vistas regulares, aunque se los menciona sin el guión bajo. Esto también es válido cuando se incluye un parcial desde otra carpeta:

```html+erb
<%= render "shared/menu" %>
```

Ese código incluirá el parcial desde `app/views/shared/_menu.html.erb`.


#### Uso de parciales para simplificar vistas

Una forma de utilizar parciales es tratarlos como el equivalente de subrutinas: como una forma de mover los detalles fuera de una vista para que puedas entender lo que está sucediendo más fácilmente. Por ejemplo, podrías tener una vista que se vea así:

```erb
<%= render "shared/ad_banner" %>

<h1>Productos</h1>

<p>Aquí tienes algunos de nuestros excelentes productos:</p>
...

<%= render "shared/footer" %>
```

Aquí, los parciales `_ad_banner.html.erb` y `_footer.html.erb` podrían contener contenido que se comparte en muchas páginas de tu aplicación. No necesitas ver los detalles de estas secciones cuando te estás concentrando en una página en particular.

Como se vio en las secciones anteriores de esta guía, `yield` es una herramienta muy poderosa para limpiar tus diseños. Ten en cuenta que es puro Ruby, por lo que puedes usarlo casi en cualquier lugar. Por ejemplo, podemos usarlo para DRY (Don't Repeat Yourself) en la definición del diseño de un formulario para varios recursos similares:

* `users/index.html.erb`

    ```html+erb
    <%= render "shared/search_filters", search: @q do |form| %>
      <p>
        El nombre contiene: <%= form.text_field :name_contains %>
      </p>
    <% end %>
    ```

* `roles/index.html.erb`

    ```html+erb
    <%= render "shared/search_filters", search: @q do |form| %>
      <p>
        El título contiene: <%= form.text_field :title_contains %>
      </p>
    <% end %>
    ```
* `shared/_search_filters.html.erb`

    ```html+erb
    <%= form_with model: search do |form| %>
      <h1>Formulario de búsqueda:</h1>
      <fieldset>
        <%= yield form %>
      </fieldset>
      <p>
        <%= form.submit "Buscar" %>
      </p>
    <% end %>
    ```

CONSEJO: Para el contenido que se comparte en todas las páginas de tu aplicación, puedes usar parciales directamente desde los layouts.

#### Layouts parciales

Un parcial puede usar su propio archivo de layout, al igual que una vista puede usar un layout. Por ejemplo, podrías llamar a un parcial de esta manera:

```erb
<%= render partial: "link_area", layout: "graybar" %>
```

Esto buscaría un parcial llamado `_link_area.html.erb` y lo renderizaría utilizando el layout `_graybar.html.erb`. Ten en cuenta que los layouts para parciales siguen la misma convención de nombres con guión bajo al principio que los parciales regulares, y se colocan en la misma carpeta que el parcial al que pertenecen (no en la carpeta principal `layouts`).

También ten en cuenta que es necesario especificar explícitamente `:partial` al pasar opciones adicionales como `:layout`.

#### Pasando variables locales

También puedes pasar variables locales a los parciales, lo que los hace aún más poderosos y flexibles. Por ejemplo, puedes usar esta técnica para reducir la duplicación entre las páginas de creación y edición, manteniendo al mismo tiempo un poco de contenido distinto:

* `new.html.erb`

    ```html+erb
    <h1>Nueva zona</h1>
    <%= render partial: "form", locals: {zone: @zone} %>
    ```

* `edit.html.erb`

    ```html+erb
    <h1>Editando zona</h1>
    <%= render partial: "form", locals: {zone: @zone} %>
    ```

* `_form.html.erb`

    ```html+erb
    <%= form_with model: zone do |form| %>
      <p>
        <b>Nombre de la zona</b><br>
        <%= form.text_field :name %>
      </p>
      <p>
        <%= form.submit %>
      </p>
    <% end %>
    ```

Aunque se renderizará el mismo parcial en ambas vistas, el helper de submit de Action View devolverá "Crear zona" para la acción de creación y "Actualizar zona" para la acción de edición.

Para pasar una variable local a un parcial solo en casos específicos, utiliza `local_assigns`.

* `index.html.erb`

    ```erb
    <%= render user.articles %>
    ```

* `show.html.erb`

    ```erb
    <%= render article, full: true %>
    ```

* `_article.html.erb`

    ```erb
    <h2><%= article.title %></h2>

    <% if local_assigns[:full] %>
      <%= simple_format article.body %>
    <% else %>
      <%= truncate article.body %>
    <% end %>
    ```

De esta manera es posible utilizar el parcial sin necesidad de declarar todas las variables locales.

Cada parcial también tiene una variable local con el mismo nombre que el parcial (sin el guión bajo inicial). Puedes pasar un objeto a esta variable local a través de la opción `:object`:

```erb
<%= render partial: "customer", object: @new_customer %>
```

Dentro del parcial `customer`, la variable `customer` se referirá a `@new_customer` de la vista principal.

Si tienes una instancia de un modelo para renderizar en un parcial, puedes usar una sintaxis abreviada:

```erb
<%= render @customer %>
```

Suponiendo que la variable de instancia `@customer` contiene una instancia del modelo `Customer`, esto utilizará `_customer.html.erb` para renderizarlo y pasará la variable local `customer` al parcial, que se referirá a la variable de instancia `@customer` en la vista principal.

#### Renderizando colecciones

Los parciales son muy útiles para renderizar colecciones. Cuando pasas una colección a un parcial a través de la opción `:collection`, el parcial se insertará una vez por cada miembro de la colección:

* `index.html.erb`

    ```html+erb
    <h1>Productos</h1>
    <%= render partial: "product", collection: @products %>
    ```

* `_product.html.erb`

    ```html+erb
    <p>Nombre del producto: <%= product.name %></p>
    ```

Cuando se llama a un parcial con una colección en plural, las instancias individuales del parcial tienen acceso al miembro de la colección que se está renderizando a través de una variable con el nombre del parcial. En este caso, el parcial es `_product`, y dentro del parcial `_product`, puedes referirte a `product` para obtener la instancia que se está renderizando.

También hay una forma abreviada para esto. Suponiendo que `@products` es una colección de instancias de `Product`, simplemente puedes escribir esto en `index.html.erb` para obtener el mismo resultado:

```html+erb
<h1>Productos</h1>
<%= render @products %>
```

Rails determina el nombre del parcial a utilizar al mirar el nombre del modelo en la colección. De hecho, incluso puedes crear una colección heterogénea y renderizarla de esta manera, y Rails elegirá el parcial adecuado para cada miembro de la colección:

* `index.html.erb`

    ```html+erb
    <h1>Contactos</h1>
    <%= render [customer1, employee1, customer2, employee2] %>
    ```

* `customers/_customer.html.erb`

    ```html+erb
    <p>Cliente: <%= customer.name %></p>
    ```

* `employees/_employee.html.erb`

    ```html+erb
    <p>Empleado: <%= employee.name %></p>
    ```

En este caso, Rails utilizará los parciales `customer` o `employee` según corresponda para cada miembro de la colección.
En caso de que la colección esté vacía, `render` devolverá nil, por lo que debería ser bastante sencillo proporcionar un contenido alternativo.

```html+erb
<h1>Productos</h1>
<%= render(@products) || "No hay productos disponibles." %>
```

#### Variables locales

Para usar un nombre de variable local personalizado dentro de la plantilla parcial, especifique la opción `:as` en la llamada a la parcial:

```erb
<%= render partial: "product", collection: @products, as: :item %>
```

Con este cambio, puedes acceder a una instancia de la colección `@products` como la variable local `item` dentro de la parcial.

También puedes pasar variables locales arbitrarias a cualquier parcial que estés renderizando con la opción `locals: {}`:

```erb
<%= render partial: "product", collection: @products,
           as: :item, locals: {title: "Página de Productos"} %>
```

En este caso, la parcial tendrá acceso a una variable local `title` con el valor "Página de Productos".

#### Variables de contador

Rails también pone a disposición una variable de contador dentro de una parcial llamada por la colección. La variable se llama igual que el nombre de la parcial seguido de `_counter`. Por ejemplo, al renderizar una colección `@products`, la parcial `_product.html.erb` puede acceder a la variable `product_counter`. La variable indexa el número de veces que la parcial se ha renderizado dentro de la vista que la contiene, comenzando con un valor de `0` en la primera renderización.

```erb
# index.html.erb
<%= render partial: "product", collection: @products %>
```

```erb
# _product.html.erb
<%= product_counter %> # 0 para el primer producto, 1 para el segundo producto...
```

Esto también funciona cuando se cambia el nombre de la parcial usando la opción `as:`. Entonces, si hicieras `as: :item`, la variable de contador sería `item_counter`.

#### Plantillas de separador

También puedes especificar una segunda parcial que se renderizará entre las instancias de la parcial principal usando la opción `:spacer_template`:

```erb
<%= render partial: @products, spacer_template: "product_ruler" %>
```

Rails renderizará la parcial `_product_ruler` (sin pasarle datos) entre cada par de parciales `_product`.

#### Diseños de parciales de colecciones

Al renderizar colecciones, también es posible usar la opción `:layout`:

```erb
<%= render partial: "product", collection: @products, layout: "special_layout" %>
```

El diseño se renderizará junto con la parcial para cada elemento de la colección. Las variables de objeto actual y object_counter también estarán disponibles en el diseño de la misma manera que lo están dentro de la parcial.

### Uso de diseños anidados

Es posible que tu aplicación requiera un diseño que difiera ligeramente de tu diseño de aplicación regular para admitir un controlador en particular. En lugar de repetir el diseño principal y editarlo, puedes lograr esto utilizando diseños anidados (a veces llamados sub-plantillas). Aquí tienes un ejemplo:

Supongamos que tienes el siguiente diseño de `ApplicationController`:

* `app/views/layouts/application.html.erb`

    ```html+erb
    <html>
    <head>
      <title><%= @page_title or "Título de la página" %></title>
      <%= stylesheet_link_tag "layout" %>
      <style><%= yield :stylesheets %></style>
    </head>
    <body>
      <div id="top_menu">Elementos del menú superior aquí</div>
      <div id="menu">Elementos del menú aquí</div>
      <div id="content"><%= content_for?(:content) ? yield(:content) : yield %></div>
    </body>
    </html>
    ```

En las páginas generadas por `NewsController`, quieres ocultar el menú superior y agregar un menú derecho:

* `app/views/layouts/news.html.erb`

    ```html+erb
    <% content_for :stylesheets do %>
      #top_menu {display: none}
      #right_menu {float: right; background-color: yellow; color: black}
    <% end %>
    <% content_for :content do %>
      <div id="right_menu">Elementos del menú derecho aquí</div>
      <%= content_for?(:news_content) ? yield(:news_content) : yield %>
    <% end %>
    <%= render template: "layouts/application" %>
    ```

Eso es todo. Las vistas de News utilizarán el nuevo diseño, ocultando el menú superior y agregando un nuevo menú derecho dentro del div "content".

Hay varias formas de obtener resultados similares con diferentes esquemas de sub-plantillas utilizando esta técnica. Ten en cuenta que no hay límite en los niveles de anidamiento. Se puede usar el método `ActionView::render` a través de `render template: 'layouts/news'` para basar un nuevo diseño en el diseño de News. Si estás seguro de que no vas a sub-plantillar el diseño de News, puedes reemplazar `content_for?(:news_content) ? yield(:news_content) : yield` simplemente con `yield`.
[controller.render]: https://api.rubyonrails.org/classes/ActionController/Rendering.html#method-i-render
[`redirect_to`]: https://api.rubyonrails.org/classes/ActionController/Redirecting.html#method-i-redirect_to
[`head`]: https://api.rubyonrails.org/classes/ActionController/Head.html#method-i-head
[`layout`]: https://api.rubyonrails.org/classes/ActionView/Layouts/ClassMethods.html#method-i-layout
[`redirect_back`]: https://api.rubyonrails.org/classes/ActionController/Redirecting.html#method-i-redirect_back
[`content_for`]: https://api.rubyonrails.org/classes/ActionView/Helpers/CaptureHelper.html#method-i-content_for
[`auto_discovery_link_tag`]: https://api.rubyonrails.org/classes/ActionView/Helpers/AssetTagHelper.html#method-i-auto_discovery_link_tag
[`javascript_include_tag`]: https://api.rubyonrails.org/classes/ActionView/Helpers/AssetTagHelper.html#method-i-javascript_include_tag
[`stylesheet_link_tag`]: https://api.rubyonrails.org/classes/ActionView/Helpers/AssetTagHelper.html#method-i-stylesheet_link_tag
[`image_tag`]: https://api.rubyonrails.org/classes/ActionView/Helpers/AssetTagHelper.html#method-i-image_tag
[`video_tag`]: https://api.rubyonrails.org/classes/ActionView/Helpers/AssetTagHelper.html#method-i-video_tag
[`audio_tag`]: https://api.rubyonrails.org/classes/ActionView/Helpers/AssetTagHelper.html#method-i-audio_tag
[view.render]: https://api.rubyonrails.org/classes/ActionView/Helpers/RenderingHelper.html#method-i-render
