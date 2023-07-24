**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: b95e1fead49349e056e5faed88aa5760
Mise à niveau de Ruby on Rails
==============================

Ce guide fournit les étapes à suivre lorsque vous mettez à niveau vos applications vers une version plus récente de Ruby on Rails. Ces étapes sont également disponibles dans des guides de version individuels.

--------------------------------------------------------------------------------

Conseils généraux
----------------

Avant de tenter de mettre à niveau une application existante, assurez-vous d'avoir une bonne raison de le faire. Vous devez équilibrer plusieurs facteurs : le besoin de nouvelles fonctionnalités, la difficulté croissante de trouver un support pour un code obsolète, et le temps et les compétences dont vous disposez, pour n'en nommer que quelques-uns.

### Couverture des tests

La meilleure façon de s'assurer que votre application fonctionne toujours après la mise à niveau est d'avoir une bonne couverture de tests avant de commencer le processus. Si vous n'avez pas de tests automatisés qui couvrent la majeure partie de votre application, vous devrez passer du temps à tester manuellement toutes les parties qui ont changé. Dans le cas d'une mise à niveau de Rails, cela signifiera chaque fonctionnalité de l'application. Faites-vous une faveur et assurez-vous que votre couverture de tests est bonne _avant_ de commencer une mise à niveau.

### Versions de Ruby

Rails reste généralement proche de la dernière version de Ruby publiée lors de sa sortie :

* Rails 7 nécessite Ruby 2.7.0 ou une version ultérieure.
* Rails 6 nécessite Ruby 2.5.0 ou une version ultérieure.
* Rails 5 nécessite Ruby 2.2.2 ou une version ultérieure.

Il est conseillé de mettre à niveau Ruby et Rails séparément. Commencez par mettre à niveau vers la dernière version de Ruby que vous pouvez, puis mettez à niveau Rails.

### Le processus de mise à niveau

Lorsque vous changez de version de Rails, il est préférable de procéder lentement, une version mineure à la fois, afin de tirer parti des avertissements de dépréciation. Les numéros de version de Rails sont sous la forme Majeur.Mineur.Correction. Les versions majeures et mineures sont autorisées à apporter des modifications à l'API publique, ce qui peut entraîner des erreurs dans votre application. Les versions de correction ne comprennent que des corrections de bugs et ne modifient aucune API publique.

Le processus devrait se dérouler comme suit :

1. Écrivez des tests et assurez-vous qu'ils passent.
2. Passez à la dernière version de correction après votre version actuelle.
3. Corrigez les tests et les fonctionnalités dépréciées.
4. Passez à la dernière version de correction de la prochaine version mineure.

Répétez ce processus jusqu'à atteindre la version de Rails cible.

#### Passage entre les versions

Pour passer d'une version à une autre :

