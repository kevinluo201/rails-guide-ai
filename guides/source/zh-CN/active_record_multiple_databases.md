**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 67ad41dc27cc9079db9a7e31dffa5aac
使用Active Record的多个数据库
==============================

本指南介绍如何在Rails应用程序中使用多个数据库。

阅读完本指南后，您将了解以下内容：

* 如何为多个数据库设置应用程序。
* 自动连接切换的工作原理。
* 如何使用水平分片来处理多个数据库。
* 支持的功能和尚未完成的工作。

--------------------------------------------------------------------------------

随着应用程序的受欢迎程度和使用率的增长，您需要扩展应用程序以支持新用户和他们的数据。应用程序可能需要在数据库层面进行扩展。Rails现在支持多个数据库，因此您不必将所有数据存储在一个地方。

目前支持以下功能：

* 多个写数据库和每个数据库的副本
* 正在使用的模型的自动连接切换
* 根据HTTP动词和最近的写操作自动在写数据库和副本之间切换
* 用于创建、删除、迁移和与多个数据库交互的Rails任务

以下功能目前不支持：

* 负载均衡副本

## 设置应用程序

虽然Rails会尽力为您完成大部分工作，但仍然有一些步骤需要您完成，以使应用程序准备好使用多个数据库。

假设我们有一个应用程序，有一个单独的写数据库，我们需要添加一个新的数据库来存储我们正在添加的一些新表。新数据库的名称将为"animals"。

`database.yml`文件如下所示：

```yaml
production:
  database: my_primary_database
  adapter: mysql2
  username: root
  password: <%= ENV['ROOT_PASSWORD'] %>
```

让我们为第一个配置添加一个副本，以及一个名为animals的第二个数据库和该数据库的副本。为此，我们需要将`database.yml`从2层配置更改为3层配置。

如果提供了主配置，它将用作"默认"配置。如果没有名为"primary"的配置，Rails将使用第一个配置作为每个环境的默认配置。默认配置将使用默认的Rails文件名。例如，主配置将使用`schema.rb`作为模式文件的文件名，而其他所有条目将使用`[CONFIGURATION_NAMESPACE]_schema.rb`作为文件名。

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

使用多个数据库时，有几个重要的设置。

首先，`primary`和`primary_replica`的数据库名称应该相同，因为它们包含相同的数据。`animals`和`animals_replica`也是如此。

其次，写入者和副本的用户名应该不同，并且副本用户的数据库权限应设置为只读，不能写入。

在使用副本数据库时，您需要在`database.yml`的副本中添加一个`replica: true`条目。这是因为Rails无法知道哪个是副本，哪个是写入者。Rails不会对副本运行某些任务，例如迁移。

最后，对于新的写入数据库，您需要将`migrations_paths`设置为存储该数据库的迁移的目录。我们将在本指南后面更详细地了解`migrations_paths`。

现在我们有了一个新的数据库，让我们设置连接模型。为了使用新的数据库，我们需要创建一个新的抽象类并连接到animals数据库。

```ruby
class AnimalsRecord < ApplicationRecord
  self.abstract_class = true

  connects_to database: { writing: :animals, reading: :animals_replica }
end
```

然后我们需要更新`ApplicationRecord`以了解我们的新副本。

```ruby
class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  connects_to database: { writing: :primary, reading: :primary_replica }
end
```

如果您为应用程序记录使用了不同的类名，您需要设置`primary_abstract_class`，以便Rails知道`ActiveRecord::Base`应与哪个类共享连接。

```ruby
class PrimaryApplicationRecord < ActiveRecord::Base
  primary_abstract_class
end
```

连接到primary/primary_replica的类可以像标准Rails应用程序一样继承自您的primary抽象类：
```ruby
class Person < ApplicationRecord
end
```

默认情况下，Rails期望主数据库的角色为`writing`，副本数据库的角色为`reading`。如果您已经有了设置好的角色，不想进行更改，您可以在应用程序配置中设置新的角色名称。

