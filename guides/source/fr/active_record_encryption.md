**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 720efaf8e1845c472cc18a5e55f3eabb
Chiffrement d'Active Record
========================

Ce guide explique comment chiffrer vos informations de base de données à l'aide d'Active Record.

Après avoir lu ce guide, vous saurez :

* Comment configurer le chiffrement de la base de données avec Active Record.
* Comment migrer des données non chiffrées.
* Comment faire coexister différents schémas de chiffrement.
* Comment utiliser l'API.
* Comment configurer la bibliothèque et comment l'étendre.

--------------------------------------------------------------------------------

Active Record prend en charge le chiffrement au niveau de l'application. Il fonctionne en déclarant quelles attributs doivent être chiffrés et en les chiffrant et déchiffrant de manière transparente lorsque cela est nécessaire. La couche de chiffrement se situe entre la base de données et l'application. L'application accédera aux données non chiffrées, mais la base de données les stockera chiffrées.

## Pourquoi chiffrer les données au niveau de l'application ?

Le chiffrement d'Active Record existe pour protéger les informations sensibles de votre application. Un exemple typique est les informations d'identification personnelles des utilisateurs. Mais pourquoi vouloir un chiffrement au niveau de l'application si vous chiffrez déjà votre base de données au repos ?

En bénéficiant immédiatement d'un avantage pratique, le chiffrement des attributs sensibles ajoute une couche de sécurité supplémentaire. Par exemple, si un attaquant avait accès à votre base de données, à une capture d'écran de celle-ci ou à vos journaux d'application, il ne pourrait pas comprendre les informations chiffrées. De plus, le chiffrement peut empêcher les développeurs de divulguer involontairement les données sensibles des utilisateurs dans les journaux d'application.

Mais plus important encore, en utilisant le chiffrement d'Active Record, vous définissez ce qui constitue des informations sensibles dans votre application au niveau du code. Le chiffrement d'Active Record permet un contrôle granulaire de l'accès aux données dans votre application et les services qui consomment les données de votre application. Par exemple, envisagez des [consoles Rails audibles qui protègent les données chiffrées](https://github.com/basecamp/console1984) ou vérifiez le système intégré pour [filtrer automatiquement les paramètres du contrôleur](#filtrage-des-paramètres-nommés-comme-des-colonnes-chiffrées).

## Utilisation de base

### Configuration

