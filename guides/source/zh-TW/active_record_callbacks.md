**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 320082396ef549e27ab4cb837ec975dd
Active Record 回呼函式
=======================

本指南教你如何連接到 Active Record 物件的生命週期。

閱讀完本指南後，你將會知道：

* Active Record 物件的某些事件何時發生
* 如何建立回呼方法以回應物件生命週期中的事件
* 如何建立封裝回呼常見行為的特殊類別

--------------------------------------------------------------------------------

物件生命週期
---------------------

在 Rails 應用程式正常運作期間，物件可能會被建立、更新和刪除。Active Record 提供了鉤子(hooks)來連接到這個*物件生命週期*，以便你可以控制應用程式和其資料。

回呼(callbacks)允許你在物件狀態變更之前或之後觸發邏輯。

```ruby
class Baby < ApplicationRecord
  after_create -> { puts "恭喜！" }
end
```

```irb
irb> @baby = Baby.create
恭喜！
```

如你所見，有許多生命週期事件，你可以選擇在這些事件之前、之後或甚至包圍它們。

回呼概觀
------------------

回呼是在物件生命週期的某些時刻被呼叫的方法。透過回呼，你可以撰寫在 Active Record 物件被建立、儲存、更新、刪除、驗證或從資料庫載入時執行的程式碼。

### 註冊回呼

為了使用可用的回呼，你需要註冊它們。你可以將回呼實作為普通方法，並使用巨集風格的類別方法來註冊它們作為回呼：

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

巨集風格的類別方法也可以接收一個區塊。如果你的區塊內的程式碼非常短，只需要一行就能容納，那麼考慮使用這種風格：

```ruby
class User < ApplicationRecord
  validates :login, :email, presence: true

  before_create do
    self.name = login.capitalize if name.blank?
  end
end
```

或者你可以將一個 proc 傳遞給回呼以觸發它。

```ruby
class User < ApplicationRecord
  before_create ->(user) { user.name = user.login.capitalize if user.name.blank? }
end
```

