**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: e904ad42aee9a68f37b4e79e0b70b685
Rapports d'erreurs dans les applications Rails
========================

Ce guide présente les différentes façons de gérer les exceptions qui se produisent dans les applications Ruby on Rails.

Après avoir lu ce guide, vous saurez :

* Comment utiliser le rapporteur d'erreurs de Rails pour capturer et signaler les erreurs.
* Comment créer des abonnés personnalisés pour votre service de rapport d'erreurs.

--------------------------------------------------------------------------------

Rapport d'erreurs
------------------------

Le rapporteur d'erreurs de Rails [error reporter](https://api.rubyonrails.org/classes/ActiveSupport/ErrorReporter.html) fournit une méthode standard pour collecter les exceptions qui se produisent dans votre application et les signaler à votre service ou emplacement préféré.

Le rapporteur d'erreurs vise à remplacer le code de gestion d'erreur redondant comme celui-ci :

```ruby
begin
  faire_quelque_chose
rescue QuelqueChoseEstCassé => erreur
  MonServiceDeRapportD'Erreurs.notifier(erreur)
end
```

avec une interface cohérente :

```ruby
Rails.error.handle(QuelqueChoseEstCassé) do
  faire_quelque_chose
end
```

Rails enveloppe toutes les exécutions (comme les requêtes HTTP, les jobs et les invocations de `rails runner`) dans le rapporteur d'erreurs, de sorte que toutes les erreurs non gérées levées dans votre application seront automatiquement signalées à votre service de rapport d'erreurs via leurs abonnés.

Cela signifie que les bibliothèques de rapport d'erreurs tierces n'ont plus besoin d'insérer un middleware Rack ou de faire des patchs pour capturer les exceptions non gérées. Les bibliothèques qui utilisent ActiveSupport peuvent également l'utiliser pour signaler de manière non intrusive les avertissements qui auraient été perdus auparavant dans les journaux.

L'utilisation du rapporteur d'erreurs de Rails n'est pas obligatoire. Tous les autres moyens de capturer les erreurs fonctionnent toujours.

### Abonnement au rapporteur

Pour utiliser le rapporteur d'erreurs, vous avez besoin d'un _abonné_. Un abonné est n'importe quel objet avec une méthode `report`. Lorsqu'une erreur se produit dans votre application ou est signalée manuellement, le rapporteur d'erreurs de Rails appelle cette méthode avec l'objet d'erreur et certaines options.

Certaines bibliothèques de rapport d'erreurs, telles que [Sentry](https://github.com/getsentry/sentry-ruby/blob/e18ce4b6dcce2ebd37778c1e96164684a1e9ebfc/sentry-rails/lib/sentry/rails/error_subscriber.rb) et [Honeybadger](https://docs.honeybadger.io/lib/ruby/integration-guides/rails-exception-tracking/), enregistrent automatiquement un abonné pour vous. Consultez la documentation de votre fournisseur pour plus de détails.

Vous pouvez également créer un abonné personnalisé. Par exemple :

```ruby
# config/initializers/error_subscriber.rb
class ErrorSubscriber
  def report(erreur, géré:, gravité:, contexte:, source: nil)
    MonServiceDeRapportD'Erreurs.rapporter_erreur(erreur, contexte: contexte, géré: géré, niveau: gravité)
  end
end
```

Après avoir défini la classe de l'abonné, enregistrez-la en appelant la méthode [`Rails.error.subscribe`](https://api.rubyonrails.org/classes/ActiveSupport/ErrorReporter.html#method-i-subscribe) :

```ruby
Rails.error.subscribe(ErrorSubscriber.new)
```

Vous pouvez enregistrer autant d'abonnés que vous le souhaitez. Rails les appellera successivement, dans l'ordre dans lequel ils ont été enregistrés.

NOTE : Le rapporteur d'erreurs de Rails appellera toujours les abonnés enregistrés, quel que soit votre environnement. Cependant, de nombreux services de rapport d'erreurs ne signalent que les erreurs en production par défaut. Vous devez configurer et tester votre configuration dans tous les environnements selon vos besoins.

### Utilisation du rapporteur d'erreurs

Il existe trois façons d'utiliser le rapporteur d'erreurs :

#### Signalement et suppression des erreurs

