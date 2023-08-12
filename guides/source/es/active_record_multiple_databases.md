**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 67ad41dc27cc9079db9a7e31dffa5aac
Múltiples bases de datos con Active Record
==========================================

Esta guía cubre el uso de múltiples bases de datos con tu aplicación Rails.

Después de leer esta guía, sabrás:

* Cómo configurar tu aplicación para múltiples bases de datos.
* Cómo funciona el cambio automático de conexión.
* Cómo usar el particionamiento horizontal para múltiples bases de datos.
* Qué características son compatibles y qué está en progreso.

--------------------------------------------------------------------------------

A medida que una aplicación crece en popularidad y uso, necesitarás escalar la aplicación
para soportar a tus nuevos usuarios y sus datos. Una forma en la que tu aplicación puede necesitar
escalar es a nivel de base de datos. Rails ahora tiene soporte para múltiples bases de datos
para que no tengas que almacenar tus datos en un solo lugar.

En este momento, se admiten las siguientes características:

* Múltiples bases de datos de escritura y una réplica para cada una.
* Cambio automático de conexión para el modelo con el que estás trabajando.
* Cambio automático entre la base de datos de escritura y la réplica según el verbo HTTP y las escrituras recientes.
* Tareas de Rails para crear, eliminar, migrar e interactuar con las múltiples bases de datos.

Las siguientes características aún no son compatibles:

* Balanceo de carga de réplicas

## Configuración de tu aplicación

Si bien Rails intenta hacer la mayor parte del trabajo por ti, aún hay algunos pasos que deberás seguir
para preparar tu aplicación para múltiples bases de datos.

Digamos que tenemos una aplicación con una única base de datos de escritura y necesitamos agregar una
nueva base de datos para algunas nuevas tablas que estamos agregando. El nombre de la nueva base de datos será
"animals".

El `database.yml` se ve así:

```yaml
production:
  database: my_primary_database
  adapter: mysql2
  username: root
  password: <%= ENV['ROOT_PASSWORD'] %>
```

Agreguemos una réplica para la primera configuración y una segunda base de datos llamada animals y una
réplica para eso también. Para hacer esto, necesitamos cambiar nuestro `database.yml` de una configuración de 2 niveles
a una configuración de 3 niveles.

Si se proporciona una configuración principal, se utilizará como configuración "predeterminada". Si
no hay una configuración llamada `"primary"`, Rails usará la primera configuración como predeterminada
para cada entorno. Las configuraciones predeterminadas utilizarán los nombres de archivo predeterminados de Rails. Por ejemplo,
las configuraciones principales utilizarán `schema.rb` para el archivo de esquema, mientras que todas las demás entradas
utilizarán `[CONFIGURATION_NAMESPACE]_schema.rb` para el nombre de archivo.

```yaml
production:
  primary:
    database: my_primary_database
    username: root
    password: <%= ENV['ROOT_PASSWORD'] %>
    adapter: mysql2
  primary_replica:
    database: my_primary_database
    username: root_readonly
    password: <%= ENV['ROOT_READONLY_PASSWORD'] %>
    adapter: mysql2
    replica: true
  animals:
    database: my_animals_database
    username: animals_root
    password: <%= ENV['ANIMALS_ROOT_PASSWORD'] %>
    adapter: mysql2
    migrations_paths: db/animals_migrate
  animals_replica:
    database: my_animals_database
    username: animals_readonly
    password: <%= ENV['ANIMALS_READONLY_PASSWORD'] %>
    adapter: mysql2
    replica: true
```

Cuando se utilizan múltiples bases de datos, hay algunas configuraciones importantes.

Primero, el nombre de la base de datos para `primary` y `primary_replica` debe ser el mismo porque contienen
los mismos datos. Esto también se aplica a `animals` y `animals_replica`.

Segundo, el nombre de usuario para los escritores y réplicas debe ser diferente, y el
permisos de la base de datos del usuario réplica deben estar configurados solo para leer y no escribir.

Cuando se utiliza una base de datos réplica, debes agregar una entrada `replica: true` a la réplica en el
`database.yml`. Esto se debe a que Rails de lo contrario no tiene forma de saber cuál es una réplica
y cuál es el escritor. Rails no ejecutará ciertas tareas, como migraciones, en réplicas.

