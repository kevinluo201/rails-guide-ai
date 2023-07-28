**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 311d5225fa32d069369256501f31c507
Migrações do Active Record
========================

As migrações são um recurso do Active Record que permite evoluir o esquema do seu banco de dados ao longo do tempo. Em vez de escrever modificações de esquema em SQL puro, as migrações permitem que você use uma DSL Ruby para descrever as alterações em suas tabelas.

Após ler este guia, você saberá:

* Os geradores que você pode usar para criá-las.
* Os métodos que o Active Record fornece para manipular seu banco de dados.
* Os comandos do Rails que manipulam as migrações e o esquema.
* Como as migrações se relacionam com o `schema.rb`.

--------------------------------------------------------------------------------

Visão geral das migrações
------------------

As migrações são uma maneira conveniente de alterar o esquema do seu banco de dados ao longo do tempo de forma consistente. Elas usam uma DSL Ruby para que você não precise escrever SQL manualmente, permitindo que seu esquema e alterações sejam independentes do banco de dados.

Você pode pensar em cada migração como uma nova 'versão' do banco de dados. Um esquema começa vazio e cada migração o modifica para adicionar ou remover tabelas, colunas ou entradas. O Active Record sabe como atualizar seu esquema ao longo dessa linha do tempo, levando-o do ponto em que está na história para a versão mais recente. O Active Record também atualizará seu arquivo `db/schema.rb` para corresponder à estrutura atualizada do seu banco de dados.

Aqui está um exemplo de uma migração:

```ruby
class CreateProducts < ActiveRecord::Migration[7.1]
  def change
    create_table :products do |t|
      t.string :name
      t.text :description

      t.timestamps
    end
  end
end
```

Essa migração adiciona uma tabela chamada `products` com uma coluna de string chamada `name` e uma coluna de texto chamada `description`. Uma coluna de chave primária chamada `id` também será adicionada implicitamente, pois é a chave primária padrão para todos os modelos do Active Record. A macro `timestamps` adiciona duas colunas, `created_at` e `updated_at`. Essas colunas especiais são gerenciadas automaticamente pelo Active Record se existirem.

Observe que definimos a alteração que queremos que ocorra no futuro. Antes que essa migração seja executada, não haverá tabela. Depois, a tabela existirá. O Active Record também sabe reverter essa migração: se desfazermos essa migração, a tabela será removida.

Em bancos de dados que suportam transações com declarações que alteram o esquema, cada migração é envolvida em uma transação. Se o banco de dados não suportar isso, quando uma migração falhar, as partes que tiverem sucesso não serão revertidas. Você terá que desfazer manualmente as alterações feitas.

NOTA: Existem certas consultas que não podem ser executadas dentro de uma transação. Se o seu adaptador suportar transações DDL, você pode usar `disable_ddl_transaction!` para desabilitá-las para uma única migração.

### Tornando o Irreversível Possível

Se você deseja que uma migração faça algo que o Active Record não saiba reverter, você pode usar `reversible`:

```ruby
class ChangeProductsPrice < ActiveRecord::Migration[7.1]
  def change
    reversible do |direction|
      change_table :products do |t|
        direction.up   { t.change :price, :string }
        direction.down { t.change :price, :integer }
      end
    end
  end
end
```

Essa migração alterará o tipo da coluna `price` para uma string ou de volta para um inteiro quando a migração for revertida. Observe o bloco sendo passado para `direction.up` e `direction.down`, respectivamente.

Alternativamente, você pode usar `up` e `down` em vez de `change`:

```ruby
class ChangeProductsPrice < ActiveRecord::Migration[7.1]
  def up
    change_table :products do |t|
      t.change :price, :string
    end
  end

  def down
    change_table :products do |t|
      t.change :price, :integer
    end
  end
end
```

