**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 67ad41dc27cc9079db9a7e31dffa5aac
複数のデータベースをActive Recordで使用する
=====================================

このガイドでは、Railsアプリケーションで複数のデータベースを使用する方法について説明します。

このガイドを読み終えると、以下のことがわかります。

* 複数のデータベースのためにアプリケーションを設定する方法
* 自動接続切り替えの動作方法
* 複数のデータベースに対する水平シャーディングの使用方法
* サポートされている機能とまだ進行中の機能

--------------------------------------------------------------------------------

アプリケーションが人気を集め、利用が増えるにつれて、新しいユーザーとそのデータをサポートするためにアプリケーションをスケールする必要があります。アプリケーションがスケールする方法の1つは、データベースレベルでのスケールです。Railsは現在、複数のデータベースをサポートしているため、データを1つの場所にすべて保存する必要はありません。

現時点では、以下の機能がサポートされています。

* 複数のライターデータベースとそれぞれのレプリカ
* モデルごとの自動接続切り替え
* HTTP動詞と最近の書き込みに応じたライターとレプリカの自動切り替え
* 複数のデータベースの作成、削除、マイグレーション、および操作のためのRailsタスク

以下の機能は（まだ）サポートされていません。

* レプリカの負荷分散

## アプリケーションの設定

Railsはほとんどの作業を自動化しようとしますが、複数のデータベースに対応するためにはまだいくつかの手順が必要です。

新しいテーブルを追加するために新しいデータベースを追加する必要があるとします。新しいデータベースの名前は「animals」です。

`database.yml`は次のようになります。

```yaml
production:
  database: my_primary_database
  adapter: mysql2
  username: root
  password: <%= ENV['ROOT_PASSWORD'] %>
```

最初の設定にレプリカを追加し、animalsという名前の2番目のデータベースとそのレプリカも追加します。これを行うには、`database.yml`を2層から3層の設定に変更する必要があります。

プライマリの設定が提供された場合、それは「デフォルト」の設定として使用されます。`"primary"`という名前の設定がない場合、Railsは各環境のデフォルトの設定として最初の設定を使用します。デフォルトの設定は、デフォルトのRailsのファイル名を使用します。たとえば、プライマリの設定はスキーマファイルに`schema.rb`を使用し、他のすべてのエントリはファイル名に`[CONFIGURATION_NAMESPACE]_schema.rb`を使用します。

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

複数のデータベースを使用する場合、いくつかの重要な設定があります。

まず、`primary`と`primary_replica`のデータベース名は同じである必要があります。これは`animals`と`animals_replica`の場合も同様です。

次に、ライターとレプリカのユーザー名は異なる必要があり、レプリカユーザーのデータベースの権限は読み取りのみに設定する必要があります。

レプリカデータベースを使用する場合、`database.yml`のレプリカに`replica: true`のエントリを追加する必要があります。これは、Railsがどちらがレプリカでどちらがライターかを知る方法がないためです。Railsはレプリカに対してマイグレーションなどの特定のタスクを実行しません。

最後に、新しいライターデータベースでは、`migrations_paths`をそのデータベースのマイグレーションを保存するディレクトリに設定する必要があります。このガイドの後半で`migrations_paths`について詳しく見ていきます。

新しいデータベースができたので、接続モデルを設定しましょう。新しいデータベースを使用するために、新しい抽象クラスを作成し、animalsデータベースに接続する必要があります。

```ruby
class AnimalsRecord < ApplicationRecord
  self.abstract_class = true

  connects_to database: { writing: :animals, reading: :animals_replica }
end
```

次に、`ApplicationRecord`を更新して新しいレプリカを認識するようにします。

```ruby
class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  connects_to database: { writing: :primary, reading: :primary_replica }
end
```

アプリケーションレコードに別の名前のクラスを使用する場合は、`primary_abstract_class`を設定する必要があります。これにより、Railsが`ActiveRecord::Base`がどのクラスと接続を共有するかを知ることができます。

```ruby
class PrimaryApplicationRecord < ActiveRecord::Base
  primary_abstract_class
end
```

プライマリ/primary_replicaに接続するクラスは、標準のRailsアプリケーションと同様に、プライマリの抽象クラスを継承することができます。
```ruby
class Person < ApplicationRecord
end
```

デフォルトでは、Railsはプライマリとレプリカのデータベースロールを`writing`と`reading`と予想しています。もし既存のシステムがある場合、変更したくない設定がすでにあるかもしれません。その場合、アプリケーションの設定で新しいロール名を設定することができます。

