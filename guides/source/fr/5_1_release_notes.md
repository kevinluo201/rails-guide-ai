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

Ces notes de version ne couvrent que les changements majeurs. Pour en savoir plus sur les corrections de bugs et les changements divers, veuillez vous référer aux journaux des modifications ou consulter la [liste des engagements](https://github.com/rails/rails/commits/5-1-stable) dans le référentiel principal de Rails sur GitHub.

--------------------------------------------------------------------------------

Mise à niveau vers Rails 5.1
---------------------------

Si vous mettez à niveau une application existante, il est conseillé d'avoir une bonne couverture de tests avant de commencer. Vous devriez également d'abord passer à Rails 5.0 au cas où vous ne l'auriez pas déjà fait et vous assurer que votre application fonctionne toujours comme prévu avant de tenter une mise à jour vers Rails 5.1. Une liste de points à surveiller lors de la mise à niveau est disponible dans le guide [Mise à niveau de Ruby on Rails](upgrading_ruby_on_rails.html#upgrading-from-rails-5-0-to-rails-5-1).

Fonctionnalités majeures
------------------------

### Prise en charge de Yarn

[Pull Request](https://github.com/rails/rails/pull/26836)

Rails 5.1 permet de gérer les dépendances JavaScript depuis npm via Yarn. Cela facilitera l'utilisation de bibliothèques telles que React, VueJS ou toute autre bibliothèque du monde npm. La prise en charge de Yarn est intégrée au pipeline d'assets de manière à ce que toutes les dépendances fonctionnent parfaitement avec l'application Rails 5.1.

### Prise en charge facultative de Webpack

[Pull Request](https://github.com/rails/rails/pull/27288)

Les applications Rails peuvent s'intégrer plus facilement avec [Webpack](https://webpack.js.org/), un assembleur d'assets JavaScript, en utilisant la nouvelle gem [Webpacker](https://github.com/rails/webpacker). Utilisez le drapeau `--webpack` lors de la génération de nouvelles applications pour activer l'intégration de Webpack.

Cela est entièrement compatible avec le pipeline d'assets, que vous pouvez continuer à utiliser pour les images, les polices, les sons et autres assets. Vous pouvez même avoir du code JavaScript géré par le pipeline d'assets et d'autres code traité via Webpack. Tout cela est géré par Yarn, qui est activé par défaut.

### jQuery n'est plus une dépendance par défaut

[Pull Request](https://github.com/rails/rails/pull/27113)

jQuery était requis par défaut dans les versions précédentes de Rails pour fournir des fonctionnalités telles que `data-remote`, `data-confirm` et d'autres parties des offres JavaScript non intrusives de Rails. Il n'est plus requis, car l'UJS a été réécrit pour utiliser du JavaScript pur et simple. Ce code est désormais inclus dans Action View en tant que `rails-ujs`.

Vous pouvez toujours utiliser jQuery si nécessaire, mais il n'est plus requis par défaut.

### Tests système

[Pull Request](https://github.com/rails/rails/pull/26703)

Rails 5.1 dispose d'une prise en charge intégrée pour l'écriture de tests Capybara, sous la forme de tests système. Vous n'avez plus besoin de vous soucier de la configuration de Capybara et des stratégies de nettoyage de la base de données pour de tels tests. Rails 5.1 fournit un wrapper pour exécuter des tests dans Chrome avec des fonctionnalités supplémentaires telles que des captures d'écran en cas d'échec.

### Secrets chiffrés

[Pull Request](https://github.com/rails/rails/pull/28038)

Rails permet désormais de gérer les secrets de l'application de manière sécurisée, inspiré par la gem [sekrets](https://github.com/ahoward/sekrets).

Exécutez `bin/rails secrets:setup` pour configurer un nouveau fichier de secrets chiffrés. Cela générera également une clé principale, qui doit être stockée en dehors du référentiel. Les secrets eux-mêmes peuvent ensuite être enregistrés en toute sécurité dans le système de contrôle de révision, sous une forme chiffrée.

Les secrets seront déchiffrés en production, en utilisant une clé stockée soit dans la variable d'environnement `RAILS_MASTER_KEY`, soit dans un fichier de clé.

### Mailers paramétrés

[Pull Request](https://github.com/rails/rails/pull/27825)

Permet de spécifier des paramètres communs utilisés pour toutes les méthodes d'une classe de mailer afin de partager des variables d'instance, des en-têtes et d'autres configurations communes.

```ruby
class InvitationsMailer < ApplicationMailer
  before_action { @inviter, @invitee = params[:inviter], params[:invitee] }
  before_action { @account = params[:inviter].account }

  def account_invitation
    mail subject: "#{@inviter.name} invited you to their Basecamp (#{@account.name})"
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
resource :basket

resolve("Basket") { [:basket] }
```

```erb
<%= form_for @basket do |form| %>
  <!-- formulaire du panier -->
<% end %>
```

Cela générera l'URL singulière `/basket` au lieu de l'URL habituelle `/baskets/:id`.

La méthode `direct` permet de créer des helpers d'URL personnalisés.

```ruby
direct(:homepage) { "https://rubyonrails.org" }

homepage_url # => "https://rubyonrails.org"
```

La valeur de retour du bloc doit être un argument valide pour la méthode `url_for`. Vous pouvez donc passer une URL sous forme de chaîne valide, un Hash, un Array, une instance Active Model ou une classe Active Model.

```ruby
direct :commentable do |model|
  [ model, anchor: model.dom_id ]
end

direct :main do
  { controller: 'pages', action: 'index', subdomain: 'www' }
end
```
### Unification de form_for et form_tag en form_with

[Pull Request](https://github.com/rails/rails/pull/26976)

Avant Rails 5.1, il y avait deux interfaces pour gérer les formulaires HTML :
`form_for` pour les instances de modèle et `form_tag` pour les URL personnalisées.

Rails 5.1 combine ces deux interfaces avec `form_with`, et
peut générer des balises de formulaire en fonction des URL, des scopes ou des modèles.

Utilisation d'une URL uniquement :

```erb
<%= form_with url: posts_path do |form| %>
  <%= form.text_field :title %>
<% end %>

<%# Générera %>

<form action="/posts" method="post" data-remote="true">
  <input type="text" name="title">
</form>
```

L'ajout d'un scope préfixe les noms des champs de saisie :

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

Lorsqu'un test génère des threads supplémentaires, et que ces threads obtiennent des connexions de base de données, ces connexions sont désormais gérées de manière spéciale :

Les threads partageront une seule connexion, qui se trouve à l'intérieur de la transaction gérée. Cela garantit que tous les threads voient la base de données dans le même état, en ignorant la transaction la plus externe. Auparavant, de telles connexions supplémentaires ne pouvaient pas voir les lignes de fixture, par exemple.

Lorsqu'un thread entre dans une transaction imbriquée, il obtient temporairement l'utilisation exclusive de la connexion, afin de maintenir l'isolation.

Si vos tests dépendent actuellement de l'obtention d'une connexion séparée, en dehors de la transaction, dans un thread généré, vous devrez passer à une gestion de connexion plus explicite.

Si vos tests génèrent des threads et que ces threads interagissent tout en utilisant également des transactions de base de données explicites, ce changement peut introduire un deadlock.

La manière la plus simple de désactiver ce nouveau comportement est de désactiver les tests transactionnels sur tous les cas de test concernés.

Railties
--------

Veuillez vous référer au [Changelog][railties] pour des changements détaillés.

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

*   Ajout d'une section partagée à `config/secrets.yml` qui sera chargée pour tous
    les environnements.
    ([commit](https://github.com/rails/rails/commit/e530534265d2c32b5c5f772e81cb9002dcf5e9cf))

*   Le fichier de configuration `config/secrets.yml` est maintenant chargé avec toutes les clés en tant que symboles.
    ([Pull Request](https://github.com/rails/rails/pull/26929))

*   Suppression de jquery-rails de la pile par défaut. rails-ujs, qui est inclus
    avec Action View, est inclus en tant qu'adaptateur UJS par défaut.
    ([Pull Request](https://github.com/rails/rails/pull/27113))

*   Ajout de la prise en charge de Yarn dans les nouvelles applications avec un binstub yarn et package.json.
    ([Pull Request](https://github.com/rails/rails/pull/26836))

*   Ajout de la prise en charge de Webpack dans les nouvelles applications via l'option `--webpack`, qui déléguera
    au gem rails/webpacker.
    ([Pull Request](https://github.com/rails/rails/pull/27288))

*   Initialisation du dépôt Git lors de la génération d'une nouvelle application, si l'option `--skip-git` n'est pas
    fournie.
    ([Pull Request](https://github.com/rails/rails/pull/27632))

*   Ajout de secrets chiffrés dans `config/secrets.yml.enc`.
    ([Pull Request](https://github.com/rails/rails/pull/28038))

*   Affichage du nom de la classe railtie dans `rails initializers`.
    ([Pull Request](https://github.com/rails/rails/pull/25257))

Action Cable
-----------

Veuillez vous référer au [Changelog][action-cable] pour des changements détaillés.

### Changements notables

*   Ajout de la prise en charge de `channel_prefix` aux adaptateurs Redis et Redis evented
    dans `cable.yml` pour éviter les collisions de noms lors de l'utilisation du même serveur Redis
    avec plusieurs applications.
    ([Pull Request](https://github.com/rails/rails/pull/27425))

*   Ajout du hook `ActiveSupport::Notifications` pour la diffusion de données.
    ([Pull Request](https://github.com/rails/rails/pull/24988))

Action Pack
-----------

Veuillez vous référer au [Changelog][action-pack] pour des changements détaillés.

### Suppressions

*   Suppression de la prise en charge des arguments non clés dans `#process`, `#get`, `#post`,
    `#patch`, `#put`, `#delete` et `#head` pour les classes `ActionDispatch::IntegrationTest`
    et `ActionController::TestCase`.
    ([Commit](https://github.com/rails/rails/commit/98b8309569a326910a723f521911e54994b112fb),
    [Commit](https://github.com/rails/rails/commit/de9542acd56f60d281465a59eac11e15ca8b3323))

*   Suppression des méthodes obsolètes `ActionDispatch::Callbacks.to_prepare` et
    `ActionDispatch::Callbacks.to_cleanup`.
    ([Commit](https://github.com/rails/rails/commit/3f2b7d60a52ffb2ad2d4fcf889c06b631db1946b))

*   Suppression des méthodes obsolètes liées aux filtres de contrôleur.
    ([Commit](https://github.com/rails/rails/commit/d7be30e8babf5e37a891522869e7b0191b79b757))

*   Suppression de la prise en charge obsolète de `:text` et `:nothing` dans `render`.
    ([Commit](https://github
### Changements notables

*   Ajout des méthodes `direct` et `resolve` à la DSL de routage.
    ([Pull Request](https://github.com/rails/rails/pull/23138))

*   Ajout d'une nouvelle classe `ActionDispatch::SystemTestCase` pour écrire des tests système dans vos applications.
    ([Pull Request](https://github.com/rails/rails/pull/26703))

Action View
-------------

Veuillez vous référer au [Changelog][action-view] pour des changements détaillés.

### Suppressions

*   Suppression de `#original_exception` obsolète dans `ActionView::Template::Error`.
    ([commit](https://github.com/rails/rails/commit/b9ba263e5aaa151808df058f5babfed016a1879f))

*   Suppression de l'option `encode_special_chars` mal nommée de `strip_tags`.
    ([Pull Request](https://github.com/rails/rails/pull/28061))

### Obsolescences

*   Obsolescence du gestionnaire ERB Erubis au profit de Erubi.
    ([Pull Request](https://github.com/rails/rails/pull/27757))

### Changements notables

*   Le gestionnaire de modèle brut (le gestionnaire de modèle par défaut dans Rails 5) génère maintenant des chaînes HTML sécurisées.
    ([commit](https://github.com/rails/rails/commit/1de0df86695f8fa2eeae6b8b46f9b53decfa6ec8))

*   Changement de `datetime_field` et `datetime_field_tag` pour générer des champs `datetime-local`.
    ([Pull Request](https://github.com/rails/rails/pull/25469))

*   Nouvelle syntaxe de style Builder pour les balises HTML (`tag.div`, `tag.br`, etc.).
    ([Pull Request](https://github.com/rails/rails/pull/25543))

*   Ajout de `form_with` pour unifier l'utilisation de `form_tag` et `form_for`.
    ([Pull Request](https://github.com/rails/rails/pull/26976))

*   Ajout de l'option `check_parameters` à `current_page?`.
    ([Pull Request](https://github.com/rails/rails/pull/27549))

Action Mailer
-------------

Veuillez vous référer au [Changelog][action-mailer] pour des changements détaillés.

### Changements notables

*   Autorisation de définir un type de contenu personnalisé lorsque des pièces jointes sont incluses et que le corps est défini en ligne.
    ([Pull Request](https://github.com/rails/rails/pull/27227))

*   Autorisation de passer des lambdas en tant que valeurs à la méthode `default`.
    ([Commit](https://github.com/rails/rails/commit/1cec84ad2ddd843484ed40b1eb7492063ce71baf))

*   Ajout de la prise en charge de l'invocation paramétrée des mailers pour partager des filtres et des valeurs par défaut entre différentes actions de mailer.
    ([Commit](https://github.com/rails/rails/commit/1cec84ad2ddd843484ed40b1eb7492063ce71baf))

*   Passage des arguments entrants à l'action du mailer à l'événement `process.action_mailer` sous une clé `args`.
    ([Pull Request](https://github.com/rails/rails/pull/27900))

Active Record
-------------

Veuillez vous référer au [Changelog][active-record] pour des changements détaillés.

### Suppressions

*   Suppression de la prise en charge de la transmission d'arguments et de bloc en même temps à `ActiveRecord::QueryMethods#select`.
    ([Commit](https://github.com/rails/rails/commit/4fc3366d9d99a0eb19e45ad2bf38534efbf8c8ce))

*   Suppression des plages i18n obsolètes `activerecord.errors.messages.restrict_dependent_destroy.one` et `activerecord.errors.messages.restrict_dependent_destroy.many`.
    ([Commit](https://github.com/rails/rails/commit/00e3973a311))

*   Suppression de l'argument de rechargement forcé obsolète dans les lecteurs d'association singuliers et de collection.
    ([Commit](https://github.com/rails/rails/commit/09cac8c67af))

*   Suppression de la prise en charge obsolète de la transmission d'une colonne à `#quote`.
    ([Commit](https://github.com/rails/rails/commit/e646bad5b7c))

*   Suppression des arguments `name` obsolètes de `#tables`.
    ([Commit](https://github.com/rails/rails/commit/d5be101dd02214468a27b6839ffe338cfe8ef5f3))

*   Suppression du comportement obsolète de `#tables` et `#table_exists?` pour ne retourner que des tables et non des vues.
    ([Commit](https://github.com/rails/rails/commit/5973a984c369a63720c2ac18b71012b8347479a8))

*   Suppression de l'argument `original_exception` obsolète dans `ActiveRecord::StatementInvalid#initialize` et `ActiveRecord::StatementInvalid#original_exception`.
    ([Commit](https://github.com/rails/rails/commit/bc6c5df4699d3f6b4a61dd12328f9e0f1bd6cf46))

*   Suppression de la prise en charge obsolète de la transmission d'une classe en tant que valeur dans une requête.
    ([Commit](https://github.com/rails/rails/commit/b4664864c972463c7437ad983832d2582186e886))

*   Suppression de la prise en charge obsolète de la requête en utilisant des virgules sur LIMIT.
    ([Commit](https://github.com/rails/rails/commit/fc3e67964753fb5166ccbd2030d7382e1976f393))

*   Suppression du paramètre `conditions` obsolète de `#destroy_all
Active Support
--------------

Veuillez vous référer au [journal des modifications][active-support] pour des changements détaillés.

### Suppressions

*   Suppression de la classe `ActiveSupport::Concurrency::Latch`.
    ([Commit](https://github.com/rails/rails/commit/0d7bd2031b4054fbdeab0a00dd58b1b08fb7fea6))

*   Suppression de `halt_callback_chains_on_return_false`.
    ([Commit](https://github.com/rails/rails/commit/4e63ce53fc25c3bc15c5ebf54bab54fa847ee02a))

*   Suppression du comportement obsolète qui arrête les rappels lorsque le retour est faux.
    ([Commit](https://github.com/rails/rails/commit/3a25cdca3e0d29ee2040931d0cb6c275d612dffe))

### Obsolescences

*   La classe `HashWithIndifferentAccess` de niveau supérieur a été doucement obsolète
    en faveur de `ActiveSupport::HashWithIndifferentAccess`.
    ([Pull Request](https://github.com/rails/rails/pull/28157))

*   Obsolescence du passage de chaîne aux options conditionnelles `:if` et `:unless` sur `set_callback` et `skip_callback`.
    ([Commit](https://github.com/rails/rails/commit/0952552))

### Changements notables

*   Correction de l'analyse de la durée et du déplacement pour le rendre cohérent lors des changements d'heure d'été.
    ([Commit](https://github.com/rails/rails/commit/8931916f4a1c1d8e70c06063ba63928c5c7eab1e),
    [Pull Request](https://github.com/rails/rails/pull/26597))

*   Mise à jour d'Unicode vers la version 9.0.0.
    ([Pull Request](https://github.com/rails/rails/pull/27822))

*   Ajout de Duration#before et #after comme alias de #ago et #since.
    ([Pull Request](https://github.com/rails/rails/pull/27721))

*   Ajout de `Module#delegate_missing_to` pour déléguer les appels de méthode non
    définis pour l'objet courant à un objet proxy.
    ([Pull Request](https://github.com/rails/rails/pull/23930))

*   Ajout de `Date#all_day` qui renvoie une plage représentant toute la journée
    de la date et de l'heure actuelles.
    ([Pull Request](https://github.com/rails/rails/pull/24930))

*   Introduction des méthodes `assert_changes` et `assert_no_changes` pour les tests.
    ([Pull Request](https://github.com/rails/rails/pull/25393))

*   Les méthodes `travel` et `travel_to` lèvent maintenant une exception lors d'appels imbriqués.
    ([Pull Request](https://github.com/rails/rails/pull/24890))

*   Mise à jour de `DateTime#change` pour prendre en charge usec et nsec.
    ([Pull Request](https://github.com/rails/rails/pull/28242))

Crédits
-------

Consultez la
[liste complète des contributeurs à Rails](https://contributors.rubyonrails.org/) pour
les nombreuses personnes qui ont passé de nombreuses heures à faire de Rails, le framework stable et robuste qu'il est. Félicitations à tous.

[railties]:       https://github.com/rails/rails/blob/5-1-stable/railties/CHANGELOG.md
[action-pack]:    https://github.com/rails/rails/blob/5-1-stable/actionpack/CHANGELOG.md
[action-view]:    https://github.com/rails/rails/blob/5-1-stable/actionview/CHANGELOG.md
[action-mailer]:  https://github.com/rails/rails/blob/5-1-stable/actionmailer/CHANGELOG.md
[action-cable]:   https://github.com/rails/rails/blob/5-1-stable/actioncable/CHANGELOG.md
[active-record]:  https://github.com/rails/rails/blob/5-1-stable/activerecord/CHANGELOG.md
[active-model]:   https://github.com/rails/rails/blob/5-1-stable/activemodel/CHANGELOG.md
[active-job]:     https://github.com/rails/rails/blob/5-1-stable/activejob/CHANGELOG.md
[active-support]: https://github.com/rails/rails/blob/5-1-stable/activesupport/CHANGELOG.md
