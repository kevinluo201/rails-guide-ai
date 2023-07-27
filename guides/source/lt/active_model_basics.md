**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: cee957545ee75801aab30265bc416992
Aktyvaus modelio pagrindai
===================

Šis vadovas turėtų suteikti jums viską, ko reikia, norint pradėti naudoti modelio klases. Aktyvus modelis leidžia Action Pack pagalbininkams sąveikauti su paprastais Ruby objektais. Aktyvus modelis taip pat padeda kurti pasirinktinius ORMs, skirtus naudoti už „Rails“ pagrindo.

Po šio vadovo perskaitymo žinosite:

* Kaip elgiasi aktyvusis įrašo modelis.
* Kaip veikia atgalinio iškvietimo ir patikrinimo funkcijos.
* Kaip veikia serializatoriai.
* Kaip aktyvusis modelis integruojasi su „Rails“ tarptautinės lokalizacijos (i18n) pagrindu.

--------------------------------------------------------------------------------

Kas yra aktyvusis modelis?
---------------------

Aktyvusis modelis yra biblioteka, kurioje yra įvairūs moduliai, naudojami kurti klases, kuriose reikalingos kai kurios funkcijos, esančios aktyviame įraše. Kai kurie iš šių modulių yra paaiškinti žemiau.

### API

`ActiveModel::API` suteikia galimybę klasėms iš karto dirbti su Action Pack ir Action View.

```ruby
class EmailContact
  include ActiveModel::API

  attr_accessor :name, :email, :message
  validates :name, :email, :message, presence: true

  def deliver
    if valid?
      # išsiųsti el. laišką
    end
  end
end
```

Įtraukus `ActiveModel::API`, gaunate tam tikrų funkcijų, pvz.:

- modelio pavadinimo introspekcija
- konversijos
- vertimai
- patikrinimai

Tai taip pat suteikia galimybę sukuriant objektą su atributų maiša, panašiai kaip bet kuris aktyvusis įrašo objektas.

```irb
irb> email_contact = EmailContact.new(name: 'David', email: 'david@example.com', message: 'Hello World')
irb> email_contact.name
=> "David"
irb> email_contact.email
=> "david@example.com"
irb> email_contact.valid?
=> true
irb> email_contact.persisted?
=> false
```

Bet kuri klasė, kuri įtraukia `ActiveModel::API`, gali būti naudojama su `form_with`, `render` ir bet kuriais kitais Action View pagalbininkų metodais, kaip ir aktyvūs įrašų objektai.

### Atributo metodai

`ActiveModel::AttributeMethods` modulis gali pridėti pasirinktinius priešdėlius ir priesagos metodus klasės metodams. Jis naudojamas apibrėžiant priešdėlius ir priesagas bei nurodant, kurie objekto metodai juos naudos.

```ruby
class Person
  include ActiveModel::AttributeMethods

  attribute_method_prefix 'reset_'
  attribute_method_suffix '_highest?'
  define_attribute_methods 'age'

  attr_accessor :age

  private
    def reset_attribute(attribute)
      send("#{attribute}=", 0)
    end

    def attribute_highest?(attribute)
      send(attribute) > 100
    end
end
```

```irb
irb> person = Person.new
irb> person.age = 110
irb> person.age_highest?
=> true
irb> person.reset_age
=> 0
irb> person.age_highest?
=> false
```

### Atgaliniai iškvietimai

`ActiveModel::Callbacks` suteikia galimybę naudoti aktyvaus įrašo stiliaus atgalinius iškvietimus. Tai leidžia apibrėžti atgalinius iškvietimus, kurie vykdomi tinkamu metu. Apibrėžus atgalinius iškvietimus, juos galima apgaubti prieš, po ir aplink pasirinktinius metodus.

```ruby
class Person
  extend ActiveModel::Callbacks

  define_model_callbacks :update

  before_update :reset_me

  def update
    run_callbacks(:update) do
      # Šis metodas yra iškviestas, kai objekte yra iškviestas atnaujinimas.
    end
  end

  def reset_me
    # Šis metodas yra iškviestas, kai objekte yra iškviestas atnaujinimas kaip prieš atnaujinimo atgalinis iškvietimas.
  end
end
```

