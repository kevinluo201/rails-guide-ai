**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: ddd82b1a207070829b1ec46e4bb40d80
Notes de version de Ruby on Rails 5.1
=======================================

Points forts de Rails 5.1 :

* Prise en charge de Yarn
* Prise en charge facultative de Webpack
* jQuery n'est plus une dépendance par défaut
* Tests système
* Secrets chiffrés
* Mailers paramétrés
* Routes directes et résolues
* Unification de form_for et form_tag en form_with

Ces notes de version ne couvrent que les changements majeurs. Pour en savoir plus sur les corrections de bugs et les changements divers, veuillez consulter les journaux des modifications ou consulter la [liste des validations](https://github.com/rails/rails/commits/5-1-stable) dans le référentiel principal de Rails sur GitHub.

--------------------------------------------------------------------------------

Mise à niveau vers Rails 5.1
----------------------------

Si vous mettez à niveau une application existante, il est conseillé d'avoir une bonne couverture de tests avant de commencer. Vous devriez également d'abord passer à Rails 5.0 au cas où vous ne l'auriez pas déjà fait et vous assurer que votre application fonctionne toujours comme prévu avant de tenter une mise à jour vers Rails 5.1. Une liste de points à surveiller lors de la mise à niveau est disponible dans le guide [Mise à niveau de Ruby on Rails](upgrading_ruby_on_rails.html#upgrading-from-rails-5-0-to-rails-5-1).

Fonctionnalités majeures
------------------------

### Prise en charge de Yarn

[Pull Request](https://github.com/rails/rails/pull/26836)

Rails 5.1 permet de gérer les dépendances JavaScript via npm via Yarn. Cela facilitera l'utilisation de bibliothèques telles que React, VueJS ou toute autre bibliothèque du monde npm. La prise en charge de Yarn est intégrée au pipeline d'actifs de sorte que toutes les dépendances fonctionneront parfaitement avec l'application Rails 5.1.

### Prise en charge facultative de Webpack

[Pull Request](https://github.com/rails/rails/pull/27288)

Les applications Rails peuvent s'intégrer plus facilement à [Webpack](https://webpack.js.org/), un assembleur d'actifs JavaScript, en utilisant le nouveau gem [Webpacker](https://github.com/rails/webpacker). Utilisez l'option `--webpack` lors de la génération de nouvelles applications pour activer l'intégration de Webpack.

Cela est entièrement compatible avec le pipeline d'actifs, que vous pouvez continuer à utiliser pour les images, les polices, les sons et autres actifs. Vous pouvez même avoir du code JavaScript géré par le pipeline d'actifs et un autre code traité via Webpack. Tout cela est géré par Yarn, qui est activé par défaut.

### jQuery n'est plus une dépendance par défaut
[Pull Request](https://github.com/rails/rails/pull/27113)

jQuery était requis par défaut dans les versions antérieures de Rails pour fournir des fonctionnalités telles que `data-remote`, `data-confirm` et d'autres parties de l'offre JavaScript non intrusive de Rails. Il n'est plus requis, car l'UJS a été réécrit pour utiliser du JavaScript simple et vanille. Ce code est maintenant inclus dans Action View en tant que `rails-ujs`.

Vous pouvez toujours utiliser jQuery si nécessaire, mais il n'est plus requis par défaut.

### Tests système

[Pull Request](https://github.com/rails/rails/pull/26703)

Rails 5.1 prend en charge intégrée pour l'écriture de tests Capybara, sous la forme de tests système. Vous n'avez plus besoin de vous soucier de la configuration de Capybara et des stratégies de nettoyage de la base de données pour de tels tests. Rails 5.1 fournit un wrapper pour exécuter des tests dans Chrome avec des fonctionnalités supplémentaires telles que des captures d'écran en cas d'échec.

### Secrets chiffrés

[Pull Request](https://github.com/rails/rails/pull/28038)

Rails permet désormais la gestion des secrets d'application de manière sécurisée, inspirée par le gem [sekrets](https://github.com/ahoward/sekrets).

Exécutez `bin/rails secrets:setup` pour configurer un nouveau fichier de secrets chiffrés. Cela générera également une clé maîtresse, qui doit être stockée en dehors du dépôt. Les secrets eux-mêmes peuvent ensuite être enregistrés en toute sécurité dans le système de contrôle de révision, sous une forme chiffrée.

Les secrets seront déchiffrés en production, en utilisant une clé stockée soit dans la variable d'environnement `RAILS_MASTER_KEY`, soit dans un fichier de clé.

### Mailers paramétrés

[Pull Request](https://github.com/rails/rails/pull/27825)

Permet de spécifier des paramètres communs utilisés pour toutes les méthodes d'une classe de mailer afin de partager des variables d'instance, des en-têtes et d'autres configurations communes.

```ruby
class InvitationsMailer < ApplicationMailer
  before_action { @inviter, @invitee = params[:inviter], params[:invitee] }
  before_action { @account = params[:inviter].account }

  def account_invitation
    mail subject: "#{@inviter.name} vous a invité à leur Basecamp (#{@account.name})"
  end
end
```

```ruby
InvitationsMailer.with(inviter: person_a, invitee: person_b)
                 .account_invitation.deliver_later
```

### Routes directes et résolues

[Pull Request](https://github.com/rails/rails/pull/23138)

Rails 5.1 ajoute deux nouvelles méthodes, `resolve` et `direct`, à la DSL de routage. La méthode `resolve` permet de personnaliser la correspondance polymorphique des modèles.
```ruby
resource :panier

resolve("Panier") { [:panier] }
```

```erb
<%= form_for @panier do |form| %>
  <!-- formulaire du panier -->
<% end %>
```

Cela générera l'URL singulière `/panier` au lieu de l'habituel `/paniers/:id`.

La méthode `direct` permet de créer des URL helpers personnalisés.

```ruby
direct(:page_d_accueil) { "https://rubyonrails.org" }

page_d_accueil_url # => "https://rubyonrails.org"
```

La valeur de retour du bloc doit être un argument valide pour la méthode `url_for`.
Vous pouvez donc passer une URL sous forme de chaîne valide, un Hash, un Array,
une instance Active Model ou une classe Active Model.

```ruby
direct :commentable do |model|
  [ model, anchor: model.dom_id ]
end

direct :principal do
  { controller: 'pages', action: 'index', subdomain: 'www' }
end
```

### Unification de form_for et form_tag en form_with

[Pull Request](https://github.com/rails/rails/pull/26976)

Avant Rails 5.1, il y avait deux interfaces pour gérer les formulaires HTML :
`form_for` pour les instances de modèle et `form_tag` pour les URLs personnalisées.

Rails 5.1 combine ces deux interfaces avec `form_with`, et
peut générer des balises de formulaire basées sur des URLs, des scopes ou des modèles.

En utilisant simplement une URL :

```erb
<%= form_with url: posts_path do |form| %>
  <%= form.text_field :title %>
<% end %>

<%# Générera %>

<form action="/posts" method="post" data-remote="true">
  <input type="text" name="title">
</form>
```

L'ajout d'un scope préfixe les noms des champs d'entrée :

```erb
<%= form_with scope: :post, url: posts_path do |form| %>
  <%= form.text_field :title %>
<% end %>

<%# Générera %>

<form action="/posts" method="post" data-remote="true">
  <input type="text" name="post[title]">
</form>
```

L'utilisation d'un modèle déduit à la fois l'URL et le scope :

```erb
<%= form_with model: Post.new do |form| %>
  <%= form.text_field :title %>
<% end %>

<%# Générera %>

<form action="/posts" method="post" data-remote="true">
  <input type="text" name="post[title]">
</form>
```

Un modèle existant crée un formulaire de mise à jour et remplit les valeurs des champs :

```erb
<%= form_with model: Post.first do |form| %>
  <%= form.text_field :title %>
<% end %>

<%# Générera %>

<form action="/posts/1" method="post" data-remote="true">
  <input type="hidden" name="_method" value="patch">
  <input type="text" name="post[title]" value="<le titre du post>">
</form>
```
Incompatibilités
-----------------

Les changements suivants peuvent nécessiter une action immédiate lors de la mise à niveau.

### Tests transactionnels avec plusieurs connexions

Les tests transactionnels enveloppent désormais toutes les connexions Active Record dans des transactions de base de données.

Lorsqu'un test génère des threads supplémentaires et que ces threads obtiennent des connexions de base de données, ces connexions sont désormais gérées de manière spéciale :

Les threads partageront une seule connexion, qui se trouve à l'intérieur de la transaction gérée. Cela garantit que tous les threads voient la base de données dans le même état, en ignorant la transaction la plus externe. Auparavant, de telles connexions supplémentaires ne pouvaient pas voir les lignes de données de test, par exemple.

Lorsqu'un thread entre dans une transaction imbriquée, il obtiendra temporairement l'utilisation exclusive de la connexion pour maintenir l'isolation.

Si vos tests dépendent actuellement de l'obtention d'une connexion séparée en dehors de la transaction dans un thread généré, vous devrez passer à une gestion de connexion plus explicite.

Si vos tests génèrent des threads et que ces threads interagissent tout en utilisant également des transactions de base de données explicites, ce changement peut entraîner un blocage.

La manière la plus simple de désactiver ce nouveau comportement est de désactiver les tests transactionnels sur tous les cas de test concernés.

Railties
--------

Veuillez vous référer au [journal des modifications][railties] pour des détails sur les changements.

### Suppressions

*   Suppression de `config.static_cache_control` obsolète.
    ([commit](https://github.com/rails/rails/commit/c861decd44198f8d7d774ee6a74194d1ac1a5a13))

*   Suppression de `config.serve_static_files` obsolète.
    ([commit](https://github.com/rails/rails/commit/0129ca2eeb6d5b2ea8c6e6be38eeb770fe45f1fa))

*   Suppression du fichier obsolète `rails/rack/debugger`.
    ([commit](https://github.com/rails/rails/commit/7563bf7b46e6f04e160d664e284a33052f9804b8))

*   Suppression des tâches obsolètes : `rails:update`, `rails:template`, `rails:template:copy`,
    `rails:update:configs` et `rails:update:bin`.
    ([commit](https://github.com/rails/rails/commit/f7782812f7e727178e4a743aa2874c078b722eef))

*   Suppression de la variable d'environnement `CONTROLLER` obsolète pour la tâche `routes`.
    ([commit](https://github.com/rails/rails/commit/f9ed83321ac1d1902578a0aacdfe55d3db754219))

*   Suppression de l'option -j (--javascript) de la commande `rails new`.
    ([Pull Request](https://github.com/rails/rails/pull/28546))

### Changements notables

*   Ajout d'une section partagée à `config/secrets.yml` qui sera chargée pour tous les environnements.
    ([commit](https://github.com/rails/rails/commit/e530534265d2c32b5c5f772e81cb9002dcf5e9cf))

*   Le fichier de configuration `config/secrets.yml` est maintenant chargé avec toutes les clés en tant que symboles.
    ([Pull Request](https://github.com/rails/rails/pull/26929))

*   Suppression de jquery-rails de la pile par défaut. rails-ujs, qui est inclus avec Action View, est utilisé comme adaptateur UJS par défaut.
    ([Pull Request](https://github.com/rails/rails/pull/27113))

*   Ajout de la prise en charge de Yarn dans les nouvelles applications avec un binstub Yarn et un package.json.
    ([Pull Request](https://github.com/rails/rails/pull/26836))
*   Ajouter la prise en charge de Webpack dans les nouvelles applications via l'option `--webpack`, qui déléguera au gem rails/webpacker.
    ([Pull Request](https://github.com/rails/rails/pull/27288))

*   Initialiser le dépôt Git lors de la génération d'une nouvelle application, si l'option `--skip-git` n'est pas fournie.
    ([Pull Request](https://github.com/rails/rails/pull/27632))

*   Ajouter des secrets chiffrés dans `config/secrets.yml.enc`.
    ([Pull Request](https://github.com/rails/rails/pull/28038))

*   Afficher le nom de la classe Railtie dans les initialisateurs de Rails.
    ([Pull Request](https://github.com/rails/rails/pull/25257))

Action Cable
-----------

Veuillez vous référer au [journal des modifications][action-cable] pour des changements détaillés.

### Changements notables

*   Ajout de la prise en charge de `channel_prefix` aux adaptateurs Redis et Redis evented dans `cable.yml` pour éviter les collisions de noms lors de l'utilisation du même serveur Redis avec plusieurs applications.
    ([Pull Request](https://github.com/rails/rails/pull/27425))

*   Ajout du crochet `ActiveSupport::Notifications` pour diffuser des données.
    ([Pull Request](https://github.com/rails/rails/pull/24988))

Action Pack
-----------

Veuillez vous référer au [journal des modifications][action-pack] pour des changements détaillés.

### Suppressions

*   Suppression de la prise en charge des arguments non clés dans `#process`, `#get`, `#post`, `#patch`, `#put`, `#delete` et `#head` pour les classes `ActionDispatch::IntegrationTest` et `ActionController::TestCase`.
    ([Commit](https://github.com/rails/rails/commit/98b8309569a326910a723f521911e54994b112fb),
    [Commit](https://github.com/rails/rails/commit/de9542acd56f60d281465a59eac11e15ca8b3323))

*   Suppression des méthodes dépréciées `ActionDispatch::Callbacks.to_prepare` et `ActionDispatch::Callbacks.to_cleanup`.
    ([Commit](https://github.com/rails/rails/commit/3f2b7d60a52ffb2ad2d4fcf889c06b631db1946b))

*   Suppression des méthodes dépréciées liées aux filtres de contrôleur.
    ([Commit](https://github.com/rails/rails/commit/d7be30e8babf5e37a891522869e7b0191b79b757))

*   Suppression de la prise en charge dépréciée de `:text` et `:nothing` dans `render`.
    ([Commit](https://github.com/rails/rails/commit/79a5ea9eadb4d43b62afacedc0706cbe88c54496),
    [Commit](https://github.com/rails/rails/commit/57e1c99a280bdc1b324936a690350320a1cd8111))

*   Suppression de la prise en charge dépréciée de l'appel des méthodes `HashWithIndifferentAccess` sur `ActionController::Parameters`.
    ([Commit](https://github.com/rails/rails/pull/26746/commits/7093ceb480ad6a0a91b511832dad4c6a86981b93))

### Dépréciations

*   Dépréciation de `config.action_controller.raise_on_unfiltered_parameters`.
    Cela n'a aucun effet dans Rails 5.1.
    ([Commit](https://github.com/rails/rails/commit/c6640fb62b10db26004a998d2ece98baede509e5))

### Changements notables

*   Ajout des méthodes `direct` et `resolve` à la DSL de routage.
    ([Pull Request](https://github.com/rails/rails/pull/23138))

*   Ajout d'une nouvelle classe `ActionDispatch::SystemTestCase` pour écrire des tests système dans vos applications.
    ([Pull Request](https://github.com/rails/rails/pull/26703))

Action View
-------------

Veuillez vous référer au [journal des modifications][action-view] pour des changements détaillés.

### Suppressions

*   Suppression de `#original_exception` déprécié dans `ActionView::Template::Error`.
    ([commit](https://github.com/rails/rails/commit/b9ba263e5aaa151808df058f5babfed016a1879f))

*   Suppression de l'option `encode_special_chars` mal nommée de `strip_tags`.
    ([Pull Request](https://github.com/rails/rails/pull/28061))

### Dépréciations

*   Dépréciation du gestionnaire ERB Erubis au profit de Erubi.
    ([Pull Request](https://github.com/rails/rails/pull/27757))

### Changements notables

*   Le gestionnaire de modèles bruts (le gestionnaire de modèles par défaut dans Rails 5) génère maintenant des chaînes HTML sécurisées.
    ([commit](https://github.com/rails/rails/commit/1de0df86695f8fa2eeae6b8b46f9b53decfa6ec8))

*   Modification de `datetime_field` et `datetime_field_tag` pour générer des champs `datetime-local`.
    ([Pull Request](https://github.com/rails/rails/pull/25469))

*   Nouvelle syntaxe de style Builder pour les balises HTML (`tag.div`, `tag.br`, etc.).
    ([Pull Request](https://github.com/rails/rails/pull/25543))
*   Ajouter `form_with` pour unifier l'utilisation de `form_tag` et `form_for`.
    ([Pull Request](https://github.com/rails/rails/pull/26976))

*   Ajouter l'option `check_parameters` à `current_page?`.
    ([Pull Request](https://github.com/rails/rails/pull/27549))

Action Mailer
-------------

Veuillez vous référer au [Changelog][action-mailer] pour des changements détaillés.

### Changements notables

*   Autoriser le réglage du type de contenu personnalisé lorsque des pièces jointes sont incluses
    et que le corps est défini en ligne.
    ([Pull Request](https://github.com/rails/rails/pull/27227))

*   Autoriser le passage de lambdas en tant que valeurs à la méthode `default`.
    ([Commit](https://github.com/rails/rails/commit/1cec84ad2ddd843484ed40b1eb7492063ce71baf))

*   Ajouter la prise en charge de l'invocation paramétrée des mailers pour partager les filtres
    et les valeurs par défaut entre différentes actions de mailer.
    ([Commit](https://github.com/rails/rails/commit/1cec84ad2ddd843484ed40b1eb7492063ce71baf))

*   Transmettre les arguments entrants à l'action du mailer à l'événement `process.action_mailer`
    sous une clé `args`.
    ([Pull Request](https://github.com/rails/rails/pull/27900))

Active Record
-------------

Veuillez vous référer au [Changelog][active-record] pour des changements détaillés.

### Suppressions

*   Supprimer la prise en charge du passage d'arguments et de bloc en même temps à
    `ActiveRecord::QueryMethods#select`.
    ([Commit](https://github.com/rails/rails/commit/4fc3366d9d99a0eb19e45ad2bf38534efbf8c8ce))

*   Supprimer les plages i18n dépréciées `activerecord.errors.messages.restrict_dependent_destroy.one` et
    `activerecord.errors.messages.restrict_dependent_destroy.many`.
    ([Commit](https://github.com/rails/rails/commit/00e3973a311))

*   Supprimer l'argument de rechargement forcé déprécié dans les lecteurs d'association singuliers et de collection.
    ([Commit](https://github.com/rails/rails/commit/09cac8c67af))

*   Supprimer la prise en charge dépréciée du passage d'une colonne à `#quote`.
    ([Commit](https://github.com/rails/rails/commit/e646bad5b7c))

*   Supprimer les arguments `name` dépréciés de `#tables`.
    ([Commit](https://github.com/rails/rails/commit/d5be101dd02214468a27b6839ffe338cfe8ef5f3))

*   Supprimer le comportement déprécié de `#tables` et `#table_exists?` pour renvoyer uniquement des tables et non des vues.
    ([Commit](https://github.com/rails/rails/commit/5973a984c369a63720c2ac18b71012b8347479a8))

*   Supprimer l'argument `original_exception` déprécié dans `ActiveRecord::StatementInvalid#initialize`
    et `ActiveRecord::StatementInvalid#original_exception`.
    ([Commit](https://github.com/rails/rails/commit/bc6c5df4699d3f6b4a61dd12328f9e0f1bd6cf46))

*   Supprimer la prise en charge dépréciée du passage d'une classe en tant que valeur dans une requête.
    ([Commit](https://github.com/rails/rails/commit/b4664864c972463c7437ad983832d2582186e886))

*   Supprimer la prise en charge dépréciée de la requête en utilisant des virgules sur LIMIT.
    ([Commit](https://github.com/rails/rails/commit/fc3e67964753fb5166ccbd2030d7382e1976f393))

*   Supprimer le paramètre `conditions` déprécié de `#destroy_all`.
    ([Commit](https://github.com/rails/rails/commit/d31a6d1384cd740c8518d0bf695b550d2a3a4e9b))

*   Supprimer le paramètre `conditions` déprécié de `#delete_all`.
    ([Commit](https://github.com/rails/rails/pull/27503/commits/e7381d289e4f8751dcec9553dcb4d32153bd922b))

*   Supprimer la méthode dépréciée `#load_schema_for` au profit de `#load_schema`.
    ([Commit](https://github.com/rails/rails/commit/419e06b56c3b0229f0c72d3e4cdf59d34d8e5545))

*   Supprimer la configuration dépréciée `#raise_in_transactional_callbacks`.
    ([Commit](https://github.com/rails/rails/commit/8029f779b8a1dd9848fee0b7967c2e0849bf6e07))

*   Supprimer la configuration dépréciée `#use_transactional_fixtures`.
    ([Commit](https://github.com/rails/rails/commit/3955218dc163f61c932ee80af525e7cd440514b3))

### Dépréciations

*   Déprécier le drapeau `error_on_ignored_order_or_limit` au profit de
    `error_on_ignored_order`.
    ([Commit](https://github.com/rails/rails/commit/451437c6f57e66cc7586ec966e530493927098c7))

*   Déprécier `sanitize_conditions` au profit de `sanitize_sql`.
    ([Pull Request](https://github.com/rails/rails/pull/25999))

*   Déprécier `supports_migrations?` sur les adaptateurs de connexion.
    ([Pull Request](https://github.com/rails/rails/pull/28172))

*   Déprécier `Migrator.schema_migrations_table_name`, utiliser `SchemaMigration.table_name` à la place.
    ([Pull Request](https://github.com/rails/rails/pull/28351))

*   Déprécier l'utilisation de `#quoted_id` dans la citation et la conversion de type.
    ([Pull Request](https://github.com/rails/rails/pull/27962))
*   Dépréciation de l'argument `default` passé à `#index_name_exists?`.
    ([Pull Request](https://github.com/rails/rails/pull/26930))

### Modifications notables

*   Changement des clés primaires par défaut en BIGINT.
    ([Pull Request](https://github.com/rails/rails/pull/26266))

*   Prise en charge des colonnes virtuelles/générées pour MySQL 5.7.5+ et MariaDB 5.2.0+.
    ([Commit](https://github.com/rails/rails/commit/65bf1c60053e727835e06392d27a2fb49665484c))

*   Ajout de la prise en charge des limites dans le traitement par lots.
    ([Commit](https://github.com/rails/rails/commit/451437c6f57e66cc7586ec966e530493927098c7))

*   Les tests transactionnels enveloppent maintenant toutes les connexions Active Record dans des transactions de base de données.
    ([Pull Request](https://github.com/rails/rails/pull/28726))

*   Les commentaires sont désormais ignorés dans la sortie de la commande `mysqldump` par défaut.
    ([Pull Request](https://github.com/rails/rails/pull/23301))

*   Correction de `ActiveRecord::Relation#count` pour utiliser `Enumerable#count` de Ruby pour compter les enregistrements lorsqu'un bloc est passé en argument au lieu de l'ignorer silencieusement.
    ([Pull Request](https://github.com/rails/rails/pull/24203))

*   Passage du drapeau `"-v ON_ERROR_STOP=1"` avec la commande `psql` pour ne pas supprimer les erreurs SQL.
    ([Pull Request](https://github.com/rails/rails/pull/24773))

*   Ajout de `ActiveRecord::Base.connection_pool.stat`.
    ([Pull Request](https://github.com/rails/rails/pull/26988))

*   L'héritage direct de `ActiveRecord::Migration` génère une erreur.
    Spécifiez la version de Rails pour laquelle la migration a été écrite.
    ([Commit](https://github.com/rails/rails/commit/249f71a22ab21c03915da5606a063d321f04d4d3))

*   Une erreur est générée lorsque l'association `through` a un nom de réflexion ambigu.
    ([Commit](https://github.com/rails/rails/commit/0944182ad7ed70d99b078b22426cbf844edd3f61))

Active Model
------------

Veuillez vous référer au [journal des modifications][active-model] pour plus de détails sur les changements.

### Suppressions

*   Suppression des méthodes dépréciées dans `ActiveModel::Errors`.
    ([commit](https://github.com/rails/rails/commit/9de6457ab0767ebab7f2c8bc583420fda072e2bd))

*   Suppression de l'option dépréciée `:tokenizer` dans le validateur de longueur.
    ([commit](https://github.com/rails/rails/commit/6a78e0ecd6122a6b1be9a95e6c4e21e10e429513))

*   Suppression du comportement déprécié qui arrête les rappels lorsque la valeur de retour est fausse.
    ([commit](https://github.com/rails/rails/commit/3a25cdca3e0d29ee2040931d0cb6c275d612dffe))

### Modifications notables

*   La chaîne originale attribuée à un attribut de modèle n'est plus incorrectement gelée.
    ([Pull Request](https://github.com/rails/rails/pull/28729))

Active Job
-----------

Veuillez vous référer au [journal des modifications][active-job] pour plus de détails sur les changements.

### Suppressions

*   Suppression du support déprécié pour passer la classe d'adaptateur à `.queue_adapter`.
    ([commit](https://github.com/rails/rails/commit/d1fc0a5eb286600abf8505516897b96c2f1ef3f6))

*   Suppression de `#original_exception` déprécié dans `ActiveJob::DeserializationError`.
    ([commit](https://github.com/rails/rails/commit/d861a1fcf8401a173876489d8cee1ede1cecde3b))

### Modifications notables

*   Ajout de la gestion déclarative des exceptions via `ActiveJob::Base.retry_on` et `ActiveJob::Base.discard_on`.
    ([Pull Request](https://github.com/rails/rails/pull/25991))

*   Renvoie l'instance de travail pour avoir accès à des éléments tels que `job.arguments` dans la logique personnalisée après l'échec des nouvelles tentatives.
    ([commit](https://github.com/rails/rails/commit/a1e4c197cb12fef66530a2edfaeda75566088d1f))

Active Support
--------------

Veuillez vous référer au [journal des modifications][active-support] pour plus de détails sur les changements.

### Suppressions

*   Suppression de la classe `ActiveSupport::Concurrency::Latch`.
    ([Commit](https://github.com/rails/rails/commit/0d7bd2031b4054fbdeab0a00dd58b1b08fb7fea6))

*   Suppression de `halt_callback_chains_on_return_false`.
    ([Commit](https://github.com/rails/rails/commit/4e63ce53fc25c3bc15c5ebf54bab54fa847ee02a))

*   Suppression du comportement déprécié qui arrête les rappels lorsque la valeur de retour est fausse.
    ([Commit](https://github.com/rails/rails/commit/3a25cdca3e0d29ee2040931d0cb6c275d612dffe))
### Dépréciations

*   La classe `HashWithIndifferentAccess` de niveau supérieur a été dépréciée en douceur
    en faveur de la classe `ActiveSupport::HashWithIndifferentAccess`.
    ([Pull Request](https://github.com/rails/rails/pull/28157))

*   Dépréciation du passage d'une chaîne de caractères aux options conditionnelles `:if` et `:unless` de `set_callback` et `skip_callback`.
    ([Commit](https://github.com/rails/rails/commit/0952552))

### Changements notables

*   Correction de l'analyse de la durée et du déplacement pour le rendre cohérent lors des changements d'heure d'été.
    ([Commit](https://github.com/rails/rails/commit/8931916f4a1c1d8e70c06063ba63928c5c7eab1e),
    [Pull Request](https://github.com/rails/rails/pull/26597))

*   Mise à jour d'Unicode vers la version 9.0.0.
    ([Pull Request](https://github.com/rails/rails/pull/27822))

*   Ajout des alias `Duration#before` et `#after` pour `#ago` et `#since`.
    ([Pull Request](https://github.com/rails/rails/pull/27721))

*   Ajout de `Module#delegate_missing_to` pour déléguer les appels de méthodes non
    définies pour l'objet courant à un objet proxy.
    ([Pull Request](https://github.com/rails/rails/pull/23930))

*   Ajout de `Date#all_day` qui renvoie une plage représentant toute la journée
    de la date et de l'heure actuelles.
    ([Pull Request](https://github.com/rails/rails/pull/24930))

*   Introduction des méthodes `assert_changes` et `assert_no_changes` pour les tests.
    ([Pull Request](https://github.com/rails/rails/pull/25393))

*   Les méthodes `travel` et `travel_to` lèvent maintenant une exception lors d'appels imbriqués.
    ([Pull Request](https://github.com/rails/rails/pull/24890))

*   Mise à jour de `DateTime#change` pour prendre en charge les microsecondes et les nanosecondes.
    ([Pull Request](https://github.com/rails/rails/pull/28242))

Crédits
-------

Consultez la
[liste complète des contributeurs à Rails](https://contributors.rubyonrails.org/) pour
les nombreuses personnes qui ont passé de nombreuses heures à faire de Rails, le framework stable et robuste qu'il est. Bravo à tous.
[active-support]: https://github.com/rails/rails/blob/5-1-stable/activesupport/CHANGELOG.md
