**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 3cf93e3667cdacd242332d2d352d53fa
Débogage des applications Rails
============================

Ce guide présente des techniques de débogage des applications Ruby on Rails.

Après avoir lu ce guide, vous saurez :

* Le but du débogage.
* Comment identifier les problèmes et les problèmes dans votre application que vos tests n'identifient pas.
* Les différentes façons de déboguer.
* Comment analyser la trace de la pile.

--------------------------------------------------------------------------------

Helpers de vue pour le débogage
--------------------------

Une tâche courante consiste à inspecter le contenu d'une variable. Rails propose trois façons différentes de le faire :

* `debug`
* `to_yaml`
* `inspect`

### `debug`

L'helper `debug` renvoie une balise \<pre> qui affiche l'objet en utilisant le format YAML. Cela générera des données lisibles par l'homme à partir de n'importe quel objet. Par exemple, si vous avez ce code dans une vue :

```html+erb
<%= debug @article %>
<p>
  <b>Titre :</b>
  <%= @article.title %>
</p>
```

Vous verrez quelque chose comme ça :

```yaml
--- !ruby/object Article
attributes:
  updated_at: 2008-09-05 22:55:47
  body: C'est un guide très utile pour déboguer votre application Rails.
  title: Guide de débogage Rails
  published: t
  id: "1"
  created_at: 2008-09-05 22:55:47
attributes_cache: {}


Titre : Guide de débogage Rails
```

### `to_yaml`

Alternativement, en appelant `to_yaml` sur n'importe quel objet, vous pouvez le convertir en YAML. Vous pouvez passer cet objet converti dans la méthode d'aide `simple_format` pour formater la sortie. C'est ainsi que `debug` fait sa magie.

```html+erb
<%= simple_format @article.to_yaml %>
<p>
  <b>Titre :</b>
  <%= @article.title %>
</p>
```

Le code ci-dessus affichera quelque chose comme ça :

```yaml
--- !ruby/object Article
attributes:
updated_at: 2008-09-05 22:55:47
body: C'est un guide très utile pour déboguer votre application Rails.
title: Guide de débogage Rails
published: t
id: "1"
created_at: 2008-09-05 22:55:47
attributes_cache: {}

Titre : Guide de débogage Rails
```

### `inspect`

Une autre méthode utile pour afficher les valeurs des objets est `inspect`, surtout lorsqu'on travaille avec des tableaux ou des hachages. Cela affichera la valeur de l'objet sous forme de chaîne de caractères. Par exemple :

```html+erb
<%= [1, 2, 3, 4, 5].inspect %>
<p>
  <b>Titre :</b>
  <%= @article.title %>
</p>
```

Affichera :

```
[1, 2, 3, 4, 5]

Titre : Guide de débogage Rails
```

Le Logger
----------

Il peut également être utile de sauvegarder des informations dans des fichiers journaux à l'exécution. Rails maintient un fichier journal distinct pour chaque environnement d'exécution.

### Qu'est-ce que le Logger ?

Rails utilise la classe `ActiveSupport::Logger` pour écrire des informations de journal. D'autres enregistreurs, tels que `Log4r`, peuvent également être utilisés.

Vous pouvez spécifier un enregistreur alternatif dans `config/application.rb` ou tout autre fichier d'environnement, par exemple :

```ruby
config.logger = Logger.new(STDOUT)
config.logger = Log4r::Logger.new("Application Log")
```

Ou dans la section `Initializer`, ajoutez _n'importe lequel_ des éléments suivants

```ruby
Rails.logger = Logger.new(STDOUT)
Rails.logger = Log4r::Logger.new("Application Log")
```

CONSEIL : Par défaut, chaque journal est créé sous `Rails.root/log/` et le fichier journal est nommé d'après l'environnement dans lequel l'application s'exécute.

### Niveaux de journalisation

Lorsqu'une information est journalisée, elle est imprimée dans le journal correspondant si le niveau de journalisation du message est égal ou supérieur au niveau de journalisation configuré. Si vous voulez connaître le niveau de journalisation actuel, vous pouvez appeler la méthode `Rails.logger.level`.

Les niveaux de journalisation disponibles sont : `:debug`, `:info`, `:warn`, `:error`, `:fatal` et `:unknown`, correspondant aux numéros de niveau de journalisation de 0 à 5, respectivement. Pour changer le niveau de journalisation par défaut, utilisez

```ruby
config.log_level = :warn # Dans n'importe quel fichier d'initialisation de l'environnement, ou
Rails.logger.level = 0 # à tout moment
```

Cela est utile lorsque vous souhaitez journaliser sous développement ou en pré-production sans inonder votre journal de production avec des informations inutiles.

CONSEIL : Le niveau de journalisation par défaut de Rails est `:debug`. Cependant, il est défini sur `:info` pour l'environnement `production` dans le fichier `config/environments/production.rb` généré par défaut.

### Envoi de messages

Pour écrire dans le journal actuel, utilisez la méthode `logger.(debug|info|warn|error|fatal|unknown)` à partir d'un contrôleur, d'un modèle ou d'un mailer :

```ruby
logger.debug "Person attributes hash: #{@person.attributes.inspect}"
logger.info "Processing the request..."
logger.fatal "Terminating application, raised unrecoverable error!!!"
```