INFO: Mais sobre [`reversible`](#using-reversible) posteriormente.

Gerando Migrações
----------------------

### Criando uma Migração Independente

As migrações são armazenadas como arquivos no diretório `db/migrate`, um para cada classe de migração. O nome do arquivo segue o formato `YYYYMMDDHHMMSS_create_products.rb`, ou seja, um carimbo de data e hora UTC identificando a migração, seguido de um sublinhado e do nome da migração. O nome da classe de migração (versão em CamelCase) deve corresponder à parte posterior do nome do arquivo. Por exemplo, `20080906120000_create_products.rb` deve definir a classe `CreateProducts` e `20080906120001_add_details_to_products.rb` deve definir `AddDetailsToProducts`. O Rails usa esse carimbo de data e hora para determinar qual migração deve ser executada e em que ordem, portanto, se você estiver copiando uma migração de outro aplicativo ou gerando um arquivo você mesmo, esteja ciente de sua posição na ordem.

É claro que calcular carimbos de data e hora não é divertido, então o Active Record fornece um gerador para fazer isso por você:

```bash
$ bin/rails generate migration AddPartNumberToProducts
```
Isso criará uma migração vazia com o nome apropriado:

```ruby
class AddPartNumberToProducts < ActiveRecord::Migration[7.1]
  def change
  end
end
```

Este gerador pode fazer muito mais do que adicionar um carimbo de data/hora ao nome do arquivo. Com base em convenções de nomenclatura e argumentos adicionais (opcionais), ele também pode começar a preencher a migração.

### Adicionando novas colunas

Se o nome da migração estiver na forma "AddColumnToTable" ou "RemoveColumnFromTable" e for seguido por uma lista de nomes e tipos de coluna, uma migração contendo as instruções [`add_column`][] e [`remove_column`][] apropriadas será criada.

```bash
$ bin/rails generate migration AddPartNumberToProducts part_number:string
```

Isso gerará a seguinte migração:

```ruby
class AddPartNumberToProducts < ActiveRecord::Migration[7.1]
  def change
    add_column :products, :part_number, :string
  end
end
```

Se você quiser adicionar um índice na nova coluna, também pode fazer isso.

```bash
$ bin/rails generate migration AddPartNumberToProducts part_number:string:index
```

Isso gerará as instruções [`add_column`][] e [`add_index`][] apropriadas:

```ruby
class AddPartNumberToProducts < ActiveRecord::Migration[7.1]
  def change
    add_column :products, :part_number, :string
    add_index :products, :part_number
  end
end
```

Você **não** está limitado a uma coluna gerada magicamente. Por exemplo:

```bash
$ bin/rails generate migration AddDetailsToProducts part_number:string price:decimal
```

Gerará uma migração de esquema que adiciona duas colunas adicionais à tabela `products`.

```ruby
class AddDetailsToProducts < ActiveRecord::Migration[7.1]
  def change
    add_column :products, :part_number, :string
    add_column :products, :price, :decimal
  end
end
```

### Removendo colunas

Da mesma forma, você pode gerar uma migração para remover uma coluna a partir da linha de comando:

```bash
$ bin/rails generate migration RemovePartNumberFromProducts part_number:string
```

Isso gera as instruções [`remove_column`][] apropriadas:

```ruby
class RemovePartNumberFromProducts < ActiveRecord::Migration[7.1]
  def change
    remove_column :products, :part_number, :string
  end
end
```

### Criando novas tabelas

Se o nome da migração estiver na forma "CreateXXX" e for seguido por uma lista de nomes e tipos de coluna, uma migração criando a tabela XXX com as colunas listadas será gerada. Por exemplo:

```bash
$ bin/rails generate migration CreateProducts name:string part_number:string
```

gera

```ruby
class CreateProducts < ActiveRecord::Migration[7.1]
  def change
    create_table :products do |t|
      t.string :name
      t.string :part_number

      t.timestamps
    end
  end
end
```

Como sempre, o que foi gerado para você é apenas um ponto de partida. Você pode adicionar ou remover o que quiser editando o arquivo `db/migrate/YYYYMMDDHHMMSS_add_details_to_products.rb`.

### Criando associações usando referências

Além disso, o gerador aceita o tipo de coluna como `references` (também disponível como `belongs_to`). Por exemplo,

```bash
$ bin/rails generate migration AddUserRefToProducts user:references
```

gera a seguinte chamada [`add_reference`][]:

```ruby
class AddUserRefToProducts < ActiveRecord::Migration[7.1]
  def change
    add_reference :products, :user, foreign_key: true
  end
end
```

Essa migração criará uma coluna `user_id`. As [referências](#references) são uma forma abreviada de criar colunas, índices, chaves estrangeiras ou até mesmo colunas de associação polimórfica.

Também há um gerador que produzirá tabelas de junção se `JoinTable` fizer parte do nome:

```bash
$ bin/rails generate migration CreateJoinTableCustomerProduct customer product
```

produzirá a seguinte migração:

```ruby
class CreateJoinTableCustomerProduct < ActiveRecord::Migration[7.1]
  def change
    create_join_table :customers, :products do |t|
      # t.index [:customer_id, :product_id]
      # t.index [:product_id, :customer_id]
    end
  end
end
```


### Geradores de modelo

Os geradores de modelo, recurso e scaffold criarão migrações apropriadas para adicionar um novo modelo. Esta migração já conterá instruções para criar a tabela relevante. Se você informar ao Rails quais colunas deseja, também serão criadas instruções para adicionar essas colunas. Por exemplo, execute:

```bash
$ bin/rails generate model Product name:string description:text
```

Isso criará uma migração que se parece com isso:

```ruby
class CreateProducts < ActiveRecord::Migration[7.1]
  def change
    create_table :products do |t|
      t.string :name
      t.text :description

      t.timestamps
    end
  end
end
```

Você pode adicionar quantos pares de nome de coluna/tipo desejar.

### Passando modificadores

Alguns [modificadores de tipo](#column-modifiers) comumente usados podem ser passados diretamente na linha de comando. Eles são cercados por chaves e seguem o tipo de campo:

Por exemplo, execute:

```bash
$ bin/rails generate migration AddDetailsToProducts 'price:decimal{5,2}' supplier:references{polymorphic}
```

produzirá uma migração que se parece com isso:

```ruby
class AddDetailsToProducts < ActiveRecord::Migration[7.1]
  def change
    add_column :products, :price, :decimal, precision: 5, scale: 2
    add_reference :products, :supplier, polymorphic: true
  end
end
```

DICA: Dê uma olhada na saída de ajuda dos geradores (`bin/rails generate --help`) para obter mais detalhes.

Escrevendo Migrações
------------------

Depois de criar sua migração usando um dos geradores, é hora de começar a trabalhar!

### Criando uma tabela

O método [`create_table`][] é um dos mais fundamentais, mas na maioria das vezes será gerado para você ao usar um gerador de modelo, recurso ou scaffold. Um uso típico seria
```ruby
create_table :products do |t|
  t.string :name
end
```

Este método cria uma tabela `products` com uma coluna chamada `name`.

Por padrão, `create_table` criará implicitamente uma chave primária chamada `id` para você. Você pode alterar o nome da coluna com a opção `:primary_key` ou, se não quiser uma chave primária, pode passar a opção `id: false`.

Se você precisar passar opções específicas do banco de dados, pode colocar um fragmento SQL na opção `:options`. Por exemplo:

```ruby
create_table :products, options: "ENGINE=BLACKHOLE" do |t|
  t.string :name, null: false
end
```

Isso irá adicionar `ENGINE=BLACKHOLE` à instrução SQL usada para criar a tabela.

Um índice pode ser criado nas colunas criadas dentro do bloco `create_table` passando `index: true` ou um hash de opções para a opção `:index`:

```ruby
create_table :users do |t|
  t.string :name, index: true
  t.string :email, index: { unique: true, name: 'unique_emails' }
end
```

Também é possível passar a opção `:comment` com qualquer descrição para a tabela que será armazenada no próprio banco de dados e pode ser visualizada com ferramentas de administração de banco de dados, como o MySQL Workbench ou o PgAdmin III. É altamente recomendável especificar comentários em migrações para aplicativos com bancos de dados grandes, pois isso ajuda as pessoas a entender o modelo de dados e gerar documentação. Atualmente, apenas os adaptadores MySQL e PostgreSQL suportam comentários.


### Criando uma Tabela de Associação

O método de migração [`create_join_table`][] cria uma tabela de associação HABTM (has and belongs to many). Um uso típico seria:

```ruby
create_join_table :products, :categories
```

Esta migração criará uma tabela `categories_products` com duas colunas chamadas `category_id` e `product_id`.

Por padrão, essas colunas têm a opção `:null` definida como `false`, o que significa que você **deve** fornecer um valor para salvar um registro nesta tabela. Isso pode ser substituído especificando a opção `:column_options`:

```ruby
create_join_table :products, :categories, column_options: { null: true }
```

Por padrão, o nome da tabela de associação vem da união dos dois primeiros argumentos fornecidos para `create_join_table`, em ordem alfabética.

Para personalizar o nome da tabela, forneça a opção `:table_name`:

```ruby
create_join_table :products, :categories, table_name: :categorization
```

Isso garante que o nome da tabela de associação seja `categorization`, conforme solicitado.

Além disso, `create_join_table` aceita um bloco, que você pode usar para adicionar índices (que não são criados por padrão) ou quaisquer colunas adicionais que desejar.

```ruby
create_join_table :products, :categories do |t|
  t.index :product_id
  t.index :category_id
end
```


### Alterando Tabelas

Se você deseja alterar uma tabela existente no local, existe o [`change_table`][].

Ele é usado de maneira semelhante ao `create_table`, mas o objeto fornecido dentro do bloco tem acesso a várias funções especiais, por exemplo:

```ruby
change_table :products do |t|
  t.remove :description, :name
  t.string :part_number
  t.index :part_number
  t.rename :upccode, :upc_code
end
```

Esta migração removerá as colunas `description` e `name`, criará uma nova coluna de string chamada `part_number` e adicionará um índice nela. Por fim, renomeia a coluna `upccode` para `upc_code`.


### Alterando Colunas

Semelhante aos métodos `remove_column` e `add_column` que cobrimos anteriormente, o Rails também fornece o método de migração [`change_column`][].

```ruby
change_column :products, :part_number, :text
```

Isso altera a coluna `part_number` na tabela de produtos para ser um campo `:text`.

NOTA: O comando `change_column` é **irreversível**. Você deve fornecer sua própria migração `reversible`, como discutimos anteriormente.

Além do `change_column`, os métodos [`change_column_null`][] e [`change_column_default`][] são usados especificamente para alterar uma restrição de nulo e valores padrão de uma coluna.

```ruby
change_column_null :products, :name, false
change_column_default :products, :approved, from: true, to: false
```

Isso define o campo `:name` em produtos como uma coluna `NOT NULL` e o valor padrão do campo `:approved` de true para false. Ambas as alterações serão aplicadas apenas a transações futuras, nenhum registro existente se aplica.

Ao definir a restrição de nulo como true, isso significa que a coluna aceitará um valor nulo, caso contrário, a restrição `NOT NULL` é aplicada e um valor deve ser passado para persistir o registro no banco de dados.

NOTA: Você também poderia escrever a migração `change_column_default` acima como `change_column_default :products, :approved, false`, mas, ao contrário do exemplo anterior, isso tornaria sua migração irreversível.


### Modificadores de Coluna

Modificadores de coluna podem ser aplicados ao criar ou alterar uma coluna:

* `comment`      Adiciona um comentário para a coluna.
* `collation`    Especifica a collation para uma coluna `string` ou `text`.
* `default`      Permite definir um valor padrão na coluna. Observe que, se você estiver usando um valor dinâmico (como uma data), o padrão será calculado apenas na primeira vez (ou seja, na data em que a migração for aplicada). Use `nil` para `NULL`.
* `limit`        Define o número máximo de caracteres para uma coluna `string` e o número máximo de bytes para colunas `text/binary/integer`.
* `null`         Permite ou impede valores `NULL` na coluna.
* `precision`    Especifica a precisão para colunas `decimal/numeric/datetime/time`.
* `scale`        Especifica a escala para colunas `decimal` e `numeric`, representando o número de dígitos após o ponto decimal.

NOTA: Para `add_column` ou `change_column`, não há opção para adicionar índices.
Eles devem ser adicionados separadamente usando `add_index`.

Alguns adaptadores podem suportar opções adicionais; consulte a documentação específica do adaptador
para obter mais informações.

NOTA: `null` e `default` não podem ser especificados via linha de comando ao gerar
migrações.

### Referências

O método `add_reference` permite a criação de uma coluna com o nome apropriado
que atua como a conexão entre uma ou mais associações.

```ruby
add_reference :users, :role
```

Esta migração criará uma coluna `role_id` na tabela de usuários. Ela também cria um
índice para esta coluna, a menos que explicitamente informado o contrário com a
opção `index: false`.

INFO: Veja também o guia [Associações do Active Record][] para saber mais.

O método `add_belongs_to` é um alias de `add_reference`.

```ruby
add_belongs_to :taggings, :taggable, polymorphic: true
```

A opção `polymorphic` criará duas colunas na tabela de taggings que podem
ser usadas para associações polimórficas: `taggable_type` e `taggable_id`.

INFO: Veja este guia para saber mais sobre [associações polimórficas][].

Uma chave estrangeira pode ser criada com a opção `foreign_key`.

```ruby
add_reference :users, :role, foreign_key: true
```

Para mais opções de `add_reference`, visite a [documentação da API](https://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html#method-i-add_reference).

Referências também podem ser removidas:

```ruby
remove_reference :products, :user, foreign_key: true, index: false
```

[Associações do Active Record]: association_basics.html
[associações polimórficas]: association_basics.html#associações-polimórficas

### Chaves Estrangeiras

Embora não seja obrigatório, você pode querer adicionar restrições de chave estrangeira para
[garantir a integridade referencial](#active-record-e-integridade-referencial).

```ruby
add_foreign_key :articles, :authors
```

Esta chamada [`add_foreign_key`][] adiciona uma nova restrição à tabela `articles`.
A restrição garante que uma linha na tabela `authors` exista onde
a coluna `id` corresponda ao `articles.author_id`.

Se o nome da coluna `from_table` não puder ser derivado do nome da `to_table`,
você pode usar a opção `:column`. Use a opção `:primary_key` se a
chave primária referenciada não for `:id`.

Por exemplo, para adicionar uma chave estrangeira em `articles.reviewer` referenciando `authors.email`:

```ruby
add_foreign_key :articles, :authors, column: :reviewer, primary_key: :email
```

Isso adicionará uma restrição à tabela `articles` que garante que uma linha na
tabela `authors` exista onde a coluna `email` corresponda ao campo `articles.reviewer`.

Várias outras opções, como `name`, `on_delete`, `if_not_exists`, `validate`,
e `deferrable` são suportadas por `add_foreign_key`.

Chaves estrangeiras também podem ser removidas usando [`remove_foreign_key`][]:

```ruby
# deixe o Active Record descobrir o nome da coluna
remove_foreign_key :accounts, :branches

# remova a chave estrangeira para uma coluna específica
remove_foreign_key :accounts, column: :owner_id
```

NOTA: O Active Record suporta apenas chaves estrangeiras de coluna única. `execute` e
`structure.sql` são necessários para usar chaves estrangeiras compostas. Veja
[Despejo de Esquema e Você](#despejo-de-esquema-e-você).

### Quando os Helpers não são Suficientes

Se os helpers fornecidos pelo Active Record não forem suficientes, você pode usar o método [`execute`][]
para executar SQL arbitrário:

```ruby
Product.connection.execute("UPDATE products SET price = 'free' WHERE 1=1")
```

Para mais detalhes e exemplos de métodos individuais, consulte a documentação da API.

Em particular, a documentação para
[`ActiveRecord::ConnectionAdapters::SchemaStatements`][], que fornece os métodos disponíveis nos métodos `change`, `up` e `down`.

Para os métodos disponíveis em relação ao objeto retornado por `create_table`, consulte [`ActiveRecord::ConnectionAdapters::TableDefinition`][].

E para o objeto retornado por `change_table`, consulte [`ActiveRecord::ConnectionAdapters::Table`][].


### Usando o Método `change`

O método `change` é a forma principal de escrever migrações. Ele funciona para a
maioria dos casos em que o Active Record sabe como reverter automaticamente as ações de uma migração. Abaixo estão algumas das ações que o `change` suporta:

* [`add_check_constraint`][]
* [`add_column`][]
* [`add_foreign_key`][]
* [`add_index`][]
* [`add_reference`][]
* [`add_timestamps`][]
* [`change_column_comment`][] (deve fornecer as opções `:from` e `:to`)
* [`change_column_default`][] (deve fornecer as opções `:from` e `:to`)
* [`change_column_null`][]
* [`change_table_comment`][] (deve fornecer as opções `:from` e `:to`)
* [`create_join_table`][]
* [`create_table`][]
* `disable_extension`
* [`drop_join_table`][]
* [`drop_table`][] (deve fornecer um bloco)
* `enable_extension`
* [`remove_check_constraint`][] (deve fornecer uma expressão de restrição)
* [`remove_column`][] (deve fornecer um tipo)
* [`remove_columns`][] (deve fornecer a opção `:type`)
* [`remove_foreign_key`][] (deve fornecer uma segunda tabela)
* [`remove_index`][]
* [`remove_reference`][]
* [`remove_timestamps`][]
* [`rename_column`][]
* [`rename_index`][]
* [`rename_table`][]

[`change_table`][] também é reversível, desde que o bloco apenas chame
operações reversíveis como as listadas acima.

`remove_column` é reversível se você fornecer o tipo de coluna como o terceiro
argumento. Forneça também as opções originais da coluna, caso contrário, o Rails não poderá
recriar a coluna exatamente ao reverter:

```ruby
remove_column :posts, :slug, :string, null: false, default: ''
```

Se você precisar usar outros métodos, deve usar `reversible`
ou escrever os métodos `up` e `down` em vez de usar o método `change`.
### Usando `reversible`

Migrações complexas podem exigir processamento que o Active Record não sabe como reverter. Você pode usar [`reversible`][] para especificar o que fazer ao executar uma migração e o que fazer ao revertê-la. Por exemplo:

```ruby
class ExampleMigration < ActiveRecord::Migration[7.1]
  def change
    create_table :distributors do |t|
      t.string :zipcode
    end

    reversible do |direction|
      direction.up do
        # criar uma visualização de distribuidores
        execute <<-SQL
          CREATE VIEW distributors_view AS
          SELECT id, zipcode
          FROM distributors;
        SQL
      end
      direction.down do
        execute <<-SQL
          DROP VIEW distributors_view;
        SQL
      end
    end

    add_column :users, :home_page_url, :string
    rename_column :users, :email, :email_address
  end
end
```

Usar `reversible` garantirá que as instruções sejam executadas na ordem correta também. Se a migração de exemplo anterior for revertida, o bloco `down` será executado após a remoção da coluna `home_page_url` e a renomeação da coluna `email_address` e imediatamente antes da tabela `distributors` ser excluída.


### Usando os métodos `up`/`down`

Você também pode usar o estilo antigo de migração usando os métodos `up` e `down` em vez do método `change`.

O método `up` deve descrever a transformação que você deseja fazer em seu esquema, e o método `down` da sua migração deve reverter as transformações feitas pelo método `up`. Em outras palavras, o esquema do banco de dados não deve ser alterado se você fizer um `up` seguido de um `down`.

Por exemplo, se você criar uma tabela no método `up`, você deve excluí-la no método `down`. É aconselhável realizar as transformações na ordem exata em que foram feitas no método `up`. O exemplo na seção `reversible` é equivalente a:

```ruby
class ExampleMigration < ActiveRecord::Migration[7.1]
  def up
    create_table :distributors do |t|
      t.string :zipcode
    end

    # criar uma visualização de distribuidores
    execute <<-SQL
      CREATE VIEW distributors_view AS
      SELECT id, zipcode
      FROM distributors;
    SQL

    add_column :users, :home_page_url, :string
    rename_column :users, :email, :email_address
  end

  def down
    rename_column :users, :email_address, :email
    remove_column :users, :home_page_url

    execute <<-SQL
      DROP VIEW distributors_view;
    SQL

    drop_table :distributors
  end
end
```

### Lançando um erro para evitar reversões

Às vezes, sua migração fará algo que é simplesmente irreversível; por exemplo, pode destruir alguns dados.

Nesses casos, você pode lançar `ActiveRecord::IrreversibleMigration` no bloco `down`.

Se alguém tentar reverter sua migração, uma mensagem de erro será exibida informando que não é possível fazê-lo.

### Revertendo migrações anteriores

Você pode usar a capacidade do Active Record de reverter migrações usando o método [`revert`][]:

```ruby
require_relative "20121212123456_example_migration"

class FixupExampleMigration < ActiveRecord::Migration[7.1]
  def change
    revert ExampleMigration

    create_table(:apples) do |t|
      t.string :variety
    end
  end
end
```

O método `revert` também aceita um bloco de instruções para reverter. Isso pode ser útil para reverter partes selecionadas de migrações anteriores.

Por exemplo, vamos imaginar que `ExampleMigration` seja confirmada e posteriormente seja decidido que uma visualização de Distributors não é mais necessária.

```ruby
class DontUseDistributorsViewMigration < ActiveRecord::Migration[7.1]
  def change
    revert do
      # código copiado da ExampleMigration
      reversible do |direction|
        direction.up do
          # criar uma visualização de distribuidores
          execute <<-SQL
            CREATE VIEW distributors_view AS
            SELECT id, zipcode
            FROM distributors;
          SQL
        end
        direction.down do
          execute <<-SQL
            DROP VIEW distributors_view;
          SQL
        end
      end

      # O restante da migração estava correto
    end
  end
end
```

A mesma migração também poderia ter sido escrita sem usar `revert`, mas isso teria envolvido alguns passos adicionais:

1. Inverter a ordem de `create_table` e `reversible`.
2. Substituir `create_table` por `drop_table`.
3. Por fim, substituir `up` por `down` e vice-versa.

Isso é tudo tratado pelo `revert`.


Executando Migrações
------------------

O Rails fornece um conjunto de comandos para executar determinados conjuntos de migrações.

O primeiro comando relacionado a migrações do Rails que você provavelmente usará será
`bin/rails db:migrate`. Em sua forma mais básica, ele simplesmente executa o método `change` ou `up`
para todas as migrações que ainda não foram executadas. Se não houver
migrações desse tipo, ele será encerrado. Ele executará essas migrações em ordem com base
na data da migração.

Observe que a execução do comando `db:migrate` também invoca o comando `db:schema:dump`,
que atualizará seu arquivo `db/schema.rb` para corresponder à estrutura do seu banco de dados.

Se você especificar uma versão de destino, o Active Record executará as migrações necessárias
(change, up, down) até atingir a versão especificada. A versão
é o prefixo numérico no nome do arquivo de migração. Por exemplo, para migrar
para a versão 20080906120000, execute:
```bash
$ bin/rails db:migrate VERSION=20080906120000
```

Se a versão 20080906120000 for maior que a versão atual (ou seja, estiver migrando para cima), isso executará o método `change` (ou `up`) em todas as migrações até e incluindo a versão 20080906120000 e não executará nenhuma migração posterior. Se estiver migrando para baixo, isso executará o método `down` em todas as migrações até, mas não incluindo, a versão 20080906120000.

### Desfazendo

Uma tarefa comum é desfazer a última migração. Por exemplo, se você cometeu um erro nela e deseja corrigi-lo. Em vez de procurar o número da versão associado à migração anterior, você pode executar:

```bash
$ bin/rails db:rollback
```

Isso desfará a última migração, revertendo o método `change` ou executando o método `down`. Se você precisar desfazer várias migrações, pode fornecer um parâmetro `STEP`:

```bash
$ bin/rails db:rollback STEP=3
```

As últimas 3 migrações serão desfeitas.

O comando `db:migrate:redo` é um atalho para desfazer e, em seguida, migrar novamente. Assim como o comando `db:rollback`, você pode usar o parâmetro `STEP` se precisar voltar mais de uma versão, por exemplo:

```bash
$ bin/rails db:migrate:redo STEP=3
```

Nenhum desses comandos do Rails faz algo que você não possa fazer com `db:migrate`. Eles estão lá para conveniência, pois você não precisa especificar explicitamente a versão para migrar.

### Configurando o Banco de Dados

O comando `bin/rails db:setup` criará o banco de dados, carregará o esquema e o inicializará com os dados de seed.

### Resetando o Banco de Dados

O comando `bin/rails db:reset` excluirá o banco de dados e o configurará novamente. Isso é funcionalmente equivalente a `bin/rails db:drop db:setup`.

NOTA: Isso não é o mesmo que executar todas as migrações. Ele usará apenas o conteúdo do arquivo `db/schema.rb` ou `db/structure.sql` atual. Se uma migração não puder ser desfeita, `bin/rails db:reset` pode não ajudar. Para obter mais informações sobre como fazer o dumping do esquema, consulte a seção [Dumping do Esquema][].

[Dumping do Esquema]: #dumping-do-esquema

### Executando Migrações Específicas

Se você precisar executar uma migração específica para cima ou para baixo, os comandos `db:migrate:up` e `db:migrate:down` farão isso. Basta especificar a versão apropriada e a migração correspondente terá seu método `change`, `up` ou `down` invocado, por exemplo:

```bash
$ bin/rails db:migrate:up VERSION=20080906120000
```

Ao executar este comando, o método `change` (ou o método `up`) será executado para a migração com a versão "20080906120000".

Primeiro, este comando verificará se a migração existe e se já foi executada e não fará nada se for o caso.

Se a versão especificada não existir, o Rails lançará uma exceção.

```bash
$ bin/rails db:migrate VERSION=zomg
rails aborted!
ActiveRecord::UnknownMigrationVersionError:

Nenhuma migração com o número de versão zomg.
```

### Executando Migrações em Diferentes Ambientes

Por padrão, executar `bin/rails db:migrate` será executado no ambiente `development`.

Para executar migrações em outro ambiente, você pode especificá-lo usando a variável de ambiente `RAILS_ENV` ao executar o comando. Por exemplo, para executar migrações no ambiente `test`, você pode executar:

```bash
$ bin/rails db:migrate RAILS_ENV=test
```

### Alterando a Saída das Migrações

Por padrão, as migrações informam exatamente o que estão fazendo e quanto tempo levaram. Uma migração que cria uma tabela e adiciona um índice pode produzir uma saída como esta:

```
==  CreateProducts: migrating =================================================
-- create_table(:products)
   -> 0.0028s
==  CreateProducts: migrated (0.0028s) ========================================
```

Vários métodos são fornecidos nas migrações que permitem controlar tudo isso:

| Método                     | Propósito
| -------------------------- | -------
| [`suppress_messages`][]    | Recebe um bloco como argumento e suprime qualquer saída gerada pelo bloco.
| [`say`][]                  | Recebe um argumento de mensagem e a exibe como está. Um segundo argumento booleano pode ser passado para especificar se deve ser recuado ou não.
| [`say_with_time`][]        | Exibe texto juntamente com quanto tempo levou para executar seu bloco. Se o bloco retornar um número inteiro, ele assume que é o número de linhas afetadas.

Por exemplo, considere a seguinte migração:

```ruby
class CreateProducts < ActiveRecord::Migration[7.1]
  def change
    suppress_messages do
      create_table :products do |t|
        t.string :name
        t.text :description
        t.timestamps
      end
    end

    say "Created a table"

    suppress_messages { add_index :products, :name }
    say "and an index!", true

    say_with_time 'Waiting for a while' do
      sleep 10
      250
    end
  end
end
```

Isso gerará a seguinte saída:

```
==  CreateProducts: migrando =================================================
-- Criada uma tabela
   -> e um índice!
-- Aguardando um pouco
   -> 10.0013s
   -> 250 linhas
==  CreateProducts: migrado (10.0054s) =======================================
```

Se você não quiser que o Active Record exiba nada, executar `bin/rails db:migrate
VERBOSE=false` suprimirá toda a saída.


Alterando Migrações Existente
----------------------------

Ocasionalmente, você pode cometer um erro ao escrever uma migração. Se você já
executou a migração, não pode simplesmente editar a migração e executar a
migração novamente: o Rails acredita que já executou a migração e, portanto, não fará
nada quando você executar `bin/rails db:migrate`. Você deve reverter a migração (por
exemplo, com `bin/rails db:rollback`), editar sua migração e, em seguida, executar
`bin/rails db:migrate` para executar a versão corrigida.

Em geral, editar migrações existentes não é uma boa ideia. Você estará
criando trabalho extra para você e seus colegas e causando grandes problemas
se a versão existente da migração já tiver sido executada em máquinas de produção.

Em vez disso, você deve escrever uma nova migração que execute as alterações
necessárias. Editar uma migração recém-gerada que ainda não foi
comprometida no controle de versão (ou, mais geralmente, que ainda não foi propagada
além de sua máquina de desenvolvimento) é relativamente inofensivo.

O método `revert` pode ser útil ao escrever uma nova migração para desfazer migrações
anteriores total ou parcialmente (consulte [Desfazendo Migrações Anteriores][] acima).

[Desfazendo Migrações Anteriores]: #desfazendo-migrações-anteriores

Despejo de Esquema e Você
----------------------

### Para que servem os Arquivos de Esquema?

As migrações, por mais poderosas que sejam, não são a fonte autoritativa do esquema do seu
banco de dados. **Seu banco de dados continua sendo a fonte da verdade.**

Por padrão, o Rails gera `db/schema.rb`, que tenta capturar o estado atual do seu
esquema de banco de dados.

Normalmente, é mais rápido e menos propenso a erros criar uma nova instância do seu
banco de dados da aplicação carregando o arquivo de esquema via `bin/rails db:schema:load`
do que reproduzir todo o histórico de migração.
[Migrações antigas][] podem falhar ao serem aplicadas corretamente se essas migrações usarem
dependências externas em mudança ou dependerem de código de aplicativo que evolui separadamente
de suas migrações.

Os arquivos de esquema também são úteis se você quiser dar uma olhada rápida nos atributos de um
objeto Active Record. Essas informações não estão no código do modelo e são
frequentemente espalhadas por várias migrações, mas as informações são resumidas
de forma clara no arquivo de esquema.

[Migrações antigas]: #migrações-antigas

### Tipos de Despejo de Esquema

O formato do despejo de esquema gerado pelo Rails é controlado pela
configuração [`config.active_record.schema_format`][] definida em
`config/application.rb`. Por padrão, o formato é `:ruby`, ou alternativamente pode
ser definido como `:sql`.

#### Usando o despejo de esquema `:ruby` padrão

Quando `:ruby` é selecionado, o esquema é armazenado em `db/schema.rb`. Se você olhar
esse arquivo, verá que ele se parece muito com uma única migração grande:

```ruby
ActiveRecord::Schema[7.1].define(version: 2008_09_06_171750) do
  create_table "authors", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "products", force: true do |t|
    t.string   "name"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "part_number"
  end
end
```

De muitas maneiras, é exatamente isso que é. Esse arquivo é criado inspecionando o
banco de dados e expressando sua estrutura usando `create_table`, `add_index` e assim por diante.

#### Usando o despejo de esquema `:sql`

No entanto, `db/schema.rb` não pode expressar tudo o que seu banco de dados pode suportar, como
triggers, sequências, procedimentos armazenados, etc.

Embora as migrações possam usar `execute` para criar construções de banco de dados que não são
suportadas pelo DSL de migração Ruby, essas construções podem não ser capazes de serem
reconstituídas pelo despejo de esquema.

Se você estiver usando recursos como esses, deverá definir o formato do esquema como `:sql`
para obter um arquivo de esquema preciso que seja útil para criar novas instâncias do banco de dados.

Quando o formato do esquema é definido como `:sql`, a estrutura do banco de dados será despejada
usando uma ferramenta específica do banco de dados em `db/structure.sql`. Por exemplo, para
PostgreSQL, é usado o utilitário `pg_dump`. Para MySQL e MariaDB, esse arquivo conterá a saída de
`SHOW CREATE TABLE` para as várias tabelas.

Para carregar o esquema de `db/structure.sql`, execute `bin/rails db:schema:load`.
O carregamento desse arquivo é feito executando as instruções SQL que ele contém. Por
definição, isso criará uma cópia perfeita da estrutura do banco de dados.


### Despejo de Esquema e Controle de Versão
Como os arquivos de esquema são comumente usados para criar novos bancos de dados, é altamente recomendável que você faça o check-in do seu arquivo de esquema no controle de versão.

Conflitos de mesclagem podem ocorrer no seu arquivo de esquema quando duas ramificações modificam o esquema. Para resolver esses conflitos, execute `bin/rails db:migrate` para regenerar o arquivo de esquema.

INFO: Aplicativos Rails recém-gerados já terão a pasta de migrações incluída na árvore do git, então tudo o que você precisa fazer é garantir que adicione quaisquer novas migrações que você adicionar e as confirme.

Active Record e Integridade Referencial
---------------------------------------

O modo Active Record afirma que a inteligência pertence aos seus modelos, não ao banco de dados. Como tal, recursos como triggers ou constraints, que empurram parte dessa inteligência de volta para o banco de dados, não são recomendados.

Validações como `validates :foreign_key, uniqueness: true` são uma maneira pela qual os modelos podem garantir a integridade dos dados. A opção `:dependent` nas associações permite que os modelos destruam automaticamente os objetos filhos quando o pai é destruído. Como qualquer coisa que opera no nível da aplicação, eles não podem garantir a integridade referencial e, por isso, algumas pessoas os complementam com [constraints de chave estrangeira][] no banco de dados.

Embora o Active Record não forneça todas as ferramentas para trabalhar diretamente com esses recursos, o método `execute` pode ser usado para executar SQL arbitrário.

[constraints de chave estrangeira]: #constraints-de-chave-estrangeira

Migrações e Dados Iniciais
------------------------

O objetivo principal do recurso de migração do Rails é emitir comandos que modificam o esquema usando um processo consistente. As migrações também podem ser usadas para adicionar ou modificar dados. Isso é útil em um banco de dados existente que não pode ser destruído e recriado, como um banco de dados de produção.

```ruby
class AddInitialProducts < ActiveRecord::Migration[7.1]
  def up
    5.times do |i|
      Product.create(name: "Product ##{i}", description: "A product.")
    end
  end

  def down
    Product.delete_all
  end
end
```

Para adicionar dados iniciais após a criação de um banco de dados, o Rails possui um recurso integrado de 'seeds' que acelera o processo. Isso é especialmente útil ao recarregar o banco de dados com frequência em ambientes de desenvolvimento e teste, ou ao configurar dados iniciais para produção.

Para começar a usar esse recurso, abra o arquivo `db/seeds.rb` e adicione algum código Ruby, em seguida, execute `bin/rails db:seed`.

NOTA: O código aqui deve ser idempotente para que possa ser executado em qualquer ponto em todos os ambientes.

```ruby
["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
  MovieGenre.find_or_create_by!(name: genre_name)
end
```

Esta é geralmente uma maneira muito mais limpa de configurar o banco de dados de um aplicativo em branco.

Migrações Antigas
--------------

O `db/schema.rb` ou `db/structure.sql` é uma captura do estado atual do seu banco de dados e é a fonte autoritativa para reconstruir esse banco de dados. Isso torna possível excluir ou podar arquivos de migração antigos.

Quando você exclui arquivos de migração no diretório `db/migrate/`, qualquer ambiente onde `bin/rails db:migrate` foi executado quando esses arquivos ainda existiam terá uma referência ao timestamp de migração específico para eles dentro de uma tabela interna do Rails chamada `schema_migrations`. Essa tabela é usada para acompanhar se as migrações foram executadas em um ambiente específico.

Se você executar o comando `bin/rails db:migrate:status`, que exibe o status (ativo ou inativo) de cada migração, você deverá ver `********** NO FILE **********` exibido ao lado de qualquer arquivo de migração excluído que foi executado em um ambiente específico, mas que não pode mais ser encontrado no diretório `db/migrate/`.

### Migrações de Engines

No entanto, há uma ressalva com [Engines][]. As tarefas Rake para instalar migrações de engines são idempotentes, o que significa que elas terão o mesmo resultado, não importa quantas vezes sejam chamadas. Migrações presentes no aplicativo pai devido a uma instalação anterior são ignoradas, e as ausentes são copiadas com um novo timestamp inicial. Se você excluiu migrações antigas de uma engine e executou a tarefa de instalação novamente, você obteria novos arquivos com novos timestamps, e `db:migrate` tentaria executá-los novamente.

Assim, geralmente você deseja preservar as migrações provenientes de engines. Elas têm um comentário especial como este:

```ruby
# Esta migração vem do blorgh (originalmente 20210621082949)
```

 [Engines]: engines.html
[`add_column`]: https://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html#method-i-add_column
[`add_index`]: https://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html#method-i-add_index
[`add_reference`]: https://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html#method-i-add_reference
[`remove_column`]: https://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html#method-i-remove_column
[`create_table`]: https://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html#method-i-create_table
[`create_join_table`]: https://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html#method-i-create_join_table
[`change_table`]: https://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html#method-i-change_table
[`change_column`]: https://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html#method-i-change_column
[`change_column_default`]: https://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html#method-i-change_column_default
[`change_column_null`]: https://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html#method-i-change_column_null
[`execute`]: https://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/DatabaseStatements.html#method-i-execute
[`ActiveRecord::ConnectionAdapters::SchemaStatements`]: https://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html
[`ActiveRecord::ConnectionAdapters::TableDefinition`]: https://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/TableDefinition.html
[`ActiveRecord::ConnectionAdapters::Table`]: https://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/Table.html
[`add_check_constraint`]: https://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html#method-i-add_check_constraint
[`add_foreign_key`]: https://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html#method-i-add_foreign_key
[`add_timestamps`]: https://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html#method-i-add_timestamps
[`change_column_comment`]: https://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html#method-i-change_column_comment
[`change_table_comment`]: https://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html#method-i-change_table_comment
[`drop_join_table`]: https://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html#method-i-drop_join_table
[`drop_table`]: https://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html#method-i-drop_table
[`remove_check_constraint`]: https://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html#method-i-remove_check_constraint
[`remove_foreign_key`]: https://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html#method-i-remove_foreign_key
[`remove_index`]: https://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html#method-i-remove_index
[`remove_reference`]: https://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html#method-i-remove_reference
[`remove_timestamps`]: https://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html#method-i-remove_timestamps
[`rename_column`]: https://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html#method-i-rename_column
[`remove_columns`]: https://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html#method-i-remove_columns
[`rename_index`]: https://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html#method-i-rename_index
[`rename_table`]: https://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html#method-i-rename_table
[`reversible`]: https://api.rubyonrails.org/classes/ActiveRecord/Migration.html#method-i-reversible
[`revert`]: https://api.rubyonrails.org/classes/ActiveRecord/Migration.html#method-i-revert
[`say`]: https://api.rubyonrails.org/classes/ActiveRecord/Migration.html#method-i-say
[`say_with_time`]: https://api.rubyonrails.org/classes/ActiveRecord/Migration.html#method-i-say_with_time
[`suppress_messages`]: https://api.rubyonrails.org/classes/ActiveRecord/Migration.html#method-i-suppress_messages
[`config.active_record.schema_format`]: configuring.html#config-active-record-schema-format
