**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 67ad41dc27cc9079db9a7e31dffa5aac
Múltiplos Bancos de Dados com Active Record
===========================================

Este guia aborda o uso de múltiplos bancos de dados em sua aplicação Rails.

Após ler este guia, você saberá:

* Como configurar sua aplicação para múltiplos bancos de dados.
* Como funciona a troca automática de conexões.
* Como usar o sharding horizontal para múltiplos bancos de dados.
* Quais recursos são suportados e o que ainda está em progresso.

--------------------------------------------------------------------------------

Conforme uma aplicação cresce em popularidade e uso, você precisará dimensionar a aplicação
para suportar seus novos usuários e seus dados. Uma maneira pela qual sua aplicação pode precisar
dimensionar é no nível do banco de dados. O Rails agora tem suporte para múltiplos bancos de dados,
então você não precisa armazenar seus dados em um único lugar.

No momento, os seguintes recursos são suportados:

* Múltiplos bancos de dados de escrita e uma réplica para cada um
* Troca automática de conexão para o modelo com o qual você está trabalhando
* Troca automática entre o banco de dados de escrita e a réplica, dependendo do verbo HTTP e das gravações recentes
* Tarefas do Rails para criar, excluir, migrar e interagir com os múltiplos bancos de dados

Os seguintes recursos não são (ainda) suportados:

* Balanceamento de carga para réplicas

## Configurando Sua Aplicação

Embora o Rails tente fazer a maior parte do trabalho para você, ainda há algumas etapas que você precisará
fazer para preparar sua aplicação para múltiplos bancos de dados.

Vamos supor que temos uma aplicação com um único banco de dados de escrita e precisamos adicionar um
novo banco de dados para algumas novas tabelas que estamos adicionando. O nome do novo banco de dados será
"animals".

O `database.yml` se parece com isso:

```yaml
production:
  database: my_primary_database
  adapter: mysql2
  username: root
  password: <%= ENV['ROOT_PASSWORD'] %>
```

Vamos adicionar uma réplica para a primeira configuração e um segundo banco de dados chamado animals e uma
réplica para ele também. Para fazer isso, precisamos alterar nosso `database.yml` de uma configuração de 2 camadas
para uma configuração de 3 camadas.

Se uma configuração primária for fornecida, ela será usada como a configuração "padrão". Se
não houver uma configuração chamada `"primary"`, o Rails usará a primeira configuração como padrão
para cada ambiente. As configurações padrão usarão os nomes de arquivo padrão do Rails. Por exemplo,
as configurações primárias usarão `schema.rb` para o arquivo de esquema, enquanto todas as outras entradas
usarão `[CONFIGURATION_NAMESPACE]_schema.rb` para o nome do arquivo.

```yaml
production:
  primary:
    database: my_primary_database
    username: root
    password: <%= ENV['ROOT_PASSWORD'] %>
    adapter: mysql2
  primary_replica:
    database: my_primary_database
    username: root_readonly
    password: <%= ENV['ROOT_READONLY_PASSWORD'] %>
    adapter: mysql2
    replica: true
  animals:
    database: my_animals_database
    username: animals_root
    password: <%= ENV['ANIMALS_ROOT_PASSWORD'] %>
    adapter: mysql2
    migrations_paths: db/animals_migrate
  animals_replica:
    database: my_animals_database
    username: animals_readonly
    password: <%= ENV['ANIMALS_READONLY_PASSWORD'] %>
    adapter: mysql2
    replica: true
```

Ao usar múltiplos bancos de dados, existem algumas configurações importantes.

Primeiro, o nome do banco de dados para `primary` e `primary_replica` deve ser o mesmo, pois eles contêm
os mesmos dados. Isso também é válido para `animals` e `animals_replica`.

Segundo, o nome de usuário para os escritores e réplicas deve ser diferente, e as permissões de banco de dados do usuário réplica
devem ser definidas apenas para leitura e não para gravação.

Ao usar um banco de dados de réplica, você precisa adicionar uma entrada `replica: true` para a réplica no
`database.yml`. Isso ocorre porque o Rails não tem como saber qual é a réplica
e qual é o escritor. O Rails não executará certas tarefas, como migrações, em réplicas.

Por fim, para novos bancos de dados de escrita, você precisa definir `migrations_paths` para o diretório
onde você armazenará as migrações para esse banco de dados. Veremos mais sobre `migrations_paths`
mais adiante neste guia.

