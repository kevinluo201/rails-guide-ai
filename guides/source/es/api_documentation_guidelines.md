**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 58b6e6f83da0f420f5da5f7d38d938db
Directrices de Documentación de API
====================================

Esta guía documenta las directrices de documentación de la API de Ruby on Rails.

Después de leer esta guía, sabrás:

* Cómo escribir prosa efectiva con fines de documentación.
* Directrices de estilo para documentar diferentes tipos de código Ruby.

--------------------------------------------------------------------------------

RDoc
----

La [documentación de la API de Rails](https://api.rubyonrails.org) se genera con
[RDoc](https://ruby.github.io/rdoc/). Para generarla, asegúrate de estar
en el directorio raíz de Rails, ejecuta `bundle install` y luego ejecuta:

```bash
$ bundle exec rake rdoc
```

Los archivos HTML resultantes se pueden encontrar en el directorio ./doc/rdoc.

NOTA: Consulta la [Referencia de Marcado][RDoc Markup] de RDoc para obtener ayuda con la sintaxis.

Enlaces
-------

La documentación de la API de Rails no está destinada a ser vista en GitHub, por lo tanto, los enlaces deben usar el marcado [`link`][RDoc Links] de RDoc en relación a la API actual.

Esto se debe a las diferencias entre el Markdown de GitHub y el RDoc generado que se publica en [api.rubyonrails.org](https://api.rubyonrails.org) y [edgeapi.rubyonrails.org](https://edgeapi.rubyonrails.org).

Por ejemplo, usamos `[link:classes/ActiveRecord/Base.html]` para crear un enlace a la clase `ActiveRecord::Base` generada por RDoc.

Esto es preferible a las URL absolutas como `[https://api.rubyonrails.org/classes/ActiveRecord/Base.html]`, que llevarían al lector fuera de su versión actual de documentación (por ejemplo, edgeapi.rubyonrails.org).

[RDoc Markup]: https://ruby.github.io/rdoc/RDoc/MarkupReference.html
[RDoc Links]: https://ruby.github.io/rdoc/RDoc/MarkupReference.html#class-RDoc::MarkupReference-label-Links

Redacción
---------

Escribe frases simples y declarativas. La brevedad es una ventaja: ve al grano.

Escribe en presente: "Devuelve un hash que...", en lugar de "Devuelve un hash que..." o "Devolverá un hash que...".

Comienza los comentarios en mayúscula. Sigue las reglas de puntuación habituales:

```ruby
# Declara un lector de atributos respaldado por una variable de instancia con nombre interno.
def attr_internal_reader(*attrs)
  # ...
end
```

Comunica al lector la forma actual de hacer las cosas, tanto de forma explícita como implícita. Utiliza los modismos recomendados en edge. Reordena las secciones para enfatizar los enfoques preferidos si es necesario, etc. La documentación debe ser un modelo de mejores prácticas y uso canónico y moderno de Rails.

La documentación debe ser breve pero completa. Explora y documenta casos límite. ¿Qué sucede si un módulo es anónimo? ¿Qué sucede si una colección está vacía? ¿Qué sucede si un argumento es nulo?

Los nombres correctos de los componentes de Rails tienen un espacio entre las palabras, como "Active Support". `ActiveRecord` es un módulo de Ruby, mientras que Active Record es un ORM. Toda la documentación de Rails debe referirse consistentemente a los componentes de Rails por sus nombres correctos.

Cuando se hace referencia a una "aplicación de Rails", en contraposición a un "motor" o "plugin", siempre se debe usar "aplicación". Las aplicaciones de Rails no son "servicios", a menos que se hable específicamente sobre arquitectura orientada a servicios.

Escribe correctamente los nombres: Arel, minitest, RSpec, HTML, MySQL, JavaScript, ERB, Hotwire. Cuando tengas dudas, consulta alguna fuente autorizada como su documentación oficial.

Prefiere redacciones que eviten los "tú" y "tu". Por ejemplo, en lugar de

```markdown
Si necesitas usar declaraciones `return` en tus callbacks, se recomienda que las definas explícitamente como métodos.
```

utiliza este estilo:

```markdown
Si se necesita `return`, se recomienda definir explícitamente un método.
```

Dicho esto, al usar pronombres en referencia a una persona hipotética, como "un
usuario con una cookie de sesión", se deben usar pronombres de género neutro (they/their/them). En lugar de:

* he o she... usa they.
* him o her... usa them.
* his o her... usa their.
* his o hers... usa theirs.
* himself o herself... usa themselves.

Inglés
------

Utiliza el inglés estadounidense (*color*, *center*, *modularize*, etc). Consulta [una lista de diferencias de ortografía entre el inglés estadounidense y británico aquí](https://en.wikipedia.org/wiki/American_and_British_English_spelling_differences).

Coma de Oxford
--------------

Utiliza la [coma de Oxford](https://en.wikipedia.org/wiki/Serial_comma)
("rojo, blanco y azul", en lugar de "rojo, blanco y azul").

Código de Ejemplo
-----------------

Elige ejemplos significativos que representen y cubran los conceptos básicos, así como puntos interesantes o problemas.

Utiliza dos espacios para indentar fragmentos de código, es decir, con fines de marcado, dos espacios con respecto al margen izquierdo. Los ejemplos en sí deben seguir las [convenciones de codificación de Rails](contributing_to_ruby_on_rails.html#follow-the-coding-conventions).

Los documentos cortos no necesitan una etiqueta explícita "Ejemplos" para introducir fragmentos; simplemente siguen los párrafos:

```ruby
# Convierte una colección de elementos en una cadena formateada llamando a +to_s+ en todos los elementos y uniéndolos.
#
#   Blog.all.to_fs # => "First PostSecond PostThird Post"
```

Por otro lado, los grandes fragmentos de documentación estructurada pueden tener una sección separada de "Ejemplos":

```ruby
# ==== Ejemplos
#
#   Person.exists?(5)
#   Person.exists?('5')
#   Person.exists?(name: "David")
#   Person.exists?(['name LIKE ?', "%#{query}%"])
```
Los resultados de las expresiones los siguen y se introducen con "# => ", alineados verticalmente:

```ruby
# Para verificar si un entero es par o impar.
#
#   1.even? # => false
#   1.odd?  # => true
#   2.even? # => true
#   2.odd?  # => false
```

Si una línea es demasiado larga, el comentario puede colocarse en la siguiente línea:

```ruby
#   label(:article, :title)
#   # => <label for="article_title">Title</label>
#
#   label(:article, :title, "A short title")
#   # => <label for="article_title">A short title</label>
#
#   label(:article, :title, "A short title", class: "title_label")
#   # => <label for="article_title" class="title_label">A short title</label>
```

Evite usar métodos de impresión como `puts` o `p` para ese propósito.

Por otro lado, los comentarios regulares no usan una flecha:

```ruby
#   polymorphic_url(record)  # same as comment_url(record)
```

### SQL

Cuando se documentan declaraciones SQL, el resultado no debe tener `=>` antes de la salida.

Por ejemplo,

```ruby
#   User.where(name: 'Oscar').to_sql
#   # SELECT "users".* FROM "users"  WHERE "users"."name" = 'Oscar'
```

### IRB

Cuando se documenta el comportamiento para IRB, el REPL interactivo de Ruby, siempre se debe agregar el prefijo `irb>` a los comandos y la salida debe tener el prefijo `=>`.

Por ejemplo,

```
# Find the customer with primary key (id) 10.
#   irb> customer = Customer.find(10)
#   # => #<Customer id: 10, first_name: "Ryan">
```

### Bash / Línea de comandos

Para ejemplos de línea de comandos, siempre agregue el comando con el prefijo `$`, la salida no tiene que tener ningún prefijo.

```
# Run the following command:
#   $ bin/rails new zomg
#   ...
```

Booleanos
--------

En predicados y banderas, prefiera documentar la semántica booleana en lugar de los valores exactos.

Cuando se utilizan "true" o "false" como se define en Ruby, use una fuente regular. Los singletones `true` y `false` necesitan una fuente de ancho fijo. Evite términos como "truthy", Ruby define lo que es verdadero y falso en el lenguaje, por lo que esas palabras tienen un significado técnico y no necesitan sustitutos.

Como regla general, no documente singletones a menos que sea absolutamente necesario. Esto evita construcciones artificiales como `!!` o ternarios, permite refactorizaciones y el código no necesita depender de los valores exactos devueltos por los métodos llamados en la implementación.

Por ejemplo:

```markdown
`config.action_mailer.perform_deliveries` especifica si el correo se entregará realmente y es verdadero de forma predeterminada
```

el usuario no necesita saber cuál es el valor predeterminado real de la bandera, por lo que solo documentamos su semántica booleana.

Un ejemplo con un predicado:

```ruby
# Returns true if the collection is empty.
#
# If the collection has been loaded
# it is equivalent to <tt>collection.size.zero?</tt>. If the
# collection has not been loaded, it is equivalent to
# <tt>!collection.exists?</tt>. If the collection has not already been
# loaded and you are going to fetch the records anyway it is better to
# check <tt>collection.length.zero?</tt>.
def empty?
  if loaded?
    size.zero?
  else
    @target.blank? && !scope.exists?
  end
end
```

La API se asegura de no comprometerse con ningún valor en particular, el método tiene semántica de predicado, eso es suficiente.

Nombres de archivos
----------

Como regla general, use nombres de archivos relativos a la raíz de la aplicación:

```
config/routes.rb            # SÍ
routes.rb                   # NO
RAILS_ROOT/config/routes.rb # NO
```

Fuentes
-----

### Fuente de ancho fijo

Use fuentes de ancho fijo para:

* Constantes, en particular nombres de clases y módulos.
* Nombres de métodos.
* Literales como `nil`, `false`, `true`, `self`.
* Símbolos.
* Parámetros de métodos.
* Nombres de archivos.

```ruby
class Array
  # Calls +to_param+ on all its elements and joins the result with
  # slashes. This is used by +url_for+ in Action Pack.
  def to_param
    collect { |e| e.to_param }.join '/'
  end
end
```

ADVERTENCIA: El uso de `+...+` para la fuente de ancho fijo solo funciona con contenido simple como clases ordinarias, módulos, nombres de métodos, símbolos, rutas (con barras diagonales), etc. Por favor, use `<tt>...</tt>` para todo lo demás.

Puede probar rápidamente la salida de RDoc con el siguiente comando:

```bash
$ echo "+:to_param+" | rdoc --pipe
# => <p><code>:to_param</code></p>
```

Por ejemplo, el código con espacios o comillas debe usar la forma `<tt>...</tt>`.

### Fuente regular

Cuando "true" y "false" son palabras en inglés en lugar de palabras clave de Ruby, use una fuente regular:

```ruby
# Runs all the validations within the specified context.
# Returns true if no errors are found, false otherwise.
#
# If the argument is false (default is +nil+), the context is
# set to <tt>:create</tt> if <tt>new_record?</tt> is true,
# and to <tt>:update</tt> if it is not.
#
# Validations with no <tt>:on</tt> option will run no
# matter the context. Validations with # some <tt>:on</tt>
# option will only run in the specified context.
def valid?(context = nil)
  # ...
end
```
Listas de descripción
-----------------

En listas de opciones, parámetros, etc., use un guión entre el elemento y su descripción (se lee mejor que dos puntos porque normalmente las opciones son símbolos):

```ruby
# * <tt>:allow_nil</tt> - Salta la validación si el atributo es +nil+.
```

La descripción comienza con mayúscula y termina con un punto final, es inglés estándar.

Un enfoque alternativo, cuando se desea proporcionar detalles adicionales y ejemplos, es utilizar el estilo de sección de opciones.

[`ActiveSupport::MessageEncryptor#encrypt_and_sign`][#encrypt_and_sign] es un gran ejemplo de esto.

```ruby
# ==== Opciones
#
# [+:expires_at+]
#   La fecha y hora en la que el mensaje expira. Después de esta fecha y hora,
#   la verificación del mensaje fallará.
#
#     message = encryptor.encrypt_and_sign("hello", expires_at: Time.now.tomorrow)
#     encryptor.decrypt_and_verify(message) # => "hello"
#     # 24 horas después...
#     encryptor.decrypt_and_verify(message) # => nil
```


Métodos generados dinámicamente
-----------------------------

Los métodos creados con `(module|class)_eval(STRING)` tienen un comentario a su lado con una instancia del código generado. Ese comentario está a 2 espacios de distancia de la plantilla:

[![(module|class)_eval(STRING) code comments](images/dynamic_method_class_eval.png)](images/dynamic_method_class_eval.png)

Si las líneas resultantes son demasiado anchas, por ejemplo, 200 columnas o más, coloque el comentario encima de la llamada:

```ruby
# def self.find_by_login_and_activated(*args)
#   options = args.extract_options!
#   ...
# end
self.class_eval %{
  def self.#{method_id}(*args)
    options = args.extract_options!
    ...
  end
}, __FILE__, __LINE__
```

Visibilidad del método
-----------------

Al escribir documentación para Rails, es importante entender la diferencia entre la API pública orientada al usuario y la API interna.

Rails, como la mayoría de las bibliotecas, utiliza la palabra clave `private` de Ruby para definir la API interna. Sin embargo, la API pública sigue una convención ligeramente diferente. En lugar de asumir que todos los métodos públicos están diseñados para el consumo del usuario, Rails utiliza la directiva `:nodoc:` para anotar este tipo de métodos como API interna.

Esto significa que hay métodos en Rails con visibilidad `public` que no están destinados al consumo del usuario.

Un ejemplo de esto es `ActiveRecord::Core::ClassMethods#arel_table`:

```ruby
module ActiveRecord::Core::ClassMethods
  def arel_table # :nodoc:
    # hacer algo de magia...
  end
end
```

Si pensaste, "este método parece un método de clase público para `ActiveRecord::Core`", tenías razón. Pero en realidad, el equipo de Rails no quiere que los usuarios dependan de este método. Por lo tanto, lo marcan como `:nodoc:` y se elimina de la documentación pública. La razón detrás de esto es permitir que el equipo cambie estos métodos según sus necesidades internas en las versiones según lo consideren necesario. El nombre de este método podría cambiar, al igual que el valor de retorno, o toda esta clase podría desaparecer; no hay garantía y por lo tanto no debes depender de esta API en tus complementos o aplicaciones. De lo contrario, corres el riesgo de que tu aplicación o gema se rompa cuando actualices a una versión más reciente de Rails.

Como colaborador, es importante pensar si esta API está destinada al consumo del usuario final. El equipo de Rails se compromete a no realizar cambios que rompan la API pública en las versiones sin pasar por un ciclo completo de deprecación. Se recomienda que uses `:nodoc:` en cualquiera de tus métodos/clases internas a menos que ya sean privados (en cuanto a visibilidad), en cuyo caso ya son internos por defecto. Una vez que la API se estabilice, la visibilidad puede cambiar, pero cambiar la API pública es mucho más difícil debido a la compatibilidad con versiones anteriores.

Una clase o módulo se marca con `:nodoc:` para indicar que todos los métodos son API interna y nunca deben usarse directamente.

En resumen, el equipo de Rails utiliza `:nodoc:` para marcar métodos y clases visibles públicamente para uso interno; los cambios en la visibilidad de la API deben considerarse cuidadosamente y discutirse en una solicitud de extracción primero.

Respecto a la pila de Rails
-------------------------

Al documentar partes de la API de Rails, es importante recordar todas las piezas que forman parte de la pila de Rails.

Esto significa que el comportamiento puede cambiar dependiendo del alcance o contexto del método o clase que estás intentando documentar.

En varios lugares hay un comportamiento diferente cuando se tiene en cuenta toda la pila de Rails, un ejemplo de esto es `ActionView::Helpers::AssetTagHelper#image_tag`:

```ruby
# image_tag("icon.png")
#   # => <img src="/assets/icon.png" />
```

Aunque el comportamiento predeterminado de `#image_tag` es siempre devolver `/images/icon.png`, cuando tenemos en cuenta la pila completa de Rails (incluido el Pipeline de activos) podemos ver el resultado mencionado anteriormente.

Solo nos interesa el comportamiento experimentado al usar la pila predeterminada completa de Rails.

En este caso, queremos documentar el comportamiento del _framework_, y no solo de este método específico.

Si tienes alguna pregunta sobre cómo el equipo de Rails maneja cierta API, no dudes en abrir un ticket o enviar un parche al [rastreador de problemas](https://github.com/rails/rails/issues).
[#encrypt_and_sign]: https://edgeapi.rubyonrails.org/classes/ActiveSupport/MessageEncryptor.html#method-i-encrypt_and_sign
