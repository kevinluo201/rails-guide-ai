**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: a4b9132308ed3786777061bd137af660
Aperçu d'Action Text
====================

Ce guide vous fournit tout ce dont vous avez besoin pour commencer à gérer
du contenu en texte enrichi.

Après avoir lu ce guide, vous saurez :

* Comment configurer Action Text.
* Comment gérer du contenu en texte enrichi.
* Comment styliser du contenu en texte enrichi et des pièces jointes.

--------------------------------------------------------------------------------

Qu'est-ce qu'Action Text ?
--------------------

Action Text apporte du contenu en texte enrichi et des fonctionnalités d'édition à Rails. Il inclut
l'éditeur [Trix](https://trix-editor.org) qui gère tout, du formatage
aux liens en passant par les citations, les listes, les images intégrées et les galeries.
Le contenu en texte enrichi généré par l'éditeur Trix est enregistré dans son propre
modèle RichText qui est associé à n'importe quel modèle Active Record existant dans l'application.
Toutes les images intégrées (ou autres pièces jointes) sont automatiquement stockées à l'aide de
Active Storage et associées au modèle RichText inclus.

## Trix par rapport aux autres éditeurs de texte enrichi

La plupart des éditeurs WYSIWYG sont des enveloppes autour des API `contenteditable` et `execCommand` de HTML,
conçues par Microsoft pour prendre en charge l'édition en direct des pages Web dans Internet Explorer 5.5,
et [ultérieurement rétro-ingénierées](https://blog.whatwg.org/the-road-to-html-5-contenteditable#history)
et copiées par d'autres navigateurs.

Étant donné que ces API n'ont jamais été entièrement spécifiées ou documentées,
et étant donné que les éditeurs HTML WYSIWYG sont d'une ampleur considérable, chaque
implémentation de navigateur a son propre ensemble de bugs et d'excentricités,
et les développeurs JavaScript sont laissés pour résoudre les incohérences.

Trix contourne ces incohérences en traitant contenteditable
comme un périphérique d'E/S : lorsque l'entrée parvient à l'éditeur, Trix convertit cette entrée
en une opération d'édition sur son modèle de document interne, puis réaffiche
ce document dans l'éditeur. Cela donne à Trix un contrôle total sur ce qui se passe après chaque frappe, et évite d'avoir à utiliser execCommand du tout.

## Installation

Exécutez `bin/rails action_text:install` pour ajouter le package Yarn et copier la migration nécessaire. De plus, vous devez configurer Active Storage pour les images intégrées et les autres pièces jointes. Veuillez vous référer au guide [Présentation d'Active Storage](active_storage_overview.html).

NOTE : Action Text utilise des relations polymorphiques avec la table `action_text_rich_texts` afin de pouvoir être partagé avec tous les modèles qui ont des attributs de texte enrichi. Si vos modèles avec du contenu Action Text utilisent des valeurs UUID pour les identifiants, tous les modèles qui utilisent des attributs Action Text devront utiliser des valeurs UUID pour leurs identifiants uniques. La migration générée pour Action Text devra également être mise à jour pour spécifier `type: :uuid` pour la ligne `:record` `references`.

Une fois l'installation terminée, une application Rails devrait avoir les modifications suivantes :

1. Les packages `trix` et `@rails/actiontext` doivent être requis dans votre point d'entrée JavaScript.

    ```js
    // application.js
    import "trix"
    import "@rails/actiontext"
    ```

2. La feuille de style `trix` sera incluse avec les styles Action Text dans votre fichier `application.css`.

## Création de contenu en texte enrichi

Ajoutez un champ de texte enrichi à un modèle existant :

```ruby
# app/models/message.rb
class Message < ApplicationRecord
  has_rich_text :content
end
```

ou ajoutez un champ de texte enrichi lors de la création d'un nouveau modèle en utilisant :

```bash
$ bin/rails generate model Message content:rich_text
```

NOTE : vous n'avez pas besoin d'ajouter un champ `content` à votre table `messages`.

Ensuite, utilisez [`rich_text_area`] pour faire référence à ce champ dans le formulaire du modèle :

```erb
<%# app/views/messages/_form.html.erb %>
<%= form_with model: message do |form| %>
  <div class="field">
    <%= form.label :content %>
    <%= form.rich_text_area :content %>
  </div>
<% end %>
```

Et enfin, affichez le contenu en texte enrichi nettoyé sur une page :

```erb
<%= @message.content %>
```

NOTE : Si une ressource jointe se trouve dans le champ `content`, elle peut ne pas s'afficher correctement à moins que vous
n'ayez le package *libvips/libvips42* installé localement sur votre machine.
Consultez leur [documentation d'installation](https://www.libvips.org/install.html) pour savoir comment l'obtenir.

Pour accepter le contenu en texte enrichi, il vous suffit de permettre l'attribut référencé :

```ruby
class MessagesController < ApplicationController
  def create
    message = Message.create! params.require(:message).permit(:title, :content)
    redirect_to message
  end
end
```


## Rendu du contenu en texte enrichi

Par défaut, Action Text affiche le contenu en texte enrichi à l'intérieur d'un élément avec la
classe `.trix-content` :

```html+erb
<%# app/views/layouts/action_text/contents/_content.html.erb %>
<div class="trix-content">
  <%= yield %>
</div>
```

Les éléments avec cette classe, ainsi que l'éditeur Action Text, sont stylisés par la
feuille de style [`trix`](https://unpkg.com/trix/dist/trix.css).
Pour fournir vos propres styles, supprimez la ligne `= require trix` de la
feuille de style `app/assets/stylesheets/actiontext.css` créée par l'installateur.

Pour personnaliser le HTML rendu autour du contenu en texte enrichi, modifiez la
mise en page `app/views/layouts/action_text/contents/_content.html.erb` créée par l'installateur.

Pour personnaliser le HTML rendu pour les images intégrées et autres pièces jointes (connues
sous le nom de blobs), modifiez le modèle `app/views/active_storage/blobs/_blob.html.erb`
créé par l'installateur.
### Rendu des pièces jointes

En plus des pièces jointes téléchargées via Active Storage, Action Text peut intégrer tout ce qui peut être résolu par un [Signed GlobalID](https://github.com/rails/globalid#signed-global-ids).

Action Text rend les éléments `<action-text-attachment>` intégrés en résolvant leur attribut `sgid` en une instance. Une fois résolue, cette instance est transmise à [`render`](https://api.rubyonrails.org/classes/ActionView/Helpers/RenderingHelper.html#method-i-render). Le HTML résultant est intégré en tant que descendant de l'élément `<action-text-attachment>`.

Par exemple, considérons un modèle `User` :

```ruby
# app/models/user.rb
class User < ApplicationRecord
  has_one_attached :avatar
end

user = User.find(1)
user.to_global_id.to_s #=> gid://MyRailsApp/User/1
user.to_signed_global_id.to_s #=> BAh7CEkiCG…
```

Ensuite, considérons un contenu de texte enrichi qui intègre un élément `<action-text-attachment>` qui fait référence au Signed GlobalID de l'instance `User` :

```html
<p>Bonjour, <action-text-attachment sgid="BAh7CEkiCG…"></action-text-attachment>.</p>
```

Action Text utilise la chaîne "BAh7CEkiCG…" pour résoudre l'instance `User`. Ensuite, considérons la vue partielle `users/user` de l'application :

```html+erb
<%# app/views/users/_user.html.erb %>
<span><%= image_tag user.avatar %> <%= user.name %></span>
```

Le HTML résultant rendu par Action Text ressemblerait à ceci :

```html
<p>Bonjour, <action-text-attachment sgid="BAh7CEkiCG…"><span><img src="..."> Jane Doe</span></action-text-attachment>.</p>
```

Pour rendre une autre vue partielle, définissez `User#to_attachable_partial_path` :

```ruby
class User < ApplicationRecord
  def to_attachable_partial_path
    "users/attachable"
  end
end
```

Ensuite, déclarez cette vue partielle. L'instance `User` sera disponible en tant que variable locale partielle `user` :

```html+erb
<%# app/views/users/_attachable.html.erb %>
<span><%= image_tag user.avatar %> <%= user.name %></span>
```

Si Action Text ne parvient pas à résoudre l'instance `User` (par exemple, si l'enregistrement a été supprimé), une vue partielle de secours par défaut sera rendue.

Rails fournit une vue partielle globale pour les pièces jointes manquantes. Cette vue partielle est installée dans votre application à l'emplacement `views/action_text/attachables/missing_attachable` et peut être modifiée si vous souhaitez rendre un HTML différent.

Pour rendre une vue partielle différente pour les pièces jointes manquantes, définissez une méthode de niveau de classe `to_missing_attachable_partial_path` :

```ruby
class User < ApplicationRecord
  def self.to_missing_attachable_partial_path
    "users/missing_attachable"
  end
end
```

Ensuite, déclarez cette vue partielle.

```html+erb
<%# app/views/users/missing_attachable.html.erb %>
<span>Utilisateur supprimé</span>
```

Pour intégrer le rendu de l'élément `<action-text-attachment>` d'Action Text, une classe doit :

* inclure le module `ActionText::Attachable`
* implémenter `#to_sgid(**options)` (disponible via le module [`GlobalID::Identification`][global-id])
* (facultatif) déclarer `#to_attachable_partial_path`
* (facultatif) déclarer une méthode de niveau de classe `#to_missing_attachable_partial_path` pour gérer les enregistrements manquants

Par défaut, toutes les descendantes de `ActiveRecord::Base` incluent le module [`GlobalID::Identification`][global-id] et sont donc compatibles avec `ActionText::Attachable`.


## Éviter les requêtes N+1

Si vous souhaitez précharger le modèle dépendant `ActionText::RichText`, en supposant que votre champ de texte enrichi s'appelle `content`, vous pouvez utiliser la portée nommée :

```ruby
Message.all.with_rich_text_content # Précharge le corps sans les pièces jointes.
Message.all.with_rich_text_content_and_embeds # Précharge à la fois le corps et les pièces jointes.
```

## API / Développement Backend

1. Une API backend (par exemple, en utilisant JSON) a besoin d'un point d'extrémité séparé pour télécharger des fichiers qui crée un `ActiveStorage::Blob` et renvoie son `attachable_sgid` :

    ```json
    {
      "attachable_sgid": "BAh7CEkiCG…"
    }
    ```

2. Prenez ce `attachable_sgid` et demandez à votre frontend de l'insérer dans le contenu de texte enrichi en utilisant une balise `<action-text-attachment>` :

    ```html
    <action-text-attachment sgid="BAh7CEkiCG…"></action-text-attachment>
    ```

Cela est basé sur Basecamp, donc si vous ne trouvez toujours pas ce que vous cherchez, consultez cette [documentation Basecamp](https://github.com/basecamp/bc3-api/blob/master/sections/rich_text.md).
[`rich_text_area`]: https://api.rubyonrails.org/classes/ActionView/Helpers/FormHelper.html#method-i-rich_text_area
[global-id]: https://github.com/rails/globalid#usage
