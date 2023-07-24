**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: cee957545ee75801aab30265bc416992
Principes de base d'Active Model
===================

Ce guide devrait vous fournir tout ce dont vous avez besoin pour commencer à utiliser les classes de modèle. Active Model permet aux helpers d'Action Pack d'interagir avec des objets Ruby simples. Active Model aide également à construire des ORM personnalisés pour une utilisation en dehors du framework Rails.

Après avoir lu ce guide, vous saurez :

* Comment se comporte un modèle Active Record.
* Comment fonctionnent les rappels et les validations.
* Comment fonctionnent les sérialiseurs.
* Comment Active Model s'intègre au framework de localisation Rails (i18n).

--------------------------------------------------------------------------------

Qu'est-ce qu'Active Model ?
---------------------

Active Model est une bibliothèque contenant différents modules utilisés dans le développement de classes qui ont besoin de certaines fonctionnalités présentes dans Active Record.
Certains de ces modules sont expliqués ci-dessous.

### API

`ActiveModel::API` ajoute la capacité à une classe de fonctionner avec Action Pack et Action View dès le départ.

```ruby
class EmailContact
  include ActiveModel::API

  attr_accessor :name, :email, :message
  validates :name, :email, :message, presence: true

  def deliver
    if valid?
      # envoyer l'email
    end
  end
end
```

Lorsque vous incluez `ActiveModel::API`, vous obtenez des fonctionnalités telles que :

- introspection du nom du modèle
- conversions
- traductions
- validations

Cela vous donne également la possibilité d'initialiser un objet avec un hachage d'attributs, tout comme n'importe quel objet Active Record.

```irb
irb> email_contact = EmailContact.new(name: 'David', email: 'david@example.com', message: 'Bonjour le monde')
irb> email_contact.name
=> "David"
irb> email_contact.email
=> "david@example.com"
irb> email_contact.valid?
=> true
irb> email_contact.persisted?
=> false
```

Toute classe qui inclut `ActiveModel::API` peut être utilisée avec `form_with`, `render` et toutes les autres méthodes d'aide d'Action View, tout comme les objets Active Record.

### Méthodes d'attribut

Le module `ActiveModel::AttributeMethods` peut ajouter des préfixes et des suffixes personnalisés aux méthodes d'une classe. Il est utilisé en définissant les préfixes et les suffixes et les méthodes de l'objet qui les utiliseront.

```ruby
class Person
  include ActiveModel::AttributeMethods

  attribute_method_prefix 'reset_'
  attribute_method_suffix '_highest?'
  define_attribute_methods 'age'

  attr_accessor :age

  private
    def reset_attribute(attribute)
      send("#{attribute}=", 0)
    end

    def attribute_highest?(attribute)
      send(attribute) > 100
    end
end
```

```irb
irb> person = Person.new
irb> person.age = 110
irb> person.age_highest?
=> true
irb> person.reset_age
=> 0
irb> person.age_highest?
=> false
```

### Rappels

`ActiveModel::Callbacks` offre des rappels de style Active Record. Cela permet de définir des rappels qui s'exécutent au moment approprié.
Après avoir défini des rappels, vous pouvez les envelopper avec des méthodes personnalisées avant, après et autour.

```ruby
class Person
  extend ActiveModel::Callbacks

  define_model_callbacks :update

  before_update :reset_me

  def update
    run_callbacks(:update) do
      # Cette méthode est appelée lorsque update est appelé sur un objet.
    end
  end

  def reset_me
    # Cette méthode est appelée lorsque update est appelé sur un objet car un rappel before_update est défini.
  end
end
```

### Conversion

Si une classe définit les méthodes `persisted?` et `id`, vous pouvez inclure le module `ActiveModel::Conversion` dans cette classe et appeler les méthodes de conversion Rails sur les objets de cette classe.

```ruby
class Person
  include ActiveModel::Conversion

  def persisted?
    false
  end

  def id
    nil
  end
end
```

```irb
irb> person = Person.new
irb> person.to_model == person
=> true
irb> person.to_key
=> nil
irb> person.to_param
=> nil
```

### Dirty

Un objet devient "dirty" lorsqu'il a subi une ou plusieurs modifications de ses attributs et n'a pas été enregistré. `ActiveModel::Dirty` permet de vérifier si un objet a été modifié ou non. Il dispose également de méthodes d'accès basées sur les attributs. Prenons en compte une classe Person avec les attributs `first_name` et `last_name` :

```ruby
class Person
  include ActiveModel::Dirty
  define_attribute_methods :first_name, :last_name

  def first_name
    @first_name
  end

  def first_name=(value)
    first_name_will_change!
    @first_name = value
  end

  def last_name
    @last_name
  end

  def last_name=(value)
    last_name_will_change!
    @last_name = value
  end

  def save
    # faire le travail d'enregistrement...
    changes_applied
  end
end
```

#### Interrogation directe d'un objet pour obtenir sa liste de tous les attributs modifiés

