**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 320082396ef549e27ab4cb837ec975dd
Callbacks Active Record
=======================

Ce guide vous apprend comment vous connecter au cycle de vie de vos objets Active Record.

Après avoir lu ce guide, vous saurez :

* Quand certains événements se produisent pendant la vie d'un objet Active Record
* Comment créer des méthodes de rappel qui répondent aux événements du cycle de vie de l'objet.
* Comment créer des classes spéciales qui encapsulent un comportement commun pour vos rappels.

--------------------------------------------------------------------------------

Le Cycle de Vie de l'Objet
---------------------

Pendant le fonctionnement normal d'une application Rails, des objets peuvent être créés, mis à jour et détruits. Active Record fournit des points d'accroche dans ce *cycle de vie de l'objet* afin que vous puissiez contrôler votre application et ses données.

Les rappels vous permettent de déclencher une logique avant ou après une modification de l'état d'un objet.

```ruby
class Baby < ApplicationRecord
  after_create -> { puts "Félicitations !" }
end
```

```irb
irb> @baby = Baby.create
Félicitations !
```

Comme vous le verrez, il existe de nombreux événements du cycle de vie et vous pouvez choisir de vous accrocher à l'un d'entre eux, avant, après, voire pendant.

Aperçu des Rappels
------------------

Les rappels sont des méthodes qui sont appelées à certains moments du cycle de vie d'un objet. Grâce aux rappels, il est possible d'écrire du code qui s'exécutera chaque fois qu'un objet Active Record est créé, enregistré, mis à jour, supprimé, validé ou chargé depuis la base de données.

### Enregistrement des Rappels

Pour utiliser les rappels disponibles, vous devez les enregistrer. Vous pouvez implémenter les rappels en tant que méthodes ordinaires et utiliser une méthode de classe de style macro pour les enregistrer en tant que rappels :

```ruby
class User < ApplicationRecord
  validates :login, :email, presence: true

  before_validation :ensure_login_has_a_value

  private
    def ensure_login_has_a_value
      if login.blank?
        self.login = email unless email.blank?
      end
    end
end
```

Les méthodes de classe de style macro peuvent également recevoir un bloc. Utilisez ce style si le code à l'intérieur de votre bloc est si court qu'il tient sur une seule ligne :

```ruby
class User < ApplicationRecord
  validates :login, :email, presence: true

  before_create do
    self.name = login.capitalize if name.blank?
  end
end
```

Vous pouvez également passer un procédure au rappel à déclencher.

```ruby
class User < ApplicationRecord
  before_create ->(user) { user.name = user.login.capitalize if user.name.blank? }
end
```

