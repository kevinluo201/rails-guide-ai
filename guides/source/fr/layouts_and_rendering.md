**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 02f663dc709da76ced45deb2ba800a78
Mises en page et rendu dans Rails
==============================

Ce guide couvre les fonctionnalités de base de mise en page d'Action Controller et Action View.

Après avoir lu ce guide, vous saurez :

* Comment utiliser les différentes méthodes de rendu intégrées dans Rails.
* Comment créer des mises en page avec plusieurs sections de contenu.
* Comment utiliser des partiels pour DRY (Don't Repeat Yourself) vos vues.
* Comment utiliser des mises en page imbriquées (sous-modèles).

--------------------------------------------------------------------------------

Aperçu : Comment les éléments s'assemblent
-------------------------------------

Ce guide se concentre sur l'interaction entre le contrôleur et la vue dans le triangle Modèle-Vue-Contrôleur. Comme vous le savez, le contrôleur est responsable de l'orchestration de l'ensemble du processus de traitement d'une requête dans Rails, bien qu'il délègue généralement tout code lourd au modèle. Mais ensuite, lorsqu'il est temps d'envoyer une réponse à l'utilisateur, le contrôleur transmet les choses à la vue. C'est cette transmission qui est le sujet de ce guide.

En gros, cela implique de décider ce qui doit être envoyé en tant que réponse et d'appeler une méthode appropriée pour créer cette réponse. Si la réponse est une vue complète, Rails effectue également un travail supplémentaire pour envelopper la vue dans une mise en page et éventuellement pour inclure des vues partielles. Vous verrez tous ces chemins plus tard dans ce guide.

Création de réponses
------------------

Du point de vue du contrôleur, il existe trois façons de créer une réponse HTTP :

* Appeler [`render`][controller.render] pour créer une réponse complète à renvoyer au navigateur.
* Appeler [`redirect_to`][] pour envoyer un code d'état de redirection HTTP au navigateur.
* Appeler [`head`][] pour créer une réponse composée uniquement d'en-têtes HTTP à renvoyer au navigateur.


### Rendu par défaut : Convention plutôt que configuration en action

Vous avez entendu dire que Rails favorise "la convention plutôt que la configuration". Le rendu par défaut en est un excellent exemple. Par défaut, les contrôleurs dans Rails rendent automatiquement les vues dont les noms correspondent aux routes valides. Par exemple, si vous avez ce code dans votre classe `BooksController` :

```ruby
class BooksController < ApplicationController
end
```

Et ce qui suit dans votre fichier de routes :

```ruby
resources :books
```

Et que vous avez un fichier de vue `app/views/books/index.html.erb` :

```html+erb
<h1>Les livres arrivent bientôt !</h1>
```

Rails rendra automatiquement `app/views/books/index.html.erb` lorsque vous accédez à `/books` et vous verrez "Les livres arrivent bientôt !" à l'écran.

Cependant, un écran à venir est seulement minimement utile, donc vous allez bientôt créer votre modèle `Book` et ajouter l'action index à `BooksController` :

```ruby
class BooksController < ApplicationController
  def index
    @books = Book.all
  end
end
```

Notez que nous n'avons pas de rendu explicite à la fin de l'action index conformément au principe "la convention plutôt que la configuration". La règle est que si vous ne rendez pas explicitement quelque chose à la fin d'une action de contrôleur, Rails cherchera automatiquement le modèle `action_name.html.erb` dans le chemin de vue du contrôleur et le rendra. Donc dans ce cas, Rails rendra le fichier `app/views/books/index.html.erb`.

Si nous voulons afficher les propriétés de tous les livres dans notre vue, nous pouvons le faire avec un modèle ERB comme ceci :

```html+erb
<h1>Liste des livres</h1>

<table>
  <thead>
    <tr>
      <th>Titre</th>
      <th>Contenu</th>
      <th colspan="3"></th>
    </tr>
  </thead>

  <tbody>
    <% @books.each do |book| %>
      <tr>
        <td><%= book.title %></td>
        <td><%= book.content %></td>
        <td><%= link_to "Afficher", book %></td>
        <td><%= link_to "Modifier", edit_book_path(book) %></td>
        <td><%= link_to "Supprimer", book, data: { turbo_method: :delete, turbo_confirm: "Êtes-vous sûr ?" } %></td>
      </tr>
    <% end %>
  </tbody>
</table>

<br>

<%= link_to "Nouveau livre", new_book_path %>
```

NOTE : Le rendu réel est effectué par des classes imbriquées du module [`ActionView::Template::Handlers`](https://api.rubyonrails.org/classes/ActionView/Template/Handlers.html). Ce guide n'approfondit pas ce processus, mais il est important de savoir que l'extension de fichier de votre vue contrôle le choix du gestionnaire de modèle.

### Utilisation de `render`

Dans la plupart des cas, la méthode [`render`][controller.render] du contrôleur effectue le gros du travail de rendu du contenu de votre application pour une utilisation par un navigateur. Il existe plusieurs façons de personnaliser le comportement de `render`. Vous pouvez rendre la vue par défaut pour un modèle Rails, ou un modèle spécifique, ou un fichier, ou du code en ligne, ou rien du tout. Vous pouvez rendre du texte, du JSON ou du XML. Vous pouvez également spécifier le type de contenu ou le statut HTTP de la réponse rendue.

CONSEIL : Si vous souhaitez voir les résultats exacts d'un appel à `render` sans avoir besoin de l'inspecter dans un navigateur, vous pouvez appeler `render_to_string`. Cette méthode prend exactement les mêmes options que `render`, mais elle renvoie une chaîne de caractères au lieu d'envoyer une réponse au navigateur.
#### Rendu de la vue d'une action

Si vous souhaitez rendre la vue correspondant à un autre modèle dans le même contrôleur, vous pouvez utiliser `render` avec le nom de la vue :

```ruby
def update
  @book = Book.find(params[:id])
  if @book.update(book_params)
    redirect_to(@book)
  else
    render "edit"
  end
end
```

Si l'appel à `update` échoue, l'appel de l'action `update` dans ce contrôleur rendra le modèle `edit.html.erb` appartenant au même contrôleur.

Si vous préférez, vous pouvez utiliser un symbole au lieu d'une chaîne de caractères pour spécifier l'action à rendre :

```ruby
def update
  @book = Book.find(params[:id])
  if @book.update(book_params)
    redirect_to(@book)
  else
    render :edit, status: :unprocessable_entity
  end
end
```

#### Rendu du modèle d'une action à partir d'un autre contrôleur

Que faire si vous souhaitez rendre un modèle à partir d'un contrôleur totalement différent de celui qui contient le code de l'action ? Vous pouvez également le faire avec `render`, qui accepte le chemin complet (relatif à `app/views`) du modèle à rendre. Par exemple, si vous exécutez du code dans un `AdminProductsController` qui se trouve dans `app/controllers/admin`, vous pouvez rendre les résultats d'une action vers un modèle dans `app/views/products` de cette manière :

```ruby
render "products/show"
```

Rails sait que cette vue appartient à un contrôleur différent en raison du caractère de barre oblique intégré dans la chaîne de caractères. Si vous souhaitez être explicite, vous pouvez utiliser l'option `:template` (qui était obligatoire dans Rails 2.2 et antérieur) :

```ruby
render template: "products/show"
```

#### Conclusion

Les deux façons de rendre (rendre le modèle d'une autre action dans le même contrôleur et rendre le modèle d'une autre action dans un autre contrôleur) sont en réalité des variantes de la même opération.

En fait, dans la classe `BooksController`, à l'intérieur de l'action `update` où nous voulons rendre le modèle `edit` si le livre ne se met pas à jour avec succès, tous les appels de rendu suivants rendraient tous le modèle `edit.html.erb` dans le répertoire `views/books` :

```ruby
render :edit
render action: :edit
render "edit"
render action: "edit"
render "books/edit"
render template: "books/edit"
```

Lequel vous utilisez est vraiment une question de style et de convention, mais la règle générale est d'utiliser le plus simple qui a du sens pour le code que vous écrivez.

#### Utilisation de `render` avec `:inline`

La méthode `render` peut se passer complètement d'une vue, si vous êtes prêt à utiliser l'option `:inline` pour fournir ERB en tant que partie de l'appel de méthode. C'est parfaitement valide :

```ruby
render inline: "<% products.each do |p| %><p><%= p.name %></p><% end %>"
```

AVERTISSEMENT : Il y a rarement une bonne raison d'utiliser cette option. Mélanger ERB dans vos contrôleurs contredit l'orientation MVC de Rails et rendra plus difficile pour les autres développeurs de suivre la logique de votre projet. Utilisez plutôt une vue erb séparée.

Par défaut, le rendu en ligne utilise ERB. Vous pouvez le forcer à utiliser Builder avec l'option `:type` :

```ruby
render inline: "xml.p {'Pratique de codage horrible !'}", type: :builder
```

#### Rendu de texte

Vous pouvez envoyer du texte brut - sans aucun balisage - au navigateur en utilisant l'option `:plain` de `render` :

```ruby
render plain: "OK"
```

CONSEIL : Le rendu de texte pur est le plus utile lorsque vous répondez à des requêtes Ajax ou de services web qui attendent autre chose que du HTML correct.

REMARQUE : Par défaut, si vous utilisez l'option `:plain`, le texte est rendu sans utiliser la mise en page actuelle. Si vous voulez que Rails place le texte dans la mise en page actuelle, vous devez ajouter l'option `layout: true` et utiliser l'extension `.text.erb` pour le fichier de mise en page.

#### Rendu de HTML

Vous pouvez envoyer une chaîne HTML au navigateur en utilisant l'option `:html` de `render` :

```ruby
render html: helpers.tag.strong('Non trouvé')
```

CONSEIL : C'est utile lorsque vous rendez un petit extrait de code HTML. Cependant, vous voudrez peut-être le déplacer vers un fichier de modèle si le balisage est complexe.

REMARQUE : Lors de l'utilisation de l'option `html:`, les entités HTML seront échappées si la chaîne n'est pas composée avec des API sensibles à `html_safe`.

#### Rendu de JSON

JSON est un format de données JavaScript utilisé par de nombreuses bibliothèques Ajax. Rails prend en charge la conversion d'objets en JSON et le rendu de ce JSON vers le navigateur :

```ruby
render json: @product
```

CONSEIL : Vous n'avez pas besoin d'appeler `to_json` sur l'objet que vous voulez rendre. Si vous utilisez l'option `:json`, `render` appellera automatiquement `to_json` pour vous.
#### Rendu XML

Rails dispose également d'une prise en charge intégrée pour convertir des objets en XML et rendre ce XML à l'appelant :

```ruby
render xml: @product
```

CONSEIL : Vous n'avez pas besoin d'appeler `to_xml` sur l'objet que vous souhaitez rendre. Si vous utilisez l'option `:xml`, `render` appellera automatiquement `to_xml` pour vous.

#### Rendu JavaScript brut

Rails peut rendre du JavaScript brut :

```ruby
render js: "alert('Hello Rails');"
```

Cela enverra la chaîne fournie au navigateur avec un type MIME de `text/javascript`.

#### Rendu du corps brut

Vous pouvez renvoyer un contenu brut au navigateur, sans définir de type de contenu, en utilisant l'option `:body` de `render` :

```ruby
render body: "brut"
```

CONSEIL : Cette option ne doit être utilisée que si vous ne vous souciez pas du type de contenu de la réponse. L'utilisation de `:plain` ou `:html` est généralement plus appropriée.

REMARQUE : À moins d'être remplacée, votre réponse renvoyée à partir de cette option de rendu sera `text/plain`, car c'est le type de contenu par défaut de la réponse de l'action Dispatch.

#### Rendu de fichier brut

Rails peut rendre un fichier brut à partir d'un chemin absolu. Cela est utile pour rendre conditionnellement des fichiers statiques tels que des pages d'erreur.

```ruby
render file: "#{Rails.root}/public/404.html", layout: false
```

Cela rend le fichier brut (il ne prend pas en charge ERB ou d'autres gestionnaires). Par défaut, il est rendu dans la mise en page actuelle.

AVERTISSEMENT : L'utilisation de l'option `:file` en combinaison avec l'entrée des utilisateurs peut entraîner des problèmes de sécurité, car un attaquant pourrait utiliser cette action pour accéder à des fichiers sensibles à la sécurité de votre système de fichiers.

CONSEIL : `send_file` est souvent une option plus rapide et meilleure si une mise en page n'est pas requise.

#### Rendu d'objets

Rails peut rendre des objets répondant à `:render_in`.

```ruby
render MyRenderable.new
```

Cela appelle `render_in` sur l'objet fourni avec le contexte de vue actuel.

Vous pouvez également fournir l'objet en utilisant l'option `:renderable` de `render` :

```ruby
render renderable: MyRenderable.new
```

#### Options pour `render`

Les appels à la méthode [`render`][controller.render] acceptent généralement six options :

* `:content_type`
* `:layout`
* `:location`
* `:status`
* `:formats`
* `:variants`

##### L'option `:content_type`

Par défaut, Rails servira les résultats d'une opération de rendu avec le type de contenu MIME `text/html` (ou `application/json` si vous utilisez l'option `:json`, ou `application/xml` pour l'option `:xml`). Il peut arriver que vous souhaitiez le modifier, et vous pouvez le faire en définissant l'option `:content_type` :

```ruby
render template: "feed", content_type: "application/rss"
```

##### L'option `:layout`

Avec la plupart des options de `render`, le contenu rendu est affiché dans le cadre de la mise en page actuelle. Vous en apprendrez plus sur les mises en page et leur utilisation plus tard dans ce guide.

Vous pouvez utiliser l'option `:layout` pour indiquer à Rails d'utiliser un fichier spécifique comme mise en page pour l'action actuelle :

```ruby
render layout: "special_layout"
```

Vous pouvez également indiquer à Rails de rendre sans aucune mise en page du tout :

```ruby
render layout: false
```

##### L'option `:location`

Vous pouvez utiliser l'option `:location` pour définir l'en-tête HTTP `Location` :

```ruby
render xml: photo, location: photo_url(photo)
```

##### L'option `:status`

Rails générera automatiquement une réponse avec le code d'état HTTP correct (dans la plupart des cas, il s'agit de `200 OK`). Vous pouvez utiliser l'option `:status` pour le modifier :

```ruby
render status: 500
render status: :forbidden
```

Rails comprend à la fois les codes d'état numériques et les symboles correspondants indiqués ci-dessous.

| Classe de réponse   | Code d'état HTTP | Symbole                          |
| ------------------- | ---------------- | -------------------------------- |
| **Informationnel**  | 100              | :continue                        |
|                     | 101              | :switching_protocols             |
|                     | 102              | :processing                      |
| **Succès**          | 200              | :ok                              |
|                     | 201              | :created                         |
|                     | 202              | :accepted                        |
|                     | 203              | :non_authoritative_information   |
|                     | 204              | :no_content                      |
|                     | 205              | :reset_content                   |
|                     | 206              | :partial_content                 |
|                     | 207              | :multi_status                    |
|                     | 208              | :already_reported                |
|                     | 226              | :im_used                         |
| **Redirection**     | 300              | :multiple_choices                |
|                     | 301              | :moved_permanently               |
|                     | 302              | :found                           |
|                     | 303              | :see_other                       |
|                     | 304              | :not_modified                    |
|                     | 305              | :use_proxy                       |
|                     | 307              | :temporary_redirect              |
|                     | 308              | :permanent_redirect              |
| **Erreur client**   | 400              | :bad_request                     |
|                     | 401              | :unauthorized                    |
|                     | 402              | :payment_required                |
|                     | 403              | :forbidden                       |
|                     | 404              | :not_found                       |
|                     | 405              | :method_not_allowed              |
|                     | 406              | :not_acceptable                  |
|                     | 407              | :proxy_authentication_required   |
|                     | 408              | :request_timeout                 |
|                     | 409              | :conflict                        |
|                     | 410              | :gone                            |
|                     | 411              | :length_required                 |
|                     | 412              | :precondition_failed             |
|                     | 413              | :payload_too_large               |
|                     | 414              | :uri_too_long                    |
|                     | 415              | :unsupported_media_type          |
|                     | 416              | :range_not_satisfiable           |
|                     | 417              | :expectation_failed              |
|                     | 421              | :misdirected_request             |
|                     | 422              | :unprocessable_entity            |
|                     | 423              | :locked                          |
|                     | 424              | :failed_dependency               |
|                     | 426              | :upgrade_required                |
|                     | 428              | :precondition_required           |
|                     | 429              | :too_many_requests               |
|                     | 431              | :request_header_fields_too_large |
|                     | 451              | :unavailable_for_legal_reasons   |
| **Erreur serveur**  | 500              | :internal_server_error           |
|                     | 501              | :not_implemented                 |
|                     | 502              | :bad_gateway                     |
|                     | 503              | :service_unavailable             |
|                     | 504              | :gateway_timeout                 |
|                     | 505              | :http_version_not_supported      |
|                     | 506              | :variant_also_negotiates         |
|                     | 507              | :insufficient_storage            |
|                     | 508              | :loop_detected                   |
|                     | 510              | :not_extended                    |
|                     | 511              | :network_authentication_required |
NOTE : Si vous essayez de rendre du contenu avec un code d'état non-content (100-199, 204, 205 ou 304), il sera supprimé de la réponse.

##### L'option `:formats`

Rails utilise le format spécifié dans la requête (ou `:html` par défaut). Vous pouvez le changer en passant l'option `:formats` avec un symbole ou un tableau :

```ruby
render formats: :xml
render formats: [:json, :xml]
```

Si un modèle avec le format spécifié n'existe pas, une erreur `ActionView::MissingTemplate` est levée.

##### L'option `:variants`

Cela indique à Rails de rechercher des variations de modèle du même format. Vous pouvez spécifier une liste de variantes en passant l'option `:variants` avec un symbole ou un tableau.

Un exemple d'utilisation serait le suivant.

```ruby
# appelé dans HomeController#index
render variants: [:mobile, :desktop]
```

Avec cet ensemble de variantes, Rails recherchera l'ensemble de modèles suivant et utilisera le premier qui existe.

- `app/views/home/index.html+mobile.erb`
- `app/views/home/index.html+desktop.erb`
- `app/views/home/index.html.erb`

Si un modèle avec le format spécifié n'existe pas, une erreur `ActionView::MissingTemplate` est levée.

Au lieu de définir la variante sur l'appel de rendu, vous pouvez également la définir sur l'objet de requête dans votre action de contrôleur.

```ruby
def index
  request.variant = determine_variant
end

  private
    def determine_variant
      variant = nil
      # du code pour déterminer la ou les variantes à utiliser
      variant = :mobile if session[:use_mobile]

      variant
    end
```

#### Recherche de mises en page

Pour trouver la mise en page actuelle, Rails recherche d'abord un fichier dans `app/views/layouts` avec le même nom de base que le contrôleur. Par exemple, le rendu des actions de la classe `PhotosController` utilisera `app/views/layouts/photos.html.erb` (ou `app/views/layouts/photos.builder`). S'il n'y a pas de mise en page spécifique au contrôleur, Rails utilisera `app/views/layouts/application.html.erb` ou `app/views/layouts/application.builder`. S'il n'y a pas de mise en page `.erb`, Rails utilisera une mise en page `.builder` si elle existe. Rails propose également plusieurs façons d'attribuer plus précisément des mises en page spécifiques à des contrôleurs et des actions individuels.

##### Spécification des mises en page pour les contrôleurs

Vous pouvez remplacer les conventions de mise en page par défaut dans vos contrôleurs en utilisant la déclaration [`layout`][]. Par exemple :

```ruby
class ProductsController < ApplicationController
  layout "inventory"
  #...
end
```

Avec cette déclaration, toutes les vues rendues par le `ProductsController` utiliseront `app/views/layouts/inventory.html.erb` comme mise en page.

Pour attribuer une mise en page spécifique à l'ensemble de l'application, utilisez une déclaration de `layout` dans votre classe `ApplicationController` :

```ruby
class ApplicationController < ActionController::Base
  layout "main"
  #...
end
```

Avec cette déclaration, toutes les vues de l'application utiliseront `app/views/layouts/main.html.erb` comme mise en page.

##### Choix des mises en page à l'exécution

Vous pouvez utiliser un symbole pour différer le choix de la mise en page jusqu'à ce qu'une requête soit traitée :

```ruby
class ProductsController < ApplicationController
  layout :products_layout

  def show
    @product = Product.find(params[:id])
  end

  private
    def products_layout
      @current_user.special? ? "special" : "products"
    end
end
```

Maintenant, si l'utilisateur actuel est un utilisateur spécial, il obtiendra une mise en page spéciale lorsqu'il consulte un produit.

Vous pouvez même utiliser une méthode en ligne, telle qu'un Proc, pour déterminer la mise en page. Par exemple, si vous passez un objet Proc, le bloc que vous donnez au Proc recevra l'instance du `controller`, de sorte que la mise en page peut être déterminée en fonction de la requête actuelle :

```ruby
class ProductsController < ApplicationController
  layout Proc.new { |controller| controller.request.xhr? ? "popup" : "application" }
end
```

##### Mises en page conditionnelles

Les mises en page spécifiées au niveau du contrôleur prennent en charge les options `:only` et `:except`. Ces options prennent soit un nom de méthode, soit un tableau de noms de méthodes, correspondant aux noms de méthodes dans le contrôleur :

```ruby
class ProductsController < ApplicationController
  layout "product", except: [:index, :rss]
end
```

Avec cette déclaration, la mise en page `product` serait utilisée pour tout sauf les méthodes `rss` et `index`.

##### Héritage des mises en page

Les déclarations de mise en page se propagent vers le bas dans la hiérarchie, et les déclarations de mise en page plus spécifiques l'emportent toujours sur les plus générales. Par exemple :

* `application_controller.rb`

    ```ruby
    class ApplicationController < ActionController::Base
      layout "main"
    end
    ```

* `articles_controller.rb`

    ```ruby
    class ArticlesController < ApplicationController
    end
    ```

* `special_articles_controller.rb`

    ```ruby
    class SpecialArticlesController < ArticlesController
      layout "special"
    end
    ```

* `old_articles_controller.rb`

    ```ruby
    class OldArticlesController < SpecialArticlesController
      layout false

      def show
        @article = Article.find(params[:id])
      end

      def index
        @old_articles = Article.older
        render layout: "old"
      end
      # ...
    end
    ```

Dans cette application :

* En général, les vues seront rendues dans la mise en page `main`
* `ArticlesController#index` utilisera la mise en page `main`
* `SpecialArticlesController#index` utilisera la mise en page `special`
* `OldArticlesController#show` n'utilisera aucune mise en page du tout
* `OldArticlesController#index` utilisera la mise en page `old`
##### Héritage de modèle

Similaire à la logique d'héritage de mise en page, si un modèle ou une partie n'est pas trouvé dans le chemin conventionnel, le contrôleur recherchera un modèle ou une partie à rendre dans sa chaîne d'héritage. Par exemple:

```ruby
# app/controllers/application_controller.rb
class ApplicationController < ActionController::Base
end
```

```ruby
# app/controllers/admin_controller.rb
class AdminController < ApplicationController
end
```

```ruby
# app/controllers/admin/products_controller.rb
class Admin::ProductsController < AdminController
  def index
  end
end
```

L'ordre de recherche pour une action `admin/products#index` sera:

* `app/views/admin/products/`
* `app/views/admin/`
* `app/views/application/`

Cela fait de `app/views/application/` un endroit idéal pour vos parties communes, qui peuvent ensuite être rendues dans votre ERB comme ceci:

```erb
<%# app/views/admin/products/index.html.erb %>
<%= render @products || "empty_list" %>

<%# app/views/application/_empty_list.html.erb %>
Il n'y a pas d'éléments dans cette liste <em>encore</em>.
```

#### Éviter les erreurs de double rendu

Tôt ou tard, la plupart des développeurs Rails verront le message d'erreur "Can only render or redirect once per action". Bien que cela soit ennuyeux, il est relativement facile à résoudre. Cela se produit généralement en raison d'une incompréhension fondamentale du fonctionnement de `render`.

Par exemple, voici du code qui déclenchera cette erreur:

```ruby
def show
  @book = Book.find(params[:id])
  if @book.special?
    render action: "special_show"
  end
  render action: "regular_show"
end
```

Si `@book.special?` est évalué à `true`, Rails commencera le processus de rendu pour insérer la variable `@book` dans la vue `special_show`. Mais cela ne stoppera pas le reste du code dans l'action `show` et lorsque Rails atteindra la fin de l'action, il commencera à rendre la vue `regular_show` - et générera une erreur. La solution est simple: assurez-vous de n'avoir qu'un seul appel à `render` ou `redirect` dans un seul chemin de code. Une chose qui peut aider est `return`. Voici une version corrigée de la méthode:

```ruby
def show
  @book = Book.find(params[:id])
  if @book.special?
    render action: "special_show"
    return
  end
  render action: "regular_show"
end
```

Notez que le rendu implicite effectué par ActionController détecte si `render` a été appelé, donc le code suivant fonctionnera sans erreur:

```ruby
def show
  @book = Book.find(params[:id])
  if @book.special?
    render action: "special_show"
  end
end
```

Cela rendra un livre avec `special?` défini avec le modèle `special_show`, tandis que les autres livres seront rendus avec le modèle `show` par défaut.

### Utilisation de `redirect_to`

Une autre façon de gérer le renvoi des réponses à une requête HTTP est avec [`redirect_to`][]. Comme vous l'avez vu, `render` indique à Rails quelle vue (ou autre ressource) utiliser pour construire une réponse. La méthode `redirect_to` fait quelque chose de complètement différent: elle indique au navigateur d'envoyer une nouvelle requête pour une URL différente. Par exemple, vous pouvez rediriger depuis n'importe quel endroit de votre code vers l'index des photos de votre application avec cet appel:

```ruby
redirect_to photos_url
```

Vous pouvez utiliser [`redirect_back`][] pour renvoyer l'utilisateur à la page d'où il vient. Cette localisation est extraite de l'en-tête `HTTP_REFERER` qui n'est pas garanti d'être défini par le navigateur, vous devez donc fournir la `fallback_location` à utiliser dans ce cas.

```ruby
redirect_back(fallback_location: root_path)
```

NOTE: `redirect_to` et `redirect_back` n'arrêtent pas et ne retournent pas immédiatement de l'exécution de la méthode, mais définissent simplement des réponses HTTP. Les instructions qui se produisent après eux dans une méthode seront exécutées. Vous pouvez arrêter l'exécution par un `return` explicite ou un autre mécanisme d'arrêt, si nécessaire.


#### Obtenir un code d'état de redirection différent

Rails utilise le code d'état HTTP 302, une redirection temporaire, lorsque vous appelez `redirect_to`. Si vous souhaitez utiliser un code d'état différent, par exemple 301, une redirection permanente, vous pouvez utiliser l'option `:status`:

```ruby
redirect_to photos_path, status: 301
```

Tout comme l'option `:status` pour `render`, `:status` pour `redirect_to` accepte à la fois des désignations d'en-tête numériques et symboliques.

#### La différence entre `render` et `redirect_to`

Parfois, les développeurs inexpérimentés considèrent `redirect_to` comme une sorte de commande `goto`, déplaçant l'exécution d'un endroit à un autre dans votre code Rails. Ce n'est _pas_ correct. Votre code s'arrête et attend une nouvelle requête du navigateur. Il se trouve simplement que vous avez indiqué au navigateur quelle requête il devrait effectuer ensuite, en renvoyant un code d'état HTTP 302.

Considérez ces actions pour voir la différence:

```ruby
def index
  @books = Book.all
end

def show
  @book = Book.find_by(id: params[:id])
  if @book.nil?
    render action: "index"
  end
end
```

Avec le code sous cette forme, il y aura probablement un problème si la variable `@book` est `nil`. Rappelez-vous, un `render :action` n'exécute aucun code dans l'action cible, donc rien ne configurera probablement la variable `@books` dont la vue `index` aura besoin. Une façon de résoudre ce problème est de rediriger au lieu de rendre:
```ruby
def index
  @books = Book.all
end

def show
  @book = Book.find_by(id: params[:id])
  if @book.nil?
    redirect_to action: :index
  end
end
```

Avec ce code, le navigateur fera une nouvelle demande pour la page d'index, le code dans la méthode `index` s'exécutera et tout ira bien.

Le seul inconvénient de ce code est qu'il nécessite un aller-retour vers le navigateur : le navigateur a demandé l'action show avec `/books/1` et le contrôleur constate qu'il n'y a pas de livres, donc le contrôleur envoie une réponse de redirection 302 au navigateur lui indiquant d'aller à `/books/`, le navigateur obéit et envoie une nouvelle demande au contrôleur demandant maintenant l'action `index`, le contrôleur récupère alors tous les livres dans la base de données et rend le modèle index, l'envoyant de nouveau au navigateur qui l'affiche ensuite sur votre écran.

Bien que dans une petite application, cette latence supplémentaire ne pose peut-être pas de problème, il est important d'y penser si le temps de réponse est une préoccupation. Nous pouvons démontrer une façon de gérer cela avec un exemple artificiel :

```ruby
def index
  @books = Book.all
end

def show
  @book = Book.find_by(id: params[:id])
  if @book.nil?
    @books = Book.all
    flash.now[:alert] = "Votre livre n'a pas été trouvé"
    render "index"
  end
end
```

Cela détecterait qu'il n'y a pas de livres avec l'ID spécifié, remplirait la variable d'instance `@books` avec tous les livres du modèle, puis rendrait directement le modèle `index.html.erb`, le renvoyant au navigateur avec un message d'alerte flash pour informer l'utilisateur de ce qui s'est passé.

### Utilisation de `head` pour construire des réponses avec en-têtes uniquement

La méthode [`head`][] peut être utilisée pour envoyer des réponses avec uniquement des en-têtes au navigateur. La méthode `head` accepte un nombre ou un symbole (voir [tableau de référence](#l-option-status)) représentant un code d'état HTTP. L'argument des options est interprété comme un hachage de noms et de valeurs d'en-tête. Par exemple, vous pouvez renvoyer uniquement un en-tête d'erreur :

```ruby
head :bad_request
```

Cela produirait l'en-tête suivant :

```http
HTTP/1.1 400 Bad Request
Connection: close
Date: Sun, 24 Jan 2010 12:15:53 GMT
Transfer-Encoding: chunked
Content-Type: text/html; charset=utf-8
X-Runtime: 0.013483
Set-Cookie: _blog_session=...snip...; path=/; HttpOnly
Cache-Control: no-cache
```

Ou vous pouvez utiliser d'autres en-têtes HTTP pour transmettre d'autres informations :

```ruby
head :created, location: photo_path(@photo)
```

Ce qui produirait :

```http
HTTP/1.1 201 Created
Connection: close
Date: Sun, 24 Jan 2010 12:16:44 GMT
Transfer-Encoding: chunked
Location: /photos/1
Content-Type: text/html; charset=utf-8
X-Runtime: 0.083496
Set-Cookie: _blog_session=...snip...; path=/; HttpOnly
Cache-Control: no-cache
```

Structure des mises en page
---------------------------

Lorsque Rails rend une vue en tant que réponse, il le fait en combinant la vue avec la mise en page actuelle, en utilisant les règles de recherche de la mise en page actuelle qui ont été couvertes précédemment dans ce guide. Dans une mise en page, vous avez accès à trois outils pour combiner différents éléments de sortie afin de former la réponse globale :

* Les balises d'actifs
* `yield` et [`content_for`][]
* Partiels


### Les assistants de balises d'actifs

Les assistants de balises d'actifs fournissent des méthodes pour générer du HTML qui lie des vues à des flux, du JavaScript, des feuilles de style, des images, des vidéos et des fichiers audio. Il existe six assistants de balises d'actifs disponibles dans Rails :

* [`auto_discovery_link_tag`][]
* [`javascript_include_tag`][]
* [`stylesheet_link_tag`][]
* [`image_tag`][]
* [`video_tag`][]
* [`audio_tag`][]

Vous pouvez utiliser ces balises dans des mises en page ou d'autres vues, bien que les balises `auto_discovery_link_tag`, `javascript_include_tag` et `stylesheet_link_tag` soient le plus souvent utilisées dans la section `<head>` d'une mise en page.

AVERTISSEMENT : Les assistants de balises d'actifs ne vérifient pas l'existence des ressources aux emplacements spécifiés ; ils supposent simplement que vous savez ce que vous faites et génèrent le lien.


#### Lien vers des flux avec `auto_discovery_link_tag`

L'assistant [`auto_discovery_link_tag`][] construit du HTML que la plupart des navigateurs et des lecteurs de flux peuvent utiliser pour détecter la présence de flux RSS, Atom ou JSON. Il prend le type de lien (`:rss`, `:atom` ou `:json`), un hachage d'options qui sont transmises à url_for, et un hachage d'options pour la balise :

```erb
<%= auto_discovery_link_tag(:rss, {action: "feed"},
  {title: "Flux RSS"}) %>
```

Il existe trois options de balise disponibles pour `auto_discovery_link_tag` :

* `:rel` spécifie la valeur `rel` dans le lien. La valeur par défaut est "alternate".
* `:type` spécifie un type MIME explicite. Rails générera automatiquement un type MIME approprié.
* `:title` spécifie le titre du lien. La valeur par défaut est la valeur `:type` en majuscules, par exemple, "ATOM" ou "RSS".
#### Lien vers des fichiers JavaScript avec `javascript_include_tag`

L'aide [`javascript_include_tag`][] renvoie une balise HTML `script` pour chaque source fournie.

Si vous utilisez Rails avec le [pipeline d'actifs](asset_pipeline.html) activé, cette aide générera un lien vers `/assets/javascripts/` plutôt que `public/javascripts` qui était utilisé dans les versions précédentes de Rails. Ce lien est ensuite servi par le pipeline d'actifs.

Un fichier JavaScript dans une application Rails ou un moteur Rails se trouve dans l'un des trois emplacements suivants : `app/assets`, `lib/assets` ou `vendor/assets`. Ces emplacements sont expliqués en détail dans la section [Organisation des actifs dans le guide du pipeline d'actifs](asset_pipeline.html#asset-organization).

Vous pouvez spécifier un chemin complet par rapport à la racine du document, ou une URL, si vous préférez. Par exemple, pour lier à un fichier JavaScript qui se trouve dans un répertoire appelé `javascripts` à l'intérieur de `app/assets`, `lib/assets` ou `vendor/assets`, vous feriez ceci :

```erb
<%= javascript_include_tag "main" %>
```

Rails générera alors une balise `script` comme ceci :

```html
<script src='/assets/main.js'></script>
```

La demande de cet actif est ensuite servie par le gem Sprockets.

Pour inclure plusieurs fichiers tels que `app/assets/javascripts/main.js` et `app/assets/javascripts/columns.js` en même temps :

```erb
<%= javascript_include_tag "main", "columns" %>
```

Pour inclure `app/assets/javascripts/main.js` et `app/assets/javascripts/photos/columns.js` :

```erb
<%= javascript_include_tag "main", "/photos/columns" %>
```

Pour inclure `http://example.com/main.js` :

```erb
<%= javascript_include_tag "http://example.com/main.js" %>
```

#### Lien vers des fichiers CSS avec `stylesheet_link_tag`

L'aide [`stylesheet_link_tag`][] renvoie une balise HTML `<link>` pour chaque source fournie.

Si vous utilisez Rails avec le pipeline d'actifs activé, cette aide générera un lien vers `/assets/stylesheets/`. Ce lien est ensuite traité par le gem Sprockets. Un fichier de feuille de style peut être stocké dans l'un des trois emplacements suivants : `app/assets`, `lib/assets` ou `vendor/assets`.

Vous pouvez spécifier un chemin complet par rapport à la racine du document, ou une URL. Par exemple, pour lier à un fichier de feuille de style qui se trouve dans un répertoire appelé `stylesheets` à l'intérieur de `app/assets`, `lib/assets` ou `vendor/assets`, vous feriez ceci :

```erb
<%= stylesheet_link_tag "main" %>
```

Pour inclure `app/assets/stylesheets/main.css` et `app/assets/stylesheets/columns.css` :

```erb
<%= stylesheet_link_tag "main", "columns" %>
```

Pour inclure `app/assets/stylesheets/main.css` et `app/assets/stylesheets/photos/columns.css` :

```erb
<%= stylesheet_link_tag "main", "photos/columns" %>
```

Pour inclure `http://example.com/main.css` :

```erb
<%= stylesheet_link_tag "http://example.com/main.css" %>
```

Par défaut, `stylesheet_link_tag` crée des liens avec `rel="stylesheet"`. Vous pouvez remplacer cette valeur par défaut en spécifiant une option appropriée (`:rel`) :

```erb
<%= stylesheet_link_tag "main_print", media: "print" %>
```

#### Lien vers des images avec `image_tag`

L'aide [`image_tag`][] construit une balise HTML `<img />` pour le fichier spécifié. Par défaut, les fichiers sont chargés à partir de `public/images`.

AVERTISSEMENT : Notez que vous devez spécifier l'extension de l'image.

```erb
<%= image_tag "header.png" %>
```

Vous pouvez fournir un chemin vers l'image si vous le souhaitez :

```erb
<%= image_tag "icons/delete.gif" %>
```

Vous pouvez fournir un hachage d'options HTML supplémentaires :

```erb
<%= image_tag "icons/delete.gif", {height: 45} %>
```

Vous pouvez fournir un texte alternatif pour l'image qui sera utilisé si l'utilisateur a désactivé les images dans son navigateur. Si vous ne spécifiez pas de texte alternatif explicitement, il sera par défaut le nom du fichier, en majuscules et sans extension. Par exemple, ces deux balises d'image renverraient le même code :

```erb
<%= image_tag "home.gif" %>
<%= image_tag "home.gif", alt: "Home" %>
```

Vous pouvez également spécifier une balise de taille spéciale, au format "{largeur}x{hauteur}" :

```erb
<%= image_tag "home.gif", size: "50x20" %>
```

En plus des balises spéciales ci-dessus, vous pouvez fournir un hachage final d'options HTML standard, telles que `:class`, `:id` ou `:name` :

```erb
<%= image_tag "home.gif", alt: "Go Home",
                          id: "HomeImage",
                          class: "nav_bar" %>
```

#### Lien vers des vidéos avec `video_tag`

L'aide [`video_tag`][] construit une balise HTML5 `<video>` pour le fichier spécifié. Par défaut, les fichiers sont chargés à partir de `public/videos`.

```erb
<%= video_tag "movie.ogg" %>
```

Produit

```erb
<video src="/videos/movie.ogg" />
```

Comme avec `image_tag`, vous pouvez fournir un chemin, soit absolu, soit relatif au répertoire `public/videos`. De plus, vous pouvez spécifier l'option `size: "#{largeur}x#{hauteur}"` comme avec `image_tag`. Les balises vidéo peuvent également avoir l'une des options HTML spécifiées à la fin (`id`, `class`, etc.).

La balise vidéo prend également en charge toutes les options HTML `<video>`, y compris :

* `poster: "nom_image.png"`, fournit une image à afficher à la place de la vidéo avant qu'elle ne commence à jouer.
* `autoplay: true`, lance la lecture de la vidéo au chargement de la page.
* `loop: true`, boucle la vidéo une fois qu'elle atteint la fin.
* `controls: true`, fournit des contrôles fournis par le navigateur pour que l'utilisateur interagisse avec la vidéo.
* `autobuffer: true`, la vidéo préchargera le fichier pour l'utilisateur au chargement de la page.
Vous pouvez également spécifier plusieurs vidéos à lire en passant un tableau de vidéos à la balise `video_tag` :

```erb
<%= video_tag ["trailer.ogg", "movie.ogg"] %>
```

Cela produira :

```erb
<video>
  <source src="/videos/trailer.ogg">
  <source src="/videos/movie.ogg">
</video>
```

#### Lien vers des fichiers audio avec la balise `audio_tag`

L'aide [`audio_tag`][] construit une balise HTML5 `<audio>` pour le fichier spécifié. Par défaut, les fichiers sont chargés à partir de `public/audios`.

```erb
<%= audio_tag "music.mp3" %>
```

Vous pouvez fournir un chemin vers le fichier audio si vous le souhaitez :

```erb
<%= audio_tag "music/first_song.mp3" %>
```

Vous pouvez également fournir un hachage d'options supplémentaires, telles que `:id`, `:class`, etc.

Comme la balise `video_tag`, la balise `audio_tag` a des options spéciales :

* `autoplay: true`, commence à lire l'audio lors du chargement de la page
* `controls: true`, fournit des contrôles fournis par le navigateur pour que l'utilisateur interagisse avec l'audio.
* `autobuffer: true`, l'audio préchargera le fichier pour l'utilisateur lors du chargement de la page.

### Comprendre `yield`

Dans le contexte d'une mise en page, `yield` identifie une section où le contenu de la vue doit être inséré. La manière la plus simple d'utiliser cela est d'avoir un seul `yield`, dans lequel l'ensemble du contenu de la vue en cours de rendu est inséré :

```html+erb
<html>
  <head>
  </head>
  <body>
  <%= yield %>
  </body>
</html>
```

Vous pouvez également créer une mise en page avec plusieurs régions de rendu :

```html+erb
<html>
  <head>
  <%= yield :head %>
  </head>
  <body>
  <%= yield %>
  </body>
</html>
```

Le corps principal de la vue sera toujours rendu dans le `yield` sans nom. Pour rendre du contenu dans un `yield` nommé, vous utilisez la méthode `content_for`.

### Utilisation de la méthode `content_for`

La méthode [`content_for`][] vous permet d'insérer du contenu dans un bloc `yield` nommé de votre mise en page. Par exemple, cette vue fonctionnerait avec la mise en page que vous venez de voir :

```html+erb
<% content_for :head do %>
  <title>Une page simple</title>
<% end %>

<p>Bonjour, Rails !</p>
```

Le résultat du rendu de cette page dans la mise en page fournie serait le HTML suivant :

```html+erb
<html>
  <head>
  <title>Une page simple</title>
  </head>
  <body>
  <p>Bonjour, Rails !</p>
  </body>
</html>
```

La méthode `content_for` est très utile lorsque votre mise en page contient des régions distinctes telles que des barres latérales et des pieds de page qui doivent recevoir leurs propres blocs de contenu insérés. Elle est également utile pour insérer des balises qui chargent des fichiers JavaScript ou CSS spécifiques à une page dans l'en-tête d'une mise en page générique.

### Utilisation de Partials

Les modèles partiels - généralement appelés simplement "partials" - sont un autre moyen de diviser le processus de rendu en morceaux plus gérables. Avec un partiel, vous pouvez déplacer le code de rendu d'une partie spécifique d'une réponse vers son propre fichier.

#### Nommer les Partials

Pour rendre un partiel dans une vue, vous utilisez la méthode [`render`][view.render] dans la vue :

```html+erb
<%= render "menu" %>
```

Cela rendra un fichier nommé `_menu.html.erb` à cet endroit dans la vue en cours de rendu. Notez le caractère de soulignement initial : les partiels sont nommés avec un soulignement initial pour les distinguer des vues régulières, même s'ils sont référencés sans le soulignement. Cela est également vrai lorsque vous importez un partiel à partir d'un autre dossier :

```html+erb
<%= render "shared/menu" %>
```

Ce code importera le partiel depuis `app/views/shared/_menu.html.erb`.


#### Utilisation de Partials pour simplifier les vues

Une façon d'utiliser les partiels est de les considérer comme l'équivalent de sous-routines : comme un moyen de déplacer les détails d'une vue afin de mieux comprendre ce qui se passe. Par exemple, vous pourriez avoir une vue qui ressemble à ceci :

```erb
<%= render "shared/ad_banner" %>

<h1>Produits</h1>

<p>Voici quelques-uns de nos excellents produits :</p>
...

<%= render "shared/footer" %>
```

Ici, les partiels `_ad_banner.html.erb` et `_footer.html.erb` pourraient contenir du contenu partagé par de nombreuses pages de votre application. Vous n'avez pas besoin de voir les détails de ces sections lorsque vous vous concentrez sur une page particulière.

Comme on l'a vu dans les sections précédentes de ce guide, `yield` est un outil très puissant pour nettoyer vos mises en page. Gardez à l'esprit que c'est du pur Ruby, vous pouvez donc l'utiliser presque partout. Par exemple, nous pouvons l'utiliser pour rendre les définitions de mise en page de formulaire DRY pour plusieurs ressources similaires :

* `users/index.html.erb`

    ```html+erb
    <%= render "shared/search_filters", search: @q do |form| %>
      <p>
        Le nom contient : <%= form.text_field :name_contains %>
      </p>
    <% end %>
    ```

* `roles/index.html.erb`

    ```html+erb
    <%= render "shared/search_filters", search: @q do |form| %>
      <p>
        Le titre contient : <%= form.text_field :title_contains %>
      </p>
    <% end %>
    ```
* `shared/_search_filters.html.erb`

    ```html+erb
    <%= form_with model: search do |form| %>
      <h1>Formulaire de recherche :</h1>
      <fieldset>
        <%= yield form %>
      </fieldset>
      <p>
        <%= form.submit "Rechercher" %>
      </p>
    <% end %>
    ```

CONSEIL : Pour le contenu partagé entre toutes les pages de votre application, vous pouvez utiliser des partiels directement à partir des mises en page.

#### Mises en page partielles

Un partiel peut utiliser son propre fichier de mise en page, tout comme une vue peut utiliser une mise en page. Par exemple, vous pouvez appeler un partiel de cette manière :

```erb
<%= render partial: "zone_lien", layout: "barre_grise" %>
```

Cela rechercherait un partiel nommé `_zone_lien.html.erb` et le rendrait en utilisant la mise en page `_barre_grise.html.erb`. Notez que les mises en page pour les partiels suivent le même nom avec un trait de soulignement en tête que les partiels réguliers, et sont placées dans le même dossier que le partiel auquel elles appartiennent (pas dans le dossier principal `layouts`).

Notez également que spécifier explicitement `:partial` est nécessaire lors de la transmission d'options supplémentaires telles que `:layout`.

#### Transmission de variables locales

Vous pouvez également transmettre des variables locales aux partiels, ce qui les rend encore plus puissants et flexibles. Par exemple, vous pouvez utiliser cette technique pour réduire la duplication entre les pages de création et de modification, tout en conservant un peu de contenu distinct :

* `new.html.erb`

    ```html+erb
    <h1>Nouvelle zone</h1>
    <%= render partial: "formulaire", locals: {zone: @zone} %>
    ```

* `edit.html.erb`

    ```html+erb
    <h1>Modification de la zone</h1>
    <%= render partial: "formulaire", locals: {zone: @zone} %>
    ```

* `_formulaire.html.erb`

    ```html+erb
    <%= form_with model: zone do |form| %>
      <p>
        <b>Nom de la zone</b><br>
        <%= form.text_field :name %>
      </p>
      <p>
        <%= form.submit %>
      </p>
    <% end %>
    ```

Bien que le même partiel soit rendu dans les deux vues, l'aide à la soumission de Action View renverra "Créer la zone" pour l'action de création et "Mettre à jour la zone" pour l'action de modification.

Pour transmettre une variable locale à un partiel uniquement dans des cas spécifiques, utilisez `local_assigns`.

* `index.html.erb`

    ```erb
    <%= render user.articles %>
    ```

* `show.html.erb`

    ```erb
    <%= render article, full: true %>
    ```

* `_article.html.erb`

    ```erb
    <h2><%= article.title %></h2>

    <% if local_assigns[:full] %>
      <%= simple_format article.body %>
    <% else %>
      <%= truncate article.body %>
    <% end %>
    ```

De cette façon, il est possible d'utiliser le partiel sans avoir besoin de déclarer toutes les variables locales.

Chaque partiel a également une variable locale portant le même nom que le partiel (moins le trait de soulignement initial). Vous pouvez transmettre un objet à cette variable locale via l'option `:object` :

```erb
<%= render partial: "client", object: @nouveau_client %>
```

Dans le partiel `client`, la variable `client` fera référence à `@nouveau_client` de la vue parente.

Si vous avez une instance d'un modèle à rendre dans un partiel, vous pouvez utiliser une syntaxe abrégée :

```erb
<%= render @client %>
```

En supposant que la variable d'instance `@client` contient une instance du modèle `Client`, cela utilisera `_client.html.erb` pour le rendre et passera la variable locale `client` dans le partiel qui fera référence à la variable d'instance `@client` dans la vue parente.

#### Rendu de collections

Les partiels sont très utiles pour le rendu de collections. Lorsque vous transmettez une collection à un partiel via l'option `:collection`, le partiel sera inséré une fois pour chaque élément de la collection :

* `index.html.erb`

    ```html+erb
    <h1>Produits</h1>
    <%= render partial: "produit", collection: @produits %>
    ```

* `_produit.html.erb`

    ```html+erb
    <p>Nom du produit : <%= produit.name %></p>
    ```

Lorsqu'un partiel est appelé avec une collection au pluriel, les instances individuelles du partiel ont accès à l'élément de la collection qui est rendu via une variable portant le nom du partiel. Dans ce cas, le partiel est `_produit`, et dans le partiel `_produit`, vous pouvez vous référer à `produit` pour obtenir l'instance qui est rendue.

Il existe également une syntaxe abrégée pour cela. En supposant que `@produits` est une collection d'instances de `Produit`, vous pouvez simplement écrire ceci dans `index.html.erb` pour obtenir le même résultat :

```html+erb
<h1>Produits</h1>
<%= render @produits %>
```

Rails détermine le nom du partiel à utiliser en examinant le nom du modèle dans la collection. En fait, vous pouvez même créer une collection hétérogène et la rendre de cette façon, et Rails choisira le partiel approprié pour chaque élément de la collection :

* `index.html.erb`

    ```html+erb
    <h1>Contacts</h1>
    <%= render [client1, employe1, client2, employe2] %>
    ```

* `clients/_client.html.erb`

    ```html+erb
    <p>Client : <%= client.name %></p>
    ```

* `employes/_employe.html.erb`

    ```html+erb
    <p>Employé : <%= employe.name %></p>
    ```

Dans ce cas, Rails utilisera les partiels `client` ou `employe` selon le cas pour chaque élément de la collection.
Dans le cas où la collection est vide, `render` renverra nil, il devrait donc être assez simple de fournir un contenu alternatif.

```html+erb
<h1>Produits</h1>
<%= render(@products) || "Il n'y a aucun produit disponible." %>
```

#### Variables locales

Pour utiliser un nom de variable locale personnalisé dans la partial, spécifiez l'option `:as` dans l'appel à la partial :

```erb
<%= render partial: "product", collection: @products, as: :item %>
```

Avec ce changement, vous pouvez accéder à une instance de la collection `@products` en tant que variable locale `item` dans la partial.

Vous pouvez également passer des variables locales arbitraires à n'importe quelle partial que vous affichez avec l'option `locals: {}` :

```erb
<%= render partial: "product", collection: @products,
           as: :item, locals: {title: "Page des produits"} %>
```

Dans ce cas, la partial aura accès à une variable locale `title` avec la valeur "Page des produits".

#### Variables de compteur

Rails met également à disposition une variable de compteur dans une partial appelée par la collection. La variable est nommée d'après le nom de la partial suivi de `_counter`. Par exemple, lors de l'affichage d'une collection `@products`, la partial `_product.html.erb` peut accéder à la variable `product_counter`. La variable indexe le nombre de fois que la partial a été affichée dans la vue englobante, en commençant par une valeur de `0` lors du premier affichage.

```erb
# index.html.erb
<%= render partial: "product", collection: @products %>
```

```erb
# _product.html.erb
<%= product_counter %> # 0 pour le premier produit, 1 pour le deuxième produit...
```

Cela fonctionne également lorsque le nom de la partial est modifié à l'aide de l'option `as:`. Ainsi, si vous avez fait `as: :item`, la variable de compteur serait `item_counter`.

#### Modèles d'espacement

Vous pouvez également spécifier une deuxième partial à afficher entre les instances de la partial principale en utilisant l'option `:spacer_template` :

```erb
<%= render partial: @products, spacer_template: "product_ruler" %>
```

Rails affichera la partial `_product_ruler` (sans données transmises) entre chaque paire de partials `_product`.

#### Mises en page de partials de collection

Lors de l'affichage de collections, il est également possible d'utiliser l'option `:layout` :

```erb
<%= render partial: "product", collection: @products, layout: "special_layout" %>
```

La mise en page sera affichée avec la partial pour chaque élément de la collection. Les variables d'objet actuel et d'objet_counter seront également disponibles dans la mise en page, de la même manière qu'elles le sont dans la partial.

### Utilisation de mises en page imbriquées

Il se peut que votre application nécessite une mise en page légèrement différente de votre mise en page d'application habituelle pour prendre en charge un contrôleur particulier. Au lieu de répéter la mise en page principale et de la modifier, vous pouvez le faire en utilisant des mises en page imbriquées (parfois appelées sous-modèles). Voici un exemple :

Supposons que vous ayez la mise en page suivante pour `ApplicationController` :

* `app/views/layouts/application.html.erb`

    ```html+erb
    <html>
    <head>
      <title><%= @page_title or "Titre de la page" %></title>
      <%= stylesheet_link_tag "layout" %>
      <style><%= yield :stylesheets %></style>
    </head>
    <body>
      <div id="top_menu">Éléments du menu supérieur ici</div>
      <div id="menu">Éléments du menu ici</div>
      <div id="content"><%= content_for?(:content) ? yield(:content) : yield %></div>
    </body>
    </html>
    ```

Sur les pages générées par `NewsController`, vous souhaitez masquer le menu supérieur et ajouter un menu droit :

* `app/views/layouts/news.html.erb`

    ```html+erb
    <% content_for :stylesheets do %>
      #top_menu {display: none}
      #right_menu {float: right; background-color: yellow; color: black}
    <% end %>
    <% content_for :content do %>
      <div id="right_menu">Éléments du menu droit ici</div>
      <%= content_for?(:news_content) ? yield(:news_content) : yield %>
    <% end %>
    <%= render template: "layouts/application" %>
    ```

C'est tout. Les vues News utiliseront la nouvelle mise en page, masquant le menu supérieur et ajoutant un nouveau menu droit à l'intérieur de la div "content".

Il existe plusieurs façons d'obtenir des résultats similaires avec différents schémas de sous-modèles en utilisant cette technique. Notez qu'il n'y a pas de limite dans les niveaux d'imbrication. On peut utiliser la méthode `ActionView::render` via `render template: 'layouts/news'` pour baser une nouvelle mise en page sur la mise en page News. Si vous êtes sûr de ne pas utiliser de sous-modèle pour la mise en page `News`, vous pouvez remplacer `content_for?(:news_content) ? yield(:news_content) : yield` simplement par `yield`.
[controller.render]: https://api.rubyonrails.org/classes/ActionController/Rendering.html#method-i-render
[`redirect_to`]: https://api.rubyonrails.org/classes/ActionController/Redirecting.html#method-i-redirect_to
[`head`]: https://api.rubyonrails.org/classes/ActionController/Head.html#method-i-head
[`layout`]: https://api.rubyonrails.org/classes/ActionView/Layouts/ClassMethods.html#method-i-layout
[`redirect_back`]: https://api.rubyonrails.org/classes/ActionController/Redirecting.html#method-i-redirect_back
[`content_for`]: https://api.rubyonrails.org/classes/ActionView/Helpers/CaptureHelper.html#method-i-content_for
[`auto_discovery_link_tag`]: https://api.rubyonrails.org/classes/ActionView/Helpers/AssetTagHelper.html#method-i-auto_discovery_link_tag
[`javascript_include_tag`]: https://api.rubyonrails.org/classes/ActionView/Helpers/AssetTagHelper.html#method-i-javascript_include_tag
[`stylesheet_link_tag`]: https://api.rubyonrails.org/classes/ActionView/Helpers/AssetTagHelper.html#method-i-stylesheet_link_tag
[`image_tag`]: https://api.rubyonrails.org/classes/ActionView/Helpers/AssetTagHelper.html#method-i-image_tag
[`video_tag`]: https://api.rubyonrails.org/classes/ActionView/Helpers/AssetTagHelper.html#method-i-video_tag
[`audio_tag`]: https://api.rubyonrails.org/classes/ActionView/Helpers/AssetTagHelper.html#method-i-audio_tag
[view.render]: https://api.rubyonrails.org/classes/ActionView/Helpers/RenderingHelper.html#method-i-render
