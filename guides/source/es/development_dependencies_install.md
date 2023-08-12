**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 282c6f5888c41f4c28238cd40bce5aa7
Instalación de las dependencias principales de desarrollo de Rails
===================================================================

Esta guía cubre cómo configurar un entorno para el desarrollo central de Ruby on Rails.

Después de leer esta guía, sabrás:

* Cómo configurar tu máquina para el desarrollo de Rails

--------------------------------------------------------------------------------

Otras formas de configurar tu entorno
-------------------------------------

Si no quieres configurar Rails para el desarrollo en tu máquina local, puedes usar Codespaces, el complemento remoto de VS Code o rails-dev-box. Obtén más información sobre estas opciones [aquí](contributing_to_ruby_on_rails.html#setting-up-a-development-environment).

Desarrollo local
----------------

Si deseas desarrollar Ruby on Rails localmente en tu máquina, sigue los pasos a continuación.

### Instalar Git

Ruby on Rails utiliza Git para el control de código fuente. La página de inicio de [Git](https://git-scm.com/) tiene instrucciones de instalación. Hay una variedad de recursos en línea que te ayudarán a familiarizarte con Git.

### Clonar el repositorio de Ruby on Rails

Navega hasta la carpeta donde deseas descargar el código fuente de Ruby on Rails (creará su propio subdirectorio `rails`) y ejecuta:

```bash
$ git clone https://github.com/rails/rails.git
$ cd rails
```

### Instalar herramientas y servicios adicionales

Algunas pruebas de Rails dependen de herramientas adicionales que debes instalar antes de ejecutar esas pruebas específicas.

Aquí está la lista de las dependencias adicionales de cada gema:

* Action Cable depende de Redis
* Active Record depende de SQLite3, MySQL y PostgreSQL
* Active Storage depende de Yarn (además, Yarn depende de
  [Node.js](https://nodejs.org/)), ImageMagick, libvips, FFmpeg, muPDF,
  Poppler, y en macOS también XQuartz.
* Active Support depende de memcached y Redis
* Railties depende de un entorno de ejecución de JavaScript, como tener
  [Node.js](https://nodejs.org/) instalado.

Instala todos los servicios que necesitas para probar correctamente la gema completa en la que realizarás cambios. A continuación, se detallan las instrucciones sobre cómo instalar estos servicios en macOS, Ubuntu, Fedora/CentOS, Arch Linux y FreeBSD.

NOTA: La documentación de Redis desaconseja las instalaciones con gestores de paquetes, ya que suelen estar desactualizados. La instalación desde la fuente y la puesta en marcha del servidor son sencillas y están bien documentadas en la [documentación de Redis](https://redis.io/download#installation).

NOTA: Las pruebas de Active Record _deben_ pasar al menos en MySQL, PostgreSQL y SQLite3. Tu parche será rechazado si se prueba solo con un adaptador, a menos que el cambio y las pruebas sean específicas del adaptador.

A continuación, puedes encontrar instrucciones sobre cómo instalar todas las herramientas adicionales para diferentes sistemas operativos.

#### macOS

En macOS, puedes usar [Homebrew](https://brew.sh/) para instalar todas las herramientas adicionales.

Para instalar todo, ejecuta:

```bash
$ brew bundle
```

También deberás iniciar cada uno de los servicios instalados. Para listar todos los servicios disponibles, ejecuta:

```bash
$ brew services list
```

Luego, puedes iniciar cada uno de los servicios uno por uno de la siguiente manera:

```bash
$ brew services start mysql
```

Reemplaza `mysql` con el nombre del servicio que deseas iniciar.

##### Problemas potenciales

Esta sección detalla algunos de los problemas potenciales que puedes encontrar con las extensiones nativas en macOS, especialmente al agrupar la gema mysql2 en el desarrollo local. Esta documentación está sujeta a cambios y puede ser incorrecta a medida que Apple realiza cambios en el entorno de desarrollo en Rails.

Para compilar la gema `mysql2` en macOS, necesitarás lo siguiente:

1. Tener instalado `openssl@1.1` (no `openssl@3`)
2. Ruby compilado con `openssl@1.1`
3. Configurar las banderas del compilador en la configuración de bundle para `mysql2`.

Si tienes instalados tanto `openssl@1.1` como `openssl@3`, deberás indicarle a Ruby que use `openssl@1.1` para que Rails pueda agrupar `mysql2`.

En tu `.bash_profile`, establece `PATH` y `RUBY_CONFIGURE_OPTS` para que apunten a `openssl@1.1`:

```
export PATH="/usr/local/opt/openssl@1.1/bin:$PATH"
export RUBY_CONFIGURE_OPTS="--with-openssl-dir=$(brew --prefix openssl@1.1)"
```

En tu `~/.bundle/config`, establece lo siguiente para `mysql2`. Asegúrate de eliminar cualquier otra entrada para `BUNDLE_BUILD__MYSQL2`:

```
BUNDLE_BUILD__MYSQL2: "--with-ldflags=-L/usr/local/opt/openssl@1.1/lib --with-cppflags=-L/usr/local/opt/openssl@1.1/include"
```

Al establecer estas banderas antes de instalar Ruby y agrupar Rails, deberías poder hacer funcionar tu entorno de desarrollo local en macOS.

#### Ubuntu

Para instalar todo, ejecuta:

```bash
$ sudo apt-get update
$ sudo apt-get install sqlite3 libsqlite3-dev mysql-server libmysqlclient-dev postgresql postgresql-client postgresql-contrib libpq-dev redis-server memcached imagemagick ffmpeg mupdf mupdf-tools libxml2-dev libvips42 poppler-utils

# Instalar Yarn
# Usa este comando si no tienes Node.js instalado
$ curl --fail --silent --show-error --location https://deb.nodesource.com/setup_18.x | sudo -E bash -
$ sudo apt-get install -y nodejs
# Una vez que hayas instalado Node.js, instala el paquete npm de yarn
$ sudo npm install --global yarn
```
#### Fedora o CentOS

Para instalar todo, ejecuta:

```bash
$ sudo dnf install sqlite-devel sqlite-libs mysql-server mysql-devel postgresql-server postgresql-devel redis memcached imagemagick ffmpeg mupdf libxml2-devel vips poppler-utils

# Instalar Yarn
# Usa este comando si no tienes Node.js instalado
$ curl --silent --location https://rpm.nodesource.com/setup_18.x | sudo bash -
$ sudo dnf install -y nodejs
# Una vez que hayas instalado Node.js, instala el paquete npm de yarn
$ sudo npm install --global yarn
```

#### Arch Linux

Para instalar todo, ejecuta:

```bash
$ sudo pacman -S sqlite mariadb libmariadbclient mariadb-clients postgresql postgresql-libs redis memcached imagemagick ffmpeg mupdf mupdf-tools poppler yarn libxml2 libvips poppler
$ sudo mariadb-install-db --user=mysql --basedir=/usr --datadir=/var/lib/mysql
$ sudo systemctl start redis mariadb memcached
```

NOTA: Si estás utilizando Arch Linux, MySQL ya no es compatible, por lo que deberás utilizar MariaDB en su lugar (ver [este anuncio](https://www.archlinux.org/news/mariadb-replaces-mysql-in-repositories/)).

#### FreeBSD

Para instalar todo, ejecuta:

```bash
$ sudo pkg install sqlite3 mysql80-client mysql80-server postgresql11-client postgresql11-server memcached imagemagick6 ffmpeg mupdf yarn libxml2 vips poppler-utils
# portmaster databases/redis
```

O instala todo a través de los puertos (estos paquetes se encuentran en la carpeta `databases`).

NOTA: Si tienes problemas durante la instalación de MySQL, consulta la [documentación de MySQL](https://dev.mysql.com/doc/refman/en/freebsd-installation.html).

#### Debian

Para instalar todas las dependencias, ejecuta:

```bash
$ sudo apt-get install sqlite3 libsqlite3-dev default-mysql-server default-libmysqlclient-dev postgresql postgresql-client postgresql-contrib libpq-dev redis-server memcached imagemagick ffmpeg mupdf mupdf-tools libxml2-dev libvips42 poppler-utils
```

NOTA: Si estás utilizando Debian, MariaDB es el servidor MySQL por defecto, por lo que puede haber diferencias.

### Configuración de la base de datos

Hay algunos pasos adicionales necesarios para configurar los motores de base de datos necesarios para ejecutar las pruebas de Active Record.

La autenticación de PostgreSQL funciona de manera diferente. Para configurar el entorno de desarrollo con tu cuenta de desarrollo, en Linux o BSD, solo tienes que ejecutar:

```bash
$ sudo -u postgres createuser --superuser $USER
```

y para macOS:

```bash
$ createuser --superuser $USER
```

NOTA: MySQL creará los usuarios cuando se creen las bases de datos. La tarea asume que tu usuario es `root` sin contraseña.

Luego, debes crear las bases de datos de prueba tanto para MySQL como para PostgreSQL con:

```bash
$ cd activerecord
$ bundle exec rake db:create
```

También puedes crear bases de datos de prueba para cada motor de base de datos por separado:

```bash
$ cd activerecord
$ bundle exec rake db:mysql:build
$ bundle exec rake db:postgresql:build
```

y puedes eliminar las bases de datos usando:

```bash
$ cd activerecord
$ bundle exec rake db:drop
```

NOTA: El uso de la tarea Rake para crear las bases de datos de prueba asegura que tengan el conjunto de caracteres y la intercalación correctos.

Si estás utilizando otra base de datos, consulta el archivo `activerecord/test/config.yml` o `activerecord/test/config.example.yml` para obtener información de conexión predeterminada. Puedes editar `activerecord/test/config.yml` para proporcionar diferentes credenciales en tu máquina, pero no debes enviar esos cambios de vuelta a Rails.

### Instalar dependencias de JavaScript

Si instalaste Yarn, deberás instalar las dependencias de JavaScript:

```bash
$ yarn install
```

### Instalación de dependencias de Gemas

Las gemas se instalan con [Bundler](https://bundler.io/), que se incluye de forma predeterminada con Ruby.

Para instalar el Gemfile de Rails, ejecuta:

```bash
$ bundle install
```

Si no necesitas ejecutar las pruebas de Active Record, puedes ejecutar:

```bash
$ bundle install --without db
```

### Contribuir a Rails

Después de configurar todo, lee cómo puedes comenzar a [contribuir](contributing_to_ruby_on_rails.html#running-an-application-against-your-local-branch).
