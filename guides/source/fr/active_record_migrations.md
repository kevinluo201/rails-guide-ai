**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 311d5225fa32d069369256501f31c507
Migrations Active Record
========================

Les migrations sont une fonctionnalité d'Active Record qui vous permet de faire évoluer votre schéma de base de données au fil du temps. Au lieu d'écrire des modifications de schéma en SQL pur, les migrations vous permettent d'utiliser un DSL Ruby pour décrire les changements apportés à vos tables.

Après avoir lu ce guide, vous saurez :

* Les générateurs que vous pouvez utiliser pour les créer.
* Les méthodes fournies par Active Record pour manipuler votre base de données.
* Les commandes Rails qui manipulent les migrations et votre schéma.
* Comment les migrations sont liées à `schema.rb`.

Aperçu des migrations
---------------------

Les migrations sont un moyen pratique de modifier votre schéma de base de données au fil du temps de manière cohérente. Elles utilisent un DSL Ruby pour que vous n'ayez pas à écrire de SQL à la main, ce qui permet à votre schéma et à vos modifications d'être indépendants de la base de données.

Vous pouvez considérer chaque migration comme une nouvelle "version" de la base de données. Un schéma commence sans rien, et chaque migration le modifie pour ajouter ou supprimer des tables, des colonnes ou des entrées. Active Record sait comment mettre à jour votre schéma le long de cette chronologie, le faisant passer du point où il se trouve dans l'historique à la dernière version. Active Record mettra également à jour votre fichier `db/schema.rb` pour correspondre à la structure à jour de votre base de données.

Voici un exemple de migration :

```ruby
class CreateProducts < ActiveRecord::Migration[7.1]
  def change
    create_table :products do |t|
      t.string :name
      t.text :description

      t.timestamps
    end
  end
end
```

Cette migration ajoute une table appelée `products` avec une colonne de type chaîne de caractères appelée `name` et une colonne de type texte appelée `description`. Une colonne de clé primaire appelée `id` sera également ajoutée implicitement, car c'est la clé primaire par défaut pour tous les modèles Active Record. La macro `timestamps` ajoute deux colonnes, `created_at` et `updated_at`. Ces colonnes spéciales sont automatiquement gérées par Active Record si elles existent.

Notez que nous définissons le changement que nous voulons voir se produire dans le futur. Avant l'exécution de cette migration, il n'y aura pas de table. Après, la table existera. Active Record sait également inverser cette migration : si nous annulons cette migration, la table sera supprimée.

Sur les bases de données qui prennent en charge les transactions avec des instructions qui modifient le schéma, chaque migration est enveloppée dans une transaction. Si la base de données ne prend pas en charge cela, lorsque la migration échoue, les parties qui ont réussi ne seront pas annulées. Vous devrez annuler manuellement les modifications qui ont été apportées.

NOTE : Il existe certaines requêtes qui ne peuvent pas être exécutées dans une transaction. Si votre adaptateur prend en charge les transactions DDL, vous pouvez utiliser `disable_ddl_transaction!` pour les désactiver pour une seule migration.

### Rendre l'irréversible possible

Si vous souhaitez qu'une migration fasse quelque chose qu'Active Record ne sait pas comment inverser, vous pouvez utiliser `reversible` :

```ruby
class ChangeProductsPrice < ActiveRecord::Migration[7.1]
  def change
    reversible do |direction|
      change_table :products do |t|
        direction.up   { t.change :price, :string }
        direction.down { t.change :price, :integer }
      end
    end
  end
end
```

Cette migration modifiera le type de la colonne `price` en une chaîne de caractères, ou en un entier lorsque la migration est annulée. Remarquez le bloc passé à `direction.up` et `direction.down` respectivement.

Alternativement, vous pouvez utiliser `up` et `down` à la place de `change` :

```ruby
class ChangeProductsPrice < ActiveRecord::Migration[7.1]
  def up
    change_table :products do |t|
      t.change :price, :string
    end
  end

  def down
    change_table :products do |t|
      t.change :price, :integer
    end
  end
end
```

INFO : Plus d'informations sur [`reversible`](#using-reversible) plus tard.

Générer des migrations
----------------------

### Créer une migration autonome

Les migrations sont stockées sous forme de fichiers dans le répertoire `db/migrate`, un pour chaque classe de migration. Le nom du fichier est de la forme `YYYYMMDDHHMMSS_create_products.rb`, c'est-à-dire un horodatage UTC identifiant la migration suivi d'un trait de soulignement suivi du nom de la migration. Le nom de la classe de migration (version CamelCase) doit correspondre à la dernière partie du nom du fichier. Par exemple, `20080906120000_create_products.rb` doit définir la classe `CreateProducts` et `20080906120001_add_details_to_products.rb` doit définir `AddDetailsToProducts`. Rails utilise cet horodatage pour déterminer quelle migration doit être exécutée et dans quel ordre, donc si vous copiez une migration depuis une autre application ou générez un fichier vous-même, soyez conscient de sa position dans l'ordre.

Bien sûr, calculer des horodatages n'est pas amusant, donc Active Record fournit un générateur pour le faire à votre place :

```bash
$ bin/rails generate migration AddPartNumberToProducts
```
Cela créera une migration vide avec un nom approprié :

```ruby
class AddPartNumberToProducts < ActiveRecord::Migration[7.1]
  def change
  end
end
```

Ce générateur peut faire beaucoup plus que préfixer un horodatage au nom du fichier.
En fonction des conventions de nommage et des arguments supplémentaires (facultatifs), il peut également commencer à élaborer la migration.

### Ajout de nouvelles colonnes

Si le nom de la migration est de la forme "AddColumnToTable" ou "RemoveColumnFromTable" et est suivi d'une liste de noms de colonnes et de types, alors une migration contenant les instructions [`add_column`][] et [`remove_column`][] appropriées sera créée.

