**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 4d8311a1435138a81e26a7e8f537dbde
Ruby on Rails 4.2 Notes de version
==================================

Points forts de Rails 4.2 :

* Active Job
* Mails asynchrones
* Adequate Record
* Web Console
* Support des clés étrangères

Ces notes de version ne couvrent que les changements majeurs. Pour en savoir plus sur les autres fonctionnalités, les corrections de bugs et les changements, veuillez vous référer aux journaux des modifications ou consulter la [liste des commits](https://github.com/rails/rails/commits/4-2-stable) dans le référentiel principal de Rails sur GitHub.

--------------------------------------------------------------------------------

Mise à niveau vers Rails 4.2
---------------------------

Si vous mettez à niveau une application existante, il est conseillé d'avoir une bonne couverture de tests avant de commencer. Vous devriez également d'abord passer à Rails 4.1 au cas où vous ne l'auriez pas déjà fait et vous assurer que votre application fonctionne toujours comme prévu avant de tenter de passer à Rails 4.2. Une liste de points à surveiller lors de la mise à niveau est disponible dans le guide [Mise à niveau de Ruby on Rails](upgrading_ruby_on_rails.html#upgrading-from-rails-4-1-to-rails-4-2).

Fonctionnalités majeures
------------------------

### Active Job

Active Job est un nouveau framework dans Rails 4.2. Il s'agit d'une interface commune au-dessus des systèmes de mise en file d'attente tels que [Resque](https://github.com/resque/resque), [Delayed Job](https://github.com/collectiveidea/delayed_job), [Sidekiq](https://github.com/mperham/sidekiq) et d'autres.

Les jobs écrits avec l'API Active Job s'exécutent sur l'une des files d'attente prises en charge grâce à leurs adaptateurs respectifs. Active Job est préconfiguré avec un exécuteur en ligne qui exécute les jobs immédiatement.

Les jobs ont souvent besoin de prendre des objets Active Record en tant qu'arguments. Active Job passe les références d'objets sous forme d'URI (uniform resource identifiers) au lieu de sérialiser l'objet lui-même. La nouvelle bibliothèque [Global ID](https://github.com/rails/globalid) construit les URIs et recherche les objets auxquels ils font référence. Le passage d'objets Active Record en tant qu'arguments de job fonctionne simplement en utilisant Global ID en interne.

Par exemple, si `trashable` est un objet Active Record, alors ce job s'exécute sans problème et sans sérialisation :

```ruby
class TrashableCleanupJob < ActiveJob::Base
  def perform(trashable, depth)
    trashable.cleanup(depth)
  end
end
```

Consultez le guide [Active Job Basics](active_job_basics.html) pour plus d'informations.

### Mails asynchrones

En s'appuyant sur Active Job, Action Mailer est maintenant livré avec une méthode `deliver_later` qui envoie les emails via la file d'attente, de sorte qu'elle ne bloque pas le contrôleur ou le modèle si la file d'attente est asynchrone (la file d'attente en ligne par défaut bloque).

L'envoi immédiat des emails est toujours possible avec `deliver_now`.

### Adequate Record

Adequate Record est un ensemble d'améliorations de performances dans Active Record qui rendent les appels courants `find` et `find_by` ainsi que certaines requêtes d'association jusqu'à 2 fois plus rapides.

Cela fonctionne en mettant en cache les requêtes SQL courantes sous forme de déclarations préparées et en les réutilisant lors d'appels similaires, en sautant une grande partie du travail de génération de requête lors d'appels ultérieurs. Pour plus de détails, veuillez vous référer au billet de blog d'[Aaron Patterson](http://tenderlovemaking.com/2014/02/19/adequaterecord-pro-like-activerecord.html).

Active Record tirera automatiquement parti de cette fonctionnalité sur les opérations prises en charge sans aucune intervention de l'utilisateur ou modifications de code. Voici quelques exemples d'opérations prises en charge :

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

La mise en cache n'est pas utilisée dans les scénarios suivants :

- Le modèle a une portée par défaut
- Le modèle utilise l'héritage de table unique
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

### Web Console

Les nouvelles applications générées avec Rails 4.2 sont maintenant livrées avec la gem [Web Console](https://github.com/rails/web-console) par défaut. Web Console ajoute une console Ruby interactive sur chaque page d'erreur et fournit une vue et des helpers de contrôleur `console`.

La console interactive sur les pages d'erreur vous permet d'exécuter du code dans le contexte de l'endroit où l'exception s'est produite. Le helper `console`, s'il est appelé n'importe où dans une vue ou un contrôleur, lance une console interactive avec le contexte final, une fois le rendu terminé.

### Support des clés étrangères

Le DSL de migration prend désormais en charge l'ajout et la suppression de clés étrangères. Elles sont également incluses dans le fichier `schema.rb`. À l'heure actuelle, seuls les adaptateurs `mysql`, `mysql2` et `postgresql` prennent en charge les clés étrangères.

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
Voir la documentation de l'API sur
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

Auparavant, l'appel à `render "foo/bar"` dans une action du contrôleur était équivalent à
`render file: "foo/bar"`. Dans Rails 4.2, cela a été modifié pour signifier
`render template: "foo/bar"` à la place. Si vous devez afficher un fichier, veuillez
modifier votre code pour utiliser la forme explicite (`render file: "foo/bar"`) à la place.

### `respond_with` / `respond_to` au niveau de la classe

`respond_with` et `respond_to` au niveau de la classe ont été déplacés
vers le gem [responders](https://github.com/plataformatec/responders). Ajoutez
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

`respond_to` au niveau de l'instance n'est pas affecté :

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

En raison d'un [changement dans Rack](https://github.com/rack/rack/commit/be28c6a2ac152fe4adfbef71f3db9f4200df89e8), les symboles que la méthode `render` accepte pour l'option `:status` ont changé :

- 306 : `:reserved` a été supprimé.
- 413 : `:request_entity_too_large` a été renommé en `:payload_too_large`.
- 414 : `:request_uri_too_long` a été renommé en `:uri_too_long`.
- 416 : `:requested_range_not_satisfiable` a été renommé en `:range_not_satisfiable`.

Gardez à l'esprit que si vous appelez `render` avec un symbole inconnu, le statut de la réponse sera par défaut 500.

### Sanitiseur HTML

Le sanitiseur HTML a été remplacé par une nouvelle implémentation plus robuste
basée sur [Loofah](https://github.com/flavorjones/loofah) et
[Nokogiri](https://github.com/sparklemotion/nokogiri). Le nouveau sanitiseur est
plus sécurisé et sa désinfection est plus puissante et flexible.

En raison du nouvel algorithme, la sortie désinfectée peut être différente pour certaines
entrées pathologiques.

Si vous avez besoin d'une sortie exacte du sanitiseur précédent, vous
pouvez ajouter le gem [rails-deprecated_sanitizer](https://github.com/kaspth/rails-deprecated_sanitizer)
à votre `Gemfile`, pour avoir le comportement précédent. Le gem ne génère pas
de messages de dépréciation car il est facultatif.

`rails-deprecated_sanitizer` sera pris en charge uniquement pour Rails 4.2 ; il ne sera pas
maintenu pour Rails 5.0.

Consultez [cet article de blog](https://blog.plataformatec.com.br/2014/07/the-new-html-sanitizer-in-rails-4-2/)
pour plus de détails sur les changements dans le nouveau sanitiseur.

### `assert_select`

`assert_select` est maintenant basé sur [Nokogiri](https://github.com/sparklemotion/nokogiri).
Par conséquent, certains sélecteurs précédemment valides ne sont plus pris en charge. Si votre
application utilise l'une de ces orthographes, vous devrez les mettre à jour :

*   Les valeurs dans les sélecteurs d'attributs peuvent nécessiter des guillemets s'ils contiennent
    des caractères non alphanumériques.

    ```ruby
    # avant
    a[href=/]
    a[href$=/]

    # maintenant
    a[href="/"]
    a[href$="/"]
    ```

*   Les DOM construits à partir d'une source HTML contenant du HTML invalide avec des éléments
    mal imbriqués peuvent différer.

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

*   Si les données sélectionnées contiennent des entités, la valeur sélectionnée pour la comparaison
    était brute (par exemple `AT&amp;T`), et maintenant elle est évaluée
    (par exemple `AT&T`).

    ```ruby
    # contenu : <p>AT&amp;T</p>

    # avant :
    assert_select('p', 'AT&amp;T')  # => true
    assert_select('p', 'AT&T')      # => false

    # maintenant :
    assert_select('p', 'AT&T')      # => true
    assert_select('p', 'AT&amp;T')  # => false
    ```

De plus, la syntaxe des substitutions a changé.

Maintenant, vous devez utiliser un sélecteur `:match` similaire à CSS :

```ruby
assert_select ":match('id', ?)", 'comment_1'
```

De plus, les substitutions Regexp ont un aspect différent lorsque l'assertion échoue.
Remarquez comment `/hello/` est utilisé ici :

```ruby
assert_select(":match('id', ?)", /hello/)
```
devient `"(?-mix:hello)"` :

```
Au moins 1 élément correspondant à "div:match('id', "(?-mix:hello)")" était attendu, mais 0 ont été trouvés.
Il était attendu que 0 soit >= 1.
```

Consultez la documentation de [Rails Dom Testing](https://github.com/rails/rails-dom-testing/tree/8798b9349fb9540ad8cb9a0ce6cb88d1384a210b) pour en savoir plus sur `assert_select`.


Railties
--------

Veuillez vous référer au [journal des modifications][railties] pour plus de détails sur les changements.

### Suppressions

*   L'option `--skip-action-view` a été supprimée du générateur d'applications. ([Demande de tirage](https://github.com/rails/rails/pull/17042))

*   La commande `rails application` a été supprimée sans remplacement. ([Demande de tirage](https://github.com/rails/rails/pull/11616))

### Dépréciations

*   `config.log_level` manquant a été déprécié pour les environnements de production. ([Demande de tirage](https://github.com/rails/rails/pull/16622))

*   `rake test:all` a été déprécié au profit de `rake test` car il exécute maintenant tous les tests du dossier `test`. ([Demande de tirage](https://github.com/rails/rails/pull/17348))

*   `rake test:all:db` a été déprécié au profit de `rake test:db`. ([Demande de tirage](https://github.com/rails/rails/pull/17348))

*   `Rails::Rack::LogTailer` a été déprécié sans remplacement. ([Commit](https://github.com/rails/rails/commit/84a13e019e93efaa8994b3f8303d635a7702dbce))

### Changements notables

*   Introduction de `web-console` dans le fichier `Gemfile` de l'application par défaut. ([Demande de tirage](https://github.com/rails/rails/pull/11667))

*   Ajout d'une option `required` au générateur de modèles pour les associations. ([Demande de tirage](https://github.com/rails/rails/pull/16062))

*   Introduction de l'espace de noms `x` pour définir des options de configuration personnalisées :

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

*   Introduction de `Rails::Application.config_for` pour charger une configuration pour l'environnement actuel.

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

    ([Demande de tirage](https://github.com/rails/rails/pull/16129))

*   Introduction de l'option `--skip-turbolinks` dans le générateur d'applications pour ne pas générer l'intégration de turbolinks. ([Commit](https://github.com/rails/rails/commit/bf17c8a531bc8059d50ad731398002a3e7162a7d))

*   Introduction d'un script `bin/setup` en tant que convention pour le code de configuration automatisé lors du démarrage d'une application. ([Demande de tirage](https://github.com/rails/rails/pull/15189))

*   Modification de la valeur par défaut de `config.assets.digest` à `true` en développement. ([Demande de tirage](https://github.com/rails/rails/pull/15155))

*   Introduction d'une API pour enregistrer de nouvelles extensions pour `rake notes`. ([Demande de tirage](https://github.com/rails/rails/pull/14379))

*   Introduction d'un rappel `after_bundle` à utiliser dans les modèles Rails. ([Demande de tirage](https://github.com/rails/rails/pull/16359))

*   Introduction de `Rails.gem_version` en tant que méthode de commodité pour retourner `Gem::Version.new(Rails.version)`. ([Demande de tirage](https://github.com/rails/rails/pull/14101))


Action Pack
-----------

Veuillez vous référer au [journal des modifications][action-pack] pour plus de détails sur les changements.

### Suppressions

*   `respond_with` et `respond_to` au niveau de la classe ont été supprimés de Rails et déplacés vers la gemme `responders` (version 2.0). Ajoutez `gem 'responders', '~> 2.0'` à votre `Gemfile` pour continuer à utiliser ces fonctionnalités. ([Demande de tirage](https://github.com/rails/rails/pull/16526), [Plus de détails](https://guides.rubyonrails.org/v4.2/upgrading_ruby_on_rails.html#responders))

*   Suppression de `AbstractController::Helpers::ClassMethods::MissingHelperError` déprécié au profit de `AbstractController::Helpers::MissingHelperError`. ([Commit](https://github.com/rails/rails/commit/a1ddde15ae0d612ff2973de9cf768ed701b594e8))

### Dépréciations

*   Dépréciation de l'option `only_path` sur les helpers `*_path`. ([Commit](https://github.com/rails/rails/commit/aa1fadd48fb40dd9396a383696134a259aa59db9))

*   Dépréciation de `assert_tag`, `assert_no_tag`, `find_tag` et `find_all_tag` au profit de `assert_select`. ([Commit](https://github.com/rails/rails-dom-testing/commit/b12850bc5ff23ba4b599bf2770874dd4f11bf750))

*   Dépréciation du support de définir l'option `:to` d'un routeur sur un symbole ou une chaîne ne contenant pas le caractère "#":

    ```ruby
    get '/posts', to: MyRackApp    => (Aucun changement nécessaire)
    get '/posts', to: 'post#index' => (Aucun changement nécessaire)
    get '/posts', to: 'posts'      => get '/posts', controller: :posts
    get '/posts', to: :index       => get '/posts', action: :index
    ```

    ([Commit](https://github.com/rails/rails/commit/cc26b6b7bccf0eea2e2c1a9ebdcc9d30ca7390d9))

*   Dépréciation du support des clés de chaîne dans les helpers d'URL :

    ```ruby
    # mauvais
    root_path('controller' => 'posts', 'action' => 'index')

    # bon
    root_path(controller: 'posts', action: 'index')
    ```

    ([Demande de tirage](https://github.com/rails/rails/pull/17743))

### Changements notables

*   La famille de méthodes `*_filter` a été supprimée de la documentation. Leur utilisation est déconseillée au profit de la famille de méthodes `*_action` :

    ```
    after_filter          => after_action

*   Lorsque le serveur Rails est configuré pour servir des ressources statiques, les ressources gzip seront désormais servies si le client le supporte et qu'un fichier gzip pré-généré (`.gz`) est présent sur le disque. Par défaut, le pipeline des ressources génère des fichiers `.gz` pour toutes les ressources compressibles. Le fait de servir des fichiers gzip réduit le transfert de données et accélère les requêtes de ressources. Utilisez toujours un CDN si vous servez des ressources depuis votre serveur Rails en production. ([Pull Request](https://github.com/rails/rails/pull/16466))

*   Lors de l'appel des helpers `process` dans un test d'intégration, le chemin doit avoir un slash initial. Auparavant, vous pouviez l'omettre, mais c'était un sous-produit de l'implémentation et non une fonctionnalité intentionnelle, par exemple :

    ```ruby
    test "list all posts" do
      get "/posts"
      assert_response :success
    end
    ```

Action View
-----------

Veuillez vous référer au [Changelog][action-view] pour plus de détails sur les changements.

### Dépréciations

*   `AbstractController::Base.parent_prefixes` est désormais déprécié. Utilisez `AbstractController::Base.local_prefixes` lorsque vous souhaitez modifier l'emplacement des vues. ([Pull Request](https://github.com/rails/rails/pull/15026))

*   `ActionView::Digestor#digest(name, format, finder, options = {})` est désormais déprécié. Les arguments doivent être passés sous forme de hash à la place. ([Pull Request](https://github.com/rails/rails/pull/14243))

### Changements notables

*   `render "foo/bar"` se développe désormais en `render template: "foo/bar"` au lieu de `render file: "foo/bar"`. ([Pull Request](https://github.com/rails/rails/pull/16888))

*   Les helpers de formulaire ne génèrent plus un élément `<div>` avec du CSS en ligne autour des champs masqués. ([Pull Request](https://github.com/rails/rails/pull/14738))

*   Introduction d'une variable locale spéciale `#{partial_name}_iteration` à utiliser avec les partials qui sont rendus avec une collection. Elle permet d'accéder à l'état actuel de l'itération via les méthodes `index`, `size`, `first?` et `last?`. ([Pull Request](https://github.com/rails/rails/pull/7698))

*   La traduction de l'attribut `placeholder` suit la même convention que la traduction de `label`. ([Pull Request](https://github.com/rails/rails/pull/16438))


Action Mailer
-------------

Veuillez vous référer au [Changelog][action-mailer] pour plus de détails sur les changements.

### Dépréciations

*   Les helpers `*_path` dans les mailers sont désormais dépréciés. Utilisez toujours les helpers `*_url` à la place. ([Pull Request](https://github.com/rails/rails/pull/15840))

*   Les méthodes `deliver` / `deliver!` sont désormais dépréciées au profit de `deliver_now` / `deliver_now!`. ([Pull Request](https://github.com/rails/rails/pull/16582))

### Changements notables

*   `link_to` et `url_for` génèrent désormais des URLs absolues par défaut dans les templates, il n'est donc plus nécessaire de passer `only_path: false`. ([Commit](https://github.com/rails/rails/commit/9685080a7677abfa5d288a81c3e078368c6bb67c))

*   Introduction de `deliver_later` qui met en file d'attente une tâche pour envoyer les emails de manière asynchrone. ([Pull Request](https://github.com/rails/rails/pull/16485))

*   Ajout de l'option de configuration `show_previews` pour activer les aperçus des mailers en dehors de l'environnement de développement. ([Pull Request](https://github.com/rails/rails/pull/15970))


Active Record
-------------

Veuillez vous référer au [Changelog][active-record] pour plus de détails sur les changements.

### Suppressions

*   Suppression de `cache_attributes` et des fonctions associées. Tous les attributs sont maintenant mis en cache. ([Pull Request](https://github.com/rails/rails/pull/15429))

*   Suppression de la méthode dépréciée `ActiveRecord::Base.quoted_locking_column`. ([Pull Request](https://github.com/rails/rails/pull/15612))

*   Suppression de `ActiveRecord::Migrator.proper_table_name` déprécié. Utilisez la méthode d'instance `proper_table_name` sur `ActiveRecord::Migration` à la place. ([Pull Request](https://github.com/rails/rails/pull/15512))

*   Suppression du type `:timestamp` inutilisé. Il est maintenant automatiquement aliasé en `:datetime` dans tous les cas. Cela corrige les incohérences lorsque les types de colonnes sont envoyés en dehors d'Active Record, par exemple pour la sérialisation XML. ([Pull Request](https://github.com/rails/rails/pull/15184))

### Dépréciations

*   Dépréciation de la suppression des erreurs à l'intérieur des callbacks `after_commit` et `after_rollback`. ([Pull Request](https://github.com/rails/rails/pull/16537))

*   Dépréciation du support défectueux de la détection automatique des caches de compteur sur les associations `has_many :through`. Vous devez maintenant spécifier manuellement le cache de compteur sur les associations `has_many` et `belongs_to` pour les enregistrements intermédiaires. ([Pull Request](https://github.com/rails/rails/pull/15754))

*   Dépréciation de la possibilité de passer des objets Active Record à `.find` ou `.exists?`. Appelez d'abord `id` sur les objets. (Commit [1](https://github.com/rails/rails/commit/d92ae6ccca3bcfd73546d612efaea011270bd270), [2](https://github.com/rails/rails/commit/d35f0033c7dec2b8d8b52058fb8db495d49596f7))

*   Dépréciation du support incomplet des valeurs de plage PostgreSQL avec des débuts exclus. Nous mappons actuellement les plages PostgreSQL sur les plages Ruby. Cette conversion n'est pas entièrement possible car les plages Ruby ne prennent pas en charge les débuts exclus.

    La solution actuelle d'incrémenter le début n'est pas correcte et est désormais dépréciée. Pour les sous-types où nous ne savons pas comment incrémenter (par exemple, lorsque `succ` n'est pas défini), une `ArgumentError` sera levée pour les plages avec des débuts exclus. ([Commit](https://github.com/rails/rails/commit/91949e48cf41af9f3e4ffba3e5eecf9b0a08bfc3))

*   Dépréciation de l'appel à `DatabaseTasks.load_schema` sans connexion. Utilisez plutôt `DatabaseTasks.load_schema_current`. ([Commit](https://github.com/rails/rails/commit/f15cef67f75e4b52fd45655d7c6ab6b35623c608))

*   Dépréciation de `sanitize_sql_hash_for_conditions` sans remplacement. L'utilisation d'une `Relation` pour effectuer des requêtes et des mises à jour est l'API préférée. ([Commit](https://github.com/rails/rails/commit/d5902c9e))

*   Dépréciation de `add_timestamps` et `t.timestamps` sans passer l'option `:null`. La valeur par défaut de `null: true` sera modifiée en `null: false` dans Rails 5. ([Pull Request](https://github.com/rails/rails/pull/16481))

*   Dépréciation de `Reflection#source_macro` sans remplacement car il n'est plus nécessaire dans Active Record. ([Pull Request](https://github.com/rails/rails/pull/16373))

*   Dépréciation de `serialized_attributes` sans remplacement. ([Pull Request](https://github.com/rails/rails/pull/15704))

*   Dépréciation du retour de `nil` depuis `column_for_attribute` lorsque la colonne n'existe pas. Il renverra un objet nul dans Rails 5.0. ([Pull Request](https://github.com/rails/rails/pull/15878))

*   Dépréciation de l'utilisation de `.joins`, `.preload` et `.eager_load` avec des associations qui dépendent de l'état de l'instance (c'est-à-dire celles définies avec une portée prenant un argument) sans remplacement. ([Commit](https://github.com/rails/rails/commit/ed56e596a0467390011bc9d56d462539776adac1))

### Changements notables

*   `SchemaDumper` utilise `force: :cascade` sur `create_table`. Cela permet de recharger un schéma lorsque des clés étrangères sont en place.
*   Ajout d'une option `:required` aux associations singulières, qui définit une validation de présence sur l'association.
    ([Demande de tirage](https://github.com/rails/rails/pull/16056))

*   `ActiveRecord::Dirty` détecte maintenant les modifications sur place des valeurs mutables. Les attributs sérialisés des modèles Active Record ne sont plus enregistrés lorsqu'ils ne sont pas modifiés. Cela fonctionne également avec d'autres types tels que les colonnes de chaînes de caractères et les colonnes JSON sur PostgreSQL.
    (Demandes de tirage [1](https://github.com/rails/rails/pull/15674),
    [2](https://github.com/rails/rails/pull/15786),
    [3](https://github.com/rails/rails/pull/15788))

*   Introduction de la tâche Rake `db:purge` pour vider la base de données de l'environnement actuel.
    (Commit [1](https://github.com/rails/rails/commit/e2f232aba15937a4b9d14bd91e0392c6d55be58d))

*   Introduction de `ActiveRecord::Base#validate!` qui génère une exception `ActiveRecord::RecordInvalid` si l'enregistrement est invalide.
    (Demande de tirage](https://github.com/rails/rails/pull/8639))

*   Introduction de `validate` comme alias de `valid?`.
    ([Demande de tirage](https://github.com/rails/rails/pull/14456))

*   `touch` accepte maintenant plusieurs attributs à mettre à jour en même temps.
    ([Demande de tirage](https://github.com/rails/rails/pull/14423))

*   L'adaptateur PostgreSQL prend maintenant en charge le type de données `jsonb` dans PostgreSQL 9.4+.
    ([Demande de tirage](https://github.com/rails/rails/pull/16220))

*   Les adaptateurs PostgreSQL et SQLite n'ajoutent plus une limite par défaut de 255 caractères sur les colonnes de chaînes de caractères.
    ([Demande de tirage](https://github.com/rails/rails/pull/14579))

*   Ajout de la prise en charge du type de colonne `citext` dans l'adaptateur PostgreSQL.
    ([Demande de tirage](https://github.com/rails/rails/pull/12523))

*   Ajout de la prise en charge des types de plage créés par l'utilisateur dans l'adaptateur PostgreSQL.
    ([Commit](https://github.com/rails/rails/commit/4cb47167e747e8f9dc12b0ddaf82bdb68c03e032))

*   `sqlite3:///some/path` est maintenant résolu en tant que chemin absolu du système `/some/path`. Pour les chemins relatifs, utilisez `sqlite3:some/path` à la place. (Auparavant, `sqlite3:///some/path` était résolu en tant que chemin relatif `some/path`. Ce comportement a été déprécié dans Rails 4.1).
    ([Demande de tirage](https://github.com/rails/rails/pull/14569))

*   Ajout de la prise en charge des secondes fractionnaires pour MySQL 5.6 et supérieur.
    (Demande de tirage [1](https://github.com/rails/rails/pull/8240),
    [2](https://github.com/rails/rails/pull/14359))

*   Ajout de `ActiveRecord::Base#pretty_print` pour afficher joliment les modèles.
    ([Demande de tirage](https://github.com/rails/rails/pull/15172))

*   `ActiveRecord::Base#reload` se comporte maintenant de la même manière que `m = Model.find(m.id)`, ce qui signifie qu'il ne conserve plus les attributs supplémentaires des `SELECT` personnalisés.
    ([Demande de tirage](https://github.com/rails/rails/pull/15866))

*   `ActiveRecord::Base#reflections` renvoie maintenant un hachage avec des clés de chaînes de caractères au lieu de clés de symboles. ([Demande de tirage](https://github.com/rails/rails/pull/17718))

*   La méthode `references` dans les migrations prend maintenant en charge une option `type` pour spécifier le type de la clé étrangère (par exemple, `:uuid`).
    ([Demande de tirage](https://github.com/rails/rails/pull/16231))

Active Model
------------

Veuillez vous référer au [journal des modifications][active-model] pour des changements détaillés.

### Suppressions

*   Suppression de `Validator#setup` déprécié sans remplacement.
    ([Demande de tirage](https://github.com/rails/rails/pull/10716))

### Dépréciations

*   Dépréciation de `reset_#{attribute}` au profit de `restore_#{attribute}`.
    ([Demande de tirage](https://github.com/rails/rails/pull/16180))

*   Dépréciation de `ActiveModel::Dirty#reset_changes` au profit de `clear_changes_information`.
    ([Demande de tirage](https://github.com/rails/rails/pull/16180))

### Changements notables

*   Introduction de `validate` comme alias de `valid?`.
    ([Demande de tirage](https://github.com/rails/rails/pull/14456))

*   Introduction de la méthode `restore_attributes` dans `ActiveModel::Dirty` pour restaurer les attributs modifiés (sales) à leurs valeurs précédentes.
    (Demande de tirage [1](https://github.com/rails/rails/pull/14861),
    [2](https://github.com/rails/rails/pull/16180))

*   `has_secure_password` n'interdit plus les mots de passe vides (c'est-à-dire les mots de passe ne contenant que des espaces) par défaut.
    ([Demande de tirage](https://github.com/rails/rails/pull/16412))

*   `has_secure_password` vérifie maintenant que le mot de passe donné a moins de 72 caractères si les validations sont activées.
    ([Demande de tirage](https://github.com/rails/rails/pull/15708))

Active Support
--------------

Veuillez vous référer au [journal des modifications][active-support] pour des changements détaillés.

### Suppressions

*   Suppression de `Numeric#ago`, `Numeric#until`, `Numeric#since`, `Numeric#from_now` dépréciés.
    ([Commit](https://github.com/rails/rails/commit/f1eddea1e3f6faf93581c43651348f48b2b7d8bb))

*   Suppression des terminaisons basées sur des chaînes de caractères dépréciées pour `ActiveSupport::Callbacks`.
    ([Demande de tirage](https://github.com/rails/rails/pull/15100))

### Dépréciations

*   Dépréciation de `Kernel#silence_stderr`, `Kernel#capture` et `Kernel#quietly` sans remplacement.
    ([Demande de tirage](https://github.com/rails/rails/pull/13392))

*   Dépréciation de `Class#superclass_delegating_accessor`, utilisez `Class#class_attribute` à la place.
    ([Demande de tirage](https://github.com/rails/rails/pull/14271))

*   Dépréciation de `ActiveSupport::SafeBuffer#prepend!` car `ActiveSupport::SafeBuffer#prepend` effectue maintenant la même fonction.
    ([Demande de tirage](https://github.com/rails/rails/pull/14529))

### Changements notables

*  
[active-support]: https://github.com/rails/rails/blob/4-2-stable/activesupport/CHANGELOG.md
