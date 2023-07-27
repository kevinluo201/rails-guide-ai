**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 390d20a8bee6232c0ffa7faeb0e9d8e8
Action Mailer Basics
====================

Ce guide vous fournit tout ce dont vous avez besoin pour commencer à envoyer des e-mails depuis votre application, ainsi que de nombreuses informations sur Action Mailer. Il explique également comment tester vos mailers.

Après avoir lu ce guide, vous saurez :

* Comment envoyer des e-mails dans une application Rails.
* Comment générer et modifier une classe Action Mailer et une vue de mailer.
* Comment configurer Action Mailer pour votre environnement.
* Comment tester vos classes Action Mailer.

--------------------------------------------------------------------------------

Qu'est-ce que Action Mailer ?
-----------------------------

Action Mailer vous permet d'envoyer des e-mails depuis votre application en utilisant des classes de mailer et des vues.

### Les mailers sont similaires aux contrôleurs

Ils héritent de [`ActionMailer::Base`][] et se trouvent dans `app/mailers`. Les mailers fonctionnent également de manière très similaire aux contrôleurs. Voici quelques exemples de similitudes. Les mailers ont :

* Des actions, ainsi que des vues associées qui se trouvent dans `app/views`.
* Des variables d'instance accessibles dans les vues.
* La possibilité d'utiliser des mises en page et des partiels.
* La possibilité d'accéder à un hachage de paramètres.


Envoi d'e-mails
---------------

Cette section vous fournira un guide étape par étape pour créer un mailer et ses vues.

### Guide pas à pas pour générer un mailer

#### Créer le mailer

```bash
$ bin/rails generate mailer User
create  app/mailers/user_mailer.rb
create  app/mailers/application_mailer.rb
invoke  erb
create    app/views/user_mailer
create    app/views/layouts/mailer.text.erb
create    app/views/layouts/mailer.html.erb
invoke  test_unit
create    test/mailers/user_mailer_test.rb
create    test/mailers/previews/user_mailer_preview.rb
```

```ruby
# app/mailers/application_mailer.rb
class ApplicationMailer < ActionMailer::Base
  default from: "from@example.com"
  layout 'mailer'
end
```

```ruby
# app/mailers/user_mailer.rb
class UserMailer < ApplicationMailer
end
```

Comme vous pouvez le voir, vous pouvez générer des mailers comme vous utilisez d'autres générateurs avec Rails.

Si vous ne souhaitez pas utiliser un générateur, vous pouvez créer votre propre fichier à l'intérieur de `app/mailers`, assurez-vous simplement qu'il hérite de `ActionMailer::Base` :

```ruby
class MyMailer < ActionMailer::Base
end
```

#### Modifier le mailer

Les mailers ont des méthodes appelées "actions" et ils utilisent des vues pour structurer leur contenu. Alors qu'un contrôleur génère du contenu comme du HTML à renvoyer au client, un mailer crée un message à envoyer par e-mail.

`app/mailers/user_mailer.rb` contient un mailer vide :

```ruby
class UserMailer < ApplicationMailer
end
```

Ajoutons une méthode appelée `welcome_email`, qui enverra un e-mail à l'adresse e-mail enregistrée de l'utilisateur :

```ruby
class UserMailer < ApplicationMailer
  default from: 'notifications@example.com'

  def welcome_email
    @user = params[:user]
    @url  = 'http://example.com/login'
    mail(to: @user.email, subject: 'Bienvenue sur mon super site')
  end
end
```

Voici une brève explication des éléments présentés dans la méthode précédente. Pour une liste complète de toutes les options disponibles, veuillez consulter la section Liste complète des attributs configurables par l'utilisateur d'Action Mailer.

* La méthode [`default`][] définit des valeurs par défaut pour tous les e-mails envoyés depuis ce mailer. Dans ce cas, nous l'utilisons pour définir la valeur de l'en-tête `:from` pour tous les messages de cette classe. Cela peut être remplacé pour chaque e-mail.
* La méthode [`mail`][] crée le message e-mail réel. Nous l'utilisons pour spécifier les valeurs des en-têtes comme `:to` et `:subject` pour chaque e-mail.


#### Créer une vue de mailer

Créez un fichier appelé `welcome_email.html.erb` dans `app/views/user_mailer/`. Cela sera le modèle utilisé pour l'e-mail, formaté en HTML :
```html+erb
<!DOCTYPE html>
<html>
  <head>
    <meta content='text/html; charset=UTF-8' http-equiv='Content-Type' />
  </head>
  <body>
    <h1>Bienvenue sur example.com, <%= @user.name %></h1>
    <p>
      Vous vous êtes inscrit avec succès sur example.com,
      votre nom d'utilisateur est : <%= @user.login %>.<br>
    </p>
    <p>
      Pour vous connecter au site, il suffit de suivre ce lien : <%= @url %>.
    </p>
    <p>Merci de nous rejoindre et passez une excellente journée !</p>
  </body>
</html>
```

Créons également une partie texte pour cet e-mail. Tous les clients ne préfèrent pas les e-mails HTML,
il est donc préférable d'envoyer les deux. Pour cela, créez un fichier appelé
`welcome_email.text.erb` dans `app/views/user_mailer/` :

