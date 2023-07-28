**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 320082396ef549e27ab4cb837ec975dd
Callbacks do Active Record
=======================

Este guia ensina como se conectar ao ciclo de vida dos objetos Active Record.

Depois de ler este guia, você saberá:

* Quando ocorrem certos eventos durante a vida de um objeto Active Record
* Como criar métodos de callback que respondem a eventos no ciclo de vida do objeto.
* Como criar classes especiais que encapsulam comportamentos comuns para seus callbacks.

--------------------------------------------------------------------------------

O Ciclo de Vida do Objeto
---------------------

Durante a operação normal de uma aplicação Rails, objetos podem ser criados, atualizados e destruídos. O Active Record fornece ganchos para este *ciclo de vida do objeto* para que você possa controlar sua aplicação e seus dados.

Callbacks permitem que você acione lógica antes ou depois de uma alteração no estado de um objeto.

```ruby
class Baby < ApplicationRecord
  after_create -> { puts "Parabéns!" }
end
```

```irb
irb> @baby = Baby.create
Parabéns!
```

Como você verá, existem muitos eventos do ciclo de vida e você pode escolher se conectar a qualquer um deles antes, depois ou até mesmo ao redor deles.

Visão geral dos Callbacks
------------------

Callbacks são métodos que são chamados em determinados momentos do ciclo de vida de um objeto. Com callbacks, é possível escrever código que será executado sempre que um objeto Active Record for criado, salvo, atualizado, excluído, validado ou carregado do banco de dados.

### Registro de Callbacks

Para usar os callbacks disponíveis, você precisa registrá-los. Você pode implementar os callbacks como métodos comuns e usar um método de classe no estilo macro para registrá-los como callbacks:

```ruby
class User < ApplicationRecord
  validates :login, :email, presence: true

  before_validation :ensure_login_has_a_value

  private
    def ensure_login_has_a_value
      if login.blank?
        self.login = email unless email.blank?
      end
    end
end
```

Os métodos de classe no estilo macro também podem receber um bloco. Considere usar este estilo se o código dentro do seu bloco for tão curto que caiba em uma única linha:

```ruby
class User < ApplicationRecord
  validates :login, :email, presence: true

  before_create do
    self.name = login.capitalize if name.blank?
  end
end
```

Alternativamente, você pode passar um proc para o callback a ser acionado.

```ruby
class User < ApplicationRecord
  before_create ->(user) { user.name = user.login.capitalize if user.name.blank? }
end
```

