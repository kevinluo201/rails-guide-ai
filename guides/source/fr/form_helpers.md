**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 975163c53746728404fb3a3658fbd0f6
Action View Form Helpers
========================

Les formulaires dans les applications web sont une interface essentielle pour la saisie des utilisateurs. Cependant, la création et la maintenance du balisage des formulaires peuvent rapidement devenir fastidieuses en raison de la nécessité de gérer les noms des contrôles de formulaire et leurs nombreux attributs. Rails simplifie cette complexité en fournissant des assistants de vue pour générer le balisage des formulaires. Cependant, étant donné que ces assistants ont des cas d'utilisation différents, les développeurs doivent connaître les différences entre les méthodes d'assistance avant de les utiliser.

Après avoir lu ce guide, vous saurez :

* Comment créer des formulaires de recherche et des formulaires génériques similaires ne représentant aucun modèle spécifique dans votre application.
* Comment créer des formulaires centrés sur le modèle pour créer et modifier des enregistrements spécifiques de la base de données.
* Comment générer des listes déroulantes à partir de plusieurs types de données.
* Quels assistants de date et d'heure Rails fournit.
* Ce qui rend un formulaire de téléchargement de fichier différent.
* Comment envoyer des formulaires vers des ressources externes et spécifier le paramètre `authenticity_token`.
* Comment construire des formulaires complexes.

--------------------------------------------------------------------------------

