**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 0f0bbb2fd67f1843d30e360c15c03c61
El Pipeline de Activos
=======================

Esta guía cubre el pipeline de activos.

Después de leer esta guía, sabrás:

* Qué es el pipeline de activos y qué hace.
* Cómo organizar correctamente los activos de tu aplicación.
* Los beneficios del pipeline de activos.
* Cómo agregar un preprocesador al pipeline.
* Cómo empaquetar activos con una gema.

--------------------------------------------------------------------------------

¿Qué es el Pipeline de Activos?
--------------------------------

El pipeline de activos proporciona un marco para manejar la entrega de activos de JavaScript y CSS. Esto se logra aprovechando tecnologías como HTTP/2 y técnicas como concatenación y minificación. Finalmente, permite que tu aplicación se combine automáticamente con activos de otras gemas.

El pipeline de activos está implementado por las gemas [importmap-rails](https://github.com/rails/importmap-rails), [sprockets](https://github.com/rails/sprockets) y [sprockets-rails](https://github.com/rails/sprockets-rails), y está habilitado de forma predeterminada. Puedes deshabilitarlo al crear una nueva aplicación pasando la opción `--skip-asset-pipeline`.

```bash
$ rails new appname --skip-asset-pipeline
```

NOTA: Esta guía se centra en el pipeline de activos predeterminado que utiliza solo `sprockets` para CSS y `importmap-rails` para el procesamiento de JavaScript. La principal limitación de estos dos es que no admiten la transpilación, por lo que no se pueden utilizar cosas como `Babel`, `Typescript`, `Sass`, `React JSX format` o `TailwindCSS`. Te recomendamos que leas la sección [Bibliotecas Alternativas](#alternative-libraries) si necesitas transpilación para tu JavaScript/CSS.

## Características principales

La primera característica del pipeline de activos es insertar una huella digital SHA256 en cada nombre de archivo para que el archivo sea almacenado en caché por el navegador web y la CDN. Esta huella digital se actualiza automáticamente cuando cambias el contenido del archivo, lo que invalida la caché.

La segunda característica del pipeline de activos es utilizar [import maps](https://github.com/WICG/import-maps) al servir archivos de JavaScript. Esto te permite construir aplicaciones modernas utilizando bibliotecas de JavaScript hechas para módulos ES (ESM) sin necesidad de transpilación y empaquetado. A su vez, **esto elimina la necesidad de Webpack, yarn, node o cualquier otra parte de la cadena de herramientas de JavaScript**.

La tercera característica del pipeline de activos es concatenar todos los archivos CSS en un archivo principal `.css`, que luego se minifica o comprime. Como aprenderás más adelante en esta guía, puedes personalizar esta estrategia para agrupar los archivos de la manera que desees. En producción, Rails inserta una huella digital SHA256 en cada nombre de archivo para que el archivo sea almacenado en caché por el navegador web. Puedes invalidar la caché modificando esta huella digital, lo cual ocurre automáticamente cada vez que cambias el contenido del archivo.

La cuarta característica del pipeline de activos es que permite codificar activos mediante un lenguaje de nivel superior para CSS.

### ¿Qué es la Huella Digital y por qué debería importarme?

La huella digital es una técnica que hace que el nombre de un archivo dependa del contenido del archivo. Cuando el contenido del archivo cambia, también cambia el nombre de archivo. Para contenido estático o que cambia con poca frecuencia, esto proporciona una forma sencilla de determinar si dos versiones de un archivo son idénticas, incluso en diferentes servidores o fechas de implementación.

Cuando un nombre de archivo es único y se basa en su contenido, se pueden establecer encabezados HTTP para alentar a las cachés en todas partes (ya sea en CDNs, en ISP, en equipos de red o en navegadores web) a mantener su propia copia del contenido. Cuando se actualiza el contenido, la huella digital cambiará. Esto hará que los clientes remotos soliciten una nueva copia del contenido. Esto generalmente se conoce como _cache busting_.

La técnica que utiliza Sprockets para la huella digital es insertar un hash del contenido en el nombre, generalmente al final. Por ejemplo, un archivo CSS `global.css`

```
global-908e25f4bf641868d8683022a5b62f54.css
```

Esta es la estrategia adoptada por el pipeline de activos de Rails.

La huella digital está habilitada de forma predeterminada tanto para los entornos de desarrollo como de producción. Puedes habilitar o deshabilitarla en tu configuración a través de la opción [`config.assets.digest`][].

### ¿Qué son los Import Maps y por qué debería importarme?

Los import maps te permiten importar módulos de JavaScript utilizando nombres lógicos que se mapean a archivos versionados/digestos, directamente desde el navegador. De esta manera, puedes construir aplicaciones modernas de JavaScript utilizando bibliotecas de JavaScript hechas para módulos ES (ESM) sin necesidad de transpilación o empaquetado.

Con este enfoque, enviarás muchos archivos JavaScript pequeños en lugar de un solo archivo JavaScript grande. Gracias a HTTP/2, esto ya no tiene una penalización de rendimiento significativa durante el transporte inicial, y de hecho ofrece beneficios sustanciales a largo plazo debido a una mejor dinámica de almacenamiento en caché.
Cómo utilizar Import Maps como un pipeline de activos de JavaScript
-----------------------------

Import Maps es el procesador de JavaScript por defecto, la lógica de generación de los mapas de importación es manejada por la gema [`importmap-rails`](https://github.com/rails/importmap-rails).

ADVERTENCIA: Los mapas de importación se utilizan únicamente para archivos de JavaScript y no se pueden utilizar para la entrega de CSS. Consulta la sección [Sprockets](#how-to-use-sprockets) para aprender sobre CSS.

Puedes encontrar instrucciones detalladas de uso en la página de inicio de la gema, pero es importante entender los conceptos básicos de `importmap-rails`.

### Cómo funciona

Los mapas de importación son básicamente una sustitución de cadena para lo que se conoce como "especificadores de módulos sin nombre". Te permiten estandarizar los nombres de las importaciones de módulos de JavaScript.

Por ejemplo, toma esta definición de importación, que no funcionará sin un mapa de importación:

```javascript
import React from "react"
```

Tendrías que definirlo de esta manera para que funcione:

```javascript
import React from "https://ga.jspm.io/npm:react@17.0.2/index.js"
```

Aquí es donde entra el mapa de importación, definimos el nombre `react` para que se vincule a la dirección `https://ga.jspm.io/npm:react@17.0.2/index.js`. Con esta información, nuestro navegador acepta la definición simplificada `import React from "react"`. Piensa en el mapa de importación como un alias para la dirección de origen de la biblioteca.

### Uso

Con `importmap-rails`, puedes crear el archivo de configuración del mapa de importación para vincular la ruta de la biblioteca a un nombre:

```ruby
# config/importmap.rb
pin "application"
pin "react", to: "https://ga.jspm.io/npm:react@17.0.2/index.js"
```

Todos los mapas de importación configurados deben ser adjuntados en el elemento `<head>` de tu aplicación agregando `<%= javascript_importmap_tags %>`. La función `javascript_importmap_tags` renderiza una serie de scripts en el elemento `head`:

- JSON con todos los mapas de importación configurados:

```html
<script type="importmap">
{
  "imports": {
    "application": "/assets/application-39f16dc3f3....js"
    "react": "https://ga.jspm.io/npm:react@17.0.2/index.js"
  }
}
</script>
```

- [`Es-module-shims`](https://github.com/guybedford/es-module-shims) actúa como un polyfill que garantiza el soporte de `import maps` en navegadores antiguos:

```html
<script src="/assets/es-module-shims.min" async="async" data-turbo-track="reload"></script>
```

- Punto de entrada para cargar JavaScript desde `app/javascript/application.js`:

```html
<script type="module">import "application"</script>
```

### Uso de paquetes npm a través de CDNs de JavaScript

Puedes utilizar el comando `./bin/importmap` que se agrega como parte de la instalación de `importmap-rails` para fijar, desfijar o actualizar paquetes npm en tu mapa de importación. El binstub utiliza [`JSPM.org`](https://jspm.org/).

Funciona de la siguiente manera:

```sh
./bin/importmap pin react react-dom
Fijando "react" a https://ga.jspm.io/npm:react@17.0.2/index.js
Fijando "react-dom" a https://ga.jspm.io/npm:react-dom@17.0.2/index.js
Fijando "object-assign" a https://ga.jspm.io/npm:object-assign@4.1.1/index.js
Fijando "scheduler" a https://ga.jspm.io/npm:scheduler@0.20.2/index.js

./bin/importmap json

{
  "imports": {
    "application": "/assets/application-37f365cbecf1fa2810a8303f4b6571676fa1f9c56c248528bc14ddb857531b95.js",
    "react": "https://ga.jspm.io/npm:react@17.0.2/index.js",
    "react-dom": "https://ga.jspm.io/npm:react-dom@17.0.2/index.js",
    "object-assign": "https://ga.jspm.io/npm:object-assign@4.1.1/index.js",
    "scheduler": "https://ga.jspm.io/npm:scheduler@0.20.2/index.js"
  }
}
```

Como puedes ver, los dos paquetes react y react-dom se resuelven en un total de cuatro dependencias, cuando se resuelven a través de jspm de forma predeterminada.

Ahora puedes utilizar estos en tu punto de entrada `application.js` como lo harías con cualquier otro módulo:

```javascript
import React from "react"
import ReactDOM from "react-dom"
```

También puedes designar una versión específica para fijar:

```sh
./bin/importmap pin react@17.0.1
Fijando "react" a https://ga.jspm.io/npm:react@17.0.1/index.js
Fijando "object-assign" a https://ga.jspm.io/npm:object-assign@4.1.1/index.js
```

Incluso puedes eliminar fijaciones:

```sh
./bin/importmap unpin react
Desfijando "react"
Desfijando "object-assign"
```

Puedes controlar el entorno del paquete para paquetes con compilaciones separadas de "producción" (la predeterminada) y "desarrollo":

```sh
./bin/importmap pin react --env development
Fijando "react" a https://ga.jspm.io/npm:react@17.0.2/dev.index.js
Fijando "object-assign" a https://ga.jspm.io/npm:object-assign@4.1.1/index.js
```

También puedes elegir un proveedor de CDN alternativo compatible al fijar, como [`unpkg`](https://unpkg.com/) o [`jsdelivr`](https://www.jsdelivr.com/) ([`jspm`](https://jspm.org/) es el predeterminado):

```sh
./bin/importmap pin react --from jsdelivr
Fijando "react" a https://cdn.jsdelivr.net/npm/react@17.0.2/index.js
```

Recuerda, sin embargo, que si cambias una fijación de un proveedor a otro, es posible que debas limpiar las dependencias agregadas por el primer proveedor que no se utilizan por el segundo proveedor.

Ejecuta `./bin/importmap` para ver todas las opciones.

Ten en cuenta que este comando es simplemente un envoltorio de conveniencia para resolver nombres lógicos de paquetes a URL de CDN. También puedes buscar las URL de CDN tú mismo y luego fijarlas. Por ejemplo, si quisieras usar Skypack para React, simplemente podrías agregar lo siguiente a `config/importmap.rb`:

```ruby
pin "react", to: "https://cdn.skypack.dev/react"
```

### Precarga de módulos fijados

Para evitar el efecto de cascada donde el navegador tiene que cargar un archivo tras otro antes de poder llegar a la importación más anidada, importmap-rails admite enlaces de [precarga de módulos](https://developers.google.com/web/updates/2017/12/modulepreload). Los módulos fijados se pueden precargar agregando `preload: true` a la fijación.

Es una buena idea precargar bibliotecas o frameworks que se utilizan en toda tu aplicación, ya que esto le indicará al navegador que las descargue antes.

Ejemplo:

```ruby
# config/importmap.rb
pin "@github/hotkey", to: "https://ga.jspm.io/npm:@github/hotkey@1.4.4/dist/index.js", preload: true
pin "md5", to: "https://cdn.jsdelivr.net/npm/md5@2.3.0/md5.js"

# app/views/layouts/application.html.erb
<%= javascript_importmap_tags %>

# incluirá el siguiente enlace antes de configurar el mapa de importación:
<link rel="modulepreload" href="https://ga.jspm.io/npm:@github/hotkey@1.4.4/dist/index.js">
...
```
NOTA: Consulta el repositorio [`importmap-rails`](https://github.com/rails/importmap-rails) para obtener la documentación más actualizada.

Cómo usar Sprockets
-----------------------------

El enfoque ingenuo para exponer los activos de tu aplicación en la web sería almacenarlos en subdirectorios de la carpeta `public`, como `images` y `stylesheets`. Hacerlo manualmente sería difícil ya que la mayoría de las aplicaciones web modernas requieren que los activos se procesen de una manera específica, por ejemplo, comprimirlos y agregar huellas digitales a los activos.

Sprockets está diseñado para preprocesar automáticamente tus activos almacenados en los directorios configurados y, después de procesarlos, exponerlos en la carpeta `public/assets` con huellas digitales, compresión, generación de mapas de origen y otras características configurables.

Los activos aún se pueden colocar en la jerarquía de `public`. Cualquier activo bajo `public` se servirá como archivos estáticos por la aplicación o el servidor web cuando [`config.public_file_server.enabled`][] se establezca en true. Debes definir directivas `manifest.js` para los archivos que deben someterse a algún preprocesamiento antes de ser servidos.

En producción, Rails precompila estos archivos en `public/assets` de forma predeterminada. Las copias precompiladas luego se sirven como activos estáticos por el servidor web. Los archivos en `app/assets` nunca se sirven directamente en producción.


### Archivos y directivas de manifiesto

Al compilar activos con Sprockets, Sprockets necesita decidir qué objetivos principales compilar, generalmente `application.css` e imágenes. Los objetivos principales se definen en el archivo `manifest.js` de Sprockets, por defecto se ve así:

```js
//= link_tree ../images
//= link_directory ../stylesheets .css
//= link_tree ../../javascript .js
//= link_tree ../../../vendor/javascript .js
```

Contiene _directivas_ - instrucciones que le indican a Sprockets qué archivos requerir para construir un solo archivo CSS o JavaScript.

Esto está destinado a incluir el contenido de todos los archivos encontrados en el directorio `./app/assets/images` o en cualquier subdirectorio, así como cualquier archivo reconocido como JS directamente en `./app/javascript` o `./vendor/javascript`.

Cargará cualquier CSS desde el directorio `./app/assets/stylesheets` (sin incluir subdirectorios). Suponiendo que tienes los archivos `application.css` y `marketing.css` en la carpeta `./app/assets/stylesheets`, te permitirá cargar esas hojas de estilo con `<%= stylesheet_link_tag "application" %>` o `<%= stylesheet_link_tag "marketing" %>` desde tus vistas.

Puede que notes que nuestros archivos JavaScript no se cargan desde el directorio `assets` de forma predeterminada, esto se debe a que `./app/javascript` es el punto de entrada predeterminado para la gema `importmap-rails` y la carpeta `vendor` es el lugar donde se almacenarían los paquetes JS descargados.

En el archivo `manifest.js` también puedes especificar la directiva `link` para cargar un archivo específico en lugar de todo el directorio. La directiva `link` requiere proporcionar una extensión de archivo explícita.

Sprockets carga los archivos especificados, los procesa si es necesario, los concatena en un solo archivo y luego los comprime (según el valor de `config.assets.css_compressor` o `config.assets.js_compressor`). La compresión reduce el tamaño del archivo, lo que permite que el navegador descargue los archivos más rápido.

### Activos específicos del controlador

Cuando generas un scaffold o un controlador, Rails también genera un archivo de hoja de estilo en cascada (CSS) para ese controlador. Además, al generar un scaffold, Rails genera el archivo `scaffolds.css`.

Por ejemplo, si generas un `ProjectsController`, Rails también agregará un nuevo archivo en `app/assets/stylesheets/projects.css`. Por defecto, estos archivos estarán listos para usar en tu aplicación de inmediato utilizando la directiva `link_directory` en el archivo `manifest.js`.

También puedes optar por incluir archivos de hojas de estilo específicos del controlador solo en sus respectivos controladores utilizando lo siguiente:

```html+erb
<%= stylesheet_link_tag params[:controller] %>
```

Al hacer esto, asegúrate de no utilizar la directiva `require_tree` en tu `application.css`, ya que eso podría resultar en que tus activos específicos del controlador se incluyan más de una vez.

### Organización de activos

Los activos del pipeline se pueden colocar dentro de una aplicación en una de tres ubicaciones: `app/assets`, `lib/assets` o `vendor/assets`.

* `app/assets` es para activos que son propiedad de la aplicación, como imágenes o hojas de estilo personalizadas.

* `app/javascript` es para tu código JavaScript.

* `vendor/[assets|javascript]` es para activos que son propiedad de entidades externas, como frameworks CSS o bibliotecas JavaScript. Ten en cuenta que el código de terceros con referencias a otros archivos también procesados por el pipeline de activos (imágenes, hojas de estilo, etc.) deberá ser reescrito para usar ayudantes como `asset_path`.

Otras ubicaciones se pueden configurar en el archivo `manifest.js`, consulta [Archivos y directivas de manifiesto](#archivos-y-directivas-de-manifiesto).

#### Rutas de búsqueda

Cuando se hace referencia a un archivo desde un manifiesto o un ayudante, Sprockets busca en todas las ubicaciones especificadas en `manifest.js`. Puedes ver la ruta de búsqueda inspeccionando [`Rails.application.config.assets.paths`](configuring.html#config-assets-paths) en la consola de Rails.
#### Uso de archivos de índice como proxies para carpetas

Sprockets utiliza archivos llamados `index` (con las extensiones relevantes) para un propósito especial.

Por ejemplo, si tienes una biblioteca de CSS con muchos módulos, que se almacena en `lib/assets/stylesheets/library_name`, el archivo `lib/assets/stylesheets/library_name/index.css` sirve como el manifiesto para todos los archivos de esta biblioteca. Este archivo podría incluir una lista de todos los archivos requeridos en orden, o una simple directiva `require_tree`.

También es algo similar a la forma en que se puede acceder a un archivo en `public/library_name/index.html` mediante una solicitud a `/library_name`. Esto significa que no puedes usar directamente un archivo de índice.

La biblioteca en su conjunto se puede acceder en los archivos `.css` de la siguiente manera:

```css
/* ...
*= require library_name
*/
```

Esto simplifica el mantenimiento y mantiene las cosas limpias al permitir que el código relacionado se agrupe antes de su inclusión en otros lugares.

### Codificación de enlaces a activos

Sprockets no agrega nuevos métodos para acceder a tus activos, aún se utiliza el familiar `stylesheet_link_tag`:

```erb
<%= stylesheet_link_tag "application", media: "all" %>
```

Si se utiliza la gema [`turbo-rails`](https://github.com/hotwired/turbo-rails), que está incluida de forma predeterminada en Rails, entonces se incluye la opción `data-turbo-track`, que hace que Turbo verifique si un activo ha sido actualizado y, de ser así, lo carga en la página:

```erb
<%= stylesheet_link_tag "application", "data-turbo-track": "reload" %>
```

En las vistas regulares, se pueden acceder a las imágenes en el directorio `app/assets/images` de la siguiente manera:

```erb
<%= image_tag "rails.png" %>
```

Siempre que el pipeline esté habilitado en tu aplicación (y no esté desactivado en el contexto del entorno actual), este archivo será servido por Sprockets. Si existe un archivo en `public/assets/rails.png`, será servido por el servidor web.

Alternativamente, una solicitud de un archivo con un hash SHA256 como `public/assets/rails-f90d8a84c707a8dc923fca1ca1895ae8ed0a09237f6992015fef1e11be77c023.png` se trata de la misma manera. Cómo se generan estos hashes se explica en la sección [En producción](#en-producción) más adelante en esta guía.

Las imágenes también se pueden organizar en subdirectorios si es necesario, y luego se pueden acceder especificando el nombre del directorio en la etiqueta:

```erb
<%= image_tag "icons/rails.png" %>
```

ADVERTENCIA: Si estás precompilando tus activos (ver [En producción](#en-producción) a continuación), vincular a un activo que no existe generará una excepción en la página que lo llama. Esto incluye vincular a una cadena vacía. Por lo tanto, ten cuidado al usar `image_tag` y los demás ayudantes con datos proporcionados por el usuario.

#### CSS y ERB

El pipeline de activos evalúa automáticamente ERB. Esto significa que si agregas una extensión `erb` a un activo CSS (por ejemplo, `application.css.erb`), entonces los ayudantes como `asset_path` están disponibles en tus reglas CSS:

```css
.class { background-image: url(<%= asset_path 'image.png' %>) }
```

Esto escribe la ruta al activo específico al que se hace referencia. En este ejemplo, tendría sentido tener una imagen en una de las rutas de carga de activos, como `app/assets/images/image.png`, que se referenciaría aquí. Si esta imagen ya está disponible en `public/assets` como un archivo con huella digital, entonces se hace referencia a esa ruta.

Si deseas utilizar una [URI de datos](https://en.wikipedia.org/wiki/Data_URI_scheme) - un método para incrustar los datos de la imagen directamente en el archivo CSS - puedes usar el ayudante `asset_data_uri`.

```css
#logo { background: url(<%= asset_data_uri 'logo.png' %>) }
```

Esto inserta una URI de datos correctamente formateada en la fuente CSS.

Ten en cuenta que la etiqueta de cierre no puede tener el estilo `-%>`.

### Generar un error cuando no se encuentra un activo

Si estás utilizando sprockets-rails >= 3.2.0, puedes configurar qué sucede cuando se realiza una búsqueda de activo y no se encuentra nada. Si desactivas "fallback de activo", se generará un error cuando no se encuentre un activo.

```ruby
config.assets.unknown_asset_fallback = false
```

Si el "fallback de activo" está habilitado, cuando no se encuentre un activo, se mostrará la ruta y no se generará ningún error. El comportamiento de fallback de activo está desactivado de forma predeterminada.

### Desactivar los hashes

Puedes desactivar los hashes actualizando `config/environments/development.rb` para incluir:

```ruby
config.assets.digest = false
```

Cuando esta opción está en true, se generarán hashes para las URL de los activos.

### Activar los mapas de origen

Puedes activar los mapas de origen actualizando `config/environments/development.rb` para incluir:

```ruby
config.assets.debug = true
```

Cuando el modo de depuración está activado, Sprockets generará un mapa de origen para cada activo. Esto te permite depurar cada archivo individualmente en las herramientas de desarrollo de tu navegador.

Los activos se compilan y almacenan en caché en la primera solicitud después de que se inicia el servidor. Sprockets establece una cabecera HTTP `must-revalidate` de Control de caché para reducir la sobrecarga de solicitudes en las solicitudes posteriores; en estas, el navegador recibe una respuesta 304 (No modificado).
Si alguno de los archivos en el manifiesto cambia entre las solicitudes, el servidor responde con un nuevo archivo compilado.

En producción
-------------

En el entorno de producción, Sprockets utiliza el esquema de huellas dactilares descrito anteriormente. Por defecto, Rails asume que los activos han sido precompilados y serán servidos como activos estáticos por su servidor web.

Durante la fase de precompilación, se genera un SHA256 a partir del contenido de los archivos compilados y se inserta en los nombres de archivo a medida que se escriben en el disco. Estos nombres con huellas dactilares son utilizados por los ayudantes de Rails en lugar del nombre del manifiesto.

Por ejemplo, esto:

```erb
<%= stylesheet_link_tag "application" %>
```

genera algo como esto:

```html
<link href="/assets/application-4dd5b109ee3439da54f5bdfd78a80473.css" rel="stylesheet" />
```

El comportamiento de las huellas dactilares es controlado por la opción de inicialización [`config.assets.digest`][] (que por defecto es `true`).

NOTA: En circunstancias normales, la opción predeterminada `config.assets.digest` no debe ser cambiada. Si no hay huellas dactilares en los nombres de archivo y se establecen encabezados de fecha futura, los clientes remotos nunca sabrán que deben volver a solicitar los archivos cuando su contenido cambie.


### Precompilación de activos

Rails viene con un comando para compilar los manifiestos de activos y otros archivos en la canalización.

Los activos compilados se escriben en la ubicación especificada en [`config.assets.prefix`][]. Por defecto, esto es el directorio `/assets`.

Puede llamar a este comando en el servidor durante la implementación para crear versiones compiladas de sus activos directamente en el servidor. Consulte la siguiente sección para obtener información sobre la compilación local.

El comando es:

```bash
$ RAILS_ENV=production rails assets:precompile
```

Esto vincula la carpeta especificada en `config.assets.prefix` a `shared/assets`. Si ya utiliza esta carpeta compartida, deberá escribir su propio comando de implementación.

Es importante que esta carpeta se comparta entre las implementaciones para que las páginas en caché remotamente que hacen referencia a los antiguos activos compilados sigan funcionando durante la vida de la página en caché.

NOTA. Siempre especifique un nombre de archivo compilado esperado que termine con `.js` o `.css`.

El comando también genera un archivo `.sprockets-manifest-randomhex.json` (donde `randomhex` es una cadena hexadecimal aleatoria de 16 bytes) que contiene una lista con todos sus activos y sus respectivas huellas dactilares. Esto es utilizado por los métodos auxiliares de Rails para evitar devolver las solicitudes de asignación a Sprockets. Un archivo de manifiesto típico se ve así:

```json
{"files":{"application-<fingerprint>.js":{"logical_path":"application.js","mtime":"2016-12-23T20:12:03-05:00","size":412383,
"digest":"<fingerprint>","integrity":"sha256-<random-string>"}},
"assets":{"application.js":"application-<fingerprint>.js"}}
```

En su aplicación, habrá más archivos y activos enumerados en el manifiesto, también se generarán `<fingerprint>` y `<random-string>`.

La ubicación predeterminada para el manifiesto es la raíz de la ubicación especificada en `config.assets.prefix` ('/assets' de forma predeterminada).

NOTA: Si faltan archivos precompilados en producción, obtendrá una excepción `Sprockets::Helpers::RailsHelper::AssetPaths::AssetNotPrecompiledError` que indica el nombre del archivo(s) que falta(n).


#### Encabezado Expires de fecha futura

Los activos precompilados existen en el sistema de archivos y son servidos directamente por su servidor web. Por defecto, no tienen encabezados de fecha futura, por lo que para obtener el beneficio de las huellas dactilares deberá actualizar la configuración de su servidor para agregar esos encabezados.

Para Apache:

```apache
# Las directivas Expires* requieren que el módulo Apache
# `mod_expires` esté habilitado.
<Location /assets/>
  # El uso de ETag se desaconseja cuando Last-Modified está presente
  Header unset ETag
  FileETag None
  # La RFC dice que solo se almacena en caché durante 1 año
  ExpiresActive On
  ExpiresDefault "access plus 1 year"
</Location>
```

Para NGINX:

```nginx
location ~ ^/assets/ {
  expires 1y;
  add_header Cache-Control public;

  add_header ETag "";
}
```

### Precompilación local

A veces, es posible que no desee o no pueda compilar los activos en el servidor de producción. Por ejemplo, es posible que tenga acceso limitado de escritura a su sistema de archivos de producción o que planee implementar con frecuencia sin realizar cambios en sus activos.

En estos casos, puede precompilar los activos _localmente_, es decir, agregar un conjunto finalizado de activos compilados y listos para producción a su repositorio de código fuente antes de implementar en producción. De esta manera, no es necesario compilarlos por separado en el servidor de producción en cada implementación.

Como se mencionó anteriormente, puede realizar este paso utilizando

```bash
$ RAILS_ENV=production rails assets:precompile
```

Tenga en cuenta las siguientes advertencias:

* Si los activos precompilados están disponibles, se servirán, incluso si ya no coinciden con los activos originales (no compilados), _incluso en el servidor de desarrollo_.

    Para asegurarse de que el servidor de desarrollo siempre compile los activos sobre la marcha (y así siempre refleje el estado más reciente del código), el entorno de desarrollo _debe estar configurado para mantener los activos precompilados en una ubicación diferente a la de producción_. De lo contrario, cualquier activo precompilado para su uso en producción sobrescribirá las solicitudes de ellos en desarrollo (es decir, los cambios posteriores que realice en los activos no se reflejarán en el navegador).
Puedes hacer esto agregando la siguiente línea a `config/environments/development.rb`:

```ruby
config.assets.prefix = "/dev-assets"
```

* La tarea de precompilación de activos en tu herramienta de implementación (_por ejemplo_, Capistrano) debe estar desactivada.
* Cualquier compresor o minificador necesario debe estar disponible en tu sistema de desarrollo.

También puedes configurar `ENV["SECRET_KEY_BASE_DUMMY"]` para activar el uso de un `secret_key_base` generado aleatoriamente que se almacena en un archivo temporal. Esto es útil cuando se precompilan activos para producción como parte de un paso de construcción que de otra manera no necesita acceso a los secretos de producción.

```bash
$ SECRET_KEY_BASE_DUMMY=1 bundle exec rails assets:precompile
```

### Compilación en vivo

En algunas circunstancias, es posible que desees utilizar la compilación en vivo. En este modo, todas las solicitudes de activos en el pipeline son manejadas directamente por Sprockets.

Para habilitar esta opción, configura:

```ruby
config.assets.compile = true
```

En la primera solicitud, los activos se compilan y se almacenan en caché como se describe en [Assets Cache Store](#assets-cache-store), y los nombres de los manifiestos utilizados en los helpers se modifican para incluir el hash SHA256.

Sprockets también establece la cabecera HTTP `Cache-Control` en `max-age=31536000`. Esto indica a todas las cachés entre tu servidor y el navegador del cliente que este contenido (el archivo servido) se puede almacenar en caché durante 1 año. El efecto de esto es reducir el número de solicitudes de este activo desde tu servidor; es muy probable que el activo esté en la caché del navegador local o en alguna caché intermedia.

Este modo utiliza más memoria, tiene un rendimiento inferior al valor predeterminado y no se recomienda.

### CDNs

CDN significa [Content Delivery Network](https://en.wikipedia.org/wiki/Content_delivery_network) (Red de Distribución de Contenido), están diseñadas principalmente para almacenar en caché activos en todo el mundo para que cuando un navegador solicite el activo, haya una copia en caché cerca geográficamente de ese navegador. Si estás sirviendo activos directamente desde tu servidor de Rails en producción, la mejor práctica es utilizar un CDN delante de tu aplicación.

Un patrón común para utilizar un CDN es configurar tu aplicación de producción como el servidor "origen". Esto significa que cuando un navegador solicita un activo desde el CDN y hay un fallo de caché, el CDN obtendrá el archivo de tu servidor sobre la marcha y luego lo almacenará en caché. Por ejemplo, si estás ejecutando una aplicación de Rails en `example.com` y tienes un CDN configurado en `mycdnsubdomain.fictional-cdn.com`, entonces cuando se realiza una solicitud a `mycdnsubdomain.fictional-cdn.com/assets/smile.png`, el CDN consultará tu servidor una vez en `example.com/assets/smile.png` y almacenará en caché la solicitud. La siguiente solicitud al CDN que llegue a la misma URL accederá a la copia en caché. Cuando el CDN puede servir un activo directamente, la solicitud nunca llega a tu servidor de Rails. Dado que los activos de un CDN están geográficamente más cerca del navegador, la solicitud es más rápida, y dado que tu servidor no necesita pasar tiempo sirviendo activos, puede centrarse en servir el código de la aplicación lo más rápido posible.

#### Configurar un CDN para servir activos estáticos

Para configurar tu CDN, debes tener tu aplicación en ejecución en producción en Internet en una URL pública disponible, por ejemplo, `example.com`. A continuación, debes registrarte en un servicio de CDN de un proveedor de alojamiento en la nube. Cuando lo hagas, debes configurar el "origen" del CDN para que apunte a tu sitio web `example.com`. Consulta la documentación de tu proveedor para obtener información sobre cómo configurar el servidor de origen.

El CDN que hayas provisionado debería darte un subdominio personalizado para tu aplicación, como `mycdnsubdomain.fictional-cdn.com` (nota: fictional-cdn.com no es un proveedor de CDN válido en el momento de escribir esto). Ahora que has configurado tu servidor de CDN, debes indicar a los navegadores que utilicen tu CDN para obtener los activos en lugar de tu servidor de Rails directamente. Puedes hacer esto configurando Rails para que establezca tu CDN como el host de activos en lugar de utilizar una ruta relativa. Para establecer tu host de activos en Rails, debes configurar [`config.asset_host`][] en `config/environments/production.rb`:

```ruby
config.asset_host = 'mycdnsubdomain.fictional-cdn.com'
```

NOTA: Solo necesitas proporcionar el "host", que es el subdominio y el dominio raíz, no necesitas especificar un protocolo o "scheme" como `http://` o `https://`. Cuando se solicita una página web, el protocolo en el enlace a tu activo que se genera coincidirá con la forma en que se accede a la página web de forma predeterminada.

También puedes configurar este valor a través de una [variable de entorno](https://en.wikipedia.org/wiki/Environment_variable) para facilitar la ejecución de una copia de tu sitio en etapa de pruebas:

```ruby
config.asset_host = ENV['CDN_HOST']
```

NOTA: Debes configurar `CDN_HOST` en tu servidor como `mycdnsubdomain.fictional-cdn.com` para que esto funcione.

Una vez que hayas configurado tu servidor y tu CDN, las rutas de los activos desde los helpers, como:

```erb
<%= asset_path('smile.png') %>
```

Se renderizarán como URLs completas del CDN, como `http://mycdnsubdomain.fictional-cdn.com/assets/smile.png`
(digest omitido por legibilidad).

Si el CDN tiene una copia de `smile.png`, la servirá al navegador y tu servidor ni siquiera sabrá que se solicitó. Si el CDN no tiene una copia, intentará encontrarla en el "origen" `example.com/assets/smile.png` y luego la almacenará para su uso futuro.

Si deseas servir solo algunos activos desde tu CDN, puedes usar la opción personalizada `:host` en tu helper de activos, que sobrescribe el valor establecido en [`config.action_controller.asset_host`][].

```erb
<%= asset_path 'image.png', host: 'mycdnsubdomain.fictional-cdn.com' %>
```

#### Personalizar el comportamiento de almacenamiento en caché del CDN

Un CDN funciona almacenando en caché el contenido. Si el CDN tiene contenido obsoleto o incorrecto, en realidad está perjudicando en lugar de ayudar a tu aplicación. El propósito de esta sección es describir el comportamiento general de almacenamiento en caché de la mayoría de los CDNs. Tu proveedor específico puede comportarse ligeramente diferente.

##### Almacenamiento en caché de solicitudes del CDN

Si bien se dice que un CDN es bueno para almacenar en caché activos, en realidad almacena en caché toda la solicitud. Esto incluye el cuerpo del activo y cualquier encabezado. El más importante es `Cache-Control`, que le indica al CDN (y a los navegadores web) cómo almacenar en caché el contenido. Esto significa que si alguien solicita un activo que no existe, como `/assets/i-dont-exist.png`, y tu aplicación de Rails devuelve un error 404, es probable que tu CDN almacene en caché la página de error 404 si hay un encabezado `Cache-Control` válido presente.

##### Depuración de encabezados del CDN

Una forma de verificar que los encabezados se almacenen en caché correctamente en tu CDN es utilizando [curl](
https://explainshell.com/explain?cmd=curl+-I+http%3A%2F%2Fwww.example.com). Puedes solicitar los encabezados tanto desde tu servidor como desde tu CDN para verificar que sean iguales:

```bash
$ curl -I http://www.example/assets/application-
d0e099e021c95eb0de3615fd1d8c4d83.css
HTTP/1.1 200 OK
Server: Cowboy
Date: Sun, 24 Aug 2014 20:27:50 GMT
Connection: keep-alive
Last-Modified: Thu, 08 May 2014 01:24:14 GMT
Content-Type: text/css
Cache-Control: public, max-age=2592000
Content-Length: 126560
Via: 1.1 vegur
```

Versus la copia del CDN:

```bash
$ curl -I http://mycdnsubdomain.fictional-cdn.com/application-
d0e099e021c95eb0de3615fd1d8c4d83.css
HTTP/1.1 200 OK Server: Cowboy Last-
Modified: Thu, 08 May 2014 01:24:14 GMT Content-Type: text/css
Cache-Control:
public, max-age=2592000
Via: 1.1 vegur
Content-Length: 126560
Accept-Ranges:
bytes
Date: Sun, 24 Aug 2014 20:28:45 GMT
Via: 1.1 varnish
Age: 885814
Connection: keep-alive
X-Served-By: cache-dfw1828-DFW
X-Cache: HIT
X-Cache-Hits:
68
X-Timer: S1408912125.211638212,VS0,VE0
```

Consulta la documentación de tu CDN para obtener cualquier información adicional que puedan proporcionar, como `X-Cache`, o para cualquier encabezado adicional que puedan agregar.

##### CDNs y el encabezado Cache-Control

El encabezado [`Cache-Control`][] describe cómo se puede almacenar en caché una solicitud. Cuando no se utiliza un CDN, un navegador utiliza esta información para almacenar en caché el contenido. Esto es muy útil para los activos que no se modifican, para que un navegador no tenga que volver a descargar el CSS o JavaScript de un sitio web en cada solicitud. Por lo general, queremos que nuestro servidor de Rails le diga a nuestro CDN (y al navegador) que el activo es "público". Esto significa que cualquier caché puede almacenar la solicitud. También comúnmente queremos establecer `max-age`, que es cuánto tiempo la caché almacenará el objeto antes de invalidarla. El valor de `max-age` se establece en segundos, con un valor máximo posible de `31536000`, que es un año. Puedes hacer esto en tu aplicación de Rails configurando:

```ruby
config.public_file_server.headers = {
  'Cache-Control' => 'public, max-age=31536000'
}
```

Ahora, cuando tu aplicación sirve un activo en producción, el CDN almacenará el activo durante hasta un año. Dado que la mayoría de los CDNs también almacenan en caché los encabezados de la solicitud, este `Cache-Control` se transmitirá a todos los navegadores futuros que busquen este activo. El navegador sabrá entonces que puede almacenar este activo durante mucho tiempo antes de tener que volver a solicitarlo.

##### CDNs y la invalidación de caché basada en URL

La mayoría de los CDNs almacenarán el contenido de un activo en caché en función de la URL completa. Esto significa que una solicitud a

```
http://mycdnsubdomain.fictional-cdn.com/assets/smile-123.png
```

Será una caché completamente diferente a

```
http://mycdnsubdomain.fictional-cdn.com/assets/smile.png
```

Si deseas establecer un `max-age` en el futuro lejano en tu `Cache-Control` (y lo deseas), asegúrate de que cuando cambies tus activos, se invalide tu caché. Por ejemplo, al cambiar la cara sonriente en una imagen de amarilla a azul, deseas que todos los visitantes de tu sitio obtengan la nueva cara azul. Cuando usas un CDN con el pipeline de activos de Rails, `config.assets.digest` se establece en `true` de forma predeterminada para que cada activo tenga un nombre de archivo diferente cuando se cambia. De esta manera, no tienes que invalidar manualmente ningún elemento en tu caché. Al usar un nombre de activo único diferente, tus usuarios obtienen el activo más reciente.
Personalización del Pipeline
------------------------

### Compresión de CSS

Una de las opciones para comprimir CSS es YUI. El [compresor de CSS de YUI](https://yui.github.io/yuicompressor/css.html) proporciona minificación.

La siguiente línea habilita la compresión de YUI y requiere la gema `yui-compressor`.

```ruby
config.assets.css_compressor = :yui
```

### Compresión de JavaScript

Las opciones posibles para la compresión de JavaScript son `:terser`, `:closure` y `:yui`. Estas requieren el uso de las gemas `terser`, `closure-compiler` o `yui-compressor`, respectivamente.

Tomemos como ejemplo la gema `terser`.
Esta gema envuelve a [Terser](https://github.com/terser/terser) (escrito para Node.js) en Ruby. Comprime tu código eliminando espacios en blanco y comentarios, acortando los nombres de las variables locales y realizando otras micro-optimizaciones, como cambiar las declaraciones `if` y `else` a operadores ternarios cuando sea posible.

La siguiente línea invoca a `terser` para la compresión de JavaScript.

```ruby
config.assets.js_compressor = :terser
```

NOTA: Necesitarás un tiempo de ejecución compatible con [ExecJS](https://github.com/rails/execjs#readme) para poder utilizar `terser`. Si estás utilizando macOS o Windows, tienes un tiempo de ejecución de JavaScript instalado en tu sistema operativo.

NOTA: La compresión de JavaScript también funcionará para tus archivos JavaScript cuando cargues tus activos a través de las gemas `importmap-rails` o `jsbundling-rails`.

### Compresión GZip de tus activos

De forma predeterminada, se generarán versiones comprimidas en formato GZip de los activos compilados, junto con la versión no comprimida de los activos. Los activos comprimidos en formato GZip ayudan a reducir la transmisión de datos a través de la red. Puedes configurar esto estableciendo la opción `gzip`.

```ruby
config.assets.gzip = false # deshabilitar la generación de activos comprimidos en formato GZip
```

Consulta la documentación de tu servidor web para obtener instrucciones sobre cómo servir activos comprimidos en formato GZip.

### Uso de tu propio compresor

La configuración del compresor para CSS y JavaScript también acepta cualquier objeto. Este objeto debe tener un método `compress` que tome una cadena como único argumento y devuelva una cadena.

```ruby
class Transformer
  def compress(string)
    hacer_algo_devolviendo_una_cadena(string)
  end
end
```

Para habilitar esto, pasa un nuevo objeto a la opción de configuración en `application.rb`:

```ruby
config.assets.css_compressor = Transformer.new
```

### Cambio de la ruta de los _assets_

La ruta pública que Sprockets utiliza de forma predeterminada es `/assets`.

Esto se puede cambiar a otra cosa:

```ruby
config.assets.prefix = "/otra_ruta"
```

Esta es una opción útil si estás actualizando un proyecto más antiguo que no utilizaba el pipeline de activos y ya utiliza esta ruta, o si deseas utilizar esta ruta para un nuevo recurso.

### Encabezados X-Sendfile

El encabezado X-Sendfile es una directiva para el servidor web que indica al servidor web que ignore la respuesta de la aplicación y, en su lugar, sirva un archivo especificado desde el disco. Esta opción está desactivada de forma predeterminada, pero se puede habilitar si tu servidor lo admite. Cuando está habilitada, esto pasa la responsabilidad de servir el archivo al servidor web, lo cual es más rápido. Consulta [send_file](https://api.rubyonrails.org/classes/ActionController/DataStreaming.html#method-i-send_file) para obtener información sobre cómo utilizar esta función.

Apache y NGINX admiten esta opción, que se puede habilitar en `config/environments/production.rb`:

```ruby
# config.action_dispatch.x_sendfile_header = "X-Sendfile" # para Apache
# config.action_dispatch.x_sendfile_header = 'X-Accel-Redirect' # para NGINX
```

ADVERTENCIA: Si estás actualizando una aplicación existente y tienes la intención de utilizar esta opción, asegúrate de pegar esta opción de configuración solo en `production.rb` y en cualquier otro entorno que definas con comportamiento de producción (no en `application.rb`).

CONSEJO: Para obtener más detalles, consulta la documentación de tu servidor web de producción:

- [Apache](https://tn123.org/mod_xsendfile/)
- [NGINX](https://www.nginx.com/resources/wiki/start/topics/examples/xsendfile/)

Almacenamiento en caché de activos
------------------

De forma predeterminada, Sprockets almacena en caché los activos en `tmp/cache/assets` en los entornos de desarrollo y producción. Esto se puede cambiar de la siguiente manera:

```ruby
config.assets.configure do |env|
  env.cache = ActiveSupport::Cache.lookup_store(:memory_store,
                                                { size: 32.megabytes })
end
```

Para deshabilitar el almacenamiento en caché de activos:

```ruby
config.assets.configure do |env|
  env.cache = ActiveSupport::Cache.lookup_store(:null_store)
end
```

Añadir activos a tus gemas
--------------------------

Los activos también pueden provenir de fuentes externas en forma de gemas.

Un buen ejemplo de esto es la gema `jquery-rails`.
Esta gema contiene una clase de motor que hereda de `Rails::Engine`.
Al hacer esto, Rails se informa de que el directorio de esta gema puede contener activos y los directorios `app/assets`, `lib/assets` y `vendor/assets` de este motor se agregan a la ruta de búsqueda de Sprockets.

Hacer que tu biblioteca o gema sea un preprocesador
------------------------------------------

Sprockets utiliza procesadores, transformadores, compresores y exportadores para ampliar la funcionalidad de Sprockets. Consulta [Extending Sprockets](https://github.com/rails/sprockets/blob/master/guides/extending_sprockets.md) para obtener más información. Aquí registramos un preprocesador para agregar un comentario al final de los archivos de texto/css (`.css`).

```ruby
module AddComment
  def self.call(input)
    { data: input[:data] + "/* Hello From my sprockets extension */" }
  end
end
```

Ahora que tienes un módulo que modifica los datos de entrada, es hora de registrarlo como un preprocesador para tu tipo MIME.
```ruby
Sprockets.register_preprocessor 'text/css', AddComment
```


Bibliotecas Alternativas
------------------------------------------

A lo largo de los años ha habido múltiples enfoques predeterminados para manejar los activos. La web evolucionó y comenzamos a ver aplicaciones cada vez más cargadas de JavaScript. En The Rails Doctrine creemos que [El menú es Omakase](https://rubyonrails.org/doctrine#omakase), por lo que nos enfocamos en la configuración predeterminada: **Sprockets con Import Maps**.

Somos conscientes de que no hay soluciones universales para los diversos frameworks/extensiones de JavaScript y CSS disponibles. Hay otras bibliotecas de empaquetado en el ecosistema de Rails que deberían permitirte en los casos en los que la configuración predeterminada no sea suficiente.

### jsbundling-rails

[`jsbundling-rails`](https://github.com/rails/jsbundling-rails) es una alternativa dependiente de Node.js para la forma de empaquetar JavaScript con [esbuild](https://esbuild.github.io/), [rollup.js](https://rollupjs.org/) o [Webpack](https://webpack.js.org/).

La gema proporciona un proceso `yarn build --watch` para generar automáticamente la salida en desarrollo. Para producción, se engancha automáticamente la tarea `javascript:build` en la tarea `assets:precompile` para asegurarse de que todas las dependencias de tus paquetes se hayan instalado y se haya construido JavaScript para todos los puntos de entrada.

**¿Cuándo usar en lugar de `importmap-rails`?** Si tu código de JavaScript depende de la transpilación, es decir, si estás utilizando [Babel](https://babeljs.io/), [TypeScript](https://www.typescriptlang.org/) o el formato `JSX` de React, entonces `jsbundling-rails` es la forma correcta de proceder.

### Webpacker/Shakapacker

[`Webpacker`](webpacker.html) era el preprocesador y empaquetador de JavaScript predeterminado para Rails 5 y 6. Ahora se ha retirado. Existe un sucesor llamado [`shakapacker`](https://github.com/shakacode/shakapacker), pero no es mantenido por el equipo o proyecto de Rails.

A diferencia de otras bibliotecas de esta lista, `webpacker`/`shakapacker` es completamente independiente de Sprockets y puede procesar tanto archivos JavaScript como CSS. Lee la [guía de Webpacker](https://guides.rubyonrails.org/webpacker.html) para obtener más información.

NOTA: Lee el documento [Comparación con Webpacker](https://github.com/rails/jsbundling-rails/blob/main/docs/comparison_with_webpacker.md) para entender las diferencias entre `jsbundling-rails` y `webpacker`/`shakapacker`.

### cssbundling-rails

[`cssbundling-rails`](https://github.com/rails/cssbundling-rails) permite empaquetar y procesar tu CSS utilizando [Tailwind CSS](https://tailwindcss.com/), [Bootstrap](https://getbootstrap.com/), [Bulma](https://bulma.io/), [PostCSS](https://postcss.org/) o [Dart Sass](https://sass-lang.com/), y luego entrega el CSS a través del pipeline de activos.

Funciona de manera similar a `jsbundling-rails`, por lo que agrega la dependencia de Node.js a tu aplicación con el proceso `yarn build:css --watch` para regenerar tus hojas de estilo en desarrollo y se engancha en la tarea `assets:precompile` en producción.

**¿Cuál es la diferencia con Sprockets?** Sprockets por sí solo no puede transpilar el Sass a CSS, se requiere Node.js para generar los archivos `.css` a partir de tus archivos `.sass`. Una vez que se generan los archivos `.css`, entonces `Sprockets` puede entregarlos a tus clientes.

NOTA: `cssbundling-rails` depende de Node para procesar el CSS. Las gemas `dartsass-rails` y `tailwindcss-rails` utilizan versiones independientes de Tailwind CSS y Dart Sass, lo que significa que no hay dependencia de Node. Si estás utilizando `importmap-rails` para manejar tus JavaScript y `dartsass-rails` o `tailwindcss-rails` para CSS, podrías evitar completamente la dependencia de Node, lo que resultaría en una solución menos compleja.

### dartsass-rails

Si deseas utilizar [`Sass`](https://sass-lang.com/) en tu aplicación, [`dartsass-rails`](https://github.com/rails/dartsass-rails) es un reemplazo para la gema heredada `sassc-rails`. `dartsass-rails` utiliza la implementación `Dart Sass` en lugar de [`LibSass`](https://sass-lang.com/blog/libsass-is-deprecated), que fue descontinuada en 2020 y era utilizada por `sassc-rails`.

A diferencia de `sassc-rails`, la nueva gema no está integrada directamente con `Sprockets`. Consulta la página de inicio de la gema para obtener instrucciones de instalación/migración.

ADVERTENCIA: La popular gema `sassc-rails` no ha recibido mantenimiento desde 2019.

### tailwindcss-rails

[`tailwindcss-rails`](https://github.com/rails/tailwindcss-rails) es una gema envolvente para [la versión ejecutable independiente](https://tailwindcss.com/blog/standalone-cli) del framework Tailwind CSS v3. Se utiliza para nuevas aplicaciones cuando se proporciona `--css tailwind` al comando `rails new`. Proporciona un proceso `watch` para generar automáticamente la salida de Tailwind en desarrollo. En producción, se engancha en la tarea `assets:precompile`.
[`config.public_file_server.enabled`]: configuring.html#config-public-file-server-enabled
[`config.assets.digest`]: configuring.html#config-assets-digest
[`config.assets.prefix`]: configuring.html#config-assets-prefix
[`config.action_controller.asset_host`]: configuring.html#config-action-controller-asset-host
[`config.asset_host`]: configuring.html#config-asset-host
[`Cache-Control`]: https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Cache-Control
