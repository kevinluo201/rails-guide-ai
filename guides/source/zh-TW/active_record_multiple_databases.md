**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 67ad41dc27cc9079db9a7e31dffa5aac
使用Active Record與多個資料庫
=========================

本指南介紹如何在Rails應用程式中使用多個資料庫。

閱讀本指南後，您將了解以下內容：

* 如何設定應用程式以使用多個資料庫。
* 自動連線切換的運作方式。
* 如何使用水平分片來處理多個資料庫。
* 支援的功能以及仍在進行中的工作。

--------------------------------------------------------------------------------

隨著應用程式的流行度和使用量增加，您需要擴展應用程式以支援新用戶和他們的資料。應用程式可能需要在資料庫層面進行擴展。Rails現在支援多個資料庫，因此您不必將所有資料存儲在同一個地方。

目前支援以下功能：

* 多個寫入資料庫和每個資料庫的複本
* 正在使用的模型的自動連線切換
* 根據HTTP動詞和最近的寫入自動在寫入資料庫和複本之間切換
* 用於創建、刪除、遷移和與多個資料庫交互的Rails任務

以下功能目前尚未（或尚未完全）支援：

* 負載平衡複本

## 設定您的應用程式

雖然Rails會盡力為您完成大部分工作，但仍然需要進行一些步驟，以使您的應用程式準備好使用多個資料庫。

假設我們有一個應用程式，其中有一個單一的寫入資料庫，我們需要為一些新添加的表格添加一個新的資料庫。新資料庫的名稱將為"animals"。

`database.yml`文件如下所示：

```yaml
production:
  database: my_primary_database
  adapter: mysql2
  username: root
  password: <%= ENV['ROOT_PASSWORD'] %>
```

讓我們為第一個配置添加一個複本，以及一個名為animals的第二個資料庫和其複本。為此，我們需要將`database.yml`從2層配置更改為3層配置。

如果提供了主要配置，它將用作"預設"配置。如果沒有名為"primary"的配置，Rails將使用第一個配置作為每個環境的預設配置。預設配置將使用預設的Rails檔案名稱。例如，主要配置將使用`schema.rb`作為模式檔案，而其他所有條目將使用`[CONFIGURATION_NAMESPACE]_schema.rb`作為檔名。

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

在使用多個資料庫時，有幾個重要的設定。

首先，`primary`和`primary_replica`的資料庫名稱應該相同，因為它們包含相同的資料。`animals`和`animals_replica`也是如此。

其次，寫入資料庫和複本的使用者名稱應該不同，並且複本使用者的資料庫權限應該設置為只讀，不能寫入。

在使用複本資料庫時，您需要在`database.yml`的複本中添加`replica: true`條目。這是因為Rails無法知道哪個是複本，哪個是寫入資料庫。Rails不會對複本執行某些任務，例如遷移。

最後，對於新的寫入資料庫，您需要將`migrations_paths`設置為存儲該資料庫遷移的目錄。我們將在本指南的後面更詳細地介紹`migrations_paths`。

現在我們有了一個新的資料庫，讓我們設置連線模型。為了使用新的資料庫，我們需要創建一個新的抽象類並連線到animals資料庫。

```ruby
class AnimalsRecord < ApplicationRecord
  self.abstract_class = true

  connects_to database: { writing: :animals, reading: :animals_replica }
end
```

然後，我們需要更新`ApplicationRecord`以了解我們的新複本。

```ruby
class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  connects_to database: { writing: :primary, reading: :primary_replica }
end
```

如果您為應用程式記錄使用不同的類名，則需要設置`primary_abstract_class`，以便Rails知道`ActiveRecord::Base`應該與哪個類共享連線。

```ruby
class PrimaryApplicationRecord < ActiveRecord::Base
  primary_abstract_class
end
```

連接到primary/primary_replica的類可以像標準的Rails應用程式一樣繼承自您的primary抽象類：

```ruby
class Person < ApplicationRecord
end
```

預設情況下，Rails 預期主要和副本的資料庫角色分別為 `writing` 和 `reading`。如果您已經有設定好的角色，且不想更改，您可以在應用程式配置中設定新的角色名稱。

