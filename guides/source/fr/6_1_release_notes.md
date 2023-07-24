**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 1d652e6ccda9c901ca3f6a003c95f83e
Notes de version de Ruby on Rails 6.1
=======================================

Points forts de Rails 6.1 :

* Changement de connexion par base de données
* Sharding horizontal
* Chargement strict des associations
* Types délégués
* Destruction des associations de manière asynchrone

Ces notes de version ne couvrent que les changements majeurs. Pour en savoir plus sur les corrections de bugs et les modifications diverses, veuillez vous référer aux journaux des modifications ou consulter la [liste des commits](https://github.com/rails/rails/commits/6-1-stable) dans le dépôt principal de Rails sur GitHub.

--------------------------------------------------------------------------------

Mise à niveau vers Rails 6.1
---------------------------

Si vous mettez à niveau une application existante, il est recommandé d'avoir une bonne couverture de tests avant de commencer. Vous devriez également d'abord mettre à niveau vers Rails 6.0 si ce n'est pas déjà fait, et vous assurer que votre application fonctionne toujours comme prévu avant de tenter une mise à jour vers Rails 6.1. Une liste de points à surveiller lors de la mise à niveau est disponible dans le guide [Mise à niveau de Ruby on Rails](upgrading_ruby_on_rails.html#upgrading-from-rails-6-0-to-rails-6-1).

Fonctionnalités majeures
------------------------

### Changement de connexion par base de données

Rails 6.1 vous permet de [changer de connexion par base de données](https://github.com/rails/rails/pull/40370). Dans la version 6.0, si vous passiez au rôle "lecture", toutes les connexions à la base de données passaient également au rôle "lecture". Maintenant, dans la version 6.1, si vous définissez `legacy_connection_handling` sur `false` dans votre configuration, Rails vous permettra de changer de connexion pour une seule base de données en appelant `connected_to` sur la classe abstraite correspondante.

### Sharding horizontal

Rails 6.0 permettait de partitionner fonctionnellement (plusieurs partitions, schémas différents) votre base de données, mais ne prenait pas en charge le sharding horizontal (même schéma, plusieurs partitions). Rails ne pouvait pas prendre en charge le sharding horizontal car les modèles dans Active Record ne pouvaient avoir qu'une seule connexion par rôle par classe. Cela est maintenant corrigé et le [sharding horizontal](https://github.com/rails/rails/pull/38531) est disponible avec Rails.

### Chargement strict des associations

Le [chargement strict des associations](https://github.com/rails/rails/pull/37400) vous permet de vous assurer que toutes vos associations sont chargées de manière anticipée et d'éviter les problèmes de type N+1.

### Types délégués

[Les types délégués](https://github.com/rails/rails/pull/39341) sont une alternative à l'héritage sur une seule table. Cela permet de représenter des hiérarchies de classes en permettant à la superclasse d'être une classe concrète représentée par sa propre table. Chaque sous-classe a sa propre table pour les attributs supplémentaires.

### Destruction des associations de manière asynchrone

[La destruction asynchrone des associations](https://github.com/rails/rails/pull/40157) ajoute la possibilité aux applications de détruire des associations dans un travail en arrière-plan. Cela peut vous aider à éviter les délais d'attente et autres problèmes de performance dans votre application lors de la suppression de données.

Railties
--------

Veuillez vous référer au [journal des modifications][railties] pour les changements détaillés.

### Suppressions

*   Suppression des tâches `rake notes` obsolètes.

*   Suppression de l'option `connection` obsolète dans la commande `rails dbconsole`.

*   Suppression du support de la variable d'environnement `SOURCE_ANNOTATION_DIRECTORIES` obsolète dans `rails notes`.

*   Suppression de l'argument `server` obsolète de la commande `rails server`.

*   Suppression du support obsolète de l'utilisation de la variable d'environnement `HOST` pour spécifier l'adresse IP du serveur.

*   Suppression des tâches `rake dev:cache` obsolètes.

*   Suppression des tâches `rake routes` obsolètes.

*   Suppression des tâches `rake initializers` obsolètes.

### Dépréciations

### Changements notables

Action Cable
------------

Veuillez vous référer au [journal des modifications][action-cable] pour les changements détaillés.

### Suppressions

### Dépréciations

### Changements notables

Action Pack
-----------

Veuillez vous référer au [journal des modifications][action-pack] pour les changements détaillés.

### Suppressions

*   Suppression de `ActionDispatch::Http::ParameterFilter` obsolète.

*   Suppression de `force_ssl` obsolète au niveau du contrôleur.

### Dépréciations

*   Dépréciation de `config.action_dispatch.return_only_media_type_on_content_type`.

### Changements notables

*   Modification de `ActionDispatch::Response#content_type` pour renvoyer l'en-tête Content-Type complet.

Action View
-----------

Veuillez vous référer au [journal des modifications][action-view] pour les changements détaillés.

### Suppressions

*   Suppression de `escape_whitelist` obsolète de `ActionView::Template::Handlers::ERB`.

*   Suppression de `find_all_anywhere` obsolète de `ActionView::Resolver`.

*   Suppression de `formats` obsolète de `ActionView::Template::HTML`.

*   Suppression de `formats` obsolète de `ActionView::Template::RawFile`.

*   Suppression de `formats` obsolète de `ActionView::Template::Text`.

*   Suppression de `find_file` obsolète de `ActionView::PathSet`.

*   Suppression de `rendered_format` obsolète de `ActionView::LookupContext`.

*   Suppression de `find_file` obsolète de `ActionView::ViewPaths`.

*   Suppression du support obsolète de passer un objet qui n'est pas un `ActionView::LookupContext` en premier argument dans `ActionView::Base#initialize`.

*   Suppression de l'argument `format` obsolète de `ActionView::Base#initialize`.

*   Suppression de `ActionView::Template#refresh` obsolète.

*   Suppression de `ActionView::Template#original_encoding` obsolète.

*   Suppression de `ActionView::Template#variants` obsolète.

*   Suppression de `ActionView::Template#formats` obsolète.

*   Suppression de `ActionView::Template#virtual_path=` obsolète.

*   Suppression de `ActionView::Template#updated_at` obsolète.

*   Suppression de l'argument `updated_at` requis pour `ActionView::Template#initialize` obsolète.

*   Suppression de `ActionView::Template.finalize_compiled_template_methods` obsolète.

*   Suppression de `config.action_view.finalize_compiled_template_methods` obsolète.

*   Suppression du support de l'appel de `ActionView::ViewPaths#with_fallback` avec un bloc.

*   Suppression du support de passer des chemins absolus à `render template:`.

*   Suppression du support de passer des chemins relatifs à `render file:`.

*   Suppression du support des gestionnaires de templates qui n'acceptent pas deux arguments.

*   Suppression de l'argument `pattern` obsolète dans `ActionView::Template::PathResolver`.

*   Suppression du support obsolète d'appeler des méthodes privées d'un objet dans certains helpers de vue.

### Dépréciations

### Changements notables
*   Exiger que les sous-classes de `ActionView::Base` implémentent `#compiled_method_container`.

*   Rendre l'argument `locals` obligatoire dans `ActionView::Template#initialize`.

*   Les helpers d'assets `javascript_include_tag` et `stylesheet_link_tag` génèrent un en-tête `Link` qui donne des indications aux navigateurs modernes sur le préchargement des assets. Cela peut être désactivé en définissant `config.action_view.preload_links_header` sur `false`.

Action Mailer
-------------

Veuillez vous référer au [journal des modifications][action-mailer] pour des détails sur les changements.

### Suppressions

*   Supprimer la méthode obsolète `ActionMailer::Base.receive` en faveur de [Action Mailbox](https://github.com/rails/rails/tree/6-1-stable/actionmailbox).

### Dépréciations

### Changements notables

Active Record
-------------

Veuillez vous référer au [journal des modifications][active-record] pour des détails sur les changements.

### Suppressions

*   Supprimer les méthodes obsolètes de `ActiveRecord::ConnectionAdapters::DatabaseLimits`.

    `column_name_length`
    `table_name_length`
    `columns_per_table`
    `indexes_per_table`
    `columns_per_multicolumn_index`
    `sql_query_length`
    `joins_per_query`

*   Supprimer la méthode obsolète `ActiveRecord::ConnectionAdapters::AbstractAdapter#supports_multi_insert?`.

*   Supprimer la méthode obsolète `ActiveRecord::ConnectionAdapters::AbstractAdapter#supports_foreign_keys_in_create?`.

*   Supprimer la méthode obsolète `ActiveRecord::ConnectionAdapters::PostgreSQLAdapter#supports_ranges?`.

*   Supprimer les méthodes obsolètes `ActiveRecord::Base#update_attributes` et `ActiveRecord::Base#update_attributes!`.

*   Supprimer l'argument `migrations_path` obsolète dans
    `ActiveRecord::ConnectionAdapter::SchemaStatements#assume_migrated_upto_version`.

*   Supprimer la méthode obsolète `config.active_record.sqlite3.represent_boolean_as_integer`.

*   Supprimer les méthodes obsolètes de `ActiveRecord::DatabaseConfigurations`.

    `fetch`
    `each`
    `first`
    `values`
    `[]=`

*   Supprimer la méthode obsolète `ActiveRecord::Result#to_hash`.

*   Supprimer la prise en charge obsolète de l'utilisation de SQL brut non sécurisé dans les méthodes de `ActiveRecord::Relation`.

### Dépréciations

*   Déprécier `ActiveRecord::Base.allow_unsafe_raw_sql`.

*   Déprécier l'argument `database` dans `connected_to`.

*   Déprécier `connection_handlers` lorsque `legacy_connection_handling` est défini sur false.

### Changements notables

*   MySQL : Le validateur d'unicité respecte maintenant la collation par défaut de la base de données, n'impose plus une comparaison sensible à la casse par défaut.

*   `relation.create` ne fuit plus la portée vers les méthodes de requête de niveau de classe dans le bloc d'initialisation et les rappels.

    Avant :

    ```ruby
    User.where(name: "John").create do |john|
      User.find_by(name: "David") # => nil
    end
    ```

    Après :

    ```ruby
    User.where(name: "John").create do |john|
      User.find_by(name: "David") # => #<User name: "David", ...>
    end
    ```

*   La chaîne de portée nommée ne fuit plus la portée vers les méthodes de requête de niveau de classe.

    ```ruby
    class User < ActiveRecord::Base
      scope :david, -> { User.where(name: "David") }
    end
    ```

    Avant :

    ```ruby
    User.where(name: "John").david
    # SELECT * FROM users WHERE name = 'John' AND name = 'David'
    ```

    Après :

    ```ruby
    User.where(name: "John").david
    # SELECT * FROM users WHERE name = 'David'
    ```

*   `where.not` génère maintenant des prédicats NAND au lieu de NOR.

    Avant :

    ```ruby
    User.where.not(name: "Jon", role: "admin")
    # SELECT * FROM users WHERE name != 'Jon' AND role != 'admin'
    ```

    Après :

    ```ruby
    User.where.not(name: "Jon", role: "admin")
    # SELECT * FROM users WHERE NOT (name = 'Jon' AND role = 'admin')
    ```

*   Pour utiliser la nouvelle gestion de connexion par base de données, les applications doivent définir `legacy_connection_handling` sur false et supprimer les accesseurs obsolètes sur `connection_handlers`. Les méthodes publiques pour `connects_to` et `connected_to` ne nécessitent aucun changement.

Active Storage
--------------

Veuillez vous référer au [journal des modifications][active-storage] pour des détails sur les changements.

### Suppressions

*   Supprimer la prise en charge obsolète pour passer des opérations `:combine_options` à `ActiveStorage::Transformers::ImageProcessing`.

*   Supprimer la classe obsolète `ActiveStorage::Transformers::MiniMagickTransformer`.

*   Supprimer la configuration obsolète `config.active_storage.queue`.

*   Supprimer la classe obsolète `ActiveStorage::Downloading`.

### Dépréciations

*   Déprécier `Blob.create_after_upload` au profit de `Blob.create_and_upload`.
    ([Pull Request](https://github.com/rails/rails/pull/34827))

### Changements notables

*   Ajouter `Blob.create_and_upload` pour créer un nouveau blob et télécharger le `io` donné vers le service.
    ([Pull Request](https://github.com/rails/rails/pull/34827))
*   Une colonne `service_name` a été ajoutée à `ActiveStorage::Blob`. Il est nécessaire d'exécuter une migration après la mise à niveau. Exécutez `bin/rails app:update` pour générer cette migration.

Active Model
------------

Veuillez vous référer au [journal des modifications][active-model] pour des détails sur les changements.

### Suppressions

### Dépréciations

### Changements notables

*   Les erreurs d'Active Model sont maintenant des objets avec une interface qui permet à votre application de gérer et d'interagir plus facilement avec les erreurs générées par les modèles. [La fonctionnalité](https://github.com/rails/rails/pull/32313) inclut une interface de requête, permet des tests plus précis et donne accès aux détails des erreurs.

Active Support
--------------

Veuillez vous référer au [journal des modifications][active-support] pour des détails sur les changements.

### Suppressions

*   Supprimer le recours obsolète à `I18n.default_locale` lorsque `config.i18n.fallbacks` est vide.

*   Supprimer la constante obsolète `LoggerSilence`.

*   Supprimer la méthode obsolète `ActiveSupport::LoggerThreadSafeLevel#after_initialize`.

*   Supprimer les méthodes obsolètes `Module#parent_name`, `Module#parent` et `Module#parents`.

*   Supprimer le fichier obsolète `active_support/core_ext/module/reachable`.

*   Supprimer le fichier obsolète `active_support/core_ext/numeric/inquiry`.

*   Supprimer le fichier obsolète `active_support/core_ext/array/prepend_and_append`.

*   Supprimer le fichier obsolète `active_support/core_ext/hash/compact`.

*   Supprimer le fichier obsolète `active_support/core_ext/hash/transform_values`.

*   Supprimer le fichier obsolète `active_support/core_ext/range/include_range`.

*   Supprimer les méthodes obsolètes `ActiveSupport::Multibyte::Chars#consumes?` et `ActiveSupport::Multibyte::Chars#normalize`.

*   Supprimer les méthodes obsolètes `ActiveSupport::Multibyte::Unicode.pack_graphemes`,
    `ActiveSupport::Multibyte::Unicode.unpack_graphemes`,
    `ActiveSupport::Multibyte::Unicode.normalize`,
    `ActiveSupport::Multibyte::Unicode.downcase`,
    `ActiveSupport::Multibyte::Unicode.upcase` et `ActiveSupport::Multibyte::Unicode.swapcase`.

*   Supprimer la méthode obsolète `ActiveSupport::Notifications::Instrumenter#end=`.

### Dépréciations

*   Déprécier `ActiveSupport::Multibyte::Unicode.default_normalization_form`.

### Changements notables

Active Job
----------

Veuillez vous référer au [journal des modifications][active-job] pour des détails sur les changements.

### Suppressions

### Dépréciations

*   Déprécier `config.active_job.return_false_on_aborted_enqueue`.

### Changements notables

*   Renvoyer `false` lorsque l'enfilement d'un travail est annulé.

Action Text
----------

Veuillez vous référer au [journal des modifications][action-text] pour des détails sur les changements.

### Suppressions

### Dépréciations

### Changements notables

*   Ajouter une méthode pour confirmer l'existence d'un contenu de texte enrichi en ajoutant `?` après le nom de l'attribut de texte enrichi.
    ([Pull Request](https://github.com/rails/rails/pull/37951))

*   Ajouter l'aide de test système `fill_in_rich_text_area` pour trouver un éditeur Trix et le remplir avec le contenu HTML donné.
    ([Pull Request](https://github.com/rails/rails/pull/35885))
*   Ajoutez `ActionText::FixtureSet.attachment` pour générer des éléments `<action-text-attachment>` dans les fixtures de la base de données. ([Pull Request](https://github.com/rails/rails/pull/40289))

Action Mailbox
----------

Veuillez vous référer au [Changelog][action-mailbox] pour les changements détaillés.

### Suppressions

### Dépréciations

*   Dépréciez `Rails.application.credentials.action_mailbox.api_key` et `MAILGUN_INGRESS_API_KEY` au profit de `Rails.application.credentials.action_mailbox.signing_key` et `MAILGUN_INGRESS_SIGNING_KEY`.

### Changements notables

Ruby on Rails Guides
--------------------

Veuillez vous référer au [Changelog][guides] pour les changements détaillés.

### Changements notables

Crédits
-------

Consultez la [liste complète des contributeurs à Rails](https://contributors.rubyonrails.org/) pour les nombreuses personnes qui ont passé de nombreuses heures à faire de Rails le framework stable et robuste qu'il est. Bravo à tous.

[railties]:       https://github.com/rails/rails/blob/6-1-stable/railties/CHANGELOG.md
[action-pack]:    https://github.com/rails/rails/blob/6-1-stable/actionpack/CHANGELOG.md
[action-view]:    https://github.com/rails/rails/blob/6-1-stable/actionview/CHANGELOG.md
[action-mailer]:  https://github.com/rails/rails/blob/6-1-stable/actionmailer/CHANGELOG.md
[action-cable]:   https://github.com/rails/rails/blob/6-1-stable/actioncable/CHANGELOG.md
[active-record]:  https://github.com/rails/rails/blob/6-1-stable/activerecord/CHANGELOG.md
[active-model]:   https://github.com/rails/rails/blob/6-1-stable/activemodel/CHANGELOG.md
[active-job]:     https://github.com/rails/rails/blob/6-1-stable/activejob/CHANGELOG.md
[action-text]:    https://github.com/rails/rails/blob/6-1-stable/actiontext/CHANGELOG.md
[guides]:         https://github.com/rails/rails/blob/6-1-stable/guides/CHANGELOG.md
[active-storage]: https://github.com/rails/rails/blob/6-1-stable/activestorage/CHANGELOG.md
[active-support]: https://github.com/rails/rails/blob/6-1-stable/activesupport/CHANGELOG.md
[action-mailbox]: https://github.com/rails/rails/blob/6-1-stable/actionmailbox/CHANGELOG.md
