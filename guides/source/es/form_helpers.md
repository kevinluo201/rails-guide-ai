**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 975163c53746728404fb3a3658fbd0f6
Ayudantes de Formularios de Action View
========================================

Los formularios en aplicaciones web son una interfaz esencial para la entrada de usuarios. Sin embargo, el marcado de formularios puede volverse rápidamente tedioso de escribir y mantener debido a la necesidad de manejar el nombre de los controles del formulario y sus numerosos atributos. Rails simplifica esta complejidad al proporcionar ayudantes de vista para generar el marcado de formularios. Sin embargo, dado que estos ayudantes tienen diferentes casos de uso, los desarrolladores deben conocer las diferencias entre los métodos de ayuda antes de utilizarlos.

Después de leer esta guía, sabrás:

* Cómo crear formularios de búsqueda y otros tipos de formularios genéricos que no representan ningún modelo específico en tu aplicación.
* Cómo crear formularios centrados en modelos para crear y editar registros específicos de la base de datos.
* Cómo generar cuadros de selección a partir de varios tipos de datos.
* Qué ayudantes de fecha y hora proporciona Rails.
* Qué hace que un formulario de carga de archivos sea diferente.
* Cómo enviar formularios a recursos externos y especificar la configuración de un `authenticity_token`.
* Cómo construir formularios complejos.

--------------------------------------------------------------------------------

