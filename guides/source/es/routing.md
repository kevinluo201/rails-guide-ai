**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: fb66c6f4aafffdb8f8d44e8a2076c9b0
Enrutamiento de Rails de afuera hacia adentro
===============================================

Esta guía cubre las características orientadas al usuario del enrutamiento de Rails.

Después de leer esta guía, sabrás:

* Cómo interpretar el código en `config/routes.rb`.
* Cómo construir tus propias rutas, utilizando tanto el estilo de recursos preferido como el método `match`.
* Cómo declarar parámetros de ruta, que se pasan a las acciones del controlador.
* Cómo crear automáticamente rutas y URLs utilizando los ayudantes de ruta.
* Técnicas avanzadas como la creación de restricciones y el montaje de puntos finales de Rack.

--------------------------------------------------------------------------------

El propósito del enrutador de Rails
-----------------------------------

El enrutador de Rails reconoce las URLs y las envía a una acción del controlador o a una aplicación de Rack. También puede generar rutas y URLs, evitando la necesidad de codificar cadenas en tus vistas.

### Conexión de URLs con código

Cuando tu aplicación de Rails recibe una solicitud entrante para:

```
GET /patients/17
```

le pide al enrutador que lo empareje con una acción del controlador. Si la primera ruta coincidente es:

```ruby
get '/patients/:id', to: 'patients#show'
```

la solicitud se envía a la acción `show` del controlador `patients` con `{ id: '17' }` en `params`.

NOTA: Rails utiliza snake_case para los nombres de los controladores aquí, si tienes un controlador de varias palabras como `MonsterTrucksController`, debes usar `monster_trucks#show`, por ejemplo.

### Generación de rutas y URLs desde el código

También puedes generar rutas y URLs. Si la ruta anterior se modifica de la siguiente manera:

```ruby
get '/patients/:id', to: 'patients#show', as: 'patient'
```

y tu aplicación contiene este código en el controlador:

```ruby
@patient = Patient.find(params[:id])
```

y esto en la vista correspondiente:

```erb
<%= link_to 'Registro del paciente', patient_path(@patient) %>
```

entonces el enrutador generará la ruta `/patients/17`. Esto reduce la fragilidad de tu vista y hace que tu código sea más fácil de entender. Ten en cuenta que el id no necesita especificarse en el ayudante de ruta.

### Configuración del enrutador de Rails

Las rutas de tu aplicación o motor se encuentran en el archivo `config/routes.rb` y típicamente se ven así:

```ruby
Rails.application.routes.draw do
  resources :brands, only: [:index, :show] do
    resources :products, only: [:index, :show]
  end

  resource :basket, only: [:show, :update, :destroy]

  resolve("Basket") { route_for(:basket) }
end
```

Dado que este es un archivo fuente regular de Ruby, puedes utilizar todas sus características para ayudarte a definir tus rutas, pero ten cuidado con los nombres de las variables, ya que pueden entrar en conflicto con los métodos DSL del enrutador.

NOTA: El bloque `Rails.application.routes.draw do ... end` que envuelve tus definiciones de ruta es necesario para establecer el alcance del DSL del enrutador y no debe eliminarse.

Enrutamiento de recursos: el predeterminado de Rails
---------------------------------------------------

El enrutamiento de recursos te permite declarar rápidamente todas las rutas comunes para un controlador de recursos dado. Una sola llamada a [`resources`][] puede declarar todas las rutas necesarias para tus acciones `index`, `show`, `new`, `edit`, `create`, `update` y `destroy`.


### Recursos en la web

Los navegadores solicitan páginas a Rails haciendo una solicitud de una URL utilizando un método HTTP específico, como `GET`, `POST`, `PATCH`, `PUT` y `DELETE`. Cada método es una solicitud para realizar una operación en el recurso. Una ruta de recurso asigna varias solicitudes relacionadas a acciones en un solo controlador.

Cuando tu aplicación de Rails recibe una solicitud entrante para:

```
DELETE /photos/17
```

le pide al enrutador que lo asigne a una acción del controlador. Si la primera ruta coincidente es:

```ruby
resources :photos
```

Rails enviaría esa solicitud a la acción `destroy` del controlador `photos` con `{ id: '17' }` en `params`.

### CRUD, verbos y acciones

En Rails, una ruta de recursos proporciona una asignación entre los verbos HTTP y las URLs a las acciones del controlador. Por convención, cada acción también se asigna a una operación CRUD específica en una base de datos. Una sola entrada en el archivo de enrutamiento, como:

```ruby
resources :photos
```

crea siete rutas diferentes en tu aplicación, todas asignadas al controlador `Photos`:

| Verbo HTTP | Ruta             | Controlador#Acción | Usado para                                    |
| ---------- | ---------------- | ----------------- | --------------------------------------------- |
| GET        | /photos          | photos#index      | mostrar una lista de todas las fotos           |
| GET        | /photos/new      | photos#new        | devolver un formulario HTML para crear una nueva foto |
| POST       | /photos          | photos#create     | crear una nueva foto                          |
| GET        | /photos/:id      | photos#show       | mostrar una foto específica                   |
| GET        | /photos/:id/edit | photos#edit       | devolver un formulario HTML para editar una foto |
| PATCH/PUT  | /photos/:id      | photos#update     | actualizar una foto específica                |
| DELETE     | /photos/:id      | photos#destroy    | eliminar una foto específica                  |
NOTA: Debido a que el enrutador utiliza el verbo HTTP y la URL para coincidir con las solicitudes entrantes, cuatro URLs se asignan a siete acciones diferentes.

NOTA: Las rutas de Rails se emparejan en el orden en que se especifican, por lo que si tienes un `resources :photos` encima de un `get 'photos/poll'`, la ruta de la acción `show` para la línea `resources` se emparejará antes que la línea `get`. Para solucionar esto, mueve la línea `get` **arriba** de la línea `resources` para que se empareje primero.

### Helpers de Ruta y URL

Al crear una ruta de recursos, también se exponen varios helpers a los controladores de tu aplicación. En el caso de `resources :photos`:

* `photos_path` devuelve `/photos`
* `new_photo_path` devuelve `/photos/new`
* `edit_photo_path(:id)` devuelve `/photos/:id/edit` (por ejemplo, `edit_photo_path(10)` devuelve `/photos/10/edit`)
* `photo_path(:id)` devuelve `/photos/:id` (por ejemplo, `photo_path(10)` devuelve `/photos/10`)

Cada uno de estos helpers tiene un helper correspondiente `_url` (como `photos_url`) que devuelve la misma ruta con el prefijo del host actual, el puerto y el prefijo de la ruta.

