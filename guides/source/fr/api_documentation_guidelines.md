**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 58b6e6f83da0f420f5da5f7d38d938db
Directives de documentation de l'API
=====================================

Ce guide documente les directives de documentation de l'API Ruby on Rails.

Après avoir lu ce guide, vous saurez :

* Comment rédiger un texte efficace à des fins de documentation.
* Les directives de style pour documenter différents types de code Ruby.

--------------------------------------------------------------------------------

RDoc
----

La documentation de l'API Rails est générée avec [RDoc](https://ruby.github.io/rdoc/). Pour la générer, assurez-vous d'être dans le répertoire racine de Rails, exécutez `bundle install` et exécutez :

```bash
$ bundle exec rake rdoc
```

Les fichiers HTML résultants se trouvent dans le répertoire ./doc/rdoc.

NOTE : Veuillez consulter la [Référence de balisage RDoc][RDoc Markup] pour obtenir de l'aide sur la syntaxe.

Liens
-----

La documentation de l'API Rails ne doit pas être consultée sur GitHub et donc les liens doivent utiliser la balise [`link`][RDoc Links] de RDoc relative à l'API actuelle.

Cela est dû aux différences entre le Markdown de GitHub et le RDoc généré qui est publié sur [api.rubyonrails.org](https://api.rubyonrails.org) et [edgeapi.rubyonrails.org](https://edgeapi.rubyonrails.org).

Par exemple, nous utilisons `[link:classes/ActiveRecord/Base.html]` pour créer un lien vers la classe `ActiveRecord::Base` générée par RDoc.

Cela est préférable aux URL absolues telles que `[https://api.rubyonrails.org/classes/ActiveRecord/Base.html]`, qui amèneraient le lecteur en dehors de sa version actuelle de documentation (par exemple, edgeapi.rubyonrails.org).

[RDoc Markup]: https://ruby.github.io/rdoc/RDoc/MarkupReference.html
[RDoc Links]: https://ruby.github.io/rdoc/RDoc/MarkupReference.html#class-RDoc::MarkupReference-label-Links

Rédaction
---------

Rédigez des phrases simples et déclaratives. La brièveté est un plus : allez droit au but.

Rédigez au présent : "Renvoie un hash qui...", plutôt que "A renvoyé un hash qui..." ou "Renvoiera un hash qui...".

Commencez les commentaires en majuscule. Suivez les règles de ponctuation habituelles :

```ruby
# Déclare un lecteur d'attribut basé sur une variable d'instance
# nommée en interne.
def attr_internal_reader(*attrs)
  # ...
end
```

Communiquez au lecteur la manière actuelle de faire les choses, de manière explicite et implicite. Utilisez les idiomes recommandés dans la version actuelle. Réorganisez les sections pour mettre en avant les approches préférées si nécessaire, etc. La documentation doit être un modèle de bonnes pratiques et d'utilisation canonique et moderne de Rails.

La documentation doit être concise mais complète. Explorez et documentez les cas particuliers. Que se passe-t-il si un module est anonyme ? Que se passe-t-il si une collection est vide ? Que se passe-t-il si un argument est nul ?

Les noms propres des composants de Rails ont un espace entre les mots, comme "Active Support". `ActiveRecord` est un module Ruby, tandis qu'Active Record est un ORM. Toute la documentation de Rails doit faire référence de manière cohérente aux composants de Rails par leurs noms propres.

Lorsque vous faites référence à une "application Rails", par opposition à un "moteur" ou un "plugin", utilisez toujours "application". Les applications Rails ne sont pas des "services", sauf si l'on parle spécifiquement d'architecture orientée services.

Écrivez correctement les noms : Arel, minitest, RSpec, HTML, MySQL, JavaScript, ERB, Hotwire. En cas de doute, veuillez consulter une source autorisée comme leur documentation officielle.

Privilégiez les formulations qui évitent les "vous" et les "votre". Par exemple, au lieu de

```markdown
Si vous avez besoin d'utiliser des instructions `return` dans vos rappels, il est recommandé de les définir explicitement en tant que méthodes.
```

utilisez cette formulation :

```markdown
Si `return` est nécessaire, il est recommandé de définir explicitement une méthode.
```

Cela dit, lors de l'utilisation de pronoms en référence à une personne hypothétique, telle qu'un "utilisateur avec un cookie de session", des pronoms neutres en genre (they/their/them) doivent être utilisés. Au lieu de :

* he or she... utilisez they.
* him or her... utilisez them.
* his or her... utilisez their.
* his or hers... utilisez theirs.
* himself or herself... utilisez themselves.

Anglais
-------

Veuillez utiliser l'anglais américain (*color*, *center*, *modularize*, etc). Voir [une liste des différences d'orthographe entre l'anglais américain et britannique ici](https://en.wikipedia.org/wiki/American_and_British_English_spelling_differences).

Virgule de séparation
----------------------

Veuillez utiliser la [virgule de séparation](https://en.wikipedia.org/wiki/Serial_comma) (par exemple, "rouge, blanc et bleu", au lieu de "rouge, blanc et bleu").

Exemples de code
----------------

Choisissez des exemples significatifs qui représentent les bases ainsi que des points intéressants ou des pièges.

Utilisez deux espaces pour indenter les morceaux de code, c'est-à-dire, à des fins de balisage, deux espaces par rapport à la marge de gauche. Les exemples eux-mêmes doivent utiliser les [conventions de codage Rails](contributing_to_ruby_on_rails.html#follow-the-coding-conventions).

Les courtes documentations n'ont pas besoin d'une étiquette "Exemples" explicite pour introduire des extraits de code ; ils suivent simplement les paragraphes :

```ruby
# Convertit une collection d'éléments en une chaîne formatée en
# appelant +to_s+ sur tous les éléments et en les joignant.
#
#   Blog.all.to_fs # => "First PostSecond PostThird Post"
```

En revanche, les gros morceaux de documentation structurée peuvent avoir une section "Exemples" séparée :

```ruby
# ==== Exemples
#
#   Person.exists?(5)
#   Person.exists?('5')
#   Person.exists?(name: "David")
#   Person.exists?(['name LIKE ?', "%#{query}%"])
```
Les résultats des expressions les suivent et sont introduits par "# => ", alignés verticalement :

```ruby
# Pour vérifier si un entier est pair ou impair.
#
#   1.even? # => false
#   1.odd?  # => true
#   2.even? # => true
#   2.odd?  # => false
```

Si une ligne est trop longue, le commentaire peut être placé sur la ligne suivante :

```ruby
#   label(:article, :title)
#   # => <label for="article_title">Title</label>
#
#   label(:article, :title, "A short title")
#   # => <label for="article_title">A short title</label>
#
#   label(:article, :title, "A short title", class: "title_label")
#   # => <label for="article_title" class="title_label">A short title</label>
```

Évitez d'utiliser des méthodes d'impression comme `puts` ou `p` à cette fin.

D'autre part, les commentaires réguliers n'utilisent pas de flèche :

```ruby
#   polymorphic_url(record)  # same as comment_url(record)
```

### SQL

Lors de la documentation des instructions SQL, le résultat ne doit pas avoir `=>` avant la sortie.

Par exemple,

```ruby
#   User.where(name: 'Oscar').to_sql
#   # SELECT "users".* FROM "users"  WHERE "users"."name" = 'Oscar'
```

### IRB

Lors de la documentation du comportement pour IRB, le REPL interactif de Ruby, préfixez toujours les commandes avec `irb>` et la sortie doit être préfixée avec `=>`.

Par exemple,

```
# Find the customer with primary key (id) 10.
#   irb> customer = Customer.find(10)
#   # => #<Customer id: 10, first_name: "Ryan">
```

### Bash / Ligne de commande

Pour les exemples en ligne de commande, préfixez toujours la commande avec `$`, la sortie n'a pas besoin d'être préfixée avec quoi que ce soit.

```
# Run the following command:
#   $ bin/rails new zomg
#   ...
```

Booléens
--------

Dans les prédicats et les indicateurs, préférez documenter les sémantiques booléennes plutôt que les valeurs exactes.

Lorsque "true" ou "false" sont utilisés tels que définis en Ruby, utilisez une police régulière. Les singletons `true` et `false` nécessitent une police à largeur fixe. Évitez les termes tels que "truthy", Ruby définit ce qui est vrai et faux dans le langage, et donc ces mots ont une signification technique et n'ont pas besoin de substituts.

En règle générale, n'utilisez pas de singletons à moins que cela ne soit absolument nécessaire. Cela évite les constructions artificielles comme `!!` ou les ternaires, permet les refontes, et le code n'a pas besoin de se fier aux valeurs exactes renvoyées par les méthodes appelées dans l'implémentation.

Par exemple :

```markdown
`config.action_mailer.perform_deliveries` spécifie si le courrier sera réellement livré et est vrai par défaut
```

l'utilisateur n'a pas besoin de connaître la valeur par défaut réelle de l'indicateur,
et nous ne documentons donc que ses sémantiques booléennes.

Un exemple avec un prédicat :

```ruby
# Returns true if the collection is empty.
#
# If the collection has been loaded
# it is equivalent to <tt>collection.size.zero?</tt>. If the
# collection has not been loaded, it is equivalent to
# <tt>!collection.exists?</tt>. If the collection has not already been
# loaded and you are going to fetch the records anyway it is better to
# check <tt>collection.length.zero?</tt>.
def empty?
  if loaded?
    size.zero?
  else
    @target.blank? && !scope.exists?
  end
end
```

L'API prend soin de ne s'engager sur aucune valeur particulière, la méthode a
des sémantiques de prédicat, c'est suffisant.

Noms de fichiers
----------

En règle générale, utilisez des noms de fichiers relatifs à la racine de l'application :

```
config/routes.rb            # OUI
routes.rb                   # NON
RAILS_ROOT/config/routes.rb # NON
```

Polices
-----

### Police à largeur fixe

Utilisez des polices à largeur fixe pour :

* Les constantes, en particulier les noms de classe et de module.
* Les noms de méthode.
* Les littéraux comme `nil`, `false`, `true`, `self`.
* Les symboles.
* Les paramètres de méthode.
* Les noms de fichiers.

```ruby
class Array
  # Calls +to_param+ on all its elements and joins the result with
  # slashes. This is used by +url_for+ in Action Pack.
  def to_param
    collect { |e| e.to_param }.join '/'
  end
end
```

AVERTISSEMENT : Utiliser `+...+` pour une police à largeur fixe ne fonctionne qu'avec un contenu simple comme
les classes ordinaires, les modules, les noms de méthode, les symboles, les chemins (avec des barres obliques),
etc. Veuillez utiliser `<tt>...</tt>` pour tout le reste.

Vous pouvez tester rapidement la sortie RDoc avec la commande suivante :

```bash
$ echo "+:to_param+" | rdoc --pipe
# => <p><code>:to_param</code></p>
```

Par exemple, le code avec des espaces ou des guillemets doit utiliser la forme `<tt>...</tt>`.

### Police régulière

Lorsque "true" et "false" sont des mots anglais plutôt que des mots-clés Ruby, utilisez une police régulière :

```ruby
# Runs all the validations within the specified context.
# Returns true if no errors are found, false otherwise.
#
# If the argument is false (default is +nil+), the context is
# set to <tt>:create</tt> if <tt>new_record?</tt> is true,
# and to <tt>:update</tt> if it is not.
#
# Validations with no <tt>:on</tt> option will run no
# matter the context. Validations with # some <tt>:on</tt>
# option will only run in the specified context.
def valid?(context = nil)
  # ...
end
```
Listes de description
-----------------

Dans les listes d'options, de paramètres, etc., utilisez un tiret entre l'élément et sa description (plus lisible qu'un deux-points car les options sont généralement des symboles) :

```ruby
# * <tt>:allow_nil</tt> - Ignorer la validation si l'attribut est +nil+.
```

La description commence par une majuscule et se termine par un point final - c'est l'anglais standard.

Une approche alternative, lorsque vous souhaitez fournir des détails supplémentaires et des exemples, consiste à utiliser le style de section d'option.

[`ActiveSupport::MessageEncryptor#encrypt_and_sign`][#encrypt_and_sign] en est un excellent exemple.

```ruby
# ==== Options
#
# [+:expires_at+]
#   La date et l'heure à laquelle le message expire. Après cette date et heure,
#   la vérification du message échouera.
#
#     message = encryptor.encrypt_and_sign("hello", expires_at: Time.now.tomorrow)
#     encryptor.decrypt_and_verify(message) # => "hello"
#     # 24 heures plus tard...
#     encryptor.decrypt_and_verify(message) # => nil
```


Méthodes générées dynamiquement
-----------------------------

Les méthodes créées avec `(module|class)_eval(STRING)` ont un commentaire à côté avec une instance du code généré. Ce commentaire est espacé de 2 espaces du modèle :

[![(module|class)_eval(STRING) code comments](images/dynamic_method_class_eval.png)](images/dynamic_method_class_eval.png)

Si les lignes résultantes sont trop larges, disons 200 colonnes ou plus, placez le commentaire au-dessus de l'appel :

```ruby
# def self.find_by_login_and_activated(*args)
#   options = args.extract_options!
#   ...
# end
self.class_eval %{
  def self.#{method_id}(*args)
    options = args.extract_options!
    ...
  end
}, __FILE__, __LINE__
```

Visibilité des méthodes
-----------------

Lors de la rédaction de la documentation pour Rails, il est important de comprendre la différence entre l'API publique destinée aux utilisateurs et l'API interne.

Rails, comme la plupart des bibliothèques, utilise le mot-clé privé de Ruby pour définir l'API interne. Cependant, l'API publique suit une convention légèrement différente. Au lieu de supposer que toutes les méthodes publiques sont conçues pour la consommation par l'utilisateur, Rails utilise la directive `:nodoc:` pour annoter ce type de méthodes en tant qu'API interne.

Cela signifie qu'il y a des méthodes dans Rails avec une visibilité `public` qui ne sont pas destinées à la consommation par l'utilisateur.

Un exemple de cela est `ActiveRecord::Core::ClassMethods#arel_table` :

```ruby
module ActiveRecord::Core::ClassMethods
  def arel_table # :nodoc:
    # faire quelque chose de magique...
  end
end
```

Si vous avez pensé : "cette méthode ressemble à une méthode de classe publique pour `ActiveRecord::Core`", vous aviez raison. Mais en réalité, l'équipe de Rails ne veut pas que les utilisateurs se fient à cette méthode. Ils la marquent donc avec `:nodoc:` et elle est supprimée de la documentation publique. La raison derrière cela est de permettre à l'équipe de modifier ces méthodes selon leurs besoins internes entre les versions comme bon leur semble. Le nom de cette méthode pourrait changer, ou la valeur de retour, ou cette classe entière pourrait disparaître ; il n'y a aucune garantie et vous ne devriez donc pas dépendre de cette API dans vos plugins ou applications. Sinon, vous risquez de casser votre application ou votre gemme lorsque vous passez à une version plus récente de Rails.

En tant que contributeur, il est important de réfléchir à savoir si cette API est destinée à la consommation par l'utilisateur final. L'équipe de Rails s'engage à ne pas apporter de modifications incompatibles à l'API publique entre les versions sans passer par un cycle complet de dépréciation. Il est recommandé d'utiliser `:nodoc:` pour marquer vos méthodes/classes internes, sauf si elles sont déjà privées (c'est-à-dire en termes de visibilité), auquel cas elles sont internes par défaut. Une fois que l'API est stabilisée, la visibilité peut changer, mais modifier l'API publique est beaucoup plus difficile en raison de la compatibilité ascendante.

Une classe ou un module est marqué avec `:nodoc:` pour indiquer que toutes les méthodes sont une API interne et ne doivent jamais être utilisées directement.

Pour résumer, l'équipe de Rails utilise `:nodoc:` pour marquer les méthodes et classes visibles publiquement comme une utilisation interne ; les changements de visibilité de l'API doivent être soigneusement considérés et discutés dans une demande de tirage en premier.

Concernant la pile Rails
-------------------------

Lors de la documentation des parties de l'API de Rails, il est important de se souvenir de tous les éléments qui composent la pile Rails.

Cela signifie que le comportement peut changer en fonction de la portée ou du contexte de la méthode ou de la classe que vous essayez de documenter.

À différents endroits, il y a un comportement différent lorsque vous tenez compte de l'ensemble de la pile, un exemple est `ActionView::Helpers::AssetTagHelper#image_tag` :

```ruby
# image_tag("icon.png")
#   # => <img src="/assets/icon.png" />
```

Bien que le comportement par défaut de `#image_tag` soit de toujours renvoyer `/images/icon.png`, nous tenons compte de l'ensemble de la pile Rails (y compris le pipeline des actifs) et nous pouvons voir le résultat ci-dessus.

Nous nous intéressons uniquement au comportement observé lors de l'utilisation de la pile Rails par défaut.

Dans ce cas, nous voulons documenter le comportement du _framework_, et pas seulement cette méthode spécifique.

Si vous avez une question sur la façon dont l'équipe de Rails gère certaines API, n'hésitez pas à ouvrir un ticket ou à envoyer un correctif au [gestionnaire de problèmes](https://github.com/rails/rails/issues).
[#encrypt_and_sign]: https://edgeapi.rubyonrails.org/classes/ActiveSupport/MessageEncryptor.html#method-i-encrypt_and_sign
