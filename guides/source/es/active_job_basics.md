**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 8e409a33cc6caed27c82b91e6adad6c7
Conceptos básicos de Active Job
=================

Esta guía te proporciona todo lo que necesitas para comenzar a crear,
encolar y ejecutar trabajos en segundo plano.

Después de leer esta guía, sabrás:

* Cómo crear trabajos.
* Cómo encolar trabajos.
* Cómo ejecutar trabajos en segundo plano.
* Cómo enviar correos electrónicos desde tu aplicación de forma asíncrona.

--------------------------------------------------------------------------------

¿Qué es Active Job?
-------------------

Active Job es un marco para declarar trabajos y hacer que se ejecuten en una variedad
de backend de encolamiento. Estos trabajos pueden ser desde limpiezas programadas
regularmente, hasta cargos de facturación, hasta envíos de correo. Cualquier cosa que se pueda dividir
en pequeñas unidades de trabajo y ejecutar en paralelo, en realidad.


El propósito de Active Job
-----------------------------

El punto principal es asegurarse de que todas las aplicaciones de Rails tengan una infraestructura de trabajos
en su lugar. Luego podemos tener características del marco y otras gemas construidas sobre eso,
sin tener que preocuparnos por las diferencias de API entre varios ejecutores de trabajos como
Delayed Job y Resque. Elegir tu backend de encolamiento se convierte en más una preocupación operativa,
entonces. Y podrás cambiar entre ellos sin tener que reescribir tus trabajos.

NOTA: Rails por defecto viene con una implementación de encolamiento asíncrono que
ejecuta trabajos con un grupo de hilos en el proceso. Los trabajos se ejecutarán de forma asíncrona, pero cualquier
trabajo en la cola se eliminará al reiniciar.


Creando un trabajo
--------------

Esta sección proporcionará una guía paso a paso para crear un trabajo y encolarlo.

### Crear el trabajo

Active Job proporciona un generador de Rails para crear trabajos. Lo siguiente creará un
trabajo en `app/jobs` (con un caso de prueba adjunto en `test/jobs`):

```bash
$ bin/rails generate job guests_cleanup
invoke  test_unit
create    test/jobs/guests_cleanup_job_test.rb
create  app/jobs/guests_cleanup_job.rb
```

También puedes crear un trabajo que se ejecutará en una cola específica:

```bash
$ bin/rails generate job guests_cleanup --queue urgent
```

Si no quieres usar un generador, puedes crear tu propio archivo dentro de
`app/jobs`, solo asegúrate de que herede de `ApplicationJob`.

Esto es cómo se ve un trabajo:

```ruby
class GuestsCleanupJob < ApplicationJob
  queue_as :default

  def perform(*guests)
    # Hacer algo más tarde
  end
end
```

Ten en cuenta que puedes definir `perform` con tantos argumentos como desees.

Si ya tienes una clase abstracta y su nombre difiere de `ApplicationJob`, puedes pasar
la opción `--parent` para indicar que deseas una clase abstracta diferente:

```bash
$ bin/rails generate job process_payment --parent=payment_job
```

```ruby
class ProcessPaymentJob < PaymentJob
  queue_as :default

  def perform(*args)
    # Hacer algo más tarde
  end
end
```

### Encolar el trabajo

Encola un trabajo usando [`perform_later`][] y, opcionalmente, [`set`][]. Así:

```ruby
# Encola un trabajo para que se realice tan pronto como el sistema de encolamiento esté
# libre.
GuestsCleanupJob.perform_later guest
```

```ruby
# Encola un trabajo para que se realice mañana al mediodía.
GuestsCleanupJob.set(wait_until: Date.tomorrow.noon).perform_later(guest)
```

```ruby
# Encola un trabajo para que se realice dentro de 1 semana.
GuestsCleanupJob.set(wait: 1.week).perform_later(guest)
```