```irb
irb> person = Person.new
irb> person.changed?
=> false

irb> person.first_name = "Prénom"
irb> person.first_name
=> "Prénom"

# Renvoie true si l'un des attributs a des modifications non enregistrées.
irb> person.changed?
=> true

# Renvoie une liste des attributs qui ont été modifiés avant l'enregistrement.
irb> person.changed
=> ["first_name"]

# Renvoie un hachage des attributs qui ont été modifiés avec leurs valeurs d'origine.
irb> person.changed_attributes
=> {"first_name"=>nil}

# Renvoie un hachage des modifications, avec les noms des attributs comme clés et les valeurs comme un tableau des anciennes et nouvelles valeurs pour ce champ.
irb> person.changes
=> {"first_name"=>[nil, "Prénom"]}
```

#### Méthodes d'accès basées sur les attributs

Permet de savoir si l'attribut particulier a été modifié ou non.
```irb
irb> person.first_name
=> "Prénom"

# attr_name_changed?
irb> person.first_name_changed?
=> true
```

Suivre la valeur précédente de l'attribut.

```irb
# attr_name_was accessor
irb> person.first_name_was
=> nil
```

Suivre à la fois les valeurs précédentes et actuelles de l'attribut modifié. Renvoie un tableau
si modifié, sinon renvoie nil.

```irb
# attr_name_change
irb> person.first_name_change
=> [nil, "Prénom"]
irb> person.last_name_change
=> nil
```

### Validations

Le module `ActiveModel::Validations` ajoute la possibilité de valider des objets
comme dans Active Record.

```ruby
class Person
  include ActiveModel::Validations

  attr_accessor :name, :email, :token

  validates :name, presence: true
  validates_format_of :email, with: /\A([^\s]+)((?:[-a-z0-9]\.)[a-z]{2,})\z/i
  validates! :token, presence: true
end
```

```irb
irb> person = Person.new
irb> person.token = "2b1f325"
irb> person.valid?
=> false
irb> person.name = 'vishnu'
irb> person.email = 'me'
irb> person.valid?
=> false
irb> person.email = 'me@vishnuatrai.com'
irb> person.valid?
=> true
irb> person.token = nil
irb> person.valid?
ActiveModel::StrictValidationFailed
```

### Naming

`ActiveModel::Naming` ajoute plusieurs méthodes de classe qui facilitent la gestion des noms et des routes.
Le module définit la méthode de classe `model_name` qui
définira plusieurs accesseurs en utilisant certaines méthodes de `ActiveSupport::Inflector`.

```ruby
class Person
  extend ActiveModel::Naming
end

Person.model_name.name                # => "Person"
Person.model_name.singular            # => "person"
Person.model_name.plural              # => "people"
Person.model_name.element             # => "person"
Person.model_name.human               # => "Person"
Person.model_name.collection          # => "people"
Person.model_name.param_key           # => "person"
Person.model_name.i18n_key            # => :person
Person.model_name.route_key           # => "people"
Person.model_name.singular_route_key  # => "person"
```

### Model

`ActiveModel::Model` permet d'implémenter des modèles similaires à `ActiveRecord::Base`.

```ruby
class EmailContact
  include ActiveModel::Model

  attr_accessor :name, :email, :message
  validates :name, :email, :message, presence: true

  def deliver
    if valid?
      # envoyer l'e-mail
    end
  end
end
```

Lorsque vous incluez `ActiveModel::Model`, vous obtenez toutes les fonctionnalités de `ActiveModel::API`.

### Serialization

`ActiveModel::Serialization` fournit une sérialisation de base pour votre objet.
Vous devez déclarer un hachage d'attributs qui contient les attributs que vous souhaitez
sérialiser. Les attributs doivent être des chaînes, pas des symboles.

```ruby
class Person
  include ActiveModel::Serialization

  attr_accessor :name

  def attributes
    { 'name' => nil }
  end
end
```

Maintenant, vous pouvez accéder à un hachage sérialisé de votre objet en utilisant la méthode `serializable_hash`.

```irb
irb> person = Person.new
irb> person.serializable_hash
=> {"name"=>nil}
irb> person.name = "Bob"
irb> person.serializable_hash
=> {"name"=>"Bob"}
```

#### ActiveModel::Serializers

Active Model fournit également le module `ActiveModel::Serializers::JSON`
pour la sérialisation / désérialisation JSON. Ce module inclut automatiquement le
module `ActiveModel::Serialization` précédemment discuté.

##### ActiveModel::Serializers::JSON

Pour utiliser `ActiveModel::Serializers::JSON`, vous devez simplement changer le
module que vous incluez de `ActiveModel::Serialization` à `ActiveModel::Serializers::JSON`.

```ruby
class Person
  include ActiveModel::Serializers::JSON

  attr_accessor :name

  def attributes
    { 'name' => nil }
  end
end
```

La méthode `as_json`, similaire à `serializable_hash`, fournit un hachage représentant
le modèle.

```irb
irb> person = Person.new
irb> person.as_json
=> {"name"=>nil}
irb> person.name = "Bob"
irb> person.as_json
=> {"name"=>"Bob"}
```

Vous pouvez également définir les attributs d'un modèle à partir d'une chaîne JSON.
Cependant, vous devez définir la méthode `attributes=` sur votre classe :

