**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 67ad41dc27cc9079db9a7e31dffa5aac
Multiples bases de données avec Active Record
=====================================

Ce guide explique comment utiliser plusieurs bases de données avec votre application Rails.

Après avoir lu ce guide, vous saurez :

* Comment configurer votre application pour plusieurs bases de données.
* Comment fonctionne la commutation automatique de connexion.
* Comment utiliser le sharding horizontal pour plusieurs bases de données.
* Quelles fonctionnalités sont prises en charge et ce qui est encore en cours de développement.

--------------------------------------------------------------------------------

À mesure qu'une application gagne en popularité et en utilisation, vous devrez la mettre à l'échelle pour prendre en charge vos nouveaux utilisateurs et leurs données. Une façon dont votre application peut avoir besoin de se mettre à l'échelle est au niveau de la base de données. Rails prend désormais en charge plusieurs bases de données afin que vous n'ayez pas à stocker toutes vos données au même endroit.

À l'heure actuelle, les fonctionnalités suivantes sont prises en charge :

* Plusieurs bases de données en écriture et une réplique pour chacune
* Commutation automatique de connexion pour le modèle avec lequel vous travaillez
* Échange automatique entre l'écriture et la réplique en fonction de la méthode HTTP et des écritures récentes
* Tâches Rails pour la création, la suppression, la migration et l'interaction avec les multiples bases de données

Les fonctionnalités suivantes ne sont pas (encore) prises en charge :

* Équilibrage de charge des répliques

## Configuration de votre application

Bien que Rails essaie de faire la plupart du travail pour vous, il y a encore quelques étapes que vous devrez effectuer pour préparer votre application à plusieurs bases de données.

Disons que nous avons une application avec une seule base de données en écriture et que nous devons ajouter une nouvelle base de données pour certaines nouvelles tables que nous ajoutons. Le nom de la nouvelle base de données sera "animals".

Le fichier `database.yml` ressemble à ceci :

```yaml
production:
  database: my_primary_database
  adapter: mysql2
  username: root
  password: <%= ENV['ROOT_PASSWORD'] %>
```

Ajoutons une réplique pour la première configuration, ainsi qu'une deuxième base de données appelée "animals" et une réplique pour celle-ci également. Pour cela, nous devons modifier notre fichier `database.yml` d'une configuration à deux niveaux à une configuration à trois niveaux.

Si une configuration principale est fournie, elle sera utilisée comme configuration "par défaut". S'il n'y a pas de configuration nommée "primary", Rails utilisera la première configuration par défaut pour chaque environnement. Les configurations par défaut utiliseront les noms de fichiers Rails par défaut. Par exemple, les configurations principales utiliseront `schema.rb` pour le fichier de schéma, tandis que toutes les autres entrées utiliseront `[CONFIGURATION_NAMESPACE]_schema.rb` pour le nom de fichier.

```yaml
production:
  primary:
    database: my_primary_database
    username: root
    password: <%= ENV['ROOT_PASSWORD'] %>
    adapter: mysql2
  primary_replica:
    database: my_primary_database
    username: root_readonly
    password: <%= ENV['ROOT_READONLY_PASSWORD'] %>
    adapter: mysql2
    replica: true
  animals:
    database: my_animals_database
    username: animals_root
    password: <%= ENV['ANIMALS_ROOT_PASSWORD'] %>
    adapter: mysql2
    migrations_paths: db/animals_migrate
  animals_replica:
    database: my_animals_database
    username: animals_readonly
    password: <%= ENV['ANIMALS_READONLY_PASSWORD'] %>
    adapter: mysql2
    replica: true
```

Lors de l'utilisation de plusieurs bases de données, il y a quelques paramètres importants.

Tout d'abord, le nom de la base de données pour `primary` et `primary_replica` doit être le même car ils contiennent les mêmes données. C'est également le cas pour `animals` et `animals_replica`.

