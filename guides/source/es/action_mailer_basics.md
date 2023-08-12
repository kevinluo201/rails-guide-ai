**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 390d20a8bee6232c0ffa7faeb0e9d8e8
Fundamentos de Action Mailer
====================

Esta guía te proporciona todo lo que necesitas para comenzar a enviar correos electrónicos desde tu aplicación, así como muchos aspectos internos de Action Mailer. También cubre cómo probar tus mailers.

Después de leer esta guía, sabrás:

* Cómo enviar correos electrónicos dentro de una aplicación Rails.
* Cómo generar y editar una clase de Action Mailer y una vista de mailer.
* Cómo configurar Action Mailer para tu entorno.
* Cómo probar tus clases de Action Mailer.

--------------------------------------------------------------------------------

¿Qué es Action Mailer?
----------------------

Action Mailer te permite enviar correos electrónicos desde tu aplicación utilizando clases de mailer y vistas.

### Los Mailers son similares a los Controladores

Heredan de [`ActionMailer::Base`][] y se encuentran en `app/mailers`. Los mailers también funcionan de manera muy similar a los controladores. Algunos ejemplos de similitudes se enumeran a continuación. Los mailers tienen:

* Acciones y también vistas asociadas que aparecen en `app/views`.
* Variables de instancia que son accesibles en las vistas.
* La capacidad de utilizar layouts y partials.
* La capacidad de acceder a un hash de parámetros.

Enviar Correos Electrónicos
--------------

Esta sección proporcionará una guía paso a paso para crear un mailer y sus vistas.

### Recorrido para Generar un Mailer

#### Crear el Mailer

```bash
$ bin/rails generate mailer User
create  app/mailers/user_mailer.rb
create  app/mailers/application_mailer.rb
invoke  erb
create    app/views/user_mailer
create    app/views/layouts/mailer.text.erb
create    app/views/layouts/mailer.html.erb
invoke  test_unit
create    test/mailers/user_mailer_test.rb
create    test/mailers/previews/user_mailer_preview.rb
```

```ruby
# app/mailers/application_mailer.rb
class ApplicationMailer < ActionMailer::Base
  default from: "from@example.com"
  layout 'mailer'
end
```

```ruby
# app/mailers/user_mailer.rb
class UserMailer < ApplicationMailer
end
```

Como puedes ver, puedes generar mailers de la misma manera que usas otros generadores con Rails.

Si no quisieras usar un generador, podrías crear tu propio archivo dentro de `app/mailers`, solo asegúrate de que herede de `ActionMailer::Base`:

```ruby
class MyMailer < ActionMailer::Base
end
```

#### Editar el Mailer

Los mailers tienen métodos llamados "acciones" y utilizan vistas para estructurar su contenido. Mientras que un controlador genera contenido como HTML para enviar de vuelta al cliente, un mailer crea un mensaje para ser entregado por correo electrónico.

`app/mailers/user_mailer.rb` contiene un mailer vacío:

```ruby
class UserMailer < ApplicationMailer
end
```

Agreguemos un método llamado `welcome_email`, que enviará un correo electrónico a la dirección de correo electrónico registrada del usuario:

```ruby
class UserMailer < ApplicationMailer
  default from: 'notifications@example.com'

  def welcome_email
    @user = params[:user]
    @url  = 'http://example.com/login'
    mail(to: @user.email, subject: 'Bienvenido a Mi Sitio Increíble')
  end
end
```

Aquí hay una explicación rápida de los elementos presentados en el método anterior. Para obtener una lista completa de todas las opciones disponibles, por favor consulta la sección Lista completa de atributos configurables por el usuario de Action Mailer.

* El método [`default`][] establece valores predeterminados para todos los correos electrónicos enviados desde este mailer. En este caso, lo usamos para establecer el valor del encabezado `:from` para todos los mensajes en esta clase. Esto se puede anular para cada correo electrónico.
* El método [`mail`][] crea el mensaje de correo electrónico real. Lo usamos para especificar los valores de los encabezados como `:to` y `:subject` por correo electrónico.

#### Crear una Vista de Mailer

Crea un archivo llamado `welcome_email.html.erb` en `app/views/user_mailer/`. Esta será la plantilla utilizada para el correo electrónico, formateada en HTML:

```html+erb
<!DOCTYPE html>
<html>
  <head>
    <meta content='text/html; charset=UTF-8' http-equiv='Content-Type' />
  </head>
  <body>
    <h1>Bienvenido a example.com, <%= @user.name %></h1>
    <p>
      Te has registrado correctamente en example.com,
      tu nombre de usuario es: <%= @user.login %>.<br>
    </p>
    <p>
      Para iniciar sesión en el sitio, simplemente sigue este enlace: <%= @url %>.
    </p>
    <p>¡Gracias por unirte y que tengas un gran día!</p>
  </body>
</html>
```

También hagamos una parte de texto para este correo electrónico. No todos los clientes prefieren los correos electrónicos en HTML, por lo que enviar ambos es una buena práctica. Para hacer esto, crea un archivo llamado `welcome_email.text.erb` en `app/views/user_mailer/`:

```erb
Bienvenido a example.com, <%= @user.name %>
===============================================

Te has registrado correctamente en example.com,
tu nombre de usuario es: <%= @user.login %>.

Para iniciar sesión en el sitio, simplemente sigue este enlace: <%= @url %>.

¡Gracias por unirte y que tengas un gran día!
```
Cuando llamas al método `mail` ahora, Action Mailer detectará las dos plantillas (texto y HTML) y generará automáticamente un correo electrónico `multipart/alternative`.

#### Llamando al Mailer

Los Mailers son simplemente otra forma de renderizar una vista. En lugar de renderizar una vista y enviarla a través del protocolo HTTP, se envían a través de los protocolos de correo electrónico. Debido a esto, tiene sentido que el controlador le indique al Mailer que envíe un correo electrónico cuando se crea un usuario correctamente.

Configurar esto es simple.

Primero, creemos un andamio (`scaffold`) para `User`:

```bash
$ bin/rails generate scaffold user name email login
$ bin/rails db:migrate
```

Ahora que tenemos un modelo de usuario con el que jugar, editaremos el archivo `app/controllers/users_controller.rb`, haremos que instruya al `UserMailer` para que envíe un correo electrónico al usuario recién creado editando la acción `create` e insertando una llamada a `UserMailer.with(user: @user).welcome_email` justo después de que el usuario se guarde correctamente.

Encolaremos el correo electrónico para que se envíe utilizando [`deliver_later`][], que está respaldado por Active Job. De esta manera, la acción del controlador puede continuar sin esperar a que se complete el envío.

```ruby
class UsersController < ApplicationController
  # ...

  # POST /users or /users.json
  def create
    @user = User.new(user_params)

    respond_to do |format|
      if @user.save
        # Indicarle a UserMailer que envíe un correo electrónico de bienvenida después de guardar
        UserMailer.with(user: @user).welcome_email.deliver_later

        format.html { redirect_to(@user, notice: 'El usuario se creó correctamente.') }
        format.json { render json: @user, status: :created, location: @user }
      else
        format.html { render action: 'new' }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # ...
end
```

NOTA: El comportamiento predeterminado de Active Job es ejecutar trabajos a través del adaptador `:async`. Por lo tanto, puedes usar `deliver_later` para enviar correos electrónicos de forma asíncrona. El adaptador predeterminado de Active Job ejecuta trabajos con un grupo de subprocesos en el proceso actual. Es adecuado para entornos de desarrollo/prueba, ya que no requiere ninguna infraestructura externa, pero no es adecuado para producción, ya que descarta trabajos pendientes al reiniciar. Si necesitas un backend persistente, deberás usar un adaptador de Active Job que tenga un backend persistente (Sidekiq, Resque, etc).

Si deseas enviar correos electrónicos de inmediato (desde un cronjob, por ejemplo), simplemente llama a [`deliver_now`][]:

```ruby
class SendWeeklySummary
  def run
    User.find_each do |user|
      UserMailer.with(user: user).weekly_summary.deliver_now
    end
  end
end
```

Cualquier par clave-valor pasado a [`with`][] se convierte en los `params` para la acción del mailer. Por lo tanto, `with(user: @user, account: @user.account)` hace que `params[:user]` y `params[:account]` estén disponibles en la acción del mailer, al igual que los controladores tienen params.

El método `welcome_email` devuelve un objeto [`ActionMailer::MessageDelivery`][] que luego se puede enviar inmediatamente (`deliver_now`) o en un momento posterior (`deliver_later`). El objeto `ActionMailer::MessageDelivery` es un contenedor alrededor de un [`Mail::Message`][]. Si deseas inspeccionar, modificar o hacer cualquier otra cosa con el objeto `Mail::Message`, puedes acceder a él con el método [`message`][] en el objeto `ActionMailer::MessageDelivery`.


### Codificación automática de valores de encabezado

Action Mailer maneja la codificación automática de caracteres multibyte dentro de los encabezados y cuerpos.

