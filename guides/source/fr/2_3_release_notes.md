**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 77b47af4826df984dead9f6263cfd135
Ruby on Rails 2.3 Notes de version
===============================

Rails 2.3 offre une variété de fonctionnalités nouvelles et améliorées, notamment une intégration généralisée de Rack, une prise en charge actualisée des Rails Engines, des transactions imbriquées pour Active Record, des scopes dynamiques et par défaut, un rendu unifié, un routage plus efficace, des modèles d'application et des traces d'exécution silencieuses. Cette liste couvre les principales mises à jour, mais ne comprend pas toutes les petites corrections de bugs et modifications. Si vous souhaitez tout voir, consultez la [liste des commits](https://github.com/rails/rails/commits/2-3-stable) dans le référentiel principal de Rails sur GitHub ou examinez les fichiers `CHANGELOG` des composants individuels de Rails.

--------------------------------------------------------------------------------

Architecture de l'application
------------------------

Il y a deux changements majeurs dans l'architecture des applications Rails : l'intégration complète de l'interface du serveur web modulaire [Rack](https://rack.github.io/) et le support renouvelé des Rails Engines.

### Intégration de Rack

Rails a maintenant rompu avec son passé CGI et utilise Rack partout. Cela a nécessité et entraîné un nombre considérable de modifications internes (mais si vous utilisez CGI, ne vous inquiétez pas ; Rails prend désormais en charge CGI via une interface de proxy). Néanmoins, il s'agit d'un changement majeur pour les composants internes de Rails. Après la mise à niveau vers 2.3, vous devriez effectuer des tests sur votre environnement local et votre environnement de production. Voici quelques éléments à tester :

* Sessions
* Cookies
* Téléchargements de fichiers
* API JSON/XML

Voici un résumé des changements liés à Rack :

* `script/server` a été modifié pour utiliser Rack, ce qui signifie qu'il prend en charge n'importe quel serveur compatible avec Rack. `script/server` utilisera également un fichier de configuration rackup s'il en existe un. Par défaut, il recherchera un fichier `config.ru`, mais vous pouvez le remplacer avec l'option `-c`.
* Le gestionnaire FCGI passe par Rack.
* `ActionController::Dispatcher` maintient sa propre pile de middleware par défaut. Les middlewares peuvent être injectés, réordonnés et supprimés. La pile est compilée en une chaîne au démarrage. Vous pouvez configurer la pile de middleware dans `environment.rb`.
* La tâche `rake middleware` a été ajoutée pour inspecter la pile de middleware. Cela est utile pour déboguer l'ordre de la pile de middleware.
* Le lanceur de tests d'intégration a été modifié pour exécuter l'ensemble de la pile de middleware et d'application. Cela rend les tests d'intégration parfaits pour tester les middlewares Rack.
* `ActionController::CGIHandler` est un wrapper CGI compatible avec les anciennes versions de Rack. Le `CGIHandler` est conçu pour prendre un ancien objet CGI et convertir ses informations d'environnement en une forme compatible avec Rack.
* `CgiRequest` et `CgiResponse` ont été supprimés.
* Les magasins de session sont désormais chargés de manière paresseuse. Si vous n'accédez jamais à l'objet de session lors d'une requête, il n'essaiera jamais de charger les données de session (analyser le cookie, charger les données depuis memcache ou rechercher un objet Active Record).
* Vous n'avez plus besoin d'utiliser `CGI::Cookie.new` dans vos tests pour définir une valeur de cookie. L'assignation d'une valeur `String` à `request.cookies["foo"]` définit désormais le cookie comme prévu.
* `CGI::Session::CookieStore` a été remplacé par `ActionController::Session::CookieStore`.
* `CGI::Session::MemCacheStore` a été remplacé par `ActionController::Session::MemCacheStore`.
* `CGI::Session::ActiveRecordStore` a été remplacé par `ActiveRecord::SessionStore`.
* Vous pouvez toujours modifier votre magasin de session avec `ActionController::Base.session_store = :active_record_store`.
* Les options de session par défaut sont toujours définies avec `ActionController::Base.session = { :key => "..." }`. Cependant, l'option `:session_domain` a été renommée en `:domain`.
* Le mutex qui enveloppe normalement toute votre requête a été déplacé dans le middleware `ActionController::Lock`.
* `ActionController::AbstractRequest` et `ActionController::Request` ont été unifiés. Le nouveau `ActionController::Request` hérite de `Rack::Request`. Cela affecte l'accès à `response.headers['type']` dans les requêtes de test. Utilisez plutôt `response.content_type`.
* Le middleware `ActiveRecord::QueryCache` est automatiquement inséré dans la pile de middleware si `ActiveRecord` a été chargé. Ce middleware configure et vide le cache de requêtes Active Record par requête.
* Le routeur et les classes de contrôleur Rails suivent la spécification Rack. Vous pouvez appeler un contrôleur directement avec `SomeController.call(env)`. Le routeur stocke les paramètres de routage dans `rack.routing_args`.
* `ActionController::Request` hérite de `Rack::Request`.
* Au lieu de `config.action_controller.session = { :session_key => 'foo', ...`, utilisez `config.action_controller.session = { :key => 'foo', ...`.

### Support renouvelé pour les Rails Engines

Après plusieurs versions sans mise à niveau, Rails 2.3 offre de nouvelles fonctionnalités pour les Rails Engines (des applications Rails pouvant être intégrées à d'autres applications). Premièrement, les fichiers de routage dans les engines sont désormais automatiquement chargés et rechargés, tout comme votre fichier `routes.rb` (cela s'applique également aux fichiers de routage dans d'autres plugins). Deuxièmement, si votre plugin dispose d'un dossier app, alors app/[models|controllers|helpers] sera automatiquement ajouté au chemin de chargement de Rails. Les engines prennent également en charge l'ajout de chemins de vue, et Action Mailer ainsi que Action View utiliseront les vues des engines et autres plugins.
Documentation
-------------

Le projet [Ruby on Rails guides](https://guides.rubyonrails.org/) a publié plusieurs guides supplémentaires pour Rails 2.3. De plus, un [site séparé](https://edgeguides.rubyonrails.org/) maintient des copies mises à jour des Guides pour Edge Rails. D'autres efforts de documentation comprennent le relancement du [wiki Rails](http://newwiki.rubyonrails.org/) et la planification préliminaire d'un livre sur Rails.

* Plus d'informations : [Projets de documentation Rails](https://weblog.rubyonrails.org/2009/1/15/rails-documentation-projects)

Prise en charge de Ruby 1.9.1
------------------

Rails 2.3 devrait réussir tous ses propres tests, que vous utilisiez Ruby 1.8 ou la version maintenant publiée de Ruby 1.9.1. Cependant, vous devez savoir que passer à 1.9.1 nécessite de vérifier la compatibilité de tous les adaptateurs de données, plugins et autres codes dont vous dépendez avec Ruby 1.9.1, ainsi qu'avec le noyau de Rails.

Active Record
-------------

Active Record bénéficie de plusieurs nouvelles fonctionnalités et corrections de bugs dans Rails 2.3. Les points forts incluent les attributs imbriqués, les transactions imbriquées, les scopes dynamiques et par défaut, ainsi que le traitement par lots.

### Attributs imbriqués

Active Record peut maintenant mettre à jour directement les attributs sur les modèles imbriqués, à condition que vous lui indiquiez de le faire :

```ruby
class Book < ActiveRecord::Base
  has_one :author
  has_many :pages

  accepts_nested_attributes_for :author, :pages
end
```

L'activation des attributs imbriqués permet plusieurs choses : enregistrement automatique (et atomique) d'un enregistrement avec ses enfants associés, validations conscientes des enfants et prise en charge des formulaires imbriqués (discutés plus tard).

Vous pouvez également spécifier des exigences pour les nouveaux enregistrements ajoutés via les attributs imbriqués en utilisant l'option `:reject_if` :

```ruby
accepts_nested_attributes_for :author,
  :reject_if => proc { |attributes| attributes['name'].blank? }
```

* Contributeur principal : [Eloy Duran](http://superalloy.nl/)
* Plus d'informations : [Formulaires de modèles imbriqués](https://weblog.rubyonrails.org/2009/1/26/nested-model-forms)

### Transactions imbriquées

Active Record prend désormais en charge les transactions imbriquées, une fonctionnalité très demandée. Vous pouvez maintenant écrire du code comme ceci :

```ruby
User.transaction do
  User.create(:username => 'Admin')
  User.transaction(:requires_new => true) do
    User.create(:username => 'Regular')
    raise ActiveRecord::Rollback
  end
end

User.find(:all)  # => Ne renvoie que Admin
```

Les transactions imbriquées vous permettent d'annuler une transaction interne sans affecter l'état de la transaction externe. Si vous souhaitez qu'une transaction soit imbriquée, vous devez ajouter explicitement l'option `:requires_new` ; sinon, une transaction imbriquée devient simplement une partie de la transaction parente (comme c'est le cas actuellement dans Rails 2.2). En interne, les transactions imbriquées utilisent des points de sauvegarde, elles sont donc prises en charge même sur les bases de données qui n'ont pas de véritables transactions imbriquées. Il y a aussi un peu de magie pour que ces transactions fonctionnent bien avec les fixtures transactionnelles lors des tests.

* Contributeurs principaux : [Jonathan Viney](http://www.workingwithrails.com/person/4985-jonathan-viney) et [Hongli Lai](http://izumi.plan99.net/blog/)

### Scopes dynamiques

Vous connaissez les finders dynamiques dans Rails (qui vous permettent de créer des méthodes comme `find_by_color_and_flavor` à la volée) et les scopes nommés (qui vous permettent d'encapsuler des conditions de requête réutilisables dans des noms conviviaux comme `currently_active`). Eh bien, maintenant vous pouvez avoir des méthodes de scope dynamiques. L'idée est de mettre en place une syntaxe qui permet de filtrer à la volée _et_ de chaîner les méthodes. Par exemple :

```ruby
Order.scoped_by_customer_id(12)
Order.scoped_by_customer_id(12).find(:all,
  :conditions => "status = 'open'")
Order.scoped_by_customer_id(12).scoped_by_status("open")
```

Il n'y a rien à définir pour utiliser les scopes dynamiques : ils fonctionnent simplement.

* Contributeur principal : [Yaroslav Markin](http://evilmartians.com/)
* Plus d'informations : [Quoi de neuf dans Edge Rails : Méthodes de scope dynamiques](http://archives.ryandaigle.com/articles/2008/12/29/what-s-new-in-edge-rails-dynamic-scope-methods)

### Scopes par défaut

Rails 2.3 introduira la notion de _scopes par défaut_, similaires aux scopes nommés, mais s'appliquant à tous les scopes nommés ou méthodes de recherche dans le modèle. Par exemple, vous pouvez écrire `default_scope :order => 'name ASC'` et chaque fois que vous récupérez des enregistrements de ce modèle, ils seront triés par nom (à moins que vous ne substituiez l'option, bien sûr).

* Contributeur principal : Paweł Kondzior
* Plus d'informations : [Quoi de neuf dans Edge Rails : Scoping par défaut](http://archives.ryandaigle.com/articles/2008/11/18/what-s-new-in-edge-rails-default-scoping)

### Traitement par lots

Vous pouvez maintenant traiter un grand nombre d'enregistrements d'un modèle Active Record avec moins de pression sur la mémoire en utilisant `find_in_batches` :

```ruby
Customer.find_in_batches(:conditions => {:active => true}) do |customer_group|
  customer_group.each { |customer| customer.update_account_balance! }
end
```

Vous pouvez passer la plupart des options de `find` dans `find_in_batches`. Cependant, vous ne pouvez pas spécifier l'ordre dans lequel les enregistrements seront renvoyés (ils seront toujours renvoyés dans l'ordre croissant de la clé primaire, qui doit être un entier), ni utiliser l'option `:limit`. À la place, utilisez l'option `:batch_size`, qui est par défaut de 1000, pour définir le nombre d'enregistrements qui seront renvoyés dans chaque lot.

La nouvelle méthode `find_each` fournit un wrapper autour de `find_in_batches` qui renvoie des enregistrements individuels, la recherche elle-même étant effectuée par lots (de 1000 par défaut) :

```ruby
Customer.find_each do |customer|
  customer.update_account_balance!
end
```
Notez que vous ne devriez utiliser cette méthode que pour le traitement par lots : pour un petit nombre d'enregistrements (moins de 1000), vous devriez simplement utiliser les méthodes de recherche régulières avec votre propre boucle.

* Plus d'informations (à ce moment-là, la méthode de commodité était appelée simplement `each`) :
    * [Rails 2.3 : Recherche par lots](http://afreshcup.com/2009/02/23/rails-23-batch-finding/)
    * [Quoi de neuf dans Edge Rails : Recherche par lots](http://archives.ryandaigle.com/articles/2009/2/23/what-s-new-in-edge-rails-batched-find)

### Conditions multiples pour les rappels

Lors de l'utilisation des rappels Active Record, vous pouvez maintenant combiner les options `:if` et `:unless` sur le même rappel, et fournir plusieurs conditions sous forme de tableau :

```ruby
before_save :update_credit_rating, :if => :active,
  :unless => [:admin, :cash_only]
```
* Contributeur principal : L. Caviola

### Recherche avec having

Rails dispose maintenant d'une option `:having` dans la recherche (ainsi que dans les associations `has_many` et `has_and_belongs_to_many`) pour filtrer les enregistrements dans les recherches groupées. Comme le savent ceux qui ont une solide expérience en SQL, cela permet de filtrer en fonction des résultats groupés :

```ruby
developers = Developer.find(:all, :group => "salary",
  :having => "sum(salary) > 10000", :select => "salary")
```

* Contributeur principal : [Emilio Tagua](https://github.com/miloops)

### Reconnexion des connexions MySQL

MySQL prend en charge un indicateur de reconnexion dans ses connexions - s'il est défini sur true, le client essaiera de se reconnecter au serveur avant de renoncer en cas de perte de connexion. Vous pouvez maintenant définir `reconnect = true` pour vos connexions MySQL dans `database.yml` pour obtenir ce comportement à partir d'une application Rails. La valeur par défaut est `false`, donc le comportement des applications existantes ne change pas.

* Contributeur principal : [Dov Murik](http://twitter.com/dubek)
* Plus d'informations :
    * [Contrôle du comportement de reconnexion automatique](http://dev.mysql.com/doc/refman/5.6/en/auto-reconnect.html)
    * [Réexamen de la reconnexion automatique de MySQL](http://groups.google.com/group/rubyonrails-core/browse_thread/thread/49d2a7e9c96cb9f4)

### Autres modifications d'Active Record

* Un `AS` supplémentaire a été supprimé du SQL généré pour le préchargement `has_and_belongs_to_many`, ce qui le rend plus efficace pour certaines bases de données.
* `ActiveRecord::Base#new_record?` renvoie maintenant `false` plutôt que `nil` lorsqu'il est confronté à un enregistrement existant.
* Un bug dans la citation des noms de table dans certaines associations `has_many :through` a été corrigé.
* Vous pouvez maintenant spécifier un horodatage particulier pour les horodatages `updated_at` : `cust = Customer.create(:name => "ABC Industries", :updated_at => 1.day.ago)`
* Meilleurs messages d'erreur en cas d'échec des appels `find_by_attribute!`.
* Le support `to_xml` d'Active Record devient un peu plus flexible avec l'ajout d'une option `:camelize`.
* Un bug dans l'annulation des rappels à partir de `before_update` ou `before_create` a été corrigé.
* Des tâches Rake pour tester les bases de données via JDBC ont été ajoutées.
* `validates_length_of` utilisera un message d'erreur personnalisé avec les options `:in` ou `:within` (si l'un est fourni).
* Les comptes sur les sélections filtrées fonctionnent maintenant correctement, vous pouvez donc faire des choses comme `Account.scoped(:select => "DISTINCT credit_limit").count`.
* `ActiveRecord::Base#invalid?` fonctionne maintenant comme l'opposé de `ActiveRecord::Base#valid?`.

Action Controller
-----------------

Action Controller apporte quelques changements importants à l'affichage, ainsi que des améliorations dans le routage et d'autres domaines, dans cette version.

### Rendu unifié

`ActionController::Base#render` est beaucoup plus intelligent pour décider quoi afficher. Maintenant, vous pouvez simplement lui dire quoi afficher et vous attendre à obtenir les bons résultats. Dans les anciennes versions de Rails, vous deviez souvent fournir des informations explicites pour le rendu :

```ruby
render :file => '/tmp/random_file.erb'
render :template => 'other_controller/action'
render :action => 'show'
```

Maintenant, dans Rails 2.3, vous pouvez simplement fournir ce que vous voulez afficher :

```ruby
render '/tmp/random_file.erb'
render 'other_controller/action'
render 'show'
render :show
```

Rails choisit entre le fichier, le modèle et l'action en fonction de la présence ou non d'un slash initial, d'un slash intégré ou d'aucun slash du tout dans ce qui doit être affiché. Notez que vous pouvez également utiliser un symbole au lieu d'une chaîne lors du rendu d'une action. Les autres styles de rendu (`:inline`, `:text`, `:update`, `:nothing`, `:json`, `:xml`, `:js`) nécessitent toujours une option explicite.

### Renommage du contrôleur d'application

Si vous êtes l'une des personnes qui a toujours été gênée par le nom spécial de `application.rb`, réjouissez-vous ! Il a été retravaillé pour devenir `application_controller.rb` dans Rails 2.3. De plus, il existe une nouvelle tâche Rake, `rake rails:update:application_controller`, pour le faire automatiquement pour vous - et elle sera exécutée dans le cadre du processus normal de `rake rails:update`.

* Plus d'informations :
    * [La mort de Application.rb](https://afreshcup.com/home/2008/11/17/rails-2x-the-death-of-applicationrb)
    * [Quoi de neuf dans Edge Rails : La dualité de Application.rb n'est plus](http://archives.ryandaigle.com/articles/2008/11/19/what-s-new-in-edge-rails-application-rb-duality-is-no-more)

### Prise en charge de l'authentification HTTP Digest

Rails dispose maintenant d'une prise en charge intégrée de l'authentification HTTP Digest. Pour l'utiliser, vous appelez `authenticate_or_request_with_http_digest` avec un bloc qui renvoie le mot de passe de l'utilisateur (qui est ensuite haché et comparé aux informations d'identification transmises) :

```ruby
class PostsController < ApplicationController
  Users = {"dhh" => "secret"}
  before_filter :authenticate

  def secret
    render :text => "Mot de passe requis !"
  end

  private
  def authenticate
    realm = "Application"
    authenticate_or_request_with_http_digest(realm) do |name|
      Users[name]
    end
  end
end
```
* Contributeur principal : [Gregg Kellogg](http://www.kellogg-assoc.com/)
* Plus d'informations : [Quoi de neuf dans Edge Rails : Authentification HTTP Digest](http://archives.ryandaigle.com/articles/2009/1/30/what-s-new-in-edge-rails-http-digest-authentication)

### Routage plus efficace

Il y a quelques changements importants dans le routage de Rails 2.3. Les helpers `formatted_` ont disparu, au profit de la simple option `:format`. Cela réduit de 50% le processus de génération des routes pour n'importe quelle ressource, et peut économiser une quantité substantielle de mémoire (jusqu'à 100 Mo sur les grandes applications). Si votre code utilise les helpers `formatted_`, cela fonctionnera toujours pour le moment, mais ce comportement est déprécié et votre application sera plus efficace si vous réécrivez ces routes en utilisant la nouvelle norme. Un autre grand changement est que Rails prend maintenant en charge plusieurs fichiers de routage, pas seulement `routes.rb`. Vous pouvez utiliser `RouteSet#add_configuration_file` pour ajouter plus de routes à tout moment, sans effacer les routes déjà chargées. Bien que ce changement soit le plus utile pour les moteurs, vous pouvez l'utiliser dans n'importe quelle application qui a besoin de charger des routes par lots.

* Contributeurs principaux : [Aaron Batalion](http://blog.hungrymachine.com/)

### Sessions chargées de manière paresseuse basées sur Rack

Un grand changement a poussé les fondements du stockage des sessions d'Action Controller au niveau de Rack. Cela a nécessité beaucoup de travail dans le code, bien que cela devrait être complètement transparent pour vos applications Rails (en bonus, certains correctifs désagréables autour de l'ancien gestionnaire de session CGI ont été supprimés). C'est toujours significatif, cependant, pour une raison simple : les applications Rack non-Rails ont accès aux mêmes gestionnaires de stockage de session (et donc à la même session) que vos applications Rails. De plus, les sessions sont maintenant chargées de manière paresseuse (en ligne avec les améliorations de chargement du reste du framework). Cela signifie que vous n'avez plus besoin de désactiver explicitement les sessions si vous ne les voulez pas ; il suffit de ne pas y faire référence et elles ne se chargeront pas.

### Changements dans la gestion des types MIME

Il y a quelques changements dans le code de gestion des types MIME dans Rails. Tout d'abord, `MIME::Type` implémente maintenant l'opérateur `=~`, ce qui rend les choses beaucoup plus propres lorsque vous devez vérifier la présence d'un type qui a des synonymes :

```ruby
if content_type && Mime::JS =~ content_type
  # faire quelque chose de cool
end

Mime::JS =~ "text/javascript"        => true
Mime::JS =~ "application/javascript" => true
```

L'autre changement est que le framework utilise maintenant `Mime::JS` lors de la vérification de JavaScript à différents endroits, ce qui permet de gérer ces alternatives de manière propre.

* Contributeur principal : [Seth Fitzsimmons](http://www.workingwithrails.com/person/5510-seth-fitzsimmons)

### Optimisation de `respond_to`

Dans les premiers fruits de la fusion de l'équipe Rails-Merb, Rails 2.3 inclut des optimisations pour la méthode `respond_to`, qui est bien sûr largement utilisée dans de nombreuses applications Rails pour permettre à votre contrôleur de formater les résultats différemment en fonction du type MIME de la requête entrante. Après avoir éliminé un appel à `method_missing` et après quelques profils et ajustements, nous constatons une amélioration de 8% du nombre de requêtes par seconde servies avec un simple `respond_to` qui bascule entre trois formats. Le meilleur ? Aucun changement requis dans le code de votre application pour profiter de cette accélération.

### Amélioration des performances de mise en cache

Rails conserve maintenant un cache local par requête des lectures effectuées à partir des magasins de cache distants, réduisant ainsi les lectures inutiles et améliorant les performances du site. Bien que ce travail était initialement limité à `MemCacheStore`, il est disponible pour tout magasin distant qui implémente les méthodes requises.

* Contributeur principal : [Nahum Wild](http://www.motionstandingstill.com/)

### Vues localisées

Rails peut maintenant fournir des vues localisées, en fonction de la locale que vous avez définie. Par exemple, supposons que vous ayez un contrôleur `Posts` avec une action `show`. Par défaut, cela rendra `app/views/posts/show.html.erb`. Mais si vous définissez `I18n.locale = :da`, cela rendra `app/views/posts/show.da.html.erb`. Si le modèle localisé n'est pas présent, la version non décorée sera utilisée. Rails inclut également `I18n#available_locales` et `I18n::SimpleBackend#available_locales`, qui renvoient un tableau des traductions disponibles dans le projet Rails actuel.

De plus, vous pouvez utiliser le même schéma pour localiser les fichiers de secours dans le répertoire public : `public/500.da.html` ou `public/404.en.html` fonctionnent, par exemple.

### Portée partielle pour les traductions

Un changement dans l'API de traduction facilite et réduit la répétition de l'écriture des traductions clés dans les partiels. Si vous appelez `translate(".foo")` depuis le modèle `people/index.html.erb`, vous appellerez en réalité `I18n.translate("people.index.foo")`. Si vous ne préfixez pas la clé avec un point, alors l'API ne fait pas de portée, comme avant.
### Autres modifications du contrôleur d'actions

* La gestion des ETag a été améliorée : Rails n'enverra plus d'en-tête ETag lorsque la réponse n'a pas de corps ou lors de l'envoi de fichiers avec `send_file`.
* Le fait que Rails vérifie les usurpations d'adresse IP peut être gênant pour les sites qui ont beaucoup de trafic avec des téléphones portables, car leurs proxies ne sont généralement pas configurés correctement. Si c'est votre cas, vous pouvez désactiver complètement la vérification en définissant `ActionController::Base.ip_spoofing_check = false`.
* `ActionController::Dispatcher` implémente maintenant sa propre pile de middleware, que vous pouvez voir en exécutant `rake middleware`.
* Les sessions de cookies ont maintenant des identifiants de session persistants, avec une compatibilité API avec les stores côté serveur.
* Vous pouvez maintenant utiliser des symboles pour l'option `:type` de `send_file` et `send_data`, comme ceci : `send_file("fabulous.png", :type => :png)`.
* Les options `:only` et `:except` pour `map.resources` ne sont plus héritées par les ressources imbriquées.
* Le client memcached inclus a été mis à jour en version 1.6.4.99.
* Les méthodes `expires_in`, `stale?` et `fresh_when` acceptent maintenant une option `:public` pour bien fonctionner avec la mise en cache par proxy.
* L'option `:requirements` fonctionne maintenant correctement avec les routes membres RESTful supplémentaires.
* Les routes peu profondes respectent maintenant correctement les espaces de noms.
* `polymorphic_url` gère mieux les objets avec des noms pluriels irréguliers.

Action View
-----------

Action View dans Rails 2.3 prend en charge les formulaires de modèles imbriqués, des améliorations de `render`, des invites plus flexibles pour les helpers de sélection de date, et une accélération de la mise en cache des ressources, entre autres choses.

### Formulaires d'objets imbriqués

Si le modèle parent accepte les attributs imbriqués pour les objets enfants (comme discuté dans la section Active Record), vous pouvez créer des formulaires imbriqués en utilisant `form_for` et `field_for`. Ces formulaires peuvent être imbriqués de manière arbitraire, ce qui vous permet de modifier des hiérarchies d'objets complexes sur une seule vue sans code excessif. Par exemple, avec ce modèle :

```ruby
class Customer < ActiveRecord::Base
  has_many :orders

  accepts_nested_attributes_for :orders, :allow_destroy => true
end
```

Vous pouvez écrire cette vue dans Rails 2.3 :

```html+erb
<% form_for @customer do |customer_form| %>
  <div>
    <%= customer_form.label :name, 'Nom du client :' %>
    <%= customer_form.text_field :name %>
  </div>

  <!-- Ici, nous appelons fields_for sur l'instance du builder customer_form.
   Le bloc est appelé pour chaque membre de la collection orders. -->
  <% customer_form.fields_for :orders do |order_form| %>
    <p>
      <div>
        <%= order_form.label :number, 'Numéro de commande :' %>
        <%= order_form.text_field :number %>
      </div>

  <!-- L'option allow_destroy dans le modèle permet de supprimer
   les enregistrements enfants. -->
      <% unless order_form.object.new_record? %>
        <div>
          <%= order_form.label :_delete, 'Supprimer :' %>
          <%= order_form.check_box :_delete %>
        </div>
      <% end %>
    </p>
  <% end %>

  <%= customer_form.submit %>
<% end %>
```

* Contributeur principal : [Eloy Duran](http://superalloy.nl/)
* Plus d'informations :
    * [Formulaires de modèles imbriqués](https://weblog.rubyonrails.org/2009/1/26/nested-model-forms)
    * [complex-form-examples](https://github.com/alloy/complex-form-examples)
    * [Quoi de neuf dans Edge Rails : Formulaires d'objets imbriqués](http://archives.ryandaigle.com/articles/2009/2/1/what-s-new-in-edge-rails-nested-attributes)

### Rendu intelligent des partiels

La méthode `render` est devenue de plus en plus intelligente au fil des ans, et elle l'est encore plus maintenant. Si vous avez un objet ou une collection et un partiel approprié, et que les noms correspondent, vous pouvez maintenant simplement rendre l'objet et les choses fonctionneront. Par exemple, dans Rails 2.3, ces appels à `render` fonctionneront dans votre vue (en supposant des noms sensés) :

```ruby
# Équivalent de render :partial => 'articles/_article',
# :object => @article
render @article

# Équivalent de render :partial => 'articles/_article',
# :collection => @articles
render @articles
```

* Plus d'informations : [Quoi de neuf dans Edge Rails : render cesse d'être difficile à gérer](http://archives.ryandaigle.com/articles/2008/11/20/what-s-new-in-edge-rails-render-stops-being-high-maintenance)

### Invites pour les helpers de sélection de date

Dans Rails 2.3, vous pouvez fournir des invites personnalisées pour les différents helpers de sélection de date (`date_select`, `time_select` et `datetime_select`), de la même manière que vous le feriez avec les helpers de sélection de collection. Vous pouvez fournir une chaîne d'invite ou un hash de chaînes d'invite individuelles pour les différents composants. Vous pouvez également simplement définir `:prompt` sur `true` pour utiliser l'invite générique personnalisée :

```ruby
select_datetime(DateTime.now, :prompt => true)

select_datetime(DateTime.now, :prompt => "Choisissez la date et l'heure")

select_datetime(DateTime.now, :prompt =>
  {:day => 'Choisissez le jour', :month => 'Choisissez le mois',
   :year => 'Choisissez l'année', :hour => 'Choisissez l'heure',
   :minute => 'Choisissez les minutes'})
```

* Contributeur principal : [Sam Oliver](http://samoliver.com/)

### Mise en cache des horodatages des ressources

Vous connaissez probablement la pratique de Rails qui consiste à ajouter des horodatages aux chemins des ressources statiques pour les "cache busters". Cela permet de s'assurer que les copies obsolètes d'éléments tels que les images et les feuilles de style ne sont pas servies à partir du cache du navigateur de l'utilisateur lorsque vous les modifiez sur le serveur. Vous pouvez maintenant modifier ce comportement avec l'option de configuration `cache_asset_timestamps` pour Action View. Si vous activez le cache, Rails calculera l'horodatage une fois lorsqu'il servira pour la première fois une ressource, et sauvegardera cette valeur. Cela signifie moins d'appels coûteux au système de fichiers pour servir les ressources statiques, mais cela signifie aussi que vous ne pouvez pas modifier les ressources pendant que le serveur est en cours d'exécution et vous attendre à ce que les modifications soient prises en compte par les clients.
### Hôtes d'actifs en tant qu'objets

Les hôtes d'actifs deviennent plus flexibles dans Edge Rails avec la possibilité de déclarer un hôte d'actifs en tant qu'objet spécifique qui répond à un appel. Cela vous permet de mettre en œuvre toute la logique complexe dont vous avez besoin dans votre hébergement d'actifs.

* Plus d'informations: [asset-hosting-with-minimum-ssl](https://github.com/dhh/asset-hosting-with-minimum-ssl/tree/master)

### Méthode d'aide grouped_options_for_select

Action View avait déjà un ensemble de méthodes d'aide pour faciliter la génération de contrôles de sélection, mais maintenant il y en a une de plus: `grouped_options_for_select`. Celle-ci accepte un tableau ou un hachage de chaînes, et les convertit en une chaîne de balises `option` enveloppées dans des balises `optgroup`. Par exemple:

```ruby
grouped_options_for_select([["Chapeaux", ["Casquette de baseball","Chapeau de cowboy"]]],
  "Chapeau de cowboy", "Choisissez un produit...")
```

retourne

```html
<option value="">Choisissez un produit...</option>
<optgroup label="Chapeaux">
  <option value="Casquette de baseball">Casquette de baseball</option>
  <option selected="selected" value="Chapeau de cowboy">Chapeau de cowboy</option>
</optgroup>
```

### Balises d'option désactivées pour les aides de sélection de formulaire

Les aides de sélection de formulaire (telles que `select` et `options_for_select`) prennent désormais en charge une option `:disabled`, qui peut prendre une seule valeur ou un tableau de valeurs à désactiver dans les balises résultantes:

```ruby
select(:post, :category, Post::CATEGORIES, :disabled => 'private')
```

retourne

```html
<select name="post[category]">
<option>histoire</option>
<option>blague</option>
<option>poème</option>
<option disabled="disabled">privé</option>
</select>
```

Vous pouvez également utiliser une fonction anonyme pour déterminer à l'exécution quelles options des collections seront sélectionnées et/ou désactivées:

```ruby
options_from_collection_for_select(@product.sizes, :name, :id, :disabled => lambda{|size| size.out_of_stock?})
```

* Contributeur principal: [Tekin Suleyman](http://tekin.co.uk/)
* Plus d'informations: [Nouveautés dans Rails 2.3 - balises d'option désactivées et lambdas pour sélectionner et désactiver des options à partir de collections](https://tekin.co.uk/2009/03/new-in-rails-23-disabled-option-tags-and-lambdas-for-selecting-and-disabling-options-from-collections)

### Une note sur le chargement des modèles

Rails 2.3 inclut la possibilité d'activer ou de désactiver les modèles mis en cache pour un environnement particulier. Les modèles mis en cache vous donnent un gain de vitesse car ils ne vérifient pas la présence d'un nouveau fichier de modèle lorsqu'ils sont rendus - mais cela signifie également que vous ne pouvez pas remplacer un modèle "en direct" sans redémarrer le serveur.

Dans la plupart des cas, vous voudrez que la mise en cache des modèles soit activée en production, ce que vous pouvez faire en définissant un paramètre dans votre fichier `production.rb`:

```ruby
config.action_view.cache_template_loading = true
```

Cette ligne sera générée par défaut dans une nouvelle application Rails 2.3. Si vous avez effectué une mise à niveau à partir d'une version plus ancienne de Rails, Rails mettra par défaut en cache les modèles en production et en test, mais pas en développement.

### Autres changements dans Action View

* La génération de jetons pour la protection CSRF a été simplifiée ; maintenant Rails utilise une simple chaîne aléatoire générée par `ActiveSupport::SecureRandom` plutôt que de manipuler les ID de session.
* `auto_link` applique maintenant correctement les options (telles que `:target` et `:class`) aux liens e-mail générés.
* L'aide `autolink` a été refactorisée pour la rendre un peu moins confuse et plus intuitive.
* `current_page?` fonctionne maintenant correctement même lorsqu'il y a plusieurs paramètres de requête dans l'URL.

Active Support
--------------

Active Support présente quelques changements intéressants, notamment l'introduction de `Object#try`.

### Object#try

Beaucoup de gens ont adopté l'idée d'utiliser `try()` pour tenter des opérations sur des objets. C'est particulièrement utile dans les vues où vous pouvez éviter les vérifications de nil en écrivant du code comme `<%= @person.try(:name) %>`. Eh bien, maintenant c'est intégré directement dans Rails. Tel qu'implémenté dans Rails, il génère une `NoMethodError` sur les méthodes privées et renvoie toujours `nil` si l'objet est nul.

* Plus d'informations: [try()](http://ozmm.org/posts/try.html)

### Object#tap Backport

`Object#tap` est une addition à [Ruby 1.9](http://www.ruby-doc.org/core-1.9/classes/Object.html#M000309) et 1.8.7 qui est similaire à la méthode `returning` que Rails a depuis un certain temps : elle exécute un bloc, puis renvoie l'objet qui a été exécuté. Rails inclut maintenant du code pour rendre cela disponible dans les anciennes versions de Ruby également.

### Parsers interchangeables pour XMLmini

Le support de l'analyse XML dans Active Support a été rendu plus flexible en vous permettant de remplacer les analyseurs. Par défaut, il utilise l'implémentation standard REXML, mais vous pouvez facilement spécifier les implémentations plus rapides LibXML ou Nokogiri pour vos propres applications, à condition d'avoir les gemmes appropriées installées :

```ruby
XmlMini.backend = 'LibXML'
```

* Contributeur principal: [Bart ten Brinke](http://www.movesonrails.com/)
* Contributeur principal: [Aaron Patterson](http://tenderlovemaking.com/)

### Secondes fractionnaires pour TimeWithZone

Les classes `Time` et `TimeWithZone` incluent une méthode `xmlschema` pour renvoyer l'heure sous forme de chaîne compatible XML. À partir de Rails 2.3, `TimeWithZone` prend en charge le même argument pour spécifier le nombre de chiffres dans la partie des secondes fractionnaires de la chaîne renvoyée que `Time` :

```ruby
Time.zone.now.xmlschema(6) # => "2009-01-16T13:00:06.13653Z"
```
* Contributeur principal : [Nicholas Dainty](http://www.workingwithrails.com/person/13536-nicholas-dainty)

### Citation des clés JSON

Si vous consultez la spécification sur le site "json.org", vous découvrirez que toutes les clés dans une structure JSON doivent être des chaînes de caractères et doivent être citées avec des guillemets doubles. À partir de Rails 2.3, nous faisons les choses correctement ici, même avec des clés numériques.

### Autres changements dans Active Support

* Vous pouvez utiliser `Enumerable#none?` pour vérifier que aucun des éléments ne correspond au bloc fourni.
* Si vous utilisez les [délégués](https://afreshcup.com/home/2008/10/19/coming-in-rails-22-delegate-prefixes) d'Active Support, la nouvelle option `:allow_nil` vous permet de renvoyer `nil` au lieu de lever une exception lorsque l'objet cible est nul.
* `ActiveSupport::OrderedHash` : implémente maintenant `each_key` et `each_value`.
* `ActiveSupport::MessageEncryptor` fournit un moyen simple de chiffrer des informations pour les stocker dans un emplacement non fiable (comme les cookies).
* La méthode `from_xml` d'Active Support ne dépend plus de XmlSimple. À la place, Rails inclut maintenant sa propre implémentation XmlMini, avec seulement les fonctionnalités dont il a besoin. Cela permet à Rails de se passer de la copie intégrée de XmlSimple qu'il transportait.
* Si vous mémorisez une méthode privée, le résultat sera maintenant privé.
* `String#parameterize` accepte un séparateur optionnel : `"Quick Brown Fox".parameterize('_') => "quick_brown_fox"`.
* `number_to_phone` accepte maintenant des numéros de téléphone à 7 chiffres.
* `ActiveSupport::Json.decode` gère maintenant les séquences d'échappement de style `\u0000`.

Railties
--------

En plus des changements de Rack mentionnés ci-dessus, Railties (le code central de Rails lui-même) présente un certain nombre de changements importants, notamment Rails Metal, les modèles d'application et les traces d'exécution silencieuses.

### Rails Metal

Rails Metal est un nouveau mécanisme qui permet de créer des points d'extrémité très rapides à l'intérieur de vos applications Rails. Les classes Metal contournent le routage et Action Controller pour vous offrir une vitesse brute (au détriment de toutes les fonctionnalités d'Action Controller, bien sûr). Cela s'appuie sur tout le travail de fondation récent pour faire de Rails une application Rack avec une pile de middleware exposée. Les points d'extrémité Metal peuvent être chargés à partir de votre application ou de plugins.

* Plus d'informations :
    * [Présentation de Rails Metal](https://weblog.rubyonrails.org/2008/12/17/introducing-rails-metal)
    * [Rails Metal : un micro-framework avec la puissance de Rails](http://soylentfoo.jnewland.com/articles/2008/12/16/rails-metal-a-micro-framework-with-the-power-of-rails-m)
    * [Metal : des points d'extrémité super rapides dans vos applications Rails](http://www.railsinside.com/deployment/180-metal-super-fast-endpoints-within-your-rails-apps.html)
    * [Quoi de neuf dans Edge Rails : Rails Metal](http://archives.ryandaigle.com/articles/2008/12/18/what-s-new-in-edge-rails-rails-metal)

### Modèles d'application

Rails 2.3 intègre le générateur d'applications [rg](https://github.com/jm/rg) de Jeremy McAnally. Cela signifie que nous avons maintenant une génération d'applications basée sur des modèles intégrée à Rails ; si vous avez un ensemble de plugins que vous incluez dans chaque application (parmi de nombreux autres cas d'utilisation), vous pouvez simplement configurer un modèle une fois et l'utiliser à chaque fois que vous exécutez la commande `rails`. Il existe également une tâche rake pour appliquer un modèle à une application existante :

```bash
$ rake rails:template LOCATION=~/template.rb
```

Cela appliquera les modifications du modèle par-dessus le code déjà présent dans le projet.

* Contributeur principal : [Jeremy McAnally](http://www.jeremymcanally.com/)
* Plus d'informations : [Modèles Rails](http://m.onkey.org/2008/12/4/rails-templates)

### Traces d'exécution silencieuses

En s'appuyant sur le plugin [Quiet Backtrace](https://github.com/thoughtbot/quietbacktrace) de thoughtbot, qui vous permet de supprimer sélectivement des lignes des traces d'exécution de `Test::Unit`, Rails 2.3 met en œuvre `ActiveSupport::BacktraceCleaner` et `Rails::BacktraceCleaner` dans le noyau. Cela prend en charge à la fois les filtres (pour effectuer des substitutions basées sur des expressions régulières sur les lignes de la trace d'exécution) et les silencieux (pour supprimer complètement les lignes de la trace d'exécution). Rails ajoute automatiquement des silencieux pour se débarrasser du bruit le plus courant dans une nouvelle application et crée un fichier `config/backtrace_silencers.rb` pour contenir vos propres ajouts. Cette fonctionnalité permet également une impression plus esthétique à partir de n'importe quelle gemme dans la trace d'exécution.

### Démarrage plus rapide en mode développement avec le chargement paresseux/automatique

Un travail considérable a été effectué pour s'assurer que les parties de Rails (et de ses dépendances) ne sont chargées en mémoire que lorsqu'elles sont réellement nécessaires. Les frameworks principaux - Active Support, Active Record, Action Controller, Action Mailer et Action View - utilisent maintenant `autoload` pour charger paresseusement leurs classes individuelles. Ce travail devrait contribuer à réduire l'empreinte mémoire et à améliorer les performances globales de Rails.

Vous pouvez également spécifier (en utilisant la nouvelle option `preload_frameworks`) si les bibliothèques principales doivent être chargées automatiquement au démarrage. Par défaut, cette option est définie sur `false` afin que Rails se charge pièce par pièce, mais il existe certaines circonstances où vous devez toujours tout charger en une seule fois - Passenger et JRuby veulent tous deux voir tout Rails chargé ensemble.

### Refonte de la tâche rake gem

Les mécanismes internes des différentes tâches <code>rake gem</code> ont été considérablement révisés pour améliorer le fonctionnement du système dans divers cas. Le système de gemmes sait maintenant faire la distinction entre les dépendances de développement et d'exécution, dispose d'un système de désarchivage plus robuste, fournit de meilleures informations lors de la recherche de l'état des gemmes et est moins sujet aux problèmes de dépendance "œuf et poule" lors de la mise en place de nouvelles choses. Des correctifs ont également été apportés pour utiliser les commandes gem sous JRuby et pour les dépendances qui tentent d'apporter des copies externes de gemmes déjà vendues.
* Contributeur principal : [David Dollar](http://www.workingwithrails.com/person/12240-david-dollar)

### Autres changements dans Railties

* Les instructions pour mettre à jour un serveur CI afin de construire Rails ont été mises à jour et élargies.
* Les tests internes de Rails ont été passés de `Test::Unit::TestCase` à `ActiveSupport::TestCase`, et le noyau de Rails nécessite Mocha pour les tests.
* Le fichier `environment.rb` par défaut a été débarrassé de son encombrement.
* Le script dbconsole vous permet désormais d'utiliser un mot de passe entièrement numérique sans planter.
* `Rails.root` renvoie maintenant un objet `Pathname`, ce qui signifie que vous pouvez l'utiliser directement avec la méthode `join` pour [nettoyer le code existant](https://afreshcup.wordpress.com/2008/12/05/a-little-rails_root-tidiness/) qui utilise `File.join`.
* Divers fichiers dans /public qui traitent de la distribution CGI et FCGI ne sont plus générés par défaut dans chaque application Rails (vous pouvez toujours les obtenir si vous en avez besoin en ajoutant `--with-dispatchers` lorsque vous exécutez la commande `rails`, ou les ajouter ultérieurement avec `rake rails:update:generate_dispatchers`).
* Les guides Rails ont été convertis du format AsciiDoc au format Textile.
* Les vues et les contrôleurs générés ont été légèrement nettoyés.
* `script/server` accepte maintenant un argument `--path` pour monter une application Rails à partir d'un chemin spécifique.
* Si des gemmes configurées sont manquantes, les tâches de rake des gemmes ignoreront le chargement d'une grande partie de l'environnement. Cela devrait résoudre bon nombre des problèmes de "poule et œuf" où rake gems:install ne pouvait pas s'exécuter car des gemmes manquaient.
* Les gemmes sont maintenant décompressées une seule fois. Cela résout les problèmes avec les gemmes (par exemple, hoe) qui sont empaquetées avec des permissions en lecture seule sur les fichiers.

Déprécié
---------

Quelques parties de code plus anciennes sont dépréciées dans cette version :

* Si vous êtes l'un des (assez rares) développeurs Rails qui déploie d'une manière qui dépend des scripts inspector, reaper et spawner, vous devez savoir que ces scripts ne sont plus inclus dans le noyau de Rails. Si vous en avez besoin, vous pourrez les récupérer via le plugin [irs_process_scripts](https://github.com/rails/irs_process_scripts).
* `render_component` passe de "déprécié" à "inexistant" dans Rails 2.3. Si vous en avez toujours besoin, vous pouvez installer le plugin [render_component](https://github.com/rails/render_component/tree/master).
* Le support des composants Rails a été supprimé.
* Si vous étiez l'une des personnes qui avaient l'habitude d'exécuter `script/performance/request` pour analyser les performances basées sur les tests d'intégration, vous devez apprendre une nouvelle astuce : ce script a été supprimé du noyau de Rails. Il existe un nouveau plugin request_profiler que vous pouvez installer pour retrouver exactement la même fonctionnalité.
* `ActionController::Base#session_enabled?` est déprécié car les sessions sont désormais chargées de manière paresseuse.
* Les options `:digest` et `:secret` de `protect_from_forgery` sont dépréciées et n'ont aucun effet.
* Certains assistants de test d'intégration ont été supprimés. `response.headers["Status"]` et `headers["Status"]` ne renverront plus rien. Rack n'autorise pas "Status" dans ses en-têtes de retour. Cependant, vous pouvez toujours utiliser les assistants `status` et `status_message`. `response.headers["cookie"]` et `headers["cookie"]` ne renverront plus aucun cookie CGI. Vous pouvez inspecter `headers["Set-Cookie"]` pour voir l'en-tête de cookie brut ou utiliser l'assistant `cookies` pour obtenir un tableau des cookies envoyés au client.
* `formatted_polymorphic_url` est déprécié. Utilisez `polymorphic_url` avec `:format` à la place.
* L'option `:http_only` dans `ActionController::Response#set_cookie` a été renommée en `:httponly`.
* Les options `:connector` et `:skip_last_comma` de `to_sentence` ont été remplacées par les options `:words_connector`, `:two_words_connector` et `:last_word_connector`.
* L'envoi d'un formulaire multipart avec un contrôle `file_field` vide soumettait auparavant une chaîne vide au contrôleur. Maintenant, il soumet un nul, en raison des différences entre l'analyseur multipart de Rack et l'ancien analyseur de Rails.

Crédits
-------

Notes de version compilées par [Mike Gunderloy](http://afreshcup.com). Cette version des notes de version de Rails 2.3 a été compilée à partir de la RC2 de Rails 2.3.
