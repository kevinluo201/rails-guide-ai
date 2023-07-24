**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 37dd3507f05f7787a794868a2619e6d5
Validations Active Record
=========================

Ce guide vous apprend comment valider l'état des objets avant qu'ils ne soient enregistrés dans la base de données en utilisant la fonctionnalité de validations d'Active Record.

Après avoir lu ce guide, vous saurez :

* Comment utiliser les helpers de validation intégrés à Active Record.
* Comment créer vos propres méthodes de validation personnalisées.
* Comment travailler avec les messages d'erreur générés par le processus de validation.

--------------------------------------------------------------------------------

Aperçu des validations
--------------------

Voici un exemple de validation très simple :

```ruby
class Person < ApplicationRecord
  validates :name, presence: true
end
```

```irb
irb> Person.create(name: "John Doe").valid?
=> true
irb> Person.create(name: nil).valid?
=> false
```

Comme vous pouvez le voir, notre validation nous indique que notre `Person` n'est pas valide sans un attribut `name`. La deuxième `Person` ne sera pas persistée dans la base de données.

Avant d'approfondir les détails, parlons de la place des validations dans l'ensemble de votre application.

### Pourquoi utiliser des validations ?

Les validations sont utilisées pour s'assurer que seules des données valides sont enregistrées dans votre base de données. Par exemple, il peut être important pour votre application de s'assurer que chaque utilisateur fournit une adresse e-mail et une adresse postale valides. Les validations au niveau du modèle sont le meilleur moyen de garantir que seules des données valides sont enregistrées dans votre base de données. Elles sont indépendantes de la base de données, ne peuvent pas être contournées par les utilisateurs finaux et sont pratiques à tester et à maintenir. Rails fournit des helpers intégrés pour les besoins courants et vous permet également de créer vos propres méthodes de validation.

Il existe plusieurs autres façons de valider les données avant qu'elles ne soient enregistrées dans votre base de données, notamment les contraintes natives de la base de données, les validations côté client et les validations au niveau du contrôleur. Voici un résumé des avantages et des inconvénients :