Voici un exemple d'une méthode instrumentée avec des journaux supplémentaires :

```ruby
class ArticlesController < ApplicationController
  # ...

  def create
    @article = Article.new(article_params)
    logger.debug "New article: #{@article.attributes.inspect}"
    logger.debug "Article should be valid: #{@article.valid?}"

    if @article.save
      logger.debug "The article was saved and now the user is going to be redirected..."
      redirect_to @article, notice: 'Article was successfully created.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  # ...

  private
    def article_params
      params.require(:article).permit(:title, :body, :published)
    end
end
```

Voici un exemple du journal généré lorsque cette action du contrôleur est exécutée :
```
Début de la requête POST "/articles" pour 127.0.0.1 à 2018-10-18 20:09:23 -0400
Traitement par ArticlesController#create en tant qu'HTML
  Paramètres: {"utf8"=>"✓", "authenticity_token"=>"XLveDrKzF1SwaiNRPTaMtkrsTzedtebPPkmxEFIU0ordLjICSnXsSNfrdMa4ccyBjuGwnnEiQhEoMN6H1Gtz3A==", "article"=>{"title"=>"Debugging Rails", "body"=>"J'apprends comment imprimer dans les journaux.", "published"=>"0"}, "commit"=>"Create Article"}
Nouvel article: {"id"=>nil, "title"=>"Debugging Rails", "body"=>"J'apprends comment imprimer dans les journaux.", "published"=>false, "created_at"=>nil, "updated_at"=>nil}
L'article devrait être valide: true
   (0.0ms)  début de la transaction
  ↳ app/controllers/articles_controller.rb:31
  Création de l'article (0.5ms)  INSERT INTO "articles" ("title", "body", "published", "created_at", "updated_at") VALUES (?, ?, ?, ?, ?)  [["title", "Debugging Rails"], ["body", "J'apprends comment imprimer dans les journaux."], ["published", 0], ["created_at", "2018-10-19 00:09:23.216549"], ["updated_at", "2018-10-19 00:09:23.216549"]]
  ↳ app/controllers/articles_controller.rb:31
   (2.3ms)  fin de la transaction
  ↳ app/controllers/articles_controller.rb:31
L'article a été enregistré et l'utilisateur va maintenant être redirigé...
Redirection vers http://localhost:3000/articles/1
Terminé 302 Found en 4ms (ActiveRecord: 0.8ms)
```

Ajouter des journaux supplémentaires comme celui-ci facilite la recherche de comportements inattendus ou inhabituels dans vos journaux. Si vous ajoutez des journaux supplémentaires, assurez-vous d'utiliser de manière sensée les niveaux de journalisation pour éviter de remplir vos journaux de production avec des informations triviales inutiles.

### Journaux de requêtes verbeux

Lorsque vous examinez la sortie des requêtes de base de données dans les journaux, il n'est peut-être pas immédiatement clair pourquoi plusieurs requêtes de base de données sont déclenchées lorsqu'une seule méthode est appelée :

```
irb(main):001:0> Article.pamplemousse
  Chargement de l'article (0.4ms)  SELECT "articles".* FROM "articles"
  Chargement du commentaire (0.2ms)  SELECT "comments".* FROM "comments" WHERE "comments"."article_id" = ?  [["article_id", 1]]
  Chargement du commentaire (0.1ms)  SELECT "comments".* FROM "comments" WHERE "comments"."article_id" = ?  [["article_id", 2]]
  Chargement du commentaire (0.1ms)  SELECT "comments".* FROM "comments" WHERE "comments"."article_id" = ?  [["article_id", 3]]
=> #<Comment id: 2, author: "1", body: "Eh bien, en fait...", article_id: 1, created_at: "2018-10-19 00:56:10", updated_at: "2018-10-19 00:56:10">
```

Après avoir exécuté `ActiveRecord.verbose_query_logs = true` dans la session `bin/rails console` pour activer les journaux de requêtes verbeux et exécuté à nouveau la méthode, il devient évident quelle seule ligne de code génère tous ces appels de base de données distincts :

```
irb(main):003:0> Article.pamplemousse
  Chargement de l'article (0.2ms)  SELECT "articles".* FROM "articles"
  ↳ app/models/article.rb:5
  Chargement du commentaire (0.1ms)  SELECT "comments".* FROM "comments" WHERE "comments"."article_id" = ?  [["article_id", 1]]
  ↳ app/models/article.rb:6
  Chargement du commentaire (0.1ms)  SELECT "comments".* FROM "comments" WHERE "comments"."article_id" = ?  [["article_id", 2]]
  ↳ app/models/article.rb:6
  Chargement du commentaire (0.1ms)  SELECT "comments".* FROM "comments" WHERE "comments"."article_id" = ?  [["article_id", 3]]
  ↳ app/models/article.rb:6
=> #<Comment id: 2, author: "1", body: "Eh bien, en fait...", article_id: 1, created_at: "2018-10-19 00:56:10", updated_at: "2018-10-19 00:56:10">
```