```ruby
config.active_record.writing_role = :default
config.active_record.reading_role = :readonly
```

重要的是要在單一模型中連接到資料庫，然後繼承該模型以用於表格，而不是將多個單獨的模型連接到同一個資料庫。資料庫客戶端對於可以打開的連接數量有限制，如果這樣做，將會使您的連接數量增加，因為Rails使用模型類別名稱作為連接規格名稱。

現在我們已經有了 `database.yml` 和新的模型設定，是時候創建資料庫了。Rails 6.0 隨附了在Rails中使用多個資料庫所需的所有任務。

您可以運行 `bin/rails -T` 來查看您可以運行的所有命令。您應該會看到以下內容：

```bash
$ bin/rails -T
bin/rails db:create                          # 根據 DATABASE_URL 或 config/database.yml 創建資料庫...
bin/rails db:create:animals                  # 為當前環境創建 animals 資料庫
bin/rails db:create:primary                  # 為當前環境創建 primary 資料庫
bin/rails db:drop                            # 根據 DATABASE_URL 或 config/database.yml 刪除資料庫...
bin/rails db:drop:animals                    # 刪除當前環境的 animals 資料庫
bin/rails db:drop:primary                    # 刪除當前環境的 primary 資料庫
bin/rails db:migrate                         # 遷移資料庫（選項：VERSION=x，VERBOSE=false，SCOPE=blog）
bin/rails db:migrate:animals                 # 為當前環境遷移 animals 資料庫
bin/rails db:migrate:primary                 # 為當前環境遷移 primary 資料庫
bin/rails db:migrate:status                  # 顯示遷移的狀態
bin/rails db:migrate:status:animals          # 顯示 animals 資料庫遷移的狀態
bin/rails db:migrate:status:primary          # 顯示 primary 資料庫遷移的狀態
bin/rails db:reset                           # 刪除並重新創建當前環境的所有資料庫，並載入種子數據
bin/rails db:reset:animals                   # 刪除並重新創建當前環境的 animals 資料庫，並載入種子數據
bin/rails db:reset:primary                   # 刪除並重新創建當前環境的 primary 資料庫，並載入種子數據
bin/rails db:rollback                        # 將模式回滾到上一個版本（使用 STEP=n 指定步驟）
bin/rails db:rollback:animals                # 回滾當前環境的 animals 資料庫（使用 STEP=n 指定步驟）
bin/rails db:rollback:primary                # 回滾當前環境的 primary 資料庫（使用 STEP=n 指定步驟）
bin/rails db:schema:dump                     # 創建資料庫模式文件（db/schema.rb 或 db/structure.sql）
bin/rails db:schema:dump:animals             # 創建資料庫模式文件（db/schema.rb 或 db/structure.sql）
bin/rails db:schema:dump:primary             # 創建可對任何支援的 DB 進行移植的 db/schema.rb 文件
bin/rails db:schema:load                     # 加載資料庫模式文件（db/schema.rb 或 db/structure.sql）
bin/rails db:schema:load:animals             # 加載資料庫模式文件（db/schema.rb 或 db/structure.sql）
bin/rails db:schema:load:primary             # 加載資料庫模式文件（db/schema.rb 或 db/structure.sql）
bin/rails db:setup                           # 創建所有資料庫，載入所有模式，並初始化種子數據（使用 db:reset 首先刪除所有資料庫）
bin/rails db:setup:animals                   # 創建 animals 資料庫，載入模式，並初始化種子數據（使用 db:reset:animals 首先刪除資料庫）
bin/rails db:setup:primary                   # 創建 primary 資料庫，載入模式，並初始化種子數據（使用 db:reset:primary 首先刪除資料庫）
```

運行像 `bin/rails db:create` 這樣的命令將創建主要和 animals 資料庫。請注意，沒有用於創建資料庫用戶的命令，您需要手動創建以支持副本的唯讀用戶。如果您只想創建 animals 資料庫，可以運行 `bin/rails db:create:animals`。

