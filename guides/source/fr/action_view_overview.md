**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: f6b613040c7aed4c76b6648b6fd963cf
Aperçu d'Action View
====================

Après avoir lu ce guide, vous saurez :

* Ce qu'est Action View et comment l'utiliser avec Rails.
* Comment utiliser au mieux les modèles, les partiels et les mises en page.
* Comment utiliser des vues localisées.

--------------------------------------------------------------------------------

Qu'est-ce qu'Action View ?
--------------------

Dans Rails, les requêtes web sont gérées par [Action Controller](action_controller_overview.html) et Action View. En général, Action Controller se charge de communiquer avec la base de données et d'effectuer les actions CRUD si nécessaire. Action View est ensuite responsable de la compilation de la réponse.

Les modèles Action View sont écrits en utilisant du code Ruby intégré dans des balises mêlées à du HTML. Pour éviter d'encombrer les modèles avec du code redondant, plusieurs classes d'aide fournissent des comportements communs pour les formulaires, les dates et les chaînes de caractères. Il est également facile d'ajouter de nouvelles classes d'aide à votre application au fur et à mesure de son évolution.

NOTE : Certaines fonctionnalités d'Action View sont liées à Active Record, mais cela ne signifie pas qu'Action View dépend d'Active Record. Action View est un package indépendant qui peut être utilisé avec n'importe quel type de bibliothèques Ruby.

Utilisation d'Action View avec Rails
----------------------------

Pour chaque contrôleur, il existe un répertoire associé dans le répertoire `app/views` qui contient les fichiers de modèle constituant les vues associées à ce contrôleur. Ces fichiers sont utilisés pour afficher la vue résultant de chaque action du contrôleur.

Jetons un coup d'œil à ce que fait Rails par défaut lors de la création d'une nouvelle ressource à l'aide du générateur de squelette :

```bash
$ bin/rails generate scaffold article
      [...]
      invoke  scaffold_controller
      create    app/controllers/articles_controller.rb
      invoke    erb
      create      app/views/articles
      create      app/views/articles/index.html.erb
      create      app/views/articles/edit.html.erb
      create      app/views/articles/show.html.erb
      create      app/views/articles/new.html.erb
      create      app/views/articles/_form.html.erb
      [...]
```

Il existe une convention de nommage pour les vues dans Rails. En général, les vues portent le même nom que l'action du contrôleur associé, comme vous pouvez le voir ci-dessus.
Par exemple, l'action index du contrôleur `articles_controller.rb` utilisera le fichier de vue `index.html.erb` dans le répertoire `app/views/articles`.
Le HTML complet renvoyé au client est composé d'une combinaison de ce fichier ERB, d'un modèle de mise en page qui l'encadre et de tous les partiels auxquels la vue peut faire référence. Dans ce guide, vous trouverez une documentation plus détaillée sur chacun de ces trois composants.

Comme mentionné, la sortie HTML finale est une composition de trois éléments de Rails : `Modèles`, `Partiels` et `Mises en page`.
Voici un bref aperçu de chacun d'eux.

Modèles
---------

Les modèles Action View peuvent être écrits de plusieurs manières. Si le fichier de modèle a une extension `.erb`, il utilise un mélange de ERB (Ruby intégré) et de HTML. Si le fichier de modèle a une extension `.builder`, la bibliothèque `Builder::XmlMarkup` est utilisée.

Rails prend en charge plusieurs systèmes de modèles et utilise une extension de fichier pour les distinguer. Par exemple, un fichier HTML utilisant le système de modèle ERB aura `.html.erb` comme extension de fichier.

### ERB

Dans un modèle ERB, du code Ruby peut être inclus à l'aide des balises `<% %>` et `<%= %>` . Les balises `<% %>` sont utilisées pour exécuter du code Ruby qui ne renvoie rien, comme des conditions, des boucles ou des blocs, et les balises `<%= %>` sont utilisées lorsque vous souhaitez afficher une sortie.

Considérez la boucle suivante pour les noms :

```html+erb
<h1>Noms de toutes les personnes</h1>
<% @people.each do |person| %>
  Nom : <%= person.name %><br>
<% end %>
```

La boucle est configurée à l'aide de balises d'intégration régulières (`<% %>`) et le nom est inséré à l'aide des balises d'intégration de sortie (`<%= %>`). Notez que ce n'est pas seulement une suggestion d'utilisation : les fonctions de sortie régulières telles que `print` et `puts` ne seront pas rendues dans la vue avec les modèles ERB. Donc cela serait incorrect :

```html+erb
<%# FAUX %>
Bonjour, M. <% puts "Frodo" %>
```

Pour supprimer les espaces blancs en début et en fin de ligne, vous pouvez utiliser `<%-` `-%>` de manière interchangeable avec `<%` et `%>`.

### Builder

