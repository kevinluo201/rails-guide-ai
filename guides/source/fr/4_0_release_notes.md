**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: b21dbc892c0a841f1bc1fafdf5ee0126
Ruby on Rails 4.0 Notes de version
==================================

Points forts de Rails 4.0 :

* Ruby 2.0 préféré ; 1.9.3+ requis
* Strong Parameters
* Turbolinks
* Russian Doll Caching

Ces notes de version ne couvrent que les changements majeurs. Pour en savoir plus sur les corrections de bugs et les changements divers, veuillez vous référer aux journaux des modifications ou consulter la [liste des validations](https://github.com/rails/rails/commits/4-0-stable) dans le dépôt principal de Rails sur GitHub.

--------------------------------------------------------------------------------

Mise à niveau vers Rails 4.0
---------------------------

Si vous mettez à niveau une application existante, il est recommandé d'avoir une bonne couverture de tests avant de commencer. Vous devriez également d'abord passer à Rails 3.2 au cas où vous ne l'auriez pas déjà fait et vous assurer que votre application fonctionne toujours comme prévu avant de tenter une mise à jour vers Rails 4.0. Une liste de points à surveiller lors de la mise à niveau est disponible dans le guide [Mise à niveau de Ruby on Rails](upgrading_ruby_on_rails.html#upgrading-from-rails-3-2-to-rails-4-0).

Création d'une application Rails 4.0
------------------------------------

```bash
# Vous devez avoir le RubyGem 'rails' installé
$ rails new myapp
$ cd myapp
```

### Vendoring Gems

Rails utilise maintenant un `Gemfile` à la racine de l'application pour déterminer les gems dont vous avez besoin pour démarrer votre application. Ce `Gemfile` est traité par le gem [Bundler](https://github.com/carlhuda/bundler), qui installe ensuite toutes vos dépendances. Il peut même installer toutes les dépendances localement à votre application afin qu'elle ne dépende pas des gems système.

Plus d'informations : [Page d'accueil de Bundler](https://bundler.io)

### Vivre au bord du gouffre

`Bundler` et `Gemfile` rendent le gel de votre application Rails aussi facile que de manger une tarte avec la nouvelle commande `bundle` dédiée. Si vous souhaitez regrouper directement depuis le dépôt Git, vous pouvez passer le drapeau `--edge` :

```bash
$ rails new myapp --edge
```

Si vous avez une copie locale du dépôt Rails et que vous souhaitez générer une application à partir de celle-ci, vous pouvez passer le drapeau `--dev` :

```bash
$ ruby /chemin/vers/rails/railties/bin/rails new myapp --dev
```

Fonctionnalités majeures
------------------------

[![Rails 4.0](images/4_0_release_notes/rails4_features.png)](https://guides.rubyonrails.org/images/4_0_release_notes/rails4_features.png)

### Mise à niveau

* **Ruby 1.9.3** ([validation](https://github.com/rails/rails/commit/a0380e808d3dbd2462df17f5d3b7fcd8bd812496)) - Ruby 2.0 préféré ; 1.9.3+ requis
* **[Nouvelle politique de dépréciation](https://www.youtube.com/watch?v=z6YgD6tVPQs)** - Les fonctionnalités dépréciées sont des avertissements dans Rails 4.0 et seront supprimées dans Rails 4.1.
* **ActionPack page et action caching** ([validation](https://github.com/rails/rails/commit/b0a7068564f0c95e7ef28fc39d0335ed17d93e90)) - Le caching de page et d'action est extrait dans un gem séparé. Le caching de page et d'action nécessite trop d'interventions manuelles (expiration manuelle des caches lorsque les objets modèle sous-jacents sont mis à jour). Utilisez plutôt le caching Russian doll.
* **ActiveRecord observers** ([validation](https://github.com/rails/rails/commit/ccecab3ba950a288b61a516bf9b6962e384aae0b)) - Les observers sont extraits dans un gem séparé. Les observers ne sont nécessaires que pour le caching de page et d'action, et peuvent conduire à un code spaghetti.
* **ActiveRecord session store** ([validation](https://github.com/rails/rails/commit/0ffe19056c8e8b2f9ae9d487b896cad2ce9387ad)) - Le stockage des sessions ActiveRecord est extrait dans un gem séparé. Stocker les sessions en SQL est coûteux. Utilisez plutôt les sessions de cookies, les sessions de memcache ou un stockage de sessions personnalisé.
* **Protection contre les affectations massives ActiveModel** ([validation](https://github.com/rails/rails/commit/f8c9a4d3e88181cee644f91e1342bfe896ca64c6)) - La protection contre les affectations massives de Rails 3 est dépréciée. Utilisez plutôt les strong parameters.
* **ActiveResource** ([validation](https://github.com/rails/rails/commit/f1637bf2bb00490203503fbd943b73406e043d1d)) - ActiveResource est extrait dans un gem séparé. ActiveResource n'était pas largement utilisé.
* **vendor/plugins supprimé** ([validation](https://github.com/rails/rails/commit/853de2bd9ac572735fa6cf59fcf827e485a231c3)) - Utilisez un `Gemfile` pour gérer les gems installées.

### ActionPack

* **Strong parameters** ([validation](https://github.com/rails/rails/commit/a8f6d5c6450a7fe058348a7f10a908352bb6c7fc)) - N'autorisez que les paramètres autorisés à mettre à jour les objets modèle (`params.permit(:title, :text)`).
* **Routing concerns** ([validation](https://github.com/rails/rails/commit/0dd24728a088fcb4ae616bb5d62734aca5276b1b)) - Dans le DSL de routage, factorisez les sous-routes communes (`comments` de `/posts/1/comments` et `/videos/1/comments`).
* **ActionController::Live** ([validation](https://github.com/rails/rails/commit/af0a9f9eefaee3a8120cfd8d05cbc431af376da3)) - Diffusez du JSON avec `response.stream`.
* **ETags déclaratifs** ([validation](https://github.com/rails/rails/commit/ed5c938fa36995f06d4917d9543ba78ed506bb8d)) - Ajoutez des ajouts d'ETag au niveau du contrôleur qui feront partie du calcul de l'ETag de l'action.
* **[Caching Russian doll](https://37signals.com/svn/posts/3113-how-key-based-cache-expiration-works)** ([validation](https://github.com/rails/rails/commit/4154bf012d2bec2aae79e4a49aa94a70d3e91d49)) - Mettez en cache des fragments imbriqués de vues. Chaque fragment expire en fonction d'un ensemble de dépendances (une clé de cache). La clé de cache est généralement un numéro de version de modèle de template et un objet modèle.
* **Turbolinks** ([validation](https://github.com/rails/rails/commit/e35d8b18d0649c0ecc58f6b73df6b3c8d0c6bb74)) - Ne servez qu'une seule page HTML initiale. Lorsque l'utilisateur navigue vers une autre page, utilisez pushState pour mettre à jour l'URL et utilisez AJAX pour mettre à jour le titre et le corps.
* **Découpler ActionView de ActionController** ([validation](https://github.com/rails/rails/commit/78b0934dd1bb84e8f093fb8ef95ca99b297b51cd)) - ActionView a été découplé de ActionPack et sera déplacé dans un gem séparé dans Rails 4.1.
* **Ne pas dépendre d'ActiveModel** ([validation](https://github.com/rails/rails/commit/166dbaa7526a96fdf046f093f25b0a134b277a68)) - ActionPack ne dépend plus d'ActiveModel.
### Général

 * **ActiveModel::Model** ([commit](https://github.com/rails/rails/commit/3b822e91d1a6c4eab0064989bbd07aae3a6d0d08)) - `ActiveModel::Model`, un mixin pour rendre les objets Ruby normaux compatibles avec ActionPack (par exemple pour `form_for`).
 * **Nouvelle API de portée** ([commit](https://github.com/rails/rails/commit/50cbc03d18c5984347965a94027879623fc44cce)) - Les portées doivent toujours utiliser des fonctions appelables.
 * **Dump du cache du schéma** ([commit](https://github.com/rails/rails/commit/5ca4fc95818047108e69e22d200e7a4a22969477)) - Pour améliorer le temps de démarrage de Rails, au lieu de charger le schéma directement depuis la base de données, chargez le schéma à partir d'un fichier de dump.
 * **Prise en charge de la spécification du niveau d'isolation de la transaction** ([commit](https://github.com/rails/rails/commit/392eeecc11a291e406db927a18b75f41b2658253)) - Choisissez si la lecture répétable ou les performances améliorées (moins de verrouillage) sont plus importantes.
 * **Dalli** ([commit](https://github.com/rails/rails/commit/82663306f428a5bbc90c511458432afb26d2f238)) - Utilisez le client Dalli memcache pour le magasin memcache.
 * **Notifications de début et de fin** ([commit](https://github.com/rails/rails/commit/f08f8750a512f741acb004d0cebe210c5f949f28)) - L'instrumentation Active Support signale les notifications de début et de fin aux abonnés.
 * **Thread safe par défaut** ([commit](https://github.com/rails/rails/commit/5d416b907864d99af55ebaa400fff217e17570cd)) - Rails peut s'exécuter dans des serveurs d'applications threadés sans configuration supplémentaire.

NOTE : Vérifiez que les gems que vous utilisez sont thread-safe.

 * **Verbe PATCH** ([commit](https://github.com/rails/rails/commit/eed9f2539e3ab5a68e798802f464b8e4e95e619e)) - Dans Rails, PATCH remplace PUT. PATCH est utilisé pour les mises à jour partielles des ressources.

### Sécurité

* **match ne capture pas tout** ([commit](https://github.com/rails/rails/commit/90d2802b71a6e89aedfe40564a37bd35f777e541)) - Dans le DSL de routage, match nécessite que le verbe HTTP ou les verbes soient spécifiés.
* **échappement des entités HTML par défaut** ([commit](https://github.com/rails/rails/commit/5f189f41258b83d49012ec5a0678d827327e7543)) - Les chaînes rendues dans erb sont échappées sauf si elles sont enveloppées dans `raw` ou si `html_safe` est appelé.
* **Nouveaux en-têtes de sécurité** ([commit](https://github.com/rails/rails/commit/6794e92b204572d75a07bd6413bdae6ae22d5a82)) - Rails envoie les en-têtes suivants avec chaque requête HTTP : `X-Frame-Options` (empêche le clickjacking en interdisant au navigateur d'intégrer la page dans une frame), `X-XSS-Protection` (demande au navigateur d'arrêter l'injection de script) et `X-Content-Type-Options` (empêche le navigateur d'ouvrir un jpeg en tant qu'exécutable).

Extraction des fonctionnalités en gems
---------------------------

Dans Rails 4.0, plusieurs fonctionnalités ont été extraites en gems. Vous pouvez simplement ajouter les gems extraites à votre `Gemfile` pour rétablir la fonctionnalité.

* Méthodes de recherche basées sur des hachages et dynamiques ([GitHub](https://github.com/rails/activerecord-deprecated_finders))
* Protection contre l'assignation massive dans les modèles Active Record ([GitHub](https://github.com/rails/protected_attributes), [Pull Request](https://github.com/rails/rails/pull/7251))
* ActiveRecord::SessionStore ([GitHub](https://github.com/rails/activerecord-session_store), [Pull Request](https://github.com/rails/rails/pull/7436))
* Observateurs Active Record ([GitHub](https://github.com/rails/rails-observers), [Commit](https://github.com/rails/rails/commit/39e85b3b90c58449164673909a6f1893cba290b2))
* Active Resource ([GitHub](https://github.com/rails/activeresource), [Pull Request](https://github.com/rails/rails/pull/572), [Blog](http://yetimedia-blog-blog.tumblr.com/post/35233051627/activeresource-is-dead-long-live-activeresource))
* Action Caching ([GitHub](https://github.com/rails/actionpack-action_caching), [Pull Request](https://github.com/rails/rails/pull/7833))
* Page Caching ([GitHub](https://github.com/rails/actionpack-page_caching), [Pull Request](https://github.com/rails/rails/pull/7833))
* Sprockets ([GitHub](https://github.com/rails/sprockets-rails))
* Tests de performance ([GitHub](https://github.com/rails/rails-perftest), [Pull Request](https://github.com/rails/rails/pull/8876))

Documentation
-------------

* Les guides sont réécrits en Markdown GitHub Flavored.

* Les guides ont un design responsive.

Railties
--------

Veuillez vous référer au [Changelog](https://github.com/rails/rails/blob/4-0-stable/railties/CHANGELOG.md) pour des changements détaillés.

### Changements notables

* Nouveaux emplacements de tests `test/models`, `test/helpers`, `test/controllers` et `test/mailers`. Les tâches rake correspondantes ont également été ajoutées. ([Pull Request](https://github.com/rails/rails/pull/7878))

* Les exécutables de votre application se trouvent désormais dans le répertoire `bin/`. Exécutez `rake rails:update:bin` pour obtenir `bin/bundle`, `bin/rails` et `bin/rake`.

* Threadsafe activé par défaut

* La possibilité d'utiliser un constructeur personnalisé en passant `--builder` (ou `-b`) à `rails new` a été supprimée. Considérez plutôt l'utilisation de modèles d'application. ([Pull Request](https://github.com/rails/rails/pull/9401))

### Dépréciations

* `config.threadsafe!` est déprécié au profit de `config.eager_load` qui offre un contrôle plus précis sur ce qui est chargé en avance.

* `Rails::Plugin` a disparu. Au lieu d'ajouter des plugins à `vendor/plugins`, utilisez des gems ou bundler avec des dépendances de chemin ou de git.

Action Mailer
-------------

Veuillez vous référer au [Changelog](https://github.com/rails/rails/blob/4-0-stable/actionmailer/CHANGELOG.md) pour des changements détaillés.

### Changements notables

### Dépréciations

Active Model
------------

Veuillez vous référer au [Changelog](https://github.com/rails/rails/blob/4-0-stable/activemodel/CHANGELOG.md) pour des changements détaillés.
### Changements notables

* Ajout de `ActiveModel::ForbiddenAttributesProtection`, un module simple pour protéger les attributs contre l'assignation de masse lorsque des attributs non autorisés sont passés.

* Ajout de `ActiveModel::Model`, un mixin permettant aux objets Ruby de fonctionner avec Action Pack dès le départ.

### Dépréciations

Active Support
--------------

Veuillez vous référer au [journal des modifications](https://github.com/rails/rails/blob/4-0-stable/activesupport/CHANGELOG.md) pour des changements détaillés.

### Changements notables

* Remplacement de la gemme `memcache-client` obsolète par `dalli` dans `ActiveSupport::Cache::MemCacheStore`.

* Optimisation de `ActiveSupport::Cache::Entry` pour réduire la consommation de mémoire et les frais de traitement.

* Les inflections peuvent maintenant être définies par locale. `singularize` et `pluralize` acceptent la locale en argument supplémentaire.

* `Object#try` renverra désormais nil au lieu de lever une erreur NoMethodError si l'objet récepteur n'implémente pas la méthode, mais vous pouvez toujours obtenir l'ancien comportement en utilisant le nouveau `Object#try!`.

* `String#to_date` lève maintenant `ArgumentError: invalid date` au lieu de `NoMethodError: undefined method 'div' for nil:NilClass` lorsqu'une date invalide est donnée. C'est maintenant identique à `Date.parse`, et il accepte plus de dates invalides que dans la version 3.x, par exemple :

    ```ruby
    # ActiveSupport 3.x
    "asdf".to_date # => NoMethodError: undefined method `div' for nil:NilClass
    "333".to_date # => NoMethodError: undefined method `div' for nil:NilClass

    # ActiveSupport 4
    "asdf".to_date # => ArgumentError: invalid date
    "333".to_date # => Fri, 29 Nov 2013
    ```

### Dépréciations

* Dépréciation de la méthode `ActiveSupport::TestCase#pending`, utilisez `skip` de minitest à la place.

* `ActiveSupport::Benchmarkable#silence` a été déprécié en raison de son manque de sécurité au niveau des threads. Il sera supprimé sans remplacement dans Rails 4.1.

* `ActiveSupport::JSON::Variable` est déprécié. Définissez vos propres méthodes `#as_json` et `#encode_json` pour les littéraux de chaîne JSON personnalisés.

* Déprécation de la méthode de compatibilité `Module#local_constant_names`, utilisez `Module#local_constants` à la place (qui renvoie des symboles).

* `ActiveSupport::BufferedLogger` est déprécié. Utilisez `ActiveSupport::Logger`, ou le logger de la bibliothèque standard Ruby.

* Dépréciation de `assert_present` et `assert_blank` au profit de `assert object.blank?` et `assert object.present?`

Action Pack
-----------

Veuillez vous référer au [journal des modifications](https://github.com/rails/rails/blob/4-0-stable/actionpack/CHANGELOG.md) pour des changements détaillés.

### Changements notables

* Modification de la feuille de style des pages d'exception en mode développement. Affichage également de la ligne de code et du fragment qui ont provoqué l'exception dans toutes les pages d'exception.

### Dépréciations


Active Record
-------------

Veuillez vous référer au [journal des modifications](https://github.com/rails/rails/blob/4-0-stable/activerecord/CHANGELOG.md) pour des changements détaillés.

### Changements notables

* Amélioration des façons d'écrire les migrations `change`, rendant les anciennes méthodes `up` et `down` inutiles.

    * Les méthodes `drop_table` et `remove_column` sont désormais réversibles, à condition que les informations nécessaires soient fournies.
      La méthode `remove_column` acceptait auparavant plusieurs noms de colonnes ; utilisez plutôt `remove_columns` (qui n'est pas réversible).
      La méthode `change_table` est également réversible, à condition que son bloc n'appelle pas `remove`, `change` ou `change_default`.

    * La nouvelle méthode `reversible` permet de spécifier du code à exécuter lors de la migration vers le haut ou vers le bas.
      Voir le [Guide sur les migrations](https://github.com/rails/rails/blob/main/guides/source/active_record_migrations.md#using-reversible)

    * La nouvelle méthode `revert` permet de revenir en arrière sur une migration entière ou sur le bloc donné.
      Si la migration est effectuée vers le bas, la migration / le bloc donné est exécuté normalement.
      Voir le [Guide sur les migrations](https://github.com/rails/rails/blob/main/guides/source/active_record_migrations.md#reverting-previous-migrations)

* Ajout de la prise en charge du type de tableau PostgreSQL. N'importe quel type de données peut être utilisé pour créer une colonne de tableau, avec une prise en charge complète des migrations et du générateur de schéma.

* Ajout de `Relation#load` pour charger explicitement l'enregistrement et renvoyer `self`.

* `Model.all` renvoie maintenant une `ActiveRecord::Relation`, plutôt qu'un tableau d'enregistrements. Utilisez `Relation#to_a` si vous voulez vraiment un tableau. Dans certains cas spécifiques, cela peut causer des problèmes lors de la mise à niveau.
* Ajout de `ActiveRecord::Migration.check_pending!` qui génère une erreur si des migrations sont en attente.

* Ajout de la prise en charge des codeurs personnalisés pour `ActiveRecord::Store`. Maintenant, vous pouvez définir votre codeur personnalisé comme ceci :

        store :settings, accessors: [ :color, :homepage ], coder: JSON

* Les connexions `mysql` et `mysql2` définiront `SQL_MODE=STRICT_ALL_TABLES` par défaut pour éviter toute perte de données silencieuse. Cela peut être désactivé en spécifiant `strict: false` dans votre `database.yml`.

* Suppression de IdentityMap.

* Suppression de l'exécution automatique des requêtes EXPLAIN. L'option `active_record.auto_explain_threshold_in_seconds` n'est plus utilisée et doit être supprimée.

* Ajout de `ActiveRecord::NullRelation` et `ActiveRecord::Relation#none` qui implémentent le modèle d'objet nul pour la classe Relation.

* Ajout de l'aide à la migration `create_join_table` pour créer des tables de jointure HABTM.

* Permet la création d'enregistrements hstore PostgreSQL.

### Dépréciations

* Dépréciation de l'ancienne API de recherche basée sur des hachages. Cela signifie que les méthodes qui acceptaient auparavant des "options de recherche" ne le font plus.

* Toutes les méthodes dynamiques, à l'exception de `find_by_...` et `find_by_...!`, sont dépréciées. Voici comment vous pouvez réécrire le code :

      * `find_all_by_...` peut être réécrit en utilisant `where(...)`.
      * `find_last_by_...` peut être réécrit en utilisant `where(...).last`.
      * `scoped_by_...` peut être réécrit en utilisant `where(...)`.
      * `find_or_initialize_by_...` peut être réécrit en utilisant `find_or_initialize_by(...)`.
      * `find_or_create_by_...` peut être réécrit en utilisant `find_or_create_by(...)`.
      * `find_or_create_by_...!` peut être réécrit en utilisant `find_or_create_by!(...)`.

Crédits
-------

Consultez la [liste complète des contributeurs à Rails](https://contributors.rubyonrails.org/) pour les nombreuses personnes qui ont passé de nombreuses heures à faire de Rails le framework stable et robuste qu'il est. Bravo à tous.