### Konversija

Jei klasė apibrėžia `persisted?` ir `id` metodus, tada galite įtraukti `ActiveModel::Conversion` modulį į tą klasę ir šios klasės objektuose naudoti „Rails“ konversijos metodus.

```ruby
class Person
  include ActiveModel::Conversion

  def persisted?
    false
  end

  def id
    nil
  end
end
```

```irb
irb> person = Person.new
irb> person.to_model == person
=> true
irb> person.to_key
=> nil
irb> person.to_param
=> nil
```

### Dirty

Objektas tampa „dirty“, kai jis patyrė vieną ar daugiau pakeitimų savo atributuose ir nebuvo išsaugotas. `ActiveModel::Dirty` suteikia galimybę patikrinti, ar objektas buvo pakeistas ar ne. Tai taip pat turi atributo pagrindinius prieigos metodus. Pagalvokime apie „Person“ klasę su atributais „first_name“ ir „last_name“:

```ruby
class Person
  include ActiveModel::Dirty
  define_attribute_methods :first_name, :last_name

  def first_name
    @first_name
  end

  def first_name=(value)
    first_name_will_change!
    @first_name = value
  end

  def last_name
    @last_name
  end

  def last_name=(value)
    last_name_will_change!
    @last_name = value
  end

  def save
    # atlikti išsaugojimo darbą...
    changes_applied
  end
end
```

#### Tiesioginio objekto užklausimas dėl jo visų pakeistų atributų sąrašo

```irb
irb> person = Person.new
irb> person.changed?
=> false

irb> person.first_name = "First Name"
irb> person.first_name
=> "First Name"

# Grąžina „true“, jei bet kuris iš atributų turi neišsaugotų pakeitimų.
irb> person.changed?
=> true

# Grąžina sąrašą atributų, kurie buvo pakeisti prieš išsaugojimą.
irb> person.changed
=> ["first_name"]

# Grąžina „Hash“, kuriame yra pakeistų atributų su jų pradinėmis reikšmėmis.
irb> person.changed_attributes
=> {"first_name"=>nil}

# Grąžina pakeitimų „Hash“, kurio atributų pavadinimai yra raktai, o reikšmės yra masyvas, kuriame yra senosios ir naujosios reikšmės šiam laukui.
irb> person.changes
=> {"first_name"=>[nil, "First Name"]}
```

#### Atributo pagrindiniai prieigos metodai

Stebėkite, ar konkretus atributas buvo pakeistas ar ne.
```irb
irb> person.first_name
=> "Vardas"

# attr_name_changed?
irb> person.first_name_changed?
=> true
```

Sekite atributo ankstesnės reikšmės.

```irb
# attr_name_was accessor
irb> person.first_name_was
=> nil
```

Sekite ankstesnę ir dabartinę pakeistos savybės reikšmes. Grąžina masyvą,
jei pakeista, kitu atveju grąžina nil.

```irb
# attr_name_change
irb> person.first_name_change
=> [nil, "Vardas"]
irb> person.last_name_change
=> nil
```

### Validacijos

`ActiveModel::Validations` modulis suteikia galimybę tikrinti objektus
kaip Active Record.

```ruby
class Person
  include ActiveModel::Validations

  attr_accessor :name, :email, :token

  validates :name, presence: true
  validates_format_of :email, with: /\A([^\s]+)((?:[-a-z0-9]\.)[a-z]{2,})\z/i
  validates! :token, presence: true
end
```

```irb
irb> person = Person.new
irb> person.token = "2b1f325"
irb> person.valid?
=> false
irb> person.name = 'vishnu'
irb> person.email = 'me'
irb> person.valid?
=> false
irb> person.email = 'me@vishnuatrai.com'
irb> person.valid?
=> true
irb> person.token = nil
irb> person.valid?
ActiveModel::StrictValidationFailed
```

### Pavadinimai