```ruby
# `perform_now` y `perform_later` llamarán a `perform` internamente, por lo que
# puedes pasar tantos argumentos como se definieron en este último.
GuestsCleanupJob.perform_later(guest1, guest2, filter: 'some_filter')
```

¡Eso es todo!


Ejecución de trabajos
-------------

Para encolar y ejecutar trabajos en producción, necesitas configurar un backend de encolamiento,
es decir, debes decidir qué biblioteca de encolamiento de terceros debe usar Rails.
Rails en sí solo proporciona un sistema de encolamiento en el proceso, que solo mantiene los trabajos en RAM.
Si el proceso se bloquea o la máquina se reinicia, entonces todos los trabajos pendientes se pierden con el
backend asíncrono predeterminado. Esto puede ser aceptable para aplicaciones más pequeñas o trabajos no críticos, pero la mayoría
de las aplicaciones en producción deberán elegir un backend persistente.

### Backends

Active Job tiene adaptadores integrados para múltiples backends de encolamiento (Sidekiq,
Resque, Delayed Job y otros). Para obtener una lista actualizada de los adaptadores,
consulta la Documentación de API para [`ActiveJob::QueueAdapters`][].


### Configuración del backend

Puedes configurar fácilmente tu backend de encolamiento con [`config.active_job.queue_adapter`]:

```ruby
# config/application.rb
module YourApp
  class Application < Rails::Application
    # Asegúrate de tener la gema del adaptador en tu Gemfile
    # y sigue las instrucciones específicas de instalación
    # y despliegue del adaptador.
    config.active_job.queue_adapter = :sidekiq
  end
end
```

También puedes configurar tu backend en función de cada trabajo:

```ruby
class GuestsCleanupJob < ApplicationJob
  self.queue_adapter = :resque
  # ...
end

# Ahora tu trabajo usará `resque` como su adaptador de cola de backend, anulando lo que
# se configuró en `config.active_job.queue_adapter`.
```
### Iniciando el Backend

Dado que los trabajos se ejecutan en paralelo a tu aplicación Rails, la mayoría de las bibliotecas de encolamiento requieren que inicies un servicio de encolamiento específico de la biblioteca (además de iniciar tu aplicación Rails) para que el procesamiento de trabajos funcione. Consulta la documentación de la biblioteca para obtener instrucciones sobre cómo iniciar tu backend de encolamiento.

Aquí tienes una lista no exhaustiva de documentación:

