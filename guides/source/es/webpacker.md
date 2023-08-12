**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 148ef2d23e16b9e0df83b14e98526736
Webpacker
=========

Esta guía te mostrará cómo instalar y usar Webpacker para empaquetar JavaScript, CSS y otros activos para el lado del cliente de tu aplicación Rails, pero ten en cuenta que [Webpacker ha sido retirado](https://github.com/rails/webpacker#webpacker-has-been-retired-).

Después de leer esta guía, sabrás:

* Qué hace Webpacker y por qué es diferente de Sprockets.
* Cómo instalar Webpacker e integrarlo con el framework de tu elección.
* Cómo usar Webpacker para activos de JavaScript.
* Cómo usar Webpacker para activos de CSS.
* Cómo usar Webpacker para activos estáticos.
* Cómo implementar un sitio que utiliza Webpacker.
* Cómo usar Webpacker en contextos alternativos de Rails, como motores o contenedores Docker.

--------------------------------------------------------------

¿Qué es Webpacker?
------------------

Webpacker es un envoltorio de Rails alrededor del sistema de construcción [webpack](https://webpack.js.org) que proporciona una configuración estándar de webpack y valores predeterminados razonables.

### ¿Qué es Webpack?

El objetivo de webpack, o cualquier sistema de construcción de front-end, es permitirte escribir tu código de front-end de una manera conveniente para los desarrolladores y luego empaquetar ese código de una manera conveniente para los navegadores. Con webpack, puedes gestionar JavaScript, CSS y activos estáticos como imágenes o fuentes. Webpack te permitirá escribir tu código, hacer referencia a otro código en tu aplicación, transformar tu código y combinar tu código en paquetes fácilmente descargables.

Consulta la [documentación de webpack](https://webpack.js.org) para obtener más información.

### ¿Cómo es Webpacker diferente de Sprockets?

Rails también incluye Sprockets, una herramienta de empaquetado de activos cuyas características se superponen con las de Webpacker. Ambas herramientas compilarán tu JavaScript en archivos compatibles con el navegador y también los minimizarán y les asignarán una huella digital en producción. En un entorno de desarrollo, Sprockets y Webpacker te permiten cambiar archivos de forma incremental.

Sprockets, que fue diseñado para ser utilizado con Rails, es algo más sencillo de integrar. En particular, el código se puede agregar a Sprockets a través de una gema de Ruby. Sin embargo, webpack es mejor para integrarse con herramientas JavaScript más actuales y paquetes NPM y permite una mayor variedad de integración. Las nuevas aplicaciones de Rails están configuradas para usar webpack para JavaScript y Sprockets para CSS, aunque también puedes hacer CSS en webpack.

Debes elegir Webpacker en lugar de Sprockets en un nuevo proyecto si deseas utilizar paquetes NPM y/o quieres acceder a las características y herramientas de JavaScript más actuales. Debes elegir Sprockets en lugar de Webpacker para aplicaciones heredadas donde la migración podría ser costosa, si deseas integrarte utilizando Gems o si tienes una cantidad muy pequeña de código para empaquetar.

Si estás familiarizado con Sprockets, la siguiente guía te dará una idea de cómo traducir. Ten en cuenta que cada herramienta tiene una estructura ligeramente diferente y los conceptos no se mapean directamente entre sí.

|Tarea              | Sprockets            | Webpacker         |
|------------------|----------------------|-------------------|
|Adjuntar JavaScript |javascript_include_tag|javascript_pack_tag|
|Adjuntar CSS        |stylesheet_link_tag   |stylesheet_pack_tag|
|Enlazar a una imagen  |image_url             |image_pack_tag     |
|Enlazar a un activo  |asset_url             |asset_pack_tag     |
|Requerir un script  |//= require           |import or require  |

Instalación de Webpacker
--------------------

Para usar Webpacker, debes instalar el gestor de paquetes Yarn, versión 1.x o superior, y debes tener instalado Node.js, versión 10.13.0 o superior.

NOTA: Webpacker depende de NPM y Yarn. NPM, el registro del gestor de paquetes de Node, es el repositorio principal para publicar y descargar proyectos JavaScript de código abierto, tanto para Node.js como para entornos de ejecución de navegadores. Es análogo a rubygems.org para las gemas de Ruby. Yarn es una utilidad de línea de comandos que permite la instalación y gestión de dependencias de JavaScript, al igual que Bundler lo hace para Ruby.

Para incluir Webpacker en un nuevo proyecto, agrega `--webpack` al comando `rails new`. Para agregar Webpacker a un proyecto existente, agrega la gema `webpacker` al archivo `Gemfile` del proyecto, ejecuta `bundle install` y luego ejecuta `bin/rails webpacker:install`.

La instalación de Webpacker crea los siguientes archivos locales:

|Archivo                    |Ubicación                |Explicación                                                                                         |
|------------------------|------------------------|----------------------------------------------------------------------------------------------------|
|Carpeta de JavaScript       | `app/javascript`       |Un lugar para tu código fuente de front-end                                                                   |
|Configuración de Webpacker | `config/webpacker.yml` |Configura la gema Webpacker                                                                         |
|Configuración de Babel     | `babel.config.js`      |Configuración para el compilador de JavaScript [Babel](https://babeljs.io)                               |
|Configuración de PostCSS   | `postcss.config.js`    |Configuración para el postprocesador de CSS [PostCSS](https://postcss.org)                             |
|Browserlist             | `.browserslistrc`      |[Browserlist](https://github.com/browserslist/browserslist) gestiona la configuración de los navegadores objetivo   |


La instalación también llama al gestor de paquetes `yarn`, crea un archivo `package.json` con un conjunto básico de paquetes enumerados y utiliza Yarn para instalar estas dependencias.

Uso
-----

### Uso de Webpacker para JavaScript

Con Webpacker instalado, cualquier archivo JavaScript en el directorio `app/javascript/packs` se compilará por defecto en su propio archivo de paquete.
Entonces, si tienes un archivo llamado `app/javascript/packs/application.js`, Webpacker creará un paquete llamado `application`, y puedes agregarlo a tu aplicación de Rails con el código `<%= javascript_pack_tag "application" %>`. Con eso en su lugar, en desarrollo, Rails volverá a compilar el archivo `application.js` cada vez que cambie, y cargas una página que utiliza ese paquete. Por lo general, el archivo en el directorio real `packs` será un manifiesto que carga principalmente otros archivos, pero también puede tener código JavaScript arbitrario.

El paquete predeterminado creado para ti por Webpacker se vinculará a los paquetes de JavaScript predeterminados de Rails si se han incluido en el proyecto:

```javascript
import Rails from "@rails/ujs"
import Turbolinks from "turbolinks"
import * as ActiveStorage from "@rails/activestorage"
import "channels"

Rails.start()
Turbolinks.start()
ActiveStorage.start()
```

Deberás incluir un paquete que requiera estos paquetes para usarlos en tu aplicación de Rails.

Es importante tener en cuenta que solo los archivos de entrada de webpack deben colocarse en el directorio `app/javascript/packs`; Webpack creará un gráfico de dependencias separado para cada punto de entrada, por lo que un gran número de paquetes aumentará la sobrecarga de compilación. El resto de tu código fuente de activos debe estar fuera de este directorio, aunque Webpacker no impone ninguna restricción ni hace ninguna sugerencia sobre cómo estructurar tu código fuente. Aquí tienes un ejemplo:

```sh
app/javascript:
  ├── packs:
  │   # solo archivos de entrada de webpack aquí
  │   └── application.js
  │   └── application.css
  └── src:
  │   └── my_component.js
  └── stylesheets:
  │   └── my_styles.css
  └── images:
      └── logo.svg
```

Por lo general, el archivo de paquete en sí es en gran medida un manifiesto que utiliza `import` o `require` para cargar los archivos necesarios y también puede realizar alguna inicialización.

Si deseas cambiar estos directorios, puedes ajustar `source_path` (por defecto `app/javascript`) y `source_entry_path` (por defecto `packs`) en el archivo `config/webpacker.yml`.

Dentro de los archivos fuente, las declaraciones `import` se resuelven en relación con el archivo que realiza la importación, por lo que `import Bar from "./foo"` encuentra un archivo `foo.js` en el mismo directorio que el archivo actual, mientras que `import Bar from "../src/foo"` encuentra un archivo en un directorio hermano llamado `src`.

### Usar Webpacker para CSS

De forma predeterminada, Webpacker admite CSS y SCSS utilizando el procesador PostCSS.

Para incluir código CSS en tus paquetes, primero incluye tus archivos CSS en tu archivo de paquete de nivel superior como si fuera un archivo JavaScript. Entonces, si tu manifiesto de nivel superior de CSS está en `app/javascript/styles/styles.scss`, puedes importarlo con `import styles/styles`. Esto le indica a webpack que incluya tu archivo CSS en la descarga. Para cargarlo realmente en la página, incluye `<%= stylesheet_pack_tag "application" %>` en la vista, donde `application` es el mismo nombre de paquete que estabas utilizando.

Si estás utilizando un framework de CSS, puedes agregarlo a Webpacker siguiendo las instrucciones para cargar el framework como un módulo de NPM usando `yarn`, típicamente `yarn add <framework>`. El framework debería tener instrucciones sobre cómo importarlo en un archivo CSS o SCSS.

### Usar Webpacker para activos estáticos

La configuración predeterminada de Webpacker [configuration](https://github.com/rails/webpacker/blob/master/lib/install/config/webpacker.yml#L21) debería funcionar de forma predeterminada para activos estáticos.
La configuración incluye varias extensiones de formato de archivos de imagen y fuente, lo que permite que webpack los incluya en el archivo `manifest.json` generado.

Con webpack, los activos estáticos se pueden importar directamente en archivos JavaScript. El valor importado representa la URL del activo. Por ejemplo:

```javascript
import myImageUrl from '../images/my-image.jpg'

// ...
let myImage = new Image();
myImage.src = myImageUrl;
myImage.alt = "Soy una imagen empaquetada por Webpacker";
document.body.appendChild(myImage);
```

Si necesitas hacer referencia a activos estáticos de Webpacker desde una vista de Rails, los activos deben ser requeridos explícitamente desde archivos JavaScript empaquetados por Webpacker. A diferencia de Sprockets, Webpacker no importa tus activos estáticos de forma predeterminada. El archivo `app/javascript/packs/application.js` predeterminado tiene una plantilla para importar archivos de un directorio dado, que puedes descomentar para cada directorio en el que desees tener archivos estáticos. Los directorios son relativos a `app/javascript`. La plantilla utiliza el directorio `images`, pero puedes usar cualquier cosa en `app/javascript`:

```javascript
const images = require.context("../images", true)
const imagePath = name => images(name, true)
```

Los activos estáticos se generarán en un directorio bajo `public/packs/media`. Por ejemplo, una imagen ubicada e importada en `app/javascript/images/my-image.jpg` se generará en `public/packs/media/images/my-image-abcd1234.jpg`. Para renderizar una etiqueta de imagen para esta imagen en una vista de Rails, usa `image_pack_tag 'media/images/my-image.jpg`.

Los ayudantes de ActionView de Webpacker para activos estáticos corresponden a los ayudantes de la canalización de activos según la siguiente tabla:
|Helper de ActionView | Helper de Webpacker |
|------------------|------------------|
|favicon_link_tag  |favicon_pack_tag  |
|image_tag         |image_pack_tag    |

Además, el helper genérico `asset_pack_path` toma la ubicación local de un archivo y devuelve su ubicación de Webpacker para usar en las vistas de Rails.

También puedes acceder a la imagen haciendo referencia directamente al archivo desde un archivo CSS en `app/javascript`.

### Webpacker en Rails Engines

A partir de la versión 6 de Webpacker, Webpacker no es "consciente de los engines", lo que significa que Webpacker no tiene la misma funcionalidad que Sprockets cuando se utiliza en Rails engines.

Se anima a los autores de gemas de Rails engines que deseen admitir a los consumidores que utilizan Webpacker a distribuir los activos frontend como un paquete NPM además de la gema en sí misma y proporcionar instrucciones (o un instalador) para demostrar cómo deben integrarse las aplicaciones host. Un buen ejemplo de este enfoque es [Alchemy CMS](https://github.com/AlchemyCMS/alchemy_cms).

### Hot Module Replacement (HMR)

Webpacker admite HMR de forma predeterminada con webpack-dev-server, y se puede activar o desactivar configurando la opción dev_server/hmr dentro de `webpacker.yml`.

Consulta la [documentación de webpack sobre DevServer](https://webpack.js.org/configuration/dev-server/#devserver-hot) para obtener más información.

Para admitir HMR con React, debes agregar react-hot-loader. Consulta la [guía de inicio de React Hot Loader](https://gaearon.github.io/react-hot-loader/getstarted/) para obtener más información.

No olvides desactivar HMR si no estás ejecutando webpack-dev-server; de lo contrario, obtendrás un error de "no encontrado" para las hojas de estilo.

Webpacker en diferentes entornos
-----------------------------------

Webpacker tiene tres entornos de forma predeterminada: `development`, `test` y `production`. Puedes agregar configuraciones de entorno adicionales en el archivo `webpacker.yml` y establecer diferentes valores predeterminados para cada entorno. Webpacker también cargará el archivo `config/webpack/<entorno>.js` para una configuración de entorno adicional.

## Ejecutar Webpacker en desarrollo

Webpacker incluye dos archivos binstub para ejecutar en desarrollo: `./bin/webpack` y `./bin/webpack-dev-server`. Ambos son envoltorios delgados alrededor de los ejecutables estándar `webpack.js` y `webpack-dev-server.js` y aseguran que se carguen los archivos de configuración y variables de entorno correctos según tu entorno.

De forma predeterminada, Webpacker compila automáticamente bajo demanda en desarrollo cuando se carga una página de Rails. Esto significa que no tienes que ejecutar procesos separados y los errores de compilación se registrarán en el registro estándar de Rails. Puedes cambiar esto cambiando a `compile: false` en el archivo `config/webpacker.yml`. Ejecutar `bin/webpack` forzará la compilación de tus packs.

Si deseas utilizar la recarga de código en vivo o tienes suficiente JavaScript como para que la compilación bajo demanda sea demasiado lenta, deberás ejecutar `./bin/webpack-dev-server` o `ruby ./bin/webpack-dev-server`. Este proceso detectará los cambios en los archivos `app/javascript/packs/*.js` y los volverá a compilar y recargar automáticamente en el navegador.

Los usuarios de Windows deberán ejecutar estos comandos en una terminal separada de `bundle exec rails server`.

Una vez que inicies este servidor de desarrollo, Webpacker comenzará automáticamente a redirigir todas las solicitudes de activos de webpack a este servidor. Cuando detengas el servidor, volverá a la compilación bajo demanda.

La [Documentación de Webpacker](https://github.com/rails/webpacker) proporciona información sobre las variables de entorno que puedes utilizar para controlar `webpack-dev-server`. Consulta las notas adicionales en la [documentación de rails/webpacker sobre el uso de webpack-dev-server](https://github.com/rails/webpacker#development).

### Implementación de Webpacker

Webpacker agrega una tarea `webpacker:compile` a la tarea `bin/rails assets:precompile`, por lo que cualquier canalización de implementación existente que estuviera utilizando `assets:precompile` debería funcionar. La tarea de compilación compilará los packs y los colocará en `public/packs`.

Documentación adicional
------------------------

Para obtener más información sobre temas avanzados, como el uso de Webpacker con frameworks populares, consulta la [Documentación de Webpacker](https://github.com/rails/webpacker).
