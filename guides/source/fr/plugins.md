**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: b550120024fb17dc176480922543264e
Les bases de la création de plugins Rails
===========================================

Un plugin Rails est soit une extension, soit une modification du framework principal. Les plugins offrent :

* Un moyen pour les développeurs de partager des idées de pointe sans nuire à la base de code stable.
* Une architecture segmentée permettant de corriger ou de mettre à jour des unités de code selon leur propre calendrier de publication.
* Une sortie pour les développeurs principaux afin qu'ils n'aient pas à inclure toutes les nouvelles fonctionnalités géniales sous le soleil.

Après avoir lu ce guide, vous saurez :

* Comment créer un plugin à partir de zéro.
* Comment écrire et exécuter des tests pour le plugin.

Ce guide décrit comment construire un plugin piloté par les tests qui permettra de :

* Étendre les classes Ruby de base comme Hash et String.
* Ajouter des méthodes à `ApplicationRecord` dans la tradition des plugins `acts_as`.
* Vous donner des informations sur l'emplacement des générateurs dans votre plugin.

Dans le but de ce guide, prétendez un instant que vous êtes un passionné d'observation des oiseaux.
Votre oiseau préféré est le Yaffle, et vous voulez créer un plugin qui permet aux autres développeurs de partager la merveille du Yaffle.

--------------------------------------------------------------------------------

Configuration
-------------

Actuellement, les plugins Rails sont construits sous forme de gems, des _plugins gemifiés_. Ils peuvent être partagés entre
différentes applications Rails en utilisant RubyGems et Bundler si nécessaire.

### Générer un plugin gemifié

Rails est livré avec une commande `rails plugin new` qui crée un
squelette pour développer n'importe quel type d'extension Rails avec la possibilité
d'exécuter des tests d'intégration en utilisant une application Rails fictive. Créez votre
plugin avec la commande :

```bash
$ rails plugin new yaffle
```

Voir l'utilisation et les options en demandant de l'aide :

```bash
$ rails plugin new --help
```

Tester votre nouveau plugin généré
----------------------------------

Accédez au répertoire qui contient le plugin, et modifiez `yaffle.gemspec` pour
remplacer toutes les lignes qui contiennent des valeurs `TODO` :

```ruby
spec.homepage    = "http://example.com"
spec.summary     = "Résumé de Yaffle."
spec.description = "Description de Yaffle."

...

spec.metadata["source_code_uri"] = "http://example.com"
spec.metadata["changelog_uri"] = "http://example.com"
```

Ensuite, exécutez la commande `bundle install`.

Maintenant, vous pouvez exécuter les tests en utilisant la commande `bin/test`, et vous devriez voir :

```bash
$ bin/test
...
1 runs, 1 assertions, 0 failures, 0 errors, 0 skips
```

Cela vous indiquera que tout a été généré correctement, et vous êtes prêt à commencer à ajouter des fonctionnalités.

Extension des classes de base
-----------------------------

Cette section expliquera comment ajouter une méthode à String qui sera disponible n'importe où dans votre application Rails.

Dans cet exemple, vous ajouterez une méthode à String appelée `to_squawk`. Pour commencer, créez un nouveau fichier de test avec quelques assertions :

```ruby
# yaffle/test/core_ext_test.rb

require "test_helper"

class CoreExtTest < ActiveSupport::TestCase
  def test_to_squawk_prepends_the_word_squawk
    assert_equal "squawk! Hello World", "Hello World".to_squawk
  end
end
```

Exécutez `bin/test` pour exécuter le test. Ce test devrait échouer car nous n'avons pas implémenté la méthode `to_squawk` :

```bash
$ bin/test
E

Error:
CoreExtTest#test_to_squawk_prepends_the_word_squawk:
NoMethodError: undefined method `to_squawk' for "Hello World":String


bin/test /path/to/yaffle/test/core_ext_test.rb:4

.

Finished in 0.003358s, 595.6483 runs/s, 297.8242 assertions/s.
2 runs, 1 assertions, 0 failures, 1 errors, 0 skips
```

Super - maintenant vous êtes prêt à commencer le développement.

Dans `lib/yaffle.rb`, ajoutez `require "yaffle/core_ext"` :

```ruby
# yaffle/lib/yaffle.rb

