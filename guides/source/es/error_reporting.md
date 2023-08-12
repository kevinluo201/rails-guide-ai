**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: e904ad42aee9a68f37b4e79e0b70b685
Informes de errores en aplicaciones Rails
========================

Esta guía presenta formas de gestionar las excepciones que ocurren en las aplicaciones Ruby on Rails.

Después de leer esta guía, sabrás:

* Cómo utilizar el informe de errores de Rails para capturar y reportar errores.
* Cómo crear suscriptores personalizados para su servicio de informes de errores.

--------------------------------------------------------------------------------

Informe de errores
------------------------

El informe de errores de Rails proporciona una forma estándar de recopilar excepciones que ocurren en su aplicación y reportarlas a su servicio o ubicación preferida.

El informe de errores tiene como objetivo reemplazar el código de manejo de errores repetitivo como este:

```ruby
begin
  hacer_algo
rescue AlgoEstaRoto => error
  MiServicioDeInformeDeErrores.notificar(error)
end
```

con una interfaz consistente:

```ruby
Rails.error.handle(AlgoEstaRoto) do
  hacer_algo
end
```

Rails envuelve todas las ejecuciones (como solicitudes HTTP, trabajos e invocaciones de `rails runner`) en el informe de errores, por lo que cualquier error no manejado que se produzca en su aplicación se informará automáticamente a su servicio de informes de errores a través de sus suscriptores.

Esto significa que las bibliotecas de informes de errores de terceros ya no necesitan insertar un middleware de Rack ni hacer ningún parche para capturar excepciones no manejadas. Las bibliotecas que utilizan ActiveSupport también pueden utilizar esto para informar advertencias de forma no intrusiva que antes se habrían perdido en los registros.

No es obligatorio utilizar el informe de errores de Rails. Todas las demás formas de capturar errores siguen funcionando.

### Suscripción al informe

Para utilizar el informe de errores, necesita un _suscriptor_. Un suscriptor es cualquier objeto con un método `report`. Cuando ocurre un error en su aplicación o se informa manualmente, el informe de errores de Rails llamará a este método con el objeto de error y algunas opciones.