```erb
Bienvenue sur example.com, <%= @user.name %>
===============================================

Vous vous êtes inscrit avec succès sur example.com,
votre nom d'utilisateur est : <%= @user.login %>.

Pour vous connecter au site, il suffit de suivre ce lien : <%= @url %>.

Merci de nous rejoindre et passez une excellente journée !
```

Lorsque vous appelez maintenant la méthode `mail`, Action Mailer détectera les deux modèles
(texte et HTML) et générera automatiquement un e-mail `multipart/alternative`.

#### Appel du Mailer

Les Mailers sont simplement une autre façon de rendre une vue. Au lieu de rendre une
vue et de l'envoyer via le protocole HTTP, ils l'envoient via
les protocoles de messagerie. Pour cette raison, il est logique que votre
contrôleur indique au Mailer d'envoyer un e-mail lorsqu'un utilisateur est créé avec succès.

La configuration est simple.

Tout d'abord, créons un échafaudage `User` :

```bash
$ bin/rails generate scaffold user name email login
$ bin/rails db:migrate
```

Maintenant que nous avons un modèle d'utilisateur avec lequel jouer, nous allons modifier
le fichier `app/controllers/users_controller.rb`, en lui demandant d'instruire le `UserMailer` d'envoyer
un e-mail au nouvel utilisateur créé en éditant l'action create et en insérant un
appel à `UserMailer.with(user: @user).welcome_email` juste après que l'utilisateur ait été enregistré avec succès.

Nous mettrons l'e-mail en file d'attente pour être envoyé en utilisant [`deliver_later`][], qui est
pris en charge par Active Job. Ainsi, l'action du contrôleur peut se poursuivre sans
attendre la fin de l'envoi.

```ruby
class UsersController < ApplicationController
  # ...

  # POST /users or /users.json
  def create
    @user = User.new(user_params)

    respond_to do |format|
      if @user.save
        # Demandez à UserMailer d'envoyer un e-mail de bienvenue après l'enregistrement
        UserMailer.with(user: @user).welcome_email.deliver_later

        format.html { redirect_to(@user, notice: 'L\'utilisateur a été créé avec succès.') }
        format.json { render json: @user, status: :created, location: @user }
      else
        format.html { render action: 'new' }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # ...
end
```

REMARQUE : Le comportement par défaut d'Active Job est d'exécuter les jobs via l'adaptateur `:async`.
Vous pouvez donc utiliser `deliver_later` pour envoyer des e-mails de manière asynchrone.
L'adaptateur par défaut d'Active Job exécute les jobs avec un pool de threads en cours d'exécution.
Il convient bien aux environnements de développement/test, car il ne nécessite pas
d'infrastructure externe, mais il est mal adapté à la production car il supprime
les jobs en attente lors du redémarrage.
Si vous avez besoin d'un backend persistant, vous devrez utiliser un adaptateur Active Job
qui dispose d'un backend persistant (Sidekiq, Resque, etc).

