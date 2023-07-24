Webpacker
=========

Ce guide vous montrera comment installer et utiliser Webpacker pour regrouper JavaScript, CSS et autres ressources pour le côté client de votre application Rails, mais veuillez noter que [Webpacker a été retiré](https://github.com/rails/webpacker#webpacker-has-been-retired-).

Après avoir lu ce guide, vous saurez :

* Ce que fait Webpacker et pourquoi il est différent de Sprockets.
* Comment installer Webpacker et l'intégrer à votre framework de choix.
* Comment utiliser Webpacker pour les ressources JavaScript.
* Comment utiliser Webpacker pour les ressources CSS.
* Comment utiliser Webpacker pour les ressources statiques.
* Comment déployer un site qui utilise Webpacker.
* Comment utiliser Webpacker dans des contextes Rails alternatifs, tels que les moteurs ou les conteneurs Docker.

--------------------------------------------------------------

Qu'est-ce que Webpacker ?
------------------

Webpacker est un wrapper Rails autour du système de construction [webpack](https://webpack.js.org) qui fournit une configuration webpack standard et des valeurs par défaut raisonnables.

### Qu'est-ce que Webpack ?

L'objectif de webpack, ou de tout système de construction front-end, est de vous permettre d'écrire votre code front-end de manière pratique pour les développeurs, puis de regrouper ce code de manière pratique pour les navigateurs. Avec webpack, vous pouvez gérer JavaScript, CSS et des ressources statiques telles que des images ou des polices. Webpack vous permettra d'écrire votre code, de référencer d'autres codes de votre application, de transformer votre code et de combiner votre code en packs facilement téléchargeables.

Consultez la [documentation webpack](https://webpack.js.org) pour plus d'informations.

### Comment Webpacker est-il différent de Sprockets ?

Rails est également livré avec Sprockets, un outil d'emballage des ressources dont les fonctionnalités se chevauchent avec celles de Webpacker. Les deux outils compileront votre JavaScript en fichiers compatibles avec les navigateurs et les minimiseront et les empreinteront également en production. Dans un environnement de développement, Sprockets et Webpacker vous permettent de modifier progressivement les fichiers.

Sprockets, qui a été conçu pour être utilisé avec Rails, est un peu plus simple à intégrer. En particulier, du code peut être ajouté à Sprockets via une gemme Ruby. Cependant, webpack est meilleur pour s'intégrer avec des outils JavaScript plus récents et des packages NPM, et permet une plus grande variété d'intégration. Les nouvelles applications Rails sont configurées pour utiliser webpack pour JavaScript et Sprockets pour CSS, bien que vous puissiez également utiliser webpack pour le CSS.

Vous devriez choisir Webpacker plutôt que Sprockets pour un nouveau projet si vous souhaitez utiliser des packages NPM et/ou si vous souhaitez accéder aux fonctionnalités et outils JavaScript les plus récents. Vous devriez choisir Sprockets plutôt que Webpacker pour les applications existantes où la migration pourrait être coûteuse, si vous souhaitez vous intégrer à l'aide de gemmes, ou si vous avez une très petite quantité de code à regrouper.

Si vous êtes familier avec Sprockets, le guide suivant pourrait vous donner une idée de la traduction. Veuillez noter que chaque outil a une structure légèrement différente, et les concepts ne se correspondent pas directement.

|Tâche              | Sprockets            | Webpacker         |
|------------------|----------------------|-------------------|
|Attacher JavaScript |javascript_include_tag|javascript_pack_tag|
|Attacher CSS        |stylesheet_link_tag   |stylesheet_pack_tag|
|Lier à une image  |image_url             |image_pack_tag     |
|Lier à une ressource  |asset_url             |asset_pack_tag     |
|Exiger un script  |//= require           |import or require  |

Installation de Webpacker
--------------------

Pour utiliser Webpacker, vous devez installer le gestionnaire de paquets Yarn, version 1.x ou supérieure, et vous devez avoir Node.js installé, version 10.13.0 et supérieure.

REMARQUE : Webpacker dépend de NPM et Yarn. NPM, le registre du gestionnaire de paquets Node, est le principal référentiel pour la publication et le téléchargement de projets JavaScript open source, à la fois pour Node.js et les navigateurs. Il est analogue à rubygems.org pour les gemmes Ruby. Yarn est une utilité en ligne de commande qui permet l'installation et la gestion des dépendances JavaScript, tout comme Bundler le fait pour Ruby.

Pour inclure Webpacker dans un nouveau projet, ajoutez `--webpack` à la commande `rails new`. Pour ajouter Webpacker à un projet existant, ajoutez la gemme `webpacker` au fichier `Gemfile` du projet, exécutez `bundle install`, puis exécutez `bin/rails webpacker:install`.

L'installation de Webpacker crée les fichiers locaux suivants :

|Fichier                    |Emplacement                |Explication                                                                                         |
|------------------------|------------------------|----------------------------------------------------------------------------------------------------|
|Dossier JavaScript       | `app/javascript`       |Un endroit pour votre code source front-end                                                                   |
|Configuration Webpacker | `config/webpacker.yml` |Configurer la gemme Webpacker                                                                         |
|Configuration Babel     | `babel.config.js`      |Configuration pour le compilateur JavaScript [Babel](https://babeljs.io)                               |
|Configuration PostCSS   | `postcss.config.js`    |Configuration pour le post-processeur CSS [PostCSS](https://postcss.org)                             |
|Browserlist             | `.browserslistrc`      |[Browserlist](https://github.com/browserslist/browserslist) gère la configuration des navigateurs cibles   |


L'installation appelle également le gestionnaire de paquets `yarn`, crée un fichier `package.json` avec un ensemble de packages de base répertoriés, et utilise Yarn pour installer ces dépendances.

Utilisation
-----

### Utilisation de Webpacker pour JavaScript

Avec Webpacker installé, tout fichier JavaScript dans le répertoire `app/javascript/packs` sera compilé par défaut dans son propre fichier pack.
Donc, si vous avez un fichier appelé `app/javascript/packs/application.js`, Webpacker créera un pack appelé `application`, et vous pouvez l'ajouter à votre application Rails avec le code `<%= javascript_pack_tag "application" %>`. Avec cela en place, en développement, Rails recompilera le fichier `application.js` à chaque fois qu'il change, et vous chargez une page qui utilise ce pack. En général, le fichier dans le répertoire réel `packs` sera un manifeste qui charge principalement d'autres fichiers, mais il peut également contenir du code JavaScript arbitraire.

Le pack par défaut créé pour vous par Webpacker liera les packages JavaScript par défaut de Rails s'ils ont été inclus dans le projet:

```javascript
import Rails from "@rails/ujs"
import Turbolinks from "turbolinks"
import * as ActiveStorage from "@rails/activestorage"
import "channels"

Rails.start()
Turbolinks.start()
ActiveStorage.start()
```

Vous devrez inclure un pack qui nécessite ces packages pour les utiliser dans votre application Rails.

Il est important de noter que seuls les fichiers d'entrée webpack doivent être placés dans le répertoire `app/javascript/packs`; Webpack créera un graphe de dépendances distinct pour chaque point d'entrée, donc un grand nombre de packs augmentera les frais généraux de compilation. Le reste de votre code source d'actifs doit vivre en dehors de ce répertoire, bien que Webpacker ne place aucune restriction ou ne fasse aucune suggestion sur la façon de structurer votre code source. Voici un exemple:

```sh
app/javascript:
  ├── packs:
  │   # seulement les fichiers d'entrée webpack ici
  │   └── application.js
  │   └── application.css
  └── src:
  │   └── my_component.js
  └── stylesheets:
  │   └── my_styles.css
  └── images:
      └── logo.svg
```

Généralement, le fichier pack lui-même est principalement un manifeste qui utilise `import` ou `require` pour charger les fichiers nécessaires et peut également effectuer une certaine initialisation.

Si vous souhaitez modifier ces répertoires, vous pouvez ajuster `source_path` (par défaut `app/javascript`) et `source_entry_path` (par défaut `packs`) dans le fichier `config/webpacker.yml`.

Dans les fichiers source, les instructions `import` sont résolues par rapport au fichier effectuant l'importation, donc `import Bar from "./foo"` trouve un fichier `foo.js` dans le même répertoire que le fichier actuel, tandis que `import Bar from "../src/foo"` trouve un fichier dans un répertoire frère nommé `src`.

### Utilisation de Webpacker pour CSS

Par défaut, Webpacker prend en charge CSS et SCSS en utilisant le processeur PostCSS.

Pour inclure du code CSS dans vos packs, incluez d'abord vos fichiers CSS dans votre fichier de pack de niveau supérieur comme s'il s'agissait d'un fichier JavaScript. Donc, si votre manifeste CSS de niveau supérieur est dans `app/javascript/styles/styles.scss`, vous pouvez l'importer avec `import styles/styles`. Cela indique à webpack d'inclure votre fichier CSS dans le téléchargement. Pour le charger réellement dans la page, incluez `<%= stylesheet_pack_tag "application" %>` dans la vue, où `application` est le même nom de pack que vous utilisiez.

Si vous utilisez un framework CSS, vous pouvez l'ajouter à Webpacker en suivant les instructions pour charger le framework en tant que module NPM en utilisant `yarn`, généralement `yarn add <framework>`. Le framework devrait avoir des instructions sur la façon de l'importer dans un fichier CSS ou SCSS.


### Utilisation de Webpacker pour les ressources statiques

La configuration par défaut de Webpacker [configuration](https://github.com/rails/webpacker/blob/master/lib/install/config/webpacker.yml#L21) devrait fonctionner avec les ressources statiques.
La configuration inclut plusieurs extensions de formats de fichiers d'images et de polices, permettant à webpack de les inclure dans le fichier `manifest.json` généré.

Avec webpack, les ressources statiques peuvent être importées directement dans les fichiers JavaScript. La valeur importée représente l'URL de la ressource. Par exemple:

```javascript
import myImageUrl from '../images/my-image.jpg'

// ...
let myImage = new Image();
myImage.src = myImageUrl;
myImage.alt = "Je suis une image regroupée par Webpacker";
document.body.appendChild(myImage);
```

Si vous avez besoin de référencer des ressources statiques de Webpacker à partir d'une vue Rails, les ressources doivent être explicitement requises à partir de fichiers JavaScript regroupés par Webpacker. Contrairement à Sprockets, Webpacker n'importe pas vos ressources statiques par défaut. Le fichier `app/javascript/packs/application.js` par défaut contient un modèle pour importer des fichiers à partir d'un répertoire donné, que vous pouvez décommenter pour chaque répertoire dans lequel vous souhaitez avoir des fichiers statiques. Les répertoires sont relatifs à `app/javascript`. Le modèle utilise le répertoire `images`, mais vous pouvez utiliser n'importe quoi dans `app/javascript`:

```javascript
const images = require.context("../images", true)
const imagePath = name => images(name, true)
```

Les ressources statiques seront générées dans un répertoire sous `public/packs/media`. Par exemple, une image située et importée à `app/javascript/images/my-image.jpg` sera générée à `public/packs/media/images/my-image-abcd1234.jpg`. Pour afficher une balise d'image pour cette image dans une vue Rails, utilisez `image_pack_tag 'media/images/my-image.jpg`.

Les helpers ActionView de Webpacker pour les ressources statiques correspondent aux helpers du pipeline d'actifs selon le tableau suivant:
|ActionView helper | Webpacker helper |
|------------------|------------------|
|favicon_link_tag  |favicon_pack_tag  |
|image_tag         |image_pack_tag    |

De plus, l'aide générique `asset_pack_path` prend l'emplacement local d'un fichier et renvoie son emplacement Webpacker pour une utilisation dans les vues Rails.

Vous pouvez également accéder à l'image en référençant directement le fichier à partir d'un fichier CSS dans `app/javascript`.

### Webpacker dans les moteurs Rails

À partir de la version 6 de Webpacker, Webpacker n'est pas "aware" des moteurs, ce qui signifie que Webpacker n'a pas la même fonctionnalité que Sprockets lorsqu'il s'agit de l'utiliser dans les moteurs Rails.

Les auteurs de gemmes de moteurs Rails qui souhaitent prendre en charge les utilisateurs utilisant Webpacker sont encouragés à distribuer les ressources frontend sous forme de package NPM en plus de la gemme elle-même et à fournir des instructions (ou un installateur) pour montrer comment les applications hôtes doivent s'intégrer. Un bon exemple de cette approche est [Alchemy CMS](https://github.com/AlchemyCMS/alchemy_cms).

### Hot Module Replacement (HMR)

Webpacker prend en charge HMR avec webpack-dev-server par défaut, et vous pouvez le basculer en définissant l'option dev_server/hmr dans `webpacker.yml`.

Consultez [la documentation de webpack sur DevServer](https://webpack.js.org/configuration/dev-server/#devserver-hot) pour plus d'informations.

Pour prendre en charge HMR avec React, vous devrez ajouter react-hot-loader. Consultez [le guide _Getting Started_ de React Hot Loader](https://gaearon.github.io/react-hot-loader/getstarted/).

N'oubliez pas de désactiver HMR si vous n'exécutez pas webpack-dev-server, sinon vous obtiendrez une erreur "not found" pour les feuilles de style.

Webpacker dans différents environnements
-----------------------------------

Webpacker a trois environnements par défaut : `development`, `test` et `production`. Vous pouvez ajouter des configurations d'environnement supplémentaires dans le fichier `webpacker.yml` et définir des valeurs par défaut différentes pour chaque environnement. Webpacker chargera également le fichier `config/webpack/<environment>.js` pour une configuration d'environnement supplémentaire.

## Exécution de Webpacker en développement

Webpacker est livré avec deux fichiers binstub pour s'exécuter en développement : `./bin/webpack` et `./bin/webpack-dev-server`. Ce sont des wrappers minces autour des exécutables standard `webpack.js` et `webpack-dev-server.js` et garantissent que les bons fichiers de configuration et variables d'environnement sont chargés en fonction de votre environnement.

Par défaut, Webpacker compile automatiquement à la demande en développement lorsqu'une page Rails se charge. Cela signifie que vous n'avez pas à exécuter de processus séparés et que les erreurs de compilation seront consignées dans le journal standard de Rails. Vous pouvez modifier cela en passant à `compile: false` dans le fichier `config/webpacker.yml`. L'exécution de `bin/webpack` forcera la compilation de vos packs.

Si vous souhaitez utiliser le rechargement du code en direct ou si vous avez suffisamment de JavaScript pour que la compilation à la demande soit trop lente, vous devrez exécuter `./bin/webpack-dev-server` ou `ruby ./bin/webpack-dev-server`. Ce processus surveillera les modifications apportées aux fichiers `app/javascript/packs/*.js` et recompilera automatiquement et rechargera le navigateur en conséquence.

Les utilisateurs de Windows devront exécuter ces commandes dans un terminal séparé de `bundle exec rails server`.

Une fois que vous avez démarré ce serveur de développement, Webpacker commencera automatiquement à acheminer toutes les demandes d'actifs webpack vers ce serveur. Lorsque vous arrêtez le serveur, il reviendra à la compilation à la demande.

La [Documentation de Webpacker](https://github.com/rails/webpacker) donne des informations sur les variables d'environnement que vous pouvez utiliser pour contrôler `webpack-dev-server`. Consultez les notes supplémentaires dans la [documentation de rails/webpacker sur l'utilisation de webpack-dev-server](https://github.com/rails/webpacker#development).

### Déploiement de Webpacker

Webpacker ajoute une tâche `webpacker:compile` à la tâche `bin/rails assets:precompile`, de sorte que tout pipeline de déploiement existant qui utilisait `assets:precompile` devrait fonctionner. La tâche de compilation compilera les packs et les placera dans `public/packs`.

Documentation supplémentaire
------------------------

Pour plus d'informations sur des sujets avancés, tels que l'utilisation de Webpacker avec des frameworks populaires, consultez la [Documentation de Webpacker](https://github.com/rails/webpacker).
