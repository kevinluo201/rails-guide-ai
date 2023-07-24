**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: b093936da01fde14532f4cead51234e1
Instrumentation Active Support
==============================

Active Support est une partie de Rails qui fournit des extensions de langage Ruby, des utilitaires et d'autres choses. L'une des choses qu'il inclut est une API d'instrumentation qui peut être utilisée à l'intérieur d'une application pour mesurer certaines actions qui se produisent dans le code Ruby, telles que celles à l'intérieur d'une application Rails ou du framework lui-même. Cependant, il n'est pas limité à Rails. Il peut être utilisé indépendamment dans d'autres scripts Ruby si nécessaire.

Dans ce guide, vous apprendrez comment utiliser l'API d'instrumentation d'Active Support pour mesurer des événements à l'intérieur de Rails et d'autres codes Ruby.

Après avoir lu ce guide, vous saurez :

* Ce que l'instrumentation peut fournir.
* Comment ajouter un abonné à un crochet.
* Comment afficher les durées à partir de l'instrumentation dans votre navigateur.
* Les crochets à l'intérieur du framework Rails pour l'instrumentation.
* Comment créer une implémentation d'instrumentation personnalisée.

--------------------------------------------------------------------------------

Introduction à l'instrumentation
-------------------------------

L'API d'instrumentation fournie par Active Support permet aux développeurs de fournir des crochets auxquels d'autres développeurs peuvent se connecter. Il y en a [plusieurs](#rails-framework-hooks) dans le framework Rails. Avec cette API, les développeurs peuvent choisir d'être notifiés lorsque certains événements se produisent à l'intérieur de leur application ou d'un autre morceau de code Ruby.