Deuxièmement, le nom d'utilisateur des écrivains et des répliques doit être différent, et les permissions de base de données de l'utilisateur de la réplique doivent être définies uniquement en lecture et non en écriture.

Lors de l'utilisation d'une base de données de réplique, vous devez ajouter une entrée `replica: true` à la réplique dans le fichier `database.yml`. Cela est nécessaire car Rails n'a aucun moyen de savoir laquelle est une réplique et laquelle est l'écrivain. Rails n'exécutera pas certaines tâches, telles que les migrations, sur les répliques.

Enfin, pour les nouvelles bases de données en écriture, vous devez définir les `migrations_paths` sur le répertoire où vous stockerez les migrations pour cette base de données. Nous examinerons plus en détail `migrations_paths` plus tard dans ce guide.

Maintenant que nous avons une nouvelle base de données, configurons le modèle de connexion. Pour utiliser la nouvelle base de données, nous devons créer une nouvelle classe abstraite et nous connecter aux bases de données des animaux.

```ruby
class AnimalsRecord < ApplicationRecord
  self.abstract_class = true

  connects_to database: { writing: :animals, reading: :animals_replica }
end
```

Ensuite, nous devons mettre à jour `ApplicationRecord` pour prendre en compte notre nouvelle réplique.

```ruby
class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  connects_to database: { writing: :primary, reading: :primary_replica }
end
```

Si vous utilisez une classe avec un nom différent pour votre enregistrement d'application, vous devez définir `primary_abstract_class` à la place, afin que Rails sache avec quelle classe `ActiveRecord::Base` doit partager une connexion.

```ruby
class PrimaryApplicationRecord < ActiveRecord::Base
  primary_abstract_class
end
```

Les classes qui se connectent à primary/primary_replica peuvent hériter de votre classe abstraite principale comme dans les applications Rails standard :
```ruby
class Person < ApplicationRecord
end
```

Par défaut, Rails s'attend à ce que les rôles de la base de données soient `écriture` et `lecture` pour le primaire
et la réplique respectivement. Si vous avez un système hérité, vous pouvez déjà avoir des rôles configurés que
vous ne voulez pas changer. Dans ce cas, vous pouvez définir un nouveau nom de rôle dans la configuration de votre application.

```ruby
config.active_record.writing_role = :default
config.active_record.reading_role = :readonly
```

Il est important de se connecter à votre base de données dans un seul modèle, puis d'hériter de ce modèle
pour les tables plutôt que de connecter plusieurs modèles individuels à la même base de données. Les clients de base de données
ont une limite sur le nombre de connexions ouvertes possibles et si vous faites cela, cela va
multiplier le nombre de connexions que vous avez puisque Rails utilise le nom de la classe du modèle pour la
spécification de connexion.

Maintenant que nous avons le fichier `database.yml` et le nouveau modèle configuré, il est temps de créer les bases de données.
Rails 6.0 est livré avec toutes les tâches Rails dont vous avez besoin pour utiliser plusieurs bases de données dans Rails.

Vous pouvez exécuter `bin/rails -T` pour voir toutes les commandes que vous pouvez exécuter. Vous devriez voir ce qui suit:

```bash
$ bin/rails -T
bin/rails db:create                          # Crée la base de données à partir de DATABASE_URL ou config/database.yml pour ...
bin/rails db:create:animals                  # Crée la base de données animals pour l'environnement actuel
bin/rails db:create:primary                  # Crée la base de données primaire pour l'environnement actuel
bin/rails db:drop                            # Supprime la base de données à partir de DATABASE_URL ou config/database.yml pour ...
bin/rails db:drop:animals                    # Supprime la base de données animals pour l'environnement actuel
bin/rails db:drop:primary                    # Supprime la base de données primaire pour l'environnement actuel
bin/rails db:migrate                         # Effectue la migration de la base de données (options: VERSION=x, VERBOSE=false, SCOPE=blog)
bin/rails db:migrate:animals                 # Effectue la migration de la base de données animals pour l'environnement actuel
bin/rails db:migrate:primary                 # Effectue la migration de la base de données primaire pour l'environnement actuel
bin/rails db:migrate:status                  # Affiche l'état des migrations
bin/rails db:migrate:status:animals          # Affiche l'état des migrations pour la base de données animals
bin/rails db:migrate:status:primary          # Affiche l'état des migrations pour la base de données primaire
bin/rails db:reset                           # Supprime et recrée toutes les bases de données à partir de leur schéma pour l'environnement actuel et charge les données de départ
bin/rails db:reset:animals                   # Supprime et recrée la base de données animals à partir de son schéma pour l'environnement actuel et charge les données de départ
bin/rails db:reset:primary                   # Supprime et recrée la base de données primaire à partir de son schéma pour l'environnement actuel et charge les données de départ
bin/rails db:rollback                        # Rejette le schéma à la version précédente (spécifiez les étapes avec STEP=n)
bin/rails db:rollback:animals                # Rejette la base de données animals pour l'environnement actuel (spécifiez les étapes avec STEP=n)
bin/rails db:rollback:primary                # Rejette la base de données primaire pour l'environnement actuel (spécifiez les étapes avec STEP=n)
bin/rails db:schema:dump                     # Crée un fichier de schéma de base de données (soit db/schema.rb, soit db/structure.sql  ...
bin/rails db:schema:dump:animals             # Crée un fichier de schéma de base de données (soit db/schema.rb, soit db/structure.sql  ...
bin/rails db:schema:dump:primary             # Crée un fichier db/schema.rb portable pour n'importe quelle base de données prise en charge  ...
bin/rails db:schema:load                     # Charge un fichier de schéma de base de données (soit db/schema.rb, soit db/structure.sql  ...
bin/rails db:schema:load:animals             # Charge un fichier de schéma de base de données (soit db/schema.rb, soit db/structure.sql  ...
bin/rails db:schema:load:primary             # Charge un fichier de schéma de base de données (soit db/schema.rb, soit db/structure.sql  ...
bin/rails db:setup                           # Crée toutes les bases de données, charge tous les schémas et initialise avec les données de départ (utilisez db:reset pour supprimer d'abord toutes les bases de données)
bin/rails db:setup:animals                   # Crée la base de données animals, charge le schéma et initialise avec les données de départ (utilisez db:reset:animals pour supprimer d'abord la base de données)
bin/rails db:setup:primary                   # Crée la base de données primaire, charge le schéma et initialise avec les données de départ (utilisez db:reset:primary pour supprimer d'abord la base de données)
```

L'exécution d'une commande comme `bin/rails db:create` créera à la fois les bases de données primaire et animals.
Notez qu'il n'y a pas de commande pour créer les utilisateurs de base de données, et vous devrez le faire manuellement
pour prendre en charge les utilisateurs en lecture seule pour vos répliques. Si vous voulez créer uniquement la base de données animals,
vous pouvez exécuter `bin/rails db:create:animals`.

## Connexion aux bases de données sans gérer le schéma et les migrations

Si vous souhaitez vous connecter à une base de données externe sans aucune tâche de gestion de base de données
telles que la gestion du schéma, les migrations, les données de départ, etc., vous pouvez définir
l'option de configuration spécifique à chaque base de données `database_tasks: false`. Par défaut, elle est
définie sur true.

```yaml
production:
  primary:
    database: ma_base_de_donnees
    adapter: mysql2
  animals:
    database: ma_base_de_donnees_animaux
    adapter: mysql2
    database_tasks: false
```

## Générateurs et Migrations

Les migrations pour plusieurs bases de données doivent être placées dans leurs propres dossiers préfixés par le
nom de la clé de la base de données dans la configuration.
Vous devez également définir les `migrations_paths` dans les configurations de la base de données pour indiquer à Rails où trouver les migrations.

