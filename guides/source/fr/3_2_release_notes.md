**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 30550ed8fa3c0983f3d99a0e91571a98
Notes de version de Ruby on Rails 3.2
=======================================

Points forts de Rails 3.2 :

* Mode de développement plus rapide
* Nouveau moteur de routage
* Explications automatiques des requêtes
* Journalisation étiquetée

Ces notes de version ne couvrent que les changements majeurs. Pour en savoir plus sur les corrections de bugs et les changements divers, veuillez consulter les journaux des modifications ou consulter la [liste des engagements](https://github.com/rails/rails/commits/3-2-stable) dans le référentiel principal de Rails sur GitHub.

--------------------------------------------------------------------------------

Mise à niveau vers Rails 3.2
---------------------------

Si vous mettez à niveau une application existante, il est conseillé d'avoir une bonne couverture de tests avant de commencer. Vous devriez également d'abord passer à Rails 3.1 au cas où vous ne l'auriez pas déjà fait et vous assurer que votre application fonctionne toujours comme prévu avant de tenter une mise à jour vers Rails 3.2. Ensuite, tenez compte des changements suivants :

### Rails 3.2 nécessite au moins Ruby 1.8.7

Rails 3.2 nécessite Ruby 1.8.7 ou une version supérieure. Le support de toutes les versions précédentes de Ruby a été officiellement abandonné et vous devriez effectuer la mise à niveau dès que possible. Rails 3.2 est également compatible avec Ruby 1.9.2.

CONSEIL : Notez que les versions p248 et p249 de Ruby 1.8.7 ont des bugs de sérialisation qui font planter Rails. Ruby Enterprise Edition les a corrigés depuis la version 1.8.7-2010.02. Du côté de Ruby 1.9, la version 1.9.1 n'est pas utilisable car elle plante carrément, donc si vous voulez utiliser 1.9.x, passez directement à 1.9.2 ou 1.9.3 pour une utilisation sans problème.

### Ce qu'il faut mettre à jour dans vos applications

* Mettez à jour votre `Gemfile` pour dépendre de
    * `rails = 3.2.0`
    * `sass-rails ~> 3.2.3`
    * `coffee-rails ~> 3.2.1`
    * `uglifier >= 1.0.3`

* Rails 3.2 déprécie `vendor/plugins` et Rails 4.0 les supprimera complètement. Vous pouvez commencer à remplacer ces plugins en les extrayant en tant que gems et en les ajoutant à votre `Gemfile`. Si vous choisissez de ne pas les transformer en gems, vous pouvez les déplacer dans, par exemple, `lib/my_plugin/*` et ajouter un initialiseur approprié dans `config/initializers/my_plugin.rb`.

* Il y a quelques nouveaux changements de configuration que vous voudrez ajouter dans `config/environments/development.rb` :

    ```ruby
    # Lever une exception en cas de protection contre les affectations massives pour les modèles Active Record
    config.active_record.mass_assignment_sanitizer = :strict

    # Journaliser le plan de requête pour les requêtes prenant plus de temps que cela (fonctionne
    # avec SQLite, MySQL et PostgreSQL)
    config.active_record.auto_explain_threshold_in_seconds = 0.5
    ```

    La configuration `mass_assignment_sanitizer` doit également être ajoutée dans `config/environments/test.rb` :

    ```ruby
    # Lever une exception en cas de protection contre les affectations massives pour les modèles Active Record
    config.active_record.mass_assignment_sanitizer = :strict
    ```

### Ce qu'il faut mettre à jour dans vos moteurs

Remplacez le code sous le commentaire dans `script/rails` par le contenu suivant :

```ruby
ENGINE_ROOT = File.expand_path('../..', __FILE__)
ENGINE_PATH = File.expand_path('../../lib/your_engine_name/engine', __FILE__)

require "rails/all"
require "rails/engine/commands"
```

Création d'une application Rails 3.2
------------------------------------

```bash
# Vous devez avoir le gem 'rails' installé
$ rails new myapp
$ cd myapp
```

### Vendre des gems

Rails utilise maintenant un `Gemfile` à la racine de l'application pour déterminer les gems dont vous avez besoin pour démarrer votre application. Ce `Gemfile` est traité par le gem [Bundler](https://github.com/carlhuda/bundler), qui installe ensuite toutes vos dépendances. Il peut même installer toutes les dépendances localement à votre application afin qu'elle ne dépende pas des gems système.

Plus d'informations : [Page d'accueil de Bundler](https://bundler.io/)

### Vivre à la pointe

`Bundler` et `Gemfile` facilitent la congélation de votre application Rails avec la nouvelle commande `bundle` dédiée. Si vous souhaitez regrouper directement à partir du référentiel Git, vous pouvez passer le drapeau `--edge` :

```bash
$ rails new myapp --edge
```

Si vous avez une copie locale du référentiel Rails et que vous souhaitez générer une application à partir de celui-ci, vous pouvez passer le drapeau `--dev` :

```bash
$ ruby /chemin/vers/rails/railties/bin/rails new myapp --dev
```

Fonctionnalités majeures
------------------------

### Mode de développement plus rapide et routage

Rails 3.2 est livré avec un mode de développement nettement plus rapide. Inspiré par [Active Reload](https://github.com/paneq/active_reload), Rails recharge les classes uniquement lorsque les fichiers changent réellement. Les gains de performances sont spectaculaires sur une application plus importante. La reconnaissance des routes est également beaucoup plus rapide grâce au nouveau moteur [Journey](https://github.com/rails/journey).

### Explications automatiques des requêtes

Rails 3.2 est livré avec une fonctionnalité intéressante qui explique les requêtes générées par Arel en définissant une méthode `explain` dans `ActiveRecord::Relation`. Par exemple, vous pouvez exécuter quelque chose comme `puts Person.active.limit(5).explain` et la requête produite par Arel est expliquée. Cela permet de vérifier les index appropriés et d'effectuer d'autres optimisations.

Les requêtes qui prennent plus d'une demi-seconde à s'exécuter sont *automatiquement* expliquées en mode développement. Bien sûr, ce seuil peut être modifié.

### Journalisation étiquetée
Lors de l'exécution d'une application multi-utilisateurs et multi-comptes, il est très utile de pouvoir filtrer les journaux en fonction de l'utilisateur. TaggedLogging dans Active Support aide à faire exactement cela en marquant les lignes de journal avec des sous-domaines, des identifiants de requête et tout ce qui peut aider au débogage de telles applications.

Documentation
-------------

À partir de Rails 3.2, les guides Rails sont disponibles pour Kindle et les applications de lecture Kindle gratuites pour iPad, iPhone, Mac, Android, etc.

Railties
--------

* Accélérer le développement en rechargeant uniquement les classes si les fichiers de dépendances ont changé. Cela peut être désactivé en définissant `config.reload_classes_only_on_change` sur false.

* Les nouvelles applications obtiennent un indicateur `config.active_record.auto_explain_threshold_in_seconds` dans les fichiers de configuration des environnements. Avec une valeur de `0.5` dans `development.rb` et commenté dans `production.rb`. Aucune mention dans `test.rb`.

* Ajout de `config.exceptions_app` pour définir l'application d'exceptions invoquée par le middleware `ShowException` lorsqu'une exception se produit. Par défaut, il est défini sur `ActionDispatch::PublicExceptions.new(Rails.public_path)`.

* Ajout d'un middleware `DebugExceptions` qui contient des fonctionnalités extraites du middleware `ShowExceptions`.

* Afficher les routes des moteurs montés dans `rake routes`.

* Permet de modifier l'ordre de chargement des railties avec `config.railties_order` comme suit :

    ```ruby
    config.railties_order = [Blog::Engine, :main_app, :all]
    ```

* Scaffold renvoie 204 No Content pour les requêtes API sans contenu. Cela permet à scaffold de fonctionner avec jQuery dès le départ.

* Mise à jour du middleware `Rails::Rack::Logger` pour appliquer les balises définies dans `config.log_tags` à `ActiveSupport::TaggedLogging`. Cela permet de marquer les lignes de journal avec des informations de débogage telles que le sous-domaine et l'identifiant de requête - toutes deux très utiles pour le débogage des applications de production multi-utilisateurs.

* Les options par défaut de `rails new` peuvent être définies dans `~/.railsrc`. Vous pouvez spécifier des arguments supplémentaires à utiliser à chaque exécution de `rails new` dans le fichier de configuration `.railsrc` de votre répertoire personnel.

* Ajout d'un alias `d` pour `destroy`. Cela fonctionne également pour les moteurs.

* Les attributs des générateurs de scaffold et de modèle sont par défaut de type string. Cela permet de faire ce qui suit : `bin/rails g scaffold Post title body:text author`

* Les générateurs de scaffold/modèle/migration acceptent désormais les modificateurs "index" et "uniq". Par exemple,

    ```bash
    bin/rails g scaffold Post title:string:index author:uniq price:decimal{7,2}
    ```

    créera des index pour `title` et `author`, ce dernier étant un index unique. Certains types tels que decimal acceptent des options personnalisées. Dans l'exemple, `price` sera une colonne décimale avec une précision de 7 et une échelle de 2.

* La gemme Turn a été supprimée du fichier `Gemfile` par défaut.

* Suppression de l'ancien générateur de plugins `rails generate plugin` au profit de la commande `rails plugin new`.

* Suppression de l'ancienne API `config.paths.app.controller` au profit de `config.paths["app/controller"]`.

### Dépréciations

* `Rails::Plugin` est déprécié et sera supprimé dans Rails 4.0. Au lieu d'ajouter des plugins à `vendor/plugins`, utilisez des gemmes ou Bundler avec des dépendances de chemin ou de git.

Action Mailer
-------------

* Mise à jour de la version de `mail` à 2.4.0.

* Suppression de l'ancienne API Action Mailer qui était dépréciée depuis Rails 3.0.

Action Pack
-----------

### Action Controller

* Fait de `ActiveSupport::Benchmarkable` un module par défaut pour `ActionController::Base`, de sorte que la méthode `#benchmark` soit à nouveau disponible dans le contexte du contrôleur comme elle l'était auparavant.

* Ajout de l'option `:gzip` à `caches_page`. L'option par défaut peut être configurée globalement en utilisant `page_cache_compression`.

* Rails utilisera désormais votre mise en page par défaut (comme "layouts/application") lorsque vous spécifiez une mise en page avec les conditions `:only` et `:except`, et que ces conditions échouent.

    ```ruby
    class CarsController
      layout 'single_car', :only => :show
    end
    ```

    Rails utilisera `layouts/single_car` lorsqu'une requête arrive dans l'action `:show`, et utilisera `layouts/application` (ou `layouts/cars`, s'il existe) lorsqu'une requête arrive pour toute autre action.

* `form_for` est modifié pour utiliser `#{action}_#{as}` comme classe CSS et id si l'option `:as` est fournie. Les versions précédentes utilisaient `#{as}_#{action}`.

* `ActionController::ParamsWrapper` sur les modèles Active Record ne wrappe désormais que les attributs `attr_accessible` s'ils sont définis. Sinon, seuls les attributs retournés par la méthode de classe `attribute_names` seront wrappés. Cela corrige le wrapping des attributs imbriqués en les ajoutant à `attr_accessible`.

* Journaliser "Filter chain halted as CALLBACKNAME rendered or redirected" chaque fois qu'un rappel avant arrête le processus.

* Refonte de `ActionDispatch::ShowExceptions`. Le contrôleur est responsable du choix d'afficher les exceptions. Il est possible de remplacer `show_detailed_exceptions?` dans les contrôleurs pour spécifier quelles requêtes doivent fournir des informations de débogage sur les erreurs.

* Les répondeurs renvoient désormais 204 No Content pour les requêtes API sans corps de réponse (comme dans le nouveau scaffold).

* Refonte des cookies de `ActionController::TestCase`. L'attribution des cookies pour les cas de test doit désormais utiliser `cookies[]`.
```ruby
cookies[:email] = 'user@example.com'
get :index
assert_equal 'user@example.com', cookies[:email]
```

Pour effacer les cookies, utilisez `clear`.

```ruby
cookies.clear
get :index
assert_nil cookies[:email]
```

Nous n'écrivons plus HTTP_COOKIE et le cookie jar est persistant entre les requêtes, donc si vous avez besoin de manipuler l'environnement pour votre test, vous devez le faire avant la création du cookie jar.

* `send_file` devine maintenant le type MIME à partir de l'extension du fichier si `:type` n'est pas fourni.

* Des entrées de type MIME pour les formats PDF, ZIP et autres ont été ajoutées.

* Permettre à `fresh_when/stale?` de prendre un enregistrement au lieu d'un hachage d'options.

* Niveau de journalisation de l'avertissement pour le jeton CSRF manquant changé de `:debug` à `:warn`.

* Les ressources doivent utiliser le protocole de la requête par défaut ou être relatives par défaut si aucune requête n'est disponible.

#### Dépréciations

* Recherche de mise en page implicite dépréciée dans les contrôleurs dont le parent avait une mise en page explicite définie :

```ruby
class ApplicationController
  layout "application"
end

class PostsController < ApplicationController
end
```

Dans l'exemple ci-dessus, `PostsController` ne recherchera plus automatiquement une mise en page pour les posts. Si vous avez besoin de cette fonctionnalité, vous pouvez soit supprimer `layout "application"` de `ApplicationController`, soit le définir explicitement sur `nil` dans `PostsController`.

* `ActionController::UnknownAction` déprécié au profit de `AbstractController::ActionNotFound`.

* `ActionController::DoubleRenderError` déprécié au profit de `AbstractController::DoubleRenderError`.

* `method_missing` déprécié au profit de `action_missing` pour les actions manquantes.

* `ActionController#rescue_action`, `ActionController#initialize_template_class` et `ActionController#assign_shortcuts` dépréciés.

### Action Dispatch

* Ajout de `config.action_dispatch.default_charset` pour configurer le jeu de caractères par défaut pour `ActionDispatch::Response`.

* Ajout du middleware `ActionDispatch::RequestId` qui rend un en-tête X-Request-Id unique disponible pour la réponse et active la méthode `ActionDispatch::Request#uuid`. Cela facilite le suivi des requêtes de bout en bout dans la pile et l'identification des requêtes individuelles dans des journaux mixtes tels que Syslog.

* Le middleware `ShowExceptions` accepte maintenant une application d'exceptions qui est responsable de rendre une exception lorsque l'application échoue. L'application est invoquée avec une copie de l'exception dans `env["action_dispatch.exception"]` et avec `PATH_INFO` réécrit en code d'état.

* Permet de configurer les réponses de secours via un railtie comme dans `config.action_dispatch.rescue_responses`.

#### Dépréciations

* Dépréciée la possibilité de définir un jeu de caractères par défaut au niveau du contrôleur, utilisez plutôt le nouveau `config.action_dispatch.default_charset`.

### Action View

* Ajout du support `button_tag` à `ActionView::Helpers::FormBuilder`. Ce support imite le comportement par défaut de `submit_tag`.

```erb
<%= form_for @post do |f| %>
  <%= f.button %>
<% end %>
```

* Les helpers de date acceptent une nouvelle option `:use_two_digit_numbers => true`, qui rend les boîtes de sélection pour les mois et les jours avec un zéro initial sans changer les valeurs respectives. Par exemple, cela est utile pour afficher des dates au format ISO 8601 telles que '2011-08-01'.

* Vous pouvez fournir un espace de noms pour votre formulaire afin de garantir l'unicité des attributs id sur les éléments du formulaire. L'attribut namespace sera préfixé par un trait de soulignement dans l'id HTML généré.

```erb
<%= form_for(@offer, :namespace => 'namespace') do |f| %>
  <%= f.label :version, 'Version' %>:
  <%= f.text_field :version %>
<% end %>
```

* Limite le nombre d'options pour `select_year` à 1000. Passez l'option `:max_years_allowed` pour définir votre propre limite.

* `content_tag_for` et `div_for` peuvent maintenant prendre une collection d'enregistrements. Il transmettra également l'enregistrement en tant que premier argument si vous définissez un argument de réception dans votre bloc. Ainsi, au lieu de faire ceci :

```ruby
@items.each do |item|
  content_tag_for(:li, item) do
    Title: <%= item.title %>
  end
end
```

Vous pouvez faire ceci :

```ruby
content_tag_for(:li, @items) do |item|
  Title: <%= item.title %>
end
```

* Ajout de la méthode d'aide `font_path` qui calcule le chemin d'un fichier de police dans `public/fonts`.

#### Dépréciations

* Le passage de formats ou de gestionnaires à `render :template` et aux autres comme `render :template => "foo.html.erb"` est déprécié. Au lieu de cela, vous pouvez fournir directement les options `:handlers` et `:formats` : `render :template => "foo", :formats => [:html, :js], :handlers => :erb`.

### Sprockets

* Ajoute une option de configuration `config.assets.logger` pour contrôler la journalisation de Sprockets. Définissez-la sur `false` pour désactiver la journalisation et sur `nil` pour utiliser `Rails.logger` par défaut. 

Active Record
-------------

* Les colonnes booléennes avec les valeurs 'on' et 'ON' sont converties en true.

* Lorsque la méthode `timestamps` crée les colonnes `created_at` et `updated_at`, elles sont par défaut non nulles.

* Implémentation de `ActiveRecord::Relation#explain`.

* Implémentation de `ActiveRecord::Base.silence_auto_explain` qui permet à l'utilisateur de désactiver sélectivement les EXPLAIN automatiques dans un bloc.

* Implémentation de la journalisation automatique des EXPLAIN pour les requêtes lentes. Un nouveau paramètre de configuration `config.active_record.auto_explain_threshold_in_seconds` détermine ce qui est considéré comme une requête lente. La valeur `nil` désactive cette fonctionnalité. Les valeurs par défaut sont de 0,5 en mode développement et `nil` en modes test et production. Rails 3.2 prend en charge cette fonctionnalité dans SQLite, MySQL (adaptateur mysql2) et PostgreSQL.
* Ajout de `ActiveRecord::Base.store` pour déclarer des magasins clé/valeur simples à une seule colonne.

    ```ruby
    class User < ActiveRecord::Base
      store :settings, accessors: [ :color, :homepage ]
    end

    u = User.new(color: 'black', homepage: '37signals.com')
    u.color                          # Attribut stocké accessible
    u.settings[:country] = 'Denmark' # Tout attribut, même s'il n'est pas spécifié avec un accesseur
    ```

* Ajout de la possibilité d'exécuter des migrations uniquement pour une portée donnée, ce qui permet d'exécuter des migrations uniquement à partir d'un moteur (par exemple pour annuler les modifications d'un moteur qui doivent être supprimées).

    ```
    rake db:migrate SCOPE=blog
    ```

* Les migrations copiées à partir des moteurs sont maintenant regroupées avec le nom du moteur, par exemple `01_create_posts.blog.rb`.

* Implémentation de la méthode `ActiveRecord::Relation#pluck` qui renvoie un tableau de valeurs de colonnes directement à partir de la table sous-jacente. Cela fonctionne également avec les attributs sérialisés.

    ```ruby
    Client.where(:active => true).pluck(:id)
    # SELECT id from clients where active = 1
    ```

* Les méthodes d'association générées sont créées dans un module séparé pour permettre la substitution et la composition. Pour une classe nommée MyModel, le module est nommé `MyModel::GeneratedFeatureMethods`. Il est inclus dans la classe modèle immédiatement après le module `generated_attributes_methods` défini dans Active Model, de sorte que les méthodes d'association remplacent les méthodes d'attribut du même nom.

* Ajout de `ActiveRecord::Relation#uniq` pour générer des requêtes uniques.

    ```ruby
    Client.select('DISTINCT name')
    ```

    ..peut être écrit comme suit :

    ```ruby
    Client.select(:name).uniq
    ```

    Cela vous permet également de revenir à la non-uniformité dans une relation :

    ```ruby
    Client.select(:name).uniq.uniq(false)
    ```

* Prise en charge de l'ordre de tri des index dans les adaptateurs SQLite, MySQL et PostgreSQL.

* Autoriser l'option `:class_name` pour les associations à prendre un symbole en plus d'une chaîne de caractères. Cela évite de confondre les débutants et est cohérent avec le fait que d'autres options comme `:foreign_key` permettent déjà un symbole ou une chaîne de caractères.

    ```ruby
    has_many :clients, :class_name => :Client # Notez que le symbole doit être en majuscule
    ```

* En mode développement, `db:drop` supprime également la base de données de test afin d'être symétrique avec `db:create`.

* La validation d'unicité insensible à la casse évite d'appeler LOWER dans MySQL lorsque la colonne utilise déjà une collation insensible à la casse.

* Les fixtures transactionnelles répertorient toutes les connexions de base de données actives. Vous pouvez tester des modèles sur différentes connexions sans désactiver les fixtures transactionnelles.

* Ajout des méthodes `first_or_create`, `first_or_create!`, `first_or_initialize` à Active Record. C'est une meilleure approche que les anciennes méthodes dynamiques `find_or_create_by` car il est plus clair quels arguments sont utilisés pour trouver l'enregistrement et lesquels sont utilisés pour le créer.

    ```ruby
    User.where(:first_name => "Scarlett").first_or_create!(:last_name => "Johansson")
    ```

* Ajout d'une méthode `with_lock` aux objets Active Record, qui démarre une transaction, verrouille l'objet (de manière pessimiste) et exécute le bloc. La méthode prend un (facultatif) paramètre et le transmet à `lock!`.

    Cela permet d'écrire ce qui suit :

    ```ruby
    class Order < ActiveRecord::Base
      def cancel!
        transaction do
          lock!
          # ... logique d'annulation
        end
      end
    end
    ```

    comme :

    ```ruby
    class Order < ActiveRecord::Base
      def cancel!
        with_lock do
          # ... logique d'annulation
        end
      end
    end
    ```

### Dépréciations

* La fermeture automatique des connexions dans les threads est dépréciée. Par exemple, le code suivant est déprécié :

    ```ruby
    Thread.new { Post.find(1) }.join
    ```

    Il doit être modifié pour fermer la connexion à la base de données à la fin du thread :

    ```ruby
    Thread.new {
      Post.find(1)
      Post.connection.close
    }.join
    ```

    Seules les personnes qui créent des threads dans leur code d'application doivent se soucier de ce changement.

* Les méthodes `set_table_name`, `set_inheritance_column`, `set_sequence_name`, `set_primary_key`, `set_locking_column` sont dépréciées. Utilisez plutôt une méthode d'assignation. Par exemple, au lieu de `set_table_name`, utilisez `self.table_name=`.

    ```ruby
    class Project < ActiveRecord::Base
      self.table_name = "project"
    end
    ```

    Ou définissez votre propre méthode `self.table_name` :

    ```ruby
    class Post < ActiveRecord::Base
      def self.table_name
        "special_" + super
      end
    end

    Post.table_name # => "special_posts"
    ```

Active Model
------------

* Ajout de `ActiveModel::Errors#added?` pour vérifier si une erreur spécifique a été ajoutée.

* Ajout de la possibilité de définir des validations strictes avec `strict => true` qui lève toujours une exception en cas d'échec.

* Fournir `mass_assignment_sanitizer` en tant qu'API facile pour remplacer le comportement du sanitizer. Prend également en charge les comportements de sanitizer `:logger` (par défaut) et `:strict`.

### Dépréciations

* Dépréciation de `define_attr_method` dans `ActiveModel::AttributeMethods` car cela n'existait que pour prendre en charge des méthodes comme `set_table_name` dans Active Record, qui sont elles-mêmes dépréciées.

* Dépréciation de `Model.model_name.partial_path` au profit de `model.to_partial_path`.

Active Resource
---------------

* Réponses de redirection : les réponses 303 See Other et 307 Temporary Redirect se comportent maintenant comme 301 Moved Permanently et 302 Found.

Active Support
--------------

* Ajout de `ActiveSupport:TaggedLogging` qui peut envelopper n'importe quelle classe `Logger` standard pour fournir des capacités de balisage.

    ```ruby
    Logger = ActiveSupport::TaggedLogging.new(Logger.new(STDOUT))

    Logger.tagged("BCX") { Logger.info "Stuff" }
    # Enregistre "[BCX] Stuff"

    Logger.tagged("BCX", "Jason") { Logger.info "Stuff" }
    # Enregistre "[BCX] [Jason] Stuff"

    Logger.tagged("BCX") { Logger.tagged("Jason") { Logger.info "Stuff" } }
    # Enregistre "[BCX] [Jason] Stuff"
    ```
* La méthode `beginning_of_week` dans `Date`, `Time` et `DateTime` accepte un argument facultatif représentant le jour à partir duquel la semaine est supposée commencer.

* `ActiveSupport::Notifications.subscribed` permet de s'abonner à des événements pendant l'exécution d'un bloc.

* Définition des nouvelles méthodes `Module#qualified_const_defined?`, `Module#qualified_const_get` et `Module#qualified_const_set` qui sont analogues aux méthodes correspondantes de l'API standard, mais acceptent des noms de constantes qualifiées.

* Ajout de `#deconstantize` qui complète `#demodulize` dans les inflections. Cela supprime le segment le plus à droite dans un nom de constante qualifiée.

* Ajout de `safe_constantize` qui transforme une chaîne en constante mais renvoie `nil` au lieu de lever une exception si la constante (ou une partie de celle-ci) n'existe pas.

* `ActiveSupport::OrderedHash` est maintenant marqué comme extractable lors de l'utilisation de `Array#extract_options!`.

* Ajout de `Array#prepend` comme alias de `Array#unshift` et `Array#append` comme alias de `Array#<<`.

* La définition d'une chaîne vide pour Ruby 1.9 a été étendue aux espaces blancs Unicode. De plus, en Ruby 1.8, l'espace idéographique U`3000 est considéré comme un espace blanc.

* L'inflecteur comprend les acronymes.

* Ajout de `Time#all_day`, `Time#all_week`, `Time#all_quarter` et `Time#all_year` comme moyen de générer des plages.

    ```ruby
    Event.where(:created_at => Time.now.all_week)
    Event.where(:created_at => Time.now.all_day)
    ```

* Ajout de `instance_accessor: false` comme option pour `Class#cattr_accessor` et ses équivalents.

* `ActiveSupport::OrderedHash` a maintenant un comportement différent pour `#each` et `#each_pair` lorsqu'un bloc acceptant ses paramètres avec un splat est donné.

* Ajout de `ActiveSupport::Cache::NullStore` pour une utilisation en développement et en test.

* Suppression de `ActiveSupport::SecureRandom` au profit de `SecureRandom` de la bibliothèque standard.

### Dépréciations

* `ActiveSupport::Base64` est déprécié au profit de `::Base64`.

* `ActiveSupport::Memoizable` est déprécié au profit du modèle de mémoization Ruby.

* `Module#synchronize` est déprécié sans remplacement. Veuillez utiliser le moniteur de la bibliothèque standard de Ruby.

* `ActiveSupport::MessageEncryptor#encrypt` et `ActiveSupport::MessageEncryptor#decrypt` sont dépréciés.

* `ActiveSupport::BufferedLogger#silence` est déprécié. Si vous souhaitez supprimer les journaux pour un certain bloc, modifiez le niveau de journalisation pour ce bloc.

* `ActiveSupport::BufferedLogger#open_log` est déprécié. Cette méthode ne devrait pas être publique en premier lieu.

* Le comportement de `ActiveSupport::BufferedLogger` qui crée automatiquement le répertoire pour votre fichier journal est déprécié. Assurez-vous de créer le répertoire pour votre fichier journal avant de l'instancier.

* `ActiveSupport::BufferedLogger#auto_flushing` est déprécié. Définissez le niveau de synchronisation sur la poignée de fichier sous-jacente comme ceci. Ou ajustez votre système de fichiers. Le cache FS contrôle maintenant la vidange.

    ```ruby
    f = File.open('foo.log', 'w')
    f.sync = true
    ActiveSupport::BufferedLogger.new f
    ```

* `ActiveSupport::BufferedLogger#flush` est déprécié. Définissez la synchronisation sur votre poignée de fichier ou ajustez votre système de fichiers.

Crédits
-------

Consultez la [liste complète des contributeurs à Rails](http://contributors.rubyonrails.org/) pour les nombreuses personnes qui ont passé de nombreuses heures à faire de Rails, le framework stable et robuste qu'il est. Félicitations à tous.

Les notes de version de Rails 3.2 ont été compilées par [Vijay Dev](https://github.com/vijaydev).
