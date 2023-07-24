**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: da25f37b5b3eddff86c5b5b2cd24007f
Ruby on Rails 3.1 Notes de version
===================================

Points forts de Rails 3.1 :

* Streaming
* Migrations réversibles
* Pipeline d'assets
* jQuery comme bibliothèque JavaScript par défaut

Ces notes de version ne couvrent que les changements majeurs. Pour en savoir plus sur les corrections de bugs et les changements, veuillez consulter les journaux des modifications ou consulter la [liste des validations](https://github.com/rails/rails/commits/3-1-stable) dans le référentiel principal de Rails sur GitHub.

--------------------------------------------------------------------------------

Mise à niveau vers Rails 3.1
---------------------------

Si vous mettez à niveau une application existante, il est conseillé d'avoir une bonne couverture de tests avant de commencer. Vous devriez également d'abord passer à Rails 3 au cas où vous ne l'auriez pas fait et vous assurer que votre application fonctionne toujours comme prévu avant de tenter de passer à Rails 3.1. Ensuite, tenez compte des changements suivants :

### Rails 3.1 nécessite au moins Ruby 1.8.7

Rails 3.1 nécessite Ruby 1.8.7 ou une version supérieure. Le support de toutes les versions précédentes de Ruby a été abandonné officiellement et vous devriez effectuer la mise à niveau dès que possible. Rails 3.1 est également compatible avec Ruby 1.9.2.

CONSEIL : Notez que les versions p248 et p249 de Ruby 1.8.7 ont des bugs de sérialisation qui font planter Rails. Ruby Enterprise Edition les a corrigés depuis la version 1.8.7-2010.02. En ce qui concerne la version 1.9, Ruby 1.9.1 n'est pas utilisable car il plante carrément, donc si vous voulez utiliser la version 1.9.x, passez directement à la version 1.9.2 pour une utilisation sans problème.

### Ce qu'il faut mettre à jour dans vos applications

Les changements suivants sont destinés à la mise à niveau de votre application vers Rails 3.1.3, la dernière version 3.1.x de Rails.

#### Gemfile

Effectuez les changements suivants dans votre `Gemfile`.

```ruby
gem 'rails', '= 3.1.3'
gem 'mysql2'

# Nécessaire pour le nouveau pipeline d'assets
group :assets do
  gem 'sass-rails',   "~> 3.1.5"
  gem 'coffee-rails', "~> 3.1.1"
  gem 'uglifier',     ">= 1.0.3"
end

# jQuery est la bibliothèque JavaScript par défaut dans Rails 3.1
gem 'jquery-rails'
```

#### config/application.rb

* Le pipeline d'assets nécessite les ajouts suivants :

    ```ruby
    config.assets.enabled = true
    config.assets.version = '1.0'
    ```

* Si votre application utilise la route "/assets" pour une ressource, vous voudrez peut-être changer le préfixe utilisé pour les assets afin d'éviter les conflits :

    ```ruby
    # Par défaut : '/assets'
    config.assets.prefix = '/asset-files'
    ```

#### config/environments/development.rb

* Supprimez le paramètre RJS `config.action_view.debug_rjs = true`.

* Ajoutez ce qui suit, si vous activez le pipeline d'assets.

    ```ruby
    # Ne pas compresser les assets
    config.assets.compress = false

    # Développe les lignes qui chargent les assets
    config.assets.debug = true
    ```

#### config/environments/production.rb

* Encore une fois, la plupart des changements ci-dessous concernent le pipeline d'assets. Vous pouvez en savoir plus à ce sujet dans le guide [Pipeline d'assets](asset_pipeline.html).

    ```ruby
    # Compresser les JavaScripts et CSS
    config.assets.compress = true

    # Ne pas revenir au pipeline d'assets si un asset précompilé est manquant
    config.assets.compile = false

    # Générer des empreintes pour les URLs des assets
    config.assets.digest = true

    # Par défaut : Rails.root.join("public/assets")
    # config.assets.manifest = YOUR_PATH

    # Précompiler des assets supplémentaires (application.js, application.css, et tous les fichiers non JS/CSS sont déjà ajoutés)
    # config.assets.precompile `= %w( admin.js admin.css )


    # Forcer l'accès à l'application via SSL, utiliser Strict-Transport-Security et des cookies sécurisés.
    # config.force_ssl = true
    ```

#### config/environments/test.rb

```ruby
# Configurer le serveur d'assets statiques pour les tests avec Cache-Control pour les performances
config.serve_static_assets = true
config.static_cache_control = "public, max-age=3600"
```

#### config/initializers/wrap_parameters.rb

* Ajoutez ce fichier avec le contenu suivant, si vous souhaitez envelopper les paramètres dans un hash imbriqué. C'est activé par défaut dans les nouvelles applications.

    ```ruby
    # Assurez-vous de redémarrer votre serveur lorsque vous modifiez ce fichier.
    # Ce fichier contient les paramètres pour ActionController::ParamsWrapper qui
    # est activé par défaut.

    # Activer l'enveloppement des paramètres pour JSON. Vous pouvez désactiver cela en définissant :format sur un tableau vide.
    ActiveSupport.on_load(:action_controller) do
      wrap_parameters :format => [:json]
    end

    # Désactiver l'élément racine dans JSON par défaut.
    ActiveSupport.on_load(:active_record) do
      self.include_root_in_json = false
    end
    ```

#### Supprimez les options :cache et :concat dans les références aux helpers d'assets dans les vues

* Avec le pipeline d'assets, les options :cache et :concat ne sont plus utilisées, supprimez ces options de vos vues.

Création d'une application Rails 3.1
------------------------------------

```bash
# Vous devez avoir le RubyGem 'rails' installé
$ rails new myapp
$ cd myapp
```

### Vendoring Gems

Rails utilise maintenant un `Gemfile` à la racine de l'application pour déterminer les gems dont vous avez besoin pour démarrer votre application. Ce `Gemfile` est traité par le gem [Bundler](https://github.com/carlhuda/bundler), qui installe ensuite toutes vos dépendances. Il peut même installer toutes les dépendances localement à votre application afin qu'elle ne dépende pas des gems système.
Plus d'informations: - [page d'accueil de Bundler](https://bundler.io/)

### Vivre à la pointe

`Bundler` et `Gemfile` rendent le gel de votre application Rails aussi facile que de manger une tarte avec la nouvelle commande `bundle` dédiée. Si vous voulez regrouper directement à partir du référentiel Git, vous pouvez passer le drapeau `--edge` :

```bash
$ rails new myapp --edge
```

Si vous avez une copie locale du référentiel Rails et que vous voulez générer une application à partir de celui-ci, vous pouvez passer le drapeau `--dev` :

```bash
$ ruby /path/to/rails/railties/bin/rails new myapp --dev
```

Changements architecturaux de Rails
----------------------------------

### Pipeline des ressources

Le changement majeur dans Rails 3.1 est le pipeline des ressources. Il rend les feuilles de style CSS et les fichiers JavaScript des citoyens de première classe et permet une organisation appropriée, y compris leur utilisation dans les plugins et les moteurs.

Le pipeline des ressources est alimenté par [Sprockets](https://github.com/rails/sprockets) et est couvert dans le guide [Pipeline des ressources](asset_pipeline.html).

### Streaming HTTP

Le streaming HTTP est un autre changement introduit dans Rails 3.1. Cela permet au navigateur de télécharger vos feuilles de style et fichiers JavaScript pendant que le serveur génère toujours la réponse. Cela nécessite Ruby 1.9.2, est facultatif et nécessite également le support du serveur web, mais la combinaison populaire de NGINX et Unicorn est prête à en profiter.

### La bibliothèque JS par défaut est maintenant jQuery

jQuery est la bibliothèque JavaScript par défaut fournie avec Rails 3.1. Mais si vous utilisez Prototype, il est simple de passer à celui-ci.

```bash
$ rails new myapp -j prototype
```

### Identity Map

Active Record dispose d'une Identity Map dans Rails 3.1. Une Identity Map conserve les enregistrements précédemment instanciés et renvoie l'objet associé à l'enregistrement s'il est à nouveau accédé. L'Identity Map est créée pour chaque requête et est vidée à la fin de la requête.

Rails 3.1 est livré avec l'Identity Map désactivée par défaut.

Railties
--------

* jQuery est la nouvelle bibliothèque JavaScript par défaut.

* jQuery et Prototype ne sont plus vendus et sont désormais fournis par les gemmes `jquery-rails` et `prototype-rails`.

* Le générateur d'applications accepte une option `-j` qui peut être une chaîne arbitraire. Si "foo" est passé, la gemme "foo-rails" est ajoutée au `Gemfile`, et le manifeste JavaScript de l'application nécessite "foo" et "foo_ujs". Actuellement, seules "prototype-rails" et "jquery-rails" existent et fournissent ces fichiers via le pipeline des ressources.

* La génération d'une application ou d'un plugin exécute `bundle install` à moins que `--skip-gemfile` ou `--skip-bundle` ne soit spécifié.

* Les générateurs de contrôleurs et de ressources génèrent désormais automatiquement des ébauches d'assets (cela peut être désactivé avec `--skip-assets`). Ces ébauches utiliseront CoffeeScript et Sass, si ces bibliothèques sont disponibles.

* Les générateurs de scaffold et d'application utilisent le style de hachage de Ruby 1.9 lorsqu'ils s'exécutent sur Ruby 1.9. Pour générer un hachage au style ancien, `--old-style-hash` peut être passé.

* Le générateur de contrôleurs de scaffold crée un bloc de format pour JSON au lieu de XML.

* Les journaux d'Active Record sont dirigés vers STDOUT et affichés en ligne dans la console.

* Ajout de la configuration `config.force_ssl` qui charge le middleware `Rack::SSL` et force toutes les requêtes à être sous le protocole HTTPS.

* Ajout de la commande `rails plugin new` qui génère un plugin Rails avec un gemspec, des tests et une application fictive pour les tests.

* Ajout de `Rack::Etag` et `Rack::ConditionalGet` à la pile de middleware par défaut.

* Ajout de `Rack::Cache` à la pile de middleware par défaut.

* Les moteurs ont reçu une mise à jour majeure - Vous pouvez les monter à n'importe quel chemin, activer les assets, exécuter des générateurs, etc.

Action Pack
-----------

### Action Controller

* Un avertissement est affiché si l'authenticité du jeton CSRF ne peut pas être vérifiée.

* Spécifiez `force_ssl` dans un contrôleur pour forcer le navigateur à transférer les données via le protocole HTTPS sur ce contrôleur particulier. Pour limiter aux actions spécifiques, `:only` ou `:except` peuvent être utilisés.

* Les paramètres de chaîne de requête sensibles spécifiés dans `config.filter_parameters` seront désormais filtrés des chemins de requête dans le journal.

* Les paramètres d'URL qui renvoient `nil` pour `to_param` sont maintenant supprimés de la chaîne de requête.

* Ajout de `ActionController::ParamsWrapper` pour envelopper les paramètres dans un hachage imbriqué, et il sera activé par défaut pour les requêtes JSON dans les nouvelles applications. Cela peut être personnalisé dans `config/initializers/wrap_parameters.rb`.

* Ajout de `config.action_controller.include_all_helpers`. Par défaut, `helper :all` est effectué dans `ActionController::Base`, ce qui inclut tous les helpers par défaut. En définissant `include_all_helpers` sur `false`, seuls `application_helper` et l'helper correspondant au contrôleur (comme `foo_helper` pour `foo_controller`) seront inclus.

* `url_for` et les helpers d'URL nommés acceptent maintenant `:subdomain` et `:domain` comme options.
* Ajout de `Base.http_basic_authenticate_with` pour effectuer une authentification de base HTTP avec un seul appel de méthode de classe.

    ```ruby
    class PostsController < ApplicationController
      USER_NAME, PASSWORD = "dhh", "secret"

      before_filter :authenticate, :except => [ :index ]

      def index
        render :text => "Tout le monde peut me voir!"
      end

      def edit
        render :text => "Je suis accessible uniquement si vous connaissez le mot de passe"
      end

      private
        def authenticate
          authenticate_or_request_with_http_basic do |user_name, password|
            user_name == USER_NAME && password == PASSWORD
          end
        end
    end
    ```

    ..peut maintenant être écrit comme suit

    ```ruby
    class PostsController < ApplicationController
      http_basic_authenticate_with :name => "dhh", :password => "secret", :except => :index

      def index
        render :text => "Tout le monde peut me voir!"
      end

      def edit
        render :text => "Je suis accessible uniquement si vous connaissez le mot de passe"
      end
    end
    ```

* Ajout de la prise en charge du streaming, vous pouvez l'activer avec:

    ```ruby
    class PostsController < ActionController::Base
      stream
    end
    ```

    Vous pouvez le restreindre à certaines actions en utilisant `:only` ou `:except`. Veuillez lire la documentation sur [`ActionController::Streaming`](https://api.rubyonrails.org/v3.1.0/classes/ActionController/Streaming.html) pour plus d'informations.

* La méthode de routage de redirection accepte maintenant également un hachage d'options qui ne modifiera que les parties de l'URL en question, ou un objet qui répond à l'appel, permettant la réutilisation des redirections.

### Action Dispatch

* `config.action_dispatch.x_sendfile_header` a maintenant la valeur par défaut `nil` et `config/environments/production.rb` ne définit aucune valeur particulière pour celle-ci. Cela permet aux serveurs de la définir via `X-Sendfile-Type`.

* `ActionDispatch::MiddlewareStack` utilise maintenant la composition plutôt que l'héritage et n'est plus un tableau.

* Ajout de `ActionDispatch::Request.ignore_accept_header` pour ignorer les en-têtes accept.

* Ajout de `Rack::Cache` à la pile par défaut.

* Déplacement de la responsabilité de l'etag de `ActionDispatch::Response` vers la pile de middleware.

* S'appuie sur l'API des magasins `Rack::Session` pour une plus grande compatibilité dans le monde Ruby. Cela est rétro-incompatible car `Rack::Session` s'attend à ce que `#get_session` accepte quatre arguments et nécessite `#destroy_session` au lieu de simplement `#destroy`.