Agora que temos um novo banco de dados, vamos configurar o modelo de conexão. Para usar o
novo banco de dados, precisamos criar uma nova classe abstrata e conectar aos bancos de dados de animais.

```ruby
class AnimalsRecord < ApplicationRecord
  self.abstract_class = true

  connects_to database: { writing: :animals, reading: :animals_replica }
end
```

Em seguida, precisamos atualizar `ApplicationRecord` para conhecer nossa nova réplica.

```ruby
class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  connects_to database: { writing: :primary, reading: :primary_replica }
end
```

Se você usar uma classe com um nome diferente para o registro de aplicação, você precisará
definir `primary_abstract_class` em vez disso, para que o Rails saiba qual classe `ActiveRecord::Base`
deve compartilhar uma conexão.

```ruby
class PrimaryApplicationRecord < ActiveRecord::Base
  primary_abstract_class
end
```

Classes que se conectam a primary/primary_replica podem herdar de sua classe abstrata primária
como em aplicações Rails padrão:
```ruby
class Person < ApplicationRecord
end
```

Por padrão, o Rails espera que os papéis do banco de dados sejam `writing` e `reading` para o primário
e réplica, respectivamente. Se você tiver um sistema legado, talvez já tenha papéis configurados que
você não deseja alterar. Nesse caso, você pode definir um novo nome de papel na configuração do seu aplicativo.

```ruby
config.active_record.writing_role = :default
config.active_record.reading_role = :readonly
```

É importante conectar-se ao seu banco de dados em um único modelo e, em seguida, herdar desse modelo
para as tabelas, em vez de conectar vários modelos individuais ao mesmo banco de dados. Os
clientes de banco de dados têm um limite para o número de conexões abertas que podem existir e se você fizer isso, ele irá
multiplicar o número de conexões que você tem, já que o Rails usa o nome da classe do modelo para o
nome da especificação de conexão.

Agora que temos o `database.yml` e o novo modelo configurados, é hora de criar os bancos de dados.
O Rails 6.0 vem com todas as tarefas do Rails que você precisa para usar vários bancos de dados no Rails.

Você pode executar `bin/rails -T` para ver todos os comandos que você pode executar. Você deve ver o seguinte:

```bash
$ bin/rails -T
bin/rails db:create                          # Cria o banco de dados a partir de DATABASE_URL ou config/database.yml para o ...
bin/rails db:create:animals                  # Cria o banco de dados animals para o ambiente atual
bin/rails db:create:primary                  # Cria o banco de dados primário para o ambiente atual
bin/rails db:drop                            # Exclui o banco de dados a partir de DATABASE_URL ou config/database.yml para o ...
bin/rails db:drop:animals                    # Exclui o banco de dados animals para o ambiente atual
bin/rails db:drop:primary                    # Exclui o banco de dados primário para o ambiente atual
bin/rails db:migrate                         # Migra o banco de dados (opções: VERSION=x, VERBOSE=false, SCOPE=blog)
bin/rails db:migrate:animals                 # Migra o banco de dados animals para o ambiente atual
bin/rails db:migrate:primary                 # Migra o banco de dados primário para o ambiente atual
bin/rails db:migrate:status                  # Exibe o status das migrações
bin/rails db:migrate:status:animals          # Exibe o status das migrações para o banco de dados animals
bin/rails db:migrate:status:primary          # Exibe o status das migrações para o banco de dados primário
bin/rails db:reset                           # Exclui e recria todos os bancos de dados a partir de seus esquemas para o ambiente atual e carrega as sementes
bin/rails db:reset:animals                   # Exclui e recria o banco de dados animals a partir de seu esquema para o ambiente atual e carrega as sementes
bin/rails db:reset:primary                   # Exclui e recria o banco de dados primário a partir de seu esquema para o ambiente atual e carrega as sementes
bin/rails db:rollback                        # Reverte o esquema para a versão anterior (especifique as etapas com STEP=n)
bin/rails db:rollback:animals                # Reverte o banco de dados animals para o ambiente atual (especifique as etapas com STEP=n)
bin/rails db:rollback:primary                # Reverte o banco de dados primário para o ambiente atual (especifique as etapas com STEP=n)
bin/rails db:schema:dump                     # Cria um arquivo de esquema do banco de dados (db/schema.rb ou db/structure.sql  ...
bin/rails db:schema:dump:animals             # Cria um arquivo de esquema do banco de dados (db/schema.rb ou db/structure.sql  ...
bin/rails db:schema:dump:primary             # Cria um arquivo db/schema.rb que é portátil para qualquer BD suportado  ...
bin/rails db:schema:load                     # Carrega um arquivo de esquema do banco de dados (db/schema.rb ou db/structure.sql  ...
bin/rails db:schema:load:animals             # Carrega um arquivo de esquema do banco de dados (db/schema.rb ou db/structure.sql  ...
bin/rails db:schema:load:primary             # Carrega um arquivo de esquema do banco de dados (db/schema.rb ou db/structure.sql  ...
bin/rails db:setup                           # Cria todos os bancos de dados, carrega todos os esquemas e inicializa com os dados de semente (use db:reset para também excluir todos os bancos de dados primeiro)
bin/rails db:setup:animals                   # Cria o banco de dados animals, carrega o esquema e inicializa com os dados de semente (use db:reset:animals para também excluir o banco de dados primeiro)
bin/rails db:setup:primary                   # Cria o banco de dados primário, carrega o esquema e inicializa com os dados de semente (use db:reset:primary para também excluir o banco de dados primeiro)
```

