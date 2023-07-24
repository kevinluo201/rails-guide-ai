**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: fb66c6f4aafffdb8f8d44e8a2076c9b0
Rails Routing de l'extérieur vers l'intérieur
===============================================

Ce guide couvre les fonctionnalités de routage de Rails accessibles aux utilisateurs.

Après avoir lu ce guide, vous saurez :

* Comment interpréter le code dans `config/routes.rb`.
* Comment construire vos propres routes, en utilisant soit le style de ressource préféré, soit la méthode `match`.
* Comment déclarer des paramètres de route, qui sont transmis aux actions du contrôleur.
* Comment créer automatiquement des chemins et des URL en utilisant les assistants de routage.
* Techniques avancées telles que la création de contraintes et le montage de points d'extrémité Rack.

--------------------------------------------------------------------------------

Le but du routeur de Rails
--------------------------

Le routeur de Rails reconnaît les URL et les envoie vers une action du contrôleur ou vers une application Rack. Il peut également générer des chemins et des URL, évitant ainsi la nécessité de coder en dur des chaînes dans vos vues.

### Connecter les URL au code

Lorsque votre application Rails reçoit une requête entrante pour :

```
GET /patients/17
```

elle demande au routeur de l'associer à une action du contrôleur. Si la première route correspondante est :

```ruby
get '/patients/:id', to: 'patients#show'
```

la requête est envoyée à l'action `show` du contrôleur `patients` avec `{ id: '17' }` dans `params`.

NOTE : Rails utilise snake_case pour les noms de contrôleur ici, si vous avez un contrôleur à plusieurs mots comme `MonsterTrucksController`, vous devez utiliser `monster_trucks#show` par exemple.

### Générer des chemins et des URL à partir du code

Vous pouvez également générer des chemins et des URL. Si la route ci-dessus est modifiée comme suit :

```ruby
get '/patients/:id', to: 'patients#show', as: 'patient'
```

et que votre application contient ce code dans le contrôleur :

```ruby
@patient = Patient.find(params[:id])
```

et ceci dans la vue correspondante :

```erb
<%= link_to 'Dossier du patient', patient_path(@patient) %>
```

alors le routeur générera le chemin `/patients/17`. Cela réduit la fragilité de votre vue et rend votre code plus facile à comprendre. Notez que l'identifiant n'a pas besoin d'être spécifié dans l'assistant de route.

### Configuration du routeur de Rails

Les routes de votre application ou de votre moteur se trouvent dans le fichier `config/routes.rb` et ressemblent généralement à ceci :

```ruby
Rails.application.routes.draw do
  resources :brands, only: [:index, :show] do
    resources :products, only: [:index, :show]
  end

  resource :basket, only: [:show, :update, :destroy]

  resolve("Basket") { route_for(:basket) }
end
```

Comme il s'agit d'un fichier source Ruby classique, vous pouvez utiliser toutes ses fonctionnalités pour vous aider à définir vos routes, mais faites attention aux noms de variables car ils peuvent entrer en conflit avec les méthodes DSL du routeur.

NOTE : Le bloc `Rails.application.routes.draw do ... end` qui enveloppe vos définitions de routes est nécessaire pour établir la portée du DSL du routeur et ne doit pas être supprimé.

Routage des ressources : la valeur par défaut de Rails
------------------------------------------------------

Le routage des ressources vous permet de déclarer rapidement toutes les routes courantes pour un contrôleur de ressources donné. Un seul appel à [`resources`][] peut déclarer toutes les routes nécessaires pour vos actions `index`, `show`, `new`, `edit`, `create`, `update` et `destroy`.


### Ressources sur le Web

Les navigateurs demandent des pages à Rails en faisant une requête pour une URL en utilisant une méthode HTTP spécifique, telle que `GET`, `POST`, `PATCH`, `PUT` et `DELETE`. Chaque méthode est une demande d'effectuer une opération sur la ressource. Une route de ressource associe un certain nombre de requêtes liées à des actions dans un seul contrôleur.

Lorsque votre application Rails reçoit une requête entrante pour :

```
DELETE /photos/17
```

elle demande au routeur de l'associer à une action du contrôleur. Si la première route correspondante est :

```ruby
resources :photos
```

Rails enverrait cette requête à l'action `destroy` du contrôleur `photos` avec `{ id: '17' }` dans `params`.

### CRUD, Verbes et Actions

Dans Rails, une route de ressource fournit une correspondance entre les verbes HTTP et les URL vers des actions de contrôleur. Par convention, chaque action est également associée à une opération CRUD spécifique dans une base de données. Une seule entrée dans le fichier de routage, telle que :

```ruby
resources :photos
```

crée sept routes différentes dans votre application, toutes mappées sur le contrôleur `Photos` :

| Verbe HTTP | Chemin            | Contrôleur#Action | Utilisé pour                                  |
| ---------- | ----------------- | ----------------- | --------------------------------------------- |
| GET        | /photos           | photos#index      | afficher une liste de toutes les photos        |
| GET        | /photos/new       | photos#new        | renvoyer un formulaire HTML pour créer une nouvelle photo |
| POST       | /photos           | photos#create     | créer une nouvelle photo                      |
| GET        | /photos/:id       | photos#show       | afficher une photo spécifique                 |
| GET        | /photos/:id/edit  | photos#edit       | renvoyer un formulaire HTML pour modifier une photo |
| PATCH/PUT  | /photos/:id       | photos#update     | mettre à jour une photo spécifique            |
| DELETE     | /photos/:id       | photos#destroy    | supprimer une photo spécifique                |
NOTE : Étant donné que le routeur utilise la méthode HTTP et l'URL pour faire correspondre les requêtes entrantes, quatre URL correspondent à sept actions différentes.

NOTE : Les routes Rails sont associées dans l'ordre où elles sont spécifiées, donc si vous avez une ligne `resources :photos` au-dessus d'un `get 'photos/poll'`, la route de l'action `show` pour la ligne `resources` sera associée avant la ligne `get`. Pour corriger cela, déplacez la ligne `get` **au-dessus** de la ligne `resources` afin qu'elle soit associée en premier.

### Aide pour les chemins et les URL

La création d'une route de ressource expose également un certain nombre d'aides aux contrôleurs de votre application. Dans le cas de `resources :photos` :

* `photos_path` renvoie `/photos`
* `new_photo_path` renvoie `/photos/new`
* `edit_photo_path(:id)` renvoie `/photos/:id/edit` (par exemple, `edit_photo_path(10)` renvoie `/photos/10/edit`)
* `photo_path(:id)` renvoie `/photos/:id` (par exemple, `photo_path(10)` renvoie `/photos/10`)

Chacune de ces aides a une aide correspondante `_url` (comme `photos_url`) qui renvoie le même chemin précédé de l'hôte, du port et du préfixe de chemin actuels.

