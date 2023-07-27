**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: df23e2b31bd56973a30f38f5a1c29b52
Ruby on Rails 5.0 Notes de version
==================================

Points forts de Rails 5.0 :

* Action Cable
* Rails API
* API des attributs Active Record
* Test Runner
* Utilisation exclusive de la CLI `rails` plutôt que Rake
* Sprockets 3
* Turbolinks 5
* Nécessite Ruby 2.2.2+

Ces notes de version ne couvrent que les changements majeurs. Pour en savoir plus sur les corrections de bugs et les changements divers, veuillez consulter les journaux des modifications ou consulter la [liste des commits](https://github.com/rails/rails/commits/5-0-stable) dans le référentiel principal de Rails sur GitHub.

--------------------------------------------------------------------------------

Mise à niveau vers Rails 5.0
---------------------------

Si vous mettez à niveau une application existante, il est conseillé d'avoir une bonne couverture de tests avant de commencer. Vous devriez également d'abord passer à Rails 4.2 au cas où vous ne l'auriez pas déjà fait et vous assurer que votre application fonctionne toujours comme prévu avant de tenter une mise à jour vers Rails 5.0. Une liste de choses à surveiller lors de la mise à niveau est disponible dans le guide [Mise à niveau de Ruby on Rails](upgrading_ruby_on_rails.html#upgrading-from-rails-4-2-to-rails-5-0).

Fonctionnalités majeures
------------------------

### Action Cable

Action Cable est un nouveau framework dans Rails 5. Il intègre de manière transparente les [WebSockets](https://en.wikipedia.org/wiki/WebSocket) avec le reste de votre application Rails.

Action Cable permet d'écrire des fonctionnalités en temps réel en Ruby dans le même style et la même forme que le reste de votre application Rails, tout en étant performant et scalable. C'est une offre complète qui fournit à la fois un framework JavaScript côté client et un framework Ruby côté serveur. Vous avez accès à votre modèle de domaine complet écrit avec Active Record ou votre ORM de choix.

Consultez le guide [Présentation d'Action Cable](action_cable_overview.html) pour plus d'informations.

### Applications API

Rails peut maintenant être utilisé pour créer des applications API allégées. Cela est utile pour créer et servir des API similaires à celles de [Twitter](https://dev.twitter.com) ou de l'API [GitHub](https://developer.github.com), qui peuvent être utilisées pour des applications publiques ainsi que pour des applications personnalisées.

Vous pouvez générer une nouvelle application Rails API en utilisant la commande :

```bash
$ rails new my_api --api
```
Cela fera trois choses principales :

- Configurer votre application pour démarrer avec un ensemble de middleware plus limité que d'habitude. Plus précisément, il n'inclura pas par défaut de middleware principalement utile pour les applications de navigateur (comme la prise en charge des cookies).
- Faire en sorte que `ApplicationController` hérite de `ActionController::API` au lieu de `ActionController::Base`. Comme pour le middleware, cela exclura tous les modules Action Controller qui fournissent des fonctionnalités principalement utilisées par les applications de navigateur.
- Configurer les générateurs pour ignorer la génération de vues, d'aides et de ressources lors de la génération d'une nouvelle ressource.

L'application fournit une base pour les API, qui peuvent ensuite être [configurées pour intégrer des fonctionnalités](api_app.html) adaptées aux besoins de l'application.

Consultez le guide [Utiliser Rails pour les applications API uniquement](api_app.html) pour plus d'informations.

### API des attributs Active Record

Définit un attribut avec un type sur un modèle. Il remplacera le type des attributs existants si nécessaire.
Cela permet de contrôler la façon dont les valeurs sont converties en SQL et vice versa lorsqu'elles sont assignées à un modèle.
Cela modifie également le comportement des valeurs passées à `ActiveRecord::Base.where`, ce qui nous permet d'utiliser nos objets de domaine dans une grande partie d'Active Record, sans avoir à dépendre des détails de l'implémentation ou à utiliser des patchs.

Voici quelques choses que vous pouvez réaliser avec cela :

- Le type détecté par Active Record peut être remplacé.
- Une valeur par défaut peut également être fournie.
- Les attributs n'ont pas besoin d'être soutenus par une colonne de base de données.

```ruby
# db/schema.rb
create_table :store_listings, force: true do |t|
  t.decimal :price_in_cents
  t.string :my_string, default: "original default"
end
```

```ruby
# app/models/store_listing.rb
class StoreListing < ActiveRecord::Base
end
```

```ruby
store_listing = StoreListing.new(price_in_cents: '10.1')

# avant
store_listing.price_in_cents # => BigDecimal.new(10.1)
StoreListing.new.my_string # => "original default"

class StoreListing < ActiveRecord::Base
  attribute :price_in_cents, :integer # type personnalisé
  attribute :my_string, :string, default: "new default" # valeur par défaut
  attribute :my_default_proc, :datetime, default: -> { Time.now } # valeur par défaut
  attribute :field_without_db_column, :integer, array: true
end

# après
store_listing.price_in_cents # => 10
StoreListing.new.my_string # => "new default"
StoreListing.new.my_default_proc # => 2015-05-30 11:04:48 -0600
model = StoreListing.new(field_without_db_column: ["1", "2", "3"])
model.attributes # => {field_without_db_column: [1, 2, 3]}
```
**Création de types personnalisés:**

Vous pouvez définir vos propres types personnalisés, tant qu'ils répondent
aux méthodes définies sur le type de valeur. La méthode `deserialize` ou
`cast` sera appelée sur votre objet de type, avec une entrée brute provenant de la
base de données ou de vos contrôleurs. Cela est utile, par exemple, lors de la conversion personnalisée,
comme les données Money.

**Interrogation:**

Lorsque `ActiveRecord::Base.where` est appelé, il utilisera
le type défini par la classe modèle pour convertir la valeur en SQL,
en appelant `serialize` sur votre objet de type.

Cela donne aux objets la capacité de spécifier comment convertir les valeurs lors de l'exécution de requêtes SQL.

**Suivi des modifications:**

Le type d'un attribut est autorisé à modifier la façon dont le suivi des modifications est effectué.

Consultez sa
[documentation](https://api.rubyonrails.org/v5.0.1/classes/ActiveRecord/Attributes/ClassMethods.html)
pour plus de détails.

### Test Runner

Un nouveau test runner a été introduit pour améliorer les capacités d'exécution des tests dans Rails.
Pour utiliser ce test runner, tapez simplement `bin/rails test`.

Le Test Runner s'inspire de `RSpec`, `minitest-reporters`, `maxitest` et d'autres.
Il inclut certaines de ces avancées notables :

- Exécute un seul test en utilisant le numéro de ligne du test.
- Exécute plusieurs tests en indiquant le numéro de ligne des tests.
- Amélioration des messages d'échec, qui facilitent également la réexécution des tests échoués.
- Arrêt rapide en utilisant l'option `-f`, pour arrêter immédiatement les tests en cas d'échec,
au lieu d'attendre la fin de la suite.
- Reporte la sortie des tests jusqu'à la fin de l'exécution complète des tests en utilisant l'option `-d`.
- Affiche la trace complète des exceptions en utilisant l'option `-b`.
- Intégration avec minitest pour permettre des options comme `-s` pour les données de test seed,
`-n` pour exécuter un test spécifique par nom, `-v` pour une sortie verbeuse améliorée, etc.
- Sortie colorée des tests.

Railties
--------

Veuillez vous référer au [Changelog][railties] pour des changements détaillés.

### Suppressions

*   Suppression de la prise en charge du débogueur, utilisez plutôt byebug. `debugger` n'est pas pris en charge par
    Ruby
    2.2. ([commit](https://github.com/rails/rails/commit/93559da4826546d07014f8cfa399b64b4a143127))
*   Suppression des tâches obsolètes `test:all` et `test:all:db`.
    ([commit](https://github.com/rails/rails/commit/f663132eef0e5d96bf2a58cec9f7c856db20be7c))

*   Suppression de `Rails::Rack::LogTailer` obsolète.
    ([commit](https://github.com/rails/rails/commit/c564dcb75c191ab3d21cc6f920998b0d6fbca623))

*   Suppression de la constante `RAILS_CACHE` obsolète.
    ([commit](https://github.com/rails/rails/commit/b7f856ce488ef8f6bf4c12bb549f462cb7671c08))

*   Suppression de la configuration `serve_static_assets` obsolète.
    ([commit](https://github.com/rails/rails/commit/463b5d7581ee16bfaddf34ca349b7d1b5878097c))

*   Suppression des tâches de documentation `doc:app`, `doc:rails` et `doc:guides`.
    ([commit](https://github.com/rails/rails/commit/cd7cc5254b090ccbb84dcee4408a5acede25ef2a))

*   Suppression du middleware `Rack::ContentLength` de la pile par défaut.
    ([Commit](https://github.com/rails/rails/commit/56903585a099ab67a7acfaaef0a02db8fe80c450))

### Dépréciations

*   `config.static_cache_control` est déprécié au profit de `config.public_file_server.headers`.
    ([Pull Request](https://github.com/rails/rails/pull/19135))

*   `config.serve_static_files` est déprécié au profit de `config.public_file_server.enabled`.
    ([Pull Request](https://github.com/rails/rails/pull/22173))

*   Les tâches de l'espace de noms `rails` sont dépréciées au profit de l'espace de noms `app`.
    (par exemple, les tâches `rails:update` et `rails:template` sont renommées `app:update` et `app:template`.)
    ([Pull Request](https://github.com/rails/rails/pull/23439))

### Changements notables

*   Ajout de l'exécuteur de tests Rails `bin/rails test`.
    ([Pull Request](https://github.com/rails/rails/pull/19216))

*   Les nouvelles applications et plugins générés obtiennent un fichier `README.md` en Markdown.
    ([commit](https://github.com/rails/rails/commit/89a12c931b1f00b90e74afffcdc2fc21f14ca663),
     [Pull Request](https://github.com/rails/rails/pull/22068))

*   Ajout de la tâche `bin/rails restart` pour redémarrer votre application Rails en touchant `tmp/restart.txt`.
    ([Pull Request](https://github.com/rails/rails/pull/18965))

*   Ajout de la tâche `bin/rails initializers` pour afficher tous les initializers définis
    dans l'ordre où ils sont invoqués par Rails.
    ([Pull Request](https://github.com/rails/rails/pull/19323))

*   Ajout de la tâche `bin/rails dev:cache` pour activer ou désactiver le cache en mode développement.
    ([Pull Request](https://github.com/rails/rails/pull/20961))

*   Ajout du script `bin/update` pour mettre à jour l'environnement de développement automatiquement.
    ([Pull Request](https://github.com/rails/rails/pull/20972))

*   Proxy des tâches Rake via `bin/rails`.
    ([Pull Request](https://github.com/rails/rails/pull/22457),
     [Pull Request](https://github.com/rails/rails/pull/22288))

*   Les nouvelles applications sont générées avec le moniteur de système de fichiers événementiel activé
    sur Linux et macOS. Cette fonctionnalité peut être désactivée en passant
    `--skip-listen` au générateur.
    ([commit](https://github.com/rails/rails/commit/de6ad5665d2679944a9ee9407826ba88395a1003),
    [commit](https://github.com/rails/rails/commit/94dbc48887bf39c241ee2ce1741ee680d773f202))

*   Génération d'applications avec une option pour enregistrer les journaux sur STDOUT en production
    en utilisant la variable d'environnement `RAILS_LOG_TO_STDOUT`.
    ([Pull Request](https://github.com/rails/rails/pull/23734))

*   Activation de HSTS avec l'en-tête IncludeSubdomains pour les nouvelles applications.
    ([Pull Request](https://github.com/rails/rails/pull/23852))

*   Le générateur d'application écrit un nouveau fichier `config/spring.rb`, qui indique
    à Spring de surveiller des fichiers communs supplémentaires.
    ([commit](https://github.com/rails/rails/commit/b04d07337fd7bc17e88500e9d6bcd361885a45f8))

*   Ajout de `--skip-action-mailer` pour ignorer Action Mailer lors de la génération d'une nouvelle application.
    ([Pull Request](https://github.com/rails/rails/pull/18288))

*   Suppression du répertoire `tmp/sessions` et de la tâche rake de nettoyage associée.
    ([Pull Request](https://github.com/rails/rails/pull/18314))

*   Modification de `_form.html.erb` généré par le générateur de scaffold pour utiliser des variables locales.
    ([Pull Request](https://github.com/rails/rails/pull/13434))
*   Désactivation du chargement automatique des classes en environnement de production.
    ([commit](https://github.com/rails/rails/commit/a71350cae0082193ad8c66d65ab62e8bb0b7853b))

Action Pack
-----------

Veuillez vous référer au [journal des modifications][action-pack] pour des détails sur les changements.

### Suppressions

*   Suppression de `ActionDispatch::Request::Utils.deep_munge`.
    ([commit](https://github.com/rails/rails/commit/52cf1a71b393486435fab4386a8663b146608996))

*   Suppression de `ActionController::HideActions`.
    ([Pull Request](https://github.com/rails/rails/pull/18371))

*   Suppression des méthodes de substitution `respond_to` et `respond_with`, cette fonctionnalité
    a été extraite dans la gemme
    [responders](https://github.com/plataformatec/responders).
    ([commit](https://github.com/rails/rails/commit/afd5e9a7ff0072e482b0b0e8e238d21b070b6280))

*   Suppression des fichiers d'assertion obsolètes.
    ([commit](https://github.com/rails/rails/commit/92e27d30d8112962ee068f7b14aa7b10daf0c976))

*   Suppression de l'utilisation obsolète de clés de chaîne dans les aides d'URL.
    ([commit](https://github.com/rails/rails/commit/34e380764edede47f7ebe0c7671d6f9c9dc7e809))

*   Suppression de l'option obsolète `only_path` sur les aides `*_path`.
    ([commit](https://github.com/rails/rails/commit/e4e1fd7ade47771067177254cb133564a3422b8a))

*   Suppression de l'option obsolète `NamedRouteCollection#helpers`.
    ([commit](https://github.com/rails/rails/commit/2cc91c37bc2e32b7a04b2d782fb8f4a69a14503f))

*   Suppression du support obsolète pour définir des routes avec l'option `:to` qui ne contient pas `#`.
    ([commit](https://github.com/rails/rails/commit/1f3b0a8609c00278b9a10076040ac9c90a9cc4a6))

*   Suppression de `ActionDispatch::Response#to_ary` obsolète.
    ([commit](https://github.com/rails/rails/commit/4b19d5b7bcdf4f11bd1e2e9ed2149a958e338c01))

*   Suppression de `ActionDispatch::Request#deep_munge` obsolète.
    ([commit](https://github.com/rails/rails/commit/7676659633057dacd97b8da66e0d9119809b343e))

*   Suppression de `ActionDispatch::Http::Parameters#symbolized_path_parameters` obsolète.
    ([commit](https://github.com/rails/rails/commit/7fe7973cd8bd119b724d72c5f617cf94c18edf9e))

*   Suppression de l'option obsolète `use_route` dans les tests de contrôleur.
    ([commit](https://github.com/rails/rails/commit/e4cfd353a47369dd32198b0e67b8cbb2f9a1c548))

*   Suppression de `assigns` et `assert_template`. Les deux méthodes ont été extraites
    dans la gemme
    [rails-controller-testing](https://github.com/rails/rails-controller-testing).
    ([Pull Request](https://github.com/rails/rails/pull/20138))

### Dépréciations

*   Dépréciation de tous les rappels `*_filter` au profit des rappels `*_action`.
    ([Pull Request](https://github.com/rails/rails/pull/18410))

*   Dépréciation des méthodes de test d'intégration `*_via_redirect`. Utilisez `follow_redirect!`
    manuellement après l'appel de la requête pour le même comportement.
    ([Pull Request](https://github.com/rails/rails/pull/18693))

*   Dépréciation de `AbstractController#skip_action_callback` au profit de méthodes de saut de rappel individuelles.
    ([Pull Request](https://github.com/rails/rails/pull/19060))

*   Dépréciation de l'option `:nothing` pour la méthode `render`.
    ([Pull Request](https://github.com/rails/rails/pull/20336))

*   Dépréciation du passage du premier paramètre en tant que `Hash` et du code d'état par défaut pour
    la méthode `head`.
    ([Pull Request](https://github.com/rails/rails/pull/20407))

*   Dépréciation de l'utilisation de chaînes ou de symboles pour les noms de classe de middleware. Utilisez plutôt les noms de classe.
    ([commit](https://github.com/rails/rails/commit/83b767ce))

*   Dépréciation de l'accès aux types MIME via des constantes (par exemple, `Mime::HTML`). Utilisez l'opérateur de crochet avec un symbole à la place (par exemple, `Mime[:html]`).
    ([Pull Request](https://github.com/rails/rails/pull/21869))

*   Dépréciation de `redirect_to :back` au profit de `redirect_back`, qui accepte un
    argument `fallback_location` requis, éliminant ainsi la possibilité d'une
    `RedirectBackError`.
    ([Pull Request](https://github.com/rails/rails/pull/22506))

*   `ActionDispatch::IntegrationTest` et `ActionController::TestCase` déprécient les arguments positionnels au profit des arguments nommés.
    ([Pull Request](https://github.com/rails/rails/pull/18323))

*   Dépréciation des paramètres de chemin `:controller` et `:action`.
    ([Pull Request](https://github.com/rails/rails/pull/23980))

*   Dépréciation de la méthode env sur les instances de contrôleur.
    ([commit](https://github.com/rails/rails/commit/05934d24aff62d66fc62621aa38dae6456e276be))

*   `ActionDispatch::ParamsParser` est déprécié et a été supprimé de la
    pile de middleware. Pour configurer les analyseurs de paramètres, utilisez
    `ActionDispatch::Request.parameter_parsers=`.
    ([commit](https://github.com/rails/rails/commit/38d2bf5fd1f3e014f2397898d371c339baa627b1),
    [commit](https://github.com/rails/rails/commit/5ed38014811d4ce6d6f957510b9153938370173b))
### Changements notables

*   Ajout de `ActionController::Renderer` pour rendre des templates arbitraires
    en dehors des actions du contrôleur.
    ([Demande d'extraction](https://github.com/rails/rails/pull/18546))

*   Migration vers la syntaxe des arguments de mots-clés dans `ActionController::TestCase` et
    les méthodes de requête HTTP de `ActionDispatch::Integration`.
    ([Demande d'extraction](https://github.com/rails/rails/pull/18323))

*   Ajout de `http_cache_forever` à Action Controller, afin de pouvoir mettre en cache une réponse
    qui ne s'expire jamais.
    ([Demande d'extraction](https://github.com/rails/rails/pull/18394))

*   Fournir un accès plus convivial aux variantes de requête.
    ([Demande d'extraction](https://github.com/rails/rails/pull/18939))

*   Pour les actions sans templates correspondants, rendre `head :no_content`
    au lieu de lever une erreur.
    ([Demande d'extraction](https://github.com/rails/rails/pull/19377))

*   Ajout de la possibilité de substituer le constructeur de formulaire par défaut pour un contrôleur.
    ([Demande d'extraction](https://github.com/rails/rails/pull/19736))

*   Ajout de la prise en charge des applications API-only.
    `ActionController::API` est ajouté en remplacement de
    `ActionController::Base` pour ce type d'applications.
    ([Demande d'extraction](https://github.com/rails/rails/pull/19832))

*   `ActionController::Parameters` n'hérite plus de
    `HashWithIndifferentAccess`.
    ([Demande d'extraction](https://github.com/rails/rails/pull/20868))

*   Rendre plus facile l'activation de `config.force_ssl` et `config.ssl_options` en
    les rendant moins dangereux à essayer et plus faciles à désactiver.
    ([Demande d'extraction](https://github.com/rails/rails/pull/21520))

*   Ajout de la possibilité de retourner des en-têtes arbitraires à `ActionDispatch::Static`.
    ([Demande d'extraction](https://github.com/rails/rails/pull/19135))

*   Modification de la valeur par défaut de préfixe de `protect_from_forgery` à `false`.
    ([commit](https://github.com/rails/rails/commit/39794037817703575c35a75f1961b01b83791191))

*   `ActionController::TestCase` sera déplacé dans son propre gemme dans Rails 5.1. Utilisez
    `ActionDispatch::IntegrationTest` à la place.
    ([commit](https://github.com/rails/rails/commit/4414c5d1795e815b102571425974a8b1d46d932d))

*   Rails génère des ETags faibles par défaut.
    ([Demande d'extraction](https://github.com/rails/rails/pull/17573))

*   Les actions du contrôleur sans appel explicite à `render` et sans
    templates correspondants rendront implicitement `head :no_content`
    au lieu de lever une erreur.
    (Demande d'extraction [1](https://github.com/rails/rails/pull/19377),
    [2](https://github.com/rails/rails/pull/23827))

*   Ajout d'une option pour les jetons CSRF par formulaire.
    ([Demande d'extraction](https://github.com/rails/rails/pull/22275))

*   Ajout de l'encodage de la requête et de l'analyse de la réponse aux tests d'intégration.
    ([Demande d'extraction](https://github.com/rails/rails/pull/21671))

*   Ajout de `ActionController#helpers` pour accéder au contexte de la vue
    au niveau du contrôleur.
    ([Demande d'extraction](https://github.com/rails/rails/pull/24866))

*   Les messages flash supprimés sont retirés avant d'être stockés dans la session.
    ([Demande d'extraction](https://github.com/rails/rails/pull/18721))

*   Ajout de la prise en charge du passage d'une collection d'enregistrements à `fresh_when` et
    `stale?`.
    ([Demande d'extraction](https://github.com/rails/rails/pull/18374))

*   `ActionController::Live` est devenu un `ActiveSupport::Concern`. Cela
    signifie qu'il ne peut pas être simplement inclus dans d'autres modules sans les étendre avec `ActiveSupport::Concern` ou `ActionController::Live`
    n'aura pas d'effet en production. Certaines personnes peuvent également utiliser un autre
    module pour inclure un code de gestion des échecs d'authentification `Warden`/`Devise` spécial
    car le middleware ne peut pas intercepter un `:warden` lancé par un thread enfant, ce qui est le cas lors de l'utilisation de `ActionController::Live`.
    ([Plus de détails dans ce problème](https://github.com/rails/rails/issues/25581))
*   Introduire `Response#strong_etag=` et `#weak_etag=` ainsi que des options analogues pour `fresh_when` et `stale?`.
    ([Demande de tirage](https://github.com/rails/rails/pull/24387))

Action View
-------------

Veuillez vous référer au [Changelog][action-view] pour des changements détaillés.

### Suppressions

*   Suppression de `AbstractController::Base::parent_prefixes` obsolète.
    ([commit](https://github.com/rails/rails/commit/34bcbcf35701ca44be559ff391535c0dd865c333))

*   Suppression de `ActionView::Helpers::RecordTagHelper`, cette fonctionnalité
    a été extraite dans le gemme
    [record_tag_helper](https://github.com/rails/record_tag_helper).
    ([Demande de tirage](https://github.com/rails/rails/pull/18411))

*   Suppression de l'option `:rescue_format` pour l'aide `translate` car elle n'est plus
    prise en charge par I18n.
    ([Demande de tirage](https://github.com/rails/rails/pull/20019))

### Changements notables

*   Changement du gestionnaire de modèle par défaut de `ERB` à `Raw`.
    ([commit](https://github.com/rails/rails/commit/4be859f0fdf7b3059a28d03c279f03f5938efc80))

*   Le rendu de collection peut mettre en cache et récupérer plusieurs partiels à la fois.
    ([Demande de tirage](https://github.com/rails/rails/pull/18948),
    [commit](https://github.com/rails/rails/commit/e93f0f0f133717f9b06b1eaefd3442bd0ff43985))

*   Ajout de la correspondance générique aux dépendances explicites.
    ([Demande de tirage](https://github.com/rails/rails/pull/20904))

*   Faire de `disable_with` le comportement par défaut pour les balises de soumission. Désactive le
    bouton lors de la soumission pour éviter les soumissions multiples.
    ([Demande de tirage](https://github.com/rails/rails/pull/21135))

*   Le nom du modèle partiel n'a plus besoin d'être un identifiant Ruby valide.
    ([commit](https://github.com/rails/rails/commit/da9038e))

*   L'aide `datetime_tag` génère maintenant une balise d'entrée avec le type
    `datetime-local`.
    ([Demande de tirage](https://github.com/rails/rails/pull/25469))

*   Autoriser les blocs lors du rendu avec l'aide `render partial:`.
    ([Demande de tirage](https://github.com/rails/rails/pull/17974))

Action Mailer
-------------

Veuillez vous référer au [Changelog][action-mailer] pour des changements détaillés.

### Suppressions

*   Suppression des aides `*_path` obsolètes dans les vues des emails.
    ([commit](https://github.com/rails/rails/commit/d282125a18c1697a9b5bb775628a2db239142ac7))

*   Suppression des méthodes `deliver` et `deliver!` obsolètes.
    ([commit](https://github.com/rails/rails/commit/755dcd0691f74079c24196135f89b917062b0715))

### Changements notables

*   La recherche de modèle respecte désormais la langue par défaut et les fallbacks de I18n.
    ([commit](https://github.com/rails/rails/commit/ecb1981b))

*   Ajout du suffixe `_mailer` aux mailers créés via le générateur, suivant la même
    convention de nommage utilisée dans les contrôleurs et les jobs.
    ([Demande de tirage](https://github.com/rails/rails/pull/18074))

*   Ajout de `assert_enqueued_emails` et `assert_no_enqueued_emails`.
    ([Demande de tirage](https://github.com/rails/rails/pull/18403))

*   Ajout de la configuration `config.action_mailer.deliver_later_queue_name` pour définir
    le nom de la file d'attente du mailer.
    ([Demande de tirage](https://github.com/rails/rails/pull/18587))

*   Ajout de la prise en charge de la mise en cache de fragments dans les vues d'Action Mailer.
    Ajout de la nouvelle option de configuration `config.action_mailer.perform_caching` pour déterminer
    si vos modèles doivent effectuer une mise en cache ou non.
    ([Demande de tirage](https://github.com/rails/rails/pull/22825))


Active Record
-------------

Veuillez vous référer au [Changelog][active-record] pour des changements détaillés.

### Suppressions

*   Suppression du comportement obsolète permettant de passer des tableaux imbriqués en tant que valeurs de requête.
    ([Demande de tirage](https://github.com/rails/rails/pull/17919))

*   Suppression de `ActiveRecord::Tasks::DatabaseTasks#load_schema` obsolète. Cette
    méthode a été remplacée par `ActiveRecord::Tasks::DatabaseTasks#load_schema_for`.
    ([commit](https://github.com/rails/rails/commit/ad783136d747f73329350b9bb5a5e17c8f8800da))
*   Suppression de `serialized_attributes` obsolète.
    ([commit](https://github.com/rails/rails/commit/82043ab53cb186d59b1b3be06122861758f814b2))

*   Suppression des caches automatiques obsolètes sur `has_many :through`.
    ([commit](https://github.com/rails/rails/commit/87c8ce340c6c83342df988df247e9035393ed7a0))

*   Suppression de `sanitize_sql_hash_for_conditions` obsolète.
    ([commit](https://github.com/rails/rails/commit/3a59dd212315ebb9bae8338b98af259ac00bbef3))

*   Suppression de `Reflection#source_macro` obsolète.
    ([commit](https://github.com/rails/rails/commit/ede8c199a85cfbb6457d5630ec1e285e5ec49313))

*   Suppression de `symbolized_base_class` et `symbolized_sti_name` obsolètes.
    ([commit](https://github.com/rails/rails/commit/9013e28e52eba3a6ffcede26f85df48d264b8951))

*   Suppression de `ActiveRecord::Base.disable_implicit_join_references=`.
    ([commit](https://github.com/rails/rails/commit/0fbd1fc888ffb8cbe1191193bf86933110693dfc))

*   Suppression de l'accès obsolète à la spécification de connexion en utilisant un accesseur de chaîne.
    ([commit](https://github.com/rails/rails/commit/efdc20f36ccc37afbb2705eb9acca76dd8aabd4f))

*   Suppression du support obsolète pour le préchargement des associations dépendantes de l'instance.
    ([commit](https://github.com/rails/rails/commit/4ed97979d14c5e92eb212b1a629da0a214084078))

*   Suppression du support obsolète pour les plages PostgreSQL avec des bornes inférieures exclusives.
    ([commit](https://github.com/rails/rails/commit/a076256d63f64d194b8f634890527a5ed2651115))

*   Suppression de l'obsolescence lors de la modification d'une relation avec Arel mis en cache.
    Cela génère une erreur `ImmutableRelation` à la place.
    ([commit](https://github.com/rails/rails/commit/3ae98181433dda1b5e19910e107494762512a86c))

*   Suppression de `ActiveRecord::Serialization::XmlSerializer` du noyau. Cette fonctionnalité
    a été extraite dans le gemme
    [activemodel-serializers-xml](https://github.com/rails/activemodel-serializers-xml).
    ([Pull Request](https://github.com/rails/rails/pull/21161))

*   Suppression du support de l'adaptateur de base de données `mysql` obsolète du noyau. La plupart des utilisateurs devraient
    pouvoir utiliser `mysql2`. Il sera converti en un gemme séparé lorsque nous trouverons quelqu'un
    pour le maintenir. ([Pull Request 1](https://github.com/rails/rails/pull/22642),
    [Pull Request 2](https://github.com/rails/rails/pull/22715))

*   Suppression du support pour le gemme `protected_attributes`.
    ([commit](https://github.com/rails/rails/commit/f4fbc0301021f13ae05c8e941c8efc4ae351fdf9))

*   Suppression du support pour les versions de PostgreSQL inférieures à 9.1.
    ([Pull Request](https://github.com/rails/rails/pull/23434))

*   Suppression du support pour le gemme `activerecord-deprecated_finders`.
    ([commit](https://github.com/rails/rails/commit/78dab2a8569408658542e462a957ea5a35aa4679))

*   Suppression de la constante `ActiveRecord::ConnectionAdapters::Column::TRUE_VALUES`.
    ([commit](https://github.com/rails/rails/commit/a502703c3d2151d4d3b421b29fefdac5ad05df61))

### Obsolescences

*   Obsolescence du passage d'une classe en tant que valeur dans une requête. Les utilisateurs devraient passer des chaînes
    à la place. ([Pull Request](https://github.com/rails/rails/pull/17916))

*   Obsolescence du retour de `false` comme moyen d'arrêter les chaînes de rappel d'Active Record.
    La méthode recommandée est de
    `throw(:abort)`. ([Pull Request](https://github.com/rails/rails/pull/17227))

*   Obsolescence de `ActiveRecord::Base.errors_in_transactional_callbacks=`.
    ([commit](https://github.com/rails/rails/commit/07d3d402341e81ada0214f2cb2be1da69eadfe72))

*   Obsolescence de l'utilisation de `Relation#uniq`, utiliser `Relation#distinct` à la place.
    ([commit](https://github.com/rails/rails/commit/adfab2dcf4003ca564d78d4425566dd2d9cd8b4f))

*   Obsolescence du type PostgreSQL `:point` au profit d'un nouveau qui renverra
    des objets `Point` au lieu d'un `Array`.
    ([Pull Request](https://github.com/rails/rails/pull/20448))

*   Obsolescence du rechargement forcé de l'association en passant un argument vrai à
    la méthode d'association.
    ([Pull Request](https://github.com/rails/rails/pull/20888))

*   Obsolescence des clés pour les erreurs d'association `restrict_dependent_destroy` au profit
    de nouveaux noms de clés.
    ([Pull Request](https://github.com/rails/rails/pull/20668))

*   Synchronisation du comportement de `#tables`.
    ([Pull Request](https://github.com/rails/rails/pull/21601))

*   Obsolescence de `SchemaCache#tables`, `SchemaCache#table_exists?` et
    `SchemaCache#clear_table_cache!` au profit de leurs nouvelles sources de données
    homologues.
    ([Pull Request](https://github.com/rails/rails/pull/21715))
*   Obsolète `connection.tables` sur les adaptateurs SQLite3 et MySQL.
    ([Pull Request](https://github.com/rails/rails/pull/21601))

*   Obsolète le passage d'arguments à `#tables` - la méthode `#tables` de certains
    adaptateurs (mysql2, sqlite3) renverrait à la fois des tables et des vues tandis que d'autres
    (postgresql) ne renvoient que des tables. Pour rendre leur comportement cohérent,
    `#tables` ne renverra que des tables à l'avenir.
    ([Pull Request](https://github.com/rails/rails/pull/21601))

*   Obsolète `table_exists?` - La méthode `#table_exists?` vérifierait à la fois
    les tables et les vues. Pour rendre leur comportement cohérent avec `#tables`,
    `#table_exists?` vérifiera uniquement les tables à l'avenir.
    ([Pull Request](https://github.com/rails/rails/pull/21601))

*   Déprécation de l'envoi de l'argument `offset` à `find_nth`. Veuillez utiliser la
    méthode `offset` sur la relation à la place.
    ([Pull Request](https://github.com/rails/rails/pull/22053))

*   Obsolète `{insert|update|delete}_sql` dans `DatabaseStatements`.
    Utilisez les méthodes publiques `{insert|update|delete}` à la place.
    ([Pull Request](https://github.com/rails/rails/pull/23086))

*   Obsolète `use_transactional_fixtures` au profit de
    `use_transactional_tests` pour plus de clarté.
    ([Pull Request](https://github.com/rails/rails/pull/19282))

*   Obsolète le passage d'une colonne à `ActiveRecord::Connection#quote`.
    ([commit](https://github.com/rails/rails/commit/7bb620869725ad6de603f6a5393ee17df13aa96c))

*   Ajout d'une option `end` à `find_in_batches` qui complète le paramètre `start`
    pour spécifier où arrêter le traitement par lots.
    ([Pull Request](https://github.com/rails/rails/pull/12257))


### Changements notables

*   Ajout d'une option `foreign_key` à `references` lors de la création de la table.
    ([commit](https://github.com/rails/rails/commit/99a6f9e60ea55924b44f894a16f8de0162cf2702))

*   Nouvelle API d'attributs.
    ([commit](https://github.com/rails/rails/commit/8c752c7ac739d5a86d4136ab1e9d0142c4041e58))

*   Ajout des options `:_prefix`/`:_suffix` à la définition de `enum`.
    ([Pull Request](https://github.com/rails/rails/pull/19813),
     [Pull Request](https://github.com/rails/rails/pull/20999))

*   Ajout de `#cache_key` à `ActiveRecord::Relation`.
    ([Pull Request](https://github.com/rails/rails/pull/20884))

*   Modification de la valeur par défaut de `null` pour `timestamps` à `false`.
    ([commit](https://github.com/rails/rails/commit/a939506f297b667291480f26fa32a373a18ae06a))

*   Ajout de `ActiveRecord::SecureToken` pour encapsuler la génération de
    jetons uniques pour les attributs d'un modèle en utilisant `SecureRandom`.
    ([Pull Request](https://github.com/rails/rails/pull/18217))

*   Ajout de l'option `:if_exists` pour `drop_table`.
    ([Pull Request](https://github.com/rails/rails/pull/18597))

*   Ajout de `ActiveRecord::Base#accessed_fields`, qui peut être utilisé pour rapidement
    découvrir quels champs ont été lus à partir d'un modèle lorsque vous cherchez à sélectionner
    uniquement les données dont vous avez besoin dans la base de données.
    ([commit](https://github.com/rails/rails/commit/be9b68038e83a617eb38c26147659162e4ac3d2c))

*   Ajout de la méthode `#or` sur `ActiveRecord::Relation`, permettant d'utiliser l'opérateur OR
    pour combiner des clauses WHERE ou HAVING.
    ([commit](https://github.com/rails/rails/commit/b0b37942d729b6bdcd2e3178eda7fa1de203b3d0))

*   Ajout de `ActiveRecord::Base.suppress` pour empêcher l'enregistrement du receveur
    pendant le bloc donné.
    ([Pull Request](https://github.com/rails/rails/pull/18910))

*   `belongs_to` déclenchera désormais une erreur de validation par défaut si l'
    association n'est pas présente. Vous pouvez désactiver cela pour chaque association
    avec `optional: true`. Déprécation également de l'option `required` au profit de `optional`
    pour `belongs_to`.
    ([Pull Request](https://github.com/rails/rails/pull/18937))
*   Ajout de `config.active_record.dump_schemas` pour configurer le comportement de `db:structure:dump`. ([Pull Request](https://github.com/rails/rails/pull/19347))

*   Ajout de l'option `config.active_record.warn_on_records_fetched_greater_than`. ([Pull Request](https://github.com/rails/rails/pull/18846))

*   Ajout d'une prise en charge native du type de données JSON dans MySQL. ([Pull Request](https://github.com/rails/rails/pull/21110))

*   Ajout de la prise en charge de la suppression d'index de manière concurrente dans PostgreSQL. ([Pull Request](https://github.com/rails/rails/pull/21317))

*   Ajout des méthodes `#views` et `#view_exists?` sur les adaptateurs de connexion. ([Pull Request](https://github.com/rails/rails/pull/21609))

*   Ajout de `ActiveRecord::Base.ignored_columns` pour rendre certaines colonnes invisibles pour Active Record. ([Pull Request](https://github.com/rails/rails/pull/21720))

*   Ajout de `connection.data_sources` et `connection.data_source_exists?`. Ces méthodes déterminent quelles relations peuvent être utilisées pour soutenir les modèles Active Record (généralement des tables et des vues). ([Pull Request](https://github.com/rails/rails/pull/21715))

*   Autoriser les fichiers de fixtures à définir la classe de modèle dans le fichier YAML lui-même. ([Pull Request](https://github.com/rails/rails/pull/20574))

*   Ajout de la possibilité de définir `uuid` comme clé primaire par défaut lors de la génération de migrations de base de données. ([Pull Request](https://github.com/rails/rails/pull/21762))

*   Ajout de `ActiveRecord::Relation#left_joins` et `ActiveRecord::Relation#left_outer_joins`. ([Pull Request](https://github.com/rails/rails/pull/12071))

*   Ajout des rappels `after_{create,update,delete}_commit`. ([Pull Request](https://github.com/rails/rails/pull/22516))

*   Versionner l'API présentée aux classes de migration, afin de pouvoir modifier les valeurs par défaut des paramètres sans casser les migrations existantes ou les forcer à être réécrites via un cycle de dépréciation. ([Pull Request](https://github.com/rails/rails/pull/21538))

*   `ApplicationRecord` est une nouvelle superclasse pour tous les modèles d'application, analogue aux contrôleurs d'application qui héritent de `ApplicationController` au lieu de `ActionController::Base`. Cela permet aux applications de configurer le comportement des modèles à l'échelle de l'application en un seul endroit. ([Pull Request](https://github.com/rails/rails/pull/22567))

*   Ajout des méthodes ActiveRecord `#second_to_last` et `#third_to_last`. ([Pull Request](https://github.com/rails/rails/pull/23583))

*   Ajout de la possibilité d'annoter les objets de base de données (tables, colonnes, index) avec des commentaires stockés dans les métadonnées de la base de données pour PostgreSQL et MySQL. ([Pull Request](https://github.com/rails/rails/pull/22911))

*   Ajout de la prise en charge des instructions préparées pour l'adaptateur `mysql2`, pour mysql2 0.4.4+. Auparavant, cela était uniquement pris en charge par l'adaptateur hérité `mysql` obsolète. Pour l'activer, définissez `prepared_statements: true` dans `config/database.yml`. ([Pull Request](https://github.com/rails/rails/pull/23461))

*   Ajout de la possibilité d'appeler `ActionRecord::Relation#update` sur des objets de relation qui exécutera les validations et les rappels sur tous les objets de la relation. ([Pull Request](https://github.com/rails/rails/pull/11898))

*   Ajout de l'option `:touch` à la méthode `save` afin que les enregistrements puissent être enregistrés sans mettre à jour les horodatages. ([Pull Request](https://github.com/rails/rails/pull/18225))

*   Ajout de la prise en charge des index d'expression et des classes d'opérateurs pour PostgreSQL. ([commit](https://github.com/rails/rails/commit/edc2b7718725016e988089b5fb6d6fb9d6e16882))
*   Ajout de l'option `:index_errors` pour ajouter des index aux erreurs des attributs imbriqués.
    ([Pull Request](https://github.com/rails/rails/pull/19686))

*   Ajout de la prise en charge des dépendances de destruction bidirectionnelle.
    ([Pull Request](https://github.com/rails/rails/pull/18548))

*   Ajout de la prise en charge des rappels `after_commit` dans les tests transactionnels.
    ([Pull Request](https://github.com/rails/rails/pull/18458))

*   Ajout de la méthode `foreign_key_exists?` pour vérifier si une clé étrangère existe ou non sur une table.
    ([Pull Request](https://github.com/rails/rails/pull/18662))

*   Ajout de l'option `:time` à la méthode `touch` pour mettre à jour les enregistrements avec une heure différente de l'heure actuelle.
    ([Pull Request](https://github.com/rails/rails/pull/18956))

*   Modification des rappels de transaction pour ne pas masquer les erreurs.
    Avant cette modification, toutes les erreurs survenues dans un rappel de transaction étaient capturées et affichées dans les journaux, sauf si vous utilisiez l'option (nouvellement dépréciée) `raise_in_transactional_callbacks = true`.

    Désormais, ces erreurs ne sont plus capturées et remontent simplement, ce qui correspond au comportement des autres rappels.
    ([commit](https://github.com/rails/rails/commit/07d3d402341e81ada0214f2cb2be1da69eadfe72))

Active Model
------------

Veuillez vous référer au [journal des modifications][active-model] pour plus de détails sur les changements.

### Suppressions

*   Suppression des méthodes dépréciées `ActiveModel::Dirty#reset_#{attribute}` et `ActiveModel::Dirty#reset_changes`.
    ([Pull Request](https://github.com/rails/rails/commit/37175a24bd508e2983247ec5d011d57df836c743))

*   Suppression de la sérialisation XML. Cette fonctionnalité a été extraite dans le gem [activemodel-serializers-xml](https://github.com/rails/activemodel-serializers-xml).
    ([Pull Request](https://github.com/rails/rails/pull/21161))

*   Suppression du module `ActionController::ModelNaming`.
    ([Pull Request](https://github.com/rails/rails/pull/18194))

### Dépréciations

*   Dépréciation du retour de `false` comme moyen d'arrêter les chaînes de rappels d'Active Model et `ActiveModel::Validations`. La méthode recommandée est d'utiliser `throw(:abort)`.
    ([Pull Request](https://github.com/rails/rails/pull/17227))

*   Dépréciation des méthodes `ActiveModel::Errors#get`, `ActiveModel::Errors#set` et `ActiveModel::Errors#[]=` qui ont un comportement incohérent.
    ([Pull Request](https://github.com/rails/rails/pull/18634))

*   Dépréciation de l'option `:tokenizer` pour `validates_length_of`, au profit de Ruby pur.
    ([Pull Request](https://github.com/rails/rails/pull/19585))

*   Dépréciation des méthodes `ActiveModel::Errors#add_on_empty` et `ActiveModel::Errors#add_on_blank` sans remplacement.
    ([Pull Request](https://github.com/rails/rails/pull/18996))

### Changements notables

*   Ajout de la méthode `ActiveModel::Errors#details` pour déterminer quel validateur a échoué.
    ([Pull Request](https://github.com/rails/rails/pull/18322))

*   Extraction de `ActiveRecord::AttributeAssignment` vers `ActiveModel::AttributeAssignment`, permettant de l'utiliser pour n'importe quel objet en tant que module inclus.
    ([Pull Request](https://github.com/rails/rails/pull/10776))

*   Ajout des méthodes `ActiveModel::Dirty#[attr_name]_previously_changed?` et `ActiveModel::Dirty#[attr_name]_previous_change` pour améliorer l'accès aux modifications enregistrées après la sauvegarde du modèle.
    ([Pull Request](https://github.com/rails/rails/pull/19847))

*   Validation de plusieurs contextes en une seule fois avec les méthodes `valid?` et `invalid?`.
    ([Pull Request](https://github.com/rails/rails/pull/21069))

*   Modification de `validates_acceptance_of` pour accepter `true` comme valeur par défaut en plus de `1`.
    ([Pull Request](https://github.com/rails/rails/pull/18439))
Active Job
-----------

Veuillez vous référer au [Changelog][active-job] pour des changements détaillés.

### Changements notables

*   `ActiveJob::Base.deserialize` délègue à la classe de travail. Cela permet aux travaux
    d'attacher des métadonnées arbitraires lorsqu'ils sont sérialisés et de les lire lorsqu'ils sont
    exécutés.
    ([Pull Request](https://github.com/rails/rails/pull/18260))

*   Ajout de la possibilité de configurer l'adaptateur de file d'attente pour chaque travail sans
    affecter les autres.
    ([Pull Request](https://github.com/rails/rails/pull/16992))

*   Un travail généré hérite maintenant de `app/jobs/application_job.rb` par défaut.
    ([Pull Request](https://github.com/rails/rails/pull/19034))

*   Autoriser `DelayedJob`, `Sidekiq`, `qu`, `que` et `queue_classic` à renvoyer
    l'identifiant du travail à `ActiveJob::Base` en tant que `provider_job_id`.
    ([Pull Request](https://github.com/rails/rails/pull/20064),
     [Pull Request](https://github.com/rails/rails/pull/20056),
     [commit](https://github.com/rails/rails/commit/68e3279163d06e6b04e043f91c9470e9259bbbe0))

*   Implémenter un processeur de travail `AsyncJob` simple et un adaptateur associé `AsyncAdapter` qui
    mettent les travaux en file d'attente dans un pool de threads `concurrent-ruby`.
    ([Pull Request](https://github.com/rails/rails/pull/21257))

*   Changer l'adaptateur par défaut de "inline" à "async". C'est un meilleur choix par défaut car
    les tests ne dépendront pas par erreur d'un comportement se produisant
    de manière synchrone.
    ([commit](https://github.com/rails/rails/commit/625baa69d14881ac49ba2e5c7d9cac4b222d7022))

Active Support
--------------

Veuillez vous référer au [Changelog][active-support] pour des changements détaillés.

### Suppressions

*   Suppression de `ActiveSupport::JSON::Encoding::CircularReferenceError` obsolète.
    ([commit](https://github.com/rails/rails/commit/d6e06ea8275cdc3f126f926ed9b5349fde374b10))

*   Suppression des méthodes obsolètes `ActiveSupport::JSON::Encoding.encode_big_decimal_as_string=`
    et `ActiveSupport::JSON::Encoding.encode_big_decimal_as_string`.
    ([commit](https://github.com/rails/rails/commit/c8019c0611791b2716c6bed48ef8dcb177b7869c))

*   Suppression de `ActiveSupport::SafeBuffer#prepend` obsolète.
    ([commit](https://github.com/rails/rails/commit/e1c8b9f688c56aaedac9466a4343df955b4a67ec))

*   Suppression des méthodes obsolètes de `Kernel`. `silence_stderr`, `silence_stream`,
    `capture` et `quietly`.
    ([commit](https://github.com/rails/rails/commit/481e49c64f790e46f4aff3ed539ed227d2eb46cb))

*   Suppression du fichier obsolète `active_support/core_ext/big_decimal/yaml_conversions`.
    ([commit](https://github.com/rails/rails/commit/98ea19925d6db642731741c3b91bd085fac92241))

*   Suppression des méthodes obsolètes `ActiveSupport::Cache::Store.instrument` et
    `ActiveSupport::Cache::Store.instrument=`.
    ([commit](https://github.com/rails/rails/commit/a3ce6ca30ed0e77496c63781af596b149687b6d7))

*   Suppression de `Class#superclass_delegating_accessor` obsolète.
    Utilisez plutôt `Class#class_attribute`.
    ([Pull Request](https://github.com/rails/rails/pull/16938))

*   Suppression de `ThreadSafe::Cache`. Utilisez `Concurrent::Map` à la place.
    ([Pull Request](https://github.com/rails/rails/pull/21679))

*   Suppression de `Object#itself` car il est implémenté dans Ruby 2.2.
    ([Pull Request](https://github.com/rails/rails/pull/18244))

### Obsolescence

*   Obsolescence de `MissingSourceFile` au profit de `LoadError`.
    ([commit](https://github.com/rails/rails/commit/734d97d2))

*   Obsolescence de `alias_method_chain` au profit de `Module#prepend` introduit dans
    Ruby 2.0.
    ([Pull Request](https://github.com/rails/rails/pull/19434))

*   Obsolescence de `ActiveSupport::Concurrency::Latch` au profit de
    `Concurrent::CountDownLatch` de concurrent-ruby.
    ([Pull Request](https://github.com/rails/rails/pull/20866))

*   Obsolescence de l'option `:prefix` de `number_to_human_size` sans remplacement.
    ([Pull Request](https://github.com/rails/rails/pull/21191))

*   Obsolescence de `Module#qualified_const_` au profit des méthodes intégrées
    `Module#const_`.
    ([Pull Request](https://github.com/rails/rails/pull/17845))

*   Obsolescence du passage d'une chaîne pour définir un rappel.
    ([Pull Request](https://github.com/rails/rails/pull/22598))

*   Obsolescence de `ActiveSupport::Cache::Store#namespaced_key`,
    `ActiveSupport::Cache::MemCachedStore#escape_key` et
    `ActiveSupport::Cache::FileStore#key_file_path`.
    Utilisez `normalize_key` à la place.
    ([Pull Request](https://github.com/rails/rails/pull/22215),
     [commit](https://github.com/rails/rails/commit/a8f773b0))
*   Déprécié `ActiveSupport::Cache::LocaleCache#set_cache_value` au profit de `write_cache_value`.
    ([Pull Request](https://github.com/rails/rails/pull/22215))

*   Déprécié le passage d'arguments à `assert_nothing_raised`.
    ([Pull Request](https://github.com/rails/rails/pull/23789))

*   Déprécié `Module.local_constants` au profit de `Module.constants(false)`.
    ([Pull Request](https://github.com/rails/rails/pull/23936))


### Changements notables

*   Ajout des méthodes `#verified` et `#valid_message?` à
    `ActiveSupport::MessageVerifier`.
    ([Pull Request](https://github.com/rails/rails/pull/17727))

*   Changement de la manière dont les chaînes de rappel peuvent être arrêtées. La méthode préférée
    pour arrêter une chaîne de rappel est maintenant d'utiliser explicitement `throw(:abort)`.
    ([Pull Request](https://github.com/rails/rails/pull/17227))

*   Nouvelle option de configuration
    `config.active_support.halt_callback_chains_on_return_false` pour spécifier
    si les chaînes de rappel d'ActiveRecord, ActiveModel et ActiveModel::Validations peuvent
    être arrêtées en retournant `false` dans un rappel 'before'.
    ([Pull Request](https://github.com/rails/rails/pull/17227))

*   Changement de l'ordre de test par défaut de `:sorted` à `:random`.
    ([commit](https://github.com/rails/rails/commit/5f777e4b5ee2e3e8e6fd0e2a208ec2a4d25a960d))

*   Ajout des méthodes `#on_weekend?`, `#on_weekday?`, `#next_weekday`, `#prev_weekday` à `Date`,
    `Time` et `DateTime`.
    ([Pull Request](https://github.com/rails/rails/pull/18335),
     [Pull Request](https://github.com/rails/rails/pull/23687))

*   Ajout de l'option `same_time` à `#next_week` et `#prev_week` pour `Date`, `Time`,
    et `DateTime`.
    ([Pull Request](https://github.com/rails/rails/pull/18335))

*   Ajout des méthodes `#prev_day` et `#next_day` en complément de `#yesterday` et
    `#tomorrow` pour `Date`, `Time` et `DateTime`.
    ([Pull Request](https://github.com/rails/rails/pull/18335))

*   Ajout de `SecureRandom.base58` pour la génération de chaînes aléatoires en base58.
    ([commit](https://github.com/rails/rails/commit/b1093977110f18ae0cafe56c3d99fc22a7d54d1b))

*   Ajout de `file_fixture` à `ActiveSupport::TestCase`.
    Il fournit un mécanisme simple pour accéder aux fichiers d'exemple dans vos cas de test.
    ([Pull Request](https://github.com/rails/rails/pull/18658))

*   Ajout de `#without` sur `Enumerable` et `Array` pour renvoyer une copie d'un
    énumérable sans les éléments spécifiés.
    ([Pull Request](https://github.com/rails/rails/pull/19157))

*   Ajout de `ActiveSupport::ArrayInquirer` et `Array#inquiry`.
    ([Pull Request](https://github.com/rails/rails/pull/18939))

*   Ajout de `ActiveSupport::TimeZone#strptime` pour permettre l'analyse des heures comme si
    elles provenaient d'un fuseau horaire donné.
    ([commit](https://github.com/rails/rails/commit/a5e507fa0b8180c3d97458a9b86c195e9857d8f6))

*   Ajout des méthodes de requête `Integer#positive?` et `Integer#negative?`
    dans la veine de `Integer#zero?`.
    ([commit](https://github.com/rails/rails/commit/e54277a45da3c86fecdfa930663d7692fd083daa))

*   Ajout d'une version bang aux méthodes `get` de `ActiveSupport::OrderedOptions` qui lèvera
    une `KeyError` si la valeur est `.blank?`.
    ([Pull Request](https://github.com/rails/rails/pull/20208))

*   Ajout de `Time.days_in_year` pour renvoyer le nombre de jours dans l'année donnée, ou l'année
    en cours si aucun argument n'est fourni.
    ([commit](https://github.com/rails/rails/commit/2f4f4d2cf1e4c5a442459fc250daf66186d110fa))

*   Ajout d'un observateur de fichiers événementiel pour détecter de manière asynchrone les modifications dans le
    code source de l'application, les routes, les localisations, etc.
    ([Pull Request](https://github.com/rails/rails/pull/22254))

*   Ajout de la suite de méthodes thread_m/cattr_accessor/reader/writer pour déclarer
    des variables de classe et de module qui vivent par thread.
    ([Pull Request](https://github.com/rails/rails/pull/22630))
*   Ajout des méthodes `Array#second_to_last` et `Array#third_to_last`.
    ([Demande de tirage](https://github.com/rails/rails/pull/23583))

*   Publication des API `ActiveSupport::Executor` et `ActiveSupport::Reloader` pour permettre aux composants et aux bibliothèques de gérer et de participer à l'exécution du code de l'application et au processus de rechargement de l'application.
    ([Demande de tirage](https://github.com/rails/rails/pull/23807))

*   `ActiveSupport::Duration` prend désormais en charge le formatage et l'analyse ISO8601.
    ([Demande de tirage](https://github.com/rails/rails/pull/16917))

*   `ActiveSupport::JSON.decode` prend désormais en charge l'analyse des heures locales ISO8601 lorsque `parse_json_times` est activé.
    ([Demande de tirage](https://github.com/rails/rails/pull/23011))

*   `ActiveSupport::JSON.decode` renvoie désormais des objets `Date` pour les chaînes de dates.
    ([Demande de tirage](https://github.com/rails/rails/pull/23011))

*   Ajout de la possibilité à `TaggedLogging` de permettre aux enregistreurs de journaux d'être instanciés plusieurs fois afin qu'ils ne partagent pas les balises entre eux.
    ([Demande de tirage](https://github.com/rails/rails/pull/9065))

Crédits
-------

Consultez la
[liste complète des contributeurs à Rails](https://contributors.rubyonrails.org/) pour
les nombreuses personnes qui ont passé de nombreuses heures à faire de Rails, le framework stable et robuste qu'il est. Bravo à tous. 

[railties]:       https://github.com/rails/rails/blob/5-0-stable/railties/CHANGELOG.md
[action-pack]:    https://github.com/rails/rails/blob/5-0-stable/actionpack/CHANGELOG.md
[action-view]:    https://github.com/rails/rails/blob/5-0-stable/actionview/CHANGELOG.md
[action-mailer]:  https://github.com/rails/rails/blob/5-0-stable/actionmailer/CHANGELOG.md
[action-cable]:   https://github.com/rails/rails/blob/5-0-stable/actioncable/CHANGELOG.md
[active-record]:  https://github.com/rails/rails/blob/5-0-stable/activerecord/CHANGELOG.md
[active-model]:   https://github.com/rails/rails/blob/5-0-stable/activemodel/CHANGELOG.md
[active-job]:     https://github.com/rails/rails/blob/5-0-stable/activejob/CHANGELOG.md
[active-support]: https://github.com/rails/rails/blob/5-0-stable/activesupport/CHANGELOG.md