```ruby
config.active_record.writing_role = :default
config.active_record.reading_role = :readonly
```

重要的是要在单个模型中连接到数据库，然后从该模型继承表，而不是将多个单独的模型连接到同一个数据库。数据库客户端对于可以打开的连接数有限制，如果这样做，它将增加您的连接数，因为Rails使用模型类名作为连接规范名称。

现在我们有了`database.yml`和新的模型设置，是时候创建数据库了。Rails 6.0附带了在Rails中使用多个数据库所需的所有rails任务。

您可以运行`bin/rails -T`来查看所有可运行的命令。您应该会看到以下内容：

```bash
$ bin/rails -T
bin/rails db:create                          # 从DATABASE_URL或config/database.yml为当前环境创建数据库...
bin/rails db:create:animals                  # 为当前环境创建animals数据库
bin/rails db:create:primary                  # 为当前环境创建primary数据库
bin/rails db:drop                            # 从DATABASE_URL或config/database.yml为当前环境删除数据库...
bin/rails db:drop:animals                    # 为当前环境删除animals数据库
bin/rails db:drop:primary                    # 为当前环境删除primary数据库
bin/rails db:migrate                         # 迁移数据库（选项：VERSION=x，VERBOSE=false，SCOPE=blog）
bin/rails db:migrate:animals                 # 为当前环境迁移animals数据库
bin/rails db:migrate:primary                 # 为当前环境迁移primary数据库
bin/rails db:migrate:status                  # 显示迁移的状态
bin/rails db:migrate:status:animals          # 显示animals数据库迁移的状态
bin/rails db:migrate:status:primary          # 显示primary数据库迁移的状态
bin/rails db:reset                           # 删除并重新创建当前环境的所有数据库架构，并加载种子数据
bin/rails db:reset:animals                   # 删除并重新创建当前环境的animals数据库架构，并加载种子数据
bin/rails db:reset:primary                   # 删除并重新创建当前环境的primary数据库架构，并加载种子数据
bin/rails db:rollback                        # 将架构回滚到上一个版本（使用STEP=n指定步骤）
bin/rails db:rollback:animals                # 为当前环境回滚animals数据库（使用STEP=n指定步骤）
bin/rails db:rollback:primary                # 为当前环境回滚primary数据库（使用STEP=n指定步骤）
bin/rails db:schema:dump                     # 创建数据库架构文件（db/schema.rb或db/structure.sql之一...
bin/rails db:schema:dump:animals             # 创建数据库架构文件（db/schema.rb或db/structure.sql之一...
bin/rails db:schema:dump:primary             # 创建可适用于任何受支持的数据库的db/schema.rb文件...
bin/rails db:schema:load                     # 加载数据库架构文件（db/schema.rb或db/structure.sql之一...
bin/rails db:schema:load:animals             # 加载数据库架构文件（db/schema.rb或db/structure.sql之一...
bin/rails db:schema:load:primary             # 加载数据库架构文件（db/schema.rb或db/structure.sql之一...
bin/rails db:setup                           # 创建所有数据库，加载所有架构，并使用种子数据进行初始化（使用db:reset首先删除所有数据库）
bin/rails db:setup:animals                   # 创建animals数据库，加载架构，并使用种子数据进行初始化（使用db:reset:animals首先删除数据库）
bin/rails db:setup:primary                   # 创建primary数据库，加载架构，并使用种子数据进行初始化（使用db:reset:primary首先删除数据库）
```

运行像`bin/rails db:create`这样的命令将创建主数据库和animals数据库。请注意，没有用于创建数据库用户的命令，您需要手动执行此操作以支持副本的只读用户。如果要仅创建animals数据库，可以运行`bin/rails db:create:animals`。

## 连接到数据库而不管理架构和迁移