- [Sidekiq](https://github.com/mperham/sidekiq/wiki/Active-Job)
- [Resque](https://github.com/resque/resque/wiki/ActiveJob)
- [Sneakers](https://github.com/jondot/sneakers/wiki/How-To:-Rails-Background-Jobs-with-ActiveJob)
- [Sucker Punch](https://github.com/brandonhilkert/sucker_punch#active-job)
- [Queue Classic](https://github.com/QueueClassic/queue_classic#active-job)
- [Delayed Job](https://github.com/collectiveidea/delayed_job#active-job)
- [Que](https://github.com/que-rb/que#additional-rails-specific-setup)
- [Good Job](https://github.com/bensheldon/good_job#readme)

Colas
------

La mayoría de los adaptadores admiten múltiples colas. Con Active Job, puedes programar el trabajo para que se ejecute en una cola específica utilizando [`queue_as`][]:

```ruby
class GuestsCleanupJob < ApplicationJob
  queue_as :low_priority
  # ...
end
```

Puedes agregar un prefijo al nombre de la cola para todos tus trabajos utilizando [`config.active_job.queue_name_prefix`][] en `application.rb`:

```ruby
# config/application.rb
module YourApp
  class Application < Rails::Application
    config.active_job.queue_name_prefix = Rails.env
  end
end
```

```ruby
# app/jobs/guests_cleanup_job.rb
class GuestsCleanupJob < ApplicationJob
  queue_as :low_priority
  # ...
end

# Ahora tu trabajo se ejecutará en la cola production_low_priority en tu
# entorno de producción y en staging_low_priority
# en tu entorno de staging
```

También puedes configurar el prefijo de forma individual para cada trabajo.

```ruby
class GuestsCleanupJob < ApplicationJob
  queue_as :low_priority
  self.queue_name_prefix = nil
  # ...
end

# Ahora la cola de tu trabajo no tendrá prefijo, anulando lo que
# se configuró en `config.active_job.queue_name_prefix`.
```

El delimitador predeterminado para el prefijo del nombre de la cola es '\_'. Esto se puede cambiar configurando [`config.active_job.queue_name_delimiter`][] en `application.rb`:

```ruby
# config/application.rb
module YourApp
  class Application < Rails::Application
    config.active_job.queue_name_prefix = Rails.env
    config.active_job.queue_name_delimiter = '.'
  end
end
```

```ruby
# app/jobs/guests_cleanup_job.rb
class GuestsCleanupJob < ApplicationJob
  queue_as :low_priority
  # ...
end

# Ahora tu trabajo se ejecutará en la cola production.low_priority en tu
# entorno de producción y en staging.low_priority
# en tu entorno de staging
```

Si deseas tener más control sobre en qué cola se ejecutará un trabajo, puedes pasar la opción `:queue` a `set`:

```ruby
MyJob.set(queue: :another_queue).perform_later(record)
```

Para controlar la cola desde el nivel del trabajo, puedes pasar un bloque a `queue_as`. El bloque se ejecutará en el contexto del trabajo (por lo que puede acceder a `self.arguments`), y debe devolver el nombre de la cola:

```ruby
class ProcessVideoJob < ApplicationJob
  queue_as do
    video = self.arguments.first
    if video.owner.premium?
      :premium_videojobs
    else
      :videojobs
    end
  end

  def perform(video)
    # Realizar procesamiento de video
  end
end
```

```ruby
ProcessVideoJob.perform_later(Video.last)
```

NOTA: Asegúrate de que tu backend de encolamiento "escuche" en el nombre de tu cola. Para algunos backends, es necesario especificar las colas a las que escuchar.

Callbacks
---------

Active Job proporciona ganchos para activar lógica durante el ciclo de vida de un trabajo. Al igual que otros callbacks en Rails, puedes implementar los callbacks como métodos ordinarios y usar un método de clase en estilo macro para registrarlos como callbacks:

```ruby
class GuestsCleanupJob < ApplicationJob
  queue_as :default

  around_perform :around_cleanup

  def perform
    # Realizar algo más tarde
  end

  private
    def around_cleanup
      # Realizar algo antes de la ejecución
      yield
      # Realizar algo después de la ejecución
    end
end
```

Los métodos de clase en estilo macro también pueden recibir un bloque. Considera usar este estilo si el código dentro de tu bloque es tan corto que cabe en una sola línea. Por ejemplo, podrías enviar métricas para cada trabajo encolado:

```ruby
class ApplicationJob < ActiveJob::Base
  before_enqueue { |job| $statsd.increment "#{job.class.name.underscore}.enqueue" }
end
```

### Callbacks Disponibles

* [`before_enqueue`][]
* [`around_enqueue`][]
* [`after_enqueue`][]
* [`before_perform`][]
* [`around_perform`][]
* [`after_perform`][]


Action Mailer
------------

Uno de los trabajos más comunes en una aplicación web moderna es enviar correos electrónicos fuera del ciclo de solicitud-respuesta, para que el usuario no tenga que esperar. Active Job está integrado con Action Mailer, por lo que puedes enviar correos electrónicos de forma asíncrona fácilmente:

```ruby
# Si quieres enviar el correo electrónico ahora, usa #deliver_now
UserMailer.welcome(@user).deliver_now

# Si quieres enviar el correo electrónico a través de Active Job, usa #deliver_later
UserMailer.welcome(@user).deliver_later
```

NOTA: Usar la cola asíncrona desde una tarea de Rake (por ejemplo, para enviar un correo electrónico usando `.deliver_later`) generalmente no funcionará porque es probable que Rake finalice, lo que causará que el grupo de hilos en proceso se elimine, antes de que se procesen todos los correos electrónicos de `.deliver_later`. Para evitar este problema, usa `.deliver_now` o ejecuta una cola persistente en desarrollo.


Internacionalización
--------------------

Cada trabajo utiliza la configuración `I18n.locale` establecida cuando se creó el trabajo. Esto es útil si envías correos electrónicos de forma asíncrona:

```ruby
I18n.locale = :eo

UserMailer.welcome(@user).deliver_later # El correo electrónico se localizará al esperanto.
```


Tipos admitidos para los argumentos
----------------------------
ActiveJob admite los siguientes tipos de argumentos de forma predeterminada:

  - Tipos básicos (`NilClass`, `String`, `Integer`, `Float`, `BigDecimal`, `TrueClass`, `FalseClass`)
  - `Symbol`
  - `Date`
  - `Time`
  - `DateTime`
  - `ActiveSupport::TimeWithZone`
  - `ActiveSupport::Duration`
  - `Hash` (Las claves deben ser de tipo `String` o `Symbol`)
  - `ActiveSupport::HashWithIndifferentAccess`
  - `Array`
  - `Range`
  - `Module`
  - `Class`

### GlobalID

Active Job admite [GlobalID](https://github.com/rails/globalid/blob/master/README.md) para los parámetros. Esto permite pasar objetos de Active Record en vivo a su trabajo en lugar de pares de clase/id, que luego debe deserializar manualmente. Antes, los trabajos se verían así:

```ruby
class TrashableCleanupJob < ApplicationJob
  def perform(trashable_class, trashable_id, depth)
    trashable = trashable_class.constantize.find(trashable_id)
    trashable.cleanup(depth)
  end
end
```

Ahora simplemente puede hacer:

```ruby
class TrashableCleanupJob < ApplicationJob
  def perform(trashable, depth)
    trashable.cleanup(depth)
  end
end
```

Esto funciona con cualquier clase que mezcle `GlobalID::Identification`, que
por defecto se ha mezclado en las clases de Active Record.

### Serializadores

Puede ampliar la lista de tipos de argumentos admitidos. Solo necesita definir su propio serializador:

```ruby
# app/serializers/money_serializer.rb
class MoneySerializer < ActiveJob::Serializers::ObjectSerializer
  # Comprueba si un argumento debe ser serializado por este serializador.
  def serialize?(argument)
    argument.is_a? Money
  end

  # Convierte un objeto en una representación más simple utilizando tipos de objeto admitidos.
  # La representación recomendada es un Hash con una clave específica. Las claves solo pueden ser de tipos básicos.
  # Debe llamar a `super` para agregar el tipo de serializador personalizado al hash.
  def serialize(money)
    super(
      "amount" => money.amount,
      "currency" => money.currency
    )
  end

  # Convierte el valor serializado en un objeto adecuado.
  def deserialize(hash)
    Money.new(hash["amount"], hash["currency"])
  end
end
```

y agregue este serializador a la lista:

```ruby
# config/initializers/custom_serializers.rb
Rails.application.config.active_job.custom_serializers << MoneySerializer
```

Tenga en cuenta que no se admite la recarga automática de código recargable durante la inicialización. Por lo tanto, se recomienda
configurar los serializadores para que se carguen solo una vez, por ejemplo, modificando `config/application.rb` de esta manera:

```ruby
# config/application.rb
module YourApp
  class Application < Rails::Application
    config.autoload_once_paths << Rails.root.join('app', 'serializers')
  end
end
```

Excepciones
----------

Las excepciones generadas durante la ejecución del trabajo se pueden manejar con
[`rescue_from`][]:

```ruby
class GuestsCleanupJob < ApplicationJob
  queue_as :default

  rescue_from(ActiveRecord::RecordNotFound) do |exception|
    # Hacer algo con la excepción
  end

  def perform
    # Hacer algo más tarde
  end
end
```

Si una excepción de un trabajo no se rescata, entonces el trabajo se considera "fallido".


### Reintentar o Descartar Trabajos Fallidos

Un trabajo fallido no se volverá a intentar, a menos que se configure de otra manera.

Es posible reintentar o descartar un trabajo fallido usando [`retry_on`] o
[`discard_on`], respectivamente. Por ejemplo:

```ruby
class RemoteServiceJob < ApplicationJob
  retry_on CustomAppException # espera predeterminada de 3s, 5 intentos

  discard_on ActiveJob::DeserializationError

  def perform(*args)
    # Puede generar CustomAppException o ActiveJob::DeserializationError
  end
end
```


### Deserialización

GlobalID permite serializar objetos completos de Active Record que se pasan a `#perform`.

Si se elimina un registro pasado después de que el trabajo se haya encolado pero antes de que se llame al método `#perform`,
Active Job generará una excepción [`ActiveJob::DeserializationError`][].


Pruebas de trabajos
--------------

Puede encontrar instrucciones detalladas sobre cómo probar sus trabajos en la
[guía de pruebas](testing.html#testing-jobs).

Depuración
---------

Si necesita ayuda para averiguar de dónde vienen los trabajos, puede habilitar [registros detallados](debugging_rails_applications.html#verbose-enqueue-logs).
[`perform_later`]: https://api.rubyonrails.org/classes/ActiveJob/Enqueuing/ClassMethods.html#method-i-perform_later
[`set`]: https://api.rubyonrails.org/classes/ActiveJob/Core/ClassMethods.html#method-i-set
[`ActiveJob::QueueAdapters`]: https://api.rubyonrails.org/classes/ActiveJob/QueueAdapters.html
[`config.active_job.queue_adapter`]: configuring.html#config-active-job-queue-adapter
[`config.active_job.queue_name_delimiter`]: configuring.html#config-active-job-queue-name-delimiter
[`config.active_job.queue_name_prefix`]: configuring.html#config-active-job-queue-name-prefix
[`queue_as`]: https://api.rubyonrails.org/classes/ActiveJob/QueueName/ClassMethods.html#method-i-queue_as
[`before_enqueue`]: https://api.rubyonrails.org/classes/ActiveJob/Callbacks/ClassMethods.html#method-i-before_enqueue
[`around_enqueue`]: https://api.rubyonrails.org/classes/ActiveJob/Callbacks/ClassMethods.html#method-i-around_enqueue
[`after_enqueue`]: https://api.rubyonrails.org/classes/ActiveJob/Callbacks/ClassMethods.html#method-i-after_enqueue
[`before_perform`]: https://api.rubyonrails.org/classes/ActiveJob/Callbacks/ClassMethods.html#method-i-before_perform
[`around_perform`]: https://api.rubyonrails.org/classes/ActiveJob/Callbacks/ClassMethods.html#method-i-around_perform
[`after_perform`]: https://api.rubyonrails.org/classes/ActiveJob/Callbacks/ClassMethods.html#method-i-after_perform
[`rescue_from`]: https://api.rubyonrails.org/classes/ActiveSupport/Rescuable/ClassMethods.html#method-i-rescue_from
[`discard_on`]: https://api.rubyonrails.org/classes/ActiveJob/Exceptions/ClassMethods.html#method-i-discard_on
[`retry_on`]: https://api.rubyonrails.org/classes/ActiveJob/Exceptions/ClassMethods.html#method-i-retry_on
[`ActiveJob::DeserializationError`]: https://api.rubyonrails.org/classes/ActiveJob/DeserializationError.html
