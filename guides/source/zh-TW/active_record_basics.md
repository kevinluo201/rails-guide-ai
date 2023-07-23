**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: b2cb0ab668ead9e8bd48cbd1bcac9b59
Active Record 基礎
====================

本指南是 Active Record 的介紹。

閱讀完本指南後，您將了解以下內容：

* 什麼是物件關聯映射（Object Relational Mapping）和 Active Record，以及它們在 Rails 中的使用方式。
* Active Record 如何適用於模型-視圖-控制器（Model-View-Controller）範式。
* 如何使用 Active Record 模型來操作存儲在關聯式數據庫中的數據。
* Active Record 的架構命名慣例。
* 數據庫遷移、驗證、回調和關聯的概念。

--------------------------------------------------------------------------------

什麼是 Active Record？
----------------------

Active Record 是 [MVC][] 中的 M，即模型（model），它是系統的一個層面，負責表示業務數據和邏輯。Active Record 促進了創建和使用需要將數據持久存儲到數據庫中的業務對象。它是 Active Record 模式的一種實現，而 Active Record 模式本身是對對象關聯映射系統的描述。

### Active Record 模式

[Active Record 是由 Martin Fowler 在他的書《企業應用架構模式》中描述的][MFAR]。在 Active Record 中，對象既包含持久數據，也包含操作該數據的行為。Active Record 的觀點是，將數據訪問邏輯作為對象的一部分，可以教育使用該對象的用戶如何向數據庫寫入和讀取數據。

### 物件關聯映射

物件關聯映射（Object Relational Mapping），通常簡稱為 ORM，是一種將應用程序中豐富的對象與關聯數據庫管理系統中的表格相連接的技術。使用 ORM，應用程序中對象的屬性和關係可以輕鬆地存儲和檢索，而無需直接編寫 SQL 語句，並且需要較少的數據庫訪問代碼。

注意：瞭解關聯數據庫管理系統（RDBMS）和結構化查詢語言（SQL）的基本知識有助於充分理解 Active Record。如果您想要進一步學習，請參考 [這個教程][sqlcourse]（或 [這個教程][rdbmsinfo]），或以其他方式學習。

### Active Record 作為 ORM 框架

Active Record 提供了幾個機制，其中最重要的是能夠：

* 表示模型及其數據。
* 表示這些模型之間的關聯。
* 通過相關模型表示繼承層次結構。
* 在將模型持久存儲到數據庫之前驗證模型。
* 以面向對象的方式執行數據庫操作。

Active Record 中的配置優於約定
----------------------------------------------

在使用其他編程語言或框架編寫應用程序時，可能需要編寫大量的配置代碼。這對於一般的 ORM 框架尤其如此。然而，如果您遵循 Rails 採用的約定，創建 Active Record 模型時將只需要編寫非常少量的配置（在某些情況下甚至不需要配置）。這個想法是，如果您大部分時間都按照相同的方式配置應用程序，那麼這應該是默認方式。因此，只有在無法遵循標準約定的情況下才需要顯式配置。

### 命名慣例

默認情況下，Active Record 使用一些命名慣例來確定模型和數據庫表之間的映射方式。Rails 會將您的類名轉為複數形式以找到相應的數據庫表。因此，對於一個名為 `Book` 的類，您應該有一個名為 **books** 的數據庫表。Rails 的複數形式機制非常強大，能夠對常規和不規則的單詞進行複數化（和單數化）。當使用由兩個或多個單詞組成的類名時，模型類名應遵循 Ruby 的命名慣例，使用 CamelCase 形式，而表名必須使用 snake_case 形式。例如：

* 模型類 - 單數形式，每個單詞的首字母大寫（例如，`BookClub`）。
* 數據庫表 - 複數形式，單詞之間用下劃線分隔（例如，`book_clubs`）。

| 模型 / 類名      | 表格 / 架構名稱 |
| ---------------- | -------------- |
| `Article`        | `articles`     |
| `LineItem`       | `line_items`   |
| `Deer`           | `deers`        |
| `Mouse`          | `mice`         |
| `Person`         | `people`       |

### 架構慣例

Active Record 使用命名慣例來命名數據庫表中的列，具體取決於這些列的用途。

* **外鍵** - 這些字段的命名應遵循 `單數形式的表名_id` 的模式（例如，`item_id`、`order_id`）。這些字段是 Active Record 在創建模型之間的關聯時尋找的字段。
* **主鍵** - 默認情況下，Active Record 將使用一個名為 `id` 的整數列作為表的主鍵（對於 PostgreSQL 和 MySQL 使用 `bigint`，對於 SQLite 使用 `integer`）。使用 [Active Record 遷移](active_record_migrations.html) 創建表時，將自動創建此列。
還有一些可選的欄位名稱，可以為Active Record實例添加額外的功能：

