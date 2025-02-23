**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 95d91c83726e012162afc60c78688099
Ruby on Rails 4.1 Notes de version
===============================

Points forts de Rails 4.1 :

* Préchargeur d'application Spring
* `config/secrets.yml`
* Variants d'Action Pack
* Prévisualisations d'Action Mailer

Ces notes de version ne couvrent que les changements majeurs. Pour en savoir plus sur les corrections de bugs et les modifications, veuillez vous référer aux journaux des modifications ou consulter la [liste des validations](https://github.com/rails/rails/commits/4-1-stable) dans le référentiel principal de Rails sur GitHub.

--------------------------------------------------------------------------------

Mise à niveau vers Rails 4.1
----------------------

Si vous mettez à niveau une application existante, il est conseillé d'avoir une bonne couverture de tests avant de commencer. Vous devriez également d'abord passer à Rails 4.0 au cas où vous ne l'auriez pas déjà fait et vous assurer que votre application fonctionne toujours comme prévu avant de tenter une mise à jour vers Rails 4.1. Une liste de choses à surveiller lors de la mise à niveau est disponible dans le guide [Mise à niveau de Ruby on Rails](upgrading_ruby_on_rails.html#upgrading-from-rails-4-0-to-rails-4-1).

Fonctionnalités majeures
--------------

### Préchargeur d'application Spring

Spring est un préchargeur d'application Rails. Il accélère le développement en maintenant votre application en cours d'exécution en arrière-plan, de sorte que vous n'avez pas besoin de la démarrer à chaque fois que vous exécutez un test, une tâche rake ou une migration.

Les nouvelles applications Rails 4.1 seront livrées avec des binstubs "springifiés". Cela signifie que `bin/rails` et `bin/rake` profiteront automatiquement des environnements spring préchargés.

**Exécution des tâches rake :**

```bash
$ bin/rake test:models
```

**Exécution d'une commande Rails :**

```bash
$ bin/rails console
```

**Inspection de Spring :**

```bash
$ bin/spring status
Spring est en cours d'exécution :

 1182 spring server | my_app | démarré il y a 29 minutes
 3656 spring app    | my_app | démarré il y a 23 secondes | mode test
 3746 spring app    | my_app | démarré il y a 10 secondes | mode développement
```

Consultez le [README de Spring](https://github.com/rails/spring/blob/master/README.md) pour voir toutes les fonctionnalités disponibles.

Consultez le guide [Mise à niveau de Ruby on Rails](upgrading_ruby_on_rails.html#spring) pour savoir comment migrer les applications existantes pour utiliser cette fonctionnalité.

### `config/secrets.yml`

Rails 4.1 génère un nouveau fichier `secrets.yml` dans le dossier `config`. Par défaut, ce fichier contient la `secret_key_base` de l'application, mais il peut également être utilisé pour stocker d'autres secrets tels que des clés d'accès pour des API externes.

Les secrets ajoutés à ce fichier sont accessibles via `Rails.application.secrets`. Par exemple, avec le `config/secrets.yml` suivant :

```yaml
development:
  secret_key_base: 3b7cd727ee24e8444053437c36cc66c3
  some_api_key: SOMEKEY
```

`Rails.application.secrets.some_api_key` renvoie `SOMEKEY` dans l'environnement de développement.

Consultez le guide [Mise à niveau de Ruby on Rails](upgrading_ruby_on_rails.html#config-secrets-yml) pour savoir comment migrer les applications existantes pour utiliser cette fonctionnalité.

### Variants d'Action Pack

Nous voulons souvent rendre différents modèles HTML/JSON/XML pour les téléphones, les tablettes et les navigateurs de bureau. Les variants facilitent cela.

Le variant de la requête est une spécialisation du format de la requête, comme `:tablet`, `:phone` ou `:desktop`.

Vous pouvez définir le variant dans un `before_action` :

```ruby
request.variant = :tablet if request.user_agent =~ /iPad/
```

Répondez aux variants dans l'action de la même manière que vous répondez aux formats :

```ruby
respond_to do |format|
  format.html do |html|
    html.tablet # rend app/views/projects/show.html+tablet.erb
    html.phone { extra_setup; render ... }
  end
end
```

Fournissez des modèles distincts pour chaque format et variant :

```
app/views/projects/show.html.erb
app/views/projects/show.html+tablet.erb
app/views/projects/show.html+phone.erb
```

Vous pouvez également simplifier la définition des variants en utilisant la syntaxe en ligne :

```ruby
respond_to do |format|
  format.js         { render "trash" }
  format.html.phone { redirect_to progress_path }
  format.html.none  { render "trash" }
end
```
### Prévisualisations d'Action Mailer

Les prévisualisations d'Action Mailer permettent de voir à quoi ressemblent les e-mails en visitant une URL spéciale qui les affiche.

Vous implémentez une classe de prévisualisation dont les méthodes renvoient l'objet de courrier que vous souhaitez vérifier :

```ruby
class NotifierPreview < ActionMailer::Preview
  def welcome
    Notifier.welcome(User.first)
  end
end
```

La prévisualisation est disponible à l'adresse http://localhost:3000/rails/mailers/notifier/welcome, et une liste d'entre elles à l'adresse http://localhost:3000/rails/mailers.

Par défaut, ces classes de prévisualisation se trouvent dans `test/mailers/previews`. Cela peut être configuré à l'aide de l'option `preview_path`.

Consultez sa [documentation](https://api.rubyonrails.org/v4.1.0/classes/ActionMailer/Base.html#class-ActionMailer::Base-label-Previewing+emails) pour plus de détails.

### Énumérations Active Record

Déclarez un attribut énuméré dont les valeurs sont mappées sur des entiers dans la base de données, mais peuvent être interrogées par nom.

```ruby
class Conversation < ActiveRecord::Base
  enum status: [ :active, :archived ]
end

conversation.archived!
conversation.active? # => false
conversation.status  # => "archived"

Conversation.archived # => Relation pour toutes les conversations archivées

Conversation.statuses # => { "active" => 0, "archived" => 1 }
```

Consultez sa [documentation](https://api.rubyonrails.org/v4.1.0/classes/ActiveRecord/Enum.html) pour plus de détails.

### Vérificateurs de messages

Les vérificateurs de messages peuvent être utilisés pour générer et vérifier des messages signés. Cela peut être utile pour transporter en toute sécurité des données sensibles telles que des jetons de rappel et des amis.

La méthode `Rails.application.message_verifier` renvoie un nouveau vérificateur de messages qui signe les messages avec une clé dérivée de secret_key_base et du nom du vérificateur de messages donné :

```ruby
signed_token = Rails.application.message_verifier(:remember_me).generate(token)
Rails.application.message_verifier(:remember_me).verify(signed_token) # => token

Rails.application.message_verifier(:remember_me).verify(tampered_token)
# lève une exception ActiveSupport::MessageVerifier::InvalidSignature
```

### Module#concerning

Une façon naturelle et peu cérémonieuse de séparer les responsabilités au sein d'une classe :

```ruby
class Todo < ActiveRecord::Base
  concerning :EventTracking do
    included do
      has_many :events
    end

    def latest_event
      # ...
    end

    private
      def some_internal_method
        # ...
      end
  end
end
```

Cet exemple est équivalent à la définition d'un module `EventTracking` en ligne, en l'étendant avec `ActiveSupport::Concern`, puis en le mélangeant à la classe `Todo`.

Consultez sa [documentation](https://api.rubyonrails.org/v4.1.0/classes/Module/Concerning.html) pour plus de détails et les cas d'utilisation prévus.

### Protection CSRF contre les balises `<script>` distantes

La protection contre les attaques de falsification de requête intersite (CSRF) couvre désormais également les requêtes GET avec des réponses JavaScript. Cela empêche un site tiers de référencer votre URL JavaScript et de tenter de l'exécuter pour extraire des données sensibles.

Cela signifie que tous vos tests qui accèdent aux URL `.js` échoueront désormais à la protection CSRF, sauf s'ils utilisent `xhr`. Mettez à jour vos tests pour être explicites quant à l'attente de XmlHttpRequests. Au lieu de `post :create, format: :js`, passez à l'explicite `xhr :post, :create, format: :js`.

Railties
--------

Veuillez vous référer au [journal des modifications](https://github.com/rails/rails/blob/4-1-stable/railties/CHANGELOG.md) pour obtenir des détails sur les modifications apportées.

### Suppressions

* Suppression de la tâche rake `update:application_controller`.

* Suppression de `Rails.application.railties.engines` obsolète.

* Suppression de `threadsafe!` obsolète de Rails Config.

* Suppression de `ActiveRecord::Generators::ActiveModel#update_attributes` obsolète au profit de `ActiveRecord::Generators::ActiveModel#update`.

* Suppression de l'option `config.whiny_nils` obsolète.

* Suppression des tâches rake obsolètes pour l'exécution des tests : `rake test:uncommitted` et `rake test:recent`.

### Changements notables

* Le préchargeur d'application [Spring](https://github.com/rails/spring) est maintenant installé par défaut pour les nouvelles applications. Il utilise le groupe de développement du `Gemfile`, il ne sera donc pas installé en production. ([Demande de tirage](https://github.com/rails/rails/pull/12958))

* Variable d'environnement `BACKTRACE` pour afficher des traces complètes des erreurs de test. ([Commit](https://github.com/rails/rails/commit/84eac5dab8b0fe9ee20b51250e52ad7bfea36553))

* Exposition de `MiddlewareStack#unshift` à la configuration de l'environnement. ([Demande de tirage](https://github.com/rails/rails/pull/12479))

* Ajout de la méthode `Application#message_verifier` pour renvoyer un vérificateur de messages. ([Demande de tirage](https://github.com/rails/rails/pull/12995))

* Le fichier `test_help.rb`, requis par l'aide de test générée par défaut, met automatiquement à jour votre base de données de test avec `db/schema.rb` (ou `db/structure.sql`). Il génère une erreur si le rechargement du schéma ne résout pas toutes les migrations en attente. Désactivez cette fonctionnalité avec `config.active_record.maintain_test_schema = false`. ([Demande de tirage](https://github.com/rails/rails/pull/13528))
* Introduire `Rails.gem_version` comme une méthode pratique pour retourner `Gem::Version.new(Rails.version)`, suggérant une façon plus fiable de comparer les versions. ([Pull Request](https://github.com/rails/rails/pull/14103))


Action Pack
-----------

Veuillez vous référer au [Changelog](https://github.com/rails/rails/blob/4-1-stable/actionpack/CHANGELOG.md) pour les changements détaillés.

### Suppressions

* Suppression de la rétrocompatibilité de l'application Rails pour les tests d'intégration, définissez `ActionDispatch.test_app` à la place.

* Suppression de la configuration dépréciée `page_cache_extension`.

* Suppression de la constante dépréciée `ActionController::RecordIdentifier`, utilisez `ActionView::RecordIdentifier` à la place.

* Suppression des constantes dépréciées d'Action Controller :

| Supprimée                           | Successeur                      |
|:-----------------------------------|:--------------------------------|
| ActionController::AbstractRequest  | ActionDispatch::Request         |
| ActionController::Request          | ActionDispatch::Request         |
| ActionController::AbstractResponse | ActionDispatch::Response        |
| ActionController::Response         | ActionDispatch::Response        |
| ActionController::Routing          | ActionDispatch::Routing         |
| ActionController::Integration      | ActionDispatch::Integration     |
| ActionController::IntegrationTest  | ActionDispatch::IntegrationTest |

### Changements notables

* `protect_from_forgery` empêche également les balises `<script>` en provenance de domaines différents. Mettez à jour vos tests en utilisant `xhr :get, :foo, format: :js` au lieu de `get :foo, format: :js`. ([Pull Request](https://github.com/rails/rails/pull/13345))

* `#url_for` prend un hash avec des options à l'intérieur d'un tableau. ([Pull Request](https://github.com/rails/rails/pull/9599))

* Ajout de la méthode `session#fetch` qui fonctionne de manière similaire à [Hash#fetch](https://www.ruby-doc.org/core-1.9.3/Hash.html#method-i-fetch), à l'exception que la valeur retournée est toujours enregistrée dans la session. ([Pull Request](https://github.com/rails/rails/pull/12692))

* Séparation complète de Action View de Action Pack. ([Pull Request](https://github.com/rails/rails/pull/11032))

* Journalisation des clés affectées par deep munge. ([Pull Request](https://github.com/rails/rails/pull/13813))

* Nouvelle option de configuration `config.action_dispatch.perform_deep_munge` pour désactiver le "deep munging" des paramètres qui était utilisé pour résoudre la vulnérabilité de sécurité CVE-2013-0155. ([Pull Request](https://github.com/rails/rails/pull/13188))

* Nouvelle option de configuration `config.action_dispatch.cookies_serializer` pour spécifier un sérialiseur pour les jars de cookies signés et chiffrés. (Pull Requests [1](https://github.com/rails/rails/pull/13692), [2](https://github.com/rails/rails/pull/13945) / [Plus de détails](upgrading_ruby_on_rails.html#cookies-serializer))

* Ajout des options `render :plain`, `render :html` et `render :body`. ([Pull Request](https://github.com/rails/rails/pull/14062) / [Plus de détails](upgrading_ruby_on_rails.html#rendering-content-from-string))


Action Mailer
-------------

Veuillez vous référer au [Changelog](https://github.com/rails/rails/blob/4-1-stable/actionmailer/CHANGELOG.md) pour les changements détaillés.

### Changements notables

* Ajout de la fonctionnalité de prévisualisation des mailers basée sur le gem mail_view de 37 Signals. ([Commit](https://github.com/rails/rails/commit/d6dec7fcb6b8fddf8c170182d4fe64ecfc7b2261))

* Instrumentation de la génération des messages Action Mailer. Le temps nécessaire pour générer un message est écrit dans le journal. ([Pull Request](https://github.com/rails/rails/pull/12556))


Active Record
-------------

Veuillez vous référer au [Changelog](https://github.com/rails/rails/blob/4-1-stable/activerecord/CHANGELOG.md) pour les changements détaillés.

### Suppressions

* Suppression de la possibilité de passer `nil` aux méthodes suivantes de `SchemaCache` : `primary_keys`, `tables`, `columns` et `columns_hash`.

* Suppression du filtre de bloc déprécié de `ActiveRecord::Migrator#migrate`.

* Suppression du constructeur de chaîne déprécié de `ActiveRecord::Migrator`.

* Suppression de l'utilisation dépréciée de `scope` sans passer un objet callable.

* Suppression de `transaction_joinable=` déprécié au profit de `begin_transaction` avec l'option `:joinable`.

* Suppression de `decrement_open_transactions` déprécié.

* Suppression de `increment_open_transactions` déprécié.

* Suppression de la méthode `PostgreSQLAdapter#outside_transaction?` dépréciée. Vous pouvez utiliser `#transaction_open?` à la place.

* Suppression de `ActiveRecord::Fixtures.find_table_name` dépréciée au profit de `ActiveRecord::Fixtures.default_fixture_model_name`.

* Suppression de `columns_for_remove` dépréciée de `SchemaStatements`.

* Suppression de `SchemaStatements#distinct` dépréciée.

* Déplacement de `ActiveRecord::TestCase` dépréciée dans la suite de tests de Rails. La classe n'est plus publique et est utilisée uniquement pour les tests internes de Rails.

* Suppression du support de l'option dépréciée `:restrict` pour `:dependent` dans les associations.

* Suppression du support des options `:delete_sql`, `:insert_sql`, `:finder_sql` et `:counter_sql` dépréciées dans les associations.

* Suppression de la méthode `type_cast_code` dépréciée de Column.

* Suppression de la méthode `ActiveRecord::Base#connection` dépréciée. Assurez-vous d'y accéder via la classe.

* Suppression de l'avertissement de dépréciation pour `auto_explain_threshold_in_seconds`.

* Suppression de l'option dépréciée `:distinct` de `Relation#count`.

* Suppression des méthodes dépréciées `partial_updates`, `partial_updates?` et `partial_updates=`.

* Suppression de la méthode dépréciée `scoped`.

* Suppression de la méthode dépréciée `default_scopes?`.

* Suppression des références de jointure implicites qui étaient dépréciées dans la version 4.0.
* Suppression de `activerecord-deprecated_finders` en tant que dépendance.
  Veuillez consulter [le README de la gem](https://github.com/rails/activerecord-deprecated_finders#active-record-deprecated-finders)
  pour plus d'informations.

* Suppression de l'utilisation de `implicit_readonly`. Veuillez utiliser la méthode `readonly`
  explicitement pour marquer les enregistrements comme
  `readonly`. ([Pull Request](https://github.com/rails/rails/pull/10769))

### Dépréciations

* Méthode `quoted_locking_column` dépréciée, qui n'est utilisée nulle part.

* Méthode `ConnectionAdapters::SchemaStatements#distinct` dépréciée,
  car elle n'est plus utilisée en interne. ([Pull Request](https://github.com/rails/rails/pull/10556))

* Tâches `rake db:test:*` dépréciées car la base de données de test est maintenant
  automatiquement gérée. Voir les notes de version de Railties. ([Pull
  Request](https://github.com/rails/rails/pull/13528))

* Dépréciation des méthodes inutilisées `ActiveRecord::Base.symbolized_base_class`
  et `ActiveRecord::Base.symbolized_sti_name` sans
  remplacement. [Commit](https://github.com/rails/rails/commit/97e7ca48c139ea5cce2fa9b4be631946252a1ebd)

### Changements notables

* Les scopes par défaut ne sont plus remplacés par des conditions chaînées.

  Avant cette modification, lorsque vous définissiez un `default_scope` dans un modèle,
  il était remplacé par des conditions chaînées dans le même champ. Maintenant, il
  est fusionné comme n'importe quel autre scope. [Plus de détails](upgrading_ruby_on_rails.html#changes-on-default-scopes).

* Ajout de `ActiveRecord::Base.to_param` pour des URL "jolies" dérivées d'un
  attribut ou d'une méthode d'un modèle. ([Pull Request](https://github.com/rails/rails/pull/12891))

* Ajout de `ActiveRecord::Base.no_touching`, qui permet d'ignorer le toucher sur
  les modèles. ([Pull Request](https://github.com/rails/rails/pull/12772))

* Unification de la conversion de type booléen pour `MysqlAdapter` et `Mysql2Adapter`.
  `type_cast` renverra `1` pour `true` et `0` pour `false`. ([Pull Request](https://github.com/rails/rails/pull/12425))

* `.unscope` supprime maintenant les conditions spécifiées dans
  `default_scope`. ([Commit](https://github.com/rails/rails/commit/94924dc32baf78f13e289172534c2e71c9c8cade))

* Ajout de `ActiveRecord::QueryMethods#rewhere` qui écrira par-dessus une condition `where`
  existante et nommée. ([Commit](https://github.com/rails/rails/commit/f950b2699f97749ef706c6939a84dfc85f0b05f2))

* Extension de `ActiveRecord::Base#cache_key` pour prendre une liste facultative d'attributs de timestamp
  dont le plus élevé sera utilisé. ([Commit](https://github.com/rails/rails/commit/e94e97ca796c0759d8fcb8f946a3bbc60252d329))

* Ajout de `ActiveRecord::Base#enum` pour déclarer des attributs énumérés dont les valeurs
  sont mappées sur des entiers dans la base de données, mais peuvent être interrogées par
  nom. ([Commit](https://github.com/rails/rails/commit/db41eb8a6ea88b854bf5cd11070ea4245e1639c5))

* Conversion des valeurs JSON lors de l'écriture, de sorte que la valeur soit cohérente avec la lecture
  depuis la base de données. ([Pull Request](https://github.com/rails/rails/pull/12643))

* Conversion des valeurs hstore lors de l'écriture, de sorte que la valeur soit cohérente
  avec la lecture depuis la base de données. ([Commit](https://github.com/rails/rails/commit/5ac2341fab689344991b2a4817bd2bc8b3edac9d))

* Rendre `next_migration_number` accessible aux générateurs tiers.
  ([Pull Request](https://github.com/rails/rails/pull/12407))

* L'appel à `update_attributes` lèvera désormais une `ArgumentError` chaque fois qu'il
  reçoit un argument `nil`. Plus précisément, une erreur sera levée si l'argument passé ne répond pas à
  `stringify_keys`. ([Pull Request](https://github.com/rails/rails/pull/9860))

* `CollectionAssociation#first`/`#last` (par exemple `has_many`) utilise une requête avec `LIMIT`
  pour récupérer les résultats plutôt que de charger l'ensemble
  de la collection. ([Pull Request](https://github.com/rails/rails/pull/12137))

* `inspect` sur les classes de modèle Active Record n'initie pas une nouvelle
  connexion. Cela signifie que l'appel à `inspect`, lorsque la base de données est manquante,
  ne lèvera plus d'exception. ([Pull Request](https://github.com/rails/rails/pull/11014))

* Suppression des restrictions de colonne pour `count`, laissant la base de données générer une erreur si le SQL est
  invalide. ([Pull Request](https://github.com/rails/rails/pull/10710))

* Rails détecte maintenant automatiquement les associations inverses. Si vous ne définissez pas l'option `:inverse_of` sur l'association, Active Record devinera
  l'association inverse en fonction de heuristiques. ([Pull Request](https://github.com/rails/rails/pull/10886))

* Gestion des attributs aliasés dans ActiveRecord::Relation. Lors de l'utilisation de clés symboliques,
  ActiveRecord traduira désormais les noms d'attributs aliasés en noms de colonnes réels utilisés dans la base de données. ([Pull Request](https://github.com/rails/rails/pull/7839))

* L'ERB dans les fichiers de fixtures n'est plus évalué dans le contexte de l'objet principal.
  Les méthodes d'aide utilisées par plusieurs fixtures doivent être définies dans des modules
  inclus dans `ActiveRecord::FixtureSet.context_class`. ([Pull Request](https://github.com/rails/rails/pull/13022))

* Ne créez pas ou ne supprimez pas la base de données de test si RAILS_ENV est spécifié
  explicitement. ([Pull Request](https://github.com/rails/rails/pull/13629))

* `Relation` n'a plus de méthodes mutatrices comme `#map!` et `#delete_if`. Convertissez
  en un `Array` en appelant `#to_a` avant d'utiliser ces méthodes. ([Pull Request](https://github.com/rails/rails/pull/13314))
* `find_in_batches`, `find_each`, `Result#each` et `Enumerable#index_by` renvoient maintenant un `Enumerator` qui peut calculer sa taille. ([Pull Request](https://github.com/rails/rails/pull/13938))

* `scope`, `enum` et les associations lèvent maintenant une erreur en cas de conflit de noms "dangereux". ([Pull Request](https://github.com/rails/rails/pull/13450), [Pull Request](https://github.com/rails/rails/pull/13896))

* Les méthodes `second` à `fifth` agissent comme le finder `first`. ([Pull Request](https://github.com/rails/rails/pull/13757))

* `touch` déclenche maintenant les callbacks `after_commit` et `after_rollback`. ([Pull Request](https://github.com/rails/rails/pull/12031))

* Activation des index partiels pour `sqlite >= 3.8.0`. ([Pull Request](https://github.com/rails/rails/pull/13350))

* `change_column_null` est maintenant réversible. ([Commit](https://github.com/rails/rails/commit/724509a9d5322ff502aefa90dd282ba33a281a96))

* Ajout d'un indicateur pour désactiver la génération du schéma après la migration. Par défaut, cela est désactivé dans l'environnement de production pour les nouvelles applications. ([Pull Request](https://github.com/rails/rails/pull/13948))

Active Model
------------

Veuillez vous référer au [journal des modifications](https://github.com/rails/rails/blob/4-1-stable/activemodel/CHANGELOG.md) pour plus de détails sur les changements.

### Dépréciations

* Dépréciation de `Validator#setup`. Cela doit maintenant être fait manuellement dans le constructeur du validateur. ([Commit](https://github.com/rails/rails/commit/7d84c3a2f7ede0e8d04540e9c0640de7378e9b3a))

### Changements notables

* Ajout des nouvelles méthodes d'API `reset_changes` et `changes_applied` à `ActiveModel::Dirty` qui contrôlent l'état des modifications.

* Possibilité de spécifier plusieurs contextes lors de la définition d'une validation. ([Pull Request](https://github.com/rails/rails/pull/13754))

* `attribute_changed?` accepte maintenant un hash pour vérifier si l'attribut a été modifié `:from` et/ou `:to` une valeur donnée. ([Pull Request](https://github.com/rails/rails/pull/13131))


Active Support
--------------

Veuillez vous référer au [journal des modifications](https://github.com/rails/rails/blob/4-1-stable/activesupport/CHANGELOG.md) pour plus de détails sur les changements.

### Suppressions

* Suppression de la dépendance `MultiJSON`. En conséquence, `ActiveSupport::JSON.decode` n'accepte plus un hash d'options pour `MultiJSON`. ([Pull Request](https://github.com/rails/rails/pull/10576) / [Plus de détails](upgrading_ruby_on_rails.html#changes-in-json-handling))

* Suppression de la prise en charge du crochet `encode_json` utilisé pour encoder des objets personnalisés en JSON. Cette fonctionnalité a été extraite dans le gem [activesupport-json_encoder](https://github.com/rails/activesupport-json_encoder). ([Pull Request associé](https://github.com/rails/rails/pull/12183) / [Plus de détails](upgrading_ruby_on_rails.html#changes-in-json-handling))

* Suppression de la classe dépréciée `ActiveSupport::JSON::Variable` sans remplacement.

* Suppression des extensions de base `String#encoding_aware?` (`core_ext/string/encoding`).

* Suppression de la méthode dépréciée `Module#local_constant_names` au profit de `Module#local_constants`.

* Suppression de la méthode dépréciée `DateTime.local_offset` au profit de `DateTime.civil_from_format`.

* Suppression des extensions de base `Logger` (`core_ext/logger.rb`).

* Suppression des méthodes dépréciées `Time#time_with_datetime_fallback`, `Time#utc_time` et `Time#local_time` au profit de `Time#utc` et `Time#local`.

* Suppression de la méthode dépréciée `Hash#diff` sans remplacement.

* Suppression de la méthode dépréciée `Date#to_time_in_current_zone` au profit de `Date#in_time_zone`.

* Suppression de la méthode dépréciée `Proc#bind` sans remplacement.

* Suppression des méthodes dépréciées `Array#uniq_by` et `Array#uniq_by!`, utilisez plutôt les méthodes natives `Array#uniq` et `Array#uniq!`.

* Suppression de la classe dépréciée `ActiveSupport::BasicObject`, utilisez `ActiveSupport::ProxyObject` à la place.

* Suppression de la classe dépréciée `BufferedLogger`, utilisez `ActiveSupport::Logger` à la place.

* Suppression des méthodes dépréciées `assert_present` et `assert_blank`, utilisez `assert object.blank?` et `assert object.present?` à la place.

* Suppression de la méthode dépréciée `#filter` pour les objets de filtre, utilisez la méthode correspondante à la place (par exemple, `#before` pour un filtre avant).

* Suppression de l'inflection irrégulière 'cow' => 'kine' des inflections par défaut. ([Commit](https://github.com/rails/rails/commit/c300dca9963bda78b8f358dbcb59cabcdc5e1dc9))

### Dépréciations

* Dépréciation des méthodes `Numeric#{ago,until,since,from_now}`, il est maintenant attendu que l'utilisateur convertisse explicitement la valeur en `AS::Duration`, par exemple `5.ago` => `5.seconds.ago`. ([Pull Request](https://github.com/rails/rails/pull/12389))

* Dépréciation du chemin d'inclusion `active_support/core_ext/object/to_json`. Utilisez `active_support/core_ext/object/json` à la place. ([Pull Request](https://github.com/rails/rails/pull/12203))

* Dépréciation de `ActiveSupport::JSON::Encoding::CircularReferenceError`. Cette fonctionnalité a été extraite dans le gem [activesupport-json_encoder](https://github.com/rails/activesupport-json_encoder). ([Pull Request](https://github.com/rails/rails/pull/12785) / [Plus de détails](upgrading_ruby_on_rails.html#changes-in-json-handling))

* Dépréciation de l'option `ActiveSupport.encode_big_decimal_as_string`. Cette fonctionnalité a été extraite dans le gem [activesupport-json_encoder](https://github.com/rails/activesupport-json_encoder). ([Pull Request](https://github.com/rails/rails/pull/13060) / [Plus de détails](upgrading_ruby_on_rails.html#changes-in-json-handling))

* Dépréciation de la sérialisation personnalisée de `BigDecimal`. ([Pull Request](https://github.com/rails/rails/pull/13911))

### Changements notables

* L'encodeur JSON d'`ActiveSupport` a été réécrit pour tirer parti du gem JSON plutôt que de faire un encodage personnalisé en pur Ruby. ([Pull Request](https://github.com/rails/rails/pull/12183) / [Plus de détails](upgrading_ruby_on_rails.html#changes-in-json-handling))

* Amélioration de la compatibilité avec le gem JSON. ([Pull Request](https://github.com/rails/rails/pull/12862) / [Plus de détails](upgrading_ruby_on_rails.html#changes-in-json-handling))

* Ajout des méthodes `ActiveSupport::Testing::TimeHelpers#travel` et `#travel_to`. Ces méthodes modifient l'heure actuelle en la remplaçant par l'heure ou la durée donnée en substituant `Time.now` et `Date.today`.
* Ajout de `ActiveSupport::Testing::TimeHelpers#travel_back`. Cette méthode renvoie
  l'heure actuelle à l'état d'origine, en supprimant les stubs ajoutés par `travel`
  et `travel_to`. ([Pull Request](https://github.com/rails/rails/pull/13884))

* Ajout de `Numeric#in_milliseconds`, comme `1.hour.in_milliseconds`, afin de pouvoir les utiliser
  avec des fonctions JavaScript comme
  `getTime()`. ([Commit](https://github.com/rails/rails/commit/423249504a2b468d7a273cbe6accf4f21cb0e643))

* Ajout des méthodes `Date#middle_of_day`, `DateTime#middle_of_day` et `Time#middle_of_day`.
  Ajout également des alias `midday`, `noon`, `at_midday`, `at_noon` et
  `at_middle_of_day`. ([Pull Request](https://github.com/rails/rails/pull/10879))

* Ajout des méthodes `Date#all_week/month/quarter/year` pour générer des plages de dates.
  ([Pull Request](https://github.com/rails/rails/pull/9685))

* Ajout de `Time.zone.yesterday` et
  `Time.zone.tomorrow`. ([Pull Request](https://github.com/rails/rails/pull/12822))

* Ajout de `String#remove(pattern)` comme raccourci pour le motif courant de
  `String#gsub(pattern,'')`. ([Commit](https://github.com/rails/rails/commit/5da23a3f921f0a4a3139495d2779ab0d3bd4cb5f))

* Ajout de `Hash#compact` et `Hash#compact!` pour supprimer les éléments ayant une valeur nulle
  d'un hash. ([Pull Request](https://github.com/rails/rails/pull/13632))

* `blank?` et `present?` renvoient des singletons. ([Commit](https://github.com/rails/rails/commit/126dc47665c65cd129967cbd8a5926dddd0aa514))

* Configuration par défaut de `I18n.enforce_available_locales` à `true`, ce qui signifie
  que `I18n` s'assurera que toutes les locales qui lui sont passées doivent être déclarées dans la
  liste `available_locales`. ([Pull Request](https://github.com/rails/rails/pull/13341))

* Introduction de `Module#concerning` : une façon naturelle et simple de séparer
  les responsabilités au sein d'une classe. ([Commit](https://github.com/rails/rails/commit/1eee0ca6de975b42524105a59e0521d18b38ab81))

* Ajout de `Object#presence_in` pour simplifier l'ajout de valeurs à une liste autorisée.
  ([Commit](https://github.com/rails/rails/commit/4edca106daacc5a159289eae255207d160f22396))


Crédits
-------

Consultez la
[liste complète des contributeurs à Rails](https://contributors.rubyonrails.org/) pour
les nombreuses personnes qui ont passé de nombreuses heures à faire de Rails, le framework stable et robuste
qu'il est aujourd'hui. Bravo à tous.
