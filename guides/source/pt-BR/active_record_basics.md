**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: b2cb0ab668ead9e8bd48cbd1bcac9b59
Noções básicas do Active Record
==============================

Este guia é uma introdução ao Active Record.

Após ler este guia, você saberá:

* O que é o Mapeamento Objeto-Relacional e o Active Record e como eles são usados no Rails.
* Como o Active Record se encaixa no paradigma Model-View-Controller.
* Como usar os modelos do Active Record para manipular dados armazenados em um banco de dados relacional.
* Convenções de nomenclatura do esquema do Active Record.
* Os conceitos de migrações de banco de dados, validações, callbacks e associações.

--------------------------------------------------------------------------------

O que é o Active Record?
------------------------

O Active Record é o M no [MVC][] - o modelo - que é a camada do sistema responsável por representar dados e lógica de negócios. O Active Record facilita a criação e o uso de objetos de negócios cujos dados requerem armazenamento persistente em um banco de dados. É uma implementação do padrão Active Record, que por si só é uma descrição de um sistema de Mapeamento Objeto-Relacional.

### O Padrão Active Record

[O Active Record foi descrito por Martin Fowler][MFAR] em seu livro _Patterns of Enterprise Application Architecture_. No Active Record, os objetos carregam tanto dados persistentes quanto comportamentos que operam nesses dados. O Active Record tem a opinião de que garantir a lógica de acesso aos dados como parte do objeto educará os usuários desse objeto sobre como gravar e ler do banco de dados.

### Mapeamento Objeto-Relacional

[O Mapeamento Objeto-Relacional][ORM], comumente referido por sua abreviação ORM, é uma técnica que conecta os objetos ricos de uma aplicação a tabelas em um sistema de gerenciamento de banco de dados relacional. Usando o ORM, as propriedades e relacionamentos dos objetos em uma aplicação podem ser facilmente armazenados e recuperados de um banco de dados sem escrever instruções SQL diretamente e com menos código de acesso ao banco de dados em geral.

NOTA: Conhecimento básico de sistemas de gerenciamento de banco de dados relacionais (RDBMS) e linguagem de consulta estruturada (SQL) é útil para entender completamente o Active Record. Consulte [este tutorial][sqlcourse] (ou [este][rdbmsinfo]) ou estude-os por outros meios se você quiser aprender mais.

### Active Record como um Framework ORM

O Active Record nos oferece vários mecanismos, sendo o mais importante a capacidade de:

* Representar modelos e seus dados.
* Representar associações entre esses modelos.
* Representar hierarquias de herança por meio de modelos relacionados.
* Validar modelos antes de serem persistidos no banco de dados.
* Realizar operações de banco de dados de maneira orientada a objetos.


Convenção sobre Configuração no Active Record
--------------------------------------------

Ao escrever aplicativos usando outras linguagens de programação ou frameworks, pode ser necessário escrever muito código de configuração. Isso é particularmente verdadeiro para frameworks ORM em geral. No entanto, se você seguir as convenções adotadas pelo Rails, precisará escrever muito pouca configuração (em alguns casos, nenhuma configuração) ao criar modelos do Active Record. A ideia é que, se você configurar seus aplicativos da mesma maneira na maioria das vezes, essa deve ser a maneira padrão. Assim, a configuração explícita seria necessária apenas nos casos em que você não pode seguir a convenção padrão.

### Convenções de Nomenclatura

Por padrão, o Active Record usa algumas convenções de nomenclatura para descobrir como a correspondência entre modelos e tabelas de banco de dados deve ser criada. O Rails pluralizará os nomes de suas classes para encontrar a tabela de banco de dados correspondente. Portanto, para uma classe `Book`, você deve ter uma tabela de banco de dados chamada **books**. Os mecanismos de pluralização do Rails são muito poderosos, sendo capazes de pluralizar (e singularizar) palavras regulares e irregulares. Ao usar nomes de classes compostos por duas ou mais palavras, o nome da classe do modelo deve seguir as convenções do Ruby, usando a forma CamelCase, enquanto o nome da tabela deve usar a forma snake_case. Exemplos:

* Classe do Modelo - Singular com a primeira letra de cada palavra em maiúscula (por exemplo, `BookClub`).
* Tabela do Banco de Dados - Plural com sublinhados separando as palavras (por exemplo, `book_clubs`).