Por último, para nuevas bases de datos de escritura, debes configurar `migrations_paths` al directorio
donde almacenarás las migraciones para esa base de datos. Veremos más sobre `migrations_paths`
más adelante en esta guía.

Ahora que tenemos una nueva base de datos, configuremos el modelo de conexión. Para usar la
nueva base de datos, necesitamos crear una nueva clase abstracta y conectarnos a la base de datos de animals.

```ruby
class AnimalsRecord < ApplicationRecord
  self.abstract_class = true

  connects_to database: { writing: :animals, reading: :animals_replica }
end
```

Luego, necesitamos actualizar `ApplicationRecord` para que esté al tanto de nuestra nueva réplica.

```ruby
class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  connects_to database: { writing: :primary, reading: :primary_replica }
end
```

Si usas una clase con un nombre diferente para tu registro de aplicación, debes
configurar `primary_abstract_class` en su lugar, para que Rails sepa con qué clase `ActiveRecord::Base`
debe compartir una conexión.

```ruby
class PrimaryApplicationRecord < ActiveRecord::Base
  primary_abstract_class
end
```

Las clases que se conectan a primary/primary_replica pueden heredar de tu clase abstracta principal
como en las aplicaciones Rails estándar:
```ruby
class Person < ApplicationRecord
end
```

Por defecto, Rails espera que los roles de la base de datos sean `writing` y `reading` para la principal
y la réplica respectivamente. Si tienes un sistema heredado, es posible que ya tengas roles configurados que
no deseas cambiar. En ese caso, puedes establecer un nuevo nombre de rol en la configuración de tu aplicación.

```ruby
config.active_record.writing_role = :default
config.active_record.reading_role = :readonly
```

Es importante conectarse a tu base de datos en un solo modelo y luego heredar de ese modelo
para las tablas en lugar de conectar múltiples modelos individuales a la misma base de datos. Los
clientes de base de datos tienen un límite en el número de conexiones abiertas que puede haber y si haces esto, se
multiplicará el número de conexiones que tienes, ya que Rails utiliza el nombre de la clase del modelo para el
nombre de especificación de conexión.

Ahora que tenemos el archivo `database.yml` y el nuevo modelo configurado, es hora de crear las bases de datos.
Rails 6.0 incluye todas las tareas de Rails que necesitas para usar múltiples bases de datos en Rails.

Puedes ejecutar `bin/rails -T` para ver todos los comandos que puedes ejecutar. Deberías ver lo siguiente:

```bash
$ bin/rails -T
bin/rails db:create                          # Crea la base de datos desde DATABASE_URL o config/database.yml para el ...
bin/rails db:create:animals                  # Crea la base de datos animals para el entorno actual
bin/rails db:create:primary                  # Crea la base de datos primary para el entorno actual
bin/rails db:drop                            # Elimina la base de datos desde DATABASE_URL o config/database.yml para el ...
bin/rails db:drop:animals                    # Elimina la base de datos animals para el entorno actual
bin/rails db:drop:primary                    # Elimina la base de datos primary para el entorno actual
bin/rails db:migrate                         # Migrar la base de datos (opciones: VERSION=x, VERBOSE=false, SCOPE=blog)
bin/rails db:migrate:animals                 # Migrar la base de datos animals para el entorno actual
bin/rails db:migrate:primary                 # Migrar la base de datos primary para el entorno actual
bin/rails db:migrate:status                  # Mostrar el estado de las migraciones
bin/rails db:migrate:status:animals          # Mostrar el estado de las migraciones para la base de datos animals
bin/rails db:migrate:status:primary          # Mostrar el estado de las migraciones para la base de datos primary
bin/rails db:reset                           # Elimina y recrea todas las bases de datos a partir de su esquema para el entorno actual y carga las semillas
bin/rails db:reset:animals                   # Elimina y recrea la base de datos animals a partir de su esquema para el entorno actual y carga las semillas
bin/rails db:reset:primary                   # Elimina y recrea la base de datos primary a partir de su esquema para el entorno actual y carga las semillas
bin/rails db:rollback                        # Revierte el esquema a la versión anterior (especifica los pasos con STEP=n)
bin/rails db:rollback:animals                # Revierte la base de datos animals para el entorno actual (especifica los pasos con STEP=n)
bin/rails db:rollback:primary                # Revierte la base de datos primary para el entorno actual (especifica los pasos con STEP=n)
bin/rails db:schema:dump                     # Crea un archivo de esquema de base de datos (ya sea db/schema.rb o db/structure.sql  ...
bin/rails db:schema:dump:animals             # Crea un archivo de esquema de base de datos (ya sea db/schema.rb o db/structure.sql  ...
bin/rails db:schema:dump:primary             # Crea un archivo db/schema.rb que sea portable para cualquier DB compatible  ...
bin/rails db:schema:load                     # Carga un archivo de esquema de base de datos (ya sea db/schema.rb o db/structure.sql  ...
bin/rails db:schema:load:animals             # Carga un archivo de esquema de base de datos (ya sea db/schema.rb o db/structure.sql  ...
bin/rails db:schema:load:primary             # Carga un archivo de esquema de base de datos (ya sea db/schema.rb o db/structure.sql  ...
bin/rails db:setup                           # Crea todas las bases de datos, carga todos los esquemas e inicializa con los datos de semilla (usa db:reset para eliminar primero todas las bases de datos)
bin/rails db:setup:animals                   # Crea la base de datos animals, carga el esquema e inicializa con los datos de semilla (usa db:reset:animals para eliminar primero la base de datos)
bin/rails db:setup:primary                   # Crea la base de datos primary, carga el esquema e inicializa con los datos de semilla (usa db:reset:primary para eliminar primero la base de datos)
```

