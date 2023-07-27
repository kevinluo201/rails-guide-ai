**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 0651830a9dc9cbd4e8a1fddab047c719
Kuriamas ir pritaikomas „Rails“ generatoriai ir šablonai
=========================================================

„Rails“ generatoriai yra būtinas įrankis, padedantis pagerinti darbo eigą. Šiuo vadovu sužinosite, kaip kurti generatorius ir pritaikyti esamus.

Po šio vadovo perskaitymo žinosite:

* Kaip pamatyti, kokie generatoriai yra jūsų aplikacijoje.
* Kaip sukurti generatorių naudojant šablonus.
* Kaip „Rails“ ieško generatorių prieš juos paleisdamas.
* Kaip pritaikyti savo šabloną perrašant generatoriaus šablonus.
* Kaip pritaikyti savo šabloną perrašant generatorius.
* Kaip naudoti atsarginius generatorius, kad išvengtumėte didelio generatorių rinkinio perrašymo.
* Kaip sukurti aplikacijos šabloną.

--------------------------------------------------------------------------------

Pirmasis kontaktas
------------------

Kai kuriate aplikaciją naudodami „rails“ komandą, iš tikrųjų naudojate „Rails“ generatorių. Tada galite gauti visų galimų generatorių sąrašą, paleisdami `bin/rails generate`:

```bash
$ rails new myapp
$ cd myapp
$ bin/rails generate
```

PASTABA: Norėdami sukurti „Rails“ aplikaciją, naudojame globalią `rails` komandą, kuri naudoja „gem install rails“ įdiegtą „Rails“ versiją. Kai esate aplikacijos kataloge, naudojame `bin/rails` komandą, kuri naudoja aplikacijoje sujungtą „Rails“ versiją.

Gausite visų „Rails“ pateiktų generatorių sąrašą. Norėdami pamatyti išsamų tam tikro generatoriaus aprašymą, paleiskite generatorių su `--help` pasirinkimu. Pavyzdžiui:

```bash
$ bin/rails generate scaffold --help
```

Kuriamas pirmasis generatorius
------------------------------