```ruby
config.active_record.writing_role = :default
config.active_record.reading_role = :readonly
```

テーブルに対して複数の個別のモデルを同じデータベースに接続する代わりに、単一のモデルに接続してからそのモデルを継承することが重要です。データベースクライアントにはオープンできる接続数の制限があり、これを行うと接続数が増えてしまいます。なぜなら、Railsは接続仕様名にモデルクラス名を使用するからです。

`database.yml`と新しいモデルが設定されたので、データベースを作成する時が来ました。Rails 6.0には、Railsで複数のデータベースを使用するために必要なすべてのrailsタスクが付属しています。

`bin/rails -T`を実行すると、実行可能なすべてのコマンドが表示されます。次のような結果が表示されるはずです。

```bash
$ bin/rails -T
bin/rails db:create                          # DATABASE_URLまたはconfig/database.ymlに基づいてデータベースを作成します...
bin/rails db:create:animals                  # 現在の環境のanimalsデータベースを作成します
bin/rails db:create:primary                  # 現在の環境のプライマリデータベースを作成します
bin/rails db:drop                            # DATABASE_URLまたはconfig/database.ymlに基づいてデータベースを削除します...
bin/rails db:drop:animals                    # 現在の環境のanimalsデータベースを削除します
bin/rails db:drop:primary                    # 現在の環境のプライマリデータベースを削除します
bin/rails db:migrate                         # データベースをマイグレーションします（オプション：VERSION=x、VERBOSE=false、SCOPE=blog）
bin/rails db:migrate:animals                 # 現在の環境のanimalsデータベースをマイグレーションします
bin/rails db:migrate:primary                 # 現在の環境のプライマリデータベースをマイグレーションします
bin/rails db:migrate:status                  # マイグレーションのステータスを表示します
bin/rails db:migrate:status:animals          # animalsデータベースのマイグレーションのステータスを表示します
bin/rails db:migrate:status:primary          # プライマリデータベースのマイグレーションのステータスを表示します
bin/rails db:reset                           # 現在の環境のスキーマからすべてのデータベースを削除して再作成し、シードをロードします
bin/rails db:reset:animals                   # 現在の環境のanimalsデータベースをスキーマから削除して再作成し、シードをロードします
bin/rails db:reset:primary                   # 現在の環境のプライマリデータベースをスキーマから削除して再作成し、シードをロードします
bin/rails db:rollback                        # スキーマを前のバージョンにロールバックします（ステップを指定する場合はSTEP=n）
bin/rails db:rollback:animals                # 現在の環境のanimalsデータベースをロールバックします（ステップを指定する場合はSTEP=n）
bin/rails db:rollback:primary                # 現在の環境のプライマリデータベースをロールバックします（ステップを指定する場合はSTEP=n）
bin/rails db:schema:dump                     # データベーススキーマファイルを作成します（db/schema.rbまたはdb/structure.sqlのいずれか...
bin/rails db:schema:dump:animals             # データベーススキーマファイルを作成します（db/schema.rbまたはdb/structure.sqlのいずれか...
bin/rails db:schema:dump:primary             # 任意のDBでポータブルなdb/schema.rbファイルを作成します...
bin/rails db:schema:load                     # データベーススキーマファイルをロードします（db/schema.rbまたはdb/structure.sqlのいずれか...
bin/rails db:schema:load:animals             # データベーススキーマファイルをロードします（db/schema.rbまたはdb/structure.sqlのいずれか...
bin/rails db:schema:load:primary             # データベーススキーマファイルをロードします（db/schema.rbまたはdb/structure.sqlのいずれか...
bin/rails db:setup                           # すべてのデータベースを作成し、すべてのスキーマをロードし、シードデータで初期化します（最初にすべてのデータベースを削除するにはdb:resetを使用します）
bin/rails db:setup:animals                   # animalsデータベースを作成し、スキーマをロードし、シードデータで初期化します（最初にデータベースを削除するにはdb:reset:animalsを使用します）
bin/rails db:setup:primary                   # プライマリデータベースを作成し、スキーマをロードし、シードデータで初期化します（最初にデータベースを削除するにはdb:reset:primaryを使用します）
```

`bin/rails db:create`のようなコマンドを実行すると、プライマリとanimalsの両方のデータベースが作成されます。データベースユーザーを作成するコマンドは存在せず、レプリカのための読み取り専用ユーザーをサポートするために手動で作成する必要があります。animalsデータベースだけを作成したい場合は、`bin/rails db:create:animals`を実行できます。

## スキーマとマイグレーションを管理せずにデータベースに接続する