Executar um comando como `bin/rails db:create` criará tanto o banco de dados primário quanto o animals.
Observe que não há comando para criar os usuários do banco de dados e você precisará fazer isso manualmente
para suportar os usuários somente leitura para suas réplicas. Se você quiser criar apenas o banco de dados animals,
você pode executar `bin/rails db:create:animals`.

## Conectando-se a bancos de dados sem gerenciar esquemas e migrações

Se você deseja se conectar a um banco de dados externo sem tarefas de gerenciamento de banco de dados
como gerenciamento de esquema, migrações, sementes, etc., você pode definir a opção de configuração `database_tasks: false` por banco de dados. Por padrão, ela é
definida como true.

```yaml
production:
  primary:
    database: my_database
    adapter: mysql2
  animals:
    database: my_animals_database
    adapter: mysql2
    database_tasks: false
```

## Geradores e Migrações

As migrações para vários bancos de dados devem estar em suas próprias pastas com o prefixo
do nome da chave do banco de dados na configuração.
Você também precisa configurar o `migrations_paths` nas configurações do banco de dados para informar ao Rails onde encontrar as migrações.

Por exemplo, o banco de dados `animals` procuraria por migrações no diretório `db/animals_migrate` e o `primary` procuraria em `db/migrate`. Os geradores do Rails agora aceitam a opção `--database` para que o arquivo seja gerado no diretório correto. O comando pode ser executado da seguinte forma:

```bash
$ bin/rails generate migration CreateDogs name:string --database animals
```

Se você estiver usando os geradores do Rails, os geradores de scaffold e model criarão a classe abstrata para você. Basta passar a chave do banco de dados para a linha de comando.

```bash
$ bin/rails generate scaffold Dog name:string --database animals
```

Uma classe com o nome do banco de dados e `Record` será criada. Neste exemplo, o banco de dados é `Animals`, então teremos `AnimalsRecord`:

```ruby
class AnimalsRecord < ApplicationRecord
  self.abstract_class = true

  connects_to database: { writing: :animals }
end
```

O modelo gerado herdará automaticamente de `AnimalsRecord`.

```ruby
class Dog < AnimalsRecord
end
```

NOTA: Como o Rails não sabe qual banco de dados é a réplica do seu escritor, você precisará adicionar isso à classe abstrata depois de terminar.

O Rails só gerará a nova classe uma vez. Ela não será sobrescrita por novos scaffolds ou excluída se o scaffold for excluído.

Se você já tiver uma classe abstrata e seu nome for diferente de `AnimalsRecord`, você pode passar a opção `--parent` para indicar que deseja uma classe abstrata diferente:

```bash
$ bin/rails generate scaffold Dog name:string --database animals --parent Animals::Record
```

Isso pulará a geração de `AnimalsRecord`, pois você indicou ao Rails que deseja usar uma classe pai diferente.

## Ativando a Troca Automática de Papéis

Por fim, para usar a réplica somente leitura em seu aplicativo, você precisará ativar o middleware para troca automática.