Ejecutar un comando como `bin/rails db:create` creará tanto la base de datos principal como la de animals.
Ten en cuenta que no hay un comando para crear los usuarios de la base de datos, y deberás hacerlo manualmente
para admitir los usuarios de solo lectura para tus réplicas. Si deseas crear solo la base de datos de animals,
puedes ejecutar `bin/rails db:create:animals`.

## Conexión a bases de datos sin gestionar esquemas y migraciones

Si deseas conectarte a una base de datos externa sin realizar ninguna tarea de gestión de base de datos
como gestión de esquemas, migraciones, semillas, etc., puedes establecer la opción de configuración `database_tasks: false` por base de datos. Por defecto está
establecido en true.

```yaml
production:
  primary:
    database: my_database
    adapter: mysql2
  animals:
    database: my_animals_database
    adapter: mysql2
    database_tasks: false
```

## Generadores y Migraciones

Las migraciones para múltiples bases de datos deben estar en sus propias carpetas con el prefijo del
nombre de la clave de la base de datos en la configuración.
También necesitas configurar las `migrations_paths` en las configuraciones de la base de datos para indicarle a Rails dónde encontrar las migraciones.

Por ejemplo, la base de datos `animals` buscaría las migraciones en el directorio `db/animals_migrate` y `primary` buscaría en `db/migrate`. Los generadores de Rails ahora aceptan la opción `--database` para que el archivo se genere en el directorio correcto. El comando se puede ejecutar de la siguiente manera:

```bash
$ bin/rails generate migration CreateDogs name:string --database animals
```

Si estás utilizando los generadores de Rails, los generadores de scaffold y model crearán la clase abstracta por ti. Simplemente pasa la clave de la base de datos a la línea de comandos.

```bash
$ bin/rails generate scaffold Dog name:string --database animals
```

Se creará una clase con el nombre de la base de datos y `Record`. En este ejemplo, la base de datos es `Animals`, por lo que obtendremos `AnimalsRecord`:

```ruby
class AnimalsRecord < ApplicationRecord
  self.abstract_class = true

  connects_to database: { writing: :animals }
end
```

El modelo generado heredará automáticamente de `AnimalsRecord`.

```ruby
class Dog < AnimalsRecord
end
```

NOTA: Dado que Rails no sabe qué base de datos es la réplica de tu escritor, deberás agregar esto a la clase abstracta después de haber terminado.

Rails solo generará la nueva clase una vez. No se sobrescribirá con nuevos scaffolds ni se eliminará si se elimina el scaffold.

Si ya tienes una clase abstracta y su nombre difiere de `AnimalsRecord`, puedes pasar la opción `--parent` para indicar que deseas una clase abstracta diferente:

```bash
$ bin/rails generate scaffold Dog name:string --database animals --parent Animals::Record
```

Esto omitirá la generación de `AnimalsRecord` ya que has indicado a Rails que deseas usar una clase padre diferente.

## Activando el Cambio Automático de Roles

Finalmente, para utilizar la réplica de solo lectura en tu aplicación, deberás activar el middleware para el cambio automático.