1. Modifiez le numéro de version de Rails dans le fichier `Gemfile` et exécutez `bundle update`.
2. Modifiez les versions des packages JavaScript de Rails dans `package.json` et exécutez `yarn install`, si vous utilisez Webpacker.
3. Exécutez la [tâche de mise à jour](#la-tâche-de-mise-à-jour).
4. Exécutez vos tests.

Vous pouvez trouver une liste de toutes les gemmes Rails publiées [ici](https://rubygems.org/gems/rails/versions).

### La tâche de mise à jour

Rails fournit la commande `rails app:update`. Après avoir mis à jour la version de Rails
dans le fichier `Gemfile`, exécutez cette commande.
Cela vous aidera à créer de nouveaux fichiers et à modifier d'anciens fichiers dans une
session interactive.

```bash
$ bin/rails app:update
       exist  config
    conflict  config/application.rb
Overwrite /myapp/config/application.rb? (enter "h" for help) [Ynaqdh]
       force  config/application.rb
      create  config/initializers/new_framework_defaults_7_0.rb
...
```

N'oubliez pas de vérifier les différences pour voir s'il y a eu des changements inattendus.

### Configurer les valeurs par défaut du framework

La nouvelle version de Rails peut avoir des valeurs par défaut de configuration différentes de la version précédente. Cependant, après avoir suivi les étapes décrites ci-dessus, votre application fonctionnera toujours avec les valeurs par défaut de configuration de la *précédente* version de Rails. Cela est dû au fait que la valeur de `config.load_defaults` dans `config/application.rb` n'a pas encore été modifiée.

Pour vous permettre de passer progressivement aux nouvelles valeurs par défaut, la tâche de mise à jour a créé un fichier `config/initializers/new_framework_defaults_X.Y.rb` (avec la version de Rails souhaitée dans le nom de fichier). Vous devez activer les nouvelles valeurs par défaut de configuration en les décommentant dans le fichier ; cela peut être fait progressivement lors de plusieurs déploiements. Une fois que votre application est prête à fonctionner avec les nouvelles valeurs par défaut, vous pouvez supprimer ce fichier et inverser la valeur de `config.load_defaults`.

Mise à niveau de Rails 7.0 vers Rails 7.1
----------------------------------------

Pour plus d'informations sur les modifications apportées à Rails 7.1, veuillez consulter les [notes de version](7_1_release_notes.html).

### Les chemins autoloadés ne sont plus dans le chemin de chargement

À partir de Rails 7.1, tous les chemins gérés par l'autoloader ne seront plus ajoutés à `$LOAD_PATH`.
Cela signifie qu'il ne sera plus possible de les charger avec un appel `require` manuel, la classe ou le module peut être référencé directement.

Réduire la taille de `$LOAD_PATH` accélère les appels à `require` pour les applications n'utilisant pas `bootsnap`, et réduit la taille du cache `bootsnap` pour les autres.
### `ActiveStorage::BaseController` n'inclut plus la préoccupation du streaming

Les contrôleurs d'application qui héritent de `ActiveStorage::BaseController` et utilisent le streaming pour implémenter une logique de service de fichiers personnalisée doivent maintenant inclure explicitement le module `ActiveStorage::Streaming`.

### `MemCacheStore` et `RedisCacheStore` utilisent maintenant la mise en pool de connexions par défaut

Le gem `connection_pool` a été ajouté en tant que dépendance du gem `activesupport`,
et les `MemCacheStore` et `RedisCacheStore` utilisent maintenant la mise en pool de connexions par défaut.

Si vous ne souhaitez pas utiliser la mise en pool de connexions, définissez l'option `:pool` sur `false` lors de la configuration de votre magasin de cache :

```ruby
config.cache_store = :mem_cache_store, "cache.example.com", pool: false
```

Consultez le guide [Caching with Rails](https://guides.rubyonrails.org/v7.1/caching_with_rails.html#connection-pool-options) pour plus d'informations.

### `SQLite3Adapter` est maintenant configuré pour être utilisé en mode strict des chaînes

L'utilisation d'un mode strict des chaînes désactive les littéraux de chaînes entre guillemets.

SQLite a quelques particularités concernant les littéraux de chaînes entre guillemets.
Il essaie d'abord de considérer les chaînes entre guillemets comme des noms d'identifiants, mais s'ils n'existent pas
il les considère ensuite comme des littéraux de chaînes. En raison de cela, les fautes de frappe peuvent passer inaperçues.
Par exemple, il est possible de créer un index pour une colonne qui n'existe pas.
Consultez la documentation de SQLite pour plus de détails : [SQLite documentation](https://www.sqlite.org/quirks.html#double_quoted_string_literals_are_accepted).

Si vous ne souhaitez pas utiliser `SQLite3Adapter` en mode strict, vous pouvez désactiver ce comportement :

```ruby
# config/application.rb
config.active_record.sqlite3_adapter_strict_strings_by_default = false
```

### Prise en charge de plusieurs chemins de prévisualisation pour `ActionMailer::Preview`

L'option `config.action_mailer.preview_path` est obsolète au profit de `config.action_mailer.preview_paths`. L'ajout de chemins à cette option de configuration entraînera l'utilisation de ces chemins dans la recherche des prévisualisations de courrier.

```ruby
config.action_mailer.preview_paths << "#{Rails.root}/lib/mailer_previews"
```

### `config.i18n.raise_on_missing_translations = true` génère maintenant une erreur pour toute traduction manquante.

Auparavant, cela ne générait une erreur que lorsqu'il était appelé dans une vue ou un contrôleur. Maintenant, cela générera une erreur chaque fois que `I18n.t` reçoit une clé non reconnue.

```ruby
# avec config.i18n.raise_on_missing_translations = true

# dans une vue ou un contrôleur :
t("missing.key") # génère une erreur dans 7.0, génère une erreur dans 7.1
I18n.t("missing.key") # ne génère pas d'erreur dans 7.0, génère une erreur dans 7.1

# n'importe où :
I18n.t("missing.key") # ne génère pas d'erreur dans 7.0, génère une erreur dans 7.1
```

Si vous ne souhaitez pas ce comportement, vous pouvez définir `config.i18n.raise_on_missing_translations = false` :

```ruby
# avec config.i18n.raise_on_missing_translations = false

# dans une vue ou un contrôleur :
t("missing.key") # ne génère pas d'erreur dans 7.0, ne génère pas d'erreur dans 7.1
I18n.t("missing.key") # ne génère pas d'erreur dans 7.0, ne génère pas d'erreur dans 7.1

# n'importe où :
I18n.t("missing.key") # ne génère pas d'erreur dans 7.0, ne génère pas d'erreur dans 7.1
```

Alternativement, vous pouvez personnaliser le gestionnaire d'exceptions `I18n.exception_handler`.
Consultez le guide [i18n](https://guides.rubyonrails.org/v7.1/i18n.html#using-different-exception-handlers) pour plus d'informations.

Mise à niveau de Rails 6.1 vers Rails 7.0
----------------------------------------

Pour plus d'informations sur les modifications apportées à Rails 7.0, veuillez consulter les [notes de version](7_0_release_notes.html).

### Le comportement de `ActionView::Helpers::UrlHelper#button_to` a changé

À partir de Rails 7.0, `button_to` génère une balise `form` avec la méthode HTTP `patch` si un objet Active Record persistant est utilisé pour construire l'URL du bouton.
Pour conserver le comportement actuel, pensez à passer explicitement l'option `method:` :

```diff
-button_to("Do a POST", [:my_custom_post_action_on_workshop, Workshop.find(1)])
+button_to("Do a POST", [:my_custom_post_action_on_workshop, Workshop.find(1)], method: :post)
```

ou utilisez une aide pour construire l'URL :

```diff
-button_to("Do a POST", [:my_custom_post_action_on_workshop, Workshop.find(1)])
+button_to("Do a POST", my_custom_post_action_on_workshop_workshop_path(Workshop.find(1)))
```

### Spring

Si votre application utilise Spring, elle doit être mise à jour vers au moins la version 3.0.0. Sinon, vous obtiendrez l'erreur suivante :

```
undefined method `mechanism=' for ActiveSupport::Dependencies:Module
```

De plus, assurez-vous que [`config.cache_classes`][] est défini sur `false` dans `config/environments/test.rb`.


### Sprockets est maintenant une dépendance facultative

Le gem `rails` ne dépend plus de `sprockets-rails`. Si votre application a encore besoin d'utiliser Sprockets,
assurez-vous d'ajouter `sprockets-rails` à votre Gemfile.

```ruby
gem "sprockets-rails"
```

### Les applications doivent fonctionner en mode `zeitwerk`

Les applications qui fonctionnent toujours en mode `classic` doivent passer en mode `zeitwerk`. Veuillez consulter le guide [Classic to Zeitwerk HOWTO](https://guides.rubyonrails.org/v7.0/classic_to_zeitwerk_howto.html) pour plus de détails.

### Le setter `config.autoloader=` a été supprimé

Dans Rails 7, il n'y a plus de point de configuration pour définir le mode de chargement automatique, `config.autoloader=` a été supprimé. Si vous l'aviez défini sur `:zeitwerk` pour une raison quelconque, supprimez-le simplement.

### L'API privée de `ActiveSupport::Dependencies` a été supprimée

L'API privée de `ActiveSupport::Dependencies` a été supprimée. Cela inclut des méthodes telles que `hook!`, `unhook!`, `depend_on`, `require_or_load`, `mechanism`, et bien d'autres.

Quelques points forts :

* Si vous utilisiez `ActiveSupport::Dependencies.constantize` ou `ActiveSupport::Dependencies.safe_constantize`, remplacez-les simplement par `String#constantize` ou `String#safe_constantize`.

  ```ruby
  ActiveSupport::Dependencies.constantize("User") # PLUS POSSIBLE
  "User".constantize # 👍
  ```

* Toute utilisation de `ActiveSupport::Dependencies.mechanism`, en lecture ou en écriture, doit être remplacée par l'accès à `config.cache_classes` en conséquence.

* Si vous souhaitez tracer l'activité du chargeur automatique, `ActiveSupport::Dependencies.verbose=` n'est plus disponible, ajoutez simplement `Rails.autoloaders.log!` dans `config/application.rb`.
Les classes ou modules internes auxiliaires ont également disparu, tels que `ActiveSupport::Dependencies::Reference`, `ActiveSupport::Dependencies::Blamable`, et d'autres.

### Chargement automatique lors de l'initialisation

Les applications qui ont chargé automatiquement des constantes rechargeables lors de l'initialisation en dehors des blocs `to_prepare` ont vu ces constantes déchargées et ont reçu cet avertissement depuis Rails 6.0 :

```
AVERTISSEMENT DE DÉPRÉCIATION : L'initialisation a chargé automatiquement la constante ....

La possibilité de le faire est dépréciée. Le chargement automatique lors de l'initialisation sera une condition d'erreur dans les versions futures de Rails.

...
```

Si vous obtenez toujours cet avertissement dans les journaux, veuillez consulter la section sur le chargement automatique lors du démarrage de l'application dans le [guide de chargement automatique](https://guides.rubyonrails.org/v7.0/autoloading_and_reloading_constants.html#autoloading-when-the-application-boots). Sinon, vous obtiendrez une `NameError` dans Rails 7.

### Possibilité de configurer `config.autoload_once_paths`

[`config.autoload_once_paths`][] peut être défini dans le corps de la classe d'application définie dans `config/application.rb` ou dans la configuration des environnements dans `config/environments/*`.

De même, les moteurs peuvent configurer cette collection dans le corps de la classe du moteur ou dans la configuration des environnements.

Ensuite, la collection est gelée, et vous pouvez charger automatiquement à partir de ces chemins. En particulier, vous pouvez charger automatiquement à partir de là lors de l'initialisation. Ils sont gérés par le chargeur automatique `Rails.autoloaders.once`, qui ne recharge pas, mais charge automatiquement/précharge.

Si vous avez configuré ce paramètre après que la configuration des environnements a été traitée et que vous obtenez une `FrozenError`, veuillez simplement déplacer le code.

### `ActionDispatch::Request#content_type` renvoie désormais l'en-tête Content-Type tel quel.

Auparavant, la valeur renvoyée par `ActionDispatch::Request#content_type` ne contenait PAS la partie charset.
Ce comportement a été modifié pour renvoyer l'en-tête Content-Type contenant la partie charset telle quelle.

Si vous souhaitez uniquement le type MIME, veuillez utiliser `ActionDispatch::Request#media_type` à la place.

Avant :

```ruby
request = ActionDispatch::Request.new("CONTENT_TYPE" => "text/csv; header=present; charset=utf-16", "REQUEST_METHOD" => "GET")
request.content_type #=> "text/csv"
```

Après :

```ruby
request = ActionDispatch::Request.new("Content-Type" => "text/csv; header=present; charset=utf-16", "REQUEST_METHOD" => "GET")
request.content_type #=> "text/csv; header=present; charset=utf-16"
request.media_type   #=> "text/csv"
```

### Le changement de classe de hachage du générateur de clés nécessite un rotateur de cookies

La classe de hachage par défaut du générateur de clés passe de SHA1 à SHA256.
Cela a des conséquences sur tout message chiffré généré par Rails, y compris
les cookies chiffrés.

Pour pouvoir lire les messages à l'aide de l'ancienne classe de hachage, il est nécessaire
d'enregistrer un rotateur. Ne pas le faire peut entraîner l'invalidation des sessions des utilisateurs lors de la mise à niveau.

Voici un exemple de rotateur pour les cookies chiffrés et signés.

```ruby
# config/initializers/cookie_rotator.rb
Rails.application.config.after_initialize do
  Rails.application.config.action_dispatch.cookies_rotations.tap do |cookies|
    authenticated_encrypted_cookie_salt = Rails.application.config.action_dispatch.authenticated_encrypted_cookie_salt
    signed_cookie_salt = Rails.application.config.action_dispatch.signed_cookie_salt

    secret_key_base = Rails.application.secret_key_base

    key_generator = ActiveSupport::KeyGenerator.new(
      secret_key_base, iterations: 1000, hash_digest_class: OpenSSL::Digest::SHA1
    )
    key_len = ActiveSupport::MessageEncryptor.key_len

    old_encrypted_secret = key_generator.generate_key(authenticated_encrypted_cookie_salt, key_len)
    old_signed_secret = key_generator.generate_key(signed_cookie_salt)

    cookies.rotate :encrypted, old_encrypted_secret
    cookies.rotate :signed, old_signed_secret
  end
end
```

### Changement de classe de hachage pour ActiveSupport::Digest en SHA256

La classe de hachage par défaut pour ActiveSupport::Digest passe de SHA1 à SHA256.
Cela a des conséquences sur des éléments tels que les Etags qui changeront ainsi que les clés de cache.
Le changement de ces clés peut avoir un impact sur les taux de réussite du cache, alors soyez prudent et surveillez cela lors de la mise à niveau vers le nouveau hachage.

### Nouveau format de sérialisation pour ActiveSupport::Cache

Un format de sérialisation plus rapide et plus compact a été introduit.

Pour l'activer, vous devez définir `config.active_support.cache_format_version = 7.0` :

```ruby
# config/application.rb

config.load_defaults 6.1
config.active_support.cache_format_version = 7.0
```

Ou simplement :

```ruby
# config/application.rb

config.load_defaults 7.0
```

Cependant, les applications Rails 6.1 ne peuvent pas lire ce nouveau format de sérialisation,
donc pour garantir une mise à niveau transparente, vous devez d'abord déployer votre mise à niveau Rails 7.0 avec
`config.active_support.cache_format_version = 6.1`, puis une fois que tous les processus Rails
ont été mis à jour, vous pouvez définir `config.active_support.cache_format_version = 7.0`.

Rails 7.0 est capable de lire les deux formats, donc le cache ne sera pas invalidé pendant la
mise à niveau.

### Génération d'une image de prévisualisation vidéo avec Active Storage

La génération d'une image de prévisualisation vidéo utilise maintenant la détection des changements de scène de FFmpeg pour générer
des images de prévisualisation plus significatives. Auparavant, la première image de la vidéo était utilisée
et cela posait des problèmes si la vidéo s'estompe du noir. Ce changement nécessite
FFmpeg v3.4+.

### Le processeur de variantes par défaut d'Active Storage a été modifié en `:vips`

Pour les nouvelles applications, la transformation d'images utilisera libvips au lieu d'ImageMagick. Cela réduira
le temps nécessaire pour générer des variantes ainsi que l'utilisation du CPU et de la mémoire, améliorant les temps de réponse
dans les applications qui utilisent Active Storage pour servir leurs images.

L'option `:mini_magick` n'est pas dépréciée, il est donc possible de continuer à l'utiliser.

Pour migrer une application existante vers libvips, définissez :
```ruby
Rails.application.config.active_storage.variant_processor = :vips
```

Vous devrez ensuite modifier le code de transformation d'image existant en utilisant les macros `image_processing` et remplacer les options d'ImageMagick par les options de libvips.

#### Remplacer resize par resize_to_limit

```diff
- variant(resize: "100x")
+ variant(resize_to_limit: [100, nil])
```

Si vous ne le faites pas, lorsque vous passez à vips, vous verrez cette erreur : `no implicit conversion to float from string`.

#### Utiliser un tableau lors du rognage

```diff
- variant(crop: "1920x1080+0+0")
+ variant(crop: [0, 0, 1920, 1080])
```

Si vous ne le faites pas lors de la migration vers vips, vous verrez l'erreur suivante : `unable to call crop: you supplied 2 arguments, but operation needs 5`.

#### Limitez les valeurs de rognage :

Vips est plus strict que ImageMagick en ce qui concerne le rognage :

1. Il ne rogne pas si `x` et/ou `y` sont des valeurs négatives. par exemple : `[-10, -10, 100, 100]`
2. Il ne rogne pas si la position (`x` ou `y`) plus la dimension de rognage (`width`, `height`) est plus grande que l'image. par exemple : une image de 125x125 et un rognage de `[50, 50, 100, 100]`

Si vous ne le faites pas lors de la migration vers vips, vous verrez l'erreur suivante : `extract_area: bad extract area`

#### Ajustez la couleur de fond utilisée pour `resize_and_pad`

Vips utilise le noir comme couleur de fond par défaut pour `resize_and_pad`, au lieu du blanc comme ImageMagick. Corrigez cela en utilisant l'option `background` :

```diff
- variant(resize_and_pad: [300, 300])
+ variant(resize_and_pad: [300, 300, background: [255]])
```

#### Supprimez toute rotation basée sur EXIF

Vips effectuera une rotation automatique des images en utilisant la valeur EXIF lors du traitement des variantes. Si vous stockiez des valeurs de rotation à partir de photos téléchargées par l'utilisateur pour appliquer une rotation avec ImageMagick, vous devez arrêter de le faire :

```diff
- variant(format: :jpg, rotate: rotation_value)
+ variant(format: :jpg)
```

#### Remplacez monochrome par colourspace

Vips utilise une option différente pour créer des images en noir et blanc :

```diff
- variant(monochrome: true)
+ variant(colourspace: "b-w")
```

#### Passez aux options de libvips pour la compression des images

JPEG

```diff
- variant(strip: true, quality: 80, interlace: "JPEG", sampling_factor: "4:2:0", colorspace: "sRGB")
+ variant(saver: { strip: true, quality: 80, interlace: true })
```

PNG

```diff
- variant(strip: true, quality: 75)
+ variant(saver: { strip: true, compression: 9 })
```

WEBP

```diff
- variant(strip: true, quality: 75, define: { webp: { lossless: false, alpha_quality: 85, thread_level: 1 } })
+ variant(saver: { strip: true, quality: 75, lossless: false, alpha_q: 85, reduction_effort: 6, smart_subsample: true })
```

GIF

```diff
- variant(layers: "Optimize")
+ variant(saver: { optimize_gif_frames: true, optimize_gif_transparency: true })
```

#### Déploiement en production

Active Storage encode dans l'URL de l'image la liste des transformations à effectuer. Si votre application met en cache ces URL, vos images seront cassées après le déploiement du nouveau code en production. Pour cette raison, vous devez invalider manuellement les clés de cache concernées.

Par exemple, si vous avez quelque chose comme ceci dans une vue :

```erb
<% @products.each do |product| %>
  <% cache product do %>
    <%= image_tag product.cover_photo.variant(resize: "200x") %>
  <% end %>
<% end %>
```

Vous pouvez invalider le cache en touchant le produit ou en modifiant la clé de cache :

```erb
<% @products.each do |product| %>
  <% cache ["v2", product] do %>
    <%= image_tag product.cover_photo.variant(resize_to_limit: [200, nil]) %>
  <% end %>
<% end %>
```

### La version de Rails est maintenant incluse dans le dump du schéma Active Record

Rails 7.0 a modifié certaines valeurs par défaut pour certains types de colonnes. Afin d'éviter que les applications passant de 6.1 à 7.0 chargent le schéma actuel en utilisant les nouvelles valeurs par défaut de 7.0, Rails inclut désormais la version du framework dans le dump du schéma.

Avant de charger le schéma pour la première fois dans Rails 7.0, assurez-vous d'exécuter `rails app:update` pour vous assurer que la version du schéma est incluse dans le dump du schéma.

Le fichier de schéma ressemblera à ceci :

```ruby
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[6.1].define(version: 2022_01_28_123512) do
```
NOTE: La première fois que vous déchargez le schéma avec Rails 7.0, vous verrez de nombreux changements dans ce fichier, y compris des informations sur les colonnes. Assurez-vous de passer en revue le contenu du nouveau fichier de schéma et de le valider dans votre référentiel.

Mise à niveau de Rails 6.0 vers Rails 6.1
----------------------------------------

Pour plus d'informations sur les modifications apportées à Rails 6.1, veuillez consulter les [notes de version](6_1_release_notes.html).

### La valeur de retour de `Rails.application.config_for` ne prend plus en charge l'accès avec des clés de type String.

Étant donné un fichier de configuration comme celui-ci :

```yaml
# config/example.yml
development:
  options:
    key: value
```

```ruby
Rails.application.config_for(:example).options
```

Cela renvoyait auparavant un hash sur lequel vous pouviez accéder aux valeurs avec des clés de type String. Cela a été déprécié dans la version 6.0 et ne fonctionne plus maintenant.

Vous pouvez appeler `with_indifferent_access` sur la valeur de retour de `config_for` si vous souhaitez toujours accéder aux valeurs avec des clés de type String, par exemple :

```ruby
Rails.application.config_for(:example).with_indifferent_access.dig('options', 'key')
```

### Le type de contenu de la réponse lors de l'utilisation de `respond_to#any`

L'en-tête Content-Type renvoyé dans la réponse peut différer de celui renvoyé par Rails 6.0, plus précisément si votre application utilise `respond_to { |format| format.any }`. Le type de contenu sera désormais basé sur le bloc donné plutôt que sur le format de la requête.

Exemple :

```ruby
def my_action
  respond_to do |format|
    format.any { render(json: { foo: 'bar' }) }
  end
end
```

```ruby
get('my_action.csv')
```

Le comportement précédent renvoyait un type de contenu de réponse `text/csv`, ce qui est incorrect car une réponse JSON est rendue. Le comportement actuel renvoie correctement un type de contenu de réponse `application/json`.

Si votre application dépend du comportement incorrect précédent, il est recommandé de spécifier les formats acceptés par votre action, par exemple :

```ruby
format.any(:xml, :json) { render request.format.to_sym => @people }
```

### `ActiveSupport::Callbacks#halted_callback_hook` reçoit maintenant un deuxième argument

Active Support vous permet de remplacer la méthode `halted_callback_hook` chaque fois qu'un rappel interrompt la chaîne. Cette méthode reçoit maintenant un deuxième argument qui est le nom du rappel interrompu. Si vous avez des classes qui remplacent cette méthode, assurez-vous qu'elle accepte deux arguments. Notez que c'est un changement de rupture sans cycle de dépréciation préalable (pour des raisons de performance).

Exemple :

```ruby
class Book < ApplicationRecord
  before_save { throw(:abort) }
  before_create { throw(:abort) }

  def halted_callback_hook(filter, callback_name) # => Cette méthode accepte maintenant 2 arguments au lieu de 1
    Rails.logger.info("Le livre n'a pas pu être #{callback_name}é")
  end
end
```

### La méthode de classe `helper` dans les contrôleurs utilise `String#constantize`

Conceptuellement, avant Rails 6.1

```ruby
helper "foo/bar"
```

donnait comme résultat

```ruby
require_dependency "foo/bar_helper"
module_name = "foo/bar_helper".camelize
module_name.constantize
```

Maintenant, cela fait plutôt ceci :

```ruby
prefix = "foo/bar".camelize
"#{prefix}Helper".constantize
```

Ce changement est rétrocompatible pour la majorité des applications, auquel cas vous n'avez rien à faire.

Techniquement, cependant, les contrôleurs pouvaient configurer `helpers_path` pour pointer vers un répertoire dans `$LOAD_PATH` qui n'était pas dans les chemins de chargement automatique. Ce cas d'utilisation n'est plus pris en charge par défaut. Si le module d'aide n'est pas chargé automatiquement, l'application est responsable de le charger avant d'appeler `helper`.

### La redirection vers HTTPS à partir de HTTP utilisera désormais le code d'état HTTP 308

Le code d'état HTTP par défaut utilisé dans `ActionDispatch::SSL` lors de la redirection des requêtes non-GET/HEAD de HTTP vers HTTPS a été changé en `308` tel que défini dans https://tools.ietf.org/html/rfc7538.

### Active Storage nécessite désormais Image Processing

Lors du traitement des variantes dans Active Storage, il est désormais nécessaire d'avoir le [gem image_processing](https://github.com/janko/image_processing) inclus au lieu d'utiliser directement `mini_magick`. Image Processing est configuré par défaut pour utiliser `mini_magick` en interne, donc la manière la plus simple de mettre à niveau est de remplacer le gem `mini_magick` par le gem `image_processing` et de vous assurer de supprimer l'utilisation explicite de `combine_options` car cela n'est plus nécessaire.

Pour plus de lisibilité, vous pouvez souhaiter changer les appels bruts à `resize` en macros `image_processing`. Par exemple, au lieu de :

```ruby
video.preview(resize: "100x100")
video.preview(resize: "100x100>")
video.preview(resize: "100x100^")
```

vous pouvez faire respectivement :

```ruby
video.preview(resize_to_fit: [100, 100])
video.preview(resize_to_limit: [100, 100])
video.preview(resize_to_fill: [100, 100])
```

### Nouvelle classe `ActiveModel::Error`

Les erreurs sont maintenant des instances d'une nouvelle classe `ActiveModel::Error`, avec des modifications apportées à l'API. Certaines de ces modifications peuvent générer des erreurs en fonction de la manière dont vous manipulez les erreurs, tandis que d'autres afficheront des avertissements de dépréciation à corriger pour Rails 7.0.

Plus d'informations sur ce changement et des détails sur les modifications de l'API peuvent être trouvés [dans ce PR](https://github.com/rails/rails/pull/32313).

Mise à niveau de Rails 5.2 vers Rails 6.0
----------------------------------------

Pour plus d'informations sur les modifications apportées à Rails 6.0, veuillez consulter les [notes de version](6_0_release_notes.html).

### Utilisation de Webpacker
[Webpacker](https://github.com/rails/webpacker)
est le compilateur JavaScript par défaut pour Rails 6. Mais si vous mettez à jour l'application, il n'est pas activé par défaut.
Si vous souhaitez utiliser Webpacker, incluez-le dans votre Gemfile et installez-le :

```ruby
gem "webpacker"
```

```bash
$ bin/rails webpacker:install
```

### Forcer SSL

La méthode `force_ssl` sur les contrôleurs a été dépréciée et sera supprimée dans Rails 6.1. Il est recommandé d'activer [`config.force_ssl`][] pour forcer les connexions HTTPS dans toute votre application. Si vous avez besoin d'exempter certains points de terminaison de la redirection, vous pouvez utiliser [`config.ssl_options`][] pour configurer ce comportement.


### Les métadonnées de but et d'expiration sont maintenant intégrées dans les cookies signés et chiffrés pour une sécurité accrue

Pour améliorer la sécurité, Rails intègre les métadonnées de but et d'expiration à l'intérieur de la valeur des cookies signés ou chiffrés.

Rails peut ainsi contrecarrer les attaques qui tentent de copier la valeur signée/chiffrée d'un cookie et de l'utiliser comme valeur d'un autre cookie.

Ces nouvelles métadonnées intégrées rendent ces cookies incompatibles avec les versions de Rails antérieures à 6.0.

Si vous avez besoin que vos cookies soient lus par Rails 5.2 et les versions antérieures, ou si vous validez toujours votre déploiement 6.0 et que vous souhaitez pouvoir revenir en arrière, définissez
`Rails.application.config.action_dispatch.use_cookies_with_metadata` sur `false`.

### Tous les packages npm ont été déplacés vers la portée `@rails`

Si vous chargiez précédemment les packages `actioncable`, `activestorage`,
ou `rails-ujs` via npm/yarn, vous devez mettre à jour les noms de ces
dépendances avant de pouvoir les mettre à niveau vers `6.0.0` :

```
actioncable   → @rails/actioncable
activestorage → @rails/activestorage
rails-ujs     → @rails/ujs
```

### Modifications de l'API JavaScript d'Action Cable

Le package JavaScript d'Action Cable a été converti de CoffeeScript
en ES2015, et nous publions maintenant le code source dans la distribution npm.

Cette version inclut quelques modifications de rupture des parties optionnelles de l'API JavaScript d'Action Cable :

- La configuration de l'adaptateur WebSocket et de l'adaptateur de journalisation a été déplacée
  des propriétés de `ActionCable` aux propriétés de `ActionCable.adapters`.
  Si vous configurez ces adaptateurs, vous devrez effectuer
  ces modifications :

    ```diff
    -    ActionCable.WebSocket = MyWebSocket
    +    ActionCable.adapters.WebSocket = MyWebSocket
    ```

    ```diff
    -    ActionCable.logger = myLogger
    +    ActionCable.adapters.logger = myLogger
    ```

- Les méthodes `ActionCable.startDebugging()` et `ActionCable.stopDebugging()`
  ont été supprimées et remplacées par la propriété
  `ActionCable.logger.enabled`. Si vous utilisez ces méthodes, vous
  devrez effectuer ces modifications :

    ```diff
    -    ActionCable.startDebugging()
    +    ActionCable.logger.enabled = true
    ```

    ```diff
    -    ActionCable.stopDebugging()
    +    ActionCable.logger.enabled = false
    ```

### `ActionDispatch::Response#content_type` renvoie maintenant l'en-tête Content-Type sans modification

Auparavant, la valeur renvoyée par `ActionDispatch::Response#content_type` ne contenait PAS la partie charset.
Ce comportement a été modifié pour inclure la partie charset précédemment omise.

Si vous souhaitez uniquement le type MIME, veuillez utiliser `ActionDispatch::Response#media_type` à la place.

Avant :

```ruby
resp = ActionDispatch::Response.new(200, "Content-Type" => "text/csv; header=present; charset=utf-16")
resp.content_type #=> "text/csv; header=present"
```

Après :

```ruby
resp = ActionDispatch::Response.new(200, "Content-Type" => "text/csv; header=present; charset=utf-16")
resp.content_type #=> "text/csv; header=present; charset=utf-16"
resp.media_type   #=> "text/csv"
```

### Nouveau paramètre `config.hosts`

Rails dispose maintenant d'un nouveau paramètre `config.hosts` à des fins de sécurité. Ce paramètre
est défini par défaut sur `localhost` en développement. Si vous utilisez d'autres domaines en développement,
vous devez les autoriser de cette manière :

```ruby
# config/environments/development.rb

config.hosts << 'dev.myapp.com'
config.hosts << /[a-z0-9-]+\.myapp\.com/ # Facultatif, les expressions régulières sont également autorisées
```

Pour les autres environnements, `config.hosts` est vide par défaut, ce qui signifie que Rails
ne valide pas du tout l'hôte. Vous pouvez éventuellement les ajouter si vous souhaitez
le valider en production.

### Chargement automatique

La configuration par défaut pour Rails 6

```ruby
# config/application.rb

config.load_defaults 6.0
```

active le mode de chargement automatique `zeitwerk` sur CRuby. Dans ce mode, le chargement automatique, le rechargement et le chargement anticipé sont gérés par [Zeitwerk](https://github.com/fxn/zeitwerk).

Si vous utilisez les valeurs par défaut d'une version précédente de Rails, vous pouvez activer zeitwerk comme ceci :

```ruby
# config/application.rb

config.autoloader = :zeitwerk
```

#### API publique

En général, les applications n'ont pas besoin d'utiliser l'API de Zeitwerk directement. Rails configure les choses selon le contrat existant : `config.autoload_paths`, `config.cache_classes`, etc.

Bien que les applications doivent respecter cette interface, l'objet de chargement réel de Zeitwerk peut être accédé via

```ruby
Rails.autoloaders.main
```

Cela peut être pratique si vous avez besoin de précharger des classes d'héritage de table unique (STI) ou de configurer un inflecteur personnalisé, par exemple.

#### Structure du projet

Si l'application en cours de mise à niveau se charge automatiquement correctement, la structure du projet devrait déjà être en grande partie compatible.

Cependant, le mode `classic` infère les noms de fichiers à partir des noms de constantes manquantes (`underscore`), tandis que le mode `zeitwerk` infère les noms de constantes à partir des noms de fichiers (`camelize`). Ces helpers ne sont pas toujours inverses l'un de l'autre, en particulier si des acronymes sont impliqués. Par exemple, `"FOO".underscore` est `"foo"`, mais `"foo".camelize` est `"Foo"`, pas `"FOO"`.
La compatibilité peut être vérifiée avec la tâche `zeitwerk:check` :

```bash
$ bin/rails zeitwerk:check
Attendez, je charge l'application.
Tout est bon !
```

#### require_dependency

Tous les cas d'utilisation connus de `require_dependency` ont été éliminés, vous devriez rechercher le projet et les supprimer.

Si votre application utilise l'héritage de table unique, veuillez consulter la section [Héritage de table unique](autoloading_and_reloading_constants.html#single-table-inheritance) du guide Autoloading and Reloading Constants (Zeitwerk Mode).

#### Noms qualifiés dans les définitions de classe et de module

Vous pouvez maintenant utiliser de manière robuste des chemins de constantes dans les définitions de classe et de module :

```ruby
# L'autoloading dans le corps de cette classe correspond maintenant à la sémantique de Ruby.
class Admin::UsersController < ApplicationController
  # ...
end
```

Un piège à connaître est que, selon l'ordre d'exécution, l'autoloader classique pouvait parfois charger `Foo::Wadus` dans

```ruby
class Foo::Bar
  Wadus
end
```

Cela ne correspond pas à la sémantique de Ruby car `Foo` n'est pas dans l'imbrication, et ne fonctionnera pas du tout en mode `zeitwerk`. Si vous rencontrez un tel cas particulier, vous pouvez utiliser le nom qualifié `Foo::Wadus` :

```ruby
class Foo::Bar
  Foo::Wadus
end
```

ou ajouter `Foo` à l'imbrication :

```ruby
module Foo
  class Bar
    Wadus
  end
end
```

#### Concerns

Vous pouvez charger automatiquement et charger de manière anticipée à partir d'une structure standard comme

```
app/models
app/models/concerns
```

Dans ce cas, `app/models/concerns` est considéré comme un répertoire racine (car il appartient aux chemins d'autoload), et il est ignoré en tant qu'espace de noms. Ainsi, `app/models/concerns/foo.rb` doit définir `Foo`, pas `Concerns::Foo`.

L'espace de noms `Concerns::` fonctionnait avec l'autoloader classique en tant qu'effet secondaire de la mise en œuvre, mais ce n'était pas vraiment un comportement voulu. Une application utilisant `Concerns::` doit renommer ces classes et modules pour pouvoir s'exécuter en mode `zeitwerk`.

#### Présence de `app` dans les chemins d'autoload

Certains projets veulent que quelque chose comme `app/api/base.rb` définisse `API::Base`, et ajoutent `app` aux chemins d'autoload pour y parvenir en mode `classic`. Étant donné que Rails ajoute automatiquement tous les sous-répertoires de `app` aux chemins d'autoload, nous avons une autre situation dans laquelle il y a des répertoires racines imbriqués, de sorte que cette configuration ne fonctionne plus. Le même principe que celui que nous avons expliqué ci-dessus avec `concerns`.

Si vous souhaitez conserver cette structure, vous devrez supprimer le sous-répertoire des chemins d'autoload dans un initialiseur :

```ruby
ActiveSupport::Dependencies.autoload_paths.delete("#{Rails.root}/app/api")
```

#### Constantes autoloadées et espaces de noms explicites

Si un espace de noms est défini dans un fichier, comme `Hotel` ici :

```
app/models/hotel.rb         # Définit Hotel.
app/models/hotel/pricing.rb # Définit Hotel::Pricing.
```

la constante `Hotel` doit être définie à l'aide des mots-clés `class` ou `module`. Par exemple :

```ruby
class Hotel
end
```

est bon.

Des alternatives comme

```ruby
Hotel = Class.new
```

ou

```ruby
Hotel = Struct.new
```

ne fonctionneront pas, les objets enfants comme `Hotel::Pricing` ne seront pas trouvés.

Cette restriction s'applique uniquement aux espaces de noms explicites. Les classes et modules ne définissant pas d'espace de noms peuvent être définis en utilisant ces idiomes.

#### Un fichier, une constante (au même niveau supérieur)

En mode `classic`, vous pouviez techniquement définir plusieurs constantes au même niveau supérieur et les recharger toutes. Par exemple, étant donné

```ruby
# app/models/foo.rb

class Foo
end

class Bar
end
```

alors que `Bar` ne pouvait pas être autoloadé, le chargement automatique de `Foo` marquerait également `Bar` comme étant chargé automatiquement. Ce n'est pas le cas en mode `zeitwerk`, vous devez déplacer `Bar` dans son propre fichier `bar.rb`. Un fichier, une constante.

Cela ne s'applique qu'aux constantes au même niveau supérieur que dans l'exemple ci-dessus. Les classes et modules internes sont acceptés. Par exemple, considérez

```ruby
# app/models/foo.rb

class Foo
  class InnerClass
  end
end
```

Si l'application recharge `Foo`, elle rechargera également `Foo::InnerClass`.

#### Spring et l'environnement `test`

Spring recharge le code de l'application si quelque chose change. Dans l'environnement `test`, vous devez activer le rechargement pour que cela fonctionne :

```ruby
# config/environments/test.rb

config.cache_classes = false
```

Sinon, vous obtiendrez cette erreur :

```
le rechargement est désactivé car config.cache_classes est true
```

#### Bootsnap

Bootsnap doit être au moins en version 1.4.2.

En plus de cela, Bootsnap doit désactiver le cache iseq en raison d'un bogue dans l'interpréteur si Ruby 2.5 est utilisé. Assurez-vous donc de dépendre d'au moins Bootsnap 1.4.4 dans ce cas.

#### `config.add_autoload_paths_to_load_path`

Le nouveau point de configuration [`config.add_autoload_paths_to_load_path`][] est `true` par défaut pour assurer la compatibilité ascendante, mais vous permet de désactiver l'ajout des chemins d'autoload à `$LOAD_PATH`.

Cela a du sens dans la plupart des applications, car vous ne devriez jamais avoir besoin de requérir un fichier dans `app/models`, par exemple, et Zeitwerk n'utilise que des noms de fichiers absolus en interne.
En optant pour la désactivation, vous optimisez les recherches `$LOAD_PATH` (moins de répertoires à vérifier) et vous économisez le travail et la consommation de mémoire de Bootsnap, car il n'a pas besoin de construire un index pour ces répertoires.


#### Sécurité des threads

En mode classique, le chargement automatique des constantes n'est pas sûr pour les threads, bien que Rails dispose de verrous en place, par exemple pour rendre les requêtes web sûres pour les threads lorsque le chargement automatique est activé, comme c'est courant dans l'environnement de développement.

Le chargement automatique des constantes est sûr pour les threads en mode `zeitwerk`. Par exemple, vous pouvez maintenant charger automatiquement dans des scripts multi-thread exécutés par la commande `runner`.

#### Globs dans config.autoload_paths

Attention aux configurations comme

```ruby
config.autoload_paths += Dir["#{config.root}/lib/**/"]
```

Chaque élément de `config.autoload_paths` doit représenter l'espace de noms de niveau supérieur (`Object`) et ils ne peuvent pas être imbriqués en conséquence (à l'exception des répertoires `concerns` expliqués ci-dessus).

Pour corriger cela, supprimez simplement les caractères génériques :

```ruby
config.autoload_paths << "#{config.root}/lib"
```

#### Le chargement anticipé et le chargement automatique sont cohérents

En mode `classique`, si `app/models/foo.rb` définit `Bar`, vous ne pourrez pas charger automatiquement ce fichier, mais le chargement anticipé fonctionnera car il charge les fichiers de manière récursive aveugle. Cela peut être une source d'erreurs si vous testez d'abord le chargement anticipé, l'exécution peut échouer plus tard lors du chargement automatique.

En mode `zeitwerk`, les deux modes de chargement sont cohérents, ils échouent et génèrent des erreurs dans les mêmes fichiers.

#### Comment utiliser le chargeur automatique classique dans Rails 6

Les applications peuvent charger les valeurs par défaut de Rails 6 et utiliser toujours le chargeur automatique classique en définissant `config.autoloader` de cette manière :

```ruby
# config/application.rb

config.load_defaults 6.0
config.autoloader = :classic
```

Lors de l'utilisation du chargeur automatique classique dans une application Rails 6, il est recommandé de définir le niveau de concurrence sur 1 dans l'environnement de développement, pour les serveurs web et les processeurs en arrière-plan, en raison des problèmes de sécurité des threads.

### Changement de comportement de l'assignation de Active Storage

Avec les valeurs par défaut de configuration pour Rails 5.2, l'assignation à une collection de pièces jointes déclarées avec `has_many_attached` ajoute de nouveaux fichiers :

```ruby
class User < ApplicationRecord
  has_many_attached :highlights
end

user.highlights.attach(filename: "funky.jpg", ...)
user.highlights.count # => 1

blob = ActiveStorage::Blob.create_after_upload!(filename: "town.jpg", ...)
user.update!(highlights: [ blob ])

user.highlights.count # => 2
user.highlights.first.filename # => "funky.jpg"
user.highlights.second.filename # => "town.jpg"
```

Avec les valeurs par défaut de configuration pour Rails 6.0, l'assignation à une collection de pièces jointes remplace les fichiers existants au lieu de les ajouter. Cela correspond au comportement d'Active Record lors de l'assignation à une association de collection :

```ruby
user.highlights.attach(filename: "funky.jpg", ...)
user.highlights.count # => 1

blob = ActiveStorage::Blob.create_after_upload!(filename: "town.jpg", ...)
user.update!(highlights: [ blob ])

user.highlights.count # => 1
user.highlights.first.filename # => "town.jpg"
```

`#attach` peut être utilisé pour ajouter de nouvelles pièces jointes sans supprimer les existantes :

```ruby
blob = ActiveStorage::Blob.create_after_upload!(filename: "town.jpg", ...)
user.highlights.attach(blob)

user.highlights.count # => 2
user.highlights.first.filename # => "funky.jpg"
user.highlights.second.filename # => "town.jpg"
```

Les applications existantes peuvent opter pour ce nouveau comportement en définissant [`config.active_storage.replace_on_assign_to_many`][] sur `true`. L'ancien comportement sera déprécié dans Rails 7.0 et supprimé dans Rails 7.1.


### Applications de gestion d'exceptions personnalisées

Les en-têtes de requête `Accept` ou `Content-Type` invalides lèveront désormais une exception.
La configuration par défaut [`config.exceptions_app`][] gère spécifiquement cette erreur et la compense.
Les applications d'exceptions personnalisées devront également gérer cette erreur, sinon ces requêtes provoqueront l'utilisation de l'application d'exceptions de secours de Rails, qui renvoie une `500 Internal Server Error`.


Mise à niveau de Rails 5.1 à Rails 5.2
-------------------------------------

Pour plus d'informations sur les modifications apportées à Rails 5.2, veuillez consulter les [notes de version](5_2_release_notes.html).

### Bootsnap

Rails 5.2 ajoute la gem bootsnap dans le [Gemfile de l'application nouvellement générée](https://github.com/rails/rails/pull/29313).
La commande `app:update` le configure dans `boot.rb`. Si vous souhaitez l'utiliser, ajoutez-le dans le Gemfile :

```ruby
# Réduit les temps de démarrage grâce à la mise en cache ; requis dans config/boot.rb
gem 'bootsnap', require: false
```

Sinon, modifiez le `boot.rb` pour ne pas utiliser bootsnap.

### L'expiration dans les cookies signés ou chiffrés est maintenant intégrée dans les valeurs des cookies

Pour améliorer la sécurité, Rails intègre désormais les informations d'expiration également dans la valeur des cookies signés ou chiffrés.

Ces nouvelles informations intégrées rendent ces cookies incompatibles avec les versions de Rails antérieures à 5.2.

Si vous avez besoin que vos cookies soient lus par la version 5.1 et les versions antérieures, ou si vous validez toujours votre déploiement 5.2 et que vous souhaitez vous permettre de revenir en arrière, définissez
`Rails.application.config.action_dispatch.use_authenticated_cookie_encryption` sur `false`.

Mise à niveau de Rails 5.0 à Rails 5.1
-------------------------------------

Pour plus d'informations sur les modifications apportées à Rails 5.1, veuillez consulter les [notes de version](5_1_release_notes.html).

### La classe `HashWithIndifferentAccess` de niveau supérieur est en cours de dépréciation

Si votre application utilise la classe `HashWithIndifferentAccess` de niveau supérieur, vous devez progressivement modifier votre code pour utiliser plutôt `ActiveSupport::HashWithIndifferentAccess`.
Il est seulement obsolète, ce qui signifie que votre code ne se cassera pas pour le moment et aucun avertissement d'obsolescence ne sera affiché, mais cette constante sera supprimée à l'avenir.

De plus, si vous avez de très anciens documents YAML contenant des sauvegardes de tels objets, vous devrez peut-être les charger et les sauvegarder à nouveau pour vous assurer qu'ils font référence à la bonne constante et que leur chargement ne se cassera pas à l'avenir.

### `application.secrets` maintenant chargé avec toutes les clés en tant que symboles

Si votre application stocke une configuration imbriquée dans `config/secrets.yml`, toutes les clés sont maintenant chargées en tant que symboles, donc l'accès en utilisant des chaînes de caractères doit être modifié.

De :

```ruby
Rails.application.secrets[:smtp_settings]["address"]
```

À :

```ruby
Rails.application.secrets[:smtp_settings][:address]
```

### Suppression du support obsolète de `:text` et `:nothing` dans `render`

Si vos contrôleurs utilisent `render :text`, cela ne fonctionnera plus. La nouvelle méthode pour rendre du texte avec le type MIME `text/plain` est d'utiliser `render :plain`.

De même, `render :nothing` est également supprimé et vous devez utiliser la méthode `head` pour envoyer des réponses ne contenant que des en-têtes. Par exemple, `head :ok` envoie une réponse 200 sans corps à rendre.

### Suppression du support obsolète de `redirect_to :back`

Dans Rails 5.0, `redirect_to :back` a été déprécié. Dans Rails 5.1, il a été complètement supprimé.

Comme alternative, utilisez `redirect_back`. Il est important de noter que `redirect_back` prend également une option `fallback_location` qui sera utilisée si `HTTP_REFERER` est manquant.

```ruby
redirect_back(fallback_location: root_path)
```


Mise à niveau de Rails 4.2 vers Rails 5.0
-------------------------------------

Pour plus d'informations sur les modifications apportées à Rails 5.0, veuillez consulter les [notes de version](5_0_release_notes.html).

### Ruby 2.2.2+ requis

À partir de Ruby on Rails 5.0, Ruby 2.2.2+ est la seule version de Ruby prise en charge. Assurez-vous d'utiliser la version 2.2.2 de Ruby ou une version supérieure avant de continuer.

### Les modèles Active Record héritent maintenant de ApplicationRecord par défaut

Dans Rails 4.2, un modèle Active Record hérite de `ActiveRecord::Base`. Dans Rails 5.0, tous les modèles héritent de `ApplicationRecord`.

`ApplicationRecord` est une nouvelle superclasse pour tous les modèles d'application, analogue aux contrôleurs d'application qui héritent de `ApplicationController` au lieu de `ActionController::Base`. Cela permet aux applications de configurer le comportement des modèles à l'échelle de l'application.

Lors de la mise à niveau de Rails 4.2 vers Rails 5.0, vous devez créer un fichier `application_record.rb` dans `app/models/` et y ajouter le contenu suivant :

```ruby
class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true
end
```

Ensuite, assurez-vous que tous vos modèles en héritent.

### Interruption des chaînes de rappel via `throw(:abort)`

Dans Rails 4.2, lorsque le rappel 'before' renvoie `false` dans Active Record et Active Model, toute la chaîne de rappels est interrompue. En d'autres termes, les rappels 'before' successifs ne sont pas exécutés, et l'action enveloppée dans les rappels ne l'est pas non plus.

Dans Rails 5.0, renvoyer `false` dans un rappel Active Record ou Active Model n'aura pas cet effet secondaire d'interruption de la chaîne de rappels. Au lieu de cela, les chaînes de rappels doivent être explicitement interrompues en appelant `throw(:abort)`.

Lorsque vous effectuez la mise à niveau de Rails 4.2 vers Rails 5.0, renvoyer `false` dans ce type de rappels interrompra toujours la chaîne de rappels, mais vous recevrez un avertissement de dépréciation concernant ce changement à venir.

Lorsque vous êtes prêt, vous pouvez opter pour le nouveau comportement et supprimer l'avertissement de dépréciation en ajoutant la configuration suivante à votre `config/application.rb` :

```ruby
ActiveSupport.halt_callback_chains_on_return_false = false
```

Notez que cette option n'affectera pas les rappels Active Support car ils n'ont jamais interrompu la chaîne lorsqu'une valeur était renvoyée.

Voir [#17227](https://github.com/rails/rails/pull/17227) pour plus de détails.

### ActiveJob hérite maintenant de ApplicationJob par défaut

Dans Rails 4.2, un Active Job hérite de `ActiveJob::Base`. Dans Rails 5.0, ce comportement a changé pour hériter maintenant de `ApplicationJob`.

Lors de la mise à niveau de Rails 4.2 vers Rails 5.0, vous devez créer un fichier `application_job.rb` dans `app/jobs/` et y ajouter le contenu suivant :

```ruby
class ApplicationJob < ActiveJob::Base
end
```

Ensuite, assurez-vous que toutes vos classes de tâches héritent de celle-ci.

Voir [#19034](https://github.com/rails/rails/pull/19034) pour plus de détails.

### Tests de contrôleurs Rails

#### Extraction de certaines méthodes d'aide vers `rails-controller-testing`

`assigns` et `assert_template` ont été extraites vers la gemme `rails-controller-testing`. Pour continuer à utiliser ces méthodes dans vos tests de contrôleurs, ajoutez `gem 'rails-controller-testing'` à votre `Gemfile`.

Si vous utilisez RSpec pour les tests, veuillez consulter la documentation de la gemme pour connaître la configuration supplémentaire requise.

#### Nouveau comportement lors du téléchargement de fichiers

Si vous utilisez `ActionDispatch::Http::UploadedFile` dans vos tests pour télécharger des fichiers, vous devrez changer pour utiliser la classe similaire `Rack::Test::UploadedFile`.
Voir [#26404](https://github.com/rails/rails/issues/26404) pour plus de détails.

### Le chargement automatique est désactivé après le démarrage dans l'environnement de production

Le chargement automatique est maintenant désactivé après le démarrage dans l'environnement de production par défaut.

Le chargement anticipé de l'application fait partie du processus de démarrage, donc les constantes de niveau supérieur sont correctes et sont toujours chargées automatiquement, il n'est pas nécessaire de nécessiter leurs fichiers.

Les constantes dans des endroits plus profonds exécutées uniquement à l'exécution, comme les corps de méthode réguliers, sont également correctes car le fichier les définissant aura été chargé de manière anticipée lors du démarrage.

Pour la grande majorité des applications, ce changement ne nécessite aucune action. Mais dans le cas très rare où votre application a besoin du chargement automatique pendant son exécution en production, définissez `Rails.application.config.enable_dependency_loading` sur true.

### Serialization XML

`ActiveModel::Serializers::Xml` a été extrait de Rails vers le gem `activemodel-serializers-xml`. Pour continuer à utiliser la sérialisation XML dans votre application, ajoutez `gem 'activemodel-serializers-xml'` à votre `Gemfile`.

### Support supprimé pour l'adaptateur de base de données `mysql` obsolète

Rails 5 supprime le support de l'adaptateur de base de données `mysql` obsolète. La plupart des utilisateurs devraient pouvoir utiliser `mysql2` à la place. Il sera converti en un gem séparé lorsque nous trouverons quelqu'un pour le maintenir.

### Support supprimé pour le débogueur

`debugger` n'est pas pris en charge par Ruby 2.2, qui est requis par Rails 5. Utilisez plutôt `byebug`.

### Utilisez `bin/rails` pour exécuter des tâches et des tests

Rails 5 ajoute la possibilité d'exécuter des tâches et des tests via `bin/rails` au lieu de rake. En général, ces changements sont parallèles à rake, mais certains ont été portés en même temps.

Pour utiliser le nouveau test runner, tapez simplement `bin/rails test`.

`rake dev:cache` est maintenant `bin/rails dev:cache`.

Exécutez `bin/rails` à l'intérieur du répertoire racine de votre application pour voir la liste des commandes disponibles.

### `ActionController::Parameters` n'hérite plus de `HashWithIndifferentAccess`

Appeler `params` dans votre application renverra maintenant un objet au lieu d'un hash. Si vos paramètres sont déjà autorisés, vous n'aurez pas besoin de faire de changements. Si vous utilisez `map` et d'autres méthodes qui dépendent de la possibilité de lire le hash indépendamment de `permitted?`, vous devrez mettre à niveau votre application pour d'abord autoriser puis convertir en un hash.

```ruby
params.permit([:proceed_to, :return_to]).to_h
```

### `protect_from_forgery` a maintenant la valeur par défaut `prepend: false`

`protect_from_forgery` a maintenant la valeur par défaut `prepend: false`, ce qui signifie qu'il sera inséré dans la chaîne de rappel au point où vous l'appelez dans votre application. Si vous voulez que `protect_from_forgery` s'exécute toujours en premier, vous devez modifier votre application pour utiliser `protect_from_forgery prepend: true`.

### Le gestionnaire de modèle par défaut est maintenant RAW

Les fichiers sans gestionnaire de modèle dans leur extension seront rendus en utilisant le gestionnaire RAW. Auparavant, Rails rendait les fichiers en utilisant le gestionnaire de modèle ERB.

Si vous ne voulez pas que votre fichier soit traité via le gestionnaire RAW, vous devez ajouter une extension à votre fichier qui peut être analysée par le gestionnaire de modèle approprié.

### Ajout de la correspondance générique pour les dépendances de modèle

Vous pouvez maintenant utiliser la correspondance générique pour les dépendances de modèle. Par exemple, si vous définissiez vos modèles de la manière suivante :

```erb
<% # Dépendance de modèle : recordings/threads/events/subscribers_changed %>
<% # Dépendance de modèle : recordings/threads/events/completed %>
<% # Dépendance de modèle : recordings/threads/events/uncompleted %>
```

Vous pouvez maintenant appeler la dépendance une seule fois avec un joker.

```erb
<% # Dépendance de modèle : recordings/threads/events/* %>
```

### `ActionView::Helpers::RecordTagHelper` déplacé vers le gem externe (record_tag_helper)

`content_tag_for` et `div_for` ont été supprimés au profit de l'utilisation de `content_tag` uniquement. Pour continuer à utiliser les anciennes méthodes, ajoutez le gem `record_tag_helper` à votre `Gemfile` :

```ruby
gem 'record_tag_helper', '~> 1.0'
```

Voir [#18411](https://github.com/rails/rails/pull/18411) pour plus de détails.

### Support supprimé pour le gem `protected_attributes`

Le gem `protected_attributes` n'est plus pris en charge dans Rails 5.

### Support supprimé pour le gem `activerecord-deprecated_finders`

Le gem `activerecord-deprecated_finders` n'est plus pris en charge dans Rails 5.

### L'ordre de test par défaut de `ActiveSupport::TestCase` est maintenant aléatoire

Lorsque les tests sont exécutés dans votre application, l'ordre par défaut est maintenant `:random` au lieu de `:sorted`. Utilisez l'option de configuration suivante pour le remettre à `:sorted`.

```ruby
# config/environments/test.rb
Rails.application.configure do
  config.active_support.test_order = :sorted
end
```

### `ActionController::Live` est devenu un `Concern`

Si vous incluez `ActionController::Live` dans un autre module qui est inclus dans votre contrôleur, vous devez également étendre le module avec `ActiveSupport::Concern`. Alternativement, vous pouvez utiliser le crochet `self.included` pour inclure `ActionController::Live` directement dans le contrôleur une fois que `StreamingSupport` est inclus.

Cela signifie que si votre application avait auparavant son propre module de streaming, le code suivant ne fonctionnerait plus en production :
```ruby
# Ceci est une solution de contournement pour les contrôleurs en streaming effectuant une authentification avec Warden/Devise.
# Voir https://github.com/plataformatec/devise/issues/2332
# L'authentification dans le routeur est une autre solution comme suggéré dans cet issue
class StreamingSupport
  include ActionController::Live # cela ne fonctionnera pas en production pour Rails 5
  # extend ActiveSupport::Concern # à moins que vous ne décommentiez cette ligne.

  def process(name)
    super(name)
  rescue ArgumentError => e
    if e.message == 'uncaught throw :warden'
      throw :warden
    else
      raise e
    end
  end
end
```

### Nouvelles valeurs par défaut du framework

#### Option `belongs_to` requise par défaut pour Active Record

`belongs_to` déclenchera désormais une erreur de validation par défaut si l'association n'est pas présente.

Cela peut être désactivé par association avec `optional: true`.

Cette valeur par défaut sera automatiquement configurée dans les nouvelles applications. Si une application existante
veut ajouter cette fonctionnalité, elle devra l'activer dans un initialiseur :

```ruby
config.active_record.belongs_to_required_by_default = true
```

La configuration est par défaut globale pour tous vos modèles, mais vous pouvez
la remplacer pour chaque modèle individuellement. Cela devrait vous aider à migrer tous vos modèles pour qu'ils aient leurs
associations requises par défaut.

```ruby
class Book < ApplicationRecord
  # le modèle n'est pas encore prêt à avoir son association requise par défaut

  self.belongs_to_required_by_default = false
  belongs_to(:author)
end

class Car < ApplicationRecord
  # le modèle est prêt à avoir son association requise par défaut

  self.belongs_to_required_by_default = true
  belongs_to(:pilot)
end
```

#### Jetons CSRF par formulaire

Rails 5 prend désormais en charge les jetons CSRF par formulaire pour atténuer les attaques par injection de code avec des formulaires
créés par JavaScript. Avec cette option activée, les formulaires de votre application auront chacun leur
propre jeton CSRF spécifique à l'action et à la méthode de ce formulaire.

```ruby
config.action_controller.per_form_csrf_tokens = true
```

#### Protection contre les usurpations d'identité avec vérification de l'origine

Vous pouvez maintenant configurer votre application pour vérifier si l'en-tête HTTP `Origin` doit être vérifié
par rapport à l'origine du site en tant que défense CSRF supplémentaire. Définissez le paramètre suivant dans votre configuration pour
true :

```ruby
config.action_controller.forgery_protection_origin_check = true
```

#### Autoriser la configuration du nom de la file d'attente d'Action Mailer

Le nom de file d'attente par défaut des mailers est `mailers`. Cette option de configuration vous permet de changer globalement
le nom de la file d'attente. Définissez le paramètre suivant dans votre configuration :

```ruby
config.action_mailer.deliver_later_queue_name = :new_queue_name
```

#### Prise en charge de la mise en cache de fragments dans les vues d'Action Mailer

Définissez [`config.action_mailer.perform_caching`][] dans votre configuration pour déterminer si vos vues d'Action Mailer
doivent prendre en charge la mise en cache.

```ruby
config.action_mailer.perform_caching = true
```

#### Configuration de la sortie de `db:structure:dump`

Si vous utilisez `schema_search_path` ou d'autres extensions PostgreSQL, vous pouvez contrôler la façon dont le schéma est
dumpé. Définissez `:all` pour générer tous les dumps, ou `:schema_search_path` pour générer à partir du chemin de recherche du schéma.

```ruby
config.active_record.dump_schemas = :all
```

#### Configuration des options SSL pour activer HSTS avec les sous-domaines

Définissez le paramètre suivant dans votre configuration pour activer HSTS lors de l'utilisation de sous-domaines :

```ruby
config.ssl_options = { hsts: { subdomains: true } }
```

#### Préservation du fuseau horaire du destinataire

Lors de l'utilisation de Ruby 2.4, vous pouvez préserver le fuseau horaire du destinataire lors de l'appel à `to_time`.

```ruby
ActiveSupport.to_time_preserves_timezone = false
```

### Modifications de la sérialisation JSON/JSONB

Dans Rails 5.0, la façon dont les attributs JSON/JSONB sont sérialisés et désérialisés a changé. Maintenant, si
vous définissez une colonne égale à une `String`, Active Record ne transformera plus cette chaîne
en `Hash`, et ne renverra que la chaîne. Cela ne se limite pas au code
interagissant avec les modèles, mais affecte également les paramètres de colonne `:default` dans `db/schema.rb`.
Il est recommandé de ne pas définir les colonnes égales à une `String`, mais de passer plutôt un `Hash`
qui sera automatiquement converti en une chaîne JSON et vice versa.

Mise à niveau de Rails 4.1 à Rails 4.2
-------------------------------------

### Console Web

Tout d'abord, ajoutez `gem 'web-console', '~> 2.0'` au groupe `:development` de votre `Gemfile` et exécutez `bundle install` (il n'a pas été inclus lors de la mise à niveau de Rails). Une fois installé, vous pouvez simplement ajouter une référence à l'aide de la console (c'est-à-dire `<%= console %>`) dans n'importe quelle vue pour l'activer. Une console sera également disponible sur n'importe quelle page d'erreur que vous consultez dans votre environnement de développement.

### Répondeurs

`respond_with` et les méthodes `respond_to` au niveau de la classe ont été extraites dans la gemme `responders`. Pour les utiliser, ajoutez simplement `gem 'responders', '~> 2.0'` à votre `Gemfile`. Les appels à `respond_with` et `respond_to` (encore une fois, au niveau de la classe) ne fonctionneront plus sans avoir inclus la gemme `responders` dans vos dépendances :
```ruby
# app/controllers/users_controller.rb

class UsersController < ApplicationController
  respond_to :html, :json

  def show
    @user = User.find(params[:id])
    respond_with @user
  end
end
```

Le niveau d'instance `respond_to` n'est pas affecté et ne nécessite pas de gemme supplémentaire :

```ruby
# app/controllers/users_controller.rb

class UsersController < ApplicationController
  def show
    @user = User.find(params[:id])
    respond_to do |format|
      format.html
      format.json { render json: @user }
    end
  end
end
```

Voir [#16526](https://github.com/rails/rails/pull/16526) pour plus de détails.

### Gestion des erreurs dans les rappels de transaction

Actuellement, Active Record supprime les erreurs levées dans les rappels `after_rollback` ou `after_commit` et les affiche uniquement dans les journaux. Dans la prochaine version, ces erreurs ne seront plus supprimées. Au lieu de cela, les erreurs se propageront normalement, comme dans les autres rappels Active Record.

Lorsque vous définissez un rappel `after_rollback` ou `after_commit`, vous recevrez un avertissement de dépréciation concernant ce changement à venir. Lorsque vous êtes prêt, vous pouvez opter pour le nouveau comportement et supprimer l'avertissement de dépréciation en ajoutant la configuration suivante à votre `config/application.rb` :

```ruby
config.active_record.raise_in_transactional_callbacks = true
```

Voir [#14488](https://github.com/rails/rails/pull/14488) et
[#16537](https://github.com/rails/rails/pull/16537) pour plus de détails.

### Ordre des cas de test

Dans Rails 5.0, les cas de test seront exécutés dans un ordre aléatoire par défaut. En prévision de ce changement, Rails 4.2 a introduit une nouvelle option de configuration `active_support.test_order` pour spécifier explicitement l'ordre des tests. Cela vous permet de verrouiller le comportement actuel en définissant l'option sur `:sorted`, ou d'opter pour le comportement futur en définissant l'option sur `:random`.

Si vous ne spécifiez pas de valeur pour cette option, un avertissement de dépréciation sera émis. Pour éviter cela, ajoutez la ligne suivante à votre environnement de test :

```ruby
# config/environments/test.rb
Rails.application.configure do
  config.active_support.test_order = :sorted # ou `:random` si vous préférez
end
```

### Attributs sérialisés

Lors de l'utilisation d'un codeur personnalisé (par exemple, `serialize :metadata, JSON`), l'assignation de `nil` à un attribut sérialisé l'enregistrera dans la base de données en tant que `NULL` au lieu de passer la valeur `nil` par le codeur (par exemple, `"null"` lors de l'utilisation du codeur `JSON`).

### Niveau de journalisation en production

Dans Rails 5, le niveau de journalisation par défaut pour l'environnement de production sera modifié en `:debug` (au lieu de `:info`). Pour conserver le niveau par défaut actuel, ajoutez la ligne suivante à votre `production.rb` :

```ruby
# Définissez sur `:info` pour correspondre au niveau par défaut actuel, ou sur `:debug` pour opter pour le niveau par défaut futur.
config.log_level = :info
```

### `after_bundle` dans les modèles Rails

Si vous avez un modèle Rails qui ajoute tous les fichiers dans le contrôle de version, il échoue à ajouter les binstubs générés car il est exécuté avant Bundler :

```ruby
# template.rb
generate(:scaffold, "person name:string")
route "root to: 'people#index'"
rake("db:migrate")

git :init
git add: "."
git commit: %Q{ -m 'Initial commit' }
```

Vous pouvez maintenant envelopper les appels `git` dans un bloc `after_bundle`. Il sera exécuté après la génération des binstubs.

```ruby
# template.rb
generate(:scaffold, "person name:string")
route "root to: 'people#index'"
rake("db:migrate")

after_bundle do
  git :init
  git add: "."
  git commit: %Q{ -m 'Initial commit' }
end
```

### Rails HTML Sanitizer

Il existe un nouveau choix pour la désinfection des fragments HTML dans vos applications. L'approche vénérable de l'analyseur HTML est maintenant officiellement dépréciée au profit de [`Rails HTML Sanitizer`](https://github.com/rails/rails-html-sanitizer).

Cela signifie que les méthodes `sanitize`, `sanitize_css`, `strip_tags` et `strip_links` sont basées sur une nouvelle implémentation.

Ce nouveau désinfectant utilise [Loofah](https://github.com/flavorjones/loofah) en interne. Loofah utilise à son tour Nokogiri, qui enveloppe des analyseurs XML écrits en C et en Java, de sorte que la désinfection devrait être plus rapide, quelle que soit la version de Ruby que vous utilisez.

La nouvelle version met à jour `sanitize`, de sorte qu'il peut prendre un `Loofah::Scrubber` pour un nettoyage puissant.
[Voir quelques exemples de scrubbers ici](https://github.com/flavorjones/loofah#loofahscrubber).

Deux nouveaux scrubbers ont également été ajoutés : `PermitScrubber` et `TargetScrubber`.
Consultez la [documentation de la gem](https://github.com/rails/rails-html-sanitizer) pour plus d'informations.

La documentation de `PermitScrubber` et `TargetScrubber` explique comment vous pouvez avoir un contrôle complet sur quand et comment les éléments doivent être supprimés.

Si votre application a besoin d'utiliser l'ancienne implémentation du désinfectant, incluez `rails-deprecated_sanitizer` dans votre `Gemfile` :

```ruby
gem 'rails-deprecated_sanitizer'
```

### Rails DOM Testing

Le module [`TagAssertions`](https://api.rubyonrails.org/v4.1/classes/ActionDispatch/Assertions/TagAssertions.html) (contenant des méthodes telles que `assert_tag`), [a été déprécié](https://github.com/rails/rails/blob/6061472b8c310158a2a2e8e9a6b81a1aef6b60fe/actionpack/lib/action_dispatch/testing/assertions/dom.rb) en faveur des méthodes `assert_select` du module `SelectorAssertions`, qui a été extrait dans la [gemme rails-dom-testing](https://github.com/rails/rails-dom-testing).

### Jetons d'authenticité masqués

Afin de lutter contre les attaques SSL, `form_authenticity_token` est maintenant masqué de sorte qu'il varie à chaque requête. Ainsi, les jetons sont validés en les démasquant puis en les déchiffrant. Par conséquent, toutes les stratégies de vérification des requêtes à partir de formulaires non-Rails qui reposaient sur un jeton CSRF de session statique doivent en tenir compte.
### Action Mailer

Auparavant, l'appel d'une méthode de mailer sur une classe de mailer entraînait l'exécution directe de la méthode d'instance correspondante. Avec l'introduction de Active Job et `#deliver_later`, ce n'est plus le cas. Dans Rails 4.2, l'appel des méthodes d'instance est différé jusqu'à ce que `deliver_now` ou `deliver_later` soit appelé. Par exemple:

```ruby
class Notifier < ActionMailer::Base
  def notify(user, ...)
    puts "Appelé"
    mail(to: user.email, ...)
  end
end
```

```ruby
mail = Notifier.notify(user, ...) # Notifier#notify n'est pas encore appelé à ce stade
mail = mail.deliver_now           # Affiche "Appelé"
```

Cela ne devrait pas entraîner de différences perceptibles pour la plupart des applications. Cependant, si vous avez besoin que certaines méthodes non-mailer soient exécutées de manière synchrone et que vous vous appuyiez précédemment sur le comportement de proxy synchrone, vous devez les définir en tant que méthodes de classe directement sur la classe de mailer:

```ruby
class Notifier < ActionMailer::Base
  def self.broadcast_notifications(users, ...)
    users.each { |user| Notifier.notify(user, ...) }
  end
end
```

### Support des clés étrangères

Le DSL de migration a été étendu pour prendre en charge les définitions de clés étrangères. Si vous utilisez la gem Foreigner, vous voudrez peut-être la supprimer. Notez que le support des clés étrangères de Rails est un sous-ensemble de Foreigner. Cela signifie que toutes les définitions Foreigner ne peuvent pas être entièrement remplacées par leur équivalent DSL de migration Rails.

La procédure de migration est la suivante:

1. Supprimez `gem "foreigner"` du `Gemfile`.
2. Exécutez `bundle install`.
3. Exécutez `bin/rake db:schema:dump`.
4. Assurez-vous que `db/schema.rb` contient toutes les définitions de clés étrangères avec les options nécessaires.

Mise à niveau de Rails 4.0 à Rails 4.1
-------------------------------------

### Protection CSRF à partir des balises `<script>` distantes

Ou, "quoi mes tests échouent !!!?" ou "mon widget `<script>` est cassé !!"

La protection contre les attaques de falsification de requête intersite (CSRF) couvre désormais également les requêtes GET avec des réponses JavaScript. Cela empêche un site tiers de référencer à distance votre JavaScript avec une balise `<script>` pour extraire des données sensibles.

Cela signifie que vos tests fonctionnels et d'intégration qui utilisent

```ruby
get :index, format: :js
```

déclencheront désormais la protection CSRF. Passez à

```ruby
xhr :get, :index, format: :js
```

pour tester explicitement une `XmlHttpRequest`.

NOTE: Vos propres balises `<script>` sont également considérées comme étant de provenance croisée et bloquées par défaut. Si vous souhaitez vraiment charger du JavaScript à partir de balises `<script>`, vous devez maintenant désactiver explicitement la protection CSRF sur ces actions.

### Spring

Si vous souhaitez utiliser Spring comme préchargeur d'application, vous devez:

1. Ajoutez `gem 'spring', group: :development` à votre `Gemfile`.
2. Installez Spring en utilisant `bundle install`.
3. Générez le binstub Spring avec `bundle exec spring binstub`.

NOTE: Les tâches rake définies par l'utilisateur s'exécuteront par défaut dans l'environnement `development`. Si vous souhaitez les exécuter dans d'autres environnements, consultez le [README de Spring](https://github.com/rails/spring#rake).

### `config/secrets.yml`

Si vous souhaitez utiliser la nouvelle convention `secrets.yml` pour stocker les secrets de votre application, vous devez:

1. Créez un fichier `secrets.yml` dans votre dossier `config` avec le contenu suivant:

    ```yaml
    development:
      secret_key_base:

    test:
      secret_key_base:

    production:
      secret_key_base: <%= ENV["SECRET_KEY_BASE"] %>
    ```

2. Utilisez votre `secret_key_base` existant de l'initialiseur `secret_token.rb` pour définir la variable d'environnement `SECRET_KEY_BASE` pour les utilisateurs exécutant l'application Rails en production. Alternativement, vous pouvez simplement copier le `secret_key_base` existant de l'initialiseur `secret_token.rb` dans `secrets.yml` sous la section `production`, en remplaçant `<%= ENV["SECRET_KEY_BASE"] %>`.

3. Supprimez l'initialiseur `secret_token.rb`.

4. Utilisez `rake secret` pour générer de nouvelles clés pour les sections `development` et `test`.

5. Redémarrez votre serveur.

### Modifications de l'aide de test

Si votre aide de test contient un appel à `ActiveRecord::Migration.check_pending!`, cela peut être supprimé. La vérification est maintenant effectuée automatiquement lorsque vous `require "rails/test_help"`, bien que laisser cette ligne dans votre aide ne soit en aucun cas préjudiciable.

### Sérialiseur de cookies

Les applications créées avant Rails 4.1 utilisent `Marshal` pour sérialiser les valeurs des cookies dans les jars de cookies signés et chiffrés. Si vous souhaitez utiliser le nouveau format basé sur `JSON` dans votre application, vous pouvez ajouter un fichier d'initialisation avec le contenu suivant:

```ruby
Rails.application.config.action_dispatch.cookies_serializer = :hybrid
```

Cela migrera automatiquement vos cookies sérialisés avec `Marshal` vers le nouveau format basé sur `JSON`.

Lors de l'utilisation du sérialiseur `:json` ou `:hybrid`, vous devez être conscient que tous les objets Ruby ne peuvent pas être sérialisés en JSON. Par exemple, les objets `Date` et `Time` seront sérialisés en tant que chaînes de caractères, et les `Hash` auront leurs clés transformées en chaînes de caractères.

```ruby
class CookiesController < ApplicationController
  def set_cookie
    cookies.encrypted[:expiration_date] = Date.tomorrow # => Thu, 20 Mar 2014
    redirect_to action: 'read_cookie'
  end

  def read_cookie
    cookies.encrypted[:expiration_date] # => "2014-03-20"
  end
end
```
Il est conseillé de stocker uniquement des données simples (chaînes de caractères et nombres) dans les cookies.
Si vous devez stocker des objets complexes, vous devrez gérer la conversion manuellement lors de la lecture des valeurs lors de requêtes ultérieures.

Si vous utilisez le stockage de session par cookie, cela s'applique également au hachage `session` et `flash`.

### Changements dans la structure du Flash

Les clés des messages Flash sont [normalisées en chaînes de caractères](https://github.com/rails/rails/commit/a668beffd64106a1e1fedb71cc25eaaa11baf0c1). Elles peuvent toujours être accédées à l'aide de symboles ou de chaînes de caractères. Parcourir le Flash renverra toujours des clés de type chaîne de caractères :

```ruby
flash["string"] = "une chaîne de caractères"
flash[:symbol] = "un symbole"

# Rails < 4.1
flash.keys # => ["string", :symbol]

# Rails >= 4.1
flash.keys # => ["string", "symbol"]
```

Assurez-vous de comparer les clés des messages Flash avec des chaînes de caractères.

### Changements dans la manipulation de JSON

Il y a quelques changements majeurs liés à la manipulation de JSON dans Rails 4.1.

#### Suppression de MultiJSON

MultiJSON a atteint sa [fin de vie](https://github.com/rails/rails/pull/10576) et a été supprimé de Rails.

Si votre application dépend actuellement de MultiJSON directement, vous avez quelques options :

1. Ajoutez 'multi_json' à votre `Gemfile`. Notez que cela pourrait cesser de fonctionner à l'avenir.

2. Migrez de MultiJSON en utilisant `obj.to_json` et `JSON.parse(str)` à la place.

ATTENTION : Ne remplacez pas simplement `MultiJson.dump` et `MultiJson.load` par `JSON.dump` et `JSON.load`. Ces API de la gem JSON sont destinées à la sérialisation et à la désérialisation d'objets Ruby arbitraires et sont généralement [non sécurisées](https://ruby-doc.org/stdlib-2.2.2/libdoc/json/rdoc/JSON.html#method-i-load).

#### Compatibilité avec la gem JSON

Historiquement, Rails avait des problèmes de compatibilité avec la gem JSON. Utiliser `JSON.generate` et `JSON.dump` dans une application Rails pouvait entraîner des erreurs inattendues.

Rails 4.1 a résolu ces problèmes en isolant son propre encodeur de la gem JSON. Les API de la gem JSON fonctionneront normalement, mais elles n'auront pas accès aux fonctionnalités spécifiques à Rails. Par exemple :

```ruby
class FooBar
  def as_json(options = nil)
    { foo: 'bar' }
  end
end
```

```irb
irb> FooBar.new.to_json
=> "{\"foo\":\"bar\"}"
irb> JSON.generate(FooBar.new, quirks_mode: true)
=> "\"#<FooBar:0x007fa80a481610>\""
```

#### Nouvel encodeur JSON

L'encodeur JSON dans Rails 4.1 a été réécrit pour tirer parti de la gem JSON. Pour la plupart des applications, il s'agit d'un changement transparent. Cependant, dans le cadre de la réécriture, les fonctionnalités suivantes ont été supprimées de l'encodeur :

1. Détection des structures de données circulaires
2. Prise en charge du crochet `encode_json`
3. Option pour encoder les objets `BigDecimal` en tant que nombres au lieu de chaînes de caractères

Si votre application dépend de l'une de ces fonctionnalités, vous pouvez les récupérer en ajoutant la gem [`activesupport-json_encoder`](https://github.com/rails/activesupport-json_encoder) à votre `Gemfile`.

#### Représentation JSON des objets Time

`#as_json` pour les objets avec une composante temporelle (`Time`, `DateTime`, `ActiveSupport::TimeWithZone`) renvoie maintenant une précision en millisecondes par défaut. Si vous avez besoin de conserver l'ancien comportement sans précision en millisecondes, définissez ce qui suit dans un fichier d'initialisation :

```ruby
ActiveSupport::JSON::Encoding.time_precision = 0
```

### Utilisation de `return` dans les blocs de rappel en ligne

Auparavant, Rails autorisait les blocs de rappel en ligne à utiliser `return` de cette manière :

```ruby
class ReadOnlyModel < ActiveRecord::Base
  before_save { return false } # MAUVAIS
end
```

Ce comportement n'a jamais été intentionnellement pris en charge. En raison d'un changement dans les internes de `ActiveSupport::Callbacks`, cela n'est plus autorisé dans Rails 4.1. Utiliser une instruction `return` dans un bloc de rappel en ligne provoque une `LocalJumpError` lors de l'exécution du rappel.

Les blocs de rappel en ligne utilisant `return` peuvent être refactorisés pour évaluer la valeur retournée :

```ruby
class ReadOnlyModel < ActiveRecord::Base
  before_save { false } # BON
end
```

Alternativement, si `return` est préféré, il est recommandé de définir explicitement une méthode :

```ruby
class ReadOnlyModel < ActiveRecord::Base
  before_save :before_save_callback # BON

  private
    def before_save_callback
      false
    end
end
```

Ce changement s'applique à la plupart des endroits dans Rails où les rappels sont utilisés, y compris les rappels d'Active Record et d'Active Model, ainsi que les filtres dans Action Controller (par exemple, `before_action`).

Consultez [cette demande de tirage](https://github.com/rails/rails/pull/13271) pour plus de détails.

### Méthodes définies dans les fixtures d'Active Record

Rails 4.1 évalue chaque ERB de fixture dans un contexte séparé, donc les méthodes d'aide définies dans une fixture ne seront pas disponibles dans les autres fixtures.

Les méthodes d'aide utilisées dans plusieurs fixtures doivent être définies dans des modules inclus dans la nouvelle classe de contexte `ActiveRecord::FixtureSet.context_class`, dans `test_helper.rb`.

```ruby
module FixtureFileHelpers
  def file_sha(path)
    OpenSSL::Digest::SHA256.hexdigest(File.read(Rails.root.join('test/fixtures', path)))
  end
end

ActiveRecord::FixtureSet.context_class.include FixtureFileHelpers
```

### Application de la règle des locales disponibles par I18n

Rails 4.1 définit désormais par défaut l'option I18n `enforce_available_locales` sur `true`. Cela signifie qu'il s'assurera que toutes les locales qui lui sont transmises doivent être déclarées dans la liste `available_locales`.
Pour le désactiver (et permettre à I18n d'accepter *n'importe* quelle option de locale), ajoutez la configuration suivante à votre application :

```ruby
config.i18n.enforce_available_locales = false
```

Notez que cette option a été ajoutée comme mesure de sécurité, pour s'assurer que les entrées utilisateur ne puissent pas être utilisées comme informations de locale à moins d'être préalablement connues. Par conséquent, il est recommandé de ne pas désactiver cette option à moins d'avoir une raison valable de le faire.

### Méthodes mutatrices appelées sur Relation

`Relation` n'a plus de méthodes mutatrices telles que `#map!` et `#delete_if`. Convertissez-les en un `Array` en appelant `#to_a` avant d'utiliser ces méthodes.

Cela vise à prévenir les bugs étranges et la confusion dans le code qui appelle directement les méthodes mutatrices sur la `Relation`.

```ruby
# Au lieu de cela
Author.where(name: 'Hank Moody').compact!

# Maintenant, vous devez faire cela
authors = Author.where(name: 'Hank Moody').to_a
authors.compact!
```

### Changements sur les portées par défaut

Les portées par défaut ne sont plus remplacées par des conditions chaînées.

Dans les versions précédentes, lorsque vous définissiez une `portée par défaut` dans un modèle, elle était remplacée par des conditions chaînées dans le même champ. Maintenant, elle est fusionnée comme n'importe quelle autre portée.

Avant :

```ruby
class User < ActiveRecord::Base
  default_scope { where state: 'pending' }
  scope :active, -> { where state: 'active' }
  scope :inactive, -> { where state: 'inactive' }
end

User.all
# SELECT "users".* FROM "users" WHERE "users"."state" = 'pending'

User.active
# SELECT "users".* FROM "users" WHERE "users"."state" = 'active'

User.where(state: 'inactive')
# SELECT "users".* FROM "users" WHERE "users"."state" = 'inactive'
```

Après :

```ruby
class User < ActiveRecord::Base
  default_scope { where state: 'pending' }
  scope :active, -> { where state: 'active' }
  scope :inactive, -> { where state: 'inactive' }
end

User.all
# SELECT "users".* FROM "users" WHERE "users"."state" = 'pending'

User.active
# SELECT "users".* FROM "users" WHERE "users"."state" = 'pending' AND "users"."state" = 'active'

User.where(state: 'inactive')
# SELECT "users".* FROM "users" WHERE "users"."state" = 'pending' AND "users"."state" = 'inactive'
```

Pour obtenir le comportement précédent, il est nécessaire de supprimer explicitement la condition de la `portée par défaut` en utilisant `unscoped`, `unscope`, `rewhere` ou `except`.

```ruby
class User < ActiveRecord::Base
  default_scope { where state: 'pending' }
  scope :active, -> { unscope(where: :state).where(state: 'active') }
  scope :inactive, -> { rewhere state: 'inactive' }
end

User.all
# SELECT "users".* FROM "users" WHERE "users"."state" = 'pending'

User.active
# SELECT "users".* FROM "users" WHERE "users"."state" = 'active'

User.inactive
# SELECT "users".* FROM "users" WHERE "users"."state" = 'inactive'
```

### Rendu du contenu à partir d'une chaîne de caractères

Rails 4.1 introduit les options `:plain`, `:html` et `:body` pour `render`. Ces options sont désormais la méthode préférée pour rendre du contenu basé sur une chaîne de caractères, car elles vous permettent de spécifier le type de contenu que vous souhaitez envoyer dans la réponse.

* `render :plain` définira le type de contenu sur `text/plain`
* `render :html` définira le type de contenu sur `text/html`
* `render :body` ne définira *pas* l'en-tête du type de contenu.

Du point de vue de la sécurité, si vous n'attendez pas à avoir de balises dans le corps de votre réponse, vous devriez utiliser `render :plain` car la plupart des navigateurs échapperont le contenu non sécurisé dans la réponse pour vous.

Nous allons déprécier l'utilisation de `render :text` dans une version future. Veuillez donc commencer à utiliser les options plus précises `:plain`, `:html` et `:body` à la place. L'utilisation de `render :text` peut présenter un risque de sécurité, car le contenu est envoyé en tant que `text/html`.

### Types de données JSON et hstore de PostgreSQL

Rails 4.1 va mapper les colonnes `json` et `hstore` sur un `Hash` Ruby avec des clés de type chaîne. Dans les versions précédentes, un `HashWithIndifferentAccess` était utilisé. Cela signifie que l'accès par symbole n'est plus pris en charge. C'est également le cas pour les `store_accessors` basés sur les colonnes `json` ou `hstore`. Assurez-vous d'utiliser des clés de type chaîne de manière cohérente.

### Utilisation explicite de blocs pour `ActiveSupport::Callbacks`

Rails 4.1 s'attend désormais à ce qu'un bloc explicite soit passé lors de l'appel à `ActiveSupport::Callbacks.set_callback`. Ce changement découle de la refonte majeure de `ActiveSupport::Callbacks` pour la version 4.1.

```ruby
# Auparavant dans Rails 4.0
set_callback :save, :around, ->(r, &block) { stuff; result = block.call; stuff }

# Maintenant dans Rails 4.1
set_callback :save, :around, ->(r, block) { stuff; result = block.call; stuff }
```

Mise à niveau de Rails 3.2 vers Rails 4.0
----------------------------------------

Si votre application est actuellement sur une version de Rails antérieure à 3.2.x, vous devez d'abord passer à Rails 3.2 avant de passer à Rails 4.0.

Les modifications suivantes sont destinées à la mise à niveau de votre application vers Rails 4.0.

### HTTP PATCH
Rails 4 utilise désormais `PATCH` comme verbe HTTP principal pour les mises à jour lorsqu'une ressource RESTful est déclarée dans `config/routes.rb`. L'action `update` est toujours utilisée et les requêtes `PUT` continueront d'être routées vers l'action `update` également. Donc, si vous utilisez uniquement les routes RESTful standard, aucune modification n'est nécessaire :

```ruby
resources :users
```

```erb
<%= form_for @user do |f| %>
```

```ruby
class UsersController < ApplicationController
  def update
    # Aucun changement nécessaire ; PATCH sera préféré et PUT continuera de fonctionner.
  end
end
```

Cependant, vous devrez apporter une modification si vous utilisez `form_for` pour mettre à jour une ressource en conjonction avec une route personnalisée utilisant la méthode HTTP `PUT` :

```ruby
resources :users do
  put :update_name, on: :member
end
```

```erb
<%= form_for [ :update_name, @user ] do |f| %>
```

```ruby
class UsersController < ApplicationController
  def update_name
    # Changement nécessaire ; form_for essaiera d'utiliser une route PATCH inexistante.
  end
end
```

Si l'action n'est pas utilisée dans une API publique et que vous êtes libre de changer la méthode HTTP, vous pouvez mettre à jour votre route pour utiliser `patch` à la place de `put` :

```ruby
resources :users do
  patch :update_name, on: :member
end
```

Les requêtes `PUT` vers `/users/:id` dans Rails 4 sont routées vers `update` comme elles le sont actuellement. Donc, si vous avez une API qui reçoit de véritables requêtes PUT, cela fonctionnera. Le routeur routera également les requêtes `PATCH` vers `/users/:id` vers l'action `update`.

Si l'action est utilisée dans une API publique et que vous ne pouvez pas changer la méthode HTTP utilisée, vous pouvez mettre à jour votre formulaire pour utiliser la méthode `PUT` à la place :

```erb
<%= form_for [ :update_name, @user ], method: :put do |f| %>
```

Pour en savoir plus sur PATCH et la raison de ce changement, consultez [cet article](https://weblog.rubyonrails.org/2012/2/26/edge-rails-patch-is-the-new-primary-http-method-for-updates/) sur le blog de Rails.

#### Note sur les types de médias

Les errata pour le verbe `PATCH` [spécifient qu'un type de média 'diff' doit être utilisé avec `PATCH`](http://www.rfc-editor.org/errata_search.php?rfc=5789). Un de ces formats est [JSON Patch](https://tools.ietf.org/html/rfc6902). Bien que Rails ne prenne pas en charge nativement JSON Patch, il est assez facile d'ajouter une prise en charge :

```ruby
# dans votre contrôleur :
def update
  respond_to do |format|
    format.json do
      # effectuer une mise à jour partielle
      @article.update params[:article]
    end

    format.json_patch do
      # effectuer un changement sophistiqué
    end
  end
end
```

```ruby
# config/initializers/json_patch.rb
Mime::Type.register 'application/json-patch+json', :json_patch
```

Comme JSON Patch a été récemment transformé en RFC, il n'y a pas encore beaucoup de bonnes bibliothèques Ruby. Hana d'Aaron Patterson [hana](https://github.com/tenderlove/hana) est l'une de ces gemmes, mais elle ne prend pas en charge les derniers changements de la spécification.

### Gemfile

Rails 4.0 a supprimé le groupe `assets` de `Gemfile`. Vous devez supprimer cette ligne de votre `Gemfile` lors de la mise à niveau. Vous devez également mettre à jour votre fichier d'application (dans `config/application.rb`) :

```ruby
# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)
```

### vendor/plugins

Rails 4.0 ne prend plus en charge le chargement de plugins à partir de `vendor/plugins`. Vous devez remplacer tous les plugins en les extrayant en gemmes et en les ajoutant à votre `Gemfile`. Si vous choisissez de ne pas les transformer en gemmes, vous pouvez les déplacer dans, par exemple, `lib/my_plugin/*` et ajouter un initialiseur approprié dans `config/initializers/my_plugin.rb`.

### Active Record

* Rails 4.0 a supprimé la carte d'identité de Active Record en raison de [certaines incohérences avec les associations](https://github.com/rails/rails/commit/302c912bf6bcd0fa200d964ec2dc4a44abe328a6). Si vous l'avez activée manuellement dans votre application, vous devrez supprimer la configuration suivante qui n'a plus d'effet : `config.active_record.identity_map`.

* La méthode `delete` dans les associations de collection peut maintenant recevoir des arguments de type `Integer` ou `String` en tant qu'identifiants d'enregistrement, en plus des enregistrements, tout comme le fait la méthode `destroy`. Auparavant, cela levait une exception `ActiveRecord::AssociationTypeMismatch` pour de tels arguments. À partir de Rails 4.0, `delete` essaie automatiquement de trouver les enregistrements correspondant aux identifiants donnés avant de les supprimer.

* Dans Rails 4.0, lorsque vous renommez une colonne ou une table, les index associés sont également renommés. Si vous avez des migrations qui renomment les index, elles ne sont plus nécessaires.

* Rails 4.0 a changé `serialized_attributes` et `attr_readonly` en méthodes de classe uniquement. Vous ne devriez plus utiliser de méthodes d'instance car elles sont maintenant obsolètes. Vous devriez les modifier pour utiliser des méthodes de classe, par exemple `self.serialized_attributes` à `self.class.serialized_attributes`.

* Lors de l'utilisation du codeur par défaut, l'assignation de `nil` à un attribut sérialisé le sauvegardera dans la base de données en tant que `NULL` au lieu de passer la valeur `nil` via YAML (`"--- \n...\n"`).
* Rails 4.0 a supprimé la fonctionnalité `attr_accessible` et `attr_protected` en faveur de Strong Parameters. Vous pouvez utiliser le [gem Protected Attributes](https://github.com/rails/protected_attributes) pour une mise à niveau en douceur.

* Si vous n'utilisez pas Protected Attributes, vous pouvez supprimer toutes les options liées à ce gem, telles que `whitelist_attributes` ou `mass_assignment_sanitizer`.

* Rails 4.0 exige que les scopes utilisent un objet appelable tel qu'un Proc ou une lambda :

    ```ruby
      scope :active, where(active: true)

      # devient
      scope :active, -> { where active: true }
    ```

* Rails 4.0 a déprécié `ActiveRecord::Fixtures` en faveur de `ActiveRecord::FixtureSet`.

* Rails 4.0 a déprécié `ActiveRecord::TestCase` en faveur de `ActiveSupport::TestCase`.

* Rails 4.0 a déprécié l'ancienne API de recherche basée sur des hachages. Cela signifie que les méthodes qui acceptaient auparavant des "options de recherche" ne le font plus. Par exemple, `Book.find(:all, conditions: { name: '1984' })` a été déprécié en faveur de `Book.where(name: '1984')`.

* Toutes les méthodes dynamiques, à l'exception de `find_by_...` et `find_by_...!`, sont dépréciées. Voici comment gérer les changements :

      * `find_all_by_...`           devient `where(...)`.
      * `find_last_by_...`          devient `where(...).last`.
      * `scoped_by_...`             devient `where(...)`.
      * `find_or_initialize_by_...` devient `find_or_initialize_by(...)`.
      * `find_or_create_by_...`     devient `find_or_create_by(...)`.

* Notez que `where(...)` renvoie une relation, pas un tableau comme les anciennes méthodes de recherche. Si vous avez besoin d'un `Array`, utilisez `where(...).to_a`.

* Ces méthodes équivalentes peuvent ne pas exécuter le même SQL que l'implémentation précédente.

* Pour réactiver les anciennes méthodes de recherche, vous pouvez utiliser le [gem activerecord-deprecated_finders](https://github.com/rails/activerecord-deprecated_finders).

* Rails 4.0 a changé la table de jointure par défaut pour les relations `has_and_belongs_to_many` afin de supprimer le préfixe commun du nom de la deuxième table. Toute relation `has_and_belongs_to_many` existante entre des modèles avec un préfixe commun doit être spécifiée avec l'option `join_table`. Par exemple :

    ```ruby
    CatalogCategory < ActiveRecord::Base
      has_and_belongs_to_many :catalog_products, join_table: 'catalog_categories_catalog_products'
    end

    CatalogProduct < ActiveRecord::Base
      has_and_belongs_to_many :catalog_categories, join_table: 'catalog_categories_catalog_products'
    end
    ```

* Notez que le préfixe prend également en compte les scopes, donc les relations entre `Catalog::Category` et `Catalog::Product` ou `Catalog::Category` et `CatalogProduct` doivent être mises à jour de la même manière.

### Active Resource

Rails 4.0 a extrait Active Resource dans son propre gem. Si vous avez encore besoin de cette fonctionnalité, vous pouvez ajouter le [gem Active Resource](https://github.com/rails/activeresource) dans votre `Gemfile`.

### Active Model

* Rails 4.0 a modifié la manière dont les erreurs sont attachées avec `ActiveModel::Validations::ConfirmationValidator`. Maintenant, lorsque les validations de confirmation échouent, l'erreur sera attachée à `:#{attribute}_confirmation` au lieu de `attribute`.

* Rails 4.0 a changé la valeur par défaut de `ActiveModel::Serializers::JSON.include_root_in_json` en `false`. Maintenant, Active Model Serializers et les objets Active Record ont le même comportement par défaut. Cela signifie que vous pouvez commenter ou supprimer l'option suivante dans le fichier `config/initializers/wrap_parameters.rb` :

    ```ruby
    # Disable root element in JSON by default.
    # ActiveSupport.on_load(:active_record) do
    #   self.include_root_in_json = false
    # end
    ```

### Action Pack

* Rails 4.0 introduit `ActiveSupport::KeyGenerator` et l'utilise comme base pour générer et vérifier les cookies signés (entre autres choses). Les cookies signés existants générés avec Rails 3.x seront mis à niveau de manière transparente si vous laissez votre `secret_token` existant en place et ajoutez le nouveau `secret_key_base`.

    ```ruby
      # config/initializers/secret_token.rb
      Myapp::Application.config.secret_token = 'existing secret token'
      Myapp::Application.config.secret_key_base = 'new secret key base'
    ```

    Veuillez noter que vous devez attendre pour définir `secret_key_base` jusqu'à ce que 100% de votre base d'utilisateurs soit sur Rails 4.x et que vous soyez raisonnablement sûr de ne pas avoir besoin de revenir à Rails 3.x. Cela est dû au fait que les cookies signés basés sur le nouveau `secret_key_base` dans Rails 4.x ne sont pas rétrocompatibles avec Rails 3.x. Vous êtes libre de laisser votre `secret_token` existant en place, de ne pas définir le nouveau `secret_key_base` et d'ignorer les avertissements de dépréciation jusqu'à ce que vous soyez raisonnablement sûr que votre mise à niveau est par ailleurs terminée.

    Si vous comptez sur la capacité des applications externes ou de JavaScript à pouvoir lire les cookies de session signés de votre application Rails (ou les cookies signés en général), vous ne devez pas définir `secret_key_base` tant que vous n'avez pas dissocié ces préoccupations.

* Rails 4.0 chiffre le contenu des sessions basées sur les cookies si `secret_key_base` a été défini. Rails 3.x signait, mais ne chiffrait pas, le contenu des sessions basées sur les cookies. Les cookies signés sont "sécurisés" car ils sont vérifiés comme ayant été générés par votre application et sont inviolables. Cependant, le contenu peut être consulté par les utilisateurs finaux, et le chiffrement du contenu élimine cette réserve/préoccupation sans pénalité de performance significative.

    Veuillez lire [Pull Request #9978](https://github.com/rails/rails/pull/9978) pour plus de détails sur le passage aux cookies de session chiffrés.

* Rails 4.0 a supprimé l'option `ActionController::Base.asset_path`. Utilisez la fonctionnalité du pipeline des assets.
* Rails 4.0 a déprécié l'option `ActionController::Base.page_cache_extension`. Utilisez plutôt `ActionController::Base.default_static_extension`.

* Rails 4.0 a supprimé le caching d'actions et de pages de Action Pack. Vous devrez ajouter la gem `actionpack-action_caching` pour utiliser `caches_action` et la gem `actionpack-page_caching` pour utiliser `caches_page` dans vos contrôleurs.

* Rails 4.0 a supprimé le parseur de paramètres XML. Vous devrez ajouter la gem `actionpack-xml_parser` si vous avez besoin de cette fonctionnalité.

* Rails 4.0 modifie la recherche par défaut du `layout` en utilisant des symboles ou des procédures qui renvoient nil. Pour obtenir le comportement "pas de layout", renvoyez false au lieu de nil.

* Rails 4.0 change le client memcached par défaut de `memcache-client` à `dalli`. Pour effectuer la mise à niveau, ajoutez simplement `gem 'dalli'` à votre `Gemfile`.

* Rails 4.0 déprécie les méthodes `dom_id` et `dom_class` dans les contrôleurs (elles sont toujours valables dans les vues). Vous devrez inclure le module `ActionView::RecordIdentifier` dans les contrôleurs qui nécessitent cette fonctionnalité.

* Rails 4.0 déprécie l'option `:confirm` pour l'aide `link_to`. Vous devriez plutôt utiliser un attribut de données (par exemple, `data: { confirm: 'Êtes-vous sûr ?' }`). Cette dépréciation concerne également les aides basées sur celle-ci (comme `link_to_if` ou `link_to_unless`).

* Rails 4.0 a modifié le fonctionnement des assertions `assert_generates`, `assert_recognizes` et `assert_routing`. Maintenant, toutes ces assertions lèvent une `Assertion` au lieu d'une `ActionController::RoutingError`.

* Rails 4.0 lève une `ArgumentError` si des routes nommées en conflit sont définies. Cela peut être déclenché par des routes nommées explicitement définies ou par la méthode `resources`. Voici deux exemples qui entrent en conflit avec des routes nommées `example_path` :

    ```ruby
    get 'one' => 'test#example', as: :example
    get 'two' => 'test#example', as: :example
    ```

    ```ruby
    resources :examples
    get 'clashing/:id' => 'test#example', as: :example
    ```

    Dans le premier cas, vous pouvez simplement éviter d'utiliser le même nom pour plusieurs routes. Dans le second cas, vous pouvez utiliser les options `only` ou `except` fournies par la méthode `resources` pour restreindre les routes créées, comme expliqué dans le [Guide de routage](routing.html#restricting-the-routes-created).

* Rails 4.0 a également modifié la façon dont les routes de caractères Unicode sont dessinées. Maintenant, vous pouvez dessiner directement des routes de caractères Unicode. Si vous avez déjà dessiné de telles routes, vous devez les modifier, par exemple :

    ```ruby
    get Rack::Utils.escape('こんにちは'), controller: 'welcome', action: 'index'
    ```

    devient

    ```ruby
    get 'こんにちは', controller: 'welcome', action: 'index'
    ```

* Rails 4.0 exige que les routes utilisant `match` spécifient la méthode de requête. Par exemple :

    ```ruby
      # Rails 3.x
      match '/' => 'root#index'

      # devient
      match '/' => 'root#index', via: :get

      # ou
      get '/' => 'root#index'
    ```

* Rails 4.0 a supprimé le middleware `ActionDispatch::BestStandardsSupport`, `<!DOCTYPE html>` déclenche déjà le mode standard selon https://msdn.microsoft.com/en-us/library/jj676915(v=vs.85).aspx et l'en-tête ChromeFrame a été déplacé vers `config.action_dispatch.default_headers`.

    N'oubliez pas de supprimer également toutes les références au middleware de votre code d'application, par exemple :

    ```ruby
    # Lève une exception
    config.middleware.insert_before(Rack::Lock, ActionDispatch::BestStandardsSupport)
    ```

    Vérifiez également les paramètres de votre environnement pour `config.action_dispatch.best_standards_support` et supprimez-le s'il est présent.

* Rails 4.0 permet la configuration des en-têtes HTTP en définissant `config.action_dispatch.default_headers`. Les valeurs par défaut sont les suivantes :

    ```ruby
      config.action_dispatch.default_headers = {
        'X-Frame-Options' => 'SAMEORIGIN',
        'X-XSS-Protection' => '1; mode=block'
      }
    ```

    Veuillez noter que si votre application dépend du chargement de certaines pages dans une balise `<frame>` ou `<iframe>`, vous devrez peut-être définir explicitement `X-Frame-Options` sur `ALLOW-FROM ...` ou `ALLOWALL`.

* Dans Rails 4.0, la précompilation des assets ne copie plus automatiquement les assets non JS/CSS de `vendor/assets` et `lib/assets`. Les développeurs d'applications et de moteurs Rails doivent placer ces assets dans `app/assets` ou configurer [`config.assets.precompile`][].

* Dans Rails 4.0, `ActionController::UnknownFormat` est levé lorsque l'action ne gère pas le format de la requête. Par défaut, l'exception est gérée en répondant avec un code 406 Not Acceptable, mais vous pouvez maintenant la remplacer. Dans Rails 3, 406 Not Acceptable était toujours renvoyé. Pas de remplacements.

* Dans Rails 4.0, une exception générique `ActionDispatch::ParamsParser::ParseError` est levée lorsque `ParamsParser` échoue à analyser les paramètres de la requête. Vous devrez capturer cette exception au lieu de la `MultiJson::DecodeError` de bas niveau, par exemple.

* Dans Rails 4.0, `SCRIPT_NAME` est correctement imbriqué lorsque des moteurs sont montés sur une application servie à partir d'un préfixe d'URL. Vous n'avez plus besoin de définir `default_url_options[:script_name]` pour contourner les préfixes d'URL écrasés.

* Rails 4.0 a déprécié `ActionController::Integration` au profit de `ActionDispatch::Integration`.
* Rails 4.0 a déprécié `ActionController::IntegrationTest` au profit de `ActionDispatch::IntegrationTest`.
* Rails 4.0 a déprécié `ActionController::PerformanceTest` au profit de `ActionDispatch::PerformanceTest`.
* Rails 4.0 a déprécié `ActionController::AbstractRequest` au profit de `ActionDispatch::Request`.
* Rails 4.0 a déprécié `ActionController::Request` au profit de `ActionDispatch::Request`.
* Rails 4.0 a déprécié `ActionController::AbstractResponse` au profit de `ActionDispatch::Response`.
* Rails 4.0 a déprécié `ActionController::Response` au profit de `ActionDispatch::Response`.
* Rails 4.0 a déprécié `ActionController::Routing` au profit de `ActionDispatch::Routing`.
### Active Support

Rails 4.0 supprime l'alias `j` pour `ERB::Util#json_escape` car `j` est déjà utilisé pour `ActionView::Helpers::JavaScriptHelper#escape_javascript`.

#### Cache

La méthode de mise en cache a changé entre Rails 3.x et 4.0. Vous devriez [modifier l'espace de noms du cache](https://guides.rubyonrails.org/v4.0/caching_with_rails.html#activesupport-cache-store) et déployer avec un cache froid.

### Ordre de chargement des helpers

L'ordre dans lequel les helpers de plusieurs répertoires sont chargés a changé dans Rails 4.0. Auparavant, ils étaient rassemblés puis triés alphabétiquement. Après la mise à niveau vers Rails 4.0, les helpers conserveront l'ordre des répertoires chargés et ne seront triés alphabétiquement que dans chaque répertoire. À moins que vous n'utilisiez explicitement le paramètre `helpers_path`, ce changement n'affectera que la façon de charger les helpers des moteurs. Si vous comptez sur l'ordre, vous devriez vérifier si les méthodes correctes sont disponibles après la mise à niveau. Si vous souhaitez modifier l'ordre dans lequel les moteurs sont chargés, vous pouvez utiliser la méthode `config.railties_order=`.

### Active Record Observer et Action Controller Sweeper

`ActiveRecord::Observer` et `ActionController::Caching::Sweeper` ont été extraits dans le gem `rails-observers`. Vous devrez ajouter le gem `rails-observers` si vous avez besoin de ces fonctionnalités.

### sprockets-rails

* `assets:precompile:primary` et `assets:precompile:all` ont été supprimés. Utilisez `assets:precompile` à la place.
* L'option `config.assets.compress` doit être modifiée en [`config.assets.js_compressor`][] comme ceci par exemple :

    ```ruby
    config.assets.js_compressor = :uglifier
    ```


### sass-rails

* `asset-url` avec deux arguments est obsolète. Par exemple : `asset-url("rails.png", image)` devient `asset-url("rails.png")`.

Mise à niveau de Rails 3.1 vers Rails 3.2
-------------------------------------

Si votre application est actuellement sur une version de Rails antérieure à 3.1.x, vous devez mettre à niveau vers Rails 3.1 avant de tenter une mise à jour vers Rails 3.2.

Les modifications suivantes sont destinées à la mise à niveau de votre application vers la dernière version 3.2.x de Rails.

### Gemfile

Apportez les modifications suivantes à votre `Gemfile`.

```ruby
gem 'rails', '3.2.21'

group :assets do
  gem 'sass-rails',   '~> 3.2.6'
  gem 'coffee-rails', '~> 3.2.2'
  gem 'uglifier',     '>= 1.0.3'
end
```

### config/environments/development.rb

Il existe quelques nouvelles configurations que vous devriez ajouter à votre environnement de développement :

```ruby
# Lever une exception en cas de protection contre les affectations de masse pour les modèles Active Record
config.active_record.mass_assignment_sanitizer = :strict

# Enregistrer le plan de requête pour les requêtes prenant plus de temps que cela (fonctionne
# avec SQLite, MySQL et PostgreSQL)
config.active_record.auto_explain_threshold_in_seconds = 0.5
```

### config/environments/test.rb

La configuration `mass_assignment_sanitizer` doit également être ajoutée à `config/environments/test.rb` :

```ruby
# Lever une exception en cas de protection contre les affectations de masse pour les modèles Active Record
config.active_record.mass_assignment_sanitizer = :strict
```

### vendor/plugins

Rails 3.2 déprécie `vendor/plugins` et Rails 4.0 les supprimera complètement. Bien que cela ne soit pas strictement nécessaire dans le cadre d'une mise à niveau vers Rails 3.2, vous pouvez commencer à remplacer les plugins en les extrayant en gems et en les ajoutant à votre `Gemfile`. Si vous choisissez de ne pas les transformer en gems, vous pouvez les déplacer dans, par exemple, `lib/my_plugin/*` et ajouter un initialiseur approprié dans `config/initializers/my_plugin.rb`.

### Active Record

L'option `:dependent => :restrict` a été supprimée de `belongs_to`. Si vous souhaitez empêcher la suppression de l'objet s'il existe des objets associés, vous pouvez définir `:dependent => :destroy` et renvoyer `false` après avoir vérifié l'existence de l'association à partir de l'un des rappels de destruction de l'objet associé.

Mise à niveau de Rails 3.0 vers Rails 3.1
-------------------------------------

Si votre application est actuellement sur une version de Rails antérieure à 3.0.x, vous devez mettre à niveau vers Rails 3.0 avant de tenter une mise à jour vers Rails 3.1.

Les modifications suivantes sont destinées à la mise à niveau de votre application vers Rails 3.1.12, la dernière version 3.1.x de Rails.

### Gemfile

Apportez les modifications suivantes à votre `Gemfile`.

```ruby
gem 'rails', '3.1.12'
gem 'mysql2'

# Nécessaire pour le nouveau pipeline d'assets
group :assets do
  gem 'sass-rails',   '~> 3.1.7'
  gem 'coffee-rails', '~> 3.1.1'
  gem 'uglifier',     '>= 1.0.3'
end

# jQuery est la bibliothèque JavaScript par défaut dans Rails 3.1
gem 'jquery-rails'
```

### config/application.rb

Le pipeline d'assets nécessite les ajouts suivants :

```ruby
config.assets.enabled = true
config.assets.version = '1.0'
```

Si votre application utilise une route "/assets" pour une ressource, vous voudrez peut-être changer le préfixe utilisé pour les assets afin d'éviter les conflits :

```ruby
# Par défaut, '/assets'
config.assets.prefix = '/asset-files'
```

### config/environments/development.rb

Supprimez le paramètre RJS `config.action_view.debug_rjs = true`.

Ajoutez ces paramètres si vous activez le pipeline d'assets :

```ruby
# Ne pas compresser les assets
config.assets.compress = false

# Développer les lignes qui chargent les assets
config.assets.debug = true
```

### config/environments/production.rb

Encore une fois, la plupart des modifications ci-dessous concernent le pipeline d'assets. Vous pouvez en savoir plus à ce sujet dans le guide [Pipeline d'assets](asset_pipeline.html).
```ruby
# Compresser les fichiers JavaScript et CSS
config.assets.compress = true

# Ne pas utiliser le pipeline des assets si un asset précompilé est manquant
config.assets.compile = false

# Générer des empreintes pour les URLs des assets
config.assets.digest = true

# Par défaut : Rails.root.join("public/assets")
# config.assets.manifest = YOUR_PATH

# Précompiler des assets supplémentaires (application.js, application.css, et tous les fichiers non-JS/CSS sont déjà ajoutés)
# config.assets.precompile += %w( admin.js admin.css )

# Forcer l'accès à l'application via SSL, utiliser Strict-Transport-Security et des cookies sécurisés.
# config.force_ssl = true
```

### config/environments/test.rb

Vous pouvez aider à tester les performances avec ces ajouts à votre environnement de test :

```ruby
# Configurer le serveur d'assets statiques pour les tests avec Cache-Control pour les performances
config.public_file_server.enabled = true
config.public_file_server.headers = {
  'Cache-Control' => 'public, max-age=3600'
}
```

### config/initializers/wrap_parameters.rb

Ajoutez ce fichier avec le contenu suivant, si vous souhaitez envelopper les paramètres dans un hash imbriqué. Cela est activé par défaut dans les nouvelles applications.

```ruby
# Assurez-vous de redémarrer votre serveur lorsque vous modifiez ce fichier.
# Ce fichier contient les paramètres pour ActionController::ParamsWrapper qui
# est activé par défaut.

# Activer l'enveloppement des paramètres pour JSON. Vous pouvez désactiver cela en définissant :format sur un tableau vide.
ActiveSupport.on_load(:action_controller) do
  wrap_parameters format: [:json]
end

# Désactiver l'élément racine dans JSON par défaut.
ActiveSupport.on_load(:active_record) do
  self.include_root_in_json = false
end
```

### config/initializers/session_store.rb

Vous devez changer la clé de session pour quelque chose de nouveau, ou supprimer toutes les sessions :

```ruby
# dans config/initializers/session_store.rb
AppName::Application.config.session_store :cookie_store, key: 'QUELQUECHOSENOUVEAU'
```

ou

```bash
$ bin/rake db:sessions:clear
```

### Supprimer les options :cache et :concat dans les références des helpers d'assets dans les vues

* Avec le pipeline des assets, les options :cache et :concat ne sont plus utilisées, supprimez ces options de vos vues.
[`config.cache_classes`]: configuring.html#config-cache-classes
[`config.autoload_once_paths`]: configuring.html#config-autoload-once-paths
[`config.force_ssl`]: configuring.html#config-force-ssl
[`config.ssl_options`]: configuring.html#config-ssl-options
[`config.add_autoload_paths_to_load_path`]: configuring.html#config-add-autoload-paths-to-load-path
[`config.active_storage.replace_on_assign_to_many`]: configuring.html#config-active-storage-replace-on-assign-to-many
[`config.exceptions_app`]: configuring.html#config-exceptions-app
[`config.action_mailer.perform_caching`]: configuring.html#config-action-mailer-perform-caching
[`config.assets.precompile`]: configuring.html#config-assets-precompile
[`config.assets.js_compressor`]: configuring.html#config-assets-js-compressor