Par exemple, la base de données `animals` rechercherait les migrations dans le répertoire `db/animals_migrate` et `primary` rechercherait dans `db/migrate`. Les générateurs de Rails prennent désormais une option `--database` pour générer le fichier dans le répertoire correct. La commande peut être exécutée comme ceci :

```bash
$ bin/rails generate migration CreateDogs name:string --database animals
```

Si vous utilisez les générateurs de Rails, les générateurs de scaffold et de modèle créeront la classe abstraite pour vous. Il suffit de passer la clé de la base de données à la ligne de commande.

```bash
$ bin/rails generate scaffold Dog name:string --database animals
```

Une classe avec le nom de la base de données et `Record` sera créée. Dans cet exemple, la base de données est `Animals`, nous obtenons donc `AnimalsRecord` :

```ruby
class AnimalsRecord < ApplicationRecord
  self.abstract_class = true

  connects_to database: { writing: :animals }
end
```

Le modèle généré héritera automatiquement de `AnimalsRecord`.

```ruby
class Dog < AnimalsRecord
end
```

NOTE : Comme Rails ne sait pas quelle base de données est la réplique de votre écrivain, vous devrez ajouter ceci à la classe abstraite une fois que vous avez terminé.

Rails ne générera la nouvelle classe qu'une seule fois. Elle ne sera pas écrasée par de nouveaux scaffolds ou supprimée si le scaffold est supprimé.

Si vous avez déjà une classe abstraite et que son nom diffère de `AnimalsRecord`, vous pouvez passer l'option `--parent` pour indiquer que vous souhaitez une classe abstraite différente :

```bash
$ bin/rails generate scaffold Dog name:string --database animals --parent Animals::Record
```

Cela permettra de sauter la génération de `AnimalsRecord` puisque vous avez indiqué à Rails que vous souhaitez utiliser une classe parent différente.

## Activation de la commutation automatique des rôles

Enfin, pour utiliser la réplique en lecture seule dans votre application, vous devrez activer le middleware de commutation automatique.

La commutation automatique permet à l'application de passer de l'écrivain à la réplique ou de la réplique à l'écrivain en fonction de la méthode HTTP et de la présence d'une écriture récente par l'utilisateur demandeur.

Si l'application reçoit une requête POST, PUT, DELETE ou PATCH, elle écrira automatiquement dans la base de données de l'écrivain. Pendant le temps spécifié après l'écriture, l'application lira à partir de la base de données principale. Pour une requête GET ou HEAD, l'application lira à partir de la réplique sauf s'il y a eu une écriture récente.

Pour activer le middleware de commutation automatique de connexion, vous pouvez exécuter le générateur de commutation automatique :

```bash
$ bin/rails g active_record:multi_db
```

Et décommentez ensuite les lignes suivantes :

```ruby
Rails.application.configure do
  config.active_record.database_selector = { delay: 2.seconds }
  config.active_record.database_resolver = ActiveRecord::Middleware::DatabaseSelector::Resolver
  config.active_record.database_resolver_context = ActiveRecord::Middleware::DatabaseSelector::Resolver::Session
end
```

Rails garantit "lire votre propre écriture" et enverra votre requête GET ou HEAD à l'écrivain si elle se trouve dans la fenêtre de `delay`. Par défaut, le délai est fixé à 2 secondes. Vous devriez le modifier en fonction de votre infrastructure de base de données. Rails ne garantit pas "lire une écriture récente" pour les autres utilisateurs dans la fenêtre de délai et enverra les requêtes GET et HEAD aux répliques à moins qu'ils n'aient écrit récemment.

La commutation automatique de connexion dans Rails est relativement primitive et ne fait délibérément pas grand-chose. L'objectif est un système qui démontre comment effectuer une commutation automatique de connexion qui soit suffisamment flexible pour être personnalisée par les développeurs d'applications.

