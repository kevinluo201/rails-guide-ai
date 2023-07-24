**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 0f0bbb2fd67f1843d30e360c15c03c61
Le pipeline d'actifs
==================

Ce guide couvre le pipeline d'actifs.

Après avoir lu ce guide, vous saurez :

* Ce qu'est le pipeline d'actifs et ce qu'il fait.
* Comment organiser correctement les actifs de votre application.
* Les avantages du pipeline d'actifs.
* Comment ajouter un pré-processeur au pipeline.
* Comment empaqueter les actifs avec une gemme.

--------------------------------------------------------------------------------

Qu'est-ce que le pipeline d'actifs ?
---------------------------

Le pipeline d'actifs fournit un cadre pour gérer la livraison des actifs JavaScript et CSS. Cela est réalisé en exploitant des technologies telles que HTTP/2 et des techniques telles que la concaténation et la minification. Enfin, il permet à votre application d'être automatiquement combinée avec des actifs provenant d'autres gemmes.

Le pipeline d'actifs est implémenté par les gemmes [importmap-rails](https://github.com/rails/importmap-rails), [sprockets](https://github.com/rails/sprockets) et [sprockets-rails](https://github.com/rails/sprockets-rails), et est activé par défaut. Vous pouvez le désactiver lors de la création d'une nouvelle application en passant l'option `--skip-asset-pipeline`.

```bash
$ rails new appname --skip-asset-pipeline
```

NOTE : Ce guide se concentre sur le pipeline d'actifs par défaut en n'utilisant que `sprockets` pour le CSS et `importmap-rails` pour le traitement JavaScript. La principale limitation de ces deux outils est qu'ils ne prennent pas en charge la transpilation, vous ne pouvez donc pas utiliser des outils tels que `Babel`, `Typescript`, `Sass`, le format `React JSX` ou `TailwindCSS`. Nous vous encourageons à lire la section [Bibliothèques alternatives](#alternative-libraries) si vous avez besoin de transpilation pour votre JavaScript/CSS.

## Principales fonctionnalités

La première fonctionnalité du pipeline d'actifs est d'insérer une empreinte SHA256 dans chaque nom de fichier afin que le fichier soit mis en cache par le navigateur web et le CDN. Cette empreinte est automatiquement mise à jour lorsque vous modifiez le contenu du fichier, ce qui invalide le cache.