```bash
$ bin/rails generate migration AddPartNumberToProducts part_number:string
```

Cela générera la migration suivante :

```ruby
class AddPartNumberToProducts < ActiveRecord::Migration[7.1]
  def change
    add_column :products, :part_number, :string
  end
end
```

Si vous souhaitez ajouter un index sur la nouvelle colonne, vous pouvez également le faire.

```bash
$ bin/rails generate migration AddPartNumberToProducts part_number:string:index
```

Cela générera les instructions [`add_column`][] et [`add_index`][] appropriées :

```ruby
class AddPartNumberToProducts < ActiveRecord::Migration[7.1]
  def change
    add_column :products, :part_number, :string
    add_index :products, :part_number
  end
end
```

Vous n'êtes **pas** limité à une seule colonne générée automatiquement. Par exemple :

```bash
$ bin/rails generate migration AddDetailsToProducts part_number:string price:decimal
```

Générera une migration de schéma qui ajoute deux colonnes supplémentaires à la table `products`.

```ruby
class AddDetailsToProducts < ActiveRecord::Migration[7.1]
  def change
    add_column :products, :part_number, :string
    add_column :products, :price, :decimal
  end
end
```

### Suppression de colonnes

De même, vous pouvez générer une migration pour supprimer une colonne à partir de la ligne de commande :

```bash
$ bin/rails generate migration RemovePartNumberFromProducts part_number:string
```

Cela génère les instructions [`remove_column`][] appropriées :

```ruby
class RemovePartNumberFromProducts < ActiveRecord::Migration[7.1]
  def change
    remove_column :products, :part_number, :string
  end
end
```

### Création de nouvelles tables

Si le nom de la migration est de la forme "CreateXXX" et est suivi d'une liste de noms de colonnes et de types, alors une migration créant la table XXX avec les colonnes répertoriées sera générée. Par exemple :

```bash
$ bin/rails generate migration CreateProducts name:string part_number:string
```

génère

```ruby
class CreateProducts < ActiveRecord::Migration[7.1]
  def change
    create_table :products do |t|
      t.string :name
      t.string :part_number

      t.timestamps
    end
  end
end
```

Comme toujours, ce qui a été généré pour vous n'est qu'un point de départ.
Vous pouvez y ajouter ou en supprimer selon vos besoins en modifiant le fichier `db/migrate/YYYYMMDDHHMMSS_add_details_to_products.rb`.

### Création d'associations en utilisant des références

De plus, le générateur accepte le type de colonne `references` (également disponible en tant que `belongs_to`). Par exemple,

```bash
$ bin/rails generate migration AddUserRefToProducts user:references
```

génère l'appel [`add_reference`][] suivant :

```ruby
class AddUserRefToProducts < ActiveRecord::Migration[7.1]
  def change
    add_reference :products, :user, foreign_key: true
  end
end
```

