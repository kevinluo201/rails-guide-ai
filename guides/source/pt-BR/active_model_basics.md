**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: cee957545ee75801aab30265bc416992
Noções básicas do Active Model
==============================

Este guia deve fornecer tudo o que você precisa para começar a usar classes de modelo. O Active Model permite que os helpers do Action Pack interajam com objetos Ruby simples. O Active Model também ajuda a construir ORMs personalizados para uso fora do framework Rails.

Depois de ler este guia, você saberá:

* Como um modelo Active Record se comporta.
* Como funcionam os callbacks e validações.
* Como funcionam os serializadores.
* Como o Active Model se integra ao framework de internacionalização (i18n) do Rails.

--------------------------------------------------------------------------------

O que é o Active Model?
------------------------

O Active Model é uma biblioteca que contém vários módulos usados no desenvolvimento de classes que precisam de algumas funcionalidades presentes no Active Record. Alguns desses módulos são explicados abaixo.

### API

`ActiveModel::API` adiciona a capacidade de uma classe trabalhar com o Action Pack e o Action View prontamente.

```ruby
class EmailContact
  include ActiveModel::API

  attr_accessor :name, :email, :message
  validates :name, :email, :message, presence: true

  def deliver
    if valid?
      # enviar email
    end
  end
end
```

Ao incluir `ActiveModel::API`, você obtém recursos como:

- introspecção do nome do modelo
- conversões
- traduções
- validações

Ele também permite que você inicialize um objeto com um hash de atributos, assim como qualquer objeto Active Record.

```irb
irb> email_contact = EmailContact.new(name: 'David', email: 'david@example.com', message: 'Olá Mundo')
irb> email_contact.name
=> "David"
irb> email_contact.email
=> "david@example.com"
irb> email_contact.valid?
=> true
irb> email_contact.persisted?
=> false
```

Qualquer classe que inclua `ActiveModel::API` pode ser usada com `form_with`, `render` e qualquer outro método helper do Action View, assim como objetos Active Record.

### Métodos de Atributo

O módulo `ActiveModel::AttributeMethods` pode adicionar prefixos e sufixos personalizados aos métodos de uma classe. Ele é usado definindo os prefixos e sufixos e quais métodos do objeto os usarão.

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

### Callbacks

`ActiveModel::Callbacks` fornece callbacks no estilo Active Record. Isso permite definir callbacks que são executados nos momentos apropriados. Depois de definir os callbacks, você pode envolvê-los com métodos personalizados antes, depois e ao redor.

```ruby
class Person
  extend ActiveModel::Callbacks

  define_model_callbacks :update

  before_update :reset_me

  def update
    run_callbacks(:update) do
      # Este método é chamado quando o update é chamado em um objeto.
    end
  end

  def reset_me
    # Este método é chamado quando o update é chamado em um objeto, pois um callback before_update é definido.
  end
end
```

### Conversão

Se uma classe define os métodos `persisted?` e `id`, então você pode incluir o módulo `ActiveModel::Conversion` nessa classe e chamar os métodos de conversão do Rails em objetos dessa classe.

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

Um objeto se torna dirty quando passa por uma ou mais alterações em seus atributos e não foi salvo. `ActiveModel::Dirty` oferece a capacidade de verificar se um objeto foi alterado ou não. Ele também possui métodos de acesso baseados em atributos. Vamos considerar uma classe Person com os atributos `first_name` e `last_name`:

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
    # fazer o trabalho de salvar...
    changes_applied
  end
end
```

#### Consultando um objeto diretamente para obter sua lista de todos os atributos alterados

```irb
irb> person = Person.new
irb> person.changed?
=> false

irb> person.first_name = "Primeiro Nome"
irb> person.first_name
=> "Primeiro Nome"

# Retorna true se algum dos atributos tiver alterações não salvas.
irb> person.changed?
=> true

# Retorna uma lista de atributos que foram alterados antes de salvar.
irb> person.changed
=> ["first_name"]

# Retorna um Hash dos atributos que foram alterados com seus valores originais.
irb> person.changed_attributes
=> {"first_name"=>nil}

