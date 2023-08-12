**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: ffc6bf535a0dbd3487837673547ae486
Hilos y ejecución de código en Rails
=====================================

Después de leer esta guía, sabrás:

* Qué código ejecuta automáticamente Rails de forma concurrente
* Cómo integrar la concurrencia manual con los componentes internos de Rails
* Cómo envolver todo el código de la aplicación
* Cómo afectar la recarga de la aplicación

--------------------------------------------------------------------------------

Concurrencia automática
-----------------------

Rails permite automáticamente que varias operaciones se realicen al mismo tiempo.

Cuando se utiliza un servidor web con hilos, como el Puma por defecto, se pueden atender múltiples solicitudes HTTP simultáneamente, asignando a cada solicitud su propia instancia de controlador.

Los adaptadores de Active Job con hilos, incluido el Async incorporado, también ejecutarán varios trabajos al mismo tiempo. Los canales de Action Cable también se gestionan de esta manera.

Todos estos mecanismos implican múltiples hilos, cada uno gestionando el trabajo para una instancia única de algún objeto (controlador, trabajo, canal), mientras comparten el espacio de proceso global (como clases y sus configuraciones, y variables globales). Si tu código no modifica ninguna de esas cosas compartidas, en su mayoría puede ignorar que existen otros hilos.

El resto de esta guía describe los mecanismos que Rails utiliza para hacer que sea "en su mayoría ignorables" y cómo las extensiones y aplicaciones con necesidades especiales pueden utilizarlos.

Executor
--------

El Executor de Rails separa el código de la aplicación del código del framework: cada vez que el framework invoca el código que has escrito en tu aplicación, lo envuelve con el Executor.

El Executor consta de dos devoluciones de llamada: `to_run` y `to_complete`. La devolución de llamada Run se llama antes del código de la aplicación y la devolución de llamada Complete se llama después.

### Devoluciones de llamada por defecto

En una aplicación Rails por defecto, las devoluciones de llamada del Executor se utilizan para:

* rastrear qué hilos están en posiciones seguras para la carga automática y la recarga
* habilitar y deshabilitar la caché de consultas de Active Record
* devolver las conexiones adquiridas de Active Record al grupo
* limitar la vida útil de la caché interna

Antes de Rails 5.0, algunas de estas tareas eran manejadas por clases middleware de Rack separadas (como `ActiveRecord::ConnectionAdapters::ConnectionManagement`), o envolviendo directamente el código con métodos como `ActiveRecord::Base.connection_pool.with_connection`. El Executor reemplaza esto con una única interfaz más abstracta.

### Envolver el código de la aplicación

Si estás escribiendo una biblioteca o componente que invocará código de la aplicación, debes envolverlo con una llamada al executor:

```ruby
Rails.application.executor.wrap do
  # llama al código de la aplicación aquí
end
```

