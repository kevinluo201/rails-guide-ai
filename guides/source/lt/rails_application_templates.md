**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: d3947b8dd1115e8f8e4279581ff626f6
Rails aplikacijų šablonai
===========================

Aplikacijų šablonai yra paprasti Ruby failai, kuriuose yra DSL (Domain Specific Language) pridėtiems gemams, inicializavimo failams ir kt. jūsų naujai sukurtai arba jau egzistuojančiai Rails aplikacijai.

Po šio vadovo perskaitymo jūs žinosite:

* Kaip naudoti šablonus generuoti/pritaikyti Rails aplikacijas.
* Kaip rašyti savo daugkartinio naudojimo aplikacijų šablonus naudojant Rails šablonų API.

--------------------------------------------------------------------------------

Naudingumas
-----

Norėdami pritaikyti šabloną, turite nurodyti Rails generatoriui šablono vietą, kurį norite pritaikyti, naudodami `-m` parinktį. Tai gali būti failo arba URL kelias.

```bash
$ rails new blog -m ~/template.rb
$ rails new blog -m http://example.com/template.rb
```

Galite naudoti `app:template` rails komandą pritaikyti šablonus jau egzistuojančiai Rails aplikacijai. Šablono vieta turi būti perduodama per LOCATION aplinkos kintamąjį. Vėlgi, tai gali būti failo arba URL kelias.

```bash
$ bin/rails app:template LOCATION=~/template.rb
$ bin/rails app:template LOCATION=http://example.com/template.rb
```

Šablono API
------------

Rails šablonų API yra lengvai suprantama. Čia pateikiamas tipinio Rails šablono pavyzdys:

```ruby
# template.rb
generate(:scaffold, "person name:string")
route "root to: 'people#index'"
rails_command("db:migrate")

after_bundle do
  git :init
  git add: "."
  git commit: %Q{ -m 'Initial commit' }
end
```

Šios sekcijos apibūdina pagrindinius API teikiamus metodus:

### gem(*args)

Prideda `gem` įrašą su nurodytu gemu į sugeneruotos aplikacijos `Gemfile`.

Pavyzdžiui, jei jūsų aplikacija priklauso nuo `bj` ir `nokogiri` gemų:

```ruby
gem "bj"
gem "nokogiri"
```

Reikia pažymėti, kad šis metodas tik prideda gemą į `Gemfile`; jis neįdiegia gemo.

### gem_group(*names, &block)

Apvija gemų įrašus grupėje.

Pavyzdžiui, jei norite įkelti `rspec-rails` tik `development` ir `test` grupėse:

```ruby
gem_group :development, :test do
  gem "rspec-rails"
end
```

### add_source(source, options={}, &block)

Prideda nurodytą šaltinį į sugeneruotos aplikacijos `Gemfile`.

Pavyzdžiui, jei reikia naudoti gemo šaltinį iš `"http://gems.github.com"`:

```ruby
add_source "http://gems.github.com"
```

Jeigu yra perduodamas blokas, gemo įrašai bloke yra apvyniojami į šaltinio grupę.

```ruby
add_source "http://gems.github.com/" do
  gem "rspec-rails"
end
```

### environment/application(data=nil, options={}, &block)

Prideda eilutę į `Application` klasę `config/application.rb` faile.

Jeigu yra nurodytas `options[:env]`, eilutė yra pridėta į atitinkamą failą `config/environments`.

```ruby
environment 'config.action_mailer.default_url_options = {host: "http://yourwebsite.example.com"}', env: 'production'
```

Vietoje `data` argumento gali būti naudojamas blokas.

### vendor/lib/file/initializer(filename, data = nil, &block)

Prideda inicializavimo failą į sugeneruotos aplikacijos `config/initializers` direktoriją.

Tarkime, jums patinka naudoti `Object#not_nil?` ir `Object#not_blank?`:

```ruby
initializer 'bloatlol.rb', <<-CODE
  class Object
    def not_nil?
      !nil?
    end

    def not_blank?
      !blank?
    end
  end
CODE
```

Panašiai, `lib()` sukuria failą `lib/` direktorijoje, o `vendor()` sukuria failą `vendor/` direktorijoje.

Yra netgi `file()`, kuris priima kelius nuo `Rails.root` ir sukuria visus reikalingus direktorijas/failus:

```ruby
file 'app/components/foo.rb', <<-CODE
  class Foo
  end
CODE
```

Tai sukurs `app/components` direktoriją ir įdės `foo.rb` į ją.

### rakefile(filename, data = nil, &block)

