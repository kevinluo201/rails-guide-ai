**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: c7252bf18650c5a9a85fc144305c4615
Notes de version de Ruby on Rails 5.2
========================================

Points forts de Rails 5.2 :

* Active Storage
* Redis Cache Store
* HTTP/2 Early Hints
* Credentials
* Content Security Policy

Ces notes de version ne couvrent que les changements majeurs. Pour en savoir plus sur les corrections de bugs et les modifications, veuillez consulter les journaux des modifications ou consulter la [liste des commits](https://github.com/rails/rails/commits/5-2-stable) dans le référentiel principal de Rails sur GitHub.

--------------------------------------------------------------------------------

Mise à niveau vers Rails 5.2
----------------------------

Si vous mettez à niveau une application existante, il est conseillé d'avoir une bonne couverture de tests avant de commencer. Vous devriez également d'abord passer à Rails 5.1 au cas où vous ne l'auriez pas déjà fait et vous assurer que votre application fonctionne toujours comme prévu avant de tenter une mise à jour vers Rails 5.2. Une liste de choses à surveiller lors de la mise à niveau est disponible dans le guide [Mise à niveau de Ruby on Rails](upgrading_ruby_on_rails.html#upgrading-from-rails-5-1-to-rails-5-2).

Fonctionnalités majeures
------------------------

### Active Storage

[Pull Request](https://github.com/rails/rails/pull/30020)

[Active Storage](https://github.com/rails/rails/tree/5-2-stable/activestorage) facilite le téléchargement de fichiers vers un service de stockage cloud tel que Amazon S3, Google Cloud Storage ou Microsoft Azure Storage et l'attachement de ces fichiers à des objets Active Record. Il est livré avec un service basé sur le disque local pour le développement et les tests et prend en charge la duplication des fichiers vers des services subordonnés pour les sauvegardes et les migrations. Vous pouvez en savoir plus sur Active Storage dans le guide [Présentation d'Active Storage](active_storage_overview.html).

### Redis Cache Store

[Pull Request](https://github.com/rails/rails/pull/31134)

Rails 5.2 est livré avec un Redis cache store intégré. Vous pouvez en savoir plus à ce sujet dans le guide [Mise en cache avec Rails : Aperçu](caching_with_rails.html#activesupport-cache-rediscachestore).

### HTTP/2 Early Hints

[Pull Request](https://github.com/rails/rails/pull/30744)

Rails 5.2 prend en charge [HTTP/2 Early Hints](https://tools.ietf.org/html/rfc8297). Pour démarrer le serveur avec Early Hints activé, passez `--early-hints` à `bin/rails server`.

### Credentials

[Pull Request](https://github.com/rails/rails/pull/30067)

Ajout du fichier `config/credentials.yml.enc` pour stocker les secrets de l'application en production. Cela permet de sauvegarder les informations d'authentification pour les services tiers directement dans le référentiel, chiffrées avec une clé présente dans le fichier `config/master.key` ou la variable d'environnement `RAILS_MASTER_KEY`. Cela remplacera éventuellement `Rails.application.secrets` et les secrets chiffrés introduits dans Rails 5.1. De plus, Rails 5.2 [ouvre l'API sous-jacente des Credentials](https://github.com/rails/rails/pull/30940), vous permettant ainsi de gérer facilement d'autres configurations, clés et fichiers chiffrés. Vous pouvez en savoir plus à ce sujet dans le guide [Sécurisation des applications Rails](security.html#custom-credentials).
### Politique de sécurité du contenu

[Pull Request](https://github.com/rails/rails/pull/31162)

Rails 5.2 est livré avec un nouveau DSL qui vous permet de configurer une
[Politique de sécurité du contenu](https://developer.mozilla.org/fr/docs/Web/HTTP/Headers/Content-Security-Policy)
pour votre application. Vous pouvez configurer une politique par défaut globale, puis
la remplacer pour chaque ressource et même utiliser des lambdas pour injecter des valeurs par requête
dans l'en-tête, telles que les sous-domaines du compte dans une application multi-locataire.
Vous pouvez en savoir plus à ce sujet dans le
[Guide de sécurisation des applications Rails](security.html#content-security-policy).

Railties
--------

Veuillez vous référer au [Changelog][railties] pour des changements détaillés.

### Dépréciations

*   Déprécation de la méthode `capify!` dans les générateurs et les modèles.
    ([Pull Request](https://github.com/rails/rails/pull/29493))

*   Le fait de passer le nom de l'environnement en tant qu'argument normal aux
    commandes `rails dbconsole` et `rails console` est déprécié.
    L'option `-e` doit être utilisée à la place.
    ([Commit](https://github.com/rails/rails/commit/48b249927375465a7102acc71c2dfb8d49af8309))

*   Déprécation de l'utilisation d'une sous-classe de `Rails::Application` pour démarrer le serveur Rails.
    ([Pull Request](https://github.com/rails/rails/pull/30127))

*   Déprécation du rappel `after_bundle` dans les modèles de plugin Rails.
    ([Pull Request](https://github.com/rails/rails/pull/29446))

### Changements notables

*   Ajout d'une section partagée à `config/database.yml` qui sera chargée pour
    tous les environnements.
    ([Pull Request](https://github.com/rails/rails/pull/28896))

*   Ajout de `railtie.rb` au générateur de plugin.
    ([Pull Request](https://github.com/rails/rails/pull/29576))

*   Suppression des fichiers de capture d'écran dans la tâche `tmp:clear`.
    ([Pull Request](https://github.com/rails/rails/pull/29534))

*   Ignorer les composants inutilisés lors de l'exécution de `bin/rails app:update`.
    Si la génération initiale de l'application a ignoré Action Cable, Active Record, etc.,
    la tâche de mise à jour respecte également ces exclusions.
    ([Pull Request](https://github.com/rails/rails/pull/29645))

*   Autoriser le passage d'un nom de connexion personnalisé à la commande `rails dbconsole`
    lors de l'utilisation d'une configuration de base de données à 3 niveaux.
    Exemple : `bin/rails dbconsole -c replica`.
    ([Commit](https://github.com/rails/rails/commit/1acd9a6464668d4d54ab30d016829f60b70dbbeb))

*   Expansion correcte des raccourcis pour le nom de l'environnement lors de l'exécution des commandes `console`
    et `dbconsole`.
    ([Commit](https://github.com/rails/rails/commit/3777701f1380f3814bd5313b225586dec64d4104))

*   Ajout de `bootsnap` au `Gemfile` par défaut.
    ([Pull Request](https://github.com/rails/rails/pull/29313))

*   Prise en charge de `-` comme moyen indépendant de la plateforme pour exécuter un script depuis stdin avec
    `rails runner`
    ([Pull Request](https://github.com/rails/rails/pull/26343))

*   Ajout de la version `ruby x.x.x` au `Gemfile` et création du fichier racine `.ruby-version`
    contenant la version Ruby actuelle lors de la création de nouvelles applications Rails.
    ([Pull Request](https://github.com/rails/rails/pull/30016))

*   Ajout de l'option `--skip-action-cable` au générateur de plugin.
    ([Pull Request](https://github.com/rails/rails/pull/30164))
*   Ajoutez `git_source` à `Gemfile` pour le générateur de plugin.
    ([Demande de tirage](https://github.com/rails/rails/pull/30110))

*   Ignorer les composants inutilisés lors de l'exécution de `bin/rails` dans le plugin Rails.
    ([Commit](https://github.com/rails/rails/commit/62499cb6e088c3bc32a9396322c7473a17a28640))

*   Optimisez l'indentation des actions du générateur.
    ([Demande de tirage](https://github.com/rails/rails/pull/30166))

*   Optimisez l'indentation des routes.
    ([Demande de tirage](https://github.com/rails/rails/pull/30241))

*   Ajoutez l'option `--skip-yarn` au générateur de plugin.
    ([Demande de tirage](https://github.com/rails/rails/pull/30238))

*   Prend en charge plusieurs arguments de versions pour la méthode `gem` des générateurs.
    ([Demande de tirage](https://github.com/rails/rails/pull/30323))

*   Dérivez `secret_key_base` du nom de l'application dans les environnements de développement et de test.
    ([Demande de tirage](https://github.com/rails/rails/pull/30067))

*   Ajoutez `mini_magick` au `Gemfile` par défaut en tant que commentaire.
    ([Demande de tirage](https://github.com/rails/rails/pull/30633))

*   `rails new` et `rails plugin new` obtiennent `Active Storage` par défaut.
    Ajoutez la possibilité de sauter `Active Storage` avec `--skip-active-storage`
    et faites-le automatiquement lorsque `--skip-active-record` est utilisé.
    ([Demande de tirage](https://github.com/rails/rails/pull/30101))

Action Cable
------------

Veuillez vous référer au [journal des modifications][action-cable] pour des changements détaillés.

### Suppressions

*   Suppression de l'adaptateur Redis événementiel obsolète.
    ([Commit](https://github.com/rails/rails/commit/48766e32d31651606b9f68a16015ad05c3b0de2c))

### Changements notables

*   Ajout de la prise en charge des options `host`, `port`, `db` et `password` dans cable.yml
    ([Demande de tirage](https://github.com/rails/rails/pull/29528))

*   Hachage des identifiants de flux longs lors de l'utilisation de l'adaptateur PostgreSQL.
    ([Demande de tirage](https://github.com/rails/rails/pull/29297))

Action Pack
-----------

Veuillez vous référer au [journal des modifications][action-pack] pour des changements détaillés.

### Suppressions

*   Suppression de `ActionController::ParamsParser::ParseError` obsolète.
    ([Commit](https://github.com/rails/rails/commit/e16c765ac6dcff068ff2e5554d69ff345c003de1))

### Dépréciations

*   Dépréciation des alias `#success?`, `#missing?` et `#error?` de
    `ActionDispatch::TestResponse`.
    ([Demande de tirage](https://github.com/rails/rails/pull/30104))

### Changements notables

*   Ajout de la prise en charge des clés de cache recyclables avec le fragment caching.
    ([Demande de tirage](https://github.com/rails/rails/pull/29092))

*   Modification du format de clé de cache pour les fragments pour faciliter le débogage des clés
    ([Demande de tirage](https://github.com/rails/rails/pull/29092))

*   Cookies et sessions chiffrés AEAD avec GCM.
    ([Demande de tirage](https://github.com/rails/rails/pull/28132))

*   Protection contre la falsification par défaut.
    ([Demande de tirage](https://github.com/rails/rails/pull/29742))

*   Expiration des cookies et sessions signés/chiffrés côté serveur.
    ([Demande de tirage](https://github.com/rails/rails/pull/30121))

*   L'option `:expires` des cookies prend en charge l'objet `ActiveSupport::Duration`.
    ([Demande de tirage](https://github.com/rails/rails/pull/30121))

*   Utilisation de la configuration du serveur `:puma` enregistré par Capybara.
    ([Demande de tirage](https://github.com/rails/rails/pull/30638))

*   Simplification du middleware des cookies avec prise en charge de la rotation des clés.
    ([Demande de tirage](https://github.com/rails/rails/pull/29716))

*   Ajout de la possibilité d'activer les Early Hints pour HTTP/2.
    ([Demande de tirage](https://github.com/rails/rails/pull/30744))

*   Ajout de la prise en charge de Chrome sans interface pour les tests système.
    ([Demande de tirage](https://github.com/rails/rails/pull/30876))

*   Ajout de l'option `:allow_other_host` à la méthode `redirect_back`.
    ([Demande de tirage](https://github.com/rails/rails/pull/30850))
*   Faites en sorte que `assert_recognizes` traverse les moteurs montés.
    ([Demande d'extraction](https://github.com/rails/rails/pull/22435))

*   Ajoutez DSL pour configurer l'en-tête Content-Security-Policy.
    ([Demande d'extraction](https://github.com/rails/rails/pull/31162),
    [Commit](https://github.com/rails/rails/commit/619b1b6353a65e1635d10b8f8c6630723a5a6f1a),
    [Commit](https://github.com/rails/rails/commit/4ec8bf68ff92f35e79232fbd605012ce1f4e1e6e))

*   Enregistrez les types MIME audio/vidéo/police les plus populaires pris en charge par les navigateurs modernes.
    ([Demande d'extraction](https://github.com/rails/rails/pull/31251))

*   Modifiez la sortie par défaut de capture d'écran des tests système de `inline` à `simple`.
    ([Commit](https://github.com/rails/rails/commit/9d6e288ee96d6241f864dbf90211c37b14a57632))

*   Ajoutez la prise en charge de Firefox sans interface graphique aux tests système.
    ([Demande d'extraction](https://github.com/rails/rails/pull/31365))

*   Ajoutez les en-têtes sécurisées `X-Download-Options` et `X-Permitted-Cross-Domain-Policies` à l'ensemble des en-têtes par défaut.
    ([Commit](https://github.com/rails/rails/commit/5d7b70f4336d42eabfc403e9f6efceb88b3eff44))

*   Modifiez les tests système pour définir Puma comme serveur par défaut uniquement lorsque l'utilisateur n'a pas spécifié manuellement un autre serveur.
    ([Demande d'extraction](https://github.com/rails/rails/pull/31384))

*   Ajoutez l'en-tête `Referrer-Policy` à l'ensemble des en-têtes par défaut.
    ([Commit](https://github.com/rails/rails/commit/428939be9f954d39b0c41bc53d85d0d106b9d1a1))

*   Correspond au comportement de `Hash#each` dans `ActionController::Parameters#each`.
    ([Demande d'extraction](https://github.com/rails/rails/pull/27790))

*   Ajoutez la prise en charge de la génération automatique de nonce pour Rails UJS.
    ([Commit](https://github.com/rails/rails/commit/b2f0a8945956cd92dec71ec4e44715d764990a49))

*   Mettez à jour la valeur par défaut de max-age de HSTS à 31536000 secondes (1 an) pour répondre à l'exigence de max-age minimale pour https://hstspreload.org/.
    ([Commit](https://github.com/rails/rails/commit/30b5f469a1d30c60d1fb0605e84c50568ff7ed37))

*   Ajoutez la méthode d'alias `to_hash` à `to_h` pour `cookies`.
    Ajoutez la méthode d'alias `to_h` à `to_hash` pour `session`.
    ([Commit](https://github.com/rails/rails/commit/50a62499e41dfffc2903d468e8b47acebaf9b500))

Action View
-----------

Veuillez vous référer au [journal des modifications][action-view] pour des changements détaillés.

### Suppressions

*   Supprimez le gestionnaire ERB Erubis obsolète.
    ([Commit](https://github.com/rails/rails/commit/7de7f12fd140a60134defe7dc55b5a20b2372d06))

### Obsolescence

*   Obsolete l'aide `image_alt` qui ajoutait un texte alt par défaut aux images générées par `image_tag`.
    ([Demande d'extraction](https://github.com/rails/rails/pull/30213))

### Changements notables

*   Ajoutez le type `:json` à `auto_discovery_link_tag` pour prendre en charge les [flux JSON](https://jsonfeed.org/version/1).
    ([Demande d'extraction](https://github.com/rails/rails/pull/29158))

*   Ajoutez l'option `srcset` à l'aide `image_tag`.
    ([Demande d'extraction](https://github.com/rails/rails/pull/29349))

*   Corrigez les problèmes avec `field_error_proc` qui entoure `optgroup` et l'option de séparation `select`.
    ([Demande d'extraction](https://github.com/rails/rails/pull/31088))

*   Changez `form_with` pour générer des identifiants par défaut.
    ([Commit](https://github.com/rails/rails/commit/260d6f112a0ffdbe03e6f5051504cb441c1e94cd))

*   Ajoutez l'aide `preload_link_tag`.
    ([Demande d'extraction](https://github.com/rails/rails/pull/31251))

*   Autorisez l'utilisation d'objets appelables en tant que méthodes de groupe pour les sélections groupées.
    ([Demande d'extraction](https://github.com/rails/rails/pull/31578))

Action Mailer
-------------

Veuillez vous référer au [journal des modifications][action-mailer] pour des changements détaillés.

### Changements notables

*   Permettez aux classes Action Mailer de configurer leur tâche de livraison.
    ([Demande d'extraction](https://github.com/rails/rails/pull/29457))

*   Ajoutez l'aide de test `assert_enqueued_email_with`.
    ([Demande d'extraction](https://github.com/rails/rails/pull/30695))

Active Record
-------------
Veuillez vous référer au [Changelog][active-record] pour obtenir des informations détaillées sur les modifications.

### Suppressions

*   Suppression de `#migration_keys` obsolète.
    ([Pull Request](https://github.com/rails/rails/pull/30337))

*   Suppression du support obsolète de `quoted_id` lors de la conversion de type
    d'un objet Active Record.
    ([Commit](https://github.com/rails/rails/commit/82472b3922bda2f337a79cef961b4760d04f9689))

*   Suppression de l'argument obsolète `default` de `index_name_exists?`.
    ([Commit](https://github.com/rails/rails/commit/8f5b34df81175e30f68879479243fbce966122d7))

*   Suppression du support obsolète de la classe passée à `:class_name`
    dans les associations.
    ([Commit](https://github.com/rails/rails/commit/e65aff70696be52b46ebe57207ebd8bb2cfcdbb6))

*   Suppression des méthodes obsolètes `initialize_schema_migrations_table` et
    `initialize_internal_metadata_table`.
    ([Commit](https://github.com/rails/rails/commit/c9660b5777707658c414b430753029cd9bc39934))

*   Suppression de la méthode obsolète `supports_migrations?`.
    ([Commit](https://github.com/rails/rails/commit/9438c144b1893f2a59ec0924afe4d46bd8d5ffdd))

*   Suppression de la méthode obsolète `supports_primary_key?`.
    ([Commit](https://github.com/rails/rails/commit/c56ff22fc6e97df4656ddc22909d9bf8b0c2cbb1))

*   Suppression de la méthode obsolète
    `ActiveRecord::Migrator.schema_migrations_table_name`.
    ([Commit](https://github.com/rails/rails/commit/7df6e3f3cbdea9a0460ddbab445c81fbb1cfd012))

*   Suppression de l'argument obsolète `name` de `#indexes`.
    ([Commit](https://github.com/rails/rails/commit/d6b779ecebe57f6629352c34bfd6c442ac8fba0e))

*   Suppression des arguments obsolètes de `#verify!`.
    ([Commit](https://github.com/rails/rails/commit/9c6ee1bed0292fc32c23dc1c68951ae64fc510be))

*   Suppression de la configuration obsolète `.error_on_ignored_order_or_limit`.
    ([Commit](https://github.com/rails/rails/commit/e1066f450d1a99c9a0b4d786b202e2ca82a4c3b3))

*   Suppression de la méthode obsolète `#scope_chain`.
    ([Commit](https://github.com/rails/rails/commit/ef7784752c5c5efbe23f62d2bbcc62d4fd8aacab))

*   Suppression de la méthode obsolète `#sanitize_conditions`.
    ([Commit](https://github.com/rails/rails/commit/8f5413b896099f80ef46a97819fe47a820417bc2))

### Dépréciations

*   Dépréciation de `supports_statement_cache?`.
    ([Pull Request](https://github.com/rails/rails/pull/28938))

*   Dépréciation de la possibilité de passer des arguments et un bloc en même temps à
    `count` et `sum` dans `ActiveRecord::Calculations`.
    ([Pull Request](https://github.com/rails/rails/pull/29262))

*   Dépréciation de la délégation à `arel` dans `Relation`.
    ([Pull Request](https://github.com/rails/rails/pull/29619))

*   Dépréciation de la méthode `set_state` dans `TransactionState`.
    ([Commit](https://github.com/rails/rails/commit/608ebccf8f6314c945444b400a37c2d07f21b253))

*   Dépréciation de `expand_hash_conditions_for_aggregates` sans remplacement.
    ([Commit](https://github.com/rails/rails/commit/7ae26885d96daee3809d0bd50b1a440c2f5ffb69))

### Changements notables

*   Lors de l'appel de la méthode d'accès dynamique aux fixtures sans arguments, elle renvoie maintenant
    toutes les fixtures de ce type. Auparavant, cette méthode renvoyait toujours
    un tableau vide.
    ([Pull Request](https://github.com/rails/rails/pull/28692))

*   Correction de l'incohérence avec les attributs modifiés lors de la substitution
    du lecteur d'attributs Active Record.
    ([Pull Request](https://github.com/rails/rails/pull/28661))

*   Prise en charge des index décroissants pour MySQL.
    ([Pull Request](https://github.com/rails/rails/pull/28773))

*   Correction de la première migration de `bin/rails db:forward`.
    ([Commit](https://github.com/rails/rails/commit/b77d2aa0c336492ba33cbfade4964ba0eda3ef84))

*   L'erreur `UnknownMigrationVersionError` est maintenant levée lors du déplacement des migrations
    lorsque la migration actuelle n'existe pas.
    ([Commit](https://github.com/rails/rails/commit/bb9d6eb094f29bb94ef1f26aa44f145f17b973fe))

*   Respect de `SchemaDumper.ignore_tables` dans les tâches rake pour
    la sauvegarde de la structure des bases de données.
    ([Pull Request](https://github.com/rails/rails/pull/29077))

*   Ajout de `ActiveRecord::Base#cache_version` pour prendre en charge les clés de cache réutilisables via
    les nouvelles entrées versionnées dans `ActiveSupport::Cache`. Cela signifie également que
    `ActiveRecord::Base#cache_key` renverra maintenant une clé stable qui
    n'inclut plus de timestamp.
    ([Pull Request](https://github.com/rails/rails/pull/29092))

*   Empêcher la création d'un paramètre de liaison si la valeur convertie est nulle.
    ([Pull Request](https://github.com/rails/rails/pull/29282))

*   Utilisation de l'INSERT groupé pour insérer les fixtures pour de meilleures performances.
    ([Pull Request](https://github.com/rails/rails/pull/29504))
* Fusionner deux relations représentant des jointures imbriquées ne transforme plus les jointures de la relation fusionnée en LEFT OUTER JOIN.
    ([Demande de tirage](https://github.com/rails/rails/pull/27063))

* Corriger les transactions pour appliquer l'état aux transactions enfants.
    Auparavant, si vous aviez une transaction imbriquée et que la transaction externe était annulée, l'enregistrement de la transaction interne était toujours marqué comme persistant. Cela a été corrigé en appliquant l'état de la transaction parent à la transaction enfant lorsque la transaction parent est annulée. Cela marquera correctement les enregistrements de la transaction interne comme non persistants.
    ([Commit](https://github.com/rails/rails/commit/0237da287eb4c507d10a0c6d94150093acc52b03))

* Corriger le chargement précoce/préchargement de l'association avec une portée incluant des jointures.
    ([Demande de tirage](https://github.com/rails/rails/pull/29413))

* Empêcher les erreurs générées par les abonnés aux notifications `sql.active_record` d'être converties en exceptions `ActiveRecord::StatementInvalid`.
    ([Demande de tirage](https://github.com/rails/rails/pull/29692))

* Ignorer la mise en cache des requêtes lors de l'utilisation de lots d'enregistrements (`find_each`, `find_in_batches`, `in_batches`).
    ([Commit](https://github.com/rails/rails/commit/b83852e6eed5789b23b13bac40228e87e8822b4d))

* Modifier la sérialisation des booléens sqlite3 pour utiliser 1 et 0.
    SQLite reconnaît nativement 1 et 0 comme vrai et faux, mais ne reconnaît pas nativement 't' et 'f' comme cela était précédemment sérialisé.
    ([Demande de tirage](https://github.com/rails/rails/pull/29699))

* Les valeurs construites à l'aide d'une affectation multi-paramètres utiliseront désormais la valeur post-type-cast pour le rendu dans les champs de formulaire à champ unique.
    ([Commit](https://github.com/rails/rails/commit/1519e976b224871c7f7dd476351930d5d0d7faf6))

* `ApplicationRecord` n'est plus généré lors de la génération de modèles. Si vous avez besoin de le générer, vous pouvez le créer avec `rails g application_record`.
    ([Demande de tirage](https://github.com/rails/rails/pull/29916))

* `Relation#or` accepte maintenant deux relations qui ont des valeurs différentes pour `references` seulement, car `references` peut être implicitement appelé par `where`.
    ([Commit](https://github.com/rails/rails/commit/ea6139101ccaf8be03b536b1293a9f36bc12f2f7))

* Lors de l'utilisation de `Relation#or`, extraire les conditions communes et les placer avant la condition OR.
    ([Demande de tirage](https://github.com/rails/rails/pull/29950))

* Ajouter la méthode d'aide `binary` pour les fixtures.
    ([Demande de tirage](https://github.com/rails/rails/pull/30073))

* Deviner automatiquement les associations inverses pour STI.
    ([Demande de tirage](https://github.com/rails/rails/pull/23425))

* Ajouter une nouvelle classe d'erreur `LockWaitTimeout` qui sera levée lorsque le délai d'attente du verrou est dépassé.
    ([Demande de tirage](https://github.com/rails/rails/pull/30360))

* Mettre à jour les noms de charge utile pour l'instrumentation `sql.active_record` pour être plus descriptifs.
    ([Demande de tirage](https://github.com/rails/rails/pull/30619))

* Utiliser l'algorithme donné lors de la suppression d'un index de la base de données.
    ([Demande de tirage](https://github.com/rails/rails/pull/24199))
*   Passer un `Set` à `Relation#where` se comporte maintenant de la même manière que passer un tableau.
    ([Commit](https://github.com/rails/rails/commit/9cf7e3494f5bd34f1382c1ff4ea3d811a4972ae2))

*   PostgreSQL `tsrange` préserve désormais la précision des sous-secondes.
    ([Pull Request](https://github.com/rails/rails/pull/30725))

*   Une erreur est levée lors de l'appel à `lock!` sur un enregistrement modifié.
    ([Commit](https://github.com/rails/rails/commit/63cf15877bae859ff7b4ebaf05186f3ca79c1863))

*   Correction d'un bug où les ordres de colonnes pour un index n'étaient pas écrits dans `db/schema.rb` lors de l'utilisation de l'adaptateur SQLite.
    ([Pull Request](https://github.com/rails/rails/pull/30970))

*   Correction de `bin/rails db:migrate` avec `VERSION` spécifié.
    `bin/rails db:migrate` avec `VERSION` vide se comporte comme sans `VERSION`.
    Vérifiez le format de `VERSION` : autorise un numéro de version de migration ou le nom d'un fichier de migration. Une erreur est levée si le format de `VERSION` est invalide.
    Une erreur est levée si la migration cible n'existe pas.
    ([Pull Request](https://github.com/rails/rails/pull/30714))

*   Ajout d'une nouvelle classe d'erreur `StatementTimeout` qui sera levée lorsque le délai d'exécution de la requête est dépassé.
    ([Pull Request](https://github.com/rails/rails/pull/31129))

*   `update_all` transmet maintenant ses valeurs à `Type#cast` avant de les transmettre à `Type#serialize`. Cela signifie que `update_all(foo: 'true')` persiste correctement un booléen.
    ([Commit](https://github.com/rails/rails/commit/68fe6b08ee72cc47263e0d2c9ff07f75c4b42761))

*   Les fragments SQL bruts doivent être explicitement marqués lorsqu'ils sont utilisés dans les méthodes de requête de relation.
    ([Commit](https://github.com/rails/rails/commit/a1ee43d2170dd6adf5a9f390df2b1dde45018a48),
    [Commit](https://github.com/rails/rails/commit/e4a921a75f8702a7dbaf41e31130fe884dea93f9))

*   Ajout de `#up_only` aux migrations de base de données pour le code qui n'est pertinent que lors de la migration ascendante, par exemple, la population d'une nouvelle colonne.
    ([Pull Request](https://github.com/rails/rails/pull/31082))

*   Ajout d'une nouvelle classe d'erreur `QueryCanceled` qui sera levée lors de l'annulation de la requête suite à une demande de l'utilisateur.
    ([Pull Request](https://github.com/rails/rails/pull/31235))

*   Les scopes ne peuvent pas être définis en conflit avec les méthodes d'instance sur `Relation`.
    ([Pull Request](https://github.com/rails/rails/pull/31179))

*   Ajout de la prise en charge des classes d'opérateurs PostgreSQL à `add_index`.
    ([Pull Request](https://github.com/rails/rails/pull/19090))

*   Enregistrement des appelants des requêtes de base de données.
    ([Pull Request](https://github.com/rails/rails/pull/26815),
    [Pull Request](https://github.com/rails/rails/pull/31519),
    [Pull Request](https://github.com/rails/rails/pull/31690))

*   Annulation des méthodes d'attribut sur les descendants lors de la réinitialisation des informations de colonne.
    ([Pull Request](https://github.com/rails/rails/pull/31475))

*   Utilisation d'un sous-sélecteur pour `delete_all` avec `limit` ou `offset`.
    ([Commit](https://github.com/rails/rails/commit/9e7260da1bdc0770cf4ac547120c85ab93ff3d48))

*   Correction d'une incohérence avec `first(n)` lorsqu'il est utilisé avec `limit()`.
    Le chercheur `first(n)` respecte désormais `limit()`, ce qui le rend cohérent avec `relation.to_a.first(n)`, et également avec le comportement de `last(n)`.
    ([Pull Request](https://github.com/rails/rails/pull/27597))

*   Correction des associations `has_many :through` imbriquées sur des instances parent non persistées.
    ([Commit](https://github.com/rails/rails/commit/027f865fc8b262d9ba3ee51da3483e94a5489b66))
*   Prendre en compte les conditions d'association lors de la suppression à travers les enregistrements.
    ([Commit](https://github.com/rails/rails/commit/ae48c65e411e01c1045056562319666384bb1b63))

*   Ne pas autoriser la mutation de l'objet détruit après l'appel à `save` ou `save!`.
    ([Commit](https://github.com/rails/rails/commit/562dd0494a90d9d47849f052e8913f0050f3e494))

*   Résoudre le problème de fusion de relation avec `left_outer_joins`.
    ([Pull Request](https://github.com/rails/rails/pull/27860))

*   Support des tables étrangères PostgreSQL.
    ([Pull Request](https://github.com/rails/rails/pull/31549))

*   Réinitialiser l'état de la transaction lorsqu'un objet Active Record est dupliqué.
    ([Pull Request](https://github.com/rails/rails/pull/31751))

*   Résoudre le problème de non-expansion lors du passage d'un objet Array en argument
    à la méthode where en utilisant une colonne `composed_of`.
    ([Pull Request](https://github.com/rails/rails/pull/31724))

*   Faire en sorte que `reflection.klass` lève une exception si `polymorphic?` n'est pas utilisé correctement.
    ([Commit](https://github.com/rails/rails/commit/63fc1100ce054e3e11c04a547cdb9387cd79571a))

*   Résoudre `#columns_for_distinct` de MySQL et PostgreSQL pour que
    `ActiveRecord::FinderMethods#limited_ids_for` utilise les valeurs de clé primaire correctes
    même si les colonnes `ORDER BY` incluent la clé primaire d'une autre table.
    ([Commit](https://github.com/rails/rails/commit/851618c15750979a75635530200665b543561a44))

*   Résoudre le problème de `dependent: :destroy` pour la relation has_one/belongs_to où
    la classe parent était supprimée lorsque l'enfant ne l'était pas.
    ([Commit](https://github.com/rails/rails/commit/b0fc04aa3af338d5a90608bf37248668d59fc881))

*   Les connexions inactives de la base de données (précédemment uniquement les connexions orphelines) sont maintenant
    périodiquement supprimées par le récupérateur du pool de connexions.
    ([Commit](https://github.com/rails/rails/pull/31221/commits/9027fafff6da932e6e64ddb828665f4b01fc8902))

Active Model
------------

Veuillez vous référer au [journal des modifications][active-model] pour des changements détaillés.

### Changements notables

*   Résoudre les méthodes `#keys`, `#values` dans `ActiveModel::Errors`.
    Modifier `#keys` pour ne renvoyer que les clés qui n'ont pas de messages vides.
    Modifier `#values` pour ne renvoyer que les valeurs non vides.
    ([Pull Request](https://github.com/rails/rails/pull/28584))

*   Ajouter la méthode `#merge!` pour `ActiveModel::Errors`.
    ([Pull Request](https://github.com/rails/rails/pull/29714))

*   Autoriser le passage d'un Proc ou d'un symbole aux options du validateur de longueur.
    ([Pull Request](https://github.com/rails/rails/pull/30674))

*   Exécuter la validation de `ConfirmationValidator` lorsque la valeur de `_confirmation`
    est `false`.
    ([Pull Request](https://github.com/rails/rails/pull/31058))

*   Les modèles utilisant l'API des attributs avec une valeur par défaut de type proc peuvent maintenant être sérialisés.
    ([Commit](https://github.com/rails/rails/commit/0af36c62a5710e023402e37b019ad9982e69de4b))

*   Ne pas perdre toutes les multiples `:includes` avec des options lors de la sérialisation.
    ([Commit](https://github.com/rails/rails/commit/853054bcc7a043eea78c97e7705a46abb603cc44))

Active Support
--------------

Veuillez vous référer au [journal des modifications][active-support] pour des changements détaillés.

### Suppressions

*   Supprimer le filtre de chaîne `:if` et `:unless` déprécié pour les rappels.
    ([Commit](https://github.com/rails/rails/commit/c792354adcbf8c966f274915c605c6713b840548))

*   Supprimer l'option dépréciée `halt_callback_chains_on_return_false`.
    ([Commit](https://github.com/rails/rails/commit/19fbbebb1665e482d76cae30166b46e74ceafe29))

### Dépréciations

*   Déprécier la méthode `Module#reachable?`.
    ([Pull Request](https://github.com/rails/rails/pull/30624))

*   Déprécier `secrets.secret_token`.
    ([Commit](https://github.com/rails/rails/commit/fbcc4bfe9a211e219da5d0bb01d894fcdaef0a0e))

### Changements notables

*   Ajouter `fetch_values` pour `HashWithIndifferentAccess`.
    ([Pull Request](https://github.com/rails/rails/pull/28316))

[active-model]: https://github.com/rails/rails/blob/master/activemodel/CHANGELOG.md
[active-support]: https://github.com/rails/rails/blob/master/activesupport/CHANGELOG.md
*   Ajouter la prise en charge de `:offset` à `Time#change`.
    ([Commit](https://github.com/rails/rails/commit/851b7f866e13518d900407c78dcd6eb477afad06))

*   Ajouter la prise en charge de `:offset` et `:zone`
    à `ActiveSupport::TimeWithZone#change`.
    ([Commit](https://github.com/rails/rails/commit/851b7f866e13518d900407c78dcd6eb477afad06))

*   Transmettre le nom du gem et l'horizon de dépréciation aux notifications de dépréciation.
    ([Pull Request](https://github.com/rails/rails/pull/28800))

*   Ajouter la prise en charge des entrées de cache versionnées. Cela permet aux magasins de cache de
    recycler les clés de cache, ce qui permet de réaliser d'importantes économies de stockage dans les cas de changement fréquent.
    Fonctionne en conjonction avec la séparation de `#cache_key` et `#cache_version`
    dans Active Record et son utilisation dans le fragment caching d'Action Pack.
    ([Pull Request](https://github.com/rails/rails/pull/29092))

*   Ajouter `ActiveSupport::CurrentAttributes` pour fournir un singleton d'attributs isolé par thread.
    Le cas d'utilisation principal est de rendre tous les attributs par requête facilement disponibles pour l'ensemble du système.
    ([Pull Request](https://github.com/rails/rails/pull/29180))

*   `#singularize` et `#pluralize` respectent maintenant les mots non dénombrables pour
    la locale spécifiée.
    ([Commit](https://github.com/rails/rails/commit/352865d0f835c24daa9a2e9863dcc9dde9e5371a))

*   Ajouter l'option par défaut à `class_attribute`.
    ([Pull Request](https://github.com/rails/rails/pull/29270))

*   Ajouter `Date#prev_occurring` et `Date#next_occurring` pour retourner
    le jour de la semaine précédent/suivant spécifié.
    ([Pull Request](https://github.com/rails/rails/pull/26600))

*   Ajouter l'option par défaut aux accesseurs d'attributs de module et de classe.
    ([Pull Request](https://github.com/rails/rails/pull/29294))

*   Cache : `write_multi`.
    ([Pull Request](https://github.com/rails/rails/pull/29366))

*   Par défaut, `ActiveSupport::MessageEncryptor` utilise le chiffrement AES 256 GCM.
    ([Pull Request](https://github.com/rails/rails/pull/29263))

*   Ajouter l'aide `freeze_time` qui fige l'heure à `Time.now` dans les tests.
    ([Pull Request](https://github.com/rails/rails/pull/29681))

*   Rendre l'ordre de `Hash#reverse_merge!` cohérent
    avec `HashWithIndifferentAccess`.
    ([Pull Request](https://github.com/rails/rails/pull/28077))

*   Ajouter la prise en charge de l'objectif et de l'expiration à `ActiveSupport::MessageVerifier` et
    `ActiveSupport::MessageEncryptor`.
    ([Pull Request](https://github.com/rails/rails/pull/29892))

*   Mettre à jour `String#camelize` pour fournir un retour lorsque l'option incorrecte est passée.
    ([Pull Request](https://github.com/rails/rails/pull/30039))

*   `Module#delegate_missing_to` lève maintenant une `DelegationError` si la cible est nulle,
    similaire à `Module#delegate`.
    ([Pull Request](https://github.com/rails/rails/pull/30191))

*   Ajouter `ActiveSupport::EncryptedFile` et
    `ActiveSupport::EncryptedConfiguration`.
    ([Pull Request](https://github.com/rails/rails/pull/30067))

*   Ajouter `config/credentials.yml.enc` pour stocker les secrets de l'application en production.
    ([Pull Request](https://github.com/rails/rails/pull/30067))

*   Ajouter la prise en charge de la rotation des clés à `MessageEncryptor` et `MessageVerifier`.
    ([Pull Request](https://github.com/rails/rails/pull/29716))

*   Renvoyer une instance de `HashWithIndifferentAccess` à partir de
    `HashWithIndifferentAccess#transform_keys`.
    ([Pull Request](https://github.com/rails/rails/pull/30728))

*   `Hash#slice` utilise maintenant la définition intégrée de Ruby 2.5+ si elle est définie.
    ([Commit](https://github.com/rails/rails/commit/01ae39660243bc5f0a986e20f9c9bff312b1b5f8))

*   `IO#to_json` renvoie maintenant la représentation `to_s`, plutôt que
    d'essayer de convertir en un tableau. Cela corrige un bogue où `IO#to_json`
    lèverait une `IOError` lorsqu'il est appelé sur un objet non lisible.
    ([Pull Request](https://github.com/rails/rails/pull/30953))
* Ajouter la même signature de méthode pour `Time#prev_day` et `Time#next_day` conformément à `Date#prev_day` et `Date#next_day`. Permet de passer un argument pour `Time#prev_day` et `Time#next_day`. ([Commit](https://github.com/rails/rails/commit/61ac2167eff741bffb44aec231f4ea13d004134e))

* Ajouter la même signature de méthode pour `Time#prev_month` et `Time#next_month` conformément à `Date#prev_month` et `Date#next_month`. Permet de passer un argument pour `Time#prev_month` et `Time#next_month`. ([Commit](https://github.com/rails/rails/commit/f2c1e3a793570584d9708aaee387214bc3543530))

* Ajouter la même signature de méthode pour `Time#prev_year` et `Time#next_year` conformément à `Date#prev_year` et `Date#next_year`. Permet de passer un argument pour `Time#prev_year` et `Time#next_year`. ([Commit](https://github.com/rails/rails/commit/ee9d81837b5eba9d5ec869ae7601d7ffce763e3e))

* Corriger la prise en charge des acronymes dans `humanize`. ([Commit](https://github.com/rails/rails/commit/0ddde0a8fca6a0ca3158e3329713959acd65605d))

* Autoriser `Range#include?` sur les plages TWZ. ([Pull Request](https://github.com/rails/rails/pull/31081))

* Cache : Activer la compression par défaut pour les valeurs supérieures à 1 ko. ([Pull Request](https://github.com/rails/rails/pull/31147))

* Redis cache store. ([Pull Request](https://github.com/rails/rails/pull/31134), [Pull Request](https://github.com/rails/rails/pull/31866))

* Gérer les erreurs `TZInfo::AmbiguousTime`. ([Pull Request](https://github.com/rails/rails/pull/31128))

* MemCacheStore : Prise en charge de l'expiration des compteurs. ([Commit](https://github.com/rails/rails/commit/b22ee64b5b30c6d5039c292235e10b24b1057f6d))

* Faire en sorte que `ActiveSupport::TimeZone.all` ne renvoie que les fuseaux horaires présents dans `ActiveSupport::TimeZone::MAPPING`. ([Pull Request](https://github.com/rails/rails/pull/31176))

* Modifier le comportement par défaut de `ActiveSupport::SecurityUtils.secure_compare` pour ne pas divulguer les informations de longueur même pour les chaînes de longueur variable. Renommer l'ancienne méthode `ActiveSupport::SecurityUtils.secure_compare` en `fixed_length_secure_compare` et commencer à lever une `ArgumentError` en cas de différence de longueur entre les chaînes passées. ([Pull Request](https://github.com/rails/rails/pull/24510))

* Utiliser SHA-1 pour générer des hachages non sensibles, tels que l'en-tête ETag. ([Pull Request](https://github.com/rails/rails/pull/31289), [Pull Request](https://github.com/rails/rails/pull/31651))

* `assert_changes` vérifiera toujours que l'expression change, indépendamment des combinaisons d'arguments `from:` et `to:`. ([Pull Request](https://github.com/rails/rails/pull/31011))

* Ajouter l'instrumentation manquante pour `read_multi` dans `ActiveSupport::Cache::Store`. ([Pull Request](https://github.com/rails/rails/pull/30268))

* Prise en charge d'un hachage en tant que premier argument dans `assert_difference`. Cela permet de spécifier plusieurs différences numériques dans la même assertion. ([Pull Request](https://github.com/rails/rails/pull/31600))

* Caching : Accélérer `read_multi` et `fetch_multi` pour MemCache et Redis. Lire dans le cache local en mémoire avant de consulter le backend. ([Commit](https://github.com/rails/rails/commit/a2b97e4ffef971607a1be8fc7909f099b6840f36))

Active Job
----------

Veuillez vous référer au [journal des modifications][active-job] pour des détails sur les changements.

### Changements notables

* Autoriser le passage d'un bloc à `ActiveJob::Base.discard_on` pour permettre une gestion personnalisée des jobs à supprimer. ([Pull Request](https://github.com/rails/rails/pull/30622))

Ruby on Rails Guides
--------------------

Veuillez vous référer au [journal des modifications][guides] pour des détails sur les changements.

### Changements notables

* Ajouter le guide [Threading and Code Execution in Rails](threading_and_code_execution.html). ([Pull Request](https://github.com/rails/rails/pull/27494))
*   Ajouter le guide [Présentation d'Active Storage](active_storage_overview.html).
    ([Demande de tirage](https://github.com/rails/rails/pull/31037))

Crédits
-------

Consultez la
[liste complète des contributeurs à Rails](https://contributors.rubyonrails.org/)
pour les nombreuses personnes qui ont passé de nombreuses heures à faire de Rails, le framework stable et robuste qu'il est. Bravo à tous.

[railties]:       https://github.com/rails/rails/blob/5-2-stable/railties/CHANGELOG.md
[action-pack]:    https://github.com/rails/rails/blob/5-2-stable/actionpack/CHANGELOG.md
[action-view]:    https://github.com/rails/rails/blob/5-2-stable/actionview/CHANGELOG.md
[action-mailer]:  https://github.com/rails/rails/blob/5-2-stable/actionmailer/CHANGELOG.md
[action-cable]:   https://github.com/rails/rails/blob/5-2-stable/actioncable/CHANGELOG.md
[active-record]:  https://github.com/rails/rails/blob/5-2-stable/activerecord/CHANGELOG.md
[active-model]:   https://github.com/rails/rails/blob/5-2-stable/activemodel/CHANGELOG.md
[active-job]:     https://github.com/rails/rails/blob/5-2-stable/activejob/CHANGELOG.md
[guides]:         https://github.com/rails/rails/blob/5-2-stable/guides/CHANGELOG.md
[active-support]: https://github.com/rails/rails/blob/5-2-stable/activesupport/CHANGELOG.md