* La recherche de modèle recherche maintenant plus haut dans la chaîne d'héritage.

### Action View

* Ajout de l'option `:authenticity_token` à `form_tag` pour une manipulation personnalisée ou pour omettre le jeton en passant `:authenticity_token => false`.

* Création de `ActionView::Renderer` et spécification d'une API pour `ActionView::Context`.

* La mutation en place de `SafeBuffer` est interdite dans Rails 3.1.

* Ajout de l'aide `button_tag` HTML5.

* `file_field` ajoute automatiquement `:multipart => true` au formulaire englobant.

* Ajout d'une idiome pratique pour générer des attributs HTML5 data-* dans les aides de balises à partir d'un hachage `:data` d'options:

    ```ruby
    tag("div", :data => {:name => 'Stephen', :city_state => %w(Chicago IL)})
    # => <div data-name="Stephen" data-city-state="[&quot;Chicago&quot;,&quot;IL&quot;]" />
    ```

Les clés sont transformées en tirets. Les valeurs sont encodées en JSON, sauf pour les chaînes de caractères et les symboles.

* `csrf_meta_tag` est renommé en `csrf_meta_tags` et alias `csrf_meta_tag` pour assurer la compatibilité ascendante.

* L'ancienne API du gestionnaire de modèles est obsolète et la nouvelle API nécessite simplement que le gestionnaire de modèles réponde à l'appel.