CONSEJO: Para encontrar los nombres de los helpers de ruta para tus rutas, consulta [Listar rutas existentes](#listar-rutas-existentes) a continuación.

### Definir Múltiples Recursos al Mismo Tiempo

Si necesitas crear rutas para más de un recurso, puedes ahorrar un poco de escritura definiéndolos todos con una sola llamada a `resources`:

```ruby
resources :photos, :books, :videos
```

Esto funciona exactamente igual que:

```ruby
resources :photos
resources :books
resources :videos
```

### Recursos Singulares

A veces, tienes un recurso que los clientes siempre buscan sin hacer referencia a un ID. Por ejemplo, te gustaría que `/profile` siempre muestre el perfil del usuario que ha iniciado sesión actualmente. En este caso, puedes usar un recurso singular para asignar `/profile` (en lugar de `/profile/:id`) a la acción `show`:

```ruby
get 'profile', to: 'users#show'
```

Al pasar una `String` a `to:`, se espera un formato `controller#action`. Cuando se utiliza un `Symbol`, la opción `to:` debe reemplazarse por `action:`. Cuando se utiliza una `String` sin un `#`, la opción `to:` debe reemplazarse por `controller:`:

```ruby
get 'profile', action: :show, controller: 'users'
```

Esta ruta de recursos:

```ruby
resource :geocoder
resolve('Geocoder') { [:geocoder] }
```

crea seis rutas diferentes en tu aplicación, todas asignadas al controlador `Geocoders`:

| Verbo HTTP | Ruta                | Controlador#Acción | Utilizado para                                  |
| ---------- | ------------------- | ------------------ | ----------------------------------------------- |
| GET        | /geocoder/new       | geocoders#new      | devuelve un formulario HTML para crear el geocodificador |
| POST       | /geocoder           | geocoders#create   | crea el nuevo geocodificador                    |
| GET        | /geocoder           | geocoders#show     | muestra el único recurso geocodificador          |
| GET        | /geocoder/edit      | geocoders#edit     | devuelve un formulario HTML para editar el geocodificador |
| PATCH/PUT  | /geocoder           | geocoders#update   | actualiza el único recurso geocodificador        |
| DELETE     | /geocoder           | geocoders#destroy  | elimina el recurso geocodificador                |

NOTA: Debido a que es posible que desees utilizar el mismo controlador para una ruta singular (`/account`) y una ruta plural (`/accounts/45`), los recursos singulares se asignan a controladores plurales. Por ejemplo, `resource :photo` y `resources :photos` crean rutas tanto singulares como plurales que se asignan al mismo controlador (`PhotosController`).

Una ruta de recursos singular genera estos helpers:

* `new_geocoder_path` devuelve `/geocoder/new`
* `edit_geocoder_path` devuelve `/geocoder/edit`
* `geocoder_path` devuelve `/geocoder`

NOTA: La llamada a `resolve` es necesaria para convertir instancias de `Geocoder` en rutas a través de [identificación de registros](form_helpers.html#relying-on-record-identification).

Al igual que con los recursos plurales, los mismos helpers que terminan en `_url` también incluirán el host, el puerto y el prefijo de la ruta.

### Espacios de Nombres de Controladores y Enrutamiento

Es posible que desees organizar grupos de controladores bajo un espacio de nombres. Lo más común es agrupar varios controladores administrativos bajo un espacio de nombres `Admin::` y colocar estos controladores en el directorio `app/controllers/admin`. Puedes enrutarte a este grupo utilizando un bloque [`namespace`][]:

```ruby
namespace :admin do
  resources :articles, :comments
end
```

Esto creará varias rutas para cada uno de los controladores `articles` y `comments`. Para `Admin::ArticlesController`, Rails creará:

| Verbo HTTP | Ruta                            | Controlador#Acción       | Helper de Ruta Nombrado           |
| ---------- | ------------------------------- | ------------------------ | --------------------------------- |
| GET        | /admin/articles                 | admin/articles#index    | admin_articles_path              |
| GET        | /admin/articles/new             | admin/articles#new      | new_admin_article_path           |
| POST       | /admin/articles                 | admin/articles#create   | admin_articles_path              |
| GET        | /admin/articles/:id             | admin/articles#show     | admin_article_path(:id)          |
| GET        | /admin/articles/:id/edit        | admin/articles#edit     | edit_admin_article_path(:id)     |
| PATCH/PUT  | /admin/articles/:id             | admin/articles#update   | admin_article_path(:id)          |
| DELETE     | /admin/articles/:id             | admin/articles#destroy  | admin_article_path(:id)          |
Si en cambio quieres enrutar `/articles` (sin el prefijo `/admin`) a `Admin::ArticlesController`, puedes especificar el módulo con un bloque [`scope`][]:

```ruby
scope module: 'admin' do
  resources :articles, :comments
end
```

Esto también se puede hacer para una sola ruta:

```ruby
resources :articles, module: 'admin'
```

Si en cambio quieres enrutar `/admin/articles` a `ArticlesController` (sin el prefijo del módulo `Admin::`), puedes especificar la ruta con un bloque `scope`:

```ruby
scope '/admin' do
  resources :articles, :comments
end
```

Esto también se puede hacer para una sola ruta:

```ruby
resources :articles, path: '/admin/articles'
```

En ambos casos, los ayudantes de ruta con nombre siguen siendo los mismos que si no usaste `scope`. En el último caso, las siguientes rutas se asignan a `ArticlesController`:

| Verbo HTTP | Ruta                     | Controlador#Acción  | Ayudante de ruta con nombre |
| ---------- | ------------------------ | -------------------- | -------------------------- |
| GET        | /admin/articles          | articles#index       | articles_path              |
| GET        | /admin/articles/new      | articles#new         | new_article_path           |
| POST       | /admin/articles          | articles#create      | articles_path              |
| GET        | /admin/articles/:id      | articles#show        | article_path(:id)          |
| GET        | /admin/articles/:id/edit | articles#edit        | edit_article_path(:id)     |
| PATCH/PUT  | /admin/articles/:id      | articles#update      | article_path(:id)          |
| DELETE     | /admin/articles/:id      | articles#destroy     | article_path(:id)          |

CONSEJO: Si necesitas usar un espacio de nombres de controlador diferente dentro de un bloque `namespace`, puedes especificar una ruta de controlador absoluta, por ejemplo: `get '/foo', to: '/foo#index'`.


### Recursos anidados

Es común tener recursos que son lógicamente hijos de otros recursos. Por ejemplo, supongamos que tu aplicación incluye estos modelos:

```ruby
class Magazine < ApplicationRecord
  has_many :ads
end

class Ad < ApplicationRecord
  belongs_to :magazine
end
```

Las rutas anidadas te permiten capturar esta relación en tu enrutamiento. En este caso, podrías incluir esta declaración de ruta:

```ruby
resources :magazines do
  resources :ads
end
```

Además de las rutas para las revistas, esta declaración también enrutará los anuncios a un `AdsController`. Las URL de los anuncios requieren una revista:

| Verbo HTTP | Ruta                                 | Controlador#Acción | Utilizado para                                                             |
| ---------- | ------------------------------------ | ----------------- | -------------------------------------------------------------------------- |
| GET        | /magazines/:magazine_id/ads          | ads#index         | mostrar una lista de todos los anuncios de una revista específica           |
| GET        | /magazines/:magazine_id/ads/new      | ads#new           | devolver un formulario HTML para crear un nuevo anuncio perteneciente a una revista específica |
| POST       | /magazines/:magazine_id/ads          | ads#create        | crear un nuevo anuncio perteneciente a una revista específica               |
| GET        | /magazines/:magazine_id/ads/:id      | ads#show          | mostrar un anuncio específico perteneciente a una revista específica        |
| GET        | /magazines/:magazine_id/ads/:id/edit | ads#edit          | devolver un formulario HTML para editar un anuncio perteneciente a una revista específica |
| PATCH/PUT  | /magazines/:magazine_id/ads/:id      | ads#update        | actualizar un anuncio específico perteneciente a una revista específica     |
| DELETE     | /magazines/:magazine_id/ads/:id      | ads#destroy       | eliminar un anuncio específico perteneciente a una revista específica       |

Esto también creará ayudantes de enrutamiento como `magazine_ads_url` y `edit_magazine_ad_path`. Estos ayudantes toman una instancia de Magazine como el primer parámetro (`magazine_ads_url(@magazine)`).

#### Límites para la anidación

Puedes anidar recursos dentro de otros recursos anidados si lo deseas. Por ejemplo:

```ruby
resources :publishers do
  resources :magazines do
    resources :photos
  end
end
```

Los recursos anidados profundamente rápidamente se vuelven engorrosos. En este caso, por ejemplo, la aplicación reconocería rutas como:

```
/publishers/1/magazines/2/photos/3
```

El ayudante de ruta correspondiente sería `publisher_magazine_photo_url`, lo que requeriría que especifiques objetos en los tres niveles. De hecho, esta situación es lo suficientemente confusa como para que un [artículo popular de Jamis Buck](http://weblog.jamisbuck.org/2007/2/5/nesting-resources) proponga una regla general para un buen diseño de Rails:

CONSEJO: Los recursos nunca deben anidarse más de 1 nivel de profundidad.

#### Anidación superficial

Una forma de evitar la anidación profunda (como se recomienda anteriormente) es generar las acciones de colección con ámbito bajo el padre, para tener una idea de la jerarquía, pero no anidar las acciones de miembro. En otras palabras, solo construir rutas con la cantidad mínima de información para identificar de manera única el recurso, como esto:

```ruby
resources :articles do
  resources :comments, only: [:index, :new, :create]
end
resources :comments, only: [:show, :edit, :update, :destroy]
```

Esta idea encuentra un equilibrio entre rutas descriptivas y anidación profunda. Existe una sintaxis abreviada para lograr exactamente eso, a través de la opción `:shallow`:

```ruby
resources :articles do
  resources :comments, shallow: true
end
```
Esto generará las mismas rutas exactas que el primer ejemplo. También puedes especificar la opción `:shallow` en el recurso padre, en cuyo caso todos los recursos anidados serán superficiales:

```ruby
resources :articles, shallow: true do
  resources :comments
  resources :quotes
  resources :drafts
end
```

El recurso de artículos aquí tendrá las siguientes rutas generadas:

| Verbo HTTP | Ruta                                         | Controlador#Acción | Helper de Ruta Nombrada |
| ---------- | -------------------------------------------- | ------------------ | ----------------------- |
| GET        | /articles/:article_id/comments(.:format)     | comments#index     | article_comments_path   |
| POST       | /articles/:article_id/comments(.:format)     | comments#create    | article_comments_path   |
| GET        | /articles/:article_id/comments/new(.:format) | comments#new       | new_article_comment_path|
| GET        | /comments/:id/edit(.:format)                 | comments#edit      | edit_comment_path       |
| GET        | /comments/:id(.:format)                      | comments#show      | comment_path            |
| PATCH/PUT  | /comments/:id(.:format)                      | comments#update    | comment_path            |
| DELETE     | /comments/:id(.:format)                      | comments#destroy   | comment_path            |
| GET        | /articles/:article_id/quotes(.:format)       | quotes#index       | article_quotes_path     |
| POST       | /articles/:article_id/quotes(.:format)       | quotes#create      | article_quotes_path     |
| GET        | /articles/:article_id/quotes/new(.:format)   | quotes#new         | new_article_quote_path  |
| GET        | /quotes/:id/edit(.:format)                   | quotes#edit        | edit_quote_path         |
| GET        | /quotes/:id(.:format)                        | quotes#show        | quote_path              |
| PATCH/PUT  | /quotes/:id(.:format)                        | quotes#update      | quote_path              |
| DELETE     | /quotes/:id(.:format)                        | quotes#destroy     | quote_path              |
| GET        | /articles/:article_id/drafts(.:format)       | drafts#index       | article_drafts_path     |
| POST       | /articles/:article_id/drafts(.:format)       | drafts#create      | article_drafts_path     |
| GET        | /articles/:article_id/drafts/new(.:format)   | drafts#new         | new_article_draft_path  |
| GET        | /drafts/:id/edit(.:format)                   | drafts#edit        | edit_draft_path         |
| GET        | /drafts/:id(.:format)                        | drafts#show        | draft_path              |
| PATCH/PUT  | /drafts/:id(.:format)                        | drafts#update      | draft_path              |
| DELETE     | /drafts/:id(.:format)                        | drafts#destroy     | draft_path              |
| GET        | /articles(.:format)                          | articles#index     | articles_path           |
| POST       | /articles(.:format)                          | articles#create    | articles_path           |
| GET        | /articles/new(.:format)                      | articles#new       | new_article_path        |
| GET        | /articles/:id/edit(.:format)                 | articles#edit      | edit_article_path       |
| GET        | /articles/:id(.:format)                      | articles#show      | article_path            |
| PATCH/PUT  | /articles/:id(.:format)                      | articles#update    | article_path            |
| DELETE     | /articles/:id(.:format)                      | articles#destroy   | article_path            |

El método [`shallow`][] de la DSL crea un ámbito dentro del cual cada anidamiento es superficial. Esto genera las mismas rutas que el ejemplo anterior:

```ruby
shallow do
  resources :articles do
    resources :comments
    resources :quotes
    resources :drafts
  end
end
```

Existen dos opciones para `scope` para personalizar las rutas superficiales. `:shallow_path` agrega un prefijo a las rutas de miembros con el parámetro especificado:

```ruby
scope shallow_path: "sekret" do
  resources :articles do
    resources :comments, shallow: true
  end
end
```

El recurso de comentarios aquí tendrá las siguientes rutas generadas:

| Verbo HTTP | Ruta                                         | Controlador#Acción | Helper de Ruta Nombrada |
| ---------- | -------------------------------------------- | ------------------ | ----------------------- |
| GET        | /articles/:article_id/comments(.:format)     | comments#index     | article_comments_path   |
| POST       | /articles/:article_id/comments(.:format)     | comments#create    | article_comments_path   |
| GET        | /articles/:article_id/comments/new(.:format) | comments#new       | new_article_comment_path|
| GET        | /sekret/comments/:id/edit(.:format)          | comments#edit      | edit_comment_path       |
| GET        | /sekret/comments/:id(.:format)               | comments#show      | comment_path            |
| PATCH/PUT  | /sekret/comments/:id(.:format)               | comments#update    | comment_path            |
| DELETE     | /sekret/comments/:id(.:format)               | comments#destroy   | comment_path            |

La opción `:shallow_prefix` agrega el parámetro especificado a los ayudantes de ruta nombrados:

```ruby
scope shallow_prefix: "sekret" do
  resources :articles do
    resources :comments, shallow: true
  end
end
```

El recurso de comentarios aquí tendrá las siguientes rutas generadas:

| Verbo HTTP | Ruta                                         | Controlador#Acción | Helper de Ruta Nombrada    |
| ---------- | -------------------------------------------- | ------------------ | -------------------------- |
| GET        | /articles/:article_id/comments(.:format)     | comments#index     | article_comments_path      |
| POST       | /articles/:article_id/comments(.:format)     | comments#create    | article_comments_path      |
| GET        | /articles/:article_id/comments/new(.:format) | comments#new       | new_article_comment_path   |
| GET        | /comments/:id/edit(.:format)                 | comments#edit      | edit_sekret_comment_path   |
| GET        | /comments/:id(.:format)                      | comments#show      | sekret_comment_path        |
| PATCH/PUT  | /comments/:id(.:format)                      | comments#update    | sekret_comment_path        |
| DELETE     | /comments/:id(.:format)                      | comments#destroy   | sekret_comment_path        |


### Preocupaciones de enrutamiento

Las preocupaciones de enrutamiento te permiten declarar rutas comunes que se pueden reutilizar dentro de otros recursos y rutas. Para definir una preocupación, utiliza un bloque [`concern`][]:

```ruby
concern :commentable do
  resources :comments
end

concern :image_attachable do
  resources :images, only: :index
end
```

Estas preocupaciones se pueden utilizar en recursos para evitar la duplicación de código y compartir comportamiento en las rutas:

```ruby
resources :messages, concerns: :commentable

resources :articles, concerns: [:commentable, :image_attachable]
```

Lo anterior es equivalente a:

```ruby
resources :messages do
  resources :comments
end

resources :articles do
  resources :comments
  resources :images, only: :index
end
```
También puedes usarlos en cualquier lugar llamando a [`concerns`][]. Por ejemplo, en un bloque `scope` o `namespace`:

```ruby
namespace :articles do
  concerns :commentable
end
```


### Creación de rutas y URLs a partir de objetos

Además de utilizar los ayudantes de enrutamiento, Rails también puede crear rutas y URLs a partir de una matriz de parámetros. Por ejemplo, supongamos que tienes este conjunto de rutas:

```ruby
resources :magazines do
  resources :ads
end
```

Cuando uses `magazine_ad_path`, puedes pasar instancias de `Magazine` y `Ad` en lugar de los IDs numéricos:

```erb
<%= link_to 'Detalles del anuncio', magazine_ad_path(@magazine, @ad) %>
```

También puedes usar [`url_for`][ActionView::RoutingUrlFor#url_for] con un conjunto de objetos, y Rails determinará automáticamente qué ruta quieres:

```erb
<%= link_to 'Detalles del anuncio', url_for([@magazine, @ad]) %>
```

En este caso, Rails verá que `@magazine` es un `Magazine` y `@ad` es un `Ad` y utilizará el ayudante `magazine_ad_path`. En ayudantes como `link_to`, puedes especificar solo el objeto en lugar de la llamada completa a `url_for`:

```erb
<%= link_to 'Detalles del anuncio', [@magazine, @ad] %>
```

Si quisieras enlazar solo a una revista:

```erb
<%= link_to 'Detalles de la revista', @magazine %>
```

Para otras acciones, solo necesitas insertar el nombre de la acción como el primer elemento de la matriz:

```erb
<%= link_to 'Editar anuncio', [:edit, @magazine, @ad] %>
```

Esto te permite tratar las instancias de tus modelos como URLs, y es una ventaja clave de usar el estilo de recursos.


### Agregar más acciones RESTful

No estás limitado a las siete rutas que el enrutamiento RESTful crea de forma predeterminada. Si lo deseas, puedes agregar rutas adicionales que se apliquen a la colección o a los miembros individuales de la colección.

#### Agregar rutas de miembros

Para agregar una ruta de miembro, simplemente agrega un bloque [`member`][] dentro del bloque de recursos:

```ruby
resources :photos do
  member do
    get 'preview'
  end
end
```

Esto reconocerá `/photos/1/preview` con GET y enrutará a la acción `preview` del controlador `PhotosController`, con el valor del ID del recurso pasado en `params[:id]`. También creará los ayudantes `preview_photo_url` y `preview_photo_path`.

Dentro del bloque de rutas de miembros, cada nombre de ruta especifica el verbo HTTP que se reconocerá. Puedes usar [`get`][], [`patch`][], [`put`][], [`post`][] o [`delete`][] aquí. Si no tienes múltiples rutas de `member`, también puedes pasar `:on` a una ruta, eliminando el bloque:

```ruby
resources :photos do
  get 'preview', on: :member
end
```

Puedes omitir la opción `:on`, esto creará la misma ruta de miembro excepto que el valor del ID del recurso estará disponible en `params[:photo_id]` en lugar de `params[:id]`. Los ayudantes de ruta también se renombrarán de `preview_photo_url` y `preview_photo_path` a `photo_preview_url` y `photo_preview_path`.


#### Agregar rutas de colección

Para agregar una ruta a la colección, utiliza un bloque [`collection`][]:

```ruby
resources :photos do
  collection do
    get 'search'
  end
end
```

Esto permitirá que Rails reconozca rutas como `/photos/search` con GET y enrute a la acción `search` del controlador `PhotosController`. También creará los ayudantes de ruta `search_photos_url` y `search_photos_path`.

Al igual que con las rutas de miembros, puedes pasar `:on` a una ruta:

```ruby
resources :photos do
  get 'search', on: :collection
end
```

NOTA: Si estás definiendo rutas de recursos adicionales con un símbolo como el primer argumento posicional, ten en cuenta que no es equivalente a usar una cadena. Los símbolos infieren acciones del controlador mientras que las cadenas infieren rutas.


#### Agregar rutas para acciones nuevas adicionales

Para agregar una acción nueva alternativa utilizando el atajo `:on`:

```ruby
resources :comments do
  get 'preview', on: :new
end
```

Esto permitirá que Rails reconozca rutas como `/comments/new/preview` con GET y enrute a la acción `preview` del controlador `CommentsController`. También creará los ayudantes de ruta `preview_new_comment_url` y `preview_new_comment_path`.

CONSEJO: Si te encuentras agregando muchas acciones adicionales a una ruta de recursos, es hora de detenerte y preguntarte si estás disfrazando la presencia de otro recurso.

Rutas no relacionadas con recursos
----------------------------------

Además del enrutamiento de recursos, Rails tiene un soporte poderoso para enrutamiento de URLs arbitrarias a acciones. Aquí, no obtienes grupos de rutas generados automáticamente por el enrutamiento de recursos. En su lugar, configuras cada ruta por separado dentro de tu aplicación.

Si bien generalmente debes usar el enrutamiento de recursos, todavía hay muchos lugares donde el enrutamiento más simple es más apropiado. No es necesario tratar de encajar cada último detalle de tu aplicación en un marco de recursos si no es adecuado.
En particular, el enrutamiento simple hace que sea muy fácil asignar URL heredadas a nuevas acciones de Rails.

### Parámetros vinculados

Cuando configuras una ruta regular, proporcionas una serie de símbolos que Rails asigna a partes de una solicitud HTTP entrante. Por ejemplo, considera esta ruta:

```ruby
get 'photos(/:id)', to: 'photos#display'
```

Si una solicitud entrante de `/photos/1` es procesada por esta ruta (porque no coincide con ninguna ruta anterior en el archivo), entonces el resultado será invocar la acción `display` del controlador `PhotosController` y hacer que el parámetro final `"1"` esté disponible como `params[:id]`. Esta ruta también enrutaría la solicitud entrante de `/photos` a `PhotosController#display`, ya que `:id` es un parámetro opcional, indicado por paréntesis.

### Segmentos dinámicos

Puedes configurar tantos segmentos dinámicos como desees dentro de una ruta regular. Cualquier segmento estará disponible para la acción como parte de `params`. Si configuras esta ruta:

```ruby
get 'photos/:id/:user_id', to: 'photos#show'
```

Una ruta entrante de `/photos/1/2` se enviará a la acción `show` del controlador `PhotosController`. `params[:id]` será `"1"` y `params[:user_id]` será `"2"`.

CONSEJO: Por defecto, los segmentos dinámicos no aceptan puntos, esto se debe a que el punto se utiliza como separador para las rutas formateadas. Si necesitas usar un punto dentro de un segmento dinámico, agrega una restricción que anule esto, por ejemplo, `id: /[^\/]+/` permite cualquier cosa excepto una barra diagonal.

### Segmentos estáticos

Puedes especificar segmentos estáticos al crear una ruta sin anteponer dos puntos a un segmento:

```ruby
get 'photos/:id/with_user/:user_id', to: 'photos#show'
```

Esta ruta respondería a rutas como `/photos/1/with_user/2`. En este caso, `params` sería `{ controller: 'photos', action: 'show', id: '1', user_id: '2' }`.

### La cadena de consulta

`params` también incluirá cualquier parámetro de la cadena de consulta. Por ejemplo, con esta ruta:

```ruby
get 'photos/:id', to: 'photos#show'
```

Una ruta entrante de `/photos/1?user_id=2` se enviará a la acción `show` del controlador `Photos`. `params` será `{ controller: 'photos', action: 'show', id: '1', user_id: '2' }`.

### Definir valores predeterminados

Puedes definir valores predeterminados en una ruta proporcionando un hash para la opción `:defaults`. Esto también se aplica a los parámetros que no especificas como segmentos dinámicos. Por ejemplo:

```ruby
get 'photos/:id', to: 'photos#show', defaults: { format: 'jpg' }
```

Rails coincidiría `photos/12` con la acción `show` de `PhotosController` y establecería `params[:format]` en `"jpg"`.

También puedes usar un bloque [`defaults`][] para definir los valores predeterminados para varios elementos:

```ruby
defaults format: :json do
  resources :photos
end
```

NOTA: No puedes anular los valores predeterminados a través de parámetros de consulta, esto es por razones de seguridad. Los únicos valores predeterminados que se pueden anular son los segmentos dinámicos mediante la sustitución en la ruta URL.

### Nombres de rutas

Puedes especificar un nombre para cualquier ruta utilizando la opción `:as`:

```ruby
get 'exit', to: 'sessions#destroy', as: :logout
```

Esto creará `logout_path` y `logout_url` como ayudantes de ruta con nombre en tu aplicación. Llamar a `logout_path` devolverá `/exit`.

También puedes usar esto para anular los métodos de enrutamiento definidos por los recursos colocando rutas personalizadas antes de que se defina el recurso, de esta manera:

```ruby
get ':username', to: 'users#show', as: :user
resources :users
```

Esto definirá un método `user_path` que estará disponible en controladores, ayudantes y vistas y que irá a una ruta como `/bob`. Dentro de la acción `show` de `UsersController`, `params[:username]` contendrá el nombre de usuario del usuario. Cambia `:username` en la definición de la ruta si no quieres que el nombre del parámetro sea `:username`.

### Restricciones de verbo HTTP

En general, debes usar los métodos [`get`][], [`post`][], [`put`][], [`patch`][] y [`delete`][] para restringir una ruta a un verbo particular. Puedes usar el método [`match`][] con la opción `:via` para coincidir con múltiples verbos a la vez:

```ruby
match 'photos', to: 'photos#show', via: [:get, :post]
```

Puedes hacer coincidir todos los verbos con una ruta particular usando `via: :all`:

```ruby
match 'photos', to: 'photos#show', via: :all
```

NOTA: Enrutar tanto las solicitudes `GET` como `POST` a una sola acción tiene implicaciones de seguridad. En general, debes evitar enrutar todos los verbos a una acción a menos que tengas una buena razón para hacerlo.

NOTA: `GET` en Rails no verificará el token CSRF. Nunca debes escribir en la base de datos desde solicitudes `GET`, para obtener más información, consulta la [guía de seguridad](security.html#csrf-countermeasures) sobre las contramedidas CSRF.
### Restricciones de segmentos

Puede utilizar la opción `:constraints` para imponer un formato para un segmento dinámico:

```ruby
get 'photos/:id', to: 'photos#show', constraints: { id: /[A-Z]\d{5}/ }
```

Esta ruta coincidiría con rutas como `/photos/A12345`, pero no con `/photos/893`. Puede expresar de manera más concisa la misma ruta de esta manera:

```ruby
get 'photos/:id', to: 'photos#show', id: /[A-Z]\d{5}/
```

`:constraints` toma expresiones regulares con la restricción de que no se pueden utilizar anclas de expresiones regulares. Por ejemplo, la siguiente ruta no funcionará:

```ruby
get '/:id', to: 'articles#show', constraints: { id: /^\d/ }
```

Sin embargo, tenga en cuenta que no es necesario utilizar anclas porque todas las rutas están ancladas al principio y al final.

Por ejemplo, las siguientes rutas permitirían que los `articles` con valores `to_param` como `1-hello-world` que siempre comienzan con un número y los `users` con valores `to_param` como `david` que nunca comienzan con un número compartan el espacio de nombres raíz:

```ruby
get '/:id', to: 'articles#show', constraints: { id: /\d.+/ }
get '/:username', to: 'users#show'
```

### Restricciones basadas en la solicitud

También puede restringir una ruta en función de cualquier método en el [objeto Request](action_controller_overview.html#the-request-object) que devuelva una `String`.

Especifica una restricción basada en la solicitud de la misma manera que especificas una restricción de segmento:

```ruby
get 'photos', to: 'photos#index', constraints: { subdomain: 'admin' }
```

También puede especificar restricciones utilizando un bloque [`constraints`][]:

```ruby
namespace :admin do
  constraints subdomain: 'admin' do
    resources :photos
  end
end
```

NOTA: Las restricciones de solicitud funcionan llamando a un método en el [objeto Request](action_controller_overview.html#the-request-object) con el mismo nombre que la clave del hash y luego comparando el valor de retorno con el valor del hash. Por lo tanto, los valores de restricción deben coincidir con el tipo de retorno del método correspondiente del objeto Request. Por ejemplo: `constraints: { subdomain: 'api' }` coincidirá con un subdominio `api` como se espera. Sin embargo, el uso de un símbolo `constraints: { subdomain: :api }` no lo hará, porque `request.subdomain` devuelve `'api'` como una cadena.

NOTA: Existe una excepción para la restricción de `formato`: aunque es un método en el objeto Request, también es un parámetro opcional implícito en cada ruta. Las restricciones de segmento tienen prioridad y la restricción de `formato` solo se aplica como tal cuando se aplica a través de un hash. Por ejemplo, `get 'foo', constraints: { format: 'json' }` coincidirá con `GET  /foo` porque el formato es opcional de forma predeterminada. Sin embargo, puede [usar una lambda](#advanced-constraints) como en `get 'foo', constraints: lambda { |req| req.format == :json }` y la ruta solo coincidirá con solicitudes JSON explícitas.


### Restricciones avanzadas

Si tiene una restricción más avanzada, puede proporcionar un objeto que responda a `matches?` que Rails debe utilizar. Digamos que desea enrutar a todos los usuarios en una lista restringida al `RestrictedListController`. Podrías hacer esto:

```ruby
class RestrictedListConstraint
  def initialize
    @ips = RestrictedList.retrieve_ips
  end

  def matches?(request)
    @ips.include?(request.remote_ip)
  end
end

Rails.application.routes.draw do
  get '*path', to: 'restricted_list#index',
    constraints: RestrictedListConstraint.new
end
```

También puede especificar restricciones como una lambda:

```ruby
Rails.application.routes.draw do
  get '*path', to: 'restricted_list#index',
    constraints: lambda { |request| RestrictedList.retrieve_ips.include?(request.remote_ip) }
end
```

Tanto el método `matches?` como la lambda reciben el objeto `request` como argumento.

#### Restricciones en forma de bloque

Puede especificar restricciones en forma de bloque. Esto es útil cuando necesita aplicar la misma regla a varias rutas. Por ejemplo:

```ruby
class RestrictedListConstraint
  # ...Igual que el ejemplo anterior
end

Rails.application.routes.draw do
  constraints(RestrictedListConstraint.new) do
    get '*path', to: 'restricted_list#index'
    get '*other-path', to: 'other_restricted_list#index'
  end
end
```

También puede usar una `lambda`:

```ruby
Rails.application.routes.draw do
  constraints(lambda { |request| RestrictedList.retrieve_ips.include?(request.remote_ip) }) do
    get '*path', to: 'restricted_list#index'
    get '*other-path', to: 'other_restricted_list#index'
  end
end
```

### Segmentos de comodín y restricciones

La segmentación de rutas es una forma de especificar que un parámetro en particular debe coincidir con todas las partes restantes de una ruta. Por ejemplo:

```ruby
get 'photos/*other', to: 'photos#unknown'
```

Esta ruta coincidiría con `photos/12` o `/photos/long/path/to/12`, estableciendo `params[:other]` en `"12"` o `"long/path/to/12"`. Los segmentos con un asterisco como prefijo se llaman "segmentos de comodín".

Los segmentos de comodín pueden aparecer en cualquier lugar de una ruta. Por ejemplo:

```ruby
get 'books/*section/:title', to: 'books#show'
```

coincidiría con `books/some/section/last-words-a-memoir` con `params[:section]` igual a `'some/section'`, y `params[:title]` igual a `'last-words-a-memoir'`.

Técnicamente, una ruta puede tener incluso más de un segmento de comodín. El emparejador asigna segmentos a parámetros de una manera intuitiva. Por ejemplo:

```ruby
get '*a/foo/*b', to: 'test#index'
```

coincidiría con `zoo/woo/foo/bar/baz` con `params[:a]` igual a `'zoo/woo'`, y `params[:b]` igual a `'bar/baz'`.
NOTA: Al solicitar `'/foo/bar.json'`, tus `params[:pages]` será igual a `'foo/bar'` con el formato de solicitud JSON. Si deseas recuperar el comportamiento antiguo de la versión 3.0.x, puedes proporcionar `format: false` de esta manera:

```ruby
get '*pages', to: 'pages#show', format: false
```

NOTA: Si deseas que el segmento de formato sea obligatorio y no se pueda omitir, puedes proporcionar `format: true` de esta manera:

```ruby
get '*pages', to: 'pages#show', format: true
```

### Redirección

Puedes redirigir cualquier ruta a otra ruta utilizando el ayudante [`redirect`][] en tu enrutador:

```ruby
get '/stories', to: redirect('/articles')
```

También puedes reutilizar segmentos dinámicos de la coincidencia en la ruta a la que redirigir:

```ruby
get '/stories/:name', to: redirect('/articles/%{name}')
```

También puedes proporcionar un bloque a `redirect`, que recibe los parámetros de ruta simbolizados y el objeto de solicitud:

```ruby
get '/stories/:name', to: redirect { |path_params, req| "/articles/#{path_params[:name].pluralize}" }
get '/stories', to: redirect { |path_params, req| "/articles/#{req.subdomain}" }
```

Ten en cuenta que la redirección predeterminada es una redirección 301 "Movido permanentemente". Ten en cuenta que algunos navegadores web o servidores proxy pueden almacenar en caché este tipo de redirección, lo que hace que la página antigua sea inaccesible. Puedes usar la opción `:status` para cambiar el estado de respuesta:

```ruby
get '/stories/:name', to: redirect('/articles/%{name}', status: 302)
```

En todos estos casos, si no proporcionas el host principal (`http://www.example.com`), Rails tomará esos detalles de la solicitud actual.


### Enrutamiento a aplicaciones Rack

En lugar de una cadena como `'articles#index'`, que corresponde a la acción `index` en el `ArticlesController`, puedes especificar cualquier [aplicación Rack](rails_on_rack.html) como el punto final para una coincidencia:

```ruby
match '/application.js', to: MyRackApp, via: :all
```

Siempre que `MyRackApp` responda a `call` y devuelva una tupla `[status, headers, body]`, el enrutador no sabrá la diferencia entre la aplicación Rack y una acción. Este es un uso apropiado de `via: :all`, ya que querrás permitir que tu aplicación Rack maneje todos los verbos según considere apropiado.

NOTA: Para los curiosos, `'articles#index'` en realidad se expande a `ArticlesController.action(:index)`, que devuelve una aplicación Rack válida.

NOTA: Dado que los proc/lambdas son objetos que responden a `call`, puedes implementar rutas muy simples (por ejemplo, para comprobaciones de salud) en línea:<br>`get '/health', to: ->(env) { [204, {}, ['']] }`

Si especificas una aplicación Rack como el punto final para una coincidencia, recuerda que la ruta no cambiará en la aplicación receptora. Con la siguiente ruta, tu aplicación Rack debería esperar que la ruta sea `/admin`:

```ruby
match '/admin', to: AdminApp, via: :all
```

Si prefieres que tu aplicación Rack reciba las solicitudes en la ruta raíz en su lugar, utiliza [`mount`][]:

```ruby
mount AdminApp, at: '/admin'
```


### Uso de `root`

Puedes especificar a qué debe dirigir Rails `'/'` con el método [`root`][]:

```ruby
root to: 'pages#main'
root 'pages#main' # atajo para lo anterior
```

Debes colocar la ruta `root` en la parte superior del archivo, ya que es la ruta más popular y debe coincidir primero.

NOTA: La ruta `root` solo enruta las solicitudes `GET` a la acción.

También puedes usar `root` dentro de espacios de nombres y alcances. Por ejemplo:

```ruby
namespace :admin do
  root to: "admin#index"
end

root to: "home#index"
```


### Rutas de caracteres Unicode

Puedes especificar rutas de caracteres Unicode directamente. Por ejemplo:

```ruby
get 'こんにちは', to: 'welcome#index'
```

### Rutas directas

Puedes crear ayudantes de URL personalizados directamente llamando a [`direct`][]. Por ejemplo:

```ruby
direct :homepage do
  "https://rubyonrails.org"
end

# >> homepage_url
# => "https://rubyonrails.org"
```

El valor de retorno del bloque debe ser un argumento válido para el método `url_for`. Por lo tanto, puedes pasar una cadena URL válida, un Hash válido, un Array, una instancia de Active Model o una clase de Active Model.

```ruby
direct :commentable do |model|
  [ model, anchor: model.dom_id ]
end

direct :main do
  { controller: 'pages', action: 'index', subdomain: 'www' }
end
```


### Uso de `resolve`

El método [`resolve`][] permite personalizar la asignación polimórfica de modelos. Por ejemplo:

```ruby
resource :basket

resolve("Basket") { [:basket] }
```

```erb
<%= form_with model: @basket do |form| %>
  <!-- formulario de la cesta -->
<% end %>
```

Esto generará la URL singular `/basket` en lugar de la habitual `/baskets/:id`.


Personalización de rutas de recursos
------------------------------------

Si bien las rutas y ayudantes predeterminados generados por [`resources`][] generalmente te servirán bien, es posible que desees personalizarlos de alguna manera. Rails te permite personalizar prácticamente cualquier parte genérica de los ayudantes de recursos.
### Especificar un controlador a utilizar

La opción `:controller` te permite especificar explícitamente un controlador para usar en el recurso. Por ejemplo:

```ruby
resources :photos, controller: 'images'
```

reconocerá las rutas entrantes que comiencen con `/photos` pero se dirigirán al controlador `Images`:

| Verbo HTTP | Ruta             | Controlador#Acción | Helper de Ruta Nombrado |
| ---------- | ---------------- | ------------------ | ---------------------- |
| GET        | /photos          | images#index       | photos_path            |
| GET        | /photos/new      | images#new         | new_photo_path         |
| POST       | /photos          | images#create      | photos_path            |
| GET        | /photos/:id      | images#show        | photo_path(:id)        |
| GET        | /photos/:id/edit | images#edit        | edit_photo_path(:id)   |
| PATCH/PUT  | /photos/:id      | images#update      | photo_path(:id)        |
| DELETE     | /photos/:id      | images#destroy     | photo_path(:id)        |

NOTA: Utiliza `photos_path`, `new_photo_path`, etc. para generar las rutas de este recurso.

Para controladores con nombres de espacio, puedes utilizar la notación de directorio. Por ejemplo:

```ruby
resources :user_permissions, controller: 'admin/user_permissions'
```

Esto se dirigirá al controlador `Admin::UserPermissions`.

NOTA: Solo se admite la notación de directorio. Especificar el controlador con la notación de constante Ruby (por ejemplo, `controller: 'Admin::UserPermissions'`) puede causar problemas de enrutamiento y dar lugar a una advertencia.

### Especificar Restricciones

Puedes utilizar la opción `:constraints` para especificar un formato requerido en el `id` implícito. Por ejemplo:

```ruby
resources :photos, constraints: { id: /[A-Z][A-Z][0-9]+/ }
```

Esta declaración restringe el parámetro `:id` para que coincida con la expresión regular proporcionada. Por lo tanto, en este caso, el enrutador ya no coincidiría `/photos/1` con esta ruta. En cambio, `/photos/RR27` coincidiría.

Puedes especificar una restricción única para aplicar a varias rutas utilizando la forma de bloque:

```ruby
constraints(id: /[A-Z][A-Z][0-9]+/) do
  resources :photos
  resources :accounts
end
```

NOTA: Por supuesto, puedes utilizar las restricciones más avanzadas disponibles en las rutas no basadas en recursos en este contexto.

CONSEJO: Por defecto, el parámetro `:id` no acepta puntos, esto se debe a que el punto se utiliza como separador para las rutas formateadas. Si necesitas utilizar un punto dentro de un `:id`, agrega una restricción que anule esto, por ejemplo, `id: /[^\/]+/` permite cualquier cosa excepto una barra.

### Anulando los Helpers de Ruta Nombrados

La opción `:as` te permite anular el nombre normal de los helpers de ruta nombrados. Por ejemplo:

```ruby
resources :photos, as: 'images'
```

reconocerá las rutas entrantes que comiencen con `/photos` y dirigirá las solicitudes al controlador `PhotosController`, pero utilizará el valor de la opción `:as` para nombrar los helpers.

| Verbo HTTP | Ruta             | Controlador#Acción | Helper de Ruta Nombrado |
| ---------- | ---------------- | ------------------ | ---------------------- |
| GET        | /photos          | photos#index       | images_path            |
| GET        | /photos/new      | photos#new         | new_image_path         |
| POST       | /photos          | photos#create      | images_path            |
| GET        | /photos/:id      | photos#show        | image_path(:id)        |
| GET        | /photos/:id/edit | photos#edit        | edit_image_path(:id)   |
| PATCH/PUT  | /photos/:id      | photos#update      | image_path(:id)        |
| DELETE     | /photos/:id      | photos#destroy     | image_path(:id)        |

### Anulando los Segmentos `new` y `edit`

La opción `:path_names` te permite anular los segmentos `new` y `edit` generados automáticamente en las rutas:

```ruby
resources :photos, path_names: { new: 'make', edit: 'change' }
```

Esto haría que el enrutamiento reconozca rutas como:

```
/photos/make
/photos/1/change
```

NOTA: Los nombres reales de las acciones no se cambian con esta opción. Las dos rutas mostradas aún se dirigirían a las acciones `new` y `edit`.

CONSEJO: Si te encuentras queriendo cambiar esta opción de manera uniforme para todas tus rutas, puedes utilizar un scope, como se muestra a continuación:

```ruby
scope path_names: { new: 'make' } do
  # el resto de tus rutas
end
```

### Prefijar los Helpers de Ruta Nombrados

Puedes utilizar la opción `:as` para prefijar los helpers de ruta nombrados que Rails genera para una ruta. Utiliza esta opción para evitar colisiones de nombres entre rutas que utilizan un ámbito de ruta. Por ejemplo:

```ruby
scope 'admin' do
  resources :photos, as: 'admin_photos'
end

resources :photos
```

Esto cambia los helpers de ruta para `/admin/photos` de `photos_path`,
`new_photos_path`, etc. a `admin_photos_path`, `new_admin_photo_path`,
etc. Sin la adición de `as: 'admin_photos'` en el recurso con ámbito `resources :photos`, el recurso sin ámbito `resources :photos` no tendrá ningún helper de ruta.

Para prefijar un grupo de helpers de ruta, utiliza `:as` con `scope`:

```ruby
scope 'admin', as: 'admin' do
  resources :photos, :accounts
end

resources :photos, :accounts
```

Como antes, esto cambia los helpers de recursos con ámbito `/admin` a
`admin_photos_path` y `admin_accounts_path`, y permite que los recursos sin ámbito utilicen `photos_path` y `accounts_path`.
NOTA: El ámbito `namespace` agregará automáticamente los prefijos `:as`, `:module` y `:path`.

#### Ámbitos paramétricos

Puede agregar un parámetro con nombre a las rutas:

```ruby
scope ':account_id', as: 'account', constraints: { account_id: /\d+/ } do
  resources :articles
end
```

Esto proporcionará rutas como `/1/articles/9` y le permitirá hacer referencia a la parte `account_id` de la ruta como `params[:account_id]` en controladores, helpers y vistas.

También generará helpers de ruta y URL con el prefijo `account_`, a los cuales puede pasar sus objetos como se espera:

```ruby
account_article_path(@account, @article) # => /1/article/9
url_for([@account, @article])            # => /1/article/9
form_with(model: [@account, @article])   # => <form action="/1/article/9" ...>
```

Estamos [usando una restricción](#segment-constraints) para limitar el ámbito para que solo coincida con cadenas similares a ID. Puede cambiar la restricción según sus necesidades o omitirla por completo. La opción `:as` tampoco es estrictamente necesaria, pero sin ella, Rails generará un error al evaluar `url_for([@account, @article])` u otros helpers que dependen de `url_for`, como [`form_with`][].


### Restricción de las rutas creadas

Por defecto, Rails crea rutas para las siete acciones predeterminadas (`index`, `show`, `new`, `create`, `edit`, `update` y `destroy`) para cada ruta RESTful en su aplicación. Puede utilizar las opciones `:only` y `:except` para ajustar este comportamiento. La opción `:only` le indica a Rails que solo cree las rutas especificadas:

```ruby
resources :photos, only: [:index, :show]
```

Ahora, una solicitud `GET` a `/photos` tendría éxito, pero una solicitud `POST` a `/photos` (que normalmente se enrutaría a la acción `create`) fallará.

La opción `:except` especifica una ruta o lista de rutas que Rails _no_ debe crear:

```ruby
resources :photos, except: :destroy
```

En este caso, Rails creará todas las rutas normales excepto la ruta para `destroy` (una solicitud `DELETE` a `/photos/:id`).

CONSEJO: Si su aplicación tiene muchas rutas RESTful, el uso de `:only` y `:except` para generar solo las rutas que realmente necesita puede reducir el uso de memoria y acelerar el proceso de enrutamiento.

### Rutas traducidas

Usando `scope`, podemos modificar los nombres de las rutas generadas por `resources`:

```ruby
scope(path_names: { new: 'neu', edit: 'bearbeiten' }) do
  resources :categories, path: 'kategorien'
end
```

Rails ahora crea rutas para el `CategoriesController`.

| Verbo HTTP | Ruta                       | Controlador#Acción  | Helper de ruta con nombre      |
| --------- | -------------------------- | ------------------ | ----------------------- |
| GET       | /kategorien                | categories#index   | categories_path         |
| GET       | /kategorien/neu            | categories#new     | new_category_path       |
| POST      | /kategorien                | categories#create  | categories_path         |
| GET       | /kategorien/:id            | categories#show    | category_path(:id)      |
| GET       | /kategorien/:id/bearbeiten | categories#edit    | edit_category_path(:id) |
| PATCH/PUT | /kategorien/:id            | categories#update  | category_path(:id)      |
| DELETE    | /kategorien/:id            | categories#destroy | category_path(:id)      |

### Anulación de la forma singular

Si desea anular la forma singular de un recurso, debe agregar reglas adicionales al inflector a través de [`inflections`][]:

```ruby
ActiveSupport::Inflector.inflections do |inflect|
  inflect.irregular 'tooth', 'teeth'
end
```


### Uso de `:as` en recursos anidados

La opción `:as` anula el nombre generado automáticamente para el recurso en los helpers de ruta anidados. Por ejemplo:

```ruby
resources :magazines do
  resources :ads, as: 'periodical_ads'
end
```

Esto creará helpers de enrutamiento como `magazine_periodical_ads_url` y `edit_magazine_periodical_ad_path`.

### Anulación de los parámetros con nombre de la ruta

La opción `:param` anula el identificador de recurso predeterminado `:id` (nombre del [segmento dinámico](routing.html#dynamic-segments) utilizado para generar las rutas). Puede acceder a ese segmento desde su controlador utilizando `params[<:param>]`.

```ruby
resources :videos, param: :identifier
```

```
    videos GET  /videos(.:format)                  videos#index
           POST /videos(.:format)                  videos#create
 new_video GET  /videos/new(.:format)              videos#new
edit_video GET  /videos/:identifier/edit(.:format) videos#edit
```

```ruby
Video.find_by(identifier: params[:identifier])
```

Puede anular `ActiveRecord::Base#to_param` del modelo asociado para construir una URL:

```ruby
class Video < ApplicationRecord
  def to_param
    identifier
  end
end
```

```ruby
video = Video.find_by(identifier: "Roman-Holiday")
edit_video_path(video) # => "/videos/Roman-Holiday/edit"
```

Dividir un archivo de rutas *muy* grande en varios archivos pequeños
-------------------------------------------------------

Si trabaja en una aplicación grande con miles de rutas, un único archivo `config/routes.rb` puede volverse engorroso y difícil de leer.

Rails ofrece una forma de dividir un archivo `routes.rb` gigantesco en varios archivos pequeños utilizando la macro [`draw`][].

Podría tener un archivo de ruta `admin.rb` que contenga todas las rutas para el área de administración, otro archivo `api.rb` para los recursos relacionados con la API, etc.

```ruby
# config/routes.rb

Rails.application.routes.draw do
  get 'foo', to: 'foo#bar'

  draw(:admin) # Cargará otro archivo de ruta ubicado en `config/routes/admin.rb`
end
```
```ruby
# config/routes/admin.rb

namespace :admin do
  resources :comments
end
```

Llamar a `draw(:admin)` dentro del bloque `Rails.application.routes.draw` intentará cargar un archivo de ruta
que tenga el mismo nombre que el argumento dado (`admin.rb` en este ejemplo).
El archivo debe estar ubicado dentro del directorio `config/routes` o cualquier subdirectorio (por ejemplo, `config/routes/admin.rb` o `config/routes/external/admin.rb`).

Puede utilizar el DSL de enrutamiento normal dentro del archivo de enrutamiento `admin.rb`, pero **no** debe rodearlo con el bloque `Rails.application.routes.draw` como lo hizo en el archivo principal `config/routes.rb`.


### No utilice esta función a menos que realmente la necesite

Tener varios archivos de enrutamiento dificulta la capacidad de descubrimiento y comprensión. Para la mayoría de las aplicaciones, incluso aquellas con cientos de rutas, es más fácil para los desarrolladores tener un solo archivo de enrutamiento. El DSL de enrutamiento de Rails ya ofrece una forma de dividir las rutas de manera organizada con `namespace` y `scope`.


Inspección y prueba de rutas
-----------------------------

Rails ofrece herramientas para inspeccionar y probar sus rutas.

### Listar las rutas existentes

Para obtener una lista completa de las rutas disponibles en su aplicación, visite <http://localhost:3000/rails/info/routes> en su navegador mientras su servidor se esté ejecutando en el entorno **development**. También puede ejecutar el comando `bin/rails routes` en su terminal para obtener la misma salida.

Ambos métodos listarán todas sus rutas, en el mismo orden en que aparecen en `config/routes.rb`. Para cada ruta, verá:

* El nombre de la ruta (si tiene alguno)
* El verbo HTTP utilizado (si la ruta no responde a todos los verbos)
* El patrón de URL a coincidir
* Los parámetros de enrutamiento para la ruta

Por ejemplo, aquí hay una pequeña sección de la salida de `bin/rails routes` para una ruta RESTful:

```
    users GET    /users(.:format)          users#index
          POST   /users(.:format)          users#create
 new_user GET    /users/new(.:format)      users#new
edit_user GET    /users/:id/edit(.:format) users#edit
```

También puede usar la opción `--expanded` para activar el modo de formato de tabla expandido.

```bash
$ bin/rails routes --expanded

--[ Ruta 1 ]----------------------------------------------------
Prefijo            | users
Verbo              | GET
URI               | /users(.:format)
Controlador#Acción | users#index
--[ Ruta 2 ]----------------------------------------------------
Prefijo            |
Verbo              | POST
URI               | /users(.:format)
Controlador#Acción | users#create
--[ Ruta 3 ]----------------------------------------------------
Prefijo            | new_user
Verbo              | GET
URI               | /users/new(.:format)
Controlador#Acción | users#new
--[ Ruta 4 ]----------------------------------------------------
Prefijo            | edit_user
Verbo              | GET
URI               | /users/:id/edit(.:format)
Controlador#Acción | users#edit
```

Puede buscar en sus rutas con la opción grep: -g. Esto muestra cualquier ruta que coincida parcialmente con el nombre del método auxiliar de URL, el verbo HTTP o la ruta URL.

```bash
$ bin/rails routes -g new_comment
$ bin/rails routes -g POST
$ bin/rails routes -g admin
```

Si solo desea ver las rutas que se asignan a un controlador específico, existe la opción -c.

```bash
$ bin/rails routes -c users
$ bin/rails routes -c admin/users
$ bin/rails routes -c Comments
$ bin/rails routes -c Articles::CommentsController
```

CONSEJO: Encontrará que la salida de `bin/rails routes` es mucho más legible si amplía la ventana de su terminal hasta que las líneas de salida no se envuelvan.

### Prueba de rutas

Las rutas deben incluirse en su estrategia de pruebas (como el resto de su aplicación). Rails ofrece tres aserciones incorporadas diseñadas para facilitar las pruebas de rutas:

* [`assert_generates`][]
* [`assert_recognizes`][]
* [`assert_routing`][]


#### La aserción `assert_generates`

[`assert_generates`][] afirma que un conjunto particular de opciones genera una ruta particular y se puede utilizar con rutas predeterminadas o rutas personalizadas. Por ejemplo:

```ruby
assert_generates '/photos/1', { controller: 'photos', action: 'show', id: '1' }
assert_generates '/about', controller: 'pages', action: 'about'
```

#### La aserción `assert_recognizes`

[`assert_recognizes`][] es el inverso de `assert_generates`. Asegura que se reconozca una ruta dada y la enrutará a un lugar específico en su aplicación. Por ejemplo:

```ruby
assert_recognizes({ controller: 'photos', action: 'show', id: '1' }, '/photos/1')
```

Puede proporcionar un argumento `:method` para especificar el verbo HTTP:

```ruby
assert_recognizes({ controller: 'photos', action: 'create' }, { path: 'photos', method: :post })
```

#### La aserción `assert_routing`

La aserción [`assert_routing`][] verifica la ruta en ambos sentidos: prueba que la ruta genera las opciones y que las opciones generan la ruta. Por lo tanto, combina las funciones de `assert_generates` y `assert_recognizes`:

```ruby
assert_routing({ path: 'photos', method: :post }, { controller: 'photos', action: 'create' })
```

[`resources`]: https://api.rubyonrails.org/classes/ActionDispatch/Routing/Mapper/Resources.html#method-i-resources
[`namespace`]: https://api.rubyonrails.org/classes/ActionDispatch/Routing/Mapper/Scoping.html#method-i-namespace
[`scope`]: https://api.rubyonrails.org/classes/ActionDispatch/Routing/Mapper/Scoping.html#method-i-scope
[`shallow`]: https://api.rubyonrails.org/classes/ActionDispatch/Routing/Mapper/Resources.html#method-i-shallow
[`concern`]: https://api.rubyonrails.org/classes/ActionDispatch/Routing/Mapper/Concerns.html#method-i-concern
[`concerns`]: https://api.rubyonrails.org/classes/ActionDispatch/Routing/Mapper/Concerns.html#method-i-concerns
[ActionView::RoutingUrlFor#url_for]: https://api.rubyonrails.org/classes/ActionView/RoutingUrlFor.html#method-i-url_for
[`delete`]: https://api.rubyonrails.org/classes/ActionDispatch/Routing/Mapper/HttpHelpers.html#method-i-delete
[`get`]: https://api.rubyonrails.org/classes/ActionDispatch/Routing/Mapper/HttpHelpers.html#method-i-get
[`member`]: https://api.rubyonrails.org/classes/ActionDispatch/Routing/Mapper/Resources.html#method-i-member
[`patch`]: https://api.rubyonrails.org/classes/ActionDispatch/Routing/Mapper/HttpHelpers.html#method-i-patch
[`post`]: https://api.rubyonrails.org/classes/ActionDispatch/Routing/Mapper/HttpHelpers.html#method-i-post
[`put`]: https://api.rubyonrails.org/classes/ActionDispatch/Routing/Mapper/HttpHelpers.html#method-i-put
[`put`]: https://api.rubyonrails.org/classes/ActionDispatch/Routing/Mapper/HttpHelpers.html#method-i-put
[`collection`]: https://api.rubyonrails.org/classes/ActionDispatch/Routing/Mapper/Resources.html#method-i-collection
[`defaults`]: https://api.rubyonrails.org/classes/ActionDispatch/Routing/Mapper/Scoping.html#method-i-defaults
[`match`]: https://api.rubyonrails.org/classes/ActionDispatch/Routing/Mapper/Base.html#method-i-match
[`constraints`]: https://api.rubyonrails.org/classes/ActionDispatch/Routing/Mapper/Scoping.html#method-i-constraints
[`redirect`]: https://api.rubyonrails.org/classes/ActionDispatch/Routing/Redirection.html#method-i-redirect
[`mount`]: https://api.rubyonrails.org/classes/ActionDispatch/Routing/Mapper/Base.html#method-i-mount
[`root`]: https://api.rubyonrails.org/classes/ActionDispatch/Routing/Mapper/Resources.html#method-i-root
[`direct`]: https://api.rubyonrails.org/classes/ActionDispatch/Routing/Mapper/CustomUrls.html#method-i-direct
[`resolve`]: https://api.rubyonrails.org/classes/ActionDispatch/Routing/Mapper/CustomUrls.html#method-i-resolve
[`form_with`]: https://api.rubyonrails.org/classes/ActionView/Helpers/FormHelper.html#method-i-form_with
[`inflections`]: https://api.rubyonrails.org/classes/ActiveSupport/Inflector.html#method-i-inflections
[`draw`]: https://api.rubyonrails.org/classes/ActionDispatch/Routing/Mapper/Resources.html#method-i-draw
[`assert_generates`]: https://api.rubyonrails.org/classes/ActionDispatch/Assertions/RoutingAssertions.html#method-i-assert_generates
[`assert_recognizes`]: https://api.rubyonrails.org/classes/ActionDispatch/Assertions/RoutingAssertions.html#method-i-assert_recognizes
[`assert_routing`]: https://api.rubyonrails.org/classes/ActionDispatch/Assertions/RoutingAssertions.html#method-i-assert_routing