# Retorna um Hash de alterações, com os nomes dos atributos como chaves e os valores como um array dos valores antigo e novo para esse campo.
irb> person.changes
=> {"first_name"=>[nil, "Primeiro Nome"]}
```

#### Métodos de Acesso Baseados em Atributos

Acompanhe se o atributo específico foi alterado ou não.
```irb
irb> pessoa.primeiro_nome
=> "Primeiro Nome"

# attr_nome_alterado?
irb> pessoa.primeiro_nome_alterado?
=> true
```

Acompanhe o valor anterior do atributo.

```irb
# accessor attr_nome_era
irb> pessoa.primeiro_nome_era
=> nil
```

Acompanhe os valores anterior e atual do atributo alterado. Retorna um array
se alterado, caso contrário, retorna nil.

```irb
# attr_nome_alteracao
irb> pessoa.primeiro_nome_alteracao
=> [nil, "Primeiro Nome"]
irb> pessoa.sobrenome_alteracao
=> nil
```

### Validações

O módulo `ActiveModel::Validations` adiciona a capacidade de validar objetos
como no Active Record.

```ruby
class Pessoa
  include ActiveModel::Validations

  attr_accessor :nome, :email, :token

  validates :nome, presence: true
  validates_format_of :email, with: /\A([^\s]+)((?:[-a-z0-9]\.)[a-z]{2,})\z/i
  validates! :token, presence: true
end
```

```irb
irb> pessoa = Pessoa.new
irb> pessoa.token = "2b1f325"
irb> pessoa.valid?
=> false
irb> pessoa.nome = 'vishnu'
irb> pessoa.email = 'me'
irb> pessoa.valid?
=> false
irb> pessoa.email = 'me@vishnuatrai.com'
irb> pessoa.valid?
=> true
irb> pessoa.token = nil
irb> pessoa.valid?
ActiveModel::StrictValidationFailed
```

### Nomenclatura

`ActiveModel::Naming` adiciona vários métodos de classe que facilitam a nomenclatura e roteamento.
O módulo define o método de classe `model_name` que
definirá vários accessors usando alguns métodos de `ActiveSupport::Inflector`.

```ruby
class Pessoa
  extend ActiveModel::Naming
end

Pessoa.model_name.name                # => "Pessoa"
Pessoa.model_name.singular            # => "pessoa"
Pessoa.model_name.plural              # => "pessoas"
Pessoa.model_name.element             # => "pessoa"
Pessoa.model_name.human               # => "Pessoa"
Pessoa.model_name.collection          # => "pessoas"
Pessoa.model_name.param_key           # => "pessoa"
Pessoa.model_name.i18n_key            # => :pessoa
Pessoa.model_name.route_key           # => "pessoas"
Pessoa.model_name.singular_route_key  # => "pessoa"
```

### Modelo

`ActiveModel::Model` permite implementar modelos semelhantes ao `ActiveRecord::Base`.

```ruby
class ContatoEmail
  include ActiveModel::Model

  attr_accessor :nome, :email, :mensagem
  validates :nome, :email, :mensagem, presence: true

  def enviar
    if valid?
      # enviar email
    end
  end
end
```

Ao incluir `ActiveModel::Model`, você obtém todos os recursos de `ActiveModel::API`.

### Serialização

`ActiveModel::Serialization` fornece serialização básica para seu objeto.
Você precisa declarar um Hash de atributos que contém os atributos que deseja serializar.
Os atributos devem ser strings, não símbolos.

```ruby
class Pessoa
  include ActiveModel::Serialization

  attr_accessor :nome

  def attributes
    { 'nome' => nil }
  end
end
```

Agora você pode acessar um Hash serializado do seu objeto usando o método `serializable_hash`.

```irb
irb> pessoa = Pessoa.new
irb> pessoa.serializable_hash
=> {"nome"=>nil}
irb> pessoa.nome = "Bob"
irb> pessoa.serializable_hash
=> {"nome"=>"Bob"}
```

#### ActiveModel::Serializers

Active Model também fornece o módulo `ActiveModel::Serializers::JSON`
para serialização / desserialização JSON. Este módulo inclui automaticamente o
módulo `ActiveModel::Serialization` discutido anteriormente.

##### ActiveModel::Serializers::JSON

Para usar `ActiveModel::Serializers::JSON`, você só precisa alterar o
módulo que você está incluindo de `ActiveModel::Serialization` para `ActiveModel::Serializers::JSON`.

```ruby
class Pessoa
  include ActiveModel::Serializers::JSON

  attr_accessor :nome

  def attributes
    { 'nome' => nil }
  end