Por fim, você pode definir seu próprio objeto de callback personalizado, que abordaremos mais detalhadamente [abaixo](#callback-classes).

```ruby
class User < ApplicationRecord
  before_create MaybeAddName
end

class MaybeAddName
  def self.before_create(record)
    if record.name.blank?
      record.name = record.login.capitalize
    end
  end
end
```

Callbacks também podem ser registrados para serem acionados apenas em determinados eventos do ciclo de vida, o que permite controle completo sobre quando e em qual contexto seus callbacks são acionados.

```ruby
class User < ApplicationRecord
  before_validation :normalize_name, on: :create

  # :on também aceita um array
  after_validation :set_location, on: [ :create, :update ]

  private
    def normalize_name
      self.name = name.downcase.titleize
    end

    def set_location
      self.location = LocationService.query(self)
    end
end
```

É considerada uma boa prática declarar os métodos de callback como privados. Se deixados públicos, eles podem ser chamados de fora do modelo e violar o princípio de encapsulamento do objeto.

CUIDADO. Evite chamadas para `update`, `save` ou outros métodos que criam efeitos colaterais no objeto dentro do seu callback. Por exemplo, não chame `update(attribute: "value")` dentro de um callback. Isso pode alterar o estado do modelo e pode resultar em efeitos colaterais inesperados durante o commit. Em vez disso, você pode atribuir valores diretamente com segurança (por exemplo, `self.attribute = "value"`) em `before_create` / `before_update` ou callbacks anteriores.

Callbacks Disponíveis
-------------------

Aqui está uma lista com todos os callbacks disponíveis do Active Record, listados na mesma ordem em que serão chamados durante as respectivas operações:

### Criando um Objeto

* [`before_validation`][]
* [`after_validation`][]
* [`before_save`][]
* [`around_save`][]
* [`before_create`][]
* [`around_create`][]
* [`after_create`][]
* [`after_save`][]
* [`after_commit`][] / [`after_rollback`][]


### Atualizando um Objeto

* [`before_validation`][]
* [`after_validation`][]
* [`before_save`][]
* [`around_save`][]
* [`before_update`][]
* [`around_update`][]
* [`after_update`][]
* [`after_save`][]
* [`after_commit`][] / [`after_rollback`][]


CUIDADO. `after_save` é executado tanto na criação quanto na atualização, mas sempre _depois_ dos callbacks mais específicos `after_create` e `after_update`, independentemente da ordem em que as chamadas de macro foram executadas.

### Destruindo um Objeto

* [`before_destroy`][]
* [`around_destroy`][]
* [`after_destroy`][]
* [`after_commit`][] / [`after_rollback`][]


NOTA: Os callbacks `before_destroy` devem ser colocados antes das associações `dependent: :destroy` (ou use a opção `prepend: true`), para garantir que eles sejam executados antes que os registros sejam excluídos por `dependent: :destroy`.

CUIDADO. `after_commit` oferece garantias muito diferentes de `after_save`, `after_update` e `after_destroy`. Por exemplo, se ocorrer uma exceção em um `after_save`, a transação será revertida e os dados não serão persistidos. Enquanto qualquer coisa que aconteça `after_commit` pode garantir que a transação já foi concluída e os dados foram persistidos no banco de dados. Mais sobre [callbacks transacionais](#transaction-callbacks) abaixo.
### `after_initialize` e `after_find`

Sempre que um objeto Active Record for instanciado, o callback [`after_initialize`][] será chamado, seja diretamente usando `new` ou quando um registro for carregado do banco de dados. Isso pode ser útil para evitar a necessidade de substituir diretamente o método `initialize` do Active Record.

Ao carregar um registro do banco de dados, o callback [`after_find`][] será chamado. `after_find` é chamado antes de `after_initialize` se ambos forem definidos.

NOTA: Os callbacks `after_initialize` e `after_find` não têm contrapartes `before_*`.

Eles podem ser registrados da mesma forma que os outros callbacks do Active Record.

```ruby
class User < ApplicationRecord
  after_initialize do |user|
    puts "Você inicializou um objeto!"
  end

  after_find do |user|
    puts "Você encontrou um objeto!"
  end
end
```

```irb
irb> User.new
Você inicializou um objeto!
=> #<User id: nil>

irb> User.first
Você encontrou um objeto!
Você inicializou um objeto!
=> #<User id: 1>
```


### `after_touch`

O callback [`after_touch`][] será chamado sempre que um objeto Active Record for tocado.

```ruby
class User < ApplicationRecord
  after_touch do |user|
    puts "Você tocou em um objeto"
  end
end
```

```irb
irb> u = User.create(name: 'Kuldeep')
=> #<User id: 1, name: "Kuldeep", created_at: "2013-11-25 12:17:49", updated_at: "2013-11-25 12:17:49">

irb> u.touch
Você tocou em um objeto
=> true
```

Ele pode ser usado junto com `belongs_to`:

```ruby
class Book < ApplicationRecord
  belongs_to :library, touch: true
  after_touch do
    puts 'Um livro foi tocado'
  end
end

class Library < ApplicationRecord
  has_many :books
  after_touch :log_when_books_or_library_touched

  private
    def log_when_books_or_library_touched
      puts 'Livro/Biblioteca foi tocado'
    end
end
```

```irb
irb> @book = Book.last
=> #<Book id: 1, library_id: 1, created_at: "2013-11-25 17:04:22", updated_at: "2013-11-25 17:05:05">

irb> @book.touch # aciona @book.library.touch
Um livro foi tocado
Livro/Biblioteca foi tocado
=> true
```


Executando Callbacks
-----------------

Os seguintes métodos acionam callbacks:

* `create`
* `create!`
* `destroy`
* `destroy!`
* `destroy_all`
* `destroy_by`
* `save`
* `save!`
* `save(validate: false)`
* `toggle!`
* `touch`
* `update_attribute`
* `update`
* `update!`
* `valid?`

Além disso, o callback `after_find` é acionado pelos seguintes métodos de busca:

* `all`
* `first`
* `find`
* `find_by`
* `find_by_*`
* `find_by_*!`
* `find_by_sql`
* `last`

O callback `after_initialize` é acionado toda vez que um novo objeto da classe é inicializado.

NOTA: Os métodos `find_by_*` e `find_by_*!` são finders dinâmicos gerados automaticamente para cada atributo. Saiba mais sobre eles na seção [Finders dinâmicos](active_record_querying.html#dynamic-finders)

Ignorando Callbacks
------------------

Assim como nas validações, também é possível ignorar callbacks usando os seguintes métodos:

* `decrement!`
* `decrement_counter`
* `delete`
* `delete_all`
* `delete_by`
* `increment!`
* `increment_counter`
* `insert`
* `insert!`
* `insert_all`
* `insert_all!`
* `touch_all`
* `update_column`
* `update_columns`
* `update_all`
* `update_counters`
* `upsert`
* `upsert_all`

Esses métodos devem ser usados com cautela, no entanto, porque regras de negócio importantes e lógica de aplicativo podem ser mantidas em callbacks. Ignorá-los sem entender as possíveis implicações pode levar a dados inválidos.

Interrompendo a Execução
-----------------

Ao registrar novos callbacks para seus modelos, eles serão enfileirados para execução. Essa fila incluirá todas as validações do seu modelo, os callbacks registrados e a operação de banco de dados a ser executada.

Toda a cadeia de callbacks é envolvida em uma transação. Se algum callback gerar uma exceção, a cadeia de execução é interrompida e um ROLLBACK é emitido. Para interromper intencionalmente uma cadeia, use:

```ruby
throw :abort
```

ATENÇÃO. Qualquer exceção que não seja `ActiveRecord::Rollback` ou `ActiveRecord::RecordInvalid` será reemitida pelo Rails após a interrupção da cadeia de callbacks. Além disso, pode quebrar o código que não espera que métodos como `save` e `update` (que normalmente tentam retornar `true` ou `false`) gerem uma exceção.

NOTA: Se um `ActiveRecord::RecordNotDestroyed` for gerado dentro do callback `after_destroy`, `before_destroy` ou `around_destroy`, ele não será reemitido e o método `destroy` retornará `false`.

Callbacks Relacionais
--------------------

Callbacks funcionam por meio de relacionamentos de modelos e até podem ser definidos por eles. Suponha um exemplo em que um usuário tem muitos artigos. Os artigos de um usuário devem ser destruídos se o usuário for destruído. Vamos adicionar um callback `after_destroy` ao modelo `User` por meio de seu relacionamento com o modelo `Article`:

```ruby
class User < ApplicationRecord
  has_many :articles, dependent: :destroy
end

class Article < ApplicationRecord
  after_destroy :log_destroy_action

  def log_destroy_action
    puts 'Artigo destruído'
  end
end
```

```irb
irb> user = User.first
=> #<User id: 1>
irb> user.articles.create!
=> #<Article id: 1, user_id: 1>
irb> user.destroy
Artigo destruído
=> #<User id: 1>
```
Callbacks Condicionais
---------------------

Assim como nas validações, também podemos condicionar a chamada de um método de callback com base em um predicado específico. Podemos fazer isso usando as opções `:if` e `:unless`, que podem receber um símbolo, um `Proc` ou um `Array`.

Você pode usar a opção `:if` quando desejar especificar em quais condições o callback **deve** ser chamado. Se você quiser especificar as condições em que o callback **não deve** ser chamado, pode usar a opção `:unless`.

### Usando `:if` e `:unless` com um `Symbol`

Você pode associar as opções `:if` e `:unless` a um símbolo correspondente ao nome de um método predicado que será chamado imediatamente antes do callback.

Ao usar a opção `:if`, o callback **não** será executado se o método predicado retornar **false**; ao usar a opção `:unless`, o callback **não** será executado se o método predicado retornar **true**. Essa é a opção mais comum.

```ruby
class Order < ApplicationRecord
  before_save :normalize_card_number, if: :paid_with_card?
end
```

Usando essa forma de registro, também é possível registrar vários predicados diferentes que devem ser chamados para verificar se o callback deve ser executado. Abordaremos isso [abaixo](#multiple-callback-conditions).

### Usando `:if` e `:unless` com um `Proc`

É possível associar `:if` e `:unless` a um objeto `Proc`. Essa opção é mais adequada ao escrever métodos de validação curtos, geralmente em uma única linha:

```ruby
class Order < ApplicationRecord
  before_save :normalize_card_number,
    if: Proc.new { |order| order.paid_with_card? }
end
```

Como o proc é avaliado no contexto do objeto, também é possível escrever assim:

```ruby
class Order < ApplicationRecord
  before_save :normalize_card_number, if: Proc.new { paid_with_card? }
end
```

### Múltiplas Condições de Callback

As opções `:if` e `:unless` também aceitam um array de procs ou nomes de métodos como símbolos:

```ruby
class Comment < ApplicationRecord
  before_save :filter_content,
    if: [:subject_to_parental_control?, :untrusted_author?]
end
```

Você pode incluir facilmente um proc na lista de condições:

```ruby
class Comment < ApplicationRecord
  before_save :filter_content,
    if: [:subject_to_parental_control?, Proc.new { untrusted_author? }]
end
```

### Usando Ambos `:if` e `:unless`

Callbacks podem misturar tanto `:if` quanto `:unless` na mesma declaração:

```ruby
class Comment < ApplicationRecord
  before_save :filter_content,
    if: Proc.new { forum.parental_control? },
    unless: Proc.new { author.trusted? }
end
```

O callback só é executado quando todas as condições `:if` são avaliadas como `true` e nenhuma das condições `:unless` são avaliadas como `true`.

Classes de Callback
----------------

Às vezes, os métodos de callback que você escrever serão úteis o suficiente para serem reutilizados por outros modelos. O Active Record permite criar classes que encapsulam os métodos de callback, para que possam ser reutilizados.

Aqui está um exemplo em que criamos uma classe com um callback `after_destroy` para lidar com a limpeza de arquivos descartados no sistema de arquivos. Esse comportamento pode não ser exclusivo do nosso modelo `PictureFile` e podemos querer compartilhá-lo, então é uma boa ideia encapsulá-lo em uma classe separada. Isso tornará mais fácil testar e alterar esse comportamento.

```ruby
class FileDestroyerCallback
  def after_destroy(file)
    if File.exist?(file.filepath)
      File.delete(file.filepath)
    end
  end
end
```

Quando declarados dentro de uma classe, como acima, os métodos de callback receberão o objeto do modelo como parâmetro. Isso funcionará em qualquer modelo que use a classe da seguinte maneira:

```ruby
class PictureFile < ApplicationRecord
  after_destroy FileDestroyerCallback.new
end
```

Observe que precisamos instanciar um novo objeto `FileDestroyerCallback`, pois declaramos nosso callback como um método de instância. Isso é particularmente útil se os callbacks usarem o estado do objeto instanciado. No entanto, muitas vezes fará mais sentido declarar os callbacks como métodos de classe:

```ruby
class FileDestroyerCallback
  def self.after_destroy(file)
    if File.exist?(file.filepath)
      File.delete(file.filepath)
    end
  end
end
```

Quando o método de callback é declarado dessa maneira, não será necessário instanciar um novo objeto `FileDestroyerCallback` em nosso modelo.

```ruby
class PictureFile < ApplicationRecord
  after_destroy FileDestroyerCallback
end
```

Você pode declarar quantos callbacks desejar dentro de suas classes de callback.

Callbacks de Transação
---------------------

### Lidando com Consistência

Existem dois callbacks adicionais que são acionados após a conclusão de uma transação de banco de dados: [`after_commit`][] e [`after_rollback`][]. Esses callbacks são muito semelhantes ao callback `after_save`, exceto que eles só são executados após as alterações no banco de dados terem sido confirmadas ou revertidas. Eles são mais úteis quando seus modelos Active Record precisam interagir com sistemas externos que não fazem parte da transação do banco de dados.
Considere, por exemplo, o exemplo anterior em que o modelo `PictureFile` precisa excluir um arquivo após o registro correspondente ser destruído. Se algo levantar uma exceção após a chamada de retorno `after_destroy` e a transação for revertida, o arquivo terá sido excluído e o modelo ficará em um estado inconsistente. Por exemplo, suponha que `picture_file_2` no código abaixo não seja válido e o método `save!` levante um erro.

```ruby
PictureFile.transaction do
  picture_file_1.destroy
  picture_file_2.save!
end
```

Usando a chamada de retorno `after_commit`, podemos lidar com esse caso.

```ruby
class PictureFile < ApplicationRecord
  after_commit :delete_picture_file_from_disk, on: :destroy

  def delete_picture_file_from_disk
    if File.exist?(filepath)
      File.delete(filepath)
    end
  end
end
```

NOTA: A opção `:on` especifica quando uma chamada de retorno será disparada. Se você não fornecer a opção `:on`, a chamada de retorno será disparada para todas as ações.

### O Contexto Importa

Como é comum usar a chamada de retorno `after_commit` apenas em criação, atualização ou exclusão, existem aliases para essas operações:

* [`after_create_commit`][]
* [`after_update_commit`][]
* [`after_destroy_commit`][]

```ruby
class PictureFile < ApplicationRecord
  after_destroy_commit :delete_picture_file_from_disk

  def delete_picture_file_from_disk
    if File.exist?(filepath)
      File.delete(filepath)
    end
  end
end
```

AVISO. Quando uma transação é concluída, as chamadas de retorno `after_commit` ou `after_rollback` são chamadas para todos os modelos criados, atualizados ou excluídos dentro dessa transação. No entanto, se uma exceção for levantada em uma dessas chamadas de retorno, a exceção será propagada e quaisquer métodos `after_commit` ou `after_rollback` restantes não serão executados. Portanto, se o código da chamada de retorno puder levantar uma exceção, você precisará resgatá-la e tratá-la dentro da chamada de retorno para permitir que outras chamadas de retorno sejam executadas.

AVISO. O código executado dentro das chamadas de retorno `after_commit` ou `after_rollback` não está contido em uma transação.

AVISO. Usar tanto `after_create_commit` quanto `after_update_commit` com o mesmo nome de método permitirá apenas que a última chamada de retorno definida tenha efeito, pois ambas são aliases internamente para `after_commit`, que substitui as chamadas de retorno previamente definidas com o mesmo nome de método.

```ruby
class User < ApplicationRecord
  after_create_commit :log_user_saved_to_db
  after_update_commit :log_user_saved_to_db

  private
    def log_user_saved_to_db
      puts 'Usuário foi salvo no banco de dados'
    end
end
```

```irb
irb> @user = User.create # não imprime nada

irb> @user.save # atualizando @user
Usuário foi salvo no banco de dados
```

### `after_save_commit`

Também existe o [`after_save_commit`][], que é um alias para usar a chamada de retorno `after_commit` tanto para criação quanto para atualização juntas:

```ruby
class User < ApplicationRecord
  after_save_commit :log_user_saved_to_db

  private
    def log_user_saved_to_db
      puts 'Usuário foi salvo no banco de dados'
    end
end
```

```irb
irb> @user = User.create # criando um Usuário
Usuário foi salvo no banco de dados

irb> @user.save # atualizando @user
Usuário foi salvo no banco de dados
```

### Ordem das Chamadas de Retorno Transacionais

Ao definir várias chamadas de retorno transacionais (`after_commit`, `after_rollback`, etc), a ordem será invertida em relação à ordem em que foram definidas.

```ruby
class User < ActiveRecord::Base
  after_commit { puts("isso é realmente chamado em segundo lugar") }
  after_commit { puts("isso é realmente chamado em primeiro lugar") }
end
```

NOTA: Isso se aplica a todas as variações de `after_*_commit`, como `after_destroy_commit`.
[`after_create`]: https://api.rubyonrails.org/classes/ActiveRecord/Callbacks/ClassMethods.html#method-i-after_create
[`after_commit`]: https://api.rubyonrails.org/classes/ActiveRecord/Transactions/ClassMethods.html#method-i-after_commit
[`after_rollback`]: https://api.rubyonrails.org/classes/ActiveRecord/Transactions/ClassMethods.html#method-i-after_rollback
[`after_save`]: https://api.rubyonrails.org/classes/ActiveRecord/Callbacks/ClassMethods.html#method-i-after_save
[`after_validation`]: https://api.rubyonrails.org/classes/ActiveModel/Validations/Callbacks/ClassMethods.html#method-i-after_validation
[`around_create`]: https://api.rubyonrails.org/classes/ActiveRecord/Callbacks/ClassMethods.html#method-i-around_create
[`around_save`]: https://api.rubyonrails.org/classes/ActiveRecord/Callbacks/ClassMethods.html#method-i-around_save
[`before_create`]: https://api.rubyonrails.org/classes/ActiveRecord/Callbacks/ClassMethods.html#method-i-before_create
[`before_save`]: https://api.rubyonrails.org/classes/ActiveRecord/Callbacks/ClassMethods.html#method-i-before_save
[`before_validation`]: https://api.rubyonrails.org/classes/ActiveModel/Validations/Callbacks/ClassMethods.html#method-i-before_validation
[`after_update`]: https://api.rubyonrails.org/classes/ActiveRecord/Callbacks/ClassMethods.html#method-i-after_update
[`around_update`]: https://api.rubyonrails.org/classes/ActiveRecord/Callbacks/ClassMethods.html#method-i-around_update
[`before_update`]: https://api.rubyonrails.org/classes/ActiveRecord/Callbacks/ClassMethods.html#method-i-before_update
[`after_destroy`]: https://api.rubyonrails.org/classes/ActiveRecord/Callbacks/ClassMethods.html#method-i-after_destroy
[`around_destroy`]: https://api.rubyonrails.org/classes/ActiveRecord/Callbacks/ClassMethods.html#method-i-around_destroy
[`before_destroy`]: https://api.rubyonrails.org/classes/ActiveRecord/Callbacks/ClassMethods.html#method-i-before_destroy
[`after_find`]: https://api.rubyonrails.org/classes/ActiveRecord/Callbacks/ClassMethods.html#method-i-after_find
[`after_initialize`]: https://api.rubyonrails.org/classes/ActiveRecord/Callbacks/ClassMethods.html#method-i-after_initialize
[`after_touch`]: https://api.rubyonrails.org/classes/ActiveRecord/Callbacks/ClassMethods.html#method-i-after_touch
[`after_create_commit`]: https://api.rubyonrails.org/classes/ActiveRecord/Transactions/ClassMethods.html#method-i-after_create_commit
[`after_destroy_commit`]: https://api.rubyonrails.org/classes/ActiveRecord/Transactions/ClassMethods.html#method-i-after_destroy_commit
[`after_save_commit`]: https://api.rubyonrails.org/classes/ActiveRecord/Transactions/ClassMethods.html#method-i-after_save_commit
[`after_update_commit`]: https://api.rubyonrails.org/classes/ActiveRecord/Transactions/ClassMethods.html#method-i-after_update_commit