## 連接到資料庫而不管理模式和遷移

如果您想連接到外部資料庫，而不需要任何資料庫管理任務，例如模式管理、遷移、種子數據等，您可以設置每個資料庫的配置選項 `database_tasks: false`。默認情況下，它設置為 true。

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

## 生成器和遷移

多個資料庫的遷移應該放在以配置中的資料庫鍵名為前綴的自己的文件夾中。
您還需要在數據庫配置中設置 `migrations_paths`，以告訴Rails在哪裡查找遷移。

例如，`animals` 數據庫將在 `db/animals_migrate` 目錄中查找遷移，而 `primary` 將在 `db/migrate` 中查找。Rails生成器現在可以使用 `--database` 選項來生成正確目錄中的文件。可以像這樣運行命令：

```bash
$ bin/rails generate migration CreateDogs name:string --database animals
```

如果您使用Rails生成器，scaffold和model生成器將為您創建抽象類。只需將數據庫鍵傳遞給命令行。

```bash
$ bin/rails generate scaffold Dog name:string --database animals
```

將創建一個帶有數據庫名稱和 `Record` 的類。在此示例中，數據庫是 `Animals`，所以我們得到 `AnimalsRecord`：

```ruby
class AnimalsRecord < ApplicationRecord
  self.abstract_class = true

  connects_to database: { writing: :animals }
end
```

生成的模型將自動繼承自 `AnimalsRecord`。

```ruby
class Dog < AnimalsRecord
end
```

注意：由於Rails不知道哪個數據庫是寫入者的副本，因此您需要在完成後將此添加到抽象類中。

Rails只會生成新類一次。它不會被新的scaffold覆蓋或在刪除scaffold時被刪除。

如果您已經有一個抽象類，並且其名稱與 `AnimalsRecord` 不同，則可以傳遞 `--parent` 選項來指示您想要不同的抽象類：

```bash
$ bin/rails generate scaffold Dog name:string --database animals --parent Animals::Record
```

這將跳過生成 `AnimalsRecord`，因為您已經告訴Rails您想使用不同的父類。

## 啟用自動角色切換

最後，為了在應用程序中使用只讀副本，您需要激活自動切換的中間件。

自動切換允許應用程序根據HTTP動詞和請求用戶的最近寫入情況從寫入者切換到副本或從副本切換到寫入者。

如果應用程序接收到POST、PUT、DELETE或PATCH請求，應用程序將自動寫入寫入者數據庫。在寫入後的指定時間內，應用程序將從主數據庫讀取。對於GET或HEAD請求，應用程序將從副本讀取，除非最近有寫入。

要激活自動連接切換中間件，可以運行自動切換生成器：

```bash
$ bin/rails g active_record:multi_db
```

然後取消註釋以下行：

```ruby
Rails.application.configure do
  config.active_record.database_selector = { delay: 2.seconds }
  config.active_record.database_resolver = ActiveRecord::Middleware::DatabaseSelector::Resolver
  config.active_record.database_resolver_context = ActiveRecord::Middleware::DatabaseSelector::Resolver::Session
end
```

Rails保證“讀取自己的寫入”，並將您的GET或HEAD請求發送到寫入者，如果在 `delay` 窗口內。默認情況下，延遲設置為2秒。您應根據您的數據庫基礎設施進行更改。Rails不保證在延遲窗口內對其他用戶進行“讀取最近的寫入”，並且將GET和HEAD請求發送到副本，除非它們最近有寫入。

Rails中的自動連接切換相對較簡單，並且故意不做太多事情。目標是構建一個系統，演示如何進行自動連接切換，並且足夠靈活，可以由應用程序開發人員自定義。

Rails中的設置允許您輕鬆更改切換方式和基於哪些參數進行切換。假設您想要使用cookie而不是會話來決定何時切換連接。您可以編寫自己的類：

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

然後將其傳遞給中間件：

```ruby
config.active_record.database_selector = { delay: 2.seconds }
config.active_record.database_resolver = ActiveRecord::Middleware::DatabaseSelector::Resolver
config.active_record.database_resolver_context = MyCookieResolver
```