* rhtml et rxml sont enfin supprimés en tant que gestionnaires de modèles.

* `config.action_view.cache_template_loading` est réintroduit, ce qui permet de décider si les modèles doivent être mis en cache ou non.

* L'aide `submit` du formulaire ne génère plus un identifiant "object_name_id".

* Permet à `FormHelper#form_for` de spécifier la `:method` comme une option directe au lieu de passer par le hachage `:html`. `form_for(@post, remote: true, method: :delete)` au lieu de `form_for(@post, remote: true, html: { method: :delete })`.

* Fournit `JavaScriptHelper#j()` en tant qu'alias de `JavaScriptHelper#escape_javascript()`. Cela remplace la méthode `Object#j()` que la gem JSON ajoute dans les modèles en utilisant JavaScriptHelper.

* Permet le format AM/PM dans les sélecteurs de date et d'heure.

* `auto_link` a été supprimé de Rails et extrait dans la [gem rails_autolink](https://github.com/tenderlove/rails_autolink)

Active Record
-------------

* Ajout d'une méthode de classe `pluralize_table_names` pour singulariser/pluraliser les noms de table des modèles individuels. Auparavant, cela ne pouvait être défini globalement pour tous les modèles via `ActiveRecord::Base.pluralize_table_names`.

    ```ruby
    class User < ActiveRecord::Base
      self.pluralize_table_names = false
    end
    ```

* Ajout du réglage des attributs des associations singulières par bloc. Le bloc sera appelé après l'initialisation de l'instance.

    ```ruby
    class User < ActiveRecord::Base
      has_one :account
    end

    user.build_account{ |a| a.credit_limit = 100.0 }
    ```

* Ajout de `ActiveRecord::Base.attribute_names` pour renvoyer une liste de noms d'attributs. Cela renverra un tableau vide si le modèle est abstrait ou si la table n'existe pas.

* Les fixtures CSV sont obsolètes et leur prise en charge sera supprimée dans Rails 3.2.0.

* `ActiveRecord#new`, `ActiveRecord#create` et `ActiveRecord#update_attributes` acceptent tous un second hachage en option qui vous permet de spécifier quel rôle considérer lors de l'attribution des attributs. Cela est basé sur les nouvelles capacités d'assignation de masse d'Active Model.
```ruby
class Post < ActiveRecord::Base
  attr_accessible :title
  attr_accessible :title, :published_at, :as => :admin
end

Post.new(params[:post], :as => :admin)
```

* `default_scope` peut maintenant prendre un bloc, une lambda ou tout autre objet qui répond à l'appel pour une évaluation paresseuse.

* Les scopes par défaut sont maintenant évalués au moment le plus tardif possible, pour éviter les problèmes où des scopes seraient créés qui contiendraient implicitement le scope par défaut, ce qui serait alors impossible à supprimer via Model.unscoped.

* L'adaptateur PostgreSQL ne prend en charge que la version 8.2 et supérieure de PostgreSQL.

* Le middleware `ConnectionManagement` est modifié pour nettoyer le pool de connexions après que le corps de la rack a été vidé.

* Ajout d'une méthode `update_column` sur Active Record. Cette nouvelle méthode met à jour un attribut donné sur un objet, en sautant les validations et les callbacks. Il est recommandé d'utiliser `update_attributes` ou `update_attribute` sauf si vous êtes sûr de ne pas vouloir exécuter de callback, y compris la modification de la colonne `updated_at`. Elle ne doit pas être appelée sur de nouveaux enregistrements.

* Les associations avec une option `:through` peuvent maintenant utiliser n'importe quelle association en tant qu'association through ou source, y compris d'autres associations qui ont une option `:through` et des associations `has_and_belongs_to_many`.

* La configuration de la connexion à la base de données actuelle est maintenant accessible via `ActiveRecord::Base.connection_config`.

* Les limites et les offsets sont supprimés des requêtes COUNT sauf si les deux sont fournis.

```ruby
People.limit(1).count           # => 'SELECT COUNT(*) FROM people'
People.offset(1).count          # => 'SELECT COUNT(*) FROM people'
People.limit(1).offset(1).count # => 'SELECT COUNT(*) FROM people LIMIT 1 OFFSET 1'
```

* `ActiveRecord::Associations::AssociationProxy` a été divisé. Il existe maintenant une classe `Association` (et des sous-classes) qui est responsable de l'opération sur les associations, puis un wrapper séparé et mince appelé `CollectionProxy`, qui fait office de proxy pour les associations de collection. Cela évite la pollution de l'espace de noms, sépare les responsabilités et permettra d'autres refactorisations.

* Les associations singulières (`has_one`, `belongs_to`) n'ont plus de proxy et renvoient simplement l'enregistrement associé ou `nil`. Cela signifie que vous ne devez pas utiliser de méthodes non documentées telles que `bob.mother.create` - utilisez plutôt `bob.create_mother`.

* Prise en charge de l'option `:dependent` sur les associations `has_many :through`. Pour des raisons historiques et pratiques, `:delete_all` est la stratégie de suppression par défaut utilisée par `association.delete(*records)`, malgré le fait que la stratégie par défaut est `:nullify` pour les has_many réguliers. De plus, cela ne fonctionne que si la réflexion source est un belongs_to. Pour d'autres situations, vous devez modifier directement l'association through.

* Le comportement de `association.destroy` pour `has_and_belongs_to_many` et `has_many :through` est modifié. À partir de maintenant, 'destroy' ou 'delete' sur une association signifiera 'se débarrasser du lien', et non pas (nécessairement) 'se débarrasser des enregistrements associés'.

* Auparavant, `has_and_belongs_to_many.destroy(*records)` détruisait les enregistrements eux-mêmes. Il ne supprimait aucun enregistrement dans la table de jointure. Maintenant, il supprime les enregistrements dans la table de jointure.

* Auparavant, `has_many_through.destroy(*records)` détruisait les enregistrements eux-mêmes et les enregistrements dans la table de jointure. [Note : Ce n'a pas toujours été le cas ; les versions précédentes de Rails ne supprimaient que les enregistrements eux-mêmes.] Maintenant, il ne détruit que les enregistrements dans la table de jointure.

* Notez que ce changement est rétrocompatible dans une certaine mesure, mais malheureusement, il n'y a aucun moyen de le 'déprécier' avant de le changer. Le changement est effectué afin d'avoir une cohérence quant à la signification de 'destroy' ou 'delete' dans les différents types d'associations. Si vous souhaitez détruire les enregistrements eux-mêmes, vous pouvez le faire avec `records.association.each(&:destroy)`.

* Ajout de l'option `:bulk => true` à `change_table` pour effectuer toutes les modifications de schéma définies dans un bloc en utilisant une seule instruction ALTER.

```ruby
change_table(:users, :bulk => true) do |t|
  t.string :company_name
  t.change :birthdate, :datetime
end
```

* Suppression de la prise en charge de l'accès aux attributs sur une table de jointure `has_and_belongs_to_many`. Il faut utiliser `has_many :through`.

* Ajout d'une méthode `create_association!` pour les associations `has_one` et `belongs_to`.

* Les migrations sont maintenant réversibles, ce qui signifie que Rails saura comment inverser vos migrations. Pour utiliser des migrations réversibles, il suffit de définir la méthode `change`.

```ruby
class MyMigration < ActiveRecord::Migration
  def change
    create_table(:horses) do |t|
      t.column :content, :text
      t.column :remind_at, :datetime
    end
  end
end
```

* Certaines choses ne peuvent pas être automatiquement inversées pour vous. Si vous savez comment inverser ces choses, vous devez définir `up` et `down` dans votre migration. Si vous définissez quelque chose dans `change` qui ne peut pas être inversé, une exception `IrreversibleMigration` sera levée lors de la descente.

* Les migrations utilisent maintenant des méthodes d'instance plutôt que des méthodes de classe :
```ruby
class FooMigration < ActiveRecord::Migration
  def up # Pas self.up
    # ...
  end
end
```

* Les fichiers de migration générés à partir des générateurs de modèle et de migration constructive (par exemple, add_name_to_users) utilisent la méthode `change` de la migration réversible au lieu des méthodes ordinaires `up` et `down`.

* Suppression de la prise en charge de l'interpolation des conditions SQL de chaîne sur les associations. À la place, une procédure doit être utilisée.

```ruby
has_many :things, :conditions => 'foo = #{bar}'          # avant
has_many :things, :conditions => proc { "foo = #{bar}" } # après
```

À l'intérieur de la procédure, `self` est l'objet qui est le propriétaire de l'association, sauf si vous chargez l'association de manière anticipée, auquel cas `self` est la classe dans laquelle l'association se trouve.

Vous pouvez avoir toutes les conditions "normales" à l'intérieur de la procédure, donc ce qui suit fonctionnera également :

```ruby
has_many :things, :conditions => proc { ["foo = ?", bar] }
```

* Auparavant, `:insert_sql` et `:delete_sql` sur l'association `has_and_belongs_to_many` vous permettaient d'appeler 'record' pour obtenir l'enregistrement qui est inséré ou supprimé. Cela est maintenant passé en argument à la procédure.

* Ajout de `ActiveRecord::Base#has_secure_password` (via `ActiveModel::SecurePassword`) pour encapsuler l'utilisation simple des mots de passe avec le chiffrement et le salage BCrypt.

```ruby
# Schéma : User(name:string, password_digest:string, password_salt:string)
class User < ActiveRecord::Base
  has_secure_password
end
```

* Lorsqu'un modèle est généré, `add_index` est ajouté par défaut pour les colonnes `belongs_to` ou `references`.

* La définition de l'ID d'un objet `belongs_to` mettra à jour la référence vers l'objet.

* Les sémantiques de `ActiveRecord::Base#dup` et `ActiveRecord::Base#clone` ont été modifiées pour correspondre davantage aux sémantiques normales de dup et clone de Ruby.

* L'appel à `ActiveRecord::Base#clone` entraînera une copie superficielle de l'enregistrement, y compris la copie de l'état gelé. Aucun rappel ne sera appelé.

* L'appel à `ActiveRecord::Base#dup` dupliquera l'enregistrement, y compris l'appel des hooks après l'initialisation. L'état gelé ne sera pas copié et toutes les associations seront effacées. Un enregistrement dupliqué renverra `true` pour `new_record?`, aura un champ d'ID `nil` et peut être enregistré.

* Le cache de requête fonctionne maintenant avec les instructions préparées. Aucun changement n'est nécessaire dans les applications.

Active Model
------------

* `attr_accessible` accepte une option `:as` pour spécifier un rôle.

* `InclusionValidator`, `ExclusionValidator` et `FormatValidator` acceptent maintenant une option qui peut être une procédure, une lambda ou tout ce qui répond à `call`. Cette option sera appelée avec l'enregistrement actuel en tant qu'argument et renvoie un objet qui répond à `include?` pour `InclusionValidator` et `ExclusionValidator`, et renvoie un objet d'expression régulière pour `FormatValidator`.

* Ajout de `ActiveModel::SecurePassword` pour encapsuler l'utilisation simple des mots de passe avec le chiffrement et le salage BCrypt.

* `ActiveModel::AttributeMethods` permet de définir des attributs à la demande.

* Ajout de la prise en charge de l'activation et de la désactivation sélective des observateurs.

* La recherche dans l'espace de noms `I18n` alternatif n'est plus prise en charge.

Active Resource
---------------

* Le format par défaut a été changé en JSON pour toutes les requêtes. Si vous voulez continuer à utiliser XML, vous devrez définir `self.format = :xml` dans la classe. Par exemple,

```ruby
class User < ActiveResource::Base
  self.format = :xml
end
```

Active Support
--------------

* `ActiveSupport::Dependencies` lève maintenant une `NameError` s'il trouve une constante existante dans `load_missing_constant`.

* Ajout d'une nouvelle méthode de rapport `Kernel#quietly` qui supprime à la fois `STDOUT` et `STDERR`.

* Ajout de `String#inquiry` en tant que méthode pratique pour transformer une chaîne en un objet `StringInquirer`.

* Ajout de `Object#in?` pour tester si un objet est inclus dans un autre objet.

* La stratégie `LocalCache` est maintenant une véritable classe middleware et n'est plus une classe anonyme.

* La classe `ActiveSupport::Dependencies::ClassCache` a été introduite pour contenir des références aux classes rechargeables.

* `ActiveSupport::Dependencies::Reference` a été refactorisé pour tirer parti directement de la nouvelle `ClassCache`.

* Rétroportage de `Range#cover?` en tant qu'alias de `Range#include?` en Ruby 1.8.

* Ajout de `weeks_ago` et `prev_week` à Date/DateTime/Time.

* Ajout du rappel `before_remove_const` à `ActiveSupport::Dependencies.remove_unloadable_constants!`.

Dépréciations :

* `ActiveSupport::SecureRandom` est déprécié au profit de `SecureRandom` de la bibliothèque standard Ruby.

Crédits
-------

Consultez la [liste complète des contributeurs à Rails](https://contributors.rubyonrails.org/) pour les nombreuses personnes qui ont passé de nombreuses heures à faire de Rails, le framework stable et robuste qu'il est. Félicitations à tous. 

Les notes de version de Rails 3.1 ont été compilées par [Vijay Dev](https://github.com/vijaydev)