El cambio automático permite que la aplicación cambie del escritor a la réplica o de la réplica al escritor según el verbo HTTP y si hubo una escritura reciente por parte del usuario que realiza la solicitud.

Si la aplicación recibe una solicitud POST, PUT, DELETE o PATCH, la aplicación escribirá automáticamente en la base de datos del escritor. Durante el tiempo especificado después de la escritura, la aplicación leerá desde la base de datos principal. Para una solicitud GET o HEAD, la aplicación leerá desde la réplica a menos que haya habido una escritura reciente.

Para activar el middleware de cambio automático de conexión, puedes ejecutar el generador de cambio automático:

```bash
$ bin/rails g active_record:multi_db
```

Y luego descomenta las siguientes líneas:

```ruby
Rails.application.configure do
  config.active_record.database_selector = { delay: 2.seconds }
  config.active_record.database_resolver = ActiveRecord::Middleware::DatabaseSelector::Resolver
  config.active_record.database_resolver_context = ActiveRecord::Middleware::DatabaseSelector::Resolver::Session
end
```

Rails garantiza "leer tu propia escritura" y enviará tu solicitud GET o HEAD al escritor si está dentro de la ventana de `delay`. De forma predeterminada, el retraso está configurado en 2 segundos. Debes cambiar esto según tu infraestructura de base de datos. Rails no garantiza "leer una escritura reciente" para otros usuarios dentro de la ventana de retraso y enviará solicitudes GET y HEAD a las réplicas a menos que hayan escrito recientemente.

El cambio automático de conexión en Rails es relativamente primitivo y deliberadamente no hace mucho. El objetivo es un sistema que demuestre cómo hacer el cambio automático de conexión que sea lo suficientemente flexible como para ser personalizado por los desarrolladores de aplicaciones.

La configuración en Rails te permite cambiar fácilmente cómo se realiza el cambio y en qué parámetros se basa. Digamos que quieres usar una cookie en lugar de una sesión para decidir cuándo cambiar las conexiones. Puedes escribir tu propia clase:

```ruby
class MyCookieResolver << ActiveRecord::Middleware::DatabaseSelector::Resolver
  def self.call(request)
    new(request.cookies)
  end

  def initialize(cookies)
    @cookies = cookies
  end

  attr_reader :cookies

  def last_write_timestamp
    self.class.convert_timestamp_to_time(cookies[:last_write])
  end

  def update_last_write_timestamp
    cookies[:last_write] = self.class.convert_time_to_timestamp(Time.now)
  end

  def save(response)
  end
end
```

Y luego pásala al middleware:

```ruby
config.active_record.database_selector = { delay: 2.seconds }
config.active_record.database_resolver = ActiveRecord::Middleware::DatabaseSelector::Resolver
config.active_record.database_resolver_context = MyCookieResolver
```

## Usando el Cambio Manual de Conexión

Hay casos en los que es posible que desees que tu aplicación se conecte a un escritor o una réplica y el cambio automático de conexión no sea adecuado. Por ejemplo, es posible que sepas que para una solicitud en particular siempre deseas enviarla a una réplica, incluso cuando estás en una ruta de solicitud POST.

Para hacer esto, Rails proporciona un método `connected_to` que cambiará a la conexión que necesitas.
```ruby
ActiveRecord::Base.connected_to(role: :reading) do
  # todo el código en este bloque estará conectado al rol de lectura
end
```

El "rol" en la llamada `connected_to` busca las conexiones que están conectadas en ese
manejador de conexión (o rol). El manejador de conexión `reading` contendrá todas las conexiones
que se conectaron a través de `connects_to` con el nombre de rol `reading`.

Tenga en cuenta que `connected_to` con un rol buscará una conexión existente y cambiará
usando el nombre de especificación de conexión. Esto significa que si pasa un rol desconocido
como `connected_to(role: :nonexistent)` obtendrá un error que dice
`ActiveRecord::ConnectionNotEstablished (No se encontró un grupo de conexiones para 'ActiveRecord::Base' para el rol 'nonexistent'.)`

Si desea que Rails garantice que las consultas realizadas sean solo de lectura, pase `prevent_writes: true`.
Esto simplemente evita que las consultas que parecen escrituras se envíen a la base de datos.
También debe configurar su base de datos réplica para que se ejecute en modo de solo lectura.

