**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: e9aa14ccbfd8f02fea6c1b061215332c
Notes de version de Ruby on Rails 7.0
=======================================

Points forts de Rails 7.0 :

* Ruby 2.7.0+ requis, Ruby 3.0+ préféré

--------------------------------------------------------------------------------

Mise à niveau vers Rails 7.0
----------------------------

Si vous mettez à niveau une application existante, il est conseillé d'avoir une bonne couverture de tests avant de commencer. Vous devriez également d'abord mettre à niveau vers Rails 6.1 au cas où vous ne l'auriez pas déjà fait, et vous assurer que votre application fonctionne toujours comme prévu avant de tenter une mise à jour vers Rails 7.0. Une liste de choses à surveiller lors de la mise à niveau est disponible dans le guide de mise à niveau de Ruby on Rails.

Principales fonctionnalités
--------------------------

Railties
--------

Veuillez vous référer au [journal des modifications][railties] pour les changements détaillés.

### Suppressions

*   Suppression de la configuration obsolète `config` dans `dbconsole`.

### Dépréciations

### Changements notables

*   Sprockets est maintenant une dépendance facultative

    La gem `rails` ne dépend plus de `sprockets-rails`. Si votre application a encore besoin d'utiliser Sprockets,
    assurez-vous d'ajouter `sprockets-rails` à votre Gemfile.

    ```
    gem "sprockets-rails"
    ```

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

*   Suppression de la méthode obsolète `ActionDispatch::Response.return_only_media_type_on_content_type`.

*   Suppression de la configuration obsolète `Rails.config.action_dispatch.hosts_response_app`.

*   Suppression de la méthode obsolète `ActionDispatch::SystemTestCase#host!`.

*   Suppression du support obsolète pour passer un chemin relatif à `fixture_file_upload` par rapport à `fixture_path`.

### Dépréciations

### Changements notables

Action View
-----------

Veuillez vous référer au [journal des modifications][action-view] pour les changements détaillés.

### Suppressions

*   Suppression de la configuration obsolète `Rails.config.action_view.raise_on_missing_translations`.

### Dépréciations

### Changements notables

*  `button_to` déduit la méthode HTTP [method] à partir d'un objet Active Record si l'objet est utilisé pour construire l'URL

    ```ruby
    button_to("Faire un POST", [:do_post_action, Workshop.find(1)])
    # Avant
    #=>   <input type="hidden" name="_method" value="post" autocomplete="off" />
    # Après
    #=>   <input type="hidden" name="_method" value="patch" autocomplete="off" />
    ```

Action Mailer
-------------

Veuillez vous référer au [journal des modifications][action-mailer] pour les changements détaillés.

### Suppressions

*   Suppression des classes obsolètes `ActionMailer::DeliveryJob` et `ActionMailer::Parameterized::DeliveryJob`
    au profit de `ActionMailer::MailDeliveryJob`.

### Dépréciations

### Changements notables

Active Record
-------------

Veuillez vous référer au [journal des modifications][active-record] pour les changements détaillés.

### Suppressions

*   Suppression de l'argument obsolète `database` de `connected_to`.

*   Suppression de la configuration obsolète `ActiveRecord::Base.allow_unsafe_raw_sql`.

*   Suppression de l'option obsolète `:spec_name` dans la méthode `configs_for`.

*   Suppression du support obsolète de chargement YAML de l'instance `ActiveRecord::Base` dans les formats Rails 4.2 et 4.1.

*   Suppression de l'avertissement de dépréciation lorsque la colonne `:interval` est utilisée dans une base de données PostgreSQL.

    Maintenant, les colonnes d'intervalle renverront des objets `ActiveSupport::Duration` au lieu de chaînes de caractères.

    Pour conserver l'ancien comportement, vous pouvez ajouter cette ligne à votre modèle :

    ```ruby
    attribute :column, :string
    ```

*   Suppression du support obsolète pour résoudre la connexion en utilisant `"primary"` comme nom de spécification de connexion.

*   Suppression du support obsolète pour citer des objets `ActiveRecord::Base`.