require "yaffle/version"
require "yaffle/railtie"
require "yaffle/core_ext"

module Yaffle
  # Your code goes here...
end
```

Enfin, créez le fichier `core_ext.rb` et ajoutez la méthode `to_squawk` :

```ruby
# yaffle/lib/yaffle/core_ext.rb

class String
  def to_squawk
    "squawk! #{self}".strip
  end
end
```

Pour tester que votre méthode fait ce qu'elle dit, exécutez les tests unitaires avec `bin/test` depuis le répertoire de votre plugin.

```
$ bin/test
...
2 runs, 2 assertions, 0 failures, 0 errors, 0 skips
```

Pour voir cela en action, changez vers le répertoire `test/dummy`, démarrez `bin/rails console`, et commencez à squawker :

```irb
irb> "Hello World".to_squawk
=> "squawk! Hello World"
```

Ajouter une méthode "acts_as" à Active Record
--------------------------------------------

Un modèle courant dans les plugins consiste à ajouter une méthode appelée `acts_as_quelquechose` aux modèles. Dans ce cas, vous
voulez écrire une méthode appelée `acts_as_yaffle` qui ajoute une méthode `squawk` à vos modèles Active Record.

Pour commencer, configurez vos fichiers de sorte que vous ayez :

```ruby
# yaffle/test/acts_as_yaffle_test.rb

require "test_helper"

class ActsAsYaffleTest < ActiveSupport::TestCase
end
```

```ruby
# yaffle/lib/yaffle.rb

require "yaffle/version"
require "yaffle/railtie"
require "yaffle/core_ext"
require "yaffle/acts_as_yaffle"

module Yaffle
  # Your code goes here...
end
```

```ruby
# yaffle/lib/yaffle/acts_as_yaffle.rb

module Yaffle
  module ActsAsYaffle
  end
end
```
### Ajouter une méthode de classe

Ce plugin s'attend à ce que vous ayez ajouté une méthode à votre modèle appelée `last_squawk`. Cependant, les utilisateurs du plugin peuvent déjà avoir défini une méthode sur leur modèle appelée `last_squawk` qu'ils utilisent pour autre chose. Ce plugin permettra de changer le nom en ajoutant une méthode de classe appelée `yaffle_text_field`.

Pour commencer, écrivez un test qui échoue et montre le comportement souhaité :

```ruby
# yaffle/test/acts_as_yaffle_test.rb

require "test_helper"

class ActsAsYaffleTest < ActiveSupport::TestCase
  def test_a_hickwalls_yaffle_text_field_should_be_last_squawk
    assert_equal "last_squawk", Hickwall.yaffle_text_field
  end

  def test_a_wickwalls_yaffle_text_field_should_be_last_tweet
    assert_equal "last_tweet", Wickwall.yaffle_text_field
  end
end
```

Lorsque vous exécutez `bin/test`, vous devriez voir le résultat suivant :

```bash
$ bin/test
# Running:

..E

Error:
ActsAsYaffleTest#test_a_wickwalls_yaffle_text_field_should_be_last_tweet:
NameError: uninitialized constant ActsAsYaffleTest::Wickwall


bin/test /path/to/yaffle/test/acts_as_yaffle_test.rb:8

E

Error:
ActsAsYaffleTest#test_a_hickwalls_yaffle_text_field_should_be_last_squawk:
NameError: uninitialized constant ActsAsYaffleTest::Hickwall


bin/test /path/to/yaffle/test/acts_as_yaffle_test.rb:4



Finished in 0.004812s, 831.2949 runs/s, 415.6475 assertions/s.
4 runs, 2 assertions, 0 failures, 2 errors, 0 skips
```

Cela nous indique que nous n'avons pas les modèles nécessaires (Hickwall et Wickwall) que nous essayons de tester. Nous pouvons facilement générer ces modèles dans notre application Rails "dummy" en exécutant les commandes suivantes depuis le répertoire `test/dummy` :

```bash
$ cd test/dummy
$ bin/rails generate model Hickwall last_squawk:string
$ bin/rails generate model Wickwall last_squawk:string last_tweet:string
```

Maintenant, vous pouvez créer les tables de base de données nécessaires dans votre base de données de test en accédant à votre application dummy et en migrant la base de données. Tout d'abord, exécutez :

```bash
$ cd test/dummy
$ bin/rails db:migrate
```

Pendant que vous y êtes, modifiez les modèles Hickwall et Wickwall pour qu'ils sachent qu'ils sont censés agir comme des yaffles.

```ruby
# test/dummy/app/models/hickwall.rb