## 使用手動連接切換

在某些情況下，您可能希望應用程序連接到寫入者或副本，而自動連接切換不夠用。例如，您可能知道對於特定請求，即使在POST請求路徑中，您也始終希望將請求發送到副本。

為此，Rails提供了一個 `connected_to` 方法，可以切換到您需要的連接。
```ruby
ActiveRecord::Base.connected_to(role: :reading) do
  # 此區塊中的所有程式碼將連接到讀取角色
end
```

在`connected_to`呼叫中的"role"會查找與該連接處理程序（或角色）上連接的連接。`reading`連接處理程序將保存通過使用角色名稱為`reading`的`connects_to`連接的所有連接。

請注意，具有角色的`connected_to`將查找現有連接並切換使用連接規格名稱。這意味著如果您傳遞一個未知的角色，例如`connected_to(role: :nonexistent)`，您將收到一個錯誤，該錯誤說明為`ActiveRecord::ConnectionNotEstablished（找不到“nonexistent”角色的“ActiveRecord::Base”的連接池。）`

如果您希望Rails確保執行的任何查詢都是只讀的，請傳遞`prevent_writes: true`。這只是防止將看起來像寫入的查詢發送到數據庫。您還應該將副本數據庫配置為以只讀模式運行。

```ruby
ActiveRecord::Base.connected_to(role: :reading, prevent_writes: true) do
  # Rails將檢查每個查詢以確保它是讀取查詢
end
```

## 水平分片

水平分片是指將數據庫分割為多個服務器，以減少每個數據庫服務器上的行數，但在“分片”之間保持相同的架構。這通常被稱為“多租戶”分片。

在Rails中支持水平分片的API與自Rails 6.0以來存在的多數據庫/垂直分片API類似。

分片在三層配置中聲明如下：

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

然後，通過`connects_to` API的`shards`鍵將模型連接起來：

```ruby
class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  connects_to shards: {
    default: { writing: :primary, reading: :primary_replica },
    shard_one: { writing: :primary_shard_one, reading: :primary_shard_one_replica }
  }
end
```

您不需要將`default`作為第一個分片名稱。Rails將假定`connects_to`哈希中的第一個分片名稱是“默認”連接。此連接在內部用於加載類型數據和其他架構相同的信息。

然後，模型可以通過`connected_to` API手動交換連接。如果使用分片，必須傳遞`role`和`shard`：

```ruby
ActiveRecord::Base.connected_to(role: :writing, shard: :default) do
  @id = Person.create! # 在名為“:default”的分片中創建一條記錄
end

ActiveRecord::Base.connected_to(role: :writing, shard: :shard_one) do
  Person.find(@id) # 找不到記錄，因為它是在名為“:default”的分片中創建的
end
```

水平分片API還支持讀取副本。您可以使用`connected_to` API交換角色和分片。

```ruby
ActiveRecord::Base.connected_to(role: :reading, shard: :shard_one) do
  Person.first # 從分片一的讀取副本查找記錄
end
```

## 啟用自動分片切換

應用程序能夠使用提供的中間件在每個請求中自動切換分片。

`ShardSelector`中間件提供了一個框架，用於自動切換分片。Rails提供了一個基本框架來確定要切換到哪個分片，並允許應用程序根據需要編寫自定義策略進行切換。

`ShardSelector`接受一組選項（目前僅支持`lock`），中間件可以使用這些選項來更改行為。`lock`默認為true，並且將禁止請求在塊內部切換分片。如果`lock`為false，則允許切換分片。對於基於租戶的分片，`lock`應始終為true，以防止應用程序代碼錯誤地在租戶之間切換。

可以使用與數據庫選擇器相同的生成器來生成自動切換分片的文件：

```bash
$ bin/rails g active_record:multi_db
```

然後在文件中取消註釋以下內容：

```ruby
Rails.application.configure do
  config.active_record.shard_selector = { lock: true }
  config.active_record.shard_resolver = ->(request) { Tenant.find_by!(host: request.host).shard }
end
```

