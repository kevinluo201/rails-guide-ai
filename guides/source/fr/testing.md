**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 6da9945dc313b748574b8aca256f1435
Tester les applications Rails
==============================

Ce guide couvre les mécanismes intégrés dans Rails pour tester votre application.

Après avoir lu ce guide, vous saurez :

* La terminologie des tests Rails.
* Comment écrire des tests unitaires, fonctionnels, d'intégration et système pour votre application.
* D'autres approches de test populaires et plugins.

--------------------------------------------------------------------------------

Pourquoi écrire des tests pour vos applications Rails ?
------------------------------------------------------

Rails facilite grandement l'écriture de vos tests. Il commence par produire du code de test squelette pendant que vous créez vos modèles et contrôleurs.

En exécutant vos tests Rails, vous pouvez vous assurer que votre code respecte la fonctionnalité souhaitée même après une refonte majeure du code.

Les tests Rails peuvent également simuler des requêtes de navigateur et vous permettre de tester la réponse de votre application sans avoir à la tester via votre navigateur.

Introduction aux tests
----------------------

Le support des tests a été intégré dans la structure de Rails dès le début. Ce n'était pas une épiphanie du genre "oh ! ajoutons le support des tests car ils sont nouveaux et cool".

### Rails se prépare pour les tests dès le départ

Rails crée un répertoire `test` pour vous dès que vous créez un projet Rails en utilisant `rails new` _nom_de_l'application_. Si vous listez le contenu de ce répertoire, vous verrez :

```bash
$ ls -F test
application_system_test_case.rb  controllers/                     helpers/                         mailers/                         system/
channels/                        fixtures/                        integration/                     models/                          test_helper.rb
```

Les répertoires `helpers`, `mailers` et `models` sont destinés à contenir les tests pour les helpers de vue, les mailers et les modèles, respectivement. Le répertoire `channels` est destiné à contenir les tests pour les connexions et les canaux Action Cable. Le répertoire `controllers` est destiné à contenir les tests pour les contrôleurs, les routes et les vues. Le répertoire `integration` est destiné à contenir les tests pour les interactions entre les contrôleurs.

Le répertoire de tests système contient des tests système, qui sont utilisés pour tester votre application dans un navigateur complet. Les tests système vous permettent de tester votre application de la même manière que vos utilisateurs l'expérimentent et vous aident à tester votre JavaScript également. Les tests système héritent de Capybara et effectuent des tests dans le navigateur pour votre application.

Les fixtures sont une façon d'organiser les données de test ; elles résident dans le répertoire `fixtures`.

Un répertoire `jobs` sera également créé lorsqu'un test associé est généré pour la première fois.

Le fichier `test_helper.rb` contient la configuration par défaut de vos tests.

Le fichier `application_system_test_case.rb` contient la configuration par défaut de vos tests système.

### L'environnement de test

Par défaut, chaque application Rails dispose de trois environnements : développement, test et production.

La configuration de chaque environnement peut être modifiée de manière similaire. Dans ce cas, nous pouvons modifier notre environnement de test en changeant les options trouvées dans `config/environments/test.rb`.

NOTE : Vos tests sont exécutés sous `RAILS_ENV=test`.

### Rails rencontre Minitest

Si vous vous souvenez, nous avons utilisé la commande `bin/rails generate model` dans le guide [Démarrage avec Rails](getting_started.html). Nous avons créé notre premier modèle, et entre autres choses, cela a créé des ébauches de tests dans le répertoire `test` :

```bash
$ bin/rails generate model article title:string body:text
...
create  app/models/article.rb
create  test/models/article_test.rb
create  test/fixtures/articles.yml
...
```

L'ébauche de test par défaut dans `test/models/article_test.rb` ressemble à ceci :

```ruby
require "test_helper"

class ArticleTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
```

Un examen ligne par ligne de ce fichier vous aidera à vous familiariser avec le code et la terminologie des tests Rails.

```ruby
require "test_helper"
```

En requérant ce fichier, `test_helper.rb`, la configuration par défaut pour exécuter nos tests est chargée. Nous l'inclurons avec tous les tests que nous écrirons, de sorte que toutes les méthodes ajoutées à ce fichier soient disponibles pour tous nos tests.

```ruby
class ArticleTest < ActiveSupport::TestCase
```

La classe `ArticleTest` définit un _cas de test_ car elle hérite de `ActiveSupport::TestCase`. `ArticleTest` dispose donc de toutes les méthodes disponibles de `ActiveSupport::TestCase`. Plus tard dans ce guide, nous verrons certaines des méthodes qu'il nous offre.

Toute méthode définie dans une classe héritée de `Minitest::Test`
(qui est la superclasse de `ActiveSupport::TestCase`) et qui commence par `test_` est simplement appelée un test. Ainsi, les méthodes définies comme `test_password` et `test_valid_password` sont des noms de test valides et sont exécutées automatiquement lorsque le cas de test est exécuté.

Rails ajoute également une méthode `test` qui prend un nom de test et un bloc. Elle génère un test normal `Minitest::Unit` avec des noms de méthode préfixés par `test_`. Ainsi, vous n'avez pas à vous soucier de nommer les méthodes, et vous pouvez écrire quelque chose comme :

```ruby
test "the truth" do
  assert true
end
```

Ce qui est approximativement équivalent à écrire ceci :
```ruby
def test_the_truth
  assert true
end
```

Bien que vous puissiez toujours utiliser des définitions de méthode régulières, l'utilisation de la macro `test` permet un nom de test plus lisible.

REMARQUE: Le nom de la méthode est généré en remplaçant les espaces par des tirets bas. Le résultat n'a pas besoin d'être un identifiant Ruby valide, car le nom peut contenir des caractères de ponctuation, etc. En effet, en Ruby, techniquement, n'importe quelle chaîne peut être un nom de méthode. Cela peut nécessiter l'utilisation des appels `define_method` et `send` pour fonctionner correctement, mais formellement, il y a peu de restrictions sur le nom.

Ensuite, examinons notre première assertion:

```ruby
assert true
```

Une assertion est une ligne de code qui évalue un objet (ou une expression) pour obtenir des résultats attendus. Par exemple, une assertion peut vérifier:

* est-ce que cette valeur = cette valeur?
* est-ce que cet objet est nul?
* cette ligne de code génère-t-elle une exception?
* le mot de passe de l'utilisateur est-il supérieur à 5 caractères?

Chaque test peut contenir une ou plusieurs assertions, sans restriction quant au nombre d'assertions autorisées. Seulement lorsque toutes les assertions sont réussies, le test réussit.

#### Votre premier test en échec

Pour voir comment un échec de test est signalé, vous pouvez ajouter un test en échec au cas de test `article_test.rb`.

```ruby
test "ne doit pas enregistrer un article sans titre" do
  article = Article.new
  assert_not article.save
end
```

Exécutons ce nouveau test ajouté (où `6` est le numéro de ligne où le test est défini).

```bash
$ bin/rails test test/models/article_test.rb:6
Options d'exécution: --seed 44656

# Exécution:

F

Échec:
ArticleTest#test_ne_doit_pas_enregistrer_un_article_sans_titre [/chemin/vers/blog/test/models/article_test.rb:6]:
Expected true to be nil or false


bin/rails test test/models/article_test.rb:6



Terminé en 0.023918s, 41.8090 exécutions/s, 41.8090 assertions/s.

1 exécutions, 1 assertions, 1 échecs, 0 erreurs, 0 sauts
```

Dans la sortie, `F` indique un échec. Vous pouvez voir la trace correspondante affichée sous `Échec` avec le nom du test en échec. Les lignes suivantes contiennent la trace de la pile suivie d'un message qui mentionne la valeur réelle et la valeur attendue par l'assertion. Les messages d'échec d'assertion par défaut fournissent juste assez d'informations pour aider à localiser l'erreur. Pour rendre le message d'échec d'assertion plus lisible, chaque assertion fournit un paramètre de message facultatif, comme indiqué ici:

```ruby
test "ne doit pas enregistrer un article sans titre" do
  article = Article.new
  assert_not article.save, "Article enregistré sans titre"
end
```

L'exécution de ce test affiche le message d'échec d'assertion plus convivial:

```
Échec:
ArticleTest#test_ne_doit_pas_enregistrer_un_article_sans_titre [/chemin/vers/blog/test/models/article_test.rb:6]:
Article enregistré sans titre
```

Maintenant, pour faire passer ce test, nous pouvons ajouter une validation au niveau du modèle pour le champ _title_.

```ruby
class Article < ApplicationRecord
  validates :title, presence: true
end
```

Maintenant, le test devrait passer. Vérifions en exécutant à nouveau le test:

```bash
$ bin/rails test test/models/article_test.rb:6
Options d'exécution: --seed 31252

# Exécution:

.

Terminé en 0.027476s, 36.3952 exécutions/s, 36.3952 assertions/s.

1 exécutions, 1 assertions, 0 échecs, 0 erreurs, 0 sauts
```

Maintenant, si vous avez remarqué, nous avons d'abord écrit un test qui échoue pour une fonctionnalité souhaitée, puis nous avons écrit du code qui ajoute la fonctionnalité et enfin nous avons vérifié que notre test passe. Cette approche du développement logiciel est appelée [_Test-Driven Development_ (TDD)](http://c2.com/cgi/wiki?TestDrivenDevelopment).

#### À quoi ressemble une erreur

Pour voir comment une erreur est signalée, voici un test contenant une erreur:

```ruby
test "doit signaler une erreur" do
  # some_undefined_variable n'est pas définie ailleurs dans le cas de test
  some_undefined_variable
  assert true
end
```

Maintenant, vous pouvez voir encore plus de sortie dans la console lors de l'exécution des tests:

```bash
$ bin/rails test test/models/article_test.rb
Options d'exécution: --seed 1808

# Exécution:

.E

Erreur:
ArticleTest#test_doit_signaler_une_erreur:
NameError: undefined local variable or method 'some_undefined_variable' for #<ArticleTest:0x007fee3aa71798>
    test/models/article_test.rb:11:in 'block in <class:ArticleTest>'


bin/rails test test/models/article_test.rb:9



Terminé en 0.040609s, 49.2500 exécutions/s, 24.6250 assertions/s.

2 exécutions, 1 assertions, 0 échecs, 1 erreurs, 0 sauts
```

Remarquez le 'E' dans la sortie. Il indique un test avec une erreur.

REMARQUE: L'exécution de chaque méthode de test s'arrête dès qu'une erreur ou un échec d'assertion est rencontré, et la suite de tests se poursuit avec la méthode suivante. Toutes les méthodes de test sont exécutées dans un ordre aléatoire. L'option [`config.active_support.test_order`][] peut être utilisée pour configurer l'ordre des tests.

Lorsqu'un test échoue, vous obtenez la trace correspondante. Par défaut, Rails filtre cette trace et n'affiche que les lignes pertinentes pour votre application. Cela élimine le bruit du framework et permet de se concentrer sur votre code. Cependant, il y a des situations où vous voulez voir la trace complète. Définissez l'argument `-b` (ou `--backtrace`) pour activer ce comportement:
```bash
$ bin/rails test -b test/models/article_test.rb
```

Si nous voulons que ce test réussisse, nous pouvons le modifier pour utiliser `assert_raises` de la manière suivante :

```ruby
test "should report error" do
  # some_undefined_variable n'est pas défini ailleurs dans le cas de test
  assert_raises(NameError) do
    some_undefined_variable
  end
end
```

Ce test devrait maintenant réussir.


### Assertions disponibles

