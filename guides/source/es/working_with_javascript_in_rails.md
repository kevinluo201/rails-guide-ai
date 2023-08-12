**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: c1e56036aa9fd68276daeec5a9407096
Trabajando con JavaScript en Rails
==================================

Esta guía cubre las opciones para integrar funcionalidad de JavaScript en tu aplicación de Rails,
incluyendo las opciones que tienes para usar paquetes de JavaScript externos y cómo usar Turbo con
Rails.

Después de leer esta guía, sabrás:

* Cómo usar Rails sin necesidad de Node.js, Yarn o un empaquetador de JavaScript.
* Cómo crear una nueva aplicación de Rails usando import maps, esbuild, rollup o webpack para
  empaquetar tu JavaScript.
* Qué es Turbo y cómo usarlo.
* Cómo usar los ayudantes HTML de Turbo proporcionados por Rails.

--------------------------------------------------------------------------------

Import Maps
-----------

[Import maps](https://github.com/rails/importmap-rails) te permiten importar módulos de JavaScript
usando nombres lógicos que se mapean a archivos versionados directamente desde el navegador. Los
import maps son la opción predeterminada a partir de Rails 7, lo que permite a cualquiera construir
aplicaciones de JavaScript modernas utilizando la mayoría de los paquetes de NPM sin necesidad de
transpilar o empaquetar.

Las aplicaciones que utilizan import maps no necesitan [Node.js](https://nodejs.org/en/) ni
[Yarn](https://yarnpkg.com/) para funcionar. Si planeas usar Rails con `importmap-rails` para
administrar tus dependencias de JavaScript, no es necesario instalar Node.js ni Yarn.

Cuando usas import maps, no se requiere un proceso de compilación separado, simplemente inicia tu
servidor con `bin/rails server` y estás listo para comenzar.

### Instalando importmap-rails

Importmap para Rails se incluye automáticamente en Rails 7+ para nuevas aplicaciones, pero también
puedes instalarlo manualmente en aplicaciones existentes:

```bash
$ bin/bundle add importmap-rails
```

Ejecuta la tarea de instalación:

```bash
$ bin/rails importmap:install
```

### Agregando paquetes de NPM con importmap-rails

Para agregar nuevos paquetes a tu aplicación impulsada por import map, ejecuta el comando
`bin/importmap pin` desde tu terminal:

```bash
$ bin/importmap pin react react-dom
```

Luego, importa el paquete en `application.js` como de costumbre:

```javascript
import React from "react"
import ReactDOM from "react-dom"
```

Agregando paquetes de NPM con empaquetadores de JavaScript
---------------------------------------------------------

Los import maps son la opción predeterminada para nuevas aplicaciones de Rails, pero si prefieres
el empaquetado tradicional de JavaScript, puedes crear nuevas aplicaciones de Rails con tu opción
preferida de [esbuild](https://esbuild.github.io/), [webpack](https://webpack.js.org/) o
[rollup.js](https://rollupjs.org/guide/en/).

Para usar un empaquetador en lugar de import maps en una nueva aplicación de Rails, pasa la opción
`--javascript` o `-j` a `rails new`:

```bash
$ rails new my_new_app --javascript=webpack
O
$ rails new my_new_app -j webpack
```

Estas opciones de empaquetado vienen con una configuración simple e integración con el pipeline de
assets a través de la gema [jsbundling-rails](https://github.com/rails/jsbundling-rails).

Cuando uses una opción de empaquetado, usa `bin/dev` para iniciar el servidor de Rails y compilar
JavaScript para desarrollo.

### Instalando Node.js y Yarn

Si estás utilizando un empaquetador de JavaScript en tu aplicación de Rails, Node.js y Yarn deben
estar instalados.

Encuentra las instrucciones de instalación en el sitio web de [Node.js](https://nodejs.org/en/download/)
y verifica que esté instalado correctamente con el siguiente comando:

```bash
$ node --version
```

La versión de tu entorno de ejecución de Node.js debería mostrarse. Asegúrate de que sea mayor que `8.16.0`.

Para instalar Yarn, sigue las instrucciones de instalación en el sitio web de
[Yarn](https://classic.yarnpkg.com/en/docs/install). Ejecutar este comando debería mostrar la versión de Yarn:

```bash
$ yarn --version
```

Si muestra algo como `1.22.0`, Yarn se ha instalado correctamente.

Elegir entre Import Maps y un Empaquetador de JavaScript
-------------------------------------------------------

Cuando creas una nueva aplicación de Rails, deberás elegir entre import maps y una solución de
empaquetado de JavaScript. Cada aplicación tiene diferentes requisitos y debes considerar tus
requisitos cuidadosamente antes de elegir una opción de JavaScript, ya que migrar de una opción a
otra puede llevar mucho tiempo en aplicaciones grandes y complejas.

Los import maps son la opción predeterminada porque el equipo de Rails cree en el potencial de los
import maps para reducir la complejidad, mejorar la experiencia del desarrollador y ofrecer mejoras
de rendimiento.

Para muchas aplicaciones, especialmente aquellas que dependen principalmente del stack de
[Hotwire](https://hotwired.dev/) para sus necesidades de JavaScript, los import maps serán la opción
correcta a largo plazo. Puedes leer más sobre el razonamiento detrás de hacer que los import maps
sean la opción predeterminada en Rails 7
[aquí](https://world.hey.com/dhh/rails-7-will-have-three-great-answers-to-javascript-in-2021-8d68191b).

Otras aplicaciones aún pueden necesitar un empaquetador de JavaScript tradicional. Los requisitos
que indican que debes elegir un empaquetador tradicional incluyen:

* Si tu código requiere un paso de transpilación, como JSX o TypeScript.
* Si necesitas usar bibliotecas de JavaScript que incluyen CSS o dependen de
  [Webpack loaders](https://webpack.js.org/loaders/).
* Si estás absolutamente seguro de que necesitas
  [tree-shaking](https://webpack.js.org/guides/tree-shaking/).
* Si vas a instalar Bootstrap, Bulma, PostCSS o Dart CSS a través de la gema
  [cssbundling-rails](https://github.com/rails/cssbundling-rails). Todas las opciones proporcionadas
  por esta gema, excepto Tailwind y Sass, instalarán automáticamente `esbuild` si no especificas una
  opción diferente en `rails new`.
Turbo
-----

Ya sea que elijas mapas de importación o un empaquetador tradicional, Rails viene con [Turbo](https://turbo.hotwired.dev/) para acelerar tu aplicación mientras reduce drásticamente la cantidad de JavaScript que necesitarás escribir.

Turbo permite que tu servidor entregue HTML directamente como alternativa a los frameworks front-end predominantes que reducen el lado del servidor de tu aplicación Rails a poco más que una API JSON.

### Turbo Drive

[Turbo Drive](https://turbo.hotwired.dev/handbook/drive) acelera la carga de páginas evitando desmontajes y reconstrucciones completas en cada solicitud de navegación. Turbo Drive es una mejora y reemplazo de Turbolinks.

### Turbo Frames

[Turbo Frames](https://turbo.hotwired.dev/handbook/frames) permite actualizar partes predefinidas de una página a pedido, sin afectar el resto del contenido de la página.

Puedes usar Turbo Frames para construir edición en el lugar sin ningún JavaScript personalizado, cargar contenido de forma perezosa y crear interfaces con pestañas renderizadas en el servidor con facilidad.

Rails proporciona ayudantes HTML para simplificar el uso de Turbo Frames a través de la gema [turbo-rails](https://github.com/hotwired/turbo-rails).

Usando esta gema, puedes agregar un Turbo Frame a tu aplicación con el ayudante `turbo_frame_tag` de la siguiente manera:

```erb
<%= turbo_frame_tag dom_id(post) do %>
  <div>
     <%= link_to post.title, post_path(post) %>
  </div>
<% end %>
```

### Turbo Streams

[Turbo Streams](https://turbo.hotwired.dev/handbook/streams) entregan cambios en la página como fragmentos de HTML envueltos en elementos `<turbo-stream>` autoejecutables. Turbo Streams te permite transmitir cambios realizados por otros usuarios a través de WebSockets y actualizar partes de una página después de enviar un formulario sin requerir una carga completa de la página.

Rails proporciona ayudantes HTML y de servidor para simplificar el uso de Turbo Streams a través de la gema [turbo-rails](https://github.com/hotwired/turbo-rails).

Usando esta gema, puedes renderizar Turbo Streams desde una acción del controlador:

```ruby
def create
  @post = Post.new(post_params)

  respond_to do |format|
    if @post.save
      format.turbo_stream
    else
      format.html { render :new, status: :unprocessable_entity }
    end
  end
end
```

Rails buscará automáticamente un archivo de vista `.turbo_stream.erb` y renderizará esa vista cuando se encuentre.

Las respuestas de Turbo Stream también se pueden renderizar en línea en la acción del controlador:

```ruby
def create
  @post = Post.new(post_params)

  respond_to do |format|
    if @post.save
      format.turbo_stream { render turbo_stream: turbo_stream.prepend('posts', partial: 'post') }
    else
      format.html { render :new, status: :unprocessable_entity }
    end
  end
end
```

Finalmente, los Turbo Streams se pueden iniciar desde un modelo o un trabajo en segundo plano utilizando ayudantes incorporados. Estas transmisiones se pueden utilizar para actualizar el contenido a través de una conexión WebSocket a todos los usuarios, manteniendo el contenido de la página actualizado y dando vida a tu aplicación.

Para transmitir un Turbo Stream desde un modelo, combina un callback del modelo de esta manera:

```ruby
class Post < ApplicationRecord
  after_create_commit { broadcast_append_to('posts') }
end
```

Con una conexión WebSocket configurada en la página que debe recibir las actualizaciones de esta manera:

```erb
<%= turbo_stream_from "posts" %>
```

Reemplazos para la funcionalidad de Rails/UJS
--------------------------------------------

Rails 6 incluyó una herramienta llamada UJS (JavaScript no intrusivo). UJS permite a los desarrolladores anular el método de solicitud HTTP de las etiquetas `<a>`, agregar diálogos de confirmación antes de ejecutar una acción y más. UJS era el valor predeterminado antes de Rails 7, pero ahora se recomienda usar Turbo en su lugar.

### Método

Hacer clic en los enlaces siempre resulta en una solicitud HTTP GET. Si tu aplicación es [RESTful](https://en.wikipedia.org/wiki/Representational_State_Transfer), algunos enlaces son en realidad acciones que cambian datos en el servidor y deben realizarse con solicitudes no GET. El atributo `data-turbo-method` permite marcar dichos enlaces con un método explícito como "post", "put" o "delete".

Turbo escaneará las etiquetas `<a>` en tu aplicación en busca del atributo de datos `turbo-method` y utilizará el método especificado cuando esté presente, anulando la acción GET predeterminada.

Por ejemplo:

```erb
<%= link_to "Eliminar publicación", post_path(post), data: { turbo_method: "delete" } %>
```

Esto genera:

```html
<a data-turbo-method="delete" href="...">Eliminar publicación</a>
```

Una alternativa para cambiar el método de un enlace con `data-turbo-method` es usar el ayudante `button_to` de Rails. Por razones de accesibilidad, los botones y los formularios reales son preferibles para cualquier acción que no sea GET.

### Confirmaciones

Puedes solicitar una confirmación adicional al usuario agregando el atributo `data-turbo-confirm` en enlaces y formularios. Al hacer clic en el enlace o enviar el formulario, se presentará al usuario un cuadro de diálogo `confirm()` de JavaScript que contiene el texto del atributo. Si el usuario elige cancelar, la acción no se llevará a cabo.

Por ejemplo, con el ayudante `link_to`:

```erb
<%= link_to "Eliminar publicación", post_path(post), data: { turbo_method: "delete", turbo_confirm: "¿Estás seguro?" } %>
```

Lo cual genera:

```html
<a href="..." data-turbo-confirm="¿Estás seguro?" data-turbo-method="delete">Eliminar publicación</a>
```
Cuando el usuario hace clic en el enlace "Eliminar publicación", se le presentará un cuadro de diálogo de confirmación que dice "¿Estás seguro?".

El atributo también se puede usar con el ayudante `button_to`, sin embargo, debe agregarse al formulario que el ayudante `button_to` renderiza internamente:

```erb
<%= button_to "Eliminar publicación", post, method: :delete, form: { data: { turbo_confirm: "¿Estás seguro?" } } %>
```

### Solicitudes Ajax

Cuando se realizan solicitudes no GET desde JavaScript, se requiere el encabezado `X-CSRF-Token`. Sin este encabezado, Rails no aceptará las solicitudes.

NOTA: Este token es necesario en Rails para prevenir ataques de falsificación de solicitudes entre sitios (CSRF). Lee más en la [guía de seguridad](security.html#cross-site-request-forgery-csrf).

[Rails Request.JS](https://github.com/rails/request.js) encapsula la lógica de agregar los encabezados de solicitud que son requeridos por Rails. Solo importa la clase `FetchRequest` del paquete e instanciala pasando el método de solicitud, la URL, las opciones, luego llama a `await request.perform()` y haz lo que necesites con la respuesta.

Por ejemplo:

```javascript
import { FetchRequest } from '@rails/request.js'

....

async myMethod () {
  const request = new FetchRequest('post', 'localhost:3000/posts', {
    body: JSON.stringify({ name: 'Request.JS' })
  })
  const response = await request.perform()
  if (response.ok) {
    const body = await response.text
  }
}
```

Cuando se utiliza otra biblioteca para realizar llamadas Ajax, es necesario agregar el token de seguridad como un encabezado predeterminado por ti mismo. Para obtener el token, revisa la etiqueta `<meta name='csrf-token' content='THE-TOKEN'>` impresa por [`csrf_meta_tags`][] en la vista de tu aplicación. Podrías hacer algo como esto:

```javascript
document.head.querySelector("meta[name=csrf-token]")?.content
```
[`csrf_meta_tags`]: https://api.rubyonrails.org/classes/ActionView/Helpers/CsrfHelper.html#method-i-csrf_meta_tags