應用程序必須提供解析器的代碼，因為它依賴於應用程序特定的模型。解析器的示例可能如下所示：

```ruby
config.active_record.shard_resolver = ->(request) {
  subdomain = request.subdomain
  tenant = Tenant.find_by_subdomain!(subdomain)
  tenant.shard
}
```

## 精細的數據庫連接切換

在Rails 6.1中，可以切換一個數據庫的連接，而不是全局切換所有數據庫。

通過精細的數據庫連接切換，任何抽象連接類都可以在不影響其他連接的情況下切換連接。這對於將您的`AnimalsRecord`查詢切換為從副本讀取，同時確保`ApplicationRecord`查詢轉到主要連接非常有用。
```ruby
AnimalsRecord.connected_to(role: :reading) do
  Dog.first # 從 animals_replica 讀取
  Person.first  # 從 primary 讀取
end
```

也可以對分片進行細粒度的連接交換。

```ruby
AnimalsRecord.connected_to(role: :reading, shard: :shard_one) do
  Dog.first # 將從 shard_one_replica 讀取。如果 shard_one_replica 沒有連接，將引發 ConnectionNotEstablished 錯誤
  Person.first # 將從 primary writer 讀取
end
```

要僅切換主要的數據庫集群，請使用 `ApplicationRecord`：

```ruby
ApplicationRecord.connected_to(role: :reading, shard: :shard_one) do
  Person.first # 從 primary_shard_one_replica 讀取
  Dog.first # 從 animals_primary 讀取
end
```

`ActiveRecord::Base.connected_to` 保持全局切換連接的能力。

### 跨數據庫的關聯處理

從 Rails 7.0+ 開始，Active Record 提供了一個選項來處理跨多個數據庫的關聯。如果您有一個 has many through 或 has one through 關聯，並且希望禁用連接並執行 2 個或多個查詢，請傳遞 `disable_joins: true` 選項。

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

以前在沒有 `disable_joins` 的情況下調用 `@dog.treats` 或沒有 `disable_joins` 的情況下調用 `@dog.yard` 將引發錯誤，因為數據庫無法處理跨集群的連接。使用 `disable_joins` 選項，Rails 將生成多個 select 查詢以避免嘗試跨集群進行連接。對於上述關聯，`@dog.treats` 將生成以下 SQL：

```sql
SELECT "humans"."id" FROM "humans" WHERE "humans"."dog_id" = ?  [["dog_id", 1]]
SELECT "treats".* FROM "treats" WHERE "treats"."human_id" IN (?, ?, ?)  [["human_id", 1], ["human_id", 2], ["human_id", 3]]
```

而 `@dog.yard` 將生成以下 SQL：

```sql
SELECT "home"."id" FROM "homes" WHERE "homes"."dog_id" = ? [["dog_id", 1]]
SELECT "yards".* FROM "yards" WHERE "yards"."home_id" = ? [["home_id", 1]]
```

使用此選項時需要注意以下幾點：

1. 這可能會對性能產生影響，因為現在將執行兩個或多個查詢（取決於關聯），而不是一個連接。如果 `humans` 的 select 返回了大量的 ID，`treats` 的 select 可能會發送太多的 ID。
2. 由於不再執行連接，具有排序或限制的查詢現在在內存中進行排序，因為無法將一個表的順序應用到另一個表。
3. 必須在所有需要禁用連接的關聯中添加此設置。Rails 無法猜測這一點，因為關聯加載是延遲的，為了在 `@dog.treats` 中加載 `treats`，Rails 已經需要知道應該生成什麼 SQL。

### Schema 快取

如果要為每個數據庫加載 schema 快取，必須在每個數據庫配置中設置 `schema_cache_path`，並在應用程序配置中設置 `config.active_record.lazily_load_schema_cache = true`。請注意，這將在建立數據庫連接時延遲加載快取。

## 注意事項

### 載入平衡的副本

Rails 也不支持副本的自動負載平衡。這非常依賴於您的基礎架構。我們可能會在將來實現基本的、原始的負載平衡，但對於規模化的應用程序，這應該是您的應用程序在 Rails 之外處理的事情。