Par exemple, il y a [un crochet](#sql-active-record) fourni dans Active Record qui est appelé à chaque fois qu'Active Record utilise une requête SQL sur une base de données. Ce crochet pourrait être **abonné** et utilisé pour suivre le nombre de requêtes pendant une certaine action. Il y a [un autre crochet](#process-action-action-controller) autour du traitement d'une action d'un contrôleur. Cela pourrait être utilisé, par exemple, pour suivre la durée d'une action spécifique.

Vous pouvez même [créer vos propres événements](#creating-custom-events) à l'intérieur de votre application auxquels vous pourrez vous abonner ultérieurement.

S'abonner à un événement
-----------------------

S'abonner à un événement est facile. Utilisez [`ActiveSupport::Notifications.subscribe`][] avec un bloc pour écouter toute notification.

Le bloc reçoit les arguments suivants :

* Nom de l'événement
* Heure de début
* Heure de fin
* Un identifiant unique pour l'instrument qui a déclenché l'événement
* Les données pour l'événement

```ruby
ActiveSupport::Notifications.subscribe "process_action.action_controller" do |name, started, finished, unique_id, data|
  # votre propre code personnalisé
  Rails.logger.info "#{name} Reçu ! (début : #{started}, fin : #{finished})" # process_action.action_controller Reçu (début : 2019-05-05 13:43:57 -0800, fin : 2019-05-05 13:43:58 -0800)
end
```

Si vous êtes préoccupé par l'exactitude de `started` et `finished` pour calculer un temps écoulé précis, utilisez [`ActiveSupport::Notifications.monotonic_subscribe`][]. Le bloc donné recevra les mêmes arguments que ci-dessus, mais `started` et `finished` auront des valeurs avec un temps monotone précis au lieu du temps du calendrier.

```ruby
ActiveSupport::Notifications.monotonic_subscribe "process_action.action_controller" do |name, started, finished, unique_id, data|
  # votre propre code personnalisé
  Rails.logger.info "#{name} Reçu ! (début : #{started}, fin : #{finished})" # process_action.action_controller Reçu (début : 1560978.425334, fin : 1560979.429234)
end
```

Définir tous ces arguments de bloc à chaque fois peut être fastidieux. Vous pouvez facilement créer un [`ActiveSupport::Notifications::Event`][]
à partir des arguments de bloc comme ceci :

```ruby
ActiveSupport::Notifications.subscribe "process_action.action_controller" do |*args|
  event = ActiveSupport::Notifications::Event.new(*args)

  event.name      # => "process_action.action_controller"
  event.duration  # => 10 (en millisecondes)
  event.payload   # => {:extra=>information}

  Rails.logger.info "#{event} Reçu !"
end
```

Vous pouvez également passer un bloc qui n'accepte qu'un seul argument, et il recevra un objet événement :

```ruby
ActiveSupport::Notifications.subscribe "process_action.action_controller" do |event|
  event.name      # => "process_action.action_controller"
  event.duration  # => 10 (en millisecondes)
  event.payload   # => {:extra=>information}

  Rails.logger.info "#{event} Reçu !"
end
```

Vous pouvez également vous abonner à des événements correspondant à une expression régulière. Cela vous permet de vous abonner à
plusieurs événements à la fois. Voici comment vous abonner à tout ce qui concerne `ActionController` :

```ruby
ActiveSupport::Notifications.subscribe(/action_controller/) do |*args|
  # inspecter tous les événements ActionController
end
```


Afficher les durées de l'instrumentation dans votre navigateur
-------------------------------------------------------------

Rails implémente la norme [Server Timing](https://www.w3.org/TR/server-timing/) pour rendre les informations de durée disponibles dans le navigateur web. Pour l'activer, modifiez votre configuration d'environnement (généralement `development.rb` car c'est le plus utilisé en développement) pour inclure ce qui suit :

```ruby
  config.server_timing = true
```

Une fois configuré (y compris le redémarrage de votre serveur), vous pouvez accéder au volet Outils de développement de votre navigateur, puis sélectionner Réseau et recharger votre page. Vous pouvez ensuite sélectionner n'importe quelle requête vers votre serveur Rails, et vous verrez les durées du serveur dans l'onglet des durées. Pour un exemple de cela, consultez la [documentation Firefox](https://firefox-source-docs.mozilla.org/devtools-user/network_monitor/request_details/index.html#server-timing).

Crochets du framework Rails
---------------------------

Dans le framework Ruby on Rails, plusieurs crochets sont fournis pour des événements courants. Ces événements et leurs charges utiles sont détaillés ci-dessous.
### Action Controller

#### `start_processing.action_controller`

| Clé           | Valeur                                                     |
| ------------- | --------------------------------------------------------- |
| `:controller` | Le nom du contrôleur                                       |
| `:action`     | L'action                                                   |
| `:params`     | Hash des paramètres de la requête sans aucun paramètre filtré |
| `:headers`    | En-têtes de la requête                                     |
| `:format`     | html/js/json/xml etc                                      |
| `:method`     | Verbe de la requête HTTP                                  |
| `:path`       | Chemin de la requête                                       |

```ruby
{
  controller: "PostsController",
  action: "new",
  params: { "action" => "new", "controller" => "posts" },
  headers: #<ActionDispatch::Http::Headers:0x0055a67a519b88>,
  format: :html,
  method: "GET",
  path: "/posts/new"
}
```

#### `process_action.action_controller`

| Clé             | Valeur                                                     |
| --------------- | --------------------------------------------------------- |
| `:controller`   | Le nom du contrôleur                                       |
| `:action`       | L'action                                                   |
| `:params`       | Hash des paramètres de la requête sans aucun paramètre filtré |
| `:headers`      | En-têtes de la requête                                     |
| `:format`       | html/js/json/xml etc                                      |
| `:method`       | Verbe de la requête HTTP                                  |
| `:path`         | Chemin de la requête                                       |
| `:request`      | L'objet [`ActionDispatch::Request`][]                       |
| `:response`     | L'objet [`ActionDispatch::Response`][]                      |
| `:status`       | Code de statut HTTP                                        |
| `:view_runtime` | Temps passé dans la vue en ms                              |
| `:db_runtime`   | Temps passé à exécuter les requêtes de la base de données en ms |

```ruby
{
  controller: "PostsController",
  action: "index",
  params: {"action" => "index", "controller" => "posts"},
  headers: #<ActionDispatch::Http::Headers:0x0055a67a519b88>,
  format: :html,
  method: "GET",
  path: "/posts",
  request: #<ActionDispatch::Request:0x00007ff1cb9bd7b8>,
  response: #<ActionDispatch::Response:0x00007f8521841ec8>,
  status: 200,
  view_runtime: 46.848,
  db_runtime: 0.157
}
```

#### `send_file.action_controller`

| Clé     | Valeur                     |
| ------- | ------------------------- |
| `:path` | Chemin complet vers le fichier |

Des clés supplémentaires peuvent être ajoutées par l'appelant.

#### `send_data.action_controller`

`ActionController` n'ajoute aucune information spécifique à la charge utile. Toutes les options sont transmises à la charge utile.

#### `redirect_to.action_controller`

| Clé         | Valeur                                    |
| ----------- | ---------------------------------------- |
| `:status`   | Code de réponse HTTP                      |
| `:location` | URL de redirection                        |
| `:request`  | L'objet [`ActionDispatch::Request`][]      |

```ruby
{
  status: 302,
  location: "http://localhost:3000/posts/new",
  request: <ActionDispatch::Request:0x00007ff1cb9bd7b8>
}
```

#### `halted_callback.action_controller`

| Clé       | Valeur                         |
| --------- | ----------------------------- |
| `:filter` | Filtre qui a interrompu l'action |

```ruby
{
  filter: ":halting_filter"
}
```

#### `unpermitted_parameters.action_controller`

| Clé           | Valeur                                                                         |
| ------------- | ----------------------------------------------------------------------------- |
| `:keys`       | Les clés non autorisées                                                          |
| `:context`    | Hash avec les clés suivantes : `:controller`, `:action`, `:params`, `:request` |

### Action Controller — Caching

#### `write_fragment.action_controller`

| Clé    | Valeur            |
| ------ | ---------------- |
| `:key` | La clé complète |

```ruby
{
  key: 'posts/1-dashboard-view'
}
```

#### `read_fragment.action_controller`

| Clé    | Valeur            |
| ------ | ---------------- |
| `:key` | La clé complète |

```ruby
{
  key: 'posts/1-dashboard-view'
}
```

#### `expire_fragment.action_controller`

| Clé    | Valeur            |
| ------ | ---------------- |
| `:key` | La clé complète |

```ruby
{
  key: 'posts/1-dashboard-view'
}
```

#### `exist_fragment?.action_controller`

| Clé    | Valeur            |
| ------ | ---------------- |
| `:key` | La clé complète |

```ruby
{
  key: 'posts/1-dashboard-view'
}
```

### Action Dispatch

#### `process_middleware.action_dispatch`

| Clé           | Valeur                  |
| ------------- | ---------------------- |
| `:middleware` | Nom du middleware |

#### `redirect.action_dispatch`

| Clé         | Valeur                                    |
| ----------- | ---------------------------------------- |
| `:status`   | Code de réponse HTTP                      |
| `:location` | URL de redirection                        |
| `:request`  | L'objet [`ActionDispatch::Request`][]      |

#### `request.action_dispatch`

| Clé         | Valeur                                    |
| ----------- | ---------------------------------------- |
| `:request`  | L'objet [`ActionDispatch::Request`][]      |

### Action View

#### `render_template.action_view`

| Clé           | Valeur                              |
| ------------- | ---------------------------------- |
| `:identifier` | Chemin complet vers le modèle      |
| `:layout`     | Mise en page applicable             |
| `:locals`     | Variables locales passées au modèle |

```ruby
{
  identifier: "/Users/adam/projects/notifications/app/views/posts/index.html.erb",
  layout: "layouts/application",
  locals: { foo: "bar" }
}
```

#### `render_partial.action_view`

| Clé           | Valeur                              |
| ------------- | ---------------------------------- |
| `:identifier` | Chemin complet vers le modèle      |
| `:locals`     | Variables locales passées au modèle |

```ruby
{
  identifier: "/Users/adam/projects/notifications/app/views/posts/_form.html.erb",
  locals: { foo: "bar" }
}
```

#### `render_collection.action_view`

| Clé           | Valeur                                 |
| ------------- | ------------------------------------- |
| `:identifier` | Chemin complet vers le modèle         |
| `:count`      | Taille de la collection               |
| `:cache_hits` | Nombre de partiels récupérés du cache |

La clé `:cache_hits` est incluse uniquement si la collection est rendue avec `cached: true`.
```ruby
{
  identifier: "/Users/adam/projects/notifications/app/views/posts/_post.html.erb",
  count: 3,
  cache_hits: 0
}
```

#### `render_layout.action_view`

| Clé           | Valeur                 |
| ------------- | --------------------- |
| `:identifier` | Chemin complet du modèle |


```ruby
{
  identifier: "/Users/adam/projects/notifications/app/views/layouts/application.html.erb"
}
```


### Active Record

#### `sql.active_record`

| Clé                  | Valeur                                    |
| -------------------- | ---------------------------------------- |
| `:sql`               | Requête SQL                            |
| `:name`              | Nom de l'opération                    |
| `:connection`        | Objet de connexion                        |
| `:binds`             | Paramètres de liaison                          |
| `:type_casted_binds` | Paramètres de liaison convertis en types               |
| `:statement_name`    | Nom de la requête SQL                       |
| `:cached`            | `true` est ajouté lorsque des requêtes mises en cache sont utilisées |

Les adaptateurs peuvent également ajouter leurs propres données.

```ruby
{
  sql: "SELECT \"posts\".* FROM \"posts\" ",
  name: "Post Load",
  connection: <ActiveRecord::ConnectionAdapters::SQLite3Adapter:0x00007f9f7a838850>,
  binds: [<ActiveModel::Attribute::WithCastValue:0x00007fe19d15dc00>],
  type_casted_binds: [11],
  statement_name: nil
}
```

#### `strict_loading_violation.active_record`

Cet événement est émis uniquement lorsque [`config.active_record.action_on_strict_loading_violation`][] est défini sur `:log`.

| Clé           | Valeur                                            |
| ------------- | ------------------------------------------------ |
| `:owner`      | Modèle avec `strict_loading` activé              |
| `:reflection` | Réflexion de l'association qui a tenté de charger |


#### `instantiation.active_record`

| Clé              | Valeur                                     |
| ---------------- | ----------------------------------------- |
| `:record_count`  | Nombre d'enregistrements instanciés       |
| `:class_name`    | Classe de l'enregistrement                            |

```ruby
{
  record_count: 1,
  class_name: "User"
}
```

### Action Mailer

#### `deliver.action_mailer`

| Clé                   | Valeur                                                |
| --------------------- | ---------------------------------------------------- |
| `:mailer`             | Nom de la classe du mailer                             |
| `:message_id`         | ID du message, généré par la gem Mail         |
| `:subject`            | Sujet du mail                                  |
| `:to`                 | Adresse(s) de destination du mail                           |
| `:from`               | Adresse d'expéditeur du mail                             |
| `:bcc`                | Adresses BCC du mail                            |
| `:cc`                 | Adresses CC du mail                             |
| `:date`               | Date du mail                                     |
| `:mail`               | La forme encodée du mail                         |
| `:perform_deliveries` | Si la livraison de ce message est effectuée ou non |

```ruby
{
  mailer: "Notification",
  message_id: "4f5b5491f1774_181b23fc3d4434d38138e5@mba.local.mail",
  subject: "Rails Guides",
  to: ["users@rails.com", "dhh@rails.com"],
  from: ["me@rails.com"],
  date: Sat, 10 Mar 2012 14:18:09 +0100,
  mail: "...", # omis pour plus de concision
  perform_deliveries: true
}
```

#### `process.action_mailer`

| Clé           | Valeur                    |
| ------------- | ------------------------ |
| `:mailer`     | Nom de la classe du mailer |
| `:action`     | L'action               |
| `:args`       | Les arguments            |

```ruby
{
  mailer: "Notification",
  action: "welcome_email",
  args: []
}
```

### Active Support — Caching

#### `cache_read.active_support`

| Clé                | Valeur                   |
| ------------------ | ----------------------- |
| `:key`             | Clé utilisée dans le store   |
| `:store`           | Nom de la classe du store |
| `:hit`             | Si cette lecture est un succès   |
| `:super_operation` | `:fetch` si une lecture est effectuée avec [`fetch`][ActiveSupport::Cache::Store#fetch] |

#### `cache_read_multi.active_support`

| Clé                | Valeur                   |
| ------------------ | ----------------------- |
| `:key`             | Clés utilisées dans le store  |
| `:store`           | Nom de la classe du store |
| `:hits`            | Clés des lectures réussies      |
| `:super_operation` | `:fetch_multi` si une lecture est effectuée avec [`fetch_multi`][ActiveSupport::Cache::Store#fetch_multi] |

#### `cache_generate.active_support`

Cet événement est émis uniquement lorsque [`fetch`][ActiveSupport::Cache::Store#fetch] est appelé avec un bloc.

| Clé      | Valeur                   |
| -------- | ----------------------- |
| `:key`   | Clé utilisée dans le store   |
| `:store` | Nom de la classe du store |

Les options passées à `fetch` seront fusionnées avec la charge utile lors de l'écriture dans le store.

```ruby
{
  key: "name-of-complicated-computation",
  store: "ActiveSupport::Cache::MemCacheStore"
}
```

#### `cache_fetch_hit.active_support`

Cet événement est émis uniquement lorsque [`fetch`][ActiveSupport::Cache::Store#fetch] est appelé avec un bloc.

| Clé      | Valeur                   |
| -------- | ----------------------- |
| `:key`   | Clé utilisée dans le store   |
| `:store` | Nom de la classe du store |

Les options passées à `fetch` seront fusionnées avec la charge utile.

```ruby
{
  key: "name-of-complicated-computation",
  store: "ActiveSupport::Cache::MemCacheStore"
}
```

#### `cache_write.active_support`

| Clé      | Valeur                   |
| -------- | ----------------------- |
| `:key`   | Clé utilisée dans le store   |
| `:store` | Nom de la classe du store |

Les stores de cache peuvent également ajouter leurs propres données.

```ruby
{
  key: "name-of-complicated-computation",
  store: "ActiveSupport::Cache::MemCacheStore"
}
```

#### `cache_write_multi.active_support`

| Clé      | Valeur                                |
| -------- | ------------------------------------ |
| `:key`   | Clés et valeurs écrites dans le store |
| `:store` | Nom de la classe du store              |
#### `cache_increment.active_support`

Cet événement est émis uniquement lors de l'utilisation de [`MemCacheStore`][ActiveSupport::Cache::MemCacheStore]
ou [`RedisCacheStore`][ActiveSupport::Cache::RedisCacheStore].

| Clé       | Valeur                      |
| --------- | -------------------------- |
| `:key`    | Clé utilisée dans le store |
| `:store`  | Nom de la classe du store  |
| `:amount` | Montant de l'incrément     |

```ruby
{
  key: "bottles-of-beer",
  store: "ActiveSupport::Cache::RedisCacheStore",
  amount: 99
}
```

#### `cache_decrement.active_support`

Cet événement est émis uniquement lors de l'utilisation des stores de cache Memcached ou Redis.

| Clé       | Valeur                      |
| --------- | -------------------------- |
| `:key`    | Clé utilisée dans le store |
| `:store`  | Nom de la classe du store  |
| `:amount` | Montant du décrément       |

```ruby
{
  key: "bottles-of-beer",
  store: "ActiveSupport::Cache::RedisCacheStore",
  amount: 1
}
```

#### `cache_delete.active_support`

| Clé      | Valeur                      |
| -------- | -------------------------- |
| `:key`   | Clé utilisée dans le store |
| `:store` | Nom de la classe du store  |

```ruby
{
  key: "name-of-complicated-computation",
  store: "ActiveSupport::Cache::MemCacheStore"
}
```

#### `cache_delete_multi.active_support`

| Clé      | Valeur                      |
| -------- | -------------------------- |
| `:key`   | Clés utilisées dans le store |
| `:store` | Nom de la classe du store  |

#### `cache_delete_matched.active_support`

Cet événement est émis uniquement lors de l'utilisation de [`RedisCacheStore`][ActiveSupport::Cache::RedisCacheStore],
[`FileStore`][ActiveSupport::Cache::FileStore] ou [`MemoryStore`][ActiveSupport::Cache::MemoryStore].

| Clé      | Valeur                      |
| -------- | -------------------------- |
| `:key`   | Motif de clé utilisé       |
| `:store` | Nom de la classe du store  |

```ruby
{
  key: "posts/*",
  store: "ActiveSupport::Cache::RedisCacheStore"
}
```

#### `cache_cleanup.active_support`

Cet événement est émis uniquement lors de l'utilisation de [`MemoryStore`][ActiveSupport::Cache::MemoryStore].

| Clé      | Valeur                                               |
| -------- | --------------------------------------------------- |
| `:store` | Nom de la classe du store                            |
| `:size`  | Nombre d'entrées dans le cache avant le nettoyage    |

```ruby
{
  store: "ActiveSupport::Cache::MemoryStore",
  size: 9001
}
```

#### `cache_prune.active_support`

Cet événement est émis uniquement lors de l'utilisation de [`MemoryStore`][ActiveSupport::Cache::MemoryStore].

| Clé      | Valeur                                               |
| -------- | --------------------------------------------------- |
| `:store` | Nom de la classe du store                            |
| `:key`   | Taille cible (en octets) pour le cache               |
| `:from`  | Taille (en octets) du cache avant l'élagage          |

```ruby
{
  store: "ActiveSupport::Cache::MemoryStore",
  key: 5000,
  from: 9001
}
```

#### `cache_exist?.active_support`

| Clé      | Valeur                      |
| -------- | -------------------------- |
| `:key`   | Clé utilisée dans le store |
| `:store` | Nom de la classe du store  |

```ruby
{
  key: "name-of-complicated-computation",
  store: "ActiveSupport::Cache::MemCacheStore"
}
```


### Active Support — Messages

#### `message_serializer_fallback.active_support`

| Clé             | Valeur                                |
| --------------- | ------------------------------------ |
| `:serializer`   | Serializer principal (prévu)          |
| `:fallback`     | Serializer de secours (réel)          |
| `:serialized`   | Chaîne sérialisée                    |
| `:deserialized` | Valeur désérialisée                  |

```ruby
{
  serializer: :json_allow_marshal,
  fallback: :marshal,
  serialized: "\x04\b{\x06I\"\nHello\x06:\x06ETI\"\nWorld\x06;\x00T",
  deserialized: { "Hello" => "World" },
}
```

### Active Job

#### `enqueue_at.active_job`

| Clé          | Valeur                                         |
| ------------ | --------------------------------------------- |
| `:adapter`   | Objet QueueAdapter traitant le job             |
| `:job`       | Objet Job                                     |

#### `enqueue.active_job`

| Clé          | Valeur                                         |
| ------------ | --------------------------------------------- |
| `:adapter`   | Objet QueueAdapter traitant le job             |
| `:job`       | Objet Job                                     |

#### `enqueue_retry.active_job`

| Clé          | Valeur                                         |
| ------------ | --------------------------------------------- |
| `:job`       | Objet Job                                     |
| `:adapter`   | Objet QueueAdapter traitant le job             |
| `:error`     | L'erreur qui a provoqué la nouvelle tentative |
| `:wait`      | Le délai de la nouvelle tentative              |

#### `enqueue_all.active_job`

| Clé          | Valeur                                         |
| ------------ | --------------------------------------------- |
| `:adapter`   | Objet QueueAdapter traitant le job             |
| `:jobs`      | Un tableau d'objets Job                        |

#### `perform_start.active_job`

| Clé          | Valeur                                         |
| ------------ | --------------------------------------------- |
| `:adapter`   | Objet QueueAdapter traitant le job             |
| `:job`       | Objet Job                                     |

#### `perform.active_job`

| Clé           | Valeur                                                 |
| ------------- | ----------------------------------------------------- |
| `:adapter`    | Objet QueueAdapter traitant le job                     |
| `:job`        | Objet Job                                             |
| `:db_runtime` | Temps passé à exécuter des requêtes de base de données en ms |

#### `retry_stopped.active_job`

| Clé          | Valeur                                         |
| ------------ | --------------------------------------------- |
| `:adapter`   | Objet QueueAdapter traitant le job             |
| `:job`       | Objet Job                                     |
| `:error`     | L'erreur qui a provoqué la nouvelle tentative |

#### `discard.active_job`

| Clé          | Valeur                                         |
| ------------ | --------------------------------------------- |
| `:adapter`   | Objet QueueAdapter traitant le job             |
| `:job`       | Objet Job                                     |
| `:error`     | L'erreur qui a provoqué l'abandon               |
### Action Cable

#### `perform_action.action_cable`

| Clé              | Valeur                     |
| ---------------- | ------------------------- |
| `:channel_class` | Nom de la classe de canal |
| `:action`        | L'action                |
| `:data`          | Un hash de données            |

#### `transmit.action_cable`

| Clé              | Valeur                     |
| ---------------- | ------------------------- |
| `:channel_class` | Nom de la classe de canal |
| `:data`          | Un hash de données            |
| `:via`           | Via                       |

#### `transmit_subscription_confirmation.action_cable`

| Clé              | Valeur                     |
| ---------------- | ------------------------- |
| `:channel_class` | Nom de la classe de canal |

#### `transmit_subscription_rejection.action_cable`

| Clé              | Valeur                     |
| ---------------- | ------------------------- |
| `:channel_class` | Nom de la classe de canal |

#### `broadcast.action_cable`

| Clé             | Valeur                |
| --------------- | -------------------- |
| `:broadcasting` | Une diffusion nommée |
| `:message`      | Un hash de message    |
| `:coder`        | Le codeur            |

### Active Storage

#### `preview.active_storage`

| Clé          | Valeur               |
| ------------ | ------------------- |
| `:key`       | Jeton sécurisé        |

#### `transform.active_storage`

#### `analyze.active_storage`

| Clé          | Valeur                          |
| ------------ | ------------------------------ |
| `:analyzer`  | Nom de l'analyseur, par exemple ffprobe |

### Active Storage — Service de stockage

#### `service_upload.active_storage`

| Clé          | Valeur                        |
| ------------ | ---------------------------- |
| `:key`       | Jeton sécurisé                 |
| `:service`   | Nom du service          |
| `:checksum`  | Checksum pour assurer l'intégrité |

#### `service_streaming_download.active_storage`

| Clé          | Valeur               |
| ------------ | ------------------- |
| `:key`       | Jeton sécurisé        |
| `:service`   | Nom du service |

#### `service_download_chunk.active_storage`

| Clé          | Valeur                           |
| ------------ | ------------------------------- |
| `:key`       | Jeton sécurisé                    |
| `:service`   | Nom du service             |
| `:range`     | Plage de bytes tentée à lire |

#### `service_download.active_storage`

| Clé          | Valeur               |
| ------------ | ------------------- |
| `:key`       | Jeton sécurisé        |
| `:service`   | Nom du service |

#### `service_delete.active_storage`

| Clé          | Valeur               |
| ------------ | ------------------- |
| `:key`       | Jeton sécurisé        |
| `:service`   | Nom du service |

#### `service_delete_prefixed.active_storage`

| Clé          | Valeur               |
| ------------ | ------------------- |
| `:prefix`    | Préfixe de clé          |
| `:service`   | Nom du service |

#### `service_exist.active_storage`

| Clé          | Valeur                       |
| ------------ | --------------------------- |
| `:key`       | Jeton sécurisé                |
| `:service`   | Nom du service         |
| `:exist`     | Fichier ou blob existe ou non  |

#### `service_url.active_storage`

| Clé          | Valeur               |
| ------------ | ------------------- |
| `:key`       | Jeton sécurisé        |
| `:service`   | Nom du service |
| `:url`       | URL générée       |

#### `service_update_metadata.active_storage`

Cet événement est émis uniquement lors de l'utilisation du service Google Cloud Storage.

| Clé             | Valeur                            |
| --------------- | -------------------------------- |
| `:key`          | Jeton sécurisé                     |
| `:service`      | Nom du service              |
| `:content_type` | Champ HTTP `Content-Type`        |
| `:disposition`  | Champ HTTP `Content-Disposition` |

### Action Mailbox

#### `process.action_mailbox`

| Clé              | Valeur                                                  |
| -----------------| ------------------------------------------------------ |
| `:mailbox`       | Instance de la classe Mailbox héritant de [`ActionMailbox::Base`][] |
| `:inbound_email` | Hash avec des données sur l'e-mail entrant en cours de traitement |

```ruby
{
  mailbox: #<RepliesMailbox:0x00007f9f7a8388>,
  inbound_email: {
    id: 1,
    message_id: "0CB459E0-0336-41DA-BC88-E6E28C697DDB@37signals.com",
    status: "processing"
  }
}
```


### Railties

#### `load_config_initializer.railties`

| Clé            | Valeur                                               |
| -------------- | --------------------------------------------------- |
| `:initializer` | Chemin de l'initialiseur chargé dans `config/initializers` |

### Rails

#### `deprecation.rails`

| Clé                    | Valeur                                                 |
| ---------------------- | ------------------------------------------------------|
| `:message`             | L'avertissement de dépréciation                        |
| `:callstack`           | D'où provient la dépréciation                          |
| `:gem_name`            | Nom de la gemme signalant la dépréciation              |
| `:deprecation_horizon` | Version où le comportement déprécié sera supprimé      |

Exceptions
----------

Si une exception se produit pendant une instrumentation, la charge utile inclura
des informations à ce sujet.

| Clé                 | Valeur                                                          |
| ------------------- | -------------------------------------------------------------- |
| `:exception`        | Un tableau de deux éléments. Nom de la classe de l'exception et le message |
| `:exception_object` | L'objet d'exception                                           |

Création d'événements personnalisés
----------------------

Ajouter vos propres événements est également facile. Active Support s'occupera de
tout le travail lourd pour vous. Il suffit d'appeler [`ActiveSupport::Notifications.instrument`][] avec un `name`, `payload` et un bloc.
La notification sera envoyée après que le bloc se termine. Active Support générera les temps de début et de fin,
et ajoutera l'ID unique de l'instrumenteur. Toutes les données transmises à l'appel `instrument` feront
partie de la charge utile.
Voici un exemple :

```ruby
ActiveSupport::Notifications.instrument "my.custom.event", this: :data do
  # effectuez vos actions personnalisées ici
end
```

Maintenant, vous pouvez écouter cet événement avec :

```ruby
ActiveSupport::Notifications.subscribe "my.custom.event" do |name, started, finished, unique_id, data|
  puts data.inspect # {:this=>:data}
end
```

Vous pouvez également appeler `instrument` sans passer de bloc. Cela vous permet d'utiliser l'infrastructure d'instrumentation pour d'autres utilisations de messagerie.

```ruby
ActiveSupport::Notifications.instrument "my.custom.event", this: :data

ActiveSupport::Notifications.subscribe "my.custom.event" do |name, started, finished, unique_id, data|
  puts data.inspect # {:this=>:data}
end
```

Vous devez suivre les conventions de Rails lors de la définition de vos propres événements. Le format est : `event.library`. Si votre application envoie des tweets, vous devez créer un événement nommé `tweet.twitter`.
[`ActiveSupport::Notifications::Event`]: https://api.rubyonrails.org/classes/ActiveSupport/Notifications/Event.html
[`ActiveSupport::Notifications.monotonic_subscribe`]: https://api.rubyonrails.org/classes/ActiveSupport/Notifications.html#method-c-monotonic_subscribe
[`ActiveSupport::Notifications.subscribe`]: https://api.rubyonrails.org/classes/ActiveSupport/Notifications.html#method-c-subscribe
[`ActionDispatch::Request`]: https://api.rubyonrails.org/classes/ActionDispatch/Request.html
[`ActionDispatch::Response`]: https://api.rubyonrails.org/classes/ActionDispatch/Response.html
[`config.active_record.action_on_strict_loading_violation`]: configuring.html#config-active-record-action-on-strict-loading-violation
[ActiveSupport::Cache::FileStore]: https://api.rubyonrails.org/classes/ActiveSupport/Cache/FileStore.html
[ActiveSupport::Cache::MemCacheStore]: https://api.rubyonrails.org/classes/ActiveSupport/Cache/MemCacheStore.html
[ActiveSupport::Cache::MemoryStore]: https://api.rubyonrails.org/classes/ActiveSupport/Cache/MemoryStore.html
[ActiveSupport::Cache::RedisCacheStore]: https://api.rubyonrails.org/classes/ActiveSupport/Cache/RedisCacheStore.html
[ActiveSupport::Cache::Store#fetch]: https://api.rubyonrails.org/classes/ActiveSupport/Cache/Store.html#method-i-fetch
[ActiveSupport::Cache::Store#fetch_multi]: https://api.rubyonrails.org/classes/ActiveSupport/Cache/Store.html#method-i-fetch_multi
[`ActionMailbox::Base`]: https://api.rubyonrails.org/classes/ActionMailbox/Base.html
[`ActiveSupport::Notifications.instrument`]: https://api.rubyonrails.org/classes/ActiveSupport/Notifications.html#method-c-instrument
