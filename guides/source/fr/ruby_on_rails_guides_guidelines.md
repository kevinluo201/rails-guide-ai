**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 9f9c36972ad6f0627da4da84b0067618
Directives de Ruby on Rails Guides
===============================

Ce guide documente les directives pour rédiger des guides Ruby on Rails. Ce guide suit lui-même une boucle élégante, en se servant comme exemple.

Après avoir lu ce guide, vous saurez :

* Les conventions à utiliser dans la documentation Rails.
* Comment générer des guides localement.

--------------------------------------------------------------------------------

Markdown
-------

Les guides sont rédigés en [Markdown compatible avec GitHub](https://help.github.com/articles/github-flavored-markdown). Il existe une [documentation complète pour Markdown](https://daringfireball.net/projects/markdown/syntax), ainsi qu'une [feuille de triche](https://daringfireball.net/projects/markdown/basics).

Prologue
--------

Chaque guide devrait commencer par un texte de motivation en haut (c'est l'introduction dans la zone bleue). Le prologue devrait indiquer au lecteur de quoi parle le guide et ce qu'il apprendra. Par exemple, consultez le [Guide de routage](routing.html).

Titres
------

Le titre de chaque guide utilise un titre `h1`; les sections du guide utilisent des titres `h2`; les sous-sections utilisent des titres `h3`; etc. Notez que le code HTML généré utilisera des balises de titre commençant par `<h2>`.

```markdown
Titre du guide
==============

Section
-------

### Sous-section
```

Lors de la rédaction des titres, mettez en majuscule tous les mots, sauf les prépositions, les conjonctions, les articles internes et les formes du verbe "être" :

```markdown
#### Assertions et tests d'emplois à l'intérieur des composants
#### La pile de middleware est un tableau
#### Quand les objets sont-ils enregistrés ?
```

Utilisez le même formatage en ligne que pour le texte normal :

```markdown
##### L'option `:content_type`
```

Lien vers l'API
------------------

Les liens vers l'API (`api.rubyonrails.org`) sont traités par le générateur de guides de la manière suivante :

Les liens qui incluent une balise de version sont laissés intacts. Par exemple :

```
https://api.rubyonrails.org/v5.0.1/classes/ActiveRecord/Attributes/ClassMethods.html
```

n'est pas modifié.

Veuillez utiliser ces liens dans les notes de version, car ils doivent pointer vers la version correspondante, quelle que soit la cible générée.

Si le lien n'inclut pas de balise de version et que les guides de développement sont générés, le domaine est remplacé par `edgeapi.rubyonrails.org`. Par exemple :

```
https://api.rubyonrails.org/classes/ActionDispatch/Response.html
```

devient

```
https://edgeapi.rubyonrails.org/classes/ActionDispatch/Response.html
```

Si le lien n'inclut pas de balise de version et que les guides de version sont générés, la version de Rails est injectée. Par exemple, si nous générons les guides pour v5.1.0, le lien

```
https://api.rubyonrails.org/classes/ActionDispatch/Response.html
```

devient

```
https://api.rubyonrails.org/v5.1.0/classes/ActionDispatch/Response.html
```

Veuillez ne pas créer de lien vers `edgeapi.rubyonrails.org` manuellement.


Directives de documentation de l'API
----------------------------

Les guides et l'API doivent être cohérents et cohérents lorsque cela est approprié. En particulier, ces sections des [Directives de documentation de l'API](api_documentation_guidelines.html) s'appliquent également aux guides :

* [Formulation](api_documentation_guidelines.html#wording)
* [Anglais](api_documentation_guidelines.html#english)
* [Code d'exemple](api_documentation_guidelines.html#example-code)
* [Noms de fichiers](api_documentation_guidelines.html#file-names)
* [Polices](api_documentation_guidelines.html#fonts)

Guides HTML
-----------

Avant de générer les guides, assurez-vous d'avoir la dernière version de Bundler installée sur votre système. Pour installer la dernière version de Bundler, exécutez `gem install bundler`.

Si vous avez déjà Bundler installé, vous pouvez le mettre à jour avec `gem update bundler`.

### Génération

Pour générer tous les guides, accédez simplement au répertoire `guides`, exécutez `bundle install` et exécutez :

```bash
$ bundle exec rake guides:generate
```

ou

```bash
$ bundle exec rake guides:generate:html
```

Les fichiers HTML résultants se trouvent dans le répertoire `./output`.

Pour traiter uniquement `my_guide.md` et rien d'autre, utilisez la variable d'environnement `ONLY` :

```bash
$ touch my_guide.md
$ bundle exec rake guides:generate ONLY=my_guide
```

Par défaut, les guides qui n'ont pas été modifiés ne sont pas traités, donc `ONLY` est rarement nécessaire en pratique.

Pour forcer le traitement de tous les guides, passez `ALL=1`.

Si vous souhaitez générer des guides dans une autre langue que l'anglais, vous pouvez les conserver dans un répertoire séparé sous `source` (par exemple, `source/es`) et utiliser la variable d'environnement `GUIDES_LANGUAGE` :

```bash
$ bundle exec rake guides:generate GUIDES_LANGUAGE=es
```

Si vous souhaitez voir toutes les variables d'environnement que vous pouvez utiliser pour configurer le script de génération, exécutez simplement :

```bash
$ rake
```

### Validation

Veuillez valider le HTML généré avec :

```bash
$ bundle exec rake guides:validate
```

En particulier, les titres obtiennent un ID généré à partir de leur contenu et cela conduit souvent à des doublons.

Guides Kindle
-------------

### Génération

Pour générer des guides pour le Kindle, utilisez la tâche rake suivante :

```bash
$ bundle exec rake guides:generate:kindle
```
