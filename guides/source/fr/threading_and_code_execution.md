**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: ffc6bf535a0dbd3487837673547ae486
Threading et exécution de code dans Rails
==========================================

Après avoir lu ce guide, vous saurez :

* Quel code Rails exécute automatiquement de manière concurrente
* Comment intégrer une concurrence manuelle avec les composants internes de Rails
* Comment envelopper tout le code de l'application
* Comment affecter le rechargement de l'application

--------------------------------------------------------------------------------

Concurrence automatique
-----------------------

Rails permet automatiquement l'exécution de diverses opérations en même temps.

Lors de l'utilisation d'un serveur web threadé, tel que le serveur Puma par défaut, plusieurs requêtes HTTP seront traitées simultanément, chaque requête disposant de sa propre instance de contrôleur.

Les adaptateurs Active Job threadés, y compris le module Async intégré, exécuteront également plusieurs tâches en même temps. Les canaux Action Cable sont également gérés de cette manière.

Ces mécanismes impliquent tous plusieurs threads, chacun gérant le travail pour une instance unique d'un objet (contrôleur, tâche, canal), tout en partageant l'espace de processus global (comme les classes et leurs configurations, et les variables globales). Tant que votre code ne modifie pas ces éléments partagés, il peut en grande partie ignorer l'existence des autres threads.

Le reste de ce guide décrit les mécanismes que Rails utilise pour rendre cette "ignorance" possible, ainsi que la manière dont les extensions et les applications ayant des besoins spécifiques peuvent les utiliser.

Executor
--------

L'Executor de Rails sépare le code de l'application du code du framework : chaque fois que le framework invoque le code que vous avez écrit dans votre application, il est enveloppé par l'Executor.

L'Executor se compose de deux rappels : `to_run` et `to_complete`. Le rappel Run est appelé avant le code de l'application, et le rappel Complete est appelé après.

### Rappels par défaut

Dans une application Rails par défaut, les rappels de l'Executor sont utilisés pour :

* suivre les threads qui se trouvent dans des positions sûres pour le chargement automatique et le rechargement
* activer et désactiver le cache de requêtes Active Record
* renvoyer les connexions Active Record acquises au pool
* limiter la durée de vie du cache interne

Avant Rails 5.0, certains de ces éléments étaient gérés par des classes middleware Rack distinctes (comme `ActiveRecord::ConnectionAdapters::ConnectionManagement`), ou en enveloppant directement le code avec des méthodes telles que `ActiveRecord::Base.connection_pool.with_connection`. L'Executor les remplace par une interface unique et plus abstraite.

### Envelopper le code de l'application

Si vous écrivez une bibliothèque ou un composant qui invoquera le code de l'application, vous devez l'envelopper avec un appel à l'executor :

```ruby
Rails.application.executor.wrap do
  # appeler le code de l'application ici
end
```

CONSEIL : Si vous invoquez régulièrement le code de l'application à partir d'un processus en cours d'exécution, vous voudrez peut-être utiliser le [Reloader](#reloader) à la place.

Chaque thread doit être enveloppé avant d'exécuter le code de l'application, donc si votre application délègue manuellement le travail à d'autres threads, par exemple via `Thread.new` ou des fonctionnalités de Concurrent Ruby qui utilisent des pools de threads, vous devez immédiatement envelopper le bloc :

```ruby
Thread.new do
  Rails.application.executor.wrap do
    # votre code ici
  end
end
```

REMARQUE : Concurrent Ruby utilise un `ThreadPoolExecutor`, qu'il configure parfois avec une option `executor`. Malgré le nom, cela n'a aucun rapport.

L'Executor est sûrement réentrant ; s'il est déjà actif sur le thread actuel, `wrap` ne fait rien.

Si envelopper le code de l'application dans un bloc est impraticable (par exemple, l'API Rack pose problème), vous pouvez également utiliser la paire `run!` / `complete!` :

```ruby
Thread.new do
  execution_context = Rails.application.executor.run!
  # votre code ici
ensure
  execution_context.complete! if execution_context
end
```

### Concurrence