スキーマ管理、マイグレーション、シードなどのデータベース管理タスクなしで外部データベースに接続したい場合は、データベースごとの設定オプション`database_tasks: false`を設定できます。デフォルトではtrueに設定されています。

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

## ジェネレータとマイグレーション

複数のデータベースのマイグレーションは、設定のデータベースキーの前にプレフィックスが付いた独自のフォルダに配置する必要があります。
Railsでは、`migrations_paths`をデータベースの設定に設定する必要もあります。これにより、Railsにマイグレーションを見つける場所を指示することができます。

たとえば、`animals`データベースの場合、マイグレーションは`db/animals_migrate`ディレクトリを探します。また、`primary`データベースの場合は`db/migrate`を探します。Railsのジェネレータは、`--database`オプションを受け取るようになりましたので、正しいディレクトリにファイルが生成されます。以下のようにコマンドを実行できます。

```bash
$ bin/rails generate migration CreateDogs name:string --database animals
```

Railsのジェネレータを使用している場合、スキャフォールドやモデルのジェネレータは抽象クラスを自動的に作成します。コマンドラインにデータベースのキーを渡すだけです。

```bash
$ bin/rails generate scaffold Dog name:string --database animals
```

データベース名と`Record`のクラスが作成されます。この例ではデータベース名は`Animals`なので、`AnimalsRecord`となります。

```ruby
class AnimalsRecord < ApplicationRecord
  self.abstract_class = true

  connects_to database: { writing: :animals }
end
```

生成されたモデルは自動的に`AnimalsRecord`を継承します。

```ruby
class Dog < AnimalsRecord
end
```

注意：Railsはライターのレプリカがどのデータベースかわからないため、これを抽象クラスに追加する必要があります。

Railsは新しいクラスを一度だけ生成します。新しいスキャフォールドで上書きされたり、スキャフォールドが削除されたりしても、クラスは削除されません。

既に抽象クラスがあり、その名前が`AnimalsRecord`と異なる場合は、`--parent`オプションを渡して別の抽象クラスを使用することができます。

```bash
$ bin/rails generate scaffold Dog name:string --database animals --parent Animals::Record
```

これにより、`AnimalsRecord`の生成がスキップされます。異なる親クラスを使用することをRailsに指示したためです。

## 自動ロール切り替えの有効化

最後に、アプリケーションで読み取り専用レプリカを使用するためには、自動切り替えのミドルウェアを有効にする必要があります。

自動切り替えにより、アプリケーションはHTTPの動詞と、リクエストユーザーによる最近の書き込みの有無に基づいて、ライターからレプリカまたはレプリカからライターに切り替えることができます。

アプリケーションがPOST、PUT、DELETE、またはPATCHリクエストを受け取る場合、アプリケーションは自動的にライターデータベースに書き込みます。書き込み後の指定された時間内は、アプリケーションはプライマリから読み取ります。GETまたはHEADリクエストの場合、アプリケーションは最近の書き込みがない限り、レプリカから読み取ります。

自動接続切り替えミドルウェアを有効にするには、自動切り替えジェネレータを実行します。

```bash
$ bin/rails g active_record:multi_db
```

次に、次の行のコメントを解除します。

```ruby
Rails.application.configure do
  config.active_record.database_selector = { delay: 2.seconds }
  config.active_record.database_resolver = ActiveRecord::Middleware::DatabaseSelector::Resolver
  config.active_record.database_resolver_context = ActiveRecord::Middleware::DatabaseSelector::Resolver::Session
end
```

Railsは「自分の書き込みを読む」と保証し、`delay`ウィンドウ内であればGETまたはHEADリクエストをライターに送信します。デフォルトでは、遅延は2秒に設定されています。データベースインフラストラクチャに基づいてこれを変更する必要があります。Railsは遅延ウィンドウ内の他のユーザーに対して「最近の書き込みを読む」とは保証せず、GETおよびHEADリクエストを最近書き込んだ場合を除いてレプリカに送信します。

Railsの自動接続切り替えは比較的原始的で、意図的にあまり多くのことを行いません。目標は、アプリケーション開発者がカスタマイズできる柔軟な自動接続切り替えの方法を示すシステムです。

Railsの設定では、切り替えの方法や基準を簡単に変更できます。たとえば、セッションではなくクッキーを使用して接続を切り替える場合は、独自のクラスを作成できます。

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

そして、ミドルウェアに渡します。

```ruby
config.active_record.database_selector = { delay: 2.seconds }
config.active_record.database_resolver = ActiveRecord::Middleware::DatabaseSelector::Resolver
config.active_record.database_resolver_context = MyCookieResolver
```