Sous chaque instruction de base de données, vous pouvez voir des flèches pointant vers le nom de fichier source spécifique (et le numéro de ligne) de la méthode qui a entraîné un appel de base de données. Cela peut vous aider à identifier et résoudre les problèmes de performance causés par les requêtes N+1 : des requêtes de base de données uniques qui génèrent plusieurs requêtes supplémentaires.

Les journaux de requêtes verbeux sont activés par défaut dans les journaux de l'environnement de développement après Rails 5.2.

AVERTISSEMENT : Nous déconseillons l'utilisation de ce paramètre dans les environnements de production. Il repose sur la méthode `Kernel#caller` de Ruby, qui a tendance à allouer beaucoup de mémoire pour générer des traces d'appels de méthode. Utilisez plutôt des balises de journalisation des requêtes (voir ci-dessous).

### Journaux de mise en file d'attente verbeux

Similaire aux "Journaux de requêtes verbeux" ci-dessus, permet d'afficher les emplacements sources des méthodes qui mettent en file d'attente des tâches en arrière-plan.

Il est activé par défaut en développement. Pour l'activer dans d'autres environnements, ajoutez dans `application.rb` ou dans n'importe quel initialiseur d'environnement :

```rb
config.active_job.verbose_enqueue_logs = true
```

Comme les journaux de requêtes verbeux, il n'est pas recommandé de l'utiliser dans les environnements de production.

Commentaires de requêtes SQL
------------------

