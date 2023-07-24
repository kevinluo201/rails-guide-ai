**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 516604959485cfefb0e0d775d767699b
Associations Active Record
==========================

Ce guide couvre les fonctionnalités d'association d'Active Record.

Après avoir lu ce guide, vous saurez comment :

* Déclarer des associations entre les modèles Active Record.
* Comprendre les différents types d'associations Active Record.
* Utiliser les méthodes ajoutées à vos modèles en créant des associations.

--------------------------------------------------------------------------------

Pourquoi des associations ?
--------------------------

Dans Rails, une _association_ est une connexion entre deux modèles Active Record. Pourquoi avons-nous besoin d'associations entre les modèles ? Parce qu'elles simplifient et facilitent les opérations courantes dans votre code.

Par exemple, considérons une application Rails simple qui comprend un modèle pour les auteurs et un modèle pour les livres. Chaque auteur peut avoir plusieurs livres.

Sans les associations, les déclarations de modèles ressembleraient à ceci :

```ruby
class Author < ApplicationRecord
end

class Book < ApplicationRecord
end
```

Maintenant, supposons que nous voulions ajouter un nouveau livre pour un auteur existant. Nous devrions faire quelque chose comme ceci :

```ruby
@book = Book.create(published_at: Time.now, author_id: @author.id)
```

Ou considérons la suppression d'un auteur et la suppression de tous ses livres :

```ruby
@books = Book.where(author_id: @author.id)
@books.each do |book|
  book.destroy
end
@author.destroy
```

Avec les associations Active Record, nous pouvons simplifier ces opérations - et d'autres - en indiquant de manière déclarative à Rails qu'il existe une connexion entre les deux modèles. Voici le code révisé pour la configuration des auteurs et des livres :

```ruby
class Author < ApplicationRecord
  has_many :books, dependent: :destroy
end

class Book < ApplicationRecord
  belongs_to :author
end
```

Avec ce changement, la création d'un nouveau livre pour un auteur particulier est plus facile :

```ruby
@book = @author.books.create(published_at: Time.now)
```

La suppression d'un auteur et de tous ses livres est *beaucoup* plus facile :

```ruby
@author.destroy
```

Pour en savoir plus sur les différents types d'associations, lisez la section suivante de ce guide. Ensuite, vous trouverez quelques astuces pour travailler avec les associations, puis une référence complète des méthodes et options pour les associations dans Rails.

Les types d'associations
------------------------

Rails prend en charge six types d'associations, chacun ayant un cas d'utilisation particulier.

Voici une liste de tous les types pris en charge avec un lien vers leur documentation API pour des informations plus détaillées sur la façon de les utiliser, leurs paramètres de méthode, etc.

* [`belongs_to`][]
* [`has_one`][]
* [`has_many`][]
* [`has_many :through`][`has_many`]
* [`has_one :through`][`has_one`]
* [`has_and_belongs_to_many`][]

Les associations sont implémentées à l'aide d'appels de style macro, de sorte que vous pouvez ajouter de manière déclarative des fonctionnalités à vos modèles. Par exemple, en déclarant qu'un modèle `belongs_to` à un autre, vous indiquez à Rails de maintenir les informations de [clé primaire](https://fr.wikipedia.org/wiki/Cl%C3%A9_primaire)-[clé étrangère](https://fr.wikipedia.org/wiki/Cl%C3%A9_%C3%A9trang%C3%A8re) entre les instances des deux modèles, et vous obtenez également un certain nombre de méthodes utilitaires ajoutées à votre modèle.

Dans le reste de ce guide, vous apprendrez comment déclarer et utiliser les différentes formes d'associations. Mais d'abord, une brève introduction aux situations où chaque type d'association est approprié.


### L'association `belongs_to`

Une association [`belongs_to`][] établit une connexion avec un autre modèle, de sorte que chaque instance du modèle déclarant "appartient à" une instance de l'autre modèle. Par exemple, si votre application comprend des auteurs et des livres, et que chaque livre peut être attribué à exactement un auteur, vous déclareriez le modèle de livre de cette manière :

```ruby
class Book < ApplicationRecord
  belongs_to :author
end
```

