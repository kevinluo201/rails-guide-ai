**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: fdd2e5c41171c61b555549ced4d68a82
Extensões Principais do Active Support
=======================================

O Active Support é o componente do Ruby on Rails responsável por fornecer extensões e utilitários para a linguagem Ruby.

Ele oferece um suporte mais amplo no nível da linguagem, direcionado tanto para o desenvolvimento de aplicações Rails quanto para o desenvolvimento do próprio Ruby on Rails.

Após ler este guia, você saberá:

* O que são Extensões Principais.
* Como carregar todas as extensões.
* Como selecionar apenas as extensões desejadas.
* Quais extensões o Active Support fornece.

--------------------------------------------------------------------------------

Como Carregar Extensões Principais
---------------------------------

### Active Support Independente

Para ter a menor pegada padrão possível, o Active Support carrega as dependências mínimas por padrão. Ele é dividido em pequenas partes para que apenas as extensões desejadas possam ser carregadas. Ele também possui alguns pontos de entrada convenientes para carregar extensões relacionadas de uma só vez, ou até mesmo tudo.

Assim, após um simples require como:

```ruby
require "active_support"
```

apenas as extensões necessárias pelo framework Active Support são carregadas.

#### Selecionando uma Definição

Este exemplo mostra como carregar [`Hash#with_indifferent_access`][Hash#with_indifferent_access]. Esta extensão permite a conversão de um `Hash` em um [`ActiveSupport::HashWithIndifferentAccess`][ActiveSupport::HashWithIndifferentAccess], que permite o acesso às chaves tanto como strings quanto como símbolos.

```ruby
{ a: 1 }.with_indifferent_access["a"] # => 1
```

Para cada método definido como uma extensão principal, este guia possui uma nota que indica onde tal método é definido. No caso de `with_indifferent_access`, a nota diz:

NOTA: Definido em `active_support/core_ext/hash/indifferent_access.rb`.

Isso significa que você pode requerê-lo assim:

```ruby
require "active_support"
require "active_support/core_ext/hash/indifferent_access"
```

O Active Support foi cuidadosamente revisado para que a seleção de um arquivo carregue apenas as dependências estritamente necessárias, se houver.

#### Carregando Extensões Principais Agrupadas

O próximo nível é simplesmente carregar todas as extensões para `Hash`. Como regra geral, as extensões para `AlgumaClasse` estão disponíveis de uma só vez ao carregar `active_support/core_ext/alguma_classe`.

Assim, para carregar todas as extensões para `Hash` (incluindo `with_indifferent_access`):

```ruby
require "active_support"
require "active_support/core_ext/hash"
```

#### Carregando Todas as Extensões Principais

Você pode preferir apenas carregar todas as extensões principais, há um arquivo para isso:

```ruby
require "active_support"
require "active_support/core_ext"
```

#### Carregando Todo o Active Support

E finalmente, se você quiser ter todo o Active Support disponível, basta executar:

```ruby
require "active_support/all"
```

Isso nem mesmo coloca todo o Active Support na memória de uma vez, na verdade, algumas coisas são configuradas via `autoload`, então são carregadas apenas quando são utilizadas.

### Active Support Dentro de uma Aplicação Ruby on Rails

Uma aplicação Ruby on Rails carrega todo o Active Support, a menos que [`config.active_support.bare`][] seja verdadeiro. Nesse caso, a aplicação carregará apenas o que o próprio framework selecionar para suas próprias necessidades, e ainda poderá selecionar a si mesma em qualquer nível de granularidade, como explicado na seção anterior.


Extensões para Todos os Objetos
-------------------------------

### `blank?` e `present?`

Os seguintes valores são considerados em branco em uma aplicação Rails:

* `nil` e `false`,

* strings compostas apenas por espaços em branco (veja a nota abaixo),

* arrays e hashes vazios, e

* qualquer outro objeto que responda a `empty?` e esteja vazio.

INFO: O predicado para strings usa a classe de caracteres sensível ao Unicode `[:space:]`, então, por exemplo, U+2029 (separador de parágrafo) é considerado como espaço em branco.
AVISO: Observe que os números não são mencionados. Em particular, 0 e 0.0 não são **vazios**.

Por exemplo, este método de `ActionController::HttpAuthentication::Token::ControllerMethods` usa [`blank?`][Object#blank?] para verificar se um token está presente:

```ruby
def authenticate(controller, &login_procedure)
  token, options = token_and_options(controller.request)
  unless token.blank?
    login_procedure.call(token, options)
  end
end
```

O método [`present?`][Object#present?] é equivalente a `!blank?`. Este exemplo é retirado de `ActionDispatch::Http::Cache::Response`:

```ruby
def set_conditional_cache_control!
  return if self["Cache-Control"].present?
  # ...
end
```

NOTA: Definido em `active_support/core_ext/object/blank.rb`.


### `presence`

O método [`presence`][Object#presence] retorna seu receptor se `present?`, e `nil` caso contrário. É útil para idiomatismos como este:

```ruby
host = config[:host].presence || 'localhost'
```

NOTA: Definido em `active_support/core_ext/object/blank.rb`.


### `duplicable?`

A partir do Ruby 2.5, a maioria dos objetos pode ser duplicada via `dup` ou `clone`:

```ruby
"foo".dup           # => "foo"
"".dup              # => ""
Rational(1).dup     # => (1/1)
Complex(0).dup      # => (0+0i)
1.method(:+).dup    # => TypeError (allocator undefined for Method)
```

O Active Support fornece [`duplicable?`][Object#duplicable?] para consultar um objeto sobre isso:

```ruby
"foo".duplicable?           # => true
"".duplicable?              # => true
Rational(1).duplicable?     # => true
Complex(1).duplicable?      # => true
1.method(:+).duplicable?    # => false
```

AVISO: Qualquer classe pode impedir a duplicação removendo `dup` e `clone` ou lançando exceções a partir deles. Portanto, apenas `rescue` pode dizer se um determinado objeto arbitrário é duplicável. `duplicable?` depende da lista codificada acima, mas é muito mais rápido que `rescue`. Use-o apenas se souber que a lista codificada é suficiente para o seu caso de uso.

NOTA: Definido em `active_support/core_ext/object/duplicable.rb`.


### `deep_dup`

O método [`deep_dup`][Object#deep_dup] retorna uma cópia profunda de um determinado objeto. Normalmente, quando você `dup` um objeto que contém outros objetos, o Ruby não os `dup`, então ele cria uma cópia rasa do objeto. Se você tiver um array com uma string, por exemplo, ficará assim:

```ruby
array     = ['string']
duplicate = array.dup

duplicate.push 'another-string'

# o objeto foi duplicado, então o elemento foi adicionado apenas à duplicata
array     # => ['string']
duplicate # => ['string', 'another-string']

duplicate.first.gsub!('string', 'foo')

# o primeiro elemento não foi duplicado, ele será alterado em ambos os arrays
array     # => ['foo']
duplicate # => ['foo', 'another-string']
```

Como você pode ver, após duplicar a instância do `Array`, obtemos outro objeto, portanto, podemos modificá-lo e o objeto original permanecerá inalterado. No entanto, isso não é verdade para os elementos do array. Como `dup` não faz uma cópia profunda, a string dentro do array ainda é o mesmo objeto.

Se você precisa de uma cópia profunda de um objeto, você deve usar `deep_dup`. Aqui está um exemplo:

```ruby
array     = ['string']
duplicate = array.deep_dup

duplicate.first.gsub!('string', 'foo')

array     # => ['string']
duplicate # => ['foo']
```

Se o objeto não for duplicável, `deep_dup` simplesmente o retornará:

```ruby
number = 1
duplicate = number.deep_dup
number.object_id == duplicate.object_id   # => true
```

NOTA: Definido em `active_support/core_ext/object/deep_dup.rb`.


### `try`

Quando você deseja chamar um método em um objeto apenas se ele não for `nil`, a maneira mais simples de fazer isso é com declarações condicionais, adicionando desordem desnecessária. A alternativa é usar [`try`][Object#try]. `try` é como `Object#public_send`, exceto que retorna `nil` se enviado para `nil`.
Aqui está um exemplo:

```ruby
# sem try
unless @number.nil?
  @number.next
end

# com try
@number.try(:next)
```

Outro exemplo é este código de `ActiveRecord::ConnectionAdapters::AbstractAdapter` onde `@logger` pode ser `nil`. Você pode ver que o código usa `try` e evita uma verificação desnecessária.

```ruby
def log_info(sql, name, ms)
  if @logger.try(:debug?)
    name = '%s (%.1fms)' % [name || 'SQL', ms]
    @logger.debug(format_log_entry(name, sql.squeeze(' ')))
  end
end
```

`try` também pode ser chamado sem argumentos, mas com um bloco, que só será executado se o objeto não for nulo:

```ruby
@person.try { |p| "#{p.first_name} #{p.last_name}" }
```

Observe que `try` irá ignorar erros de método inexistente, retornando nil em vez disso. Se você quiser se proteger contra erros de digitação, use [`try!`][Object#try!] em vez disso:

```ruby
@number.try(:nest)  # => nil
@number.try!(:nest) # NoMethodError: undefined method `nest' for 1:Integer
```

NOTA: Definido em `active_support/core_ext/object/try.rb`.


### `class_eval(*args, &block)`

Você pode avaliar código no contexto da classe singleton de qualquer objeto usando [`class_eval`][Kernel#class_eval]:

```ruby
class Proc
  def bind(object)
    block, time = self, Time.current
    object.class_eval do
      method_name = "__bind_#{time.to_i}_#{time.usec}"
      define_method(method_name, &block)
      method = instance_method(method_name)
      remove_method(method_name)
      method
    end.bind(object)
  end
end
```

NOTA: Definido em `active_support/core_ext/kernel/singleton_class.rb`.


### `acts_like?(duck)`

O método [`acts_like?`][Object#acts_like?] fornece uma maneira de verificar se uma classe age como outra classe com base em uma convenção simples: uma classe que fornece a mesma interface que `String` define

```ruby
def acts_like_string?
end
```

que é apenas um marcador, seu corpo ou valor de retorno são irrelevantes. Em seguida, o código do cliente pode consultar se é seguro usar o duck-type dessa maneira:

```ruby
some_klass.acts_like?(:string)
```

O Rails possui classes que agem como `Date` ou `Time` e seguem esse contrato.

NOTA: Definido em `active_support/core_ext/object/acts_like.rb`.


### `to_param`

Todos os objetos no Rails respondem ao método [`to_param`][Object#to_param], que deve retornar algo que os represente como valores em uma string de consulta ou como fragmentos de URL.

Por padrão, `to_param` apenas chama `to_s`:

```ruby
7.to_param # => "7"
```

O valor de retorno de `to_param` **não** deve ser escapado:

```ruby
"Tom & Jerry".to_param # => "Tom & Jerry"
```

Várias classes no Rails sobrescrevem esse método.

Por exemplo, `nil`, `true` e `false` retornam eles mesmos. [`Array#to_param`][Array#to_param] chama `to_param` nos elementos e junta o resultado com "/":

```ruby
[0, true, String].to_param # => "0/true/String"
```

É importante observar que o sistema de roteamento do Rails chama `to_param` nos modelos para obter um valor para o espaço reservado `:id`. `ActiveRecord::Base#to_param` retorna o `id` de um modelo, mas você pode redefinir esse método em seus modelos. Por exemplo, dado

```ruby
class User
  def to_param
    "#{id}-#{name.parameterize}"
  end
end
```

obtemos:

```ruby
user_path(@user) # => "/users/357-john-smith"
```

CUIDADO. Os controladores precisam estar cientes de qualquer redefinição de `to_param`, porque quando uma solicitação como essa chega, "357-john-smith" é o valor de `params[:id]`.

NOTA: Definido em `active_support/core_ext/object/to_param.rb`.


### `to_query`

O método [`to_query`][Object#to_query] constrói uma string de consulta que associa uma determinada `key` com o valor de retorno de `to_param`. Por exemplo, com a seguinte definição de `to_param`:

```ruby
class User
  def to_param
    "#{id}-#{name.parameterize}"
  end
end
```

obtemos:

```ruby
current_user.to_query('user') # => "user=357-john-smith"
```

Este método escapa o que for necessário, tanto para a chave quanto para o valor:

```ruby
account.to_query('company[name]')
# => "company%5Bname%5D=Johnson+%26+Johnson"
```

portanto, sua saída está pronta para ser usada em uma string de consulta.
Arrays retornam o resultado da aplicação de `to_query` a cada elemento com `key[]` como chave, e junta o resultado com "&":

```ruby
[3.4, -45.6].to_query('sample')
# => "sample%5B%5D=3.4&sample%5B%5D=-45.6"
```

Hashes também respondem a `to_query`, mas com uma assinatura diferente. Se nenhum argumento for passado, uma chamada gera uma série ordenada de atribuições chave/valor chamando `to_query(key)` em seus valores. Em seguida, junta o resultado com "&":

```ruby
{ c: 3, b: 2, a: 1 }.to_query # => "a=1&b=2&c=3"
```

O método [`Hash#to_query`][Hash#to_query] aceita um namespace opcional para as chaves:

```ruby
{ id: 89, name: "John Smith" }.to_query('user')
# => "user%5Bid%5D=89&user%5Bname%5D=John+Smith"
```

NOTA: Definido em `active_support/core_ext/object/to_query.rb`.


### `with_options`

O método [`with_options`][Object#with_options] fornece uma maneira de agrupar opções comuns em uma série de chamadas de método.

Dado um hash de opções padrão, `with_options` gera um objeto proxy para um bloco. Dentro do bloco, os métodos chamados no proxy são encaminhados para o receptor com suas opções mescladas. Por exemplo, você pode se livrar da duplicação em:

```ruby
class Account < ApplicationRecord
  has_many :customers, dependent: :destroy
  has_many :products,  dependent: :destroy
  has_many :invoices,  dependent: :destroy
  has_many :expenses,  dependent: :destroy
end
```

desta forma:

```ruby
class Account < ApplicationRecord
  with_options dependent: :destroy do |assoc|
    assoc.has_many :customers
    assoc.has_many :products
    assoc.has_many :invoices
    assoc.has_many :expenses
  end
end
```

Esse idiom pode transmitir _agrupamento_ também para o leitor. Por exemplo, digamos que você queira enviar um boletim informativo cujo idioma depende do usuário. Em algum lugar do mailer, você pode agrupar trechos dependentes do idioma da seguinte forma:

```ruby
I18n.with_options locale: user.locale, scope: "newsletter" do |i18n|
  subject i18n.t :subject
  body    i18n.t :body, user_name: user.name
end
```

DICA: Como `with_options` encaminha chamadas para seu receptor, elas podem ser aninhadas. Cada nível de aninhamento mesclará os padrões herdados além dos próprios.

NOTA: Definido em `active_support/core_ext/object/with_options.rb`.


### Suporte a JSON

Active Support fornece uma implementação melhor de `to_json` do que a gem `json` normalmente fornece para objetos Ruby. Isso ocorre porque algumas classes, como `Hash` e `Process::Status`, precisam de tratamento especial para fornecer uma representação JSON adequada.

NOTA: Definido em `active_support/core_ext/object/json.rb`.

### Variáveis de Instância

Active Support fornece vários métodos para facilitar o acesso às variáveis de instância.

#### `instance_values`

O método [`instance_values`][Object#instance_values] retorna um hash que mapeia nomes de variáveis de instância sem "@" para seus valores correspondentes. As chaves são strings:

```ruby
class C
  def initialize(x, y)
    @x, @y = x, y
  end
end

C.new(0, 1).instance_values # => {"x" => 0, "y" => 1}
```

NOTA: Definido em `active_support/core_ext/object/instance_variables.rb`.


#### `instance_variable_names`

O método [`instance_variable_names`][Object#instance_variable_names] retorna um array. Cada nome inclui o sinal "@".

```ruby
class C
  def initialize(x, y)
    @x, @y = x, y
  end
end

C.new(0, 1).instance_variable_names # => ["@x", "@y"]
```

NOTA: Definido em `active_support/core_ext/object/instance_variables.rb`.


### Silenciando Avisos e Exceções

Os métodos [`silence_warnings`][Kernel#silence_warnings] e [`enable_warnings`][Kernel#enable_warnings] alteram o valor de `$VERBOSE` de acordo com a duração de seu bloco e o redefinem posteriormente:

```ruby
silence_warnings { Object.const_set "RAILS_DEFAULT_LOGGER", logger }
```

Também é possível silenciar exceções com [`suppress`][Kernel#suppress]. Este método recebe um número arbitrário de classes de exceção. Se uma exceção for lançada durante a execução do bloco e for `kind_of?` qualquer um dos argumentos, `suppress` a captura e retorna silenciosamente. Caso contrário, a exceção não é capturada:
```ruby
# Se o usuário estiver bloqueado, o incremento é perdido, não é um grande problema.
suppress(ActiveRecord::StaleObjectError) do
  current_user.increment! :visits
end
```

NOTA: Definido em `active_support/core_ext/kernel/reporting.rb`.


### `in?`

O predicado [`in?`][Object#in?] testa se um objeto está incluído em outro objeto. Uma exceção `ArgumentError` será lançada se o argumento passado não responder a `include?`.

Exemplos de `in?`:

```ruby
1.in?([1, 2])        # => true
"lo".in?("hello")   # => true
25.in?(30..50)      # => false
1.in?(1)            # => ArgumentError
```

NOTA: Definido em `active_support/core_ext/object/inclusion.rb`.


Extensões para `Module`
----------------------

### Atributos

#### `alias_attribute`

Os atributos do modelo têm um leitor, um escritor e um predicado. Você pode criar um alias para um atributo do modelo tendo os três métodos correspondentes todos definidos para você usando [`alias_attribute`][Module#alias_attribute]. Como em outros métodos de aliasing, o novo nome é o primeiro argumento e o antigo nome é o segundo (uma mnemônica é que eles seguem a mesma ordem que em uma atribuição):

```ruby
class User < ApplicationRecord
  # Você pode se referir à coluna de email como "login".
  # Isso pode ser significativo para o código de autenticação.
  alias_attribute :login, :email
end
```

NOTA: Definido em `active_support/core_ext/module/aliasing.rb`.


#### Atributos Internos

Quando você está definindo um atributo em uma classe que é destinada a ser subclassificada, colisões de nomes são um risco. Isso é notavelmente importante para bibliotecas.

Active Support define as macros [`attr_internal_reader`][Module#attr_internal_reader], [`attr_internal_writer`][Module#attr_internal_writer] e [`attr_internal_accessor`][Module#attr_internal_accessor]. Elas se comportam como suas contrapartes Ruby `attr_*` embutidas, exceto que nomeiam a variável de instância subjacente de uma maneira que torna as colisões menos prováveis.

A macro [`attr_internal`][Module#attr_internal] é um sinônimo para `attr_internal_accessor`:

```ruby
# biblioteca
class ThirdPartyLibrary::Crawler
  attr_internal :log_level
end

# código do cliente
class MyCrawler < ThirdPartyLibrary::Crawler
  attr_accessor :log_level
end
```

No exemplo anterior, pode ser o caso de que `:log_level` não pertença à interface pública da biblioteca e seja usado apenas para desenvolvimento. O código do cliente, desconhecendo o conflito potencial, faz uma subclasse e define seu próprio `:log_level`. Graças ao `attr_internal`, não há colisão.

Por padrão, a variável de instância interna é nomeada com um sublinhado inicial, `@_log_level` no exemplo acima. Isso é configurável através de `Module.attr_internal_naming_format`, você pode passar qualquer string de formato `sprintf`-like com um `@` inicial e um `%s` em algum lugar, onde o nome será colocado. O padrão é `"@_%s"`.

O Rails usa atributos internos em alguns pontos, por exemplo, para views:

```ruby
module ActionView
  class Base
    attr_internal :captures
    attr_internal :request, :layout
    attr_internal :controller, :template
  end
end
```

NOTA: Definido em `active_support/core_ext/module/attr_internal.rb`.


#### Atributos do Módulo

As macros [`mattr_reader`][Module#mattr_reader], [`mattr_writer`][Module#mattr_writer] e [`mattr_accessor`][Module#mattr_accessor] são as mesmas macros `cattr_*` definidas para classes. Na verdade, as macros `cattr_*` são apenas aliases para as macros `mattr_*`. Veja [Atributos de Classe](#class-attributes).

Por exemplo, a API para o logger do Active Storage é gerada com `mattr_accessor`:

```ruby
module ActiveStorage
  mattr_accessor :logger
end
```

NOTA: Definido em `active_support/core_ext/module/attribute_accessors.rb`.


### Pais

#### `module_parent`

O método [`module_parent`][Module#module_parent] em um módulo nomeado aninhado retorna o módulo que contém sua constante correspondente:

```ruby
module X
  module Y
    module Z
    end
  end
end
M = X::Y::Z

X::Y::Z.module_parent # => X::Y
M.module_parent       # => X::Y
```

Se o módulo for anônimo ou pertencer ao nível superior, `module_parent` retorna `Object`.
AVISO: Observe que, nesse caso, `module_parent_name` retorna `nil`.

NOTA: Definido em `active_support/core_ext/module/introspection.rb`.


#### `module_parent_name`

O método [`module_parent_name`][Module#module_parent_name] em um módulo nomeado aninhado retorna o nome totalmente qualificado do módulo que contém sua constante correspondente:

```ruby
module X
  module Y
    module Z
    end
  end
end
M = X::Y::Z

X::Y::Z.module_parent_name # => "X::Y"
M.module_parent_name       # => "X::Y"
```

Para módulos de nível superior ou anônimos, `module_parent_name` retorna `nil`.

AVISO: Observe que, nesse caso, `module_parent` retorna `Object`.

NOTA: Definido em `active_support/core_ext/module/introspection.rb`.


#### `module_parents`

O método [`module_parents`][Module#module_parents] chama `module_parent` no receptor e nos módulos superiores até que `Object` seja alcançado. A cadeia é retornada em um array, de baixo para cima:

```ruby
module X
  module Y
    module Z
    end
  end
end
M = X::Y::Z

X::Y::Z.module_parents # => [X::Y, X, Object]
M.module_parents       # => [X::Y, X, Object]
```

NOTA: Definido em `active_support/core_ext/module/introspection.rb`.


### Anônimo

Um módulo pode ou não ter um nome:

```ruby
module M
end
M.name # => "M"

N = Module.new
N.name # => "N"

Module.new.name # => nil
```

Você pode verificar se um módulo tem um nome com o predicado [`anonymous?`][Module#anonymous?]:

```ruby
module M
end
M.anonymous? # => false

Module.new.anonymous? # => true
```

Observe que ser inacessível não implica ser anônimo:

```ruby
module M
end

m = Object.send(:remove_const, :M)

m.anonymous? # => false
```

embora um módulo anônimo seja inacessível por definição.

NOTA: Definido em `active_support/core_ext/module/anonymous.rb`.


### Delegação de Método

#### `delegate`

A macro [`delegate`][Module#delegate] oferece uma maneira fácil de encaminhar métodos.

Vamos imaginar que os usuários em um aplicativo têm informações de login no modelo `User`, mas nome e outros dados em um modelo separado `Profile`:

```ruby
class User < ApplicationRecord
  has_one :profile
end
```

Com essa configuração, você obtém o nome do usuário por meio do perfil, `user.profile.name`, mas pode ser útil ainda poder acessar esse atributo diretamente:

```ruby
class User < ApplicationRecord
  has_one :profile

  def name
    profile.name
  end
end
```

Isso é o que `delegate` faz por você:

```ruby
class User < ApplicationRecord
  has_one :profile

  delegate :name, to: :profile
end
```

É mais curto e a intenção é mais óbvia.

O método deve ser público no alvo.

A macro `delegate` aceita vários métodos:

```ruby
delegate :name, :age, :address, :twitter, to: :profile
```

Quando interpolado em uma string, a opção `:to` deve se tornar uma expressão que avalia para o objeto ao qual o método é delegado. Normalmente uma string ou símbolo. Essa expressão é avaliada no contexto do receptor:

```ruby
# delega para a constante Rails
delegate :logger, to: :Rails

# delega para a classe do receptor
delegate :table_name, to: :class
```

AVISO: Se a opção `:prefix` for `true`, isso é menos genérico, veja abaixo.

Por padrão, se a delegação levantar `NoMethodError` e o alvo for `nil`, a exceção é propagada. Você pode solicitar que `nil` seja retornado em vez disso com a opção `:allow_nil`:

```ruby
delegate :name, to: :profile, allow_nil: true
```

Com `:allow_nil`, a chamada `user.name` retorna `nil` se o usuário não tiver um perfil.

A opção `:prefix` adiciona um prefixo ao nome do método gerado. Isso pode ser útil, por exemplo, para obter um nome melhor:
```ruby
delegate :street, to: :address, prefix: true
```

O exemplo anterior gera `address_street` em vez de `street`.

AVISO: Neste caso, como o nome do método gerado é composto pelo objeto alvo e pelos nomes dos métodos alvo, a opção `:to` deve ser um nome de método.

Um prefixo personalizado também pode ser configurado:

```ruby
delegate :size, to: :attachment, prefix: :avatar
```

No exemplo anterior, a macro gera `avatar_size` em vez de `size`.

A opção `:private` altera o escopo dos métodos:

```ruby
delegate :date_of_birth, to: :profile, private: true
```

Os métodos delegados são públicos por padrão. Passe `private: true` para alterar isso.

NOTA: Definido em `active_support/core_ext/module/delegation.rb`


#### `delegate_missing_to`

Imagine que você gostaria de delegar tudo que está faltando no objeto `User` para o objeto `Profile`. A macro [`delegate_missing_to`][Module#delegate_missing_to] permite que você implemente isso facilmente:

```ruby
class User < ApplicationRecord
  has_one :profile

  delegate_missing_to :profile
end
```

O alvo pode ser qualquer coisa chamável dentro do objeto, como variáveis de instância, métodos, constantes, etc. Apenas os métodos públicos do alvo são delegados.

NOTA: Definido em `active_support/core_ext/module/delegation.rb`.


### Redefinindo Métodos

Existem casos em que você precisa definir um método com `define_method`, mas não sabe se um método com esse nome já existe. Se existir, um aviso é emitido se eles estiverem habilitados. Não é um grande problema, mas também não é limpo.

O método [`redefine_method`][Module#redefine_method] evita esse aviso potencial, removendo o método existente antes, se necessário.

Você também pode usar [`silence_redefinition_of_method`][Module#silence_redefinition_of_method] se precisar definir o método de substituição você mesmo (porque está usando `delegate`, por exemplo).

NOTA: Definido em `active_support/core_ext/module/redefine_method.rb`.


Extensões para `Class`
---------------------

### Atributos de Classe

#### `class_attribute`

O método [`class_attribute`][Class#class_attribute] declara um ou mais atributos de classe hereditários que podem ser substituídos em qualquer nível da hierarquia.

```ruby
class A
  class_attribute :x
end

class B < A; end

class C < B; end

A.x = :a
B.x # => :a
C.x # => :a

B.x = :b
A.x # => :a
C.x # => :b

C.x = :c
A.x # => :a
B.x # => :b
```

Por exemplo, `ActionMailer::Base` define:

```ruby
class_attribute :default_params
self.default_params = {
  mime_version: "1.0",
  charset: "UTF-8",
  content_type: "text/plain",
  parts_order: [ "text/plain", "text/enriched", "text/html" ]
}.freeze
```

Eles também podem ser acessados e substituídos no nível da instância.

```ruby
A.x = 1

a1 = A.new
a2 = A.new
a2.x = 2

a1.x # => 1, vem de A
a2.x # => 2, substituído em a2
```

A geração do método de escrita da instância pode ser impedida definindo a opção `:instance_writer` como `false`.

```ruby
module ActiveRecord
  class Base
    class_attribute :table_name_prefix, instance_writer: false, default: "my"
  end
end
```

Um modelo pode achar essa opção útil como uma forma de impedir a atribuição em massa de definir o atributo.

A geração do método de leitura da instância pode ser impedida definindo a opção `:instance_reader` como `false`.

```ruby
class A
  class_attribute :x, instance_reader: false
end

A.new.x = 1
A.new.x # NoMethodError
```

Para conveniência, `class_attribute` também define um predicado de instância que é a dupla negação do que o leitor de instância retorna. Nos exemplos acima, seria chamado de `x?`.
Quando `:instance_reader` é `false`, o predicado da instância retorna um `NoMethodError`, assim como o método leitor.

Se você não deseja o predicado da instância, passe `instance_predicate: false` e ele não será definido.

NOTA: Definido em `active_support/core_ext/class/attribute.rb`.


#### `cattr_reader`, `cattr_writer` e `cattr_accessor`

As macros [`cattr_reader`][Module#cattr_reader], [`cattr_writer`][Module#cattr_writer] e [`cattr_accessor`][Module#cattr_accessor] são análogas às suas contrapartes `attr_*`, mas para classes. Elas inicializam uma variável de classe como `nil`, a menos que ela já exista, e geram os métodos de classe correspondentes para acessá-la:

```ruby
class MysqlAdapter < AbstractAdapter
  # Gera métodos de classe para acessar @@emulate_booleans.
  cattr_accessor :emulate_booleans
end
```

Além disso, você pode passar um bloco para `cattr_*` para configurar o atributo com um valor padrão:

```ruby
class MysqlAdapter < AbstractAdapter
  # Gera métodos de classe para acessar @@emulate_booleans com valor padrão true.
  cattr_accessor :emulate_booleans, default: true
end
```

Métodos de instância também são criados para conveniência, eles são apenas proxies para o atributo de classe. Portanto, as instâncias podem alterar o atributo de classe, mas não podem substituí-lo como acontece com `class_attribute` (veja acima). Por exemplo, dado

```ruby
module ActionView
  class Base
    cattr_accessor :field_error_proc, default: Proc.new { ... }
  end
end
```

podemos acessar `field_error_proc` nas views.

A geração do método leitor de instância pode ser impedida definindo `:instance_reader` como `false` e a geração do método escritor de instância pode ser impedida definindo `:instance_writer` como `false`. A geração de ambos os métodos pode ser impedida definindo `:instance_accessor` como `false`. Em todos os casos, o valor deve ser exatamente `false` e não qualquer valor falso.

```ruby
module A
  class B
    # Nenhum leitor de instância first_name é gerado.
    cattr_accessor :first_name, instance_reader: false
    # Nenhum escritor de instância last_name= é gerado.
    cattr_accessor :last_name, instance_writer: false
    # Nenhum leitor de instância surname ou escritor surname= é gerado.
    cattr_accessor :surname, instance_accessor: false
  end
end
```

Um modelo pode achar útil definir `:instance_accessor` como `false` como uma forma de impedir a atribuição em massa de definir o atributo.

NOTA: Definido em `active_support/core_ext/module/attribute_accessors.rb`.


### Subclasses e Descendentes

#### `subclasses`

O método [`subclasses`][Class#subclasses] retorna as subclasses do receptor:

```ruby
class C; end
C.subclasses # => []

class B < C; end
C.subclasses # => [B]

class A < B; end
C.subclasses # => [B]

class D < C; end
C.subclasses # => [B, D]
```

A ordem em que essas classes são retornadas não é especificada.

NOTA: Definido em `active_support/core_ext/class/subclasses.rb`.


#### `descendants`

O método [`descendants`][Class#descendants] retorna todas as classes que são `<` que o receptor:

```ruby
class C; end
C.descendants # => []

class B < C; end
C.descendants # => [B]

class A < B; end
C.descendants # => [B, A]

class D < C; end
C.descendants # => [B, A, D]
```

A ordem em que essas classes são retornadas não é especificada.

NOTA: Definido em `active_support/core_ext/class/subclasses.rb`.


Extensões para `String`
----------------------

### Segurança na Saída

#### Motivação

Inserir dados em modelos HTML requer cuidado extra. Por exemplo, você não pode simplesmente interpolar `@review.title` literalmente em uma página HTML. Por um lado, se o título da revisão for "Flanagan & Matz rules!", a saída não será bem formada porque um ampersand deve ser escapado como "&amp;amp;". Além disso, dependendo da aplicação, isso pode ser uma grande vulnerabilidade de segurança, pois os usuários podem injetar HTML malicioso definindo um título de revisão feito sob medida. Consulte a seção sobre cross-site scripting no [guia de segurança](security.html#cross-site-scripting-xss) para obter mais informações sobre os riscos.
#### Strings Seguras

Active Support possui o conceito de strings _(html) seguras_. Uma string segura é aquela que é marcada como sendo inserível em HTML como está. Ela é confiável, independentemente de ter sido escapada ou não.

Por padrão, as strings são consideradas _inseguras_:

```ruby
"".html_safe? # => false
```

Você pode obter uma string segura a partir de uma dada string usando o método [`html_safe`][String#html_safe]:

```ruby
s = "".html_safe
s.html_safe? # => true
```

É importante entender que `html_safe` não realiza nenhum tipo de escape, é apenas uma afirmação:

```ruby
s = "<script>...</script>".html_safe
s.html_safe? # => true
s            # => "<script>...</script>"
```

É sua responsabilidade garantir que chamar `html_safe` em uma determinada string seja seguro.

Se você adicionar uma string segura, seja no local com `concat`/`<<`, ou com `+`, o resultado será uma string segura. Argumentos inseguros são escapados:

```ruby
"".html_safe + "<" # => "&lt;"
```

Argumentos seguros são adicionados diretamente:

```ruby
"".html_safe + "<".html_safe # => "<"
```

Esses métodos não devem ser usados em visualizações comuns. Valores inseguros são automaticamente escapados:

```erb
<%= @review.title %> <%# tudo bem, escapado se necessário %>
```

Para inserir algo literalmente, use o auxiliar [`raw`][] em vez de chamar `html_safe`:

```erb
<%= raw @cms.current_template %> <%# insere @cms.current_template como está %>
```

ou, de forma equivalente, use `<%==`:

```erb
<%== @cms.current_template %> <%# insere @cms.current_template como está %>
```

O auxiliar `raw` chama `html_safe` para você:

```ruby
def raw(stringish)
  stringish.to_s.html_safe
end
```

NOTA: Definido em `active_support/core_ext/string/output_safety.rb`.


#### Transformação

Como regra geral, exceto talvez para concatenação, como explicado acima, qualquer método que possa alterar uma string retorna uma string insegura. Esses métodos são `downcase`, `gsub`, `strip`, `chomp`, `underscore`, etc.

No caso de transformações no local, como `gsub!`, o próprio receptor se torna inseguro.

INFO: O bit de segurança é sempre perdido, independentemente de a transformação ter realmente alterado algo.

#### Conversão e Coerção

Chamar `to_s` em uma string segura retorna uma string segura, mas a coerção com `to_str` retorna uma string insegura.

#### Cópia

Chamar `dup` ou `clone` em strings seguras produz strings seguras.

### `remove`

O método [`remove`][String#remove] irá remover todas as ocorrências do padrão:

```ruby
"Hello World".remove(/Hello /) # => "World"
```

Também existe a versão destrutiva `String#remove!`.

NOTA: Definido em `active_support/core_ext/string/filters.rb`.


### `squish`

O método [`squish`][String#squish] remove espaços em branco no início e no final, e substitui sequências de espaços em branco por um único espaço:

```ruby
" \n  foo\n\r \t bar \n".squish # => "foo bar"
```

Também existe a versão destrutiva `String#squish!`.

Observe que ele lida tanto com espaços em branco ASCII quanto Unicode.

NOTA: Definido em `active_support/core_ext/string/filters.rb`.


### `truncate`

O método [`truncate`][String#truncate] retorna uma cópia da string truncada após um determinado `length`:

```ruby
"Oh dear! Oh dear! I shall be late!".truncate(20)
# => "Oh dear! Oh dear!..."
```

O ponto de reticências pode ser personalizado com a opção `:omission`:

```ruby
"Oh dear! Oh dear! I shall be late!".truncate(20, omission: '&hellip;')
# => "Oh dear! Oh &hellip;"
```

Observe em particular que a truncagem leva em conta o comprimento da string de omissão.

Passe um `:separator` para truncar a string em uma quebra natural:
```ruby
"Oh querido! Oh querido! Eu vou me atrasar!".truncate(18)
# => "Oh querido! Oh qu..."
"Oh querido! Oh querido! Eu vou me atrasar!".truncate(18, separator: ' ')
# => "Oh querido! Oh..."
```

A opção `:separator` pode ser uma expressão regular:

```ruby
"Oh querido! Oh querido! Eu vou me atrasar!".truncate(18, separator: /\s/)
# => "Oh querido! Oh..."
```

Nos exemplos acima, "querido" é cortado primeiro, mas depois `:separator` impede isso.

NOTA: Definido em `active_support/core_ext/string/filters.rb`.


### `truncate_bytes`

O método [`truncate_bytes`][String#truncate_bytes] retorna uma cópia da string truncada para no máximo `bytesize` bytes:

```ruby
"👍👍👍👍".truncate_bytes(15)
# => "👍👍👍…"
```

O ponto de reticências pode ser personalizado com a opção `:omission`:

```ruby
"👍👍👍👍".truncate_bytes(15, omission: "🖖")
# => "👍👍🖖"
```

NOTA: Definido em `active_support/core_ext/string/filters.rb`.


### `truncate_words`

O método [`truncate_words`][String#truncate_words] retorna uma cópia da string truncada após um determinado número de palavras:

```ruby
"Oh querido! Oh querido! Eu vou me atrasar!".truncate_words(4)
# => "Oh querido! Oh querido!..."
```

O ponto de reticências pode ser personalizado com a opção `:omission`:

```ruby
"Oh querido! Oh querido! Eu vou me atrasar!".truncate_words(4, omission: '&hellip;')
# => "Oh querido! Oh querido!&hellip;"
```

Passe um `:separator` para truncar a string em uma quebra natural:

```ruby
"Oh querido! Oh querido! Eu vou me atrasar!".truncate_words(3, separator: '!')
# => "Oh querido! Oh querido! Eu vou me atrasar..."
```

A opção `:separator` pode ser uma expressão regular:

```ruby
"Oh querido! Oh querido! Eu vou me atrasar!".truncate_words(4, separator: /\s/)
# => "Oh querido! Oh querido!..."
```

NOTA: Definido em `active_support/core_ext/string/filters.rb`.


### `inquiry`

O método [`inquiry`][String#inquiry] converte uma string em um objeto `StringInquirer`, tornando as verificações de igualdade mais legíveis.

```ruby
"produção".inquiry.production? # => true
"ativo".inquiry.inactive?       # => false
```

NOTA: Definido em `active_support/core_ext/string/inquiry.rb`.


### `starts_with?` e `ends_with?`

O Active Support define aliases de terceira pessoa para `String#start_with?` e `String#end_with?`:

```ruby
"foo".starts_with?("f") # => true
"foo".ends_with?("o")   # => true
```

NOTA: Definido em `active_support/core_ext/string/starts_ends_with.rb`.

### `strip_heredoc`

O método [`strip_heredoc`][String#strip_heredoc] remove a indentação em heredocs.

Por exemplo, em

```ruby
if options[:usage]
  puts <<-USAGE.strip_heredoc
    Este comando faz tal e tal coisa.

    As opções suportadas são:
      -h         Esta mensagem
      ...
  USAGE
end
```

o usuário veria a mensagem de uso alinhada à margem esquerda.

Tecnicamente, ele procura pela linha com a menor indentação em toda a string e remove
essa quantidade de espaços em branco no início.

NOTA: Definido em `active_support/core_ext/string/strip.rb`.


### `indent`

O método [`indent`][String#indent] recua as linhas da string:

```ruby
<<EOS.indent(2)
def algum_metodo
  algum_codigo
end
EOS
# =>
  def algum_metodo
    algum_codigo
  end
```

O segundo argumento, `indent_string`, especifica qual string de recuo usar. O padrão é `nil`, o que faz com que o método faça uma suposição educada olhando para a primeira linha recuada e usando um espaço se não houver.

```ruby
"  foo".indent(2)        # => "    foo"
"foo\n\t\tbar".indent(2) # => "\t\tfoo\n\t\t\t\tbar"
"foo".indent(2, "\t")    # => "\t\tfoo"
```

Embora `indent_string` seja tipicamente um espaço ou uma tabulação, ele pode ser qualquer string.

O terceiro argumento, `indent_empty_lines`, é uma flag que indica se as linhas vazias devem ser recuadas. O padrão é falso.

```ruby
"foo\n\nbar".indent(2)            # => "  foo\n\n  bar"
"foo\n\nbar".indent(2, nil, true) # => "  foo\n  \n  bar"
```

O método [`indent!`][String#indent!] realiza a recuo no local.

NOTA: Definido em `active_support/core_ext/string/indent.rb`.
### Acesso

#### `at(position)`

O método [`at`][String#at] retorna o caractere da string na posição `position`:

```ruby
"hello".at(0)  # => "h"
"hello".at(4)  # => "o"
"hello".at(-1) # => "o"
"hello".at(10) # => nil
```

NOTA: Definido em `active_support/core_ext/string/access.rb`.


#### `from(position)`

O método [`from`][String#from] retorna a substring da string a partir da posição `position`:

```ruby
"hello".from(0)  # => "hello"
"hello".from(2)  # => "llo"
"hello".from(-2) # => "lo"
"hello".from(10) # => nil
```

NOTA: Definido em `active_support/core_ext/string/access.rb`.


#### `to(position)`

O método [`to`][String#to] retorna a substring da string até a posição `position`:

```ruby
"hello".to(0)  # => "h"
"hello".to(2)  # => "hel"
"hello".to(-2) # => "hell"
"hello".to(10) # => "hello"
```

NOTA: Definido em `active_support/core_ext/string/access.rb`.


#### `first(limit = 1)`

O método [`first`][String#first] retorna uma substring contendo os primeiros `limit` caracteres da string.

A chamada `str.first(n)` é equivalente a `str.to(n-1)` se `n` > 0, e retorna uma string vazia para `n` == 0.

NOTA: Definido em `active_support/core_ext/string/access.rb`.


#### `last(limit = 1)`

O método [`last`][String#last] retorna uma substring contendo os últimos `limit` caracteres da string.

A chamada `str.last(n)` é equivalente a `str.from(-n)` se `n` > 0, e retorna uma string vazia para `n` == 0.

NOTA: Definido em `active_support/core_ext/string/access.rb`.


### Inflections

#### `pluralize`

O método [`pluralize`][String#pluralize] retorna o plural de sua string de entrada:

```ruby
"table".pluralize     # => "tables"
"ruby".pluralize      # => "rubies"
"equipment".pluralize # => "equipment"
```

Como o exemplo anterior mostra, o Active Support conhece alguns plurais irregulares e substantivos incontáveis. Regras embutidas podem ser estendidas em `config/initializers/inflections.rb`. Este arquivo é gerado por padrão pelo comando `rails new` e possui instruções em comentários.

`pluralize` também pode receber um parâmetro opcional `count`. Se `count == 1`, a forma singular será retornada. Para qualquer outro valor de `count`, a forma plural será retornada:

```ruby
"dude".pluralize(0) # => "dudes"
"dude".pluralize(1) # => "dude"
"dude".pluralize(2) # => "dudes"
```

O Active Record usa esse método para calcular o nome padrão da tabela que corresponde a um modelo:

```ruby
# active_record/model_schema.rb
def undecorated_table_name(model_name)
  table_name = model_name.to_s.demodulize.underscore
  pluralize_table_names ? table_name.pluralize : table_name
end
```

NOTA: Definido em `active_support/core_ext/string/inflections.rb`.


#### `singularize`

O método [`singularize`][String#singularize] é o inverso de `pluralize`:

```ruby
"tables".singularize    # => "table"
"rubies".singularize    # => "ruby"
"equipment".singularize # => "equipment"
```

As associações calculam o nome da classe associada padrão correspondente usando esse método:

```ruby
# active_record/reflection.rb
def derive_class_name
  class_name = name.to_s.camelize
  class_name = class_name.singularize if collection?
  class_name
end
```

NOTA: Definido em `active_support/core_ext/string/inflections.rb`.


#### `camelize`

O método [`camelize`][String#camelize] retorna sua string de entrada em camel case:

```ruby
"product".camelize    # => "Product"
"admin_user".camelize # => "AdminUser"
```

Como uma regra geral, você pode pensar neste método como aquele que transforma caminhos em nomes de classes ou módulos Ruby, onde as barras separa os namespaces:

```ruby
"backoffice/session".camelize # => "Backoffice::Session"
```

Por exemplo, o Action Pack usa esse método para carregar a classe que fornece um determinado armazenamento de sessão:

```ruby
# action_controller/metal/session_management.rb
def session_store=(store)
  @@session_store = store.is_a?(Symbol) ?
    ActionDispatch::Session.const_get(store.to_s.camelize) :
    store
end
```

`camelize` aceita um argumento opcional, que pode ser `:upper` (padrão) ou `:lower`. Com o último, a primeira letra se torna minúscula:
```ruby
"visual_effect".camelize(:lower) # => "visualEffect"
```

Isso pode ser útil para calcular nomes de métodos em uma linguagem que segue essa convenção, por exemplo JavaScript.

INFO: Como regra geral, você pode pensar em `camelize` como o inverso de `underscore`, embora haja casos em que isso não se aplica: `"SSLError".underscore.camelize` retorna `"SslError"`. Para suportar casos como esse, o Active Support permite que você especifique siglas em `config/initializers/inflections.rb`:

```ruby
ActiveSupport::Inflector.inflections do |inflect|
  inflect.acronym 'SSL'
end

"SSLError".underscore.camelize # => "SSLError"
```

`camelize` é um alias para [`camelcase`][String#camelcase].

NOTA: Definido em `active_support/core_ext/string/inflections.rb`.


#### `underscore`

O método [`underscore`][String#underscore] faz o contrário, de camel case para paths:

```ruby
"Product".underscore   # => "product"
"AdminUser".underscore # => "admin_user"
```

Também converte "::" para "/":

```ruby
"Backoffice::Session".underscore # => "backoffice/session"
```

E entende strings que começam com letra minúscula:

```ruby
"visualEffect".underscore # => "visual_effect"
```

`underscore` não aceita argumentos.

O Rails usa `underscore` para obter um nome em minúsculas para classes de controladores:

```ruby
# actionpack/lib/abstract_controller/base.rb
def controller_path
  @controller_path ||= name.delete_suffix("Controller").underscore
end
```

Por exemplo, esse valor é o que você obtém em `params[:controller]`.

INFO: Como regra geral, você pode pensar em `underscore` como o inverso de `camelize`, embora haja casos em que isso não se aplica. Por exemplo, `"SSLError".underscore.camelize` retorna `"SslError"`.

NOTA: Definido em `active_support/core_ext/string/inflections.rb`.


#### `titleize`

O método [`titleize`][String#titleize] capitaliza as palavras na string:

```ruby
"alice in wonderland".titleize # => "Alice In Wonderland"
"fermat's enigma".titleize     # => "Fermat's Enigma"
```

`titleize` é um alias para [`titlecase`][String#titlecase].

NOTA: Definido em `active_support/core_ext/string/inflections.rb`.


#### `dasherize`

O método [`dasherize`][String#dasherize] substitui os underscores na string por hífens:

```ruby
"name".dasherize         # => "name"
"contact_data".dasherize # => "contact-data"
```

O serializador XML de modelos usa esse método para transformar os nomes dos nós em formato de hífens:

```ruby
# active_model/serializers/xml.rb
def reformat_name(name)
  name = name.camelize if camelize?
  dasherize? ? name.dasherize : name
end
```

NOTA: Definido em `active_support/core_ext/string/inflections.rb`.


#### `demodulize`

Dada uma string com um nome de constante qualificado, [`demodulize`][String#demodulize] retorna o próprio nome da constante, ou seja, a parte mais à direita:

```ruby
"Product".demodulize                        # => "Product"
"Backoffice::UsersController".demodulize    # => "UsersController"
"Admin::Hotel::ReservationUtils".demodulize # => "ReservationUtils"
"::Inflections".demodulize                  # => "Inflections"
"".demodulize                               # => ""
```

O Active Record, por exemplo, usa esse método para calcular o nome de uma coluna de cache de contagem:

```ruby
# active_record/reflection.rb
def counter_cache_column
  if options[:counter_cache] == true
    "#{active_record.name.demodulize.underscore.pluralize}_count"
  elsif options[:counter_cache]
    options[:counter_cache]
  end
end
```

NOTA: Definido em `active_support/core_ext/string/inflections.rb`.


#### `deconstantize`

Dada uma string com uma expressão de referência a uma constante qualificada, [`deconstantize`][String#deconstantize] remove o segmento mais à direita, geralmente deixando o nome do contêiner da constante:

```ruby
"Product".deconstantize                        # => ""
"Backoffice::UsersController".deconstantize    # => "Backoffice"
"Admin::Hotel::ReservationUtils".deconstantize # => "Admin::Hotel"
```

NOTA: Definido em `active_support/core_ext/string/inflections.rb`.


#### `parameterize`

O método [`parameterize`][String#parameterize] normaliza a string de forma que possa ser usada em URLs amigáveis.

```ruby
"John Smith".parameterize # => "john-smith"
"Kurt Gödel".parameterize # => "kurt-godel"
```

Para preservar a caixa da string, defina o argumento `preserve_case` como true. Por padrão, `preserve_case` é definido como false.

```ruby
"John Smith".parameterize(preserve_case: true) # => "John-Smith"
"Kurt Gödel".parameterize(preserve_case: true) # => "Kurt-Godel"
```

Para usar um separador personalizado, substitua o argumento `separator`.

```ruby
"John Smith".parameterize(separator: "_") # => "john_smith"
"Kurt Gödel".parameterize(separator: "_") # => "kurt_godel"
```

NOTA: Definido em `active_support/core_ext/string/inflections.rb`.


#### `tableize`

O método [`tableize`][String#tableize] é `underscore` seguido de `pluralize`.

```ruby
"Person".tableize      # => "people"
"Invoice".tableize     # => "invoices"
"InvoiceLine".tableize # => "invoice_lines"
```

Como regra geral, `tableize` retorna o nome da tabela que corresponde a um determinado modelo para casos simples. A implementação real no Active Record não é apenas `tableize`, pois também desmodulariza o nome da classe e verifica algumas opções que podem afetar a string retornada.

NOTA: Definido em `active_support/core_ext/string/inflections.rb`.


#### `classify`

O método [`classify`][String#classify] é o inverso de `tableize`. Ele retorna o nome da classe correspondente a um nome de tabela:

```ruby
"people".classify        # => "Person"
"invoices".classify      # => "Invoice"
"invoice_lines".classify # => "InvoiceLine"
```

O método entende nomes de tabela qualificados:

```ruby
"highrise_production.companies".classify # => "Company"
```

Observe que `classify` retorna o nome da classe como uma string. Você pode obter o objeto de classe real invocando `constantize` nele, explicado a seguir.

NOTA: Definido em `active_support/core_ext/string/inflections.rb`.


#### `constantize`

O método [`constantize`][String#constantize] resolve a expressão de referência constante em seu receptor:

```ruby
"Integer".constantize # => Integer

module M
  X = 1
end
"M::X".constantize # => 1
```

Se a string não se refere a uma constante conhecida, ou seu conteúdo não é um nome de constante válido, `constantize` gera uma exceção `NameError`.

A resolução de nome de constante por `constantize` sempre começa no nível superior do `Object`, mesmo se não houver "::" no início.

```ruby
X = :in_Object
module M
  X = :in_M

  X                 # => :in_M
  "::X".constantize # => :in_Object
  "X".constantize   # => :in_Object (!)
end
```

Portanto, em geral, não é equivalente ao que o Ruby faria no mesmo local se uma constante real fosse avaliada.

Os casos de teste do Mailer obtêm o mailer sendo testado a partir do nome da classe de teste usando `constantize`:

```ruby
# action_mailer/test_case.rb
def determine_default_mailer(name)
  name.delete_suffix("Test").constantize
rescue NameError => e
  raise NonInferrableMailerError.new(name)
end
```

NOTA: Definido em `active_support/core_ext/string/inflections.rb`.


#### `humanize`

O método [`humanize`][String#humanize] ajusta um nome de atributo para exibição aos usuários finais.

Especificamente, ele realiza as seguintes transformações:

  * Aplica regras de inflexão humana ao argumento.
  * Remove sublinhados iniciais, se houver.
  * Remove o sufixo "_id", se presente.
  * Substitui sublinhados por espaços, se houver.
  * Coloca todas as palavras em minúsculas, exceto acrônimos.
  * Capitaliza a primeira palavra.

A capitalização da primeira palavra pode ser desativada definindo a opção `:capitalize` como false (o padrão é true).

```ruby
"name".humanize                         # => "Name"
"author_id".humanize                    # => "Author"
"author_id".humanize(capitalize: false) # => "author"
"comments_count".humanize               # => "Comments count"
"_id".humanize                          # => "Id"
```

Se "SSL" for definido como um acrônimo:

```ruby
'ssl_error'.humanize # => "SSL error"
```

O método auxiliar `full_messages` usa `humanize` como fallback para incluir nomes de atributos:

```ruby
def full_messages
  map { |attribute, message| full_message(attribute, message) }
end

def full_message
  # ...
  attr_name = attribute.to_s.tr('.', '_').humanize
  attr_name = @base.class.human_attribute_name(attribute, default: attr_name)
  # ...
end
```

NOTA: Definido em `active_support/core_ext/string/inflections.rb`.


#### `foreign_key`

O método [`foreign_key`][String#foreign_key] retorna o nome da coluna de chave estrangeira a partir de um nome de classe. Para fazer isso, ele desmodulariza, adiciona sublinhados e adiciona "_id":

```ruby
"User".foreign_key           # => "user_id"
"InvoiceLine".foreign_key    # => "invoice_line_id"
"Admin::Session".foreign_key # => "session_id"
```
Passe um argumento falso se você não quiser o sublinhado em "_id":

```ruby
"User".foreign_key(false) # => "userid"
```

As associações usam esse método para inferir chaves estrangeiras, por exemplo, `has_one` e `has_many` fazem isso:

```ruby
# active_record/associations.rb
foreign_key = options[:foreign_key] || reflection.active_record.name.foreign_key
```

NOTA: Definido em `active_support/core_ext/string/inflections.rb`.


#### `upcase_first`

O método [`upcase_first`][String#upcase_first] capitaliza a primeira letra do receptor:

```ruby
"employee salary".upcase_first # => "Employee salary"
"".upcase_first                # => ""
```

NOTA: Definido em `active_support/core_ext/string/inflections.rb`.


#### `downcase_first`

O método [`downcase_first`][String#downcase_first] converte a primeira letra do receptor para minúscula:

```ruby
"If I had read Alice in Wonderland".downcase_first # => "if I had read Alice in Wonderland"
"".downcase_first                                  # => ""
```

NOTA: Definido em `active_support/core_ext/string/inflections.rb`.


### Conversões

#### `to_date`, `to_time`, `to_datetime`

Os métodos [`to_date`][String#to_date], [`to_time`][String#to_time] e [`to_datetime`][String#to_datetime] são basicamente invólucros de conveniência em torno de `Date._parse`:

```ruby
"2010-07-27".to_date              # => Tue, 27 Jul 2010
"2010-07-27 23:37:00".to_time     # => 2010-07-27 23:37:00 +0200
"2010-07-27 23:37:00".to_datetime # => Tue, 27 Jul 2010 23:37:00 +0000
```

`to_time` recebe um argumento opcional `:utc` ou `:local`, para indicar em qual fuso horário você deseja o horário:

```ruby
"2010-07-27 23:42:00".to_time(:utc)   # => 2010-07-27 23:42:00 UTC
"2010-07-27 23:42:00".to_time(:local) # => 2010-07-27 23:42:00 +0200
```

O padrão é `:local`.

Consulte a documentação de `Date._parse` para mais detalhes.

INFO: Os três retornam `nil` para receptores em branco.

NOTA: Definido em `active_support/core_ext/string/conversions.rb`.


Extensões para `Symbol`
----------------------

### `starts_with?` e `ends_with?`

O Active Support define aliases de terceira pessoa para `Symbol#start_with?` e `Symbol#end_with?`:

```ruby
:foo.starts_with?("f") # => true
:foo.ends_with?("o")   # => true
```

NOTA: Definido em `active_support/core_ext/symbol/starts_ends_with.rb`.

Extensões para `Numeric`
-----------------------

### Bytes

Todos os números respondem a esses métodos:

* [`bytes`][Numeric#bytes]
* [`kilobytes`][Numeric#kilobytes]
* [`megabytes`][Numeric#megabytes]
* [`gigabytes`][Numeric#gigabytes]
* [`terabytes`][Numeric#terabytes]
* [`petabytes`][Numeric#petabytes]
* [`exabytes`][Numeric#exabytes]

Eles retornam a quantidade correspondente de bytes, usando um fator de conversão de 1024:

```ruby
2.kilobytes   # => 2048
3.megabytes   # => 3145728
3.5.gigabytes # => 3758096384.0
-4.exabytes   # => -4611686018427387904
```

As formas singulares são aliadas para que você possa dizer:

```ruby
1.megabyte # => 1048576
```

NOTA: Definido em `active_support/core_ext/numeric/bytes.rb`.


### Time

Os seguintes métodos:

* [`seconds`][Numeric#seconds]
* [`minutes`][Numeric#minutes]
* [`hours`][Numeric#hours]
* [`days`][Numeric#days]
* [`weeks`][Numeric#weeks]
* [`fortnights`][Numeric#fortnights]

permitem declarações e cálculos de tempo, como `45.minutes + 2.hours + 4.weeks`. Seus valores de retorno também podem ser adicionados ou subtraídos de objetos Time.

Esses métodos podem ser combinados com [`from_now`][Duration#from_now], [`ago`][Duration#ago], etc, para cálculos precisos de datas. Por exemplo:

```ruby
# equivalente a Time.current.advance(days: 1)
1.day.from_now

# equivalente a Time.current.advance(weeks: 2)
2.weeks.from_now

# equivalente a Time.current.advance(days: 4, weeks: 5)
(4.days + 5.weeks).from_now
```

ATENÇÃO. Para outras durações, consulte as extensões de tempo para `Integer`.

NOTA: Definido em `active_support/core_ext/numeric/time.rb`.


### Formatação

Permite a formatação de números de várias maneiras.

Produza uma representação em string de um número como um número de telefone:

```ruby
5551234.to_fs(:phone)
# => 555-1234
1235551234.to_fs(:phone)
# => 123-555-1234
1235551234.to_fs(:phone, area_code: true)
# => (123) 555-1234
1235551234.to_fs(:phone, delimiter: " ")
# => 123 555 1234
1235551234.to_fs(:phone, area_code: true, extension: 555)
# => (123) 555-1234 x 555
1235551234.to_fs(:phone, country_code: 1)
# => +1-123-555-1234
```

Produza uma representação em string de um número como moeda:

```ruby
1234567890.50.to_fs(:currency)                 # => $1,234,567,890.50
1234567890.506.to_fs(:currency)                # => $1,234,567,890.51
1234567890.506.to_fs(:currency, precision: 3)  # => $1,234,567,890.506
```
Produza uma representação em string de um número como uma porcentagem:

```ruby
100.to_fs(:porcentagem)
# => 100.000%
100.to_fs(:porcentagem, precisão: 0)
# => 100%
1000.to_fs(:porcentagem, delimitador: '.', separador: ',')
# => 1.000,000%
302.24398923423.to_fs(:porcentagem, precisão: 5)
# => 302.24399%
```

Produza uma representação em string de um número em forma delimitada:

```ruby
12345678.to_fs(:delimitado)                     # => 12,345,678
12345678.05.to_fs(:delimitado)                  # => 12,345,678.05
12345678.to_fs(:delimitado, delimitador: ".")     # => 12.345.678
12345678.to_fs(:delimitado, delimitador: ",")     # => 12,345,678
12345678.05.to_fs(:delimitado, separador: " ")  # => 12,345,678 05
```

Produza uma representação em string de um número arredondado para uma precisão:

```ruby
111.2345.to_fs(:arredondado)                     # => 111.235
111.2345.to_fs(:arredondado, precisão: 2)       # => 111.23
13.to_fs(:arredondado, precisão: 5)             # => 13.00000
389.32314.to_fs(:arredondado, precisão: 0)      # => 389
111.2345.to_fs(:arredondado, significativo: true)  # => 111
```

Produza uma representação em string de um número como um número de bytes legível pelo ser humano:

```ruby
123.to_fs(:tamanho_humano)                  # => 123 Bytes
1234.to_fs(:tamanho_humano)                 # => 1.21 KB
12345.to_fs(:tamanho_humano)                # => 12.1 KB
1234567.to_fs(:tamanho_humano)              # => 1.18 MB
1234567890.to_fs(:tamanho_humano)           # => 1.15 GB
1234567890123.to_fs(:tamanho_humano)        # => 1.12 TB
1234567890123456.to_fs(:tamanho_humano)     # => 1.1 PB
1234567890123456789.to_fs(:tamanho_humano)  # => 1.07 EB
```

Produza uma representação em string de um número em palavras legíveis pelo ser humano:

```ruby
123.to_fs(:humano)               # => "123"
1234.to_fs(:humano)              # => "1.23 Mil"
12345.to_fs(:humano)             # => "12.3 Mil"
1234567.to_fs(:humano)           # => "1.23 Milhão"
1234567890.to_fs(:humano)        # => "1.23 Bilhão"
1234567890123.to_fs(:humano)     # => "1.23 Trilhão"
1234567890123456.to_fs(:humano)  # => "1.23 Quadrilhão"
```

NOTA: Definido em `active_support/core_ext/numeric/conversions.rb`.

Extensões para `Integer`
-----------------------

### `múltiplo_de?`

O método [`múltiplo_de?`][Integer#múltiplo_de?] testa se um número inteiro é múltiplo do argumento:

```ruby
2.múltiplo_de?(1) # => true
1.múltiplo_de?(2) # => false
```

NOTA: Definido em `active_support/core_ext/integer/multiple.rb`.


### `ordinal`

O método [`ordinal`][Integer#ordinal] retorna a string de sufixo ordinal correspondente ao número inteiro:

```ruby
1.ordinal    # => "º"
2.ordinal    # => "º"
53.ordinal   # => "º"
2009.ordinal # => "º"
-21.ordinal  # => "º"
-134.ordinal # => "º"
```

NOTA: Definido em `active_support/core_ext/integer/inflections.rb`.


### `ordinalize`

O método [`ordinalize`][Integer#ordinalize] retorna a string ordinal correspondente ao número inteiro. Em comparação, observe que o método `ordinal` retorna **apenas** a string de sufixo.

```ruby
1.ordinalize    # => "1º"
2.ordinalize    # => "2º"
53.ordinalize   # => "53º"
2009.ordinalize # => "2009º"
-21.ordinalize  # => "-21º"
-134.ordinalize # => "-134º"
```

NOTA: Definido em `active_support/core_ext/integer/inflections.rb`.


### Tempo

Os seguintes métodos:

* [`meses`][Integer#meses]
* [`anos`][Integer#anos]

permitem declarações e cálculos de tempo, como `4.meses + 5.anos`. Seus valores de retorno também podem ser adicionados ou subtraídos de objetos Time.

Esses métodos podem ser combinados com [`from_now`][Duration#from_now], [`ago`][Duration#ago], etc, para cálculos precisos de datas. Por exemplo:

```ruby
# equivalente a Time.current.advance(months: 1)
1.mês.from_now

# equivalente a Time.current.advance(years: 2)
2.anos.from_now

# equivalente a Time.current.advance(months: 4, years: 5)
(4.meses + 5.anos).from_now
```

ATENÇÃO. Para outras durações, consulte as extensões de tempo para `Numeric`.

NOTA: Definido em `active_support/core_ext/integer/time.rb`.


Extensões para `BigDecimal`
--------------------------

### `to_s`

O método `to_s` fornece um especificador padrão de "F". Isso significa que uma chamada simples para `to_s` resultará em uma representação de ponto flutuante em vez de notação científica:

```ruby
BigDecimal(5.00, 6).to_s       # => "5.0"
```

A notação científica ainda é suportada:

```ruby
BigDecimal(5.00, 6).to_s("e")  # => "0.5E1"
```

Extensões para `Enumerable`
--------------------------

### `sum`

O método [`sum`][Enumerable#sum] adiciona os elementos de um enumerável:
```ruby
[1, 2, 3].sum # => 6
(1..100).sum  # => 5050
```

A adição assume apenas que os elementos respondem a `+`:

```ruby
[[1, 2], [2, 3], [3, 4]].sum    # => [1, 2, 2, 3, 3, 4]
%w(foo bar baz).sum             # => "foobarbaz"
{ a: 1, b: 2, c: 3 }.sum          # => [:a, 1, :b, 2, :c, 3]
```

A soma de uma coleção vazia é zero por padrão, mas isso pode ser personalizado:

```ruby
[].sum    # => 0
[].sum(1) # => 1
```

Se um bloco for fornecido, `sum` se torna um iterador que retorna os elementos da coleção e soma os valores retornados:

```ruby
(1..5).sum { |n| n * 2 } # => 30
[2, 4, 6, 8, 10].sum    # => 30
```

A soma de um receptor vazio também pode ser personalizada nessa forma:

```ruby
[].sum(1) { |n| n**3 } # => 1
```

NOTA: Definido em `active_support/core_ext/enumerable.rb`.


### `index_by`

O método [`index_by`][Enumerable#index_by] gera um hash com os elementos de um iterável indexados por alguma chave.

Ele itera pela coleção e passa cada elemento para um bloco. O elemento será indexado pelo valor retornado pelo bloco:

```ruby
invoices.index_by(&:number)
# => {'2009-032' => <Invoice ...>, '2009-008' => <Invoice ...>, ...}
```

ATENÇÃO. As chaves normalmente devem ser únicas. Se o bloco retornar o mesmo valor para diferentes elementos, nenhuma coleção será construída para essa chave. O último item vencerá.

NOTA: Definido em `active_support/core_ext/enumerable.rb`.


### `index_with`

O método [`index_with`][Enumerable#index_with] gera um hash com os elementos de um iterável como chaves. O valor
é ou um valor padrão passado ou retornado em um bloco.

```ruby
post = Post.new(title: "hey there", body: "what's up?")

%i( title body ).index_with { |attr_name| post.public_send(attr_name) }
# => { title: "hey there", body: "what's up?" }

WEEKDAYS.index_with(Interval.all_day)
# => { monday: [ 0, 1440 ], … }
```

NOTA: Definido em `active_support/core_ext/enumerable.rb`.


### `many?`

O método [`many?`][Enumerable#many?] é uma forma abreviada de `collection.size > 1`:

```erb
<% if pages.many? %>
  <%= pagination_links %>
<% end %>
```

Se um bloco opcional for fornecido, `many?` leva em consideração apenas os elementos que retornam true:

```ruby
@see_more = videos.many? { |video| video.category == params[:category] }
```

NOTA: Definido em `active_support/core_ext/enumerable.rb`.


### `exclude?`

O predicado [`exclude?`][Enumerable#exclude?] testa se um determinado objeto **não** pertence à coleção. É a negação do `include?` embutido:

```ruby
to_visit << node if visited.exclude?(node)
```

NOTA: Definido em `active_support/core_ext/enumerable.rb`.


### `including`

O método [`including`][Enumerable#including] retorna um novo iterável que inclui os elementos passados:

```ruby
[ 1, 2, 3 ].including(4, 5)                    # => [ 1, 2, 3, 4, 5 ]
["David", "Rafael"].including %w[ Aaron Todd ] # => ["David", "Rafael", "Aaron", "Todd"]
```

NOTA: Definido em `active_support/core_ext/enumerable.rb`.


### `excluding`

O método [`excluding`][Enumerable#excluding] retorna uma cópia de um iterável com os elementos especificados
removidos:

```ruby
["David", "Rafael", "Aaron", "Todd"].excluding("Aaron", "Todd") # => ["David", "Rafael"]
```

`excluding` é um alias para [`without`][Enumerable#without].

NOTA: Definido em `active_support/core_ext/enumerable.rb`.


### `pluck`

O método [`pluck`][Enumerable#pluck] extrai a chave fornecida de cada elemento:

```ruby
[{ name: "David" }, { name: "Rafael" }, { name: "Aaron" }].pluck(:name) # => ["David", "Rafael", "Aaron"]
[{ id: 1, name: "David" }, { id: 2, name: "Rafael" }].pluck(:id, :name) # => [[1, "David"], [2, "Rafael"]]
```

NOTA: Definido em `active_support/core_ext/enumerable.rb`.


### `pick`

O método [`pick`][Enumerable#pick] extrai a chave fornecida do primeiro elemento:

```ruby
[{ name: "David" }, { name: "Rafael" }, { name: "Aaron" }].pick(:name) # => "David"
[{ id: 1, name: "David" }, { id: 2, name: "Rafael" }].pick(:id, :name) # => [1, "David"]
```

NOTA: Definido em `active_support/core_ext/enumerable.rb`.


Extensões para `Array`
---------------------

### Acesso

O Active Support aprimora a API de arrays para facilitar certas formas de acesso. Por exemplo, [`to`][Array#to] retorna o subarray de elementos até o índice passado:

```ruby
%w(a b c d).to(2) # => ["a", "b", "c"]
[].to(7)          # => []
```

Da mesma forma, [`from`][Array#from] retorna a cauda a partir do elemento no índice passado até o final. Se o índice for maior que o comprimento do array, ele retorna um array vazio.

```ruby
%w(a b c d).from(2)  # => ["c", "d"]
%w(a b c d).from(10) # => []
[].from(0)           # => []
```

O método [`including`][Array#including] retorna um novo array que inclui os elementos passados:

```ruby
[ 1, 2, 3 ].including(4, 5)          # => [ 1, 2, 3, 4, 5 ]
[ [ 0, 1 ] ].including([ [ 1, 0 ] ]) # => [ [ 0, 1 ], [ 1, 0 ] ]
```

O método [`excluding`][Array#excluding] retorna uma cópia do Array excluindo os elementos especificados.
Esta é uma otimização de `Enumerable#excluding` que usa `Array#-`
em vez de `Array#reject` por motivos de desempenho.

```ruby
["David", "Rafael", "Aaron", "Todd"].excluding("Aaron", "Todd") # => ["David", "Rafael"]
[ [ 0, 1 ], [ 1, 0 ] ].excluding([ [ 1, 0 ] ])                  # => [ [ 0, 1 ] ]
```

Os métodos [`second`][Array#second], [`third`][Array#third], [`fourth`][Array#fourth] e [`fifth`][Array#fifth] retornam o elemento correspondente, assim como [`second_to_last`][Array#second_to_last] e [`third_to_last`][Array#third_to_last] (`first` e `last` são integrados). Graças à sabedoria social e à construtividade positiva em todos os lugares, [`forty_two`][Array#forty_two] também está disponível.

```ruby
%w(a b c d).third # => "c"
%w(a b c d).fifth # => nil
```

NOTA: Definido em `active_support/core_ext/array/access.rb`.


### Extração

O método [`extract!`][Array#extract!] remove e retorna os elementos para os quais o bloco retorna um valor verdadeiro.
Se nenhum bloco for fornecido, um Enumerator é retornado.

```ruby
numbers = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
odd_numbers = numbers.extract! { |number| number.odd? } # => [1, 3, 5, 7, 9]
numbers # => [0, 2, 4, 6, 8]
```

NOTA: Definido em `active_support/core_ext/array/extract.rb`.


### Extração de Opções

Quando o último argumento em uma chamada de método é um hash, exceto talvez por um argumento `&block`, o Ruby permite omitir os colchetes:

```ruby
User.exists?(email: params[:email])
```

Açúcar sintático é usado muito no Rails para evitar argumentos posicionais onde haveria muitos, oferecendo em vez disso interfaces que emulam parâmetros nomeados. Em particular, é muito idiomático usar um hash final para opções.

Se um método espera um número variável de argumentos e usa `*` em sua declaração, no entanto, esse hash de opções acaba sendo um item do array de argumentos, onde ele perde seu papel.

Nesses casos, você pode dar a um hash de opções um tratamento distinto com [`extract_options!`][Array#extract_options!]. Este método verifica o tipo do último item de um array. Se for um hash, ele o remove e o retorna, caso contrário, retorna um hash vazio.
Vamos ver, por exemplo, a definição da macro do controlador `caches_action`:

```ruby
def caches_action(*actions)
  return unless cache_configured?
  options = actions.extract_options!
  # ...
end
```

Este método recebe um número arbitrário de nomes de ação e um hash opcional de opções como último argumento. Com a chamada para `extract_options!`, você obtém o hash de opções e o remove de `actions` de uma maneira simples e explícita.

NOTA: Definido em `active_support/core_ext/array/extract_options.rb`.


### Conversões

#### `to_sentence`

O método [`to_sentence`][Array#to_sentence] transforma um array em uma string que contém uma frase enumerando seus itens:

```ruby
%w().to_sentence                # => ""
%w(Terra).to_sentence           # => "Terra"
%w(Terra Vento).to_sentence      # => "Terra e Vento"
%w(Terra Vento Fogo).to_sentence # => "Terra, Vento e Fogo"
```

Este método aceita três opções:

* `:two_words_connector`: O que é usado para arrays de tamanho 2. O padrão é " e ".
* `:words_connector`: O que é usado para unir os elementos de arrays com 3 ou mais elementos, exceto os dois últimos. O padrão é ", ".
* `:last_word_connector`: O que é usado para unir os últimos itens de um array com 3 ou mais elementos. O padrão é ", e ".

Os valores padrão para essas opções podem ser localizados, suas chaves são:

| Opção                 | Chave I18n                            |
| ---------------------- | ----------------------------------- |
| `:two_words_connector` | `support.array.two_words_connector` |
| `:words_connector`     | `support.array.words_connector`     |
| `:last_word_connector` | `support.array.last_word_connector` |

NOTA: Definido em `active_support/core_ext/array/conversions.rb`.


#### `to_fs`

O método [`to_fs`][Array#to_fs] age como `to_s` por padrão.

No entanto, se o array contiver itens que respondem a `id`, o símbolo `:db` pode ser passado como argumento. Isso é tipicamente usado com coleções de objetos Active Record. As strings retornadas são:

```ruby
[].to_fs(:db)            # => "null"
[user].to_fs(:db)        # => "8456"
invoice.lines.to_fs(:db) # => "23,567,556,12"
```

Os inteiros no exemplo acima são supostos vir das respectivas chamadas para `id`.

NOTA: Definido em `active_support/core_ext/array/conversions.rb`.


#### `to_xml`

O método [`to_xml`][Array#to_xml] retorna uma string contendo uma representação XML de seu receptor:

```ruby
Contributor.limit(2).order(:rank).to_xml
# =>
# <?xml version="1.0" encoding="UTF-8"?>
# <contributors type="array">
#   <contributor>
#     <id type="integer">4356</id>
#     <name>Jeremy Kemper</name>
#     <rank type="integer">1</rank>
#     <url-id>jeremy-kemper</url-id>
#   </contributor>
#   <contributor>
#     <id type="integer">4404</id>
#     <name>David Heinemeier Hansson</name>
#     <rank type="integer">2</rank>
#     <url-id>david-heinemeier-hansson</url-id>
#   </contributor>
# </contributors>
```

Para fazer isso, ele envia `to_xml` para cada item, coletando os resultados em um nó raiz. Todos os itens devem responder a `to_xml`, caso contrário, uma exceção é lançada.

Por padrão, o nome do elemento raiz é o plural do nome da classe do primeiro item, com underscores e traços, desde que o restante dos elementos pertença a esse tipo (verificado com `is_a?`) e eles não sejam hashes. No exemplo acima, isso é "contributors".

Se houver algum elemento que não pertença ao tipo do primeiro, o nó raiz se torna "objects":

```ruby
[Contributor.first, Commit.first].to_xml
# =>
# <?xml version="1.0" encoding="UTF-8"?>
# <objects type="array">
#   <object>
#     <id type="integer">4583</id>
#     <name>Aaron Batalion</name>
#     <rank type="integer">53</rank>
#     <url-id>aaron-batalion</url-id>
#   </object>
#   <object>
#     <author>Joshua Peek</author>
#     <authored-timestamp type="datetime">2009-09-02T16:44:36Z</authored-timestamp>
#     <branch>origin/master</branch>
#     <committed-timestamp type="datetime">2009-09-02T16:44:36Z</committed-timestamp>
#     <committer>Joshua Peek</committer>
#     <git-show nil="true"></git-show>
#     <id type="integer">190316</id>
#     <imported-from-svn type="boolean">false</imported-from-svn>
#     <message>Kill AMo observing wrap_with_notifications since ARes was only using it</message>
#     <sha1>723a47bfb3708f968821bc969a9a3fc873a3ed58</sha1>
#   </object>
# </objects>
```

Se o receptor for uma matriz de hashes, o elemento raiz é, por padrão, também "objects":

```ruby
[{ a: 1, b: 2 }, { c: 3 }].to_xml
# =>
# <?xml version="1.0" encoding="UTF-8"?>
# <objects type="array">
#   <object>
#     <b type="integer">2</b>
#     <a type="integer">1</a>
#   </object>
#   <object>
#     <c type="integer">3</c>
#   </object>
# </objects>
```

ATENÇÃO. Se a coleção estiver vazia, o elemento raiz será, por padrão, "nil-classes". Isso é uma pegadinha, por exemplo, o elemento raiz da lista de contribuidores acima não seria "contribuidores" se a coleção estivesse vazia, mas sim "nil-classes". Você pode usar a opção `:root` para garantir um elemento raiz consistente.

O nome dos nós filhos é, por padrão, o nome do nó raiz singularizado. Nos exemplos acima, vimos "contribuidor" e "objeto". A opção `:children` permite definir esses nomes de nó.

O construtor XML padrão é uma nova instância de `Builder::XmlMarkup`. Você pode configurar seu próprio construtor por meio da opção `:builder`. O método também aceita opções como `:dasherize` e outros, que são repassados ao construtor:

```ruby
Contributor.limit(2).order(:rank).to_xml(skip_types: true)
# =>
# <?xml version="1.0" encoding="UTF-8"?>
# <contribuidores>
#   <contribuidor>
#     <id>4356</id>
#     <nome>Jeremy Kemper</nome>
#     <classificação>1</classificação>
#     <id-url>jeremy-kemper</id-url>
#   </contribuidor>
#   <contribuidor>
#     <id>4404</id>
#     <nome>David Heinemeier Hansson</nome>
#     <classificação>2</classificação>
#     <id-url>david-heinemeier-hansson</id-url>
#   </contribuidor>
# </contribuidores>
```

NOTA: Definido em `active_support/core_ext/array/conversions.rb`.


### Encapsulamento

O método [`Array.wrap`][Array.wrap] encapsula seu argumento em uma matriz, a menos que ele já seja uma matriz (ou semelhante a uma matriz).

Especificamente:

* Se o argumento for `nil`, uma matriz vazia é retornada.
* Caso contrário, se o argumento responder a `to_ary`, ele é invocado e, se o valor de `to_ary` não for `nil`, ele é retornado.
* Caso contrário, uma matriz com o argumento como seu único elemento é retornada.

```ruby
Array.wrap(nil)       # => []
Array.wrap([1, 2, 3]) # => [1, 2, 3]
Array.wrap(0)         # => [0]
```

Este método é semelhante em propósito ao `Kernel#Array`, mas existem algumas diferenças:

* Se o argumento responder a `to_ary`, o método é invocado. `Kernel#Array` continua tentando `to_a` se o valor retornado for `nil`, mas `Array.wrap` retorna imediatamente uma matriz com o argumento como seu único elemento.
* Se o valor retornado de `to_ary` não for nem `nil` nem um objeto `Array`, `Kernel#Array` gera uma exceção, enquanto `Array.wrap` não, ele apenas retorna o valor.
* Ele não chama `to_a` no argumento, se o argumento não responder a `to_ary`, ele retorna uma matriz com o argumento como seu único elemento.

O último ponto é particularmente digno de comparação para algumas enumeráveis:

```ruby
Array.wrap(foo: :bar) # => [{:foo=>:bar}]
Array(foo: :bar)      # => [[:foo, :bar]]
```

Também existe um idioma relacionado que usa o operador splat:

```ruby
[*object]
```

NOTA: Definido em `active_support/core_ext/array/wrap.rb`.


### Duplicação

O método [`Array#deep_dup`][Array#deep_dup] duplica a si mesmo e todos os objetos internos de forma recursiva com o método `Object#deep_dup` do Active Support. Ele funciona como `Array#map`, enviando o método `deep_dup` para cada objeto interno.

```ruby
array = [1, [2, 3]]
dup = array.deep_dup
dup[1][2] = 4
array[1][2] == nil   # => true
```

NOTA: Definido em `active_support/core_ext/object/deep_dup.rb`.
### Agrupamento

#### `in_groups_of(número, preencher_com = nil)`

O método [`in_groups_of`][Array#in_groups_of] divide um array em grupos consecutivos de um determinado tamanho. Ele retorna um array com os grupos:

```ruby
[1, 2, 3].in_groups_of(2) # => [[1, 2], [3, nil]]
```

ou os retorna em sequência se um bloco for passado:

```html+erb
<% sample.in_groups_of(3) do |a, b, c| %>
  <tr>
    <td><%= a %></td>
    <td><%= b %></td>
    <td><%= c %></td>
  </tr>
<% end %>
```

O primeiro exemplo mostra como `in_groups_of` preenche o último grupo com quantos elementos `nil` forem necessários para ter o tamanho solicitado. Você pode alterar esse valor de preenchimento usando o segundo argumento opcional:

```ruby
[1, 2, 3].in_groups_of(2, 0) # => [[1, 2], [3, 0]]
```

E você pode dizer ao método para não preencher o último grupo passando `false`:

```ruby
[1, 2, 3].in_groups_of(2, false) # => [[1, 2], [3]]
```

Como consequência, `false` não pode ser usado como valor de preenchimento.

NOTA: Definido em `active_support/core_ext/array/grouping.rb`.


#### `in_groups(número, preencher_com = nil)`

O método [`in_groups`][Array#in_groups] divide um array em um certo número de grupos. O método retorna um array com os grupos:

```ruby
%w(1 2 3 4 5 6 7).in_groups(3)
# => [["1", "2", "3"], ["4", "5", nil], ["6", "7", nil]]
```

ou os retorna em sequência se um bloco for passado:

```ruby
%w(1 2 3 4 5 6 7).in_groups(3) { |group| p group }
["1", "2", "3"]
["4", "5", nil]
["6", "7", nil]
```

Os exemplos acima mostram que `in_groups` preenche alguns grupos com um elemento `nil` adicional, se necessário. Um grupo pode ter no máximo um desses elementos extras, o mais à direita, se houver. E os grupos que os têm são sempre os últimos.

Você pode alterar esse valor de preenchimento usando o segundo argumento opcional:

```ruby
%w(1 2 3 4 5 6 7).in_groups(3, "0")
# => [["1", "2", "3"], ["4", "5", "0"], ["6", "7", "0"]]
```

E você pode dizer ao método para não preencher os grupos menores passando `false`:

```ruby
%w(1 2 3 4 5 6 7).in_groups(3, false)
# => [["1", "2", "3"], ["4", "5"], ["6", "7"]]
```

Como consequência, `false` não pode ser usado como valor de preenchimento.

NOTA: Definido em `active_support/core_ext/array/grouping.rb`.


#### `split(valor = nil)`

O método [`split`][Array#split] divide um array por um separador e retorna os pedaços resultantes.

Se um bloco for passado, os separadores são aqueles elementos do array para os quais o bloco retorna verdadeiro:

```ruby
(-5..5).to_a.split { |i| i.multiple_of?(4) }
# => [[-5], [-3, -2, -1], [1, 2, 3], [5]]
```

Caso contrário, o valor recebido como argumento, que é opcional e tem o valor padrão `nil`, é o separador:

```ruby
[0, 1, -5, 1, 1, "foo", "bar"].split(1)
# => [[0], [-5], [], ["foo", "bar"]]
```

DICA: Observe no exemplo anterior que separadores consecutivos resultam em arrays vazios.

NOTA: Definido em `active_support/core_ext/array/grouping.rb`.


Extensões para `Hash`
--------------------

### Conversões

#### `to_xml`

O método [`to_xml`][Hash#to_xml] retorna uma string contendo uma representação XML de seu receptor:

```ruby
{ foo: 1, bar: 2 }.to_xml
# =>
# <?xml version="1.0" encoding="UTF-8"?>
# <hash>
#   <foo type="integer">1</foo>
#   <bar type="integer">2</bar>
# </hash>
```
Para fazer isso, o método percorre os pares e constrói nós que dependem dos _valores_. Dado um par `chave`, `valor`:

* Se `valor` for um hash, há uma chamada recursiva com `chave` como `:root`.

* Se `valor` for um array, há uma chamada recursiva com `chave` como `:root` e `chave` singularizada como `:children`.

* Se `valor` for um objeto chamável, ele deve esperar um ou dois argumentos. Dependendo da aridade, o objeto chamável é invocado com o hash `options` como primeiro argumento com `chave` como `:root` e `chave` singularizada como segundo argumento. O valor de retorno se torna um novo nó.

* Se `valor` responder a `to_xml`, o método é invocado com `chave` como `:root`.

* Caso contrário, um nó com `chave` como tag é criado com uma representação em string de `valor` como nó de texto. Se `valor` for `nil`, um atributo "nil" definido como "true" é adicionado. A menos que a opção `:skip_types` exista e seja verdadeira, um atributo "type" também é adicionado de acordo com o seguinte mapeamento:

```ruby
XML_TYPE_NAMES = {
  "Symbol"     => "symbol",
  "Integer"    => "integer",
  "BigDecimal" => "decimal",
  "Float"      => "float",
  "TrueClass"  => "boolean",
  "FalseClass" => "boolean",
  "Date"       => "date",
  "DateTime"   => "datetime",
  "Time"       => "datetime"
}
```

Por padrão, o nó raiz é "hash", mas isso pode ser configurado através da opção `:root`.

O construtor XML padrão é uma nova instância de `Builder::XmlMarkup`. Você pode configurar seu próprio construtor com a opção `:builder`. O método também aceita opções como `:dasherize` e amigos, que são encaminhados para o construtor.

NOTA: Definido em `active_support/core_ext/hash/conversions.rb`.


### Mesclando

Ruby possui um método embutido `Hash#merge` que mescla dois hashes:

```ruby
{ a: 1, b: 1 }.merge(a: 0, c: 2)
# => {:a=>0, :b=>1, :c=>2}
```

O Active Support define algumas maneiras adicionais de mesclar hashes que podem ser convenientes.

#### `reverse_merge` e `reverse_merge!`

Em caso de colisão, a chave no hash do argumento vence em `merge`. Você pode suportar hashes de opções com valores padrão de forma compacta com esse idiom:

```ruby
options = { length: 30, omission: "..." }.merge(options)
```

O Active Support define [`reverse_merge`][Hash#reverse_merge] caso você prefira essa notação alternativa:

```ruby
options = options.reverse_merge(length: 30, omission: "...")
```

E uma versão com bang [`reverse_merge!`][Hash#reverse_merge!] que realiza a mesclagem no local:

```ruby
options.reverse_merge!(length: 30, omission: "...")
```

ATENÇÃO. Leve em consideração que `reverse_merge!` pode alterar o hash no chamador, o que pode ou não ser uma boa ideia.

NOTA: Definido em `active_support/core_ext/hash/reverse_merge.rb`.


#### `reverse_update`

O método [`reverse_update`][Hash#reverse_update] é um alias para `reverse_merge!`, explicado acima.

ATENÇÃO. Observe que `reverse_update` não possui bang.

NOTA: Definido em `active_support/core_ext/hash/reverse_merge.rb`.


#### `deep_merge` e `deep_merge!`

Como você pode ver no exemplo anterior, se uma chave for encontrada em ambos os hashes, o valor no hash do argumento vence.

O Active Support define [`Hash#deep_merge`][Hash#deep_merge]. Em uma mesclagem profunda, se uma chave for encontrada em ambos os hashes e seus valores forem hashes por sua vez, então a _mesclagem_ deles se torna o valor no hash resultante:

```ruby
{ a: { b: 1 } }.deep_merge(a: { c: 2 })
# => {:a=>{:b=>1, :c=>2}}
```
O método [`deep_merge!`][Hash#deep_merge!] realiza uma mesclagem profunda no local.

NOTA: Definido em `active_support/core_ext/hash/deep_merge.rb`.


### Duplicação Profunda

O método [`Hash#deep_dup`][Hash#deep_dup] duplica a si mesmo e todas as chaves e valores
internamente de forma recursiva com o método `Object#deep_dup` do Active Support. Funciona como `Enumerator#each_with_object` enviando o método `deep_dup` para cada par dentro.

```ruby
hash = { a: 1, b: { c: 2, d: [3, 4] } }

dup = hash.deep_dup
dup[:b][:e] = 5
dup[:b][:d] << 5

hash[:b][:e] == nil      # => true
hash[:b][:d] == [3, 4]   # => true
```

NOTA: Definido em `active_support/core_ext/object/deep_dup.rb`.


### Trabalhando com Chaves

#### `except` e `except!`

O método [`except`][Hash#except] retorna um hash com as chaves na lista de argumentos removidas, se presentes:

```ruby
{ a: 1, b: 2 }.except(:a) # => {:b=>2}
```

Se o receptor responder a `convert_key`, o método é chamado em cada um dos argumentos. Isso permite que `except` funcione bem com hashes com acesso indiferente, por exemplo:

```ruby
{ a: 1 }.with_indifferent_access.except(:a)  # => {}
{ a: 1 }.with_indifferent_access.except("a") # => {}
```

Existe também a variante com exclamação [`except!`][Hash#except!] que remove as chaves no local.

NOTA: Definido em `active_support/core_ext/hash/except.rb`.


#### `stringify_keys` e `stringify_keys!`

O método [`stringify_keys`][Hash#stringify_keys] retorna um hash que tem uma versão em string das chaves no receptor. Ele faz isso enviando `to_s` para elas:

```ruby
{ nil => nil, 1 => 1, a: :a }.stringify_keys
# => {"" => nil, "1" => 1, "a" => :a}
```

Em caso de colisão de chaves, o valor será o mais recentemente inserido no hash:

```ruby
{ "a" => 1, a: 2 }.stringify_keys
# O resultado será
# => {"a"=>2}
```

Este método pode ser útil, por exemplo, para aceitar facilmente símbolos e strings como opções. Por exemplo, `ActionView::Helpers::FormHelper` define:

```ruby
def to_check_box_tag(options = {}, checked_value = "1", unchecked_value = "0")
  options = options.stringify_keys
  options["type"] = "checkbox"
  # ...
end
```

A segunda linha pode acessar com segurança a chave "type" e permitir que o usuário passe tanto `:type` quanto "type".

Existe também a variante com exclamação [`stringify_keys!`][Hash#stringify_keys!] que converte as chaves em string no local.

Além disso, pode-se usar [`deep_stringify_keys`][Hash#deep_stringify_keys] e [`deep_stringify_keys!`][Hash#deep_stringify_keys!] para converter todas as chaves no hash fornecido e todos os hashes aninhados nele em string. Um exemplo do resultado é:

```ruby
{ nil => nil, 1 => 1, nested: { a: 3, 5 => 5 } }.deep_stringify_keys
# => {""=>nil, "1"=>1, "nested"=>{"a"=>3, "5"=>5}}
```

NOTA: Definido em `active_support/core_ext/hash/keys.rb`.


#### `symbolize_keys` e `symbolize_keys!`

O método [`symbolize_keys`][Hash#symbolize_keys] retorna um hash que tem uma versão simbolizada das chaves no receptor, quando possível. Ele faz isso enviando `to_sym` para elas:

```ruby
{ nil => nil, 1 => 1, "a" => "a" }.symbolize_keys
# => {nil=>nil, 1=>1, :a=>"a"}
```

ATENÇÃO. Note que no exemplo anterior apenas uma chave foi simbolizada.

Em caso de colisão de chaves, o valor será o mais recentemente inserido no hash:

```ruby
{ "a" => 1, a: 2 }.symbolize_keys
# => {:a=>2}
```

Este método pode ser útil, por exemplo, para aceitar facilmente símbolos e strings como opções. Por exemplo, `ActionText::TagHelper` define
```ruby
def rich_text_area_tag(name, value = nil, options = {})
  options = options.symbolize_keys

  options[:input] ||= "trix_input_#{ActionText::TagHelper.id += 1}"
  # ...
end
```

A terceira linha pode acessar com segurança a chave `:input` e permite que o usuário passe tanto `:input` quanto "input".

Também existe a variante com exclamação [`symbolize_keys!`][Hash#symbolize_keys!] que simboliza as chaves no local.

Além disso, pode-se usar [`deep_symbolize_keys`][Hash#deep_symbolize_keys] e [`deep_symbolize_keys!`][Hash#deep_symbolize_keys!] para simbolizar todas as chaves no hash fornecido e todos os hashes aninhados nele. Um exemplo do resultado é:

```ruby
{ nil => nil, 1 => 1, "nested" => { "a" => 3, 5 => 5 } }.deep_symbolize_keys
# => {nil=>nil, 1=>1, nested:{a:3, 5=>5}}
```

NOTA: Definido em `active_support/core_ext/hash/keys.rb`.


#### `to_options` e `to_options!`

Os métodos [`to_options`][Hash#to_options] e [`to_options!`][Hash#to_options!] são aliases de `symbolize_keys` e `symbolize_keys!`, respectivamente.

NOTA: Definido em `active_support/core_ext/hash/keys.rb`.


#### `assert_valid_keys`

O método [`assert_valid_keys`][Hash#assert_valid_keys] recebe um número arbitrário de argumentos e verifica se o receptor tem alguma chave fora dessa lista. Se tiver, `ArgumentError` é lançado.

```ruby
{ a: 1 }.assert_valid_keys(:a)  # passa
{ a: 1 }.assert_valid_keys("a") # ArgumentError
```

O Active Record não aceita opções desconhecidas ao criar associações, por exemplo. Ele implementa esse controle por meio de `assert_valid_keys`.

NOTA: Definido em `active_support/core_ext/hash/keys.rb`.


### Trabalhando com Valores

#### `deep_transform_values` e `deep_transform_values!`

O método [`deep_transform_values`][Hash#deep_transform_values] retorna um novo hash com todos os valores convertidos pela operação do bloco. Isso inclui os valores do hash raiz e de todos os hashes e arrays aninhados.

```ruby
hash = { person: { name: 'Rob', age: '28' } }

hash.deep_transform_values { |value| value.to_s.upcase }
# => {person: {name: "ROB", age: "28"}}
```

Também existe a variante com exclamação [`deep_transform_values!`][Hash#deep_transform_values!] que converte destrutivamente todos os valores usando a operação do bloco.

NOTA: Definido em `active_support/core_ext/hash/deep_transform_values.rb`.


### Slicing

O método [`slice!`][Hash#slice!] substitui o hash apenas pelas chaves fornecidas e retorna um hash contendo os pares chave/valor removidos.

```ruby
hash = { a: 1, b: 2 }
rest = hash.slice!(:a) # => {:b=>2}
hash                   # => {:a=>1}
```

NOTA: Definido em `active_support/core_ext/hash/slice.rb`.


### Extrair

O método [`extract!`][Hash#extract!] remove e retorna os pares chave/valor correspondentes às chaves fornecidas.

```ruby
hash = { a: 1, b: 2 }
rest = hash.extract!(:a) # => {:a=>1}
hash                     # => {:b=>2}
```

O método `extract!` retorna a mesma subclasse de Hash que o receptor é.

```ruby
hash = { a: 1, b: 2 }.with_indifferent_access
rest = hash.extract!(:a).class
# => ActiveSupport::HashWithIndifferentAccess
```

NOTA: Definido em `active_support/core_ext/hash/slice.rb`.


### Acesso Indiferente

O método [`with_indifferent_access`][Hash#with_indifferent_access] retorna um [`ActiveSupport::HashWithIndifferentAccess`][ActiveSupport::HashWithIndifferentAccess] a partir de seu receptor:

```ruby
{ a: 1 }.with_indifferent_access["a"] # => 1
```

NOTA: Definido em `active_support/core_ext/hash/indifferent_access.rb`.


Extensões para `Regexp`
----------------------

### `multiline?`

O método [`multiline?`][Regexp#multiline?] indica se uma expressão regular tem a flag `/m` definida, ou seja, se o ponto corresponde a quebras de linha.

```ruby
%r{.}.multiline?  # => false
%r{.}m.multiline? # => true

Regexp.new('.').multiline?                    # => false
Regexp.new('.', Regexp::MULTILINE).multiline? # => true
```

O Rails usa esse método em um único lugar, também no código de roteamento. Expressões regulares multilinhas não são permitidas para requisitos de rota e essa flag facilita a aplicação dessa restrição.

```ruby
def verify_regexp_requirements(requirements)
  # ...
  if requirement.multiline?
    raise ArgumentError, "Regexp multiline option is not allowed in routing requirements: #{requirement.inspect}"
  end
  # ...
end
```
NOTA: Definido em `active_support/core_ext/regexp.rb`.


Extensões para `Range`
---------------------

### `to_fs`

O Active Support define `Range#to_fs` como uma alternativa para `to_s` que entende um argumento de formato opcional. No momento em que este documento foi escrito, o único formato não padrão suportado é `:db`:

```ruby
(Date.today..Date.tomorrow).to_fs
# => "2009-10-25..2009-10-26"

(Date.today..Date.tomorrow).to_fs(:db)
# => "BETWEEN '2009-10-25' AND '2009-10-26'"
```

Como o exemplo mostra, o formato `:db` gera uma cláusula SQL `BETWEEN`. Isso é usado pelo Active Record em seu suporte a valores de intervalo em condições.

NOTA: Definido em `active_support/core_ext/range/conversions.rb`.

### `===` e `include?`

Os métodos `Range#===` e `Range#include?` indicam se um determinado valor está entre os extremos de uma instância dada:

```ruby
(2..3).include?(Math::E) # => true
```

O Active Support estende esses métodos para que o argumento possa ser outro intervalo. Nesse caso, testamos se os extremos do intervalo do argumento pertencem ao próprio intervalo receptor:

```ruby
(1..10) === (3..7)  # => true
(1..10) === (0..7)  # => false
(1..10) === (3..11) # => false
(1...9) === (3..9)  # => false

(1..10).include?(3..7)  # => true
(1..10).include?(0..7)  # => false
(1..10).include?(3..11) # => false
(1...9).include?(3..9)  # => false
```

NOTA: Definido em `active_support/core_ext/range/compare_range.rb`.

### `overlap?`

O método [`Range#overlap?`][Range#overlap?] indica se dois intervalos dados têm uma interseção não vazia:

```ruby
(1..10).overlap?(7..11)  # => true
(1..10).overlap?(0..7)   # => true
(1..10).overlap?(11..27) # => false
```

NOTA: Definido em `active_support/core_ext/range/overlap.rb`.


Extensões para `Date`
--------------------

### Cálculos

INFO: Os seguintes métodos de cálculo têm casos especiais em outubro de 1582, pois os dias 5 a 14 simplesmente não existem. Este guia não documenta seu comportamento em torno desses dias por brevidade, mas é suficiente dizer que eles fazem o que você espera. Ou seja, `Date.new(1582, 10, 4).tomorrow` retorna `Date.new(1582, 10, 15)` e assim por diante. Verifique `test/core_ext/date_ext_test.rb` no conjunto de testes do Active Support para o comportamento esperado.

#### `Date.current`

O Active Support define [`Date.current`][Date.current] como sendo hoje no fuso horário atual. Isso é semelhante a `Date.today`, exceto que ele respeita o fuso horário do usuário, se definido. Ele também define [`Date.yesterday`][Date.yesterday] e [`Date.tomorrow`][Date.tomorrow], e os predicados de instância [`past?`][DateAndTime::Calculations#past?], [`today?`][DateAndTime::Calculations#today?], [`tomorrow?`][DateAndTime::Calculations#tomorrow?], [`next_day?`][DateAndTime::Calculations#next_day?], [`yesterday?`][DateAndTime::Calculations#yesterday?], [`prev_day?`][DateAndTime::Calculations#prev_day?], [`future?`][DateAndTime::Calculations#future?], [`on_weekday?`][DateAndTime::Calculations#on_weekday?] e [`on_weekend?`][DateAndTime::Calculations#on_weekend?], todos eles relativos a `Date.current`.

Ao fazer comparações de datas usando métodos que respeitam o fuso horário do usuário, certifique-se de usar `Date.current` e não `Date.today`. Existem casos em que o fuso horário do usuário pode estar no futuro em comparação com o fuso horário do sistema, que é usado por padrão pelo `Date.today`. Isso significa que `Date.today` pode ser igual a `Date.yesterday`.

NOTA: Definido em `active_support/core_ext/date/calculations.rb`.


#### Datas Nomeadas

##### `beginning_of_week`, `end_of_week`

Os métodos [`beginning_of_week`][DateAndTime::Calculations#beginning_of_week] e [`end_of_week`][DateAndTime::Calculations#end_of_week] retornam as datas para o início e o fim da semana, respectivamente. Assume-se que as semanas começam na segunda-feira, mas isso pode ser alterado passando um argumento, definindo `Date.beginning_of_week` localmente ou [`config.beginning_of_week`][].

```ruby
d = Date.new(2010, 5, 8)     # => Sat, 08 May 2010
d.beginning_of_week          # => Mon, 03 May 2010
d.beginning_of_week(:sunday) # => Sun, 02 May 2010
d.end_of_week                # => Sun, 09 May 2010
d.end_of_week(:sunday)       # => Sat, 08 May 2010
```

`beginning_of_week` é um alias para [`at_beginning_of_week`][DateAndTime::Calculations#at_beginning_of_week] e `end_of_week` é um alias para [`at_end_of_week`][DateAndTime::Calculations#at_end_of_week].

NOTA: Definido em `active_support/core_ext/date_and_time/calculations.rb`.


##### `monday`, `sunday`

Os métodos [`monday`][DateAndTime::Calculations#monday] e [`sunday`][DateAndTime::Calculations#sunday] retornam as datas para a segunda-feira anterior e o próximo domingo, respectivamente.
```ruby
date = Date.new(2010, 6, 7)
date.months_ago(3) # => Mon, 07 Mar 2010
date.months_since(3) # => Thu, 07 Sep 2010
```

If such a day does not exist, the last day of the corresponding month is returned:

```ruby
Date.new(2012, 3, 31).months_ago(1)     # => Thu, 29 Feb 2012
Date.new(2012, 1, 31).months_since(1)   # => Thu, 29 Feb 2012
```

[`last_month`][DateAndTime::Calculations#last_month] is short-hand for `#months_ago(1)`.

NOTE: Defined in `active_support/core_ext/date_and_time/calculations.rb`.


##### `weeks_ago`, `weeks_since`

The methods [`weeks_ago`][DateAndTime::Calculations#weeks_ago] and [`weeks_since`][DateAndTime::Calculations#weeks_since] work analogously for weeks:

```ruby
date = Date.new(2010, 6, 7)
date.weeks_ago(2) # => Mon, 24 May 2010
date.weeks_since(2) # => Mon, 21 Jun 2010
```

If such a day does not exist, the last day of the corresponding month is returned:

```ruby
Date.new(2012, 2, 29).weeks_ago(1)     # => Wed, 22 Feb 2012
Date.new(2012, 2, 29).weeks_since(1)   # => Wed, 07 Mar 2012
```

[`last_week`][DateAndTime::Calculations#last_week] is short-hand for `#weeks_ago(1)`.

NOTE: Defined in `active_support/core_ext/date_and_time/calculations.rb`.


##### `days_ago`, `days_since`

The methods [`days_ago`][DateAndTime::Calculations#days_ago] and [`days_since`][DateAndTime::Calculations#days_since] work analogously for days:

```ruby
date = Date.new(2010, 6, 7)
date.days_ago(5) # => Wed, 02 Jun 2010
date.days_since(5) # => Sat, 12 Jun 2010
```

[`yesterday`][DateAndTime::Calculations#yesterday] is short-hand for `#days_ago(1)`, and [`tomorrow`][DateAndTime::Calculations#tomorrow] is short-hand for `#days_since(1)`.

NOTE: Defined in `active_support/core_ext/date_and_time/calculations.rb`.
```
```ruby
date = DateTime.new(2010, 6, 7, 19, 55, 25)
date.beginning_of_minute # => Mon Jun 07 19:55:00 +0200 2010
```

The method [`end_of_minute`][DateTime#end_of_minute] returns a timestamp at the end of the minute (hh:mm:59):

```ruby
date = DateTime.new(2010, 6, 7, 19, 55, 25)
date.end_of_minute # => Mon Jun 07 19:55:59 +0200 2010
```

`beginning_of_minute` is aliased to [`at_beginning_of_minute`][DateTime#at_beginning_of_minute].

NOTE: Defined in `active_support/core_ext/date_time/calculations.rb`.


##### `change`

The method [`change`][DateTime#change] allows you to get a new timestamp which is the same as the receiver except for the given year, month, day, hour, minute, or second:

```ruby
date = DateTime.new(2010, 12, 23, 12, 30, 45)
date.change(year: 2011, month: 11, day: 15)
# => Tue, 15 Nov 2011 12:30:45 +0200
```

This method is not tolerant to non-existing dates, if the change is invalid `ArgumentError` is raised:

```ruby
date = DateTime.new(2010, 1, 31, 12, 30, 45)
date.change(month: 2)
# => ArgumentError: invalid date
```

NOTE: Defined in `active_support/core_ext/date_time/calculations.rb`.


#### Durations

[`Duration`][ActiveSupport::Duration] objects can be added to and subtracted from timestamps:

```ruby
t = Time.current
# => Mon, 09 Aug 2010 12:34:56 UTC +00:00
t + 1.year
# => Tue, 09 Aug 2011 12:34:56 UTC +00:00
t - 3.hours
# => Mon, 09 Aug 2010 09:34:56 UTC +00:00
```

They translate to calls to `since` or `advance`. For example here we get the correct jump in the calendar reform:

```ruby
Time.new(1582, 10, 4, 12, 0, 0) + 1.day
# => Fri, 15 Oct 1582 12:00:00 UTC +00:00
```


#### Time Zones

INFO: The following methods return a `Time` object if possible, otherwise a `DateTime`. If set, they honor the user time zone.

##### `in_time_zone`

The method [`in_time_zone`][Time#in_time_zone] returns a new `Time` or `DateTime` object in the specified time zone:

```ruby
time = Time.utc(2010, 6, 7, 19, 55, 25)
time.in_time_zone('Eastern Time (US & Canada)') # => Mon, 07 Jun 2010 15:55:25 EDT -04:00
```

NOTE: Defined in `active_support/core_ext/time/zones.rb`.


##### `utc`

The method [`utc`][Time#utc] returns a new `Time` object in UTC time zone:

```ruby
time = Time.new(2010, 6, 7, 19, 55, 25, '-04:00')
time.utc # => Tue, 08 Jun 2010 03:55:25 UTC +00:00
```

NOTE: Defined in `active_support/core_ext/time/calculations.rb`.


##### `local`

The method [`local`][Time#local] returns a new `Time` or `DateTime` object in the local time zone:

```ruby
time = Time.utc(2010, 6, 7, 19, 55, 25)
time.local # => Mon, 07 Jun 2010 15:55:25 EDT -04:00
```

NOTE: Defined in `active_support/core_ext/time/calculations.rb`.


##### `to_time`

The method [`to_time`][Time#to_time] returns a new `Time` object representing the same time as the receiver:

```ruby
date = Date.new(2010, 6, 7)
date.to_time # => Mon, 07 Jun 2010 00:00:00 UTC +00:00
```

NOTE: Defined in `active_support/core_ext/date/conversions.rb`.


##### `to_datetime`

The method [`to_datetime`][Time#to_datetime] returns a new `DateTime` object representing the same time as the receiver:

```ruby
time = Time.new(2010, 6, 7, 19, 55, 25)
time.to_datetime # => Mon, 07 Jun 2010 19:55:25 +0000
```

NOTE: Defined in `active_support/core_ext/time/conversions.rb`.
```ruby
date = DateTime.new(2010, 6, 7, 19, 55, 25)
date.beginning_of_minute # => Segunda-feira, 07 de Junho de 2010 19:55:00 +0200
```

O método [`end_of_minute`][DateTime#end_of_minute] retorna um timestamp no final do minuto (hh:mm:59):

```ruby
date = DateTime.new(2010, 6, 7, 19, 55, 25)
date.end_of_minute # => Segunda-feira, 07 de Junho de 2010 19:55:59 +0200
```

`beginning_of_minute` é um alias para [`at_beginning_of_minute`][DateTime#at_beginning_of_minute].

INFO: `beginning_of_hour`, `end_of_hour`, `beginning_of_minute` e `end_of_minute` são implementados para `Time` e `DateTime`, mas **não** para `Date`, pois não faz sentido solicitar o início ou o fim de uma hora ou minuto em uma instância de `Date`.

NOTE: Definido em `active_support/core_ext/date_time/calculations.rb`.


##### `ago`, `since`

O método [`ago`][Date#ago] recebe um número de segundos como argumento e retorna um timestamp correspondente a essa quantidade de segundos atrás da meia-noite:

```ruby
date = Date.current # => Sexta-feira, 11 de Junho de 2010
date.ago(1)         # => Quinta-feira, 10 de Junho de 2010 23:59:59 EDT -04:00
```

Da mesma forma, [`since`][Date#since] move para frente:

```ruby
date = Date.current # => Sexta-feira, 11 de Junho de 2010
date.since(1)       # => Sexta-feira, 11 de Junho de 2010 00:00:01 EDT -04:00
```

NOTE: Definido em `active_support/core_ext/date/calculations.rb`.


Extensões para `DateTime`
------------------------

WARNING: `DateTime` não está ciente das regras de DST (Horário de Verão) e, portanto, alguns desses métodos têm casos especiais quando ocorre uma mudança de DST. Por exemplo, [`seconds_since_midnight`][DateTime#seconds_since_midnight] pode não retornar a quantidade real em um dia assim.

### Cálculos

A classe `DateTime` é uma subclasse de `Date`, então ao carregar `active_support/core_ext/date/calculations.rb`, você herda esses métodos e seus aliases, exceto que eles sempre retornarão datetimes.

Os seguintes métodos são reimplementados para que você **não** precise carregar `active_support/core_ext/date/calculations.rb` para esses:

* [`beginning_of_day`][DateTime#beginning_of_day] / [`midnight`][DateTime#midnight] / [`at_midnight`][DateTime#at_midnight] / [`at_beginning_of_day`][DateTime#at_beginning_of_day]
* [`end_of_day`][DateTime#end_of_day]
* [`ago`][DateTime#ago]
* [`since`][DateTime#since] / [`in`][DateTime#in]

Por outro lado, [`advance`][DateTime#advance] e [`change`][DateTime#change] também são definidos e suportam mais opções, eles estão documentados abaixo.

Os seguintes métodos são implementados apenas em `active_support/core_ext/date_time/calculations.rb`, pois só fazem sentido quando usados com uma instância de `DateTime`:

* [`beginning_of_hour`][DateTime#beginning_of_hour] / [`at_beginning_of_hour`][DateTime#at_beginning_of_hour]
* [`end_of_hour`][DateTime#end_of_hour]


#### Datetimes Nomeados

##### `DateTime.current`

Active Support define [`DateTime.current`][DateTime.current] para ser como `Time.now.to_datetime`, exceto que ele respeita o fuso horário do usuário, se definido. Os predicados de instância [`past?`][DateAndTime::Calculations#past?] e [`future?`][DateAndTime::Calculations#future?] são definidos em relação a `DateTime.current`.

NOTE: Definido em `active_support/core_ext/date_time/calculations.rb`.


#### Outras Extensões

##### `seconds_since_midnight`

O método [`seconds_since_midnight`][DateTime#seconds_since_midnight] retorna o número de segundos desde a meia-noite:

```ruby
now = DateTime.current     # => Segunda-feira, 07 de Junho de 2010 20:26:36 +0000
now.seconds_since_midnight # => 73596
```

NOTE: Definido em `active_support/core_ext/date_time/calculations.rb`.


##### `utc`

O método [`utc`][DateTime#utc] retorna o mesmo datetime no receptor expresso em UTC.

```ruby
now = DateTime.current # => Segunda-feira, 07 de Junho de 2010 19:27:52 -0400
now.utc                # => Segunda-feira, 07 de Junho de 2010 23:27:52 +0000
```

Esse método também é um alias para [`getutc`][DateTime#getutc].

NOTE: Definido em `active_support/core_ext/date_time/calculations.rb`.


##### `utc?`

O predicado [`utc?`][DateTime#utc?] indica se o receptor tem UTC como seu fuso horário:

```ruby
now = DateTime.now # => Segunda-feira, 07 de Junho de 2010 19:30:47 -0400
now.utc?           # => false
now.utc.utc?       # => true
```

NOTE: Definido em `active_support/core_ext/date_time/calculations.rb`.


##### `advance`

A maneira mais genérica de pular para outro datetime é [`advance`][DateTime#advance]. Este método recebe um hash com as chaves `:years`, `:months`, `:weeks`, `:days`, `:hours`, `:minutes` e `:seconds`, e retorna um datetime avançado conforme as chaves presentes indicam.
```ruby
d = DateTime.current
# => Qui, 05 Ago 2010 11:33:31 +0000
d.advance(years: 1, months: 1, days: 1, hours: 1, minutes: 1, seconds: 1)
# => Ter, 06 Set 2011 12:34:32 +0000
```

Este método primeiro calcula a data de destino passando `:years`, `:months`, `:weeks` e `:days` para `Date#advance` documentado acima. Depois disso, ajusta o horário chamando [`since`][DateTime#since] com o número de segundos para avançar. Esta ordem é relevante, uma ordem diferente resultaria em datas e horas diferentes em alguns casos extremos. O exemplo em `Date#advance` se aplica e podemos estendê-lo para mostrar a relevância da ordem relacionada aos bits de tempo.

Se primeiro movermos os bits de data (que também têm uma ordem relativa de processamento, como documentado anteriormente) e depois os bits de tempo, obtemos, por exemplo, o seguinte cálculo:

```ruby
d = DateTime.new(2010, 2, 28, 23, 59, 59)
# => Dom, 28 Fev 2010 23:59:59 +0000
d.advance(months: 1, seconds: 1)
# => Seg, 29 Mar 2010 00:00:00 +0000
```

mas se os calculássemos na ordem inversa, o resultado seria diferente:

```ruby
d.advance(seconds: 1).advance(months: 1)
# => Qui, 01 Abr 2010 00:00:00 +0000
```

AVISO: Como `DateTime` não é DST-aware, você pode acabar em um ponto no tempo que não existe sem nenhum aviso ou erro informando isso.

NOTA: Definido em `active_support/core_ext/date_time/calculations.rb`.


#### Alterando Componentes

O método [`change`][DateTime#change] permite obter um novo datetime que é o mesmo que o receptor, exceto pelas opções fornecidas, que podem incluir `:year`, `:month`, `:day`, `:hour`, `:min`, `:sec`, `:offset`, `:start`:

```ruby
now = DateTime.current
# => Ter, 08 Jun 2010 01:56:22 +0000
now.change(year: 2011, offset: Rational(-6, 24))
# => Qua, 08 Jun 2011 01:56:22 -0600
```

Se as horas forem zeradas, então os minutos e segundos também serão (a menos que tenham valores fornecidos):

```ruby
now.change(hour: 0)
# => Ter, 08 Jun 2010 00:00:00 +0000
```

Da mesma forma, se os minutos forem zerados, então os segundos também serão (a menos que tenha um valor fornecido):

```ruby
now.change(min: 0)
# => Ter, 08 Jun 2010 01:00:00 +0000
```

Este método não tolera datas que não existem, se a alteração for inválida, `ArgumentError` é lançado:

```ruby
DateTime.current.change(month: 2, day: 30)
# => ArgumentError: data inválida
```

NOTA: Definido em `active_support/core_ext/date_time/calculations.rb`.


#### Durações

Objetos [`Duration`][ActiveSupport::Duration] podem ser adicionados e subtraídos de datetimes:

```ruby
now = DateTime.current
# => Seg, 09 Ago 2010 23:15:17 +0000
now + 1.year
# => Ter, 09 Ago 2011 23:15:17 +0000
now - 1.week
# => Seg, 02 Ago 2010 23:15:17 +0000
```

Eles se traduzem em chamadas para `since` ou `advance`. Por exemplo, aqui obtemos o salto correto na reforma do calendário:

```ruby
DateTime.new(1582, 10, 4, 23) + 1.hour
# => Sex, 15 Out 1582 00:00:00 +0000
```

Extensões para `Time`
--------------------

### Cálculos

São análogos. Consulte a documentação acima e leve em consideração as seguintes diferenças:

* [`change`][Time#change] aceita uma opção adicional `:usec`.
* `Time` entende DST, então você obtém cálculos corretos de DST como em

```ruby
Time.zone_default
# => #<ActiveSupport::TimeZone:0x7f73654d4f38 @utc_offset=nil, @name="Madrid", ...>

# Em Barcelona, 2010/03/28 02:00 +0100 se torna 2010/03/28 03:00 +0200 devido ao DST.
t = Time.local(2010, 3, 28, 1, 59, 59)
# => Dom Mar 28 01:59:59 +0100 2010
t.advance(seconds: 1)
# => Dom Mar 28 03:00:00 +0200 2010
```

* Se [`since`][Time#since] ou [`ago`][Time#ago] saltarem para um tempo que não pode ser expresso com `Time`, um objeto `DateTime` é retornado.

#### `Time.current`

O Active Support define [`Time.current`][Time.current] como a data de hoje no fuso horário atual. É como `Time.now`, mas respeita o fuso horário do usuário, se definido. Ele também define os predicados de instância [`past?`][DateAndTime::Calculations#past?], [`today?`][DateAndTime::Calculations#today?], [`tomorrow?`][DateAndTime::Calculations#tomorrow?], [`next_day?`][DateAndTime::Calculations#next_day?], [`yesterday?`][DateAndTime::Calculations#yesterday?], [`prev_day?`][DateAndTime::Calculations#prev_day?] e [`future?`][DateAndTime::Calculations#future?], todos relativos a `Time.current`.

Ao fazer comparações de tempo usando métodos que respeitam o fuso horário do usuário, certifique-se de usar `Time.current` em vez de `Time.now`. Existem casos em que o fuso horário do usuário pode estar no futuro em comparação com o fuso horário do sistema, que é usado por padrão pelo `Time.now`. Isso significa que `Time.now.to_date` pode ser igual a `Date.yesterday`.

NOTA: Definido em `active_support/core_ext/time/calculations.rb`.


#### `all_day`, `all_week`, `all_month`, `all_quarter` e `all_year`

O método [`all_day`][DateAndTime::Calculations#all_day] retorna um intervalo representando o dia inteiro do tempo atual.

```ruby
now = Time.current
# => Mon, 09 Aug 2010 23:20:05 UTC +00:00
now.all_day
# => Mon, 09 Aug 2010 00:00:00 UTC +00:00..Mon, 09 Aug 2010 23:59:59 UTC +00:00
```

Analogamente, [`all_week`][DateAndTime::Calculations#all_week], [`all_month`][DateAndTime::Calculations#all_month], [`all_quarter`][DateAndTime::Calculations#all_quarter] e [`all_year`][DateAndTime::Calculations#all_year] servem para gerar intervalos de tempo.

```ruby
now = Time.current
# => Mon, 09 Aug 2010 23:20:05 UTC +00:00
now.all_week
# => Mon, 09 Aug 2010 00:00:00 UTC +00:00..Sun, 15 Aug 2010 23:59:59 UTC +00:00
now.all_week(:sunday)
# => Sun, 16 Sep 2012 00:00:00 UTC +00:00..Sat, 22 Sep 2012 23:59:59 UTC +00:00
now.all_month
# => Sat, 01 Aug 2010 00:00:00 UTC +00:00..Tue, 31 Aug 2010 23:59:59 UTC +00:00
now.all_quarter
# => Thu, 01 Jul 2010 00:00:00 UTC +00:00..Thu, 30 Sep 2010 23:59:59 UTC +00:00
now.all_year
# => Fri, 01 Jan 2010 00:00:00 UTC +00:00..Fri, 31 Dec 2010 23:59:59 UTC +00:00
```

NOTA: Definido em `active_support/core_ext/date_and_time/calculations.rb`.


#### `prev_day`, `next_day`

[`prev_day`][Time#prev_day] e [`next_day`][Time#next_day] retornam o tempo no dia anterior ou no próximo dia:

```ruby
t = Time.new(2010, 5, 8) # => 2010-05-08 00:00:00 +0900
t.prev_day               # => 2010-05-07 00:00:00 +0900
t.next_day               # => 2010-05-09 00:00:00 +0900
```

NOTA: Definido em `active_support/core_ext/time/calculations.rb`.


#### `prev_month`, `next_month`

[`prev_month`][Time#prev_month] e [`next_month`][Time#next_month] retornam o tempo com o mesmo dia no mês anterior ou no próximo mês:

```ruby
t = Time.new(2010, 5, 8) # => 2010-05-08 00:00:00 +0900
t.prev_month             # => 2010-04-08 00:00:00 +0900
t.next_month             # => 2010-06-08 00:00:00 +0900
```

Se um dia assim não existir, o último dia do mês correspondente é retornado:

```ruby
Time.new(2000, 5, 31).prev_month # => 2000-04-30 00:00:00 +0900
Time.new(2000, 3, 31).prev_month # => 2000-02-29 00:00:00 +0900
Time.new(2000, 5, 31).next_month # => 2000-06-30 00:00:00 +0900
Time.new(2000, 1, 31).next_month # => 2000-02-29 00:00:00 +0900
```

NOTA: Definido em `active_support/core_ext/time/calculations.rb`.


#### `prev_year`, `next_year`

[`prev_year`][Time#prev_year] e [`next_year`][Time#next_year] retornam um tempo com o mesmo dia/mês no ano anterior ou no próximo ano:

```ruby
t = Time.new(2010, 5, 8) # => 2010-05-08 00:00:00 +0900
t.prev_year              # => 2009-05-08 00:00:00 +0900
t.next_year              # => 2011-05-08 00:00:00 +0900
```

Se a data for o dia 29 de fevereiro de um ano bissexto, você obtém o dia 28:

```ruby
t = Time.new(2000, 2, 29) # => 2000-02-29 00:00:00 +0900
t.prev_year               # => 1999-02-28 00:00:00 +0900
t.next_year               # => 2001-02-28 00:00:00 +0900
```
NOTA: Definido em `active_support/core_ext/time/calculations.rb`.


#### `prev_quarter`, `next_quarter`

[`prev_quarter`][DateAndTime::Calculations#prev_quarter] e [`next_quarter`][DateAndTime::Calculations#next_quarter] retornam a data com o mesmo dia no trimestre anterior ou seguinte:

```ruby
t = Time.local(2010, 5, 8) # => 2010-05-08 00:00:00 +0300
t.prev_quarter             # => 2010-02-08 00:00:00 +0200
t.next_quarter             # => 2010-08-08 00:00:00 +0300
```

Se esse dia não existir, o último dia do mês correspondente é retornado:

```ruby
Time.local(2000, 7, 31).prev_quarter  # => 2000-04-30 00:00:00 +0300
Time.local(2000, 5, 31).prev_quarter  # => 2000-02-29 00:00:00 +0200
Time.local(2000, 10, 31).prev_quarter # => 2000-07-31 00:00:00 +0300
Time.local(2000, 11, 31).next_quarter # => 2001-03-01 00:00:00 +0200
```

`prev_quarter` é um alias para [`last_quarter`][DateAndTime::Calculations#last_quarter].

NOTA: Definido em `active_support/core_ext/date_and_time/calculations.rb`.


### Construtores de Tempo

Active Support define [`Time.current`][Time.current] como `Time.zone.now` se houver um fuso horário do usuário definido, com fallback para `Time.now`:

```ruby
Time.zone_default
# => #<ActiveSupport::TimeZone:0x7f73654d4f38 @utc_offset=nil, @name="Madrid", ...>
Time.current
# => Fri, 06 Aug 2010 17:11:58 CEST +02:00
```

Analogamente ao `DateTime`, os predicados [`past?`][DateAndTime::Calculations#past?] e [`future?`][DateAndTime::Calculations#future?] são relativos ao `Time.current`.

Se o tempo a ser construído estiver além do intervalo suportado por `Time` na plataforma em execução, os microssegundos são descartados e um objeto `DateTime` é retornado.

#### Durações

Objetos [`Duration`][ActiveSupport::Duration] podem ser adicionados e subtraídos de objetos de tempo:

```ruby
now = Time.current
# => Mon, 09 Aug 2010 23:20:05 UTC +00:00
now + 1.year
# => Tue, 09 Aug 2011 23:21:11 UTC +00:00
now - 1.week
# => Mon, 02 Aug 2010 23:21:11 UTC +00:00
```

Eles se traduzem em chamadas para `since` ou `advance`. Por exemplo, aqui obtemos o salto correto na reforma do calendário:

```ruby
Time.utc(1582, 10, 3) + 5.days
# => Mon Oct 18 00:00:00 UTC 1582
```

Extensões para `File`
--------------------

### `atomic_write`

Com o método de classe [`File.atomic_write`][File.atomic_write], você pode escrever em um arquivo de forma que nenhum leitor veja o conteúdo meio escrito.

O nome do arquivo é passado como argumento, e o método gera um identificador de arquivo aberto para escrita. Uma vez que o bloco é concluído, `atomic_write` fecha o identificador de arquivo e conclui seu trabalho.

Por exemplo, o Action Pack usa esse método para escrever arquivos de cache de ativos como `all.css`:

```ruby
File.atomic_write(joined_asset_path) do |cache|
  cache.write(join_asset_file_contents(asset_paths))
end
```

Para realizar isso, `atomic_write` cria um arquivo temporário. Esse é o arquivo em que o código no bloco realmente escreve. Ao concluir, o arquivo temporário é renomeado, o que é uma operação atômica em sistemas POSIX. Se o arquivo de destino existir, `atomic_write` o sobrescreve e mantém proprietários e permissões. No entanto, existem alguns casos em que `atomic_write` não pode alterar a propriedade ou permissões do arquivo, esse erro é capturado e ignorado, confiando no usuário/sistema de arquivos para garantir que o arquivo seja acessível aos processos que o necessitam.

NOTA. Devido à operação chmod que `atomic_write` executa, se o arquivo de destino tiver um ACL definido nele, esse ACL será recalculado/modificado.

ATENÇÃO. Observe que você não pode anexar com `atomic_write`.

O arquivo auxiliar é gravado em um diretório padrão para arquivos temporários, mas você pode passar um diretório de sua escolha como segundo argumento.

NOTA: Definido em `active_support/core_ext/file/atomic.rb`.


Extensões para `NameError`
-------------------------
O Active Support adiciona [`missing_name?`][NameError#missing_name?] ao `NameError`, que testa se a exceção foi lançada por causa do nome passado como argumento.

O nome pode ser fornecido como um símbolo ou uma string. Um símbolo é testado em relação ao nome da constante simples, uma string é testada em relação ao nome da constante totalmente qualificado.

DICA: Um símbolo pode representar um nome de constante totalmente qualificado como em `:"ActiveRecord::Base"`, então o comportamento para símbolos é definido por conveniência, não porque precisa ser assim tecnicamente.

Por exemplo, quando uma ação de `ArticlesController` é chamada, o Rails tenta otimisticamente usar `ArticlesHelper`. Está tudo bem se o módulo helper não existir, então se uma exceção for lançada para esse nome de constante, ela deve ser silenciada. Mas pode ser o caso de `articles_helper.rb` lançar um `NameError` devido a uma constante desconhecida real. Isso deve ser relançado. O método `missing_name?` fornece uma maneira de distinguir ambos os casos:

```ruby
def default_helper_module!
  module_name = name.delete_suffix("Controller")
  module_path = module_name.underscore
  helper module_path
rescue LoadError => e
  raise e unless e.is_missing? "helpers/#{module_path}_helper"
rescue NameError => e
  raise e unless e.missing_name? "#{module_name}Helper"
end
```

NOTA: Definido em `active_support/core_ext/name_error.rb`.


Extensões para `LoadError`
-------------------------

O Active Support adiciona [`is_missing?`][LoadError#is_missing?] ao `LoadError`.

Dado um nome de caminho, `is_missing?` testa se a exceção foi lançada devido a esse arquivo específico (exceto talvez pela extensão ".rb").

Por exemplo, quando uma ação de `ArticlesController` é chamada, o Rails tenta carregar `articles_helper.rb`, mas esse arquivo pode não existir. Isso é normal, o módulo helper não é obrigatório, então o Rails silencia um erro de carregamento. Mas pode ser o caso de o módulo helper existir e, por sua vez, requerer outra biblioteca que está faltando. Nesse caso, o Rails deve relançar a exceção. O método `is_missing?` fornece uma maneira de distinguir ambos os casos:

```ruby
def default_helper_module!
  module_name = name.delete_suffix("Controller")
  module_path = module_name.underscore
  helper module_path
rescue LoadError => e
  raise e unless e.is_missing? "helpers/#{module_path}_helper"
rescue NameError => e
  raise e unless e.missing_name? "#{module_name}Helper"
end
```

NOTA: Definido em `active_support/core_ext/load_error.rb`.


Extensões para Pathname
-------------------------

### `existence`

O método [`existence`][Pathname#existence] retorna o próprio objeto se o arquivo com o nome especificado existir, caso contrário, retorna `nil`. É útil para idiomatismos como este:

```ruby
content = Pathname.new("file").existence&.read
```

NOTA: Definido em `active_support/core_ext/pathname/existence.rb`.
[`config.active_support.bare`]: configuring.html#config-active-support-bare
[Object#blank?]: https://api.rubyonrails.org/classes/Object.html#method-i-blank-3F
[Object#present?]: https://api.rubyonrails.org/classes/Object.html#method-i-present-3F
[Object#presence]: https://api.rubyonrails.org/classes/Object.html#method-i-presence
[Object#duplicable?]: https://api.rubyonrails.org/classes/Object.html#method-i-duplicable-3F
[Object#deep_dup]: https://api.rubyonrails.org/classes/Object.html#method-i-deep_dup
[Object#try]: https://api.rubyonrails.org/classes/Object.html#method-i-try
[Object#try!]: https://api.rubyonrails.org/classes/Object.html#method-i-try-21
[Kernel#class_eval]: https://api.rubyonrails.org/classes/Kernel.html#method-i-class_eval
[Object#acts_like?]: https://api.rubyonrails.org/classes/Object.html#method-i-acts_like-3F
[Array#to_param]: https://api.rubyonrails.org/classes/Array.html#method-i-to_param
[Object#to_param]: https://api.rubyonrails.org/classes/Object.html#method-i-to_param
[Hash#to_query]: https://api.rubyonrails.org/classes/Hash.html#method-i-to_query
[Object#to_query]: https://api.rubyonrails.org/classes/Object.html#method-i-to_query
[Object#with_options]: https://api.rubyonrails.org/classes/Object.html#method-i-with_options
[Object#instance_values]: https://api.rubyonrails.org/classes/Object.html#method-i-instance_values
[Object#instance_variable_names]: https://api.rubyonrails.org/classes/Object.html#method-i-instance_variable_names
[Kernel#enable_warnings]: https://api.rubyonrails.org/classes/Kernel.html#method-i-enable_warnings
[Kernel#silence_warnings]: https://api.rubyonrails.org/classes/Kernel.html#method-i-silence_warnings
[Kernel#suppress]: https://api.rubyonrails.org/classes/Kernel.html#method-i-suppress
[Object#in?]: https://api.rubyonrails.org/classes/Object.html#method-i-in-3F
[Module#alias_attribute]: https://api.rubyonrails.org/classes/Module.html#method-i-alias_attribute
[Module#attr_internal]: https://api.rubyonrails.org/classes/Module.html#method-i-attr_internal
[Module#attr_internal_accessor]: https://api.rubyonrails.org/classes/Module.html#method-i-attr_internal_accessor
[Module#attr_internal_reader]: https://api.rubyonrails.org/classes/Module.html#method-i-attr_internal_reader
[Module#attr_internal_writer]: https://api.rubyonrails.org/classes/Module.html#method-i-attr_internal_writer
[Module#mattr_accessor]: https://api.rubyonrails.org/classes/Module.html#method-i-mattr_accessor
[Module#mattr_reader]: https://api.rubyonrails.org/classes/Module.html#method-i-mattr_reader
[Module#mattr_writer]: https://api.rubyonrails.org/classes/Module.html#method-i-mattr_writer
[Module#module_parent]: https://api.rubyonrails.org/classes/Module.html#method-i-module_parent
[Module#module_parent_name]: https://api.rubyonrails.org/classes/Module.html#method-i-module_parent_name
[Module#module_parents]: https://api.rubyonrails.org/classes/Module.html#method-i-module_parents
[Module#anonymous?]: https://api.rubyonrails.org/classes/Module.html#method-i-anonymous-3F
[Module#delegate]: https://api.rubyonrails.org/classes/Module.html#method-i-delegate
[Module#delegate_missing_to]: https://api.rubyonrails.org/classes/Module.html#method-i-delegate_missing_to
[Module#redefine_method]: https://api.rubyonrails.org/classes/Module.html#method-i-redefine_method
[Module#silence_redefinition_of_method]: https://api.rubyonrails.org/classes/Module.html#method-i-silence_redefinition_of_method
[Class#class_attribute]: https://api.rubyonrails.org/classes/Class.html#method-i-class_attribute
[Module#cattr_accessor]: https://api.rubyonrails.org/classes/Module.html#method-i-cattr_accessor
[Module#cattr_reader]: https://api.rubyonrails.org/classes/Module.html#method-i-cattr_reader
[Module#cattr_writer]: https://api.rubyonrails.org/classes/Module.html#method-i-cattr_writer
[Class#subclasses]: https://api.rubyonrails.org/classes/Class.html#method-i-subclasses
[Class#descendants]: https://api.rubyonrails.org/classes/Class.html#method-i-descendants
[`raw`]: https://api.rubyonrails.org/classes/ActionView/Helpers/OutputSafetyHelper.html#method-i-raw
[String#html_safe]: https://api.rubyonrails.org/classes/String.html#method-i-html_safe
[String#remove]: https://api.rubyonrails.org/classes/String.html#method-i-remove
[String#squish]: https://api.rubyonrails.org/classes/String.html#method-i-squish
[String#truncate]: https://api.rubyonrails.org/classes/String.html#method-i-truncate
[String#truncate_bytes]: https://api.rubyonrails.org/classes/String.html#method-i-truncate_bytes
[String#truncate_words]: https://api.rubyonrails.org/classes/String.html#method-i-truncate_words
[String#inquiry]: https://api.rubyonrails.org/classes/String.html#method-i-inquiry
[String#strip_heredoc]: https://api.rubyonrails.org/classes/String.html#method-i-strip_heredoc
[String#indent!]: https://api.rubyonrails.org/classes/String.html#method-i-indent-21
[String#indent]: https://api.rubyonrails.org/classes/String.html#method-i-indent
[String#at]: https://api.rubyonrails.org/classes/String.html#method-i-at
[String#from]: https://api.rubyonrails.org/classes/String.html#method-i-from
[String#to]: https://api.rubyonrails.org/classes/String.html#method-i-to
[String#first]: https://api.rubyonrails.org/classes/String.html#method-i-first
[String#last]: https://api.rubyonrails.org/classes/String.html#method-i-last
[String#pluralize]: https://api.rubyonrails.org/classes/String.html#method-i-pluralize
[String#singularize]: https://api.rubyonrails.org/classes/String.html#method-i-singularize
[String#camelcase]: https://api.rubyonrails.org/classes/String.html#method-i-camelcase
[String#camelize]: https://api.rubyonrails.org/classes/String.html#method-i-camelize
[String#underscore]: https://api.rubyonrails.org/classes/String.html#method-i-underscore
[String#titlecase]: https://api.rubyonrails.org/classes/String.html#method-i-titlecase
[String#titleize]: https://api.rubyonrails.org/classes/String.html#method-i-titleize
[String#dasherize]: https://api.rubyonrails.org/classes/String.html#method-i-dasherize
[String#demodulize]: https://api.rubyonrails.org/classes/String.html#method-i-demodulize
[String#deconstantize]: https://api.rubyonrails.org/classes/String.html#method-i-deconstantize
[String#parameterize]: https://api.rubyonrails.org/classes/String.html#method-i-parameterize
[String#tableize]: https://api.rubyonrails.org/classes/String.html#method-i-tableize
[String#classify]: https://api.rubyonrails.org/classes/String.html#method-i-classify
[String#constantize]: https://api.rubyonrails.org/classes/String.html#method-i-constantize
[String#humanize]: https://api.rubyonrails.org/classes/String.html#method-i-humanize
[String#foreign_key]: https://api.rubyonrails.org/classes/String.html#method-i-foreign_key
[String#upcase_first]: https://api.rubyonrails.org/classes/String.html#method-i-upcase_first
[String#downcase_first]: https://api.rubyonrails.org/classes/String.html#method-i-downcase_first
[String#to_date]: https://api.rubyonrails.org/classes/String.html#method-i-to_date
[String#to_datetime]: https://api.rubyonrails.org/classes/String.html#method-i-to_datetime
[String#to_time]: https://api.rubyonrails.org/classes/String.html#method-i-to_time
[Numeric#bytes]: https://api.rubyonrails.org/classes/Numeric.html#method-i-bytes
[Numeric#exabytes]: https://api.rubyonrails.org/classes/Numeric.html#method-i-exabytes
[Numeric#gigabytes]: https://api.rubyonrails.org/classes/Numeric.html#method-i-gigabytes
[Numeric#kilobytes]: https://api.rubyonrails.org/classes/Numeric.html#method-i-kilobytes
[Numeric#megabytes]: https://api.rubyonrails.org/classes/Numeric.html#method-i-megabytes
[Numeric#petabytes]: https://api.rubyonrails.org/classes/Numeric.html#method-i-petabytes
[Numeric#terabytes]: https://api.rubyonrails.org/classes/Numeric.html#method-i-terabytes
[Duration#ago]: https://api.rubyonrails.org/classes/ActiveSupport/Duration.html#method-i-ago
[Duration#from_now]: https://api.rubyonrails.org/classes/ActiveSupport/Duration.html#method-i-from_now
[Numeric#days]: https://api.rubyonrails.org/classes/Numeric.html#method-i-days
[Numeric#fortnights]: https://api.rubyonrails.org/classes/Numeric.html#method-i-fortnights
[Numeric#hours]: https://api.rubyonrails.org/classes/Numeric.html#method-i-hours
[Numeric#minutes]: https://api.rubyonrails.org/classes/Numeric.html#method-i-minutes
[Numeric#seconds]: https://api.rubyonrails.org/classes/Numeric.html#method-i-seconds
[Numeric#weeks]: https://api.rubyonrails.org/classes/Numeric.html#method-i-weeks
[Integer#multiple_of?]: https://api.rubyonrails.org/classes/Integer.html#method-i-multiple_of-3F
[Integer#ordinal]: https://api.rubyonrails.org/classes/Integer.html#method-i-ordinal
[Integer#ordinalize]: https://api.rubyonrails.org/classes/Integer.html#method-i-ordinalize
[Integer#months]: https://api.rubyonrails.org/classes/Integer.html#method-i-months
[Integer#years]: https://api.rubyonrails.org/classes/Integer.html#method-i-years
[Enumerable#sum]: https://api.rubyonrails.org/classes/Enumerable.html#method-i-sum
[Enumerable#index_by]: https://api.rubyonrails.org/classes/Enumerable.html#method-i-index_by
[Enumerable#index_with]: https://api.rubyonrails.org/classes/Enumerable.html#method-i-index_with
[Enumerable#many?]: https://api.rubyonrails.org/classes/Enumerable.html#method-i-many-3F
[Enumerable#exclude?]: https://api.rubyonrails.org/classes/Enumerable.html#method-i-exclude-3F
[Enumerable#including]: https://api.rubyonrails.org/classes/Enumerable.html#method-i-including
[Enumerable#excluding]: https://api.rubyonrails.org/classes/Enumerable.html#method-i-excluding
[Enumerable#without]: https://api.rubyonrails.org/classes/Enumerable.html#method-i-without
[Enumerable#pluck]: https://api.rubyonrails.org/classes/Enumerable.html#method-i-pluck
[Enumerable#pick]: https://api.rubyonrails.org/classes/Enumerable.html#method-i-pick
[Array#excluding]: https://api.rubyonrails.org/classes/Array.html#method-i-excluding
[Array#fifth]: https://api.rubyonrails.org/classes/Array.html#method-i-fifth
[Array#forty_two]: https://api.rubyonrails.org/classes/Array.html#method-i-forty_two
[Array#fourth]: https://api.rubyonrails.org/classes/Array.html#method-i-fourth
[Array#from]: https://api.rubyonrails.org/classes/Array.html#method-i-from
[Array#including]: https://api.rubyonrails.org/classes/Array.html#method-i-including
[Array#second]: https://api.rubyonrails.org/classes/Array.html#method-i-second
[Array#second_to_last]: https://api.rubyonrails.org/classes/Array.html#method-i-second_to_last
[Array#third]: https://api.rubyonrails.org/classes/Array.html#method-i-third
[Array#third_to_last]: https://api.rubyonrails.org/classes/Array.html#method-i-third_to_last
[Array#to]: https://api.rubyonrails.org/classes/Array.html#method-i-to
[Array#extract!]: https://api.rubyonrails.org/classes/Array.html#method-i-extract-21
[Array#extract_options!]: https://api.rubyonrails.org/classes/Array.html#method-i-extract_options-21
[Array#to_sentence]: https://api.rubyonrails.org/classes/Array.html#method-i-to_sentence
[Array#to_fs]: https://api.rubyonrails.org/classes/Array.html#method-i-to_fs
[Array#to_xml]: https://api.rubyonrails.org/classes/Array.html#method-i-to_xml
[Array.wrap]: https://api.rubyonrails.org/classes/Array.html#method-c-wrap
[Array#deep_dup]: https://api.rubyonrails.org/classes/Array.html#method-i-deep_dup
[Array#in_groups_of]: https://api.rubyonrails.org/classes/Array.html#method-i-in_groups_of
[Array#in_groups]: https://api.rubyonrails.org/classes/Array.html#method-i-in_groups
[Array#split]: https://api.rubyonrails.org/classes/Array.html#method-i-split
[Hash#to_xml]: https://api.rubyonrails.org/classes/Hash.html#method-i-to_xml
[Hash#reverse_merge!]: https://api.rubyonrails.org/classes/Hash.html#method-i-reverse_merge-21
[Hash#reverse_merge]: https://api.rubyonrails.org/classes/Hash.html#method-i-reverse_merge
[Hash#reverse_update]: https://api.rubyonrails.org/classes/Hash.html#method-i-reverse_update
[Hash#deep_merge!]: https://api.rubyonrails.org/classes/Hash.html#method-i-deep_merge-21
[Hash#deep_merge]: https://api.rubyonrails.org/classes/Hash.html#method-i-deep_merge
[Hash#deep_dup]: https://api.rubyonrails.org/classes/Hash.html#method-i-deep_dup
[Hash#except!]: https://api.rubyonrails.org/classes/Hash.html#method-i-except-21
[Hash#except]: https://api.rubyonrails.org/classes/Hash.html#method-i-except
[Hash#deep_stringify_keys!]: https://api.rubyonrails.org/classes/Hash.html#method-i-deep_stringify_keys-21
[Hash#deep_stringify_keys]: https://api.rubyonrails.org/classes/Hash.html#method-i-deep_stringify_keys
[Hash#stringify_keys!]: https://api.rubyonrails.org/classes/Hash.html#method-i-stringify_keys-21
[Hash#stringify_keys]: https://api.rubyonrails.org/classes/Hash.html#method-i-stringify_keys
[Hash#deep_symbolize_keys!]: https://api.rubyonrails.org/classes/Hash.html#method-i-deep_symbolize_keys-21
[Hash#deep_symbolize_keys]: https://api.rubyonrails.org/classes/Hash.html#method-i-deep_symbolize_keys
[Hash#symbolize_keys!]: https://api.rubyonrails.org/classes/Hash.html#method-i-symbolize_keys-21
[Hash#symbolize_keys]: https://api.rubyonrails.org/classes/Hash.html#method-i-symbolize_keys
[Hash#to_options!]: https://api.rubyonrails.org/classes/Hash.html#method-i-to_options-21
[Hash#to_options]: https://api.rubyonrails.org/classes/Hash.html#method-i-to_options
[Hash#assert_valid_keys]: https://api.rubyonrails.org/classes/Hash.html#method-i-assert_valid_keys
[Hash#deep_transform_values!]: https://api.rubyonrails.org/classes/Hash.html#method-i-deep_transform_values-21
[Hash#deep_transform_values]: https://api.rubyonrails.org/classes/Hash.html#method-i-deep_transform_values
[Hash#slice!]: https://api.rubyonrails.org/classes/Hash.html#method-i-slice-21
[Hash#extract!]: https://api.rubyonrails.org/classes/Hash.html#method-i-extract-21
[ActiveSupport::HashWithIndifferentAccess]: https://api.rubyonrails.org/classes/ActiveSupport/HashWithIndifferentAccess.html
[Hash#with_indifferent_access]: https://api.rubyonrails.org/classes/Hash.html#method-i-with_indifferent_access
[Regexp#multiline?]: https://api.rubyonrails.org/classes/Regexp.html#method-i-multiline-3F
[Range#overlap?]: https://api.rubyonrails.org/classes/Range.html#method-i-overlaps-3F
[Date.current]: https://api.rubyonrails.org/classes/Date.html#method-c-current
[Date.tomorrow]: https://api.rubyonrails.org/classes/Date.html#method-c-tomorrow
[Date.yesterday]: https://api.rubyonrails.org/classes/Date.html#method-c-yesterday
[DateAndTime::Calculations#future?]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-future-3F
[DateAndTime::Calculations#on_weekday?]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-on_weekday-3F
[DateAndTime::Calculations#on_weekend?]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-on_weekend-3F
[DateAndTime::Calculations#past?]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-past-3F
[`config.beginning_of_week`]: configuring.html#config-beginning-of-week
[DateAndTime::Calculations#at_beginning_of_week]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-at_beginning_of_week
[DateAndTime::Calculations#at_end_of_week]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-at_end_of_week
[DateAndTime::Calculations#beginning_of_week]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-beginning_of_week
[DateAndTime::Calculations#end_of_week]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-end_of_week
[DateAndTime::Calculations#monday]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-monday
[DateAndTime::Calculations#sunday]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-sunday
[Date.beginning_of_week]: https://api.rubyonrails.org/classes/Date.html#method-c-beginning_of_week
[DateAndTime::Calculations#last_week]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-last_week
[DateAndTime::Calculations#next_week]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-next_week
[DateAndTime::Calculations#prev_week]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-prev_week
[DateAndTime::Calculations#at_beginning_of_month]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-at_beginning_of_month
[DateAndTime::Calculations#at_end_of_month]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-at_end_of_month
[DateAndTime::Calculations#beginning_of_month]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-beginning_of_month
[DateAndTime::Calculations#end_of_month]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-end_of_month
[DateAndTime::Calculations#quarter]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-quarter
[DateAndTime::Calculations#at_beginning_of_quarter]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-at_beginning_of_quarter
[DateAndTime::Calculations#at_end_of_quarter]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-at_end_of_quarter
[DateAndTime::Calculations#beginning_of_quarter]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-beginning_of_quarter
[DateAndTime::Calculations#end_of_quarter]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-end_of_quarter
[DateAndTime::Calculations#at_beginning_of_year]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-at_beginning_of_year
[DateAndTime::Calculations#at_end_of_year]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-at_end_of_year
[DateAndTime::Calculations#beginning_of_year]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-beginning_of_year
[DateAndTime::Calculations#end_of_year]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-end_of_year
[DateAndTime::Calculations#last_year]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-last_year
[DateAndTime::Calculations#years_ago]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-years_ago
[DateAndTime::Calculations#years_since]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-years_since
[DateAndTime::Calculations#last_month]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-last_month
[DateAndTime::Calculations#months_ago]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-months_ago
[DateAndTime::Calculations#months_since]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-months_since
[DateAndTime::Calculations#weeks_ago]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-weeks_ago
[Date#advance]: https://api.rubyonrails.org/classes/Date.html#method-i-advance
[Date#change]: https://api.rubyonrails.org/classes/Date.html#method-i-change
[ActiveSupport::Duration]: https://api.rubyonrails.org/classes/ActiveSupport/Duration.html
[Date#at_beginning_of_day]: https://api.rubyonrails.org/classes/Date.html#method-i-at_beginning_of_day
[Date#at_midnight]: https://api.rubyonrails.org/classes/Date.html#method-i-at_midnight
[Date#beginning_of_day]: https://api.rubyonrails.org/classes/Date.html#method-i-beginning_of_day
[Date#end_of_day]: https://api.rubyonrails.org/classes/Date.html#method-i-end_of_day
[Date#midnight]: https://api.rubyonrails.org/classes/Date.html#method-i-midnight
[DateTime#at_beginning_of_minute]: https://api.rubyonrails.org/classes/DateTime.html#method-i-at_beginning_of_minute
[DateTime#beginning_of_minute]: https://api.rubyonrails.org/classes/DateTime.html#method-i-beginning_of_minute
[DateTime#end_of_minute]: https://api.rubyonrails.org/classes/DateTime.html#method-i-end_of_minute
[Date#ago]: https://api.rubyonrails.org/classes/Date.html#method-i-ago
[Date#since]: https://api.rubyonrails.org/classes/Date.html#method-i-since
[DateTime#ago]: https://api.rubyonrails.org/classes/DateTime.html#method-i-ago
[DateTime#at_beginning_of_day]: https://api.rubyonrails.org/classes/DateTime.html#method-i-at_beginning_of_day
[DateTime#at_beginning_of_hour]: https://api.rubyonrails.org/classes/DateTime.html#method-i-at_beginning_of_hour
[DateTime#at_midnight]: https://api.rubyonrails.org/classes/DateTime.html#method-i-at_midnight
[DateTime#beginning_of_day]: https://api.rubyonrails.org/classes/DateTime.html#method-i-beginning_of_day
[DateTime#beginning_of_hour]: https://api.rubyonrails.org/classes/DateTime.html#method-i-beginning_of_hour
[DateTime#end_of_day]: https://api.rubyonrails.org/classes/DateTime.html#method-i-end_of_day
[DateTime#end_of_hour]: https://api.rubyonrails.org/classes/DateTime.html#method-i-end_of_hour
[DateTime#in]: https://api.rubyonrails.org/classes/DateTime.html#method-i-in
[DateTime#midnight]: https://api.rubyonrails.org/classes/DateTime.html#method-i-midnight
[DateTime.current]: https://api.rubyonrails.org/classes/DateTime.html#method-c-current
[DateTime#seconds_since_midnight]: https://api.rubyonrails.org/classes/DateTime.html#method-i-seconds_since_midnight
[DateTime#getutc]: https://api.rubyonrails.org/classes/DateTime.html#method-i-getutc
[DateTime#utc]: https://api.rubyonrails.org/classes/DateTime.html#method-i-utc
[DateTime#utc?]: https://api.rubyonrails.org/classes/DateTime.html#method-i-utc-3F
[DateTime#advance]: https://api.rubyonrails.org/classes/DateTime.html#method-i-advance
[DateTime#since]: https://api.rubyonrails.org/classes/DateTime.html#method-i-since
[DateTime#change]: https://api.rubyonrails.org/classes/DateTime.html#method-i-change
[Time#ago]: https://api.rubyonrails.org/classes/Time.html#method-i-ago
[Time#change]: https://api.rubyonrails.org/classes/Time.html#method-i-change
[Time#since]: https://api.rubyonrails.org/classes/Time.html#method-i-since
[DateAndTime::Calculations#next_day?]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-next_day-3F
[DateAndTime::Calculations#prev_day?]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-prev_day-3F
[DateAndTime::Calculations#today?]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-today-3F
[DateAndTime::Calculations#tomorrow?]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-tomorrow-3F
[DateAndTime::Calculations#yesterday?]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-yesterday-3F
[DateAndTime::Calculations#all_day]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-all_day
[DateAndTime::Calculations#all_month]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-all_month
[DateAndTime::Calculations#all_quarter]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-all_quarter
[DateAndTime::Calculations#all_week]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-all_week
[DateAndTime::Calculations#all_year]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-all_year
[Time.current]: https://api.rubyonrails.org/classes/Time.html#method-c-current
[Time#next_day]: https://api.rubyonrails.org/classes/Time.html#method-i-next_day
[Time#prev_day]: https://api.rubyonrails.org/classes/Time.html#method-i-prev_day
[Time#next_month]: https://api.rubyonrails.org/classes/Time.html#method-i-next_month
[Time#prev_month]: https://api.rubyonrails.org/classes/Time.html#method-i-prev_month
[Time#next_year]: https://api.rubyonrails.org/classes/Time.html#method-i-next_year
[Time#prev_year]: https://api.rubyonrails.org/classes/Time.html#method-i-prev_year
[DateAndTime::Calculations#last_quarter]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-last_quarter
[DateAndTime::Calculations#next_quarter]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-next_quarter
[DateAndTime::Calculations#prev_quarter]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-prev_quarter
[File.atomic_write]: https://api.rubyonrails.org/classes/File.html#method-c-atomic_write
[NameError#missing_name?]: https://api.rubyonrails.org/classes/NameError.html#method-i-missing_name-3F
[LoadError#is_missing?]: https://api.rubyonrails.org/classes/LoadError.html#method-i-is_missing-3F
[Pathname#existence]: https://api.rubyonrails.org/classes/Pathname.html#method-i-existence