*   Suppression du support obsolète pour convertir des objets `ActiveRecord::Base` en valeurs de base de données.

*   Suppression du support obsolète pour passer une colonne à `type_cast`.

*   Suppression de la méthode obsolète `DatabaseConfig#config`.

*   Suppression des tâches Rake obsolètes :

    * `db:schema:load_if_ruby`
    * `db:structure:dump`
    * `db:structure:load`
    * `db:structure:load_if_sql`
    * `db:structure:dump:#{name}`
    * `db:structure:load:#{name}`
    * `db:test:load_structure`
    * `db:test:load_structure:#{name}`

*   Suppression du support obsolète pour `Model.reorder(nil).first` pour effectuer une recherche en utilisant un ordre non déterministe.

*   Suppression des arguments `environment` et `name` obsolètes de `Tasks::DatabaseTasks.schema_up_to_date?`.

*   Suppression de la méthode obsolète `Tasks::DatabaseTasks.dump_filename`.

*   Suppression de la méthode obsolète `Tasks::DatabaseTasks.schema_file`.

*   Suppression de la méthode obsolète `Tasks::DatabaseTasks.spec`.

*   Suppression de la méthode obsolète `Tasks::DatabaseTasks.current_config`.

*   Suppression de la méthode obsolète `ActiveRecord::Connection#allowed_index_name_length`.

*   Suppression de la méthode obsolète `ActiveRecord::Connection#in_clause_length`.

*   Suppression de la méthode obsolète `ActiveRecord::DatabaseConfigurations::DatabaseConfig#spec_name`.

*   Suppression de la méthode obsolète `ActiveRecord::Base.connection_config`.

*   Suppression de la méthode obsolète `ActiveRecord::Base.arel_attribute`.

*   Suppression de la méthode obsolète `ActiveRecord::Base.configurations.default_hash`.

*   Suppression de la méthode obsolète `ActiveRecord::Base.configurations.to_h`.

*   Suppression des méthodes obsolètes `ActiveRecord::Result#map!` et `ActiveRecord::Result#collect!`.

*   Suppression de la méthode obsolète `ActiveRecord::Base#remove_connection`.

### Dépréciations

*   Dépréciation de la méthode `Tasks::DatabaseTasks.schema_file_type`.

### Changements notables

*   Annulation des transactions lorsque le bloc retourne plus tôt que prévu.

    Avant ce changement, lorsque le bloc de transaction retournait prématurément, la transaction était validée.

    Le problème est que les délais d'attente déclenchés à l'intérieur du bloc de transaction faisaient également valider la transaction incomplète, donc afin d'éviter cette erreur, le bloc de transaction est annulé.

*   La fusion des conditions sur la même colonne ne conserve plus les deux conditions,
    et sera systématiquement remplacée par la dernière condition.

    ```ruby
    # Rails 6.1 (la clause IN est remplacée par une condition d'égalité du côté du mergeur)
    Author.where(id: [david.id, mary.id]).merge(Author.where(id: bob)) # => [bob]
    # Rails 6.1 (les deux conditions de conflit existent, déprécié)
    Author.where(id: david.id..mary.id).merge(Author.where(id: bob)) # => []
    # Rails 6.1 avec rewhere pour migrer vers le comportement de Rails 7.0
    Author.where(id: david.id..mary.id).merge(Author.where(id: bob), rewhere: true) # => [bob]
    # Rails 7.0 (même comportement avec la clause IN, la condition du mergeur est systématiquement remplacée)
    Author.where(id: [david.id, mary.id]).merge(Author.where(id: bob)) # => [bob]
    Author.where(id: david.id..mary.id).merge(Author.where(id: bob)) # => [bob]
    ```
Stockage actif
--------------

Veuillez vous référer au [journal des modifications][active-storage] pour des changements détaillés.

### Suppressions

### Dépréciations

### Changements notables

Modèle actif
------------

Veuillez vous référer au [journal des modifications][active-model] pour des changements détaillés.

### Suppressions

*   Supprimer l'énumération obsolète des instances de `ActiveModel::Errors` en tant que Hash.

*   Supprimer `ActiveModel::Errors#to_h` obsolète.