`ActiveModel::Naming` prideda keletą klasės metodų, kurie palengvina pavadinimų ir maršrutų
valdymą. Modulis apibrėžia `model_name` klasės metodą, kuris
apibrėžia keletą priėjimo būdų naudojant `ActiveSupport::Inflector` metodus.

```ruby
class Person
  extend ActiveModel::Naming
end

Person.model_name.name                # => "Person"
Person.model_name.singular            # => "person"
Person.model_name.plural              # => "people"
Person.model_name.element             # => "person"
Person.model_name.human               # => "Person"
Person.model_name.collection          # => "people"
Person.model_name.param_key           # => "person"
Person.model_name.i18n_key            # => :person
Person.model_name.route_key           # => "people"
Person.model_name.singular_route_key  # => "person"
```

### Modelis

`ActiveModel::Model` leidžia kurti modelius, panašius į `ActiveRecord::Base`.

```ruby
class EmailContact
  include ActiveModel::Model

  attr_accessor :name, :email, :message
  validates :name, :email, :message, presence: true

  def deliver
    if valid?
      # pristatyti el. laišką
    end
  end
end
```

Įtraukus `ActiveModel::Model`, gaunate visas funkcijas iš `ActiveModel::API`.

### Serializacija

`ActiveModel::Serialization` suteikia pagrindinę objekto serializaciją.
Turite apibrėžti atributų Hash, kuriame yra atributai, kuriuos norite
serializuoti. Atributai turi būti eilutės, o ne simboliai.

```ruby
class Person
  include ActiveModel::Serialization

  attr_accessor :name

  def attributes
    { 'name' => nil }
  end
end
```

Dabar galite pasiekti objekto serializuotą Hash naudodami `serializable_hash` metodą.

```irb
irb> person = Person.new
irb> person.serializable_hash
=> {"name"=>nil}
irb> person.name = "Bob"
irb> person.serializable_hash
=> {"name"=>"Bob"}
```

#### ActiveModel::Serializers

Active Model taip pat suteikia `ActiveModel::Serializers::JSON` modulį
JSON serializavimui / deserializavimui. Šis modulis automatiškai įtraukia
ankstesniai aptartą `ActiveModel::Serialization` modulį.

##### ActiveModel::Serializers::JSON

Norėdami naudoti `ActiveModel::Serializers::JSON`, turite pakeisti
įtraukiamą modulį iš `ActiveModel::Serialization` į `ActiveModel::Serializers::JSON`.

```ruby
class Person
  include ActiveModel::Serializers::JSON

  attr_accessor :name

  def attributes
    { 'name' => nil }
  end
end
```

`as_json` metodas, panašiai kaip `serializable_hash`, suteikia modelio
atitinkančią Hash reprezentaciją.

```irb
irb> person = Person.new
irb> person.as_json
=> {"name"=>nil}
irb> person.name = "Bob"
irb> person.as_json
=> {"name"=>"Bob"}
```

Taip pat galite apibrėžti atributus modeliui iš JSON eilutės.
Tačiau turite apibrėžti `attributes=` metodą savo klasėje:

```ruby
class Person
  include ActiveModel::Serializers::JSON

  attr_accessor :name

  def attributes=(hash)
    hash.each do |key, value|
      send("#{key}=", value)
    end
  end

  def attributes
    { 'name' => nil }
  end
end
```

Dabar galima sukurti `Person` objekto instanciją ir nustatyti atributus naudojant `from_json`.

```irb
irb> json = { name: 'Bob' }.to_json
irb> person = Person.new
irb> person.from_json(json)
=> #<Person:0x00000100c773f0 @name="Bob">
irb> person.name
=> "Bob"
```

### Vertimas

`ActiveModel::Translation` suteikia integraciją tarp jūsų objekto ir „Rails“
tarptautinės (i18n) sistemos.

```ruby
class Person
  extend ActiveModel::Translation
end
```

Naudojant `human_attribute_name` metodą, galite paversti atributo pavadinimus
į žmogui skaitytines formatus. Žmogui skaitytinas formatas yra apibrėžtas jūsų lokalizacijos failuose.

* config/locales/app.pt-BR.yml