| Modelo / Classe | Tabela / Esquema |
| --------------- | --------------- |
| `Article`       | `articles`      |
| `LineItem`      | `line_items`    |
| `Deer`          | `deers`         |
| `Mouse`         | `mice`          |
| `Person`        | `people`        |

### Convenções de Esquema

O Active Record usa convenções de nomenclatura para as colunas nas tabelas de banco de dados, dependendo do propósito dessas colunas.

* **Chaves estrangeiras** - Esses campos devem ser nomeados seguindo o padrão `singularized_table_name_id` (por exemplo, `item_id`, `order_id`). Esses são os campos que o Active Record procurará quando você criar associações entre seus modelos.
* **Chaves primárias** - Por padrão, o Active Record usará uma coluna inteira chamada `id` como chave primária da tabela (`bigint` para PostgreSQL e MySQL, `integer` para SQLite). Ao usar [Migrações do Active Record](active_record_migrations.html) para criar suas tabelas, essa coluna será criada automaticamente.
Também existem alguns nomes de colunas opcionais que adicionam recursos adicionais às instâncias do Active Record:

* `created_at` - Define automaticamente a data e hora atual quando o registro é criado pela primeira vez.
* `updated_at` - Define automaticamente a data e hora atual quando o registro é criado ou atualizado.
* `lock_version` - Adiciona [bloqueio otimista](https://api.rubyonrails.org/classes/ActiveRecord/Locking.html) a um modelo.
* `type` - Especifica que o modelo usa [Herança de Tabela Única](https://api.rubyonrails.org/classes/ActiveRecord/Base.html#class-ActiveRecord::Base-label-Single+table+inheritance).
* `(nome_da_associacao)_type` - Armazena o tipo para [associações polimórficas](association_basics.html#polymorphic-associations).
* `(nome_da_tabela)_count` - Usado para armazenar em cache o número de objetos relacionados em associações. Por exemplo, uma coluna `comments_count` em uma classe `Article` que possui muitas instâncias de `Comment` armazenará em cache o número de comentários existentes para cada artigo.

NOTA: Embora esses nomes de colunas sejam opcionais, eles são reservados pelo Active Record. Evite palavras-chave reservadas, a menos que você queira a funcionalidade extra. Por exemplo, `type` é uma palavra-chave reservada usada para designar uma tabela usando Herança de Tabela Única (STI). Se você não estiver usando STI, tente uma palavra-chave análoga como "contexto", que ainda pode descrever com precisão os dados que você está modelando.

Criando Modelos Active Record
-----------------------------

Ao gerar uma aplicação, uma classe abstrata `ApplicationRecord` será criada em `app/models/application_record.rb`. Esta é a classe base para todos os modelos em um aplicativo e é o que transforma uma classe Ruby comum em um modelo Active Record.

Para criar modelos Active Record, faça uma subclasse da classe `ApplicationRecord` e você está pronto:

```ruby
class Product < ApplicationRecord
end
```

Isso criará um modelo `Product`, mapeado para uma tabela `products` no banco de dados. Ao fazer isso, você também terá a capacidade de mapear as colunas de cada linha nessa tabela com os atributos das instâncias do seu modelo. Suponha que a tabela `products` tenha sido criada usando uma instrução SQL (ou uma de suas extensões) como esta:

```sql
CREATE TABLE products (
  id int(11) NOT NULL auto_increment,
  name varchar(255),
  PRIMARY KEY  (id)
);
```

O esquema acima declara uma tabela com duas colunas: `id` e `name`. Cada linha desta tabela representa um determinado produto com esses dois parâmetros. Assim, você poderia escrever código como o seguinte:

```ruby
p = Product.new
p.name = "Algum Livro"
puts p.name # "Algum Livro"
```

Substituindo as Convenções de Nomenclatura
------------------------------------------

E se você precisar seguir uma convenção de nomenclatura diferente ou precisar usar seu aplicativo Rails com um banco de dados legado? Sem problemas, você pode substituir facilmente as convenções padrão.

Como `ApplicationRecord` herda de `ActiveRecord::Base`, os modelos da sua aplicação terão vários métodos úteis disponíveis. Por exemplo, você pode usar o método `ActiveRecord::Base.table_name=` para personalizar o nome da tabela que deve ser usado:

```ruby
class Product < ApplicationRecord
  self.table_name = "meus_produtos"
end
```

Se você fizer isso, precisará definir manualmente o nome da classe que está hospedando os fixtures (`meus_produtos.yml`) usando o método `set_fixture_class` na definição do seu teste:

```ruby
# test/models/product_test.rb
class ProductTest < ActiveSupport::TestCase
  set_fixture_class meus_produtos: Product
  fixtures :meus_produtos
  # ...
end
```

Também é possível substituir a coluna que deve ser usada como chave primária da tabela usando o método `ActiveRecord::Base.primary_key=`:

```ruby
class Product < ApplicationRecord
  self.primary_key = "product_id"
end
```

NOTA: **O Active Record não suporta o uso de colunas de chave primária não primárias chamadas `id`.**

NOTA: Se você tentar criar uma coluna chamada `id` que não seja a chave primária, o Rails lançará um erro durante as migrações, como:
`you can't redefine the primary key column 'id' on 'my_products'.`
`To define a custom primary key, pass { id: false } to create_table.`

CRUD: Lendo e Gravando Dados
---------------------------

CRUD é uma sigla para os quatro verbos que usamos para operar em dados: **C**reate (Criar), **R**ead (Ler), **U**pdate (Atualizar) e **D**elete (Excluir). O Active Record cria automaticamente métodos para permitir que um aplicativo leia e manipule dados armazenados em suas tabelas.

### Criar

Objetos Active Record podem ser criados a partir de um hash, um bloco ou ter seus atributos definidos manualmente após a criação. O método `new` retornará um novo objeto, enquanto `create` retornará o objeto e o salvará no banco de dados.

Por exemplo, dado um modelo `User` com atributos `name` e `occupation`, a chamada do método `create` criará e salvará um novo registro no banco de dados:

```ruby
user = User.create(name: "David", occupation: "Code Artist")
```
Usando o método `new`, um objeto pode ser instanciado sem ser salvo:

```ruby
user = User.new
user.name = "David"
user.occupation = "Code Artist"
```

Uma chamada para `user.save` irá salvar o registro no banco de dados.

Finalmente, se um bloco for fornecido, tanto `create` quanto `new` irão passar o novo
objeto para esse bloco para inicialização, enquanto apenas `create` irá persistir
o objeto resultante no banco de dados:

```ruby
user = User.new do |u|
  u.name = "David"
  u.occupation = "Code Artist"
end
```

### Leitura

Active Record fornece uma API rica para acessar dados em um banco de dados. Abaixo
estão alguns exemplos de diferentes métodos de acesso a dados fornecidos pelo Active Record.

```ruby
# retorna uma coleção com todos os usuários
users = User.all
```

```ruby
# retorna o primeiro usuário
user = User.first
```

```ruby
# retorna o primeiro usuário chamado David
david = User.find_by(name: 'David')
```

```ruby
# encontra todos os usuários chamados David que são Code Artists e ordena por created_at em ordem cronológica reversa
users = User.where(name: 'David', occupation: 'Code Artist').order(created_at: :desc)
```

Você pode aprender mais sobre consultas em um modelo Active Record no guia [Interface de Consulta do Active Record](active_record_querying.html).

### Atualização

Uma vez que um objeto Active Record tenha sido recuperado, seus atributos podem ser modificados
e ele pode ser salvo no banco de dados.

```ruby
user = User.find_by(name: 'David')
user.name = 'Dave'
user.save
```

Uma forma abreviada disso é usar um hash mapeando os nomes dos atributos para o valor desejado, assim:

```ruby
user = User.find_by(name: 'David')
user.update(name: 'Dave')
```

Isso é mais útil ao atualizar vários atributos de uma vez.

Se você deseja atualizar vários registros em massa **sem callbacks ou validações**,
você pode atualizar o banco de dados diretamente usando `update_all`:

```ruby
User.update_all max_login_attempts: 3, must_change_password: true
```

### Exclusão

Da mesma forma, uma vez recuperado, um objeto Active Record pode ser destruído, removendo-o
do banco de dados.

```ruby
user = User.find_by(name: 'David')
user.destroy
```

Se você deseja excluir vários registros em massa, pode usar o método `destroy_by`
ou `destroy_all`:

```ruby
# encontra e exclui todos os usuários chamados David
User.destroy_by(name: 'David')

# exclui todos os usuários
User.destroy_all
```

Validações
-----------

Active Record permite que você valide o estado de um modelo antes de gravá-lo
no banco de dados. Existem vários métodos que você pode usar para verificar seus
modelos e validar se um valor de atributo não está vazio, é único e não
já está no banco de dados, segue um formato específico e muitos outros.

Métodos como `save`, `create` e `update` validam um modelo antes de persisti-lo
no banco de dados. Quando um modelo é inválido, esses métodos retornam `false` e nenhuma
operação de banco de dados é realizada. Todos esses métodos têm uma contraparte com exclamação
(ou seja, `save!`, `create!` e `update!`), que são mais rigorosos, pois
lançam uma exceção `ActiveRecord::RecordInvalid` quando a validação falha.
Um exemplo rápido para ilustrar:

```ruby
class User < ApplicationRecord
  validates :name, presence: true
end
```

```irb
irb> user = User.new
irb> user.save
=> false
irb> user.save!
ActiveRecord::RecordInvalid: Validation failed: Name can’t be blank
```

Você pode aprender mais sobre validações no guia [Validações do Active Record](active_record_validations.html).

Callbacks
---------

Callbacks do Active Record permitem que você anexe código a certos eventos no
ciclo de vida de seus modelos. Isso permite adicionar comportamento aos seus modelos
executando código de forma transparente quando esses eventos ocorrem, como quando você cria um novo
registro, atualiza-o, exclui-o e assim por diante.

```ruby
class User < ApplicationRecord
  after_create :log_new_user

  private
    def log_new_user
      puts "Um novo usuário foi registrado"
    end
end
```

```irb
irb> @user = User.create
Um novo usuário foi registrado
```

Você pode aprender mais sobre callbacks no guia [Callbacks do Active Record](active_record_callbacks.html).

Migrações
----------

O Rails fornece uma maneira conveniente de gerenciar alterações no esquema de um banco de dados por meio
de migrações. As migrações são escritas em uma linguagem específica do domínio e armazenadas
em arquivos que são executados em qualquer banco de dados que o Active Record suporta.

Aqui está uma migração que cria uma nova tabela chamada `publications`:

```ruby
class CreatePublications < ActiveRecord::Migration[7.1]
  def change
    create_table :publications do |t|
      t.string :title
      t.text :description
      t.references :publication_type
      t.references :publisher, polymorphic: true
      t.boolean :single_issue

      t.timestamps
    end
  end
end
```

Observe que o código acima é independente do banco de dados: ele será executado no MySQL,
PostgreSQL, SQLite e outros.

O Rails mantém o controle das migrações que foram aplicadas ao banco de dados e as armazena
em uma tabela adjacente no mesmo banco de dados chamada `schema_migrations`.
Para executar a migração e criar a tabela, você deve executar `bin/rails db:migrate`,
e para reverter e excluir a tabela, `bin/rails db:rollback`.

Você pode aprender mais sobre migrações no [guia de Migrações do Active Record](active_record_migrations.html).

Associações
------------

As associações do Active Record permitem que você defina relacionamentos entre modelos.
As associações podem ser usadas para descrever relacionamentos um-para-um, um-para-muitos e muitos-para-muitos.
Por exemplo, um relacionamento como "Autor tem muitos Livros" pode ser definido da seguinte forma:

```ruby
class Author < ApplicationRecord
  has_many :books
end
```

A classe Author agora possui métodos para adicionar e remover livros de um autor, e muito mais.

Você pode aprender mais sobre associações no [guia de Associações do Active Record](association_basics.html).
[MVC]: https://en.wikipedia.org/wiki/Model%E2%80%93view%E2%80%93controller
[MFAR]: https://www.martinfowler.com/eaaCatalog/activeRecord.html
[ORM]: https://en.wikipedia.org/wiki/Object-relational_mapping
[sqlcourse]: https://www.khanacademy.org/computing/computer-programming/sql
[rdbmsinfo]: https://www.devart.com/what-is-rdbms/