*   Supprimer `ActiveModel::Errors#slice!` obsolète.

*   Supprimer `ActiveModel::Errors#values` obsolète.

*   Supprimer `ActiveModel::Errors#keys` obsolète.

*   Supprimer `ActiveModel::Errors#to_xml` obsolète.

*   Supprimer la prise en charge obsolète de la concaténation des erreurs vers `ActiveModel::Errors#messages`.

*   Supprimer la prise en charge obsolète de la suppression des erreurs à partir de `ActiveModel::Errors#messages`.

*   Supprimer la prise en charge obsolète de la suppression des erreurs à partir de `ActiveModel::Errors#messages`.

*   Supprimer la prise en charge obsolète de l'utilisation de `[]=` dans `ActiveModel::Errors#messages`.

*   Supprimer la prise en charge de la charge Marshal et YAML du format d'erreur Rails 5.x.

*   Supprimer la prise en charge de la charge Marshal du format `ActiveModel::AttributeSet` de Rails 5.x.

### Dépréciations

### Changements notables

Support actif
--------------

Veuillez vous référer au [journal des modifications][active-support] pour des changements détaillés.

### Suppressions

*   Supprimer `config.active_support.use_sha1_digests` obsolète.

*   Supprimer `URI.parser` obsolète.

*   Supprimer la prise en charge obsolète de l'utilisation de `Range#include?` pour vérifier l'inclusion d'une valeur dans
    une plage de date et d'heure est obsolète.

*   Supprimer `ActiveSupport::Multibyte::Unicode.default_normalization_form` obsolète.

### Dépréciations

*   Déprécier le passage d'un format à `#to_s` au profit de `#to_fs` dans `Array`, `Range`, `Date`, `DateTime`, `Time`,
    `BigDecimal`, `Float` et `Integer`.

    Cette dépréciation permet aux applications Rails de profiter d'une optimisation de Ruby 3.1
    [optimization](https://github.com/ruby/ruby/commit/b08dacfea39ad8da3f1fd7fdd0e4538cc892ec44) qui rend
    l'interpolation de certains types d'objets plus rapide.

    Les nouvelles applications n'auront pas la méthode `#to_s` substituée dans ces classes, les applications existantes peuvent utiliser
    `config.active_support.disable_to_s_conversion`.

### Changements notables

Job actif
----------

Veuillez vous référer au [journal des modifications][active-job] pour des changements détaillés.

### Suppressions

*   Suppression du comportement obsolète qui ne stoppait pas les rappels `after_enqueue`/`after_perform` lorsqu'un
    rappel précédent était arrêté avec `throw :abort`.

*   Supprimer l'option obsolète `:return_false_on_aborted_enqueue`.

### Dépréciations

*   Déprécier `Rails.config.active_job.skip_after_callbacks_if_terminated`.

### Changements notables

Texte d'action
----------

Veuillez vous référer au [journal des modifications][action-text] pour des changements détaillés.

### Suppressions

### Dépréciations

### Changements notables

Boîte aux lettres d'action
----------

Veuillez vous référer au [journal des modifications][action-mailbox] pour des changements détaillés.

### Suppressions

*   Supprimer `Rails.application.credentials.action_mailbox.mailgun_api_key` obsolète.

*   Supprimer la variable d'environnement obsolète `MAILGUN_INGRESS_API_KEY`.

### Dépréciations

### Changements notables

Guides Ruby on Rails
--------------------

Veuillez vous référer au [journal des modifications][guides] pour des changements détaillés.

### Changements notables

Crédits
-------

Consultez la
[liste complète des contributeurs à Rails](https://contributors.rubyonrails.org/)
pour les nombreuses personnes qui ont passé de nombreuses heures à faire de Rails, le framework stable et robuste
qu'il est. Félicitations à tous.
[active-storage]: https://github.com/rails/rails/blob/7-0-stable/activestorage/CHANGELOG.md
[active-support]: https://github.com/rails/rails/blob/7-0-stable/activesupport/CHANGELOG.md
[action-mailbox]: https://github.com/rails/rails/blob/7-0-stable/actionmailbox/CHANGELOG.md