```ruby
ActiveRecord::Base.connected_to(role: :reading, prevent_writes: true) do
  # Rails verificará cada consulta para asegurarse de que sea una consulta de lectura
end
```

## Fragmentación horizontal

La fragmentación horizontal es cuando se divide la base de datos para reducir el número de filas en cada
servidor de base de datos, pero se mantiene el mismo esquema en los "fragmentos". Esto se conoce comúnmente como fragmentación "multiinquilino".

La API para admitir la fragmentación horizontal en Rails es similar a la API de fragmentación vertical / múltiples bases de datos que existe desde Rails 6.0.

Los fragmentos se declaran en la configuración de tres niveles de esta manera:

```yaml
production:
  primary:
    database: my_primary_database
    adapter: mysql2
  primary_replica:
    database: my_primary_database
    adapter: mysql2
    replica: true
  primary_shard_one:
    database: my_primary_shard_one
    adapter: mysql2
  primary_shard_one_replica:
    database: my_primary_shard_one
    adapter: mysql2
    replica: true
```

Los modelos se conectan a través de la API `connects_to` mediante la clave `shards`:

```ruby
class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  connects_to shards: {
    default: { writing: :primary, reading: :primary_replica },
    shard_one: { writing: :primary_shard_one, reading: :primary_shard_one_replica }
  }
end
```

No es necesario utilizar `default` como el primer nombre de fragmento. Rails asumirá que el primer
nombre de fragmento en el hash `connects_to` es la conexión "predeterminada". Esta conexión se utiliza
internamente para cargar datos de tipo y otra información donde el esquema es el mismo en todos los fragmentos.

Luego, los modelos pueden intercambiar conexiones manualmente a través de la API `connected_to`. Si
se utiliza la fragmentación, se deben pasar tanto un `role` como un `shard`:

```ruby
ActiveRecord::Base.connected_to(role: :writing, shard: :default) do
  @id = Person.create! # Crea un registro en el fragmento llamado ":default"
end

ActiveRecord::Base.connected_to(role: :writing, shard: :shard_one) do
  Person.find(@id) # No se puede encontrar el registro, no existe porque se creó
                   # en el fragmento llamado ":default".
end
```

La API de fragmentación horizontal también admite réplicas de lectura. Puede intercambiar el
rol y el fragmento con la API `connected_to`.

```ruby
ActiveRecord::Base.connected_to(role: :reading, shard: :shard_one) do
  Person.first # Buscar registro desde la réplica de lectura del fragmento uno
end
```

## Activación del cambio automático de fragmento

Las aplicaciones pueden cambiar automáticamente de fragmento por solicitud utilizando el middleware proporcionado.

El middleware `ShardSelector` proporciona un marco para cambiar automáticamente
los fragmentos. Rails proporciona un marco básico para determinar a qué
fragmento cambiar y permite a las aplicaciones escribir estrategias personalizadas
para el cambio si es necesario.

El `ShardSelector` toma un conjunto de opciones (actualmente solo se admite `lock`)
que pueden ser utilizadas por el middleware para alterar el comportamiento. `lock`
es verdadero de forma predeterminada y prohibirá que la solicitud cambie de fragmento una vez
dentro del bloque. Si `lock` es falso, se permitirá el cambio de fragmento.
Para la fragmentación basada en inquilinos, `lock` siempre debe ser verdadero para evitar que la aplicación
código cambie accidentalmente entre inquilinos.

Se puede utilizar el mismo generador que el selector de base de datos para generar el archivo para
el cambio automático de fragmento:

```bash
$ bin/rails g active_record:multi_db
```

Luego, en el archivo, descomente lo siguiente:

```ruby
Rails.application.configure do
  config.active_record.shard_selector = { lock: true }
  config.active_record.shard_resolver = ->(request) { Tenant.find_by!(host: request.host).shard }
end
```

Las aplicaciones deben proporcionar el código para el resolvedor, ya que depende de la aplicación
modelos específicos. Un resolvedor de ejemplo se vería así:

```ruby
config.active_record.shard_resolver = ->(request) {
  subdomain = request.subdomain
  tenant = Tenant.find_by_subdomain!(subdomain)
  tenant.shard
}
```

## Cambio granular de conexión de base de datos

En Rails 6.1 es posible cambiar las conexiones para una base de datos en lugar de
todas las bases de datos de forma global.