A troca automática permite que o aplicativo alterne do escritor para a réplica ou da réplica para o escritor com base no verbo HTTP e se houve uma gravação recente pelo usuário solicitante.

Se o aplicativo estiver recebendo uma solicitação POST, PUT, DELETE ou PATCH, o aplicativo gravará automaticamente no banco de dados do escritor. Pelo tempo especificado após a gravação, o aplicativo lerá do banco de dados primário. Para uma solicitação GET ou HEAD, o aplicativo lerá da réplica, a menos que tenha ocorrido uma gravação recente.

Para ativar o middleware de troca automática de conexão, você pode executar o gerador de troca automática:

```bash
$ bin/rails g active_record:multi_db
```

E então descomente as seguintes linhas:

```ruby
Rails.application.configure do
  config.active_record.database_selector = { delay: 2.seconds }
  config.active_record.database_resolver = ActiveRecord::Middleware::DatabaseSelector::Resolver
  config.active_record.database_resolver_context = ActiveRecord::Middleware::DatabaseSelector::Resolver::Session
end
```

O Rails garante "leia sua própria gravação" e enviará sua solicitação GET ou HEAD para o escritor se estiver dentro da janela de `delay`. Por padrão, o atraso é definido como 2 segundos. Você deve alterar isso com base na infraestrutura do seu banco de dados. O Rails não garante "leia uma gravação recente" para outros usuários dentro da janela de atraso e enviará solicitações GET e HEAD para as réplicas, a menos que tenham gravado recentemente.

A troca automática de conexão no Rails é relativamente primitiva e deliberadamente não faz muito. O objetivo é um sistema que demonstre como fazer a troca automática de conexão que seja flexível o suficiente para ser personalizado pelos desenvolvedores de aplicativos.

A configuração no Rails permite que você altere facilmente como a troca é feita e em quais parâmetros ela é baseada. Digamos que você queira usar um cookie em vez de uma sessão para decidir quando trocar de conexões. Você pode escrever sua própria classe:

```ruby
class MyCookieResolver << ActiveRecord::Middleware::DatabaseSelector::Resolver
  def self.call(request)
    new(request.cookies)
  end

  def initialize(cookies)
    @cookies = cookies
  end

  attr_reader :cookies

  def last_write_timestamp
    self.class.convert_timestamp_to_time(cookies[:last_write])
  end

  def update_last_write_timestamp
    cookies[:last_write] = self.class.convert_time_to_timestamp(Time.now)
  end

  def save(response)
  end
end
```

E então passe para o middleware:

```ruby
config.active_record.database_selector = { delay: 2.seconds }
config.active_record.database_resolver = ActiveRecord::Middleware::DatabaseSelector::Resolver
config.active_record.database_resolver_context = MyCookieResolver
```

## Usando a Troca Manual de Conexão

Existem casos em que você pode querer que seu aplicativo se conecte a um escritor ou a uma réplica e a troca automática de conexão não é adequada. Por exemplo, você pode saber que, para uma determinada solicitação, sempre deseja enviar a solicitação para uma réplica, mesmo quando estiver em um caminho de solicitação POST.

Para fazer isso, o Rails fornece um método `connected_to` que alternará para a conexão que você precisa.
```ruby
ActiveRecord::Base.connected_to(role: :reading) do
  # todo o código neste bloco estará conectado ao papel de leitura
end
```

O "papel" na chamada `connected_to` procura as conexões que estão conectadas nesse
manipulador de conexão (ou papel). O manipulador de conexão `reading` conterá todas as conexões
que foram conectadas via `connects_to` com o nome do papel `reading`.

Observe que `connected_to` com um papel procurará uma conexão existente e alternará
usando o nome da especificação de conexão. Isso significa que se você passar um papel desconhecido
como `connected_to(role: :nonexistent)` você receberá um erro que diz
`ActiveRecord::ConnectionNotEstablished (Nenhum pool de conexões para 'ActiveRecord::Base' encontrado para o papel 'nonexistent'.)`

Se você deseja que o Rails garanta que todas as consultas executadas sejam apenas leitura, passe `prevent_writes: true`.
Isso apenas impede que as consultas que parecem escritas sejam enviadas para o banco de dados.
Você também deve configurar seu banco de dados de réplica para ser executado em modo somente leitura.