## 手動接続切り替えの使用

自動接続切り替えが十分ではない場合、アプリケーションがライターまたはレプリカに接続する必要がある場合があります。たとえば、特定のリクエストでは、POSTリクエストパスであっても常にレプリカにリクエストを送信する必要がある場合などです。

この場合、Railsは必要な接続に切り替えるための`connected_to`メソッドを提供しています。
```ruby
ActiveRecord::Base.connected_to(role: :reading) do
  # このブロック内のすべてのコードは、readingのロールに接続されます
end
```

`connected_to`呼び出しの「role」は、その接続ハンドラ（またはロール）に接続されている接続を検索します。`reading`接続ハンドラは、`connects_to`で`reading`というロール名で接続されたすべての接続を保持します。

`connected_to`にロールを指定すると、接続仕様名を使用して既存の接続を検索し、切り替えます。つまり、`connected_to(role: :nonexistent)`のような存在しないロールを渡すと、`ActiveRecord::ConnectionNotEstablished (No connection pool for 'ActiveRecord::Base' found for the 'nonexistent' role.)`というエラーが発生します。

クエリが読み取り専用であることをRailsに保証させるには、`prevent_writes: true`を渡します。これにより、書き込みのように見えるクエリがデータベースに送信されないようになります。また、レプリカデータベースを読み取り専用モードで設定する必要もあります。

```ruby
ActiveRecord::Base.connected_to(role: :reading, prevent_writes: true) do
  # Railsは各クエリを読み取りクエリであることを確認します
end
```

## 水平シャーディング

水平シャーディングとは、データベースを分割して各データベースサーバーの行数を減らすが、「シャード」全体で同じスキーマを維持することです。これは一般的に「マルチテナント」シャーディングと呼ばれます。

Railsで水平シャーディングをサポートするためのAPIは、Rails 6.0以降存在している複数のデータベース/垂直シャーディングAPIと似ています。

シャードは、次のように3層の設定で宣言されます。

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

次に、`shards`キーを使用してモデルを`connects_to` APIで接続します。

```ruby
class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  connects_to shards: {
    default: { writing: :primary, reading: :primary_replica },
    shard_one: { writing: :primary_shard_one, reading: :primary_shard_one_replica }
  }
end
```

最初のシャード名として`default`を使用する必要はありません。Railsは`connects_to`ハッシュの最初のシャード名を「デフォルト」の接続として扱います。この接続は、スキーマがシャード全体で同じであるタイプデータやその他の情報を読み込むために内部的に使用されます。

その後、モデルは`connected_to` APIを使用して接続を手動で切り替えることができます。シャーディングを使用する場合、`role`と`shard`の両方を渡す必要があります。

```ruby
ActiveRecord::Base.connected_to(role: :writing, shard: :default) do
  @id = Person.create! # ":default"という名前のシャードにレコードを作成します
end

ActiveRecord::Base.connected_to(role: :writing, shard: :shard_one) do
  Person.find(@id) # レコードが見つからないため、存在しません。なぜなら、それは":default"という名前のシャードで作成されたからです。
end
```

水平シャーディングAPIは読み取りレプリカもサポートしています。`connected_to` APIでロールとシャードを切り替えることができます。

```ruby
ActiveRecord::Base.connected_to(role: :reading, shard: :shard_one) do
  Person.first # シャード1の読み取りレプリカからレコードを検索します
end
```

## 自動シャード切り替えの有効化

アプリケーションは、提供されるミドルウェアを使用してリクエストごとに自動的にシャードを切り替えることができます。

`ShardSelector`ミドルウェアは、自動的にシャードを切り替えるためのフレームワークを提供します。Railsは、どのシャードに切り替えるかを決定するための基本的なフレームワークを提供し、必要に応じてアプリケーションがカスタムストラテジーを記述できるようにします。

`ShardSelector`は、ミドルウェアが動作を変更するために使用できるオプションのセット（現在は`lock`のみサポート）を受け取ります。`lock`はデフォルトでtrueになっており、ブロック内に入るとリクエストがシャードの切り替えを禁止します。`lock`がfalseの場合、シャードの切り替えが許可されます。テナントベースのシャーディングでは、アプリケーションコードがテナント間を誤って切り替えることを防ぐために、`lock`は常にtrueにする必要があります。

自動シャード切り替えのためのファイルを生成するために、データベースセレクタと同じジェネレータを使用できます。

```bash
$ bin/rails g active_record:multi_db
```

