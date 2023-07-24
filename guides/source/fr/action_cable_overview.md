**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 4f7308fdab05dc13d399bde6a8ac302c
Aperçu d'Action Cable
=====================

Dans ce guide, vous apprendrez comment fonctionne Action Cable et comment utiliser les WebSockets pour intégrer des fonctionnalités en temps réel dans votre application Rails.

Après avoir lu ce guide, vous saurez :

* Ce qu'est Action Cable et son intégration backend et frontend
* Comment configurer Action Cable
* Comment configurer des canaux
* Le déploiement et la configuration de l'architecture pour exécuter Action Cable

--------------------------------------------------------------------------------

Qu'est-ce qu'Action Cable ?
---------------------------

Action Cable intègre de manière transparente les [WebSockets](https://en.wikipedia.org/wiki/WebSocket) avec le reste de votre application Rails. Il permet d'écrire des fonctionnalités en temps réel en Ruby, dans le même style et la même forme que le reste de votre application Rails, tout en étant performant et scalable. C'est une offre complète qui fournit à la fois un framework JavaScript côté client et un framework Ruby côté serveur. Vous avez accès à l'ensemble de votre modèle de domaine écrit avec Active Record ou votre ORM de choix.

Terminologie
-----------

Action Cable utilise les WebSockets au lieu du protocole de requête-réponse HTTP. Tant Action Cable que les WebSockets introduisent une terminologie moins familière :

### Connexions

*Les connexions* constituent la base de la relation client-serveur. Un seul serveur Action Cable peut gérer plusieurs instances de connexion. Il a une instance de connexion par connexion WebSocket. Un utilisateur unique peut avoir plusieurs WebSockets ouverts vers votre application s'il utilise plusieurs onglets de navigateur ou appareils.

### Consommateurs

Le client d'une connexion WebSocket est appelé le *consommateur*. Dans Action Cable, le consommateur est créé par le framework JavaScript côté client.

### Canaux

Chaque consommateur peut, à son tour, s'abonner à plusieurs *canaux*. Chaque canal encapsule une unité logique de travail, similaire à ce qu'un contrôleur fait dans une configuration MVC typique. Par exemple, vous pourriez avoir un `ChatChannel` et un `AppearancesChannel`, et un consommateur pourrait être abonné à l'un ou aux deux de ces canaux. Au minimum, un consommateur devrait être abonné à un canal.

### Abonnés

Lorsque le consommateur est abonné à un canal, il agit en tant qu'*abonné*. La connexion entre l'abonné et le canal est, sans surprise, appelée une souscription. Un consommateur peut agir en tant qu'abonné à un canal donné un nombre illimité de fois. Par exemple, un consommateur pourrait s'abonner à plusieurs salles de discussion en même temps. (Et n'oubliez pas qu'un utilisateur physique peut avoir plusieurs consommateurs, un par onglet/appareil ouvert sur votre connexion).

### Pub/Sub

[Pub/Sub](https://en.wikipedia.org/wiki/Publish%E2%80%93subscribe_pattern) ou Publish-Subscribe fait référence à un paradigme de file d'attente de messages où les expéditeurs d'informations (éditeurs) envoient des données à une classe abstraite de destinataires (abonnés), sans spécifier les destinataires individuels. Action Cable utilise cette approche pour communiquer entre le serveur et de nombreux clients.

### Diffusion

Une diffusion est un lien pub/sub où tout ce qui est transmis par le diffuseur est envoyé directement aux abonnés du canal qui diffusent cette diffusion nommée. Chaque canal peut diffuser zéro ou plusieurs diffusions.

## Composants côté serveur

### Connexions

Pour chaque WebSocket accepté par le serveur, un objet de connexion est instancié. Cet objet devient le parent de toutes les *souscriptions de canal* qui sont créées à partir de là. La connexion elle-même ne traite aucune logique d'application spécifique, en dehors de l'authentification et de l'autorisation. Le client d'une connexion WebSocket est appelé le *consommateur* de la connexion. Un utilisateur individuel créera une paire consommateur-connexion par onglet de navigateur, fenêtre ou appareil qu'il a ouvert.

Les connexions sont des instances de `ApplicationCable::Connection`, qui étend [`ActionCable::Connection::Base`][]. Dans `ApplicationCable::Connection`, vous autorisez la connexion entrante et procédez à son établissement si l'utilisateur peut être identifié.

#### Configuration de la connexion

```ruby
# app/channels/application_cable/connection.rb
module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_user

    def connect
      self.current_user = find_verified_user
    end

    private
      def find_verified_user
        if verified_user = User.find_by(id: cookies.encrypted[:user_id])
          verified_user
        else
          reject_unauthorized_connection
        end
      end
  end
end
```

Ici, [`identified_by`][] désigne un identifiant de connexion qui peut être utilisé pour retrouver la connexion spécifique ultérieurement. Notez que tout ce qui est marqué comme un identifiant créera automatiquement un délégué portant le même nom sur toutes les instances de canal créées à partir de la connexion.

Cet exemple repose sur le fait que vous avez déjà géré l'authentification de l'utilisateur ailleurs dans votre application, et qu'une authentification réussie définit un cookie chiffré avec l'ID de l'utilisateur.

Le cookie est ensuite automatiquement envoyé à l'instance de connexion lorsqu'une nouvelle connexion est tentée, et vous l'utilisez pour définir `current_user`. En identifiant la connexion par ce même utilisateur actuel, vous vous assurez également que vous pouvez récupérer ultérieurement toutes les connexions ouvertes par un utilisateur donné (et éventuellement les déconnecter toutes si l'utilisateur est supprimé ou non autorisé).
Si votre approche d'authentification inclut l'utilisation d'une session, vous utilisez le cookie store pour la session, votre cookie de session est nommé `_session` et la clé de l'ID utilisateur est `user_id`, vous pouvez utiliser cette approche :

```ruby
verified_user = User.find_by(id: cookies.encrypted['_session']['user_id'])
```


#### Gestion des exceptions

Par défaut, les exceptions non gérées sont capturées et enregistrées dans le journal de Rails. Si vous souhaitez intercepter ces exceptions de manière globale et les signaler à un service externe de suivi des bugs, par exemple, vous pouvez le faire avec [`rescue_from`][] :

```ruby
# app/channels/application_cable/connection.rb
module ApplicationCable
  class Connection < ActionCable::Connection::Base
    rescue_from StandardError, with: :report_error

    private
      def report_error(e)
        SomeExternalBugtrackingService.notify(e)
      end
  end
end
```


#### Rappels de connexion

Il existe des rappels `before_command`, `after_command` et `around_command` disponibles pour être invoqués avant, après ou autour de chaque commande reçue par un client respectivement.
Le terme "commande" ici fait référence à toute interaction reçue par un client (abonnement, désabonnement ou exécution d'actions) :

```ruby
# app/channels/application_cable/connection.rb
module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :user

    around_command :set_current_account

    private
      def set_current_account(&block)
        # Maintenant, tous les canaux peuvent utiliser Current.account
        Current.set(account: user.account, &block)
      end
  end
end
```

### Canaux

Un *canal* encapsule une unité logique de travail, similaire à ce qu'un contrôleur fait dans une configuration MVC typique. Par défaut, Rails crée une classe parente `ApplicationCable::Channel` (qui étend [`ActionCable::Channel::Base`][]) pour encapsuler la logique partagée entre vos canaux.

#### Configuration du canal parent

```ruby
# app/channels/application_cable/channel.rb
module ApplicationCable
  class Channel < ActionCable::Channel::Base
  end
end
```

Ensuite, vous pouvez créer vos propres classes de canal. Par exemple, vous pourriez avoir un `ChatChannel` et un `AppearanceChannel` :

```ruby
# app/channels/chat_channel.rb
class ChatChannel < ApplicationCable::Channel
end
```

```ruby
# app/channels/appearance_channel.rb
class AppearanceChannel < ApplicationCable::Channel
end
```


Un consommateur peut ensuite s'abonner à l'un ou aux deux de ces canaux.

#### Abonnements

Les consommateurs s'abonnent aux canaux, agissant en tant que *abonnés*. Leur connexion est appelée *abonnement*. Les messages produits sont ensuite routés vers ces abonnements de canal en fonction d'un identifiant envoyé par le consommateur de canal.

```ruby
# app/channels/chat_channel.rb
class ChatChannel < ApplicationCable::Channel
  # Appelé lorsque le consommateur est devenu avec succès un abonné de ce canal.
  def subscribed
  end
end
```

#### Gestion des exceptions

Comme avec `ApplicationCable::Connection`, vous pouvez également utiliser [`rescue_from`][] sur un canal spécifique pour gérer les exceptions levées :

```ruby
# app/channels/chat_channel.rb
class ChatChannel < ApplicationCable::Channel
  rescue_from 'MyError', with: :deliver_error_message

  private
    def deliver_error_message(e)
      broadcast_to(...)
    end
end
```

#### Rappels de canal

`ApplicationCable::Channel` fournit un certain nombre de rappels qui peuvent être utilisés pour déclencher une logique pendant le cycle de vie d'un canal. Les rappels disponibles sont :

- `before_subscribe`
- `after_subscribe` (alias : `on_subscribe`)
- `before_unsubscribe`
- `after_unsubscribe` (alias : `on_unsubscribe`)

REMARQUE : Le rappel `after_subscribe` est déclenché chaque fois que la méthode `subscribed` est appelée, même si l'abonnement a été rejeté avec la méthode `reject`. Pour déclencher `after_subscribe` uniquement lors d'abonnements réussis, utilisez `after_subscribe :send_welcome_message, unless: :subscription_rejected?`

```ruby
# app/channels/chat_channel.rb
class ChatChannel < ApplicationCable::Channel
  after_subscribe :send_welcome_message, unless: :subscription_rejected?
  after_subscribe :track_subscription

  private
    def send_welcome_message
      broadcast_to(...)
    end

    def track_subscription
      # ...
    end
end
```

## Composants côté client

### Connexions

Les consommateurs ont besoin d'une instance de la connexion de leur côté. Cela peut être établi en utilisant le JavaScript suivant, qui est généré par défaut par Rails :

#### Connecter le consommateur

```js
// app/javascript/channels/consumer.js
// Action Cable fournit le framework pour gérer les WebSockets dans Rails.
// Vous pouvez générer de nouveaux canaux où les fonctionnalités WebSocket sont disponibles en utilisant la commande `bin/rails generate channel`.

import { createConsumer } from "@rails/actioncable"

export default createConsumer()
```

Cela préparera un consommateur qui se connectera par défaut à `/cable` sur votre serveur. La connexion ne sera établie que lorsque vous aurez également spécifié au moins un abonnement qui vous intéresse.

Le consommateur peut éventuellement prendre un argument qui spécifie l'URL à laquelle se connecter. Cela peut être une chaîne de caractères ou une fonction qui renvoie une chaîne de caractères qui sera appelée lorsque le WebSocket est ouvert.

```js
// Spécifier une URL différente à laquelle se connecter
createConsumer('wss://example.com/cable')
// Ou lors de l'utilisation de websockets sur HTTP
createConsumer('https://ws.example.com/cable')

// Utiliser une fonction pour générer dynamiquement l'URL
createConsumer(getWebSocketURL)

function getWebSocketURL() {
  const token = localStorage.get('auth-token')
  return `wss://example.com/cable?token=${token}`
}
```

#### Abonné

Un consommateur devient un abonné en créant un abonnement à un canal donné :

```js
// app/javascript/channels/chat_channel.js
import consumer from "./consumer"

consumer.subscriptions.create({ channel: "ChatChannel", room: "Best Room" })

// app/javascript/channels/appearance_channel.js
import consumer from "./consumer"

consumer.subscriptions.create({ channel: "AppearanceChannel" })
```

Bien que cela crée l'abonnement, la fonctionnalité nécessaire pour répondre aux données reçues sera décrite ultérieurement.
Un consommateur peut agir en tant qu'abonné à un canal donné un nombre illimité de fois. Par exemple, un consommateur peut s'abonner à plusieurs salles de discussion en même temps :

```js
// app/javascript/channels/chat_channel.js
import consumer from "./consumer"

consumer.subscriptions.create({ channel: "ChatChannel", room: "1st Room" })
consumer.subscriptions.create({ channel: "ChatChannel", room: "2nd Room" })
```

## Interactions client-serveur

### Flux

Les *flux* fournissent le mécanisme par lequel les canaux routent le contenu publié (diffusions) vers leurs abonnés. Par exemple, le code suivant utilise [`stream_from`][] pour s'abonner à la diffusion nommée `chat_Best Room` lorsque la valeur du paramètre `:room` est `"Best Room"` :

```ruby
# app/channels/chat_channel.rb
class ChatChannel < ApplicationCable::Channel
  def subscribed
    stream_from "chat_#{params[:room]}"
  end
end
```

Ensuite, ailleurs dans votre application Rails, vous pouvez diffuser vers une telle salle en appelant [`broadcast`][] :

```ruby
ActionCable.server.broadcast("chat_Best Room", { body: "This Room is Best Room." })
```

Si vous avez un flux lié à un modèle, le nom de diffusion peut être généré à partir du canal et du modèle. Par exemple, le code suivant utilise [`stream_for`][] pour s'abonner à une diffusion comme `posts:Z2lkOi8vVGVzdEFwcC9Qb3N0LzE`, où `Z2lkOi8vVGVzdEFwcC9Qb3N0LzE` est le GlobalID du modèle Post.

```ruby
class PostsChannel < ApplicationCable::Channel
  def subscribed
    post = Post.find(params[:id])
    stream_for post
  end
end
```

Vous pouvez ensuite diffuser vers ce canal en appelant [`broadcast_to`][] :

```ruby
PostsChannel.broadcast_to(@post, @comment)
```


### Diffusions

Une *diffusion* est un lien pub/sub où tout ce qui est transmis par un éditeur est routé directement vers les abonnés du canal qui diffusent cette diffusion nommée. Chaque canal peut diffuser zéro ou plusieurs diffusions.

Les diffusions sont purement une file d'attente en ligne et dépendent du temps. Si un consommateur ne diffuse pas (abonné à un canal donné), il ne recevra pas la diffusion s'il se connecte ultérieurement.

### Abonnements

Lorsqu'un consommateur est abonné à un canal, il agit en tant qu'abonné. Cette connexion est appelée un abonnement. Les messages entrants sont ensuite routés vers ces abonnements de canal en fonction d'un identifiant envoyé par le consommateur de câble.

```js
// app/javascript/channels/chat_channel.js
import consumer from "./consumer"

consumer.subscriptions.create({ channel: "ChatChannel", room: "Best Room" }, {
  received(data) {
    this.appendLine(data)
  },

  appendLine(data) {
    const html = this.createLine(data)
    const element = document.querySelector("[data-chat-room='Best Room']")
    element.insertAdjacentHTML("beforeend", html)
  },

  createLine(data) {
    return `
      <article class="chat-line">
        <span class="speaker">${data["sent_by"]}</span>
        <span class="body">${data["body"]}</span>
      </article>
    `
  }
})
```

### Passage de paramètres aux canaux

Vous pouvez transmettre des paramètres du côté client au côté serveur lors de la création d'un abonnement. Par exemple :

```ruby
# app/channels/chat_channel.rb
class ChatChannel < ApplicationCable::Channel
  def subscribed
    stream_from "chat_#{params[:room]}"
  end
end
```

Un objet passé en tant que premier argument à `subscriptions.create` devient le hachage de paramètres dans le canal de câble. Le mot-clé `channel` est requis :

```js
// app/javascript/channels/chat_channel.js
import consumer from "./consumer"

consumer.subscriptions.create({ channel: "ChatChannel", room: "Best Room" }, {
  received(data) {
    this.appendLine(data)
  },

  appendLine(data) {
    const html = this.createLine(data)
    const element = document.querySelector("[data-chat-room='Best Room']")
    element.insertAdjacentHTML("beforeend", html)
  },

  createLine(data) {
    return `
      <article class="chat-line">
        <span class="speaker">${data["sent_by"]}</span>
        <span class="body">${data["body"]}</span>
      </article>
    `
  }
})
```

```ruby
# Quelque part dans votre application, cela est appelé, peut-être
# à partir d'un NewCommentJob.
ActionCable.server.broadcast(
  "chat_#{room}",
  {
    sent_by: 'Paul',
    body: 'This is a cool chat app.'
  }
)
```

### Rebroadcast d'un message

Un cas d'utilisation courant est de *rebroadcast* un message envoyé par un client à tous les autres clients connectés.

```ruby
# app/channels/chat_channel.rb
class ChatChannel < ApplicationCable::Channel
  def subscribed
    stream_from "chat_#{params[:room]}"
  end

  def receive(data)
    ActionCable.server.broadcast("chat_#{params[:room]}", data)
  end
end
```

```js
// app/javascript/channels/chat_channel.js
import consumer from "./consumer"

const chatChannel = consumer.subscriptions.create({ channel: "ChatChannel", room: "Best Room" }, {
  received(data) {
    // data => { sent_by: "Paul", body: "This is a cool chat app." }
  }
}

chatChannel.send({ sent_by: "Paul", body: "This is a cool chat app." })
```

Le rebroadcast sera reçu par tous les clients connectés, _y compris_ le client qui a envoyé le message. Notez que les paramètres sont les mêmes qu'au moment de l'abonnement au canal.

## Exemples Full-Stack

Les étapes de configuration suivantes sont communes aux deux exemples :

  1. [Configurez votre connexion](#connection-setup).
  2. [Configurez votre canal parent](#parent-channel-setup).
  3. [Connectez votre consommateur](#connect-consumer).

### Exemple 1 : Apparitions des utilisateurs

Voici un exemple simple d'un canal qui suit si un utilisateur est en ligne ou non et sur quelle page il se trouve. (Cela est utile pour créer des fonctionnalités de présence comme afficher un point vert à côté d'un nom d'utilisateur s'il est en ligne).

Créez le canal d'apparition côté serveur :

```ruby
# app/channels/appearance_channel.rb
class AppearanceChannel < ApplicationCable::Channel
  def subscribed
    current_user.appear
  end

  def unsubscribed
    current_user.disappear
  end

  def appear(data)
    current_user.appear(on: data['appearing_on'])
  end

  def away
    current_user.away
  end
end
```
Lorsqu'un abonnement est initié, le rappel `subscribed` est déclenché, et nous en profitons pour dire "l'utilisateur actuel est effectivement apparu". Cette API d'apparition/disparition peut être soutenue par Redis, une base de données, ou tout autre chose.

Créez l'abonnement du côté client au canal d'apparition :

```js
// app/javascript/channels/appearance_channel.js
import consumer from "./consumer"

consumer.subscriptions.create("AppearanceChannel", {
  // Appelé une fois lorsque l'abonnement est créé.
  initialized() {
    this.update = this.update.bind(this)
  },

  // Appelé lorsque l'abonnement est prêt à être utilisé sur le serveur.
  connected() {
    this.install()
    this.update()
  },

  // Appelé lorsque la connexion WebSocket est fermée.
  disconnected() {
    this.uninstall()
  },

  // Appelé lorsque l'abonnement est rejeté par le serveur.
  rejected() {
    this.uninstall()
  },

  update() {
    this.documentIsActive ? this.appear() : this.away()
  },

  appear() {
    // Appelle `AppearanceChannel#appear(data)` sur le serveur.
    this.perform("appear", { appearing_on: this.appearingOn })
  },

  away() {
    // Appelle `AppearanceChannel#away` sur le serveur.
    this.perform("away")
  },

  install() {
    window.addEventListener("focus", this.update)
    window.addEventListener("blur", this.update)
    document.addEventListener("turbo:load", this.update)
    document.addEventListener("visibilitychange", this.update)
  },

  uninstall() {
    window.removeEventListener("focus", this.update)
    window.removeEventListener("blur", this.update)
    document.removeEventListener("turbo:load", this.update)
    document.removeEventListener("visibilitychange", this.update)
  },

  get documentIsActive() {
    return document.visibilityState === "visible" && document.hasFocus()
  },

  get appearingOn() {
    const element = document.querySelector("[data-appearing-on]")
    return element ? element.getAttribute("data-appearing-on") : null
  }
})
```

#### Interaction Client-Serveur

1. **Client** se connecte au **Serveur** via `createConsumer()`. (`consumer.js`). Le
  **Serveur** identifie cette connexion par `current_user`.

2. **Client** s'abonne au canal d'apparition via
  `consumer.subscriptions.create({ channel: "AppearanceChannel" })`. (`appearance_channel.js`)

3. **Serveur** reconnaît qu'un nouvel abonnement a été initié pour le
  canal d'apparition et exécute son rappel `subscribed`, appelant la méthode `appear`
  sur `current_user`. (`appearance_channel.rb`)

4. **Client** reconnaît qu'un abonnement a été établi et appelle
  `connected` (`appearance_channel.js`), qui à son tour appelle `install` et `appear`.
  `appear` appelle `AppearanceChannel#appear(data)` sur le serveur, et fournit un
  hash de données `{ appearing_on: this.appearingOn }`. Cela est
  possible car l'instance du canal côté serveur expose automatiquement toutes
  les méthodes publiques déclarées dans la classe (à l'exception des rappels), de sorte que celles-ci peuvent être
  atteintes en tant qu'appels de procédure à distance via la méthode `perform` d'un abonnement.

5. **Serveur** reçoit la demande d'action `appear` sur le canal d'apparition pour la connexion identifiée par `current_user`
  (`appearance_channel.rb`). **Serveur** récupère les données avec la
  clé `:appearing_on` du hash de données et les définit comme valeur pour la clé `:on`
  passée à `current_user.appear`.

### Exemple 2 : Réception de nouvelles notifications Web

L'exemple d'apparition concernait l'exposition de fonctionnalités côté serveur à
l'invocation côté client via la connexion WebSocket. Mais l'avantage des WebSockets est qu'il s'agit d'une voie à double sens. Ainsi, montrons maintenant un exemple
où le serveur invoque une action côté client.

Il s'agit d'un canal de notification Web qui vous permet de déclencher des notifications Web côté client lorsque vous diffusez vers les flux pertinents :

Créez le canal de notification Web côté serveur :

```ruby
# app/channels/web_notifications_channel.rb
class WebNotificationsChannel < ApplicationCable::Channel
  def subscribed
    stream_for current_user
  end
end
```

Créez l'abonnement du canal de notification Web côté client :

```js
// app/javascript/channels/web_notifications_channel.js
// Côté client, qui suppose que vous avez déjà demandé
// l'autorisation d'envoyer des notifications Web.
import consumer from "./consumer"

consumer.subscriptions.create("WebNotificationsChannel", {
  received(data) {
    new Notification(data["title"], { body: data["body"] })
  }
})
```

Diffusez du contenu vers une instance de canal de notification Web à partir d'un autre endroit de votre
application :

```ruby
# Quelque part dans votre application, cela est appelé, peut-être depuis un NewCommentJob
WebNotificationsChannel.broadcast_to(
  current_user,
  title: 'Nouvelles choses !',
  body: 'Toutes les nouvelles dignes d'être imprimées'
)
```

L'appel `WebNotificationsChannel.broadcast_to` place un message dans la file d'attente pubsub de l'adaptateur d'abonnement actuel sous un nom de diffusion distinct pour chaque
utilisateur. Pour un utilisateur avec un ID de 1, le nom de diffusion serait
`web_notifications:1`.

Le canal a été instruit de diffuser tout ce qui arrive à
`web_notifications:1` directement vers le client en invoquant le rappel `received`.
Les données transmises en argument sont le hash envoyé en tant que deuxième paramètre
à l'appel de diffusion côté serveur, encodé en JSON pour le trajet à travers le réseau
et déballé pour l'argument de données arrivant en tant que `received`.

### Exemples plus complets

Consultez le référentiel [rails/actioncable-examples](https://github.com/rails/actioncable-examples)
pour un exemple complet de configuration d'Action Cable dans une application Rails et d'ajout de canaux.

## Configuration

Action Cable a deux configurations obligatoires : un adaptateur d'abonnement et des origines de requête autorisées.

### Adaptateur d'abonnement

Par défaut, Action Cable recherche un fichier de configuration dans `config/cable.yml`.
Le fichier doit spécifier un adaptateur pour chaque environnement Rails. Consultez la
section [Dépendances](#dependencies) pour plus d'informations sur les adaptateurs.

```yaml
development:
  adapter: async

test:
  adapter: test

production:
  adapter: redis
  url: redis://10.10.3.153:6381
  channel_prefix: appname_production
```
#### Configuration de l'adaptateur

Voici une liste des adaptateurs d'abonnement disponibles pour les utilisateurs finaux.

##### Adaptateur asynchrone

L'adaptateur asynchrone est destiné au développement/test et ne doit pas être utilisé en production.

##### Adaptateur Redis

L'adaptateur Redis nécessite que les utilisateurs fournissent une URL pointant vers le serveur Redis.
De plus, un `channel_prefix` peut être fourni pour éviter les collisions de noms de canal
lors de l'utilisation du même serveur Redis pour plusieurs applications. Consultez la [documentation Redis Pub/Sub](https://redis.io/docs/manual/pubsub/#database--scoping) pour plus de détails.

L'adaptateur Redis prend également en charge les connexions SSL/TLS. Les paramètres SSL/TLS requis peuvent être transmis dans la clé `ssl_params` du fichier de configuration YAML.

```
production:
  adapter: redis
  url: rediss://10.10.3.153:tls_port
  channel_prefix: appname_production
  ssl_params: {
    ca_file: "/path/to/ca.crt"
  }
```

Les options données à `ssl_params` sont transmises directement à la méthode `OpenSSL::SSL::SSLContext#set_params` et peuvent être n'importe quel attribut valide du contexte SSL.
Veuillez vous référer à la [documentation OpenSSL::SSL::SSLContext](https://docs.ruby-lang.org/en/master/OpenSSL/SSL/SSLContext.html) pour les autres attributs disponibles.

Si vous utilisez des certificats auto-signés pour l'adaptateur Redis derrière un pare-feu et que vous choisissez de sauter la vérification du certificat, alors le `verify_mode` SSL doit être défini sur `OpenSSL::SSL::VERIFY_NONE`.

AVERTISSEMENT: Il n'est pas recommandé d'utiliser `VERIFY_NONE` en production à moins de comprendre parfaitement les implications en matière de sécurité. Pour définir cette option pour l'adaptateur Redis, la configuration doit être `ssl_params: { verify_mode: <%= OpenSSL::SSL::VERIFY_NONE %> }`.

##### Adaptateur PostgreSQL

L'adaptateur PostgreSQL utilise le pool de connexions d'Active Record et donc la
configuration de la base de données `config/database.yml` de l'application pour sa connexion.
Cela peut changer à l'avenir. [#27214](https://github.com/rails/rails/issues/27214)

### Origines de requête autorisées

Action Cable n'acceptera que les requêtes provenant des origines spécifiées, qui sont
transmises à la configuration du serveur sous forme de tableau. Les origines peuvent être des instances de
chaînes de caractères ou des expressions régulières, contre lesquelles une vérification de correspondance sera effectuée.

```ruby
config.action_cable.allowed_request_origins = ['https://rubyonrails.com', %r{http://ruby.*}]
```

Pour désactiver et autoriser les requêtes depuis n'importe quelle origine :

```ruby
config.action_cable.disable_request_forgery_protection = true
```

Par défaut, Action Cable autorise toutes les requêtes depuis localhost:3000 lorsqu'il est exécuté
en environnement de développement.

### Configuration du consommateur

Pour configurer l'URL, ajoutez un appel à [`action_cable_meta_tag`][] dans votre mise en page HTML
HEAD. Cela utilise une URL ou un chemin généralement défini via [`config.action_cable.url`][] dans les
fichiers de configuration de l'environnement.


### Configuration du pool de travailleurs

Le pool de travailleurs est utilisé pour exécuter les rappels de connexion et les actions de canal de manière
isolée du thread principal du serveur. Action Cable permet à l'application
de configurer le nombre de threads traités simultanément dans le pool de travailleurs.

```ruby
config.action_cable.worker_pool_size = 4
```

Notez également que votre serveur doit fournir au moins le même nombre de connexions de base de données
que vous avez de travailleurs. La taille par défaut du pool de travailleurs est fixée à 4, donc
cela signifie que vous devez mettre au moins 4 connexions de base de données à disposition.
Vous pouvez modifier cela dans `config/database.yml` via l'attribut `pool`.

### Journalisation côté client

La journalisation côté client est désactivée par défaut. Vous pouvez l'activer en définissant `ActionCable.logger.enabled` sur true.

```ruby
import * as ActionCable from '@rails/actioncable'

ActionCable.logger.enabled = true
```

### Autres configurations

L'autre option courante à configurer est les balises de journalisation appliquées au
journal spécifique à la connexion. Voici un exemple qui utilise
l'ID du compte utilisateur si disponible, sinon "no-account" lors du marquage :

```ruby
config.action_cable.log_tags = [
  -> request { request.env['user_account_id'] || "no-account" },
  :action_cable,
  -> request { request.uuid }
]
```

Pour une liste complète de toutes les options de configuration, voir la
classe `ActionCable::Server::Configuration`.

## Exécution de serveurs Cable autonomes

Action Cable peut s'exécuter soit dans le cadre de votre application Rails, soit en tant que
serveur autonome. En développement, l'exécution dans le cadre de votre application Rails
est généralement suffisante, mais en production, vous devriez l'exécuter en tant que serveur autonome.

### Dans l'application

Action Cable peut s'exécuter aux côtés de votre application Rails. Par exemple, pour
écouter les requêtes WebSocket sur `/websocket`, spécifiez ce chemin à
[`config.action_cable.mount_path`][] :

```ruby
# config/application.rb
class Application < Rails::Application
  config.action_cable.mount_path = '/websocket'
end
```

Vous pouvez utiliser `ActionCable.createConsumer()` pour vous connecter au serveur de câble
si [`action_cable_meta_tag`][] est invoqué dans la mise en page. Sinon, un chemin est
spécifié en premier argument à `createConsumer` (par exemple, `ActionCable.createConsumer("/websocket")`).

Pour chaque instance de votre serveur que vous créez, et pour chaque travailleur que votre serveur
génère, vous aurez également une nouvelle instance d'Action Cable, mais l'adaptateur Redis ou
PostgreSQL synchronise les messages entre les connexions.


### Autonome

Les serveurs de câble peuvent être séparés de votre serveur d'application normal. C'est
encore une application Rack, mais c'est sa propre application Rack. La configuration de base recommandée
est la suivante :
```ruby
# cable/config.ru
require_relative "../config/environment"
Rails.application.eager_load!

run ActionCable.server
```

Ensuite, pour démarrer le serveur :

```
bundle exec puma -p 28080 cable/config.ru
```

Cela démarre un serveur de câble sur le port 28080. Pour indiquer à Rails d'utiliser ce
serveur, mettez à jour votre configuration :

```ruby
# config/environments/development.rb
Rails.application.configure do
  config.action_cable.mount_path = nil
  config.action_cable.url = "ws://localhost:28080" # utiliser wss:// en production
end
```

Enfin, assurez-vous d'avoir [configuré correctement le consommateur](#consumer-configuration).

### Notes

Le serveur WebSocket n'a pas accès à la session, mais il a
accès aux cookies. Cela peut être utilisé lorsque vous avez besoin de gérer
l'authentification. Vous pouvez voir une façon de le faire avec Devise dans cet [article](https://greg.molnar.io/blog/actioncable-devise-authentication/).

## Dépendances

Action Cable fournit une interface d'adaptateur d'abonnement pour traiter ses
internes de publication/abonnement. Par défaut, les adaptateurs asynchrones, en ligne, PostgreSQL et Redis
sont inclus. L'adaptateur par défaut
dans les nouvelles applications Rails est l'adaptateur asynchrone (`async`).

Le côté Ruby des choses est construit sur [websocket-driver](https://github.com/faye/websocket-driver-ruby),
[nio4r](https://github.com/celluloid/nio4r) et [concurrent-ruby](https://github.com/ruby-concurrency/concurrent-ruby).

## Déploiement

Action Cable est alimenté par une combinaison de WebSockets et de threads. Tant le
plomberie du framework que le travail de canal spécifié par l'utilisateur sont gérés en interne par
utilisation du support natif des threads de Ruby. Cela signifie que vous pouvez utiliser tous vos modèles Rails existants sans problème, tant que vous n'avez pas commis de péchés de sécurité des threads.

Le serveur Action Cable implémente l'API de détournement de socket Rack,
permettant ainsi l'utilisation d'un modèle multi-thread pour gérer les connexions
en interne, indépendamment de la possibilité que le serveur d'application soit multi-thread ou non.

En conséquence, Action Cable fonctionne avec des serveurs populaires comme Unicorn, Puma et
Passenger.

## Test

Vous pouvez trouver des instructions détaillées sur la façon de tester votre fonctionnalité Action Cable dans le
[guide de test](testing.html#testing-action-cable).
[`ActionCable::Connection::Base`]: https://api.rubyonrails.org/classes/ActionCable/Connection/Base.html
[`identified_by`]: https://api.rubyonrails.org/classes/ActionCable/Connection/Identification/ClassMethods.html#method-i-identified_by
[`rescue_from`]: https://api.rubyonrails.org/classes/ActiveSupport/Rescuable/ClassMethods.html#method-i-rescue_from
[`ActionCable::Channel::Base`]: https://api.rubyonrails.org/classes/ActionCable/Channel/Base.html
[`broadcast`]: https://api.rubyonrails.org/classes/ActionCable/Server/Broadcasting.html#method-i-broadcast
[`broadcast_to`]: https://api.rubyonrails.org/classes/ActionCable/Channel/Broadcasting/ClassMethods.html#method-i-broadcast_to
[`stream_for`]: https://api.rubyonrails.org/classes/ActionCable/Channel/Streams.html#method-i-stream_for
[`stream_from`]: https://api.rubyonrails.org/classes/ActionCable/Channel/Streams.html#method-i-stream_from
[`config.action_cable.url`]: configuring.html#config-action-cable-url
[`action_cable_meta_tag`]: https://api.rubyonrails.org/classes/ActionCable/Helpers/ActionCableHelper.html#method-i-action_cable_meta_tag
[`config.action_cable.mount_path`]: configuring.html#config-action-cable-mount-path
[`action_cable_meta_tag`]: https://api.rubyonrails.org/classes/ActionCable/Helpers/ActionCableHelper.html#method-i-action_cable_meta_tag