Tout d'abord, vous devez ajouter quelques clés à vos [informations d'identification Rails](/security.html#custom-credentials). Exécutez `bin/rails db:encryption:init` pour générer un ensemble de clés aléatoires :

```bash
$ bin/rails db:encryption:init
Ajoutez cette entrée aux informations d'identification de l'environnement cible :

active_record_encryption:
  primary_key: EGY8WhulUOXixybod7ZWwMIL68R9o5kC
  deterministic_key: aPA5XyALhf75NNnMzaspW7akTfZp0lPY
  key_derivation_salt: xEY0dt6TZcAMg52K7O84wYzkjvbA62Hz
```

NOTE : Ces valeurs générées font 32 octets de longueur. Si vous les générez vous-même, les longueurs minimales que vous devez utiliser sont de 12 octets pour la clé principale (celle-ci sera utilisée pour dériver la clé AES de 32 octets) et de 20 octets pour le sel.

### Déclaration des attributs chiffrés

Les attributs chiffrables sont définis au niveau du modèle. Ce sont des attributs Active Record classiques sauvegardés dans une colonne portant le même nom.

```ruby
class Article < ApplicationRecord
  encrypts :title
end
````

La bibliothèque chiffrera ces attributs de manière transparente avant de les enregistrer dans la base de données et les déchiffrera lors de leur récupération :

```ruby
article = Article.create title: "Tout chiffrer !"
article.title # => "Tout chiffrer !"
```

Mais, en réalité, le SQL exécuté ressemble à ceci :

```sql
INSERT INTO `articles` (`title`) VALUES ('{\"p\":\"n7J0/ol+a7DRMeaE\",\"h\":{\"iv\":\"DXZMDWUKfp3bg/Yu\",\"at\":\"X1/YjMHbHD4talgF9dt61A==\"}}')
```

#### Important : À propos du stockage et de la taille de la colonne

Le chiffrement nécessite un espace supplémentaire en raison de l'encodage Base64 et des métadonnées stockées avec les charges utiles chiffrées. Lors de l'utilisation du fournisseur de clés de chiffrement intégré, vous pouvez estimer le surcoût maximal à environ 255 octets. Ce surcoût est négligeable pour les tailles plus grandes. Non seulement parce qu'il est dilué, mais aussi parce que la bibliothèque utilise la compression par défaut, ce qui peut offrir jusqu'à 30% d'économies d'espace de stockage par rapport à la version non chiffrée pour les charges utiles plus importantes.

Il y a une préoccupation importante concernant les tailles de colonnes de chaînes de caractères : dans les bases de données modernes, la taille de la colonne détermine le *nombre de caractères* qu'elle peut allouer, et non le nombre d'octets. Par exemple, avec l'UTF-8, chaque caractère peut prendre jusqu'à quatre octets, donc potentiellement, une colonne dans une base de données utilisant l'UTF-8 peut stocker jusqu'à quatre fois sa taille en termes de *nombre d'octets*. Maintenant, les charges utiles chiffrées sont des chaînes binaires sérialisées en Base64, elles peuvent donc être stockées dans des colonnes `string` régulières. Parce qu'elles sont une séquence d'octets ASCII, une colonne chiffrée peut prendre jusqu'à quatre fois la taille de sa version claire. Ainsi, même si les octets stockés dans la base de données sont les mêmes, la colonne doit être quatre fois plus grande.

En pratique, cela signifie :

* Lorsque vous chiffrez de courts textes écrits dans des alphabets occidentaux (principalement des caractères ASCII), vous devez tenir compte de ce surcoût de 255 octets lors de la définition de la taille de la colonne.
* Lorsque vous chiffrez de courts textes écrits dans des alphabets non occidentaux, tels que le cyrillique, vous devez multiplier la taille de la colonne par 4. Notez que le surcoût de stockage est de 255 octets au maximum.
* Lorsque vous chiffrez de longs textes, vous pouvez ignorer les préoccupations concernant la taille de la colonne.
Quelques exemples:

| Contenu à chiffrer                                | Taille de colonne d'origine | Taille de colonne chiffrée recommandée | Surcoût de stockage (cas le pire) |
| ------------------------------------------------- | -------------------------- | ------------------------------------- | --------------------------------- |
| Adresses e-mail                                   | string(255)                | string(510)                           | 255 octets                       |
| Courte séquence d'emojis                          | string(255)                | string(1020)                          | 255 octets                       |
| Résumé de textes écrits dans des alphabets non-occidentaux | string(500)          | string(2000)                          | 255 octets                       |
| Texte arbitrairement long                          | text                       | text                                  | négligeable                      |

### Chiffrement déterministe et non déterministe

Par défaut, Active Record Encryption utilise une approche non déterministe pour le chiffrement. Non déterministe, dans ce contexte, signifie que chiffrer le même contenu avec le même mot de passe deux fois donnera des textes chiffrés différents. Cette approche améliore la sécurité en rendant l'analyse cryptographique des textes chiffrés plus difficile et l'interrogation de la base de données impossible.

Vous pouvez utiliser l'option `deterministic:` pour générer des vecteurs d'initialisation de manière déterministe, ce qui permet d'interroger efficacement les données chiffrées.

```ruby
class Author < ApplicationRecord
  encrypts :email, deterministic: true
end

Author.find_by_email("some@email.com") # Vous pouvez interroger le modèle normalement
```

L'approche non déterministe est recommandée sauf si vous avez besoin d'interroger les données.

NOTE : En mode non déterministe, Active Record utilise AES-GCM avec une clé de 256 bits et un vecteur d'initialisation aléatoire. En mode déterministe, il utilise également AES-GCM, mais le vecteur d'initialisation est généré sous la forme d'un digest HMAC-SHA-256 de la clé et du contenu à chiffrer.

NOTE : Vous pouvez désactiver le chiffrement déterministe en omettant une `deterministic_key`.

## Fonctionnalités

### Action Text

Vous pouvez chiffrer les attributs Action Text en passant `encrypted: true` dans leur déclaration.

```ruby
class Message < ApplicationRecord
  has_rich_text :content, encrypted: true
end
```

NOTE : La transmission d'options de chiffrement individuelles aux attributs Action Text n'est pas encore prise en charge. Elle utilisera le chiffrement non déterministe avec les options de chiffrement globales configurées.

### Fixtures

Vous pouvez obtenir des fixtures Rails chiffrées automatiquement en ajoutant cette option à votre `test.rb` :

```ruby
config.active_record.encryption.encrypt_fixtures = true
```

Lorsqu'elle est activée, tous les attributs chiffrables seront chiffrés selon les paramètres de chiffrement définis dans le modèle.

#### Fixtures Action Text

Pour chiffrer les fixtures Action Text, vous devez les placer dans `fixtures/action_text/encrypted_rich_texts.yml`.

### Types pris en charge

`active_record.encryption` sérialisera les valeurs en utilisant le type sous-jacent avant de les chiffrer, mais *elles doivent être sérialisables en tant que chaînes de caractères*. Les types structurés tels que `serialized` sont pris en charge par défaut.

Si vous avez besoin de prendre en charge un type personnalisé, la méthode recommandée consiste à utiliser un [attribut sérialisé](https://api.rubyonrails.org/classes/ActiveRecord/AttributeMethods/Serialization/ClassMethods.html). La déclaration de l'attribut sérialisé doit être placée **avant** la déclaration de chiffrement :

```ruby
# CORRECT
class Article < ApplicationRecord
  serialize :title, type: Title
  encrypts :title
end

# INCORRECT
class Article < ApplicationRecord
  encrypts :title
  serialize :title, type: Title
end
```

### Ignorer la casse

Il peut être nécessaire d'ignorer la casse lors de l'interrogation de données chiffrées de manière déterministe. Deux approches facilitent cette tâche :

Vous pouvez utiliser l'option `:downcase` lors de la déclaration de l'attribut chiffré pour mettre en minuscule le contenu avant le chiffrement.

```ruby
class Person
  encrypts :email_address, deterministic: true, downcase: true
end
```

Lors de l'utilisation de `:downcase`, la casse d'origine est perdue. Dans certaines situations, vous voudrez peut-être ignorer la casse uniquement lors de l'interrogation tout en conservant la casse d'origine. Pour ces situations, vous pouvez utiliser l'option `:ignore_case`. Cela nécessite d'ajouter une nouvelle colonne nommée `original_<nom_de_colonne>` pour stocker le contenu avec la casse inchangée :

```ruby
class Label
  encrypts :name, deterministic: true, ignore_case: true # le contenu avec la casse d'origine sera stocké dans la colonne `original_name`
end
```

### Prise en charge des données non chiffrées

Pour faciliter les migrations de données non chiffrées, la bibliothèque inclut l'option `config.active_record.encryption.support_unencrypted_data`. Lorsqu'elle est définie sur `true` :

* Essayer de lire des attributs chiffrés qui ne sont pas chiffrés fonctionnera normalement, sans générer d'erreur.
* Les requêtes avec des attributs chiffrés de manière déterministe incluront la version "en clair" d'entre eux pour prendre en charge la recherche de contenu chiffré et non chiffré. Vous devez définir `config.active_record.encryption.extend_queries = true` pour activer cette fonctionnalité.

**Cette option est destinée à être utilisée pendant les périodes de transition** lorsque des données claires et des données chiffrées doivent coexister. Les deux sont définis sur `false` par défaut, ce qui est l'objectif recommandé pour toute application : des erreurs seront générées lors de la manipulation de données non chiffrées.

### Prise en charge des anciens schémas de chiffrement

Modifier les propriétés de chiffrement des attributs peut rompre les données existantes. Par exemple, imaginez que vous souhaitez rendre un attribut déterministe non déterministe. Si vous modifiez simplement la déclaration dans le modèle, la lecture des textes chiffrés existants échouera car la méthode de chiffrement est maintenant différente.
Pour prendre en charge ces situations, vous pouvez déclarer les schémas de chiffrement précédents qui seront utilisés dans deux scénarios :

* Lors de la lecture de données chiffrées, Active Record Encryption essaiera les schémas de chiffrement précédents si le schéma actuel ne fonctionne pas.
* Lors de la requête de données déterministes, il ajoutera des textes chiffrés en utilisant les schémas précédents afin que les requêtes fonctionnent de manière transparente avec des données chiffrées avec différents schémas. Vous devez définir `config.active_record.encryption.extend_queries = true` pour activer cela.

Vous pouvez configurer les schémas de chiffrement précédents :

* Globalement
* Sur une base par attribut

#### Schémas de chiffrement précédents globaux

Vous pouvez ajouter des schémas de chiffrement précédents en les ajoutant sous forme de liste de propriétés en utilisant la propriété de configuration `previous` dans votre `application.rb` :

```ruby
config.active_record.encryption.previous = [ { key_provider: MyOldKeyProvider.new } ]
```

#### Schémas de chiffrement par attribut

Utilisez `:previous` lors de la déclaration de l'attribut :

```ruby
class Article
  encrypts :title, deterministic: true, previous: { deterministic: false }
end
```

#### Schémas de chiffrement et attributs déterministes

Lors de l'ajout de schémas de chiffrement précédents :

* Avec un chiffrement **non déterministe**, les nouvelles informations seront toujours chiffrées avec le schéma de chiffrement le plus *récent* (actuel).
* Avec un chiffrement **déterministe**, les nouvelles informations seront toujours chiffrées avec le schéma de chiffrement le plus *ancien* par défaut.

En général, avec un chiffrement déterministe, vous voulez que les textes chiffrés restent constants. Vous pouvez modifier ce comportement en définissant `deterministic: { fixed: false }`. Dans ce cas, il utilisera le schéma de chiffrement le plus *récent* pour chiffrer les nouvelles données.

### Contraintes uniques

NOTE : Les contraintes uniques ne peuvent être utilisées qu'avec des données chiffrées de manière déterministe.

#### Validations uniques

Les validations uniques sont prises en charge normalement tant que les requêtes étendues sont activées (`config.active_record.encryption.extend_queries = true`).

```ruby
class Person
  validates :email_address, uniqueness: true
  encrypts :email_address, deterministic: true, downcase: true
end
```

Elles fonctionneront également lors de la combinaison de données chiffrées et non chiffrées, ainsi que lors de la configuration de schémas de chiffrement précédents.

NOTE : Si vous souhaitez ignorer la casse, assurez-vous d'utiliser `downcase:` ou `ignore_case:` dans la déclaration `encrypts`. L'utilisation de l'option `case_sensitive:` dans la validation ne fonctionnera pas.

#### Index uniques

Pour prendre en charge les index uniques sur les colonnes chiffrées de manière déterministe, vous devez vous assurer que leur texte chiffré ne change jamais.

Pour encourager cela, les attributs déterministes utiliseront toujours le schéma de chiffrement le plus ancien disponible par défaut lorsque plusieurs schémas de chiffrement sont configurés. Sinon, il est de votre responsabilité de veiller à ce que les propriétés de chiffrement ne changent pas pour ces attributs, sinon les index uniques ne fonctionneront pas.

```ruby
class Person
  encrypts :email_address, deterministic: true
end
```

### Filtrage des paramètres nommés comme des colonnes chiffrées

Par défaut, les colonnes chiffrées sont configurées pour être [automatiquement filtrées dans les journaux Rails](action_controller_overview.html#parameters-filtering). Vous pouvez désactiver ce comportement en ajoutant ce qui suit à votre `application.rb` :

Lors de la génération du paramètre de filtrage, il utilisera le nom du modèle comme préfixe. Par exemple : pour `Person#name`, le paramètre de filtrage sera `person.name`.

```ruby
config.active_record.encryption.add_to_filter_parameters = false
```

Si vous souhaitez exclure des colonnes spécifiques de ce filtrage automatique, ajoutez-les à `config.active_record.encryption.excluded_from_filter_parameters`.

### Encodage

La bibliothèque préservera l'encodage des valeurs de chaîne chiffrées de manière non déterministe.

Étant donné que l'encodage est stocké avec la charge utile chiffrée, les valeurs chiffrées de manière déterministe forceront par défaut l'encodage UTF-8. Par conséquent, une même valeur avec un encodage différent donnera un texte chiffré différent lorsqu'il est chiffré. Vous voulez généralement éviter cela pour que les requêtes et les contraintes d'unicité fonctionnent, donc la bibliothèque effectuera automatiquement la conversion à votre place.

Vous pouvez configurer l'encodage par défaut souhaité pour le chiffrement déterministe avec :

```ruby
config.active_record.encryption.forced_encoding_for_deterministic_encryption = Encoding::US_ASCII
```

Et vous pouvez désactiver ce comportement et préserver l'encodage dans tous les cas avec :

```ruby
config.active_record.encryption.forced_encoding_for_deterministic_encryption = nil
```

## Gestion des clés

Les fournisseurs de clés mettent en œuvre des stratégies de gestion des clés. Vous pouvez configurer les fournisseurs de clés globalement ou sur une base par attribut.

### Fournisseurs de clés intégrés

#### DerivedSecretKeyProvider

Un fournisseur de clés qui fournira des clés dérivées des mots de passe fournis en utilisant PBKDF2.

```ruby
config.active_record.encryption.key_provider = ActiveRecord::Encryption::DerivedSecretKeyProvider.new(["some passwords", "to derive keys from. ", "These should be in", "credentials"])
```

NOTE : Par défaut, `active_record.encryption` configure un `DerivedSecretKeyProvider` avec les clés définies dans `active_record.encryption.primary_key`.

#### EnvelopeEncryptionKeyProvider

Implémente une stratégie simple de [chiffrement par enveloppe](https://docs.aws.amazon.com/kms/latest/developerguide/concepts.html#enveloping) :

- Il génère une clé aléatoire pour chaque opération de chiffrement des données
- Il stocke la clé de données avec les données elles-mêmes, chiffrées avec une clé principale définie dans le paramètre `active_record.encryption.primary_key` des informations d'identification.

Vous pouvez configurer Active Record pour utiliser ce fournisseur de clés en ajoutant ceci à votre `application.rb` :

```ruby
config.active_record.encryption.key_provider = ActiveRecord::Encryption::EnvelopeEncryptionKeyProvider.new
```

Comme pour les autres fournisseurs de clés intégrés, vous pouvez fournir une liste de clés principales dans `active_record.encryption.primary_key` pour mettre en œuvre des schémas de rotation des clés.
### Fournisseurs de clés personnalisés

Pour des schémas de gestion de clés plus avancés, vous pouvez configurer un fournisseur de clés personnalisé dans un initialiseur :

```ruby
ActiveRecord::Encryption.key_provider = MyKeyProvider.new
```

Un fournisseur de clés doit implémenter cette interface :

```ruby
class MyKeyProvider
  def encryption_key
  end

  def decryption_keys(encrypted_message)
  end
end
```

Les deux méthodes renvoient des objets `ActiveRecord::Encryption::Key` :

- `encryption_key` renvoie la clé utilisée pour chiffrer un contenu
- `decryption_keys` renvoie une liste de clés potentielles pour déchiffrer un message donné

Une clé peut inclure des balises arbitraires qui seront stockées en clair avec le message. Vous pouvez utiliser `ActiveRecord::Encryption::Message#headers` pour examiner ces valeurs lors du déchiffrement.

### Fournisseurs de clés spécifiques au modèle

Vous pouvez configurer un fournisseur de clés spécifique à une classe avec l'option `:key_provider` :

```ruby
class Article < ApplicationRecord
  encrypts :summary, key_provider: ArticleKeyProvider.new
end
```

### Clés spécifiques au modèle

Vous pouvez configurer une clé donnée spécifique à une classe avec l'option `:key` :

```ruby
class Article < ApplicationRecord
  encrypts :summary, key: "une clé secrète pour les résumés d'articles"
end
```

Active Record utilise la clé pour dériver la clé utilisée pour chiffrer et déchiffrer les données.

### Rotation des clés

`active_record.encryption` peut fonctionner avec des listes de clés pour prendre en charge la mise en œuvre de schémas de rotation des clés :

- La **dernière clé** sera utilisée pour chiffrer les nouveaux contenus.
- Toutes les clés seront essayées lors du déchiffrement des contenus jusqu'à ce qu'une fonctionne.

```yml
active_record_encryption:
  primary_key:
    - a1cc4d7b9f420e40a337b9e68c5ecec6 # Les clés précédentes peuvent toujours déchiffrer les contenus existants
    - bc17e7b413fd4720716a7633027f8cc4 # Active, chiffre les nouveaux contenus
  key_derivation_salt: a3226b97b3b2f8372d1fc6d497a0c0d3
```

Cela permet des flux de travail dans lesquels vous conservez une courte liste de clés en ajoutant de nouvelles clés, en rechiffrant les contenus et en supprimant les anciennes clés.

NOTE : La rotation des clés n'est actuellement pas prise en charge pour le chiffrement déterministe.

NOTE : Active Record Encryption ne fournit pas encore de gestion automatique des processus de rotation des clés. Toutes les pièces sont là, mais cela n'a pas encore été implémenté.

### Stockage des références de clés

Vous pouvez configurer `active_record.encryption.store_key_references` pour que `active_record.encryption` stocke une référence à la clé de chiffrement dans le message chiffré lui-même.

```ruby
config.active_record.encryption.store_key_references = true
```

Cela permet un déchiffrement plus performant car le système peut maintenant localiser les clés directement au lieu d'essayer des listes de clés. Le prix à payer est le stockage : les données chiffrées seront un peu plus volumineuses.

## API

### API de base

Le chiffrement ActiveRecord est destiné à être utilisé de manière déclarative, mais il offre une API pour des scénarios d'utilisation avancés.

#### Chiffrer et déchiffrer

```ruby
article.encrypt # chiffre ou rechiffre tous les attributs chiffrables
article.decrypt # déchiffre tous les attributs chiffrables
```

#### Lire le texte chiffré

```ruby
article.ciphertext_for(:title)
```

#### Vérifier si un attribut est chiffré ou non

```ruby
article.encrypted_attribute?(:title)
```

## Configuration(duplicated)

### Options de configuration

Vous pouvez configurer les options de chiffrement Active Record dans votre `application.rb` (scénario le plus courant) ou dans un fichier de configuration d'environnement spécifique `config/environments/<nom_env>.rb` si vous souhaitez les définir spécifiquement pour chaque environnement.

AVERTISSEMENT : Il est recommandé d'utiliser le support intégré des informations d'identification de Rails pour stocker les clés. Si vous préférez les définir manuellement via des propriétés de configuration, assurez-vous de ne pas les commettre avec votre code (par exemple, utilisez des variables d'environnement).

#### `config.active_record.encryption.support_unencrypted_data`

Lorsqu'il est vrai, les données non chiffrées peuvent être lues normalement. Lorsqu'il est faux, cela générera des erreurs. Par défaut : `false`.

#### `config.active_record.encryption.extend_queries`

Lorsqu'il est vrai, les requêtes faisant référence à des attributs chiffrés de manière déterministe seront modifiées pour inclure des valeurs supplémentaires si nécessaire. Ces valeurs supplémentaires seront la version non chiffrée de la valeur (lorsque `config.active_record.encryption.support_unencrypted_data` est vrai) et les valeurs chiffrées avec des schémas de chiffrement précédents, le cas échéant (telles que fournies avec l'option `previous:`). Par défaut : `false` (expérimental).

#### `config.active_record.encryption.encrypt_fixtures`

Lorsqu'il est vrai, les attributs chiffrables dans les fixtures seront automatiquement chiffrés lors du chargement. Par défaut : `false`.

#### `config.active_record.encryption.store_key_references`

Lorsqu'il est vrai, une référence à la clé de chiffrement est stockée dans les en-têtes du message chiffré. Cela permet un déchiffrement plus rapide lorsque plusieurs clés sont utilisées. Par défaut : `false`.

#### `config.active_record.encryption.add_to_filter_parameters`

Lorsqu'il est vrai, les noms d'attributs chiffrés sont automatiquement ajoutés à [`config.filter_parameters`][] et ne seront pas affichés dans les journaux. Par défaut : `true`.


#### `config.active_record.encryption.excluded_from_filter_parameters`

Vous pouvez configurer une liste de paramètres qui ne seront pas filtrés lorsque `config.active_record.encryption.add_to_filter_parameters` est vrai. Par défaut : `[]`.

#### `config.active_record.encryption.validate_column_size`

Ajoute une validation basée sur la taille de la colonne. Cela est recommandé pour éviter de stocker des valeurs énormes à l'aide de charges utiles hautement compressibles. Par défaut : `true`.

#### `config.active_record.encryption.primary_key`

La clé ou les listes de clés utilisées pour dériver les clés de chiffrement des données racines. La façon dont elles sont utilisées dépend du fournisseur de clés configuré. Il est préférable de le configurer via les informations d'identification `active_record_encryption.primary_key`.
#### `config.active_record.encryption.deterministic_key`

La clé ou la liste de clés utilisées pour le chiffrement déterministe. Il est préférable de le configurer via l'identifiant `active_record_encryption.deterministic_key`.

#### `config.active_record.encryption.key_derivation_salt`

Le sel utilisé lors de la dérivation des clés. Il est préférable de le configurer via l'identifiant `active_record_encryption.key_derivation_salt`.

#### `config.active_record.encryption.forced_encoding_for_deterministic_encryption`

L'encodage par défaut des attributs chiffrés de manière déterministe. Vous pouvez désactiver l'encodage forcé en définissant cette option sur `nil`. Par défaut, il est `Encoding::UTF_8`.

#### `config.active_record.encryption.hash_digest_class`

L'algorithme de hachage utilisé pour dériver les clés. Par défaut, c'est `OpenSSL::Digest::SHA1`.

#### `config.active_record.encryption.support_sha1_for_non_deterministic_encryption`

Prend en charge le déchiffrement des données chiffrées de manière non déterministe avec une classe de hachage SHA1. Par défaut, c'est false, ce qui signifie qu'il ne prendra en charge que l'algorithme de hachage configuré dans `config.active_record.encryption.hash_digest_class`.

### Contextes de chiffrement

Un contexte de chiffrement définit les composants de chiffrement utilisés à un moment donné. Il existe un contexte de chiffrement par défaut basé sur votre configuration globale, mais vous pouvez configurer un contexte personnalisé pour un attribut donné ou lors de l'exécution d'un bloc de code spécifique.

NOTE : Les contextes de chiffrement sont un mécanisme de configuration flexible mais avancé. La plupart des utilisateurs n'ont pas besoin de s'en préoccuper.

Les principaux composants des contextes de chiffrement sont :

* `encryptor` : expose l'API interne pour le chiffrement et le déchiffrement des données. Il interagit avec un `key_provider` pour construire des messages chiffrés et gérer leur sérialisation. Le chiffrement/déchiffrement lui-même est effectué par le `cipher` et la sérialisation par `message_serializer`.
* `cipher` : l'algorithme de chiffrement lui-même (AES 256 GCM)
* `key_provider` : fournit les clés de chiffrement et de déchiffrement.
* `message_serializer` : sérialise et désérialise les charges utiles chiffrées (`Message`).

NOTE : Si vous décidez de construire votre propre `message_serializer`, il est important d'utiliser des mécanismes sûrs qui ne peuvent pas désérialiser des objets arbitraires. Un scénario couramment pris en charge est le chiffrement de données non chiffrées existantes. Un attaquant peut exploiter cela pour entrer une charge utile falsifiée avant que le chiffrement ne se produise et effectuer des attaques RCE. Cela signifie que les sérialiseurs personnalisés doivent éviter `Marshal`, `YAML.load` (utilisez plutôt `YAML.safe_load`) ou `JSON.load` (utilisez `JSON.parse` à la place).

#### Contexte de chiffrement global

Le contexte de chiffrement global est celui utilisé par défaut et est configuré comme les autres propriétés de configuration dans votre fichier `application.rb` ou les fichiers de configuration de l'environnement.

```ruby
config.active_record.encryption.key_provider = ActiveRecord::Encryption::EnvelopeEncryptionKeyProvider.new
config.active_record.encryption.encryptor = MyEncryptor.new
```

#### Contextes de chiffrement par attribut

Vous pouvez remplacer les paramètres du contexte de chiffrement en les passant dans la déclaration de l'attribut :

```ruby
class Attribute
  encrypts :title, encryptor: MyAttributeEncryptor.new
end
```

#### Contexte de chiffrement lors de l'exécution d'un bloc de code

Vous pouvez utiliser `ActiveRecord::Encryption.with_encryption_context` pour définir un contexte de chiffrement pour un bloc de code donné :

```ruby
ActiveRecord::Encryption.with_encryption_context(encryptor: ActiveRecord::Encryption::NullEncryptor.new) do
  ...
end
```

#### Contextes de chiffrement intégrés

##### Désactiver le chiffrement

Vous pouvez exécuter du code sans chiffrement :

```ruby
ActiveRecord::Encryption.without_encryption do
   ...
end
```

Cela signifie que la lecture du texte chiffré renverra le texte chiffré, et le contenu enregistré sera stocké non chiffré.

##### Protéger les données chiffrées

Vous pouvez exécuter du code sans chiffrement mais empêcher la modification du contenu chiffré :

```ruby
ActiveRecord::Encryption.protecting_encrypted_data do
   ...
end
```

Cela peut être pratique si vous souhaitez protéger les données chiffrées tout en exécutant un code arbitraire contre elles (par exemple, dans une console Rails).
[`config.filter_parameters`]: configuring.html#config-filter-parameters