Generatoriai yra sukurti naudojant [Thor](https://github.com/rails/thor), kuris suteikia galingas parinktis analizei ir puikią API failų manipuliavimui.

Sukurkime generatorių, kuris sukurs inicializavimo failą pavadinimu `initializer.rb` viduje `config/initializers`. Pirmas žingsnis yra sukurti failą `lib/generators/initializer_generator.rb` su šiuo turiniu:

```ruby
class InitializerGenerator < Rails::Generators::Base
  def create_initializer_file
    create_file "config/initializers/initializer.rb", <<~RUBY
      # Čia pridėkite inicializavimo turinį
    RUBY
  end
end
```

Mūsų naujas generatorius yra gana paprastas: jis paveldi [`Rails::Generators::Base`][] ir turi vieną metodų apibrėžimą. Paleidus generatorių, kiekvienas viešas metodas generatoriuje vykdomas seka, kurioje jis yra apibrėžtas. Mūsų metodas iškviečia [`create_file`][], kuris sukurs failą nurodytuose tiksluose su nurodytu turiniu.

Norėdami iškviesti naują generatorių, paleiskime:

```bash
$ bin/rails generate initializer
```

Prieš tęsiant, pažiūrėkime naujo generatoriaus aprašymą:

```bash
$ bin/rails generate initializer --help
```

„Rails“ paprastai gali gauti gerą aprašymą, jei generatorius yra sudėtinio pavadinimo, pvz., `ActiveRecord::Generators::ModelGenerator`, bet ne šiuo atveju. Šią problemą galime išspręsti dviem būdais. Pirmasis būdas pridėti aprašymą yra iškvietus [`desc`][] viduje mūsų generatoriaus:

```ruby
class InitializerGenerator < Rails::Generators::Base
  desc "Šis generatorius sukuria inicializavimo failą config/initializers"
  def create_initializer_file
    create_file "config/initializers/initializer.rb", <<~RUBY
      # Čia pridėkite inicializavimo turinį
    RUBY
  end
end
```

Dabar galime pamatyti naują aprašymą, paleidę `--help` naujame generatoriuje.

Antrasis būdas pridėti aprašymą yra sukurti failą pavadinimu `USAGE` tame pačiame kataloge, kuriame yra mūsų generatorius. Tai padarysime kitame žingsnyje.


Generatorių kūrimas su generatoriais
-----------------------------------

Patys generatoriai turi generatorių. Pašalinkime mūsų `InitializerGenerator` ir naudokime `bin/rails generate generator`, kad sukurtume naują:

```bash
$ rm lib/generators/initializer_generator.rb

$ bin/rails generate generator initializer
      create  lib/generators/initializer
      create  lib/generators/initializer/initializer_generator.rb
      create  lib/generators/initializer/USAGE
      create  lib/generators/initializer/templates
      invoke  test_unit
      create    test/lib/generators/initializer_generator_test.rb
```

Tai yra tik sukurtas generatorius:

```ruby
class InitializerGenerator < Rails::Generators::NamedBase
  source_root File.expand_path("templates", __dir__)
end
```

Pirma, pastebėkite, kad generatorius paveldi [`Rails::Generators::NamedBase`][] vietoj `Rails::Generators::Base`. Tai reiškia, kad mūsų generatorius tikisi bent vieno argumento, kuris bus inicializatoriaus pavadinimas ir bus prieinamas mūsų kodo per `name`.

Tai galime pamatyti, patikrinę naujo generatoriaus aprašymą:

```bash
$ bin/rails generate initializer --help
Usage:
  bin/rails generate initializer NAME [options]
```

Taip pat pastebėkite, kad generatorius turi klasės metodą, vadinamą [`source_root`][]. Šis metodas nurodo mūsų šablonų vietą, jei tokių yra. Pagal numatytuosius nustatymus jis rodo į `lib/generators/initializer/templates` katalogą, kuris buvo tik ką sukurtas.

Norėdami suprasti, kaip veikia generatorių šablonai, sukursime failą `lib/generators/initializer/templates/initializer.rb` su šiuo turiniu:

```ruby
# Čia pridėkite inicializavimo turinį
```

Ir pakeiskime generatorių, kad jis kopijuotų šį šabloną, kai jis yra iškviečiamas:
```ruby
class InitializerGenerator < Rails::Generators::NamedBase
  source_root File.expand_path("templates", __dir__)

  def copy_initializer_file
    copy_file "initializer.rb", "config/initializers/#{file_name}.rb"
  end
end
```

Dabar paleiskime mūsų generatorių:

```bash
$ bin/rails generate initializer core_extensions
      create  config/initializers/core_extensions.rb

$ cat config/initializers/core_extensions.rb
# Čia pridėkite inicializavimo turinį
```

Matome, kad [`copy_file`][] sukūrė `config/initializers/core_extensions.rb`
su mūsų šablono turiniu. (Kelio paskirties vietoje naudojamas `file_name` metodas
paveldėtas iš `Rails::Generators::NamedBase`.)

Generatoriaus komandų eilutės parinktys
---------------------------------------

Generatoriai gali palaikyti komandų eilutės parinktis naudodami [`class_option`][].
Pavyzdžiui:

```ruby
class InitializerGenerator < Rails::Generators::NamedBase
  class_option :scope, type: :string, default: "app"
end
```

Dabar mūsų generatorių galima paleisti su `--scope` parinktimi:

```bash
$ bin/rails generate initializer theme --scope dashboard
```

Parinkties reikšmės pasiekiamos generatoriaus metodams naudojant [`options`][]:

```ruby
def copy_initializer_file
  @scope = options["scope"]
end
```


Generatoriaus nustatymas
------------------------

Išsprendžiant generatoriaus pavadinimą, „Rails“ ieško generatoriaus naudodamas kelis
failų pavadinimus. Pavyzdžiui, paleidus `bin/rails generate initializer core_extensions`,
„Rails“ bando įkelti kiekvieną iš šių failų, kol vienas bus rastas:

* `rails/generators/initializer/initializer_generator.rb`
* `generators/initializer/initializer_generator.rb`
* `rails/generators/initializer_generator.rb`
* `generators/initializer_generator.rb`

Jei nei vienas iš šių failų nerandamas, bus iškelta klaida.

Mūsų generatorių įdėjome į aplikacijos `lib/` katalogą, nes šis
katalogas yra `$LOAD_PATH`, todėl leidžiama „Rails“ rasti ir įkelti failą.

„Rails“ generatorių šablonų perrašymas
-------------------------------------

„Rails“ taip pat ieško generatoriaus šablonų failų keliose vietose.
Viena iš šių vietų yra aplikacijos `lib/templates/` katalogas.
Tai leidžia mums perrašyti „Rails“ įdiegtų generatorių naudojamus šablonus.
Pavyzdžiui, galime perrašyti [scaffold kontrolerio šabloną][] arba
[scaffold rodinio šablonus][].

Norėdami tai pamatyti veikiant, sukurkime `lib/templates/erb/scaffold/index.html.erb.tt`
failą su šiuo turiniu:

```erb
<%% @<%= plural_table_name %>.count %> <%= human_name.pluralize %>
```

Atkreipkite dėmesį, kad šablonas yra ERB šablonas, kuris atvaizduoja _kitą_ ERB šabloną.
Taigi bet koks `<%`, kuris turėtų pasirodyti _rezultatuojamame_ šablone, turi būti pakeistas į `<%%`
_generatoriaus_ šablone.

Dabar paleiskime „Rails“ įdiegtą scaffold generatorių:

```bash
$ bin/rails generate scaffold Post title:string
      ...
      create      app/views/posts/index.html.erb
      ...
```

`app/views/posts/index.html.erb` turinys yra:

```erb
<% @posts.count %> Posts
```

[scaffold kontrolerio šablonas]: https://github.com/rails/rails/blob/main/railties/lib/rails/generators/rails/scaffold_controller/templates/controller.rb.tt
[scaffold rodinio šablonai]: https://github.com/rails/rails/tree/main/railties/lib/rails/generators/erb/scaffold/templates

„Rails“ generatorių perrašymas
---------------------------

„Rails“ įdiegtus generatorius galima konfigūruoti naudojant [`config.generators`][],
įskaitant visišką kai kurių generatorių perrašymą.

Pirmiausia pažvelkime, kaip veikia scaffold generatorius.

```bash
$ bin/rails generate scaffold User name:string
      invoke  active_record
      create    db/migrate/20230518000000_create_users.rb
      create    app/models/user.rb
      invoke    test_unit
      create      test/models/user_test.rb
      create      test/fixtures/users.yml
      invoke  resource_route
       route    resources :users
      invoke  scaffold_controller
      create    app/controllers/users_controller.rb
      invoke    erb
      create      app/views/users
      create      app/views/users/index.html.erb
      create      app/views/users/edit.html.erb
      create      app/views/users/show.html.erb
      create      app/views/users/new.html.erb
      create      app/views/users/_form.html.erb
      create      app/views/users/_user.html.erb
      invoke    resource_route
      invoke    test_unit
      create      test/controllers/users_controller_test.rb
      create      test/system/users_test.rb
      invoke    helper
      create      app/helpers/users_helper.rb
      invoke      test_unit
      invoke    jbuilder
      create      app/views/users/index.json.jbuilder
      create      app/views/users/show.json.jbuilder
```

Iš išvesties matome, kad scaffold generatorius iškviečia kitus
generatorius, pvz., `scaffold_controller` generatorių. Ir kai kurie iš tų
generatorių taip pat iškviečia kitus generatorius. Ypač `scaffold_controller`
generatorius iškviečia keletą kitų generatorių, įskaitant `helper` generatorių.

Perrašykime įdiegtą `helper` generatorių nauju generatoriumi, kurį pavadinsime
`my_helper`:

```bash
$ bin/rails generate generator rails/my_helper
      create  lib/generators/rails/my_helper
      create  lib/generators/rails/my_helper/my_helper_generator.rb
      create  lib/generators/rails/my_helper/USAGE
      create  lib/generators/rails/my_helper/templates
      invoke  test_unit
      create    test/lib/generators/rails/my_helper_generator_test.rb
```

Ir `lib/generators/rails/my_helper/my_helper_generator.rb` faile apibrėšime
generatorių kaip:

```ruby
class Rails::MyHelperGenerator < Rails::Generators::NamedBase
  def create_helper_file
    create_file "app/helpers/#{file_name}_helper.rb", <<~RUBY
      module #{class_name}Helper
        # Aš padedu!
      end
    RUBY
  end
end
```

Galiausiai, mums reikia pasakyti „Rails“, kad naudotų `my_helper` generatorių vietoje
įdiegto `helper` generatoriaus. Tam naudojame `config.generators`. `config/application.rb`
faile pridėkime:

```ruby
config.generators do |g|
  g.helper :my_helper
end
```

Dabar, jei paleisime scaffold generatorių dar kartą, matysime `my_helper` generatorių
veikime:

```bash
$ bin/rails generate scaffold Article body:text
      ...
      invoke  scaffold_controller
      ...
      invoke    my_helper
      create      app/helpers/articles_helper.rb
      ...
```

PASTABA: Galbūt pastebėsite, kad įdiegto `helper` generatoriaus išvestyje
yra "invoke test_unit", tuo tarpu `my_helper` išvestyje to nėra.
Nors `helper` generatorius pagal numatytuosius nesukuria testų, jis
suteikia galimybę tai padaryti naudojant [`hook_for`][]. Galime tai padaryti
įtraukdami `hook_for :test_framework, as: :helper` į `MyHelperGenerator` klasę.
Daugiau informacijos rasite `hook_for` dokumentacijoje.


### Generatorių atsarginės kopijos

Kitas būdas perrašyti konkretų generatorių yra naudojant _atsargines kopijas_.
Atsarginė kopija leidžia generatoriaus vardų erdvės deleguoti kitai generatorių vardų erdvei.
Pavyzdžiui, sakykime, norime perrašyti `test_unit:model` generatorių savo `my_test_unit:model` generatoriumi, tačiau nenorime pakeisti visų kitų `test_unit:*` generatorių, pvz., `test_unit:controller`.

Pirma, sukuriame `my_test_unit:model` generatorių `lib/generators/my_test_unit/model/model_generator.rb`:

```ruby
module MyTestUnit
  class ModelGenerator < Rails::Generators::NamedBase
    source_root File.expand_path("templates", __dir__)

    def do_different_stuff
      say "Darome skirtingus dalykus..."
    end
  end
end
```

Toliau naudojame `config.generators`, kad sukonfigūruotume `test_framework` generatorių kaip `my_test_unit`, tačiau taip pat sukonfigūruojame atsarginę galimybę, kad visi trūkstami `my_test_unit:*` generatoriai būtų pakeičiami į `test_unit:*`:

```ruby
config.generators do |g|
  g.test_framework :my_test_unit, fixture: false
  g.fallbacks[:my_test_unit] = :test_unit
end
```

Dabar paleidus scaffold generatorių, matome, kad `my_test_unit` pakeitė `test_unit`, tačiau paveikti tik modelio testai:

```bash
$ bin/rails generate scaffold Comment body:text
      invoke  active_record
      create    db/migrate/20230518000000_create_comments.rb
      create    app/models/comment.rb
      invoke    my_test_unit
    Darome skirtingus dalykus...
      invoke  resource_route
       route    resources :comments
      invoke  scaffold_controller
      create    app/controllers/comments_controller.rb
      invoke    erb
      create      app/views/comments
      create      app/views/comments/index.html.erb
      create      app/views/comments/edit.html.erb
      create      app/views/comments/show.html.erb
      create      app/views/comments/new.html.erb
      create      app/views/comments/_form.html.erb
      create      app/views/comments/_comment.html.erb
      invoke    resource_route
      invoke    my_test_unit
      create      test/controllers/comments_controller_test.rb
      create      test/system/comments_test.rb
      invoke    helper
      create      app/helpers/comments_helper.rb
      invoke      my_test_unit
      invoke    jbuilder
      create      app/views/comments/index.json.jbuilder
      create      app/views/comments/show.json.jbuilder
```

Programos šablonai
------------------

Programos šablonai yra ypatingo tipo generatoriai. Jie gali naudoti visus [generatorių pagalbos metodus](#generatorių-pagalbos-metodai), tačiau jie yra parašyti kaip Ruby skriptas, o ne kaip Ruby klasė. Štai pavyzdys:

```ruby
# template.rb

if yes?("Ar norite įdiegti Devise?")
  gem "devise"
  devise_model = ask("Kaip norėtumėte pavadinti vartotojo modelį?", default: "User")
end

after_bundle do
  if devise_model
    generate "devise:install"
    generate "devise", devise_model
    rails_command "db:migrate"
  end

  git add: ".", commit: %(-m 'Pradinis commit')
end
```

Pirma, šablonas paklausia vartotojo, ar nori įdiegti Devise. Jei vartotojas atsako "taip" (arba "t"), šablonas prideda Devise į `Gemfile` ir paklausia vartotojo, kaip nori pavadinti Devise vartotojo modelį (pagal nutylėjimą `User`). Vėliau, po to, kai paleidžiamas `bundle install`, šablonas paleidžia Devise generatorius ir `rails db:migrate`, jei buvo nurodytas Devise modelis. Galiausiai, šablonas prideda ir užfiksuoja visą programos direktoriją naudojant `git add` ir `git commit`.

Šabloną galime paleisti, kuriant naują Rails aplikaciją, perduodant `-m` parametrą `rails new` komandai:

```bash
$ rails new my_cool_app -m path/to/template.rb
```

Alternatyviai, šabloną galime paleisti esamoje aplikacijoje naudojant `bin/rails app:template`:

```bash
$ bin/rails app:template LOCATION=path/to/template.rb
```

Šablonai taip pat gali būti saugomi ne vietiniame diske - galite nurodyti URL vietoj kelio:

```bash
$ rails new my_cool_app -m http://example.com/template.rb
$ bin/rails app:template LOCATION=http://example.com/template.rb
```

Generatorių pagalbos metodai
---------------------------

Thor teikia daug generatorių pagalbos metodus per [`Thor::Actions`][], tokius kaip:

* [`copy_file`][]
* [`create_file`][]
* [`gsub_file`][]
* [`insert_into_file`][]
* [`inside`][]

Be to, Rails taip pat teikia daug pagalbos metodus per [`Rails::Generators::Actions`][], tokius kaip:

* [`environment`][]
* [`gem`][]
* [`generate`][]
* [`git`][]
* [`initializer`][]
* [`lib`][]
* [`rails_command`][]
* [`rake`][]
* [`route`][]
[`Rails::Generators::Base`]: https://api.rubyonrails.org/classes/Rails/Generators/Base.html
[`Thor::Actions`]: https://www.rubydoc.info/gems/thor/Thor/Actions
[`create_file`]: https://www.rubydoc.info/gems/thor/Thor/Actions#create_file-instance_method
[`desc`]: https://www.rubydoc.info/gems/thor/Thor#desc-class_method
[`Rails::Generators::NamedBase`]: https://api.rubyonrails.org/classes/Rails/Generators/NamedBase.html
[`copy_file`]: https://www.rubydoc.info/gems/thor/Thor/Actions#copy_file-instance_method
[`source_root`]: https://api.rubyonrails.org/classes/Rails/Generators/Base.html#method-c-source_root
[`class_option`]: https://www.rubydoc.info/gems/thor/Thor/Base/ClassMethods#class_option-instance_method
[`options`]: https://www.rubydoc.info/gems/thor/Thor/Base#options-instance_method
[`config.generators`]: configuring.html#configuring-generators
[`hook_for`]: https://api.rubyonrails.org/classes/Rails/Generators/Base.html#method-c-hook_for
[`Rails::Generators::Actions`]: https://api.rubyonrails.org/classes/Rails/Generators/Actions.html
[`environment`]: https://api.rubyonrails.org/classes/Rails/Generators/Actions.html#method-i-environment
[`gem`]: https://api.rubyonrails.org/classes/Rails/Generators/Actions.html#method-i-gem
[`generate`]: https://api.rubyonrails.org/classes/Rails/Generators/Actions.html#method-i-generate
[`git`]: https://api.rubyonrails.org/classes/Rails/Generators/Actions.html#method-i-git
[`gsub_file`]: https://www.rubydoc.info/gems/thor/Thor/Actions#gsub_file-instance_method
[`initializer`]: https://api.rubyonrails.org/classes/Rails/Generators/Actions.html#method-i-initializer
[`insert_into_file`]: https://www.rubydoc.info/gems/thor/Thor/Actions#insert_into_file-instance_method
[`inside`]: https://www.rubydoc.info/gems/thor/Thor/Actions#inside-instance_method
[`lib`]: https://api.rubyonrails.org/classes/Rails/Generators/Actions.html#method-i-lib
[`rails_command`]: https://api.rubyonrails.org/classes/Rails/Generators/Actions.html#method-i-rails_command
[`rake`]: https://api.rubyonrails.org/classes/Rails/Generators/Actions.html#method-i-rake
[`route`]: https://api.rubyonrails.org/classes/Rails/Generators/Actions.html#method-i-route