* `created_at` - 在記錄首次創建時自動設置為當前日期和時間。
* `updated_at` - 在記錄創建或更新時自動設置為當前日期和時間。
* `lock_version` - 為模型添加[樂觀鎖定](https://api.rubyonrails.org/classes/ActiveRecord/Locking.html)。
* `type` - 指定模型使用[單表繼承](https://api.rubyonrails.org/classes/ActiveRecord/Base.html#class-ActiveRecord::Base-label-Single+table+inheritance)。
* `(association_name)_type` - 存儲[多態關聯](association_basics.html#polymorphic-associations)的類型。
* `(table_name)_count` - 用於緩存關聯上的對象數量。例如，`Article`類中有許多`Comment`實例的`comments_count`列將緩存每篇文章的現有評論數量。

注意：雖然這些欄位名稱是可選的，但實際上它們是由Active Record保留的。除非您需要額外的功能，否則應避免使用保留關鍵字。例如，`type`是用於指定使用單表繼承（STI）的表的保留關鍵字。如果您不使用STI，可以嘗試使用類似的關鍵字，如“context”，這可能仍然準確描述您正在建模的數據。

創建Active Record模型
----------------------

在生成應用程序時，將在`app/models/application_record.rb`中創建一個抽象的`ApplicationRecord`類。這是應用程序中所有模型的基類，它將一個普通的Ruby類轉換為Active Record模型。

要創建Active Record模型，請將其子類化為`ApplicationRecord`類，然後就可以使用了：

```ruby
class Product < ApplicationRecord
end
```

這將創建一個`Product`模型，將其映射到數據庫中的`products`表。通過這樣做，您還可以將該表中每一行的列與模型實例的屬性進行映射。假設`products`表是使用SQL（或其擴展之一）語句創建的，如下所示：

```sql
CREATE TABLE products (
  id int(11) NOT NULL auto_increment,
  name varchar(255),
  PRIMARY KEY  (id)
);
```

上面的模式聲明了一個具有兩個列`id`和`name`的表。該表的每一行表示具有這兩個參數的某個產品。因此，您可以編寫以下代碼：

```ruby
p = Product.new
p.name = "Some Book"
puts p.name # "Some Book"
```

覆蓋命名慣例
----------------

如果您需要遵循不同的命名慣例或需要使用遺留數據庫與Rails應用程序，則可以輕鬆覆蓋默認慣例。

由於`ApplicationRecord`繼承自`ActiveRecord::Base`，因此應用程序的模型將具有許多有用的方法可供使用。例如，您可以使用`ActiveRecord::Base.table_name=`方法自定義要使用的表名：

```ruby
class Product < ApplicationRecord
  self.table_name = "my_products"
end
```

如果這樣做，您將需要在測試定義中使用`set_fixture_class`方法手動定義托管測試數據（`my_products.yml`）的類名：

```ruby
# test/models/product_test.rb
class ProductTest < ActiveSupport::TestCase
  set_fixture_class my_products: Product
  fixtures :my_products
  # ...
end
```

還可以使用`ActiveRecord::Base.primary_key=`方法覆蓋作為表的主鍵使用的列：

```ruby
class Product < ApplicationRecord
  self.primary_key = "product_id"
end
```

注意：**Active Record不支持使用非主鍵列命名為`id`。**

注意：如果您嘗試創建一個名為`id`的列，而該列不是主鍵，Rails將在遷移期間拋出錯誤，例如：`you can't redefine the primary key column 'id' on 'my_products'.` `To define a custom primary key, pass { id: false } to create_table.`

CRUD：讀取和寫入數據
-------------------

CRUD是我們用於操作數據的四個動詞的首字母縮寫：**C**reate（創建）、**R**ead（讀取）、**U**pdate（更新）和**D**elete（刪除）。Active Record會自動創建方法，允許應用程序讀取和操作存儲在其表中的數據。

### 創建

可以從哈希、塊或在創建後手動設置其屬性的方式來創建Active Record對象。`new`方法將返回一個新對象，而`create`將返回該對象並將其保存到數據庫中。

例如，假設有一個名為`User`的模型，具有`name`和`occupation`兩個屬性，則`create`方法調用將創建並將一條新記錄保存到數據庫中：

```ruby
user = User.create(name: "David", occupation: "Code Artist")
```
使用`new`方法可以實例化一個對象而不保存：

```ruby
user = User.new
user.name = "David"
user.occupation = "Code Artist"
```

調用`user.save`將將記錄提交到數據庫。

最後，如果提供了一個塊，`create`和`new`都將將新對象傳遞給該塊進行初始化，而只有`create`會將結果對象持久化到數據庫：

```ruby
user = User.new do |u|
  u.name = "David"
  u.occupation = "Code Artist"
end
```

### 讀取

Active Record提供了一個豐富的API來訪問數據庫中的數據。以下是Active Record提供的幾種不同數據訪問方法的示例。

```ruby
# 返回包含所有用戶的集合
users = User.all
```

```ruby
# 返回第一個用戶
user = User.first
```

```ruby
# 返回名為David的第一個用戶
david = User.find_by(name: 'David')
```

```ruby
# 查找所有名為David且職業為Code Artist的用戶，按照創建時間倒序排序
users = User.where(name: 'David', occupation: 'Code Artist').order(created_at: :desc)
```

您可以在[Active Record查詢接口](active_record_querying.html)指南中了解更多關於查詢Active Record模型的信息。

### 更新

一旦檢索到Active Record對象，可以修改其屬性並將其保存到數據庫。

```ruby
user = User.find_by(name: 'David')
user.name = 'Dave'
user.save
```

一種簡寫方式是使用將屬性名映射到所需值的哈希，如下所示：

```ruby
user = User.find_by(name: 'David')
user.update(name: 'Dave')
```

這在同時更新多個屬性時最有用。

如果您想要批量更新多個記錄**而不調用回調函數或驗證**，可以直接使用`update_all`更新數據庫：

```ruby
User.update_all max_login_attempts: 3, must_change_password: true
```

### 刪除

同樣地，一旦檢索到Active Record對象，可以刪除它，從數據庫中刪除它。

```ruby
user = User.find_by(name: 'David')
user.destroy
```

如果您想要批量刪除多個記錄，可以使用`destroy_by`或`destroy_all`方法：

```ruby
# 查找並刪除所有名為David的用戶
User.destroy_by(name: 'David')

# 刪除所有用戶
User.destroy_all
```

驗證
-----------

Active Record允許您在將模型寫入數據庫之前驗證模型的狀態。有幾種方法可以檢查模型並驗證屬性值是否為空，是否唯一且不在數據庫中，是否遵循特定格式等等。

`save`、`create`和`update`等方法在將模型持久化到數據庫之前對模型進行驗證。當模型無效時，這些方法返回`false`，並且不執行任何數據庫操作。所有這些方法都有一個bang對應方法（即`save!`、`create!`和`update!`），它們更嚴格，當驗證失敗時引發`ActiveRecord::RecordInvalid`異常。以下是一個快速示例：

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

您可以在[Active Record驗證指南](active_record_validations.html)中了解更多關於驗證的信息。

回調函數
---------

Active Record回調函數允許您將代碼附加到模型的某些事件上。這使您可以通過在發生這些事件時透明地執行代碼來為模型添加行為，例如在創建新記錄、更新記錄、刪除記錄等時。

```ruby
class User < ApplicationRecord
  after_create :log_new_user

  private
    def log_new_user
      puts "A new user was registered"
    end
end
```

```irb
irb> @user = User.create
A new user was registered
```

您可以在[Active Record回調指南](active_record_callbacks.html)中了解更多關於回調函數的信息。

遷移
----------

Rails提供了一種方便的方式來通過遷移管理對數據庫模式的更改。遷移使用特定於域的語言編寫，並存儲在對Active Record支持的任何數據庫上執行的文件中。

以下是創建一個名為`publications`的新表的遷移示例：

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

請注意，上述代碼是與數據庫無關的：它可以在MySQL、PostgreSQL、SQLite和其他數據庫中運行。

Rails跟踪已提交到數據庫的遷移並將它們存儲在同一數據庫中的相鄰表`schema_migrations`中。
要運行遷移並創建表，您需要運行 `bin/rails db:migrate`，
要回滾並刪除表，則運行 `bin/rails db:rollback`。

您可以在[Active Record遷移指南](active_record_migrations.html)中了解更多關於遷移的資訊。

關聯
----

Active Record關聯允許您定義模型之間的關係。
關聯可用於描述一對一、一對多和多對多的關係。例如，像“作者有多本書”這樣的關係可以定義如下：

```ruby
class Author < ApplicationRecord
  has_many :books
end
```

現在，Author類別具有添加和刪除作者的書籍等方法。

您可以在[Active Record關聯指南](association_basics.html)中了解更多關於關聯的資訊。
[MVC]: https://en.wikipedia.org/wiki/Model%E2%80%93view%E2%80%93controller
[MFAR]: https://www.martinfowler.com/eaaCatalog/activeRecord.html
[ORM]: https://en.wikipedia.org/wiki/Object-relational_mapping
[sqlcourse]: https://www.khanacademy.org/computing/computer-programming/sql
[rdbmsinfo]: https://www.devart.com/what-is-rdbms/
