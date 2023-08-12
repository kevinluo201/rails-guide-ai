**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: a4b9132308ed3786777061bd137af660
Resumen de Action Text
=======================

Esta guía te proporciona todo lo que necesitas para comenzar a manejar contenido de texto enriquecido.

Después de leer esta guía, sabrás:

* Cómo configurar Action Text.
* Cómo manejar contenido de texto enriquecido.
* Cómo dar estilo al contenido de texto enriquecido y a los adjuntos.

--------------------------------------------------------------------------------

¿Qué es Action Text?
--------------------

Action Text trae contenido de texto enriquecido y edición a Rails. Incluye el editor [Trix](https://trix-editor.org) que maneja todo, desde el formato hasta los enlaces, citas, listas, imágenes incrustadas y galerías. El contenido de texto enriquecido generado por el editor Trix se guarda en su propio modelo RichText que está asociado con cualquier modelo Active Record existente en la aplicación. Las imágenes incrustadas (u otros adjuntos) se almacenan automáticamente utilizando Active Storage y se asocian con el modelo RichText incluido.

## Trix en comparación con otros editores de texto enriquecido

La mayoría de los editores WYSIWYG son envoltorios alrededor de las APIs `contenteditable` y `execCommand` de HTML, diseñadas por Microsoft para admitir la edición en vivo de páginas web en Internet Explorer 5.5, y [eventualmente ingenierizadas inversamente](https://blog.whatwg.org/the-road-to-html-5-contenteditable#history) y copiadas por otros navegadores.

Debido a que estas APIs nunca se especificaron ni documentaron completamente, y porque los editores de HTML WYSIWYG son enormes en alcance, la implementación de cada navegador tiene su propio conjunto de errores y peculiaridades, y los desarrolladores de JavaScript se ven obligados a resolver las inconsistencias.

Trix evita estas inconsistencias tratando contenteditable como un dispositivo de entrada/salida: cuando la entrada llega al editor, Trix convierte esa entrada en una operación de edición en su modelo de documento interno, y luego vuelve a renderizar ese documento en el editor. Esto le da a Trix un control completo sobre lo que sucede después de cada pulsación de tecla y evita la necesidad de usar execCommand en absoluto.

## Instalación

Ejecuta `bin/rails action_text:install` para agregar el paquete Yarn y copiar la migración necesaria. Además, debes configurar Active Storage para las imágenes incrustadas y otros adjuntos. Consulta la guía [Resumen de Active Storage](active_storage_overview.html) para obtener más información.

NOTA: Action Text utiliza relaciones polimórficas con la tabla `action_text_rich_texts` para que pueda compartirse con todos los modelos que tienen atributos de texto enriquecido. Si tus modelos con contenido de Action Text utilizan valores UUID para los identificadores, todos los modelos que utilizan atributos de Action Text deberán utilizar valores UUID para sus identificadores únicos. La migración generada para Action Text también deberá actualizarse para especificar `type: :uuid` en la línea `references :record`.

Después de completar la instalación, una aplicación Rails debería tener los siguientes cambios:

1. Tanto `trix` como `@rails/actiontext` deben requerirse en el punto de entrada de JavaScript.

    ```js
    // application.js
    import "trix"
    import "@rails/actiontext"
    ```

2. La hoja de estilos `trix` se incluirá junto con los estilos de Action Text en tu archivo `application.css`.

## Creación de contenido de texto enriquecido

Agrega un campo de texto enriquecido a un modelo existente:

```ruby
# app/models/message.rb
class Message < ApplicationRecord
  has_rich_text :content
end
```

o agrega un campo de texto enriquecido al crear un nuevo modelo usando:

```bash
$ bin/rails generate model Message content:rich_text
```

NOTA: no necesitas agregar un campo `content` a tu tabla `messages`.

Luego, utiliza [`rich_text_area`] para hacer referencia a este campo en el formulario del modelo:

```erb
<%# app/views/messages/_form.html.erb %>
<%= form_with model: message do |form| %>
  <div class="field">
    <%= form.label :content %>
    <%= form.rich_text_area :content %>
  </div>
<% end %>
```

Y finalmente, muestra el contenido de texto enriquecido sanitizado en una página:

```erb
<%= @message.content %>
```

NOTA: Si hay un recurso adjunto dentro del campo `content`, es posible que no se muestre correctamente a menos que tengas instalado localmente el paquete *libvips/libvips42*. Consulta su [documentación de instalación](https://www.libvips.org/install.html) para obtener más información.

Para aceptar el contenido de texto enriquecido, todo lo que tienes que hacer es permitir el atributo referenciado:

```ruby
class MessagesController < ApplicationController
  def create
    message = Message.create! params.require(:message).permit(:title, :content)
    redirect_to message
  end
end
```


## Renderización de contenido de texto enriquecido

Por defecto, Action Text renderizará el contenido de texto enriquecido dentro de un elemento con la clase `.trix-content`:

```html+erb
<%# app/views/layouts/action_text/contents/_content.html.erb %>
<div class="trix-content">
  <%= yield %>
</div>
```

Los elementos con esta clase, así como el editor de Action Text, tienen estilos definidos por la hoja de estilos [`trix`](https://unpkg.com/trix/dist/trix.css). Para proporcionar tus propios estilos, elimina la línea `= require trix` de la hoja de estilos `app/assets/stylesheets/actiontext.css` creada por el instalador.

Para personalizar el HTML renderizado alrededor del contenido de texto enriquecido, edita la plantilla `app/views/layouts/action_text/contents/_content.html.erb` creada por el instalador.

Para personalizar el HTML renderizado para las imágenes incrustadas y otros adjuntos (conocidos como blobs), edita la plantilla `app/views/active_storage/blobs/_blob.html.erb` creada por el instalador.
### Renderización de adjuntos

Además de los adjuntos cargados a través de Active Storage, Action Text puede incrustar cualquier cosa que pueda resolverse mediante un [Signed GlobalID](https://github.com/rails/globalid#signed-global-ids).

Action Text renderiza elementos `<action-text-attachment>` incrustados resolviendo su atributo `sgid` en una instancia. Una vez resuelta, esa instancia se pasa a [`render`](https://api.rubyonrails.org/classes/ActionView/Helpers/RenderingHelper.html#method-i-render). El HTML resultante se incrusta como descendiente del elemento `<action-text-attachment>`.

Por ejemplo, considera un modelo `User`:

```ruby
# app/models/user.rb
class User < ApplicationRecord
  has_one_attached :avatar
end

user = User.find(1)
user.to_global_id.to_s #=> gid://MyRailsApp/User/1
user.to_signed_global_id.to_s #=> BAh7CEkiCG…
```

A continuación, considera un contenido de texto enriquecido que incrusta un elemento `<action-text-attachment>` que hace referencia al GlobalID firmado de la instancia `User`:

```html
<p>Hola, <action-text-attachment sgid="BAh7CEkiCG…"></action-text-attachment>.</p>
```

Action Text resuelve el String "BAh7CEkiCG…" para resolver la instancia `User`. A continuación, considera la vista parcial `users/user` de la aplicación:

```html+erb
<%# app/views/users/_user.html.erb %>
<span><%= image_tag user.avatar %> <%= user.name %></span>
```

El HTML resultante renderizado por Action Text se vería algo así:

```html
<p>Hola, <action-text-attachment sgid="BAh7CEkiCG…"><span><img src="..."> Jane Doe</span></action-text-attachment>.</p>
```

Para renderizar una vista parcial diferente, define `User#to_attachable_partial_path`:

```ruby
class User < ApplicationRecord
  def to_attachable_partial_path
    "users/attachable"
  end
end
```

Luego declara esa vista parcial. La instancia `User` estará disponible como la variable local parcial `user`:

```html+erb
<%# app/views/users/_attachable.html.erb %>
<span><%= image_tag user.avatar %> <%= user.name %></span>
```

Si Action Text no puede resolver la instancia `User` (por ejemplo, si el registro ha sido eliminado), se renderizará una vista parcial de fallback predeterminada.

Rails proporciona una vista parcial global para adjuntos faltantes. Esta vista parcial se instala en tu aplicación en `views/action_text/attachables/missing_attachable` y se puede modificar si deseas renderizar HTML diferente.

Para renderizar una vista parcial de adjunto faltante diferente, define un método de nivel de clase `to_missing_attachable_partial_path`:

```ruby
class User < ApplicationRecord
  def self.to_missing_attachable_partial_path
    "users/missing_attachable"
  end
end
```

Luego declara esa vista parcial.

```html+erb
<%# app/views/users/missing_attachable.html.erb %>
<span>Usuario eliminado</span>
```

Para integrarse con la renderización del elemento `<action-text-attachment>` de Action Text, una clase debe:

* incluir el módulo `ActionText::Attachable`
* implementar `#to_sgid(**options)` (disponible a través de la preocupación [`GlobalID::Identification`][global-id])
* (opcional) declarar `#to_attachable_partial_path`
* (opcional) declarar un método de nivel de clase `#to_missing_attachable_partial_path` para manejar registros faltantes

Por defecto, todos los descendientes de `ActiveRecord::Base` mezclan la preocupación [`GlobalID::Identification`][global-id], y por lo tanto son compatibles con `ActionText::Attachable`.


## Evitar consultas N+1

Si deseas precargar el modelo dependiente `ActionText::RichText`, suponiendo que tu campo de texto enriquecido se llama `content`, puedes usar el ámbito con nombre:

```ruby
Message.all.with_rich_text_content # Precargar el cuerpo sin adjuntos.
Message.all.with_rich_text_content_and_embeds # Precargar tanto el cuerpo como los adjuntos.
```

## API / Desarrollo Backend

1. Una API backend (por ejemplo, usando JSON) necesita un punto final separado para cargar archivos que cree un `ActiveStorage::Blob` y devuelva su `attachable_sgid`:

    ```json
    {
      "attachable_sgid": "BAh7CEkiCG…"
    }
    ```

2. Toma ese `attachable_sgid` y pide a tu frontend que lo inserte en el contenido de texto enriquecido usando una etiqueta `<action-text-attachment>`:

    ```html
    <action-text-attachment sgid="BAh7CEkiCG…"></action-text-attachment>
    ```

Esto se basa en Basecamp, así que si aún no encuentras lo que estás buscando, consulta este [Documento de Basecamp](https://github.com/basecamp/bc3-api/blob/master/sections/rich_text.md).
[`rich_text_area`]: https://api.rubyonrails.org/classes/ActionView/Helpers/FormHelper.html#method-i-rich_text_area
[global-id]: https://github.com/rails/globalid#usage