次に、ファイルで次のコメントを解除します。

```ruby
Rails.application.configure do
  config.active_record.shard_selector = { lock: true }
  config.active_record.shard_resolver = ->(request) { Tenant.find_by!(host: request.host).shard }
end
```

アプリケーションは、アプリケーション固有のモデルに依存するため、リゾルバのコードを提供する必要があります。例えば、リゾルバは次のようになります。

```ruby
config.active_record.shard_resolver = ->(request) {
  subdomain = request.subdomain
  tenant = Tenant.find_by_subdomain!(subdomain)
  tenant.shard
}
```

## 細かいデータベース接続の切り替え

Rails 6.1では、すべてのデータベースをグローバルに切り替えるのではなく、1つのデータベースの接続を切り替えることができます。

細かいデータベース接続の切り替えでは、抽象的な接続クラスは他の接続に影響を与えることなく接続を切り替えることができます。これは、`AnimalsRecord`のクエリをレプリカから読み取るように切り替え、同時に`ApplicationRecord`のクエリをプライマリに送信するために役立ちます。
```ruby
AnimalsRecord.connected_to(role: :reading) do
  Dog.first # animals_replicaから読み込み
  Person.first  # primaryから読み込み
end
```

シャードごとに接続を切り替えることも可能です。

```ruby
AnimalsRecord.connected_to(role: :reading, shard: :shard_one) do
  Dog.first # shard_one_replicaから読み込み。shard_one_replicaに接続が存在しない場合、ConnectionNotEstablishedエラーが発生します
  Person.first # primary writerから読み込み
end
```

プライマリデータベースクラスタのみを切り替える場合は、`ApplicationRecord`を使用します。

```ruby
ApplicationRecord.connected_to(role: :reading, shard: :shard_one) do
  Person.first # primary_shard_one_replicaから読み込み
  Dog.first # animals_primaryから読み込み
end
```

`ActiveRecord::Base.connected_to`を使用すると、接続をグローバルに切り替えることができます。

### データベース間の結合を伴う関連の処理

Rails 7.0以降、Active Recordには、複数のデータベースを結合する関連を処理するオプションがあります。`disable_joins: true`オプションを渡すと、2つ以上のクエリを実行して結合を無効化することができます。

例えば：

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

以前は、`disable_joins`なしで`@dog.treats`を呼び出すか、`disable_joins`なしで`@dog.yard`を呼び出すとエラーが発生しました。これは、データベースがクラスタ間の結合を処理できないためです。`disable_joins`オプションを使用すると、Railsはクラスタ間の結合を試みずに、複数のSELECTクエリを生成します。上記の関連では、`@dog.treats`は次のSQLを生成します：

```sql
SELECT "humans"."id" FROM "humans" WHERE "humans"."dog_id" = ?  [["dog_id", 1]]
SELECT "treats".* FROM "treats" WHERE "treats"."human_id" IN (?, ?, ?)  [["human_id", 1], ["human_id", 2], ["human_id", 3]]
```

一方、`@dog.yard`は次のSQLを生成します：

```sql
SELECT "home"."id" FROM "homes" WHERE "homes"."dog_id" = ? [["dog_id", 1]]
SELECT "yards".* FROM "yards" WHERE "yards"."home_id" = ? [["home_id", 1]]
```

このオプションにはいくつかの重要な注意点があります：

1. クエリが2つ以上実行されるため、パフォーマンスに影響がある場合があります（関連によります）。`humans`のSELECTが多数のIDを返した場合、`treats`のSELECTは多すぎるIDを送信する可能性があります。
2. 結合を行わなくなったため、順序や制限のあるクエリはインメモリでソートされます。1つのテーブルの順序は他のテーブルに適用できないためです。
3. この設定は、結合を無効化したいすべての関連に追加する必要があります。Railsは関連の読み込みが遅延されるため、`@dog.treats`で`treats`を読み込むためには、すでに生成するべきSQLを知っている必要があります。

### スキーマキャッシュ

各データベースにスキーマキャッシュをロードする場合は、各データベースの設定で`schema_cache_path`を設定し、アプリケーションの設定で`config.active_record.lazily_load_schema_cache = true`を設定する必要があります。データベース接続が確立されると、キャッシュは遅延してロードされます。

## 注意点

### レプリカの負荷分散

Railsはレプリカの自動的な負荷分散もサポートしていません。これは非常にインフラストラクチャに依存します。将来的には基本的なプリミティブな負荷分散を実装するかもしれませんが、スケールの大きなアプリケーションでは、Railsの外部で処理する必要があります。
