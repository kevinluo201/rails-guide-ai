**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 4f7308fdab05dc13d399bde6a8ac302c
Resumen de Action Cable
========================

En esta guía, aprenderás cómo funciona Action Cable y cómo utilizar WebSockets para incorporar características en tiempo real en tu aplicación Rails.

Después de leer esta guía, sabrás:

* Qué es Action Cable y su integración backend y frontend.
* Cómo configurar Action Cable.
* Cómo configurar canales.
* Despliegue y configuración de la arquitectura para ejecutar Action Cable.

--------------------------------------------------------------------------------

¿Qué es Action Cable?
---------------------

Action Cable integra de manera transparente los [WebSockets](https://en.wikipedia.org/wiki/WebSocket) con el resto de tu aplicación Rails. Permite escribir características en tiempo real en Ruby de la misma forma y estilo que el resto de tu aplicación Rails, manteniendo un buen rendimiento y escalabilidad. Es una oferta de pila completa que proporciona tanto un framework de JavaScript en el lado del cliente como un framework de Ruby en el lado del servidor. Tienes acceso a todo tu modelo de dominio escrito con Active Record o tu ORM de elección.

Terminología
-----------

Action Cable utiliza WebSockets en lugar del protocolo de solicitud-respuesta HTTP. Tanto Action Cable como WebSockets introducen terminología menos familiar:

### Conexiones

*Conexiones* forman la base de la relación cliente-servidor. Un único servidor de Action Cable puede manejar múltiples instancias de conexión. Tiene una instancia de conexión por cada conexión WebSocket. Un único usuario puede tener múltiples WebSockets abiertos en tu aplicación si utiliza múltiples pestañas del navegador o dispositivos.

### Consumidores

El cliente de una conexión WebSocket se llama *consumidor*. En Action Cable, el consumidor es creado por el framework de JavaScript en el lado del cliente.

### Canales

Cada consumidor puede, a su vez, suscribirse a múltiples *canales*. Cada canal encapsula una unidad lógica de trabajo, similar a lo que hace un controlador en una configuración típica de MVC. Por ejemplo, podrías tener un `ChatChannel` y un `AppearancesChannel`, y un consumidor podría estar suscrito a uno o ambos de estos canales. Como mínimo, un consumidor debe estar suscrito a un canal.

### Suscriptores

Cuando el consumidor está suscrito a un canal, actúa como un *suscriptor*. La conexión entre el suscriptor y el canal se llama, sorpresa sorpresa, una suscripción. Un consumidor puede actuar como suscriptor de un canal dado cualquier número de veces. Por ejemplo, un consumidor podría suscribirse a múltiples salas de chat al mismo tiempo. (Y recuerda que un usuario físico puede tener múltiples consumidores, uno por pestaña/dispositivo abierto en tu conexión).

### Pub/Sub

[Pub/Sub](https://en.wikipedia.org/wiki/Publish%E2%80%93subscribe_pattern) o Publicar-Suscribir se refiere a un paradigma de cola de mensajes en el que los remitentes de información (publicadores) envían datos a una clase abstracta de destinatarios (suscriptores), sin especificar destinatarios individuales. Action Cable utiliza este enfoque para comunicarse entre el servidor y muchos clientes.

### Difusión

Una difusión es un enlace pub/sub donde todo lo transmitido por el emisor se envía directamente a los suscriptores del canal que están transmitiendo esa difusión nombrada. Cada canal puede estar transmitiendo cero o más difusiones.

## Componentes del lado del servidor

### Conexiones

Por cada WebSocket aceptado por el servidor, se instancia un objeto de conexión. Este objeto se convierte en el padre de todas las *suscripciones de canal* que se crean a partir de ese momento. La conexión en sí no se ocupa de ninguna lógica de aplicación específica más allá de la autenticación y autorización. El cliente de una conexión WebSocket se llama *consumidor* de la conexión. Un usuario individual creará una pareja consumidor-conexión por cada pestaña del navegador, ventana o dispositivo que tenga abierto.

Las conexiones son instancias de `ApplicationCable::Connection`, que extiende [`ActionCable::Connection::Base`][]. En `ApplicationCable::Connection`, autorizas la conexión entrante y procedes a establecerla si el usuario puede ser identificado.

#### Configuración de la conexión

```ruby
# app/channels/application_cable/connection.rb
module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_user

    def connect
      self.current_user = find_verified_user
    end

    private
      def find_verified_user
        if verified_user = User.find_by(id: cookies.encrypted[:user_id])
          verified_user
        else
          reject_unauthorized_connection
        end
      end
  end
end
```

Aquí, [`identified_by`][] designa un identificador de conexión que se puede utilizar para encontrar la conexión específica más adelante. Ten en cuenta que cualquier cosa marcada como un identificador creará automáticamente un delegado con el mismo nombre en todas las instancias de canal creadas a partir de la conexión.

Este ejemplo se basa en el hecho de que ya habrás manejado la autenticación del usuario en otro lugar de tu aplicación, y que una autenticación exitosa establece una cookie encriptada con el ID del usuario.

La cookie se envía automáticamente a la instancia de conexión cuando se intenta una nueva conexión, y la utilizas para establecer `current_user`. Al identificar la conexión con este mismo usuario actual, también te aseguras de que luego puedas recuperar todas las conexiones abiertas por un usuario dado (y potencialmente desconectarlas todas si el usuario se elimina o no está autorizado).
Si su enfoque de autenticación incluye el uso de una sesión, utiliza el almacenamiento de cookies para la sesión, su cookie de sesión se llama `_session` y la clave del ID de usuario es `user_id`, puede utilizar este enfoque:

```ruby
verified_user = User.find_by(id: cookies.encrypted['_session']['user_id'])
```


#### Manejo de excepciones

De forma predeterminada, las excepciones no controladas se capturan y se registran en el registro de Rails. Si desea interceptar globalmente estas excepciones y reportarlas a un servicio externo de seguimiento de errores, por ejemplo, puede hacerlo con [`rescue_from`][]:

```ruby
# app/channels/application_cable/connection.rb
module ApplicationCable
  class Connection < ActionCable::Connection::Base
    rescue_from StandardError, with: :report_error

    private
      def report_error(e)
        SomeExternalBugtrackingService.notify(e)
      end
  end
end
```


#### Callbacks de conexión

Hay callbacks `before_command`, `after_command` y `around_command` disponibles para invocar antes, después o alrededor de cada comando recibido por un cliente respectivamente.
El término "comando" aquí se refiere a cualquier interacción recibida por un cliente (suscribirse, cancelar la suscripción o realizar acciones):

```ruby
# app/channels/application_cable/connection.rb
module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :user

    around_command :set_current_account

    private
      def set_current_account(&block)
        # Ahora todos los canales pueden usar Current.account
        Current.set(account: user.account, &block)
      end
  end
end
```

### Canales

Un *canal* encapsula una unidad lógica de trabajo, similar a lo que hace un controlador en una configuración típica de MVC. De forma predeterminada, Rails crea una clase padre `ApplicationCable::Channel` (que extiende [`ActionCable::Channel::Base`][]) para encapsular la lógica compartida entre sus canales.

#### Configuración del canal padre

```ruby
# app/channels/application_cable/channel.rb
module ApplicationCable
  class Channel < ActionCable::Channel::Base
  end
end
```

Luego puede crear sus propias clases de canal. Por ejemplo, podría tener un `ChatChannel` y un `AppearanceChannel`:

```ruby
# app/channels/chat_channel.rb
class ChatChannel < ApplicationCable::Channel
end
```

```ruby
# app/channels/appearance_channel.rb
class AppearanceChannel < ApplicationCable::Channel
end
```


Un consumidor podría suscribirse a uno o ambos de estos canales.

#### Suscripciones

Los consumidores se suscriben a canales, actuando como *suscriptores*. Su conexión se
llama una *suscripción*. Los mensajes producidos se envían a estas suscripciones de canal
según un identificador enviado por el consumidor del canal.

```ruby
# app/channels/chat_channel.rb
class ChatChannel < ApplicationCable::Channel
  # Se llama cuando el consumidor se ha convertido con éxito en un suscriptor de este canal.
  def subscribed
  end
end
```

#### Manejo de excepciones

Al igual que con `ApplicationCable::Connection`, también puede usar [`rescue_from`][] en un
canal específico para manejar excepciones lanzadas:

```ruby
# app/channels/chat_channel.rb
class ChatChannel < ApplicationCable::Channel
  rescue_from 'MyError', with: :deliver_error_message

  private
    def deliver_error_message(e)
      broadcast_to(...)
    end
end
```

#### Callbacks de canal

`ApplicationCable::Channel` proporciona una serie de callbacks que se pueden utilizar para activar la lógica
durante el ciclo de vida de un canal. Los callbacks disponibles son:

- `before_subscribe`
- `after_subscribe` (también alias: `on_subscribe`)
- `before_unsubscribe`
- `after_unsubscribe` (también alias: `on_unsubscribe`)

NOTA: El callback `after_subscribe` se activa cada vez que se llama al método `subscribed`,
incluso si la suscripción fue rechazada con el método `reject`. Para activar `after_subscribe`
solo en suscripciones exitosas, use `after_subscribe :send_welcome_message, unless: :subscription_rejected?`

```ruby
# app/channels/chat_channel.rb
class ChatChannel < ApplicationCable::Channel
  after_subscribe :send_welcome_message, unless: :subscription_rejected?
  after_subscribe :track_subscription

  private
    def send_welcome_message
      broadcast_to(...)
    end

    def track_subscription
      # ...
    end
end
```

## Componentes del lado del cliente

### Conexiones

Los consumidores requieren una instancia de la conexión en su lado. Esto se puede
establecer utilizando el siguiente JavaScript, que se genera de forma predeterminada en Rails:

#### Conectar consumidor

```js
// app/javascript/channels/consumer.js
// Action Cable proporciona el marco para trabajar con WebSockets en Rails.
// Puede generar nuevos canales donde se encuentran las características de WebSocket utilizando el comando `bin/rails generate channel`.

import { createConsumer } from "@rails/actioncable"

export default createConsumer()
```

Esto preparará un consumidor que se conectará a `/cable` en su servidor de forma predeterminada.
La conexión no se establecerá hasta que también haya especificado al menos una suscripción
que le interese tener.

El consumidor opcionalmente puede tomar un argumento que especifica la URL a la que conectarse. Esto
puede ser una cadena o una función que devuelve una cadena que se llamará cuando se abra el
WebSocket.

```js
// Especificar una URL diferente a la que conectarse
createConsumer('wss://example.com/cable')
// O cuando se usan websockets sobre HTTP
createConsumer('https://ws.example.com/cable')

// Usar una función para generar dinámicamente la URL
createConsumer(getWebSocketURL)

function getWebSocketURL() {
  const token = localStorage.get('auth-token')
  return `wss://example.com/cable?token=${token}`
}
```

#### Suscriptor

Un consumidor se convierte en un suscriptor creando una suscripción a un canal dado:

```js
// app/javascript/channels/chat_channel.js
import consumer from "./consumer"

consumer.subscriptions.create({ channel: "ChatChannel", room: "Best Room" })

// app/javascript/channels/appearance_channel.js
import consumer from "./consumer"

consumer.subscriptions.create({ channel: "AppearanceChannel" })
```

Si bien esto crea la suscripción, la funcionalidad necesaria para responder a
los datos recibidos se describirá más adelante.
Un consumidor puede actuar como suscriptor de un canal determinado cualquier número de veces. Por ejemplo, un consumidor podría suscribirse a múltiples salas de chat al mismo tiempo:

```js
// app/javascript/channels/chat_channel.js
import consumer from "./consumer"

consumer.subscriptions.create({ channel: "ChatChannel", room: "1st Room" })
consumer.subscriptions.create({ channel: "ChatChannel", room: "2nd Room" })
```

## Interacciones Cliente-Servidor

### Streams

*Streams* proporcionan el mecanismo mediante el cual los canales enrutan contenido publicado (transmisiones) a sus suscriptores. Por ejemplo, el siguiente código utiliza [`stream_from`][] para suscribirse a la transmisión llamada `chat_Best Room` cuando el valor del parámetro `:room` es `"Best Room"`:

```ruby
# app/channels/chat_channel.rb
class ChatChannel < ApplicationCable::Channel
  def subscribed
    stream_from "chat_#{params[:room]}"
  end
end
```

Luego, en otra parte de su aplicación de Rails, puede transmitir a esa sala llamando a [`broadcast`][]:

```ruby
ActionCable.server.broadcast("chat_Best Room", { body: "This Room is Best Room." })
```

Si tiene una transmisión relacionada con un modelo, entonces el nombre de la transmisión se puede generar a partir del canal y el modelo. Por ejemplo, el siguiente código utiliza [`stream_for`][] para suscribirse a una transmisión como `posts:Z2lkOi8vVGVzdEFwcC9Qb3N0LzE`, donde `Z2lkOi8vVGVzdEFwcC9Qb3N0LzE` es el GlobalID del modelo Post.

```ruby
class PostsChannel < ApplicationCable::Channel
  def subscribed
    post = Post.find(params[:id])
    stream_for post
  end
end
```

Luego puede transmitir a este canal llamando a [`broadcast_to`][]:

```ruby
PostsChannel.broadcast_to(@post, @comment)
```


### Transmisiones

Una *transmisión* es un enlace pub/sub donde cualquier cosa transmitida por un editor se enruta directamente a los suscriptores del canal que están transmitiendo esa transmisión con nombre. Cada canal puede transmitir cero o más transmisiones.

Las transmisiones son puramente una cola en línea y dependiente del tiempo. Si un consumidor no está transmitiendo (suscripto a un canal determinado), no recibirá la transmisión si se conecta más tarde.

### Suscripciones

Cuando un consumidor se suscribe a un canal, actúa como un suscriptor. Esta conexión se llama suscripción. Los mensajes entrantes se enrutan a estas suscripciones de canal en función de un identificador enviado por el consumidor de cable.

```js
// app/javascript/channels/chat_channel.js
import consumer from "./consumer"

consumer.subscriptions.create({ channel: "ChatChannel", room: "Best Room" }, {
  received(data) {
    this.appendLine(data)
  },

  appendLine(data) {
    const html = this.createLine(data)
    const element = document.querySelector("[data-chat-room='Best Room']")
    element.insertAdjacentHTML("beforeend", html)
  },

  createLine(data) {
    return `
      <article class="chat-line">
        <span class="speaker">${data["sent_by"]}</span>
        <span class="body">${data["body"]}</span>
      </article>
    `
  }
})
```

### Pasar parámetros a los canales

Puede pasar parámetros desde el lado del cliente al lado del servidor al crear una suscripción. Por ejemplo:

```ruby
# app/channels/chat_channel.rb
class ChatChannel < ApplicationCable::Channel
  def subscribed
    stream_from "chat_#{params[:room]}"
  end
end
```

Un objeto pasado como primer argumento a `subscriptions.create` se convierte en el hash de parámetros en el canal de cable. La palabra clave `channel` es requerida:

```js
// app/javascript/channels/chat_channel.js
import consumer from "./consumer"

consumer.subscriptions.create({ channel: "ChatChannel", room: "Best Room" }, {
  received(data) {
    this.appendLine(data)
  },

  appendLine(data) {
    const html = this.createLine(data)
    const element = document.querySelector("[data-chat-room='Best Room']")
    element.insertAdjacentHTML("beforeend", html)
  },

  createLine(data) {
    return `
      <article class="chat-line">
        <span class="speaker">${data["sent_by"]}</span>
        <span class="body">${data["body"]}</span>
      </article>
    `
  }
})
```

```ruby
# En algún lugar de su aplicación esto se llama, tal vez
# desde un NewCommentJob.
ActionCable.server.broadcast(
  "chat_#{room}",
  {
    sent_by: 'Paul',
    body: 'This is a cool chat app.'
  }
)
```

### Rebroadcast de un mensaje

Un caso de uso común es *rebroadcastear* un mensaje enviado por un cliente a cualquier otro cliente conectado.

```ruby
# app/channels/chat_channel.rb
class ChatChannel < ApplicationCable::Channel
  def subscribed
    stream_from "chat_#{params[:room]}"
  end

  def receive(data)
    ActionCable.server.broadcast("chat_#{params[:room]}", data)
  end
end
```

```js
// app/javascript/channels/chat_channel.js
import consumer from "./consumer"

const chatChannel = consumer.subscriptions.create({ channel: "ChatChannel", room: "Best Room" }, {
  received(data) {
    // data => { sent_by: "Paul", body: "This is a cool chat app." }
  }
}

chatChannel.send({ sent_by: "Paul", body: "This is a cool chat app." })
```

El rebroadcast será recibido por todos los clientes conectados, _incluyendo_ el cliente que envió el mensaje. Tenga en cuenta que los parámetros son los mismos que cuando se suscribió al canal.

## Ejemplos de pila completa

Los siguientes pasos de configuración son comunes a ambos ejemplos:

  1. [Configurar su conexión](#connection-setup).
  2. [Configurar su canal principal](#parent-channel-setup).
  3. [Conectar su consumidor](#connect-consumer).

### Ejemplo 1: Apariciones de usuarios

Aquí hay un ejemplo simple de un canal que rastrea si un usuario está en línea o no y en qué página se encuentra. (Esto es útil para crear características de presencia como mostrar un punto verde junto a un nombre de usuario si está en línea).

Cree el canal de apariciones del lado del servidor:

```ruby
# app/channels/appearance_channel.rb
class AppearanceChannel < ApplicationCable::Channel
  def subscribed
    current_user.appear
  end

  def unsubscribed
    current_user.disappear
  end

  def appear(data)
    current_user.appear(on: data['appearing_on'])
  end

  def away
    current_user.away
  end
end
```
Cuando se inicia una suscripción, se activa el callback `subscribed` y aprovechamos esa oportunidad para decir "el usuario actual ha aparecido". Esa API de aparecer/desaparecer podría estar respaldada por Redis, una base de datos o cualquier otra cosa.

Crear la suscripción del canal de apariencia del lado del cliente:

```js
// app/javascript/channels/appearance_channel.js
import consumer from "./consumer"

consumer.subscriptions.create("AppearanceChannel", {
  // Llamado una vez cuando se crea la suscripción.
  initialized() {
    this.update = this.update.bind(this)
  },

  // Llamado cuando la suscripción está lista para usar en el servidor.
  connected() {
    this.install()
    this.update()
  },

  // Llamado cuando la conexión WebSocket se cierra.
  disconnected() {
    this.uninstall()
  },

  // Llamado cuando la suscripción es rechazada por el servidor.
  rejected() {
    this.uninstall()
  },

  update() {
    this.documentIsActive ? this.appear() : this.away()
  },

  appear() {
    // Llama a `AppearanceChannel#appear(data)` en el servidor.
    this.perform("appear", { appearing_on: this.appearingOn })
  },

  away() {
    // Llama a `AppearanceChannel#away` en el servidor.
    this.perform("away")
  },

  install() {
    window.addEventListener("focus", this.update)
    window.addEventListener("blur", this.update)
    document.addEventListener("turbo:load", this.update)
    document.addEventListener("visibilitychange", this.update)
  },

  uninstall() {
    window.removeEventListener("focus", this.update)
    window.removeEventListener("blur", this.update)
    document.removeEventListener("turbo:load", this.update)
    document.removeEventListener("visibilitychange", this.update)
  },

  get documentIsActive() {
    return document.visibilityState === "visible" && document.hasFocus()
  },

  get appearingOn() {
    const element = document.querySelector("[data-appearing-on]")
    return element ? element.getAttribute("data-appearing-on") : null
  }
})
```

#### Interacción Cliente-Servidor

1. **Cliente** se conecta al **Servidor** a través de `createConsumer()`. (`consumer.js`). El
  **Servidor** identifica esta conexión por `current_user`.

2. **Cliente** se suscribe al canal de apariencia a través de
  `consumer.subscriptions.create({ channel: "AppearanceChannel" })`. (`appearance_channel.js`)

3. **Servidor** reconoce que se ha iniciado una nueva suscripción para el
  canal de apariencia y ejecuta su callback `subscribed`, llamando al método `appear`
  en `current_user`. (`appearance_channel.rb`)

4. **Cliente** reconoce que se ha establecido una suscripción y llama a
  `connected` (`appearance_channel.js`), que a su vez llama a `install` y `appear`.
  `appear` llama a `AppearanceChannel#appear(data)` en el servidor, y suministra un
  hash de datos de `{ appearing_on: this.appearingOn }`. Esto es
  posible porque la instancia del canal del lado del servidor expone automáticamente todos
  los métodos públicos declarados en la clase (excepto los callbacks), de modo que estos pueden ser
  alcanzados como llamadas de procedimiento remoto a través del método `perform` de una suscripción.

5. **Servidor** recibe la solicitud de la acción `appear` en el canal de apariencia para la conexión identificada por `current_user`
  (`appearance_channel.rb`). **Servidor** recupera los datos con la
  clave `:appearing_on` del hash de datos y lo establece como el valor para la clave `:on`
  que se pasa a `current_user.appear`.

### Ejemplo 2: Recibir nuevas notificaciones web

El ejemplo de apariencia se trataba de exponer la funcionalidad del servidor a
invocación del lado del cliente a través de la conexión WebSocket. Pero lo genial
de los WebSockets es que es una calle de doble sentido. Así que ahora, vamos a mostrar un ejemplo
donde el servidor invoca una acción en el cliente.

Este es un canal de notificaciones web que te permite activar notificaciones web del lado del cliente
cuando se transmiten a los flujos relevantes:

Crear el canal de notificaciones web del lado del servidor:

```ruby
# app/channels/web_notifications_channel.rb
class WebNotificationsChannel < ApplicationCable::Channel
  def subscribed
    stream_for current_user
  end
end
```

Crear la suscripción del canal de notificaciones web del lado del cliente:

```js
// app/javascript/channels/web_notifications_channel.js
// Lado del cliente que asume que ya has solicitado
// el permiso para enviar notificaciones web.
import consumer from "./consumer"

consumer.subscriptions.create("WebNotificationsChannel", {
  received(data) {
    new Notification(data["title"], { body: data["body"] })
  }
})
```

Transmitir contenido a una instancia del canal de notificaciones web desde otro lugar de tu
aplicación:

```ruby
# En algún lugar de tu aplicación esto se llama, tal vez desde un NewCommentJob
WebNotificationsChannel.broadcast_to(
  current_user,
  title: '¡Cosas nuevas!',
  body: 'Todas las noticias dignas de imprimir'
)
```

La llamada `WebNotificationsChannel.broadcast_to` coloca un mensaje en la cola de pubsub del adaptador de suscripción actual bajo un nombre de transmisión separado para cada
usuario. Para un usuario con un ID de 1, el nombre de transmisión sería
`web_notifications:1`.

Se ha instruido al canal para que transmita todo lo que llegue a
`web_notifications:1` directamente al cliente invocando el callback `received`. Los datos pasados como argumento son el hash enviado como segundo parámetro
a la llamada de transmisión del lado del servidor, codificado en JSON para el viaje a través del cable
y desempaquetado para el argumento de datos que llega como `received`.

### Ejemplos más completos

Consulta el repositorio [rails/actioncable-examples](https://github.com/rails/actioncable-examples)
para ver un ejemplo completo de cómo configurar Action Cable en una aplicación Rails y agregar canales.

## Configuración

Action Cable tiene dos configuraciones requeridas: un adaptador de suscripción y los orígenes de solicitud permitidos.

### Adaptador de suscripción

De forma predeterminada, Action Cable busca un archivo de configuración en `config/cable.yml`.
El archivo debe especificar un adaptador para cada entorno de Rails. Consulta la sección
[Dependencias](#dependencias) para obtener información adicional sobre los adaptadores.

```yaml
development:
  adapter: async

test:
  adapter: test

production:
  adapter: redis
  url: redis://10.10.3.153:6381
  channel_prefix: appname_production
```
#### Configuración del adaptador

A continuación se muestra una lista de los adaptadores de suscripción disponibles para los usuarios finales.

##### Adaptador Async

El adaptador async está destinado para desarrollo/pruebas y no debe utilizarse en producción.

##### Adaptador Redis

El adaptador Redis requiere que los usuarios proporcionen una URL que apunte al servidor Redis.
Además, se puede proporcionar un `channel_prefix` para evitar colisiones de nombres de canal
cuando se utiliza el mismo servidor Redis para varias aplicaciones. Consulte la [documentación de Redis Pub/Sub](https://redis.io/docs/manual/pubsub/#database--scoping) para obtener más detalles.

El adaptador Redis también admite conexiones SSL/TLS. Los parámetros SSL/TLS requeridos se pueden pasar en la clave `ssl_params` en el archivo de configuración YAML.

```
production:
  adapter: redis
  url: rediss://10.10.3.153:tls_port
  channel_prefix: appname_production
  ssl_params: {
    ca_file: "/path/to/ca.crt"
  }
```

Las opciones dadas a `ssl_params` se pasan directamente al método `OpenSSL::SSL::SSLContext#set_params` y pueden ser cualquier atributo válido del contexto SSL.
Consulte la [documentación de OpenSSL::SSL::SSLContext](https://docs.ruby-lang.org/en/master/OpenSSL/SSL/SSLContext.html) para obtener otros atributos disponibles.

Si está utilizando certificados autofirmados para el adaptador Redis detrás de un firewall y opta por omitir la verificación del certificado, entonces el `verify_mode` SSL debe establecerse como `OpenSSL::SSL::VERIFY_NONE`.

ADVERTENCIA: No se recomienda utilizar `VERIFY_NONE` en producción a menos que comprenda absolutamente las implicaciones de seguridad. Para establecer esta opción para el adaptador Redis, la configuración debe ser `ssl_params: { verify_mode: <%= OpenSSL::SSL::VERIFY_NONE %> }`.

##### Adaptador PostgreSQL

El adaptador PostgreSQL utiliza el grupo de conexiones de Active Record y, por lo tanto, la
configuración de la base de datos en `config/database.yml` de la aplicación para su conexión.
Esto puede cambiar en el futuro. [#27214](https://github.com/rails/rails/issues/27214)

### Orígenes de solicitud permitidos

Action Cable solo aceptará solicitudes de los orígenes especificados, que se
pasan a la configuración del servidor como un array. Los orígenes pueden ser instancias de
cadenas o expresiones regulares, contra las cuales se realizará una comprobación de coincidencia.

```ruby
config.action_cable.allowed_request_origins = ['https://rubyonrails.com', %r{http://ruby.*}]
```

Para deshabilitar y permitir solicitudes desde cualquier origen:

```ruby
config.action_cable.disable_request_forgery_protection = true
```

De forma predeterminada, Action Cable permite todas las solicitudes desde localhost:3000 cuando se ejecuta
en el entorno de desarrollo.

### Configuración del consumidor

Para configurar la URL, agregue una llamada a [`action_cable_meta_tag`][] en su diseño HTML
HEAD. Esto utiliza una URL o ruta que generalmente se establece a través de [`config.action_cable.url`][] en los
archivos de configuración del entorno.


### Configuración del grupo de trabajadores

El grupo de trabajadores se utiliza para ejecutar devoluciones de llamada de conexión y acciones de canal de forma
aislada del hilo principal del servidor. Action Cable permite que la aplicación
configure la cantidad de hilos procesados simultáneamente en el grupo de trabajadores.

```ruby
config.action_cable.worker_pool_size = 4
```

Además, tenga en cuenta que su servidor debe proporcionar al menos la misma cantidad de conexiones de base de datos
que la cantidad de trabajadores que tiene. El tamaño predeterminado del grupo de trabajadores se establece en 4, por lo que
eso significa que debe tener al menos 4 conexiones de base de datos disponibles.
Puede cambiar eso en `config/database.yml` a través del atributo `pool`.

### Registro del lado del cliente

El registro del lado del cliente está desactivado de forma predeterminada. Puede habilitarlo configurando `ActionCable.logger.enabled` como verdadero.

```ruby
import * as ActionCable from '@rails/actioncable'

ActionCable.logger.enabled = true
```

### Otras configuraciones

La otra opción común para configurar son las etiquetas de registro aplicadas al
registro de conexión por conexión. Aquí hay un ejemplo que utiliza
el ID de cuenta de usuario si está disponible, de lo contrario "no-account" mientras etiqueta:

```ruby
config.action_cable.log_tags = [
  -> request { request.env['user_account_id'] || "no-account" },
  :action_cable,
  -> request { request.uuid }
]
```

Para obtener una lista completa de todas las opciones de configuración, consulte la
clase `ActionCable::Server::Configuration`.

## Ejecución de servidores de Cable independientes

Action Cable puede ejecutarse como parte de su aplicación Rails o como
un servidor independiente. En desarrollo, ejecutarlo como parte de su aplicación Rails
generalmente está bien, pero en producción debe ejecutarlo como un servidor independiente.

### En la aplicación

Action Cable puede ejecutarse junto con su aplicación Rails. Por ejemplo, para
escuchar solicitudes de WebSocket en `/websocket`, especifique esa ruta en
[`config.action_cable.mount_path`][]:

```ruby
# config/application.rb
class Application < Rails::Application
  config.action_cable.mount_path = '/websocket'
end
```

Puede usar `ActionCable.createConsumer()` para conectarse al servidor de cable
si se invoca [`action_cable_meta_tag`][] en el diseño. De lo contrario, se especifica una ruta como
primer argumento para `createConsumer` (por ejemplo, `ActionCable.createConsumer("/websocket")`).

Por cada instancia de su servidor que cree y por cada trabajador que su servidor
genere, también tendrá una nueva instancia de Action Cable, pero el adaptador Redis o
PostgreSQL mantiene los mensajes sincronizados entre las conexiones.


### Independiente

Los servidores de cable se pueden separar de su servidor de aplicaciones normal. Es
aún una aplicación Rack, pero es su propia aplicación Rack. La configuración básica recomendada
es la siguiente:
```ruby
# cable/config.ru
require_relative "../config/environment"
Rails.application.eager_load!

run ActionCable.server
```

Luego, para iniciar el servidor:

```
bundle exec puma -p 28080 cable/config.ru
```

Esto inicia un servidor de cable en el puerto 28080. Para indicarle a Rails que use este
servidor, actualiza tu configuración:

```ruby
# config/environments/development.rb
Rails.application.configure do
  config.action_cable.mount_path = nil
  config.action_cable.url = "ws://localhost:28080" # usar wss:// en producción
end
```

Finalmente, asegúrate de haber [configurado correctamente el consumidor](#configuración-del-consumidor).

### Notas

El servidor WebSocket no tiene acceso a la sesión, pero sí tiene
acceso a las cookies. Esto se puede utilizar cuando se necesita manejar
la autenticación. Puedes ver una forma de hacerlo con Devise en este [artículo](https://greg.molnar.io/blog/actioncable-devise-authentication/).

## Dependencias

Action Cable proporciona una interfaz de adaptador de suscripción para procesar su
interno de pubsub. Por defecto, se incluyen adaptadores asíncronos, en línea, PostgreSQL y Redis.
El adaptador predeterminado
en nuevas aplicaciones de Rails es el adaptador asíncrono (`async`).

El lado de Ruby se basa en [websocket-driver](https://github.com/faye/websocket-driver-ruby),
[nio4r](https://github.com/celluloid/nio4r) y [concurrent-ruby](https://github.com/ruby-concurrency/concurrent-ruby).

## Implementación

Action Cable funciona con una combinación de WebSockets y hilos. Tanto la
infraestructura del framework como el trabajo de canal especificado por el usuario se manejan internamente
utilizando el soporte nativo de hilos de Ruby. Esto significa que puedes usar todos tus modelos de Rails existentes sin problemas, siempre y cuando no hayas cometido ningún pecado de seguridad de hilos.

El servidor de Action Cable implementa la API de secuestro de socket de Rack,
lo que permite el uso de un patrón multihilo para gestionar las conexiones
internamente, independientemente de si el servidor de la aplicación es multihilo o no.

En consecuencia, Action Cable funciona con servidores populares como Unicorn, Puma y
Passenger.

## Pruebas

Puedes encontrar instrucciones detalladas sobre cómo probar la funcionalidad de Action Cable en la
[guía de pruebas](testing.html#testing-action-cable).
[`ActionCable::Connection::Base`]: https://api.rubyonrails.org/classes/ActionCable/Connection/Base.html
[`identified_by`]: https://api.rubyonrails.org/classes/ActionCable/Connection/Identification/ClassMethods.html#method-i-identified_by
[`rescue_from`]: https://api.rubyonrails.org/classes/ActiveSupport/Rescuable/ClassMethods.html#method-i-rescue_from
[`ActionCable::Channel::Base`]: https://api.rubyonrails.org/classes/ActionCable/Channel/Base.html
[`broadcast`]: https://api.rubyonrails.org/classes/ActionCable/Server/Broadcasting.html#method-i-broadcast
[`broadcast_to`]: https://api.rubyonrails.org/classes/ActionCable/Channel/Broadcasting/ClassMethods.html#method-i-broadcast_to
[`stream_for`]: https://api.rubyonrails.org/classes/ActionCable/Channel/Streams.html#method-i-stream_for
[`stream_from`]: https://api.rubyonrails.org/classes/ActionCable/Channel/Streams.html#method-i-stream_from
[`config.action_cable.url`]: configuring.html#config-action-cable-url
[`action_cable_meta_tag`]: https://api.rubyonrails.org/classes/ActionCable/Helpers/ActionCableHelper.html#method-i-action_cable_meta_tag
[`config.action_cable.mount_path`]: configuring.html#config-action-cable-mount-path
[`action_cable_meta_tag`]: https://api.rubyonrails.org/classes/ActionCable/Helpers/ActionCableHelper.html#method-i-action_cable_meta_tag
