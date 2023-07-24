**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 17dc214f52c294509e9b174971ef1ab3
Contribuer à Ruby on Rails
=============================

Ce guide explique comment _vous_ pouvez devenir partie prenante du développement continu de Ruby on Rails.

Après avoir lu ce guide, vous saurez :

* Comment utiliser GitHub pour signaler des problèmes.
* Comment cloner le référentiel principal et exécuter la suite de tests.
* Comment aider à résoudre les problèmes existants.
* Comment contribuer à la documentation de Ruby on Rails.
* Comment contribuer au code de Ruby on Rails.

Ruby on Rails n'est pas "le framework de quelqu'un d'autre". Au fil des années, des milliers de personnes ont contribué à Ruby on Rails, allant d'un simple caractère à des changements architecturaux massifs ou une documentation importante, le tout dans le but d'améliorer Ruby on Rails pour tous. Même si vous ne vous sentez pas encore prêt à écrire du code ou de la documentation, il existe différentes autres façons de contribuer, de signaler des problèmes à tester des correctifs.

Comme mentionné dans le [README de Rails](https://github.com/rails/rails/blob/main/README.md), toute personne interagissant avec les référentiels de code, les systèmes de suivi des problèmes, les salles de discussion, les forums de discussion et les listes de diffusion de Rails et de ses sous-projets est tenue de respecter le [code de conduite de Rails](https://rubyonrails.org/conduct).

--------------------------------------------------------------------------------

Signaler un problème
------------------

Ruby on Rails utilise [le suivi des problèmes de GitHub](https://github.com/rails/rails/issues) pour suivre les problèmes (principalement les bugs et les contributions de nouveau code). Si vous avez trouvé un bug dans Ruby on Rails, c'est l'endroit où commencer. Vous devrez créer un compte GitHub (gratuit) pour soumettre un problème, commenter des problèmes ou créer des demandes de tirage.

NOTE : Les bugs dans la version la plus récente de Ruby on Rails recevront probablement le plus d'attention. De plus, l'équipe principale de Rails est toujours intéressée par les commentaires de ceux qui peuvent prendre le temps de tester _edge Rails_ (le code de la version de Rails actuellement en développement). Plus loin dans ce guide, vous découvrirez comment obtenir edge Rails pour les tests. Consultez notre [politique de maintenance](maintenance_policy.html) pour obtenir des informations sur les versions prises en charge. Ne signalez jamais un problème de sécurité sur le suivi des problèmes de GitHub.

### Créer un rapport de bug

Si vous avez trouvé un problème dans Ruby on Rails qui ne présente pas de risque pour la sécurité, recherchez les [problèmes](https://github.com/rails/rails/issues) sur GitHub, au cas où il aurait déjà été signalé. Si vous ne trouvez aucun problème ouvert sur GitHub traitant du problème que vous avez trouvé, votre prochaine étape consistera à [ouvrir un nouveau problème](https://github.com/rails/rails/issues/new). (Consultez la section suivante pour signaler des problèmes de sécurité.)

Nous avons préparé un modèle de problème pour vous, afin que lorsque vous créez un problème, vous incluiez toutes les informations nécessaires pour déterminer s'il y a un bug dans le framework. Chaque problème doit inclure un titre et une description claire du problème. Assurez-vous d'inclure autant d'informations pertinentes que possible, y compris un exemple de code ou un test en échec qui démontre le comportement attendu, ainsi que votre configuration système. Votre objectif devrait être de faciliter la reproduction du bug et de trouver une solution, pour vous-même et pour les autres.

Une fois que vous avez ouvert un problème, il se peut qu'il ne soit pas immédiatement actif, sauf s'il s'agit d'un bug de type "Code Rouge, Critique, le Monde est en Train de S'Effondrer". Cela ne signifie pas que nous ne nous soucions pas de votre bug, simplement qu'il y a beaucoup de problèmes et de demandes de tirage à traiter. D'autres personnes confrontées au même problème peuvent trouver votre problème, le confirmer et collaborer avec vous pour le résoudre. Si vous savez comment résoudre le bug, n'hésitez pas à ouvrir une demande de tirage.

### Créer un cas de test exécutable

Avoir un moyen de reproduire votre problème aidera les gens à confirmer, enquêter et finalement résoudre votre problème. Vous pouvez le faire en fournissant un cas de test exécutable. Pour faciliter ce processus, nous avons préparé plusieurs modèles de rapport de bug que vous pouvez utiliser comme point de départ :

* Modèle pour les problèmes d'Active Record (modèles, base de données) : [gem](https://github.com/rails/rails/blob/main/guides/bug_report_templates/active_record_gem.rb) / [main](https://github.com/rails/rails/blob/main/guides/bug_report_templates/active_record_main.rb)
* Modèle pour les problèmes de test d'Active Record (migration) : [gem](https://github.com/rails/rails/blob/main/guides/bug_report_templates/active_record_migrations_gem.rb) / [main](https://github.com/rails/rails/blob/main/guides/bug_report_templates/active_record_migrations_main.rb)
* Modèle pour les problèmes d'Action Pack (contrôleurs, routage) : [gem](https://github.com/rails/rails/blob/main/guides/bug_report_templates/action_controller_gem.rb) / [main](https://github.com/rails/rails/blob/main/guides/bug_report_templates/action_controller_main.rb)
* Modèle pour les problèmes d'Active Job : [gem](https://github.com/rails/rails/blob/main/guides/bug_report_templates/active_job_gem.rb) / [main](https://github.com/rails/rails/blob/main/guides/bug_report_templates/active_job_main.rb)
* Modèle pour les problèmes d'Active Storage : [gem](https://github.com/rails/rails/blob/main/guides/bug_report_templates/active_storage_gem.rb) / [main](https://github.com/rails/rails/blob/main/guides/bug_report_templates/active_storage_main.rb)
* Modèle pour les problèmes d'Action Mailbox : [gem](https://github.com/rails/rails/blob/main/guides/bug_report_templates/action_mailbox_gem.rb) / [main](https://github.com/rails/rails/blob/main/guides/bug_report_templates/action_mailbox_main.rb)
* Modèle générique pour les autres problèmes : [gem](https://github.com/rails/rails/blob/main/guides/bug_report_templates/generic_gem.rb) / [main](https://github.com/rails/rails/blob/main/guides/bug_report_templates/generic_main.rb)

Ces modèles incluent le code de base pour configurer un cas de test contre une version publiée de Rails (`*_gem.rb`) ou edge Rails (`*_main.rb`).
Copiez le contenu du modèle approprié dans un fichier `.rb` et apportez les modifications nécessaires pour démontrer le problème. Vous pouvez l'exécuter en exécutant `ruby the_file.rb` dans votre terminal. Si tout se passe bien, vous devriez voir votre cas de test échouer.

Vous pouvez ensuite partager votre cas de test exécutable sous forme de [gist](https://gist.github.com) ou coller le contenu dans la description du problème.

### Traitement spécial des problèmes de sécurité

AVERTISSEMENT : Veuillez ne pas signaler les vulnérabilités de sécurité avec des rapports publics sur GitHub. La page de la politique de sécurité de Rails (https://rubyonrails.org/security) détaille la procédure à suivre pour les problèmes de sécurité.

### Et les demandes de fonctionnalités ?

Veuillez ne pas inclure les demandes de fonctionnalités dans les problèmes GitHub. Si vous souhaitez voir une nouvelle fonctionnalité ajoutée à Ruby on Rails, vous devrez écrire le code vous-même - ou convaincre quelqu'un d'autre de s'associer à vous pour écrire le code. Plus loin dans ce guide, vous trouverez des instructions détaillées pour proposer un correctif à Ruby on Rails. Si vous entrez un élément de liste de souhaits dans les problèmes GitHub sans code, vous pouvez vous attendre à ce qu'il soit marqué comme "non valide" dès qu'il sera examiné.

Parfois, la frontière entre 'bug' et 'fonctionnalité' est difficile à tracer. En général, une fonctionnalité est tout ce qui ajoute un nouveau comportement, tandis qu'un bug est tout ce qui provoque un comportement incorrect. Parfois, l'équipe Core devra prendre une décision. Cela dit, la distinction détermine généralement avec quelle version votre modification est publiée ; nous adorons les soumissions de fonctionnalités ! Elles ne seront simplement pas rétroportées sur les branches de maintenance.

Si vous souhaitez obtenir des commentaires sur une idée de fonctionnalité avant de faire le travail pour créer un correctif, veuillez démarrer une discussion sur le [forum de discussion rails-core](https://discuss.rubyonrails.org/c/rubyonrails-core). Vous pourriez ne pas obtenir de réponse, ce qui signifie que tout le monde est indifférent. Vous pourriez trouver quelqu'un d'intéressé par la construction de cette fonctionnalité. Vous pourriez obtenir un "Cela ne sera pas accepté". Mais c'est l'endroit approprié pour discuter de nouvelles idées. Les problèmes GitHub ne sont pas un lieu particulièrement propice aux discussions parfois longues et complexes que les nouvelles fonctionnalités nécessitent.


Aider à résoudre les problèmes existants
-----------------------------------------

Outre le signalement de problèmes, vous pouvez aider l'équipe principale à résoudre les problèmes existants en fournissant des commentaires à leur sujet. Si vous débutez dans le développement principal de Rails, fournir des commentaires vous aidera à vous familiariser avec le code source et les processus.

Si vous consultez la [liste des problèmes](https://github.com/rails/rails/issues) dans les problèmes GitHub, vous trouverez de nombreux problèmes nécessitant déjà une attention. Que pouvez-vous faire à ce sujet ? En fait, beaucoup de choses :

### Vérification des rapports de bugs

Pour commencer, il est utile de vérifier simplement les rapports de bugs. Pouvez-vous reproduire le problème signalé sur votre ordinateur ? Si c'est le cas, vous pouvez ajouter un commentaire au problème en disant que vous voyez la même chose.

Si un problème est très vague, pouvez-vous aider à le réduire à quelque chose de plus précis ? Peut-être pouvez-vous fournir des informations supplémentaires pour reproduire le bug, ou peut-être pouvez-vous éliminer des étapes inutiles qui ne sont pas nécessaires pour démontrer le problème.

Si vous trouvez un rapport de bug sans test, il est très utile de contribuer un test qui échoue. C'est aussi un excellent moyen d'explorer le code source : en regardant les fichiers de test existants, vous apprendrez comment écrire plus de tests. Les nouveaux tests sont mieux contribués sous forme de correctif, comme expliqué plus loin dans la section [Contribuer au code Rails](#contribuer-au-code-rails).

Tout ce que vous pouvez faire pour rendre les rapports de bugs plus concis ou plus faciles à reproduire aide les personnes qui essaient d'écrire du code pour corriger ces bugs - que vous finissiez par écrire le code vous-même ou non.

### Tester les correctifs

Vous pouvez également aider en examinant les demandes de tirage qui ont été soumises à Ruby on Rails via GitHub. Pour appliquer les modifications de quelqu'un, créez d'abord une branche dédiée :

```bash
$ git checkout -b testing_branch
```

Ensuite, vous pouvez utiliser leur branche distante pour mettre à jour votre base de code. Par exemple, disons que l'utilisateur GitHub JohnSmith a bifurqué et poussé vers une branche de sujet "orange" située à l'adresse https://github.com/JohnSmith/rails.

```bash
$ git remote add JohnSmith https://github.com/JohnSmith/rails.git
$ git pull JohnSmith orange
```

Une alternative à l'ajout de leur distant à votre checkout est d'utiliser l'outil [GitHub CLI](https://cli.github.com/) pour vérifier leur demande de tirage.

Après avoir appliqué leur branche, testez-la ! Voici quelques points à prendre en compte :
* Est-ce que le changement fonctionne réellement ?
* Êtes-vous satisfait des tests ? Pouvez-vous comprendre ce qu'ils testent ? Manque-t-il des tests ?
* Est-ce que cela est correctement documenté ? Est-ce que la documentation ailleurs doit être mise à jour ?
* Est-ce que vous aimez l'implémentation ? Pouvez-vous penser à une manière plus agréable ou plus rapide d'implémenter une partie de leur changement ?

Une fois que vous êtes satisfait que la demande de tirage contient un bon changement, commentez l'issue GitHub en indiquant vos conclusions. Votre commentaire devrait indiquer que vous aimez le changement et ce que vous aimez à ce sujet. Quelque chose comme :

>J'aime la façon dont vous avez restructuré ce code dans generate_finder_sql - beaucoup plus agréable. Les tests semblent bons aussi.

Si votre commentaire se contente de dire "+1", il est probable que les autres examinateurs ne le prendront pas trop au sérieux. Montrez que vous avez pris le temps de passer en revue la demande de tirage.

Contribuer à la documentation de Rails
--------------------------------------

Ruby on Rails dispose de deux ensembles principaux de documentation : les guides, qui vous aident à apprendre Ruby on Rails, et l'API, qui sert de référence.

Vous pouvez aider à améliorer les guides Rails ou la référence de l'API en les rendant plus cohérents, plus consistants ou plus lisibles, en ajoutant des informations manquantes, en corrigeant des erreurs factuelles, en corrigeant des fautes de frappe ou en les mettant à jour avec la dernière version de Rails.

Pour ce faire, apportez des modifications aux fichiers source des guides Rails (situés [ici](https://github.com/rails/rails/tree/main/guides/source) sur GitHub) ou aux commentaires RDoc dans le code source. Ensuite, ouvrez une demande de tirage pour appliquer vos modifications à la branche principale.

Lorsque vous travaillez avec la documentation, veuillez prendre en compte les [Directives de documentation de l'API](api_documentation_guidelines.html) et les [Directives des guides Ruby on Rails](ruby_on_rails_guides_guidelines.html).

Traduction des guides Rails
---------------------------

Nous sommes heureux d'avoir des volontaires pour traduire les guides Rails. Il vous suffit de suivre ces étapes :

* Fork https://github.com/rails/rails.
* Ajoutez un dossier source pour votre langue, par exemple : *guides/source/it-IT* pour l'italien.
* Copiez le contenu de *guides/source* dans votre répertoire de langue et traduisez-le.
* NE traduisez PAS les fichiers HTML, car ils sont générés automatiquement.

Notez que les traductions ne sont pas soumises au référentiel Rails ; votre travail se trouve dans votre fork, comme décrit ci-dessus. Cela s'explique par le fait que, en pratique, la maintenance de la documentation via des correctifs n'est viable qu'en anglais.

Pour générer les guides au format HTML, vous devrez installer les dépendances des guides, `cd` dans le répertoire *guides*, puis exécuter (par exemple, pour it-IT) :

```bash
# installer uniquement les gemmes nécessaires aux guides. Pour annuler, exécutez : bundle config --delete without
$ bundle install --without job cable storage ujs test db
$ cd guides/
$ bundle exec rake guides:generate:html GUIDES_LANGUAGE=it-IT
```

Cela générera les guides dans un répertoire *output*.

REMARQUE : La gemme Redcarpet ne fonctionne pas avec JRuby.

Efforts de traduction que nous connaissons (différentes versions) :

* **Italien** : [https://github.com/rixlabs/docrails](https://github.com/rixlabs/docrails)
* **Espagnol** : [https://github.com/latinadeveloper/railsguides.es](https://github.com/latinadeveloper/railsguides.es)
* **Polonais** : [https://github.com/apohllo/docrails](https://github.com/apohllo/docrails)
* **Français** : [https://github.com/railsfrance/docrails](https://github.com/railsfrance/docrails)
* **Tchèque** : [https://github.com/rubyonrails-cz/docrails/tree/czech](https://github.com/rubyonrails-cz/docrails/tree/czech)
* **Turc** : [https://github.com/ujk/docrails](https://github.com/ujk/docrails)
* **Coréen** : [https://github.com/rorlakr/rails-guides](https://github.com/rorlakr/rails-guides)
* **Chinois simplifié** : [https://github.com/ruby-china/guides](https://github.com/ruby-china/guides)
* **Chinois traditionnel** : [https://github.com/docrails-tw/guides](https://github.com/docrails-tw/guides)
* **Russe** : [https://github.com/morsbox/rusrails](https://github.com/morsbox/rusrails)
* **Japonais** : [https://github.com/yasslab/railsguides.jp](https://github.com/yasslab/railsguides.jp)
* **Portugais brésilien** : [https://github.com/campuscode/rails-guides-pt-BR](https://github.com/campuscode/rails-guides-pt-BR)

Contribuer au code de Rails
---------------------------

### Configuration d'un environnement de développement

Pour passer de la soumission de bugs à l'aide à la résolution de problèmes existants ou à la contribution de votre propre code à Ruby on Rails, vous devez être en mesure d'exécuter sa suite de tests. Dans cette section du guide, vous apprendrez comment configurer les tests sur votre ordinateur.

#### Utilisation de GitHub Codespaces

Si vous êtes membre d'une organisation qui a activé les codespaces, vous pouvez forker Rails dans cette organisation et utiliser les codespaces sur GitHub. Le codespace sera initialisé avec toutes les dépendances requises et vous permettra d'exécuter tous les tests.

#### Utilisation de VS Code Remote Containers

Si vous avez [Visual Studio Code](https://code.visualstudio.com) et [Docker](https://www.docker.com) installés, vous pouvez utiliser le plugin [VS Code remote containers](https://code.visualstudio.com/docs/remote/containers-tutorial). Le plugin lira la configuration [`.devcontainer`](https://github.com/rails/rails/tree/main/.devcontainer) dans le référentiel et construira le conteneur Docker localement.

#### Utilisation de Dev Container CLI

Alternativement, avec [Docker](https://www.docker.com) et [npm](https://github.com/npm/cli) installés, vous pouvez exécuter [Dev Container CLI](https://github.com/devcontainers/cli) pour utiliser la configuration [`.devcontainer`](https://github.com/rails/rails/tree/main/.devcontainer) depuis la ligne de commande.

```bash
$ npm install -g @devcontainers/cli
$ cd rails
$ devcontainer up --workspace-folder .
$ devcontainer exec --workspace-folder . bash
```

#### Utilisation de rails-dev-box

Il est également possible d'utiliser le [rails-dev-box](https://github.com/rails/rails-dev-box) pour obtenir un environnement de développement prêt. Cependant, le rails-dev-box utilise Vagrant et Virtual Box, ce qui ne fonctionnera pas sur les Mac avec Apple silicon.
#### Développement local

Lorsque vous ne pouvez pas utiliser GitHub Codespaces, consultez [ce guide](development_dependencies_install.html) pour savoir comment configurer le développement local. C'est considéré comme la méthode difficile car l'installation des dépendances peut dépendre du système d'exploitation.

### Cloner le référentiel Rails

Pour pouvoir contribuer du code, vous devez cloner le référentiel Rails :

```bash
$ git clone https://github.com/rails/rails.git
```

et créer une branche dédiée :

```bash
$ cd rails
$ git checkout -b ma_nouvelle_branche
```

Peu importe le nom que vous utilisez car cette branche n'existera que sur votre ordinateur local et votre référentiel personnel sur GitHub. Elle ne fera pas partie du référentiel Git de Rails.

### Installation des dépendances

Installez les gemmes requises.

```bash
$ bundle install
```

### Exécution d'une application avec votre branche locale

Si vous avez besoin d'une application Rails fictive pour tester des modifications, le drapeau `--dev` de `rails new` génère une application qui utilise votre branche locale :

```bash
$ cd rails
$ bundle exec rails new ~/my-test-app --dev
```

L'application générée dans `~/my-test-app` s'exécute avec votre branche locale et, en particulier, voit toutes les modifications après le redémarrage du serveur.

Pour les packages JavaScript, vous pouvez utiliser [`yarn link`](https://yarnpkg.com/cli/link) pour utiliser votre branche locale dans une application générée :

```bash
$ cd rails/activestorage
$ yarn link
$ cd ~/my-test-app
$ yarn link "@rails/activestorage"
```

### Écrire votre code

Maintenant, il est temps d'écrire du code ! Lorsque vous apportez des modifications à Rails, voici quelques points à garder à l'esprit :

* Suivez le style et les conventions de Rails.
* Utilisez les idiomes et les helpers de Rails.
* Incluez des tests qui échouent sans votre code et réussissent avec celui-ci.
* Mettez à jour la documentation (environnante), les exemples ailleurs et les guides : tout ce qui est affecté par votre contribution.
* Si la modification ajoute, supprime ou modifie une fonctionnalité, assurez-vous d'inclure une entrée dans le fichier CHANGELOG. Si votre modification est une correction de bogue, une entrée dans le fichier CHANGELOG n'est pas nécessaire.

CONSEIL : Les modifications qui sont purement cosmétiques et n'apportent rien de substantiel à la stabilité, à la fonctionnalité ou à la testabilité de Rails ne seront généralement pas acceptées (en savoir plus sur [notre raisonnement derrière cette décision](https://github.com/rails/rails/pull/13771#issuecomment-32746700)).

#### Suivre les conventions de codage

Rails suit un ensemble simple de conventions de style de codage :

* Deux espaces, pas de tabulations (pour l'indentation).
* Pas d'espace en fin de ligne. Les lignes vides ne doivent pas contenir d'espaces.
* Indentation et pas de ligne vide après private/protected.
* Utilisez la syntaxe Ruby >= 1.9 pour les hashes. Préférez `{ a: :b }` à `{ :a => :b }`.
* Préférez `&&`/`||` à `and`/`or`.
* Préférez `class << self` à `self.method` pour les méthodes de classe.
* Utilisez `my_method(my_arg)` et non `my_method( my_arg )` ou `my_method my_arg`.
* Utilisez `a = b` et non `a=b`.
* Utilisez les méthodes `assert_not` au lieu de `refute`.
* Préférez `method { do_stuff }` à `method{do_stuff}` pour les blocs d'une seule ligne.
* Suivez les conventions dans le code source que vous voyez déjà utilisées.

Ce qui précède sont des lignes directrices - veuillez utiliser votre meilleur jugement pour les appliquer.

De plus, nous avons des règles [RuboCop](https://www.rubocop.org/) définies pour codifier certaines de nos conventions de codage. Vous pouvez exécuter RuboCop localement sur le fichier que vous avez modifié avant de soumettre une pull request :

```bash
$ bundle exec rubocop actionpack/lib/action_controller/metal/strong_parameters.rb
Inspection du fichier 1
.

1 fichier inspecté, aucune infraction détectée
```

Pour les fichiers CoffeeScript et JavaScript de `rails-ujs`, vous pouvez exécuter `npm run lint` dans le dossier `actionview`.

#### Vérification de l'orthographe

Nous utilisons [misspell](https://github.com/client9/misspell) qui est principalement écrit en [Golang](https://golang.org/) pour vérifier l'orthographe avec [GitHub Actions](https://github.com/rails/rails/blob/main/.github/workflows/lint.yml). Corrigez rapidement les mots anglais couramment mal orthographiés avec `misspell`. `misspell` est différent de la plupart des autres correcteurs orthographiques car il n'utilise pas de dictionnaire personnalisé. Vous pouvez exécuter `misspell` localement sur tous les fichiers avec :

```bash
$ find . -type f | xargs ./misspell -i 'aircrafts,devels,invertions' -error
```

Les options ou drapeaux importants de `misspell` sont :

- `-i` chaîne : ignorer les corrections suivantes, séparées par des virgules
- `-w` : Écraser le fichier avec les corrections (par défaut, seule l'affichage est effectué)

Nous exécutons également [codespell](https://github.com/codespell-project/codespell) avec GitHub Actions pour vérifier l'orthographe et [codespell](https://pypi.org/project/codespell/) s'exécute avec un [petit dictionnaire personnalisé](https://github.com/rails/rails/blob/main/codespell.txt). `codespell` est écrit en [Python](https://www.python.org/) et vous pouvez l'exécuter avec :

```bash
$ codespell --ignore-words=codespell.txt
```

### Évaluez les performances de votre code

Pour les modifications qui pourraient avoir un impact sur les performances, veuillez évaluer les performances de votre code et mesurer l'impact. Veuillez partager le script de benchmark que vous avez utilisé ainsi que les résultats. Vous devriez envisager d'inclure ces informations dans votre message de commit, afin de permettre aux futurs contributeurs de vérifier facilement vos résultats et de déterminer s'ils sont toujours pertinents. (Par exemple, des optimisations futures dans la machine virtuelle Ruby pourraient rendre certaines optimisations inutiles.)
Lors de l'optimisation pour un scénario spécifique qui vous intéresse, il est facile de régresser les performances pour d'autres cas courants.
Par conséquent, vous devez tester votre modification par rapport à une liste de scénarios représentatifs, idéalement extraits d'applications de production réelles.

Vous pouvez utiliser le [modèle de benchmark](https://github.com/rails/rails/blob/main/guides/bug_report_templates/benchmark.rb) comme point de départ. Il inclut le code de base pour configurer un benchmark en utilisant la gem [benchmark-ips](https://github.com/evanphx/benchmark-ips). Le modèle est conçu pour tester des modifications relativement autonomes qui peuvent être intégrées dans le script.

### Exécution des tests

Il n'est pas habituel dans Rails d'exécuter l'ensemble de la suite de tests avant de pousser les modifications. La suite de tests de railties, en particulier, prend beaucoup de temps, et prendra d'autant plus de temps si le code source est monté dans `/vagrant` comme cela se produit dans le flux de travail recommandé avec le [rails-dev-box](https://github.com/rails/rails-dev-box).

En compromis, testez ce que votre code affecte évidemment, et si le changement n'est pas dans railties, exécutez l'ensemble de la suite de tests du composant affecté. Si tous les tests réussissent, cela suffit pour proposer votre contribution. Nous avons [Buildkite](https://buildkite.com/rails/rails) comme filet de sécurité pour détecter les pannes inattendues ailleurs.

#### Rails entier :

Pour exécuter tous les tests, faites :

```bash
$ cd rails
$ bundle exec rake test
```

#### Pour un composant particulier

Vous pouvez exécuter des tests uniquement pour un composant particulier (par exemple, Action Pack). Par exemple, pour exécuter les tests d'Action Mailer :

```bash
$ cd actionmailer
$ bin/test
```

#### Pour un répertoire spécifique

Vous pouvez exécuter des tests uniquement pour un répertoire spécifique d'un composant particulier (par exemple, les modèles dans Active Storage). Par exemple, pour exécuter les tests dans `/activestorage/test/models` :

```bash
$ cd activestorage
$ bin/test models
```

#### Pour un fichier spécifique

Vous pouvez exécuter les tests pour un fichier spécifique :

```bash
$ cd actionview
$ bin/test test/template/form_helper_test.rb
```

#### Exécution d'un seul test

Vous pouvez exécuter un seul test par nom en utilisant l'option `-n` :

```bash
$ cd actionmailer
$ bin/test test/mail_layout_test.rb -n test_explicit_class_layout
```

#### Pour une ligne spécifique

Trouver le nom n'est pas toujours facile, mais si vous connaissez le numéro de ligne à partir duquel votre test commence, cette option est pour vous :

```bash
$ cd railties
$ bin/test test/application/asset_debugging_test.rb:69
```

#### Exécution des tests avec une graine spécifique

L'exécution des tests est aléatoire avec une graine de randomisation. Si vous rencontrez des échecs de tests aléatoires, vous pouvez reproduire plus précisément un scénario de test en échec en définissant spécifiquement la graine de randomisation.

Exécution de tous les tests pour un composant :

```bash
$ cd actionmailer
$ SEED=15002 bin/test
```

Exécution d'un seul fichier de test :

```bash
$ cd actionmailer
$ SEED=15002 bin/test test/mail_layout_test.rb
```

#### Exécution des tests en série

Les tests unitaires d'Action Pack et d'Action View s'exécutent en parallèle par défaut. Si vous rencontrez des échecs de tests aléatoires, vous pouvez définir la graine de randomisation et laisser ces tests unitaires s'exécuter en série en définissant `PARALLEL_WORKERS=1`

```bash
$ cd actionview
$ PARALLEL_WORKERS=1 SEED=53708 bin/test test/template/test_case_test.rb
```

#### Test d'Active Record

Tout d'abord, créez les bases de données dont vous aurez besoin. Vous pouvez trouver une liste des noms de table, des noms d'utilisateur et des mots de passe requis dans `activerecord/test/config.example.yml`.

Pour MySQL et PostgreSQL, il suffit d'exécuter :

```bash
$ cd activerecord
$ bundle exec rake db:mysql:build
```

Ou :

```bash
$ cd activerecord
$ bundle exec rake db:postgresql:build
```

Cela n'est pas nécessaire pour SQLite3.

Voici comment exécuter la suite de tests Active Record uniquement pour SQLite3 :

```bash
$ cd activerecord
$ bundle exec rake test:sqlite3
```

Vous pouvez maintenant exécuter les tests comme vous l'avez fait pour `sqlite3`. Les tâches sont respectivement :

```bash
$ bundle exec rake test:mysql2
$ bundle exec rake test:trilogy
$ bundle exec rake test:postgresql
```

Enfin,

```bash
$ bundle exec rake test
```

les exécutera maintenant tous les trois à la suite.

Vous pouvez également exécuter chaque test individuellement :

```bash
$ ARCONN=mysql2 bundle exec ruby -Itest test/cases/associations/has_many_associations_test.rb
```

Pour exécuter un seul test avec tous les adaptateurs, utilisez :

```bash
$ bundle exec rake TEST=test/cases/associations/has_many_associations_test.rb
```

Vous pouvez également utiliser `test_jdbcmysql`, `test_jdbcsqlite3` ou `test_jdbcpostgresql`. Consultez le fichier `activerecord/RUNNING_UNIT_TESTS.rdoc` pour obtenir des informations sur l'exécution de tests de base de données plus ciblés.

#### Utilisation de débogueurs avec les tests

Pour utiliser un débogueur externe (pry, byebug, etc), installez le débogueur et utilisez-le normalement. Si des problèmes de débogueur se produisent, exécutez les tests en série en définissant `PARALLEL_WORKERS=1` ou exécutez un seul test avec `-n test_long_test_name`.

### Avertissements

La suite de tests s'exécute avec les avertissements activés. Idéalement, Ruby on Rails ne devrait émettre aucun avertissement, mais il peut y en avoir quelques-uns, ainsi que certains provenant de bibliothèques tierces. Veuillez les ignorer (ou les corriger !), le cas échéant, et soumettre des correctifs qui n'émettent pas de nouveaux avertissements.
Rails CI lèvera une exception si des avertissements sont introduits. Pour implémenter le même comportement localement, définissez `RAILS_STRICT_WARNINGS=1` lors de l'exécution de la suite de tests.

### Mise à jour de la documentation

Les [guides](https://guides.rubyonrails.org/) Ruby on Rails fournissent une vue d'ensemble des fonctionnalités de Rails, tandis que la [documentation de l'API](https://api.rubyonrails.org/) se penche sur les détails spécifiques.

Si votre PR ajoute une nouvelle fonctionnalité ou modifie le comportement d'une fonctionnalité existante, vérifiez la documentation pertinente et mettez-la à jour ou ajoutez-y des informations si nécessaire.

Par exemple, si vous modifiez l'analyseur d'images d'Active Storage pour ajouter un nouveau champ de métadonnées, vous devez mettre à jour la section [Analyzing Files](active_storage_overview.html#analyzing-files) du guide Active Storage pour refléter cela.

### Mise à jour du CHANGELOG

Le CHANGELOG est une partie importante de chaque version. Il contient la liste des modifications pour chaque version de Rails.

Vous devez ajouter une entrée **en haut** du CHANGELOG du framework que vous avez modifié si vous ajoutez ou supprimez une fonctionnalité, ou si vous ajoutez des avis de dépréciation. Les refactorisations, les corrections de bugs mineurs et les modifications de documentation ne doivent généralement pas figurer dans le CHANGELOG.

Une entrée dans le CHANGELOG doit résumer ce qui a été modifié et doit se terminer par le nom de l'auteur. Vous pouvez utiliser plusieurs lignes si vous avez besoin de plus d'espace, et vous pouvez ajouter des exemples de code indentés avec 4 espaces. Si une modification est liée à un problème spécifique, vous devez ajouter le numéro du problème. Voici un exemple d'entrée dans le CHANGELOG :

```
*   Résumé d'une modification qui décrit brièvement ce qui a été modifié. Vous pouvez utiliser plusieurs
    lignes et les envelopper autour de 80 caractères. Les exemples de code sont également acceptés, si nécessaire :

        class Foo
          def bar
            puts 'baz'
          end
        end

    Vous pouvez continuer après l'exemple de code, et vous pouvez ajouter le numéro du problème.

    Résout #1234.

    *Votre Nom*
```

Votre nom peut être ajouté directement après le dernier mot s'il n'y a pas d'exemples de code ou de paragraphes multiples. Sinon, il est préférable de faire un nouveau paragraphe.

### Modifications majeures

Toute modification susceptible de casser les applications existantes est considérée comme une modification majeure. Pour faciliter la mise à niveau des applications Rails, les modifications majeures nécessitent un cycle de dépréciation.

#### Suppression de comportement

Si votre modification majeure supprime un comportement existant, vous devez d'abord ajouter un avertissement de dépréciation tout en conservant le comportement existant.

Par exemple, supposons que vous souhaitiez supprimer une méthode publique de `ActiveRecord::Base`. Si la branche principale pointe vers la version non publiée 7.0, Rails 7.0 devra afficher un avertissement de dépréciation. Cela garantit que toute mise à niveau vers n'importe quelle version de Rails 7.0 affichera l'avertissement de dépréciation. Dans Rails 7.1, la méthode peut être supprimée.

Vous pouvez ajouter l'avertissement de dépréciation suivant :

```ruby
def deprecated_method
  ActiveRecord.deprecator.warn(<<-MSG.squish)
    `ActiveRecord::Base.deprecated_method` est dépréciée et sera supprimée dans Rails 7.1.
  MSG
  # Comportement existant
end
```

#### Modification de comportement

Si votre modification majeure modifie un comportement existant, vous devrez ajouter une valeur par défaut du framework. Les valeurs par défaut du framework facilitent les mises à niveau de Rails en permettant aux applications de passer progressivement aux nouvelles valeurs par défaut.

Pour mettre en œuvre une nouvelle valeur par défaut du framework, créez d'abord une configuration en ajoutant un accesseur sur le framework cible. Définissez la valeur par défaut sur le comportement existant pour vous assurer que rien ne se casse lors d'une mise à niveau.

```ruby
module ActiveJob
  mattr_accessor :existing_behavior, default: true
end
```

La nouvelle configuration vous permet d'implémenter conditionnellement le nouveau comportement :

```ruby
def changed_method
  if ActiveJob.existing_behavior
    # Comportement existant
  else
    # Nouveau comportement
  end
end
```

Pour définir la nouvelle valeur par défaut du framework, définissez la nouvelle valeur dans `Rails::Application::Configuration#load_defaults` :

```ruby
def load_defaults(target_version)
  case target_version.to_s
  when "7.1"
    ...
    if respond_to?(:active_job)
      active_job.existing_behavior = false
    end
    ...
  end
end
```

Pour faciliter la mise à niveau, il est nécessaire d'ajouter la nouvelle valeur par défaut au modèle `new_framework_defaults`. Ajoutez une section mise en commentaire, définissant la nouvelle valeur :

```ruby
# new_framework_defaults_7_1.rb.tt

# Rails.application.config.active_job.existing_behavior = false
```

Enfin, ajoutez la nouvelle configuration au guide de configuration dans `configuration.md` :

```markdown
#### `config.active_job.existing_behavior`

| À partir de la version | La valeur par défaut est |
| --------------------- | ----------------------- |
| (originale)           | `true`                  |
| 7.1                   | `false`                 |
```

### Ignorer les fichiers créés par votre éditeur / IDE

Certains éditeurs et IDE créent des fichiers ou des dossiers cachés à l'intérieur du dossier `rails`. Au lieu de les exclure manuellement de chaque commit ou de les ajouter à `.gitignore` de Rails, vous devriez les ajouter à votre propre [fichier global d'ignorance de git](https://docs.github.com/en/get-started/getting-started-with-git/ignoring-files#configuring-ignored-files-for-all-repositories-on-your-computer).

### Mise à jour de Gemfile.lock

Certaines modifications nécessitent des mises à jour des dépendances. Dans ces cas, assurez-vous d'exécuter `bundle update` pour obtenir la version correcte de la dépendance et de commiter le fichier `Gemfile.lock` avec vos modifications.
### Valider vos modifications

Lorsque vous êtes satisfait du code sur votre ordinateur, vous devez valider les modifications sur Git :

```bash
$ git commit -a
```

Cela ouvrira votre éditeur pour écrire un message de validation. Lorsque vous avez terminé, enregistrez et fermez pour continuer.

Un message de validation bien formaté et descriptif sont très utiles pour les autres afin de comprendre pourquoi le changement a été effectué, donc prenez le temps de l'écrire.

Un bon message de validation ressemble à ceci :

```
Résumé court (idéalement moins de 50 caractères)

Description plus détaillée, si nécessaire. Chaque ligne doit être coupée à
72 caractères. Essayez d'être aussi descriptif que possible. Même si vous
pensez que le contenu de la validation est évident, il peut ne pas l'être
pour les autres. Ajoutez toute description déjà présente dans les
problèmes pertinents ; il ne devrait pas être nécessaire de visiter une page
web pour vérifier l'historique.

La section de description peut contenir plusieurs paragraphes.

Des exemples de code peuvent être intégrés en les indentant avec 4 espaces :

    class ArticlesController
      def index
        render json: Article.limit(10)
      end
    end

Vous pouvez également ajouter des points de puce :

- créez un point de puce en commençant une ligne par un tiret (-)
  ou un astérisque (*)

- coupez les lignes à 72 caractères et indentez les lignes supplémentaires
  avec 2 espaces pour plus de lisibilité
```

CONSEIL. Veuillez fusionner vos validations en une seule validation lorsque cela est approprié. Cela simplifie les futurs choix de cerises et maintient le journal Git propre.

### Mettre à jour votre branche

Il est fort probable que d'autres modifications aient été apportées à main pendant que vous travailliez. Pour obtenir les nouvelles modifications de main :

```bash
$ git checkout main
$ git pull --rebase
```

Appliquez maintenant votre correctif sur les dernières modifications :

```bash
$ git checkout my_new_branch
$ git rebase main
```

Pas de conflits ? Les tests passent toujours ? Le changement vous semble toujours raisonnable ? Ensuite, poussez les modifications réappliquées sur GitHub :

```bash
$ git push --force-with-lease
```

Nous interdisons la poussée forcée sur la base du référentiel rails/rails, mais vous pouvez effectuer une poussée forcée vers votre fork. Lors de la réapplication, c'est une exigence car l'historique a changé.

### Fork

Accédez au référentiel Rails [GitHub](https://github.com/rails/rails) et cliquez sur "Fork" dans le coin supérieur droit.

Ajoutez le nouveau dépôt à votre référentiel local sur votre machine locale :

```bash
$ git remote add fork https://github.com/<votre nom d'utilisateur>/rails.git
```

Vous avez peut-être cloné votre référentiel local à partir de rails/rails, ou vous avez peut-être cloné à partir de votre référentiel fork. Les commandes git suivantes supposent que vous avez créé un "rails" distant qui pointe vers rails/rails.

```bash
$ git remote add rails https://github.com/rails/rails.git
```

Téléchargez les nouveaux validations et branches du référentiel officiel :

```bash
$ git fetch rails
```

Fusionnez le nouveau contenu :

```bash
$ git checkout main
$ git rebase rails/main
$ git checkout my_new_branch
$ git rebase rails/main
```

Mettez à jour votre fork :

```bash
$ git push fork main
$ git push fork my_new_branch
```

### Ouvrir une demande de pull

Accédez au référentiel Rails que vous venez de pousser (par exemple,
https://github.com/votre-nom-utilisateur/rails) et cliquez sur "Pull Requests" dans la barre supérieure (juste au-dessus du code).
Sur la page suivante, cliquez sur "New pull request" dans le coin supérieur droit.

La demande de pull doit cibler le référentiel de base `rails/rails` et la branche `main`.
Le référentiel source sera votre travail (`votre-nom-utilisateur/rails`), et la branche sera
le nom que vous avez donné à votre branche. Cliquez sur "create pull request" lorsque vous êtes prêt.

Assurez-vous que les ensembles de modifications que vous avez introduits sont inclus. Remplissez quelques détails sur
votre correctif potentiel, en utilisant le modèle de demande de pull fourni. Lorsque vous avez terminé, cliquez sur "Create
pull request".

### Obtenir des commentaires

La plupart des demandes de pull passeront par quelques itérations avant d'être fusionnées.
Différents contributeurs auront parfois des opinions différentes, et souvent
les correctifs devront être révisés avant de pouvoir être fusionnés.

Certains contributeurs à Rails ont activé les notifications par e-mail de GitHub, mais
d'autres ne l'ont pas fait. De plus, (presque) tous ceux qui travaillent sur Rails sont des
bénévoles, il peut donc s'écouler quelques jours avant que vous obteniez vos premiers commentaires sur
une demande de pull. Ne désespérez pas ! Parfois, c'est rapide ; parfois, c'est lent. Telle
est la vie de l'open source.

Si cela fait plus d'une semaine et que vous n'avez rien entendu, vous voudrez peut-être essayer
de faire avancer les choses. Vous pouvez utiliser le [forum de discussion rubyonrails-core](https://discuss.rubyonrails.org/c/rubyonrails-core) pour cela. Vous pouvez également
laisser un autre commentaire sur la demande de pull.
Pendant que vous attendez des commentaires sur votre demande de tirage, ouvrez quelques autres demandes de tirage et donnez-en à quelqu'un d'autre ! Ils l'apprécieront de la même manière que vous appréciez les commentaires sur vos correctifs.

Notez que seules les équipes Core et Committers sont autorisées à fusionner les modifications de code. Si quelqu'un donne des commentaires et "approuve" vos modifications, il se peut qu'il n'ait pas la capacité ou le dernier mot pour fusionner votre modification.

### Itérer si nécessaire

Il est tout à fait possible que les commentaires que vous recevez suggèrent des modifications. Ne vous découragez pas : le but de contribuer à un projet open source actif est de puiser dans les connaissances de la communauté. Si les gens vous encouragent à ajuster votre code, cela vaut la peine de faire les ajustements et de le soumettre à nouveau. Si les commentaires indiquent que votre code ne sera pas fusionné, vous pourriez quand même envisager de le publier en tant que gemme.

#### Fusionner les commits

L'une des choses que nous pouvons vous demander de faire est de "fusionner vos commits", ce qui regroupera tous vos commits en un seul. Nous préférons les demandes de tirage qui ne contiennent qu'un seul commit. Cela facilite la rétroportabilité des modifications vers les branches stables, la fusion des commits indésirables est plus facile et l'historique git peut être un peu plus facile à suivre. Rails est un projet volumineux et un tas de commits superflus peuvent ajouter beaucoup de bruit.

```bash
$ git fetch rails
$ git checkout ma_nouvelle_branche
$ git rebase -i rails/main

< Choisissez 'squash' pour tous vos commits sauf le premier. >
< Modifiez le message du commit pour qu'il ait du sens et décrivez toutes vos modifications. >

$ git push fork ma_nouvelle_branche --force-with-lease
```

Vous devriez pouvoir actualiser la demande de tirage sur GitHub et constater qu'elle a été mise à jour.

#### Mettre à jour une demande de tirage

Il peut arriver que l'on vous demande d'apporter des modifications au code que vous avez déjà validé. Cela peut inclure la modification de commits existants. Dans ce cas, Git ne vous permettra pas de pousser les modifications car la branche poussée et la branche locale ne correspondent pas. Au lieu d'ouvrir une nouvelle demande de tirage, vous pouvez forcer la poussée vers votre branche sur GitHub comme décrit précédemment dans la section sur la fusion des commits :

```bash
$ git commit --amend
$ git push fork ma_nouvelle_branche --force-with-lease
```

Cela mettra à jour la branche et la demande de tirage sur GitHub avec votre nouveau code. En utilisant `--force-with-lease` lors de la poussée forcée, git mettra à jour le dépôt distant de manière plus sûre qu'avec un `-f` classique, qui peut supprimer du travail du dépôt distant que vous n'avez pas déjà.

### Anciennes versions de Ruby on Rails

Si vous souhaitez apporter une correction aux versions de Ruby on Rails antérieures à la prochaine version, vous devrez configurer et basculer vers votre propre branche de suivi locale. Voici un exemple pour basculer vers la branche 7-0-stable :

```bash
$ git branch --track 7-0-stable rails/7-0-stable
$ git checkout 7-0-stable
```

REMARQUE : Avant de travailler sur des versions plus anciennes, veuillez consulter la [politique de maintenance](maintenance_policy.html). Les modifications ne seront pas acceptées pour les versions qui ont atteint la fin de leur vie.

#### Rétroporter

Les modifications fusionnées dans main sont destinées à la prochaine version majeure de Rails. Parfois, il peut être bénéfique de propager vos modifications vers les branches stables pour les inclure dans les versions de maintenance. En général, les correctifs de sécurité et les corrections de bugs sont de bons candidats pour une rétroportabilité, tandis que les nouvelles fonctionnalités et les correctifs qui modifient le comportement attendu ne seront pas acceptés. En cas de doute, il est préférable de consulter un membre de l'équipe Rails avant de rétroporter vos modifications afin d'éviter des efforts inutiles.

Tout d'abord, assurez-vous que votre branche principale est à jour.

```bash
$ git checkout main
$ git pull --rebase
```

Vérifiez la branche vers laquelle vous rétroportez, par exemple, `7-0-stable`, et assurez-vous qu'elle est à jour :

```bash
$ git checkout 7-0-stable
$ git reset --hard origin/7-0-stable
$ git checkout -b ma-branche-de-retroportage
```

Si vous rétroportez une demande de tirage fusionnée, trouvez le commit de fusion et effectuez un cherry-pick :

```bash
$ git cherry-pick -m1 MERGE_SHA
```

Résolvez les conflits éventuels sur le cherry-pick, poussez vos modifications, puis ouvrez une demande de tirage pointant vers la branche stable vers laquelle vous rétroportez. Si vous avez un ensemble de modifications plus complexe, la documentation sur [cherry-pick](https://git-scm.com/docs/git-cherry-pick) peut vous aider.

Contributeurs de Rails
------------------

Toutes les contributions sont créditées dans [Rails Contributors](https://contributors.rubyonrails.org).