La configuration dans Rails vous permet de changer facilement la façon dont la commutation est effectuée et sur quels paramètres elle est basée. Disons que vous voulez utiliser un cookie au lieu d'une session pour décider quand échanger les connexions. Vous pouvez écrire votre propre classe :

```ruby
class MyCookieResolver << ActiveRecord::Middleware::DatabaseSelector::Resolver
  def self.call(request)
    new(request.cookies)
  end

  def initialize(cookies)
    @cookies = cookies
  end

  attr_reader :cookies

  def last_write_timestamp
    self.class.convert_timestamp_to_time(cookies[:last_write])
  end

  def update_last_write_timestamp
    cookies[:last_write] = self.class.convert_time_to_timestamp(Time.now)
  end

  def save(response)
  end
end
```

Et ensuite le passer au middleware :

```ruby
config.active_record.database_selector = { delay: 2.seconds }
config.active_record.database_resolver = ActiveRecord::Middleware::DatabaseSelector::Resolver
config.active_record.database_resolver_context = MyCookieResolver
```

## Utilisation de la commutation manuelle de connexion

Il existe des cas où vous souhaiterez peut-être que votre application se connecte à un écrivain ou à une réplique et où la commutation automatique de connexion n'est pas adéquate. Par exemple, vous pouvez savoir que pour une requête particulière, vous voulez toujours envoyer la requête à une réplique, même lorsque vous êtes dans un chemin de requête POST.

Pour cela, Rails fournit une méthode `connected_to` qui permet de basculer vers la connexion dont vous avez besoin.
```ruby
ActiveRecord::Base.connected_to(role: :reading) do
  # tout le code dans ce bloc sera connecté au rôle de lecture
end
```

Le "rôle" dans l'appel `connected_to` recherche les connexions qui sont connectées sur ce gestionnaire de connexion (ou rôle). Le gestionnaire de connexion `reading` contiendra toutes les connexions qui ont été connectées via `connects_to` avec le nom de rôle `reading`.

Notez que `connected_to` avec un rôle recherchera une connexion existante et basculera en utilisant le nom de spécification de connexion. Cela signifie que si vous passez un rôle inconnu comme `connected_to(role: :nonexistent)`, vous obtiendrez une erreur qui dit `ActiveRecord::ConnectionNotEstablished (No connection pool for 'ActiveRecord::Base' found for the 'nonexistent' role.)`

Si vous voulez que Rails garantisse que toutes les requêtes effectuées sont en lecture seule, passez `prevent_writes: true`. Cela empêche simplement l'envoi de requêtes qui ressemblent à des écritures à la base de données. Vous devez également configurer votre base de données de réplica pour fonctionner en mode lecture seule.

```ruby
ActiveRecord::Base.connected_to(role: :reading, prevent_writes: true) do
  # Rails vérifiera chaque requête pour s'assurer qu'il s'agit d'une requête de lecture
end
```

## Fragmentation horizontale

La fragmentation horizontale consiste à diviser votre base de données pour réduire le nombre de lignes sur chaque serveur de base de données, tout en maintenant le même schéma sur les "fragments". On appelle cela communément la fragmentation "multi-tenant".

L'API pour prendre en charge la fragmentation horizontale dans Rails est similaire à l'API de fragmentation verticale / de bases de données multiples qui existe depuis Rails 6.0.

Les fragments sont déclarés dans la configuration à trois niveaux comme ceci:

```yaml
production:
  primary:
    database: my_primary_database
    adapter: mysql2
  primary_replica:
    database: my_primary_database
    adapter: mysql2
    replica: true
  primary_shard_one:
    database: my_primary_shard_one
    adapter: mysql2
  primary_shard_one_replica:
    database: my_primary_shard_one
    adapter: mysql2
    replica: true
```

Les modèles sont ensuite connectés avec l'API `connects_to` via la clé `shards`:

```ruby
class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  connects_to shards: {
    default: { writing: :primary, reading: :primary_replica },
    shard_one: { writing: :primary_shard_one, reading: :primary_shard_one_replica }
  }
end
```

Vous n'êtes pas obligé d'utiliser `default` comme premier nom de fragment. Rails suppose que le premier nom de fragment dans le hachage `connects_to` est la connexion "par défaut". Cette connexion est utilisée en interne pour charger les données de type et autres informations où le schéma est le même sur tous les fragments.

Ensuite, les modèles peuvent échanger manuellement les connexions via l'API `connected_to`. Si vous utilisez la fragmentation, à la fois un `role` et un `shard` doivent être passés:

```ruby
ActiveRecord::Base.connected_to(role: :writing, shard: :default) do
  @id = Person.create! # Crée un enregistrement dans le fragment nommé ":default"
end

ActiveRecord::Base.connected_to(role: :writing, shard: :shard_one) do
  Person.find(@id) # Impossible de trouver l'enregistrement, il n'existe pas car il a été créé
                   # dans le fragment nommé ":default".
end
```

L'API de fragmentation horizontale prend également en charge les réplicas de lecture. Vous pouvez échanger le rôle et le fragment avec l'API `connected_to`.

```ruby
ActiveRecord::Base.connected_to(role: :reading, shard: :shard_one) do
  Person.first # Recherche un enregistrement à partir du réplica de lecture du fragment one
end
```

## Activation de la commutation automatique de fragment

Les applications peuvent automatiquement basculer les fragments par requête en utilisant le middleware fourni.

Le middleware `ShardSelector` fournit un cadre pour basculer automatiquement les fragments. Rails fournit un cadre de base pour déterminer quel fragment basculer et permet aux applications d'écrire des stratégies personnalisées si nécessaire.

Le `ShardSelector` prend un ensemble d'options (actuellement seul `lock` est pris en charge) qui peuvent être utilisées par le middleware pour modifier le comportement. `lock` est vrai par défaut et empêchera la requête de basculer entre les fragments une fois à l'intérieur du bloc. Si `lock` est faux, alors le basculement de fragment sera autorisé. Pour la fragmentation basée sur le locataire, `lock` doit toujours être vrai pour empêcher le code de l'application de basculer accidentellement entre les locataires.

Le même générateur que le sélecteur de base de données peut être utilisé pour générer le fichier de basculement automatique de fragment :

```bash
$ bin/rails g active_record:multi_db
```

Ensuite, dans le fichier, décommentez ce qui suit :

```ruby
Rails.application.configure do
  config.active_record.shard_selector = { lock: true }
  config.active_record.shard_resolver = ->(request) { Tenant.find_by!(host: request.host).shard }
end
```

Les applications doivent fournir le code pour le résolveur car il dépend des modèles spécifiques de l'application. Un résolveur d'exemple ressemblerait à ceci :

```ruby
config.active_record.shard_resolver = ->(request) {
  subdomain = request.subdomain
  tenant = Tenant.find_by_subdomain!(subdomain)
  tenant.shard
}
```

## Commutation granulaire de la connexion à la base de données

Dans Rails 6.1, il est possible de basculer les connexions pour une base de données spécifique au lieu de toutes les bases de données globalement.

Avec la commutation granulaire de la connexion à la base de données, toute classe de connexion abstraite pourra basculer les connexions sans affecter les autres connexions. Cela est utile pour basculer vos requêtes `AnimalsRecord` pour lire à partir du réplica tout en vous assurant que vos requêtes `ApplicationRecord` vont vers le primaire.
```ruby
AnimalsRecord.connected_to(role: :reading) do
  Dog.first # Lit à partir de animals_replica
  Person.first  # Lit à partir de primary
end
```

Il est également possible de changer les connexions de manière granulaire pour les fragments.