Les instructions SQL peuvent être commentées avec des balises contenant des informations d'exécution, telles que le nom du contrôleur ou de la tâche, pour retracer les requêtes problématiques à la zone de l'application qui a généré ces instructions. Cela est utile lorsque vous enregistrez des requêtes lentes (par exemple, [MySQL](https://dev.mysql.com/doc/refman/en/slow-query-log.html), [PostgreSQL](https://www.postgresql.org/docs/current/runtime-config-logging.html#GUC-LOG-MIN-DURATION-STATEMENT)), que vous visualisez les requêtes en cours d'exécution ou pour les outils de traçage de bout en bout.

Pour l'activer, ajoutez dans `application.rb` ou dans n'importe quel initialiseur d'environnement :

```rb
config.active_record.query_log_tags_enabled = true
```

Par défaut, le nom de l'application, le nom et l'action du contrôleur, ou le nom de la tâche sont enregistrés. Le format par défaut est [SQLCommenter](https://open-telemetry.github.io/opentelemetry-sqlcommenter/). Par exemple :

```
Chargement de l'article (0.2ms)  SELECT "articles".* FROM "articles" /*application='Blog',controller='articles',action='index'*/

Mise à jour de l'article (0.3ms)  UPDATE "articles" SET "title" = ?, "updated_at" = ? WHERE "posts"."id" = ? /*application='Blog',job='ImproveTitleJob'*/  [["title", "Improved Rails debugging guide"], ["updated_at", "2022-10-16 20:25:40.091371"], ["id", 1]]
```

Le comportement de [`ActiveRecord::QueryLogs`](https://api.rubyonrails.org/classes/ActiveRecord/QueryLogs.html) peut être modifié pour inclure tout ce qui aide à relier les points de la requête SQL, tels que les identifiants de demande et de tâche pour les journaux d'application, les identifiants de compte et de locataire, etc.
### Journalisation avec balises

Lors de l'exécution d'applications multi-utilisateurs et multi-comptes, il est souvent utile de pouvoir filtrer les journaux à l'aide de règles personnalisées. `TaggedLogging` dans Active Support vous permet de le faire en ajoutant des balises aux lignes de journal avec des sous-domaines, des identifiants de requête et tout ce qui peut faciliter le débogage de telles applications.

```ruby
logger = ActiveSupport::TaggedLogging.new(Logger.new(STDOUT))
logger.tagged("BCX") { logger.info "Stuff" }                            # Journalise "[BCX] Stuff"
logger.tagged("BCX", "Jason") { logger.info "Stuff" }                   # Journalise "[BCX] [Jason] Stuff"
logger.tagged("BCX") { logger.tagged("Jason") { logger.info "Stuff" } } # Journalise "[BCX] [Jason] Stuff"
```

### Impact des journaux sur les performances

La journalisation aura toujours un impact minime sur les performances de votre application Rails, en particulier lors de la journalisation sur disque. De plus, il y a quelques subtilités :

L'utilisation du niveau `:debug` aura un impact plus important sur les performances que `:fatal`, car un plus grand nombre de chaînes sont évaluées et écrites dans la sortie du journal (par exemple, le disque).

Un autre piège potentiel est le nombre trop élevé d'appels à `Logger` dans votre code :

```ruby
logger.debug "Person attributes hash: #{@person.attributes.inspect}"
```

Dans l'exemple ci-dessus, il y aura un impact sur les performances même si le niveau de sortie autorisé n'inclut pas le débogage. La raison en est que Ruby doit évaluer ces chaînes, ce qui inclut l'instanciation de l'objet `String` assez lourd et l'interpolation des variables.

Il est donc recommandé de passer des blocs aux méthodes du journal, car ils ne sont évalués que si le niveau de sortie est le même que celui autorisé, ou s'il est inclus dans ce niveau (c'est-à-dire un chargement différé). Le même code réécrit serait :

```ruby
logger.debug { "Person attributes hash: #{@person.attributes.inspect}" }
```

Le contenu du bloc, et donc l'interpolation des chaînes, n'est évalué que si le débogage est activé. Ces économies de performances ne sont vraiment perceptibles qu'avec de grandes quantités de journalisation, mais c'est une bonne pratique à adopter.

INFO : Cette section a été rédigée par [Jon Cairns dans une réponse sur Stack Overflow](https://stackoverflow.com/questions/16546730/logging-in-rails-is-there-any-performance-hit/16546935#16546935) et est sous licence [cc by-sa 4.0](https://creativecommons.org/licenses/by-sa/4.0/).

Débogage avec la gemme `debug`
------------------------------

Lorsque votre code se comporte de manière inattendue, vous pouvez essayer d'imprimer des journaux ou de les afficher dans la console pour diagnostiquer le problème. Malheureusement, il arrive que ce type de suivi des erreurs ne soit pas efficace pour trouver la cause profonde d'un problème. Lorsque vous avez réellement besoin de plonger dans votre code source en cours d'exécution, le débogueur est votre meilleur compagnon.

Le débogueur peut également vous aider si vous souhaitez en savoir plus sur le code source de Rails mais ne savez pas par où commencer. Il vous suffit de déboguer n'importe quelle requête vers votre application et d'utiliser ce guide pour apprendre comment passer du code que vous avez écrit au code sous-jacent de Rails.

Rails 7 inclut la gemme `debug` dans le `Gemfile` des nouvelles applications générées par CRuby. Par défaut, elle est prête dans les environnements `development` et `test`. Veuillez consulter sa [documentation](https://github.com/ruby/debug) pour connaître son utilisation.

### Entrer dans une session de débogage

Par défaut, une session de débogage commencera après que la bibliothèque `debug` ait été requise, ce qui se produit lorsque votre application démarre. Mais ne vous inquiétez pas, la session n'interférera pas avec votre application.

Pour entrer dans la session de débogage, vous pouvez utiliser `binding.break` et ses alias : `binding.b` et `debugger`. Les exemples suivants utiliseront `debugger` :

```rb
class PostsController < ApplicationController
  before_action :set_post, only: %i[ show edit update destroy ]

  # GET /posts or /posts.json
  def index
    @posts = Post.all
    debugger
  end
  # ...
end
```

Une fois que votre application évalue l'instruction de débogage, elle entrera dans la session de débogage :

```rb
Processing by PostsController#index as HTML
[2, 11] in ~/projects/rails-guide-example/app/controllers/posts_controller.rb
     2|   before_action :set_post, only: %i[ show edit update destroy ]
     3|
     4|   # GET /posts or /posts.json
     5|   def index
     6|     @posts = Post.all
=>   7|     debugger
     8|   end
     9|
    10|   # GET /posts/1 or /posts/1.json
    11|   def show
=>#0    PostsController#index at ~/projects/rails-guide-example/app/controllers/posts_controller.rb:7
  #1    ActionController::BasicImplicitRender#send_action(method="index", args=[]) at ~/.rbenv/versions/3.0.1/lib/ruby/gems/3.0.0/gems/actionpack-7.1.0.alpha/lib/action_controller/metal/basic_implicit_render.rb:6
  # and 72 frames (use `bt' command for all frames)
(rdbg)
```

Vous pouvez quitter la session de débogage à tout moment et continuer l'exécution de votre application avec la commande `continue` (ou `c`). Ou, pour quitter à la fois la session de débogage et votre application, utilisez la commande `quit` (ou `q`).

### Le contexte

Après avoir entré dans la session de débogage, vous pouvez saisir du code Ruby comme si vous étiez dans une console Rails ou IRB.

```rb
(rdbg) @posts    # ruby
[]
(rdbg) self
#<PostsController:0x0000000000aeb0>
(rdbg)
```

Vous pouvez également utiliser les commandes `p` ou `pp` pour évaluer des expressions Ruby, ce qui est utile lorsque le nom d'une variable entre en conflit avec une commande du débogueur.
```rb
(rdbg) p headers    # commande
=> {"X-Frame-Options"=>"SAMEORIGIN", "X-XSS-Protection"=>"1; mode=block", "X-Content-Type-Options"=>"nosniff", "X-Download-Options"=>"noopen", "X-Permitted-Cross-Domain-Policies"=>"none", "Referrer-Policy"=>"strict-origin-when-cross-origin"}
(rdbg) pp headers    # commande
{"X-Frame-Options"=>"SAMEORIGIN",
 "X-XSS-Protection"=>"1; mode=block",
 "X-Content-Type-Options"=>"nosniff",
 "X-Download-Options"=>"noopen",
 "X-Permitted-Cross-Domain-Policies"=>"none",
 "Referrer-Policy"=>"strict-origin-when-cross-origin"}
(rdbg)
```

En plus de l'évaluation directe, le débogueur vous aide également à collecter une grande quantité d'informations grâce à différentes commandes, telles que :

- `info` (ou `i`) - Informations sur la trame actuelle.
- `backtrace` (ou `bt`) - Trace arrière (avec des informations supplémentaires).
- `outline` (ou `o`, `ls`) - Méthodes disponibles, constantes, variables locales et variables d'instance dans la portée actuelle.

#### La commande `info`

`info` fournit un aperçu des valeurs des variables locales et d'instance visibles à partir de la trame actuelle.

```rb
(rdbg) info    # commande
%self = #<PostsController:0x0000000000af78>
@_action_has_layout = true
@_action_name = "index"
@_config = {}
@_lookup_context = #<ActionView::LookupContext:0x00007fd91a037e38 @details_key=nil, @digest_cache=...
@_request = #<ActionDispatch::Request GET "http://localhost:3000/posts" for 127.0.0.1>
@_response = #<ActionDispatch::Response:0x00007fd91a03ea08 @mon_data=#<Monitor:0x00007fd91a03e8c8>...
@_response_body = nil
@_routes = nil
@marked_for_same_origin_verification = true
@posts = []
@rendered_format = nil
```

#### La commande `backtrace`

Lorsqu'elle est utilisée sans options, `backtrace` liste toutes les trames de la pile :

```rb
=>#0    PostsController#index at ~/projects/rails-guide-example/app/controllers/posts_controller.rb:7
  #1    ActionController::BasicImplicitRender#send_action(method="index", args=[]) at ~/.rbenv/versions/3.0.1/lib/ruby/gems/3.0.0/gems/actionpack-7.1.0.alpha/lib/action_controller/metal/basic_implicit_render.rb:6
  #2    AbstractController::Base#process_action(method_name="index", args=[]) at ~/.rbenv/versions/3.0.1/lib/ruby/gems/3.0.0/gems/actionpack-7.1.0.alpha/lib/abstract_controller/base.rb:214
  #3    ActionController::Rendering#process_action(#arg_rest=nil) at ~/.rbenv/versions/3.0.1/lib/ruby/gems/3.0.0/gems/actionpack-7.1.0.alpha/lib/action_controller/metal/rendering.rb:53
  #4    block in process_action at ~/.rbenv/versions/3.0.1/lib/ruby/gems/3.0.0/gems/actionpack-7.1.0.alpha/lib/abstract_controller/callbacks.rb:221
  #5    block in run_callbacks at ~/.rbenv/versions/3.0.1/lib/ruby/gems/3.0.0/gems/activesupport-7.1.0.alpha/lib/active_support/callbacks.rb:118
  #6    ActionText::Rendering::ClassMethods#with_renderer(renderer=#<PostsController:0x0000000000af78>) at ~/.rbenv/versions/3.0.1/lib/ruby/gems/3.0.0/gems/actiontext-7.1.0.alpha/lib/action_text/rendering.rb:20
  #7    block {|controller=#<PostsController:0x0000000000af78>, action=#<Proc:0x00007fd91985f1c0 /Users/st0012/...|} in <class:Engine> (4 levels) at ~/.rbenv/versions/3.0.1/lib/ruby/gems/3.0.0/gems/actiontext-7.1.0.alpha/lib/action_text/engine.rb:69
  #8    [C] BasicObject#instance_exec at ~/.rbenv/versions/3.0.1/lib/ruby/gems/3.0.0/gems/activesupport-7.1.0.alpha/lib/active_support/callbacks.rb:127
  ..... et plus
```

Chaque trame est accompagnée de :

- Identifiant de la trame
- Emplacement de l'appel
- Informations supplémentaires (par exemple, arguments de bloc ou de méthode)

Cela vous donnera une bonne idée de ce qui se passe dans votre application. Cependant, vous remarquerez probablement que :

- Il y a trop de trames (généralement plus de 50 dans une application Rails).
- La plupart des trames proviennent de Rails ou d'autres bibliothèques que vous utilisez.

La commande `backtrace` propose 2 options pour vous aider à filtrer les trames :

- `backtrace [num]` - affiche uniquement `num` nombres de trames, par exemple `backtrace 10`.
- `backtrace /pattern/` - affiche uniquement les trames dont l'identifiant ou l'emplacement correspond au motif, par exemple `backtrace /MyModel/`.

Il est également possible d'utiliser ces options ensemble : `backtrace [num] /pattern/`.

#### La commande `outline`

`outline` est similaire à la commande `ls` de `pry` et `irb`. Elle vous montrera ce qui est accessible depuis la portée actuelle, y compris :

- Variables locales
- Variables d'instance
- Variables de classe
- Méthodes et leurs sources

```rb
ActiveSupport::Configurable#methods: config
AbstractController::Base#methods:
  action_methods  action_name  action_name=  available_action?  controller_path  inspect
  response_body
ActionController::Metal#methods:
  content_type       content_type=  controller_name  dispatch          headers
  location           location=      media_type       middleware_stack  middleware_stack=
  middleware_stack?  performed?     request          request=          reset_session
  response           response=      response_body=   response_code     session
  set_request!       set_response!  status           status=           to_a
ActionView::ViewPaths#methods:
  _prefixes  any_templates?  append_view_path   details_for_lookup  formats     formats=  locale
  locale=    lookup_context  prepend_view_path  template_exists?    view_paths
AbstractController::Rendering#methods: view_assigns

# .....

PostsController#methods: create  destroy  edit  index  new  show  update
instance variables:
  @_action_has_layout  @_action_name    @_config  @_lookup_context                      @_request
  @_response           @_response_body  @_routes  @marked_for_same_origin_verification  @posts
  @rendered_format
class variables: @@raise_on_missing_translations  @@raise_on_open_redirects
```

### Points d'arrêt

Il existe de nombreuses façons d'insérer et de déclencher un point d'arrêt dans le débogueur. En plus d'ajouter des instructions de débogage (par exemple, `debugger`) directement dans votre code, vous pouvez également insérer des points d'arrêt avec des commandes :

- `break` (ou `b`)
  - `break` - liste tous les points d'arrêt
  - `break <num>` - définit un point d'arrêt sur la ligne `num` du fichier actuel
  - `break <file:num>` - définit un point d'arrêt sur la ligne `num` du fichier `file`
  - `break <Class#method>` ou `break <Class.method>` - définit un point d'arrêt sur `Class#method` ou `Class.method`
  - `break <expr>.<method>` - définit un point d'arrêt sur la méthode `<method>` du résultat de `<expr>`.
- `catch <Exception>` - définit un point d'arrêt qui s'arrêtera lorsque `Exception` sera levée
- `watch <@ivar>` - définit un point d'arrêt
```rb
(rdbg) c    # commande continue
[23, 32] in ~/projects/rails-guide-example/app/controllers/posts_controller.rb
    23|   def create
    24|     @post = Post.new(post_params)
    25|     debugger
    26|
    27|     respond_to do |format|
=>  28|       if @post.save
    29|         format.html { redirect_to @post, notice: "Post was successfully created." }
    30|         format.json { render :show, status: :created, location: @post }
    31|       else
    32|         format.html { render :new, status: :unprocessable_entity }
=>#0    block {|format=#<ActionController::MimeResponds::Collec...|} in create at ~/projects/rails-guide-example/app/controllers/posts_controller.rb:28
  #1    ActionController::MimeResponds#respond_to(mimes=[]) at ~/.rbenv/versions/3.0.1/lib/ruby/gems/3.0.0/gems/actionpack-7.0.0.alpha2/lib/action_controller/metal/mime_responds.rb:205
  # et 74 frames (utilisez la commande `bt' pour afficher toutes les frames)

Arrêt à #0  BP - Ligne  /Users/st0012/projects/rails-guide-example/app/controllers/posts_controller.rb:28 (ligne)
```

Définir un point d'arrêt sur un appel de méthode donné - par exemple `b @post.save`.

```rb
[20, 29] in ~/projects/rails-guide-example/app/controllers/posts_controller.rb
    20|   end
    21|
    22|   # POST /posts or /posts.json
    23|   def create
    24|     @post = Post.new(post_params)
=>  25|     debugger
    26|
    27|     respond_to do |format|
    28|       if @post.save
    29|         format.html { redirect_to @post, notice: "Post was successfully created." }
=>#0    PostsController#create at ~/projects/rails-guide-example/app/controllers/posts_controller.rb:25
  #1    ActionController::BasicImplicitRender#send_action(method="create", args=[]) at ~/.rbenv/versions/3.0.1/lib/ruby/gems/3.0.0/gems/actionpack-7.0.0.alpha2/lib/action_controller/metal/basic_implicit_render.rb:6
  # et 72 frames (utilisez la commande `bt' pour afficher toutes les frames)
(rdbg) b @post.save    # commande break
#0  BP - Méthode  @post.save à /Users/st0012/.rbenv/versions/3.0.1/lib/ruby/gems/3.0.0/gems/activerecord-7.0.0.alpha2/lib/active_record/suppressor.rb:43

```

```rb
(rdbg) c    # commande continue
[39, 48] in ~/.rbenv/versions/3.0.1/lib/ruby/gems/3.0.0/gems/activerecord-7.0.0.alpha2/lib/active_record/suppressor.rb
    39|         SuppressorRegistry.suppressed[name] = previous_state
    40|       end
    41|     end
    42|
    43|     def save(**) # :nodoc:
=>  44|       SuppressorRegistry.suppressed[self.class.name] ? true : super
    45|     end
    46|
    47|     def save!(**) # :nodoc:
    48|       SuppressorRegistry.suppressed[self.class.name] ? true : super
=>#0    ActiveRecord::Suppressor#save(#arg_rest=nil) at ~/.rbenv/versions/3.0.1/lib/ruby/gems/3.0.0/gems/activerecord-7.0.0.alpha2/lib/active_record/suppressor.rb:44
  #1    block {|format=#<ActionController::MimeResponds::Collec...|} in create at ~/projects/rails-guide-example/app/controllers/posts_controller.rb:28
  # et 75 frames (utilisez la commande `bt' pour afficher toutes les frames)

Arrêt à #0  BP - Méthode  @post.save à /Users/st0012/.rbenv/versions/3.0.1/lib/ruby/gems/3.0.0/gems/activerecord-7.0.0.alpha2/lib/active_record/suppressor.rb:43
```

#### La commande `catch`

Arrêtez-vous lorsqu'une exception est levée - par exemple `catch ActiveRecord::RecordInvalid`.

```rb
[20, 29] in ~/projects/rails-guide-example/app/controllers/posts_controller.rb
    20|   end
    21|
    22|   # POST /posts or /posts.json
    23|   def create
    24|     @post = Post.new(post_params)
=>  25|     debugger
    26|
    27|     respond_to do |format|
    28|       if @post.save!
    29|         format.html { redirect_to @post, notice: "Post was successfully created." }
=>#0    PostsController#create at ~/projects/rails-guide-example/app/controllers/posts_controller.rb:25
  #1    ActionController::BasicImplicitRender#send_action(method="create", args=[]) at ~/.rbenv/versions/3.0.1/lib/ruby/gems/3.0.0/gems/actionpack-7.0.0.alpha2/lib/action_controller/metal/basic_implicit_render.rb:6
  # et 72 frames (utilisez la commande `bt' pour afficher toutes les frames)
(rdbg) catch ActiveRecord::RecordInvalid    # commande
#1  BP - Catch  "ActiveRecord::RecordInvalid"
```

```rb
(rdbg) c    # commande continue
[75, 84] in ~/.rbenv/versions/3.0.1/lib/ruby/gems/3.0.0/gems/activerecord-7.0.0.alpha2/lib/active_record/validations.rb
    75|     def default_validation_context
    76|       new_record? ? :create : :update
    77|     end
    78|
    79|     def raise_validation_error
=>  80|       raise(RecordInvalid.new(self))
    81|     end
    82|
    83|     def perform_validations(options = {})
    84|       options[:validate] == false || valid?(options[:context])
=>#0    ActiveRecord::Validations#raise_validation_error at ~/.rbenv/versions/3.0.1/lib/ruby/gems/3.0
Veuillez noter que les 3 premières options : `do:`, `pre:` et `if:` sont également disponibles pour les instructions de débogage que nous avons mentionnées précédemment. Par exemple :

```rb
[2, 11] in ~/projects/rails-guide-example/app/controllers/posts_controller.rb
     2|   before_action :set_post, only: %i[ show edit update destroy ]
     3|
     4|   # GET /posts or /posts.json
     5|   def index
     6|     @posts = Post.all
=>   7|     debugger(do: "info")
     8|   end
     9|
    10|   # GET /posts/1 or /posts/1.json
    11|   def show
=>#0    PostsController#index at ~/projects/rails-guide-example/app/controllers/posts_controller.rb:7
  #1    ActionController::BasicImplicitRender#send_action(method="index", args=[]) at ~/.rbenv/versions/3.0.1/lib/ruby/gems/3.0.0/gems/actionpack-7.0.0.alpha2/lib/action_controller/metal/basic_implicit_render.rb:6
  # et 72 frames (utilisez la commande `bt' pour tous les frames)
(rdbg:binding.break) info
%self = #<PostsController:0x00000000017480>
@_action_has_layout = true
@_action_name = "index"
@_config = {}
@_lookup_context = #<ActionView::LookupContext:0x00007fce3ad336b8 @details_key=nil, @digest_cache=...
@_request = #<ActionDispatch::Request GET "http://localhost:3000/posts" for 127.0.0.1>
@_response = #<ActionDispatch::Response:0x00007fce3ad397e8 @mon_data=#<Monitor:0x00007fce3ad396a8>...
@_response_body = nil
@_routes = nil
@marked_for_same_origin_verification = true
@posts = #<ActiveRecord::Relation [#<Post id: 2, title: "qweqwe", content: "qweqwe", created_at: "...
@rendered_format = nil
```

#### Programmez votre flux de travail de débogage

Avec ces options, vous pouvez scripter votre flux de travail de débogage en une seule ligne comme ceci :

```rb
def create
  debugger(do: "catch ActiveRecord::RecordInvalid do: bt 10")
  # ...
end
```

Ensuite, le débogueur exécutera la commande scriptée et insérera le point d'arrêt catch

```rb
(rdbg:binding.break) catch ActiveRecord::RecordInvalid do: bt 10
#0  BP - Catch  "ActiveRecord::RecordInvalid"
[75, 84] in ~/.rbenv/versions/3.0.1/lib/ruby/gems/3.0.0/gems/activerecord-7.0.0.alpha2/lib/active_record/validations.rb
    75|     def default_validation_context
    76|       new_record? ? :create : :update
    77|     end
    78|
    79|     def raise_validation_error
=>  80|       raise(RecordInvalid.new(self))
    81|     end
    82|
    83|     def perform_validations(options = {})
    84|       options[:validate] == false || valid?(options[:context])
=>#0    ActiveRecord::Validations#raise_validation_error at ~/.rbenv/versions/3.0.1/lib/ruby/gems/3.0.0/gems/activerecord-7.0.0.alpha2/lib/active_record/validations.rb:80
  #1    ActiveRecord::Validations#save!(options={}) at ~/.rbenv/versions/3.0.1/lib/ruby/gems/3.0.0/gems/activerecord-7.0.0.alpha2/lib/active_record/validations.rb:53
  # et 88 frames (utilisez la commande `bt' pour tous les frames)
```

Une fois que le point d'arrêt catch est déclenché, il affiche les frames de la pile

```rb
Arrêt par #0  BP - Catch  "ActiveRecord::RecordInvalid"

(rdbg:catch) bt 10
=>#0    ActiveRecord::Validations#raise_validation_error at ~/.rbenv/versions/3.0.1/lib/ruby/gems/3.0.0/gems/activerecord-7.0.0.alpha2/lib/active_record/validations.rb:80
  #1    ActiveRecord::Validations#save!(options={}) at ~/.rbenv/versions/3.0.1/lib/ruby/gems/3.0.0/gems/activerecord-7.0.0.alpha2/lib/active_record/validations.rb:53
  #2    block in save! at ~/.rbenv/versions/3.0.1/lib/ruby/gems/3.0.0/gems/activerecord-7.0.0.alpha2/lib/active_record/transactions.rb:302
```

Cette technique peut vous éviter de saisir manuellement des commandes répétitives et rendre l'expérience de débogage plus fluide.

Vous pouvez trouver plus de commandes et d'options de configuration dans sa [documentation](https://github.com/ruby/debug).

Débogage avec la gem `web-console`
----------------------------------

Web Console est un peu comme `debug`, mais il s'exécute dans le navigateur. Vous pouvez demander une console dans le contexte d'une vue ou d'un contrôleur sur n'importe quelle page. La console sera rendue à côté de votre contenu HTML.

### Console

Dans n'importe quelle action de contrôleur ou vue, vous pouvez invoquer la console en appelant la méthode `console`.

Par exemple, dans un contrôleur :

```ruby
class PostsController < ApplicationController
  def new
    console
    @post = Post.new
  end
end
```

Ou dans une vue :

```html+erb
<% console %>

<h2>Nouvel article</h2>
```

Cela rendra une console dans votre vue. Vous n'avez pas besoin de vous soucier de l'emplacement de l'appel `console` ; il ne sera pas rendu à l'endroit de son invocation, mais à côté de votre contenu HTML.

La console exécute du code Ruby pur : vous pouvez définir et instancier des classes personnalisées, créer de nouveaux modèles et inspecter des variables.

REMARQUE : Une seule console peut être rendue par requête. Sinon, `web-console` lèvera une erreur lors de la deuxième invocation de `console`.

### Inspection des variables

Vous pouvez invoquer `instance_variables` pour lister toutes les variables d'instance disponibles dans votre contexte. Si vous souhaitez lister toutes les variables locales, vous pouvez le faire avec `local_variables`.

### Paramètres

* `config.web_console.allowed_ips` : Liste autorisée d'adresses IPv4 ou IPv6 et de réseaux (par défaut : `127.0.0.1/8, ::1`).
* `config.web_console.whiny_requests` : Enregistre un message lorsqu'un rendu de console est empêché (par défaut : `true`).

Comme `web-console` évalue du code Ruby pur à distance sur le serveur, ne l'utilisez pas en production.

Débogage des fuites de mémoire
------------------------------

Une application Ruby (sur Rails ou non) peut avoir des fuites de mémoire, que ce soit dans le code Ruby ou au niveau du code C.

Dans cette section, vous apprendrez comment trouver et corriger de telles fuites en utilisant des outils tels que Valgrind.

### Valgrind

[Valgrind](http://valgrind.org/) est une application permettant de détecter les fuites de mémoire et les conditions de concurrence basées sur le C.

Il existe des outils Valgrind qui peuvent détecter automatiquement de nombreux bugs de gestion de la mémoire et des threads, et profiler vos programmes en détail. Par exemple, si une extension C dans l'interpréteur appelle `malloc()` mais n'appelle pas correctement `free()`, cette mémoire ne sera pas disponible tant que l'application ne se termine pas.

Pour plus d'informations sur l'installation de Valgrind et son utilisation avec Ruby, consultez [Valgrind and Ruby](https://blog.evanweaver.com/2008/02/05/valgrind-and-ruby/) par Evan Weaver.

### Trouver une fuite de mémoire

Il existe un excellent article sur la détection et la correction des fuites de mémoire chez Derailed, [que vous pouvez lire ici](https://github.com/schneems/derailed_benchmarks#is-my-app-leaking-memory).
Plugins pour le débogage
---------------------

Il existe quelques plugins Rails pour vous aider à trouver des erreurs et déboguer votre application. Voici une liste de plugins utiles pour le débogage :

* [Query Trace](https://github.com/ruckus/active-record-query-trace/tree/master) Ajoute une trace d'origine de requête à vos journaux.
* [Exception Notifier](https://github.com/smartinez87/exception_notification/tree/master) Fournit un objet mailer et un ensemble de modèles par défaut pour envoyer des notifications par e-mail lorsque des erreurs se produisent dans une application Rails.
* [Better Errors](https://github.com/charliesome/better_errors) Remplace la page d'erreur standard de Rails par une nouvelle contenant plus d'informations contextuelles, comme le code source et l'inspection des variables.
* [RailsPanel](https://github.com/dejan/rails_panel) Extension Chrome pour le développement Rails qui met fin à la surveillance du fichier development.log. Obtenez toutes les informations sur les requêtes de votre application Rails dans le navigateur - dans le panneau Outils de développement. Fournit un aperçu des temps de db/rendering/total, de la liste des paramètres, des vues rendues et plus encore.
* [Pry](https://github.com/pry/pry) Une alternative à IRB et une console de développement en temps d'exécution.

Références
----------

* [Page d'accueil de web-console](https://github.com/rails/web-console)
* [Page d'accueil de debug](https://github.com/ruby/debug)
