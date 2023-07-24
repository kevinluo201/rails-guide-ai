**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 8e409a33cc6caed27c82b91e6adad6c7
Principes de base d'Active Job
==============================

Ce guide vous fournit tout ce dont vous avez besoin pour commencer à créer,
mettre en file d'attente et exécuter des tâches en arrière-plan.

Après avoir lu ce guide, vous saurez :

* Comment créer des tâches.
* Comment mettre des tâches en file d'attente.
* Comment exécuter des tâches en arrière-plan.
* Comment envoyer des e-mails depuis votre application de manière asynchrone.

--------------------------------------------------------------------------------

Qu'est-ce qu'Active Job ?
-------------------------

Active Job est un framework permettant de déclarer des tâches et de les exécuter sur différents backends de mise en file d'attente. Ces tâches peuvent être des opérations de nettoyage régulièrement planifiées, des facturations, des envois d'e-mails, etc. Tout ce qui peut être découpé en petites unités de travail et exécuté en parallèle, en somme.

L'objectif d'Active Job
-----------------------

L'objectif principal est de garantir que toutes les applications Rails disposent d'une infrastructure de tâches en place. Nous pouvons ensuite développer des fonctionnalités du framework et d'autres gemmes en s'appuyant dessus, sans avoir à se soucier des différences d'API entre les différents exécuteurs de tâches tels que Delayed Job et Resque. Le choix de votre backend de mise en file d'attente devient alors davantage une préoccupation opérationnelle. Et vous pourrez passer de l'un à l'autre sans avoir à réécrire vos tâches.

REMARQUE : Rails est livré par défaut avec une implémentation de mise en file d'attente asynchrone qui exécute les tâches avec un pool de threads en cours d'exécution. Les tâches s'exécuteront de manière asynchrone, mais toutes les tâches en file d'attente seront abandonnées lors du redémarrage.

Création d'une tâche
--------------------

Cette section vous fournira un guide étape par étape pour créer une tâche et la mettre en file d'attente.

### Créer la tâche

Active Job fournit un générateur Rails pour créer des tâches. La commande suivante créera une tâche dans `app/jobs` (avec un test associé dans `test/jobs`):

```bash
$ bin/rails generate job guests_cleanup
invoke  test_unit
create    test/jobs/guests_cleanup_job_test.rb
create  app/jobs/guests_cleanup_job.rb
```

Vous pouvez également créer une tâche qui s'exécutera sur une file d'attente spécifique :

```bash
$ bin/rails generate job guests_cleanup --queue urgent
```

Si vous ne souhaitez pas utiliser de générateur, vous pouvez créer votre propre fichier à l'intérieur de `app/jobs`, assurez-vous simplement qu'il hérite de `ApplicationJob`.

Voici à quoi ressemble une tâche :

```ruby
class GuestsCleanupJob < ApplicationJob
  queue_as :default

  def perform(*guests)
    # Faire quelque chose plus tard
  end
end
```

Notez que vous pouvez définir `perform` avec autant d'arguments que vous le souhaitez.

Si vous avez déjà une classe abstraite et que son nom diffère de `ApplicationJob`, vous pouvez passer l'option `--parent` pour indiquer que vous souhaitez une classe abstraite différente :

```bash
$ bin/rails generate job process_payment --parent=payment_job
```

```ruby
class ProcessPaymentJob < PaymentJob
  queue_as :default

  def perform(*args)
    # Faire quelque chose plus tard
  end
end
```

### Mettre la tâche en file d'attente

Mettez une tâche en file d'attente en utilisant [`perform_later`][] et, éventuellement, [`set`][]. Comme ceci :

```ruby
# Mettre une tâche en file d'attente pour être exécutée dès que le système de mise en file d'attente est
# libre.
GuestsCleanupJob.perform_later guest
```

```ruby
# Mettre une tâche en file d'attente pour être exécutée demain à midi.
GuestsCleanupJob.set(wait_until: Date.tomorrow.noon).perform_later(guest)
```

```ruby
# Mettre une tâche en file d'attente pour être exécutée dans 1 semaine.
GuestsCleanupJob.set(wait: 1.week).perform_later(guest)
```