Cette migration créera une colonne `user_id`. Les [références](#references) sont un raccourci pour créer des colonnes, des index, des clés étrangères, voire des colonnes d'association polymorphique.

Il existe également un générateur qui produira des tables de jointure si `JoinTable` fait partie du nom :

```bash
$ bin/rails generate migration CreateJoinTableCustomerProduct customer product
```

produira la migration suivante :

```ruby
class CreateJoinTableCustomerProduct < ActiveRecord::Migration[7.1]
  def change
    create_join_table :customers, :products do |t|
      # t.index [:customer_id, :product_id]
      # t.index [:product_id, :customer_id]
    end
  end
end
```


### Générateurs de modèles

Les générateurs de modèle, de ressource et de scaffold créeront des migrations appropriées pour ajouter un nouveau modèle. Cette migration contiendra déjà des instructions pour créer la table correspondante. Si vous indiquez à Rails les colonnes que vous souhaitez, des instructions pour ajouter ces colonnes seront également créées. Par exemple, en exécutant :

```bash
$ bin/rails generate model Product name:string description:text
```

Cela créera une migration qui ressemble à ceci :

```ruby
class CreateProducts < ActiveRecord::Migration[7.1]
  def change
    create_table :products do |t|
      t.string :name
      t.text :description

      t.timestamps
    end
  end
end
```

Vous pouvez ajouter autant de paires nom de colonne/type que vous le souhaitez.

### Passage de modificateurs

Certains [modificateurs de type](#column-modifiers) couramment utilisés peuvent être passés directement en ligne de commande. Ils sont encadrés par des accolades et suivent le type de champ :

Par exemple, en exécutant :

```bash
$ bin/rails generate migration AddDetailsToProducts 'price:decimal{5,2}' supplier:references{polymorphic}
```

produira une migration qui ressemble à ceci

```ruby
class AddDetailsToProducts < ActiveRecord::Migration[7.1]
  def change
    add_column :products, :price, :decimal, precision: 5, scale: 2
    add_reference :products, :supplier, polymorphic: true
  end
end
```

CONSEIL : Consultez la sortie d'aide des générateurs (`bin/rails generate --help`)
pour plus de détails.

Écriture des migrations
------------------

Une fois que vous avez créé votre migration à l'aide d'un des générateurs, il est temps de vous mettre au travail !

### Création d'une table

La méthode [`create_table`][] est l'une des plus fondamentales, mais la plupart du temps,
elle sera générée pour vous en utilisant un générateur de modèle, de ressource ou de scaffold. Une utilisation typique serait
```ruby
create_table :products do |t|
  t.string :name
end
```

Cette méthode crée une table `products` avec une colonne appelée `name`.

Par défaut, `create_table` créera implicitement une clé primaire appelée `id` pour vous. Vous pouvez changer le nom de la colonne avec l'option `:primary_key`, ou si vous ne voulez pas de clé primaire du tout, vous pouvez passer l'option `id: false`.

Si vous avez besoin de passer des options spécifiques à la base de données, vous pouvez placer un fragment SQL dans l'option `:options`. Par exemple :

```ruby
create_table :products, options: "ENGINE=BLACKHOLE" do |t|
  t.string :name, null: false
end
```

Cela ajoutera `ENGINE=BLACKHOLE` à l'instruction SQL utilisée pour créer la table.

Un index peut être créé sur les colonnes créées dans le bloc `create_table` en passant `index: true` ou un hachage d'options à l'option `:index` :

```ruby
create_table :users do |t|
  t.string :name, index: true
  t.string :email, index: { unique: true, name: 'unique_emails' }
end
```

Vous pouvez également passer l'option `:comment` avec une description pour la table qui sera stockée dans la base de données elle-même et peut être consultée avec des outils d'administration de base de données, tels que MySQL Workbench ou PgAdmin III. Il est fortement recommandé de spécifier des commentaires dans les migrations pour les applications avec de grandes bases de données car cela aide les gens à comprendre le modèle de données et à générer de la documentation. Actuellement, seuls les adaptateurs MySQL et PostgreSQL prennent en charge les commentaires.


### Création d'une table de jointure

La méthode de migration [`create_join_table`][] crée une table de jointure HABTM (a et appartient à plusieurs). Une utilisation typique serait :

```ruby
create_join_table :products, :categories
```

Cette migration créera une table `categories_products` avec deux colonnes appelées `category_id` et `product_id`.

Ces colonnes ont l'option `:null` définie sur `false` par défaut, ce qui signifie que vous **devez** fournir une valeur pour enregistrer un enregistrement dans cette table. Cela peut être annulé en spécifiant l'option `:column_options` :

```ruby
create_join_table :products, :categories, column_options: { null: true }
```

Par défaut, le nom de la table de jointure provient de l'union des deux premiers arguments fournis à `create_join_table`, dans l'ordre alphabétique.

Pour personnaliser le nom de la table, fournissez l'option `:table_name` :

```ruby
create_join_table :products, :categories, table_name: :categorization
```

Cela garantit que le nom de la table de jointure est `categorization` comme demandé.

De plus, `create_join_table` accepte un bloc, que vous pouvez utiliser pour ajouter des index (qui ne sont pas créés par défaut) ou toute autre colonne supplémentaire de votre choix.

```ruby
create_join_table :products, :categories do |t|
  t.index :product_id
  t.index :category_id
end
```


### Modification de tables

Si vous souhaitez modifier une table existante sur place, utilisez [`change_table`][].

Il est utilisé de manière similaire à `create_table`, mais l'objet renvoyé dans le bloc a accès à un certain nombre de fonctions spéciales, par exemple :

```ruby
change_table :products do |t|
  t.remove :description, :name
  t.string :part_number
  t.index :part_number
  t.rename :upccode, :upc_code
end
```

Cette migration supprimera les colonnes `description` et `name`, créera une nouvelle colonne de type `string` appelée `part_number` et ajoutera un index dessus. Enfin, elle renommera la colonne `upccode` en `upc_code`.


### Modification de colonnes

Similairement aux méthodes `remove_column` et `add_column` que nous avons vues précédemment, Rails fournit également la méthode de migration [`change_column`][].

```ruby
change_column :products, :part_number, :text
```

Cela modifie la colonne `part_number` de la table `products` pour qu'elle soit de type `:text`.

REMARQUE : La commande `change_column` est **irréversible**. Vous devez fournir votre propre migration réversible, comme nous l'avons discuté précédemment.

En plus de `change_column`, les méthodes [`change_column_null`][] et [`change_column_default`][] sont utilisées spécifiquement pour modifier une contrainte de nullité et les valeurs par défaut d'une colonne.

```ruby
change_column_null :products, :name, false
change_column_default :products, :approved, from: true, to: false
```

Cela définit le champ `:name` de la table `products` comme une colonne `NOT NULL` et la valeur par défaut du champ `:approved` de `true` à `false`. Ces deux modifications ne s'appliqueront qu'aux transactions futures, les enregistrements existants ne sont pas concernés.

Lorsque vous définissez la contrainte de nullité sur `true`, cela signifie que la colonne acceptera une valeur nulle, sinon la contrainte `NOT NULL` est appliquée et une valeur doit être passée pour persister l'enregistrement dans la base de données.

REMARQUE : Vous pourriez également écrire la migration `change_column_default` ci-dessus comme `change_column_default :products, :approved, false`, mais contrairement à l'exemple précédent, cela rendrait votre migration irréversible.


### Modificateurs de colonnes

Les modificateurs de colonnes peuvent être appliqués lors de la création ou de la modification d'une colonne :

* `comment`      Ajoute un commentaire pour la colonne.
* `collation`    Spécifie la collation pour une colonne `string` ou `text`.
* `default`      Permet de définir une valeur par défaut sur la colonne. Notez que si vous utilisez une valeur dynamique (comme une date), la valeur par défaut ne sera calculée qu'une seule fois (c'est-à-dire à la date où la migration est appliquée). Utilisez `nil` pour `NULL`.
* `limit`        Définit le nombre maximum de caractères pour une colonne `string` et le nombre maximum d'octets pour les colonnes `text/binary/integer`.
* `null`         Autorise ou interdit les valeurs `NULL` dans la colonne.
* `precision`    Spécifie la précision des colonnes `decimal/numeric/datetime/time`.
* `scale`        Spécifie l'échelle des colonnes `decimal` et `numeric`, représentant le nombre de chiffres après la virgule.
NOTE: Pour `add_column` ou `change_column`, il n'y a pas d'option pour ajouter des index.
Ils doivent être ajoutés séparément en utilisant `add_index`.

Certains adaptateurs peuvent prendre en charge des options supplémentaires ; consultez la documentation spécifique à l'adaptateur pour plus d'informations.

NOTE: `null` et `default` ne peuvent pas être spécifiés via la ligne de commande lors de la génération des migrations.

### Références

La méthode `add_reference` permet de créer une colonne portant un nom approprié
agissant comme la connexion entre une ou plusieurs associations.

```ruby
add_reference :users, :role
```

Cette migration créera une colonne `role_id` dans la table des utilisateurs. Elle crée également un index pour cette colonne, sauf si on lui dit explicitement de ne pas le faire avec l'option `index: false`.

INFO: Voir également le guide [Associations Active Record][] pour en savoir plus.

La méthode `add_belongs_to` est un alias de `add_reference`.

```ruby
add_belongs_to :taggings, :taggable, polymorphic: true
```

L'option polymorphic créera deux colonnes dans la table des taggings qui peuvent
être utilisées pour des associations polymorphiques : `taggable_type` et `taggable_id`.

INFO: Consultez ce guide pour en savoir plus sur les [associations polymorphiques][].

Une clé étrangère peut être créée avec l'option `foreign_key`.

```ruby
add_reference :users, :role, foreign_key: true
```

Pour plus d'options `add_reference`, consultez la [documentation de l'API](https://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html#method-i-add_reference).

Les références peuvent également être supprimées :

```ruby
remove_reference :products, :user, foreign_key: true, index: false
```

[Associations Active Record]: association_basics.html
[associations polymorphiques]: association_basics.html#associations-polymorphiques

### Clés étrangères

Bien que ce ne soit pas obligatoire, vous voudrez peut-être ajouter des contraintes de clé étrangère pour
[garantir l'intégrité référentielle](#active-record-et-integrite-referentielle).

```ruby
add_foreign_key :articles, :authors
```

Cet appel [`add_foreign_key`][] ajoute une nouvelle contrainte à la table `articles`.
La contrainte garantit qu'une ligne existe dans la table `authors` où
la colonne `id` correspond à `articles.author_id`.

Si le nom de la colonne `from_table` ne peut pas être déduit du nom de la table `to_table`,
vous pouvez utiliser l'option `:column`. Utilisez l'option `:primary_key` si la
clé primaire référencée n'est pas `:id`.

Par exemple, pour ajouter une clé étrangère sur `articles.reviewer` faisant référence à `authors.email` :

```ruby
add_foreign_key :articles, :authors, column: :reviewer, primary_key: :email
```

Cela ajoutera une contrainte à la table `articles` qui garantit qu'une ligne existe dans la
table `authors` où la colonne `email` correspond au champ `articles.reviewer`.

Plusieurs autres options telles que `name`, `on_delete`, `if_not_exists`, `validate`,
et `deferrable` sont prises en charge par `add_foreign_key`.

Les clés étrangères peuvent également être supprimées à l'aide de [`remove_foreign_key`][] :

```ruby
# laissez Active Record déterminer le nom de la colonne
remove_foreign_key :accounts, :branches

# supprimez la clé étrangère pour une colonne spécifique
remove_foreign_key :accounts, column: :owner_id
```

NOTE: Active Record ne prend en charge que les clés étrangères à une seule colonne. `execute` et
`structure.sql` sont nécessaires pour utiliser des clés étrangères composites. Voir
[Dumping du schéma et vous](#dumping-du-schema-et-vous).

### Quand les aides ne suffisent pas

Si les aides fournies par Active Record ne suffisent pas, vous pouvez utiliser la méthode [`execute`][]
pour exécuter du SQL arbitraire :

```ruby
Product.connection.execute("UPDATE products SET price = 'free' WHERE 1=1")
```

Pour plus de détails et d'exemples de méthodes individuelles, consultez la documentation de l'API.

En particulier, la documentation pour
[`ActiveRecord::ConnectionAdapters::SchemaStatements`][], qui fournit les méthodes disponibles dans les méthodes `change`, `up` et `down`.

Pour les méthodes disponibles concernant l'objet renvoyé par `create_table`, voir [`ActiveRecord::ConnectionAdapters::TableDefinition`][].

Et pour l'objet renvoyé par `change_table`, voir [`ActiveRecord::ConnectionAdapters::Table`][].


### Utilisation de la méthode `change`

La méthode `change` est la principale façon d'écrire des migrations. Elle fonctionne pour la
majorité des cas où Active Record sait comment inverser automatiquement les actions d'une migration. Voici quelques-unes des actions que `change` prend en charge :

* [`add_check_constraint`][]
* [`add_column`][]
* [`add_foreign_key`][]
* [`add_index`][]
* [`add_reference`][]
* [`add_timestamps`][]
* [`change_column_comment`][] (doit fournir les options `:from` et `:to`)
* [`change_column_default`][] (doit fournir les options `:from` et `:to`)
* [`change_column_null`][]
* [`change_table_comment`][] (doit fournir les options `:from` et `:to`)
* [`create_join_table`][]
* [`create_table`][]
* `disable_extension`
* [`drop_join_table`][]
* [`drop_table`][] (doit fournir un bloc)
* `enable_extension`
* [`remove_check_constraint`][] (doit fournir une expression de contrainte)
* [`remove_column`][] (doit fournir un type)
* [`remove_columns`][] (doit fournir l'option `:type`)
* [`remove_foreign_key`][] (doit fournir une deuxième table)
* [`remove_index`][]
* [`remove_reference`][]
* [`remove_timestamps`][]
* [`rename_column`][]
* [`rename_index`][]
* [`rename_table`][]

[`change_table`][] est également réversible, tant que le bloc n'appelle que
des opérations réversibles comme celles énumérées ci-dessus.

`remove_column` est réversible si vous fournissez le type de colonne en tant que troisième
argument. Fournissez également les options de colonne d'origine, sinon Rails ne peut pas
recréer exactement la colonne lors du retour en arrière :

```ruby
remove_column :posts, :slug, :string, null: false, default: ''
```

Si vous avez besoin d'utiliser d'autres méthodes, vous devriez utiliser `reversible`
ou écrire les méthodes `up` et `down` au lieu d'utiliser la méthode `change`.
### Utilisation de `reversible`

Les migrations complexes peuvent nécessiter un traitement que Active Record ne sait pas comment inverser. Vous pouvez utiliser [`reversible`][] pour spécifier ce qu'il faut faire lors de l'exécution d'une migration et ce qu'il faut faire lors de sa réversion. Par exemple :

```ruby
class ExampleMigration < ActiveRecord::Migration[7.1]
  def change
    create_table :distributors do |t|
      t.string :zipcode
    end

    reversible do |direction|
      direction.up do
        # créer une vue distributeurs
        execute <<-SQL
          CREATE VIEW distributors_view AS
          SELECT id, zipcode
          FROM distributors;
        SQL
      end
      direction.down do
        execute <<-SQL
          DROP VIEW distributors_view;
        SQL
      end
    end

    add_column :users, :home_page_url, :string
    rename_column :users, :email, :email_address
  end
end
```

L'utilisation de `reversible` garantira également que les instructions sont exécutées dans le bon ordre. Si la migration de l'exemple précédent est révoquée, le bloc `down` sera exécuté après la suppression de la colonne `home_page_url` et le renommage de la colonne `email_address`, juste avant la suppression de la table `distributors`.


### Utilisation des méthodes `up`/`down`

Vous pouvez également utiliser l'ancienne méthode de migration en utilisant les méthodes `up` et `down` au lieu de la méthode `change`.

La méthode `up` doit décrire la transformation que vous souhaitez apporter à votre schéma, et la méthode `down` de votre migration doit annuler les transformations effectuées par la méthode `up`. En d'autres termes, le schéma de la base de données ne doit pas être modifié si vous effectuez un `up` suivi d'un `down`.

Par exemple, si vous créez une table dans la méthode `up`, vous devez la supprimer dans la méthode `down`. Il est conseillé d'effectuer les transformations dans l'ordre inverse précisément dans lequel elles ont été effectuées dans la méthode `up`. L'exemple de la section `reversible` est équivalent à :

```ruby
class ExampleMigration < ActiveRecord::Migration[7.1]
  def up
    create_table :distributors do |t|
      t.string :zipcode
    end

    # créer une vue distributeurs
    execute <<-SQL
      CREATE VIEW distributors_view AS
      SELECT id, zipcode
      FROM distributors;
    SQL

    add_column :users, :home_page_url, :string
    rename_column :users, :email, :email_address
  end

  def down
    rename_column :users, :email_address, :email
    remove_column :users, :home_page_url

    execute <<-SQL
      DROP VIEW distributors_view;
    SQL

    drop_table :distributors
  end
end
```

### Lancer une erreur pour empêcher les réversions

Parfois, votre migration fera quelque chose qui est tout simplement irréversible ; par exemple, elle pourrait détruire certaines données.

Dans de tels cas, vous pouvez lever `ActiveRecord::IrreversibleMigration` dans votre bloc `down`.

Si quelqu'un essaie de révoquer votre migration, un message d'erreur s'affichera indiquant que cela ne peut pas être fait.

### Réversion des migrations précédentes

Vous pouvez utiliser la capacité d'Active Record à annuler les migrations en utilisant la méthode [`revert`][] :

```ruby
require_relative "20121212123456_example_migration"

class FixupExampleMigration < ActiveRecord::Migration[7.1]
  def change
    revert ExampleMigration

    create_table(:apples) do |t|
      t.string :variety
    end
  end
end
```

La méthode `revert` accepte également un bloc d'instructions à inverser. Cela peut être utile pour révoquer certaines parties de migrations précédentes.

Par exemple, imaginons que `ExampleMigration` soit validée et qu'il soit ensuite décidé qu'une vue Distributors n'est plus nécessaire.

```ruby
class DontUseDistributorsViewMigration < ActiveRecord::Migration[7.1]
  def change
    revert do
      # code copié-collé depuis ExampleMigration
      reversible do |direction|
        direction.up do
          # créer une vue distributeurs
          execute <<-SQL
            CREATE VIEW distributors_view AS
            SELECT id, zipcode
            FROM distributors;
          SQL
        end
        direction.down do
          execute <<-SQL
            DROP VIEW distributors_view;
          SQL
        end
      end

      # Le reste de la migration était correct
    end
  end
end
```

La même migration aurait également pu être écrite sans utiliser `revert`, mais cela aurait nécessité quelques étapes supplémentaires :

1. Inverser l'ordre de `create_table` et `reversible`.
2. Remplacer `create_table` par `drop_table`.
3. Enfin, remplacer `up` par `down` et vice versa.

Tout cela est pris en charge par `revert`.


Exécution des migrations
------------------

Rails fournit un ensemble de commandes pour exécuter certains ensembles de migrations.

La toute première commande de rails liée aux migrations que vous utiliserez sera probablement `bin/rails db:migrate`. Dans sa forme la plus basique, elle exécute simplement la méthode `change` ou `up` pour toutes les migrations qui n'ont pas encore été exécutées. S'il n'y a pas de telles migrations, elle se termine. Elle exécutera ces migrations dans l'ordre en fonction de la date de la migration.

Notez que l'exécution de la commande `db:migrate` invoque également la commande `db:schema:dump`, qui mettra à jour votre fichier `db/schema.rb` pour qu'il corresponde à la structure de votre base de données.

Si vous spécifiez une version cible, Active Record exécutera les migrations requises (change, up, down) jusqu'à ce qu'elle atteigne la version spécifiée. La version est le préfixe numérique du nom de fichier de la migration. Par exemple, pour migrer vers la version 20080906120000, exécutez :
```bash
$ bin/rails db:migrate VERSION=20080906120000
```

Si la version 20080906120000 est supérieure à la version actuelle (c'est-à-dire qu'elle migre vers le haut), cela exécutera la méthode `change` (ou `up`) sur toutes les migrations jusqu'à et y compris 20080906120000, et n'exécutera aucune migration ultérieure. Si la migration se fait vers le bas, cela exécutera la méthode `down` sur toutes les migrations jusqu'à, mais sans inclure, 20080906120000.

### Annulation

Une tâche courante consiste à annuler la dernière migration. Par exemple, si vous avez commis une erreur et souhaitez la corriger. Au lieu de rechercher le numéro de version associé à la migration précédente, vous pouvez exécuter :

```bash
$ bin/rails db:rollback
```

Cela annulera la dernière migration, soit en inversant la méthode `change`, soit en exécutant la méthode `down`. Si vous devez annuler plusieurs migrations, vous pouvez fournir un paramètre `STEP` :

```bash
$ bin/rails db:rollback STEP=3
```

Les 3 dernières migrations seront annulées.

La commande `db:migrate:redo` est un raccourci pour effectuer une annulation, puis migrer à nouveau vers le haut. Comme avec la commande `db:rollback`, vous pouvez utiliser le paramètre `STEP` si vous devez revenir en arrière de plus d'une version, par exemple :

```bash
$ bin/rails db:migrate:redo STEP=3
```

Aucune de ces commandes Rails ne fait quelque chose que vous ne pourriez pas faire avec `db:migrate`. Elles sont là pour plus de commodité, car vous n'avez pas besoin de spécifier explicitement la version vers laquelle migrer.

### Configuration de la base de données

La commande `bin/rails db:setup` créera la base de données, chargera le schéma et l'initialisera avec les données de base.

### Réinitialisation de la base de données

La commande `bin/rails db:reset` supprimera la base de données et la configurera à nouveau. Cela équivaut fonctionnellement à `bin/rails db:drop db:setup`.

NOTE : Ceci n'est pas la même chose que d'exécuter toutes les migrations. Elle utilisera uniquement le contenu du fichier `db/schema.rb` ou `db/structure.sql` actuel. Si une migration ne peut pas être annulée, `bin/rails db:reset` ne pourra pas vous aider. Pour en savoir plus sur l'export du schéma, consultez la section [Exportation du schéma][].

[Exportation du schéma]: #exportation-du-schéma

### Exécution de migrations spécifiques

Si vous devez exécuter une migration spécifique vers le haut ou vers le bas, les commandes `db:migrate:up` et `db:migrate:down` le feront. Spécifiez simplement la version appropriée et la migration correspondante aura sa méthode `change`, `up` ou `down` invoquée, par exemple :

```bash
$ bin/rails db:migrate:up VERSION=20080906120000
```

En exécutant cette commande, la méthode `change` (ou la méthode `up`) sera exécutée pour la migration avec la version "20080906120000".

Tout d'abord, cette commande vérifiera si la migration existe et si elle a déjà été effectuée, et ne fera rien si c'est le cas.

Si la version spécifiée n'existe pas, Rails lèvera une exception.

```bash
$ bin/rails db:migrate VERSION=zomg
rails aborted!
ActiveRecord::UnknownMigrationVersionError:

Aucune migration avec le numéro de version zomg.
```

### Exécution de migrations dans différents environnements

Par défaut, l'exécution de `bin/rails db:migrate` se fera dans l'environnement `development`.

Pour exécuter des migrations dans un autre environnement, vous pouvez le spécifier en utilisant la variable d'environnement `RAILS_ENV` lors de l'exécution de la commande. Par exemple, pour exécuter des migrations dans l'environnement `test`, vous pouvez exécuter :

```bash
$ bin/rails db:migrate RAILS_ENV=test
```

### Modification de la sortie de l'exécution des migrations

Par défaut, les migrations vous indiquent exactement ce qu'elles font et combien de temps cela a pris. Une migration créant une table et ajoutant un index pourrait produire une sortie comme celle-ci :

```
==  CreateProducts: migrating =================================================
-- create_table(:products)
   -> 0.0028s
==  CreateProducts: migrated (0.0028s) ========================================
```

Plusieurs méthodes sont fournies dans les migrations pour vous permettre de contrôler tout cela :

| Méthode                    | Objectif
| -------------------------- | -------
| [`suppress_messages`][]    | Prend un bloc en argument et supprime toute sortie générée par le bloc.
| [`say`][]                  | Prend un argument de message et le produit tel quel. Un deuxième argument booléen peut être passé pour spécifier s'il faut indenter ou non.
| [`say_with_time`][]        | Produit du texte ainsi que le temps qu'il a fallu pour exécuter son bloc. Si le bloc renvoie un entier, il suppose que c'est le nombre de lignes affectées.

Par exemple, prenez la migration suivante :

```ruby
class CreateProducts < ActiveRecord::Migration[7.1]
  def change
    suppress_messages do
      create_table :products do |t|
        t.string :name
        t.text :description
        t.timestamps
      end
    end

    say "Created a table"

    suppress_messages { add_index :products, :name }
    say "and an index!", true

    say_with_time 'Waiting for a while' do
      sleep 10
      250
    end
  end
end
```

Cela générera la sortie suivante :

```
== CreateProducts: migration =================================================
-- Création d'une table
   -> et un index !
-- Attente pendant un moment
   -> 10.0013s
   -> 250 lignes
== CreateProducts: migration terminée (10.0054s) =======================================
```

Si vous ne voulez pas que Active Record affiche quoi que ce soit, exécuter `bin/rails db:migrate VERBOSE=false` supprimera toute sortie.


Modification des migrations existantes
----------------------------

Il arrive parfois que vous fassiez une erreur lors de l'écriture d'une migration. Si vous avez déjà exécuté la migration, vous ne pouvez pas simplement modifier la migration et exécuter à nouveau la migration : Rails pense qu'il a déjà exécuté la migration et ne fera donc rien lorsque vous exécutez `bin/rails db:migrate`. Vous devez annuler la migration (par exemple avec `bin/rails db:rollback`), modifier votre migration, puis exécuter `bin/rails db:migrate` pour exécuter la version corrigée.

En général, il n'est pas conseillé de modifier les migrations existantes. Vous créerez du travail supplémentaire pour vous-même et vos collègues et vous causera de gros problèmes si la version existante de la migration a déjà été exécutée sur des machines de production.

Au lieu de cela, vous devriez écrire une nouvelle migration qui effectue les modifications dont vous avez besoin. Modifier une migration nouvellement générée qui n'a pas encore été validée par le contrôle de source (ou, plus généralement, qui n'a pas été propagée au-delà de votre machine de développement) est relativement sans danger.

La méthode `revert` peut être utile lors de l'écriture d'une nouvelle migration pour annuler les migrations précédentes en totalité ou en partie (voir [Annulation des migrations précédentes][] ci-dessus).

[Annulation des migrations précédentes]: #annulation-des-migrations-précédentes

Exportation du schéma et vous
----------------------

### À quoi servent les fichiers de schéma ?

Les migrations, aussi puissantes soient-elles, ne sont pas la source d'autorité pour votre schéma de base de données. **Votre base de données reste la source de vérité.**

Par défaut, Rails génère `db/schema.rb` qui tente de capturer l'état actuel de votre schéma de base de données.

Il est généralement plus rapide et moins sujet aux erreurs de créer une nouvelle instance de la base de données de votre application en chargeant le fichier de schéma via `bin/rails db:schema:load` plutôt que de rejouer l'ensemble de l'historique des migrations. Les [anciennes migrations][] peuvent échouer à s'appliquer correctement si ces migrations utilisent des dépendances externes changeantes ou s'appuient sur du code d'application qui évolue séparément de vos migrations.

Les fichiers de schéma sont également utiles si vous souhaitez rapidement consulter les attributs d'un objet Active Record. Ces informations ne se trouvent pas dans le code du modèle et sont souvent réparties dans plusieurs migrations, mais les informations sont bien résumées dans le fichier de schéma.

[Anciennes migrations]: #anciennes-migrations

### Types d'exportation de schéma

Le format de l'exportation de schéma générée par Rails est contrôlé par le paramètre [`config.active_record.schema_format`][] défini dans `config/application.rb`. Par défaut, le format est `:ruby`, ou peut également être défini sur `:sql`.

#### Utilisation du schéma `:ruby` par défaut

Lorsque `:ruby` est sélectionné, le schéma est stocké dans `db/schema.rb`. Si vous regardez ce fichier, vous constaterez qu'il ressemble énormément à une très grande migration :

```ruby
ActiveRecord::Schema[7.1].define(version: 2008_09_06_171750) do
  create_table "authors", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "products", force: true do |t|
    t.string   "name"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "part_number"
  end
end
```

À bien des égards, c'est exactement ce que c'est. Ce fichier est créé en inspectant la base de données et en exprimant sa structure à l'aide de `create_table`, `add_index`, etc.

#### Utilisation de l'exportation de schéma `:sql`

Cependant, `db/schema.rb` ne peut pas exprimer tout ce que votre base de données peut prendre en charge, comme les déclencheurs, les séquences, les procédures stockées, etc.

Bien que les migrations puissent utiliser `execute` pour créer des constructions de base de données qui ne sont pas prises en charge par le DSL de migration Ruby, ces constructions ne peuvent pas toujours être reconstituées par l'exportation de schéma.

Si vous utilisez des fonctionnalités de ce type, vous devez définir le format de schéma sur `:sql` afin d'obtenir un fichier de schéma précis qui est utile pour créer de nouvelles instances de base de données.

Lorsque le format de schéma est défini sur `:sql`, la structure de la base de données sera exportée à l'aide d'un outil spécifique à la base de données dans `db/structure.sql`. Par exemple, pour PostgreSQL, l'utilitaire `pg_dump` est utilisé. Pour MySQL et MariaDB, ce fichier contiendra la sortie de `SHOW CREATE TABLE` pour les différentes tables.

Pour charger le schéma à partir de `db/structure.sql`, exécutez `bin/rails db:schema:load`. Le chargement de ce fichier se fait en exécutant les instructions SQL qu'il contient. Par définition, cela créera une copie parfaite de la structure de la base de données.


### Exportation de schéma et contrôle de source
Étant donné que les fichiers de schéma sont couramment utilisés pour créer de nouvelles bases de données, il est fortement recommandé de les enregistrer dans le contrôle de source.

Des conflits de fusion peuvent survenir dans votre fichier de schéma lorsque deux branches modifient le schéma. Pour résoudre ces conflits, exécutez `bin/rails db:migrate` pour régénérer le fichier de schéma.

INFO : Les nouvelles applications Rails générées auront déjà le dossier de migrations inclus dans l'arborescence git, il vous suffit donc de vous assurer d'ajouter toutes les nouvelles migrations que vous ajoutez et de les valider.

Active Record et intégrité référentielle
---------------------------------------

La méthode Active Record affirme que l'intelligence appartient à vos modèles, et non à la base de données. Par conséquent, les fonctionnalités telles que les déclencheurs ou les contraintes, qui renvoient une partie de cette intelligence à la base de données, ne sont pas recommandées.

Les validations telles que `validates :foreign_key, uniqueness: true` sont un moyen pour les modèles d'assurer l'intégrité des données. L'option `:dependent` sur les associations permet aux modèles de détruire automatiquement les objets enfants lorsque le parent est détruit. Comme tout ce qui fonctionne au niveau de l'application, cela ne peut pas garantir l'intégrité référentielle, c'est pourquoi certaines personnes les complètent avec des [contraintes de clé étrangère][] dans la base de données.

Bien qu'Active Record ne fournisse pas tous les outils pour travailler directement avec de telles fonctionnalités, la méthode `execute` peut être utilisée pour exécuter du SQL arbitraire.

[contraintes de clé étrangère]: #contraintes-de-clé-étrangère

Migrations et données de départ
-------------------------------

Le principal objectif de la fonctionnalité de migration de Rails est d'émettre des commandes qui modifient le schéma en utilisant un processus cohérent. Les migrations peuvent également être utilisées pour ajouter ou modifier des données. Cela est utile dans une base de données existante qui ne peut pas être détruite et recréée, comme une base de données de production.

```ruby
class AddInitialProducts < ActiveRecord::Migration[7.1]
  def up
    5.times do |i|
      Product.create(name: "Product ##{i}", description: "A product.")
    end
  end

  def down
    Product.delete_all
  end
end
```

Pour ajouter des données initiales après la création d'une base de données, Rails dispose d'une fonctionnalité intégrée de "seeds" qui accélère le processus. Cela est particulièrement utile lors du rechargement fréquent de la base de données dans les environnements de développement et de test, ou lors de la configuration des données initiales pour la production.

Pour commencer avec cette fonctionnalité, ouvrez `db/seeds.rb` et ajoutez du code Ruby, puis exécutez `bin/rails db:seed`.

NOTE : Le code ici doit être idempotent afin de pouvoir être exécuté à n'importe quel moment dans chaque environnement.

```ruby
["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
  MovieGenre.find_or_create_by!(name: genre_name)
end
```

C'est généralement une façon beaucoup plus propre de configurer la base de données d'une application vide.

Anciennes migrations
--------------------

Le fichier `db/schema.rb` ou `db/structure.sql` est un instantané de l'état actuel de votre base de données et constitue la source d'autorité pour reconstruire cette base de données. Cela permet de supprimer ou de nettoyer d'anciens fichiers de migration.

Lorsque vous supprimez des fichiers de migration dans le répertoire `db/migrate/`, tout environnement où `bin/rails db:migrate` a été exécuté lorsque ces fichiers existaient encore conservera une référence à l'horodatage de migration qui leur est spécifique dans une table interne de la base de données Rails appelée `schema_migrations`. Cette table est utilisée pour suivre si les migrations ont été exécutées dans un environnement spécifique.

Si vous exécutez la commande `bin/rails db:migrate:status`, qui affiche l'état (activé ou désactivé) de chaque migration, vous devriez voir `********** NO FILE **********` affiché à côté de tout fichier de migration supprimé qui a été exécuté une fois dans un environnement spécifique mais qui ne peut plus être trouvé dans le répertoire `db/migrate/`.

### Migrations provenant de moteurs

Il y a cependant une mise en garde avec les [moteurs][]. Les tâches Rake pour installer les migrations provenant des moteurs sont idempotentes, ce qui signifie qu'elles auront le même résultat quelle que soit leur fréquence d'appel. Les migrations présentes dans l'application parente en raison d'une installation précédente sont ignorées, et celles qui manquent sont copiées avec un nouvel horodatage. Si vous supprimez d'anciennes migrations de moteur et que vous exécutez à nouveau la tâche d'installation, vous obtiendrez de nouveaux fichiers avec de nouveaux horodatages, et `db:migrate` tentera de les exécuter à nouveau.

Ainsi, vous voulez généralement conserver les migrations provenant des moteurs. Elles ont un commentaire spécial comme ceci :

```ruby
# Cette migration provient de blorgh (initialement 20210621082949)
```

 [moteurs]: engines.html
[`add_column`]: https://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html#method-i-add_column
[`add_index`]: https://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html#method-i-add_index
[`add_reference`]: https://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html#method-i-add_reference
[`remove_column`]: https://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html#method-i-remove_column
[`create_table`]: https://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html#method-i-create_table
[`create_join_table`]: https://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html#method-i-create_join_table
[`change_table`]: https://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html#method-i-change_table
[`change_column`]: https://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html#method-i-change_column
[`change_column_default`]: https://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html#method-i-change_column_default
[`change_column_null`]: https://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html#method-i-change_column_null
[`execute`]: https://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/DatabaseStatements.html#method-i-execute
[`ActiveRecord::ConnectionAdapters::SchemaStatements`]: https://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html
[`ActiveRecord::ConnectionAdapters::TableDefinition`]: https://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/TableDefinition.html
[`ActiveRecord::ConnectionAdapters::Table`]: https://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/Table.html
[`add_check_constraint`]: https://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html#method-i-add_check_constraint
[`add_foreign_key`]: https://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html#method-i-add_foreign_key
[`add_timestamps`]: https://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html#method-i-add_timestamps
[`change_column_comment`]: https://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html#method-i-change_column_comment
[`change_table_comment`]: https://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html#method-i-change_table_comment
[`drop_join_table`]: https://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html#method-i-drop_join_table
[`drop_table`]: https://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html#method-i-drop_table
[`remove_check_constraint`]: https://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html#method-i-remove_check_constraint
[`remove_foreign_key`]: https://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html#method-i-remove_foreign_key
[`remove_index`]: https://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html#method-i-remove_index
[`remove_reference`]: https://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html#method-i-remove_reference
[`remove_timestamps`]: https://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html#method-i-remove_timestamps
[`rename_column`]: https://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html#method-i-rename_column
[`remove_columns`]: https://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html#method-i-remove_columns
[`rename_index`]: https://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html#method-i-rename_index
[`rename_table`]: https://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html#method-i-rename_table
[`reversible`]: https://api.rubyonrails.org/classes/ActiveRecord/Migration.html#method-i-reversible
[`revert`]: https://api.rubyonrails.org/classes/ActiveRecord/Migration.html#method-i-revert
[`say`]: https://api.rubyonrails.org/classes/ActiveRecord/Migration.html#method-i-say
[`say_with_time`]: https://api.rubyonrails.org/classes/ActiveRecord/Migration.html#method-i-say_with_time
[`suppress_messages`]: https://api.rubyonrails.org/classes/ActiveRecord/Migration.html#method-i-suppress_messages
[`config.active_record.schema_format`]: configuring.html#config-active-record-schema-format