如果您想连接到外部数据库而不进行任何数据库管理任务，例如架构管理、迁移、种子数据等，您可以将每个数据库的配置选项`database_tasks: false`设置为false。默认情况下，它设置为true。

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

## 生成器和迁移

多个数据库的迁移应该位于其自己的文件夹中，以配置中的数据库键名为前缀。
你还需要在数据库配置中设置`migrations_paths`，告诉Rails在哪里找到迁移。

例如，`animals`数据库将在`db/animals_migrate`目录中查找迁移，而`primary`将在`db/migrate`中查找。Rails生成器现在接受一个`--database`选项，以便在正确的目录中生成文件。可以像这样运行命令：

```bash
$ bin/rails generate migration CreateDogs name:string --database animals
```

如果你正在使用Rails生成器，脚手架和模型生成器将为你创建抽象类。只需将数据库键传递给命令行。

```bash
$ bin/rails generate scaffold Dog name:string --database animals
```

将创建一个带有数据库名称和`Record`的类。在这个例子中，数据库是`Animals`，所以我们得到了`AnimalsRecord`：

```ruby
class AnimalsRecord < ApplicationRecord
  self.abstract_class = true

  connects_to database: { writing: :animals }
end
```

生成的模型将自动继承自`AnimalsRecord`。

```ruby
class Dog < AnimalsRecord
end
```

注意：由于Rails不知道哪个数据库是写入操作的副本，所以你需要在完成后将这个内容添加到抽象类中。

Rails只会生成一次新的类。它不会被新的脚手架覆盖或在删除脚手架时被删除。

如果你已经有一个抽象类，并且它的名称与`AnimalsRecord`不同，你可以传递`--parent`选项来指示你想要一个不同的抽象类：

```bash
$ bin/rails generate scaffold Dog name:string --database animals --parent Animals::Record
```

这将跳过生成`AnimalsRecord`，因为你已经告诉Rails你想使用一个不同的父类。

## 激活自动角色切换

最后，为了在应用程序中使用只读副本，你需要激活自动切换的中间件。

自动切换允许应用程序根据HTTP动词和请求用户的最近写入情况从写入数据库切换到副本或从副本切换到写入数据库。

如果应用程序接收到POST、PUT、DELETE或PATCH请求，应用程序将自动写入写入数据库。在写入后的指定时间内，应用程序将从主数据库读取。对于GET或HEAD请求，应用程序将从副本读取，除非最近有写入。

要激活自动连接切换中间件，可以运行自动切换生成器：

```bash
$ bin/rails g active_record:multi_db
```

然后取消注释以下行：

```ruby
Rails.application.configure do
  config.active_record.database_selector = { delay: 2.seconds }
  config.active_record.database_resolver = ActiveRecord::Middleware::DatabaseSelector::Resolver
  config.active_record.database_resolver_context = ActiveRecord::Middleware::DatabaseSelector::Resolver::Session
end
```

Rails保证“读取自己的写入”，如果在`delay`窗口内，将把GET或HEAD请求发送到写入数据库。默认情况下，延迟设置为2秒。你应该根据你的数据库基础设施进行更改。对于延迟窗口内的其他用户，Rails不保证“读取最近的写入”，并且将把GET和HEAD请求发送到副本，除非它们最近写入。

Rails中的自动连接切换相对简单，并且故意不做太多事情。目标是一个能够演示如何进行自动连接切换的系统，同时又足够灵活，可以由应用程序开发人员进行自定义。

Rails中的设置允许你轻松更改切换的方式和基于哪些参数进行切换。假设你想使用cookie而不是会话来决定何时切换连接。你可以编写自己的类：

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

然后将其传递给中间件：

```ruby
config.active_record.database_selector = { delay: 2.seconds }
config.active_record.database_resolver = ActiveRecord::Middleware::DatabaseSelector::Resolver
config.active_record.database_resolver_context = MyCookieResolver
```

## 使用手动连接切换