```ruby
AnimalsRecord.connected_to(role: :reading, shard: :shard_one) do
  Dog.first # Lira à partir de shard_one_replica. Si aucune connexion n'existe pour shard_one_replica,
  # une erreur ConnectionNotEstablished sera levée
  Person.first # Lira à partir du rédacteur principal
end
```

Pour basculer uniquement sur le cluster de base de données principal, utilisez `ApplicationRecord` :

```ruby
ApplicationRecord.connected_to(role: :reading, shard: :shard_one) do
  Person.first # Lit à partir de primary_shard_one_replica
  Dog.first # Lit à partir de animals_primary
end
```

`ActiveRecord::Base.connected_to` maintient la possibilité de basculer les connexions globalement.

### Gestion des associations avec des jointures entre bases de données

À partir de Rails 7.0+, Active Record dispose d'une option pour gérer les associations qui effectueraient
une jointure entre plusieurs bases de données. Si vous avez une association has_many through ou has_one through
que vous souhaitez désactiver la jointure et effectuer 2 ou plusieurs requêtes, passez l'option `disable_joins: true`.

Par exemple :

```ruby
class Dog < AnimalsRecord
  has_many :treats, through: :humans, disable_joins: true
  has_many :humans

  has_one :home
  has_one :yard, through: :home, disable_joins: true
end

class Home
  belongs_to :dog
  has_one :yard
end

class Yard
  belongs_to :home
end
```

Auparavant, appeler `@dog.treats` sans `disable_joins` ou `@dog.yard` sans `disable_joins`
lèverait une erreur car les bases de données ne peuvent pas gérer les jointures entre clusters. Avec l'option
`disable_joins`, Rails générera plusieurs requêtes de sélection
pour éviter de tenter une jointure entre clusters. Pour l'association ci-dessus, `@dog.treats` générera le
SQL suivant :

```sql
SELECT "humans"."id" FROM "humans" WHERE "humans"."dog_id" = ?  [["dog_id", 1]]
SELECT "treats".* FROM "treats" WHERE "treats"."human_id" IN (?, ?, ?)  [["human_id", 1], ["human_id", 2], ["human_id", 3]]
```

Alors que `@dog.yard` générera le SQL suivant :

```sql
SELECT "home"."id" FROM "homes" WHERE "homes"."dog_id" = ? [["dog_id", 1]]
SELECT "yards".* FROM "yards" WHERE "yards"."home_id" = ? [["home_id", 1]]
```

Il y a quelques points importants à prendre en compte avec cette option :

1. Il peut y avoir des implications de performance car maintenant deux ou plusieurs requêtes seront effectuées (en fonction
   de l'association) plutôt qu'une jointure. Si la sélection pour `humans` renvoie un grand nombre d'IDs
   la sélection pour `treats` peut envoyer trop d'IDs.
2. Étant donné que nous ne réalisons plus de jointures, une requête avec un ordre ou une limite est maintenant triée en mémoire car
   l'ordre d'une table ne peut pas être appliqué à une autre table.
3. Ce paramètre doit être ajouté à toutes les associations où vous souhaitez désactiver la jointure.
   Rails ne peut pas le deviner pour vous car le chargement des associations est paresseux, pour charger `treats` dans `@dog.treats`
   Rails a déjà besoin de savoir quel SQL doit être généré.

### Mise en cache du schéma

Si vous souhaitez charger un cache de schéma pour chaque base de données, vous devez définir un `schema_cache_path` dans chaque configuration de base de données et définir `config.active_record.lazily_load_schema_cache = true` dans votre configuration d'application. Notez que cela chargera le cache de manière paresseuse lorsque les connexions de base de données seront établies.

## Limitations

### Équilibrage de charge des réplicas

Rails ne prend pas en charge l'équilibrage de charge automatique des réplicas. Cela dépend fortement de votre infrastructure. Nous pourrions implémenter un équilibrage de charge basique et primitif à l'avenir, mais pour une application à grande échelle, cela devrait être géré en dehors de Rails par votre application.