NOTA: Esta guía no pretende ser una documentación completa de los ayudantes de formularios disponibles y sus argumentos. Por favor, visita [la documentación de la API de Rails](https://api.rubyonrails.org/classes/ActionView/Helpers.html) para obtener una referencia completa de todos los ayudantes disponibles.

Trabajando con Formularios Básicos
---------------------------------

El principal ayudante de formularios es [`form_with`](https://api.rubyonrails.org/classes/ActionView/Helpers/FormHelper.html#method-i-form_with).

```erb
<%= form_with do |form| %>
  Contenido del formulario
<% end %>
```

Cuando se llama sin argumentos de esta manera, crea una etiqueta de formulario que, al enviarse, realizará una solicitud POST a la página actual. Por ejemplo, suponiendo que la página actual es una página de inicio, el HTML generado se verá así:

```html
<form accept-charset="UTF-8" action="/" method="post">
  <input name="authenticity_token" type="hidden" value="J7CBxfHalt49OSHp27hblqK20c9PgwJ108nDHX/8Cts=" />
  Contenido del formulario
</form>
```

Observarás que el HTML contiene un elemento `input` con el tipo `hidden`. Este `input` es importante, porque los formularios que no son GET no se pueden enviar correctamente sin él. El elemento `input` oculto con el nombre `authenticity_token` es una característica de seguridad de Rails llamada **protección contra falsificación de solicitudes entre sitios**, y los ayudantes de formularios lo generan para cada formulario que no es GET (siempre que esta característica de seguridad esté habilitada). Puedes obtener más información al respecto en la guía [Securing Rails Applications](security.html#cross-site-request-forgery-csrf) (en inglés).

### Un Formulario de Búsqueda Genérico

Uno de los formularios más básicos que se ven en la web es un formulario de búsqueda. Este formulario contiene:

* un elemento de formulario con método "GET",
* una etiqueta para la entrada,
* un elemento de entrada de texto, y
* un elemento de envío.

Para crear este formulario, utilizarás `form_with` y el objeto constructor de formularios que genera. De esta manera:

```erb
<%= form_with url: "/search", method: :get do |form| %>
  <%= form.label :query, "Buscar:" %>
  <%= form.text_field :query %>
  <%= form.submit "Buscar" %>
<% end %>
```

Esto generará el siguiente HTML:

```html
<form action="/search" method="get" accept-charset="UTF-8" >
  <label for="query">Buscar:</label>
  <input id="query" name="query" type="text" />
  <input name="commit" type="submit" value="Buscar" data-disable-with="Buscar" />
</form>
```

CONSEJO: Pasar `url: my_specified_path` a `form_with` indica al formulario dónde realizar la solicitud. Sin embargo, como se explica a continuación, también puedes pasar objetos Active Record al formulario.

CONSEJO: Para cada entrada de formulario, se genera un atributo ID a partir de su nombre (`"query"` en el ejemplo anterior). Estos ID pueden ser muy útiles para aplicar estilos CSS o manipular los controles del formulario con JavaScript.

IMPORTANTE: Utiliza "GET" como método para los formularios de búsqueda. Esto permite a los usuarios marcar una búsqueda específica y volver a ella. En general, Rails te anima a utilizar el verbo HTTP correcto para una acción.

### Ayudantes para Generar Elementos de Formulario

El objeto constructor de formularios generado por `form_with` proporciona numerosos métodos de ayuda para generar elementos de formulario como campos de texto, casillas de verificación y botones de radio. El primer parámetro de estos métodos siempre es el nombre de la entrada. Cuando se envía el formulario, el nombre se enviará junto con los datos del formulario y llegará a `params` en el controlador con el valor ingresado por el usuario para ese campo. Por ejemplo, si el formulario contiene `<%= form.text_field :query %>`, entonces podrías obtener el valor de este campo en el controlador con `params[:query]`.

Cuando se nombran las entradas, Rails utiliza ciertas convenciones que permiten enviar parámetros con valores no escalares, como matrices o hashes, que también serán accesibles en `params`. Puedes obtener más información al respecto en la sección [Understanding Parameter Naming Conventions](#understanding-parameter-naming-conventions) de esta guía. Para obtener detalles sobre el uso preciso de estos ayudantes, consulta la [documentación de la API](https://api.rubyonrails.org/classes/ActionView/Helpers/FormTagHelper.html).
#### Casillas de verificación

Las casillas de verificación son controles de formulario que permiten al usuario seleccionar o deseleccionar un conjunto de opciones:

```erb
<%= form.check_box :pet_dog %>
<%= form.label :pet_dog, "Tengo un perro" %>
<%= form.check_box :pet_cat %>
<%= form.label :pet_cat, "Tengo un gato" %>
```

Esto genera lo siguiente:

```html
<input type="checkbox" id="pet_dog" name="pet_dog" value="1" />
<label for="pet_dog">Tengo un perro</label>
<input type="checkbox" id="pet_cat" name="pet_cat" value="1" />
<label for="pet_cat">Tengo un gato</label>
```

El primer parámetro de [`check_box`](https://api.rubyonrails.org/classes/ActionView/Helpers/FormBuilder.html#method-i-check_box) es el nombre del campo de entrada. Los valores de las casillas de verificación (los valores que aparecerán en `params`) se pueden especificar opcionalmente utilizando los terceros y cuartos parámetros. Consulta la documentación de la API para obtener más detalles.

#### Botones de opción

Los botones de opción, aunque similares a las casillas de verificación, son controles que especifican un conjunto de opciones en las que son mutuamente excluyentes (es decir, el usuario solo puede seleccionar una):

```erb
<%= form.radio_button :age, "child" %>
<%= form.label :age_child, "Soy menor de 21 años" %>
<%= form.radio_button :age, "adult" %>
<%= form.label :age_adult, "Soy mayor de 21 años" %>
```

Salida:

```html
<input type="radio" id="age_child" name="age" value="child" />
<label for="age_child">Soy menor de 21 años</label>
<input type="radio" id="age_adult" name="age" value="adult" />
<label for="age_adult">Soy mayor de 21 años</label>
```

El segundo parámetro de [`radio_button`](https://api.rubyonrails.org/classes/ActionView/Helpers/FormBuilder.html#method-i-radio_button) es el valor del campo de entrada. Debido a que estos dos botones de opción comparten el mismo nombre (`age`), el usuario solo podrá seleccionar uno de ellos, y `params[:age]` contendrá `"child"` o `"adult"`.

NOTA: Siempre utiliza etiquetas para las casillas de verificación y los botones de opción. Asocian texto con una opción específica y, al expandir la región clickeable, facilitan que los usuarios hagan clic en los campos de entrada.

### Otros ayudantes de interés

Otros controles de formulario que vale la pena mencionar son las áreas de texto, los campos ocultos, los campos de contraseña, los campos numéricos, los campos de fecha y hora, y muchos más:

```erb
<%= form.text_area :message, size: "70x5" %>
<%= form.hidden_field :parent_id, value: "foo" %>
<%= form.password_field :password %>
<%= form.number_field :price, in: 1.0..20.0, step: 0.5 %>
<%= form.range_field :discount, in: 1..100 %>
<%= form.date_field :born_on %>
<%= form.time_field :started_at %>
<%= form.datetime_local_field :graduation_day %>
<%= form.month_field :birthday_month %>
<%= form.week_field :birthday_week %>
<%= form.search_field :name %>
<%= form.email_field :address %>
<%= form.telephone_field :phone %>
<%= form.url_field :homepage %>
<%= form.color_field :favorite_color %>
```

Salida:

```html
<textarea name="message" id="message" cols="70" rows="5"></textarea>
<input type="hidden" name="parent_id" id="parent_id" value="foo" />
<input type="password" name="password" id="password" />
<input type="number" name="price" id="price" step="0.5" min="1.0" max="20.0" />
<input type="range" name="discount" id="discount" min="1" max="100" />
<input type="date" name="born_on" id="born_on" />
<input type="time" name="started_at" id="started_at" />
<input type="datetime-local" name="graduation_day" id="graduation_day" />
<input type="month" name="birthday_month" id="birthday_month" />
<input type="week" name="birthday_week" id="birthday_week" />
<input type="search" name="name" id="name" />
<input type="email" name="address" id="address" />
<input type="tel" name="phone" id="phone" />
<input type="url" name="homepage" id="homepage" />
<input type="color" name="favorite_color" id="favorite_color" value="#000000" />
```

Los campos ocultos no se muestran al usuario, sino que almacenan datos como cualquier campo de texto. Los valores dentro de ellos se pueden cambiar con JavaScript.

IMPORTANTE: Los campos de búsqueda, teléfono, fecha, hora, color, fecha y hora, mes, semana, URL, correo electrónico, número y rango son controles HTML5. Si deseas que tu aplicación tenga una experiencia consistente en navegadores antiguos, necesitarás un polyfill de HTML5 (proporcionado por CSS y/o JavaScript). Definitivamente [no hay escasez de soluciones para esto](https://github.com/Modernizr/Modernizr/wiki/HTML5-Cross-Browser-Polyfills), aunque una herramienta popular en este momento es [Modernizr](https://modernizr.com/), que proporciona una forma sencilla de agregar funcionalidad en función de la presencia de características HTML5 detectadas.

CONSEJO: Si estás utilizando campos de entrada de contraseña (para cualquier propósito), es posible que desees configurar tu aplicación para evitar que esos parámetros se registren. Puedes obtener más información al respecto en la guía [Securing Rails Applications](security.html#logging).

Trabajando con objetos de modelo
-------------------------------

### Vinculando un formulario a un objeto

El argumento `:model` de `form_with` nos permite vincular el objeto del generador de formularios a un objeto de modelo. Esto significa que el formulario estará enfocado en ese objeto de modelo y los campos del formulario se llenarán con los valores de ese objeto de modelo.

Por ejemplo, si tenemos un objeto de modelo `@article` como:

```ruby
@article = Article.find(42)
# => #<Article id: 42, title: "Mi título", body: "Mi cuerpo">
```

El siguiente formulario:

```erb
<%= form_with model: @article do |form| %>
  <%= form.text_field :title %>
  <%= form.text_area :body, size: "60x10" %>
  <%= form.submit %>
<% end %>
```

Genera:

```html
<form action="/articles/42" method="post" accept-charset="UTF-8" >
  <input name="authenticity_token" type="hidden" value="..." />
  <input type="text" name="article[title]" id="article_title" value="Mi título" />
  <textarea name="article[body]" id="article_body" cols="60" rows="10">
    Mi cuerpo
  </textarea>
  <input type="submit" name="commit" value="Actualizar artículo" data-disable-with="Actualizar artículo">
</form>
```
Aquí hay varias cosas a tener en cuenta:

* El atributo `action` del formulario se completa automáticamente con un valor apropiado para `@article`.
* Los campos del formulario se completan automáticamente con los valores correspondientes de `@article`.
* Los nombres de los campos del formulario están delimitados con `article[...]`. Esto significa que `params[:article]` será un hash que contiene los valores de todos estos campos. Puedes obtener más información sobre la importancia de los nombres de entrada en el capítulo [Understanding Parameter Naming Conventions](#understanding-parameter-naming-conventions) de esta guía.
* El botón de envío se le asigna automáticamente un texto apropiado.

CONSEJO: Convencionalmente, tus entradas reflejarán los atributos del modelo. Sin embargo, ¡no tienen que hacerlo! Si necesitas otra información, puedes incluirla en tu formulario de la misma manera que con los atributos y acceder a ella a través de `params[:article][:my_nifty_non_attribute_input]`.

#### El ayudante `fields_for`

El ayudante [`fields_for`][] crea un enlace similar pero sin renderizar una etiqueta `<form>`. Esto se puede utilizar para renderizar campos para objetos de modelo adicionales dentro del mismo formulario. Por ejemplo, si tienes un modelo `Person` con un modelo asociado `ContactDetail`, puedes crear un solo formulario para ambos de la siguiente manera:

```erb
<%= form_with model: @person do |person_form| %>
  <%= person_form.text_field :name %>
  <%= fields_for :contact_detail, @person.contact_detail do |contact_detail_form| %>
    <%= contact_detail_form.text_field :phone_number %>
  <% end %>
<% end %>
```

Lo cual produce la siguiente salida:

```html
<form action="/people" accept-charset="UTF-8" method="post">
  <input type="hidden" name="authenticity_token" value="bL13x72pldyDD8bgtkjKQakJCpd4A8JdXGbfksxBDHdf1uC0kCMqe2tvVdUYfidJt0fj3ihC4NxiVHv8GVYxJA==" />
  <input type="text" name="person[name]" id="person_name" />
  <input type="text" name="contact_detail[phone_number]" id="contact_detail_phone_number" />
</form>
```

El objeto devuelto por `fields_for` es un constructor de formularios similar al devuelto por `form_with`.


### Dependiendo de la identificación del registro

El modelo Article está directamente disponible para los usuarios de la aplicación, por lo que, siguiendo las mejores prácticas para desarrollar con Rails, deberías declararlo **un recurso**:

```ruby
resources :articles
```

CONSEJO: Declarar un recurso tiene varios efectos secundarios. Consulta la guía [Rails Routing from the Outside In](routing.html#resource-routing-the-rails-default) para obtener más información sobre cómo configurar y utilizar recursos.

Cuando se trata de recursos RESTful, las llamadas a `form_with` pueden ser mucho más fáciles si te basas en la **identificación del registro**. En resumen, puedes pasar la instancia del modelo y Rails se encargará de determinar el nombre del modelo y el resto. En ambos ejemplos, el estilo largo y el estilo corto tienen el mismo resultado:

```ruby
## Crear un nuevo artículo
# estilo largo:
form_with(model: @article, url: articles_path)
# estilo corto:
form_with(model: @article)

## Editar un artículo existente
# estilo largo:
form_with(model: @article, url: article_path(@article), method: "patch")
# estilo corto:
form_with(model: @article)
```

Observa cómo la invocación de `form_with` en estilo corto es conveniente y es la misma, independientemente de si el registro es nuevo o existente. La identificación del registro es lo suficientemente inteligente como para determinar si el registro es nuevo preguntando `record.persisted?`. También selecciona la ruta correcta para enviar los datos y el nombre basado en la clase del objeto.

Si tienes un [recurso singular](routing.html#singular-resources), deberás llamar a `resource` y `resolve` para que funcione con `form_with`:

```ruby
resource :geocoder
resolve('Geocoder') { [:geocoder] }
```

ADVERTENCIA: Cuando estás utilizando STI (herencia de tabla única) con tus modelos, no puedes depender de la identificación del registro en una subclase si solo su clase principal está declarada como recurso. Deberás especificar `:url` y `:scope` (el nombre del modelo) explícitamente.

#### Tratando con espacios de nombres

Si has creado rutas con espacios de nombres, `form_with` también tiene una forma abreviada para eso. Si tu aplicación tiene un espacio de nombres de administrador, entonces

```ruby
form_with model: [:admin, @article]
```

creará un formulario que envía los datos al `ArticlesController` dentro del espacio de nombres de administrador (enviando a `admin_article_path(@article)` en caso de una actualización). Si tienes varios niveles de espacios de nombres, la sintaxis es similar:

```ruby
form_with model: [:admin, :management, @article]
```

Para obtener más información sobre el sistema de enrutamiento de Rails y las convenciones asociadas, consulta la guía [Rails Routing from the Outside In](routing.html).

### ¿Cómo funcionan los formularios con los métodos PATCH, PUT o DELETE?

El framework de Rails fomenta el diseño RESTful de tus aplicaciones, lo que significa que realizarás muchas solicitudes "PATCH", "PUT" y "DELETE" (además de "GET" y "POST"). Sin embargo, la mayoría de los navegadores _no admiten_ métodos distintos de "GET" y "POST" al enviar formularios.

Rails soluciona este problema emulando otros métodos a través de POST con un campo oculto llamado `"_method"`, que se establece para reflejar el método deseado:

```ruby
form_with(url: search_path, method: "patch")
```

Salida:

```html
<form accept-charset="UTF-8" action="/search" method="post">
  <input name="_method" type="hidden" value="patch" />
  <input name="authenticity_token" type="hidden" value="f755bb0ed134b76c432144748a6d4b7a7ddf2b71" />
  <!-- ... -->
</form>
```
Al analizar los datos enviados mediante POST, Rails tendrá en cuenta el parámetro especial `_method` y actuará como si el método HTTP fuera el especificado en él ("PATCH" en este ejemplo).

Al renderizar un formulario, los botones de envío pueden anular el atributo `method` declarado a través de la palabra clave `formmethod:`:

```erb
<%= form_with url: "/posts/1", method: :patch do |form| %>
  <%= form.button "Eliminar", formmethod: :delete, data: { confirm: "¿Estás seguro?" } %>
  <%= form.button "Actualizar" %>
<% end %>
```

Similar a los elementos `<form>`, la mayoría de los navegadores _no admiten_ la anulación de los métodos de formulario declarados a través de [formmethod][] que no sean "GET" y "POST".

Rails soluciona este problema emulando otros métodos sobre POST mediante una combinación de [formmethod][], [value][button-value] y [name][button-name]:

```html
<form accept-charset="UTF-8" action="/posts/1" method="post">
  <input name="_method" type="hidden" value="patch" />
  <input name="authenticity_token" type="hidden" value="f755bb0ed134b76c432144748a6d4b7a7ddf2b71" />
  <!-- ... -->

  <button type="submit" formmethod="post" name="_method" value="delete" data-confirm="¿Estás seguro?">Eliminar</button>
  <button type="submit" name="button">Actualizar</button>
</form>
```


Crear cuadros de selección fácilmente
-------------------------------------

Los cuadros de selección en HTML requieren una cantidad significativa de marcado, un elemento `<option>` por cada opción para elegir. Por lo tanto, Rails proporciona métodos auxiliares para reducir esta carga.

Por ejemplo, supongamos que tenemos una lista de ciudades para que el usuario elija. Podemos usar el ayudante [`select`](https://api.rubyonrails.org/classes/ActionView/Helpers/FormBuilder.html#method-i-select) de la siguiente manera:

```erb
<%= form.select :city, ["Berlín", "Chicago", "Madrid"] %>
```

Salida:

```html
<select name="city" id="city">
  <option value="Berlín">Berlín</option>
  <option value="Chicago">Chicago</option>
  <option value="Madrid">Madrid</option>
</select>
```

También podemos designar valores `<option>` que difieren de sus etiquetas:

```erb
<%= form.select :city, [["Berlín", "BE"], ["Chicago", "CHI"], ["Madrid", "MD"]] %>
```

Salida:

```html
<select name="city" id="city">
  <option value="BE">Berlín</option>
  <option value="CHI">Chicago</option>
  <option value="MD">Madrid</option>
</select>
```

De esta manera, el usuario verá el nombre completo de la ciudad, pero `params[:city]` será uno de `"BE"`, `"CHI"` o `"MD"`.

Por último, podemos especificar una opción predeterminada para el cuadro de selección con el argumento `:selected`:

```erb
<%= form.select :city, [["Berlín", "BE"], ["Chicago", "CHI"], ["Madrid", "MD"]], selected: "CHI" %>
```

Salida:

```html
<select name="city" id="city">
  <option value="BE">Berlín</option>
  <option value="CHI" selected="selected">Chicago</option>
  <option value="MD">Madrid</option>
</select>
```

### Grupos de opciones

En algunos casos, es posible que deseemos mejorar la experiencia del usuario agrupando opciones relacionadas. Podemos hacerlo pasando un `Hash` (o un `Array` comparable) a `select`:

```erb
<%= form.select :city,
      {
        "Europa" => [ ["Berlín", "BE"], ["Madrid", "MD"] ],
        "América del Norte" => [ ["Chicago", "CHI"] ],
      },
      selected: "CHI" %>
```

Salida:

```html
<select name="city" id="city">
  <optgroup label="Europa">
    <option value="BE">Berlín</option>
    <option value="MD">Madrid</option>
  </optgroup>
  <optgroup label="América del Norte">
    <option value="CHI" selected="selected">Chicago</option>
  </optgroup>
</select>
```

### Cuadros de selección y objetos de modelo

Al igual que otros controles de formulario, un cuadro de selección puede estar vinculado a un atributo del modelo. Por ejemplo, si tenemos un objeto de modelo `@person` como:

```ruby
@person = Person.new(city: "MD")
```

El siguiente formulario:

```erb
<%= form_with model: @person do |form| %>
  <%= form.select :city, [["Berlín", "BE"], ["Chicago", "CHI"], ["Madrid", "MD"]] %>
<% end %>
```

Genera un cuadro de selección como:

```html
<select name="person[city]" id="person_city">
  <option value="BE">Berlín</option>
  <option value="CHI">Chicago</option>
  <option value="MD" selected="selected">Madrid</option>
</select>
```

Observa que la opción adecuada se marcó automáticamente como `selected="selected"`. ¡Dado que este cuadro de selección estaba vinculado a un modelo, no fue necesario especificar un argumento `:selected`!

### Selección de zona horaria y país

Para aprovechar el soporte de zona horaria en Rails, debes preguntar a tus usuarios en qué zona horaria se encuentran. Hacerlo requeriría generar opciones de selección a partir de una lista de objetos predefinidos [`ActiveSupport::TimeZone`](https://api.rubyonrails.org/classes/ActiveSupport/TimeZone.html), pero puedes usar simplemente el ayudante [`time_zone_select`](https://api.rubyonrails.org/classes/ActionView/Helpers/FormBuilder.html#method-i-time_zone_select) que ya lo envuelve:

```erb
<%= form.time_zone_select :time_zone %>
```

Rails _solía tener_ un ayudante `country_select` para elegir países, pero esto se ha extraído al [complemento country_select](https://github.com/stefanpenner/country_select).

Uso de ayudantes de formulario de fecha y hora
--------------------------------------------

Si no deseas utilizar las entradas de fecha y hora de HTML5, Rails proporciona ayudantes de formulario alternativos para fecha y hora que generan cuadros de selección simples. Estos ayudantes generan un cuadro de selección para cada componente temporal (por ejemplo, año, mes, día, etc.). Por ejemplo, si tenemos un objeto de modelo `@person` como:

```ruby
@person = Person.new(birth_date: Date.new(1995, 12, 21))
```

El siguiente formulario:

```erb
<%= form_with model: @person do |form| %>
  <%= form.date_select :birth_date %>
<% end %>
```

Genera cuadros de selección como:

```html
<select name="person[birth_date(1i)]" id="person_birth_date_1i">
  <option value="1990">1990</option>
  <option value="1991">1991</option>
  <option value="1992">1992</option>
  <option value="1993">1993</option>
  <option value="1994">1994</option>
  <option value="1995" selected="selected">1995</option>
  <option value="1996">1996</option>
  <option value="1997">1997</option>
  <option value="1998">1998</option>
  <option value="1999">1999</option>
  <option value="2000">2000</option>
</select>
<select name="person[birth_date(2i)]" id="person_birth_date_2i">
  <option value="1">enero</option>
  <option value="2">febrero</option>
  <option value="3">marzo</option>
  <option value="4">abril</option>
  <option value="5">mayo</option>
  <option value="6">junio</option>
  <option value="7">julio</option>
  <option value="8">agosto</option>
  <option value="9">septiembre</option>
  <option value="10">octubre</option>
  <option value="11">noviembre</option>
  <option value="12" selected="selected">diciembre</option>
</select>
<select name="person[birth_date(3i)]" id="person_birth_date_3i">
  <option value="1">1</option>
  ...
  <option value="21" selected="selected">21</option>
  ...
  <option value="31">31</option>
</select>
```
Ten en cuenta que, cuando se envía el formulario, no habrá un solo valor en el hash `params` que contenga la fecha completa. En su lugar, habrá varios valores con nombres especiales como `"birth_date(1i)"`. Active Record sabe cómo ensamblar estos valores con nombres especiales en una fecha o hora completa, según el tipo declarado del atributo del modelo. Por lo tanto, podemos pasar `params[:person]` a `Person.new` o `Person#update` como lo haríamos si el formulario usara un solo campo para representar la fecha completa.

Además del ayudante [`date_select`](https://api.rubyonrails.org/classes/ActionView/Helpers/FormBuilder.html#method-i-date_select), Rails proporciona [`time_select`](https://api.rubyonrails.org/classes/ActionView/Helpers/FormBuilder.html#method-i-time_select) y [`datetime_select`](https://api.rubyonrails.org/classes/ActionView/Helpers/FormBuilder.html#method-i-datetime_select).

### Cuadros de selección para componentes temporales individuales

Rails también proporciona ayudantes para renderizar cuadros de selección para componentes temporales individuales: [`select_year`](https://api.rubyonrails.org/classes/ActionView/Helpers/DateHelper.html#method-i-select_year), [`select_month`](https://api.rubyonrails.org/classes/ActionView/Helpers/DateHelper.html#method-i-select_month), [`select_day`](https://api.rubyonrails.org/classes/ActionView/Helpers/DateHelper.html#method-i-select_day), [`select_hour`](https://api.rubyonrails.org/classes/ActionView/Helpers/DateHelper.html#method-i-select_hour), [`select_minute`](https://api.rubyonrails.org/classes/ActionView/Helpers/DateHelper.html#method-i-select_minute) y [`select_second`](https://api.rubyonrails.org/classes/ActionView/Helpers/DateHelper.html#method-i-select_second). Estos ayudantes son métodos "desnudos", lo que significa que no se llaman en una instancia de constructor de formularios. Por ejemplo:

```erb
<%= select_year 1999, prefix: "party" %>
```

Genera un cuadro de selección como:

```html
<select name="party[year]" id="party_year">
  <option value="1994">1994</option>
  <option value="1995">1995</option>
  <option value="1996">1996</option>
  <option value="1997">1997</option>
  <option value="1998">1998</option>
  <option value="1999" selected="selected">1999</option>
  <option value="2000">2000</option>
  <option value="2001">2001</option>
  <option value="2002">2002</option>
  <option value="2003">2003</option>
  <option value="2004">2004</option>
</select>
```

Para cada uno de estos ayudantes, puedes especificar un objeto de fecha o hora en lugar de un número como valor predeterminado, y se extraerá y utilizará el componente temporal correspondiente.

Elecciones de una colección de objetos arbitrarios
--------------------------------------------------

A veces, queremos generar un conjunto de opciones a partir de una colección de objetos arbitrarios. Por ejemplo, si tenemos un modelo `City` y una asociación correspondiente `belongs_to :city`:

```ruby
class City < ApplicationRecord
end

class Person < ApplicationRecord
  belongs_to :city
end
```

```ruby
City.order(:name).map { |city| [city.name, city.id] }
# => [["Berlin", 3], ["Chicago", 1], ["Madrid", 2]]
```

Entonces podemos permitir al usuario elegir una ciudad de la base de datos con el siguiente formulario:

```erb
<%= form_with model: @person do |form| %>
  <%= form.select :city_id, City.order(:name).map { |city| [city.name, city.id] } %>
<% end %>
```

NOTA: Al renderizar un campo para una asociación `belongs_to`, debes especificar el nombre de la clave externa (`city_id` en el ejemplo anterior), en lugar del nombre de la asociación en sí.

Sin embargo, Rails proporciona ayudantes que generan opciones a partir de una colección sin tener que iterar explícitamente sobre ella. Estos ayudantes determinan el valor y la etiqueta de texto de cada opción llamando a métodos especificados en cada objeto de la colección.

### El ayudante `collection_select`

Para generar un cuadro de selección, podemos usar [`collection_select`](https://api.rubyonrails.org/classes/ActionView/Helpers/FormBuilder.html#method-i-collection_select):

```erb
<%= form.collection_select :city_id, City.order(:name), :id, :name %>
```

Salida:

```html
<select name="person[city_id]" id="person_city_id">
  <option value="3">Berlin</option>
  <option value="1">Chicago</option>
  <option value="2">Madrid</option>
</select>
```

NOTA: Con `collection_select` especificamos primero el método de valor (`:id` en el ejemplo anterior) y luego el método de etiqueta de texto (`:name` en el ejemplo anterior). Esto es contrario al orden utilizado al especificar opciones para el ayudante `select`, donde la etiqueta de texto viene primero y el valor segundo.

### El ayudante `collection_radio_buttons`

Para generar un conjunto de botones de radio, podemos usar [`collection_radio_buttons`](https://api.rubyonrails.org/classes/ActionView/Helpers/FormBuilder.html#method-i-collection_radio_buttons):

```erb
<%= form.collection_radio_buttons :city_id, City.order(:name), :id, :name %>
```

Salida:

```html
<input type="radio" name="person[city_id]" value="3" id="person_city_id_3">
<label for="person_city_id_3">Berlin</label>

<input type="radio" name="person[city_id]" value="1" id="person_city_id_1">
<label for="person_city_id_1">Chicago</label>

<input type="radio" name="person[city_id]" value="2" id="person_city_id_2">
<label for="person_city_id_2">Madrid</label>
```

### El ayudante `collection_check_boxes`

Para generar un conjunto de casillas de verificación, por ejemplo, para admitir una asociación `has_and_belongs_to_many`, podemos usar [`collection_check_boxes`](https://api.rubyonrails.org/classes/ActionView/Helpers/FormBuilder.html#method-i-collection_check_boxes):

```erb
<%= form.collection_check_boxes :interest_ids, Interest.order(:name), :id, :name %>
```

Salida:

```html
<input type="checkbox" name="person[interest_id][]" value="3" id="person_interest_id_3">
<label for="person_interest_id_3">Engineering</label>

<input type="checkbox" name="person[interest_id][]" value="4" id="person_interest_id_4">
<label for="person_interest_id_4">Math</label>

<input type="checkbox" name="person[interest_id][]" value="1" id="person_interest_id_1">
<label for="person_interest_id_1">Science</label>

<input type="checkbox" name="person[interest_id][]" value="2" id="person_interest_id_2">
<label for="person_interest_id_2">Technology</label>
```

Carga de archivos
-----------------

Una tarea común es cargar algún tipo de archivo, ya sea una imagen de una persona o un archivo CSV que contiene datos para procesar. Los campos de carga de archivos se pueden renderizar con el ayudante [`file_field`](https://api.rubyonrails.org/classes/ActionView/Helpers/FormBuilder.html#method-i-file_field).

```erb
<%= form_with model: @person do |form| %>
  <%= form.file_field :picture %>
<% end %>
```

Lo más importante a recordar con las cargas de archivos es que el atributo `enctype` del formulario renderizado **debe** establecerse en "multipart/form-data". Esto se hace automáticamente si usas un `file_field` dentro de un `form_with`. También puedes establecer el atributo manualmente:

```erb
<%= form_with url: "/uploads", multipart: true do |form| %>
  <%= file_field_tag :picture %>
<% end %>
```

Ten en cuenta que, de acuerdo con las convenciones de `form_with`, los nombres de los campos en los dos formularios anteriores también serán diferentes. Es decir, el nombre del campo en el primer formulario será `person[picture]` (accesible a través de `params[:person][:picture]`), y el nombre del campo en el segundo formulario será simplemente `picture` (accesible a través de `params[:picture]`).
### Qué se carga

El objeto en el hash `params` es una instancia de [`ActionDispatch::Http::UploadedFile`](https://api.rubyonrails.org/classes/ActionDispatch/Http/UploadedFile.html). El siguiente fragmento guarda el archivo cargado en `#{Rails.root}/public/uploads` con el mismo nombre que el archivo original.

```ruby
def upload
  uploaded_file = params[:picture]
  File.open(Rails.root.join('public', 'uploads', uploaded_file.original_filename), 'wb') do |file|
    file.write(uploaded_file.read)
  end
end
```

Una vez que se ha cargado un archivo, hay una multitud de tareas potenciales, que van desde dónde almacenar los archivos (en disco, Amazon S3, etc.), asociarlos con modelos, redimensionar archivos de imagen y generar miniaturas, etc. [Active Storage](active_storage_overview.html) está diseñado para ayudar con estas tareas.

Personalización de los constructores de formularios
---------------------------------------------------

El objeto devuelto por `form_with` y `fields_for` es una instancia de [`ActionView::Helpers::FormBuilder`](https://api.rubyonrails.org/classes/ActionView/Helpers/FormBuilder.html). Los constructores de formularios encapsulan la noción de mostrar elementos de formulario para un solo objeto. Si bien puedes escribir helpers para tus formularios de la manera habitual, también puedes crear una subclase de `ActionView::Helpers::FormBuilder` y agregar los helpers allí. Por ejemplo,

```erb
<%= form_with model: @person do |form| %>
  <%= text_field_with_label form, :first_name %>
<% end %>
```

se puede reemplazar por

```erb
<%= form_with model: @person, builder: LabellingFormBuilder do |form| %>
  <%= form.text_field :first_name %>
<% end %>
```

definiendo una clase `LabellingFormBuilder` similar a la siguiente:

```ruby
class LabellingFormBuilder < ActionView::Helpers::FormBuilder
  def text_field(attribute, options = {})
    label(attribute) + super
  end
end
```

Si reutilizas esto con frecuencia, puedes definir un helper `labeled_form_with` que aplique automáticamente la opción `builder: LabellingFormBuilder`:

```ruby
def labeled_form_with(model: nil, scope: nil, url: nil, format: nil, **options, &block)
  options[:builder] = LabellingFormBuilder
  form_with model: model, scope: scope, url: url, format: format, **options, &block
end
```

El constructor de formularios utilizado también determina qué sucede cuando haces:

```erb
<%= render partial: f %>
```

Si `f` es una instancia de `ActionView::Helpers::FormBuilder`, esto renderizará el partial `form`, estableciendo el objeto del partial en el constructor de formularios. Si el constructor de formularios es de la clase `LabellingFormBuilder`, entonces se renderizará el partial `labelling_form` en su lugar.

Entendiendo las convenciones de nomenclatura de parámetros
---------------------------------------------------------

Los valores de los formularios pueden estar en el nivel superior del hash `params` o anidados en otro hash. Por ejemplo, en una acción `create` estándar para un modelo Person, `params[:person]` generalmente sería un hash de todos los atributos de la persona a crear. El hash `params` también puede contener arrays, arrays de hashes, y así sucesivamente.

Fundamentalmente, los formularios HTML no conocen ningún tipo de datos estructurados, todo lo que generan son pares de nombre-valor, donde los pares son simplemente cadenas simples. Los arrays y hashes que ves en tu aplicación son el resultado de algunas convenciones de nomenclatura de parámetros que Rails utiliza.

### Estructuras básicas

Las dos estructuras básicas son arrays y hashes. Los hashes reflejan la sintaxis utilizada para acceder al valor en `params`. Por ejemplo, si un formulario contiene:

```html
<input id="person_name" name="person[name]" type="text" value="Henry"/>
```

el hash `params` contendrá

```ruby
{ 'person' => { 'name' => 'Henry' } }
```

y `params[:person][:name]` recuperará el valor enviado en el controlador.

Los hashes pueden estar anidados tantos niveles como se requiera, por ejemplo:

```html
<input id="person_address_city" name="person[address][city]" type="text" value="New York"/>
```

resultará en el hash `params` siendo

```ruby
{ 'person' => { 'address' => { 'city' => 'New York' } } }
```

Normalmente, Rails ignora los nombres de parámetros duplicados. Si el nombre del parámetro termina con un conjunto vacío de corchetes `[]`, se acumularán en un array. Si deseas que los usuarios puedan ingresar múltiples números de teléfono, puedes colocar esto en el formulario:

```html
<input name="person[phone_number][]" type="text"/>
<input name="person[phone_number][]" type="text"/>
<input name="person[phone_number][]" type="text"/>
```

Esto hará que `params[:person][:phone_number]` sea un array que contiene los números de teléfono ingresados.

### Combinándolos

Podemos mezclar y combinar estos dos conceptos. Un elemento de un hash puede ser un array como en el ejemplo anterior, o puedes tener un array de hashes. Por ejemplo, un formulario podría permitirte crear cualquier número de direcciones repitiendo el siguiente fragmento de formulario:

```html
<input name="person[addresses][][line1]" type="text"/>
<input name="person[addresses][][line2]" type="text"/>
<input name="person[addresses][][city]" type="text"/>
<input name="person[addresses][][line1]" type="text"/>
<input name="person[addresses][][line2]" type="text"/>
<input name="person[addresses][][city]" type="text"/>
```

Esto hará que `params[:person][:addresses]` sea un array de hashes con claves `line1`, `line2` y `city`.

Sin embargo, hay una restricción: aunque los hashes pueden estar anidados arbitrariamente, solo se permite un nivel de "arrayness". Los arrays generalmente se pueden reemplazar por hashes; por ejemplo, en lugar de tener un array de objetos de modelo, se puede tener un hash de objetos de modelo indexados por su id, un índice de array u otro parámetro.
ADVERTENCIA: Los parámetros de matriz no funcionan bien con el ayudante `check_box`. Según la especificación HTML, las casillas de verificación no marcadas no envían ningún valor. Sin embargo, a menudo es conveniente que una casilla de verificación siempre envíe un valor. El ayudante `check_box` simula esto creando una entrada oculta auxiliar con el mismo nombre. Si la casilla de verificación no está marcada, solo se envía la entrada oculta y si está marcada, se envían ambas, pero el valor enviado por la casilla de verificación tiene prioridad.

### La opción `:index` del ayudante `fields_for`

Digamos que queremos renderizar un formulario con un conjunto de campos para cada una de las direcciones de una persona. El ayudante [`fields_for`][] con su opción `:index` puede ayudar:

```erb
<%= form_with model: @person do |person_form| %>
  <%= person_form.text_field :name %>
  <% @person.addresses.each do |address| %>
    <%= person_form.fields_for address, index: address.id do |address_form| %>
      <%= address_form.text_field :city %>
    <% end %>
  <% end %>
<% end %>
```

Suponiendo que la persona tiene dos direcciones con los IDs 23 y 45, el formulario anterior renderizaría una salida similar a:

```html
<form accept-charset="UTF-8" action="/people/1" method="post">
  <input name="_method" type="hidden" value="patch" />
  <input id="person_name" name="person[name]" type="text" />
  <input id="person_address_23_city" name="person[address][23][city]" type="text" />
  <input id="person_address_45_city" name="person[address][45][city]" type="text" />
</form>
```

Lo cual resultará en un hash `params` que se ve así:

```ruby
{
  "person" => {
    "name" => "Bob",
    "address" => {
      "23" => {
        "city" => "Paris"
      },
      "45" => {
        "city" => "London"
      }
    }
  }
}
```

Todos los campos de entrada del formulario se asignan al hash `"person"` porque llamamos a `fields_for` en el constructor de formularios `person_form`. Además, al especificar `index: address.id`, renderizamos el atributo `name` de cada campo de ciudad como `person[address][#{address.id}][city]` en lugar de `person[address][city]`. De esta manera, podemos determinar qué registros de dirección deben modificarse al procesar el hash `params`.

Puede pasar otros números o cadenas de importancia a través de la opción `:index`. Incluso puede pasar `nil`, lo que producirá un parámetro de matriz.

Para crear anidaciones más complejas, puede especificar la parte inicial del nombre de entrada explícitamente. Por ejemplo:

```erb
<%= fields_for 'person[address][primary]', address, index: address.id do |address_form| %>
  <%= address_form.text_field :city %>
<% end %>
```

creará campos de entrada como:

```html
<input id="person_address_primary_23_city" name="person[address][primary][23][city]" type="text" value="Paris" />
```

También puede pasar una opción `:index` directamente a ayudantes como `text_field`, pero generalmente es menos repetitivo especificarlo en el nivel del constructor de formularios que en campos de entrada individuales.

Hablando en general, el nombre final de la entrada será una concatenación del nombre dado a `fields_for` / `form_with`, el valor de la opción `:index` y el nombre del atributo.

Por último, como atajo, en lugar de especificar un ID para `:index` (por ejemplo, `index: address.id`), puede agregar `"[]"` al nombre dado. Por ejemplo:

```erb
<%= fields_for 'person[address][primary][]', address do |address_form| %>
  <%= address_form.text_field :city %>
<% end %>
```

produce exactamente la misma salida que nuestro ejemplo original.

Formularios para recursos externos
----------------------------------

Los ayudantes de formularios de Rails también se pueden utilizar para construir un formulario para enviar datos a un recurso externo. Sin embargo, a veces puede ser necesario establecer un `authenticity_token` para el recurso; esto se puede hacer pasando un parámetro `authenticity_token: 'your_external_token'` a las opciones de `form_with`:

```erb
<%= form_with url: 'http://farfar.away/form', authenticity_token: 'external_token' do %>
  Contenido del formulario
<% end %>
```

A veces, al enviar datos a un recurso externo, como una pasarela de pago, los campos que se pueden utilizar en el formulario están limitados por una API externa y puede ser indeseable generar un `authenticity_token`. Para no enviar un token, simplemente pase `false` a la opción `:authenticity_token`:

```erb
<%= form_with url: 'http://farfar.away/form', authenticity_token: false do %>
  Contenido del formulario
<% end %>
```

Construyendo formularios complejos
----------------------------------

Muchas aplicaciones van más allá de los formularios simples que editan un solo objeto. Por ejemplo, al crear una `Persona`, es posible que desee permitir al usuario (en el mismo formulario) crear varios registros de dirección (casa, trabajo, etc.). Al editar posteriormente esa persona, el usuario debería poder agregar, eliminar o modificar direcciones según sea necesario.

### Configurando el modelo

Active Record proporciona soporte a nivel de modelo a través del método [`accepts_nested_attributes_for`](https://api.rubyonrails.org/classes/ActiveRecord/NestedAttributes/ClassMethods.html#method-i-accepts_nested_attributes_for):

```ruby
class Person < ApplicationRecord
  has_many :addresses, inverse_of: :person
  accepts_nested_attributes_for :addresses
end

class Address < ApplicationRecord
  belongs_to :person
end
```

Esto crea un método `addresses_attributes=` en `Person` que le permite crear, actualizar y (opcionalmente) destruir direcciones.
### Formularios anidados

El siguiente formulario permite a un usuario crear una `Persona` y sus direcciones asociadas.

```html+erb
<%= form_with model: @person do |form| %>
  Direcciones:
  <ul>
    <%= form.fields_for :addresses do |addresses_form| %>
      <li>
        <%= addresses_form.label :kind %>
        <%= addresses_form.text_field :kind %>

        <%= addresses_form.label :street %>
        <%= addresses_form.text_field :street %>
        ...
      </li>
    <% end %>
  </ul>
<% end %>
```


Cuando una asociación acepta atributos anidados, `fields_for` renderiza su bloque una vez por cada elemento de la asociación. En particular, si una persona no tiene direcciones, no renderiza nada. Un patrón común es que el controlador construya uno o más hijos vacíos para que al menos se muestre un conjunto de campos al usuario. El siguiente ejemplo resultaría en 2 conjuntos de campos de dirección que se renderizarían en el formulario de nueva persona.

```ruby
def new
  @person = Person.new
  2.times { @person.addresses.build }
end
```

`fields_for` proporciona un generador de formularios. El nombre de los parámetros será lo que `accepts_nested_attributes_for` espera. Por ejemplo, al crear un usuario con 2 direcciones, los parámetros enviados se verían así:

```ruby
{
  'person' => {
    'name' => 'John Doe',
    'addresses_attributes' => {
      '0' => {
        'kind' => 'Home',
        'street' => '221b Baker Street'
      },
      '1' => {
        'kind' => 'Office',
        'street' => '31 Spooner Street'
      }
    }
  }
}
```

Los valores reales de las claves en el hash `:addresses_attributes` no son importantes; sin embargo, deben ser cadenas de enteros y diferentes para cada dirección.

Si el objeto asociado ya está guardado, `fields_for` genera automáticamente un campo oculto con el `id` del registro guardado. Puedes desactivar esto pasando `include_id: false` a `fields_for`.

### El controlador

Como de costumbre, debes [declarar los parámetros permitidos](action_controller_overview.html#strong-parameters) en el controlador antes de pasarlos al modelo:

```ruby
def create
  @person = Person.new(person_params)
  # ...
end

private
  def person_params
    params.require(:person).permit(:name, addresses_attributes: [:id, :kind, :street])
  end
```

### Eliminación de objetos

Puedes permitir a los usuarios eliminar objetos asociados pasando `allow_destroy: true` a `accepts_nested_attributes_for`

```ruby
class Person < ApplicationRecord
  has_many :addresses
  accepts_nested_attributes_for :addresses, allow_destroy: true
end
```

Si el hash de atributos para un objeto contiene la clave `_destroy` con un valor que se evalúa como `true` (por ejemplo, 1, '1', true o 'true'), entonces el objeto se eliminará. Este formulario permite a los usuarios eliminar direcciones:

```erb
<%= form_with model: @person do |form| %>
  Direcciones:
  <ul>
    <%= form.fields_for :addresses do |addresses_form| %>
      <li>
        <%= addresses_form.check_box :_destroy %>
        <%= addresses_form.label :kind %>
        <%= addresses_form.text_field :kind %>
        ...
      </li>
    <% end %>
  </ul>
<% end %>
```

No olvides actualizar los parámetros permitidos en tu controlador para incluir también el campo `_destroy`:

```ruby
def person_params
  params.require(:person).
    permit(:name, addresses_attributes: [:id, :kind, :street, :_destroy])
end
```

### Evitar registros vacíos

A menudo es útil ignorar conjuntos de campos que el usuario no ha completado. Puedes controlar esto pasando un bloque `:reject_if` a `accepts_nested_attributes_for`. Este bloque se llamará con cada hash de atributos enviado por el formulario. Si el bloque devuelve `true`, entonces Active Record no construirá un objeto asociado para ese hash. El siguiente ejemplo solo intentará construir una dirección si el atributo `kind` está establecido.

```ruby
class Person < ApplicationRecord
  has_many :addresses
  accepts_nested_attributes_for :addresses, reject_if: lambda { |attributes| attributes['kind'].blank? }
end
```

Como conveniencia, también puedes pasar el símbolo `:all_blank`, que creará un bloque que rechazará registros donde todos los atributos estén en blanco, excluyendo cualquier valor para `_destroy`.

### Añadir campos sobre la marcha

En lugar de renderizar varios conjuntos de campos de antemano, es posible que desees agregarlos solo cuando un usuario haga clic en un botón "Agregar nueva dirección". Rails no proporciona soporte incorporado para esto. Al generar nuevos conjuntos de campos, debes asegurarte de que la clave del array asociado sea única; la fecha actual en JavaScript (milisegundos desde la [época](https://es.wikipedia.org/wiki/Tiempo_Unix)) es una elección común.

Uso de Tag Helpers sin un generador de formularios
---------------------------------------------------

En caso de que necesites renderizar campos de formulario fuera del contexto de un generador de formularios, Rails proporciona ayudantes de etiquetas para elementos de formulario comunes. Por ejemplo, [`check_box_tag`](https://api.rubyonrails.org/classes/ActionView/Helpers/FormTagHelper.html#method-i-check_box_tag):

```erb
<%= check_box_tag "accept" %>
```

Salida:

```html
<input type="checkbox" name="accept" id="accept" value="1" />
```

Generalmente, estos ayudantes tienen el mismo nombre que sus contrapartes de generador de formularios, pero con un sufijo `_tag`. Para obtener una lista completa, consulta la documentación de la API de [`FormTagHelper`](https://api.rubyonrails.org/classes/ActionView/Helpers/FormTagHelper.html).
Uso de `form_tag` y `form_for`
-------------------------------

Antes de que se introdujera `form_with` en Rails 5.1, su funcionalidad solía estar dividida entre [`form_tag`](https://api.rubyonrails.org/v5.2/classes/ActionView/Helpers/FormTagHelper.html#method-i-form_tag) y [`form_for`](https://api.rubyonrails.org/v5.2/classes/ActionView/Helpers/FormHelper.html#method-i-form_for). Ambos están ahora en desuso suave. La documentación sobre su uso se puede encontrar en [versiones anteriores de esta guía](https://guides.rubyonrails.org/v5.2/form_helpers.html).
[`fields_for`]: https://api.rubyonrails.org/classes/ActionView/Helpers/FormBuilder.html#method-i-fields_for
[formmethod]: https://developer.mozilla.org/en-US/docs/Web/HTML/Element/button#attr-formmethod
[button-name]: https://developer.mozilla.org/en-US/docs/Web/HTML/Element/button#attr-name
[button-value]: https://developer.mozilla.org/en-US/docs/Web/HTML/Element/button#attr-value