```yaml
pt-BR:
  activemodel:
    attributes:
      person:
        name: 'Nome'
```

```ruby
Person.human_attribute_name('name') # => "Nome"
```

### Lint testai

`ActiveModel::Lint::Tests` leidžia patikrinti, ar objektas atitinka
Active Model API.

* `app/models/person.rb`

    ```ruby
    class Person
      include ActiveModel::Model
    end
    ```

* `test/models/person_test.rb`

    ```ruby
    require "test_helper"

    class PersonTest < ActiveSupport::TestCase
      include ActiveModel::Lint::Tests

      setup do
        @model = Person.new
      end
    end
    ```

```bash
$ bin/rails test

Run options: --seed 14596

# Running:

......

Finished in 0.024899s, 240.9735 runs/s, 1204.8677 assertions/s.

6 runs, 30 assertions, 0 failures, 0 errors, 0 skips
```

Objektui nereikia įgyvendinti visų API, kad veiktų su
Action Pack. Šis modulis tik siekia padėti, jei norite visų
funkcijų iškart.

### SecurePassword

`ActiveModel::SecurePassword` suteikia būdą saugiai saugoti bet kokį
slaptažodį užšifruotoje formoje. Įtraukus šį modulį, yra
pateikiamas `has_secure_password` klasės metodas, kuris apibrėžia
`password` priėjimo būdą su tam tikromis numatytomis tikrinimais.
```
#### Reikalavimai

`ActiveModel::SecurePassword` priklauso nuo [`bcrypt`](https://github.com/codahale/bcrypt-ruby 'BCrypt'),
todėl įtraukite šią juostą į savo `Gemfile`, kad teisingai naudotumėte `ActiveModel::SecurePassword`.
Tam, kad tai veiktų, modelyje turi būti prieigos teikėjas, pavadinimu `XXX_digest`.
Čia `XXX` yra jūsų norimo slaptažodžio atributo pavadinimas.
Automatiškai pridedami šie patikrinimai:

1. Slaptažodis turi būti pateiktas.
2. Slaptažodis turi būti lygus jo patvirtinimui (jei perduodamas `XXX_confirmation`).
3. Slaptažodžio maksimalus ilgis yra 72 (reikalaujama `bcrypt`, nuo kurio priklauso ActiveModel::SecurePassword).

#### Pavyzdžiai

```ruby
class Person
  include ActiveModel::SecurePassword
  has_secure_password
  has_secure_password :recovery_password, validations: false

  attr_accessor :password_digest, :recovery_password_digest
end
```

```irb
irb> person = Person.new

# Kai slaptažodis yra tuščias.
irb> person.valid?
=> false

# Kai patvirtinimas nesutampa su slaptažodžiu.
irb> person.password = 'aditya'
irb> person.password_confirmation = 'nomatch'
irb> person.valid?
=> false

# Kai slaptažodžio ilgis viršija 72.
irb> person.password = person.password_confirmation = 'a' * 100
irb> person.valid?
=> false

# Kai pateikiamas tik slaptažodis be slaptažodžio patvirtinimo.
irb> person.password = 'aditya'
irb> person.valid?
=> true

# Kai visi patikrinimai yra sėkmingi.
irb> person.password = person.password_confirmation = 'aditya'
irb> person.valid?
=> true

irb> person.recovery_password = "42password"

irb> person.authenticate('aditya')
=> #<Person> # == person
irb> person.authenticate('notright')
=> false
irb> person.authenticate_password('aditya')
=> #<Person> # == person
irb> person.authenticate_password('notright')
=> false

irb> person.authenticate_recovery_password('42password')
=> #<Person> # == person
irb> person.authenticate_recovery_password('notright')
=> false

irb> person.password_digest
=> "$2a$04$gF8RfZdoXHvyTjHhiU4ZsO.kQqV9oonYZu31PRE4hLQn3xM2qkpIy"
irb> person.recovery_password_digest
=> "$2a$04$iOfhwahFymCs5weB3BNH/uXkTG65HR.qpW.bNhEjFP3ftli3o5DQC"
```
