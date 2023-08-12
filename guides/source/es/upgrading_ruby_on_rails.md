**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: b95e1fead49349e056e5faed88aa5760
Actualización de Ruby on Rails
=======================

Esta guía proporciona los pasos a seguir cuando actualizas tus aplicaciones a una versión más nueva de Ruby on Rails. Estos pasos también están disponibles en las guías de lanzamiento individuales.

--------------------------------------------------------------------------------

Consejos generales
--------------

Antes de intentar actualizar una aplicación existente, debes asegurarte de tener una buena razón para hacerlo. Debes equilibrar varios factores: la necesidad de nuevas características, la dificultad creciente de encontrar soporte para código antiguo y tu tiempo y habilidades disponibles, por nombrar algunos.

### Cobertura de pruebas

La mejor manera de asegurarte de que tu aplicación siga funcionando después de la actualización es tener una buena cobertura de pruebas antes de comenzar el proceso. Si no tienes pruebas automatizadas que ejerciten la mayor parte de tu aplicación, deberás pasar tiempo ejercitando manualmente todas las partes que han cambiado. En el caso de una actualización de Rails, eso significará cada pieza de funcionalidad en la aplicación. Hazte un favor y asegúrate de que tu cobertura de pruebas sea buena _antes_ de comenzar una actualización.

### Versiones de Ruby

Rails generalmente se mantiene cerca de la última versión de Ruby lanzada cuando se lanza:

* Rails 7 requiere Ruby 2.7.0 o una versión más nueva.
* Rails 6 requiere Ruby 2.5.0 o una versión más nueva.
* Rails 5 requiere Ruby 2.2.2 o una versión más nueva.

Es una buena idea actualizar Ruby y Rails por separado. Primero actualiza a la última versión de Ruby que puedas y luego actualiza Rails.

### El proceso de actualización

Cuando cambias las versiones de Rails, es mejor avanzar lentamente, una versión menor a la vez, para aprovechar al máximo las advertencias de deprecación. Los números de versión de Rails tienen la forma Mayor.Menor.Parche. Las versiones Mayor y Menor pueden realizar cambios en la API pública, lo que puede causar errores en tu aplicación. Las versiones de Parche solo incluyen correcciones de errores y no cambian ninguna API pública.

El proceso debería seguir los siguientes pasos:

1. Escribe pruebas y asegúrate de que pasen.
2. Muévete a la última versión de parche después de tu versión actual.
3. Corrige las pruebas y las características obsoletas.
4. Muévete a la última versión de parche de la siguiente versión menor.

Repite este proceso hasta que alcances tu versión objetivo de Rails.

#### Moverse entre versiones

Para moverte entre versiones:

1. Cambia el número de versión de Rails en el `Gemfile` y ejecuta `bundle update`.
2. Cambia las versiones de los paquetes de JavaScript de Rails en `package.json` y ejecuta `yarn install`, si estás utilizando Webpacker.
3. Ejecuta la [tarea de actualización](#la-tarea-de-actualizacion).
4. Ejecuta tus pruebas.

Puedes encontrar una lista de todas las gemas de Rails lanzadas [aquí](https://rubygems.org/gems/rails/versions).

### La tarea de actualización

Rails proporciona el comando `rails app:update`. Después de actualizar la versión de Rails en el `Gemfile`, ejecuta este comando.
Esto te ayudará con la creación de nuevos archivos y cambios en los archivos antiguos en una sesión interactiva.

```bash
$ bin/rails app:update
       exist  config
    conflict  config/application.rb
Sobrescribir /myapp/config/application.rb? (ingresa "h" para obtener ayuda) [Ynaqdh]
       force  config/application.rb
      create  config/initializers/new_framework_defaults_7_0.rb
...
```

No olvides revisar las diferencias para ver si hubo algún cambio inesperado.

### Configurar los valores predeterminados del framework

Es posible que la nueva versión de Rails tenga valores predeterminados de configuración diferentes a la versión anterior. Sin embargo, después de seguir los pasos descritos anteriormente, tu aplicación seguirá ejecutándose con los valores predeterminados de configuración de la *versión anterior* de Rails. Esto se debe a que el valor de `config.load_defaults` en `config/application.rb` aún no ha sido cambiado.

Para permitirte actualizar a los nuevos valores predeterminados de forma gradual, la tarea de actualización ha creado un archivo `config/initializers/new_framework_defaults_X.Y.rb` (con la versión deseada de Rails en el nombre del archivo). Debes habilitar los nuevos valores predeterminados de configuración descomentándolos en el archivo; esto se puede hacer gradualmente en varias implementaciones. Una vez que tu aplicación esté lista para ejecutarse con los nuevos valores predeterminados, puedes eliminar este archivo y cambiar el valor de `config.load_defaults`.

Actualización de Rails 7.0 a Rails 7.1
-------------------------------------

Para obtener más información sobre los cambios realizados en Rails 7.1, consulta las [notas de lanzamiento](7_1_release_notes.html).

### Las rutas cargadas automáticamente ya no están en la ruta de carga

A partir de Rails 7.1, todas las rutas gestionadas por el cargador automático ya no se agregarán a `$LOAD_PATH`.
Esto significa que no será posible cargarlas con una llamada manual a `require`, en su lugar, se puede hacer referencia a la clase o módulo.

Reducir el tamaño de `$LOAD_PATH` acelera las llamadas a `require` para aplicaciones que no utilizan `bootsnap` y reduce el
tamaño de la caché de `bootsnap` para las demás.
### `ActiveStorage::BaseController` ya no incluye la preocupación por la transmisión

Los controladores de la aplicación que heredan de `ActiveStorage::BaseController` y utilizan la transmisión para implementar la lógica personalizada de servir archivos ahora deben incluir explícitamente el módulo `ActiveStorage::Streaming`.

### `MemCacheStore` y `RedisCacheStore` ahora utilizan la agrupación de conexiones de forma predeterminada

Se ha agregado la gema `connection_pool` como una dependencia de la gema `activesupport`,
y `MemCacheStore` y `RedisCacheStore` ahora utilizan la agrupación de conexiones de forma predeterminada.

Si no desea utilizar la agrupación de conexiones, configure la opción `:pool` en `false` al configurar su almacén de caché:

```ruby
config.cache_store = :mem_cache_store, "cache.example.com", pool: false
```

Consulte la guía [Caché con Rails](https://guides.rubyonrails.org/v7.1/caching_with_rails.html#connection-pool-options) para obtener más información.

### `SQLite3Adapter` ahora está configurado para utilizarse en un modo estricto de cadenas

El uso de un modo estricto de cadenas deshabilita los literales de cadena entre comillas dobles.

SQLite tiene algunas peculiaridades en torno a los literales de cadena entre comillas dobles.
Primero intenta considerar las cadenas entre comillas dobles como nombres de identificadores, pero si no existen,
luego las considera como literales de cadena. Debido a esto, los errores tipográficos pueden pasar desapercibidos.
Por ejemplo, es posible crear un índice para una columna que no existe.
Consulte la documentación de SQLite para obtener más detalles: [SQLite documentation](https://www.sqlite.org/quirks.html#double_quoted_string_literals_are_accepted).

Si no desea utilizar `SQLite3Adapter` en modo estricto, puede deshabilitar este comportamiento:

```ruby
# config/application.rb
config.active_record.sqlite3_adapter_strict_strings_by_default = false
```

### Se admite múltiples rutas de vista previa para `ActionMailer::Preview`

La opción `config.action_mailer.preview_path` está en desuso a favor de `config.action_mailer.preview_paths`. Agregar rutas a esta opción de configuración hará que se utilicen esas rutas en la búsqueda de vistas previas de correo.

```ruby
config.action_mailer.preview_paths << "#{Rails.root}/lib/mailer_previews"
```

### `config.i18n.raise_on_missing_translations = true` ahora genera un error en caso de falta de traducción.

Anteriormente, solo generaba un error cuando se llamaba en una vista o controlador. Ahora generará un error cada vez que se proporcione una clave no reconocida a `I18n.t`.

```ruby
# con config.i18n.raise_on_missing_translations = true

# en una vista o controlador:
t("missing.key") # genera un error en 7.0, genera un error en 7.1
I18n.t("missing.key") # no generaba un error en 7.0, genera un error en 7.1

# en cualquier lugar:
I18n.t("missing.key") # no generaba un error en 7.0, genera un error en 7.1
```

Si no desea este comportamiento, puede establecer `config.i18n.raise_on_missing_translations = false`:

```ruby
# con config.i18n.raise_on_missing_translations = false

# en una vista o controlador:
t("missing.key") # no generaba un error en 7.0, no genera un error en 7.1
I18n.t("missing.key") # no generaba un error en 7.0, no genera un error en 7.1

# en cualquier lugar:
I18n.t("missing.key") # no generaba un error en 7.0, no genera un error en 7.1
```

Alternativamente, puede personalizar el `I18n.exception_handler`.
Consulte la guía [i18n](https://guides.rubyonrails.org/v7.1/i18n.html#using-different-exception-handlers) para obtener más información.

Actualización de Rails 6.1 a Rails 7.0
-------------------------------------

Para obtener más información sobre los cambios realizados en Rails 7.0, consulte las [notas de la versión](7_0_release_notes.html).

### El comportamiento de `ActionView::Helpers::UrlHelper#button_to` ha cambiado

A partir de Rails 7.0, `button_to` renderiza una etiqueta `form` con el verbo HTTP `patch` si se utiliza un objeto Active Record persistente para construir la URL del botón.
Para mantener el comportamiento actual, considere pasar explícitamente la opción `method:`:

```diff
-button_to("Do a POST", [:my_custom_post_action_on_workshop, Workshop.find(1)])
+button_to("Do a POST", [:my_custom_post_action_on_workshop, Workshop.find(1)], method: :post)
```

o utilizando un helper para construir la URL:

```diff
-button_to("Do a POST", [:my_custom_post_action_on_workshop, Workshop.find(1)])
+button_to("Do a POST", my_custom_post_action_on_workshop_workshop_path(Workshop.find(1)))
```

### Spring

Si su aplicación utiliza Spring, debe actualizarse a al menos la versión 3.0.0. De lo contrario, obtendrá el siguiente error:

```
undefined method `mechanism=' for ActiveSupport::Dependencies:Module
```

Además, asegúrese de que [`config.cache_classes`][] esté configurado en `false` en `config/environments/test.rb`.


### Sprockets ahora es una dependencia opcional

La gema `rails` ya no depende de `sprockets-rails`. Si su aplicación todavía necesita usar Sprockets,
asegúrese de agregar `sprockets-rails` a su Gemfile.

```ruby
gem "sprockets-rails"
```

### Las aplicaciones deben ejecutarse en modo `zeitwerk`

Las aplicaciones que siguen ejecutándose en modo `classic` deben cambiar al modo `zeitwerk`. Consulte la guía [Classic to Zeitwerk HOWTO](https://guides.rubyonrails.org/v7.0/classic_to_zeitwerk_howto.html) para obtener más detalles.

### Se ha eliminado el setter `config.autoloader=`

En Rails 7 no hay un punto de configuración para establecer el modo de carga automática, se ha eliminado `config.autoloader=`. Si lo tenía configurado en `:zeitwerk` por alguna razón, simplemente elimínelo.

### Se ha eliminado la API privada de `ActiveSupport::Dependencies`

Se ha eliminado la API privada de `ActiveSupport::Dependencies`. Esto incluye métodos como `hook!`, `unhook!`, `depend_on`, `require_or_load`, `mechanism` y muchos otros.

Algunos aspectos destacados:

* Si utilizaba `ActiveSupport::Dependencies.constantize` o `ActiveSupport::Dependencies.safe_constantize`, simplemente cámbielos por `String#constantize` o `String#safe_constantize`.

  ```ruby
  ActiveSupport::Dependencies.constantize("User") # YA NO ES POSIBLE
  "User".constantize # 👍
  ```

* Cualquier uso de `ActiveSupport::Dependencies.mechanism`, tanto de lectura como de escritura, debe reemplazarse accediendo a `config.cache_classes` en consecuencia.

* Si desea rastrear la actividad del cargador automático, `ActiveSupport::Dependencies.verbose=` ya no está disponible, simplemente agregue `Rails.autoloaders.log!` en `config/application.rb`.
También se han eliminado las clases o módulos internos auxiliares, como `ActiveSupport::Dependencies::Reference`, `ActiveSupport::Dependencies::Blamable` y otros.

### Carga automática durante la inicialización

Las aplicaciones que cargaban automáticamente constantes recargables durante la inicialización fuera de los bloques `to_prepare` descargaban esas constantes y emitían esta advertencia desde Rails 6.0:

```
ADVERTENCIA DE DEPRECIACIÓN: La inicialización cargó automáticamente la constante ....

Poder hacer esto está en desuso. La carga automática durante la inicialización será una condición de error en futuras versiones de Rails.

...
```

Si aún obtiene esta advertencia en los registros, consulte la sección sobre carga automática cuando la aplicación se inicia en la [guía de carga automática](https://guides.rubyonrails.org/v7.0/autoloading_and_reloading_constants.html#autoloading-when-the-application-boots). De lo contrario, obtendrá un `NameError` en Rails 7.

### Posibilidad de configurar `config.autoload_once_paths`

[`config.autoload_once_paths`][] se puede configurar en el cuerpo de la clase de la aplicación definida en `config/application.rb` o en la configuración para entornos en `config/environments/*`.

De manera similar, los motores pueden configurar esa colección en el cuerpo de la clase del motor o en la configuración para entornos.

Después de eso, la colección se congela y se puede cargar automáticamente desde esas rutas. En particular, se puede cargar automáticamente desde allí durante la inicialización. Son gestionados por el cargador automático `Rails.autoloaders.once`, que no se recarga, solo carga automáticamente/carga ansiosa.

Si configuró esta opción después de que se haya procesado la configuración de los entornos y está obteniendo un `FrozenError`, simplemente mueva el código.

### `ActionDispatch::Request#content_type` ahora devuelve el encabezado Content-Type tal como está.

Anteriormente, el valor devuelto por `ActionDispatch::Request#content_type` NO contenía la parte del conjunto de caracteres.
Este comportamiento cambió para devolver el encabezado Content-Type que contiene la parte del conjunto de caracteres tal como está.

Si solo desea el tipo MIME, utilice `ActionDispatch::Request#media_type` en su lugar.

Antes:

```ruby
request = ActionDispatch::Request.new("CONTENT_TYPE" => "text/csv; header=present; charset=utf-16", "REQUEST_METHOD" => "GET")
request.content_type #=> "text/csv"
```

Después:

```ruby
request = ActionDispatch::Request.new("Content-Type" => "text/csv; header=present; charset=utf-16", "REQUEST_METHOD" => "GET")
request.content_type #=> "text/csv; header=present; charset=utf-16"
request.media_type   #=> "text/csv"
```

### El cambio de clase de resumen del generador de claves requiere un rotador de cookies

La clase de resumen predeterminada para el generador de claves está cambiando de SHA1 a SHA256.
Esto tiene consecuencias en cualquier mensaje cifrado generado por Rails, incluidas las cookies cifradas.

Para poder leer mensajes utilizando la antigua clase de resumen, es necesario registrar un rotador. No hacerlo puede resultar en que los usuarios tengan sus sesiones invalidadas durante la actualización.

A continuación se muestra un ejemplo de rotador para las cookies cifradas y firmadas.

```ruby
# config/initializers/cookie_rotator.rb
Rails.application.config.after_initialize do
  Rails.application.config.action_dispatch.cookies_rotations.tap do |cookies|
    authenticated_encrypted_cookie_salt = Rails.application.config.action_dispatch.authenticated_encrypted_cookie_salt
    signed_cookie_salt = Rails.application.config.action_dispatch.signed_cookie_salt

    secret_key_base = Rails.application.secret_key_base

    key_generator = ActiveSupport::KeyGenerator.new(
      secret_key_base, iterations: 1000, hash_digest_class: OpenSSL::Digest::SHA1
    )
    key_len = ActiveSupport::MessageEncryptor.key_len

    old_encrypted_secret = key_generator.generate_key(authenticated_encrypted_cookie_salt, key_len)
    old_signed_secret = key_generator.generate_key(signed_cookie_salt)

    cookies.rotate :encrypted, old_encrypted_secret
    cookies.rotate :signed, old_signed_secret
  end
end
```

### Cambio de clase de resumen para ActiveSupport::Digest a SHA256

La clase de resumen predeterminada para ActiveSupport::Digest está cambiando de SHA1 a SHA256.
Esto tiene consecuencias en cosas como las Etags que cambiarán y las claves de caché también.
Cambiar estas claves puede tener un impacto en las tasas de aciertos en caché, así que tenga cuidado y esté atento a esto al actualizar al nuevo hash.

### Nuevo formato de serialización de ActiveSupport::Cache

Se introdujo un formato de serialización más rápido y compacto.

Para habilitarlo, debe establecer `config.active_support.cache_format_version = 7.0`:

```ruby
# config/application.rb

config.load_defaults 6.1
config.active_support.cache_format_version = 7.0
```

O simplemente:

```ruby
# config/application.rb

config.load_defaults 7.0
```

Sin embargo, las aplicaciones de Rails 6.1 no pueden leer este nuevo formato de serialización,
por lo que para garantizar una actualización sin problemas, primero debe implementar su actualización de Rails 7.0 con
`config.active_support.cache_format_version = 6.1`, y luego, una vez que todos los procesos de Rails
hayan sido actualizados, puede establecer `config.active_support.cache_format_version = 7.0`.

Rails 7.0 puede leer ambos formatos, por lo que la caché no se invalidará durante la
actualización.

### Generación de imágenes de vista previa de video en Active Storage

La generación de imágenes de vista previa de video ahora utiliza la detección de cambios de escena de FFmpeg para generar imágenes de vista previa más significativas. Anteriormente se utilizaba el primer fotograma del video y eso causaba problemas si el video se desvanecía desde negro. Este cambio requiere FFmpeg v3.4+.

### El procesador de variantes predeterminado de Active Storage cambió a `:vips`

Para nuevas aplicaciones, la transformación de imágenes utilizará libvips en lugar de ImageMagick. Esto reducirá el tiempo necesario para generar variantes, así como el uso de CPU y memoria, mejorando los tiempos de respuesta en aplicaciones que dependen de Active Storage para servir sus imágenes.

La opción `:mini_magick` no se está deprecando, por lo que está bien seguir usándola.

Para migrar una aplicación existente a libvips, establezca:
```ruby
Rails.application.config.active_storage.variant_processor = :vips
```

Luego deberás cambiar el código de transformación de imágenes existente a los macros `image_processing` y reemplazar las opciones de ImageMagick con las opciones de libvips.

#### Reemplazar resize con resize_to_limit

```diff
- variant(resize: "100x")
+ variant(resize_to_limit: [100, nil])
```

Si no haces esto, cuando cambies a vips verás este error: `no implicit conversion to float from string`.

#### Usar un array al recortar

```diff
- variant(crop: "1920x1080+0+0")
+ variant(crop: [0, 0, 1920, 1080])
```

Si no haces esto al migrar a vips, verás el siguiente error: `unable to call crop: you supplied 2 arguments, but operation needs 5`.

#### Ajustar los valores de recorte:

Vips es más estricto que ImageMagick cuando se trata de recortar:

1. No recortará si `x` y/o `y` son valores negativos. Ejemplo: `[-10, -10, 100, 100]`
2. No recortará si la posición (`x` o `y`) más la dimensión de recorte (`width`, `height`) es mayor que la imagen. Ejemplo: una imagen de 125x125 y un recorte de `[50, 50, 100, 100]`

Si no haces esto al migrar a vips, verás el siguiente error: `extract_area: bad extract area`

#### Ajustar el color de fondo utilizado para `resize_and_pad`

Vips utiliza negro como color de fondo predeterminado en `resize_and_pad`, en lugar de blanco como ImageMagick. Soluciónalo utilizando la opción `background`:

```diff
- variant(resize_and_pad: [300, 300])
+ variant(resize_and_pad: [300, 300, background: [255]])
```

#### Eliminar cualquier rotación basada en EXIF

Vips rotará automáticamente las imágenes utilizando el valor EXIF al procesar variantes. Si estabas almacenando valores de rotación de fotos cargadas por el usuario para aplicar la rotación con ImageMagick, debes dejar de hacerlo:

```diff
- variant(format: :jpg, rotate: rotation_value)
+ variant(format: :jpg)
```

#### Reemplazar monochrome con colourspace

Vips utiliza una opción diferente para crear imágenes monocromáticas:

```diff
- variant(monochrome: true)
+ variant(colourspace: "b-w")
```

#### Cambiar a opciones de libvips para comprimir imágenes

JPEG

```diff
- variant(strip: true, quality: 80, interlace: "JPEG", sampling_factor: "4:2:0", colorspace: "sRGB")
+ variant(saver: { strip: true, quality: 80, interlace: true })
```

PNG

```diff
- variant(strip: true, quality: 75)
+ variant(saver: { strip: true, compression: 9 })
```

WEBP

```diff
- variant(strip: true, quality: 75, define: { webp: { lossless: false, alpha_quality: 85, thread_level: 1 } })
+ variant(saver: { strip: true, quality: 75, lossless: false, alpha_q: 85, reduction_effort: 6, smart_subsample: true })
```

GIF

```diff
- variant(layers: "Optimize")
+ variant(saver: { optimize_gif_frames: true, optimize_gif_transparency: true })
```

#### Implementar en producción

Active Storage codifica en la URL de la imagen la lista de transformaciones que deben realizarse. Si tu aplicación está almacenando en caché estas URL, tus imágenes se romperán después de implementar el nuevo código en producción. Por esta razón, debes invalidar manualmente las claves de caché afectadas.

Por ejemplo, si tienes algo como esto en una vista:

```erb
<% @products.each do |product| %>
  <% cache product do %>
    <%= image_tag product.cover_photo.variant(resize: "200x") %>
  <% end %>
<% end %>
```

Puedes invalidar la caché tocando el producto o cambiando la clave de caché:

```erb
<% @products.each do |product| %>
  <% cache ["v2", product] do %>
    <%= image_tag product.cover_photo.variant(resize_to_limit: [200, nil]) %>
  <% end %>
<% end %>
```

### La versión de Rails ahora se incluye en el volcado del esquema de Active Record

Rails 7.0 cambió algunos valores predeterminados para algunos tipos de columnas. Para evitar que las aplicaciones que se actualizan de 6.1 a 7.0 carguen el esquema actual utilizando los nuevos valores predeterminados de 7.0, Rails ahora incluye la versión del framework en el volcado del esquema.

Antes de cargar el esquema por primera vez en Rails 7.0, asegúrate de ejecutar `rails app:update` para asegurarte de que la versión del esquema se incluya en el volcado del esquema.

El archivo de esquema se verá así:

```ruby
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[6.1].define(version: 2022_01_28_123512) do
```
NOTA: La primera vez que se volcó el esquema con Rails 7.0, verá muchos cambios en ese archivo, incluida
alguna información de columna. Asegúrese de revisar el nuevo contenido del archivo de esquema y confirmarlo en su repositorio.

Actualización de Rails 6.0 a Rails 6.1
-------------------------------------

Para obtener más información sobre los cambios realizados en Rails 6.1, consulte las [notas de la versión](6_1_release_notes.html).

### El valor de retorno de `Rails.application.config_for` ya no admite el acceso con claves de cadena.

Dado un archivo de configuración como este:

```yaml
# config/example.yml
development:
  options:
    key: value
```

```ruby
Rails.application.config_for(:example).options
```

Esto solía devolver un hash en el que podía acceder a los valores con claves de cadena. Eso se deprecó en 6.0 y ahora ya no funciona.

Puede llamar a `with_indifferent_access` en el valor de retorno de `config_for` si aún desea acceder a los valores con claves de cadena, por ejemplo:

```ruby
Rails.application.config_for(:example).with_indifferent_access.dig('options', 'key')
```

### El tipo de contenido de la respuesta al usar `respond_to#any`

El encabezado Content-Type devuelto en la respuesta puede diferir de lo que devolvía Rails 6.0,
más específicamente si su aplicación usa `respond_to { |format| format.any }`.
El tipo de contenido ahora se basará en el bloque dado en lugar del formato de la solicitud.

Ejemplo:

```ruby
def my_action
  respond_to do |format|
    format.any { render(json: { foo: 'bar' }) }
  end
end
```

```ruby
get('my_action.csv')
```

El comportamiento anterior devolvía un Content-Type de respuesta `text/csv`, lo cual es incorrecto ya que se está renderizando una respuesta JSON.
El comportamiento actual devuelve correctamente un Content-Type de respuesta `application/json`.

Si su aplicación depende del comportamiento incorrecto anterior, se recomienda especificar
los formatos que acepta su acción, es decir:

```ruby
format.any(:xml, :json) { render request.format.to_sym => @people }
```

### `ActiveSupport::Callbacks#halted_callback_hook` ahora recibe un segundo argumento

Active Support le permite anular el `halted_callback_hook` cada vez que un callback
detiene la cadena. Este método ahora recibe un segundo argumento que es el nombre del callback que se está deteniendo.
Si tiene clases que anulan este método, asegúrese de que acepten dos argumentos. Tenga en cuenta que este es un cambio que rompe la compatibilidad sin un ciclo de deprecación previo (por razones de rendimiento).

Ejemplo:

```ruby
class Book < ApplicationRecord
  before_save { throw(:abort) }
  before_create { throw(:abort) }

  def halted_callback_hook(filter, callback_name) # => Este método ahora acepta 2 argumentos en lugar de 1
    Rails.logger.info("No se pudo #{callback_name}r el libro")
  end
end
```

### El método de clase `helper` en los controladores utiliza `String#constantize`

Conceptualmente, antes de Rails 6.1

```ruby
helper "foo/bar"
```

resultaba en

```ruby
require_dependency "foo/bar_helper"
module_name = "foo/bar_helper".camelize
module_name.constantize
```

Ahora hace esto en su lugar:

```ruby
prefix = "foo/bar".camelize
"#{prefix}Helper".constantize
```

Este cambio es compatible con versiones anteriores para la mayoría de las aplicaciones, en cuyo caso no es necesario hacer nada.

Técnicamente, sin embargo, los controladores podrían configurar `helpers_path` para que apunte a un directorio en `$LOAD_PATH` que no estuviera en las rutas de carga automática. Ese caso de uso ya no es compatible de forma predeterminada. Si el módulo de ayuda no se puede cargar automáticamente, la aplicación es responsable de cargarlo antes de llamar a `helper`.

### La redirección a HTTPS desde HTTP ahora utilizará el código de estado HTTP 308

El código de estado HTTP predeterminado utilizado en `ActionDispatch::SSL` al redirigir solicitudes no GET/HEAD de HTTP a HTTPS se ha cambiado a `308` según se define en https://tools.ietf.org/html/rfc7538.

### Active Storage ahora requiere Image Processing

Al procesar variantes en Active Storage, ahora es necesario tener el [gem image_processing](https://github.com/janko/image_processing) incluido en lugar de usar directamente `mini_magick`. Image Processing está configurado de forma predeterminada para usar `mini_magick` en segundo plano, por lo que la forma más fácil de actualizar es reemplazar el gem `mini_magick` por el gem `image_processing` y asegurarse de eliminar el uso explícito de `combine_options` ya que ya no es necesario.

Para mayor legibilidad, es posible que desee cambiar las llamadas `resize` en bruto a las macros de `image_processing`. Por ejemplo, en lugar de:

```ruby
video.preview(resize: "100x100")
video.preview(resize: "100x100>")
video.preview(resize: "100x100^")
```

puede hacer respectivamente:

```ruby
video.preview(resize_to_fit: [100, 100])
video.preview(resize_to_limit: [100, 100])
video.preview(resize_to_fill: [100, 100])
```

### Nueva clase `ActiveModel::Error`

Ahora los errores son instancias de una nueva clase `ActiveModel::Error`, con cambios en
la API. Algunos de estos cambios pueden generar errores dependiendo de cómo manipule
los errores, mientras que otros mostrarán advertencias de deprecación para corregir en Rails 7.0.

Más información sobre este cambio y detalles sobre los cambios en la API se pueden
encontrar [en este PR](https://github.com/rails/rails/pull/32313).

Actualización de Rails 5.2 a Rails 6.0
-------------------------------------

Para obtener más información sobre los cambios realizados en Rails 6.0, consulte las [notas de la versión](6_0_release_notes.html).

### Uso de Webpacker
[Webpacker](https://github.com/rails/webpacker)
es el compilador de JavaScript predeterminado para Rails 6. Pero si estás actualizando la aplicación, no está activado de forma predeterminada.
Si quieres usar Webpacker, inclúyelo en tu Gemfile e instálalo:

```ruby
gem "webpacker"
```

```bash
$ bin/rails webpacker:install
```

### Forzar SSL

El método `force_ssl` en los controladores ha sido deprecado y se eliminará en
Rails 6.1. Se recomienda habilitar [`config.force_ssl`][] para hacer cumplir las conexiones HTTPS
en toda tu aplicación. Si necesitas eximir ciertos puntos finales
de la redirección, puedes usar [`config.ssl_options`][] para configurar ese comportamiento.


### Los metadatos de propósito y caducidad ahora están incrustados dentro de las cookies firmadas y encriptadas para aumentar la seguridad

Para mejorar la seguridad, Rails incrusta los metadatos de propósito y caducidad dentro del valor de las cookies firmadas o encriptadas.

Rails puede entonces frustrar los ataques que intentan copiar el valor firmado/encriptado
de una cookie y usarlo como el valor de otra cookie.

Estos nuevos metadatos incrustados hacen que esas cookies sean incompatibles con versiones de Rails anteriores a 6.0.

Si necesitas que tus cookies sean leídas por Rails 5.2 y anteriores, o aún estás validando tu implementación de 6.0 y quieres
poder revertir, establece
`Rails.application.config.action_dispatch.use_cookies_with_metadata` en `false`.

### Todos los paquetes npm se han movido al ámbito `@rails`

Si anteriormente estabas cargando alguno de los paquetes `actioncable`, `activestorage`,
o `rails-ujs` a través de npm/yarn, debes actualizar los nombres de estas
dependencias antes de poder actualizarlas a `6.0.0`:

```
actioncable   → @rails/actioncable
activestorage → @rails/activestorage
rails-ujs     → @rails/ujs
```

### Cambios en la API de JavaScript de Action Cable

El paquete de JavaScript de Action Cable se ha convertido de CoffeeScript
a ES2015, y ahora publicamos el código fuente en la distribución npm.

Esta versión incluye algunos cambios que rompen partes opcionales de la
API de JavaScript de Action Cable:

- La configuración del adaptador WebSocket y del adaptador de registro se ha movido
  de propiedades de `ActionCable` a propiedades de `ActionCable.adapters`.
  Si estás configurando estos adaptadores, necesitarás hacer
  estos cambios:

    ```diff
    -    ActionCable.WebSocket = MyWebSocket
    +    ActionCable.adapters.WebSocket = MyWebSocket
    ```

    ```diff
    -    ActionCable.logger = myLogger
    +    ActionCable.adapters.logger = myLogger
    ```

- Los métodos `ActionCable.startDebugging()` y `ActionCable.stopDebugging()`
  se han eliminado y se han reemplazado por la propiedad
  `ActionCable.logger.enabled`. Si estás usando estos métodos, necesitarás
  hacer estos cambios:

    ```diff
    -    ActionCable.startDebugging()
    +    ActionCable.logger.enabled = true
    ```

    ```diff
    -    ActionCable.stopDebugging()
    +    ActionCable.logger.enabled = false
    ```

### `ActionDispatch::Response#content_type` ahora devuelve el encabezado Content-Type sin modificaciones

Anteriormente, el valor devuelto por `ActionDispatch::Response#content_type` NO contenía la parte de conjunto de caracteres.
Este comportamiento ha cambiado para incluir la parte de conjunto de caracteres previamente omitida.

Si solo quieres el tipo MIME, utiliza `ActionDispatch::Response#media_type` en su lugar.

Antes:

```ruby
resp = ActionDispatch::Response.new(200, "Content-Type" => "text/csv; header=present; charset=utf-16")
resp.content_type #=> "text/csv; header=present"
```

Después:

```ruby
resp = ActionDispatch::Response.new(200, "Content-Type" => "text/csv; header=present; charset=utf-16")
resp.content_type #=> "text/csv; header=present; charset=utf-16"
resp.media_type   #=> "text/csv"
```

### Nueva configuración `config.hosts`

Rails ahora tiene una nueva configuración `config.hosts` por motivos de seguridad. Esta configuración
tiene como valor predeterminado `localhost` en desarrollo. Si usas otros dominios en desarrollo,
necesitas permitirlos de esta manera:

```ruby
# config/environments/development.rb

config.hosts << 'dev.myapp.com'
config.hosts << /[a-z0-9-]+\.myapp\.com/ # Opcionalmente, también se permite una expresión regular
```

Para otros entornos, `config.hosts` está vacío de forma predeterminada, lo que significa que Rails
no validará el host en absoluto. Opcionalmente, puedes agregarlos si deseas
validarlo en producción.

### Carga automática

La configuración predeterminada para Rails 6

```ruby
# config/application.rb

config.load_defaults 6.0
```

habilita el modo de carga automática `zeitwerk` en CRuby. En ese modo, la carga automática, la recarga y la carga ansiosa son gestionadas por [Zeitwerk](https://github.com/fxn/zeitwerk).

Si estás utilizando los valores predeterminados de una versión anterior de Rails, puedes habilitar zeitwerk de la siguiente manera:

```ruby
# config/application.rb

config.autoloader = :zeitwerk
```

#### API pública

En general, las aplicaciones no necesitan utilizar la API de Zeitwerk directamente. Rails configura las cosas según el contrato existente: `config.autoload_paths`, `config.cache_classes`, etc.

Si bien las aplicaciones deben adherirse a esa interfaz, el objeto de carga de Zeitwerk real se puede acceder como

```ruby
Rails.autoloaders.main
```

Eso puede ser útil si necesitas precargar clases de herencia de tabla única (STI) o configurar un inflector personalizado, por ejemplo.

#### Estructura del proyecto

Si la aplicación que se está actualizando se carga automáticamente correctamente, la estructura del proyecto debería ser compatible en su mayoría.

Sin embargo, el modo `classic` infiere los nombres de archivo a partir de los nombres de constante faltantes (`underscore`), mientras que el modo `zeitwerk` infiere los nombres de constante a partir de los nombres de archivo (`camelize`). Estos ayudantes no siempre son inversos entre sí, en particular si se involucran acrónimos. Por ejemplo, `"FOO".underscore` es `"foo"`, pero `"foo".camelize` es `"Foo"`, no `"FOO"`.
La compatibilidad se puede verificar con la tarea `zeitwerk:check`:

```bash
$ bin/rails zeitwerk:check
Espera, estoy cargando la aplicación.
¡Todo está bien!
```

#### require_dependency

Se han eliminado todos los casos conocidos de `require_dependency`, debes buscar en el proyecto y eliminarlos.

Si tu aplicación utiliza la herencia de tabla única, consulta la sección [Herencia de tabla única](autoloading_and_reloading_constants.html#single-table-inheritance) de la guía Autoloading and Reloading Constants (Modo Zeitwerk).

#### Nombres calificados en las definiciones de clases y módulos

Ahora puedes usar de manera robusta rutas constantes en las definiciones de clases y módulos:

```ruby
# La carga automática en el cuerpo de esta clase coincide ahora con la semántica de Ruby.
class Admin::UsersController < ApplicationController
  # ...
end
```

Un detalle a tener en cuenta es que, dependiendo del orden de ejecución, el cargador automático clásico a veces podía cargar `Foo::Wadus` en

```ruby
class Foo::Bar
  Wadus
end
```

Esto no coincide con la semántica de Ruby porque `Foo` no está en el anidamiento, y no funcionará en el modo `zeitwerk`. Si encuentras un caso así, puedes usar el nombre calificado `Foo::Wadus`:

```ruby
class Foo::Bar
  Foo::Wadus
end
```

o agregar `Foo` al anidamiento:

```ruby
module Foo
  class Bar
    Wadus
  end
end
```

#### Concerns

Puedes cargar automáticamente y cargar de manera anticipada desde una estructura estándar como

```
app/models
app/models/concerns
```

En ese caso, se asume que `app/models/concerns` es un directorio raíz (porque pertenece a las rutas de carga automática) y se ignora como espacio de nombres. Por lo tanto, `app/models/concerns/foo.rb` debe definir `Foo`, no `Concerns::Foo`.

El espacio de nombres `Concerns::` funcionaba con el cargador automático clásico como un efecto secundario de la implementación, pero en realidad no era un comportamiento deseado. Una aplicación que utiliza `Concerns::` debe cambiar el nombre de esas clases y módulos para poder ejecutarse en el modo `zeitwerk`.

#### Tener `app` en las rutas de carga automática

Algunos proyectos desean que algo como `app/api/base.rb` defina `API::Base` y agregan `app` a las rutas de carga automática para lograrlo en el modo `classic`. Dado que Rails agrega automáticamente todos los subdirectorios de `app` a las rutas de carga automática, tenemos otra situación en la que hay directorios raíz anidados, por lo que esa configuración ya no funciona. El mismo principio que explicamos anteriormente con `concerns`.

Si deseas mantener esa estructura, deberás eliminar el subdirectorio de las rutas de carga automática en un inicializador:

```ruby
ActiveSupport::Dependencies.autoload_paths.delete("#{Rails.root}/app/api")
```

#### Constantes cargadas automáticamente y espacios de nombres explícitos

Si se define un espacio de nombres en un archivo, como `Hotel` aquí:

```
app/models/hotel.rb         # Define Hotel.
app/models/hotel/pricing.rb # Define Hotel::Pricing.
```

la constante `Hotel` debe establecerse utilizando las palabras clave `class` o `module`. Por ejemplo:

```ruby
class Hotel
end
```

es correcto.

Alternativas como

```ruby
Hotel = Class.new
```

o

```ruby
Hotel = Struct.new
```

no funcionarán, los objetos secundarios como `Hotel::Pricing` no se encontrarán.

Esta restricción solo se aplica a los espacios de nombres explícitos. Las clases y módulos que no definen un espacio de nombres se pueden definir utilizando esos métodos.

#### Un archivo, una constante (en el mismo nivel superior)

En el modo `classic`, técnicamente se podían definir varias constantes en el mismo nivel superior y todas se recargaban. Por ejemplo, dado

```ruby
# app/models/foo.rb

class Foo
end

class Bar
end
```

mientras que `Bar` no se podía cargar automáticamente, cargar `Foo` marcaría a `Bar` como cargado automáticamente también. Esto no ocurre en el modo `zeitwerk`, debes mover `Bar` a su propio archivo `bar.rb`. Un archivo, una constante.

Esto solo se aplica a las constantes en el mismo nivel superior como en el ejemplo anterior. Las clases y módulos internos están bien. Por ejemplo, considera

```ruby
# app/models/foo.rb

class Foo
  class InnerClass
  end
end
```

Si la aplicación recarga `Foo`, también recargará `Foo::InnerClass`.

#### Spring y el entorno `test`

Spring recarga el código de la aplicación si algo cambia. En el entorno `test`, debes habilitar la recarga para que funcione:

```ruby
# config/environments/test.rb

config.cache_classes = false
```

De lo contrario, obtendrás este error:

```
la recarga está desactivada porque config.cache_classes es true
```

#### Bootsnap

Bootsnap debe ser al menos la versión 1.4.2.

Además de eso, Bootsnap necesita deshabilitar la caché de iseq debido a un error en el intérprete si se ejecuta Ruby 2.5. Asegúrate de depender al menos de Bootsnap 1.4.4 en ese caso.

#### `config.add_autoload_paths_to_load_path`

El nuevo punto de configuración [`config.add_autoload_paths_to_load_path`][] es `true` de forma predeterminada por compatibilidad con versiones anteriores, pero te permite optar por no agregar las rutas de carga automática a `$LOAD_PATH`.

Esto tiene sentido en la mayoría de las aplicaciones, ya que nunca debes requerir un archivo en `app/models`, por ejemplo, y Zeitwerk solo utiliza nombres de archivo absolutos internamente.
Al optar por la opción de exclusión, se optimizan las búsquedas en `$LOAD_PATH` (menos directorios que verificar) y se ahorra trabajo y consumo de memoria en Bootsnap, ya que no necesita construir un índice para estos directorios.

#### Seguridad en hilos

En el modo clásico, la carga automática de constantes no es segura en hilos, aunque Rails tiene bloqueos implementados, por ejemplo, para hacer que las solicitudes web sean seguras en hilos cuando la carga automática está habilitada, como es común en el entorno de desarrollo.

La carga automática de constantes es segura en hilos en el modo `zeitwerk`. Por ejemplo, ahora se puede cargar automáticamente en scripts multihilo ejecutados por el comando `runner`.

#### Comodines en config.autoload_paths

Tenga cuidado con las configuraciones como:

```ruby
config.autoload_paths += Dir["#{config.root}/lib/**/"]
```

Cada elemento de `config.autoload_paths` debe representar el espacio de nombres de nivel superior (`Object`) y no pueden estar anidados en consecuencia (con la excepción de los directorios `concerns` explicados anteriormente).

Para solucionar esto, simplemente elimine los comodines:

```ruby
config.autoload_paths << "#{config.root}/lib"
```

#### La carga ansiosa y la carga automática son consistentes

En el modo `clásico`, si `app/models/foo.rb` define `Bar`, no podrá cargar automáticamente ese archivo, pero la carga ansiosa funcionará porque carga archivos de forma recursiva a ciegas. Esto puede ser una fuente de errores si se prueban las cosas primero con carga ansiosa, la ejecución puede fallar más tarde con la carga automática.

En el modo `zeitwerk`, ambos modos de carga son consistentes, fallan y generan errores en los mismos archivos.

#### Cómo usar el cargador automático clásico en Rails 6

Las aplicaciones pueden cargar las configuraciones predeterminadas de Rails 6 y seguir utilizando el cargador automático clásico configurando `config.autoloader` de esta manera:

```ruby
# config/application.rb

config.load_defaults 6.0
config.autoloader = :classic
```

Cuando se utiliza el cargador automático clásico en una aplicación de Rails 6, se recomienda establecer el nivel de concurrencia en 1 en el entorno de desarrollo, para los servidores web y los procesadores en segundo plano, debido a las preocupaciones de seguridad en hilos.

### Cambio en el comportamiento de asignación de Active Storage

Con la configuración predeterminada para Rails 5.2, al asignar a una colección de archivos adjuntos declarados con `has_many_attached`, se agregan nuevos archivos:

```ruby
class User < ApplicationRecord
  has_many_attached :highlights
end

user.highlights.attach(filename: "funky.jpg", ...)
user.highlights.count # => 1

blob = ActiveStorage::Blob.create_after_upload!(filename: "town.jpg", ...)
user.update!(highlights: [ blob ])

user.highlights.count # => 2
user.highlights.first.filename # => "funky.jpg"
user.highlights.second.filename # => "town.jpg"
```

Con la configuración predeterminada para Rails 6.0, al asignar a una colección de archivos adjuntos se reemplazan los archivos existentes en lugar de agregar nuevos. Esto coincide con el comportamiento de Active Record al asignar a una asociación de colección:

```ruby
user.highlights.attach(filename: "funky.jpg", ...)
user.highlights.count # => 1

blob = ActiveStorage::Blob.create_after_upload!(filename: "town.jpg", ...)
user.update!(highlights: [ blob ])

user.highlights.count # => 1
user.highlights.first.filename # => "town.jpg"
```

`#attach` se puede usar para agregar nuevos archivos adjuntos sin eliminar los existentes:

```ruby
blob = ActiveStorage::Blob.create_after_upload!(filename: "town.jpg", ...)
user.highlights.attach(blob)

user.highlights.count # => 2
user.highlights.first.filename # => "funky.jpg"
user.highlights.second.filename # => "town.jpg"
```

Las aplicaciones existentes pueden optar por este nuevo comportamiento configurando [`config.active_storage.replace_on_assign_to_many`][] en `true`. El comportamiento anterior se eliminará en Rails 7.0 y se eliminará por completo en Rails 7.1.

### Aplicaciones de manejo de excepciones personalizadas

Las cabeceras de solicitud `Accept` o `Content-Type` no válidas ahora generarán una excepción. La configuración predeterminada [`config.exceptions_app`][] maneja específicamente ese error y lo compensa. Las aplicaciones de excepciones personalizadas también deberán manejar ese error, de lo contrario, Rails utilizará la aplicación de excepciones de respaldo, que devuelve un `500 Internal Server Error`.

Actualización de Rails 5.1 a Rails 5.2
-------------------------------------

Para obtener más información sobre los cambios realizados en Rails 5.2, consulte las [notas de la versión](5_2_release_notes.html).

### Bootsnap

Rails 5.2 agrega la gema bootsnap en el [Gemfile de la aplicación recién generada](https://github.com/rails/rails/pull/29313). El comando `app:update` lo configura en `boot.rb`. Si desea usarlo, agreguelo al Gemfile:

```ruby
# Reduce los tiempos de arranque mediante el almacenamiento en caché; requerido en config/boot.rb
gem 'bootsnap', require: false
```

De lo contrario, cambie `boot.rb` para no usar bootsnap.

### El vencimiento en las cookies firmadas o encriptadas ahora está incrustado en los valores de las cookies

Para mejorar la seguridad, Rails ahora incrusta la información de vencimiento también en el valor de las cookies firmadas o encriptadas.

Esta nueva información incrustada hace que esas cookies sean incompatibles con versiones de Rails anteriores a 5.2.

Si necesita que sus cookies sean leídas por la versión 5.1 y anteriores, o aún está validando su implementación de la versión 5.2 y desea permitir el retroceso, configure `Rails.application.config.action_dispatch.use_authenticated_cookie_encryption` en `false`.

Actualización de Rails 5.0 a Rails 5.1
-------------------------------------

Para obtener más información sobre los cambios realizados en Rails 5.1, consulte las [notas de la versión](5_1_release_notes.html).

### La clase `HashWithIndifferentAccess` de nivel superior está obsoleta

Si su aplicación utiliza la clase `HashWithIndifferentAccess` de nivel superior, debe cambiar lentamente su código para utilizar en su lugar `ActiveSupport::HashWithIndifferentAccess`.
Solo está suavemente obsoleto, lo que significa que su código no se romperá en este momento y no se mostrará ninguna advertencia de obsolescencia, pero esta constante se eliminará en el futuro.

Además, si tiene documentos YAML bastante antiguos que contienen volcados de dichos objetos, es posible que deba cargarlos y volcarlos nuevamente para asegurarse de que hagan referencia a la constante correcta y que su carga no se rompa en el futuro.

### `application.secrets` ahora se carga con todas las claves como símbolos

Si su aplicación almacena una configuración anidada en `config/secrets.yml`, todas las claves ahora se cargan como símbolos, por lo que el acceso utilizando cadenas debe cambiarse.

De:

```ruby
Rails.application.secrets[:smtp_settings]["address"]
```

A:

```ruby
Rails.application.secrets[:smtp_settings][:address]
```

### Se eliminó el soporte obsoleto de `:text` y `:nothing` en `render`

Si sus controladores están utilizando `render :text`, ya no funcionarán. El nuevo método para renderizar texto con el tipo MIME `text/plain` es utilizar `render :plain`.

De manera similar, se eliminó `render :nothing` y debe utilizar el método `head` para enviar respuestas que contengan solo encabezados. Por ejemplo, `head :ok` envía una respuesta 200 sin cuerpo para renderizar.

### Se eliminó el soporte obsoleto de `redirect_to :back`

En Rails 5.0, `redirect_to :back` fue declarado obsoleto. En Rails 5.1, se eliminó por completo.

Como alternativa, use `redirect_back`. Es importante tener en cuenta que `redirect_back` también acepta una opción `fallback_location` que se utilizará en caso de que falte el `HTTP_REFERER`.

```ruby
redirect_back(fallback_location: root_path)
```

Actualización de Rails 4.2 a Rails 5.0
-------------------------------------

Para obtener más información sobre los cambios realizados en Rails 5.0, consulte las [notas de la versión](5_0_release_notes.html).

### Se requiere Ruby 2.2.2+

A partir de Ruby on Rails 5.0, solo se admite la versión de Ruby 2.2.2+. Asegúrese de tener la versión de Ruby 2.2.2 o superior antes de continuar.

### Los modelos de Active Record ahora heredan de ApplicationRecord de forma predeterminada

En Rails 4.2, un modelo de Active Record hereda de `ActiveRecord::Base`. En Rails 5.0, todos los modelos heredan de `ApplicationRecord`.

`ApplicationRecord` es una nueva superclase para todos los modelos de la aplicación, análoga a los controladores de la aplicación que heredan de `ApplicationController` en lugar de `ActionController::Base`. Esto proporciona a las aplicaciones un único lugar para configurar el comportamiento del modelo en toda la aplicación.

Cuando actualice de Rails 4.2 a Rails 5.0, debe crear un archivo `application_record.rb` en `app/models/` y agregar el siguiente contenido:

```ruby
class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true
end
```

Luego asegúrese de que todos sus modelos hereden de él.

### Detención de cadenas de devolución de llamada mediante `throw(:abort)`

En Rails 4.2, cuando una devolución de llamada 'before' devuelve `false` en Active Record y Active Model, se detiene toda la cadena de devolución de llamada. En otras palabras, las devoluciones de llamada 'before' sucesivas no se ejecutan y la acción envuelta en devoluciones de llamada tampoco se ejecuta.

En Rails 5.0, devolver `false` en una devolución de llamada de Active Record o Active Model no tendrá este efecto secundario de detener la cadena de devolución de llamada. En su lugar, las cadenas de devolución de llamada deben detenerse explícitamente llamando a `throw(:abort)`.

Cuando actualice de Rails 4.2 a Rails 5.0, devolver `false` en ese tipo de devoluciones de llamada seguirá deteniendo la cadena de devolución de llamada, pero recibirá una advertencia de obsolescencia sobre este próximo cambio.

Cuando esté listo, puede optar por el nuevo comportamiento y eliminar la advertencia de obsolescencia agregando la siguiente configuración a su `config/application.rb`:

```ruby
ActiveSupport.halt_callback_chains_on_return_false = false
```

Tenga en cuenta que esta opción no afectará las devoluciones de llamada de Active Support, ya que nunca detuvieron la cadena cuando se devolvía cualquier valor.

Consulte [#17227](https://github.com/rails/rails/pull/17227) para obtener más detalles.

### ActiveJob ahora hereda de ApplicationJob de forma predeterminada

En Rails 4.2, un Active Job hereda de `ActiveJob::Base`. En Rails 5.0, este comportamiento ha cambiado y ahora hereda de `ApplicationJob`.

Cuando actualice de Rails 4.2 a Rails 5.0, debe crear un archivo `application_job.rb` en `app/jobs/` y agregar el siguiente contenido:

```ruby
class ApplicationJob < ActiveJob::Base
end
```

Luego asegúrese de que todas sus clases de trabajo hereden de él.

Consulte [#19034](https://github.com/rails/rails/pull/19034) para obtener más detalles.

### Pruebas de controladores de Rails

#### Extracción de algunos métodos auxiliares a `rails-controller-testing`

`assigns` y `assert_template` se han extraído a la gema `rails-controller-testing`. Para seguir utilizando estos métodos en sus pruebas de controladores, agregue `gem 'rails-controller-testing'` a su `Gemfile`.

Si está utilizando RSpec para las pruebas, consulte la documentación de la gema para ver la configuración adicional requerida.

#### Nuevo comportamiento al cargar archivos

Si está utilizando `ActionDispatch::Http::UploadedFile` en sus pruebas para cargar archivos, deberá cambiar para usar la clase similar `Rack::Test::UploadedFile`.
Ver [#26404](https://github.com/rails/rails/issues/26404) para más detalles.

### La carga automática está desactivada después de arrancar en el entorno de producción

La carga automática ahora está desactivada después de arrancar en el entorno de producción de forma predeterminada.

La carga ansiosa de la aplicación es parte del proceso de arranque, por lo que las constantes de nivel superior están bien y aún se cargan automáticamente, no es necesario requerir sus archivos.

Las constantes en lugares más profundos que solo se ejecutan en tiempo de ejecución, como los cuerpos de los métodos regulares, también están bien porque el archivo que las define se habrá cargado ansiosamente durante el arranque.

Para la gran mayoría de las aplicaciones, este cambio no requiere ninguna acción. Pero en el caso muy raro de que su aplicación necesite carga automática mientras se ejecuta en producción, establezca `Rails.application.config.enable_dependency_loading` en true.

### Serialización XML

`ActiveModel::Serializers::Xml` se ha extraído de Rails a la gema `activemodel-serializers-xml`. Para seguir utilizando la serialización XML en su aplicación, agregue `gem 'activemodel-serializers-xml'` a su `Gemfile`.

### Se eliminó el soporte para el adaptador de base de datos `mysql` heredado

Rails 5 elimina el soporte para el adaptador de base de datos `mysql` heredado. La mayoría de los usuarios deberían poder usar `mysql2` en su lugar. Se convertirá en una gema separada cuando encontremos a alguien que la mantenga.

### Se eliminó el soporte para el depurador

`debugger` no es compatible con Ruby 2.2, que es requerido por Rails 5. Use `byebug` en su lugar.

### Use `bin/rails` para ejecutar tareas y pruebas

Rails 5 agrega la capacidad de ejecutar tareas y pruebas a través de `bin/rails` en lugar de rake. En general, estos cambios son paralelos a rake, pero algunos se portaron por completo.

Para usar el nuevo ejecutor de pruebas, simplemente escriba `bin/rails test`.

`rake dev:cache` ahora es `bin/rails dev:cache`.

Ejecute `bin/rails` dentro del directorio raíz de su aplicación para ver la lista de comandos disponibles.

### `ActionController::Parameters` ya no hereda de `HashWithIndifferentAccess`

Llamar a `params` en su aplicación ahora devolverá un objeto en lugar de un hash. Si sus parámetros ya están permitidos, no necesitará realizar ningún cambio. Si está utilizando `map` y otros métodos que dependen de poder leer el hash independientemente de `permitted?`, deberá actualizar su aplicación para primero permitir y luego convertirlo en un hash.

```ruby
params.permit([:proceed_to, :return_to]).to_h
```

### `protect_from_forgery` ahora tiene `prepend: false` como valor predeterminado

`protect_from_forgery` ahora tiene `prepend: false` como valor predeterminado, lo que significa que se insertará en la cadena de llamadas en el punto en el que lo llame en su aplicación. Si desea que `protect_from_forgery` siempre se ejecute primero, debe cambiar su aplicación para usar `protect_from_forgery prepend: true`.

### El controlador de plantillas predeterminado ahora es RAW

Los archivos sin un controlador de plantillas en su extensión se renderizarán utilizando el controlador raw. Anteriormente, Rails renderizaba los archivos utilizando el controlador de plantillas ERB.

Si no desea que su archivo se maneje a través del controlador raw, debe agregar una extensión a su archivo que pueda ser analizada por el controlador de plantillas correspondiente.

### Se agregó la coincidencia de comodines para las dependencias de plantillas

Ahora puede usar la coincidencia de comodines para las dependencias de sus plantillas. Por ejemplo, si estaba definiendo sus plantillas de la siguiente manera:

```erb
<% # Dependencia de plantilla: recordings/threads/events/subscribers_changed %>
<% # Dependencia de plantilla: recordings/threads/events/completed %>
<% # Dependencia de plantilla: recordings/threads/events/uncompleted %>
```

Ahora solo puede llamar a la dependencia una vez con un comodín.

```erb
<% # Dependencia de plantilla: recordings/threads/events/* %>
```

### `ActionView::Helpers::RecordTagHelper` se movió a la gema externa (record_tag_helper)

`content_tag_for` y `div_for` se han eliminado a favor de simplemente usar `content_tag`. Para seguir utilizando los métodos antiguos, agregue la gema `record_tag_helper` a su `Gemfile`:

```ruby
gem 'record_tag_helper', '~> 1.0'
```

Ver [#18411](https://github.com/rails/rails/pull/18411) para más detalles.

### Se eliminó el soporte para la gema `protected_attributes`

La gema `protected_attributes` ya no es compatible con Rails 5.

### Se eliminó el soporte para la gema `activerecord-deprecated_finders`

La gema `activerecord-deprecated_finders` ya no es compatible con Rails 5.

### El orden de prueba predeterminado de `ActiveSupport::TestCase` ahora es aleatorio

Cuando se ejecutan pruebas en su aplicación, el orden predeterminado ahora es `:random` en lugar de `:sorted`. Use la siguiente opción de configuración para volver a establecerlo en `:sorted`.

```ruby
# config/environments/test.rb
Rails.application.configure do
  config.active_support.test_order = :sorted
end
```

### `ActionController::Live` se convirtió en un `Concern`

Si incluye `ActionController::Live` en otro módulo que se incluye en su controlador, también debe extender el módulo con `ActiveSupport::Concern`. Alternativamente, puede usar el gancho `self.included` para incluir `ActionController::Live` directamente en el controlador una vez que se incluya `StreamingSupport`.

Esto significa que si su aplicación solía tener su propio módulo de transmisión, el siguiente código se rompería en producción:
```ruby
# Esta es una solución alternativa para controladores en streaming que realizan autenticación con Warden/Devise.
# Ver https://github.com/plataformatec/devise/issues/2332
# Autenticar en el enrutador es otra solución como se sugiere en ese problema.
class StreamingSupport
  include ActionController::Live # esto no funcionará en producción para Rails 5
  # extend ActiveSupport::Concern # a menos que descomentes esta línea.

  def process(name)
    super(name)
  rescue ArgumentError => e
    if e.message == 'uncaught throw :warden'
      throw :warden
    else
      raise e
    end
  end
end
```

### Nuevas configuraciones predeterminadas del framework

#### Opción `belongs_to` requerida por defecto en Active Record

`belongs_to` ahora generará un error de validación de forma predeterminada si la asociación no está presente.

Esto se puede desactivar por asociación con `optional: true`.

Esta configuración predeterminada se configurará automáticamente en nuevas aplicaciones. Si una aplicación existente
desea agregar esta característica, deberá activarla en un inicializador:

```ruby
config.active_record.belongs_to_required_by_default = true
```

La configuración es global de forma predeterminada para todos tus modelos, pero puedes
anularla en cada modelo. Esto te ayudará a migrar todos tus modelos para que tengan sus
asociaciones requeridas de forma predeterminada.

```ruby
class Book < ApplicationRecord
  # el modelo aún no está listo para tener su asociación requerida de forma predeterminada

  self.belongs_to_required_by_default = false
  belongs_to(:author)
end

class Car < ApplicationRecord
  # el modelo está listo para tener su asociación requerida de forma predeterminada

  self.belongs_to_required_by_default = true
  belongs_to(:pilot)
end
```

#### Tokens CSRF por formulario

Rails 5 ahora admite tokens CSRF por formulario para mitigar ataques de inyección de código en formularios
creados por JavaScript. Con esta opción activada, cada formulario en tu aplicación tendrá su
propio token CSRF específico para la acción y el método de ese formulario.

```ruby
config.action_controller.per_form_csrf_tokens = true
```

#### Protección contra falsificaciones con verificación de origen

Ahora puedes configurar tu aplicación para verificar si el encabezado HTTP `Origin` debe ser verificado
contra el origen del sitio como una defensa CSRF adicional. Establece lo siguiente en tu configuración para
activarlo:

```ruby
config.action_controller.forgery_protection_origin_check = true
```

#### Permitir la configuración del nombre de la cola de Action Mailer

El nombre predeterminado de la cola de correo es `mailers`. Esta opción de configuración te permite cambiar globalmente
el nombre de la cola. Establece lo siguiente en tu configuración:

```ruby
config.action_mailer.deliver_later_queue_name = :new_queue_name
```

#### Soporte para fragmentos en caché en las vistas de Action Mailer

Establece [`config.action_mailer.perform_caching`][] en tu configuración para determinar si las vistas de Action Mailer
deben admitir el almacenamiento en caché.

```ruby
config.action_mailer.perform_caching = true
```

#### Configurar la salida de `db:structure:dump`

Si estás utilizando `schema_search_path` u otras extensiones de PostgreSQL, puedes controlar cómo se vuelca el esquema.
Establece `:all` para generar todos los volcados, o `:schema_search_path` para generar desde el esquema de búsqueda de esquemas.

```ruby
config.active_record.dump_schemas = :all
```

#### Configurar opciones SSL para habilitar HSTS con subdominios

Establece lo siguiente en tu configuración para habilitar HSTS cuando se usen subdominios:

```ruby
config.ssl_options = { hsts: { subdomains: true } }
```

#### Preservar la zona horaria del receptor

Cuando uses Ruby 2.4, puedes preservar la zona horaria del receptor al llamar a `to_time`.

```ruby
ActiveSupport.to_time_preserves_timezone = false
```

### Cambios en la serialización JSON/JSONB

En Rails 5.0, la forma en que se serializan y deserializan los atributos JSON/JSONB ha cambiado. Ahora, si
asignas una columna igual a una `String`, Active Record ya no convertirá esa cadena
en un `Hash`, y en su lugar solo devolverá la cadena. Esto no se limita al código
que interactúa con modelos, sino que también afecta a la configuración de columna `:default` en `db/schema.rb`.
Se recomienda no asignar columnas igual a una `String`, sino pasar un `Hash`
en su lugar, que se convertirá automáticamente en una cadena JSON y viceversa.

Actualización de Rails 4.1 a Rails 4.2
-------------------------------------

### Consola web

Primero, agrega `gem 'web-console', '~> 2.0'` al grupo `:development` en tu `Gemfile` y ejecuta `bundle install` (no se incluirá cuando actualices Rails). Una vez instalado, simplemente puedes agregar una referencia al ayudante de la consola (es decir, `<%= console %>`) en cualquier vista en la que desees habilitarlo. También se proporcionará una consola en cualquier página de error que veas en tu entorno de desarrollo.

### Responders

`respond_with` y los métodos `respond_to` a nivel de clase se han extraído a la gema `responders`. Para usarlos, simplemente agrega `gem 'responders', '~> 2.0'` a tu `Gemfile`. Las llamadas a `respond_with` y `respond_to` (nuevamente, a nivel de clase) ya no funcionarán sin haber incluido la gema `responders` en tus dependencias.
```ruby
# app/controllers/users_controller.rb

class UsersController < ApplicationController
  respond_to :html, :json

  def show
    @user = User.find(params[:id])
    respond_with @user
  end
end
```

La instancia de `respond_to` no se ve afectada y no requiere la gema adicional:

```ruby
# app/controllers/users_controller.rb

class UsersController < ApplicationController
  def show
    @user = User.find(params[:id])
    respond_to do |format|
      format.html
      format.json { render json: @user }
    end
  end
end
```

Ver [#16526](https://github.com/rails/rails/pull/16526) para más detalles.

### Manejo de errores en callbacks de transacciones

Actualmente, Active Record suprime los errores generados dentro de los callbacks `after_rollback` o `after_commit` y solo los imprime en los registros. En la próxima versión, estos errores ya no se suprimirán. En su lugar, los errores se propagarán normalmente como en otros callbacks de Active Record.

Cuando defines un callback `after_rollback` o `after_commit`, recibirás una advertencia de deprecación sobre este cambio próximo. Cuando estés listo, puedes optar por el nuevo comportamiento y eliminar la advertencia de deprecación agregando la siguiente configuración a tu `config/application.rb`:

```ruby
config.active_record.raise_in_transactional_callbacks = true
```

Ver [#14488](https://github.com/rails/rails/pull/14488) y [#16537](https://github.com/rails/rails/pull/16537) para más detalles.

### Orden de los casos de prueba

En Rails 5.0, los casos de prueba se ejecutarán en orden aleatorio de forma predeterminada. En anticipación a este cambio, Rails 4.2 introdujo una nueva opción de configuración `active_support.test_order` para especificar explícitamente el orden de las pruebas. Esto te permite bloquear el comportamiento actual estableciendo la opción en `:sorted`, u optar por el comportamiento futuro estableciendo la opción en `:random`.

Si no especificas un valor para esta opción, se emitirá una advertencia de deprecación. Para evitar esto, agrega la siguiente línea a tu entorno de prueba:

```ruby
# config/environments/test.rb
Rails.application.configure do
  config.active_support.test_order = :sorted # o `:random` si prefieres
end
```

### Atributos serializados

Cuando usas un codificador personalizado (por ejemplo, `serialize :metadata, JSON`), asignar `nil` a un atributo serializado lo guardará en la base de datos como `NULL` en lugar de pasar el valor `nil` a través del codificador (por ejemplo, `"null"` cuando se usa el codificador `JSON`).

### Nivel de registro en producción

En Rails 5, el nivel de registro predeterminado para el entorno de producción se cambiará a `:debug` (en lugar de `:info`). Para mantener el valor predeterminado actual, agrega la siguiente línea a tu `production.rb`:

```ruby
# Establece en `:info` para que coincida con el valor predeterminado actual, o establece en `:debug` para optar por el valor predeterminado futuro.
config.log_level = :info
```

### `after_bundle` en plantillas de Rails

Si tienes una plantilla de Rails que agrega todos los archivos al control de versiones, fallará al agregar los binstubs generados porque se ejecuta antes de Bundler:

```ruby
# template.rb
generate(:scaffold, "person name:string")
route "root to: 'people#index'"
rake("db:migrate")

git :init
git add: "."
git commit: %Q{ -m 'Initial commit' }
```

Ahora puedes envolver las llamadas `git` en un bloque `after_bundle`. Se ejecutará después de que se hayan generado los binstubs.

```ruby
# template.rb
generate(:scaffold, "person name:string")
route "root to: 'people#index'"
rake("db:migrate")

after_bundle do
  git :init
  git add: "."
  git commit: %Q{ -m 'Initial commit' }
end
```

### Sanitizador HTML de Rails

Hay una nueva opción para sanitizar fragmentos de HTML en tus aplicaciones. El enfoque antiguo de html-scanner ahora está oficialmente en desuso a favor de [`Rails HTML Sanitizer`](https://github.com/rails/rails-html-sanitizer).

Esto significa que los métodos `sanitize`, `sanitize_css`, `strip_tags` y `strip_links` están respaldados por una nueva implementación.

Este nuevo sanitizador utiliza [Loofah](https://github.com/flavorjones/loofah) internamente. Loofah, a su vez, utiliza Nokogiri, que envuelve analizadores XML escritos en C y Java, por lo que la sanitización debería ser más rápida sin importar qué versión de Ruby uses.

La nueva versión actualiza `sanitize`, por lo que puede recibir un `Loofah::Scrubber` para una limpieza potente.
[Consulta algunos ejemplos de scrubbers aquí](https://github.com/flavorjones/loofah#loofahscrubber).

También se han agregado dos nuevos scrubbers: `PermitScrubber` y `TargetScrubber`.
Lee el [readme de la gema](https://github.com/rails/rails-html-sanitizer) para obtener más información.

La documentación de `PermitScrubber` y `TargetScrubber` explica cómo puedes tener un control completo sobre cuándo y cómo se deben eliminar los elementos.

Si tu aplicación necesita usar la implementación antigua del sanitizador, incluye `rails-deprecated_sanitizer` en tu `Gemfile`:

```ruby
gem 'rails-deprecated_sanitizer'
```

### Pruebas DOM de Rails

El módulo [`TagAssertions`](https://api.rubyonrails.org/v4.1/classes/ActionDispatch/Assertions/TagAssertions.html) (que contiene métodos como `assert_tag`), [ha sido deprecado](https://github.com/rails/rails/blob/6061472b8c310158a2a2e8e9a6b81a1aef6b60fe/actionpack/lib/action_dispatch/testing/assertions/dom.rb) a favor de los métodos `assert_select` del módulo `SelectorAssertions`, que se ha extraído a la [gema rails-dom-testing](https://github.com/rails/rails-dom-testing).

### Tokens de autenticidad enmascarados

Para mitigar los ataques SSL, `form_authenticity_token` ahora está enmascarado para que varíe con cada solicitud. Por lo tanto, los tokens se validan desenmascarando y luego descifrando. Como resultado, cualquier estrategia para verificar solicitudes de formularios no pertenecientes a Rails que dependa de un token CSRF de sesión estático debe tener esto en cuenta.
### Action Mailer

Anteriormente, llamar a un método de mailer en una clase de mailer resultaba en la ejecución directa del método de instancia correspondiente. Con la introducción de Active Job y `#deliver_later`, esto ya no es cierto. En Rails 4.2, la invocación de los métodos de instancia se pospone hasta que se llame a `deliver_now` o `deliver_later`. Por ejemplo:

```ruby
class Notifier < ActionMailer::Base
  def notify(user, ...)
    puts "Llamado"
    mail(to: user.email, ...)
  end
end
```

```ruby
mail = Notifier.notify(user, ...) # Notifier#notify aún no se ha llamado en este punto
mail = mail.deliver_now           # Imprime "Llamado"
```

Esto no debería resultar en ninguna diferencia notable para la mayoría de las aplicaciones. Sin embargo, si necesitas que algunos métodos que no son de mailer se ejecuten de forma sincrónica y anteriormente confiabas en el comportamiento de proxy sincrónico, debes definirlos como métodos de clase en la clase de mailer directamente:

```ruby
class Notifier < ActionMailer::Base
  def self.broadcast_notifications(users, ...)
    users.each { |user| Notifier.notify(user, ...) }
  end
end
```

### Soporte para claves foráneas

El DSL de migración se ha ampliado para admitir definiciones de claves foráneas. Si has estado utilizando la gema Foreigner, es posible que desees considerar eliminarla. Ten en cuenta que el soporte de claves foráneas de Rails es un subconjunto de Foreigner. Esto significa que no todas las definiciones de Foreigner pueden ser reemplazadas completamente por su contraparte DSL de migración de Rails.

El procedimiento de migración es el siguiente:

1. Elimina `gem "foreigner"` del archivo `Gemfile`.
2. Ejecuta `bundle install`.
3. Ejecuta `bin/rake db:schema:dump`.
4. Asegúrate de que `db/schema.rb` contenga todas las definiciones de claves foráneas con las opciones necesarias.

Actualización de Rails 4.0 a Rails 4.1
-------------------------------------

### Protección CSRF desde etiquetas `<script>` remotas

O, "¡¿qué?! ¡mis pruebas están fallando!" o "¡mi widget `<script>` está roto!"

La protección contra falsificación de solicitudes entre sitios (CSRF) ahora también cubre las solicitudes GET con respuestas JavaScript. Esto evita que un sitio de terceros haga referencia de forma remota a tu JavaScript con una etiqueta `<script>` para extraer datos sensibles.

Esto significa que tus pruebas funcionales e de integración que usan

```ruby
get :index, format: :js
```

ahora activarán la protección CSRF. Cambia a

```ruby
xhr :get, :index, format: :js
```

para probar explícitamente una `XmlHttpRequest`.

NOTA: Tus propias etiquetas `<script>` también se tratan como de origen cruzado y se bloquean de forma predeterminada. Si realmente deseas cargar JavaScript desde etiquetas `<script>`, ahora debes omitir explícitamente la protección CSRF en esas acciones.

### Spring

Si deseas usar Spring como tu pre-cargador de aplicaciones, debes:

1. Agregar `gem 'spring', group: :development` a tu archivo `Gemfile`.
2. Instalar Spring usando `bundle install`.
3. Generar el binstub de Spring con `bundle exec spring binstub`.

NOTA: Las tareas de rake definidas por el usuario se ejecutarán en el entorno `development` de forma predeterminada. Si deseas que se ejecuten en otros entornos, consulta el [README de Spring](https://github.com/rails/spring#rake).

### `config/secrets.yml`

Si deseas utilizar la nueva convención `secrets.yml` para almacenar los secretos de tu aplicación, debes:

1. Crear un archivo `secrets.yml` en tu carpeta `config` con el siguiente contenido:

    ```yaml
    development:
      secret_key_base:

    test:
      secret_key_base:

    production:
      secret_key_base: <%= ENV["SECRET_KEY_BASE"] %>
    ```

2. Utiliza tu `secret_key_base` existente del inicializador `secret_token.rb` para establecer la variable de entorno `SECRET_KEY_BASE` para los usuarios que ejecutan la aplicación Rails en producción. Alternativamente, simplemente puedes copiar el `secret_key_base` existente del inicializador `secret_token.rb` a `secrets.yml` en la sección `production`, reemplazando `<%= ENV["SECRET_KEY_BASE"] %>`.

3. Elimina el inicializador `secret_token.rb`.

4. Utiliza `rake secret` para generar nuevas claves para las secciones `development` y `test`.

5. Reinicia tu servidor.

### Cambios en el helper de pruebas

Si tu helper de pruebas contiene una llamada a `ActiveRecord::Migration.check_pending!`, esto se puede eliminar. La verificación ahora se realiza automáticamente cuando se requiere "rails/test_help", aunque dejar esta línea en tu helper no causa ningún daño de ninguna manera.

### Serializador de cookies

Las aplicaciones creadas antes de Rails 4.1 utilizan `Marshal` para serializar los valores de las cookies en los frascos de cookies firmadas y encriptadas. Si deseas utilizar el nuevo formato basado en `JSON` en tu aplicación, puedes agregar un archivo inicializador con el siguiente contenido:

```ruby
Rails.application.config.action_dispatch.cookies_serializer = :hybrid
```

Esto migrará automáticamente tus cookies serializadas con `Marshal` al nuevo formato basado en `JSON`.

Cuando uses el serializador `:json` o `:hybrid`, debes tener en cuenta que no todos los objetos de Ruby se pueden serializar como JSON. Por ejemplo, los objetos `Date` y `Time` se serializarán como cadenas, y las claves de los `Hash` se convertirán en cadenas.

```ruby
class CookiesController < ApplicationController
  def set_cookie
    cookies.encrypted[:expiration_date] = Date.tomorrow # => Thu, 20 Mar 2014
    redirect_to action: 'read_cookie'
  end

  def read_cookie
    cookies.encrypted[:expiration_date] # => "2014-03-20"
  end
end
```
Es recomendable que solo almacenes datos simples (cadenas y números) en cookies.
Si tienes que almacenar objetos complejos, tendrás que manejar la conversión
manualmente al leer los valores en solicitudes posteriores.

Si utilizas el almacenamiento de sesión en cookies, esto también se aplicará a los hash `session` y `flash`.

### Cambios en la estructura de Flash

Las claves de los mensajes Flash se [normalizan a cadenas](https://github.com/rails/rails/commit/a668beffd64106a1e1fedb71cc25eaaa11baf0c1). Todavía se pueden acceder utilizando símbolos o cadenas. Al recorrer el flash
siempre se obtendrán claves de cadena:

```ruby
flash["cadena"] = "una cadena"
flash[:simbolo] = "un símbolo"

# Rails < 4.1
flash.keys # => ["cadena", :simbolo]

# Rails >= 4.1
flash.keys # => ["cadena", "simbolo"]
```

Asegúrate de comparar las claves de los mensajes Flash con cadenas.

### Cambios en el manejo de JSON

Hay algunos cambios importantes relacionados con el manejo de JSON en Rails 4.1.

#### Eliminación de MultiJSON

MultiJSON ha llegado a su [fin de vida](https://github.com/rails/rails/pull/10576)
y ha sido eliminado de Rails.

Si tu aplicación depende actualmente de MultiJSON directamente, tienes algunas opciones:

1. Agrega 'multi_json' a tu `Gemfile`. Ten en cuenta que esto podría dejar de funcionar en el futuro.

2. Migra lejos de MultiJSON utilizando `obj.to_json` y `JSON.parse(str)` en su lugar.

ADVERTENCIA: No reemplaces simplemente `MultiJson.dump` y `MultiJson.load` con
`JSON.dump` y `JSON.load`. Estas APIs de la gema JSON están destinadas a serializar y
deserializar objetos Ruby arbitrarios y generalmente no son seguras.

#### Compatibilidad con la gema JSON

Históricamente, Rails tenía algunos problemas de compatibilidad con la gema JSON. Usar
`JSON.generate` y `JSON.dump` dentro de una aplicación Rails podía producir
errores inesperados.

Rails 4.1 solucionó estos problemas aislando su propio codificador de la gema JSON. Las
APIs de la gema JSON funcionarán normalmente, pero no tendrán acceso a ninguna
característica específica de Rails. Por ejemplo:

```ruby
class FooBar
  def as_json(options = nil)
    { foo: 'bar' }
  end
end
```

```irb
irb> FooBar.new.to_json
=> "{\"foo\":\"bar\"}"
irb> JSON.generate(FooBar.new, quirks_mode: true)
=> "\"#<FooBar:0x007fa80a481610>\""
```

#### Nuevo codificador JSON

El codificador JSON en Rails 4.1 ha sido reescrito para aprovechar la gema JSON. Para la mayoría de las aplicaciones, este cambio debería ser transparente. Sin embargo, como
parte de la reescritura, se han eliminado las siguientes características del codificador:

1. Detección de estructuras de datos circulares.
2. Soporte para el gancho `encode_json`.
3. Opción para codificar objetos `BigDecimal` como números en lugar de cadenas.

Si tu aplicación depende de una de estas características, puedes recuperarlas
agregando la gema [`activesupport-json_encoder`](https://github.com/rails/activesupport-json_encoder)
a tu `Gemfile`.

#### Representación JSON de objetos Time

`#as_json` para objetos con componente de tiempo (`Time`, `DateTime`, `ActiveSupport::TimeWithZone`)
ahora devuelve precisión en milisegundos de forma predeterminada. Si necesitas mantener el comportamiento anterior sin precisión en milisegundos,
configura lo siguiente en un inicializador:

```ruby
ActiveSupport::JSON::Encoding.time_precision = 0
```

### Uso de `return` dentro de bloques de devolución de llamada en línea

Anteriormente, Rails permitía que los bloques de devolución de llamada en línea usaran `return` de esta manera:

```ruby
class ReadOnlyModel < ActiveRecord::Base
  before_save { return false } # MAL
end
```

Este comportamiento nunca fue admitido intencionalmente. Debido a un cambio en las partes internas
de `ActiveSupport::Callbacks`, esto ya no está permitido en Rails 4.1. Usar una
instrucción `return` en un bloque de devolución de llamada en línea provoca que se genere un `LocalJumpError`
cuando se ejecuta la devolución de llamada.

Los bloques de devolución de llamada en línea que usan `return` se pueden refactorizar para evaluar el
valor devuelto:

```ruby
class ReadOnlyModel < ActiveRecord::Base
  before_save { false } # BIEN
end
```

Alternativamente, si se prefiere `return`, se recomienda definir explícitamente
un método:

```ruby
class ReadOnlyModel < ActiveRecord::Base
  before_save :before_save_callback # BIEN

  private
    def before_save_callback
      false
    end
end
```

Este cambio se aplica a la mayoría de los lugares en Rails donde se utilizan devoluciones de llamada, incluyendo
devoluciones de llamada de Active Record y Active Model, así como filtros en Action
Controller (por ejemplo, `before_action`).

Consulta [esta solicitud de extracción](https://github.com/rails/rails/pull/13271) para obtener más
detalles.

### Métodos definidos en fixtures de Active Record

Rails 4.1 evalúa el ERB de cada fixture en un contexto separado, por lo que los métodos auxiliares
definidos en una fixture no estarán disponibles en otras fixtures.

Los métodos auxiliares que se utilizan en varias fixtures deben definirse en módulos
incluidos en la nueva clase de contexto `ActiveRecord::FixtureSet.context_class`, en
`test_helper.rb`.

```ruby
module FixtureFileHelpers
  def file_sha(path)
    OpenSSL::Digest::SHA256.hexdigest(File.read(Rails.root.join('test/fixtures', path)))
  end
end

ActiveRecord::FixtureSet.context_class.include FixtureFileHelpers
```

### I18n obliga a utilizar locales disponibles

Rails 4.1 ahora establece por defecto la opción de I18n `enforce_available_locales` en `true`. Esto
significa que se asegurará de que todos los locales pasados a él deben declararse en
la lista `available_locales`.
Para desactivarlo (y permitir que I18n acepte *cualquier* opción de localización), agregue la siguiente configuración a su aplicación:

```ruby
config.i18n.enforce_available_locales = false
```

Tenga en cuenta que esta opción se agregó como medida de seguridad, para garantizar que la entrada del usuario no se pueda utilizar como información de localización a menos que se conozca previamente. Por lo tanto, se recomienda no desactivar esta opción a menos que tenga una razón sólida para hacerlo.

### Métodos mutadores llamados en Relation

`Relation` ya no tiene métodos mutadores como `#map!` y `#delete_if`. Conviértalo en un `Array` llamando a `#to_a` antes de usar estos métodos.

Esto pretende evitar errores extraños y confusión en el código que llama directamente a los métodos mutadores en la `Relation`.

```ruby
# En lugar de esto
Author.where(name: 'Hank Moody').compact!

# Ahora tienes que hacer esto
authors = Author.where(name: 'Hank Moody').to_a
authors.compact!
```

### Cambios en los alcances predeterminados

Los alcances predeterminados ya no se anulan por condiciones encadenadas.

En versiones anteriores, cuando definías un `default_scope` en un modelo, se anulaba por condiciones encadenadas en el mismo campo. Ahora se fusiona como cualquier otro alcance.

Antes:

```ruby
class User < ActiveRecord::Base
  default_scope { where state: 'pending' }
  scope :active, -> { where state: 'active' }
  scope :inactive, -> { where state: 'inactive' }
end

User.all
# SELECT "users".* FROM "users" WHERE "users"."state" = 'pending'

User.active
# SELECT "users".* FROM "users" WHERE "users"."state" = 'active'

User.where(state: 'inactive')
# SELECT "users".* FROM "users" WHERE "users"."state" = 'inactive'
```

Después:

```ruby
class User < ActiveRecord::Base
  default_scope { where state: 'pending' }
  scope :active, -> { where state: 'active' }
  scope :inactive, -> { where state: 'inactive' }
end

User.all
# SELECT "users".* FROM "users" WHERE "users"."state" = 'pending'

User.active
# SELECT "users".* FROM "users" WHERE "users"."state" = 'pending' AND "users"."state" = 'active'

User.where(state: 'inactive')
# SELECT "users".* FROM "users" WHERE "users"."state" = 'pending' AND "users"."state" = 'inactive'
```

Para obtener el comportamiento anterior, es necesario eliminar explícitamente la condición del `default_scope` utilizando `unscoped`, `unscope`, `rewhere` o `except`.

```ruby
class User < ActiveRecord::Base
  default_scope { where state: 'pending' }
  scope :active, -> { unscope(where: :state).where(state: 'active') }
  scope :inactive, -> { rewhere state: 'inactive' }
end

User.all
# SELECT "users".* FROM "users" WHERE "users"."state" = 'pending'

User.active
# SELECT "users".* FROM "users" WHERE "users"."state" = 'active'

User.inactive
# SELECT "users".* FROM "users" WHERE "users"."state" = 'inactive'
```

### Renderización de contenido desde una cadena

Rails 4.1 introduce las opciones `:plain`, `:html` y `:body` para `render`. Estas opciones son ahora la forma preferida de renderizar contenido basado en cadenas, ya que te permite especificar el tipo de contenido que deseas que se envíe en la respuesta.

* `render :plain` establecerá el tipo de contenido como `text/plain`
* `render :html` establecerá el tipo de contenido como `text/html`
* `render :body` *no* establecerá la cabecera del tipo de contenido.

Desde el punto de vista de la seguridad, si no esperas tener ningún marcado en el cuerpo de tu respuesta, debes usar `render :plain`, ya que la mayoría de los navegadores escaparán el contenido inseguro en la respuesta por ti.

Estaremos desaconsejando el uso de `render :text` en una versión futura. Así que por favor comienza a usar las opciones más precisas `:plain`, `:html` y `:body` en su lugar. El uso de `render :text` puede representar un riesgo de seguridad, ya que el contenido se envía como `text/html`.

### Tipos de datos JSON y hstore de PostgreSQL

Rails 4.1 mapeará las columnas `json` y `hstore` a un `Hash` de Ruby con claves de cadena. En versiones anteriores, se utilizaba un `HashWithIndifferentAccess`. Esto significa que el acceso mediante símbolos ya no es compatible. Esto también se aplica a los `store_accessors` basados en columnas `json` o `hstore`. Asegúrate de usar claves de cadena de manera consistente.

### Uso explícito de bloque para `ActiveSupport::Callbacks`

Rails 4.1 ahora espera que se pase un bloque explícito al llamar a `ActiveSupport::Callbacks.set_callback`. Este cambio se deriva de la reescritura de `ActiveSupport::Callbacks` para la versión 4.1.

```ruby
# Anteriormente en Rails 4.0
set_callback :save, :around, ->(r, &block) { stuff; result = block.call; stuff }

# Ahora en Rails 4.1
set_callback :save, :around, ->(r, block) { stuff; result = block.call; stuff }
```

Actualización de Rails 3.2 a Rails 4.0
-------------------------------------

Si su aplicación se encuentra actualmente en una versión de Rails anterior a 3.2.x, debe actualizar a Rails 3.2 antes de intentar actualizar a Rails 4.0.

Los siguientes cambios están destinados a la actualización de su aplicación a Rails 4.0.

### HTTP PATCH
Rails 4 ahora utiliza `PATCH` como el verbo HTTP principal para las actualizaciones cuando se declara un recurso RESTful en `config/routes.rb`. La acción `update` todavía se utiliza y las solicitudes `PUT` seguirán siendo enrutadas a la acción `update` también. Entonces, si solo estás utilizando las rutas RESTful estándar, no es necesario hacer cambios:

```ruby
resources :users
```

```erb
<%= form_for @user do |f| %>
```

```ruby
class UsersController < ApplicationController
  def update
    # No se necesita ningún cambio; se preferirá PATCH y PUT seguirá funcionando.
  end
end
```

Sin embargo, necesitarás hacer un cambio si estás utilizando `form_for` para actualizar un recurso en conjunto con una ruta personalizada que utiliza el método HTTP `PUT`:

```ruby
resources :users do
  put :update_name, on: :member
end
```

```erb
<%= form_for [ :update_name, @user ] do |f| %>
```

```ruby
class UsersController < ApplicationController
  def update_name
    # Se necesita un cambio; form_for intentará utilizar una ruta PATCH que no existe.
  end
end
```

Si la acción no se utiliza en una API pública y tienes libertad para cambiar el método HTTP, puedes actualizar tu ruta para utilizar `patch` en lugar de `put`:

```ruby
resources :users do
  patch :update_name, on: :member
end
```

Las solicitudes `PUT` a `/users/:id` en Rails 4 se enrutará a `update` como lo hacen actualmente. Entonces, si tienes una API que recibe solicitudes PUT reales, seguirá funcionando. El enrutador también enrutará las solicitudes `PATCH` a `/users/:id` a la acción `update`.

Si la acción se utiliza en una API pública y no puedes cambiar el método HTTP que se está utilizando, puedes actualizar tu formulario para utilizar el método `PUT` en su lugar:

```erb
<%= form_for [ :update_name, @user ], method: :put do |f| %>
```

Para obtener más información sobre PATCH y por qué se realizó este cambio, consulta [esta publicación](https://weblog.rubyonrails.org/2012/2/26/edge-rails-patch-is-the-new-primary-http-method-for-updates/) en el blog de Rails.

#### Una nota sobre los tipos de medios

Las correcciones para el verbo `PATCH` [especifican que se debe utilizar un tipo de medio 'diff'](http://www.rfc-editor.org/errata_search.php?rfc=5789) con `PATCH`. Uno de esos formatos es [JSON Patch](https://tools.ietf.org/html/rfc6902). Aunque Rails no admite nativamente JSON Patch, es bastante fácil agregar soporte:

```ruby
# en tu controlador:
def update
  respond_to do |format|
    format.json do
      # realizar una actualización parcial
      @article.update params[:article]
    end

    format.json_patch do
      # realizar un cambio sofisticado
    end
  end
end
```

```ruby
# config/initializers/json_patch.rb
Mime::Type.register 'application/json-patch+json', :json_patch
```

Como JSON Patch se convirtió en un RFC recientemente, todavía no hay muchas bibliotecas Ruby excelentes. [hana](https://github.com/tenderlove/hana) de Aaron Patterson es una de esas gemas, pero no tiene soporte completo para los últimos cambios en la especificación.

### Gemfile

Rails 4.0 eliminó el grupo `assets` de `Gemfile`. Debes eliminar esa línea de tu `Gemfile` al actualizar. También debes actualizar tu archivo de aplicación (en `config/application.rb`):

```ruby
# Requiere las gemas enumeradas en Gemfile, incluyendo cualquier gema
# que hayas limitado a :test, :development o :production.
Bundler.require(*Rails.groups)
```

### vendor/plugins

Rails 4.0 ya no admite cargar complementos desde `vendor/plugins`. Debes reemplazar cualquier complemento extrayéndolos a gemas y agregándolos a tu `Gemfile`. Si decides no convertirlos en gemas, puedes moverlos a, por ejemplo, `lib/my_plugin/*` y agregar un inicializador adecuado en `config/initializers/my_plugin.rb`.

### Active Record

* Rails 4.0 ha eliminado el mapa de identidad de Active Record debido a [algunas inconsistencias con las asociaciones](https://github.com/rails/rails/commit/302c912bf6bcd0fa200d964ec2dc4a44abe328a6). Si lo has habilitado manualmente en tu aplicación, deberás eliminar la siguiente configuración que ya no tiene efecto: `config.active_record.identity_map`.

* El método `delete` en las asociaciones de colecciones ahora puede recibir argumentos `Integer` o `String` como identificadores de registros, además de registros, al igual que el método `destroy`. Anteriormente, esto generaba un error `ActiveRecord::AssociationTypeMismatch` para tales argumentos. A partir de Rails 4.0, `delete` intentará automáticamente encontrar los registros que coincidan con los identificadores dados antes de eliminarlos.

* En Rails 4.0, cuando se cambia el nombre de una columna o una tabla, los índices relacionados también se renombran. Si tienes migraciones que renombran los índices, ya no son necesarios.

* Rails 4.0 ha cambiado `serialized_attributes` y `attr_readonly` para que sean solo métodos de clase. No debes utilizar métodos de instancia ya que ahora están en desuso. Debes cambiarlos para que utilicen métodos de clase, por ejemplo, cambiar `self.serialized_attributes` a `self.class.serialized_attributes`.

* Cuando se utiliza el codificador predeterminado, asignar `nil` a un atributo serializado lo guardará en la base de datos como `NULL` en lugar de pasar el valor `nil` a través de YAML (`"--- \n...\n"`).
* Rails 4.0 ha eliminado la función `attr_accessible` y `attr_protected` a favor de Strong Parameters. Puedes usar la gema [Protected Attributes](https://github.com/rails/protected_attributes) para una actualización sin problemas.

* Si no estás utilizando Protected Attributes, puedes eliminar cualquier opción relacionada con esta gema, como `whitelist_attributes` o `mass_assignment_sanitizer`.

* Rails 4.0 requiere que los scopes utilicen un objeto callable como un Proc o lambda:

    ```ruby
      scope :active, where(active: true)

      # se convierte en
      scope :active, -> { where active: true }
    ```

* Rails 4.0 ha deprecado `ActiveRecord::Fixtures` a favor de `ActiveRecord::FixtureSet`.

* Rails 4.0 ha deprecado `ActiveRecord::TestCase` a favor de `ActiveSupport::TestCase`.

* Rails 4.0 ha deprecado la API de búsqueda basada en hash de estilo antiguo. Esto significa que los métodos que anteriormente aceptaban "opciones de búsqueda" ya no lo hacen. Por ejemplo, `Book.find(:all, conditions: { name: '1984' })` ha sido deprecado a favor de `Book.where(name: '1984')`.

* Todos los métodos dinámicos excepto `find_by_...` y `find_by_...!` han sido deprecados. Así es como puedes manejar los cambios:

      * `find_all_by_...`           se convierte en `where(...)`.
      * `find_last_by_...`          se convierte en `where(...).last`.
      * `scoped_by_...`             se convierte en `where(...)`.
      * `find_or_initialize_by_...` se convierte en `find_or_initialize_by(...)`.
      * `find_or_create_by_...`     se convierte en `find_or_create_by(...)`.

* Ten en cuenta que `where(...)` devuelve una relación, no un array como los antiguos finders. Si necesitas un `Array`, utiliza `where(...).to_a`.

* Estos métodos equivalentes pueden no ejecutar el mismo SQL que la implementación anterior.

* Para volver a habilitar los antiguos finders, puedes utilizar la gema [activerecord-deprecated_finders](https://github.com/rails/activerecord-deprecated_finders).

* Rails 4.0 ha cambiado la tabla de unión predeterminada para las relaciones `has_and_belongs_to_many` para eliminar el prefijo común del nombre de la segunda tabla. Cualquier relación `has_and_belongs_to_many` existente entre modelos con un prefijo común debe especificarse con la opción `join_table`. Por ejemplo:

    ```ruby
    CatalogCategory < ActiveRecord::Base
      has_and_belongs_to_many :catalog_products, join_table: 'catalog_categories_catalog_products'
    end

    CatalogProduct < ActiveRecord::Base
      has_and_belongs_to_many :catalog_categories, join_table: 'catalog_categories_catalog_products'
    end
    ```

* Ten en cuenta que el prefijo también tiene en cuenta los scopes, por lo que las relaciones entre `Catalog::Category` y `Catalog::Product` o `Catalog::Category` y `CatalogProduct` deben actualizarse de manera similar.

### Active Resource

Rails 4.0 extrajo Active Resource a su propia gema. Si aún necesitas esta característica, puedes agregar la gema [Active Resource](https://github.com/rails/activeresource) en tu `Gemfile`.

### Active Model

* Rails 4.0 ha cambiado cómo se adjuntan los errores con `ActiveModel::Validations::ConfirmationValidator`. Ahora, cuando las validaciones de confirmación fallan, el error se adjuntará a `:#{attribute}_confirmation` en lugar de `attribute`.

* Rails 4.0 ha cambiado el valor predeterminado de `ActiveModel::Serializers::JSON.include_root_in_json` a `false`. Ahora, Active Model Serializers y los objetos Active Record tienen el mismo comportamiento predeterminado. Esto significa que puedes comentar o eliminar la siguiente opción en el archivo `config/initializers/wrap_parameters.rb`:

    ```ruby
    # Disable root element in JSON by default.
    # ActiveSupport.on_load(:active_record) do
    #   self.include_root_in_json = false
    # end
    ```

### Action Pack

* Rails 4.0 introduce `ActiveSupport::KeyGenerator` y lo utiliza como base para generar y verificar cookies firmadas (entre otras cosas). Las cookies firmadas existentes generadas con Rails 3.x se actualizarán de forma transparente si dejas tu `secret_token` existente en su lugar y agregas el nuevo `secret_key_base`.

    ```ruby
      # config/initializers/secret_token.rb
      Myapp::Application.config.secret_token = 'existing secret token'
      Myapp::Application.config.secret_key_base = 'new secret key base'
    ```

    Ten en cuenta que debes esperar para configurar `secret_key_base` hasta que el 100% de tu base de usuarios esté en Rails 4.x y estés razonablemente seguro de que no necesitarás volver a Rails 3.x. Esto se debe a que las cookies firmadas basadas en el nuevo `secret_key_base` en Rails 4.x no son compatibles con versiones anteriores de Rails 3.x. Puedes dejar tu `secret_token` existente en su lugar, no configurar el nuevo `secret_key_base` e ignorar las advertencias de deprecación hasta que estés razonablemente seguro de que tu actualización esté completa.

    Si dependes de la capacidad de que aplicaciones externas o JavaScript puedan leer las cookies de sesión firmadas de tu aplicación Rails (o cookies firmadas en general), no debes configurar `secret_key_base` hasta que hayas separado estas preocupaciones.

* Rails 4.0 encripta el contenido de las sesiones basadas en cookies si se ha configurado `secret_key_base`. Rails 3.x firmaba, pero no encriptaba, el contenido de las sesiones basadas en cookies. Las cookies firmadas son "seguras" en el sentido de que se verifica que hayan sido generadas por tu aplicación y son a prueba de manipulaciones. Sin embargo, los usuarios finales pueden ver el contenido y encriptar el contenido elimina esta advertencia/preocupación sin una penalización significativa en el rendimiento.

    Por favor, lee [Pull Request #9978](https://github.com/rails/rails/pull/9978) para obtener detalles sobre el cambio a cookies de sesión encriptadas.

* Rails 4.0 eliminó la opción `ActionController::Base.asset_path`. Utiliza la funcionalidad del pipeline de assets.
* Rails 4.0 ha deprecado la opción `ActionController::Base.page_cache_extension`. En su lugar, utiliza `ActionController::Base.default_static_extension`.

* Rails 4.0 ha eliminado el almacenamiento en caché de acciones y páginas de Action Pack. Deberás agregar la gema `actionpack-action_caching` para utilizar `caches_action` y la gema `actionpack-page_caching` para utilizar `caches_page` en tus controladores.

* Rails 4.0 ha eliminado el analizador de parámetros XML. Deberás agregar la gema `actionpack-xml_parser` si necesitas esta funcionalidad.

* Rails 4.0 cambia la búsqueda predeterminada de `layout` utilizando símbolos o procs que devuelven nil. Para obtener el comportamiento de "sin diseño", devuelve false en lugar de nil.

* Rails 4.0 cambia el cliente memcached predeterminado de `memcache-client` a `dalli`. Para actualizar, simplemente agrega `gem 'dalli'` a tu `Gemfile`.

* Rails 4.0 deprecia los métodos `dom_id` y `dom_class` en controladores (son válidos en vistas). Deberás incluir el módulo `ActionView::RecordIdentifier` en los controladores que requieran esta funcionalidad.

* Rails 4.0 deprecia la opción `:confirm` para el helper `link_to`. En su lugar, debes utilizar un atributo de datos (por ejemplo, `data: { confirm: '¿Estás seguro?' }`). Esta deprecación también afecta a los helpers basados en este (como `link_to_if` o `link_to_unless`).

* Rails 4.0 cambió la forma en que funcionan `assert_generates`, `assert_recognizes` y `assert_routing`. Ahora todas estas aserciones lanzan `Assertion` en lugar de `ActionController::RoutingError`.

* Rails 4.0 genera un `ArgumentError` si se definen rutas con nombres conflictivos. Esto puede ocurrir con rutas con nombres explícitamente definidos o con el método `resources`. Aquí hay dos ejemplos que entran en conflicto con rutas llamadas `example_path`:

    ```ruby
    get 'one' => 'test#example', as: :example
    get 'two' => 'test#example', as: :example
    ```

    ```ruby
    resources :examples
    get 'clashing/:id' => 'test#example', as: :example
    ```

    En el primer caso, simplemente evita usar el mismo nombre para múltiples rutas. En el segundo caso, puedes utilizar las opciones `only` o `except` proporcionadas por el método `resources` para restringir las rutas creadas, como se detalla en la [Guía de enrutamiento](routing.html#restricting-the-routes-created).

* Rails 4.0 también cambió la forma en que se dibujan las rutas de caracteres Unicode. Ahora puedes dibujar rutas de caracteres Unicode directamente. Si ya dibujas este tipo de rutas, debes cambiarlas, por ejemplo:

    ```ruby
    get Rack::Utils.escape('こんにちは'), controller: 'welcome', action: 'index'
    ```

    se convierte en

    ```ruby
    get 'こんにちは', controller: 'welcome', action: 'index'
    ```

* Rails 4.0 requiere que las rutas que utilizan `match` especifiquen el método de solicitud. Por ejemplo:

    ```ruby
      # Rails 3.x
      match '/' => 'root#index'

      # se convierte en
      match '/' => 'root#index', via: :get

      # o
      get '/' => 'root#index'
    ```

* Rails 4.0 ha eliminado el middleware `ActionDispatch::BestStandardsSupport`, `<!DOCTYPE html>` ya activa el modo estándar según https://msdn.microsoft.com/en-us/library/jj676915(v=vs.85).aspx y el encabezado ChromeFrame se ha movido a `config.action_dispatch.default_headers`.

    Recuerda que también debes eliminar cualquier referencia al middleware de tu código de aplicación, por ejemplo:

    ```ruby
    # Lanzar excepción
    config.middleware.insert_before(Rack::Lock, ActionDispatch::BestStandardsSupport)
    ```

    También verifica la configuración de tu entorno para `config.action_dispatch.best_standards_support` y elimínala si está presente.

* Rails 4.0 permite la configuración de encabezados HTTP mediante `config.action_dispatch.default_headers`. Los valores predeterminados son los siguientes:

    ```ruby
      config.action_dispatch.default_headers = {
        'X-Frame-Options' => 'SAMEORIGIN',
        'X-XSS-Protection' => '1; mode=block'
      }
    ```

    Ten en cuenta que si tu aplicación depende de cargar ciertas páginas en un `<frame>` o `<iframe>`, es posible que debas establecer explícitamente `X-Frame-Options` en `ALLOW-FROM ...` o `ALLOWALL`.

* En Rails 4.0, la precompilación de activos ya no copia automáticamente activos que no sean JS/CSS de `vendor/assets` y `lib/assets`. Los desarrolladores de aplicaciones y motores de Rails deben colocar estos activos en `app/assets` o configurar [`config.assets.precompile`][].

* En Rails 4.0, se lanza `ActionController::UnknownFormat` cuando la acción no maneja el formato de la solicitud. De forma predeterminada, la excepción se maneja respondiendo con un código 406 Not Acceptable, pero ahora puedes anular eso. En Rails 3, siempre se devolvía un código 406 Not Acceptable. No hay anulaciones.

* En Rails 4.0, se lanza una excepción genérica `ActionDispatch::ParamsParser::ParseError` cuando `ParamsParser` no puede analizar los parámetros de la solicitud. Deberás rescatar esta excepción en lugar de `MultiJson::DecodeError` a nivel bajo, por ejemplo.

* En Rails 4.0, `SCRIPT_NAME` se anida correctamente cuando los motores están montados en una aplicación que se sirve desde un prefijo de URL. Ya no es necesario establecer `default_url_options[:script_name]` para solucionar los prefijos de URL sobrescritos.

* Rails 4.0 ha deprecado `ActionController::Integration` en favor de `ActionDispatch::Integration`.
* Rails 4.0 ha deprecado `ActionController::IntegrationTest` en favor de `ActionDispatch::IntegrationTest`.
* Rails 4.0 ha deprecado `ActionController::PerformanceTest` en favor de `ActionDispatch::PerformanceTest`.
* Rails 4.0 ha deprecado `ActionController::AbstractRequest` en favor de `ActionDispatch::Request`.
* Rails 4.0 ha deprecado `ActionController::Request` en favor de `ActionDispatch::Request`.
* Rails 4.0 ha deprecado `ActionController::AbstractResponse` en favor de `ActionDispatch::Response`.
* Rails 4.0 ha deprecado `ActionController::Response` en favor de `ActionDispatch::Response`.
* Rails 4.0 ha deprecado `ActionController::Routing` en favor de `ActionDispatch::Routing`.
### Active Support

Rails 4.0 elimina el alias `j` para `ERB::Util#json_escape` ya que `j` ya se utiliza para `ActionView::Helpers::JavaScriptHelper#escape_javascript`.

#### Caché

El método de caché ha cambiado entre Rails 3.x y 4.0. Debes [cambiar el espacio de nombres de la caché](https://guides.rubyonrails.org/v4.0/caching_with_rails.html#activesupport-cache-store) y desplegar con una caché fría.

### Orden de carga de los ayudantes

El orden en el que se cargan los ayudantes de más de un directorio ha cambiado en Rails 4.0. Anteriormente, se recopilaban y luego se ordenaban alfabéticamente. Después de actualizar a Rails 4.0, los ayudantes conservarán el orden de los directorios cargados y se ordenarán alfabéticamente solo dentro de cada directorio. A menos que utilices explícitamente el parámetro `helpers_path`, este cambio solo afectará la forma de cargar los ayudantes de los motores. Si dependes del orden, debes verificar si los métodos correctos están disponibles después de la actualización. Si deseas cambiar el orden en que se cargan los motores, puedes usar el método `config.railties_order=`.

### Active Record Observer y Action Controller Sweeper

`ActiveRecord::Observer` y `ActionController::Caching::Sweeper` se han extraído a la gema `rails-observers`. Deberás agregar la gema `rails-observers` si necesitas estas características.

### sprockets-rails

* Se han eliminado `assets:precompile:primary` y `assets:precompile:all`. Utiliza `assets:precompile` en su lugar.
* La opción `config.assets.compress` debe cambiarse a [`config.assets.js_compressor`][] de la siguiente manera, por ejemplo:

    ```ruby
    config.assets.js_compressor = :uglifier
    ```

### sass-rails

* `asset-url` con dos argumentos está en desuso. Por ejemplo: `asset-url("rails.png", image)` se convierte en `asset-url("rails.png")`.

Actualización de Rails 3.1 a Rails 3.2
-------------------------------------

Si tu aplicación se encuentra actualmente en una versión de Rails anterior a 3.1.x, debes actualizar a Rails 3.1 antes de intentar una actualización a Rails 3.2.

Los siguientes cambios están destinados a actualizar tu aplicación a la última versión 3.2.x de Rails.

### Gemfile

Realiza los siguientes cambios en tu `Gemfile`.

```ruby
gem 'rails', '3.2.21'

group :assets do
  gem 'sass-rails',   '~> 3.2.6'
  gem 'coffee-rails', '~> 3.2.2'
  gem 'uglifier',     '>= 1.0.3'
end
```

### config/environments/development.rb

Hay algunas nuevas configuraciones que debes agregar a tu entorno de desarrollo:

```ruby
# Levanta una excepción en la protección de asignación masiva para los modelos de Active Record
config.active_record.mass_assignment_sanitizer = :strict

# Registra el plan de consulta para las consultas que tardan más de esto (funciona
# con SQLite, MySQL y PostgreSQL)
config.active_record.auto_explain_threshold_in_seconds = 0.5
```

### config/environments/test.rb

La configuración `mass_assignment_sanitizer` también debe agregarse a `config/environments/test.rb`:

```ruby
# Levanta una excepción en la protección de asignación masiva para los modelos de Active Record
config.active_record.mass_assignment_sanitizer = :strict
```

### vendor/plugins

Rails 3.2 deprecia `vendor/plugins` y Rails 4.0 los eliminará por completo. Si bien no es estrictamente necesario como parte de una actualización a Rails 3.2, puedes comenzar a reemplazar cualquier plugin extrayéndolos a gemas y agregándolos a tu `Gemfile`. Si decides no convertirlos en gemas, puedes moverlos a, por ejemplo, `lib/my_plugin/*` y agregar un inicializador apropiado en `config/initializers/my_plugin.rb`.

### Active Record

Se ha eliminado la opción `:dependent => :restrict` de `belongs_to`. Si deseas evitar eliminar el objeto si hay objetos asociados, puedes establecer `:dependent => :destroy` y devolver `false` después de verificar la existencia de la asociación desde cualquier callback de destrucción del objeto asociado.

Actualización de Rails 3.0 a Rails 3.1
-------------------------------------

Si tu aplicación se encuentra actualmente en una versión de Rails anterior a 3.0.x, debes actualizar a Rails 3.0 antes de intentar una actualización a Rails 3.1.

Los siguientes cambios están destinados a actualizar tu aplicación a Rails 3.1.12, la última versión 3.1.x de Rails.

### Gemfile

Realiza los siguientes cambios en tu `Gemfile`.

```ruby
gem 'rails', '3.1.12'
gem 'mysql2'

# Necesario para el nuevo pipeline de activos
group :assets do
  gem 'sass-rails',   '~> 3.1.7'
  gem 'coffee-rails', '~> 3.1.1'
  gem 'uglifier',     '>= 1.0.3'
end

# jQuery es la biblioteca de JavaScript predeterminada en Rails 3.1
gem 'jquery-rails'
```

### config/application.rb

El pipeline de activos requiere las siguientes adiciones:

```ruby
config.assets.enabled = true
config.assets.version = '1.0'
```

Si tu aplicación utiliza una ruta "/assets" para un recurso, es posible que desees cambiar el prefijo utilizado para los activos para evitar conflictos:

```ruby
# Por defecto es '/assets'
config.assets.prefix = '/asset-files'
```

### config/environments/development.rb

Elimina la configuración RJS `config.action_view.debug_rjs = true`.

Agrega estas configuraciones si habilitas el pipeline de activos:

```ruby
# No comprime los activos
config.assets.compress = false

# Expande las líneas que cargan los activos
config.assets.debug = true
```

### config/environments/production.rb

Nuevamente, la mayoría de los cambios a continuación son para el pipeline de activos. Puedes leer más sobre esto en la guía [Asset Pipeline](asset_pipeline.html).
```ruby
# Comprimir JavaScripts y CSS
config.assets.compress = true

# No volver a la canalización de activos si falta un activo precompilado
config.assets.compile = false

# Generar resúmenes para las URL de los activos
config.assets.digest = true

# Por defecto, Rails.root.join("public/assets")
# config.assets.manifest = TU_RUTA

# Precompilar activos adicionales (application.js, application.css y todos los que no sean JS/CSS ya están agregados)
# config.assets.precompile += %w( admin.js admin.css )

# Forzar todo el acceso a la aplicación a través de SSL, utilizar Strict-Transport-Security y utilizar cookies seguras.
# config.force_ssl = true
```

### config/environments/test.rb

Puedes ayudar a probar el rendimiento con estas adiciones a tu entorno de prueba:

```ruby
# Configurar el servidor de activos estáticos para pruebas con Cache-Control para el rendimiento
config.public_file_server.enabled = true
config.public_file_server.headers = {
  'Cache-Control' => 'public, max-age=3600'
}
```

### config/initializers/wrap_parameters.rb

Agrega este archivo con el siguiente contenido, si deseas envolver los parámetros en un hash anidado. Esto está activado de forma predeterminada en las nuevas aplicaciones.

```ruby
# Asegúrate de reiniciar tu servidor cuando modifiques este archivo.
# Este archivo contiene configuraciones para ActionController::ParamsWrapper que
# está habilitado de forma predeterminada.

# Habilitar envoltura de parámetros para JSON. Puedes deshabilitarlo configurando :format como un array vacío.
ActiveSupport.on_load(:action_controller) do
  wrap_parameters format: [:json]
end

# Deshabilitar el elemento raíz en JSON de forma predeterminada.
ActiveSupport.on_load(:active_record) do
  self.include_root_in_json = false
end
```

### config/initializers/session_store.rb

Necesitas cambiar la clave de tu sesión por algo nuevo, o eliminar todas las sesiones:

```ruby
# en config/initializers/session_store.rb
AppName::Application.config.session_store :cookie_store, key: 'ALGONUEVO'
```

o

```bash
$ bin/rake db:sessions:clear
```

### Elimina las opciones :cache y :concat en las referencias de los ayudantes de activos en las vistas

* Con el Pipeline de Activos, las opciones :cache y :concat ya no se utilizan, elimina estas opciones de tus vistas.
[`config.cache_classes`]: configuring.html#config-cache-classes
[`config.autoload_once_paths`]: configuring.html#config-autoload-once-paths
[`config.force_ssl`]: configuring.html#config-force-ssl
[`config.ssl_options`]: configuring.html#config-ssl-options
[`config.add_autoload_paths_to_load_path`]: configuring.html#config-add-autoload-paths-to-load-path
[`config.active_storage.replace_on_assign_to_many`]: configuring.html#config-active-storage-replace-on-assign-to-many
[`config.exceptions_app`]: configuring.html#config-exceptions-app
[`config.action_mailer.perform_caching`]: configuring.html#config-action-mailer-perform-caching
[`config.assets.precompile`]: configuring.html#config-assets-precompile
[`config.assets.js_compressor`]: configuring.html#config-assets-js-compressor