Enfin, vous pouvez définir votre propre objet de rappel personnalisé, que nous aborderons plus en détail plus tard [ci-dessous](#callback-classes).

```ruby
class User < ApplicationRecord
  before_create MaybeAddName
end

class MaybeAddName
  def self.before_create(record)
    if record.name.blank?
      record.name = record.login.capitalize
    end
  end
end
```

Les rappels peuvent également être enregistrés pour ne se déclencher que lors de certains événements du cycle de vie, ce qui permet un contrôle complet sur le moment et le contexte dans lequel vos rappels sont déclenchés.

```ruby
class User < ApplicationRecord
  before_validation :normalize_name, on: :create

  # :on prend également un tableau
  after_validation :set_location, on: [ :create, :update ]

  private
    def normalize_name
      self.name = name.downcase.titleize
    end

    def set_location
      self.location = LocationService.query(self)
    end
end
```

Il est considéré comme une bonne pratique de déclarer les méthodes de rappel comme privées. Si elles sont laissées publiques, elles peuvent être appelées depuis l'extérieur du modèle et violer le principe d'encapsulation des objets.

ATTENTION. Évitez les appels à `update`, `save` ou d'autres méthodes qui créent des effets secondaires sur l'objet à l'intérieur de votre rappel. Par exemple, n'appelez pas `update(attribute: "valeur")` dans un rappel. Cela peut modifier l'état du modèle et entraîner des effets secondaires inattendus lors de la validation. À la place, vous pouvez assigner en toute sécurité des valeurs directement (par exemple, `self.attribute = "valeur"`) dans `before_create` / `before_update` ou dans des rappels antérieurs.

Rappels Disponibles
-------------------

Voici une liste de tous les rappels disponibles dans Active Record, répertoriés dans le même ordre dans lequel ils seront appelés lors des opérations respectives :

### Création d'un Objet

* [`before_validation`][]
* [`after_validation`][]
* [`before_save`][]
* [`around_save`][]
* [`before_create`][]
* [`around_create`][]
* [`after_create`][]
* [`after_save`][]
* [`after_commit`][] / [`after_rollback`][]


### Mise à Jour d'un Objet

* [`before_validation`][]
* [`after_validation`][]
* [`before_save`][]
* [`around_save`][]
* [`before_update`][]
* [`around_update`][]
* [`after_update`][]
* [`after_save`][]
* [`after_commit`][] / [`after_rollback`][]


ATTENTION. `after_save` s'exécute à la fois lors de la création et de la mise à jour, mais toujours _après_ les rappels plus spécifiques `after_create` et `after_update`, quel que soit l'ordre dans lequel les appels de macro ont été exécutés.

### Suppression d'un Objet

* [`before_destroy`][]
* [`around_destroy`][]
* [`after_destroy`][]
* [`after_commit`][] / [`after_rollback`][]


REMARQUE : Les rappels `before_destroy` doivent être placés avant les associations `dependent: :destroy` (ou utiliser l'option `prepend: true`), pour s'assurer qu'ils s'exécutent avant la suppression des enregistrements par `dependent: :destroy`.

ATTENTION. `after_commit` offre des garanties très différentes de `after_save`, `after_update` et `after_destroy`. Par exemple, si une exception se produit dans un `after_save`, la transaction sera annulée et les données ne seront pas persistées. Tandis que tout ce qui se passe `after_commit` peut garantir que la transaction est déjà terminée et que les données ont été persistées dans la base de données. Plus d'informations sur les [rappels transactionnels](#transaction-callbacks) ci-dessous.
### `after_initialize` et `after_find`

Chaque fois qu'un objet Active Record est instancié, le rappel [`after_initialize`][] est appelé, que ce soit en utilisant directement `new` ou lorsqu'un enregistrement est chargé depuis la base de données. Cela peut être utile pour éviter de devoir remplacer directement la méthode `initialize` de votre Active Record.

Lors du chargement d'un enregistrement depuis la base de données, le rappel [`after_find`][] est appelé. `after_find` est appelé avant `after_initialize` si les deux sont définis.

NOTE : Les rappels `after_initialize` et `after_find` n'ont pas de contreparties `before_*`.

Ils peuvent être enregistrés de la même manière que les autres rappels Active Record.

```ruby
class User < ApplicationRecord
  after_initialize do |user|
    puts "Vous avez initialisé un objet !"
  end

  after_find do |user|
    puts "Vous avez trouvé un objet !"
  end
end
```

```irb
irb> User.new
Vous avez initialisé un objet !
=> #<User id: nil>

irb> User.first
Vous avez trouvé un objet !
Vous avez initialisé un objet !
=> #<User id: 1>
```


### `after_touch`

Le rappel [`after_touch`][] est appelé chaque fois qu'un objet Active Record est touché.

```ruby
class User < ApplicationRecord
  after_touch do |user|
    puts "Vous avez touché un objet"
  end
end
```

```irb
irb> u = User.create(name: 'Kuldeep')
=> #<User id: 1, name: "Kuldeep", created_at: "2013-11-25 12:17:49", updated_at: "2013-11-25 12:17:49">

irb> u.touch
Vous avez touché un objet
=> true
```

Il peut être utilisé avec `belongs_to` :

```ruby
class Book < ApplicationRecord
  belongs_to :library, touch: true
  after_touch do
    puts 'Un livre a été touché'
  end
end

class Library < ApplicationRecord
  has_many :books
  after_touch :log_when_books_or_library_touched

  private
    def log_when_books_or_library_touched
      puts 'Un livre/une bibliothèque a été touché(e)'
    end
end
```

```irb
irb> @book = Book.last
=> #<Book id: 1, library_id: 1, created_at: "2013-11-25 17:04:22", updated_at: "2013-11-25 17:05:05">

irb> @book.touch # déclenche @book.library.touch
Un livre a été touché
Un livre/une bibliothèque a été touché(e)
=> true
```


Exécution des rappels
-----------------

Les méthodes suivantes déclenchent des rappels :

* `create`
* `create!`
* `destroy`
* `destroy!`
* `destroy_all`
* `destroy_by`
* `save`
* `save!`
* `save(validate: false)`
* `toggle!`
* `touch`
* `update_attribute`
* `update`
* `update!`
* `valid?`

De plus, le rappel `after_find` est déclenché par les méthodes de recherche suivantes :

* `all`
* `first`
* `find`
* `find_by`
* `find_by_*`
* `find_by_*!`
* `find_by_sql`
* `last`

Le rappel `after_initialize` est déclenché à chaque fois qu'un nouvel objet de la classe est initialisé.

NOTE : Les méthodes `find_by_*` et `find_by_*!` sont des finders dynamiques générés automatiquement pour chaque attribut. En savoir plus à leur sujet dans la section [Finders dynamiques](active_record_querying.html#dynamic-finders)

Passer outre les rappels
------------------

Tout comme avec les validations, il est également possible de passer outre les rappels en utilisant les méthodes suivantes :

* `decrement!`
* `decrement_counter`
* `delete`
* `delete_all`
* `delete_by`
* `increment!`
* `increment_counter`
* `insert`
* `insert!`
* `insert_all`
* `insert_all!`
* `touch_all`
* `update_column`
* `update_columns`
* `update_all`
* `update_counters`
* `upsert`
* `upsert_all`

Ces méthodes doivent être utilisées avec prudence, car des règles métier importantes et de la logique d'application peuvent être conservées dans les rappels. Les contourner sans comprendre les implications potentielles peut conduire à des données invalides.

Arrêt de l'exécution
-----------------

Lorsque vous commencez à enregistrer de nouveaux rappels pour vos modèles, ils sont mis en file d'attente pour l'exécution. Cette file d'attente comprend toutes les validations de votre modèle, les rappels enregistrés et l'opération de base de données à exécuter.

Toute la chaîne de rappels est enveloppée dans une transaction. Si un rappel génère une exception, la chaîne d'exécution est interrompue et un ROLLBACK est effectué. Pour arrêter intentionnellement une chaîne, utilisez :

```ruby
throw :abort
```

ATTENTION. Toute exception qui n'est pas `ActiveRecord::Rollback` ou `ActiveRecord::RecordInvalid` sera relancée par Rails après l'arrêt de la chaîne de rappels. De plus, cela peut casser du code qui n'attend pas que les méthodes comme `save` et `update` (qui essaient normalement de renvoyer `true` ou `false`) génèrent une exception.

NOTE : Si une exception `ActiveRecord::RecordNotDestroyed` est levée dans le rappel `after_destroy`, `before_destroy` ou `around_destroy`, elle ne sera pas relancée et la méthode `destroy` renverra `false`.

Rappels relationnels
--------------------

Les rappels fonctionnent à travers les relations entre les modèles et peuvent même être définis par eux. Supposons un exemple où un utilisateur a plusieurs articles. Les articles d'un utilisateur doivent être détruits si l'utilisateur est détruit. Ajoutons un rappel `after_destroy` au modèle `User` via sa relation avec le modèle `Article` :

```ruby
class User < ApplicationRecord
  has_many :articles, dependent: :destroy
end

class Article < ApplicationRecord
  after_destroy :log_destroy_action

  def log_destroy_action
    puts 'Article détruit'
  end
end
```

```irb
irb> user = User.first
=> #<User id: 1>
irb> user.articles.create!
=> #<Article id: 1, user_id: 1>
irb> user.destroy
Article détruit
=> #<User id: 1>
```
Rappels conditionnels
---------------------

Tout comme avec les validations, nous pouvons également conditionner l'appel d'une méthode de rappel en fonction de la satisfaction d'un prédicat donné. Nous pouvons le faire en utilisant les options `:if` et `:unless`, qui peuvent prendre un symbole, un `Proc` ou un tableau.

Vous pouvez utiliser l'option `:if` lorsque vous souhaitez spécifier dans quelles conditions le rappel **doit** être appelé. Si vous souhaitez spécifier les conditions dans lesquelles le rappel **ne doit pas** être appelé, vous pouvez utiliser l'option `:unless`.

### Utilisation de `:if` et `:unless` avec un `Symbole`

Vous pouvez associer les options `:if` et `:unless` à un symbole correspondant au nom d'une méthode prédicat qui sera appelée juste avant le rappel.

Lorsque vous utilisez l'option `:if`, le rappel **ne sera pas** exécuté si la méthode prédicat renvoie **false** ; lorsque vous utilisez l'option `:unless`, le rappel **ne sera pas** exécuté si la méthode prédicat renvoie **true**. C'est l'option la plus courante.

```ruby
class Order < ApplicationRecord
  before_save :normalize_card_number, if: :paid_with_card?
end
```

En utilisant cette forme d'enregistrement, il est également possible d'enregistrer plusieurs prédicats différents qui doivent être appelés pour vérifier si le rappel doit être exécuté. Nous aborderons cela [ci-dessous](#multiple-callback-conditions).

### Utilisation de `:if` et `:unless` avec un `Proc`

Il est possible d'associer `:if` et `:unless` à un objet `Proc`. Cette option est particulièrement adaptée lors de l'écriture de méthodes de validation courtes, généralement d'une seule ligne :

```ruby
class Order < ApplicationRecord
  before_save :normalize_card_number,
    if: Proc.new { |order| order.paid_with_card? }
end
```

Comme le `proc` est évalué dans le contexte de l'objet, il est également possible d'écrire ceci :

```ruby
class Order < ApplicationRecord
  before_save :normalize_card_number, if: Proc.new { paid_with_card? }
end
```

### Conditions de rappel multiples

Les options `:if` et `:unless` acceptent également un tableau de procs ou de noms de méthodes sous forme de symboles :

```ruby
class Comment < ApplicationRecord
  before_save :filter_content,
    if: [:subject_to_parental_control?, :untrusted_author?]
end
```

Vous pouvez facilement inclure un proc dans la liste des conditions :

```ruby
class Comment < ApplicationRecord
  before_save :filter_content,
    if: [:subject_to_parental_control?, Proc.new { untrusted_author? }]
end
```

### Utilisation de `:if` et `:unless` ensemble

Les rappels peuvent mélanger à la fois `:if` et `:unless` dans la même déclaration :

```ruby
class Comment < ApplicationRecord
  before_save :filter_content,
    if: Proc.new { forum.parental_control? },
    unless: Proc.new { author.trusted? }
end
```

Le rappel ne s'exécute que lorsque toutes les conditions `:if` sont évaluées à `true` et aucune des conditions `:unless` n'est évaluée à `true`.

Classes de rappels
----------------

Parfois, les méthodes de rappel que vous écrirez seront suffisamment utiles pour être réutilisées par d'autres modèles. Active Record permet de créer des classes qui encapsulent les méthodes de rappel, afin qu'elles puissent être réutilisées.

Voici un exemple où nous créons une classe avec un rappel `after_destroy` pour gérer la suppression des fichiers supprimés sur le système de fichiers. Ce comportement peut ne pas être unique à notre modèle `PictureFile` et nous souhaitons peut-être le partager, il est donc judicieux de l'encapsuler dans une classe distincte. Cela facilitera les tests de ce comportement et sa modification.

```ruby
class FileDestroyerCallback
  def after_destroy(file)
    if File.exist?(file.filepath)
      File.delete(file.filepath)
    end
  end
end
```

Lorsqu'ils sont déclarés à l'intérieur d'une classe, comme ci-dessus, les méthodes de rappel recevront l'objet du modèle en tant que paramètre. Cela fonctionnera sur n'importe quel modèle qui utilise la classe de la manière suivante :

```ruby
class PictureFile < ApplicationRecord
  after_destroy FileDestroyerCallback.new
end
```

Notez que nous avons dû instancier un nouvel objet `FileDestroyerCallback`, car nous avons déclaré notre rappel en tant que méthode d'instance. Cela est particulièrement utile si les rappels utilisent l'état de l'objet instancié. Cependant, il sera souvent plus logique de déclarer les rappels en tant que méthodes de classe :

```ruby
class FileDestroyerCallback
  def self.after_destroy(file)
    if File.exist?(file.filepath)
      File.delete(file.filepath)
    end
  end
end
```

Lorsque la méthode de rappel est déclarée de cette manière, il ne sera pas nécessaire d'instancier un nouvel objet `FileDestroyerCallback` dans notre modèle.

```ruby
class PictureFile < ApplicationRecord
  after_destroy FileDestroyerCallback
end
```

Vous pouvez déclarer autant de rappels que vous le souhaitez à l'intérieur de vos classes de rappel.

Rappels de transaction
---------------------

### Gestion de la cohérence

Il existe deux rappels supplémentaires qui sont déclenchés à la fin d'une transaction de base de données : [`after_commit`][] et [`after_rollback`][]. Ces rappels sont très similaires au rappel `after_save`, à la différence qu'ils ne s'exécutent qu'après que les modifications de la base de données ont été validées ou annulées. Ils sont particulièrement utiles lorsque vos modèles Active Record doivent interagir avec des systèmes externes qui ne font pas partie de la transaction de base de données.
Considérez, par exemple, l'exemple précédent où le modèle `PictureFile` doit supprimer un fichier après la destruction de l'enregistrement correspondant. Si une exception est levée après l'appel du rappel `after_destroy` et que la transaction est annulée, le fichier aura été supprimé et le modèle sera dans un état incohérent. Par exemple, supposons que `picture_file_2` dans le code ci-dessous n'est pas valide et que la méthode `save!` génère une erreur.

```ruby
PictureFile.transaction do
  picture_file_1.destroy
  picture_file_2.save!
end
```

En utilisant le rappel `after_commit`, nous pouvons prendre en compte ce cas.

```ruby
class PictureFile < ApplicationRecord
  after_commit :delete_picture_file_from_disk, on: :destroy

  def delete_picture_file_from_disk
    if File.exist?(filepath)
      File.delete(filepath)
    end
  end
end
```

NOTE : L'option `:on` spécifie quand un rappel sera déclenché. Si vous ne fournissez pas l'option `:on`, le rappel sera déclenché pour chaque action.

### Le contexte est important

Étant donné que l'utilisation du rappel `after_commit` uniquement lors de la création, de la mise à jour ou de la suppression est courante, il existe des alias pour ces opérations :

* [`after_create_commit`][]
* [`after_update_commit`][]
* [`after_destroy_commit`][]

```ruby
class PictureFile < ApplicationRecord
  after_destroy_commit :delete_picture_file_from_disk

  def delete_picture_file_from_disk
    if File.exist?(filepath)
      File.delete(filepath)
    end
  end
end
```

AVERTISSEMENT. Lorsqu'une transaction est terminée, les rappels `after_commit` ou `after_rollback` sont appelés pour tous les modèles créés, mis à jour ou supprimés dans cette transaction. Cependant, si une exception est levée dans l'un de ces rappels, l'exception remontera et les méthodes `after_commit` ou `after_rollback` restantes ne seront pas exécutées. Par conséquent, si votre code de rappel peut générer une exception, vous devrez la capturer et la gérer dans le rappel afin de permettre l'exécution des autres rappels.

AVERTISSEMENT. Le code exécuté dans les rappels `after_commit` ou `after_rollback` n'est pas lui-même inclus dans une transaction.

AVERTISSEMENT. Utiliser à la fois `after_create_commit` et `after_update_commit` avec le même nom de méthode ne permettra que le dernier rappel défini d'être pris en compte, car ils sont tous deux des alias internes de `after_commit` qui remplace les rappels précédemment définis avec le même nom de méthode.

```ruby
class User < ApplicationRecord
  after_create_commit :log_user_saved_to_db
  after_update_commit :log_user_saved_to_db

  private
    def log_user_saved_to_db
      puts 'L\'utilisateur a été enregistré dans la base de données'
    end
end
```

```irb
irb> @user = User.create # ne rien afficher

irb> @user.save # mise à jour de @user
L'utilisateur a été enregistré dans la base de données
```

### `after_save_commit`

Il y a aussi [`after_save_commit`][], qui est un alias pour utiliser le rappel `after_commit` à la fois pour la création et la mise à jour ensemble :

```ruby
class User < ApplicationRecord
  after_save_commit :log_user_saved_to_db

  private
    def log_user_saved_to_db
      puts 'L\'utilisateur a été enregistré dans la base de données'
    end
end
```

```irb
irb> @user = User.create # création d'un utilisateur
L'utilisateur a été enregistré dans la base de données

irb> @user.save # mise à jour de @user
L'utilisateur a été enregistré dans la base de données
```

### Ordre des rappels transactionnels

Lors de la définition de plusieurs rappels transactionnels `after_` (`after_commit`, `after_rollback`, etc), l'ordre sera inversé par rapport à leur définition.

```ruby
class User < ActiveRecord::Base
  after_commit { puts("Ceci est en fait appelé en second") }
  after_commit { puts("Ceci est en fait appelé en premier") }
end
```

NOTE : Cela s'applique également à toutes les variations de `after_*_commit`, telles que `after_destroy_commit`.
[`after_create`]: https://api.rubyonrails.org/classes/ActiveRecord/Callbacks/ClassMethods.html#method-i-after_create
[`after_commit`]: https://api.rubyonrails.org/classes/ActiveRecord/Transactions/ClassMethods.html#method-i-after_commit
[`after_rollback`]: https://api.rubyonrails.org/classes/ActiveRecord/Transactions/ClassMethods.html#method-i-after_rollback
[`after_save`]: https://api.rubyonrails.org/classes/ActiveRecord/Callbacks/ClassMethods.html#method-i-after_save
[`after_validation`]: https://api.rubyonrails.org/classes/ActiveModel/Validations/Callbacks/ClassMethods.html#method-i-after_validation
[`around_create`]: https://api.rubyonrails.org/classes/ActiveRecord/Callbacks/ClassMethods.html#method-i-around_create
[`around_save`]: https://api.rubyonrails.org/classes/ActiveRecord/Callbacks/ClassMethods.html#method-i-around_save
[`before_create`]: https://api.rubyonrails.org/classes/ActiveRecord/Callbacks/ClassMethods.html#method-i-before_create
[`before_save`]: https://api.rubyonrails.org/classes/ActiveRecord/Callbacks/ClassMethods.html#method-i-before_save
[`before_validation`]: https://api.rubyonrails.org/classes/ActiveModel/Validations/Callbacks/ClassMethods.html#method-i-before_validation
[`after_update`]: https://api.rubyonrails.org/classes/ActiveRecord/Callbacks/ClassMethods.html#method-i-after_update
[`around_update`]: https://api.rubyonrails.org/classes/ActiveRecord/Callbacks/ClassMethods.html#method-i-around_update
[`before_update`]: https://api.rubyonrails.org/classes/ActiveRecord/Callbacks/ClassMethods.html#method-i-before_update
[`after_destroy`]: https://api.rubyonrails.org/classes/ActiveRecord/Callbacks/ClassMethods.html#method-i-after_destroy
[`around_destroy`]: https://api.rubyonrails.org/classes/ActiveRecord/Callbacks/ClassMethods.html#method-i-around_destroy
[`before_destroy`]: https://api.rubyonrails.org/classes/ActiveRecord/Callbacks/ClassMethods.html#method-i-before_destroy
[`after_find`]: https://api.rubyonrails.org/classes/ActiveRecord/Callbacks/ClassMethods.html#method-i-after_find
[`after_initialize`]: https://api.rubyonrails.org/classes/ActiveRecord/Callbacks/ClassMethods.html#method-i-after_initialize
[`after_touch`]: https://api.rubyonrails.org/classes/ActiveRecord/Callbacks/ClassMethods.html#method-i-after_touch
[`after_create_commit`]: https://api.rubyonrails.org/classes/ActiveRecord/Transactions/ClassMethods.html#method-i-after_create_commit
[`after_destroy_commit`]: https://api.rubyonrails.org/classes/ActiveRecord/Transactions/ClassMethods.html#method-i-after_destroy_commit
[`after_save_commit`]: https://api.rubyonrails.org/classes/ActiveRecord/Transactions/ClassMethods.html#method-i-after_save_commit
[`after_update_commit`]: https://api.rubyonrails.org/classes/ActiveRecord/Transactions/ClassMethods.html#method-i-after_update_commit
