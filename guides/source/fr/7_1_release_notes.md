**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 82080185bf1d0c30f22fa131b42e4187
Notes de version de Ruby on Rails 7.1
========================================

Points forts de Rails 7.1 :

--------------------------------------------------------------------------------

Mise à niveau vers Rails 7.1
---------------------------

Si vous mettez à niveau une application existante, il est préférable d'avoir une bonne couverture de tests avant de commencer. Vous devriez également d'abord mettre à niveau vers Rails 7.0 au cas où vous ne l'auriez pas déjà fait et vous assurer que votre application fonctionne toujours comme prévu avant de tenter une mise à jour vers Rails 7.1. Une liste de choses à surveiller lors de la mise à niveau est disponible dans le guide [Mise à niveau de Ruby on Rails](upgrading_ruby_on_rails.html#upgrading-from-rails-7-0-to-rails-7-1).

Principales fonctionnalités
---------------------------

Railties
--------

Veuillez consulter le [journal des modifications][railties] pour obtenir des détails sur les modifications apportées.

### Suppressions

### Dépréciations

### Modifications notables

Action Cable
------------

Veuillez consulter le [journal des modifications][action-cable] pour obtenir des détails sur les modifications apportées.

### Suppressions

### Dépréciations

### Modifications notables

Action Pack
-----------

Veuillez consulter le [journal des modifications][action-pack] pour obtenir des détails sur les modifications apportées.

### Suppressions

*   Supprimer le comportement obsolète sur `Request#content_type`

*   Supprimer la possibilité obsolète d'assigner une seule valeur à `config.action_dispatch.trusted_proxies`.

*   Supprimer l'enregistrement obsolète des pilotes `poltergeist` et `webkit` (capybara-webkit) pour les tests système.

### Dépréciations

*   Déprécier `config.action_dispatch.return_only_request_media_type_on_content_type`.

*   Déprécier `AbstractController::Helpers::MissingHelperError`

*   Déprécier `ActionDispatch::IllegalStateError`.

### Modifications notables

Action View
-----------

Veuillez consulter le [journal des modifications][action-view] pour obtenir des détails sur les modifications apportées.

### Suppressions

*   Supprimer la constante obsolète `ActionView::Path`.

*   Supprimer le support obsolète pour le passage de variables d'instance en tant que variables locales aux partiels.

### Dépréciations

### Modifications notables

Action Mailer
-------------

Veuillez consulter le [journal des modifications][action-mailer] pour obtenir des détails sur les modifications apportées.

### Suppressions

### Dépréciations

### Modifications notables

Active Record
-------------

Veuillez consulter le [journal des modifications][active-record] pour obtenir des détails sur les modifications apportées.

### Suppressions

*   Supprimer la prise en charge de `ActiveRecord.legacy_connection_handling`.

*   Supprimer les accesseurs de configuration obsolètes de `ActiveRecord::Base`

*   Supprimer la prise en charge de `:include_replicas` sur `configs_for`. Utilisez plutôt `:include_hidden`.

*   Supprimer `config.active_record.partial_writes`.

*   Supprimer `Tasks::DatabaseTasks.schema_file_type`.

### Dépréciations

### Modifications notables

Active Storage
--------------

Veuillez consulter le [journal des modifications][active-storage] pour obtenir des détails sur les modifications apportées.

### Suppressions

*   Supprimer les types de contenu par défaut invalides dans les configurations Active Storage.

*   Supprimer les méthodes `ActiveStorage::Current#host` et `ActiveStorage::Current#host=` obsolètes.

*   Supprimer le comportement obsolète lors de l'assignation à une collection de pièces jointes. Au lieu d'ajouter à la collection,
    la collection est maintenant remplacée.

*   Supprimer les méthodes `purge` et `purge_later` obsolètes de l'association des pièces jointes.

### Dépréciations

### Modifications notables

Active Model
------------

Veuillez consulter le [journal des modifications][active-model] pour obtenir des détails sur les modifications apportées.

### Suppressions

### Dépréciations

### Modifications notables

Active Support
--------------

Veuillez consulter le [journal des modifications][active-support] pour obtenir des détails sur les modifications apportées.

### Suppressions

*   Supprimer la substitution obsolète de `Enumerable#sum`.

*   Supprimer `ActiveSupport::PerThreadRegistry`.

*   Supprimer l'option obsolète de passage d'un format à `#to_s` dans `Array`, `Range`, `Date`, `DateTime`, `Time`,
    `BigDecimal`, `Float` et `Integer`.

*   Supprimer la substitution obsolète de `ActiveSupport::TimeWithZone.name`.

*   Supprimer le fichier `active_support/core_ext/uri` obsolète.

*   Supprimer le fichier `active_support/core_ext/range/include_time_with_zone` obsolète.

*   Supprimer la conversion implicite des objets en `String` par `ActiveSupport::SafeBuffer`.

*   Supprimer le support obsolète pour générer des UUID RFC 4122 incorrects lors de la fourniture d'un ID d'espace de noms qui n'est pas l'une des
    constantes définies sur `Digest::UUID`.

### Dépréciations

*   Déprécier `config.active_support.disable_to_s_conversion`.

*   Déprécier `config.active_support.remove_deprecated_time_with_zone_name`.

*   Déprécier `config.active_support.use_rfc4122_namespaced_uuids`.

### Modifications notables

Active Job
----------

Veuillez consulter le [journal des modifications][active-job] pour obtenir des détails sur les modifications apportées.

### Suppressions

### Dépréciations

### Modifications notables

Action Text
----------

Veuillez consulter le [journal des modifications][action-text] pour obtenir des détails sur les modifications apportées.

### Suppressions

### Dépréciations

### Modifications notables

Action Mailbox
----------

Veuillez consulter le [journal des modifications][action-mailbox] pour obtenir des détails sur les modifications apportées.

### Suppressions

### Dépréciations

### Modifications notables

Guides Ruby on Rails
--------------------

Veuillez consulter le [journal des modifications][guides] pour obtenir des détails sur les modifications apportées.

### Modifications notables

Crédits
-------

Consultez la [liste complète des contributeurs à Rails](https://contributors.rubyonrails.org/)
pour toutes les personnes qui ont passé de nombreuses heures à faire de Rails le framework stable et robuste qu'il est. Félicitations à tous.

[railties]:       https://github.com/rails/rails/blob/main/railties/CHANGELOG.md
[action-pack]:    https://github.com/rails/rails/blob/main/actionpack/CHANGELOG.md
[action-view]:    https://github.com/rails/rails/blob/main/actionview/CHANGELOG.md
[action-mailer]:  https://github.com/rails/rails/blob/main/actionmailer/CHANGELOG.md
[action-cable]:   https://github.com/rails/rails/blob/main/actioncable/CHANGELOG.md
[active-record]:  https://github.com/rails/rails/blob/main/activerecord/CHANGELOG.md
[active-model]:   https://github.com/rails/rails/blob/main/activemodel/CHANGELOG.md
[active-job]:     https://github.com/rails/rails/blob/main/activejob/CHANGELOG.md
[action-text]:    https://github.com/rails/rails/blob/main/actiontext/CHANGELOG.md
[guides]:         https://github.com/rails/rails/blob/main/guides/CHANGELOG.md
[active-storage]: https://github.com/rails/rails/blob/main/activestorage/CHANGELOG.md
[active-support]: https://github.com/rails/rails/blob/main/activesupport/CHANGELOG.md
[action-mailbox]: https://github.com/rails/rails/blob/main/actionmailbox/CHANGELOG.md