Con el cambio granular de conexión de base de datos, cualquier clase de conexión abstracta
podrá cambiar de conexiones sin afectar a otras conexiones. Esto
es útil para cambiar las consultas de su `AnimalsRecord` para leer desde la réplica
mientras se asegura de que sus consultas de `ApplicationRecord` vayan al primario.
```ruby
AnimalsRecord.connected_to(role: :reading) do
  Dog.first # Lee de animals_replica
  Person.first  # Lee de primary
end
```

También es posible intercambiar conexiones de forma granular para fragmentos.

```ruby
AnimalsRecord.connected_to(role: :reading, shard: :shard_one) do
  Dog.first # Leerá de shard_one_replica. Si no existe una conexión para shard_one_replica,
  # se generará un error ConnectionNotEstablished
  Person.first # Leerá del escritor principal
end
```

Para cambiar solo el clúster de la base de datos principal, utiliza `ApplicationRecord`:

```ruby
ApplicationRecord.connected_to(role: :reading, shard: :shard_one) do
  Person.first # Lee de primary_shard_one_replica
  Dog.first # Lee de animals_primary
end
```

`ActiveRecord::Base.connected_to` mantiene la capacidad de cambiar conexiones globalmente.

### Manejo de asociaciones con uniones entre bases de datos

A partir de Rails 7.0+, Active Record tiene una opción para manejar asociaciones que realizarían
una unión entre múltiples bases de datos. Si tienes una asociación "has many through" o "has one through"
que deseas deshabilitar la unión y realizar 2 o más consultas, pasa la opción `disable_joins: true`.

Por ejemplo:

```ruby
class Dog < AnimalsRecord
  has_many :treats, through: :humans, disable_joins: true
  has_many :humans

  has_one :home
  has_one :yard, through: :home, disable_joins: true
end

class Home
  belongs_to :dog
  has_one :yard
end

class Yard
  belongs_to :home
end
```

Anteriormente, llamar a `@dog.treats` sin `disable_joins` o `@dog.yard` sin `disable_joins`
generaría un error porque las bases de datos no pueden manejar uniones entre clústeres. Con la opción
`disable_joins`, Rails generará múltiples consultas de selección
para evitar intentar unir clústeres. Para la asociación anterior, `@dog.treats` generaría el siguiente SQL:

```sql
SELECT "humans"."id" FROM "humans" WHERE "humans"."dog_id" = ?  [["dog_id", 1]]
SELECT "treats".* FROM "treats" WHERE "treats"."human_id" IN (?, ?, ?)  [["human_id", 1], ["human_id", 2], ["human_id", 3]]
```

Mientras que `@dog.yard` generaría el siguiente SQL:

```sql
SELECT "home"."id" FROM "homes" WHERE "homes"."dog_id" = ? [["dog_id", 1]]
SELECT "yards".* FROM "yards" WHERE "yards"."home_id" = ? [["home_id", 1]]
```

Hay algunas cosas importantes que debes tener en cuenta con esta opción:

1. Puede haber implicaciones de rendimiento, ya que ahora se realizarán dos o más consultas (dependiendo
   de la asociación) en lugar de una unión. Si la selección de `humans` devuelve un alto número de IDs,
   la selección de `treats` puede enviar demasiados IDs.
2. Dado que ya no realizamos uniones, una consulta con un orden o límite ahora se ordena en memoria ya que
   el orden de una tabla no se puede aplicar a otra tabla.
3. Esta configuración debe agregarse a todas las asociaciones donde se desee deshabilitar la unión.
   Rails no puede adivinar esto por ti porque la carga de asociaciones es perezosa, para cargar `treats` en `@dog.treats`
   Rails ya necesita saber qué SQL debe generarse.

### Caché de esquema

Si deseas cargar una caché de esquema para cada base de datos, debes establecer una `schema_cache_path` en cada configuración de base de datos y establecer `config.active_record.lazily_load_schema_cache = true` en la configuración de tu aplicación. Ten en cuenta que esto cargará la caché de forma perezosa cuando se establezcan las conexiones de base de datos.

## Precauciones

### Balanceo de carga de réplicas

Rails tampoco admite el balanceo de carga automático de réplicas. Esto depende mucho de tu infraestructura. Es posible que implementemos un balanceo de carga básico y primitivo en el futuro, pero para una aplicación a gran escala, esto es algo que tu aplicación debe manejar fuera de Rails.