Jusqu'à présent, vous avez eu un aperçu de certaines des assertions disponibles. Les assertions sont les ouvrières des tests. Ce sont elles qui effectuent réellement les vérifications pour s'assurer que tout se passe comme prévu.

Voici un extrait des assertions que vous pouvez utiliser avec [`Minitest`](https://github.com/minitest/minitest), la bibliothèque de tests par défaut utilisée par Rails. Le paramètre `[msg]` est une chaîne de message facultative que vous pouvez spécifier pour rendre vos messages d'échec de test plus clairs.

| Assertion                                                        | Objectif |
| ---------------------------------------------------------------- | ------- |
| `assert( test, [msg] )`                                          | Vérifie que `test` est vrai.|
| `assert_not( test, [msg] )`                                      | Vérifie que `test` est faux.|
| `assert_equal( expected, actual, [msg] )`                        | Vérifie que `expected == actual` est vrai.|
| `assert_not_equal( expected, actual, [msg] )`                    | Vérifie que `expected != actual` est vrai.|
| `assert_same( expected, actual, [msg] )`                         | Vérifie que `expected.equal?(actual)` est vrai.|
| `assert_not_same( expected, actual, [msg] )`                     | Vérifie que `expected.equal?(actual)` est faux.|
| `assert_nil( obj, [msg] )`                                       | Vérifie que `obj.nil?` est vrai.|
| `assert_not_nil( obj, [msg] )`                                   | Vérifie que `obj.nil?` est faux.|
| `assert_empty( obj, [msg] )`                                     | Vérifie que `obj` est `empty?`.|
| `assert_not_empty( obj, [msg] )`                                 | Vérifie que `obj` n'est pas `empty?`.|
| `assert_match( regexp, string, [msg] )`                          | Vérifie qu'une chaîne correspond à l'expression régulière.|
| `assert_no_match( regexp, string, [msg] )`                       | Vérifie qu'une chaîne ne correspond pas à l'expression régulière.|
| `assert_includes( collection, obj, [msg] )`                      | Vérifie que `obj` est dans `collection`.|
| `assert_not_includes( collection, obj, [msg] )`                  | Vérifie que `obj` n'est pas dans `collection`.|
| `assert_in_delta( expected, actual, [delta], [msg] )`            | Vérifie que les nombres `expected` et `actual` sont à `delta` près l'un de l'autre.|
| `assert_not_in_delta( expected, actual, [delta], [msg] )`        | Vérifie que les nombres `expected` et `actual` ne sont pas à `delta` près l'un de l'autre.|
| `assert_in_epsilon ( expected, actual, [epsilon], [msg] )`       | Vérifie que les nombres `expected` et `actual` ont une erreur relative inférieure à `epsilon`.|
| `assert_not_in_epsilon ( expected, actual, [epsilon], [msg] )`   | Vérifie que les nombres `expected` et `actual` ont une erreur relative supérieure à `epsilon`.|
| `assert_throws( symbol, [msg] ) { block }`                       | Vérifie que le bloc donné lance le symbole.|
| `assert_raises( exception1, exception2, ... ) { block }`         | Vérifie que le bloc donné lève l'une des exceptions données.|
| `assert_instance_of( class, obj, [msg] )`                        | Vérifie que `obj` est une instance de `class`.|
| `assert_not_instance_of( class, obj, [msg] )`                    | Vérifie que `obj` n'est pas une instance de `class`.|
| `assert_kind_of( class, obj, [msg] )`                            | Vérifie que `obj` est une instance de `class` ou en descend.|
| `assert_not_kind_of( class, obj, [msg] )`                        | Vérifie que `obj` n'est pas une instance de `class` et n'en descend pas.|
| `assert_respond_to( obj, symbol, [msg] )`                        | Vérifie que `obj` répond à `symbol`.|
| `assert_not_respond_to( obj, symbol, [msg] )`                    | Vérifie que `obj` ne répond pas à `symbol`.|
| `assert_operator( obj1, operator, [obj2], [msg] )`               | Vérifie que `obj1.operator(obj2)` est vrai.|
| `assert_not_operator( obj1, operator, [obj2], [msg] )`           | Vérifie que `obj1.operator(obj2)` est faux.|
| `assert_predicate ( obj, predicate, [msg] )`                     | Vérifie que `obj.predicate` est vrai, par exemple `assert_predicate str, :empty?`|
| `assert_not_predicate ( obj, predicate, [msg] )`                 | Vérifie que `obj.predicate` est faux, par exemple `assert_not_predicate str, :empty?`|
| `flunk( [msg] )`                                                 | Force l'échec. Cela est utile pour marquer explicitement un test qui n'est pas encore terminé.|

Ce qui précède est un sous-ensemble des assertions que minitest prend en charge. Pour une liste exhaustive et plus à jour, veuillez consulter la documentation de l'API de Minitest, en particulier [`Minitest::Assertions`](http://docs.seattlerb.org/minitest/Minitest/Assertions.html).

En raison de la nature modulaire du framework de test, il est possible de créer vos propres assertions. En fait, c'est exactement ce que fait Rails. Il inclut certaines assertions spécialisées pour vous faciliter la vie.

REMARQUE : La création de vos propres assertions est un sujet avancé que nous n'aborderons pas dans ce tutoriel.

### Assertions spécifiques à Rails

Rails ajoute ses propres assertions personnalisées au framework `minitest` :
| Assertion                                                                         | But |
| --------------------------------------------------------------------------------- | ------- |
| [`assert_difference(expressions, difference = 1, message = nil) {...}`](https://api.rubyonrails.org/classes/ActiveSupport/Testing/Assertions.html#method-i-assert_difference) | Teste la différence numérique entre la valeur de retour d'une expression en conséquence de ce qui est évalué dans le bloc donné.|
| [`assert_no_difference(expressions, message = nil, &block)`](https://api.rubyonrails.org/classes/ActiveSupport/Testing/Assertions.html#method-i-assert_no_difference) | Vérifie que le résultat numérique de l'évaluation d'une expression n'est pas modifié avant et après l'invocation du bloc donné.|
| [`assert_changes(expressions, message = nil, from:, to:, &block)`](https://api.rubyonrails.org/classes/ActiveSupport/Testing/Assertions.html#method-i-assert_changes) | Teste que le résultat de l'évaluation d'une expression est modifié après l'invocation du bloc donné.|
| [`assert_no_changes(expressions, message = nil, &block)`](https://api.rubyonrails.org/classes/ActiveSupport/Testing/Assertions.html#method-i-assert_no_changes) | Teste que le résultat de l'évaluation d'une expression n'est pas modifié après l'invocation du bloc donné.|
| [`assert_nothing_raised { block }`](https://api.rubyonrails.org/classes/ActiveSupport/Testing/Assertions.html#method-i-assert_nothing_raised) | S'assure que le bloc donné ne génère aucune exception.|
| [`assert_recognizes(expected_options, path, extras={}, message=nil)`](https://api.rubyonrails.org/classes/ActionDispatch/Assertions/RoutingAssertions.html#method-i-assert_recognizes) | Vérifie que le routage du chemin donné a été géré correctement et que les options analysées (données dans le hachage expected_options) correspondent au chemin. Fondamentalement, cela vérifie que Rails reconnaît la route donnée par expected_options.|
| [`assert_generates(expected_path, options, defaults={}, extras = {}, message=nil)`](https://api.rubyonrails.org/classes/ActionDispatch/Assertions/RoutingAssertions.html#method-i-assert_generates) | Vérifie que les options fournies peuvent être utilisées pour générer le chemin fourni. C'est l'inverse de assert_recognizes. Le paramètre extras est utilisé pour indiquer à la requête les noms et valeurs des paramètres de requête supplémentaires qui seraient dans une chaîne de requête. Le paramètre message vous permet de spécifier un message d'erreur personnalisé pour les échecs de l'assertion.|
| [`assert_response(type, message = nil)`](https://api.rubyonrails.org/classes/ActionDispatch/Assertions/ResponseAssertions.html#method-i-assert_response) | Vérifie que la réponse est renvoyée avec un code d'état spécifique. Vous pouvez spécifier `:success` pour indiquer 200-299, `:redirect` pour indiquer 300-399, `:missing` pour indiquer 404, ou `:error` pour correspondre à la plage 500-599. Vous pouvez également passer un numéro de statut explicite ou son équivalent symbolique. Pour plus d'informations, consultez la [liste complète des codes de statut](https://rubydoc.info/gems/rack/Rack/Utils#HTTP_STATUS_CODES-constant) et comment fonctionne leur [correspondance](https://rubydoc.info/gems/rack/Rack/Utils#SYMBOL_TO_STATUS_CODE-constant).|
| [`assert_redirected_to(options = {}, message=nil)`](https://api.rubyonrails.org/classes/ActionDispatch/Assertions/ResponseAssertions.html#method-i-assert_redirected_to) | Vérifie que la réponse est une redirection vers une URL correspondant aux options données. Vous pouvez également passer des routes nommées telles que `assert_redirected_to root_path` et des objets Active Record tels que `assert_redirected_to @article`.|

Vous verrez l'utilisation de certaines de ces assertions dans le prochain chapitre.

### Une brève note sur les cas de test

Toutes les assertions de base telles que `assert_equal` définies dans `Minitest::Assertions` sont également disponibles dans les classes que nous utilisons dans nos propres cas de test. En fait, Rails fournit les classes suivantes à partir desquelles vous pouvez hériter :

* [`ActiveSupport::TestCase`](https://api.rubyonrails.org/classes/ActiveSupport/TestCase.html)
* [`ActionMailer::TestCase`](https://api.rubyonrails.org/classes/ActionMailer/TestCase.html)
* [`ActionView::TestCase`](https://api.rubyonrails.org/classes/ActionView/TestCase.html)
* [`ActiveJob::TestCase`](https://api.rubyonrails.org/classes/ActiveJob/TestCase.html)
* [`ActionDispatch::IntegrationTest`](https://api.rubyonrails.org/classes/ActionDispatch/IntegrationTest.html)
* [`ActionDispatch::SystemTestCase`](https://api.rubyonrails.org/classes/ActionDispatch/SystemTestCase.html)
* [`Rails::Generators::TestCase`](https://api.rubyonrails.org/classes/Rails/Generators/TestCase.html)

Chacune de ces classes inclut `Minitest::Assertions`, ce qui nous permet d'utiliser toutes les assertions de base dans nos tests.

NOTE : Pour plus d'informations sur `Minitest`, consultez [sa documentation](http://docs.seattlerb.org/minitest).

### L'exécuteur de tests Rails

Nous pouvons exécuter tous nos tests en une seule fois en utilisant la commande `bin/rails test`.

Ou nous pouvons exécuter un seul fichier de test en passant à la commande `bin/rails test` le nom du fichier contenant les cas de test.

```bash
$ bin/rails test test/models/article_test.rb
Options d'exécution : --seed 1559

# Exécution :

..

Terminé en 0,027034s, 73,9810 exécutions/s, 110,9715 assertions/s.

2 exécutions, 3 assertions, 0 échecs, 0 erreurs, 0 sauts
```

Cela exécutera toutes les méthodes de test du cas de test.

Vous pouvez également exécuter une méthode de test particulière du cas de test en fournissant le drapeau `-n` ou `--name` et le nom de la méthode de test.

```bash
$ bin/rails test test/models/article_test.rb -n test_the_truth
Options d'exécution : -n test_the_truth --seed 43583

# Exécution :

.

Tests terminés en 0,009064s, 110,3266 tests/s, 110,3266 assertions/s.

1 test, 1 assertion, 0 échecs, 0 erreurs, 0 sauts
```

Vous pouvez également exécuter un test à une ligne spécifique en fournissant le numéro de ligne.

```bash
$ bin/rails test test/models/article_test.rb:6 # exécuter un test spécifique et une ligne
```

Vous pouvez également exécuter un répertoire entier de tests en fournissant le chemin du répertoire.

```bash
$ bin/rails test test/controllers # exécuter tous les tests d'un répertoire spécifique
```

L'exécuteur de tests offre également de nombreuses autres fonctionnalités telles que l'arrêt rapide en cas d'échec, le report différé des résultats des tests à la fin de l'exécution des tests, etc. Consultez la documentation de l'exécuteur de tests comme suit :

```bash
$ bin/rails test -h
Utilisation : rails test [options] [fichiers ou répertoires]

Vous pouvez exécuter un seul test en ajoutant un numéro de ligne à un nom de fichier :

    bin/rails test test/models/user_test.rb:27

Vous pouvez exécuter plusieurs fichiers et répertoires en même temps :

    bin/rails test test/controllers test/integration/login_test.rb

Par défaut, les échecs et les erreurs des tests sont signalés en ligne pendant l'exécution.

Options de minitest :
    -h, --help                       Affiche cette aide.
        --no-plugins                 Contourne le chargement automatique des plugins minitest (ou définissez $MT_NO_PLUGINS).
    -s, --seed SEED                  Définit la graine aléatoire. Également via env. Ex : SEED=n rake
    -v, --verbose                    Verbose. Affiche la progression du traitement des fichiers.
    -n, --name PATTERN               Filtre l'exécution sur /regexp/ ou une chaîne.
        --exclude PATTERN            Exclut /regexp/ ou une chaîne de l'exécution.

Extensions connues : rails, pride
    -w, --warnings                   Exécute avec les avertissements Ruby activés
    -e, --environment ENV            Exécute les tests dans l'environnement ENV
    -b, --backtrace                  Affiche la trace complète
    -d, --defer-output               Affiche les échecs et les erreurs des tests après l'exécution des tests
    -f, --fail-fast                  Interrompt l'exécution des tests au premier échec ou erreur
    -c, --[no-]color                 Active la couleur dans la sortie
    -p, --pride                      Fierté. Montre ta fierté de tester !
```
### Exécution des tests en intégration continue (CI)

Pour exécuter tous les tests dans un environnement CI, il vous suffit d'une seule commande :

```bash
$ bin/rails test
```

Si vous utilisez des [tests système](#system-testing), `bin/rails test` ne les exécutera pas, car ils peuvent être lents. Pour les exécuter également, ajoutez une autre étape CI qui exécute `bin/rails test:system`, ou modifiez votre première étape en `bin/rails test:all`, qui exécute tous les tests, y compris les tests système.

Tests parallèles
----------------

Les tests parallèles vous permettent de paralléliser votre suite de tests. Bien que la méthode par défaut soit la création de processus, le threading est également pris en charge. L'exécution de tests en parallèle réduit le temps nécessaire pour exécuter l'ensemble de votre suite de tests.

### Tests parallèles avec des processus

La méthode de parallélisation par défaut consiste à créer des processus en utilisant le système DRb de Ruby. Les processus sont créés en fonction du nombre de travailleurs fournis. Le nombre par défaut est le nombre réel de cœurs sur la machine sur laquelle vous vous trouvez, mais peut être modifié en passant le nombre à la méthode parallelize.

Pour activer la parallélisation, ajoutez ce qui suit à votre `test_helper.rb` :

```ruby
class ActiveSupport::TestCase
  parallelize(workers: 2)
end
```

Le nombre de travailleurs passés est le nombre de fois que le processus sera créé. Vous voudrez peut-être paralléliser votre suite de tests locale différemment de votre CI, donc une variable d'environnement est fournie pour pouvoir facilement changer le nombre de travailleurs qu'une exécution de test doit utiliser :

```bash
$ PARALLEL_WORKERS=15 bin/rails test
```

Lors de la parallélisation des tests, Active Record gère automatiquement la création d'une base de données et le chargement du schéma dans la base de données pour chaque processus. Les bases de données seront suffixées par le numéro correspondant au travailleur. Par exemple, si vous avez 2 travailleurs, les tests créeront respectivement `test-database-0` et `test-database-1`.

Si le nombre de travailleurs passés est inférieur ou égal à 1, les processus ne seront pas créés et les tests ne seront pas parallélisés et les tests utiliseront la base de données `test-database` d'origine.

Deux hooks sont fournis, l'un s'exécute lorsque le processus est créé, et l'autre s'exécute avant que le processus créé ne soit fermé. Ils peuvent être utiles si votre application utilise plusieurs bases de données ou effectue d'autres tâches qui dépendent du nombre de travailleurs.

La méthode `parallelize_setup` est appelée juste après la création des processus. La méthode `parallelize_teardown` est appelée juste avant la fermeture des processus.

```ruby
class ActiveSupport::TestCase
  parallelize_setup do |worker|
    # configuration des bases de données
  end

  parallelize_teardown do |worker|
    # nettoyage des bases de données
  end

  parallelize(workers: :number_of_processors)
end
```

Ces méthodes ne sont pas nécessaires ou disponibles lors de l'utilisation de tests parallèles avec des threads.

### Tests parallèles avec des threads

Si vous préférez utiliser des threads ou si vous utilisez JRuby, une option de parallélisation par thread est disponible. Le paralléliseur threadé est basé sur l'exécuteur `Parallel::Executor` de Minitest.

Pour changer la méthode de parallélisation pour utiliser des threads plutôt que des processus, ajoutez ce qui suit à votre `test_helper.rb` :

```ruby
class ActiveSupport::TestCase
  parallelize(workers: :number_of_processors, with: :threads)
end
```

Les applications Rails générées à partir de JRuby ou TruffleRuby incluront automatiquement l'option `with: :threads`.

Le nombre de travailleurs passé à `parallelize` détermine le nombre de threads que les tests utiliseront. Vous voudrez peut-être paralléliser votre suite de tests locale différemment de votre CI, donc une variable d'environnement est fournie pour pouvoir facilement changer le nombre de travailleurs qu'une exécution de test doit utiliser :

```bash
$ PARALLEL_WORKERS=15 bin/rails test
```

### Tests de transactions parallèles

Rails enveloppe automatiquement chaque cas de test dans une transaction de base de données qui est annulée après l'exécution du test. Cela rend les cas de test indépendants les uns des autres et les modifications apportées à la base de données ne sont visibles que dans un seul test.

Lorsque vous souhaitez tester du code qui exécute des transactions parallèles dans des threads, les transactions peuvent se bloquer mutuellement car elles sont déjà imbriquées sous la transaction de test.

Vous pouvez désactiver les transactions dans une classe de cas de test en définissant `self.use_transactional_tests = false` :

```ruby
class WorkerTest < ActiveSupport::TestCase
  self.use_transactional_tests = false

  test "transactions parallèles" do
    # démarrer des threads qui créent des transactions
  end
end
```

REMARQUE : Avec les tests transactionnels désactivés, vous devez nettoyer toutes les données créées par les tests, car les modifications ne sont pas automatiquement annulées après l'exécution du test.

### Seuil de parallélisation des tests

L'exécution de tests en parallèle ajoute une surcharge en termes de configuration de la base de données et de chargement des fixtures. Pour cette raison, Rails ne parallélisera pas les exécutions qui impliquent moins de 50 tests.

Vous pouvez configurer ce seuil dans votre `test.rb` :
```ruby
config.active_support.test_parallelization_threshold = 100
```

Et aussi lors de la configuration de la parallélisation au niveau des cas de test :

```ruby
class ActiveSupport::TestCase
  parallelize threshold: 100
end
```

La base de données de test
--------------------------

Presque toutes les applications Rails interagissent intensivement avec une base de données et, par conséquent, vos tests auront également besoin d'une base de données avec laquelle interagir. Pour écrire des tests efficaces, vous devrez comprendre comment configurer cette base de données et la remplir avec des données d'exemple.

Par défaut, chaque application Rails dispose de trois environnements : développement, test et production. La base de données de chacun d'entre eux est configurée dans `config/database.yml`.

Une base de données de test dédiée vous permet de configurer et d'interagir avec des données de test de manière isolée. De cette façon, vos tests peuvent manipuler les données de test en toute confiance, sans se soucier des données dans les bases de données de développement ou de production.

### Maintenir le schéma de la base de données de test

Pour exécuter vos tests, votre base de données de test devra avoir la structure actuelle. L'assistant de test vérifie si votre base de données de test a des migrations en attente. Il essaiera de charger votre `db/schema.rb` ou `db/structure.sql` dans la base de données de test. Si des migrations sont encore en attente, une erreur sera générée. Cela indique généralement que votre schéma n'est pas entièrement migré. Exécuter les migrations contre la base de données de développement (`bin/rails db:migrate`) mettra à jour le schéma.

NOTE : Si des modifications ont été apportées aux migrations existantes, la base de données de test doit être reconstruite. Cela peut être fait en exécutant `bin/rails db:test:prepare`.

### Les bases des données de test

Pour de bons tests, vous devrez réfléchir à la configuration des données de test. Dans Rails, vous pouvez le faire en définissant et en personnalisant des bases de données de test. Vous pouvez trouver une documentation complète dans la [documentation de l'API des bases de données de test](https://api.rubyonrails.org/classes/ActiveRecord/FixtureSet.html).

#### Qu'est-ce qu'une base de données de test ?

_Les bases de données de test_ est un terme élégant pour désigner des données d'exemple. Les bases de données de test vous permettent de remplir votre base de données de test avec des données prédéfinies avant l'exécution de vos tests. Les bases de données de test sont indépendantes de la base de données et sont écrites en YAML. Il y a un fichier par modèle.

NOTE : Les bases de données de test ne sont pas conçues pour créer tous les objets dont vos tests ont besoin, et elles sont mieux gérées lorsqu'elles sont utilisées uniquement pour les données par défaut qui peuvent être appliquées au cas général.

Vous trouverez les bases de données de test dans votre répertoire `test/fixtures`. Lorsque vous exécutez `bin/rails generate model` pour créer un nouveau modèle, Rails crée automatiquement des ébauches de bases de données de test dans ce répertoire.

#### YAML

Les bases de données de test au format YAML sont une façon conviviale de décrire vos données d'exemple. Ces types de bases de données de test ont l'extension de fichier **.yml** (comme `users.yml`).

Voici un exemple de fichier de base de données de test YAML :

```yaml
# lo & behold! I am a YAML comment!
david:
  name: David Heinemeier Hansson
  birthday: 1979-10-15
  profession: Développement de systèmes

steve:
  name: Steve Ross Kellock
  birthday: 1974-09-27
  profession: gars avec un clavier
```

Chaque base de données de test est donnée un nom suivi d'une liste indentée de paires clé/valeur séparées par des deux-points. Les enregistrements sont généralement séparés par une ligne vide. Vous pouvez placer des commentaires dans un fichier de base de données de test en utilisant le caractère # en première colonne.

Si vous travaillez avec des [associations](/association_basics.html), vous pouvez définir un nœud de référence entre deux bases de données de test différentes. Voici un exemple avec une association `belongs_to`/`has_many` :

```yaml
# test/fixtures/categories.yml
about:
  name: À propos
```

```yaml
# test/fixtures/articles.yml
first:
  title: Bienvenue dans Rails !
  category: about
```

```yaml
# test/fixtures/action_text/rich_texts.yml
first_content:
  record: first (Article)
  name: content
  body: <div>Bonjour, depuis <strong>une base de données de test</strong></div>
```

Remarquez que la clé `category` de l'article `first` trouvé dans `fixtures/articles.yml` a une valeur de `about`, et que la clé `record` de l'entrée `first_content` trouvée dans `fixtures/action_text/rich_texts.yml` a une valeur de `first (Article)`. Cela indique à Active Record de charger la catégorie `about` trouvée dans `fixtures/categories.yml` pour le premier, et à Action Text de charger l'article `first` trouvé dans `fixtures/articles.yml` pour le second.

NOTE : Pour que les associations se réfèrent les unes aux autres par leur nom, vous pouvez utiliser le nom de la base de données de test à la place de spécifier l'attribut `id:` sur les bases de données de test associées. Rails attribuera automatiquement une clé primaire pour être cohérente entre les exécutions. Pour plus d'informations sur ce comportement d'association, veuillez lire la [documentation de l'API des bases de données de test](https://api.rubyonrails.org/classes/ActiveRecord/FixtureSet.html).

#### Bases de données de test pour les pièces jointes de fichiers

Comme les autres modèles basés sur Active Record, les enregistrements de pièces jointes Active Storage héritent des instances de ActiveRecord::Base et peuvent donc être remplis par des bases de données de test.

Considérez un modèle `Article` qui a une image associée en tant que pièce jointe `thumbnail`, ainsi que des données de base de données de test YAML :

```ruby
class Article
  has_one_attached :thumbnail
end
```

```yaml
# test/fixtures/articles.yml
first:
  title: Un article
```

En supposant qu'il existe un fichier encodé [image/png][] à l'emplacement `test/fixtures/files/first.png`, les entrées de fixture YAML suivantes généreront les enregistrements `ActiveStorage::Blob` et `ActiveStorage::Attachment` associés :

```yaml
# test/fixtures/active_storage/blobs.yml
first_thumbnail_blob: <%= ActiveStorage::FixtureSet.blob filename: "first.png" %>
```

```yaml
# test/fixtures/active_storage/attachments.yml
first_thumbnail_attachment:
  name: thumbnail
  record: first (Article)
  blob: first_thumbnail_blob
```


#### ERB'in It Up

ERB vous permet d'intégrer du code Ruby dans les modèles. Le format de fixture YAML est prétraité avec ERB lorsque Rails charge les fixtures. Cela vous permet d'utiliser Ruby pour vous aider à générer des données d'exemple. Par exemple, le code suivant génère mille utilisateurs :

```erb
<% 1000.times do |n| %>
user_<%= n %>:
  username: <%= "user#{n}" %>
  email: <%= "user#{n}@example.com" %>
<% end %>
```

#### Les fixtures en action

Rails charge automatiquement toutes les fixtures du répertoire `test/fixtures` par défaut. Le chargement se fait en trois étapes :

1. Supprimer toutes les données existantes de la table correspondant à la fixture
2. Charger les données de la fixture dans la table
3. Sauvegarder les données de la fixture dans une méthode au cas où vous souhaitez y accéder directement

CONSEIL : Pour supprimer les données existantes de la base de données, Rails essaie de désactiver les déclencheurs d'intégrité référentielle (comme les clés étrangères et les contraintes de vérification). Si vous rencontrez des erreurs de permission ennuyeuses lors de l'exécution des tests, assurez-vous que l'utilisateur de la base de données a le privilège de désactiver ces déclencheurs dans l'environnement de test. (Dans PostgreSQL, seuls les superutilisateurs peuvent désactiver tous les déclencheurs. En savoir plus sur les autorisations PostgreSQL [ici](https://www.postgresql.org/docs/current/sql-altertable.html)).

#### Les fixtures sont des objets Active Record

Les fixtures sont des instances d'Active Record. Comme mentionné au point #3 ci-dessus, vous pouvez accéder à l'objet directement car il est automatiquement disponible en tant que méthode dont la portée est locale au cas de test. Par exemple :

```ruby
# cela renverra l'objet User pour la fixture nommée david
users(:david)

# cela renverra la propriété id de david
users(:david).id

# on peut également accéder aux méthodes disponibles sur la classe User
david = users(:david)
david.call(david.partner)
```

Pour obtenir plusieurs fixtures à la fois, vous pouvez passer une liste de noms de fixtures. Par exemple :

```ruby
# cela renverra un tableau contenant les fixtures david et steve
users(:david, :steve)
```


Test des modèles
----------------

Les tests des modèles sont utilisés pour tester les différents modèles de votre application.

Les tests des modèles Rails sont stockés dans le répertoire `test/models`. Rails fournit un générateur pour créer un squelette de test de modèle pour vous.

```bash
$ bin/rails generate test_unit:model article title:string body:text
create  test/models/article_test.rb
create  test/fixtures/articles.yml
```

Les tests des modèles n'ont pas de superclasse propre comme `ActionMailer::TestCase`. Au lieu de cela, ils héritent de [`ActiveSupport::TestCase`](https://api.rubyonrails.org/classes/ActiveSupport/TestCase.html).

Test du système
---------------

Les tests du système vous permettent de tester les interactions des utilisateurs avec votre application, en exécutant des tests dans un navigateur réel ou sans tête. Les tests du système utilisent Capybara en interne.

Pour créer des tests du système Rails, utilisez le répertoire `test/system` de votre application. Rails fournit un générateur pour créer un squelette de test du système pour vous.

```bash
$ bin/rails generate system_test users
      invoke test_unit
      create test/system/users_test.rb
```

Voici à quoi ressemble un test du système fraîchement généré :

```ruby
require "application_system_test_case"

class UsersTest < ApplicationSystemTestCase
  # test "visiting the index" do
  #   visit users_url
  #
  #   assert_selector "h1", text: "Users"
  # end
end
```

Par défaut, les tests du système sont exécutés avec le pilote Selenium, en utilisant le navigateur Chrome et une taille d'écran de 1400x1400. La section suivante explique comment modifier les paramètres par défaut.

### Modification des paramètres par défaut

Rails facilite grandement la modification des paramètres par défaut des tests du système. Toute la configuration est abstraite pour que vous puissiez vous concentrer sur l'écriture de vos tests.

Lorsque vous générez une nouvelle application ou un nouveau scaffold, un fichier `application_system_test_case.rb` est créé dans le répertoire de test. C'est là que toute la configuration de vos tests du système doit être placée.

Si vous souhaitez modifier les paramètres par défaut, vous pouvez modifier ce qui "pilote" les tests du système. Disons que vous voulez changer le pilote de Selenium à Cuprite. Ajoutez d'abord la gem `cuprite` à votre `Gemfile`. Ensuite, dans votre fichier `application_system_test_case.rb`, faites ce qui suit :

```ruby
require "test_helper"
require "capybara/cuprite"

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  driven_by :cuprite
end
```

Le nom du pilote est un argument obligatoire pour `driven_by`. Les arguments facultatifs qui peuvent être passés à `driven_by` sont `:using` pour le navigateur (cela ne sera utilisé que par Selenium), `:screen_size` pour changer la taille de l'écran pour les captures d'écran, et `:options` qui peuvent être utilisées pour définir des options prises en charge par le pilote.
```ruby
require "test_helper"

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  driven_by :selenium, using: :firefox
end
```

Si vous souhaitez utiliser un navigateur sans interface graphique, vous pouvez utiliser Headless Chrome ou Headless Firefox en ajoutant `headless_chrome` ou `headless_firefox` dans l'argument `:using`.

```ruby
require "test_helper"

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  driven_by :selenium, using: :headless_chrome
end
```

Si vous souhaitez utiliser un navigateur distant, par exemple [Headless Chrome dans Docker](https://github.com/SeleniumHQ/docker-selenium), vous devez ajouter l'URL distante via les `options`.

```ruby
require "test_helper"

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  options = ENV["SELENIUM_REMOTE_URL"].present? ? { url: ENV["SELENIUM_REMOTE_URL"] } : {}
  driven_by :selenium, using: :headless_chrome, options: options
end
```

Dans ce cas, la gem `webdrivers` n'est plus nécessaire. Vous pouvez la supprimer complètement ou ajouter l'option `require:` dans le fichier `Gemfile`.

```ruby
# ...
group :test do
  gem "webdrivers", require: !ENV["SELENIUM_REMOTE_URL"] || ENV["SELENIUM_REMOTE_URL"].empty?
end
```

Maintenant, vous devriez obtenir une connexion au navigateur distant.

```bash
$ SELENIUM_REMOTE_URL=http://localhost:4444/wd/hub bin/rails test:system
```

Si votre application en test s'exécute également à distance, par exemple dans un conteneur Docker, Capybara a besoin de plus d'informations sur la façon d'appeler les serveurs distants.

```ruby
require "test_helper"

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  def setup
    Capybara.server_host = "0.0.0.0" # lier à toutes les interfaces
    Capybara.app_host = "http://#{IPSocket.getaddress(Socket.gethostname)}" if ENV["SELENIUM_REMOTE_URL"].present?
    super
  end
  # ...
end
```

Maintenant, vous devriez obtenir une connexion au navigateur et au serveur distant, que ce soit dans un conteneur Docker ou dans un environnement d'intégration continue.

Si votre configuration Capybara nécessite plus de paramètres que ceux fournis par Rails, cette configuration supplémentaire peut être ajoutée dans le fichier `application_system_test_case.rb`.

Veuillez consulter la [documentation de Capybara](https://github.com/teamcapybara/capybara#setup) pour des paramètres supplémentaires.

### Aide pour les captures d'écran

Le `ScreenshotHelper` est un assistant conçu pour capturer des captures d'écran de vos tests. Cela peut être utile pour visualiser le navigateur à l'endroit où un test a échoué, ou pour visualiser ultérieurement les captures d'écran à des fins de débogage.

Deux méthodes sont fournies : `take_screenshot` et `take_failed_screenshot`. `take_failed_screenshot` est automatiquement inclus dans `before_teardown` à l'intérieur de Rails.

La méthode d'aide `take_screenshot` peut être incluse n'importe où dans vos tests pour prendre une capture d'écran du navigateur.

### Mise en œuvre d'un test système

Maintenant, nous allons ajouter un test système à notre application de blog. Nous allons démontrer l'écriture d'un test système en visitant la page d'index et en créant un nouvel article de blog.

Si vous avez utilisé le générateur de squelette, un squelette de test système a été automatiquement créé pour vous. Si vous n'avez pas utilisé le générateur de squelette, commencez par créer un squelette de test système.

```bash
$ bin/rails generate system_test articles
```

Il devrait avoir créé un fichier de test fictif pour nous. Avec la sortie de la commande précédente, vous devriez voir :

```
      invoke  test_unit
      create    test/system/articles_test.rb
```

Maintenant, ouvrons ce fichier et écrivons notre première assertion :

```ruby
require "application_system_test_case"

class ArticlesTest < ApplicationSystemTestCase
  test "viewing the index" do
    visit articles_path
    assert_selector "h1", text: "Articles"
  end
end
```

Le test devrait vérifier qu'il y a un `h1` sur la page d'index des articles et réussir.

Exécutez les tests système.

```bash
$ bin/rails test:system
```

NOTE : Par défaut, l'exécution de `bin/rails test` ne lancera pas vos tests système. Assurez-vous d'exécuter `bin/rails test:system` pour les exécuter réellement. Vous pouvez également exécuter `bin/rails test:all` pour exécuter tous les tests, y compris les tests système.

#### Création d'un test système pour les articles

Maintenant, testons le flux de création d'un nouvel article dans notre blog.

```ruby
test "should create Article" do
  visit articles_path

  click_on "New Article"

  fill_in "Title", with: "Creating an Article"
  fill_in "Body", with: "Created this article successfully!"

  click_on "Create Article"

  assert_text "Creating an Article"
end
```

La première étape consiste à appeler `visit articles_path`. Cela amènera le test à la page d'index des articles.

Ensuite, `click_on "New Article"` trouvera le bouton "New Article" sur la page d'index. Cela redirigera le navigateur vers `/articles/new`.

Ensuite, le test remplira le titre et le corps de l'article avec le texte spécifié. Une fois les champs remplis, "Create Article" est cliqué, ce qui enverra une requête POST pour créer le nouvel article dans la base de données.

Nous serons redirigés vers la page d'index des articles et nous vérifions que le texte du titre du nouvel article est présent sur la page d'index des articles.

#### Test pour plusieurs tailles d'écran

Si vous souhaitez tester les tailles mobiles en plus des tailles de bureau, vous pouvez créer une autre classe qui hérite de `ActionDispatch::SystemTestCase` et l'utiliser dans votre suite de tests. Dans cet exemple, un fichier appelé `mobile_system_test_case.rb` est créé dans le répertoire `/test` avec la configuration suivante.
```ruby
require "test_helper"

class MobileSystemTestCase < ActionDispatch::SystemTestCase
  driven_by :selenium, using: :chrome, screen_size: [375, 667]
end
```

Pour utiliser cette configuration, créez un test à l'intérieur de `test/system` qui hérite de `MobileSystemTestCase`.
Maintenant, vous pouvez tester votre application en utilisant plusieurs configurations différentes.

```ruby
require "mobile_system_test_case"

class PostsTest < MobileSystemTestCase
  test "visiting the index" do
    visit posts_url
    assert_selector "h1", text: "Posts"
  end
end
```

#### Aller plus loin

La beauté des tests système est qu'ils sont similaires aux tests d'intégration
dans la mesure où ils testent l'interaction de l'utilisateur avec votre contrôleur, votre modèle et votre vue, mais
les tests système sont beaucoup plus robustes et testent réellement votre application comme si
un véritable utilisateur l'utilisait. À l'avenir, vous pouvez tester tout ce que l'utilisateur
ferait dans votre application, comme commenter, supprimer des articles,
publier des articles en brouillon, etc.

Tests d'intégration
-------------------

Les tests d'intégration sont utilisés pour tester comment différentes parties de notre application interagissent. Ils sont généralement utilisés pour tester les flux de travail importants au sein de notre application.

Pour créer des tests d'intégration Rails, nous utilisons le répertoire `test/integration` de notre application. Rails fournit un générateur pour créer un squelette de test d'intégration.

```bash
$ bin/rails generate integration_test user_flows
      exists  test/integration/
      create  test/integration/user_flows_test.rb
```

Voici à quoi ressemble un test d'intégration nouvellement généré :

```ruby
require "test_helper"

class UserFlowsTest < ActionDispatch::IntegrationTest
  # test "the truth" do
  #   assert true
  # end
end
```

Ici, le test hérite de `ActionDispatch::IntegrationTest`. Cela rend certains assistants supplémentaires disponibles pour nous aider dans nos tests d'intégration.

### Assistants disponibles pour les tests d'intégration

En plus des assistants de test standard, l'héritage de `ActionDispatch::IntegrationTest` offre quelques assistants supplémentaires disponibles lors de l'écriture de tests d'intégration. Faisons une brève présentation des trois catégories d'assistants que nous pouvons choisir.

Pour gérer l'exécution des tests d'intégration, consultez [`ActionDispatch::Integration::Runner`](https://api.rubyonrails.org/classes/ActionDispatch/Integration/Runner.html).

Lors de l'exécution de requêtes, nous aurons [`ActionDispatch::Integration::RequestHelpers`](https://api.rubyonrails.org/classes/ActionDispatch/Integration/RequestHelpers.html) à notre disposition.

Si nous devons modifier la session ou l'état de notre test d'intégration, consultez [`ActionDispatch::Integration::Session`](https://api.rubyonrails.org/classes/ActionDispatch/Integration/Session.html) pour obtenir de l'aide.

### Mise en œuvre d'un test d'intégration

Ajoutons un test d'intégration à notre application de blog. Nous commencerons par un flux de travail de base consistant à créer un nouvel article de blog pour vérifier que tout fonctionne correctement.

Commençons par générer le squelette de notre test d'intégration :

```bash
$ bin/rails generate integration_test blog_flow
```

Cela devrait avoir créé un fichier de test fictif pour nous. Avec la sortie de la
commande précédente, nous devrions voir :

```
      invoke  test_unit
      create    test/integration/blog_flow_test.rb
```

Ouvrons maintenant ce fichier et écrivons notre première assertion :

```ruby
require "test_helper"

class BlogFlowTest < ActionDispatch::IntegrationTest
  test "can see the welcome page" do
    get "/"
    assert_select "h1", "Welcome#index"
  end
end
```

Nous examinerons `assert_select` pour interroger le HTML résultant d'une requête dans la section "Testing Views" ci-dessous. Il est utilisé pour tester la réponse de notre requête en vérifiant la présence d'éléments HTML clés et de leur contenu.

Lorsque nous visitons notre chemin racine, nous devrions voir `welcome/index.html.erb` rendu pour la vue. Donc cette assertion devrait passer.

#### Création d'une intégration d'articles

Et si nous testions notre capacité à créer un nouvel article dans notre blog et à voir l'article résultant.

```ruby
test "can create an article" do
  get "/articles/new"
  assert_response :success

  post "/articles",
    params: { article: { title: "can create", body: "article successfully." } }
  assert_response :redirect
  follow_redirect!
  assert_response :success
  assert_select "p", "Title:\n  can create"
end
```

Décortiquons ce test pour le comprendre.

Nous commençons par appeler l'action `:new` sur notre contrôleur Articles. Cette réponse devrait être réussie.

Ensuite, nous effectuons une requête POST vers l'action `:create` de notre contrôleur Articles :

```ruby
post "/articles",
  params: { article: { title: "can create", body: "article successfully." } }
assert_response :redirect
follow_redirect!
```

Les deux lignes suivant la requête servent à gérer la redirection que nous avons configurée lors de la création d'un nouvel article.

NOTE : N'oubliez pas d'appeler `follow_redirect!` si vous prévoyez de faire des requêtes ultérieures après une redirection.

Enfin, nous pouvons affirmer que notre réponse a été réussie et que notre nouvel article est lisible sur la page.

#### Aller plus loin

Nous avons réussi à tester avec succès un flux de travail très simple pour visiter notre blog et créer un nouvel article. Si nous voulions aller plus loin, nous pourrions ajouter des tests pour les commentaires, la suppression d'articles ou la modification de commentaires. Les tests d'intégration sont un excellent moyen d'expérimenter toutes sortes de cas d'utilisation pour nos applications.
Tests fonctionnels pour vos contrôleurs
-----------------------------------------

Dans Rails, tester les différentes actions d'un contrôleur est une forme de tests fonctionnels. Rappelez-vous que vos contrôleurs gèrent les requêtes web entrantes de votre application et finissent par répondre avec une vue rendue. Lorsque vous écrivez des tests fonctionnels, vous testez comment vos actions gèrent les requêtes et le résultat ou la réponse attendue, dans certains cas une vue HTML.

### Ce qu'il faut inclure dans vos tests fonctionnels

Vous devriez tester des choses telles que :

* la requête web a-t-elle réussi ?
* l'utilisateur a-t-il été redirigé vers la bonne page ?
* l'authentification de l'utilisateur a-t-elle réussi ?
* le message approprié a-t-il été affiché à l'utilisateur dans la vue ?
* les informations correctes ont-elles été affichées dans la réponse ?

La manière la plus simple de voir des tests fonctionnels en action est de générer un contrôleur en utilisant le générateur de squelette :

```bash
$ bin/rails generate scaffold_controller article title:string body:text
...
create  app/controllers/articles_controller.rb
...
invoke  test_unit
create    test/controllers/articles_controller_test.rb
...
```

Cela générera le code du contrôleur et les tests pour une ressource `Article`. Vous pouvez consulter le fichier `articles_controller_test.rb` dans le répertoire `test/controllers`.

Si vous avez déjà un contrôleur et que vous voulez simplement générer le code de squelette de test pour chacune des sept actions par défaut, vous pouvez utiliser la commande suivante :

```bash
$ bin/rails generate test_unit:scaffold article
...
invoke  test_unit
create    test/controllers/articles_controller_test.rb
...
```

Jetons un coup d'œil à l'un de ces tests, `test_should_get_index` du fichier `articles_controller_test.rb`.

```ruby
# articles_controller_test.rb
class ArticlesControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get articles_url
    assert_response :success
  end
end
```

Dans le test `test_should_get_index`, Rails simule une requête sur l'action appelée `index`, en s'assurant que la requête a réussi et en vérifiant également que le bon corps de réponse a été généré.

La méthode `get` lance la requête web et remplit les résultats dans `@response`. Elle peut accepter jusqu'à 6 arguments :

* L'URI de l'action du contrôleur que vous demandez.
  Cela peut être sous forme de chaîne de caractères ou d'un helper de route (par exemple `articles_url`).
* `params` : option avec un hash de paramètres de requête à passer à l'action
  (par exemple des paramètres de chaîne de requête ou des variables d'article).
* `headers` : pour définir les en-têtes qui seront transmis avec la requête.
* `env` : pour personnaliser l'environnement de la requête si nécessaire.
* `xhr` : indique si la requête est une requête Ajax ou non. Peut être défini sur true pour marquer la requête comme Ajax.
* `as` : pour encoder la requête avec un type de contenu différent.

Tous ces arguments de mot-clé sont facultatifs.

Exemple : Appeler l'action `:show` pour le premier `Article`, en passant un en-tête `HTTP_REFERER` :

```ruby
get article_url(Article.first), headers: { "HTTP_REFERER" => "http://example.com/home" }
```

Autre exemple : Appeler l'action `:update` pour le dernier `Article`, en passant un nouveau texte pour le `title` dans `params`, en tant que requête Ajax :

```ruby
patch article_url(Article.last), params: { article: { title: "updated" } }, xhr: true
```

Encore un exemple : Appeler l'action `:create` pour créer un nouvel article, en passant du texte pour le `title` dans `params`, en tant que requête JSON :

```ruby
post articles_path, params: { article: { title: "Ahoy!" } }, as: :json
```

NOTE : Si vous essayez d'exécuter le test `test_should_create_article` de `articles_controller_test.rb`, il échouera en raison de la validation ajoutée au niveau du modèle et c'est normal.

Modifions le test `test_should_create_article` dans `articles_controller_test.rb` pour que tous nos tests passent :

```ruby
test "should create article" do
  assert_difference("Article.count") do
    post articles_url, params: { article: { body: "Rails is awesome!", title: "Hello Rails" } }
  end

  assert_redirected_to article_path(Article.last)
end
```

Maintenant, vous pouvez essayer d'exécuter tous les tests et ils devraient passer.

NOTE : Si vous avez suivi les étapes de la section [Authentification de base](getting_started.html#basic-authentication), vous devrez ajouter l'autorisation à chaque en-tête de requête pour que tous les tests passent :

```ruby
post articles_url, params: { article: { body: "Rails is awesome!", title: "Hello Rails" } }, headers: { Authorization: ActionController::HttpAuthentication::Basic.encode_credentials("dhh", "secret") }
```

### Types de requêtes disponibles pour les tests fonctionnels

Si vous êtes familier avec le protocole HTTP, vous saurez que `get` est un type de requête. Il existe 6 types de requêtes pris en charge dans les tests fonctionnels de Rails :

* `get`
* `post`
* `patch`
* `put`
* `head`
* `delete`

Tous les types de requêtes ont des méthodes équivalentes que vous pouvez utiliser. Dans une application C.R.U.D. typique, vous utiliserez plus souvent `get`, `post`, `put` et `delete`.
NOTE: Les tests fonctionnels ne vérifient pas si le type de requête spécifié est accepté par l'action, nous nous préoccupons davantage du résultat. Les tests de requête existent pour ce cas d'utilisation afin de rendre vos tests plus significatifs.

### Test des requêtes XHR (Ajax)

Pour tester les requêtes Ajax, vous pouvez spécifier l'option `xhr: true` pour les méthodes `get`, `post`, `patch`, `put` et `delete`. Par exemple :

```ruby
test "requête ajax" do
  article = articles(:one)
  get article_url(article), xhr: true

  assert_equal "hello world", @response.body
  assert_equal "text/javascript", @response.media_type
end
```

### Les trois Hash de l'Apocalypse

Après qu'une requête a été effectuée et traitée, vous aurez 3 objets Hash prêts à être utilisés :

* `cookies` - Tous les cookies qui sont définis
* `flash` - Tous les objets présents dans le flash
* `session` - Tout objet présent dans les variables de session

Comme c'est le cas avec les objets Hash normaux, vous pouvez accéder aux valeurs en référençant les clés par chaîne de caractères. Vous pouvez également les référencer par leur nom de symbole. Par exemple :

```ruby
flash["gordon"]               flash[:gordon]
session["shmession"]          session[:shmession]
cookies["are_good_for_u"]     cookies[:are_good_for_u]
```

### Variables d'instance disponibles

**Après** qu'une requête a été effectuée, vous avez également accès à trois variables d'instance dans vos tests fonctionnels :

* `@controller` - Le contrôleur qui traite la requête
* `@request` - L'objet de requête
* `@response` - L'objet de réponse


```ruby
class ArticlesControllerTest < ActionDispatch::IntegrationTest
  test "devrait obtenir l'index" do
    get articles_url

    assert_equal "index", @controller.action_name
    assert_equal "application/x-www-form-urlencoded", @request.media_type
    assert_match "Articles", @response.body
  end
end
```

### Définition des en-têtes et des variables CGI

[Les en-têtes HTTP](https://tools.ietf.org/search/rfc2616#section-5.3)
et
[les variables CGI](https://tools.ietf.org/search/rfc3875#section-4.1)
peuvent être transmis en tant qu'en-têtes :

```ruby
# définition d'un en-tête HTTP
get articles_url, headers: { "Content-Type": "text/plain" } # simuler la requête avec un en-tête personnalisé

# définition d'une variable CGI
get articles_url, headers: { "HTTP_REFERER": "http://example.com/home" } # simuler la requête avec une variable d'environnement personnalisée
```

### Test des notifications `flash`

Si vous vous souvenez de notre discussion précédente, l'un des trois Hash de l'Apocalypse était `flash`.

Nous voulons ajouter un message `flash` à notre application de blog chaque fois que quelqu'un crée avec succès un nouvel article.

Commençons par ajouter cette assertion à notre test `test_should_create_article` :

```ruby
test "devrait créer un article" do
  assert_difference("Article.count") do
    post articles_url, params: { article: { title: "Some title" } }
  end

  assert_redirected_to article_path(Article.last)
  assert_equal "Article a été créé avec succès.", flash[:notice]
end
```

Si nous exécutons maintenant notre test, nous devrions voir un échec :

```bash
$ bin/rails test test/controllers/articles_controller_test.rb -n test_should_create_article
Options d'exécution : -n test_should_create_article --seed 32266

# Exécution :

F

Terminé en 0.114870s, 8.7055 exécutions/s, 34.8220 assertions/s.

  1) Échec :
ArticlesControllerTest#test_should_create_article [/test/controllers/articles_controller_test.rb:16]:
--- expected
+++ actual
@@ -1 +1 @@
-"Article a été créé avec succès."
+nil

1 exécution, 4 assertions, 1 échec, 0 erreurs, 0 ignorés
```

Implémentons maintenant le message `flash` dans notre contrôleur. Notre action `:create` devrait maintenant ressembler à ceci :

```ruby
def create
  @article = Article.new(article_params)

  if @article.save
    flash[:notice] = "Article a été créé avec succès."
    redirect_to @article
  else
    render "new"
  end
end
```

Maintenant, si nous exécutons nos tests, nous devrions voir qu'ils réussissent :

```bash
$ bin/rails test test/controllers/articles_controller_test.rb -n test_should_create_article
Options d'exécution : -n test_should_create_article --seed 18981

# Exécution :

.

Terminé en 0.081972s, 12.1993 exécutions/s, 48.7972 assertions/s.

1 exécution, 4 assertions, 0 échecs, 0 erreurs, 0 ignorés
```

### Mise en pratique

À ce stade, notre contrôleur Articles teste les actions `:index`, `:new` et `:create`. Que faire avec les données existantes ?

Écrivons un test pour l'action `:show` :

```ruby
test "devrait afficher l'article" do
  article = articles(:one)
  get article_url(article)
  assert_response :success
end
```

Souvenez-vous de notre discussion précédente sur les fixtures, la méthode `articles()` nous donnera accès à nos fixtures d'articles.

Et comment supprimer un article existant ?

```ruby
test "devrait supprimer l'article" do
  article = articles(:one)
  assert_difference("Article.count", -1) do
    delete article_url(article)
  end

  assert_redirected_to articles_path
end
```

Nous pouvons également ajouter un test pour mettre à jour un article existant.

```ruby
test "devrait mettre à jour l'article" do
  article = articles(:one)

  patch article_url(article), params: { article: { title: "updated" } }

  assert_redirected_to article_path(article)
  # Rechargez l'association pour récupérer les données mises à jour et vérifiez que le titre est mis à jour.
  article.reload
  assert_equal "updated", article.title
end
```

Remarquez que nous commençons à voir une certaine duplication dans ces trois tests, ils accèdent tous les deux aux mêmes données de fixture d'article. Nous pouvons rendre cela plus D.R.Y. en utilisant les méthodes `setup` et `teardown` fournies par `ActiveSupport::Callbacks`.

Maintenant, notre test devrait ressembler à quelque chose comme ce qui suit. Ignorez les autres tests pour l'instant, nous les laissons de côté pour des raisons de concision.
```ruby
require "test_helper"

class ArticlesControllerTest < ActionDispatch::IntegrationTest
  # appelé avant chaque test individuel
  setup do
    @article = articles(:one)
  end

  # appelé après chaque test individuel
  teardown do
    # lorsqu'un contrôleur utilise le cache, il est conseillé de le réinitialiser ensuite
    Rails.cache.clear
  end

  test "should show article" do
    # Réutilise la variable d'instance @article définie dans le setup
    get article_url(@article)
    assert_response :success
  end

  test "should destroy article" do
    assert_difference("Article.count", -1) do
      delete article_url(@article)
    end

    assert_redirected_to articles_path
  end

  test "should update article" do
    patch article_url(@article), params: { article: { title: "updated" } }

    assert_redirected_to article_path(@article)
    # Recharge l'association pour récupérer les données mises à jour et vérifie que le titre est mis à jour.
    @article.reload
    assert_equal "updated", @article.title
  end
end
```

Comme pour les autres rappels dans Rails, les méthodes `setup` et `teardown` peuvent également être utilisées en passant un bloc, une lambda ou un nom de méthode sous forme de symbole à appeler.

### Aides de test

Pour éviter la duplication de code, vous pouvez ajouter vos propres aides de test.
L'aide de connexion peut être un bon exemple :

```ruby
# test/test_helper.rb

module SignInHelper
  def sign_in_as(user)
    post sign_in_url(email: user.email, password: user.password)
  end
end

class ActionDispatch::IntegrationTest
  include SignInHelper
end
```

```ruby
require "test_helper"

class ProfileControllerTest < ActionDispatch::IntegrationTest
  test "should show profile" do
    # l'aide est maintenant réutilisable à partir de n'importe quel cas de test de contrôleur
    sign_in_as users(:david)

    get profile_url
    assert_response :success
  end
end
```

#### Utilisation de fichiers séparés

Si vous trouvez que vos aides encombrent `test_helper.rb`, vous pouvez les extraire dans des fichiers séparés.
Un bon endroit pour les stocker est `test/lib` ou `test/test_helpers`.

```ruby
# test/test_helpers/multiple_assertions.rb
module MultipleAssertions
  def assert_multiple_of_forty_two(number)
    assert (number % 42 == 0), "expected #{number} to be a multiple of 42"
  end
end
```

Ces aides peuvent ensuite être explicitement requises au besoin et incluses au besoin

```ruby
require "test_helper"
require "test_helpers/multiple_assertions"

class NumberTest < ActiveSupport::TestCase
  include MultipleAssertions

  test "420 is a multiple of forty two" do
    assert_multiple_of_forty_two 420
  end
end
```

ou elles peuvent continuer à être incluses directement dans les classes parent pertinentes

```ruby
# test/test_helper.rb
require "test_helpers/sign_in_helper"

class ActionDispatch::IntegrationTest
  include SignInHelper
end
```

#### Requête préalable des aides

Il peut être pratique de requérir préalablement les aides dans `test_helper.rb` afin que vos fichiers de test y aient un accès implicite. Cela peut être accompli en utilisant le globbing, comme suit

```ruby
# test/test_helper.rb
Dir[Rails.root.join("test", "test_helpers", "**", "*.rb")].each { |file| require file }
```

Cela a pour inconvénient d'augmenter le temps de démarrage, par rapport à la requête manuelle uniquement des fichiers nécessaires dans vos tests individuels.

Test des routes
--------------

Comme tout le reste de votre application Rails, vous pouvez tester vos routes. Les tests de routes se trouvent dans `test/controllers/` ou font partie des tests de contrôleur.

REMARQUE : Si votre application a des routes complexes, Rails fournit plusieurs aides utiles pour les tester.

Pour plus d'informations sur les assertions de routage disponibles dans Rails, consultez la documentation de l'API pour [`ActionDispatch::Assertions::RoutingAssertions`](https://api.rubyonrails.org/classes/ActionDispatch/Assertions/RoutingAssertions.html).

Test des vues
-------------

Tester la réponse à votre requête en vérifiant la présence d'éléments HTML clés et leur contenu est une façon courante de tester les vues de votre application. Comme les tests de routes, les tests de vues se trouvent dans `test/controllers/` ou font partie des tests de contrôleur. La méthode `assert_select` vous permet d'interroger les éléments HTML de la réponse en utilisant une syntaxe simple mais puissante.

Il existe deux formes de `assert_select` :

`assert_select(selector, [equality], [message])` garantit que la condition d'égalité est respectée sur les éléments sélectionnés par le sélecteur. Le sélecteur peut être une expression de sélecteur CSS (String) ou une expression avec des valeurs de substitution.

`assert_select(element, selector, [equality], [message])` garantit que la condition d'égalité est respectée sur tous les éléments sélectionnés par le sélecteur à partir de l'_élément_ (instance de `Nokogiri::XML::Node` ou `Nokogiri::XML::NodeSet`) et de ses descendants.

Par exemple, vous pouvez vérifier le contenu de l'élément de titre dans votre réponse avec :

```ruby
assert_select "title", "Welcome to Rails Testing Guide"
```

Vous pouvez également utiliser des blocs `assert_select` imbriqués pour des investigations plus approfondies.

Dans l'exemple suivant, le `assert_select` interne pour `li.menu_item` s'exécute
dans la collection d'éléments sélectionnés par le bloc externe :

```ruby
assert_select "ul.navigation" do
  assert_select "li.menu_item"
end
```

Une collection d'éléments sélectionnés peut être itérée afin que `assert_select` puisse être appelé séparément pour chaque élément.

Par exemple, si la réponse contient deux listes ordonnées, chacune avec quatre éléments de liste imbriqués, les tests suivants réussiront tous les deux.

```ruby
assert_select "ol" do |elements|
  elements.each do |element|
    assert_select element, "li", 4
  end
end

assert_select "ol" do
  assert_select "li", 8
end
```

Cette assertion est assez puissante. Pour une utilisation plus avancée, consultez sa [documentation](https://github.com/rails/rails-dom-testing/blob/master/lib/rails/dom/testing/assertions/selector_assertions.rb).

### Assertions supplémentaires basées sur la vue

Il existe d'autres assertions principalement utilisées dans les tests de vues :

| Assertion                                                 | Objectif |
| --------------------------------------------------------- | ------- |
| `assert_select_email`                                     | Vous permet de faire des assertions sur le corps d'un e-mail. |
| `assert_select_encoded`                                   | Vous permet de faire des assertions sur du HTML encodé. Il le fait en décodant le contenu de chaque élément, puis en appelant le bloc avec tous les éléments non encodés.|
| `css_select(selector)` ou `css_select(element, selector)` | Retourne un tableau de tous les éléments sélectionnés par le _sélecteur_. Dans la deuxième variante, il correspond d'abord à l'_élément_ de base, puis essaie de faire correspondre l'expression du _sélecteur_ à l'un de ses enfants. Si aucune correspondance n'est trouvée, les deux variantes renvoient un tableau vide.|

Voici un exemple d'utilisation de `assert_select_email` :

```ruby
assert_select_email do
  assert_select "small", "Please click the 'Unsubscribe' link if you want to opt-out."
end
```

Testing Helpers
---------------

Un helper est simplement un module simple dans lequel vous pouvez définir des méthodes disponibles dans vos vues.

Pour tester les helpers, il vous suffit de vérifier que la sortie de la méthode du helper correspond à ce que vous attendez. Les tests liés aux helpers se trouvent dans le répertoire `test/helpers`.

Supposons que nous ayons le helper suivant :

```ruby
module UsersHelper
  def link_to_user(user)
    link_to "#{user.first_name} #{user.last_name}", user
  end
end
```

Nous pouvons tester la sortie de cette méthode de la manière suivante :

```ruby
class UsersHelperTest < ActionView::TestCase
  test "should return the user's full name" do
    user = users(:david)

    assert_dom_equal %{<a href="/user/#{user.id}">David Heinemeier Hansson</a>}, link_to_user(user)
  end
end
```

De plus, puisque la classe de test étend `ActionView::TestCase`, vous avez accès aux méthodes d'aide de Rails telles que `link_to` ou `pluralize`.

Testing Your Mailers
--------------------

Tester les classes de mailer nécessite des outils spécifiques pour faire un travail approfondi.

### Garder le facteur sous contrôle

Vos classes de mailer - comme toutes les autres parties de votre application Rails - doivent être testées pour s'assurer qu'elles fonctionnent comme prévu.

Les objectifs des tests de vos classes de mailer sont de s'assurer que :

* les e-mails sont traités (créés et envoyés)
* le contenu de l'e-mail est correct (sujet, expéditeur, corps, etc.)
* les bons e-mails sont envoyés au bon moment

#### De tous les côtés

Il y a deux aspects pour tester votre mailer, les tests unitaires et les tests fonctionnels. Dans les tests unitaires, vous exécutez le mailer de manière isolée avec des entrées étroitement contrôlées et comparez la sortie à une valeur connue (un fixture). Dans les tests fonctionnels, vous ne testez pas tant les détails minutieux produits par le mailer ; au lieu de cela, nous testons si nos contrôleurs et modèles utilisent le mailer de la bonne manière. Vous testez pour prouver que le bon e-mail a été envoyé au bon moment.

### Tests unitaires

Pour tester si votre mailer fonctionne comme prévu, vous pouvez utiliser des tests unitaires pour comparer les résultats réels du mailer avec des exemples pré-écrits de ce qui devrait être produit.

#### La revanche des fixtures

Dans le cadre des tests unitaires d'un mailer, les fixtures sont utilisées pour fournir un exemple de ce à quoi la sortie _devrait_ ressembler. Étant donné qu'il s'agit d'e-mails d'exemple et non de données Active Record comme les autres fixtures, ils sont conservés dans leur propre sous-répertoire séparé des autres fixtures. Le nom du répertoire dans `test/fixtures` correspond directement au nom du mailer. Ainsi, pour un mailer nommé `UserMailer`, les fixtures doivent résider dans le répertoire `test/fixtures/user_mailer`.

Si vous avez généré votre mailer, le générateur ne crée pas de fixtures fictives pour les actions du mailer. Vous devrez créer ces fichiers vous-même comme décrit ci-dessus.

#### Le cas de test de base

Voici un test unitaire pour tester un mailer nommé `UserMailer` dont l'action `invite` est utilisée pour envoyer une invitation à un ami. Il s'agit d'une version adaptée du test de base créé par le générateur pour une action `invite`.

```ruby
require "test_helper"

class UserMailerTest < ActionMailer::TestCase
  test "invite" do
    # Créez l'e-mail et stockez-le pour d'autres assertions
    email = UserMailer.create_invite("me@example.com",
                                     "friend@example.com", Time.now)

    # Envoyez l'e-mail, puis testez s'il a été mis en file d'attente
    assert_emails 1 do
      email.deliver_now
    end

    # Testez que le corps de l'e-mail envoyé contient ce à quoi nous nous attendons
    assert_equal ["me@example.com"], email.from
    assert_equal ["friend@example.com"], email.to
    assert_equal "You have been invited by me@example.com", email.subject
    assert_equal read_fixture("invite").join, email.body.to_s
  end
end
```
Dans le test, nous créons l'e-mail et stockons l'objet renvoyé dans la variable `email`. Ensuite, nous nous assurons qu'il a été envoyé (le premier assert), puis, dans le deuxième groupe d'assertions, nous nous assurons que l'e-mail contient bien ce que nous attendons. L'aide `read_fixture` est utilisée pour lire le contenu de ce fichier.

NOTE : `email.body.to_s` est présent lorsqu'il n'y a qu'une seule partie (HTML ou texte). Si le mailer en fournit les deux, vous pouvez tester votre fixture par rapport à des parties spécifiques avec `email.text_part.body.to_s` ou `email.html_part.body.to_s`.

Voici le contenu de la fixture `invite` :

```
Salut friend@example.com,

Tu as été invité.

Amicalement !
```

C'est le bon moment pour en savoir un peu plus sur l'écriture de tests pour vos mailers. La ligne `ActionMailer::Base.delivery_method = :test` dans `config/environments/test.rb` définit le mode de livraison en mode test afin que l'e-mail ne soit pas réellement envoyé (utile pour éviter de spammer vos utilisateurs lors des tests), mais qu'il soit plutôt ajouté à un tableau (`ActionMailer::Base.deliveries`).

NOTE : Le tableau `ActionMailer::Base.deliveries` n'est réinitialisé automatiquement que dans les tests `ActionMailer::TestCase` et `ActionDispatch::IntegrationTest`. Si vous souhaitez repartir à zéro en dehors de ces cas de test, vous pouvez le réinitialiser manuellement avec : `ActionMailer::Base.deliveries.clear`

#### Test des e-mails en file d'attente

Vous pouvez utiliser l'assertion `assert_enqueued_email_with` pour confirmer que l'e-mail a été mis en file d'attente avec tous les arguments de la méthode mailer attendus et/ou les paramètres du mailer paramétrés. Cela vous permet de faire correspondre tous les e-mails qui ont été mis en file d'attente avec la méthode `deliver_later`.

Comme dans le cas de test de base, nous créons l'e-mail et stockons l'objet renvoyé dans la variable `email`. Les exemples suivants incluent des variations de passage d'arguments et/ou de paramètres.

Cet exemple vérifiera que l'e-mail a été mis en file d'attente avec les bons arguments :

```ruby
require "test_helper"

class UserMailerTest < ActionMailer::TestCase
  test "invite" do
    # Crée l'e-mail et le stocke pour d'autres assertions
    email = UserMailer.create_invite("me@example.com", "friend@example.com")

    # Vérifie que l'e-mail a été mis en file d'attente avec les bons arguments
    assert_enqueued_email_with UserMailer, :create_invite, args: ["me@example.com", "friend@example.com"] do
      email.deliver_later
    end
  end
end
```

Cet exemple vérifiera qu'un mailer a été mis en file d'attente avec les bons arguments nommés de la méthode mailer en passant un hash des arguments en tant que `args` :

```ruby
require "test_helper"

class UserMailerTest < ActionMailer::TestCase
  test "invite" do
    # Crée l'e-mail et le stocke pour d'autres assertions
    email = UserMailer.create_invite(from: "me@example.com", to: "friend@example.com")

    # Vérifie que l'e-mail a été mis en file d'attente avec les bons arguments nommés
    assert_enqueued_email_with UserMailer, :create_invite, args: [{ from: "me@example.com",
                                                                    to: "friend@example.com" }] do
      email.deliver_later
    end
  end
end
```

Cet exemple vérifiera qu'un mailer paramétré a été mis en file d'attente avec les bons paramètres et arguments du mailer. Les paramètres du mailer sont passés en tant que `params` et les arguments de la méthode mailer en tant que `args` :

```ruby
require "test_helper"

class UserMailerTest < ActionMailer::TestCase
  test "invite" do
    # Crée l'e-mail et le stocke pour d'autres assertions
    email = UserMailer.with(all: "good").create_invite("me@example.com", "friend@example.com")

    # Vérifie que l'e-mail a été mis en file d'attente avec les bons paramètres et arguments du mailer
    assert_enqueued_email_with UserMailer, :create_invite, params: { all: "good" },
                                                           args: ["me@example.com", "friend@example.com"] do
      email.deliver_later
    end
  end
end
```

Cet exemple montre une autre façon de vérifier qu'un mailer paramétré a été mis en file d'attente avec les bons paramètres :

```ruby
require "test_helper"

class UserMailerTest < ActionMailer::TestCase
  test "invite" do
    # Crée l'e-mail et le stocke pour d'autres assertions
    email = UserMailer.with(to: "friend@example.com").create_invite

    # Vérifie que l'e-mail a été mis en file d'attente avec les bons paramètres du mailer
    assert_enqueued_email_with UserMailer.with(to: "friend@example.com"), :create_invite do
      email.deliver_later
    end
  end
end
```

### Tests fonctionnels et système

Les tests unitaires nous permettent de tester les attributs de l'e-mail, tandis que les tests fonctionnels et système nous permettent de tester si les interactions de l'utilisateur déclenchent correctement l'envoi de l'e-mail. Par exemple, vous pouvez vérifier que l'opération d'invitation d'un ami envoie un e-mail de manière appropriée :

```ruby
# Test d'intégration
require "test_helper"

class UsersControllerTest < ActionDispatch::IntegrationTest
  test "invite friend" do
    # Vérifie la différence dans ActionMailer::Base.deliveries
    assert_emails 1 do
      post invite_friend_url, params: { email: "friend@example.com" }
    end
  end
end
```

```ruby
# Test système
require "test_helper"

class UsersTest < ActionDispatch::SystemTestCase
  driven_by :selenium, using: :headless_chrome

  test "inviting a friend" do
    visit invite_users_url
    fill_in "Email", with: "friend@example.com"
    assert_emails 1 do
      click_on "Invite"
    end
  end
end
```

NOTE : La méthode `assert_emails` n'est pas liée à une méthode de livraison particulière et fonctionnera avec les e-mails envoyés avec la méthode `deliver_now` ou `deliver_later`. Si nous voulons explicitement vérifier que l'e-mail a été mis en file d'attente, nous pouvons utiliser les méthodes `assert_enqueued_email_with` ([exemples ci-dessus](#testing-enqueued-emails)) ou `assert_enqueued_emails`. Plus d'informations peuvent être trouvées dans la [documentation ici](https://api.rubyonrails.org/classes/ActionMailer/TestHelper.html).
Tests d'emploi
------------

Étant donné que vos emplois personnalisés peuvent être mis en file d'attente à différents niveaux à l'intérieur de votre application,
vous devrez tester à la fois les emplois eux-mêmes (leur comportement lorsqu'ils sont mis en file d'attente)
et que d'autres entités les mettent correctement en file d'attente.

### Un cas de test de base

Par défaut, lorsque vous générez un emploi, un test associé sera également généré
sous le répertoire `test/jobs`. Voici un exemple de test avec un emploi de facturation :

```ruby
require "test_helper"

class BillingJobTest < ActiveJob::TestCase
  test "que le compte est facturé" do
    BillingJob.perform_now(account, product)
    assert account.reload.charged_for?(product)
  end
end
```

Ce test est assez simple et ne fait que vérifier si l'emploi a effectué le travail attendu.

### Assertions personnalisées et tests d'emplois à l'intérieur d'autres composants

Active Job est livré avec un ensemble d'assertions personnalisées qui peuvent être utilisées pour réduire la verbosité des tests. Pour une liste complète des assertions disponibles, consultez la documentation de l'API pour [`ActiveJob::TestHelper`](https://api.rubyonrails.org/classes/ActiveJob/TestHelper.html).

Il est bon de vérifier que vos emplois sont correctement mis en file d'attente ou exécutés
partout où vous les invoquez (par exemple, à l'intérieur de vos contrôleurs). C'est précisément là
que les assertions personnalisées fournies par Active Job sont très utiles. Par exemple,
dans un modèle, vous pouvez confirmer qu'un emploi a été mis en file d'attente :

```ruby
require "test_helper"

class ProductTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  test "planification de l'emploi de facturation" do
    assert_enqueued_with(job: BillingJob) do
      product.charge(account)
    end
    assert_not account.reload.charged_for?(product)
  end
end
```

L'adaptateur par défaut, `:test`, n'exécute pas les emplois lorsqu'ils sont mis en file d'attente.
Vous devez lui indiquer quand vous voulez que les emplois soient exécutés :

```ruby
require "test_helper"

class ProductTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  test "planification de l'emploi de facturation" do
    perform_enqueued_jobs(only: BillingJob) do
      product.charge(account)
    end
    assert account.reload.charged_for?(product)
  end
end
```

Tous les emplois précédemment exécutés et mis en file d'attente sont effacés avant chaque exécution de test,
vous pouvez donc supposer en toute sécurité qu'aucun emploi n'a déjà été exécuté dans le cadre de chaque test.

Test de Action Cable
--------------------

Étant donné que Action Cable est utilisé à différents niveaux à l'intérieur de votre application,
vous devrez tester à la fois les canaux, les classes de connexion elles-mêmes, et que d'autres
entités diffusent les messages corrects.

### Cas de test de connexion

Par défaut, lorsque vous générez une nouvelle application Rails avec Action Cable, un test pour la classe de connexion de base (`ApplicationCable::Connection`) est également généré sous le répertoire `test/channels/application_cable`.

Les tests de connexion visent à vérifier si les identifiants d'une connexion sont correctement attribués
ou si des demandes de connexion incorrectes sont rejetées. Voici un exemple :

```ruby
class ApplicationCable::ConnectionTest < ActionCable::Connection::TestCase
  test "se connecte avec des paramètres" do
    # Simule l'ouverture d'une connexion en appelant la méthode `connect`
    connect params: { user_id: 42 }

    # Vous pouvez accéder à l'objet Connection via `connection` dans les tests
    assert_equal connection.user_id, "42"
  end

  test "rejette la connexion sans paramètres" do
    # Utilisez l'assertion `assert_reject_connection` pour vérifier que
    # la connexion est rejetée
    assert_reject_connection { connect }
  end
end
```

Vous pouvez également spécifier les cookies de requête de la même manière que vous le faites dans les tests d'intégration :

```ruby
test "se connecte avec des cookies" do
  cookies.signed[:user_id] = "42"

  connect

  assert_equal connection.user_id, "42"
end
```

Consultez la documentation de l'API pour [`ActionCable::Connection::TestCase`](https://api.rubyonrails.org/classes/ActionCable/Connection/TestCase.html) pour plus d'informations.

### Cas de test de canal

Par défaut, lorsque vous générez un canal, un test associé sera également généré
sous le répertoire `test/channels`. Voici un exemple de test avec un canal de discussion :

```ruby
require "test_helper"

class ChatChannelTest < ActionCable::Channel::TestCase
  test "s'abonne et diffuse pour la salle" do
    # Simule la création d'un abonnement en appelant `subscribe`
    subscribe room: "15"

    # Vous pouvez accéder à l'objet Channel via `subscription` dans les tests
    assert subscription.confirmed?
    assert_has_stream "chat_15"
  end
end
```

Ce test est assez simple et ne fait que vérifier si le canal abonne la connexion à un flux particulier.

Vous pouvez également spécifier les identifiants de connexion sous-jacents. Voici un exemple de test avec un canal de notifications web :

```ruby
require "test_helper"

class WebNotificationsChannelTest < ActionCable::Channel::TestCase
  test "s'abonne et diffuse pour l'utilisateur" do
    stub_connection current_user: users(:john)

    subscribe

    assert_has_stream_for users(:john)
  end
end
```

Consultez la documentation de l'API pour [`ActionCable::Channel::TestCase`](https://api.rubyonrails.org/classes/ActionCable/Channel/TestCase.html) pour plus d'informations.

### Assertions personnalisées et tests de diffusion à l'intérieur d'autres composants

Action Cable est livré avec un ensemble d'assertions personnalisées qui peuvent être utilisées pour réduire la verbosité des tests. Pour une liste complète des assertions disponibles, consultez la documentation de l'API pour [`ActionCable::TestHelper`](https://api.rubyonrails.org/classes/ActionCable/TestHelper.html).

Il est bon de vérifier que le bon message a été diffusé à l'intérieur d'autres composants (par exemple, à l'intérieur de vos contrôleurs). C'est précisément là
que les assertions personnalisées fournies par Action Cable sont très utiles. Par exemple,
dans un modèle :
```ruby
require "test_helper"

class ProductTest < ActionCable::TestCase
  test "diffuser le statut après la charge" do
    assert_broadcast_on("products:#{product.id}", type: "charged") do
      product.charge(account)
    end
  end
end
```

Si vous souhaitez tester la diffusion effectuée avec `Channel.broadcast_to`, vous devez utiliser `Channel.broadcasting_for` pour générer un nom de flux sous-jacent :

```ruby
# app/jobs/chat_relay_job.rb
class ChatRelayJob < ApplicationJob
  def perform(room, message)
    ChatChannel.broadcast_to room, text: message
  end
end
```

```ruby
# test/jobs/chat_relay_job_test.rb
require "test_helper"

class ChatRelayJobTest < ActiveJob::TestCase
  include ActionCable::TestHelper

  test "diffuser un message dans la salle" do
    room = rooms(:all)

    assert_broadcast_on(ChatChannel.broadcasting_for(room), text: "Salut !") do
      ChatRelayJob.perform_now(room, "Salut !")
    end
  end
end
```

Test de chargement anticipé
---------------------------

Normalement, les applications ne se chargent pas de manière anticipée dans les environnements `development` ou `test` pour accélérer les choses. Mais elles le font dans l'environnement `production`.

Si un fichier du projet ne peut pas être chargé pour une raison quelconque, il vaut mieux le détecter avant de le déployer en production, n'est-ce pas ?

### Intégration continue

Si votre projet dispose d'une intégration continue, le chargement anticipé en CI est un moyen facile de s'assurer que l'application se charge de manière anticipée.

Les CI définissent généralement une variable d'environnement pour indiquer que la suite de tests s'exécute là-bas. Par exemple, cela pourrait être `CI` :

```ruby
# config/environments/test.rb
config.eager_load = ENV["CI"].present?
```

À partir de Rails 7, les applications nouvellement générées sont configurées de cette manière par défaut.

### Suites de tests minimales

Si votre projet n'a pas d'intégration continue, vous pouvez quand même charger de manière anticipée dans la suite de tests en appelant `Rails.application.eager_load!` :

#### Minitest

```ruby
require "test_helper"

class ZeitwerkComplianceTest < ActiveSupport::TestCase
  test "charge de manière anticipée tous les fichiers sans erreur" do
    assert_nothing_raised { Rails.application.eager_load! }
  end
end
```

#### RSpec

```ruby
require "rails_helper"

RSpec.describe "Conformité Zeitwerk" do
  it "charge de manière anticipée tous les fichiers sans erreur" do
    expect { Rails.application.eager_load! }.not_to raise_error
  end
end
```

Ressources de test supplémentaires
----------------------------------

### Test du code dépendant du temps

Rails fournit des méthodes d'aide intégrées qui vous permettent de vérifier que votre code sensible au temps fonctionne comme prévu.

L'exemple suivant utilise l'aide [`travel_to`][travel_to] :

```ruby
# Étant donné qu'un utilisateur est éligible pour offrir un mois après son inscription.
user = User.create(name: "Gaurish", activation_date: Date.new(2004, 10, 24))
assert_not user.applicable_for_gifting?

travel_to Date.new(2004, 11, 24) do
  # À l'intérieur du bloc `travel_to`, `Date.current` est simulé
  assert_equal Date.new(2004, 10, 24), user.activation_date
  assert user.applicable_for_gifting?
end

# Le changement n'était visible que dans le bloc `travel_to`.
assert_equal Date.new(2004, 10, 24), user.activation_date
```

Veuillez consulter la référence de l'API [`ActiveSupport::Testing::TimeHelpers`][time_helpers_api] pour plus d'informations sur les aides temporelles disponibles.
[`config.active_support.test_order`]: configuring.html#config-active-support-test-order
[image/png]: https://developer.mozilla.org/en-US/docs/Web/HTTP/Basics_of_HTTP/MIME_types#image_types
[travel_to]: https://api.rubyonrails.org/classes/ActiveSupport/Testing/TimeHelpers.html#method-i-travel_to
[time_helpers_api]: https://api.rubyonrails.org/classes/ActiveSupport/Testing/TimeHelpers.html
