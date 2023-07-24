**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: c1e56036aa9fd68276daeec5a9407096
Travailler avec JavaScript dans Rails
================================

Ce guide couvre les options d'intégration de fonctionnalités JavaScript dans votre application Rails,
y compris les options pour utiliser des packages JavaScript externes et comment utiliser Turbo avec
Rails.

Après avoir lu ce guide, vous saurez :

* Comment utiliser Rails sans avoir besoin de Node.js, Yarn ou d'un bundler JavaScript.
* Comment créer une nouvelle application Rails en utilisant des import maps, esbuild, rollup ou webpack pour regrouper
  votre JavaScript.
* Ce qu'est Turbo, et comment l'utiliser.
* Comment utiliser les helpers HTML Turbo fournis par Rails.

--------------------------------------------------------------------------------

Import Maps
-----------

[Les import maps](https://github.com/rails/importmap-rails) vous permettent d'importer des modules JavaScript en utilisant
des noms logiques qui correspondent directement aux fichiers versionnés depuis le navigateur. Les import maps sont la méthode
par défaut à partir de Rails 7, permettant à quiconque de construire des applications JavaScript modernes en utilisant la plupart des packages NPM
sans avoir besoin de transpiler ou de regrouper.

Les applications utilisant les import maps n'ont pas besoin de [Node.js](https://nodejs.org/en/) ou
[Yarn](https://yarnpkg.com/) pour fonctionner. Si vous prévoyez d'utiliser Rails avec `importmap-rails` pour
gérer vos dépendances JavaScript, il n'est pas nécessaire d'installer Node.js ou Yarn.

Lors de l'utilisation des import maps, aucun processus de build séparé n'est requis, il suffit de démarrer votre serveur avec
`bin/rails server` et vous êtes prêt à partir.

### Installation de importmap-rails

Importmap pour Rails est automatiquement inclus dans Rails 7+ pour les nouvelles applications, mais vous pouvez également l'installer manuellement dans les applications existantes :

```bash
$ bin/bundle add importmap-rails
```

Exécutez la tâche d'installation :

```bash
$ bin/rails importmap:install
```

### Ajout de packages NPM avec importmap-rails

Pour ajouter de nouveaux packages à votre application alimentée par import map, exécutez la commande `bin/importmap pin`
depuis votre terminal :

```bash
$ bin/importmap pin react react-dom
```

Ensuite, importez le package dans `application.js` comme d'habitude :

```javascript
import React from "react"
import ReactDOM from "react-dom"
```

Ajout de packages NPM avec des bundlers JavaScript
--------

Les import maps sont la méthode par défaut pour les nouvelles applications Rails, mais si vous préférez le regroupement JavaScript traditionnel,
vous pouvez créer de nouvelles applications Rails avec votre choix de
[esbuild](https://esbuild.github.io/), [webpack](https://webpack.js.org/) ou
[rollup.js](https://rollupjs.org/guide/en/).

Pour utiliser un bundler à la place des import maps dans une nouvelle application Rails, passez l'option `—javascript` ou `-j`
à `rails new` :

```bash
$ rails new my_new_app --javascript=webpack
OU
$ rails new my_new_app -j webpack
```

Ces options de bundling sont accompagnées d'une configuration simple et d'une intégration avec le pipeline d'assets via le gem [jsbundling-rails](https://github.com/rails/jsbundling-rails).

Lors de l'utilisation d'une option de bundling, utilisez `bin/dev` pour démarrer le serveur Rails et construire le JavaScript pour
le développement.

### Installation de Node.js et Yarn

Si vous utilisez un bundler JavaScript dans votre application Rails, Node.js et Yarn doivent être
installés.

Trouvez les instructions d'installation sur le site web de [Node.js](https://nodejs.org/en/download/) et
vérifiez qu'il est correctement installé avec la commande suivante :

```bash
$ node --version
```

La version de votre runtime Node.js devrait s'afficher. Assurez-vous qu'elle est supérieure à `8.16.0`.

Pour installer Yarn, suivez les instructions d'installation sur le
site web de [Yarn](https://classic.yarnpkg.com/en/docs/install). L'exécution de cette commande devrait afficher
la version de Yarn :

```bash
$ yarn --version
```

Si elle affiche quelque chose comme `1.22.0`, Yarn a été correctement installé.

Choisir entre les import maps et un bundler JavaScript
-----------------------------------------------------

Lorsque vous créez une nouvelle application Rails, vous devrez choisir entre les import maps et une
solution de bundling JavaScript. Chaque application a des exigences différentes, et vous devriez
considérer attentivement vos besoins avant de choisir une option JavaScript, car la migration d'une
option à une autre peut être longue pour les applications volumineuses et complexes.

Les import maps sont l'option par défaut car l'équipe Rails croit en leur potentiel pour
réduire la complexité, améliorer l'expérience des développeurs et offrir des gains de performance.

Pour de nombreuses applications, en particulier celles qui s'appuient principalement sur la pile [Hotwire](https://hotwired.dev/)
pour leurs besoins en JavaScript, les import maps seront la bonne option à long terme. Vous
pouvez en savoir plus sur les raisons qui ont conduit à faire des import maps l'option par défaut dans Rails 7
[ici](https://world.hey.com/dhh/rails-7-will-have-three-great-answers-to-javascript-in-2021-8d68191b).

D'autres applications peuvent encore avoir besoin d'un bundler JavaScript traditionnel. Les exigences qui indiquent
que vous devriez choisir un bundler traditionnel incluent :

* Si votre code nécessite une étape de transpilation, comme JSX ou TypeScript.
* Si vous avez besoin d'utiliser des bibliothèques JavaScript qui incluent du CSS ou qui dépendent d'une autre manière des
  [chargeurs Webpack](https://webpack.js.org/loaders/).
* Si vous êtes absolument sûr d'avoir besoin de
  [tree-shaking](https://webpack.js.org/guides/tree-shaking/).
* Si vous installez Bootstrap, Bulma, PostCSS ou Dart CSS via le gem [cssbundling-rails](https://github.com/rails/cssbundling-rails). Toutes les options fournies par ce gem, à l'exception de Tailwind et Sass, installeront automatiquement `esbuild` pour vous si vous ne spécifiez pas une autre option dans `rails new`.
Turbo
-----

Que vous choisissiez des cartes d'importation ou un bundler traditionnel, Rails est livré avec [Turbo](https://turbo.hotwired.dev/) pour accélérer votre application tout en réduisant considérablement la quantité de JavaScript que vous devrez écrire.

Turbo permet à votre serveur de fournir directement du HTML en alternative aux frameworks front-end prédominants qui réduisent la partie côté serveur de votre application Rails à peu près à une API JSON.

### Turbo Drive

[Turbo Drive](https://turbo.hotwired.dev/handbook/drive) accélère le chargement des pages en évitant les démontages et reconstructions complets de la page à chaque demande de navigation. Turbo Drive est une amélioration et un remplacement de Turbolinks.

### Turbo Frames

[Turbo Frames](https://turbo.hotwired.dev/handbook/frames) permettent de mettre à jour des parties prédéfinies d'une page sur demande, sans affecter le reste du contenu de la page.

Vous pouvez utiliser Turbo Frames pour créer une édition en place sans aucun JavaScript personnalisé, charger du contenu de manière paresseuse et créer facilement des interfaces à onglets rendues côté serveur.

Rails fournit des helpers HTML pour simplifier l'utilisation de Turbo Frames grâce au gem [turbo-rails](https://github.com/hotwired/turbo-rails).

En utilisant ce gem, vous pouvez ajouter un Turbo Frame à votre application avec l'helper `turbo_frame_tag` comme ceci :

```erb
<%= turbo_frame_tag dom_id(post) do %>
  <div>
     <%= link_to post.title, post_path(post) %>
  </div>
<% end %>
```

### Turbo Streams

[Turbo Streams](https://turbo.hotwired.dev/handbook/streams) permettent de livrer des modifications de page sous forme de fragments de HTML enveloppés dans des éléments `<turbo-stream>` auto-exécutables. Les Turbo Streams vous permettent de diffuser les modifications apportées par d'autres utilisateurs via WebSockets et de mettre à jour des parties d'une page après une soumission de formulaire sans nécessiter de chargement complet de la page.

Rails fournit des helpers HTML et côté serveur pour simplifier l'utilisation de Turbo Streams grâce au gem [turbo-rails](https://github.com/hotwired/turbo-rails).

En utilisant ce gem, vous pouvez rendre des Turbo Streams à partir d'une action de contrôleur :

```ruby
def create
  @post = Post.new(post_params)

  respond_to do |format|
    if @post.save
      format.turbo_stream
    else
      format.html { render :new, status: :unprocessable_entity }
    end
  end
end
```

Rails recherchera automatiquement un fichier de vue `.turbo_stream.erb` et rendra cette vue lorsqu'elle est trouvée.

Les réponses Turbo Stream peuvent également être rendues en ligne dans l'action du contrôleur :

```ruby
def create
  @post = Post.new(post_params)

  respond_to do |format|
    if @post.save
      format.turbo_stream { render turbo_stream: turbo_stream.prepend('posts', partial: 'post') }
    else
      format.html { render :new, status: :unprocessable_entity }
    end
  end
end
```

Enfin, les Turbo Streams peuvent être initiés à partir d'un modèle ou d'un job en arrière-plan en utilisant des helpers intégrés. Ces diffusions peuvent être utilisées pour mettre à jour le contenu via une connexion WebSocket à tous les utilisateurs, en maintenant le contenu de la page à jour et en donnant vie à votre application.

Pour diffuser un Turbo Stream à partir d'un modèle, combinez un rappel de modèle comme ceci :

```ruby
class Post < ApplicationRecord
  after_create_commit { broadcast_append_to('posts') }
end
```

Avec une connexion WebSocket configurée sur la page qui doit recevoir les mises à jour comme ceci :

```erb
<%= turbo_stream_from "posts" %>
```

Remplacements pour la fonctionnalité Rails/UJS
--------------------------------------------

Rails 6 est livré avec un outil appelé UJS (Unobtrusive JavaScript). UJS permet aux développeurs de remplacer la méthode de requête HTTP des balises `<a>`, d'ajouter des boîtes de dialogue de confirmation avant d'exécuter une action, et plus encore. UJS était la valeur par défaut avant Rails 7, mais il est maintenant recommandé d'utiliser Turbo à la place.

### Méthode

Cliquer sur des liens entraîne toujours une requête HTTP GET. Si votre application est [RESTful](https://en.wikipedia.org/wiki/Representational_State_Transfer), certains liens sont en réalité des actions qui modifient des données sur le serveur et doivent être effectuées avec des requêtes non-GET. L'attribut `data-turbo-method` permet de marquer de tels liens avec une méthode explicite telle que "post", "put" ou "delete".

Turbo analysera les balises `<a>` de votre application à la recherche de l'attribut de données `turbo-method` et utilisera la méthode spécifiée lorsqu'elle est présente, en remplaçant l'action GET par défaut.

Par exemple :

```erb
<%= link_to "Supprimer le post", post_path(post), data: { turbo_method: "delete" } %>
```

Cela génère :

```html
<a data-turbo-method="delete" href="...">Supprimer le post</a>
```

Une alternative pour changer la méthode d'un lien avec `data-turbo-method` est d'utiliser l'helper `button_to` de Rails. Pour des raisons d'accessibilité, les véritables boutons et formulaires sont préférables pour toute action autre que GET.

### Confirmations

Vous pouvez demander une confirmation supplémentaire à l'utilisateur en ajoutant un attribut `data-turbo-confirm` sur les liens et les formulaires. Lorsque l'utilisateur clique sur le lien ou soumet le formulaire, il sera présenté avec une boîte de dialogue JavaScript `confirm()` contenant le texte de l'attribut. Si l'utilisateur choisit d'annuler, l'action n'est pas exécutée.

Par exemple, avec l'helper `link_to` :

```erb
<%= link_to "Supprimer le post", post_path(post), data: { turbo_method: "delete", turbo_confirm: "Êtes-vous sûr ?" } %>
```

Ce qui génère :

```html
<a href="..." data-turbo-confirm="Êtes-vous sûr ?" data-turbo-method="delete">Supprimer le post</a>
```
Lorsque l'utilisateur clique sur le lien "Supprimer la publication", il sera présenté avec une boîte de dialogue de confirmation "Êtes-vous sûr ?".

L'attribut peut également être utilisé avec l'assistant `button_to`, cependant il doit être ajouté au formulaire que l'assistant `button_to` rend en interne :

```erb
<%= button_to "Supprimer la publication", post, method: :delete, form: { data: { turbo_confirm: "Êtes-vous sûr ?" } } %>
```

### Requêtes Ajax

Lorsque vous effectuez des requêtes non-GET à partir de JavaScript, l'en-tête `X-CSRF-Token` est requis. Sans cet en-tête, les requêtes ne seront pas acceptées par Rails.

NOTE : Ce jeton est requis par Rails pour prévenir les attaques de falsification de requête intersite (CSRF). Pour en savoir plus, consultez le [guide de sécurité](security.html#cross-site-request-forgery-csrf).

[Rails Request.JS](https://github.com/rails/request.js) encapsule la logique d'ajout des en-têtes de requête requis par Rails. Il suffit d'importer la classe `FetchRequest` du package et de l'instancier en passant la méthode de requête, l'URL, les options, puis d'appeler `await request.perform()` et de faire ce que vous voulez avec la réponse.

Par exemple :

```javascript
import { FetchRequest } from '@rails/request.js'

....

async myMethod () {
  const request = new FetchRequest('post', 'localhost:3000/posts', {
    body: JSON.stringify({ name: 'Request.JS' })
  })
  const response = await request.perform()
  if (response.ok) {
    const body = await response.text
  }
}
```

Lorsque vous utilisez une autre bibliothèque pour effectuer des appels Ajax, il est nécessaire d'ajouter vous-même le jeton de sécurité en tant qu'en-tête par défaut. Pour obtenir le jeton, consultez la balise `<meta name='csrf-token' content='THE-TOKEN'>` imprimée par [`csrf_meta_tags`][] dans la vue de votre application. Vous pouvez faire quelque chose comme :

```javascript
document.head.querySelector("meta[name=csrf-token]")?.content
```
[`csrf_meta_tags`]: https://api.rubyonrails.org/classes/ActionView/Helpers/CsrfHelper.html#method-i-csrf_meta_tags