```ruby
# `perform_now` et `perform_later` appelleront `perform` en interne, vous pouvez donc passer autant d'arguments que défini dans ce dernier.
GuestsCleanupJob.perform_later(guest1, guest2, filter: 'some_filter')
```

C'est tout !

Exécution des tâches
--------------------

Pour mettre des tâches en file d'attente et les exécuter en production, vous devez configurer un backend de mise en file d'attente, c'est-à-dire choisir une bibliothèque de mise en file d'attente tierce que Rails devrait utiliser. Rails lui-même ne fournit qu'un système de mise en file d'attente en interne, qui ne conserve les tâches que dans la RAM. Si le processus plante ou que la machine est réinitialisée, toutes les tâches en attente sont perdues avec le backend asynchrone par défaut. Cela peut convenir aux applications plus petites ou aux tâches non critiques, mais la plupart des applications en production devront choisir un backend persistant.

### Backends

Active Job dispose d'adaptateurs intégrés pour plusieurs backends de mise en file d'attente (Sidekiq, Resque, Delayed Job, et d'autres). Pour obtenir une liste à jour des adaptateurs, consultez la documentation de l'API pour [`ActiveJob::QueueAdapters`][].

### Configuration du backend

Vous pouvez facilement configurer votre backend de mise en file d'attente avec [`config.active_job.queue_adapter`] :

```ruby
# config/application.rb
module YourApp
  class Application < Rails::Application
    # Assurez-vous d'avoir la gemme de l'adaptateur dans votre Gemfile
    # et suivez les instructions d'installation et de déploiement spécifiques à l'adaptateur.
    config.active_job.queue_adapter = :sidekiq
  end
end
```

Vous pouvez également configurer votre backend pour chaque tâche :

```ruby
class GuestsCleanupJob < ApplicationJob
  self.queue_adapter = :resque
  # ...
end

# Maintenant, votre tâche utilisera `resque` comme adaptateur de file d'attente backend, en remplacement de ce qui a été configuré dans `config.active_job.queue_adapter`.
```
### Démarrage du Backend

Étant donné que les tâches s'exécutent en parallèle de votre application Rails, la plupart des bibliothèques de mise en file d'attente nécessitent que vous démarriez un service de mise en file d'attente spécifique à la bibliothèque (en plus de démarrer votre application Rails) pour que le traitement des tâches fonctionne. Consultez la documentation de la bibliothèque pour obtenir des instructions sur la façon de démarrer votre backend de mise en file d'attente.

Voici une liste non exhaustive de documentation :

- [Sidekiq](https://github.com/mperham/sidekiq/wiki/Active-Job)
- [Resque](https://github.com/resque/resque/wiki/ActiveJob)
- [Sneakers](https://github.com/jondot/sneakers/wiki/How-To:-Rails-Background-Jobs-with-ActiveJob)
- [Sucker Punch](https://github.com/brandonhilkert/sucker_punch#active-job)
- [Queue Classic](https://github.com/QueueClassic/queue_classic#active-job)
- [Delayed Job](https://github.com/collectiveidea/delayed_job#active-job)
- [Que](https://github.com/que-rb/que#additional-rails-specific-setup)
- [Good Job](https://github.com/bensheldon/good_job#readme)

Files d'attente
------

La plupart des adaptateurs prennent en charge plusieurs files d'attente. Avec Active Job, vous pouvez planifier l'exécution de la tâche sur une file d'attente spécifique en utilisant [`queue_as`][] :

```ruby
class GuestsCleanupJob < ApplicationJob
  queue_as :low_priority
  # ...
end
```

Vous pouvez préfixer le nom de la file d'attente pour toutes vos tâches en utilisant [`config.active_job.queue_name_prefix`][] dans `application.rb` :

```ruby
# config/application.rb
module YourApp
  class Application < Rails::Application
    config.active_job.queue_name_prefix = Rails.env
  end
end
```

```ruby
# app/jobs/guests_cleanup_job.rb
class GuestsCleanupJob < ApplicationJob
  queue_as :low_priority
  # ...
end

# Maintenant, votre tâche s'exécutera sur la file d'attente production_low_priority dans votre
# environnement de production et sur la file d'attente staging_low_priority
# dans votre environnement de staging
```

Vous pouvez également configurer le préfixe sur une base par tâche.

```ruby
class GuestsCleanupJob < ApplicationJob
  queue_as :low_priority
  self.queue_name_prefix = nil
  # ...
end

# Maintenant, la file d'attente de votre tâche ne sera pas préfixée, annulant ce qui
# a été configuré dans `config.active_job.queue_name_prefix`.
```

Le délimiteur par défaut du préfixe du nom de la file d'attente est '\_'. Cela peut être modifié en définissant
[`config.active_job.queue_name_delimiter`][] dans `application.rb` :

```ruby
# config/application.rb
module YourApp
  class Application < Rails::Application
    config.active_job.queue_name_prefix = Rails.env
    config.active_job.queue_name_delimiter = '.'
  end
end
```

```ruby
# app/jobs/guests_cleanup_job.rb
class GuestsCleanupJob < ApplicationJob
  queue_as :low_priority
  # ...
end

# Maintenant, votre tâche s'exécutera sur la file d'attente production.low_priority dans votre
# environnement de production et sur la file d'attente staging.low_priority
# dans votre environnement de staging
```

Si vous souhaitez avoir plus de contrôle sur la file d'attente sur laquelle une tâche sera exécutée, vous pouvez passer une option `:queue`
à `set` :

```ruby
MyJob.set(queue: :another_queue).perform_later(record)
```

Pour contrôler la file d'attente au niveau de la tâche, vous pouvez passer un bloc à `queue_as`. Le
bloc sera exécuté dans le contexte de la tâche (il peut donc accéder à `self.arguments`),
et il doit renvoyer le nom de la file d'attente :

```ruby
class ProcessVideoJob < ApplicationJob
  queue_as do
    video = self.arguments.first
    if video.owner.premium?
      :premium_videojobs
    else
      :videojobs
    end
  end

  def perform(video)
    # Faire le traitement de la vidéo
  end
end
```

```ruby
ProcessVideoJob.perform_later(Video.last)
```

NOTE : Assurez-vous que votre backend de mise en file d'attente "écoute" le nom de votre file d'attente. Pour certains
backends, vous devez spécifier les files d'attente à écouter.


Callbacks
---------

Active Job fournit des hooks pour déclencher une logique pendant le cycle de vie d'une tâche. Comme
d'autres callbacks dans Rails, vous pouvez implémenter les callbacks en tant que méthodes ordinaires
et utiliser une méthode de classe de style macro pour les enregistrer en tant que callbacks :

```ruby
class GuestsCleanupJob < ApplicationJob
  queue_as :default

  around_perform :around_cleanup

  def perform
    # Faire quelque chose plus tard
  end

  private
    def around_cleanup
      # Faire quelque chose avant l'exécution
      yield
      # Faire quelque chose après l'exécution
    end
end
```

Les méthodes de classe de style macro peuvent également recevoir un bloc. Considérez l'utilisation de cette
style si le code à l'intérieur de votre bloc est si court qu'il tient sur une seule ligne.
Par exemple, vous pourriez envoyer des métriques pour chaque tâche en file d'attente :

```ruby
class ApplicationJob < ActiveJob::Base
  before_enqueue { |job| $statsd.increment "#{job.class.name.underscore}.enqueue" }
end
```

### Callbacks disponibles

* [`before_enqueue`][]
* [`around_enqueue`][]
* [`after_enqueue`][]
* [`before_perform`][]
* [`around_perform`][]
* [`after_perform`][]


Action Mailer
------------

L'une des tâches les plus courantes dans une application web moderne est l'envoi d'e-mails en dehors
du cycle demande-réponse, de sorte que l'utilisateur n'ait pas à attendre. Active Job
est intégré à Action Mailer, vous pouvez donc facilement envoyer des e-mails de manière asynchrone :

```ruby
# Si vous voulez envoyer l'e-mail maintenant, utilisez #deliver_now
UserMailer.welcome(@user).deliver_now

# Si vous voulez envoyer l'e-mail via Active Job, utilisez #deliver_later
UserMailer.welcome(@user).deliver_later
```

NOTE : L'utilisation de la file d'attente asynchrone à partir d'une tâche Rake (par exemple, pour
envoyer un e-mail en utilisant `.deliver_later`) ne fonctionnera généralement pas car Rake va
probablement se terminer, ce qui entraînera la suppression de la file d'attente en cours d'exécution, avant que tous les e-mails `.deliver_later` ne soient traités. Pour éviter ce problème, utilisez
`.deliver_now` ou exécutez une file d'attente persistante en développement.


Internationalisation
--------------------

Chaque tâche utilise la valeur de `I18n.locale` définie lors de la création de la tâche. Cela est utile si vous envoyez
des e-mails de manière asynchrone :

```ruby
I18n.locale = :eo

UserMailer.welcome(@user).deliver_later # L'e-mail sera localisé en espéranto.
```


Types pris en charge pour les arguments
----------------------------
ActiveJob prend en charge les types d'arguments suivants par défaut:

  - Types de base (`NilClass`, `String`, `Integer`, `Float`, `BigDecimal`, `TrueClass`, `FalseClass`)
  - `Symbol`
  - `Date`
  - `Time`
  - `DateTime`
  - `ActiveSupport::TimeWithZone`
  - `ActiveSupport::Duration`
  - `Hash` (Les clés doivent être de type `String` ou `Symbol`)
  - `ActiveSupport::HashWithIndifferentAccess`
  - `Array`
  - `Range`
  - `Module`
  - `Class`

### GlobalID

Active Job prend en charge [GlobalID](https://github.com/rails/globalid/blob/master/README.md) pour les paramètres. Cela permet de passer des objets Active Record en direct à votre travail au lieu de paires classe/id, que vous devez ensuite désérialiser manuellement. Auparavant, les travaux ressemblaient à ceci:

```ruby
class TrashableCleanupJob < ApplicationJob
  def perform(trashable_class, trashable_id, depth)
    trashable = trashable_class.constantize.find(trashable_id)
    trashable.cleanup(depth)
  end
end
```

Maintenant, vous pouvez simplement faire:

```ruby
class TrashableCleanupJob < ApplicationJob
  def perform(trashable, depth)
    trashable.cleanup(depth)
  end
end
```

Cela fonctionne avec n'importe quelle classe qui inclut `GlobalID::Identification`, qui est par défaut mélangée aux classes Active Record.

### Serializers

Vous pouvez étendre la liste des types d'arguments pris en charge. Vous devez simplement définir votre propre sérialiseur:

```ruby
# app/serializers/money_serializer.rb
class MoneySerializer < ActiveJob::Serializers::ObjectSerializer
  # Vérifie si un argument doit être sérialisé par ce sérialiseur.
  def serialize?(argument)
    argument.is_a? Money
  end

  # Convertit un objet en une représentation plus simple en utilisant des types d'objets pris en charge.
  # La représentation recommandée est un Hash avec une clé spécifique. Les clés ne peuvent être que de types de base.
  # Vous devez appeler `super` pour ajouter le type de sérialiseur personnalisé au hash.
  def serialize(money)
    super(
      "amount" => money.amount,
      "currency" => money.currency
    )
  end

  # Convertit la valeur sérialisée en un objet approprié.
  def deserialize(hash)
    Money.new(hash["amount"], hash["currency"])
  end
end
```

et ajoutez ce sérialiseur à la liste:

```ruby
# config/initializers/custom_serializers.rb
Rails.application.config.active_job.custom_serializers << MoneySerializer
```

Notez que le rechargement automatique du code rechargeable pendant l'initialisation n'est pas pris en charge. Il est donc recommandé de configurer les sérialiseurs pour qu'ils ne soient chargés qu'une seule fois, par exemple en modifiant `config/application.rb` comme ceci:

```ruby
# config/application.rb
module YourApp
  class Application < Rails::Application
    config.autoload_once_paths << Rails.root.join('app', 'serializers')
  end
end
```

Exceptions
----------

Les exceptions levées pendant l'exécution du travail peuvent être gérées avec [`rescue_from`][]:

```ruby
class GuestsCleanupJob < ApplicationJob
  queue_as :default

  rescue_from(ActiveRecord::RecordNotFound) do |exception|
    # Faites quelque chose avec l'exception
  end

  def perform
    # Faites quelque chose plus tard
  end
end
```

Si une exception d'un travail n'est pas récupérée, alors le travail est considéré comme "échoué".


### Réessayer ou supprimer les travaux échoués

Un travail échoué ne sera pas réessayé, sauf si cela est configuré autrement.

Il est possible de réessayer ou de supprimer un travail échoué en utilisant [`retry_on`] ou
[`discard_on`], respectivement. Par exemple:

```ruby
class RemoteServiceJob < ApplicationJob
  retry_on CustomAppException # attend 3s par défaut, 5 tentatives

  discard_on ActiveJob::DeserializationError

  def perform(*args)
    # Peut lever CustomAppException ou ActiveJob::DeserializationError
  end
end
```


### Désérialisation

GlobalID permet de sérialiser des objets Active Record complets passés à `#perform`.

Si un enregistrement passé est supprimé après que le travail a été mis en file d'attente mais avant que la méthode `#perform`
ne soit appelée, Active Job lèvera une exception [`ActiveJob::DeserializationError`][]
exception.


Test des travaux
--------------

Vous pouvez trouver des instructions détaillées sur la façon de tester vos travaux dans le
[guide de test](testing.html#testing-jobs).

Débogage
---------

Si vous avez besoin d'aide pour comprendre d'où viennent les travaux, vous pouvez activer [l'enregistrement détaillé](debugging_rails_applications.html#verbose-enqueue-logs).
[`perform_later`]: https://api.rubyonrails.org/classes/ActiveJob/Enqueuing/ClassMethods.html#method-i-perform_later
[`set`]: https://api.rubyonrails.org/classes/ActiveJob/Core/ClassMethods.html#method-i-set
[`ActiveJob::QueueAdapters`]: https://api.rubyonrails.org/classes/ActiveJob/QueueAdapters.html
[`config.active_job.queue_adapter`]: configuring.html#config-active-job-queue-adapter
[`config.active_job.queue_name_delimiter`]: configuring.html#config-active-job-queue-name-delimiter
[`config.active_job.queue_name_prefix`]: configuring.html#config-active-job-queue-name-prefix
[`queue_as`]: https://api.rubyonrails.org/classes/ActiveJob/QueueName/ClassMethods.html#method-i-queue_as
[`before_enqueue`]: https://api.rubyonrails.org/classes/ActiveJob/Callbacks/ClassMethods.html#method-i-before_enqueue
[`around_enqueue`]: https://api.rubyonrails.org/classes/ActiveJob/Callbacks/ClassMethods.html#method-i-around_enqueue
[`after_enqueue`]: https://api.rubyonrails.org/classes/ActiveJob/Callbacks/ClassMethods.html#method-i-after_enqueue
[`before_perform`]: https://api.rubyonrails.org/classes/ActiveJob/Callbacks/ClassMethods.html#method-i-before_perform
[`around_perform`]: https://api.rubyonrails.org/classes/ActiveJob/Callbacks/ClassMethods.html#method-i-around_perform
[`after_perform`]: https://api.rubyonrails.org/classes/ActiveJob/Callbacks/ClassMethods.html#method-i-after_perform
[`rescue_from`]: https://api.rubyonrails.org/classes/ActiveSupport/Rescuable/ClassMethods.html#method-i-rescue_from
[`discard_on`]: https://api.rubyonrails.org/classes/ActiveJob/Exceptions/ClassMethods.html#method-i-discard_on
[`retry_on`]: https://api.rubyonrails.org/classes/ActiveJob/Exceptions/ClassMethods.html#method-i-retry_on
[`ActiveJob::DeserializationError`]: https://api.rubyonrails.org/classes/ActiveJob/DeserializationError.html