La deuxième fonctionnalité du pipeline d'actifs est d'utiliser des [import maps](https://github.com/WICG/import-maps) lors de la fourniture de fichiers JavaScript. Cela vous permet de créer des applications modernes en utilisant des bibliothèques JavaScript conçues pour les modules ES (ESM) sans avoir besoin de transpilation et de regroupement. À son tour, **cela élimine le besoin de Webpack, yarn, node ou toute autre partie de la chaîne d'outils JavaScript**.

La troisième fonctionnalité du pipeline d'actifs est de concaténer tous les fichiers CSS en un seul fichier principal `.css`, qui est ensuite minifié ou compressé. Comme vous le verrez plus loin dans ce guide, vous pouvez personnaliser cette stratégie pour regrouper les fichiers de la manière qui vous convient. En production, Rails insère une empreinte SHA256 dans chaque nom de fichier afin que le fichier soit mis en cache par le navigateur web. Vous pouvez invalider le cache en modifiant cette empreinte, ce qui se produit automatiquement chaque fois que vous modifiez le contenu du fichier.

La quatrième fonctionnalité du pipeline d'actifs est qu'il permet de coder des actifs via un langage de niveau supérieur pour le CSS.

### Qu'est-ce que l'empreinte et pourquoi devrais-je m'en soucier ?

L'empreinte est une technique qui rend le nom d'un fichier dépendant du contenu du fichier. Lorsque le contenu du fichier change, le nom du fichier change également. Pour un contenu statique ou peu modifié, cela permet de savoir facilement si deux versions d'un fichier sont identiques, même sur différents serveurs ou dates de déploiement.

Lorsqu'un nom de fichier est unique et basé sur son contenu, les en-têtes HTTP peuvent être définies pour encourager les caches partout (que ce soit sur les CDN, chez les fournisseurs d'accès Internet, dans l'équipement de réseau ou dans les navigateurs web) à conserver leur propre copie du contenu. Lorsque le contenu est mis à jour, l'empreinte change. Cela incite les clients distants à demander une nouvelle copie du contenu. C'est généralement appelé _cache busting_.

La technique utilisée par Sprockets pour l'empreinte consiste à insérer un hachage du contenu dans le nom, généralement à la fin. Par exemple, un fichier CSS `global.css`

```
global-908e25f4bf641868d8683022a5b62f54.css
```

C'est la stratégie adoptée par le pipeline d'actifs de Rails.

L'empreinte est activée par défaut pour les environnements de développement et de production. Vous pouvez l'activer ou la désactiver dans votre configuration grâce à l'option [`config.assets.digest`][].

### Qu'est-ce que les Import Maps et pourquoi devrais-je m'en soucier ?

Les Import Maps vous permettent d'importer des modules JavaScript en utilisant des noms logiques qui correspondent à des fichiers versionnés/digérés - directement depuis le navigateur. Vous pouvez donc créer des applications JavaScript modernes en utilisant des bibliothèques JavaScript conçues pour les modules ES (ESM) sans avoir besoin de transpilation ou de regroupement.

Avec cette approche, vous enverrez de nombreux petits fichiers JavaScript au lieu d'un seul gros fichier JavaScript. Grâce à HTTP/2, cela n'entraîne plus de pénalité de performance matérielle lors du transport initial, et offre en fait des avantages substantiels à long terme grâce à de meilleures dynamiques de mise en cache.
Comment utiliser les Import Maps en tant que pipeline d'actifs JavaScript
-----------------------------

Les Import Maps sont le processeur JavaScript par défaut, la logique de génération des import maps est gérée par le gem [`importmap-rails`](https://github.com/rails/importmap-rails).

AVERTISSEMENT : Les import maps sont utilisées uniquement pour les fichiers JavaScript et ne peuvent pas être utilisées pour la livraison de CSS. Consultez la section [Sprockets](#how-to-use-sprockets) pour en savoir plus sur CSS.

Vous pouvez trouver des instructions d'utilisation détaillées sur la page d'accueil du gem, mais il est important de comprendre les bases de `importmap-rails`.

### Comment ça marche

Les import maps sont essentiellement une substitution de chaîne pour ce qu'on appelle les "bare module specifiers". Elles vous permettent de normaliser les noms des imports de modules JavaScript.

Prenons par exemple une telle définition d'import, qui ne fonctionnera pas sans une import map :

```javascript
import React from "react"
```

Vous devriez la définir comme ceci pour que cela fonctionne :

```javascript
import React from "https://ga.jspm.io/npm:react@17.0.2/index.js"
```

Voici l'import map, nous définissons le nom `react` pour être lié à l'adresse `https://ga.jspm.io/npm:react@17.0.2/index.js`. Avec ces informations, notre navigateur accepte la définition simplifiée `import React from "react"`. Pensez à l'import map comme à un alias pour l'adresse source de la bibliothèque.

### Utilisation

Avec `importmap-rails`, vous créez le fichier de configuration importmap en liant le chemin de la bibliothèque à un nom :

```ruby
# config/importmap.rb
pin "application"
pin "react", to: "https://ga.jspm.io/npm:react@17.0.2/index.js"
```

Toutes les import maps configurées doivent être attachées à l'élément `<head>` de votre application en ajoutant `<%= javascript_importmap_tags %>`. Les `javascript_importmap_tags` rendent un ensemble de scripts dans l'élément `head` :

- JSON avec toutes les import maps configurées :

```html
<script type="importmap">
{
  "imports": {
    "application": "/assets/application-39f16dc3f3....js"
    "react": "https://ga.jspm.io/npm:react@17.0.2/index.js"
  }
}
</script>
```

- [`Es-module-shims`](https://github.com/guybedford/es-module-shims) agissant en tant que polyfill assurant la prise en charge des `import maps` sur les anciens navigateurs :

```html
<script src="/assets/es-module-shims.min" async="async" data-turbo-track="reload"></script>
```

- Point d'entrée pour charger JavaScript à partir de `app/javascript/application.js` :

```html
<script type="module">import "application"</script>
```

### Utilisation de packages npm via des CDN JavaScript

Vous pouvez utiliser la commande `./bin/importmap` qui est ajoutée dans le cadre de l'installation de `importmap-rails` pour épingler, désépingler ou mettre à jour des packages npm dans votre import map. Le binstub utilise [`JSPM.org`](https://jspm.org/).

Cela fonctionne comme ceci :

```sh
./bin/importmap pin react react-dom
Pinning "react" to https://ga.jspm.io/npm:react@17.0.2/index.js
Pinning "react-dom" to https://ga.jspm.io/npm:react-dom@17.0.2/index.js
Pinning "object-assign" to https://ga.jspm.io/npm:object-assign@4.1.1/index.js
Pinning "scheduler" to https://ga.jspm.io/npm:scheduler@0.20.2/index.js

./bin/importmap json

{
  "imports": {
    "application": "/assets/application-37f365cbecf1fa2810a8303f4b6571676fa1f9c56c248528bc14ddb857531b95.js",
    "react": "https://ga.jspm.io/npm:react@17.0.2/index.js",
    "react-dom": "https://ga.jspm.io/npm:react-dom@17.0.2/index.js",
    "object-assign": "https://ga.jspm.io/npm:object-assign@4.1.1/index.js",
    "scheduler": "https://ga.jspm.io/npm:scheduler@0.20.2/index.js"
  }
}
```

Comme vous pouvez le voir, les deux packages react et react-dom résolvent un total de quatre dépendances, lorsqu'ils sont résolus via le jspm par défaut.

Maintenant, vous pouvez les utiliser dans votre point d'entrée `application.js` comme vous le feriez avec n'importe quel autre module :

```javascript
import React from "react"
import ReactDOM from "react-dom"
```

Vous pouvez également désigner une version spécifique à épingler :

```sh
./bin/importmap pin react@17.0.1
Pinning "react" to https://ga.jspm.io/npm:react@17.0.1/index.js
Pinning "object-assign" to https://ga.jspm.io/npm:object-assign@4.1.1/index.js
```

Ou même supprimer des épingles :

```sh
./bin/importmap unpin react
Unpinning "react"
Unpinning "object-assign"
```

Vous pouvez contrôler l'environnement du package pour les packages avec des versions "production" (par défaut) et "development" distinctes :

```sh
./bin/importmap pin react --env development
Pinning "react" to https://ga.jspm.io/npm:react@17.0.2/dev.index.js
Pinning "object-assign" to https://ga.jspm.io/npm:object-assign@4.1.1/index.js
```

Vous pouvez également choisir un fournisseur CDN alternatif pris en charge lors de l'épinglage, comme [`unpkg`](https://unpkg.com/) ou [`jsdelivr`](https://www.jsdelivr.com/) ([`jspm`](https://jspm.org/) est le fournisseur par défaut) :

```sh
./bin/importmap pin react --from jsdelivr
Pinning "react" to https://cdn.jsdelivr.net/npm/react@17.0.2/index.js
```

N'oubliez pas, cependant, que si vous passez d'un fournisseur à un autre, vous devrez peut-être nettoyer les dépendances ajoutées par le premier fournisseur qui ne sont pas utilisées par le deuxième fournisseur.

Exécutez `./bin/importmap` pour voir toutes les options.

Notez que cette commande est simplement une enveloppe de commodité pour résoudre les noms de packages logiques en URL de CDN. Vous pouvez également rechercher vous-même les URL de CDN, puis les épingler. Par exemple, si vous voulez utiliser Skypack pour React, vous pouvez simplement ajouter ceci à `config/importmap.rb` :

```ruby
pin "react", to: "https://cdn.skypack.dev/react"
```

### Préchargement des modules épinglés

Pour éviter l'effet de cascade où le navigateur doit charger un fichier après l'autre avant de pouvoir accéder à l'importation la plus profondément imbriquée, importmap-rails prend en charge les liens [modulepreload](https://developers.google.com/web/updates/2017/12/modulepreload). Les modules épinglés peuvent être préchargés en ajoutant `preload: true` à l'épingle.

Il est conseillé de précharger les bibliothèques ou frameworks utilisés dans toute votre application, car cela indiquera au navigateur de les télécharger plus tôt.

Exemple :

```ruby
# config/importmap.rb
pin "@github/hotkey", to: "https://ga.jspm.io/npm:@github/hotkey@1.4.4/dist/index.js", preload: true
pin "md5", to: "https://cdn.jsdelivr.net/npm/md5@2.3.0/md5.js"

# app/views/layouts/application.html.erb
<%= javascript_importmap_tags %>

# inclura le lien suivant avant la configuration de l'importmap :
<link rel="modulepreload" href="https://ga.jspm.io/npm:@github/hotkey@1.4.4/dist/index.js">
...
```
REMARQUE: Consultez le référentiel [`importmap-rails`](https://github.com/rails/importmap-rails) pour la documentation la plus à jour.

Comment utiliser Sprockets
-----------------------------

L'approche naïve pour exposer les ressources de votre application sur le web serait de les stocker dans des sous-répertoires du dossier `public`, tels que `images` et `stylesheets`. Le faire manuellement serait difficile car la plupart des applications web modernes nécessitent que les ressources soient traitées de manière spécifique, par exemple en les compressant et en ajoutant des empreintes digitales aux ressources.

Sprockets est conçu pour prétraiter automatiquement vos ressources stockées dans les répertoires configurés et, après traitement, les exposer dans le dossier `public/assets` avec des empreintes digitales, une compression, la génération de cartes source et d'autres fonctionnalités configurables.

Les ressources peuvent toujours être placées dans la hiérarchie `public`. Toutes les ressources sous `public` seront servies en tant que fichiers statiques par l'application ou le serveur web lorsque [`config.public_file_server.enabled`][] est défini sur true. Vous devez définir des directives `manifest.js` pour les fichiers qui doivent subir un prétraitement avant d'être servis.

En production, Rails compile ces fichiers par défaut dans `public/assets`. Les copies précompilées sont ensuite servies en tant que ressources statiques par le serveur web. Les fichiers dans `app/assets` ne sont jamais servis directement en production.


### Fichiers de manifeste et directives

Lors de la compilation des ressources avec Sprockets, Sprockets doit décider des cibles de premier niveau à compiler, généralement `application.css` et les images. Les cibles de premier niveau sont définies dans le fichier `manifest.js` de Sprockets, par défaut il ressemble à ceci:

```js
//= link_tree ../images
//= link_directory ../stylesheets .css
//= link_tree ../../javascript .js
//= link_tree ../../../vendor/javascript .js
```

Il contient des _directives_ - des instructions qui indiquent à Sprockets quels fichiers requérir pour construire un seul fichier CSS ou JavaScript.

Cela permet d'inclure le contenu de tous les fichiers trouvés dans le répertoire `./app/assets/images` ou ses sous-répertoires, ainsi que tout fichier reconnu comme JS directement dans `./app/javascript` ou `./vendor/javascript`.

Il chargera tout CSS du répertoire `./app/assets/stylesheets` (sans inclure les sous-répertoires). En supposant que vous ayez des fichiers `application.css` et `marketing.css` dans le dossier `./app/assets/stylesheets`, cela vous permettra de charger ces feuilles de style avec `<%= stylesheet_link_tag "application" %>` ou `<%= stylesheet_link_tag "marketing" %>` depuis vos vues.

Vous remarquerez peut-être que nos fichiers JavaScript ne sont pas chargés depuis le répertoire `assets` par défaut, c'est parce que `./app/javascript` est le point d'entrée par défaut pour le gem `importmap-rails` et le dossier `vendor` est l'endroit où les packages JS téléchargés seraient stockés.

Dans le fichier `manifest.js`, vous pouvez également spécifier la directive `link` pour charger un fichier spécifique au lieu de tout le répertoire. La directive `link` nécessite de fournir une extension de fichier explicite.

Sprockets charge les fichiers spécifiés, les traite si nécessaire, les concatène en un seul fichier, puis les compresse (en fonction de la valeur de `config.assets.css_compressor` ou `config.assets.js_compressor`). La compression réduit la taille du fichier, ce qui permet au navigateur de télécharger les fichiers plus rapidement.

### Ressources spécifiques au contrôleur

Lorsque vous générez un scaffold ou un contrôleur, Rails génère également un fichier de feuille de style en cascade pour ce contrôleur. De plus, lors de la génération d'un scaffold, Rails génère le fichier `scaffolds.css`.

Par exemple, si vous générez un `ProjectsController`, Rails ajoutera également un nouveau fichier à `app/assets/stylesheets/projects.css`. Par défaut, ces fichiers seront prêts à être utilisés par votre application immédiatement en utilisant la directive `link_directory` dans le fichier `manifest.js`.

Vous pouvez également choisir d'inclure des fichiers de feuilles de style spécifiques au contrôleur uniquement dans leurs contrôleurs respectifs en utilisant la méthode suivante:

```html+erb
<%= stylesheet_link_tag params[:controller] %>
```

Lorsque vous faites cela, assurez-vous de ne pas utiliser la directive `require_tree` dans votre `application.css`, car cela pourrait entraîner l'inclusion multiple de vos ressources spécifiques au contrôleur.

### Organisation des ressources

Les ressources du pipeline peuvent être placées à l'intérieur d'une application dans l'un des trois emplacements suivants: `app/assets`, `lib/assets` ou `vendor/assets`.

* `app/assets` est destiné aux ressources appartenant à l'application, telles que des images personnalisées ou des feuilles de style.

* `app/javascript` est destiné à votre code JavaScript

* `vendor/[assets|javascript]` est destiné aux ressources appartenant à des entités externes, telles que des frameworks CSS ou des bibliothèques JavaScript. Gardez à l'esprit que le code tiers avec des références à d'autres fichiers également traités par le pipeline de ressources (images, feuilles de style, etc.) devra être réécrit pour utiliser des helpers comme `asset_path`.

D'autres emplacements peuvent être configurés dans le fichier `manifest.js`, consultez la section [Fichiers de manifeste et directives](#manifest-files-and-directives).

#### Chemins de recherche

Lorsqu'un fichier est référencé à partir d'un manifeste ou d'un helper, Sprockets recherche tous les emplacements spécifiés dans `manifest.js`. Vous pouvez afficher le chemin de recherche en inspectant [`Rails.application.config.assets.paths`](configuring.html#config-assets-paths) dans la console Rails.
#### Utilisation des fichiers d'index comme des proxies pour les dossiers

Sprockets utilise des fichiers nommés `index` (avec les extensions pertinentes) à des fins spéciales.

Par exemple, si vous avez une bibliothèque CSS avec de nombreux modules, qui est stockée dans `lib/assets/stylesheets/library_name`, le fichier `lib/assets/stylesheets/library_name/index.css` sert de manifeste pour tous les fichiers de cette bibliothèque. Ce fichier pourrait inclure une liste de tous les fichiers requis dans l'ordre, ou une simple directive `require_tree`.

C'est également assez similaire à la façon dont un fichier dans `public/library_name/index.html` peut être atteint par une requête à `/library_name`. Cela signifie que vous ne pouvez pas utiliser directement un fichier d'index.

La bibliothèque dans son ensemble peut être accédée dans les fichiers `.css` comme ceci :

```css
/* ...
*= require library_name
*/
```

Cela simplifie la maintenance et garde les choses propres en permettant de regrouper le code lié avant son inclusion ailleurs.

### Codage des liens vers les ressources

Sprockets n'ajoute aucune nouvelle méthode pour accéder à vos ressources - vous utilisez toujours le familier `stylesheet_link_tag` :

```erb
<%= stylesheet_link_tag "application", media: "all" %>
```

Si vous utilisez la gem [`turbo-rails`](https://github.com/hotwired/turbo-rails), qui est incluse par défaut dans Rails, alors incluez l'option `data-turbo-track` qui permet à Turbo de vérifier si une ressource a été mise à jour et, le cas échéant, de la charger dans la page :

```erb
<%= stylesheet_link_tag "application", "data-turbo-track": "reload" %>
```

Dans les vues régulières, vous pouvez accéder aux images dans le répertoire `app/assets/images` de cette manière :

```erb
<%= image_tag "rails.png" %>
```

À condition que le pipeline soit activé dans votre application (et non désactivé dans le contexte de l'environnement actuel), ce fichier est servi par Sprockets. Si un fichier existe à `public/assets/rails.png`, il est servi par le serveur web.

Alternativement, une demande de fichier avec un hachage SHA256 tel que `public/assets/rails-f90d8a84c707a8dc923fca1ca1895ae8ed0a09237f6992015fef1e11be77c023.png` est traitée de la même manière. La façon dont ces hachages sont générés est expliquée dans la section [En production](#en-production) plus loin dans ce guide.

Les images peuvent également être organisées dans des sous-répertoires si nécessaire, puis peuvent être accédées en spécifiant le nom du répertoire dans la balise :

```erb
<%= image_tag "icons/rails.png" %>
```

AVERTISSEMENT : Si vous précompilez vos ressources (voir [En production](#en-production) ci-dessous), un lien vers une ressource qui n'existe pas provoquera une exception dans la page appelante. Cela inclut un lien vers une chaîne vide. Par conséquent, faites attention à utiliser `image_tag` et les autres helpers avec des données fournies par l'utilisateur.

#### CSS et ERB

Le pipeline des ressources évalue automatiquement ERB. Cela signifie que si vous ajoutez une extension `erb` à une ressource CSS (par exemple, `application.css.erb`), alors les helpers comme `asset_path` sont disponibles dans vos règles CSS :

```css
.class { background-image: url(<%= asset_path 'image.png' %>) }
```

Cela écrit le chemin vers la ressource spécifique qui est référencée. Dans cet exemple, il serait logique d'avoir une image dans l'un des chemins de chargement des ressources, comme `app/assets/images/image.png`, qui serait référencée ici. Si cette image est déjà disponible dans `public/assets` en tant que fichier avec empreinte digitale, alors ce chemin est référencé.

Si vous souhaitez utiliser un [URI de données](https://en.wikipedia.org/wiki/Data_URI_scheme) - une méthode d'intégration des données de l'image directement dans le fichier CSS - vous pouvez utiliser l'helper `asset_data_uri`.

```css
#logo { background: url(<%= asset_data_uri 'logo.png' %>) }
```

Cela insère un URI de données correctement formaté dans la source CSS.

Notez que la balise de fermeture ne peut pas être de style `-%>`.

### Générer une erreur lorsque une ressource n'est pas trouvée

Si vous utilisez sprockets-rails >= 3.2.0, vous pouvez configurer ce qui se passe lorsque la recherche d'une ressource est effectuée et que rien n'est trouvé. Si vous désactivez "fallback des ressources", une erreur sera levée lorsque une ressource ne peut pas être trouvée.

```ruby
config.assets.unknown_asset_fallback = false
```

Si le "fallback des ressources" est activé, alors lorsque une ressource ne peut pas être trouvée, le chemin sera affiché à la place et aucune erreur ne sera levée. Le comportement de fallback des ressources est désactivé par défaut.

### Désactiver les empreintes

Vous pouvez désactiver les empreintes en mettant à jour `config/environments/development.rb` pour inclure :

```ruby
config.assets.digest = false
```

Lorsque cette option est activée, des empreintes seront générées pour les URLs des ressources.

### Activer les Source Maps

Vous pouvez activer les Source Maps en mettant à jour `config/environments/development.rb` pour inclure :

```ruby
config.assets.debug = true
```

Lorsque le mode de débogage est activé, Sprockets génère une Source Map pour chaque ressource. Cela vous permet de déboguer chaque fichier individuellement dans les outils de développement de votre navigateur.

Les ressources sont compilées et mises en cache lors de la première requête après le démarrage du serveur. Sprockets définit un en-tête HTTP `must-revalidate` Cache-Control pour réduire les frais généraux des requêtes lors des requêtes suivantes - dans ce cas, le navigateur reçoit une réponse 304 (Non modifié).
Si l'un des fichiers du manifeste change entre les requêtes, le serveur répond avec un nouveau fichier compilé.

En production
-------------

Dans l'environnement de production, Sprockets utilise le schéma de numérotation des empreintes digitales décrit ci-dessus. Par défaut, Rails suppose que les ressources ont été précompilées et seront servies en tant que ressources statiques par votre serveur web.

Pendant la phase de précompilation, un SHA256 est généré à partir du contenu des fichiers compilés et inséré dans les noms de fichiers lorsqu'ils sont écrits sur le disque. Ces noms avec empreintes digitales sont utilisés par les helpers de Rails à la place du nom du manifeste.

Par exemple, ceci :

```erb
<%= stylesheet_link_tag "application" %>
```

génère quelque chose comme cela :

```html
<link href="/assets/application-4dd5b109ee3439da54f5bdfd78a80473.css" rel="stylesheet" />
```

Le comportement de numérotation des empreintes digitales est contrôlé par l'option d'initialisation [`config.assets.digest`][] (qui est par défaut à `true`).

NOTE : Dans des circonstances normales, l'option par défaut `config.assets.digest` ne devrait pas être modifiée. Si les empreintes digitales ne sont pas présentes dans les noms de fichiers et que des en-têtes à longue durée de vie sont définis, les clients distants ne sauront jamais qu'ils doivent récupérer les fichiers lorsque leur contenu change.


### Précompilation des ressources

Rails est livré avec une commande pour compiler les manifestes de ressources et les autres fichiers du pipeline.

Les ressources compilées sont écrites à l'emplacement spécifié dans [`config.assets.prefix`][]. Par défaut, il s'agit du répertoire `/assets`.

Vous pouvez appeler cette commande sur le serveur lors du déploiement pour créer des versions compilées de vos ressources directement sur le serveur. Consultez la section suivante pour des informations sur la compilation locale.

La commande est :

```bash
$ RAILS_ENV=production rails assets:precompile
```

Cela lie le dossier spécifié dans `config.assets.prefix` à `shared/assets`. Si vous utilisez déjà ce dossier partagé, vous devrez écrire votre propre commande de déploiement.

Il est important que ce dossier soit partagé entre les déploiements afin que les pages mises en cache à distance qui font référence aux anciennes ressources compilées fonctionnent toujours pendant la durée de vie de la page mise en cache.

NOTE. Spécifiez toujours un nom de fichier compilé attendu qui se termine par `.js` ou `.css`.

La commande génère également un fichier `.sprockets-manifest-randomhex.json` (où `randomhex` est une chaîne hexadécimale aléatoire de 16 octets) qui contient une liste de toutes vos ressources et de leurs empreintes digitales respectives. Cela est utilisé par les méthodes d'aide de Rails pour éviter de renvoyer les requêtes de mappage à Sprockets. Un fichier de manifeste typique ressemble à ceci :

```json
{"files":{"application-<fingerprint>.js":{"logical_path":"application.js","mtime":"2016-12-23T20:12:03-05:00","size":412383,
"digest":"<fingerprint>","integrity":"sha256-<random-string>"}},
"assets":{"application.js":"application-<fingerprint>.js"}}
```

Dans votre application, il y aura plus de fichiers et de ressources répertoriés dans le manifeste, `<fingerprint>` et `<random-string>` seront également générés.

L'emplacement par défaut du manifeste est la racine de l'emplacement spécifié dans `config.assets.prefix` ('/assets' par défaut).

NOTE : Si des fichiers précompilés manquent en production, vous obtiendrez une exception `Sprockets::Helpers::RailsHelper::AssetPaths::AssetNotPrecompiledError` indiquant le nom du ou des fichiers manquants.


#### En-tête Expires à longue durée de vie

Les ressources précompilées existent sur le système de fichiers et sont servies directement par votre serveur web. Elles n'ont pas d'en-têtes à longue durée de vie par défaut, donc pour bénéficier de la numérotation des empreintes digitales, vous devrez mettre à jour la configuration de votre serveur pour ajouter ces en-têtes.

Pour Apache :

```apache
# Les directives Expires* nécessitent que le module Apache
# `mod_expires` soit activé.
<Location /assets/>
  # L'utilisation de ETag est déconseillée lorsque Last-Modified est présent
  Header unset ETag
  FileETag None
  # La RFC dit de mettre en cache pendant 1 an seulement
  ExpiresActive On
  ExpiresDefault "access plus 1 year"
</Location>
```

Pour NGINX :

```nginx
location ~ ^/assets/ {
  expires 1y;
  add_header Cache-Control public;

  add_header ETag "";
}
```

### Précompilation locale

Parfois, vous ne voulez pas ou vous ne pouvez pas compiler les ressources sur le serveur de production. Par exemple, vous pouvez avoir un accès en écriture limité à votre système de fichiers de production, ou vous pouvez prévoir de déployer fréquemment sans apporter de modifications à vos ressources.

Dans de tels cas, vous pouvez précompiler les ressources _localement_ - c'est-à-dire ajouter un ensemble finalisé de ressources compilées prêtes pour la production à votre référentiel de code source avant de le pousser en production. De cette façon, elles n'ont pas besoin d'être précompilées séparément sur le serveur de production à chaque déploiement.

Comme indiqué ci-dessus, vous pouvez effectuer cette étape en utilisant

```bash
$ RAILS_ENV=production rails assets:precompile
```

Notez les points suivants :

* Si les ressources précompilées sont disponibles, elles seront servies - même si elles ne correspondent plus aux ressources originales (non compilées), _même sur le serveur de développement._

    Pour vous assurer que le serveur de développement compile toujours les ressources à la volée (et reflète ainsi toujours l'état le plus récent du code), l'environnement de développement _doit être configuré pour conserver les ressources précompilées dans un emplacement différent de celui de la production._ Sinon, toutes les ressources précompilées pour une utilisation en production écraseront les requêtes les concernant en développement (c'est-à-dire que les modifications ultérieures que vous apportez aux ressources ne seront pas reflétées dans le navigateur).
Vous pouvez le faire en ajoutant la ligne suivante à `config/environments/development.rb` :

```ruby
config.assets.prefix = "/dev-assets"
```

* La tâche de précompilation des assets dans votre outil de déploiement (par exemple, Capistrano) doit être désactivée.
* Tous les compresseurs ou minificateurs nécessaires doivent être disponibles sur votre système de développement.

Vous pouvez également définir `ENV["SECRET_KEY_BASE_DUMMY"]` pour déclencher l'utilisation d'une `secret_key_base` générée de manière aléatoire qui est stockée dans un fichier temporaire. Cela est utile lors de la précompilation des assets pour la production dans le cadre d'une étape de construction qui n'a pas besoin d'accéder aux secrets de production.

```bash
$ SECRET_KEY_BASE_DUMMY=1 bundle exec rails assets:precompile
```

### Compilation en direct

Dans certaines circonstances, vous pouvez souhaiter utiliser la compilation en direct. Dans ce mode, toutes les requêtes d'assets dans le pipeline sont gérées directement par Sprockets.

Pour activer cette option, définissez :

```ruby
config.assets.compile = true
```

Lors de la première requête, les assets sont compilés et mis en cache comme indiqué dans [Assets Cache Store](#assets-cache-store), et les noms de manifeste utilisés dans les helpers sont modifiés pour inclure le hachage SHA256.

Sprockets définit également l'en-tête HTTP `Cache-Control` sur `max-age=31536000`. Cela indique à tous les caches entre votre serveur et le navigateur client que ce contenu (le fichier servi) peut être mis en cache pendant 1 an. Cela réduit le nombre de requêtes pour cet asset depuis votre serveur ; il y a de fortes chances que l'asset soit déjà en cache dans le navigateur local ou dans un cache intermédiaire.

Ce mode utilise plus de mémoire, a des performances moins bonnes que le mode par défaut et n'est pas recommandé.

### CDN

CDN signifie [Content Delivery Network](https://en.wikipedia.org/wiki/Content_delivery_network), ils sont principalement conçus pour mettre en cache des assets partout dans le monde afin que lorsqu'un navigateur demande l'asset, une copie mise en cache soit géographiquement proche de ce navigateur. Si vous servez directement des assets depuis votre serveur Rails en production, la meilleure pratique est d'utiliser un CDN devant votre application.

Un schéma courant pour utiliser un CDN consiste à définir votre application de production comme serveur "origin". Cela signifie que lorsque le navigateur demande un asset depuis le CDN et qu'il n'y a pas de cache, il récupérera le fichier depuis votre serveur à la volée, puis le mettra en cache. Par exemple, si vous exécutez une application Rails sur `example.com` et que vous avez configuré un CDN sur `mycdnsubdomain.fictional-cdn.com`, alors lorsqu'une requête est faite à `mycdnsubdomain.fictional-cdn.com/assets/smile.png`, le CDN interrogera votre serveur une fois à `example.com/assets/smile.png` et mettra en cache la requête. La prochaine requête au CDN qui arrive à la même URL touchera la copie mise en cache. Lorsque le CDN peut servir directement un asset, la requête n'atteint jamais votre serveur Rails. Étant donné que les assets d'un CDN sont géographiquement plus proches du navigateur, la requête est plus rapide, et comme votre serveur n'a pas besoin de passer du temps à servir des assets, il peut se concentrer sur la fourniture du code de l'application aussi rapidement que possible.

#### Configuration d'un CDN pour servir des assets statiques

Pour configurer votre CDN, vous devez avoir votre application en production sur Internet à une URL publiquement accessible, par exemple `example.com`. Ensuite, vous devrez vous inscrire à un service CDN auprès d'un fournisseur d'hébergement cloud. Lorsque vous le faites, vous devez configurer l'"origin" du CDN pour pointer vers votre site web `example.com`. Consultez votre fournisseur pour obtenir la documentation sur la configuration du serveur d'origine.

Le CDN que vous avez provisionné devrait vous donner un sous-domaine personnalisé pour votre application, tel que `mycdnsubdomain.fictional-cdn.com` (notez que fictional-cdn.com n'est pas un fournisseur CDN valide au moment de la rédaction de ce document). Maintenant que vous avez configuré votre serveur CDN, vous devez indiquer aux navigateurs d'utiliser votre CDN pour récupérer les assets au lieu de votre serveur Rails directement. Vous pouvez le faire en configurant Rails pour définir votre CDN comme hôte d'assets au lieu d'utiliser un chemin relatif. Pour définir votre hôte d'assets dans Rails, vous devez définir [`config.asset_host`][] dans `config/environments/production.rb` :

```ruby
config.asset_host = 'mycdnsubdomain.fictional-cdn.com'
```

NOTE : Vous devez uniquement fournir l'"hôte", c'est-à-dire le sous-domaine et le domaine racine, vous n'avez pas besoin de spécifier un protocole ou un "scheme" tel que `http://` ou `https://`. Lorsqu'une page web est demandée, le protocole dans le lien vers votre asset généré correspondra à la façon dont la page web est accédée par défaut.

Vous pouvez également définir cette valeur via une [variable d'environnement](https://en.wikipedia.org/wiki/Environment_variable) pour faciliter l'exécution d'une copie de votre site en staging :
```ruby
config.asset_host = ENV['CDN_HOST']
```

NOTE: Vous devez définir `CDN_HOST` sur votre serveur à `mycdnsubdomain.fictional-cdn.com` pour que cela fonctionne.

Une fois que vous avez configuré votre serveur et votre CDN, les chemins des ressources provenant des helpers tels que :

```erb
<%= asset_path('smile.png') %>
```

Seront rendus sous forme d'URLs CDN complètes comme `http://mycdnsubdomain.fictional-cdn.com/assets/smile.png` (digest omis pour plus de lisibilité).

Si le CDN possède une copie de `smile.png`, il la servira au navigateur et votre serveur ne saura même pas qu'elle a été demandée. Si le CDN ne possède pas de copie, il essaiera de la trouver à l'« origine » `example.com/assets/smile.png`, puis la stockera pour une utilisation ultérieure.

Si vous souhaitez servir uniquement certaines ressources depuis votre CDN, vous pouvez utiliser l'option `:host` personnalisée de votre helper de ressources, qui écrase la valeur définie dans [`config.action_controller.asset_host`][].

```erb
<%= asset_path 'image.png', host: 'mycdnsubdomain.fictional-cdn.com' %>
```


#### Personnaliser le comportement de mise en cache du CDN

Un CDN fonctionne en mettant en cache le contenu. Si le CDN contient un contenu obsolète ou incorrect, il nuit plutôt qu'il n'aide votre application. Le but de cette section est de décrire le comportement général de mise en cache de la plupart des CDNs. Votre fournisseur spécifique peut se comporter légèrement différemment.

##### Mise en cache des requêtes CDN

Bien qu'un CDN soit décrit comme étant bon pour la mise en cache des ressources, il met en fait en cache la requête entière. Cela inclut le corps de la ressource ainsi que tous les en-têtes. Le plus important étant `Cache-Control`, qui indique au CDN (et aux navigateurs web) comment mettre en cache les contenus. Cela signifie que si quelqu'un demande une ressource qui n'existe pas, comme `/assets/i-dont-exist.png`, et que votre application Rails renvoie une erreur 404, alors votre CDN mettra probablement en cache la page 404 si un en-tête `Cache-Control` valide est présent.

##### Débogage des en-têtes CDN

Une façon de vérifier si les en-têtes sont correctement mis en cache dans votre CDN est d'utiliser [curl](
https://explainshell.com/explain?cmd=curl+-I+http%3A%2F%2Fwww.example.com). Vous pouvez demander les en-têtes à la fois à votre serveur et à votre CDN pour vérifier qu'ils sont identiques :

```bash
$ curl -I http://www.example/assets/application-
d0e099e021c95eb0de3615fd1d8c4d83.css
HTTP/1.1 200 OK
Server: Cowboy
Date: Sun, 24 Aug 2014 20:27:50 GMT
Connection: keep-alive
Last-Modified: Thu, 08 May 2014 01:24:14 GMT
Content-Type: text/css
Cache-Control: public, max-age=2592000
Content-Length: 126560
Via: 1.1 vegur
```

Comparé à la copie du CDN :

```bash
$ curl -I http://mycdnsubdomain.fictional-cdn.com/application-
d0e099e021c95eb0de3615fd1d8c4d83.css
HTTP/1.1 200 OK Server: Cowboy Last-
Modified: Thu, 08 May 2014 01:24:14 GMT Content-Type: text/css
Cache-Control:
public, max-age=2592000
Via: 1.1 vegur
Content-Length: 126560
Accept-Ranges:
bytes
Date: Sun, 24 Aug 2014 20:28:45 GMT
Via: 1.1 varnish
Age: 885814
Connection: keep-alive
X-Served-By: cache-dfw1828-DFW
X-Cache: HIT
X-Cache-Hits:
68
X-Timer: S1408912125.211638212,VS0,VE0
```

Consultez la documentation de votre CDN pour toute information supplémentaire qu'elle pourrait fournir, telle que `X-Cache`, ou pour tout en-tête supplémentaire qu'elle pourrait ajouter.

##### CDNs et l'en-tête Cache-Control

L'en-tête [`Cache-Control`][] décrit comment une requête peut être mise en cache. Lorsqu'aucun CDN n'est utilisé, un navigateur utilise ces informations pour mettre en cache les contenus. Cela est très utile pour les ressources qui ne sont pas modifiées, de sorte qu'un navigateur n'a pas besoin de re-télécharger le CSS ou le JavaScript d'un site web à chaque requête. En général, nous voulons que notre serveur Rails indique à notre CDN (et au navigateur) que la ressource est « publique ». Cela signifie que n'importe quelle mise en cache peut stocker la requête. Nous voulons également généralement définir `max-age`, qui correspond à la durée pendant laquelle la mise en cache conservera l'objet avant d'invalidation de la mise en cache. La valeur `max-age` est exprimée en secondes, avec une valeur maximale possible de `31536000`, soit un an. Vous pouvez le faire dans votre application Rails en définissant :

```ruby
config.public_file_server.headers = {
  'Cache-Control' => 'public, max-age=31536000'
}
```

Maintenant, lorsque votre application sert une ressource en production, le CDN stockera la ressource pendant une durée pouvant aller jusqu'à un an. Étant donné que la plupart des CDNs mettent également en cache les en-têtes de la requête, ce `Cache-Control` sera transmis à tous les navigateurs futurs qui demandent cette ressource. Le navigateur sait alors qu'il peut stocker cette ressource pendant très longtemps avant de devoir la redemander.

##### CDNs et l'invalidation de cache basée sur l'URL

La plupart des CDNs mettront en cache le contenu d'une ressource en fonction de l'URL complète. Cela signifie qu'une requête à

```
http://mycdnsubdomain.fictional-cdn.com/assets/smile-123.png
```

Sera un cache complètement différent de

```
http://mycdnsubdomain.fictional-cdn.com/assets/smile.png
```

Si vous souhaitez définir une `max-age` lointaine dans votre `Cache-Control` (et vous le souhaitez), assurez-vous que lorsque vous modifiez vos ressources, votre cache est invalidé. Par exemple, lorsque vous changez le visage souriant d'une image du jaune au bleu, vous voulez que tous les visiteurs de votre site obtiennent le nouveau visage bleu. Lorsque vous utilisez un CDN avec le pipeline d'actifs de Rails, `config.assets.digest` est défini sur `true` par défaut, de sorte que chaque ressource aura un nom de fichier différent lorsqu'elle est modifiée. De cette façon, vous n'avez jamais à invalider manuellement des éléments de votre cache. En utilisant un nom de ressource unique différent, vos utilisateurs obtiennent la dernière ressource.
Personnalisation du pipeline
------------------------

### Compression CSS

Une des options de compression CSS est YUI. Le [compresseur CSS YUI](https://yui.github.io/yuicompressor/css.html) permet la minification.

La ligne suivante active la compression YUI et nécessite le gem `yui-compressor`.

```ruby
config.assets.css_compressor = :yui
```

### Compression JavaScript

Les options possibles pour la compression JavaScript sont `:terser`, `:closure` et `:yui`. Elles nécessitent respectivement les gems `terser`, `closure-compiler` ou `yui-compressor`.

Prenons l'exemple du gem `terser`.
Ce gem enveloppe [Terser](https://github.com/terser/terser) (écrit pour Node.js) en Ruby. Il compresse votre code en supprimant les espaces et les commentaires, en raccourcissant les noms de variables locales et en effectuant d'autres micro-optimisations telles que la transformation des déclarations `if` et `else` en opérateurs ternaires lorsque cela est possible.

La ligne suivante invoque `terser` pour la compression JavaScript.

```ruby
config.assets.js_compressor = :terser
```

NOTE : Vous aurez besoin d'un moteur d'exécution compatible avec [ExecJS](https://github.com/rails/execjs#readme) pour utiliser `terser`. Si vous utilisez macOS ou Windows, vous avez déjà un moteur d'exécution JavaScript installé sur votre système d'exploitation.

NOTE : La compression JavaScript fonctionnera également pour vos fichiers JavaScript lorsque vous chargez vos assets via les gems `importmap-rails` ou `jsbundling-rails`.

### Compression GZip de vos assets

Par défaut, une version compressée au format GZip des assets compilés est générée, ainsi qu'une version non compressée des assets. Les assets compressés au format GZip permettent de réduire la transmission des données sur le réseau. Vous pouvez configurer cela en définissant le paramètre `gzip`.

```ruby
config.assets.gzip = false # désactive la génération des assets compressés au format GZip
```

Consultez la documentation de votre serveur web pour savoir comment servir des assets compressés au format GZip.

### Utilisation de votre propre compresseur

Les paramètres de configuration du compresseur pour CSS et JavaScript acceptent également n'importe quel objet. Cet objet doit avoir une méthode `compress` qui prend une chaîne de caractères comme unique argument et qui doit renvoyer une chaîne de caractères.

```ruby
class Transformer
  def compress(string)
    faire_quelque_chose_renvoie_une_chaîne_de_caractères(string)
  end
end
```

Pour activer cela, passez un nouvel objet à l'option de configuration dans `application.rb` :

```ruby
config.assets.css_compressor = Transformer.new
```

### Modification du chemin des _assets_

Le chemin public utilisé par défaut par Sprockets est `/assets`.

Il est possible de le modifier :

```ruby
config.assets.prefix = "/un_autre_chemin"
```

C'est une option pratique si vous mettez à jour un ancien projet qui n'utilisait pas le pipeline d'assets et qui utilise déjà ce chemin, ou si vous souhaitez utiliser ce chemin pour une nouvelle ressource.

### En-têtes X-Sendfile

L'en-tête X-Sendfile est une directive envoyée au serveur web pour lui indiquer d'ignorer la réponse de l'application et de servir à la place un fichier spécifié depuis le disque. Cette option est désactivée par défaut, mais peut être activée si votre serveur le prend en charge. Lorsqu'elle est activée, la responsabilité de servir le fichier est confiée au serveur web, ce qui est plus rapide. Consultez la documentation de votre serveur web pour savoir comment utiliser cette fonctionnalité.

Apache et NGINX prennent en charge cette option, qui peut être activée dans `config/environments/production.rb` :

```ruby
# config.action_dispatch.x_sendfile_header = "X-Sendfile" # pour Apache
# config.action_dispatch.x_sendfile_header = 'X-Accel-Redirect' # pour NGINX
```

ATTENTION : Si vous mettez à niveau une application existante et que vous prévoyez d'utiliser cette option, veillez à coller cette option de configuration uniquement dans `production.rb` et dans tous les autres environnements que vous définissez avec un comportement de production (pas dans `application.rb`).

CONSEIL : Pour plus de détails, consultez la documentation de votre serveur web de production :

- [Apache](https://tn123.org/mod_xsendfile/)
- [NGINX](https://www.nginx.com/resources/wiki/start/topics/examples/xsendfile/)

Cache des assets
------------------

Par défaut, Sprockets met en cache les assets dans `tmp/cache/assets` dans les environnements de développement et de production. Vous pouvez le modifier comme suit :

```ruby
config.assets.configure do |env|
  env.cache = ActiveSupport::Cache.lookup_store(:memory_store,
                                                { size: 32.megabytes })
end
```

Pour désactiver le cache des assets :

```ruby
config.assets.configure do |env|
  env.cache = ActiveSupport::Cache.lookup_store(:null_store)
end
```

Ajout d'assets à vos gems
--------------------------

Les assets peuvent également provenir de sources externes sous la forme de gems.

Un bon exemple est la gem `jquery-rails`.
Cette gem contient une classe engine qui hérite de `Rails::Engine`.
De cette manière, Rails est informé que le répertoire de cette gem peut contenir des assets et les répertoires `app/assets`, `lib/assets` et `vendor/assets` de cette engine sont ajoutés au chemin de recherche de Sprockets.

Transformer votre bibliothèque ou votre gem en préprocesseur
------------------------------------------

Sprockets utilise des processeurs, des transformateurs, des compresseurs et des exportateurs pour étendre ses fonctionnalités. Consultez [Extension de Sprockets](https://github.com/rails/sprockets/blob/master/guides/extending_sprockets.md) pour en savoir plus. Ici, nous avons enregistré un préprocesseur pour ajouter un commentaire à la fin des fichiers text/css (`.css`).

```ruby
module AddComment
  def self.call(input)
    { data: input[:data] + "/* Hello From my sprockets extension */" }
  end
end
```

Maintenant que vous avez un module qui modifie les données d'entrée, il est temps de l'enregistrer en tant que préprocesseur pour votre type MIME.
```ruby
Sprockets.register_preprocessor 'text/css', AddComment
```


Bibliothèques alternatives
------------------------------------------

Au fil des années, plusieurs approches par défaut ont été utilisées pour gérer les ressources. Le web a évolué et nous avons commencé à voir de plus en plus d'applications lourdes en JavaScript. Dans la doctrine de Rails, nous croyons que [Le Menu est Omakase](https://rubyonrails.org/doctrine#omakase), nous nous sommes donc concentrés sur la configuration par défaut : **Sprockets avec Import Maps**.

Nous sommes conscients qu'il n'y a pas de solution universelle pour les différents frameworks/extensions JavaScript et CSS disponibles. Il existe d'autres bibliothèques de regroupement dans l'écosystème Rails qui devraient vous permettre de répondre aux cas où la configuration par défaut ne suffit pas.

### jsbundling-rails

[`jsbundling-rails`](https://github.com/rails/jsbundling-rails) est une alternative dépendante de Node.js à la méthode de regroupement des JavaScript avec [esbuild](https://esbuild.github.io/), [rollup.js](https://rollupjs.org/) ou [Webpack](https://webpack.js.org/).

La gem fournit un processus `yarn build --watch` pour générer automatiquement la sortie en développement. Pour la production, elle relie automatiquement la tâche `javascript:build` à la tâche `assets:precompile` pour s'assurer que toutes les dépendances de vos packages ont été installées et que le JavaScript a été généré pour tous les points d'entrée.

**Quand l'utiliser à la place de `importmap-rails` ?** Si votre code JavaScript dépend de la transpilation, c'est-à-dire si vous utilisez [Babel](https://babeljs.io/), [TypeScript](https://www.typescriptlang.org/) ou le format React `JSX`, alors `jsbundling-rails` est la bonne solution.

### Webpacker/Shakapacker

[`Webpacker`](webpacker.html) était le préprocesseur JavaScript et le regroupeur par défaut pour Rails 5 et 6. Il a maintenant été abandonné. Un successeur appelé [`shakapacker`](https://github.com/shakacode/shakapacker) existe, mais il n'est pas maintenu par l'équipe ou le projet Rails.

Contrairement aux autres bibliothèques de cette liste, `webpacker`/`shakapacker` est complètement indépendant de Sprockets et peut traiter à la fois les fichiers JavaScript et CSS. Consultez le [guide Webpacker](https://guides.rubyonrails.org/webpacker.html) pour en savoir plus.

NOTE : Lisez le document [Comparaison avec Webpacker](https://github.com/rails/jsbundling-rails/blob/main/docs/comparison_with_webpacker.md) pour comprendre les différences entre `jsbundling-rails` et `webpacker`/`shakapacker`.

### cssbundling-rails

[`cssbundling-rails`](https://github.com/rails/cssbundling-rails) permet de regrouper et de traiter votre CSS à l'aide de [Tailwind CSS](https://tailwindcss.com/), [Bootstrap](https://getbootstrap.com/), [Bulma](https://bulma.io/), [PostCSS](https://postcss.org/) ou [Dart Sass](https://sass-lang.com/), puis de livrer le CSS via le pipeline des ressources.

Il fonctionne de manière similaire à `jsbundling-rails`, ajoutant la dépendance Node.js à votre application avec le processus `yarn build:css --watch` pour régénérer vos feuilles de style en développement et se connecte à la tâche `assets:precompile` en production.

**Quelle est la différence avec Sprockets ?** Sprockets seul n'est pas capable de transpiler le Sass en CSS, Node.js est nécessaire pour générer les fichiers `.css` à partir de vos fichiers `.sass`. Une fois les fichiers `.css` générés, `Sprockets` peut les livrer à vos clients.

NOTE : `cssbundling-rails` repose sur Node pour traiter le CSS. Les gems `dartsass-rails` et `tailwindcss-rails` utilisent des versions autonomes de Tailwind CSS et Dart Sass, ce qui signifie qu'il n'y a pas de dépendance à Node. Si vous utilisez `importmap-rails` pour gérer vos JavaScripts et `dartsass-rails` ou `tailwindcss-rails` pour le CSS, vous pouvez éviter complètement la dépendance à Node, ce qui donne une solution moins complexe.

### dartsass-rails

Si vous souhaitez utiliser [`Sass`](https://sass-lang.com/) dans votre application, [`dartsass-rails`](https://github.com/rails/dartsass-rails) remplace la gem `sassc-rails` obsolète. `dartsass-rails` utilise l'implémentation `Dart Sass` en remplacement de [`LibSass`](https://sass-lang.com/blog/libsass-is-deprecated) utilisé par `sassc-rails` et déprécié en 2020.

Contrairement à `sassc-rails`, la nouvelle gem n'est pas directement intégrée à `Sprockets`. Veuillez vous référer à la [page d'accueil de la gem](https://github.com/rails/dartsass-rails) pour les instructions d'installation/migration.

AVERTISSEMENT : La populaire gem `sassc-rails` n'est plus maintenue depuis 2019.

### tailwindcss-rails

[`tailwindcss-rails`](https://github.com/rails/tailwindcss-rails) est une gem d'enrobage pour [la version exécutable autonome](https://tailwindcss.com/blog/standalone-cli) du framework Tailwind CSS v3. Utilisée pour les nouvelles applications lorsque `--css tailwind` est spécifié à la commande `rails new`. Fournit un processus `watch` pour générer automatiquement la sortie de Tailwind en développement. En production, il se connecte à la tâche `assets:precompile`.
[`config.public_file_server.enabled`]: configuring.html#config-public-file-server-enabled
[`config.assets.digest`]: configuring.html#config-assets-digest
[`config.assets.prefix`]: configuring.html#config-assets-prefix
[`config.action_controller.asset_host`]: configuring.html#config-action-controller-asset-host
[`config.asset_host`]: configuring.html#config-asset-host
[`Cache-Control`]: https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Cache-Control
