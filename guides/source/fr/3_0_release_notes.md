**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: dd2584972aa8eae419ed5d55a287e27d
Ruby on Rails 3.0 Notes de version
==================================

Rails 3.0, c'est des poneys et des arcs-en-ciel ! Il va vous préparer le dîner et plier votre linge. Vous vous demanderez comment la vie était possible avant son arrivée. C'est la meilleure version de Rails que nous ayons jamais réalisée !

Mais sérieusement, c'est vraiment du bon matériel. Il y a toutes les bonnes idées apportées lorsque l'équipe de Merb s'est jointe à la fête et a apporté une focalisation sur l'agnosticisme du framework, des internes plus minces et plus rapides, et une poignée d'API savoureuses. Si vous passez à Rails 3.0 depuis Merb 1.x, vous devriez reconnaître beaucoup de choses. Si vous passez de Rails 2.x, vous allez l'adorer aussi.

Même si vous vous moquez de tous nos nettoyages internes, Rails 3.0 va vous ravir. Nous avons une multitude de nouvelles fonctionnalités et d'API améliorées. Il n'y a jamais eu de meilleur moment pour être un développeur Rails. Voici quelques points forts :

* Un tout nouveau routeur avec une emphase sur les déclarations RESTful
* Nouvelle API Action Mailer modelée d'après Action Controller (maintenant sans la douleur agonisante de l'envoi de messages multipartes !)
* Nouveau langage de requête chaînable pour Active Record construit sur l'algèbre relationnelle
* Helpers JavaScript non intrusifs avec des pilotes pour Prototype, jQuery, et plus à venir (fin du JS en ligne)
* Gestion explicite des dépendances avec Bundler

En plus de tout cela, nous avons fait de notre mieux pour déprécier les anciennes API avec de belles alertes. Cela signifie que vous pouvez migrer votre application existante vers Rails 3 sans avoir à réécrire immédiatement tout votre ancien code selon les meilleures pratiques actuelles.