end
```

O método `as_json`, semelhante a `serializable_hash`, fornece um Hash representando
o modelo.

```irb
irb> pessoa = Pessoa.new
irb> pessoa.as_json
=> {"nome"=>nil}
irb> pessoa.nome = "Bob"
irb> pessoa.as_json
=> {"nome"=>"Bob"}
```

Você também pode definir os atributos de um modelo a partir de uma string JSON.
No entanto, você precisa definir o método `attributes=` na sua classe:

```ruby
class Pessoa
  include ActiveModel::Serializers::JSON

  attr_accessor :nome

  def attributes=(hash)
    hash.each do |key, value|
      send("#{key}=", value)
    end
  end

  def attributes
    { 'nome' => nil }
  end
end
```

Agora é possível criar uma instância de `Pessoa` e definir atributos usando `from_json`.

```irb
irb> json = { nome: 'Bob' }.to_json
irb> pessoa = Pessoa.new
irb> pessoa.from_json(json)
=> #<Pessoa:0x00000100c773f0 @nome="Bob">
irb> pessoa.nome
=> "Bob"
```

### Tradução

`ActiveModel::Translation` fornece integração entre seu objeto e o framework de internacionalização (i18n) do Rails.

```ruby
class Pessoa
  extend ActiveModel::Translation
end
```

Com o método `human_attribute_name`, você pode transformar nomes de atributos em um
formato mais legível para humanos. O formato legível para humanos é definido em seu(s) arquivo(s) de localização.

* config/locales/app.pt-BR.yml

```yaml
pt-BR:
  activemodel:
    attributes:
      pessoa:
        nome: 'Nome'
```

```ruby
Pessoa.human_attribute_name('nome') # => "Nome"
```

### Testes de Lint

`ActiveModel::Lint::Tests` permite testar se um objeto está em conformidade com
a API do Active Model.

* `app/models/pessoa.rb`

    ```ruby
    class Pessoa
      include ActiveModel::Model
    end
    ```

* `test/models/pessoa_test.rb`

    ```ruby
    require "test_helper"

    class PessoaTest < ActiveSupport::TestCase
      include ActiveModel::Lint::Tests

      setup do
        @model = Pessoa.new
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

Não é necessário que um objeto implemente todas as APIs para funcionar com
Action Pack. Este módulo apenas pretende orientar caso você queira todos
os recursos prontos para uso.

### SecurePassword

`ActiveModel::SecurePassword` fornece uma maneira de armazenar com segurança qualquer
senha em forma criptografada. Quando você inclui este módulo, um
método de classe `has_secure_password` é fornecido, que define
um accessor `password` com determinadas validações por padrão.
#### Requisitos

`ActiveModel::SecurePassword` depende do [`bcrypt`](https://github.com/codahale/bcrypt-ruby 'BCrypt'),
portanto, inclua essa gem no seu `Gemfile` para usar `ActiveModel::SecurePassword` corretamente.
Para que isso funcione, o modelo deve ter um acessor chamado `XXX_digest`.
Onde `XXX` é o nome do atributo da sua senha desejada.
As seguintes validações são adicionadas automaticamente:

1. A senha deve estar presente.
2. A senha deve ser igual à sua confirmação (desde que `XXX_confirmation` seja passado junto).
3. O comprimento máximo de uma senha é 72 (exigido pelo `bcrypt` no qual `ActiveModel::SecurePassword` depende).

#### Exemplos

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

# Quando a senha está em branco.
irb> person.valid?
=> false

# Quando a confirmação não corresponde à senha.
irb> person.password = 'aditya'
irb> person.password_confirmation = 'nomatch'
irb> person.valid?
=> false

# Quando o comprimento da senha excede 72.
irb> person.password = person.password_confirmation = 'a' * 100
irb> person.valid?
=> false

# Quando apenas a senha é fornecida sem a confirmação da senha.
irb> person.password = 'aditya'
irb> person.valid?
=> true

# Quando todas as validações são aprovadas.
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
