**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 3529115f04b9d5fe01401105d9c154e2
Aperçu du contrôleur d'action
==============================

Dans ce guide, vous apprendrez comment fonctionnent les contrôleurs et comment ils s'intègrent dans le cycle de requête de votre application.

Après avoir lu ce guide, vous saurez comment :

* Suivre le flux d'une requête à travers un contrôleur.
* Restreindre les paramètres transmis à votre contrôleur.
* Stocker des données dans la session ou les cookies, et pourquoi.
* Travailler avec des filtres pour exécuter du code pendant le traitement de la requête.
* Utiliser l'authentification HTTP intégrée d'Action Controller.
* Diffuser des données directement vers le navigateur de l'utilisateur.
* Filtrer les paramètres sensibles pour qu'ils n'apparaissent pas dans le journal de l'application.
* Gérer les exceptions qui peuvent être levées pendant le traitement de la requête.
* Utiliser le point de contrôle de santé intégré pour les équilibreurs de charge et les moniteurs de disponibilité.

--------------------------------------------------------------------------------

Que fait un contrôleur ?
------------------------

Action Controller est le C dans [MVC](https://fr.wikipedia.org/wiki/Mod%C3%A8le-vue-contr%C3%B4leur). Après que le routeur a déterminé quel contrôleur utiliser pour une requête, le contrôleur est responsable de comprendre la requête et de produire la sortie appropriée. Heureusement, Action Controller fait la plupart du travail pour vous et utilise des conventions intelligentes pour rendre cela aussi simple que possible.

Pour la plupart des applications [RESTful](https://fr.wikipedia.org/wiki/Representational_state_transfer) conventionnelles, le contrôleur recevra la requête (ceci est invisible pour vous en tant que développeur), récupérera ou enregistrera des données à partir d'un modèle, et utilisera une vue pour créer une sortie HTML. Si votre contrôleur doit faire les choses un peu différemment, ce n'est pas un problème, c'est simplement la façon la plus courante pour un contrôleur de fonctionner.

On peut donc considérer un contrôleur comme un intermédiaire entre les modèles et les vues. Il rend les données du modèle disponibles à la vue, afin qu'elle puisse afficher ces données à l'utilisateur, et il enregistre ou met à jour les données utilisateur dans le modèle.

NOTE : Pour plus de détails sur le processus de routage, consultez [Rails Routing from the Outside In](routing.html).

Convention de nommage des contrôleurs
--------------------------------------

La convention de nommage des contrôleurs dans Rails favorise la plurielisation du dernier mot dans le nom du contrôleur, bien que cela ne soit pas strictement requis (par exemple, `ApplicationController`). Par exemple, `ClientsController` est préférable à `ClientController`, `SiteAdminsController` est préférable à `SiteAdminController` ou `SitesAdminsController`, et ainsi de suite.

Suivre cette convention vous permettra d'utiliser les générateurs de routes par défaut (par exemple, `resources`, etc.) sans avoir besoin de qualifier chaque `:path` ou `:controller`, et maintiendra une utilisation cohérente des aides de routes nommées dans votre application. Consultez [Layouts and Rendering Guide](layouts_and_rendering.html) pour plus de détails.

NOTE : La convention de nommage des contrôleurs diffère de la convention de nommage des modèles, qui doivent être nommés au singulier.

Méthodes et actions
-------------------

Un contrôleur est une classe Ruby qui hérite de `ApplicationController` et possède des méthodes comme n'importe quelle autre classe. Lorsque votre application reçoit une requête, le routage détermine quel contrôleur et quelle action exécuter, puis Rails crée une instance de ce contrôleur et exécute la méthode portant le même nom que l'action.

```ruby
class ClientsController < ApplicationController
  def new
  end
end
```

Par exemple, si un utilisateur se rend sur `/clients/new` dans votre application pour ajouter un nouveau client, Rails créera une instance de `ClientsController` et appellera sa méthode `new`. Notez que la méthode vide de l'exemple ci-dessus fonctionnerait très bien car Rails rendra par défaut la vue `new.html.erb` à moins que l'action ne dise le contraire. En créant un nouveau `Client`, la méthode `new` peut rendre accessible une variable d'instance `@client` dans la vue :

```ruby
def new
  @client = Client.new
end
```

Le [Guide des mises en page et du rendu](layouts_and_rendering.html) explique cela plus en détail.

`ApplicationController` hérite de [`ActionController::Base`][], qui définit un certain nombre de méthodes utiles. Ce guide en couvrira certaines, mais si vous êtes curieux de voir ce qu'il y a dedans, vous pouvez les voir toutes dans la [documentation de l'API](https://api.rubyonrails.org/classes/ActionController.html) ou dans le code source lui-même.

Seules les méthodes publiques peuvent être appelées en tant qu'actions. Il est préférable de réduire la visibilité des méthodes (avec `private` ou `protected`) qui ne sont pas destinées à être des actions, comme les méthodes auxiliaires ou les filtres.

AVERTISSEMENT : Certains noms de méthodes sont réservés par Action Controller. Redéfinir accidentellement ces noms en tant qu'actions, ou même en tant que méthodes auxiliaires, pourrait entraîner une `SystemStackError`. Si vous limitez vos contrôleurs aux seules actions de routage de ressources RESTful, vous ne devriez pas avoir à vous en préoccuper.

NOTE : Si vous devez utiliser un nom de méthode réservé en tant que nom d'action, une solution de contournement consiste à utiliser une route personnalisée pour mapper le nom de méthode réservé à votre méthode d'action non réservée.
[Routage des ressources]: routing.html#resource-routing-the-rails-default

Paramètres
----------

Vous voudrez probablement accéder aux données envoyées par l'utilisateur ou à d'autres paramètres dans vos actions de contrôleur. Il existe deux types de paramètres possibles dans une application web. Le premier type de paramètre est envoyé en tant que partie de l'URL, appelé paramètres de chaîne de requête. La chaîne de requête est tout ce qui se trouve après "?" dans l'URL. Le deuxième type de paramètre est généralement appelé données POST. Ces informations proviennent généralement d'un formulaire HTML rempli par l'utilisateur. C'est appelé données POST car elles ne peuvent être envoyées que dans le cadre d'une requête HTTP POST. Rails ne fait aucune distinction entre les paramètres de chaîne de requête et les paramètres POST, et les deux sont disponibles dans le hachage [`params`][] de votre contrôleur :

```ruby
class ClientsController < ApplicationController
  # Cette action utilise des paramètres de chaîne de requête car elle est exécutée
  # par une requête HTTP GET, mais cela ne fait aucune différence
  # pour la façon dont les paramètres sont accessibles. L'URL pour
  # cette action ressemblerait à ceci pour lister les clients activés : /clients?status=activated
  def index
    if params[:status] == "activated"
      @clients = Client.activated
    else
      @clients = Client.inactivated
    end
  end

  # Cette action utilise des paramètres POST. Ils proviennent très probablement
  # d'un formulaire HTML soumis par l'utilisateur. L'URL pour
  # cette requête RESTful sera "/clients", et les données seront
  # envoyées en tant que partie du corps de la requête.
  def create
    @client = Client.new(params[:client])
    if @client.save
      redirect_to @client
    else
      # Cette ligne remplace le comportement de rendu par défaut, qui
      # aurait été de rendre la vue "create".
      render "new"
    end
  end
end
```


### Paramètres de hachage et de tableau

Le hachage `params` n'est pas limité à des clés et des valeurs unidimensionnelles. Il peut contenir des tableaux et des hachages imbriqués. Pour envoyer un tableau de valeurs, ajoutez une paire de crochets vides "[]" au nom de la clé :

```
GET /clients?ids[]=1&ids[]=2&ids[]=3
```

NOTE : L'URL réelle dans cet exemple sera encodée en "/clients?ids%5b%5d=1&ids%5b%5d=2&ids%5b%5d=3" car les caractères "[" et "]" ne sont pas autorisés dans les URL. La plupart du temps, vous n'avez pas à vous en soucier car le navigateur l'encodera pour vous, et Rails le décodera automatiquement, mais si vous vous trouvez un jour à devoir envoyer ces requêtes manuellement au serveur, gardez cela à l'esprit.

La valeur de `params[:ids]` sera maintenant `["1", "2", "3"]`. Notez que les valeurs des paramètres sont toujours des chaînes de caractères ; Rails ne tente pas de deviner ou de convertir le type.

NOTE : Les valeurs telles que `[nil]` ou `[nil, nil, ...]` dans `params` sont remplacées
par `[]` par défaut pour des raisons de sécurité. Consultez le [Guide de sécurité](security.html#unsafe-query-generation)
pour plus d'informations.

Pour envoyer un hachage, vous incluez le nom de la clé entre crochets :

```html
<form accept-charset="UTF-8" action="/clients" method="post">
  <input type="text" name="client[name]" value="Acme" />
  <input type="text" name="client[phone]" value="12345" />
  <input type="text" name="client[address][postcode]" value="12345" />
  <input type="text" name="client[address][city]" value="Carrot City" />
</form>
```

Lorsque ce formulaire est soumis, la valeur de `params[:client]` sera `{ "name" => "Acme", "phone" => "12345", "address" => { "postcode" => "12345", "city" => "Carrot City" } }`. Notez le hachage imbriqué dans `params[:client][:address]`.

L'objet `params` agit comme un hachage, mais vous permet d'utiliser des symboles et des chaînes de caractères de manière interchangeable en tant que clés.

### Paramètres JSON

Si votre application expose une API, il est probable que vous acceptiez des paramètres au format JSON. Si l'en-tête "Content-Type" de votre requête est défini sur "application/json", Rails chargera automatiquement vos paramètres dans le hachage `params`, auquel vous pouvez accéder normalement.

Par exemple, si vous envoyez ce contenu JSON :

```json
{ "company": { "name": "acme", "address": "123 Carrot Street" } }
```

Votre contrôleur recevra `params[:company]` comme `{ "name" => "acme", "address" => "123 Carrot Street" }`.

De plus, si vous avez activé `config.wrap_parameters` dans votre fichier d'initialisation ou appelé [`wrap_parameters`][] dans votre contrôleur, vous pouvez omettre en toute sécurité l'élément racine dans le paramètre JSON. Dans ce cas, les paramètres seront clonés et enveloppés avec une clé choisie en fonction du nom de votre contrôleur. Ainsi, la requête JSON ci-dessus peut être écrite comme suit :

```json
{ "name": "acme", "address": "123 Carrot Street" }
```

Et, en supposant que vous envoyiez les données à `CompaniesController`, elles seront ensuite enveloppées dans la clé `:company` comme ceci :
```ruby
{ name: "acme", address: "123 Carrot Street", company: { name: "acme", address: "123 Carrot Street" } }
```

Vous pouvez personnaliser le nom de la clé ou les paramètres spécifiques que vous souhaitez envelopper en consultant la [documentation de l'API](https://api.rubyonrails.org/classes/ActionController/ParamsWrapper.html).

REMARQUE: La prise en charge de l'analyse des paramètres XML a été extraite dans une gemme appelée `actionpack-xml_parser`.


### Paramètres de routage

Le hash `params` contiendra toujours les clés `:controller` et `:action`, mais vous devriez utiliser les méthodes [`controller_name`][] et [`action_name`][] pour accéder à ces valeurs. Tous les autres paramètres définis par le routage, tels que `:id`, seront également disponibles. Par exemple, considérons une liste de clients où la liste peut afficher des clients actifs ou inactifs. Nous pouvons ajouter une route qui capture le paramètre `:status` dans une URL "jolie":

```ruby
get '/clients/:status', to: 'clients#index', foo: 'bar'
```

Dans ce cas, lorsque l'utilisateur ouvre l'URL `/clients/active`, `params[:status]` sera défini sur "active". Lorsque cette route est utilisée, `params[:foo]` sera également défini sur "bar", comme s'il était passé dans la chaîne de requête. Votre contrôleur recevra également `params[:action]` comme "index" et `params[:controller]` comme "clients".


### `default_url_options`

Vous pouvez définir des paramètres par défaut globaux pour la génération d'URL en définissant une méthode appelée `default_url_options` dans votre contrôleur. Une telle méthode doit renvoyer un hash avec les valeurs par défaut souhaitées, dont les clés doivent être des symboles:

```ruby
class ApplicationController < ActionController::Base
  def default_url_options
    { locale: I18n.locale }
  end
end
```

Ces options seront utilisées comme point de départ lors de la génération des URL, il est donc possible qu'elles soient remplacées par les options passées aux appels `url_for`.

Si vous définissez `default_url_options` dans `ApplicationController`, comme dans l'exemple ci-dessus, ces valeurs par défaut seront utilisées pour toutes les générations d'URL. La méthode peut également être définie dans un contrôleur spécifique, auquel cas elle n'affecte que les URL générées là-bas.

Dans une requête donnée, la méthode n'est pas réellement appelée pour chaque URL générée. Pour des raisons de performance, le hash retourné est mis en cache et il y a au plus une invocation par requête.

### Strong Parameters

Avec les strong parameters, les paramètres du contrôleur d'action sont interdits d'utilisation dans les affectations massives du modèle actif jusqu'à ce qu'ils aient été autorisés. Cela signifie que vous devrez prendre une décision consciente sur les attributs à autoriser pour la mise à jour en masse. C'est une meilleure pratique de sécurité pour éviter d'autoriser accidentellement les utilisateurs à mettre à jour des attributs sensibles du modèle.

De plus, les paramètres peuvent être marqués comme requis et passeront par un flux prédéfini de levée/capture qui entraînera le renvoi d'une erreur 400 Bad Request si tous les paramètres requis ne sont pas transmis.

```ruby
class PeopleController < ActionController::Base
  # Cela lèvera une exception ActiveModel::ForbiddenAttributesError
  # car il utilise une affectation massive sans autorisation explicite.
  def create
    Person.create(params[:person])
  end

  # Cela passera sans problème tant qu'il y a une clé person
  # dans les paramètres, sinon cela lèvera une exception
  # ActionController::ParameterMissing, qui sera capturée
  # par ActionController::Base et transformée en une erreur 400 Bad
  # Request.
  def update
    person = current_account.people.find(params[:id])
    person.update!(person_params)
    redirect_to person
  end

  private
    # Utiliser une méthode privée pour encapsuler les paramètres autorisés
    # est une bonne pratique car vous pourrez réutiliser la même
    # liste d'autorisations entre create et update. De plus, vous pouvez
    # spécialiser cette méthode avec une vérification par utilisateur des attributs autorisés.
    def person_params
      params.require(:person).permit(:name, :age)
    end
end
```

#### Valeurs scalaires autorisées

Appeler [`permit`][] comme ceci:

```ruby
params.permit(:id)
```

autorise la clé spécifiée (`:id`) à être incluse si elle apparaît dans `params` et
qu'elle a une valeur scalaire autorisée associée. Sinon, la clé sera filtrée, donc les tableaux, les hachages ou tout autre objet ne peuvent pas être injectés.

Les types scalaires autorisés sont `String`, `Symbol`, `NilClass`,
`Numeric`, `TrueClass`, `FalseClass`, `Date`, `Time`, `DateTime`,
`StringIO`, `IO`, `ActionDispatch::Http::UploadedFile` et
`Rack::Test::UploadedFile`.

Pour déclarer que la valeur dans `params` doit être un tableau de valeurs scalaires autorisées, mappez la clé sur un tableau vide:

```ruby
params.permit(id: [])
```

Parfois, il n'est pas possible ou pratique de déclarer les clés valides d'un paramètre de hachage ou de sa structure interne. Mappez simplement sur un hachage vide:

```ruby
params.permit(preferences: {})
```

mais faites attention car cela ouvre la porte à une entrée arbitraire. Dans ce
cas, `permit` garantit que les valeurs dans la structure retournée sont des scalaires autorisés et filtre tout le reste.
Pour permettre un hachage complet de paramètres, la méthode [`permit!`][] peut être utilisée :

```ruby
params.require(:log_entry).permit!
```

Cela marque le hachage de paramètres `:log_entry` et tout sous-hachage de celui-ci comme autorisé et ne vérifie pas les scalaires autorisés, tout est accepté. Une extrême prudence doit être exercée lors de l'utilisation de `permit!`, car cela permettra à tous les attributs de modèle actuels et futurs d'être massivement assignés.

#### Paramètres imbriqués

Vous pouvez également utiliser `permit` sur des paramètres imbriqués, comme :

```ruby
params.permit(:name, { emails: [] },
              friends: [ :name,
                         { family: [ :name ], hobbies: [] }])
```

Cette déclaration autorise les attributs `name`, `emails` et `friends`. Il est prévu que `emails` soit un tableau de valeurs scalaires autorisées, et que `friends` soit un tableau de ressources avec des attributs spécifiques : ils doivent avoir un attribut `name` (toutes les valeurs scalaires autorisées sont autorisées), un attribut `hobbies` en tant que tableau de valeurs scalaires autorisées, et un attribut `family` qui est limité à avoir un `name` (toutes les valeurs scalaires autorisées sont également autorisées ici).

#### Plus d'exemples

Vous voudrez peut-être également utiliser les attributs autorisés dans votre action `new`. Cela pose le problème que vous ne pouvez pas utiliser [`require`][] sur la clé racine car, normalement, elle n'existe pas lors de l'appel à `new` :

```ruby
# en utilisant `fetch`, vous pouvez fournir une valeur par défaut et utiliser
# l'API Strong Parameters à partir de là.
params.fetch(:blog, {}).permit(:title, :author)
```

La méthode de classe du modèle `accepts_nested_attributes_for` vous permet de mettre à jour et de détruire des enregistrements associés. Cela est basé sur les paramètres `id` et `_destroy` :

```ruby
# autoriser :id et :_destroy
params.require(:author).permit(:name, books_attributes: [:title, :id, :_destroy])
```

Les hachages avec des clés entières sont traités différemment, et vous pouvez déclarer les attributs comme s'ils étaient des enfants directs. Vous obtenez ce type de paramètres lorsque vous utilisez `accepts_nested_attributes_for` en combinaison avec une association `has_many` :

```ruby
# Pour autoriser les données suivantes :
# {"book" => {"title" => "Some Book",
#             "chapters_attributes" => { "1" => {"title" => "First Chapter"},
#                                        "2" => {"title" => "Second Chapter"}}}}

params.require(:book).permit(:title, chapters_attributes: [:title])
```

Imaginez un scénario où vous avez des paramètres représentant un nom de produit, et un hachage de données arbitraires associées à ce produit, et vous souhaitez autoriser l'attribut du nom du produit et également l'ensemble du hachage de données :

```ruby
def product_params
  params.require(:product).permit(:name, data: {})
end
```

#### En dehors du champ d'application des Strong Parameters

L'API des paramètres forts a été conçue en tenant compte des cas d'utilisation les plus courants. Elle n'est pas destinée à être une solution miracle pour résoudre tous vos problèmes de filtrage des paramètres. Cependant, vous pouvez facilement mélanger l'API avec votre propre code pour vous adapter à votre situation.

Session
-------

Votre application dispose d'une session pour chaque utilisateur dans laquelle vous pouvez stocker de petites quantités de données qui seront persistées entre les requêtes. La session n'est disponible que dans le contrôleur et la vue et peut utiliser l'un des plusieurs mécanismes de stockage différents :

* [`ActionDispatch::Session::CookieStore`][] - Stocke tout sur le client.
* [`ActionDispatch::Session::CacheStore`][] - Stocke les données dans le cache Rails.
* [`ActionDispatch::Session::MemCacheStore`][] - Stocke les données dans un cluster memcached (cette implémentation est obsolète ; envisagez d'utiliser `CacheStore` à la place).
* [`ActionDispatch::Session::ActiveRecordStore`][activerecord-session_store] -
  Stocke les données dans une base de données en utilisant Active Record (nécessite le
  gem [`activerecord-session_store`][activerecord-session_store])
* Un stockage personnalisé ou un stockage fourni par un gem tiers

Tous les magasins de session utilisent un cookie pour stocker un identifiant unique pour chaque session (vous devez utiliser un cookie, Rails ne vous permettra pas de passer l'ID de session dans l'URL car cela est moins sécurisé).

Pour la plupart des magasins, cet ID est utilisé pour rechercher les données de session sur le serveur, par exemple dans une table de base de données. Il y a une exception, qui est le magasin de session par défaut et recommandé - le CookieStore - qui stocke toutes les données de session dans le cookie lui-même (l'ID est toujours disponible si vous en avez besoin). Cela présente l'avantage d'être très léger et ne nécessite aucune configuration dans une nouvelle application pour utiliser la session. Les données du cookie sont cryptographiquement signées pour les rendre inviolables. Et elles sont également chiffrées, de sorte que toute personne qui y a accès ne peut pas lire son contenu (Rails ne l'acceptera pas s'il a été modifié).

Le CookieStore peut stocker environ 4 Ko de données - beaucoup moins que les autres - mais cela est généralement suffisant. Il est déconseillé de stocker de grandes quantités de données dans la session, quelle que soit la méthode de stockage de session utilisée par votre application. Vous devriez particulièrement éviter de stocker des objets complexes (comme des instances de modèle) dans la session, car le serveur pourrait ne pas être en mesure de les reconstituer entre les requêtes, ce qui entraînerait une erreur.
Si vos sessions utilisateur ne stockent pas de données critiques ou n'ont pas besoin d'être conservées pendant de longues périodes (par exemple, si vous utilisez simplement le flash pour la messagerie), vous pouvez envisager d'utiliser `ActionDispatch::Session::CacheStore`. Cela permettra de stocker les sessions en utilisant l'implémentation de cache que vous avez configurée pour votre application. L'avantage de cela est que vous pouvez utiliser votre infrastructure de cache existante pour stocker les sessions sans nécessiter de configuration ou d'administration supplémentaire. L'inconvénient, bien sûr, est que les sessions seront éphémères et pourraient disparaître à tout moment.

En savoir plus sur le stockage des sessions dans le [Guide de sécurité](security.html).

Si vous avez besoin d'un autre mécanisme de stockage des sessions, vous pouvez le modifier dans un initialiseur :

```ruby
Rails.application.config.session_store :cache_store
```

Consultez [`config.session_store`](configuring.html#config-session-store) dans le guide de configuration pour plus d'informations.

Rails configure une clé de session (le nom du cookie) lors de la signature des données de session. Celles-ci peuvent également être modifiées dans un initialiseur :

```ruby
# Assurez-vous de redémarrer votre serveur lorsque vous modifiez ce fichier.
Rails.application.config.session_store :cookie_store, key: '_your_app_session'
```

Vous pouvez également passer une clé `:domain` et spécifier le nom de domaine pour le cookie :

```ruby
# Assurez-vous de redémarrer votre serveur lorsque vous modifiez ce fichier.
Rails.application.config.session_store :cookie_store, key: '_your_app_session', domain: ".example.com"
```

Rails configure (pour le CookieStore) une clé secrète utilisée pour signer les données de session dans `config/credentials.yml.enc`. Cela peut être modifié avec `bin/rails credentials:edit`.

```yaml
# aws:
#   access_key_id: 123
#   secret_access_key: 345

# Utilisé comme secret de base pour tous les vérificateurs de messages dans Rails, y compris celui qui protège les cookies.
secret_key_base: 492f...
```

REMARQUE : Changer la secret_key_base lors de l'utilisation du `CookieStore` invalidera toutes les sessions existantes.



### Accéder à la session

Dans votre contrôleur, vous pouvez accéder à la session via la méthode d'instance `session`.

REMARQUE : Les sessions sont chargées de manière paresseuse. Si vous n'accédez pas aux sessions dans le code de votre action, elles ne seront pas chargées. Par conséquent, vous n'aurez jamais besoin de désactiver les sessions, il suffit de ne pas y accéder.

Les valeurs de session sont stockées à l'aide de paires clé/valeur comme un hash :

```ruby
class ApplicationController < ActionController::Base
  private
    # Trouve l'utilisateur avec l'ID stocké dans la session avec la clé
    # :current_user_id. C'est une façon courante de gérer la connexion de l'utilisateur dans
    # une application Rails ; la connexion définit la valeur de session et
    # la déconnexion la supprime.
    def current_user
      @_current_user ||= session[:current_user_id] &&
        User.find_by(id: session[:current_user_id])
    end
end
```

Pour stocker quelque chose dans la session, il suffit de l'assigner à la clé comme un hash :

```ruby
class LoginsController < ApplicationController
  # "Crée" une connexion, autrement dit "connecte l'utilisateur"
  def create
    if user = User.authenticate(params[:username], params[:password])
      # Enregistre l'ID de l'utilisateur dans la session pour qu'il puisse être utilisé dans
      # les requêtes suivantes
      session[:current_user_id] = user.id
      redirect_to root_url
    end
  end
end
```

Pour supprimer quelque chose de la session, supprimez la paire clé/valeur :

```ruby
class LoginsController < ApplicationController
  # "Supprime" une connexion, autrement dit "déconnecte l'utilisateur"
  def destroy
    # Supprime l'ID de l'utilisateur de la session
    session.delete(:current_user_id)
    # Efface l'utilisateur actuel mis en mémoire
    @_current_user = nil
    redirect_to root_url, status: :see_other
  end
end
```

Pour réinitialiser l'ensemble de la session, utilisez [`reset_session`][].


### Le Flash

Le flash est une partie spéciale de la session qui est effacée à chaque requête. Cela signifie que les valeurs stockées là-bas ne seront disponibles que dans la requête suivante, ce qui est utile pour transmettre des messages d'erreur, etc.

Le flash est accessible via la méthode [`flash`][]. Comme la session, le flash est représenté comme un hash.

Prenons l'exemple de la déconnexion. Le contrôleur peut envoyer un message qui sera affiché à l'utilisateur lors de la prochaine requête :

```ruby
class LoginsController < ApplicationController
  def destroy
    session.delete(:current_user_id)
    flash[:notice] = "Vous vous êtes déconnecté avec succès."
    redirect_to root_url, status: :see_other
  end
end
```

Notez qu'il est également possible d'assigner un message flash dans le cadre de la redirection. Vous pouvez assigner `:notice`, `:alert` ou le `:flash` polyvalent :

```ruby
redirect_to root_url, notice: "Vous vous êtes déconnecté avec succès."
redirect_to root_url, alert: "Vous êtes coincé ici !"
redirect_to root_url, flash: { referral_code: 1234 }
```

L'action `destroy` redirige vers l'`root_url` de l'application, où le message sera affiché. Notez que c'est entièrement à la prochaine action de décider ce qu'elle fera, le cas échéant, avec ce que l'action précédente a mis dans le flash. Il est courant d'afficher toutes les alertes ou notifications d'erreur du flash dans la mise en page de l'application :
```erb
<html>
  <!-- <head/> -->
  <body>
    <% flash.each do |name, msg| -%>
      <%= content_tag :div, msg, class: name %>
    <% end -%>

    <!-- more content -->
  </body>
</html>
```

De cette façon, si une action définit un message de notification ou d'alerte, la mise en page l'affichera automatiquement.

Vous pouvez transmettre n'importe quoi que la session peut stocker ; vous n'êtes pas limité aux notifications et alertes :

```erb
<% if flash[:just_signed_up] %>
  <p class="welcome">Bienvenue sur notre site !</p>
<% end %>
```

Si vous souhaitez qu'une valeur flash soit conservée pour une autre requête, utilisez [`flash.keep`][] :

```ruby
class MainController < ApplicationController
  # Disons que cette action correspond à root_url, mais vous voulez
  # que toutes les requêtes ici soient redirigées vers UsersController#index.
  # Si une action définit le flash et redirige ici, les valeurs
  # seraient normalement perdues lorsqu'une autre redirection se produit, mais vous
  # pouvez utiliser 'keep' pour le faire persister pour une autre requête.
  def index
    # Conservera toutes les valeurs flash.
    flash.keep

    # Vous pouvez également utiliser une clé pour ne conserver qu'un certain type de valeur.
    # flash.keep(:notice)
    redirect_to users_url
  end
end
```


#### `flash.now`

Par défaut, ajouter des valeurs au flash les rendra disponibles pour la prochaine requête, mais parfois vous voudrez accéder à ces valeurs dans la même requête. Par exemple, si l'action `create` échoue à enregistrer une ressource et que vous affichez directement le modèle `new`, cela ne donnera pas lieu à une nouvelle requête, mais vous voudrez peut-être quand même afficher un message à l'aide du flash. Pour ce faire, vous pouvez utiliser [`flash.now`][] de la même manière que vous utilisez le flash normal :

```ruby
class ClientsController < ApplicationController
  def create
    @client = Client.new(client_params)
    if @client.save
      # ...
    else
      flash.now[:error] = "Impossible d'enregistrer le client"
      render action: "new"
    end
  end
end
```


Cookies
-------

Votre application peut stocker de petites quantités de données sur le client - appelées cookies - qui seront persistantes entre les requêtes et même les sessions. Rails fournit un accès facile aux cookies via la méthode [`cookies`][], qui - tout comme la `session` - fonctionne comme un hash :

```ruby
class CommentsController < ApplicationController
  def new
    # Remplir automatiquement le nom du commentateur s'il a été stocké dans un cookie
    @comment = Comment.new(author: cookies[:commenter_name])
  end

  def create
    @comment = Comment.new(comment_params)
    if @comment.save
      flash[:notice] = "Merci pour votre commentaire !"
      if params[:remember_name]
        # Mémoriser le nom du commentateur.
        cookies[:commenter_name] = @comment.author
      else
        # Supprimer le cookie pour le nom du commentateur, s'il existe.
        cookies.delete(:commenter_name)
      end
      redirect_to @comment.article
    else
      render action: "new"
    end
  end
end
```

Notez que si pour les valeurs de session vous pouvez définir la clé sur `nil`, pour supprimer une valeur de cookie, vous devez utiliser `cookies.delete(:clé)`.

Rails fournit également un bocal à cookies signé et un bocal à cookies chiffré pour stocker
des données sensibles. Le bocal à cookies signé ajoute une signature cryptographique sur les
valeurs des cookies pour protéger leur intégrité. Le bocal à cookies chiffré chiffre les
valeurs en plus de les signer, de sorte qu'elles ne peuvent pas être lues par l'utilisateur final.
Consultez la [documentation de l'API](https://api.rubyonrails.org/classes/ActionDispatch/Cookies.html)
pour plus de détails.

Ces bocaux à cookies spéciaux utilisent un sérialiseur pour sérialiser les valeurs attribuées en
chaînes de caractères et les désérialiser en objets Ruby lors de la lecture. Vous pouvez spécifier
le sérialiseur à utiliser via [`config.action_dispatch.cookies_serializer`][].

Le sérialiseur par défaut pour les nouvelles applications est `:json`. Notez que JSON a
un support limité pour les objets Ruby. Par exemple, les objets `Date`, `Time` et
`Symbol` (y compris les clés `Hash`) seront sérialisés et désérialisés
en `String`s :

```ruby
class CookiesController < ApplicationController
  def set_cookie
    cookies.encrypted[:expiration_date] = Date.tomorrow # => Thu, 20 Mar 2014
    redirect_to action: 'read_cookie'
  end

  def read_cookie
    cookies.encrypted[:expiration_date] # => "2014-03-20"
  end
end
```

Si vous avez besoin de stocker ces objets ou des objets plus complexes, vous devrez peut-être
convertir manuellement leurs valeurs lors de leur lecture dans les requêtes suivantes.

Si vous utilisez le stockage des sessions par cookies, ce qui précède s'applique également au hash `session`
et au hash `flash`.


Rendu
---------

ActionController facilite le rendu de données HTML, XML ou JSON. Si vous avez généré un contrôleur en utilisant le générateur de squelette, il ressemblerait à ceci :

```ruby
class UsersController < ApplicationController
  def index
    @users = User.all
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render xml: @users }
      format.json { render json: @users }
    end
  end
end
```

Vous pouvez remarquer dans le code ci-dessus que nous utilisons `render xml: @users`, pas `render xml: @users.to_xml`. Si l'objet n'est pas une chaîne de caractères, Rails invoquera automatiquement `to_xml` pour nous.
Vous pouvez en savoir plus sur le rendu dans le [Guide des mises en page et du rendu](layouts_and_rendering.html).

Filtres
-------

Les filtres sont des méthodes qui sont exécutées "avant", "après" ou "autour" d'une action du contrôleur.

Les filtres sont hérités, donc si vous définissez un filtre sur `ApplicationController`, il sera exécuté sur chaque contrôleur de votre application.

Les filtres "avant" sont enregistrés via [`before_action`][]. Ils peuvent interrompre le cycle de la requête. Un filtre "avant" courant est celui qui nécessite qu'un utilisateur soit connecté pour qu'une action soit exécutée. Vous pouvez définir la méthode de filtre de cette manière :

```ruby
class ApplicationController < ActionController::Base
  before_action :require_login

  private
    def require_login
      unless logged_in?
        flash[:error] = "Vous devez être connecté pour accéder à cette section"
        redirect_to new_login_url # interrompt le cycle de la requête
      end
    end
end
```

La méthode stocke simplement un message d'erreur dans le flash et redirige vers le formulaire de connexion si l'utilisateur n'est pas connecté. Si un filtre "avant" rend ou redirige, l'action ne sera pas exécutée. Si d'autres filtres sont programmés pour s'exécuter après ce filtre, ils sont également annulés.

Dans cet exemple, le filtre est ajouté à `ApplicationController` et donc tous les contrôleurs de l'application l'héritent. Cela rendra nécessaire la connexion de l'utilisateur pour utiliser tout dans l'application. Pour des raisons évidentes (l'utilisateur ne pourrait pas se connecter en premier lieu !), tous les contrôleurs ou actions ne devraient pas nécessiter cela. Vous pouvez empêcher ce filtre de s'exécuter avant des actions particulières avec [`skip_before_action`][] :

```ruby
class LoginsController < ApplicationController
  skip_before_action :require_login, only: [:new, :create]
end
```

Maintenant, les actions `new` et `create` de `LoginsController` fonctionneront comme avant sans nécessiter que l'utilisateur soit connecté. L'option `:only` est utilisée pour ignorer ce filtre uniquement pour ces actions, et il y a aussi une option `:except` qui fonctionne dans l'autre sens. Ces options peuvent également être utilisées lors de l'ajout de filtres, vous pouvez donc ajouter un filtre qui ne s'exécute que pour des actions sélectionnées en premier lieu.

NOTE : Appeler le même filtre plusieurs fois avec différentes options ne fonctionnera pas, car la dernière définition de filtre écrasera les précédentes.


### Filtres après et autour

En plus des filtres "avant", vous pouvez également exécuter des filtres après l'exécution d'une action, ou à la fois avant et après.

Les filtres "après" sont enregistrés via [`after_action`][]. Ils sont similaires aux filtres "avant", mais parce que l'action a déjà été exécutée, ils ont accès aux données de réponse qui vont être envoyées au client. Évidemment, les filtres "après" ne peuvent pas empêcher l'action de s'exécuter. Veuillez noter que les filtres "après" ne sont exécutés qu'après une action réussie, mais pas lorsqu'une exception est levée dans le cycle de la requête.

Les filtres "autour" sont enregistrés via [`around_action`][]. Ils sont responsables de l'exécution de leurs actions associées en utilisant le mécanisme de yield, similaire au fonctionnement des middlewares Rack.

Par exemple, dans un site web où les modifications ont un flux de validation, un administrateur pourrait les prévisualiser facilement en les appliquant dans une transaction :

```ruby
class ChangesController < ApplicationController
  around_action :wrap_in_transaction, only: :show

  private
    def wrap_in_transaction
      ActiveRecord::Base.transaction do
        begin
          yield
        ensure
          raise ActiveRecord::Rollback
        end
      end
    end
end
```

Notez qu'un filtre "autour" enveloppe également le rendu. En particulier, dans l'exemple ci-dessus, si la vue elle-même lit depuis la base de données (par exemple via une portée), elle le fera dans la transaction et présentera donc les données à prévisualiser.

Vous pouvez choisir de ne pas utiliser yield et de construire la réponse vous-même, auquel cas l'action ne sera pas exécutée.


### Autres façons d'utiliser les filtres

Bien que la façon la plus courante d'utiliser les filtres soit de créer des méthodes privées et d'utiliser `before_action`, `after_action` ou `around_action` pour les ajouter, il existe deux autres façons de faire la même chose.

La première consiste à utiliser directement un bloc avec les méthodes `*_action`. Le bloc reçoit le contrôleur en argument. Le filtre `require_login` ci-dessus pourrait être réécrit pour utiliser un bloc :

```ruby
class ApplicationController < ActionController::Base
  before_action do |controller|
    unless controller.send(:logged_in?)
      flash[:error] = "Vous devez être connecté pour accéder à cette section"
      redirect_to new_login_url
    end
  end
end
```

Notez que le filtre, dans ce cas, utilise `send` car la méthode `logged_in?` est privée, et le filtre ne s'exécute pas dans le contexte du contrôleur. Ce n'est pas la façon recommandée de mettre en œuvre ce filtre particulier, mais dans des cas plus simples, cela peut être utile.
Spécifiquement pour `around_action`, le bloc renvoie également dans l'action :

```ruby
around_action { |_controller, action| time(&action) }
```

La deuxième façon est d'utiliser une classe (en fait, n'importe quel objet qui réponde aux bonnes méthodes fera l'affaire) pour gérer le filtrage. Cela est utile dans les cas plus complexes et ne peut pas être implémenté de manière lisible et réutilisable en utilisant les deux autres méthodes. Par exemple, vous pourriez réécrire le filtre de connexion pour utiliser une classe :

```ruby
class ApplicationController < ActionController::Base
  before_action LoginFilter
end

class LoginFilter
  def self.before(controller)
    unless controller.send(:logged_in?)
      controller.flash[:error] = "Vous devez être connecté pour accéder à cette section"
      controller.redirect_to controller.new_login_url
    end
  end
end
```

Encore une fois, ce n'est pas un exemple idéal pour ce filtre, car il n'est pas exécuté dans le contexte du contrôleur mais reçoit le contrôleur en argument. La classe de filtre doit implémenter une méthode portant le même nom que le filtre, donc pour le filtre `before_action`, la classe doit implémenter une méthode `before`, et ainsi de suite. La méthode `around` doit `yield` pour exécuter l'action.

Protection contre les attaques de falsification de requêtes
-----------------------------------------------------------

La falsification de requêtes entre sites est un type d'attaque dans lequel un site trompe un utilisateur pour qu'il effectue des requêtes sur un autre site, ajoutant, modifiant ou supprimant éventuellement des données sur ce site sans la connaissance ou la permission de l'utilisateur.

La première étape pour éviter cela est de s'assurer que toutes les actions "destructrices" (création, mise à jour et suppression) ne peuvent être accessibles qu'avec des requêtes non-GET. Si vous suivez les conventions RESTful, vous le faites déjà. Cependant, un site malveillant peut toujours envoyer une requête non-GET à votre site assez facilement, et c'est là que la protection contre la falsification de requêtes intervient. Comme son nom l'indique, elle protège contre les requêtes falsifiées.

La façon dont cela est fait est d'ajouter un jeton non devinable, connu uniquement de votre serveur, à chaque requête. Ainsi, si une requête arrive sans le jeton approprié, l'accès sera refusé.

Si vous générez un formulaire comme ceci :

```erb
<%= form_with model: @user do |form| %>
  <%= form.text_field :username %>
  <%= form.text_field :password %>
<% end %>
```

Vous verrez comment le jeton est ajouté en tant que champ caché :

```html
<form accept-charset="UTF-8" action="/users/1" method="post">
<input type="hidden"
       value="67250ab105eb5ad10851c00a5621854a23af5489"
       name="authenticity_token"/>
<!-- fields -->
</form>
```

Rails ajoute ce jeton à chaque formulaire généré à l'aide des [helpers de formulaire](form_helpers.html), donc la plupart du temps, vous n'avez pas à vous en soucier. Si vous écrivez un formulaire manuellement ou devez ajouter le jeton pour une autre raison, il est disponible via la méthode `form_authenticity_token` :

La méthode `form_authenticity_token` génère un jeton d'authentification valide. C'est utile dans les endroits où Rails ne l'ajoute pas automatiquement, comme dans les appels Ajax personnalisés.

Le [Guide de sécurité](security.html) en dit plus à ce sujet, ainsi que sur de nombreux autres problèmes liés à la sécurité auxquels vous devez être attentif lors du développement d'une application web.

Les objets de requête et de réponse
----------------------------------

Dans chaque contrôleur, il existe deux méthodes d'accès pointant vers les objets de requête et de réponse associés au cycle de requête en cours d'exécution. La méthode [`request`][] contient une instance de [`ActionDispatch::Request`][] et la méthode [`response`][] renvoie un objet de réponse représentant ce qui va être renvoyé au client.


### L'objet `request`

L'objet de requête contient de nombreuses informations utiles sur la requête provenant du client. Pour obtenir une liste complète des méthodes disponibles, consultez la [documentation de l'API Rails](https://api.rubyonrails.org/classes/ActionDispatch/Request.html) et la [documentation de Rack](https://www.rubydoc.info/github/rack/rack/Rack/Request). Parmi les propriétés auxquelles vous pouvez accéder sur cet objet, on trouve :

| Propriété de `request`                     | Objectif                                                                          |
| ----------------------------------------- | -------------------------------------------------------------------------------- |
| `host`                                    | Le nom d'hôte utilisé pour cette requête.                                              |
| `domain(n=2)`                             | Les `n` premiers segments du nom d'hôte, en commençant par la droite (le TLD).            |
| `format`                                  | Le type de contenu demandé par le client.                                        |
| `method`                                  | La méthode HTTP utilisée pour la requête.                                            |
| `get?`, `post?`, `patch?`, `put?`, `delete?`, `head?` | Renvoie true si la méthode HTTP est GET/POST/PATCH/PUT/DELETE/HEAD.   |
| `headers`                                 | Renvoie un hash contenant les en-têtes associés à la requête.               |
| `port`                                    | Le numéro de port (entier) utilisé pour la requête.                                  |
| `protocol`                                | Renvoie une chaîne contenant le protocole utilisé plus "://", par exemple "http://". |
| `query_string`                            | La partie de la chaîne de requête de l'URL, c'est-à-dire tout ce qui se trouve après "?".                    |
| `remote_ip`                               | L'adresse IP du client.                                                    |
| `url`                                     | L'URL complète utilisée pour la requête.                                             |
#### `path_parameters`, `query_parameters` et `request_parameters`

Rails collecte tous les paramètres envoyés avec la requête dans le hash `params`, qu'ils soient envoyés en tant que partie de la chaîne de requête ou du corps de la requête. L'objet de requête dispose de trois accesseurs qui vous donnent accès à ces paramètres en fonction de leur provenance. Le hash [`query_parameters`][] contient les paramètres qui ont été envoyés en tant que partie de la chaîne de requête, tandis que le hash [`request_parameters`][] contient les paramètres envoyés en tant que partie du corps de la requête. Le hash [`path_parameters`][] contient les paramètres qui ont été reconnus par le routage comme faisant partie du chemin menant à ce contrôleur et à cette action particuliers.


### L'objet `response`

L'objet de réponse n'est généralement pas utilisé directement, mais il est construit pendant l'exécution de l'action et le rendu des données qui sont renvoyées à l'utilisateur. Cependant, parfois - comme dans un filtre après - il peut être utile d'accéder directement à la réponse. Certains de ces méthodes d'accès ont également des setters, ce qui vous permet de modifier leurs valeurs. Pour obtenir une liste complète des méthodes disponibles, consultez la [documentation de l'API Rails](https://api.rubyonrails.org/classes/ActionDispatch/Response.html) et la [documentation de Rack](https://www.rubydoc.info/github/rack/rack/Rack/Response).

| Propriété de `response` | Objectif                                                                                             |
| ---------------------- | --------------------------------------------------------------------------------------------------- |
| `body`                 | Il s'agit de la chaîne de données renvoyée au client. Il s'agit le plus souvent de HTML.             |
| `status`               | Le code d'état HTTP de la réponse, comme 200 pour une requête réussie ou 404 pour un fichier non trouvé. |
| `location`             | L'URL vers laquelle le client est redirigé, le cas échéant.                                          |
| `content_type`         | Le type de contenu de la réponse.                                                                   |
| `charset`              | L'encodage de caractères utilisé pour la réponse. Par défaut, il s'agit de "utf-8".                                  |
| `headers`              | Les en-têtes utilisés pour la réponse.                                                                      |

#### Définition d'en-têtes personnalisés

Si vous souhaitez définir des en-têtes personnalisés pour une réponse, vous pouvez le faire en utilisant `response.headers`. L'attribut `headers` est un hash qui fait correspondre les noms des en-têtes à leurs valeurs, et Rails en définira certains automatiquement. Si vous souhaitez ajouter ou modifier un en-tête, il vous suffit de l'assigner à `response.headers` de cette manière :

```ruby
response.headers["Content-Type"] = "application/pdf"
```

NOTE : Dans le cas ci-dessus, il serait plus logique d'utiliser directement le setter `content_type`.

Authentifications HTTP
--------------------

Rails est livré avec trois mécanismes d'authentification HTTP intégrés :

* Authentification de base
* Authentification digest
* Authentification par jeton

### Authentification de base HTTP

L'authentification de base HTTP est un schéma d'authentification pris en charge par la majorité des navigateurs et autres clients HTTP. Par exemple, considérez une section d'administration qui ne sera accessible qu'en entrant un nom d'utilisateur et un mot de passe dans la fenêtre de dialogue HTTP de votre navigateur. L'utilisation de l'authentification intégrée ne nécessite l'utilisation que d'une seule méthode, [`http_basic_authenticate_with`][].

```ruby
class AdminsController < ApplicationController
  http_basic_authenticate_with name: "humbaba", password: "5baa61e4"
end
```

Avec cela en place, vous pouvez créer des contrôleurs dans un espace de noms qui héritent de `AdminsController`. Le filtre sera donc exécuté pour toutes les actions de ces contrôleurs, les protégeant par une authentification de base HTTP.


### Authentification digest HTTP

L'authentification digest HTTP est supérieure à l'authentification de base car elle ne nécessite pas que le client envoie un mot de passe non chiffré via le réseau (bien que l'authentification de base HTTP soit sécurisée via HTTPS). L'utilisation de l'authentification digest avec Rails ne nécessite que l'utilisation d'une seule méthode, [`authenticate_or_request_with_http_digest`][].

```ruby
class AdminsController < ApplicationController
  USERS = { "lifo" => "world" }

  before_action :authenticate

  private
    def authenticate
      authenticate_or_request_with_http_digest do |username|
        USERS[username]
      end
    end
end
```

Comme on peut le voir dans l'exemple ci-dessus, le bloc `authenticate_or_request_with_http_digest` ne prend qu'un seul argument - le nom d'utilisateur. Et le bloc renvoie le mot de passe. Le fait de renvoyer `false` ou `nil` à partir de `authenticate_or_request_with_http_digest` entraînera un échec de l'authentification.


### Authentification par jeton HTTP

L'authentification par jeton HTTP est un schéma qui permet d'utiliser des jetons d'accès dans l'en-tête HTTP `Authorization`. Il existe de nombreux formats de jetons disponibles, mais leur description dépasse le cadre de ce document.

Par exemple, supposons que vous souhaitiez utiliser un jeton d'authentification qui a été préalablement émis pour effectuer une authentification et un accès. La mise en œuvre de l'authentification par jeton avec Rails ne nécessite que l'utilisation d'une seule méthode, [`authenticate_or_request_with_http_token`][].

```ruby
class PostsController < ApplicationController
  TOKEN = "secret"

  before_action :authenticate

  private
    def authenticate
      authenticate_or_request_with_http_token do |token, options|
        ActiveSupport::SecurityUtils.secure_compare(token, TOKEN)
      end
    end
end
```

Comme on peut le voir dans l'exemple ci-dessus, le bloc `authenticate_or_request_with_http_token` prend deux arguments - le jeton et un `Hash` contenant les options qui ont été analysées à partir de l'en-tête HTTP `Authorization`. Le bloc doit renvoyer `true` si l'authentification est réussie. Le fait de renvoyer `false` ou `nil` entraînera un échec de l'authentification.
Streaming et téléchargement de fichiers
----------------------------

Parfois, vous voudrez envoyer un fichier à l'utilisateur au lieu de rendre une page HTML. Tous les contrôleurs de Rails ont les méthodes [`send_data`][] et [`send_file`][], qui permettent toutes deux de diffuser des données vers le client. `send_file` est une méthode pratique qui vous permet de fournir le nom d'un fichier sur le disque, et il diffusera le contenu de ce fichier pour vous.

Pour diffuser des données vers le client, utilisez `send_data` :

```ruby
require "prawn"
class ClientsController < ApplicationController
  # Génère un document PDF avec des informations sur le client et le renvoie. L'utilisateur recevra le PDF en téléchargement de fichier.
  def download_pdf
    client = Client.find(params[:id])
    send_data generate_pdf(client),
              filename: "#{client.name}.pdf",
              type: "application/pdf"
  end

  private
    def generate_pdf(client)
      Prawn::Document.new do
        text client.name, align: :center
        text "Adresse : #{client.address}"
        text "Email : #{client.email}"
      end.render
    end
end
```

L'action `download_pdf` dans l'exemple ci-dessus appellera une méthode privée qui génère réellement le document PDF et le renvoie sous forme de chaîne de caractères. Cette chaîne sera ensuite diffusée vers le client en tant que téléchargement de fichier, et un nom de fichier sera suggéré à l'utilisateur. Parfois, lors de la diffusion de fichiers à l'utilisateur, vous ne voulez peut-être pas qu'il télécharge le fichier. Prenez par exemple les images, qui peuvent être intégrées dans des pages HTML. Pour indiquer au navigateur qu'un fichier n'est pas destiné à être téléchargé, vous pouvez définir l'option `:disposition` sur "inline". La valeur opposée et par défaut de cette option est "attachment".


### Envoi de fichiers

Si vous souhaitez envoyer un fichier qui existe déjà sur le disque, utilisez la méthode `send_file`.

```ruby
class ClientsController < ApplicationController
  # Diffuse un fichier qui a déjà été généré et stocké sur le disque.
  def download_pdf
    client = Client.find(params[:id])
    send_file("#{Rails.root}/files/clients/#{client.id}.pdf",
              filename: "#{client.name}.pdf",
              type: "application/pdf")
  end
end
```

Cela lira et diffusera le fichier 4 Ko à la fois, évitant de charger le fichier entier en mémoire d'un coup. Vous pouvez désactiver la diffusion en utilisant l'option `:stream` ou ajuster la taille du bloc avec l'option `:buffer_size`.

Si `:type` n'est pas spécifié, il sera deviné à partir de l'extension de fichier spécifiée dans `:filename`. Si le type de contenu n'est pas enregistré pour l'extension, `application/octet-stream` sera utilisé.

AVERTISSEMENT : Faites attention lorsque vous utilisez des données provenant du client (params, cookies, etc.) pour localiser le fichier sur le disque, car cela représente un risque de sécurité qui pourrait permettre à quelqu'un d'accéder à des fichiers auxquels il n'est pas destiné.

CONSEIL : Il n'est pas recommandé de diffuser des fichiers statiques via Rails si vous pouvez les conserver dans un dossier public sur votre serveur web. Il est beaucoup plus efficace de laisser l'utilisateur télécharger le fichier directement à l'aide d'Apache ou d'un autre serveur web, en évitant ainsi que la requête ne passe inutilement par l'ensemble de la pile Rails.

### Téléchargements RESTful

Bien que `send_data` fonctionne très bien, si vous créez une application RESTful, il n'est généralement pas nécessaire d'avoir des actions distinctes pour les téléchargements de fichiers. Dans la terminologie REST, le fichier PDF de l'exemple ci-dessus peut être considéré comme une autre représentation de la ressource client. Rails propose une façon élégante de réaliser des téléchargements "RESTful". Voici comment vous pouvez réécrire l'exemple pour que le téléchargement PDF fasse partie de l'action `show`, sans diffusion :

```ruby
class ClientsController < ApplicationController
  # L'utilisateur peut demander à recevoir cette ressource en HTML ou en PDF.
  def show
    @client = Client.find(params[:id])

    respond_to do |format|
      format.html
      format.pdf { render pdf: generate_pdf(@client) }
    end
  end
end
```

Pour que cet exemple fonctionne, vous devez ajouter le type MIME PDF à Rails. Cela peut être fait en ajoutant la ligne suivante au fichier `config/initializers/mime_types.rb` :

```ruby
Mime::Type.register "application/pdf", :pdf
```

REMARQUE : Les fichiers de configuration ne sont pas rechargés à chaque requête, vous devez donc redémarrer le serveur pour que les modifications prennent effet.

Maintenant, l'utilisateur peut demander une version PDF d'un client simplement en ajoutant ".pdf" à l'URL :

```
GET /clients/1.pdf
```

### Diffusion en direct de données arbitraires

Rails vous permet de diffuser plus que des fichiers. En fait, vous pouvez diffuser n'importe quoi
que vous souhaitez dans un objet de réponse. Le module [`ActionController::Live`][] vous permet
de créer une connexion persistante avec un navigateur. En utilisant ce module, vous pourrez
envoyer des données arbitraires au navigateur à des moments spécifiques.
#### Intégration du streaming en direct

En incluant `ActionController::Live` à l'intérieur de votre classe de contrôleur, toutes les actions à l'intérieur du contrôleur auront la capacité de diffuser des données. Vous pouvez mélanger le module de la manière suivante :

```ruby
class MyController < ActionController::Base
  include ActionController::Live

  def stream
    response.headers['Content-Type'] = 'text/event-stream'
    100.times {
      response.stream.write "hello world\n"
      sleep 1
    }
  ensure
    response.stream.close
  end
end
```

Le code ci-dessus maintiendra une connexion persistante avec le navigateur et enverra 100 messages de `"hello world\n"`, chacun séparé d'une seconde.

Il y a quelques points à noter dans l'exemple ci-dessus. Nous devons nous assurer de fermer le flux de réponse. Oublier de fermer le flux laissera le socket ouvert indéfiniment. Nous devons également définir le type de contenu sur `text/event-stream` avant d'écrire dans le flux de réponse. Cela est dû au fait que les en-têtes ne peuvent pas être écrits après que la réponse a été engagée (lorsque `response.committed?` renvoie une valeur vraie), ce qui se produit lorsque vous `write` ou `commit` le flux de réponse.

#### Exemple d'utilisation

Supposons que vous fabriquiez une machine de karaoké et qu'un utilisateur souhaite obtenir les paroles d'une chanson particulière. Chaque `Song` a un certain nombre de lignes et chaque ligne prend un temps `num_beats` pour terminer de chanter.

Si nous voulions renvoyer les paroles de manière karaoké (en n'envoyant la ligne suivante que lorsque le chanteur a terminé la ligne précédente), nous pourrions utiliser `ActionController::Live` comme suit :

```ruby
class LyricsController < ActionController::Base
  include ActionController::Live

  def show
    response.headers['Content-Type'] = 'text/event-stream'
    song = Song.find(params[:id])

    song.each do |line|
      response.stream.write line.lyrics
      sleep line.num_beats
    end
  ensure
    response.stream.close
  end
end
```

Le code ci-dessus envoie la ligne suivante seulement après que le chanteur a terminé la ligne précédente.

#### Considérations sur le streaming

Le streaming de données arbitraires est un outil extrêmement puissant. Comme le montrent les exemples précédents, vous pouvez choisir quand et quoi envoyer à travers un flux de réponse. Cependant, vous devez également noter les points suivants :

* Chaque flux de réponse crée un nouveau thread et copie les variables locales du thread à partir du thread d'origine. Avoir trop de variables locales de thread peut avoir un impact négatif sur les performances. De même, un grand nombre de threads peut également entraver les performances.
* Oublier de fermer le flux de réponse laissera le socket correspondant ouvert indéfiniment. Assurez-vous d'appeler `close` chaque fois que vous utilisez un flux de réponse.
* Les serveurs WEBrick mettent en mémoire tampon toutes les réponses, donc l'inclusion de `ActionController::Live` ne fonctionnera pas. Vous devez utiliser un serveur web qui ne met pas automatiquement en mémoire tampon les réponses.

Filtrage des journaux
-------------

Rails conserve un fichier journal pour chaque environnement dans le dossier `log`. Ces fichiers sont extrêmement utiles pour déboguer ce qui se passe réellement dans votre application, mais dans une application en direct, vous ne souhaitez peut-être pas que toutes les informations soient stockées dans le fichier journal.

### Filtrage des paramètres

Vous pouvez filtrer les paramètres de requête sensibles de vos fichiers journaux en les ajoutant à [`config.filter_parameters`][] dans la configuration de l'application. Ces paramètres seront marqués [FILTERED] dans le journal.

```ruby
config.filter_parameters << :password
```

NOTE : Les paramètres fournis seront filtrés par une expression régulière de correspondance partielle. Rails ajoute une liste de filtres par défaut, y compris `:passw`, `:secret` et `:token`, dans l'initialiseur approprié (`initializers/filter_parameter_logging.rb`) pour gérer les paramètres d'application typiques tels que `password`, `password_confirmation` et `my_token`.


### Filtrage des redirections

Il est parfois souhaitable de filtrer des fichiers journaux certaines localisations sensibles vers lesquelles votre application redirige. Vous pouvez le faire en utilisant l'option de configuration `config.filter_redirect` :

```ruby
config.filter_redirect << 's3.amazonaws.com'
```

Vous pouvez le définir comme une chaîne de caractères, une expression régulière ou un tableau des deux.

```ruby
config.filter_redirect.concat ['s3.amazonaws.com', /private_path/]
```

Les URL correspondantes seront marquées comme '[FILTERED]'.

Rescue
------

Il est fort probable que votre application contienne des bugs ou génère une exception qui doit être gérée. Par exemple, si l'utilisateur suit un lien vers une ressource qui n'existe plus dans la base de données, Active Record générera l'exception `ActiveRecord::RecordNotFound`.

La gestion des exceptions par défaut de Rails affiche un message "500 Server Error" pour toutes les exceptions. Si la requête a été effectuée localement, une trace détaillée et des informations supplémentaires sont affichées, vous permettant de comprendre ce qui s'est mal passé et de le traiter. Si la requête a été effectuée à distance, Rails affiche simplement un message simple "500 Server Error" à l'utilisateur, ou un message "404 Not Found" s'il y a une erreur de routage ou si un enregistrement n'a pas pu être trouvé. Parfois, vous voudrez peut-être personnaliser la façon dont ces erreurs sont capturées et affichées à l'utilisateur. Il existe plusieurs niveaux de gestion des exceptions disponibles dans une application Rails :
### Les modèles par défaut 500 et 404

Par défaut, en environnement de production, l'application affiche un message d'erreur 404 ou 500. En environnement de développement, toutes les exceptions non gérées sont simplement levées. Ces messages sont contenus dans des fichiers HTML statiques dans le dossier public, respectivement `404.html` et `500.html`. Vous pouvez personnaliser ces fichiers pour ajouter des informations supplémentaires et du style, mais rappelez-vous qu'il s'agit de fichiers HTML statiques ; c'est-à-dire que vous ne pouvez pas utiliser ERB, SCSS, CoffeeScript ou des mises en page pour eux.

### `rescue_from`

Si vous souhaitez faire quelque chose de plus élaboré lors de la capture d'erreurs, vous pouvez utiliser [`rescue_from`][], qui gère les exceptions d'un certain type (ou de plusieurs types) dans un contrôleur entier et ses sous-classes.

Lorsqu'une exception se produit et est capturée par une directive `rescue_from`, l'objet exception est transmis au gestionnaire. Le gestionnaire peut être une méthode ou un objet `Proc` passé à l'option `:with`. Vous pouvez également utiliser un bloc directement au lieu d'un objet `Proc` explicite.

Voici comment vous pouvez utiliser `rescue_from` pour intercepter toutes les erreurs `ActiveRecord::RecordNotFound` et faire quelque chose avec elles.

```ruby
class ApplicationController < ActionController::Base
  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found

  private
    def record_not_found
      render plain: "404 Not Found", status: 404
    end
end
```

Bien sûr, cet exemple est tout sauf élaboré et n'améliore pas du tout la gestion des exceptions par défaut, mais une fois que vous pouvez attraper toutes ces exceptions, vous êtes libre de faire ce que vous voulez avec elles. Par exemple, vous pouvez créer des classes d'exceptions personnalisées qui seront levées lorsque l'utilisateur n'a pas accès à certaines sections de votre application :

```ruby
class ApplicationController < ActionController::Base
  rescue_from User::NotAuthorized, with: :user_not_authorized

  private
    def user_not_authorized
      flash[:error] = "Vous n'avez pas accès à cette section."
      redirect_back(fallback_location: root_path)
    end
end

class ClientsController < ApplicationController
  # Vérifiez que l'utilisateur a la bonne autorisation pour accéder aux clients.
  before_action :check_authorization

  # Notez comment les actions n'ont pas à se soucier de tout le truc d'authentification.
  def edit
    @client = Client.find(params[:id])
  end

  private
    # Si l'utilisateur n'est pas autorisé, lancez simplement l'exception.
    def check_authorization
      raise User::NotAuthorized unless current_user.admin?
    end
end
```

AVERTISSEMENT : Utiliser `rescue_from` avec `Exception` ou `StandardError` peut entraîner des effets secondaires graves, car cela empêche Rails de gérer correctement les exceptions. Par conséquent, il n'est pas recommandé de le faire à moins qu'il n'y ait une raison valable.

NOTE : Lorsqu'il est exécuté en environnement de production, toutes les erreurs `ActiveRecord::RecordNotFound` affichent la page d'erreur 404. À moins que vous n'ayez besoin d'un comportement personnalisé, vous n'avez pas besoin de gérer cela.

NOTE : Certaines exceptions ne peuvent être récupérées que depuis la classe `ApplicationController`, car elles sont levées avant l'initialisation du contrôleur et l'exécution de l'action.


Forcer le protocole HTTPS
--------------------

Si vous souhaitez vous assurer que la communication avec votre contrôleur est uniquement possible via HTTPS, vous devez activer le middleware [`ActionDispatch::SSL`][] en utilisant [`config.force_ssl`][] dans votre configuration d'environnement.


Point de contrôle de santé intégré
------------------------------

Rails est également livré avec un point de contrôle de santé intégré accessible via le chemin `/up`. Ce point de contrôle renvoie un code d'état 200 si l'application a démarré sans exception, et un code d'état 500 sinon.

En production, de nombreuses applications doivent signaler leur état en amont, que ce soit à un moniteur de disponibilité qui avertira un ingénieur en cas de problème, ou à un équilibreur de charge ou un contrôleur Kubernetes utilisé pour déterminer la santé d'un pod. Ce point de contrôle de santé est conçu pour être un modèle unique qui fonctionnera dans de nombreuses situations.

Bien que toutes les nouvelles applications Rails générées auront le point de contrôle de santé à `/up`, vous pouvez configurer le chemin comme vous le souhaitez dans votre fichier "config/routes.rb" :

```ruby
Rails.application.routes.draw do
  get "healthz" => "rails/health#show", as: :rails_health_check
end
```

Le point de contrôle de santé sera maintenant accessible via le chemin `/healthz`.

NOTE : Ce point de contrôle ne reflète pas l'état de toutes les dépendances de votre application, telles que la base de données ou le cluster Redis. Remplacez "rails/health#show" par votre propre action de contrôleur si vous avez des besoins spécifiques à l'application.

Réfléchissez bien à ce que vous voulez vérifier, car cela peut entraîner des situations où votre application est redémarrée en raison d'un service tiers défaillant. Idéalement, vous devriez concevoir votre application pour gérer ces pannes de manière élégante.
[`ActionController::Base`]: https://api.rubyonrails.org/classes/ActionController/Base.html
[`params`]: https://api.rubyonrails.org/classes/ActionController/StrongParameters.html#method-i-params
[`wrap_parameters`]: https://api.rubyonrails.org/classes/ActionController/ParamsWrapper/Options/ClassMethods.html#method-i-wrap_parameters
[`controller_name`]: https://api.rubyonrails.org/classes/ActionController/Metal.html#method-i-controller_name
[`action_name`]: https://api.rubyonrails.org/classes/AbstractController/Base.html#method-i-action_name
[`permit`]: https://api.rubyonrails.org/classes/ActionController/Parameters.html#method-i-permit
[`permit!`]: https://api.rubyonrails.org/classes/ActionController/Parameters.html#method-i-permit-21
[`require`]: https://api.rubyonrails.org/classes/ActionController/Parameters.html#method-i-require
[`ActionDispatch::Session::CookieStore`]: https://api.rubyonrails.org/classes/ActionDispatch/Session/CookieStore.html
[`ActionDispatch::Session::CacheStore`]: https://api.rubyonrails.org/classes/ActionDispatch/Session/CacheStore.html
[`ActionDispatch::Session::MemCacheStore`]: https://api.rubyonrails.org/classes/ActionDispatch/Session/MemCacheStore.html
[activerecord-session_store]: https://github.com/rails/activerecord-session_store
[`reset_session`]: https://api.rubyonrails.org/classes/ActionController/Metal.html#method-i-reset_session
[`flash`]: https://api.rubyonrails.org/classes/ActionDispatch/Flash/RequestMethods.html#method-i-flash
[`flash.keep`]: https://api.rubyonrails.org/classes/ActionDispatch/Flash/FlashHash.html#method-i-keep
[`flash.now`]: https://api.rubyonrails.org/classes/ActionDispatch/Flash/FlashHash.html#method-i-now
[`config.action_dispatch.cookies_serializer`]: configuring.html#config-action-dispatch-cookies-serializer
[`cookies`]: https://api.rubyonrails.org/classes/ActionController/Cookies.html#method-i-cookies
[`before_action`]: https://api.rubyonrails.org/classes/AbstractController/Callbacks/ClassMethods.html#method-i-before_action
[`skip_before_action`]: https://api.rubyonrails.org/classes/AbstractController/Callbacks/ClassMethods.html#method-i-skip_before_action
[`after_action`]: https://api.rubyonrails.org/classes/AbstractController/Callbacks/ClassMethods.html#method-i-after_action
[`around_action`]: https://api.rubyonrails.org/classes/AbstractController/Callbacks/ClassMethods.html#method-i-around_action
[`ActionDispatch::Request`]: https://api.rubyonrails.org/classes/ActionDispatch/Request.html
[`request`]: https://api.rubyonrails.org/classes/ActionController/Base.html#method-i-request
[`response`]: https://api.rubyonrails.org/classes/ActionController/Base.html#method-i-response
[`path_parameters`]: https://api.rubyonrails.org/classes/ActionDispatch/Http/Parameters.html#method-i-path_parameters
[`query_parameters`]: https://api.rubyonrails.org/classes/ActionDispatch/Request.html#method-i-query_parameters
[`request_parameters`]: https://api.rubyonrails.org/classes/ActionDispatch/Request.html#method-i-request_parameters
[`http_basic_authenticate_with`]: https://api.rubyonrails.org/classes/ActionController/HttpAuthentication/Basic/ControllerMethods/ClassMethods.html#method-i-http_basic_authenticate_with
[`authenticate_or_request_with_http_digest`]: https://api.rubyonrails.org/classes/ActionController/HttpAuthentication/Digest/ControllerMethods.html#method-i-authenticate_or_request_with_http_digest
[`authenticate_or_request_with_http_token`]: https://api.rubyonrails.org/classes/ActionController/HttpAuthentication/Token/ControllerMethods.html#method-i-authenticate_or_request_with_http_token
[`send_data`]: https://api.rubyonrails.org/classes/ActionController/DataStreaming.html#method-i-send_data
[`send_file`]: https://api.rubyonrails.org/classes/ActionController/DataStreaming.html#method-i-send_file
[`ActionController::Live`]: https://api.rubyonrails.org/classes/ActionController/Live.html
[`config.filter_parameters`]: configuring.html#config-filter-parameters
[`rescue_from`]: https://api.rubyonrails.org/classes/ActiveSupport/Rescuable/ClassMethods.html#method-i-rescue_from
[`config.force_ssl`]: configuring.html#config-force-ssl
[`ActionDispatch::SSL`]: https://api.rubyonrails.org/classes/ActionDispatch/SSL.html