Si vous souhaitez envoyer des e-mails immédiatement (à partir d'un cronjob par exemple), appelez simplement
[`deliver_now`][] :

```ruby
class SendWeeklySummary
  def run
    User.find_each do |user|
      UserMailer.with(user: user).weekly_summary.deliver_now
    end
  end
end
```
Toute paire clé-valeur passée à [`with`][] devient simplement les `params` pour l'action du mailer. Ainsi, `with(user: @user, account: @user.account)` rend `params[:user]` et `params[:account]` disponibles dans l'action du mailer. Tout comme les contrôleurs ont des params.

La méthode `welcome_email` renvoie un objet [`ActionMailer::MessageDelivery`][] qui peut ensuite être invité à `deliver_now` ou `deliver_later` pour s'envoyer lui-même. L'objet `ActionMailer::MessageDelivery` est un wrapper autour d'un [`Mail::Message`][]. Si vous souhaitez inspecter, modifier ou faire autre chose avec l'objet `Mail::Message`, vous pouvez y accéder avec la méthode [`message`][] sur l'objet `ActionMailer::MessageDelivery`.


### Encodage automatique des valeurs d'en-tête

Action Mailer gère l'encodage automatique des caractères multioctets à l'intérieur des en-têtes et des corps.

Pour des exemples plus complexes tels que la définition de jeux de caractères alternatifs ou l'auto-encodage du texte, veuillez vous référer à la bibliothèque [Mail](https://github.com/mikel/mail).

### Liste complète des méthodes d'Action Mailer

Il existe seulement trois méthodes dont vous avez besoin pour envoyer pratiquement n'importe quel message électronique :

* [`headers`][] - Spécifie n'importe quel en-tête de l'e-mail que vous souhaitez. Vous pouvez passer un hash de noms de champs d'en-tête et de paires de valeurs, ou vous pouvez appeler `headers[:nom_champ] = 'valeur'`.
* [`attachments`][] - Vous permet d'ajouter des pièces jointes à votre e-mail. Par exemple, `attachments['nom-fichier.jpg'] = File.read('nom-fichier.jpg')`.
* [`mail`][] - Crée l'e-mail lui-même. Vous pouvez passer les en-têtes en tant que hash à la méthode `mail` en tant que paramètre. `mail` créera un e-mail - soit du texte brut, soit multipart - en fonction des modèles d'e-mail que vous avez définis.


#### Ajout de pièces jointes

Action Mailer facilite grandement l'ajout de pièces jointes.

* Passez le nom de fichier et le contenu à Action Mailer et à la [gem Mail](https://github.com/mikel/mail) qui devinera automatiquement le `mime_type`, définira l'`encoding` et créera la pièce jointe.

    ```ruby
    attachments['nom-fichier.jpg'] = File.read('/chemin/vers/nom-fichier.jpg')
    ```

  Lorsque la méthode `mail` sera déclenchée, elle enverra un e-mail multipart avec une pièce jointe, correctement imbriquée avec le niveau supérieur étant `multipart/mixed` et la première partie étant un `multipart/alternative` contenant les messages d'e-mail en texte brut et HTML.

NOTE : Mail encodera automatiquement en Base64 une pièce jointe. Si vous voulez autre chose, encodez votre contenu et passez le contenu encodé et l'encodage dans un `Hash` à la méthode `attachments`.

* Passez le nom de fichier, spécifiez les en-têtes et le contenu à Action Mailer et Mail utilisera les paramètres que vous avez passés.

    ```ruby
    contenu_encodé = SpecialEncode(File.read('/chemin/vers/nom-fichier.jpg'))
    attachments['nom-fichier.jpg'] = {
      mime_type: 'application/gzip',
      encoding: 'SpecialEncoding',
      content: contenu_encodé
    }
    ```

NOTE : Si vous spécifiez un encodage, Mail supposera que votre contenu est déjà encodé et n'essaiera pas de l'encoder en Base64.

#### Création de pièces jointes intégrées

Action Mailer 3.0 facilite la création de pièces jointes intégrées, ce qui nécessitait beaucoup de piratage dans les versions antérieures à 3.0.

* Tout d'abord, pour indiquer à Mail de transformer une pièce jointe en pièce jointe intégrée, il suffit d'appeler `#inline` sur la méthode `attachments` dans votre Mailer :

    ```ruby
    def bienvenue
      attachments.inline['image.jpg'] = File.read('/chemin/vers/image.jpg')
    end
    ```

* Ensuite, dans votre vue, vous pouvez simplement faire référence à `attachments` en tant que hash et spécifier quelle pièce jointe vous souhaitez afficher, en appelant `url` dessus, puis en passant le résultat dans la méthode `image_tag` :
```html+erb
<p>Bonjour, voici notre image</p>

<%= image_tag attachments['image.jpg'].url %>
```

* Comme il s'agit d'un appel standard à `image_tag`, vous pouvez passer un hachage d'options après l'URL de la pièce jointe comme vous le feriez pour n'importe quelle autre image :

```html+erb
<p>Bonjour, voici notre image</p>

<%= image_tag attachments['image.jpg'].url, alt: 'Ma photo', class: 'photos' %>
```

#### Envoi d'e-mails à plusieurs destinataires

Il est possible d'envoyer un e-mail à un ou plusieurs destinataires dans un seul e-mail (par exemple, informer tous les administrateurs d'une nouvelle inscription) en définissant la liste des e-mails avec la clé `:to`. La liste des e-mails peut être un tableau d'adresses e-mail ou une seule chaîne de caractères avec les adresses séparées par des virgules.

```ruby
class AdminMailer < ApplicationMailer
  default to: -> { Admin.pluck(:email) },
          from: 'notification@example.com'

  def new_registration(user)
    @user = user
    mail(subject: "Nouvelle inscription : #{@user.email}")
  end
end
```

Le même format peut être utilisé pour définir les destinataires en copie carbone (Cc:) et en copie carbone invisible (Bcc:) en utilisant les clés `:cc` et `:bcc` respectivement.

#### Envoi d'e-mails avec un nom

Parfois, vous souhaitez afficher le nom de la personne plutôt que simplement son adresse e-mail lorsqu'elle reçoit l'e-mail. Vous pouvez utiliser [`email_address_with_name`][] pour cela :

```ruby
def welcome_email
  @user = params[:user]
  mail(
    to: email_address_with_name(@user.email, @user.name),
    subject: 'Bienvenue sur mon super site'
  )
end
```

La même technique fonctionne pour spécifier un nom d'expéditeur :

```ruby
class UserMailer < ApplicationMailer
  default from: email_address_with_name('notification@example.com', 'Notifications de la société exemple')
end
```

Si le nom est une chaîne vide, seule l'adresse est renvoyée.


### Vues du mailer

Les vues du mailer sont situées dans le répertoire `app/views/nom_de_la_classe_mailer`. La vue spécifique du mailer est connue de la classe car son nom est identique à la méthode du mailer. Dans notre exemple ci-dessus, notre vue du mailer pour la méthode `welcome_email` sera dans `app/views/user_mailer/welcome_email.html.erb` pour la version HTML et `welcome_email.text.erb` pour la version texte brut.

Pour changer la vue du mailer par défaut pour votre action, vous pouvez faire quelque chose comme ceci :

```ruby
class UserMailer < ApplicationMailer
  default from: 'notifications@example.com'

  def welcome_email
    @user = params[:user]
    @url  = 'http://example.com/login'
    mail(to: @user.email,
         subject: 'Bienvenue sur mon super site',
         template_path: 'notifications',
         template_name: 'another')
  end
end
```

Dans ce cas, il recherchera les modèles dans `app/views/notifications` avec le nom `another`. Vous pouvez également spécifier un tableau de chemins pour `template_path`, et ils seront recherchés dans l'ordre.

Si vous souhaitez plus de flexibilité, vous pouvez également passer un bloc et rendre des modèles spécifiques ou même rendre en ligne ou du texte sans utiliser de fichier de modèle :

```ruby
class UserMailer < ApplicationMailer
  default from: 'notifications@example.com'

  def welcome_email
    @user = params[:user]
    @url  = 'http://example.com/login'
    mail(to: @user.email,
         subject: 'Bienvenue sur mon super site') do |format|
      format.html { render 'another_template' }
      format.text { render plain: 'Rendu du texte' }
    end
  end
end
```

Cela rendra le modèle 'another_template.html.erb' pour la partie HTML et utilisera le texte rendu pour la partie texte. La commande de rendu est la même que celle utilisée dans Action Controller, vous pouvez donc utiliser toutes les mêmes options, telles que `:text`, `:inline`, etc.

Si vous souhaitez rendre un modèle situé en dehors du répertoire par défaut `app/views/nom_du_mailer/`, vous pouvez utiliser [`prepend_view_path`][], comme ceci :
```ruby
class UserMailer < ApplicationMailer
  prepend_view_path "custom/path/to/mailer/view"

  # Cela tentera de charger le modèle "custom/path/to/mailer/view/welcome_email"
  def welcome_email
    # ...
  end
end
```

Vous pouvez également envisager d'utiliser la méthode [`append_view_path`][].


#### Mise en cache de la vue du mailer

Vous pouvez effectuer une mise en cache fragmentée dans les vues du mailer, tout comme dans les vues de l'application, en utilisant la méthode [`cache`][].

```html+erb
<% cache do %>
  <%= @company.name %>
<% end %>
```

Et pour utiliser cette fonctionnalité, vous devez configurer votre application comme suit :

```ruby
config.action_mailer.perform_caching = true
```

La mise en cache fragmentée est également prise en charge dans les emails multiparties.
Pour en savoir plus sur la mise en cache, consultez le [guide de mise en cache de Rails](caching_with_rails.html).


### Mise en page des mails d'action

Tout comme les vues des contrôleurs, vous pouvez également avoir des mises en page pour les mails. Le nom de la mise en page doit être le même que celui de votre mailer, par exemple `user_mailer.html.erb` et `user_mailer.text.erb` pour être automatiquement reconnu par votre mailer comme une mise en page.

Pour utiliser un fichier différent, appelez [`layout`][] dans votre mailer :

```ruby
class UserMailer < ApplicationMailer
  layout 'awesome' # utilise awesome.(html|text).erb comme mise en page
end
```

Tout comme avec les vues des contrôleurs, utilisez `yield` pour rendre la vue à l'intérieur de la mise en page.

Vous pouvez également passer une option `layout: 'nom_de_la_mise_en_page'` à l'appel de rendu à l'intérieur du bloc de format pour spécifier des mises en page différentes pour différents formats :

```ruby
class UserMailer < ApplicationMailer
  def welcome_email
    mail(to: params[:user].email) do |format|
      format.html { render layout: 'my_layout' }
      format.text
    end
  end
end
```

Rendra la partie HTML en utilisant le fichier `my_layout.html.erb` et la partie texte avec le fichier habituel `user_mailer.text.erb` s'il existe.


### Prévisualisation des emails

Les prévisualisations des mailers d'action permettent de voir à quoi ressemblent les emails en visitant une URL spéciale qui les affiche. Dans l'exemple ci-dessus, la classe de prévisualisation pour `UserMailer` doit être nommée `UserMailerPreview` et se trouver dans `test/mailers/previews/user_mailer_preview.rb`. Pour voir la prévisualisation de `welcome_email`, implémentez une méthode qui porte le même nom et appelez `UserMailer.welcome_email` :

```ruby
class UserMailerPreview < ActionMailer::Preview
  def welcome_email
    UserMailer.with(user: User.first).welcome_email
  end
end
```

Ensuite, la prévisualisation sera disponible à l'adresse <http://localhost:3000/rails/mailers/user_mailer/welcome_email>.

Si vous modifiez quelque chose dans `app/views/user_mailer/welcome_email.html.erb` ou dans le mailer lui-même, cela se rechargera automatiquement et le rendra pour que vous puissiez voir instantanément le nouveau style. Une liste des prévisualisations est également disponible à l'adresse <http://localhost:3000/rails/mailers>.

Par défaut, ces classes de prévisualisation se trouvent dans `test/mailers/previews`.
Cela peut être configuré en utilisant l'option `preview_paths`. Par exemple, si vous
voulez ajouter `lib/mailer_previews`, vous pouvez le configurer dans
`config/application.rb` :

```ruby
config.action_mailer.preview_paths << "#{Rails.root}/lib/mailer_previews"
```

### Génération d'URL dans les vues des mailers d'action

Contrairement aux contrôleurs, l'instance du mailer n'a aucune connaissance du
requête entrante, vous devrez donc fournir vous-même le paramètre `:host`.

Comme le `:host` est généralement cohérent dans toute l'application, vous pouvez le configurer
globalement dans `config/application.rb` :

```ruby
config.action_mailer.default_url_options = { host: 'example.com' }
```

En raison de ce comportement, vous ne pouvez pas utiliser les helpers `*_path` à l'intérieur d'un email. Au lieu de cela, vous devrez utiliser le helper associé `*_url`. Par exemple, au lieu d'utiliser

```html+erb
<%= link_to 'welcome', welcome_path %>
```

Vous devrez utiliser :

```html+erb
<%= link_to 'welcome', welcome_url %>
```

En utilisant l'URL complète, vos liens fonctionneront désormais dans vos emails.
#### Générer des URLs avec `url_for`

[`url_for`][] génère une URL complète par défaut dans les templates.

Si vous n'avez pas configuré l'option `:host` globalement, assurez-vous de la passer à
`url_for`.


```erb
<%= url_for(host: 'example.com',
            controller: 'welcome',
            action: 'greeting') %>
```


#### Générer des URLs avec des routes nommées

Les clients de messagerie électronique n'ont pas de contexte web et donc les chemins n'ont pas d'URL de base pour former des adresses web complètes. Ainsi, vous devriez toujours utiliser la variante `*_url` des helpers de routes nommées.

Si vous n'avez pas configuré l'option `:host` globalement, assurez-vous de la passer à l'helper d'URL.

```erb
<%= user_url(@user, host: 'example.com') %>
```

NOTE : les liens non-`GET` nécessitent [rails-ujs](https://github.com/rails/rails/blob/main/actionview/app/assets/javascripts) ou
[jQuery UJS](https://github.com/rails/jquery-ujs), et ne fonctionneront pas dans les templates de messagerie. Ils entraîneront des requêtes `GET` normales.

### Ajouter des images dans les vues de l'Action Mailer

Contrairement aux contrôleurs, l'instance du mailer n'a aucune connaissance sur la requête entrante, vous devrez donc fournir vous-même le paramètre `:asset_host`.

Comme le `:asset_host` est généralement cohérent dans toute l'application, vous pouvez le configurer globalement dans `config/application.rb` :

```ruby
config.asset_host = 'http://example.com'
```

Maintenant, vous pouvez afficher une image dans votre e-mail.

```html+erb
<%= image_tag 'image.jpg' %>
```

### Envoi d'e-mails multipart

Action Mailer enverra automatiquement des e-mails multipart si vous avez des templates différents pour la même action. Ainsi, pour notre exemple `UserMailer`, si vous avez `welcome_email.text.erb` et `welcome_email.html.erb` dans `app/views/user_mailer`, Action Mailer enverra automatiquement un e-mail multipart avec les versions HTML et texte configurées comme différentes parties.

L'ordre d'insertion des parties est déterminé par `:parts_order` à l'intérieur de la méthode `ActionMailer::Base.default`.

### Envoi d'e-mails avec des options de livraison dynamiques

Si vous souhaitez remplacer les options de livraison par défaut (par exemple, les informations d'identification SMTP) lors de l'envoi d'e-mails, vous pouvez le faire en utilisant `delivery_method_options` dans l'action du mailer.

```ruby
class UserMailer < ApplicationMailer
  def welcome_email
    @user = params[:user]
    @url  = user_url(@user)
    delivery_options = { user_name: params[:company].smtp_user,
                         password: params[:company].smtp_password,
                         address: params[:company].smtp_host }
    mail(to: @user.email,
         subject: "Veuillez consulter les conditions générales jointes",
         delivery_method_options: delivery_options)
  end
end
```

### Envoi d'e-mails sans rendu de modèle

Il peut arriver que vous souhaitiez ignorer l'étape de rendu du modèle et fournir le corps de l'e-mail sous forme de chaîne. Vous pouvez le faire en utilisant l'option `:body`. Dans de tels cas, n'oubliez pas d'ajouter l'option `:content_type`. Rails utilisera par défaut `text/plain` sinon.

```ruby
class UserMailer < ApplicationMailer
  def welcome_email
    mail(to: params[:user].email,
         body: params[:email_body],
         content_type: "text/html",
         subject: "Déjà rendu !")
  end
end
```

Rappels d'Action Mailer
-----------------------

Action Mailer vous permet de spécifier un [`before_action`][], [`after_action`][] et
[`around_action`][] pour configurer le message, et [`before_deliver`][], [`after_deliver`][] et
[`around_deliver`][] pour contrôler la livraison.

* Les rappels peuvent être spécifiés avec un bloc ou un symbole faisant référence à une méthode dans la classe du mailer, de manière similaire aux contrôleurs.

* Vous pouvez utiliser un `before_action` pour définir des variables d'instance, remplir l'objet mail avec des valeurs par défaut, ou insérer des en-têtes et des pièces jointes par défaut.

```ruby
class InvitationsMailer < ApplicationMailer
  before_action :set_inviter_and_invitee
  before_action { @account = params[:inviter].account }

  default to:       -> { @invitee.email_address },
          from:     -> { common_address(@inviter) },
          reply_to: -> { @inviter.email_address_with_name }

  def account_invitation
    mail subject: "#{@inviter.name} vous a invité à rejoindre leur Basecamp (#{@account.name})"
  end

  def project_invitation
    @project    = params[:project]
    @summarizer = ProjectInvitationSummarizer.new(@project.bucket)

    mail subject: "#{@inviter.name.familiar} vous a ajouté à un projet dans Basecamp (#{@account.name})"
  end

  private
    def set_inviter_and_invitee
      @inviter = params[:inviter]
      @invitee = params[:invitee]
    end
end
```
* Vous pouvez utiliser un `after_action` pour effectuer une configuration similaire à un `before_action`, mais en utilisant des variables d'instance définies dans votre action de mailer.

* L'utilisation d'un rappel `after_action` vous permet également de remplacer les paramètres de méthode de livraison en mettant à jour `mail.delivery_method.settings`.

```ruby
class UserMailer < ApplicationMailer
  before_action { @business, @user = params[:business], params[:user] }

  after_action :set_delivery_options,
               :prevent_delivery_to_guests,
               :set_business_headers

  def feedback_message
  end

  def campaign_message
  end

  private
    def set_delivery_options
      # Vous avez accès à l'instance du mail,
      # aux variables d'instance @business et @user ici
      if @business && @business.has_smtp_settings?
        mail.delivery_method.settings.merge!(@business.smtp_settings)
      end
    end

    def prevent_delivery_to_guests
      if @user && @user.guest?
        mail.perform_deliveries = false
      end
    end

    def set_business_headers
      if @business
        headers["X-SMTPAPI-CATEGORY"] = @business.code
      end
    end
end
```

* Vous pouvez utiliser un `after_delivery` pour enregistrer la livraison du message.

* Les rappels du mailer interrompent le traitement ultérieur si le corps est défini sur une valeur non nulle. `before_deliver` peut être interrompu avec `throw :abort`.


Utilisation des assistants d'Action Mailer
-----------------------------------------

Action Mailer hérite de `AbstractController`, vous avez donc accès à la plupart
des mêmes assistants que dans Action Controller.

Il existe également des méthodes d'assistance spécifiques à Action Mailer disponibles dans
[`ActionMailer::MailHelper`][]. Par exemple, elles permettent d'accéder à l'instance du mailer
depuis votre vue avec [`mailer`][MailHelper#mailer], et d'accéder au message en tant que [`message`][MailHelper#message]:

```erb
<%= stylesheet_link_tag mailer.name.underscore %>
<h1><%= message.subject %></h1>
```


Configuration d'Action Mailer
-----------------------------

Les options de configuration suivantes sont à définir de préférence dans l'un des fichiers d'environnement
(environment.rb, production.rb, etc...)

| Configuration | Description |
|---------------|-------------|
|`logger`|Génère des informations sur l'exécution du mailing si disponible. Peut être défini sur `nil` pour désactiver les journaux. Compatible avec les journaux de Ruby (`Logger`) et `Log4r`.|
|`smtp_settings`|Permet une configuration détaillée pour la méthode de livraison `:smtp` :<ul><li>`:address` - Vous permet d'utiliser un serveur de messagerie distant. Changez-le simplement de sa valeur par défaut `"localhost"`.</li><li>`:port` - Au cas où votre serveur de messagerie ne fonctionnerait pas sur le port 25, vous pouvez le modifier.</li><li>`:domain` - Si vous devez spécifier un domaine HELO, vous pouvez le faire ici.</li><li>`:user_name` - Si votre serveur de messagerie nécessite une authentification, définissez le nom d'utilisateur dans ce paramètre.</li><li>`:password` - Si votre serveur de messagerie nécessite une authentification, définissez le mot de passe dans ce paramètre.</li><li>`:authentication` - Si votre serveur de messagerie nécessite une authentification, vous devez spécifier le type d'authentification ici. Il s'agit d'un symbole et peut être `:plain` (envoie le mot de passe en clair), `:login` (envoie le mot de passe encodé en Base64) ou `:cram_md5` (combine un mécanisme de défi/réponse pour échanger des informations et un algorithme de hachage Message Digest 5 pour hasher des informations importantes).</li><li>`:enable_starttls` - Utilise STARTTLS lors de la connexion à votre serveur SMTP et échoue si non pris en charge. Par défaut, `false`.</li><li>`:enable_starttls_auto` - Détecte si STARTTLS est activé sur votre serveur SMTP et commence à l'utiliser. Par défaut, `true`.</li><li>`:openssl_verify_mode` - Lors de l'utilisation de TLS, vous pouvez définir comment OpenSSL vérifie le certificat. Cela est très utile si vous devez valider un certificat auto-signé et/ou un certificat générique. Vous pouvez utiliser le nom d'une constante de vérification OpenSSL ('none' ou 'peer') ou directement la constante (`OpenSSL::SSL::VERIFY_NONE` ou `OpenSSL::SSL::VERIFY_PEER`).</li><li>`:ssl/:tls` - Active la connexion SMTP pour utiliser SMTP/TLS (SMTPS : connexion SMTP sur TLS directe)</li><li>`:open_timeout` - Nombre de secondes à attendre lors de la tentative d'ouverture d'une connexion.</li><li>`:read_timeout` - Nombre de secondes à attendre avant d'interrompre un appel à `read(2)`.</li></ul>|
|`sendmail_settings`|Vous permet de remplacer les options pour la méthode de livraison `:sendmail`.<ul><li>`:location` - L'emplacement de l'exécutable sendmail. Par défaut, `/usr/sbin/sendmail`.</li><li>`:arguments` - Les arguments de ligne de commande à transmettre à sendmail. Par défaut, `["-i"]`.</li></ul>|
|`raise_delivery_errors`|Indique si des erreurs doivent être levées si l'e-mail ne parvient pas à être livré. Cela ne fonctionne que si le serveur de messagerie externe est configuré pour une livraison immédiate. Par défaut, `true`.|
|`delivery_method`|Définit une méthode de livraison. Les valeurs possibles sont :<ul><li>`:smtp` (par défaut), peut être configuré en utilisant [`config.action_mailer.smtp_settings`][].</li><li>`:sendmail`, peut être configuré en utilisant [`config.action_mailer.sendmail_settings`][].</li><li>`:file` : enregistre les e-mails dans des fichiers ; peut être configuré en utilisant `config.action_mailer.file_settings`.</li><li>`:test` : enregistre les e-mails dans le tableau `ActionMailer::Base.deliveries`.</li></ul>Consultez la [documentation de l'API](https://api.rubyonrails.org/classes/ActionMailer/Base.html) pour plus d'informations.|
|`perform_deliveries`|Détermine si les livraisons sont effectivement effectuées lorsque la méthode `deliver` est invoquée sur le message Mail. Par défaut, elles le sont, mais cela peut être désactivé pour faciliter les tests fonctionnels. Si cette valeur est `false`, le tableau `deliveries` ne sera pas rempli même si `delivery_method` est `:test`.|
|`deliveries`|Conserve un tableau de tous les e-mails envoyés via Action Mailer avec la méthode de livraison `:test`. Très utile pour les tests unitaires et fonctionnels.|
|`delivery_job`|La classe de tâche utilisée avec `deliver_later`. Par défaut, `ActionMailer::MailDeliveryJob`.|
|`deliver_later_queue_name`|Le nom de la file d'attente utilisée avec la tâche `delivery_job` par défaut. Par défaut, la file d'attente Active Job par défaut.|
|`default_options`|Vous permet de définir des valeurs par défaut pour les options de la méthode `mail` (`:from`, `:reply_to`, etc.).|
Pour une description complète des configurations possibles, consultez la section [Configuration d'Action Mailer](configuring.html#configuring-action-mailer) de notre guide Configuring Rails Applications.


### Exemple de configuration d'Action Mailer

Un exemple consisterait à ajouter ce qui suit à votre fichier `config/environments/$RAILS_ENV.rb` approprié :

```ruby
config.action_mailer.delivery_method = :sendmail
# Par défaut :
# config.action_mailer.sendmail_settings = {
#   location: '/usr/sbin/sendmail',
#   arguments: %w[ -i ]
# }
config.action_mailer.perform_deliveries = true
config.action_mailer.raise_delivery_errors = true
config.action_mailer.default_options = { from: 'no-reply@example.com' }
```

### Configuration d'Action Mailer pour Gmail

Action Mailer utilise la gem [Mail](https://github.com/mikel/mail) et accepte une configuration similaire. Ajoutez ceci à votre fichier `config/environments/$RAILS_ENV.rb` pour envoyer via Gmail :

```ruby
config.action_mailer.delivery_method = :smtp
config.action_mailer.smtp_settings = {
  address:         'smtp.gmail.com',
  port:            587,
  domain:          'example.com',
  user_name:       '<username>',
  password:        '<password>',
  authentication:  'plain',
  enable_starttls: true,
  open_timeout:    5,
  read_timeout:    5 }
```

Si vous utilisez une ancienne version de la gem Mail (2.6.x ou antérieure), utilisez `enable_starttls_auto` à la place de `enable_starttls`.

REMARQUE : Google [bloque les connexions](https://support.google.com/accounts/answer/6010255) provenant d'applications qu'il juge moins sécurisées. Vous pouvez modifier vos paramètres Gmail [ici](https://www.google.com/settings/security/lesssecureapps) pour autoriser les tentatives. Si votre compte Gmail a l'authentification à deux facteurs activée, vous devrez définir un [mot de passe d'application](https://myaccount.google.com/apppasswords) et l'utiliser à la place de votre mot de passe habituel.

Test des mailers
--------------

Vous pouvez trouver des instructions détaillées sur la façon de tester vos mailers dans le guide [testing](testing.html#testing-your-mailers).

Interception et observation des emails
-------------------

Action Mailer fournit des hooks dans les méthodes d'observation et d'interception de Mail. Cela vous permet d'enregistrer des classes qui sont appelées pendant le cycle de vie de la livraison des emails.

### Interception des emails

Les intercepteurs vous permettent de modifier les emails avant qu'ils ne soient remis aux agents de livraison. Une classe d'intercepteur doit implémenter la méthode `::delivering_email(message)` qui sera appelée avant l'envoi de l'email.

```ruby
class SandboxEmailInterceptor
  def self.delivering_email(message)
    message.to = ['sandbox@example.com']
  end
end
```

Avant que l'intercepteur puisse faire son travail, vous devez l'enregistrer en utilisant l'option de configuration `interceptors`. Vous pouvez le faire dans un fichier d'initialisation comme `config/initializers/mail_interceptors.rb` :

```ruby
Rails.application.configure do
  if Rails.env.staging?
    config.action_mailer.interceptors = %w[SandboxEmailInterceptor]
  end
end
```

REMARQUE : L'exemple ci-dessus utilise un environnement personnalisé appelé "staging" pour un serveur similaire à la production mais à des fins de test. Vous pouvez lire [Création d'environnements Rails](configuring.html#creating-rails-environments) pour plus d'informations sur les environnements Rails personnalisés.

### Observation des emails

Les observateurs vous donnent accès au message de l'email après son envoi. Une classe d'observateur doit implémenter la méthode `:delivered_email(message)`, qui sera appelée après l'envoi de l'email.

```ruby
class EmailDeliveryObserver
  def self.delivered_email(message)
    EmailDelivery.log(message)
  end
end
```

Comme pour les intercepteurs, vous devez enregistrer les observateurs en utilisant l'option de configuration `observers`. Vous pouvez le faire dans un fichier d'initialisation comme `config/initializers/mail_observers.rb` :

```ruby
Rails.application.configure do
  config.action_mailer.observers = %w[EmailDeliveryObserver]
end
```
[`ActionMailer::Base`]: https://api.rubyonrails.org/classes/ActionMailer/Base.html
[`default`]: https://api.rubyonrails.org/classes/ActionMailer/Base.html#method-c-default
[`mail`]: https://api.rubyonrails.org/classes/ActionMailer/Base.html#method-i-mail
[`ActionMailer::MessageDelivery`]: https://api.rubyonrails.org/classes/ActionMailer/MessageDelivery.html
[`deliver_later`]: https://api.rubyonrails.org/classes/ActionMailer/MessageDelivery.html#method-i-deliver_later
[`deliver_now`]: https://api.rubyonrails.org/classes/ActionMailer/MessageDelivery.html#method-i-deliver_now
[`Mail::Message`]: https://api.rubyonrails.org/classes/Mail/Message.html
[`message`]: https://api.rubyonrails.org/classes/ActionMailer/MessageDelivery.html#method-i-message
[`with`]: https://api.rubyonrails.org/classes/ActionMailer/Parameterized/ClassMethods.html#method-i-with
[`attachments`]: https://api.rubyonrails.org/classes/ActionMailer/Base.html#method-i-attachments
[`headers`]: https://api.rubyonrails.org/classes/ActionMailer/Base.html#method-i-headers
[`email_address_with_name`]: https://api.rubyonrails.org/classes/ActionMailer/Base.html#method-i-email_address_with_name
[`append_view_path`]: https://api.rubyonrails.org/classes/ActionView/ViewPaths/ClassMethods.html#method-i-append_view_path
[`prepend_view_path`]: https://api.rubyonrails.org/classes/ActionView/ViewPaths/ClassMethods.html#method-i-prepend_view_path
[`cache`]: https://api.rubyonrails.org/classes/ActionView/Helpers/CacheHelper.html#method-i-cache
[`layout`]: https://api.rubyonrails.org/classes/ActionView/Layouts/ClassMethods.html#method-i-layout
[`url_for`]: https://api.rubyonrails.org/classes/ActionView/RoutingUrlFor.html#method-i-url_for
[`after_action`]: https://api.rubyonrails.org/classes/AbstractController/Callbacks/ClassMethods.html#method-i-after_action
[`after_deliver`]: https://api.rubyonrails.org/classes/ActionMailer/Callbacks/ClassMethods.html#method-i-after_deliver
[`around_action`]: https://api.rubyonrails.org/classes/AbstractController/Callbacks/ClassMethods.html#method-i-around_action
[`around_deliver`]: https://api.rubyonrails.org/classes/ActionMailer/Callbacks/ClassMethods.html#method-i-around_deliver
[`before_action`]: https://api.rubyonrails.org/classes/AbstractController/Callbacks/ClassMethods.html#method-i-before_action
[`before_deliver`]: https://api.rubyonrails.org/classes/ActionMailer/Callbacks/ClassMethods.html#method-i-before_deliver
[`ActionMailer::MailHelper`]: https://api.rubyonrails.org/classes/ActionMailer/MailHelper.html
[MailHelper#mailer]: https://api.rubyonrails.org/classes/ActionMailer/MailHelper.html#method-i-mailer
[MailHelper#message]: https://api.rubyonrails.org/classes/ActionMailer/MailHelper.html#method-i-message
[`config.action_mailer.sendmail_settings`]: configuring.html#config-action-mailer-sendmail-settings
[`config.action_mailer.smtp_settings`]: configuring.html#config-action-mailer-smtp-settings