Para ejemplos más complejos, como definir conjuntos de caracteres alternativos o texto de auto-codificación primero, consulta la biblioteca [Mail](https://github.com/mikel/mail).

### Lista completa de métodos de Action Mailer

Solo hay tres métodos que necesitas para enviar prácticamente cualquier mensaje de correo electrónico:

* [`headers`][] - Especifica cualquier encabezado que desees en el correo electrónico. Puedes pasar un hash de nombres de campo de encabezado y pares de valores, o puedes llamar a `headers[:nombre_campo] = 'valor'`.
* [`attachments`][] - Te permite agregar archivos adjuntos a tu correo electrónico. Por ejemplo, `attachments['nombre-archivo.jpg'] = File.read('nombre-archivo.jpg')`.
* [`mail`][] - Crea el correo electrónico en sí. Puedes pasar encabezados como un hash al método `mail` como parámetro. `mail` creará un correo electrónico, ya sea de texto plano o multipartes, según las plantillas de correo electrónico que hayas definido.
#### Agregar adjuntos

Action Mailer facilita mucho la adición de adjuntos.

* Pase el nombre de archivo y el contenido a Action Mailer y la gema [Mail](https://github.com/mikel/mail) adivinará automáticamente el `mime_type`, establecerá la `encoding` y creará el adjunto.

    ```ruby
    attachments['filename.jpg'] = File.read('/path/to/filename.jpg')
    ```

  Cuando se active el método `mail`, se enviará un correo electrónico multipartes con un adjunto, correctamente anidado con el nivel superior siendo `multipart/mixed` y la primera parte siendo un `multipart/alternative` que contiene los mensajes de correo electrónico en texto plano y HTML.

NOTA: Mail automáticamente codificará en Base64 un adjunto. Si desea algo diferente, codifique su contenido y pase el contenido codificado y la codificación en un `Hash` al método `attachments`.

* Pase el nombre de archivo y especifique encabezados y contenido y Action Mailer y Mail utilizarán la configuración que pase.

    ```ruby
    encoded_content = SpecialEncode(File.read('/path/to/filename.jpg'))
    attachments['filename.jpg'] = {
      mime_type: 'application/gzip',
      encoding: 'SpecialEncoding',
      content: encoded_content
    }
    ```

NOTA: Si especifica una codificación, Mail asumirá que su contenido ya está codificado y no intentará codificarlo en Base64.

#### Crear adjuntos en línea

Action Mailer 3.0 hace que los adjuntos en línea, que requerían mucho trabajo en las versiones anteriores a 3.0, sean mucho más simples y triviales como deberían ser.

* Primero, para indicarle a Mail que convierta un adjunto en un adjunto en línea, simplemente llame a `#inline` en el método `attachments` dentro de su Mailer:

    ```ruby
    def welcome
      attachments.inline['image.jpg'] = File.read('/path/to/image.jpg')
    end
    ```

* Luego, en su vista, simplemente puede hacer referencia a `attachments` como un hash y especificar qué adjunto desea mostrar, llamando a `url` en él y luego pasando el resultado al método `image_tag`:

    ```html+erb
    <p>Hola, esta es nuestra imagen</p>

    <%= image_tag attachments['image.jpg'].url %>
    ```

* Como esta es una llamada estándar a `image_tag`, puede pasar un hash de opciones después de la URL del adjunto, al igual que lo haría para cualquier otra imagen:

    ```html+erb
    <p>Hola, esta es nuestra imagen</p>

    <%= image_tag attachments['image.jpg'].url, alt: 'Mi foto', class: 'fotos' %>
    ```

#### Enviar correo electrónico a múltiples destinatarios

Es posible enviar correo electrónico a uno o más destinatarios en un solo correo electrónico (por ejemplo, informar a todos los administradores de un nuevo registro) estableciendo la lista de correos electrónicos en la clave `:to`. La lista de correos electrónicos puede ser una matriz de direcciones de correo electrónico o una cadena única con las direcciones separadas por comas.

```ruby
class AdminMailer < ApplicationMailer
  default to: -> { Admin.pluck(:email) },
          from: 'notification@example.com'

  def new_registration(user)
    @user = user
    mail(subject: "Nuevo registro de usuario: #{@user.email}")
  end
end
```

El mismo formato se puede utilizar para establecer destinatarios en copia (Cc:) y copia oculta (Bcc:), utilizando las claves `:cc` y `:bcc`, respectivamente.

#### Enviar correo electrónico con nombre

A veces desea mostrar el nombre de la persona en lugar de solo su dirección de correo electrónico cuando reciben el correo electrónico. Puede usar [`email_address_with_name`][] para eso:

```ruby
def welcome_email
  @user = params[:user]
  mail(
    to: email_address_with_name(@user.email, @user.name),
    subject: 'Bienvenido a Mi Sitio Increíble'
  )
end
```

La misma técnica funciona para especificar un nombre de remitente:

```ruby
class UserMailer < ApplicationMailer
  default from: email_address_with_name('notification@example.com', 'Notificaciones de la Compañía de Ejemplo')
end
```

Si el nombre es una cadena en blanco, solo devuelve la dirección.

### Vistas de Mailer

Las vistas de Mailer se encuentran en el directorio `app/views/nombre_de_la_clase_mailer`. La vista de Mailer específica es conocida por la clase porque su nombre es el mismo que el método del mailer. En nuestro ejemplo anterior, nuestra vista de mailer para el método `welcome_email` estará en `app/views/user_mailer/welcome_email.html.erb` para la versión HTML y `welcome_email.text.erb` para la versión de texto sin formato.

Para cambiar la vista de mailer predeterminada para su acción, haga algo como esto:

```ruby
class UserMailer < ApplicationMailer
  default from: 'notifications@example.com'

  def welcome_email
    @user = params[:user]
    @url  = 'http://example.com/login'
    mail(to: @user.email,
         subject: 'Bienvenido a Mi Sitio Increíble',
         template_path: 'notifications',
         template_name: 'another')
  end
end
```
En este caso, buscará plantillas en `app/views/notifications` con el nombre `another`. También puedes especificar una matriz de rutas para `template_path` y se buscarán en orden.

Si deseas más flexibilidad, también puedes pasar un bloque y renderizar plantillas específicas o incluso renderizar en línea o texto sin usar un archivo de plantilla:

```ruby
class UserMailer < ApplicationMailer
  default from: 'notifications@example.com'

  def welcome_email
    @user = params[:user]
    @url  = 'http://example.com/login'
    mail(to: @user.email,
         subject: 'Bienvenido a Mi Sitio Increíble') do |format|
      format.html { render 'another_template' }
      format.text { render plain: 'Renderizar texto' }
    end
  end
end
```

Esto renderizará la plantilla 'another_template.html.erb' para la parte HTML y utilizará el texto renderizado para la parte de texto. El comando render es el mismo que se utiliza dentro de Action Controller, por lo que puedes usar todas las mismas opciones, como `:text`, `:inline`, etc.

Si deseas renderizar una plantilla ubicada fuera del directorio predeterminado `app/views/mailer_name/`, puedes aplicar el método [`prepend_view_path`][], de la siguiente manera:

```ruby
class UserMailer < ApplicationMailer
  prepend_view_path "custom/path/to/mailer/view"

  # Esto intentará cargar la plantilla "custom/path/to/mailer/view/welcome_email"
  def welcome_email
    # ...
  end
end
```

También puedes considerar usar el método [`append_view_path`][].


#### Caché de la vista del Mailer

Puedes realizar caché de fragmentos en las vistas del mailer al igual que en las vistas de la aplicación utilizando el método [`cache`][].

```html+erb
<% cache do %>
  <%= @company.name %>
<% end %>
```

Y para utilizar esta función, debes configurar tu aplicación de la siguiente manera:

```ruby
config.action_mailer.perform_caching = true
```

La caché de fragmentos también es compatible con correos electrónicos multipartes.
Lee más sobre la caché en la [guía de caché de Rails](caching_with_rails.html).


### Diseños de Action Mailer

Al igual que las vistas del controlador, también puedes tener diseños de mailer. El nombre del diseño debe ser el mismo que el de tu mailer, como `user_mailer.html.erb` y `user_mailer.text.erb` para que sean reconocidos automáticamente por tu mailer como un diseño.

Para usar un archivo diferente, llama a [`layout`][] en tu mailer:

```ruby
class UserMailer < ApplicationMailer
  layout 'awesome' # utiliza awesome.(html|text).erb como el diseño
end
```

Al igual que con las vistas del controlador, utiliza `yield` para renderizar la vista dentro del diseño.

También puedes pasar la opción `layout: 'nombre_del_diseño'` a la llamada de render dentro del bloque de formato para especificar diseños diferentes para diferentes formatos:

```ruby
class UserMailer < ApplicationMailer
  def welcome_email
    mail(to: params[:user].email) do |format|
      format.html { render layout: 'my_layout' }
      format.text
    end
  end
end
```

Esto renderizará la parte HTML utilizando el archivo `my_layout.html.erb` y la parte de texto con el archivo `user_mailer.text.erb` habitual si existe.


### Previsualización de correos electrónicos

Las previsualizaciones de Action Mailer proporcionan una forma de ver cómo se ven los correos electrónicos visitando una URL especial que los renderiza. En el ejemplo anterior, la clase de previsualización para `UserMailer` debe llamarse `UserMailerPreview` y ubicarse en `test/mailers/previews/user_mailer_preview.rb`. Para ver la previsualización de `welcome_email`, implementa un método que tenga el mismo nombre y llama a `UserMailer.welcome_email`:

```ruby
class UserMailerPreview < ActionMailer::Preview
  def welcome_email
    UserMailer.with(user: User.first).welcome_email
  end
end
```

Luego, la previsualización estará disponible en <http://localhost:3000/rails/mailers/user_mailer/welcome_email>.

Si cambias algo en `app/views/user_mailer/welcome_email.html.erb` o en el mailer mismo, se recargará y se renderizará automáticamente para que puedas ver el nuevo estilo al instante. Una lista de previsualizaciones también está disponible en <http://localhost:3000/rails/mailers>.

De forma predeterminada, estas clases de previsualización se encuentran en `test/mailers/previews`.
Esto se puede configurar utilizando la opción `preview_paths`. Por ejemplo, si deseas agregar `lib/mailer_previews`, puedes configurarlo en `config/application.rb`:

```ruby
config.action_mailer.preview_paths << "#{Rails.root}/lib/mailer_previews"
```

### Generación de URLs en las vistas de Action Mailer

A diferencia de los controladores, la instancia del mailer no tiene ningún contexto sobre la solicitud entrante, por lo que deberás proporcionar el parámetro `:host` tú mismo.

Como el `:host` suele ser consistente en toda la aplicación, puedes configurarlo globalmente en `config/application.rb`:

```ruby
config.action_mailer.default_url_options = { host: 'example.com' }
```
Debido a este comportamiento, no puedes usar ninguno de los ayudantes `*_path` dentro de un correo electrónico. En su lugar, deberás usar el ayudante asociado `*_url`. Por ejemplo, en lugar de usar

```html+erb
<%= link_to 'bienvenido', welcome_path %>
```

Deberás usar:

```html+erb
<%= link_to 'bienvenido', welcome_url %>
```

Al utilizar la URL completa, tus enlaces ahora funcionarán en tus correos electrónicos.

#### Generando URLs con `url_for`

[`url_for`][] genera una URL completa de forma predeterminada en las plantillas.

Si no configuraste la opción `:host` globalmente, asegúrate de pasarla a `url_for`.


```erb
<%= url_for(host: 'example.com',
            controller: 'welcome',
            action: 'greeting') %>
```


#### Generando URLs con Rutas Nombradas

Los clientes de correo electrónico no tienen contexto web, por lo que las rutas no tienen una URL base para formar direcciones web completas. Por lo tanto, siempre debes usar la variante `*_url` de los ayudantes de rutas nombradas.

Si no configuraste la opción `:host` globalmente, asegúrate de pasarla al ayudante de URL.

```erb
<%= user_url(@user, host: 'example.com') %>
```

NOTA: los enlaces que no son de tipo `GET` requieren [rails-ujs](https://github.com/rails/rails/blob/main/actionview/app/assets/javascripts) o [jQuery UJS](https://github.com/rails/jquery-ujs), y no funcionarán en las plantillas de correo. Resultarán en solicitudes `GET` normales.

### Agregando Imágenes en las Vistas de Action Mailer

A diferencia de los controladores, la instancia del mailer no tiene ningún contexto sobre la solicitud entrante, por lo que deberás proporcionar el parámetro `:asset_host` tú mismo.

Como el `:asset_host` suele ser consistente en toda la aplicación, puedes configurarlo globalmente en `config/application.rb`:

```ruby
config.asset_host = 'http://example.com'
```

Ahora puedes mostrar una imagen dentro de tu correo electrónico.

```html+erb
<%= image_tag 'image.jpg' %>
```

### Enviando Correos Electrónicos Multiparte

Action Mailer enviará automáticamente correos electrónicos multiparte si tienes diferentes plantillas para la misma acción. Entonces, para nuestro ejemplo de `UserMailer`, si tienes `welcome_email.text.erb` y `welcome_email.html.erb` en `app/views/user_mailer`, Action Mailer enviará automáticamente un correo electrónico multiparte con las versiones HTML y de texto configuradas como partes diferentes.

El orden de las partes que se insertan se determina por `:parts_order` dentro del método `ActionMailer::Base.default`.

### Enviando Correos Electrónicos con Opciones de Entrega Dinámicas

Si deseas anular las opciones de entrega predeterminadas (por ejemplo, las credenciales SMTP) al enviar correos electrónicos, puedes hacerlo utilizando `delivery_method_options` en la acción del mailer.

```ruby
class UserMailer < ApplicationMailer
  def welcome_email
    @user = params[:user]
    @url  = user_url(@user)
    delivery_options = { user_name: params[:company].smtp_user,
                         password: params[:company].smtp_password,
                         address: params[:company].smtp_host }
    mail(to: @user.email,
         subject: "Por favor, consulta los Términos y Condiciones adjuntos",
         delivery_method_options: delivery_options)
  end
end
```

### Enviando Correos Electrónicos sin Renderizar Plantillas

Puede haber casos en los que desees omitir el paso de renderización de la plantilla y proporcionar el cuerpo del correo electrónico como una cadena. Puedes lograr esto utilizando la opción `:body`. En tales casos, no olvides agregar la opción `:content_type`. De lo contrario, Rails utilizará `text/plain` de forma predeterminada.

```ruby
class UserMailer < ApplicationMailer
  def welcome_email
    mail(to: params[:user].email,
         body: params[:email_body],
         content_type: "text/html",
         subject: "¡Ya se ha renderizado!")
  end
end
```

Acciones de Devolución de Llamada de Action Mailer
--------------------------------------------------

Action Mailer te permite especificar un [`before_action`][], [`after_action`][] y [`around_action`][] para configurar el mensaje, y [`before_deliver`][], [`after_deliver`][] y [`around_deliver`][] para controlar la entrega.

* Las devoluciones de llamada se pueden especificar con un bloque o un símbolo a un método en la clase del mailer, similar a los controladores.

* Puedes usar un `before_action` para establecer variables de instancia, poblar el objeto de correo con valores predeterminados o insertar encabezados y adjuntos predeterminados.

```ruby
class InvitationsMailer < ApplicationMailer
  before_action :set_inviter_and_invitee
  before_action { @account = params[:inviter].account }

  default to:       -> { @invitee.email_address },
          from:     -> { common_address(@inviter) },
          reply_to: -> { @inviter.email_address_with_name }

  def account_invitation
    mail subject: "#{@inviter.name} te invitó a su Basecamp (#{@account.name})"
  end

  def project_invitation
    @project    = params[:project]
    @summarizer = ProjectInvitationSummarizer.new(@project.bucket)

    mail subject: "#{@inviter.name.familiar} te agregó a un proyecto en Basecamp (#{@account.name})"
  end

  private
    def set_inviter_and_invitee
      @inviter = params[:inviter]
      @invitee = params[:invitee]
    end
end
```
* Podrías usar un `after_action` para hacer una configuración similar a un `before_action`, pero utilizando variables de instancia establecidas en tu acción de mailer.

* El uso de un callback `after_action` también te permite anular la configuración del método de entrega actualizando `mail.delivery_method.settings`.

```ruby
class UserMailer < ApplicationMailer
  before_action { @business, @user = params[:business], params[:user] }

  after_action :set_delivery_options,
               :prevent_delivery_to_guests,
               :set_business_headers

  def feedback_message
  end

  def campaign_message
  end

  private
    def set_delivery_options
      # Tienes acceso a la instancia de mail,
      # a las variables de instancia @business y @user aquí
      if @business && @business.has_smtp_settings?
        mail.delivery_method.settings.merge!(@business.smtp_settings)
      end
    end

    def prevent_delivery_to_guests
      if @user && @user.guest?
        mail.perform_deliveries = false
      end
    end

    def set_business_headers
      if @business
        headers["X-SMTPAPI-CATEGORY"] = @business.code
      end
    end
end
```

* Podrías usar un `after_delivery` para registrar la entrega del mensaje.

* Los callbacks del mailer abortan el procesamiento adicional si el cuerpo se establece en un valor distinto de `nil`. `before_deliver` puede abortar con `throw :abort`.


Uso de los ayudantes de Action Mailer
-------------------------------------

Action Mailer hereda de `AbstractController`, por lo que tienes acceso a la mayoría
de los mismos ayudantes que tienes en Action Controller.

También hay algunos métodos de ayuda específicos de Action Mailer disponibles en
[`ActionMailer::MailHelper`][]. Por ejemplo, estos permiten acceder a la instancia del mailer
desde tu vista con [`mailer`][MailHelper#mailer], y acceder al mensaje como [`message`][MailHelper#message]:

```erb
<%= stylesheet_link_tag mailer.name.underscore %>
<h1><%= message.subject %></h1>
```


Configuración de Action Mailer
-----------------------------

Las siguientes opciones de configuración se deben realizar en uno de los archivos de entorno
(environment.rb, production.rb, etc...)

| Configuración | Descripción |
|---------------|-------------|
|`logger`|Genera información sobre la ejecución del envío de correos si está disponible. Puede establecerse en `nil` para no generar registros. Compatible tanto con el propio `Logger` de Ruby como con los registros de `Log4r`.|
|`smtp_settings`|Permite una configuración detallada para el método de entrega `:smtp`:<ul><li>`:address` - Permite utilizar un servidor de correo remoto. Solo cambia el valor de su configuración predeterminada `"localhost"`.</li><li>`:port` - En caso de que tu servidor de correo no se ejecute en el puerto 25, puedes cambiarlo.</li><li>`:domain` - Si necesitas especificar un dominio HELO, puedes hacerlo aquí.</li><li>`:user_name` - Si tu servidor de correo requiere autenticación, establece el nombre de usuario en esta configuración.</li><li>`:password` - Si tu servidor de correo requiere autenticación, establece la contraseña en esta configuración.</li><li>`:authentication` - Si tu servidor de correo requiere autenticación, debes especificar el tipo de autenticación aquí. Esto es un símbolo y puede ser `:plain` (enviará la contraseña en texto claro), `:login` (enviará la contraseña codificada en Base64) o `:cram_md5` (combina un mecanismo de desafío/respuesta para intercambiar información y un algoritmo criptográfico de resumen de mensaje MD5 para resumir información importante).</li><li>`:enable_starttls` - Utiliza STARTTLS al conectarse a tu servidor SMTP y falla si no es compatible. Por defecto es `false`.</li><li>`:enable_starttls_auto` - Detecta si STARTTLS está habilitado en tu servidor SMTP y comienza a usarlo. Por defecto es `true`.</li><li>`:openssl_verify_mode` - Cuando se utiliza TLS, puedes establecer cómo OpenSSL verifica el certificado. Esto es muy útil si necesitas validar un certificado autofirmado y/o un certificado comodín. Puedes usar el nombre de una constante de verificación de OpenSSL ('none' o 'peer') o directamente la constante (`OpenSSL::SSL::VERIFY_NONE` o `OpenSSL::SSL::VERIFY_PEER`).</li><li>`:ssl/:tls` - Habilita la conexión SMTP para usar SMTP/TLS (SMTPS: conexión SMTP sobre TLS directa)</li><li>`:open_timeout` - Número de segundos para esperar al intentar abrir una conexión.</li><li>`:read_timeout` - Número de segundos para esperar hasta que se agote el tiempo de espera de una llamada a read(2).</li></ul>|
|`sendmail_settings`|Permite anular las opciones para el método de entrega `:sendmail`.<ul><li>`:location` - La ubicación del ejecutable sendmail. Por defecto es `/usr/sbin/sendmail`.</li><li>`:arguments` - Los argumentos de línea de comandos que se pasarán a sendmail. Por defecto es `["-i"]`.</li></ul>|
|`raise_delivery_errors`|Determina si se deben generar errores si el correo electrónico no se puede enviar. Esto solo funciona si el servidor de correo externo está configurado para enviar inmediatamente. Por defecto es `true`.|
|`delivery_method`|Define un método de entrega. Los valores posibles son:<ul><li>`:smtp` (predeterminado), se puede configurar utilizando [`config.action_mailer.smtp_settings`][].</li><li>`:sendmail`, se puede configurar utilizando [`config.action_mailer.sendmail_settings`][].</li><li>`:file`: guarda los correos electrónicos en archivos; se puede configurar utilizando `config.action_mailer.file_settings`.</li><li>`:test`: guarda los correos electrónicos en la matriz `ActionMailer::Base.deliveries`.</li></ul>Consulta la [documentación de la API](https://api.rubyonrails.org/classes/ActionMailer/Base.html) para obtener más información.|
|`perform_deliveries`|Determina si los envíos se llevan a cabo realmente cuando se invoca el método `deliver` en el mensaje de correo. Por defecto, sí se llevan a cabo, pero esto se puede desactivar para ayudar en las pruebas funcionales. Si este valor es `false`, la matriz `deliveries` no se llenará incluso si el `delivery_method` es `:test`.|
|`deliveries`|Mantiene una matriz de todos los correos electrónicos enviados a través de Action Mailer con el método de entrega `:test`. Muy útil para pruebas unitarias y funcionales.|
|`delivery_job`|La clase de trabajo utilizada con `deliver_later`. Por defecto es `ActionMailer::MailDeliveryJob`.|
|`deliver_later_queue_name`|El nombre de la cola utilizada con el trabajo `delivery_job` predeterminado. Por defecto es la cola predeterminada de Active Job.|
|`default_options`|Permite establecer valores predeterminados para las opciones del método `mail` (`:from`, `:reply_to`, etc.).|
Para obtener una descripción completa de las posibles configuraciones, consulte la sección [Configuración de Action Mailer](configuring.html#configuring-action-mailer) en nuestra guía Configuración de aplicaciones Rails.

### Ejemplo de configuración de Action Mailer

Un ejemplo sería agregar lo siguiente a su archivo `config/environments/$RAILS_ENV.rb` correspondiente:

```ruby
config.action_mailer.delivery_method = :sendmail
# Por defecto:
# config.action_mailer.sendmail_settings = {
#   location: '/usr/sbin/sendmail',
#   arguments: %w[ -i ]
# }
config.action_mailer.perform_deliveries = true
config.action_mailer.raise_delivery_errors = true
config.action_mailer.default_options = { from: 'no-reply@example.com' }
```

### Configuración de Action Mailer para Gmail

Action Mailer utiliza la gema [Mail](https://github.com/mikel/mail) y acepta una configuración similar. Agregue esto a su archivo `config/environments/$RAILS_ENV.rb` para enviar correos electrónicos a través de Gmail:

```ruby
config.action_mailer.delivery_method = :smtp
config.action_mailer.smtp_settings = {
  address:         'smtp.gmail.com',
  port:            587,
  domain:          'example.com',
  user_name:       '<username>',
  password:        '<password>',
  authentication:  'plain',
  enable_starttls: true,
  open_timeout:    5,
  read_timeout:    5 }
```

Si está utilizando una versión antigua de la gema Mail (2.6.x o anterior), use `enable_starttls_auto` en lugar de `enable_starttls`.

NOTA: Google [bloquea los inicios de sesión](https://support.google.com/accounts/answer/6010255) desde aplicaciones que considera menos seguras. Puede cambiar la configuración de su cuenta de Gmail [aquí](https://www.google.com/settings/security/lesssecureapps) para permitir los intentos. Si su cuenta de Gmail tiene habilitada la autenticación de dos factores, deberá configurar una [contraseña de aplicación](https://myaccount.google.com/apppasswords) y utilizarla en lugar de su contraseña regular.

Pruebas de correo electrónico
--------------

Puede encontrar instrucciones detalladas sobre cómo probar sus mailers en la [guía de pruebas](testing.html#testing-your-mailers).

Interceptar y observar correos electrónicos
-------------------

Action Mailer proporciona ganchos en los métodos de observación e intercepción de Mail. Estos le permiten registrar clases que se llaman durante el ciclo de vida de entrega de correo electrónico de cada correo electrónico enviado.

### Interceptar correos electrónicos

Los interceptores le permiten realizar modificaciones en los correos electrónicos antes de que se entreguen a los agentes de entrega. Una clase de interceptor debe implementar el método `::delivering_email(message)`, que se llamará antes de enviar el correo electrónico.

```ruby
class SandboxEmailInterceptor
  def self.delivering_email(message)
    message.to = ['sandbox@example.com']
  end
end
```

Antes de que el interceptor pueda hacer su trabajo, debe registrarlo utilizando la opción de configuración `interceptors`. Puede hacer esto en un archivo inicializador como `config/initializers/mail_interceptors.rb`:

```ruby
Rails.application.configure do
  if Rails.env.staging?
    config.action_mailer.interceptors = %w[SandboxEmailInterceptor]
  end
end
```

NOTA: El ejemplo anterior utiliza un entorno personalizado llamado "staging" para un servidor similar a producción pero con fines de prueba. Puede leer [Creación de entornos Rails](configuring.html#creating-rails-environments) para obtener más información sobre los entornos personalizados de Rails.

### Observar correos electrónicos

Los observadores le brindan acceso al mensaje de correo electrónico después de que se haya enviado. Una clase de observador debe implementar el método `:delivered_email(message)`, que se llamará después de enviar el correo electrónico.

```ruby
class EmailDeliveryObserver
  def self.delivered_email(message)
    EmailDelivery.log(message)
  end
end
```

Al igual que con los interceptores, debe registrar los observadores utilizando la opción de configuración `observers`. Puede hacer esto en un archivo inicializador como `config/initializers/mail_observers.rb`:

```ruby
Rails.application.configure do
  config.action_mailer.observers = %w[EmailDeliveryObserver]
end
```
[`ActionMailer::Base`]: https://api.rubyonrails.org/classes/ActionMailer/Base.html
[`default`]: https://api.rubyonrails.org/classes/ActionMailer/Base.html#method-c-default
[`mail`]: https://api.rubyonrails.org/classes/ActionMailer/Base.html#method-i-mail
[`ActionMailer::MessageDelivery`]: https://api.rubyonrails.org/classes/ActionMailer/MessageDelivery.html
[`deliver_later`]: https://api.rubyonrails.org/classes/ActionMailer/MessageDelivery.html#method-i-deliver_later
[`deliver_now`]: https://api.rubyonrails.org/classes/ActionMailer/MessageDelivery.html#method-i-deliver_now
[`Mail::Message`]: https://api.rubyonrails.org/classes/Mail/Message.html
[`message`]: https://api.rubyonrails.org/classes/ActionMailer/MessageDelivery.html#method-i-message
[`with`]: https://api.rubyonrails.org/classes/ActionMailer/Parameterized/ClassMethods.html#method-i-with
[`attachments`]: https://api.rubyonrails.org/classes/ActionMailer/Base.html#method-i-attachments
[`headers`]: https://api.rubyonrails.org/classes/ActionMailer/Base.html#method-i-headers
[`email_address_with_name`]: https://api.rubyonrails.org/classes/ActionMailer/Base.html#method-i-email_address_with_name
[`append_view_path`]: https://api.rubyonrails.org/classes/ActionView/ViewPaths/ClassMethods.html#method-i-append_view_path
[`prepend_view_path`]: https://api.rubyonrails.org/classes/ActionView/ViewPaths/ClassMethods.html#method-i-prepend_view_path
[`cache`]: https://api.rubyonrails.org/classes/ActionView/Helpers/CacheHelper.html#method-i-cache
[`layout`]: https://api.rubyonrails.org/classes/ActionView/Layouts/ClassMethods.html#method-i-layout
[`url_for`]: https://api.rubyonrails.org/classes/ActionView/RoutingUrlFor.html#method-i-url_for
[`after_action`]: https://api.rubyonrails.org/classes/AbstractController/Callbacks/ClassMethods.html#method-i-after_action
[`after_deliver`]: https://api.rubyonrails.org/classes/ActionMailer/Callbacks/ClassMethods.html#method-i-after_deliver
[`around_action`]: https://api.rubyonrails.org/classes/AbstractController/Callbacks/ClassMethods.html#method-i-around_action
[`around_deliver`]: https://api.rubyonrails.org/classes/ActionMailer/Callbacks/ClassMethods.html#method-i-around_deliver
[`before_action`]: https://api.rubyonrails.org/classes/AbstractController/Callbacks/ClassMethods.html#method-i-before_action
[`before_deliver`]: https://api.rubyonrails.org/classes/ActionMailer/Callbacks/ClassMethods.html#method-i-before_deliver
[`ActionMailer::MailHelper`]: https://api.rubyonrails.org/classes/ActionMailer/MailHelper.html
[MailHelper#mailer]: https://api.rubyonrails.org/classes/ActionMailer/MailHelper.html#method-i-mailer
[MailHelper#message]: https://api.rubyonrails.org/classes/ActionMailer/MailHelper.html#method-i-message
[`config.action_mailer.sendmail_settings`]: configuring.html#config-action-mailer-sendmail-settings
[`config.action_mailer.smtp_settings`]: configuring.html#config-action-mailer-smtp-settings