```ruby
class Person
  include ActiveModel::Serializers::JSON

  attr_accessor :name

  def attributes=(hash)
    hash.each do |key, value|
      send("#{key}=", value)
    end
  end

  def attributes
    { 'name' => nil }
  end
end
```

Maintenant, il est possible de créer une instance de `Person` et de définir des attributs à l'aide de `from_json`.

```irb
irb> json = { name: 'Bob' }.to_json
irb> person = Person.new
irb> person.from_json(json)
=> #<Person:0x00000100c773f0 @name="Bob">
irb> person.name
=> "Bob"
```

### Translation

`ActiveModel::Translation` permet l'intégration entre votre objet et le framework de
internationalisation (i18n) de Rails.

```ruby
class Person
  extend ActiveModel::Translation
end
```

Avec la méthode `human_attribute_name`, vous pouvez transformer les noms d'attributs en un
format plus lisible par les humains. Le format lisible par les humains est défini dans votre fichier(s) de localisation.

* config/locales/app.pt-BR.yml

```yaml
pt-BR:
  activemodel:
    attributes:
      person:
        name: 'Nome'
```

```ruby
Person.human_attribute_name('name') # => "Nome"
```

### Lint Tests

`ActiveModel::Lint::Tests` vous permet de tester si un objet est conforme à
l'API Active Model.

* `app/models/person.rb`

    ```ruby
    class Person
      include ActiveModel::Model
    end
    ```

* `test/models/person_test.rb`

    ```ruby
    require "test_helper"

    class PersonTest < ActiveSupport::TestCase
      include ActiveModel::Lint::Tests

      setup do
        @model = Person.new
      end
    end
    ```

```bash
$ bin/rails test

Run options: --seed 14596

# Running:

......

Finished in 0.024899s, 240.9735 runs/s, 1204.8677 assertions/s.

6 runs, 30 assertions, 0 failures, 0 errors, 0 skips
```

Il n'est pas nécessaire qu'un objet implémente toutes les API pour fonctionner avec
Action Pack. Ce module vise uniquement à guider au cas où vous souhaitez toutes
les fonctionnalités prêtes à l'emploi.

### SecurePassword

`ActiveModel::SecurePassword` permet de stocker de manière sécurisée n'importe quel
mot de passe sous une forme chiffrée. Lorsque vous incluez ce module, une
méthode de classe `has_secure_password` est fournie, qui définit
un accesseur `password` avec certaines validations par défaut.
#### Exigences

`ActiveModel::SecurePassword` dépend de [`bcrypt`](https://github.com/codahale/bcrypt-ruby 'BCrypt'),
donc incluez cette gem dans votre `Gemfile` pour utiliser `ActiveModel::SecurePassword` correctement.
Pour que cela fonctionne, le modèle doit avoir un accesseur nommé `XXX_digest`.
Où `XXX` est le nom de l'attribut de votre mot de passe souhaité.
Les validations suivantes sont ajoutées automatiquement :

1. Le mot de passe doit être présent.
2. Le mot de passe doit être identique à sa confirmation (si `XXX_confirmation` est fourni).
3. La longueur maximale d'un mot de passe est de 72 caractères (requis par `bcrypt` sur lequel ActiveModel::SecurePassword dépend).

#### Exemples

```ruby
class Personne
  include ActiveModel::SecurePassword
  has_secure_password
  has_secure_password :recovery_password, validations: false

  attr_accessor :password_digest, :recovery_password_digest
end
```

```irb
irb> personne = Personne.new

# Lorsque le mot de passe est vide.
irb> personne.valid?
=> false

# Lorsque la confirmation ne correspond pas au mot de passe.
irb> personne.password = 'aditya'
irb> personne.password_confirmation = 'nomatch'
irb> personne.valid?
=> false

# Lorsque la longueur du mot de passe dépasse 72 caractères.
irb> personne.password = personne.password_confirmation = 'a' * 100
irb> personne.valid?
=> false

# Lorsque seul le mot de passe est fourni sans confirmation de mot de passe.
irb> personne.password = 'aditya'
irb> personne.valid?
=> true

# Lorsque toutes les validations sont passées.
irb> personne.password = personne.password_confirmation = 'aditya'
irb> personne.valid?
=> true

irb> personne.recovery_password = "42password"

irb> personne.authenticate('aditya')
=> #<Personne> # == personne
irb> personne.authenticate('notright')
=> false
irb> personne.authenticate_password('aditya')
=> #<Personne> # == personne
irb> personne.authenticate_password('notright')
=> false

irb> personne.authenticate_recovery_password('42password')
=> #<Personne> # == personne
irb> personne.authenticate_recovery_password('notright')
=> false

irb> personne.password_digest
=> "$2a$04$gF8RfZdoXHvyTjHhiU4ZsO.kQqV9oonYZu31PRE4hLQn3xM2qkpIy"
irb> personne.recovery_password_digest
=> "$2a$04$iOfhwahFymCs5weB3BNH/uXkTG65HR.qpW.bNhEjFP3ftli3o5DQC"
```