在某些情况下，你可能希望应用程序连接到写入数据库或副本，并且自动连接切换不足够。例如，你可能知道对于特定请求，即使在POST请求路径中，你也总是希望将请求发送到副本。

为此，Rails提供了一个`connected_to`方法，可以切换到你需要的连接。
```ruby
ActiveRecord::Base.connected_to(role: :reading) do
  # 此代码块中的所有代码将连接到读取角色
end
```

`connected_to` 调用中的 "role" 查找在该连接处理程序（或角色）上连接的连接。`reading` 连接处理程序将保存通过具有 `reading` 角色名称的 `connects_to` 连接的所有连接。

请注意，使用角色的 `connected_to` 将查找现有连接并使用连接规范名称进行切换。这意味着如果传递一个未知的角色，比如 `connected_to(role: :nonexistent)`，你将收到一个错误，错误消息为 `ActiveRecord::ConnectionNotEstablished (No connection pool for 'ActiveRecord::Base' found for the 'nonexistent' role.)`

如果你希望 Rails 确保执行的任何查询都是只读的，请传递 `prevent_writes: true`。这只是阻止将看起来像写入的查询发送到数据库。你还应该将副本数据库配置为只读模式。

```ruby
ActiveRecord::Base.connected_to(role: :reading, prevent_writes: true) do
  # Rails 将检查每个查询以确保它是读取查询
end
```

## 水平分片

水平分片是指将数据库分割成多个服务器，以减少每个数据库服务器上的行数，但在“分片”之间保持相同的模式。这通常被称为“多租户”分片。

在 Rails 中支持水平分片的 API 与自 Rails 6.0 以来存在的多数据库/垂直分片 API 类似。

分片在三层配置中声明如下：

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

然后，使用 `connects_to` API 中的 `shards` 键将模型连接起来：

```ruby
class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  connects_to shards: {
    default: { writing: :primary, reading: :primary_replica },
    shard_one: { writing: :primary_shard_one, reading: :primary_shard_one_replica }
  }
end
```

你不需要将 `default` 作为第一个分片名称。Rails 将假定 `connects_to` 哈希中的第一个分片名称是“默认”连接。此连接在内部用于加载类型数据和其他模式相同的信息。

然后，模型可以通过 `connected_to` API 手动交换连接。如果使用分片，则必须传递 `role` 和 `shard`：

```ruby
ActiveRecord::Base.connected_to(role: :writing, shard: :default) do
  @id = Person.create! # 在名为 ":default" 的分片中创建记录
end

ActiveRecord::Base.connected_to(role: :writing, shard: :shard_one) do
  Person.find(@id) # 无法找到记录，因为它是在名为 ":default" 的分片中创建的
end
```

水平分片 API 还支持读取副本。你可以使用 `connected_to` API 交换角色和分片。

```ruby
ActiveRecord::Base.connected_to(role: :reading, shard: :shard_one) do
  Person.first # 从分片一的读取副本中查找记录
end
```

## 激活自动分片切换

应用程序能够使用提供的中间件自动在每个请求中切换分片。

`ShardSelector` 中间件提供了一个框架，用于自动切换分片。Rails 提供了一个基本框架来确定要切换到哪个分片，并允许应用程序根据需要编写自定义策略来进行切换。

`ShardSelector` 接受一组选项（目前只支持 `lock`），中间件可以使用这些选项来更改行为。`lock` 默认为 true，将禁止请求在块内部切换分片。如果 `lock` 为 false，则允许切换分片。对于基于租户的分片，`lock` 应始终为 true，以防止应用程序代码错误地在租户之间切换。

可以使用与数据库选择器相同的生成器来生成自动分片切换的文件：

```bash
$ bin/rails g active_record:multi_db
```

然后在文件中取消注释以下内容：

```ruby
Rails.application.configure do
  config.active_record.shard_selector = { lock: true }
  config.active_record.shard_resolver = ->(request) { Tenant.find_by!(host: request.host).shard }
end
```