* Les contraintes de base de données et/ou les procédures stockées rendent les mécanismes de validation dépendants de la base de données et peuvent rendre les tests et la maintenance plus difficiles. Cependant, si votre base de données est utilisée par d'autres applications, il peut être judicieux d'utiliser certaines contraintes au niveau de la base de données. De plus, les validations au niveau de la base de données peuvent gérer en toute sécurité certaines choses (comme l'unicité dans les tables très utilisées) qui peuvent être difficiles à implémenter autrement.
* Les validations côté client peuvent être utiles, mais elles sont généralement peu fiables si elles sont utilisées seules. Si elles sont implémentées en utilisant JavaScript, elles peuvent être contournées si JavaScript est désactivé dans le navigateur de l'utilisateur. Cependant, combinées à d'autres techniques, les validations côté client peuvent être un moyen pratique de fournir aux utilisateurs un retour immédiat lorsqu'ils utilisent votre site.
* Les validations au niveau du contrôleur peuvent être tentantes à utiliser, mais elles deviennent souvent lourdes et difficiles à tester et à maintenir. Dans la mesure du possible, il est conseillé de garder vos contrôleurs simples, car cela rendra votre application agréable à utiliser à long terme.

Utilisez-les dans certains cas spécifiques. L'équipe de Rails estime que les validations au niveau du modèle sont les plus appropriées dans la plupart des cas.

### Quand les validations se produisent-elles ?

Il existe deux types d'objets Active Record : ceux qui correspondent à une ligne dans votre base de données et ceux qui n'y correspondent pas. Lorsque vous créez un nouvel objet, par exemple en utilisant la méthode `new`, cet objet n'appartient pas encore à la base de données. Une fois que vous appelez `save` sur cet objet, il sera enregistré dans la table de base de données appropriée. Active Record utilise la méthode d'instance `new_record?` pour déterminer si un objet est déjà dans la base de données ou non. Considérons la classe Active Record suivante :

```ruby
class Person < ApplicationRecord
end
```

Nous pouvons voir comment cela fonctionne en examinant la sortie de `bin/rails console` :

```irb
irb> p = Person.new(name: "John Doe")
=> #<Person id: nil, name: "John Doe", created_at: nil, updated_at: nil>

irb> p.new_record?
=> true

irb> p.save
=> true

irb> p.new_record?
=> false
```

La création et l'enregistrement d'un nouvel enregistrement enverront une opération SQL `INSERT` à la base de données. La mise à jour d'un enregistrement existant enverra une opération SQL `UPDATE`. Les validations sont généralement exécutées avant l'envoi de ces commandes à la base de données. Si une validation échoue, l'objet sera marqué comme invalide et Active Record n'effectuera pas l'opération `INSERT` ou `UPDATE`. Cela évite de stocker un objet invalide dans la base de données. Vous pouvez choisir d'exécuter des validations spécifiques lorsqu'un objet est créé, enregistré ou mis à jour.

ATTENTION : Il existe de nombreuses façons de modifier l'état d'un objet dans la base de données. Certaines méthodes déclencheront des validations, mais d'autres non. Cela signifie qu'il est possible d'enregistrer un objet dans la base de données dans un état invalide si vous n'êtes pas prudent.
Les méthodes suivantes déclenchent des validations et ne sauvegardent l'objet dans la base de données que si l'objet est valide :

* `create`
* `create!`
* `save`
* `save!`
* `update`
* `update!`

Les versions avec un point d'exclamation (par exemple `save!`) lèvent une exception si l'enregistrement est invalide. Les versions sans point d'exclamation ne le font pas : `save` et `update` renvoient `false`, et `create` renvoie l'objet.

### Ignorer les validations

Les méthodes suivantes ignorent les validations et sauvegardent l'objet dans la base de données quel que soit sa validité. Elles doivent être utilisées avec prudence.

* `decrement!`
* `decrement_counter`
* `increment!`
* `increment_counter`
* `insert`
* `insert!`
* `insert_all`
* `insert_all!`
* `toggle!`
* `touch`
* `touch_all`
* `update_all`
* `update_attribute`
* `update_column`
* `update_columns`
* `update_counters`
* `upsert`
* `upsert_all`

Notez que `save` a également la possibilité d'ignorer les validations si `validate: false` est passé en argument. Cette technique doit être utilisée avec prudence.

* `save(validate: false)`

### `valid?` et `invalid?`

Avant de sauvegarder un objet Active Record, Rails exécute vos validations. Si ces validations produisent des erreurs, Rails ne sauvegarde pas l'objet.

Vous pouvez également exécuter ces validations vous-même. [`valid?`][] déclenche vos validations et renvoie `true` s'il n'y a aucune erreur dans l'objet, et `false` sinon. Comme vous l'avez vu ci-dessus :

```ruby
class Person < ApplicationRecord
  validates :name, presence: true
end
```

```irb
irb> Person.create(name: "John Doe").valid?
=> true
irb> Person.create(name: nil).valid?
=> false
```

Après que Active Record ait effectué les validations, les échecs peuvent être consultés via la méthode d'instance [`errors`][]. Celle-ci renvoie une collection d'erreurs. Par définition, un objet est valide si cette collection est vide après l'exécution des validations.

Notez qu'un objet instancié avec `new` ne signalera pas d'erreurs même s'il est techniquement invalide, car les validations ne sont automatiquement exécutées que lorsque l'objet est sauvegardé, par exemple avec les méthodes `create` ou `save`.

```ruby
class Person < ApplicationRecord
  validates :name, presence: true
end
```

```irb
irb> p = Person.new
=> #<Person id: nil, name: nil>
irb> p.errors.size
=> 0

irb> p.valid?
=> false
irb> p.errors.objects.first.full_message
=> "Name can’t be blank"

irb> p = Person.create
=> #<Person id: nil, name: nil>
irb> p.errors.objects.first.full_message
=> "Name can’t be blank"

irb> p.save
=> false

irb> p.save!
ActiveRecord::RecordInvalid: Validation failed: Name can’t be blank

irb> Person.create!
ActiveRecord::RecordInvalid: Validation failed: Name can’t be blank
```

[`invalid?`][] est l'inverse de `valid?`. Elle déclenche vos validations, renvoyant `true` si des erreurs ont été trouvées dans l'objet, et `false` sinon.


### `errors[]`

Pour vérifier si un attribut particulier d'un objet est valide ou non, vous pouvez utiliser [`errors[:attribut]`][Errors#squarebrackets]. Elle renvoie un tableau de tous les messages d'erreur pour `:attribut`. Si aucun erreur n'est présente sur l'attribut spécifié, un tableau vide est renvoyé.

Cette méthode n'est utile qu'_après_ l'exécution des validations, car elle ne fait qu'inspecter la collection d'erreurs et ne déclenche pas les validations elles-mêmes. Elle est différente de la méthode `ActiveRecord::Base#invalid?` expliquée ci-dessus car elle ne vérifie pas la validité de l'objet dans son ensemble. Elle vérifie uniquement s'il y a des erreurs sur un attribut individuel de l'objet.

```ruby
class Person < ApplicationRecord
  validates :name, presence: true
end
```

```irb
irb> Person.new.errors[:name].any?
=> false
irb> Person.create.errors[:name].any?
=> true
```

Nous aborderons les erreurs de validation plus en détail dans la section [Travailler avec les erreurs de validation](#working-with-validation-errors).


Aides à la validation
------------------

Active Record propose de nombreux assistants de validation prédéfinis que vous pouvez utiliser directement dans vos définitions de classe. Ces assistants fournissent des règles de validation courantes. Chaque fois qu'une validation échoue, une erreur est ajoutée à la collection `errors` de l'objet, et celle-ci est associée à l'attribut en cours de validation.

Chaque assistant accepte un nombre arbitraire de noms d'attributs, de sorte qu'avec une seule ligne de code, vous pouvez ajouter le même type de validation à plusieurs attributs.

Tous acceptent les options `:on` et `:message`, qui définissent quand la validation doit être exécutée et quel message doit être ajouté à la collection `errors` en cas d'échec, respectivement. L'option `:on` prend l'une des valeurs `:create` ou `:update`. Il existe un message d'erreur par défaut pour chacun des assistants de validation. Ces messages sont utilisés lorsque l'option `:message` n'est pas spécifiée. Examinons chacun des assistants disponibles.

INFO : Pour voir une liste des assistants par défaut disponibles, consultez [`ActiveModel::Validations::HelperMethods`][].
### `acceptance`

Cette méthode valide si une case à cocher sur l'interface utilisateur a été cochée lorsqu'un formulaire a été soumis. Cela est généralement utilisé lorsque l'utilisateur doit accepter les conditions d'utilisation de votre application, confirmer la lecture d'un texte ou tout autre concept similaire.

```ruby
class Person < ApplicationRecord
  validates :terms_of_service, acceptance: true
end
```

Cette vérification est effectuée uniquement si `terms_of_service` n'est pas `nil`.
Le message d'erreur par défaut pour cet assistant est _"doit être accepté"_.
Vous pouvez également passer un message personnalisé via l'option `message`.

```ruby
class Person < ApplicationRecord
  validates :terms_of_service, acceptance: { message: 'doit être respecté' }
end
```

Il peut également recevoir une option `:accept`, qui détermine les valeurs autorisées qui seront considérées comme acceptables. Par défaut, il est défini sur `['1', true]` et peut être facilement modifié.

```ruby
class Person < ApplicationRecord
  validates :terms_of_service, acceptance: { accept: 'yes' }
  validates :eula, acceptance: { accept: ['TRUE', 'accepted'] }
end
```

Cette validation est très spécifique aux applications web et cette 'acceptance' n'a pas besoin d'être enregistrée dans votre base de données. Si vous n'avez pas de champ pour cela, l'assistant créera un attribut virtuel. Si le champ existe dans votre base de données, l'option `accept` doit être définie sur ou inclure `true`, sinon la validation ne sera pas exécutée.

### `confirmation`

Vous devez utiliser cet assistant lorsque vous avez deux champs de texte qui doivent recevoir exactement le même contenu. Par exemple, vous voudrez peut-être confirmer une adresse e-mail ou un mot de passe. Cette validation crée un attribut virtuel dont le nom est le nom du champ qui doit être confirmé avec "_confirmation" ajouté.

```ruby
class Person < ApplicationRecord
  validates :email, confirmation: true
end
```

Dans votre modèle de vue, vous pouvez utiliser quelque chose comme

```erb
<%= text_field :person, :email %>
<%= text_field :person, :email_confirmation %>
```

NOTE: Cette vérification est effectuée uniquement si `email_confirmation` n'est pas `nil`. Pour exiger une confirmation, assurez-vous d'ajouter une vérification de présence pour l'attribut de confirmation (nous examinerons `presence` [plus tard](#presence) dans ce guide) :

```ruby
class Person < ApplicationRecord
  validates :email, confirmation: true
  validates :email_confirmation, presence: true
end
```

Il existe également une option `:case_sensitive` que vous pouvez utiliser pour définir si la contrainte de confirmation sera sensible à la casse ou non. Cette option est par défaut à `true`.

```ruby
class Person < ApplicationRecord
  validates :email, confirmation: { case_sensitive: false }
end
```

Le message d'erreur par défaut pour cet assistant est _"ne correspond pas à la confirmation"_. Vous pouvez également passer un message personnalisé via l'option `message`.

Généralement, lors de l'utilisation de ce validateur, vous voudrez le combiner avec l'option `:if` pour ne valider le champ "_confirmation" que lorsque le champ initial a été modifié et **pas** à chaque fois que vous enregistrez l'enregistrement. Plus d'informations sur les [validations conditionnelles](#conditional-validation) plus tard.

```ruby
class Person < ApplicationRecord
  validates :email, confirmation: true
  validates :email_confirmation, presence: true, if: :email_changed?
end
```

### `comparison`

Cette vérification valide une comparaison entre deux valeurs comparables.

```ruby
class Promotion < ApplicationRecord
  validates :end_date, comparison: { greater_than: :start_date }
end
```

Le message d'erreur par défaut pour cet assistant est _"comparaison échouée"_. Vous pouvez également passer un message personnalisé via l'option `message`.

Ces options sont toutes prises en charge :

* `:greater_than` - Spécifie que la valeur doit être supérieure à la valeur fournie. Le message d'erreur par défaut pour cette option est _"doit être supérieur à %{count}"_.
* `:greater_than_or_equal_to` - Spécifie que la valeur doit être supérieure ou égale à la valeur fournie. Le message d'erreur par défaut pour cette option est _"doit être supérieur ou égal à %{count}"_.
* `:equal_to` - Spécifie que la valeur doit être égale à la valeur fournie. Le message d'erreur par défaut pour cette option est _"doit être égal à %{count}"_.
* `:less_than` - Spécifie que la valeur doit être inférieure à la valeur fournie. Le message d'erreur par défaut pour cette option est _"doit être inférieur à %{count}"_.
* `:less_than_or_equal_to` - Spécifie que la valeur doit être inférieure ou égale à la valeur fournie. Le message d'erreur par défaut pour cette option est _"doit être inférieur ou égal à %{count}"_.
* `:other_than` - Spécifie que la valeur doit être autre que la valeur fournie. Le message d'erreur par défaut pour cette option est _"doit être autre que %{count}"_.

NOTE: Le validateur nécessite une option de comparaison. Chaque option accepte une valeur, une procédure ou un symbole. Toute classe qui inclut Comparable peut être comparée.
### `format`

Ce helper valide les valeurs des attributs en testant s'ils correspondent à une expression régulière donnée, spécifiée à l'aide de l'option `:with`.

```ruby
class Product < ApplicationRecord
  validates :legacy_code, format: { with: /\A[a-zA-Z]+\z/,
    message: "ne permet que les lettres" }
end
```

Inversement, en utilisant l'option `:without`, vous pouvez exiger que l'attribut spécifié ne corresponde _pas_ à l'expression régulière.

Dans les deux cas, l'option `:with` ou `:without` fournie doit être une expression régulière ou une procédure ou une lambda qui en renvoie une.

Le message d'erreur par défaut est _"n'est pas valide"_.

AVERTISSEMENT. utilisez `\A` et `\z` pour correspondre au début et à la fin de la chaîne, `^` et `$` correspondent au début/fin d'une ligne. En raison d'une utilisation fréquente incorrecte de `^` et `$`, vous devez passer l'option `multiline: true` si vous utilisez l'un de ces deux ancres dans l'expression régulière fournie. Dans la plupart des cas, vous devriez utiliser `\A` et `\z`.

### `inclusion`

Ce helper valide que les valeurs des attributs sont incluses dans un ensemble donné. En fait, cet ensemble peut être n'importe quel objet énumérable.

```ruby
class Coffee < ApplicationRecord
  validates :size, inclusion: { in: %w(small medium large),
    message: "%{value} n'est pas une taille valide" }
end
```

Le helper `inclusion` a une option `:in` qui reçoit l'ensemble de valeurs qui seront acceptées. L'option `:in` a un alias appelé `:within` que vous pouvez utiliser à la même fin, si vous le souhaitez. L'exemple précédent utilise l'option `:message` pour montrer comment vous pouvez inclure la valeur de l'attribut. Pour toutes les options, veuillez consulter la [documentation sur les messages](#message).

Le message d'erreur par défaut pour ce helper est _"n'est pas inclus dans la liste"_.

### `exclusion`

L'opposé de `inclusion` est... `exclusion` !

Ce helper valide que les valeurs des attributs ne sont pas incluses dans un ensemble donné. En fait, cet ensemble peut être n'importe quel objet énumérable.

```ruby
class Account < ApplicationRecord
  validates :subdomain, exclusion: { in: %w(www us ca jp),
    message: "%{value} est réservé." }
end
```

Le helper `exclusion` a une option `:in` qui reçoit l'ensemble de valeurs qui ne seront pas acceptées pour les attributs validés. L'option `:in` a un alias appelé `:within` que vous pouvez utiliser à la même fin, si vous le souhaitez. Cet exemple utilise l'option `:message` pour montrer comment vous pouvez inclure la valeur de l'attribut. Pour toutes les options de l'argument message, veuillez consulter la [documentation sur les messages](#message).

Le message d'erreur par défaut est _"est réservé"_.

Alternativement à un énumérable traditionnel (comme un tableau), vous pouvez fournir une procédure, une lambda ou un symbole qui renvoie un énumérable. Si l'énumérable est une plage numérique, temporelle ou de date et heure, le test est effectué avec `Range#cover?`, sinon avec `include?`. Lorsque vous utilisez une procédure ou une lambda, l'instance en cours de validation est passée en argument.

### `length`

Ce helper valide la longueur des valeurs des attributs. Il offre plusieurs options, vous pouvez donc spécifier des contraintes de longueur de différentes manières :

```ruby
class Person < ApplicationRecord
  validates :name, length: { minimum: 2 }
  validates :bio, length: { maximum: 500 }
  validates :password, length: { in: 6..20 }
  validates :registration_number, length: { is: 6 }
end
```

Les options possibles pour les contraintes de longueur sont :

* `:minimum` - L'attribut ne peut pas avoir une longueur inférieure à celle spécifiée.
* `:maximum` - L'attribut ne peut pas avoir une longueur supérieure à celle spécifiée.
* `:in` (ou `:within`) - La longueur de l'attribut doit être incluse dans un intervalle donné. La valeur pour cette option doit être une plage.
* `:is` - La longueur de l'attribut doit être égale à la valeur donnée.

Les messages d'erreur par défaut dépendent du type de validation de longueur effectuée. Vous pouvez personnaliser ces messages en utilisant les options `:wrong_length`, `:too_long` et `:too_short` et `%{count}` comme espace réservé pour le nombre correspondant à la contrainte de longueur utilisée. Vous pouvez toujours utiliser l'option `:message` pour spécifier un message d'erreur.

```ruby
class Person < ApplicationRecord
  validates :bio, length: { maximum: 1000,
    too_long: "%{count} caractères est le maximum autorisé" }
end
```

Notez que les messages d'erreur par défaut sont au pluriel (par exemple, "est trop court (le minimum est de %{count} caractères)"). Pour cette raison, lorsque `:minimum` est égal à 1, vous devez fournir un message personnalisé ou utiliser `presence: true` à la place. Lorsque `:in` ou `:within` ont une limite inférieure de 1, vous devez soit fournir un message personnalisé, soit appeler `presence` avant `length`.
REMARQUE: Une seule option de contrainte peut être utilisée à la fois, à l'exception des options `:minimum` et `:maximum` qui peuvent être combinées.

### `numericality`

Cette méthode de validation vérifie que vos attributs ne contiennent que des valeurs numériques. Par défaut, elle accepte un signe optionnel suivi d'un nombre entier ou décimal.

Pour spécifier que seuls les nombres entiers sont autorisés, définissez `:only_integer` sur `true`. La méthode utilisera ensuite l'expression régulière suivante pour valider la valeur de l'attribut.

```ruby
/\A[+-]?\d+\z/
```

Sinon, elle essaiera de convertir la valeur en un nombre en utilisant `Float`. Les `Float` sont convertis en `BigDecimal` en utilisant la précision de la colonne ou un maximum de 15 chiffres.

```ruby
class Player < ApplicationRecord
  validates :points, numericality: true
  validates :games_played, numericality: { only_integer: true }
end
```

Le message d'erreur par défaut pour `:only_integer` est _"doit être un entier"_.

En plus de `:only_integer`, cette méthode accepte également l'option `:only_numeric`, qui spécifie que la valeur doit être une instance de `Numeric` et essaie de la convertir si elle est une `String`.

REMARQUE: Par défaut, `numericality` n'accepte pas les valeurs `nil`. Vous pouvez utiliser l'option `allow_nil: true` pour les autoriser. Notez que pour les colonnes de type `Integer` et `Float`, les chaînes vides sont converties en `nil`.

Le message d'erreur par défaut lorsque aucune option n'est spécifiée est _"n'est pas un nombre"_.

Il existe également de nombreuses options qui peuvent être utilisées pour ajouter des contraintes aux valeurs acceptables :

* `:greater_than` - Spécifie que la valeur doit être supérieure à la valeur fournie. Le message d'erreur par défaut pour cette option est _"doit être supérieur à %{count}"_.
* `:greater_than_or_equal_to` - Spécifie que la valeur doit être supérieure ou égale à la valeur fournie. Le message d'erreur par défaut pour cette option est _"doit être supérieur ou égal à %{count}"_.
* `:equal_to` - Spécifie que la valeur doit être égale à la valeur fournie. Le message d'erreur par défaut pour cette option est _"doit être égal à %{count}"_.
* `:less_than` - Spécifie que la valeur doit être inférieure à la valeur fournie. Le message d'erreur par défaut pour cette option est _"doit être inférieur à %{count}"_.
* `:less_than_or_equal_to` - Spécifie que la valeur doit être inférieure ou égale à la valeur fournie. Le message d'erreur par défaut pour cette option est _"doit être inférieur ou égal à %{count}"_.
* `:other_than` - Spécifie que la valeur doit être différente de la valeur fournie. Le message d'erreur par défaut pour cette option est _"doit être différent de %{count}"_.
* `:in` - Spécifie que la valeur doit être dans la plage fournie. Le message d'erreur par défaut pour cette option est _"doit être dans %{count}"_.
* `:odd` - Spécifie que la valeur doit être un nombre impair. Le message d'erreur par défaut pour cette option est _"doit être impair"_.
* `:even` - Spécifie que la valeur doit être un nombre pair. Le message d'erreur par défaut pour cette option est _"doit être pair"_.

### `presence`

Cette méthode de validation vérifie que les attributs spécifiés ne sont pas vides. Elle utilise la méthode [`Object#blank?`][] pour vérifier si la valeur est `nil` ou une chaîne vide, c'est-à-dire une chaîne vide ou composée uniquement d'espaces.

```ruby
class Person < ApplicationRecord
  validates :name, :login, :email, presence: true
end
```

Si vous souhaitez vous assurer qu'une association est présente, vous devez vérifier si l'objet associé lui-même est présent, et non la clé étrangère utilisée pour mapper l'association. De cette façon, il est vérifié non seulement que la clé étrangère n'est pas vide, mais aussi que l'objet référencé existe.

```ruby
class Supplier < ApplicationRecord
  has_one :account
  validates :account, presence: true
end
```

Pour valider les enregistrements associés dont la présence est requise, vous devez spécifier l'option `:inverse_of` pour l'association :

```ruby
class Order < ApplicationRecord
  has_many :line_items, inverse_of: :order
end
```

REMARQUE: Si vous souhaitez vous assurer que l'association est à la fois présente et valide, vous devez également utiliser `validates_associated`. Plus d'informations à ce sujet ci-dessous.

Si vous validez la présence d'un objet associé via une relation `has_one` ou `has_many`, il sera vérifié que l'objet n'est ni `blank?` ni `marked_for_destruction?`.

Étant donné que `false.blank?` est vrai, si vous souhaitez valider la présence d'un champ booléen, vous devez utiliser l'une des validations suivantes :

```ruby
# La valeur _doit_ être true ou false
validates :boolean_field_name, inclusion: [true, false]
# La valeur _ne doit pas_ être nil, c'est-à-dire true ou false
validates :boolean_field_name, exclusion: [nil]
```
En utilisant l'une de ces validations, vous vous assurerez que la valeur ne sera PAS `nil`, ce qui entraînerait une valeur `NULL` dans la plupart des cas.

Le message d'erreur par défaut est _"ne peut pas être vide"_.

### `absence`

Cette méthode de validation vérifie que les attributs spécifiés sont absents. Elle utilise la méthode [`Object#present?`][] pour vérifier si la valeur n'est ni `nil` ni une chaîne vide, c'est-à-dire une chaîne vide ou composée uniquement d'espaces.

```ruby
class Person < ApplicationRecord
  validates :name, :login, :email, absence: true
end
```

Si vous souhaitez vous assurer qu'une association est absente, vous devez tester si l'objet associé lui-même est absent, et non la clé étrangère utilisée pour mapper l'association.

```ruby
class LineItem < ApplicationRecord
  belongs_to :order
  validates :order, absence: true
end
```

Pour valider les enregistrements associés dont l'absence est requise, vous devez spécifier l'option `:inverse_of` pour l'association :

```ruby
class Order < ApplicationRecord
  has_many :line_items, inverse_of: :order
end
```

REMARQUE : Si vous souhaitez vous assurer que l'association est à la fois présente et valide, vous devez également utiliser `validates_associated`. Plus d'informations à ce sujet ci-dessous.

Si vous validez l'absence d'un objet associé via une relation `has_one` ou `has_many`, cela vérifiera que l'objet n'est ni `present?` ni `marked_for_destruction?`.

Étant donné que `false.present?` est faux, si vous souhaitez valider l'absence d'un champ booléen, vous devez utiliser `validates :nom_du_champ, exclusion: { in: [true, false] }`.

Le message d'erreur par défaut est _"doit être vide"_.

### `uniqueness`

Cette méthode de validation vérifie que la valeur de l'attribut est unique juste avant que l'objet ne soit enregistré.

```ruby
class Account < ApplicationRecord
  validates :email, uniqueness: true
end
```

La validation se fait en effectuant une requête SQL dans la table du modèle, à la recherche d'un enregistrement existant avec la même valeur dans cet attribut.

Il existe une option `:scope` que vous pouvez utiliser pour spécifier un ou plusieurs attributs qui sont utilisés pour limiter la vérification d'unicité :

```ruby
class Holiday < ApplicationRecord
  validates :name, uniqueness: { scope: :year,
    message: "ne doit se produire qu'une fois par an" }
end
```

ATTENTION. Cette validation ne crée pas de contrainte d'unicité dans la base de données, il peut donc arriver que deux connexions de base de données différentes créent deux enregistrements avec la même valeur pour une colonne que vous souhaitez rendre unique. Pour éviter cela, vous devez créer un index unique sur cette colonne dans votre base de données.

Pour ajouter une contrainte d'unicité à votre base de données, utilisez l'instruction [`add_index`][] dans une migration et incluez l'option `unique: true`.

Si vous souhaitez créer une contrainte de base de données pour empêcher d'éventuelles violations d'une validation d'unicité en utilisant l'option `:scope`, vous devez créer un index unique sur les deux colonnes de votre base de données. Consultez [le manuel MySQL][] pour plus de détails sur les index de plusieurs colonnes ou [le manuel PostgreSQL][] pour des exemples de contraintes uniques qui font référence à un groupe de colonnes.

Il existe également une option `:case_sensitive` que vous pouvez utiliser pour définir si la contrainte d'unicité sera sensible à la casse, insensible à la casse ou respectera la collation par défaut de la base de données. Cette option est par défaut respecte la collation par défaut de la base de données.

```ruby
class Person < ApplicationRecord
  validates :name, uniqueness: { case_sensitive: false }
end
```

ATTENTION. Notez que certaines bases de données sont configurées pour effectuer des recherches insensibles à la casse de toute façon.

Il existe une option `:conditions` qui vous permet de spécifier des conditions supplémentaires sous la forme d'un fragment SQL `WHERE` pour limiter la recherche de la contrainte d'unicité (par exemple, `conditions: -> { where(status: 'active') }`).

Le message d'erreur par défaut est _"a déjà été pris"_.

Consultez [`validates_uniqueness_of`][] pour plus d'informations.

[le manuel MySQL]: https://dev.mysql.com/doc/refman/en/multiple-column-indexes.html
[le manuel PostgreSQL]: https://www.postgresql.org/docs/current/static/ddl-constraints.html

### `validates_associated`

Vous devez utiliser cette méthode d'aide lorsque votre modèle a des associations qui doivent toujours être validées. Chaque fois que vous essayez d'enregistrer votre objet, `valid?` sera appelé sur chacun des objets associés.

```ruby
class Library < ApplicationRecord
  has_many :books
  validates_associated :books
end
```

Cette validation fonctionnera avec tous les types d'associations.

ATTENTION : N'utilisez pas `validates_associated` des deux côtés de vos associations. Ils s'appelleraient mutuellement dans une boucle infinie.

Le message d'erreur par défaut pour [`validates_associated`][] est _"est invalide"_. Notez que chaque objet associé contiendra sa propre collection d'erreurs ; les erreurs ne remontent pas au modèle appelant.

REMARQUE : [`validates_associated`][] ne peut être utilisé qu'avec des objets ActiveRecord, tout ce qui précède peut également être utilisé avec n'importe quel objet qui inclut [`ActiveModel::Validations`][].
### `validates_each`

Cette méthode auxiliaire valide les attributs par rapport à un bloc. Elle n'a pas de fonction de validation prédéfinie. Vous devez en créer une en utilisant un bloc, et chaque attribut passé à [`validates_each`][] sera testé par rapport à celui-ci.

Dans l'exemple suivant, nous rejetterons les noms et prénoms qui commencent par une minuscule.

```ruby
class Person < ApplicationRecord
  validates_each :name, :surname do |record, attr, value|
    record.errors.add(attr, 'doit commencer par une majuscule') if /\A[[:lower:]]/.match?(value)
  end
end
```

Le bloc reçoit l'enregistrement, le nom de l'attribut et la valeur de l'attribut.

Vous pouvez faire ce que vous voulez pour vérifier les données valides dans le bloc. Si votre validation échoue, vous devez ajouter une erreur au modèle, le rendant ainsi invalide.


### `validates_with`

Cette méthode auxiliaire passe l'enregistrement à une classe distincte pour la validation.

```ruby
class GoodnessValidator < ActiveModel::Validator
  def validate(record)
    if record.first_name == "Evil"
      record.errors.add :base, "Cette personne est mauvaise"
    end
  end
end

class Person < ApplicationRecord
  validates_with GoodnessValidator
end
```

Il n'y a pas de message d'erreur par défaut pour `validates_with`. Vous devez ajouter manuellement des erreurs à la collection d'erreurs de l'enregistrement dans la classe du validateur.

REMARQUE : Les erreurs ajoutées à `record.errors[:base]` concernent l'état de l'enregistrement dans son ensemble.

Pour implémenter la méthode de validation, vous devez accepter un paramètre `record` dans la définition de la méthode, qui est l'enregistrement à valider.

Si vous souhaitez ajouter une erreur sur un attribut spécifique, passez-le en premier argument, comme `record.errors.add(:first_name, "veuillez choisir un autre nom")`. Nous aborderons les [erreurs de validation][] plus en détail ultérieurement.

```ruby
def validate(record)
  if record.some_field != "acceptable"
    record.errors.add :some_field, "ce champ est inacceptable"
  end
end
```

La méthode auxiliaire [`validates_with`][] prend une classe, ou une liste de classes à utiliser pour la validation.

```ruby
class Person < ApplicationRecord
  validates_with MyValidator, MyOtherValidator, on: :create
end
```

Comme toutes les autres validations, `validates_with` prend les options `:if`, `:unless` et `:on`. Si vous passez d'autres options, elles seront envoyées à la classe du validateur en tant qu'options :

```ruby
class GoodnessValidator < ActiveModel::Validator
  def validate(record)
    if options[:fields].any? { |field| record.send(field) == "Evil" }
      record.errors.add :base, "Cette personne est mauvaise"
    end
  end
end

class Person < ApplicationRecord
  validates_with GoodnessValidator, fields: [:first_name, :last_name]
end
```

Notez que le validateur sera initialisé *une seule fois* pour tout le cycle de vie de l'application, et non à chaque exécution de validation, donc faites attention à l'utilisation de variables d'instance à l'intérieur.

Si votre validateur est suffisamment complexe pour nécessiter des variables d'instance, vous pouvez facilement utiliser un simple objet Ruby :

```ruby
class Person < ApplicationRecord
  validate do |person|
    GoodnessValidator.new(person).validate
  end
end

class GoodnessValidator
  def initialize(person)
    @person = person
  end

  def validate
    if some_complex_condition_involving_ivars_and_private_methods?
      @person.errors.add :base, "Cette personne est mauvaise"
    end
  end

  # ...
end
```

Nous aborderons les [validations personnalisées](#performing-custom-validations) plus tard.

[erreurs de validation](#working-with-validation-errors)

Options de validation courantes
-------------------------

Il existe plusieurs options courantes prises en charge par les validateurs que nous venons de voir, examinons-en quelques-unes maintenant !

REMARQUE : Toutes ces options ne sont pas prises en charge par tous les validateurs, veuillez vous référer à la documentation de l'API pour [`ActiveModel::Validations`][].

En utilisant l'une des méthodes de validation que nous venons de mentionner, il existe également une liste d'options courantes partagées avec les validateurs. Nous les aborderons maintenant !

* [`:allow_nil`](#allow-nil) : Ignorer la validation si l'attribut est `nil`.
* [`:allow_blank`](#allow-blank) : Ignorer la validation si l'attribut est vide.
* [`:message`](#message) : Spécifier un message d'erreur personnalisé.
* [`:on`](#on) : Spécifier les contextes où cette validation est active.
* [`:strict`](#strict-validations) : Lever une exception lorsque la validation échoue.
* [`:if` et `:unless`](#conditional-validation) : Spécifier quand la validation doit ou ne doit pas se produire.


### `:allow_nil`

L'option `:allow_nil` ignore la validation lorsque la valeur à valider est `nil`.

```ruby
class Coffee < ApplicationRecord
  validates :size, inclusion: { in: %w(small medium large),
    message: "%{value} n'est pas une taille valide" }, allow_nil: true
end
```

```irb
irb> Coffee.create(size: nil).valid?
=> true
irb> Coffee.create(size: "mega").valid?
=> false
```

Pour toutes les options de l'argument message, veuillez consulter la
[documentation sur les messages](#message).

### `:allow_blank`

L'option `:allow_blank` est similaire à l'option `:allow_nil`. Cette option permet à la validation de passer si la valeur de l'attribut est `blank?`, comme `nil` ou une chaîne vide par exemple.

```ruby
class Topic < ApplicationRecord
  validates :title, length: { is: 5 }, allow_blank: true
end
```

```irb
irb> Topic.create(title: "").valid?
=> true
irb> Topic.create(title: nil).valid?
=> true
```

### `:message`
Comme vous l'avez déjà vu, l'option `:message` vous permet de spécifier le message qui sera ajouté à la collection `errors` lorsque la validation échoue. Lorsque cette option n'est pas utilisée, Active Record utilisera le message d'erreur par défaut correspondant à chaque helper de validation.

L'option `:message` accepte soit une `String` soit un `Proc` comme valeur.

Une valeur `String` pour `:message` peut éventuellement contenir `%{value}`, `%{attribute}` et `%{model}`, qui seront remplacés dynamiquement lorsque la validation échoue. Ce remplacement est effectué à l'aide de la gem i18n, et les espaces ne sont pas autorisés dans les espaces réservés.

```ruby
class Person < ApplicationRecord
  # Message codé en dur
  validates :name, presence: { message: "doit être renseigné s'il vous plaît" }

  # Message avec une valeur d'attribut dynamique. %{value} sera remplacé
  # par la valeur réelle de l'attribut. %{attribute} et %{model}
  # sont également disponibles.
  validates :age, numericality: { message: "%{value} semble incorrect" }
end
```

Une valeur `Proc` pour `:message` est donnée deux arguments : l'objet en cours de validation et un hash avec les paires clé-valeur `:model`, `:attribute` et `:value`.

```ruby
class Person < ApplicationRecord
  validates :username,
    uniqueness: {
      # object = objet person en cours de validation
      # data = { model: "Person", attribute: "Username", value: <username> }
      message: ->(object, data) do
        "Hey #{object.name}, #{data[:value]} est déjà pris."
      end
    }
end
```

### `:on`

L'option `:on` vous permet de spécifier quand la validation doit être effectuée. Le comportement par défaut de tous les helpers de validation intégrés est de s'exécuter lors de l'enregistrement (à la fois lors de la création d'un nouvel enregistrement et lors de sa mise à jour). Si vous souhaitez le modifier, vous pouvez utiliser `on: :create` pour exécuter la validation uniquement lors de la création d'un nouvel enregistrement ou `on: :update` pour exécuter la validation uniquement lors de la mise à jour d'un enregistrement.

```ruby
class Person < ApplicationRecord
  # il sera possible de mettre à jour l'e-mail avec une valeur en double
  validates :email, uniqueness: true, on: :create

  # il sera possible de créer l'enregistrement avec un âge non numérique
  validates :age, numericality: true, on: :update

  # par défaut (valide à la fois lors de la création et de la mise à jour)
  validates :name, presence: true
end
```

Vous pouvez également utiliser `on:` pour définir des contextes personnalisés. Les contextes personnalisés doivent être déclenchés explicitement en passant le nom du contexte à `valid?`, `invalid?` ou `save`.

```ruby
class Person < ApplicationRecord
  validates :email, uniqueness: true, on: :account_setup
  validates :age, numericality: true, on: :account_setup
end
```

```irb
irb> person = Person.new(age: 'trente-trois')
irb> person.valid?
=> true
irb> person.valid?(:account_setup)
=> false
irb> person.errors.messages
=> {:email=>["a déjà été pris"], :age=>["n'est pas un nombre"]}
```

`person.valid?(:account_setup)` exécute les deux validations sans enregistrer le modèle. `person.save(context: :account_setup)` valide `person` dans le contexte `account_setup` avant de l'enregistrer.

Passer un tableau de symboles est également acceptable.

```ruby
class Book
  include ActiveModel::Validations

  validates :title, presence: true, on: [:update, :ensure_title]
end
```

```irb
irb> book = Book.new(title: nil)
irb> book.valid?
=> true
irb> book.valid?(:ensure_title)
=> false
irb> book.errors.messages
=> {:title=>["ne peut pas être vide"]}
```

Lorsqu'ils sont déclenchés par un contexte explicite, les validations sont exécutées pour ce contexte, ainsi que pour toutes les validations _sans_ contexte.

```ruby
class Person < ApplicationRecord
  validates :email, uniqueness: true, on: :account_setup
  validates :age, numericality: true, on: :account_setup
  validates :name, presence: true
end
```

```irb
irb> person = Person.new
irb> person.valid?(:account_setup)
=> false
irb> person.errors.messages
=> {:email=>["a déjà été pris"], :age=>["n'est pas un nombre"], :name=>["ne peut pas être vide"]}
```

Nous aborderons d'autres cas d'utilisation de `on:` dans le guide des [callbacks](active_record_callbacks.html).

Validations strictes
--------------------

Vous pouvez également spécifier des validations strictes et lever une exception `ActiveModel::StrictValidationFailed` lorsque l'objet est invalide.

```ruby
class Person < ApplicationRecord
  validates :name, presence: { strict: true }
end
```

```irb
irb> Person.new.valid?
ActiveModel::StrictValidationFailed: Le nom ne peut pas être vide
```

Il est également possible de passer une exception personnalisée à l'option `:strict`.

```ruby
class Person < ApplicationRecord
  validates :token, presence: true, uniqueness: true, strict: TokenGenerationException
end
```

```irb
irb> Person.new.valid?
TokenGenerationException: Le token ne peut pas être vide
```

Validation conditionnelle
-------------------------

Il peut parfois être logique de valider un objet uniquement lorsque un prédicat donné est satisfait. Vous pouvez le faire en utilisant les options `:if` et `:unless`, qui peuvent prendre un symbole, un `Proc` ou un tableau. Vous pouvez utiliser l'option `:if` lorsque vous souhaitez spécifier quand la validation **doit** avoir lieu. Alternativement, si vous souhaitez spécifier quand la validation **ne doit pas** avoir lieu, vous pouvez utiliser l'option `:unless`.
### Utilisation d'un symbole avec `:if` et `:unless`

Vous pouvez associer les options `:if` et `:unless` à un symbole correspondant au nom d'une méthode qui sera appelée juste avant la validation. C'est l'option la plus couramment utilisée.

```ruby
class Order < ApplicationRecord
  validates :card_number, presence: true, if: :paid_with_card?

  def paid_with_card?
    payment_type == "card"
  end
end
```

### Utilisation d'un Proc avec `:if` et `:unless`

Il est possible d'associer `:if` et `:unless` à un objet `Proc` qui sera appelé. L'utilisation d'un objet `Proc` vous permet d'écrire une condition en ligne au lieu d'une méthode distincte. Cette option est particulièrement adaptée aux instructions d'une seule ligne.

```ruby
class Account < ApplicationRecord
  validates :password, confirmation: true,
    unless: Proc.new { |a| a.password.blank? }
end
```

Comme `lambda` est un type de `Proc`, il peut également être utilisé pour écrire des conditions en ligne en profitant de la syntaxe raccourcie.

```ruby
validates :password, confirmation: true, unless: -> { password.blank? }
```

### Regroupement des validations conditionnelles

Il est parfois utile de faire en sorte que plusieurs validations utilisent une même condition. Cela peut être facilement réalisé en utilisant [`with_options`][].

```ruby
class User < ApplicationRecord
  with_options if: :is_admin? do |admin|
    admin.validates :password, length: { minimum: 10 }
    admin.validates :email, presence: true
  end
end
```

Toutes les validations à l'intérieur du bloc `with_options` passeront automatiquement la condition `if: :is_admin?`


### Combinaison des conditions de validation

D'autre part, lorsque plusieurs conditions définissent si une validation doit être effectuée ou non, un `Array` peut être utilisé. De plus, vous pouvez appliquer à la fois `:if` et `:unless` à la même validation.

```ruby
class Computer < ApplicationRecord
  validates :mouse, presence: true,
                    if: [Proc.new { |c| c.market.retail? }, :desktop?],
                    unless: Proc.new { |c| c.trackpad.present? }
end
```

La validation n'est exécutée que lorsque toutes les conditions `:if` et aucune des conditions `:unless` sont évaluées à `true`.

Réalisation de validations personnalisées
-----------------------------------------

Lorsque les helpers de validation intégrés ne suffisent pas à vos besoins, vous pouvez écrire vos propres validateurs ou méthodes de validation selon vos préférences.

### Validateurs personnalisés

Les validateurs personnalisés sont des classes qui héritent de [`ActiveModel::Validator`][]. Ces classes doivent implémenter la méthode `validate` qui prend un enregistrement en argument et effectue la validation sur celui-ci. Le validateur personnalisé est appelé en utilisant la méthode `validates_with`.

```ruby
class MyValidator < ActiveModel::Validator
  def validate(record)
    unless record.name.start_with? 'X'
      record.errors.add :name, "Fournissez un nom commençant par X, s'il vous plaît !"
    end
  end
end

class Person < ApplicationRecord
  validates_with MyValidator
end
```

La manière la plus simple d'ajouter des validateurs personnalisés pour valider des attributs individuels est d'utiliser le pratique [`ActiveModel::EachValidator`][]. Dans ce cas, la classe de validateur personnalisé doit implémenter une méthode `validate_each` qui prend trois arguments : l'enregistrement, l'attribut à valider et la valeur de l'attribut dans l'instance passée.

```ruby
class EmailValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    unless URI::MailTo::EMAIL_REGEXP.match?(value)
      record.errors.add attribute, (options[:message] || "n'est pas une adresse e-mail")
    end
  end
end

class Person < ApplicationRecord
  validates :email, presence: true, email: true
end
```

Comme le montre l'exemple, vous pouvez également combiner des validations standard avec vos propres validateurs personnalisés.


### Méthodes personnalisées

Vous pouvez également créer des méthodes qui vérifient l'état de vos modèles et ajoutent des erreurs à la collection `errors` lorsqu'ils sont invalides. Vous devez ensuite enregistrer ces méthodes en utilisant la méthode de classe [`validate`][], en passant les symboles correspondant aux noms des méthodes de validation.

Vous pouvez passer plus d'un symbole pour chaque méthode de classe et les validations respectives seront exécutées dans le même ordre que celui dans lequel elles ont été enregistrées.

La méthode `valid?` vérifiera que la collection `errors` est vide, donc vos méthodes de validation personnalisées doivent y ajouter des erreurs lorsque vous souhaitez que la validation échoue :

```ruby
class Invoice < ApplicationRecord
  validate :expiration_date_cannot_be_in_the_past,
    :discount_cannot_be_greater_than_total_value

  def expiration_date_cannot_be_in_the_past
    if expiration_date.present? && expiration_date < Date.today
      errors.add(:expiration_date, "ne peut pas être dans le passé")
    end
  end

  def discount_cannot_be_greater_than_total_value
    if discount > total_value
      errors.add(:discount, "ne peut pas être supérieur à la valeur totale")
    end
  end
end
```

Par défaut, ces validations seront exécutées à chaque appel de `valid?` ou de sauvegarde de l'objet. Mais il est également possible de contrôler quand exécuter ces validations personnalisées en donnant une option `:on` à la méthode `validate`, avec soit `:create` soit `:update`.

```ruby
class Invoice < ApplicationRecord
  validate :active_customer, on: :create

  def active_customer
    errors.add(:customer_id, "n'est pas actif") unless customer.active?
  end
end
```
Voir la section ci-dessus pour plus de détails sur [`:on`](#on).

### Liste des validateurs

Si vous souhaitez connaître tous les validateurs pour un objet donné, ne cherchez pas plus loin que `validators`.

Par exemple, si nous avons le modèle suivant utilisant un validateur personnalisé et un validateur intégré :

```ruby
class Person < ApplicationRecord
  validates :name, presence: true, on: :create
  validates :email, format: URI::MailTo::EMAIL_REGEXP
  validates_with MyOtherValidator, strict: true
end
```

Nous pouvons maintenant utiliser `validators` sur le modèle "Person" pour lister tous les validateurs, ou même vérifier un champ spécifique en utilisant `validators_on`.

```irb
irb> Person.validators
#=> [#<ActiveRecord::Validations::PresenceValidator:0x10b2f2158
      @attributes=[:name], @options={:on=>:create}>,
     #<MyOtherValidatorValidator:0x10b2f17d0
      @attributes=[:name], @options={:strict=>true}>,
     #<ActiveModel::Validations::FormatValidator:0x10b2f0f10
      @attributes=[:email],
      @options={:with=>URI::MailTo::EMAIL_REGEXP}>]
     #<MyOtherValidator:0x10b2f0948 @options={:strict=>true}>]

irb> Person.validators_on(:name)
#=> [#<ActiveModel::Validations::PresenceValidator:0x10b2f2158
      @attributes=[:name], @options={on: :create}>]
```


Travailler avec les erreurs de validation
-----------------------------------------

Les méthodes [`valid?`][] et [`invalid?`][] ne fournissent qu'un résumé de l'état de validité. Cependant, vous pouvez approfondir chaque erreur individuelle en utilisant différentes méthodes de la collection [`errors`][].

Voici une liste des méthodes les plus couramment utilisées. Veuillez vous référer à la documentation [`ActiveModel::Errors`][] pour une liste de toutes les méthodes disponibles.


### `errors`

La passerelle par laquelle vous pouvez accéder à divers détails de chaque erreur.

Cela renvoie une instance de la classe `ActiveModel::Errors` contenant toutes les erreurs, chaque erreur étant représentée par un objet [`ActiveModel::Error`][].

```ruby
class Person < ApplicationRecord
  validates :name, presence: true, length: { minimum: 3 }
end
```

```irb
irb> person = Person.new
irb> person.valid?
=> false
irb> person.errors.full_messages
=> ["Le nom ne peut pas être vide", "Le nom est trop court (au minimum 3 caractères)"]

irb> person = Person.new(name: "John Doe")
irb> person.valid?
=> true
irb> person.errors.full_messages
=> []

irb> person = Person.new
irb> person.valid?
=> false
irb> person.errors.first.details
=> {:error=>:too_short, :count=>3}
```


### `errors[]`

[`errors[]`][Errors#squarebrackets] est utilisé lorsque vous souhaitez vérifier les messages d'erreur pour un attribut spécifique. Il renvoie un tableau de chaînes avec tous les messages d'erreur pour l'attribut donné, chaque chaîne avec un message d'erreur. S'il n'y a pas d'erreurs liées à l'attribut, il renvoie un tableau vide.

```ruby
class Person < ApplicationRecord
  validates :name, presence: true, length: { minimum: 3 }
end
```

```irb
irb> person = Person.new(name: "John Doe")
irb> person.valid?
=> true
irb> person.errors[:name]
=> []

irb> person = Person.new(name: "JD")
irb> person.valid?
=> false
irb> person.errors[:name]
=> ["est trop court (au minimum 3 caractères)"]

irb> person = Person.new
irb> person.valid?
=> false
irb> person.errors[:name]
=> ["ne peut pas être vide", "est trop court (au minimum 3 caractères)"]
```

### `errors.where` et objet d'erreur

Parfois, nous avons besoin de plus d'informations sur chaque erreur en plus de son message. Chaque erreur est encapsulée en tant qu'objet `ActiveModel::Error`, et la méthode [`where`][] est le moyen le plus courant d'y accéder.

`where` renvoie un tableau d'objets d'erreur filtrés par différents degrés de conditions.

```ruby
class Person < ApplicationRecord
  validates :name, presence: true, length: { minimum: 3 }
end
```

Nous pouvons filtrer uniquement l'`attribut` en le passant comme premier paramètre à `errors.where(:attr)`. Le deuxième paramètre est utilisé pour filtrer le `type` d'erreur que nous voulons en appelant `errors.where(:attr, :type)`.

```irb
irb> person = Person.new
irb> person.valid?
=> false

irb> person.errors.where(:name)
=> [ ... ] # toutes les erreurs pour l'attribut :name

irb> person.errors.where(:name, :too_short)
=> [ ... ] # erreurs :too_short pour l'attribut :name
```

Enfin, nous pouvons filtrer par toutes les `options` qui peuvent exister sur le type d'objet d'erreur donné.

```irb
irb> person = Person.new
irb> person.valid?
=> false

irb> person.errors.where(:name, :too_short, minimum: 3)
=> [ ... ] # toutes les erreurs de nom étant trop courtes et le minimum est de 2
```

Vous pouvez lire diverses informations à partir de ces objets d'erreur :

```irb
irb> error = person.errors.where(:name).last

irb> error.attribute
=> :name
irb> error.type
=> :too_short
irb> error.options[:count]
=> 3
```

Vous pouvez également générer le message d'erreur :

```irb
irb> error.message
=> "est trop court (au minimum 3 caractères)"
irb> error.full_message
=> "Le nom est trop court (au minimum 3 caractères)"
```

La méthode [`full_message`][] génère un message plus convivial pour l'utilisateur, avec le nom de l'attribut en majuscule précédé. (Pour personnaliser le format utilisé par `full_message`, consultez le [guide I18n](i18n.html#active-model-methods).)


### `errors.add`

La méthode [`add`][] crée l'objet d'erreur en prenant l'`attribut`, le `type` d'erreur et un hachage d'options supplémentaires. Cela est utile lorsque vous écrivez votre propre validateur, car cela vous permet de définir des situations d'erreur très spécifiques.

```ruby
class Person < ApplicationRecord
  validate do |person|
    errors.add :name, :too_plain, message: "n'est pas assez cool"
  end
end
```
```irb
irb> person = Person.create
irb> person.errors.where(:name).first.type
=> :too_plain
irb> person.errors.where(:name).first.full_message
=> "Le nom n'est pas assez cool"
```


### `errors[:base]`

Vous pouvez ajouter des erreurs qui sont liées à l'état de l'objet dans son ensemble, au lieu d'être liées à un attribut spécifique. Pour cela, vous devez utiliser `:base` comme attribut lors de l'ajout d'une nouvelle erreur.

```ruby
class Person < ApplicationRecord
  validate do |person|
    errors.add :base, :invalid, message: "Cette personne est invalide car ..."
  end
end
```

```irb
irb> person = Person.create
irb> person.errors.where(:base).first.full_message
=> "Cette personne est invalide car ..."
```

### `errors.size`

La méthode `size` renvoie le nombre total d'erreurs pour l'objet.

```ruby
class Person < ApplicationRecord
  validates :name, presence: true, length: { minimum: 3 }
end
```

```irb
irb> person = Person.new
irb> person.valid?
=> false
irb> person.errors.size
=> 2

irb> person = Person.new(name: "Andrea", email: "andrea@example.com")
irb> person.valid?
=> true
irb> person.errors.size
=> 0
```

### `errors.clear`

La méthode `clear` est utilisée lorsque vous souhaitez intentionnellement effacer la collection `errors`. Bien sûr, appeler `errors.clear` sur un objet invalide ne le rendra pas valide : la collection `errors` sera maintenant vide, mais la prochaine fois que vous appellerez `valid?` ou toute méthode qui tente d'enregistrer cet objet dans la base de données, les validations seront à nouveau exécutées. Si l'une des validations échoue, la collection `errors` sera à nouveau remplie.

```ruby
class Person < ApplicationRecord
  validates :name, presence: true, length: { minimum: 3 }
end
```

```irb
irb> person = Person.new
irb> person.valid?
=> false
irb> person.errors.empty?
=> false

irb> person.errors.clear
irb> person.errors.empty?
=> true

irb> person.save
=> false

irb> person.errors.empty?
=> false
```

Affichage des erreurs de validation dans les vues
-------------------------------------

Une fois que vous avez créé un modèle et ajouté des validations, si ce modèle est créé via un formulaire web, vous voulez probablement afficher un message d'erreur lorsque l'une des validations échoue.

Étant donné que chaque application gère ce genre de chose différemment, Rails n'inclut aucun helper de vue pour vous aider à générer ces messages directement. Cependant, grâce au grand nombre de méthodes que Rails vous donne pour interagir avec les validations en général, vous pouvez construire les vôtres. De plus, lors de la génération d'un scaffold, Rails ajoutera du code ERB dans le fichier `_form.html.erb` qu'il génère pour afficher la liste complète des erreurs sur ce modèle.

En supposant que nous avons un modèle qui a été enregistré dans une variable d'instance nommée `@article`, cela ressemble à ceci :

```html+erb
<% if @article.errors.any? %>
  <div id="error_explanation">
    <h2><%= pluralize(@article.errors.count, "erreur") %> ont empêché l'enregistrement de cet article :</h2>

    <ul>
      <% @article.errors.each do |error| %>
        <li><%= error.full_message %></li>
      <% end %>
    </ul>
  </div>
<% end %>
```

De plus, si vous utilisez les helpers de formulaire de Rails pour générer vos formulaires, lorsqu'une erreur de validation se produit sur un champ, il générera un `<div>` supplémentaire autour de l'entrée.

```html
<div class="field_with_errors">
  <input id="article_title" name="article[title]" size="30" type="text" value="">
</div>
```

Vous pouvez ensuite styliser ce div comme vous le souhaitez. Le scaffold par défaut que Rails génère, par exemple, ajoute cette règle CSS :

```css
.field_with_errors {
  padding: 2px;
  background-color: red;
  display: table;
}
```

Cela signifie que tout champ avec une erreur se retrouve avec une bordure rouge de 2 pixels.
[`errors`]: https://api.rubyonrails.org/classes/ActiveModel/Validations.html#method-i-errors
[`invalid?`]: https://api.rubyonrails.org/classes/ActiveModel/Validations.html#method-i-invalid-3F
[`valid?`]: https://api.rubyonrails.org/classes/ActiveRecord/Validations.html#method-i-valid-3F
[Errors#squarebrackets]: https://api.rubyonrails.org/classes/ActiveModel/Errors.html#method-i-5B-5D
[`ActiveModel::Validations::HelperMethods`]: https://api.rubyonrails.org/classes/ActiveModel/Validations/HelperMethods.html
[`Object#blank?`]: https://api.rubyonrails.org/classes/Object.html#method-i-blank-3F
[`Object#present?`]: https://api.rubyonrails.org/classes/Object.html#method-i-present-3F
[`validates_uniqueness_of`]: https://api.rubyonrails.org/classes/ActiveRecord/Validations/ClassMethods.html#method-i-validates_uniqueness_of
[`add_index`]: https://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html#method-i-add_index
[`validates_associated`]: https://api.rubyonrails.org/classes/ActiveRecord/Validations/ClassMethods.html#method-i-validates_associated
[`validates_each`]: https://api.rubyonrails.org/classes/ActiveModel/Validations/ClassMethods.html#method-i-validates_each
[`validates_with`]: https://api.rubyonrails.org/classes/ActiveModel/Validations/ClassMethods.html#method-i-validates_with
[`ActiveModel::Validations`]: https://api.rubyonrails.org/classes/ActiveModel/Validations.html
[`with_options`]: https://api.rubyonrails.org/classes/Object.html#method-i-with_options
[`ActiveModel::EachValidator`]: https://api.rubyonrails.org/classes/ActiveModel/EachValidator.html
[`ActiveModel::Validator`]: https://api.rubyonrails.org/classes/ActiveModel/Validator.html
[`validate`]: https://api.rubyonrails.org/classes/ActiveModel/Validations/ClassMethods.html#method-i-validate
[`ActiveModel::Errors`]: https://api.rubyonrails.org/classes/ActiveModel/Errors.html
[`ActiveModel::Error`]: https://api.rubyonrails.org/classes/ActiveModel/Error.html
[`full_message`]: https://api.rubyonrails.org/classes/ActiveModel/Errors.html#method-i-full_message
[`where`]: https://api.rubyonrails.org/classes/ActiveModel/Errors.html#method-i-where
[`add`]: https://api.rubyonrails.org/classes/ActiveModel/Errors.html#method-i-add