class Hickwall < ApplicationRecord
  acts_as_yaffle
end
```

```ruby
# test/dummy/app/models/wickwall.rb

class Wickwall < ApplicationRecord
  acts_as_yaffle yaffle_text_field: :last_tweet
end
```

Nous ajouterons également du code pour définir la méthode `acts_as_yaffle`.

```ruby
# yaffle/lib/yaffle/acts_as_yaffle.rb

module Yaffle
  module ActsAsYaffle
    extend ActiveSupport::Concern

    class_methods do
      def acts_as_yaffle(options = {})
      end
    end
  end
end
```

```ruby
# test/dummy/app/models/application_record.rb

class ApplicationRecord < ActiveRecord::Base
  include Yaffle::ActsAsYaffle

  self.abstract_class = true
end
```

Vous pouvez ensuite retourner au répertoire racine (`cd ../..`) de votre plugin et relancer les tests en utilisant `bin/test`.

```bash
$ bin/test
# Running:

.E

Error:
ActsAsYaffleTest#test_a_hickwalls_yaffle_text_field_should_be_last_squawk:
NoMethodError: undefined method `yaffle_text_field' for #<Class:0x0055974ebbe9d8>


bin/test /path/to/yaffle/test/acts_as_yaffle_test.rb:4

E

Error:
ActsAsYaffleTest#test_a_wickwalls_yaffle_text_field_should_be_last_tweet:
NoMethodError: undefined method `yaffle_text_field' for #<Class:0x0055974eb8cfc8>


bin/test /path/to/yaffle/test/acts_as_yaffle_test.rb:8

.

Finished in 0.008263s, 484.0999 runs/s, 242.0500 assertions/s.
4 runs, 2 assertions, 0 failures, 2 errors, 0 skips
```

Nous nous rapprochons... Maintenant, nous allons implémenter le code de la méthode `acts_as_yaffle` pour que les tests réussissent.

```ruby
# yaffle/lib/yaffle/acts_as_yaffle.rb

module Yaffle
  module ActsAsYaffle
    extend ActiveSupport::Concern

    class_methods do
      def acts_as_yaffle(options = {})
        cattr_accessor :yaffle_text_field, default: (options[:yaffle_text_field] || :last_squawk).to_s
      end
    end
  end
end
```

```ruby
# test/dummy/app/models/application_record.rb

class ApplicationRecord < ActiveRecord::Base
  include Yaffle::ActsAsYaffle

  self.abstract_class = true
end
```

Lorsque vous exécutez `bin/test`, vous devriez voir que tous les tests réussissent :

```bash
$ bin/test
...
4 runs, 4 assertions, 0 failures, 0 errors, 0 skips
```

### Ajouter une méthode d'instance

Ce plugin ajoutera une méthode appelée 'squawk' à tout objet Active Record qui appelle `acts_as_yaffle`. La méthode 'squawk' se contentera de définir la valeur d'un des champs dans la base de données.

Pour commencer, écrivez un test qui échoue et montre le comportement souhaité :

```ruby
# yaffle/test/acts_as_yaffle_test.rb
require "test_helper"

class ActsAsYaffleTest < ActiveSupport::TestCase
  def test_a_hickwalls_yaffle_text_field_should_be_last_squawk
    assert_equal "last_squawk", Hickwall.yaffle_text_field
  end

  def test_a_wickwalls_yaffle_text_field_should_be_last_tweet
    assert_equal "last_tweet", Wickwall.yaffle_text_field
  end

  def test_hickwalls_squawk_should_populate_last_squawk
    hickwall = Hickwall.new
    hickwall.squawk("Hello World")
    assert_equal "squawk! Hello World", hickwall.last_squawk
  end

  def test_wickwalls_squawk_should_populate_last_tweet
    wickwall = Wickwall.new
    wickwall.squawk("Hello World")
    assert_equal "squawk! Hello World", wickwall.last_tweet
  end