Sukuria naują rake failą `lib/tasks` direktorijoje su nurodytomis užduotimis:

```ruby
rakefile("bootstrap.rake") do
  <<-TASK
    namespace :boot do
      task :strap do
        puts "i like boots!"
      end
    end
  TASK
end
```

Pirmiau pateiktas kodas sukurs `lib/tasks/bootstrap.rake` su `boot:strap` rake užduotimi.

### generate(what, *args)

Paleidžia nurodytą rails generatorių su pateiktais argumentais.

```ruby
generate(:scaffold, "person", "name:string", "address:text", "age:number")
```

### run(command)

Vykdo bet kokį komandą. Kaip ir atgalinės kabutės. Tarkime, norite pašalinti `README.rdoc` failą:

```ruby
run "rm README.rdoc"
```

### rails_command(command, options = {})

Paleidžia nurodytą komandą Rails aplikacijoje. Tarkime, norite atlikti duomenų bazės migraciją:

```ruby
rails_command "db:migrate"
```

Taip pat galite paleisti komandas su kitu Rails aplinku:

```ruby
rails_command "db:migrate", env: 'production'
```

Taip pat galite paleisti komandas kaip super-vartotojas:

```ruby
rails_command "log:clear", sudo: true
```

Taip pat galite paleisti komandas, kurios turėtų nutraukti aplikacijos generavimą, jei jos nepavyksta:

```ruby
rails_command "db:migrate", abort_on_failure: true
```

### route(routing_code)

Prideda maršrutizavimo įrašą į `config/routes.rb` failą. Ankstesniuose žingsniuose mes sugeneravome person šabloną ir pašalinome `README.rdoc`. Dabar, norint padaryti `PeopleController#index` numatytąja aplikacijos puslapiu:

```ruby
route "root to: 'person#index'"
```

### inside(dir)

Leidžia paleisti komandą iš nurodytos direktorijos. Pavyzdžiui, jei turite kopiją edge rails, kurią norite susieti su savo naujomis aplikacijomis, galite tai padaryti:
```ruby
viduje('pardavėjas') do
  vykdyti "ln -s ~/commit-rails/rails rails"
end
```

### klausti(klausimas)

`klausti()` suteikia galimybę gauti grįžtamąjį ryšį iš naudotojo ir jį naudoti savo šablonuose. Tarkime, norite, kad naudotojas pavadintų naują švytinčią biblioteką, kurią pridedate:

```ruby
bibliotekos_pavadinimas = klausti("Kaip norite pavadinti švytinčią biblioteką?")
bibliotekos_pavadinimas << ".rb" jei bibliotekos_pavadinimas.index(".rb")

biblioteka bibliotekos_pavadinimas, <<-KODAS
  class Švytinčia
  end
KODAS
```

### taip?(klausimas) arba ne?(klausimas)

Šios metodai leidžia jums užduoti klausimus iš šablonų ir nuspręsti srautą pagal naudotojo atsakymą. Tarkime, norite paprašyti naudotojo paleisti migracijas:

```ruby
rails_komanda("db:migrate") jei taip?("Paleisti duomenų bazės migracijas?")
# ne?(klausimas) veikia priešingai.
```

### git(:komanda)

Rails šablonai leidžia jums paleisti bet kokią git komandą:

```ruby
git :init
git add: "."
git commit: "-a -m 'Pradinis įsipareigojimas'"
```

### po_bundlo(&blokas)

Registruoja atgalinį iškvietimą, kuris bus vykdomas po to, kai bus sujungti grotuvai ir binstubai
yra sugeneruojami. Tai naudinga, jei norite pridėti sugeneruotus failus į versijų kontrolę:

```ruby
po_bundlo do
  git :init
  git add: '.'
  git commit: "-a -m 'Pradinis įsipareigojimas'"
end
```

Atgaliniai iškvietimai vykdomi net jei buvo perduotas `--skip-bundle` parametras.

Išplėstinis naudojimas
--------------

Programos šablonas yra vertinamas `Rails::Generators::AppGenerator` egzemplioriaus kontekste. Jis naudoja
[`apply`](https://www.rubydoc.info/gems/thor/Thor/Actions#apply-instance_method)
veiksmą, kurį teikia Thor.

Tai reiškia, kad galite išplėsti ir pakeisti egzempliorių pagal savo poreikius.

Pavyzdžiui, perrašydami `source_paths` metodą, kad jis apimtų
jūsų šablono vietą. Dabar metodai, pvz., `copy_file`, priims
kelius iki jūsų šablono vietos.

```ruby
def source_paths
  [__dir__]
end
```
