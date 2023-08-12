**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 17dc214f52c294509e9b174971ef1ab3
Contribuir a Ruby on Rails
=============================

Esta guía cubre cómo _tú_ puedes formar parte del desarrollo continuo de Ruby on Rails.

Después de leer esta guía, sabrás:

* Cómo usar GitHub para reportar problemas.
* Cómo clonar el repositorio principal y ejecutar la suite de pruebas.
* Cómo ayudar a resolver problemas existentes.
* Cómo contribuir a la documentación de Ruby on Rails.
* Cómo contribuir al código de Ruby on Rails.

Ruby on Rails no es "el marco de trabajo de otra persona". A lo largo de los años, miles de personas han contribuido a Ruby on Rails, desde un solo carácter hasta cambios arquitectónicos masivos o documentación significativa, todo para mejorar Ruby on Rails para todos. Incluso si no te sientes capaz de escribir código o documentación todavía, hay varias otras formas en las que puedes contribuir, desde informar problemas hasta probar parches.

Como se menciona en el [README de Rails](https://github.com/rails/rails/blob/main/README.md), se espera que todos los que interactúen en los repositorios de código, rastreadores de problemas, salas de chat, foros de discusión y listas de correo de Rails y sus subproyectos sigan el [código de conducta](https://rubyonrails.org/conduct) de Rails.

--------------------------------------------------------------------------------

Reportar un problema
------------------

Ruby on Rails utiliza [GitHub Issue Tracking](https://github.com/rails/rails/issues) para rastrear problemas (principalmente errores y contribuciones de nuevo código). Si has encontrado un error en Ruby on Rails, este es el lugar para comenzar. Necesitarás crear una cuenta de GitHub (gratuita) para enviar un problema, comentar problemas o crear solicitudes de extracción.

NOTA: Los errores en la versión más reciente de Ruby on Rails probablemente recibirán más atención. Además, el equipo central de Rails siempre está interesado en recibir comentarios de aquellos que puedan tomarse el tiempo para probar _edge Rails_ (el código de la versión de Rails que está actualmente en desarrollo). Más adelante en esta guía, descubrirás cómo obtener edge Rails para probar. Consulta nuestra [política de mantenimiento](maintenance_policy.html) para obtener información sobre qué versiones son compatibles. Nunca informes un problema de seguridad en el rastreador de problemas de GitHub.

### Crear un informe de error

Si has encontrado un problema en Ruby on Rails que no representa un riesgo de seguridad, busca en [Issues](https://github.com/rails/rails/issues) en GitHub, por si ya se ha informado. Si no puedes encontrar problemas abiertos en GitHub que aborden el problema que encontraste, tu siguiente paso será [abrir un nuevo problema](https://github.com/rails/rails/issues/new). (Consulta la siguiente sección para informar problemas de seguridad).

Hemos proporcionado una plantilla de problema para que, al crear un problema, incluyas toda la información necesaria para determinar si hay un error en el marco de trabajo. Cada problema debe incluir un título y una descripción clara del problema. Asegúrate de incluir toda la información relevante posible, incluido un ejemplo de código o una prueba fallida que demuestre el comportamiento esperado, así como la configuración de tu sistema. Tu objetivo debe ser facilitar a ti mismo, y a los demás, reproducir el error y encontrar una solución.

Una vez que abras un problema, es posible que no veas actividad de inmediato, a menos que sea un error "Rojo, Crítico, el Mundo se está Acabando". Eso no significa que no nos importe tu error, solo que hay muchos problemas y solicitudes de extracción para revisar. Otras personas con el mismo problema pueden encontrar tu problema, confirmar el error y colaborar contigo para solucionarlo. Si sabes cómo solucionar el error, adelante y abre una solicitud de extracción.

### Crear un caso de prueba ejecutable

Tener una forma de reproducir tu problema ayudará a las personas a confirmar, investigar y, en última instancia, solucionar tu problema. Puedes hacer esto proporcionando un caso de prueba ejecutable. Para facilitar este proceso, hemos preparado varias plantillas de informe de errores para que las uses como punto de partida:

* Plantilla para problemas de Active Record (modelos, base de datos): [gem](https://github.com/rails/rails/blob/main/guides/bug_report_templates/active_record_gem.rb) / [main](https://github.com/rails/rails/blob/main/guides/bug_report_templates/active_record_main.rb)
* Plantilla para problemas de prueba de Active Record (migraciones): [gem](https://github.com/rails/rails/blob/main/guides/bug_report_templates/active_record_migrations_gem.rb) / [main](https://github.com/rails/rails/blob/main/guides/bug_report_templates/active_record_migrations_main.rb)
* Plantilla para problemas de Action Pack (controladores, enrutamiento): [gem](https://github.com/rails/rails/blob/main/guides/bug_report_templates/action_controller_gem.rb) / [main](https://github.com/rails/rails/blob/main/guides/bug_report_templates/action_controller_main.rb)
* Plantilla para problemas de Active Job: [gem](https://github.com/rails/rails/blob/main/guides/bug_report_templates/active_job_gem.rb) / [main](https://github.com/rails/rails/blob/main/guides/bug_report_templates/active_job_main.rb)
* Plantilla para problemas de Active Storage: [gem](https://github.com/rails/rails/blob/main/guides/bug_report_templates/active_storage_gem.rb) / [main](https://github.com/rails/rails/blob/main/guides/bug_report_templates/active_storage_main.rb)
* Plantilla para problemas de Action Mailbox: [gem](https://github.com/rails/rails/blob/main/guides/bug_report_templates/action_mailbox_gem.rb) / [main](https://github.com/rails/rails/blob/main/guides/bug_report_templates/action_mailbox_main.rb)
* Plantilla genérica para otros problemas: [gem](https://github.com/rails/rails/blob/main/guides/bug_report_templates/generic_gem.rb) / [main](https://github.com/rails/rails/blob/main/guides/bug_report_templates/generic_main.rb)

Estas plantillas incluyen el código base para configurar un caso de prueba contra una versión lanzada de Rails (`*_gem.rb`) o edge Rails (`*_main.rb`).
Copia el contenido de la plantilla adecuada en un archivo `.rb` y realiza los cambios necesarios para demostrar el problema. Puedes ejecutarlo ejecutando `ruby the_file.rb` en tu terminal. Si todo va bien, deberías ver que tu caso de prueba falla.

Luego, puedes compartir tu caso de prueba ejecutable como un [gist](https://gist.github.com) o pegar el contenido en la descripción del problema.

### Tratamiento especial para problemas de seguridad

ADVERTENCIA: No informes vulnerabilidades de seguridad mediante informes públicos de problemas en GitHub. La página de política de seguridad de Rails (https://rubyonrails.org/security) detalla el procedimiento a seguir para problemas de seguridad.

### ¿Qué hay de las solicitudes de funciones?

Por favor, no incluyas elementos de "solicitud de función" en los problemas de GitHub. Si hay una nueva función que deseas ver agregada a Ruby on Rails, deberás escribir el código tú mismo o convencer a alguien más para que se asocie contigo para escribir el código. Más adelante en esta guía, encontrarás instrucciones detalladas para proponer un parche para Ruby on Rails. Si ingresas un elemento de lista de deseos en los problemas de GitHub sin código, puedes esperar que se marque como "inválido" tan pronto como se revise.

A veces, la línea entre 'error' y 'función' es difícil de trazar. En general, una función es cualquier cosa que agregue un nuevo comportamiento, mientras que un error es cualquier cosa que cause un comportamiento incorrecto. A veces, el equipo principal tendrá que tomar una decisión. Dicho esto, la distinción generalmente determina en qué parche se lanzará tu cambio; ¡nos encantan las contribuciones de funciones! Simplemente no se volverán a aplicar en las ramas de mantenimiento.

Si deseas recibir comentarios sobre una idea para una función antes de hacer el trabajo para crear un parche, inicia una discusión en el [foro de discusión de rails-core](https://discuss.rubyonrails.org/c/rubyonrails-core). Es posible que no obtengas respuesta, lo que significa que a todos les da igual. Es posible que encuentres a alguien que también esté interesado en construir esa función. Es posible que obtengas un "Esto no será aceptado". Pero es el lugar adecuado para discutir nuevas ideas. Los problemas de GitHub no son un lugar especialmente adecuado para las discusiones a veces largas y complicadas que requieren las nuevas funciones.


Ayudar a resolver problemas existentes
----------------------------------

Además de informar problemas, puedes ayudar al equipo principal a resolver los existentes proporcionando comentarios sobre ellos. Si eres nuevo en el desarrollo principal de Rails, proporcionar comentarios te ayudará a familiarizarte con el código y los procesos.

Si revisas la [lista de problemas](https://github.com/rails/rails/issues) en GitHub Issues, encontrarás muchos problemas que ya requieren atención. ¿Qué puedes hacer al respecto? Bastante, de hecho:

### Verificación de informes de errores

Para empezar, ayuda simplemente verificar los informes de errores. ¿Puedes reproducir el problema informado en tu computadora? Si es así, puedes agregar un comentario al problema diciendo que estás viendo lo mismo.

Si un problema es muy vago, ¿puedes ayudar a reducirlo a algo más específico? Tal vez puedas proporcionar información adicional para reproducir el error, o tal vez puedas eliminar pasos innecesarios que no son necesarios para demostrar el problema.

Si encuentras un informe de error sin una prueba, es muy útil contribuir con una prueba que falle. Esta también es una excelente manera de explorar el código fuente: mirar los archivos de prueba existentes te enseñará cómo escribir más pruebas. Las nuevas pruebas se deben contribuir en forma de parche, como se explica más adelante en la sección [Contribución al código de Rails](#contributing-to-the-rails-code).

Cualquier cosa que puedas hacer para que los informes de errores sean más concisos o más fáciles de reproducir ayuda a las personas que intentan escribir código para solucionar esos errores, ya sea que termines escribiendo el código tú mismo o no.

### Pruebas de parches

También puedes ayudar examinando las solicitudes de extracción que se han enviado a Ruby on Rails a través de GitHub. Para aplicar los cambios de alguien, primero crea una rama dedicada:

```bash
$ git checkout -b testing_branch
```

Luego, puedes usar su rama remota para actualizar tu código base. Por ejemplo, digamos que el usuario de GitHub JohnSmith ha bifurcado y ha enviado a una rama de tema "orange" ubicada en https://github.com/JohnSmith/rails.

```bash
$ git remote add JohnSmith https://github.com/JohnSmith/rails.git
$ git pull JohnSmith orange
```

Una alternativa a agregar su remoto a tu repositorio es usar la [herramienta de línea de comandos de GitHub](https://cli.github.com/) para revisar su solicitud de extracción.

Después de aplicar su rama, ¡pruébala! Aquí hay algunas cosas en las que pensar:
* ¿La modificación realmente funciona?
* ¿Estás satisfecho con las pruebas? ¿Puedes entender qué están probando? ¿Falta alguna prueba?
* ¿Tiene la cobertura de documentación adecuada? ¿Debería actualizarse la documentación en otro lugar?
* ¿Te gusta la implementación? ¿Puedes pensar en una forma más agradable o más rápida de implementar una parte de su cambio?

Una vez que estés satisfecho de que la solicitud de extracción contiene un buen cambio, comenta en el problema de GitHub indicando tus hallazgos. Tu comentario debe indicar que te gusta el cambio y qué te gusta de él. Algo como:

> Me gusta la forma en que has reestructurado ese código en generate_finder_sql, mucho mejor. Las pruebas también se ven bien.

Si tu comentario simplemente dice "+1", es probable que otros revisores no lo tomen muy en serio. Muestra que te tomaste el tiempo para revisar la solicitud de extracción.

Contribuir a la documentación de Rails
--------------------------------------

Ruby on Rails tiene dos conjuntos principales de documentación: las guías, que te ayudan a aprender sobre Ruby on Rails, y la API, que sirve como referencia.

Puedes ayudar a mejorar las guías de Rails o la referencia de la API haciéndolas más coherentes, consistentes o legibles, agregando información faltante, corrigiendo errores factuales, corrigiendo errores tipográficos o actualizándolas con la última versión de Rails.

Para hacerlo, realiza cambios en los archivos fuente de las guías de Rails (ubicados [aquí](https://github.com/rails/rails/tree/main/guides/source) en GitHub) o en los comentarios RDoc en el código fuente. Luego, abre una solicitud de extracción para aplicar tus cambios a la rama principal.

Cuando trabajes con la documentación, ten en cuenta las [Directrices de documentación de la API](api_documentation_guidelines.html) y las [Directrices de las guías de Ruby on Rails](ruby_on_rails_guides_guidelines.html).

Traducción de las guías de Rails
-------------------------------

Nos complace contar con personas voluntarias para traducir las guías de Rails. Solo sigue estos pasos:

* Haz un fork de https://github.com/rails/rails.
* Agrega una carpeta de origen para tu idioma, por ejemplo: *guides/source/it-IT* para italiano.
* Copia el contenido de *guides/source* en tu directorio de idioma y tradúcelo.
* NO traduzcas los archivos HTML, ya que se generan automáticamente.

Ten en cuenta que las traducciones no se envían al repositorio de Rails; tu trabajo vive en tu fork, como se describe anteriormente. Esto se debe a que, en la práctica, el mantenimiento de la documentación a través de parches solo es sostenible en inglés.

Para generar las guías en formato HTML, deberás instalar las dependencias de las guías, `cd` en el directorio *guides* y luego ejecutar (por ejemplo, para it-IT):

```bash
# solo instala las gemas necesarias para las guías. Para deshacer, ejecuta: bundle config --delete without
$ bundle install --without job cable storage ujs test db
$ cd guides/
$ bundle exec rake guides:generate:html GUIDES_LANGUAGE=it-IT
```

Esto generará las guías en un directorio *output*.

NOTA: La gema Redcarpet no funciona con JRuby.

Esfuerzos de traducción que conocemos (varias versiones):

* **Italiano**: [https://github.com/rixlabs/docrails](https://github.com/rixlabs/docrails)
* **Español**: [https://github.com/latinadeveloper/railsguides.es](https://github.com/latinadeveloper/railsguides.es)
* **Polaco**: [https://github.com/apohllo/docrails](https://github.com/apohllo/docrails)
* **Francés**: [https://github.com/railsfrance/docrails](https://github.com/railsfrance/docrails)
* **Checo**: [https://github.com/rubyonrails-cz/docrails/tree/czech](https://github.com/rubyonrails-cz/docrails/tree/czech)
* **Turco**: [https://github.com/ujk/docrails](https://github.com/ujk/docrails)
* **Coreano**: [https://github.com/rorlakr/rails-guides](https://github.com/rorlakr/rails-guides)
* **Chino simplificado**: [https://github.com/ruby-china/guides](https://github.com/ruby-china/guides)
* **Chino tradicional**: [https://github.com/docrails-tw/guides](https://github.com/docrails-tw/guides)
* **Ruso**: [https://github.com/morsbox/rusrails](https://github.com/morsbox/rusrails)
* **Japonés**: [https://github.com/yasslab/railsguides.jp](https://github.com/yasslab/railsguides.jp)
* **Portugués brasileño**: [https://github.com/campuscode/rails-guides-pt-BR](https://github.com/campuscode/rails-guides-pt-BR)

Contribuir al código de Rails
----------------------------

### Configuración de un entorno de desarrollo

Para pasar de enviar errores a ayudar a resolver problemas existentes o contribuir con tu propio código a Ruby on Rails, _debes_ poder ejecutar su conjunto de pruebas. En esta sección de la guía, aprenderás cómo configurar las pruebas en tu computadora.

#### Usando GitHub Codespaces

Si eres miembro de una organización que tiene habilitados los codespaces, puedes hacer un fork de Rails en esa organización y usar los codespaces en GitHub. El codespace se inicializará con todas las dependencias requeridas y te permitirá ejecutar todas las pruebas.

#### Usando VS Code Remote Containers

Si tienes [Visual Studio Code](https://code.visualstudio.com) y [Docker](https://www.docker.com) instalados, puedes usar el complemento [VS Code remote containers](https://code.visualstudio.com/docs/remote/containers-tutorial). El complemento leerá la configuración [`.devcontainer`](https://github.com/rails/rails/tree/main/.devcontainer) en el repositorio y construirá el contenedor Docker localmente.

#### Usando Dev Container CLI

Alternativamente, con [Docker](https://www.docker.com) y [npm](https://github.com/npm/cli) instalados, puedes ejecutar [Dev Container CLI](https://github.com/devcontainers/cli) para utilizar la configuración [`.devcontainer`](https://github.com/rails/rails/tree/main/.devcontainer) desde la línea de comandos.

```bash
$ npm install -g @devcontainers/cli
$ cd rails
$ devcontainer up --workspace-folder .
$ devcontainer exec --workspace-folder . bash
```

#### Usando rails-dev-box

También es posible utilizar el [rails-dev-box](https://github.com/rails/rails-dev-box) para obtener un entorno de desarrollo listo. Sin embargo, el rails-dev-box utiliza Vagrant y Virtual Box, lo cual no funcionará en Macs con Apple silicon.
#### Desarrollo local

Cuando no puedes usar GitHub Codespaces, consulta [esta otra guía](development_dependencies_install.html) para aprender cómo configurar el desarrollo local. Esto se considera el método difícil porque la instalación de dependencias puede depender del sistema operativo.

### Clonar el repositorio de Rails

Para poder contribuir con código, necesitas clonar el repositorio de Rails:

```bash
$ git clone https://github.com/rails/rails.git
```

y crear una rama dedicada:

```bash
$ cd rails
$ git checkout -b my_new_branch
```

No importa mucho qué nombre uses, porque esta rama solo existirá en tu computadora local y en tu repositorio personal en GitHub. No formará parte del repositorio Git de Rails.

### Bundle install

Instala las gemas requeridas.

```bash
$ bundle install
```

### Ejecutar una aplicación con tu rama local

En caso de que necesites una aplicación de prueba de Rails para probar cambios, la opción `--dev` de `rails new` genera una aplicación que utiliza tu rama local:

```bash
$ cd rails
$ bundle exec rails new ~/my-test-app --dev
```

La aplicación generada en `~/my-test-app` se ejecuta con tu rama local y, en particular, muestra cualquier modificación al reiniciar el servidor.

Para los paquetes de JavaScript, puedes usar [`yarn link`](https://yarnpkg.com/cli/link) para vincular tu rama local en una aplicación generada:

```bash
$ cd rails/activestorage
$ yarn link
$ cd ~/my-test-app
$ yarn link "@rails/activestorage"
```

### Escribe tu código

¡Ahora es el momento de escribir código! Al hacer cambios en Rails, aquí tienes algunas cosas que debes tener en cuenta:

* Sigue el estilo y las convenciones de Rails.
* Utiliza los ídolos y ayudantes de Rails.
* Incluye pruebas que fallen sin tu código y pasen con él.
* Actualiza la documentación (circundante), los ejemplos en otros lugares y las guías: todo lo que se vea afectado por tu contribución.
* Si el cambio agrega, elimina o cambia una función, asegúrate de incluir una entrada en el CHANGELOG. Si tu cambio es una corrección de errores, no es necesario incluir una entrada en el CHANGELOG.

CONSEJO: Los cambios que son cosméticos y no agregan nada sustancial a la estabilidad, funcionalidad o capacidad de prueba de Rails generalmente no serán aceptados (lee más sobre [nuestra justificación detrás de esta decisión](https://github.com/rails/rails/pull/13771#issuecomment-32746700)).

#### Sigue las convenciones de codificación

Rails sigue un conjunto simple de convenciones de estilo de codificación:

* Dos espacios, no tabulaciones (para la indentación).
* Sin espacios en blanco al final. Las líneas en blanco no deben tener espacios.
* Indenta y no dejes una línea en blanco después de `private/protected`.
* Utiliza la sintaxis de Ruby >= 1.9 para los hashes. Prefiere `{ a: :b }` en lugar de `{ :a => :b }`.
* Prefiere `&&`/`||` en lugar de `and`/`or`.
* Prefiere `class << self` en lugar de `self.method` para los métodos de clase.
* Utiliza `my_method(my_arg)` en lugar de `my_method( my_arg )` o `my_method my_arg`.
* Utiliza `a = b` en lugar de `a=b`.
* Utiliza los métodos `assert_not` en lugar de `refute`.
* Prefiere `method { do_stuff }` en lugar de `method{do_stuff}` para bloques de una sola línea.
* Sigue las convenciones del código fuente que ya ves utilizado.

Estas son pautas, por favor, utiliza tu mejor criterio al aplicarlas.

Además, tenemos reglas de [RuboCop](https://www.rubocop.org/) definidas para codificar algunas de nuestras convenciones de codificación. Puedes ejecutar RuboCop localmente contra el archivo que has modificado antes de enviar una solicitud de extracción:

```bash
$ bundle exec rubocop actionpack/lib/action_controller/metal/strong_parameters.rb
Inspecting 1 file
.

1 file inspected, no offenses detected
```

Para los archivos de CoffeeScript y JavaScript de `rails-ujs`, puedes ejecutar `npm run lint` en la carpeta `actionview`.

#### Verificación ortográfica

Ejecutamos [misspell](https://github.com/client9/misspell), que está escrito principalmente en [Golang](https://golang.org/), para verificar la ortografía con [GitHub Actions](https://github.com/rails/rails/blob/main/.github/workflows/lint.yml). Corrige rápidamente palabras en inglés comúnmente mal escritas con `misspell`. `misspell` es diferente a la mayoría de los correctores ortográficos porque no utiliza un diccionario personalizado. Puedes ejecutar `misspell` localmente en todos los archivos con:

```bash
$ find . -type f | xargs ./misspell -i 'aircrafts,devels,invertions' -error
```

Algunas opciones o banderas destacadas de `misspell` son:

- `-i` cadena: ignora las siguientes correcciones, separadas por comas
- `-w`: sobrescribe el archivo con las correcciones (el valor predeterminado es solo mostrarlas)

También ejecutamos [codespell](https://github.com/codespell-project/codespell) con GitHub Actions para verificar la ortografía y [codespell](https://pypi.org/project/codespell/) se ejecuta con un [pequeño diccionario personalizado](https://github.com/rails/rails/blob/main/codespell.txt). `codespell` está escrito en [Python](https://www.python.org/) y puedes ejecutarlo con:

```bash
$ codespell --ignore-words=codespell.txt
```

### Evalúa el rendimiento de tu código

Para los cambios que puedan tener un impacto en el rendimiento, por favor evalúa el rendimiento de tu código y mide el impacto. Por favor, comparte el script de evaluación que utilizaste y los resultados. Deberías considerar incluir esta información en el mensaje de tu confirmación, para permitir que los futuros colaboradores verifiquen fácilmente tus hallazgos y determinen si siguen siendo relevantes. (Por ejemplo, futuras optimizaciones en la máquina virtual de Ruby podrían hacer que ciertas optimizaciones sean innecesarias).
Cuando se optimiza para un escenario específico en el que te importa, es fácil que el rendimiento se vea afectado en otros casos comunes. Por lo tanto, debes probar tu cambio con una lista de escenarios representativos, idealmente extraídos de aplicaciones de producción del mundo real.

Puedes utilizar la [plantilla de benchmark](https://github.com/rails/rails/blob/main/guides/bug_report_templates/benchmark.rb) como punto de partida. Incluye el código de plantilla necesario para configurar un benchmark utilizando la gema [benchmark-ips](https://github.com/evanphx/benchmark-ips). La plantilla está diseñada para probar cambios relativamente autónomos que se pueden incluir en el script.

### Ejecución de pruebas

No es habitual en Rails ejecutar el conjunto completo de pruebas antes de enviar los cambios. El conjunto de pruebas de railties, en particular, lleva mucho tiempo y llevará aún más tiempo si el código fuente está montado en `/vagrant`, como ocurre en el flujo de trabajo recomendado con [rails-dev-box](https://github.com/rails/rails-dev-box).

Como compromiso, prueba lo que tu código afecta obviamente y, si el cambio no está en railties, ejecuta el conjunto completo de pruebas del componente afectado. Si todas las pruebas pasan, eso es suficiente para proponer tu contribución. Tenemos [Buildkite](https://buildkite.com/rails/rails) como una red de seguridad para detectar errores inesperados en otros lugares.

#### Rails completo:

Para ejecutar todas las pruebas, haz lo siguiente:

```bash
$ cd rails
$ bundle exec rake test
```

#### Para un componente específico

Puedes ejecutar pruebas solo para un componente específico (por ejemplo, Action Pack). Por ejemplo, para ejecutar las pruebas de Action Mailer:

```bash
$ cd actionmailer
$ bin/test
```

#### Para un directorio específico

Puedes ejecutar pruebas solo para un directorio específico de un componente en particular (por ejemplo, modelos en Active Storage). Por ejemplo, para ejecutar pruebas en `/activestorage/test/models`:

```bash
$ cd activestorage
$ bin/test models
```

#### Para un archivo específico

Puedes ejecutar las pruebas para un archivo específico:

```bash
$ cd actionview
$ bin/test test/template/form_helper_test.rb
```

#### Ejecución de una sola prueba

Puedes ejecutar una sola prueba por nombre utilizando la opción `-n`:

```bash
$ cd actionmailer
$ bin/test test/mail_layout_test.rb -n test_explicit_class_layout
```

#### Para una línea específica

No siempre es fácil determinar el nombre, pero si conoces el número de línea en el que comienza tu prueba, esta opción es para ti:

```bash
$ cd railties
$ bin/test test/application/asset_debugging_test.rb:69
```

#### Ejecución de pruebas con una semilla específica

La ejecución de pruebas es aleatoria con una semilla de aleatorización. Si experimentas fallas de prueba aleatorias, puedes reproducir de manera más precisa un escenario de prueba fallido estableciendo específicamente la semilla de aleatorización.

Ejecutando todas las pruebas para un componente:

```bash
$ cd actionmailer
$ SEED=15002 bin/test
```

Ejecutando un solo archivo de prueba:

```bash
$ cd actionmailer
$ SEED=15002 bin/test test/mail_layout_test.rb
```

#### Ejecución de pruebas en serie

Las pruebas unitarias de Action Pack y Action View se ejecutan en paralelo de forma predeterminada. Si experimentas fallas de prueba aleatorias, puedes establecer la semilla de aleatorización y permitir que estas pruebas unitarias se ejecuten en serie estableciendo `PARALLEL_WORKERS=1`

```bash
$ cd actionview
$ PARALLEL_WORKERS=1 SEED=53708 bin/test test/template/test_case_test.rb
```

#### Pruebas de Active Record

Primero, crea las bases de datos que necesitarás. Puedes encontrar una lista de los nombres de tabla, nombres de usuario y contraseñas requeridos en `activerecord/test/config.example.yml`.

Para MySQL y PostgreSQL, es suficiente con ejecutar:

```bash
$ cd activerecord
$ bundle exec rake db:mysql:build
```

O:

```bash
$ cd activerecord
$ bundle exec rake db:postgresql:build
```

Esto no es necesario para SQLite3.

Así es como ejecutas el conjunto de pruebas de Active Record solo para SQLite3:

```bash
$ cd activerecord
$ bundle exec rake test:sqlite3
```

Ahora puedes ejecutar las pruebas como lo hiciste para `sqlite3`. Las tareas son respectivamente:

```bash
$ bundle exec rake test:mysql2
$ bundle exec rake test:trilogy
$ bundle exec rake test:postgresql
```

Finalmente,

```bash
$ bundle exec rake test
```

ejecutará las tres pruebas a su vez.

También puedes ejecutar cualquier prueba individualmente:

```bash
$ ARCONN=mysql2 bundle exec ruby -Itest test/cases/associations/has_many_associations_test.rb
```

Para ejecutar una sola prueba en todos los adaptadores, utiliza:

```bash
$ bundle exec rake TEST=test/cases/associations/has_many_associations_test.rb
```

También puedes invocar `test_jdbcmysql`, `test_jdbcsqlite3` o `test_jdbcpostgresql`. Consulta el archivo `activerecord/RUNNING_UNIT_TESTS.rdoc` para obtener información sobre cómo ejecutar pruebas de bases de datos más específicas.

#### Uso de depuradores con pruebas

Para utilizar un depurador externo (pry, byebug, etc.), instala el depurador y úsalo normalmente. Si ocurren problemas con el depurador, ejecuta las pruebas en serie estableciendo `PARALLEL_WORKERS=1` o ejecuta una sola prueba con `-n test_long_test_name`.

### Advertencias

El conjunto de pruebas se ejecuta con advertencias habilitadas. Idealmente, Ruby on Rails no debería emitir advertencias, pero puede haber algunas, así como algunas de bibliotecas de terceros. Por favor, ignóralas (¡o soluciónalas!) y envía parches que no emitan nuevas advertencias.
Rails CI generará un error si se introducen advertencias. Para implementar el mismo comportamiento localmente, establezca `RAILS_STRICT_WARNINGS=1` al ejecutar la suite de pruebas.

### Actualización de la documentación

Las [guías](https://guides.rubyonrails.org/) de Ruby on Rails proporcionan una visión general de alto nivel de las características de Rails, mientras que la [documentación de la API](https://api.rubyonrails.org/) se adentra en los detalles específicos.

Si su PR agrega una nueva característica o cambia cómo se comporta una característica existente, verifique la documentación relevante y actualícela o agréguela según sea necesario.

Por ejemplo, si modifica el analizador de imágenes de Active Storage para agregar un nuevo campo de metadatos, debe actualizar la sección [Análisis de archivos](active_storage_overview.html#analyzing-files) de la guía de Active Storage para reflejar eso.

### Actualización del CHANGELOG

El CHANGELOG es una parte importante de cada versión. Mantiene la lista de cambios para cada versión de Rails.

Debe agregar una entrada **al principio** del CHANGELOG del framework que modificó si está agregando o eliminando una característica o agregando avisos de deprecación. Los cambios de refactorización, correcciones de errores menores y cambios en la documentación generalmente no deben ir al CHANGELOG.

Una entrada en el CHANGELOG debe resumir lo que se cambió y debe terminar con el nombre del autor. Puede usar varias líneas si necesita más espacio y puede adjuntar ejemplos de código con sangría de 4 espacios. Si un cambio está relacionado con un problema específico, debe adjuntar el número del problema. Aquí hay un ejemplo de entrada en el CHANGELOG:

```
*   Resumen de un cambio que describe brevemente lo que se cambió. Puede usar varias
    líneas y envolverlas alrededor de 80 caracteres. Los ejemplos de código también están bien si es necesario:

        class Foo
          def bar
            puts 'baz'
          end
        end

    Puede continuar después del ejemplo de código y puede adjuntar el número del problema.

    Soluciona #1234.

    *Tu Nombre*
```

Su nombre se puede agregar directamente después de la última palabra si no hay ejemplos de código o varios párrafos. De lo contrario, es mejor hacer un nuevo párrafo.

### Cambios que rompen la compatibilidad

Cualquier cambio que pueda romper aplicaciones existentes se considera un cambio que rompe la compatibilidad. Para facilitar la actualización de las aplicaciones de Rails, los cambios que rompen la compatibilidad requieren un ciclo de deprecación.

#### Eliminación de comportamiento

Si su cambio que rompe la compatibilidad elimina un comportamiento existente, primero deberá agregar una advertencia de deprecación manteniendo el comportamiento existente.

Como ejemplo, supongamos que desea eliminar un método público en `ActiveRecord::Base`. Si la rama principal apunta a la versión no lanzada 7.0, Rails 7.0 deberá mostrar una advertencia de deprecación. Esto asegura que cualquier persona que actualice a cualquier versión de Rails 7.0 verá la advertencia de deprecación. En Rails 7.1, el método se puede eliminar.

Podría agregar la siguiente advertencia de deprecación:

```ruby
def metodo_deprecado
  ActiveRecord.deprecator.warn(<<-MSG.squish)
    `ActiveRecord::Base.metodo_deprecado` está en desuso y se eliminará en Rails 7.1.
  MSG
  # Comportamiento existente
end
```

#### Cambio de comportamiento

Si su cambio que rompe la compatibilidad cambia un comportamiento existente, deberá agregar un valor predeterminado del framework. Los valores predeterminados del framework facilitan las actualizaciones de Rails al permitir que las aplicaciones cambien a los nuevos valores predeterminados uno por uno.

Para implementar un nuevo valor predeterminado del framework, primero cree una configuración agregando un accesorio en el framework objetivo. Establezca el valor predeterminado en el comportamiento existente para asegurarse de que nada se rompa durante una actualización.

```ruby
module ActiveJob
  mattr_accessor :comportamiento_existente, default: true
end
```

La nueva configuración le permite implementar condicionalmente el nuevo comportamiento:

```ruby
def metodo_cambiado
  if ActiveJob.comportamiento_existente
    # Comportamiento existente
  else
    # Nuevo comportamiento
  end
end
```

Para establecer el nuevo valor predeterminado del framework, establezca el nuevo valor en `Rails::Application::Configuration#load_defaults`:

```ruby
def load_defaults(target_version)
  case target_version.to_s
  when "7.1"
    ...
    if respond_to?(:active_job)
      active_job.comportamiento_existente = false
    end
    ...
  end
end
```

Para facilitar la actualización, es necesario agregar el nuevo valor predeterminado a la plantilla `new_framework_defaults`. Agregue una sección comentada, estableciendo el nuevo valor:

```ruby
# new_framework_defaults_7_1.rb.tt

# Rails.application.config.active_job.comportamiento_existente = false
```

Como último paso, agregue la nueva configuración a la guía de configuración en `configuration.md`:

```markdown
#### `config.active_job.comportamiento_existente`

| A partir de la versión | El valor predeterminado es |
| --------------------- | ------------------------- |
| (original)            | `true`                    |
| 7.1                   | `false`                   |
```

### Ignorar archivos creados por su editor / IDE

Algunos editores e IDE crearán archivos o carpetas ocultas dentro de la carpeta `rails`. En lugar de excluirlos manualmente de cada confirmación o agregarlos a `.gitignore` de Rails, debe agregarlos a su propio [archivo global de ignorados de git](https://docs.github.com/en/get-started/getting-started-with-git/ignoring-files#configuring-ignored-files-for-all-repositories-on-your-computer).

### Actualización del Gemfile.lock

Algunos cambios requieren actualizaciones de dependencias. En estos casos, asegúrese de ejecutar `bundle update` para obtener la versión correcta de la dependencia y confirme el archivo `Gemfile.lock` dentro de sus cambios.
### Realizar tus cambios

Cuando estés satisfecho con el código en tu computadora, debes realizar los cambios en Git:

```bash
$ git commit -a
```

Esto abrirá tu editor para escribir un mensaje de confirmación. Cuando hayas terminado, guarda y cierra para continuar.

Un mensaje de confirmación bien formateado y descriptivo es muy útil para que otros entiendan por qué se realizó el cambio, así que tómate el tiempo para escribirlo.

Un buen mensaje de confirmación se ve así:

```
Resumen breve (idealmente 50 caracteres o menos)

Descripción más detallada, si es necesario. Cada línea debe tener un
máximo de 72 caracteres. Intenta ser lo más descriptivo posible. Incluso si
crees que el contenido de la confirmación es obvio, puede que no lo sea
para otros. Agrega cualquier descripción que ya esté presente en los
problemas relevantes; no debería ser necesario visitar una página web
para verificar el historial.

La sección de descripción puede tener varios párrafos.

Los ejemplos de código se pueden incluir sangrando con 4 espacios:

    class ArticlesController
      def index
        render json: Article.limit(10)
      end
    end

También puedes agregar viñetas:

- hacer una viñeta comenzando una línea con un guion (-)
  o un asterisco (*)

- envuelve las líneas a 72 caracteres, e indenta cualquier línea adicional
  con 2 espacios para mayor legibilidad
```

CONSEJO. Por favor, combina tus confirmaciones en una sola cuando sea apropiado. Esto
simplifica futuras selecciones de cerezas y mantiene el registro de git limpio.

### Actualiza tu rama

Es bastante probable que se hayan realizado otros cambios en main mientras estabas trabajando. Para obtener los nuevos cambios en main:

```bash
$ git checkout main
$ git pull --rebase
```

Ahora vuelve a aplicar tu parche sobre los últimos cambios:

```bash
$ git checkout my_new_branch
$ git rebase main
```

¿No hay conflictos? ¿Las pruebas aún pasan? ¿El cambio aún te parece razonable? Luego, envía los cambios rebaseados a GitHub:

```bash
$ git push --force-with-lease
```

No permitimos la fuerza de empuje en el repositorio base de rails/rails, pero puedes hacerlo en tu bifurcación. Al rebasear, esto es un requisito ya que el historial ha cambiado.

### Bifurcar

Ve al repositorio de Rails en [GitHub](https://github.com/rails/rails) y presiona "Fork" en la esquina superior derecha.

Agrega el nuevo remoto a tu repositorio local en tu máquina:

```bash
$ git remote add fork https://github.com/<tu nombre de usuario>/rails.git
```

Es posible que hayas clonado tu repositorio local desde rails/rails, o puede que lo hayas clonado desde tu repositorio bifurcado. Los siguientes comandos de git asumen que has creado un remoto "rails" que apunta a rails/rails.

```bash
$ git remote add rails https://github.com/rails/rails.git
```

Descarga nuevos commits y ramas del repositorio oficial:

```bash
$ git fetch rails
```

Fusiona el nuevo contenido:

```bash
$ git checkout main
$ git rebase rails/main
$ git checkout my_new_branch
$ git rebase rails/main
```

Actualiza tu bifurcación:

```bash
$ git push fork main
$ git push fork my_new_branch
```

### Abrir una solicitud de extracción

Ve al repositorio de Rails que acabas de enviar (por ejemplo,
https://github.com/tu-nombre-de-usuario/rails) y haz clic en "Pull Requests" en la barra superior (justo encima del código).
En la siguiente página, haz clic en "New pull request" en la esquina superior derecha.

La solicitud de extracción debe apuntar al repositorio base `rails/rails` y la rama `main`.
El repositorio de origen será tu trabajo (`tu-nombre-de-usuario/rails`), y la rama será
el nombre que le hayas dado a tu rama. Haz clic en "create pull request" cuando estés listo.

Asegúrate de que los cambios que has introducido estén incluidos. Completa algunos detalles sobre
tu parche potencial, utilizando la plantilla de solicitud de extracción proporcionada. Cuando hayas terminado, haz clic en "Create
pull request".

### Obtén algunos comentarios

La mayoría de las solicitudes de extracción pasarán por algunas iteraciones antes de ser fusionadas.
Diferentes colaboradores a veces tendrán opiniones diferentes, y a menudo
los parches deberán ser revisados antes de poder ser fusionados.

Algunos colaboradores de Rails tienen las notificaciones por correo electrónico de GitHub activadas, pero
otros no. Además, (casi) todos los que trabajan en Rails son
voluntarios, por lo que puede llevar algunos días obtener los primeros comentarios sobre
una solicitud de extracción. ¡No te desesperes! A veces es rápido; a veces es lento. Así
es la vida del código abierto.

Si ha pasado más de una semana y no has recibido ninguna respuesta, es posible que desees intentar
agilizar las cosas. Puedes usar el [foro de discusión de rubyonrails-core](https://discuss.rubyonrails.org/c/rubyonrails-core) para esto. También puedes
dejar otro comentario en la solicitud de extracción.
Mientras esperas comentarios sobre tu solicitud de extracción, abre algunas otras solicitudes de extracción y ¡ayuda a alguien más! Lo apreciarán de la misma manera que tú aprecias los comentarios sobre tus parches.

Ten en cuenta que solo los equipos Core y Committers tienen permiso para fusionar cambios de código. Si alguien da comentarios y "aprueba" tus cambios, es posible que no tengan la capacidad o la última palabra para fusionar tu cambio.

### Itera según sea necesario

Es posible que los comentarios que recibas sugieran cambios. No te desanimes: el objetivo de contribuir a un proyecto de código abierto activo es aprovechar el conocimiento de la comunidad. Si las personas te animan a ajustar tu código, vale la pena hacer los ajustes y volver a enviarlo. Si los comentarios indican que tu código no se fusionará, aún puedes considerar lanzarlo como una gema.

#### Combinar confirmaciones

Una de las cosas que podemos pedirte es "combinar tus confirmaciones", lo que combinará todas tus confirmaciones en una sola confirmación. Preferimos solicitudes de extracción que sean una sola confirmación. Esto facilita la retroportabilidad de los cambios a las ramas estables, combinar las confirmaciones facilita revertir confirmaciones incorrectas y el historial de git puede ser un poco más fácil de seguir. Rails es un proyecto grande y un montón de confirmaciones innecesarias pueden agregar mucho ruido.

```bash
$ git fetch rails
$ git checkout mi_nueva_rama
$ git rebase -i rails/main

< Elije 'squash' para todas tus confirmaciones excepto la primera. >
< Edita el mensaje de confirmación para que tenga sentido y describe todos tus cambios. >

$ git push fork mi_nueva_rama --force-with-lease
```

Deberías poder actualizar la solicitud de extracción en GitHub y ver que se ha actualizado.

#### Actualizar una solicitud de extracción

A veces se te pedirá que hagas algunos cambios en el código que ya has confirmado. Esto puede incluir modificar confirmaciones existentes. En este caso, Git no te permitirá enviar los cambios ya que la rama enviada y la rama local no coinciden. En lugar de abrir una nueva solicitud de extracción, puedes enviar los cambios forzados a tu rama en GitHub como se describe anteriormente en la sección de combinación de confirmaciones:

```bash
$ git commit --amend
$ git push fork mi_nueva_rama --force-with-lease
```

Esto actualizará la rama y la solicitud de extracción en GitHub con tu nuevo código. Al enviar forzadamente con `--force-with-lease`, git actualizará de manera más segura el remoto que con un `-f` típico, que puede eliminar el trabajo del remoto que aún no tienes.

### Versiones antiguas de Ruby on Rails

Si deseas agregar una corrección a versiones de Ruby on Rails anteriores a la próxima versión, deberás configurar y cambiar a tu propia rama local de seguimiento. Aquí tienes un ejemplo para cambiar a la rama 7-0-stable:

```bash
$ git branch --track 7-0-stable rails/7-0-stable
$ git checkout 7-0-stable
```

NOTA: Antes de trabajar en versiones antiguas, verifica la [política de mantenimiento](maintenance_policy.html). No se aceptarán cambios en versiones que hayan alcanzado el final de su vida útil.

#### Retroportar

Los cambios que se fusionan en main están destinados a la próxima versión principal de Rails. A veces, puede ser beneficioso propagar tus cambios a ramas estables para incluirlos en versiones de mantenimiento. En general, las correcciones de seguridad y las correcciones de errores son buenos candidatos para una retroportación, mientras que las nuevas características y los parches que cambian el comportamiento esperado no serán aceptados. Cuando tengas dudas, es mejor consultar a un miembro del equipo de Rails antes de retroportar tus cambios para evitar esfuerzos desperdiciados.

Primero, asegúrate de que tu rama main esté actualizada.

```bash
$ git checkout main
$ git pull --rebase
```

Cambiar a la rama a la que estás retroportando, por ejemplo, `7-0-stable`, y asegúrate de que esté actualizada:

```bash
$ git checkout 7-0-stable
$ git reset --hard origin/7-0-stable
$ git checkout -b mi_rama_de_retroportacion
```

Si estás retroportando una solicitud de extracción fusionada, encuentra la confirmación de la fusión y aplícala:

```bash
$ git cherry-pick -m1 MERGE_SHA
```

Soluciona cualquier conflicto que ocurra en la aplicación, envía tus cambios y luego abre una solicitud de extracción que apunte a la rama estable a la que estás retroportando. Si tienes un conjunto de cambios más complejo, la documentación de [cherry-pick](https://git-scm.com/docs/git-cherry-pick) puede ayudar.

Contribuidores de Rails
------------------

Todas las contribuciones reciben crédito en [Contribuidores de Rails](https://contributors.rubyonrails.org).