CONSEJO: Si invocas repetidamente código de la aplicación desde un proceso en ejecución prolongada, es posible que desees envolverlo utilizando el [Reloader](#reloader) en su lugar.

Cada hilo debe envolverse antes de ejecutar el código de la aplicación, por lo que si tu aplicación delega manualmente el trabajo a otros hilos, como a través de `Thread.new` o características de Concurrent Ruby que utilizan grupos de hilos, debes envolver inmediatamente el bloque:

```ruby
Thread.new do
  Rails.application.executor.wrap do
    # tu código aquí
  end
end
```

NOTA: Concurrent Ruby utiliza un `ThreadPoolExecutor`, que a veces se configura con una opción `executor`. A pesar del nombre, no está relacionado.

El Executor es seguramente reentrante; si ya está activo en el hilo actual, `wrap` no hace nada.

Si no es práctico envolver el código de la aplicación en un bloque (por ejemplo, la API de Rack hace que esto sea problemático), también puedes usar el par `run!` / `complete!`:

```ruby
Thread.new do
  execution_context = Rails.application.executor.run!
  # tu código aquí
ensure
  execution_context.complete! if execution_context
end
```

### Concurrencia

El Executor pondrá el hilo actual en modo `running` en el [Load Interlock](#load-interlock). Esta operación bloqueará temporalmente si otro hilo está cargando automáticamente una constante o descargando/recargando la aplicación.

Reloader
--------

Al igual que el Executor, el Reloader también envuelve el código de la aplicación. Si el Executor no está activo en el hilo actual, el Reloader lo invocará por ti, por lo que solo necesitas llamar a uno. Esto también garantiza que todo lo que hace el Reloader, incluidas todas sus invocaciones de devolución de llamada, se realiza envuelto dentro del Executor.

```ruby
Rails.application.reloader.wrap do
  # llama al código de la aplicación aquí
end
```

El Reloader solo es adecuado donde un proceso de nivel de framework en ejecución prolongada llama repetidamente al código de la aplicación, como un servidor web o una cola de trabajos. Rails envuelve automáticamente las solicitudes web y los trabajadores de Active Job, por lo que rara vez necesitarás invocar al Reloader por ti mismo. Siempre considera si el Executor es más adecuado para tu caso de uso.

### Devoluciones de llamada

Antes de entrar en el bloque envuelto, el Reloader comprobará si la aplicación en ejecución necesita ser recargada, por ejemplo, porque se ha modificado el archivo fuente de un modelo. Si determina que se requiere una recarga, esperará hasta que sea seguro y luego lo hará antes de continuar. Cuando la aplicación está configurada para recargar siempre independientemente de si se detectan cambios, la recarga se realiza al final del bloque.
El Reloader también proporciona devoluciones de llamada `to_run` y `to_complete`; se invocan en los mismos puntos que las del Executor, pero solo cuando la ejecución actual ha iniciado una recarga de la aplicación. Cuando no se considera necesaria una recarga, el Reloader invocará el bloque envuelto sin otras devoluciones de llamada.

### Descarga de Clases

La parte más significativa del proceso de recarga es la Descarga de Clases, donde se eliminan todas las clases cargadas automáticamente, listas para ser cargadas nuevamente. Esto ocurrirá inmediatamente antes de la devolución de llamada Run o Complete, dependiendo de la configuración `reload_classes_only_on_change`.

A menudo, se necesitan realizar acciones adicionales de recarga ya sea justo antes o justo después de la Descarga de Clases, por lo que el Reloader también proporciona devoluciones de llamada `before_class_unload` y `after_class_unload`.

### Concurrencia

Solo los procesos "de nivel superior" de larga duración deben invocar al Reloader, porque si determina que se necesita una recarga, se bloqueará hasta que todos los demás hilos hayan completado cualquier invocación del Executor.

Si esto ocurriera en un hilo "hijo", con un padre en espera dentro del Executor, causaría un bloqueo inevitable: la recarga debe ocurrir antes de que se ejecute el hilo hijo, pero no se puede realizar de manera segura mientras el hilo padre está en medio de la ejecución. Los hilos hijos deben usar el Executor en su lugar.

Comportamiento del Framework
------------------

Los componentes del framework Rails también utilizan estas herramientas para gestionar sus propias necesidades de concurrencia.

`ActionDispatch::Executor` y `ActionDispatch::Reloader` son middlewares de Rack que envuelven las solicitudes con un Executor o Reloader suministrado, respectivamente. Se incluyen automáticamente en la pila de aplicaciones predeterminada. El Reloader asegurará que cualquier solicitud HTTP que llegue se sirva con una copia recién cargada de la aplicación si se han producido cambios en el código.

Active Job también envuelve las ejecuciones de sus trabajos con el Reloader, cargando el código más reciente para ejecutar cada trabajo a medida que sale de la cola.

Action Cable utiliza el Executor en su lugar: debido a que una conexión de Cable está vinculada a una instancia específica de una clase, no es posible recargar para cada mensaje WebSocket que llega. Sin embargo, solo se envuelve el controlador de mensajes; una conexión de Cable de larga duración no impide una recarga que se activa por una nueva solicitud o trabajo entrante. En su lugar, Action Cable utiliza la devolución de llamada `before_class_unload` del Reloader para desconectar todas sus conexiones. Cuando el cliente se reconecta automáticamente, estará hablando con la nueva versión del código.

Los anteriores son los puntos de entrada al framework, por lo que son responsables de asegurar que sus respectivos hilos estén protegidos y decidir si es necesaria una recarga. Otros componentes solo necesitan usar el Executor cuando generan hilos adicionales.

### Configuración

El Reloader solo verifica los cambios de archivos cuando `config.enable_reloading` es `true` y también `config.reload_classes_only_on_change`. Estos son los valores predeterminados en el entorno `development`.

Cuando `config.enable_reloading` es `false` (en `production`, de forma predeterminada), el Reloader solo es un paso intermedio hacia el Executor.

El Executor siempre tiene un trabajo importante que hacer, como la gestión de la conexión a la base de datos. Cuando `config.enable_reloading` es `false` y `config.eager_load` es `true` (valores predeterminados en `production`), no se producirá ninguna recarga, por lo que no necesita el Bloqueo de Carga. Con la configuración predeterminada en el entorno `development`, el Executor utilizará el Bloqueo de Carga para asegurarse de que las constantes solo se carguen cuando sea seguro.

Bloqueo de Carga
--------------

El Bloqueo de Carga permite habilitar la carga automática y la recarga en un entorno de tiempo de ejecución multinúcleo.

Cuando un hilo está realizando una carga automática evaluando la definición de clase desde el archivo correspondiente, es importante que ningún otro hilo encuentre una referencia a la constante parcialmente definida.

De manera similar, solo es seguro realizar una descarga/recarga cuando no hay código de la aplicación en ejecución: después de la recarga, la constante `User`, por ejemplo, puede apuntar a una clase diferente. Sin esta regla, una recarga mal sincronizada significaría que `User.new.class == User`, o incluso `User == User`, podría ser falso.

Ambas restricciones se abordan mediante el Bloqueo de Carga. Realiza un seguimiento de qué hilos están ejecutando código de la aplicación actualmente, cargando una clase o descargando constantes cargadas automáticamente.

Solo un hilo puede cargar o descargar a la vez, y para hacerlo, debe esperar hasta que ningún otro hilo esté ejecutando código de la aplicación. Si un hilo está esperando para realizar una carga, no impide que otros hilos carguen (de hecho, cooperarán y cada uno realizará su carga en cola a su vez, antes de que todos vuelvan a ejecutarse juntos).

### `permit_concurrent_loads`

El Executor adquiere automáticamente un bloqueo `running` durante la duración de su bloque, y la carga automática sabe cuándo actualizar a un bloqueo de `load` y cambiar nuevamente a `running` después.
Otras operaciones de bloqueo realizadas dentro del bloque Executor (que incluye todo el código de la aplicación), sin embargo, pueden retener innecesariamente el bloqueo "running". Si otro hilo encuentra una constante que debe cargarse automáticamente, esto puede causar un bloqueo.

Por ejemplo, suponiendo que "User" aún no se ha cargado, lo siguiente causará un bloqueo:

```ruby
Rails.application.executor.wrap do
  th = Thread.new do
    Rails.application.executor.wrap do
      User # el hilo interno espera aquí; no puede cargar
           # User mientras otro hilo está en ejecución
    end
  end

  th.join # el hilo externo espera aquí, manteniendo el bloqueo 'running'
end
```

Para evitar este bloqueo, el hilo externo puede utilizar `permit_concurrent_loads`. Al llamar a este método, el hilo garantiza que no desreferenciará ninguna constante posiblemente cargada automáticamente dentro del bloque suministrado. La forma más segura de cumplir esa promesa es colocarla lo más cerca posible de la llamada de bloqueo:

```ruby
Rails.application.executor.wrap do
  th = Thread.new do
    Rails.application.executor.wrap do
      User # el hilo interno puede adquirir el bloqueo 'load',
           # cargar User y continuar
    end
  end

  ActiveSupport::Dependencies.interlock.permit_concurrent_loads do
    th.join # el hilo externo espera aquí, pero no tiene bloqueo
  end
end
```

Otro ejemplo, utilizando Concurrent Ruby:

```ruby
Rails.application.executor.wrap do
  futures = 3.times.collect do |i|
    Concurrent::Promises.future do
      Rails.application.executor.wrap do
        # hacer trabajo aquí
      end
    end
  end

  values = ActiveSupport::Dependencies.interlock.permit_concurrent_loads do
    futures.collect(&:value)
  end
end
```

### ActionDispatch::DebugLocks

Si tu aplicación está bloqueada y crees que el Load Interlock puede estar involucrado, puedes agregar temporalmente el middleware ActionDispatch::DebugLocks a `config/application.rb`:

```ruby
config.middleware.insert_before Rack::Sendfile,
                                  ActionDispatch::DebugLocks
```

Si luego reinicias la aplicación y vuelves a desencadenar la condición de bloqueo, `/rails/locks` mostrará un resumen de todos los hilos actualmente conocidos por el interlock, qué nivel de bloqueo están sosteniendo o esperando y su traza de llamadas actual.

Generalmente, un bloqueo se producirá debido a que el interlock entra en conflicto con algún otro bloqueo externo o llamada de E/S bloqueante. Una vez que lo encuentres, puedes envolverlo con `permit_concurrent_loads`.
