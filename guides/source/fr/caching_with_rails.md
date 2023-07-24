**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: bef23603f5d822054701f5cbf2578d95
Mise en cache avec Rails : Aperçu
===============================

Ce guide est une introduction à l'accélération de votre application Rails avec la mise en cache.

La mise en cache consiste à stocker le contenu généré pendant le cycle de demande-réponse et à le réutiliser lors de réponses à des demandes similaires.

La mise en cache est souvent le moyen le plus efficace d'améliorer les performances d'une application. Grâce à la mise en cache, les sites web fonctionnant sur un seul serveur avec une seule base de données peuvent supporter une charge de milliers d'utilisateurs simultanés.

Rails propose un ensemble de fonctionnalités de mise en cache prêtes à l'emploi. Ce guide vous enseignera la portée et le but de chacune d'entre elles. Maîtrisez ces techniques et vos applications Rails pourront servir des millions de vues sans temps de réponse exorbitant ni factures de serveur élevées.

Après avoir lu ce guide, vous saurez :

* La mise en cache par fragments et par poupées russes.
* Comment gérer les dépendances de mise en cache.
* Les magasins de cache alternatifs.
* Le support GET conditionnel.

--------------------------------------------------------------------------------

Mise en cache de base
-------------

Il s'agit d'une introduction à trois types de techniques de mise en cache : la mise en cache de page, d'action et de fragment. Par défaut, Rails fournit la mise en cache de fragment. Pour utiliser la mise en cache de page et d'action, vous devrez ajouter `actionpack-page_caching` et `actionpack-action_caching` à votre `Gemfile`.

Par défaut, la mise en cache n'est activée que dans votre environnement de production. Vous pouvez expérimenter la mise en cache localement en exécutant `rails dev:cache`, ou en définissant [`config.action_controller.perform_caching`][] sur `true` dans `config/environments/development.rb`.

NOTE : Changer la valeur de `config.action_controller.perform_caching` n'aura d'effet que sur la mise en cache fournie par Action Controller. Par exemple, cela n'aura pas d'impact sur la mise en cache de bas niveau que nous abordons ci-dessous.

### Mise en cache de page

