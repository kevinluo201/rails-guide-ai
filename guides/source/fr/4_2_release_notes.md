**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 4d8311a1435138a81e26a7e8f537dbde
Ruby on Rails 4.2 Notes de version
===============================

Points forts de Rails 4.2 :

* Active Job
* Mails asynchrones
* Adequate Record
* Web Console
* Support des clés étrangères

Ces notes de version ne couvrent que les changements majeurs. Pour en savoir plus
sur les autres fonctionnalités, corrections de bugs et changements, veuillez vous référer aux journaux de modifications ou consulter la [liste des commits](https://github.com/rails/rails/commits/4-2-stable) dans le référentiel principal de Rails sur GitHub.

--------------------------------------------------------------------------------

Mise à niveau vers Rails 4.2
----------------------

Si vous mettez à niveau une application existante, il est conseillé d'avoir une bonne couverture de tests avant de commencer. Vous devriez également d'abord mettre à niveau vers Rails 4.1 au cas où vous ne l'auriez pas déjà fait et vous assurer que votre application fonctionne toujours comme prévu avant de tenter de passer à Rails 4.2. Une liste de points à surveiller lors de la mise à niveau est disponible dans le guide [Mise à niveau de Ruby on Rails](upgrading_ruby_on_rails.html#upgrading-from-rails-4-1-to-rails-4-2).


Fonctionnalités majeures
--------------

### Active Job

Active Job est un nouveau framework dans Rails 4.2. Il s'agit d'une interface commune au-dessus des systèmes de mise en file d'attente tels que [Resque](https://github.com/resque/resque), [Delayed Job](https://github.com/collectiveidea/delayed_job), [Sidekiq](https://github.com/mperham/sidekiq), et plus encore.

Les jobs écrits avec l'API Active Job s'exécutent sur l'une des files d'attente prises en charge grâce à leurs adaptateurs respectifs. Active Job est préconfiguré avec un exécuteur en ligne qui exécute les jobs immédiatement.

Les jobs ont souvent besoin de prendre des objets Active Record en tant qu'arguments. Active Job passe les références d'objets sous forme d'URI (uniform resource identifiers) au lieu de sérialiser l'objet lui-même. La nouvelle bibliothèque [Global ID](https://github.com/rails/globalid) construit des URIs et recherche les objets auxquels ils font référence. Le passage d'objets Active Record en tant qu'arguments de job fonctionne simplement en utilisant Global ID en interne.

Par exemple, si `trashable` est un objet Active Record, alors ce job s'exécute
sans problème, sans aucune sérialisation :

```ruby
class TrashableCleanupJob < ActiveJob::Base
  def perform(trashable, depth)
    trashable.cleanup(depth)
  end
end
```

Consultez le guide [Active Job Basics](active_job_basics.html) pour plus d'informations.

### Mails asynchrones

En s'appuyant sur Active Job, Action Mailer est désormais livré avec une méthode `deliver_later` qui envoie les e-mails via la file d'attente, de sorte qu'elle ne bloque pas le contrôleur ou le modèle si la file d'attente est asynchrone (la file d'attente en ligne par défaut bloque).

Il est toujours possible d'envoyer des e-mails immédiatement avec `deliver_now`.

### Adequate Record

Adequate Record est un ensemble d'améliorations de performance dans Active Record qui rendent les appels courants `find` et `find_by` ainsi que certaines requêtes d'association jusqu'à 2 fois plus rapides.

Cela fonctionne en mettant en cache les requêtes SQL courantes sous forme de déclarations préparées et en les réutilisant lors d'appels similaires, en sautant une grande partie du travail de génération de requête lors d'appels ultérieurs. Pour plus de détails, veuillez vous référer au billet de blog d'[Aaron Patterson](http://tenderlovemaking.com/2014/02/19/adequaterecord-pro-like-activerecord.html).

Active Record profitera automatiquement de cette fonctionnalité sur
les opérations prises en charge sans aucune intervention de l'utilisateur ou de modifications de code. Voici
quelques exemples d'opérations prises en charge :

```ruby
Post.find(1)  # Le premier appel génère et met en cache la déclaration préparée
Post.find(2)  # Les appels suivants réutilisent la déclaration préparée mise en cache

Post.find_by_title('premier post')
Post.find_by_title('deuxième post')

Post.find_by(title: 'premier post')
Post.find_by(title: 'deuxième post')

post.comments
post.comments(true)
```

Il est important de souligner que, comme le suggèrent les exemples ci-dessus, les déclarations préparées ne mettent pas en cache les valeurs passées dans les appels de méthode ; elles contiennent plutôt des espaces réservés pour ces valeurs.

Le cache n'est pas utilisé dans les scénarios suivants :
- Le modèle a une portée par défaut.
- Le modèle utilise l'héritage de table unique.
- `find` avec une liste d'identifiants, par exemple :

    ```ruby
    # non mis en cache
    Post.find(1, 2, 3)
    Post.find([1,2])
    ```

- `find_by` avec des fragments SQL :

    ```ruby
    Post.find_by('published_at < ?', 2.weeks.ago)
    ```

### Console Web

Les nouvelles applications générées avec Rails 4.2 incluent désormais la gem [Web
Console](https://github.com/rails/web-console) par défaut. Web Console ajoute
une console Ruby interactive sur chaque page d'erreur et fournit une vue et des
helpers de contrôleur pour la console.

La console interactive sur les pages d'erreur vous permet d'exécuter du code dans le contexte
de l'endroit où l'exception s'est produite. L'helper `console`, s'il est appelé
n'importe où dans une vue ou un contrôleur, lance une console interactive avec le contexte final,
une fois le rendu terminé.

### Support des clés étrangères

Le DSL de migration prend désormais en charge l'ajout et la suppression de clés étrangères. Elles sont également incluses
dans `schema.rb`. À l'heure actuelle, seuls les adaptateurs `mysql`, `mysql2` et `postgresql` prennent en charge les clés étrangères.

```ruby
# ajouter une clé étrangère à `articles.author_id` faisant référence à `authors.id`
add_foreign_key :articles, :authors

# ajouter une clé étrangère à `articles.author_id` faisant référence à `users.lng_id`
add_foreign_key :articles, :users, column: :author_id, primary_key: "lng_id"

# supprimer la clé étrangère sur `accounts.branch_id`
remove_foreign_key :accounts, :branches

# supprimer la clé étrangère sur `accounts.owner_id`
remove_foreign_key :accounts, column: :owner_id
```

Consultez la documentation de l'API sur
[add_foreign_key](https://api.rubyonrails.org/v4.2.0/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html#method-i-add_foreign_key)
et
[remove_foreign_key](https://api.rubyonrails.org/v4.2.0/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html#method-i-remove_foreign_key)
pour une description complète.

Incompatibilités
-----------------

Les fonctionnalités précédemment dépréciées ont été supprimées. Veuillez vous référer aux
composants individuels pour les nouvelles dépréciations de cette version.

Les changements suivants peuvent nécessiter une action immédiate lors de la mise à niveau.

### `render` avec un argument de type String

Auparavant, l'appel à `render "foo/bar"` dans une action de contrôleur était équivalent à
`render file: "foo/bar"`. Dans Rails 4.2, cela a été modifié pour signifier
`render template: "foo/bar"`. Si vous devez rendre un fichier, veuillez
modifier votre code pour utiliser la forme explicite (`render file: "foo/bar"`) à la place.

### `respond_with` / `respond_to` au niveau de la classe

`respond_with` et le `respond_to` correspondant au niveau de la classe ont été déplacés
vers la gemme [responders](https://github.com/plataformatec/responders). Ajoutez
`gem 'responders', '~> 2.0'` à votre `Gemfile` pour l'utiliser :

```ruby
# app/controllers/users_controller.rb

class UsersController < ApplicationController
  respond_to :html, :json

  def show
    @user = User.find(params[:id])
    respond_with @user
  end
end
```

Le `respond_to` au niveau de l'instance n'est pas affecté :

```ruby
# app/controllers/users_controller.rb

class UsersController < ApplicationController
  def show
    @user = User.find(params[:id])
    respond_to do |format|
      format.html
      format.json { render json: @user }
    end
  end
end
```

### Hôte par défaut pour `rails server`

En raison d'un [changement dans Rack](https://github.com/rack/rack/commit/28b014484a8ac0bbb388e7eaeeef159598ec64fc),
`rails server` écoute désormais sur `localhost` au lieu de `0.0.0.0` par défaut. Cela
devrait avoir un impact minimal sur le flux de travail de développement standard car à la fois
http://127.0.0.1:3000 et http://localhost:3000 continueront de fonctionner comme avant
sur votre propre machine.

Cependant, avec ce changement, vous ne pourrez plus accéder au serveur Rails
à partir d'une autre machine, par exemple si votre environnement de développement
est dans une machine virtuelle et que vous souhaitez y accéder depuis la machine hôte.
Dans de tels cas, veuillez démarrer le serveur avec `rails server -b 0.0.0.0` pour
restaurer l'ancien comportement.

Si vous faites cela, assurez-vous de configurer correctement votre pare-feu de sorte que seules
les machines de confiance de votre réseau puissent accéder à votre serveur de développement.
### Symboles d'options de statut modifiés pour `render`

En raison d'un [changement dans Rack](https://github.com/rack/rack/commit/be28c6a2ac152fe4adfbef71f3db9f4200df89e8), les symboles acceptés par la méthode `render` pour l'option `:status` ont été modifiés :

- 306 : `:reserved` a été supprimé.
- 413 : `:request_entity_too_large` a été renommé en `:payload_too_large`.
- 414 : `:request_uri_too_long` a été renommé en `:uri_too_long`.
- 416 : `:requested_range_not_satisfiable` a été renommé en `:range_not_satisfiable`.

Gardez à l'esprit que si vous appelez `render` avec un symbole inconnu, le statut de la réponse sera par défaut 500.

### Sanitiseur HTML

Le sanitiseur HTML a été remplacé par une nouvelle implémentation plus robuste basée sur [Loofah](https://github.com/flavorjones/loofah) et [Nokogiri](https://github.com/sparklemotion/nokogiri). Le nouveau sanitiseur est plus sécurisé et sa fonction de sanitisation est plus puissante et flexible.

En raison du nouvel algorithme, la sortie sanitisée peut être différente pour certaines entrées pathologiques.

Si vous avez besoin de la sortie exacte de l'ancien sanitiseur, vous pouvez ajouter la gemme [rails-deprecated_sanitizer](https://github.com/kaspth/rails-deprecated_sanitizer) au `Gemfile` pour obtenir le comportement précédent. La gemme ne génère pas de messages de dépréciation car elle est facultative.

`rails-deprecated_sanitizer` sera pris en charge uniquement pour Rails 4.2 ; elle ne sera pas maintenue pour Rails 5.0.

Consultez [cet article de blog](https://blog.plataformatec.com.br/2014/07/the-new-html-sanitizer-in-rails-4-2/) pour plus de détails sur les changements apportés au nouveau sanitiseur.

### `assert_select`

`assert_select` est maintenant basé sur [Nokogiri](https://github.com/sparklemotion/nokogiri). Par conséquent, certains sélecteurs précédemment valides ne sont plus pris en charge. Si votre application utilise l'une de ces orthographes, vous devrez les mettre à jour :

*   Les valeurs dans les sélecteurs d'attributs peuvent nécessiter des guillemets s'ils contiennent des caractères non alphanumériques.

    ```ruby
    # avant
    a[href=/]
    a[href$=/]

    # maintenant
    a[href="/"]
    a[href$="/"]
    ```

*   Les DOM construits à partir de sources HTML contenant du HTML invalide avec des éléments mal imbriqués peuvent différer.

    Par exemple :

    ```ruby
    # contenu : <div><i><p></i></div>

    # avant :
    assert_select('div > i')  # => true
    assert_select('div > p')  # => false
    assert_select('i > p')    # => true

    # maintenant :
    assert_select('div > i')  # => true
    assert_select('div > p')  # => true
    assert_select('i > p')    # => false
    ```

*   Si les données sélectionnées contiennent des entités, la valeur sélectionnée pour la comparaison était brute (par exemple `AT&amp;T`), et maintenant elle est évaluée (par exemple `AT&T`).

    ```ruby
    # contenu : <p>AT&amp;T</p>

    # avant :
    assert_select('p', 'AT&amp;T')  # => true
    assert_select('p', 'AT&T')      # => false

    # maintenant :
    assert_select('p', 'AT&T')      # => true
    assert_select('p', 'AT&amp;T')  # => false
    ```

De plus, les substitutions ont changé de syntaxe.

Maintenant, vous devez utiliser un sélecteur `:match` similaire à CSS :

```ruby
assert_select ":match('id', ?)", 'comment_1'
```

De plus, les substitutions Regexp ont une apparence différente lorsque l'assertion échoue. Remarquez comment `/hello/` ici :

```ruby
assert_select(":match('id', ?)", /hello/)
```

devient `"(?-mix:hello)"` :

```
Expected at least 1 element matching "div:match('id', "(?-mix:hello)")", found 0..
Expected 0 to be >= 1.
```

Consultez la documentation de [Rails Dom Testing](https://github.com/rails/rails-dom-testing/tree/8798b9349fb9540ad8cb9a0ce6cb88d1384a210b) pour en savoir plus sur `assert_select`.


Railties
--------

Veuillez vous référer au [journal des modifications][railties] pour des détails sur les changements.

### Suppressions

*   L'option `--skip-action-view` a été supprimée du générateur d'applications. ([Pull Request](https://github.com/rails/rails/pull/17042))

*   La commande `rails application` a été supprimée sans remplacement. ([Pull Request](https://github.com/rails/rails/pull/11616))

### Dépréciations

*   Dépréciation de l'absence de `config.log_level` pour les environnements de production. ([Pull Request](https://github.com/rails/rails/pull/16622))

*   Dépréciation de `rake test:all` au profit de `rake test`, car il exécute maintenant tous les tests du dossier `test`. ([Pull Request](https://github.com/rails/rails/pull/17348))
*   Déprécié `rake test:all:db` au profit de `rake test:db`.
    ([Pull Request](https://github.com/rails/rails/pull/17348))

*   Déprécié `Rails::Rack::LogTailer` sans remplacement.
    ([Commit](https://github.com/rails/rails/commit/84a13e019e93efaa8994b3f8303d635a7702dbce))

### Changements notables

*   Introduit `web-console` dans le `Gemfile` de l'application par défaut.
    ([Pull Request](https://github.com/rails/rails/pull/11667))

*   Ajouté une option `required` au générateur de modèle pour les associations.
    ([Pull Request](https://github.com/rails/rails/pull/16062))

*   Introduit l'espace de noms `x` pour définir des options de configuration personnalisées :

    ```ruby
    # config/environments/production.rb
    config.x.payment_processing.schedule = :daily
    config.x.payment_processing.retries  = 3
    config.x.super_debugger              = true
    ```

    Ces options sont ensuite disponibles via l'objet de configuration :

    ```ruby
    Rails.configuration.x.payment_processing.schedule # => :daily
    Rails.configuration.x.payment_processing.retries  # => 3
    Rails.configuration.x.super_debugger              # => true
    ```

    ([Commit](https://github.com/rails/rails/commit/611849772dd66c2e4d005dcfe153f7ce79a8a7db))

*   Introduit `Rails::Application.config_for` pour charger une configuration pour
    l'environnement actuel.

    ```yaml
    # config/exception_notification.yml
    production:
      url: http://127.0.0.1:8080
      namespace: my_app_production
    development:
      url: http://localhost:3001
      namespace: my_app_development
    ```

    ```ruby
    # config/environments/production.rb
    Rails.application.configure do
      config.middleware.use ExceptionNotifier, config_for(:exception_notification)
    end
    ```

    ([Pull Request](https://github.com/rails/rails/pull/16129))

*   Introduit une option `--skip-turbolinks` dans le générateur d'application pour ne pas générer
    l'intégration de turbolinks.
    ([Commit](https://github.com/rails/rails/commit/bf17c8a531bc8059d50ad731398002a3e7162a7d))

*   Introduit un script `bin/setup` en tant que convention pour le code de configuration automatisé lors
    de la création d'une application.
    ([Pull Request](https://github.com/rails/rails/pull/15189))

*   Changé la valeur par défaut de `config.assets.digest` à `true` en développement.
    ([Pull Request](https://github.com/rails/rails/pull/15155))

*   Introduit une API pour enregistrer de nouvelles extensions pour `rake notes`.
    ([Pull Request](https://github.com/rails/rails/pull/14379))

*   Introduit un rappel `after_bundle` à utiliser dans les modèles Rails.
    ([Pull Request](https://github.com/rails/rails/pull/16359))

*   Introduit `Rails.gem_version` en tant que méthode pratique pour retourner
    `Gem::Version.new(Rails.version)`.
    ([Pull Request](https://github.com/rails/rails/pull/14101))


Action Pack
-----------

Veuillez vous référer au [Changelog][action-pack] pour les changements détaillés.

### Suppressions

*   `respond_with` et `respond_to` au niveau de la classe ont été supprimés de Rails et
    déplacés vers le gem `responders` (version 2.0). Ajoutez `gem 'responders', '~> 2.0'`
    à votre `Gemfile` pour continuer à utiliser ces fonctionnalités.
    ([Pull Request](https://github.com/rails/rails/pull/16526),
     [Plus de détails](https://guides.rubyonrails.org/v4.2/upgrading_ruby_on_rails.html#responders))

*   Supprimé `AbstractController::Helpers::ClassMethods::MissingHelperError` déprécié
    au profit de `AbstractController::Helpers::MissingHelperError`.
    ([Commit](https://github.com/rails/rails/commit/a1ddde15ae0d612ff2973de9cf768ed701b594e8))

### Dépréciations

*   Dépréciée l'option `only_path` sur les helpers `*_path`.
    ([Commit](https://github.com/rails/rails/commit/aa1fadd48fb40dd9396a383696134a259aa59db9))

*   Déprécié `assert_tag`, `assert_no_tag`, `find_tag` et `find_all_tag` au
    profit de `assert_select`.
    ([Commit](https://github.com/rails/rails-dom-testing/commit/b12850bc5ff23ba4b599bf2770874dd4f11bf750))

*   Déprécié la prise en charge du réglage de l'option `:to` d'un routeur à un symbole ou une
    chaîne de caractères qui ne contient pas le caractère "#":

    ```ruby
    get '/posts', to: MyRackApp    => (Aucun changement nécessaire)
    get '/posts', to: 'post#index' => (Aucun changement nécessaire)
    get '/posts', to: 'posts'      => get '/posts', controller: :posts
    get '/posts', to: :index       => get '/posts', action: :index
    ```

    ([Commit](https://github.com/rails/rails/commit/cc26b6b7bccf0eea2e2c1a9ebdcc9d30ca7390d9))

*   Dépréciée la prise en charge des clés de chaîne dans les helpers d'URL :

    ```ruby
    # mauvais
    root_path('controller' => 'posts', 'action' => 'index')

    # bon
    root_path(controller: 'posts', action: 'index')
    ```

    ([Pull Request](https://github.com/rails/rails/pull/17743))

### Changements notables

*   La famille de méthodes `*_filter` a été supprimée de la documentation. Leur
    utilisation est déconseillée au profit de la famille de méthodes `*_action` :

    ```
    after_filter          => after_action
    append_after_filter   => append_after_action
    append_around_filter  => append_around_action
    append_before_filter  => append_before_action
    around_filter         => around_action
    before_filter         => before_action
    prepend_after_filter  => prepend_after_action
    prepend_around_filter => prepend_around_action
    prepend_before_filter => prepend_before_action
    skip_after_filter     => skip_after_action
    skip_around_filter    => skip_around_action
    skip_before_filter    => skip_before_action
    skip_filter           => skip_action_callback
    ```

    Si votre application dépend actuellement de ces méthodes, vous devriez utiliser les
    méthodes de remplacement `*_action` à la place. Ces méthodes seront dépréciées à
    l'avenir et seront finalement supprimées de Rails.

    (Commit [1](https://github.com/rails/rails/commit/6c5f43bab8206747a8591435b2aa0ff7051ad3de),
    [2](https://github.com/rails/rails/commit/489a8f2a44dc9cea09154ee1ee2557d1f037c7d4))

*   `render nothing: true` ou le rendu d'un corps `nil` n'ajoute plus un seul
    espace de remplissage au corps de la réponse.
    ([Pull Request](https://github.com/rails/rails/pull/14883))
* Rails inclut maintenant automatiquement le digest du template dans les ETags.
    ([Pull Request](https://github.com/rails/rails/pull/16527))

* Les segments passés aux helpers d'URL sont maintenant automatiquement échappés.
    ([Commit](https://github.com/rails/rails/commit/5460591f0226a9d248b7b4f89186bd5553e7768f))

* Introduction de l'option `always_permitted_parameters` pour configurer les paramètres autorisés globalement. La valeur par défaut de cette configuration est `['controller', 'action']`.
    ([Pull Request](https://github.com/rails/rails/pull/15933))

* Ajout de la méthode HTTP `MKCALENDAR` de [RFC 4791](https://tools.ietf.org/html/rfc4791).
    ([Pull Request](https://github.com/rails/rails/pull/15121))

* Les notifications `*_fragment.action_controller` incluent maintenant le nom du contrôleur et de l'action dans la charge utile.
    ([Pull Request](https://github.com/rails/rails/pull/14137))

* Amélioration de la page d'erreur de routage avec une recherche floue pour les routes.
    ([Pull Request](https://github.com/rails/rails/pull/14619))

* Ajout d'une option pour désactiver l'enregistrement des échecs de CSRF.
    ([Pull Request](https://github.com/rails/rails/pull/14280))

* Lorsque le serveur Rails est configuré pour servir des ressources statiques, les ressources gzip seront maintenant servies si le client le supporte et qu'un fichier gzip pré-généré (`.gz`) est présent sur le disque. Par défaut, le pipeline des ressources génère des fichiers `.gz` pour toutes les ressources compressibles. Le fait de servir des fichiers gzip réduit le transfert de données et accélère les requêtes de ressources. Utilisez toujours un CDN si vous servez des ressources depuis votre serveur Rails en production.
    ([Pull Request](https://github.com/rails/rails/pull/16466))

* Lors de l'appel des helpers `process` dans un test d'intégration, le chemin doit avoir une barre oblique initiale. Auparavant, vous pouviez l'omettre, mais c'était un sous-produit de l'implémentation et non une fonctionnalité intentionnelle, par exemple :

    ```ruby
    test "list all posts" do
      get "/posts"
      assert_response :success
    end
    ```

Action View
-----------

Veuillez vous référer au [journal des modifications][action-view] pour des changements détaillés.

### Dépréciations

* Dépréciation de `AbstractController::Base.parent_prefixes`. Remplacez-le par `AbstractController::Base.local_prefixes` lorsque vous souhaitez modifier l'emplacement des vues.
    ([Pull Request](https://github.com/rails/rails/pull/15026))

* Dépréciation de `ActionView::Digestor#digest(name, format, finder, options = {})`. Les arguments doivent être passés sous forme de hash.
    ([Pull Request](https://github.com/rails/rails/pull/14243))

### Changements notables

* `render "foo/bar"` se développe maintenant en `render template: "foo/bar"` au lieu de `render file: "foo/bar"`.
    ([Pull Request](https://github.com/rails/rails/pull/16888))

* Les helpers de formulaire ne génèrent plus un élément `<div>` avec du CSS en ligne autour des champs masqués.
    ([Pull Request](https://github.com/rails/rails/pull/14738))

* Introduction de la variable locale spéciale `#{partial_name}_iteration` à utiliser avec les partiels rendus avec une collection. Elle permet d'accéder à l'état actuel de l'itération via les méthodes `index`, `size`, `first?` et `last?`.
    ([Pull Request](https://github.com/rails/rails/pull/7698))

* Les traductions de l'attribut de substitution suivent la même convention que les traductions de `label`.
    ([Pull Request](https://github.com/rails/rails/pull/16438))


Action Mailer
-------------

Veuillez vous référer au [journal des modifications][action-mailer] pour des changements détaillés.

### Dépréciations

* Dépréciation des helpers `*_path` dans les mailers. Utilisez toujours les helpers `*_url` à la place.
    ([Pull Request](https://github.com/rails/rails/pull/15840))

* Dépréciation de `deliver` / `deliver!` au profit de `deliver_now` / `deliver_now!`.
    ([Pull Request](https://github.com/rails/rails/pull/16582))

### Changements notables

* `link_to` et `url_for` génèrent maintenant des URLs absolues par défaut dans les templates, il n'est plus nécessaire de passer `only_path: false`.
    ([Commit](https://github.com/rails/rails/commit/9685080a7677abfa5d288a81c3e078368c6bb67c))

* Introduction de `deliver_later` qui met en file d'attente une tâche dans la file d'attente de l'application pour envoyer des emails de manière asynchrone.
    ([Pull Request](https://github.com/rails/rails/pull/16485))

* Ajout de l'option de configuration `show_previews` pour activer les aperçus des mailers en dehors de l'environnement de développement.
    ([Pull Request](https://github.com/rails/rails/pull/15970))


Active Record
-------------

Veuillez vous référer au [journal des modifications][active-record] pour des changements détaillés.

### Suppressions

* Suppression de `cache_attributes` et des fonctions associées. Tous les attributs sont mis en cache.
    ([Pull Request](https://github.com/rails/rails/pull/15429))

* Suppression de la méthode dépréciée `ActiveRecord::Base.quoted_locking_column`.
    ([Pull Request](https://github.com/rails/rails/pull/15612))

* Suppression de `ActiveRecord::Migrator.proper_table_name` déprécié. Utilisez la méthode d'instance `proper_table_name` sur `ActiveRecord::Migration` à la place.
    ([Pull Request](https://github.com/rails/rails/pull/15512))

* Suppression du type `:timestamp` inutilisé. Il est maintenant automatiquement aliasé en `:datetime` dans tous les cas. Cela corrige les incohérences lorsque les types de colonnes sont envoyés en dehors d'Active Record, par exemple pour la sérialisation XML.
    ([Pull Request](https://github.com/rails/rails/pull/15184))
### Dépréciations

*   Dépréciation de la suppression des erreurs à l'intérieur de `after_commit` et `after_rollback`.
    ([Pull Request](https://github.com/rails/rails/pull/16537))

*   Dépréciation du support cassé pour la détection automatique des caches de compteur sur
    les associations `has_many :through`. Vous devriez plutôt spécifier manuellement
    le cache de compteur sur les associations `has_many` et `belongs_to` pour les
    enregistrements intermédiaires.
    ([Pull Request](https://github.com/rails/rails/pull/15754))

*   Dépréciation du passage d'objets Active Record à `.find` ou `.exists?`. Appelez
    `id` sur les objets en premier.
    (Commit [1](https://github.com/rails/rails/commit/d92ae6ccca3bcfd73546d612efaea011270bd270),
    [2](https://github.com/rails/rails/commit/d35f0033c7dec2b8d8b52058fb8db495d49596f7))

*   Dépréciation du support inachevé pour les valeurs de plage PostgreSQL avec exclusion
    des débuts. Nous mappions actuellement les plages PostgreSQL sur des plages Ruby. Cette conversion
    n'est pas entièrement possible car les plages Ruby ne prennent pas en charge les débuts exclus.

    La solution actuelle d'incrémenter le début n'est pas correcte
    et est maintenant dépréciée. Pour les sous-types où nous ne savons pas comment incrémenter
    (par exemple, `succ` n'est pas défini), cela lèvera une `ArgumentError` pour les plages
    avec des débuts exclus.
    ([Commit](https://github.com/rails/rails/commit/91949e48cf41af9f3e4ffba3e5eecf9b0a08bfc3))

*   Dépréciation de l'appel à `DatabaseTasks.load_schema` sans connexion. Utilisez
    plutôt `DatabaseTasks.load_schema_current`.
    ([Commit](https://github.com/rails/rails/commit/f15cef67f75e4b52fd45655d7c6ab6b35623c608))

*   Dépréciation de `sanitize_sql_hash_for_conditions` sans remplacement. Utiliser une
    `Relation` pour effectuer des requêtes et des mises à jour est l'API préférée.
    ([Commit](https://github.com/rails/rails/commit/d5902c9e))

*   Dépréciation de `add_timestamps` et `t.timestamps` sans passer l'option `:null`.
    La valeur par défaut de `null: true` changera dans Rails 5 pour `null: false`.
    ([Pull Request](https://github.com/rails/rails/pull/16481))

*   Dépréciation de `Reflection#source_macro` sans remplacement car il n'est plus
    nécessaire dans Active Record.
    ([Pull Request](https://github.com/rails/rails/pull/16373))

*   Dépréciation de `serialized_attributes` sans remplacement.
    ([Pull Request](https://github.com/rails/rails/pull/15704))

*   Dépréciation du retour de `nil` depuis `column_for_attribute` lorsque aucune colonne
    n'existe. Il renverra un objet nul dans Rails 5.0.
    ([Pull Request](https://github.com/rails/rails/pull/15878))

*   Dépréciation de l'utilisation de `.joins`, `.preload` et `.eager_load` avec des associations
    qui dépendent de l'état de l'instance (c'est-à-dire celles définies avec une portée qui
    prend un argument) sans remplacement.
    ([Commit](https://github.com/rails/rails/commit/ed56e596a0467390011bc9d56d462539776adac1))

### Changements notables

*   `SchemaDumper` utilise `force: :cascade` sur `create_table`. Cela permet
    de recharger un schéma lorsque des clés étrangères sont en place.

*   Ajout d'une option `:required` aux associations singulières, qui définit une
    validation de présence sur l'association.
    ([Pull Request](https://github.com/rails/rails/pull/16056))

*   `ActiveRecord::Dirty` détecte maintenant les modifications en place des valeurs mutables.
    Les attributs sérialisés sur les modèles Active Record ne sont plus enregistrés lorsque
    inchangés. Cela fonctionne également avec d'autres types tels que les colonnes de chaîne et les colonnes json
    sur PostgreSQL.
    (Pull Requests [1](https://github.com/rails/rails/pull/15674),
    [2](https://github.com/rails/rails/pull/15786),
    [3](https://github.com/rails/rails/pull/15788))

*   Introduction de la tâche Rake `db:purge` pour vider la base de données de l'
    environnement actuel.
    ([Commit](https://github.com/rails/rails/commit/e2f232aba15937a4b9d14bd91e0392c6d55be58d))

*   Introduction de `ActiveRecord::Base#validate!` qui lève
    `ActiveRecord::RecordInvalid` si l'enregistrement est invalide.
    ([Pull Request](https://github.com/rails/rails/pull/8639))

*   Introduction de `validate` comme alias de `valid?`.
    ([Pull Request](https://github.com/rails/rails/pull/14456))

*   `touch` accepte maintenant plusieurs attributs à toucher en une seule fois.
    ([Pull Request](https://github.com/rails/rails/pull/14423))

*   L'adaptateur PostgreSQL prend désormais en charge le type de données `jsonb` dans PostgreSQL 9.4+.
    ([Pull Request](https://github.com/rails/rails/pull/16220))

*   Les adaptateurs PostgreSQL et SQLite n'ajoutent plus une limite par défaut de 255
    caractères sur les colonnes de chaîne.
    ([Pull Request](https://github.com/rails/rails/pull/14579))

*   Ajout de la prise en charge du type de colonne `citext` dans l'adaptateur PostgreSQL.
    ([Pull Request](https://github.com/rails/rails/pull/12523))

*   Ajout de la prise en charge des types de plage créés par l'utilisateur dans l'adaptateur PostgreSQL.
    ([Commit](https://github.com/rails/rails/commit/4cb47167e747e8f9dc12b0ddaf82bdb68c03e032))

*   `sqlite3:///some/path` se résout maintenant au chemin absolu du système
    `/some/path`. Pour les chemins relatifs, utilisez plutôt `sqlite3:some/path`.
    (Auparavant, `sqlite3:///some/path` se résolvait au chemin relatif
    `some/path`. Ce comportement a été déprécié dans Rails 4.1).
    ([Pull Request](https://github.com/rails/rails/pull/14569))

*   Ajout de la prise en charge des secondes fractionnaires pour MySQL 5.6 et supérieur.
    (Pull Request [1](https://github.com/rails/rails/pull/8240),
    [2](https://github.com/rails/rails/pull/14359))
*   Ajout de `ActiveRecord::Base#pretty_print` pour afficher joliment les modèles.
    ([Demande de tirage](https://github.com/rails/rails/pull/15172))

*   `ActiveRecord::Base#reload` se comporte désormais de la même manière que `m = Model.find(m.id)`,
    ce qui signifie qu'il ne conserve plus les attributs supplémentaires des
    `SELECT` personnalisés.
    ([Demande de tirage](https://github.com/rails/rails/pull/15866))

*   `ActiveRecord::Base#reflections` renvoie maintenant un hash avec des clés de chaîne au lieu
    de clés de symbole. ([Demande de tirage](https://github.com/rails/rails/pull/17718))

*   La méthode `references` dans les migrations prend désormais en charge une option `type` pour
    spécifier le type de la clé étrangère (par exemple, `:uuid`).
    ([Demande de tirage](https://github.com/rails/rails/pull/16231))

Active Model
------------

Veuillez vous référer au [journal des modifications][active-model] pour des changements détaillés.

### Suppressions

*   Suppression de `Validator#setup` obsolète sans remplacement.
    ([Demande de tirage](https://github.com/rails/rails/pull/10716))

### Obsolescence

*   `reset_#{attribute}` est obsolète au profit de `restore_#{attribute}`.
    ([Demande de tirage](https://github.com/rails/rails/pull/16180))

*   `ActiveModel::Dirty#reset_changes` est obsolète au profit de
    `clear_changes_information`.
    ([Demande de tirage](https://github.com/rails/rails/pull/16180))

### Changements notables

*   Introduction de `validate` en tant qu'alias de `valid?`.
    ([Demande de tirage](https://github.com/rails/rails/pull/14456))

*   Introduction de la méthode `restore_attributes` dans `ActiveModel::Dirty` pour restaurer
    les attributs modifiés (sales) à leurs valeurs précédentes.
    (Demande de tirage [1](https://github.com/rails/rails/pull/14861),
    [2](https://github.com/rails/rails/pull/16180))

*   `has_secure_password` n'interdit plus les mots de passe vides (c'est-à-dire les mots de passe
    qui ne contiennent que des espaces) par défaut.
    ([Demande de tirage](https://github.com/rails/rails/pull/16412))

*   `has_secure_password` vérifie désormais que le mot de passe donné a moins de 72
    caractères si les validations sont activées.
    ([Demande de tirage](https://github.com/rails/rails/pull/15708))

Active Support
--------------

Veuillez vous référer au [journal des modifications][active-support] pour des changements détaillés.

### Suppressions

*   Suppression de `Numeric#ago`, `Numeric#until`, `Numeric#since`,
    `Numeric#from_now` obsolètes.
    ([Commit](https://github.com/rails/rails/commit/f1eddea1e3f6faf93581c43651348f48b2b7d8bb))

*   Suppression des terminaisons basées sur des chaînes obsolètes pour `ActiveSupport::Callbacks`.
    ([Demande de tirage](https://github.com/rails/rails/pull/15100))

### Obsolescence

*   `Kernel#silence_stderr`, `Kernel#capture` et `Kernel#quietly` sont obsolètes sans remplacement.
    ([Demande de tirage](https://github.com/rails/rails/pull/13392))

*   `Class#superclass_delegating_accessor` est obsolète, utilisez
    `Class#class_attribute` à la place.
    ([Demande de tirage](https://github.com/rails/rails/pull/14271))

*   `ActiveSupport::SafeBuffer#prepend!` est obsolète car
    `ActiveSupport::SafeBuffer#prepend` effectue désormais la même fonction.
    ([Demande de tirage](https://github.com/rails/rails/pull/14529))

### Changements notables

*   Introduction d'une nouvelle option de configuration `active_support.test_order` pour
    spécifier l'ordre d'exécution des cas de test. Cette option est actuellement définie par défaut
    sur `:sorted`, mais sera modifiée en `:random` dans Rails 5.0.
    ([Commit](https://github.com/rails/rails/commit/53e877f7d9291b2bf0b8c425f9e32ef35829f35b))

*   `Object#try` et `Object#try!` peuvent désormais être utilisés sans un récepteur explicite dans le bloc.
    ([Commit](https://github.com/rails/rails/commit/5e51bdda59c9ba8e5faf86294e3e431bd45f1830),
    [Demande de tirage](https://github.com/rails/rails/pull/17361))

*   L'assistant de test `travel_to` tronque désormais la composante `usec` à 0.
    ([Commit](https://github.com/rails/rails/commit/9f6e82ee4783e491c20f5244a613fdeb4024beb5))

*   Introduction de `Object#itself` en tant que fonction d'identité.
    (Commit [1](https://github.com/rails/rails/commit/702ad710b57bef45b081ebf42e6fa70820fdd810),
    [2](https://github.com/rails/rails/commit/64d91122222c11ad3918cc8e2e3ebc4b0a03448a))

*   `Object#with_options` peut désormais être utilisé sans un récepteur explicite dans le bloc.
    ([Demande de tirage](https://github.com/rails/rails/pull/16339))

*   Introduction de `String#truncate_words` pour tronquer une chaîne par un certain nombre de mots.
    ([Demande de tirage](https://github.com/rails/rails/pull/16190))

*   Ajout de `Hash#transform_values` et `Hash#transform_values!` pour simplifier un
    modèle courant où les valeurs d'un hash doivent changer, mais les clés restent
    les mêmes.
    ([Demande de tirage](https://github.com/rails/rails/pull/15819))

*   L'assistant d'inflection `humanize` supprime désormais tous les tirets bas initiaux.
    ([Commit](https://github.com/rails/rails/commit/daaa21bc7d20f2e4ff451637423a25ff2d5e75c7))

*   Introduction de `Concern#class_methods` en tant qu'alternative à
    `module ClassMethods`, ainsi que `Kernel#concern` pour éviter le
    boilerplate `module Foo; extend ActiveSupport::Concern; end`.
    ([Commit](https://github.com/rails/rails/commit/b16c36e688970df2f96f793a759365b248b582ad))

*   Nouveau [guide](autoloading_and_reloading_constants_classic_mode.html) sur le chargement automatique et le rechargement des constantes.

Crédits
-------

Consultez la
[liste complète des contributeurs à Rails](https://contributors.rubyonrails.org/) pour
les nombreuses personnes qui ont passé de nombreuses heures à faire de Rails le framework stable et robuste
qu'il est aujourd'hui. Félicitations à tous.
[active-support]: https://github.com/rails/rails/blob/4-2-stable/activesupport/CHANGELOG.md
