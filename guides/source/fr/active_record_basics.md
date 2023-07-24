**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: b2cb0ab668ead9e8bd48cbd1bcac9b59
Principes de base d'Active Record
====================

Ce guide est une introduction à Active Record.

Après avoir lu ce guide, vous saurez :

* Ce qu'est l'Object Relational Mapping et Active Record et comment ils sont utilisés dans Rails.
* Comment Active Record s'intègre dans le paradigme Modèle-Vue-Contrôleur.
* Comment utiliser les modèles Active Record pour manipuler les données stockées dans une base de données relationnelle.
* Les conventions de nommage des schémas Active Record.
* Les concepts de migrations de base de données, de validations, de rappels et d'associations.

--------------------------------------------------------------------------------

Qu'est-ce qu'Active Record ?
----------------------

Active Record est le M dans [MVC][] - le modèle - qui est la couche du système responsable de la représentation des données et de la logique métier. Active Record facilite la création et l'utilisation d'objets métier dont les données nécessitent un stockage persistant dans une base de données. Il s'agit d'une implémentation du modèle Active Record qui est lui-même une description d'un système de mappage objet-relationnel.

### Le modèle Active Record

[Active Record a été décrit par Martin Fowler][MFAR] dans son livre _Patterns of Enterprise Application Architecture_. Dans Active Record, les objets portent à la fois des données persistantes et des comportements qui opèrent sur ces données. Active Record considère que le fait de garantir la logique d'accès aux données en tant que partie de l'objet permettra aux utilisateurs de cet objet d'apprendre comment écrire et lire dans la base de données.

### Mappage objet-relationnel

[Le mappage objet-relationnel][ORM], communément appelé ORM, est une technique qui relie les objets riches d'une application aux tables d'un système de gestion de base de données relationnelle. En utilisant l'ORM, les propriétés et les relations des objets dans une application peuvent être facilement stockées et récupérées à partir d'une base de données sans écrire directement des instructions SQL et avec moins de code d'accès à la base de données dans l'ensemble.

NOTE : Une connaissance de base des systèmes de gestion de base de données relationnelles (SGBDR) et du langage de requête structuré (SQL) est utile pour comprendre pleinement Active Record. Veuillez vous référer à [ce tutoriel][sqlcourse] (ou [celui-ci][rdbmsinfo]) ou les étudier par d'autres moyens si vous souhaitez en savoir plus.

### Active Record en tant que framework ORM

Active Record nous offre plusieurs mécanismes, le plus important étant la capacité de :

* Représenter des modèles et leurs données.
* Représenter les associations entre ces modèles.
* Représenter les hiérarchies d'héritage à travers des modèles liés.
* Valider les modèles avant de les persister dans la base de données.
* Effectuer des opérations de base de données de manière orientée objet.


La convention plutôt que la configuration dans Active Record
----------------------------------------------

Lorsque vous écrivez des applications en utilisant d'autres langages de programmation ou frameworks, il peut être nécessaire d'écrire beaucoup de code de configuration. Cela est particulièrement vrai pour les frameworks ORM en général. Cependant, si vous suivez les conventions adoptées par Rails, vous n'aurez besoin d'écrire que très peu de configuration (dans certains cas, aucune configuration du tout) lors de la création de modèles Active Record. L'idée est que si vous configurez vos applications de la même manière la plupart du temps, cela devrait être la façon par défaut. Ainsi, une configuration explicite ne serait nécessaire que dans les cas où vous ne pouvez pas suivre la convention standard.

### Conventions de nommage

Par défaut, Active Record utilise certaines conventions de nommage pour déterminer comment la correspondance entre les modèles et les tables de la base de données doit être créée. Rails va plurieliser les noms de vos classes pour trouver la table de base de données respective. Ainsi, pour une classe `Book`, vous devriez avoir une table de base de données appelée **books**. Les mécanismes de pluriel de Rails sont très puissants, capables de plurieliser (et de singulieriser) à la fois des mots réguliers et irréguliers. Lorsque vous utilisez des noms de classe composés de deux mots ou plus, le nom de la classe du modèle doit suivre les conventions Ruby, en utilisant la forme CamelCase, tandis que le nom de la table doit utiliser la forme snake_case. Exemples :

* Classe de modèle - Singulier avec la première lettre de chaque mot en majuscule (par exemple, `BookClub`).
* Table de base de données - Pluriel avec des underscores séparant les mots (par exemple, `book_clubs`).