Les modèles Builder sont une alternative plus programmatique à ERB. Ils sont particulièrement utiles pour générer du contenu XML. Un objet XmlMarkup nommé `xml` est automatiquement mis à disposition des modèles avec une extension `.builder`.

Voici quelques exemples de base :

```ruby
xml.em("emphasized")
xml.em { xml.b("emph & bold") }
xml.a("A Link", "href" => "https://rubyonrails.org")
xml.target("name" => "compile", "option" => "fast")
```

qui produirait :

```html
<em>emphasized</em>
<em><b>emph &amp; bold</b></em>
<a href="https://rubyonrails.org">A link</a>
<target option="fast" name="compile" />
```

Toute méthode avec un bloc sera traitée comme une balise de balisage XML avec un balisage imbriqué dans le bloc. Par exemple, le suivant :
```ruby
xml.div {
  xml.h1(@person.name)
  xml.p(@person.bio)
}
```

produirait quelque chose comme:

```html
<div>
  <h1>David Heinemeier Hansson</h1>
  <p>Un produit du design danois pendant l'hiver '79...</p>
</div>
```

Voici un exemple complet de flux RSS réellement utilisé sur Basecamp:

```ruby
xml.rss("version" => "2.0", "xmlns:dc" => "http://purl.org/dc/elements/1.1/") do
  xml.channel do
    xml.title(@feed_title)
    xml.link(@url)
    xml.description "Basecamp: Articles récents"
    xml.language "en-us"
    xml.ttl "40"

    for item in @recent_items
      xml.item do
        xml.title(item_title(item))
        xml.description(item_description(item)) if item_description(item)
        xml.pubDate(item_pubDate(item))
        xml.guid(@person.firm.account.url + @recent_items.url(item))
        xml.link(@person.firm.account.url + @recent_items.url(item))
        xml.tag!("dc:creator", item.author_name) if item_has_creator?(item)
      end
    end
  end
end
```

### Jbuilder