NOTE : Ce guide n'a pas vocation à être une documentation complète des assistants de formulaire disponibles et de leurs arguments. Veuillez consulter [la documentation de l'API Rails](https://api.rubyonrails.org/classes/ActionView/Helpers.html) pour une référence complète de tous les assistants disponibles.

Gérer les formulaires de base
------------------------

L'assistant de formulaire principal est [`form_with`](https://api.rubyonrails.org/classes/ActionView/Helpers/FormHelper.html#method-i-form_with).

```erb
<%= form_with do |form| %>
  Contenu du formulaire
<% end %>
```

Lorsqu'il est appelé sans arguments de cette manière, il crée une balise de formulaire qui, lorsqu'elle est soumise, enverra une requête POST à la page actuelle. Par exemple, en supposant que la page actuelle est une page d'accueil, le HTML généré ressemblera à ceci :

```html
<form accept-charset="UTF-8" action="/" method="post">
  <input name="authenticity_token" type="hidden" value="J7CBxfHalt49OSHp27hblqK20c9PgwJ108nDHX/8Cts=" />
  Contenu du formulaire
</form>
```

Vous remarquerez que le HTML contient un élément `input` avec le type `hidden`. Cet élément `input` est important, car les formulaires autres que GET ne peuvent pas être soumis avec succès sans lui. L'élément `input` caché avec le nom `authenticity_token` est une fonctionnalité de sécurité de Rails appelée **protection contre les attaques de falsification de requête intersite**, et les assistants de formulaire le génèrent pour chaque formulaire autre que GET (à condition que cette fonctionnalité de sécurité soit activée). Vous pouvez en savoir plus à ce sujet dans le guide [Sécuriser les applications Rails](security.html#cross-site-request-forgery-csrf).

### Un formulaire de recherche générique

L'un des formulaires les plus basiques que l'on trouve sur le web est un formulaire de recherche. Ce formulaire contient :

* un élément de formulaire avec la méthode "GET",
* une étiquette pour l'entrée,
* un élément d'entrée de texte, et
* un élément de soumission.

Pour créer ce formulaire, vous utiliserez `form_with` et l'objet constructeur de formulaire qu'il renvoie. Comme ceci :

```erb
<%= form_with url: "/search", method: :get do |form| %>
  <%= form.label :query, "Rechercher :" %>
  <%= form.text_field :query %>
  <%= form.submit "Rechercher" %>
<% end %>
```

Cela générera le HTML suivant :

```html
<form action="/search" method="get" accept-charset="UTF-8" >
  <label for="query">Rechercher :</label>
  <input id="query" name="query" type="text" />
  <input name="commit" type="submit" value="Rechercher" data-disable-with="Rechercher" />
</form>
```

CONSEIL : En passant `url: my_specified_path` à `form_with`, vous indiquez au formulaire où effectuer la requête. Cependant, comme expliqué ci-dessous, vous pouvez également passer des objets Active Record au formulaire.

CONSEIL : Pour chaque entrée de formulaire, un attribut ID est généré à partir de son nom (`"query"` dans l'exemple ci-dessus). Ces ID peuvent être très utiles pour le style CSS ou la manipulation des contrôles de formulaire avec JavaScript.

IMPORTANT : Utilisez la méthode "GET" pour les formulaires de recherche. Cela permet aux utilisateurs de mettre en signet une recherche spécifique et d'y revenir. Plus généralement, Rails vous encourage à utiliser la méthode HTTP appropriée pour une action.

### Assistants pour générer des éléments de formulaire

L'objet constructeur de formulaire renvoyé par `form_with` fournit de nombreuses méthodes d'assistance pour générer des éléments de formulaire tels que des champs de texte, des cases à cocher et des boutons radio. Le premier paramètre de ces méthodes est toujours le nom de l'entrée. Lorsque le formulaire est soumis, le nom sera transmis avec les données du formulaire et arrivera dans les `params` du contrôleur avec la valeur saisie par l'utilisateur pour ce champ. Par exemple, si le formulaire contient `<%= form.text_field :query %>`, vous pourriez obtenir la valeur de ce champ dans le contrôleur avec `params[:query]`.

Lors de la dénomination des entrées, Rails utilise certaines conventions qui permettent de soumettre des paramètres avec des valeurs non scalaires telles que des tableaux ou des hachages, qui seront également accessibles dans `params`. Vous pouvez en savoir plus à ce sujet dans la section [Comprendre les conventions de dénomination des paramètres](#understanding-parameter-naming-conventions) de ce guide. Pour plus de détails sur l'utilisation précise de ces assistants, veuillez vous référer à la [documentation de l'API](https://api.rubyonrails.org/classes/ActionView/Helpers/FormTagHelper.html).
#### Cases à cocher

Les cases à cocher sont des contrôles de formulaire qui permettent à l'utilisateur de choisir parmi un ensemble d'options qu'il peut activer ou désactiver :

```erb
<%= form.check_box :pet_dog %>
<%= form.label :pet_dog, "J'ai un chien" %>
<%= form.check_box :pet_cat %>
<%= form.label :pet_cat, "J'ai un chat" %>
```

Cela génère le code suivant :

```html
<input type="checkbox" id="pet_dog" name="pet_dog" value="1" />
<label for="pet_dog">J'ai un chien</label>
<input type="checkbox" id="pet_cat" name="pet_cat" value="1" />
<label for="pet_cat">J'ai un chat</label>
```

Le premier paramètre de [`check_box`](https://api.rubyonrails.org/classes/ActionView/Helpers/FormBuilder.html#method-i-check_box) est le nom de l'entrée. Les valeurs de la case à cocher (les valeurs qui apparaîtront dans `params`) peuvent éventuellement être spécifiées à l'aide des troisième et quatrième paramètres. Consultez la documentation de l'API pour plus de détails.

#### Boutons radio

Les boutons radio, bien qu'ils ressemblent aux cases à cocher, sont des contrôles qui spécifient un ensemble d'options mutuellement exclusives (c'est-à-dire que l'utilisateur ne peut en choisir qu'une seule) :

```erb
<%= form.radio_button :age, "child" %>
<%= form.label :age_child, "Je suis âgé de moins de 21 ans" %>
<%= form.radio_button :age, "adult" %>
<%= form.label :age_adult, "Je suis âgé de plus de 21 ans" %>
```

Résultat :

```html
<input type="radio" id="age_child" name="age" value="child" />
<label for="age_child">Je suis âgé de moins de 21 ans</label>
<input type="radio" id="age_adult" name="age" value="adult" />
<label for="age_adult">Je suis âgé de plus de 21 ans</label>
```

Le deuxième paramètre de [`radio_button`](https://api.rubyonrails.org/classes/ActionView/Helpers/FormBuilder.html#method-i-radio_button) est la valeur de l'entrée. Comme ces deux boutons radio partagent le même nom (`age`), l'utilisateur ne pourra en sélectionner qu'un seul, et `params[:age]` contiendra soit `"child"` soit `"adult"`.

NOTE : Utilisez toujours des étiquettes pour les cases à cocher et les boutons radio. Elles associent du texte à une option spécifique et, en étendant la zone cliquable, facilitent la sélection par les utilisateurs.

### Autres aides intéressantes

D'autres contrôles de formulaire valent la peine d'être mentionnés, tels que les zones de texte, les champs masqués, les champs de mot de passe, les champs numériques, les champs de date et d'heure, et bien d'autres encore :

```erb
<%= form.text_area :message, size: "70x5" %>
<%= form.hidden_field :parent_id, value: "foo" %>
<%= form.password_field :password %>
<%= form.number_field :price, in: 1.0..20.0, step: 0.5 %>
<%= form.range_field :discount, in: 1..100 %>
<%= form.date_field :born_on %>
<%= form.time_field :started_at %>
<%= form.datetime_local_field :graduation_day %>
<%= form.month_field :birthday_month %>
<%= form.week_field :birthday_week %>
<%= form.search_field :name %>
<%= form.email_field :address %>
<%= form.telephone_field :phone %>
<%= form.url_field :homepage %>
<%= form.color_field :favorite_color %>
```

Résultat :

```html
<textarea name="message" id="message" cols="70" rows="5"></textarea>
<input type="hidden" name="parent_id" id="parent_id" value="foo" />
<input type="password" name="password" id="password" />
<input type="number" name="price" id="price" step="0.5" min="1.0" max="20.0" />
<input type="range" name="discount" id="discount" min="1" max="100" />
<input type="date" name="born_on" id="born_on" />
<input type="time" name="started_at" id="started_at" />
<input type="datetime-local" name="graduation_day" id="graduation_day" />
<input type="month" name="birthday_month" id="birthday_month" />
<input type="week" name="birthday_week" id="birthday_week" />
<input type="search" name="name" id="name" />
<input type="email" name="address" id="address" />
<input type="tel" name="phone" id="phone" />
<input type="url" name="homepage" id="homepage" />
<input type="color" name="favorite_color" id="favorite_color" value="#000000" />
```

Les champs masqués ne sont pas affichés à l'utilisateur mais contiennent des données comme n'importe quelle entrée textuelle. Les valeurs à l'intérieur peuvent être modifiées avec JavaScript.

IMPORTANT : Les champs de recherche, de téléphone, de date, d'heure, de couleur, de date et d'heure, de mois, de semaine, d'URL, d'e-mail, de nombre et de plage sont des contrôles HTML5. Si vous souhaitez que votre application offre une expérience cohérente dans les anciens navigateurs, vous aurez besoin d'un polyfill HTML5 (fourni par CSS et/ou JavaScript). Il ne manque certainement [pas de solutions à cela](https://github.com/Modernizr/Modernizr/wiki/HTML5-Cross-Browser-Polyfills), bien que l'outil populaire du moment soit [Modernizr](https://modernizr.com/), qui offre un moyen simple d'ajouter des fonctionnalités en fonction de la présence de fonctionnalités HTML5 détectées.

CONSEIL : Si vous utilisez des champs de saisie de mot de passe (à n'importe quelle fin), vous voudrez peut-être configurer votre application pour empêcher l'enregistrement de ces paramètres. Vous pouvez en apprendre davantage à ce sujet dans le guide [Sécuriser les applications Rails](security.html#logging).

Traitement des objets de modèle
-------------------------------

### Lier un formulaire à un objet

L'argument `:model` de `form_with` nous permet de lier l'objet form builder à un objet de modèle. Cela signifie que le formulaire sera limité à cet objet de modèle, et les champs du formulaire seront pré-remplis avec les valeurs de cet objet de modèle.

Par exemple, si nous avons un objet de modèle `@article` comme ceci :

```ruby
@article = Article.find(42)
# => #<Article id: 42, title: "My Title", body: "My Body">
```

Le formulaire suivant :

```erb
<%= form_with model: @article do |form| %>
  <%= form.text_field :title %>
  <%= form.text_area :body, size: "60x10" %>
  <%= form.submit %>
<% end %>
```

Donne le résultat suivant :

```html
<form action="/articles/42" method="post" accept-charset="UTF-8" >
  <input name="authenticity_token" type="hidden" value="..." />
  <input type="text" name="article[title]" id="article_title" value="My Title" />
  <textarea name="article[body]" id="article_body" cols="60" rows="10">
    My Body
  </textarea>
  <input type="submit" name="commit" value="Update Article" data-disable-with="Update Article">
</form>
```
Il y a plusieurs choses à remarquer ici :

* Le formulaire `action` est automatiquement rempli avec une valeur appropriée pour `@article`.
* Les champs du formulaire sont automatiquement remplis avec les valeurs correspondantes de `@article`.
* Les noms des champs du formulaire sont définis avec `article[...]`. Cela signifie que `params[:article]` sera un hash contenant les valeurs de tous ces champs. Vous pouvez en savoir plus sur la signification des noms d'entrée dans le chapitre [Comprendre les conventions de nommage des paramètres](#understanding-parameter-naming-conventions) de ce guide.
* Le bouton de soumission se voit automatiquement attribuer une valeur de texte appropriée.

CONSEIL : En général, vos entrées refléteront les attributs du modèle. Cependant, ce n'est pas obligatoire ! Si vous avez besoin d'autres informations, vous pouvez les inclure dans votre formulaire de la même manière qu'avec les attributs et y accéder via `params[:article][:my_nifty_non_attribute_input]`.

#### L'assistant `fields_for`

L'assistant [`fields_for`][] crée une liaison similaire mais sans générer une balise `<form>`. Cela peut être utilisé pour générer des champs pour des objets de modèle supplémentaires dans le même formulaire. Par exemple, si vous avez un modèle `Person` avec un modèle associé `ContactDetail`, vous pouvez créer un seul formulaire pour les deux comme ceci :

```erb
<%= form_with model: @person do |person_form| %>
  <%= person_form.text_field :name %>
  <%= fields_for :contact_detail, @person.contact_detail do |contact_detail_form| %>
    <%= contact_detail_form.text_field :phone_number %>
  <% end %>
<% end %>
```

Ce qui produit la sortie suivante :

```html
<form action="/people" accept-charset="UTF-8" method="post">
  <input type="hidden" name="authenticity_token" value="bL13x72pldyDD8bgtkjKQakJCpd4A8JdXGbfksxBDHdf1uC0kCMqe2tvVdUYfidJt0fj3ihC4NxiVHv8GVYxJA==" />
  <input type="text" name="person[name]" id="person_name" />
  <input type="text" name="contact_detail[phone_number]" id="contact_detail_phone_number" />
</form>
```

L'objet renvoyé par `fields_for` est un constructeur de formulaire similaire à celui renvoyé par `form_with`.


### S'appuyer sur l'identification des enregistrements

Le modèle Article est directement disponible pour les utilisateurs de l'application, donc - en suivant les meilleures pratiques de développement avec Rails - vous devriez le déclarer **une ressource** :

```ruby
resources :articles
```

CONSEIL : La déclaration d'une ressource a plusieurs effets secondaires. Consultez le guide [Rails Routing from the Outside In](routing.html#resource-routing-the-rails-default) pour plus d'informations sur la configuration et l'utilisation des ressources.

Lorsque vous travaillez avec des ressources RESTful, les appels à `form_with` peuvent être considérablement simplifiés si vous vous appuyez sur **l'identification des enregistrements**. En bref, vous pouvez simplement passer l'instance du modèle et laisser Rails déterminer le nom du modèle et le reste. Dans ces deux exemples, le style long et le style court donnent le même résultat :

```ruby
## Création d'un nouvel article
# style long :
form_with(model: @article, url: articles_path)
# style court :
form_with(model: @article)

## Modification d'un article existant
# style long :
form_with(model: @article, url: article_path(@article), method: "patch")
# style court :
form_with(model: @article)
```

Remarquez comment l'appel à `form_with` en style court est pratique et identique, que l'enregistrement soit nouveau ou existant. L'identification des enregistrements est suffisamment intelligente pour déterminer si l'enregistrement est nouveau en demandant `record.persisted?`. Elle sélectionne également le chemin de soumission correct et le nom en fonction de la classe de l'objet.

Si vous avez une [ressource singulière](routing.html#singular-resources), vous devrez appeler `resource` et `resolve` pour que cela fonctionne avec `form_with` :

```ruby
resource :geocoder
resolve('Geocoder') { [:geocoder] }
```

AVERTISSEMENT : Lorsque vous utilisez l'ITM (héritage de table unique) avec vos modèles, vous ne pouvez pas vous appuyer sur l'identification des enregistrements sur une sous-classe si seule leur classe parent est déclarée comme ressource. Vous devrez spécifier `:url` et `:scope` (le nom du modèle) explicitement.

#### Gérer les espaces de noms

Si vous avez créé des routes avec des espaces de noms, `form_with` dispose également d'une syntaxe pratique pour cela. Si votre application a un espace de noms admin, alors

```ruby
form_with model: [:admin, @article]
```

créera un formulaire qui soumet à `ArticlesController` à l'intérieur de l'espace de noms admin (soumettant à `admin_article_path(@article)` dans le cas d'une mise à jour). Si vous avez plusieurs niveaux d'espaces de noms, la syntaxe est similaire :

```ruby
form_with model: [:admin, :management, @article]
```

Pour plus d'informations sur le système de routage de Rails et les conventions associées, veuillez consulter le guide [Rails Routing from the Outside In](routing.html).

### Comment fonctionnent les formulaires avec les méthodes PATCH, PUT ou DELETE ?

Le framework Rails encourage la conception RESTful de vos applications, ce qui signifie que vous allez effectuer de nombreuses requêtes "PATCH", "PUT" et "DELETE" (en plus de "GET" et "POST"). Cependant, la plupart des navigateurs _ne prennent pas en charge_ les méthodes autres que "GET" et "POST" lorsqu'il s'agit de soumettre des formulaires.

Rails contourne ce problème en émulant les autres méthodes via POST avec une entrée masquée nommée `"_method"`, qui est définie pour refléter la méthode souhaitée :

```ruby
form_with(url: search_path, method: "patch")
```

Sortie :

```html
<form accept-charset="UTF-8" action="/search" method="post">
  <input name="_method" type="hidden" value="patch" />
  <input name="authenticity_token" type="hidden" value="f755bb0ed134b76c432144748a6d4b7a7ddf2b71" />
  <!-- ... -->
</form>
```
Lors de l'analyse des données POSTées, Rails prend en compte le paramètre spécial `_method` et agit comme si la méthode HTTP était celle spécifiée à l'intérieur de celui-ci ("PATCH" dans cet exemple).

Lors du rendu d'un formulaire, les boutons de soumission peuvent remplacer l'attribut `method` déclaré grâce au mot-clé `formmethod:` :

```erb
<%= form_with url: "/posts/1", method: :patch do |form| %>
  <%= form.button "Supprimer", formmethod: :delete, data: { confirm: "Êtes-vous sûr ?" } %>
  <%= form.button "Mettre à jour" %>
<% end %>
```

De la même manière que les éléments `<form>`, la plupart des navigateurs ne prennent pas en charge la substitution des méthodes de formulaire déclarées via [formmethod][] autres que "GET" et "POST".

Rails contourne ce problème en émulant d'autres méthodes via POST grâce à une combinaison des attributs [formmethod][], [value][button-value] et [name][button-name] :

```html
<form accept-charset="UTF-8" action="/posts/1" method="post">
  <input name="_method" type="hidden" value="patch" />
  <input name="authenticity_token" type="hidden" value="f755bb0ed134b76c432144748a6d4b7a7ddf2b71" />
  <!-- ... -->

  <button type="submit" formmethod="post" name="_method" value="delete" data-confirm="Êtes-vous sûr ?">Supprimer</button>
  <button type="submit" name="button">Mettre à jour</button>
</form>
```


Création facile de listes déroulantes
-------------------------------------

Les listes déroulantes en HTML nécessitent une quantité importante de balises - un élément `<option>` pour chaque option à choisir. Rails fournit donc des méthodes d'aide pour réduire cette charge.

Par exemple, supposons que nous ayons une liste de villes parmi lesquelles l'utilisateur peut choisir. Nous pouvons utiliser l'aide [`select`](https://api.rubyonrails.org/classes/ActionView/Helpers/FormBuilder.html#method-i-select) de la manière suivante :

```erb
<%= form.select :city, ["Berlin", "Chicago", "Madrid"] %>
```

Résultat :

```html
<select name="city" id="city">
  <option value="Berlin">Berlin</option>
  <option value="Chicago">Chicago</option>
  <option value="Madrid">Madrid</option>
</select>
```

Nous pouvons également spécifier des valeurs `<option>` différentes de leurs libellés :

```erb
<%= form.select :city, [["Berlin", "BE"], ["Chicago", "CHI"], ["Madrid", "MD"]] %>
```

Résultat :

```html
<select name="city" id="city">
  <option value="BE">Berlin</option>
  <option value="CHI">Chicago</option>
  <option value="MD">Madrid</option>
</select>
```

Ainsi, l'utilisateur verra le nom complet de la ville, mais `params[:city]` sera l'une des valeurs `"BE"`, `"CHI"` ou `"MD"`.

Enfin, nous pouvons spécifier un choix par défaut pour la liste déroulante avec l'argument `:selected` :

```erb
<%= form.select :city, [["Berlin", "BE"], ["Chicago", "CHI"], ["Madrid", "MD"]], selected: "CHI" %>
```

Résultat :

```html
<select name="city" id="city">
  <option value="BE">Berlin</option>
  <option value="CHI" selected="selected">Chicago</option>
  <option value="MD">Madrid</option>
</select>
```

### Groupes d'options

Dans certains cas, nous souhaitons améliorer l'expérience utilisateur en regroupant des options liées. Nous pouvons le faire en passant un `Hash` (ou un `Array` comparable) à `select` :

```erb
<%= form.select :city,
      {
        "Europe" => [ ["Berlin", "BE"], ["Madrid", "MD"] ],
        "Amérique du Nord" => [ ["Chicago", "CHI"] ],
      },
      selected: "CHI" %>
```

Résultat :

```html
<select name="city" id="city">
  <optgroup label="Europe">
    <option value="BE">Berlin</option>
    <option value="MD">Madrid</option>
  </optgroup>
  <optgroup label="Amérique du Nord">
    <option value="CHI" selected="selected">Chicago</option>
  </optgroup>
</select>
```

### Listes déroulantes et objets de modèle

Comme pour les autres contrôles de formulaire, une liste déroulante peut être liée à un attribut de modèle. Par exemple, si nous avons un objet de modèle `@person` comme suit :

```ruby
@person = Person.new(city: "MD")
```

Le formulaire suivant :

```erb
<%= form_with model: @person do |form| %>
  <%= form.select :city, [["Berlin", "BE"], ["Chicago", "CHI"], ["Madrid", "MD"]] %>
<% end %>
```

Affiche une liste déroulante comme suit :

```html
<select name="person[city]" id="person_city">
  <option value="BE">Berlin</option>
  <option value="CHI">Chicago</option>
  <option value="MD" selected="selected">Madrid</option>
</select>
```

Remarquez que l'option appropriée a été automatiquement marquée `selected="selected"`. Étant donné que cette liste déroulante était liée à un modèle, nous n'avons pas besoin de spécifier un argument `:selected` !

### Sélection de fuseau horaire et de pays

Pour tirer parti de la prise en charge des fuseaux horaires dans Rails, vous devez demander à vos utilisateurs dans quel fuseau horaire ils se trouvent. Cela nécessiterait de générer des options de sélection à partir d'une liste prédéfinie d'objets [`ActiveSupport::TimeZone`](https://api.rubyonrails.org/classes/ActiveSupport/TimeZone.html), mais vous pouvez simplement utiliser l'aide [`time_zone_select`](https://api.rubyonrails.org/classes/ActionView/Helpers/FormBuilder.html#method-i-time_zone_select) qui l'encapsule déjà :

```erb
<%= form.time_zone_select :time_zone %>
```

Rails _avait_ une aide `country_select` pour choisir les pays, mais celle-ci a été extraite dans le plugin [country_select](https://github.com/stefanpenner/country_select).

Utilisation des aides de formulaire pour les dates et heures
-----------------------------------------------------------

Si vous ne souhaitez pas utiliser les entrées de date et d'heure HTML5, Rails propose des aides de formulaire alternatives pour les dates et heures qui affichent des listes déroulantes simples. Ces aides génèrent une liste déroulante pour chaque composant temporel (par exemple, année, mois, jour, etc.). Par exemple, si nous avons un objet de modèle `@person` comme suit :

```ruby
@person = Person.new(birth_date: Date.new(1995, 12, 21))
```

Le formulaire suivant :

```erb
<%= form_with model: @person do |form| %>
  <%= form.date_select :birth_date %>
<% end %>
```

Affiche des listes déroulantes comme suit :

```html
<select name="person[birth_date(1i)]" id="person_birth_date_1i">
  <option value="1990">1990</option>
  <option value="1991">1991</option>
  <option value="1992">1992</option>
  <option value="1993">1993</option>
  <option value="1994">1994</option>
  <option value="1995" selected="selected">1995</option>
  <option value="1996">1996</option>
  <option value="1997">1997</option>
  <option value="1998">1998</option>
  <option value="1999">1999</option>
  <option value="2000">2000</option>
</select>
<select name="person[birth_date(2i)]" id="person_birth_date_2i">
  <option value="1">Janvier</option>
  <option value="2">Février</option>
  <option value="3">Mars</option>
  <option value="4">Avril</option>
  <option value="5">Mai</option>
  <option value="6">Juin</option>
  <option value="7">Juillet</option>
  <option value="8">Août</option>
  <option value="9">Septembre</option>
  <option value="10">Octobre</option>
  <option value="11">Novembre</option>
  <option value="12" selected="selected">Décembre</option>
</select>
<select name="person[birth_date(3i)]" id="person_birth_date_3i">
  <option value="1">1</option>
  ...
  <option value="21" selected="selected">21</option>
  ...
  <option value="31">31</option>
</select>
```
Remarquez que, lorsque le formulaire est soumis, il n'y aura pas de valeur unique dans le hachage `params` qui contient la date complète. Au lieu de cela, il y aura plusieurs valeurs avec des noms spéciaux comme `"birth_date(1i)"`. Active Record sait comment assembler ces valeurs spécialement nommées en une date ou une heure complète, en fonction du type déclaré de l'attribut du modèle. Ainsi, nous pouvons transmettre `params[:person]` à `Person.new` ou `Person#update` comme nous le ferions si le formulaire utilisait un seul champ pour représenter la date complète.

En plus de l'aide [`date_select`](https://api.rubyonrails.org/classes/ActionView/Helpers/FormBuilder.html#method-i-date_select), Rails fournit [`time_select`](https://api.rubyonrails.org/classes/ActionView/Helpers/FormBuilder.html#method-i-time_select) et [`datetime_select`](https://api.rubyonrails.org/classes/ActionView/Helpers/FormBuilder.html#method-i-datetime_select).

### Boîtes de sélection pour les composants temporels individuels

Rails fournit également des aides pour afficher des boîtes de sélection pour les composants temporels individuels : [`select_year`](https://api.rubyonrails.org/classes/ActionView/Helpers/DateHelper.html#method-i-select_year), [`select_month`](https://api.rubyonrails.org/classes/ActionView/Helpers/DateHelper.html#method-i-select_month), [`select_day`](https://api.rubyonrails.org/classes/ActionView/Helpers/DateHelper.html#method-i-select_day), [`select_hour`](https://api.rubyonrails.org/classes/ActionView/Helpers/DateHelper.html#method-i-select_hour), [`select_minute`](https://api.rubyonrails.org/classes/ActionView/Helpers/DateHelper.html#method-i-select_minute) et [`select_second`](https://api.rubyonrails.org/classes/ActionView/Helpers/DateHelper.html#method-i-select_second). Ces aides sont des méthodes "brutes", ce qui signifie qu'elles ne sont pas appelées sur une instance de constructeur de formulaire. Par exemple :

```erb
<%= select_year 1999, prefix: "party" %>
```

Affiche une boîte de sélection comme :

```html
<select name="party[year]" id="party_year">
  <option value="1994">1994</option>
  <option value="1995">1995</option>
  <option value="1996">1996</option>
  <option value="1997">1997</option>
  <option value="1998">1998</option>
  <option value="1999" selected="selected">1999</option>
  <option value="2000">2000</option>
  <option value="2001">2001</option>
  <option value="2002">2002</option>
  <option value="2003">2003</option>
  <option value="2004">2004</option>
</select>
```

Pour chacune de ces aides, vous pouvez spécifier un objet de date ou d'heure au lieu d'un nombre comme valeur par défaut, et le composant temporel approprié sera extrait et utilisé.

Choix à partir d'une collection d'objets arbitraires
---------------------------------------------------

Parfois, nous voulons générer un ensemble de choix à partir d'une collection d'objets arbitraires. Par exemple, si nous avons un modèle `City` et une association correspondante `belongs_to :city` :

```ruby
class City < ApplicationRecord
end

class Person < ApplicationRecord
  belongs_to :city
end
```

```ruby
City.order(:name).map { |city| [city.name, city.id] }
# => [["Berlin", 3], ["Chicago", 1], ["Madrid", 2]]
```

Alors nous pouvons permettre à l'utilisateur de choisir une ville dans la base de données avec le formulaire suivant :

```erb
<%= form_with model: @person do |form| %>
  <%= form.select :city_id, City.order(:name).map { |city| [city.name, city.id] } %>
<% end %>
```

NOTE : Lorsque vous affichez un champ pour une association `belongs_to`, vous devez spécifier le nom de la clé étrangère (`city_id` dans l'exemple ci-dessus), plutôt que le nom de l'association elle-même.

Cependant, Rails fournit des aides qui génèrent des choix à partir d'une collection sans avoir à les parcourir explicitement. Ces aides déterminent la valeur et l'étiquette de texte de chaque choix en appelant des méthodes spécifiées sur chaque objet de la collection.

### L'aide `collection_select`

Pour générer une boîte de sélection, nous pouvons utiliser [`collection_select`](https://api.rubyonrails.org/classes/ActionView/Helpers/FormBuilder.html#method-i-collection_select) :

```erb
<%= form.collection_select :city_id, City.order(:name), :id, :name %>
```

Sortie :

```html
<select name="person[city_id]" id="person_city_id">
  <option value="3">Berlin</option>
  <option value="1">Chicago</option>
  <option value="2">Madrid</option>
</select>
```

NOTE : Avec `collection_select`, nous spécifions d'abord la méthode de valeur (`:id` dans l'exemple ci-dessus), puis la méthode d'étiquette de texte (`:name` dans l'exemple ci-dessus). Cela est contraire à l'ordre utilisé lors de la spécification des choix pour l'aide `select`, où l'étiquette de texte vient en premier et la valeur en second.

### L'aide `collection_radio_buttons`

Pour générer un ensemble de boutons radio, nous pouvons utiliser [`collection_radio_buttons`](https://api.rubyonrails.org/classes/ActionView/Helpers/FormBuilder.html#method-i-collection_radio_buttons) :

```erb
<%= form.collection_radio_buttons :city_id, City.order(:name), :id, :name %>
```

Sortie :

```html
<input type="radio" name="person[city_id]" value="3" id="person_city_id_3">
<label for="person_city_id_3">Berlin</label>

<input type="radio" name="person[city_id]" value="1" id="person_city_id_1">
<label for="person_city_id_1">Chicago</label>

<input type="radio" name="person[city_id]" value="2" id="person_city_id_2">
<label for="person_city_id_2">Madrid</label>
```

### L'aide `collection_check_boxes`

Pour générer un ensemble de cases à cocher - par exemple, pour prendre en charge une association `has_and_belongs_to_many` - nous pouvons utiliser [`collection_check_boxes`](https://api.rubyonrails.org/classes/ActionView/Helpers/FormBuilder.html#method-i-collection_check_boxes) :

```erb
<%= form.collection_check_boxes :interest_ids, Interest.order(:name), :id, :name %>
```

Sortie :

```html
<input type="checkbox" name="person[interest_id][]" value="3" id="person_interest_id_3">
<label for="person_interest_id_3">Engineering</label>

<input type="checkbox" name="person[interest_id][]" value="4" id="person_interest_id_4">
<label for="person_interest_id_4">Math</label>

<input type="checkbox" name="person[interest_id][]" value="1" id="person_interest_id_1">
<label for="person_interest_id_1">Science</label>

<input type="checkbox" name="person[interest_id][]" value="2" id="person_interest_id_2">
<label for="person_interest_id_2">Technology</label>
```

Téléchargement de fichiers
--------------------------

Une tâche courante consiste à télécharger un fichier quelconque, qu'il s'agisse d'une photo d'une personne ou d'un fichier CSV contenant des données à traiter. Les champs de téléchargement de fichiers peuvent être affichés avec l'aide [`file_field`](https://api.rubyonrails.org/classes/ActionView/Helpers/FormBuilder.html#method-i-file_field).

```erb
<%= form_with model: @person do |form| %>
  <%= form.file_field :picture %>
<% end %>
```

La chose la plus importante à retenir avec les téléchargements de fichiers est que l'attribut `enctype` du formulaire rendu **doit** être défini sur "multipart/form-data". Cela se fait automatiquement si vous utilisez un `file_field` à l'intérieur d'un `form_with`. Vous pouvez également définir manuellement l'attribut :

```erb
<%= form_with url: "/uploads", multipart: true do |form| %>
  <%= file_field_tag :picture %>
<% end %>
```

Notez que, conformément aux conventions de `form_with`, les noms de champ dans les deux formulaires ci-dessus seront également différents. C'est-à-dire que le nom de champ dans le premier formulaire sera `person[picture]` (accessible via `params[:person][:picture]`), et le nom de champ dans le deuxième formulaire sera simplement `picture` (accessible via `params[:picture]`).
### Ce qui est téléchargé

L'objet dans le hachage `params` est une instance de [`ActionDispatch::Http::UploadedFile`](https://api.rubyonrails.org/classes/ActionDispatch/Http/UploadedFile.html). Le code suivant enregistre le fichier téléchargé dans `#{Rails.root}/public/uploads` sous le même nom que le fichier d'origine.

```ruby
def upload
  uploaded_file = params[:picture]
  File.open(Rails.root.join('public', 'uploads', uploaded_file.original_filename), 'wb') do |file|
    file.write(uploaded_file.read)
  end
end
```

Une fois qu'un fichier a été téléchargé, il existe une multitude de tâches potentielles, allant de l'endroit où stocker les fichiers (sur le disque, Amazon S3, etc.), à leur association avec des modèles, en passant par le redimensionnement des fichiers image et la génération de miniatures, etc. [Active Storage](active_storage_overview.html) est conçu pour aider à ces tâches.

Personnalisation des constructeurs de formulaires
------------------------------------------------

L'objet renvoyé par `form_with` et `fields_for` est une instance de [`ActionView::Helpers::FormBuilder`](https://api.rubyonrails.org/classes/ActionView/Helpers/FormBuilder.html). Les constructeurs de formulaires encapsulent la notion d'affichage des éléments de formulaire pour un seul objet. Vous pouvez écrire des helpers pour vos formulaires de la manière habituelle, mais vous pouvez également créer une sous-classe de `ActionView::Helpers::FormBuilder` et y ajouter les helpers. Par exemple,

```erb
<%= form_with model: @person do |form| %>
  <%= text_field_with_label form, :first_name %>
<% end %>
```

peut être remplacé par

```erb
<%= form_with model: @person, builder: LabellingFormBuilder do |form| %>
  <%= form.text_field :first_name %>
<% end %>
```

en définissant une classe `LabellingFormBuilder` similaire à celle-ci :

```ruby
class LabellingFormBuilder < ActionView::Helpers::FormBuilder
  def text_field(attribute, options = {})
    label(attribute) + super
  end
end
```

Si vous réutilisez cela fréquemment, vous pouvez définir un helper `labeled_form_with` qui applique automatiquement l'option `builder: LabellingFormBuilder` :

```ruby
def labeled_form_with(model: nil, scope: nil, url: nil, format: nil, **options, &block)
  options[:builder] = LabellingFormBuilder
  form_with model: model, scope: scope, url: url, format: format, **options, &block
end
```

Le constructeur de formulaire utilisé détermine également ce qui se passe lorsque vous faites :

```erb
<%= render partial: f %>
```

Si `f` est une instance de `ActionView::Helpers::FormBuilder`, cela rendra le partiel `form`, en définissant l'objet du partiel sur le constructeur de formulaire. Si le constructeur de formulaire est de la classe `LabellingFormBuilder`, alors le partiel `labelling_form` sera rendu à la place.

Comprendre les conventions de nommage des paramètres
----------------------------------------------------

Les valeurs des formulaires peuvent être au niveau supérieur du hachage `params` ou imbriquées dans un autre hachage. Par exemple, dans une action `create` standard pour un modèle `Person`, `params[:person]` serait généralement un hachage de tous les attributs de la personne à créer. Le hachage `params` peut également contenir des tableaux, des tableaux de hachages, etc.

Fondamentalement, les formulaires HTML ne connaissent aucun type de données structurées, ils ne génèrent que des paires nom-valeur, où les paires sont simplement des chaînes de caractères. Les tableaux et les hachages que vous voyez dans votre application sont le résultat de certaines conventions de nommage des paramètres utilisées par Rails.

### Structures de base

Les deux structures de base sont les tableaux et les hachages. Les hachages reflètent la syntaxe utilisée pour accéder à la valeur dans `params`. Par exemple, si un formulaire contient :

```html
<input id="person_name" name="person[name]" type="text" value="Henry"/>
```

le hachage `params` contiendra

```ruby
{ 'person' => { 'name' => 'Henry' } }
```

et `params[:person][:name]` récupérera la valeur soumise dans le contrôleur.

Les hachages peuvent être imbriqués autant de niveaux que nécessaire, par exemple :

```html
<input id="person_address_city" name="person[address][city]" type="text" value="New York"/>
```

résultera en un hachage `params` :

```ruby
{ 'person' => { 'address' => { 'city' => 'New York' } } }
```

Normalement, Rails ignore les noms de paramètres en double. Si le nom du paramètre se termine par un ensemble de crochets vides `[]`, ils seront accumulés dans un tableau. Si vous souhaitez permettre aux utilisateurs de saisir plusieurs numéros de téléphone, vous pouvez placer ceci dans le formulaire :

```html
<input name="person[phone_number][]" type="text"/>
<input name="person[phone_number][]" type="text"/>
<input name="person[phone_number][]" type="text"/>
```

Cela entraînerait `params[:person][:phone_number]` étant un tableau contenant les numéros de téléphone saisis.

### Les combiner

Nous pouvons mélanger ces deux concepts. Un élément d'un hachage peut être un tableau comme dans l'exemple précédent, ou vous pouvez avoir un tableau de hachages. Par exemple, un formulaire pourrait vous permettre de créer un nombre quelconque d'adresses en répétant le fragment de formulaire suivant :

```html
<input name="person[addresses][][line1]" type="text"/>
<input name="person[addresses][][line2]" type="text"/>
<input name="person[addresses][][city]" type="text"/>
<input name="person[addresses][][line1]" type="text"/>
<input name="person[addresses][][line2]" type="text"/>
<input name="person[addresses][][city]" type="text"/>
```

Cela entraînerait `params[:person][:addresses]` étant un tableau de hachages avec les clés `line1`, `line2` et `city`.

Il y a une restriction, cependant : bien que les hachages puissent être imbriqués de manière arbitraire, un seul niveau de "tableau" est autorisé. Les tableaux peuvent généralement être remplacés par des hachages ; par exemple, au lieu d'avoir un tableau d'objets de modèle, on peut avoir un hachage d'objets de modèle indexés par leur identifiant, un index de tableau ou un autre paramètre.
AVERTISSEMENT: Les paramètres de tableau ne fonctionnent pas bien avec l'aide `check_box`. Selon la spécification HTML, les cases à cocher non cochées ne soumettent aucune valeur. Cependant, il est souvent pratique qu'une case à cocher soumette toujours une valeur. L'aide `check_box` simule cela en créant un champ de saisie caché auxiliaire avec le même nom. Si la case à cocher n'est pas cochée, seul le champ de saisie caché est soumis, et s'il est coché, les deux sont soumis mais la valeur soumise par la case à cocher a la priorité.

### L'option `:index` de l'aide `fields_for`

Supposons que nous voulions afficher un formulaire avec un ensemble de champs pour chacune des adresses d'une personne. L'aide [`fields_for`][] avec son option `:index` peut aider :

```erb
<%= form_with model: @person do |person_form| %>
  <%= person_form.text_field :name %>
  <% @person.addresses.each do |address| %>
    <%= person_form.fields_for address, index: address.id do |address_form| %>
      <%= address_form.text_field :city %>
    <% end %>
  <% end %>
<% end %>
```

En supposant que la personne a deux adresses avec les ID 23 et 45, le formulaire ci-dessus afficherait une sortie similaire à :

```html
<form accept-charset="UTF-8" action="/people/1" method="post">
  <input name="_method" type="hidden" value="patch" />
  <input id="person_name" name="person[name]" type="text" />
  <input id="person_address_23_city" name="person[address][23][city]" type="text" />
  <input id="person_address_45_city" name="person[address][45][city]" type="text" />
</form>
```

Ce qui donnerait un hash `params` qui ressemble à :

```ruby
{
  "person" => {
    "name" => "Bob",
    "address" => {
      "23" => {
        "city" => "Paris"
      },
      "45" => {
        "city" => "London"
      }
    }
  }
}
```

Tous les champs de saisie du formulaire sont mappés sur le hash `"person"` car nous avons appelé `fields_for` sur le constructeur de formulaire `person_form`. De plus, en spécifiant `index: address.id`, nous avons rendu l'attribut `name` de chaque champ de saisie de ville comme `person[address][#{address.id}][city]` au lieu de `person[address][city]`. Ainsi, nous pouvons déterminer quels enregistrements d'adresse doivent être modifiés lors du traitement du hash `params`.

Vous pouvez passer d'autres nombres ou chaînes de caractères significatifs via l'option `:index`. Vous pouvez même passer `nil`, ce qui produira un paramètre de tableau.

Pour créer des imbrications plus complexes, vous pouvez spécifier explicitement la partie initiale du nom du champ de saisie. Par exemple :

```erb
<%= fields_for 'person[address][primary]', address, index: address.id do |address_form| %>
  <%= address_form.text_field :city %>
<% end %>
```

créera des champs de saisie comme :

```html
<input id="person_address_primary_23_city" name="person[address][primary][23][city]" type="text" value="Paris" />
```

Vous pouvez également passer une option `:index` directement aux aides telles que `text_field`, mais il est généralement moins répétitif de spécifier cela au niveau du constructeur de formulaire que sur les champs de saisie individuels.

En général, le nom final du champ de saisie sera une concaténation du nom donné à `fields_for` / `form_with`, de la valeur de l'option `:index` et du nom de l'attribut.

Enfin, en tant que raccourci, au lieu de spécifier un ID pour `:index` (par exemple `index: address.id`), vous pouvez ajouter `"[]"` au nom donné. Par exemple :

```erb
<%= fields_for 'person[address][primary][]', address do |address_form| %>
  <%= address_form.text_field :city %>
<% end %>
```

produit exactement la même sortie que notre exemple original.

Formulaires vers des ressources externes
---------------------------------------

Les aides de formulaire de Rails peuvent également être utilisées pour créer un formulaire pour envoyer des données vers une ressource externe. Cependant, il peut parfois être nécessaire de définir un `authenticity_token` pour la ressource ; cela peut être fait en passant un paramètre `authenticity_token: 'votre_token_externe'` aux options de `form_with` :

```erb
<%= form_with url: 'http://loinloin.loin/form', authenticity_token: 'token_externe' do %>
  Contenu du formulaire
<% end %>
```

Parfois, lors de la soumission de données vers une ressource externe, comme une passerelle de paiement, les champs pouvant être utilisés dans le formulaire sont limités par une API externe et il peut être indésirable de générer un `authenticity_token`. Pour ne pas envoyer de jeton, il suffit de passer `false` à l'option `:authenticity_token` :

```erb
<%= form_with url: 'http://loinloin.loin/form', authenticity_token: false do %>
  Contenu du formulaire
<% end %>
```

Construction de formulaires complexes
------------------------------------

De nombreuses applications dépassent les simples formulaires permettant de modifier un seul objet. Par exemple, lors de la création d'une `Personne`, vous voudrez peut-être permettre à l'utilisateur de créer plusieurs enregistrements d'adresse (domicile, travail, etc.) sur le même formulaire. Lors de la modification ultérieure de cette personne, l'utilisateur devrait pouvoir ajouter, supprimer ou modifier des adresses selon les besoins.

### Configuration du modèle

Active Record fournit une prise en charge au niveau du modèle via la méthode [`accepts_nested_attributes_for`](https://api.rubyonrails.org/classes/ActiveRecord/NestedAttributes/ClassMethods.html#method-i-accepts_nested_attributes_for) :

```ruby
class Person < ApplicationRecord
  has_many :addresses, inverse_of: :person
  accepts_nested_attributes_for :addresses
end

class Address < ApplicationRecord
  belongs_to :person
end
```

Cela crée une méthode `addresses_attributes=` sur `Person` qui vous permet de créer, mettre à jour et (éventuellement) supprimer des adresses.
### Formulaires imbriqués

Le formulaire suivant permet à un utilisateur de créer une `Personne` et ses adresses associées.

```html+erb
<%= form_with model: @person do |form| %>
  Adresses :
  <ul>
    <%= form.fields_for :addresses do |addresses_form| %>
      <li>
        <%= addresses_form.label :kind %>
        <%= addresses_form.text_field :kind %>

        <%= addresses_form.label :street %>
        <%= addresses_form.text_field :street %>
        ...
      </li>
    <% end %>
  </ul>
<% end %>
```


Lorsqu'une association accepte des attributs imbriqués, `fields_for` rend son bloc une fois pour chaque élément de l'association. En particulier, si une personne n'a pas d'adresses, rien n'est rendu. Un schéma courant consiste à construire un ou plusieurs enfants vides dans le contrôleur afin qu'au moins un ensemble de champs soit affiché à l'utilisateur. L'exemple ci-dessous entraînerait le rendu de 2 ensembles de champs d'adresse dans le formulaire de nouvelle personne.

```ruby
def new
  @person = Person.new
  2.times { @person.addresses.build }
end
```

`fields_for` renvoie un constructeur de formulaire. Le nom des paramètres sera ce que `accepts_nested_attributes_for` attend. Par exemple, lors de la création d'un utilisateur avec 2 adresses, les paramètres soumis ressembleraient à ceci :

```ruby
{
  'person' => {
    'name' => 'John Doe',
    'addresses_attributes' => {
      '0' => {
        'kind' => 'Home',
        'street' => '221b Baker Street'
      },
      '1' => {
        'kind' => 'Office',
        'street' => '31 Spooner Street'
      }
    }
  }
}
```

Les valeurs réelles des clés dans le hachage `:addresses_attributes` sont sans importance ; cependant, elles doivent être des chaînes de caractères d'entiers et différentes pour chaque adresse.

Si l'objet associé est déjà enregistré, `fields_for` génère automatiquement un champ caché avec l'`id` de l'enregistrement enregistré. Vous pouvez désactiver cela en passant `include_id: false` à `fields_for`.

### Le contrôleur

Comme d'habitude, vous devez [déclarer les paramètres autorisés](action_controller_overview.html#strong-parameters) dans le contrôleur avant de les transmettre au modèle :

```ruby
def create
  @person = Person.new(person_params)
  # ...
end

private
  def person_params
    params.require(:person).permit(:name, addresses_attributes: [:id, :kind, :street])
  end
```

### Suppression d'objets

Vous pouvez permettre aux utilisateurs de supprimer des objets associés en passant `allow_destroy: true` à `accepts_nested_attributes_for`

```ruby
class Person < ApplicationRecord
  has_many :addresses
  accepts_nested_attributes_for :addresses, allow_destroy: true
end
```

Si le hachage d'attributs pour un objet contient la clé `_destroy` avec une valeur qui évalue à `true` (par exemple, 1, '1', true ou 'true'), alors l'objet sera détruit. Ce formulaire permet aux utilisateurs de supprimer des adresses :

```erb
<%= form_with model: @person do |form| %>
  Adresses :
  <ul>
    <%= form.fields_for :addresses do |addresses_form| %>
      <li>
        <%= addresses_form.check_box :_destroy %>
        <%= addresses_form.label :kind %>
        <%= addresses_form.text_field :kind %>
        ...
      </li>
    <% end %>
  </ul>
<% end %>
```

N'oubliez pas de mettre à jour les paramètres autorisés dans votre contrôleur pour inclure également le champ `_destroy` :

```ruby
def person_params
  params.require(:person).
    permit(:name, addresses_attributes: [:id, :kind, :street, :_destroy])
end
```

### Empêcher les enregistrements vides

Il est souvent utile d'ignorer les ensembles de champs que l'utilisateur n'a pas remplis. Vous pouvez contrôler cela en passant un proc `:reject_if` à `accepts_nested_attributes_for`. Ce proc sera appelé avec chaque hachage d'attributs soumis par le formulaire. Si le proc renvoie `true`, alors Active Record ne construira pas d'objet associé pour ce hachage. L'exemple ci-dessous essaie de construire une adresse uniquement si l'attribut `kind` est défini.

```ruby
class Person < ApplicationRecord
  has_many :addresses
  accepts_nested_attributes_for :addresses, reject_if: lambda { |attributes| attributes['kind'].blank? }
end
```

Pour plus de commodité, vous pouvez plutôt passer le symbole `:all_blank`, qui créera un proc qui rejettera les enregistrements où tous les attributs sont vides, à l'exception de toute valeur pour `_destroy`.

### Ajouter des champs à la volée

Au lieu de rendre plusieurs ensembles de champs à l'avance, vous pouvez souhaiter les ajouter uniquement lorsque l'utilisateur clique sur un bouton "Ajouter une nouvelle adresse". Rails ne fournit aucune prise en charge intégrée pour cela. Lors de la génération de nouveaux ensembles de champs, vous devez vous assurer que la clé du tableau associé est unique - la date JavaScript actuelle (millisecondes depuis l'[époque](https://en.wikipedia.org/wiki/Unix_time)) est un choix courant.

Utilisation des aides aux balises sans un constructeur de formulaire
-------------------------------------------------------------------

Si vous avez besoin de rendre des champs de formulaire en dehors du contexte d'un constructeur de formulaire, Rails fournit des aides aux balises pour les éléments de formulaire courants. Par exemple, [`check_box_tag`](https://api.rubyonrails.org/classes/ActionView/Helpers/FormTagHelper.html#method-i-check_box_tag) :

```erb
<%= check_box_tag "accept" %>
```

Sortie :

```html
<input type="checkbox" name="accept" id="accept" value="1" />
```

Généralement, ces aides ont le même nom que leurs homologues constructeurs de formulaire, avec un suffixe `_tag`. Pour une liste complète, consultez la documentation de l'API [`FormTagHelper`](https://api.rubyonrails.org/classes/ActionView/Helpers/FormTagHelper.html).
Utilisation de `form_tag` et `form_for`
-------------------------------

Avant l'introduction de `form_with` dans Rails 5.1, sa fonctionnalité était répartie entre [`form_tag`](https://api.rubyonrails.org/v5.2/classes/ActionView/Helpers/FormTagHelper.html#method-i-form_tag) et [`form_for`](https://api.rubyonrails.org/v5.2/classes/ActionView/Helpers/FormHelper.html#method-i-form_for). Les deux sont maintenant considérés comme obsolètes. La documentation sur leur utilisation peut être trouvée dans [les anciennes versions de ce guide](https://guides.rubyonrails.org/v5.2/form_helpers.html).
[`fields_for`]: https://api.rubyonrails.org/classes/ActionView/Helpers/FormBuilder.html#method-i-fields_for
[formmethod]: https://developer.mozilla.org/en-US/docs/Web/HTML/Element/button#attr-formmethod
[button-name]: https://developer.mozilla.org/en-US/docs/Web/HTML/Element/button#attr-name
[button-value]: https://developer.mozilla.org/en-US/docs/Web/HTML/Element/button#attr-value
