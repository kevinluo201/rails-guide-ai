**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: b1c2c8ad5c4bacb2e3b92aa320c4da3d
Ruby on Rails 6.0 Notes de version
===================================

Points forts de Rails 6.0 :

* Action Mailbox
* Action Text
* Tests parallèles
* Tests Action Cable

Ces notes de version ne couvrent que les changements majeurs. Pour en savoir plus sur les corrections de bugs et les changements divers, veuillez consulter les journaux des modifications ou consulter la [liste des validations](https://github.com/rails/rails/commits/6-0-stable) dans le référentiel principal de Rails sur GitHub.

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

[Action Text](https://github.com/rails/rails/tree/6-0-stable/actiontext) apporte un contenu et une édition de texte enrichis à Rails. Il inclut l'éditeur [Trix](https://trix-editor.org) qui gère tout, de la mise en forme aux liens en passant par les citations, les listes, les images intégrées et les galeries. Le contenu texte enrichi généré par l'éditeur Trix est enregistré dans son propre modèle RichText qui est associé à n'importe quel modèle Active Record existant dans l'application. Toutes les images intégrées (ou autres pièces jointes) sont automatiquement stockées à l'aide d'Active Storage et associées au modèle RichText inclus.

Vous pouvez en savoir plus sur Action Text dans le guide [Action Text Overview](action_text_overview.html).

### Tests parallèles

[Pull Request](https://github.com/rails/rails/pull/31900)

[Tests parallèles](testing.html#parallel-testing) vous permet de paralléliser votre suite de tests. Bien que la création de processus soit la méthode par défaut, le threading est également pris en charge. L'exécution de tests en parallèle réduit le temps nécessaire pour exécuter l'ensemble de votre suite de tests.

### Tests Action Cable

[Pull Request](https://github.com/rails/rails/pull/33659)

Les outils de test [Action Cable](testing.html#testing-action-cable) vous permettent de tester votre fonctionnalité Action Cable à n'importe quel niveau : connexions, canaux, diffusions.

Railties
--------

Veuillez consulter le [journal des modifications][railties] pour plus de détails sur les changements.

### Suppressions

*   Suppression de l'aide `after_bundle` obsolète à l'intérieur des modèles de plugins.
    ([Commit](https://github.com/rails/rails/commit/4d51efe24e461a2a3ed562787308484cd48370c7))

*   Suppression du support obsolète de `config.ru` qui utilise la classe d'application comme argument de `run`.
    ([Commit](https://github.com/rails/rails/commit/553b86fc751c751db504bcbe2d033eb2bb5b6a0b))

*   Suppression de l'argument obsolète `environment` des commandes Rails.
    ([Commit](https://github.com/rails/rails/commit/e20589c9be09c7272d73492d4b0f7b24e5595571))

*   Suppression de la méthode obsolète `capify!` dans les générateurs et les modèles.
    ([Commit](https://github.com/rails/rails/commit/9d39f81d512e0d16a27e2e864ea2dd0e8dc41b17))

*   Suppression de `config.secret_token` obsolète.
    ([Commit](https://github.com/rails/rails/commit/46ac5fe69a20d4539a15929fe48293e1809a26b0))

### Dépréciations

*   Dépréciation du passage du nom du serveur Rack en tant qu'argument normal à `rails server`.
    ([Pull Request](https://github.com/rails/rails/pull/32058))

*   Dépréciation de la prise en charge de l'utilisation de l'environnement `HOST` pour spécifier l'adresse IP du serveur.
    ([Pull Request](https://github.com/rails/rails/pull/32540))

*   Dépréciation de l'accès aux hachages retournés par `config_for` avec des clés non symboliques.
    ([Pull Request](https://github.com/rails/rails/pull/35198))

### Changements notables

*   Ajout d'une option explicite `--using` ou `-u` pour spécifier le serveur pour la commande `rails server`.
    ([Pull Request](https://github.com/rails/rails/pull/32058))

*   Ajout de la possibilité de voir la sortie de `rails routes` au format étendu.
    ([Pull Request](https://github.com/rails/rails/pull/32130))

*   Exécution de la tâche de base de données de chargement des données de base à l'aide de l'adaptateur Active Job en ligne.
    ([Pull Request](https://github.com/rails/rails/pull/34953))

*   Ajout d'une commande `rails db:system:change` pour changer la base de données de l'application.
    ([Pull Request](https://github.com/rails/rails/pull/34832))

*   Ajout de la commande `rails test:channels` pour tester uniquement les canaux Action Cable.
    ([Pull Request](https://github.com/rails/rails/pull/34947))

*   Introduction d'une protection contre les attaques de rebinding DNS.
    ([Pull Request](https://github.com/rails/rails/pull/33145))

*   Ajout de la possibilité d'annuler en cas d'échec lors de l'exécution des commandes de génération.
    ([Pull Request](https://github.com/rails/rails/pull/34420))

*   Faire de Webpacker le compilateur JavaScript par défaut pour Rails 6.
    ([Pull Request](https://github.com/rails/rails/pull/33079))

*   Ajout de la prise en charge de plusieurs bases de données pour la commande `rails db:migrate:status`.
    ([Pull Request](https://github.com/rails/rails/pull/34137))

*   Ajout de la possibilité d'utiliser des chemins de migration différents à partir de plusieurs bases de données dans les générateurs.
    ([Pull Request](https://github.com/rails/rails/pull/34021))

*   Ajout de la prise en charge des informations d'identification multi-environnements.
    ([Pull Request](https://github.com/rails/rails/pull/33521))

*   Définir `null_store` comme cache store par défaut en environnement de test.
    ([Pull Request](https://github.com/rails/rails/pull/33773))

Action Cable
------------

Veuillez consulter le [journal des modifications][action-cable] pour plus de détails sur les changements.

### Suppressions

*   Remplacer `ActionCable.startDebugging()` et `ActionCable.stopDebugging()` par `ActionCable.logger.enabled`.
    ([Pull Request](https://github.com/rails/rails/pull/34370))

### Dépréciations

*   Il n'y a pas de dépréciations pour Action Cable dans Rails 6.0.

### Changements notables

*   Ajout de la prise en charge de l'option `channel_prefix` pour les adaptateurs de souscription PostgreSQL dans `cable.yml`.
    ([Pull Request](https://github.com/rails/rails/pull/35276))

*   Possibilité de passer une configuration personnalisée à `ActionCable::Server::Base`.
    ([Pull Request](https://github.com/rails/rails/pull/34714))

*   Ajout des hooks de chargement `:action_cable_connection` et `:action_cable_channel`.
    ([Pull Request](https://github.com/rails/rails/pull/35094))

*   Ajout de `Channel::Base#broadcast_to` et `Channel::Base.broadcasting_for`.
    ([Pull Request](https://github.com/rails/rails/pull/35021))

*   Fermeture d'une connexion lors de l'appel de `reject_unauthorized_connection` à partir d'une `ActionCable::Connection`.
    ([Pull Request](https://github.com/rails/rails/pull/34194))

*   Conversion du package JavaScript Action Cable de CoffeeScript à ES2015 et publication du code source dans la distribution npm.
    ([Pull Request](https://github.com/rails/rails/pull/34370))

*   Déplacement de la configuration de l'adaptateur WebSocket et de l'adaptateur de journalisation des propriétés de `ActionCable` vers `ActionCable.adapters`.
    ([Pull Request](https
*   Ajoutez une option `id` à l'adaptateur Redis pour distinguer les connexions Redis d'Action Cable.
    ([Pull Request](https://github.com/rails/rails/pull/33798))

Action Pack
-----------

Veuillez vous référer au [journal des modifications][action-pack] pour des détails sur les changements.

### Suppressions

*   Supprimez l'aide `fragment_cache_key` obsolète au profit de `combined_fragment_cache_key`.
    ([Commit](https://github.com/rails/rails/commit/e70d3df7c9b05c129b0fdcca57f66eca316c5cfc))

*   Supprimez les méthodes obsolètes dans `ActionDispatch::TestResponse`:
    `#success?` au profit de `#successful?`, `#missing?` au profit de `#not_found?`,
    `#error?` au profit de `#server_error?`.
    ([Commit](https://github.com/rails/rails/commit/13ddc92e079e59a0b894e31bf5bb4fdecbd235d1))

### Dépréciations

*   Dépréciez `ActionDispatch::Http::ParameterFilter` au profit de `ActiveSupport::ParameterFilter`.
    ([Pull Request](https://github.com/rails/rails/pull/34039))

*   Dépréciez `force_ssl` au niveau du contrôleur au profit de `config.force_ssl`.
    ([Pull Request](https://github.com/rails/rails/pull/32277))

### Changements notables

*   Modifiez `ActionDispatch::Response#content_type` pour renvoyer le Content-Type
    en-tête tel quel.
    ([Pull Request](https://github.com/rails/rails/pull/36034))

*   Lancez une `ArgumentError` si un paramètre de ressource contient un deux-points.
    ([Pull Request](https://github.com/rails/rails/pull/35236))

*   Autorisez l'appel de `ActionDispatch::SystemTestCase.driven_by` avec un bloc
    pour définir des capacités de navigateur spécifiques.
    ([Pull Request](https://github.com/rails/rails/pull/35081))

*   Ajoutez le middleware `ActionDispatch::HostAuthorization` qui protège contre les attaques de rebinding DNS.
    ([Pull Request](https://github.com/rails/rails/pull/33145))

*   Autorisez l'utilisation de `parsed_body` dans `ActionController::TestCase`.
    ([Pull Request](https://github.com/rails/rails/pull/34717))

*   Lancez une `ArgumentError` lorsque plusieurs routes racines existent dans le même contexte
    sans spécifications de nom `as:`.
    ([Pull Request](https://github.com/rails/rails/pull/34494))

*   Autorisez l'utilisation de `#rescue_from` pour gérer les erreurs d'analyse des paramètres.
    ([Pull Request](https://github.com/rails/rails/pull/34341))

*   Ajoutez `ActionController::Parameters#each_value` pour itérer à travers les paramètres.
    ([Pull Request](https://github.com/rails/rails/pull/33979))

*   Encodez les noms de fichiers Content-Disposition sur `send_data` et `send_file`.
    ([Pull Request](https://github.com/rails/rails/pull/33829))

*   Exposez `ActionController::Parameters#each_key`.
    ([Pull Request](https://github.com/rails/rails/pull/33758))

*   Ajoutez des métadonnées de but et d'expiration à l'intérieur des cookies signés/chiffrés pour empêcher la copie de la valeur des
    cookies les uns dans les autres.
    ([Pull Request](https://github.com/rails/rails/pull/32937))

*   Lancez `ActionController::RespondToMismatchError` pour les invocations `respond_to` conflictuelles.
    ([Pull Request](https://github.com/rails/rails/pull/33446))

*   Ajoutez une page d'erreur explicite lorsque le modèle d'un format de requête est manquant.
    ([Pull Request](https://github.com/rails/rails/pull/29286))

*   Introduisez `ActionDispatch::DebugExceptions.register_interceptor`, une façon de se brancher sur
    DebugExceptions et de traiter l'exception avant qu'elle ne soit rendue.
    ([Pull Request](https://github.com/rails/rails/pull/23868))

*   Ne produisez qu'une seule valeur d'en-tête Content-Security-Policy nonce par requête.
    ([Pull Request](https://github.com/rails/rails/pull/32602))

*   Ajoutez un module spécifiquement pour la configuration par défaut des en-têtes Rails
    qui peut être inclus explicitement dans les contrôleurs.
    ([Pull Request](https://github.com/rails/rails/pull/32484))

*   Ajoutez `#dig` à `ActionDispatch::Request::Session`.
    ([Pull Request](https://github.com/rails/rails/pull/32446))

Action View
-----------

Veuillez vous référer au [journal des modifications][action-view] pour des détails sur les changements.

### Suppressions

*   Supprimez l'aide `image_alt` obsolète.
    ([Commit](https://github.com/rails/rails/commit/60c8a03c8d1e45e48fcb1055ba4c49ed3d5ff78f))

*   Supprimez un module vide `RecordTagHelper` dont la fonctionnalité
    a déjà été déplacée vers la gem `record_tag_helper`.
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

*   Effacez le cache d'Action View uniquement en développement lors de modifications de fichiers, accélérant
    le mode développement.
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

*   Extrayez l'appel JavaScript `confirm` dans sa propre méthode remplaçable dans `rails_ujs`.
    ([Pull Request](https://github.com/rails/rails/pull/32404))

*   Ajoutez une option de configuration `action_controller.default_enforce_utf8
*   Supprimer la méthode dépréciée `#supports_statement_cache?` des adaptateurs de base de données.
    ([Commit](https://github.com/rails/rails/commit/5f3ed8784383fb4eb0f9959f31a9c28a991b7553))

*   Supprimer la méthode dépréciée `#insert_fixtures` des adaptateurs de base de données.
    ([Commit](https://github.com/rails/rails/commit/400ba786e1d154448235f5f90183e48a1043eece))

*   Supprimer la méthode dépréciée `ActiveRecord::ConnectionAdapters::SQLite3Adapter#valid_alter_table_type?`.
    ([Commit](https://github.com/rails/rails/commit/45b4d5f81f0c0ca72c18d0dea4a3a7b2ecc589bf))

*   Supprimer la prise en charge de la spécification du nom de colonne pour `#sum` lorsqu'un bloc est passé.
    ([Commit](https://github.com/rails/rails/commit/91ddb30083430622188d76eb9f29b78131df67f9))

*   Supprimer la prise en charge de la spécification du nom de colonne pour `#count` lorsqu'un bloc est passé.
    ([Commit](https://github.com/rails/rails/commit/67356f2034ab41305af7218f7c8b2fee2d614129))

*   Supprimer la prise en charge de la délégation des méthodes manquantes dans une relation à Arel.
    ([Commit](https://github.com/rails/rails/commit/d97980a16d76ad190042b4d8578109714e9c53d0))

*   Supprimer la prise en charge de la délégation des méthodes manquantes dans une relation aux méthodes privées de la classe.
    ([Commit](https://github.com/rails/rails/commit/a7becf147afc85c354e5cfa519911a948d25fc4d))

*   Supprimer la prise en charge de la spécification d'un nom de timestamp pour `#cache_key`.
    ([Commit](https://github.com/rails/rails/commit/0bef23e630f62e38f20b5ae1d1d5dbfb087050ea))

*   Supprimer la méthode dépréciée `ActiveRecord::Migrator.migrations_path=`.
    ([Commit](https://github.com/rails/rails/commit/90d7842186591cae364fab3320b524e4d31a7d7d))

*   Supprimer la méthode dépréciée `expand_hash_conditions_for_aggregates`.
    ([Commit](https://github.com/rails/rails/commit/27b252d6a85e300c7236d034d55ec8e44f57a83e))


### Dépréciations

*   Déprécier les comparaisons de collation avec sensibilité à la casse pour le validateur d'unicité.
    ([Commit](https://github.com/rails/rails/commit/9def05385f1cfa41924bb93daa187615e88c95b9))

*   Déprécier l'utilisation des méthodes de requête au niveau de la classe si la portée du récepteur a fuité.
    ([Pull Request](https://github.com/rails/rails/pull/35280))

*   Déprécier `config.active_record.sqlite3.represent_boolean_as_integer`.
    ([Commit](https://github.com/rails/rails/commit/f59b08119bc0c01a00561d38279b124abc82561b))

*   Déprécier la spécification de `migrations_paths` pour `connection.assume_migrated_upto_version`.
    ([Commit](https://github.com/rails/rails/commit/c1b14aded27e063ead32fa911aa53163d7cfc21a))

*   Déprécier `ActiveRecord::Result#to_hash` au profit de `ActiveRecord::Result#to_a`.
    ([Commit](https://github.com/rails/rails/commit/16510d609c601aa7d466809f3073ec3313e08937))

*   Déprécier les méthodes dans `DatabaseLimits`: `column_name_length`, `table_name_length`,
    `columns_per_table`, `indexes_per_table`, `columns_per_multicolumn_index`,
    `sql_query_length` et `joins_per_query`.
    ([Commit](https://github.com/rails/rails/commit/e0a1235f7df0fa193c7e299a5adee88db246b44f))

*   Déprécier `update_attributes`/`!` au profit de `update`/`!`.
    ([Commit](https://github.com/rails/rails/commit/5645149d3a27054450bd1130ff5715504638a5f5))

### Modifications notables

*   Augmenter la version minimale de la gemme `sqlite3` à 1.4.
    ([Pull Request](https://github.com/rails/rails/pull/35844))

*   Ajouter `rails db:prepare` pour créer une base de données si elle n'existe pas et exécuter ses migrations.
    ([Pull Request](https://github.com/rails/rails/pull/35768))

*   Ajouter le rappel `after_save_commit` comme raccourci pour `after_commit :hook, on: [ :create, :update ]`.
    ([Pull Request](https://github.com/rails/rails/pull/35804))

*   Ajouter `ActiveRecord::Relation#extract_associated` pour extraire les enregistrements associés d'une relation.
    ([Pull Request](https://github.com/rails/rails/pull/35784))

*   Ajouter `ActiveRecord::Relation#annotate` pour ajouter des commentaires SQL aux requêtes ActiveRecord::Relation.
    ([Pull Request](https://github.com/rails/rails/pull/35617))

*   Ajouter la prise en charge de la définition d'indices d'optimisation sur les bases de données.
    ([Pull Request](https://github.com/rails/rails/pull/35615))

*   Ajouter les méthodes `insert_all`/`insert_all!`/`upsert_all` pour effectuer des insertions en masse.
    ([Pull Request](https://github.com/rails/rails/pull/35631))

*   Ajouter `rails db:seed:replant` qui tronque les tables de chaque base de données
    pour l'environnement actuel et charge les données de départ.
    ([Pull Request](https://github.com/rails/rails/pull/34779))

*   Ajouter la méthode `reselect`, qui est un raccourci pour `unscope(:select).select(fields)`.
    ([Pull Request](https://github.com/rails/rails/pull/33611))

*   Ajouter des scopes négatifs pour toutes les valeurs d'énumération.
    ([Pull Request](https://github.com/rails/rails/pull/35381))

*   Ajouter `#destroy_by`
*   Modifier `ActiveRecord::Base.configurations` pour renvoyer un objet au lieu d'un hash.
    ([Pull Request](https://github.com/rails/rails/pull/33637))

*   Ajouter une configuration de base de données pour désactiver les verrous consultatifs.
    ([Pull Request](https://github.com/rails/rails/pull/33691))

*   Mettre à jour la méthode `alter_table` de l'adaptateur SQLite3 pour restaurer les clés étrangères.
    ([Pull Request](https://github.com/rails/rails/pull/33585))

*   Permettre à l'option `:to_table` de `remove_foreign_key` d'être inversible.
    ([Pull Request](https://github.com/rails/rails/pull/33530))

*   Corriger la valeur par défaut des types de temps MySQL avec une précision spécifiée.
    ([Pull Request](https://github.com/rails/rails/pull/33280))

*   Corriger l'option `touch` pour se comporter de manière cohérente avec la méthode `Persistence#touch`.
    ([Pull Request](https://github.com/rails/rails/pull/33107))

*   Lever une exception pour les définitions de colonnes en double dans les migrations.
    ([Pull Request](https://github.com/rails/rails/pull/33029))

*   Augmenter la version minimale de SQLite à 3.8.
    ([Pull Request](https://github.com/rails/rails/pull/32923))

*   Corriger les enregistrements parent pour ne pas être enregistrés avec des enregistrements enfants en double.
    ([Pull Request](https://github.com/rails/rails/pull/32952))

*   S'assurer que `Associations::CollectionAssociation#size` et `Associations::CollectionAssociation#empty?`
    utilisent les identifiants d'association chargés si présents.
    ([Pull Request](https://github.com/rails/rails/pull/32617))

*   Ajouter la prise en charge du préchargement des associations des associations polymorphiques lorsque tous les enregistrements n'ont pas les associations demandées.
    ([Commit](https://github.com/rails/rails/commit/75ef18c67c29b1b51314b6c8a963cee53394080b))

*   Ajouter la méthode `touch_all` à `ActiveRecord::Relation`.
    ([Pull Request](https://github.com/rails/rails/pull/31513))

*   Ajouter le prédicat `ActiveRecord::Base.base_class?`.
    ([Pull Request](https://github.com/rails/rails/pull/32417))

*   Ajouter des options de préfixe/suffixe personnalisées à `ActiveRecord::Store.store_accessor`.
    ([Pull Request](https://github.com/rails/rails/pull/32306))

*   Ajouter `ActiveRecord::Base.create_or_find_by`/`!` pour gérer la condition de course SELECT/INSERT dans `ActiveRecord::Base.find_or_create_by`/`!` en s'appuyant sur les contraintes uniques dans la base de données.
    ([Pull Request](https://github.com/rails/rails/pull/31989))

*   Ajouter `Relation#pick` comme raccourci pour les plucks à valeur unique.
    ([Pull Request](https://github.com/rails/rails/pull/31941))

Active Storage
--------------

Veuillez vous référer au [journal des modifications][active-storage] pour des changements détaillés.

### Suppressions

### Dépréciations

*   Déprécier `config.active_storage.queue` au profit de `config.active_storage.queues.analysis`
    et `config.active_storage.queues.purge`.
    ([Pull Request](https://github.com/rails/rails/pull/34838))

*   Déprécier `ActiveStorage::Downloading` au profit de `ActiveStorage::Blob#open`.
    ([Commit](https://github.com/rails/rails/commit/ee21b7c2eb64def8f00887a9fafbd77b85f464f1))

*   Déprécier l'utilisation de `mini_magick` directement pour générer des variantes d'images au profit de
    `image_processing`.
    ([Commit](https://github.com/rails/rails/commit/697f4a93ad386f9fb7795f0ba68f815f16ebad0f))

*   Déprécier `:combine_options` dans le transformateur ImageProcessing d'Active Storage
    sans remplacement.
    ([Commit](https://github.com/rails/rails/commit/697f4a93ad386f9fb7795f0ba68f815f16ebad0f))

### Changements notables

*   Ajouter la prise en charge de la génération de variantes d'images BMP.
    ([Pull Request](https://github.com/rails/rails/pull/36051))

*   Ajouter la prise en charge de la génération de variantes d'images TIFF.
    ([Pull Request](https://github.com/rails/rails/pull/34824))

*   Ajouter la prise en charge de la génération de variantes d'images JPEG progressives.
    ([Pull Request](https://github.com/rails/rails/pull/34455))

*   Ajouter `ActiveStorage.routes_prefix` pour configurer les routes générées par Active Storage.
    ([Pull Request](https://github.com/rails/rails/pull/33883))

*   Générer une réponse 404 Not Found sur `ActiveStorage::DiskController#show` lorsque
    le fichier demandé est manquant dans le service de disque.
    ([Pull Request](https://github.com/rails/rails/pull/33666))

*   Lever `ActiveStorage::FileNotFoundError` lorsque le fichier demandé est manquant pour
    `ActiveStorage::Blob#download` et `ActiveStorage::Blob#open`.
    ([Pull Request](https://github.com/rails/rails/pull/33666))

*   Ajouter une classe générique `ActiveStorage::Error` dont héritent les exceptions d'Active Storage.
    ([Commit](https://github.com/rails/rails/commit/18425b837149bc0d50f8d5349e1091a623762d6b))

*   Persister les fichiers téléchargés assignés à un enregistrement dans le stockage lorsque l'enregistrement
    est enregistré au lieu de le faire immédiatement.
    ([Pull Request](https://github.com/rails/rails/pull/33303))

*   Remplacer éventuellement les fichiers existants au lieu de les ajouter lors de l'assignation à
    une collection de pièces jointes (comme dans `@user.update!(images: [ … ])`). Utiliser
    `config.active_storage.replace_on_assign_to_many` pour contrôler ce comportement.
    ([Pull Request](https://github.com/rails/rails/pull/33303),
     [Pull Request](https://github.com/rails/rails/pull/36716))

*   Ajouter la possibilité de réfléchir sur les pièces jointes définies en utilisant le mécanisme de réflexion
    existant d'Active Record.
    ([Pull Request](https://github.com/rails/rails/pull/33018))

*   Ajouter `ActiveStorage::Blob#open`, qui télécharge un blob dans un fichier temporaire sur le disque
    et renvoie le fichier temporaire.
    ([Commit](https://github.com/rails/rails/commit/ee21b7c2eb64def8f00887a9fafbd77b85f464f1))

*   Prise en charge des téléchargements en streaming depuis Google Cloud Storage. Nécessite la version 1.11+
    de la gem `google-cloud-storage`.
    ([Pull Request](https://github.com/rails/rails/pull/32788))

*   Utiliser la gem
*   Déprécier `ActiveSupport::Multibyte::Chars.consumes?` en faveur de `String#is_utf8?`.
    ([Demande d'extraction](https://github.com/rails/rails/pull/34215))

*   Déprécier `ActiveSupport::Multibyte::Unicode#pack_graphemes(array)` et `ActiveSupport::Multibyte::Unicode#unpack_graphemes(string)` en faveur de `array.flatten.pack("U*")` et `string.scan(/\X/).map(&:codepoints)`, respectivement.
    ([Demande d'extraction](https://github.com/rails/rails/pull/34254))

### Changements notables

*   Ajouter la prise en charge des tests parallèles.
    ([Demande d'extraction](https://github.com/rails/rails/pull/31900))

*   S'assurer que `String#strip_heredoc` préserve la congélation des chaînes.
    ([Demande d'extraction](https://github.com/rails/rails/pull/32037))

*   Ajouter `String#truncate_bytes` pour tronquer une chaîne à une taille maximale en octets sans casser les caractères multioctets ou les groupes de graphèmes.
    ([Demande d'extraction](https://github.com/rails/rails/pull/27319))

*   Ajouter l'option `private` à la méthode `delegate` afin de déléguer à des méthodes privées. Cette option accepte `true/false` comme valeur.
    ([Demande d'extraction](https://github.com/rails/rails/pull/31944))

*   Ajouter la prise en charge des traductions via I18n pour `ActiveSupport::Inflector#ordinal` et `ActiveSupport::Inflector#ordinalize`.
    ([Demande d'extraction](https://github.com/rails/rails/pull/32168))

*   Ajouter les méthodes `before?` et `after?` à `Date`, `DateTime`, `Time` et `TimeWithZone`.
    ([Demande d'extraction](https://github.com/rails/rails/pull/32185))

*   Corriger le bogue où `URI.unescape` échouait avec une entrée de caractères Unicode/échappés mélangés.
    ([Demande d'extraction](https://github.com/rails/rails/pull/32183))

*   Corriger le bogue où `ActiveSupport::Cache` augmentait massivement la taille de stockage lorsque la compression était activée.
    ([Demande d'extraction](https://github.com/rails/rails/pull/32539))

*   Redis cache store : `delete_matched` ne bloque plus le serveur Redis.
    ([Demande d'extraction](https://github.com/rails/rails/pull/32614))

*   Corriger le bogue où `ActiveSupport::TimeZone.all` échouait lorsque les données tzinfo pour n'importe quel fuseau horaire défini dans `ActiveSupport::TimeZone::MAPPING` étaient manquantes.
    ([Demande d'extraction](https://github.com/rails/rails/pull/32613))

*   Ajouter `Enumerable#index_with` qui permet de créer un hash à partir d'un énumérable avec la valeur d'un bloc passé ou un argument par défaut.
    ([Demande d'extraction](https://github.com/rails/rails/pull/32523))

*   Autoriser les méthodes `Range#===` et `Range#cover?` à fonctionner avec un argument `Range`.
    ([Demande d'extraction](https://github.com/rails/rails/pull/32938))

*   Prise en charge de l'expiration des clés dans les opérations `increment/decrement` de RedisCacheStore.
    ([Demande d'extraction](https://github.com/rails/rails/pull/33254))

*   Ajouter des fonctionnalités de temps CPU, de temps d'inactivité et d'allocations aux événements du log subscriber.
    ([Demande d'extraction](https://github.com/rails/rails/pull/33449))

*   Ajouter la prise en charge d'un objet d'événement au système de notification Active Support.
    ([Demande d'extraction](https://github.com/rails/rails/pull/33451))

*   Ajouter la prise en charge de la non-mise en cache des entrées `nil` en introduisant une nouvelle option `skip_nil` pour `ActiveSupport::Cache#fetch`.
    ([Demande d'extraction](https://github.com/rails/rails/pull/25437))

*   Ajouter la méthode `Array#extract!` qui supprime et renvoie les éléments pour lesquels le bloc renvoie une valeur vraie.
    ([Demande d'extraction](https://github.com/rails/rails/pull/33137))

*   Conserver une chaîne HTML-safe après découpage.
    ([Demande d'extraction](https://github.com/rails/rails/pull/33808))

*   Ajouter la prise en charge du suivi des autoloads constants via le journal.
    ([Commit](https://github.com/rails/rails/commit/c03bba4f1f03bad7dc034af555b7f2b329cf76f5))

*   Définir `unfreeze_time` comme un alias de `travel_back`.
    ([Demande d'extraction](https://github.com/rails/rails/pull/33813))

*   Changer `ActiveSupport::TaggedLogging.new` pour renvoyer une nouvelle instance de journal au lieu de muter celle reçue en argument.
    ([Demande d'extraction](https://github.com/rails/rails/pull/27792))

*   Traiter les méthodes `#delete_prefix`, `#delete_suffix` et `#unicode_normalize` comme des méthodes non HTML-safe.
    ([Demande d'extraction](https://github.com/rails/rails/pull/33990))

*   Corriger le bogue où `#without` pour `ActiveSupport::HashWithIndifferentAccess` échouait avec des arguments de symbole.
    ([Demande d'extraction](https://github.com/rails/rails/pull/34012))

*   Renommer `Module#parent`, `Module#parents` et `Module#parent_name` en `module_parent`, `module_parents` et `module_parent_name`.
    ([Demande d'extraction](https://github.com/rails/rails/pull/34051))

*   Ajouter `ActiveSupport::ParameterFilter`.
    ([Demande d'extraction](https://github.com/rails/rails/pull/34039))

*   Corriger le problème où la durée était arrondie à une seconde entière lorsque un flottant était ajouté à la durée.
    ([Demande d'extraction](https://github.com/rails/rails/pull/34135))

*   Faire de `#to_options` un alias de `#symbolize_keys` dans `ActiveSupport::HashWithIndifferentAccess`.
    ([Demande d'extraction](https://github.com/rails/rails/pull/34360))

*   Ne plus lever d'exception si le même bloc est inclus plusieurs fois pour un Concern.
    ([Demande d'extraction](https://github.com/rails/rails/pull/34553))

*   Préserver l'ordre des clés transmis à `ActiveSupport::CacheStore#fetch_multi`.
    ([Demande d'extraction](https://github.com/rails/rails/pull/34700))

*   Corriger `String#safe_constantize` pour ne pas générer d'erreur `LoadError` pour les références de constantes incorrectement cadrées.
    ([Demande d'extraction](https://github.com/rails/rails/pull/34892))

*   Ajouter `Hash#deep_transform_values` et `Hash#deep
*   Autoriser l'appel de `perform_enqueued_jobs` sans bloc.
    ([Pull Request](https://github.com/rails/rails/pull/33626))

*   Autoriser l'appel de `assert_performed_with` sans bloc.
    ([Pull Request](https://github.com/rails/rails/pull/33635))

*   Ajouter l'option `:queue` aux assertions et aux helpers de tâches.
    ([Pull Request](https://github.com/rails/rails/pull/33635))

*   Ajouter des hooks à Active Job pour les réessais et les suppressions.
    ([Pull Request](https://github.com/rails/rails/pull/33751))

*   Ajouter une façon de tester un sous-ensemble d'arguments lors de l'exécution de tâches.
    ([Pull Request](https://github.com/rails/rails/pull/33995))

*   Inclure les arguments désérialisés dans les tâches renvoyées par les helpers de test d'Active Job.
    ([Pull Request](https://github.com/rails/rails/pull/34204))

*   Autoriser les helpers d'assertion d'Active Job à accepter un Proc pour l'argument `only`.
    ([Pull Request](https://github.com/rails/rails/pull/34339))

*   Supprimer les microsecondes et les nanosecondes des arguments de tâche dans les helpers d'assertion.
    ([Pull Request](https://github.com/rails/rails/pull/35713))

Guides Ruby on Rails
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
pour les nombreuses personnes qui ont passé de nombreuses heures à faire de Rails, le framework stable et robuste qu'il est. Félicitations à tous.
[active-storage]: https://github.com/rails/rails/blob/6-0-stable/activestorage/CHANGELOG.md
[active-support]: https://github.com/rails/rails/blob/6-0-stable/activesupport/CHANGELOG.md
