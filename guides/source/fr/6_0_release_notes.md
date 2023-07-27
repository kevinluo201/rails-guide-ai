**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: b1c2c8ad5c4bacb2e3b92aa320c4da3d
Ruby on Rails 6.0 Notes de version
===================================

Points forts de Rails 6.0 :

* Action Mailbox
* Action Text
* Tests parallèles
* Tests Action Cable

Ces notes de version ne couvrent que les changements majeurs. Pour en savoir plus sur les corrections de bugs et les changements, veuillez consulter les journaux des modifications ou consulter la [liste des validations](https://github.com/rails/rails/commits/6-0-stable) dans le référentiel principal de Rails sur GitHub.

--------------------------------------------------------------------------------

Mise à niveau vers Rails 6.0
---------------------------

Si vous mettez à niveau une application existante, il est conseillé d'avoir une bonne couverture de tests avant de commencer. Vous devriez également d'abord passer à Rails 5.2 au cas où vous ne l'auriez pas déjà fait et vous assurer que votre application fonctionne toujours comme prévu avant de tenter une mise à jour vers Rails 6.0. Une liste de choses à surveiller lors de la mise à niveau est disponible dans le guide [Mise à niveau de Ruby on Rails](upgrading_ruby_on_rails.html#upgrading-from-rails-5-2-to-rails-6-0).

Fonctionnalités majeures
------------------------

### Action Mailbox

[Pull Request](https://github.com/rails/rails/pull/34786)

[Action Mailbox](https://github.com/rails/rails/tree/6-0-stable/actionmailbox) vous permet de router les e-mails entrants vers des boîtes aux lettres similaires à des contrôleurs. Vous pouvez en savoir plus sur Action Mailbox dans le guide [Action Mailbox Basics](action_mailbox_basics.html).

### Action Text

[Pull Request](https://github.com/rails/rails/pull/34873)

[Action Text](https://github.com/rails/rails/tree/6-0-stable/actiontext) apporte du contenu et de l'édition de texte enrichi à Rails. Il inclut l'éditeur [Trix](https://trix-editor.org) qui gère tout, de la mise en forme aux liens en passant par les citations, les listes, les images intégrées et les galeries. Le contenu texte enrichi généré par l'éditeur Trix est enregistré dans son propre modèle RichText qui est associé à n'importe quel modèle Active Record existant dans l'application. Toutes les images intégrées (ou autres pièces jointes) sont automatiquement stockées à l'aide d'Active Storage et associées au modèle RichText inclus.

Vous pouvez en savoir plus sur Action Text dans le guide [Action Text Overview](action_text_overview.html).

### Tests parallèles

[Pull Request](https://github.com/rails/rails/pull/31900)

[Les tests parallèles](testing.html#parallel-testing) vous permettent de paralléliser votre suite de tests. Bien que la création de processus soit la méthode par défaut, le threading est également pris en charge. L'exécution de tests en parallèle réduit le temps nécessaire pour exécuter l'ensemble de votre suite de tests.

### Tests Action Cable

[Pull Request](https://github.com/rails/rails/pull/33659)

[Les outils de test Action Cable](testing.html#testing-action-cable) vous permettent de tester votre fonctionnalité Action Cable à n'importe quel niveau : connexions, canaux, diffusions.

Railties
--------

Veuillez vous référer au [journal des modifications][railties] pour des changements détaillés.

### Suppressions

*   Supprimer l'aide `after_bundle` obsolète à l'intérieur des modèles de plugins.
    ([Commit](https://github.com/rails/rails/commit/4d51efe24e461a2a3ed562787308484cd48370c7))

*   Supprimer le support obsolète de `config.ru` qui utilise la classe d'application comme argument de `run`.
    ([Commit](https://github.com/rails/rails/commit/553b86fc751c751db504bcbe2d033eb2bb5b6a0b))

*   Supprimer l'argument obsolète `environment` des commandes Rails.
    ([Commit](https://github.com/rails/rails/commit/e20589c9be09c7272d73492d4b0f7b24e5595571))

*   Supprimer la méthode obsolète `capify!` dans les générateurs et les modèles.
    ([Commit](https://github.com/rails/rails/commit/9d39f81d512e0d16a27e2e864ea2dd0e8dc41b17))

*   Supprimer `config.secret_token` obsolète.
    ([Commit](https://github.com/rails/rails/commit/46ac5fe69a20d4539a15929fe48293e1809a26b0))

### Dépréciations

*   Déprécier le passage du nom du serveur Rack en tant qu'argument normal à `rails server`.
    ([Pull Request](https://github.com/rails/rails/pull/32058))

*   Déprécier la prise en charge de l'utilisation de l'environnement `HOST` pour spécifier l'adresse IP du serveur.
    ([Pull Request](https://github.com/rails/rails/pull/32540))

*   Déprécier l'accès aux hachages retournés par `config_for` avec des clés non symboliques.
    ([Pull Request](https://github.com/rails/rails/pull/35198))

### Changements notables

*   Ajouter une option explicite `--using` ou `-u` pour spécifier le serveur pour la commande `rails server`.
    ([Pull Request](https://github.com/rails/rails/pull/32058))

*   Ajouter la possibilité de voir la sortie de `rails routes` au format étendu.
    ([Pull Request](https://github.com/rails/rails/pull/32130))

*   Exécuter la tâche de base de données de seed en utilisant l'adaptateur Active Job en ligne.
    ([Pull Request](https://github.com/rails/rails/pull/34953))

*   Ajouter une commande `rails db:system:change` pour changer la base de données de l'application.
    ([Pull Request](https://github.com/rails/rails/pull/34832))

*   Ajouter la commande `rails test:channels` pour tester uniquement les canaux Action Cable.
    ([Pull Request](https://github.com/rails/rails/pull/34947))
*   Introduire une protection contre les attaques de rebinding DNS.
    ([Demande de tirage](https://github.com/rails/rails/pull/33145))

*   Ajouter la possibilité d'annuler en cas d'échec lors de l'exécution des commandes de génération.
    ([Demande de tirage](https://github.com/rails/rails/pull/34420))

*   Faire de Webpacker le compilateur JavaScript par défaut pour Rails 6.
    ([Demande de tirage](https://github.com/rails/rails/pull/33079))

*   Ajouter la prise en charge de plusieurs bases de données pour la commande `rails db:migrate:status`.
    ([Demande de tirage](https://github.com/rails/rails/pull/34137))

*   Ajouter la possibilité d'utiliser des chemins de migration différents à partir de plusieurs bases de données dans les générateurs.
    ([Demande de tirage](https://github.com/rails/rails/pull/34021))

*   Ajouter la prise en charge des informations d'identification multi-environnement.
    ([Demande de tirage](https://github.com/rails/rails/pull/33521))

*   Définir `null_store` comme cache store par défaut dans l'environnement de test.
    ([Demande de tirage](https://github.com/rails/rails/pull/33773))

Action Cable
------------

Veuillez vous référer au [journal des modifications][action-cable] pour des changements détaillés.

### Suppressions

*   Remplacer `ActionCable.startDebugging()` et `ActionCable.stopDebugging()`
    par `ActionCable.logger.enabled`.
    ([Demande de tirage](https://github.com/rails/rails/pull/34370))

### Dépréciations

*   Il n'y a pas de dépréciations pour Action Cable dans Rails 6.0.

### Changements notables

*   Ajouter la prise en charge de l'option `channel_prefix` pour les adaptateurs de souscription PostgreSQL
    dans `cable.yml`.
    ([Demande de tirage](https://github.com/rails/rails/pull/35276))

*   Autoriser la transmission d'une configuration personnalisée à `ActionCable::Server::Base`.
    ([Demande de tirage](https://github.com/rails/rails/pull/34714))

*   Ajouter les hooks de chargement `:action_cable_connection` et `:action_cable_channel`.
    ([Demande de tirage](https://github.com/rails/rails/pull/35094))

*   Ajouter `Channel::Base#broadcast_to` et `Channel::Base.broadcasting_for`.
    ([Demande de tirage](https://github.com/rails/rails/pull/35021))

*   Fermer une connexion lors de l'appel de `reject_unauthorized_connection` à partir d'une
    `ActionCable::Connection`.
    ([Demande de tirage](https://github.com/rails/rails/pull/34194))

*   Convertir le package JavaScript Action Cable de CoffeeScript à ES2015 et
    publier le code source dans la distribution npm.
    ([Demande de tirage](https://github.com/rails/rails/pull/34370))

*   Déplacer la configuration de l'adaptateur WebSocket et de l'adaptateur de journalisation
    des propriétés de `ActionCable` vers `ActionCable.adapters`.
    ([Demande de tirage](https://github.com/rails/rails/pull/34370))

*   Ajouter une option `id` à l'adaptateur Redis pour distinguer les connexions Redis d'Action Cable.
    ([Demande de tirage](https://github.com/rails/rails/pull/33798))

Action Pack
-----------

Veuillez vous référer au [journal des modifications][action-pack] pour des changements détaillés.

### Suppressions

*   Supprimer l'aide `fragment_cache_key` obsolète au profit de `combined_fragment_cache_key`.
    ([Commit](https://github.com/rails/rails/commit/e70d3df7c9b05c129b0fdcca57f66eca316c5cfc))

*   Supprimer les méthodes obsolètes dans `ActionDispatch::TestResponse` :
    `#success?` au profit de `#successful?`, `#missing?` au profit de `#not_found?`,
    `#error?` au profit de `#server_error?`.
    ([Commit](https://github.com/rails/rails/commit/13ddc92e079e59a0b894e31bf5bb4fdecbd235d1))

### Dépréciations

*   Déprécier `ActionDispatch::Http::ParameterFilter` au profit de `ActiveSupport::ParameterFilter`.
    ([Demande de tirage](https://github.com/rails/rails/pull/34039))

*   Déprécier `force_ssl` au niveau du contrôleur au profit de `config.force_ssl`.
    ([Demande de tirage](https://github.com/rails/rails/pull/32277))

### Changements notables

*   Modifier `ActionDispatch::Response#content_type` pour renvoyer le Content-Type
    de l'en-tête tel quel.
    ([Demande de tirage](https://github.com/rails/rails/pull/36034))

*   Lever une `ArgumentError` si un paramètre de ressource contient un deux-points.
    ([Demande de tirage](https://github.com/rails/rails/pull/35236))

*   Autoriser l'appel de `ActionDispatch::SystemTestCase.driven_by` avec un bloc
    pour définir des capacités spécifiques du navigateur.
    ([Demande de tirage](https://github.com/rails/rails/pull/35081))

*   Ajouter le middleware `ActionDispatch::HostAuthorization` qui protège contre les attaques de rebinding DNS.
    ([Demande de tirage](https://github.com/rails/rails/pull/33145))

*   Autoriser l'utilisation de `parsed_body` dans `ActionController::TestCase`.
    ([Demande de tirage](https://github.com/rails/rails/pull/34717))

*   Lever une `ArgumentError` lorsqu'il existe plusieurs routes racines dans le même contexte
    sans spécifications de nom `as:`.
    ([Demande de tirage](https://github.com/rails/rails/pull/34494))

*   Autoriser l'utilisation de `#rescue_from` pour gérer les erreurs d'analyse des paramètres.
    ([Demande de tirage](https://github.com/rails/rails/pull/34341))

*   Ajouter `ActionController::Parameters#each_value` pour itérer à travers les paramètres.
    ([Demande de tirage](https://github.com/rails/rails/pull/33979))

*   Encoder les noms de fichiers Content-Disposition sur `send_data` et `send_file`.
    ([Demande de tirage](https://github.com/rails/rails/pull/33829))

*   Exposer `ActionController::Parameters#each_key`.
    ([Demande de tirage](https://github.com/rails/rails/pull/33758))

*   Ajouter des métadonnées de but et d'expiration à l'intérieur des cookies signés/chiffrés pour empêcher la copie de la valeur des
    cookies dans d'autres.
    ([Demande de tirage](https://github.com/rails/rails/pull/32937))

*   Lever `ActionController::RespondToMismatchError` pour les invocations `respond_to` conflictuelles.
    ([Demande de tirage](https://github.com/rails/rails/pull/33446))

*   Ajouter une page d'erreur explicite lorsque le modèle d'une demande est manquant pour un format donné.
    ([Demande de tirage](https://github.com/rails/rails/pull/29286))

*   Introduire `ActionDispatch::DebugExceptions.register_interceptor`, une façon de se brancher sur
    DebugExceptions et de traiter l'exception avant son rendu.
    ([Demande de tirage](https://github.com/rails/rails/pull/23868))

*   Ne produire qu'une seule valeur d'en-tête Content-Security-Policy nonce par demande.
    ([Demande de tirage](https://github.com/rails/rails/pull/32602))

*   Ajouter un module spécifiquement pour la configuration par défaut des en-têtes Rails
    qui peut être inclus explicitement dans les contrôleurs.
    ([Demande de tirage](https://github.com/rails/rails/pull/32484))

[action-cable]: https://github.com/rails/rails/blob/master/actioncable/CHANGELOG.md
[action-pack]: https://github.com/rails/rails/blob/master/actionpack/CHANGELOG.md
*   Ajoutez `#dig` à `ActionDispatch::Request::Session`.
    ([Pull Request](https://github.com/rails/rails/pull/32446))

Action View
-----------

Veuillez vous référer au [Changelog][action-view] pour des changements détaillés.

### Suppressions

*   Supprimez l'aide `image_alt` obsolète.
    ([Commit](https://github.com/rails/rails/commit/60c8a03c8d1e45e48fcb1055ba4c49ed3d5ff78f))

*   Supprimez un module `RecordTagHelper` vide dont la fonctionnalité
    a déjà été déplacée vers la gemme `record_tag_helper`.
    ([Commit](https://github.com/rails/rails/commit/5c5ddd69b1e06fb6b2bcbb021e9b8dae17e7cb31))

### Dépréciations

*   Dépréciez `ActionView::Template.finalize_compiled_template_methods` sans
    remplacement.
    ([Pull Request](https://github.com/rails/rails/pull/35036))

*   Dépréciez `config.action_view.finalize_compiled_template_methods` sans
    remplacement.
    ([Pull Request](https://github.com/rails/rails/pull/35036))

*   Dépréciez l'appel de méthodes de modèle privées depuis l'aide de vue `options_from_collection_for_select`.
    ([Pull Request](https://github.com/rails/rails/pull/33547))

### Changements notables

*   Effacez le cache d'Action View uniquement en cas de modifications de fichiers, accélérant
    le mode de développement.
    ([Pull Request](https://github.com/rails/rails/pull/35629))

*   Déplacez tous les packages npm de Rails dans une portée `@rails`.
    ([Pull Request](https://github.com/rails/rails/pull/34905))

*   N'acceptez que les formats des types MIME enregistrés.
    ([Pull Request](https://github.com/rails/rails/pull/35604), [Pull Request](https://github.com/rails/rails/pull/35753))

*   Ajoutez des allocations à la sortie du serveur pour le rendu des modèles et des partiels.
    ([Pull Request](https://github.com/rails/rails/pull/34136))

*   Ajoutez une option `year_format` à la balise `date_select`, permettant de
    personnaliser les noms des années.
    ([Pull Request](https://github.com/rails/rails/pull/32190))

*   Ajoutez une option `nonce: true` pour l'aide `javascript_include_tag` afin de
    prendre en charge la génération automatique de nonce pour une politique de sécurité du contenu.
    ([Pull Request](https://github.com/rails/rails/pull/32607))

*   Ajoutez une configuration `action_view.finalize_compiled_template_methods` pour désactiver ou
    activer les finaliseurs de `ActionView::Template`.
    ([Pull Request](https://github.com/rails/rails/pull/32418))

*   Extrayez l'appel JavaScript `confirm` dans sa propre méthode pouvant être surchargée dans `rails_ujs`.
    ([Pull Request](https://github.com/rails/rails/pull/32404))

*   Ajoutez une option de configuration `action_controller.default_enforce_utf8` pour gérer
    l'encodage UTF-8. Par défaut, cette option est à `false`.
    ([Pull Request](https://github.com/rails/rails/pull/32125))

*   Ajoutez la prise en charge du style de clé I18n pour les clés de locale dans les balises de soumission.
    ([Pull Request](https://github.com/rails/rails/pull/26799))

Action Mailer
-------------

Veuillez vous référer au [Changelog][action-mailer] pour des changements détaillés.

### Suppressions

### Dépréciations

*   Dépréciez `ActionMailer::Base.receive` en faveur d'Action Mailbox.
    ([Commit](https://github.com/rails/rails/commit/e3f832a7433a291a51c5df397dc3dd654c1858cb))

*   Dépréciez `DeliveryJob` et `Parameterized::DeliveryJob` en faveur de
    `MailDeliveryJob`.
    ([Pull Request](https://github.com/rails/rails/pull/34591))

### Changements notables

*   Ajoutez `MailDeliveryJob` pour envoyer des e-mails réguliers et paramétrés.
    ([Pull Request](https://github.com/rails/rails/pull/34591))

*   Permettez aux emplois d'envoi d'e-mails personnalisés de fonctionner avec les assertions de test d'Action Mailer.
    ([Pull Request](https://github.com/rails/rails/pull/34339))

*   Permettez de spécifier un nom de modèle pour les e-mails multipart avec des blocs au lieu de
    n'utiliser que le nom de l'action.
    ([Pull Request](https://github.com/rails/rails/pull/22534))

*   Ajoutez `perform_deliveries` à la charge utile de la notification `deliver.action_mailer`.
    ([Pull Request](https://github.com/rails/rails/pull/33824))

*   Améliorez le message de journalisation lorsque `perform_deliveries` est faux pour indiquer
    que l'envoi des e-mails a été ignoré.
    ([Pull Request](https://github.com/rails/rails/pull/33824))

*   Permettez d'appeler `assert_enqueued_email_with` sans bloc.
    ([Pull Request](https://github.com/rails/rails/pull/33258))

*   Effectuez les emplois d'envoi d'e-mails en file d'attente dans le bloc `assert_emails`.
    ([Pull Request](https://github.com/rails/rails/pull/32231))

*   Permettez à `ActionMailer::Base` de désenregistrer les observateurs et intercepteurs.
    ([Pull Request](https://github.com/rails/rails/pull/32207))

Active Record
-------------

Veuillez vous référer au [Changelog][active-record] pour des changements détaillés.

### Suppressions

*   Supprimez `#set_state` obsolète de l'objet de transaction.
    ([Commit](https://github.com/rails/rails/commit/6c745b0c5152a4437163a67707e02f4464493983))

*   Supprimez `#supports_statement_cache?` obsolète des adaptateurs de base de données.
    ([Commit](https://github.com/rails/rails/commit/5f3ed8784383fb4eb0f9959f31a9c28a991b7553))

*   Supprimez `#insert_fixtures` obsolète des adaptateurs de base de données.
    ([Commit](https://github.com/rails/rails/commit/400ba786e1d154448235f5f90183e48a1043eece))

*   Supprimez `ActiveRecord::ConnectionAdapters::SQLite3Adapter#valid_alter_table_type?` obsolète.
    ([Commit](https://github.com/rails/rails/commit/45b4d5f81f0c0ca72c18d0dea4a3a7b2ecc589bf))

*   Supprimez la prise en charge de la spécification du nom de colonne pour `#cache_key`.
    ([Commit](https://github.com/rails/rails/commit/0bef23e630f62e38f20b5ae1d1d5dbfb087050ea))

*   Supprimez `ActiveRecord::Migrator.migrations_path=`.
    ([Commit](https://github.com/rails/rails/commit/90d7842186591cae364fab3320b524e4d31a7d7d))
*   Supprimer `expand_hash_conditions_for_aggregates` obsolète.
    ([Commit](https://github.com/rails/rails/commit/27b252d6a85e300c7236d034d55ec8e44f57a83e))


### Obsolescence

*   Obsolescence des comparaisons de collation avec sensibilité à la casse pour le validateur d'unicité.
    ([Commit](https://github.com/rails/rails/commit/9def05385f1cfa41924bb93daa187615e88c95b9))

*   Obsolescence de l'utilisation des méthodes de requête de niveau de classe si la portée du récepteur a fuité.
    ([Pull Request](https://github.com/rails/rails/pull/35280))

*   Obsolescence de `config.active_record.sqlite3.represent_boolean_as_integer`.
    ([Commit](https://github.com/rails/rails/commit/f59b08119bc0c01a00561d38279b124abc82561b))

*   Obsolescence du passage de `migrations_paths` à `connection.assume_migrated_upto_version`.
    ([Commit](https://github.com/rails/rails/commit/c1b14aded27e063ead32fa911aa53163d7cfc21a))

*   Obsolescence de `ActiveRecord::Result#to_hash` au profit de `ActiveRecord::Result#to_a`.
    ([Commit](https://github.com/rails/rails/commit/16510d609c601aa7d466809f3073ec3313e08937))

*   Obsolescence des méthodes dans `DatabaseLimits`: `column_name_length`, `table_name_length`,
    `columns_per_table`, `indexes_per_table`, `columns_per_multicolumn_index`,
    `sql_query_length`, et `joins_per_query`.
    ([Commit](https://github.com/rails/rails/commit/e0a1235f7df0fa193c7e299a5adee88db246b44f))

*   Obsolescence de `update_attributes`/`!` au profit de `update`/`!`.
    ([Commit](https://github.com/rails/rails/commit/5645149d3a27054450bd1130ff5715504638a5f5))

### Changements notables

*   Augmentation de la version minimale de la gemme `sqlite3` à 1.4.
    ([Pull Request](https://github.com/rails/rails/pull/35844))

*   Ajout de `rails db:prepare` pour créer une base de données si elle n'existe pas, et exécuter ses migrations.
    ([Pull Request](https://github.com/rails/rails/pull/35768))

*   Ajout du rappel `after_save_commit` comme raccourci pour `after_commit :hook, on: [ :create, :update ]`.
    ([Pull Request](https://github.com/rails/rails/pull/35804))

*   Ajout de `ActiveRecord::Relation#extract_associated` pour extraire les enregistrements associés d'une relation.
    ([Pull Request](https://github.com/rails/rails/pull/35784))

*   Ajout de `ActiveRecord::Relation#annotate` pour ajouter des commentaires SQL aux requêtes d'ActiveRecord::Relation.
    ([Pull Request](https://github.com/rails/rails/pull/35617))

*   Ajout de la prise en charge de l'ajout d'indices d'optimisation sur les bases de données.
    ([Pull Request](https://github.com/rails/rails/pull/35615))

*   Ajout des méthodes `insert_all`/`insert_all!`/`upsert_all` pour effectuer des insertions en bloc.
    ([Pull Request](https://github.com/rails/rails/pull/35631))

*   Ajout de `rails db:seed:replant` qui tronque les tables de chaque base de données
    pour l'environnement actuel et charge les données de départ.
    ([Pull Request](https://github.com/rails/rails/pull/34779))

*   Ajout de la méthode `reselect`, qui est un raccourci pour `unscope(:select).select(fields)`.
    ([Pull Request](https://github.com/rails/rails/pull/33611))

*   Ajout de scopes négatifs pour toutes les valeurs d'énumération.
    ([Pull Request](https://github.com/rails/rails/pull/35381))

*   Ajout de `#destroy_by` et `#delete_by` pour les suppressions conditionnelles.
    ([Pull Request](https://github.com/rails/rails/pull/35316))

*   Ajout de la possibilité de basculer automatiquement entre les connexions de base de données.
    ([Pull Request](https://github.com/rails/rails/pull/35073))

*   Ajout de la possibilité d'empêcher l'écriture dans une base de données pendant la durée d'un bloc.
    ([Pull Request](https://github.com/rails/rails/pull/34505))

*   Ajout d'une API pour basculer les connexions afin de prendre en charge plusieurs bases de données.
    ([Pull Request](https://github.com/rails/rails/pull/34052))

*   Les horodatages avec précision deviennent la valeur par défaut pour les migrations.
    ([Pull Request](https://github.com/rails/rails/pull/34970))

*   Prise en charge de l'option `:size` pour modifier la taille du texte et du blob dans MySQL.
    ([Pull Request](https://github.com/rails/rails/pull/35071))

*   Définir à NULL à la fois la clé étrangère et les colonnes de type étranger
    pour les associations polymorphes avec la stratégie `dependent: :nullify`.
    ([Pull Request](https://github.com/rails/rails/pull/28078))

*   Autoriser une instance autorisée de `ActionController::Parameters` à être passée en argument à `ActiveRecord::Relation#exists?`.
    ([Pull Request](https://github.com/rails/rails/pull/34891))

*   Prise en charge de `#where` pour les plages infinies introduites dans Ruby 2.6.
    ([Pull Request](https://github.com/rails/rails/pull/34906))

*   Faire de `ROW_FORMAT=DYNAMIC` une option de création de table par défaut pour MySQL.
    ([Pull Request](https://github.com/rails/rails/pull/34742))

*   Ajout de l'option `:if_not_exists` à `create_table`.
    ([Pull Request](https://github.com/rails/rails/pull/31382))

*   Ajout de la prise en charge de plusieurs bases de données à `rails db:schema:cache:dump`
    et `rails db:schema:cache:clear`.
    ([Pull Request](https://github.com/rails/rails/pull/34181))

*   Ajout de la prise en charge des configurations de hachage et d'URL dans le hachage de base de données de `ActiveRecord::Base.connected_to`.
    ([Pull Request](https://github.com/rails/rails/pull/34196))

*   Ajout de la prise en charge des expressions par défaut et des index d'expression pour MySQL.
    ([Pull Request](https://github.com/rails/rails/pull/34307))

*   Ajout d'une option `index` pour les helpers de migration `change_table`.
    ([Pull Request](https://github.com/rails/rails/pull/23593))

*   Correction de la réversion de `transaction` pour les migrations. Auparavant, les commandes à l'intérieur d'une `transaction`
    dans une migration révoquée s'exécutaient sans être inversées. Ce changement corrige cela.
    ([Pull Request](https://github.com/rails/rails/pull/31604))
*   Autoriser la configuration de `ActiveRecord::Base.configurations=` avec un hash symbolisé.
    ([Demande de tirage](https://github.com/rails/rails/pull/33968))

*   Corriger le cache de compteur pour ne mettre à jour que si l'enregistrement est réellement enregistré.
    ([Demande de tirage](https://github.com/rails/rails/pull/33913))

*   Ajouter la prise en charge des index d'expression pour l'adaptateur SQLite.
    ([Demande de tirage](https://github.com/rails/rails/pull/33874))

*   Permettre aux sous-classes de redéfinir les rappels autosave pour les enregistrements associés.
    ([Demande de tirage](https://github.com/rails/rails/pull/33378))

*   Augmenter la version minimale de MySQL à 5.5.8.
    ([Demande de tirage](https://github.com/rails/rails/pull/33853))

*   Utiliser l'ensemble de caractères utf8mb4 par défaut dans MySQL.
    ([Demande de tirage](https://github.com/rails/rails/pull/33608))

*   Ajouter la possibilité de filtrer les données sensibles dans `#inspect`.
    ([Demande de tirage](https://github.com/rails/rails/pull/33756), [Demande de tirage](https://github.com/rails/rails/pull/34208))

*   Changer `ActiveRecord::Base.configurations` pour renvoyer un objet au lieu d'un hash.
    ([Demande de tirage](https://github.com/rails/rails/pull/33637))

*   Ajouter une configuration de base de données pour désactiver les verrous consultatifs.
    ([Demande de tirage](https://github.com/rails/rails/pull/33691))

*   Mettre à jour la méthode `alter_table` de l'adaptateur SQLite3 pour restaurer les clés étrangères.
    ([Demande de tirage](https://github.com/rails/rails/pull/33585))

*   Permettre à l'option `:to_table` de `remove_foreign_key` d'être inversible.
    ([Demande de tirage](https://github.com/rails/rails/pull/33530))

*   Corriger la valeur par défaut pour les types de temps MySQL avec une précision spécifiée.
    ([Demande de tirage](https://github.com/rails/rails/pull/33280))

*   Corriger l'option `touch` pour se comporter de manière cohérente avec la méthode `Persistence#touch`.
    ([Demande de tirage](https://github.com/rails/rails/pull/33107))

*   Lever une exception pour les définitions de colonnes en double dans les migrations.
    ([Demande de tirage](https://github.com/rails/rails/pull/33029))

*   Augmenter la version minimale de SQLite à 3.8.
    ([Demande de tirage](https://github.com/rails/rails/pull/32923))

*   Empêcher les enregistrements parent d'être enregistrés avec des enregistrements enfants en double.
    ([Demande de tirage](https://github.com/rails/rails/pull/32952))

*   S'assurer que `Associations::CollectionAssociation#size` et `Associations::CollectionAssociation#empty?`
    utilisent les identifiants d'association chargés s'ils sont présents.
    ([Demande de tirage](https://github.com/rails/rails/pull/32617))

*   Ajouter la prise en charge du préchargement des associations des associations polymorphiques lorsque tous les enregistrements n'ont pas les associations demandées.
    ([Commit](https://github.com/rails/rails/commit/75ef18c67c29b1b51314b6c8a963cee53394080b))

*   Ajouter la méthode `touch_all` à `ActiveRecord::Relation`.
    ([Demande de tirage](https://github.com/rails/rails/pull/31513))

*   Ajouter le prédicat `ActiveRecord::Base.base_class?`.
    ([Demande de tirage](https://github.com/rails/rails/pull/32417))

*   Ajouter des options de préfixe/suffixe personnalisées à `ActiveRecord::Store.store_accessor`.
    ([Demande de tirage](https://github.com/rails/rails/pull/32306))

*   Ajouter `ActiveRecord::Base.create_or_find_by`/`!` pour gérer la condition de course SELECT/INSERT dans
    `ActiveRecord::Base.find_or_create_by`/`!` en s'appuyant sur les contraintes uniques dans la base de données.
    ([Demande de tirage](https://github.com/rails/rails/pull/31989))

*   Ajouter `Relation#pick` comme raccourci pour les plucks à valeur unique.
    ([Demande de tirage](https://github.com/rails/rails/pull/31941))

Stockage actif
--------------

Veuillez vous référer au [journal des modifications][active-storage] pour des changements détaillés.

### Suppressions

### Dépréciations

*   Déprécier `config.active_storage.queue` au profit de `config.active_storage.queues.analysis`
    et `config.active_storage.queues.purge`.
    ([Demande de tirage](https://github.com/rails/rails/pull/34838))

*   Déprécier `ActiveStorage::Downloading` au profit de `ActiveStorage::Blob#open`.
    ([Commit](https://github.com/rails/rails/commit/ee21b7c2eb64def8f00887a9fafbd77b85f464f1))

*   Déprécier l'utilisation de `mini_magick` directement pour générer des variantes d'images au profit de
    `image_processing`.
    ([Commit](https://github.com/rails/rails/commit/697f4a93ad386f9fb7795f0ba68f815f16ebad0f))

*   Déprécier `:combine_options` dans le transformateur ImageProcessing de Active Storage
    sans remplacement.
    ([Commit](https://github.com/rails/rails/commit/697f4a93ad386f9fb7795f0ba68f815f16ebad0f))

### Changements notables

*   Ajouter la prise en charge de la génération de variantes d'images BMP.
    ([Demande de tirage](https://github.com/rails/rails/pull/36051))

*   Ajouter la prise en charge de la génération de variantes d'images TIFF.
    ([Demande de tirage](https://github.com/rails/rails/pull/34824))

*   Ajouter la prise en charge de la génération de variantes d'images JPEG progressives.
    ([Demande de tirage](https://github.com/rails/rails/pull/34455))

*   Ajouter `ActiveStorage.routes_prefix` pour configurer les routes générées par Active Storage.
    ([Demande de tirage](https://github.com/rails/rails/pull/33883))

*   Générer une réponse 404 Not Found sur `ActiveStorage::DiskController#show` lorsque
    le fichier demandé est manquant dans le service de disque.
    ([Demande de tirage](https://github.com/rails/rails/pull/33666))

*   Lever `ActiveStorage::FileNotFoundError` lorsque le fichier demandé est manquant pour
    `ActiveStorage::Blob#download` et `ActiveStorage::Blob#open`.
    ([Demande de tirage](https://github.com/rails/rails/pull/33666))

*   Ajouter une classe générique `ActiveStorage::Error` dont les exceptions de Active Storage héritent.
    ([Commit](https://github.com/rails/rails/commit/18425b837149bc0d50f8d5349e1091a623762d6b))

*   Enregistrer les fichiers téléchargés assignés à un enregistrement dans le stockage lorsque l'enregistrement
    est enregistré au lieu de le faire immédiatement.
    ([Demande de tirage](https://github.com/rails/rails/pull/33303))

*   Remplacer éventuellement les fichiers existants au lieu de les ajouter lors de l'assignation à
    une collection de pièces jointes (comme dans `@user.update!(images: [ … ])`). Utiliser
    `config.active_storage.replace_on_assign_to_many` pour contrôler ce comportement.
    ([Demande de tirage](https://github.com/rails/rails/pull/33303),
     [Demande de tirage](https://github.com/rails/rails/pull/36716))

*   Ajouter la possibilité de réfléchir sur les pièces jointes définies en utilisant le mécanisme de réflexion
    existant d'Active Record.
    ([Demande de tirage](https://github.com/rails/rails/pull/33018))
*   Ajouter `ActiveStorage::Blob#open`, qui télécharge un blob dans un fichier temporaire sur le disque
    et renvoie le fichier temporaire.
    ([Commit](https://github.com/rails/rails/commit/ee21b7c2eb64def8f00887a9fafbd77b85f464f1))

*   Prendre en charge le streaming des téléchargements depuis Google Cloud Storage. Nécessite la version 1.11+
    de la gemme `google-cloud-storage`.
    ([Pull Request](https://github.com/rails/rails/pull/32788))

*   Utiliser la gemme `image_processing` pour les variantes d'Active Storage. Cela remplace l'utilisation
    de `mini_magick` directement.
    ([Pull Request](https://github.com/rails/rails/pull/32471))

Active Model
------------

Veuillez vous référer au [journal des modifications][active-model] pour des détails sur les changements.

### Suppressions

### Dépréciations

### Changements notables

*   Ajouter une option de configuration pour personnaliser le format de `ActiveModel::Errors#full_message`.
    ([Pull Request](https://github.com/rails/rails/pull/32956))

*   Ajouter la prise en charge de la configuration du nom d'attribut pour `has_secure_password`.
    ([Pull Request](https://github.com/rails/rails/pull/26764))

*   Ajouter la méthode `#slice!` à `ActiveModel::Errors`.
    ([Pull Request](https://github.com/rails/rails/pull/34489))

*   Ajouter `ActiveModel::Errors#of_kind?` pour vérifier la présence d'une erreur spécifique.
    ([Pull Request](https://github.com/rails/rails/pull/34866))

*   Corriger la méthode `ActiveModel::Serializers::JSON#as_json` pour les horodatages.
    ([Pull Request](https://github.com/rails/rails/pull/31503))

*   Corriger le validateur de numéricité pour utiliser toujours la valeur avant la conversion de type, sauf pour Active Record.
    ([Pull Request](https://github.com/rails/rails/pull/33654))

*   Corriger la validation d'égalité de numéricité de `BigDecimal` et `Float`
    en les convertissant en `BigDecimal` des deux côtés de la validation.
    ([Pull Request](https://github.com/rails/rails/pull/32852))

*   Corriger la valeur de l'année lors de la conversion d'un hachage de temps multiparamètre.
    ([Pull Request](https://github.com/rails/rails/pull/34990))

*   Convertir les symboles booléens faux sur un attribut booléen en faux.
    ([Pull Request](https://github.com/rails/rails/pull/35794))

*   Renvoyer la date correcte lors de la conversion des paramètres dans `value_from_multiparameter_assignment`
    pour `ActiveModel::Type::Date`.
    ([Pull Request](https://github.com/rails/rails/pull/29651))

*   Revenir à la locale parente avant de revenir à l'espace de noms `:errors` lors de la récupération
    des traductions d'erreurs.
    ([Pull Request](https://github.com/rails/rails/pull/35424))

Active Support
--------------

Veuillez vous référer au [journal des modifications][active-support] pour des détails sur les changements.

### Suppressions

*   Supprimer la méthode dépréciée `#acronym_regex` de `Inflections`.
    ([Commit](https://github.com/rails/rails/commit/0ce67d3cd6d1b7b9576b07fecae3dd5b422a5689))

*   Supprimer la méthode dépréciée `Module#reachable?`.
    ([Commit](https://github.com/rails/rails/commit/6eb1d56a333fd2015610d31793ed6281acd66551))

*   Supprimer `` Kernel#` `` sans remplacement.
    ([Pull Request](https://github.com/rails/rails/pull/31253))

### Dépréciations

*   Déprécier l'utilisation d'arguments entiers négatifs pour `String#first` et
    `String#last`.
    ([Pull Request](https://github.com/rails/rails/pull/33058))

*   Déprécier `ActiveSupport::Multibyte::Unicode#downcase/upcase/swapcase`
    au profit de `String#downcase/upcase/swapcase`.
    ([Pull Request](https://github.com/rails/rails/pull/34123))

*   Déprécier `ActiveSupport::Multibyte::Unicode#normalize`
    et `ActiveSupport::Multibyte::Chars#normalize` au profit de
    `String#unicode_normalize`.
    ([Pull Request](https://github.com/rails/rails/pull/34202))

*   Déprécier `ActiveSupport::Multibyte::Chars.consumes?` au profit de
    `String#is_utf8?`.
    ([Pull Request](https://github.com/rails/rails/pull/34215))

*   Déprécier `ActiveSupport::Multibyte::Unicode#pack_graphemes(array)`
    et `ActiveSupport::Multibyte::Unicode#unpack_graphemes(string)`
    au profit de `array.flatten.pack("U*")` et `string.scan(/\X/).map(&:codepoints)`,
    respectivement.
    ([Pull Request](https://github.com/rails/rails/pull/34254))

### Changements notables

*   Ajouter la prise en charge des tests parallèles.
    ([Pull Request](https://github.com/rails/rails/pull/31900))

*   S'assurer que `String#strip_heredoc` préserve la congelation des chaînes.
    ([Pull Request](https://github.com/rails/rails/pull/32037))

*   Ajouter `String#truncate_bytes` pour tronquer une chaîne à une taille maximale en octets
    sans casser les caractères multioctets ou les groupes de graphèmes.
    ([Pull Request](https://github.com/rails/rails/pull/27319))

*   Ajouter l'option `private` à la méthode `delegate` pour déléguer à
    des méthodes privées. Cette option accepte `true/false` comme valeur.
    ([Pull Request](https://github.com/rails/rails/pull/31944))

*   Ajouter la prise en charge des traductions via I18n pour `ActiveSupport::Inflector#ordinal`
    et `ActiveSupport::Inflector#ordinalize`.
    ([Pull Request](https://github.com/rails/rails/pull/32168))

*   Ajouter les méthodes `before?` et `after?` à `Date`, `DateTime`,
    `Time` et `TimeWithZone`.
    ([Pull Request](https://github.com/rails/rails/pull/32185))

*   Corriger le bogue où `URI.unescape` échouait avec un mélange de caractères Unicode/échappés.
    ([Pull Request](https://github.com/rails/rails/pull/32183))

*   Corriger le bogue où `ActiveSupport::Cache` augmentait considérablement la taille de stockage
    lorsque la compression était activée.
    ([Pull Request](https://github.com/rails/rails/pull/32539))

*   Redis cache store : `delete_matched` ne bloque plus le serveur Redis.
    ([Pull Request](https://github.com/rails/rails/pull/32614))

*   Corriger le bogue où `ActiveSupport::TimeZone.all` échouait lorsque les données tzinfo pour
    n'importe quel fuseau horaire défini dans `ActiveSupport::TimeZone::MAPPING` étaient manquantes.
    ([Pull Request](https://github.com/rails/rails/pull/32613))

*   Ajouter `Enumerable#index_with` qui permet de créer un hash à partir d'un énumérable
    avec la valeur d'un bloc passé ou un argument par défaut.
    ([Pull Request](https://github.com/rails/rails/pull/32523))

*   Permettre aux méthodes `Range#===` et `Range#cover?` de fonctionner avec un argument de type `Range`.
    ([Pull Request](https://github.com/rails/rails/pull/32938))
*   Ajouter la prise en charge de l'expiration des clés dans les opérations `increment/decrement` de RedisCacheStore.
    ([Demande de tirage](https://github.com/rails/rails/pull/33254))

*   Ajouter les fonctionnalités de temps CPU, de temps d'inactivité et d'allocations aux événements du souscripteur de journalisation.
    ([Demande de tirage](https://github.com/rails/rails/pull/33449))

*   Ajouter la prise en charge de l'objet d'événement au système de notification Active Support.
    ([Demande de tirage](https://github.com/rails/rails/pull/33451))

*   Ajouter la prise en charge de la non mise en cache des entrées `nil` en introduisant la nouvelle option `skip_nil` pour `ActiveSupport::Cache#fetch`.
    ([Demande de tirage](https://github.com/rails/rails/pull/25437))

*   Ajouter la méthode `Array#extract!` qui supprime et renvoie les éléments pour lesquels le bloc renvoie une valeur vraie.
    ([Demande de tirage](https://github.com/rails/rails/pull/33137))

*   Conserver une chaîne HTML-safe après découpage.
    ([Demande de tirage](https://github.com/rails/rails/pull/33808))

*   Ajouter la prise en charge du suivi des autoloads constants via la journalisation.
    ([Commit](https://github.com/rails/rails/commit/c03bba4f1f03bad7dc034af555b7f2b329cf76f5))

*   Définir `unfreeze_time` comme un alias de `travel_back`.
    ([Demande de tirage](https://github.com/rails/rails/pull/33813))

*   Changer `ActiveSupport::TaggedLogging.new` pour renvoyer une nouvelle instance de journal au lieu de modifier celle reçue en argument.
    ([Demande de tirage](https://github.com/rails/rails/pull/27792))

*   Traiter les méthodes `#delete_prefix`, `#delete_suffix` et `#unicode_normalize` comme des méthodes non HTML-safe.
    ([Demande de tirage](https://github.com/rails/rails/pull/33990))

*   Corriger le bogue où `#without` pour `ActiveSupport::HashWithIndifferentAccess` échouait avec des arguments de type symbole.
    ([Demande de tirage](https://github.com/rails/rails/pull/34012))

*   Renommer `Module#parent`, `Module#parents` et `Module#parent_name` en `module_parent`, `module_parents` et `module_parent_name`.
    ([Demande de tirage](https://github.com/rails/rails/pull/34051))

*   Ajouter `ActiveSupport::ParameterFilter`.
    ([Demande de tirage](https://github.com/rails/rails/pull/34039))

*   Corriger le problème où la durée était arrondie à la seconde entière lorsque un nombre à virgule flottante était ajouté à la durée.
    ([Demande de tirage](https://github.com/rails/rails/pull/34135))

*   Faire de `#to_options` un alias de `#symbolize_keys` dans `ActiveSupport::HashWithIndifferentAccess`.
    ([Demande de tirage](https://github.com/rails/rails/pull/34360))

*   Ne plus lever d'exception si le même bloc est inclus plusieurs fois pour un Concern.
    ([Demande de tirage](https://github.com/rails/rails/pull/34553))

*   Préserver l'ordre des clés transmises à `ActiveSupport::CacheStore#fetch_multi`.
    ([Demande de tirage](https://github.com/rails/rails/pull/34700))

*   Corriger `String#safe_constantize` pour ne pas générer une `LoadError` pour les références de constantes incorrectement cadrées.
    ([Demande de tirage](https://github.com/rails/rails/pull/34892))

*   Ajouter `Hash#deep_transform_values` et `Hash#deep_transform_values!`.
    ([Commit](https://github.com/rails/rails/commit/b8dc06b8fdc16874160f61dcf58743fcc10e57db))

*   Ajouter `ActiveSupport::HashWithIndifferentAccess#assoc`.
    ([Demande de tirage](https://github.com/rails/rails/pull/35080))

*   Ajouter le rappel `before_reset` à `CurrentAttributes` et définir `after_reset` comme un alias de `resets` pour la symétrie.
    ([Demande de tirage](https://github.com/rails/rails/pull/35063))

*   Réviser `ActiveSupport::Notifications.unsubscribe` pour gérer correctement les abonnés avec des expressions régulières ou plusieurs motifs.
    ([Demande de tirage](https://github.com/rails/rails/pull/32861))

*   Ajouter un nouveau mécanisme de chargement automatique utilisant Zeitwerk.
    ([Commit](https://github.com/rails/rails/commit/e53430fa9af239e21e11548499d814f540d421e5))

*   Ajouter `Array#including` et `Enumerable#including` pour agrandir facilement une collection.
    ([Commit](https://github.com/rails/rails/commit/bfaa3091c3c32b5980a614ef0f7b39cbf83f6db3))

*   Renommer `Array#without` et `Enumerable#without` en `Array#excluding` et `Enumerable#excluding`. Les anciens noms de méthode sont conservés en tant qu'alias.
    ([Commit](https://github.com/rails/rails/commit/bfaa3091c3c32b5980a614ef0f7b39cbf83f6db3))

*   Ajouter la prise en charge de la fourniture de la `locale` à `transliterate` et `parameterize`.
    ([Demande de tirage](https://github.com/rails/rails/pull/35571))

*   Corriger `Time#advance` pour fonctionner avec des dates antérieures à 1001-03-07.
    ([Demande de tirage](https://github.com/rails/rails/pull/35659))

*   Mettre à jour `ActiveSupport::Notifications::Instrumenter#instrument` pour permettre de ne pas passer de bloc.
    ([Demande de tirage](https://github.com/rails/rails/pull/35705))

*   Utiliser des références faibles dans le suivi des descendants pour permettre aux sous-classes anonymes d'être collectées par le garbage collector.
    ([Demande de tirage](https://github.com/rails/rails/pull/31442))

*   Appeler les méthodes de test avec la méthode `with_info_handler` pour permettre au plugin minitest-hooks de fonctionner.
    ([Commit](https://github.com/rails/rails/commit/758ba117a008b6ea2d3b92c53b6a7a8d7ccbca69))

*   Préserver le statut `html_safe?` sur `ActiveSupport::SafeBuffer#*`.
    ([Demande de tirage](https://github.com/rails/rails/pull/36012))

Active Job
----------

Veuillez vous référer au [journal des modifications][active-job] pour des changements détaillés.

### Suppressions

*   Supprimer la prise en charge de la gemme Qu.
    ([Demande de tirage](https://github.com/rails/rails/pull/32300))

### Dépréciations

### Changements notables

*   Ajouter la prise en charge de sérialiseurs personnalisés pour les arguments de Active Job.
    ([Demande de tirage](https://github.com/rails/rails/pull/30941))

*   Ajouter la prise en charge de l'exécution des tâches Active dans le fuseau horaire dans lequel elles ont été mises en file d'attente.
    ([Demande de tirage](https://github.com/rails/rails/pull/32085))

*   Autoriser le passage de plusieurs exceptions à `retry_on`/`discard_on`.
    ([Commit](https://github.com/rails/rails/commit/3110caecbebdad7300daaf26bfdff39efda99e25))

*   Autoriser l'appel de `assert_enqueued_with` et `assert_enqueued_email_with` sans bloc.
    ([Demande de tirage](https://github.com/rails/rails/pull/33258))

*   Envelopper les notifications pour `enqueue` et `enqueue_at` dans le rappel `around_enqueue` au lieu du rappel `after_enqueue`.
    ([Demande de tirage](https://github.com/rails/rails/pull/33171))

*   Autoriser l'appel de `perform_enqueued_jobs` sans bloc.
    ([Demande de tirage](https://github.com/rails/rails/pull/33626))

*   Autoriser l'appel de `assert_performed_with` sans bloc.
    ([Demande de tirage](https://github.com/rails/rails/pull/33635))

[active-job]: https://github.com/rails/rails/blob/master/activerecord/CHANGELOG.md
*   Ajouter l'option `:queue` aux assertions et aux helpers de job.
    ([Pull Request](https://github.com/rails/rails/pull/33635))

*   Ajouter des hooks à Active Job pour les tentatives de réessai et les suppressions.
    ([Pull Request](https://github.com/rails/rails/pull/33751))

*   Ajouter une façon de tester un sous-ensemble d'arguments lors de l'exécution des jobs.
    ([Pull Request](https://github.com/rails/rails/pull/33995))

*   Inclure les arguments désérialisés dans les jobs retournés par les helpers de test d'Active Job.
    ([Pull Request](https://github.com/rails/rails/pull/34204))

*   Permettre aux helpers d'assertion d'Active Job d'accepter un Proc pour le mot-clé `only`.
    ([Pull Request](https://github.com/rails/rails/pull/34339))

*   Supprimer les microsecondes et les nanosecondes des arguments du job dans les helpers d'assertion.
    ([Pull Request](https://github.com/rails/rails/pull/35713))

Ruby on Rails Guides
--------------------

Veuillez vous référer au [Changelog][guides] pour les changements détaillés.

### Changements notables

*   Ajouter le guide sur les bases de données multiples avec Active Record.
    ([Pull Request](https://github.com/rails/rails/pull/36389))

*   Ajouter une section sur le dépannage du chargement automatique des constantes.
    ([Commit](https://github.com/rails/rails/commit/c03bba4f1f03bad7dc034af555b7f2b329cf76f5))

*   Ajouter le guide sur les bases de l'Action Mailbox.
    ([Pull Request](https://github.com/rails/rails/pull/34812))

*   Ajouter le guide sur l'aperçu de l'Action Text.
    ([Pull Request](https://github.com/rails/rails/pull/34878))

Crédits
-------

Consultez la [liste complète des contributeurs à Rails](https://contributors.rubyonrails.org/)
pour toutes les personnes qui ont passé de nombreuses heures à faire de Rails le framework stable et robuste qu'il est. Félicitations à tous.
[active-storage]: https://github.com/rails/rails/blob/6-0-stable/activestorage/CHANGELOG.md
[active-support]: https://github.com/rails/rails/blob/6-0-stable/activesupport/CHANGELOG.md