[Jbuilder](https://github.com/rails/jbuilder) est une gemme maintenue par l'équipe Rails et incluse dans le `Gemfile` par défaut de Rails. Il est similaire à Builder mais est utilisé pour générer du JSON, au lieu de XML.

Si vous ne l'avez pas, vous pouvez l'ajouter au `Gemfile` avec:

```ruby
gem 'jbuilder'
```

Un objet Jbuilder nommé `json` est automatiquement disponible dans les templates avec une extension `.jbuilder`.

Voici un exemple basique:

```ruby
json.name("Alex")
json.email("alex@example.com")
```

produirait:

```json
{
  "name": "Alex",
  "email": "alex@example.com"
}
```

Consultez la [documentation de Jbuilder](https://github.com/rails/jbuilder#jbuilder) pour plus d'exemples et d'informations.

### Mise en cache des templates

Par défaut, Rails compile chaque template en une méthode pour le rendre. En environnement de développement, lorsque vous modifiez un template, Rails vérifie l'heure de modification du fichier et le recompile.

Partials
--------

Les partials - généralement appelés "partials" - sont un autre moyen de diviser le processus de rendu en morceaux plus gérables. Avec les partials, vous pouvez extraire des morceaux de code de vos templates pour les placer dans des fichiers séparés et les réutiliser dans vos templates.

### Rendu des partials

Pour rendre un partial dans une vue, vous utilisez la méthode `render` dans la vue:

```erb
<%= render "menu" %>
```

Cela rendra un fichier nommé `_menu.html.erb` à cet endroit dans la vue qui est en cours de rendu. Notez le caractère de soulignement en tête: les partials sont nommés avec un soulignement en tête pour les distinguer des vues régulières, même s'ils sont référencés sans le soulignement. Cela est vrai même lorsque vous importez un partial à partir d'un autre dossier:

```erb
<%= render "shared/menu" %>
```

Ce code importera le partial à partir de `app/views/shared/_menu.html.erb`.

### Utilisation des partials pour simplifier les vues

Une façon d'utiliser les partials est de les considérer comme l'équivalent de sous-routines; un moyen de déplacer les détails d'une vue afin de mieux comprendre ce qui se passe. Par exemple, vous pourriez avoir une vue qui ressemble à ceci:

```html+erb
<%= render "shared/ad_banner" %>

<h1>Produits</h1>

<p>Voici quelques-uns de nos excellents produits:</p>
<% @products.each do |product| %>
  <%= render partial: "product", locals: { product: product } %>
<% end %>

<%= render "shared/footer" %>
```

Ici, les partials `_ad_banner.html.erb` et `_footer.html.erb` pourraient contenir du contenu partagé entre de nombreuses pages de votre application. Vous n'avez pas besoin de voir les détails de ces sections lorsque vous vous concentrez sur une page particulière.

### `render` sans les options `partial` et `locals`

Dans l'exemple ci-dessus, `render` prend 2 options: `partial` et `locals`. Mais si ce sont les seules options que vous souhaitez passer, vous pouvez ignorer l'utilisation de ces options. Par exemple, au lieu de:

```erb
<%= render partial: "product", locals: { product: @product } %>
```

Vous pouvez également faire:

```erb
<%= render "product", product: @product %>
```

### Les options `as` et `object`

Par défaut, `ActionView::Partials::PartialRenderer` a son objet dans une variable locale portant le même nom que le template. Ainsi, étant donné:

```erb
<%= render partial: "product" %>
```

dans le partial `_product`, nous aurons `@product` dans la variable locale `product`, comme si nous avions écrit:

```erb
<%= render partial: "product", locals: { product: @product } %>
```

L'option `object` peut être utilisée pour spécifier directement quel objet est rendu dans le partial; utile lorsque l'objet du template se trouve ailleurs (par exemple, dans une variable d'instance différente ou dans une variable locale).

Par exemple, au lieu de:

```erb
<%= render partial: "product", locals: { product: @item } %>
```

nous ferions:

```erb
<%= render partial: "product", object: @item %>
```

Avec l'option `as`, nous pouvons spécifier un nom différent pour ladite variable locale. Par exemple, si nous voulions que ce soit `item` au lieu de `product`, nous ferions:

```erb
<%= render partial: "product", object: @item, as: "item" %>
```

Cela équivaut à
```erb
<%= render partial: "product", locals: { item: @item } %>
```

### Rendu de collections

Généralement, un modèle aura besoin d'itérer sur une collection et de rendre un sous-modèle pour chacun des éléments. Ce modèle a été implémenté sous la forme d'une méthode unique qui accepte un tableau et rend un modèle partiel pour chacun des éléments du tableau.

Ainsi, cet exemple de rendu de tous les produits :

```erb
<% @products.each do |product| %>
  <%= render partial: "product", locals: { product: product } %>
<% end %>
```

peut être réécrit en une seule ligne :

```erb
<%= render partial: "product", collection: @products %>
```

Lorsqu'un modèle partiel est appelé avec une collection, les instances individuelles du modèle partiel ont accès au membre de la collection qui est rendu via une variable nommée d'après le modèle partiel. Dans ce cas, le modèle partiel est `_product`, et à l'intérieur, vous pouvez vous référer à `product` pour obtenir le membre de la collection qui est rendu.

Vous pouvez utiliser une syntaxe abrégée pour le rendu de collections. En supposant que `@products` est une collection d'instances de `Product`, vous pouvez simplement écrire ce qui suit pour obtenir le même résultat :

```erb
<%= render @products %>
```

Rails détermine le nom du modèle partiel à utiliser en regardant le nom du modèle dans la collection, `Product` dans ce cas. En fait, vous pouvez même rendre une collection composée d'instances de modèles différents en utilisant cette syntaxe abrégée, et Rails choisira le modèle partiel approprié pour chaque membre de la collection.

### Modèles d'espacement

Vous pouvez également spécifier un deuxième modèle partiel à rendre entre les instances du modèle partiel principal en utilisant l'option `:spacer_template` :

```erb
<%= render partial: @products, spacer_template: "product_ruler" %>
```

Rails rendra le modèle partiel `_product_ruler` (sans données lui étant transmises) entre chaque paire de modèles partiels `_product`.

### Locaux stricts

Par défaut, les modèles acceptent n'importe quel `locals` en tant qu'arguments de mot-clé. Pour définir quels `locals` un modèle accepte, ajoutez un commentaire magique `locals` :

```erb
<%# locals: (message:) -%>
<%= message %>
```

Des valeurs par défaut peuvent également être fournies :

```erb
<%# locals: (message: "Bonjour, monde !") -%>
<%= message %>
```

Ou les `locals` peuvent être désactivés complètement :

```erb
<%# locals: () %>
```

Mises en page
-------

Les mises en page peuvent être utilisées pour rendre un modèle de vue commun autour des résultats des actions du contrôleur Rails. En général, une application Rails aura quelques mises en page dans lesquelles les pages seront rendues. Par exemple, un site pourrait avoir une mise en page pour un utilisateur connecté et une autre pour le côté marketing ou commercial du site. La mise en page pour un utilisateur connecté pourrait inclure une navigation de premier niveau qui devrait être présente sur de nombreuses actions du contrôleur. La mise en page commerciale pour une application SaaS pourrait inclure une navigation de premier niveau pour des choses comme les pages "Tarification" et "Contactez-nous". On s'attendrait à ce que chaque mise en page ait un aspect et une convivialité différents. Vous pouvez en savoir plus sur les mises en page dans le guide [Mises en page et rendu dans Rails](layouts_and_rendering.html).

### Modèles partiels

Les modèles partiels peuvent avoir leurs propres mises en page appliquées. Ces mises en page sont différentes de celles appliquées à une action du contrôleur, mais elles fonctionnent de manière similaire.

Supposons que nous affichions un article sur une page qui devrait être enveloppé dans une `div` à des fins d'affichage. Tout d'abord, nous allons créer un nouvel `Article` :

```ruby
Article.create(body: 'Les modèles partiels sont cool !')
```

Dans le modèle `show`, nous allons rendre le modèle partiel `_article` enveloppé dans la mise en page `box` :

**articles/show.html.erb**

```erb
<%= render partial: 'article', layout: 'box', locals: { article: @article } %>
```

La mise en page `box` enveloppe simplement le modèle partiel `_article` dans une `div` :

**articles/_box.html.erb**

```html+erb
<div class='box'>
  <%= yield %>
</div>
```

Notez que la mise en page partielle a accès à la variable locale `article` qui a été transmise à l'appel `render`. Cependant, contrairement aux mises en page globales de l'application, les mises en page partielles conservent le préfixe de soulignement.

Vous pouvez également rendre un bloc de code dans une mise en page partielle au lieu d'appeler `yield`. Par exemple, si nous n'avions pas le modèle partiel `_article`, nous pourrions faire ceci à la place :

**articles/show.html.erb**

```html+erb
<% render(layout: 'box', locals: { article: @article }) do %>
  <div>
    <p><%= article.body %></p>
  </div>
<% end %>
```

En supposant que nous utilisons le même modèle partiel `_box` que ci-dessus, cela produirait le même résultat que l'exemple précédent.

Chemins de vue
----------

Lors du rendu d'une réponse, le contrôleur doit résoudre l'emplacement des différentes vues. Par défaut, il ne recherche que dans le répertoire `app/views`.
Nous pouvons ajouter d'autres emplacements et leur donner une certaine priorité lors de la résolution des chemins en utilisant les méthodes `prepend_view_path` et `append_view_path`.

### Prepend View Path

Cela peut être utile, par exemple, lorsque nous voulons mettre des vues dans un répertoire différent pour les sous-domaines.

Nous pouvons le faire en utilisant :

```ruby
prepend_view_path "app/views/#{request.subdomain}"
```

Ensuite, Action View cherchera d'abord dans ce répertoire lors de la résolution des vues.

### Append View Path

De même, nous pouvons ajouter des chemins :

```ruby
append_view_path "app/views/direct"
```

Cela ajoutera `app/views/direct` à la fin des chemins de recherche.

Helpers
-------

Rails fournit de nombreuses méthodes d'aide à utiliser avec Action View. Celles-ci incluent des méthodes pour :

* Formater les dates, les chaînes de caractères et les nombres
* Créer des liens HTML vers des images, des vidéos, des feuilles de style, etc...
* Sanitiser le contenu
* Créer des formulaires
* Localiser le contenu

Vous pouvez en savoir plus sur les helpers dans le [Guide des helpers d'Action View](action_view_helpers.html) et le [Guide des helpers de formulaire d'Action View](form_helpers.html).

Vues localisées
---------------

Action View a la capacité de rendre des templates différents en fonction de la locale actuelle.

Par exemple, supposons que vous ayez un `ArticlesController` avec une action show. Par défaut, l'appel de cette action rendra `app/views/articles/show.html.erb`. Mais si vous définissez `I18n.locale = :de`, alors `app/views/articles/show.de.html.erb` sera rendu à la place. Si le template localisé n'est pas présent, la version non décorée sera utilisée. Cela signifie que vous n'êtes pas obligé de fournir des vues localisées pour tous les cas, mais elles seront préférées et utilisées si elles sont disponibles.

Vous pouvez utiliser la même technique pour localiser les fichiers de secours dans votre répertoire public. Par exemple, en définissant `I18n.locale = :de` et en créant `public/500.de.html` et `public/404.de.html`, vous pourriez avoir des pages de secours localisées.

Étant donné que Rails ne restreint pas les symboles que vous utilisez pour définir I18n.locale, vous pouvez exploiter ce système pour afficher du contenu différent en fonction de ce que vous voulez. Par exemple, supposons que vous ayez des utilisateurs "experts" qui devraient voir des pages différentes des utilisateurs "normaux". Vous pourriez ajouter ceci à `app/controllers/application_controller.rb` :

```ruby
before_action :set_expert_locale

def set_expert_locale
  I18n.locale = :expert if current_user.expert?
end
```

Ensuite, vous pourriez créer des vues spéciales comme `app/views/articles/show.expert.html.erb` qui ne seraient affichées qu'aux utilisateurs experts.

Vous pouvez en savoir plus sur l'API d'internationalisation (I18n) de Rails [ici](i18n.html).