L'Executor met le thread actuel en mode `running` dans l'[Interlock de chargement](#load-interlock). Cette opération se bloque temporairement si un autre thread est en train de charger automatiquement une constante ou de décharger/recharger l'application.

Reloader
--------

Comme l'Executor, le Reloader enveloppe également le code de l'application. Si l'Executor n'est pas déjà actif sur le thread actuel, le Reloader l'invoquera pour vous, vous n'avez donc besoin d'appeler qu'une seule fois. Cela garantit également que tout ce que fait le Reloader, y compris toutes ses invocations de rappels, est enveloppé à l'intérieur de l'Executor.

```ruby
Rails.application.reloader.wrap do
  # appeler le code de l'application ici
end
```

Le Reloader convient uniquement lorsqu'un processus de niveau framework en cours d'exécution appelle de manière répétée le code de l'application, par exemple pour un serveur web ou une file de tâches. Rails enveloppe automatiquement les requêtes web et les travailleurs Active Job, vous n'aurez donc que rarement besoin d'invoquer le Reloader vous-même. Pensez toujours à savoir si l'Executor est plus adapté à votre cas d'utilisation.

### Rappels

Avant d'entrer dans le bloc enveloppé, le Reloader vérifiera si l'application en cours d'exécution doit être rechargée, par exemple parce que le fichier source d'un modèle a été modifié. S'il détermine qu'un rechargement est nécessaire, il attendra jusqu'à ce que ce soit sûr, puis le fera, avant de continuer. Lorsque l'application est configurée pour toujours recharger, indépendamment de la détection de modifications, le rechargement est effectué à la fin du bloc.
Le Reloader fournit également des rappels `to_run` et `to_complete`; ils sont invoqués aux mêmes points que ceux de l'Executor, mais seulement lorsque l'exécution en cours a initié un rechargement de l'application. Lorsqu'aucun rechargement n'est jugé nécessaire, le Reloader invoquera le bloc enveloppé sans autres rappels.

### Déchargement de classe

La partie la plus significative du processus de rechargement est le déchargement de classe, où toutes les classes chargées automatiquement sont supprimées, prêtes à être rechargées. Cela se produira immédiatement avant le rappel Run ou Complete, en fonction du paramètre `reload_classes_only_on_change`.

Souvent, des actions de rechargement supplémentaires doivent être effectuées soit juste avant, soit juste après le déchargement de classe, c'est pourquoi le Reloader fournit également des rappels `before_class_unload` et `after_class_unload`.

### Concurrence

Seuls les processus "de premier niveau" de longue durée doivent invoquer le Reloader, car s'il détermine qu'un rechargement est nécessaire, il se bloquera jusqu'à ce que tous les autres threads aient terminé toutes les invocations de l'Executor.

Si cela se produisait dans un thread "enfant", avec un parent en attente à l'intérieur de l'Executor, cela provoquerait une impasse inévitable : le rechargement doit se produire avant que le thread enfant ne soit exécuté, mais il ne peut pas être effectué en toute sécurité pendant que le thread parent est en cours d'exécution. Les threads enfants doivent utiliser l'Executor à la place.

Comportement du framework
------------------

Les composants du framework Rails utilisent également ces outils pour gérer leurs propres besoins en matière de concurrence.

`ActionDispatch::Executor` et `ActionDispatch::Reloader` sont des middlewares Rack qui enveloppent les requêtes avec un Executor ou un Reloader fourni, respectivement. Ils sont automatiquement inclus dans la pile d'application par défaut. Le Reloader garantira que toute requête HTTP arrivante est servie avec une copie fraîchement chargée de l'application si des modifications de code ont eu lieu.

Active Job enveloppe également ses exécutions de tâches avec le Reloader, chargeant le code le plus récent pour exécuter chaque tâche lorsqu'elle sort de la file d'attente.

Action Cable utilise plutôt l'Executor : parce qu'une connexion Cable est liée à une instance spécifique d'une classe, il n'est pas possible de recharger pour chaque message WebSocket arrivant. Seul le gestionnaire de messages est enveloppé, cependant ; une connexion Cable de longue durée n'empêche pas un rechargement déclenché par une nouvelle requête ou tâche entrante. À la place, Action Cable utilise le rappel `before_class_unload` du Reloader pour déconnecter toutes ses connexions. Lorsque le client se reconnecte automatiquement, il parlera à la nouvelle version du code.

Ce sont les points d'entrée du framework, il leur incombe donc de protéger leurs threads respectifs et de décider si un rechargement est nécessaire. Les autres composants n'ont besoin d'utiliser l'Executor que lorsqu'ils créent des threads supplémentaires.

### Configuration

Le Reloader ne vérifie les modifications de fichiers que lorsque `config.enable_reloading` est `true` et que `config.reload_classes_only_on_change` l'est également. Ce sont les valeurs par défaut dans l'environnement `development`.

Lorsque `config.enable_reloading` est `false` (par défaut en `production`), le Reloader est simplement un passage vers l'Executor.

L'Executor a toujours un travail important à faire, comme la gestion de la connexion à la base de données. Lorsque `config.enable_reloading` est `false` et que `config.eager_load` est `true` (valeurs par défaut en `production`), aucun rechargement ne se produira, il n'a donc pas besoin de l'interverrouillage de chargement. Avec les paramètres par défaut dans l'environnement `development`, l'Executor utilisera l'interverrouillage de chargement pour s'assurer que les constantes ne sont chargées que lorsque cela est sûr.

Interverrouillage de chargement
--------------

L'interverrouillage de chargement permet d'activer le chargement automatique et le rechargement dans un environnement d'exécution multithread.

Lorsqu'un thread effectue un chargement automatique en évaluant la définition de classe à partir du fichier approprié, il est important qu'aucun autre thread ne rencontre une référence à la constante partiellement définie.

De même, il est seulement sûr d'effectuer un déchargement/rechargement lorsque aucun code d'application n'est en cours d'exécution : après le rechargement, la constante `User`, par exemple, peut pointer vers une classe différente. Sans cette règle, un rechargement mal synchronisé signifierait que `User.new.class == User`, ou même `User == User`, pourrait être faux.

Ces deux contraintes sont prises en compte par l'interverrouillage de chargement. Il garde une trace des threads qui exécutent actuellement du code d'application, chargent une classe ou déchargent des constantes chargées automatiquement.

Un seul thread peut charger ou décharger à la fois, et pour le faire, il doit attendre qu'aucun autre thread n'exécute de code d'application. Si un thread attend de charger, cela n'empêche pas les autres threads de charger (en fait, ils coopéreront et effectueront chacun leur chargement en file d'attente tour à tour, avant de tous reprendre l'exécution ensemble).

### `permit_concurrent_loads`

L'Executor acquiert automatiquement un verrou `running` pendant la durée de son bloc, et le chargement automatique sait quand passer à un verrou `load` et revenir à `running` ensuite.
D'autres opérations de blocage effectuées à l'intérieur du bloc Executor (qui inclut tout le code de l'application), cependant, peuvent conserver inutilement le verrou "running". Si un autre thread rencontre une constante qu'il doit charger automatiquement, cela peut provoquer un deadlock.

Par exemple, en supposant que "User" n'est pas encore chargé, le code suivant provoquera un deadlock :

```ruby
Rails.application.executor.wrap do
  th = Thread.new do
    Rails.application.executor.wrap do
      User # le thread interne attend ici ; il ne peut pas charger
           # User tant qu'un autre thread est en cours d'exécution
    end
  end

  th.join # le thread externe attend ici, en maintenant le verrou "running"
end
```

Pour éviter ce deadlock, le thread externe peut utiliser `permit_concurrent_loads`. En appelant cette méthode, le thread garantit qu'il ne déréférencera aucune constante éventuellement chargée automatiquement à l'intérieur du bloc fourni. La manière la plus sûre de respecter cette promesse est de la placer aussi près que possible de l'appel bloquant :

```ruby
Rails.application.executor.wrap do
  th = Thread.new do
    Rails.application.executor.wrap do
      User # le thread interne peut acquérir le verrou "load",
           # charger User et continuer
    end
  end

  ActiveSupport::Dependencies.interlock.permit_concurrent_loads do
    th.join # le thread externe attend ici, mais n'a pas de verrou
  end
end
```

Un autre exemple, en utilisant Concurrent Ruby :

```ruby
Rails.application.executor.wrap do
  futures = 3.times.collect do |i|
    Concurrent::Promises.future do
      Rails.application.executor.wrap do
        # faire du travail ici
      end
    end
  end

  values = ActiveSupport::Dependencies.interlock.permit_concurrent_loads do
    futures.collect(&:value)
  end
end
```

### ActionDispatch::DebugLocks

Si votre application se retrouve dans un deadlock et que vous pensez que l'interlock de chargement peut être impliqué, vous pouvez temporairement ajouter le middleware ActionDispatch::DebugLocks à `config/application.rb` :

```ruby
config.middleware.insert_before Rack::Sendfile,
                                  ActionDispatch::DebugLocks
```

Si vous redémarrez ensuite l'application et que vous déclenchez à nouveau la condition de deadlock, `/rails/locks` affichera un résumé de tous les threads actuellement connus de l'interlock, le niveau de verrouillage qu'ils détiennent ou attendent, ainsi que leur trace de pile actuelle.

Généralement, un deadlock sera causé par l'interlock qui entre en conflit avec un autre verrou externe ou un appel de blocage d'E/S. Une fois que vous l'avez trouvé, vous pouvez l'encadrer avec `permit_concurrent_loads`.