CONSEIL : Pour trouver les noms des aides de route pour vos routes, voir [Listing existing routes](#listing-existing-routes) ci-dessous.

### Définition de plusieurs ressources en même temps

Si vous avez besoin de créer des routes pour plus d'une ressource, vous pouvez économiser un peu de frappe en les définissant toutes avec un seul appel à `resources` :

```ruby
resources :photos, :books, :videos
```

Cela fonctionne exactement de la même manière que :

```ruby
resources :photos
resources :books
resources :videos
```

### Ressources singulières

Parfois, vous avez une ressource que les clients recherchent toujours sans référencer un ID. Par exemple, vous souhaitez que `/profile` affiche toujours le profil de l'utilisateur actuellement connecté. Dans ce cas, vous pouvez utiliser une ressource singulière pour faire correspondre `/profile` (plutôt que `/profile/:id`) à l'action `show` :

```ruby
get 'profile', to: 'users#show'
```

Le fait de passer une `String` à `to:` attend un format `controller#action`. Lorsque vous utilisez un `Symbol`, l'option `to:` doit être remplacée par `action:`. Lorsque vous utilisez une `String` sans `#`, l'option `to:` doit être remplacée par `controller:` :

```ruby
get 'profile', action: :show, controller: 'users'
```

Cette route de ressource :

```ruby
resource :geocoder
resolve('Geocoder') { [:geocoder] }
```

crée six routes différentes dans votre application, toutes mappées sur le contrôleur `Geocoders` :

| Méthode HTTP | Chemin                | Contrôleur#Action | Utilisé pour                                   |
| ------------ | --------------------- | ----------------- | ---------------------------------------------- |
| GET          | /geocoder/new         | geocoders#new     | renvoie un formulaire HTML pour créer le géocodeur |
| POST         | /geocoder             | geocoders#create  | crée le nouveau géocodeur                       |
| GET          | /geocoder             | geocoders#show    | affiche la ressource unique du géocodeur        |
| GET          | /geocoder/edit        | geocoders#edit    | renvoie un formulaire HTML pour modifier le géocodeur |
| PATCH/PUT    | /geocoder             | geocoders#update  | met à jour la ressource unique du géocodeur     |
| DELETE       | /geocoder             | geocoders#destroy | supprime la ressource du géocodeur              |

NOTE : Étant donné que vous pouvez vouloir utiliser le même contrôleur pour une route singulière (`/account`) et une route plurielle (`/accounts/45`), les ressources singulières sont mappées sur des contrôleurs pluriels. Ainsi, par exemple, `resource :photo` et `resources :photos` créent à la fois des routes singulières et plurielles qui sont mappées sur le même contrôleur (`PhotosController`).

Une route de ressource singulière génère ces aides :

* `new_geocoder_path` renvoie `/geocoder/new`
* `edit_geocoder_path` renvoie `/geocoder/edit`
* `geocoder_path` renvoie `/geocoder`

NOTE : L'appel à `resolve` est nécessaire pour convertir les instances de `Geocoder` en routes via [l'identification des enregistrements](form_helpers.html#relying-on-record-identification).

Comme pour les ressources plurielles, les mêmes aides se terminant par `_url` incluront également l'hôte, le port et le préfixe de chemin.

### Espaces de noms des contrôleurs et routage

Vous pouvez souhaiter organiser des groupes de contrôleurs sous un espace de noms. Le plus souvent, vous regroupez un certain nombre de contrôleurs d'administration sous un espace de noms `Admin::` et placez ces contrôleurs sous le répertoire `app/controllers/admin`. Vous pouvez router vers un tel groupe en utilisant un bloc [`namespace`][] :

```ruby
namespace :admin do
  resources :articles, :comments
end
```

Cela créera un certain nombre de routes pour chacun des contrôleurs `articles` et `comments`. Pour `Admin::ArticlesController`, Rails créera :

| Méthode HTTP | Chemin                      | Contrôleur#Action       | Aide de route nommée            |
| ------------ | --------------------------- | ----------------------- | ------------------------------- |
| GET          | /admin/articles             | admin/articles#index    | admin_articles_path            |
| GET          | /admin/articles/new         | admin/articles#new      | new_admin_article_path         |
| POST         | /admin/articles             | admin/articles#create   | admin_articles_path            |
| GET          | /admin/articles/:id         | admin/articles#show     | admin_article_path(:id)        |
| GET          | /admin/articles/:id/edit    | admin/articles#edit     | edit_admin_article_path(:id)   |
| PATCH/PUT    | /admin/articles/:id         | admin/articles#update   | admin_article_path(:id)        |
| DELETE       | /admin/articles/:id         | admin/articles#destroy  | admin_article_path(:id)        |
Si vous souhaitez plutôt router `/articles` (sans le préfixe `/admin`) vers `Admin::ArticlesController`, vous pouvez spécifier le module avec un bloc [`scope`][] :

```ruby
scope module: 'admin' do
  resources :articles, :comments
end
```

Cela peut également être fait pour une seule route :

```ruby
resources :articles, module: 'admin'
```

Si vous souhaitez plutôt router `/admin/articles` vers `ArticlesController` (sans le préfixe du module `Admin::`), vous pouvez spécifier le chemin avec un bloc `scope` :

```ruby
scope '/admin' do
  resources :articles, :comments
end
```

Cela peut également être fait pour une seule route :

```ruby
resources :articles, path: '/admin/articles'
```

Dans ces deux cas, les helpers de route nommés restent les mêmes que si vous n'utilisiez pas `scope`. Dans le dernier cas, les chemins suivants sont mappés vers `ArticlesController` :

| Verbe HTTP | Chemin                   | Contrôleur#Action    | Helper de route nommé |
| --------- | ------------------------ | -------------------- | ---------------------- |
| GET       | /admin/articles          | articles#index       | articles_path          |
| GET       | /admin/articles/new      | articles#new         | new_article_path       |
| POST      | /admin/articles          | articles#create      | articles_path          |
| GET       | /admin/articles/:id      | articles#show        | article_path(:id)      |
| GET       | /admin/articles/:id/edit | articles#edit        | edit_article_path(:id) |
| PATCH/PUT | /admin/articles/:id      | articles#update      | article_path(:id)      |
| DELETE    | /admin/articles/:id      | articles#destroy     | article_path(:id)      |

CONSEIL : Si vous avez besoin d'utiliser un espace de noms de contrôleur différent à l'intérieur d'un bloc `namespace`, vous pouvez spécifier un chemin de contrôleur absolu, par exemple : `get '/foo', to: '/foo#index'`.


### Ressources imbriquées

Il est courant d'avoir des ressources qui sont logiquement des enfants d'autres ressources. Par exemple, supposons que votre application inclut ces modèles :

```ruby
class Magazine < ApplicationRecord
  has_many :ads
end

class Ad < ApplicationRecord
  belongs_to :magazine
end
```

Les routes imbriquées vous permettent de capturer cette relation dans votre routage. Dans ce cas, vous pourriez inclure cette déclaration de route :

```ruby
resources :magazines do
  resources :ads
end
```

En plus des routes pour les magazines, cette déclaration routera également les annonces vers un `AdsController`. Les URLs des annonces nécessitent un magazine :

| Verbe HTTP | Chemin                                 | Contrôleur#Action | Utilisé pour                                                                |
| --------- | -------------------------------------- | ----------------- | -------------------------------------------------------------------------- |
| GET       | /magazines/:magazine_id/ads            | ads#index         | afficher une liste de toutes les annonces pour un magazine spécifique       |
| GET       | /magazines/:magazine_id/ads/new        | ads#new           | renvoyer un formulaire HTML pour créer une nouvelle annonce appartenant à un magazine spécifique |
| POST      | /magazines/:magazine_id/ads            | ads#create        | créer une nouvelle annonce appartenant à un magazine spécifique            |
| GET       | /magazines/:magazine_id/ads/:id        | ads#show          | afficher une annonce spécifique appartenant à un magazine spécifique       |
| GET       | /magazines/:magazine_id/ads/:id/edit   | ads#edit          | renvoyer un formulaire HTML pour modifier une annonce appartenant à un magazine spécifique |
| PATCH/PUT | /magazines/:magazine_id/ads/:id        | ads#update        | mettre à jour une annonce spécifique appartenant à un magazine spécifique   |
| DELETE    | /magazines/:magazine_id/ads/:id        | ads#destroy       | supprimer une annonce spécifique appartenant à un magazine spécifique       |

Cela créera également des helpers de routage tels que `magazine_ads_url` et `edit_magazine_ad_path`. Ces helpers prennent une instance de Magazine en premier paramètre (`magazine_ads_url(@magazine)`).

#### Limites de l'imbrication

Vous pouvez imbriquer des ressources dans d'autres ressources imbriquées si vous le souhaitez. Par exemple :

```ruby
resources :publishers do
  resources :magazines do
    resources :photos
  end
end
```

Les ressources profondément imbriquées deviennent rapidement fastidieuses. Dans ce cas, par exemple, l'application reconnaîtrait des chemins tels que :

```
/publishers/1/magazines/2/photos/3
```

Le helper de route correspondant serait `publisher_magazine_photo_url`, ce qui vous obligerait à spécifier des objets aux trois niveaux. En effet, cette situation est assez confuse pour qu'un [article populaire de Jamis Buck](http://weblog.jamisbuck.org/2007/2/5/nesting-resources) propose une règle de base pour une bonne conception Rails :

CONSEIL : Les ressources ne doivent jamais être imbriquées à plus d'un niveau de profondeur.

#### Imbrication superficielle

Une façon d'éviter l'imbrication profonde (comme recommandé ci-dessus) consiste à générer les actions de collection sous la portée du parent, de manière à avoir une idée de la hiérarchie, mais à ne pas imbriquer les actions des membres. En d'autres termes, construire uniquement des routes avec le minimum d'informations pour identifier de manière unique la ressource, comme ceci :

```ruby
resources :articles do
  resources :comments, only: [:index, :new, :create]
end
resources :comments, only: [:show, :edit, :update, :destroy]
```

Cette idée trouve un équilibre entre des routes descriptives et une imbrication profonde. Il existe une syntaxe abrégée pour y parvenir, via l'option `:shallow` :

```ruby
resources :articles do
  resources :comments, shallow: true
end
```
Cela générera exactement les mêmes routes que le premier exemple. Vous pouvez également spécifier l'option `:shallow` dans la ressource parent, auquel cas toutes les ressources imbriquées seront superficielles :

```ruby
resources :articles, shallow: true do
  resources :comments
  resources :quotes
  resources :drafts
end
```

La ressource articles aura les routes suivantes générées pour elle :

| Verbe HTTP | Chemin                                         | Contrôleur#Action | Aide à la route nommée       |
| --------- | -------------------------------------------- | ----------------- | ------------------------ |
| GET       | /articles/:article_id/comments(.:format)     | comments#index    | article_comments_path    |
| POST      | /articles/:article_id/comments(.:format)     | comments#create   | article_comments_path    |
| GET       | /articles/:article_id/comments/new(.:format) | comments#new      | new_article_comment_path |
| GET       | /comments/:id/edit(.:format)                 | comments#edit     | edit_comment_path        |
| GET       | /comments/:id(.:format)                      | comments#show     | comment_path             |
| PATCH/PUT | /comments/:id(.:format)                      | comments#update   | comment_path             |
| DELETE    | /comments/:id(.:format)                      | comments#destroy  | comment_path             |
| GET       | /articles/:article_id/quotes(.:format)       | quotes#index      | article_quotes_path      |
| POST      | /articles/:article_id/quotes(.:format)       | quotes#create     | article_quotes_path      |
| GET       | /articles/:article_id/quotes/new(.:format)   | quotes#new        | new_article_quote_path   |
| GET       | /quotes/:id/edit(.:format)                   | quotes#edit       | edit_quote_path          |
| GET       | /quotes/:id(.:format)                        | quotes#show       | quote_path               |
| PATCH/PUT | /quotes/:id(.:format)                        | quotes#update     | quote_path               |
| DELETE    | /quotes/:id(.:format)                        | quotes#destroy    | quote_path               |
| GET       | /articles/:article_id/drafts(.:format)       | drafts#index      | article_drafts_path      |
| POST      | /articles/:article_id/drafts(.:format)       | drafts#create     | article_drafts_path      |
| GET       | /articles/:article_id/drafts/new(.:format)   | drafts#new        | new_article_draft_path   |
| GET       | /drafts/:id/edit(.:format)                   | drafts#edit       | edit_draft_path          |
| GET       | /drafts/:id(.:format)                        | drafts#show       | draft_path               |
| PATCH/PUT | /drafts/:id(.:format)                        | drafts#update     | draft_path               |
| DELETE    | /drafts/:id(.:format)                        | drafts#destroy    | draft_path               |
| GET       | /articles(.:format)                          | articles#index    | articles_path            |
| POST      | /articles(.:format)                          | articles#create   | articles_path            |
| GET       | /articles/new(.:format)                      | articles#new      | new_article_path         |
| GET       | /articles/:id/edit(.:format)                 | articles#edit     | edit_article_path        |
| GET       | /articles/:id(.:format)                      | articles#show     | article_path             |
| PATCH/PUT | /articles/:id(.:format)                      | articles#update   | article_path             |
| DELETE    | /articles/:id(.:format)                      | articles#destroy  | article_path             |

La méthode [`shallow`][] de la DSL crée une portée à l'intérieur de laquelle chaque imbrication est superficielle. Cela génère les mêmes routes que l'exemple précédent :

```ruby
shallow do
  resources :articles do
    resources :comments
    resources :quotes
    resources :drafts
  end
end
```

Il existe deux options pour `scope` pour personnaliser les routes superficielles. `:shallow_path` préfixe les chemins des membres avec le paramètre spécifié :

```ruby
scope shallow_path: "sekret" do
  resources :articles do
    resources :comments, shallow: true
  end
end
```

La ressource comments aura les routes suivantes générées pour elle :

| Verbe HTTP | Chemin                                         | Contrôleur#Action | Aide à la route nommée       |
| --------- | -------------------------------------------- | ----------------- | ------------------------ |
| GET       | /articles/:article_id/comments(.:format)     | comments#index    | article_comments_path    |
| POST      | /articles/:article_id/comments(.:format)     | comments#create   | article_comments_path    |
| GET       | /articles/:article_id/comments/new(.:format) | comments#new      | new_article_comment_path |
| GET       | /sekret/comments/:id/edit(.:format)          | comments#edit     | edit_comment_path        |
| GET       | /sekret/comments/:id(.:format)               | comments#show     | comment_path             |
| PATCH/PUT | /sekret/comments/:id(.:format)               | comments#update   | comment_path             |
| DELETE    | /sekret/comments/:id(.:format)               | comments#destroy  | comment_path             |

L'option `:shallow_prefix` ajoute le paramètre spécifié aux aides de route nommées :

```ruby
scope shallow_prefix: "sekret" do
  resources :articles do
    resources :comments, shallow: true
  end
end
```

La ressource comments aura les routes suivantes générées pour elle :

| Verbe HTTP | Chemin                                         | Contrôleur#Action | Aide à la route nommée          |
| --------- | -------------------------------------------- | ----------------- | --------------------------- |
| GET       | /articles/:article_id/comments(.:format)     | comments#index    | article_comments_path       |
| POST      | /articles/:article_id/comments(.:format)     | comments#create   | article_comments_path       |
| GET       | /articles/:article_id/comments/new(.:format) | comments#new      | new_article_comment_path    |
| GET       | /comments/:id/edit(.:format)                 | comments#edit     | edit_sekret_comment_path    |
| GET       | /comments/:id(.:format)                      | comments#show     | sekret_comment_path         |
| PATCH/PUT | /comments/:id(.:format)                      | comments#update   | sekret_comment_path         |
| DELETE    | /comments/:id(.:format)                      | comments#destroy  | sekret_comment_path         |


### Préoccupations de routage

Les préoccupations de routage vous permettent de déclarer des routes communes qui peuvent être réutilisées dans d'autres ressources et routes. Pour définir une préoccupation, utilisez un bloc [`concern`][] :

```ruby
concern :commentable do
  resources :comments
end

concern :image_attachable do
  resources :images, only: :index
end
```

Ces préoccupations peuvent être utilisées dans les ressources pour éviter la duplication de code et partager le comportement entre les routes :

```ruby
resources :messages, concerns: :commentable

resources :articles, concerns: [:commentable, :image_attachable]
```

Ce qui précède est équivalent à :

```ruby
resources :messages do
  resources :comments
end

resources :articles do
  resources :comments
  resources :images, only: :index
end
```
Vous pouvez également les utiliser n'importe où en appelant [`concerns`][]. Par exemple, dans un bloc `scope` ou `namespace` :

```ruby
namespace :articles do
  concerns :commentable
end
```


### Création de chemins et d'URL à partir d'objets

En plus d'utiliser les helpers de routage, Rails peut également créer des chemins et des URL à partir d'un tableau de paramètres. Par exemple, supposons que vous ayez cet ensemble de routes :

```ruby
resources :magazines do
  resources :ads
end
```

Lorsque vous utilisez `magazine_ad_path`, vous pouvez passer des instances de `Magazine` et `Ad` au lieu des identifiants numériques :

```erb
<%= link_to 'Détails de l'annonce', magazine_ad_path(@magazine, @ad) %>
```

Vous pouvez également utiliser [`url_for`][ActionView::RoutingUrlFor#url_for] avec un ensemble d'objets, et Rails déterminera automatiquement quelle route vous souhaitez :

```erb
<%= link_to 'Détails de l'annonce', url_for([@magazine, @ad]) %>
```

Dans ce cas, Rails verra que `@magazine` est un `Magazine` et `@ad` est un `Ad` et utilisera donc l'helper `magazine_ad_path`. Dans les helpers comme `link_to`, vous pouvez spécifier simplement l'objet à la place de l'appel complet à `url_for` :

```erb
<%= link_to 'Détails de l'annonce', [@magazine, @ad] %>
```

Si vous souhaitez créer un lien vers un magazine uniquement :

```erb
<%= link_to 'Détails du magazine', @magazine %>
```

Pour les autres actions, vous devez simplement insérer le nom de l'action en tant que premier élément du tableau :

```erb
<%= link_to 'Modifier l'annonce', [:edit, @magazine, @ad] %>
```

Cela vous permet de traiter les instances de vos modèles comme des URL, et constitue un avantage clé de l'utilisation du style ressource.


### Ajout de plus d'actions RESTful

Vous n'êtes pas limité aux sept routes que le routage RESTful crée par défaut. Si vous le souhaitez, vous pouvez ajouter des routes supplémentaires qui s'appliquent à la collection ou aux membres individuels de la collection.

#### Ajout de routes membres

Pour ajouter une route membre, ajoutez simplement un bloc [`member`][] dans le bloc de la ressource :

```ruby
resources :photos do
  member do
    get 'preview'
  end
end
```

Cela reconnaîtra `/photos/1/preview` avec GET, et routera vers l'action `preview` de `PhotosController`, avec la valeur de l'identifiant de la ressource passée dans `params[:id]`. Il créera également les helpers `preview_photo_url` et `preview_photo_path`.

Dans le bloc des routes membres, chaque nom de route spécifie la méthode HTTP qui sera reconnue. Vous pouvez utiliser [`get`][], [`patch`][], [`put`][], [`post`][], ou [`delete`][] ici. Si vous n'avez pas plusieurs routes `member`, vous pouvez également passer `:on` à une route, en éliminant le bloc :

```ruby
resources :photos do
  get 'preview', on: :member
end
```

Vous pouvez omettre l'option `:on`, cela créera la même route membre à l'exception de la valeur de l'identifiant de la ressource qui sera disponible dans `params[:photo_id]` au lieu de `params[:id]`. Les helpers de route seront également renommés de `preview_photo_url` et `preview_photo_path` en `photo_preview_url` et `photo_preview_path`.


#### Ajout de routes de collection

Pour ajouter une route à la collection, utilisez un bloc [`collection`][] :

```ruby
resources :photos do
  collection do
    get 'search'
  end
end
```

Cela permettra à Rails de reconnaître des chemins tels que `/photos/search` avec GET, et routera vers l'action `search` de `PhotosController`. Il créera également les helpers de route `search_photos_url` et `search_photos_path`.

Tout comme avec les routes membres, vous pouvez passer `:on` à une route :

```ruby
resources :photos do
  get 'search', on: :collection
end
```

NOTE : Si vous définissez des routes de ressource supplémentaires avec un symbole en tant que premier argument positionnel, soyez conscient que ce n'est pas équivalent à utiliser une chaîne de caractères. Les symboles infèrent les actions du contrôleur tandis que les chaînes infèrent les chemins.


#### Ajout de routes pour des actions nouvelles supplémentaires

Pour ajouter une action nouvelle alternative en utilisant le raccourci `:on` :

```ruby
resources :comments do
  get 'preview', on: :new
end
```

Cela permettra à Rails de reconnaître des chemins tels que `/comments/new/preview` avec GET, et routera vers l'action `preview` de `CommentsController`. Il créera également les helpers `preview_new_comment_url` et `preview_new_comment_path`.

CONSEIL : Si vous vous retrouvez à ajouter de nombreuses actions supplémentaires à une route ressource, il est temps de vous arrêter et de vous demander si vous ne masquez pas la présence d'une autre ressource.

Routes non ressourceful
----------------------

En plus du routage des ressources, Rails offre une prise en charge puissante pour router des URL arbitraires vers des actions. Ici, vous n'obtenez pas de groupes de routes générés automatiquement par le routage des ressources. Au lieu de cela, vous configurez chaque route séparément dans votre application.

Bien que vous devriez généralement utiliser le routage des ressources, il existe encore de nombreux cas où le routage plus simple est plus approprié. Il n'est pas nécessaire d'essayer de faire rentrer chaque dernier morceau de votre application dans un framework ressourceful si cela ne convient pas.
En particulier, le routage simple facilite grandement la correspondance des URL héritées avec les nouvelles actions de Rails.

### Paramètres liés

Lorsque vous configurez une route régulière, vous fournissez une série de symboles que Rails associe à des parties d'une requête HTTP entrante. Par exemple, considérez cette route :

```ruby
get 'photos(/:id)', to: 'photos#display'
```

Si une requête entrante de `/photos/1` est traitée par cette route (parce qu'elle n'a pas correspondu à une route précédente dans le fichier), alors le résultat sera d'appeler l'action `display` du `PhotosController`, et de rendre le paramètre final `"1"` disponible en tant que `params[:id]`. Cette route routera également la requête entrante de `/photos` vers `PhotosController#display`, car `:id` est un paramètre facultatif, indiqué par des parenthèses.

### Segments dynamiques

Vous pouvez configurer autant de segments dynamiques que vous le souhaitez dans une route régulière. Tout segment sera disponible pour l'action en tant que partie de `params`. Si vous configurez cette route :

```ruby
get 'photos/:id/:user_id', to: 'photos#show'
```

Un chemin entrant de `/photos/1/2` sera envoyé à l'action `show` du `PhotosController`. `params[:id]` sera `"1"`, et `params[:user_id]` sera `"2"`.

CONSEIL : Par défaut, les segments dynamiques n'acceptent pas les points - cela est dû au fait que le point est utilisé comme séparateur pour les routes formatées. Si vous avez besoin d'utiliser un point à l'intérieur d'un segment dynamique, ajoutez une contrainte qui annule cela - par exemple, `id: /[^\/]+/` permet tout sauf une barre oblique.

### Segments statiques

Vous pouvez spécifier des segments statiques lors de la création d'une route en ne préfixant pas un deux-points à un segment :

```ruby
get 'photos/:id/with_user/:user_id', to: 'photos#show'
```

Cette route répondrait aux chemins tels que `/photos/1/with_user/2`. Dans ce cas, `params` serait `{ controller: 'photos', action: 'show', id: '1', user_id: '2' }`.

### La chaîne de requête

Les `params` incluront également tous les paramètres de la chaîne de requête. Par exemple, avec cette route :

```ruby
get 'photos/:id', to: 'photos#show'
```

Un chemin entrant de `/photos/1?user_id=2` sera envoyé à l'action `show` du contrôleur `Photos`. `params` sera `{ controller: 'photos', action: 'show', id: '1', user_id: '2' }`.

### Définition des valeurs par défaut

Vous pouvez définir des valeurs par défaut dans une route en fournissant un hash pour l'option `:defaults`. Cela s'applique même aux paramètres que vous ne spécifiez pas en tant que segments dynamiques. Par exemple :

```ruby
get 'photos/:id', to: 'photos#show', defaults: { format: 'jpg' }
```

Rails ferait correspondre `photos/12` à l'action `show` de `PhotosController`, et définirait `params[:format]` sur `"jpg"`.

Vous pouvez également utiliser un bloc [`defaults`][] pour définir les valeurs par défaut pour plusieurs éléments :

```ruby
defaults format: :json do
  resources :photos
end
```

REMARQUE : Vous ne pouvez pas remplacer les valeurs par défaut via les paramètres de la chaîne de requête - cela est pour des raisons de sécurité. Les seules valeurs par défaut qui peuvent être remplacées sont les segments dynamiques via la substitution dans le chemin de l'URL.

### Nommer les routes

Vous pouvez spécifier un nom pour n'importe quelle route en utilisant l'option `:as` :

```ruby
get 'exit', to: 'sessions#destroy', as: :logout
```

Cela créera `logout_path` et `logout_url` en tant qu'aides de route nommées dans votre application. Appeler `logout_path` renverra `/exit`

Vous pouvez également utiliser cela pour remplacer les méthodes de routage définies par les ressources en plaçant des routes personnalisées avant que la ressource ne soit définie, comme ceci :

```ruby
get ':username', to: 'users#show', as: :user
resources :users
```

Cela définira une méthode `user_path` qui sera disponible dans les contrôleurs, les aides et les vues et qui ira vers une route telle que `/bob`. À l'intérieur de l'action `show` de `UsersController`, `params[:username]` contiendra le nom d'utilisateur de l'utilisateur. Modifiez `:username` dans la définition de la route si vous ne souhaitez pas que le nom de votre paramètre soit `:username`.

### Contraintes de verbe HTTP

En général, vous devriez utiliser les méthodes [`get`][], [`post`][], [`put`][], [`patch`][] et [`delete`][] pour contraindre une route à un verbe particulier. Vous pouvez utiliser la méthode [`match`][] avec l'option `:via` pour faire correspondre plusieurs verbes à la fois :

```ruby
match 'photos', to: 'photos#show', via: [:get, :post]
```

Vous pouvez faire correspondre tous les verbes à une route particulière en utilisant `via: :all` :

```ruby
match 'photos', to: 'photos#show', via: :all
```

REMARQUE : Faire correspondre à la fois les requêtes `GET` et `POST` à une seule action présente des implications en termes de sécurité. En général, vous devriez éviter de faire correspondre tous les verbes à une action à moins d'avoir une bonne raison de le faire.

REMARQUE : `GET` dans Rails ne vérifiera pas le jeton CSRF. Vous ne devriez jamais écrire dans la base de données à partir de requêtes `GET`, pour plus d'informations, consultez le [guide de sécurité](security.html#csrf-countermeasures) sur les contre-mesures CSRF.
### Contraintes de segment

Vous pouvez utiliser l'option `:constraints` pour imposer un format à un segment dynamique :

```ruby
get 'photos/:id', to: 'photos#show', constraints: { id: /[A-Z]\d{5}/ }
```

Cette route correspondrait aux chemins tels que `/photos/A12345`, mais pas à `/photos/893`. Vous pouvez exprimer de manière plus concise la même route de cette manière :

```ruby
get 'photos/:id', to: 'photos#show', id: /[A-Z]\d{5}/
```

`:constraints` prend des expressions régulières avec la restriction que les ancres regexp ne peuvent pas être utilisées. Par exemple, la route suivante ne fonctionnera pas :

```ruby
get '/:id', to: 'articles#show', constraints: { id: /^\d/ }
```

Cependant, notez que vous n'avez pas besoin d'utiliser des ancres car toutes les routes sont ancrées au début et à la fin.

Par exemple, les routes suivantes permettraient aux `articles` avec des valeurs `to_param` comme `1-hello-world` qui commencent toujours par un nombre et aux `utilisateurs` avec des valeurs `to_param` comme `david` qui ne commencent jamais par un nombre de partager l'espace de noms racine :

```ruby
get '/:id', to: 'articles#show', constraints: { id: /\d.+/ }
get '/:username', to: 'users#show'
```

### Contraintes basées sur la requête

Vous pouvez également contraindre une route en fonction de n'importe quelle méthode de l'objet [Request](action_controller_overview.html#the-request-object) qui renvoie une `String`.

Vous spécifiez une contrainte basée sur la requête de la même manière que vous spécifiez une contrainte de segment :

```ruby
get 'photos', to: 'photos#index', constraints: { subdomain: 'admin' }
```

Vous pouvez également spécifier des contraintes en utilisant un bloc [`constraints`][] :

```ruby
namespace :admin do
  constraints subdomain: 'admin' do
    resources :photos
  end
end
```

REMARQUE : Les contraintes de requête fonctionnent en appelant une méthode sur l'objet [Request](action_controller_overview.html#the-request-object) avec le même nom que la clé du hash, puis en comparant la valeur de retour avec la valeur du hash. Par conséquent, les valeurs de contrainte doivent correspondre au type de retour de la méthode correspondante de l'objet Request. Par exemple : `constraints: { subdomain: 'api' }` correspondra à un sous-domaine `api` comme prévu. Cependant, l'utilisation d'un symbole `constraints: { subdomain: :api }` ne le fera pas, car `request.subdomain` renvoie `'api'` en tant que chaîne de caractères.

REMARQUE : Il y a une exception pour la contrainte `format` : bien qu'il s'agisse d'une méthode de l'objet Request, c'est également un paramètre facultatif implicite sur chaque chemin. Les contraintes de segment ont la priorité et la contrainte `format` n'est appliquée que lorsqu'elle est imposée par le biais d'un hash. Par exemple, `get 'foo', constraints: { format: 'json' }` correspondra à `GET  /foo` car le format est facultatif par défaut. Cependant, vous pouvez [utiliser un lambda](#advanced-constraints) comme dans `get 'foo', constraints: lambda { |req| req.format == :json }` et la route ne correspondra qu'aux requêtes JSON explicites.


### Contraintes avancées

Si vous avez une contrainte plus avancée, vous pouvez fournir un objet qui répond à `matches?` que Rails devrait utiliser. Disons que vous voulez router tous les utilisateurs d'une liste restreinte vers le `RestrictedListController`. Vous pouvez faire :

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

Vous pouvez également spécifier des contraintes en tant que lambda :

```ruby
Rails.application.routes.draw do
  get '*path', to: 'restricted_list#index',
    constraints: lambda { |request| RestrictedList.retrieve_ips.include?(request.remote_ip) }
end
```

La méthode `matches?` et le lambda reçoivent tous deux l'objet `request` en argument.

#### Contraintes sous forme de bloc

Vous pouvez spécifier des contraintes sous forme de bloc. C'est utile lorsque vous devez appliquer la même règle à plusieurs routes. Par exemple :

```ruby
class RestrictedListConstraint
  # ...Same as the example above
end

Rails.application.routes.draw do
  constraints(RestrictedListConstraint.new) do
    get '*path', to: 'restricted_list#index'
    get '*other-path', to: 'other_restricted_list#index'
  end
end
```

Vous pouvez également utiliser un `lambda` :

```ruby
Rails.application.routes.draw do
  constraints(lambda { |request| RestrictedList.retrieve_ips.include?(request.remote_ip) }) do
    get '*path', to: 'restricted_list#index'
    get '*other-path', to: 'other_restricted_list#index'
  end
end
```

### Globbing de route et segments génériques

Le globbing de route est une façon de spécifier qu'un paramètre particulier doit correspondre à toutes les parties restantes d'une route. Par exemple :

```ruby
get 'photos/*other', to: 'photos#unknown'
```

Cette route correspondrait à `photos/12` ou `/photos/long/path/to/12`, en définissant `params[:other]` sur `"12"` ou `"long/path/to/12"`. Les segments préfixés par une étoile sont appelés "segments génériques".

Les segments génériques peuvent apparaître n'importe où dans une route. Par exemple :

```ruby
get 'books/*section/:title', to: 'books#show'
```

correspondrait à `books/some/section/last-words-a-memoir` avec `params[:section]` égal à `'some/section'`, et `params[:title]` égal à `'last-words-a-memoir'`.

Techniquement, une route peut avoir plus d'un segment générique. Le matcher attribue les segments aux paramètres de manière intuitive. Par exemple :

```ruby
get '*a/foo/*b', to: 'test#index'
```

correspondrait à `zoo/woo/foo/bar/baz` avec `params[:a]` égal à `'zoo/woo'`, et `params[:b]` égal à `'bar/baz'`.
NOTE: En demandant `'/foo/bar.json'`, vos `params[:pages]` seront égaux à `'foo/bar'` avec le format de requête JSON. Si vous souhaitez retrouver le comportement ancien de la version 3.0.x, vous pouvez fournir `format: false` comme ceci:

```ruby
get '*pages', to: 'pages#show', format: false
```

NOTE: Si vous souhaitez rendre le segment de format obligatoire, de sorte qu'il ne puisse pas être omis, vous pouvez fournir `format: true` comme ceci:

```ruby
get '*pages', to: 'pages#show', format: true
```

### Redirection

Vous pouvez rediriger n'importe quel chemin vers un autre chemin en utilisant l'aide [`redirect`][] dans votre routeur:

```ruby
get '/stories', to: redirect('/articles')
```

Vous pouvez également réutiliser des segments dynamiques de la correspondance dans le chemin de redirection:

```ruby
get '/stories/:name', to: redirect('/articles/%{name}')
```

Vous pouvez également fournir un bloc à `redirect`, qui reçoit les paramètres de chemin symbolisés et l'objet de requête:

```ruby
get '/stories/:name', to: redirect { |path_params, req| "/articles/#{path_params[:name].pluralize}" }
get '/stories', to: redirect { |path_params, req| "/articles/#{req.subdomain}" }
```

Veuillez noter que la redirection par défaut est une redirection 301 "Moved Permanently". Gardez à l'esprit que certains navigateurs Web ou serveurs proxy peuvent mettre en cache ce type de redirection, rendant l'ancienne page inaccessible. Vous pouvez utiliser l'option `:status` pour changer le statut de la réponse:

```ruby
get '/stories/:name', to: redirect('/articles/%{name}', status: 302)
```

Dans tous ces cas, si vous ne fournissez pas l'hôte principal (`http://www.example.com`), Rails prendra ces détails à partir de la requête actuelle.


### Routage vers des applications Rack

Au lieu d'une chaîne de caractères comme `'articles#index'`, qui correspond à l'action `index` dans le contrôleur `ArticlesController`, vous pouvez spécifier n'importe quelle [application Rack](rails_on_rack.html) comme point final pour un matcher:

```ruby
match '/application.js', to: MyRackApp, via: :all
```

Tant que `MyRackApp` répond à `call` et renvoie un `[status, headers, body]`, le routeur ne fera pas la différence entre l'application Rack et une action. C'est une utilisation appropriée de `via: :all`, car vous voudrez permettre à votre application Rack de gérer tous les verbes comme elle le juge approprié.

NOTE: Pour les curieux, `'articles#index'` se développe en réalité en `ArticlesController.action(:index)`, qui renvoie une application Rack valide.

NOTE: Étant donné que les procédures/lambdas sont des objets qui répondent à `call`, vous pouvez implémenter des routes très simples (par exemple, pour les vérifications de santé) en ligne:<br>`get '/health', to: ->(env) { [204, {}, ['']] }`

Si vous spécifiez une application Rack comme point final pour un matcher, rappelez-vous que
la route ne sera pas modifiée dans l'application de réception. Avec la route suivante,
votre application Rack devrait s'attendre à ce que la route soit `/admin`:

```ruby
match '/admin', to: AdminApp, via: :all
```

Si vous préférez que votre application Rack reçoive les requêtes à la racine
au lieu de cela, utilisez [`mount`][]:

```ruby
mount AdminApp, at: '/admin'
```


### Utilisation de `root`

Vous pouvez spécifier vers quoi Rails doit router `'/'` avec la méthode [`root`][]:

```ruby
root to: 'pages#main'
root 'pages#main' # raccourci pour le précédent
```

Vous devez placer la route `root` en haut du fichier, car c'est la route la plus populaire et elle doit être vérifiée en premier.

NOTE: La route `root` ne route que les requêtes `GET` vers l'action.

Vous pouvez également utiliser `root` à l'intérieur des espaces de noms et des scopes. Par exemple:

```ruby
namespace :admin do
  root to: "admin#index"
end

root to: "home#index"
```


### Routes de caractères Unicode

Vous pouvez spécifier directement des routes de caractères Unicode. Par exemple:

```ruby
get 'こんにちは', to: 'welcome#index'
```

### Routes directes

Vous pouvez créer des helpers d'URL personnalisés directement en appelant [`direct`][]. Par exemple:

```ruby
direct :homepage do
  "https://rubyonrails.org"
end

# >> homepage_url
# => "https://rubyonrails.org"
```

La valeur de retour du bloc doit être un argument valide pour la méthode `url_for`. Ainsi, vous pouvez passer une URL sous forme de chaîne valide, un Hash, un Array, une instance Active Model ou une classe Active Model.

```ruby
direct :commentable do |model|
  [ model, anchor: model.dom_id ]
end

direct :main do
  { controller: 'pages', action: 'index', subdomain: 'www' }
end
```


### Utilisation de `resolve`

La méthode [`resolve`][] permet de personnaliser la correspondance polymorphe des modèles. Par exemple:

```ruby
resource :basket

resolve("Basket") { [:basket] }
```

```erb
<%= form_with model: @basket do |form| %>
  <!-- formulaire de panier -->
<% end %>
```

Cela générera l'URL singulière `/basket` au lieu de l'URL habituelle `/baskets/:id`.


Personnalisation des routes de ressources
-----------------------------------------

Bien que les routes et les helpers par défaut générés par [`resources`][] vous conviennent généralement, vous voudrez peut-être les personnaliser d'une manière ou d'une autre. Rails vous permet de personnaliser pratiquement n'importe quelle partie générique des helpers de ressources.
### Spécifier un contrôleur à utiliser

L'option `:controller` vous permet de spécifier explicitement un contrôleur à utiliser pour la ressource. Par exemple :

```ruby
resources :photos, controller: 'images'
```

reconnaîtra les chemins entrants commençant par `/photos` mais routera vers le contrôleur `Images` :

| Verbe HTTP | Chemin           | Contrôleur#Action | Aide pour le nom de la route |
| ---------- | ---------------- | ----------------- | --------------------------- |
| GET        | /photos          | images#index      | photos_path                 |
| GET        | /photos/new      | images#new        | new_photo_path              |
| POST       | /photos          | images#create     | photos_path                 |
| GET        | /photos/:id      | images#show       | photo_path(:id)             |
| GET        | /photos/:id/edit | images#edit       | edit_photo_path(:id)        |
| PATCH/PUT  | /photos/:id      | images#update     | photo_path(:id)             |
| DELETE     | /photos/:id      | images#destroy    | photo_path(:id)             |

NOTE : Utilisez `photos_path`, `new_photo_path`, etc. pour générer des chemins pour cette ressource.

Pour les contrôleurs avec un espace de noms, vous pouvez utiliser la notation de répertoire. Par exemple :

```ruby
resources :user_permissions, controller: 'admin/user_permissions'
```

Cela routera vers le contrôleur `Admin::UserPermissions`.

NOTE : Seule la notation de répertoire est prise en charge. Spécifier le contrôleur avec la notation de constante Ruby (par exemple `controller: 'Admin::UserPermissions'`) peut entraîner des problèmes de routage et générer un avertissement.

### Spécifier des contraintes

Vous pouvez utiliser l'option `:constraints` pour spécifier un format requis sur l'`id` implicite. Par exemple :

```ruby
resources :photos, constraints: { id: /[A-Z][A-Z][0-9]+/ }
```

Cette déclaration contraint le paramètre `:id` à correspondre à l'expression régulière fournie. Ainsi, dans ce cas, le routeur ne correspondrait plus à `/photos/1` à cette route. Au lieu de cela, `/photos/RR27` correspondrait.

Vous pouvez spécifier une seule contrainte à appliquer à plusieurs routes en utilisant la forme de bloc :

```ruby
constraints(id: /[A-Z][A-Z][0-9]+/) do
  resources :photos
  resources :accounts
end
```

NOTE : Bien sûr, vous pouvez utiliser les contraintes plus avancées disponibles dans les routes non ressources dans ce contexte.

CONSEIL : Par défaut, le paramètre `:id` n'accepte pas les points - cela est dû au fait que le point est utilisé comme séparateur pour les routes formatées. Si vous avez besoin d'utiliser un point dans un `:id`, ajoutez une contrainte qui annule cela - par exemple, `id: /[^\/]+/` permet tout sauf une barre oblique.

### Remplacement des aides pour les routes nommées

L'option `:as` vous permet de remplacer la dénomination normale des aides pour les routes nommées. Par exemple :

```ruby
resources :photos, as: 'images'
```

reconnaîtra les chemins entrants commençant par `/photos` et routera les requêtes vers `PhotosController`, mais utilisera la valeur de l'option `:as` pour nommer les aides.

| Verbe HTTP | Chemin           | Contrôleur#Action | Aide pour le nom de la route |
| ---------- | ---------------- | ----------------- | --------------------------- |
| GET        | /photos          | photos#index      | images_path                 |
| GET        | /photos/new      | photos#new        | new_image_path              |
| POST       | /photos          | photos#create     | images_path                 |
| GET        | /photos/:id      | photos#show       | image_path(:id)             |
| GET        | /photos/:id/edit | photos#edit       | edit_image_path(:id)        |
| PATCH/PUT  | /photos/:id      | photos#update     | image_path(:id)             |
| DELETE     | /photos/:id      | photos#destroy    | image_path(:id)             |

### Remplacement des segments `new` et `edit`

L'option `:path_names` vous permet de remplacer les segments `new` et `edit` générés automatiquement dans les chemins :

```ruby
resources :photos, path_names: { new: 'make', edit: 'change' }
```

Cela ferait en sorte que le routage reconnaisse des chemins tels que :

```
/photos/make
/photos/1/change
```

NOTE : Les noms d'action réels ne sont pas modifiés par cette option. Les deux chemins indiqués routeraient toujours vers les actions `new` et `edit`.

CONSEIL : Si vous souhaitez changer cette option uniformément pour toutes vos routes, vous pouvez utiliser une portée, comme ci-dessous :

```ruby
scope path_names: { new: 'make' } do
  # reste de vos routes
end
```

### Préfixer les aides pour les routes nommées

Vous pouvez utiliser l'option `:as` pour préfixer les aides pour les routes nommées que Rails génère pour une route. Utilisez cette option pour éviter les collisions de noms entre les routes utilisant une portée de chemin. Par exemple :

```ruby
scope 'admin' do
  resources :photos, as: 'admin_photos'
end

resources :photos
```

Cela modifie les aides de route pour `/admin/photos` de `photos_path`,
`new_photos_path`, etc. en `admin_photos_path`, `new_admin_photo_path`,
etc. Sans l'ajout de `as: 'admin_photos` sur les `resources` de portée, les `resources :photos` non portées n'auront aucune aide de route.

Pour préfixer un groupe d'aides de route, utilisez `:as` avec `scope` :

```ruby
scope 'admin', as: 'admin' do
  resources :photos, :accounts
end

resources :photos, :accounts
```

Comme précédemment, cela modifie les aides de ressources avec la portée `/admin` en
`admin_photos_path` et `admin_accounts_path`, et permet aux ressources non portées
d'utiliser `photos_path` et `accounts_path`.
REMARQUE: L'espace de noms `namespace` ajoutera automatiquement les préfixes `:as`, `:module` et `:path`.

#### Espaces de noms paramétriques

Vous pouvez préfixer les routes avec un paramètre nommé:

```ruby
scope ':account_id', as: 'account', constraints: { account_id: /\d+/ } do
  resources :articles
end
```

Cela vous fournira des chemins tels que `/1/articles/9` et vous permettra de faire référence à la partie `account_id` du chemin en tant que `params[:account_id]` dans les contrôleurs, les helpers et les vues.

Cela générera également des helpers de chemin et d'URL préfixés par `account_`, dans lesquels vous pouvez passer vos objets comme prévu:

```ruby
account_article_path(@account, @article) # => /1/article/9
url_for([@account, @article])            # => /1/article/9
form_with(model: [@account, @article])   # => <form action="/1/article/9" ...>
```

Nous utilisons [une contrainte](#segment-constraints) pour limiter la portée afin de ne correspondre qu'à des chaînes ressemblant à des identifiants. Vous pouvez modifier la contrainte selon vos besoins ou l'omettre complètement. L'option `:as` n'est pas strictement requise, mais sans elle, Rails générera une erreur lors de l'évaluation de `url_for([@account, @article])` ou d'autres helpers qui dépendent de `url_for`, tels que [`form_with`][].


### Restriction des routes créées

Par défaut, Rails crée des routes pour les sept actions par défaut (`index`, `show`, `new`, `create`, `edit`, `update` et `destroy`) pour chaque route RESTful de votre application. Vous pouvez utiliser les options `:only` et `:except` pour affiner ce comportement. L'option `:only` indique à Rails de créer uniquement les routes spécifiées:

```ruby
resources :photos, only: [:index, :show]
```

Maintenant, une requête `GET` vers `/photos` réussira, mais une requête `POST` vers `/photos` (qui serait normalement routée vers l'action `create`) échouera.

L'option `:except` spécifie une route ou une liste de routes que Rails ne doit _pas_ créer:

```ruby
resources :photos, except: :destroy
```

Dans ce cas, Rails créera toutes les routes normales sauf la route pour `destroy` (une requête `DELETE` vers `/photos/:id`).

CONSEIL: Si votre application comporte de nombreuses routes RESTful, utiliser `:only` et `:except` pour générer uniquement les routes dont vous avez réellement besoin peut réduire l'utilisation de la mémoire et accélérer le processus de routage.

### Chemins traduits

En utilisant `scope`, nous pouvons modifier les noms de chemin générés par `resources`:

```ruby
scope(path_names: { new: 'neu', edit: 'bearbeiten' }) do
  resources :categories, path: 'kategorien'
end
```

Rails crée maintenant des routes vers le `CategoriesController`.

| Verbe HTTP | Chemin                      | Contrôleur#Action | Helper de route nommé   |
| ---------- | --------------------------- | ----------------- | ----------------------- |
| GET        | /kategorien                 | categories#index  | categories_path         |
| GET        | /kategorien/neu             | categories#new    | new_category_path       |
| POST       | /kategorien                 | categories#create | categories_path         |
| GET        | /kategorien/:id             | categories#show   | category_path(:id)      |
| GET        | /kategorien/:id/bearbeiten  | categories#edit   | edit_category_path(:id) |
| PATCH/PUT  | /kategorien/:id             | categories#update | category_path(:id)      |
| DELETE     | /kategorien/:id             | categories#destroy| category_path(:id)      |

### Remplacement de la forme singulière

Si vous souhaitez remplacer la forme singulière d'une ressource, vous devez ajouter des règles supplémentaires à l'inflecteur via [`inflections`][]:

```ruby
ActiveSupport::Inflector.inflections do |inflect|
  inflect.irregular 'tooth', 'teeth'
end
```


### Utilisation de `:as` dans les ressources imbriquées

L'option `:as` remplace le nom généré automatiquement pour la ressource dans les helpers de route imbriqués. Par exemple:

```ruby
resources :magazines do
  resources :ads, as: 'periodical_ads'
end
```

Cela créera des helpers de routage tels que `magazine_periodical_ads_url` et `edit_magazine_periodical_ad_path`.

### Remplacement des paramètres nommés de la route

L'option `:param` remplace l'identifiant de ressource par défaut `:id` (nom du [segment dynamique](routing.html#dynamic-segments) utilisé pour générer les routes). Vous pouvez accéder à ce segment depuis votre contrôleur en utilisant `params[<:param>]`.

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

Vous pouvez remplacer `ActiveRecord::Base#to_param` du modèle associé pour construire une URL:

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

Diviser un fichier de routes *très* volumineux en plusieurs fichiers plus petits
-------------------------------------------------------

Si vous travaillez dans une grande application avec des milliers de routes, un seul fichier `config/routes.rb` peut devenir encombrant et difficile à lire.

Rails offre un moyen de diviser un énorme fichier de routes unique en plusieurs fichiers plus petits en utilisant la macro [`draw`][].

Vous pouvez avoir un fichier de route `admin.rb` qui contient toutes les routes de la zone d'administration, un autre fichier `api.rb` pour les ressources liées à l'API, etc.

```ruby
# config/routes.rb

Rails.application.routes.draw do
  get 'foo', to: 'foo#bar'

  draw(:admin) # Chargera un autre fichier de route situé dans `config/routes/admin.rb`
end
```
```ruby
# config/routes/admin.rb

namespace :admin do
  resources :comments
end
```

Appeler `draw(:admin)` à l'intérieur du bloc `Rails.application.routes.draw` tentera de charger un fichier de route
qui a le même nom que l'argument donné (`admin.rb` dans cet exemple).
Le fichier doit être situé à l'intérieur du répertoire `config/routes` ou de tout sous-répertoire (par exemple `config/routes/admin.rb` ou `config/routes/external/admin.rb`).

Vous pouvez utiliser le DSL de routage normal à l'intérieur du fichier de routage `admin.rb`, mais vous **ne devez pas** l'entourer du bloc `Rails.application.routes.draw` comme vous l'avez fait dans le fichier principal `config/routes.rb`.


### N'utilisez pas cette fonctionnalité à moins que vous en ayez vraiment besoin

Avoir plusieurs fichiers de routage rend la découverte et la compréhension plus difficiles. Pour la plupart des applications - même celles avec quelques centaines de routes - il est plus facile pour les développeurs d'avoir un seul fichier de routage. Le DSL de routage de Rails offre déjà un moyen de diviser les routes de manière organisée avec `namespace` et `scope`.


Inspection et test des routes
-----------------------------

Rails offre des fonctionnalités pour inspecter et tester vos routes.

### Liste des routes existantes

Pour obtenir une liste complète des routes disponibles dans votre application, visitez <http://localhost:3000/rails/info/routes> dans votre navigateur pendant que votre serveur est en cours d'exécution dans l'environnement **development**. Vous pouvez également exécuter la commande `bin/rails routes` dans votre terminal pour produire la même sortie.

Les deux méthodes afficheront toutes vos routes, dans le même ordre qu'elles apparaissent dans `config/routes.rb`. Pour chaque route, vous verrez :

* Le nom de la route (s'il y en a un)
* La méthode HTTP utilisée (si la route ne répond pas à toutes les méthodes)
* Le modèle d'URL à correspondre
* Les paramètres de routage pour la route

Par exemple, voici une petite section de la sortie `bin/rails routes` pour une route RESTful :

```
    users GET    /users(.:format)          users#index
          POST   /users(.:format)          users#create
 new_user GET    /users/new(.:format)      users#new
edit_user GET    /users/:id/edit(.:format) users#edit
```

Vous pouvez également utiliser l'option `--expanded` pour activer le mode de formatage de tableau étendu.

```bash
$ bin/rails routes --expanded

--[ Route 1 ]----------------------------------------------------
Prefix            | users
Verb              | GET
URI               | /users(.:format)
Controller#Action | users#index
--[ Route 2 ]----------------------------------------------------
Prefix            |
Verb              | POST
URI               | /users(.:format)
Controller#Action | users#create
--[ Route 3 ]----------------------------------------------------
Prefix            | new_user
Verb              | GET
URI               | /users/new(.:format)
Controller#Action | users#new
--[ Route 4 ]----------------------------------------------------
Prefix            | edit_user
Verb              | GET
URI               | /users/:id/edit(.:format)
Controller#Action | users#edit
```

Vous pouvez rechercher vos routes avec l'option grep: -g. Cela affiche toutes les routes qui correspondent partiellement au nom de la méthode d'aide URL, à la méthode HTTP ou au chemin URL.

```bash
$ bin/rails routes -g new_comment
$ bin/rails routes -g POST
$ bin/rails routes -g admin
```

Si vous voulez seulement voir les routes qui sont mappées vers un contrôleur spécifique, il y a l'option -c.

```bash
$ bin/rails routes -c users
$ bin/rails routes -c admin/users
$ bin/rails routes -c Comments
$ bin/rails routes -c Articles::CommentsController
```

CONSEIL : Vous constaterez que la sortie de `bin/rails routes` est beaucoup plus lisible si vous élargissez votre fenêtre de terminal jusqu'à ce que les lignes de sortie ne se chevauchent pas.

### Test des routes

Les routes doivent être incluses dans votre stratégie de test (tout comme le reste de votre application). Rails offre trois assertions intégrées conçues pour faciliter le test des routes :

* [`assert_generates`][]
* [`assert_recognizes`][]
* [`assert_routing`][]


#### L'assertion `assert_generates`

[`assert_generates`][] affirme qu'un ensemble particulier d'options génère un chemin particulier et peut être utilisé avec des routes par défaut ou des routes personnalisées. Par exemple :

```ruby
assert_generates '/photos/1', { controller: 'photos', action: 'show', id: '1' }
assert_generates '/about', controller: 'pages', action: 'about'
```

#### L'assertion `assert_recognizes`

[`assert_recognizes`][] est l'inverse de `assert_generates`. Elle affirme qu'un chemin donné est reconnu et le route vers un endroit particulier de votre application. Par exemple :

```ruby
assert_recognizes({ controller: 'photos', action: 'show', id: '1' }, '/photos/1')
```

Vous pouvez fournir un argument `:method` pour spécifier la méthode HTTP :

```ruby
assert_recognizes({ controller: 'photos', action: 'create' }, { path: 'photos', method: :post })
```

#### L'assertion `assert_routing`

L'assertion [`assert_routing`][] vérifie la route dans les deux sens : elle teste que le chemin génère les options, et que les options génèrent le chemin. Ainsi, elle combine les fonctions de `assert_generates` et `assert_recognizes` :

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