| Modèle / Classe    | Table / Schéma |
| ---------------- | -------------- |
| `Article`        | `articles`     |
| `LineItem`       | `line_items`   |
| `Deer`           | `deers`        |
| `Mouse`          | `mice`         |
| `Person`         | `people`       |

### Conventions de schéma

Active Record utilise des conventions de nommage pour les colonnes des tables de base de données, en fonction de l'objectif de ces colonnes.

* **Clés étrangères** - Ces champs doivent être nommés en suivant le modèle `nom_table_au_singulier_id` (par exemple, `item_id`, `order_id`). Ce sont les champs que Active Record recherchera lorsque vous créerez des associations entre vos modèles.
* **Clés primaires** - Par défaut, Active Record utilisera une colonne entière nommée `id` comme clé primaire de la table (`bigint` pour PostgreSQL et MySQL, `integer` pour SQLite). Lorsque vous utilisez [Active Record Migrations](active_record_migrations.html) pour créer vos tables, cette colonne sera automatiquement créée.
Il existe également des noms de colonnes facultatifs qui ajoutent des fonctionnalités supplémentaires aux instances Active Record :

* `created_at` - est automatiquement défini sur la date et l'heure actuelles lors de la création initiale de l'enregistrement.
* `updated_at` - est automatiquement défini sur la date et l'heure actuelles lors de la création ou de la mise à jour de l'enregistrement.
* `lock_version` - ajoute un [verrouillage optimiste](https://api.rubyonrails.org/classes/ActiveRecord/Locking.html) à un modèle.
* `type` - spécifie que le modèle utilise [l'héritage de table unique](https://api.rubyonrails.org/classes/ActiveRecord/Base.html#class-ActiveRecord::Base-label-Single+table+inheritance).
* `(nom_association)_type` - stocke le type pour les [associations polymorphes](association_basics.html#polymorphic-associations).
* `(nom_table)_count` - utilisé pour mettre en cache le nombre d'objets appartenant à des associations. Par exemple, une colonne `comments_count` dans une classe `Article` qui a de nombreuses instances de `Comment` mettra en cache le nombre de commentaires existants pour chaque article.

NOTE : Bien que ces noms de colonnes soient facultatifs, ils sont en fait réservés par Active Record. Évitez les mots-clés réservés à moins que vous ne souhaitiez bénéficier de fonctionnalités supplémentaires. Par exemple, `type` est un mot-clé réservé utilisé pour désigner une table utilisant l'héritage de table unique (STI). Si vous n'utilisez pas STI, essayez un mot-clé analogue comme "contexte", qui peut toujours décrire avec précision les données que vous modélisez.

Création de modèles Active Record
---------------------------------

Lors de la génération d'une application, une classe abstraite `ApplicationRecord` sera créée dans `app/models/application_record.rb`. Il s'agit de la classe de base pour tous les modèles d'une application, et c'est ce qui transforme une classe Ruby ordinaire en un modèle Active Record.

Pour créer des modèles Active Record, sous-classez la classe `ApplicationRecord` et vous êtes prêt :

```ruby
class Product < ApplicationRecord
end
```

Cela créera un modèle `Product`, associé à une table `products` dans la base de données. En faisant cela, vous aurez également la possibilité de mapper les colonnes de chaque ligne de cette table avec les attributs des instances de votre modèle. Supposons que la table `products` ait été créée à l'aide d'une instruction SQL (ou l'une de ses extensions) comme :

```sql
CREATE TABLE products (
  id int(11) NOT NULL auto_increment,
  name varchar(255),
  PRIMARY KEY  (id)
);
```

Le schéma ci-dessus déclare une table avec deux colonnes : `id` et `name`. Chaque ligne de cette table représente un certain produit avec ces deux paramètres. Ainsi, vous seriez en mesure d'écrire du code comme suit :

```ruby
p = Product.new
p.name = "Some Book"
puts p.name # "Some Book"
```

Remplacement des conventions de dénomination
--------------------------------------------

Que faire si vous devez suivre une convention de dénomination différente ou si vous devez utiliser votre application Rails avec une base de données existante ? Pas de problème, vous pouvez facilement remplacer les conventions par défaut.

Étant donné que `ApplicationRecord` hérite de `ActiveRecord::Base`, les modèles de votre application auront plusieurs méthodes utiles à leur disposition. Par exemple, vous pouvez utiliser la méthode `ActiveRecord::Base.table_name=` pour personnaliser le nom de la table à utiliser :

```ruby
class Product < ApplicationRecord
  self.table_name = "my_products"
end
```

Si vous le faites, vous devrez définir manuellement le nom de la classe qui héberge les fixtures (`my_products.yml`) en utilisant la méthode `set_fixture_class` dans votre définition de test :

```ruby
# test/models/product_test.rb
class ProductTest < ActiveSupport::TestCase
  set_fixture_class my_products: Product
  fixtures :my_products
  # ...
end
```

Il est également possible de remplacer la colonne qui doit être utilisée comme clé primaire de la table en utilisant la méthode `ActiveRecord::Base.primary_key=` :

```ruby
class Product < ApplicationRecord
  self.primary_key = "product_id"
end
```

NOTE : **Active Record ne prend pas en charge l'utilisation de colonnes de clé primaire non nommées `id`.**

NOTE : Si vous essayez de créer une colonne nommée `id` qui n'est pas la clé primaire, Rails générera une erreur lors des migrations, par exemple : `vous ne pouvez pas redéfinir la colonne de clé primaire 'id' sur 'my_products'.` `Pour définir une clé primaire personnalisée, passez { id: false } à create_table.`

CRUD : Lecture et écriture de données
-------------------------------------

CRUD est un acronyme pour les quatre verbes que nous utilisons pour manipuler des données : **C**réer, **L**ire, **M**ettre à jour et **S**upprimer. Active Record crée automatiquement des méthodes pour permettre à une application de lire et de manipuler les données stockées dans ses tables.

### Créer

Les objets Active Record peuvent être créés à partir d'un hash, d'un bloc ou leurs attributs peuvent être définis manuellement après la création. La méthode `new` renverra un nouvel objet tandis que `create` renverra l'objet et l'enregistrera dans la base de données.

Par exemple, étant donné un modèle `User` avec les attributs `name` et `occupation`, l'appel de la méthode `create` créera et enregistrera un nouvel enregistrement dans la base de données :

```ruby
user = User.create(name: "David", occupation: "Code Artist")
```
À l'aide de la méthode `new`, un objet peut être instancié sans être enregistré :

```ruby
user = User.new
user.name = "David"
user.occupation = "Code Artist"
```

Un appel à `user.save` enregistrera l'enregistrement dans la base de données.

Enfin, si un bloc est fourni, à la fois `create` et `new` renverront le nouvel objet à ce bloc pour l'initialisation, tandis que seul `create` persistera l'objet résultant dans la base de données :

```ruby
user = User.new do |u|
  u.name = "David"
  u.occupation = "Code Artist"
end
```

### Lecture

Active Record fournit une API riche pour accéder aux données d'une base de données. Voici quelques exemples de différentes méthodes d'accès aux données fournies par Active Record.

```ruby
# retourne une collection avec tous les utilisateurs
users = User.all
```

```ruby
# retourne le premier utilisateur
user = User.first
```

```ruby
# retourne le premier utilisateur nommé David
david = User.find_by(name: 'David')
```

```ruby
# trouve tous les utilisateurs nommés David qui sont des artistes du code et les trie par created_at dans l'ordre chronologique inverse
users = User.where(name: 'David', occupation: 'Code Artist').order(created_at: :desc)
```

Vous pouvez en savoir plus sur la requête d'un modèle Active Record dans le guide [Interface de requête Active Record](active_record_querying.html).

### Mise à jour

Une fois qu'un objet Active Record a été récupéré, ses attributs peuvent être modifiés et il peut être enregistré dans la base de données.

```ruby
user = User.find_by(name: 'David')
user.name = 'Dave'
user.save
```

Une façon plus concise de faire cela est d'utiliser un hachage qui fait correspondre les noms d'attributs à la valeur souhaitée, comme ceci :

```ruby
user = User.find_by(name: 'David')
user.update(name: 'Dave')
```

Cela est particulièrement utile lors de la mise à jour de plusieurs attributs à la fois.

Si vous souhaitez mettre à jour plusieurs enregistrements en vrac **sans rappels ni validations**, vous pouvez mettre à jour la base de données directement en utilisant `update_all` :

```ruby
User.update_all max_login_attempts: 3, must_change_password: true
```

### Suppression

De même, une fois récupéré, un objet Active Record peut être détruit, ce qui le supprime de la base de données.

```ruby
user = User.find_by(name: 'David')
user.destroy
```

Si vous souhaitez supprimer plusieurs enregistrements en vrac, vous pouvez utiliser la méthode `destroy_by` ou `destroy_all` :

```ruby
# trouve et supprime tous les utilisateurs nommés David
User.destroy_by(name: 'David')

# supprime tous les utilisateurs
User.destroy_all
```

Validations
-----------

Active Record vous permet de valider l'état d'un modèle avant qu'il ne soit écrit dans la base de données. Il existe plusieurs méthodes que vous pouvez utiliser pour vérifier vos modèles et valider qu'une valeur d'attribut n'est pas vide, est unique et n'est pas déjà dans la base de données, suit un format spécifique, et bien d'autres encore.

Les méthodes telles que `save`, `create` et `update` valident un modèle avant de le persister dans la base de données. Lorsqu'un modèle est invalide, ces méthodes renvoient `false` et aucune opération de base de données n'est effectuée. Toutes ces méthodes ont une contrepartie avec un point d'exclamation (c'est-à-dire `save!`, `create!` et `update!`), qui sont plus strictes car elles lèvent une exception `ActiveRecord::RecordInvalid` en cas d'échec de la validation.
Un exemple rapide pour illustrer :

```ruby
class User < ApplicationRecord
  validates :name, presence: true
end
```

```irb
irb> user = User.new
irb> user.save
=> false
irb> user.save!
ActiveRecord::RecordInvalid: Validation failed: Name can’t be blank
```

Vous pouvez en savoir plus sur les validations dans le guide [Validations Active Record](active_record_validations.html).

Callbacks
---------

Les callbacks Active Record vous permettent d'attacher du code à certains événements du cycle de vie de vos modèles. Cela vous permet d'ajouter un comportement à vos modèles en exécutant de manière transparente du code lorsque ces événements se produisent, par exemple lorsque vous créez un nouvel enregistrement, le mettez à jour, le supprimez, etc.

```ruby
class User < ApplicationRecord
  after_create :log_new_user

  private
    def log_new_user
      puts "Un nouvel utilisateur a été enregistré"
    end
end
```

```irb
irb> @user = User.create
Un nouvel utilisateur a été enregistré
```

Vous pouvez en savoir plus sur les callbacks dans le guide [Callbacks Active Record](active_record_callbacks.html).

Migrations
----------

Rails offre un moyen pratique de gérer les modifications d'un schéma de base de données via les migrations. Les migrations sont écrites dans un langage spécifique au domaine et stockées dans des fichiers qui sont exécutés sur n'importe quelle base de données prise en charge par Active Record.

Voici une migration qui crée une nouvelle table appelée `publications` :

```ruby
class CreatePublications < ActiveRecord::Migration[7.1]
  def change
    create_table :publications do |t|
      t.string :title
      t.text :description
      t.references :publication_type
      t.references :publisher, polymorphic: true
      t.boolean :single_issue

      t.timestamps
    end
  end
end
```

Notez que le code ci-dessus est indépendant de la base de données : il fonctionnera avec MySQL, PostgreSQL, SQLite et autres.

Rails garde une trace des migrations qui ont été validées dans la base de données et les stocke dans une table voisine de cette même base de données appelée `schema_migrations`.
Pour exécuter la migration et créer la table, vous devez exécuter `bin/rails db:migrate`,
et pour revenir en arrière et supprimer la table, `bin/rails db:rollback`.

Vous pouvez en savoir plus sur les migrations dans le [guide des migrations Active Record](active_record_migrations.html).

Associations
------------

Les associations Active Record vous permettent de définir des relations entre les modèles.
Les associations peuvent être utilisées pour décrire des relations un-à-un, un-à-plusieurs et plusieurs-à-plusieurs.
Par exemple, une relation comme "Un auteur a plusieurs livres" peut être définie comme suit :

```ruby
class Author < ApplicationRecord
  has_many :books
end
```

La classe Author dispose maintenant de méthodes pour ajouter et supprimer des livres à un auteur, et bien plus encore.

Vous pouvez en savoir plus sur les associations dans le [guide des associations Active Record](association_basics.html).
[MVC]: https://en.wikipedia.org/wiki/Model%E2%80%93view%E2%80%93controller
[MFAR]: https://www.martinfowler.com/eaaCatalog/activeRecord.html
[ORM]: https://en.wikipedia.org/wiki/Object-relational_mapping
[sqlcourse]: https://www.khanacademy.org/computing/computer-programming/sql
[rdbmsinfo]: https://www.devart.com/what-is-rdbms/