Algunas bibliotecas de informes de errores, como [Sentry](https://github.com/getsentry/sentry-ruby/blob/e18ce4b6dcce2ebd37778c1e96164684a1e9ebfc/sentry-rails/lib/sentry/rails/error_subscriber.rb) y [Honeybadger](https://docs.honeybadger.io/lib/ruby/integration-guides/rails-exception-tracking/), se registran automáticamente como suscriptores. Consulte la documentación de su proveedor para obtener más detalles.

También puede crear un suscriptor personalizado. Por ejemplo:

```ruby
# config/initializers/error_subscriber.rb
class ErrorSubscriber
  def report(error, handled:, severity:, context:, source: nil)
    MyErrorReportingService.report_error(error, context: context, handled: handled, level: severity)
  end
end
```

Después de definir la clase del suscriptor, regístrela llamando al método [`Rails.error.subscribe`](https://api.rubyonrails.org/classes/ActiveSupport/ErrorReporter.html#method-i-subscribe):

```ruby
Rails.error.subscribe(ErrorSubscriber.new)
```

Puede registrar tantos suscriptores como desee. Rails los llamará en orden, en el orden en que se registraron.

NOTA: El informe de errores de Rails siempre llamará a los suscriptores registrados, independientemente de su entorno. Sin embargo, muchos servicios de informes de errores solo informan errores en producción de forma predeterminada. Debe configurar y probar su configuración en todos los entornos según sea necesario.

### Uso del informe de errores

Hay tres formas en las que puede utilizar el informe de errores:

#### Informar y omitir errores

[`Rails.error.handle`](https://api.rubyonrails.org/classes/ActiveSupport/ErrorReporter.html#method-i-handle) informará cualquier error que se produzca dentro del bloque. Luego **omitirá** el error y el resto de su código fuera del bloque continuará como de costumbre.

```ruby
resultado = Rails.error.handle do
  1 + '1' # genera TypeError
end
resultado # => nil
1 + 1 # Esto se ejecutará
```

Si no se produce ningún error en el bloque, `Rails.error.handle` devolverá el resultado del bloque, de lo contrario devolverá `nil`. Puede anular esto proporcionando un `fallback`:

```ruby
usuario = Rails.error.handle(fallback: -> { User.anonymous }) do
  User.find_by(params[:id])
end
```

#### Informar y volver a generar errores

[`Rails.error.record`](https://api.rubyonrails.org/classes/ActiveSupport/ErrorReporter.html#method-i-record) informará errores a todos los suscriptores registrados y luego volverá a generar el error, lo que significa que el resto de su código no se ejecutará.

```ruby
Rails.error.record do
  1 + '1' # genera TypeError
end
1 + 1 # Esto no se ejecutará
```

Si no se produce ningún error en el bloque, `Rails.error.record` devolverá el resultado del bloque.

#### Informar errores manualmente

También puede informar errores manualmente llamando a [`Rails.error.report`](https://api.rubyonrails.org/classes/ActiveSupport/ErrorReporter.html#method-i-report):

```ruby
begin
  # código
rescue StandardError => e
  Rails.error.report(e)
end
```

Cualquier opción que pase se pasará a los suscriptores de errores.

### Opciones de informe de errores

Las 3 API de informe (`#handle`, `#record` y `#report`) admiten las siguientes opciones, que luego se pasan a todos los suscriptores registrados:

- `handled`: un `Boolean` para indicar si el error fue manejado. Esto se establece en `true` de forma predeterminada. `#record` lo establece en `false`.
- `severity`: un `Symbol` que describe la gravedad del error. Los valores esperados son: `:error`, `:warning` y `:info`. `#handle` lo establece en `:warning`, mientras que `#record` lo establece en `:error`.
- `context`: un `Hash` para proporcionar más contexto sobre el error, como detalles de la solicitud o del usuario.
- `source`: una `String` sobre la fuente del error. La fuente predeterminada es `"application"`. Los errores informados por bibliotecas internas pueden establecer otras fuentes; por ejemplo, la biblioteca de caché de Redis puede usar `"redis_cache_store.active_support"`. Su suscriptor puede utilizar la fuente para ignorar errores en los que no esté interesado.
```ruby
Rails.error.handle(context: { user_id: user.id }, severity: :info) do
  # ...
end
```

### Filtrado por Clases de Error

Con `Rails.error.handle` y `Rails.error.record`, también puedes elegir reportar solo errores de ciertas clases. Por ejemplo:

```ruby
Rails.error.handle(IOError) do
  1 + '1' # genera TypeError
end
1 + 1 # Los TypeErrors no son IOError, por lo que esto *no* se ejecutará
```

Aquí, el `TypeError` no será capturado por el reportero de errores de Rails. Solo se reportarán instancias de `IOError` y sus descendientes. Cualquier otro error se generará normalmente.

### Configuración de Contexto Global

Además de configurar el contexto a través de la opción `context`, puedes usar la API [`#set_context`](https://api.rubyonrails.org/classes/ActiveSupport/ErrorReporter.html#method-i-set_context). Por ejemplo:

```ruby
Rails.error.set_context(section: "checkout", user_id: @user.id)
```

Cualquier contexto configurado de esta manera se fusionará con la opción `context`.

```ruby
Rails.error.set_context(a: 1)
Rails.error.handle(context: { b: 2 }) { raise }
# El contexto reportado será: {:a=>1, :b=>2}
Rails.error.handle(context: { b: 3 }) { raise }
# El contexto reportado será: {:a=>1, :b=>3}
```

### Para Bibliotecas

Las bibliotecas de reporte de errores pueden registrar sus suscriptores en un `Railtie`:

```ruby
module MySdk
  class Railtie < ::Rails::Railtie
    initializer "my_sdk.error_subscribe" do
      Rails.error.subscribe(MyErrorSubscriber.new)
    end
  end
end
```

Si registras un suscriptor de errores, pero aún tienes otros mecanismos de errores como un middleware de Rack, es posible que los errores se reporten varias veces. Debes eliminar tus otros mecanismos o ajustar la funcionalidad de reporte para que omita reportar una excepción que ya haya visto antes.