最後，你可以定義自己的自訂回呼物件，我們稍後會在[下方](#回呼類別)更詳細地介紹。

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

回呼也可以註冊只在特定生命週期事件上觸發，這樣可以完全控制回呼觸發的時間和上下文。

```ruby
class User < ApplicationRecord
  before_validation :normalize_name, on: :create

  # :on 也可以接收陣列
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

將回呼方法宣告為私有是一種良好的實踐。如果保持為公開，它們可以從模型外部呼叫，違反物件封裝的原則。

警告。在回呼內部避免呼叫 `update`、`save` 或其他會對物件產生副作用的方法。例如，在回呼內部不要呼叫 `update(attribute: "value")`。這可能會改變模型的狀態，並在提交期間產生意外的副作用。相反，你可以在 `before_create`、`before_update` 或更早的回呼中直接安全地指派值（例如，`self.attribute = "value"`）。

可用的回呼
-------------------

以下是所有可用的 Active Record 回呼的清單，按照它們在相應操作期間被呼叫的順序列出：

### 建立物件

* [`before_validation`][]
* [`after_validation`][]
* [`before_save`][]
* [`around_save`][]
* [`before_create`][]
* [`around_create`][]
* [`after_create`][]
* [`after_save`][]
* [`after_commit`][] / [`after_rollback`][]


### 更新物件

* [`before_validation`][]
* [`after_validation`][]
* [`before_save`][]
* [`around_save`][]
* [`before_update`][]
* [`around_update`][]
* [`after_update`][]
* [`after_save`][]
* [`after_commit`][] / [`after_rollback`][]


警告。`after_save` 在建立和更新時都會執行，但總是在更具體的 `after_create` 和 `after_update` 回呼之後執行，不論巨集呼叫的順序如何。

### 刪除物件

* [`before_destroy`][]
* [`around_destroy`][]
* [`after_destroy`][]
* [`after_commit`][] / [`after_rollback`][]


注意：`before_destroy` 回呼應該放在 `dependent: :destroy` 關聯之前（或使用 `prepend: true` 選項），以確保它們在 `dependent: :destroy` 刪除記錄之前執行。

警告。`after_commit` 提供的保證與 `after_save`、`after_update` 和 `after_destroy` 不同。例如，如果 `after_save` 中發生例外，事務將被回滾，資料將不會被持久化。而 `after_commit` 中發生的任何事情都可以保證事務已經完成，資料已經被持久化到資料庫。更多關於[事務回呼](#事務回呼)的內容請參閱下方。
### `after_initialize` 和 `after_find`

每當一個 Active Record 物件被實例化時，[`after_initialize`][] 回調函數將被調用，無論是直接使用 `new` 還是從數據庫加載記錄。這可以避免直接覆蓋 Active Record 的 `initialize` 方法。

從數據庫加載記錄時，[`after_find`][] 回調函數將被調用。如果兩者都被定義，`after_find` 將在 `after_initialize` 之前被調用。

注意：`after_initialize` 和 `after_find` 回調函數沒有對應的 `before_*` 回調函數。

它們可以像其他 Active Record 回調函數一樣註冊。

```ruby
class User < ApplicationRecord
  after_initialize do |user|
    puts "你已經初始化了一個物件！"
  end

  after_find do |user|
    puts "你已經找到了一個物件！"
  end
end
```

```irb
irb> User.new
你已經初始化了一個物件！
=> #<User id: nil>

irb> User.first
你已經找到了一個物件！
你已經初始化了一個物件！
=> #<User id: 1>
```


### `after_touch`

[`after_touch`][] 回調函數將在每次觸發 Active Record 物件時被調用。

```ruby
class User < ApplicationRecord
  after_touch do |user|
    puts "你已經觸發了一個物件"
  end
end
```

```irb
irb> u = User.create(name: 'Kuldeep')
=> #<User id: 1, name: "Kuldeep", created_at: "2013-11-25 12:17:49", updated_at: "2013-11-25 12:17:49">

irb> u.touch
你已經觸發了一個物件
=> true
```

它可以與 `belongs_to` 一起使用：

```ruby
class Book < ApplicationRecord
  belongs_to :library, touch: true
  after_touch do
    puts '一本書被觸發了'
  end
end

class Library < ApplicationRecord
  has_many :books
  after_touch :log_when_books_or_library_touched

  private
    def log_when_books_or_library_touched
      puts '書籍/圖書館被觸發了'
    end
end
```

```irb
irb> @book = Book.last
=> #<Book id: 1, library_id: 1, created_at: "2013-11-25 17:04:22", updated_at: "2013-11-25 17:05:05">

irb> @book.touch # 觸發 @book.library.touch
一本書被觸發了
書籍/圖書館被觸發了
=> true
```


執行回調函數
-----------------

以下方法觸發回調函數：

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

此外，`after_find` 回調函數由以下查詢方法觸發：

* `all`
* `first`
* `find`
* `find_by`
* `find_by_*`
* `find_by_*!`
* `find_by_sql`
* `last`

`after_initialize` 回調函數在每次初始化該類的新對象時觸發。

注意：`find_by_*` 和 `find_by_*!` 方法是根據每個屬性自動生成的動態查詢器。在 [動態查詢器部分](active_record_querying.html#dynamic-finders) 了解更多信息。

跳過回調函數
------------------

與驗證一樣，也可以使用以下方法跳過回調函數：

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

但是，應該謹慎使用這些方法，因為重要的業務規則和應用程序邏輯可能保存在回調函數中。不了解可能的影響而繞過它們可能導致無效的數據。

停止執行
-----------------

當您開始為模型註冊新的回調函數時，它們將被排隊執行。此隊列將包括模型的所有驗證、註冊的回調函數和要執行的數據庫操作。

整個回調鏈被包裹在一個事務中。如果任何回調函數引發異常，執行鏈將停止並發出 ROLLBACK。要有意停止鏈，使用：

```ruby
throw :abort
```

警告。任何不是 `ActiveRecord::Rollback` 或 `ActiveRecord::RecordInvalid` 的異常，在回調鏈停止後將被 Rails 重新引發。此外，可能會破壞不希望 `save` 和 `update`（通常嘗試返回 `true` 或 `false`）引發異常的代碼。

注意：如果在 `after_destroy`、`before_destroy` 或 `around_destroy` 回調函數中引發 `ActiveRecord::RecordNotDestroyed`，它將不會被重新引發，並且 `destroy` 方法將返回 `false`。

關聯回調函數
--------------------

回調函數通過模型關係工作，甚至可以通過它們定義。假設一個例子，其中一個用戶有多篇文章。如果用戶被刪除，用戶的文章應該被刪除。讓我們通過與 `Article` 模型的關聯，在 `User` 模型上添加一個 `after_destroy` 回調函數：

```ruby
class User < ApplicationRecord
  has_many :articles, dependent: :destroy
end

class Article < ApplicationRecord
  after_destroy :log_destroy_action

  def log_destroy_action
    puts '文章被刪除'
  end
end
```

```irb
irb> user = User.first
=> #<User id: 1>
irb> user.articles.create!
=> #<Article id: 1, user_id: 1>
irb> user.destroy
文章被刪除
=> #<User id: 1>
```
條件回調
---------------------

與驗證一樣，我們也可以根據滿足給定條件的情況來調用回調方法。我們可以使用`:if`和`:unless`選項來實現這一點，這些選項可以接受符號、`Proc`或數組。

當您希望指定在哪些條件下應該調用回調時，可以使用`:if`選項。如果您希望指定在哪些條件下不應該調用回調，則可以使用`:unless`選項。

### 使用符號的`:if`和`:unless`

您可以將`:if`和`:unless`選項與與回調之前將調用的謂詞方法名對應的符號關聯起來。

使用`:if`選項時，如果謂詞方法返回`false`，則不會執行回調；使用`:unless`選項時，如果謂詞方法返回`true`，則不會執行回調。這是最常見的選項。

```ruby
class Order < ApplicationRecord
  before_save :normalize_card_number, if: :paid_with_card?
end
```

使用此形式的註冊，還可以註冊幾個不同的謂詞，以檢查是否應該執行回調。我們將在下面討論這個問題。

### 使用`Proc`的`:if`和`:unless`

可以將`:if`和`:unless`與`Proc`對象關聯起來。這個選項最適合編寫短的驗證方法，通常是一行代碼：

```ruby
class Order < ApplicationRecord
  before_save :normalize_card_number,
    if: Proc.new { |order| order.paid_with_card? }
end
```

由於`Proc`在對象的上下文中求值，所以也可以這樣寫：

```ruby
class Order < ApplicationRecord
  before_save :normalize_card_number, if: Proc.new { paid_with_card? }
end
```

### 多個回調條件

`:if`和`:unless`選項還可以接受一個`Proc`數組或方法名的符號：

```ruby
class Comment < ApplicationRecord
  before_save :filter_content,
    if: [:subject_to_parental_control?, :untrusted_author?]
end
```

您可以在條件列表中輕鬆包含一個`Proc`：

```ruby
class Comment < ApplicationRecord
  before_save :filter_content,
    if: [:subject_to_parental_control?, Proc.new { untrusted_author? }]
end
```

### 同時使用`:if`和`:unless`

回調可以在同一聲明中混合使用`:if`和`:unless`：

```ruby
class Comment < ApplicationRecord
  before_save :filter_content,
    if: Proc.new { forum.parental_control? },
    unless: Proc.new { author.trusted? }
end
```

只有在所有的`:if`條件都為`true`且所有的`:unless`條件都為`false`時，回調才會運行。

回調類
----------------

有時，您編寫的回調方法將非常有用，可以被其他模型重用。Active Record使得可以創建封裝回調方法的類，以便重用。

以下是一個示例，我們創建了一個類，其中包含一個`after_destroy`回調，用於處理文件系統上被丟棄文件的清理。這個行為可能不僅僅適用於我們的`PictureFile`模型，我們可能希望共享它，因此將其封裝到一個單獨的類中是一個好主意。這將使測試該行為和更改該行為變得更加容易。

```ruby
class FileDestroyerCallback
  def after_destroy(file)
    if File.exist?(file.filepath)
      File.delete(file.filepath)
    end
  end
end
```

在上面的類中聲明時，回調方法將接收模型對象作為參數。這將在任何使用該類的模型上工作，如下所示：

```ruby
class PictureFile < ApplicationRecord
  after_destroy FileDestroyerCallback.new
end
```

請注意，我們需要實例化一個新的`FileDestroyerCallback`對象，因為我們將回調聲明為實例方法。如果回調使用實例化對象的狀態，這將特別有用。然而，通常更合理的是將回調聲明為類方法：

```ruby
class FileDestroyerCallback
  def self.after_destroy(file)
    if File.exist?(file.filepath)
      File.delete(file.filepath)
    end
  end
end
```

當以這種方式聲明回調方法時，在我們的模型中不需要實例化一個新的`FileDestroyerCallback`對象。

```ruby
class PictureFile < ApplicationRecord
  after_destroy FileDestroyerCallback
end
```

您可以在回調類中聲明任意多個回調。

事務回調
---------------------

### 處理一致性

在完成數據庫事務後，還會觸發兩個額外的回調：[`after_commit`][]和[`after_rollback`][]。這些回調與`after_save`回調非常相似，只是它們在數據庫更改提交或回滾之後才執行。當您的Active Record模型需要與不屬於數據庫事務的外部系統交互時，它們非常有用。
例如，考慮之前的例子，其中“PictureFile”模型需要在相應的記錄被刪除後刪除文件。如果在調用“after_destroy”回調後引發任何異常並且事務回滾，則文件將被刪除，模型將處於不一致的狀態。例如，假設以下代碼中的“picture_file_2”無效並且“save！”方法引發錯誤。

```ruby
PictureFile.transaction do
  picture_file_1.destroy
  picture_file_2.save!
end
```

通過使用“after_commit”回調，我們可以處理這種情況。

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

注意：“:on”選項指定回調將在何時觸發。如果不提供“:on”選項，則回調將對每個操作觸發。

### 上下文很重要

由於在創建、更新或刪除時僅使用“after_commit”回調是常見的，因此為這些操作提供了別名：

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

警告。當事務完成時，將為在該事務中創建、更新或刪除的所有模型調用“after_commit”或“after_rollback”回調。但是，如果在其中一個回調中引發異常，異常將冒泡並且不會執行任何剩餘的“after_commit”或“after_rollback”方法。因此，如果回調代碼可能引發異常，您需要在回調內部捕獲並處理它，以允許其他回調運行。

警告。在“after_commit”或“after_rollback”回調中執行的代碼本身不包含在事務中。

警告。同時使用相同方法名的“after_create_commit”和“after_update_commit”只允許最後定義的回調生效，因為它們都內部別名為“after_commit”，它會覆蓋以前定義的具有相同方法名的回調。

```ruby
class User < ApplicationRecord
  after_create_commit :log_user_saved_to_db
  after_update_commit :log_user_saved_to_db

  private
    def log_user_saved_to_db
      puts 'User was saved to database'
    end
end
```

```irb
irb> @user = User.create # 不打印任何內容

irb> @user.save # 更新@user
User was saved to database
```

### `after_save_commit`

還有[`after_save_commit`]，它是使用“after_commit”回調的創建和更新的別名：

```ruby
class User < ApplicationRecord
  after_save_commit :log_user_saved_to_db

  private
    def log_user_saved_to_db
      puts 'User was saved to database'
    end
end
```

```irb
irb> @user = User.create # 創建一個User
User was saved to database

irb> @user.save # 更新@user
User was saved to database
```

### 事務回調順序

在定義多個事務性“after_”回調（“after_commit”，“after_rollback”等）時，它們的順序將與定義時相反。

```ruby
class User < ActiveRecord::Base
  after_commit { puts("this actually gets called second") }
  after_commit { puts("this actually gets called first") }
end
```

注意：這也適用於所有“after_*_commit”變體，例如“after_destroy_commit”。
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