end
```

Exécutez le test pour vous assurer que les deux derniers tests échouent avec une erreur contenant "NoMethodError: undefined method \`squawk'", puis mettez à jour `acts_as_yaffle.rb` pour ressembler à ceci :

```ruby
# yaffle/lib/yaffle/acts_as_yaffle.rb

module Yaffle
  module ActsAsYaffle
    extend ActiveSupport::Concern

    included do
      def squawk(string)
        write_attribute(self.class.yaffle_text_field, string.to_squawk)
      end
    end

    class_methods do
      def acts_as_yaffle(options = {})
        cattr_accessor :yaffle_text_field, default: (options[:yaffle_text_field] || :last_squawk).to_s
      end
    end
  end
end
```

```ruby
# test/dummy/app/models/application_record.rb

class ApplicationRecord < ActiveRecord::Base
  include Yaffle::ActsAsYaffle

  self.abstract_class = true
end
```

Exécutez `bin/test` une dernière fois, et vous devriez voir :

```bash
$ bin/test
...
6 runs, 6 assertions, 0 failures, 0 errors, 0 skips
```

REMARQUE : L'utilisation de `write_attribute` pour écrire dans le champ du modèle est juste un exemple de la façon dont un plugin peut interagir avec le modèle, et ne sera pas toujours la bonne méthode à utiliser. Par exemple, vous pourriez également utiliser :
```ruby
send("#{self.class.yaffle_text_field}=", string.to_squawk)
```

Générateurs
----------

Les générateurs peuvent être inclus dans votre gemme simplement en les créant dans un répertoire `lib/generators` de votre plugin. Plus d'informations sur la création de générateurs peuvent être trouvées dans le [Guide des générateurs](generators.html).

Publication de votre gemme
-------------------

Les plugins de gemmes actuellement en développement peuvent facilement être partagés à partir de n'importe quel dépôt Git. Pour partager la gemme Yaffle avec d'autres personnes, il suffit de commettre le code dans un dépôt Git (comme GitHub) et d'ajouter une ligne au `Gemfile` de l'application en question :

```ruby
gem "yaffle", git: "https://github.com/rails/yaffle.git"
```

Après avoir exécuté `bundle install`, la fonctionnalité de votre gemme sera disponible pour l'application.

Lorsque la gemme est prête à être partagée en tant que version officielle, elle peut être publiée sur [RubyGems](https://rubygems.org).

Alternativement, vous pouvez bénéficier des tâches Rake de Bundler. Vous pouvez voir une liste complète avec la commande suivante :

```bash
$ bundle exec rake -T

$ bundle exec rake build
# Construit yaffle-0.1.0.gem dans le répertoire pkg

$ bundle exec rake install
# Construit et installe yaffle-0.1.0.gem dans les gemmes système

$ bundle exec rake release
# Crée une balise v0.1.0 et construit et pousse yaffle-0.1.0.gem vers Rubygems
```

Pour plus d'informations sur la publication de gemmes sur RubyGems, voir : [Publication de votre gemme](https://guides.rubygems.org/publishing).

Documentation RDoc
------------------

Une fois que votre plugin est stable et que vous êtes prêt à le déployer, faites plaisir à tout le monde en le documentant ! Heureusement, écrire de la documentation pour votre plugin est facile.

La première étape consiste à mettre à jour le fichier README avec des informations détaillées sur l'utilisation de votre plugin. Quelques éléments clés à inclure sont :

* Votre nom
* Comment l'installer
* Comment ajouter la fonctionnalité à l'application (plusieurs exemples de cas d'utilisation courants)
* Avertissements, pièges ou astuces qui pourraient aider les utilisateurs et leur faire gagner du temps

Une fois que votre README est solide, passez en revue et ajoutez des commentaires RDoc à toutes les méthodes que les développeurs utiliseront. Il est également courant d'ajouter des commentaires `# :nodoc:` à ces parties du code qui ne font pas partie de l'API publique.

Une fois que vos commentaires sont prêts, accédez au répertoire de votre plugin et exécutez :

```bash
$ bundle exec rake rdoc
```

### Références

* [Développer une RubyGem en utilisant Bundler](https://github.com/radar/guides/blob/master/gem-development.md)
* [Utilisation des .gemspecs comme prévu](https://yehudakatz.com/2010/04/02/using-gemspecs-as-intended/)
* [Référence de gemspec](https://guides.rubygems.org/specification-reference/)
