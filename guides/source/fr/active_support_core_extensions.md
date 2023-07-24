**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: fdd2e5c41171c61b555549ced4d68a82
Extensions de base d'Active Support
===================================

Active Support est le composant de Ruby on Rails chargé de fournir des extensions et des utilitaires au langage Ruby.

Il offre une base plus riche au niveau du langage, destinée à la fois au développement d'applications Rails et au développement de Ruby on Rails lui-même.

Après avoir lu ce guide, vous saurez :

* Ce que sont les extensions de base.
* Comment charger toutes les extensions.
* Comment sélectionner uniquement les extensions souhaitées.
* Quelles extensions Active Support propose.

--------------------------------------------------------------------------------

Comment charger les extensions de base
-------------------------------------

### Active Support autonome

Afin d'avoir la plus petite empreinte possible par défaut, Active Support charge les dépendances minimales par défaut. Il est divisé en petites parties de sorte que seules les extensions souhaitées peuvent être chargées. Il dispose également de points d'entrée pratiques pour charger des extensions connexes en une seule fois, voire tout charger.

Ainsi, après un simple require comme :

```ruby
require "active_support"
```

seules les extensions requises par le framework Active Support sont chargées.

#### Sélectionner une définition

Cet exemple montre comment charger [`Hash#with_indifferent_access`][Hash#with_indifferent_access]. Cette extension permet de convertir un `Hash` en [`ActiveSupport::HashWithIndifferentAccess`][ActiveSupport::HashWithIndifferentAccess] qui permet d'accéder aux clés sous forme de chaînes de caractères ou de symboles.

```ruby
{ a: 1 }.with_indifferent_access["a"] # => 1
```

Pour chaque méthode définie en tant qu'extension de base, ce guide comporte une note indiquant où cette méthode est définie. Dans le cas de `with_indifferent_access`, la note indique :

NOTE : Défini dans `active_support/core_ext/hash/indifferent_access.rb`.

Cela signifie que vous pouvez le requérir de cette manière :

```ruby
require "active_support"
require "active_support/core_ext/hash/indifferent_access"
```

Active Support a été soigneusement révisé de sorte que le chargement d'un fichier ne charge que les dépendances strictement nécessaires, le cas échéant.

#### Charger les extensions de base groupées

Le niveau suivant consiste simplement à charger toutes les extensions de `Hash`. En règle générale, les extensions de `SomeClass` sont disponibles en une seule fois en chargeant `active_support/core_ext/some_class`.

Ainsi, pour charger toutes les extensions de `Hash` (y compris `with_indifferent_access`) :

```ruby
require "active_support"
require "active_support/core_ext/hash"
```

#### Charger toutes les extensions de base

Vous pouvez préférer charger simplement toutes les extensions de base, il existe un fichier à cet effet :

```ruby
require "active_support"
require "active_support/core_ext"
```

#### Charger tout Active Support

Et enfin, si vous voulez avoir tout Active Support disponible, il suffit de faire :

```ruby
require "active_support/all"
```

Cela ne met même pas tout Active Support en mémoire dès le départ, en effet, certaines choses sont configurées via `autoload`, donc elles ne sont chargées que si elles sont utilisées.

### Active Support dans une application Ruby on Rails

Une application Ruby on Rails charge tout Active Support à moins que [`config.active_support.bare`][] ne soit vrai. Dans ce cas, l'application ne chargera que ce que le framework lui-même sélectionne pour ses propres besoins, et peut toujours se sélectionner elle-même à n'importe quel niveau de granularité, comme expliqué dans la section précédente.


Extensions pour tous les objets
-------------------------------

### `blank?` et `present?`

Les valeurs suivantes sont considérées comme vides dans une application Rails :

* `nil` et `false`,

* les chaînes de caractères composées uniquement d'espaces (voir la note ci-dessous),

* les tableaux et les hachages vides, et

* tout autre objet qui répond à `empty?` et est vide.

INFO : Le prédicat pour les chaînes de caractères utilise la classe de caractères Unicode `[:space:]`, donc par exemple U+2029 (séparateur de paragraphe) est considéré comme un espace.

AVERTISSEMENT : Notez que les nombres ne sont pas mentionnés. En particulier, 0 et 0.0 ne sont **pas** vides.

Par exemple, cette méthode de `ActionController::HttpAuthentication::Token::ControllerMethods` utilise [`blank?`][Object#blank?] pour vérifier si un jeton est présent :

```ruby
def authenticate(controller, &login_procedure)
  token, options = token_and_options(controller.request)
  unless token.blank?
    login_procedure.call(token, options)
  end
end
```

La méthode [`present?`][Object#present?] est équivalente à `!blank?`. Cet exemple est tiré de `ActionDispatch::Http::Cache::Response` :

```ruby
def set_conditional_cache_control!
  return if self["Cache-Control"].present?
  # ...
end
```

NOTE : Défini dans `active_support/core_ext/object/blank.rb`.


### `presence`

La méthode [`presence`][Object#presence] renvoie son receveur s'il est `present?`, et `nil` sinon. Elle est utile pour des idiomes comme celui-ci :

```ruby
host = config[:host].presence || 'localhost'
```

NOTE : Défini dans `active_support/core_ext/object/blank.rb`.


### `duplicable?`

À partir de Ruby 2.5, la plupart des objets peuvent être dupliqués via `dup` ou `clone` :

```ruby
"foo".dup           # => "foo"
"".dup              # => ""
Rational(1).dup     # => (1/1)
Complex(0).dup      # => (0+0i)
1.method(:+).dup    # => TypeError (allocator undefined for Method)
```

Active Support fournit [`duplicable?`][Object#duplicable?] pour interroger un objet à ce sujet :

```ruby
"foo".duplicable?           # => true
"".duplicable?              # => true
Rational(1).duplicable?     # => true
Complex(1).duplicable?      # => true
1.method(:+).duplicable?    # => false
```

AVERTISSEMENT : N'importe quelle classe peut interdire la duplication en supprimant `dup` et `clone` ou en levant des exceptions à partir d'eux. Ainsi, seul `rescue` peut dire si un objet arbitraire donné peut être dupliqué. `duplicable?` dépend de la liste codée en dur ci-dessus, mais il est beaucoup plus rapide que `rescue`. Utilisez-le uniquement si vous savez que la liste codée en dur est suffisante dans votre cas d'utilisation.
NOTE: Défini dans `active_support/core_ext/object/duplicable.rb`.


### `deep_dup`

La méthode [`deep_dup`][Object#deep_dup] renvoie une copie en profondeur d'un objet donné. Normalement, lorsque vous dupliquez un objet qui contient d'autres objets, Ruby ne les duplique pas, il crée donc une copie superficielle de l'objet. Si vous avez par exemple un tableau avec une chaîne de caractères, cela ressemblera à ceci :

```ruby
array     = ['chaîne']
duplicate = array.dup

duplicate.push 'autre-chaîne'

# l'objet a été dupliqué, donc l'élément a été ajouté uniquement à la copie
array     # => ['chaîne']
duplicate # => ['chaîne', 'autre-chaîne']

duplicate.first.gsub!('chaîne', 'foo')

# le premier élément n'a pas été dupliqué, il sera modifié dans les deux tableaux
array     # => ['foo']
duplicate # => ['foo', 'autre-chaîne']
```

Comme vous pouvez le voir, après avoir dupliqué l'instance de `Array`, nous avons obtenu un autre objet, donc nous pouvons le modifier et l'objet original restera inchangé. Cependant, cela n'est pas vrai pour les éléments du tableau. Étant donné que `dup` ne fait pas de copie en profondeur, la chaîne de caractères à l'intérieur du tableau est toujours le même objet.

Si vous avez besoin d'une copie en profondeur d'un objet, vous devriez utiliser `deep_dup`. Voici un exemple :

```ruby
array     = ['chaîne']
duplicate = array.deep_dup

duplicate.first.gsub!('chaîne', 'foo')

array     # => ['chaîne']
duplicate # => ['foo']
```

Si l'objet ne peut pas être dupliqué, `deep_dup` le renverra simplement :

```ruby
number = 1
duplicate = number.deep_dup
number.object_id == duplicate.object_id   # => true
```

NOTE: Défini dans `active_support/core_ext/object/deep_dup.rb`.


### `try`

Lorsque vous voulez appeler une méthode sur un objet uniquement s'il n'est pas `nil`, la façon la plus simple de le faire est d'utiliser des instructions conditionnelles, ce qui ajoute un encombrement inutile. L'alternative est d'utiliser [`try`][Object#try]. `try` est similaire à `Object#public_send`, sauf qu'il renvoie `nil` s'il est envoyé à `nil`.

Voici un exemple :

```ruby
# sans try
unless @number.nil?
  @number.next
end

# avec try
@number.try(:next)
```

Un autre exemple est ce code de `ActiveRecord::ConnectionAdapters::AbstractAdapter` où `@logger` pourrait être `nil`. Vous pouvez voir que le code utilise `try` et évite une vérification inutile.

```ruby
def log_info(sql, name, ms)
  if @logger.try(:debug?)
    name = '%s (%.1fms)' % [name || 'SQL', ms]
    @logger.debug(format_log_entry(name, sql.squeeze(' ')))
  end
end
```

`try` peut également être appelé sans arguments mais avec un bloc, qui ne sera exécuté que si l'objet n'est pas nul :

```ruby
@person.try { |p| "#{p.first_name} #{p.last_name}" }
```

Notez que `try` va masquer les erreurs de méthode inexistante, renvoyant à la place `nil`. Si vous voulez vous protéger contre les fautes de frappe, utilisez [`try!`][Object#try!] à la place :

```ruby
@number.try(:nest)  # => nil
@number.try!(:nest) # NoMethodError: undefined method `nest' for 1:Integer
```

NOTE: Défini dans `active_support/core_ext/object/try.rb`.


### `class_eval(*args, &block)`

Vous pouvez évaluer du code dans le contexte de la classe singleton de n'importe quel objet en utilisant [`class_eval`][Kernel#class_eval] :

```ruby
class Proc
  def bind(object)
    block, time = self, Time.current
    object.class_eval do
      method_name = "__bind_#{time.to_i}_#{time.usec}"
      define_method(method_name, &block)
      method = instance_method(method_name)
      remove_method(method_name)
      method
    end.bind(object)
  end
end
```

NOTE: Défini dans `active_support/core_ext/kernel/singleton_class.rb`.


### `acts_like?(duck)`

La méthode [`acts_like?`][Object#acts_like?] permet de vérifier si une classe se comporte comme une autre classe en se basant sur une simple convention : une classe qui fournit la même interface que `String` définit

```ruby
def acts_like_string?
end
```

qui n'est qu'un marqueur, son corps ou sa valeur de retour sont sans importance. Ensuite, le code client peut interroger cette conformité de type canard de cette manière :

```ruby
some_klass.acts_like?(:string)
```

Rails a des classes qui se comportent comme `Date` ou `Time` et qui suivent ce contrat.

NOTE: Défini dans `active_support/core_ext/object/acts_like.rb`.


### `to_param`

Tous les objets dans Rails répondent à la méthode [`to_param`][Object#to_param], qui est censée renvoyer quelque chose qui les représente comme des valeurs dans une chaîne de requête, ou comme des fragments d'URL.

Par défaut, `to_param` appelle simplement `to_s` :

```ruby
7.to_param # => "7"
```

La valeur de retour de `to_param` ne doit **pas** être échappée :

```ruby
"Tom & Jerry".to_param # => "Tom & Jerry"
```

Plusieurs classes dans Rails redéfinissent cette méthode.

Par exemple, `nil`, `true` et `false` renvoient eux-mêmes. [`Array#to_param`][Array#to_param] appelle `to_param` sur les éléments et les joint avec "/":

```ruby
[0, true, String].to_param # => "0/true/String"
```

Il est important de noter que le système de routage de Rails appelle `to_param` sur les modèles pour obtenir une valeur pour le paramètre `:id`. `ActiveRecord::Base#to_param` renvoie l'`id` d'un modèle, mais vous pouvez redéfinir cette méthode dans vos modèles. Par exemple, avec :

```ruby
class User
  def to_param
    "#{id}-#{name.parameterize}"
  end
end
```

nous obtenons :

```ruby
user_path(@user) # => "/users/357-john-smith"
```

ATTENTION. Les contrôleurs doivent être conscients de toute redéfinition de `to_param` car lorsque cette requête arrive, "357-john-smith" est la valeur de `params[:id]`.
NOTE: Défini dans `active_support/core_ext/object/to_param.rb`.


### `to_query`

La méthode [`to_query`][Object#to_query] construit une chaîne de requête qui associe une clé donnée avec la valeur de retour de `to_param`. Par exemple, avec la définition `to_param` suivante :

```ruby
class User
  def to_param
    "#{id}-#{name.parameterize}"
  end
end
```

nous obtenons :

```ruby
current_user.to_query('user') # => "user=357-john-smith"
```

Cette méthode échappe tout ce qui est nécessaire, à la fois pour la clé et pour la valeur :

```ruby
account.to_query('company[name]')
# => "company%5Bname%5D=Johnson+%26+Johnson"
```

donc sa sortie est prête à être utilisée dans une chaîne de requête.

Les tableaux renvoient le résultat de l'application de `to_query` à chaque élément avec `key[]` comme clé, et joignent le résultat avec "&" :

```ruby
[3.4, -45.6].to_query('sample')
# => "sample%5B%5D=3.4&sample%5B%5D=-45.6"
```

Les hachages répondent également à `to_query` mais avec une signature différente. Si aucun argument n'est passé, un appel génère une série triée d'assignations clé/valeur en appelant `to_query(key)` sur ses valeurs. Ensuite, il joint le résultat avec "&" :

```ruby
{ c: 3, b: 2, a: 1 }.to_query # => "a=1&b=2&c=3"
```

La méthode [`Hash#to_query`][Hash#to_query] accepte un espace de noms facultatif pour les clés :

```ruby
{ id: 89, name: "John Smith" }.to_query('user')
# => "user%5Bid%5D=89&user%5Bname%5D=John+Smith"
```

NOTE: Défini dans `active_support/core_ext/object/to_query.rb`.


### `with_options`

La méthode [`with_options`][Object#with_options] permet de regrouper des options communes dans une série d'appels de méthode.

Étant donné un hachage d'options par défaut, `with_options` renvoie un objet proxy à un bloc. Dans le bloc, les méthodes appelées sur le proxy sont transmises au receveur avec leurs options fusionnées. Par exemple, vous pouvez vous débarrasser de la duplication dans :

```ruby
class Account < ApplicationRecord
  has_many :customers, dependent: :destroy
  has_many :products,  dependent: :destroy
  has_many :invoices,  dependent: :destroy
  has_many :expenses,  dependent: :destroy
end
```

de cette façon :

```ruby
class Account < ApplicationRecord
  with_options dependent: :destroy do |assoc|
    assoc.has_many :customers
    assoc.has_many :products
    assoc.has_many :invoices
    assoc.has_many :expenses
  end
end
```

Cette idiomatique peut également transmettre un regroupement au lecteur. Par exemple, supposons que vous souhaitiez envoyer une newsletter dont la langue dépend de l'utilisateur. Vous pouvez regrouper les éléments dépendant de la langue quelque part dans le mailer de cette façon :

```ruby
I18n.with_options locale: user.locale, scope: "newsletter" do |i18n|
  subject i18n.t :subject
  body    i18n.t :body, user_name: user.name
end
```

CONSEIL : Comme `with_options` transmet les appels à son receveur, ils peuvent être imbriqués. Chaque niveau d'imbrication fusionnera les valeurs par défaut héritées en plus des leurs propres.

NOTE: Défini dans `active_support/core_ext/object/with_options.rb`.


### Support JSON

Active Support fournit une meilleure implémentation de `to_json` que la gemme `json` ne le fait normalement pour les objets Ruby. Cela est dû au fait que certaines classes, comme `Hash` et `Process::Status`, nécessitent un traitement spécial pour fournir une représentation JSON appropriée.

NOTE: Défini dans `active_support/core_ext/object/json.rb`.

### Variables d'instance

Active Support fournit plusieurs méthodes pour faciliter l'accès aux variables d'instance.

#### `instance_values`

La méthode [`instance_values`][Object#instance_values] renvoie un hachage qui associe les noms des variables d'instance sans "@" à leurs valeurs correspondantes. Les clés sont des chaînes de caractères :

```ruby
class C
  def initialize(x, y)
    @x, @y = x, y
  end
end

C.new(0, 1).instance_values # => {"x" => 0, "y" => 1}
```

NOTE: Défini dans `active_support/core_ext/object/instance_variables.rb`.


#### `instance_variable_names`

La méthode [`instance_variable_names`][Object#instance_variable_names] renvoie un tableau. Chaque nom inclut le signe "@".

```ruby
class C
  def initialize(x, y)
    @x, @y = x, y
  end
end

C.new(0, 1).instance_variable_names # => ["@x", "@y"]
```

NOTE: Défini dans `active_support/core_ext/object/instance_variables.rb`.


### Silencing Warnings and Exceptions

Les méthodes [`silence_warnings`][Kernel#silence_warnings] et [`enable_warnings`][Kernel#enable_warnings] modifient la valeur de `$VERBOSE` en conséquence pendant la durée de leur bloc, puis la réinitialisent :

```ruby
silence_warnings { Object.const_set "RAILS_DEFAULT_LOGGER", logger }
```

Il est également possible de supprimer les exceptions avec [`suppress`][Kernel#suppress]. Cette méthode reçoit un nombre arbitraire de classes d'exceptions. Si une exception est levée pendant l'exécution du bloc et qu'elle est `kind_of?` l'un des arguments, `suppress` la capture et la renvoie silencieusement. Sinon, l'exception n'est pas capturée :

```ruby
# Si l'utilisateur est verrouillé, l'incrémentation est perdue, pas de problème majeur.
suppress(ActiveRecord::StaleObjectError) do
  current_user.increment! :visits
end
```

NOTE: Défini dans `active_support/core_ext/kernel/reporting.rb`.


### `in?`

Le prédicat [`in?`][Object#in?] teste si un objet est inclus dans un autre objet. Une exception `ArgumentError` sera levée si l'argument passé ne répond pas à `include?`.

Exemples de `in?` :

```ruby
1.in?([1, 2])        # => true
"lo".in?("hello")   # => true
25.in?(30..50)      # => false
1.in?(1)            # => ArgumentError
```

NOTE: Défini dans `active_support/core_ext/object/inclusion.rb`.


Extensions à `Module`
----------------------

### Attributs

#### `alias_attribute`

Les attributs du modèle ont un lecteur, un écrivain et un prédicat. Vous pouvez créer un alias pour un attribut du modèle en utilisant [`alias_attribute`][Module#alias_attribute]. Comme dans les autres méthodes d'aliasing, le nouveau nom est le premier argument, et l'ancien nom est le deuxième (une mnémonique est qu'ils vont dans le même ordre que si vous faisiez une affectation) :
```ruby
class User < ApplicationRecord
  # Vous pouvez vous référer à la colonne email en tant que "login".
  # Cela peut être significatif pour le code d'authentification.
  alias_attribute :login, :email
end
```

NOTE: Défini dans `active_support/core_ext/module/aliasing.rb`.


#### Attributs internes

Lorsque vous définissez un attribut dans une classe destinée à être sous-classée, les collisions de noms sont un risque. C'est particulièrement important pour les bibliothèques.

Active Support définit les macros [`attr_internal_reader`][Module#attr_internal_reader], [`attr_internal_writer`][Module#attr_internal_writer] et [`attr_internal_accessor`][Module#attr_internal_accessor]. Elles fonctionnent comme leurs homologues Ruby `attr_*`, à la différence qu'elles nomment la variable d'instance sous-jacente de manière à réduire les risques de collision.

La macro [`attr_internal`][Module#attr_internal] est un synonyme de `attr_internal_accessor` :

```ruby
# bibliothèque
class ThirdPartyLibrary::Crawler
  attr_internal :log_level
end

# code client
class MyCrawler < ThirdPartyLibrary::Crawler
  attr_accessor :log_level
end
```

Dans l'exemple précédent, il se peut que `:log_level` n'appartienne pas à l'interface publique de la bibliothèque et qu'il ne soit utilisé que pour le développement. Le code client, ignorant le conflit potentiel, sous-classe et définit son propre `:log_level`. Grâce à `attr_internal`, il n'y a pas de collision.

Par défaut, la variable d'instance interne est nommée avec un tiret bas en préfixe, `@_log_level` dans l'exemple ci-dessus. Cela peut être configuré via `Module.attr_internal_naming_format`, vous pouvez passer n'importe quelle chaîne de format `sprintf` avec un `@` en préfixe et un `%s` quelque part, où le nom sera placé. La valeur par défaut est `"@_%s"`.

Rails utilise des attributs internes à quelques endroits, par exemple pour les vues :

```ruby
module ActionView
  class Base
    attr_internal :captures
    attr_internal :request, :layout
    attr_internal :controller, :template
  end
end
```

NOTE: Défini dans `active_support/core_ext/module/attr_internal.rb`.


#### Attributs de module

Les macros [`mattr_reader`][Module#mattr_reader], [`mattr_writer`][Module#mattr_writer] et [`mattr_accessor`][Module#mattr_accessor] sont identiques aux macros `cattr_*` définies pour les classes. En fait, les macros `cattr_*` ne sont que des alias des macros `mattr_*`. Voir [Attributs de classe](#attributs-de-classe).

Par exemple, l'API du journal de Active Storage est générée avec `mattr_accessor` :

```ruby
module ActiveStorage
  mattr_accessor :logger
end
```

NOTE: Défini dans `active_support/core_ext/module/attribute_accessors.rb`.


### Parents

#### `module_parent`

La méthode [`module_parent`][Module#module_parent] sur un module nommé imbriqué renvoie le module qui contient sa constante correspondante :

```ruby
module X
  module Y
    module Z
    end
  end
end
M = X::Y::Z

X::Y::Z.module_parent # => X::Y
M.module_parent       # => X::Y
```

Si le module est anonyme ou appartient au niveau supérieur, `module_parent` renvoie `Object`.

ATTENTION : Notez que dans ce cas, `module_parent_name` renvoie `nil`.

NOTE: Défini dans `active_support/core_ext/module/introspection.rb`.


#### `module_parent_name`

La méthode [`module_parent_name`][Module#module_parent_name] sur un module nommé imbriqué renvoie le nom entièrement qualifié du module qui contient sa constante correspondante :

```ruby
module X
  module Y
    module Z
    end
  end
end
M = X::Y::Z

X::Y::Z.module_parent_name # => "X::Y"
M.module_parent_name       # => "X::Y"
```

Pour les modules de niveau supérieur ou anonymes, `module_parent_name` renvoie `nil`.

ATTENTION : Notez que dans ce cas, `module_parent` renvoie `Object`.

NOTE: Défini dans `active_support/core_ext/module/introspection.rb`.


#### `module_parents`

La méthode [`module_parents`][Module#module_parents] appelle `module_parent` sur le receveur et remonte jusqu'à atteindre `Object`. La chaîne est renvoyée dans un tableau, du bas vers le haut :

```ruby
module X
  module Y
    module Z
    end
  end
end
M = X::Y::Z

X::Y::Z.module_parents # => [X::Y, X, Object]
M.module_parents       # => [X::Y, X, Object]
```

NOTE: Défini dans `active_support/core_ext/module/introspection.rb`.


### Anonyme

Un module peut avoir ou non un nom :

```ruby
module M
end
M.name # => "M"

N = Module.new
N.name # => "N"

Module.new.name # => nil
```

Vous pouvez vérifier si un module a un nom avec le prédicat [`anonymous?`][Module#anonymous?] :

```ruby
module M
end
M.anonymous? # => false

Module.new.anonymous? # => true
```

Notez que le fait d'être inaccessible n'implique pas d'être anonyme :

```ruby
module M
end

m = Object.send(:remove_const, :M)

m.anonymous? # => false
```

bien qu'un module anonyme soit inaccessible par définition.

NOTE: Défini dans `active_support/core_ext/module/anonymous.rb`.


### Délégation de méthode

#### `delegate`

La macro [`delegate`][Module#delegate] offre un moyen simple de transférer des méthodes.

Imaginons que les utilisateurs dans une application aient des informations de connexion dans le modèle `User`, mais que le nom et d'autres données soient dans un modèle `Profile` distinct :

```ruby
class User < ApplicationRecord
  has_one :profile
end
```

Avec cette configuration, vous obtenez le nom d'un utilisateur via son profil, `user.profile.name`, mais il pourrait être pratique de pouvoir accéder directement à cet attribut :

```ruby
class User < ApplicationRecord
  has_one :profile

  def name
    profile.name
  end
end
```

C'est ce que fait `delegate` pour vous :

```ruby
class User < ApplicationRecord
  has_one :profile

  delegate :name, to: :profile
end
```

C'est plus court et l'intention est plus évidente.
La méthode doit être publique dans la cible.

La macro `delegate` accepte plusieurs méthodes :

```ruby
delegate :name, :age, :address, :twitter, to: :profile
```

Lorsqu'elle est interpolée dans une chaîne, l'option `:to` doit devenir une expression qui évalue à l'objet auquel la méthode est déléguée. Typiquement une chaîne de caractères ou un symbole. Une telle expression est évaluée dans le contexte du receveur :

```ruby
# délègue à la constante Rails
delegate :logger, to: :Rails

# délègue à la classe du receveur
delegate :table_name, to: :class
```

AVERTISSEMENT : Si l'option `:prefix` est `true`, cela est moins générique, voir ci-dessous.

Par défaut, si la délégation génère une `NoMethodError` et que la cible est `nil`, l'exception est propagée. Vous pouvez demander que `nil` soit renvoyé à la place avec l'option `:allow_nil` :

```ruby
delegate :name, to: :profile, allow_nil: true
```

Avec `:allow_nil`, l'appel `user.name` renvoie `nil` si l'utilisateur n'a pas de profil.

L'option `:prefix` ajoute un préfixe au nom de la méthode générée. Cela peut être pratique, par exemple, pour obtenir un meilleur nom :

```ruby
delegate :street, to: :address, prefix: true
```

L'exemple précédent génère `address_street` plutôt que `street`.

AVERTISSEMENT : Dans ce cas, le nom de la méthode générée est composé des noms de l'objet cible et de la méthode cible, l'option `:to` doit donc être un nom de méthode.

Un préfixe personnalisé peut également être configuré :

```ruby
delegate :size, to: :attachment, prefix: :avatar
```

Dans l'exemple précédent, la macro génère `avatar_size` plutôt que `size`.

L'option `:private` change la portée des méthodes :

```ruby
delegate :date_of_birth, to: :profile, private: true
```

Les méthodes déléguées sont publiques par défaut. Passez `private: true` pour changer cela.

NOTE : Défini dans `active_support/core_ext/module/delegation.rb`


#### `delegate_missing_to`

Imaginez que vous souhaitez déléguer tout ce qui manque à l'objet `User` à l'objet `Profile`. La macro [`delegate_missing_to`][Module#delegate_missing_to] vous permet de mettre en œuvre cela en un clin d'œil :

```ruby
class User < ApplicationRecord
  has_one :profile

  delegate_missing_to :profile
end
```

La cible peut être n'importe quoi d'appelable dans l'objet, par exemple des variables d'instance, des méthodes, des constantes, etc. Seules les méthodes publiques de la cible sont déléguées.

NOTE : Défini dans `active_support/core_ext/module/delegation.rb`.


### Redéfinition des méthodes

Il y a des cas où vous devez définir une méthode avec `define_method`, mais vous ne savez pas si une méthode avec ce nom existe déjà. Si c'est le cas, un avertissement est émis si elles sont activées. Ce n'est pas très grave, mais ce n'est pas propre non plus.

La méthode [`redefine_method`][Module#redefine_method] évite un tel avertissement potentiel, en supprimant la méthode existante si nécessaire.

Vous pouvez également utiliser [`silence_redefinition_of_method`][Module#silence_redefinition_of_method] si vous avez besoin de définir la méthode de remplacement vous-même (parce que vous utilisez `delegate`, par exemple).

NOTE : Défini dans `active_support/core_ext/module/redefine_method.rb`.


Extensions à `Class`
---------------------

### Attributs de classe

#### `class_attribute`

La méthode [`class_attribute`][Class#class_attribute] déclare un ou plusieurs attributs de classe héritables qui peuvent être redéfinis à n'importe quel niveau de la hiérarchie.

```ruby
class A
  class_attribute :x
end

class B < A; end

class C < B; end

A.x = :a
B.x # => :a
C.x # => :a

B.x = :b
A.x # => :a
C.x # => :b

C.x = :c
A.x # => :a
B.x # => :b
```

Par exemple, `ActionMailer::Base` définit :

```ruby
class_attribute :default_params
self.default_params = {
  mime_version: "1.0",
  charset: "UTF-8",
  content_type: "text/plain",
  parts_order: [ "text/plain", "text/enriched", "text/html" ]
}.freeze
```

Ils peuvent également être accédés et redéfinis au niveau de l'instance.

```ruby
A.x = 1

a1 = A.new
a2 = A.new
a2.x = 2

a1.x # => 1, provient de A
a2.x # => 2, redéfini dans a2
```

La génération de la méthode d'instance en écriture peut être empêchée en définissant l'option `:instance_writer` sur `false`.

```ruby
module ActiveRecord
  class Base
    class_attribute :table_name_prefix, instance_writer: false, default: "my"
  end
end
```

Un modèle peut trouver cette option utile comme moyen d'empêcher l'assignation en masse de définir l'attribut.

La génération de la méthode d'instance en lecture peut être empêchée en définissant l'option `:instance_reader` sur `false`.

```ruby
class A
  class_attribute :x, instance_reader: false
end

A.new.x = 1
A.new.x # NoMethodError
```

Pour plus de commodité, `class_attribute` définit également un prédicat d'instance qui est la double négation de ce que renvoie la méthode de lecture d'instance. Dans les exemples ci-dessus, il s'appellerait `x?`.

Lorsque `:instance_reader` est `false`, le prédicat d'instance renvoie une `NoMethodError` comme la méthode de lecture.

Si vous ne voulez pas du prédicat d'instance, passez `instance_predicate: false` et il ne sera pas défini.
NOTE: Défini dans `active_support/core_ext/class/attribute.rb`.


#### `cattr_reader`, `cattr_writer` et `cattr_accessor`

Les macros [`cattr_reader`][Module#cattr_reader], [`cattr_writer`][Module#cattr_writer] et [`cattr_accessor`][Module#cattr_accessor] sont analogues à leurs homologues `attr_*` mais pour les classes. Elles initialisent une variable de classe à `nil` sauf si elle existe déjà, et génèrent les méthodes de classe correspondantes pour y accéder :

```ruby
class MysqlAdapter < AbstractAdapter
  # Génère les méthodes de classe pour accéder à @@emulate_booleans.
  cattr_accessor :emulate_booleans
end
```

De plus, vous pouvez passer un bloc à `cattr_*` pour configurer l'attribut avec une valeur par défaut :

```ruby
class MysqlAdapter < AbstractAdapter
  # Génère les méthodes de classe pour accéder à @@emulate_booleans avec une valeur par défaut de true.
  cattr_accessor :emulate_booleans, default: true
end
```

Des méthodes d'instance sont également créées pour plus de commodité, ce sont simplement des proxies vers l'attribut de classe. Ainsi, les instances peuvent modifier l'attribut de classe, mais ne peuvent pas le remplacer comme c'est le cas avec `class_attribute` (voir ci-dessus). Par exemple, étant donné

```ruby
module ActionView
  class Base
    cattr_accessor :field_error_proc, default: Proc.new { ... }
  end
end
```

nous pouvons accéder à `field_error_proc` dans les vues.

La génération de la méthode d'instance de lecture peut être empêchée en définissant `:instance_reader` sur `false` et la génération de la méthode d'instance d'écriture peut être empêchée en définissant `:instance_writer` sur `false`. La génération des deux méthodes peut être empêchée en définissant `:instance_accessor` sur `false`. Dans tous les cas, la valeur doit être exactement `false` et non une fausse valeur quelconque.

```ruby
module A
  class B
    # Aucune méthode d'instance first_name n'est générée.
    cattr_accessor :first_name, instance_reader: false
    # Aucune méthode d'instance last_name= n'est générée.
    cattr_accessor :last_name, instance_writer: false
    # Aucune méthode d'instance surname ni de méthode surname= n'est générée.
    cattr_accessor :surname, instance_accessor: false
  end
end
```

Un modèle peut trouver utile de définir `:instance_accessor` sur `false` comme moyen d'empêcher l'assignation en masse de définir l'attribut.

NOTE: Défini dans `active_support/core_ext/module/attribute_accessors.rb`.


### Sous-classes et descendants

#### `subclasses`

La méthode [`subclasses`][Class#subclasses] renvoie les sous-classes du receveur :

```ruby
class C; end
C.subclasses # => []

class B < C; end
C.subclasses # => [B]

class A < B; end
C.subclasses # => [B]

class D < C; end
C.subclasses # => [B, D]
```

L'ordre dans lequel ces classes sont renvoyées n'est pas spécifié.

NOTE: Défini dans `active_support/core_ext/class/subclasses.rb`.


#### `descendants`

La méthode [`descendants`][Class#descendants] renvoie toutes les classes qui sont `<` que son receveur :

```ruby
class C; end
C.descendants # => []

class B < C; end
C.descendants # => [B]

class A < B; end
C.descendants # => [B, A]

class D < C; end
C.descendants # => [B, A, D]
```

L'ordre dans lequel ces classes sont renvoyées n'est pas spécifié.

NOTE: Défini dans `active_support/core_ext/class/subclasses.rb`.


Extensions à `String`
----------------------

### Sécurité de la sortie

#### Motivation

Insérer des données dans des modèles HTML nécessite une attention particulière. Par exemple, vous ne pouvez pas simplement interpoler `@review.title` tel quel dans une page HTML. Pour une chose, si le titre de la revue est "Flanagan & Matz rules!", la sortie ne sera pas bien formée car un esperluette doit être échappée en "&amp;amp;". De plus, selon l'application, cela peut constituer une grande faille de sécurité car les utilisateurs peuvent injecter du HTML malveillant en définissant un titre de revue spécialement conçu. Consultez la section sur les attaques de type cross-site scripting dans le [guide de sécurité](security.html#cross-site-scripting-xss) pour plus d'informations sur les risques.

#### Chaînes sûres

Active Support a le concept de chaînes _(html) safe_. Une chaîne sûre est une chaîne marquée comme pouvant être insérée dans du HTML telle quelle. Elle est considérée comme fiable, que son échappement ait été effectué ou non.

Les chaînes sont considérées comme _non sûres_ par défaut :

```ruby
"".html_safe? # => false
```

Vous pouvez obtenir une chaîne sûre à partir d'une chaîne donnée avec la méthode [`html_safe`][String#html_safe] :

```ruby
s = "".html_safe
s.html_safe? # => true
```

Il est important de comprendre que `html_safe` n'effectue aucun échappement, c'est simplement une assertion :

```ruby
s = "<script>...</script>".html_safe
s.html_safe? # => true
s            # => "<script>...</script>"
```

Il est de votre responsabilité de vous assurer que l'appel à `html_safe` sur une chaîne particulière est correct.

Si vous ajoutez une chaîne sûre, soit en place avec `concat`/`<<`, soit avec `+`, le résultat est une chaîne sûre. Les arguments non sûrs sont échappés :

```ruby
"".html_safe + "<" # => "&lt;"
```

Les arguments sûrs sont directement ajoutés :

```ruby
"".html_safe + "<".html_safe # => "<"
```

Ces méthodes ne doivent pas être utilisées dans les vues ordinaires. Les valeurs non sûres sont automatiquement échappées :

```erb
<%= @review.title %> <%# bien, échappé si nécessaire %>
```
Pour insérer quelque chose tel quel, utilisez l'aide [`raw`][] plutôt que d'appeler `html_safe` :

```erb
<%= raw @cms.current_template %> <%# insère @cms.current_template tel quel %>
```

ou, de manière équivalente, utilisez `<%==` :

```erb
<%== @cms.current_template %> <%# insère @cms.current_template tel quel %>
```

L'aide `raw` appelle `html_safe` pour vous :

```ruby
def raw(stringish)
  stringish.to_s.html_safe
end
```

NOTE : Défini dans `active_support/core_ext/string/output_safety.rb`.


#### Transformation

En règle générale, sauf peut-être pour la concaténation comme expliqué ci-dessus, toute méthode qui peut modifier une chaîne vous donne une chaîne non sécurisée. Ce sont `downcase`, `gsub`, `strip`, `chomp`, `underscore`, etc.

Dans le cas des transformations en place comme `gsub!`, le receveur lui-même devient non sécurisé.

INFO : Le bit de sécurité est toujours perdu, peu importe si la transformation a effectivement changé quelque chose.

#### Conversion et coercition

Appeler `to_s` sur une chaîne sécurisée renvoie une chaîne sécurisée, mais la coercition avec `to_str` renvoie une chaîne non sécurisée.

#### Copie

Appeler `dup` ou `clone` sur des chaînes sécurisées donne des chaînes sécurisées.

### `remove`

La méthode [`remove`][String#remove] supprime toutes les occurrences du motif :

```ruby
"Hello World".remove(/Hello /) # => "World"
```

Il existe également la version destructive `String#remove!`.

NOTE : Défini dans `active_support/core_ext/string/filters.rb`.


### `squish`

La méthode [`squish`][String#squish] supprime les espaces vides en début et en fin de chaîne, et remplace les séquences d'espaces par un seul espace :

```ruby
" \n  foo\n\r \t bar \n".squish # => "foo bar"
```

Il existe également la version destructive `String#squish!`.

Notez qu'elle gère à la fois les espaces vides ASCII et Unicode.

NOTE : Défini dans `active_support/core_ext/string/filters.rb`.


### `truncate`

La méthode [`truncate`][String#truncate] renvoie une copie de sa chaîne tronquée après une longueur donnée :

```ruby
"Oh dear! Oh dear! I shall be late!".truncate(20)
# => "Oh dear! Oh dear!..."
```

L'ellipse peut être personnalisée avec l'option `:omission` :

```ruby
"Oh dear! Oh dear! I shall be late!".truncate(20, omission: '&hellip;')
# => "Oh dear! Oh &hellip;"
```

Notez en particulier que la troncature prend en compte la longueur de la chaîne d'omission.

Passez un `:separator` pour tronquer la chaîne à une rupture naturelle :

```ruby
"Oh dear! Oh dear! I shall be late!".truncate(18)
# => "Oh dear! Oh dea..."
"Oh dear! Oh dear! I shall be late!".truncate(18, separator: ' ')
# => "Oh dear! Oh..."
```

L'option `:separator` peut être une expression régulière :

```ruby
"Oh dear! Oh dear! I shall be late!".truncate(18, separator: /\s/)
# => "Oh dear! Oh..."
```

Dans les exemples ci-dessus, "dear" est coupé en premier, mais ensuite `:separator` l'empêche.

NOTE : Défini dans `active_support/core_ext/string/filters.rb`.


### `truncate_bytes`

La méthode [`truncate_bytes`][String#truncate_bytes] renvoie une copie de sa chaîne tronquée à au plus `bytesize` octets :

```ruby
"👍👍👍👍".truncate_bytes(15)
# => "👍👍👍…"
```

L'ellipse peut être personnalisée avec l'option `:omission` :

```ruby
"👍👍👍👍".truncate_bytes(15, omission: "🖖")
# => "👍👍🖖"
```

NOTE : Défini dans `active_support/core_ext/string/filters.rb`.


### `truncate_words`

La méthode [`truncate_words`][String#truncate_words] renvoie une copie de sa chaîne tronquée après un certain nombre de mots :

```ruby
"Oh dear! Oh dear! I shall be late!".truncate_words(4)
# => "Oh dear! Oh dear!..."
```

L'ellipse peut être personnalisée avec l'option `:omission` :

```ruby
"Oh dear! Oh dear! I shall be late!".truncate_words(4, omission: '&hellip;')
# => "Oh dear! Oh dear!&hellip;"
```

Passez un `:separator` pour tronquer la chaîne à une rupture naturelle :

```ruby
"Oh dear! Oh dear! I shall be late!".truncate_words(3, separator: '!')
# => "Oh dear! Oh dear! I shall be late..."
```

L'option `:separator` peut être une expression régulière :

```ruby
"Oh dear! Oh dear! I shall be late!".truncate_words(4, separator: /\s/)
# => "Oh dear! Oh dear!..."
```

NOTE : Défini dans `active_support/core_ext/string/filters.rb`.


### `inquiry`

La méthode [`inquiry`][String#inquiry] convertit une chaîne en un objet `StringInquirer`, ce qui rend les comparaisons d'égalité plus jolies.

```ruby
"production".inquiry.production? # => true
"active".inquiry.inactive?       # => false
```

NOTE : Défini dans `active_support/core_ext/string/inquiry.rb`.


### `starts_with?` et `ends_with?`

Active Support définit des alias à la troisième personne de `String#start_with?` et `String#end_with?` :

```ruby
"foo".starts_with?("f") # => true
"foo".ends_with?("o")   # => true
```

NOTE : Défini dans `active_support/core_ext/string/starts_ends_with.rb`.

### `strip_heredoc`

La méthode [`strip_heredoc`][String#strip_heredoc] supprime l'indentation dans les heredocs.

Par exemple, dans

```ruby
if options[:usage]
  puts <<-USAGE.strip_heredoc
    This command does such and such.

    Supported options are:
      -h         This message
      ...
  USAGE
end
```

l'utilisateur verra le message d'utilisation aligné contre la marge gauche.

Techniquement, elle recherche la ligne avec le moins d'indentation dans toute la chaîne, et supprime
cette quantité d'espaces vides en début de ligne.

NOTE : Défini dans `active_support/core_ext/string/strip.rb`.


### `indent`

La méthode [`indent`][String#indent] indente les lignes de la chaîne :

```ruby
<<EOS.indent(2)
def some_method
  some_code
end
EOS
# =>
  def some_method
    some_code
  end
```

Le deuxième argument, `indent_string`, spécifie quelle chaîne d'indentation utiliser. La valeur par défaut est `nil`, ce qui indique à la méthode de faire une supposition éclairée en regardant la première ligne indentée, et de revenir à un espace s'il n'y en a pas.

```ruby
"  foo".indent(2)        # => "    foo"
"foo\n\t\tbar".indent(2) # => "\t\tfoo\n\t\t\t\tbar"
"foo".indent(2, "\t")    # => "\t\tfoo"
```

Bien que `indent_string` soit généralement un espace ou une tabulation, il peut être n'importe quelle chaîne de caractères.

Le troisième argument, `indent_empty_lines`, est un indicateur qui indique si les lignes vides doivent être indentées. La valeur par défaut est false.

```ruby
"foo\n\nbar".indent(2)            # => "  foo\n\n  bar"
"foo\n\nbar".indent(2, nil, true) # => "  foo\n  \n  bar"
```

La méthode [`indent!`][String#indent!] effectue l'indentation sur place.

NOTE : Défini dans `active_support/core_ext/string/indent.rb`.


### Accès

#### `at(position)`

La méthode [`at`][String#at] renvoie le caractère de la chaîne à la position `position` :

```ruby
"hello".at(0)  # => "h"
"hello".at(4)  # => "o"
"hello".at(-1) # => "o"
"hello".at(10) # => nil
```

NOTE : Défini dans `active_support/core_ext/string/access.rb`.


#### `from(position)`

La méthode [`from`][String#from] renvoie la sous-chaîne de la chaîne à partir de la position `position` :

```ruby
"hello".from(0)  # => "hello"
"hello".from(2)  # => "llo"
"hello".from(-2) # => "lo"
"hello".from(10) # => nil
```

NOTE : Défini dans `active_support/core_ext/string/access.rb`.


#### `to(position)`

La méthode [`to`][String#to] renvoie la sous-chaîne de la chaîne jusqu'à la position `position` :

```ruby
"hello".to(0)  # => "h"
"hello".to(2)  # => "hel"
"hello".to(-2) # => "hell"
"hello".to(10) # => "hello"
```

NOTE : Défini dans `active_support/core_ext/string/access.rb`.


#### `first(limit = 1)`

La méthode [`first`][String#first] renvoie une sous-chaîne contenant les premiers caractères `limit` de la chaîne.

L'appel `str.first(n)` est équivalent à `str.to(n-1)` si `n` > 0, et renvoie une chaîne vide pour `n` == 0.

NOTE : Défini dans `active_support/core_ext/string/access.rb`.


#### `last(limit = 1)`

La méthode [`last`][String#last] renvoie une sous-chaîne contenant les derniers caractères `limit` de la chaîne.

L'appel `str.last(n)` est équivalent à `str.from(-n)` si `n` > 0, et renvoie une chaîne vide pour `n` == 0.

NOTE : Défini dans `active_support/core_ext/string/access.rb`.


### Inflections

#### `pluralize`

La méthode [`pluralize`][String#pluralize] renvoie le pluriel de son argument :

```ruby
"table".pluralize     # => "tables"
"ruby".pluralize      # => "rubies"
"equipment".pluralize # => "equipment"
```

Comme le montre l'exemple précédent, Active Support connaît certains pluriels irréguliers et des noms non dénombrables. Les règles intégrées peuvent être étendues dans `config/initializers/inflections.rb`. Ce fichier est généré par défaut par la commande `rails new` et contient des instructions en commentaires.

`pluralize` peut également prendre un paramètre optionnel `count`. Si `count == 1`, la forme singulière sera renvoyée. Pour toute autre valeur de `count`, la forme plurielle sera renvoyée :

```ruby
"dude".pluralize(0) # => "dudes"
"dude".pluralize(1) # => "dude"
"dude".pluralize(2) # => "dudes"
```

Active Record utilise cette méthode pour calculer le nom de table par défaut correspondant à un modèle :

```ruby
# active_record/model_schema.rb
def undecorated_table_name(model_name)
  table_name = model_name.to_s.demodulize.underscore
  pluralize_table_names ? table_name.pluralize : table_name
end
```

NOTE : Défini dans `active_support/core_ext/string/inflections.rb`.


#### `singularize`

La méthode [`singularize`][String#singularize] est l'inverse de `pluralize` :

```ruby
"tables".singularize    # => "table"
"rubies".singularize    # => "ruby"
"equipment".singularize # => "equipment"
```

Les associations calculent le nom de la classe associée par défaut en utilisant cette méthode :

```ruby
# active_record/reflection.rb
def derive_class_name
  class_name = name.to_s.camelize
  class_name = class_name.singularize if collection?
  class_name
end
```

NOTE : Défini dans `active_support/core_ext/string/inflections.rb`.


#### `camelize`

La méthode [`camelize`][String#camelize] renvoie son argument en camel case :

```ruby
"product".camelize    # => "Product"
"admin_user".camelize # => "AdminUser"
```

En règle générale, vous pouvez considérer cette méthode comme celle qui transforme les chemins en noms de classes ou de modules Ruby, où les barres obliques séparent les espaces de noms :

```ruby
"backoffice/session".camelize # => "Backoffice::Session"
```

Par exemple, Action Pack utilise cette méthode pour charger la classe qui fournit un certain magasin de session :

```ruby
# action_controller/metal/session_management.rb
def session_store=(store)
  @@session_store = store.is_a?(Symbol) ?
    ActionDispatch::Session.const_get(store.to_s.camelize) :
    store
end
```

`camelize` accepte un argument optionnel, qui peut être `:upper` (par défaut) ou `:lower`. Avec ce dernier, la première lettre devient en minuscule :

```ruby
"visual_effect".camelize(:lower) # => "visualEffect"
```

Cela peut être pratique pour calculer les noms de méthodes dans un langage qui suit cette convention, par exemple JavaScript.

INFO : En règle générale, vous pouvez considérer `camelize` comme l'inverse de `underscore`, bien qu'il existe des cas où cela ne s'applique pas : `"SSLError".underscore.camelize` renvoie `"SslError"`. Pour prendre en charge des cas comme celui-ci, Active Support vous permet de spécifier des acronymes dans `config/initializers/inflections.rb` :

```ruby
ActiveSupport::Inflector.inflections do |inflect|
  inflect.acronym 'SSL'
end

"SSLError".underscore.camelize # => "SSLError"
```

`camelize` est un alias de [`camelcase`][String#camelcase].

NOTE : Défini dans `active_support/core_ext/string/inflections.rb`.
#### `underscore`

La méthode [`underscore`][String#underscore] fonctionne dans l'autre sens, de camel case à des chemins :

```ruby
"Product".underscore   # => "product"
"AdminUser".underscore # => "admin_user"
```

Elle convertit également "::" en "/":

```ruby
"Backoffice::Session".underscore # => "backoffice/session"
```

et comprend les chaînes qui commencent par une minuscule :

```ruby
"visualEffect".underscore # => "visual_effect"
```

Cependant, `underscore` n'accepte aucun argument.

Rails utilise `underscore` pour obtenir un nom en minuscules pour les classes de contrôleur :

```ruby
# actionpack/lib/abstract_controller/base.rb
def controller_path
  @controller_path ||= name.delete_suffix("Controller").underscore
end
```

Par exemple, cette valeur est celle que vous obtenez dans `params[:controller]`.

INFO : En règle générale, vous pouvez considérer `underscore` comme l'inverse de `camelize`, bien qu'il existe des cas où cela ne s'applique pas. Par exemple, `"SSLError".underscore.camelize` renvoie `"SslError"`.

NOTE : Défini dans `active_support/core_ext/string/inflections.rb`.


#### `titleize`

La méthode [`titleize`][String#titleize] met en majuscule les mots de la chaîne :

```ruby
"alice in wonderland".titleize # => "Alice In Wonderland"
"fermat's enigma".titleize     # => "Fermat's Enigma"
```

`titleize` est un alias de [`titlecase`][String#titlecase].

NOTE : Défini dans `active_support/core_ext/string/inflections.rb`.


#### `dasherize`

La méthode [`dasherize`][String#dasherize] remplace les tirets bas dans la chaîne par des tirets :

```ruby
"name".dasherize         # => "name"
"contact_data".dasherize # => "contact-data"
```

Le sérialiseur XML des modèles utilise cette méthode pour transformer les noms de nœuds en tirets :

```ruby
# active_model/serializers/xml.rb
def reformat_name(name)
  name = name.camelize if camelize?
  dasherize? ? name.dasherize : name
end
```

NOTE : Défini dans `active_support/core_ext/string/inflections.rb`.


#### `demodulize`

Étant donné une chaîne avec un nom de constante qualifié, [`demodulize`][String#demodulize] renvoie le nom de la constante lui-même, c'est-à-dire la partie la plus à droite :

```ruby
"Product".demodulize                        # => "Product"
"Backoffice::UsersController".demodulize    # => "UsersController"
"Admin::Hotel::ReservationUtils".demodulize # => "ReservationUtils"
"::Inflections".demodulize                  # => "Inflections"
"".demodulize                               # => ""
```

Par exemple, Active Record utilise cette méthode pour calculer le nom d'une colonne de cache de compteur :

```ruby
# active_record/reflection.rb
def counter_cache_column
  if options[:counter_cache] == true
    "#{active_record.name.demodulize.underscore.pluralize}_count"
  elsif options[:counter_cache]
    options[:counter_cache]
  end
end
```

NOTE : Défini dans `active_support/core_ext/string/inflections.rb`.


#### `deconstantize`

Étant donné une chaîne avec une expression de référence de constante qualifiée, [`deconstantize`][String#deconstantize] supprime le segment le plus à droite, laissant généralement le nom du conteneur de la constante :

```ruby
"Product".deconstantize                        # => ""
"Backoffice::UsersController".deconstantize    # => "Backoffice"
"Admin::Hotel::ReservationUtils".deconstantize # => "Admin::Hotel"
```

NOTE : Défini dans `active_support/core_ext/string/inflections.rb`.


#### `parameterize`

La méthode [`parameterize`][String#parameterize] normalise la chaîne de manière à pouvoir être utilisée dans des URLs agréables.

```ruby
"John Smith".parameterize # => "john-smith"
"Kurt Gödel".parameterize # => "kurt-godel"
```

Pour conserver la casse de la chaîne, définissez l'argument `preserve_case` sur true. Par défaut, `preserve_case` est défini sur false.

```ruby
"John Smith".parameterize(preserve_case: true) # => "John-Smith"
"Kurt Gödel".parameterize(preserve_case: true) # => "Kurt-Godel"
```

Pour utiliser un séparateur personnalisé, remplacez l'argument `separator`.

```ruby
"John Smith".parameterize(separator: "_") # => "john_smith"
"Kurt Gödel".parameterize(separator: "_") # => "kurt_godel"
```

NOTE : Défini dans `active_support/core_ext/string/inflections.rb`.


#### `tableize`

La méthode [`tableize`][String#tableize] est `underscore` suivie de `pluralize`.

```ruby
"Person".tableize      # => "people"
"Invoice".tableize     # => "invoices"
"InvoiceLine".tableize # => "invoice_lines"
```

En règle générale, `tableize` renvoie le nom de la table correspondant à un modèle donné pour les cas simples. L'implémentation réelle dans Active Record n'est pas simplement `tableize`, car elle démodule également le nom de la classe et vérifie quelques options qui peuvent affecter la chaîne renvoyée.

NOTE : Défini dans `active_support/core_ext/string/inflections.rb`.


#### `classify`

La méthode [`classify`][String#classify] est l'inverse de `tableize`. Elle vous donne le nom de classe correspondant à un nom de table :

```ruby
"people".classify        # => "Person"
"invoices".classify      # => "Invoice"
"invoice_lines".classify # => "InvoiceLine"
```

La méthode comprend les noms de table qualifiés :

```ruby
"highrise_production.companies".classify # => "Company"
```

Notez que `classify` renvoie un nom de classe sous forme de chaîne. Vous pouvez obtenir l'objet de classe réel en invoquant `constantize` dessus, expliqué ci-dessous.

NOTE : Défini dans `active_support/core_ext/string/inflections.rb`.


#### `constantize`

La méthode [`constantize`][String#constantize] résout l'expression de référence de constante dans sa chaîne :

```ruby
"Integer".constantize # => Integer

module M
  X = 1
end
"M::X".constantize # => 1
```

Si la chaîne ne correspond à aucune constante connue, ou si son contenu n'est même pas un nom de constante valide, `constantize` lève une `NameError`.

La résolution du nom de constante par `constantize` commence toujours au niveau supérieur de `Object`, même s'il n'y a pas de "::" au début.

```ruby
X = :in_Object
module M
  X = :in_M

  X                 # => :in_M
  "::X".constantize # => :in_Object
  "X".constantize   # => :in_Object (!)
end
```

Ainsi, en général, ce n'est pas équivalent à ce que ferait Ruby au même endroit, si une vraie constante était évaluée.

Les cas de test des mailers obtiennent le mailer testé à partir du nom de la classe de test en utilisant `constantize` :
```ruby
# action_mailer/test_case.rb
def determine_default_mailer(name)
  name.delete_suffix("Test").constantize
rescue NameError => e
  raise NonInferrableMailerError.new(name)
end
```

NOTE: Défini dans `active_support/core_ext/string/inflections.rb`.


#### `humanize`

La méthode [`humanize`][String#humanize] modifie un nom d'attribut pour l'affichage aux utilisateurs finaux.

Plus précisément, elle effectue les transformations suivantes :

  * Applique les règles d'inflection humaine à l'argument.
  * Supprime les tirets bas initiaux, le cas échéant.
  * Supprime le suffixe "_id" s'il est présent.
  * Remplace les tirets bas par des espaces, le cas échéant.
  * Met en minuscule tous les mots sauf les acronymes.
  * Met en majuscule la première lettre.

La majuscule de la première lettre peut être désactivée en définissant l'option `:capitalize` sur `false` (par défaut, `true`).

```ruby
"name".humanize                         # => "Name"
"author_id".humanize                    # => "Author"
"author_id".humanize(capitalize: false) # => "author"
"comments_count".humanize               # => "Comments count"
"_id".humanize                          # => "Id"
```

Si "SSL" est défini comme un acronyme :

```ruby
'ssl_error'.humanize # => "SSL error"
```

La méthode auxiliaire `full_messages` utilise `humanize` comme solution de repli pour inclure les noms d'attributs :

```ruby
def full_messages
  map { |attribute, message| full_message(attribute, message) }
end

def full_message
  # ...
  attr_name = attribute.to_s.tr('.', '_').humanize
  attr_name = @base.class.human_attribute_name(attribute, default: attr_name)
  # ...
end
```

NOTE: Défini dans `active_support/core_ext/string/inflections.rb`.


#### `foreign_key`

La méthode [`foreign_key`][String#foreign_key] donne un nom de colonne de clé étrangère à partir d'un nom de classe. Pour ce faire, elle démodule, ajoute des tirets bas et ajoute "_id" :

```ruby
"User".foreign_key           # => "user_id"
"InvoiceLine".foreign_key    # => "invoice_line_id"
"Admin::Session".foreign_key # => "session_id"
```

Passez un argument `false` si vous ne voulez pas de tiret bas dans "_id" :

```ruby
"User".foreign_key(false) # => "userid"
```

Les associations utilisent cette méthode pour déduire les clés étrangères, par exemple `has_one` et `has_many` font ceci :

```ruby
# active_record/associations.rb
foreign_key = options[:foreign_key] || reflection.active_record.name.foreign_key
```

NOTE: Défini dans `active_support/core_ext/string/inflections.rb`.


#### `upcase_first`

La méthode [`upcase_first`][String#upcase_first] met en majuscule la première lettre du récepteur :

```ruby
"employee salary".upcase_first # => "Employee salary"
"".upcase_first                # => ""
```

NOTE: Défini dans `active_support/core_ext/string/inflections.rb`.


#### `downcase_first`

La méthode [`downcase_first`][String#downcase_first] convertit la première lettre du récepteur en minuscule :

```ruby
"If I had read Alice in Wonderland".downcase_first # => "if I had read Alice in Wonderland"
"".downcase_first                                  # => ""
```

NOTE: Défini dans `active_support/core_ext/string/inflections.rb`.


### Conversions

#### `to_date`, `to_time`, `to_datetime`

Les méthodes [`to_date`][String#to_date], [`to_time`][String#to_time] et [`to_datetime`][String#to_datetime] sont essentiellement des enveloppes pratiques autour de `Date._parse` :

```ruby
"2010-07-27".to_date              # => Tue, 27 Jul 2010
"2010-07-27 23:37:00".to_time     # => 2010-07-27 23:37:00 +0200
"2010-07-27 23:37:00".to_datetime # => Tue, 27 Jul 2010 23:37:00 +0000
```

`to_time` reçoit un argument facultatif `:utc` ou `:local`, pour indiquer dans quel fuseau horaire vous voulez l'heure :

```ruby
"2010-07-27 23:42:00".to_time(:utc)   # => 2010-07-27 23:42:00 UTC
"2010-07-27 23:42:00".to_time(:local) # => 2010-07-27 23:42:00 +0200
```

Par défaut, c'est `:local`.

Veuillez vous référer à la documentation de `Date._parse` pour plus de détails.

INFO: Les trois renvoient `nil` pour les récepteurs vides.

NOTE: Défini dans `active_support/core_ext/string/conversions.rb`.


Extensions à `Symbol`
----------------------

### `starts_with?` et `ends_with?`

Active Support définit des alias à la troisième personne de `Symbol#start_with?` et `Symbol#end_with?` :

```ruby
:foo.starts_with?("f") # => true
:foo.ends_with?("o")   # => true
```

NOTE: Défini dans `active_support/core_ext/symbol/starts_ends_with.rb`.

Extensions à `Numeric`
-----------------------

### Bytes

Tous les nombres répondent à ces méthodes :

* [`bytes`][Numeric#bytes]
* [`kilobytes`][Numeric#kilobytes]
* [`megabytes`][Numeric#megabytes]
* [`gigabytes`][Numeric#gigabytes]
* [`terabytes`][Numeric#terabytes]
* [`petabytes`][Numeric#petabytes]
* [`exabytes`][Numeric#exabytes]

Elles renvoient la quantité correspondante d'octets, en utilisant un facteur de conversion de 1024 :

```ruby
2.kilobytes   # => 2048
3.megabytes   # => 3145728
3.5.gigabytes # => 3758096384.0
-4.exabytes   # => -4611686018427387904
```

Les formes singulières sont des alias, vous pouvez donc dire :

```ruby
1.megabyte # => 1048576
```

NOTE: Défini dans `active_support/core_ext/numeric/bytes.rb`.


### Time

Les méthodes suivantes :

* [`seconds`][Numeric#seconds]
* [`minutes`][Numeric#minutes]
* [`hours`][Numeric#hours]
* [`days`][Numeric#days]
* [`weeks`][Numeric#weeks]
* [`fortnights`][Numeric#fortnights]

permettent les déclarations et les calculs de temps, comme `45.minutes + 2.hours + 4.weeks`. Leurs valeurs de retour peuvent également être ajoutées ou soustraites à des objets Time.

Ces méthodes peuvent être combinées avec [`from_now`][Duration#from_now], [`ago`][Duration#ago], etc., pour des calculs de dates précis. Par exemple :

```ruby
# équivalent à Time.current.advance(days: 1)
1.day.from_now

# équivalent à Time.current.advance(weeks: 2)
2.weeks.from_now

# équivalent à Time.current.advance(days: 4, weeks: 5)
(4.days + 5.weeks).from_now
```

ATTENTION. Pour d'autres durées, veuillez vous référer aux extensions de temps à `Integer`.

NOTE: Défini dans `active_support/core_ext/numeric/time.rb`.


### Formatage

Permet le formatage des nombres de différentes manières.

Produit une représentation sous forme de chaîne d'un nombre en tant que numéro de téléphone :

```ruby
5551234.to_fs(:phone)
# => 555-1234
1235551234.to_fs(:phone)
# => 123-555-1234
1235551234.to_fs(:phone, area_code: true)
# => (123) 555-1234
1235551234.to_fs(:phone, delimiter: " ")
# => 123 555 1234
1235551234.to_fs(:phone, area_code: true, extension: 555)
# => (123) 555-1234 x 555
1235551234.to_fs(:phone, country_code: 1)
# => +1-123-555-1234
```

Produire une représentation sous forme de chaîne d'un nombre en tant que devise :

```ruby
1234567890.50.to_fs(:currency)                 # => 1 234 567 890,50 $
1234567890.506.to_fs(:currency)                # => 1 234 567 890,51 $
1234567890.506.to_fs(:currency, precision: 3)  # => 1 234 567 890,506 $
```

Produire une représentation sous forme de chaîne d'un nombre en pourcentage :

```ruby
100.to_fs(:percentage)
# => 100,000%
100.to_fs(:percentage, precision: 0)
# => 100%
1000.to_fs(:percentage, delimiter: '.', separator: ',')
# => 1.000,000%
302.24398923423.to_fs(:percentage, precision: 5)
# => 302,24399%
```

Produire une représentation sous forme de chaîne d'un nombre en forme délimitée :

```ruby
12345678.to_fs(:delimited)                     # => 12 345 678
12345678.05.to_fs(:delimited)                  # => 12 345 678,05
12345678.to_fs(:delimited, delimiter: ".")     # => 12.345.678
12345678.to_fs(:delimited, delimiter: ",")     # => 12 345 678
12345678.05.to_fs(:delimited, separator: " ")  # => 12 345 678 05
```

Produire une représentation sous forme de chaîne d'un nombre arrondi à une précision :

```ruby
111.2345.to_fs(:rounded)                     # => 111,235
111.2345.to_fs(:rounded, precision: 2)       # => 111,23
13.to_fs(:rounded, precision: 5)             # => 13,00000
389.32314.to_fs(:rounded, precision: 0)      # => 389
111.2345.to_fs(:rounded, significant: true)  # => 111
```

Produire une représentation sous forme de chaîne d'un nombre en tant que nombre de bytes lisible par l'homme :

```ruby
123.to_fs(:human_size)                  # => 123 Bytes
1234.to_fs(:human_size)                 # => 1,21 KB
12345.to_fs(:human_size)                # => 12,1 KB
1234567.to_fs(:human_size)              # => 1,18 MB
1234567890.to_fs(:human_size)           # => 1,15 GB
1234567890123.to_fs(:human_size)        # => 1,12 TB
1234567890123456.to_fs(:human_size)     # => 1,1 PB
1234567890123456789.to_fs(:human_size)  # => 1,07 EB
```

Produire une représentation sous forme de chaîne d'un nombre en mots lisibles par l'homme :

```ruby
123.to_fs(:human)               # => "123"
1234.to_fs(:human)              # => "1,23 Thousand"
12345.to_fs(:human)             # => "12,3 Thousand"
1234567.to_fs(:human)           # => "1,23 Million"
1234567890.to_fs(:human)        # => "1,23 Billion"
1234567890123.to_fs(:human)     # => "1,23 Trillion"
1234567890123456.to_fs(:human)  # => "1,23 Quadrillion"
```

NOTE : Défini dans `active_support/core_ext/numeric/conversions.rb`.

Extensions à `Integer`
-----------------------

### `multiple_of?`

La méthode [`multiple_of?`][Integer#multiple_of?] teste si un entier est un multiple de l'argument :

```ruby
2.multiple_of?(1) # => true
1.multiple_of?(2) # => false
```

NOTE : Défini dans `active_support/core_ext/integer/multiple.rb`.


### `ordinal`

La méthode [`ordinal`][Integer#ordinal] renvoie la chaîne de suffixe ordinal correspondant à l'entier récepteur :

```ruby
1.ordinal    # => "st"
2.ordinal    # => "nd"
53.ordinal   # => "rd"
2009.ordinal # => "th"
-21.ordinal  # => "st"
-134.ordinal # => "th"
```

NOTE : Défini dans `active_support/core_ext/integer/inflections.rb`.


### `ordinalize`

La méthode [`ordinalize`][Integer#ordinalize] renvoie la chaîne ordinale correspondant à l'entier récepteur. En comparaison, notez que la méthode `ordinal` renvoie **seulement** la chaîne de suffixe.

```ruby
1.ordinalize    # => "1st"
2.ordinalize    # => "2nd"
53.ordinalize   # => "53rd"
2009.ordinalize # => "2009th"
-21.ordinalize  # => "-21st"
-134.ordinalize # => "-134th"
```

NOTE : Défini dans `active_support/core_ext/integer/inflections.rb`.


### Time

Les méthodes suivantes :

* [`months`][Integer#months]
* [`years`][Integer#years]

permettent les déclarations et les calculs de temps, comme `4.months + 5.years`. Leurs valeurs de retour peuvent également être ajoutées ou soustraites des objets Time.

Ces méthodes peuvent être combinées avec [`from_now`][Duration#from_now], [`ago`][Duration#ago], etc., pour des calculs de dates précis. Par exemple :

```ruby
# équivalent à Time.current.advance(months: 1)
1.month.from_now

# équivalent à Time.current.advance(years: 2)
2.years.from_now

# équivalent à Time.current.advance(months: 4, years: 5)
(4.months + 5.years).from_now
```

AVERTISSEMENT. Pour d'autres durées, veuillez vous référer aux extensions de temps à `Numeric`.

NOTE : Défini dans `active_support/core_ext/integer/time.rb`.


Extensions à `BigDecimal`
--------------------------

### `to_s`

La méthode `to_s` fournit un spécificateur par défaut de "F". Cela signifie qu'un simple appel à `to_s` donnera une représentation en virgule flottante au lieu de la notation scientifique :

```ruby
BigDecimal(5.00, 6).to_s       # => "5.0"
```

La notation scientifique est toujours prise en charge :

```ruby
BigDecimal(5.00, 6).to_s("e")  # => "0.5E1"
```

Extensions à `Enumerable`
--------------------------

### `sum`

La méthode [`sum`][Enumerable#sum] ajoute les éléments d'un énumérable :

```ruby
[1, 2, 3].sum # => 6
(1..100).sum  # => 5050
```

L'addition suppose uniquement que les éléments répondent à `+` :

```ruby
[[1, 2], [2, 3], [3, 4]].sum    # => [1, 2, 2, 3, 3, 4]
%w(foo bar baz).sum             # => "foobarbaz"
{ a: 1, b: 2, c: 3 }.sum          # => [:a, 1, :b, 2, :c, 3]
```

La somme d'une collection vide est zéro par défaut, mais cela peut être personnalisé :

```ruby
[].sum    # => 0
[].sum(1) # => 1
```

Si un bloc est donné, `sum` devient un itérateur qui renvoie les éléments de la collection et additionne les valeurs renvoyées :

```ruby
(1..5).sum { |n| n * 2 } # => 30
[2, 4, 6, 8, 10].sum    # => 30
```

La somme d'un récepteur vide peut également être personnalisée sous cette forme :

```ruby
[].sum(1) { |n| n**3 } # => 1
```

NOTE : Défini dans `active_support/core_ext/enumerable.rb`.


### `index_by`

La méthode [`index_by`][Enumerable#index_by] génère un hash avec les éléments d'un énumérable indexés par une clé.
Il itère à travers la collection et passe chaque élément à un bloc. L'élément sera indexé par la valeur retournée par le bloc :

```ruby
invoices.index_by(&:number)
# => {'2009-032' => <Invoice ...>, '2009-008' => <Invoice ...>, ...}
```

ATTENTION. Les clés doivent normalement être uniques. Si le bloc retourne la même valeur pour différents éléments, aucune collection n'est construite pour cette clé. Le dernier élément l'emportera.

NOTE : Défini dans `active_support/core_ext/enumerable.rb`.


### `index_with`

La méthode [`index_with`][Enumerable#index_with] génère un hash avec les éléments d'un énumérable en tant que clés. La valeur
est soit une valeur par défaut passée en argument, soit retournée par un bloc.

```ruby
post = Post.new(title: "hey there", body: "what's up?")

%i( title body ).index_with { |attr_name| post.public_send(attr_name) }
# => { title: "hey there", body: "what's up?" }

WEEKDAYS.index_with(Interval.all_day)
# => { monday: [ 0, 1440 ], … }
```

NOTE : Défini dans `active_support/core_ext/enumerable.rb`.


### `many?`

La méthode [`many?`][Enumerable#many?] est une abréviation pour `collection.size > 1` :

```erb
<% if pages.many? %>
  <%= pagination_links %>
<% end %>
```

Si un bloc optionnel est donné, `many?` ne prend en compte que les éléments qui renvoient true :

```ruby
@see_more = videos.many? { |video| video.category == params[:category] }
```

NOTE : Défini dans `active_support/core_ext/enumerable.rb`.


### `exclude?`

Le prédicat [`exclude?`][Enumerable#exclude?] teste si un objet donné n'appartient **pas** à la collection. C'est la négation de la méthode intégrée `include?` :

```ruby
to_visit << node if visited.exclude?(node)
```

NOTE : Défini dans `active_support/core_ext/enumerable.rb`.


### `including`

La méthode [`including`][Enumerable#including] renvoie un nouvel énumérable qui inclut les éléments passés en argument :

```ruby
[ 1, 2, 3 ].including(4, 5)                    # => [ 1, 2, 3, 4, 5 ]
["David", "Rafael"].including %w[ Aaron Todd ] # => ["David", "Rafael", "Aaron", "Todd"]
```

NOTE : Défini dans `active_support/core_ext/enumerable.rb`.


### `excluding`

La méthode [`excluding`][Enumerable#excluding] renvoie une copie d'un énumérable avec les éléments spécifiés
supprimés :

```ruby
["David", "Rafael", "Aaron", "Todd"].excluding("Aaron", "Todd") # => ["David", "Rafael"]
```

`excluding` est un alias de [`without`][Enumerable#without].

NOTE : Défini dans `active_support/core_ext/enumerable.rb`.


### `pluck`

La méthode [`pluck`][Enumerable#pluck] extrait la clé donnée de chaque élément :

```ruby
[{ name: "David" }, { name: "Rafael" }, { name: "Aaron" }].pluck(:name) # => ["David", "Rafael", "Aaron"]
[{ id: 1, name: "David" }, { id: 2, name: "Rafael" }].pluck(:id, :name) # => [[1, "David"], [2, "Rafael"]]
```

NOTE : Défini dans `active_support/core_ext/enumerable.rb`.


### `pick`

La méthode [`pick`][Enumerable#pick] extrait la clé donnée du premier élément :

```ruby
[{ name: "David" }, { name: "Rafael" }, { name: "Aaron" }].pick(:name) # => "David"
[{ id: 1, name: "David" }, { id: 2, name: "Rafael" }].pick(:id, :name) # => [1, "David"]
```

NOTE : Défini dans `active_support/core_ext/enumerable.rb`.


Extensions pour `Array`
---------------------

### Accès

Active Support améliore l'API des tableaux pour faciliter certains moyens de les accéder. Par exemple, [`to`][Array#to] renvoie le sous-tableau des éléments jusqu'à celui à l'index passé en argument :

```ruby
%w(a b c d).to(2) # => ["a", "b", "c"]
[].to(7)          # => []
```

De même, [`from`][Array#from] renvoie la partie à partir de l'élément à l'index passé en argument jusqu'à la fin. Si l'index est supérieur à la longueur du tableau, il renvoie un tableau vide.

```ruby
%w(a b c d).from(2)  # => ["c", "d"]
%w(a b c d).from(10) # => []
[].from(0)           # => []
```

La méthode [`including`][Array#including] renvoie un nouveau tableau qui inclut les éléments passés en argument :

```ruby
[ 1, 2, 3 ].including(4, 5)          # => [ 1, 2, 3, 4, 5 ]
[ [ 0, 1 ] ].including([ [ 1, 0 ] ]) # => [ [ 0, 1 ], [ 1, 0 ] ]
```

La méthode [`excluding`][Array#excluding] renvoie une copie du tableau en excluant les éléments spécifiés.
Il s'agit d'une optimisation de `Enumerable#excluding` qui utilise `Array#-`
au lieu de `Array#reject` pour des raisons de performance.

```ruby
["David", "Rafael", "Aaron", "Todd"].excluding("Aaron", "Todd") # => ["David", "Rafael"]
[ [ 0, 1 ], [ 1, 0 ] ].excluding([ [ 1, 0 ] ])                  # => [ [ 0, 1 ] ]
```

Les méthodes [`second`][Array#second], [`third`][Array#third], [`fourth`][Array#fourth] et [`fifth`][Array#fifth] renvoient l'élément correspondant, tout comme [`second_to_last`][Array#second_to_last] et [`third_to_last`][Array#third_to_last] (`first` et `last` sont intégrés). Grâce à la sagesse sociale et à la constructivité positive tout autour, [`forty_two`][Array#forty_two] est également disponible.

```ruby
%w(a b c d).third # => "c"
%w(a b c d).fifth # => nil
```

NOTE : Défini dans `active_support/core_ext/array/access.rb`.


### Extraction

La méthode [`extract!`][Array#extract!] supprime et renvoie les éléments pour lesquels le bloc renvoie une valeur true.
Si aucun bloc n'est donné, un Enumerator est renvoyé à la place.
```ruby
numbers = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
odd_numbers = numbers.extract! { |number| number.odd? } # => [1, 3, 5, 7, 9]
numbers # => [0, 2, 4, 6, 8]
```

NOTE: Défini dans `active_support/core_ext/array/extract.rb`.


### Extraction d'options

Lorsque le dernier argument dans un appel de méthode est un hash, sauf peut-être pour un argument `&block`, Ruby vous permet d'omettre les crochets :

```ruby
User.exists?(email: params[:email])
```

Ce sucre syntaxique est beaucoup utilisé dans Rails pour éviter les arguments positionnels lorsque cela serait trop nombreux, offrant à la place des interfaces qui émulent les paramètres nommés. Il est particulièrement idiomatique d'utiliser un hash de fin pour les options.

Si une méthode attend un nombre variable d'arguments et utilise `*` dans sa déclaration, cependant, un hash d'options se retrouve être un élément du tableau d'arguments, où il perd son rôle.

Dans ces cas, vous pouvez donner un traitement distingué à un hash d'options avec [`extract_options!`][Array#extract_options!]. Cette méthode vérifie le type du dernier élément d'un tableau. S'il s'agit d'un hash, il le retire et le renvoie, sinon il renvoie un hash vide.

Voyons par exemple la définition de la macro de contrôleur `caches_action` :

```ruby
def caches_action(*actions)
  return unless cache_configured?
  options = actions.extract_options!
  # ...
end
```

Cette méthode reçoit un nombre arbitraire de noms d'actions, et un hash d'options facultatif en dernier argument. Avec l'appel à `extract_options!`, vous obtenez le hash d'options et le supprimez de `actions` de manière simple et explicite.

NOTE: Défini dans `active_support/core_ext/array/extract_options.rb`.


### Conversions

#### `to_sentence`

La méthode [`to_sentence`][Array#to_sentence] transforme un tableau en une chaîne de caractères contenant une phrase qui énumère ses éléments :

```ruby
%w().to_sentence                # => ""
%w(Earth).to_sentence           # => "Earth"
%w(Earth Wind).to_sentence      # => "Earth and Wind"
%w(Earth Wind Fire).to_sentence # => "Earth, Wind, and Fire"
```

Cette méthode accepte trois options :

* `:two_words_connector` : Ce qui est utilisé pour les tableaux de longueur 2. Par défaut, c'est " et ".
* `:words_connector` : Ce qui est utilisé pour joindre les éléments des tableaux avec 3 éléments ou plus, sauf les deux derniers. Par défaut, c'est ", ".
* `:last_word_connector` : Ce qui est utilisé pour joindre les derniers éléments d'un tableau avec 3 éléments ou plus. Par défaut, c'est ", and ".

Les valeurs par défaut de ces options peuvent être localisées, leurs clés sont :

| Option                 | Clé I18n                            |
| ---------------------- | ----------------------------------- |
| `:two_words_connector` | `support.array.two_words_connector` |
| `:words_connector`     | `support.array.words_connector`     |
| `:last_word_connector` | `support.array.last_word_connector` |

NOTE: Défini dans `active_support/core_ext/array/conversions.rb`.


#### `to_fs`

La méthode [`to_fs`][Array#to_fs] agit comme `to_s` par défaut.

Si le tableau contient des éléments qui répondent à `id`, cependant, le symbole
`:db` peut être passé en argument. C'est généralement utilisé avec
des collections d'objets Active Record. Les chaînes retournées sont :

```ruby
[].to_fs(:db)            # => "null"
[user].to_fs(:db)        # => "8456"
invoice.lines.to_fs(:db) # => "23,567,556,12"
```

Les entiers dans l'exemple ci-dessus sont censés provenir des appels respectifs à `id`.

NOTE: Défini dans `active_support/core_ext/array/conversions.rb`.


#### `to_xml`

La méthode [`to_xml`][Array#to_xml] renvoie une chaîne de caractères contenant une représentation XML de son récepteur :

```ruby
Contributor.limit(2).order(:rank).to_xml
# =>
# <?xml version="1.0" encoding="UTF-8"?>
# <contributors type="array">
#   <contributor>
#     <id type="integer">4356</id>
#     <name>Jeremy Kemper</name>
#     <rank type="integer">1</rank>
#     <url-id>jeremy-kemper</url-id>
#   </contributor>
#   <contributor>
#     <id type="integer">4404</id>
#     <name>David Heinemeier Hansson</name>
#     <rank type="integer">2</rank>
#     <url-id>david-heinemeier-hansson</url-id>
#   </contributor>
# </contributors>
```

Pour ce faire, elle envoie `to_xml` à chaque élément à tour de rôle, et collecte les résultats sous un nœud racine. Tous les éléments doivent répondre à `to_xml`, sinon une exception est levée.

Par défaut, le nom de l'élément racine est le pluriel en underscore et en tiret du nom de la classe du premier élément, à condition que le reste des éléments appartiennent à ce type (vérifié avec `is_a?`) et qu'ils ne soient pas des hashes. Dans l'exemple ci-dessus, il s'agit de "contributors".

S'il y a un élément qui n'appartient pas au type du premier, le nœud racine devient "objects" :

```ruby
[Contributor.first, Commit.first].to_xml
# =>
# <?xml version="1.0" encoding="UTF-8"?>
# <objects type="array">
#   <object>
#     <id type="integer">4583</id>
#     <name>Aaron Batalion</name>
#     <rank type="integer">53</rank>
#     <url-id>aaron-batalion</url-id>
#   </object>
#   <object>
#     <author>Joshua Peek</author>
#     <authored-timestamp type="datetime">2009-09-02T16:44:36Z</authored-timestamp>
#     <branch>origin/master</branch>
#     <committed-timestamp type="datetime">2009-09-02T16:44:36Z</committed-timestamp>
#     <committer>Joshua Peek</committer>
#     <git-show nil="true"></git-show>
#     <id type="integer">190316</id>
#     <imported-from-svn type="boolean">false</imported-from-svn>
#     <message>Kill AMo observing wrap_with_notifications since ARes was only using it</message>
#     <sha1>723a47bfb3708f968821bc969a9a3fc873a3ed58</sha1>
#   </object>
# </objects>
```
Si le récepteur est un tableau de hachages, l'élément racine est par défaut également "objects":

```ruby
[{ a: 1, b: 2 }, { c: 3 }].to_xml
# =>
# <?xml version="1.0" encoding="UTF-8"?>
# <objects type="array">
#   <object>
#     <b type="integer">2</b>
#     <a type="integer">1</a>
#   </object>
#   <object>
#     <c type="integer">3</c>
#   </object>
# </objects>
```

ATTENTION. Si la collection est vide, l'élément racine est par défaut "nil-classes". C'est un piège, par exemple, l'élément racine de la liste des contributeurs ci-dessus ne serait pas "contributeurs" si la collection était vide, mais "nil-classes". Vous pouvez utiliser l'option `:root` pour garantir un élément racine cohérent.

Le nom des nœuds enfants est par défaut le nom du nœud racine au singulier. Dans les exemples ci-dessus, nous avons vu "contributeur" et "objet". L'option `:children` vous permet de définir ces noms de nœuds.

Le générateur XML par défaut est une nouvelle instance de `Builder::XmlMarkup`. Vous pouvez configurer votre propre générateur via l'option `:builder`. La méthode accepte également des options telles que `:dasherize` et autres, qui sont transmises au générateur:

```ruby
Contributor.limit(2).order(:rank).to_xml(skip_types: true)
# =>
# <?xml version="1.0" encoding="UTF-8"?>
# <contributors>
#   <contributor>
#     <id>4356</id>
#     <name>Jeremy Kemper</name>
#     <rank>1</rank>
#     <url-id>jeremy-kemper</url-id>
#   </contributor>
#   <contributor>
#     <id>4404</id>
#     <name>David Heinemeier Hansson</name>
#     <rank>2</rank>
#     <url-id>david-heinemeier-hansson</url-id>
#   </contributor>
# </contributors>
```

NOTE: Défini dans `active_support/core_ext/array/conversions.rb`.


### Enveloppement

La méthode [`Array.wrap`][Array.wrap] enveloppe son argument dans un tableau à moins qu'il ne soit déjà un tableau (ou similaire à un tableau).

Plus précisément:

* Si l'argument est `nil`, un tableau vide est renvoyé.
* Sinon, si l'argument répond à `to_ary`, il est invoqué, et si la valeur de `to_ary` n'est pas `nil`, elle est renvoyée.
* Sinon, un tableau avec l'argument comme unique élément est renvoyé.

```ruby
Array.wrap(nil)       # => []
Array.wrap([1, 2, 3]) # => [1, 2, 3]
Array.wrap(0)         # => [0]
```

Cette méthode est similaire à `Kernel#Array`, mais il y a quelques différences:

* Si l'argument répond à `to_ary`, la méthode est invoquée. `Kernel#Array` passe à `to_a` si la valeur renvoyée est `nil`, mais `Array.wrap` renvoie immédiatement un tableau avec l'argument comme unique élément.
* Si la valeur renvoyée par `to_ary` n'est ni `nil` ni un objet `Array`, `Kernel#Array` génère une exception, tandis que `Array.wrap` ne le fait pas, il renvoie simplement la valeur.
* Elle n'appelle pas `to_a` sur l'argument, si l'argument ne répond pas à `to_ary`, elle renvoie un tableau avec l'argument comme unique élément.

Le dernier point vaut particulièrement la peine d'être comparé pour certaines énumérations:

```ruby
Array.wrap(foo: :bar) # => [{:foo=>:bar}]
Array(foo: :bar)      # => [[:foo, :bar]]
```

Il existe également une expression idiomatique connexe qui utilise l'opérateur splat:

```ruby
[*object]
```

NOTE: Défini dans `active_support/core_ext/array/wrap.rb`.


### Duplication

La méthode [`Array#deep_dup`][Array#deep_dup] duplique elle-même et tous les objets à l'intérieur de manière récursive avec la méthode Active Support `Object#deep_dup`. Elle fonctionne comme `Array#map`, en envoyant la méthode `deep_dup` à chaque objet à l'intérieur.

```ruby
array = [1, [2, 3]]
dup = array.deep_dup
dup[1][2] = 4
array[1][2] == nil   # => true
```

NOTE: Défini dans `active_support/core_ext/object/deep_dup.rb`.


### Groupement

#### `in_groups_of(number, fill_with = nil)`

La méthode [`in_groups_of`][Array#in_groups_of] divise un tableau en groupes consécutifs d'une certaine taille. Elle renvoie un tableau avec les groupes:

```ruby
[1, 2, 3].in_groups_of(2) # => [[1, 2], [3, nil]]
```

ou les renvoie un par un si un bloc est passé:

```html+erb
<% sample.in_groups_of(3) do |a, b, c| %>
  <tr>
    <td><%= a %></td>
    <td><%= b %></td>
    <td><%= c %></td>
  </tr>
<% end %>
```

Le premier exemple montre comment `in_groups_of` remplit le dernier groupe avec autant d'éléments `nil` que nécessaire pour obtenir la taille demandée. Vous pouvez modifier cette valeur de remplissage en utilisant le deuxième argument facultatif:

```ruby
[1, 2, 3].in_groups_of(2, 0) # => [[1, 2], [3, 0]]
```

Et vous pouvez indiquer à la méthode de ne pas remplir le dernier groupe en passant `false`:

```ruby
[1, 2, 3].in_groups_of(2, false) # => [[1, 2], [3]]
```

Par conséquent, `false` ne peut pas être utilisé comme valeur de remplissage.

NOTE: Défini dans `active_support/core_ext/array/grouping.rb`.


#### `in_groups(number, fill_with = nil)`

La méthode [`in_groups`][Array#in_groups] divise un tableau en un certain nombre de groupes. La méthode renvoie un tableau avec les groupes:

```ruby
%w(1 2 3 4 5 6 7).in_groups(3)
# => [["1", "2", "3"], ["4", "5", nil], ["6", "7", nil]]
```

ou les renvoie à tour de rôle si un bloc est passé :

```ruby
%w(1 2 3 4 5 6 7).in_groups(3) { |group| p group }
["1", "2", "3"]
["4", "5", nil]
["6", "7", nil]
```

Les exemples ci-dessus montrent que `in_groups` remplit certains groupes avec un élément `nil` supplémentaire si nécessaire. Un groupe peut avoir au plus un de ces éléments supplémentaires, le plus à droite s'il y en a. Et les groupes qui les ont sont toujours les derniers.

Vous pouvez changer cette valeur de remplissage en utilisant le deuxième argument facultatif :

```ruby
%w(1 2 3 4 5 6 7).in_groups(3, "0")
# => [["1", "2", "3"], ["4", "5", "0"], ["6", "7", "0"]]
```

Et vous pouvez indiquer à la méthode de ne pas remplir les groupes plus petits en passant `false` :

```ruby
%w(1 2 3 4 5 6 7).in_groups(3, false)
# => [["1", "2", "3"], ["4", "5"], ["6", "7"]]
```

Par conséquent, `false` ne peut pas être utilisé comme valeur de remplissage.

NOTE : Défini dans `active_support/core_ext/array/grouping.rb`.


#### `split(value = nil)`

La méthode [`split`][Array#split] divise un tableau par un séparateur et renvoie les morceaux résultants.

Si un bloc est passé, les séparateurs sont les éléments du tableau pour lesquels le bloc renvoie true :

```ruby
(-5..5).to_a.split { |i| i.multiple_of?(4) }
# => [[-5], [-3, -2, -1], [1, 2, 3], [5]]
```

Sinon, la valeur reçue en argument, qui est par défaut `nil`, est le séparateur :

```ruby
[0, 1, -5, 1, 1, "foo", "bar"].split(1)
# => [[0], [-5], [], ["foo", "bar"]]
```

CONSEIL : Remarquez dans l'exemple précédent que les séparateurs consécutifs donnent des tableaux vides.

NOTE : Défini dans `active_support/core_ext/array/grouping.rb`.


Extensions pour `Hash`
--------------------

### Conversions

#### `to_xml`

La méthode [`to_xml`][Hash#to_xml] renvoie une chaîne de caractères contenant une représentation XML de son objet :

```ruby
{ foo: 1, bar: 2 }.to_xml
# =>
# <?xml version="1.0" encoding="UTF-8"?>
# <hash>
#   <foo type="integer">1</foo>
#   <bar type="integer">2</bar>
# </hash>
```

Pour ce faire, la méthode parcourt les paires et construit des nœuds qui dépendent des _valeurs_. Étant donné une paire `clé`, `valeur` :

* Si `valeur` est un hash, il y a un appel récursif avec `clé` comme `:root`.

* Si `valeur` est un tableau, il y a un appel récursif avec `clé` comme `:root`, et `clé` au singulier comme `:children`.

* Si `valeur` est un objet appelable, il doit attendre un ou deux arguments. Selon l'arité, l'objet appelable est invoqué avec le hash `options` comme premier argument avec `clé` comme `:root`, et `clé` au singulier comme deuxième argument. Sa valeur de retour devient un nouveau nœud.

* Si `valeur` répond à `to_xml`, la méthode est invoquée avec `clé` comme `:root`.

* Sinon, un nœud avec `clé` comme balise est créé avec une représentation sous forme de chaîne de caractères de `valeur` comme nœud de texte. Si `valeur` est `nil`, un attribut "nil" défini sur "true" est ajouté. Sauf si l'option `:skip_types` existe et est true, un attribut "type" est également ajouté selon la correspondance suivante :

```ruby
XML_TYPE_NAMES = {
  "Symbol"     => "symbol",
  "Integer"    => "integer",
  "BigDecimal" => "decimal",
  "Float"      => "float",
  "TrueClass"  => "boolean",
  "FalseClass" => "boolean",
  "Date"       => "date",
  "DateTime"   => "datetime",
  "Time"       => "datetime"
}
```

Par défaut, le nœud racine est "hash", mais cela peut être configuré via l'option `:root`.

Le générateur XML par défaut est une nouvelle instance de `Builder::XmlMarkup`. Vous pouvez configurer votre propre générateur avec l'option `:builder`. La méthode accepte également des options telles que `:dasherize` et autres, qui sont transmises au générateur.

NOTE : Défini dans `active_support/core_ext/hash/conversions.rb`.


### Fusion

Ruby dispose d'une méthode intégrée `Hash#merge` qui fusionne deux hashes :

```ruby
{ a: 1, b: 1 }.merge(a: 0, c: 2)
# => {:a=>0, :b=>1, :c=>2}
```

Active Support définit quelques autres façons de fusionner des hashes qui peuvent être pratiques.

#### `reverse_merge` et `reverse_merge!`

En cas de collision, la clé dans le hash de l'argument l'emporte dans `merge`. Vous pouvez prendre en charge les hashes d'options avec des valeurs par défaut de manière compacte avec cette expression :

```ruby
options = { length: 30, omission: "..." }.merge(options)
```

Active Support définit [`reverse_merge`][Hash#reverse_merge] au cas où vous préférez cette notation alternative :

```ruby
options = options.reverse_merge(length: 30, omission: "...")
```

Et une version bang [`reverse_merge!`][Hash#reverse_merge!] qui effectue la fusion sur place :

```ruby
options.reverse_merge!(length: 30, omission: "...")
```

ATTENTION. Prenez en compte que `reverse_merge!` peut modifier le hash dans l'appelant, ce qui peut être une bonne ou une mauvaise idée.

NOTE : Défini dans `active_support/core_ext/hash/reverse_merge.rb`.
#### `reverse_update`

La méthode [`reverse_update`][Hash#reverse_update] est un alias de `reverse_merge!`, expliqué ci-dessus.

ATTENTION. Notez que `reverse_update` n'a pas de bang.

NOTE: Défini dans `active_support/core_ext/hash/reverse_merge.rb`.


#### `deep_merge` et `deep_merge!`

Comme vous pouvez le voir dans l'exemple précédent, si une clé est présente dans les deux hachages, la valeur du hachage en argument l'emporte.

Active Support définit [`Hash#deep_merge`][Hash#deep_merge]. Lors d'une fusion profonde, si une clé est présente dans les deux hachages et que leurs valeurs sont elles-mêmes des hachages, leur _fusion_ devient la valeur dans le hachage résultant :

```ruby
{ a: { b: 1 } }.deep_merge(a: { c: 2 })
# => {:a=>{:b=>1, :c=>2}}
```

La méthode [`deep_merge!`][Hash#deep_merge!] effectue une fusion profonde sur place.

NOTE: Défini dans `active_support/core_ext/hash/deep_merge.rb`.


### Duplication profonde

La méthode [`Hash#deep_dup`][Hash#deep_dup] duplique elle-même et toutes les clés et valeurs à l'intérieur de manière récursive avec la méthode `Object#deep_dup` d'Active Support. Elle fonctionne comme `Enumerator#each_with_object` en envoyant la méthode `deep_dup` à chaque paire à l'intérieur.

```ruby
hash = { a: 1, b: { c: 2, d: [3, 4] } }

dup = hash.deep_dup
dup[:b][:e] = 5
dup[:b][:d] << 5

hash[:b][:e] == nil      # => true
hash[:b][:d] == [3, 4]   # => true
```

NOTE: Défini dans `active_support/core_ext/object/deep_dup.rb`.


### Travailler avec les clés

#### `except` et `except!`

La méthode [`except`][Hash#except] renvoie un hachage avec les clés de la liste d'arguments supprimées, si elles sont présentes :

```ruby
{ a: 1, b: 2 }.except(:a) # => {:b=>2}
```

Si le récepteur répond à `convert_key`, la méthode est appelée sur chacun des arguments. Cela permet à `except` de fonctionner correctement avec les hachages à accès indifférent par exemple :

```ruby
{ a: 1 }.with_indifferent_access.except(:a)  # => {}
{ a: 1 }.with_indifferent_access.except("a") # => {}
```

Il existe également la variante avec bang [`except!`][Hash#except!] qui supprime les clés sur place.

NOTE: Défini dans `active_support/core_ext/hash/except.rb`.


#### `stringify_keys` et `stringify_keys!`

La méthode [`stringify_keys`][Hash#stringify_keys] renvoie un hachage dont les clés du récepteur sont converties en chaînes de caractères. Elle le fait en envoyant `to_s` à chaque clé :

```ruby
{ nil => nil, 1 => 1, a: :a }.stringify_keys
# => {"" => nil, "1" => 1, "a" => :a}
```

En cas de collision de clés, la valeur sera celle qui a été insérée le plus récemment dans le hachage :

```ruby
{ "a" => 1, a: 2 }.stringify_keys
# Le résultat sera
# => {"a"=>2}
```

Cette méthode peut être utile, par exemple, pour accepter facilement à la fois des symboles et des chaînes de caractères en tant qu'options. Par exemple, `ActionView::Helpers::FormHelper` définit :

```ruby
def to_check_box_tag(options = {}, checked_value = "1", unchecked_value = "0")
  options = options.stringify_keys
  options["type"] = "checkbox"
  # ...
end
```

La deuxième ligne peut accéder en toute sécurité à la clé "type" et permettre à l'utilisateur de passer soit `:type` soit "type".

Il existe également la variante avec bang [`stringify_keys!`][Hash#stringify_keys!] qui convertit les clés en chaînes de caractères sur place.

En plus de cela, on peut utiliser [`deep_stringify_keys`][Hash#deep_stringify_keys] et [`deep_stringify_keys!`][Hash#deep_stringify_keys!] pour convertir en chaînes de caractères toutes les clés du hachage donné et tous les hachages qui y sont imbriqués. Un exemple du résultat est :

```ruby
{ nil => nil, 1 => 1, nested: { a: 3, 5 => 5 } }.deep_stringify_keys
# => {""=>nil, "1"=>1, "nested"=>{"a"=>3, "5"=>5}}
```

NOTE: Défini dans `active_support/core_ext/hash/keys.rb`.


#### `symbolize_keys` et `symbolize_keys!`

La méthode [`symbolize_keys`][Hash#symbolize_keys] renvoie un hachage dont les clés du récepteur sont symbolisées, dans la mesure du possible. Elle le fait en envoyant `to_sym` à chaque clé :

```ruby
{ nil => nil, 1 => 1, "a" => "a" }.symbolize_keys
# => {nil=>nil, 1=>1, :a=>"a"}
```

ATTENTION. Notez que dans l'exemple précédent, une seule clé a été symbolisée.

En cas de collision de clés, la valeur sera celle qui a été insérée le plus récemment dans le hachage :

```ruby
{ "a" => 1, a: 2 }.symbolize_keys
# => {:a=>2}
```

Cette méthode peut être utile, par exemple, pour accepter facilement à la fois des symboles et des chaînes de caractères en tant qu'options. Par exemple, `ActionText::TagHelper` définit :

```ruby
def rich_text_area_tag(name, value = nil, options = {})
  options = options.symbolize_keys

  options[:input] ||= "trix_input_#{ActionText::TagHelper.id += 1}"
  # ...
end
```

La troisième ligne peut accéder en toute sécurité à la clé `:input` et permettre à l'utilisateur de passer soit `:input` soit "input".

Il existe également la variante avec bang [`symbolize_keys!`][Hash#symbolize_keys!] qui symbolise les clés sur place.

En plus de cela, on peut utiliser [`deep_symbolize_keys`][Hash#deep_symbolize_keys] et [`deep_symbolize_keys!`][Hash#deep_symbolize_keys!] pour symboliser toutes les clés du hachage donné et tous les hachages qui y sont imbriqués. Un exemple du résultat est :

```ruby
{ nil => nil, 1 => 1, "nested" => { "a" => 3, 5 => 5 } }.deep_symbolize_keys
# => {nil=>nil, 1=>1, nested:{a:3, 5=>5}}
```
NOTE: Défini dans `active_support/core_ext/hash/keys.rb`.


#### `to_options` et `to_options!`

Les méthodes [`to_options`][Hash#to_options] et [`to_options!`][Hash#to_options!] sont des alias de `symbolize_keys` et `symbolize_keys!`, respectivement.

NOTE: Défini dans `active_support/core_ext/hash/keys.rb`.


#### `assert_valid_keys`

La méthode [`assert_valid_keys`][Hash#assert_valid_keys] reçoit un nombre arbitraire d'arguments et vérifie si le récepteur a une clé en dehors de cette liste. Si c'est le cas, une `ArgumentError` est levée.

```ruby
{ a: 1 }.assert_valid_keys(:a)  # passe
{ a: 1 }.assert_valid_keys("a") # ArgumentError
```

Active Record n'accepte pas les options inconnues lors de la construction d'associations, par exemple. Il implémente ce contrôle via `assert_valid_keys`.

NOTE: Défini dans `active_support/core_ext/hash/keys.rb`.


### Travailler avec les valeurs

#### `deep_transform_values` et `deep_transform_values!`

La méthode [`deep_transform_values`][Hash#deep_transform_values] renvoie un nouveau hash avec toutes les valeurs converties par l'opération du bloc. Cela inclut les valeurs du hash racine et de tous les hashes et tableaux imbriqués.

```ruby
hash = { person: { name: 'Rob', age: '28' } }

hash.deep_transform_values { |value| value.to_s.upcase }
# => {person: {name: "ROB", age: "28"}}
```

Il existe également la variante destructive [`deep_transform_values!`][Hash#deep_transform_values!] qui convertit toutes les valeurs de manière destructive en utilisant l'opération du bloc.

NOTE: Défini dans `active_support/core_ext/hash/deep_transform_values.rb`.


### Découpage

La méthode [`slice!`][Hash#slice!] remplace le hash par les clés données et renvoie un hash contenant les paires clé/valeur supprimées.

```ruby
hash = { a: 1, b: 2 }
rest = hash.slice!(:a) # => {:b=>2}
hash                   # => {:a=>1}
```

NOTE: Défini dans `active_support/core_ext/hash/slice.rb`.


### Extraction

La méthode [`extract!`][Hash#extract!] supprime et renvoie les paires clé/valeur correspondant aux clés données.

```ruby
hash = { a: 1, b: 2 }
rest = hash.extract!(:a) # => {:a=>1}
hash                     # => {:b=>2}
```

La méthode `extract!` renvoie la même sous-classe de Hash que le récepteur.

```ruby
hash = { a: 1, b: 2 }.with_indifferent_access
rest = hash.extract!(:a).class
# => ActiveSupport::HashWithIndifferentAccess
```

NOTE: Défini dans `active_support/core_ext/hash/slice.rb`.


### Accès indifférent

La méthode [`with_indifferent_access`][Hash#with_indifferent_access] renvoie un [`ActiveSupport::HashWithIndifferentAccess`][ActiveSupport::HashWithIndifferentAccess] à partir de son récepteur :

```ruby
{ a: 1 }.with_indifferent_access["a"] # => 1
```

NOTE: Défini dans `active_support/core_ext/hash/indifferent_access.rb`.


Extensions à `Regexp`
----------------------

### `multiline?`

La méthode [`multiline?`][Regexp#multiline?] indique si une expression régulière a le drapeau `/m` activé, c'est-à-dire si le point correspond aux sauts de ligne.

```ruby
%r{.}.multiline?  # => false
%r{.}m.multiline? # => true

Regexp.new('.').multiline?                    # => false
Regexp.new('.', Regexp::MULTILINE).multiline? # => true
```

Rails utilise cette méthode à un seul endroit, également dans le code de routage. Les expressions régulières multilignes ne sont pas autorisées pour les exigences de route et ce drapeau facilite l'application de cette contrainte.

```ruby
def verify_regexp_requirements(requirements)
  # ...
  if requirement.multiline?
    raise ArgumentError, "Regexp multiline option is not allowed in routing requirements: #{requirement.inspect}"
  end
  # ...
end
```

NOTE: Défini dans `active_support/core_ext/regexp.rb`.


Extensions à `Range`
---------------------

### `to_fs`

Active Support définit `Range#to_fs` comme une alternative à `to_s` qui comprend un argument de format facultatif. Au moment de la rédaction de cet article, le seul format non par défaut pris en charge est `:db` :

```ruby
(Date.today..Date.tomorrow).to_fs
# => "2009-10-25..2009-10-26"

(Date.today..Date.tomorrow).to_fs(:db)
# => "BETWEEN '2009-10-25' AND '2009-10-26'"
```

Comme l'exemple le montre, le format `:db` génère une clause SQL `BETWEEN`. Cela est utilisé par Active Record dans sa prise en charge des valeurs de plage dans les conditions.

NOTE: Défini dans `active_support/core_ext/range/conversions.rb`.

### `===` et `include?`

Les méthodes `Range#===` et `Range#include?` indiquent si une valeur se situe entre les extrémités d'une instance donnée :

```ruby
(2..3).include?(Math::E) # => true
```

Active Support étend ces méthodes de sorte que l'argument puisse être à son tour une autre plage. Dans ce cas, nous testons si les extrémités de la plage argument appartiennent elles-mêmes au récepteur :

```ruby
(1..10) === (3..7)  # => true
(1..10) === (0..7)  # => false
(1..10) === (3..11) # => false
(1...9) === (3..9)  # => false

(1..10).include?(3..7)  # => true
(1..10).include?(0..7)  # => false
(1..10).include?(3..11) # => false
(1...9).include?(3..9)  # => false
```

NOTE: Défini dans `active_support/core_ext/range/compare_range.rb`.

### `overlap?`

La méthode [`Range#overlap?`][Range#overlap?] indique si deux plages données ont une intersection non vide :

```ruby
(1..10).overlap?(7..11)  # => true
(1..10).overlap?(0..7)   # => true
(1..10).overlap?(11..27) # => false
```

NOTE: Défini dans `active_support/core_ext/range/overlap.rb`.


Extensions à `Date`
--------------------

### Calculs

INFO: Les méthodes de calcul suivantes ont des cas particuliers en octobre 1582, car les jours 5 à 14 n'existent tout simplement pas. Ce guide ne documente pas leur comportement autour de ces jours pour des raisons de concision, mais il suffit de dire qu'ils font ce que vous attendez. C'est-à-dire que `Date.new(1582, 10, 4).tomorrow` renvoie `Date.new(1582, 10, 15)` et ainsi de suite. Veuillez consulter `test/core_ext/date_ext_test.rb` dans la suite de tests Active Support pour connaître le comportement attendu.

#### `Date.current`

Active Support définit [`Date.current`][Date.current] comme étant aujourd'hui dans le fuseau horaire actuel. C'est comme `Date.today`, sauf qu'il respecte le fuseau horaire de l'utilisateur, s'il est défini. Il définit également [`Date.yesterday`][Date.yesterday] et [`Date.tomorrow`][Date.tomorrow], ainsi que les prédicats d'instance [`past?`][DateAndTime::Calculations#past?], [`today?`][DateAndTime::Calculations#today?], [`tomorrow?`][DateAndTime::Calculations#tomorrow?], [`next_day?`][DateAndTime::Calculations#next_day?], [`yesterday?`][DateAndTime::Calculations#yesterday?], [`prev_day?`][DateAndTime::Calculations#prev_day?], [`future?`][DateAndTime::Calculations#future?], [`on_weekday?`][DateAndTime::Calculations#on_weekday?] et [`on_weekend?`][DateAndTime::Calculations#on_weekend?], tous relatifs à `Date.current`.
Lorsque vous effectuez des comparaisons de dates en utilisant des méthodes qui respectent le fuseau horaire de l'utilisateur, assurez-vous d'utiliser `Date.current` et non `Date.today`. Il existe des cas où le fuseau horaire de l'utilisateur peut être dans le futur par rapport au fuseau horaire du système, que `Date.today` utilise par défaut. Cela signifie que `Date.today` peut être égal à `Date.yesterday`.

NOTE : Défini dans `active_support/core_ext/date/calculations.rb`.


#### Dates nommées

##### `beginning_of_week`, `end_of_week`

Les méthodes [`beginning_of_week`][DateAndTime::Calculations#beginning_of_week] et [`end_of_week`][DateAndTime::Calculations#end_of_week] renvoient les dates du début et de la fin de la semaine, respectivement. Les semaines sont supposées commencer le lundi, mais cela peut être modifié en passant un argument, en définissant `Date.beginning_of_week` ou [`config.beginning_of_week`][].

```ruby
d = Date.new(2010, 5, 8)     # => sam. 08 mai 2010
d.beginning_of_week          # => lun. 03 mai 2010
d.beginning_of_week(:sunday) # => dim. 02 mai 2010
d.end_of_week                # => dim. 09 mai 2010
d.end_of_week(:sunday)       # => sam. 08 mai 2010
```

`beginning_of_week` est un alias de [`at_beginning_of_week`][DateAndTime::Calculations#at_beginning_of_week] et `end_of_week` est un alias de [`at_end_of_week`][DateAndTime::Calculations#at_end_of_week].

NOTE : Défini dans `active_support/core_ext/date_and_time/calculations.rb`.


##### `monday`, `sunday`

Les méthodes [`monday`][DateAndTime::Calculations#monday] et [`sunday`][DateAndTime::Calculations#sunday] renvoient les dates du lundi précédent et du dimanche suivant, respectivement.

```ruby
d = Date.new(2010, 5, 8)     # => sam. 08 mai 2010
d.monday                     # => lun. 03 mai 2010
d.sunday                     # => dim. 09 mai 2010

d = Date.new(2012, 9, 10)    # => lun. 10 sept. 2012
d.monday                     # => lun. 10 sept. 2012

d = Date.new(2012, 9, 16)    # => dim. 16 sept. 2012
d.sunday                     # => dim. 16 sept. 2012
```

NOTE : Défini dans `active_support/core_ext/date_and_time/calculations.rb`.


##### `prev_week`, `next_week`

La méthode [`next_week`][DateAndTime::Calculations#next_week] reçoit un symbole avec un nom de jour en anglais (par défaut, c'est le [`Date.beginning_of_week`][Date.beginning_of_week] local au thread, ou [`config.beginning_of_week`][], ou `:monday`) et renvoie la date correspondante à ce jour.

```ruby
d = Date.new(2010, 5, 9) # => dim. 09 mai 2010
d.next_week              # => lun. 10 mai 2010
d.next_week(:saturday)   # => sam. 15 mai 2010
```

La méthode [`prev_week`][DateAndTime::Calculations#prev_week] est analogue :

```ruby
d.prev_week              # => lun. 26 avr. 2010
d.prev_week(:saturday)   # => sam. 01 mai 2010
d.prev_week(:friday)     # => ven. 30 avr. 2010
```

`prev_week` est un alias de [`last_week`][DateAndTime::Calculations#last_week].

`next_week` et `prev_week` fonctionnent comme prévu lorsque `Date.beginning_of_week` ou `config.beginning_of_week` sont définis.

NOTE : Défini dans `active_support/core_ext/date_and_time/calculations.rb`.


##### `beginning_of_month`, `end_of_month`

Les méthodes [`beginning_of_month`][DateAndTime::Calculations#beginning_of_month] et [`end_of_month`][DateAndTime::Calculations#end_of_month] renvoient les dates du début et de la fin du mois :

```ruby
d = Date.new(2010, 5, 9) # => dim. 09 mai 2010
d.beginning_of_month     # => sam. 01 mai 2010
d.end_of_month           # => lun. 31 mai 2010
```

`beginning_of_month` est un alias de [`at_beginning_of_month`][DateAndTime::Calculations#at_beginning_of_month], et `end_of_month` est un alias de [`at_end_of_month`][DateAndTime::Calculations#at_end_of_month].

NOTE : Défini dans `active_support/core_ext/date_and_time/calculations.rb`.


##### `quarter`, `beginning_of_quarter`, `end_of_quarter`

La méthode [`quarter`][DateAndTime::Calculations#quarter] renvoie le trimestre de l'année civile du récepteur :

```ruby
d = Date.new(2010, 5, 9) # => dim. 09 mai 2010
d.quarter                # => 2
```

Les méthodes [`beginning_of_quarter`][DateAndTime::Calculations#beginning_of_quarter] et [`end_of_quarter`][DateAndTime::Calculations#end_of_quarter] renvoient les dates du début et de la fin du trimestre de l'année civile du récepteur :

```ruby
d = Date.new(2010, 5, 9) # => dim. 09 mai 2010
d.beginning_of_quarter   # => jeu. 01 avr. 2010
d.end_of_quarter         # => mer. 30 juin 2010
```

`beginning_of_quarter` est un alias de [`at_beginning_of_quarter`][DateAndTime::Calculations#at_beginning_of_quarter], et `end_of_quarter` est un alias de [`at_end_of_quarter`][DateAndTime::Calculations#at_end_of_quarter].

NOTE : Défini dans `active_support/core_ext/date_and_time/calculations.rb`.


##### `beginning_of_year`, `end_of_year`

Les méthodes [`beginning_of_year`][DateAndTime::Calculations#beginning_of_year] et [`end_of_year`][DateAndTime::Calculations#end_of_year] renvoient les dates du début et de la fin de l'année :

```ruby
d = Date.new(2010, 5, 9) # => dim. 09 mai 2010
d.beginning_of_year      # => ven. 01 janv. 2010
d.end_of_year            # => ven. 31 déc. 2010
```

`beginning_of_year` est un alias de [`at_beginning_of_year`][DateAndTime::Calculations#at_beginning_of_year], et `end_of_year` est un alias de [`at_end_of_year`][DateAndTime::Calculations#at_end_of_year].

NOTE : Défini dans `active_support/core_ext/date_and_time/calculations.rb`.


#### Autres calculs de dates

##### `years_ago`, `years_since`

La méthode [`years_ago`][DateAndTime::Calculations#years_ago] reçoit un nombre d'années et renvoie la même date il y a autant d'années :

```ruby
date = Date.new(2010, 6, 7)
date.years_ago(10) # => mer. 07 juin 2000
```

[`years_since`][DateAndTime::Calculations#years_since] avance dans le temps :

```ruby
date = Date.new(2010, 6, 7)
date.years_since(10) # => dim. 07 juin 2020
```

Si un tel jour n'existe pas, le dernier jour du mois correspondant est renvoyé :

```ruby
Date.new(2012, 2, 29).years_ago(3)     # => sam. 28 févr. 2009
Date.new(2012, 2, 29).years_since(3)   # => sam. 28 févr. 2015
```

[`last_year`][DateAndTime::Calculations#last_year] est un raccourci pour `#years_ago(1)`.

NOTE : Défini dans `active_support/core_ext/date_and_time/calculations.rb`.


##### `months_ago`, `months_since`

Les méthodes [`months_ago`][DateAndTime::Calculations#months_ago] et [`months_since`][DateAndTime::Calculations#months_since] fonctionnent de manière analogue pour les mois :

```ruby
Date.new(2010, 4, 30).months_ago(2)   # => dim. 28 févr. 2010
Date
Si un tel jour n'existe pas, le dernier jour du mois correspondant est renvoyé:

```ruby
Date.new(2010, 4, 30).months_ago(2)    # => Dim, 28 Fév 2010
Date.new(2009, 12, 31).months_since(2) # => Dim, 28 Fév 2010
```

[`last_month`][DateAndTime::Calculations#last_month] est un raccourci pour `#months_ago(1)`.

NOTE: Défini dans `active_support/core_ext/date_and_time/calculations.rb`.


##### `weeks_ago`

La méthode [`weeks_ago`][DateAndTime::Calculations#weeks_ago] fonctionne de manière analogue pour les semaines:

```ruby
Date.new(2010, 5, 24).weeks_ago(1)    # => Lun, 17 Mai 2010
Date.new(2010, 5, 24).weeks_ago(2)    # => Lun, 10 Mai 2010
```

NOTE: Défini dans `active_support/core_ext/date_and_time/calculations.rb`.


##### `advance`

La façon la plus générique de passer à d'autres jours est [`advance`][Date#advance]. Cette méthode reçoit un hash avec les clés `:years`, `:months`, `:weeks`, `:days`, et renvoie une date avancée autant que les clés indiquent:

```ruby
date = Date.new(2010, 6, 6)
date.advance(years: 1, weeks: 2)  # => Lun, 20 Juin 2011
date.advance(months: 2, days: -2) # => Mer, 04 Aoû 2010
```

Notez dans l'exemple précédent que les incréments peuvent être négatifs.

NOTE: Défini dans `active_support/core_ext/date/calculations.rb`.


#### Modification des composants

La méthode [`change`][Date#change] vous permet d'obtenir une nouvelle date qui est identique à la date d'origine, à l'exception de l'année, du mois ou du jour donné:

```ruby
Date.new(2010, 12, 23).change(year: 2011, month: 11)
# => Mer, 23 Nov 2011
```

Cette méthode ne tolère pas les dates inexistantes, si le changement est invalide, une `ArgumentError` est levée:

```ruby
Date.new(2010, 1, 31).change(month: 2)
# => ArgumentError: date invalide
```

NOTE: Défini dans `active_support/core_ext/date/calculations.rb`.


#### Durées

Les objets [`Duration`][ActiveSupport::Duration] peuvent être ajoutés et soustraits aux dates:

```ruby
d = Date.current
# => Lun, 09 Aoû 2010
d + 1.year
# => Mar, 09 Aoû 2011
d - 3.hours
# => Dim, 08 Aoû 2010 21:00:00 UTC +00:00
```

Ils se traduisent par des appels à `since` ou `advance`. Par exemple, ici nous obtenons le bon saut dans la réforme du calendrier:

```ruby
Date.new(1582, 10, 4) + 1.day
# => Ven, 15 Oct 1582
```


#### Horodatage

INFO: Les méthodes suivantes renvoient un objet `Time` si possible, sinon un `DateTime`. Si défini, elles respectent le fuseau horaire de l'utilisateur.

##### `beginning_of_day`, `end_of_day`

La méthode [`beginning_of_day`][Date#beginning_of_day] renvoie un horodatage au début de la journée (00:00:00):

```ruby
date = Date.new(2010, 6, 7)
date.beginning_of_day # => Lun Jun 07 00:00:00 +0200 2010
```

La méthode [`end_of_day`][Date#end_of_day] renvoie un horodatage à la fin de la journée (23:59:59):

```ruby
date = Date.new(2010, 6, 7)
date.end_of_day # => Lun Jun 07 23:59:59 +0200 2010
```

`beginning_of_day` est un alias de [`at_beginning_of_day`][Date#at_beginning_of_day], [`midnight`][Date#midnight], [`at_midnight`][Date#at_midnight].

NOTE: Défini dans `active_support/core_ext/date/calculations.rb`.


##### `beginning_of_hour`, `end_of_hour`

La méthode [`beginning_of_hour`][DateTime#beginning_of_hour] renvoie un horodatage au début de l'heure (hh:00:00):

```ruby
date = DateTime.new(2010, 6, 7, 19, 55, 25)
date.beginning_of_hour # => Lun Jun 07 19:00:00 +0200 2010
```

La méthode [`end_of_hour`][DateTime#end_of_hour] renvoie un horodatage à la fin de l'heure (hh:59:59):

```ruby
date = DateTime.new(2010, 6, 7, 19, 55, 25)
date.end_of_hour # => Lun Jun 07 19:59:59 +0200 2010
```

`beginning_of_hour` est un alias de [`at_beginning_of_hour`][DateTime#at_beginning_of_hour].

NOTE: Défini dans `active_support/core_ext/date_time/calculations.rb`.

##### `beginning_of_minute`, `end_of_minute`

La méthode [`beginning_of_minute`][DateTime#beginning_of_minute] renvoie un horodatage au début de la minute (hh:mm:00):

```ruby
date = DateTime.new(2010, 6, 7, 19, 55, 25)
date.beginning_of_minute # => Lun Jun 07 19:55:00 +0200 2010
```

La méthode [`end_of_minute`][DateTime#end_of_minute] renvoie un horodatage à la fin de la minute (hh:mm:59):

```ruby
date = DateTime.new(2010, 6, 7, 19, 55, 25)
date.end_of_minute # => Lun Jun 07 19:55:59 +0200 2010
```

`beginning_of_minute` est un alias de [`at_beginning_of_minute`][DateTime#at_beginning_of_minute].

INFO: `beginning_of_hour`, `end_of_hour`, `beginning_of_minute` et `end_of_minute` sont implémentés pour `Time` et `DateTime` mais **pas** pour `Date` car il n'est pas logique de demander le début ou la fin d'une heure ou d'une minute sur une instance de `Date`.

NOTE: Défini dans `active_support/core_ext/date_time/calculations.rb`.


##### `ago`, `since`

La méthode [`ago`][Date#ago] reçoit un nombre de secondes en argument et renvoie un horodatage correspondant à ces secondes avant minuit:

```ruby
date = Date.current # => Ven, 11 Juin 2010
date.ago(1)         # => Jeu, 10 Juin 2010 23:59:59 EDT -04:00
```

De même, [`since`][Date#since] avance:

```ruby
date = Date.current # => Ven, 11 Juin 2010
date.since(1)       # => Ven, 11 Juin 2010 00:00:01 EDT -04:00
```

NOTE: Défini dans `active_support/core_ext/date/calculations.rb`.


Extensions pour `DateTime`
------------------------

AVERTISSEMENT: `DateTime` n'est pas conscient des règles de l'heure d'été et certaines de ces méthodes ont des cas particuliers lorsqu'un changement d'heure d'été est en cours. Par exemple, [`seconds_since_midnight`][DateTime#seconds_since_midnight] pourrait ne pas renvoyer la quantité réelle dans un tel jour.
### Calculs

La classe `DateTime` est une sous-classe de `Date`, donc en chargeant `active_support/core_ext/date/calculations.rb`, vous héritez de ces méthodes et de leurs alias, à l'exception qu'elles renverront toujours des datetimes.

Les méthodes suivantes sont réimplémentées, vous n'avez donc **pas** besoin de charger `active_support/core_ext/date/calculations.rb` pour celles-ci :

* [`beginning_of_day`][DateTime#beginning_of_day] / [`midnight`][DateTime#midnight] / [`at_midnight`][DateTime#at_midnight] / [`at_beginning_of_day`][DateTime#at_beginning_of_day]
* [`end_of_day`][DateTime#end_of_day]
* [`ago`][DateTime#ago]
* [`since`][DateTime#since] / [`in`][DateTime#in]

En revanche, [`advance`][DateTime#advance] et [`change`][DateTime#change] sont également définis et prennent en charge plus d'options, ils sont documentés ci-dessous.

Les méthodes suivantes sont uniquement implémentées dans `active_support/core_ext/date_time/calculations.rb`, car elles n'ont de sens que lorsqu'elles sont utilisées avec une instance de `DateTime` :

* [`beginning_of_hour`][DateTime#beginning_of_hour] / [`at_beginning_of_hour`][DateTime#at_beginning_of_hour]
* [`end_of_hour`][DateTime#end_of_hour]


#### Datetimes nommés

##### `DateTime.current`

Active Support définit [`DateTime.current`][DateTime.current] pour être similaire à `Time.now.to_datetime`, à l'exception qu'il respecte le fuseau horaire de l'utilisateur, s'il est défini. Les prédicats d'instance [`past?`][DateAndTime::Calculations#past?] et [`future?`][DateAndTime::Calculations#future?] sont définis par rapport à `DateTime.current`.

NOTE : Défini dans `active_support/core_ext/date_time/calculations.rb`.


#### Autres extensions

##### `seconds_since_midnight`

La méthode [`seconds_since_midnight`][DateTime#seconds_since_midnight] renvoie le nombre de secondes depuis minuit :

```ruby
now = DateTime.current     # => Mon, 07 Jun 2010 20:26:36 +0000
now.seconds_since_midnight # => 73596
```

NOTE : Défini dans `active_support/core_ext/date_time/calculations.rb`.


##### `utc`

La méthode [`utc`][DateTime#utc] vous donne le même datetime dans le récepteur exprimé en UTC.

```ruby
now = DateTime.current # => Mon, 07 Jun 2010 19:27:52 -0400
now.utc                # => Mon, 07 Jun 2010 23:27:52 +0000
```

Cette méthode est également aliasée en [`getutc`][DateTime#getutc].

NOTE : Défini dans `active_support/core_ext/date_time/calculations.rb`.


##### `utc?`

Le prédicat [`utc?`][DateTime#utc?] indique si le récepteur a UTC comme fuseau horaire :

```ruby
now = DateTime.now # => Mon, 07 Jun 2010 19:30:47 -0400
now.utc?           # => false
now.utc.utc?       # => true
```

NOTE : Défini dans `active_support/core_ext/date_time/calculations.rb`.


##### `advance`

La façon la plus générique de passer à un autre datetime est [`advance`][DateTime#advance]. Cette méthode reçoit un hash avec les clés `:years`, `:months`, `:weeks`, `:days`, `:hours`, `:minutes` et `:seconds`, et renvoie un datetime avancé autant que les clés actuelles l'indiquent.

```ruby
d = DateTime.current
# => Thu, 05 Aug 2010 11:33:31 +0000
d.advance(years: 1, months: 1, days: 1, hours: 1, minutes: 1, seconds: 1)
# => Tue, 06 Sep 2011 12:34:32 +0000
```

Cette méthode calcule d'abord la date de destination en passant `:years`, `:months`, `:weeks` et `:days` à `Date#advance`, documenté ci-dessus. Ensuite, elle ajuste l'heure en appelant [`since`][DateTime#since] avec le nombre de secondes à avancer. Cet ordre est important, un ordre différent donnerait des datetimes différents dans certains cas particuliers. L'exemple dans `Date#advance` s'applique, et nous pouvons l'étendre pour montrer la pertinence de l'ordre par rapport aux bits de temps.

Si nous déplaçons d'abord les bits de date (qui ont également un ordre relatif de traitement, comme documenté précédemment), puis les bits de temps, nous obtenons par exemple le calcul suivant :

```ruby
d = DateTime.new(2010, 2, 28, 23, 59, 59)
# => Sun, 28 Feb 2010 23:59:59 +0000
d.advance(months: 1, seconds: 1)
# => Mon, 29 Mar 2010 00:00:00 +0000
```

mais si nous les calculons dans l'autre sens, le résultat serait différent :

```ruby
d.advance(seconds: 1).advance(months: 1)
# => Thu, 01 Apr 2010 00:00:00 +0000
```

AVERTISSEMENT : Comme `DateTime` ne prend pas en compte l'heure d'été, vous pouvez vous retrouver à un moment qui n'existe pas sans avertissement ni erreur vous le signalant.

NOTE : Défini dans `active_support/core_ext/date_time/calculations.rb`.


#### Modification des composants

La méthode [`change`][DateTime#change] vous permet d'obtenir un nouveau datetime identique au récepteur, à l'exception des options données, qui peuvent inclure `:year`, `:month`, `:day`, `:hour`, `:min`, `:sec`, `:offset`, `:start` :

```ruby
now = DateTime.current
# => Tue, 08 Jun 2010 01:56:22 +0000
now.change(year: 2011, offset: Rational(-6, 24))
# => Wed, 08 Jun 2011 01:56:22 -0600
```

Si les heures sont mises à zéro, les minutes et les secondes le sont aussi (sauf si elles ont des valeurs données) :

```ruby
now.change(hour: 0)
# => Tue, 08 Jun 2010 00:00:00 +0000
```

De même, si les minutes sont mises à zéro, les secondes le sont aussi (sauf si une valeur est donnée) :

```ruby
now.change(min: 0)
# => Tue, 08 Jun 2010 01:00:00 +0000
```

Cette méthode ne tolère pas les dates inexistantes, si le changement est invalide, une `ArgumentError` est levée :

```ruby
DateTime.current.change(month: 2, day: 30)
# => ArgumentError: invalid date
```

NOTE : Défini dans `active_support/core_ext/date_time/calculations.rb`.


#### Durées

Les objets [`Duration`][ActiveSupport::Duration] peuvent être ajoutés et soustraits des datetimes :

```ruby
now = DateTime.current
# => Mon, 09 Aug 2010 23:15:17 +0000
now + 1.year
# => Tue, 09 Aug 2011 23:15:17 +0000
now - 1.week
# => Mon, 02 Aug 2010 23:15:17 +0000
```
Ils se traduisent par des appels à `since` ou `advance`. Par exemple, ici, nous obtenons le bon saut dans la réforme du calendrier :

```ruby
DateTime.new(1582, 10, 4, 23) + 1.hour
# => Fri, 15 Oct 1582 00:00:00 +0000
```

Extensions à `Time`
--------------------

### Calculs

Ils sont analogues. Veuillez vous référer à leur documentation ci-dessus et prendre en compte les différences suivantes :

* [`change`][Time#change] accepte une option supplémentaire `:usec`.
* `Time` comprend DST, vous obtenez donc des calculs DST corrects comme dans

```ruby
Time.zone_default
# => #<ActiveSupport::TimeZone:0x7f73654d4f38 @utc_offset=nil, @name="Madrid", ...>

# À Barcelone, le 28/03/2010 02:00 +0100 devient le 28/03/2010 03:00 +0200 en raison de DST.
t = Time.local(2010, 3, 28, 1, 59, 59)
# => Sun Mar 28 01:59:59 +0100 2010
t.advance(seconds: 1)
# => Sun Mar 28 03:00:00 +0200 2010
```

* Si [`since`][Time#since] ou [`ago`][Time#ago] saute à un moment qui ne peut pas être exprimé avec `Time`, un objet `DateTime` est renvoyé à la place.


#### `Time.current`

Active Support définit [`Time.current`][Time.current] comme aujourd'hui dans le fuseau horaire actuel. C'est comme `Time.now`, sauf qu'il respecte le fuseau horaire de l'utilisateur, s'il est défini. Il définit également les prédicats d'instance [`past?`][DateAndTime::Calculations#past?], [`today?`][DateAndTime::Calculations#today?], [`tomorrow?`][DateAndTime::Calculations#tomorrow?], [`next_day?`][DateAndTime::Calculations#next_day?], [`yesterday?`][DateAndTime::Calculations#yesterday?], [`prev_day?`][DateAndTime::Calculations#prev_day?] et [`future?`][DateAndTime::Calculations#future?], tous relatifs à `Time.current`.

Lorsque vous effectuez des comparaisons de temps en utilisant des méthodes qui respectent le fuseau horaire de l'utilisateur, assurez-vous d'utiliser `Time.current` au lieu de `Time.now`. Il existe des cas où le fuseau horaire de l'utilisateur peut être dans le futur par rapport au fuseau horaire du système, que `Time.now` utilise par défaut. Cela signifie que `Time.now.to_date` peut être égal à `Date.yesterday`.

NOTE : Défini dans `active_support/core_ext/time/calculations.rb`.


#### `all_day`, `all_week`, `all_month`, `all_quarter` et `all_year`

La méthode [`all_day`][DateAndTime::Calculations#all_day] renvoie une plage représentant toute la journée du moment actuel.

```ruby
now = Time.current
# => Mon, 09 Aug 2010 23:20:05 UTC +00:00
now.all_day
# => Mon, 09 Aug 2010 00:00:00 UTC +00:00..Mon, 09 Aug 2010 23:59:59 UTC +00:00
```

De manière analogue, [`all_week`][DateAndTime::Calculations#all_week], [`all_month`][DateAndTime::Calculations#all_month], [`all_quarter`][DateAndTime::Calculations#all_quarter] et [`all_year`][DateAndTime::Calculations#all_year] servent tous à générer des plages de temps.

```ruby
now = Time.current
# => Mon, 09 Aug 2010 23:20:05 UTC +00:00
now.all_week
# => Mon, 09 Aug 2010 00:00:00 UTC +00:00..Sun, 15 Aug 2010 23:59:59 UTC +00:00
now.all_week(:sunday)
# => Sun, 16 Sep 2012 00:00:00 UTC +00:00..Sat, 22 Sep 2012 23:59:59 UTC +00:00
now.all_month
# => Sat, 01 Aug 2010 00:00:00 UTC +00:00..Tue, 31 Aug 2010 23:59:59 UTC +00:00
now.all_quarter
# => Thu, 01 Jul 2010 00:00:00 UTC +00:00..Thu, 30 Sep 2010 23:59:59 UTC +00:00
now.all_year
# => Fri, 01 Jan 2010 00:00:00 UTC +00:00..Fri, 31 Dec 2010 23:59:59 UTC +00:00
```

NOTE : Défini dans `active_support/core_ext/date_and_time/calculations.rb`.


#### `prev_day`, `next_day`

[`prev_day`][Time#prev_day] et [`next_day`][Time#next_day] renvoient le moment dans le jour précédent ou suivant :

```ruby
t = Time.new(2010, 5, 8) # => 2010-05-08 00:00:00 +0900
t.prev_day               # => 2010-05-07 00:00:00 +0900
t.next_day               # => 2010-05-09 00:00:00 +0900
```

NOTE : Défini dans `active_support/core_ext/time/calculations.rb`.


#### `prev_month`, `next_month`

[`prev_month`][Time#prev_month] et [`next_month`][Time#next_month] renvoient le moment avec le même jour dans le mois précédent ou suivant :

```ruby
t = Time.new(2010, 5, 8) # => 2010-05-08 00:00:00 +0900
t.prev_month             # => 2010-04-08 00:00:00 +0900
t.next_month             # => 2010-06-08 00:00:00 +0900
```

Si un tel jour n'existe pas, le dernier jour du mois correspondant est renvoyé :

```ruby
Time.new(2000, 5, 31).prev_month # => 2000-04-30 00:00:00 +0900
Time.new(2000, 3, 31).prev_month # => 2000-02-29 00:00:00 +0900
Time.new(2000, 5, 31).next_month # => 2000-06-30 00:00:00 +0900
Time.new(2000, 1, 31).next_month # => 2000-02-29 00:00:00 +0900
```

NOTE : Défini dans `active_support/core_ext/time/calculations.rb`.


#### `prev_year`, `next_year`

[`prev_year`][Time#prev_year] et [`next_year`][Time#next_year] renvoient un moment avec le même jour/mois dans l'année précédente ou suivante :

```ruby
t = Time.new(2010, 5, 8) # => 2010-05-08 00:00:00 +0900
t.prev_year              # => 2009-05-08 00:00:00 +0900
t.next_year              # => 2011-05-08 00:00:00 +0900
```

Si la date est le 29 février d'une année bissextile, vous obtenez le 28 :

```ruby
t = Time.new(2000, 2, 29) # => 2000-02-29 00:00:00 +0900
t.prev_year               # => 1999-02-28 00:00:00 +0900
t.next_year               # => 2001-02-28 00:00:00 +0900
```

NOTE : Défini dans `active_support/core_ext/time/calculations.rb`.


#### `prev_quarter`, `next_quarter`

[`prev_quarter`][DateAndTime::Calculations#prev_quarter] et [`next_quarter`][DateAndTime::Calculations#next_quarter] renvoient la date avec le même jour dans le trimestre précédent ou suivant :

```ruby
t = Time.local(2010, 5, 8) # => 2010-05-08 00:00:00 +0300
t.prev_quarter             # => 2010
`prev_quarter` est aliasé à [`last_quarter`][DateAndTime::Calculations#last_quarter].

NOTE : Défini dans `active_support/core_ext/date_and_time/calculations.rb`.


### Constructeurs de temps

Active Support définit [`Time.current`][Time.current] comme étant `Time.zone.now` s'il existe un fuseau horaire utilisateur défini, avec une fallback sur `Time.now` :

```ruby
Time.zone_default
# => #<ActiveSupport::TimeZone:0x7f73654d4f38 @utc_offset=nil, @name="Madrid", ...>
Time.current
# => Fri, 06 Aug 2010 17:11:58 CEST +02:00
```

De manière analogue à `DateTime`, les prédicats [`past?`][DateAndTime::Calculations#past?] et [`future?`][DateAndTime::Calculations#future?] sont relatifs à `Time.current`.

Si le temps à construire se situe en dehors de la plage supportée par `Time` dans la plateforme d'exécution, les microsecondes sont ignorées et un objet `DateTime` est renvoyé à la place.

#### Durées

Les objets [`Duration`][ActiveSupport::Duration] peuvent être ajoutés ou soustraits à des objets de temps :

```ruby
now = Time.current
# => Mon, 09 Aug 2010 23:20:05 UTC +00:00
now + 1.year
# => Tue, 09 Aug 2011 23:21:11 UTC +00:00
now - 1.week
# => Mon, 02 Aug 2010 23:21:11 UTC +00:00
```

Ils se traduisent par des appels à `since` ou `advance`. Par exemple, ici nous obtenons le bon saut dans la réforme du calendrier :

```ruby
Time.utc(1582, 10, 3) + 5.days
# => Mon Oct 18 00:00:00 UTC 1582
```

Extensions à `File`
--------------------

### `atomic_write`

Avec la méthode de classe [`File.atomic_write`][File.atomic_write], vous pouvez écrire dans un fichier d'une manière qui empêchera tout lecteur de voir un contenu partiellement écrit.

Le nom du fichier est passé en argument, et la méthode renvoie une poignée de fichier ouverte en écriture. Une fois que le bloc est terminé, `atomic_write` ferme la poignée de fichier et termine son travail.

Par exemple, Action Pack utilise cette méthode pour écrire des fichiers de cache d'actifs comme `all.css` :

```ruby
File.atomic_write(joined_asset_path) do |cache|
  cache.write(join_asset_file_contents(asset_paths))
end
```

Pour cela, `atomic_write` crée un fichier temporaire. C'est le fichier sur lequel le code du bloc écrit réellement. À la fin, le fichier temporaire est renommé, ce qui est une opération atomique sur les systèmes POSIX. Si le fichier cible existe, `atomic_write` le remplace et conserve les propriétaires et les permissions. Cependant, il existe quelques cas où `atomic_write` ne peut pas modifier la propriété ou les permissions du fichier, cette erreur est capturée et ignorée en faisant confiance à l'utilisateur/système de fichiers pour s'assurer que le fichier est accessible aux processus qui en ont besoin.

NOTE. En raison de l'opération chmod que `atomic_write` effectue, si le fichier cible a un ACL défini, cet ACL sera recalculé/modifié.

AVERTISSEMENT. Notez que vous ne pouvez pas ajouter avec `atomic_write`.

Le fichier auxiliaire est écrit dans un répertoire standard pour les fichiers temporaires, mais vous pouvez passer un répertoire de votre choix en tant que deuxième argument.

NOTE : Défini dans `active_support/core_ext/file/atomic.rb`.


Extensions à `NameError`
-------------------------

Active Support ajoute [`missing_name?`][NameError#missing_name?] à `NameError`, qui teste si l'exception a été levée en raison du nom passé en argument.

Le nom peut être donné sous forme de symbole ou de chaîne de caractères. Un symbole est testé par rapport au nom de constante nu, une chaîne de caractères par rapport au nom de constante entièrement qualifié.

CONSEIL : Un symbole peut représenter un nom de constante entièrement qualifié comme dans `:"ActiveRecord::Base"`, donc le comportement pour les symboles est défini pour des raisons de commodité, et non parce que cela doit être techniquement ainsi.

Par exemple, lorsque l'action d'un `ArticlesController` est appelée, Rails essaie de manière optimiste d'utiliser `ArticlesHelper`. Il est normal que le module d'aide n'existe pas, donc si une exception pour ce nom de constante est levée, elle doit être ignorée. Mais il se peut que `articles_helper.rb` lève une `NameError` en raison d'une constante inconnue réelle. Cela doit être relancé. La méthode `missing_name?` fournit un moyen de distinguer les deux cas :

```ruby
def default_helper_module!
  module_name = name.delete_suffix("Controller")
  module_path = module_name.underscore
  helper module_path
rescue LoadError => e
  raise e unless e.is_missing? "helpers/#{module_path}_helper"
rescue NameError => e
  raise e unless e.missing_name? "#{module_name}Helper"
end
```

NOTE : Défini dans `active_support/core_ext/name_error.rb`.


Extensions à `LoadError`
-------------------------

Active Support ajoute [`is_missing?`][LoadError#is_missing?] à `LoadError`.

Étant donné un nom de chemin, `is_missing?` teste si l'exception a été levée en raison de ce fichier particulier (sauf peut-être pour l'extension ".rb").

Par exemple, lorsque l'action d'un `ArticlesController` est appelée, Rails essaie de charger `articles_helper.rb`, mais ce fichier peut ne pas exister. C'est normal, le module d'aide n'est pas obligatoire, donc Rails ignore une erreur de chargement. Mais il se peut que le module d'aide existe et nécessite à son tour une autre bibliothèque qui est manquante. Dans ce cas, Rails doit relancer l'exception. La méthode `is_missing?` fournit un moyen de distinguer les deux cas :

```ruby
def default_helper_module!
  module_name = name.delete_suffix("Controller")
  module_path = module_name.underscore
  helper module_path
rescue LoadError => e
  raise e unless e.is_missing? "helpers/#{module_path}_helper"
rescue NameError => e
  raise e unless e.missing_name? "#{module_name}Helper"
end
```
NOTE : Défini dans `active_support/core_ext/load_error.rb`.


Extensions de Pathname
-------------------------

### `existence`

La méthode [`existence`][Pathname#existence] renvoie le récepteur si le fichier nommé existe, sinon elle renvoie `nil`. Elle est utile pour des idiomes comme celui-ci :

```ruby
content = Pathname.new("file").existence&.read
```

NOTE : Défini dans `active_support/core_ext/pathname/existence.rb`.
[`config.active_support.bare`]: configuring.html#config-active-support-bare
[Object#blank?]: https://api.rubyonrails.org/classes/Object.html#method-i-blank-3F
[Object#present?]: https://api.rubyonrails.org/classes/Object.html#method-i-present-3F
[Object#presence]: https://api.rubyonrails.org/classes/Object.html#method-i-presence
[Object#duplicable?]: https://api.rubyonrails.org/classes/Object.html#method-i-duplicable-3F
[Object#deep_dup]: https://api.rubyonrails.org/classes/Object.html#method-i-deep_dup
[Object#try]: https://api.rubyonrails.org/classes/Object.html#method-i-try
[Object#try!]: https://api.rubyonrails.org/classes/Object.html#method-i-try-21
[Kernel#class_eval]: https://api.rubyonrails.org/classes/Kernel.html#method-i-class_eval
[Object#acts_like?]: https://api.rubyonrails.org/classes/Object.html#method-i-acts_like-3F
[Array#to_param]: https://api.rubyonrails.org/classes/Array.html#method-i-to_param
[Object#to_param]: https://api.rubyonrails.org/classes/Object.html#method-i-to_param
[Hash#to_query]: https://api.rubyonrails.org/classes/Hash.html#method-i-to_query
[Object#to_query]: https://api.rubyonrails.org/classes/Object.html#method-i-to_query
[Object#with_options]: https://api.rubyonrails.org/classes/Object.html#method-i-with_options
[Object#instance_values]: https://api.rubyonrails.org/classes/Object.html#method-i-instance_values
[Object#instance_variable_names]: https://api.rubyonrails.org/classes/Object.html#method-i-instance_variable_names
[Kernel#enable_warnings]: https://api.rubyonrails.org/classes/Kernel.html#method-i-enable_warnings
[Kernel#silence_warnings]: https://api.rubyonrails.org/classes/Kernel.html#method-i-silence_warnings
[Kernel#suppress]: https://api.rubyonrails.org/classes/Kernel.html#method-i-suppress
[Object#in?]: https://api.rubyonrails.org/classes/Object.html#method-i-in-3F
[Module#alias_attribute]: https://api.rubyonrails.org/classes/Module.html#method-i-alias_attribute
[Module#attr_internal]: https://api.rubyonrails.org/classes/Module.html#method-i-attr_internal
[Module#attr_internal_accessor]: https://api.rubyonrails.org/classes/Module.html#method-i-attr_internal_accessor
[Module#attr_internal_reader]: https://api.rubyonrails.org/classes/Module.html#method-i-attr_internal_reader
[Module#attr_internal_writer]: https://api.rubyonrails.org/classes/Module.html#method-i-attr_internal_writer
[Module#mattr_accessor]: https://api.rubyonrails.org/classes/Module.html#method-i-mattr_accessor
[Module#mattr_reader]: https://api.rubyonrails.org/classes/Module.html#method-i-mattr_reader
[Module#mattr_writer]: https://api.rubyonrails.org/classes/Module.html#method-i-mattr_writer
[Module#module_parent]: https://api.rubyonrails.org/classes/Module.html#method-i-module_parent
[Module#module_parent_name]: https://api.rubyonrails.org/classes/Module.html#method-i-module_parent_name
[Module#module_parents]: https://api.rubyonrails.org/classes/Module.html#method-i-module_parents
[Module#anonymous?]: https://api.rubyonrails.org/classes/Module.html#method-i-anonymous-3F
[Module#delegate]: https://api.rubyonrails.org/classes/Module.html#method-i-delegate
[Module#delegate_missing_to]: https://api.rubyonrails.org/classes/Module.html#method-i-delegate_missing_to
[Module#redefine_method]: https://api.rubyonrails.org/classes/Module.html#method-i-redefine_method
[Module#silence_redefinition_of_method]: https://api.rubyonrails.org/classes/Module.html#method-i-silence_redefinition_of_method
[Class#class_attribute]: https://api.rubyonrails.org/classes/Class.html#method-i-class_attribute
[Module#cattr_accessor]: https://api.rubyonrails.org/classes/Module.html#method-i-cattr_accessor
[Module#cattr_reader]: https://api.rubyonrails.org/classes/Module.html#method-i-cattr_reader
[Module#cattr_writer]: https://api.rubyonrails.org/classes/Module.html#method-i-cattr_writer
[Class#subclasses]: https://api.rubyonrails.org/classes/Class.html#method-i-subclasses
[Class#descendants]: https://api.rubyonrails.org/classes/Class.html#method-i-descendants
[`raw`]: https://api.rubyonrails.org/classes/ActionView/Helpers/OutputSafetyHelper.html#method-i-raw
[String#html_safe]: https://api.rubyonrails.org/classes/String.html#method-i-html_safe
[String#remove]: https://api.rubyonrails.org/classes/String.html#method-i-remove
[String#squish]: https://api.rubyonrails.org/classes/String.html#method-i-squish
[String#truncate]: https://api.rubyonrails.org/classes/String.html#method-i-truncate
[String#truncate_bytes]: https://api.rubyonrails.org/classes/String.html#method-i-truncate_bytes
[String#truncate_words]: https://api.rubyonrails.org/classes/String.html#method-i-truncate_words
[String#inquiry]: https://api.rubyonrails.org/classes/String.html#method-i-inquiry
[String#strip_heredoc]: https://api.rubyonrails.org/classes/String.html#method-i-strip_heredoc
[String#indent!]: https://api.rubyonrails.org/classes/String.html#method-i-indent-21
[String#indent]: https://api.rubyonrails.org/classes/String.html#method-i-indent
[String#at]: https://api.rubyonrails.org/classes/String.html#method-i-at
[String#from]: https://api.rubyonrails.org/classes/String.html#method-i-from
[String#to]: https://api.rubyonrails.org/classes/String.html#method-i-to
[String#first]: https://api.rubyonrails.org/classes/String.html#method-i-first
[String#last]: https://api.rubyonrails.org/classes/String.html#method-i-last
[String#pluralize]: https://api.rubyonrails.org/classes/String.html#method-i-pluralize
[String#singularize]: https://api.rubyonrails.org/classes/String.html#method-i-singularize
[String#camelcase]: https://api.rubyonrails.org/classes/String.html#method-i-camelcase
[String#camelize]: https://api.rubyonrails.org/classes/String.html#method-i-camelize
[String#underscore]: https://api.rubyonrails.org/classes/String.html#method-i-underscore
[String#titlecase]: https://api.rubyonrails.org/classes/String.html#method-i-titlecase
[String#titleize]: https://api.rubyonrails.org/classes/String.html#method-i-titleize
[String#dasherize]: https://api.rubyonrails.org/classes/String.html#method-i-dasherize
[String#demodulize]: https://api.rubyonrails.org/classes/String.html#method-i-demodulize
[String#deconstantize]: https://api.rubyonrails.org/classes/String.html#method-i-deconstantize
[String#parameterize]: https://api.rubyonrails.org/classes/String.html#method-i-parameterize
[String#tableize]: https://api.rubyonrails.org/classes/String.html#method-i-tableize
[String#classify]: https://api.rubyonrails.org/classes/String.html#method-i-classify
[String#constantize]: https://api.rubyonrails.org/classes/String.html#method-i-constantize
[String#humanize]: https://api.rubyonrails.org/classes/String.html#method-i-humanize
[String#foreign_key]: https://api.rubyonrails.org/classes/String.html#method-i-foreign_key
[String#upcase_first]: https://api.rubyonrails.org/classes/String.html#method-i-upcase_first
[String#downcase_first]: https://api.rubyonrails.org/classes/String.html#method-i-downcase_first
[String#to_date]: https://api.rubyonrails.org/classes/String.html#method-i-to_date
[String#to_datetime]: https://api.rubyonrails.org/classes/String.html#method-i-to_datetime
[String#to_time]: https://api.rubyonrails.org/classes/String.html#method-i-to_time
[Numeric#bytes]: https://api.rubyonrails.org/classes/Numeric.html#method-i-bytes
[Numeric#exabytes]: https://api.rubyonrails.org/classes/Numeric.html#method-i-exabytes
[Numeric#gigabytes]: https://api.rubyonrails.org/classes/Numeric.html#method-i-gigabytes
[Numeric#kilobytes]: https://api.rubyonrails.org/classes/Numeric.html#method-i-kilobytes
[Numeric#megabytes]: https://api.rubyonrails.org/classes/Numeric.html#method-i-megabytes
[Numeric#petabytes]: https://api.rubyonrails.org/classes/Numeric.html#method-i-petabytes
[Numeric#terabytes]: https://api.rubyonrails.org/classes/Numeric.html#method-i-terabytes
[Duration#ago]: https://api.rubyonrails.org/classes/ActiveSupport/Duration.html#method-i-ago
[Duration#from_now]: https://api.rubyonrails.org/classes/ActiveSupport/Duration.html#method-i-from_now
[Numeric#days]: https://api.rubyonrails.org/classes/Numeric.html#method-i-days
[Numeric#fortnights]: https://api.rubyonrails.org/classes/Numeric.html#method-i-fortnights
[Numeric#hours]: https://api.rubyonrails.org/classes/Numeric.html#method-i-hours
[Numeric#minutes]: https://api.rubyonrails.org/classes/Numeric.html#method-i-minutes
[Numeric#seconds]: https://api.rubyonrails.org/classes/Numeric.html#method-i-seconds
[Numeric#weeks]: https://api.rubyonrails.org/classes/Numeric.html#method-i-weeks
[Integer#multiple_of?]: https://api.rubyonrails.org/classes/Integer.html#method-i-multiple_of-3F
[Integer#ordinal]: https://api.rubyonrails.org/classes/Integer.html#method-i-ordinal
[Integer#ordinalize]: https://api.rubyonrails.org/classes/Integer.html#method-i-ordinalize
[Integer#months]: https://api.rubyonrails.org/classes/Integer.html#method-i-months
[Integer#years]: https://api.rubyonrails.org/classes/Integer.html#method-i-years
[Enumerable#sum]: https://api.rubyonrails.org/classes/Enumerable.html#method-i-sum
[Enumerable#index_by]: https://api.rubyonrails.org/classes/Enumerable.html#method-i-index_by
[Enumerable#index_with]: https://api.rubyonrails.org/classes/Enumerable.html#method-i-index_with
[Enumerable#many?]: https://api.rubyonrails.org/classes/Enumerable.html#method-i-many-3F
[Enumerable#exclude?]: https://api.rubyonrails.org/classes/Enumerable.html#method-i-exclude-3F
[Enumerable#including]: https://api.rubyonrails.org/classes/Enumerable.html#method-i-including
[Enumerable#excluding]: https://api.rubyonrails.org/classes/Enumerable.html#method-i-excluding
[Enumerable#without]: https://api.rubyonrails.org/classes/Enumerable.html#method-i-without
[Enumerable#pluck]: https://api.rubyonrails.org/classes/Enumerable.html#method-i-pluck
[Enumerable#pick]: https://api.rubyonrails.org/classes/Enumerable.html#method-i-pick
[Array#excluding]: https://api.rubyonrails.org/classes/Array.html#method-i-excluding
[Array#fifth]: https://api.rubyonrails.org/classes/Array.html#method-i-fifth
[Array#forty_two]: https://api.rubyonrails.org/classes/Array.html#method-i-forty_two
[Array#fourth]: https://api.rubyonrails.org/classes/Array.html#method-i-fourth
[Array#from]: https://api.rubyonrails.org/classes/Array.html#method-i-from
[Array#including]: https://api.rubyonrails.org/classes/Array.html#method-i-including
[Array#second]: https://api.rubyonrails.org/classes/Array.html#method-i-second
[Array#second_to_last]: https://api.rubyonrails.org/classes/Array.html#method-i-second_to_last
[Array#third]: https://api.rubyonrails.org/classes/Array.html#method-i-third
[Array#third_to_last]: https://api.rubyonrails.org/classes/Array.html#method-i-third_to_last
[Array#to]: https://api.rubyonrails.org/classes/Array.html#method-i-to
[Array#extract!]: https://api.rubyonrails.org/classes/Array.html#method-i-extract-21
[Array#extract_options!]: https://api.rubyonrails.org/classes/Array.html#method-i-extract_options-21
[Array#to_sentence]: https://api.rubyonrails.org/classes/Array.html#method-i-to_sentence
[Array#to_fs]: https://api.rubyonrails.org/classes/Array.html#method-i-to_fs
[Array#to_xml]: https://api.rubyonrails.org/classes/Array.html#method-i-to_xml
[Array.wrap]: https://api.rubyonrails.org/classes/Array.html#method-c-wrap
[Array#deep_dup]: https://api.rubyonrails.org/classes/Array.html#method-i-deep_dup
[Array#in_groups_of]: https://api.rubyonrails.org/classes/Array.html#method-i-in_groups_of
[Array#in_groups]: https://api.rubyonrails.org/classes/Array.html#method-i-in_groups
[Array#split]: https://api.rubyonrails.org/classes/Array.html#method-i-split
[Hash#to_xml]: https://api.rubyonrails.org/classes/Hash.html#method-i-to_xml
[Hash#reverse_merge!]: https://api.rubyonrails.org/classes/Hash.html#method-i-reverse_merge-21
[Hash#reverse_merge]: https://api.rubyonrails.org/classes/Hash.html#method-i-reverse_merge
[Hash#reverse_update]: https://api.rubyonrails.org/classes/Hash.html#method-i-reverse_update
[Hash#deep_merge!]: https://api.rubyonrails.org/classes/Hash.html#method-i-deep_merge-21
[Hash#deep_merge]: https://api.rubyonrails.org/classes/Hash.html#method-i-deep_merge
[Hash#deep_dup]: https://api.rubyonrails.org/classes/Hash.html#method-i-deep_dup
[Hash#except!]: https://api.rubyonrails.org/classes/Hash.html#method-i-except-21
[Hash#except]: https://api.rubyonrails.org/classes/Hash.html#method-i-except
[Hash#deep_stringify_keys!]: https://api.rubyonrails.org/classes/Hash.html#method-i-deep_stringify_keys-21
[Hash#deep_stringify_keys]: https://api.rubyonrails.org/classes/Hash.html#method-i-deep_stringify_keys
[Hash#stringify_keys!]: https://api.rubyonrails.org/classes/Hash.html#method-i-stringify_keys-21
[Hash#stringify_keys]: https://api.rubyonrails.org/classes/Hash.html#method-i-stringify_keys
[Hash#deep_symbolize_keys!]: https://api.rubyonrails.org/classes/Hash.html#method-i-deep_symbolize_keys-21
[Hash#deep_symbolize_keys]: https://api.rubyonrails.org/classes/Hash.html#method-i-deep_symbolize_keys
[Hash#symbolize_keys!]: https://api.rubyonrails.org/classes/Hash.html#method-i-symbolize_keys-21
[Hash#symbolize_keys]: https://api.rubyonrails.org/classes/Hash.html#method-i-symbolize_keys
[Hash#to_options!]: https://api.rubyonrails.org/classes/Hash.html#method-i-to_options-21
[Hash#to_options]: https://api.rubyonrails.org/classes/Hash.html#method-i-to_options
[Hash#assert_valid_keys]: https://api.rubyonrails.org/classes/Hash.html#method-i-assert_valid_keys
[Hash#deep_transform_values!]: https://api.rubyonrails.org/classes/Hash.html#method-i-deep_transform_values-21
[Hash#deep_transform_values]: https://api.rubyonrails.org/classes/Hash.html#method-i-deep_transform_values
[Hash#slice!]: https://api.rubyonrails.org/classes/Hash.html#method-i-slice-21
[Hash#extract!]: https://api.rubyonrails.org/classes/Hash.html#method-i-extract-21
[ActiveSupport::HashWithIndifferentAccess]: https://api.rubyonrails.org/classes/ActiveSupport/HashWithIndifferentAccess.html
[Hash#with_indifferent_access]: https://api.rubyonrails.org/classes/Hash.html#method-i-with_indifferent_access
[Regexp#multiline?]: https://api.rubyonrails.org/classes/Regexp.html#method-i-multiline-3F
[Range#overlap?]: https://api.rubyonrails.org/classes/Range.html#method-i-overlaps-3F
[Date.current]: https://api.rubyonrails.org/classes/Date.html#method-c-current
[Date.tomorrow]: https://api.rubyonrails.org/classes/Date.html#method-c-tomorrow
[Date.yesterday]: https://api.rubyonrails.org/classes/Date.html#method-c-yesterday
[DateAndTime::Calculations#future?]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-future-3F
[DateAndTime::Calculations#on_weekday?]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-on_weekday-3F
[DateAndTime::Calculations#on_weekend?]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-on_weekend-3F
[DateAndTime::Calculations#past?]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-past-3F
[`config.beginning_of_week`]: configuring.html#config-beginning-of-week
[DateAndTime::Calculations#at_beginning_of_week]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-at_beginning_of_week
[DateAndTime::Calculations#at_end_of_week]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-at_end_of_week
[DateAndTime::Calculations#beginning_of_week]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-beginning_of_week
[DateAndTime::Calculations#end_of_week]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-end_of_week
[DateAndTime::Calculations#monday]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-monday
[DateAndTime::Calculations#sunday]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-sunday
[Date.beginning_of_week]: https://api.rubyonrails.org/classes/Date.html#method-c-beginning_of_week
[DateAndTime::Calculations#last_week]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-last_week
[DateAndTime::Calculations#next_week]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-next_week
[DateAndTime::Calculations#prev_week]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-prev_week
[DateAndTime::Calculations#at_beginning_of_month]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-at_beginning_of_month
[DateAndTime::Calculations#at_end_of_month]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-at_end_of_month
[DateAndTime::Calculations#beginning_of_month]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-beginning_of_month
[DateAndTime::Calculations#end_of_month]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-end_of_month
[DateAndTime::Calculations#quarter]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-quarter
[DateAndTime::Calculations#at_beginning_of_quarter]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-at_beginning_of_quarter
[DateAndTime::Calculations#at_end_of_quarter]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-at_end_of_quarter
[DateAndTime::Calculations#beginning_of_quarter]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-beginning_of_quarter
[DateAndTime::Calculations#end_of_quarter]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-end_of_quarter
[DateAndTime::Calculations#at_beginning_of_year]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-at_beginning_of_year
[DateAndTime::Calculations#at_end_of_year]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-at_end_of_year
[DateAndTime::Calculations#beginning_of_year]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-beginning_of_year
[DateAndTime::Calculations#end_of_year]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-end_of_year
[DateAndTime::Calculations#last_year]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-last_year
[DateAndTime::Calculations#years_ago]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-years_ago
[DateAndTime::Calculations#years_since]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-years_since
[DateAndTime::Calculations#last_month]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-last_month
[DateAndTime::Calculations#months_ago]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-months_ago
[DateAndTime::Calculations#months_since]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-months_since
[DateAndTime::Calculations#weeks_ago]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-weeks_ago
[Date#advance]: https://api.rubyonrails.org/classes/Date.html#method-i-advance
[Date#change]: https://api.rubyonrails.org/classes/Date.html#method-i-change
[ActiveSupport::Duration]: https://api.rubyonrails.org/classes/ActiveSupport/Duration.html
[Date#at_beginning_of_day]: https://api.rubyonrails.org/classes/Date.html#method-i-at_beginning_of_day
[Date#at_midnight]: https://api.rubyonrails.org/classes/Date.html#method-i-at_midnight
[Date#beginning_of_day]: https://api.rubyonrails.org/classes/Date.html#method-i-beginning_of_day
[Date#end_of_day]: https://api.rubyonrails.org/classes/Date.html#method-i-end_of_day
[Date#midnight]: https://api.rubyonrails.org/classes/Date.html#method-i-midnight
[DateTime#at_beginning_of_minute]: https://api.rubyonrails.org/classes/DateTime.html#method-i-at_beginning_of_minute
[DateTime#beginning_of_minute]: https://api.rubyonrails.org/classes/DateTime.html#method-i-beginning_of_minute
[DateTime#end_of_minute]: https://api.rubyonrails.org/classes/DateTime.html#method-i-end_of_minute
[Date#ago]: https://api.rubyonrails.org/classes/Date.html#method-i-ago
[Date#since]: https://api.rubyonrails.org/classes/Date.html#method-i-since
[DateTime#ago]: https://api.rubyonrails.org/classes/DateTime.html#method-i-ago
[DateTime#at_beginning_of_day]: https://api.rubyonrails.org/classes/DateTime.html#method-i-at_beginning_of_day
[DateTime#at_beginning_of_hour]: https://api.rubyonrails.org/classes/DateTime.html#method-i-at_beginning_of_hour
[DateTime#at_midnight]: https://api.rubyonrails.org/classes/DateTime.html#method-i-at_midnight
[DateTime#beginning_of_day]: https://api.rubyonrails.org/classes/DateTime.html#method-i-beginning_of_day
[DateTime#beginning_of_hour]: https://api.rubyonrails.org/classes/DateTime.html#method-i-beginning_of_hour
[DateTime#end_of_day]: https://api.rubyonrails.org/classes/DateTime.html#method-i-end_of_day
[DateTime#end_of_hour]: https://api.rubyonrails.org/classes/DateTime.html#method-i-end_of_hour
[DateTime#in]: https://api.rubyonrails.org/classes/DateTime.html#method-i-in
[DateTime#midnight]: https://api.rubyonrails.org/classes/DateTime.html#method-i-midnight
[DateTime.current]: https://api.rubyonrails.org/classes/DateTime.html#method-c-current
[DateTime#seconds_since_midnight]: https://api.rubyonrails.org/classes/DateTime.html#method-i-seconds_since_midnight
[DateTime#getutc]: https://api.rubyonrails.org/classes/DateTime.html#method-i-getutc
[DateTime#utc]: https://api.rubyonrails.org/classes/DateTime.html#method-i-utc
[DateTime#utc?]: https://api.rubyonrails.org/classes/DateTime.html#method-i-utc-3F
[DateTime#advance]: https://api.rubyonrails.org/classes/DateTime.html#method-i-advance
[DateTime#since]: https://api.rubyonrails.org/classes/DateTime.html#method-i-since
[DateTime#change]: https://api.rubyonrails.org/classes/DateTime.html#method-i-change
[Time#ago]: https://api.rubyonrails.org/classes/Time.html#method-i-ago
[Time#change]: https://api.rubyonrails.org/classes/Time.html#method-i-change
[Time#since]: https://api.rubyonrails.org/classes/Time.html#method-i-since
[DateAndTime::Calculations#next_day?]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-next_day-3F
[DateAndTime::Calculations#prev_day?]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-prev_day-3F
[DateAndTime::Calculations#today?]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-today-3F
[DateAndTime::Calculations#tomorrow?]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-tomorrow-3F
[DateAndTime::Calculations#yesterday?]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-yesterday-3F
[DateAndTime::Calculations#all_day]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-all_day
[DateAndTime::Calculations#all_month]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-all_month
[DateAndTime::Calculations#all_quarter]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-all_quarter
[DateAndTime::Calculations#all_week]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-all_week
[DateAndTime::Calculations#all_year]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-all_year
[Time.current]: https://api.rubyonrails.org/classes/Time.html#method-c-current
[Time#next_day]: https://api.rubyonrails.org/classes/Time.html#method-i-next_day
[Time#prev_day]: https://api.rubyonrails.org/classes/Time.html#method-i-prev_day
[Time#next_month]: https://api.rubyonrails.org/classes/Time.html#method-i-next_month
[Time#prev_month]: https://api.rubyonrails.org/classes/Time.html#method-i-prev_month
[Time#next_year]: https://api.rubyonrails.org/classes/Time.html#method-i-next_year
[Time#prev_year]: https://api.rubyonrails.org/classes/Time.html#method-i-prev_year
[DateAndTime::Calculations#last_quarter]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-last_quarter
[DateAndTime::Calculations#next_quarter]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-next_quarter
[DateAndTime::Calculations#prev_quarter]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-prev_quarter
[File.atomic_write]: https://api.rubyonrails.org/classes/File.html#method-c-atomic_write
[NameError#missing_name?]: https://api.rubyonrails.org/classes/NameError.html#method-i-missing_name-3F
[LoadError#is_missing?]: https://api.rubyonrails.org/classes/LoadError.html#method-i-is_missing-3F
[Pathname#existence]: https://api.rubyonrails.org/classes/Pathname.html#method-i-existence
