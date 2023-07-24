**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 37d2486eee8522a64c5f97f86900b8a6
Aide aux vues d'action
====================

Après avoir lu ce guide, vous saurez :

* Comment formater des dates, des chaînes de caractères et des nombres
* Comment créer des liens vers des images, des vidéos, des feuilles de style, etc.
* Comment nettoyer le contenu
* Comment localiser le contenu

--------------------------------------------------------------------------------

Aperçu des aides fournies par Action View
-------------------------------------------

WIP: Toutes les aides ne sont pas répertoriées ici. Pour une liste complète, consultez la [documentation de l'API](https://api.rubyonrails.org/classes/ActionView/Helpers.html).

Ce qui suit est seulement un bref aperçu des aides disponibles dans Action View. Il est recommandé de consulter la [documentation de l'API](https://api.rubyonrails.org/classes/ActionView/Helpers.html), qui couvre toutes les aides en détail, mais cela devrait servir de bon point de départ.

### AssetTagHelper

Ce module fournit des méthodes pour générer du HTML qui lie les vues aux ressources telles que les images, les fichiers JavaScript, les feuilles de style et les flux.

Par défaut, Rails lie ces ressources à l'hôte actuel dans le dossier public, mais vous pouvez indiquer à Rails de lier les ressources à partir d'un serveur de ressources dédié en définissant [`config.asset_host`][] dans la configuration de l'application, généralement dans `config/environments/production.rb`. Par exemple, supposons que votre hôte de ressources soit `assets.example.com` :

```ruby
config.asset_host = "assets.example.com"
image_tag("rails.png")
# => <img src="http://assets.example.com/images/rails.png" />
```


#### auto_discovery_link_tag

Renvoie une balise de lien que les navigateurs et les lecteurs de flux peuvent utiliser pour détecter automatiquement un flux RSS, Atom ou JSON.

```ruby
auto_discovery_link_tag(:rss, "http://www.example.com/feed.rss", { title: "RSS Feed" })
# => <link rel="alternate" type="application/rss+xml" title="RSS Feed" href="http://www.example.com/feed.rss" />
```

#### image_path

Calcule le chemin d'une ressource image dans le répertoire `app/assets/images`. Les chemins complets à partir de la racine du document seront transmis. Utilisé en interne par `image_tag` pour construire le chemin de l'image.

```ruby
image_path("edit.png") # => /assets/edit.png
```

L'empreinte digitale sera ajoutée au nom de fichier si `config.assets.digest` est défini sur `true`.

```ruby
image_path("edit.png")
# => /assets/edit-2d1a2db63fc738690021fedb5a65b68e.png
```

#### image_url

Calcule l'URL d'une ressource image dans le répertoire `app/assets/images`. Cela appellera `image_path` en interne et fusionnera avec votre hôte actuel ou votre hôte de ressources.

```ruby
image_url("edit.png") # => http://www.example.com/assets/edit.png
```

#### image_tag

Renvoie une balise d'image HTML pour la source. La source peut être un chemin complet ou un fichier qui existe dans votre répertoire `app/assets/images`.

```ruby
image_tag("icon.png") # => <img src="/assets/icon.png" />
```

#### javascript_include_tag

Renvoie une balise de script HTML pour chacune des sources fournies. Vous pouvez passer le nom de fichier (l'extension `.js` est facultative) des fichiers JavaScript qui existent dans votre répertoire `app/assets/javascripts` pour les inclure dans la page actuelle, ou vous pouvez passer le chemin complet par rapport à la racine de votre document.

```ruby
javascript_include_tag "common"
# => <script src="/assets/common.js"></script>
```

#### javascript_path

Calcule le chemin d'une ressource JavaScript dans le répertoire `app/assets/javascripts`. Si le nom de fichier source n'a pas d'extension, `.js` sera ajouté. Les chemins complets à partir de la racine du document seront transmis. Utilisé en interne par `javascript_include_tag` pour construire le chemin du script.

```ruby
javascript_path "common" # => /assets/common.js
```

#### javascript_url

Calcule l'URL d'une ressource JavaScript dans le répertoire `app/assets/javascripts`. Cela appellera `javascript_path` en interne et fusionnera avec votre hôte actuel ou votre hôte de ressources.

```ruby
javascript_url "common"
# => http://www.example.com/assets/common.js
```

#### stylesheet_link_tag

Renvoie une balise de lien de feuille de style pour les sources spécifiées en arguments. Si vous ne spécifiez pas d'extension, `.css` sera ajouté automatiquement.

```ruby
stylesheet_link_tag "application"
# => <link href="/assets/application.css" rel="stylesheet" />
```

#### stylesheet_path

Calcule le chemin d'une ressource de feuille de style dans le répertoire `app/assets/stylesheets`. Si le nom de fichier source n'a pas d'extension, `.css` sera ajouté. Les chemins complets à partir de la racine du document seront transmis. Utilisé en interne par `stylesheet_link_tag` pour construire le chemin de la feuille de style.

```ruby
stylesheet_path "application" # => /assets/application.css
```

#### stylesheet_url

Calcule l'URL d'une ressource de feuille de style dans le répertoire `app/assets/stylesheets`. Cela appellera `stylesheet_path` en interne et fusionnera avec votre hôte actuel ou votre hôte de ressources.

```ruby
stylesheet_url "application"
# => http://www.example.com/assets/application.css
```

### AtomFeedHelper

#### atom_feed

Cet assistant facilite la création d'un flux Atom. Voici un exemple d'utilisation complet :

**config/routes.rb**

```ruby
resources :articles
```

**app/controllers/articles_controller.rb**

```ruby
def index
  @articles = Article.all

  respond_to do |format|
    format.html
    format.atom
  end
end
```

**app/views/articles/index.atom.builder**

```ruby
atom_feed do |feed|
  feed.title("Articles Index")
  feed.updated(@articles.first.created_at)

  @articles.each do |article|
    feed.entry(article) do |entry|
      entry.title(article.title)
      entry.content(article.body, type: 'html')

      entry.author do |author|
        author.name(article.author_name)
      end
    end
  end
end
```

### BenchmarkHelper

#### benchmark

Vous permet de mesurer le temps d'exécution d'un bloc dans un modèle et enregistre le résultat dans le journal. Entourez ce bloc autour des opérations coûteuses ou des éventuels goulots d'étranglement pour obtenir une mesure de temps pour l'opération.
```html+erb
<% benchmark "Traitement des fichiers de données" do %>
  <%= expensive_files_operation %>
<% end %>
```

Cela ajouterait quelque chose comme "Traitement des fichiers de données (0.34523)" dans le journal, que vous pouvez ensuite utiliser pour comparer les durées lors de l'optimisation de votre code.

### CacheHelper

#### cache

Une méthode pour mettre en cache des fragments d'une vue plutôt qu'une action ou une page entière. Cette technique est utile pour mettre en cache des éléments tels que des menus, des listes de sujets d'actualité, des fragments HTML statiques, etc. Cette méthode prend un bloc qui contient le contenu que vous souhaitez mettre en cache. Voir `AbstractController::Caching::Fragments` pour plus d'informations.

```erb
<% cache do %>
  <%= render "shared/footer" %>
<% end %>
```

### CaptureHelper

#### capture

La méthode `capture` vous permet d'extraire une partie d'un modèle dans une variable. Vous pouvez ensuite utiliser cette variable n'importe où dans vos modèles ou votre mise en page.

```html+erb
<% @greeting = capture do %>
  <p>Bienvenue ! La date et l'heure sont <%= Time.now %></p>
<% end %>
```

La variable capturée peut ensuite être utilisée n'importe où ailleurs.

```html+erb
<html>
  <head>
    <title>Bienvenue !</title>
  </head>
  <body>
    <%= @greeting %>
  </body>
</html>
```

#### content_for

L'appel à `content_for` stocke un bloc de balisage dans un identifiant pour une utilisation ultérieure. Vous pouvez faire des appels ultérieurs au contenu stocké dans d'autres modèles ou la mise en page en passant l'identifiant en argument à `yield`.

Par exemple, supposons que nous avons une mise en page d'application standard, mais aussi une page spéciale qui nécessite un certain JavaScript que le reste du site n'a pas besoin. Nous pouvons utiliser `content_for` pour inclure ce JavaScript sur notre page spéciale sans alourdir le reste du site.

**app/views/layouts/application.html.erb**

```html+erb
<html>
  <head>
    <title>Bienvenue !</title>
    <%= yield :special_script %>
  </head>
  <body>
    <p>Bienvenue ! La date et l'heure sont <%= Time.now %></p>
  </body>
</html>
```

**app/views/articles/special.html.erb**

```html+erb
<p>Ceci est une page spéciale.</p>

<% content_for :special_script do %>
  <script>alert('Bonjour !')</script>
<% end %>
```

### DateHelper

#### distance_of_time_in_words

Rapporte la distance approximative dans le temps entre deux objets Time ou Date ou des entiers en secondes. Définissez `include_seconds` sur true si vous souhaitez des approximations plus détaillées.

```ruby
distance_of_time_in_words(Time.now, Time.now + 15.seconds)
# => moins d'une minute
distance_of_time_in_words(Time.now, Time.now + 15.seconds, include_seconds: true)
# => moins de 20 secondes
```

#### time_ago_in_words

Comme `distance_of_time_in_words`, mais où `to_time` est fixé à `Time.now`.

```ruby
time_ago_in_words(3.minutes.from_now) # => 3 minutes
```

### DebugHelper

Renvoie une balise `pre` contenant l'objet déversé par YAML. Cela crée une manière très lisible d'inspecter un objet.

```ruby
my_hash = { 'first' => 1, 'second' => 'two', 'third' => [1, 2, 3] }
debug(my_hash)
```

```html
<pre class='debug_dump'>---
first: 1
second: two
third:
- 1
- 2
- 3
</pre>
```

### FormHelper

Les helpers de formulaire sont conçus pour faciliter le travail avec les modèles par rapport à l'utilisation d'éléments HTML standard en fournissant un ensemble de méthodes pour créer des formulaires basés sur vos modèles. Cet helper génère le HTML pour les formulaires, en fournissant une méthode pour chaque type de saisie (par exemple, texte, mot de passe, sélection, etc.). Lorsque le formulaire est soumis (c'est-à-dire lorsque l'utilisateur appuie sur le bouton de soumission ou que form.submit est appelé via JavaScript), les saisies du formulaire seront regroupées dans l'objet params et renvoyées au contrôleur.

Vous pouvez en savoir plus sur les helpers de formulaire dans le [Guide des helpers de formulaire Action View](form_helpers.html).

### JavaScriptHelper

Fournit des fonctionnalités pour travailler avec JavaScript dans vos vues.

#### escape_javascript

Échappe les retours chariot et les guillemets simples et doubles pour les segments JavaScript.

#### javascript_tag

Renvoie une balise JavaScript enveloppant le code fourni.

```ruby
javascript_tag "alert('Tout va bien')"
```

```html
<script>
//<![CDATA[
alert('Tout va bien')
//]]>
</script>
```

### NumberHelper

Fournit des méthodes pour convertir des nombres en chaînes formatées. Des méthodes sont fournies pour les numéros de téléphone, les devises, les pourcentages, la précision, la notation positionnelle et la taille des fichiers.

#### number_to_currency

Formate un nombre en une chaîne de devise (par exemple, $13.65).

```ruby
number_to_currency(1234567890.50) # => $1,234,567,890.50
```

#### number_to_human

Affiche joliment (formate et approxime) un nombre pour qu'il soit plus lisible par les utilisateurs ; utile pour les nombres qui peuvent devenir très grands.

```ruby
number_to_human(1234)    # => 1,23 millier
number_to_human(1234567) # => 1,23 million
```

#### number_to_human_size

Formate les octets en une représentation plus compréhensible ; utile pour indiquer la taille des fichiers aux utilisateurs.

```ruby
number_to_human_size(1234)    # => 1,21 Ko
number_to_human_size(1234567) # => 1,18 Mo
```

#### number_to_percentage

Formate un nombre en une chaîne de pourcentage.
```ruby
number_to_percentage(100, precision: 0) # => 100%
```

#### number_to_phone

Formate un nombre en un numéro de téléphone (par défaut, aux États-Unis).

```ruby
number_to_phone(1235551234) # => 123-555-1234
```

#### number_with_delimiter

Formate un nombre avec des milliers groupés en utilisant un délimiteur.

```ruby
number_with_delimiter(12345678) # => 12,345,678
```

#### number_with_precision

Formate un nombre avec le niveau de `precision` spécifié, qui est par défaut de 3.

```ruby
number_with_precision(111.2345)               # => 111.235
number_with_precision(111.2345, precision: 2) # => 111.23
```

### SanitizeHelper

Le module SanitizeHelper fournit un ensemble de méthodes pour nettoyer le texte des éléments HTML indésirables.

#### sanitize

Cette méthode sanitize va encoder en HTML toutes les balises et supprimer tous les attributs qui ne sont pas spécifiquement autorisés.

```ruby
sanitize @article.body
```

Si les options `:attributes` ou `:tags` sont passées, seuls les attributs et balises mentionnés sont autorisés et rien d'autre.

```ruby
sanitize @article.body, tags: %w(table tr td), attributes: %w(id class style)
```

Pour modifier les valeurs par défaut pour plusieurs utilisations, par exemple en ajoutant des balises de tableau par défaut :

```ruby
class Application < Rails::Application
  config.action_view.sanitized_allowed_tags = 'table', 'tr', 'td'
end
```

#### sanitize_css(style)

Nettoie un bloc de code CSS.

#### strip_links(html)

Supprime toutes les balises de lien du texte en ne laissant que le texte du lien.

```ruby
strip_links('<a href="https://rubyonrails.org">Ruby on Rails</a>')
# => Ruby on Rails
```

```ruby
strip_links('emails to <a href="mailto:me@email.com">me@email.com</a>.')
# => emails to me@email.com.
```

```ruby
strip_links('Blog: <a href="http://myblog.com/">Visit</a>.')
# => Blog: Visit.
```

#### strip_tags(html)

Supprime toutes les balises HTML du html, y compris les commentaires.
Cette fonctionnalité est alimentée par le gem rails-html-sanitizer.

```ruby
strip_tags("Strip <i>these</i> tags!")
# => Strip these tags!
```

```ruby
strip_tags("<b>Bold</b> no more!  <a href='more.html'>See more</a>")
# => Bold no more!  See more
```

NB : La sortie peut encore contenir des caractères non échappés '<', '>', '&' et perturber les navigateurs.

### UrlHelper

Fournit des méthodes pour créer des liens et obtenir des URL qui dépendent du sous-système de routage.

#### url_for

Retourne l'URL pour l'ensemble des `options` fournies.

##### Exemples

```ruby
url_for @profile
# => /profiles/1

url_for [ @hotel, @booking, page: 2, line: 3 ]
# => /hotels/1/bookings/1?line=3&page=2
```

#### link_to

Crée un lien vers une URL dérivée de `url_for` en interne. Principalement utilisé pour créer des liens de ressources RESTful, qui pour cet exemple, se résume à passer des modèles à `link_to`.

**Exemples**

```ruby
link_to "Profile", @profile
# => <a href="/profiles/1">Profile</a>
```

Vous pouvez également utiliser un bloc si votre cible de lien ne peut pas être incluse dans le paramètre du nom. Exemple en ERB :

```html+erb
<%= link_to @profile do %>
  <strong><%= @profile.name %></strong> -- <span>Check it out!</span>
<% end %>
```

produirait :

```html
<a href="/profiles/1">
  <strong>David</strong> -- <span>Check it out!</span>
</a>
```

Voir [la documentation de l'API pour plus d'informations](https://api.rubyonrails.org/classes/ActionView/Helpers/UrlHelper.html#method-i-link_to)

#### button_to

Génère un formulaire qui soumet vers l'URL passée. Le formulaire a un bouton de soumission avec la valeur du `name`.

##### Exemples

```html+erb
<%= button_to "Sign in", sign_in_path %>
```

produirait approximativement quelque chose comme :

```html
<form method="post" action="/sessions" class="button_to">
  <input type="submit" value="Sign in" />
</form>
```

Voir [la documentation de l'API pour plus d'informations](https://api.rubyonrails.org/classes/ActionView/Helpers/UrlHelper.html#method-i-button_to)

### CsrfHelper

Renvoie les balises meta "csrf-param" et "csrf-token" avec le nom du paramètre et du jeton de protection contre les attaques de falsification de requête intersite.

```html
<%= csrf_meta_tags %>
```

REMARQUE : Les formulaires classiques génèrent des champs masqués, ils n'utilisent donc pas ces balises. Plus de détails peuvent être trouvés dans le [Guide de sécurité de Rails](security.html#cross-site-request-forgery-csrf).
[`config.asset_host`]: configuring.html#config-asset-host