La mise en cache de page est un mécanisme de Rails qui permet à la demande d'une page générée d'être satisfaite par le serveur web (c'est-à-dire Apache ou NGINX) sans avoir à passer par l'ensemble de la pile Rails. Bien que cela soit très rapide, cela ne peut pas être appliqué à toutes les situations (comme les pages nécessitant une authentification). De plus, comme le serveur web sert un fichier directement depuis le système de fichiers, vous devrez mettre en place une expiration du cache.

INFO : La mise en cache de page a été supprimée de Rails 4. Voir le [gem actionpack-page_caching](https://github.com/rails/actionpack-page_caching).

### Mise en cache d'action

La mise en cache de page ne peut pas être utilisée pour les actions qui ont des filtres avant - par exemple, les pages qui nécessitent une authentification. C'est là que la mise en cache d'action intervient. La mise en cache d'action fonctionne comme la mise en cache de page, sauf que la demande web entrante atteint la pile Rails afin que les filtres avant puissent être exécutés avant que le cache ne soit servi. Cela permet d'exécuter l'authentification et d'autres restrictions tout en servant le résultat de la sortie à partir d'une copie mise en cache.

INFO : La mise en cache d'action a été supprimée de Rails 4. Voir le [gem actionpack-action_caching](https://github.com/rails/actionpack-action_caching). Voir [l'aperçu de l'expiration du cache basée sur les clés de DHH](https://signalvnoise.com/posts/3113-how-key-based-cache-expiration-works) pour la méthode préférée.

### Mise en cache de fragment

Les applications web dynamiques construisent généralement des pages avec une variété de composants qui n'ont pas tous les mêmes caractéristiques de mise en cache. Lorsque différentes parties de la page doivent être mises en cache et expirées séparément, vous pouvez utiliser la mise en cache de fragment.

La mise en cache de fragment permet à une partie de la logique de la vue d'être enveloppée dans un bloc de cache et d'être servie à partir du magasin de cache lors de la prochaine demande.

Par exemple, si vous souhaitez mettre en cache chaque produit sur une page, vous pouvez utiliser ce code :

```html+erb
<% @products.each do |product| %>
  <% cache product do %>
    <%= render product %>
  <% end %>
<% end %>
```

Lorsque votre application reçoit sa première demande pour cette page, Rails écrira une nouvelle entrée de cache avec une clé unique. Une clé ressemble à ceci :

```
views/products/index:bea67108094918eeba42cd4a6e786901/products/1
```

La chaîne de caractères au milieu est un condensé de l'arborescence du modèle. Il s'agit d'un condensé de hachage calculé en fonction du contenu du fragment de vue que vous mettez en cache. Si vous modifiez le fragment de vue (par exemple, le HTML change), le condensé changera, ce qui expirera le fichier existant.

Une version de cache, dérivée de l'enregistrement du produit, est stockée dans l'entrée de cache. Lorsque le produit est modifié, la version de cache change et tous les fragments mis en cache qui contiennent la version précédente sont ignorés.

CONSEIL : Les magasins de cache comme Memcached supprimeront automatiquement les anciens fichiers de cache.

Si vous souhaitez mettre en cache un fragment dans certaines conditions, vous pouvez utiliser `cache_if` ou `cache_unless` :

```erb
<% cache_if admin?, product do %>
  <%= render product %>
<% end %>
```

#### Mise en cache de collection

L'aide `render` peut également mettre en cache les modèles individuels rendus pour une collection. Elle peut même améliorer l'exemple précédent avec `each` en lisant tous les modèles de cache à la fois au lieu d'un par un. Cela se fait en passant `cached: true` lors du rendu de la collection :
```html+erb
<%= render partial: 'products/product', collection: @products, cached: true %>
```

Tous les modèles mis en cache lors des rendus précédents seront récupérés en une seule fois, avec une vitesse beaucoup plus élevée. De plus, les modèles qui n'ont pas encore été mis en cache seront écrits en cache et récupérés en une seule fois lors du prochain rendu.

### Mise en cache de poupées russes

Vous pouvez vouloir imbriquer des fragments mis en cache à l'intérieur d'autres fragments mis en cache. Cela s'appelle la mise en cache de poupées russes.

L'avantage de la mise en cache de poupées russes est que si un seul produit est mis à jour, tous les autres fragments internes peuvent être réutilisés lors de la régénération du fragment externe.

Comme expliqué dans la section précédente, un fichier mis en cache expirera si la valeur de `updated_at` change pour un enregistrement sur lequel le fichier mis en cache dépend directement. Cependant, cela n'expirera pas le cache dans lequel le fragment est imbriqué.

Par exemple, prenons la vue suivante :

```erb
<% cache product do %>
  <%= render product.games %>
<% end %>
```

Qui à son tour rend cette vue :

```erb
<% cache game do %>
  <%= render game %>
<% end %>
```

Si un attribut de game est modifié, la valeur de `updated_at` sera définie sur l'heure actuelle, ce qui expirera le cache. Cependant, comme `updated_at` ne sera pas modifié pour l'objet product, ce cache ne sera pas expiré et votre application servira des données obsolètes. Pour résoudre ce problème, nous lierons les modèles ensemble avec la méthode `touch` :

```ruby
class Product < ApplicationRecord
  has_many :games
end

class Game < ApplicationRecord
  belongs_to :product, touch: true
end
```

Avec `touch` défini sur `true`, toute action qui modifie `updated_at` pour un enregistrement de jeu le modifiera également pour le produit associé, ce qui expirera le cache.

### Mise en cache partielle partagée

Il est possible de partager des partiels et la mise en cache associée entre des fichiers avec des types MIME différents. Par exemple, la mise en cache partielle partagée permet aux auteurs de modèles de partager un partiel entre des fichiers HTML et JavaScript. Lorsque les modèles sont collectés dans les chemins de fichiers du résolveur de modèles, ils incluent uniquement l'extension du langage de modèle et non le type MIME. Pour cette raison, les modèles peuvent être utilisés pour plusieurs types MIME. Les requêtes HTML et JavaScript répondront tous deux au code suivant :

```ruby
render(partial: 'hotels/hotel', collection: @hotels, cached: true)
```

Chargera un fichier nommé `hotels/hotel.erb`.

Une autre option consiste à inclure le nom complet du fichier partiel à rendre.

```ruby
render(partial: 'hotels/hotel.html.erb', collection: @hotels, cached: true)
```

Chargera un fichier nommé `hotels/hotel.html.erb` dans n'importe quel type MIME de fichier, par exemple vous pouvez inclure ce partiel dans un fichier JavaScript.

### Gestion des dépendances

Pour invalider correctement le cache, vous devez définir correctement les dépendances de mise en cache. Rails est suffisamment intelligent pour gérer les cas courants, vous n'avez donc pas besoin de spécifier quoi que ce soit. Cependant, parfois, lorsque vous travaillez avec des helpers personnalisés par exemple, vous devez les définir explicitement.

#### Dépendances implicites

La plupart des dépendances de modèle peuvent être déduites à partir des appels à `render` dans le modèle lui-même. Voici quelques exemples d'appels à `render` que `ActionView::Digestor` sait décoder :

```ruby
render partial: "comments/comment", collection: commentable.comments
render "comments/comments"
render 'comments/comments'
render('comments/comments')

render "header" se traduit par render("comments/header")

render(@topic)         se traduit par render("topics/topic")
render(topics)         se traduit par render("topics/topic")
render(message.topics) se traduit par render("topics/topic")
```

D'autre part, certains appels doivent être modifiés pour que la mise en cache fonctionne correctement. Par exemple, si vous transmettez une collection personnalisée, vous devrez modifier :

```ruby
render @project.documents.where(published: true)
```

à :

```ruby
render partial: "documents/document", collection: @project.documents.where(published: true)
```

#### Dépendances explicites

Parfois, vous aurez des dépendances de modèle qui ne peuvent pas être déduites du tout. C'est généralement le cas lorsque le rendu se produit dans des helpers. Voici un exemple :

```html+erb
<%= render_sortable_todolists @project.todolists %>
```

Vous devrez utiliser un format de commentaire spécial pour les appeler :

```html+erb
<%# Dépendance de modèle : todolists/todolist %>
<%= render_sortable_todolists @project.todolists %>
```

Dans certains cas, comme une configuration d'héritage de table unique, vous pouvez avoir plusieurs dépendances explicites. Au lieu d'écrire chaque modèle, vous pouvez utiliser un joker pour faire correspondre n'importe quel modèle dans un répertoire :

```html+erb
<%# Dépendance de modèle : events/* %>
<%= render_categorizable_events @person.events %>
```

En ce qui concerne la mise en cache de collection, si le modèle partiel ne commence pas par un appel de cache propre, vous pouvez toujours bénéficier de la mise en cache de collection en ajoutant un format de commentaire spécial n'importe où dans le modèle, par exemple :

```html+erb
<%# Collection de modèles : notification %>
<% my_helper_that_calls_cache(some_arg, notification) do %>
  <%= notification.name %>
<% end %>
```
#### Dépendances externes

Si vous utilisez une méthode auxiliaire, par exemple, à l'intérieur d'un bloc mis en cache et que vous mettez à jour cette méthode auxiliaire, vous devrez également mettre à jour le cache. Peu importe comment vous le faites, mais le MD5 du fichier de modèle doit changer. Une recommandation est d'être simplement explicite dans un commentaire, comme ceci :

```html+erb
<%# Helper Dependency Updated: 28 juillet 2015 à 19h %>
<%= some_helper_method(person) %>
```

### Mise en cache de bas niveau

Parfois, vous devez mettre en cache une valeur particulière ou le résultat d'une requête plutôt que de mettre en cache des fragments de vue. Le mécanisme de mise en cache de Rails fonctionne très bien pour stocker toutes les informations sérialisables.

La manière la plus efficace de mettre en œuvre une mise en cache de bas niveau est d'utiliser la méthode `Rails.cache.fetch`. Cette méthode effectue à la fois la lecture et l'écriture dans le cache. Lorsqu'un seul argument est passé, la clé est récupérée et la valeur du cache est renvoyée. Si un bloc est passé, ce bloc sera exécuté en cas de cache manqué. La valeur de retour du bloc sera écrite dans le cache sous la clé de cache donnée, et cette valeur de retour sera renvoyée. En cas de cache trouvé, la valeur mise en cache sera renvoyée sans exécuter le bloc.

Considérez l'exemple suivant. Une application a un modèle `Product` avec une méthode d'instance qui recherche le prix du produit sur un site concurrent. Les données renvoyées par cette méthode seraient parfaites pour une mise en cache de bas niveau :

```ruby
class Product < ApplicationRecord
  def competing_price
    Rails.cache.fetch("#{cache_key_with_version}/competing_price", expires_in: 12.hours) do
      Competitor::API.find_price(id)
    end
  end
end
```

NOTE : Remarquez que dans cet exemple, nous avons utilisé la méthode `cache_key_with_version`, de sorte que la clé de cache résultante sera quelque chose comme `products/233-20140225082222765838000/competing_price`. `cache_key_with_version` génère une chaîne basée sur le nom de classe du modèle, l'`id` et les attributs `updated_at`. C'est une convention courante et cela permet d'invaliditer le cache chaque fois que le produit est mis à jour. En général, lorsque vous utilisez une mise en cache de bas niveau, vous devez générer une clé de cache.

#### Évitez de mettre en cache des instances d'objets Active Record

Considérez cet exemple, qui stocke une liste d'objets Active Record représentant des superutilisateurs dans le cache :

```ruby
# super_admins est une requête SQL coûteuse, donc ne l'exécutez pas trop souvent
Rails.cache.fetch("super_admin_users", expires_in: 12.hours) do
  User.super_admins.to_a
end
```

Vous devriez __éviter__ ce modèle. Pourquoi ? Parce que l'instance pourrait changer. En production, ses attributs pourraient être différents, ou l'enregistrement pourrait être supprimé. Et en développement, cela fonctionne de manière peu fiable avec les magasins de cache qui rechargent le code lorsque vous apportez des modifications.

Au lieu de cela, mettez en cache l'ID ou un autre type de données primitif. Par exemple :

```ruby
# super_admins est une requête SQL coûteuse, donc ne l'exécutez pas trop souvent
ids = Rails.cache.fetch("super_admin_user_ids", expires_in: 12.hours) do
  User.super_admins.pluck(:id)
end
User.where(id: ids).to_a
```

### Mise en cache SQL

La mise en cache de requêtes est une fonctionnalité de Rails qui met en cache l'ensemble des résultats renvoyés par chaque requête. Si Rails rencontre la même requête à nouveau pour cette demande, il utilisera l'ensemble des résultats mis en cache au lieu d'exécuter à nouveau la requête contre la base de données.

Par exemple :

```ruby
class ProductsController < ApplicationController
  def index
    # Exécuter une requête de recherche
    @products = Product.all

    # ...

    # Exécuter à nouveau la même requête
    @products = Product.all
  end
end
```

La deuxième fois que la même requête est exécutée contre la base de données, elle ne va pas réellement accéder à la base de données. La première fois, le résultat est renvoyé depuis le cache de requête (en mémoire) et la deuxième fois, il est extrait de la mémoire.

Cependant, il est important de noter que les caches de requête sont créés au début d'une action et détruits à la fin de cette action et ne persistent donc que pendant la durée de l'action. Si vous souhaitez stocker les résultats de requête de manière plus persistante, vous pouvez utiliser une mise en cache de bas niveau.

Magasins de cache
------------

Rails fournit différents magasins pour les données mises en cache (en dehors de la mise en cache SQL et de la mise en cache de pages).

### Configuration

Vous pouvez configurer le magasin de cache par défaut de votre application en définissant l'option de configuration `config.cache_store`. D'autres paramètres peuvent être passés en tant qu'arguments au constructeur du magasin de cache :

```ruby
config.cache_store = :memory_store, { size: 64.megabytes }
```

Alternativement, vous pouvez définir `ActionController::Base.cache_store` en dehors d'un bloc de configuration.

Vous pouvez accéder au cache en appelant `Rails.cache`.

#### Options du pool de connexions

Par défaut, [`:mem_cache_store`](#activesupport-cache-memcachestore) et
[`:redis_cache_store`](#activesupport-cache-rediscachestore) sont configurés pour utiliser
le pool de connexions. Cela signifie que si vous utilisez Puma, ou un autre serveur à threads,
vous pouvez avoir plusieurs threads effectuant des requêtes vers le magasin de cache en même temps.
Si vous souhaitez désactiver le pool de connexions, définissez l'option `:pool` sur `false` lors de la configuration du cache store :

```ruby
config.cache_store = :mem_cache_store, "cache.example.com", pool: false
```

Vous pouvez également remplacer les paramètres de pool par défaut en fournissant des options individuelles à l'option `:pool` :

```ruby
config.cache_store = :mem_cache_store, "cache.example.com", pool: { size: 32, timeout: 1 }
```

* `:size` - Cette option définit le nombre de connexions par processus (par défaut : 5).

* `:timeout` - Cette option définit le nombre de secondes à attendre pour une connexion (par défaut : 5). Si aucune connexion n'est disponible dans le délai imparti, une `Timeout::Error` sera levée.

### `ActiveSupport::Cache::Store`

[`ActiveSupport::Cache::Store`][] fournit les fondations pour interagir avec le cache dans Rails. Il s'agit d'une classe abstraite et vous ne pouvez pas l'utiliser seule. Au lieu de cela, vous devez utiliser une implémentation concrète de la classe liée à un moteur de stockage. Rails est livré avec plusieurs implémentations, documentées ci-dessous.

Les principales méthodes de l'API sont [`read`][ActiveSupport::Cache::Store#read], [`write`][ActiveSupport::Cache::Store#write], [`delete`][ActiveSupport::Cache::Store#delete], [`exist?`][ActiveSupport::Cache::Store#exist?] et [`fetch`][ActiveSupport::Cache::Store#fetch].

Les options passées au constructeur du cache store seront traitées comme des options par défaut pour les méthodes de l'API appropriées.


### `ActiveSupport::Cache::MemoryStore`

[`ActiveSupport::Cache::MemoryStore`][] conserve les entrées en mémoire dans le même processus Ruby. Le cache
store a une taille limitée spécifiée en envoyant l'option `:size` à l'initialiseur (par défaut : 32 Mo). Lorsque le cache dépasse la taille allouée, un
nettoyage sera effectué et les entrées les moins récemment utilisées seront supprimées.

```ruby
config.cache_store = :memory_store, { size: 64.megabytes }
```

Si vous exécutez plusieurs processus de serveur Ruby on Rails (ce qui est le cas
si vous utilisez Phusion Passenger ou le mode cluster puma), alors vos instances de processus de serveur Rails
ne pourront pas partager les données du cache entre elles. Ce cache
store n'est pas adapté aux déploiements d'applications volumineuses. Cependant, il peut
bien fonctionner pour les petits sites à faible trafic avec seulement quelques processus de serveur,
ainsi que pour les environnements de développement et de test.

Les nouveaux projets Rails sont configurés pour utiliser cette implémentation par défaut dans l'environnement de développement.

REMARQUE : Comme les processus ne partageront pas les données du cache lors de l'utilisation de `:memory_store`,
il ne sera pas possible de lire, d'écrire ou d'expirer manuellement le cache via la console Rails.


### `ActiveSupport::Cache::FileStore`

[`ActiveSupport::Cache::FileStore`][] utilise le système de fichiers pour stocker les entrées. Le chemin du répertoire où les fichiers du store seront stockés doit être spécifié lors de l'initialisation du cache.

```ruby
config.cache_store = :file_store, "/chemin/vers/le/répertoire/cache"
```

Avec ce cache store, plusieurs processus de serveur sur le même hôte peuvent partager un
cache. Ce cache store convient aux sites à faible à moyen trafic qui sont
servis à partir d'un ou deux hôtes. Les processus de serveur s'exécutant sur des hôtes différents pourraient
partager un cache en utilisant un système de fichiers partagé, mais cette configuration n'est pas recommandée.

Comme le cache va croître jusqu'à ce que le disque soit plein, il est recommandé de
vider périodiquement les anciennes entrées.

Il s'agit de l'implémentation par défaut du cache store (à `"#{root}/tmp/cache/"`) si
aucune `config.cache_store` explicite n'est fournie.


### `ActiveSupport::Cache::MemCacheStore`

[`ActiveSupport::Cache::MemCacheStore`][] utilise le serveur `memcached` de Danga pour fournir un cache centralisé pour votre application. Rails utilise par défaut le gem `dalli` inclus. Il s'agit actuellement du cache store le plus populaire pour les sites web en production. Il peut être utilisé pour fournir un cluster de cache unique et partagé avec des performances et une redondance très élevées.

Lors de l'initialisation du cache, vous devez spécifier les adresses de tous les serveurs memcached de votre cluster, ou vous assurer que la variable d'environnement `MEMCACHE_SERVERS` a été définie correctement.

```ruby
config.cache_store = :mem_cache_store, "cache-1.example.com", "cache-2.example.com"
```

Si aucune adresse n'est spécifiée, il supposera que memcached s'exécute en local sur le port par défaut (`127.0.0.1:11211`), mais ce n'est pas une configuration idéale pour les sites plus importants.

```ruby
config.cache_store = :mem_cache_store # Utilisera $MEMCACHE_SERVERS, puis 127.0.0.1:11211 en dernier recours
```

Consultez la documentation de [`Dalli::Client`](https://www.rubydoc.info/gems/dalli/Dalli/Client#initialize-instance_method) pour les types d'adresses pris en charge.

La méthode [`write`][ActiveSupport::Cache::MemCacheStore#write] (et `fetch`) de ce cache accepte des options supplémentaires qui exploitent des fonctionnalités spécifiques à memcached.


### `ActiveSupport::Cache::RedisCacheStore`

[`ActiveSupport::Cache::RedisCacheStore`][] profite de la prise en charge de Redis pour l'éviction automatique
lorsqu'il atteint la mémoire maximale, ce qui lui permet de se comporter comme un serveur de cache Memcached.

Note de déploiement : Redis n'expire pas les clés par défaut, veillez donc à utiliser un
serveur Redis cache dédié. Ne remplissez pas votre serveur Redis persistant avec
des données de cache volatiles ! Lisez le
[guide de configuration du serveur de cache Redis](https://redis.io/topics/lru-cache) en détail.

Pour un serveur Redis cache uniquement, définissez `maxmemory-policy` sur l'une des variantes de allkeys.
Redis 4+ prend en charge l'éviction des clés les moins fréquemment utilisées (`allkeys-lfu`), un excellent
choix par défaut. Redis 3 et les versions antérieures doivent utiliser l'éviction des clés les moins récemment utilisées (`allkeys-lru`).
Définissez des délais d'attente de lecture et d'écriture du cache relativement courts. Régénérer une valeur mise en cache est souvent plus rapide que d'attendre plus d'une seconde pour la récupérer. Les délais d'attente de lecture et d'écriture sont tous deux définis par défaut à 1 seconde, mais peuvent être réduits si votre réseau a une latence constamment faible.

Par défaut, le magasin de cache n'essaiera pas de se reconnecter à Redis si la connexion échoue pendant une requête. Si vous rencontrez des déconnexions fréquentes, vous pouvez activer les tentatives de reconnexion.

Les lectures et écritures de cache ne génèrent jamais d'exceptions ; elles renvoient simplement `nil` à la place, se comportant comme s'il n'y avait rien dans le cache. Pour évaluer si votre cache génère des exceptions, vous pouvez fournir un `error_handler` pour signaler un service de collecte d'exceptions. Il doit accepter trois arguments de mot-clé : `method`, la méthode du magasin de cache qui a été appelée initialement ; `returning`, la valeur renvoyée à l'utilisateur, généralement `nil` ; et `exception`, l'exception qui a été capturée.

Pour commencer, ajoutez la gemme redis à votre Gemfile :

```ruby
gem 'redis'
```

Enfin, ajoutez la configuration dans le fichier `config/environments/*.rb` correspondant :

```ruby
config.cache_store = :redis_cache_store, { url: ENV['REDIS_URL'] }
```

Un magasin de cache Redis plus complexe, adapté à la production, peut ressembler à ceci :

```ruby
cache_servers = %w(redis://cache-01:6379/0 redis://cache-02:6379/0)
config.cache_store = :redis_cache_store, { url: cache_servers,

  connect_timeout:    30,  # Par défaut : 20 secondes
  read_timeout:       0.2, # Par défaut : 1 seconde
  write_timeout:      0.2, # Par défaut : 1 seconde
  reconnect_attempts: 1,   # Par défaut : 0

  error_handler: -> (method:, returning:, exception:) {
    # Signaler les erreurs à Sentry en tant que warnings
    Sentry.capture_exception exception, level: 'warning',
      tags: { method: method, returning: returning }
  }
}
```


### `ActiveSupport::Cache::NullStore`

[`ActiveSupport::Cache::NullStore`][] est limité à chaque requête web et efface les valeurs stockées à la fin d'une requête. Il est destiné à être utilisé dans les environnements de développement et de test. Il peut être très utile lorsque vous avez du code qui interagit directement avec `Rails.cache` mais que le cache interfère avec la visualisation des résultats des modifications de code.

```ruby
config.cache_store = :null_store
```


### Magasins de cache personnalisés

Vous pouvez créer votre propre magasin de cache personnalisé en étendant simplement `ActiveSupport::Cache::Store` et en implémentant les méthodes appropriées. De cette façon, vous pouvez utiliser n'importe quel nombre de technologies de mise en cache dans votre application Rails.

Pour utiliser un magasin de cache personnalisé, définissez simplement le magasin de cache sur une nouvelle instance de votre classe personnalisée.

```ruby
config.cache_store = MyCacheStore.new
```

Clés de cache
----------

Les clés utilisées dans un cache peuvent être n'importe quel objet qui répond à `cache_key` ou `to_param`. Vous pouvez implémenter la méthode `cache_key` dans vos classes si vous avez besoin de générer des clés personnalisées. Active Record générera des clés basées sur le nom de la classe et l'identifiant de l'enregistrement.

Vous pouvez utiliser des Hashes et des tableaux de valeurs comme clés de cache.

```ruby
# Ceci est une clé de cache valide
Rails.cache.read(site: "mysite", owners: [owner_1, owner_2])
```

Les clés que vous utilisez sur `Rails.cache` ne seront pas les mêmes que celles réellement utilisées avec le moteur de stockage. Elles peuvent être modifiées avec un espace de noms ou modifiées pour s'adapter aux contraintes de la technologie backend. Cela signifie, par exemple, que vous ne pouvez pas enregistrer des valeurs avec `Rails.cache` et ensuite essayer de les récupérer avec la gemme `dalli`. Cependant, vous n'avez pas non plus besoin de vous soucier de dépasser la limite de taille de memcached ou de violer les règles de syntaxe.

Support des requêtes GET conditionnelles
-----------------------

Les requêtes GET conditionnelles sont une fonctionnalité de la spécification HTTP qui permet aux serveurs web d'indiquer aux navigateurs que la réponse à une requête GET n'a pas changé depuis la dernière requête et peut être récupérée en toute sécurité depuis le cache du navigateur.

Elles fonctionnent en utilisant les en-têtes `HTTP_IF_NONE_MATCH` et `HTTP_IF_MODIFIED_SINCE` pour transmettre à la fois un identifiant de contenu unique et l'horodatage de la dernière modification du contenu. Si le navigateur envoie une requête où l'identifiant de contenu (ETag) ou l'horodatage de la dernière modification correspond à la version du serveur, alors le serveur n'a besoin de renvoyer qu'une réponse vide avec un statut de non modifié.

Il incombe au serveur (c'est-à-dire à nous) de rechercher un horodatage de dernière modification et l'en-tête if-none-match et de déterminer s'il faut renvoyer ou non la réponse complète. Avec le support des requêtes GET conditionnelles dans Rails, cela est assez simple :

```ruby
class ProductsController < ApplicationController
  def show
    @product = Product.find(params[:id])

    # Si la requête est obsolète selon l'horodatage donné et la valeur etag
    # (c'est-à-dire qu'elle doit être traitée à nouveau), exécutez ce bloc
    if stale?(last_modified: @product.updated_at.utc, etag: @product.cache_key_with_version)
      respond_to do |wants|
        # ... traitement normal de la réponse
      end
    end

    # Si la requête est fraîche (c'est-à-dire qu'elle n'a pas été modifiée), vous n'avez rien à faire. Le rendu par défaut vérifie cela en utilisant les paramètres
    # utilisés dans l'appel précédent à stale? et enverra automatiquement un
    # :not_modified. C'est tout, vous avez terminé.
  end
end
```
Au lieu d'un hachage d'options, vous pouvez également simplement passer un modèle. Rails utilisera les méthodes `updated_at` et `cache_key_with_version` pour définir `last_modified` et `etag` :

```ruby
class ProductsController < ApplicationController
  def show
    @product = Product.find(params[:id])

    if stale?(@product)
      respond_to do |wants|
        # ... traitement normal de la réponse
      end
    end
  end
end
```

Si vous n'avez aucun traitement spécial de la réponse et utilisez le mécanisme de rendu par défaut (c'est-à-dire que vous n'utilisez pas `respond_to` ou n'appelez pas `render` vous-même), vous disposez d'une aide facile avec `fresh_when` :

```ruby
class ProductsController < ApplicationController
  # Cela enverra automatiquement un :not_modified si la requête est fraîche,
  # et rendra le modèle par défaut (product.*) s'il est obsolète.

  def show
    @product = Product.find(params[:id])
    fresh_when last_modified: @product.published_at.utc, etag: @product
  end
end
```

Parfois, nous voulons mettre en cache une réponse, par exemple une page statique, qui ne sera jamais expirée. Pour cela, nous pouvons utiliser l'aide `http_cache_forever` et ainsi le navigateur et les proxies le mettront en cache indéfiniment.

Par défaut, les réponses mises en cache seront privées, mises en cache uniquement sur le navigateur web de l'utilisateur. Pour permettre aux proxies de mettre en cache la réponse, définissez `public: true` pour indiquer qu'ils peuvent servir la réponse mise en cache à tous les utilisateurs.

En utilisant cette aide, l'en-tête `last_modified` est défini sur `Time.new(2011, 1, 1).utc` et l'en-tête `expires` est défini sur 100 ans.

AVERTISSEMENT : Utilisez cette méthode avec précaution car le navigateur/le proxy ne pourra pas invalider la réponse mise en cache à moins que le cache du navigateur ne soit effacé de force.

```ruby
class HomeController < ApplicationController
  def index
    http_cache_forever(public: true) do
      render
    end
  end
end
```

### ETags forts par rapport aux ETags faibles

Rails génère des ETags faibles par défaut. Les ETags faibles permettent aux réponses sémantiquement équivalentes d'avoir les mêmes ETags, même si leurs corps ne correspondent pas exactement. Cela est utile lorsque nous ne voulons pas que la page soit régénérée pour de petites modifications dans le corps de la réponse.

Les ETags faibles ont un préfixe `W/` pour les différencier des ETags forts.

```
W/"618bbc92e2d35ea1945008b42799b0e7" → ETag faible
"618bbc92e2d35ea1945008b42799b0e7" → ETag fort
```

Contrairement à l'ETag faible, l'ETag fort implique que la réponse doit être exactement la même et identique octet par octet. C'est utile lors de l'utilisation de requêtes Range dans un grand fichier vidéo ou PDF. Certains CDN ne prennent en charge que les ETags forts, comme Akamai. Si vous avez absolument besoin de générer un ETag fort, vous pouvez le faire comme suit.

```ruby
class ProductsController < ApplicationController
  def show
    @product = Product.find(params[:id])
    fresh_when last_modified: @product.published_at.utc, strong_etag: @product
  end
end
```

Vous pouvez également définir l'ETag fort directement sur la réponse.

```ruby
response.strong_etag = response.body # => "618bbc92e2d35ea1945008b42799b0e7"
```

Mise en cache en développement
-----------------------------

Il est courant de vouloir tester la stratégie de mise en cache de votre application en mode développement. Rails fournit la commande `dev:cache` pour activer/désactiver facilement la mise en cache.

```bash
$ bin/rails dev:cache
Le mode développement est maintenant mis en cache.
$ bin/rails dev:cache
Le mode développement n'est plus mis en cache.
```

Par défaut, lorsque la mise en cache en mode développement est *désactivée*, Rails utilise [`:null_store`](#activesupport-cache-nullstore).

Références
----------

* [Article de DHH sur l'expiration basée sur les clés](https://signalvnoise.com/posts/3113-how-key-based-cache-expiration-works)
* [Railscast de Ryan Bates sur les digests de cache](http://railscasts.com/episodes/387-cache-digests)
[`config.action_controller.perform_caching`]: configuring.html#config-action-controller-perform-caching
[`ActiveSupport::Cache::Store`]: https://api.rubyonrails.org/classes/ActiveSupport/Cache/Store.html
[ActiveSupport::Cache::Store#delete]: https://api.rubyonrails.org/classes/ActiveSupport/Cache/Store.html#method-i-delete
[ActiveSupport::Cache::Store#exist?]: https://api.rubyonrails.org/classes/ActiveSupport/Cache/Store.html#method-i-exist-3F
[ActiveSupport::Cache::Store#fetch]: https://api.rubyonrails.org/classes/ActiveSupport/Cache/Store.html#method-i-fetch
[ActiveSupport::Cache::Store#read]: https://api.rubyonrails.org/classes/ActiveSupport/Cache/Store.html#method-i-read
[ActiveSupport::Cache::Store#write]: https://api.rubyonrails.org/classes/ActiveSupport/Cache/Store.html#method-i-write
[`ActiveSupport::Cache::MemoryStore`]: https://api.rubyonrails.org/classes/ActiveSupport/Cache/MemoryStore.html
[`ActiveSupport::Cache::FileStore`]: https://api.rubyonrails.org/classes/ActiveSupport/Cache/FileStore.html
[`ActiveSupport::Cache::MemCacheStore`]: https://api.rubyonrails.org/classes/ActiveSupport/Cache/MemCacheStore.html
[ActiveSupport::Cache::MemCacheStore#write]: https://api.rubyonrails.org/classes/ActiveSupport/Cache/MemCacheStore.html#method-i-write
[`ActiveSupport::Cache::RedisCacheStore`]: https://api.rubyonrails.org/classes/ActiveSupport/Cache/RedisCacheStore.html
[`ActiveSupport::Cache::NullStore`]: https://api.rubyonrails.org/classes/ActiveSupport/Cache/NullStore.html