```ruby
ActiveRecord::Base.connected_to(role: :reading, prevent_writes: true) do
  # O Rails verificará cada consulta para garantir que seja uma consulta de leitura
end
```

## Shardamento Horizontal

O shardamento horizontal ocorre quando você divide seu banco de dados para reduzir o número de linhas em cada
servidor de banco de dados, mas mantém o mesmo esquema em todos os "shards". Isso é comumente chamado de shardamento "multi-tenant".

A API para suportar o shardamento horizontal no Rails é semelhante à API de shardamento vertical / múltiplo
banco de dados que existe desde o Rails 6.0.

Os shards são declarados na configuração de três camadas da seguinte forma:

```yaml
production:
  primary:
    database: my_primary_database
    adapter: mysql2
  primary_replica:
    database: my_primary_database
    adapter: mysql2
    replica: true
  primary_shard_one:
    database: my_primary_shard_one
    adapter: mysql2
  primary_shard_one_replica:
    database: my_primary_shard_one
    adapter: mysql2
    replica: true
```

Os modelos são então conectados à API `connects_to` por meio da chave `shards`:

```ruby
class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  connects_to shards: {
    default: { writing: :primary, reading: :primary_replica },
    shard_one: { writing: :primary_shard_one, reading: :primary_shard_one_replica }
  }
end
```

Você não é obrigado a usar `default` como o primeiro nome de shard. O Rails assumirá o primeiro
nome de shard no hash `connects_to` como a conexão "padrão". Essa conexão é usada
internamente para carregar dados de tipo e outras informações em que o esquema é o mesmo em todos os shards.

Em seguida, os modelos podem trocar de conexões manualmente por meio da API `connected_to`. Se
usando shardamento, tanto um `role` quanto um `shard` devem ser passados:

```ruby
ActiveRecord::Base.connected_to(role: :writing, shard: :default) do
  @id = Person.create! # Cria um registro no shard chamado ":default"
end

ActiveRecord::Base.connected_to(role: :writing, shard: :shard_one) do
  Person.find(@id) # Não é possível encontrar o registro, pois não existe porque foi criado
                   # no shard chamado ":default".
end
```

A API de shardamento horizontal também suporta réplicas de leitura. Você pode alternar o
papel e o shard com a API `connected_to`.

```ruby
ActiveRecord::Base.connected_to(role: :reading, shard: :shard_one) do
  Person.first # Procura o registro na réplica de leitura do shard one
end
```

## Ativando a Troca Automática de Shards

As aplicações podem alternar automaticamente os shards por solicitação usando o middleware fornecido.

O Middleware `ShardSelector` fornece uma estrutura para trocar automaticamente
os shards. O Rails fornece uma estrutura básica para determinar qual
shard trocar e permite que as aplicações escrevam estratégias personalizadas
para a troca, se necessário.

O `ShardSelector` recebe um conjunto de opções (atualmente apenas `lock` é suportado)
que podem ser usadas pelo middleware para alterar o comportamento. `lock`
é verdadeiro por padrão e proibirá a solicitação de trocar de shard uma vez
dentro do bloco. Se `lock` for falso, a troca de shard será permitida.
Para shardamento baseado em locatário, `lock` deve sempre ser verdadeiro para evitar que a aplicação
troque acidentalmente entre locatários.

O mesmo gerador do seletor de banco de dados pode ser usado para gerar o arquivo para
troca automática de shards:

```bash
$ bin/rails g active_record:multi_db
```

Em seguida, no arquivo, descomente o seguinte:

```ruby
Rails.application.configure do
  config.active_record.shard_selector = { lock: true }
  config.active_record.shard_resolver = ->(request) { Tenant.find_by!(host: request.host).shard }
end
```

As aplicações devem fornecer o código para o resolvedor, pois ele depende de modelos específicos da aplicação.
Um resolvedor de exemplo ficaria assim:

```ruby
config.active_record.shard_resolver = ->(request) {
  subdomain = request.subdomain
  tenant = Tenant.find_by_subdomain!(subdomain)
  tenant.shard
}
```

## Alternância Granular de Conexão de Banco de Dados

No Rails 6.1, é possível alternar as conexões para um banco de dados em vez de
todos os bancos de dados globalmente.