[`Rails.error.handle`](https://api.rubyonrails.org/classes/ActiveSupport/ErrorReporter.html#method-i-handle) signalera toute erreur levée dans le bloc. Elle supprimera ensuite l'erreur, et le reste de votre code en dehors du bloc continuera normalement.

```ruby
résultat = Rails.error.handle do
  1 + '1' # lève TypeError
end
résultat # => nil
1 + 1 # Cela sera exécuté
```

Si aucune erreur n'est levée dans le bloc, `Rails.error.handle` renverra le résultat du bloc, sinon il renverra `nil`. Vous pouvez remplacer cela en fournissant une `fallback` :

```ruby
utilisateur = Rails.error.handle(fallback: -> { Utilisateur.anonyme }) do
  Utilisateur.find_by(params[:id])
end
```

#### Signalement et re-lancement des erreurs

[`Rails.error.record`](https://api.rubyonrails.org/classes/ActiveSupport/ErrorReporter.html#method-i-record) signalera les erreurs à tous les abonnés enregistrés, puis re-lancera l'erreur, ce qui signifie que le reste de votre code ne sera pas exécuté.

```ruby
Rails.error.record do
  1 + '1' # lève TypeError
end
1 + 1 # Cela ne sera pas exécuté
```

Si aucune erreur n'est levée dans le bloc, `Rails.error.record` renverra le résultat du bloc.

#### Signalement manuel des erreurs

Vous pouvez également signaler manuellement des erreurs en appelant [`Rails.error.report`](https://api.rubyonrails.org/classes/ActiveSupport/ErrorReporter.html#method-i-report) :

```ruby
begin
  # code
rescue StandardError => e
  Rails.error.report(e)
end
```

Toutes les options que vous transmettez seront transmises aux abonnés d'erreurs.

### Options de signalement d'erreurs

Les 3 API de signalement (`#handle`, `#record` et `#report`) prennent en charge les options suivantes, qui sont ensuite transmises à tous les abonnés enregistrés :

- `géré` : un `Boolean` pour indiquer si l'erreur a été gérée. Cela est défini par défaut sur `true`. `#record` le définit sur `false`.
- `gravité` : un `Symbol` décrivant la gravité de l'erreur. Les valeurs attendues sont : `:error`, `:warning` et `:info`. `#handle` le définit sur `:warning`, tandis que `#record` le définit sur `:error`.
- `contexte` : un `Hash` pour fournir plus de contexte sur l'erreur, comme les détails de la requête ou de l'utilisateur.
- `source` : une `String` sur la source de l'erreur. La source par défaut est `"application"`. Les erreurs signalées par des bibliothèques internes peuvent utiliser d'autres sources ; par exemple, la bibliothèque de cache Redis peut utiliser `"redis_cache_store.active_support"`. Votre abonné peut utiliser la source pour ignorer les erreurs qui ne vous intéressent pas.
```ruby
Rails.error.handle(contexte: { user_id: user.id }, gravite: :info) do
  # ...
end
```

### Filtrage par classes d'erreurs

Avec `Rails.error.handle` et `Rails.error.record`, vous pouvez également choisir de ne signaler que les erreurs de certaines classes. Par exemple:

```ruby
Rails.error.handle(IOError) do
  1 + '1' # lève TypeError
end
1 + 1 # Les TypeErrors ne sont pas des IOError, donc cela ne sera *pas* exécuté
```

Ici, le `TypeError` ne sera pas capturé par le rapporteur d'erreurs de Rails. Seules les instances de `IOError` et de ses descendants seront signalées. Toutes les autres erreurs seront levées normalement.

### Définition du contexte globalement

En plus de définir le contexte via l'option `contexte`, vous pouvez utiliser l'API [`#set_context`](https://api.rubyonrails.org/classes/ActiveSupport/ErrorReporter.html#method-i-set_context). Par exemple:

```ruby
Rails.error.set_context(section: "checkout", user_id: @user.id)
```

Tout contexte défini de cette manière sera fusionné avec l'option `contexte`

```ruby
Rails.error.set_context(a: 1)
Rails.error.handle(contexte: { b: 2 }) { raise }
# Le contexte signalé sera: {:a=>1, :b=>2}
Rails.error.handle(contexte: { b: 3 }) { raise }
# Le contexte signalé sera: {:a=>1, :b=>3}
```

### Pour les bibliothèques

Les bibliothèques de signalement d'erreurs peuvent enregistrer leurs abonnés dans un `Railtie`:

```ruby
module MySdk
  class Railtie < ::Rails::Railtie
    initializer "my_sdk.error_subscribe" do
      Rails.error.subscribe(MyErrorSubscriber.new)
    end
  end
end
```

Si vous enregistrez un abonné d'erreur, mais que vous avez toujours d'autres mécanismes d'erreur comme un middleware Rack, vous risquez de signaler les erreurs plusieurs fois. Vous devez soit supprimer vos autres mécanismes, soit ajuster votre fonctionnalité de rapport pour qu'elle ignore le signalement d'une exception qu'elle a déjà rencontrée.