Ces notes de version couvrent les mises à niveau majeures, mais ne comprennent pas toutes les petites corrections de bugs et les changements. Rails 3.0 comprend près de 4 000 commits de plus de 250 auteurs ! Si vous voulez tout voir, consultez la [liste des commits](https://github.com/rails/rails/commits/3-0-stable) dans le dépôt principal de Rails sur GitHub.

--------------------------------------------------------------------------------

Pour installer Rails 3 :

```bash
# Utilisez sudo si votre configuration l'exige
$ gem install rails
```


Mise à niveau vers Rails 3
--------------------------

Si vous mettez à niveau une application existante, il est conseillé d'avoir une bonne couverture de tests avant de commencer. Vous devriez également d'abord mettre à niveau vers Rails 2.3.5 et vous assurer que votre application fonctionne toujours comme prévu avant de tenter de passer à Rails 3. Ensuite, tenez compte des changements suivants :

### Rails 3 nécessite au moins Ruby 1.8.7

Rails 3.0 nécessite Ruby 1.8.7 ou une version supérieure. Le support de toutes les versions précédentes de Ruby a été officiellement abandonné et vous devriez effectuer la mise à niveau dès que possible. Rails 3.0 est également compatible avec Ruby 1.9.2.

ASTUCE : Notez que les versions p248 et p249 de Ruby 1.8.7 ont des bugs de sérialisation qui font planter Rails 3.0. Ruby Enterprise Edition les a corrigés depuis la version 1.8.7-2010.02. Du côté de Ruby 1.9, la version 1.9.1 n'est pas utilisable car elle plante carrément avec Rails 3.0, donc si vous voulez utiliser Rails 3 avec 1.9.x, passez à la version 1.9.2 pour une navigation en douceur.

### Objet d'application Rails

Dans le cadre des travaux préparatoires pour prendre en charge l'exécution de plusieurs applications Rails dans le même processus, Rails 3 introduit le concept d'un objet d'application. Un objet d'application contient toutes les configurations spécifiques à l'application et est très similaire à `config/environment.rb` des versions précédentes de Rails.

Chaque application Rails doit maintenant avoir un objet d'application correspondant. L'objet d'application est défini dans `config/application.rb`. Si vous mettez à niveau une application existante vers Rails 3, vous devez ajouter ce fichier et déplacer les configurations appropriées de `config/environment.rb` vers `config/application.rb`.

### script/* remplacé par script/rails

Le nouveau `script/rails` remplace tous les scripts qui se trouvaient dans le répertoire `script`. Vous n'exécutez pas `script/rails` directement, la commande `rails` détecte qu'elle est invoquée à la racine d'une application Rails et exécute le script pour vous. L'utilisation prévue est la suivante :

```bash
$ rails console                      # au lieu de script/console
$ rails g scaffold post title:string # au lieu de script/generate scaffold post title:string
```

Exécutez `rails --help` pour obtenir une liste de toutes les options.

### Dépendances et config.gem

La méthode `config.gem` a disparu et a été remplacée par l'utilisation de `bundler` et d'un `Gemfile`, voir [Vendoring Gems](#vendoring-gems) ci-dessous.

### Processus de mise à niveau

Pour faciliter le processus de mise à niveau, un plugin nommé [Rails Upgrade](https://github.com/rails/rails_upgrade) a été créé pour automatiser une partie de celui-ci.

Il suffit d'installer le plugin, puis d'exécuter `rake rails:upgrade:check` pour vérifier votre application et voir les éléments qui doivent être mis à jour (avec des liens vers des informations sur la façon de les mettre à jour). Il propose également une tâche pour générer un `Gemfile` basé sur vos appels `config.gem` actuels et une tâche pour générer un nouveau fichier de routes à partir de votre fichier actuel. Pour obtenir le plugin, exécutez simplement la commande suivante :
```bash
$ ruby script/plugin install git://github.com/rails/rails_upgrade.git
```

Vous pouvez voir un exemple de comment cela fonctionne sur [Rails Upgrade is now an Official Plugin](http://omgbloglol.com/post/364624593/rails-upgrade-is-now-an-official-plugin)

En plus de l'outil Rails Upgrade, si vous avez besoin d'aide supplémentaire, il y a des personnes sur IRC et [rubyonrails-talk](https://discuss.rubyonrails.org/c/rubyonrails-talk) qui font probablement la même chose, rencontrant peut-être les mêmes problèmes. N'oubliez pas de partager vos propres expériences lors de la mise à niveau afin que les autres puissent bénéficier de vos connaissances !

Création d'une application Rails 3.0
------------------------------------

```bash
# Vous devez avoir le RubyGem 'rails' installé
$ rails new myapp
$ cd myapp
```

### Vendoring Gems

Rails utilise maintenant un `Gemfile` à la racine de l'application pour déterminer les gems dont vous avez besoin pour démarrer votre application. Ce `Gemfile` est traité par [Bundler](https://github.com/bundler/bundler) qui installe ensuite toutes vos dépendances. Il peut même installer toutes les dépendances localement à votre application afin qu'elle ne dépende pas des gems système.

Plus d'informations : - [Page d'accueil de Bundler](https://bundler.io/)

### Vivre à la pointe

`Bundler` et `Gemfile` permettent de geler facilement votre application Rails avec la nouvelle commande dédiée `bundle`, donc `rake freeze` n'est plus pertinent et a été supprimé.

Si vous voulez regrouper directement à partir du référentiel Git, vous pouvez passer le drapeau `--edge` :

```bash
$ rails new myapp --edge
```

Si vous avez une copie locale du référentiel Rails et que vous voulez générer une application à partir de celui-ci, vous pouvez passer le drapeau `--dev` :

```bash
$ ruby /path/to/rails/bin/rails new myapp --dev
```

Changements architecturaux de Rails
----------------------------------

Il y a six changements majeurs dans l'architecture de Rails.

### Railties Restrung

Railties a été mis à jour pour fournir une API de plugin cohérente pour l'ensemble du framework Rails ainsi qu'une réécriture complète des générateurs et des liaisons Rails. Le résultat est que les développeurs peuvent maintenant se connecter à n'importe quelle étape importante des générateurs et du framework de l'application de manière cohérente et définie.

### Tous les composants principaux de Rails sont découplés

Avec la fusion de Merb et Rails, l'un des grands travaux a été de supprimer le couplage étroit entre les composants principaux de Rails. Cela a maintenant été réalisé, et tous les composants principaux de Rails utilisent maintenant la même API que vous pouvez utiliser pour développer des plugins. Cela signifie que tout plugin que vous créez, ou tout remplacement de composant principal (comme DataMapper ou Sequel) peut accéder à toutes les fonctionnalités auxquelles les composants principaux de Rails ont accès et les étendre et les améliorer à volonté.

Plus d'informations : - [Le grand découplage](http://yehudakatz.com/2009/07/19/rails-3-the-great-decoupling/)

### Abstraction du modèle actif

Dans le cadre du découplage des composants principaux, toutes les liaisons à Active Record ont été extraites de Action Pack. Cela a maintenant été réalisé. Tous les nouveaux plugins ORM doivent maintenant simplement implémenter les interfaces Active Model pour fonctionner de manière transparente avec Action Pack.

Plus d'informations : - [Faites en sorte que n'importe quel objet Ruby se comporte comme ActiveRecord](http://yehudakatz.com/2010/01/10/activemodel-make-any-ruby-object-feel-like-activerecord/)

### Abstraction du contrôleur

Une autre grande partie du découplage des composants principaux a été la création d'une superclasse de base séparée des notions de HTTP afin de gérer le rendu des vues, etc. Cette création de `AbstractController` a permis de simplifier considérablement `ActionController` et `ActionMailer` en supprimant le code commun de toutes ces bibliothèques et en le plaçant dans Abstract Controller.

Plus d'informations : - [Architecture de pointe de Rails](http://yehudakatz.com/2009/06/11/rails-edge-architecture/)

### Intégration d'Arel

[Arel](https://github.com/brynary/arel) (ou Active Relation) a été adopté comme base d'Active Record et est maintenant requis pour Rails. Arel fournit une abstraction SQL qui simplifie Active Record et fournit les bases de la fonctionnalité de relation dans Active Record.

Plus d'informations : - [Pourquoi j'ai écrit Arel](https://web.archive.org/web/20120718093140/http://magicscalingsprinkles.wordpress.com/2010/01/28/why-i-wrote-arel/)

### Extraction de Mail

Action Mailer, depuis ses débuts, a eu des correctifs, des pré-analyseurs et même des agents de livraison et de réception, en plus d'avoir TMail vendu dans l'arborescence des sources. La version 3 change cela en extrayant toutes les fonctionnalités liées aux messages électroniques vers le gem [Mail](https://github.com/mikel/mail). Cela réduit à nouveau la duplication du code et aide à créer des limites définissables entre Action Mailer et l'analyseur de courrier électronique.

Plus d'informations : - [Nouvelle API Action Mailer dans Rails 3](http://lindsaar.net/2010/1/26/new-actionmailer-api-in-rails-3)

Documentation
-------------

La documentation dans l'arborescence de Rails est en cours de mise à jour avec toutes les modifications de l'API, en outre, les [Rails Edge Guides](https://edgeguides.rubyonrails.org/) sont mises à jour une par une pour refléter les changements dans Rails 3.0. Les guides sur [guides.rubyonrails.org](https://guides.rubyonrails.org/) continueront cependant à ne contenir que la version stable de Rails (à ce stade, la version 2.3.5, jusqu'à la sortie de la version 3.0).

Plus d'informations : - [Projets de documentation Rails](https://weblog.rubyonrails.org/2009/1/15/rails-documentation-projects)
Internationalisation
--------------------

Un grand travail a été réalisé pour prendre en charge l'internationalisation dans Rails 3, notamment avec la dernière gemme [I18n](https://github.com/svenfuchs/i18n) qui apporte de nombreuses améliorations de vitesse.

* I18n pour n'importe quel objet - Le comportement I18n peut être ajouté à n'importe quel objet en incluant `ActiveModel::Translation` et `ActiveModel::Validations`. Il y a également une option de repli `errors.messages` pour les traductions.
* Les attributs peuvent avoir des traductions par défaut.
* Les balises de soumission de formulaire tirent automatiquement le bon statut (Créer ou Mettre à jour) en fonction du statut de l'objet, et tirent donc la bonne traduction.
* Les labels avec I18n fonctionnent maintenant en passant simplement le nom de l'attribut.

Plus d'informations : - [Modifications I18n dans Rails 3](http://blog.plataformatec.com.br/2010/02/rails-3-i18n-changes/)


Railties
--------

Avec le découplage des principaux frameworks de Rails, Railties a été complètement révisé afin de faciliter et d'étendre la liaison des frameworks, des moteurs ou des plugins :

* Chaque application a maintenant son propre espace de noms, l'application est lancée avec `YourAppName.boot` par exemple, ce qui facilite l'interaction avec d'autres applications.
* Tout ce qui se trouve sous `Rails.root/app` est maintenant ajouté au chemin de chargement, vous pouvez donc créer `app/observers/user_observer.rb` et Rails le chargera sans aucune modification.
* Rails 3.0 fournit maintenant un objet `Rails.config`, qui constitue un référentiel central de toutes sortes d'options de configuration propres à Rails.

La génération d'application a reçu des options supplémentaires permettant de sauter l'installation de test-unit, Active Record, Prototype et Git. De plus, un nouveau drapeau `--dev` a été ajouté, qui configure l'application avec le `Gemfile` pointant vers votre copie de Rails (qui est déterminée par le chemin vers l'exécutable `rails`). Consultez `rails --help` pour plus d'informations.

Les générateurs de Railties ont été largement améliorés dans Rails 3.0, en gros :

* Les générateurs ont été entièrement réécrits et ne sont plus rétrocompatibles.
* L'API des modèles de Rails et l'API des générateurs ont été fusionnées (elles sont identiques à l'ancienne).
* Les générateurs ne sont plus chargés à partir de chemins spéciaux, ils sont simplement trouvés dans le chemin de chargement Ruby, donc en appelant `rails generate foo`, il cherchera `generators/foo_generator`.
* Les nouveaux générateurs fournissent des hooks, de sorte que n'importe quel moteur de template, ORM ou framework de test peut facilement s'y connecter.
* Les nouveaux générateurs vous permettent de remplacer les templates en plaçant une copie dans `Rails.root/lib/templates`.
* `Rails::Generators::TestCase` est également fourni pour que vous puissiez créer vos propres générateurs et les tester.

De plus, les vues générées par les générateurs de Railties ont été améliorées :

* Les vues utilisent maintenant des balises `div` au lieu de balises `p`.
* Les échafaudages générés utilisent maintenant des partiels `_form`, au lieu de code dupliqué dans les vues d'édition et de création.
* Les formulaires des échafaudages utilisent maintenant `f.submit` qui renvoie "Créer NomDuModèle" ou "Mettre à jour NomDuModèle" en fonction de l'état de l'objet passé.

Enfin, quelques améliorations ont été apportées aux tâches Rake :

* `rake db:forward` a été ajouté, ce qui vous permet de faire avancer vos migrations individuellement ou par groupes.
* `rake routes CONTROLLER=x` a été ajouté, ce qui vous permet de visualiser uniquement les routes pour un contrôleur donné.

Railties déprécie maintenant :

* `RAILS_ROOT` au profit de `Rails.root`,
* `RAILS_ENV` au profit de `Rails.env`, et
* `RAILS_DEFAULT_LOGGER` au profit de `Rails.logger`.

`PLUGIN/rails/tasks` et `PLUGIN/tasks` ne sont plus chargés, toutes les tâches doivent maintenant se trouver dans `PLUGIN/lib/tasks`.

Plus d'informations :

* [Découverte des générateurs Rails 3](http://blog.plataformatec.com.br/2010/01/discovering-rails-3-generators)
* [Le module Rails (dans Rails 3)](http://quaran.to/blog/2010/02/03/the-rails-module/)

Action Pack
-----------

Il y a eu des changements significatifs internes et externes dans Action Pack.


### Contrôleur abstrait

Le contrôleur abstrait extrait les parties génériques du contrôleur d'action dans un module réutilisable que n'importe quelle bibliothèque peut utiliser pour rendre des templates, des partiels, des helpers, des traductions, des journaux, n'importe quelle partie du cycle de demande-réponse. Cette abstraction a permis à `ActionMailer::Base` d'hériter maintenant de `AbstractController` et d'envelopper simplement la DSL de Rails sur la gemme Mail.

Cela a également permis de nettoyer le contrôleur d'action, en abstrayant ce qui pouvait l'être pour simplifier le code.

Notez cependant que le contrôleur abstrait n'est pas une API destinée aux utilisateurs, vous ne le rencontrerez pas dans votre utilisation quotidienne de Rails.

Plus d'informations : - [Architecture de pointe de Rails](http://yehudakatz.com/2009/06/11/rails-edge-architecture/)


### Contrôleur d'action

* `application_controller.rb` a maintenant `protect_from_forgery` activé par défaut.
* Le `cookie_verifier_secret` a été déprécié et est maintenant assigné via `Rails.application.config.cookie_secret` et déplacé dans son propre fichier : `config/initializers/cookie_verification_secret.rb`.
* Le `session_store` était configuré dans `ActionController::Base.session`, et il est maintenant déplacé dans `Rails.application.config.session_store`. Les valeurs par défaut sont configurées dans `config/initializers/session_store.rb`.
* `cookies.secure` vous permet de définir des valeurs chiffrées dans les cookies avec `cookie.secure[:key] => value`.
* `cookies.permanent` vous permet de définir des valeurs permanentes dans le hash des cookies `cookie.permanent[:key] => value` qui lèvent des exceptions sur les valeurs signées en cas d'échec de vérification.
* Vous pouvez maintenant passer `:notice => 'Ceci est un message flash'` ou `:alert => 'Quelque chose s'est mal passé'` à l'appel `format` à l'intérieur d'un bloc `respond_to`. Le hash `flash[]` fonctionne toujours comme précédemment.
* La méthode `respond_with` a maintenant été ajoutée à vos contrôleurs, simplifiant les blocs `format` vénérables.
* `ActionController::Responder` a été ajouté, vous permettant de personnaliser la génération de vos réponses.
Dépréciations :

* `filter_parameter_logging` est déprécié au profit de `config.filter_parameters << :password`.

Plus d'informations :

* [Options de rendu dans Rails 3](https://blog.engineyard.com/2010/render-options-in-rails-3)
* [Trois raisons d'aimer ActionController::Responder](https://weblog.rubyonrails.org/2009/8/31/three-reasons-love-responder)


### Action Dispatch

Action Dispatch est nouveau dans Rails 3.0 et offre une nouvelle implémentation plus propre pour le routage.

* Nettoyage en profondeur et réécriture du routeur, le routeur Rails est maintenant `rack_mount` avec une DSL Rails par-dessus, c'est un logiciel autonome.
* Les routes définies par chaque application sont maintenant regroupées dans votre module Application, c'est-à-dire :

    ```ruby
    # Au lieu de :

    ActionController::Routing::Routes.draw do |map|
      map.resources :posts
    end

    # Vous faites :

    AppName::Application.routes do
      resources :posts
    end
    ```

* Ajout de la méthode `match` au routeur, vous pouvez également passer n'importe quelle application Rack à la route correspondante.
* Ajout de la méthode `constraints` au routeur, vous permettant de protéger les routeurs avec des contraintes définies.
* Ajout de la méthode `scope` au routeur, vous permettant de regrouper les routes pour différentes langues ou différentes actions, par exemple :

    ```ruby
    scope 'es' do
      resources :projects, :path_names => { :edit => 'cambiar' }, :path => 'proyecto'
    end

    # Vous donne l'action edit avec /es/proyecto/1/cambiar
    ```

* Ajout de la méthode `root` au routeur comme raccourci pour `match '/', :to => path`.
* Vous pouvez passer des segments optionnels dans le match, par exemple `match "/:controller(/:action(/:id))(.:format)"`, chaque segment entre parenthèses est optionnel.
* Les routes peuvent être exprimées via des blocs, par exemple vous pouvez appeler `controller :home { match '/:action' }`.

NOTE. Les anciennes commandes `map` fonctionnent toujours comme avant avec une couche de compatibilité arrière, cependant cela sera supprimé dans la version 3.1.

Dépréciations :

* La route de capture pour les applications non-REST (`/:controller/:action/:id`) est maintenant commentée.
* Les routes `:path_prefix` n'existent plus et `:name_prefix` ajoute maintenant automatiquement "_" à la fin de la valeur donnée.

Plus d'informations :
* [Le routeur Rails 3 : Rack it Up](http://yehudakatz.com/2009/12/26/the-rails-3-router-rack-it-up/)
* [Routes remaniées dans Rails 3](https://medium.com/fusion-of-thoughts/revamped-routes-in-rails-3-b6d00654e5b0)
* [Actions génériques dans Rails 3](http://yehudakatz.com/2009/12/20/generic-actions-in-rails-3/)


### Action View

#### JavaScript non intrusif

Une refonte majeure a été effectuée dans les helpers de Action View, en mettant en œuvre des hooks JavaScript non intrusifs (UJS) et en supprimant les anciennes commandes AJAX en ligne. Cela permet à Rails d'utiliser n'importe quel pilote UJS conforme pour mettre en œuvre les hooks UJS dans les helpers.

Cela signifie que tous les anciens helpers `remote_<method>` ont été supprimés du cœur de Rails et placés dans le [Prototype Legacy Helper](https://github.com/rails/prototype_legacy_helper). Pour obtenir des hooks UJS dans votre HTML, vous passez maintenant `:remote => true`. Par exemple :

```ruby
form_for @post, :remote => true
```

Produit :

```html
<form action="http://host.com" id="create-post" method="post" data-remote="true">
```

#### Helpers avec des blocs

Les helpers comme `form_for` ou `div_for` qui insèrent du contenu à partir d'un bloc utilisent maintenant `<%=` :

```html+erb
<%= form_for @post do |f| %>
  ...
<% end %>
```

Vos propres helpers de ce type doivent renvoyer une chaîne de caractères, plutôt que d'ajouter manuellement au tampon de sortie.

Les helpers qui font autre chose, comme `cache` ou `content_for`, ne sont pas affectés par ce changement, ils ont besoin de `&lt;%` comme avant.

#### Autres changements

* Vous n'avez plus besoin d'appeler `h(string)` pour échapper la sortie HTML, c'est activé par défaut dans tous les templates de vue. Si vous voulez la chaîne non échappée, appelez `raw(string)`.
* Les helpers produisent maintenant du HTML5 par défaut.
* Le helper d'étiquette de formulaire récupère maintenant les valeurs de I18n avec une seule valeur, donc `f.label :name` récupérera la traduction `:name`.
* L'étiquette de sélection I18n doit maintenant être :en.helpers.select au lieu de :en.support.select.
* Vous n'avez plus besoin de placer un signe moins à la fin d'une interpolation Ruby à l'intérieur d'un template ERB pour supprimer le retour chariot final dans la sortie HTML.
* Ajout du helper `grouped_collection_select` à Action View.
* `content_for?` a été ajouté, vous permettant de vérifier l'existence de contenu dans une vue avant de le rendre.
* passer `:value => nil` aux helpers de formulaire définira l'attribut `value` du champ à nil au lieu d'utiliser la valeur par défaut
* passer `:id => nil` aux helpers de formulaire fera que ces champs seront rendus sans attribut `id`
* passer `:alt => nil` à `image_tag` fera que la balise `img` sera rendue sans attribut `alt`

Active Model
------------

Active Model est nouveau dans Rails 3.0. Il fournit une couche d'abstraction pour que toutes les bibliothèques ORM puissent interagir avec Rails en implémentant une interface Active Model.
### Abstraction ORM et interface Action Pack

Une partie de la déconnexion des composants principaux consistait à extraire tous les liens vers Active Record d'Action Pack. Cela a maintenant été réalisé. Tous les nouveaux plugins ORM doivent simplement implémenter les interfaces Active Model pour fonctionner parfaitement avec Action Pack.

Plus d'informations : - [Rendre n'importe quel objet Ruby semblable à ActiveRecord](http://yehudakatz.com/2010/01/10/activemodel-make-any-ruby-object-feel-like-activerecord/)


### Validations

Les validations ont été déplacées d'Active Record vers Active Model, fournissant une interface de validations qui fonctionne avec les bibliothèques ORM de Rails 3.

* Il existe maintenant une méthode raccourcie `validates :attribut, options_hash` qui vous permet de passer des options pour toutes les méthodes de validation de classe, vous pouvez passer plus d'une option à une méthode de validation.
* La méthode `validates` a les options suivantes :
    * `:acceptance => Boolean`.
    * `:confirmation => Boolean`.
    * `:exclusion => { :in => Enumerable }`.
    * `:inclusion => { :in => Enumerable }`.
    * `:format => { :with => Regexp, :on => :create }`.
    * `:length => { :maximum => Fixnum }`.
    * `:numericality => Boolean`.
    * `:presence => Boolean`.
    * `:uniqueness => Boolean`.

NOTE : Toutes les méthodes de validation de style Rails version 2.3 sont toujours prises en charge dans Rails 3.0, la nouvelle méthode `validates` est conçue comme une aide supplémentaire dans les validations de votre modèle, et non comme un remplacement de l'API existante.

Vous pouvez également passer un objet validateur, que vous pouvez ensuite réutiliser entre les objets qui utilisent Active Model :

```ruby
class TitleValidator < ActiveModel::EachValidator
  Titles = ['M.', 'Mme.', 'Dr.']
  def validate_each(record, attribute, value)
    unless Titles.include?(value)
      record.errors[attribute] << 'doit être un titre valide'
    end
  end
end
```

```ruby
class Personne
  include ActiveModel::Validations
  attr_accessor :titre
  validates :titre, :presence => true, :titre => true
end

# Ou pour Active Record

class Personne < ActiveRecord::Base
  validates :titre, :presence => true, :titre => true
end
```

Il existe également une prise en charge de l'introspection :

```ruby
User.validators
User.validators_on(:login)
```

Plus d'informations :

* [Validation sexy dans Rails 3](http://thelucid.com/2010/01/08/sexy-validation-in-edge-rails-rails-3/)
* [Explications sur les validations dans Rails 3](http://lindsaar.net/2010/1/31/validates_rails_3_awesome_is_true)


Active Record
-------------

Active Record a reçu beaucoup d'attention dans Rails 3.0, notamment une abstraction en Active Model, une mise à jour complète de l'interface de requête en utilisant Arel, des mises à jour de validation et de nombreuses améliorations et corrections. Toutes les API de Rails 2.x seront utilisables grâce à une couche de compatibilité qui sera prise en charge jusqu'à la version 3.1.


### Interface de requête

Active Record, grâce à l'utilisation d'Arel, renvoie maintenant des relations sur ses méthodes principales. L'API existante dans Rails 2.3.x est toujours prise en charge et ne sera pas obsolète avant Rails 3.1 et ne sera pas supprimée avant Rails 3.2, cependant, la nouvelle API fournit les nouvelles méthodes suivantes qui renvoient toutes des relations permettant de les chaîner ensemble :

* `where` - fournit des conditions sur la relation, ce qui est renvoyé.
* `select` - choisissez les attributs des modèles que vous souhaitez renvoyer depuis la base de données.
* `group` - groupe la relation sur l'attribut fourni.
* `having` - fournit une expression limitant les relations de groupe (contrainte GROUP BY).
* `joins` - joint la relation à une autre table.
* `clause` - fournit une expression limitant les relations de jointure (contrainte JOIN).
* `includes` - inclut d'autres relations pré-chargées.
* `order` - trie la relation en fonction de l'expression fournie.
* `limit` - limite la relation au nombre d'enregistrements spécifié.
* `lock` - verrouille les enregistrements renvoyés par la table.
* `readonly` - renvoie une copie en lecture seule des données.
* `from` - fournit un moyen de sélectionner des relations à partir de plusieurs tables.
* `scope` - (précédemment `named_scope`) renvoie des relations et peut être chaîné avec les autres méthodes de relation.
* `with_scope` - et `with_exclusive_scope` renvoient maintenant également des relations et peuvent donc être chaînés.
* `default_scope` - fonctionne également avec les relations.

Plus d'informations :

* [Interface de requête Active Record](http://m.onkey.org/2010/1/22/active-record-query-interface)
* [Laissez votre SQL rugir dans Rails 3](http://hasmanyquestions.wordpress.com/2010/01/17/let-your-sql-growl-in-rails-3/)


### Améliorations

* Ajout de `:destroyed?` aux objets Active Record.
* Ajout de `:inverse_of` aux associations Active Record vous permettant de récupérer l'instance d'une association déjà chargée sans accéder à la base de données.


### Correctifs et obsolètes

De plus, de nombreuses corrections ont été apportées à la branche Active Record :

* La prise en charge de SQLite 2 a été abandonnée au profit de SQLite 3.
* Prise en charge de l'ordre des colonnes pour MySQL.
* Le support de `TIME ZONE` de l'adaptateur PostgreSQL a été corrigé pour ne plus insérer de valeurs incorrectes.
* Prise en charge de plusieurs schémas dans les noms de table pour PostgreSQL.
* Prise en charge de PostgreSQL pour la colonne de type de données XML.
* `table_name` est maintenant mis en cache.
* Un travail considérable a également été effectué sur l'adaptateur Oracle avec de nombreuses corrections de bugs.
Ainsi que les dépréciations suivantes :

* `named_scope` dans une classe Active Record est déprécié et a été renommé simplement `scope`.
* Dans les méthodes `scope`, vous devriez passer à l'utilisation des méthodes de relation, au lieu d'une méthode de recherche `:conditions => {}`, par exemple `scope :since, lambda {|time| where("created_at > ?", time) }`.
* `save(false)` est déprécié, au profit de `save(:validate => false)`.
* Les messages d'erreur I18n pour Active Record doivent être modifiés de `:en.activerecord.errors.template` à `:en.errors.template`.
* `model.errors.on` est déprécié au profit de `model.errors[]`
* validates_presence_of => validates... :presence => true
* `ActiveRecord::Base.colorize_logging` et `config.active_record.colorize_logging` sont dépréciés au profit de `Rails::LogSubscriber.colorize_logging` ou `config.colorize_logging`

NOTE : Bien qu'une implémentation de State Machine soit présente dans Active Record depuis quelques mois maintenant, elle a été supprimée de la version 3.0 de Rails.


Active Resource
---------------

Active Resource a également été extrait vers Active Model, ce qui vous permet d'utiliser des objets Active Resource avec Action Pack de manière transparente.

* Ajout de validations via Active Model.
* Ajout de hooks d'observation.
* Prise en charge d'un proxy HTTP.
* Ajout de la prise en charge de l'authentification digest.
* Déplacement de la dénomination du modèle dans Active Model.
* Changement des attributs d'Active Resource en un Hash avec un accès indifférent.
* Ajout des alias `first`, `last` et `all` pour les scopes de recherche équivalents.
* `find_every` ne renvoie plus une erreur `ResourceNotFound` si rien n'est retourné.
* Ajout de `save!` qui génère une erreur `ResourceInvalid` sauf si l'objet est `valid?`.
* Ajout de `update_attribute` et `update_attributes` aux modèles Active Resource.
* Ajout de `exists?`.
* Renommage de `SchemaDefinition` en `Schema` et de `define_schema` en `schema`.
* Utilisation du `format` des ressources actives plutôt que du `content-type` des erreurs distantes pour charger les erreurs.
* Utilisation de `instance_eval` pour le bloc de schéma.
* Correction de `ActiveResource::ConnectionError#to_s` lorsque `@response` ne répond pas à #code ou #message, gestion de la compatibilité avec Ruby 1.9.
* Ajout de la prise en charge des erreurs au format JSON.
* Assurez-vous que `load` fonctionne avec des tableaux numériques.
* Reconnaît une réponse 410 de la ressource distante comme indiquant que la ressource a été supprimée.
* Ajout de la possibilité de définir des options SSL sur les connexions Active Resource.
* Le délai de connexion affecte également `Net::HTTP` `open_timeout`.

Dépréciations :

* `save(false)` est déprécié, au profit de `save(:validate => false)`.
* Ruby 1.9.2 : `URI.parse` et `.decode` sont dépréciés et ne sont plus utilisés dans la bibliothèque.


Active Support
--------------

Un effort important a été fait dans Active Support pour le rendre sélectionnable, c'est-à-dire que vous n'avez plus besoin de requérir l'intégralité de la bibliothèque Active Support pour en obtenir des parties. Cela permet aux différents composants principaux de Rails de fonctionner de manière plus légère.

Voici les principaux changements dans Active Support :

* Grand nettoyage de la bibliothèque en supprimant les méthodes inutilisées.
* Active Support ne fournit plus de versions intégrées de TZInfo, Memcache Client et Builder. Ils sont tous inclus en tant que dépendances et installés via la commande `bundle install`.
* Les tampons sécurisés sont implémentés dans `ActiveSupport::SafeBuffer`.
* Ajout de `Array.uniq_by` et `Array.uniq_by!`.
* Suppression de `Array#rand` et rétroportage de `Array#sample` de Ruby 1.9.
* Correction d'un bug dans `TimeZone.seconds_to_utc_offset` qui renvoyait une valeur incorrecte.
* Ajout de `ActiveSupport::Notifications` middleware.
* `ActiveSupport.use_standard_json_time_format` est maintenant activé par défaut.
* `ActiveSupport.escape_html_entities_in_json` est maintenant désactivé par défaut.
* `Integer#multiple_of?` accepte zéro comme argument, renvoie false sauf si le récepteur est zéro.
* `string.chars` a été renommé en `string.mb_chars`.
* `ActiveSupport::OrderedHash` peut maintenant être désérialisé via YAML.
* Ajout d'un parseur basé sur SAX pour XmlMini, utilisant LibXML et Nokogiri.
* Ajout de `Object#presence` qui renvoie l'objet s'il est `#present?` sinon renvoie `nil`.
* Ajout de l'extension de base `String#exclude?` qui renvoie l'inverse de `#include?`.
* Ajout de `to_i` à `DateTime` dans `ActiveSupport` afin que `to_yaml` fonctionne correctement sur les modèles avec des attributs `DateTime`.
* Ajout de `Enumerable#exclude?` pour égaliser `Enumerable#include?` et éviter `!x.include?`.
* Passage à l'échappement XSS activé par défaut pour Rails.
* Prise en charge de la fusion profonde dans `ActiveSupport::HashWithIndifferentAccess`.
* `Enumerable#sum` fonctionne maintenant avec toutes les énumérations, même si elles ne répondent pas à `:size`.
* `inspect` sur une durée de longueur zéro renvoie '0 secondes' au lieu d'une chaîne vide.
* Ajout de `element` et `collection` à `ModelName`.
* `String#to_time` et `String#to_datetime` gèrent les secondes fractionnaires.
* Ajout de la prise en charge des nouveaux rappels pour l'objet de filtre autour qui répond à `:before` et `:after` utilisé dans les rappels avant et après.
* La méthode `ActiveSupport::OrderedHash#to_a` renvoie un ensemble ordonné de tableaux. Correspond à `Hash#to_a` de Ruby 1.9.
* `MissingSourceFile` existe en tant que constante mais est maintenant égal à `LoadError`.
* Ajout de `Class#class_attribute` pour pouvoir déclarer un attribut de niveau de classe dont la valeur est héritable et pouvant être écrasée par les sous-classes.
* Enfin, suppression de `DeprecatedCallbacks` dans `ActiveRecord::Associations`.
* `Object#metaclass` est maintenant `Kernel#singleton_class` pour correspondre à Ruby.
Les méthodes suivantes ont été supprimées car elles sont désormais disponibles dans Ruby 1.8.7 et 1.9.

* `Integer#even?` et `Integer#odd?`
* `String#each_char`
* `String#start_with?` et `String#end_with?` (les alias à la troisième personne sont conservés)
* `String#bytesize`
* `Object#tap`
* `Symbol#to_proc`
* `Object#instance_variable_defined?`
* `Enumerable#none?`

Le correctif de sécurité pour REXML reste dans Active Support car les premiers niveaux de correctifs de Ruby 1.8.7 en ont encore besoin. Active Support sait s'il doit l'appliquer ou non.

Les méthodes suivantes ont été supprimées car elles ne sont plus utilisées dans le framework :

* `Kernel#daemonize`
* `Object#remove_subclasses_of`, `Object#extend_with_included_modules_from`, `Object#extended_by`
* `Class#remove_class`
* `Regexp#number_of_captures`, `Regexp.unoptionalize`, `Regexp.optionalize`, `Regexp#number_of_captures`

Action Mailer
-------------

Action Mailer a reçu une nouvelle API avec TMail étant remplacé par la nouvelle [Mail](https://github.com/mikel/mail) en tant que bibliothèque de messagerie électronique. Action Mailer lui-même a été entièrement réécrit avec pratiquement chaque ligne de code touchée. Le résultat est qu'Action Mailer hérite maintenant simplement de Abstract Controller et enveloppe la gem Mail dans un DSL Rails. Cela réduit considérablement la quantité de code et la duplication d'autres bibliothèques dans Action Mailer.

* Tous les mailers sont maintenant dans `app/mailers` par défaut.
* Peut maintenant envoyer des e-mails en utilisant la nouvelle API avec trois méthodes : `attachments`, `headers` et `mail`.
* Action Mailer prend désormais en charge nativement les pièces jointes en ligne en utilisant la méthode `attachments.inline`.
* Les méthodes d'envoi d'e-mails d'Action Mailer renvoient maintenant des objets `Mail::Message`, qui peuvent ensuite envoyer eux-mêmes le message en appelant la méthode `deliver`.
* Toutes les méthodes de livraison sont maintenant abstraites dans la gem Mail.
* La méthode de livraison de courrier peut accepter un hachage de tous les champs d'en-tête de courrier valides avec leur paire de valeurs.
* La méthode de livraison `mail` fonctionne de manière similaire à `respond_to` de Action Controller, et vous pouvez rendre explicitement ou implicitement des modèles. Action Mailer transformera l'e-mail en un e-mail multipart si nécessaire.
* Vous pouvez passer une procédure à l'appel `format.mime_type` à l'intérieur du bloc de messagerie et rendre explicitement des types de texte spécifiques, ou ajouter des mises en page ou des modèles différents. L'appel `render` à l'intérieur de la procédure provient de Abstract Controller et prend en charge les mêmes options.
* Les tests unitaires de messagerie ont été déplacés vers des tests fonctionnels.
* Action Mailer délègue maintenant tout le codage automatique des champs d'en-tête et des corps à la gem Mail.
* Action Mailer codera automatiquement les corps et les en-têtes des e-mails pour vous.

Dépréciations :

* `:charset`, `:content_type`, `:mime_version`, `:implicit_parts_order` sont tous dépréciés au profit des déclarations de style `ActionMailer.default :key => value`.
* Les méthodes dynamiques `create_method_name` et `deliver_method_name` du Mailer sont dépréciées, il suffit d'appeler `method_name` qui renvoie maintenant un objet `Mail::Message`.
* `ActionMailer.deliver(message)` est déprécié, il suffit d'appeler `message.deliver`.
* `template_root` est déprécié, passez des options à un appel de rendu à l'intérieur d'une procédure de la méthode `format.mime_type` à l'intérieur du bloc de génération `mail`.
* La méthode `body` pour définir des variables d'instance est dépréciée (`body {:ivar => value}`), déclarez simplement les variables d'instance directement dans la méthode et elles seront disponibles dans la vue.
* La présence des mailers dans `app/models` est dépréciée, utilisez `app/mailers` à la place.

Plus d'informations :

* [Nouvelle API Action Mailer dans Rails 3](http://lindsaar.net/2010/1/26/new-actionmailer-api-in-rails-3)
* [Nouvelle gem Mail pour Ruby](http://lindsaar.net/2010/1/23/mail-gem-version-2-released)


Crédits
-------

Consultez la [liste complète des contributeurs à Rails](https://contributors.rubyonrails.org/) pour les nombreuses personnes qui ont passé de nombreuses heures à créer Rails 3. Félicitations à tous.

Les notes de version de Rails 3.0 ont été compilées par [Mikel Lindsaar](http://lindsaar.net).