![Diagramme d'association `belongs_to`](images/association_basics/belongs_to.png)

NOTE : Les associations `belongs_to` doivent utiliser le terme au singulier. Si vous avez utilisé la forme plurielle dans l'exemple ci-dessus pour l'association `author` dans le modèle `Book` et avez essayé de créer l'instance par `Book.create(authors: author)`, vous obtiendriez une erreur "uninitialized constant Book::Authors". Cela est dû au fait que Rails déduit automatiquement le nom de la classe à partir du nom de l'association. Si le nom de l'association est incorrectement pluriel, alors la classe déduite sera également incorrectement plurielle.

La migration correspondante pourrait ressembler à ceci :

```ruby
class CreateBooks < ActiveRecord::Migration[7.1]
  def change
    create_table :authors do |t|
      t.string :name
      t.timestamps
    end

    create_table :books do |t|
      t.belongs_to :author
      t.datetime :published_at
      t.timestamps
    end
  end
end
```

Lorsqu'il est utilisé seul, `belongs_to` produit une connexion unidirectionnelle de type un à un. Par conséquent, chaque livre dans l'exemple ci-dessus "connaît" son auteur, mais les auteurs ne connaissent pas leurs livres.
Pour configurer une [association bidirectionnelle](#associations-bidirectionnelles) - utilisez `belongs_to` en combinaison avec un `has_one` ou `has_many` sur l'autre modèle, dans ce cas le modèle Author.

`belongs_to` n'assure pas la cohérence des références si `optional` est défini sur true, donc selon le cas d'utilisation, vous devrez peut-être également ajouter une contrainte de clé étrangère au niveau de la base de données sur la colonne de référence, comme ceci :
```ruby
create_table :books do |t|
  t.belongs_to :author, foreign_key: true
  # ...
end
```

### L'association `has_one`

Une association [`has_one`][] indique qu'un autre modèle a une référence vers ce modèle. Ce modèle peut être récupéré via cette association.

Par exemple, si chaque fournisseur de votre application a un seul compte, vous déclareriez le modèle de fournisseur comme ceci :

```ruby
class Supplier < ApplicationRecord
  has_one :account
end
```

La principale différence avec `belongs_to` est que la colonne de liaison `supplier_id` est située dans l'autre table :

![Diagramme de l'association has_one](images/association_basics/has_one.png)

La migration correspondante pourrait ressembler à ceci :

```ruby
class CreateSuppliers < ActiveRecord::Migration[7.1]
  def change
    create_table :suppliers do |t|
      t.string :name
      t.timestamps
    end

    create_table :accounts do |t|
      t.belongs_to :supplier
      t.string :account_number
      t.timestamps
    end
  end
end
```

Selon le cas d'utilisation, vous devrez peut-être également créer un index unique et/ou une contrainte de clé étrangère sur la colonne du fournisseur pour la table des comptes. Dans ce cas, la définition de la colonne pourrait ressembler à ceci :

```ruby
create_table :accounts do |t|
  t.belongs_to :supplier, index: { unique: true }, foreign_key: true
  # ...
end
```

Cette relation peut être [bidirectionnelle](#associations-bidirectionnelles) lorsqu'elle est utilisée en combinaison avec `belongs_to` sur l'autre modèle.

### L'association `has_many`

Une association [`has_many`][] est similaire à `has_one`, mais indique une connexion de un-à-plusieurs avec un autre modèle. On trouve souvent cette association du "côté opposé" d'une association `belongs_to`. Cette association indique que chaque instance du modèle a zéro ou plusieurs instances d'un autre modèle. Par exemple, dans une application contenant des auteurs et des livres, le modèle d'auteur pourrait être déclaré comme ceci :

```ruby
class Author < ApplicationRecord
  has_many :books
end
```

NOTE : Le nom de l'autre modèle est mis au pluriel lors de la déclaration d'une association `has_many`.

![Diagramme de l'association has_many](images/association_basics/has_many.png)

La migration correspondante pourrait ressembler à ceci :

```ruby
class CreateAuthors < ActiveRecord::Migration[7.1]
  def change
    create_table :authors do |t|
      t.string :name
      t.timestamps
    end

    create_table :books do |t|
      t.belongs_to :author
      t.datetime :published_at
      t.timestamps
    end
  end
end
```

Selon le cas d'utilisation, il est généralement conseillé de créer un index non unique et éventuellement une contrainte de clé étrangère sur la colonne de l'auteur pour la table des livres :

```ruby
create_table :books do |t|
  t.belongs_to :author, index: true, foreign_key: true
  # ...
end
```

### L'association `has_many :through`

Une association [`has_many :through`][`has_many`] est souvent utilisée pour établir une connexion de plusieurs-à-plusieurs avec un autre modèle. Cette association indique que le modèle déclarant peut être associé à zéro ou plusieurs instances d'un autre modèle en passant _par_ un troisième modèle. Par exemple, considérez une pratique médicale où les patients prennent rendez-vous pour voir des médecins. Les déclarations d'association pertinentes pourraient ressembler à ceci :

```ruby
class Physician < ApplicationRecord
  has_many :appointments
  has_many :patients, through: :appointments
end

class Appointment < ApplicationRecord
  belongs_to :physician
  belongs_to :patient
end

class Patient < ApplicationRecord
  has_many :appointments
  has_many :physicians, through: :appointments
end
```

![Diagramme de l'association has_many :through](images/association_basics/has_many_through.png)

La migration correspondante pourrait ressembler à ceci :

```ruby
class CreateAppointments < ActiveRecord::Migration[7.1]
  def change
    create_table :physicians do |t|
      t.string :name
      t.timestamps
    end

    create_table :patients do |t|
      t.string :name
      t.timestamps
    end

    create_table :appointments do |t|
      t.belongs_to :physician
      t.belongs_to :patient
      t.datetime :appointment_date
      t.timestamps
    end
  end
end
```

La collection de modèles de jointure peut être gérée via les [méthodes d'association `has_many`](#référence-d-association-has-many).
Par exemple, si vous assignez :

```ruby
physician.patients = patients
```

Alors de nouveaux modèles de jointure sont automatiquement créés pour les objets nouvellement associés.
Si certains qui existaient précédemment manquent maintenant, alors leurs lignes de jointure sont automatiquement supprimées.

AVERTISSEMENT : La suppression automatique des modèles de jointure est directe, aucun rappel de destruction n'est déclenché.

L'association `has_many :through` est également utile pour configurer des "raccourcis" à travers des associations `has_many` imbriquées. Par exemple, si un document a plusieurs sections, et qu'une section a plusieurs paragraphes, vous pouvez parfois vouloir obtenir une simple collection de tous les paragraphes dans le document. Vous pouvez le configurer de cette manière :

```ruby
class Document < ApplicationRecord
  has_many :sections
  has_many :paragraphs, through: :sections
end

class Section < ApplicationRecord
  belongs_to :document
  has_many :paragraphs
end

class Paragraph < ApplicationRecord
  belongs_to :section
end
```

Avec `through: :sections` spécifié, Rails comprendra maintenant :

```ruby
@document.paragraphs
```

### L'association `has_one :through`

Une association [`has_one :through`][`has_one`] établit une connexion de un-à-un avec un autre modèle. Cette association indique que le modèle déclarant peut être associé à une instance d'un autre modèle en passant _par_ un troisième modèle. Par exemple, si chaque fournisseur a un compte, et chaque compte est associé à un historique de compte, alors le modèle de fournisseur pourrait ressembler à ceci :
```ruby
class Supplier < ApplicationRecord
  has_one :account
  has_one :account_history, through: :account
end

class Account < ApplicationRecord
  belongs_to :supplier
  has_one :account_history
end

class AccountHistory < ApplicationRecord
  belongs_to :account
end
```

![Diagramme de l'association has_one :through](images/association_basics/has_one_through.png)

La migration correspondante pourrait ressembler à ceci :

```ruby
class CreateAccountHistories < ActiveRecord::Migration[7.1]
  def change
    create_table :suppliers do |t|
      t.string :name
      t.timestamps
    end

    create_table :accounts do |t|
      t.belongs_to :supplier
      t.string :account_number
      t.timestamps
    end

    create_table :account_histories do |t|
      t.belongs_to :account
      t.integer :credit_rating
      t.timestamps
    end
  end
end
```

### L'association `has_and_belongs_to_many`

Une association [`has_and_belongs_to_many`][] crée une connexion directe de type many-to-many avec un autre modèle, sans modèle intermédiaire.
Cette association indique que chaque instance du modèle déclarant se réfère à zéro ou plusieurs instances d'un autre modèle.
Par exemple, si votre application inclut des assemblages et des pièces, avec chaque assemblage ayant plusieurs pièces et chaque pièce apparaissant dans plusieurs assemblages, vous pouvez déclarer les modèles de cette manière :

```ruby
class Assembly < ApplicationRecord
  has_and_belongs_to_many :parts
end

class Part < ApplicationRecord
  has_and_belongs_to_many :assemblies
end
```

![Diagramme de l'association has_and_belongs_to_many](images/association_basics/habtm.png)

La migration correspondante pourrait ressembler à ceci :

```ruby
class CreateAssembliesAndParts < ActiveRecord::Migration[7.1]
  def change
    create_table :assemblies do |t|
      t.string :name
      t.timestamps
    end

    create_table :parts do |t|
      t.string :part_number
      t.timestamps
    end

    create_table :assemblies_parts, id: false do |t|
      t.belongs_to :assembly
      t.belongs_to :part
    end
  end
end
```

### Choisir entre `belongs_to` et `has_one`

Si vous souhaitez établir une relation one-to-one entre deux modèles, vous devrez ajouter `belongs_to` à l'un et `has_one` à l'autre. Comment savoir lequel est lequel ?

La distinction réside dans l'endroit où vous placez la clé étrangère (elle va sur la table de la classe déclarant l'association `belongs_to`), mais vous devriez également réfléchir à la signification réelle des données. La relation `has_one` indique que l'une des choses vous appartient - c'est-à-dire que quelque chose pointe vers vous. Par exemple, il est plus logique de dire qu'un fournisseur possède un compte plutôt qu'un compte possède un fournisseur. Cela suggère que les relations correctes sont les suivantes :

```ruby
class Supplier < ApplicationRecord
  has_one :account
end

class Account < ApplicationRecord
  belongs_to :supplier
end
```

La migration correspondante pourrait ressembler à ceci :

```ruby
class CreateSuppliers < ActiveRecord::Migration[7.1]
  def change
    create_table :suppliers do |t|
      t.string :name
      t.timestamps
    end

    create_table :accounts do |t|
      t.bigint  :supplier_id
      t.string  :account_number
      t.timestamps
    end

    add_index :accounts, :supplier_id
  end
end
```

NOTE : Utiliser `t.bigint :supplier_id` rend le nom de la clé étrangère évident et explicite. Dans les versions actuelles de Rails, vous pouvez masquer ce détail d'implémentation en utilisant `t.references :supplier` à la place.

### Choisir entre `has_many :through` et `has_and_belongs_to_many`

Rails propose deux façons différentes de déclarer une relation many-to-many entre des modèles. La première façon est d'utiliser `has_and_belongs_to_many`, qui vous permet de créer l'association directement :

```ruby
class Assembly < ApplicationRecord
  has_and_belongs_to_many :parts
end

class Part < ApplicationRecord
  has_and_belongs_to_many :assemblies
end
```

La deuxième façon de déclarer une relation many-to-many est d'utiliser `has_many :through`. Cela crée l'association de manière indirecte, via un modèle de jointure :

```ruby
class Assembly < ApplicationRecord
  has_many :manifests
  has_many :parts, through: :manifests
end

class Manifest < ApplicationRecord
  belongs_to :assembly
  belongs_to :part
end

class Part < ApplicationRecord
  has_many :manifests
  has_many :assemblies, through: :manifests
end
```

La règle la plus simple est que vous devriez configurer une relation `has_many :through` si vous avez besoin de travailler avec le modèle de relation en tant qu'entité indépendante. Si vous n'avez pas besoin de faire quoi que ce soit avec le modèle de relation, il peut être plus simple de configurer une relation `has_and_belongs_to_many` (mais n'oubliez pas de créer la table de jointure dans la base de données).

Vous devriez utiliser `has_many :through` si vous avez besoin de validations, de rappels ou d'attributs supplémentaires sur le modèle de jointure.

### Associations polymorphes

Une variante légèrement plus avancée des associations est l'association polymorphe. Avec les associations polymorphes, un modèle peut appartenir à plus d'un autre modèle, sur une seule association. Par exemple, vous pourriez avoir un modèle de photo qui appartient soit à un modèle d'employé, soit à un modèle de produit. Voici comment cela pourrait être déclaré :

```ruby
class Picture < ApplicationRecord
  belongs_to :imageable, polymorphic: true
end

class Employee < ApplicationRecord
  has_many :pictures, as: :imageable
end

class Product < ApplicationRecord
  has_many :pictures, as: :imageable
end
```

Vous pouvez considérer une déclaration `belongs_to` polymorphe comme la mise en place d'une interface que tout autre modèle peut utiliser. À partir d'une instance du modèle `Employee`, vous pouvez récupérer une collection de photos : `@employee.pictures`.
De même, vous pouvez récupérer `@product.pictures`.

Si vous avez une instance du modèle `Picture`, vous pouvez accéder à son parent via `@picture.imageable`. Pour que cela fonctionne, vous devez déclarer à la fois une colonne de clé étrangère et une colonne de type dans le modèle qui déclare l'interface polymorphique :

```ruby
class CreatePictures < ActiveRecord::Migration[7.1]
  def change
    create_table :pictures do |t|
      t.string  :name
      t.bigint  :imageable_id
      t.string  :imageable_type
      t.timestamps
    end

    add_index :pictures, [:imageable_type, :imageable_id]
  end
end
```

Cette migration peut être simplifiée en utilisant la forme `t.references` :

```ruby
class CreatePictures < ActiveRecord::Migration[7.1]
  def change
    create_table :pictures do |t|
      t.string :name
      t.references :imageable, polymorphic: true
      t.timestamps
    end
  end
end
```

![Diagramme d'association polymorphique](images/association_basics/polymorphic.png)

### Auto-joins

Lors de la conception d'un modèle de données, il arrive parfois qu'un modèle doive être lié à lui-même. Par exemple, vous pouvez vouloir stocker tous les employés dans un seul modèle de base de données, mais pouvoir tracer des relations telles que celles entre un manager et ses subordonnés. Cette situation peut être modélisée avec des associations d'auto-joins :

```ruby
class Employee < ApplicationRecord
  has_many :subordinates, class_name: "Employee",
                          foreign_key: "manager_id"

  belongs_to :manager, class_name: "Employee", optional: true
end
```

Avec cette configuration, vous pouvez récupérer `@employee.subordinates` et `@employee.manager`.

Dans vos migrations/schéma, vous ajouterez une colonne de référence au modèle lui-même.

```ruby
class CreateEmployees < ActiveRecord::Migration[7.1]
  def change
    create_table :employees do |t|
      t.references :manager, foreign_key: { to_table: :employees }
      t.timestamps
    end
  end
end
```

NOTE : L'option `to_table` passée à `foreign_key` et d'autres sont expliquées dans [`SchemaStatements#add_reference`][connection.add_reference].

Conseils, astuces et avertissements
----------------------------------

Voici quelques éléments que vous devez connaître pour utiliser efficacement les associations Active Record dans vos applications Rails :

* Contrôler le cache
* Éviter les collisions de noms
* Mettre à jour le schéma
* Contrôler la portée de l'association
* Associations bidirectionnelles

### Contrôler le cache

Toutes les méthodes d'association sont basées sur le cache, qui conserve le résultat de la dernière requête disponible pour d'autres opérations. Le cache est même partagé entre les méthodes. Par exemple :

```ruby
# récupère les livres depuis la base de données
author.books.load

# utilise la copie mise en cache des livres
author.books.size

# utilise la copie mise en cache des livres
author.books.empty?
```

Mais que faire si vous souhaitez recharger le cache, car les données peuvent avoir été modifiées par une autre partie de l'application ? Il suffit d'appeler `reload` sur l'association :

```ruby
# récupère les livres depuis la base de données
author.books.load

# utilise la copie mise en cache des livres
author.books.size

# supprime la copie mise en cache des livres et retourne à la base de données
author.books.reload.empty?
```

### Éviter les collisions de noms

Vous n'êtes pas libre d'utiliser n'importe quel nom pour vos associations. Parce que la création d'une association ajoute une méthode portant ce nom au modèle, il est déconseillé de donner à une association un nom déjà utilisé pour une méthode d'instance de `ActiveRecord::Base`. La méthode d'association remplacerait la méthode de base et causerait des problèmes. Par exemple, `attributes` ou `connection` sont de mauvais noms pour des associations.

### Mettre à jour le schéma

Les associations sont extrêmement utiles, mais elles ne sont pas magiques. Vous êtes responsable de maintenir votre schéma de base de données pour qu'il corresponde à vos associations. En pratique, cela signifie deux choses, selon le type d'associations que vous créez. Pour les associations `belongs_to`, vous devez créer des clés étrangères, et pour les associations `has_and_belongs_to_many`, vous devez créer la table de jointure appropriée.

#### Création de clés étrangères pour les associations `belongs_to`

Lorsque vous déclarez une association `belongs_to`, vous devez créer des clés étrangères si nécessaire. Par exemple, considérez ce modèle :

```ruby
class Book < ApplicationRecord
  belongs_to :author
end
```

Cette déclaration doit être soutenue par une colonne de clé étrangère correspondante dans la table des livres. Pour une nouvelle table, la migration pourrait ressembler à ceci :

```ruby
class CreateBooks < ActiveRecord::Migration[7.1]
  def change
    create_table :books do |t|
      t.datetime   :published_at
      t.string     :book_number
      t.references :author
    end
  end
end
```

Alors que pour une table existante, cela pourrait ressembler à ceci :

```ruby
class AddAuthorToBooks < ActiveRecord::Migration[7.1]
  def change
    add_reference :books, :author
  end
end
```

NOTE : Si vous souhaitez [imposer l'intégrité référentielle au niveau de la base de données][foreign_keys], ajoutez l'option `foreign_key: true` aux déclarations de colonnes de type 'reference' ci-dessus.

#### Création de tables de jointure pour les associations `has_and_belongs_to_many`

Si vous créez une association `has_and_belongs_to_many`, vous devez créer explicitement la table de jointure. À moins que le nom de la table de jointure ne soit explicitement spécifié en utilisant l'option `:join_table`, Active Record crée le nom en utilisant l'ordre lexical des noms de classe. Ainsi, une jointure entre les modèles d'auteur et de livre donnera le nom de table de jointure par défaut "authors_books" car "a" est supérieur à "b" dans l'ordre lexical.
AVERTISSEMENT : La priorité entre les noms de modèle est calculée à l'aide de l'opérateur `<=>` pour les `String`. Cela signifie que si les chaînes ont des longueurs différentes et que les chaînes sont égales lorsqu'elles sont comparées jusqu'à la plus courte longueur, alors la chaîne la plus longue est considérée comme ayant une priorité lexicale supérieure à celle plus courte. Par exemple, on s'attendrait à ce que les tables "paper_boxes" et "papers" génèrent un nom de table de jointure "papers_paper_boxes" en raison de la longueur du nom "paper_boxes", mais en réalité, elles génèrent un nom de table de jointure "paper_boxes_papers" (parce que le trait de soulignement '\_' est lexicographiquement _inférieur_ à 's' dans les encodages courants).

Quel que soit le nom, vous devez générer manuellement la table de jointure avec une migration appropriée. Par exemple, considérez ces associations :

```ruby
class Assembly < ApplicationRecord
  has_and_belongs_to_many :parts
end

class Part < ApplicationRecord
  has_and_belongs_to_many :assemblies
end
```

Ces associations doivent être soutenues par une migration pour créer la table `assemblies_parts`. Cette table doit être créée sans clé primaire :

```ruby
class CreateAssembliesPartsJoinTable < ActiveRecord::Migration[7.1]
  def change
    create_table :assemblies_parts, id: false do |t|
      t.bigint :assembly_id
      t.bigint :part_id
    end

    add_index :assemblies_parts, :assembly_id
    add_index :assemblies_parts, :part_id
  end
end
```

Nous passons `id: false` à `create_table` car cette table ne représente pas un modèle. Cela est nécessaire pour que l'association fonctionne correctement. Si vous observez un comportement étrange dans une association `has_and_belongs_to_many` comme des ID de modèle corrompus ou des exceptions sur des ID en conflit, il est probable que vous ayez oublié cette partie.

Pour simplifier, vous pouvez également utiliser la méthode `create_join_table` :

```ruby
class CreateAssembliesPartsJoinTable < ActiveRecord::Migration[7.1]
  def change
    create_join_table :assemblies, :parts do |t|
      t.index :assembly_id
      t.index :part_id
    end
  end
end
```

### Contrôler la portée de l'association

Par défaut, les associations recherchent des objets uniquement dans la portée du module actuel. Cela peut être important lorsque vous déclarez des modèles Active Record dans un module. Par exemple :

```ruby
module MyApplication
  module Business
    class Supplier < ApplicationRecord
      has_one :account
    end

    class Account < ApplicationRecord
      belongs_to :supplier
    end
  end
end
```

Cela fonctionnera bien, car les classes `Supplier` et `Account` sont définies dans la même portée. Mais ce qui suit ne fonctionnera _pas_, car `Supplier` et `Account` sont définis dans des portées différentes :

```ruby
module MyApplication
  module Business
    class Supplier < ApplicationRecord
      has_one :account
    end
  end

  module Billing
    class Account < ApplicationRecord
      belongs_to :supplier
    end
  end
end
```

Pour associer un modèle à un modèle dans un espace de noms différent, vous devez spécifier le nom de classe complet dans votre déclaration d'association :

```ruby
module MyApplication
  module Business
    class Supplier < ApplicationRecord
      has_one :account,
        class_name: "MyApplication::Billing::Account"
    end
  end

  module Billing
    class Account < ApplicationRecord
      belongs_to :supplier,
        class_name: "MyApplication::Business::Supplier"
    end
  end
end
```

### Associations bidirectionnelles

Il est normal que les associations fonctionnent dans les deux sens, nécessitant une déclaration sur deux modèles différents :

```ruby
class Author < ApplicationRecord
  has_many :books
end

class Book < ApplicationRecord
  belongs_to :author
end
```

Active Record tentera d'identifier automatiquement que ces deux modèles partagent une association bidirectionnelle en fonction du nom de l'association. Cette information permet à Active Record de :

* Éviter les requêtes inutiles pour les données déjà chargées :

    ```irb
    irb> author = Author.first
    irb> author.books.all? do |book|
    irb>   book.author.equal?(author) # Aucune requête supplémentaire exécutée ici
    irb> end
    => true
    ```

* Éviter les données incohérentes (puisque seule une copie de l'objet `Author` est chargée) :

    ```irb
    irb> author = Author.first
    irb> book = author.books.first
    irb> author.name == book.author.name
    => true
    irb> author.name = "Nom modifié"
    irb> author.name == book.author.name
    => true
    ```

* Enregistrer automatiquement les associations dans plus de cas :

    ```irb
    irb> author = Author.new
    irb> book = author.books.new
    irb> book.save!
    irb> book.persisted?
    => true
    irb> author.persisted?
    => true
    ```

* Valider la [présence](active_record_validations.html#presence) et l'[absence](active_record_validations.html#absence) des associations dans plus de cas :

    ```irb
    irb> book = Book.new
    irb> book.valid?
    => false
    irb> book.errors.full_messages
    => ["Author must exist"]
    irb> author = Author.new
    irb> book = author.books.new
    irb> book.valid?
    => true
    ```

Active Record prend en charge l'identification automatique pour la plupart des associations avec des noms standard. Cependant, les associations bidirectionnelles qui contiennent les options `:through` ou `:foreign_key` ne seront pas automatiquement identifiées.

Les portées personnalisées sur l'association opposée empêchent également l'identification automatique, tout comme les portées personnalisées sur l'association elle-même, sauf si [`config.active_record.automatic_scope_inversing`][] est défini sur true (la valeur par défaut pour les nouvelles applications).

Par exemple, considérez les déclarations de modèles suivantes :

```ruby
class Author < ApplicationRecord
  has_many :books
end

class Book < ApplicationRecord
  belongs_to :writer, class_name: 'Author', foreign_key: 'author_id'
end
```

En raison de l'option `:foreign_key`, Active Record ne reconnaîtra plus automatiquement l'association bidirectionnelle. Cela peut causer des problèmes dans votre application :
* Exécuter des requêtes inutiles pour les mêmes données (dans cet exemple, cela entraîne N+1 requêtes) :

    ```irb
    irb> author = Author.first
    irb> author.books.any? do |book|
    irb>   book.author.equal?(author) # Cela exécute une requête pour chaque livre
    irb> end
    => false
    ```

* Référencer plusieurs copies d'un modèle avec des données incohérentes :

    ```irb
    irb> author = Author.first
    irb> book = author.books.first
    irb> author.name == book.author.name
    => true
    irb> author.name = "Nom modifié"
    irb> author.name == book.author.name
    => false
    ```

* Échouer à enregistrer automatiquement les associations :

    ```irb
    irb> author = Author.new
    irb> book = author.books.new
    irb> book.save!
    irb> book.persisted?
    => true
    irb> author.persisted?
    => false
    ```

* Échouer à valider la présence ou l'absence :

    ```irb
    irb> author = Author.new
    irb> book = author.books.new
    irb> book.valid?
    => false
    irb> book.errors.full_messages
    => ["L'auteur doit exister"]
    ```

Active Record fournit l'option `:inverse_of` afin que vous puissiez déclarer explicitement des associations bidirectionnelles :

```ruby
class Author < ApplicationRecord
  has_many :books, inverse_of: 'writer'
end

class Book < ApplicationRecord
  belongs_to :writer, class_name: 'Author', foreign_key: 'author_id'
end
```

En incluant l'option `:inverse_of` dans la déclaration de l'association `has_many`,
Active Record reconnaîtra désormais l'association bidirectionnelle et se comportera comme dans
les exemples initiaux ci-dessus.


Référence détaillée des associations
-----------------------------------

Les sections suivantes donnent les détails de chaque type d'association, y compris les méthodes qu'elles ajoutent et les options que vous pouvez utiliser lors de la déclaration d'une association.

### Référence de l'association `belongs_to`

En termes de base de données, l'association `belongs_to` indique que la table de ce modèle contient une colonne qui représente une référence à une autre table.
Cela peut être utilisé pour établir des relations de un à un ou de un à plusieurs, selon la configuration.
Si la table de l'autre classe contient la référence dans une relation de un à un, vous devriez utiliser `has_one` à la place.

#### Méthodes ajoutées par `belongs_to`

Lorsque vous déclarez une association `belongs_to`, la classe déclarante gagne automatiquement 8 méthodes liées à l'association :

* `association`
* `association=(associate)`
* `build_association(attributes = {})`
* `create_association(attributes = {})`
* `create_association!(attributes = {})`
* `reload_association`
* `reset_association`
* `association_changed?`
* `association_previously_changed?`

Dans toutes ces méthodes, `association` est remplacé par le symbole passé en premier argument à `belongs_to`. Par exemple, étant donné la déclaration :

```ruby
class Book < ApplicationRecord
  belongs_to :author
end
```

Chaque instance du modèle `Book` aura ces méthodes :

* `author`
* `author=`
* `build_author`
* `create_author`
* `create_author!`
* `reload_author`
* `reset_author`
* `author_changed?`
* `author_previously_changed?`

NOTE : Lors de l'initialisation d'une association `has_one` ou `belongs_to`, vous devez utiliser le préfixe `build_` pour construire l'association, plutôt que la méthode `association.build` qui serait utilisée pour les associations `has_many` ou `has_and_belongs_to_many`. Pour en créer une, utilisez le préfixe `create_`.

##### `association`

La méthode `association` renvoie l'objet associé, le cas échéant. Si aucun objet associé n'est trouvé, elle renvoie `nil`.

```ruby
@author = @book.author
```

Si l'objet associé a déjà été récupéré depuis la base de données pour cet objet, la version mise en cache sera renvoyée. Pour outrepasser ce comportement (et forcer une lecture depuis la base de données), appelez `#reload_association` sur l'objet parent.

```ruby
@author = @book.reload_author
```

Pour décharger la version mise en cache de l'objet associé, ce qui entraînera la prochaine accès, le cas échéant, à le récupérer depuis la base de données, appelez `#reset_association` sur l'objet parent.

```ruby
@book.reset_author
```

##### `association=(associate)`

La méthode `association=` attribue un objet associé à cet objet. En interne, cela signifie extraire la clé primaire de l'objet associé et définir la clé étrangère de cet objet sur la même valeur.

```ruby
@book.author = @author
```

##### `build_association(attributes = {})`

La méthode `build_association` renvoie un nouvel objet du type associé. Cet objet sera instancié à partir des attributs passés, et le lien via la clé étrangère de cet objet sera défini, mais l'objet associé ne sera _pas encore_ enregistré.

```ruby
@author = @book.build_author(author_number: 123,
                             author_name: "John Doe")
```

##### `create_association(attributes = {})`

La méthode `create_association` renvoie un nouvel objet du type associé. Cet objet sera instancié à partir des attributs passés, le lien via la clé étrangère de cet objet sera défini, et, une fois qu'il aura passé toutes les validations spécifiées sur le modèle associé, l'objet associé _sera_ enregistré.

```ruby
@author = @book.create_author(author_number: 123,
                              author_name: "John Doe")
```

##### `create_association!(attributes = {})`

Fait la même chose que `create_association` ci-dessus, mais lève `ActiveRecord::RecordInvalid` si l'enregistrement est invalide.

##### `association_changed?`

La méthode `association_changed?` renvoie true si un nouvel objet associé a été assigné et que la clé étrangère sera mise à jour lors de la prochaine sauvegarde.
```ruby
@book.author # => #<Author author_number: 123, author_name: "John Doe">
@book.author_changed? # => false

@book.author = Author.second # => #<Author author_number: 456, author_name: "Jane Smith">
@book.author_changed? # => true

@book.save!
@book.author_changed? # => false
```

##### `association_previously_changed?`

La méthode `association_previously_changed?` renvoie true si la sauvegarde précédente a mis à jour l'association pour référencer un nouvel objet associé.

```ruby
@book.author # => #<Author author_number: 123, author_name: "John Doe">
@book.author_previously_changed? # => false

@book.author = Author.second # => #<Author author_number: 456, author_name: "Jane Smith">
@book.save!
@book.author_previously_changed? # => true
```

#### Options pour `belongs_to`

Bien que Rails utilise des valeurs par défaut intelligentes qui fonctionneront bien dans la plupart des situations, il peut y avoir des moments où vous souhaitez personnaliser le comportement de la référence d'association `belongs_to`. De telles personnalisations peuvent facilement être réalisées en passant des options et des blocs de portée lors de la création de l'association. Par exemple, cette association utilise deux de ces options :

```ruby
class Book < ApplicationRecord
  belongs_to :author, touch: :books_updated_at,
    counter_cache: true
end
```

L'association [`belongs_to`][] prend en charge ces options :

* `:autosave`
* `:class_name`
* `:counter_cache`
* `:dependent`
* `:foreign_key`
* `:primary_key`
* `:inverse_of`
* `:polymorphic`
* `:touch`
* `:validate`
* `:optional`

##### `:autosave`

Si vous définissez l'option `:autosave` sur `true`, Rails sauvegardera tous les membres de l'association chargés et détruira les membres marqués pour destruction chaque fois que vous sauvegardez l'objet parent. Définir `:autosave` sur `false` n'est pas la même chose que de ne pas définir l'option `:autosave`. Si l'option `:autosave` n'est pas présente, alors les nouveaux objets associés seront sauvegardés, mais les objets associés mis à jour ne seront pas sauvegardés.

##### `:class_name`

Si le nom de l'autre modèle ne peut pas être déduit du nom de l'association, vous pouvez utiliser l'option `:class_name` pour fournir le nom du modèle. Par exemple, si un livre appartient à un auteur, mais que le nom réel du modèle contenant les auteurs est `Patron`, vous devez configurer les choses de cette manière :

```ruby
class Book < ApplicationRecord
  belongs_to :author, class_name: "Patron"
end
```

##### `:counter_cache`

L'option `:counter_cache` peut être utilisée pour rendre la recherche du nombre d'objets appartenant plus efficace. Considérez ces modèles :

```ruby
class Book < ApplicationRecord
  belongs_to :author
end

class Author < ApplicationRecord
  has_many :books
end
```

Avec ces déclarations, demander la valeur de `@author.books.size` nécessite un appel à la base de données pour effectuer une requête `COUNT(*)`. Pour éviter cet appel, vous pouvez ajouter un cache de compteur au modèle _appartenant_ :

```ruby
class Book < ApplicationRecord
  belongs_to :author, counter_cache: true
end

class Author < ApplicationRecord
  has_many :books
end
```

Avec cette déclaration, Rails maintiendra la valeur du cache à jour, puis renverra cette valeur en réponse à la méthode `size`.

Bien que l'option `:counter_cache` soit spécifiée sur le modèle qui inclut la déclaration `belongs_to`, la colonne réelle doit être ajoutée au modèle _associé_ (`has_many`). Dans le cas ci-dessus, vous devriez ajouter une colonne nommée `books_count` au modèle `Author`.

Vous pouvez remplacer le nom de colonne par défaut en spécifiant un nom de colonne personnalisé dans la déclaration `counter_cache` au lieu de `true`. Par exemple, pour utiliser `count_of_books` au lieu de `books_count` :

```ruby
class Book < ApplicationRecord
  belongs_to :author, counter_cache: :count_of_books
end

class Author < ApplicationRecord
  has_many :books
end
```

NOTE : Vous n'avez besoin de spécifier l'option `:counter_cache` que du côté `belongs_to` de l'association.

Les colonnes de cache de compteur sont ajoutées à la liste des attributs en lecture seule du modèle propriétaire via `attr_readonly`.

Si pour une raison quelconque vous modifiez la valeur de la clé primaire d'un modèle propriétaire, et que vous ne mettez pas à jour également les clés étrangères des modèles comptés, alors le cache de compteur peut contenir des données obsolètes. En d'autres termes, tous les modèles orphelins seront toujours pris en compte dans le compteur. Pour corriger un cache de compteur obsolète, utilisez [`reset_counters`][].


##### `:dependent`

Si vous définissez l'option `:dependent` sur :

* `:destroy`, lorsque l'objet est détruit, `destroy` sera appelé sur ses objets associés.
* `:delete`, lorsque l'objet est détruit, tous ses objets associés seront supprimés directement de la base de données sans appeler leur méthode `destroy`.
* `:destroy_async` : lorsque l'objet est détruit, une tâche `ActiveRecord::DestroyAssociationAsyncJob` est mise en file d'attente, qui appellera `destroy` sur ses objets associés. Active Job doit être configuré pour que cela fonctionne. N'utilisez pas cette option si l'association est soutenue par des contraintes de clé étrangère dans votre base de données. Les actions des contraintes de clé étrangère se produiront dans la même transaction qui supprime son propriétaire.
AVERTISSEMENT: Vous ne devez pas spécifier cette option sur une association `belongs_to` qui est connectée à une association `has_many` sur l'autre classe. Ce faisant, vous risquez d'avoir des enregistrements orphelins dans votre base de données.

##### `:foreign_key`

Par convention, Rails suppose que la colonne utilisée pour stocker la clé étrangère sur ce modèle est le nom de l'association avec le suffixe `_id` ajouté. L'option `:foreign_key` vous permet de définir directement le nom de la clé étrangère :

```ruby
class Book < ApplicationRecord
  belongs_to :author, class_name: "Patron",
                      foreign_key: "patron_id"
end
```

CONSEIL: Dans tous les cas, Rails ne créera pas de colonnes de clé étrangère pour vous. Vous devez les définir explicitement dans le cadre de vos migrations.

##### `:primary_key`

Par convention, Rails suppose que la colonne `id` est utilisée pour stocker la clé primaire de ses tables. L'option `:primary_key` vous permet de spécifier une colonne différente.

Par exemple, supposons que nous avons une table `users` avec `guid` comme clé primaire. Si nous voulons une table `todos` distincte pour stocker la clé étrangère `user_id` dans la colonne `guid`, nous pouvons utiliser `primary_key` pour y parvenir, comme ceci :

```ruby
class User < ApplicationRecord
  self.primary_key = 'guid' # la clé primaire est guid et non id
end

class Todo < ApplicationRecord
  belongs_to :user, primary_key: 'guid'
end
```

Lorsque nous exécutons `@user.todos.create`, l'enregistrement `@todo` aura sa valeur `user_id` comme valeur `guid` de `@user`.

##### `:inverse_of`

L'option `:inverse_of` spécifie le nom de l'association `has_many` ou `has_one` qui est l'inverse de cette association. Voir la section [association bidirectionnelle](#bi-directional-associations) pour plus de détails.

```ruby
class Author < ApplicationRecord
  has_many :books, inverse_of: :author
end

class Book < ApplicationRecord
  belongs_to :author, inverse_of: :books
end
```

##### `:polymorphic`

Passer `true` à l'option `:polymorphic` indique qu'il s'agit d'une association polymorphique. Les associations polymorphiques ont été discutées en détail <a href="#polymorphic-associations">plus tôt dans ce guide</a>.

##### `:touch`

Si vous définissez l'option `:touch` sur `true`, alors le timestamp `updated_at` ou `updated_on` sur l'objet associé sera mis à jour avec l'heure actuelle chaque fois que cet objet est enregistré ou détruit :

```ruby
class Book < ApplicationRecord
  belongs_to :author, touch: true
end

class Author < ApplicationRecord
  has_many :books
end
```

Dans ce cas, enregistrer ou détruire un livre mettra à jour le timestamp sur l'auteur associé. Vous pouvez également spécifier un attribut de timestamp particulier à mettre à jour :

```ruby
class Book < ApplicationRecord
  belongs_to :author, touch: :books_updated_at
end
```

##### `:validate`

Si vous définissez l'option `:validate` sur `true`, alors les nouveaux objets associés seront validés chaque fois que vous enregistrez cet objet. Par défaut, c'est `false` : les nouveaux objets associés ne seront pas validés lorsque cet objet est enregistré.

##### `:optional`

Si vous définissez l'option `:optional` sur `true`, alors la présence de l'objet associé ne sera pas validée. Par défaut, cette option est définie sur `false`.

#### Scopes pour `belongs_to`

Il peut arriver que vous souhaitiez personnaliser la requête utilisée par `belongs_to`. De telles personnalisations peuvent être réalisées via un bloc de portée. Par exemple :

```ruby
class Book < ApplicationRecord
  belongs_to :author, -> { where active: true }
end
```

Vous pouvez utiliser n'importe laquelle des méthodes de requête standard à l'intérieur du bloc de portée. Les suivantes sont discutées ci-dessous :

* `where`
* `includes`
* `readonly`
* `select`

##### `where`

La méthode `where` vous permet de spécifier les conditions que l'objet associé doit remplir.

```ruby
class Book < ApplicationRecord
  belongs_to :author, -> { where active: true }
end
```

##### `includes`

Vous pouvez utiliser la méthode `includes` pour spécifier les associations de second ordre qui doivent être chargées en avance lorsque cette association est utilisée. Par exemple, considérez ces modèles :

```ruby
class Chapter < ApplicationRecord
  belongs_to :book
end

class Book < ApplicationRecord
  belongs_to :author
  has_many :chapters
end

class Author < ApplicationRecord
  has_many :books
end
```

Si vous récupérez fréquemment les auteurs directement à partir des chapitres (`@chapter.book.author`), vous pouvez rendre votre code un peu plus efficace en incluant les auteurs dans l'association des chapitres aux livres :

```ruby
class Chapter < ApplicationRecord
  belongs_to :book, -> { includes :author }
end

class Book < ApplicationRecord
  belongs_to :author
  has_many :chapters
end

class Author < ApplicationRecord
  has_many :books
end
```

NOTE: Il n'est pas nécessaire d'utiliser `includes` pour les associations immédiates - c'est-à-dire, si vous avez `Book belongs_to :author`, alors l'auteur est chargé en avance automatiquement lorsque cela est nécessaire.

##### `readonly`

Si vous utilisez `readonly`, alors l'objet associé sera en lecture seule lorsqu'il est récupéré via l'association.
##### `select`

La méthode `select` vous permet de remplacer la clause SQL `SELECT` utilisée pour récupérer des données sur l'objet associé. Par défaut, Rails récupère toutes les colonnes.

CONSEIL : Si vous utilisez la méthode `select` sur une association `belongs_to`, vous devriez également définir l'option `:foreign_key` pour garantir les résultats corrects.

#### Des objets associés existent-ils ?

Vous pouvez vérifier si des objets associés existent en utilisant la méthode `association.nil?` :

```ruby
if @book.author.nil?
  @msg = "Aucun auteur trouvé pour ce livre"
end
```

#### Quand les objets sont-ils enregistrés ?

L'assignation d'un objet à une association `belongs_to` ne sauvegarde pas automatiquement l'objet. Elle ne sauvegarde pas non plus l'objet associé.

### Référence d'association `has_one`

L'association `has_one` crée une correspondance un-à-un avec un autre modèle. En termes de base de données, cette association indique que l'autre classe contient la clé étrangère. Si cette classe contient la clé étrangère, vous devriez utiliser `belongs_to` à la place.

#### Méthodes ajoutées par `has_one`

Lorsque vous déclarez une association `has_one`, la classe déclarante gagne automatiquement 6 méthodes liées à l'association :

* `association`
* `association=(associate)`
* `build_association(attributes = {})`
* `create_association(attributes = {})`
* `create_association!(attributes = {})`
* `reload_association`
* `reset_association`

Dans toutes ces méthodes, `association` est remplacé par le symbole passé en premier argument à `has_one`. Par exemple, avec la déclaration suivante :

```ruby
class Supplier < ApplicationRecord
  has_one :account
end
```

Chaque instance du modèle `Supplier` aura ces méthodes :

* `account`
* `account=`
* `build_account`
* `create_account`
* `create_account!`
* `reload_account`
* `reset_account`

NOTE : Lors de l'initialisation d'une nouvelle association `has_one` ou `belongs_to`, vous devez utiliser le préfixe `build_` pour construire l'association, plutôt que la méthode `association.build` qui serait utilisée pour les associations `has_many` ou `has_and_belongs_to_many`. Pour en créer une, utilisez le préfixe `create_`.

##### `association`

La méthode `association` renvoie l'objet associé, s'il existe. Si aucun objet associé n'est trouvé, elle renvoie `nil`.

```ruby
@account = @supplier.account
```

Si l'objet associé a déjà été récupéré de la base de données pour cet objet, la version mise en cache sera renvoyée. Pour outrepasser ce comportement (et forcer une lecture depuis la base de données), appelez `#reload_association` sur l'objet parent.

```ruby
@account = @supplier.reload_account
```

Pour décharger la version mise en cache de l'objet associé - forçant la prochaine accès, le cas échéant, à le récupérer depuis la base de données - appelez `#reset_association` sur l'objet parent.

```ruby
@supplier.reset_account
```

##### `association=(associate)`

La méthode `association=` assigne un objet associé à cet objet. En interne, cela signifie extraire la clé primaire de cet objet et définir la clé étrangère de l'objet associé sur la même valeur.

```ruby
@supplier.account = @account
```

##### `build_association(attributes = {})`

La méthode `build_association` renvoie un nouvel objet du type associé. Cet objet sera instancié à partir des attributs passés, et le lien via sa clé étrangère sera défini, mais l'objet associé ne sera _pas encore_ enregistré.

```ruby
@account = @supplier.build_account(terms: "Net 30")
```

##### `create_association(attributes = {})`

La méthode `create_association` renvoie un nouvel objet du type associé. Cet objet sera instancié à partir des attributs passés, le lien via sa clé étrangère sera défini, et, une fois qu'il aura passé toutes les validations spécifiées sur le modèle associé, l'objet associé _sera_ enregistré.

```ruby
@account = @supplier.create_account(terms: "Net 30")
```

##### `create_association!(attributes = {})`

Fait la même chose que `create_association` ci-dessus, mais lève une exception `ActiveRecord::RecordInvalid` si l'enregistrement est invalide.

#### Options pour `has_one`

Bien que Rails utilise des valeurs par défaut intelligentes qui fonctionneront bien dans la plupart des situations, il peut y avoir des moments où vous souhaitez personnaliser le comportement de la référence d'association `has_one`. De telles personnalisations peuvent facilement être réalisées en passant des options lors de la création de l'association. Par exemple, cette association utilise deux de ces options :

```ruby
class Supplier < ApplicationRecord
  has_one :account, class_name: "Billing", dependent: :nullify
end
```

L'association [`has_one`][] prend en charge ces options :

* `:as`
* `:autosave`
* `:class_name`
* `:dependent`
* `:foreign_key`
* `:inverse_of`
* `:primary_key`
* `:source`
* `:source_type`
* `:through`
* `:touch`
* `:validate`

##### `:as`

Le réglage de l'option `:as` indique qu'il s'agit d'une association polymorphique. Les associations polymorphiques ont été discutées en détail [plus tôt dans ce guide](#polymorphic-associations).

##### `:autosave`

Si vous définissez l'option `:autosave` sur `true`, Rails enregistrera tous les membres de l'association chargés et détruira les membres marqués pour destruction chaque fois que vous enregistrez l'objet parent. Définir `:autosave` sur `false` n'est pas la même chose que ne pas définir l'option `:autosave`. Si l'option `:autosave` n'est pas présente, alors les nouveaux objets associés seront enregistrés, mais les objets associés mis à jour ne seront pas enregistrés.
##### `:class_name`

Si le nom de l'autre modèle ne peut pas être déduit à partir du nom de l'association, vous pouvez utiliser l'option `:class_name` pour fournir le nom du modèle. Par exemple, si un fournisseur a un compte, mais que le nom réel du modèle contenant les comptes est `Billing`, vous devez configurer les choses de cette manière :

```ruby
class Supplier < ApplicationRecord
  has_one :account, class_name: "Billing"
end
```

##### `:dependent`

Contrôle ce qui se passe avec l'objet associé lorsque son propriétaire est détruit :

* `:destroy` détruit également l'objet associé
* `:delete` supprime directement l'objet associé de la base de données (les rappels ne seront pas exécutés)
* `:destroy_async` : lorsque l'objet est détruit, un travail `ActiveRecord::DestroyAssociationAsyncJob` est enregistré en file d'attente, qui appellera la méthode `destroy` sur ses objets associés. Active Job doit être configuré pour que cela fonctionne. N'utilisez pas cette option si l'association est soutenue par des contraintes de clé étrangère dans votre base de données. Les actions de contrainte de clé étrangère se produiront dans la même transaction qui supprime son propriétaire.
* `:nullify` définit la clé étrangère sur `NULL`. La colonne de type polymorphique est également définie sur `NULL` pour les associations polymorphiques. Les rappels ne sont pas exécutés.
* `:restrict_with_exception` provoque une exception `ActiveRecord::DeleteRestrictionError` si un enregistrement associé existe
* `:restrict_with_error` provoque une erreur ajoutée au propriétaire si un objet associé existe

Il est nécessaire de ne pas définir ou laisser l'option `:nullify` pour les associations qui ont des contraintes de base de données `NOT NULL`. Si vous ne définissez pas `dependent` pour détruire de telles associations, vous ne pourrez pas modifier l'objet associé car la clé étrangère de l'objet associé initial sera définie sur la valeur `NULL` non autorisée.

##### `:foreign_key`

Par convention, Rails suppose que la colonne utilisée pour contenir la clé étrangère sur l'autre modèle est le nom de ce modèle avec le suffixe `_id` ajouté. L'option `:foreign_key` vous permet de définir directement le nom de la clé étrangère :

```ruby
class Supplier < ApplicationRecord
  has_one :account, foreign_key: "supp_id"
end
```

CONSEIL : Dans tous les cas, Rails ne créera pas de colonnes de clé étrangère pour vous. Vous devez les définir explicitement dans le cadre de vos migrations.

##### `:inverse_of`

L'option `:inverse_of` spécifie le nom de l'association `belongs_to` qui est l'inverse de cette association. Consultez la section [association bidirectionnelle](#bi-directional-associations) pour plus de détails.

```ruby
class Supplier < ApplicationRecord
  has_one :account, inverse_of: :supplier
end

class Account < ApplicationRecord
  belongs_to :supplier, inverse_of: :account
end
```

##### `:primary_key`

Par convention, Rails suppose que la colonne utilisée pour contenir la clé primaire de ce modèle est `id`. Vous pouvez remplacer cela et spécifier explicitement la clé primaire avec l'option `:primary_key`.

##### `:source`

L'option `:source` spécifie le nom de l'association source pour une association `has_one :through`.

##### `:source_type`

L'option `:source_type` spécifie le type d'association source pour une association `has_one :through` qui passe par une association polymorphique.

```ruby
class Author < ApplicationRecord
  has_one :book
  has_one :hardback, through: :book, source: :format, source_type: "Hardback"
  has_one :dust_jacket, through: :hardback
end

class Book < ApplicationRecord
  belongs_to :format, polymorphic: true
end

class Paperback < ApplicationRecord; end

class Hardback < ApplicationRecord
  has_one :dust_jacket
end

class DustJacket < ApplicationRecord; end
```

##### `:through`

L'option `:through` spécifie un modèle de jointure à travers lequel effectuer la requête. Les associations `has_one :through` ont été discutées en détail [plus tôt dans ce guide](#the-has-one-through-association).

##### `:touch`

Si vous définissez l'option `:touch` sur `true`, alors l'horodatage `updated_at` ou `updated_on` sur l'objet associé sera défini sur l'heure actuelle chaque fois que cet objet est enregistré ou détruit :

```ruby
class Supplier < ApplicationRecord
  has_one :account, touch: true
end

class Account < ApplicationRecord
  belongs_to :supplier
end
```

Dans ce cas, enregistrer ou détruire un fournisseur mettra à jour l'horodatage sur le compte associé. Vous pouvez également spécifier un attribut d'horodatage particulier à mettre à jour :

```ruby
class Supplier < ApplicationRecord
  has_one :account, touch: :suppliers_updated_at
end
```

##### `:validate`

Si vous définissez l'option `:validate` sur `true`, alors les nouveaux objets associés seront validés chaque fois que vous enregistrez cet objet. Par défaut, cela est `false` : les nouveaux objets associés ne seront pas validés lorsque cet objet est enregistré.

#### Scopes pour `has_one`

Il peut arriver que vous souhaitiez personnaliser la requête utilisée par `has_one`. De telles personnalisations peuvent être réalisées via un bloc de portée. Par exemple :

```ruby
class Supplier < ApplicationRecord
  has_one :account, -> { where active: true }
end
```
Vous pouvez utiliser n'importe laquelle des méthodes de requête standard à l'intérieur du bloc de portée. Les suivantes sont discutées ci-dessous :

* `where`
* `includes`
* `readonly`
* `select`

##### `where`

La méthode `where` vous permet de spécifier les conditions que l'objet associé doit remplir.

```ruby
class Supplier < ApplicationRecord
  has_one :account, -> { where "confirmed = 1" }
end
```

##### `includes`

Vous pouvez utiliser la méthode `includes` pour spécifier les associations de second ordre qui doivent être chargées en avance lorsque cette association est utilisée. Par exemple, considérez ces modèles :

```ruby
class Supplier < ApplicationRecord
  has_one :account
end

class Account < ApplicationRecord
  belongs_to :supplier
  belongs_to :representative
end

class Representative < ApplicationRecord
  has_many :accounts
end
```

Si vous récupérez fréquemment des représentants directement à partir des fournisseurs (`@supplier.account.representative`), vous pouvez rendre votre code un peu plus efficace en incluant les représentants dans l'association des fournisseurs aux comptes :

```ruby
class Supplier < ApplicationRecord
  has_one :account, -> { includes :representative }
end

class Account < ApplicationRecord
  belongs_to :supplier
  belongs_to :representative
end

class Representative < ApplicationRecord
  has_many :accounts
end
```

##### `readonly`

Si vous utilisez la méthode `readonly`, alors l'objet associé sera en lecture seule lorsqu'il est récupéré via l'association.

##### `select`

La méthode `select` vous permet de remplacer la clause SQL `SELECT` utilisée pour récupérer des données sur l'objet associé. Par défaut, Rails récupère toutes les colonnes.

#### Des objets associés existent-ils ?

Vous pouvez vérifier si des objets associés existent en utilisant la méthode `association.nil?` :

```ruby
if @supplier.account.nil?
  @msg = "Aucun compte trouvé pour ce fournisseur"
end
```

#### Quand les objets sont-ils enregistrés ?

Lorsque vous assignez un objet à une association `has_one`, cet objet est automatiquement enregistré (afin de mettre à jour sa clé étrangère). De plus, tout objet qui est remplacé est également automatiquement enregistré, car sa clé étrangère changera également.

Si l'un de ces enregistrements échoue en raison d'erreurs de validation, alors l'instruction d'assignation renvoie `false` et l'assignation elle-même est annulée.

Si l'objet parent (celui qui déclare l'association `has_one`) n'est pas enregistré (c'est-à-dire que `new_record?` renvoie `true`), alors les objets enfants ne sont pas enregistrés. Ils le seront automatiquement lorsque l'objet parent sera enregistré.

Si vous souhaitez assigner un objet à une association `has_one` sans enregistrer l'objet, utilisez la méthode `build_association`.

### Référence d'association `has_many`

L'association `has_many` crée une relation un-à-plusieurs avec un autre modèle. En termes de base de données, cette association indique que l'autre classe aura une clé étrangère qui fait référence à des instances de cette classe.

#### Méthodes ajoutées par `has_many`

Lorsque vous déclarez une association `has_many`, la classe déclarante gagne automatiquement 17 méthodes liées à l'association :

* `collection`
* [`collection<<(object, ...)`][`collection<<`]
* [`collection.delete(object, ...)`][`collection.delete`]
* [`collection.destroy(object, ...)`][`collection.destroy`]
* `collection=(objects)`
* `collection_singular_ids`
* `collection_singular_ids=(ids)`
* [`collection.clear`][]
* [`collection.empty?`][]
* [`collection.size`][]
* [`collection.find(...)`][`collection.find`]
* [`collection.where(...)`][`collection.where`]
* [`collection.exists?(...)`][`collection.exists?`]
* [`collection.build(attributes = {})`][`collection.build`]
* [`collection.create(attributes = {})`][`collection.create`]
* [`collection.create!(attributes = {})`][`collection.create!`]
* [`collection.reload`][]

Dans toutes ces méthodes, `collection` est remplacé par le symbole passé en premier argument à `has_many`, et `collection_singular` est remplacé par la version au singulier de ce symbole. Par exemple, étant donné la déclaration :

```ruby
class Author < ApplicationRecord
  has_many :books
end
```

Chaque instance du modèle `Author` aura ces méthodes :

```ruby
books
books<<(object, ...)
books.delete(object, ...)
books.destroy(object, ...)
books=(objects)
book_ids
book_ids=(ids)
books.clear
books.empty?
books.size
books.find(...)
books.where(...)
books.exists?(...)
books.build(attributes = {}, ...)
books.create(attributes = {})
books.create!(attributes = {})
books.reload
```

##### `collection`

La méthode `collection` renvoie une Relation de tous les objets associés. S'il n'y a pas d'objets associés, elle renvoie une Relation vide.

```ruby
@books = @author.books
```

##### `collection<<(object, ...)`

La méthode [`collection<<`][] ajoute un ou plusieurs objets à la collection en définissant leurs clés étrangères sur la clé primaire du modèle appelant.

```ruby
@author.books << @book1
```

##### `collection.delete(object, ...)`

La méthode [`collection.delete`][] supprime un ou plusieurs objets de la collection en définissant leurs clés étrangères sur `NULL`.

```ruby
@author.books.delete(@book1)
```

AVERTISSEMENT : De plus, les objets seront détruits s'ils sont associés à `dependent: :destroy`, et supprimés s'ils sont associés à `dependent: :delete_all`.

##### `collection.destroy(object, ...)`

La méthode [`collection.destroy`][] supprime un ou plusieurs objets de la collection en exécutant `destroy` sur chaque objet.

```ruby
@author.books.destroy(@book1)
```

AVERTISSEMENT : Les objets seront _toujours_ supprimés de la base de données, en ignorant l'option `:dependent`.

##### `collection=(objects)`

La méthode `collection=` fait en sorte que la collection ne contienne que les objets fournis, en ajoutant et en supprimant au besoin. Les modifications sont persistées dans la base de données.
##### `collection_singular_ids`

La méthode `collection_singular_ids` renvoie un tableau des identifiants des objets dans la collection.

```ruby
@book_ids = @author.book_ids
```

##### `collection_singular_ids=(ids)`

La méthode `collection_singular_ids=` fait en sorte que la collection ne contienne que les objets identifiés par les valeurs de clé primaire fournies, en ajoutant et en supprimant au besoin. Les modifications sont persistées dans la base de données.

##### `collection.clear`

La méthode [`collection.clear`][] supprime tous les objets de la collection selon la stratégie spécifiée par l'option `dependent`. Si aucune option n'est donnée, elle suit la stratégie par défaut. La stratégie par défaut pour les associations `has_many :through` est `delete_all`, et pour les associations `has_many` est de définir les clés étrangères à `NULL`.

```ruby
@author.books.clear
```

AVERTISSEMENT : Les objets seront supprimés s'ils sont associés à `dependent: :destroy` ou `dependent: :destroy_async`, tout comme `dependent: :delete_all`.

##### `collection.empty?`

La méthode [`collection.empty?`][] renvoie `true` si la collection ne contient aucun objet associé.

```erb
<% if @author.books.empty? %>
  Aucun livre trouvé
<% end %>
```

##### `collection.size`

La méthode [`collection.size`][] renvoie le nombre d'objets dans la collection.

```ruby
@book_count = @author.books.size
```

##### `collection.find(...)`

La méthode [`collection.find`][] trouve des objets dans la table de la collection.

```ruby
@available_book = @author.books.find(1)
```

##### `collection.where(...)`

La méthode [`collection.where`][] trouve des objets dans la collection en fonction des conditions fournies, mais les objets sont chargés de manière paresseuse, ce qui signifie que la base de données est interrogée uniquement lorsque les objets sont accédés.

```ruby
@available_books = author.books.where(available: true) # Pas encore de requête
@available_book = @available_books.first # Maintenant la base de données sera interrogée
```

##### `collection.exists?(...)`

La méthode [`collection.exists?`][] vérifie si un objet répondant aux conditions fournies existe dans la table de la collection.

##### `collection.build(attributes = {})`

La méthode [`collection.build`][] renvoie un seul objet ou un tableau de nouveaux objets du type associé. L'objet(s) sera instancié à partir des attributs passés, et le lien via sa clé étrangère sera créé, mais les objets associés ne seront _pas_ encore enregistrés.

```ruby
@book = author.books.build(published_at: Time.now,
                            book_number: "A12345")

@books = author.books.build([
  { published_at: Time.now, book_number: "A12346" },
  { published_at: Time.now, book_number: "A12347" }
])
```

##### `collection.create(attributes = {})`

La méthode [`collection.create`][] renvoie un seul objet ou un tableau de nouveaux objets du type associé. L'objet(s) sera instancié à partir des attributs passés, le lien via sa clé étrangère sera créé, et, une fois qu'il passe toutes les validations spécifiées sur le modèle associé, l'objet associé sera _enregistré_.

```ruby
@book = author.books.create(published_at: Time.now,
                             book_number: "A12345")

@books = author.books.create([
  { published_at: Time.now, book_number: "A12346" },
  { published_at: Time.now, book_number: "A12347" }
])
```

##### `collection.create!(attributes = {})`

Fait la même chose que `collection.create` ci-dessus, mais lève une exception `ActiveRecord::RecordInvalid` si l'enregistrement est invalide.

##### `collection.reload`

La méthode [`collection.reload`][] renvoie une Relation de tous les objets associés, en forçant une lecture de la base de données. S'il n'y a pas d'objets associés, elle renvoie une Relation vide.

```ruby
@books = author.books.reload
```

#### Options pour `has_many`

Bien que Rails utilise des valeurs par défaut intelligentes qui fonctionneront bien dans la plupart des situations, il peut y avoir des moments où vous souhaitez personnaliser le comportement de la référence d'association `has_many`. De telles personnalisations peuvent être facilement réalisées en passant des options lors de la création de l'association. Par exemple, cette association utilise deux de ces options :

```ruby
class Author < ApplicationRecord
  has_many :books, dependent: :delete_all, validate: false
end
```

L'association [`has_many`][] prend en charge ces options :

* `:as`
* `:autosave`
* `:class_name`
* `:counter_cache`
* `:dependent`
* `:foreign_key`
* `:inverse_of`
* `:primary_key`
* `:source`
* `:source_type`
* `:through`
* `:validate`

##### `:as`

Le réglage de l'option `:as` indique qu'il s'agit d'une association polymorphique, comme discuté [plus tôt dans ce guide](#polymorphic-associations).

##### `:autosave`

Si vous définissez l'option `:autosave` sur `true`, Rails enregistrera tous les membres de l'association chargés et détruira les membres marqués pour destruction chaque fois que vous enregistrez l'objet parent. Définir `:autosave` sur `false` n'est pas la même chose que de ne pas définir l'option `:autosave`. Si l'option `:autosave` n'est pas présente, les nouveaux objets associés seront enregistrés, mais les objets associés mis à jour ne seront pas enregistrés.

##### `:class_name`

Si le nom de l'autre modèle ne peut pas être déduit du nom de l'association, vous pouvez utiliser l'option `:class_name` pour fournir le nom du modèle. Par exemple, si un auteur a plusieurs livres, mais que le nom réel du modèle contenant les livres est `Transaction`, vous le configureriez de cette manière :

```ruby
class Author < ApplicationRecord
  has_many :books, class_name: "Transaction"
end
```
##### `:counter_cache`

Cette option peut être utilisée pour configurer un `:counter_cache` personnalisé. Vous n'avez besoin de cette option que lorsque vous avez personnalisé le nom de votre `:counter_cache` sur l'association [belongs_to](#options-for-belongs-to).

##### `:dependent`

Contrôle ce qui se passe avec les objets associés lorsque leur propriétaire est détruit :

* `:destroy` entraîne également la destruction de tous les objets associés
* `:delete_all` entraîne la suppression directe de tous les objets associés de la base de données (les rappels ne seront pas exécutés)
* `:destroy_async` : lorsque l'objet est détruit, un travail `ActiveRecord::DestroyAssociationAsyncJob` est mis en file d'attente, qui appellera la méthode destroy sur ses objets associés. Active Job doit être configuré pour que cela fonctionne.
* `:nullify` entraîne la mise à `NULL` de la clé étrangère. La colonne de type polymorphique est également mise à `NULL` sur les associations polymorphiques. Les rappels ne sont pas exécutés.
* `:restrict_with_exception` entraîne la levée d'une exception `ActiveRecord::DeleteRestrictionError` s'il existe des enregistrements associés
* `:restrict_with_error` entraîne l'ajout d'une erreur au propriétaire s'il existe des objets associés

Les options `:destroy` et `:delete_all` affectent également la sémantique des méthodes `collection.delete` et `collection=` en les amenant à détruire les objets associés lorsqu'ils sont supprimés de la collection.

##### `:foreign_key`

Par convention, Rails suppose que la colonne utilisée pour contenir la clé étrangère sur l'autre modèle est le nom de ce modèle avec le suffixe `_id` ajouté. L'option `:foreign_key` vous permet de définir directement le nom de la clé étrangère :

```ruby
class Author < ApplicationRecord
  has_many :books, foreign_key: "cust_id"
end
```

CONSEIL : Dans tous les cas, Rails ne créera pas de colonnes de clé étrangère pour vous. Vous devez les définir explicitement dans le cadre de vos migrations.

##### `:inverse_of`

L'option `:inverse_of` spécifie le nom de l'association `belongs_to` qui est l'inverse de cette association.
Voir la section [association bidirectionnelle](#bi-directional-associations) pour plus de détails.

```ruby
class Author < ApplicationRecord
  has_many :books, inverse_of: :author
end

class Book < ApplicationRecord
  belongs_to :author, inverse_of: :books
end
```

##### `:primary_key`

Par convention, Rails suppose que la colonne utilisée pour contenir la clé primaire de l'association est `id`. Vous pouvez remplacer cela et spécifier explicitement la clé primaire avec l'option `:primary_key`.

Supposons que la table `users` ait `id` comme clé primaire mais qu'elle ait également une colonne `guid`. L'exigence est que la table `todos` doit contenir la valeur de la colonne `guid` en tant que clé étrangère et non la valeur `id`. Cela peut être réalisé comme ceci :

```ruby
class User < ApplicationRecord
  has_many :todos, primary_key: :guid
end
```

Maintenant, si nous exécutons `@todo = @user.todos.create`, la valeur de `user_id` de l'enregistrement `@todo` sera la valeur `guid` de `@user`.

##### `:source`

L'option `:source` spécifie le nom de l'association source pour une association `has_many :through`. Vous n'avez besoin d'utiliser cette option que si le nom de l'association source ne peut pas être déduit automatiquement à partir du nom de l'association.

##### `:source_type`

L'option `:source_type` spécifie le type d'association source pour une association `has_many :through` qui passe par une association polymorphique.

```ruby
class Author < ApplicationRecord
  has_many :books
  has_many :paperbacks, through: :books, source: :format, source_type: "Paperback"
end

class Book < ApplicationRecord
  belongs_to :format, polymorphic: true
end

class Hardback < ApplicationRecord; end
class Paperback < ApplicationRecord; end
```

##### `:through`

L'option `:through` spécifie un modèle de jointure à travers lequel effectuer la requête. Les associations `has_many :through` permettent de mettre en œuvre des relations de nombreux à nombreux, comme discuté [plus tôt dans ce guide](#the-has-many-through-association).

##### `:validate`

Si vous définissez l'option `:validate` sur `false`, les nouveaux objets associés ne seront pas validés chaque fois que vous enregistrez cet objet. Par défaut, cela est `true` : les nouveaux objets associés seront validés lorsque cet objet est enregistré.

#### Scopes pour `has_many`

Il peut arriver que vous souhaitiez personnaliser la requête utilisée par `has_many`. De telles personnalisations peuvent être réalisées via un bloc de portée. Par exemple :

```ruby
class Author < ApplicationRecord
  has_many :books, -> { where processed: true }
end
```

Vous pouvez utiliser n'importe quelle [méthode de requête](active_record_querying.html) standard à l'intérieur du bloc de portée. Les suivantes sont discutées ci-dessous :

* `where`
* `extending`
* `group`
* `includes`
* `limit`
* `offset`
* `order`
* `readonly`
* `select`
* `distinct`

##### `where`

La méthode `where` vous permet de spécifier les conditions que l'objet associé doit remplir.

```ruby
class Author < ApplicationRecord
  has_many :confirmed_books, -> { where "confirmed = 1" },
    class_name: "Book"
end
```
Vous pouvez également définir des conditions via un hash :

```ruby
class Author < ApplicationRecord
  has_many :confirmed_books, -> { where confirmed: true },
    class_name: "Book"
end
```

Si vous utilisez une option `where` de style hash, la création d'enregistrements via cette association sera automatiquement limitée en utilisant le hash. Dans ce cas, l'utilisation de `@author.confirmed_books.create` ou `@author.confirmed_books.build` créera des livres où la colonne confirmed a la valeur `true`.

##### `extending`

La méthode `extending` spécifie un module nommé à étendre sur le proxy d'association. Les extensions d'association sont discutées en détail [plus loin dans ce guide](#association-extensions).

##### `group`

La méthode `group` fournit un nom d'attribut pour regrouper le jeu de résultats en utilisant une clause `GROUP BY` dans le SQL du finder.

```ruby
class Author < ApplicationRecord
  has_many :chapters, -> { group 'books.id' },
                      through: :books
end
```

##### `includes`

Vous pouvez utiliser la méthode `includes` pour spécifier des associations de second ordre qui doivent être préchargées lorsque cette association est utilisée. Par exemple, considérez ces modèles :

```ruby
class Author < ApplicationRecord
  has_many :books
end

class Book < ApplicationRecord
  belongs_to :author
  has_many :chapters
end

class Chapter < ApplicationRecord
  belongs_to :book
end
```

Si vous récupérez fréquemment des chapitres directement à partir des auteurs (`@author.books.chapters`), vous pouvez rendre votre code un peu plus efficace en incluant les chapitres dans l'association des auteurs aux livres :

```ruby
class Author < ApplicationRecord
  has_many :books, -> { includes :chapters }
end

class Book < ApplicationRecord
  belongs_to :author
  has_many :chapters
end

class Chapter < ApplicationRecord
  belongs_to :book
end
```

##### `limit`

La méthode `limit` vous permet de limiter le nombre total d'objets qui seront récupérés via une association.

```ruby
class Author < ApplicationRecord
  has_many :recent_books,
    -> { order('published_at desc').limit(100) },
    class_name: "Book"
end
```

##### `offset`

La méthode `offset` vous permet de spécifier le décalage de départ pour la récupération des objets via une association. Par exemple, `-> { offset(11) }` sautera les 11 premiers enregistrements.

##### `order`

La méthode `order` dicte l'ordre dans lequel les objets associés seront reçus (dans la syntaxe utilisée par une clause SQL `ORDER BY`).

```ruby
class Author < ApplicationRecord
  has_many :books, -> { order "date_confirmed DESC" }
end
```

##### `readonly`

Si vous utilisez la méthode `readonly`, alors les objets associés seront en lecture seule lorsqu'ils sont récupérés via l'association.

##### `select`

La méthode `select` vous permet de remplacer la clause SQL `SELECT` utilisée pour récupérer des données sur les objets associés. Par défaut, Rails récupère toutes les colonnes.

AVERTISSEMENT : Si vous spécifiez votre propre `select`, assurez-vous d'inclure les colonnes de clé primaire et de clé étrangère du modèle associé. Sinon, Rails lèvera une erreur.

##### `distinct`

Utilisez la méthode `distinct` pour garder la collection sans doublons. Cela est principalement utile avec l'option `:through`.

```ruby
class Person < ApplicationRecord
  has_many :readings
  has_many :articles, through: :readings
end
```

```irb
irb> person = Person.create(name: 'John')
irb> article = Article.create(name: 'a1')
irb> person.articles << article
irb> person.articles << article
irb> person.articles.to_a
=> [#<Article id: 5, name: "a1">, #<Article id: 5, name: "a1">]
irb> Reading.all.to_a
=> [#<Reading id: 12, person_id: 5, article_id: 5>, #<Reading id: 13, person_id: 5, article_id: 5>]
```

Dans le cas ci-dessus, il y a deux lectures et `person.articles` en affiche deux même si ces enregistrements pointent vers le même article.

Maintenant, définissons `distinct` :

```ruby
class Person
  has_many :readings
  has_many :articles, -> { distinct }, through: :readings
end
```

```irb
irb> person = Person.create(name: 'Honda')
irb> article = Article.create(name: 'a1')
irb> person.articles << article
irb> person.articles << article
irb> person.articles.to_a
=> [#<Article id: 7, name: "a1">]
irb> Reading.all.to_a
=> [#<Reading id: 16, person_id: 7, article_id: 7>, #<Reading id: 17, person_id: 7, article_id: 7>]
```

Dans le cas ci-dessus, il y a toujours deux lectures. Cependant, `person.articles` n'affiche qu'un seul article car la collection ne charge que des enregistrements uniques.

Si vous souhaitez vous assurer que, lors de l'insertion, tous les enregistrements de l'association persistée sont distincts (afin de vous assurer que lorsque vous inspectez l'association, vous ne trouverez jamais d'enregistrements en double), vous devriez ajouter un index unique sur la table elle-même. Par exemple, si vous avez une table nommée `readings` et que vous voulez vous assurer que les articles ne peuvent être ajoutés à une personne qu'une seule fois, vous pouvez ajouter ce qui suit dans une migration :

```ruby
add_index :readings, [:person_id, :article_id], unique: true
```
Une fois que vous avez cet index unique, essayer d'ajouter l'article à une personne deux fois
soulèvera une erreur `ActiveRecord::RecordNotUnique` :

```irb
irb> person = Person.create(name: 'Honda')
irb> article = Article.create(name: 'a1')
irb> person.articles << article
irb> person.articles << article
ActiveRecord::RecordNotUnique
```

Notez que la vérification de l'unicité à l'aide de quelque chose comme `include?` est sujette
à des conditions de concurrence. N'essayez pas d'utiliser `include?` pour garantir la distinction
dans une association. Par exemple, en utilisant l'exemple d'article ci-dessus, le
code suivant serait sujet à des conditions de concurrence car plusieurs utilisateurs pourraient essayer cela
en même temps :

```ruby
person.articles << article unless person.articles.include?(article)
```

#### Quand les objets sont-ils enregistrés ?

Lorsque vous assignez un objet à une association `has_many`, cet objet est automatiquement enregistré (afin de mettre à jour sa clé étrangère). Si vous assignez plusieurs objets en une seule instruction, ils sont tous enregistrés.

Si l'un de ces enregistrements échoue en raison d'erreurs de validation, alors l'instruction d'assignation renvoie `false` et l'assignation elle-même est annulée.

Si l'objet parent (celui qui déclare l'association `has_many`) n'est pas enregistré (c'est-à-dire que `new_record?` renvoie `true`), alors les objets enfants ne sont pas enregistrés lorsqu'ils sont ajoutés. Tous les membres non enregistrés de l'association seront automatiquement enregistrés lorsque le parent sera enregistré.

Si vous souhaitez assigner un objet à une association `has_many` sans enregistrer l'objet, utilisez la méthode `collection.build`.

### Référence de l'association `has_and_belongs_to_many`

L'association `has_and_belongs_to_many` crée une relation de plusieurs à plusieurs avec un autre modèle. En termes de base de données, cela associe deux classes via une table de jointure intermédiaire qui inclut des clés étrangères se référant à chacune des classes.

#### Méthodes ajoutées par `has_and_belongs_to_many`

Lorsque vous déclarez une association `has_and_belongs_to_many`, la classe déclarante gagne automatiquement plusieurs méthodes liées à l'association :

* `collection`
* [`collection<<(object, ...)`][`collection<<`]
* [`collection.delete(object, ...)`][`collection.delete`]
* [`collection.destroy(object, ...)`][`collection.destroy`]
* `collection=(objects)`
* `collection_singular_ids`
* `collection_singular_ids=(ids)`
* [`collection.clear`][]
* [`collection.empty?`][]
* [`collection.size`][]
* [`collection.find(...)`][`collection.find`]
* [`collection.where(...)`][`collection.where`]
* [`collection.exists?(...)`][`collection.exists?`]
* [`collection.build(attributes = {})`][`collection.build`]
* [`collection.create(attributes = {})`][`collection.create`]
* [`collection.create!(attributes = {})`][`collection.create!`]
* [`collection.reload`][]

Dans toutes ces méthodes, `collection` est remplacé par le symbole passé en premier argument à `has_and_belongs_to_many`, et `collection_singular` est remplacé par la version au singulier de ce symbole. Par exemple, étant donné la déclaration :

```ruby
class Part < ApplicationRecord
  has_and_belongs_to_many :assemblies
end
```

Chaque instance du modèle `Part` aura ces méthodes :

```ruby
assemblies
assemblies<<(object, ...)
assemblies.delete(object, ...)
assemblies.destroy(object, ...)
assemblies=(objects)
assembly_ids
assembly_ids=(ids)
assemblies.clear
assemblies.empty?
assemblies.size
assemblies.find(...)
assemblies.where(...)
assemblies.exists?(...)
assemblies.build(attributes = {}, ...)
assemblies.create(attributes = {})
assemblies.create!(attributes = {})
assemblies.reload
```

##### Méthodes de colonne supplémentaires

Si la table de jointure pour une association `has_and_belongs_to_many` a des colonnes supplémentaires en plus des deux clés étrangères, ces colonnes seront ajoutées en tant qu'attributs aux enregistrements récupérés via cette association. Les enregistrements retournés avec des attributs supplémentaires seront toujours en lecture seule, car Rails ne peut pas enregistrer les modifications de ces attributs.

AVERTISSEMENT : L'utilisation d'attributs supplémentaires sur la table de jointure dans une association `has_and_belongs_to_many` est déconseillée. Si vous avez besoin de ce type de comportement complexe sur la table qui joint deux modèles dans une relation de plusieurs à plusieurs, vous devriez utiliser une association `has_many :through` au lieu de `has_and_belongs_to_many`.

##### `collection`

La méthode `collection` renvoie une Relation de tous les objets associés. S'il n'y a pas d'objets associés, elle renvoie une Relation vide.

```ruby
@assemblies = @part.assemblies
```

##### `collection<<(object, ...)`

La méthode [`collection<<`][] ajoute un ou plusieurs objets à la collection en créant des enregistrements dans la table de jointure.

```ruby
@part.assemblies << @assembly1
```

NOTE : Cette méthode est également appelée `collection.concat` et `collection.push`.

##### `collection.delete(object, ...)`

La méthode [`collection.delete`][] supprime un ou plusieurs objets de la collection en supprimant les enregistrements dans la table de jointure. Cela ne détruit pas les objets.

```ruby
@part.assemblies.delete(@assembly1)
```

##### `collection.destroy(object, ...)`

La méthode [`collection.destroy`][] supprime un ou plusieurs objets de la collection en supprimant les enregistrements dans la table de jointure. Cela ne détruit pas les objets.

```ruby
@part.assemblies.destroy(@assembly1)
```

##### `collection=(objects)`

La méthode `collection=` fait en sorte que la collection ne contienne que les objets fournis, en ajoutant et en supprimant au besoin. Les modifications sont persistées dans la base de données.

##### `collection_singular_ids`

La méthode `collection_singular_ids` renvoie un tableau des identifiants des objets de la collection.

```ruby
@assembly_ids = @part.assembly_ids
```

##### `collection_singular_ids=(ids)`

La méthode `collection_singular_ids=` fait en sorte que la collection ne contienne que les objets identifiés par les valeurs des clés primaires fournies, en ajoutant et en supprimant au besoin. Les modifications sont persistées dans la base de données.
##### `collection.clear`

La méthode [`collection.clear`][] supprime chaque objet de la collection en supprimant les lignes de la table de jointure. Cela ne détruit pas les objets associés.

##### `collection.empty?`

La méthode [`collection.empty?`][] renvoie `true` si la collection ne contient aucun objet associé.

```html+erb
<% if @part.assemblies.empty? %>
  Cette pièce n'est utilisée dans aucune assemblée
<% end %>
```

##### `collection.size`

La méthode [`collection.size`][] renvoie le nombre d'objets dans la collection.

```ruby
@assembly_count = @part.assemblies.size
```

##### `collection.find(...)`

La méthode [`collection.find`][] trouve des objets dans la table de la collection.

```ruby
@assembly = @part.assemblies.find(1)
```

##### `collection.where(...)`

La méthode [`collection.where`][] trouve des objets dans la collection en fonction des conditions fournies, mais les objets sont chargés de manière paresseuse, ce qui signifie que la base de données est interrogée uniquement lorsque les objets sont accédés.

```ruby
@new_assemblies = @part.assemblies.where("created_at > ?", 2.days.ago)
```

##### `collection.exists?(...)`

La méthode [`collection.exists?`][] vérifie si un objet répondant aux conditions fournies existe dans la table de la collection.

##### `collection.build(attributes = {})`

La méthode [`collection.build`][] renvoie un nouvel objet du type associé. Cet objet sera instancié à partir des attributs passés, et le lien via la table de jointure sera créé, mais l'objet associé ne sera pas encore enregistré.

```ruby
@assembly = @part.assemblies.build({ assembly_name: "Boîtier de transmission" })
```

##### `collection.create(attributes = {})`

La méthode [`collection.create`][] renvoie un nouvel objet du type associé. Cet objet sera instancié à partir des attributs passés, le lien via la table de jointure sera créé, et une fois qu'il aura passé toutes les validations spécifiées sur le modèle associé, l'objet associé sera enregistré.

```ruby
@assembly = @part.assemblies.create({ assembly_name: "Boîtier de transmission" })
```

##### `collection.create!(attributes = {})`

Fait la même chose que `collection.create`, mais génère une exception `ActiveRecord::RecordInvalid` si l'enregistrement est invalide.

##### `collection.reload`

La méthode [`collection.reload`][] renvoie une Relation de tous les objets associés, en forçant une lecture de la base de données. S'il n'y a pas d'objets associés, elle renvoie une Relation vide.

```ruby
@assemblies = @part.assemblies.reload
```

#### Options pour `has_and_belongs_to_many`

Bien que Rails utilise des valeurs par défaut intelligentes qui fonctionneront bien dans la plupart des situations, il peut arriver que vous souhaitiez personnaliser le comportement de la référence d'association `has_and_belongs_to_many`. De telles personnalisations peuvent être facilement réalisées en passant des options lors de la création de l'association. Par exemple, cette association utilise deux options :

```ruby
class Parts < ApplicationRecord
  has_and_belongs_to_many :assemblies, -> { readonly },
                                       autosave: true
end
```

L'association [`has_and_belongs_to_many`][] prend en charge ces options :

* `:association_foreign_key`
* `:autosave`
* `:class_name`
* `:foreign_key`
* `:join_table`
* `:validate`

##### `:association_foreign_key`

Par convention, Rails suppose que la colonne dans la table de jointure utilisée pour contenir la clé étrangère pointant vers l'autre modèle est le nom de ce modèle avec le suffixe `_id` ajouté. L'option `:association_foreign_key` vous permet de définir directement le nom de la clé étrangère :

CONSEIL : Les options `:foreign_key` et `:association_foreign_key` sont utiles lors de la configuration d'une auto-jointure many-to-many. Par exemple :

```ruby
class User < ApplicationRecord
  has_and_belongs_to_many :friends,
      class_name: "User",
      foreign_key: "this_user_id",
      association_foreign_key: "other_user_id"
end
```

##### `:autosave`

Si vous définissez l'option `:autosave` sur `true`, Rails enregistrera tous les membres de l'association chargés et détruira les membres marqués pour destruction chaque fois que vous enregistrez l'objet parent. Définir `:autosave` sur `false` n'est pas la même chose que de ne pas définir l'option `:autosave`. Si l'option `:autosave` n'est pas présente, alors les nouveaux objets associés seront enregistrés, mais les objets associés mis à jour ne seront pas enregistrés.

##### `:class_name`

Si le nom de l'autre modèle ne peut pas être déduit du nom de l'association, vous pouvez utiliser l'option `:class_name` pour fournir le nom du modèle. Par exemple, si une pièce a plusieurs assemblages, mais que le nom réel du modèle contenant les assemblages est `Gadget`, vous configureriez les choses de cette manière :

```ruby
class Parts < ApplicationRecord
  has_and_belongs_to_many :assemblies, class_name: "Gadget"
end
```

##### `:foreign_key`

Par convention, Rails suppose que la colonne dans la table de jointure utilisée pour contenir la clé étrangère pointant vers ce modèle est le nom de ce modèle avec le suffixe `_id` ajouté. L'option `:foreign_key` vous permet de définir directement le nom de la clé étrangère :

```ruby
class User < ApplicationRecord
  has_and_belongs_to_many :friends,
      class_name: "User",
      foreign_key: "this_user_id",
      association_foreign_key: "other_user_id"
end
```

##### `:join_table`

Si le nom par défaut de la table de jointure, basé sur l'ordre lexical, ne vous convient pas, vous pouvez utiliser l'option `:join_table` pour remplacer la valeur par défaut.
##### `:validate`

Si vous définissez l'option `:validate` sur `false`, alors les nouveaux objets associés ne seront pas validés chaque fois que vous enregistrez cet objet. Par défaut, cette option est à `true` : les nouveaux objets associés seront validés lorsque cet objet est enregistré.

#### Scopes pour `has_and_belongs_to_many`

Il peut arriver que vous souhaitiez personnaliser la requête utilisée par `has_and_belongs_to_many`. De telles personnalisations peuvent être réalisées via un bloc de portée. Par exemple :

```ruby
class Parts < ApplicationRecord
  has_and_belongs_to_many :assemblies, -> { where active: true }
end
```

Vous pouvez utiliser n'importe laquelle des méthodes de requête standard [querying methods](active_record_querying.html) à l'intérieur du bloc de portée. Les suivantes sont discutées ci-dessous :

* `where`
* `extending`
* `group`
* `includes`
* `limit`
* `offset`
* `order`
* `readonly`
* `select`
* `distinct`

##### `where`

La méthode `where` vous permet de spécifier les conditions que l'objet associé doit remplir.

```ruby
class Parts < ApplicationRecord
  has_and_belongs_to_many :assemblies,
    -> { where "factory = 'Seattle'" }
end
```

Vous pouvez également définir des conditions via un hash :

```ruby
class Parts < ApplicationRecord
  has_and_belongs_to_many :assemblies,
    -> { where factory: 'Seattle' }
end
```

Si vous utilisez un `where` de style hash, alors la création d'enregistrements via cette association sera automatiquement limitée en utilisant le hash. Dans ce cas, l'utilisation de `@parts.assemblies.create` ou `@parts.assemblies.build` créera des assemblages où la colonne `factory` a la valeur "Seattle".

##### `extending`

La méthode `extending` spécifie un module nommé à étendre sur le proxy d'association. Les extensions d'association sont discutées en détail [plus loin dans ce guide](#association-extensions).

##### `group`

La méthode `group` fournit un nom d'attribut pour regrouper le jeu de résultats, en utilisant une clause `GROUP BY` dans la requête SQL.

```ruby
class Parts < ApplicationRecord
  has_and_belongs_to_many :assemblies, -> { group "factory" }
end
```

##### `includes`

Vous pouvez utiliser la méthode `includes` pour spécifier les associations de second ordre qui doivent être chargées en avance lorsque cette association est utilisée.

##### `limit`

La méthode `limit` vous permet de restreindre le nombre total d'objets qui seront récupérés via une association.

```ruby
class Parts < ApplicationRecord
  has_and_belongs_to_many :assemblies,
    -> { order("created_at DESC").limit(50) }
end
```

##### `offset`

La méthode `offset` vous permet de spécifier le décalage de départ pour récupérer les objets via une association. Par exemple, si vous définissez `offset(11)`, cela sautera les 11 premiers enregistrements.

##### `order`

La méthode `order` dicte l'ordre dans lequel les objets associés seront reçus (dans la syntaxe utilisée par une clause SQL `ORDER BY`).

```ruby
class Parts < ApplicationRecord
  has_and_belongs_to_many :assemblies,
    -> { order "assembly_name ASC" }
end
```

##### `readonly`

Si vous utilisez la méthode `readonly`, alors les objets associés seront en lecture seule lorsqu'ils sont récupérés via l'association.

##### `select`

La méthode `select` vous permet de remplacer la clause SQL `SELECT` utilisée pour récupérer les données sur les objets associés. Par défaut, Rails récupère toutes les colonnes.

##### `distinct`

Utilisez la méthode `distinct` pour supprimer les doublons de la collection.

#### Quand les objets sont-ils enregistrés ?

Lorsque vous assignez un objet à une association `has_and_belongs_to_many`, cet objet est automatiquement enregistré (afin de mettre à jour la table de jointure). Si vous assignez plusieurs objets en une seule instruction, ils sont tous enregistrés.

Si l'un de ces enregistrements échoue en raison d'erreurs de validation, alors l'instruction d'assignation renvoie `false` et l'assignation elle-même est annulée.

Si l'objet parent (celui qui déclare l'association `has_and_belongs_to_many`) n'est pas enregistré (c'est-à-dire que `new_record?` renvoie `true`), alors les objets enfants ne sont pas enregistrés lorsqu'ils sont ajoutés. Tous les membres non enregistrés de l'association seront automatiquement enregistrés lorsque le parent est enregistré.

Si vous souhaitez assigner un objet à une association `has_and_belongs_to_many` sans enregistrer l'objet, utilisez la méthode `collection.build`.

### Callbacks d'association

Les callbacks normaux se connectent au cycle de vie des objets Active Record, vous permettant de travailler avec ces objets à différents moments. Par exemple, vous pouvez utiliser un callback `:before_save` pour provoquer quelque chose qui se produit juste avant qu'un objet soit enregistré.

Les callbacks d'association sont similaires aux callbacks normaux, mais ils sont déclenchés par des événements dans le cycle de vie d'une collection. Il existe quatre callbacks d'association disponibles :

* `before_add`
* `after_add`
* `before_remove`
* `after_remove`

Vous définissez les callbacks d'association en ajoutant des options à la déclaration de l'association. Par exemple :

```ruby
class Author < ApplicationRecord
  has_many :books, before_add: :check_credit_limit

  def check_credit_limit(book)
    # ...
  end
end
```

Rails passe l'objet ajouté ou supprimé au callback.
Vous pouvez empiler des rappels sur un seul événement en les passant sous forme de tableau :

```ruby
class Author < ApplicationRecord
  has_many :books,
    before_add: [:check_credit_limit, :calculate_shipping_charges]

  def check_credit_limit(book)
    # ...
  end

  def calculate_shipping_charges(book)
    # ...
  end
end
```

Si un rappel `before_add` lance `:abort`, l'objet n'est pas ajouté à la collection. De même, si un rappel `before_remove` lance `:abort`, l'objet n'est pas supprimé de la collection :

```ruby
# Le livre ne sera pas ajouté si la limite est atteinte
def check_credit_limit(book)
  throw(:abort) if limit_reached?
end
```

REMARQUE : Ces rappels sont appelés uniquement lorsque les objets associés sont ajoutés ou supprimés via la collection d'association :

```ruby
# Déclenche le rappel `before_add`
author.books << book
author.books = [book, book2]

# Ne déclenche pas le rappel `before_add`
book.update(author_id: 1)
```

### Extensions d'association

Vous n'êtes pas limité à la fonctionnalité que Rails construit automatiquement dans les objets proxy d'association. Vous pouvez également étendre ces objets à l'aide de modules anonymes, en ajoutant de nouveaux finders, créateurs ou autres méthodes. Par exemple :

```ruby
class Author < ApplicationRecord
  has_many :books do
    def find_by_book_prefix(book_number)
      find_by(category_id: book_number[0..2])
    end
  end
end
```

Si vous avez une extension qui doit être partagée par de nombreuses associations, vous pouvez utiliser un module d'extension nommé. Par exemple :

```ruby
module FindRecentExtension
  def find_recent
    where("created_at > ?", 5.days.ago)
  end
end

class Author < ApplicationRecord
  has_many :books, -> { extending FindRecentExtension }
end

class Supplier < ApplicationRecord
  has_many :deliveries, -> { extending FindRecentExtension }
end
```

Les extensions peuvent faire référence aux éléments internes du proxy d'association en utilisant ces trois attributs de l'accesseur `proxy_association` :

* `proxy_association.owner` renvoie l'objet dont l'association fait partie.
* `proxy_association.reflection` renvoie l'objet de réflexion qui décrit l'association.
* `proxy_association.target` renvoie l'objet associé pour `belongs_to` ou `has_one`, ou la collection d'objets associés pour `has_many` ou `has_and_belongs_to_many`.

### Délimitation de l'association en utilisant le propriétaire de l'association

Le propriétaire de l'association peut être passé en tant qu'argument unique au bloc de portée dans les situations où vous avez besoin d'un contrôle encore plus précis sur la portée de l'association. Cependant, en contrepartie, le préchargement de l'association ne sera plus possible.

```ruby
class Supplier < ApplicationRecord
  has_one :account, ->(supplier) { where active: supplier.active? }
end
```

Héritage de table unique (STI)
------------------------------

Parfois, vous souhaiterez partager des champs et des comportements entre différents modèles. Disons que nous avons les modèles Car, Motorcycle et Bicycle. Nous voulons partager les champs `color` et `price` et certaines méthodes pour tous, mais avoir un comportement spécifique pour chacun, et des contrôleurs séparés également.

Tout d'abord, générons le modèle de base Vehicle :

```bash
$ bin/rails generate model vehicle type:string color:string price:decimal{10.2}
```

Avez-vous remarqué que nous ajoutons un champ "type" ? Étant donné que tous les modèles seront enregistrés dans une seule table de base de données, Rails enregistrera dans cette colonne le nom du modèle qui est enregistré. Dans notre exemple, cela peut être "Car", "Motorcycle" ou "Bicycle". L'ITI ne fonctionnera pas sans un champ "type" dans la table.

Ensuite, nous allons générer le modèle Car qui hérite de Vehicle. Pour cela, nous pouvons utiliser l'option `--parent=PARENT`, qui générera un modèle qui hérite du parent spécifié et sans migration équivalente (puisque la table existe déjà).

Par exemple, pour générer le modèle Car :

```bash
$ bin/rails generate model car --parent=Vehicle
```

Le modèle généré ressemblera à ceci :

```ruby
class Car < Vehicle
end
```

Cela signifie que tous les comportements ajoutés à Vehicle sont également disponibles pour Car, comme les associations, les méthodes publiques, etc.

La création d'une voiture l'enregistrera dans la table "vehicles" avec "Car" comme champ "type" :

```ruby
Car.create(color: 'Red', price: 10000)
```

générera le SQL suivant :

```sql
INSERT INTO "vehicles" ("type", "color", "price") VALUES ('Car', 'Red', 10000)
```

La recherche des enregistrements de voiture ne recherchera que les véhicules qui sont des voitures :

```ruby
Car.all
```

exécutera une requête comme :

```sql
SELECT "vehicles".* FROM "vehicles" WHERE "vehicles"."type" IN ('Car')
```

Types délégués
----------------

L'approche de l'`héritage de table unique (STI)` fonctionne mieux lorsqu'il y a peu de différence entre les sous-classes et leurs attributs, mais inclut tous les attributs de toutes les sous-classes dont vous avez besoin pour créer une seule table.

L'inconvénient de cette approche est qu'elle entraîne un gonflement de cette table. En effet, elle inclura même des attributs spécifiques à une sous-classe qui ne sont utilisés par rien d'autre.

Dans l'exemple suivant, il y a deux modèles Active Record qui héritent de la même classe "Entry" qui inclut l'attribut `subject`.
```ruby
# Schéma: entries[ id, type, subject, created_at, updated_at]
class Entry < ApplicationRecord
end

class Comment < Entry
end

class Message < Entry
end
```

Les types délégués résolvent ce problème, via `delegated_type`.

Pour utiliser les types délégués, nous devons modéliser nos données d'une manière particulière. Les exigences sont les suivantes :

* Il existe une superclasse qui stocke les attributs partagés entre toutes les sous-classes dans sa table.
* Chaque sous-classe doit hériter de la superclasse et aura une table distincte pour les attributs supplémentaires qui lui sont propres.

Cela élimine la nécessité de définir des attributs dans une seule table qui sont partagés involontairement entre toutes les sous-classes.

Pour appliquer cela à notre exemple ci-dessus, nous devons régénérer nos modèles.
Tout d'abord, générons le modèle de base `Entry` qui servira de superclasse :

```bash
$ bin/rails generate model entry entryable_type:string entryable_id:integer
```

Ensuite, nous allons générer de nouveaux modèles `Message` et `Comment` pour la délégation :

```bash
$ bin/rails generate model message subject:string body:string
$ bin/rails generate model comment content:string
```

Après avoir exécuté les générateurs, nous devrions obtenir des modèles qui ressemblent à ceci :

```ruby
# Schéma: entries[ id, entryable_type, entryable_id, created_at, updated_at ]
class Entry < ApplicationRecord
end

# Schéma: messages[ id, subject, body, created_at, updated_at ]
class Message < ApplicationRecord
end

# Schéma: comments[ id, content, created_at, updated_at ]
class Comment < ApplicationRecord
end
```

### Déclarer `delegated_type`

Tout d'abord, déclarez un `delegated_type` dans la superclasse `Entry`.

```ruby
class Entry < ApplicationRecord
  delegated_type :entryable, types: %w[ Message Comment ], dependent: :destroy
end
```

Le paramètre `entryable` spécifie le champ à utiliser pour la délégation et inclut les types `Message` et `Comment` en tant que classes déléguées.

La classe `Entry` a les champs `entryable_type` et `entryable_id`. Il s'agit du champ avec les suffixes `_type` et `_id` ajoutés au nom `entryable` dans la définition de `delegated_type`.
`entryable_type` stocke le nom de la sous-classe du délégué et `entryable_id` stocke l'identifiant d'enregistrement de la sous-classe du délégué.

Ensuite, nous devons définir un module pour implémenter ces types délégués, en déclarant le paramètre `as: :entryable` à l'association `has_one`.

```ruby
module Entryable
  extend ActiveSupport::Concern

  included do
    has_one :entry, as: :entryable, touch: true
  end
end
```

Et incluez ensuite le module créé dans votre sous-classe.

```ruby
class Message < ApplicationRecord
  include Entryable
end

class Comment < ApplicationRecord
  include Entryable
end
```

Avec cette définition complète, notre délégataire `Entry` fournit maintenant les méthodes suivantes :

| Méthode | Renvoi |
|---|---|
| `Entry#entryable_class` | Message ou Comment |
| `Entry#entryable_name` | "message" ou "comment" |
| `Entry.messages` | `Entry.where(entryable_type: "Message")` |
| `Entry#message?` | Renvoie true lorsque `entryable_type == "Message"` |
| `Entry#message` | Renvoie l'enregistrement du message lorsque `entryable_type == "Message"`, sinon `nil` |
| `Entry#message_id` | Renvoie `entryable_id` lorsque `entryable_type == "Message"`, sinon `nil` |
| `Entry.comments` | `Entry.where(entryable_type: "Comment")` |
| `Entry#comment?` | Renvoie true lorsque `entryable_type == "Comment"` |
| `Entry#comment` | Renvoie l'enregistrement du commentaire lorsque `entryable_type == "Comment"`, sinon `nil` |
| `Entry#comment_id` | Renvoie `entryable_id` lorsque `entryable_type == "Comment"`, sinon `nil` |

### Création d'objet

Lors de la création d'un nouvel objet `Entry`, nous pouvons spécifier la sous-classe `entryable` en même temps.

```ruby
Entry.create! entryable: Message.new(subject: "hello!")
```

### Ajout de délégation supplémentaire

Nous pouvons étendre notre délégataire `Entry` et l'améliorer davantage en définissant des `delegates` et en utilisant le polymorphisme pour les sous-classes.
Par exemple, pour déléguer la méthode `title` de `Entry` à ses sous-classes :

```ruby
class Entry < ApplicationRecord
  delegated_type :entryable, types: %w[ Message Comment ]
  delegates :title, to: :entryable
end

class Message < ApplicationRecord
  include Entryable

  def title
    subject
  end
end

class Comment < ApplicationRecord
  include Entryable

  def title
    content.truncate(20)
  end
end
```
[`belongs_to`]: https://api.rubyonrails.org/classes/ActiveRecord/Associations/ClassMethods.html#method-i-belongs_to
[`has_and_belongs_to_many`]: https://api.rubyonrails.org/classes/ActiveRecord/Associations/ClassMethods.html#method-i-has_and_belongs_to_many
[`has_many`]: https://api.rubyonrails.org/classes/ActiveRecord/Associations/ClassMethods.html#method-i-has_many
[`has_one`]: https://api.rubyonrails.org/classes/ActiveRecord/Associations/ClassMethods.html#method-i-has_one
[connection.add_reference]: https://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html#method-i-add_reference
[foreign_keys]: active_record_migrations.html#foreign-keys
[`config.active_record.automatic_scope_inversing`]: configuring.html#config-active-record-automatic-scope-inversing
[`reset_counters`]: https://api.rubyonrails.org/classes/ActiveRecord/CounterCache/ClassMethods.html#method-i-reset_counters
[`collection<<`]: https://api.rubyonrails.org/classes/ActiveRecord/Associations/CollectionProxy.html#method-i-3C-3C
[`collection.build`]: https://api.rubyonrails.org/classes/ActiveRecord/Associations/CollectionProxy.html#method-i-build
[`collection.clear`]: https://api.rubyonrails.org/classes/ActiveRecord/Associations/CollectionProxy.html#method-i-clear
[`collection.create`]: https://api.rubyonrails.org/classes/ActiveRecord/Associations/CollectionProxy.html#method-i-create
[`collection.create!`]: https://api.rubyonrails.org/classes/ActiveRecord/Associations/CollectionProxy.html#method-i-create-21
[`collection.delete`]: https://api.rubyonrails.org/classes/ActiveRecord/Associations/CollectionProxy.html#method-i-delete
[`collection.destroy`]: https://api.rubyonrails.org/classes/ActiveRecord/Associations/CollectionProxy.html#method-i-destroy
[`collection.empty?`]: https://api.rubyonrails.org/classes/ActiveRecord/Associations/CollectionProxy.html#method-i-empty-3F
[`collection.exists?`]: https://api.rubyonrails.org/classes/ActiveRecord/FinderMethods.html#method-i-exists-3F
[`collection.find`]: https://api.rubyonrails.org/classes/ActiveRecord/Associations/CollectionProxy.html#method-i-find
[`collection.reload`]: https://api.rubyonrails.org/classes/ActiveRecord/Associations/CollectionProxy.html#method-i-reload
[`collection.size`]: https://api.rubyonrails.org/classes/ActiveRecord/Associations/CollectionProxy.html#method-i-size
[`collection.where`]: https://api.rubyonrails.org/classes/ActiveRecord/QueryMethods.html#method-i-where