Com a alternância granular de conexão de banco de dados, qualquer classe de conexão abstrata
poderá alternar as conexões sem afetar outras conexões. Isso
é útil para alternar suas consultas `AnimalsRecord` para leitura da réplica
enquanto garante que suas consultas `ApplicationRecord` vão para o primário.
```ruby
AnimalsRecord.connected_to(role: :reading) do
  Dog.first # Lê do animals_replica
  Person.first  # Lê do primary
end
```

Também é possível trocar as conexões de forma granular para shards.

```ruby
AnimalsRecord.connected_to(role: :reading, shard: :shard_one) do
  Dog.first # Lerá de shard_one_replica. Se não houver conexão para shard_one_replica,
  # um erro ConnectionNotEstablished será lançado
  Person.first # Lerá do escritor primário
end
```

Para trocar apenas o cluster de banco de dados primário, use `ApplicationRecord`:

```ruby
ApplicationRecord.connected_to(role: :reading, shard: :shard_one) do
  Person.first # Lê do primary_shard_one_replica
  Dog.first # Lê do animals_primary
end
```

`ActiveRecord::Base.connected_to` mantém a capacidade de trocar
conexões globalmente.

### Lidando com Associações com Junções entre Bancos de Dados

A partir do Rails 7.0+, o Active Record possui uma opção para lidar com associações que realizam
uma junção entre vários bancos de dados. Se você tiver uma associação has many through ou has one through
que você deseja desabilitar a junção e realizar 2 ou mais consultas, passe a opção `disable_joins: true`.

Por exemplo:

```ruby
class Dog < AnimalsRecord
  has_many :treats, through: :humans, disable_joins: true
  has_many :humans

  has_one :home
  has_one :yard, through: :home, disable_joins: true
end

class Home
  belongs_to :dog
  has_one :yard
end

class Yard
  belongs_to :home
end
```

Anteriormente, chamar `@dog.treats` sem `disable_joins` ou `@dog.yard` sem `disable_joins`
lançaria um erro porque os bancos de dados não podem lidar com junções entre clusters. Com a
opção `disable_joins`, o Rails irá gerar várias consultas de seleção
para evitar tentativas de junção entre clusters. Para a associação acima, `@dog.treats` geraria o
seguinte SQL:

```sql
SELECT "humans"."id" FROM "humans" WHERE "humans"."dog_id" = ?  [["dog_id", 1]]
SELECT "treats".* FROM "treats" WHERE "treats"."human_id" IN (?, ?, ?)  [["human_id", 1], ["human_id", 2], ["human_id", 3]]
```

Enquanto `@dog.yard` geraria o seguinte SQL:

```sql
SELECT "home"."id" FROM "homes" WHERE "homes"."dog_id" = ? [["dog_id", 1]]
SELECT "yards".* FROM "yards" WHERE "yards"."home_id" = ? [["home_id", 1]]
```

Existem algumas coisas importantes a serem observadas com essa opção:

1. Pode haver implicações de desempenho, uma vez que agora serão realizadas duas ou mais consultas (dependendo
   da associação) em vez de uma junção. Se a seleção de `humans` retornar um grande número de IDs,
   a seleção de `treats` pode enviar muitos IDs.
2. Como não estamos mais realizando junções, uma consulta com uma ordenação ou limite agora é ordenada em memória, uma vez que
   a ordem de uma tabela não pode ser aplicada a outra tabela.
3. Essa configuração deve ser adicionada a todas as associações em que você deseja desabilitar a junção.
   O Rails não pode adivinhar isso para você, porque o carregamento da associação é preguiçoso, para carregar `treats` em `@dog.treats`,
   o Rails já precisa saber qual SQL deve ser gerado.

### Cache de Esquema

Se você deseja carregar um cache de esquema para cada banco de dados, você deve definir um `schema_cache_path` em cada configuração de banco de dados e definir `config.active_record.lazily_load_schema_cache = true` na configuração da sua aplicação. Observe que isso carregará o cache preguiçosamente quando as conexões do banco de dados forem estabelecidas.

## Observações

### Balanceamento de Carga de Réplicas

O Rails também não oferece suporte ao balanceamento de carga automático de réplicas. Isso depende muito da sua infraestrutura. Podemos implementar um balanceamento de carga básico e primitivo no futuro, mas para uma aplicação em escala, isso deve ser tratado fora do Rails.