应用程序必须提供解析器的代码，因为它依赖于特定于应用程序的模型。一个示例解析器如下所示：

```ruby
config.active_record.shard_resolver = ->(request) {
  subdomain = request.subdomain
  tenant = Tenant.find_by_subdomain!(subdomain)
  tenant.shard
}
```

## 精细的数据库连接切换

在 Rails 6.1 中，可以切换一个数据库的连接，而不是全局影响所有数据库的连接。

通过精细的数据库连接切换，任何抽象连接类都可以在不影响其他连接的情况下切换连接。这对于将你的 `AnimalsRecord` 查询切换到从副本读取，同时确保你的 `ApplicationRecord` 查询发送到主数据库非常有用。
```ruby
AnimalsRecord.connected_to(role: :reading) do
  Dog.first # 从animals_replica读取
  Person.first  # 从primary读取
end
```

还可以针对分片精确地切换连接。

```ruby
AnimalsRecord.connected_to(role: :reading, shard: :shard_one) do
  Dog.first # 将从shard_one_replica读取。如果shard_one_replica没有连接，将引发ConnectionNotEstablished错误
  Person.first # 将从主写入读取
end
```

要仅切换主数据库集群，请使用`ApplicationRecord`：

```ruby
ApplicationRecord.connected_to(role: :reading, shard: :shard_one) do
  Person.first # 从primary_shard_one_replica读取
  Dog.first # 从animals_primary读取
end
```

`ActiveRecord::Base.connected_to`保持全局切换连接的能力。

### 处理跨数据库的关联关系

从Rails 7.0+开始，Active Record提供了一个选项来处理跨多个数据库的关联关系。如果您有一个has many through或has one through关联关系，想要禁用连接并执行2个或多个查询，请传递`disable_joins: true`选项。

例如：

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

以前调用`@dog.treats`（没有`disable_joins`）或`@dog.yard`（没有`disable_joins`）会引发错误，因为数据库无法处理跨集群的连接。使用`disable_joins`选项，Rails将生成多个select查询以避免尝试跨集群连接。对于上述关联关系，`@dog.treats`将生成以下SQL：

```sql
SELECT "humans"."id" FROM "humans" WHERE "humans"."dog_id" = ?  [["dog_id", 1]]
SELECT "treats".* FROM "treats" WHERE "treats"."human_id" IN (?, ?, ?)  [["human_id", 1], ["human_id", 2], ["human_id", 3]]
```

而`@dog.yard`将生成以下SQL：

```sql
SELECT "home"."id" FROM "homes" WHERE "homes"."dog_id" = ? [["dog_id", 1]]
SELECT "yards".* FROM "yards" WHERE "yards"."home_id" = ? [["home_id", 1]]
```

使用此选项时需要注意以下几点：

1. 这可能会对性能产生影响，因为现在将执行两个或多个查询（取决于关联关系），而不是连接。如果`humans`的select返回了大量的ID，`treats`的select可能会发送太多的ID。
2. 由于不再执行连接，具有排序或限制的查询现在在内存中进行排序，因为无法将一个表的顺序应用于另一个表。
3. 必须在所有需要禁用连接的关联关系中添加此设置。Rails无法为您猜测，因为关联加载是惰性的，要在`@dog.treats`中加载`treats`，Rails已经需要知道应该生成什么SQL。

### 模式缓存

如果要为每个数据库加载模式缓存，必须在每个数据库配置中设置`schema_cache_path`，并在应用程序配置中设置`config.active_record.lazily_load_schema_cache = true`。请注意，这将在建立数据库连接时延迟加载缓存。

## 注意事项

### 负载均衡副本

Rails也不支持自动负载均衡副本。这非常依赖于您的基础设施。我们可能会在将来实现基本的、原始的负载均衡，但对于规模化的应用程序，这应该是您的应用程序在Rails之外处理的事情。
