**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 29fda46e32914456eb8369ab3f2cb7d6
Ruby on Rails 2.2 Notes de version
===============================

Rails 2.2 apporte plusieurs fonctionnalités nouvelles et améliorées. Cette liste couvre les principales mises à jour mais ne comprend pas toutes les petites corrections de bugs et modifications. Si vous voulez tout voir, consultez la [liste des commits](https://github.com/rails/rails/commits/2-2-stable) dans le référentiel principal de Rails sur GitHub.

En plus de Rails, la version 2.2 marque le lancement des [Guides Ruby on Rails](https://guides.rubyonrails.org/), les premiers résultats du hackfest en cours des [Guides Rails](http://hackfest.rubyonrails.org/guide). Ce site fournira une documentation de haute qualité sur les principales fonctionnalités de Rails.

--------------------------------------------------------------------------------

Infrastructure
--------------

Rails 2.2 est une version importante pour l'infrastructure qui permet à Rails de fonctionner correctement et d'être connecté au reste du monde.

### Internationalisation

Rails 2.2 fournit un système facile pour l'internationalisation (ou i18n, pour ceux d'entre vous qui en ont marre de taper).

* Principaux contributeurs : Équipe Rails i18n
* Plus d'informations :
    * [Site web officiel de Rails i18n](http://rails-i18n.org)
    * [Enfin. Ruby on Rails est internationalisé](https://web.archive.org/web/20140407075019/http://www.artweb-design.de/2008/7/18/finally-ruby-on-rails-gets-internationalized)
    * [Localiser Rails : Application de démonstration](https://github.com/clemens/i18n_demo_app)

### Compatibilité avec Ruby 1.9 et JRuby

En plus de la sécurité des threads, beaucoup de travail a été fait pour que Rails fonctionne bien avec JRuby et la prochaine version de Ruby 1.9. Étant donné que Ruby 1.9 est en constante évolution, exécuter Rails de pointe sur Ruby de pointe est encore une proposition aléatoire, mais Rails est prêt à passer à Ruby 1.9 lorsque ce dernier sera publié.

Documentation
-------------

La documentation interne de Rails, sous forme de commentaires de code, a été améliorée à de nombreux endroits. De plus, le projet [Ruby on Rails Guides](https://guides.rubyonrails.org/) est la source définitive d'informations sur les principaux composants de Rails. Dans sa première version officielle, la page Guides comprend :

* [Commencer avec Rails](getting_started.html)
* [Migrations de base de données Rails](active_record_migrations.html)
* [Associations Active Record](association_basics.html)
* [Interface de requête Active Record](active_record_querying.html)
* [Mises en page et rendu dans Rails](layouts_and_rendering.html)
* [Aides de formulaire Action View](form_helpers.html)
* [Routing Rails de l'extérieur vers l'intérieur](routing.html)
* [Présentation d'Action Controller](action_controller_overview.html)
* [Mise en cache Rails](caching_with_rails.html)
* [Guide pour tester les applications Rails](testing.html)
* [Sécurisation des applications Rails](security.html)
* [Débogage des applications Rails](debugging_rails_applications.html)
* [Les bases de la création de plugins Rails](plugins.html)

Au total, les Guides fournissent des dizaines de milliers de mots de conseils pour les développeurs Rails débutants et intermédiaires.

Si vous souhaitez générer ces guides localement, à l'intérieur de votre application :

```bash
$ rake doc:guides
```

Cela placera les guides dans `Rails.root/doc/guides` et vous pourrez commencer à les consulter en ouvrant `Rails.root/doc/guides/index.html` dans votre navigateur préféré.

* Contributions majeures de [Xavier Noria](http://advogato.org/person/fxn/diary.html) et [Hongli Lai](http://izumi.plan99.net/blog/).
* Plus d'informations :
    * [Hackfest Rails Guides](http://hackfest.rubyonrails.org/guide)
    * [Aidez à améliorer la documentation de Rails sur la branche Git](https://weblog.rubyonrails.org/2008/5/2/help-improve-rails-documentation-on-git-branch)

Meilleure intégration avec HTTP : Prise en charge ETag prête à l'emploi
----------------------------------------------------------

La prise en charge des en-têtes ETag et de la dernière modification dans les en-têtes HTTP signifie que Rails peut maintenant renvoyer une réponse vide s'il reçoit une demande pour une ressource qui n'a pas été modifiée récemment. Cela vous permet de vérifier si une réponse doit être envoyée ou non.

```ruby
class ArticlesController < ApplicationController
  def show_with_respond_to_block
    @article = Article.find(params[:id])

    # Si la demande envoie des en-têtes différents des options fournies à stale?, alors
    # la demande est effectivement obsolète et le bloc respond_to est déclenché (et les options
    # de l'appel à stale? sont définies sur la réponse).
    #
    # Si les en-têtes de la demande correspondent, alors la demande est à jour et le bloc respond_to n'est
    # pas déclenché. À la place, le rendu par défaut se produit, qui vérifiera les en-têtes last-modified
    # et etag et conclura qu'il suffit d'envoyer un "304 Not Modified" au lieu de rendre le modèle.
    if stale?(:last_modified => @article.published_at.utc, :etag => @article)
      respond_to do |wants|
        # traitement normal de la réponse
      end
    end
  end

  def show_with_implied_render
    @article = Article.find(params[:id])

    # Définit les en-têtes de réponse et les vérifie par rapport à la demande, si la demande est obsolète
    # (c'est-à-dire aucune correspondance avec etag ou last-modified), alors le rendu par défaut du modèle se produit.
    # Si la demande est à jour, alors le rendu par défaut renverra un "304 Not Modified"
    # au lieu de rendre le modèle.
    fresh_when(:last_modified => @article.published_at.utc, :etag => @article)
  end
end
```

Sécurité des threads
-------------

Le travail effectué pour rendre Rails sécurisé pour les threads est déployé dans Rails 2.2. Selon votre infrastructure de serveur web, cela signifie que vous pouvez traiter plus de demandes avec moins de copies de Rails en mémoire, ce qui améliore les performances du serveur et utilise davantage les cœurs multiples.
Pour activer la répartition multithreadée en mode de production de votre application, ajoutez la ligne suivante dans votre fichier `config/environments/production.rb` :

```ruby
config.threadsafe!
```

* Plus d'informations :
    * [Thread safety for your Rails](http://m.onkey.org/2008/10/23/thread-safety-for-your-rails)
    * [Thread safety project announcement](https://weblog.rubyonrails.org/2008/8/16/josh-peek-officially-joins-the-rails-core)
    * [Q/A: What Thread-safe Rails Means](http://blog.headius.com/2008/08/qa-what-thread-safe-rails-means.html)

Active Record
-------------

Il y a deux grandes nouveautés à mentionner ici : les migrations transactionnelles et les transactions de base de données en pool. Il y a aussi une nouvelle syntaxe (plus propre) pour les conditions de jointure de tables, ainsi que plusieurs autres améliorations mineures.

### Migrations transactionnelles

Historiquement, les migrations en plusieurs étapes dans Rails ont posé problème. Si quelque chose se passait mal pendant une migration, tout ce qui avait été modifié avant l'erreur était enregistré dans la base de données et tout ce qui venait après l'erreur n'était pas appliqué. De plus, la version de la migration était enregistrée comme ayant été exécutée, ce qui signifie qu'elle ne pouvait pas simplement être réexécutée avec `rake db:migrate:redo` après avoir corrigé le problème. Les migrations transactionnelles changent cela en enveloppant les étapes de migration dans une transaction DDL, de sorte que si l'une d'entre elles échoue, la migration entière est annulée. Dans Rails 2.2, les migrations transactionnelles sont prises en charge par défaut sur PostgreSQL. Le code est extensible à d'autres types de bases de données à l'avenir - et IBM l'a déjà étendu pour prendre en charge l'adaptateur DB2.

* Contributeur principal : [Adam Wiggins](http://about.adamwiggins.com/)
* Plus d'informations :
    * [DDL Transactions](http://adam.heroku.com/past/2008/9/3/ddl_transactions/)
    * [A major milestone for DB2 on Rails](http://db2onrails.com/2008/11/08/a-major-milestone-for-db2-on-rails/)

### Pool de connexions

Le pool de connexions permet à Rails de répartir les requêtes de base de données sur un ensemble de connexions de base de données qui augmentera jusqu'à une taille maximale (par défaut 5, mais vous pouvez ajouter une clé `pool` à votre fichier `database.yml` pour ajuster cela). Cela permet de supprimer les goulots d'étranglement dans les applications qui prennent en charge de nombreux utilisateurs simultanés. Il y a aussi un `wait_timeout` qui est par défaut de 5 secondes avant d'abandonner. `ActiveRecord::Base.connection_pool` vous donne un accès direct au pool si vous en avez besoin.

```yaml
development:
  adapter: mysql
  username: root
  database: sample_development
  pool: 10
  wait_timeout: 10
```

* Contributeur principal : [Nick Sieger](http://blog.nicksieger.com/)
* Plus d'informations :
    * [What's New in Edge Rails: Connection Pools](http://archives.ryandaigle.com/articles/2008/9/7/what-s-new-in-edge-rails-connection-pools)

### Hashes pour les conditions de jointure de tables

Vous pouvez désormais spécifier des conditions sur les tables de jointure à l'aide d'un hash. Cela est très utile si vous avez besoin de faire des requêtes sur des jointures complexes.

```ruby
class Photo < ActiveRecord::Base
  belongs_to :product
end

class Product < ActiveRecord::Base
  has_many :photos
end

# Obtenir tous les produits avec des photos libres de droits :
Product.all(:joins => :photos, :conditions => { :photos => { :copyright => false }})
```

* Plus d'informations :
    * [What's New in Edge Rails: Easy Join Table Conditions](http://archives.ryandaigle.com/articles/2008/7/7/what-s-new-in-edge-rails-easy-join-table-conditions)

### Nouveaux finders dynamiques

Deux nouveaux ensembles de méthodes ont été ajoutés à la famille des finders dynamiques d'Active Record.

#### `find_last_by_attribute`

La méthode `find_last_by_attribute` est équivalente à `Model.last(:conditions => {:attribute => value})`

```ruby
# Obtenir le dernier utilisateur inscrit de Londres
User.find_last_by_city('Londres')
```

* Contributeur principal : [Emilio Tagua](http://www.workingwithrails.com/person/9147-emilio-tagua)

#### `find_by_attribute!`

La nouvelle version bang! de `find_by_attribute!` est équivalente à `Model.first(:conditions => {:attribute => value}) || raise ActiveRecord::RecordNotFound`. Au lieu de renvoyer `nil` si aucune correspondance n'est trouvée, cette méthode lèvera une exception si aucune correspondance n'est trouvée.

```ruby
# Lève une exception ActiveRecord::RecordNotFound si 'Moby' ne s'est pas encore inscrit !
User.find_by_name!('Moby')
```

* Contributeur principal : [Josh Susser](http://blog.hasmanythrough.com)

### Les associations respectent les portées privées/protégées

Les proxies d'association d'Active Record respectent désormais la portée des méthodes sur l'objet proxy. Auparavant (si User a_one :account), `@user.account.private_method` appelait la méthode privée sur l'objet Account associé. Cela échoue dans Rails 2.2 ; si vous avez besoin de cette fonctionnalité, vous devriez utiliser `@user.account.send(:private_method)` (ou rendre la méthode publique au lieu de privée ou protégée). Veuillez noter que si vous remplacez `method_missing`, vous devez également remplacer `respond_to` pour correspondre au comportement afin que les associations fonctionnent normalement.

* Contributeur principal : Adam Milligan
* Plus d'informations :
    * [Rails 2.2 Change: Private Methods on Association Proxies are Private](http://afreshcup.com/2008/10/24/rails-22-change-private-methods-on-association-proxies-are-private/)

### Autres changements d'Active Record

* `rake db:migrate:redo` accepte maintenant une VERSION facultative pour cibler cette migration spécifique à refaire
* Définissez `config.active_record.timestamped_migrations = false` pour avoir des migrations avec un préfixe numérique au lieu d'un horodatage UTC.
* Les colonnes de comptage de cache (pour les associations déclarées avec `:counter_cache => true`) n'ont plus besoin d'être initialisées à zéro.
* `ActiveRecord::Base.human_name` pour une traduction humaine consciente de l'internationalisation des noms de modèle

Action Controller
-----------------

Du côté du contrôleur, il y a plusieurs changements qui vous aideront à organiser vos routes. Il y a aussi quelques changements internes dans le moteur de routage pour réduire l'utilisation de la mémoire dans les applications complexes.
### Imbrication de routes peu profondes

L'imbrication de routes peu profondes offre une solution à la difficulté bien connue d'utilisation de ressources profondément imbriquées. Avec l'imbrication peu profonde, vous devez fournir suffisamment d'informations pour identifier de manière unique la ressource avec laquelle vous souhaitez travailler.

```ruby
map.resources :publishers, :shallow => true do |publisher|
  publisher.resources :magazines do |magazine|
    magazine.resources :photos
  end
end
```

Cela permettra la reconnaissance (entre autres) de ces routes :

```
/publishers/1           ==> publisher_path(1)
/publishers/1/magazines ==> publisher_magazines_path(1)
/magazines/2            ==> magazine_path(2)
/magazines/2/photos     ==> magazines_photos_path(2)
/photos/3               ==> photo_path(3)
```

* Contributeur principal : [S. Brent Faulkner](http://www.unwwwired.net/)
* Plus d'informations :
    * [Rails Routing from the Outside In](routing.html#nested-resources)
    * [What's New in Edge Rails: Shallow Routes](http://archives.ryandaigle.com/articles/2008/9/7/what-s-new-in-edge-rails-shallow-routes)

### Tableaux de méthodes pour les routes de membre ou de collection

Vous pouvez maintenant fournir un tableau de méthodes pour les nouvelles routes de membre ou de collection. Cela supprime la contrainte de devoir définir une route comme acceptant n'importe quelle méthode dès que vous avez besoin de gérer plus d'une méthode. Avec Rails 2.2, c'est une déclaration de route légitime :

```ruby
map.resources :photos, :collection => { :search => [:get, :post] }
```

* Contributeur principal : [Brennan Dunn](http://brennandunn.com/)

### Ressources avec des actions spécifiques

Par défaut, lorsque vous utilisez `map.resources` pour créer une route, Rails génère des routes pour sept actions par défaut (index, show, create, new, edit, update et destroy). Mais chacune de ces routes occupe de la mémoire dans votre application et fait en sorte que Rails génère une logique de routage supplémentaire. Maintenant, vous pouvez utiliser les options `:only` et `:except` pour affiner les routes que Rails générera pour les ressources. Vous pouvez fournir une seule action, un tableau d'actions ou les options spéciales `:all` ou `:none`. Ces options sont héritées par les ressources imbriquées.

```ruby
map.resources :photos, :only => [:index, :show]
map.resources :products, :except => :destroy
```

* Contributeur principal : [Tom Stuart](http://experthuman.com/)

### Autres changements dans Action Controller

* Vous pouvez maintenant facilement [afficher une page d'erreur personnalisée](http://m.onkey.org/2008/7/20/rescue-from-dispatching) pour les exceptions levées lors du routage d'une requête.
* L'en-tête Accept-Header est désactivé par défaut maintenant. Vous devriez préférer l'utilisation d'URL formatées (comme `/customers/1.xml`) pour indiquer le format que vous souhaitez. Si vous avez besoin des en-têtes Accept, vous pouvez les réactiver avec `config.action_controller.use_accept_header = true`.
* Les chiffres des benchmarks sont maintenant rapportés en millisecondes plutôt qu'en fractions de secondes.
* Rails prend maintenant en charge les cookies uniquement HTTP (et les utilise pour les sessions), ce qui aide à atténuer certains risques de script intersite dans les navigateurs plus récents.
* `redirect_to` prend maintenant en charge pleinement les schémas d'URI (ainsi, par exemple, vous pouvez rediriger vers un URI svn`ssh:).
* `render` prend maintenant en charge une option `:js` pour afficher du JavaScript simple avec le bon type MIME.
* La protection contre les attaques de falsification de requête a été renforcée pour s'appliquer uniquement aux requêtes de contenu au format HTML.
* Les URL polymorphiques se comportent de manière plus logique si un paramètre passé est nul. Par exemple, en appelant `polymorphic_path([@project, @date, @area])` avec une date nulle, vous obtiendrez `project_area_path`.

Action View
-----------

* `javascript_include_tag` et `stylesheet_link_tag` prennent en charge une nouvelle option `:recursive` à utiliser avec `:all`, afin que vous puissiez charger un arbre entier de fichiers avec une seule ligne de code.
* La bibliothèque JavaScript Prototype incluse a été mise à jour en version 1.6.0.3.
* `RJS#page.reload` pour recharger l'emplacement actuel du navigateur via JavaScript.
* L'aide `atom_feed` prend maintenant une option `:instruct` pour vous permettre d'insérer des instructions de traitement XML.

Action Mailer
-------------

Action Mailer prend maintenant en charge les mises en page des mailers. Vous pouvez rendre vos e-mails HTML aussi jolis que vos vues dans le navigateur en fournissant une mise en page portant le nom approprié - par exemple, la classe `CustomerMailer` s'attend à utiliser `layouts/customer_mailer.html.erb`.

* Plus d'informations :
    * [What's New in Edge Rails: Mailer Layouts](http://archives.ryandaigle.com/articles/2008/9/7/what-s-new-in-edge-rails-mailer-layouts)

Action Mailer offre maintenant une prise en charge intégrée des serveurs SMTP de GMail, en activant automatiquement STARTTLS. Cela nécessite l'installation de Ruby 1.8.7.

Active Support
--------------

Active Support offre maintenant une mémoïsation intégrée pour les applications Rails, la méthode `each_with_object`, la prise en charge des préfixes sur les délégués et diverses autres nouvelles méthodes utilitaires.

### Mémoïsation

La mémoïsation est un modèle d'initialisation d'une méthode une fois, puis de stockage de sa valeur pour une utilisation ultérieure. Vous avez probablement utilisé ce modèle dans vos propres applications :

```ruby
def full_name
  @full_name ||= "#{first_name} #{last_name}"
end
```

La mémoïsation vous permet de gérer cette tâche de manière déclarative :

```ruby
extend ActiveSupport::Memoizable

def full_name
  "#{first_name} #{last_name}"
end
memoize :full_name
```

D'autres fonctionnalités de la mémoïsation incluent `unmemoize`, `unmemoize_all` et `memoize_all` pour activer ou désactiver la mémoïsation.
* Contributeur principal : [Josh Peek](http://joshpeek.com/)
* Plus d'informations :
    * [Quoi de neuf dans Edge Rails : Easy Memoization](http://archives.ryandaigle.com/articles/2008/7/16/what-s-new-in-edge-rails-memoization)
    * [Memo-quoi ? Un guide de la mémoization](http://www.railway.at/articles/2008/09/20/a-guide-to-memoization)

### each_with_object

La méthode `each_with_object` fournit une alternative à `inject`, en utilisant une méthode rétroportée de Ruby 1.9. Elle itère sur une collection, en passant l'élément courant et le mémo dans le bloc.

```ruby
%w(foo bar).each_with_object({}) { |str, hsh| hsh[str] = str.upcase } # => {'foo' => 'FOO', 'bar' => 'BAR'}
```

Contributeur principal : [Adam Keys](http://therealadam.com/)

### Délégués avec préfixes

Si vous déléguez un comportement d'une classe à une autre, vous pouvez maintenant spécifier un préfixe qui sera utilisé pour identifier les méthodes déléguées. Par exemple :

```ruby
class Vendor < ActiveRecord::Base
  has_one :account
  delegate :email, :password, :to => :account, :prefix => true
end
```

Cela produira les méthodes déléguées `vendor#account_email` et `vendor#account_password`. Vous pouvez également spécifier un préfixe personnalisé :

```ruby
class Vendor < ActiveRecord::Base
  has_one :account
  delegate :email, :password, :to => :account, :prefix => :owner
end
```

Cela produira les méthodes déléguées `vendor#owner_email` et `vendor#owner_password`.

Contributeur principal : [Daniel Schierbeck](http://workingwithrails.com/person/5830-daniel-schierbeck)

### Autres changements dans Active Support

* Mises à jour importantes de `ActiveSupport::Multibyte`, y compris des corrections de compatibilité avec Ruby 1.9.
* L'ajout de `ActiveSupport::Rescuable` permet à n'importe quelle classe d'inclure la syntaxe `rescue_from`.
* `past?`, `today?` et `future?` pour les classes `Date` et `Time` pour faciliter les comparaisons de dates/heure.
* `Array#second` à `Array#fifth` comme alias de `Array#[1]` à `Array#[4]`.
* `Enumerable#many?` pour encapsuler `collection.size > 1`.
* `Inflector#parameterize` produit une version prête pour les URL de son entrée, à utiliser dans `to_param`.
* `Time#advance` reconnaît les jours et les semaines fractionnaires, vous pouvez donc faire `1.7.weeks.ago`, `1.5.hours.since`, etc.
* La bibliothèque TzInfo incluse a été mise à jour en version 0.3.12.
* `ActiveSupport::StringInquirer` vous permet de tester l'égalité de manière élégante dans les chaînes de caractères : `ActiveSupport::StringInquirer.new("abc").abc? => true`

Railties
--------

Dans Railties (le code principal de Rails lui-même), les plus grands changements se trouvent dans le mécanisme `config.gems`.

### config.gems

Pour éviter les problèmes de déploiement et rendre les applications Rails plus autonomes, il est possible de placer des copies de toutes les gemmes requises par votre application Rails dans `/vendor/gems`. Cette fonctionnalité est apparue pour la première fois dans Rails 2.1, mais elle est beaucoup plus flexible et robuste dans Rails 2.2, gérant les dépendances complexes entre les gemmes. La gestion des gemmes dans Rails comprend ces commandes :

* `config.gem _nom_de_la_gem_` dans votre fichier `config/environment.rb`
* `rake gems` pour lister toutes les gemmes configurées, ainsi que si elles (et leurs dépendances) sont installées, gelées ou du framework (les gemmes du framework sont celles chargées par Rails avant l'exécution du code de dépendance des gemmes ; ces gemmes ne peuvent pas être gelées)
* `rake gems:install` pour installer les gemmes manquantes sur l'ordinateur
* `rake gems:unpack` pour placer une copie des gemmes requises dans `/vendor/gems`
* `rake gems:unpack:dependencies` pour obtenir des copies des gemmes requises et de leurs dépendances dans `/vendor/gems`
* `rake gems:build` pour construire les extensions natives manquantes
* `rake gems:refresh_specs` pour aligner les gemmes gelées créées avec Rails 2.1 sur la manière de les stocker dans Rails 2.2

Vous pouvez déballer ou installer une seule gemme en spécifiant `GEM=_nom_de_la_gem_` en ligne de commande.

* Contributeur principal : [Matt Jones](https://github.com/al2o3cr)
* Plus d'informations :
    * [Quoi de neuf dans Edge Rails : Dépendances de gemmes](http://archives.ryandaigle.com/articles/2008/4/1/what-s-new-in-edge-rails-gem-dependencies)
    * [Rails 2.1.2 et 2.2RC1 : Mettez à jour votre RubyGems](https://afreshcup.com/home/2008/10/25/rails-212-and-22rc1-update-your-rubygems)
    * [Discussion détaillée sur Lighthouse](http://rails.lighthouseapp.com/projects/8994-ruby-on-rails/tickets/1128)

### Autres changements dans Railties

* Si vous êtes fan du serveur web [Thin](http://code.macournoyer.com/thin/), vous serez heureux de savoir que `script/server` prend désormais en charge Thin directement.
* `script/plugin install &lt;plugin&gt; -r &lt;revision&gt;` fonctionne maintenant avec des plugins basés sur git ainsi que des plugins basés sur svn.
* `script/console` prend désormais en charge l'option `--debugger`.
* Les instructions pour configurer un serveur d'intégration continue pour construire Rails lui-même sont incluses dans la source de Rails.
* `rake notes:custom ANNOTATION=MYFLAG` vous permet de lister des annotations personnalisées.
* `Rails.env` est enveloppé dans `StringInquirer` afin que vous puissiez faire `Rails.env.development?`.
* Pour éliminer les avertissements de dépréciation et gérer correctement les dépendances des gemmes, Rails nécessite maintenant rubygems 1.3.1 ou une version ultérieure.

Déprécié
---------

Quelques parties de code plus anciennes sont dépréciées dans cette version :

* `Rails::SecretKeyGenerator` a été remplacé par `ActiveSupport::SecureRandom`.
* `render_component` est déprécié. Il existe un [plugin render_components](https://github.com/rails/render_component/tree/master) disponible si vous avez besoin de cette fonctionnalité.
* Les affectations locales implicites lors du rendu de partiels sont dépréciées.

    ```ruby
    def partial_with_implicit_local_assignment
      @customer = Customer.new("Marcel")
      render :partial => "customer"
    end
    ```

    Auparavant, le code ci-dessus rendait disponible une variable locale appelée `customer` à l'intérieur du partiel 'customer'. Vous devez maintenant passer explicitement toutes les variables via le hash `:locals`.
* `country_select` a été supprimé. Veuillez consulter la [page de dépréciation](http://www.rubyonrails.org/deprecation/list-of-countries) pour plus d'informations et un remplacement de plugin.
* `ActiveRecord::Base.allow_concurrency` n'a plus aucun effet.
* `ActiveRecord::Errors.default_error_messages` a été déprécié au profit de `I18n.translate('activerecord.errors.messages')`.
* La syntaxe d'interpolation `%s` et `%d` pour l'internationalisation est dépréciée.
* `String#chars` a été déprécié au profit de `String#mb_chars`.
* Les durées de mois fractionnaires ou d'années fractionnaires sont dépréciées. Utilisez plutôt l'arithmétique des classes `Date` et `Time` de base de Ruby.
* `Request#relative_url_root` est déprécié. Utilisez plutôt `ActionController::Base.relative_url_root`.

Crédits
-------

Notes de version compilées par [Mike Gunderloy](http://afreshcup.com)
